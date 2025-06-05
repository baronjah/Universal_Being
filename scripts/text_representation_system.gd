# ==================================================
# UNIVERSAL TEXT REPRESENTATION SYSTEM
# PURPOSE: Convert 3D Universal Beings to 1D text for AI companions
# ==================================================

extends Node
class_name TextRepresentationSystem

# Text formatting constants
const HEADER_CHAR = "="
const SECTION_CHAR = "-"
const INDENT = "  "

# Generate text representation for any Universal Being
static func generate_text_for_being(being: UniversalBeing) -> String:
	if not being:
		return "[NULL BEING]"
	
	var text = ""
	
	# Basic being info
	text += "[%s:%s]" % [being.being_type.to_upper(), being.being_name]
	text += " POS:(%.1f,%.1f,%.1f)" % [being.global_position.x, being.global_position.y, being.global_position.z]
	text += " CONSCIOUSNESS:%d" % being.consciousness_level
	
	# Add being-specific info
	if being.has_method("get_text_details"):
		text += " " + being.get_text_details()
	
	return text

# Generate a scene graph in text format
static func generate_scene_text(root_node: Node) -> String:
	var text = "=== SCENE GRAPH ===\n"
	text += _recursive_node_text(root_node, 0)
	text += "==================\n"
	return text

static func _recursive_node_text(node: Node, depth: int) -> String:
	var indent = ""
	for i in depth:
		indent += INDENT
	
	var text = indent
	
	# Node type and name
	text += "[%s] %s" % [node.get_class(), node.name]
	
	# Position if it's a 3D node
	if node is Node3D:
		var pos = node.position
		text += " @ (%.1f, %.1f, %.1f)" % [pos.x, pos.y, pos.z]
	
	# Universal Being info
	if node is UniversalBeing:
		text += " {UB: %s, CL:%d}" % [node.being_type, node.consciousness_level]
	
	text += "\n"
	
	# Recurse children
	for child in node.get_children():
		text += _recursive_node_text(child, depth + 1)
	
	return text

# Generate connection graph in text
static func generate_connection_text(beings: Array[UniversalBeing]) -> String:
	var text = "=== CONNECTIONS ===\n"
	
	for being in beings:
		if being.has_method("get_socket_info"):
			var info = being.get_socket_info()
			text += "%s:\n" % being.being_name
			text += "  IN: %d connections\n" % info.get("input_connections", 0)
			text += "  OUT: %d connections\n" % info.get("output_connections", 0)
	
	text += "==================\n"
	return text

# Convert visual state to ASCII art
static func generate_ascii_representation(being: UniversalBeing) -> String:
	var ascii = ""
	
	match being.being_type:
		"button_3d", "socket_button":
			if being.get("output_value", false):
				ascii = "[=ON=]"
			else:
				ascii = "[OFF ]"
		
		"interface_window":
			ascii = """
╔════════════╗
║ %s ║
╟────────────╢
║            ║
║   WINDOW   ║
║            ║
╚════════════╝""" % being.being_name.substr(0, 10).pad_zeros(10)
		
		"cursor":
			ascii = "  ↖\n   ●\n"
		
		"player":
			ascii = " ☺\n/|\\n/ \\"
		
		_:
			ascii = "[%s]" % being.being_type
	
	return ascii

# Create a live text feed for AI companions
static func create_text_feed(scene: Node) -> String:
	var feed = "=== UNIVERSAL BEING TEXT FEED ===\n"
	feed += "Time: %s\n" % Time.get_time_string_from_system()
	feed += "\n"
	
	# Find all Universal Beings
	var beings = []
	_find_all_beings(scene, beings)
	
	feed += "Active Beings: %d\n" % beings.size()
	feed += "\n"
	
	# List each being's state
	for being in beings:
		feed += generate_text_for_being(being) + "\n"
	
	# Add connections
	feed += "\n"
	feed += generate_connection_text(beings)
	
	return feed

static func _find_all_beings(node: Node, beings: Array) -> void:
	if node is UniversalBeing:
		beings.append(node)
	
	for child in node.get_children():
		_find_all_beings(child, beings)

# Generate command-line style representation
static func generate_cli_representation(being: UniversalBeing) -> String:
	var cli = "$ ub status %s\n" % being.being_name
	cli += "Type: %s\n" % being.being_type
	cli += "UUID: %s\n" % being.get_instance_id()
	cli += "Consciousness: %d/5\n" % being.consciousness_level
	cli += "Position: %.2f, %.2f, %.2f\n" % [being.global_position.x, being.global_position.y, being.global_position.z]
	
	if being.has_method("get_socket_info"):
		var info = being.get_socket_info()
		cli += "Sockets: %d IN, %d OUT\n" % [info.get("input_connections", 0), info.get("output_connections", 0)]
	
	return cli