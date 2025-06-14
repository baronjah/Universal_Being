# JSH_Akashic_Records.gd
# res://code/gdscript/scripts/akashic_records/JSH_Akashic_Records.gd
extends Node
class_name JSH_AkashicRecordsSystem

# Import the helper class
const ConsoleIntegrationHelper = preload("res://code/gdscript/scripts/akashic_records/console_integration_helper.gd")

# Main connector for the Akashic Records system
# This script integrates with existing JSH systems while providing new functionality

# === System References ===
var akashic_records_manager = null  # The new Akashic Records Manager
var universal_bridge = null         # Bridge to connect systems
var thing_creator = null            # Thing Creator reference
var debug_ui = null                 # Debug UI for testing
var database_integrator = null      # Database integration with JSH systems

# === Existing JSH System References ===
var jsh_records_system = null       # Your existing records system
var jsh_data_splitter = null        # Your existing data splitter
var jsh_database_system = null      # Your existing database system
var jsh_console = null              # Your console system
var jsh_task_manager = null         # Your task manager

# === System Status ===
var is_initialized = false
var debug_mode = true
var initialization_step = 0

# === Configuration ===
var config = {
	"auto_initialize": true,
	"connect_to_existing_systems": true,
	"register_console_commands": true,
	"create_demo_entries": true,
	"create_debug_ui": true
}

# === Signals ===
signal initialization_complete
signal entity_created(entity_id, type)
signal entity_transformed(entity_id, old_type, new_type)
signal records_updated(record_id)

func _ready():
	if config["auto_initialize"]:
		call_deferred("initialize")

func _input(event):
	# Toggle debug UI with F3 key
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		if debug_ui:
			debug_ui.toggle_visibility()

# Main initialization function
func initialize() -> bool:
	if is_initialized:
		return true

	print("JSH_AkashicRecords: Starting initialization...")

	# Step 1: Find existing JSH systems
	_find_existing_systems()
	initialization_step += 1

	# Step 2: Initialize new systems
	_initialize_new_systems()
	initialization_step += 1

	# Step 3: Connect systems
	_connect_systems()
	initialization_step += 1

	# Step 4: Register commands
	if config["register_console_commands"]:
		_register_console_commands()
	initialization_step += 1

	# Step 5: Create demo entries if configured
	if config["create_demo_entries"]:
		_create_demo_entries()
	initialization_step += 1

	# Step 6: Create debug UI if configured
	if config["create_debug_ui"]:
		_create_debug_ui()
	initialization_step += 1

	is_initialized = true
	print("JSH_AkashicRecords: Initialization complete!")
	emit_signal("initialization_complete")

	return true

# Step 1: Find existing JSH systems
func _find_existing_systems() -> void:
	print("JSH_AkashicRecords: Finding existing systems...")
	
	# Find records system
	if has_node("/root/main/JSH_records_system"):
		jsh_records_system = get_node("/root/main/JSH_records_system")
		print("Found JSH_records_system")
	
	# Find data splitter
	if has_node("/root/main/JSH_data_splitter"):
		jsh_data_splitter = get_node("/root/main/JSH_data_splitter") 
		print("Found JSH_data_splitter")
	
	# Find database system
	if has_node("/root/main/JSH_database_system"):
		jsh_database_system = get_node("/root/main/JSH_database_system")
		print("Found JSH_database_system")
	elif has_node("/root/main/JSH_Core/JSH_database_system"):
		jsh_database_system = get_node("/root/main/JSH_Core/JSH_database_system")
		print("Found JSH_database_system in JSH_Core")
	
	# Find console
	if has_node("/root/main/JSH_console"):
		jsh_console = get_node("/root/main/JSH_console")
		print("Found JSH_console")
	
	# Find task manager
	if has_node("/root/main/JSH_task_manager"):
		jsh_task_manager = get_node("/root/main/JSH_task_manager")
		print("Found JSH_task_manager")

# Step 2: Initialize new systems
func _initialize_new_systems() -> void:
	print("JSH_AkashicRecords: Initializing new systems...")
	
	# Initialize Akashic Records Manager
	akashic_records_manager = AkashicRecordsManagerA.get_instance()
	if not akashic_records_manager.is_initialized:
		akashic_records_manager.initialize()
	print("Akashic Records Manager initialized")
	
	# Initialize Universal Bridge
	universal_bridge = UniversalBridgeSystem.get_instance()
	universal_bridge.initialize()
	print("Universal Bridge initialized")
	
	# Initialize Thing Creator if needed
	var thing_creator_node = find_node_by_name("ThingCreator")
	if thing_creator_node:
		thing_creator = thing_creator_node
		print("Found existing ThingCreator")
	else:
		thing_creator = ThingCreatorA.get_instance()
		thing_creator.name = "ThingCreator"
		add_child(thing_creator)
		print("Created new ThingCreator")

# Step 3: Connect systems
func _connect_systems() -> void:
	print("JSH_AkashicRecords: Connecting systems...")
	
	if config["connect_to_existing_systems"]:
		# Connect to records system
		if jsh_records_system:
			# Subscribe to record updates
			if jsh_records_system.has_signal("record_updated"):
				if not jsh_records_system.is_connected("record_updated", Callable(self, "_on_jsh_record_updated")):
					jsh_records_system.connect("record_updated", Callable(self, "_on_jsh_record_updated"))
			print("Connected to JSH_records_system")
		
		# Connect to data splitter
		if jsh_data_splitter:
			# Subscribe to parsing events
			if jsh_data_splitter.has_signal("parsing_completed"):
				if not jsh_data_splitter.is_connected("parsing_completed", Callable(self, "_on_jsh_parsing_completed")):
					jsh_data_splitter.connect("parsing_completed", Callable(self, "_on_jsh_parsing_completed"))
			print("Connected to JSH_data_splitter")
		
		# Connect to database system
		if jsh_database_system:
			# No specific connections needed yet
			print("Connected to JSH_database_system")
	
	# Connect new systems to each other
	universal_bridge.akashic_records_manager = akashic_records_manager
	universal_bridge.thing_creator = thing_creator
	
	# Connect signals
	if not akashic_records_manager.is_connected("word_created", Callable(self, "_on_word_created")):
		akashic_records_manager.connect("word_created", Callable(self, "_on_word_created"))
	
	if not akashic_records_manager.is_connected("entity_created", Callable(self, "_on_entity_created")):
		akashic_records_manager.connect("entity_created", Callable(self, "_on_entity_created"))
	
	if not thing_creator.is_connected("thing_created", Callable(self, "_on_thing_created")):
		thing_creator.connect("thing_created", Callable(self, "_on_thing_created"))
	
	print("Systems connected")

# Step 4: Register console commands
func _register_console_commands() -> void:
	print("JSH_AkashicRecords: Registering console commands...")
	
	if jsh_console:
		# Register basic Akashic Records commands
		var commands = [
			{
				"name": "akashic_create",
				"description": "Create a new entity in the Akashic Records. Usage: akashic_create <type> <x> <y> <z>",
				"callback": "_cmd_akashic_create"
			},
			{
				"name": "akashic_list",
				"description": "List entities in the Akashic Records. Usage: akashic_list [type]",
				"callback": "_cmd_akashic_list"
			},
			{
				"name": "akashic_info",
				"description": "Get info about an entity. Usage: akashic_info <entity_id>",
				"callback": "_cmd_akashic_info"
			},
			{
				"name": "transform_entity",
				"description": "Transform an entity to a new type. Usage: transform_entity <entity_id> <new_type>",
				"callback": "_cmd_transform_entity"
			}
		]
		
		# Use the ConsoleIntegrationHelper to register commands
		for cmd in commands:
			# Use the helper to handle different command registration interfaces
			ConsoleIntegrationHelper.register_command(
				jsh_console,
				cmd["name"],
				cmd["description"],
				self,
				cmd["callback"]
			)
		
		print("Console commands registered")

# Step 5: Create demo entries
func _create_demo_entries() -> void:
	print("JSH_AkashicRecords: Creating demo entries...")
	
	# Create primordial entity type if it doesn't exist
	var primordial = akashic_records_manager.get_word("primordial")
	if primordial.size() == 0:
		var primordial_data = {
			"id": "primordial",
			"display_name": "Primordial Essence",
			"category": "base",
			"description": "The fundamental essence from which all things evolve",
			"properties": {
				"essence": 1.0,
				"stability": 1.0,
				"resonance": 0.5,
				"complexity": 0.0
			}
		}
		
		akashic_records_manager.create_word("primordial", "base", primordial_data.get("properties", {}))
		print("Created primordial word definition")
	
	# Create basic element types
	var elements = ["fire", "water", "wood", "ash"]
	var properties = {
		"fire": {
			"essence": 0.9,
			"stability": 0.3,
			"heat": 0.9,
			"energy": 0.8
		},
		"water": {
			"essence": 0.8,
			"stability": 0.7,
			"flow": 0.9,
			"clarity": 0.7
		},
		"wood": {
			"essence": 0.7,
			"stability": 0.8,
			"growth": 0.8,
			"structure": 0.7
		},
		"ash": {
			"essence": 0.6,
			"stability": 0.9,
			"fertilizer": 0.7,
			"dissolution": 0.6
		}
	}
	
	for element in elements:
		var element_def = akashic_records_manager.get_word(element)
		if element_def.size() == 0:
			var element_data = {
				"id": element,
				"display_name": element.capitalize(),
				"category": "element",
				"parent": "primordial",
				"description": "A basic " + element + " element",
				"properties": properties[element]
			}

			akashic_records_manager.create_word(element, "element", element_data.get("properties", {}))
			print("Created " + element + " word definition")
	
	# Create a test zone
	akashic_records_manager.zone_manager.create_zone("test_zone", AABB(Vector3(-100, -100, -100), Vector3(200, 200, 200)))
	print("Created test zone")

# Create debug UI
func _create_debug_ui() -> void:
	print("JSH_AkashicRecords: Creating debug UI...")

	# Create the debug UI
	var DebugUIScene = load("res://code/gdscript/scripts/akashic_records/debug_ui.tscn")
	if DebugUIScene:
		debug_ui = DebugUIScene.instantiate()
	else:
		# Try to load the debug UI script
		var DebugUIScript = load("res://code/gdscript/scripts/akashic_records/debug_ui.gd")
		if DebugUIScript:
			debug_ui = DebugUIScript.new()
		else:
			# Create a minimal debug UI if not found
			debug_ui = Control.new()
			debug_ui.name = "MinimalDebugUI"
			
			# Add a dummy initialize method
			debug_ui.set_script(GDScript.new())
			debug_ui.get_script().source_code = """
extends Control

func initialize(records_manager, creator, bridge):
	print("Minimal Debug UI initialized")
	
func toggle_visibility():
	visible = !visible
	
func log_interaction(entity1_id, entity2_id, result):
	print("Interaction logged: ", entity1_id, " + ", entity2_id, " = ", result)
"""
			debug_ui.get_script().reload()

# Check if debug_ui was created successfully
	if debug_ui:
		debug_ui.name = "AkashicDebugUI"
		add_child(debug_ui)

		# Initialize the UI with system references
		if debug_ui.has_method("initialize"):
			debug_ui.initialize(akashic_records_manager, thing_creator, universal_bridge)
		
		# Register interaction signal handlers
		if universal_bridge and universal_bridge.has_signal("interaction_processed"):
			universal_bridge.connect("interaction_processed", Callable(self, "_on_interaction_processed"))
	else:
		push_error("Failed to create debug UI - missing debug_ui.tscn or AkashicDebugUI class")

	# Add debug commands to console
	if jsh_console:
		var debug_command = {
			"name": "akashic_debug",
			"description": "Toggle Akashic Records debug UI",
			"callback": "_cmd_toggle_debug_ui"
		}

		# Use the ConsoleIntegrationHelper to register the debug command
		ConsoleIntegrationHelper.register_command(
			jsh_console,
			debug_command["name"],
			debug_command["description"],
			self,
			debug_command["callback"]
		)

	print("Debug UI created")

# Toggle debug UI visibility
func _cmd_toggle_debug_ui(_args) -> String:
	if debug_ui:
		debug_ui.toggle_visibility()
		return "Toggled Akashic Records debug UI"
	return "Debug UI not available"

# Log interaction events to debug UI
func _on_interaction_processed(entity1_id, entity2_id, result) -> void:
	if debug_ui:
		debug_ui.log_interaction(entity1_id, entity2_id, result)

# === Console Command Implementations ===

func _cmd_akashic_create(args) -> String:
	if args.size() < 4:
		return "Usage: akashic_create <type> <x> <y> <z>"

	var type = args[0]
	var x = float(args[1])
	var y = float(args[2])
	var z = float(args[3])

	var thing_id = universal_bridge.create_thing_from_word(type, Vector3(x, y, z))

	if thing_id.is_empty():
		return "Failed to create entity of type: " + type

	return "Created entity: " + thing_id + " at position (" + str(x) + ", " + str(y) + ", " + str(z) + ")"

func _cmd_akashic_list(args) -> String:
	var category = args[0] if args.size() > 0 else ""
	
	var words = []
	var stats = akashic_records_manager.get_dictionary_stats()
	
	if stats.has("words"):
		for word_id in stats.words:
			var word = akashic_records_manager.get_word(word_id)
			if word.size() > 0:
				if category.is_empty() or word.get("category", "") == category:
					words.append(word_id + " (" + word.get("category", "unknown") + ")")
	
	if words.size() == 0:
		return "No words found" + ("" if category.is_empty() else " in category: " + category)
	
	return "Words in dictionary:\n" + "\n".join(words)

func _cmd_akashic_info(args) -> String:
	if args.size() < 1:
		return "Usage: akashic_info <entity_id>"
	
	var entity_id = args[0]
	var entity = akashic_records_manager.get_entity(entity_id)
	
	if entity.size() == 0:
		return "Entity not found: " + entity_id
	
	return JSON.stringify(entity, "\t")

func _cmd_transform_entity(args) -> String:
	if args.size() < 2:
		return "Usage: transform_entity <entity_id> <new_type>"
	
	var entity_id = args[0]
	var new_type = args[1]
	
	var success = universal_bridge.transform_thing(entity_id, new_type)
	
	if success:
		return "Transformed entity: " + entity_id + " to " + new_type
	else:
		return "Failed to transform entity: " + entity_id

# === Signal Handlers ===

func _on_word_created(word_id: String) -> void:
	print("Word created in dictionary: " + word_id)
	# Integrate with your record system if needed
	if jsh_records_system and jsh_records_system.has_method("update_record"):
		jsh_records_system.update_record("dictionary", word_id, {"created": true})

func _on_entity_created(entity_id: String) -> void:
	print("Entity created in Akashic Records: " + entity_id)
	emit_signal("entity_created", entity_id, "unknown")

func _on_thing_created(thing_id: String, word_id: String, position: Vector3) -> void:
	print("Thing created: " + thing_id + " of type " + word_id)
	emit_signal("entity_created", thing_id, word_id)

func _on_jsh_record_updated(record_id: String) -> void:
	print("JSH record updated: " + record_id)
	emit_signal("records_updated", record_id)

func _on_jsh_parsing_completed(stats: Dictionary) -> void:
	print("JSH parsing completed")
	# Could update your records based on parsed data

# === Utility Functions ===

# Find a node by name in the scene tree
func find_node_by_name(name: String) -> Node:
	if has_node("/root/" + name):
		return get_node("/root/" + name)
		
	var root = get_tree().root
	return _find_node_recursive(root, name)

# Find a node recursively by name
func _find_node_recursive(node: Node, name: String) -> Node:
	if node.name == name:
		return node
	
	for child in node.get_children():
		var found = _find_node_recursive(child, name)
		if found:
			return found
	
	return null

# Find a node by class name
func find_node_by_class(class_name_param: String) -> Node:
	var root = get_tree().root
	return _find_node_by_class_recursive(root, class_name_param)

# Find a node recursively by class
func _find_node_by_class_recursive(node: Node, class_name_param: String) -> Node:
	if node.get_class() == class_name_param:
		return node
	
	for child in node.get_children():
		var found = _find_node_by_class_recursive(child, class_name_param)
		if found:
			return found
	
	return null

# === Public API ===

# Create an entity from a word definition
func create_entity(type: String, position: Vector3) -> String:
	if not is_initialized:
		print("ERROR: System not initialized")
		return ""
	
	return universal_bridge.create_thing_from_word(type, position)

# Transform an entity to a new type
func transform_entity(entity_id: String, new_type: String) -> bool:
	if not is_initialized:
		print("ERROR: System not initialized")
		return false
	
	return universal_bridge.transform_thing(entity_id, new_type)

# Process interaction between two entities
func interact_entities(entity1_id: String, entity2_id: String) -> Dictionary:
	if not is_initialized:
		print("ERROR: System not initialized")
		return {"success": false, "reason": "not_initialized"}
	
	return universal_bridge.process_thing_interaction(entity1_id, entity2_id)

# Create a new word definition
func create_word(word_id: String, properties: Dictionary = {}) -> bool:
	if not is_initialized:
		print("ERROR: System not initialized")
		return false
	
	var word_data = {
		"id": word_id,
		"display_name": word_id.capitalize(),
		"category": properties.get("category", "custom"),
		"parent": properties.get("parent", "primordial"),
		"properties": properties
	}
	
	return akashic_records_manager.create_word(word_id, properties.get("category", "custom"), properties)