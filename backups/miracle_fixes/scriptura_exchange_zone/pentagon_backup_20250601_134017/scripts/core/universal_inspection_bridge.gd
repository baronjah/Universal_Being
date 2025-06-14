# ==================================================
# SCRIPT NAME: universal_inspection_bridge.gd
# DESCRIPTION: Ensures ALL objects are inspectable through console
# PURPOSE: Bridge floodgates, console, and inspector for perfect harmony
# CREATED: 2025-05-28 - Neural network awakening day
# ==================================================

extends UniversalBeingBase
signal object_made_inspectable(object: Node, source: String)
signal inspection_bridge_ready()

# Connected systems
var console_manager: Node = null
var object_inspector: Node = null
var floodgate_controller: Node = null
var universal_object_manager: Node = null

# Object tracking
var inspectable_objects: Dictionary = {}
var creation_sources: Dictionary = {}

func _ready() -> void:
	name = "UniversalInspectionBridge"
	print("🔗 [InspectionBridge] Connecting all object creation to console...")
	
	# Wait for other systems to initialize
	call_deferred("_connect_to_systems")

func _connect_to_systems() -> void:
	"""Connect to all object creation systems"""
	
	# Find all the systems
	console_manager = get_node_or_null("/root/ConsoleManager")
	floodgate_controller = get_node_or_null("/root/FloodgateController")
	universal_object_manager = get_node_or_null("/root/UniversalObjectManager")
	
	# Find inspector in scene
	await get_tree().process_frame
	object_inspector = _find_inspector_in_scene()
	
	if console_manager:
		print("✅ [InspectionBridge] Console manager connected")
		_register_bridge_commands()
	
	if floodgate_controller:
		print("✅ [InspectionBridge] Floodgate controller connected")
		_connect_floodgate_signals()
	
	if universal_object_manager:
		print("✅ [InspectionBridge] Universal object manager connected")
		_connect_universal_signals()
	
	# Monitor scene tree for ANY new objects
	_setup_scene_tree_monitoring()
	
	print("🌟 [InspectionBridge] All systems connected - everything is now inspectable!")
	inspection_bridge_ready.emit()

func _find_inspector_in_scene() -> Node:
	"""Find the object inspector in the scene tree"""
	var inspector = get_tree().get_first_node_in_group("object_inspector")
	if not inspector:
		# Search by name
		inspector = get_tree().get_nodes_in_group("*").filter(
			func(node): return "inspector" in node.name.to_lower()
		)
		if inspector.size() > 0:
			inspector = inspector[0]
		else:
			inspector = null
	
	if inspector:
		print("✅ [InspectionBridge] Object inspector found: " + inspector.name)
	else:
		print("⚠️ [InspectionBridge] Object inspector not found - will search again later")
	
	return inspector

func _setup_scene_tree_monitoring() -> void:
	"""Monitor scene tree for ANY new node creation"""
	var tree = get_tree()
	if tree:
		# Connect to node added signal to catch EVERYTHING
		if not tree.node_added.is_connected(_on_any_node_added):
			tree.node_added.connect(_on_any_node_added)
		print("🔍 [InspectionBridge] Scene tree monitoring active")

func _on_any_node_added(node: Node) -> void:
	"""Called whenever ANY node is added to the scene tree"""
	if node and is_instance_valid(node):
		# Skip UI nodes and system nodes
		if _should_make_inspectable(node):
			_make_object_inspectable(node, "scene_tree")

func _should_make_inspectable(node: Node) -> bool:
	"""Determine if this node should be made inspectable"""
	
	# Skip UI nodes
	if node is Control or node is CanvasLayer:
		return false
	
	# Skip system nodes
	var node_name = node.name.to_lower()
	if any_keyword_in_string(node_name, ["console", "ui", "system", "manager", "autoload"]):
		return false
	
	# Include 3D objects, physics objects, and game entities
	if node is Node3D or node is RigidBody3D or node is CharacterBody3D:
		return true
	
	# Include nodes with specific names indicating game objects
	if any_keyword_in_string(node_name, ["box", "tree", "ragdoll", "walker", "being", "object"]):
		return true
	
	return false


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
func any_keyword_in_string(text: String, keywords: Array) -> bool:
	"""Check if any keyword appears in the text"""
	for keyword in keywords:
		if keyword in text:
			return true
	return false

func _make_object_inspectable(object: Node, source: String = "unknown") -> void:
	"""Make any object inspectable through the console"""
	if not object or not is_instance_valid(object):
		return
	
	var object_id = str(object.get_instance_id())
	
	# Skip if already registered
	if object_id in inspectable_objects:
		return
	
	# Register the object
	inspectable_objects[object_id] = {
		"node": object,
		"name": object.name,
		"type": object.get_class(),
		"source": source,
		"position": _get_object_position(object),
		"created_at": Time.get_ticks_msec()
	}
	creation_sources[object_id] = source
	
	print("🔍 [InspectionBridge] Made inspectable: %s (%s) from %s" % [object.name, object.get_class(), source])
	
	# Add to object inspector if available
	if object_inspector and object_inspector.has_method("add_tracked_object"):
		object_inspector.add_tracked_object(object)
	
	object_made_inspectable.emit(object, source)

func _get_object_position(object: Node) -> Vector3:
	"""Get position of any object type"""
	if object is Node3D:
		return object.global_position
	elif object is Node2D:
		return Vector3(object.global_position.x, object.global_position.y, 0)
	else:
		return Vector3.ZERO

func _connect_floodgate_signals() -> void:
	"""Connect to floodgate controller signals"""
	# Connect to any object creation signals from floodgates
	if floodgate_controller.has_signal("object_created"):
		floodgate_controller.object_created.connect(_on_floodgate_object_created)

func _connect_universal_signals() -> void:
	"""Connect to universal object manager signals"""
	if universal_object_manager.has_signal("object_spawned"):
		universal_object_manager.object_spawned.connect(_on_universal_object_spawned)

func _on_floodgate_object_created(object: Node) -> void:
	"""Handle objects created through floodgates"""
	_make_object_inspectable(object, "floodgate")

func _on_universal_object_spawned(object: Node) -> void:
	"""Handle objects created through universal manager"""
	_make_object_inspectable(object, "universal")

func _register_bridge_commands() -> void:
	"""Register console commands for the inspection bridge"""
	if console_manager and console_manager.has_method("register_command"):
		console_manager.register_command("list_inspectable", _cmd_list_inspectable,
			"List all inspectable objects")
		console_manager.register_command("inspect_by_name", _cmd_inspect_by_name,
			"Inspect object by name: inspect_by_name <name>")
		console_manager.register_command("bridge_status", _cmd_bridge_status,
			"Show inspection bridge status")

func _cmd_list_inspectable(_args: Array) -> void:
	"""Console command: List all inspectable objects"""
	if not console_manager:
		return
	
	console_manager._print_to_console("Inspectable Objects:")
	console_manager._print_to_console("==============================")
	
	var count_by_source = {}
	for obj_id in inspectable_objects:
		var obj_data = inspectable_objects[obj_id]
		var node = obj_data.node
		
		if not is_instance_valid(node):
			continue
		
		var source = obj_data.source
		if not source in count_by_source:
			count_by_source[source] = 0
		count_by_source[source] += 1
		
		var pos = obj_data.position
		console_manager._print_to_console("- %s (%s) at (%.1f, %.1f, %.1f) [%s]" % [
			node.name, obj_data.type, pos.x, pos.y, pos.z, source
		])
	
	console_manager._print_to_console("==============================")
	console_manager._print_to_console("Summary by source:")
	for source in count_by_source:
		console_manager._print_to_console("  %s: %d objects" % [source, count_by_source[source]])

func _cmd_inspect_by_name(args: Array) -> void:
	"""Console command: Inspect object by name"""
	if not console_manager:
		return
	
	if args.size() == 0:
		console_manager._print_to_console("Usage: inspect_by_name <object_name>")
		return
	
	var target_name = args[0]
	var found_object = null
	
	for obj_id in inspectable_objects:
		var obj_data = inspectable_objects[obj_id]
		var node = obj_data.node
		
		if is_instance_valid(node) and node.name == target_name:
			found_object = node
			break
	
	if found_object:
		if object_inspector and object_inspector.has_method("inspect_object"):
			object_inspector.inspect_object(found_object)
			console_manager._print_to_console("Inspecting: " + found_object.name)
		else:
			# Try to find enhanced inspector
			var enhanced_inspector = get_node_or_null("/root/EnhancedObjectInspector")
			if enhanced_inspector and enhanced_inspector.has_method("inspect_object"):
				enhanced_inspector.inspect_object(found_object)
				console_manager._print_to_console("Inspecting with Enhanced Inspector: " + found_object.name)
			else:
				console_manager._print_to_console("Object inspector not available - looking for inspector...")
				# List available inspectors for debugging
				_find_and_list_inspectors()
	else:
		console_manager._print_to_console("Object not found: " + target_name)

func _cmd_bridge_status(_args: Array) -> void:
	"""Console command: Show bridge status"""
	if not console_manager:
		return
	
	console_manager._print_to_console("Universal Inspection Bridge Status:")
	console_manager._print_to_console("===================================")
	console_manager._print_to_console("Console Manager: " + ("OK" if console_manager else "MISSING"))
	console_manager._print_to_console("Object Inspector: " + ("OK" if object_inspector else "MISSING"))
	console_manager._print_to_console("Floodgate Controller: " + ("OK" if floodgate_controller else "MISSING"))
	console_manager._print_to_console("Universal Object Manager: " + ("OK" if universal_object_manager else "MISSING"))
	console_manager._print_to_console("===================================")
	console_manager._print_to_console("Tracked Objects: " + str(inspectable_objects.size()))
	console_manager._print_to_console("Scene Tree Monitoring: ACTIVE")

func _find_and_list_inspectors() -> void:
	"""Find all available inspectors and list them"""
	if not console_manager:
		return
	
	console_manager._print_to_console("🔍 Searching for available inspectors...")
	
	var inspector_nodes = []
	
	# Check common paths
	var common_paths = [
		"/root/EnhancedObjectInspector",
		"/root/UniversalObjectInspector", 
		"/root/AdvancedObjectInspector"
	]
	
	for path in common_paths:
		var node = get_node_or_null(path)
		if node:
			inspector_nodes.append(node)
			console_manager._print_to_console("  ✅ Found: " + path + " (" + node.get_class() + ")")
	
	# Search by group
	var group_inspectors = get_tree().get_nodes_in_group("object_inspector")
	for inspector in group_inspectors:
		if not inspector in inspector_nodes:
			inspector_nodes.append(inspector)
			console_manager._print_to_console("  ✅ Found in group: " + str(inspector.get_path()) + " (" + inspector.get_class() + ")")
	
	# Search by name containing "inspector"
	var all_nodes = get_tree().get_nodes_in_group("*")
	for node in all_nodes:
		if "inspector" in node.name.to_lower() and not node in inspector_nodes:
			inspector_nodes.append(node)
			console_manager._print_to_console("  ✅ Found by name: " + str(node.get_path()) + " (" + node.get_class() + ")")
	
	if inspector_nodes.is_empty():
		console_manager._print_to_console("  ❌ No inspectors found!")
		console_manager._print_to_console("  ℹ️  Try using mouse click to inspect objects directly")
	else:
		console_manager._print_to_console("  📊 Total inspectors found: " + str(inspector_nodes.size()))
		
		# Try to use the first available one
		if object_inspector == null and inspector_nodes.size() > 0:
			object_inspector = inspector_nodes[0]
			console_manager._print_to_console("  🔧 Set active inspector to: " + object_inspector.name)