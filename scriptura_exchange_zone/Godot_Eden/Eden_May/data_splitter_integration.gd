extends Node

class_name DataSplitterIntegration

# ----- NODE PATHS -----
@export_node_path var notepad3d_integration_path: NodePath
@export_node_path var pitopia_main_path: NodePath
@export_node_path var data_splitter_path: NodePath
@export_node_path var console_path: NodePath
@export_node_path var main_controller_path: NodePath

# ----- COMPONENT REFERENCES -----
var notepad3d_integration = null
var pitopia_main = null
var data_splitter = null
var console = null
var main_controller = null

# ----- INTEGRATION SETTINGS -----
@export var auto_initialize: bool = true
@export var process_existing_files: bool = true
@export var display_split_stats: bool = true
@export var auto_connect_realities: bool = true
@export var enable_data_visualization: bool = true
@export var log_split_operations: bool = true
@export var split_rule_file: String = "res://split_rules.json"

# ----- VISUALIZATION SETTINGS -----
@export var visualization_scale: float = 1.0
@export var use_line_renderer: bool = true
@export var line_material: StandardMaterial3D
@export var block_material: StandardMaterial3D
@export var highlight_material: StandardMaterial3D
@export var data_block_scene: PackedScene
@export var data_line_scene: PackedScene

# ----- DATA STRUCTURE -----
var split_rules = {
	"LEVEL_0": ["[", "]"],    # Main blocks
	"LEVEL_1": ["="],         # Section separators 
	"LEVEL_2": ["|"],         # Data separators
	"LEVEL_3": [",", "."]     # Content separators
}

var storage_rules = {
	"MAX_LINE_LENGTH": 80,
	"MAX_FUNCTION_SIZE": 1000,
	"REQUIRED_TAGS": ["name", "version", "status"],
	"ALLOWED_SYMBOLS": ["[", "]", "=", "|", "#"]
}

var file_format = {
	"line_separator": "|",
	"block_start": "[",
	"block_end": "]",
	"dict_marker": "=",
	"version_marker": "#"
}

# ----- STATE VARIABLES -----
var visualization_parent: Node3D
var active_blocks = {}
var active_lines = {}
var active_connections = {}
var active_metadata = {}
var current_processing_mode = "standard"
var current_processing_files = []
var current_visualization_mode = "3d"
var current_split_rule_level = "LEVEL_0"
var current_realities = {}

# ----- SIGNALS -----
signal integration_ready
signal data_split_completed(stats)
signal data_block_created(block_id, block_data)
signal data_block_modified(block_id, block_data)
signal data_block_deleted(block_id)
signal reality_data_mapped(reality_name, data_blocks)
signal visualization_updated
signal rules_applied(rule_level, content, result)

# ----- INITIALIZATION -----
func _ready():
	if auto_initialize:
		initialize()

func initialize():
	print("DataSplitterIntegration initializing...")
	
	# Find and connect components
	_resolve_component_paths()
	
	# Create visualization parent
	_create_visualization_parent()
	
	# Load split rules if file exists
	_load_split_rules()
	
	# Connect signals
	_connect_signals()
	
	if process_existing_files:
		# Process any existing files
		_process_existing_files()
	
	if auto_connect_realities:
		# Connect with realities from Notepad3D
		_connect_realities()
	
	print("DataSplitterIntegration ready")
	emit_signal("integration_ready")

func _resolve_component_paths():
	# Find notepad3d integration
	if notepad3d_integration_path:
		notepad3d_integration = get_node_or_null(notepad3d_integration_path)
	
	if not notepad3d_integration:
		notepad3d_integration = get_node_or_null("/root/Notepad3DPitopiaIntegration")
		if not notepad3d_integration:
			var nodes = get_tree().get_nodes_in_group("notepad3d_integration")
			if nodes.size() > 0:
				notepad3d_integration = nodes[0]
	
	# Find pitopia main
	if pitopia_main_path:
		pitopia_main = get_node_or_null(pitopia_main_path)
	
	if not pitopia_main:
		pitopia_main = get_node_or_null("/root/PitopiaMain")
		if not pitopia_main:
			var nodes = get_tree().get_nodes_in_group("pitopia_main")
			if nodes.size() > 0:
				pitopia_main = nodes[0]
	
	# Find data splitter
	if data_splitter_path:
		data_splitter = get_node_or_null(data_splitter_path)
	
	if not data_splitter and main_controller:
		data_splitter = main_controller.get_node_or_null("JSH_data_splitter")
	
	if not data_splitter:
		data_splitter = get_node_or_null("/root/main/JSH_data_splitter")
		if not data_splitter:
			var nodes = get_tree().get_nodes_in_group("data_splitter")
			if nodes.size() > 0:
				data_splitter = nodes[0]
	
	# Find console
	if console_path:
		console = get_node_or_null(console_path)
	
	if not console and pitopia_main:
		console = pitopia_main.get_node_or_null("Console")
	
	# Find main controller
	if main_controller_path:
		main_controller = get_node_or_null(main_controller_path)
	
	if not main_controller:
		main_controller = get_node_or_null("/root/main")
	
	# Log found components
	print("Components found:")
	print("- Notepad3D Integration: ", "Yes" if notepad3d_integration else "No")
	print("- Pitopia Main: ", "Yes" if pitopia_main else "No")
	print("- Data Splitter: ", "Yes" if data_splitter else "No")
	print("- Console: ", "Yes" if console else "No")
	print("- Main Controller: ", "Yes" if main_controller else "No")

func _create_visualization_parent():
	visualization_parent = Node3D.new()
	visualization_parent.name = "DataVisualization"
	add_child(visualization_parent)

func _load_split_rules():
	# Check if rules file exists
	if FileAccess.file_exists(split_rule_file):
		var file = FileAccess.open(split_rule_file, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			var json = JSON.parse_string(json_text)
			
			if json:
				# Update rules
				if json.has("split_rules"):
					split_rules = json.split_rules
				if json.has("storage_rules"):
					storage_rules = json.storage_rules
				if json.has("file_format"):
					file_format = json.file_format
					
				print("Loaded split rules from file")
			else:
				print("Error parsing split rules file")
	else:
		# Create default rules file
		_save_split_rules()

func _save_split_rules():
	var file = FileAccess.open(split_rule_file, FileAccess.WRITE)
	if file:
		var json = {
			"split_rules": split_rules,
			"storage_rules": storage_rules,
			"file_format": file_format
		}
		
		file.store_string(JSON.stringify(json, "\t"))
		print("Created default split rules file")
	else:
		print("Error creating split rules file")

func _connect_signals():
	# Connect to Notepad3D signals
	if notepad3d_integration:
		if notepad3d_integration.has_signal("reality_changed"):
			notepad3d_integration.connect("reality_changed", Callable(self, "_on_reality_changed"))
		
		if notepad3d_integration.has_signal("word_manifested"):
			notepad3d_integration.connect("word_manifested", Callable(self, "_on_word_manifested"))
	
	# Connect to Data Splitter signals
	if data_splitter:
		if data_splitter.has_signal("parsing_completed"):
			data_splitter.connect("parsing_completed", Callable(self, "_on_parsing_completed"))
		
		if data_splitter.has_signal("error_detected"):
			data_splitter.connect("error_detected", Callable(self, "_on_error_detected"))

func _process_existing_files():
	if data_splitter:
		# Process files in default directory
		var result = data_splitter.process_directory()
		
		if display_split_stats:
			_display_split_stats(result)
		
		# Create visualizations for processed files
		for file in result.processed_files:
			_create_visualizations_for_file(file)
	else:
		print("Data Splitter not available, can't process existing files")

func _connect_realities():
	if notepad3d_integration:
		# Get available realities from Notepad3D
		var realities = _get_available_realities()
		
		# Map data to realities
		for reality in realities:
			_map_data_to_reality(reality)
	else:
		print("Notepad3D Integration not available, can't connect realities")

func _get_available_realities() -> Array:
	if notepad3d_integration and notepad3d_integration.has_method("get_available_realities"):
		return notepad3d_integration.get_available_realities()
	
	# Default realities if method not available
	return ["Physical", "Digital", "Astral", "Quantum", "Memory", "Dream"]

# ----- DATA SPLITTING FUNCTIONS -----
func split_data(content: String, rule_level: String = "LEVEL_0") -> Array:
	# Apply split rules to content
	var result = []
	
	if split_rules.has(rule_level):
		for symbol in split_rules[rule_level]:
			# Split content by symbol
			var parts = content.split(symbol)
			
			# Filter out empty parts
			for part in parts:
				if not part.strip_edges().is_empty():
					result.append(part.strip_edges())
	
	# Log operation if enabled
	if log_split_operations:
		print("Split data using rule level: " + rule_level)
		print("Input length: " + str(content.length()) + ", Output parts: " + str(result.size()))
	
	# Emit signal
	emit_signal("rules_applied", rule_level, content, result)
	
	return result

func process_file(file_path: String) -> Dictionary:
	if data_splitter:
		# Use data splitter to process file
		var success = data_splitter.process_file(file_path)
		
		# Get stats
		var stats = data_splitter.get_parse_stats()
		
		# Create visualization if successful
		if success:
			_create_visualizations_for_file(file_path)
		
		return {
			"success": success,
			"stats": stats,
			"file_path": file_path
		}
	
	return {
		"success": false,
		"error": "Data Splitter not available"
	}

func analyze_content(content: String) -> Dictionary:
	if data_splitter:
		return data_splitter.analyze_file_content(content)
	
	# Simplified analysis if data_splitter not available
	var analysis = {
		"total_chars": content.length(),
		"char_counts": {},
		"splits": []
	}
	
	# Count characters
	for c in content:
		if not analysis.char_counts.has(c):
			analysis.char_counts[c] = 0
		analysis.char_counts[c] += 1
	
	# Basic splitting
	var splits = content.split("[")
	for split in splits:
		if split.contains("]"):
			analysis.splits.append(split.split("]")[0])
	
	return analysis

func parse_jsh_file(content: String) -> Dictionary:
	if data_splitter:
		return data_splitter.parse_jsh_file(content)
	
	# Simplified parsing if data_splitter not available
	var blocks = {}
	var current_block = ""
	var lines = content.split(file_format.line_separator)
	
	for line in lines:
		if line.is_empty():
			continue
			
		if line.begins_with(file_format.block_start):
			var parts = line.split(file_format.dict_marker)
			if parts.size() >= 2:
				current_block = parts[0].trim_prefix(file_format.block_start).trim_suffix(file_format.block_end)
				blocks[current_block] = {
					"content": [],
					"metadata": {}
				}
		elif current_block != "":
			if blocks.has(current_block):
				blocks[current_block].content.append(line)
	
	return blocks

# ----- VISUALIZATION FUNCTIONS -----
func _create_visualizations_for_file(file_path: String):
	if not enable_data_visualization:
		return
	
	# Read file content
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		
		# Parse file
		var blocks = parse_jsh_file(content)
		
		# Create visualizations for each block
		for block_name in blocks:
			_create_block_visualization(block_name, blocks[block_name])
		
		# Create connections between blocks
		_create_block_connections(blocks)
	else:
		print("Error opening file: " + file_path)

func _create_block_visualization(block_name: String, block_data: Dictionary):
	# Create block node
	var block_node
	
	if data_block_scene:
		# Use provided scene
		block_node = data_block_scene.instantiate()
	else:
		# Create basic visualization
		block_node = Node3D.new()
		
		# Add a mesh instance
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "BlockMesh"
		mesh_instance.mesh = BoxMesh.new()
		
		# Apply material
		if block_material:
			mesh_instance.material_override = block_material
		else:
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.2, 0.5, 0.8)
			mesh_instance.material_override = material
		
		block_node.add_child(mesh_instance)
		
		# Add label for block name
		var label = Label3D.new()
		label.text = block_name
		label.pixel_size = 0.01
		label.position.y = 0.6
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		block_node.add_child(label)
	
	# Position the block in 3D space
	block_node.name = "Block_" + block_name
	block_node.position = _get_block_position(block_name)
	
	# Store reference
	active_blocks[block_name] = block_node
	
	# Add to visualization parent
	visualization_parent.add_child(block_node)
	
	# Create visualizations for content lines
	_create_content_visualizations(block_name, block_data.content, block_node.position)
	
	# Emit signal
	emit_signal("data_block_created", block_name, block_data)

func _create_content_visualizations(block_name: String, content: Array, block_position: Vector3):
	# Create visualization for each content line
	for i in range(content.size()):
		var line = content[i]
		var line_id = block_name + "_line_" + str(i)
		
		# Create line node
		var line_node
		
		if data_line_scene:
			# Use provided scene
			line_node = data_line_scene.instantiate()
		else:
			# Create basic visualization
			line_node = Node3D.new()
			
			if use_line_renderer:
				# Create line mesh
				var line_mesh = MeshInstance3D.new()
				line_mesh.name = "LineMesh"
				
				# Create a cylinder mesh
				var cylinder = CylinderMesh.new()
				cylinder.top_radius = 0.05
				cylinder.bottom_radius = 0.05
				cylinder.height = 1.0
				line_mesh.mesh = cylinder
				
				# Apply material
				if line_material:
					line_mesh.material_override = line_material
				else:
					var material = StandardMaterial3D.new()
					material.albedo_color = Color(0.8, 0.2, 0.5)
					line_mesh.material_override = material
				
				line_node.add_child(line_mesh)
			
			# Add label for line content
			var label = Label3D.new()
			label.text = line if line.length() < 20 else line.substr(0, 17) + "..."
			label.pixel_size = 0.005
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			line_node.add_child(label)
		
		# Position the line in 3D space
		line_node.name = "Line_" + line_id
		var line_position = block_position + Vector3(0, -0.2 - (i * 0.15), 0)
		line_node.position = line_position
		
		# Store reference
		active_lines[line_id] = {
			"node": line_node,
			"content": line,
			"block": block_name,
			"index": i
		}
		
		# Add to visualization parent
		visualization_parent.add_child(line_node)

func _create_block_connections(blocks: Dictionary):
	# Create connections between related blocks
	for block_name in blocks:
		var block_data = blocks[block_name]
		
		# Check for references to other blocks in content and metadata
		var referenced_blocks = _find_block_references(block_data, blocks.keys())
		
		# Create connections to referenced blocks
		for ref_block in referenced_blocks:
			_create_connection(block_name, ref_block)

func _find_block_references(block_data: Dictionary, all_blocks: Array) -> Array:
	var referenced_blocks = []
	
	# Check in content
	for line in block_data.content:
		for block_name in all_blocks:
			if line.contains(block_name) and not referenced_blocks.has(block_name):
				referenced_blocks.append(block_name)
	
	# Check in metadata
	if block_data.has("metadata"):
		for key in block_data.metadata:
			var value = block_data.metadata[key]
			
			if value is String:
				for block_name in all_blocks:
					if value.contains(block_name) and not referenced_blocks.has(block_name):
						referenced_blocks.append(block_name)
	
	return referenced_blocks

func _create_connection(source_block: String, target_block: String):
	# Skip if either block doesn't exist
	if not active_blocks.has(source_block) or not active_blocks.has(target_block):
		return
	
	# Check if connection already exists
	var connection_id = source_block + "_to_" + target_block
	if active_connections.has(connection_id):
		return
	
	# Create connection visualization
	var connection_node = Node3D.new()
	connection_node.name = "Connection_" + connection_id
	
	# Get block positions
	var source_pos = active_blocks[source_block].position
	var target_pos = active_blocks[target_block].position
	
	# Create line mesh
	var line_mesh = MeshInstance3D.new()
	line_mesh.name = "ConnectionMesh"
	
	# Calculate distance and direction
	var direction = target_pos - source_pos
	var distance = direction.length()
	var center = (source_pos + target_pos) / 2
	
	# Create a cylinder mesh
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.02
	cylinder.bottom_radius = 0.02
	cylinder.height = distance
	line_mesh.mesh = cylinder
	
	# Orient cylinder to point from source to target
	line_mesh.look_at_from_position(center, target_pos, Vector3.UP)
	line_mesh.rotate_object_local(Vector3.RIGHT, PI/2)
	
	# Apply material
	var material
	if line_material:
		material = line_material.duplicate()
	else:
		material = StandardMaterial3D.new()
		material.albedo_color = Color(0.2, 0.8, 0.2)
	
	line_mesh.material_override = material
	connection_node.add_child(line_mesh)
	
	# Store reference
	active_connections[connection_id] = {
		"node": connection_node,
		"source": source_block,
		"target": target_block
	}
	
	# Add to visualization parent
	visualization_parent.add_child(connection_node)

func _get_block_position(block_name: String) -> Vector3:
	# Generate a position based on block name (simplified)
	var hash_value = hash(block_name)
	var x = (hash_value % 1000) / 500.0 - 1.0
	var z = ((hash_value / 1000) % 1000) / 500.0 - 1.0
	
	# Scale position
	x *= 5.0 * visualization_scale
	z *= 5.0 * visualization_scale
	
	return Vector3(x, 0, z)

# ----- REALITY MAPPING FUNCTIONS -----
func _map_data_to_reality(reality_name: String):
	# Skip if Notepad3D integration not available
	if not notepad3d_integration:
		return
	
	# Choose mapping strategy based on reality type
	match reality_name:
		"Physical":
			_map_physical_reality()
		"Digital":
			_map_digital_reality()
		"Astral":
			_map_astral_reality()
		"Quantum":
			_map_quantum_reality()
		"Memory":
			_map_memory_reality()
		"Dream":
			_map_dream_reality()
		_:
			_map_generic_reality(reality_name)
	
	# Store reality mapping
	current_realities[reality_name] = {
		"blocks": active_blocks.keys(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Emit signal
	emit_signal("reality_data_mapped", reality_name, active_blocks.keys())

func _map_physical_reality():
	# Map data blocks to physical reality as tangible objects
	if active_blocks.size() > 0:
		for block_name in active_blocks:
			_manifgest_block_as_entity(block_name, "physical", Vector3(0, 1, 0))

func _map_digital_reality():
	# Map data blocks to digital reality as code structures
	if active_blocks.size() > 0:
		for block_name in active_blocks:
			_manifgest_block_as_entity(block_name, "digital", Vector3(0, 0.5, 0))

func _map_astral_reality():
	# Map data blocks to astral reality as ethereal concepts
	if active_blocks.size() > 0:
		for block_name in active_blocks:
			_manifgest_block_as_entity(block_name, "astral", Vector3(0, 2, 0))

func _map_quantum_reality():
	# Map data blocks to quantum reality as probability entities
	if active_blocks.size() > 0:
		for block_name in active_blocks:
			_manifgest_block_as_entity(block_name, "quantum", Vector3(0, 0.1, 0))

func _map_memory_reality():
	# Map data blocks to memory reality as persistent records
	if active_blocks.size() > 0:
		for block_name in active_blocks:
			_manifgest_block_as_entity(block_name, "memory", Vector3(0, 0.3, 0))

func _map_dream_reality():
	# Map data blocks to dream reality as abstract concepts
	if active_blocks.size() > 0:
		for block_name in active_blocks:
			_manifgest_block_as_entity(block_name, "dream", Vector3(0, 3, 0))

func _map_generic_reality(reality_name: String):
	# Map data blocks to a generic reality
	if active_blocks.size() > 0:
		for block_name in active_blocks:
			_manifgest_block_as_entity(block_name, reality_name.to_lower(), Vector3(0, 1, 0))

func _manifgest_block_as_entity(block_name: String, reality_type: String, offset: Vector3 = Vector3.ZERO):
	# Skip if Notepad3D integration not available
	if not notepad3d_integration:
		return
	
	# Manifest the block as an entity in the specified reality
	if notepad3d_integration.has_method("manifest_word"):
		# Change to target reality if needed
		var current_reality = ""
		
		if notepad3d_integration.has_property("current_reality_type"):
			current_reality = notepad3d_integration.current_reality_type
		
		if current_reality != reality_type and notepad3d_integration.has_method("change_reality"):
			notepad3d_integration.change_reality(reality_type)
		
		# Generate position based on block visualization position
		var position = active_blocks[block_name].position + offset
		
		# Manifest block as word entity
		var entity = notepad3d_integration.manifest_word(block_name, position)
		
		# Log if successful
		if entity:
			print("Manifested block '" + block_name + "' as entity in " + reality_type + " reality")
			
			# Try to create connections
			_create_entity_connections(block_name, reality_type)
	else:
		print("Notepad3D integration doesn't support manifest_word method")

func _create_entity_connections(block_name: String, reality_type: String):
	# Skip if Notepad3D integration not available
	if not notepad3d_integration:
		return
	
	# Find connections from this block
	for connection_id in active_connections:
		var connection = active_connections[connection_id]
		
		if connection.source == block_name:
			# Find target block
			var target_block = connection.target
			
			# Connect entities if both exist in the current reality
			if notepad3d_integration.has_method("connect_words"):
				var result = notepad3d_integration.find_word_in_reality(block_name, reality_type)
				var target_result = notepad3d_integration.find_word_in_reality(target_block, reality_type)
				
				if result.found and target_result.found:
					notepad3d_integration.connect_words(result.entity_id, target_result.entity_id, "data_connection")
					print("Connected entities '" + block_name + "' to '" + target_block + "' in " + reality_type + " reality")

# ----- INTEGRATION COMMANDS -----
func process_command(command: String) -> Dictionary:
	# Process data splitter related commands
	
	# Split command and parameters
	var parts = command.split(" ", false, 1)
	var cmd = parts[0].to_lower()
	var params = ""
	if parts.size() > 1:
		params = parts[1]
	
	match cmd:
		"/split":
			# Split data using specified rule level
			var split_parts = params.split(" ", false, 1)
			var rule_level = "LEVEL_0"
			var content = params
			
			if split_parts.size() >= 2:
				rule_level = split_parts[0].to_upper()
				content = split_parts[1]
			
			var result = split_data(content, rule_level)
			
			return {
				"success": true,
				"message": "Split into " + str(result.size()) + " parts using rule level " + rule_level,
				"parts": result
			}
			
		"/analyze":
			# Analyze content
			var analysis = analyze_content(params)
			
			return {
				"success": true,
				"message": "Content analysis complete: " + str(analysis.total_chars) + " chars, " + 
							str(analysis.splits.size()) + " blocks",
				"analysis": analysis
			}
			
		"/map":
			# Map data to a specific reality
			var reality_name = params
			if reality_name.strip_edges().is_empty():
				return {
					"success": false,
					"message": "Usage: /map [reality_name]"
				}
			
			_map_data_to_reality(reality_name)
			
			return {
				"success": true,
				"message": "Mapped data to " + reality_name + " reality"
			}
			
		"/stats":
			# Display data splitter stats
			if data_splitter:
				var stats = data_splitter.get_parse_stats()
				
				return {
					"success": true,
					"message": "Data Splitter Stats: " + 
								str(stats.files_processed) + " files processed, " +
								str(stats.successful_parses) + " successful, " +
								str(stats.failed_parses) + " failed, " +
								str(stats.total_blocks) + " blocks",
					"stats": stats
				}
			else:
				return {
					"success": false,
					"message": "Data Splitter not available"
				}
				
		"/visualize":
			# Toggle visualization mode
			if params.to_lower() == "2d":
				current_visualization_mode = "2d"
				_update_visualization_mode("2d")
				
				return {
					"success": true,
					"message": "Switched to 2D visualization mode"
				}
			elif params.to_lower() == "3d":
				current_visualization_mode = "3d"
				_update_visualization_mode("3d")
				
				return {
					"success": true,
					"message": "Switched to 3D visualization mode"
				}
			else:
				return {
					"success": false,
					"message": "Usage: /visualize [2d|3d]"
				}
				
		"/clear":
			# Clear all visualizations
			_clear_visualizations()
			
			return {
				"success": true,
				"message": "All visualizations cleared"
			}
				
		"/help":
			# Display available commands
			return {
				"success": true,
				"message": "Data Splitter Commands:\n" +
							"/split [LEVEL_0-3] [content] - Split content using rule level\n" +
							"/analyze [content] - Analyze content structure\n" +
							"/map [reality_name] - Map data to a specific reality\n" +
							"/stats - Display data splitter statistics\n" +
							"/visualize [2d|3d] - Toggle visualization mode\n" +
							"/clear - Clear all visualizations\n" +
							"/help - Display this help"
			}
			
	# Unknown command
	return {
		"success": false,
		"message": "Unknown data splitter command. Type /help for available commands."
	}

func _update_visualization_mode(mode: String):
	# Update visualization based on mode
	visualization_parent.visible = (mode == "3d")
	
	# Emit signal
	emit_signal("visualization_updated")

func _clear_visualizations():
	# Remove all visualization nodes
	for block_name in active_blocks:
		active_blocks[block_name].queue_free()
	
	for line_id in active_lines:
		active_lines[line_id].node.queue_free()
	
	for connection_id in active_connections:
		active_connections[connection_id].node.queue_free()
	
	# Clear dictionaries
	active_blocks.clear()
	active_lines.clear()
	active_connections.clear()
	
	# Emit signal
	emit_signal("visualization_updated")

# ----- SIGNAL HANDLERS -----
func _on_reality_changed(new_reality, old_reality):
	print("Reality changed from " + old_reality + " to " + new_reality)
	
	# Update visualizations based on new reality
	if current_realities.has(new_reality):
		# Show only blocks mapped to this reality
		for block_name in active_blocks:
			active_blocks[block_name].visible = current_realities[new_reality].blocks.has(block_name)
		
		# Update connections visibility
		for connection_id in active_connections:
			var connection = active_connections[connection_id]
			var source_visible = active_blocks[connection.source].visible
			var target_visible = active_blocks[connection.target].visible
			
			connection.node.visible = source_visible and target_visible
	else:
		# Reality not mapped yet, map it
		_map_data_to_reality(new_reality)

func _on_word_manifested(word, entity, reality_type, dimension):
	# Check if word corresponds to a data block
	if active_blocks.has(word):
		print("Data block '" + word + "' manifested as entity in " + reality_type + " reality")
		
		# Try to create connections
		_create_entity_connections(word, reality_type)

func _on_parsing_completed(stats):
	print("Data parsing completed: " + str(stats.processed_files.size()) + " files processed")
	
	# Display stats if enabled
	if display_split_stats:
		_display_split_stats(stats)
	
	# Emit signal
	emit_signal("data_split_completed", stats)

func _on_error_detected(error):
	print("Data parsing error: " + error.message if error.has("message") else "Unknown error")
	
	# Log to console if available
	if console:
		var output = console.get_node_or_null("Panel/OutputLabel")
		if output and output is RichTextLabel:
			output.text += "[color=#ff0000]Data parsing error: " + error.message + "[/color]\n"

func _display_split_stats(stats):
	# Display stats to console if available
	if console:
		var output = console.get_node_or_null("Panel/OutputLabel")
		if output and output is RichTextLabel:
			output.text += "[color=#88ff99]Data Split Stats:[/color]\n"
			output.text += "Files processed: " + str(stats.stats.files_processed) + "\n"
			output.text += "Successful: " + str(stats.stats.successful_parses) + "\n"
			output.text += "Failed: " + str(stats.stats.failed_parses) + "\n"
			output.text += "Total blocks: " + str(stats.stats.total_blocks) + "\n"