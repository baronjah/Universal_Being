# Debuggable Interface - Luminus's elegant debug contract
# Every runtime script should optionally implement this for clean debug panels

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