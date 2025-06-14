# ==================================================
# SCRIPT NAME: universal_object_manager.gd
# DESCRIPTION: Single source of truth for ALL objects in the game
# PURPOSE: Perfect unification - every object tracked, registered, inspectable
# CREATED: 2025-05-27 - The perfect system realized
# ==================================================

extends UniversalBeingBase
# Signals for system-wide awareness
signal object_created(uuid: String, data: Dictionary)
signal object_modified(uuid: String, changes: Dictionary)
signal object_destroyed(uuid: String)
signal batch_operation_complete(operation: String, count: int)

# Single source of truth databases
var all_objects: Dictionary = {}      # uuid -> full object data
var objects_by_type: Dictionary = {}  # type -> [uuids]
var objects_by_name: Dictionary = {}  # name -> uuid
var creation_history: Array = []      # Track everything
var uuid_counter: int = 0            # Simple incremental UUID

# Performance tracking
var creation_count: int = 0
var modification_count: int = 0
var destruction_count: int = 0

# System references (populated on ready)
var floodgate: Node = null
var world_builder: Node = null
var asset_library: Node = null
var console_manager: Node = null

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "UniversalObjectManager"
	print("🌟 [UniversalObjectManager] Initializing perfect object tracking system...")
	
	# Get system references
	_connect_to_systems()
	
	# Set process for cleanup
	set_process(true)
	
	print("✅ [UniversalObjectManager] Ready - All objects will be perfect!")

func _log(message: String, level: String = "INFO") -> void:
	"""Simple logging function"""
	print("[%s] [UniversalObjectManager] %s" % [level, message])

func _connect_to_systems() -> void:
	"""Connect to all existing systems"""
	# These will be available as autoloads
	floodgate = get_node_or_null("/root/FloodgateController")
	world_builder = get_node_or_null("/root/WorldBuilder")
	asset_library = get_node_or_null("/root/AssetLibrary")
	console_manager = get_node_or_null("/root/ConsoleManager")

# ========== CREATION SYSTEM ==========


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func create_object(type: String, position: Vector3, properties: Dictionary = {}) -> Node:
	"""Universal object creation - THE ONLY WAY to create objects"""
	
	# Generate unique ID
	var uuid = _generate_uuid()
	
	# Create through StandardizedObjects
	var obj = StandardizedObjects.create_object(type, position, properties)
	if not obj:
		push_error("[UniversalObjectManager] Failed to create object type: " + type)
		return null
	
	# Set universal metadata
	obj.set_meta("uuid", uuid)
	obj.set_meta("created_by", _get_caller_info())
	obj.set_meta("created_at", Time.get_ticks_msec())
	obj.set_meta("universal_tracked", true)
	
	# Create comprehensive data entry
	var data = {
		"uuid": uuid,
		"type": type,
		"name": obj.name,
		"node": obj,
		"position": position,
		"properties": properties,
		"created_at": Time.get_ticks_msec(),
		"created_by": _get_caller_info(),
		"modifications": [],
		"active": true
	}
	
	# Store in all databases
	all_objects[uuid] = data
	
	# Type tracking
	if not objects_by_type.has(type):
		objects_by_type[type] = []
	objects_by_type[type].append(uuid)
	
	# Name tracking
	objects_by_name[obj.name] = uuid
	
	# History tracking
	creation_history.append({
		"uuid": uuid,
		"type": type,
		"time": Time.get_ticks_msec(),
		"caller": _get_caller_info()
	})
	
	# Register with all systems automatically
	_register_with_all_systems(uuid, obj, type, data)
	
	# Update counters
	creation_count += 1
	
	# Emit signal for any additional listeners
	object_created.emit(uuid, data)
	
	# Add to scene tree (if not already parented)
	if not obj.is_inside_tree():
		get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
	
	print("✨ [UniversalObjectManager] Created " + type + " (UUID: " + uuid + ")")
	
	return obj

func _register_with_all_systems(_uuid: String, obj: Node, type: String, _data: Dictionary) -> void:
	"""Register object with all connected systems"""
	
	# Register with Floodgate
	if floodgate and floodgate.has_method("second_dimensional_magic"):
		floodgate.second_dimensional_magic(0, obj.name, obj)
	
	# Register with WorldBuilder
	if world_builder and "spawned_objects" in world_builder:
		world_builder.spawned_objects.append(obj)
	
	# Register with AssetLibrary if applicable
	if asset_library and asset_library.has_method("register_spawned_asset"):
		asset_library.register_spawned_asset(type, obj)
	
	# Make sure it's in the proper groups
	obj.add_to_group("universal_objects")
	obj.add_to_group("spawned_objects")
	obj.add_to_group(type + "s")

# ========== QUERY SYSTEM ==========

func get_object_by_uuid(uuid: String) -> Node:
	"""Get object node by UUID"""
	if all_objects.has(uuid):
		return all_objects[uuid].node
	return null

func get_object_by_name(object_name: String) -> Node:
	"""Get object node by name"""
	if objects_by_name.has(object_name):
		var uuid = objects_by_name[object_name]
		return get_object_by_uuid(uuid)
	return null

func get_object_data(uuid: String) -> Dictionary:
	"""Get full object data"""
	return all_objects.get(uuid, {})

func get_objects_by_type(type: String) -> Array:
	"""Get all objects of a specific type"""
	var result = []
	if objects_by_type.has(type):
		for uuid in objects_by_type[type]:
			if all_objects.has(uuid) and all_objects[uuid].active:
				result.append(all_objects[uuid].node)
	return result

func get_all_objects() -> Array:
	"""Get all active objects"""
	var result = []
	for data in all_objects.values():
		if data.active and is_instance_valid(data.node):
			result.append(data.node)
	return result

func get_object_count() -> int:
	"""Get total active object count"""
	var count = 0
	for data in all_objects.values():
		if data.active and is_instance_valid(data.node):
			count += 1
	return count

# ========== MODIFICATION SYSTEM ==========

func modify_object(uuid: String, changes: Dictionary) -> bool:
	"""Modify object properties"""
	if not all_objects.has(uuid):
		return false
	
	var data = all_objects[uuid]
	var obj = data.node
	
	if not is_instance_valid(obj):
		return false
	
	# Record modification
	var modification = {
		"time": Time.get_ticks_msec(),
		"changes": changes,
		"by": _get_caller_info()
	}
	data.modifications.append(modification)
	
	# Apply changes
	for property in changes:
		if property in obj:
			obj.set(property, changes[property])
	
	# Update counters
	modification_count += 1
	
	# Emit signal
	object_modified.emit(uuid, changes)
	
	return true

# ========== DESTRUCTION SYSTEM ==========

func destroy_object(uuid: String) -> bool:
	"""Properly destroy an object"""
	if not all_objects.has(uuid):
		return false
	
	var data = all_objects[uuid]
	var obj = data.node
	
	# Mark as inactive first
	data.active = false
	
	# Remove from type tracking
	if objects_by_type.has(data.type):
		objects_by_type[data.type].erase(uuid)
	
	# Remove from name tracking
	objects_by_name.erase(data.name)
	
	# Emit signal before destruction
	object_destroyed.emit(uuid)
	
	# Queue the node for deletion
	if is_instance_valid(obj):
		obj.queue_free()
	
	# Update counters
	destruction_count += 1
	
	print("💥 [UniversalObjectManager] Destroyed " + data.type + " (UUID: " + uuid + ")")
	
	return true

func destroy_all_objects() -> void:
	"""Destroy all tracked objects"""
	var count = 0
	for uuid in all_objects.keys():
		if all_objects[uuid].active:
			destroy_object(uuid)
			count += 1
	
	batch_operation_complete.emit("destroy_all", count)

# ========== UTILITY FUNCTIONS ==========

func _generate_uuid() -> String:
	"""Generate a unique ID"""
	uuid_counter += 1
	return "obj_" + str(Time.get_ticks_msec()) + "_" + str(uuid_counter)

func _get_caller_info() -> String:
	"""Get information about who called this function"""
	var stack = get_stack()
	if stack.size() > 2:
		return stack[2].source + ":" + str(stack[2].line)
	return "unknown"

func get_statistics() -> Dictionary:
	"""Get system statistics"""
	return {
		"total_created": creation_count,
		"total_modified": modification_count,
		"total_destroyed": destruction_count,
		"active_objects": get_object_count(),
		"types_tracked": objects_by_type.size(),
		"memory_entries": all_objects.size()
	}

# ========== CLEANUP SYSTEM ==========

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	"""Periodic cleanup of invalid references"""
	# Only run cleanup every 60 frames (1 second at 60fps)
	if Engine.get_process_frames() % 60 != 0:
		return
	
	# Clean up invalid objects
	var cleaned = 0
	for uuid in all_objects.keys():
		var data = all_objects[uuid]
		if data.active and not is_instance_valid(data.node):
			data.active = false
			cleaned += 1
	
	if cleaned > 0:
		print("🧹 [UniversalObjectManager] Cleaned up " + str(cleaned) + " invalid references")

# ========== CONSOLE COMMANDS ==========

func register_console_commands() -> void:
	"""Register universal commands with console"""
	if not console_manager:
		return
	
	var commands = console_manager.get("commands")
	if commands:
		commands["uom_stats"] = _cmd_statistics
		commands["uom_list"] = _cmd_list_all
		commands["uom_inspect"] = _cmd_inspect
		commands["uom_clear"] = _cmd_clear_all

func _cmd_statistics(_args: Array) -> String:
	"""Show UOM statistics"""
	var stats = get_statistics()
	return "=== Universal Object Manager Stats ===\n" + \
		"Created: " + str(stats.total_created) + "\n" + \
		"Modified: " + str(stats.total_modified) + "\n" + \
		"Destroyed: " + str(stats.total_destroyed) + "\n" + \
		"Active: " + str(stats.active_objects) + "\n" + \
		"Types: " + str(stats.types_tracked)

func _cmd_list_all(_args: Array) -> String:
	"""List all objects"""
	var result = "=== All Tracked Objects ===\n"
	for type in objects_by_type:
		var objects = get_objects_by_type(type)
		if objects.size() > 0:
			result += "\n" + type.to_upper() + "S (" + str(objects.size()) + "):\n"
			for obj in objects:
				result += "  - " + obj.name + " at " + str(obj.position) + "\n"
	return result

func _cmd_inspect(args: Array) -> String:
	"""Inspect specific object"""
	if args.is_empty():
		return "Usage: uom_inspect <name|uuid>"
	
	var target = args[0]
	var data = {}
	
	# Try by name first, then UUID
	if objects_by_name.has(target):
		data = get_object_data(objects_by_name[target])
	else:
		data = get_object_data(target)
	
	if data.is_empty():
		return "Object not found: " + target
	
	return "=== Object Inspection ===\n" + \
		"UUID: " + data.uuid + "\n" + \
		"Type: " + data.type + "\n" + \
		"Name: " + data.name + "\n" + \
		"Position: " + str(data.position) + "\n" + \
		"Created: " + str(data.created_at) + "\n" + \
		"By: " + data.created_by + "\n" + \
		"Modifications: " + str(data.modifications.size())

func _cmd_clear_all(_args: Array) -> String:
	"""Clear all objects"""
	var count = get_object_count()
	destroy_all_objects()
	return "Cleared " + str(count) + " objects"