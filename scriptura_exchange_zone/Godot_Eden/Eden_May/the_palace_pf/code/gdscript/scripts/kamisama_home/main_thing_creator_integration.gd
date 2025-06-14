# Thing Creator Integration Code for main.gd
# Add this code to your existing main.gd file

# Add these imports at the top of your file
const ThingCreatorIntegration = preload("res://code/gdscript/scripts/Menu_Keyboard_Console/thing_creator_integration.gd")
const ThingCreatorCommands = preload("res://code/gdscript/scripts/Menu_Keyboard_Console/thing_creator_commands.gd")

# Add these class variables to your main.gd class
var thing_creator_integration = null
var thing_creator_commands = null

# Add this function to initialize the Thing Creator system
func _initialize_thing_creator():
    print("Initializing Thing Creator System...")
    
    # Create ThingCreator instance if not already existing
    if not has_node("/root/ThingCreator"):
        var ThingCreatorClass = load("res://code/gdscript/scripts/akashic_records/thing_creator.gd")
        if ThingCreatorClass:
            var thing_creator = ThingCreatorClass.new()
            thing_creator.name = "ThingCreator"
            get_tree().root.add_child(thing_creator)
            print("ThingCreator initialized")
        else:
            print("Failed to load ThingCreator class")
            return
    
    # Initialize Thing Creator integration with menu
    thing_creator_integration = ThingCreatorIntegration.new()
    add_child(thing_creator_integration)
    thing_creator_integration.initialize(self)  # Pass self as the main console
    
    # Initialize Thing Creator commands for JSH console
    thing_creator_commands = ThingCreatorCommands.new()
    add_child(thing_creator_commands)
    
    # Initialize JSH console commands
    # NOTE: Update this path to match your actual JSH console node!
    var jsh_console = null
    if has_node("JSH_console"):
        jsh_console = get_node("JSH_console")
    elif has_node("CanvasLayer/JSH_console"):
        jsh_console = get_node("CanvasLayer/JSH_console")
    
    if jsh_console:
        thing_creator_commands.initialize(jsh_console)
        print("Thing Creator commands registered with JSH console")
    else:
        print("JSH console not found, skipping commands initialization")
    
    print("Thing Creator system fully initialized")

# Add this to your _ready() function after initializing Akashic Records:
# _initialize_thing_creator()

# Make sure you have this function for the Thing Creator UI to work:
func add_to_view_area(content):
    # Adjust the path to match your view area node!
    var view_area = $ViewArea  # or $UI/ViewArea or whatever your path is
    
    # Clear existing content
    for child in view_area.get_children():
        child.queue_free()
    
    # Add new content
    view_area.add_child(content)