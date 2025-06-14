extends Node
class_name SecureMemoryChannel

"""
Secure Memory Channel
-------------------
Manages secure memory transmission between devices
Implements encryption and validation for memory data
Preserves structure while ensuring future compatibility
"""

# Security Constants
const SECURITY_LEVELS = {
    "LOW": 0,      # Basic validation
    "MEDIUM": 1,   # Checksum verification
    "HIGH": 2,     # Encryption with shared key
    "MAXIMUM": 3   # Full encryption with unique keys
}

const HASH_TYPES = {
    "MD5": 0,
    "SHA1": 1,
    "SHA256": 2
}

# Channel Markers
const MEMORY_MARKERS = {
    "PAST": "#<",     # Past memory marker
    "PRESENT": "#|",  # Present/center memory marker
    "FUTURE": "#>",   # Future memory marker
    "LOCKED": "#X",   # Locked memory marker
    "PARTIAL": "#~",  # Partially available marker
    "VERIFIED": "#✓", # Verified memory marker
    "ERROR": "#!"     # Error or corrupted memory marker
}

# System components
var _memory_system = null
var _trajectory_system = null
var _connection_system = null
var _current_security_level = SECURITY_LEVELS.MEDIUM
var _encryption_key = ""
var _device_id = ""
var _trusted_devices = []
var _pending_transfers = []
var _completed_transfers = []
var _current_hash_type = HASH_TYPES.SHA256

# Transfer states
enum TransferState {
    PENDING,
    IN_PROGRESS,
    COMPLETED,
    FAILED,
    CANCELED
}

# Data structures
class MemoryTransfer:
    var id: String
    var source_device: String
    var target_device: String
    var memory_ids = []
    var encryption_level: int
    var hash_type: int
    var state: int
    var error_message: String = ""
    var timestamp: int
    var metadata = {}
    var verification_hash: String = ""
    
    func _init(p_id: String, p_source: String, p_target: String):
        id = p_id
        source_device = p_source
        target_device = p_target
        timestamp = OS.get_unix_time()
        state = TransferState.PENDING
    
    func add_memory(memory_id: String):
        if not memory_ids.has(memory_id):
            memory_ids.append(memory_id)
    
    func set_encryption_level(level: int):
        encryption_level = level
    
    func set_hash_type(type: int):
        hash_type = type
    
    func complete():
        state = TransferState.COMPLETED
    
    func fail(message: String):
        state = TransferState.FAILED
        error_message = message
    
    func cancel():
        state = TransferState.CANCELED
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "source_device": source_device,
            "target_device": target_device,
            "memory_ids": memory_ids,
            "encryption_level": encryption_level,
            "hash_type": hash_type,
            "state": state,
            "error_message": error_message,
            "timestamp": timestamp,
            "metadata": metadata,
            "verification_hash": verification_hash
        }
    
    static func from_dict(data: Dictionary) -> MemoryTransfer:
        var transfer = MemoryTransfer.new(
            data.id,
            data.source_device,
            data.target_device
        )
        
        transfer.memory_ids = data.memory_ids.duplicate()
        transfer.encryption_level = data.encryption_level
        transfer.hash_type = data.hash_type
        transfer.state = data.state
        transfer.error_message = data.error_message
        transfer.timestamp = data.timestamp
        transfer.metadata = data.metadata.duplicate()
        transfer.verification_hash = data.verification_hash
        
        return transfer

class DeviceProfile:
    var id: String
    var name: String
    var public_key: String = ""
    var trust_level: int
    var last_sync: int = -1
    var metadata = {}
    
    func _init(p_id: String, p_name: String, p_trust_level: int):
        id = p_id
        name = p_name
        trust_level = p_trust_level
    
    func update_last_sync():
        last_sync = OS.get_unix_time()
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
            "public_key": public_key,
            "trust_level": trust_level,
            "last_sync": last_sync,
            "metadata": metadata
        }
    
    static func from_dict(data: Dictionary) -> DeviceProfile:
        var device = DeviceProfile.new(
            data.id,
            data.name,
            data.trust_level
        )
        
        device.public_key = data.public_key
        device.last_sync = data.last_sync
        device.metadata = data.metadata.duplicate()
        
        return device

# Signals
signal transfer_created(transfer_id)
signal transfer_completed(transfer_id)
signal transfer_failed(transfer_id, error)
signal device_added(device_id)
signal security_level_changed(new_level)

# System Initialization
func _ready():
    # Generate device ID if not already set
    if _device_id.empty():
        _device_id = _generate_device_id()
    
    # Load trusted devices
    load_trusted_devices()
    
    # Load transfers
    load_transfers()

func initialize(memory_system = null, trajectory_system = null, connection_system = null):
    _memory_system = memory_system
    _trajectory_system = trajectory_system
    _connection_system = connection_system
    
    return true

# Security Management
func set_security_level(level: int) -> bool:
    if level < SECURITY_LEVELS.LOW or level > SECURITY_LEVELS.MAXIMUM:
        return false
    
    _current_security_level = level
    emit_signal("security_level_changed", level)
    
    return true

func set_encryption_key(key: String) -> bool:
    if key.empty():
        return false
    
    _encryption_key = key
    return true

func generate_encryption_key() -> String:
    # Generate a random encryption key
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    
    var key = ""
    for i in range(32):
        key += char(rng.randi_range(33, 126))
    
    _encryption_key = key
    return key

# Device Management
func add_trusted_device(name: String, public_key: String = "", trust_level: int = 1) -> String:
    var device_id = "device_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    
    var device = DeviceProfile.new(device_id, name, trust_level)
    if not public_key.empty():
        device.public_key = public_key
    
    _trusted_devices.append(device)
    
    # Save device list
    save_trusted_devices()
    
    emit_signal("device_added", device_id)
    
    return device_id

func remove_trusted_device(device_id: String) -> bool:
    for i in range(_trusted_devices.size()):
        if _trusted_devices[i].id == device_id:
            _trusted_devices.remove(i)
            
            # Save device list
            save_trusted_devices()
            
            return true
    
    return false

func get_trusted_device(device_id: String) -> DeviceProfile:
    for device in _trusted_devices:
        if device.id == device_id:
            return device
    
    return null

func is_device_trusted(device_id: String) -> bool:
    for device in _trusted_devices:
        if device.id == device_id:
            return true
    
    return false

# Transfer Management
func create_transfer(target_device_id: String, memory_ids: Array) -> String:
    var transfer_id = "transfer_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    
    var transfer = MemoryTransfer.new(
        transfer_id,
        _device_id,
        target_device_id
    )
    
    # Add memories
    for memory_id in memory_ids:
        transfer.add_memory(memory_id)
    
    # Set encryption level based on current security
    transfer.set_encryption_level(_current_security_level)
    transfer.set_hash_type(_current_hash_type)
    
    # Generate verification hash
    transfer.verification_hash = _generate_verification_hash(memory_ids)
    
    # Add to pending transfers
    _pending_transfers.append(transfer)
    
    # Save transfers
    save_transfers()
    
    emit_signal("transfer_created", transfer_id)
    
    return transfer_id

func execute_transfer(transfer_id: String) -> Dictionary:
    var transfer = null
    
    # Find transfer
    for t in _pending_transfers:
        if t.id == transfer_id:
            transfer = t
            break
    
    if transfer == null:
        return {"success": false, "error": "Transfer not found"}
    
    # Check if target device is trusted
    if not is_device_trusted(transfer.target_device):
        transfer.fail("Target device not trusted")
        return {"success": false, "error": "Target device not trusted"}
    
    # Prepare memory data
    var memory_data = []
    
    for memory_id in transfer.memory_ids:
        # Get memory from system if available
        var memory = null
        if _memory_system:
            memory = _memory_system.get_memory(memory_id)
        
        if memory:
            # Convert to transferable format
            var mem_dict = memory.to_dict()
            
            # Apply encryption if needed
            if transfer.encryption_level >= SECURITY_LEVELS.HIGH:
                mem_dict = _encrypt_memory_data(mem_dict)
            
            memory_data.append(mem_dict)
        else:
            # If memory not found, add placeholder
            memory_data.append({
                "id": memory_id,
                "content": "Memory not available",
                "status": "placeholder"
            })
    
    # Mark as in progress
    transfer.state = TransferState.IN_PROGRESS
    
    # Create transfer packet
    var transfer_packet = {
        "transfer_id": transfer.id,
        "source_device": transfer.source_device,
        "target_device": transfer.target_device,
        "memory_count": memory_data.size(),
        "memory_data": memory_data,
        "encryption_level": transfer.encryption_level,
        "verification_hash": transfer.verification_hash,
        "timestamp": OS.get_unix_time()
    }
    
    # Simulate successful transfer for now
    transfer.complete()
    
    # Move from pending to completed
    _pending_transfers.erase(transfer)
    _completed_transfers.append(transfer)
    
    # Save transfers
    save_transfers()
    
    emit_signal("transfer_completed", transfer.id)
    
    return {
        "success": true,
        "transfer_packet": transfer_packet
    }

func receive_transfer(transfer_packet: Dictionary) -> Dictionary:
    # Validate packet
    if not _validate_transfer_packet(transfer_packet):
        return {"success": false, "error": "Invalid transfer packet"}
    
    # Check if source device is trusted
    if not is_device_trusted(transfer_packet.source_device):
        return {"success": false, "error": "Source device not trusted"}
    
    # Verify hash
    var computed_hash = _generate_verification_hash_from_packet(transfer_packet)
    if computed_hash != transfer_packet.verification_hash:
        return {"success": false, "error": "Verification hash mismatch"}
    
    # Process memories
    var processed_memories = []
    
    for mem_data in transfer_packet.memory_data:
        # Decrypt if needed
        if transfer_packet.encryption_level >= SECURITY_LEVELS.HIGH:
            mem_data = _decrypt_memory_data(mem_data)
        
        # Import memory into system if available
        if _memory_system:
            var result = _import_memory_to_system(mem_data)
            processed_memories.append(result)
        else:
            processed_memories.append({
                "id": mem_data.id if mem_data.has("id") else "unknown",
                "status": "stored",
                "system_available": false
            })
    
    # Create completed transfer record
    var transfer = MemoryTransfer.new(
        transfer_packet.transfer_id,
        transfer_packet.source_device,
        transfer_packet.target_device
    )
    
    transfer.memory_ids = []
    for mem in processed_memories:
        transfer.memory_ids.append(mem.id)
    
    transfer.encryption_level = transfer_packet.encryption_level
    transfer.verification_hash = transfer_packet.verification_hash
    transfer.complete()
    
    # Add to completed transfers
    _completed_transfers.append(transfer)
    
    # Save transfers
    save_transfers()
    
    # Update device sync time
    var source_device = get_trusted_device(transfer_packet.source_device)
    if source_device:
        source_device.update_last_sync()
        save_trusted_devices()
    
    return {
        "success": true,
        "processed_memories": processed_memories
    }

func cancel_transfer(transfer_id: String) -> bool:
    for i in range(_pending_transfers.size()):
        if _pending_transfers[i].id == transfer_id:
            _pending_transfers[i].cancel()
            
            # Move to completed (as canceled)
            var transfer = _pending_transfers[i]
            _pending_transfers.remove(i)
            _completed_transfers.append(transfer)
            
            # Save transfers
            save_transfers()
            
            return true
    
    return false

# Encryption/Security Functions
func _encrypt_memory_data(memory_data: Dictionary) -> Dictionary:
    # This would normally use proper encryption
    # For now, just add a marker to simulate encryption
    var result = memory_data.duplicate()
    result["encrypted"] = true
    
    if memory_data.has("content"):
        # Simple XOR with key (for demonstration only - not secure!)
        var encrypted_content = ""
        var content = memory_data.content
        var key = _encryption_key
        
        for i in range(content.length()):
            var char_code = ord(content[i])
            var key_char_code = ord(key[i % key.length()])
            encrypted_content += char(char_code ^ key_char_code)
        
        result["content"] = encrypted_content
    
    return result

func _decrypt_memory_data(memory_data: Dictionary) -> Dictionary:
    # Reverse of the encryption process
    if not memory_data.has("encrypted") or not memory_data.encrypted:
        return memory_data
    
    var result = memory_data.duplicate()
    result.erase("encrypted")
    
    if memory_data.has("content"):
        # Simple XOR with key (for demonstration only - not secure!)
        var decrypted_content = ""
        var content = memory_data.content
        var key = _encryption_key
        
        for i in range(content.length()):
            var char_code = ord(content[i])
            var key_char_code = ord(key[i % key.length()])
            decrypted_content += char(char_code ^ key_char_code)
        
        result["content"] = decrypted_content
    
    return result

func _generate_verification_hash(memory_ids: Array) -> String:
    # Create a hash based on memory IDs and content
    var data_to_hash = PoolStringArray(memory_ids).join(",")
    
    # Add memory content if available
    if _memory_system:
        for memory_id in memory_ids:
            var memory = _memory_system.get_memory(memory_id)
            if memory:
                data_to_hash += ":" + memory.content
    
    # Add device ID and timestamp
    data_to_hash += "|" + _device_id + "|" + str(OS.get_unix_time())
    
    # Hash the data
    var hash = data_to_hash.sha256_text()
    
    return hash

func _generate_verification_hash_from_packet(packet: Dictionary) -> String:
    var memory_ids = []
    var data_to_hash = ""
    
    # Extract memory IDs and content
    for mem_data in packet.memory_data:
        if mem_data.has("id"):
            memory_ids.append(mem_data.id)
            
            if mem_data.has("content"):
                data_to_hash += ":" + mem_data.content
    
    data_to_hash = PoolStringArray(memory_ids).join(",") + data_to_hash
    
    # Add source device and timestamp
    data_to_hash += "|" + packet.source_device + "|" + str(packet.timestamp)
    
    # Hash the data
    var hash = data_to_hash.sha256_text()
    
    return hash

func _validate_transfer_packet(packet: Dictionary) -> bool:
    # Check required fields
    var required_fields = [
        "transfer_id", "source_device", "target_device",
        "memory_count", "memory_data", "encryption_level",
        "verification_hash", "timestamp"
    ]
    
    for field in required_fields:
        if not packet.has(field):
            return false
    
    # Check that target matches this device
    if packet.target_device != _device_id:
        return false
    
    # Check memory count
    if packet.memory_count != packet.memory_data.size():
        return false
    
    return true

func _import_memory_to_system(memory_data: Dictionary) -> Dictionary:
    if not _memory_system:
        return {
            "id": memory_data.id if memory_data.has("id") else "unknown",
            "status": "system_unavailable"
        }
    
    # Check if memory already exists
    var existing_memory = null
    if memory_data.has("id"):
        existing_memory = _memory_system.get_memory(memory_data.id)
    
    var memory_id = ""
    
    if existing_memory:
        # Update existing memory
        var success = _memory_system.update_memory(
            memory_data.id,
            memory_data.content
        )
        
        if success:
            memory_id = memory_data.id
            return {
                "id": memory_id,
                "status": "updated"
            }
        else:
            return {
                "id": memory_data.id,
                "status": "update_failed"
            }
    else:
        # Create new memory
        var dimension = 1
        if memory_data.has("dimension"):
            dimension = memory_data.dimension
        
        memory_id = _memory_system.create_memory(
            memory_data.content,
            dimension
        )
        
        if memory_id:
            # Add tags if available
            if memory_data.has("tags"):
                for tag in memory_data.tags:
                    _memory_system.add_tag_to_memory(memory_id, tag)
            
            return {
                "id": memory_id,
                "status": "created"
            }
        else:
            return {
                "id": "failed",
                "status": "creation_failed"
            }
    
    return {
        "id": memory_id,
        "status": "unknown"
    }

# File Operations
func save_trusted_devices() -> bool:
    var dir = Directory.new()
    var devices_dir = "user://secure_memory"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(devices_dir):
        dir.make_dir_recursive(devices_dir)
    
    # Save as JSON
    var file = File.new()
    var file_path = devices_dir.plus_file("trusted_devices.json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open devices file for writing: " + str(err))
        return false
    
    var devices_data = []
    for device in _trusted_devices:
        devices_data.append(device.to_dict())
    
    file.store_string(JSON.print(devices_data, "  "))
    file.close()
    
    return true

func load_trusted_devices() -> bool:
    var file = File.new()
    var file_path = "user://secure_memory/trusted_devices.json"
    
    if not file.file_exists(file_path):
        return false
    
    var err = file.open(file_path, File.READ)
    if err != OK:
        push_error("Failed to open devices file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse devices JSON: " + str(parse_result.error))
        return false
    
    var devices_data = parse_result.result
    _trusted_devices = []
    
    for device_data in devices_data:
        var device = DeviceProfile.from_dict(device_data)
        _trusted_devices.append(device)
    
    return true

func save_transfers() -> bool:
    var dir = Directory.new()
    var transfers_dir = "user://secure_memory/transfers"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(transfers_dir):
        dir.make_dir_recursive(transfers_dir)
    
    # Save pending transfers
    var file = File.new()
    var file_path = transfers_dir.plus_file("pending_transfers.json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open pending transfers file for writing: " + str(err))
        return false
    
    var pending_data = []
    for transfer in _pending_transfers:
        pending_data.append(transfer.to_dict())
    
    file.store_string(JSON.print(pending_data, "  "))
    file.close()
    
    # Save completed transfers
    file_path = transfers_dir.plus_file("completed_transfers.json")
    err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open completed transfers file for writing: " + str(err))
        return false
    
    var completed_data = []
    for transfer in _completed_transfers:
        completed_data.append(transfer.to_dict())
    
    file.store_string(JSON.print(completed_data, "  "))
    file.close()
    
    return true

func load_transfers() -> bool:
    var dir = Directory.new()
    var transfers_dir = "user://secure_memory/transfers"
    
    if not dir.dir_exists(transfers_dir):
        return false
    
    # Load pending transfers
    var file = File.new()
    var file_path = transfers_dir.plus_file("pending_transfers.json")
    
    if file.file_exists(file_path):
        var err = file.open(file_path, File.READ)
        if err != OK:
            push_error("Failed to open pending transfers file for reading: " + str(err))
        else:
            var content = file.get_as_text()
            file.close()
            
            var parse_result = JSON.parse(content)
            if parse_result.error != OK:
                push_error("Failed to parse pending transfers JSON: " + str(parse_result.error))
            else:
                var pending_data = parse_result.result
                _pending_transfers = []
                
                for transfer_data in pending_data:
                    var transfer = MemoryTransfer.from_dict(transfer_data)
                    _pending_transfers.append(transfer)
    
    # Load completed transfers
    file_path = transfers_dir.plus_file("completed_transfers.json")
    
    if file.file_exists(file_path):
        var err = file.open(file_path, File.READ)
        if err != OK:
            push_error("Failed to open completed transfers file for reading: " + str(err))
        else:
            var content = file.get_as_text()
            file.close()
            
            var parse_result = JSON.parse(content)
            if parse_result.error != OK:
                push_error("Failed to parse completed transfers JSON: " + str(parse_result.error))
            else:
                var completed_data = parse_result.result
                _completed_transfers = []
                
                for transfer_data in completed_data:
                    var transfer = MemoryTransfer.from_dict(transfer_data)
                    _completed_transfers.append(transfer)
    
    return true

func _generate_device_id() -> String:
    # Generate a unique device ID
    var os_name = OS.get_name()
    var device_name = OS.get_model_name()
    var unique_id = OS.get_unique_id()
    
    # If unique ID not available, create a random one
    if unique_id.empty():
        var rng = RandomNumberGenerator.new()
        rng.randomize()
        unique_id = str(rng.randi()) + "-" + str(OS.get_unix_time())
    
    var device_id = (os_name + "-" + device_name + "-" + unique_id).sha256_text().substr(0, 16)
    return device_id

# Google Drive Integration
func setup_google_drive_connection(auth_token: String) -> Dictionary:
    # This would normally handle actual Google Drive API connection
    # For now, just simulate the connection
    
    var result = {
        "success": true,
        "device_id": _device_id,
        "security_level": _current_security_level,
        "connection_status": "authenticated"
    }
    
    return result

func sync_memories_with_drive(folder_path: String = "MemorySystem") -> Dictionary:
    # This would normally handle actual Google Drive sync
    # For now, just simulate the sync
    
    var result = {
        "success": true,
        "memories_uploaded": 0,
        "memories_downloaded": 0,
        "sync_timestamp": OS.get_unix_time(),
        "folder_path": folder_path
    }
    
    # Simulate memory transfer
    if _memory_system:
        var memory_count = _memory_system._memories.size()
        result.memories_uploaded = min(memory_count, 5)  # Simulate uploading some memories
        result.memories_downloaded = 3  # Simulate downloading some memories
    
    return result

# Security Pattern Visualization
func visualize_memory_security_patterns(date: String = "") -> Dictionary:
    if not _trajectory_system:
        return {"success": false, "error": "Trajectory system not available"}
    
    var trajectory = _trajectory_system.get_trajectory(date)
    if not trajectory:
        return {"success": false, "error": "Trajectory not found"}
    
    # Generate security pattern
    var pattern = {
        "past_memories": [],   # Past memories (verified)
        "center_memories": [], # Present/center memories
        "future_memories": [], # Future planned memories
        "secure_zones": [],    # Secure memory zones
        "structure": {
            "layout": "temporal", # temporal, spatial, etc.
            "format": "structured",
            "padding": true
        }
    }
    
    # Add trajectory points
    for point_type in trajectory.points:
        var point = trajectory.points[point_type]
        if not point.memory_id.empty():
            if point_type == _trajectory_system.TRAJECTORY_POINTS.START:
                pattern.past_memories.append({
                    "id": point.memory_id,
                    "security": "verified",
                    "marker": MEMORY_MARKERS.VERIFIED
                })
            elif point_type == _trajectory_system.TRAJECTORY_POINTS.CENTER:
                pattern.center_memories.append({
                    "id": point.memory_id,
                    "security": "active",
                    "marker": MEMORY_MARKERS.PRESENT
                })
            elif point_type == _trajectory_system.TRAJECTORY_POINTS.END:
                pattern.future_memories.append({
                    "id": point.memory_id,
                    "security": "planned",
                    "marker": MEMORY_MARKERS.FUTURE
                })
    
    # Add secure zones based on connected memories
    for memory_id in trajectory.connected_memories:
        pattern.secure_zones.append({
            "memory_id": memory_id,
            "type": "protected",
            "marker": MEMORY_MARKERS.LOCKED
        })
    
    return {
        "success": true,
        "pattern": pattern
    }

# Utility Functions
func get_transfer_status_summary() -> Dictionary:
    return {
        "pending_transfers": _pending_transfers.size(),
        "completed_transfers": _completed_transfers.size(),
        "security_level": _current_security_level,
        "device_id": _device_id,
        "trusted_devices": _trusted_devices.size()
    }

func generate_security_report() -> String:
    var report = "# SECURE MEMORY CHANNEL REPORT #\n\n"
    
    # Device information
    report += "## Device Information\n"
    report += "Device ID: " + _device_id + "\n"
    report += "Security Level: " + _security_level_name(_current_security_level) + "\n"
    report += "Trusted Devices: " + str(_trusted_devices.size()) + "\n\n"
    
    # Transfer statistics
    report += "## Transfer Statistics\n"
    report += "Pending Transfers: " + str(_pending_transfers.size()) + "\n"
    report += "Completed Transfers: " + str(_completed_transfers.size()) + "\n\n"
    
    # Recent transfers
    report += "## Recent Transfers\n"
    var recent_transfers = _get_recent_transfers(5)
    
    if recent_transfers.size() > 0:
        for transfer in recent_transfers:
            var status = "Unknown"
            if transfer.state == TransferState.COMPLETED:
                status = "Completed"
            elif transfer.state == TransferState.FAILED:
                status = "Failed: " + transfer.error_message
            elif transfer.state == TransferState.CANCELED:
                status = "Canceled"
            elif transfer.state == TransferState.IN_PROGRESS:
                status = "In Progress"
            elif transfer.state == TransferState.PENDING:
                status = "Pending"
            
            report += "- Transfer " + transfer.id + ": " + status + "\n"
            report += "  Memories: " + str(transfer.memory_ids.size()) + "\n"
            report += "  Target: " + transfer.target_device + "\n"
    else:
        report += "No recent transfers\n"
    
    return report

func _security_level_name(level: int) -> String:
    for key in SECURITY_LEVELS:
        if SECURITY_LEVELS[key] == level:
            return key
    return "UNKNOWN"

func _get_recent_transfers(count: int) -> Array:
    var all_transfers = _completed_transfers.duplicate()
    all_transfers.append_array(_pending_transfers)
    
    # Sort by timestamp (most recent first)
    all_transfers.sort_custom(self, "_sort_transfers_by_time")
    
    # Take only the requested count
    var result = []
    for i in range(min(count, all_transfers.size())):
        result.append(all_transfers[i])
    
    return result

func _sort_transfers_by_time(a: MemoryTransfer, b: MemoryTransfer) -> bool:
    return a.timestamp > b.timestamp

# Example usage:
# var secure_channel = SecureMemoryChannel.new()
# add_child(secure_channel)
# secure_channel.initialize(memory_system, trajectory_system, connection_system)
# 
# # Set security level
# secure_channel.set_security_level(SecureMemoryChannel.SECURITY_LEVELS.HIGH)
# 
# # Generate encryption key
# var key = secure_channel.generate_encryption_key()
# 
# # Add trusted device
# var device_id = secure_channel.add_trusted_device("My Phone")
# 
# # Create and execute transfer
# var transfer_id = secure_channel.create_transfer(device_id, ["memory_1", "memory_2"])
# var result = secure_channel.execute_transfer(transfer_id)
# 
# # Connect to Google Drive
# var drive_connection = secure_channel.setup_google_drive_connection("auth_token")
# var sync_result = secure_channel.sync_memories_with_drive()
# 
# # Generate security report
# var report = secure_channel.generate_security_report()