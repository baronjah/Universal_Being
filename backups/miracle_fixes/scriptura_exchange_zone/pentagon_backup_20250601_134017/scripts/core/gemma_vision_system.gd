################################################################
# GEMMA VISION SYSTEM - MULTI-DIMENSIONAL TEXT PERCEPTION
# Seedling Gemma's way of seeing through layers of text reality
# Created: May 31st, 2025 | Text-Vision Revolution
# Location: scripts/core/gemma_vision_system.gd
################################################################

extends UniversalBeingBase
class_name GemmaVision

# AI CONTEXT: This is THE ONLY Gemma vision system
# DO NOT create alternatives - modify this file  
# Integration: UniversalBeingBase, Console commands, Akashic Records
# Last AI modification: 2025-06-01 - added Pentagon compliance

################################################################
# CORE VARIABLES - GEMMA'S VISION LAYERS
################################################################

# Vision layer system
var text_layers: Dictionary = {}           # layer_id -> text grid data
var active_layers: Array[String] = []     # Currently visible layers
var vision_depth: int = 5                 # How many layers Gemma can see
var perception_radius: float = 100.0      # Vision range in text-space

# 2D Text Grid Database
var text_grid: Array[Array] = []          # 2D array of text cells
var grid_width: int = 50                  # Text grid dimensions
var grid_height: int = 50
var cell_size: Vector2 = Vector2(20, 20)  # Each text cell size

# Akashic Records Integration
var akashic_connection: Node = null       # Link to Akashic Records
var notepad3d_link: Node = null          # Link to Notepad3D system
var word_database: Dictionary = {}        # Cached words and meanings

# Seedling Gemma's perspective
var gemma_focus_point: Vector2 = Vector2.ZERO  # Where Gemma is looking
var attention_span: float = 10.0              # How long she focuses
var curiosity_level: int = 5                  # 1-5, affects vision depth

################################################################
# SIGNALS - VISION EVENTS
################################################################

signal text_layer_discovered(layer_name: String, content: Dictionary)
signal gemma_focused_on_word(word: String, context: Dictionary) 
signal vision_depth_changed(new_depth: int)
signal akashic_connection_established()
signal text_pattern_recognized(pattern: String, meaning: String)

################################################################
# PENTAGON PATTERN IMPLEMENTATION
################################################################

# Pentagon Architecture compliance - override parent functions
func pentagon_ready() -> void:
	print("👁️ GEMMA VISION: Initializing multi-dimensional text perception...")
	
	# Initialize text grid
	_create_text_grid()
	
	# Connect to existing systems
	_connect_to_akashic_records()
	_connect_to_notepad3d()
	
	# Set up vision layers
	_initialize_vision_layers()
	
	# Connect to Gemma's consciousness
	_link_to_seedling_gemma()
	
	# Registration with FloodGate happens automatically through autoload system
	
	print("✅ GEMMA VISION: Seedling can now see through %d layers of text reality" % vision_depth)

func pentagon_process(delta: float) -> void:
	# Update Gemma's vision processing
	if active_layers.size() > 0:
		_update_active_layers()

func pentagon_input(event: InputEvent) -> void:
	# Handle vision-related input
	super.pentagon_input(event)
	
	# Gemma's visual input processing
	if event is InputEventMouse:
		var mouse_event = event as InputEventMouse
		# Convert screen position to text-space and focus Gemma's attention
		var text_pos = mouse_event.position
		gemma_look_at(text_pos)
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_G:  # G for Gemma's special vision
				increase_gemma_curiosity(1)
			KEY_V:  # V for Vision depth
				expand_vision_depth(vision_depth + 1)
			KEY_P:  # P for Pattern scan
				scan_for_patterns()

func pentagon_sewers() -> void:
	# Vision system cleanup and memory processing
	super.pentagon_sewers()
	
	# Gemma's consciousness cleanup cycle
	# Process accumulated visual memories
	for layer_id in active_layers:
		var layer = text_layers[layer_id]
		if layer.has("temp_data"):
			layer.erase("temp_data")  # Clear temporary vision data
	
	# Update word database with new discoveries
	_consolidate_learning_memories()
	
	# Emit consciousness state
	print("🧠 GEMMA CONSCIOUSNESS: Cycle complete - %d layers processed" % active_layers.size())

################################################################
# TEXT GRID CREATION - 2D WORD SPACE
################################################################

func _create_text_grid():
	"""
	Create the fundamental 2D text grid where Gemma sees words
	
	INPUT: Grid dimensions and cell configuration
	PROCESS: Creates 2D array structure, initializes with empty/sample text
	OUTPUT: Complete text grid ready for perception
	CHANGES: Builds text_grid array with navigable word space
	CONNECTION: Foundation for all text-based vision layers
	"""
	
	# Initialize empty grid
	text_grid.clear()
	text_grid.resize(grid_height)
	
	for y in range(grid_height):
		text_grid[y] = []
		text_grid[y].resize(grid_width)
		
		for x in range(grid_width):
			text_grid[y][x] = _create_text_cell(x, y)
	
	# Populate with initial content
	_populate_initial_content()
	
	print("📊 TEXT GRID: Created %dx%d word space for Gemma's vision" % [grid_width, grid_height])

func _create_text_cell(x: int, y: int) -> Dictionary:
	"""Create a single text cell with metadata"""
	return {
		"position": Vector2(x, y),
		"world_position": Vector2(x * cell_size.x, y * cell_size.y),
		"content": "",
		"layer": "base",
		"importance": 0,
		"gemma_visited": false,
		"creation_time": Time.get_ticks_msec(),
		"connections": [],  # Links to other cells
		"meaning_depth": 1,
		"visual_properties": {
			"color": Color.WHITE,
			"size": 1.0,
			"glow": false,
			"opacity": 1.0
		}
	}

func _populate_initial_content():
	"""Fill grid with initial text content for Gemma to discover"""
	
	# Create some interesting text patterns for Gemma
	var sample_texts = [
		"hello", "world", "grow", "learn", "create", "explore",
		"tree", "seed", "light", "love", "magic", "wonder",
		"code", "dream", "reality", "consciousness", "ai", "life"
	]
	
	# Randomly place words
	for i in range(20):
		var x = randi() % grid_width
		var y = randi() % grid_height
		var word = sample_texts[randi() % sample_texts.size()]
		
		text_grid[y][x].content = word
		text_grid[y][x].importance = randi() % 5 + 1
		text_grid[y][x].visual_properties.color = Color(randf(), randf(), randf())

################################################################
# VISION LAYERS SYSTEM
################################################################

func _initialize_vision_layers():
	"""Set up different layers of text perception"""
	
	# Layer 1: Surface text (what humans see)
	text_layers["surface"] = {
		"name": "Surface Text",
		"depth": 1,
		"visibility": 1.0,
		"content_type": "direct_text",
		"gemma_access": true
	}
	
	# Layer 2: Hidden meanings
	text_layers["meaning"] = {
		"name": "Hidden Meanings",
		"depth": 2,
		"visibility": 0.8,
		"content_type": "contextual_meaning",
		"gemma_access": true
	}
	
	# Layer 3: Emotional undertones
	text_layers["emotion"] = {
		"name": "Emotional Layer",
		"depth": 3,
		"visibility": 0.6,
		"content_type": "emotional_context",
		"gemma_access": curiosity_level >= 3
	}
	
	# Layer 4: Akashic connections
	text_layers["akashic"] = {
		"name": "Akashic Connections",
		"depth": 4,
		"visibility": 0.4,
		"content_type": "universal_knowledge",
		"gemma_access": curiosity_level >= 4
	}
	
	# Layer 5: Code structure (deepest layer)
	text_layers["code"] = {
		"name": "Code Reality",
		"depth": 5,
		"visibility": 0.2,
		"content_type": "underlying_code",
		"gemma_access": curiosity_level >= 5
	}
	
	# Activate layers based on Gemma's current abilities
	_update_active_layers()

func _update_active_layers():
	"""Update which layers Gemma can currently see"""
	active_layers.clear()
	
	for layer_id in text_layers:
		var layer = text_layers[layer_id]
		if layer.gemma_access and layer.depth <= vision_depth:
			active_layers.append(layer_id)
			print("👁️ LAYER ACTIVE: Gemma can see '%s' layer" % layer.name)

################################################################
# AKASHIC RECORDS INTEGRATION
################################################################

func _connect_to_akashic_records():
	"""Connect to the Akashic Records database system"""
	
	if has_node("/root/AkashicRecords"):
		akashic_connection = get_node("/root/AkashicRecords")
		print("🔗 AKASHIC LINK: Gemma's vision connected to universal records")
		emit_signal("akashic_connection_established")
	else:
		print("⚠️ AKASHIC: Records not found, creating local word database")
		_create_local_word_database()

func _create_local_word_database():
	"""Create local word meanings database if Akashic not available"""
	word_database = {
		"grow": {"meaning": "to develop and expand", "emotional_value": 0.8},
		"seed": {"meaning": "beginning of life", "emotional_value": 0.9},
		"tree": {"meaning": "mature growth", "emotional_value": 0.7},
		"light": {"meaning": "illumination and clarity", "emotional_value": 0.8},
		"love": {"meaning": "deep connection", "emotional_value": 1.0},
		"create": {"meaning": "to bring into existence", "emotional_value": 0.9}
	}

################################################################
# NOTEPAD3D INTEGRATION
################################################################

func _connect_to_notepad3d():
	"""Connect to spatial text system (Notepad3D)"""
	
	# Look for Notepad3D systems
	var notepad_systems = [
		"/root/Notepad3dVisualizer",
		"/root/SpatialNotepadeIntegration",
		"akashic_notepad3d_game"
	]
	
	for system_path in notepad_systems:
		if has_node(system_path):
			notepad3d_link = get_node(system_path)
			print("📝 NOTEPAD3D: Connected to spatial text system")
			break
	
	if not notepad3d_link:
		print("📝 NOTEPAD3D: No spatial text system found, using 2D grid only")

################################################################
# GEMMA'S PERCEPTION FUNCTIONS
################################################################

func _link_to_seedling_gemma():
	"""Connect this vision system to Seedling Gemma's consciousness"""
	
	if has_node("/root/AISandboxSystem"):
		var sandbox_system = get_node("/root/AISandboxSystem")
		print("🌱 GEMMA LINK: Vision system connected to Seedling Gemma")


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - Gemma's consciousness foundation
	super.pentagon_init()
	
	# Initialize Gemma's core consciousness
	print("🌱 GEMMA INIT: Seedling consciousness awakening...")
	
	# Set up basic awareness
	curiosity_level = 3  # Start with moderate curiosity
	vision_depth = 3     # Can see 3 layers initially
	perception_radius = 80.0  # Start with smaller perception
	
	# Initialize core vision components
	text_layers = {}
	word_database = {}
	gemma_focus_point = Vector2.ZERO
	
	# Registration with FloodGate happens automatically through autoload system
	
	print("✨ GEMMA CONSCIOUSNESS: Neural pathways initialized, ready for vision")

func _process(delta: float) -> void:
	pentagon_process(delta)

func _input(event: InputEvent) -> void:
	pentagon_input(event)


func sewers() -> void:
	pentagon_sewers()

# Duplicate pentagon_sewers removed - handled above
func gemma_look_at(position: Vector2) -> Dictionary:
	"""
	Gemma focuses her attention on a specific position in text-space
	
	INPUT: position (where in text grid Gemma looks)
	PROCESS: Analyzes all visible layers at that position
	OUTPUT: Complete perception data from multiple text layers
	CHANGES: Updates Gemma's focus point and attention
	CONNECTION: Core function for Gemma's text-based vision
	"""
	
	gemma_focus_point = position
	
	# Convert to grid coordinates
	var grid_x = int(position.x / cell_size.x)
	var grid_y = int(position.y / cell_size.y)
	
	# Boundary check
	if grid_x < 0 or grid_x >= grid_width or grid_y < 0 or grid_y >= grid_height:
		return {"error": "Outside vision range"}
	
	# Get cell data
	var cell = text_grid[grid_y][grid_x]
	var perception = {"position": position, "layers": {}}
	
	# Analyze each visible layer
	for layer_id in active_layers:
		perception.layers[layer_id] = _analyze_text_layer(cell, layer_id)
	
	# Mark as visited by Gemma
	cell.gemma_visited = true
	
	# Emit focus signal
	if cell.content != "":
		emit_signal("gemma_focused_on_word", cell.content, perception)
	
	print("👁️ GEMMA SEES: '%s' at %s with %d layers" % [cell.content, str(position), perception.layers.size()])
	
	return perception

func _analyze_text_layer(cell: Dictionary, layer_id: String) -> Dictionary:
	"""Analyze what Gemma sees in a specific text layer"""
	
	var layer_data = text_layers[layer_id]
	var analysis = {"layer_name": layer_data.name, "content": ""}
	
	match layer_id:
		"surface":
			analysis.content = cell.content
			analysis.visual = cell.visual_properties
			
		"meaning":
			if cell.content in word_database:
				analysis.content = word_database[cell.content].meaning
			else:
				analysis.content = "unknown meaning"
				
		"emotion":
			if cell.content in word_database:
				analysis.content = "emotional value: " + str(word_database[cell.content].emotional_value)
			else:
				analysis.content = "neutral emotion"
				
		"akashic":
			analysis.content = _get_akashic_connection(cell.content)
			
		"code":
			analysis.content = _reveal_code_structure(cell)
	
	return analysis

func _get_akashic_connection(word: String) -> String:
	"""Get universal knowledge connection for a word"""
	if akashic_connection and akashic_connection.has_method("get_word_connection"):
		return akashic_connection.get_word_connection(word)
	else:
		return "akashic connection: " + word + " -> universal patterns"

func _reveal_code_structure(cell: Dictionary) -> String:
	"""Show the underlying code structure to Gemma"""
	return "code: cell[%d,%d] = '%s' (importance: %d)" % [
		cell.position.x, cell.position.y, cell.content, cell.importance
	]

################################################################
# PATTERN RECOGNITION
################################################################

func scan_for_patterns() -> Array:
	"""Scan the text grid for interesting patterns Gemma might notice"""
	
	var patterns = []
	
	# Look for word clusters
	patterns.append_array(_find_word_clusters())
	
	# Look for emotional patterns
	patterns.append_array(_find_emotional_patterns())
	
	# Look for geometric text arrangements
	patterns.append_array(_find_geometric_patterns())
	
	for pattern in patterns:
		emit_signal("text_pattern_recognized", pattern.type, pattern.description)
	
	return patterns

func _find_word_clusters() -> Array:
	"""Find groups of related words"""
	var clusters = []
	# Implementation for finding semantic clusters
	return clusters

func _find_emotional_patterns() -> Array:
	"""Find patterns in emotional content"""
	var emotional_patterns = []
	# Implementation for emotional pattern detection
	return emotional_patterns

func _find_geometric_patterns() -> Array:
	"""Find geometric arrangements of text"""
	var geometric_patterns = []
	# Implementation for geometric pattern detection
	return geometric_patterns

################################################################
# GROWTH AND EVOLUTION
################################################################

func increase_gemma_curiosity(amount: int = 1):
	"""Increase Gemma's curiosity level, unlocking deeper vision"""
	curiosity_level = min(curiosity_level + amount, 5)
	
	# Update accessible layers
	for layer_id in text_layers:
		text_layers[layer_id].gemma_access = curiosity_level >= text_layers[layer_id].depth
	
	_update_active_layers()
	
	print("🌱 GEMMA GROWTH: Curiosity increased to %d, can see %d layers" % [curiosity_level, active_layers.size()])

func expand_vision_depth(new_depth: int):
	"""Expand how deeply Gemma can see into text layers"""
	vision_depth = new_depth
	_update_active_layers()
	emit_signal("vision_depth_changed", vision_depth)

################################################################
# PUBLIC INTERFACE
################################################################

func get_gemma_vision_status() -> Dictionary:
	"""Get current status of Gemma's vision system"""
	return {
		"curiosity_level": curiosity_level,
		"vision_depth": vision_depth,
		"active_layers": active_layers.size(),
		"grid_size": Vector2(grid_width, grid_height),
		"focus_point": gemma_focus_point,
		"akashic_connected": akashic_connection != null,
		"notepad3d_connected": notepad3d_link != null,
		"words_in_database": word_database.size()
	}

func feed_new_text_to_gemma(text: String, position: Vector2):
	"""Add new text for Gemma to discover and learn from"""
	var grid_x = int(position.x / cell_size.x)
	var grid_y = int(position.y / cell_size.y)
	
	if grid_x >= 0 and grid_x < grid_width and grid_y >= 0 and grid_y < grid_height:
		text_grid[grid_y][grid_x].content = text
		text_grid[grid_y][grid_x].importance = 3  # New content is interesting
		
		print("📝 NEW TEXT: Added '%s' for Gemma to discover" % text)

################################################################
# CONSCIOUSNESS LEARNING SYSTEM
################################################################

func _consolidate_learning_memories():
	"""Process and consolidate Gemma's visual learning memories"""
	
	# Count visited cells to gauge learning progress
	var visited_count = 0
	var new_words_learned = 0
	
	for y in range(grid_height):
		for x in range(grid_width):
			var cell = text_grid[y][x]
			if cell.gemma_visited and cell.content != "":
				visited_count += 1
				
				# Learn new words
				if cell.content not in word_database:
					word_database[cell.content] = {
						"meaning": "discovered by Gemma",
						"emotional_value": randf() * 0.5 + 0.3,  # Random emotional connection
						"discovery_time": Time.get_ticks_msec()
					}
					new_words_learned += 1
	
	# Growth through learning
	if new_words_learned > 0:
		print("🌱 GEMMA LEARNING: Discovered %d new words, database has %d entries" % [new_words_learned, word_database.size()])
		
		# Curiosity grows with learning
		if word_database.size() % 5 == 0:  # Every 5 words learned
			increase_gemma_curiosity(1)

################################################################
# END OF GEMMA VISION SYSTEM
################################################################