extends Node
class_name MenuSystemInspector

# This script is designed to analyze the menu system structure 
# to understand how to properly integrate the Thing Creator

var log = []

func _ready():
    # Wait a moment for the scene to fully initialize
    await get_tree().create_timer(0.5).timeout
    
    print("==== Menu System Inspector Starting ====")
    
    # Analyze the scene structure
    inspect_scene_structure()
    
    # Look for menu-related nodes
    find_menu_nodes()
    
    # Check for JSH console implementation
    check_jsh_console()
    
    # Check for "things", "actions", etc. banks
    check_for_banks()
    
    # Try to find the main.gd script
    find_main_script()
    
    # Print the analysis
    print_analysis()
    
    print("==== Menu System Inspector Complete ====")

func inspect_scene_structure():
    log.append("Scene Structure Analysis:")
    
    var root = get_tree().root
    var current_scene = get_tree().current_scene
    
    log.append("- Root name: " + root.name)
    log.append("- Current scene name: " + current_scene.name)
    
    # List all direct children of the scene
    var children = current_scene.get_children()
    log.append("- Scene has " + str(children.size()) + " direct children:")
    
    for i in range(min(children.size(), 10)):  # Show the first 10 children
        var child = children[i]
        log.append("  - " + child.name + " (" + child.get_class() + ")")
        
        # Check if this could be a menu controller
        if child.get_script():
            log.append("    Has script: " + str(child.get_script().resource_path))
            check_node_for_menu_methods(child)

func find_menu_nodes():
    log.append("Searching for menu-related nodes...")
    
    var possible_menu_names = [
        "Menu", "MainMenu", "Console", "JSH_console", "CommandLine", 
        "MenuController", "GameMenu", "HUD", "UI"
    ]
    
    for name in possible_menu_names:
        var node = find_node_by_name(name)
        if node:
            log.append("- Found potential menu node: " + name)
            check_node_for_menu_methods(node)

func check_node_for_menu_methods(node):
    # Check for methods used in menu systems
    var menu_methods = [
        "add_menu_entry", 
        "register_system", 
        "show_message", 
        "add_to_view_area"
    ]
    
    var has_methods = false
    
    for method in menu_methods:
        if node.has_method(method):
            if not has_methods:
                log.append("  Menu methods found:")
                has_methods = true
            log.append("  - " + method + "()")

func check_jsh_console():
    log.append("Checking for JSH console implementation...")
    
    var jsh_console = find_node_by_name("JSH_console")
    if jsh_console:
        log.append("- Found JSH_console node: " + str(jsh_console.get_path()))
        
        # Check for typical console methods
        var console_methods = [
            "register_command",
            "execute_command",
            "print_to_console"
        ]
        
        for method in console_methods:
            if jsh_console.has_method(method):
                log.append("  - Has " + method + "()")
    else:
        log.append("- JSH_console node not found directly")
        
        # Try a more generic search
        var console_nodes = []
        find_nodes_with_name_containing("console", get_tree().root, console_nodes)
        
        if console_nodes.size() > 0:
            log.append("- Found " + str(console_nodes.size()) + " potential console nodes:")
            for node in console_nodes:
                log.append("  - " + str(node.get_path()))

func check_for_banks():
    log.append("Checking for menu banks...")
    
    var bank_names = ["things_bank", "actions_bank", "scenes_bank", "instructions_bank"]
    
    var main = get_tree().current_scene
    for bank_name in bank_names:
        if main.has_node(bank_name):
            log.append("- Found bank in main scene: " + bank_name)
        elif main.has_member(bank_name):
            log.append("- Found bank as a member variable: " + bank_name)
    
    # Look for nodes with "bank" in the name
    var bank_nodes = []
    find_nodes_with_name_containing("bank", get_tree().root, bank_nodes)
    
    if bank_nodes.size() > 0:
        log.append("- Found " + str(bank_nodes.size()) + " potential bank nodes:")
        for node in bank_nodes:
            log.append("  - " + str(node.get_path()))

func find_main_script():
    log.append("Searching for main.gd script...")
    
    var main = get_tree().current_scene
    var script = main.get_script()
    
    if script:
        log.append("- Main scene has script: " + str(script.resource_path))
        
        # Check if the script follows our expected API
        check_for_expected_api(main)
    else:
        log.append("- Main scene does not have a script")
        
        # Look for nodes with scripts that might be controllers
        var script_nodes = []
        find_nodes_with_scripts(main, script_nodes)
        
        if script_nodes.size() > 0:
            log.append("- Found " + str(script_nodes.size()) + " nodes with scripts:")
            for node in script_nodes:
                log.append("  - " + str(node.get_path()) + " - " + str(node.get_script().resource_path))

func check_for_expected_api(node):
    # Check if this node implements the expected API for our integration
    var api_methods = [
        "add_menu_entry",
        "register_system",
        "add_to_view_area",
        "show_message"
    ]
    
    var implemented_methods = []
    
    for method in api_methods:
        if node.has_method(method):
            implemented_methods.append(method)
    
    if implemented_methods.size() > 0:
        log.append("- Node implements " + str(implemented_methods.size()) + "/" + str(api_methods.size()) + " expected API methods:")
        for method in implemented_methods:
            log.append("  - " + method + "()")
    else:
        log.append("- Node does not implement any expected API methods")

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

# Recursive function to find nodes with a specific string in their name
func find_nodes_with_name_containing(substring, node, results):
    if substring.to_lower() in node.name.to_lower():
        results.append(node)
    
    for child in node.get_children():
        find_nodes_with_name_containing(substring, child, results)

# Recursive function to find nodes with scripts
func find_nodes_with_scripts(node, results):
    if node.get_script():
        results.append(node)
    
    for child in node.get_children():
        find_nodes_with_scripts(child, results)

func print_analysis():
    print("\n===== MENU SYSTEM ANALYSIS REPORT =====")
    for entry in log:
        print(entry)
    print("=======================================\n")
    
    print("INTEGRATION RECOMMENDATIONS:")
    print("1. Based on the analysis above, determine where to initialize the Thing Creator")
    print("2. Find the right node to call register_system() and add_menu_entry()")
    print("3. Locate the JSH console to register commands")
    print("4. Find or create a suitable view area for the UI")