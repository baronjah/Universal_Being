# Debuggable Interface - Luminus's elegant debug contract
# Every runtime script should optionally implement this for clean debug panels

extends RefCounted
class_name Debuggable

## Return a payload the debugger can render & edit
func get_debug_payload() -> Dictionary:
	return {}

## Called after a value is live-edited
func set_debug_field(key: String, value) -> void:
	pass

## Return callable buttons (string → Callable)
func get_debug_actions() -> Dictionary:
	return {}

## Optional: introspect all vars + functions automatically
func reflect_debug_data() -> Dictionary:
	var result := {}
	for prop in get_property_list():
		# Check if property should be shown (exported or editor visible)
		if prop.has("usage") and (prop.usage & PROPERTY_USAGE_EDITOR):
			var prop_name = prop.get("name", "")
			if not prop_name.begins_with("_"):  # Skip private properties
				result[prop_name] = get(prop_name)
	return result