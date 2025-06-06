# ==================================================
# UNIVERSAL BEING: UniversalCommandProcessor
# TYPE: Core System
# PURPOSE: Meta-game command system for reality creation and modification
# COMPONENTS: Command parsing, natural language processing, dynamic execution
# SCENES: None (core system)
# ==================================================

extends UniversalBeing
class_name UniversalCommandProcessor

# ===== COMMAND CATEGORIES =====
enum CommandType {
    NATURAL_LANGUAGE,     # "say potato to open doors"
    SCRIPT_COMMAND,       # "/load script door_opener.gd"
    DATA_INSPECTION,      # "/count lines in script.gd"
    LOGIC_CONNECTOR,      # "/when potato near door then open"
    REALITY_MODIFIER,     # "/create being from template"
    SYSTEM_DEBUG,         # "/reload all scripts"
    AI_COLLABORATION      # "/gemma create new logic"
}

# ===== COMMAND SYSTEM =====
var command_history: Array[Dictionary] = []
var logic_connectors: Dictionary = {}  # word -> action mappings
var natural_language_patterns: Dictionary = {}
var active_macros: Dictionary = {}
var script_cache: Dictionary = {}

# ===== MACRO SYSTEM =====
var macro_recording: bool = false
var current_macro: Array[String] = []

# ===== AI COLLABORATION CHANNELS =====
var ai_channel_active: bool = false
var ai_collaboration_log: Array[String] = []
var gemma_commands: Array[String] = []

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    being_type = "command_processor"
    being_name = "Universal Command Processor"
    consciousness_level = 7  # Highest level for reality control
    
    _initialize_command_patterns()
    _setup_logic_connectors()
    
    print("🌟 UniversalCommandProcessor: Meta-reality system online")

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Connect to console for command processing
    _connect_to_console()
    
    print("🌟 UniversalCommandProcessor: Ready for universe creation")

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Process pending commands
    _process_command_queue(delta)
    
    # Check logic connectors for proximity triggers
    _check_proximity_triggers()

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    # Handle AI collaboration hotkeys
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F1: toggle_ai_channel()
            KEY_F2: start_macro_recording()
            KEY_F3: replay_last_macro()

func pentagon_sewers() -> void:
    print("🌟 UniversalCommandProcessor: Saving reality state...")
    _save_command_history()
    _save_logic_connectors()
    super.pentagon_sewers()

# ===== COMMAND PROCESSING =====

func process_universal_command(command: String, source: String = "user") -> Dictionary:
    """Process any command - natural language or structured"""
    print("🌟 Processing command: '%s' from %s" % [command, source])
    
    var result = {
        "success": false,
        "message": "",
        "actions_performed": [],
        "new_beings_created": [],
        "scripts_modified": []
    }
    
    # Record command in history
    var command_entry = {
        "command": command,
        "source": source,
        "timestamp": Time.get_unix_time_from_system(),
        "consciousness_context": consciousness_level
    }
    command_history.append(command_entry)
    
    # Determine command type and process
    var cmd_type = _classify_command(command)
    
    match cmd_type:
        CommandType.NATURAL_LANGUAGE:
            result = _process_natural_language(command)
        CommandType.SCRIPT_COMMAND:
            result = _process_script_command(command)
        CommandType.DATA_INSPECTION:
            result = _process_data_inspection(command)
        CommandType.LOGIC_CONNECTOR:
            result = _process_logic_connector(command)
        CommandType.REALITY_MODIFIER:
            result = _process_reality_modifier(command)
        CommandType.SYSTEM_DEBUG:
            result = _process_system_debug(command)
        CommandType.AI_COLLABORATION:
            result = _process_ai_collaboration(command)
    
    # Log result for AI learning
    command_entry["result"] = result
    
    return result

func _process_natural_language(command: String) -> Dictionary:
    """Process natural language commands like 'say potato to open doors'"""
    var result = {"success": false, "message": "", "actions_performed": []}
    
    # Parse natural language patterns
    if command.contains("say") and command.contains("to"):
        var parts = command.split(" to ")
        if parts.size() >= 2:
            var trigger_phrase = parts[0].replace("say ", "").strip_edges()
            var action_description = parts[1].strip_edges()
            
            # Create logic connector
            var connector_id = "nl_" + str(Time.get_ticks_msec())
            logic_connectors[trigger_phrase] = {
                "id": connector_id,
                "action": action_description,
                "type": "proximity_trigger",
                "created_by": command,
                "consciousness_level": consciousness_level
            }
            
            result.success = true
            result.message = "Created logic connector: '%s' -> '%s'" % [trigger_phrase, action_description]
            result.actions_performed.append("logic_connector_created")
            
            print("🌟 Logic connector created: %s" % trigger_phrase)
    
    return result

func _process_script_command(command: String) -> Dictionary:
    """Process script-related commands"""
    var result = {"success": false, "message": "", "actions_performed": []}
    
    if command.begins_with("/load script "):
        var script_path = command.replace("/load script ", "").strip_edges()
        var loaded_script = _load_and_cache_script(script_path)
        
        if loaded_script:
            result.success = true
            result.message = "Script loaded: %s" % script_path
            result.actions_performed.append("script_loaded")
        else:
            result.message = "Failed to load script: %s" % script_path
    
    elif command.begins_with("/reload "):
        var target = command.replace("/reload ", "").strip_edges()
        if target == "all scripts":
            _reload_all_scripts()
            result.success = true
            result.message = "All scripts reloaded"
            result.actions_performed.append("all_scripts_reloaded")
    
    return result

func _process_data_inspection(command: String) -> Dictionary:
    """Process data inspection commands"""
    var result = {"success": false, "message": "", "actions_performed": []}
    
    if command.contains("count lines in"):
        var file_path = command.split("count lines in ")[1].strip_edges()
        var line_count = _count_lines_in_file(file_path)
        
        if line_count >= 0:
            result.success = true
            result.message = "File %s has %d lines" % [file_path, line_count]
            result.actions_performed.append("line_count_performed")
    
    elif command.contains("show functions in"):
        var file_path = command.split("show functions in ")[1].strip_edges()
        var functions = _extract_functions_from_file(file_path)
        
        result.success = true
        result.message = "Functions in %s: %s" % [file_path, str(functions)]
        result.actions_performed.append("function_analysis_performed")
    
    return result

func _process_logic_connector(command: String) -> Dictionary:
    """Process logic connector commands"""
    var result = {"success": false, "message": "", "actions_performed": []}
    
    if command.begins_with("/when "):
        var parts = command.replace("/when ", "").split(" then ")
        if parts.size() >= 2:
            var trigger = parts[0].strip_edges()
            var action = parts[1].strip_edges()
            
            # Create logic connector
            var connector_id = "lc_" + str(Time.get_ticks_msec())
            logic_connectors[connector_id] = {
                "trigger": trigger,
                "action": action,
                "type": "logic_connector",
                "created_by": command
            }
            
            result.success = true
            result.message = "Created logic connector: '%s' -> '%s'" % [trigger, action]
            result.actions_performed.append("logic_connector_created")
    
    return result

func _process_reality_modifier(command: String) -> Dictionary:
    """Process reality modification commands"""
    var result = {"success": false, "message": "", "actions_performed": []}
    
    if command.begins_with("/create being "):
        var description = command.replace("/create being ", "").strip_edges()
        var being = _create_being_from_description({"name": description, "type": "generic"})
        if being:
            result.success = true
            result.message = "Created new being: %s" % being.being_name
            result.actions_performed.append("being_created")
            result.new_beings_created.append(being)
    elif command.begins_with("/modify "):
        var modification = command.replace("/modify ", "").strip_edges()
        if _apply_reality_modification({"type": "custom", "value": modification}):
            result.success = true
            result.message = "Applied modification: %s" % modification
            result.actions_performed.append("reality_modified")
        else:
            result.message = "Failed to apply modification: %s" % modification
    
    return result

# ===== AI COLLABORATION SYSTEM =====

func toggle_ai_channel() -> void:
    """Toggle AI collaboration channel"""
    ai_channel_active = !ai_channel_active
    
    if ai_channel_active:
        print("🤖 AI Collaboration Channel ACTIVE - You and Gemma can now create together!")
        _notify_gemma_channel_open()
    else:
        print("🤖 AI Collaboration Channel closed")

func process_ai_command(command: String, ai_source: String = "gemma") -> Dictionary:
    """Process commands from AI systems"""
    print("🤖 AI Command from %s: %s" % [ai_source, command])
    
    # Add AI context to command processing
    var result = process_universal_command(command, ai_source)
    
    # Log AI collaboration
    ai_collaboration_log.append("%s: %s" % [ai_source, command])
    
    return result

func create_anything_with_ai(description: String) -> Dictionary:
    """Collaborative creation with AI"""
    print("✨ Creating with AI: %s" % description)
    
    var creation_plan = _generate_creation_plan(description)
    var result = _execute_creation_plan(creation_plan)
    
    return result

# ===== PROXIMITY TRIGGERS =====

func _check_proximity_triggers() -> void:
    """Check for proximity-based logic triggers"""
    for being in get_tree().get_nodes_in_group("universal_beings"):
        if being.has_method("check_proximity_triggers"):
            # Create a single action parameter for proximity check
            var action_data = {
                "type": "proximity_check",
                "source": being,
                "metadata": {}
            }
            being.check_proximity_triggers(action_data)

func _execute_proximity_action(action: Dictionary) -> void:
    """Execute a proximity-based action"""
    var source = action.get("source")
    var target = action.get("target")
    if source and target and source.has_method("on_proximity_action"):
        # Create a single action parameter containing all necessary data
        var action_data = {
            "target": target,
            "action_type": action.get("type", "proximity"),
            "metadata": action.get("metadata", {})
        }
        source.on_proximity_action(action_data)

# ===== UTILITY FUNCTIONS =====

func _count_lines_in_file(file_path: String) -> int:
    """Count lines in a file"""
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var count = 0
        while not file.eof_reached():
            file.get_line()
            count += 1
        return count
    return -1

func _extract_functions_from_file(file_path: String) -> Array:
    """Extract function names from a file"""
    var functions = []
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        while not file.eof_reached():
            var line = file.get_line()
            if line.contains("func "):
                var func_name = line.split("func ")[1].split("(")[0].strip_edges()
                functions.append(func_name)
    return functions

func _load_and_cache_script(script_path: String) -> GDScript:
    """Load and cache a script"""
    if script_cache.has(script_path):
        return script_cache[script_path]
    
    var script = load(script_path)
    if script:
        script_cache[script_path] = script
        return script
    return null

# ===== AI INTERFACE =====

func ai_interface() -> Dictionary:
    """Enhanced AI interface for meta-game control"""
    var base = super.ai_interface()
    base.meta_commands = [
        "process_command",
        "create_anything",
        "setup_logic_connector",
        "inspect_data",
        "reload_reality",
        "collaborate_with_user"
    ]
    base.collaboration_active = ai_channel_active
    base.command_history_size = command_history.size()
    return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """AI method invocation for universe control"""
    match method_name:
        "process_command":
            if args.size() > 0:
                return process_universal_command(args[0], "ai")
            return {"success": false, "message": "No command provided"}
        
        "create_anything":
            if args.size() > 0:
                return create_anything_with_ai(args[0])
            return {"success": false, "message": "No description provided"}
        
        "setup_logic_connector":
            if args.size() >= 2:
                var trigger = args[0]
                var action = args[1]
                logic_connectors[trigger] = {"action": action, "type": "ai_created"}
                return "Logic connector created: %s -> %s" % [trigger, action]
            return {"success": false, "message": "Missing trigger or action"}
        
        "inspect_data":
            if args.size() > 0:
                return _process_data_inspection("show functions in " + args[0])
            return {"success": false, "message": "No target specified"}
        
        "reload_reality":
            _reload_all_scripts()
            return "Reality reloaded - all scripts refreshed"
        
        "collaborate_with_user":
            toggle_ai_channel()
            return "AI collaboration channel: %s" % ("active" if ai_channel_active else "inactive")
        
        _:
            return await super.ai_invoke_method(method_name, args)

func _to_string() -> String:
    return "UniversalCommandProcessor<Commands:%d, Connectors:%d>" % [command_history.size(), logic_connectors.size()]

# ===== INITIALIZATION FUNCTIONS =====

func _initialize_command_patterns() -> void:
    """Initialize natural language command patterns"""
    natural_language_patterns = {
        "say_to": {
            "pattern": "say {word} to {action}",
            "example": "say potato to open doors"
        },
        "create_being": {
            "pattern": "create being {name} {type}",
            "example": "create being Door door"
        },
        "connect_logic": {
            "pattern": "connect {source} to {target}",
            "example": "connect door_sensor door_actuator"
        }
    }

func _setup_logic_connectors() -> void:
    """Setup initial logic connector system"""
    logic_connectors = {}
    # Load any saved connectors from Akashic Records
    if has_node("/root/AkashicRecordsSystemSystem"):
        var records = get_node("/root/AkashicRecordsSystemSystem")
        var saved_connectors = records.load_record("logic_connectors", "system")
        if saved_connectors:
            logic_connectors = saved_connectors

func _connect_to_console() -> void:
    """Connect to UniversalConsole for command processing"""
    if has_node("/root/UniversalConsole"):
        var console = get_node("/root/UniversalConsole")
        console.command_entered.connect(_on_console_command)
        console.ai_channel_toggled.connect(_on_ai_channel_toggle)

func _process_command_queue(delta: float) -> void:
    """Process any pending commands in the queue"""
    # Process any queued commands
    pass  # Implement command queue processing

func _save_command_history() -> void:
    """Save command history to Akashic Records"""
    if has_node("/root/AkashicRecordsSystemSystem"):
        var records = get_node("/root/AkashicRecordsSystemSystem")
        records.save_record("command_history", "system", command_history)

func _save_logic_connectors() -> void:
    """Save logic connectors to Akashic Records"""
    if has_node("/root/AkashicRecordsSystemSystem"):
        var records = get_node("/root/AkashicRecordsSystemSystem")
        records.save_record("logic_connectors", "system", logic_connectors)

func _classify_command(command: String) -> CommandType:
    """Classify command type based on content"""
    if command.begins_with("/"):
        if command.contains("script"):
            return CommandType.SCRIPT_COMMAND
        elif command.contains("count") or command.contains("show"):
            return CommandType.DATA_INSPECTION
        elif command.contains("reload"):
            return CommandType.SYSTEM_DEBUG
        elif command.contains("gemma"):
            return CommandType.AI_COLLABORATION
    
    if command.contains("say") and command.contains("to"):
        return CommandType.NATURAL_LANGUAGE
    elif command.contains("connect"):
        return CommandType.LOGIC_CONNECTOR
    elif command.contains("create being"):
        return CommandType.REALITY_MODIFIER
    
    return CommandType.NATURAL_LANGUAGE  # Default to natural language

func _process_system_debug(command: String) -> Dictionary:
    """Process system debug commands"""
    var result = {"success": false, "message": "", "actions_performed": []}
    
    if command == "/reload all scripts":
        _reload_all_scripts()
        result.success = true
        result.message = "All scripts reloaded"
        result.actions_performed.append("scripts_reloaded")
    
    return result

func _process_ai_collaboration(command: String) -> Dictionary:
    """Process AI collaboration commands"""
    var result = {"success": false, "message": "", "actions_performed": []}
    
    if command.begins_with("/gemma"):
        var ai_command = command.replace("/gemma ", "")
        gemma_commands.append(ai_command)
        result.success = true
        result.message = "AI command queued: " + ai_command
        result.actions_performed.append("ai_command_queued")
    
    return result

func _reload_all_scripts() -> void:
    """Reload all scripts in the game"""
    for node in get_tree().get_nodes_in_group("universal_beings"):
        if node.get_script():
            var script_path = node.get_script().resource_path
            if script_path:
                node.set_script(load(script_path))

func _create_being_from_description(description: Dictionary) -> UniversalBeing:
    """Create a new being from description"""
    var being = UniversalBeing.new()
    being.being_name = description.get("name", "Unnamed")
    being.being_type = description.get("type", "generic")
    being.consciousness_level = description.get("consciousness", 1)
    return being

func _apply_reality_modification(modification: Dictionary) -> bool:
    """Apply a reality modification"""
    var success = false
    
    match modification.get("type"):
        "gravity":
            ProjectSettings.set_setting("physics/2d/default_gravity", modification.value)
            success = true
        "time_scale":
            Engine.time_scale = modification.value
            success = true
        "consciousness":
            # Modify global consciousness rules
            success = true
        "custom":
            # Handle custom modifications
            success = true
    
    return success  # Always return a boolean value

func _notify_gemma_channel_open() -> void:
    """Notify when AI channel is opened"""
    if has_node("/root/UniversalConsole"):
        var console = get_node("/root/UniversalConsole")
        console.ai_print("Gemma channel active - Ready for collaboration")

func _generate_creation_plan(description: String) -> Array:
    """Generate a plan for creating something"""
    var plan = []
    # Add creation steps based on description
    return plan

func _execute_creation_plan(plan: Array) -> bool:
    """Execute a creation plan"""
    for step in plan:
        # Execute each step
        pass
    return true

# ===== MACRO SYSTEM =====

func start_macro_recording() -> void:
    """Start recording a new macro"""
    if not macro_recording:
        macro_recording = true
        current_macro = []
        print("🌟 Macro recording started")

func replay_last_macro() -> void:
    """Replay the last recorded macro"""
    if active_macros.has("last_macro"):
        var macro = active_macros["last_macro"]
        for command in macro:
            process_universal_command(command, "macro")
        print("🌟 Replayed last macro")

# ===== SIGNAL HANDLERS =====

func _on_console_command(command: String) -> void:
    """Handle commands from the UniversalConsole"""
    process_universal_command(command, "console")

func _on_ai_channel_toggle(enabled: bool) -> void:
    """Handle AI channel toggle from console"""
    ai_channel_active = enabled
    if enabled:
        _notify_gemma_channel_open()