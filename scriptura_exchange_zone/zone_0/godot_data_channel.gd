extends Node

class_name GodotDataChannel

# Godot Data Channel System
# Connects any device data stream to the Godot Engine across time dimensions
# Provides synchronized data flow with the 12-turn system

# Signal declarations
signal data_received(source, data_packet, timestamp)
signal dimension_changed(old_dimension, new_dimension)
signal channel_opened(device_id, channel_id)
signal channel_closed(device_id, channel_id)
signal token_advanced(token_number, dimension)

# Configuration
var config = {
	"lines_per_token": 9,
	"token_speed": 1.0,
	"auto_synchronize": true,
	"time_dilation_enabled": true,
	"persistent_channels": true,
	"channel_capacity": 12
}

# Channel states
var active_channels = {}
var channel_buffers = {}
var time_markers = {}

# Dimension tracking
var current_dimension = 3 # Default to 3D space
var current_token = 1
var tokens_completed = 0

# Turn symbols and concepts
var TURN_SYMBOLS = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ"]
var TURN_DIMENSIONS = ["1D", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "11D", "12D"]
var TURN_CONCEPTS = ["Point", "Line", "Space", "Time", "Consciousness", "Connection", "Creation", "Network", "Harmony", "Unity", "Transcendence", "Infinity"]

# Device connection registry
var connected_devices = {}

# ===== INITIALIZATION =====

func _ready():
	print("Godot Data Channel initialized")
	
	# Set up connection monitoring
	_setup_connection_monitor()
	
	# Initialize channel buffers
	_initialize_buffers()
	
	# Load channel configuration if available
	_load_config()
	
	# Connect to TurnSystem if available
	_connect_to_turn_system()

func _setup_connection_monitor():
	# Set up timer for checking device connections
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.autostart = true
	timer.connect("timeout", self, "_check_device_connections")
	add_child(timer)

func _initialize_buffers():
	# Create buffers for all 12 dimensions
	for i in range(1, 13):
		channel_buffers[i] = []
		time_markers[i] = OS.get_unix_time()

func _load_config():
	var file = File.new()
	var config_path = "user://godot_data_channel_config.json"
	
	if file.file_exists(config_path):
		file.open(config_path, File.READ)
		var text = file.get_as_text()
		file.close()
		
		var result = JSON.parse(text)
		if result.error == OK:
			# Apply saved configuration
			var saved_config = result.result
			for key in saved_config.keys():
				if config.has(key):
					config[key] = saved_config[key]
			
			print("Loaded channel configuration")
		else:
			print("Error parsing channel configuration")

func _connect_to_turn_system():
	# Find TurnSystem if present in the scene tree
	var turn_system = get_node_or_null("/root/TurnSystem")
	
	if turn_system:
		# Connect to the turn system signals
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")
		turn_system.connect("token_advanced", self, "_on_token_advanced")
		
		# Sync current dimension
		current_dimension = turn_system.current_dimension
		print("Connected to Turn System, dimension: " + str(current_dimension))
	else:
		print("Turn System not found, operating in standalone mode")

# ===== CHANNEL MANAGEMENT =====

# Open a data channel for a device
func open_channel(device_id, device_type, auth_token = ""):
	# Generate unique channel ID
	var channel_id = _generate_channel_id(device_id)
	
	# Create channel data structure
	var channel = {
		"id": channel_id,
		"device_id": device_id,
		"device_type": device_type,
		"status": "active",
		"opened_at": OS.get_unix_time(),
		"dimension": current_dimension,
		"auth_token": auth_token,
		"packet_count": 0
	}
	
	# Store in active channels
	active_channels[channel_id] = channel
	
	# Register connected device
	connected_devices[device_id] = {
		"last_seen": OS.get_unix_time(),
		"type": device_type,
		"channels": [channel_id]
	}
	
	# Emit signal
	emit_signal("channel_opened", device_id, channel_id)
	
	print("Channel opened for device: " + device_id + " (Type: " + device_type + ")")
	
	return channel_id

# Close a data channel
func close_channel(channel_id):
	if active_channels.has(channel_id):
		var channel = active_channels[channel_id]
		
		# Update status
		channel.status = "closed"
		channel.closed_at = OS.get_unix_time()
		
		# Update device registry
		if connected_devices.has(channel.device_id):
			var device = connected_devices[channel.device_id]
			if device.channels.has(channel_id):
				device.channels.erase(channel_id)
			
			# Remove device if no more channels
			if device.channels.empty() and not config.persistent_channels:
				connected_devices.erase(channel.device_id)
		
		# Emit signal
		emit_signal("channel_closed", channel.device_id, channel_id)
		
		print("Channel closed: " + channel_id)
		
		return true
	
	return false

# Get list of all active channels
func get_active_channels():
	var active = []
	
	for channel_id in active_channels.keys():
		var channel = active_channels[channel_id]
		if channel.status == "active":
			active.append(channel)
	
	return active

# Check if device is connected
func is_device_connected(device_id):
	return connected_devices.has(device_id)

# ===== DATA TRANSMISSION =====

# Send data packet through a channel
func send_data(channel_id, data, metadata = {}):
	if not active_channels.has(channel_id):
		return false
	
	var channel = active_channels[channel_id]
	
	# Verify channel is active
	if channel.status != "active":
		return false
	
	# Create data packet
	var packet = {
		"id": _generate_packet_id(),
		"timestamp": OS.get_datetime(),
		"source": channel.device_id,
		"dimension": current_dimension,
		"token": current_token,
		"data": data,
		"metadata": metadata
	}
	
	# Process packet based on dimension rules
	_process_packet(packet, channel)
	
	# Update packet count
	channel.packet_count += 1
	
	# Update last seen
	connected_devices[channel.device_id].last_seen = OS.get_unix_time()
	
	return true

# Receive data packet from external source
func receive_data(device_id, data, metadata = {}):
	# Get channel for device
	var channel_id = null
	
	if connected_devices.has(device_id):
		var device = connected_devices[device_id]
		if not device.channels.empty():
			channel_id = device.channels[0]
	
	# Create channel if needed and allowed
	if channel_id == null:
		channel_id = open_channel(device_id, metadata.get("device_type", "unknown"))
	
	# Forward to send_data once we have a channel
	return send_data(channel_id, data, metadata)

# Get data for current dimension
func get_data_for_dimension(dimension = null):
	if dimension == null:
		dimension = current_dimension
	
	# Ensure dimension is in range
	if dimension < 1 or dimension > 12:
		return []
	
	return channel_buffers[dimension]

# Clear data for a specific dimension
func clear_dimension_data(dimension):
	if dimension >= 1 and dimension <= 12:
		channel_buffers[dimension] = []
		return true
	
	return false

# Process incoming packet according to dimension rules
func _process_packet(packet, channel):
	var dimension = current_dimension
	
	# Apply dimension-specific modifications
	match dimension:
		1: # Point - store only the most recent packet per device
			# Remove any existing packets from this device
			var buffer = channel_buffers[dimension]
			for i in range(buffer.size() - 1, -1, -1):
				if buffer[i].source == packet.source:
					buffer.remove(i)
			
			# Add new packet
			channel_buffers[dimension].append(packet)
			
		2: # Line - packets flow in linear sequence
			# Add packet in order
			channel_buffers[dimension].append(packet)
			
			# Enforce maximum buffer length for line dimension
			if channel_buffers[dimension].size() > config.channel_capacity * 2:
				channel_buffers[dimension].pop_front()
			
		3: # Space - regular 3D space processing
			# Store packet with full metadata
			channel_buffers[dimension].append(packet)
			
		4: # Time - enable time-based lookups
			# Add timestamp marker
			packet.time_index = OS.get_unix_time()
			channel_buffers[dimension].append(packet)
			time_markers[dimension] = packet.time_index
			
		5: # Consciousness - enable awareness of other packets
			# Add self-awareness references
			packet.awareness = {
				"dimension": dimension,
				"token": current_token,
				"total_packets": channel_buffers[dimension].size(),
				"device_count": connected_devices.size()
			}
			channel_buffers[dimension].append(packet)
			
		6: # Connection - link related data across dimensions
			# Add connection references
			packet.connections = []
			
			# Look for related packets in other dimensions
			for d in range(1, 13):
				if d == dimension:
					continue
				
				for p in channel_buffers[d]:
					if p.source == packet.source:
						packet.connections.append({
							"dimension": d,
							"packet_id": p.id,
							"timestamp": p.timestamp
						})
						break
			
			channel_buffers[dimension].append(packet)
			
		7: # Creation - enable data transformation
			# Add transformation capabilities
			if packet.data is Dictionary:
				# Apply creative transformation based on data type
				if packet.data.has("text"):
					packet.data.word_count = packet.data.text.split(" ").size()
				elif packet.data.has("value") and packet.data.value is int:
					packet.data.binary = "%b" % packet.data.value
			
			channel_buffers[dimension].append(packet)
			
		8: # Network - track relationship between all data points
			# Build network graph
			packet.network = {
				"connections": connected_devices.size(),
				"position": channel_buffers[dimension].size(),
				"links": []
			}
			
			# Create links to related packets
			var link_count = min(3, channel_buffers[dimension].size())
			for i in range(link_count):
				if not channel_buffers[dimension].empty():
					var index = channel_buffers[dimension].size() - 1 - i
					if index >= 0:
						var linked_packet = channel_buffers[dimension][index]
						packet.network.links.append(linked_packet.id)
			
			channel_buffers[dimension].append(packet)
			
		9: # Harmony - balance data across channels
			# Check for imbalance across dimensions
			var max_size = 0
			var min_size = 999999
			
			for d in range(1, 13):
				var size = channel_buffers[d].size()
				max_size = max(max_size, size)
				if size > 0:
					min_size = min(min_size, size)
			
			# Calculate harmony score
			var imbalance = max_size - min_size
			packet.harmony = {
				"balance_score": clamp(1.0 - (float(imbalance) / max(1, max_size)), 0.0, 1.0),
				"imbalance": imbalance,
				"dimensions_active": 0
			}
			
			# Count active dimensions
			for d in range(1, 13):
				if channel_buffers[d].size() > 0:
					packet.harmony.dimensions_active += 1
			
			channel_buffers[dimension].append(packet)
			
		10: # Unity - combine aspects of all dimensions
			# Create unified view
			packet.unified_view = {}
			
			# Sample from each dimension
			for d in range(1, 13):
				if not channel_buffers[d].empty():
					# Get most recent packet from this dimension
					var sample = channel_buffers[d].back()
					packet.unified_view[str(d)] = {
						"id": sample.id,
						"timestamp": sample.timestamp,
						"source": sample.source
					}
			
			channel_buffers[dimension].append(packet)
			
		11: # Transcendence - exist beyond normal constraints
			# Add transcendent properties
			packet.transcended = true
			packet.accessible_in_all_dimensions = true
			
			# Add to this dimension
			channel_buffers[dimension].append(packet)
			
			# Add references to all other dimensions
			for d in range(1, 13):
				if d != dimension:
					var reference = {
						"id": packet.id + "_ref_" + str(d),
						"timestamp": packet.timestamp,
						"source": packet.source,
						"dimension": d,
						"token": current_token,
						"is_reference": true,
						"original_dimension": dimension,
						"original_id": packet.id,
						"data": packet.data
					}
					channel_buffers[d].append(reference)
			
		12: # Infinity - no limits
			# Add to all possible buffers, past and future
			packet.infinite = true
			
			# Store in all dimensions simultaneously
			for d in range(1, 13):
				var clone = packet.duplicate()
				clone.manifest_dimension = d
				channel_buffers[d].append(clone)
	
	# Emit signal for listeners
	emit_signal("data_received", packet.source, packet, OS.get_datetime())

# ===== DIMENSION MANAGEMENT =====

# Handle dimension changes
func _on_dimension_changed(new_dimension, old_dimension):
	current_dimension = new_dimension
	
	# Emit signal for listeners
	emit_signal("dimension_changed", old_dimension, new_dimension)
	
	print("Data channel dimension changed: " + str(old_dimension) + " → " + str(new_dimension) + 
		" (" + TURN_SYMBOLS[new_dimension-1] + " - " + TURN_DIMENSIONS[new_dimension-1] + " - " + TURN_CONCEPTS[new_dimension-1] + ")")

# Handle token advancement
func _on_token_advanced(token_number, dimension):
	current_token = token_number
	current_dimension = dimension
	
	# Apply time dilation if enabled
	if config.time_dilation_enabled:
		# Time flows differently in different dimensions
		match dimension:
			4: # Time dimension - accelerated token processing
				config.token_speed = 0.5
			5: # Consciousness - slower, more deliberate
				config.token_speed = 2.0
			12: # Infinity - extremely fast
				config.token_speed = 0.1
			_: # Default
				config.token_speed = 1.0
	
	# Update token counter
	if token_number == 1:
		tokens_completed += 1
	
	# Emit signal for listeners
	emit_signal("token_advanced", token_number, dimension)

# Manually change dimension
func change_dimension(new_dimension):
	if new_dimension >= 1 and new_dimension <= 12:
		var old_dimension = current_dimension
		current_dimension = new_dimension
		
		_on_dimension_changed(new_dimension, old_dimension)
		return true
	
	return false

# ===== UTILITY FUNCTIONS =====

# Generate unique channel ID
func _generate_channel_id(device_id):
	var timestamp = OS.get_unix_time()
	var random = randi() % 10000
	return device_id.substr(0, 8) + "_" + str(timestamp) + "_" + str(random)

# Generate unique packet ID
func _generate_packet_id():
	var timestamp = OS.get_unix_time()
	var random = randi() % 1000000
	return str(timestamp) + "_" + str(random)

# Check device connections periodically
func _check_device_connections():
	var current_time = OS.get_unix_time()
	var timeout_threshold = 300 # 5 minutes
	
	# Check all devices for timeout
	for device_id in connected_devices.keys():
		var device = connected_devices[device_id]
		var time_diff = current_time - device.last_seen
		
		if time_diff > timeout_threshold:
			print("Device timed out: " + device_id)
			
			# Close all channels for this device
			for channel_id in device.channels:
				if active_channels.has(channel_id):
					close_channel(channel_id)
			
			# Remove device from registry
			connected_devices.erase(device_id)

# Save current configuration
func save_config():
	var file = File.new()
	var config_path = "user://godot_data_channel_config.json"
	
	file.open(config_path, File.WRITE)
	file.store_string(JSON.print(config, "  "))
	file.close()
	
	print("Saved channel configuration")

# ===== EXTERNAL API =====

# Get current dimension info
func get_current_dimension_info():
	return {
		"number": current_dimension,
		"symbol": TURN_SYMBOLS[current_dimension-1],
		"name": TURN_DIMENSIONS[current_dimension-1],
		"concept": TURN_CONCEPTS[current_dimension-1],
		"token": current_token,
		"tokens_completed": tokens_completed,
		"active_channels": get_active_channels().size(),
		"connected_devices": connected_devices.size(),
		"data_packets": channel_buffers[current_dimension].size()
	}

# Get channel statistics
func get_channel_stats():
	var stats = {
		"total_channels": active_channels.size(),
		"active_channels": 0,
		"total_devices": connected_devices.size(),
		"packets_by_dimension": {},
		"total_packets": 0
	}
	
	# Count active channels
	for channel_id in active_channels.keys():
		if active_channels[channel_id].status == "active":
			stats.active_channels += 1
	
	# Count packets by dimension
	for d in range(1, 13):
		var count = channel_buffers[d].size()
		stats.packets_by_dimension[str(d)] = count
		stats.total_packets += count
	
	return stats

# Update configuration setting
func set_config_value(key, value):
	if config.has(key):
		config[key] = value
		save_config()
		return true
	
	return false

# Export all data for a device
func export_device_data(device_id):
	if not connected_devices.has(device_id):
		return null
	
	var export_data = {
		"device_id": device_id,
		"device_type": connected_devices[device_id].type,
		"channels": [],
		"packets": [],
		"exported_at": OS.get_datetime()
	}
	
	# Add channel information
	for channel_id in connected_devices[device_id].channels:
		if active_channels.has(channel_id):
			export_data.channels.append(active_channels[channel_id])
	
	# Collect all packets from this device
	for d in range(1, 13):
		for packet in channel_buffers[d]:
			if packet.source == device_id:
				export_data.packets.append(packet)
	
	return export_data

# Clear all data but keep configuration
func clear_all_data():
	# Reset all buffers
	for d in range(1, 13):
		channel_buffers[d] = []
	
	# Reset active channels
	active_channels = {}
	
	# Reset connected devices
	connected_devices = {}
	
	# Reset counters
	tokens_completed = 0
	
	print("All channel data cleared")