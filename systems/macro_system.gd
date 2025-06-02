# ==================================================
# UNIVERSAL BEING: MacroSystem
# TYPE: Command Recording System
# PURPOSE: Record, replay, and edit command sequences for complex operations
# COMPONENTS: Command recording, playback, editing, AI macro generation
# SCENES: None (core system)
# ==================================================

extends UniversalBeing
class_name MacroSystem

# ===== MACRO STRUCTURES =====
var active_macros: Dictionary = {}  # macro_name -> macro_data
var recording_macro: Dictionary = {}
var is_recording: bool = false
var current_recording_name: String = ""

# ===== MACRO DATA STRUCTURE =====
# macro_data = {
#   "name": "door_opening_sequence",
#   "description": "Opens doors with potato command",
#   "commands": [
#     {"command": "say potato", "timestamp": 0.0, "context": {}},
#     {"command": "/scene load door.tscn", "timestamp": 1.5, "context": {}}
#   ],
#   "created_by": "user|ai|collaborative",
#   "consciousness_context": 3,
#   "success_rate": 0.95
# }

# ===== RECORDING STATE =====
var recording_start_time: float = 0.0
var last_command_time: float = 0.0

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    being_type = "macro_system"
    being_name = "Macro Recording System"
    consciousness_level = 4  # Enlightened level for pattern recognition
    
    _load_saved_macros()
    
    print("📹 MacroSystem: Command recording system ready")

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Connect to command processor for recording
    _connect_to_command_system()
    
    print("📹 MacroSystem: Connected to command pipeline")

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Update recording timestamps if recording
    if is_recording:
        last_command_time += delta

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    # Handle macro hotkeys
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F2:
                _toggle_recording()
            KEY_F3:
                _replay_last_macro()
            KEY_F4:
                _show_macro_menu()

func pentagon_sewers() -> void:
    print("📹 MacroSystem: Saving macro library...")
    _save_macro_library()
    super.pentagon_sewers()

# ===== RECORDING SYSTEM =====

func start_recording(macro_name: String = "") -> bool:
    """Start recording a new macro"""
    if is_recording:
        print("📹 Already recording macro: %s" % current_recording_name)
        return false
    
    if macro_name.is_empty():
        macro_name = "macro_" + str(Time.get_unix_time_from_system())
    
    current_recording_name = macro_name
    recording_macro = {
        "name": macro_name,
        "description": "",
        "commands": [],
        "created_by": "user",
        "consciousness_context": consciousness_level,
        "creation_time": Time.get_unix_time_from_system()
    }
    
    is_recording = true
    recording_start_time = Time.get_time_dict_from_system().msec / 1000.0
    last_command_time = 0.0
    
    print("📹 Recording started: %s" % macro_name)
    return true

func stop_recording() -> Dictionary:
    """Stop recording and save the macro"""
    if not is_recording:
        print("📹 No recording in progress")
        return {}
    
    is_recording = false
    
    # Finalize macro
    recording_macro["duration"] = last_command_time
    recording_macro["command_count"] = recording_macro.commands.size()
    
    # Save to active macros
    active_macros[current_recording_name] = recording_macro.duplicate()
    
    print("📹 Recording complete: %s (%d commands, %.1fs duration)" % [
        current_recording_name,
        recording_macro.command_count,
        recording_macro.duration
    ])
    
    var completed_macro = recording_macro.duplicate()
    recording_macro.clear()
    current_recording_name = ""
    
    return completed_macro

func record_command(command: String, context: Dictionary = {}) -> void:
    """Record a command during macro recording"""
    if not is_recording:
        return
    
    var command_entry = {
        "command": command,
        "timestamp": last_command_time,
        "context": context.duplicate(),
        "consciousness_level": consciousness_level
    }
    
    recording_macro.commands.append(command_entry)
    print("📹 Recorded: %s (t=%.1fs)" % [command, last_command_time])

# ===== PLAYBACK SYSTEM =====

func replay_macro(macro_name: String, speed_multiplier: float = 1.0) -> bool:
    """Replay a saved macro"""
    if not active_macros.has(macro_name):
        print("📹 Macro not found: %s" % macro_name)
        return false
    
    var macro = active_macros[macro_name]
    print("📹 Replaying macro: %s" % macro_name)
    
    _execute_macro_sequence(macro, speed_multiplier)
    return true

func _execute_macro_sequence(macro: Dictionary, speed_multiplier: float) -> void:
    """Execute macro command sequence"""
    var commands = macro.commands
    var command_processor = _get_command_processor()
    
    if not command_processor:
        print("📹 Command processor not available")
        return
    
    # Execute commands with timing
    for i in range(commands.size()):
        var cmd = commands[i]
        var delay = cmd.timestamp / speed_multiplier
        
        # Wait for the right time
        if delay > 0:
            await get_tree().create_timer(delay).timeout
        
        # Execute command
        print("📹 Executing: %s" % cmd.command)
        var result = command_processor.process_universal_command(cmd.command, "macro")
        
        # Check if command succeeded
        if not result.success:
            print("📹 Macro command failed: %s" % cmd.command)
            break

func replay_last_macro() -> bool:
    """Replay the most recently created macro"""
    if active_macros.is_empty():
        print("📹 No macros available")
        return false
    
    # Find most recent macro
    var latest_macro = ""
    var latest_time = 0.0
    
    for macro_name in active_macros:
        var macro = active_macros[macro_name]
        if macro.creation_time > latest_time:
            latest_time = macro.creation_time
            latest_macro = macro_name
    
    return replay_macro(latest_macro)

# ===== MACRO EDITING =====

func edit_macro(macro_name: String) -> Dictionary:
    """Get macro for editing"""
    if not active_macros.has(macro_name):
        return {}
    
    return active_macros[macro_name].duplicate()

func update_macro(macro_name: String, edited_macro: Dictionary) -> bool:
    """Update a macro with edited version"""
    if not active_macros.has(macro_name):
        return false
    
    active_macros[macro_name] = edited_macro.duplicate()
    print("📹 Macro updated: %s" % macro_name)
    return true

func add_command_to_macro(macro_name: String, command: String, position: int = -1) -> bool:
    """Add command to existing macro"""
    if not active_macros.has(macro_name):
        return false
    
    var macro = active_macros[macro_name]
    var new_command = {
        "command": command,
        "timestamp": 0.0,
        "context": {},
        "consciousness_level": consciousness_level
    }
    
    if position < 0 or position >= macro.commands.size():
        macro.commands.append(new_command)
    else:
        macro.commands.insert(position, new_command)
    
    # Recalculate timestamps
    _recalculate_macro_timing(macro)
    
    print("📹 Command added to macro %s: %s" % [macro_name, command])
    return true

func _recalculate_macro_timing(macro: Dictionary) -> void:
    """Recalculate timing for macro commands"""
    var time_per_command = 1.0  # Default 1 second between commands
    
    for i in range(macro.commands.size()):
        macro.commands[i].timestamp = i * time_per_command

# ===== AI MACRO GENERATION =====

func generate_ai_macro(description: String, ai_source: String = "gemma") -> Dictionary:
    """Generate macro using AI"""
    print("🤖 Generating AI macro: %s" % description)
    
    var ai_macro = {
        "name": "ai_" + description.replace(" ", "_").to_lower(),
        "description": description,
        "commands": _generate_commands_for_description(description),
        "created_by": ai_source,
        "consciousness_context": consciousness_level,
        "creation_time": Time.get_unix_time_from_system()
    }
    
    # Add to active macros
    active_macros[ai_macro.name] = ai_macro
    
    print("🤖 AI macro created: %s" % ai_macro.name)
    return ai_macro

func _generate_commands_for_description(description: String) -> Array:
    """Generate command sequence based on description"""
    var commands = []
    
    # Simple pattern matching for common scenarios
    if description.contains("door"):
        commands.append({"command": "say potato", "timestamp": 0.0, "context": {}})
        commands.append({"command": "/scene load door.tscn", "timestamp": 1.0, "context": {}})
    
    elif description.contains("create") and description.contains("being"):
        commands.append({"command": "/create being " + description, "timestamp": 0.0, "context": {}})
        commands.append({"command": "/scene list", "timestamp": 1.0, "context": {}})
    
    else:
        # Generic command generation
        commands.append({"command": description, "timestamp": 0.0, "context": {}})
    
    return commands

# ===== MACRO LIBRARY MANAGEMENT =====

func _save_macro_library() -> void:
    """Save all macros to file"""
    var save_data = {
        "macros": active_macros,
        "version": "1.0",
        "save_time": Time.get_unix_time_from_system()
    }
    
    var file = FileAccess.open("user://macro_library.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()
        print("📹 Macro library saved (%d macros)" % active_macros.size())

func _load_saved_macros() -> void:
    """Load saved macros from file"""
    var file = FileAccess.open("user://macro_library.json", FileAccess.READ)
    if not file:
        print("📹 No saved macro library found")
        return
    
    var json_text = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var parse_result = json.parse(json_text)
    
    if parse_result == OK:
        var save_data = json.data
        active_macros = save_data.get("macros", {})
        print("📹 Loaded %d saved macros" % active_macros.size())

# ===== UTILITY FUNCTIONS =====

func _toggle_recording() -> void:
    """Toggle recording state"""
    if is_recording:
        stop_recording()
    else:
        start_recording()

func _show_macro_menu() -> void:
    """Show available macros"""
    print("📹 Available Macros:")
    for macro_name in active_macros:
        var macro = active_macros[macro_name]
        print("  %s: %s (%d commands)" % [macro_name, macro.description, macro.commands.size()])

func _get_command_processor() -> Node:
    """Get the universal command processor"""
    return get_node_or_null("/root/UniversalCommandProcessor")

func _connect_to_command_system() -> void:
    """Connect to command system for automatic recording"""
    var cmd_processor = _get_command_processor()
    if cmd_processor and cmd_processor.has_signal("command_executed"):
        cmd_processor.command_executed.connect(_on_command_executed)

func _on_command_executed(command: String, result: Dictionary) -> void:
    """Handle command execution during recording"""
    if is_recording:
        record_command(command, result)

# ===== AI INTERFACE =====

func ai_interface() -> Dictionary:
    """AI interface for macro system"""
    var base = super.ai_interface()
    base.macro_commands = [
        "start_recording",
        "stop_recording",
        "replay_macro",
        "create_ai_macro",
        "list_macros",
        "edit_macro"
    ]
    base.recording_state = is_recording
    base.macro_count = active_macros.size()
    return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """AI method invocation for macro control"""
    match method_name:
        "start_recording":
            var name = args[0] if args.size() > 0 else ""
            return start_recording(name)
        
        "stop_recording":
            return stop_recording()
        
        "replay_macro":
            if args.size() > 0:
                var speed = args[1] if args.size() > 1 else 1.0
                return replay_macro(args[0], speed)
        
        "create_ai_macro":
            if args.size() > 0:
                return generate_ai_macro(args[0], "ai")
        
        "list_macros":
            var macro_list = []
            for macro_name in active_macros:
                macro_list.append({
                    "name": macro_name,
                    "description": active_macros[macro_name].description,
                    "commands": active_macros[macro_name].commands.size()
                })
            return macro_list
        
        "edit_macro":
            if args.size() > 0:
                return edit_macro(args[0])
        
        _:
            return await super.ai_invoke_method(method_name, args)

func _to_string() -> String:
    return "MacroSystem<Recording:%s, Macros:%d>" % [str(is_recording), active_macros.size()]