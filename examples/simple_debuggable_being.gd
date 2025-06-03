# Example: Simplified Debuggable Being using DEBUG_META
# Shows how easy it is to make any being debuggable with minimal code

extends UniversalBeing
class_name SimpleDebuggableBeing

# Just define what you want to show/edit/do!
const DEBUG_META := {
	"show_vars": ["being_name", "consciousness_level", "position"],
	"edit_vars": ["consciousness_level", "being_name"],
	"actions": {
		"Evolve": "_evolve",
		"Reset": "_reset"
	}
}

# Your normal being properties
@export var special_property: float = 42.0

func _evolve():
	consciousness_level = mini(consciousness_level + 1, 7)
	print("✨ Evolved to consciousness level %d!" % consciousness_level)

func _reset():
	consciousness_level = 0
	print("🔄 Reset to base consciousness")

# That's it! The debug system handles the rest using DEBUG_META
# You only need these if you want custom behavior:

func get_debug_payload() -> Dictionary:
	# Use the default implementation from base class
	var out := {}
	for key in DEBUG_META.get("show_vars", []):
		out[key] = get(key) if has_method("get") else "N/A"
	return out

func set_debug_field(key: String, value) -> void:
	# Only allow editing fields listed in edit_vars
	if key in DEBUG_META.get("edit_vars", []):
		set(key, value)
		print("✏️ Set %s = %s" % [key, value])

func get_debug_actions() -> Dictionary:
	# Convert method names to callables
	var out := {}
	for label in DEBUG_META.actions.keys():
		out[label] = Callable(self, DEBUG_META.actions[label])
	return out
