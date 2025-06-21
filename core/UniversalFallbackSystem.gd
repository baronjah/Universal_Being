# ==================================================
# UNIVERSAL FALLBACK SYSTEM
# PURPOSE: Load multiple scripts with same class name, fallback method resolution
# ==================================================

extends RefCounted
class_name UniversalFallbackSystem

static var class_registry = {}

# Register multiple implementations of the same class name
static func register_class_implementation(class_names: String, script_path: String, priority: int = 0):
	if not class_registry.has(class_names):
		class_registry[class_names] = []
	
	var implementation = {
		"script_path": script_path,
		"script": load(script_path),
		"priority": priority
	}
	
	class_registry[class_names].append(implementation)
	# Sort by priority (higher priority first)
	class_registry[class_names].sort_custom(func(a, b): return a.priority > b.priority)

# Create instance with fallback method resolution
static func create_fallback_instance(class_names: String):
	if not class_registry.has(class_names):
		push_error("No implementations registered for class: " + class_names)
		return null
	
	var implementations = class_registry[class_names]
	if implementations.is_empty():
		return null
	
	# Create primary instance
	var primary_script = implementations[0].script
	var instance = primary_script.new()
	
	# Wrap with fallback proxy if multiple implementations exist
	if implementations.size() > 1:
		return FallbackProxy.new(instance, implementations)
	
	return instance

class FallbackProxy:
	extends RefCounted
	
	var primary_instance
	var implementations: Array
	var method_cache = {}
	
	func _init(primary: Object, impls: Array):
		primary_instance = primary
		implementations = impls
	
	# Intercept all method calls
	func _get(property):
		if primary_instance.has_method(property):
			return Callable(self, "_call_with_fallback").bind(property)
		return primary_instance.get(property)
	
	func _set(property, value):
		primary_instance.set(property, value)
	
	func _call_with_fallback(method_name: String, args: Array = []):
		# Check cache first
		if method_cache.has(method_name):
			var cached_instance = method_cache[method_name]
			return cached_instance.callv(method_name, args)
		
		# Try each implementation in priority order
		for impl in implementations:
			var instance = impl.script.new()
			if instance.has_method(method_name):
				method_cache[method_name] = instance
				return instance.callv(method_name, args)
		
		push_error("Method '" + method_name + "' not found in any implementation")
		return null
	
	# Forward common Object methods (renamed to avoid native conflicts)
	func proxy_has_method(method: StringName) -> bool:
		if primary_instance.has_method(method):
			return true
		
		for impl in implementations:
			var instance = impl.script.new()
			if instance.has_method(method):
				return true
		return false
	
	func proxy_get_class() -> String:
		return primary_instance.get_class()
