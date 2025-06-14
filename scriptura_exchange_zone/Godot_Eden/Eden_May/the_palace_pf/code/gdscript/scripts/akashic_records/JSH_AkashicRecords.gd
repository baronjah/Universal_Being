extends Node
class_name JSH_AkashicRecords

# Main entry point for the Akashic Records system
# Add this script to your main scene to integrate everything

# Configuration
var config = {
	"auto_initialize": true,
	"debug_mode": true,
	"create_demo_content": true,
	"register_console_commands": true,
	"connect_to_element_system": true,
	"connect_to_menu_system": true
}

# System references
var akashic_integration = null
var universal_bridge = null
var akashic_records_manager = null
var thing_creator = null
var ui_manager = null
var debug_panel = null

# Initialization state
var is_initialized = false
var initialization_steps_completed = 0
var total_initialization_steps = 5

# Debug info
var startup_time = 0
var initialization_time = 0
var system_status = {}

# Signals
signal initialization_complete
signal initialization_step_completed(step, message)
signal debug_info_updated(info)

func _ready():
	if config.auto_initialize:
		startup_time = Time.get_ticks_msec()
		call_deferred("initialize")

# Initialize the entire Akashic Records system
func initialize() -> bool:
	if is_initialized:
		return true
	
	print("JSH_AkashicRecords: Beginning initialization...")
	
	# Step 1: Create Akashic Integration
	emit_signal("initialization_step_completed", 1, "Creating Akashic Integration")
	_create_akashic_integration()
	initialization_steps_completed += 1
	
	# Step 2: Initialize systems
	emit_signal("initialization_step_completed", 2, "Initializing core systems")
	_initialize_core_systems()
	initialization_steps_completed += 1
	
	# Step 3: Connect systems
	emit_signal("initialization_step_completed", 3, "Connecting systems")
	_connect_systems()
	initialization_steps_completed += 1
	
	# Step 4: Setup UI and commands
	emit_signal("initialization_step_completed", 4, "Setting up UI and commands")
	_setup_ui_and_commands()
	initialization_steps_completed += 1
	
	# Step 5: Create demo content
	if config.create_demo_content:
		emit_signal("initialization_step_completed", 5, "Creating demo content")
		_create_demo_content()
	
	initialization_steps_completed += 1
	
	is_initialized = true
	initialization_time = Time.get_ticks_msec() - startup_time
	print("JSH_AkashicRecords: Initialization complete in ", initialization_time, "ms")
	
	# Create debug panel if in debug mode
	if config.debug_mode:
		_create_debug_panel()
	
	emit_signal("initialization_complete")
	return true

# Step 1: Create Akashic Integration
func _create_akashic_integration() -> void:
	akashic_integration = AkashicIntegration.new()
	akashic_integration.name = "AkashicIntegration"
	add_child(akashic_integration)
	
	# Connect signals
	akashic_integration.connect("integration_initialized", Callable(self, "_on_integration_initialized"))
	akashic_integration.connect("debug_info_updated", Callable(self, "_on_debug_info_updated"))
	
	print("JSH_AkashicRecords: Akashic Integration created")

# Step 2: Initialize core systems
func _initialize_core_systems() -> void:
	# Initialize the Akashic Records Manager
	akashic_records_manager = AkashicRecordsManagerA.get_instance()
	if not akashic_records_manager.is_initialized:
		akashic_records_manager.initialize()
	
	# Initialize the Thing Creator
	thing_creator = ThingCreatorA.get_instance()
	
	# Initialize the Universal Bridge
	universal_bridge = UniversalBridge.get_instance()
	universal_bridge.initialize()
	
	print("JSH_AkashicRecords: Core systems initialized")

# Step 3: Connect systems
func _connect_systems() -> void:
	# Connect to Element System if configured
	if config.connect_to_element_system:
		_connect_to_element_system()
	
	# Connect to Menu System if configured
	if config.connect_to_menu_system:
		_connect_to_menu_system()
	
	print("JSH_AkashicRecords: Systems connected")

# Step 4: Setup UI and commands
func _setup_ui_and_commands() -> void:
	# Create UI manager
	ui_manager = AkashicRecordsUI.new()
	ui_manager.name = "AkashicRecordsUI"
	add_child(ui_manager)
	
	# Setup UI
	ui_manager.setup(akashic_records_manager, thing_creator, universal_bridge)
	
	# Register console commands if configured
	if config.register_console_commands:
		_register_console_commands()
	
	print("JSH_AkashicRecords: UI and commands set up")

# Step 5: Create demo content
func _create_demo_content() -> void:
	# Create base elements if they don't exist
	universal_bridge.ensure_element_definitions()
	
	# Create visualization concepts
	var concepts = [
		"energy_flow",
		"resonance_pattern",
		"transformation_field",
		"essence_manifestation",
		"complexity_wave"
	]
	
	for concept in concepts:
		universal_bridge.create_visualization_entry(concept)
	
	print("JSH_AkashicRecords: Demo content created")

# Create debug panel for monitoring
func _create_debug_panel() -> void:
	debug_panel = Control.new()
	debug_panel.name = "AkashicDebugPanel"
	
	var panel = Panel.new()
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	debug_panel.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.margin_left = 10
	vbox.margin_top = 10
	vbox.margin_right = -10
	vbox.margin_bottom = -10
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "Akashic Records Debug"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(title)
	
	var stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.text = "Loading system stats..."
	stats_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(stats_label)
	
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_button.connect("pressed", Callable(debug_panel, "queue_free"))
	vbox.add_child(close_button)
	
	# Resize panel
	debug_panel.position = Vector2(20, 20)
	debug_panel.size = Vector2(300, 400)
	debug_panel.visible = false
	
	add_child(debug_panel)
	
	# Update stats
	_update_debug_stats()
	
	print("JSH_AkashicRecords: Debug panel created")

# Update debug stats
func _update_debug_stats() -> void:
	if not debug_panel or not debug_panel.has_node("Panel/VBoxContainer/StatsLabel"):
		return
	
	var stats_label = debug_panel.get_node("Panel/VBoxContainer/StatsLabel")
	
	# Get system stats
	var akashic_stats = akashic_records_manager.get_dictionary_stats()
	var zone_stats = akashic_records_manager.get_zone_stats()
	
	var stats_text = """
Initialization Time: %sms

Dictionary:
- Words: %s
- Root Words: %s
- Files: %s

Zones:
- Total Zones: %s
- Loaded Zones: %s
- Total Entities: %s

Things:
- Active Things: %s

Integration:
- Akashic Records: %s
- Element System: %s
- Thing Creator: %s
- Bridge: %s
- Console: %s
- Menu: %s
	""" % [
		initialization_time,
		akashic_stats.get("total_words", 0),
		akashic_stats.get("root_words", 0),
		akashic_stats.get("files", 0),
		zone_stats.get("total_zones", 0),
		zone_stats.get("loaded_zones", 0),
		zone_stats.get("total_entities", 0),
		thing_creator.get_all_things().size(),
		system_status.get("akashic_records", false),
		system_status.get("element_manager", false),
		system_status.get("thing_creator", false),
		system_status.get("bridge", false),
		system_status.get("console", false),
		system_status.get("menu", false)
	]
	
	stats_label.text = stats_text

# Connect to Element System
func _connect_to_element_system() -> void:
	# Find Element Manager
	var element_manager = null
	
	if has_node("/root/ElementManager"):
		element_manager = get_node("/root/ElementManager")
	else:
		var nodes = get_tree().get_nodes_in_group("element_manager")
		if nodes.size() > 0:
			element_manager = nodes[0]
		else:
			# Try to find it in the scene tree
			element_manager = _find_node_by_class("ElementManager")
	
	if element_manager:
		# Update Universal Bridge with element manager reference
		universal_bridge.element_manager = element_manager
		
		# Connect signals
		if not element_manager.is_connected("element_created", Callable(universal_bridge, "_on_element_created")):
			element_manager.connect("element_created", Callable(universal_bridge, "_on_element_created"))
		
		if not element_manager.is_connected("element_transformed", Callable(universal_bridge, "_on_element_transformed")):
			element_manager.connect("element_transformed", Callable(universal_bridge, "_on_element_transformed"))
		
		print("JSH_AkashicRecords: Connected to Element System")
		system_status["element_manager"] = true
	else:
		print("JSH_AkashicRecords: Element Manager not found, connection skipped")
		system_status["element_manager"] = false

# Connect to Menu System
func _connect_to_menu_system() -> void:
	# Find main menu system
	var menu_system = null
	
	if has_node("/root/main"):
		menu_system = get_node("/root/main")
		
		# Find JSH console if available
		if menu_system.has_node("JSH_console"):
			var console = menu_system.get_node("JSH_console")
			universal_bridge.console_system = console
			system_status["console"] = true
		elif menu_system.has_node("CanvasLayer/JSH_console"):
			var console = menu_system.get_node("CanvasLayer/JSH_console")
			universal_bridge.console_system = console
			system_status["console"] = true
		else:
			system_status["console"] = false
		
		# Update Universal Bridge with menu system reference
		universal_bridge.menu_system = menu_system
		
		print("JSH_AkashicRecords: Connected to Menu System")
		system_status["menu"] = true
	else:
		print("JSH_AkashicRecords: Menu System not found, connection skipped")
		system_status["menu"] = false
		system_status["console"] = false

# Register console commands
func _register_console_commands() -> void:
	var console = universal_bridge.console_system
	
	if console and console.has_method("register_command"):
		var commands = [
			{
				"name": "akashic",
				"description": "Open Akashic Records main menu",
				"callback": "_cmd_open_akashic_menu"
			},
			{
				"name": "create_element",
				"description": "Create an element at specified position. Usage: create_element <type> <x> <y> <z>",
				"callback": "_cmd_create_element"
			},
			{
				"name": "akashic_debug",
				"description": "Toggle Akashic Records debug panel",
				"callback": "_cmd_toggle_debug"
			}
		]
		
		for command in commands:
			console.register_command(command.name, command.description, command.callback)
		
		print("JSH_AkashicRecords: Console commands registered")
		system_status["console"] = true
	else:
		print("JSH_AkashicRecords: Console not found or doesn't support registering commands")
		system_status["console"] = false

# Console command implementations
func _cmd_open_akashic_menu(_args, _console) -> String:
	if ui_manager:
		ui_manager.open_main_menu()
		return "Opened Akashic Records menu"
	return "UI manager not available"

func _cmd_create_element(args, _console) -> String:
	if args.size() < 4:
		return "Usage: create_element <type> <x> <y> <z>"
	
	var type = args[0]
	var x = float(args[1])
	var y = float(args[2])
	var z = float(args[3])
	
	var thing_id = universal_bridge.create_thing_from_word(type, Vector3(x, y, z))
	
	if thing_id.is_empty():
		return "Failed to create element of type: " + type
	
	return "Created element: " + thing_id + " at position (" + str(x) + ", " + str(y) + ", " + str(z) + ")"

func _cmd_toggle_debug(_args, _console) -> String:
	if debug_panel:
		debug_panel.visible = !debug_panel.visible
		
		if debug_panel.visible:
			_update_debug_stats()
			return "Debug panel shown"
		else:
			return "Debug panel hidden"
			
	return "Debug panel not available"

# Utility function to find node by class name
func _find_node_by_class(class_name_param: String) -> Node:
	var root = get_tree().root
	return _find_node_by_class_recursive(root, class_name_param)

func _find_node_by_class_recursive(node: Node, class_name_param: String) -> Node:
	if node.get_class() == class_name_param:
		return node
	
	for child in node.get_children():
		var found = _find_node_by_class_recursive(child, class_name_param)
		if found:
			return found
	
	return null

# Signal handlers
func _on_integration_initialized() -> void:
	print("JSH_AkashicRecords: Integration initialized")
	
	# Update system status
	system_status = akashic_integration.integration_status

func _on_debug_info_updated(info) -> void:
	system_status = info
	
	if debug_panel and debug_panel.visible:
		_update_debug_stats()
	
	emit_signal("debug_info_updated", info)

# Public API for other scripts to use

# Get main Akashic Records Manager instance
func get_akashic_records_manager():
	return akashic_records_manager

# Get Universal Bridge instance
func get_universal_bridge():
	return universal_bridge

# Get Thing Creator instance
func get_thing_creator():
	return thing_creator

# Get UI Manager instance
func get_ui_manager():
	return ui_manager

# Create a new element at the specified position
func create_element(type: String, position: Vector3) -> String:
	return universal_bridge.create_thing_from_word(type, position)

# Process interaction between two things
func process_interaction(thing1_id: String, thing2_id: String) -> Dictionary:
	return universal_bridge.process_thing_interaction(thing1_id, thing2_id)

# Transform a thing to a new type
func transform_thing(thing_id: String, new_type: String) -> bool:
	return universal_bridge.transform_thing(thing_id, new_type)

# Manifest a word as elements
func manifest_word(word_id: String, position: Vector3, size: float = 10.0) -> Array:
	return universal_bridge.manifest_word_as_elements(word_id, position, size)

# Create a visualization concept
func create_visualization(concept_name: String, properties: Dictionary = {}) -> bool:
	return universal_bridge.create_visualization_entry(concept_name, properties)