extends Node
class_name EdenProjectInitializer

# References to key systems
var universal_bridge = null
var akashic_records_manager = null
var element_manager = null
var console_system = null
var thing_creator = null

# Initialization status
var systems_initialized = []
var is_initialization_complete = false

# Signals
signal initialization_progress(system_name, progress)
signal initialization_completed

# Configuration
var config = {
	"debug_mode": true,
	"create_basic_elements": true,
	"auto_save_interval": 300, # seconds
	"max_elements": 1000,
	"default_world_size": Vector3(100, 100, 100),
	"camera_start_position": Vector3(0, 10, 20)
}

func _ready():
	# Start initialization sequence
	if config.debug_mode:
		print("Eden Project initialization starting with minimal setup...")

	# Wait one frame to ensure the scene is properly set up
	await get_tree().process_frame

	# For our first test, we'll only initialize the Universal Bridge
	# to avoid any potential issues with other systems
	initialize_universal_bridge()

	# Mark initialization as complete
	is_initialization_complete = true
	emit_signal("initialization_completed")

	if config.debug_mode:
		print("Minimal Eden Project initialization complete!")

func initialize_systems():
	# Step 1: Initialize Universal Bridge
	initialize_universal_bridge()
	
	# Step 2: Initialize Console System (if available)
	initialize_console_system()
	
	# Step 3: Initialize Akashic Records
	initialize_akashic_records()
	
	# Step 4: Initialize Element System
	initialize_element_system()
	
	# Step 5: Initialize Thing Creator
	initialize_thing_creator()
	
	# Step 6: Connect all systems
	connect_systems()
	
	# Step 7: Setup auto-save
	setup_auto_save()
	
	# Step 8: Create basic elements if configured
	if config.create_basic_elements:
		create_basic_elements()
	
	# Mark initialization as complete
	is_initialization_complete = true
	emit_signal("initialization_completed")
	
	if config.debug_mode:
		print("Eden Project initialization complete!")

func initialize_universal_bridge():
	if config.debug_mode:
		print("Initializing Universal Bridge...")

	# Get or create the bridge
	universal_bridge = UniversalBridgeSystem.get_instance()

	# Add to scene tree if not already added
	if not universal_bridge.is_inside_tree():
		add_child(universal_bridge)

	# Initialize
	universal_bridge.initialize()

	systems_initialized.append("universal_bridge")
	emit_signal("initialization_progress", "Universal Bridge", 20)

func initialize_console_system():
	if config.debug_mode:
		print("Initializing Console System...")
	
	# Try to find existing console system
	console_system = get_node_or_null("/root/JSH_Console_System")
	
	if not console_system:
		# Create a new console if needed
		var console_script = load("res://code/gdscript/scripts/Menu_Keyboard_Console/JSH_console.gd")
		if console_script:
			console_system = console_script.new()
			console_system.name = "JSH_Console_System"
			get_tree().root.add_child(console_system)
	
	systems_initialized.append("console_system")
	emit_signal("initialization_progress", "Console System", 40)

func initialize_akashic_records():
	if config.debug_mode:
		print("Initializing Akashic Records...")
	
	# Get from Universal Bridge
	akashic_records_manager = universal_bridge.akashic_records_manager
	
	if not akashic_records_manager:
		push_error("Failed to get Akashic Records Manager from Universal Bridge")
		return
	
	systems_initialized.append("akashic_records")
	emit_signal("initialization_progress", "Akashic Records", 60)

func initialize_element_system():
	if config.debug_mode:
		print("Initializing Element System...")
	
	# Try to find existing element manager
	element_manager = get_node_or_null("ElementManager")
	
	if not element_manager:
		# Create new element manager
		var element_manager_script = load("res://code/gdscript/scripts/elements_shapes_projection/element_manager.gd")
		if element_manager_script:
			element_manager = element_manager_script.new()
			element_manager.name = "ElementManager"
			add_child(element_manager)
	
	# Configure element manager
	element_manager.MAX_ELEMENTS = config.max_elements
	
	# Tell Universal Bridge about the element manager
	universal_bridge.element_manager = element_manager
	
	systems_initialized.append("element_system")
	emit_signal("initialization_progress", "Element System", 80)

func initialize_thing_creator():
	if config.debug_mode:
		print("Initializing Thing Creator...")
	
	# Get from Universal Bridge
	thing_creator = universal_bridge.thing_creator
	
	if not thing_creator:
		push_error("Failed to get Thing Creator from Universal Bridge")
		return
	
	systems_initialized.append("thing_creator")
	emit_signal("initialization_progress", "Thing Creator", 90)

func connect_systems():
	if config.debug_mode:
		print("Connecting all systems...")
	
	# Make sure all systems are initialized
	if not "universal_bridge" in systems_initialized or \
	   not "akashic_records" in systems_initialized or \
	   not "element_system" in systems_initialized or \
	   not "thing_creator" in systems_initialized:
		push_error("Cannot connect systems: Not all systems are initialized")
		return
	
	# Connect through Universal Bridge
	universal_bridge._connect_signals()
	
	systems_initialized.append("systems_connected")
	emit_signal("initialization_progress", "System Connections", 95)

func setup_auto_save():
	if config.auto_save_interval <= 0:
		return
	
	var timer = Timer.new()
	timer.wait_time = config.auto_save_interval
	timer.one_shot = false
	timer.timeout.connect(auto_save)
	add_child(timer)
	timer.start()

func auto_save():
	if config.debug_mode:
		print("Auto-saving system state...")
	
	if akashic_records_manager:
		akashic_records_manager.save_all()

func create_basic_elements():
	if config.debug_mode:
		print("Creating basic elements...")
	
	# Ensure Universal Bridge has created basic definitions
	universal_bridge.ensure_element_definitions()
	
	# Create a test world if element manager is available
	if element_manager:
		var test_settings = {
			"world_size": config.default_world_size,
			"initial_elements": {
				"fire": 5,
				"water": 5,
				"wood": 5,
				"ash": 5
			},
			"physics_intensity": 1.0
		}
		
		element_manager.generate_world(test_settings)
	
	emit_signal("initialization_progress", "Basic Elements", 100)

func _process(delta):
	# Check for key presses to toggle console
	if Input.is_action_just_pressed("toggle_console") and console_system:
		# This would depend on your console implementation
		pass

# Public API for accessing the systems
func get_universal_bridge():
	return universal_bridge

func get_akashic_records_manager():
	return akashic_records_manager

func get_element_manager():
	return element_manager

func get_console_system():
	return console_system

func get_thing_creator():
	return thing_creator