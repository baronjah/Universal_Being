extends Node
class_name ThingCreatorAutoIntegrator

# This script automatically diagnoses and integrates the Thing Creator system
# into your layer_0.tscn without requiring modification of main.gd

var jsh_console = null
var main_console = null
var akashic_records_manager = null
var view_area = null
var thing_creator = null
var thing_creator_integration = null
var thing_creator_commands = null

var log = []

func _ready():
    # Wait a moment for the scene to fully initialize
    await get_tree().create_timer(0.5).timeout
    
    print("==== Thing Creator Auto Integrator Starting ====")
    
    # Analyze the scene structure first
    analyze_scene()
    
    # Find key components
    find_akashic_records()
    find_jsh_console()
    find_main_console()
    find_view_area()
    
    # Implement the integration
    implement_integration()
    
    # Print final report
    print_report()
    
    print("==== Thing Creator Auto Integrator Complete ====")

# Analyze the scene to understand its structure
func analyze_scene():
    log.append("Analyzing scene structure...")
    
    var root = get_tree().root
    var current_scene = get_tree().current_scene
    
    log.append("- Root name: " + root.name)
    log.append("- Current scene name: " + current_scene.name)
    
    # List immediate children with scripts
    var script_nodes = []
    for child in current_scene.get_children():
        if child.get_script():
            script_nodes.append(child)
            
    log.append("- Found " + str(script_nodes.size()) + " immediate children with scripts")
    
    # Try to identify the main controller
    for node in script_nodes:
        if has_menu_methods(node):
            log.append("- Node '" + node.name + "' appears to be a main controller")
    
    # Look for JSH Console
    var jsh_candidates = []
    find_nodes_with_name_containing("console", root, jsh_candidates)
    if jsh_candidates.size() > 0:
        log.append("- Found " + str(jsh_candidates.size()) + " potential console nodes")

# Check if a node has menu-related methods
func has_menu_methods(node):
    var menu_methods = ["add_menu_entry", "register_system", "show_message", "add_to_view_area"]
    
    var found_methods = 0
    for method in menu_methods:
        if node.has_method(method):
            found_methods += 1
    
    return found_methods >= 2

# Find the AkashicRecordsManager
func find_akashic_records():
    log.append("Searching for AkashicRecordsManager...")
    
    if has_node("/root/AkashicRecordsManager"):
        akashic_records_manager = get_node("/root/AkashicRecordsManager")
        log.append("✓ Found AkashicRecordsManager at: /root/AkashicRecordsManager")
        return
    
    # Try to find by searching all nodes
    akashic_records_manager = find_node_by_class("AkashicRecordsManager")
    if akashic_records_manager:
        log.append("✓ Found AkashicRecordsManager by search at: " + str(akashic_records_manager.get_path()))
        return
    
    log.append("✗ Could not find AkashicRecordsManager node")
    log.append("  Ensure Akashic Records system is initialized first")

# Find the JSH console
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
        log.append("✓ Found JSH console by search at: " + str(jsh_console.get_path()))
        return
    
    # Last resort - try to find by class or partial name
    var console_candidates = []
    find_nodes_with_name_containing("console", get_tree().root, console_candidates)
    if console_candidates.size() > 0:
        jsh_console = console_candidates[0]
        log.append("✓ Found potential JSH console by name: " + str(jsh_console.get_path()))
        return
    
    log.append("✗ Could not find JSH console node")
    log.append("  JSH console commands will not be available")

# Find the main console (node with menu methods)
func find_main_console():
    log.append("Searching for main console (menu controller)...")
    
    # First check the main scene node
    var main = get_tree().current_scene
    if has_menu_methods(main):
        main_console = main
        log.append("✓ Main scene implements menu methods")
        return
    
    # Then check immediate children
    for child in main.get_children():
        if has_menu_methods(child):
            main_console = child
            log.append("✓ Found menu controller: " + str(main_console.get_path()))
            return
    
    # Last resort - look for a node that might have a script
    var script_nodes = []
    find_nodes_with_scripts(main, script_nodes)
    
    for node in script_nodes:
        if has_menu_methods(node):
            main_console = node
            log.append("✓ Found potential menu controller: " + str(main_console.get_path()))
            return
    
    log.append("✗ Could not find a node with menu methods")
    log.append("  Will use main scene as fallback")
    main_console = main

# Find a suitable view area for UI content
func find_view_area():
    log.append("Searching for view area...")
    
    # Common names for view area
    var possible_names = ["ViewArea", "ContentArea", "UIContent", "MainContent", "ViewPort", "ViewContainer"]
    
    # Try to find by name first
    for name in possible_names:
        var node = find_node_by_name(name)
        if node and node is Control:
            view_area = node
            log.append("✓ Found view area by name: " + name)
            return
    
    # Try to find a container that might work as a view area
    var containers = []
    
    # Try to find Container nodes
    var container_found = find_suitable_container(get_tree().root, containers)
    if container_found and containers.size() > 0:
        # Sort by suitability (prefer Control nodes with more space)
        containers.sort_custom(Callable(self, "_sort_by_suitability"))
        view_area = containers[0]
        log.append("✓ Found suitable container for view area: " + str(view_area.get_path()))
        return
    
    # Create a view area as a last resort
    log.append("✗ Could not find a suitable view area node")
    log.append("  Creating a fallback view area")
    
    view_area = Control.new()
    view_area.name = "ViewArea"
    view_area.anchor_right = 1.0
    view_area.anchor_bottom = 1.0
    
    var fallback_parent = main_console if main_console else get_tree().current_scene
    fallback_parent.add_child(view_area)
    log.append("! Created fallback ViewArea as child of: " + str(fallback_parent.name))

# Find suitable container nodes recursively
func find_suitable_container(node, containers):
    var found = false
    
    # Check if this node is a suitable container
    if node is Control and _is_suitable_container(node):
        containers.append(node)
        found = true
    
    # Check children
    for child in node.get_children():
        if find_suitable_container(child, containers):
            found = true
    
    return found

# Check if a node is suitable as a container
func _is_suitable_container(node):
    # Prefer Panel, VBoxContainer, Control nodes
    var suitable_classes = ["Panel", "PanelContainer", "VBoxContainer", "HBoxContainer", "Control"]
    
    for class_name in suitable_classes:
        if node.is_class(class_name):
            return true
    
    return false

# Sort containers by suitability
func _sort_by_suitability(a, b):
    # Prefer containers with specific names
    var view_keywords = ["view", "content", "container", "panel", "area"]
    
    var a_name_score = _name_keyword_score(a.name, view_keywords)
    var b_name_score = _name_keyword_score(b.name, view_keywords)
    
    if a_name_score != b_name_score:
        return a_name_score > b_name_score
    
    # Then prefer Control nodes with more real estate
    var a_size = _get_node_area(a)
    var b_size = _get_node_area(b)
    
    return a_size > b_size

# Calculate keyword score based on name
func _name_keyword_score(node_name, keywords):
    var score = 0
    var name_lower = node_name.to_lower()
    
    for keyword in keywords:
        if keyword in name_lower:
            score += 1
    
    return score

# Get approximate node area
func _get_node_area(node):
    if node is Control:
        var rect = node.get_rect()
        return rect.size.x * rect.size.y
    return 0

# Implement the integration
func implement_integration():
    log.append("Implementing Thing Creator integration...")
    
    # Check dependencies
    if not akashic_records_manager:
        log.append("! Cannot continue without AkashicRecordsManager")
        log.append("  Make sure Akashic Records is initialized first")
        return
    
    # Create Thing Creator if needed
    setup_thing_creator()
    
    # Set up integration with console
    setup_integration()
    
    # Set up JSH commands if possible
    setup_jsh_commands()
    
    # Create proxy methods on main scene
    create_proxy_methods()

# Set up the Thing Creator
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

# Set up integration with the menu
func setup_integration():
    log.append("Setting up menu integration...")
    
    if not main_console:
        log.append("✗ Cannot set up menu integration: No main console found")
        return
    
    # Create integration
    var IntegrationClass = load("res://code/gdscript/scripts/Menu_Keyboard_Console/thing_creator_integration.gd")
    if IntegrationClass:
        thing_creator_integration = IntegrationClass.new()
        thing_creator_integration.name = "ThingCreatorIntegration"
        add_child(thing_creator_integration)
        
        # Modify the initialize method to use proxies if needed
        # This handles the case where main_console doesn't implement all methods
        add_proxy_methods_to_main_console()
        
        # Initialize the integration
        thing_creator_integration.initialize(main_console)
        log.append("✓ Initialized Thing Creator integration with main console")
    else:
        log.append("✗ Failed to load ThingCreatorIntegration class")

# Set up JSH console commands
func setup_jsh_commands():
    log.append("Setting up JSH console commands...")
    
    if not jsh_console:
        log.append("✗ Cannot set up JSH commands: No JSH console found")
        return
    
    # Create commands
    var CommandsClass = load("res://code/gdscript/scripts/Menu_Keyboard_Console/thing_creator_commands.gd")
    if CommandsClass:
        thing_creator_commands = CommandsClass.new()
        thing_creator_commands.name = "ThingCreatorCommands"
        add_child(thing_creator_commands)
        
        # Initialize the commands
        if jsh_console.has_method("register_command"):
            thing_creator_commands.initialize(jsh_console)
            log.append("✓ Initialized Thing Creator commands with JSH console")
        else:
            log.append("✗ JSH console does not have register_command method")
    else:
        log.append("✗ Failed to load ThingCreatorCommands class")

# Add proxy methods to the main console if needed
func add_proxy_methods_to_main_console():
    var required_methods = {
        "register_system": funcref(self, "_proxy_register_system"),
        "add_menu_entry": funcref(self, "_proxy_add_menu_entry"),
        "add_to_view_area": funcref(self, "_proxy_add_to_view_area"),
        "show_message": funcref(self, "_proxy_show_message")
    }
    
    for method in required_methods:
        if not main_console.has_method(method):
            # Add a proxy method to our script
            if method == "register_system":
                main_console.register_system = required_methods[method]
            elif method == "add_menu_entry":
                main_console.add_menu_entry = required_methods[method]
            elif method == "add_to_view_area":
                main_console.add_to_view_area = required_methods[method]
            elif method == "show_message":
                main_console.show_message = required_methods[method]
            
            log.append("! Added proxy method to main console: " + method)

# Create proxy methods for menu integration
func create_proxy_methods():
    log.append("Creating proxy methods...")
    
    # Register our proxy object on the main scene so it can be found later
    var main = get_tree().current_scene
    if not main.has_meta("thing_creator_proxy"):
        main.set_meta("thing_creator_proxy", self)
        log.append("✓ Registered proxy on main scene")

# Proxy method implementations
func _proxy_register_system(system, system_name):
    print("Proxy register_system called: " + system_name)
    # Store in our own dictionary
    if not has_meta("registered_systems"):
        set_meta("registered_systems", {})
    
    var systems = get_meta("registered_systems")
    systems[system_name] = system

func _proxy_add_menu_entry(category, entry):
    print("Proxy add_menu_entry called for category: " + category)
    # Try to find an actual bank with this name
    var bank_name = category + "_bank"
    var main = get_tree().current_scene
    
    if main.has_node(bank_name):
        var bank = main.get_node(bank_name)
        if bank.has_method("add_entry"):
            bank.add_entry(entry)
    
    # Store in our own dictionary as fallback
    if not has_meta("menu_entries"):
        set_meta("menu_entries", {})
    
    var entries = get_meta("menu_entries")
    if not entries.has(category):
        entries[category] = []
    
    entries[category].append(entry)

func _proxy_add_to_view_area(content):
    print("Proxy add_to_view_area called")
    if view_area:
        # Clear existing content
        for child in view_area.get_children():
            child.queue_free()
        
        # Add new content
        view_area.add_child(content)

func _proxy_show_message(message):
    print("Proxy show_message called: " + message)
    # Just print to console as fallback

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

# Recursive function to find a node by class
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

# Find nodes with scripts
func find_nodes_with_scripts(node, results):
    if node.get_script():
        results.append(node)
    
    for child in node.get_children():
        find_nodes_with_scripts(child, results)

# Find nodes with a specific string in their name
func find_nodes_with_name_containing(substring, node, results):
    if substring.to_lower() in node.name.to_lower():
        results.append(node)
    
    for child in node.get_children():
        find_nodes_with_name_containing(substring, child, results)

func print_report():
    print("\n===== THING CREATOR INTEGRATION REPORT =====")
    for entry in log:
        print(entry)
    print("===========================================\n")
    
    # Determine overall status
    var ready_for_use = thing_creator != null
    var jsh_ready = thing_creator_commands != null && jsh_console != null
    var ui_ready = thing_creator_integration != null && main_console != null && view_area != null
    
    print("INTEGRATION STATUS:")
    print("- Core Functionality: " + ("READY" if ready_for_use else "NOT READY"))
    print("- JSH Commands: " + ("READY" if jsh_ready else "NOT READY"))
    print("- UI Integration: " + ("READY" if ui_ready else "NOT READY"))
    
    print("\nINTEGRATION INFO:")
    if thing_creator:
        print("- ThingCreator: " + str(thing_creator.get_path()))
    if thing_creator_integration:
        print("- Integration: " + str(thing_creator_integration.get_path()))
    if thing_creator_commands:
        print("- Commands: " + str(thing_creator_commands.get_path()))
    if main_console:
        print("- Main Console: " + str(main_console.get_path()))
    if jsh_console:
        print("- JSH Console: " + str(jsh_console.get_path()))
    if view_area:
        print("- View Area: " + str(view_area.get_path()))
    
    print("\nQUICK TEST COMMANDS:")
    if jsh_ready:
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