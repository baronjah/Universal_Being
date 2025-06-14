extends Node
class_name ThingCreatorIntegration

# References
var main_console = null
var akashic_records_manager = null
var thing_creator = null
var thing_creator_ui_scene = null
var current_ui_instance = null

# Initialization
func initialize(p_main_console) -> void:
	main_console = p_main_console
	
	# Find AkashicRecordsManager
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
	else:
		push_error("AkashicRecordsManager not found! Make sure it's initialized.")
		return
	
	# Initialize Thing Creator if not already created
	if has_node("/root/ThingCreator"):
		thing_creator = get_node("/root/ThingCreator")
	else:
		var ThingCreatorClass = load("res://code/gdscript/scripts/akashic_records/thing_creator.gd")
		if ThingCreatorClass:
			thing_creator = ThingCreatorClass.new()
			thing_creator.name = "ThingCreator"
			get_tree().root.add_child(thing_creator)
		else:
			push_error("ThingCreator class not found!")
			return
	
	# Load the Thing Creator UI scene
	thing_creator_ui_scene = load("res://code/gdscript/scenes/thing_creator_ui.tscn")
	
	# Register with main console
	_register_with_console()
	
	print("Thing Creator Integration initialized")

func _register_with_console() -> void:
	if main_console:
		# Register as a system with the main console
		main_console.register_system(self, "ThingCreator")
		
		# Add menu entries
		_add_menu_entries()

func _add_menu_entries() -> void:
	# Create the Thing Creator entry for the "Things" menu
	var creator_entry = {
		"title": "Thing Creator",
		"description": "Create things from Akashic Records",
		"callback": Callable(self, "open_thing_creator_ui"),
		"icon": "cubes"  # Choose an appropriate icon
	}
	
	main_console.add_menu_entry("things", creator_entry)
	
	# Create entry for the "Create" category
	var create_entry = {
		"title": "Create Thing",
		"description": "Create a new thing in the world",
		"callback": Callable(self, "open_thing_creator_ui"),
		"icon": "plus-square"
	}
	
	main_console.add_menu_entry("actions", create_entry)
	
	# Create entry for the "Manage" category
	var manage_entry = {
		"title": "Manage Things",
		"description": "Manage existing things in the world",
		"callback": Callable(self, "open_thing_manager"),
		"icon": "tasks"
	}
	
	main_console.add_menu_entry("things", manage_entry)

# UI Open Handlers
func open_thing_creator_ui() -> void:
	if not thing_creator_ui_scene:
		main_console.show_message("Error: Thing Creator UI scene not found")
		return
	
	# Close existing UI if open
	_close_current_ui()
	
	# Instance the UI
	current_ui_instance = thing_creator_ui_scene.instantiate()
	
	# Connect the thing_created signal
	current_ui_instance.thing_created.connect(_on_thing_created)
	
	# Add to main console view area
	main_console.add_to_view_area(current_ui_instance)
	
	main_console.show_message("Thing Creator UI opened")

func open_thing_manager() -> void:
	# This would be implemented in a future update
	main_console.show_message("Thing Manager not yet implemented")

func _close_current_ui() -> void:
	if current_ui_instance and is_instance_valid(current_ui_instance):
		current_ui_instance.queue_free()
		current_ui_instance = null

# Signal handlers
func _on_thing_created(thing_id: String, word_id: String, position: Vector3) -> void:
	main_console.show_message("Thing created: " + thing_id + " (from word: " + word_id + ")")

# Public API
func create_thing(word_id: String, position: Vector3, custom_properties: Dictionary = {}) -> String:
	if thing_creator:
		return thing_creator.create_thing(word_id, position, custom_properties)
	return ""

func remove_thing(thing_id: String) -> bool:
	if thing_creator:
		return thing_creator.remove_thing(thing_id)
	return false

func get_all_things() -> Array[String]:
	if thing_creator:
		return thing_creator.get_all_things()
	return []

func get_thing_position(thing_id: String) -> Vector3:
	if thing_creator:
		return thing_creator.get_thing_position(thing_id)
	return Vector3.ZERO

func process_thing_interaction(thing1_id: String, thing2_id: String) -> Dictionary:
	if thing_creator:
		return thing_creator.process_thing_interaction(thing1_id, thing2_id)
	return {"success": false, "error": "Thing Creator not available"}