extends Node

# Integration Manager
# Connects Scriptura Turn System, API Coordinator, Wish Maker, and Eden_May systems

class_name IntegrationManager

# References to main systems
var eden_core = null
var scriptura_turn_system = null
var api_coordinator = null
var wish_maker = null

# Core Eden_May components
var game_project = null
var word_manager = null
var line_processor = null

# OCR connector
var simple_ocr = null

# Integration status
var systems_status = {
	"eden_core": false,
	"scriptura_turn": false,
	"api_coordinator": false,
	"wish_maker": false,
	"simple_ocr": false
}

# Configuration
var config = {
	"auto_connect": true,
	"sync_turn_state": true,
	"enable_ocr_pipeline": true,
	"enable_color_sync": true,
	"command_integration": true
}

# OCR pipeline settings
var ocr_queue = []
var processing_ocr = false

# Signals
signal system_connected(system_name)
signal system_disconnected(system_name)
signal integration_completed()
signal ocr_processed(text, source)

func _init():
	print("Integration Manager initializing")

func _ready():
	print("Integration Manager ready")
	find_systems()
	
	if config.auto_connect:
		connect_all_systems()

func find_systems():
	# Find Eden Core
	eden_core = get_node_or_null("/root/EdenMayGame/EdenCore")
	if eden_core:
		systems_status.eden_core = true
		print("Found Eden Core")
		
		# Get Eden_May components through Eden Core
		game_project = eden_core.get_node_or_null("../GameProject")
		word_manager = eden_core.get_node_or_null("../WordManager")
		line_processor = eden_core.get_node_or_null("../LineProcessor")
	
	# Find Scriptura Turn System
	scriptura_turn_system = get_node_or_null("/root/EdenMayGame/ScripturaTurnSystem")
	if not scriptura_turn_system:
		scriptura_turn_system = get_node_or_null("/root/ScripturaTurnSystem")
	
	if scriptura_turn_system:
		systems_status.scriptura_turn = true
		print("Found Scriptura Turn System")
	
	# Find API Coordinator
	api_coordinator = get_node_or_null("/root/EdenMayGame/APICoordinator")
	if not api_coordinator:
		api_coordinator = get_node_or_null("/root/APICoordinatorSystem/APICoordinator")
	
	if api_coordinator:
		systems_status.api_coordinator = true
		print("Found API Coordinator")
	
	# Find Wish Maker
	wish_maker = get_node_or_null("/root/EdenMayGame/WishMaker")
	if not wish_maker:
		wish_maker = get_node_or_null("/root/WishMakerSystem/WishMaker")
	
	if wish_maker:
		systems_status.wish_maker = true
		print("Found Wish Maker")
	
	# Find Simple OCR
	simple_ocr = get_node_or_null("/root/SimpleOCR")
	if simple_ocr:
		systems_status.simple_ocr = true
		print("Found Simple OCR")

func connect_all_systems():
	print("Connecting all systems")
	
	# Create missing systems
	create_missing_systems()
	
	# Connect systems
	connect_scriptura_to_eden()
	connect_api_to_scriptura()
	connect_ocr_to_scriptura()
	connect_wish_maker_to_scriptura()
	
	# Set up command integration
	if config.command_integration:
		integrate_commands()
	
	# Set up OCR pipeline
	if config.enable_ocr_pipeline:
		setup_ocr_pipeline()
	
	# Set up color synchronization
	if config.enable_color_sync:
		setup_color_sync()
	
	# Sync turn state if needed
	if config.sync_turn_state:
		sync_turn_state()
	
	print("All systems connected")
	emit_signal("integration_completed")

func create_missing_systems():
	# Create Scriptura Turn System if needed
	if not scriptura_turn_system:
		print("Creating Scriptura Turn System")
		var ScripturaTurnSystem = load("res://Eden_May/scriptura_turn_system.gd")
		if ScripturaTurnSystem:
			scriptura_turn_system = ScripturaTurnSystem.new()
			scriptura_turn_system.name = "ScripturaTurnSystem"
			add_child(scriptura_turn_system)
			systems_status.scriptura_turn = true
	
	# Create API Coordinator if needed
	if not api_coordinator:
		print("Creating API Coordinator")
		var APICoordinator = load("res://Eden_May/api_coordinator.gd")
		if APICoordinator:
			api_coordinator = APICoordinator.new()
			api_coordinator.name = "APICoordinator"
			add_child(api_coordinator)
			systems_status.api_coordinator = true
	
	# Create Wish Maker if needed
	if not wish_maker:
		print("Creating Wish Maker")
		var WishMaker = load("res://Eden_May/wish_maker.gd")
		if WishMaker:
			wish_maker = WishMaker.new()
			wish_maker.name = "WishMaker"
			add_child(wish_maker)
			systems_status.wish_maker = true

func connect_scriptura_to_eden():
	if not scriptura_turn_system or not eden_core:
		print("Cannot connect Scriptura to Eden: missing components")
		return
	
	print("Connecting Scriptura to Eden Core")
	
	# Connect signals
	scriptura_turn_system.connect("turn_advanced", self, "_on_turn_advanced")
	scriptura_turn_system.connect("turn_progress_updated", self, "_on_turn_progress_updated")
	
	# Set references
	scriptura_turn_system.word_manager = word_manager
	scriptura_turn_system.line_processor = line_processor
	
	return true

func connect_api_to_scriptura():
	if not scriptura_turn_system or not api_coordinator:
		print("Cannot connect API to Scriptura: missing components")
		return
	
	print("Connecting API Coordinator to Scriptura")
	
	# Set references
	scriptura_turn_system.api_coordinator = api_coordinator
	
	# Connect signals
	api_coordinator.connect("api_response_received", scriptura_turn_system, "_on_api_response_received")
	api_coordinator.connect("connection_status_changed", scriptura_turn_system, "_on_api_connection_changed")
	
	return true

func connect_ocr_to_scriptura():
	if not scriptura_turn_system:
		print("Cannot connect OCR to Scriptura: missing components")
		return
	
	print("Connecting OCR to Scriptura")
	
	# Enable OCR in Scriptura
	scriptura_turn_system.enable_ocr()
	
	# Connect with simple_ocr if available
	if simple_ocr:
		scriptura_turn_system.connect("ocr_result_ready", self, "_on_ocr_result_ready")
	
	return true

func connect_wish_maker_to_scriptura():
	if not scriptura_turn_system or not wish_maker:
		print("Cannot connect Wish Maker to Scriptura: missing components")
		return
	
	print("Connecting Wish Maker to Scriptura")
	
	# Enhance wish maker with OCR capabilities
	if not wish_maker.has_method("process_ocr_text"):
		wish_maker.process_ocr_text = funcref(self, "_wish_maker_process_ocr")
	
	# Connect signals
	scriptura_turn_system.connect("ocr_result_ready", wish_maker, "process_ocr_text")
	
	return true

func integrate_commands():
	if not eden_core:
		print("Cannot integrate commands: Eden Core missing")
		return
	
	print("Integrating commands")
	
	# Add scriptura commands
	if eden_core.has_method("check_special_commands"):
		var original_check_commands = eden_core.check_special_commands
		
		# Replace with enhanced version that includes scriptura commands
		eden_core.check_special_commands = funcref(self, "_enhanced_check_commands")
	
	# Add OCR command if not already present
	if eden_core.has_method("process_command") and not "_process_ocr_command" in eden_core:
		eden_core._process_ocr_command = funcref(self, "_process_ocr_command")
	
	return true

func setup_ocr_pipeline():
	print("Setting up OCR pipeline")
	
	# Connect OCR signals
	if scriptura_turn_system:
		scriptura_turn_system.connect("ocr_result_ready", self, "_on_ocr_result_ready")
	
	if simple_ocr:
		simple_ocr.connect("ocr_completed", self, "_on_simple_ocr_completed")
	
	return true

func setup_color_sync():
	if not scriptura_turn_system or not api_coordinator:
		print("Cannot set up color sync: missing components")
		return
	
	print("Setting up color synchronization")
	
	# Add color sync method to API Coordinator if not present
	if not api_coordinator.has_method("set_custom_color"):
		api_coordinator.set_custom_color = funcref(self, "_api_set_custom_color")
	
	# Update initial color
	var turn_color = scriptura_turn_system.get_turn_color(scriptura_turn_system.current_turn)
	api_coordinator.set_custom_color(turn_color)
	
	return true

func sync_turn_state():
	if not scriptura_turn_system or not eden_core:
		print("Cannot sync turn state: missing components")
		return
	
	print("Synchronizing turn state")
	
	# Set scriptura turn based on eden_core
	if eden_core.has_method("get_system_status"):
		var status = eden_core.get_system_status()
		if status.has("turn") and status.turn.has("current"):
			scriptura_turn_system.current_turn = status.turn.current
			scriptura_turn_system.turn_progress = status.turn.progress * 100.0
			
			print("Synchronized turn: " + str(scriptura_turn_system.current_turn))
	
	return true

func process_ocr_file(file_path):
	if not scriptura_turn_system:
		print("Cannot process OCR: Scriptura Turn System missing")
		return false
	
	print("Processing OCR file: " + file_path)
	
	return scriptura_turn_system.process_image(file_path)

func queue_ocr_file(file_path):
	print("Queueing OCR file: " + file_path)
	
	ocr_queue.append(file_path)
	
	if not processing_ocr:
		process_next_ocr()
	
	return true

func process_next_ocr():
	if ocr_queue.size() == 0:
		processing_ocr = false
		return
	
	processing_ocr = true
	var file_path = ocr_queue.pop_front()
	
	print("Processing next OCR file in queue: " + file_path)
	var result = process_ocr_file(file_path)
	
	if not result:
		# If processing failed, move to next file
		call_deferred("process_next_ocr")

func _on_ocr_result_ready(text, source_file):
	print("OCR result ready from Scriptura: " + source_file)
	
	# Forward the signal
	emit_signal("ocr_processed", text, source_file)
	
	# Process next file in queue if any
	call_deferred("process_next_ocr")

func _on_simple_ocr_completed(text, source_file):
	print("OCR completed from SimpleOCR: " + source_file)
	
	# Forward to Scriptura if available
	if scriptura_turn_system:
		scriptura_turn_system.process_ocr_text(text, source_file)

func _on_turn_advanced(turn_number, turn_name):
	print("Turn advanced: " + str(turn_number) + " - " + turn_name)
	
	# Synchronize with Eden Core if available
	if eden_core and eden_core.has_method("advance_turn"):
		eden_core.advance_turn()

func _on_turn_progress_updated(progress):
	# Update Eden Core progress if available
	if eden_core and eden_core.has_method("update_turn_progress"):
		eden_core.update_turn_progress(progress)

# Enhanced command checking that includes scriptura commands
func _enhanced_check_commands(text):
	# Original command checking
	var eden_result = eden_core.check_special_commands(text)
	if eden_result:
		return eden_result
	
	# Check for scriptura commands
	text = text.strip_edges().to_lower()
	
	if text == "scriptura" or text == "turn system":
		return _show_scriptura_ui()
	
	if text.begins_with("ocr "):
		var file_path = text.substr(4).strip_edges()
		return _process_ocr_command(file_path)
	
	if text == "connect apis":
		return _connect_apis_command()
	
	if text == "turn info" or text == "turn status":
		return _show_turn_info()
	
	# No special scriptura command detected
	return null

func _show_scriptura_ui():
	# Show Scriptura UI
	if scriptura_turn_system:
		var scene = load("res://Eden_May/scriptura_turn_system.tscn")
		if scene:
			var instance = scene.instance()
			get_tree().root.add_child(instance)
			return "Opened Scriptura Turn System UI"
	
	return "Scriptura Turn System UI not available"

func _process_ocr_command(file_path):
	# Process OCR command
	if scriptura_turn_system:
		var result = scriptura_turn_system.process_image(file_path)
		if result:
			return "Processing OCR for file: " + file_path
		else:
			return "Failed to process OCR for file: " + file_path
	
	return "OCR processing not available"

func _connect_apis_command():
	# Connect APIs command
	if scriptura_turn_system:
		var result = scriptura_turn_system.connect_to_apis()
		if result:
			return "Connecting to APIs: Gemini, Luminous, Claude"
		else:
			return "Failed to connect to APIs"
	
	return "API connection not available"

func _show_turn_info():
	# Show turn info command
	if scriptura_turn_system:
		var turn_number = scriptura_turn_system.current_turn
		var turn_name = scriptura_turn_system.get_turn_name(turn_number)
		var progress = scriptura_turn_system.turn_progress
		
		return "Current Turn: " + str(turn_number) + " - " + turn_name + "\nProgress: " + str(progress) + "%"
	
	return "Turn information not available"

# API color setting function
func _api_set_custom_color(color):
	# This is added to the API Coordinator
	if self.has_method("transition_color_state"):
		# Find state closest to this color
		var closest_state = "void"
		var closest_distance = 999999
		
		for state_name in self.color_progression:
			var state_color = self.color_progression[state_name]
			var distance = _color_distance(state_color, color)
			
			if distance < closest_distance:
				closest_distance = distance
				closest_state = state_name
		
		# Transition to that state
		self.transition_color_state(closest_state)
	else:
		# Direct color setting if transition not available
		var custom_state = "custom"
		self.color_progression[custom_state] = color
		self.current_color_state = custom_state
		self.emit_signal("color_state_changed", custom_state, color)

func _color_distance(color1, color2):
	return abs(color1.r - color2.r) + abs(color1.g - color2.g) + abs(color1.b - color2.b)

# Wish Maker OCR processing function
func _wish_maker_process_ocr(text, source_file):
	# This is added to the Wish Maker
	print("Processing OCR text in Wish Maker")
	
	# Extract words from OCR text
	var words = text.split(" ")
	var spell_words = []
	
	# Check for spell words
	for word in words:
		word = word.strip_edges().to_lower()
		
		if self.spell_dictionary.has(word):
			spell_words.append(word)
			self.process_spell_word(word)
	
	# Create a wish based on OCR text
	if spell_words.size() > 0:
		var wish_text = "OCR detected spell words: " + PoolStringArray(spell_words).join(", ")
		var token_amount = 200  # Higher token amount for OCR-derived wishes
		
		self.make_wish(wish_text, token_amount)
		return "Created wish from OCR detected spell words"
	
	return "No spell words found in OCR text"