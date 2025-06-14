# ==================================================
# SCRIPT NAME: unified_creation_system.gd
# DESCRIPTION: The ONE system that unifies all creation methods
# PURPOSE: Everything creates through here - console, UI, code
# CREATED: 2025-05-28 - The Great Unification
# ==================================================

extends UniversalBeingBase
class_name UnifiedCreationSystem

# The single source of truth for all object creation
signal object_created(object: Node3D, type: String)
signal object_destroyed(object: Node3D)
signal creation_failed(reason: String)

# Creation sources tracking
enum CreationSource {
	CONSOLE,        # Console commands
	GAME_RULES,     # Automatic spawning from rules
	UI_INTERFACE,   # Grid/inspector creation
	CODE_DIRECT,    # Direct code calls
	SCENE_LOAD      # Scene file loading
}

# Unified object registry
var all_objects: Dictionary = {}  # UUID -> Object
var object_counts: Dictionary = {} # Type -> Count
var creation_history: Array = []

# System references
var floodgate: FloodgateController
var asset_library: Node
var universal_object_manager: Node
var standard_objects = StandardizedObjects

# Performance control
var creation_budget_ms: float = 2.0  # Max time per frame for creations
var pending_creations: Array = []

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "UnifiedCreationSystem"
	
	# Get system references
	floodgate = get_node("/root/FloodgateController")
	asset_library = get_node("/root/AssetLibrary")
	universal_object_manager = get_node("/root/UniversalObjectManager")
	
	print("🌟 [UnifiedCreation] System initialized - ONE creation system to rule them all")


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
func create(what: String, where: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> Node3D:
	"""The ONE function to create anything"""
	
	# Record creation request
	var request = {
		"type": what,
		"position": where,
		"properties": properties,
		"source": properties.get("source", CreationSource.CODE_DIRECT),
		"timestamp": Time.get_ticks_msec()
	}
	creation_history.append(request)
	
	# Route to appropriate creation method
	var created_object: Node3D = null
	
	# Check if it's a Universal Being type
	if _is_universal_being_type(what):
		created_object = _create_universal_being(what, where, properties)
	
	# Check if it's a standard object
	elif standard_objects.object_definitions.has(what):
		created_object = _create_standard_object(what, where, properties)
	
	# Check if it's a scene file
	elif what.ends_with(".tscn"):
		created_object = _create_from_scene(what, where, properties)
	
	# Unknown type - try Universal Being anyway
	else:
		print("[UnifiedCreation] Unknown type '" + what + "' - attempting Universal Being")
		created_object = _create_universal_being(what, where, properties)
	
	# Post-creation processing
	if created_object:
		_register_object(created_object, what)
		_apply_properties(created_object, properties)
		_route_through_floodgate(created_object)
		object_created.emit(created_object, what)
		return created_object
	else:
		var reason = "Failed to create: " + what
		creation_failed.emit(reason)
		push_error(reason)
		return null

func _is_universal_being_type(type: String) -> bool:
	"""Check if this should be a Universal Being"""
	# Types that are always Universal Beings
	var ub_types = ["universal_being", "being", "entity", "interface"]
	if type in ub_types:
		return true
	
	# Check if we have a TXT definition
	var definition_path = "res://assets/definitions/"
	var paths_to_check = [
		definition_path + "objects/" + type + ".txt",
		definition_path + "interfaces/" + type + ".txt",
		definition_path + "creatures/" + type + ".txt"
	]
	
	for path in paths_to_check:
		if FileAccess.file_exists(path):
			return true
	
	return false

func _create_universal_being(type: String, position: Vector3, _properties: Dictionary) -> Node3D:
	"""Create through Universal Being system"""
	var being = asset_library.load_universal_being(type)
	if being:
		being.position = position
		being.name = _generate_unique_name(type)
		return being
	return null

func _create_standard_object(type: String, position: Vector3, properties: Dictionary) -> Node3D:
	"""Create through StandardizedObjects system"""
	var obj = standard_objects.create_object(type, position, properties)
	if obj:
		obj.name = _generate_unique_name(type)
		return obj
	return null

func _create_from_scene(scene_path: String, position: Vector3, _properties: Dictionary) -> Node3D:
	"""Create from TSCN file"""
	var scene = load(scene_path)
	if scene:
		var instance = scene.instantiate()
		instance.position = position
		instance.name = _generate_unique_name(scene_path.get_file().get_basename())
		return instance
	return null

func _register_object(obj: Node3D, type: String) -> void:
	"""Register object in unified registry"""
	var uuid = "obj_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 1000)
	obj.set_meta("uuid", uuid)
	obj.set_meta("object_type", type)
	obj.set_meta("creation_time", Time.get_ticks_msec())
	
	all_objects[uuid] = obj
	object_counts[type] = object_counts.get(type, 0) + 1
	
	# Add to tracking groups
	obj.add_to_group("all_objects")
	obj.add_to_group(type + "s")

func _apply_properties(obj: Node3D, properties: Dictionary) -> void:
	"""Apply any custom properties"""
	for key in properties:
		if key == "source":
			continue
		
		# Try different methods to set property
		if obj.has_method("set_property"):
			obj.call("set_property", key, properties[key])
		elif obj.has_method("set"):
			obj.set(key, properties[key])
		else:
			obj.set_meta(key, properties[key])

func _route_through_floodgate(obj: Node3D) -> void:
	"""Send through floodgate for proper addition"""
	if floodgate:
		floodgate.second_dimensional_magic(0, obj.name, obj)
	else:
		# Fallback
		get_tree().FloodgateController.universal_add_child(obj, current_scene)

func _generate_unique_name(base_type: String) -> String:
	"""Generate unique name for object"""
	var count = object_counts.get(base_type, 0) + 1
	return base_type.capitalize() + "_" + str(count)

func destroy(obj: Node3D) -> void:
	"""Unified object destruction"""
	if not is_instance_valid(obj):
		return
	
	var uuid = obj.get_meta("uuid", "")
	if uuid in all_objects:
		all_objects.erase(uuid)
	
	var type = obj.get_meta("object_type", "unknown")
	object_counts[type] = max(0, object_counts.get(type, 1) - 1)
	
	object_destroyed.emit(obj)
	obj.queue_free()

func get_all_of_type(type: String) -> Array:
	"""Get all objects of a specific type"""
	var result = []
	for uuid in all_objects:
		var obj = all_objects[uuid]
		if is_instance_valid(obj) and obj.get_meta("object_type", "") == type:
			result.append(obj)
	return result

func get_statistics() -> Dictionary:
	"""Get creation statistics"""
	return {
		"total_objects": all_objects.size(),
		"object_counts": object_counts,
		"creation_history_size": creation_history.size(),
		"valid_objects": all_objects.values().filter(is_instance_valid).size()
	}