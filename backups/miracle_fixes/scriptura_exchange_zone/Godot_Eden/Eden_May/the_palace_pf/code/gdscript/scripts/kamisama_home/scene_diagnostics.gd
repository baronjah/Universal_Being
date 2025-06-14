extends Node
class_name SceneDiagnostics

# This script helps diagnose your scene structure to find key nodes
# It can be temporarily added to your scene for debugging

var log = []

func _ready():
    # Wait a moment for the scene to fully initialize
    await get_tree().create_timer(0.5).timeout
    
    print("==== Scene Diagnostics Starting ====")
    
    # Find main components
    find_jsh_console()
    find_akashic_records()
    find_view_area()
    find_menu_system()
    
    # Print the final report
    print_report()
    
    print("==== Scene Diagnostics Complete ====")

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
            log.append("✓ Found JSH console at: " + path)
            return
    
    # Try to find by searching all nodes
    var node = find_node_by_name("JSH_console")
    if node:
        var path = get_path_to(node)
        log.append("✓ Found JSH console by search at: " + str(path))
        return
    
    log.append("✗ Could not find JSH console node")

func find_akashic_records():
    log.append("Searching for AkashicRecordsManager...")
    
    if has_node("/root/AkashicRecordsManager"):
        log.append("✓ Found AkashicRecordsManager at: /root/AkashicRecordsManager")
        return
    
    # Try to find by searching all nodes
    var node = find_node_by_class("AkashicRecordsManager")
    if node:
        var path = get_path_to(node)
        log.append("✓ Found AkashicRecordsManager by search at: " + str(path))
        return
    
    log.append("✗ Could not find AkashicRecordsManager node")

func find_view_area():
    log.append("Searching for view area...")
    
    # Common names for view area
    var possible_names = ["ViewArea", "ContentArea", "UIContent", "MainContent", "ViewPort", "ViewContainer"]
    
    for name in possible_names:
        var node = find_node_by_name(name)
        if node:
            var path = get_path_to(node)
            log.append("✓ Found potential view area: " + name + " at " + str(path))
            return
    
    log.append("✗ Could not find a clear view area node")
    log.append("  Suggestions for view area: Look for Control nodes that contain UI content")

func find_menu_system():
    log.append("Searching for menu system...")
    
    # Check if main has menu methods
    var main = get_tree().current_scene
    var has_menu_methods = false
    
    if main.has_method("add_menu_entry"):
        has_menu_methods = true
        log.append("✓ Found add_menu_entry method in main scene")
    
    if main.has_method("register_system"):
        has_menu_methods = true 
        log.append("✓ Found register_system method in main scene")
    
    if not has_menu_methods:
        log.append("✗ Could not find menu system methods in main scene")
        log.append("  Suggestions: Look for script that handles menu entries")

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
    print("\n===== SCENE DIAGNOSTICS REPORT =====")
    for entry in log:
        print(entry)
    print("===================================\n")
    
    print("INTEGRATION INSTRUCTIONS:")
    print("1. Add the following to your main.gd:")
    print("   _initialize_thing_creator()")
    print("2. Update the JSH console path in _initialize_thing_creator() based on report")
    print("3. Update the view area path in add_to_view_area() based on report")
    print("4. Ensure AkashicRecordsManager is initialized before Thing Creator")