# ==================================================
# MACRO SYSTEM - Record Reality Manipulation Sequences
# PURPOSE: Record and replay command sequences
# LOCATION: core/command_system/MacroSystem.gd
# ==================================================

extends Node
#class_name MacroSystem # Commented to avoid duplicate

var command_processor: UniversalCommandProcessor
var recording: bool = false
var current_macro: Macro = null
var stored_macros: Dictionary = {}

signal macro_started(name: String)
signal macro_completed(name: String, commands: int)
signal macro_played(name: String)

class Macro:
	var name: String
	var commands: Array[MacroCommand] = []
	var description: String = ""
	var tags: Array[String] = []
	var consciousness_requirement: int = 0
	
	func add_command(cmd: String, delay_ms: int = 0) -> void:
		commands.append(MacroCommand.new(cmd, delay_ms))
	
	func to_dict() -> Dictionary:
		pass
		var cmds = []
		for cmd in commands:
			cmds.append(cmd.to_dict())
		return {
			"name": name,
			"commands": cmds,
			"description": description,
			"tags": tags,
			"consciousness_requirement": consciousness_requirement
		}
	
	static func from_dict(data: Dictionary) -> Macro:
		var macro = Macro.new()
		macro.name = data.get("name", "unnamed")
		macro.description = data.get("description", "")
		macro.tags = data.get("tags", [])
		macro.consciousness_requirement = data.get("consciousness_requirement", 0)
		
		for cmd_data in data.get("commands", []):
			var cmd = MacroCommand.from_dict(cmd_data)
			macro.commands.append(cmd)
		
		return macro

class MacroCommand:
	var command: String
	var delay_ms: int
	var timestamp: float
	
	func _init(cmd: String = "", delay: int = 0) -> void:
		command = cmd
		delay_ms = delay
		timestamp = Time.get_ticks_msec()
	
	func to_dict() -> Dictionary:
		return {
			"command": command,
			"delay_ms": delay_ms
		}
	
	static func from_dict(data: Dictionary) -> MacroCommand:
		return MacroCommand.new(
			data.get("command", ""),
			data.get("delay_ms", 0)
		)

func _ready() -> void:
	# Find command processor
	if has_node("/root/UniversalCommandProcessor"):
		command_processor = get_node("/root/UniversalCommandProcessor")
		command_processor.command_executed.connect(_on_command_executed)
	
	load_macros()

func start_recording(macro_name: String) -> void:
	"""Start recording a new macro"""
	if recording:
		stop_recording()
	
	current_macro = Macro.new()
	current_macro.name = macro_name
	recording = true
	macro_started.emit(macro_name)
	print("🔴 Recording macro: %s" % macro_name)

func stop_recording() -> bool:
	"""Stop recording and save macro"""
	if not recording or not current_macro:
		return false
	
	recording = false
	stored_macros[current_macro.name] = current_macro
	save_macros()
	
	var cmd_count = current_macro.commands.size()
	macro_completed.emit(current_macro.name, cmd_count)
	print("⏹️ Macro saved: %s (%d commands)" % [current_macro.name, cmd_count])
	
	current_macro = null
	return true

func play_macro(macro_name: String, target: Node = null) -> void:
	"""Play a recorded macro"""
	if not macro_name in stored_macros:
		push_error("Macro not found: %s" % macro_name)
		return
	
	var macro = stored_macros[macro_name]
	macro_played.emit(macro_name)
	
	# Check consciousness requirement
	if target and target is UniversalBeing:
		if target.consciousness_level < macro.consciousness_requirement:
			print("⚠️ Insufficient consciousness level for macro: %s" % macro_name)
			return
	
	# Execute commands with delays
	_execute_macro_commands(macro.commands)

func _execute_macro_commands(commands: Array) -> void:
	"""Execute macro commands with proper timing"""
	for i in range(commands.size()):
		var cmd = commands[i]
		
		if cmd.delay_ms > 0:
			await get_tree().create_timer(cmd.delay_ms / 1000.0).timeout
		
		if command_processor:
			command_processor.execute_command(cmd.command)

func _on_command_executed(command: String, result: Variant) -> void:
	"""Record commands when in recording mode"""
	if recording and current_macro:
		var delay = 0
		if current_macro.commands.size() > 0:
			# Calculate delay from last command
			var last_cmd = current_macro.commands[-1]
			delay = Time.get_ticks_msec() - last_cmd.timestamp
		
		current_macro.add_command(command, delay)

func list_macros(filter_tags: Array[String] = []) -> Array[String]:
	"""List all available macros with optional tag filter"""
	var result: Array[String] = []
	
	for macro_name in stored_macros:
		var macro = stored_macros[macro_name]
		
		# Filter by tags if specified
		if not filter_tags.is_empty():
			var has_tag = false
			for tag in filter_tags:
				if tag in macro.tags:
					has_tag = true
					break
			if not has_tag:
				continue
		
		result.append(macro_name)
	
	return result

func get_macro_info(macro_name: String) -> Dictionary:
	"""Get detailed information about a macro"""
	if not macro_name in stored_macros:
		return {}
	
	var macro = stored_macros[macro_name]
	return {
		"name": macro.name,
		"description": macro.description,
		"command_count": macro.commands.size(),
		"tags": macro.tags,
		"consciousness_requirement": macro.consciousness_requirement,
		"commands": macro.commands.map(func(cmd): return cmd.command)
	}

func create_combo_macro(name: String, macro_names: Array[String]) -> bool:
	"""Combine multiple macros into one"""
	var combo = Macro.new()
	combo.name = name
	combo.description = "Combo: " + ", ".join(macro_names)
	combo.tags = ["combo"]
	
	for macro_name in macro_names:
		if macro_name in stored_macros:
			var macro = stored_macros[macro_name]
			for cmd in macro.commands:
				combo.commands.append(cmd)
			
			# Update consciousness requirement
			combo.consciousness_requirement = max(
				combo.consciousness_requirement,
				macro.consciousness_requirement
			)
	
	if combo.commands.size() > 0:
		stored_macros[name] = combo
		save_macros()
		return true
	
	return false

func save_macros() -> void:
	"""Save all macros to Akashic Records"""
	if has_node("/root/AkashicRecordsSystemSystem"):
		var akashic = get_node("/root/AkashicRecordsSystemSystem")
		var data = {}
		for name in stored_macros:
			data[name] = stored_macros[name].to_dict()
		akashic.save_record("macros", "system", data)

func load_macros() -> void:
	"""Load macros from Akashic Records"""
	if has_node("/root/AkashicRecordsSystemSystem"):
		var akashic = get_node("/root/AkashicRecordsSystemSystem")
		var data = akashic.load_record("macros", "system")
		if data and data is Dictionary:
			for name in data:
				stored_macros[name] = Macro.from_dict(data[name])
			print("📼 Loaded %d macros" % stored_macros.size())

# Predefined reality manipulation macros
func create_default_macros() -> void:
	"""Create useful default macros"""
	
	# Door opening sequence
	var door_macro = Macro.new()
	door_macro.name = "open_door"
	door_macro.description = "Opens doors when 'potato' is said"
	door_macro.add_command("create trigger potato open_door")
	door_macro.add_command("connect door_sensor door_actuator")
	door_macro.tags = ["interaction", "trigger"]
	stored_macros["open_door"] = door_macro
	
	# Being spawn sequence
	var spawn_macro = Macro.new()
	spawn_macro.name = "spawn_conscious"
	spawn_macro.description = "Spawn a conscious being"
	spawn_macro.add_command("create being Seeker conscious", 100)
	spawn_macro.add_command("execute target.consciousness_level = 5", 100)
	spawn_macro.add_command("connect target consciousness_network", 100)
	spawn_macro.consciousness_requirement = 3
	spawn_macro.tags = ["creation", "consciousness"]
	stored_macros["spawn_conscious"] = spawn_macro
	
	# Reality warp sequence
	var warp_macro = Macro.new()
	warp_macro.name = "reality_warp"
	warp_macro.description = "Warp reality parameters"
	warp_macro.add_command("reality gravity 50", 200)
	warp_macro.add_command("reality time 0.5", 200)
	warp_macro.add_command("execute get_tree().call_group('universal_beings', 'on_reality_shift')", 100)
	warp_macro.consciousness_requirement = 7
	warp_macro.tags = ["reality", "advanced"]
	stored_macros["reality_warp"] = warp_macro
	
	save_macros()