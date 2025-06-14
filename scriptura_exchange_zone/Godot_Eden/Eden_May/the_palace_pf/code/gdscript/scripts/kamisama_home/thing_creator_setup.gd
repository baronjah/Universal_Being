extends Node
class_name ThingCreatorSetup

# This script handles the initialization of the Thing Creator system
# Add this to your main scene to set up the system

func _ready():
	# Initialize the system
	initialize_thing_creator()

func initialize_thing_creator():
	print("Initializing Thing Creator System...")
	
	# First check if AkashicRecordsManager exists
	if not has_node("/root/AkashicRecordsManager"):
		push_error("AkashicRecordsManager not found! Make sure it's initialized before Thing Creator.")
		return false
	
	# Then check if ThingCreator already exists to avoid duplication
	if has_node("/root/ThingCreator"):
		print("ThingCreator already initialized.")
		return true
	
	# Create ThingCreator
	var ThingCreatorClass = load("res://code/gdscript/scripts/akashic_records/thing_creator.gd")
	if not ThingCreatorClass:
		push_error("Failed to load ThingCreator class.")
		return false
		
	var thing_creator = ThingCreatorClass.new()
	thing_creator.name = "ThingCreator"
	get_tree().root.add_child(thing_creator)
	
	print("ThingCreator initialized successfully.")
	
	# Initialize JSH console commands if console is available
	initialize_jsh_commands()
	
	# Initialize Thing Creator Integration for menu system if main console is available
	initialize_menu_integration()
	
	return true

func initialize_jsh_commands():
	var jsh_console = null
	
	# Find JSH console
	if has_node("/root/JSH_console"):
		jsh_console = get_node("/root/JSH_console")
	elif has_node("/root/Main/JSH_console"):
		jsh_console = get_node("/root/Main/JSH_console")
	
	if not jsh_console:
		print("JSH console not found, skipping command initialization.")
		return false
	
	# Create command handler
	var CommandsClass = load("res://code/gdscript/scripts/Menu_Keyboard_Console/thing_creator_commands.gd")
	if not CommandsClass:
		push_error("Failed to load ThingCreatorCommands class.")
		return false
		
	var commands = CommandsClass.new()
	commands.name = "ThingCreatorCommands"
	add_child(commands)
	commands.initialize(jsh_console)
	
	print("Thing Creator commands initialized for JSH console.")
	return true

func initialize_menu_integration():
	var main_console = null
	
	# Find main console (typically in Main node)
	if has_node("/root/Main"):
		var main = get_node("/root/Main")
		
		# Check if main has a add_menu_entry method (assuming this is the console)
		if main.has_method("add_menu_entry"):
			main_console = main
	
	if not main_console:
		print("Main console not found, skipping menu integration.")
		return false
	
	# Create integration
	var IntegrationClass = load("res://code/gdscript/scripts/Menu_Keyboard_Console/thing_creator_integration.gd")
	if not IntegrationClass:
		push_error("Failed to load ThingCreatorIntegration class.")
		return false
		
	var integration = IntegrationClass.new()
	integration.name = "ThingCreatorIntegration"
	add_child(integration)
	integration.initialize(main_console)
	
	print("Thing Creator menu integration initialized.")
	return true

# Call this method to manually initialize the system if needed
func manual_initialize():
	return initialize_thing_creator()