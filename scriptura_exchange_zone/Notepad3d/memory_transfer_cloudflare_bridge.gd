extends Node

class_name MemoryTransferCloudFlareBridge

# This class bridges the Memory Transfer System with CloudFlare Workers
# to enable cross-device memory transfer over the web

signal bridge_connected(success, worker_url)
signal bridge_disconnected
signal worker_message_received(message_type, content)
signal auth_status_changed(status, message)
signal sync_status_changed(status, message)

# CloudFlare connection parameters
const DEFAULT_WORKER_URL = "https://memory-transfer.EXAMPLE-DOMAIN.workers.dev"
const API_VERSION = "v1"
const PING_INTERVAL = 60 # Seconds between ping messages
const RECONNECT_ATTEMPTS = 3
const RECONNECT_DELAY = 5 # Seconds between reconnect attempts

# Authentication states
enum AuthState {
	UNAUTHENTICATED,
	AUTHENTICATING,
	AUTHENTICATED,
	FAILED,
	EXPIRED
}

# Connection states
enum ConnectionState {
	DISCONNECTED,
	CONNECTING,
	CONNECTED,
	RECONNECTING,
	ERROR
}

# Memory transfer system
var memory_transfer_system

# Connection management
var http_request
var websocket_client
var worker_url = DEFAULT_WORKER_URL
var api_key = ""
var device_token = ""
var connection_state = ConnectionState.DISCONNECTED
var auth_state = AuthState.UNAUTHENTICATED
var reconnect_count = 0
var last_ping_time = 0
var ping_timer

# Device info
var device_id = ""
var device_type = "desktop"

# Config
var config = {
	"use_websocket": true,
	"enable_encryption": true,
	"auto_reconnect": true,
	"max_batch_size_mb": 5,
	"debug_mode": false,
	"memory_stats_interval": 300, # 5 minutes
	"heartbeat_enabled": true
}

func _ready():
	# Initialize components
	_initialize_components()
	
	# Create ping timer
	ping_timer = Timer.new()
	ping_timer.wait_time = PING_INTERVAL
	ping_timer.autostart = false
	ping_timer.timeout.connect(_on_ping_timer)
	add_child(ping_timer)
	
	# Auto-connect if API key is set
	if not api_key.empty():
		connect_to_worker()

func _initialize_components():
	# Find memory transfer system
	if has_node("/root/MemoryTransferSystem") or get_node_or_null("/root/MemoryTransferSystem"):
		memory_transfer_system = get_node("/root/MemoryTransferSystem")
		print("Connected to MemoryTransferSystem")
	else:
		print("WARNING: MemoryTransferSystem not found")
	
	# Create HTTP request
	http_request = HTTPRequest.new()
	http_request.timeout = 30 # 30 second timeout
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)
	
	# Initialize device info
	if memory_transfer_system and memory_transfer_system.cross_device_connector:
		device_id = memory_transfer_system.cross_device_connector.system_id
	else:
		device_id = _generate_device_id()
	
	device_type = _detect_device_type()
	
	print("Device ID: " + device_id)
	print("Device Type: " + device_type)

func set_api_key(key):
	api_key = key
	print("API key set")

func set_worker_url(url):
	worker_url = url
	print("Worker URL set to: " + url)

func connect_to_worker():
	if connection_state == ConnectionState.CONNECTED:
		print("Already connected to worker")
		return true
	
	if api_key.empty():
		print("ERROR: API key not set")
		return false
	
	print("Connecting to CloudFlare Worker at: " + worker_url)
	connection_state = ConnectionState.CONNECTING
	
	# Check if using WebSocket or HTTP
	if config.use_websocket:
		return _connect_websocket()
	else:
		return _connect_http()

func disconnect_from_worker():
	if connection_state == ConnectionState.DISCONNECTED:
		return true
	
	print("Disconnecting from CloudFlare Worker")
	
	if config.use_websocket and websocket_client:
		websocket_client.close()
	
	connection_state = ConnectionState.DISCONNECTED
	auth_state = AuthState.UNAUTHENTICATED
	
	# Stop ping timer
	ping_timer.stop()
	
	emit_signal("bridge_disconnected")
	return true

func _connect_websocket():
	# Create WebSocket client if needed
	if not websocket_client:
		websocket_client = WebSocketClient.new()
		websocket_client.connection_closed.connect(_on_ws_connection_closed)
		websocket_client.connection_error.connect(_on_ws_connection_error)
		websocket_client.connection_established.connect(_on_ws_connection_established)
		websocket_client.data_received.connect(_on_ws_data_received)
	
	# Connect to the worker
	var url = worker_url + "/api/" + API_VERSION + "/ws"
	
	# Add API key as query parameter
	url += "?api_key=" + api_key
	
	var error = websocket_client.connect_to_url(url)
	
	if error != OK:
		print("ERROR: Failed to connect to WebSocket: " + str(error))
		connection_state = ConnectionState.ERROR
		emit_signal("bridge_connected", false, worker_url)
		return false
	
	print("WebSocket connecting...")
	return true

func _connect_http():
	# Use HTTP request to authenticate first
	var url = worker_url + "/api/" + API_VERSION + "/auth"
	var headers = [
		"Content-Type: application/json",
		"X-API-Key: " + api_key
	]
	
	var body = JSON.stringify({
		"device_id": device_id,
		"device_type": device_type,
		"app_version": "1.0.0"
	})
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		print("ERROR: HTTP Request failed: " + str(error))
		connection_state = ConnectionState.ERROR
		emit_signal("bridge_connected", false, worker_url)
		return false
	
	auth_state = AuthState.AUTHENTICATING
	emit_signal("auth_status_changed", auth_state, "Authenticating with worker")
	
	print("HTTP authentication request sent")
	return true

func _process(delta):
	# Process WebSocket client if connected
	if config.use_websocket and websocket_client and connection_state == ConnectionState.CONNECTED:
		websocket_client.poll()
		
		# Check if we need to send a ping
		if config.heartbeat_enabled:
			var current_time = Time.get_unix_time_from_system()
			if current_time - last_ping_time >= PING_INTERVAL:
				_send_ping()
				last_ping_time = current_time

func sync_memory_fragments():
	if connection_state != ConnectionState.CONNECTED:
		print("ERROR: Not connected to worker")
		return false
	
	if auth_state != AuthState.AUTHENTICATED:
		print("ERROR: Not authenticated")
		return false
	
	print("Syncing memory fragments with CloudFlare Worker")
	emit_signal("sync_status_changed", "syncing", "Starting memory fragment sync")
	
	# Create a memory snapshot to sync
	var snapshot = null
	if memory_transfer_system:
		snapshot = memory_transfer_system.create_memory_snapshot("cloud_sync_" + str(Time.get_unix_time_from_system()))
	
	if not snapshot:
		print("ERROR: Failed to create memory snapshot")
		emit_signal("sync_status_changed", "error", "Failed to create memory snapshot")
		return false
	
	# Check if using WebSocket or HTTP
	if config.use_websocket:
		return _sync_via_websocket(snapshot)
	else:
		return _sync_via_http(snapshot)

func _sync_via_websocket(snapshot):
	if not websocket_client or connection_state != ConnectionState.CONNECTED:
		return false
	
	# Split snapshot into batches if needed
	var json_data = JSON.stringify(snapshot)
	var total_size_mb = json_data.length() / (1024.0 * 1024.0)
	
	if total_size_mb <= config.max_batch_size_mb:
		# Small enough to send as one message
		var sync_message = {
			"type": "memory_sync",
			"timestamp": Time.get_unix_time_from_system(),
			"device_id": device_id,
			"snapshot": snapshot,
			"batch_info": {
				"total_batches": 1,
				"batch_index": 0,
				"is_final": true
			}
		}
		
		websocket_client.send_text(JSON.stringify(sync_message))
		print("Sent memory snapshot via WebSocket: " + str(snapshot.fragments_count) + " fragments")
		return true
	else:
		# Split into batches
		var batch_size = int(config.max_batch_size_mb * 1024 * 1024) # bytes per batch
		var fragments = snapshot.fragments
		var fragments_per_batch = int(fragments.size() * batch_size / json_data.length())
		
		if fragments_per_batch < 1:
			fragments_per_batch = 1
		
		var total_batches = ceil(float(fragments.size()) / fragments_per_batch)
		
		print("Splitting memory sync into " + str(total_batches) + " batches")
		
		# Send each batch
		for i in range(total_batches):
			var start_idx = i * fragments_per_batch
			var end_idx = min(start_idx + fragments_per_batch, fragments.size())
			var batch_fragments = fragments.slice(start_idx, end_idx - 1)
			
			var batch_snapshot = snapshot.duplicate(true)
			batch_snapshot.fragments = batch_fragments
			batch_snapshot.fragments_count = batch_fragments.size()
			
			var sync_message = {
				"type": "memory_sync",
				"timestamp": Time.get_unix_time_from_system(),
				"device_id": device_id,
				"snapshot": batch_snapshot,
				"batch_info": {
					"total_batches": total_batches,
					"batch_index": i,
					"is_final": i == total_batches - 1
				}
			}
			
			websocket_client.send_text(JSON.stringify(sync_message))
			print("Sent memory snapshot batch " + str(i+1) + "/" + str(total_batches) + 
				": " + str(batch_fragments.size()) + " fragments")
			
			# Small delay between batches to avoid overwhelming the worker
			OS.delay_msec(100)
		
		return true

func _sync_via_http(snapshot):
	var url = worker_url + "/api/" + API_VERSION + "/sync"
	var headers = [
		"Content-Type: application/json",
		"X-API-Key: " + api_key,
		"X-Device-Token: " + device_token
	]
	
	# Need to split snapshot if it's too large
	var json_data = JSON.stringify(snapshot)
	var total_size_mb = json_data.length() / (1024.0 * 1024.0)
	
	if total_size_mb <= config.max_batch_size_mb:
		# Send as one request
		var body = JSON.stringify({
			"device_id": device_id,
			"snapshot": snapshot,
			"timestamp": Time.get_unix_time_from_system()
		})
		
		var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
		
		if error != OK:
			print("ERROR: HTTP sync request failed: " + str(error))
			emit_signal("sync_status_changed", "error", "Failed to send HTTP sync request")
			return false
		
		print("HTTP sync request sent: " + str(snapshot.fragments_count) + " fragments")
		return true
	else:
		# Need to split into multiple requests
		# This would be more complex to implement with HTTP
		# For now, log an error
		print("ERROR: Snapshot too large for HTTP sync: " + str(total_size_mb) + "MB")
		emit_signal("sync_status_changed", "error", "Snapshot too large for HTTP sync")
		return false

func request_cloud_memories():
	if connection_state != ConnectionState.CONNECTED:
		print("ERROR: Not connected to worker")
		return false
	
	if auth_state != AuthState.AUTHENTICATED:
		print("ERROR: Not authenticated")
		return false
	
	print("Requesting cloud memories from worker")
	
	# Different approach based on connection type
	if config.use_websocket:
		var request_message = {
			"type": "request_memories",
			"timestamp": Time.get_unix_time_from_system(),
			"device_id": device_id
		}
		
		websocket_client.send_text(JSON.stringify(request_message))
		return true
	else:
		var url = worker_url + "/api/" + API_VERSION + "/memories"
		var headers = [
			"Content-Type: application/json",
			"X-API-Key: " + api_key,
			"X-Device-Token: " + device_token
		]
		
		var error = http_request.request(url, headers, HTTPClient.METHOD_GET)
		
		if error != OK:
			print("ERROR: HTTP memories request failed: " + str(error))
			return false
		
		return true

func send_device_stats():
	if connection_state != ConnectionState.CONNECTED:
		print("ERROR: Not connected to worker")
		return false
	
	if auth_state != AuthState.AUTHENTICATED:
		print("ERROR: Not authenticated")
		return false
	
	# Get current memory stats
	var stats = null
	if memory_transfer_system:
		stats = memory_transfer_system._update_device_memory_stats()
	
	if not stats:
		print("ERROR: Failed to get device memory stats")
		return false
	
	print("Sending device stats to worker")
	
	# Different approach based on connection type
	if config.use_websocket:
		var stats_message = {
			"type": "device_stats",
			"timestamp": Time.get_unix_time_from_system(),
			"device_id": device_id,
			"stats": stats
		}
		
		websocket_client.send_text(JSON.stringify(stats_message))
		return true
	else:
		var url = worker_url + "/api/" + API_VERSION + "/stats"
		var headers = [
			"Content-Type: application/json",
			"X-API-Key: " + api_key,
			"X-Device-Token: " + device_token
		]
		
		var body = JSON.stringify({
			"device_id": device_id,
			"stats": stats,
			"timestamp": Time.get_unix_time_from_system()
		})
		
		var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
		
		if error != OK:
			print("ERROR: HTTP stats request failed: " + str(error))
			return false
		
		return true

# Internal helper methods

func _generate_device_id():
	var os_name = OS.get_name()
	var unix_time = Time.get_unix_time_from_system()
	var random_value = randi() % 10000
	
	return os_name + "_" + str(unix_time) + "_" + str(random_value)

func _detect_device_type():
	var os_name = OS.get_name()
	
	match os_name:
		"Android", "iOS":
			return "phone"
		"HTML5":
			return "browser"
		_:
			return "desktop"

func _send_ping():
	if not config.use_websocket or not websocket_client or connection_state != ConnectionState.CONNECTED:
		return
	
	var ping_message = {
		"type": "ping",
		"timestamp": Time.get_unix_time_from_system(),
		"device_id": device_id
	}
	
	websocket_client.send_text(JSON.stringify(ping_message))
	last_ping_time = Time.get_unix_time_from_system()
	
	if config.debug_mode:
		print("Sent ping")

func _handle_identify_response(response):
	if response.has("status") and response.status == "success":
		# Extract device token
		if response.has("device_token"):
			device_token = response.device_token
		
		connection_state = ConnectionState.CONNECTED
		auth_state = AuthState.AUTHENTICATED
		reconnect_count = 0
		
		# Start ping timer if using WebSocket
		if config.use_websocket:
			ping_timer.start()
		
		emit_signal("bridge_connected", true, worker_url)
		emit_signal("auth_status_changed", auth_state, "Authenticated with worker")
		
		print("Successfully connected to CloudFlare Worker")
		
		# Send device stats
		send_device_stats()
		
		return true
	else:
		var error_msg = "Authentication failed"
		if response.has("message"):
			error_msg = response.message
		
		connection_state = ConnectionState.ERROR
		auth_state = AuthState.FAILED
		
		emit_signal("bridge_connected", false, worker_url)
		emit_signal("auth_status_changed", auth_state, error_msg)
		
		print("ERROR: " + error_msg)
		return false

func _handle_sync_response(response):
	if response.has("status") and response.status == "success":
		var message = "Sync completed successfully"
		if response.has("message"):
			message = response.message
		
		emit_signal("sync_status_changed", "success", message)
		print("Memory sync completed: " + message)
		return true
	else:
		var error_msg = "Sync failed"
		if response.has("message"):
			error_msg = response.message
		
		emit_signal("sync_status_changed", "error", error_msg)
		print("ERROR: Memory sync failed: " + error_msg)
		return false

func _handle_memories_response(response):
	if response.has("status") and response.status == "success" and response.has("memories"):
		var memories = response.memories
		
		print("Received " + str(memories.size()) + " memories from cloud")
		
		# Process received memories
		if memory_transfer_system:
			for memory in memories:
				# Apply to local system (implementation depends on memory format)
				_apply_cloud_memory(memory)
		
		emit_signal("worker_message_received", "memories", memories)
		return true
	else:
		var error_msg = "Failed to get memories"
		if response.has("message"):
			error_msg = response.message
		
		print("ERROR: " + error_msg)
		return false

func _apply_cloud_memory(memory):
	# Implementation depends on the memory format
	# For now, a simple placeholder that checks the type
	
	if memory.has("type"):
		match memory.type:
			"snapshot":
				# Apply snapshot
				if memory_transfer_system and memory.has("data"):
					# Create temporary file
					var temp_path = "user://temp_cloud_snapshot.json"
					var file = FileAccess.open(temp_path, FileAccess.WRITE)
					if file:
						file.store_string(JSON.stringify(memory.data))
						file.close()
						
						# Load snapshot
						memory_transfer_system.load_memory_snapshot(temp_path)
						
						# Clean up
						var dir = DirAccess.open("user://")
						if dir.file_exists(temp_path):
							dir.remove(temp_path)
			
			"fragment":
				# Add single fragment
				if memory_transfer_system and memory_transfer_system.drive_memory_connector and memory.has("data"):
					memory_transfer_system.drive_memory_connector.save_memory_fragment(memory.data)
			
			_:
				print("Unknown cloud memory type: " + memory.type)

# Signal handlers

func _on_http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("ERROR: HTTP request failed with result: " + str(result))
		connection_state = ConnectionState.ERROR
		
		if auth_state == AuthState.AUTHENTICATING:
			auth_state = AuthState.FAILED
			emit_signal("auth_status_changed", auth_state, "HTTP request failed")
		
		emit_signal("bridge_connected", false, worker_url)
		return
	
	# Parse response
	var response_text = body.get_string_from_utf8()
	var test_json_conv = JSON.new()
	var error = test_json_conv.parse(response_text)
	
	if error != OK:
		print("ERROR: Failed to parse HTTP response: " + response_text)
		connection_state = ConnectionState.ERROR
		
		if auth_state == AuthState.AUTHENTICATING:
			auth_state = AuthState.FAILED
			emit_signal("auth_status_changed", auth_state, "Invalid response format")
		
		emit_signal("bridge_connected", false, worker_url)
		return
	
	var response = test_json_conv.get_data()
	
	# Handle response based on current state
	if auth_state == AuthState.AUTHENTICATING:
		_handle_identify_response(response)
	elif response.has("type"):
		match response.type:
			"sync_response":
				_handle_sync_response(response)
			
			"memories_response":
				_handle_memories_response(response)
			
			_:
				print("Unknown response type: " + response.type)
				emit_signal("worker_message_received", response.type, response)

func _on_ws_connection_established(protocol):
	print("WebSocket connection established")
	
	# Send identify message
	var identify_message = {
		"type": "identify",
		"device_id": device_id,
		"device_type": device_type,
		"api_key": api_key,
		"app_version": "1.0.0",
		"timestamp": Time.get_unix_time_from_system()
	}
	
	websocket_client.send_text(JSON.stringify(identify_message))
	auth_state = AuthState.AUTHENTICATING
	emit_signal("auth_status_changed", auth_state, "Authenticating with worker")
	
	print("Sent identify message")

func _on_ws_connection_closed(was_clean_close):
	print("WebSocket connection closed. Clean: " + str(was_clean_close))
	
	connection_state = ConnectionState.DISCONNECTED
	ping_timer.stop()
	
	emit_signal("bridge_disconnected")
	
	# Auto-reconnect if enabled
	if config.auto_reconnect and reconnect_count < RECONNECT_ATTEMPTS:
		reconnect_count += 1
		connection_state = ConnectionState.RECONNECTING
		
		print("Attempting to reconnect (" + str(reconnect_count) + "/" + str(RECONNECT_ATTEMPTS) + ")...")
		
		# Create reconnect timer
		var timer = Timer.new()
		timer.wait_time = RECONNECT_DELAY
		timer.one_shot = true
		timer.timeout.connect(_on_reconnect_timer)
		add_child(timer)
		timer.start()

func _on_ws_connection_error():
	print("WebSocket connection error")
	
	connection_state = ConnectionState.ERROR
	
	if auth_state == AuthState.AUTHENTICATING:
		auth_state = AuthState.FAILED
		emit_signal("auth_status_changed", auth_state, "WebSocket connection error")
	
	emit_signal("bridge_connected", false, worker_url)
	
	# Auto-reconnect if enabled
	if config.auto_reconnect and reconnect_count < RECONNECT_ATTEMPTS:
		reconnect_count += 1
		connection_state = ConnectionState.RECONNECTING
		
		print("Attempting to reconnect (" + str(reconnect_count) + "/" + str(RECONNECT_ATTEMPTS) + ")...")
		
		# Create reconnect timer
		var timer = Timer.new()
		timer.wait_time = RECONNECT_DELAY
		timer.one_shot = true
		timer.timeout.connect(_on_reconnect_timer)
		add_child(timer)
		timer.start()

func _on_ws_data_received():
	var data = websocket_client.get_peer(1).get_packet().get_string_from_utf8()
	
	if config.debug_mode:
		print("WebSocket data received: " + data)
	
	# Parse JSON
	var test_json_conv = JSON.new()
	var error = test_json_conv.parse(data)
	
	if error != OK:
		print("ERROR: Failed to parse WebSocket data")
		return
	
	var message = test_json_conv.get_data()
	
	# Handle message based on type
	if message.has("type"):
		match message.type:
			"identify_response":
				_handle_identify_response(message)
			
			"pong":
				if config.debug_mode:
					print("Received pong")
			
			"sync_response":
				_handle_sync_response(message)
			
			"memories_response":
				_handle_memories_response(message)
			
			"connection_status":
				print("Connection status: " + message.status)
				emit_signal("worker_message_received", "connection_status", message)
			
			_:
				print("Unknown message type: " + message.type)
				emit_signal("worker_message_received", message.type, message)

func _on_ping_timer():
	_send_ping()

func _on_reconnect_timer():
	_connect_websocket()