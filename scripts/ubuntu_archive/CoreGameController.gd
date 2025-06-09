class_name CoreGameController
extends Node

# Component references
var word_manifestor = null
var entity_manager = null
var creation_console = null
var player = null
var map_system = null

# Scenes to preload
var console_scene = preload("res://creation_console.tscn")
var entity_scene = preload("res://universal_entity.tscn")  # Adjust path as needed

# Signals
signal initialization_complete()
signal system_error(system_name, error_message)

func _ready():
	# Initialize all systems
	print("CoreGameController: Initializing system components...")
	
	# Set up components in the correct order
	var success = true
	success = success and _initialize_entity_system()
	success = success and _initialize_word_system()
	success = success and _initialize_map_system()
	success = success and _initialize_ui_system()
	
	# Find player (if exists)
	player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		player = player[0]
		print("CoreGameController: Found player node")
	else:
		player = null
		print("CoreGameController: No player node found, some positioning features will be disabled")
	
	# Connect systems together
	_connect_systems()
	
	# Register input handling
	_setup_input_handling()
	
	if success:
		print("CoreGameController: Initialization complete")
		emit_signal("initialization_complete")
	else:
		print("CoreGameController: Initialization completed with errors")

func _initialize_entity_system() -> bool:
	print("CoreGameController: Initializing entity system...")
	
	# Try to get entity manager instance
	if ClassDB.class_exists("CoreEntityManager"):
		entity_manager = CoreEntityManager.get_instance()
	elif ClassDB.class_exists("JSHEntityManager"):
		entity_manager = JSHEntityManager.get_instance()
	elif ClassDB.class_exists("ThingCreatorA"):
		entity_manager = ThingCreatorA.get_instance()
	
	if entity_manager:
		print("CoreGameController: Entity manager initialized")
		return true
	else:
		print("CoreGameController: Failed to initialize entity manager")
		emit_signal("system_error", "EntitySystem", "Failed to initialize entity manager")
		return false

func _initialize_word_system() -> bool:
	print("CoreGameController: Initializing word manifestation system...")
	
	# Try to get word manifestor instance
	if ClassDB.class_exists("CoreWordManifestor"):
		word_manifestor = CoreWordManifestor.get_instance()
	elif ClassDB.class_exists("JSHWordManifestor"):
		word_manifestor = JSHWordManifestor.get_instance()
	
	if word_manifestor:
		print("CoreGameController: Word manifestor initialized")
		return true
	else:
		print("CoreGameController: Failed to initialize word manifestor")
		emit_signal("system_error", "WordSystem", "Failed to initialize word manifestor")
		return false

func _initialize_map_system() -> bool:
	print("CoreGameController: Initializing map system...")
	
	# Try to find map system in the scene
	var map_nodes = get_tree().get_nodes_in_group("map_system")
	if map_nodes.size() > 0:
		map_system = map_nodes[0]
		print("CoreGameController: Found map system node")
		return true
	
	# If no map system found in scene, check for class
	if ClassDB.class_exists("DynamicMapSystem"):
		# Try to create a map system
		map_system = Node.new()
		map_system.set_script(load("res://DynamicMapSystem.gd"))
		add_child(map_system)
		print("CoreGameController: Created map system instance")
		return true
	
	# Create a dummy map system for minimal functionality
	map_system = Node.new()
	map_system.name = "DummyMapSystem"
	map_system.add_to_group("map_system")
	
	# Add minimal required methods
	map_system.set_script(GDScript.new())
	map_system.get_script().source_code = """
	extends Node
	
	func add_entity_to_world(entity, position = Vector3.ZERO):
		add_child(entity)
		if entity is Node3D:
			entity.global_position = position
		return true
		
	func get_entities():
		return get_children()
	"""
	map_system.get_script().reload()
	
	add_child(map_system)
	print("CoreGameController: Created dummy map system")
	
	# Not a fatal error, just reduced functionality
	return true

func _initialize_ui_system() -> bool:
	print("CoreGameController: Initializing UI system...")
	
	# Create creation console UI
	creation_console = console_scene.instantiate()
	add_child(creation_console)
	
	print("CoreGameController: Creation console initialized")
	return true

func _connect_systems() -> void:
	print("CoreGameController: Connecting systems...")
	
	# Connect word manifestor to map system and player
	if word_manifestor and word_manifestor.has_method("initialize"):
		word_manifestor.initialize(map_system, player)
		print("CoreGameController: Connected word manifestor to map system and player")
	
	# Connect console to word manifestor
	if creation_console and creation_console.has_signal("command_entered"):
		# Connect creation console to word manifestor
		print("CoreGameController: Connected creation console to word manifestor")
	
	print("CoreGameController: System connections complete")

func _setup_input_handling() -> void:
	# Check for existing input map action for console toggle
	if not InputMap.has_action("toggle_console"):
		# Create action for console toggle
		InputMap.add_action("toggle_console")
		
		# Add Tab key to the action
		var event = InputEventKey.new()
		event.keycode = KEY_TAB
		InputMap.action_add_event("toggle_console", event)
		
		print("CoreGameController: Added input mapping for toggle_console")

# Public API to toggle console visibility
func toggle_console() -> void:
	if creation_console:
		creation_console.toggle_visibility()

# Public API to manifest a word
func manifest_word(word: String, position = null) -> Object:
	if word_manifestor:
		return word_manifestor.manifest_word(word, position)
	return null

# Public API to process a console command
func process_command(command: String) -> Dictionary:
	if word_manifestor:
		return word_manifestor.process_command(command)
	return {"success": false, "message": "Word manifestor not available", "entity": null}

func _input(event):
	# Check for toggle console input
	if event.is_action_pressed("toggle_console"):
		toggle_console()
