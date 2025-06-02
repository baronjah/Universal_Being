# ==================================================
# UNIVERSAL BEING: Input Focus Manager
# TYPE: system
# PURPOSE: Manages input focus for Universal Beings
# COMPONENTS: []
# SCENES: []
# ==================================================

extends UniversalBeing
class_name InputFocusManagerUniversalBeing

# ===== FOCUS MANAGEMENT =====

var focused_being: Node = null
var focus_stack: Array[Node] = []
var focus_locked: bool = false

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "input_focus_manager"
	being_name = "Input Focus Manager"
	consciousness_level = 2  # System-level consciousness
	
	print("🎯 Input Focus Manager: Pentagon Init Complete")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Register with FloodGate as system being
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_system_being"):
			flood_gates.register_system_being(self)
	
	print("🎯 Input Focus Manager: Pentagon Ready Complete")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Process focus updates
	update_focus_state()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle focus-related input
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			clear_focus()
		elif event.keycode == KEY_TAB:
			if event.shift_pressed:
				focus_previous()
			else:
				focus_next()

func pentagon_sewers() -> void:
	# Cleanup focus state
	clear_focus()
	focus_stack.clear()
	
	super.pentagon_sewers()

# ===== FOCUS MANAGEMENT METHODS =====

func set_focus(being: Node) -> bool:
	"""Set focus to a specific Universal Being"""
	if focus_locked or not being:
		return false
	
	# Remove current focus
	if focused_being:
		if focused_being.has_method("on_focus_lost"):
			focused_being.on_focus_lost()
		focus_stack.erase(focused_being)
	
	# Set new focus
	focused_being = being
	if not being in focus_stack:
		focus_stack.append(being)
	
	# Notify being
	if being.has_method("on_focus_gained"):
		being.on_focus_gained()
	
	print("🎯 Focus set to: %s" % being.name)
	return true

func clear_focus() -> void:
	"""Clear current focus"""
	if focused_being:
		if focused_being.has_method("on_focus_lost"):
			focused_being.on_focus_lost()
		focused_being = null
		print("🎯 Focus cleared")

func focus_next() -> void:
	"""Focus next being in stack"""
	if focus_stack.is_empty():
		return
	
	var current_index = focus_stack.find(focused_being) if focused_being else -1
	var next_index = (current_index + 1) % focus_stack.size()
	set_focus(focus_stack[next_index])

func focus_previous() -> void:
	"""Focus previous being in stack"""
	if focus_stack.is_empty():
		return
	
	var current_index = focus_stack.find(focused_being) if focused_being else 0
	var prev_index = (current_index - 1) if current_index > 0 else focus_stack.size() - 1
	set_focus(focus_stack[prev_index])

func update_focus_state() -> void:
	"""Update focus state each frame"""
	if focused_being and not is_instance_valid(focused_being):
		clear_focus()
		focus_stack.erase(focused_being)

func lock_focus(locked: bool = true) -> void:
	"""Lock/unlock focus changes"""
	focus_locked = locked
	print("🎯 Focus %s" % ("locked" if locked else "unlocked"))

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	var base_interface = super.ai_interface()
	
	base_interface["focus_info"] = {
		"focused_being": focused_being.name if focused_being else "none",
		"focus_stack_size": focus_stack.size(),
		"focus_locked": focus_locked
	}
	
	base_interface["capabilities"] = [
		"focus_management",
		"focus_navigation",
		"focus_locking"
	]
	
	return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"set_focus":
			if args.size() > 0:
				return set_focus(args[0])
			return false
		"clear_focus":
			clear_focus()
			return true
		"lock_focus":
			lock_focus(args[0] if args.size() > 0 else true)
			return true
		"unlock_focus":
			lock_focus(false)
			return true
		_:
			return super.ai_invoke_method(method_name, args) 