extends Node3D

class_name DataSplitterController

# ----- NODE PATHS -----
@export_node_path var notepad3d_integration_path: NodePath
@export_node_path var pitopia_main_path: NodePath
@export_node_path var console_path: NodePath
@export_node_path var data_container_path: NodePath

# ----- COMPONENT REFERENCES -----
var notepad3d_integration = null
var pitopia_main = null
var console = null
var data_container = null

# ----- CONFIGURATION -----
@export var auto_initialize: bool = true
@export var enable_debug_logs: bool = true
@export var max_data_streams: int = 9
@export var default_data_chunk_size: int = 16
@export var default_split_factor: int = 3
@export var data_visualization_enabled: bool = true

# ----- VISUAL SETTINGS -----
@export_group("Visual Settings")
@export var stream_material: StandardMaterial3D
@export var chunk_material: StandardMaterial3D
@export var connection_material: StandardMaterial3D
@export var split_effect: PackedScene
@export var merge_effect: PackedScene

# ----- STATE VARIABLES -----
var initialized: bool = false
var current_dimension: int = 3
var current_turn: int = 1
var current_reality: String = "Physical"
var current_moon_phase: int = 0

var data_streams = []
var data_chunks = {}
var data_splits = {}
var active_connections = {}
var active_visualizers = {}
var data_flow_history = []
var merge_operations = []

# Dictionary of node references for visual elements
var stream_nodes = {}
var chunk_nodes = {}
var connection_nodes = {}
var split_nodes = {}

# ----- SIGNALS -----
signal initialization_completed
signal data_stream_created(stream_id, data_type, size)
signal data_chunk_created(chunk_id, content, parent_stream)
signal data_split_created(split_id, original_chunk, resulting_chunks)
signal data_merged(merge_id, source_chunks, result_chunk)
signal data_flow_processed(flow_id, source, destination, amount)
signal dimension_changed(new_dimension, old_dimension)
signal turn_advanced(turn_number)
signal reality_changed(new_reality, old_reality)

# ----- INITIALIZATION -----
func _ready():
	if auto_initialize:
		initialize()

func initialize():
	print("DataSplitterController: Initializing...")
	
	# Resolve node paths
	_resolve_node_paths()
	
	# Create container nodes if needed
	_create_container_nodes()
	
	# Setup visualization materials
	_setup_visualization_materials()
	
	# Connect to Notepad3D and Pitopia signals
	_connect_signals()
	
	# Setup data processing system
	_initialize_data_system()
	
	# Mark as initialized
	initialized = true
	emit_signal("initialization_completed")
	
	if enable_debug_logs:
		print("DataSplitterController: Initialization complete")
		_log_message("Data Splitter System initialized. Ready to process data.")

func _resolve_node_paths():
	# Resolve Notepad3D Integration
	if notepad3d_integration_path:
		notepad3d_integration = get_node_or_null(notepad3d_integration_path)
	
	# Resolve Pitopia Main
	if pitopia_main_path:
		pitopia_main = get_node_or_null(pitopia_main_path)
	
	# Resolve Console
	if console_path:
		console = get_node_or_null(console_path)
	
	# Resolve Data Container
	if data_container_path:
		data_container = get_node_or_null(data_container_path)
	else:
		# Try to find in children
		data_container = get_node_or_null("../DataSplitterContainer")
	
	if enable_debug_logs:
		print("DataSplitterController: Node resolution results:")
		print("- Notepad3D Integration: ", "Found" if notepad3d_integration else "Not found")
		print("- Pitopia Main: ", "Found" if pitopia_main else "Not found")
		print("- Console: ", "Found" if console else "Not found")
		print("- Data Container: ", "Found" if data_container else "Not found")

func _create_container_nodes():
	# Create data container if missing
	if not data_container:
		data_container = get_node_or_null("../DataSplitterContainer")
		
		if not data_container:
			data_container = Node3D.new()
			data_container.name = "DataSplitterContainer"
			add_child(data_container)
			print("DataSplitterController: Created missing DataSplitterContainer")
	
	# Ensure all required child nodes exist
	var streams_node = data_container.get_node_or_null("DataStreams")
	if not streams_node:
		streams_node = Node3D.new()
		streams_node.name = "DataStreams"
		data_container.add_child(streams_node)
	
	var chunks_node = data_container.get_node_or_null("DataChunks")
	if not chunks_node:
		chunks_node = Node3D.new()
		chunks_node.name = "DataChunks"
		data_container.add_child(chunks_node)
	
	var connections_node = data_container.get_node_or_null("DataConnections")
	if not connections_node:
		connections_node = Node3D.new()
		connections_node.name = "DataConnections"
		data_container.add_child(connections_node)
	
	var visualizer_node = data_container.get_node_or_null("DataVisualizer")
	if not visualizer_node:
		visualizer_node = Node3D.new()
		visualizer_node.name = "DataVisualizer"
		data_container.add_child(visualizer_node)

func _setup_visualization_materials():
	# Create default materials if not provided
	if not stream_material:
		stream_material = StandardMaterial3D.new()
		stream_material.albedo_color = Color(0.2, 0.4, 0.8)
		stream_material.metallic = 0.7
		stream_material.roughness = 0.2
		stream_material.emission_enabled = true
		stream_material.emission = Color(0.3, 0.5, 0.9)
		stream_material.emission_energy = 0.5
	
	if not chunk_material:
		chunk_material = StandardMaterial3D.new()
		chunk_material.albedo_color = Color(0.8, 0.3, 0.5)
		chunk_material.metallic = 0.6
		chunk_material.roughness = 0.3
		chunk_material.emission_enabled = true
		chunk_material.emission = Color(0.9, 0.4, 0.6)
		chunk_material.emission_energy = 0.6
	
	if not connection_material:
		connection_material = StandardMaterial3D.new()
		connection_material.albedo_color = Color(0.5, 0.8, 0.3)
		connection_material.emission_enabled = true
		connection_material.emission = Color(0.6, 0.9, 0.4)
		connection_material.emission_energy = 0.7

func _connect_signals():
	# Connect to Notepad3D Integration signals
	if notepad3d_integration:
		if notepad3d_integration.has_signal("reality_changed") and not notepad3d_integration.is_connected("reality_changed", Callable(self, "_on_reality_changed")):
			notepad3d_integration.connect("reality_changed", Callable(self, "_on_reality_changed"))
		
		if notepad3d_integration.has_signal("word_manifested") and not notepad3d_integration.is_connected("word_manifested", Callable(self, "_on_word_manifested")):
			notepad3d_integration.connect("word_manifested", Callable(self, "_on_word_manifested"))
		
		if notepad3d_integration.has_signal("moon_phase_changed") and not notepad3d_integration.is_connected("moon_phase_changed", Callable(self, "_on_moon_phase_changed")):
			notepad3d_integration.connect("moon_phase_changed", Callable(self, "_on_moon_phase_changed"))
	
	# Connect to Pitopia Main signals
	if pitopia_main:
		if pitopia_main.has_signal("dimension_changed") and not pitopia_main.is_connected("dimension_changed", Callable(self, "_on_dimension_changed")):
			pitopia_main.connect("dimension_changed", Callable(self, "_on_dimension_changed"))
		
		if pitopia_main.has_signal("turn_advanced") and not pitopia_main.is_connected("turn_advanced", Callable(self, "_on_turn_advanced")):
			pitopia_main.connect("turn_advanced", Callable(self, "_on_turn_advanced"))
		
		if pitopia_main.has_signal("word_manifested") and not pitopia_main.is_connected("word_manifested", Callable(self, "_on_word_manifested")):
			pitopia_main.connect("word_manifested", Callable(self, "_on_word_manifested"))

func _initialize_data_system():
	# Create initial data streams
	for i in range(3):
		create_data_stream("stream_" + str(i), "binary", default_data_chunk_size)

# ----- DATA STREAM MANAGEMENT -----
func create_data_stream(stream_id: String, data_type: String = "binary", size: int = 16) -> Dictionary:
	# Check if already at maximum streams
	if data_streams.size() >= max_data_streams:
		if enable_debug_logs:
			print("DataSplitterController: Cannot create stream, maximum reached")
		return {"success": false, "message": "Maximum streams reached"}
	
	# Create stream data
	var stream_data = {
		"id": stream_id,
		"type": data_type,
		"size": size,
		"chunks": [],
		"created_at": Time.get_unix_time_from_system(),
		"dimension": current_dimension,
		"reality": current_reality,
		"active": true,
		"properties": {
			"flow_rate": 1.0,
			"compression_ratio": 0.8,
			"stability": 0.9,
			"entropy": 0.2
		}
	}
	
	# Add to streams
	data_streams.append(stream_data)
	
	# Create visualization
	if data_visualization_enabled:
		_create_stream_visualization(stream_data)
	
	# Emit signal
	emit_signal("data_stream_created", stream_id, data_type, size)
	
	# Add initial data chunk
	var initial_chunk = create_data_chunk(stream_id + "_chunk_0", "Initial " + data_type + " data", stream_id)
	
	if enable_debug_logs:
		print("DataSplitterController: Created stream '" + stream_id + "' with initial chunk")
	
	return {"success": true, "message": "Stream created", "stream_data": stream_data}

func create_data_chunk(chunk_id: String, content: String, parent_stream_id: String) -> Dictionary:
	# Validate parent stream
	var parent_stream = null
	for stream in data_streams:
		if stream.id == parent_stream_id:
			parent_stream = stream
			break
	
	if not parent_stream:
		return {"success": false, "message": "Parent stream not found"}
	
	# Create chunk data
	var chunk_data = {
		"id": chunk_id,
		"content": content,
		"parent_stream": parent_stream_id,
		"size": content.length() + randi_range(5, 15), # Some randomness
		"created_at": Time.get_unix_time_from_system(),
		"dimension": current_dimension,
		"reality": current_reality,
		"properties": {
			"entropy": randf_range(0.1, 0.9),
			"complexity": randf_range(0.2, 0.8),
			"coherence": randf_range(0.4, 0.9),
			"stability": randf_range(0.5, 1.0)
		}
	}
	
	# Add to chunks dictionary
	data_chunks[chunk_id] = chunk_data
	
	# Add to parent stream chunks list
	parent_stream.chunks.append(chunk_id)
	
	# Create visualization
	if data_visualization_enabled:
		_create_chunk_visualization(chunk_data)
	
	# Emit signal
	emit_signal("data_chunk_created", chunk_id, content, parent_stream_id)
	
	if enable_debug_logs:
		print("DataSplitterController: Created chunk '" + chunk_id + "' in stream '" + parent_stream_id + "'")
	
	return {"success": true, "message": "Data chunk created", "chunk_data": chunk_data}

func split_data_chunk(chunk_id: String, split_factor: int = -1) -> Dictionary:
	# Validate chunk
	if not data_chunks.has(chunk_id):
		return {"success": false, "message": "Chunk not found"}
	
	# Get chunk data
	var chunk_data = data_chunks[chunk_id]
	
	# Use default split factor if not specified
	if split_factor <= 0:
		split_factor = default_split_factor
	
	# Create split id
	var split_id = "split_" + chunk_id + "_" + str(Time.get_unix_time_from_system())
	
	# Generate content divisions
	var content = chunk_data.content
	var content_parts = []
	
	# Try to split content intelligently
	if content.find(" ") >= 0:
		# Split by words
		var words = content.split(" ", false)
		
		# Calculate words per part
		var words_per_part = ceil(float(words.size()) / split_factor)
		
		# Create parts
		for i in range(split_factor):
			var start_idx = i * words_per_part
			var end_idx = min(start_idx + words_per_part, words.size())
			
			if start_idx >= words.size():
				break
			
			var part_words = words.slice(start_idx, end_idx)
			content_parts.append(" ".join(part_words))
	else:
		# Split by characters
		var chars_per_part = ceil(float(content.length()) / split_factor)
		
		for i in range(split_factor):
			var start_idx = i * chars_per_part
			var end_idx = min(start_idx + chars_per_part, content.length())
			
			if start_idx >= content.length():
				break
			
			content_parts.append(content.substr(start_idx, end_idx - start_idx))
	
	# Create resulting chunks
	var resulting_chunks = []
	for i in range(content_parts.size()):
		var sub_chunk_id = chunk_id + "_sub_" + str(i)
		var sub_content = content_parts[i]
		
		# Create new chunk
		var result = create_data_chunk(sub_chunk_id, sub_content, chunk_data.parent_stream)
		if result.success:
			resulting_chunks.append(sub_chunk_id)
	
	# Create split data
	var split_data = {
		"id": split_id,
		"original_chunk": chunk_id,
		"resulting_chunks": resulting_chunks,
		"factor": split_factor,
		"created_at": Time.get_unix_time_from_system(),
		"dimension": current_dimension,
		"reality": current_reality
	}
	
	# Add to splits
	data_splits[split_id] = split_data
	
	# Create visualization effect
	if data_visualization_enabled:
		_create_split_visualization(split_data)
	
	# Connect resulting chunks visually
	for sub_chunk_id in resulting_chunks:
		_create_connection(chunk_id, sub_chunk_id, "split")
	
	# Emit signal
	emit_signal("data_split_created", split_id, chunk_id, resulting_chunks)
	
	if enable_debug_logs:
		print("DataSplitterController: Split chunk '" + chunk_id + "' into " + str(resulting_chunks.size()) + " parts")
	
	return {"success": true, "message": "Data chunk split", "split_data": split_data, "resulting_chunks": resulting_chunks}

func merge_data_chunks(chunk_ids: Array, merge_type: String = "concatenate") -> Dictionary:
	# Validate chunks
	for chunk_id in chunk_ids:
		if not data_chunks.has(chunk_id):
			return {"success": false, "message": "Chunk '" + chunk_id + "' not found"}
	
	if chunk_ids.size() < 2:
		return {"success": false, "message": "Need at least 2 chunks to merge"}
	
	# Get first chunk to determine parent stream
	var first_chunk = data_chunks[chunk_ids[0]]
	var parent_stream_id = first_chunk.parent_stream
	
	# Check if all chunks belong to the same parent stream
	for chunk_id in chunk_ids:
		if data_chunks[chunk_id].parent_stream != parent_stream_id:
			return {"success": false, "message": "All chunks must belong to the same stream"}
	
	# Create merge id
	var merge_id = "merge_" + str(Time.get_unix_time_from_system())
	
	# Perform merge based on merge type
	var merged_content = ""
	
	if merge_type == "concatenate":
		# Simple concatenation with spaces
		for chunk_id in chunk_ids:
			if merged_content.length() > 0:
				merged_content += " "
			merged_content += data_chunks[chunk_id].content
	elif merge_type == "interleave":
		# Interleave words from each chunk
		var all_words = []
		for chunk_id in chunk_ids:
			var chunk_words = data_chunks[chunk_id].content.split(" ", false)
			for i in range(chunk_words.size()):
				all_words.append(chunk_words[i])
		merged_content = " ".join(all_words)
	else:
		# Default to concatenation
		for chunk_id in chunk_ids:
			merged_content += data_chunks[chunk_id].content
	
	# Create result chunk
	var result_chunk_id = "merged_" + str(Time.get_unix_time_from_system())
	var result = create_data_chunk(result_chunk_id, merged_content, parent_stream_id)
	
	if not result.success:
		return {"success": false, "message": "Failed to create merged chunk"}
	
	# Record merge operation
	var merge_data = {
		"id": merge_id,
		"source_chunks": chunk_ids.duplicate(),
		"result_chunk": result_chunk_id,
		"merge_type": merge_type,
		"created_at": Time.get_unix_time_from_system(),
		"dimension": current_dimension,
		"reality": current_reality
	}
	
	merge_operations.append(merge_data)
	
	# Create merge visualization
	if data_visualization_enabled:
		_create_merge_visualization(merge_data)
	
	# Connect source chunks to result
	for chunk_id in chunk_ids:
		_create_connection(chunk_id, result_chunk_id, "merge")
	
	# Emit signal
	emit_signal("data_merged", merge_id, chunk_ids, result_chunk_id)
	
	if enable_debug_logs:
		print("DataSplitterController: Merged " + str(chunk_ids.size()) + " chunks into '" + result_chunk_id + "'")
	
	return {"success": true, "message": "Chunks merged", "merge_data": merge_data, "result_chunk": result_chunk_id}

# ----- VISUALIZATION FUNCTIONS -----
func _create_stream_visualization(stream_data):
	# Create visual representation of data stream
	var streams_node = data_container.get_node("DataStreams")
	
	# Create stream container
	var stream_node = Node3D.new()
	stream_node.name = "Stream_" + stream_data.id
	streams_node.add_child(stream_node)
	
	# Calculate position based on number of existing streams
	var stream_index = data_streams.size() - 1
	var angle = (2 * PI / max_data_streams) * stream_index
	var radius = 3.0 + (current_dimension * 0.1)
	var height = 0.5 + (stream_index * 0.2)
	
	stream_node.position = Vector3(cos(angle) * radius, height, sin(angle) * radius)
	
	# Create visual model (cylinder representing data flow)
	var cylinder = CSGCylinder3D.new()
	cylinder.radius = 0.1 + (stream_data.size / 100.0)
	cylinder.height = 0.8 + (stream_data.size / 50.0)
	cylinder.material = stream_material.duplicate()
	
	# Adjust color based on data type
	var material = cylinder.material
	if stream_data.type == "binary":
		material.albedo_color = Color(0.2, 0.4, 0.9)
		material.emission = Color(0.3, 0.5, 1.0)
	elif stream_data.type == "text":
		material.albedo_color = Color(0.9, 0.4, 0.2)
		material.emission = Color(1.0, 0.5, 0.3)
	elif stream_data.type == "image":
		material.albedo_color = Color(0.4, 0.9, 0.2)
		material.emission = Color(0.5, 1.0, 0.3)
	
	stream_node.add_child(cylinder)
	
	# Add label
	var label = Label3D.new()
	label.text = stream_data.id
	label.font_size = 18
	label.position = Vector3(0, cylinder.height/2 + 0.2, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	stream_node.add_child(label)
	
	# Add to tracking
	stream_nodes[stream_data.id] = stream_node
	
	return stream_node

func _create_chunk_visualization(chunk_data):
	# Create visual representation of data chunk
	var chunks_node = data_container.get_node("DataChunks")
	
	# Create chunk container
	var chunk_node = Node3D.new()
	chunk_node.name = "Chunk_" + chunk_data.id
	chunks_node.add_child(chunk_node)
	
	# Find parent stream node for positioning relative to it
	var parent_stream_node = stream_nodes.get(chunk_data.parent_stream)
	var position = Vector3.ZERO
	
	if parent_stream_node:
		# Position near the parent stream
		var stream_pos = parent_stream_node.global_position
		var chunk_index = data_chunks.size() - 1
		var angle = randf_range(0, 2 * PI)
		var radius = 0.8 + (chunk_data.size / 50.0)
		
		position = Vector3(
			stream_pos.x + cos(angle) * radius,
			stream_pos.y + randf_range(-0.5, 0.5),
			stream_pos.z + sin(angle) * radius
		)
	else:
		# Fallback position if parent not found
		var chunk_index = data_chunks.size()
		position = Vector3(randf_range(-5, 5), randf_range(0, 3), randf_range(-5, 5))
	
	chunk_node.global_position = position
	
	# Create visual model (box representing data chunk)
	var box = CSGBox3D.new()
	box.size = Vector3(
		0.3 + (chunk_data.size / 100.0),
		0.3 + (chunk_data.size / 150.0),
		0.3 + (chunk_data.size / 120.0)
	)
	box.material = chunk_material.duplicate()
	
	# Adjust color based on entropy
	var entropy = chunk_data.properties.entropy
	var material = box.material
	material.albedo_color = Color(0.8, 0.3 + (entropy * 0.5), 0.9 - (entropy * 0.6))
	material.emission = Color(0.9, 0.4 + (entropy * 0.5), 1.0 - (entropy * 0.6))
	
	chunk_node.add_child(box)
	
	# Add label
	var label = Label3D.new()
	label.text = chunk_data.id
	label.font_size = 12
	label.position = Vector3(0, box.size.y/2 + 0.2, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	chunk_node.add_child(label)
	
	# Add to tracking
	chunk_nodes[chunk_data.id] = chunk_node
	
	return chunk_node

func _create_split_visualization(split_data):
	# Create visual effect for data split
	if not split_effect:
		return
	
	var original_chunk_node = chunk_nodes.get(split_data.original_chunk)
	if not original_chunk_node:
		return
	
	# Create effect instance
	var effect = split_effect.instantiate()
	var visualizer_node = data_container.get_node("DataVisualizer")
	visualizer_node.add_child(effect)
	
	# Position at original chunk
	effect.global_position = original_chunk_node.global_position
	
	# Configure effect if applicable
	if effect.has_method("set_split_factor"):
		effect.set_split_factor(split_data.resulting_chunks.size())
	
	# Auto-remove after effect completes
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.connect("timeout", Callable(effect, "queue_free"))
	effect.add_child(timer)
	timer.start()

func _create_merge_visualization(merge_data):
	# Create visual effect for data merge
	if not merge_effect:
		return
	
	var result_chunk_node = chunk_nodes.get(merge_data.result_chunk)
	if not result_chunk_node:
		return
	
	# Create effect instance
	var effect = merge_effect.instantiate()
	var visualizer_node = data_container.get_node("DataVisualizer")
	visualizer_node.add_child(effect)
	
	# Position at result chunk
	effect.global_position = result_chunk_node.global_position
	
	# Configure effect if applicable
	if effect.has_method("set_merge_factor"):
		effect.set_merge_factor(merge_data.source_chunks.size())
	
	# Auto-remove after effect completes
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.connect("timeout", Callable(effect, "queue_free"))
	effect.add_child(timer)
	timer.start()

func _create_connection(source_id: String, target_id: String, connection_type: String = "default"):
	# Create visual connection between data elements
	var connections_node = data_container.get_node("DataConnections")
	
	# Get source and target nodes
	var source_node = null
	var target_node = null
	
	if chunk_nodes.has(source_id):
		source_node = chunk_nodes[source_id]
	elif stream_nodes.has(source_id):
		source_node = stream_nodes[source_id]
	
	if chunk_nodes.has(target_id):
		target_node = chunk_nodes[target_id]
	elif stream_nodes.has(target_id):
		target_node = stream_nodes[target_id]
	
	if not source_node or not target_node:
		return null
	
	# Create unique connection ID
	var connection_id = source_id + "_to_" + target_id
	
	# Skip if already exists
	if connection_nodes.has(connection_id):
		return connection_nodes[connection_id]
	
	# Create connection container
	var connection_node = Node3D.new()
	connection_node.name = "Connection_" + connection_id
	connections_node.add_child(connection_node)
	
	# Create visual line
	var line_mesh = _create_connection_line(source_node.global_position, target_node.global_position, connection_type)
	connection_node.add_child(line_mesh)
	
	# Create connection data
	var connection_data = {
		"id": connection_id,
		"source": source_id,
		"target": target_id,
		"type": connection_type,
		"created_at": Time.get_unix_time_from_system()
	}
	
	# Store in active connections
	active_connections[connection_id] = connection_data
	
	# Add to tracking
	connection_nodes[connection_id] = connection_node
	
	return connection_node

func _create_connection_line(start_pos: Vector3, end_pos: Vector3, connection_type: String) -> Node3D:
	# Create a 3D visualization of a connection line
	var line_container = Node3D.new()
	line_container.name = "LineContainer"
	
	# Calculate midpoint and direction
	var midpoint = (start_pos + end_pos) / 2
	var direction = (end_pos - start_pos).normalized()
	var length = start_pos.distance_to(end_pos)
	
	# Create mesh instance
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "LineRenderer"
	
	# Create cylinder mesh for the line
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.02
	cylinder.bottom_radius = 0.02
	cylinder.height = length
	mesh_instance.mesh = cylinder
	
	# Position and orient cylinder to connect points
	mesh_instance.look_at_from_position(midpoint, end_pos, Vector3.UP)
	mesh_instance.rotate_object_local(Vector3.RIGHT, PI/2) # Rotate to align cylinder axis
	
	# Apply material based on connection type
	var material = connection_material.duplicate()
	material.albedo_color = _get_connection_color(connection_type)
	material.emission = material.albedo_color
	material.emission_energy = 0.7
	
	mesh_instance.material_override = material
	
	line_container.add_child(mesh_instance)
	return line_container

func _get_connection_color(connection_type: String) -> Color:
	# Return color based on connection type
	match connection_type:
		"split":
			return Color(0.9, 0.5, 0.1) # Orange
		"merge":
			return Color(0.1, 0.6, 0.9) # Blue
		"flow":
			return Color(0.3, 0.9, 0.3) # Green
		"transform":
			return Color(0.8, 0.3, 0.8) # Purple
		_:
			return Color(0.7, 0.7, 0.7) # Gray

# ----- CONSOLE COMMAND PROCESSING -----
func process_command(command: String) -> Dictionary:
	# Process data splitter commands
	
	# Skip empty commands
	if command.strip_edges().is_empty():
		return {"success": false, "message": "Empty command"}
	
	# Split into command and parameters
	var parts = command.split(" ", false, 1)
	var cmd = parts[0].to_lower()
	var params = ""
	if parts.size() > 1:
		params = parts[1]
	
	match cmd:
		"/split":
			# Split data command
			if params.is_empty():
				_log_message("Usage: /split [text to split]")
				return {"success": false, "message": "Missing text to split"}
			
			# Create a stream if needed
			var stream_id = "text_stream_" + str(data_streams.size())
			if data_streams.size() == 0:
				create_data_stream(stream_id, "text", params.length())
			else:
				stream_id = data_streams[0].id
			
			# Create chunk with text
			var chunk_id = "text_chunk_" + str(Time.get_unix_time_from_system())
			var chunk_result = create_data_chunk(chunk_id, params, stream_id)
			
			if not chunk_result.success:
				_log_message("Failed to create chunk: " + chunk_result.message)
				return chunk_result
			
			# Split the chunk
			var split_result = split_data_chunk(chunk_id)
			
			if split_result.success:
				_log_message("Split text into " + str(split_result.resulting_chunks.size()) + " parts")
				return split_result
			else:
				_log_message("Failed to split: " + split_result.message)
				return split_result
		
		"/merge":
			# Merge data command
			if params.is_empty():
				_log_message("Usage: /merge [chunk_id_1] [chunk_id_2] ...")
				return {"success": false, "message": "Missing chunks to merge"}
			
			var chunk_ids = params.split(" ", false)
			if chunk_ids.size() < 2:
				_log_message("Need at least 2 chunks to merge")
				return {"success": false, "message": "Need at least 2 chunks to merge"}
			
			var merge_result = merge_data_chunks(chunk_ids)
			
			if merge_result.success:
				_log_message("Merged " + str(chunk_ids.size()) + " chunks into " + merge_result.result_chunk)
				return merge_result
			else:
				_log_message("Failed to merge: " + merge_result.message)
				return merge_result
		
		"/stream":
			# Create new data stream
			var stream_id = "stream_" + str(data_streams.size())
			var stream_type = "binary"
			var stream_size = default_data_chunk_size
			
			if not params.is_empty():
				var param_parts = params.split(" ")
				if param_parts.size() >= 1:
					stream_id = param_parts[0]
				if param_parts.size() >= 2:
					stream_type = param_parts[1]
				if param_parts.size() >= 3 and param_parts[2].is_valid_int():
					stream_size = param_parts[2].to_int()
			
			var stream_result = create_data_stream(stream_id, stream_type, stream_size)
			
			if stream_result.success:
				_log_message("Created new data stream: " + stream_id)
				return stream_result
			else:
				_log_message("Failed to create stream: " + stream_result.message)
				return stream_result
		
		"/list":
			# List existing data elements
			var listing = "[color=#88ff99]Data Splitter Elements:[/color]\n"
			
			listing += "\n[color=#aaaaff]Streams (" + str(data_streams.size()) + "):[/color]\n"
			for stream in data_streams:
				listing += "- " + stream.id + " (" + stream.type + ", " + str(stream.size) + " bytes, " + str(stream.chunks.size()) + " chunks)\n"
			
			listing += "\n[color=#ffaaaa]Chunks (" + str(data_chunks.size()) + "):[/color]\n"
			var chunk_count = 0
			for chunk_id in data_chunks:
				listing += "- " + chunk_id + " (size: " + str(data_chunks[chunk_id].size) + ")\n"
				chunk_count += 1
				if chunk_count >= 10:
					listing += "  ... and " + str(data_chunks.size() - 10) + " more\n"
					break
			
			listing += "\n[color=#aaffaa]Splits (" + str(data_splits.size()) + "):[/color]\n"
			var split_count = 0
			for split_id in data_splits:
				listing += "- " + split_id + " (factor: " + str(data_splits[split_id].factor) + ")\n"
				split_count += 1
				if split_count >= 5:
					listing += "  ... and " + str(data_splits.size() - 5) + " more\n"
					break
			
			_log_message(listing)
			return {"success": true, "message": listing}
		
		"/help":
			# Display data splitter commands
			var help_text = "[color=#88ff99]Data Splitter Commands:[/color]\n"
			help_text += "/split [text] - Split text into data chunks\n"
			help_text += "/merge [chunk_id1] [chunk_id2] ... - Merge chunks\n"
			help_text += "/stream [id] [type] [size] - Create a new data stream\n"
			help_text += "/list - List all data elements\n"
			help_text += "/help - Display this help\n"
			
			_log_message(help_text)
			return {"success": true, "message": help_text}
		
		_:
			# Pass to notepad3d if available
			if notepad3d_integration and notepad3d_integration.has_method("process_command"):
				return notepad3d_integration.process_command(command)
			elif pitopia_main and pitopia_main.has_method("process_command"):
				return pitopia_main.process_command(command)
			else:
				return {"success": false, "message": "Unknown command. Try /help for available commands."}

# ----- SIGNAL HANDLERS -----
func _on_dimension_changed(new_dimension, old_dimension = 0):
	current_dimension = new_dimension
	
	if enable_debug_logs:
		print("DataSplitterController: Dimension changed to " + str(new_dimension) + "D")
	
	# Apply dimension effects to data elements
	_apply_dimension_effects(new_dimension)
	
	# Emit signal
	emit_signal("dimension_changed", new_dimension, old_dimension)

func _on_turn_advanced(turn_number):
	current_turn = turn_number
	
	if enable_debug_logs:
		print("DataSplitterController: Advanced to turn " + str(turn_number))
	
	# Process automatic data flows
	_process_data_flows()
	
	# Emit signal
	emit_signal("turn_advanced", turn_number)

func _on_reality_changed(new_reality, old_reality):
	current_reality = new_reality
	
	if enable_debug_logs:
		print("DataSplitterController: Reality changed to " + new_reality)
	
	# Apply reality effects to data elements
	_apply_reality_effects(new_reality)
	
	# Emit signal
	emit_signal("reality_changed", new_reality, old_reality)

func _on_moon_phase_changed(new_phase, old_phase, stability):
	current_moon_phase = new_phase
	
	if enable_debug_logs:
		print("DataSplitterController: Moon phase changed to " + str(new_phase) + " (stability: " + str(stability) + ")")
	
	# Adjust data flow and split stability based on moon phase
	_adjust_stability_by_moon_phase(new_phase, stability)

func _on_word_manifested(word, entity, reality_type = "", dimension = 0):
	if enable_debug_logs:
		print("DataSplitterController: Word '" + word + "' manifested")
	
	# Check for data splitter related words to trigger effects
	var data_related_words = ["data", "split", "stream", "flow", "chunk", "merge", "process"]
	for data_word in data_related_words:
		if word.to_lower().find(data_word) >= 0:
			_process_word_data_effects(word, entity)
			break

# ----- EFFECT FUNCTIONS -----
func _apply_dimension_effects(dimension: int):
	# Apply dimension-specific effects to data elements
	
	# Adjust stream properties
	for stream in data_streams:
		stream.dimension = dimension
		stream.properties.flow_rate = 1.0 + (dimension * 0.1)
		
		# Adjust visualization
		if stream_nodes.has(stream.id):
			var stream_node = stream_nodes[stream.id]
			
			# Scale based on dimension
			var scale_factor = 1.0 + ((dimension - 3) * 0.05)
			stream_node.scale = Vector3(scale_factor, scale_factor, scale_factor)
			
			# Adjust position
			var stream_index = data_streams.find(stream)
			var angle = (2 * PI / max_data_streams) * stream_index
			var radius = 3.0 + (dimension * 0.1)
			var height = 0.5 + (stream_index * 0.2)
			
			# Create tween for smooth transition
			var tween = get_tree().create_tween()
			tween.tween_property(stream_node, "position", Vector3(cos(angle) * radius, height, sin(angle) * radius), 1.0)
	
	# Adjust chunk properties
	for chunk_id in data_chunks:
		var chunk = data_chunks[chunk_id]
		chunk.dimension = dimension
		
		# Higher dimensions increase complexity and coherence
		chunk.properties.complexity = min(1.0, chunk.properties.complexity + (dimension * 0.02))
		
		# Adjust visualization
		if chunk_nodes.has(chunk_id):
			var chunk_node = chunk_nodes[chunk_id]
			
			# Scale and effects based on dimension
			var scale_factor = 1.0 + ((dimension - 3) * 0.03)
			chunk_node.scale = Vector3(scale_factor, scale_factor, scale_factor)
			
			# For dimensions 5+, add subtle glow effects
			if dimension >= 5:
				var mesh = chunk_node.get_child(0)
				if mesh is CSGBox3D:
					var material = mesh.material
					if material is StandardMaterial3D:
						material.emission_energy = 0.5 + ((dimension - 5) * 0.1)

func _apply_reality_effects(reality: String):
	# Apply reality-specific effects to data elements
	
	# Reality-specific properties for streams
	for stream in data_streams:
		stream.reality = reality
		
		match reality:
			"Physical":
				stream.properties.compression_ratio = 0.8
				stream.properties.stability = 0.9
			"Digital":
				stream.properties.compression_ratio = 0.5
				stream.properties.stability = 0.95
			"Astral":
				stream.properties.compression_ratio = 0.3
				stream.properties.stability = 0.7
			"Memory":
				stream.properties.compression_ratio = 0.4
				stream.properties.stability = 0.8
			"Dream":
				stream.properties.compression_ratio = 0.2
				stream.properties.stability = 0.6
		
		# Adjust visualization
		if stream_nodes.has(stream.id):
			var stream_node = stream_nodes[stream.id]
			var cylinder = stream_node.get_child(0)
			
			if cylinder is CSGCylinder3D and cylinder.material is StandardMaterial3D:
				var material = cylinder.material
				
				# Adjust colors based on reality
				match reality:
					"Physical":
						material.albedo_color = material.albedo_color.lerp(Color(0.2, 0.4, 0.9), 0.7)
						material.emission = material.emission.lerp(Color(0.3, 0.5, 1.0), 0.7)
					"Digital":
						material.albedo_color = material.albedo_color.lerp(Color(0.1, 0.8, 0.2), 0.7)
						material.emission = material.emission.lerp(Color(0.2, 0.9, 0.3), 0.7)
					"Astral":
						material.albedo_color = material.albedo_color.lerp(Color(0.9, 0.3, 0.9), 0.7)
						material.emission = material.emission.lerp(Color(1.0, 0.4, 1.0), 0.7)
					"Memory":
						material.albedo_color = material.albedo_color.lerp(Color(0.8, 0.8, 0.2), 0.7)
						material.emission = material.emission.lerp(Color(0.9, 0.9, 0.3), 0.7)
					"Dream":
						material.albedo_color = material.albedo_color.lerp(Color(0.5, 0.2, 0.8), 0.7)
						material.emission = material.emission.lerp(Color(0.6, 0.3, 0.9), 0.7)
	
	# Reality-specific properties for chunks
	for chunk_id in data_chunks:
		var chunk = data_chunks[chunk_id]
		chunk.reality = reality
		
		# Adjust visualization
		if chunk_nodes.has(chunk_id):
			var chunk_node = chunk_nodes[chunk_id]
			var box = chunk_node.get_child(0)
			
			if box is CSGBox3D and box.material is StandardMaterial3D:
				var material = box.material
				
				# Adjust material properties based on reality
				match reality:
					"Physical":
						material.metallic = 0.8
						material.roughness = 0.2
					"Digital":
						material.metallic = 0.2
						material.roughness = 0.1
					"Astral":
						material.metallic = 0.5
						material.roughness = 0.3
						material.emission_energy = 0.8
					"Memory":
						material.metallic = 0.3
						material.roughness = 0.5
					"Dream":
						material.metallic = 0.6
						material.roughness = 0.4
						material.emission_energy = 1.0

func _adjust_stability_by_moon_phase(phase: int, stability: float):
	# Adjust data processing based on moon phase
	
	# Modify stream flow rates
	for stream in data_streams:
		# Moon phase affects flow rate and stability
		var phase_factor = 0.5 + (stability * 0.5)
		stream.properties.flow_rate *= phase_factor
		stream.properties.stability = min(1.0, stream.properties.stability * phase_factor)
		
		# Visual adjustments
		if stream_nodes.has(stream.id):
			var stream_node = stream_nodes[stream.id]
			var cylinder = stream_node.get_child(0)
			
			if cylinder is CSGCylinder3D and cylinder.material is StandardMaterial3D:
				var material = cylinder.material
				material.emission_energy = 0.5 + (stability * 0.5)
	
	# Modify data chunk coherence
	for chunk_id in data_chunks:
		var chunk = data_chunks[chunk_id]
		
		# Moon phase affects data stability
		chunk.properties.coherence = min(1.0, chunk.properties.coherence * (0.7 + (stability * 0.3)))
		
		# Visual adjustments
		if chunk_nodes.has(chunk_id):
			var chunk_node = chunk_nodes[chunk_id]
			var box = chunk_node.get_child(0)
			
			if box is CSGBox3D and box.material is StandardMaterial3D:
				var material = box.material
				material.emission_energy = 0.4 + (stability * 0.6)

func _process_word_data_effects(word: String, entity):
	var word_lower = word.to_lower()
	
	if word_lower == "data" or word_lower == "stream":
		# Create a new data stream
		var stream_id = "word_stream_" + str(Time.get_unix_time_from_system())
		create_data_stream(stream_id, "text", 16 + word.length())
	
	elif word_lower == "split":
		# Split a random chunk if available
		if data_chunks.size() > 0:
			var chunk_id = data_chunks.keys()[randi() % data_chunks.size()]
			split_data_chunk(chunk_id)
	
	elif word_lower == "merge":
		# Merge random chunks if enough are available
		if data_chunks.size() >= 2:
			var all_chunks = data_chunks.keys()
			var to_merge = []
			
			# Pick 2-3 random chunks
			for i in range(min(data_chunks.size(), 2 + randi() % 2)):
				var idx = randi() % all_chunks.size()
				to_merge.append(all_chunks[idx])
				all_chunks.remove_at(idx)
			
			merge_data_chunks(to_merge)
	
	elif word_lower.find("flow") >= 0 or word_lower.find("process") >= 0:
		# Trigger data flows
		_process_data_flows()

func _process_data_flows():
	# Process automatic data flows between chunks and streams
	var flow_count = 0
	
	# For each stream, create flows between chunks
	for stream in data_streams:
		if stream.chunks.size() < 2:
			continue
		
		# Flow rate affects how many flows to create
		var flow_count_for_stream = int(max(1, stream.properties.flow_rate))
		
		for i in range(flow_count_for_stream):
			if stream.chunks.size() < 2:
				break
			
			# Pick random source and destination
			var source_idx = randi() % stream.chunks.size()
			var dest_idx = source_idx
			while dest_idx == source_idx:
				dest_idx = randi() % stream.chunks.size()
			
			var source_chunk = stream.chunks[source_idx]
			var dest_chunk = stream.chunks[dest_idx]
			
			# Create connection if doesn't exist
			_create_connection(source_chunk, dest_chunk, "flow")
			
			# Record flow
			var flow_id = "flow_" + str(Time.get_unix_time_from_system()) + "_" + str(flow_count)
			var flow_amount = 5 + randi() % 15
			
			var flow_data = {
				"id": flow_id,
				"source": source_chunk,
				"destination": dest_chunk,
				"amount": flow_amount,
				"timestamp": Time.get_unix_time_from_system(),
				"dimension": current_dimension,
				"reality": current_reality
			}
			
			data_flow_history.append(flow_data)
			emit_signal("data_flow_processed", flow_id, source_chunk, dest_chunk, flow_amount)
			
			flow_count += 1
			
			# Create visualization effect
			_create_flow_particle_effect(source_chunk, dest_chunk, flow_amount)
	
	if enable_debug_logs and flow_count > 0:
		print("DataSplitterController: Processed " + str(flow_count) + " data flows")
	
	# Update UI
	_update_ui_display()

func _create_flow_particle_effect(source_id: String, dest_id: String, amount: int):
	if not data_visualization_enabled:
		return
	
	if not chunk_nodes.has(source_id) or not chunk_nodes.has(dest_id):
		return
	
	var source_pos = chunk_nodes[source_id].global_position
	var dest_pos = chunk_nodes[dest_id].global_position
	
	# Create a simple particle effect
	var particles = CPUParticles3D.new()
	particles.emitting = true
	particles.amount = min(50, amount * 2)
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 0.0
	particles.direction = Vector3(0, 0, 0)
	particles.spread = 5.0
	particles.gravity = Vector3.ZERO
	
	# Set start and end positions
	particles.global_position = source_pos
	var dir = (dest_pos - source_pos).normalized()
	particles.velocity = dir * (source_pos.distance_to(dest_pos) / particles.lifetime)
	
	# Color based on dimension
	var base_color = Color(0.3, 0.7, 0.9)
	if current_dimension > 3:
		base_color = Color(0.9, 0.4, 0.8) # Higher dimensions more purple
	
	particles.color = base_color
	particles.color_ramp = Gradient.new()
	
	# Add to visualizer
	var visualizer_node = data_container.get_node("DataVisualizer")
	visualizer_node.add_child(particles)
	
	# Auto-remove when done
	var timer = Timer.new()
	timer.wait_time = particles.lifetime + 0.5
	timer.one_shot = true
	timer.connect("timeout", Callable(particles, "queue_free"))
	particles.add_child(timer)
	timer.start()

func _update_ui_display():
	# Update data splitter UI elements
	var ui = get_node_or_null("../UI")
	if not ui:
		return
	
	var data_panel = ui.get_node_or_null("DataSplitterPanel")
	if not data_panel:
		return
	
	# Update stream count
	var streams_label = data_panel.get_node_or_null("StreamsLabel")
	if streams_label:
		streams_label.text = "Active Streams: " + str(data_streams.size()) + "/" + str(max_data_streams)
	
	# Update chunk count
	var chunks_label = data_panel.get_node_or_null("ChunksLabel")
	if chunks_label:
		chunks_label.text = "Data Chunks: " + str(data_chunks.size())
	
	# Update splits count
	var splits_label = data_panel.get_node_or_null("SplitsLabel")
	if splits_label:
		splits_label.text = "Active Splits: " + str(data_splits.size())

func _log_message(message: String):
	# Log message to console output if available
	if console:
		var output = console.get_node_or_null("Panel/OutputLabel")
		if output and output is RichTextLabel:
			output.text += message + "\n"
			
			# Scroll to bottom
			output.scroll_to_line(output.get_line_count() - 1)
	
	if enable_debug_logs:
		print("DataSplitterController: " + message)

# ----- PHYSICS PROCESS -----
func _physics_process(delta):
	if not initialized or not data_visualization_enabled:
		return
	
	# Update connections - make sure they stay connected to moving chunks
	for connection_id in connection_nodes:
		var connection_data = active_connections.get(connection_id)
		if not connection_data:
			continue
		
		var source_id = connection_data.source
		var target_id = connection_data.target
		
		var source_node = null
		if chunk_nodes.has(source_id):
			source_node = chunk_nodes[source_id]
		elif stream_nodes.has(source_id):
			source_node = stream_nodes[source_id]
		
		var target_node = null
		if chunk_nodes.has(target_id):
			target_node = chunk_nodes[target_id]
		elif stream_nodes.has(target_id):
			target_node = stream_nodes[target_id]
		
		if source_node and target_node:
			_update_connection_line(connection_nodes[connection_id], source_node.global_position, target_node.global_position)
	
	# Apply dimension effects for 4D+ (temporal flows)
	if current_dimension >= 4:
		_process_temporal_effects(delta)

func _update_connection_line(connection_node, start_pos, end_pos):
	var line_container = connection_node.get_child(0)
	if not line_container or not line_container.get_child_count() > 0:
		return
	
	var mesh_instance = line_container.get_child(0)
	
	# Calculate midpoint and direction
	var midpoint = (start_pos + end_pos) / 2
	var direction = (end_pos - start_pos).normalized()
	var length = start_pos.distance_to(end_pos)
	
	# Update cylinder length
	if mesh_instance.mesh is CylinderMesh:
		mesh_instance.mesh.height = length
	
	# Position and orient cylinder to connect points
	mesh_instance.look_at_from_position(midpoint, end_pos, Vector3.UP)
	mesh_instance.rotate_object_local(Vector3.RIGHT, PI/2) # Rotate to align cylinder axis

func _process_temporal_effects(delta):
	# Apply temporal effects to data chunks (4D+)
	var time = Time.get_ticks_msec() / 1000.0
	var temporal_factor = (current_dimension - 3) * 0.05
	
	for chunk_id in chunk_nodes:
		var chunk_node = chunk_nodes[chunk_id]
		var original_pos = chunk_node.transform.origin
		
		# Create a unique oscillation for each chunk
		var chunk_hash = chunk_id.hash()
		var unique_offset = Vector3(
			sin(time + chunk_hash * 0.1) * temporal_factor,
			cos(time * 0.7 + chunk_hash * 0.05) * temporal_factor,
			sin(time * 0.5 + chunk_hash * 0.15) * temporal_factor
		)
		
		# Apply smooth movement
		chunk_node.global_position = chunk_node.global_position.lerp(original_pos + unique_offset, delta * 2.0)
		
		# Apply pulsing glow for dimensions 5+
		if current_dimension >= 5:
			var box = chunk_node.get_child(0)
			if box is CSGBox3D and box.material is StandardMaterial3D:
				var pulse = (sin(time + chunk_hash * 0.1) * 0.5 + 0.5) * temporal_factor * 2
				box.material.emission_energy = 0.6 + pulse