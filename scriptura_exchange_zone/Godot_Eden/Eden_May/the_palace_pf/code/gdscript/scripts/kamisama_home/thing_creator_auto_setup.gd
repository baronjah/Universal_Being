extends Node
class_name ThingCreatorAutoSetup

# This script automatically sets up the Thing Creator system
# It attempts to find the correct paths and fix common issues

var jsh_console = null
var akashic_records_manager = null
var view_area = null
var thing_creator = null
var thing_creator_integration = null
var thing_creator_commands = null

var log = []

func _ready():
    # Wait a moment for the scene to fully initialize
    await get_tree().create_timer(0.5).timeout
    
    print("==== Thing Creator Auto Setup Starting ====")
    
    # Find required components
    find_akashic_records()
    find_jsh_console()
    find_view_area()
    
    # Check for required files
    check_required_files()
    
    # Set up Thing Creator
    setup_thing_creator()
    
    # Set up integration and commands
    setup_integration()
    
    # Print final report
    print_report()
    
    print("==== Thing Creator Auto Setup Complete ====")

func find_akashic_records():
    log.append("Searching for AkashicRecordsManager...")
    
    if has_node("/root/AkashicRecordsManager"):
        akashic_records_manager = get_node("/root/AkashicRecordsManager")
        log.append("✓ Found AkashicRecordsManager at: /root/AkashicRecordsManager")
        return
    
    # Try to find by searching all nodes
    akashic_records_manager = find_node_by_class("AkashicRecordsManager")
    if akashic_records_manager:
        log.append("✓ Found AkashicRecordsManager by search")
        return
    
    log.append("✗ Could not find AkashicRecordsManager node")
    log.append("  Ensure Akashic Records system is initialized first")

func find_jsh_console():
    log.append("Searching for JSH console...")
    
    # Common paths to try
    var possible_paths = [
        "/root/Main/JSH_console",
        "/root/Main/CanvasLayer/JSH_console",
        "/root/Main/UI/JSH_console",
        "/root/layer_0/JSH_console",
        "/root/layer_0/CanvasLayer/JSH_console",
        "/root/layer_0/UI/JSH_console"
    ]
    
    # Try each path
    for path in possible_paths:
        if has_node(path):
            jsh_console = get_node(path)
            log.append("✓ Found JSH console at: " + path)
            return
    
    # Try to find by searching all nodes
    jsh_console = find_node_by_name("JSH_console")
    if jsh_console:
        log.append("✓ Found JSH console by search")
        return
    
    log.append("✗ Could not find JSH console node")
    log.append("  JSH console commands will not be available")

func find_view_area():
    log.append("Searching for view area...")
    
    # Common names for view area
    var possible_names = ["ViewArea", "ContentArea", "UIContent", "MainContent", "ViewPort", "ViewContainer"]
    
    for name in possible_names:
        var node = find_node_by_name(name)
        if node and node is Control:
            view_area = node
            log.append("✓ Found view area: " + name)
            return
    
    log.append("✗ Could not find a suitable view area node")
    log.append("  Thing Creator UI may not display correctly")
    
    # Try to create a view area as a fallback
    var main = get_tree().current_scene
    if main:
        view_area = Control.new()
        view_area.name = "ViewArea"
        view_area.anchor_right = 1.0
        view_area.anchor_bottom = 1.0
        main.add_child(view_area)
        log.append("! Created temporary ViewArea as fallback")

func check_required_files():
    log.append("Checking required Thing Creator files...")
    
    var required_files = [
        "res://code/gdscript/scripts/akashic_records/thing_creator.gd",
        "res://code/gdscript/scripts/akashic_records/thing_creator_ui.gd",
        "res://code/gdscript/scenes/thing_creator_ui.tscn",
        "res://code/gdscript/scripts/Menu_Keyboard_Console/thing_creator_integration.gd",
        "res://code/gdscript/scripts/Menu_Keyboard_Console/thing_creator_commands.gd"
    ]
    
    var all_files_exist = true
    
    for file_path in required_files:
        if FileAccess.file_exists(file_path):
            log.append("✓ Found file: " + file_path)
        else:
            log.append("✗ Missing file: " + file_path)
            all_files_exist = false
    
    if not all_files_exist:
        log.append("! Some required files are missing")

func setup_thing_creator():
    log.append("Setting up Thing Creator...")
    
    # Check if already exists
    if has_node("/root/ThingCreator"):
        thing_creator = get_node("/root/ThingCreator")
        log.append("✓ ThingCreator already exists at /root/ThingCreator")
        return
    
    # Create new instance
    var ThingCreatorClass = load("res://code/gdscript/scripts/akashic_records/thing_creator.gd")
    if ThingCreatorClass:
        thing_creator = ThingCreatorClass.new()
        thing_creator.name = "ThingCreator"
        get_tree().root.add_child(thing_creator)
        log.append("✓ Created new ThingCreator instance")
    else:
        log.append("✗ Failed to load ThingCreator class")

func setup_integration():
    log.append("Setting up integration...")
    
    # Set up integration with menu
    var IntegrationClass = load("res://code/gdscript/scripts/Menu_Keyboard_Console/thing_creator_integration.gd")
    if IntegrationClass:
        thing_creator_integration = IntegrationClass.new()
        thing_creator_integration.name = "ThingCreatorIntegration"
        add_child(thing_creator_integration)
        
        # Get main scene for initialization
        var main = get_tree().current_scene
        if main:
            thing_creator_integration.initialize(main)
            log.append("✓ Initialized Thing Creator integration with main scene")
        else:
            log.append("✗ Could not initialize integration: Main scene not found")
    else:
        log.append("✗ Failed to load ThingCreatorIntegration class")
    
    # Set up JSH console commands
    var CommandsClass = load("res://code/gdscript/scripts/Menu_Keyboard_Console/thing_creator_commands.gd")
    if CommandsClass and jsh_console:
        thing_creator_commands = CommandsClass.new()
        thing_creator_commands.name = "ThingCreatorCommands"
        add_child(thing_creator_commands)
        thing_creator_commands.initialize(jsh_console)
        log.append("✓ Initialized Thing Creator commands with JSH console")
    elif not CommandsClass:
        log.append("✗ Failed to load ThingCreatorCommands class")
    elif not jsh_console:
        log.append("✗ Could not initialize commands: JSH console not found")

# Recursive function to find a node by name
func find_node_by_name(node_name, node = null):
    if node == null:
        node = get_tree().root
    
    if node.name == node_name:
        return node
    
    for child in node.get_children():
        var found = find_node_by_name(node_name, child)
        if found:
            return found
    
    return null

# Recursive function to find a node by class name
func find_node_by_class(class_name_to_find, node = null):
    if node == null:
        node = get_tree().root
    
    if node.get_class() == class_name_to_find:
        return node
    
    for child in node.get_children():
        var found = find_node_by_class(class_name_to_find, child)
        if found:
            return found
    
    return null

func print_report():
    print("\n===== THING CREATOR SETUP REPORT =====")
    for entry in log:
        print(entry)
    print("=====================================\n")
    
    # Determine overall status
    var ready_for_use = thing_creator != null
    var commands_ready = thing_creator_commands != null
    var ui_ready = thing_creator_integration != null && view_area != null
    
    print("SETUP STATUS:")
    print("- Core Functionality: " + ("READY" if ready_for_use else "NOT READY"))
    print("- JSH Commands: " + ("READY" if commands_ready else "NOT READY"))
    print("- UI Integration: " + ("READY" if ui_ready else "NOT READY"))
    
    print("\nQUICK TEST COMMANDS:")
    if commands_ready:
        print("1. In JSH console, type: thing-help")
        print("2. In JSH console, type: thing-create fire 0 1 0")
        print("3. In JSH console, type: thing-list")
    else:
        print("JSH commands not available - check report for issues")
    
    if ui_ready:
        print("\nUI ACCESS:")
        print("Look for 'Thing Creator' in your menu system")
    else:
        print("\nUI not available - check report for issues")