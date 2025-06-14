extends Node
class_name JshEtherealIntegration

# This script integrates the JSH Ethereal Engine components into the layer_0 scene
# It serves as a bridge between the main.gd controller and the new engine components

# Components
var thing_creator = null
var ui_controller = null
var akashic_records_manager = null

# Flag to indicate if the system is initialized
var is_initialized = false

func _ready():
	print("JshEtherealIntegration initializing...")
	
	# Wait a bit for the scene to fully initialize
	await get_tree().create_timer(1.0).timeout
	
	# Initialize components
	initialize_components()
	
	print("JshEtherealIntegration ready - press Tab to access interface")

func initialize_components():
	# Create or find the CoreThingCreator
	initialize_thing_creator()
	
	# Create UI
	initialize_ui()
	
	# Connect to main controller signals if needed
	connect_signals()
	
	is_initialized = true

func initialize_thing_creator():
	# Check if ThingCreator already exists
	if has_node("/root/CoreThingCreator"):
		thing_creator = get_node("/root/CoreThingCreator")
		print("Found existing CoreThingCreator")
	else:
		# Load the CoreThingCreator script
		var thing_creator_script = load("res://code/gdscript/scripts/core/CoreThingCreator.gd")
		if thing_creator_script:
			thing_creator = thing_creator_script.get_instance()
			thing_creator.name = "CoreThingCreator"
			get_tree().root.add_child(thing_creator)
			print("Created new CoreThingCreator instance")
		else:
			push_error("CoreThingCreator script not found!")

func initialize_ui():
	# Check if UI already exists
	if has_node("/root/EtherealEngineUI"):
		ui_controller = get_node("/root/EtherealEngineUI")
		print("Found existing EtherealEngineUI")
	else:
		# Load the UI script
		var ui_script = load("res://code/gdscript/scripts/ui/EtherealEngineUI.gd")
		if ui_script:
			ui_controller = ui_script.new()
			ui_controller.name = "EtherealEngineUI"
			get_tree().root.add_child(ui_controller)
			print("Created new EtherealEngineUI instance")
		else:
			push_error("EtherealEngineUI script not found!")

func connect_signals():
	# Connect to main controller signals
	var main_controller = get_parent()
	
	# Connect to any relevant signals from main_controller if needed
	if main_controller.has_signal("ready_for_commands"):
		main_controller.connect("ready_for_commands", _on_main_controller_ready)
	
	# Connect to ThingCreator signals for messaging
	if thing_creator:
		thing_creator.connect("entity_created", _on_entity_created)
		thing_creator.connect("entity_transformed", _on_entity_transformed)
		thing_creator.connect("entity_evolved", _on_entity_evolved)
		thing_creator.connect("entity_connected", _on_entity_connected)
		thing_creator.connect("pattern_created", _on_pattern_created)

# Signal handlers

func _on_main_controller_ready():
	print("Main controller is ready, JSH Ethereal Engine integration complete")

func _on_entity_created(entity_id, word, position):
	var main_controller = get_parent()
	if main_controller.has_method("log_message"):
		main_controller.log_message("Created entity " + entity_id + " from word '" + word + "'")

func _on_entity_transformed(entity_id, old_form, new_form):
	var main_controller = get_parent()
	if main_controller.has_method("log_message"):
		main_controller.log_message("Entity " + entity_id + " transformed from " + old_form + " to " + new_form)

func _on_entity_evolved(entity_id, old_stage, new_stage):
	var main_controller = get_parent()
	if main_controller.has_method("log_message"):
		main_controller.log_message("Entity " + entity_id + " evolved from stage " + str(old_stage) + " to stage " + str(new_stage))

func _on_entity_connected(entity_id, target_id, connection_type):
	var main_controller = get_parent()
	if main_controller.has_method("log_message"):
		main_controller.log_message("Connected entity " + entity_id + " to " + target_id + " with " + connection_type + " connection")

func _on_pattern_created(pattern_id, entities):
	var main_controller = get_parent()
	if main_controller.has_method("log_message"):
		main_controller.log_message("Created pattern " + pattern_id + " with " + str(entities.size()) + " entities")