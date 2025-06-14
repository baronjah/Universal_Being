extends Node
class_name AkashicIntegration

# This script integrates all JSH systems with the Akashic Records database
# It should be added to your main scene

# Constants
const AUTO_INITIALIZE = true
const DEBUG_MODE = true

# System references
var universal_bridge = null
var akashic_records_manager = null
var element_manager = null
var thing_creator = null
var ui_manager = null

# Signals
signal integration_initialized
signal main_menu_created
signal debug_info_updated(info)

# System status
var integration_status = {
	"akashic_records": false,
	"element_manager": false,
	"thing_creator": false,
	"bridge": false,
	"console": false,
	"menu": false
}

func _ready():
	if AUTO_INITIALIZE:
		call_deferred("initialize")

# Initialize the integration
func initialize() -> bool:
	print("Initializing Akashic Integration...")
	
	# Step 1: Initialize the Akashic Records Manager
	_initialize_akashic_records()
	
	# Step 2: Connect to Element Manager and Thing Creator
	_connect_systems()
	
	# Step 3: Initialize the Universal Bridge
	_initialize_universal_bridge()
	
	# Step 4: Setup UI if needed
	_setup_ui()
	
	# Step 5: Register console commands
	_register_console_commands()
	
	print("Akashic Integration complete!")
	emit_signal("integration_initialized")
	
	# Create initial dictionary entries for demonstration
	_create_initial_dictionary_entries()
	
	return true

# Initialize the Akashic Records Manager
func _initialize_akashic_records() -> void:
	# Check if AkashicRecordsManager is already in the scene tree
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
	else:
		# Create instance if not found
		akashic_records_manager = AkashicRecordsManagerA.get_instance()
		
		# Add to scene tree if needed
		if not akashic_records_manager.get_parent():
			add_child(akashic_records_manager)
	
	# Initialize if needed
	if not akashic_records_manager.is_initialized:
		akashic_records_manager.initialize()
	
	integration_status["akashic_records"] = true
	print("Akashic Records Manager initialized")

# Connect to Element Manager and Thing Creator
func _connect_systems() -> void:
	# Find Element Manager
	if has_node("/root/ElementManager"):
		element_manager = get_node("/root/ElementManager")
	else:
		var nodes = get_tree().get_nodes_in_group("element_manager")
		if nodes.size() > 0:
			element_manager = nodes[0]
		else:
			# Look for it in the scene tree
			element_manager = _find_node_by_class("ElementManager")
	
	integration_status["element_manager"] = element_manager != null
	
	# Find Thing Creator
	if has_node("/root/ThingCreator"):
		thing_creator = get_node("/root/ThingCreator")
	else:
		# Create instance if not found
		thing_creator = ThingCreatorA.get_instance()
		
		# Add to scene tree if needed
		if not thing_creator.get_parent():
			add_child(thing_creator)
	
	integration_status["thing_creator"] = true
	print("Connected to systems - Element Manager: ", integration_status["element_manager"], ", Thing Creator: ", integration_status["thing_creator"])

# Initialize the Universal Bridge
func _initialize_universal_bridge() -> void:
	universal_bridge = UniversalBridge.get_instance()
	
	# Add to scene tree if needed
	if not universal_bridge.get_parent():
		add_child(universal_bridge)
	
	# Initialize the bridge
	universal_bridge.initialize()
	
	integration_status["bridge"] = true
	print("Universal Bridge initialized")
	
	# Ensure element definitions exist
	universal_bridge.ensure_element_definitions()

# Setup UI components
func _setup_ui() -> void:
	# Create UI manager if needed
	ui_manager = AkashicRecordsUI.new()
	add_child(ui_manager)
	
	# Connect UI to systems
	ui_manager.setup(akashic_records_manager, thing_creator, universal_bridge)
	
	integration_status["menu"] = true
	print("UI setup complete")
	
	# Create main menu
	_create_main_menu()

# Register console commands
func _register_console_commands() -> void:
	# Find JSH console if available
	var console = null
	
	if has_node("/root/main/JSH_console"):
		console = get_node("/root/main/JSH_console")
	elif has_node("/root/main/CanvasLayer/JSH_console"):
		console = get_node("/root/main/CanvasLayer/JSH_console")
	
	if console:
		# Register commands with console
		var commands = _get_akashic_commands()
		
		for command in commands:
			if console.has_method("register_command"):
				console.register_command(command.name, command.description, command.callback)
		
		integration_status["console"] = true
		print("Console commands registered")

# Utility function to find node by class name
func _find_node_by_class(class_name_param: String) -> Node:
	var nodes = get_tree().get_nodes_in_group("__nodes_by_class_" + class_name_param)
	if nodes.size() > 0:
		return nodes[0]

	return null

# Create main menu for Akashic Records
func _create_main_menu() -> void:
	# This depends on your menu system implementation
	# Here's a generic approach using the ui_manager
	
	if ui_manager:
		var menu_items = [
			{
				"id": "create_element",
				"text": "Create Element",
				"icon": "element",
				"callback": "create_element_menu"
			},
			{
				"id": "dictionary_browser",
				"text": "Dictionary Browser",
				"icon": "dictionary",
				"callback": "open_dictionary_browser"
			},
			{
				"id": "thing_creator",
				"text": "Thing Creator",
				"icon": "create",
				"callback": "open_thing_creator"
			},
			{
				"id": "interactions",
				"text": "Interactions",
				"icon": "interaction",
				"callback": "open_interactions_menu"
			}
		]
		
		ui_manager.create_main_menu(menu_items)
		
		emit_signal("main_menu_created")
		print("Main menu created")

# Get Akashic Records commands for console
func _get_akashic_commands() -> Array:
	return [
		{
			"name": "akashic_create",
			"description": "Create a new word in the dictionary. Usage: akashic_create <word_id> <category> [parent]",
			"callback": "cmd_akashic_create"
		},
		{
			"name": "akashic_get",
			"description": "Get word information from the dictionary. Usage: akashic_get <word_id>",
			"callback": "cmd_akashic_get"
		},
		{
			"name": "akashic_list",
			"description": "List words in the dictionary. Usage: akashic_list [category]",
			"callback": "cmd_akashic_list"
		},
		{
			"name": "akashic_interact",
			"description": "Process interaction between two words. Usage: akashic_interact <word1> <word2>",
			"callback": "cmd_akashic_interact"
		},
		{
			"name": "create_thing",
			"description": "Create a thing from a word definition. Usage: create_thing <word_id> <x> <y> <z>",
			"callback": "cmd_create_thing"
		},
		{
			"name": "transform_thing",
			"description": "Transform a thing to a new type. Usage: transform_thing <thing_id> <new_type>",
			"callback": "cmd_transform_thing"
		},
		{
			"name": "manifest_word",
			"description": "Manifest a word as elements. Usage: manifest_word <word_id> <x> <y> <z> [size]",
			"callback": "cmd_manifest_word"
		}
	]

# Console command implementations
func cmd_akashic_create(args, console) -> String:
	if args.size() < 2:
		return "Usage: akashic_create <word_id> <category> [parent]"
	
	var word_id = args[0]
	var category = args[1]
	var parent = args[2] if args.size() > 2 else ""
	
	var word_data = {
		"id": word_id,
		"display_name": word_id.capitalize(),
		"category": category,
		"parent": parent,
		"properties": {}
	}
	
	var success = akashic_records_manager.create_word(word_id, word_data)
	
	if success:
		return "Created word: " + word_id
	else:
		return "Failed to create word: " + word_id

func cmd_akashic_get(args, console) -> String:
	if args.size() < 1:
		return "Usage: akashic_get <word_id>"
	
	var word_id = args[0]
	var word = akashic_records_manager.get_word(word_id)
	
	if word.size() == 0:
		return "Word not found: " + word_id
	
	return JSON.stringify(word, "\t")

func cmd_akashic_list(args, console) -> String:
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

func cmd_akashic_interact(args, console) -> String:
	if args.size() < 2:
		return "Usage: akashic_interact <word1> <word2>"
	
	var word1 = args[0]
	var word2 = args[1]
	
	var result = akashic_records_manager.interaction_engine.process_interaction(word1, word2)
	
	if result.success:
		return "Interaction result: " + result.get("type", "unknown") + "\n" + JSON.stringify(result, "\t")
	else:
		return "Interaction failed: " + result.get("reason", "unknown")

func cmd_create_thing(args, console) -> String:
	if args.size() < 4:
		return "Usage: create_thing <word_id> <x> <y> <z>"
	
	var word_id = args[0]
	var x = float(args[1])
	var y = float(args[2])
	var z = float(args[3])
	
	var thing_id = universal_bridge.create_thing_from_word(word_id, Vector3(x, y, z))
	
	if thing_id.is_empty():
		return "Failed to create thing from word: " + word_id
	
	return "Created thing: " + thing_id + " at position (" + str(x) + ", " + str(y) + ", " + str(z) + ")"

func cmd_transform_thing(args, console) -> String:
	if args.size() < 2:
		return "Usage: transform_thing <thing_id> <new_type>"
	
	var thing_id = args[0]
	var new_type = args[1]
	
	var success = universal_bridge.transform_thing(thing_id, new_type)
	
	if success:
		return "Transformed thing: " + thing_id + " to type: " + new_type
	else:
		return "Failed to transform thing: " + thing_id

func cmd_manifest_word(args, console) -> String:
	if args.size() < 4:
		return "Usage: manifest_word <word_id> <x> <y> <z> [size]"
	
	var word_id = args[0]
	var x = float(args[1])
	var y = float(args[2])
	var z = float(args[3])
	var size = float(args[4]) if args.size() > 4 else 10.0
	
	var entity_ids = universal_bridge.manifest_word_as_elements(word_id, Vector3(x, y, z), size)
	
	if entity_ids.size() == 0:
		return "Failed to manifest word: " + word_id
	
	return "Manifested word: " + word_id + " with " + str(entity_ids.size()) + " elements"

# Create initial dictionary entries for demonstration
func _create_initial_dictionary_entries() -> void:
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
	
	print("Created initial dictionary entries")
	
	# Check status of all systems
	print("Integration status:")
	print("- Akashic Records: ", integration_status["akashic_records"])
	print("- Element Manager: ", integration_status["element_manager"])
	print("- Thing Creator: ", integration_status["thing_creator"])
	print("- Bridge: ", integration_status["bridge"])
	print("- Console: ", integration_status["console"])
	print("- Menu: ", integration_status["menu"])
	
	# Emit debug info
	emit_signal("debug_info_updated", integration_status)