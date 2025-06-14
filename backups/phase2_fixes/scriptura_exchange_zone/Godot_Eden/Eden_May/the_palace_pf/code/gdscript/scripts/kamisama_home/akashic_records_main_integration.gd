# Akashic Records Integration for main.gd
# This file contains the code blocks needed to integrate the Akashic Records system
# into your main.gd script for the layer_0.tscn scene.

# 1. Add this import at the top of your main.gd file
const AkashicRecordsIntegration = preload("res://code/gdscript/scripts/Menu_Keyboard_Console/akashic_records_integration.gd")

# 2. Add this class variable to your main.gd file
# Akashic Records integration
var akashic_records_integration = null

# 3. Add this code to your _ready() function after menu system initialization
func _initialize_akashic_records() -> void:
    # Initialize Akashic Records integration
    akashic_records_integration = AkashicRecordsIntegration.new()
    add_child(akashic_records_integration)
    akashic_records_integration.initialize(self)
    print("Akashic Records system initialized")

# 4. Add this access method to your main.gd script
# Get the Akashic Records integration
func get_akashic_records() -> AkashicRecordsIntegration:
    return akashic_records_integration

# 5. If you don't already have a view area, add this variable
# View area for UI content
@onready var view_area = $ViewArea

# 6. Add this method if you don't already have it
# Add content to the view area
func add_to_view_area(content: Control) -> void:
    # Clear existing content
    for child in view_area.get_children():
        child.queue_free()
    
    # Add new content
    view_area.add_child(content)

# 7. Add these system registration methods if you don't have them
# Dictionary of registered systems
var registered_systems = {}

# Register a system with the console
func register_system(system, system_name: String) -> void:
    registered_systems[system_name] = system
    print("System registered: " + system_name)

# Get a registered system
func get_system(system_name: String):
    return registered_systems.get(system_name, null)

# 8. Add this menu entry management function if you don't have it
# Add a menu entry to a category
func add_menu_entry(category: String, entry: Dictionary) -> void:
    if category == "things":
        things_bank.add_entry(entry)
    elif category == "scenes":
        scenes_bank.add_entry(entry)
    elif category == "actions":
        actions_bank.add_entry(entry)
    elif category == "instructions":
        instructions_bank.add_entry(entry)
    # Note: Adjust to match your existing menu system's structure

# 9. Add this message display function if you don't have it
# Show a message to the user
func show_message(message: String) -> void:
    print(message)  # Fallback to console
    
    # If you have a UI label for status messages:
    # $StatusLabel.text = message

# Instructions for calling _initialize_akashic_records():
# In your _ready() function, add the following line after you've initialized
# your menu system:
# _initialize_akashic_records()