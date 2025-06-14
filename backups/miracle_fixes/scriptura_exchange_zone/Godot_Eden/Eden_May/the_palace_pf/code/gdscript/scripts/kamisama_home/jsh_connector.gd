extends Node
class_name JSHConnector

# This script helps locate and connect to the JSH console
# It's useful when the JSH console node path is unknown or complex

var jsh_console = null
var connected_systems = []

func _ready():
    # Wait a moment for the scene to fully initialize
    await get_tree().create_timer(0.5).timeout
    
    # Find JSH console
    find_jsh_console()
    
    # If found, initialize connected systems
    if jsh_console:
        print("JSH Connector: Found JSH console")
        initialize_connected_systems()
    else:
        print("JSH Connector: JSH console not found")

func find_jsh_console():
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
            print("JSH Connector: Found console at " + path)
            return
    
    # If not found by path, search the scene tree
    jsh_console = find_node_by_class("JSH_console")
    
    if not jsh_console:
        push_warning("JSH Connector: Could not find JSH console node")

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

func register_system(system):
    if not system in connected_systems:
        connected_systems.append(system)
        
        # Initialize immediately if console is already found
        if jsh_console and system.has_method("initialize"):
            system.initialize(jsh_console)
            return true
    
    return false

func initialize_connected_systems():
    if not jsh_console:
        return
    
    for system in connected_systems:
        if system.has_method("initialize"):
            system.initialize(jsh_console)
            print("JSH Connector: Initialized " + system.get_class())