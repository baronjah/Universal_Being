extends Node
class_name iPhoneLiDARBridge

# Singleton instance
static var _instance = null

# Signals
signal scan_started(scan_id)
signal scan_completed(scan_id, scan_data)
signal scan_failed(scan_id, error)
signal connection_status_changed(is_connected)
signal object_recognized(object_data)

# Connection
var websocket: WebSocketPeer
var is_connected: bool = false
var connection_info: Dictionary = {}
var last_active_time: int = 0
var reconnect_attempts: int = 0
var max_reconnect_attempts: int = 5

# Scan data
var current_scan_id: String = ""
var pending_scans: Dictionary = {}
var completed_scans: Dictionary = {}
var scan_mutex = Mutex.new()

# Processing settings
var point_cloud_simplification: float = 0.05  # 5cm minimum distance between points
var scan_max_size_mb: int = 50  # Maximum scan size in MB
var auto_recognize_objects: bool = true
var real_world_scale: float = 1.0  # Conversion factor from real-world meters to game units

# Configuration
var server_address: String = "0.0.0.0"  # Listen on all interfaces
var server_port: int = 45680
var use_compression: bool = true
var scan_timeout: float = 30.0  # Seconds

# Scan types
enum ScanType {
    ROOM_SCAN,      # Full room scan
    OBJECT_SCAN,    # Single object detailed scan
    QUICK_SCAN,     # Fast low-resolution scan
    TRACKING_SCAN   # Continuous tracking scan
}

# Internal state
var server: TCPServer
var clients: Array = []
var scan_chunks: Dictionary = {}
var received_bytes: Dictionary = {}
var expected_bytes: Dictionary = {}

# Get singleton instance
static func get_instance():
    if not _instance:
        _instance = iPhoneLiDARBridge.new()
    return _instance

func _init():
    # Register this node as singleton
    if not Engine.has_singleton("iPhoneLiDARBridge"):
        Engine.register_singleton("iPhoneLiDARBridge", self)

func _ready():
    # Initialize server
    server = TCPServer.new()
    var err = server.listen(server_port, server_address)
    if err != OK:
        push_error("Failed to start iPhone LiDAR bridge server: " + str(err))
    else:
        print("iPhone LiDAR bridge server started on port " + str(server_port))

# Main process function
func _process(delta):
    # Check for new connections
    if server.is_connection_available():
        var new_client = server.take_connection()
        _handle_new_connection(new_client)
    
    # Process existing connections
    for client_idx in range(clients.size() - 1, -1, -1):
        var client = clients[client_idx]
        
        # Check client status
        if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
            # Process data from this client
            _process_client_data(client)
        else:
            # Remove disconnected client
            print("Client disconnected")
            clients.remove_at(client_idx)
    
    # Check for scan timeouts
    _check_scan_timeouts()

# Handle new client connection
func _handle_new_connection(client: StreamPeerTCP):
    print("New iPhone connection")
    clients.append(client)
    
    # Send welcome message
    var welcome_msg = {
        "type": "welcome",
        "version": "1.0",
        "compression": use_compression,
        "max_scan_size_mb": scan_max_size_mb
    }
    _send_message(client, welcome_msg)
    
    # Update connection state
    is_connected = true
    last_active_time = Time.get_ticks_msec()
    emit_signal("connection_status_changed", true)

# Process data from a client
func _process_client_data(client: StreamPeerTCP):
    # Check if data is available
    if client.get_available_bytes() > 0:
        # Try to read header first (4-byte size indicator)
        if client.get_available_bytes() >= 4:
            # Read message size
            var msg_size = client.get_u32()
            
            # If we have the full message
            if client.get_available_bytes() >= msg_size:
                # Read the message data
                var data = client.get_data(msg_size)
                if data[0] == OK:
                    var message_json = data[1].get_string_from_utf8()
                    var message = JSON.parse_string(message_json)
                    if message:
                        _handle_message(client, message)
                    else:
                        push_error("Failed to parse message as JSON")
                else:
                    push_error("Failed to read client data")

# Handle a message from iPhone
func _handle_message(client: StreamPeerTCP, message: Dictionary):
    # Update last active time
    last_active_time = Time.get_ticks_msec()
    
    # Process based on message type
    if message.has("type"):
        match message.type:
            "scan_start":
                _handle_scan_start(client, message)
                
            "scan_data":
                _handle_scan_data(client, message)
                
            "scan_complete":
                _handle_scan_complete(client, message)
                
            "scan_error":
                _handle_scan_error(client, message)
                
            "object_recognition":
                _handle_object_recognition(client, message)
                
            "device_info":
                _handle_device_info(client, message)
                
            "ping":
                _handle_ping(client, message)
                
            _:
                push_warning("Unknown message type: " + message.type)

# Handle scan start message
func _handle_scan_start(client: StreamPeerTCP, message: Dictionary):
    if message.has("scan_id") and message.has("scan_type") and message.has("expected_size"):
        var scan_id = message.scan_id
        var scan_type = message.scan_type
        var expected_size = message.expected_size
        
        print("Starting new scan: ", scan_id, " of type ", scan_type)
        
        # Initialize scan tracking
        scan_mutex.lock()
        pending_scans[scan_id] = {
            "start_time": Time.get_ticks_msec(),
            "scan_type": scan_type,
            "expected_size": expected_size,
            "received_bytes": 0,
            "chunks": {},
            "status": "starting",
            "client": client
        }
        scan_mutex.unlock()
        
        # Signal scan started
        emit_signal("scan_started", scan_id)
        
        # Acknowledge scan start
        _send_message(client, {
            "type": "scan_start_ack",
            "scan_id": scan_id,
            "status": "ready"
        })

# Handle scan data chunk
func _handle_scan_data(client: StreamPeerTCP, message: Dictionary):
    if message.has("scan_id") and message.has("chunk_id") and message.has("data"):
        var scan_id = message.scan_id
        var chunk_id = message.chunk_id
        var chunk_data = message.data
        var total_chunks = message.total_chunks if message.has("total_chunks") else 1
        
        scan_mutex.lock()
        if pending_scans.has(scan_id):
            # Update scan tracking
            if not pending_scans[scan_id].has("chunks"):
                pending_scans[scan_id].chunks = {}
            
            # Store this chunk
            pending_scans[scan_id].chunks[chunk_id] = chunk_data
            pending_scans[scan_id].received_bytes += chunk_data.length()
            
            # Calculate percentage and print progress
            var percentage = (float(pending_scans[scan_id].chunks.size()) / total_chunks) * 100
            print("Scan ", scan_id, " progress: ", percentage, "% (", pending_scans[scan_id].chunks.size(), "/", total_chunks, " chunks)")
            
            # Check if scan is complete
            if pending_scans[scan_id].chunks.size() == total_chunks:
                # Mark status as processing
                pending_scans[scan_id].status = "processing"
                
                # Schedule processing
                call_deferred("_process_complete_scan", scan_id)
            }
        else:
            push_warning("Received chunk for unknown scan: " + scan_id)
        scan_mutex.unlock()
        
        # Acknowledge chunk
        _send_message(client, {
            "type": "chunk_ack",
            "scan_id": scan_id,
            "chunk_id": chunk_id
        })

# Handle scan complete message
func _handle_scan_complete(client: StreamPeerTCP, message: Dictionary):
    if message.has("scan_id"):
        var scan_id = message.scan_id
        
        scan_mutex.lock()
        if pending_scans.has(scan_id):
            # Mark scan as completed from iPhone side
            pending_scans[scan_id].status = "complete_from_device"
            
            # Check if we have all expected data
            if pending_scans[scan_id].received_bytes >= pending_scans[scan_id].expected_size:
                # Process the complete scan if not already processing
                if pending_scans[scan_id].status != "processing":
                    call_deferred("_process_complete_scan", scan_id)
            }
        scan_mutex.unlock()
        
        # Acknowledge completion
        _send_message(client, {
            "type": "scan_complete_ack",
            "scan_id": scan_id
        })

# Handle scan error message
func _handle_scan_error(client: StreamPeerTCP, message: Dictionary):
    if message.has("scan_id") and message.has("error"):
        var scan_id = message.scan_id
        var error = message.error
        
        print("Scan error: ", scan_id, " - ", error)
        
        scan_mutex.lock()
        if pending_scans.has(scan_id):
            # Mark scan as failed
            pending_scans[scan_id].status = "failed"
            pending_scans[scan_id].error = error
            
            # Move to completed scans for reference
            completed_scans[scan_id] = pending_scans[scan_id]
            pending_scans.erase(scan_id)
        }
        scan_mutex.unlock()
        
        # Signal scan failed
        emit_signal("scan_failed", scan_id, error)

# Handle object recognition message
func _handle_object_recognition(client: StreamPeerTCP, message: Dictionary):
    if message.has("objects"):
        var objects = message.objects
        
        for obj in objects:
            if obj.has("type") and obj.has("confidence") and obj.has("position"):
                print("Object recognized: ", obj.type, " (confidence: ", obj.confidence, ")")
                
                # Emit signal for each recognized object
                emit_signal("object_recognized", obj)

# Handle device info message
func _handle_device_info(client: StreamPeerTCP, message: Dictionary):
    if message.has("device_info"):
        var device_info = message.device_info
        
        print("iPhone device info: ", device_info)
        
        # Store connection info
        connection_info = device_info
        connection_info.last_update = Time.get_ticks_msec()

# Handle ping message
func _handle_ping(client: StreamPeerTCP, message: Dictionary):
    # Respond with pong
    _send_message(client, {
        "type": "pong",
        "time": Time.get_ticks_msec()
    })

# Process a completed scan
func _process_complete_scan(scan_id: String):
    scan_mutex.lock()
    if pending_scans.has(scan_id):
        var scan_data = pending_scans[scan_id]
        
        print("Processing complete scan: ", scan_id)
        
        # Combine chunks into complete data
        var combined_data = _combine_scan_chunks(scan_data.chunks)
        
        # Process scan data (convert to mesh, etc)
        var processed_scan = _process_scan_data(scan_id, combined_data, scan_data.scan_type)
        
        # Move to completed scans
        scan_data.status = "completed"
        scan_data.processed_data = processed_scan
        completed_scans[scan_id] = scan_data
        pending_scans.erase(scan_id)
        
        scan_mutex.unlock()
        
        # Notify completion
        emit_signal("scan_completed", scan_id, processed_scan)
    } else {
        scan_mutex.unlock()
    }

# Combine scan chunks into complete data
func _combine_scan_chunks(chunks: Dictionary):
    # Sort chunks by ID
    var sorted_keys = chunks.keys()
    sorted_keys.sort()
    
    var combined = PackedByteArray()
    
    # Append chunks in order
    for key in sorted_keys:
        combined.append_array(chunks[key])
    
    return combined

# Process raw scan data into usable form
func _process_scan_data(scan_id: String, raw_data: PackedByteArray, scan_type):
    # For now, we'll return a placeholder processing result
    # In a real implementation, this would convert the point cloud data to a mesh
    return {
        "scan_id": scan_id,
        "type": scan_type,
        "point_count": raw_data.size() / 12,  # Assuming 12 bytes per point (x,y,z as float32)
        "mesh": null  # Would be a real mesh in the actual implementation
    }

# Check for scan timeouts
func _check_scan_timeouts():
    var current_time = Time.get_ticks_msec()
    
    scan_mutex.lock()
    var scan_ids = pending_scans.keys()
    for scan_id in scan_ids:
        var scan = pending_scans[scan_id]
        
        # Check if scan has timed out
        if current_time - scan.start_time > scan_timeout * 1000:  # Convert to ms
            print("Scan timeout: ", scan_id)
            
            # Mark as failed
            scan.status = "failed"
            scan.error = "timeout"
            
            # Move to completed scans
            completed_scans[scan_id] = scan
            pending_scans.erase(scan_id)
            
            # Signal failure
            call_deferred("emit_signal", "scan_failed", scan_id, "timeout")
        }
    }
    scan_mutex.unlock()

# Send a message to a client
func _send_message(client: StreamPeerTCP, message: Dictionary):
    # Convert message to JSON
    var json_string = JSON.stringify(message)
    var data = json_string.to_utf8_buffer()
    
    # Send size first, then data
    client.put_u32(data.size())
    client.put_data(data)

# Request a new scan from iPhone
func request_scan(scan_type: ScanType = ScanType.ROOM_SCAN) -> String:
    # Generate unique scan ID
    var scan_id = str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)
    
    # Check if we have any connected clients
    if clients.is_empty():
        push_error("Cannot request scan: No iPhone connected")
        return ""
    
    # Send scan request to first client
    var client = clients[0]
    
    _send_message(client, {
        "type": "request_scan",
        "scan_id": scan_id,
        "scan_type": scan_type,
        "settings": {
            "resolution": point_cloud_simplification,
            "recognize_objects": auto_recognize_objects,
            "max_size_mb": scan_max_size_mb
        }
    })
    
    # Initialize scan tracking
    scan_mutex.lock()
    pending_scans[scan_id] = {
        "start_time": Time.get_ticks_msec(),
        "scan_type": scan_type,
        "expected_size": 0,  # Will be updated when scan starts
        "received_bytes": 0,
        "chunks": {},
        "status": "requested",
        "client": client
    }
    scan_mutex.unlock()
    
    print("Requested new scan: ", scan_id)
    return scan_id

# Get scan status
func get_scan_status(scan_id: String) -> Dictionary:
    scan_mutex.lock()
    
    if pending_scans.has(scan_id):
        var status = pending_scans[scan_id].duplicate()
        scan_mutex.unlock()
        return status
    elif completed_scans.has(scan_id):
        var status = completed_scans[scan_id].duplicate()
        scan_mutex.unlock()
        return status
    
    scan_mutex.unlock()
    return {"status": "not_found"}

# Cancel an ongoing scan
func cancel_scan(scan_id: String) -> bool:
    scan_mutex.lock()
    
    if pending_scans.has(scan_id):
        var client = pending_scans[scan_id].client
        
        # Send cancel request
        _send_message(client, {
            "type": "cancel_scan",
            "scan_id": scan_id
        })
        
        # Mark as cancelled
        pending_scans[scan_id].status = "cancelled"
        
        # Move to completed scans
        completed_scans[scan_id] = pending_scans[scan_id]
        pending_scans.erase(scan_id)
        
        scan_mutex.unlock()
        return true
    }
    
    scan_mutex.unlock()
    return false

# Get all completed scans
func get_completed_scans() -> Array:
    scan_mutex.lock()
    var scan_ids = completed_scans.keys()
    scan_mutex.unlock()
    return scan_ids

# Get information about current connection
func get_connection_info() -> Dictionary:
    return {
        "is_connected": is_connected,
        "device_info": connection_info,
        "last_active": last_active_time,
        "pending_scans": pending_scans.size(),
        "completed_scans": completed_scans.size(),
        "server_address": server_address,
        "server_port": server_port
    }

# Force disconnect current client
func disconnect_client() -> bool:
    if clients.is_empty():
        return false
    
    # Close all client connections
    for client in clients:
        # Send disconnect message
        _send_message(client, {
            "type": "disconnect",
            "reason": "user_request"
        })
    
    # Reset clients array
    clients = []
    
    # Update state
    is_connected = false
    emit_signal("connection_status_changed", false)
    
    return true