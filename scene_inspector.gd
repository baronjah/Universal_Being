extends Node

# Script to inspect the scene tree and find all nodes
func _ready():
	print("\n🔍 SCENE TREE INSPECTOR")
	print("Analyzing the Universal Being game scene...")
	
	# Wait for scene to fully load
	await get_tree().create_timer(3.0).timeout
	
	print("\n📋 FULL SCENE TREE:")
	_print_tree(get_tree().root, 0)
	
	print("\n🎮 NODES WITH 'CONSOLE' IN NAME:")
	var console_nodes = _find_console_nodes(get_tree().root)
	for node in console_nodes:
		print("  - %s (%s) at %s" % [node.name, node.get_class(), node.get_path()])
		if node.has_method("deploy_consciousness_revolution"):
			print("    ✅ HAS deploy_consciousness_revolution method")
		else:
			print("    ❌ No deploy_consciousness_revolution method")
	
	print("\n🎯 NODES WITH 'UNIVERSAL' IN NAME:")
	var universal_nodes = _find_nodes_with_text(get_tree().root, "universal")
	for node in universal_nodes:
		print("  - %s (%s)" % [node.name, node.get_class()])
	
	print("\n📱 NODES WITH 'UI' IN NAME:")
	var ui_nodes = _find_nodes_with_text(get_tree().root, "ui")
	for node in ui_nodes:
		print("  - %s (%s)" % [node.name, node.get_class()])
	
	print("\n🔍 SCENE INSPECTOR COMPLETE")
	get_tree().quit()

func _print_tree(node: Node, depth: int):
	pass
	var indent = ""
	for i in range(depth):
		indent += "  "
	
	print("%s- %s (%s)" % [indent, node.name, node.get_class()])
	
	# Limit depth to avoid huge output
	if depth < 4:
		for child in node.get_children():
			_print_tree(child, depth + 1)

func _find_console_nodes(node: Node) -> Array:
	pass
	var results = []
	if "console" in node.name.to_lower():
		results.append(node)
	for child in node.get_children():
		results.append_array(_find_console_nodes(child))
	return results

func _find_nodes_with_text(node: Node, search_text: String) -> Array:
	pass
	var results = []
	if search_text.to_lower() in node.name.to_lower():
		results.append(node)
	for child in node.get_children():
		results.append_array(_find_nodes_with_text(child, search_text))
	return results