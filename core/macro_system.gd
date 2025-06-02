# ==================================================
# UNIVERSAL BEING: Macro System
# TYPE: system
# PURPOSE: Manages and executes macros for Universal Beings
# COMPONENTS: []
# SCENES: []
# ==================================================

extends UniversalBeing
class_name MacroSystemUniversalBeing

# ===== MACRO MANAGEMENT =====

var macros: Dictionary = {}  # name -> MacroData
var active_macro: MacroData = null
var macro_history: Array[MacroData] = []
var max_history_size: int = 100

# ===== MACRO DATA STRUCTURE =====

class MacroData:
	var name: String
	var commands: Array[String]
	var description: String
	var created_by: String
	var created_at: int
	var last_used: int
	var usage_count: int
	
	func _init(p_name: String, p_commands: Array[String], p_description: String = "", p_created_by: String = "system") -> void:
		name = p_name
		commands = p_commands
		description = p_description
		created_by = p_created_by
		created_at = Time.get_unix_time_from_system()
		last_used = created_at
		usage_count = 0
	
	func to_dict() -> Dictionary:
		return {
			"name": name,
			"commands": commands,
			"description": description,
			"created_by": created_by,
			"created_at": created_at,
			"last_used": last_used,
			"usage_count": usage_count
		}
	
	static func from_dict(data: Dictionary) -> MacroData:
		var macro = MacroData.new(
			data.get("name", ""),
			data.get("commands", []),
			data.get("description", ""),
			data.get("created_by", "system")
		)
		macro.last_used = data.get("last_used", macro.created_at)
		macro.usage_count = data.get("usage_count", 0)
		return macro

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "macro_system"
	being_name = "Macro System"
	consciousness_level = 2  # System-level consciousness
	
	print("🎮 Macro System: Pentagon Init Complete")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Register with FloodGate as system being
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_system_being"):
			flood_gates.register_system_being(self)
	
	# Load saved macros
	load_macros()
	
	print("🎮 Macro System: Pentagon Ready Complete")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Process active macro if any
	if active_macro:
		process_active_macro()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle macro-related input
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE and active_macro:
			cancel_active_macro()

func pentagon_sewers() -> void:
	# Save macros before cleanup
	save_macros()
	
	# Clear active macro
	active_macro = null
	macro_history.clear()
	
	super.pentagon_sewers()

# ===== MACRO MANAGEMENT METHODS =====

func create_macro(name: String, commands: Array[String], description: String = "", created_by: String = "system") -> bool:
	"""Create a new macro"""
	if macros.has(name):
		push_error("Macro '%s' already exists" % name)
		return false
	
	var macro = MacroData.new(name, commands, description, created_by)
	macros[name] = macro
	save_macros()
	print("🎮 Created macro: %s" % name)
	return true

func delete_macro(name: String) -> bool:
	"""Delete an existing macro"""
	if not macros.has(name):
		push_error("Macro '%s' not found" % name)
		return false
	
	macros.erase(name)
	save_macros()
	print("🎮 Deleted macro: %s" % name)
	return true

func execute_macro(name: String) -> bool:
	"""Execute a macro by name"""
	if not macros.has(name):
		push_error("Macro '%s' not found" % name)
		return false
	
	if active_macro:
		push_error("Macro '%s' already active" % active_macro.name)
		return false
	
	active_macro = macros[name]
	active_macro.last_used = Time.get_unix_time_from_system()
	active_macro.usage_count += 1
	
	# Add to history
	macro_history.append(active_macro)
	if macro_history.size() > max_history_size:
		macro_history.pop_front()
	
	print("🎮 Executing macro: %s" % name)
	return true

func cancel_active_macro() -> void:
	"""Cancel the currently active macro"""
	if active_macro:
		print("🎮 Cancelled macro: %s" % active_macro.name)
		active_macro = null

func process_active_macro() -> void:
	"""Process the active macro's commands"""
	if not active_macro or active_macro.commands.is_empty():
		active_macro = null
		return
	
	# Get next command
	var command = active_macro.commands.pop_front()
	
	# Execute command through command processor
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var command_processor = SystemBootstrap.get_command_processor()
		if command_processor and command_processor.has_method("process_command"):
			command_processor.process_command(command)

func get_macro_info(name: String) -> Dictionary:
	"""Get information about a macro"""
	if not macros.has(name):
		return {}
	
	return macros[name].to_dict()

func list_macros() -> Array[Dictionary]:
	"""List all available macros"""
	var macro_list: Array[Dictionary] = []
	for macro in macros.values():
		macro_list.append(macro.to_dict())
	return macro_list

func get_macro_history() -> Array[Dictionary]:
	"""Get macro execution history"""
	var history: Array[Dictionary] = []
	for macro in macro_history:
		history.append(macro.to_dict())
	return history

# ===== PERSISTENCE =====

func save_macros() -> void:
	"""Save macros to Akashic Records"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("save_data"):
			var macro_data = {}
			for name in macros:
				macro_data[name] = macros[name].to_dict()
			akashic.save_data("macros", macro_data)

func load_macros() -> void:
	"""Load macros from Akashic Records"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("load_data"):
			var macro_data = akashic.load_data("macros", {})
			for name in macro_data:
				macros[name] = MacroData.from_dict(macro_data[name])

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	var base_interface = super.ai_interface()
	
	base_interface["macro_info"] = {
		"total_macros": macros.size(),
		"active_macro": active_macro.name if active_macro else "none",
		"history_size": macro_history.size()
	}
	
	base_interface["capabilities"] = [
		"macro_creation",
		"macro_execution",
		"macro_management",
		"history_tracking"
	]
	
	return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"create_macro":
			if args.size() >= 2:
				return create_macro(args[0], args[1], args[2] if args.size() > 2 else "", args[3] if args.size() > 3 else "ai")
			return false
		"delete_macro":
			if args.size() > 0:
				return delete_macro(args[0])
			return false
		"execute_macro":
			if args.size() > 0:
				return execute_macro(args[0])
			return false
		"cancel_macro":
			cancel_active_macro()
			return true
		"list_macros":
			return list_macros()
		"get_history":
			return get_macro_history()
		_:
			return super.ai_invoke_method(method_name, args) 