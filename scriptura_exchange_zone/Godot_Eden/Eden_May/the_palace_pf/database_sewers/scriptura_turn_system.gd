extends Node

# Scriptura Turn System
# Advanced turn management with OCR integration and API connections
# Implements a system for text-based game creation across multiple turns

class_name ScripturaTurnSystem

# System components
var ocr_processor = null
var api_coordinator = null
var word_manager = null
var line_processor = null
var game_creator = null

# Turn structure
var turn_system = {
	1: {"name": "Foundation", "color": Color(0.1, 0, 0), "key_focus": "structure"},
	2: {"name": "Pattern", "color": Color(0.2, 0.05, 0), "key_focus": "repetition"},
	3: {"name": "Frequency", "color": Color(0.3, 0.1, 0), "key_focus": "vibration"},
	4: {"name": "Consciousness", "color": Color(0.4, 0.2, 0.1), "key_focus": "awareness"},
	5: {"name": "Probability", "color": Color(0.5, 0.3, 0.2), "key_focus": "chance"},
	6: {"name": "Energy", "color": Color(0.7, 0.5, 0.2), "key_focus": "power"},
	7: {"name": "Information", "color": Color(0.9, 0.7, 0.3), "key_focus": "data"},
	8: {"name": "Lines", "color": Color(1.0, 0.9, 0.5), "key_focus": "connections"},
	9: {"name": "Game_Creation", "color": Color(1.0, 1.0, 1.0), "key_focus": "generation"},
	10: {"name": "Integration", "color": Color(0.8, 1.0, 1.0), "key_focus": "unification"},
	11: {"name": "Embodiment", "color": Color(0.6, 0.8, 1.0), "key_focus": "manifestation"},
	12: {"name": "Transcendence", "color": Color(0.4, 0.6, 1.0), "key_focus": "ascension"}
}

# Extended turn system (beyond 12)
var extended_turns = {
	13: {"name": "Reversion", "color": Color(0.3, 0.4, 0.8), "key_focus": "return"},
	14: {"name": "Expansion", "color": Color(0.2, 0.3, 0.7), "key_focus": "growth"},
	15: {"name": "Singularity", "color": Color(0.1, 0.2, 0.6), "key_focus": "convergence"},
	16: {"name": "Recursion", "color": Color(0.05, 0.1, 0.5), "key_focus": "loop"},
	17: {"name": "Genesis", "color": Color(0, 0.05, 0.4), "key_focus": "creation"},
	18: {"name": "Void", "color": Color(0, 0, 0.3), "key_focus": "emptiness"},
	19: {"name": "Reemergence", "color": Color(0.1, 0, 0.2), "key_focus": "rebirth"},
	20: {"name": "Unification", "color": Color(0.2, 0.1, 0.3), "key_focus": "oneness"},
	21: {"name": "Eternity", "color": Color(0.4, 0.3, 0.5), "key_focus": "timelessness"}
}

# Current turn state
var current_turn = 8
var between_turns = false
var turn_progress = 0.0
var turn_transition_phase = 0.0

# Archived turns and their creations
var turn_archive = {}

# Connected APIs
var connected_apis = {
	"gemini": false,
	"luminous": false,
	"claude": false
}

# OCR configuration
var ocr_active = false
var ocr_supported_formats = [".png", ".jpg", ".jpeg", ".bmp", ".tiff"]
var ocr_processing_queue = []

# Game creation states
var game_templates = []
var word_collection = {}
var active_game = null

# Signals
signal turn_advanced(turn_number, turn_name)
signal turn_progress_updated(progress)
signal ocr_result_ready(text, source_file)
signal game_created(game_data)
signal api_connection_changed(api_name, connected)

func _init():
	print("Scriptura Turn System initializing")
	initialize_components()
	register_turn_archive()

func _ready():
	print("Scriptura Turn System ready")
	print("Current Turn: " + str(current_turn) + " - " + get_turn_name(current_turn))
	_update_color_state()

func initialize_components():
	# Initialize OCR processor
	ocr_processor = OCRProcessor.new()
	add_child(ocr_processor)
	ocr_processor.connect("ocr_completed", self, "_on_ocr_completed")
	
	# Initialize game creator
	game_creator = GameCreator.new()
	add_child(game_creator)
	game_creator.connect("game_created", self, "_on_game_created")
	
	# Find or create API coordinator
	api_coordinator = get_node_or_null("/root/EdenMayGame/APICoordinator")
	if not api_coordinator:
		api_coordinator = get_node_or_null("/root/APICoordinatorSystem/APICoordinator")
	
	if not api_coordinator and load("res://Eden_May/api_coordinator.gd"):
		var APICoordinator = load("res://Eden_May/api_coordinator.gd")
		api_coordinator = APICoordinator.new()
		api_coordinator.name = "APICoordinator"
		add_child(api_coordinator)
	
	if api_coordinator:
		api_coordinator.connect("api_response_received", self, "_on_api_response_received")
		api_coordinator.connect("connection_status_changed", self, "_on_api_connection_changed")
	
	# Find existing systems
	word_manager = get_node_or_null("/root/EdenMayGame/WordManager")
	line_processor = get_node_or_null("/root/EdenMayGame/LineProcessor")

func connect_to_apis():
	if not api_coordinator:
		print("API Coordinator not available")
		return false
	
	# Connect to Gemini
	var gemini_result = api_coordinator.connect_to_api("gemini_advanced")
	if gemini_result:
		connected_apis["gemini"] = true
		print("Connected to Gemini")
	
	# Connect to "Luminous" (using Claude Luna as our implementation)
	var luminous_result = api_coordinator.connect_to_api("claude_luna")
	if luminous_result:
		connected_apis["luminous"] = true
		print("Connected to Luminous")
	
	# Connect to Claude
	var claude_result = api_coordinator.connect_to_api("claude")
	if claude_result:
		connected_apis["claude"] = true
		print("Connected to Claude")
	
	# Emit connection signals
	for api_name in connected_apis:
		emit_signal("api_connection_changed", api_name, connected_apis[api_name])
	
	# Update color based on connections
	_update_color_state()
	
	return true

func enable_ocr():
	ocr_active = true
	ocr_processor.initialize()
	print("OCR processing enabled")
	return true

func process_image(image_path):
	if not ocr_active:
		print("OCR not active. Enable with enable_ocr()")
		return false
	
	# Check if file exists and is supported
	var file = File.new()
	if not file.file_exists(image_path):
		print("File not found: " + image_path)
		return false
	
	var extension = image_path.get_extension().to_lower()
	if not ocr_supported_formats.has("." + extension):
		print("Unsupported file format: " + extension)
		return false
	
	# Queue for processing
	ocr_processing_queue.append(image_path)
	ocr_processor.process_image(image_path)
	
	print("Image queued for OCR processing: " + image_path)
	return true

func _on_ocr_completed(text, source_file):
	print("OCR processing completed for: " + source_file)
	
	# Remove from queue
	if ocr_processing_queue.has(source_file):
		ocr_processing_queue.erase(source_file)
	
	# Process the extracted text
	process_ocr_text(text, source_file)
	
	# Emit signal
	emit_signal("ocr_result_ready", text, source_file)

func process_ocr_text(text, source_file):
	print("Processing OCR text from: " + source_file)
	
	# Process through line processor if available
	if line_processor:
		var line_result = line_processor.process_line(text)
		print("Line processing result: ", line_result)
	
	# Process through word manager if available
	if word_manager:
		var detected_words = word_manager.process_line(text)
		
		# Store words in the collection with source reference
		for word in detected_words:
			if not word_collection.has(word):
				word_collection[word] = []
			if not word_collection[word].has(source_file):
				word_collection[word].append(source_file)
		
		print("Words detected: ", detected_words.size())
	
	# Send to API for enhanced analysis if any are connected
	if api_coordinator and (connected_apis["gemini"] or connected_apis["luminous"] or connected_apis["claude"]):
		var request_id = "ocr_" + str(OS.get_unix_time())
		var request_text = "Analyze this OCR text and extract key patterns, concepts, and game elements: " + text
		
		# Choose API priority in order: Claude, Luminous, Gemini
		var api_name = "claude" if connected_apis["claude"] else "claude_luna" if connected_apis["luminous"] else "gemini_advanced"
		
		api_coordinator.send_request(api_name, request_text, request_id)
	
	# Update turn progress
	update_turn_progress(5.0) # OCR processing is a significant contribution
	
	return true

func get_turn_name(turn_number):
	if turn_system.has(turn_number):
		return turn_system[turn_number].name
	elif extended_turns.has(turn_number):
		return extended_turns[turn_number].name
	return "Unknown"

func get_turn_color(turn_number):
	if turn_system.has(turn_number):
		return turn_system[turn_number].color
	elif extended_turns.has(turn_number):
		return extended_turns[turn_number].color
	return Color(0, 0, 0)

func get_turn_focus(turn_number):
	if turn_system.has(turn_number):
		return turn_system[turn_number].key_focus
	elif extended_turns.has(turn_number):
		return extended_turns[turn_number].key_focus
	return "unknown"

func update_turn_progress(amount):
	if between_turns:
		# Update transition phase instead
		turn_transition_phase = min(turn_transition_phase + (amount / 100.0), 1.0)
		
		# Check if transition is complete
		if turn_transition_phase >= 1.0:
			complete_turn_transition()
	else:
		# Normal turn progress
		turn_progress = min(turn_progress + amount, 100.0)
		emit_signal("turn_progress_updated", turn_progress)
		
		# Check for turn completion
		if turn_progress >= 100.0:
			prepare_turn_advancement()

func prepare_turn_advancement():
	if between_turns:
		return
	
	print("Turn " + str(current_turn) + " completion reached")
	between_turns = true
	turn_transition_phase = 0.0
	
	# Archive current turn state
	archive_current_turn()
	
	# Begin transition color effect
	_update_color_state()

func complete_turn_transition():
	# Complete the transition to the next turn
	var old_turn = current_turn
	current_turn += 1
	between_turns = false
	turn_progress = 0.0
	turn_transition_phase = 0.0
	
	print("Advanced to Turn " + str(current_turn) + " - " + get_turn_name(current_turn))
	
	# Update systems
	_update_color_state()
	
	# Notify word manager of turn change if available
	if word_manager and word_manager.has_method("set_turn"):
		word_manager.set_turn(current_turn)
	
	# Notify line processor of turn change if available
	if line_processor and line_processor.has_method("set_turn"):
		line_processor.set_turn(current_turn)
	
	# Create special effects based on the new turn
	apply_turn_effects(current_turn)
	
	# Emit signal
	emit_signal("turn_advanced", current_turn, get_turn_name(current_turn))

func archive_current_turn():
	# Save current turn state to the archive
	turn_archive[current_turn] = {
		"timestamp": OS.get_unix_time(),
		"word_collection": word_collection.duplicate(),
		"game_elements": get_current_game_elements(),
		"connected_apis": connected_apis.duplicate()
	}
	
	print("Turn " + str(current_turn) + " archived")

func register_turn_archive():
	# Load existing archive if available
	var file = File.new()
	var archive_path = "res://Eden_May/turn_archive.json"
	
	if file.file_exists(archive_path):
		var err = file.open(archive_path, File.READ)
		if err == OK:
			var text = file.get_as_text()
			file.close()
			
			var json = JSON.parse(text)
			if json.error == OK:
				turn_archive = json.result
				print("Loaded " + str(turn_archive.size()) + " archived turns")
	else:
		print("No turn archive found, starting fresh")

func save_turn_archive():
	# Save archive to file
	var file = File.new()
	var archive_path = "res://Eden_May/turn_archive.json"
	
	var err = file.open(archive_path, File.WRITE)
	if err == OK:
		file.store_string(JSON.print(turn_archive, "  "))
		file.close()
		print("Turn archive saved")
		return true
	
	print("Error saving turn archive: " + str(err))
	return false

func get_current_game_elements():
	# Collect game elements from current turn
	var elements = {
		"words": word_collection.keys(),
		"patterns": line_processor.get_pattern_stats() if line_processor else {},
		"turn": current_turn,
		"turn_name": get_turn_name(current_turn)
	}
	
	return elements

func apply_turn_effects(turn_number):
	print("Applying Turn " + str(turn_number) + " effects")
	
	# Apply different effects based on turn number
	match turn_number:
		9: # Game Creation
			begin_game_creation()
		10: # Integration
			integrate_game_systems()
		11: # Embodiment
			embody_game_creation()
		12: # Transcendence
			transcend_game_creation()
		13: # Reversion
			revert_to_foundation()
		_:
			print("No special effects for Turn " + str(turn_number))

func begin_game_creation():
	print("Beginning Game Creation phase")
	
	# Initialize game templates
	game_templates = [
		{
			"name": "Word Game",
			"description": "A game focused on forming words and unlocking their power",
			"elements": ["words", "spelling", "discovery"],
			"complexity": 3,
			"turn_requirement": 8
		},
		{
			"name": "Pattern Game",
			"description": "A game about recognizing and creating patterns",
			"elements": ["patterns", "matching", "sequence"],
			"complexity": 4,
			"turn_requirement": 7
		},
		{
			"name": "Line Connection Game",
			"description": "Connect lines to form shapes and unlock powers",
			"elements": ["lines", "connections", "shapes"],
			"complexity": 5,
			"turn_requirement": 8
		},
		{
			"name": "Energy Flow Game",
			"description": "Direct energy flows to create and transform",
			"elements": ["energy", "flow", "transformation"],
			"complexity": 6,
			"turn_requirement": 8
		},
		{
			"name": "Quantum Realm Game",
			"description": "Navigate quantum probabilities to shape reality",
			"elements": ["quantum", "probability", "reality"],
			"complexity": 8,
			"turn_requirement": 9
		}
	]
	
	# Start game creation process
	if game_creator:
		game_creator.start_creation(word_collection, line_processor.get_pattern_stats() if line_processor else {})

func integrate_game_systems():
	print("Integrating game systems")
	if active_game:
		active_game.integrate_systems()

func embody_game_creation():
	print("Embodying game creation")
	if active_game:
		active_game.embody_creation()

func transcend_game_creation():
	print("Transcending game creation")
	if active_game:
		active_game.transcend()

func revert_to_foundation():
	print("Reverting to foundation")
	# Reset systems but keep accumulated knowledge
	if active_game:
		active_game.archive()
		active_game = null
	
	word_collection = {}
	turn_progress = 0.0

func _on_api_response_received(api_name, response, request_id):
	# Handle API responses
	if request_id.begins_with("ocr_"):
		# Response to OCR analysis request
		print("Received OCR analysis from " + api_name)
		
		# Process analysis response
		if api_name == "claude" or api_name == "claude_luna":
			# Claude provides more detailed creative analysis
			parse_claude_analysis(response)
		else:
			# Gemini provides more data-focused analysis
			parse_gemini_analysis(response)
	
	elif request_id.begins_with("game_"):
		# Response to game creation request
		print("Received game creation response from " + api_name)
		if game_creator:
			game_creator.process_api_response(api_name, response, request_id)

func parse_claude_analysis(response):
	# Extract patterns and concepts from Claude's analysis
	print("Parsing Claude analysis")
	
	# In a real implementation, you would parse the structured output
	# For now, we'll simulate pattern extraction
	
	# Update turn progress based on valuable analysis
	update_turn_progress(3.0)

func parse_gemini_analysis(response):
	# Extract data points and elements from Gemini's analysis
	print("Parsing Gemini analysis")
	
	# In a real implementation, you would parse the structured output
	# For now, we'll simulate data extraction
	
	# Update turn progress based on valuable analysis
	update_turn_progress(2.5)

func _on_api_connection_changed(api_name, connected):
	# Update connection status
	if api_name == "gemini_advanced":
		connected_apis["gemini"] = connected
	elif api_name == "claude_luna":
		connected_apis["luminous"] = connected
	elif api_name == "claude":
		connected_apis["claude"] = connected
	
	# Emit signal
	emit_signal("api_connection_changed", api_name, connected)
	
	# Update color state based on connections
	_update_color_state()

func _update_color_state():
	# Determine color based on turn and connections
	var base_color
	
	if between_turns:
		# Transition between colors
		var from_color = get_turn_color(current_turn)
		var to_color = get_turn_color(current_turn + 1)
		
		base_color = from_color.linear_interpolate(to_color, turn_transition_phase)
	else:
		base_color = get_turn_color(current_turn)
	
	# Adjust based on API connections
	var connection_count = 0
	for api in connected_apis:
		if connected_apis[api]:
			connection_count += 1
	
	# Enhance color based on connections
	var enhanced_color = base_color
	if connection_count > 0:
		# Add luminosity based on connections
		var luminosity_boost = connection_count * 0.1
		enhanced_color.r = min(enhanced_color.r + luminosity_boost, 1.0)
		enhanced_color.g = min(enhanced_color.g + luminosity_boost, 1.0)
		enhanced_color.b = min(enhanced_color.b + luminosity_boost, 1.0)
	
	# Set color in API coordinator if available
	if api_coordinator and api_coordinator.has_method("set_custom_color"):
		api_coordinator.set_custom_color(enhanced_color)

func _on_game_created(game_data):
	print("Game created: " + game_data.name)
	active_game = game_data
	emit_signal("game_created", game_data)

# OCR Processor class
class OCRProcessor extends Node:
	signal ocr_completed(text, source_file)
	
	var initialized = false
	
	func initialize():
		initialized = true
		print("OCR Processor initialized")
	
	func process_image(image_path):
		if not initialized:
			print("OCR Processor not initialized")
			return false
		
		print("Processing image: " + image_path)
		
		# In a real implementation, this would call the OCR library
		# For now, we'll simulate OCR processing
		
		# Short delay to simulate processing
		yield(get_tree().create_timer(1.0), "timeout")
		
		# Generate sample text based on the image name
		var image_name = image_path.get_file().get_basename()
		var simulated_text = "OCR Result from " + image_name + ":\n"
		simulated_text += "This is simulated OCR text that would be extracted from the image.\n"
		simulated_text += "It contains various words that might be detected in Turn " + str(OS.get_unix_time() % 12 + 1) + ".\n"
		simulated_text += "Special words: dipata, zenime, perfefic might be detected."
		
		# Emit completion signal
		emit_signal("ocr_completed", simulated_text, image_path)
		return true

# Game Creator class
class GameCreator extends Node:
	signal game_created(game_data)
	
	var word_collection = {}
	var pattern_stats = {}
	var creation_phase = 0
	var templates = []
	
	func start_creation(words, patterns):
		word_collection = words
		pattern_stats = patterns
		creation_phase = 1
		
		print("Game creation started")
		advance_creation_phase()
	
	func advance_creation_phase():
		creation_phase += 1
		print("Game creation phase: " + str(creation_phase))
		
		match creation_phase:
			2: # Select template
				select_game_template()
			3: # Generate core mechanics
				generate_core_mechanics()
			4: # Create game assets
				create_game_assets()
			5: # Finalize game
				finalize_game()
	
	func select_game_template():
		# In a real implementation, you would analyze word_collection and pattern_stats
		# to select the best template
		
		# For now, simulate template selection
		var template = {
			"name": "Word Manifestation",
			"description": "Create and manifest words into reality",
			"core_mechanic": "word_power",
			"elements": word_collection.keys()
		}
		
		templates.append(template)
		print("Template selected: " + template.name)
		
		# Advance to next phase
		yield(get_tree().create_timer(1.0), "timeout")
		advance_creation_phase()
	
	func generate_core_mechanics():
		# Generate game mechanics based on template and collections
		print("Generating core mechanics")
		
		# Simulate API request for mechanics
		# In a real implementation, you would send this to the API
		
		# Advance to next phase
		yield(get_tree().create_timer(1.0), "timeout")
		advance_creation_phase()
	
	func create_game_assets():
		# Create game assets based on words and patterns
		print("Creating game assets")
		
		# Simulate asset creation
		# In a real implementation, you would generate actual assets
		
		# Advance to next phase
		yield(get_tree().create_timer(1.0), "timeout")
		advance_creation_phase()
	
	func finalize_game():
		# Finalize game creation
		print("Finalizing game")
		
		# Create game data
		var game_data = {
			"name": templates[0].name,
			"description": templates[0].description,
			"mechanics": ["Word Formation", "Pattern Recognition", "Energy Manipulation"],
			"assets": word_collection.keys().slice(0, min(10, word_collection.keys().size() - 1)),
			"timestamp": OS.get_unix_time(),
			
			# Add methods
			"integrate_systems": funcref(self, "dummy_method"),
			"embody_creation": funcref(self, "dummy_method"),
			"transcend": funcref(self, "dummy_method"),
			"archive": funcref(self, "dummy_method")
		}
		
		# Emit creation signal
		emit_signal("game_created", game_data)
	
	func process_api_response(api_name, response, request_id):
		print("Processing API response for game creation")
		# In a real implementation, you would parse the API response
		# and use it to influence game creation
	
	func dummy_method():
		# Placeholder for game object methods
		pass