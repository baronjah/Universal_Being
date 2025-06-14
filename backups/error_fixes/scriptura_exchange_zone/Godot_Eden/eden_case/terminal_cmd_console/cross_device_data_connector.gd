extends Node

class_name CrossDeviceDataConnector

# Device connections
var connected_devices = {}
var local_device_id = ""
var sync_queue = []

# Pool connections
var data_pool_manager
var memory_manager
var ethereal_connector

# API connections
var api_connections = {}
var active_api = "default"

# Device tracking
var last_seen_devices = {}
var device_capabilities = {}
var device_metadata = {}

# Transfer settings
var auto_connect = true
var allow_remote_control = false
var encryption_enabled = true
var compression_level = 6
var transfer_chunk_size = 1024 * 1024 # 1MB chunks

# Statistics
var bytes_sent = 0
var bytes_received = 0
var successful_transfers = 0
var failed_transfers = 0
var last_connection_time = 0

signal device_connected(device_id)
signal device_disconnected(device_id)
signal data_received(device_id, data_type, data)
signal transfer_progress(device_id, operation, progress, total)
signal error_occurred(device_id, error_code, message)

func _ready():
	initialize_system()
	generate_device_id()
	connect_to_managers()
	
	if auto_connect:
		discover_devices()

func initialize_system():
	print("Initializing Cross-Device Data Connector...")
	
	# Load saved settings if available
	load_settings()
	
	# Register APIs
	register_known_apis()
	
	# Set up connection timer
	var timer = Timer.new()
	timer.wait_time = 60 # Check every minute
	timer.autostart = true
	timer.connect("timeout", self, "check_connections")
	add_child(timer)

func generate_device_id():
	# Generate a unique device ID if not already set
	if local_device_id == "":
		var system_id = OS.get_unique_id()
		
		if system_id == "":
			# Fallback if OS.get_unique_id() doesn't work
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			system_id = str(rng.randi()) + str(OS.get_unix_time())
		
		local_device_id = "dev_" + system_id.sha256_text().substr(0, 8)
		
	print("Local device ID: " + local_device_id)
	return local_device_id

func connect_to_managers():
	# Connect to DatapoolSyncManager if available
	if has_node("/root/DatapoolSyncManager"):
		data_pool_manager = get_node("/root/DatapoolSyncManager")
		print("Connected to DatapoolSyncManager")
	else:
		# Try to create it
		var DatapoolSyncManagerScript = load("res://datapool_sync_manager.gd")
		if DatapoolSyncManagerScript:
			data_pool_manager = DatapoolSyncManagerScript.new()
			data_pool_manager.name = "DatapoolSyncManager"
			get_tree().get_root().add_child(data_pool_manager)
			print("Created DatapoolSyncManager")
	
	# Connect to memory system
	if has_node("/root/MemorySystem"):
		memory_manager = get_node("/root/MemorySystem")
		print("Connected to MemorySystem")
	elif has_node("/root/MemoryManager"):
		memory_manager = get_node("/root/MemoryManager")
		print("Connected to MemoryManager")
	
	# Connect to EtherealEngineConnector if available
	if has_node("/root/EtherealEngineConnector"):
		ethereal_connector = get_node("/root/EtherealEngineConnector")
		print("Connected to EtherealEngineConnector")

# Device discovery and connection
func discover_devices():
	print("Discovering devices...")
	
	# Local network discovery
	discover_local_network()
	
	# Cloud-based discovery
	discover_cloud_devices()
	
	# Direct connection to known devices
	connect_to_known_devices()
	
	print("Device discovery completed. Found " + str(connected_devices.size()) + " devices.")

func discover_local_network():
	# Placeholder for local network discovery (would use UDP broadcast in actual implementation)
	print("Scanning local network...")
	
	# In a real implementation, this would use UDP broadcast to discover devices
	# For now, we'll simulate finding devices
	var simulated_local_devices = []
	
	# Check if any devices are running on known ports
	for port in [8970, 8971, 8972]:
		# This would be a real network check in a full implementation
		pass
	
	# Process found devices
	for device_info in simulated_local_devices:
		register_device(device_info.id, device_info.name, device_info.address, "local")

func discover_cloud_devices():
	# Check for cloud-connected devices through each API
	for api_id in api_connections:
		var api = api_connections[api_id]
		
		if api.has("connected") and api.connected:
			var cloud_devices = fetch_cloud_devices(api_id)
			
			for device in cloud_devices:
				register_device(device.id, device.name, device.address, "cloud_" + api_id)

func fetch_cloud_devices(api_id):
	var devices = []
	var api = api_connections[api_id]
	
	if api.handler.has_method("list_connected_devices"):
		devices = api.handler.list_connected_devices()
	elif api_id == "google_drive" and data_pool_manager:
		# Special case: try to get devices through DatapoolSyncManager
		var google_accounts = data_pool_manager.scan_google_accounts()
		
		for account_id in data_pool_manager.google_drive_accounts:
			var account = data_pool_manager.google_drive_accounts[account_id]
			
			# Each account could represent a device
			devices.append({
				"id": "gdrive_" + account_id,
				"name": account.name,
				"address": account_id,
				"last_seen": OS.get_unix_time()
			})
	
	return devices

func connect_to_known_devices():
	# Load known devices from configuration
	var known_devices = load_known_devices()
	
	for device_id in known_devices:
		var device = known_devices[device_id]
		
		if not connected_devices.has(device_id):
			connect_to_device(device_id, device.address, device.connection_type)

func register_device(device_id, device_name, address, connection_type):
	if device_id == local_device_id:
		return false
	
	if not connected_devices.has(device_id):
		connected_devices[device_id] = {
			"id": device_id,
			"name": device_name,
			"address": address,
			"connection_type": connection_type,
			"connected": false,
			"connection_time": 0,
			"last_activity": 0,
			"transfer_queue": []
		}
		
		# Try to connect
		connect_to_device(device_id, address, connection_type)
		return true
	
	return false

func connect_to_device(device_id, address, connection_type):
	if not connected_devices.has(device_id):
		print("Device not registered: " + device_id)
		return false
	
	var device = connected_devices[device_id]
	print("Connecting to device: " + device_id + " via " + connection_type)
	
	var success = false
	
	match connection_type:
		"local":
			success = connect_local(device_id, address)
		"direct":
			success = connect_direct(device_id, address)
		_:
			if connection_type.begins_with("cloud_"):
				var api_id = connection_type.replace("cloud_", "")
				success = connect_cloud(device_id, address, api_id)
	
	if success:
		device.connected = true
		device.connection_time = OS.get_unix_time()
		device.last_activity = OS.get_unix_time()
		
		emit_signal("device_connected", device_id)
		
		# Exchange capabilities
		exchange_device_capabilities(device_id)
		
		# Process any queued transfers
		process_transfer_queue(device_id)
		
		print("Connected to device: " + device_id)
	else:
		print("Failed to connect to device: " + device_id)
	
	return success

func connect_local(device_id, address):
	# Placeholder for local network connection
	# In a real implementation, this would establish a socket connection
	
	# Simulate success for now
	return true

func connect_direct(device_id, address):
	# Placeholder for direct connection (e.g., via IP)
	# In a real implementation, this would establish a direct connection
	
	# Simulate success for now
	return true

func connect_cloud(device_id, address, api_id):
	if not api_connections.has(api_id):
		print("API not registered: " + api_id)
		return false
	
	var api = api_connections[api_id]
	
	if not api.has("connected") or not api.connected:
		print("API not connected: " + api_id)
		return false
	
	print("Connecting to device " + device_id + " via cloud API: " + api_id)
	
	# Try to establish connection through the API
	if api.handler.has_method("connect_to_device"):
		return api.handler.connect_to_device(device_id, address)
	
	# Simulate success for demonstration
	return true

func disconnect_from_device(device_id):
	if not connected_devices.has(device_id):
		print("Device not registered: " + device_id)
		return false
	
	var device = connected_devices[device_id]
	
	if not device.connected:
		return true
	
	print("Disconnecting from device: " + device_id)
	
	var connection_type = device.connection_type
	var success = false
	
	match connection_type:
		"local":
			success = disconnect_local(device_id)
		"direct":
			success = disconnect_direct(device_id)
		_:
			if connection_type.begins_with("cloud_"):
				var api_id = connection_type.replace("cloud_", "")
				success = disconnect_cloud(device_id, api_id)
	
	if success:
		device.connected = false
		emit_signal("device_disconnected", device_id)
		print("Disconnected from device: " + device_id)
	else:
		print("Failed to disconnect from device: " + device_id)
	
	return success

func disconnect_local(device_id):
	# Placeholder for local network disconnection
	return true

func disconnect_direct(device_id):
	# Placeholder for direct connection disconnection
	return true

func disconnect_cloud(device_id, api_id):
	if not api_connections.has(api_id):
		return false
	
	var api = api_connections[api_id]
	
	if api.handler.has_method("disconnect_from_device"):
		return api.handler.disconnect_from_device(device_id)
	
	return true

func check_connections():
	var current_time = OS.get_unix_time()
	var timeout = 300 # 5 minutes timeout
	
	for device_id in connected_devices:
		var device = connected_devices[device_id]
		
		if device.connected:
			# Check if device is still active
			if current_time - device.last_activity > timeout:
				print("Device " + device_id + " timeout. Last activity: " + str(current_time - device.last_activity) + "s ago")
				disconnect_from_device(device_id)
			else:
				# Ping device to keep connection alive
				ping_device(device_id)

func ping_device(device_id):
	if not connected_devices.has(device_id) or not connected_devices[device_id].connected:
		return false
	
	# Send a minimal ping to keep connection alive
	send_data(device_id, "system", {"type": "ping", "time": OS.get_unix_time()})
	return true

# Device capabilities
func exchange_device_capabilities(device_id):
	if not connected_devices.has(device_id) or not connected_devices[device_id].connected:
		return false
	
	// Send our capabilities
	var local_capabilities = get_local_capabilities()
	send_data(device_id, "system", {"type": "capabilities", "data": local_capabilities})
	
	// Request their capabilities
	send_data(device_id, "system", {"type": "get_capabilities"})
	
	return true

func get_local_capabilities():
	var capabilities = {
		"device_id": local_device_id,
		"device_name": OS.get_name() + " " + str(local_device_id.substr(0, 4)),
		"os": OS.get_name(),
		"version": "1.0",
		"features": {
			"memory_sync": memory_manager != null,
			"pool_sync": data_pool_manager != null,
			"ethereal_engine": ethereal_connector != null,
			"encryption": encryption_enabled,
			"compression": compression_level > 0,
			"remote_control": allow_remote_control
		},
		"apis": api_connections.keys(),
		"storage": {
			"available": get_available_storage(),
			"formats": ["json", "binary", "text"]
		}
	}
	
	return capabilities

func process_capabilities(device_id, capabilities):
	if not connected_devices.has(device_id):
		return false
	
	device_capabilities[device_id] = capabilities
	
	# Record metadata
	device_metadata[device_id] = {
		"name": capabilities.device_name,
		"os": capabilities.has("os") ? capabilities.os : "unknown",
		"version": capabilities.has("version") ? capabilities.version : "unknown",
		"last_updated": OS.get_unix_time()
	}
	
	print("Received capabilities from device: " + device_id)
	print("Device name: " + capabilities.device_name)
	
	return true

func get_available_storage():
	# Try to get actual disk space
	var space = {
		"total": 0,
		"available": 0,
		"unit": "bytes"
	}
	
	# Placeholder - would use OS-specific methods to get storage info
	# For now, just return a placeholder value
	space.total = 1073741824 # 1GB
	space.available = 536870912 # 512MB
	
	return space

# Data transfer functions
func send_data(device_id, data_type, data):
	if not connected_devices.has(device_id):
		print("Device not registered: " + device_id)
		return false
	
	var device = connected_devices[device_id]
	
	if not device.connected:
		print("Device not connected: " + device_id)
		queue_transfer(device_id, "send", data_type, data)
		return false
	
	print("Sending data to device: " + device_id + " (Type: " + data_type + ")")
	
	# Prepare payload
	var payload = {
		"sender": local_device_id,
		"type": data_type,
		"data": data,
		"timestamp": OS.get_unix_time(),
		"id": generate_transfer_id()
	}
	
	# Apply compression if enabled
	if compression_level > 0:
		payload = compress_data(payload, compression_level)
	
	# Apply encryption if enabled
	if encryption_enabled:
		payload = encrypt_data(payload, device_id)
	
	# Determine sending method based on connection type
	var success = false
	
	match device.connection_type:
		"local":
			success = send_local(device_id, payload)
		"direct":
			success = send_direct(device_id, payload)
		_:
			if device.connection_type.begins_with("cloud_"):
				var api_id = device.connection_type.replace("cloud_", "")
				success = send_cloud(device_id, payload, api_id)
	
	if success:
		device.last_activity = OS.get_unix_time()
		bytes_sent += calculate_data_size(payload)
		successful_transfers += 1
	else:
		failed_transfers += 1
		queue_transfer(device_id, "send", data_type, data)
	
	return success

func send_local(device_id, payload):
	# Placeholder for sending via local network
	# In a real implementation, this would send data over sockets
	
	# Simulate success
	return true

func send_direct(device_id, payload):
	# Placeholder for sending via direct connection
	# In a real implementation, this would send data over a direct connection
	
	# Simulate success
	return true

func send_cloud(device_id, payload, api_id):
	if not api_connections.has(api_id):
		print("API not registered: " + api_id)
		return false
	
	var api = api_connections[api_id]
	
	if not api.has("connected") or not api.connected:
		print("API not connected: " + api_id)
		return false
	
	if api.handler.has_method("send_data_to_device"):
		return api.handler.send_data_to_device(device_id, payload)
	elif api.handler.has_method("transfer_data"):
		return api.handler.transfer_data(device_id, payload)
	elif api_id == "google_drive" and data_pool_manager:
		// For Google Drive, use the datapool manager to write to a shared location
		var temp_path = "user://temp_transfer_" + payload.id + ".dat"
		var file = File.new()
		
		if file.open(temp_path, File.WRITE) == OK:
			file.store_var(payload, true)
			file.close()
			
			// Now use datapool manager to upload this file to a special transfers folder
			var pool_id = ensure_transfers_pool()
			if pool_id and data_pool_manager.sync_pool(pool_id):
				return true
	
	return false

func receive_data(device_id, payload):
	if not connected_devices.has(device_id):
		print("Received data from unregistered device: " + device_id)
		register_device(device_id, "Unknown Device", "", "unknown")
	
	var device = connected_devices[device_id]
	device.last_activity = OS.get_unix_time()
	
	print("Received data from device: " + device_id)
	
	# Decrypt if needed
	if encryption_enabled and payload.has("encrypted") and payload.encrypted:
		payload = decrypt_data(payload, device_id)
		
		if payload == null:
			print("Failed to decrypt data from device: " + device_id)
			return false
	
	# Decompress if needed
	if payload.has("compressed") and payload.compressed:
		payload = decompress_data(payload)
		
		if payload == null:
			print("Failed to decompress data from device: " + device_id)
			return false
	
	// Update stats
	bytes_received += calculate_data_size(payload)
	
	// Process system messages
	if payload.type == "system":
		process_system_message(device_id, payload.data)
	else:
		// Process regular data
		emit_signal("data_received", device_id, payload.type, payload.data)
		
		// If it's a data type we know how to handle, process it
		process_data_by_type(device_id, payload.type, payload.data)
	
	return true

func process_system_message(device_id, data):
	if not data.has("type"):
		return false
	
	match data.type:
		"ping":
			// Respond to ping with pong
			send_data(device_id, "system", {"type": "pong", "time": OS.get_unix_time()})
		"pong":
			// Update last activity time (already done in receive_data)
			pass
		"capabilities":
			// Process capabilities information
			process_capabilities(device_id, data.data)
		"get_capabilities":
			// Send our capabilities
			send_data(device_id, "system", {"type": "capabilities", "data": get_local_capabilities()})
		"error":
			// Log the error
			print("Error from device " + device_id + ": " + data.message)
			emit_signal("error_occurred", device_id, data.code, data.message)
		"file_transfer_request":
			// Handle file transfer request
			handle_file_transfer_request(device_id, data)
		"file_transfer_response":
			// Handle file transfer response
			handle_file_transfer_response(device_id, data)
	
	return true

func handle_file_transfer_request(device_id, data):
	if not data.has("file_id") or not data.has("file_name") or not data.has("file_size"):
		send_data(device_id, "system", {
			"type": "error",
			"code": "invalid_request",
			"message": "Invalid file transfer request"
		})
		return false
	
	// Check if we have space
	var available_space = get_available_storage().available
	if data.file_size > available_space:
		send_data(device_id, "system", {
			"type": "file_transfer_response",
			"file_id": data.file_id,
			"accepted": false,
			"reason": "insufficient_space"
		})
		return false
	
	// Accept the transfer
	send_data(device_id, "system", {
		"type": "file_transfer_response",
		"file_id": data.file_id,
		"accepted": true,
		"chunk_size": transfer_chunk_size
	})
	
	return true

func handle_file_transfer_response(device_id, data):
	if not data.has("file_id") or not data.has("accepted"):
		return false
	
	if data.accepted:
		// Start sending file chunks
		var chunk_size = data.has("chunk_size") ? data.chunk_size : transfer_chunk_size
		start_file_transfer(device_id, data.file_id, chunk_size)
	else:
		// Transfer rejected
		print("File transfer rejected by device " + device_id + ": " + data.reason)
	
	return data.accepted

func start_file_transfer(device_id, file_id, chunk_size):
	// Find the file in the transfer queue
	for transfer in sync_queue:
		if transfer.id == file_id and transfer.device_id == device_id:
			send_file_chunks(device_id, transfer, chunk_size)
			return true
	
	return false

func send_file_chunks(device_id, transfer, chunk_size):
	var file = File.new()
	if file.open(transfer.file_path, File.READ) != OK:
		print("Failed to open file: " + transfer.file_path)
		return false
	
	var file_size = file.get_len()
	var chunks_sent = 0
	var total_chunks = ceil(file_size / float(chunk_size))
	
	while file.get_position() < file_size:
		var chunk_data = file.get_buffer(chunk_size)
		var chunk_position = file.get_position()
		
		var chunk = {
			"type": "file_chunk",
			"file_id": transfer.id,
			"chunk_index": chunks_sent,
			"total_chunks": total_chunks,
			"position": chunk_position,
			"data": chunk_data,
			"size": chunk_data.size()
		}
		
		send_data(device_id, "file_transfer", chunk)
		chunks_sent += 1
		
		// Report progress
		emit_signal("transfer_progress", device_id, "send", chunk_position, file_size)
		
		// Add a small delay to avoid overwhelming the connection
		OS.delay_msec(50)
	
	file.close()
	
	// Send completion message
	send_data(device_id, "system", {
		"type": "file_transfer_complete",
		"file_id": transfer.id,
		"file_name": transfer.file_name,
		"file_size": file_size,
		"chunks": chunks_sent
	})
	
	// Remove from queue
	for i in range(sync_queue.size()):
		if sync_queue[i].id == transfer.id:
			sync_queue.remove(i)
			break
	
	return true

func process_data_by_type(device_id, data_type, data):
	match data_type:
		"memory":
			process_memory_data(device_id, data)
		"file_transfer":
			process_file_chunk(device_id, data)
		"pool_data":
			process_pool_data(device_id, data)
		"ethereal":
			process_ethereal_data(device_id, data)
		"command":
			process_command(device_id, data)

func process_memory_data(device_id, data):
	if not memory_manager:
		print("No memory manager available to process memory data")
		return false
	
	if not data.has("operation"):
		return false
	
	match data.operation:
		"store":
			if data.has("fragment") and memory_manager.has_method("store_memory"):
				memory_manager.store_memory(data.fragment)
		"retrieve":
			if data.has("id") and memory_manager.has_method("retrieve_memory"):
				var fragment = memory_manager.retrieve_memory(data.id)
				if fragment:
					send_data(device_id, "memory", {
						"operation": "retrieve_response",
						"fragment": fragment,
						"request_id": data.request_id if data.has("request_id") else null
					})
		"sync":
			if data.has("fragments") and memory_manager.has_method("sync_fragments"):
				memory_manager.sync_fragments(data.fragments)

func process_file_chunk(device_id, data):
	if not data.has("file_id") or not data.has("chunk_index") or not data.has("data"):
		return false
	
	// Check if we have a temporary file to write to
	var temp_dir = "user://temp_downloads/"
	var dir = Directory.new()
	if not dir.dir_exists(temp_dir):
		dir.make_dir_recursive(temp_dir)
	
	var temp_path = temp_dir + data.file_id + ".part"
	var file = File.new()
	
	var open_mode = File.READ_WRITE
	if data.chunk_index == 0:
		open_mode = File.WRITE # Create new file for first chunk
	
	if file.open(temp_path, open_mode) != OK:
		print("Failed to open temporary file: " + temp_path)
		return false
	
	// Seek to the right position
	if data.has("position"):
		file.seek(data.position - data.data.size())
	else:
		file.seek_end()
	
	// Write chunk data
	file.store_buffer(data.data)
	file.close()
	
	// Report progress
	if data.has("total_chunks"):
		var progress = float(data.chunk_index + 1) / data.total_chunks
		emit_signal("transfer_progress", device_id, "receive", data.chunk_index + 1, data.total_chunks)
	
	// Check if this was the last chunk
	if data.has("total_chunks") and data.chunk_index + 1 >= data.total_chunks:
		// Rename to final filename
		var final_path = temp_dir + data.file_id
		dir.rename(temp_path, final_path)
		
		print("File transfer complete: " + final_path)
	
	return true

func process_pool_data(device_id, data):
	if not data_pool_manager:
		print("No data pool manager available to process pool data")
		return false
	
	if not data.has("operation"):
		return false
	
	match data.operation:
		"sync_request":
			if data.has("pool_id"):
				// Handle pool sync request
				var pool_id = data.pool_id
				if data_pool_manager.active_pools.has(pool_id):
					data_pool_manager.sync_pool(pool_id)
					
					// Notify the requesting device
					send_data(device_id, "pool_data", {
						"operation": "sync_complete",
						"pool_id": pool_id,
						"success": true,
						"request_id": data.request_id if data.has("request_id") else null
					})
		"pool_info":
			// Process pool information from another device
			if data.has("pools"):
				for pool_data in data.pools:
					// Could store this information for cross-device pool awareness
					pass

func process_ethereal_data(device_id, data):
	if not ethereal_connector:
		print("No ethereal engine connector available")
		return false
	
	if not data.has("operation"):
		return false
	
	// Forward to the ethereal connector
	if ethereal_connector.has_method("process_external_data"):
		ethereal_connector.process_external_data(device_id, data)
	
	return true

func process_command(device_id, data):
	if not allow_remote_control:
		print("Remote commands not allowed")
		send_data(device_id, "command", {
			"operation": "response",
			"success": false,
			"message": "Remote commands not allowed on this device",
			"command_id": data.command_id if data.has("command_id") else null
		})
		return false
	
	if not data.has("command"):
		return false
	
	print("Processing command from device " + device_id + ": " + data.command)
	
	var result = execute_command(data.command)
	
	send_data(device_id, "command", {
		"operation": "response",
		"success": result.success,
		"result": result.result,
		"command_id": data.command_id if data.has("command_id") else null
	})
	
	return result.success

func execute_command(command):
	var result = {
		"success": false,
		"result": null
	}
	
	// Parse the command
	var parts = command.split(" ", false)
	
	if parts.size() == 0:
		result.result = "Empty command"
		return result
	
	// Route command to appropriate manager
	match parts[0]:
		"pool":
			if data_pool_manager and data_pool_manager.has_method("process_command"):
				result.result = data_pool_manager.process_command(command)
				result.success = true
		"memory":
			if memory_manager and memory_manager.has_method("process_command"):
				result.result = memory_manager.process_command(command)
				result.success = true
		"ethereal":
			if ethereal_connector and ethereal_connector.has_method("process_command"):
				result.result = ethereal_connector.process_command(command)
				result.success = true
		"device":
			result = process_device_command(parts)
		"help":
			result.result = show_help()
			result.success = true
		_:
			result.result = "Unknown command: " + parts[0]
	
	return result

func process_device_command(parts):
	var result = {
		"success": false,
		"result": null
	}
	
	if parts.size() < 2:
		result.result = "Usage: device <list|connect|disconnect|info>"
		return result
	
	match parts[1]:
		"list":
			var device_list = "Connected Devices:\n"
			
			if connected_devices.empty():
				device_list += "No devices connected\n"
			else:
				for id in connected_devices:
					var device = connected_devices[id]
					device_list += "- " + id + " (" + device.name + ") "
					
					if device.connected:
						device_list += "[Connected] "
					else:
						device_list += "[Disconnected] "
						
					device_list += "Type: " + device.connection_type + "\n"
			
			result.result = device_list
			result.success = true
			
		"connect":
			if parts.size() < 3:
				result.result = "Usage: device connect <device_id>"
				return result
			
			var device_id = parts[2]
			
			if connected_devices.has(device_id) and connect_to_device(device_id, connected_devices[device_id].address, connected_devices[device_id].connection_type):
				result.result = "Connected to device: " + device_id
				result.success = true
			else:
				result.result = "Failed to connect to device: " + device_id
				
		"disconnect":
			if parts.size() < 3:
				result.result = "Usage: device disconnect <device_id>"
				return result
			
			var device_id = parts[2]
			
			if disconnect_from_device(device_id):
				result.result = "Disconnected from device: " + device_id
				result.success = true
			else:
				result.result = "Failed to disconnect from device: " + device_id
				
		"info":
			if parts.size() < 3:
				result.result = "Usage: device info <device_id>"
				return result
			
			var device_id = parts[2]
			
			if not connected_devices.has(device_id):
				result.result = "Device not found: " + device_id
				return result
			
			var device = connected_devices[device_id]
			var device_info = "Device Information: " + device_id + "\n"
			device_info += "Name: " + device.name + "\n"
			device_info += "Connection Type: " + device.connection_type + "\n"
			device_info += "Status: " + (device.connected ? "Connected" : "Disconnected") + "\n"
			
			if device.connected:
				device_info += "Connected Since: " + get_time_ago(OS.get_unix_time() - device.connection_time) + "\n"
				device_info += "Last Activity: " + get_time_ago(OS.get_unix_time() - device.last_activity) + "\n"
			
			if device_capabilities.has(device_id):
				var caps = device_capabilities[device_id]
				device_info += "\nCapabilities:\n"
				
				if caps.has("os"):
					device_info += "OS: " + caps.os + "\n"
				
				if caps.has("features"):
					device_info += "Features:\n"
					for feature in caps.features:
						device_info += "- " + feature + ": " + str(caps.features[feature]) + "\n"
			
			result.result = device_info
			result.success = true
			
		"send":
			if parts.size() < 5:
				result.result = "Usage: device send <device_id> <data_type> <data>"
				return result
			
			var device_id = parts[2]
			var data_type = parts[3]
			var data_str = " ".join(parts.slice(4, parts.size() - 1))
			
			// Try to parse as JSON
			var data = null
			var json = JSON.parse(data_str)
			
			if json.error == OK:
				data = json.result
			else:
				// If not valid JSON, use as string
				data = data_str
			
			if send_data(device_id, data_type, data):
				result.result = "Data sent to device: " + device_id
				result.success = true
			else:
				result.result = "Failed to send data to device: " + device_id
				
		_:
			result.result = "Unknown device command: " + parts[1]
	
	return result

func show_help():
	return """
CROSS-DEVICE DATA CONNECTOR - COMMANDS

device list - List all devices
device connect <device_id> - Connect to a device
device disconnect <device_id> - Disconnect from a device
device info <device_id> - Show device information
device send <device_id> <data_type> <data> - Send data to a device

pool ... - Access data pool commands (see DatapoolSyncManager)
memory ... - Access memory commands (if available)
ethereal ... - Access Ethereal Engine commands (if available)

help - Show this help text
"""

# Queue management
func queue_transfer(device_id, operation, data_type, data):
	if not connected_devices.has(device_id):
		return false
	
	var device = connected_devices[device_id]
	
	var transfer = {
		"id": generate_transfer_id(),
		"operation": operation,
		"data_type": data_type,
		"data": data,
		"timestamp": OS.get_unix_time(),
		"attempts": 0
	}
	
	device.transfer_queue.append(transfer)
	print("Queued transfer for device " + device_id + ": " + transfer.id)
	
	return true

func process_transfer_queue(device_id):
	if not connected_devices.has(device_id) or not connected_devices[device_id].connected:
		return false
	
	var device = connected_devices[device_id]
	
	if device.transfer_queue.empty():
		return true
	
	print("Processing transfer queue for device " + device_id + ": " + str(device.transfer_queue.size()) + " items")
	
	var processed = []
	
	for transfer in device.transfer_queue:
		transfer.attempts += 1
		
		if transfer.operation == "send":
			if send_data(device_id, transfer.data_type, transfer.data):
				processed.append(transfer)
			elif transfer.attempts >= 3:
				// After 3 attempts, give up
				processed.append(transfer)
				print("Failed to send queued transfer after 3 attempts: " + transfer.id)
		else:
			// Other operations not supported in queue yet
			processed.append(transfer)
	
	// Remove processed items
	for item in processed:
		device.transfer_queue.erase(item)
	
	return true

# File transfer functions
func send_file(device_id, file_path, remote_path=null):
	if not connected_devices.has(device_id):
		print("Device not registered: " + device_id)
		return false
	
	var device = connected_devices[device_id]
	
	var file = File.new()
	if not file.file_exists(file_path):
		print("File does not exist: " + file_path)
		return false
	
	// Get file information
	var file_size = 0
	if file.open(file_path, File.READ) == OK:
		file_size = file.get_len()
		file.close()
	
	var file_name = file_path.get_file()
	
	// Create transfer record
	var transfer_id = generate_transfer_id()
	var transfer = {
		"id": transfer_id,
		"device_id": device_id,
		"operation": "send_file",
		"file_path": file_path,
		"file_name": file_name,
		"file_size": file_size,
		"remote_path": remote_path,
		"timestamp": OS.get_unix_time(),
		"status": "pending"
	}
	
	// Add to queue
	sync_queue.append(transfer)
	
	// Send transfer request
	if device.connected:
		send_data(device_id, "system", {
			"type": "file_transfer_request",
			"file_id": transfer_id,
			"file_name": file_name,
			"file_size": file_size,
			"remote_path": remote_path
		})
	
	return transfer_id

# API management
func register_known_apis():
	# Check for known API handlers
	check_and_register_api("claude", "ClaudeAPI")
	check_and_register_api("openai", "OpenAIAPI")
	check_and_register_api("google_drive", "GoogleDriveAPI")
	check_and_register_api("google_assistant", "GoogleAssistantAPI")
	check_and_register_api("gemini", "GeminiAPI")
	check_and_register_api("local", "LocalModelAPI")
	
	# Set default API
	if api_connections.has("claude"):
		active_api = "claude"
	elif api_connections.has("openai"):
		active_api = "openai"
	elif api_connections.has("gemini"):
		active_api = "gemini"
	
	print("Registered " + str(api_connections.size()) + " APIs")

func check_and_register_api(api_id, class_name):
	# Try to find the API class
	var api_class = ClassDB.get_global(class_name)
	if api_class:
		var api_instance = api_class.new()
		register_api(api_id, api_instance)
		return true
	
	# Try to find as a node
	if has_node("/root/" + class_name):
		var api_node = get_node("/root/" + class_name)
		register_api(api_id, api_node)
		return true
		
	return false

func register_api(api_id, handler):
	api_connections[api_id] = {
		"id": api_id,
		"handler": handler,
		"connected": false,
		"last_used": 0
	}
	
	// Try to connect
	connect_to_api(api_id)
	
	return true

func connect_to_api(api_id):
	if not api_connections.has(api_id):
		print("API not registered: " + api_id)
		return false
	
	var api = api_connections[api_id]
	
	print("Connecting to API: " + api_id)
	
	var success = false
	
	if api.handler.has_method("connect"):
		success = api.handler.connect()
	elif api.handler.has_method("authenticate"):
		success = api.handler.authenticate()
	else:
		// Assume connected if no connect method
		success = true
	
	if success:
		api.connected = true
		api.last_used = OS.get_unix_time()
		print("Connected to API: " + api_id)
	else:
		print("Failed to connect to API: " + api_id)
	
	return success

# Data utility functions
func compress_data(data, level):
	# In a real implementation, this would compress the data
	# For this example, we'll just mark it as compressed
	return {
		"compressed": true,
		"compression_level": level,
		"original_data": data
	}

func decompress_data(compressed_data):
	# In a real implementation, this would decompress the data
	if compressed_data.has("original_data"):
		return compressed_data.original_data
	
	return null

func encrypt_data(data, target_device_id):
	# In a real implementation, this would encrypt the data
	# For this example, we'll just mark it as encrypted
	return {
		"encrypted": true,
		"target_device": target_device_id,
		"original_data": data
	}

func decrypt_data(encrypted_data, source_device_id):
	# In a real implementation, this would decrypt the data
	if encrypted_data.has("original_data"):
		return encrypted_data.original_data
	
	return null

func calculate_data_size(data):
	# Simple approximation of data size
	var json_data = JSON.print(data)
	return json_data.length()

# Configuration functions
func load_settings():
	var file = File.new()
	if not file.file_exists("user://cross_device_settings.json"):
		return
	
	file.open("user://cross_device_settings.json", File.READ)
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.parse(content)
	if json.error == OK:
		var settings = json.result
		
		if settings.has("auto_connect"):
			auto_connect = settings.auto_connect
		
		if settings.has("allow_remote_control"):
			allow_remote_control = settings.allow_remote_control
		
		if settings.has("encryption_enabled"):
			encryption_enabled = settings.encryption_enabled
		
		if settings.has("compression_level"):
			compression_level = settings.compression_level
		
		if settings.has("transfer_chunk_size"):
			transfer_chunk_size = settings.transfer_chunk_size
		
		if settings.has("local_device_id") and settings.local_device_id != "":
			local_device_id = settings.local_device_id
	
	// Load known devices
	load_known_devices()

func save_settings():
	var settings = {
		"auto_connect": auto_connect,
		"allow_remote_control": allow_remote_control,
		"encryption_enabled": encryption_enabled,
		"compression_level": compression_level,
		"transfer_chunk_size": transfer_chunk_size,
		"local_device_id": local_device_id
	}
	
	var file = File.new()
	file.open("user://cross_device_settings.json", File.WRITE)
	file.store_string(JSON.print(settings))
	file.close()
	
	// Save known devices
	save_known_devices()

func load_known_devices():
	var known_devices = {}
	
	var file = File.new()
	if not file.file_exists("user://known_devices.json"):
		return known_devices
	
	file.open("user://known_devices.json", File.READ)
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.parse(content)
	if json.error == OK:
		known_devices = json.result
	
	return known_devices

func save_known_devices():
	var devices_to_save = {}
	
	for id in connected_devices:
		var device = connected_devices[id]
		
		devices_to_save[id] = {
			"id": id,
			"name": device.name,
			"address": device.address,
			"connection_type": device.connection_type,
			"last_seen": OS.get_unix_time()
		}
	
	var file = File.new()
	file.open("user://known_devices.json", File.WRITE)
	file.store_string(JSON.print(devices_to_save))
	file.close()

# Pool management
func ensure_transfers_pool():
	if not data_pool_manager:
		return null
	
	// Check if transfers pool exists
	var transfers_pool_id = null
	
	for pool_id in data_pool_manager.active_pools:
		var pool = data_pool_manager.active_pools[pool_id]
		if pool.name == "DeviceTransfers":
			transfers_pool_id = pool_id
			break
	
	// Create if not exists
	if transfers_pool_id == null:
		transfers_pool_id = data_pool_manager.create_data_pool("DeviceTransfers", "system", "Temporary storage for cross-device transfers")
		
		// Attach Google Drive if available
		for drive_id in data_pool_manager.drive_connectors:
			if drive_id.begins_with("google_drive_"):
				data_pool_manager.attach_drive_to_pool(transfers_pool_id, drive_id, {"priority": 10})
				break
	}
	
	return transfers_pool_id

# Utility functions
func generate_transfer_id():
	return "transfer_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)

func get_time_ago(seconds):
	if seconds < 60:
		return str(seconds) + " seconds"
	elif seconds < 3600:
		return str(int(seconds / 60)) + " minutes"
	elif seconds < 86400:
		return str(int(seconds / 3600)) + " hours"
	else:
		return str(int(seconds / 86400)) + " days"