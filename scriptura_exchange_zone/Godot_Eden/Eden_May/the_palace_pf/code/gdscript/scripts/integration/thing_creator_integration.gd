extends Node
class_name CoreThingCreatorIntegration

# References to required systems
var thing_creator = null # Can be ThingCreator (autoload) or CoreThingCreator
var akashic_records_manager = null
var console_system = null

# Signals
signal integration_completed
signal command_registered(command_name)
signal entity_registered(entity_id, word_id, element_id)
signal entity_transformed(entity_id, old_type, new_type)

# Initialize with system references
func initialize(p_thing_creator, p_akashic_records_manager, p_console_system = null) -> void:
	thing_creator = p_thing_creator
	akashic_records_manager = p_akashic_records_manager
	console_system = p_console_system

	# Register commands if console system exists
	if console_system:
		_register_console_commands()

	# Connect signals between systems
	_connect_signals()

	emit_signal("integration_completed")
	print("ThingCreatorIntegration initialized successfully")

func _ready() -> void:
	# Wait a moment to allow other systems to initialize
	await get_tree().create_timer(0.2).timeout

	# Find required systems
	_find_dependencies()

	# Register console commands
	if console_system:
		_register_console_commands()

	emit_signal("integration_completed")
	print("ThingCreatorIntegration completed")

# Find all required dependencies
func _find_dependencies() -> void:
	print("Finding Thing Creator Integration dependencies...")

	# Find ThingCreator - try autoload first, then CoreThingCreator
	if has_node("/root/ThingCreator"):
		thing_creator = get_node("/root/ThingCreator")
	else:
		# Try to find CoreThingCreator by instance
		thing_creator = _find_node_by_class("CoreThingCreator")

		# If not found, try to create a CoreThingCreator
		if not thing_creator:
			thing_creator = CoreThingCreator.get_instance()
			thing_creator.name = "CoreThingCreator"
			get_tree().root.add_child(thing_creator)
			print("Created new CoreThingCreator instance")

	# Find AkashicRecordsManager
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
	else:
		# Try to find CoreAkashicRecordsManager by instance
		akashic_records_manager = _find_node_by_class("CoreAkashicRecordsManager")

		# If not found, try to create a CoreAkashicRecordsManager
		if not akashic_records_manager:
			akashic_records_manager = CoreAkashicRecordsManager.get_instance()
			akashic_records_manager.name = "CoreAkashicRecordsManager"
			get_tree().root.add_child(akashic_records_manager)
			akashic_records_manager.initialize()
			print("Created new CoreAkashicRecordsManager instance")

	# Find Console System
	# Search for different possible console implementations
	for console_class in ["JSH_console", "Console", "DebugConsole", "CommandConsole"]:
		var node = _find_node_by_class(console_class)
		if node:
			console_system = node
			print("Found console system: " + console_class)
			break

	if has_node("/root/JSH_console"):
		console_system = get_node("/root/JSH_console")

	# Report status
	var status = "ThingCreatorIntegration dependencies found:\n"
	status += "- ThingCreator: " + str(is_instance_valid(thing_creator)) + "\n"
	status += "- AkashicRecordsManager: " + str(is_instance_valid(akashic_records_manager)) + "\n"
	status += "- Console System: " + str(is_instance_valid(console_system))
	print(status)

# Connect signals between systems
func _connect_signals() -> void:
	if thing_creator and akashic_records_manager:
		# Connect signals from thing_creator to this integration
		if not thing_creator.is_connected("thing_created", Callable(self, "_on_thing_created")):
			thing_creator.connect("thing_created", Callable(self, "_on_thing_created"))

		if not thing_creator.is_connected("thing_removed", Callable(self, "_on_thing_removed")):
			thing_creator.connect("thing_removed", Callable(self, "_on_thing_removed"))

		# Connect signals from akashic_records_manager if needed
		if akashic_records_manager.has_signal("word_created"):
			if not akashic_records_manager.is_connected("word_created", Callable(self, "_on_word_created")):
				akashic_records_manager.connect("word_created", Callable(self, "_on_word_created"))

# Register commands with the console system
func _register_console_commands() -> void:
	if not console_system or not thing_creator:
		push_error("Cannot register console commands: Missing dependencies")
		return

	print("Registering Thing Creator console commands...")

	# Define commands to register
	var commands = [
		{
			"name": "thing_create",
			"description": "Creates a new thing from a word definition",
			"method": "_execute_thing_create"
		},
		{
			"name": "thing_list",
			"description": "Lists all active things",
			"method": "_execute_thing_list"
		},
		{
			"name": "thing_remove",
			"description": "Removes a thing by ID",
			"method": "_execute_thing_remove"
		},
		{
			"name": "thing_info",
			"description": "Displays information about a thing",
			"method": "_execute_thing_info"
		}
	]

	# Register each command
	for cmd in commands:
		var success = ConsoleIntegrationHelper.register_command(
			console_system,
			cmd["name"],
			cmd["description"],
			self,
			cmd["method"]
		)

		if success:
			emit_signal("command_registered", cmd["name"])
			print("Registered command: " + cmd["name"])
		else:
			push_error("Failed to register command: " + cmd["name"])

# Console command implementations

func _execute_thing_create(args: Array) -> String:
	if not thing_creator:
		return "Error: ThingCreator not available"

	if args.size() < 1:
		return "Usage: thing_create <word_id> [x] [y] [z]"

	var word_id = args[0]
	var position = Vector3.ZERO

	if args.size() >= 4:
		position = Vector3(float(args[1]), float(args[2]), float(args[3]))

	var thing_id = thing_creator.create_thing(word_id, position)

	if thing_id.is_empty():
		return "Failed to create thing from word: " + word_id

	return "Created thing " + thing_id + " from word " + word_id

func _execute_thing_list(_args: Array) -> String:
	if not thing_creator:
		return "Error: ThingCreator not available"

	var things = thing_creator.get_all_things()

	if things.size() == 0:
		return "No active things found"

	var result = "Active things (" + str(things.size()) + "):\n"

	for thing_id in things:
		var word_id = thing_creator.get_thing_word(thing_id)
		var position = thing_creator.get_thing_position(thing_id)
		result += "- " + thing_id + " (Word: " + word_id + ", Position: " + str(position) + ")\n"

	return result

func _execute_thing_remove(args: Array) -> String:
	if not thing_creator:
		return "Error: ThingCreator not available"

	if args.size() < 1:
		return "Usage: thing_remove <thing_id>"

	var thing_id = args[0]

	if not thing_creator.has_thing(thing_id):
		return "Thing not found: " + thing_id

	if thing_creator.remove_thing(thing_id):
		return "Thing removed: " + thing_id

	return "Failed to remove thing: " + thing_id

func _execute_thing_info(args: Array) -> String:
	if not thing_creator:
		return "Error: ThingCreator not available"

	if args.size() < 1:
		return "Usage: thing_info <thing_id>"

	var thing_id = args[0]

	if not thing_creator.has_thing(thing_id):
		return "Thing not found: " + thing_id

	var thing_data = thing_creator.get_thing(thing_id)
	var result = "Thing: " + thing_id + "\n"
	result += "Word: " + thing_data.get("word_id", "<unknown>") + "\n"
	result += "Position: " + str(thing_data.get("position", Vector3.ZERO)) + "\n"

	# Display properties if any
	var properties = thing_data.get("properties", {})
	if properties.size() > 0:
		result += "Properties:\n"
		for key in properties.keys():
			result += "  " + key + ": " + str(properties[key]) + "\n"

	return result

# For backward compatibility
func _cmd_create_thing(args: Array) -> String:
	return _execute_thing_create(args)

func _cmd_list_things(args: Array) -> String:
	return _execute_thing_list(args)

func _cmd_remove_thing(args: Array) -> String:
	return _execute_thing_remove(args)

func _cmd_thing_info(args: Array) -> String:
	return _execute_thing_info(args)

# Signal handlers
func _on_thing_created(thing_id: String, word_id: String, position: Vector3) -> void:
	if console_system and console_system.has_method("add_text_line"):
		console_system.add_text_line("Thing created: " + thing_id)

func _on_thing_removed(thing_id: String) -> void:
	if console_system and console_system.has_method("add_text_line"):
		console_system.add_text_line("Thing removed: " + thing_id)

func _on_word_created(word_id: String) -> void:
	if console_system and console_system.has_method("add_text_line"):
		console_system.add_text_line("New word available for thing creation: " + word_id)

# Helper method to find a node by class
func _find_node_by_class(class_name_to_find: String, node: Node = null) -> Node:
	if node == null:
		node = get_tree().root

	if node.get_class() == class_name_to_find:
		return node

	for child in node.get_children():
		var found = _find_node_by_class(class_name_to_find, child)
		if found:
			return found

	return null