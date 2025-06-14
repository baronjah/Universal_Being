extends Node
class_name SceneDumper

# This script dumps the entire scene hierarchy to help
# understand the structure of complex scenes

func _ready():
    # Wait a moment for the scene to fully initialize
    await get_tree().create_timer(0.5).timeout
    
    print("==== Scene Dumper Starting ====")
    
    # Dump the entire scene
    dump_scene()
    
    print("==== Scene Dumper Complete ====")

func dump_scene():
    print("Scene Hierarchy:")
    print_node_hierarchy(get_tree().root, 0)
    
    # Additionally, find key nodes for integration
    print("\nKey Nodes for Integration:")
    
    # Find main script
    var main = get_tree().current_scene
    if main.get_script():
        print("- Main scene script: " + str(main.get_script().resource_path))
    
    # Find JSH console
    var jsh = find_node_by_name("JSH_console")
    if jsh:
        print("- JSH console: " + str(jsh.get_path()))
    
    # Find view area
    var view_area = find_view_area()
    if view_area:
        print("- View area: " + str(view_area.get_path()))
    
    # Find menu nodes
    var menu_nodes = []
    find_menu_nodes(menu_nodes)
    if menu_nodes.size() > 0:
        print("- Menu nodes:")
        for node in menu_nodes:
            print("  - " + str(node.get_path()))

func print_node_hierarchy(node, indent_level):
    var indent = ""
    for i in range(indent_level):
        indent += "  "
    
    # Print node name and class
    var node_info = indent + "- " + node.name + " (" + node.get_class() + ")"
    
    # Add script info if it has a script
    if node.get_script():
        node_info += " [Script: " + str(node.get_script().resource_path) + "]"
    
    print(node_info)
    
    # Print children
    for child in node.get_children():
        print_node_hierarchy(child, indent_level + 1)

# Find all potential menu nodes
func find_menu_nodes(results):
    var menu_keywords = ["menu", "console", "command", "hud", "ui", "interface"]
    
    find_nodes_by_keywords(menu_keywords, get_tree().root, results)

# Find a potential view area
func find_view_area():
    var view_keywords = ["view", "content", "container", "panel", "display"]
    var potential_view_areas = []
    
    find_nodes_by_keywords(view_keywords, get_tree().root, potential_view_areas)
    
    # Filter to only Control nodes that could host UI
    var control_nodes = []
    for node in potential_view_areas:
        if node is Control:
            control_nodes.append(node)
    
    if control_nodes.size() > 0:
        # Sort by potential suitability (prefer larger containers)
        control_nodes.sort_custom(Callable(self, "_sort_by_size"))
        return control_nodes[0]
    
    return null

# Sort nodes by size (larger nodes first)
func _sort_by_size(a, b):
    var a_size = a.size.x * a.size.y if a.has_method("get_size") else 0
    var b_size = b.size.x * b.size.y if b.has_method("get_size") else 0
    return a_size > b_size

# Find nodes with keywords in their name
func find_nodes_by_keywords(keywords, node, results):
    var node_name_lower = node.name.to_lower()
    
    for keyword in keywords:
        if keyword in node_name_lower:
            results.append(node)
            break
    
    for child in node.get_children():
        find_nodes_by_keywords(keywords, child, results)

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