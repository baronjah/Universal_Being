# 🏛️ Debug Scene Inspector - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
## Debug Scene Inspector
## Attach to any node to get detailed scene information

@export var auto_inspect: bool = true
@export var inspect_depth: int = 3

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	if auto_inspect:
		inspect_scene()


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func inspect_scene() -> void:
	print("\n=== SCENE INSPECTION ===")
	print("Scene Tree Structure:")
	_print_tree(get_tree().root, 0, inspect_depth)
	
	print("\n=== AUTOLOAD NODES ===")
	for child in get_tree().root.get_children():
		if child.name != "Window":
			print("  • %s (%s)" % [child.name, child.get_class()])

func _print_tree(node: Node, indent: int, max_depth: int) -> void:
	if indent > max_depth:
		return
		
	var indent_str = "  ".repeat(indent)
	var info = "%s%s" % [indent_str, node.name]
	
	# Add extra info for specific node types
	if node is RigidBody3D:
		info += " [RigidBody3D - Mass: %.2f]" % node.mass
	elif node is CollisionShape3D:
		info += " [CollisionShape3D]"
	elif node is MeshInstance3D:
		info += " [MeshInstance3D]"
	elif node is Control:
		info += " [UI Control - Visible: %s]" % node.visible
		
	print(info)
	
	for child in node.get_children():
		_print_tree(child, indent + 1, max_depth)

func get_node_info(path: String) -> void:
	var node = get_node_or_null(path)
	if not node:
		print("Node not found: %s" % path)
		return
		
	print("\n=== NODE INFO: %s ===" % path)
	print("  Class: %s" % node.get_class())
	print("  Script: %s" % (node.get_script().resource_path if node.get_script() else "None"))
	print("  Groups: %s" % node.get_groups())
	
	# Print properties
	if node is Node3D:
		print("  Position: %s" % node.position)
		print("  Rotation: %s" % node.rotation_degrees)
		print("  Scale: %s" % node.scale)
		print("  Visible: %s" % node.visible)