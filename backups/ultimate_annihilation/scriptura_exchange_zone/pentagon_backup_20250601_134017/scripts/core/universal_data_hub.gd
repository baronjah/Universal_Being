# ==================================================
# SCRIPT NAME: universal_data_hub.gd
# DESCRIPTION: Central brain for all data - the ONE source of truth
# PURPOSE: Every script asks this hub for data instead of searching
# CREATED: 2025-05-27
# ==================================================

extends UniversalBeingBase
signal system_registered(name: String, system: Node)
signal object_registered(uuid: String, object: Node)
signal data_requested(requester: String, data_type: String)

# ========== CENTRAL REGISTRIES ==========
var all_objects: Dictionary = {}          # UUID -> Node
var all_beings: Dictionary = {}           # UUID -> UniversalBeing
var all_systems: Dictionary = {}          # System name -> Node reference
var all_rules: Dictionary = {}            # Rule name -> Callable
var object_types: Dictionary = {}         # Type -> Array of UUIDs
var active_scenes: Dictionary = {}        # Scene name -> PackedScene
var global_variables: Dictionary = {}     # Var name -> value

# ========== CENTRAL LIMITS ==========
const MAX_NODES: int = 22000
const MAX_MEMORY_MB: float = 4096.0
const TARGET_FPS: float = 60.0
const MAX_BEINGS: int = 1000
const SYSTEM_VERSION: String = "1.0.0"

# ========== PERFORMANCE TRACKING ==========
var performance_stats = {
	"total_objects": 0,
	"total_beings": 0,
	"total_systems": 0,
	"requests_per_second": 0,
	"last_cleanup": 0
}

var request_counter: int = 0
var request_timer: float = 0.0

func _ready() -> void:
	name = "UniversalDataHub"
	print("🧠 [DataHub] Universal Data Hub initialized - The ONE source of truth")
	
	# Register self first
	all_systems["DataHub"] = self
	
	# Start performance monitoring
	set_process(true)

func _process(delta: float) -> void:
	request_timer += delta
	if request_timer >= 1.0:
		performance_stats.requests_per_second = request_counter
		request_counter = 0
		request_timer = 0.0

# ========== SYSTEM REGISTRATION ==========


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
func register_system(system_name: String, system: Node) -> bool:
	"""Register a system for central tracking"""
	if system_name in all_systems:
		push_warning("[DataHub] System already registered: " + system_name)
		return false
	
	all_systems[system_name] = system
	performance_stats.total_systems += 1
	system_registered.emit(system_name, system)
	print("[DataHub] System registered: " + system_name)
	return true

func get_system(system_name: String) -> Node:
	"""Get a registered system by name"""
	request_counter += 1
	data_requested.emit("get_system", "system:" + system_name)
	return all_systems.get(system_name)

# ========== OBJECT MANAGEMENT ==========

func register_object(obj: Node, type: String = "generic") -> String:
	"""Register any object and return its UUID"""
	var uuid = _generate_uuid()
	
	# Store in main registry
	all_objects[uuid] = obj
	obj.set_meta("uuid", uuid)
	obj.set_meta("type", type)
	
	# Store by type
	if not type in object_types:
		object_types[type] = []
	object_types[type].append(uuid)
	
	# Special handling for beings
	if obj.has_method("become"):  # It's a Universal Being!
		all_beings[uuid] = obj
		performance_stats.total_beings += 1
	
	performance_stats.total_objects += 1
	object_registered.emit(uuid, obj)
	return uuid

func get_object(uuid: String) -> Node:
	"""Get object by UUID"""
	request_counter += 1
	data_requested.emit("get_object", "object:" + uuid)
	return all_objects.get(uuid)

func get_objects_by_type(type: String) -> Array:
	"""Get all objects of a specific type"""
	request_counter += 1
	var result = []
	
	if type in object_types:
		for uuid in object_types[type]:
			var obj = all_objects.get(uuid)
			if is_instance_valid(obj):
				result.append(obj)
	
	return result

func unregister_object(uuid: String) -> void:
	"""Remove object from all registries"""
	if uuid in all_objects:
		var obj = all_objects[uuid]
		var type = obj.get_meta("type", "generic")
		
		# Remove from type registry
		if type in object_types:
			object_types[type].erase(uuid)
		
		# Remove from beings if applicable
		if uuid in all_beings:
			all_beings.erase(uuid)
			performance_stats.total_beings -= 1
		
		# Remove from main registry
		all_objects.erase(uuid)
		performance_stats.total_objects -= 1

# ========== UNIVERSAL BEING MANAGEMENT ==========

func get_all_beings() -> Array:
	"""Get all Universal Beings"""
	request_counter += 1
	var result = []
	for uuid in all_beings:
		var being = all_beings[uuid]
		if is_instance_valid(being):
			result.append(being)
	return result

func get_beings_by_form(form: String) -> Array:
	"""Get beings in a specific form"""
	request_counter += 1
	var result = []
	for being in get_all_beings():
		if being.get("form") == form:
			result.append(being)
	return result

# ========== RULE MANAGEMENT ==========

func register_rule(rule_name: String, callable: Callable) -> void:
	"""Register a rule/behavior"""
	all_rules[rule_name] = callable
	print("[DataHub] Rule registered: " + rule_name)

func execute_rule(rule_name: String, params: Array = []) -> Variant:
	"""Execute a registered rule"""
	if rule_name in all_rules:
		return all_rules[rule_name].callv(params)
	else:
		push_error("[DataHub] Unknown rule: " + rule_name)
		return null

# ========== GLOBAL VARIABLES ==========

func set_global(var_name: String, value: Variant) -> void:
	"""Set a global variable"""
	global_variables[var_name] = value

func get_global(var_name: String, default: Variant = null) -> Variant:
	"""Get a global variable"""
	request_counter += 1
	data_requested.emit("get_global", "global:" + var_name)
	return global_variables.get(var_name, default)

# ========== PERFORMANCE & LIMITS ==========

func check_limits() -> Dictionary:
	"""Check if we're within limits"""
	return {
		"nodes_ok": performance_stats.total_objects < MAX_NODES,
		"memory_ok": _estimate_memory() < MAX_MEMORY_MB,
		"beings_ok": performance_stats.total_beings < MAX_BEINGS,
		"fps_ok": Engine.get_frames_per_second() > TARGET_FPS
	}

func cleanup_invalid() -> int:
	"""Remove invalid references"""
	var cleaned = 0
	
	# Clean objects
	var invalid_uuids = []
	for uuid in all_objects:
		if not is_instance_valid(all_objects[uuid]):
			invalid_uuids.append(uuid)
	
	for uuid in invalid_uuids:
		unregister_object(uuid)
		cleaned += 1
	
	# Clean systems
	var invalid_systems = []
	for system_name in all_systems:
		if not is_instance_valid(all_systems[system_name]):
			invalid_systems.append(system_name)
	
	for system_name in invalid_systems:
		all_systems.erase(system_name)
		cleaned += 1
	
	performance_stats.last_cleanup = Time.get_ticks_msec()
	return cleaned

# ========== UTILITY FUNCTIONS ==========

func _generate_uuid() -> String:
	"""Generate a unique ID"""
	return "obj_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

func _estimate_memory() -> float:
	"""Estimate memory usage in MB"""
	var base = 100.0
	var per_object = 0.5
	var per_being = 2.0
	
	return base + (performance_stats.total_objects * per_object) + (performance_stats.total_beings * per_being)

func get_stats() -> Dictionary:
	"""Get hub statistics"""
	return {
		"objects": performance_stats.total_objects,
		"beings": performance_stats.total_beings,
		"systems": performance_stats.total_systems,
		"rules": all_rules.size(),
		"globals": global_variables.size(),
		"requests_per_second": performance_stats.requests_per_second,
		"memory_estimate_mb": _estimate_memory()
	}

# ========== CONVENIENCE FUNCTIONS ==========

func find_nearest_object(pos: Vector3, type: String = "") -> Node:
	"""Find nearest object to a position"""
	request_counter += 1
	var nearest = null
	var min_dist = INF
	
	var search_objects = get_objects_by_type(type) if type else all_objects.values()
	
	for obj in search_objects:
		if is_instance_valid(obj) and obj.has_method("get_global_position"):
			var dist = pos.distance_to(obj.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = obj
	
	return nearest

func broadcast_to_systems(message: String, _data: Dictionary = {}) -> void:
	"""Send message to all registered systems"""
	for system_name in all_systems:
		var system = all_systems[system_name]
		if is_instance_valid(system) and system.has_method("receive_broadcast"):
			system.receive_broadcast(message, _data)