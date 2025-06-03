# LogicConnector (singleton) - Luminus's elegant debug registry
# Central registry for all Debuggable objects with raypicking support

extends Node
class_name LogicConnectorSingleton

var _registry: Dictionary = {}   # Object → Debuggable

# ===== REGISTRY MANAGEMENT =====

func register(o: Object) -> void:
	"""Register an object if it implements Debuggable interface"""
	if o is Debuggable:
		_registry[o] = o
		print("🔌 Registered debuggable: %s" % o.name if o.has_method("get") else str(o))

func deregister(o: Object) -> void:
	"""Deregister an object from debug registry"""
	if o in _registry:
		print("🔌 Deregistered debuggable: %s" % o.name if o.has_method("get") else str(o))
	_registry.erase(o)

func all() -> Array:
	"""Get all registered debuggable objects"""
	return _registry.values()

func raypick(camera: Camera3D) -> Debuggable:
	"""Pick debuggable object under camera raycast"""
	if not camera:
		return null
	
	var space_state = camera.get_world_3d().direct_space_state
	var from = camera.global_position
	var to = camera.global_position - camera.transform.basis.z * 1000
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var hit = space_state.intersect_ray(query)
	
	if hit and hit.get("collider") in _registry:
		return _registry[hit.get("collider")]
	
	return null

# ===== UTILITY METHODS =====

func get_debuggable_count() -> int:
	"""Get number of registered debuggable objects"""
	return _registry.size()

func find_debuggable_by_name(name: String) -> Debuggable:
	"""Find debuggable object by name"""
	for obj in _registry.keys():
		if obj.has_method("get") and obj.name == name:
			return _registry[obj]
	return null

func get_debuggable_types() -> Array[String]:
	"""Get all unique types of registered debuggables"""
	var types = []
	for obj in _registry.keys():
		var type = obj.get_class() if obj.has_method("get_class") else "Unknown"
		if type not in types:
			types.append(type)
	return types

func clear_registry() -> void:
	"""Clear all registered objects (for testing)"""
	_registry.clear()
	print("🔌 LogicConnector registry cleared")

func print_registry_status() -> void:
	"""Print current registry status"""
	print("🔌 LogicConnector Registry Status:")
	print("  Total Objects: %d" % _registry.size())
	print("  Types: %s" % get_debuggable_types())
	
	for obj in _registry.keys():
		var name = obj.name if obj.has_method("get") else "unnamed"
		var type = obj.get_class() if obj.has_method("get_class") else "unknown"
		print("  - %s (%s)" % [name, type])