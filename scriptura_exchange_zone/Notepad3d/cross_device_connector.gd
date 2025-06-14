extends Node

class_name CrossDeviceConnector

signal device_connected(device_id, device_type)
signal device_disconnected(device_id)
signal data_received(device_id, data_type, content)
signal cross_sync_status(status, message)

# Device types and their capabilities
const DEVICE_TYPES = {
    "desktop": {
        "max_tunnels": 12,
        "energy_modifier": 1.0,
        "dimension_access": [1, 2, 3, 4, 5, 6, 7, 8, 9],
        "transfer_rate": 1.0
    },
    "browser": {
        "max_tunnels": 9,
        "energy_modifier": 0.8,
        "dimension_access": [1, 2, 3, 4, 5, 6],
        "transfer_rate": 0.9
    },
    "phone": {
        "max_tunnels": 6,
        "energy_modifier": 0.6,
        "dimension_access": [1, 2, 3, 4],
        "transfer_rate": 0.7
    },
    "tablet": {
        "max_tunnels": 8,
        "energy_modifier": 0.7,
        "dimension_access": [1, 2, 3, 4, 5],
        "transfer_rate": 0.8
    },
    "claude": {
        "max_tunnels": 15,
        "energy_modifier": 1.2,
        "dimension_access": [1, 2, 3, 4, 5, 6, 7, 8, 9],
        "transfer_rate": 1.2
    }
}

# Connection settings
const SYNC_INTERVAL = 60  # Seconds between sync attempts
const CONNECTION_TIMEOUT = 10  # Seconds before timing out
const MAX_RECONNECT_ATTEMPTS = 3
const HEARTBEAT_INTERVAL = 30  # Seconds between heartbeat signals

# References to tunnel system
var tunnel_controller
var ethereal_tunnel_manager
var tunnel_visualizer

# Connected devices
var connected_devices = {}
var device_tunnels = {}
var device_anchors = {}

# Sync status
var last_sync_time = 0
var sync_in_progress = false
var reconnect_attempts = {}

# WebSocket server/client for real-time communication
var websocket_server
var websocket_clients = {}

# Bridge to Claude API for special functions
var claude_bridge

# Storage for device-specific data
var device_data_pool = {}

# Cross-device identification
var system_id = ""
var device_token = ""

# Configuration
var config = {
    "enable_real_time_sync": true,
    "enable_websocket": true,
    "websocket_port": 9080,
    "backup_sync_interval": 300,  # 5 minutes
    "token_exchange_enabled": true,
    "word_pattern_sync": true,
    "enable_cross_device_anchors": true,
    "enable_numeric_scaling": true,
    "cloud_sync_enabled": true,
    "tunnel_security_level": 2,  # 0-3, higher is more secure
    "browser_extensions_enabled": true
}

func _ready():
    # Generate unique system ID if not already set
    if system_id.empty():
        system_id = _generate_system_id()
    
    # Load configuration
    _load_config()
    
    # Auto-detect components
    _detect_components()
    
    # Initialize WebSocket if enabled
    if config.enable_websocket:
        _initialize_websocket()
    
    # Initialize Claude bridge if available
    _initialize_claude_bridge()

func _process(delta):
    # Check for periodic sync
    if config.enable_real_time_sync and not sync_in_progress:
        var current_time = Time.get_unix_time_from_system()
        if current_time - last_sync_time >= SYNC_INTERVAL:
            sync_all_devices()
    
    # Process WebSocket messages
    if websocket_server:
        websocket_server.poll()
    
    # Send heartbeat signals to connected devices
    _send_heartbeats()

func _detect_components():
    # Find tunnel controller
    if not tunnel_controller:
        var potential_controllers = get_tree().get_nodes_in_group("tunnel_controllers")
        if potential_controllers.size() > 0:
            tunnel_controller = potential_controllers[0]
            print("Found tunnel controller: " + tunnel_controller.name)
    
    # Get references from controller
    if tunnel_controller:
        ethereal_tunnel_manager = tunnel_controller.ethereal_tunnel_manager
        tunnel_visualizer = tunnel_controller.tunnel_visualizer

func connect_device(device_id, device_type, connection_data = {}):
    # Validate device type
    if not DEVICE_TYPES.has(device_type):
        emit_signal("cross_sync_status", "error", "Unknown device type: " + device_type)
        return false
    
    # Check if device is already connected
    if connected_devices.has(device_id):
        emit_signal("cross_sync_status", "warning", "Device already connected: " + device_id)
        return true
    
    # Create device data
    var device_info = {
        "id": device_id,
        "type": device_type,
        "capabilities": DEVICE_TYPES[device_type].duplicate(),
        "connected_at": Time.get_unix_time_from_system(),
        "last_sync": 0,
        "status": "connecting",
        "connection_data": connection_data
    }
    
    # Add additional connection data
    if connection_data.has("ip_address"):
        device_info.ip_address = connection_data.ip_address
    
    if connection_data.has("app_version"):
        device_info.app_version = connection_data.app_version
    
    # Create anchor for device in ethereal space
    if ethereal_tunnel_manager and config.enable_cross_device_anchors:
        var coordinates = _generate_device_coordinates(device_type, device_id)
        var anchor_id = "device_" + device_id
        
        var anchor = ethereal_tunnel_manager.register_anchor(anchor_id, coordinates, "device_" + device_type)
        
        if anchor:
            device_info.anchor_id = anchor_id
            device_anchors[device_id] = anchor_id
    
    # Register device
    connected_devices[device_id] = device_info
    device_tunnels[device_id] = []
    
    emit_signal("device_connected", device_id, device_type)
    emit_signal("cross_sync_status", "success", "Device connected: " + device_id + " (" + device_type + ")")
    
    // Establish initial sync
    sync_device(device_id)
    
    return true

func disconnect_device(device_id):
    if not connected_devices.has(device_id):
        emit_signal("cross_sync_status", "warning", "Device not connected: " + device_id)
        return false
    
    var device_info = connected_devices[device_id]
    
    // Clean up WebSocket connection if any
    if websocket_clients.has(device_id):
        var client = websocket_clients[device_id]
        client.close()
        websocket_clients.erase(device_id)
    
    // Remove tunnels associated with this device
    if device_tunnels.has(device_id):
        for tunnel_id in device_tunnels[device_id]:
            if ethereal_tunnel_manager and ethereal_tunnel_manager.has_tunnel(tunnel_id):
                ethereal_tunnel_manager.collapse_tunnel(tunnel_id)
    
    // Remove anchor if it exists
    if device_anchors.has(device_id):
        var anchor_id = device_anchors[device_id]
        if ethereal_tunnel_manager and ethereal_tunnel_manager.has_anchor(anchor_id):
            ethereal_tunnel_manager.remove_anchor(anchor_id)
        device_anchors.erase(device_id)
    
    // Clean up device records
    connected_devices.erase(device_id)
    device_tunnels.erase(device_id)
    reconnect_attempts.erase(device_id)
    
    emit_signal("device_disconnected", device_id)
    emit_signal("cross_sync_status", "info", "Device disconnected: " + device_id)
    
    return true

func sync_device(device_id):
    if not connected_devices.has(device_id):
        emit_signal("cross_sync_status", "error", "Cannot sync unknown device: " + device_id)
        return false
    
    var device_info = connected_devices[device_id]
    
    // Set sync in progress
    sync_in_progress = true
    device_info.status = "syncing"
    
    emit_signal("cross_sync_status", "info", "Syncing with device: " + device_id)
    
    // Actual sync logic depends on the connection method
    var success = false
    
    if websocket_clients.has(device_id):
        // Use WebSocket for real-time sync
        success = _sync_via_websocket(device_id)
    else:
        // Use alternate method (API calls, file sync, etc.)
        success = _sync_via_api(device_id)
    
    // Update sync status
    if success:
        device_info.last_sync = Time.get_unix_time_from_system()
        device_info.status = "connected"
        emit_signal("cross_sync_status", "success", "Sync completed with device: " + device_id)
    else:
        device_info.status = "sync_failed"
        emit_signal("cross_sync_status", "error", "Sync failed with device: " + device_id)
        
        // Attempt reconnect if applicable
        if not reconnect_attempts.has(device_id):
            reconnect_attempts[device_id] = 0
        
        reconnect_attempts[device_id] += 1
        
        if reconnect_attempts[device_id] <= MAX_RECONNECT_ATTEMPTS:
            emit_signal("cross_sync_status", "info", "Attempting reconnection (" + 
                        str(reconnect_attempts[device_id]) + "/" + str(MAX_RECONNECT_ATTEMPTS) + 
                        ") with device: " + device_id)
            
            // Schedule a reconnect attempt
            var timer = Timer.new()
            timer.wait_time = 5.0  // Wait 5 seconds before retry
            timer.one_shot = true
            timer.connect("timeout", self, "_reconnect_device", [device_id, timer])
            add_child(timer)
            timer.start()
        else:
            // Give up after max attempts
            emit_signal("cross_sync_status", "error", "Giving up reconnection with device: " + device_id)
            disconnect_device(device_id)
    
    sync_in_progress = false
    return success

func sync_all_devices():
    if sync_in_progress:
        return false
    
    emit_signal("cross_sync_status", "info", "Starting sync with all devices")
    
    sync_in_progress = true
    last_sync_time = Time.get_unix_time_from_system()
    
    var success_count = 0
    var failure_count = 0
    
    // Iterate through all connected devices
    for device_id in connected_devices.keys():
        var result = sync_device(device_id)
        
        if result:
            success_count += 1
        else:
            failure_count += 1
    
    sync_in_progress = false
    
    emit_signal("cross_sync_status", "info", "Sync completed. Success: " + str(success_count) + 
                ", Failures: " + str(failure_count))
    
    return success_count > 0 && failure_count == 0

func send_data_to_device(device_id, data_type, content):
    if not connected_devices.has(device_id):
        emit_signal("cross_sync_status", "error", "Cannot send data to unknown device: " + device_id)
        return false
    
    var device_info = connected_devices[device_id]
    
    // Check device capabilities
    if data_type == "word_pattern" && !device_info.capabilities.has("word_pattern_sync"):
        emit_signal("cross_sync_status", "warning", "Device does not support word pattern sync: " + device_id)
        return false
    
    if websocket_clients.has(device_id):
        // Send via WebSocket
        var message = {
            "type": "data",
            "data_type": data_type,
            "content": content,
            "timestamp": Time.get_unix_time_from_system(),
            "sender": system_id
        }
        
        var json_str = JSON.stringify(message)
        websocket_clients[device_id].send_text(json_str)
        
        emit_signal("cross_sync_status", "info", "Data sent to device: " + device_id)
        return true
    else:
        // Store in data pool for next sync
        if not device_data_pool.has(device_id):
            device_data_pool[device_id] = []
        
        device_data_pool[device_id].push_back({
            "type": data_type,
            "content": content,
            "timestamp": Time.get_unix_time_from_system()
        })
        
        emit_signal("cross_sync_status", "info", "Data queued for device: " + device_id)
        return true

func create_cross_device_tunnel(source_device_id, target_device_id, dimension = 3):
    if not connected_devices.has(source_device_id):
        emit_signal("cross_sync_status", "error", "Source device not connected: " + source_device_id)
        return null
    
    if not connected_devices.has(target_device_id):
        emit_signal("cross_sync_status", "error", "Target device not connected: " + target_device_id)
        return null
    
    if not ethereal_tunnel_manager:
        emit_signal("cross_sync_status", "error", "No tunnel manager available")
        return null
    
    // Get device anchors
    var source_anchor = device_anchors.get(source_device_id)
    var target_anchor = device_anchors.get(target_device_id)
    
    if not source_anchor:
        emit_signal("cross_sync_status", "error", "Source device has no anchor: " + source_device_id)
        return null
    
    if not target_anchor:
        emit_signal("cross_sync_status", "error", "Target device has no anchor: " + target_device_id)
        return null
    
    // Check dimension constraints
    var source_device = connected_devices[source_device_id]
    var target_device = connected_devices[target_device_id]
    
    if not source_device.capabilities.dimension_access.has(dimension):
        emit_signal("cross_sync_status", "error", "Source device cannot access dimension " + str(dimension))
        return null
    
    if not target_device.capabilities.dimension_access.has(dimension):
        emit_signal("cross_sync_status", "error", "Target device cannot access dimension " + str(dimension))
        return null
    
    // Create tunnel
    var tunnel
    
    if tunnel_controller:
        tunnel = tunnel_controller.establish_tunnel(source_anchor, target_anchor)
    else:
        tunnel = ethereal_tunnel_manager.establish_tunnel(source_anchor, target_anchor, dimension)
    
    if tunnel:
        // Register tunnel with devices
        device_tunnels[source_device_id].push_back(tunnel.id)
        device_tunnels[target_device_id].push_back(tunnel.id)
        
        emit_signal("cross_sync_status", "success", "Cross-device tunnel established: " + tunnel.id)
        
        // Inform both devices if they're connected via WebSocket
        var tunnel_info = {
            "type": "tunnel_established",
            "tunnel_id": tunnel.id,
            "source_device": source_device_id,
            "target_device": target_device_id,
            "dimension": dimension,
            "timestamp": Time.get_unix_time_from_system()
        }
        
        var json_str = JSON.stringify(tunnel_info)
        
        if websocket_clients.has(source_device_id):
            websocket_clients[source_device_id].send_text(json_str)
        
        if websocket_clients.has(target_device_id):
            websocket_clients[target_device_id].send_text(json_str)
    else:
        emit_signal("cross_sync_status", "error", "Failed to establish cross-device tunnel")
    
    return tunnel

func transfer_through_cross_device_tunnel(tunnel_id, content, source_device_id = ""):
    if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
        emit_signal("cross_sync_status", "error", "Tunnel not found: " + tunnel_id)
        return false
    
    // Validate source device if specified
    if not source_device_id.empty():
        if not connected_devices.has(source_device_id):
            emit_signal("cross_sync_status", "error", "Source device not connected: " + source_device_id)
            return false
        
        // Check if tunnel belongs to source device
        if not device_tunnels.has(source_device_id) or not device_tunnels[source_device_id].has(tunnel_id):
            emit_signal("cross_sync_status", "error", "Tunnel does not belong to source device")
            return false
    
    // Get tunnel data
    var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
    
    // Determine source and target devices from tunnel
    var source_anchor = tunnel_data.source
    var target_anchor = tunnel_data.target
    
    var source_device = ""
    var target_device = ""
    
    // Find devices associated with anchors
    for device_id in device_anchors:
        if device_anchors[device_id] == source_anchor:
            source_device = device_id
        elif device_anchors[device_id] == target_anchor:
            target_device = device_id
    
    if source_device.empty() or target_device.empty():
        emit_signal("cross_sync_status", "error", "Could not identify devices for tunnel: " + tunnel_id)
        return false
    
    // Scale content based on numeric token system if enabled
    var scaled_content = content
    if config.enable_numeric_scaling:
        scaled_content = _apply_numeric_scaling(content, source_device, target_device)
    
    // Transfer through tunnel
    var result = false
    
    if tunnel_controller:
        result = tunnel_controller.transfer_through_tunnel(tunnel_id, scaled_content)
    else:
        // Manually notify about transfer
        emit_signal("cross_sync_status", "info", "Transferring data through tunnel: " + tunnel_id)
        
        // Send to target device
        result = send_data_to_device(target_device, "tunnel_transfer", {
            "tunnel_id": tunnel_id,
            "content": scaled_content,
            "timestamp": Time.get_unix_time_from_system(),
            "source_device": source_device
        })
    
    return result

func _initialize_websocket():
    // Create WebSocket server
    websocket_server = WebSocketServer.new()
    
    // Set WebSocket options
    websocket_server.private_key = null // Set actual key path if needed
    websocket_server.ssl_certificate = null // Set actual cert path if needed
    
    // Connect signals
    websocket_server.connect("client_connected", self, "_on_client_connected")
    websocket_server.connect("client_disconnected", self, "_on_client_disconnected")
    websocket_server.connect("client_close_request", self, "_on_client_close_request")
    websocket_server.connect("data_received", self, "_on_data_received")
    
    // Start server
    var err = websocket_server.listen(config.websocket_port)
    if err != OK:
        print("Failed to start WebSocket server on port: ", config.websocket_port)
        return false
    
    print("WebSocket server started on port: ", config.websocket_port)
    return true

func _on_client_connected(id, protocol):
    print("Client connected with ID: ", id)
    
    // New clients start in a pending state until they identify
    websocket_clients[str(id)] = {
        "id": id,
        "status": "pending",
        "protocol": protocol,
        "connected_at": Time.get_unix_time_from_system()
    }

func _on_client_disconnected(id, was_clean_close):
    print("Client disconnected with ID: ", id)
    
    // Find device ID associated with this client
    var device_id_to_remove = null
    
    for device_id in websocket_clients:
        if str(websocket_clients[device_id].id) == str(id):
            device_id_to_remove = device_id
            break
    
    if device_id_to_remove:
        websocket_clients.erase(device_id_to_remove)
        
        // Don't disconnect the device immediately, it might reconnect
        if connected_devices.has(device_id_to_remove):
            connected_devices[device_id_to_remove].status = "connection_lost"
            
            // Schedule a check
            var timer = Timer.new()
            timer.wait_time = CONNECTION_TIMEOUT
            timer.one_shot = true
            timer.connect("timeout", self, "_check_device_reconnection", [device_id_to_remove, timer])
            add_child(timer)
            timer.start()

func _on_client_close_request(id, code, reason):
    print("Client close request with ID: ", id, ", code: ", code, ", reason: ", reason)

func _on_data_received(id):
    var packet = websocket_server.get_peer(id).get_packet()
    var data_string = packet.get_string_from_utf8()
    
    // Parse JSON data
    var json_result = JSON.parse_string(data_string)
    
    if not json_result:
        print("Invalid JSON received from client: ", id)
        return
    
    var message = json_result
    
    // Handle based on message type
    match message.type:
        "identify":
            _handle_identify_message(id, message)
        
        "data":
            _handle_data_message(id, message)
        
        "heartbeat":
            _handle_heartbeat_message(id, message)
        
        "tunnel_request":
            _handle_tunnel_request(id, message)
        
        "sync_request":
            _handle_sync_request(id, message)
        
        _:
            print("Unknown message type from client: ", id)

func _handle_identify_message(client_id, message):
    // Extract device info
    var device_id = message.device_id
    var device_type = message.device_type
    var device_token = message.token
    
    // Validate token if token exchange is enabled
    if config.token_exchange_enabled:
        if not _validate_device_token(device_id, device_token):
            print("Invalid device token from: ", device_id)
            websocket_server.get_peer(client_id).close()
            return
    
    // Connect the device
    var result = connect_device(device_id, device_type, {
        "ip_address": websocket_server.get_peer(client_id).get_connected_host(),
        "app_version": message.get("app_version", "unknown")
    })
    
    if result:
        // Associate websocket client with device
        websocket_clients[device_id] = websocket_server.get_peer(client_id)
        
        // Send acknowledgement
        var response = {
            "type": "identify_ack",
            "status": "success",
            "system_id": system_id,
            "timestamp": Time.get_unix_time_from_system()
        }
        
        websocket_server.get_peer(client_id).send_text(JSON.stringify(response))
    else:
        // Send failure
        var response = {
            "type": "identify_ack",
            "status": "failure",
            "reason": "Failed to connect device",
            "timestamp": Time.get_unix_time_from_system()
        }
        
        websocket_server.get_peer(client_id).send_text(JSON.stringify(response))

func _handle_data_message(client_id, message):
    // Find device ID associated with this client
    var sender_device_id = null
    
    for device_id in websocket_clients:
        if str(websocket_clients[device_id].id) == str(client_id):
            sender_device_id = device_id
            break
    
    if not sender_device_id:
        print("Received data from unidentified client: ", client_id)
        return
    
    // Process the data
    var data_type = message.data_type
    var content = message.content
    
    // Emit signal for this data
    emit_signal("data_received", sender_device_id, data_type, content)
    
    // Handle based on data type
    match data_type:
        "word_pattern":
            _handle_word_pattern_data(sender_device_id, content)
        
        "energy_transfer":
            _handle_energy_transfer(sender_device_id, content)
        
        "dimension_shift":
            _handle_dimension_shift(sender_device_id, content)
        
        "anchor_data":
            _handle_anchor_data(sender_device_id, content)
        
        "token_data":
            _handle_token_data(sender_device_id, content)

func _initialize_claude_bridge():
    // Check if Claude bridge functionality is available
    if OS.has_feature("claude_api"):
        claude_bridge = preload("res://claude_api_bridge.gd").new()
        add_child(claude_bridge)
        
        // Connect signals
        claude_bridge.connect("api_connected", self, "_on_claude_api_connected")
        claude_bridge.connect("api_error", self, "_on_claude_api_error")
        
        // Initialize connection
        claude_bridge.initialize()
        
        return true
    
    return false

func _on_claude_api_connected():
    print("Claude API connected")
    
    // Register Claude as a connected device
    var claude_id = "claude_api_" + str(randi() % 1000)
    
    connect_device(claude_id, "claude", {
        "api_version": claude_bridge.get_api_version(),
        "model": claude_bridge.get_model_info()
    })

func _on_claude_api_error(error_code, message):
    print("Claude API error: ", error_code, " - ", message)
    
    // Handle reconnection or report to user
    emit_signal("cross_sync_status", "error", "Claude API error: " + message)

func _generate_system_id():
    // Create a unique system ID based on hardware and time
    var os_name = OS.get_name()
    var time_stamp = Time.get_unix_time_from_system()
    var random_salt = randi() % 100000
    
    var raw_id = os_name + "_" + str(time_stamp) + "_" + str(random_salt)
    
    // Use a hash function to create a consistent ID
    return str(hash(raw_id)).md5_text().substr(0, 16)

func _generate_device_coordinates(device_type, device_id):
    // Generate 3D coordinates based on device type and ID
    // This determines where in the ethereal space the device appears
    
    var coordinates = Vector3.ZERO
    
    // Base position on device type
    match device_type:
        "desktop":
            coordinates = Vector3(5, 0, 0)
        "browser":
            coordinates = Vector3(0, 5, 0)
        "phone":
            coordinates = Vector3(0, 0, 5)
        "tablet":
            coordinates = Vector3(3, 3, 0)
        "claude":
            coordinates = Vector3(0, 0, 0)
    
    // Add variation based on device ID
    var id_hash = device_id.hash()
    
    coordinates.x += (id_hash % 100) / 10.0 - 5.0
    coordinates.y += ((id_hash / 100) % 100) / 10.0 - 5.0
    coordinates.z += ((id_hash / 10000) % 100) / 10.0 - 5.0
    
    return coordinates

func _sync_via_websocket(device_id):
    if not websocket_clients.has(device_id):
        return false
    
    // Send sync request
    var sync_message = {
        "type": "sync",
        "timestamp": Time.get_unix_time_from_system(),
        "system_id": system_id
    }
    
    // Add anchor data if available
    if device_anchors.has(device_id):
        var anchor_id = device_anchors[device_id]
        if ethereal_tunnel_manager.has_anchor(anchor_id):
            var anchor_data = ethereal_tunnel_manager.get_anchor_data(anchor_id)
            sync_message["anchor_data"] = anchor_data
    
    // Add tunnel data if available
    if device_tunnels.has(device_id):
        var tunnels_data = []
        
        for tunnel_id in device_tunnels[device_id]:
            if ethereal_tunnel_manager.has_tunnel(tunnel_id):
                var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
                tunnels_data.push_back(tunnel_data)
        
        sync_message["tunnels_data"] = tunnels_data
    
    // Add any pending data from the pool
    if device_data_pool.has(device_id) and device_data_pool[device_id].size() > 0:
        sync_message["pending_data"] = device_data_pool[device_id]
        device_data_pool[device_id].clear()
    
    // Send the message
    websocket_clients[device_id].send_text(JSON.stringify(sync_message))
    
    // For WebSocket we consider this successful as long as we could send
    return true

func _sync_via_api(device_id):
    // Implementation of sync via API calls
    // This is a placeholder and would need to be implemented based on your specific API
    
    emit_signal("cross_sync_status", "warning", "API sync not fully implemented for device: " + device_id)
    
    // This would involve making HTTP requests or using a different protocol
    // For now we'll simulate success
    return true

func _reconnect_device(device_id, timer):
    // Cleanup timer
    timer.queue_free()
    
    if not connected_devices.has(device_id):
        return
    
    // Attempt to sync again
    sync_device(device_id)

func _check_device_reconnection(device_id, timer):
    // Cleanup timer
    timer.queue_free()
    
    if not connected_devices.has(device_id):
        return
    
    // Check if the device has reconnected
    if connected_devices[device_id].status == "connection_lost":
        // Device didn't reconnect within timeout
        disconnect_device(device_id)

func _send_heartbeats():
    // Only send heartbeats on a fixed interval
    if Engine.get_idle_frames() % (HEARTBEAT_INTERVAL * Engine.get_frames_per_second()) != 0:
        return
    
    // Send heartbeat to all connected WebSocket clients
    var heartbeat_message = {
        "type": "heartbeat",
        "timestamp": Time.get_unix_time_from_system(),
        "system_id": system_id
    }
    
    var json_str = JSON.stringify(heartbeat_message)
    
    for device_id in websocket_clients:
        if connected_devices.has(device_id) and connected_devices[device_id].status == "connected":
            websocket_clients[device_id].send_text(json_str)

func _handle_heartbeat_message(client_id, message):
    // Update last activity timestamp for the device
    var device_id = message.get("device_id", "")
    
    if device_id and connected_devices.has(device_id):
        connected_devices[device_id].last_activity = Time.get_unix_time_from_system()

func _handle_tunnel_request(client_id, message):
    var device_id = ""
    
    // Find device ID associated with this client
    for id in websocket_clients:
        if str(websocket_clients[id].id) == str(client_id):
            device_id = id
            break
    
    if device_id.empty():
        print("Tunnel request from unidentified client: ", client_id)
        return
    
    // Extract request data
    var target_device = message.target_device
    var dimension = message.get("dimension", 3)
    
    // Create the tunnel
    var tunnel = create_cross_device_tunnel(device_id, target_device, dimension)
    
    // Send response
    var response = {
        "type": "tunnel_response",
        "status": tunnel ? "success" : "failure",
        "tunnel_id": tunnel ? tunnel.id : "",
        "timestamp": Time.get_unix_time_from_system()
    }
    
    websocket_server.get_peer(client_id).send_text(JSON.stringify(response))

func _handle_sync_request(client_id, message):
    var device_id = ""
    
    // Find device ID associated with this client
    for id in websocket_clients:
        if str(websocket_clients[id].id) == str(client_id):
            device_id = id
            break
    
    if device_id.empty():
        print("Sync request from unidentified client: ", client_id)
        return
    
    // Process sync
    sync_device(device_id)

func _handle_word_pattern_data(device_id, content):
    if not config.word_pattern_sync:
        return
    
    // Process word pattern data
    // This would be implemented based on your specific word pattern system
    
    // Example: pass to tunnel visualizer for visualization
    if tunnel_visualizer and tunnel_visualizer.has_method("visualize_word_pattern"):
        tunnel_visualizer.visualize_word_pattern(content.pattern, content.energy)

func _handle_energy_transfer(device_id, content):
    if not tunnel_controller:
        return
    
    // Apply energy transfer
    var amount = content.amount
    var source = content.source
    
    // Scale based on device capabilities
    var device_info = connected_devices[device_id]
    amount *= device_info.capabilities.energy_modifier
    
    // Apply to tunnel controller
    var current = tunnel_controller.available_energy
    var max_energy = tunnel_controller.max_energy
    
    tunnel_controller.available_energy = clamp(current + amount, 0, max_energy)

func _handle_dimension_shift(device_id, content):
    if not tunnel_controller:
        return
    
    // Process dimension shift request
    var target_dimension = content.dimension
    
    // Check device capabilities
    var device_info = connected_devices[device_id]
    
    if not device_info.capabilities.dimension_access.has(target_dimension):
        emit_signal("cross_sync_status", "warning", "Device cannot access dimension " + str(target_dimension))
        return
    
    // Attempt shift
    tunnel_controller.shift_dimension(target_dimension)

func _handle_anchor_data(device_id, content):
    if not ethereal_tunnel_manager:
        return
    
    // Update anchor data
    if device_anchors.has(device_id):
        var anchor_id = device_anchors[device_id]
        
        // Update coordinates if needed
        if content.has("coordinates"):
            var coords = Vector3(
                content.coordinates.x,
                content.coordinates.y,
                content.coordinates.z
            )
            
            ethereal_tunnel_manager.update_anchor_coordinates(anchor_id, coords)
        
        // Update other properties if needed
        if content.has("properties"):
            ethereal_tunnel_manager.update_anchor_properties(anchor_id, content.properties)

func _handle_token_data(device_id, content):
    if not config.enable_numeric_scaling:
        return
    
    // Store token data for numeric scaling
    if not connected_devices.has(device_id):
        return
    
    connected_devices[device_id].token_data = content

func _apply_numeric_scaling(content, source_device, target_device):
    // Apply numeric token system for energy scaling
    // This scales content based on various numeric patterns
    
    // Simple implementation: count numbers in content and use as scaling factors
    var number_pattern = RegEx.new()
    number_pattern.compile("\\d+")
    
    var matches = number_pattern.search_all(content)
    var number_count = matches.size()
    
    var source_cap = connected_devices[source_device].capabilities
    var target_cap = connected_devices[target_device].capabilities
    
    // Extract multiplier based on number patterns
    var multiplier = 1.0
    
    if number_count > 0:
        // Use numbers as energy anchors
        var total = 0
        var count = 0
        
        for match_obj in matches:
            var num = int(match_obj.get_string())
            if num > 0:
                total += num
                count += 1
        
        if count > 0:
            var avg = float(total) / count
            
            // Scale multiplier based on average value
            // Higher average numbers provide more energy
            multiplier = 1.0 + (avg / 100.0)
        
        // Apply device-specific scaling
        multiplier *= source_cap.energy_modifier
        multiplier /= target_cap.energy_modifier
    }
    
    // Apply multiplier to content if it's relevant
    // In this case we're not actually changing the content, just using
    // the numeric patterns to influence tunnel energy/stability
    
    // Store multiplier for later use
    if tunnel_controller:
        tunnel_controller.set_transfer_multiplier(multiplier)
    
    return content

func _validate_device_token(device_id, token):
    // Simple token validation
    // In a real implementation, this would use proper cryptographic methods
    
    // For now, accept any token
    return true

func _load_config():
    // Load configuration from file
    if not FileAccess.file_exists("user://cross_device_config.json"):
        return
    
    var file = FileAccess.open("user://cross_device_config.json", FileAccess.READ)
    if not file:
        return
    
    var json = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse_string(json)
    if parse_result:
        // Update config with loaded values
        for key in parse_result:
            if config.has(key):
                config[key] = parse_result[key]

func save_config():
    // Save configuration to file
    var file = FileAccess.open("user://cross_device_config.json", FileAccess.WRITE)
    if not file:
        return false
    
    var json = JSON.stringify(config)
    file.store_string(json)
    file.close()
    
    return true

func get_device_status(device_id):
    if not connected_devices.has(device_id):
        return null
    
    var device = connected_devices[device_id]
    
    return {
        "id": device.id,
        "type": device.type,
        "status": device.status,
        "capabilities": device.capabilities,
        "connected_at": device.connected_at,
        "last_sync": device.last_sync,
        "anchor_id": device_anchors.get(device_id, ""),
        "tunnel_count": device_tunnels.has(device_id) ? device_tunnels[device_id].size() : 0
    }

func get_all_connected_devices():
    var devices = []
    
    for device_id in connected_devices:
        devices.push_back(get_device_status(device_id))
    
    return devices

func get_device_tunnels(device_id):
    if not device_tunnels.has(device_id):
        return []
    
    var tunnels = []
    
    for tunnel_id in device_tunnels[device_id]:
        if ethereal_tunnel_manager and ethereal_tunnel_manager.has_tunnel(tunnel_id):
            var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
            tunnels.push_back(tunnel_data)
    
    return tunnels

func set_config_value(key, value):
    if config.has(key):
        config[key] = value
        save_config()
        return true
    
    return false