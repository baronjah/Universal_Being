extends Node

class_name EdenHarmonyConnector

# ----- CONSTANTS -----
const VERSION = "1.0.0"
const CONFIG_FILE = "user://eden_harmony_config.json"

# ----- COMPONENT REFERENCES -----
var turn_system = null
var word_manifestor = null
var ethereal_integration = null
var entity_manager = null
var dimensional_color_system = null
var ui_controller = null

# ----- COMPONENT PATHS -----
var component_paths = {
	"turn_system": "/root/TurnSystem",
	"turn_controller": "/root/TurnController",
	"word_manifestor": "/root/CoreWordManifestor",
	"ethereal_integration": "/root/JshEtherealIntegration",
	"entity_manager": "/root/CoreEntityManager",
	"dimensional_color_system": "/root/DimensionalColorSystem",
	"ui_controller": "/root/EtherealEngineUI"
}

# ----- SIGNAL INTEGRATION -----
var connected_signals = {}

# ----- CONFIGURATION -----
var config = {
	"auto_start": true,
	"default_turn_duration": 9.0,
	"default_dimension": 3,
	"word_manifestation_power": 1.0,
	"enable_automatic_synchronization": true,
	"synchronization_interval": 3.0,
	"debug_mode": true
}

# ----- SIGNALS -----
signal initialization_complete
signal component_connected(component_name)
signal components_synchronized
signal word_manifested(word, entity, dimension)
signal dimension_changed(new_dimension)
signal turn_advanced(turn_number)

# ----- INITIALIZATION -----
func _ready():
	print("Eden Harmony Connector initializing...")
	
	# Load configuration
	load_configuration()
	
	# Initialize components
	connect_components()
	
	# Set up synchronization timer if enabled
	if config.enable_automatic_synchronization:
		var sync_timer = Timer.new()
		sync_timer.wait_time = config.synchronization_interval
		sync_timer.one_shot = false
		sync_timer.autostart = true
		sync_timer.connect("timeout", Callable(self, "synchronize_all_components"))
		add_child(sync_timer)
	
	# Start the system if auto-start is enabled
	if config.auto_start:
		start_system()
	
	print("Eden Harmony Connector initialized (v" + VERSION + ")")
	emit_signal("initialization_complete")

func connect_components():
	# Find and connect to all major components
	_connect_turn_system()
	_connect_word_manifestor()
	_connect_ethereal_integration()
	_connect_entity_manager()
	_connect_dimensional_color_system()
	_connect_ui_controller()
	
	# Connect signals between components
	_connect_component_signals()

func _connect_turn_system():
	# Try to find TurnSystem
	turn_system = get_node_or_null(component_paths.turn_system)
	
	# If not found, try TurnController
	if not turn_system:
		turn_system = get_node_or_null(component_paths.turn_controller)
	
	# If still not found, try to find in the scene tree
	if not turn_system:
		var nodes = get_tree().get_nodes_in_group("turn_system")
		if nodes.size() > 0:
			turn_system = nodes[0]
	
	if turn_system:
		print("Connected to turn system: " + turn_system.get_class())
		emit_signal("component_connected", "turn_system")
	else:
		print("No turn system found, dimensional transitions will be limited")

func _connect_word_manifestor():
	# Try to get the CoreWordManifestor singleton
	if ClassDB.class_exists("CoreWordManifestor"):
		word_manifestor = CoreWordManifestor.get_instance()
		print("Connected to CoreWordManifestor")
		emit_signal("component_connected", "word_manifestor")
	else:
		print("CoreWordManifestor not found, word manifestation will be unavailable")

func _connect_ethereal_integration():
	# Try to find JshEtherealIntegration
	ethereal_integration = get_node_or_null(component_paths.ethereal_integration)
	
	# If not found, try to find in the scene tree
	if not ethereal_integration:
		var nodes = get_tree().get_nodes_in_group("ethereal_integration")
		if nodes.size() > 0:
			ethereal_integration = nodes[0]
	
	if ethereal_integration:
		print("Connected to ethereal integration: " + ethereal_integration.get_class())
		emit_signal("component_connected", "ethereal_integration")
	else:
		print("No ethereal integration found, some features may be limited")

func _connect_entity_manager():
	# Try to get the entity manager singleton
	if ClassDB.class_exists("CoreEntityManager"):
		entity_manager = CoreEntityManager.get_instance()
		print("Connected to CoreEntityManager")
		emit_signal("component_connected", "entity_manager")
	elif ClassDB.class_exists("JSHEntityManager"):
		entity_manager = JSHEntityManager.get_instance()
		print("Connected to JSHEntityManager")
		emit_signal("component_connected", "entity_manager")
	elif ClassDB.class_exists("ThingCreatorA"):
		entity_manager = ThingCreatorA.get_instance()
		print("Connected to ThingCreatorA")
		emit_signal("component_connected", "entity_manager")
	else:
		print("No entity manager found, entity creation will be limited")

func _connect_dimensional_color_system():
	# Try to find DimensionalColorSystem
	dimensional_color_system = get_node_or_null(component_paths.dimensional_color_system)
	
	# If not found, try to find in the scene tree
	if not dimensional_color_system:
		var nodes = get_tree().get_nodes_in_group("color_system")
		if nodes.size() > 0:
			dimensional_color_system = nodes[0]
	
	if dimensional_color_system:
		print("Connected to dimensional color system: " + dimensional_color_system.get_class())
		emit_signal("component_connected", "dimensional_color_system")
	else:
		print("No dimensional color system found, visual theming will be limited")

func _connect_ui_controller():
	# Try to find UI controller
	ui_controller = get_node_or_null(component_paths.ui_controller)
	
	# If not found, try to find in the scene tree
	if not ui_controller:
		var nodes = get_tree().get_nodes_in_group("ui_controller")
		if nodes.size() > 0:
			ui_controller = nodes[0]
	
	if ui_controller:
		print("Connected to UI controller: " + ui_controller.get_class())
		emit_signal("component_connected", "ui_controller")
	else:
		print("No UI controller found, UI interactions will be limited")

func _connect_component_signals():
	# Connect signals between components for integration
	
	# Turn system signals
	if turn_system:
		if turn_system.has_signal("turn_started"):
			if not connected_signals.has("turn_started"):
				turn_system.connect("turn_started", Callable(self, "_on_turn_started"))
				connected_signals["turn_started"] = true
		
		if turn_system.has_signal("dimension_changed"):
			if not connected_signals.has("dimension_changed"):
				turn_system.connect("dimension_changed", Callable(self, "_on_dimension_changed"))
				connected_signals["dimension_changed"] = true
	
	# Word manifestor signals
	if word_manifestor:
		if word_manifestor.has_signal("word_manifested"):
			if not connected_signals.has("word_manifested"):
				word_manifestor.connect("word_manifested", Callable(self, "_on_word_manifested"))
				connected_signals["word_manifested"] = true
		
		if word_manifestor.has_signal("word_combination_created"):
			if not connected_signals.has("word_combination_created"):
				word_manifestor.connect("word_combination_created", Callable(self, "_on_word_combination_created"))
				connected_signals["word_combination_created"] = true

	print("Component signals connected")

# ----- SYSTEM CONTROL -----
func start_system():
	print("Starting Eden Harmony System...")
	
	# Start turn system if available
	if turn_system:
		if turn_system.has_method("start_turns"):
			turn_system.start_turns()
		elif turn_system.has_method("start_turn"):
			turn_system.start_turn(1)
	
	# Set default dimension
	set_dimension(config.default_dimension)
	
	# Initialize UI
	update_ui()
	
	print("Eden Harmony System started")

func stop_system():
	print("Stopping Eden Harmony System...")
	
	# Stop turn system if available
	if turn_system:
		if turn_system.has_method("stop_turns"):
			turn_system.stop_turns()
	
	print("Eden Harmony System stopped")

# ----- SYNCHRONIZATION -----
func synchronize_all_components():
	print("Synchronizing all components...")
	
	# Get current dimension from turn system
	var current_dimension = get_current_dimension()
	
	# Synchronize dimensional color system
	if dimensional_color_system:
		if dimensional_color_system.has_method("set_dimension"):
			dimensional_color_system.set_dimension(current_dimension)
		elif dimensional_color_system.has_method("update_turn"):
			dimensional_color_system.update_turn(get_current_turn(), 12)
	
	# Synchronize UI
	update_ui()
	
	emit_signal("components_synchronized")
	print("Components synchronized")

# ----- WORD MANIFESTATION -----
func manifest_word(word: String, position = null) -> Object:
	if word_manifestor:
		var entity = word_manifestor.manifest_word(word, position)
		
		# Adjust entity properties based on current dimension
		if entity:
			var current_dimension = get_current_dimension()
			_apply_dimensional_properties(entity, current_dimension)
			
			# Notify ethereal integration if available
			if ethereal_integration and ethereal_integration.has_method("_on_entity_created"):
				ethereal_integration._on_entity_created(entity.get_instance_id(), word, str(position))
		
		return entity
	
	return null

func combine_words(words: Array, position = null) -> Object:
	if word_manifestor:
		var entity = word_manifestor.combine_words(words, position)
		
		# Adjust entity properties based on current dimension
		if entity:
			var current_dimension = get_current_dimension()
			_apply_dimensional_properties(entity, current_dimension)
		
		return entity
	
	return null

func process_command(command: String) -> Dictionary:
	if word_manifestor:
		var result = word_manifestor.process_command(command)
		
		# Apply dimension properties to any created entity
		if result.success and result.entity:
			var current_dimension = get_current_dimension()
			_apply_dimensional_properties(result.entity, current_dimension)
		
		return result
	
	return {"success": false, "message": "Word manifestor not available", "entity": null}

func _apply_dimensional_properties(entity, dimension: int):
	# Apply properties based on current dimension to the entity
	if entity.has_method("set_property"):
		entity.set_property("dimension", dimension)
		
		# Apply dimension-specific properties
		match dimension:
			1: # Linear
				entity.set_property("dimensionality", "linear")
				entity.set_property("manifestation_clarity", 0.3)
			2: # Planar
				entity.set_property("dimensionality", "planar")
				entity.set_property("manifestation_clarity", 0.5)
			3: # Spatial
				entity.set_property("dimensionality", "spatial")
				entity.set_property("manifestation_clarity", 0.7)
			4: # Temporal
				entity.set_property("dimensionality", "temporal")
				entity.set_property("manifestation_clarity", 0.8)
				entity.set_property("temporal_flux", 0.4)
			5: # Probability
				entity.set_property("dimensionality", "probabilistic")
				entity.set_property("manifestation_clarity", 0.6)
				entity.set_property("quantum_state", 0.5)
			_: # Higher dimensions
				entity.set_property("dimensionality", "transcendent")
				entity.set_property("manifestation_clarity", 0.9)
				entity.set_property("ethereal_resonance", 0.7)

# ----- DIMENSION CONTROL -----
func set_dimension(dimension: int) -> bool:
	if turn_system:
		if turn_system.has_method("set_dimension"):
			var success = turn_system.set_dimension(dimension)
			
			# Update color system if turn system doesn't handle it
			if success and dimensional_color_system:
				if dimensional_color_system.has_method("set_dimension"):
					dimensional_color_system.set_dimension(dimension)
				elif dimensional_color_system.has_method("update_dimension"):
					dimensional_color_system.update_dimension(dimension)
			
			return success
	elif dimensional_color_system:
		# If no turn system, try to set dimension directly in color system
		if dimensional_color_system.has_method("set_dimension"):
			dimensional_color_system.set_dimension(dimension)
			emit_signal("dimension_changed", dimension)
			return true
	
	return false

func get_current_dimension() -> int:
	if turn_system:
		if turn_system.has_property("current_dimension"):
			return turn_system.current_dimension
		elif turn_system.has_method("get_current_dimension"):
			return turn_system.get_current_dimension()
	
	if dimensional_color_system:
		if dimensional_color_system.has_property("current_dimension"):
			return dimensional_color_system.current_dimension
		elif dimensional_color_system.has_method("get_current_dimension"):
			return dimensional_color_system.get_current_dimension()
	
	return config.default_dimension

func get_dimension_name(dimension: int = -1) -> String:
	if dimension < 0:
		dimension = get_current_dimension()
	
	if turn_system and turn_system.has_method("get_dimension_name"):
		return turn_system.get_dimension_name()
	
	# Default dimension names
	var dimension_names = [
		"Linear Expression",      # 1D
		"Planar Reflection",      # 2D
		"Spatial Manifestation",  # 3D
		"Temporal Flow",          # 4D
		"Probability Waves",      # 5D
		"Phase Resonance",        # 6D
		"Dream Weaving",          # 7D
		"Interconnection",        # 8D
		"Divine Judgment",        # 9D
		"Harmonic Convergence",   # 10D
		"Conscious Reflection",   # 11D
		"Divine Manifestation"    # 12D
	]
	
	if dimension >= 1 and dimension <= dimension_names.size():
		return dimension_names[dimension - 1]
	
	return "Unknown Dimension"

# ----- TURN CONTROL -----
func advance_turn():
	if turn_system:
		if turn_system.has_method("advance_turn"):
			turn_system.advance_turn()
			return true
	
	return false

func get_current_turn():
	if turn_system:
		if turn_system.has_property("current_turn"):
			return turn_system.current_turn
		elif turn_system.has_method("get_current_turn"):
			return turn_system.get_current_turn()
	
	return 1

# ----- UI MANAGEMENT -----
func update_ui():
	if ui_controller:
		if ui_controller.has_method("update_display"):
			var ui_data = {
				"dimension": get_current_dimension(),
				"dimension_name": get_dimension_name(),
				"turn": get_current_turn(),
				"word_count": get_manifested_word_count()
			}
			ui_controller.update_display(ui_data)
	
	# Update console if available
	if get_node_or_null("/root/creation_console"):
		var console = get_node("/root/creation_console")
		if console.has_method("add_message"):
			console.add_message("Turn: " + str(get_current_turn()) + " | Dimension: " + str(get_current_dimension()) + "D - " + get_dimension_name())

func get_manifested_word_count() -> int:
	if word_manifestor:
		if word_manifestor.has_property("recent_manifestations"):
			return word_manifestor.recent_manifestations.size()
	
	return 0

# ----- SIGNAL HANDLERS -----
func _on_turn_started(turn_number):
	emit_signal("turn_advanced", turn_number)
	
	# Update UI
	update_ui()
	
	if config.debug_mode:
		print("Turn advanced to: " + str(turn_number))

func _on_dimension_changed(new_dimension, _old_dimension = 0):
	emit_signal("dimension_changed", new_dimension)
	
	# Update color system if not already updated
	if dimensional_color_system:
		if dimensional_color_system.has_method("set_dimension"):
			dimensional_color_system.set_dimension(new_dimension)
		elif dimensional_color_system.has_method("update_dimension"):
			dimensional_color_system.update_dimension(new_dimension)
	
	# Update UI
	update_ui()
	
	if config.debug_mode:
		print("Dimension changed to: " + str(new_dimension) + "D - " + get_dimension_name(new_dimension))

func _on_word_manifested(word, entity):
	var current_dimension = get_current_dimension()
	emit_signal("word_manifested", word, entity, current_dimension)
	
	if config.debug_mode:
		print("Word manifested: " + word + " in dimension " + str(current_dimension) + "D")

func _on_word_combination_created(words, result):
	if config.debug_mode:
		print("Word combination created: " + str(words) + " → " + result)

# ----- CONFIGURATION MANAGEMENT -----
func load_configuration():
	if FileAccess.file_exists(CONFIG_FILE):
		var file = FileAccess.open(CONFIG_FILE, FileAccess.READ)
		if file:
			var text = file.get_as_text()
			var parsed = JSON.parse_string(text)
			
			if parsed != null:
				for key in parsed:
					if config.has(key):
						config[key] = parsed[key]
			else:
				print("Error parsing configuration JSON")
	else:
		print("Configuration file not found, using defaults")
		save_configuration()

func save_configuration():
	var file = FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(config))
	else:
		print("Error saving configuration: ", FileAccess.get_open_error())

# ----- INPUT HANDLING -----
func _input(event):
	# Handle dimension changing with number keys
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var dimension = event.keycode - KEY_0
			set_dimension(dimension)
		elif event.keycode == KEY_0:
			set_dimension(10)
		elif event.keycode == KEY_MINUS:
			set_dimension(11)
		elif event.keycode == KEY_EQUAL:
			set_dimension(12)
		
		# Tab key to show/hide console
		elif event.keycode == KEY_TAB:
			toggle_console()
	
func toggle_console():
	# Find and toggle console visibility if available
	var console = get_node_or_null("/root/creation_console")
	if console and console.has_method("toggle_visibility"):
		console.toggle_visibility()