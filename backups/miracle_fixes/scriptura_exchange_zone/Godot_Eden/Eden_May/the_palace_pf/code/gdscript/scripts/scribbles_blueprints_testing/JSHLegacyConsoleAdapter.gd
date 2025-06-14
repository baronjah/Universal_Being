extends Node
class_name JSHLegacyConsoleAdapter

# This adapter connects our Phase 4 JSHConsoleManager with the existing JSH_console.gd implementation
# It enables bidirectional command execution and output synchronization

# References to both systems
var jsh_console_manager: JSHConsoleManager = null
var legacy_console = null  # JSH_console.gd instance

# References to bank systems
var records_bank = null
var actions_bank = null
var scenes_bank = null
var instructions_bank = null
var banks_combiner = null

# Text display reference
var text_screen = null

# Command and output mapping
var command_mapping = {}
var legacy_commands = []
var output_buffer = []

# Configuration
var bidirectional_command_execution = true
var sync_output = true
var register_bank_commands = true

# Initialization
func _init(console_manager = null, legacy_instance = null):
    jsh_console_manager = console_manager if console_manager else JSHConsoleManager.get_instance()
    legacy_console = legacy_instance

func _ready():
    # Find legacy console if not provided in init
    if not legacy_console:
        legacy_console = get_node_or_null("/root/JSH_console")
    
    # Find bank systems
    records_bank = get_node_or_null("/root/records_bank")
    actions_bank = get_node_or_null("/root/actions_bank")
    scenes_bank = get_node_or_null("/root/scenes_bank") 
    instructions_bank = get_node_or_null("/root/instructions_bank")
    banks_combiner = get_node_or_null("/root/banks_combiner")
    
    # Find text screen
    text_screen = get_node_or_null("/root/text_screen")
    
    # Set up signal connections
    _connect_signals()
    
    # Import legacy commands
    if legacy_console:
        _import_legacy_commands()
    
    # Import bank actions as commands
    if actions_bank and register_bank_commands:
        _import_bank_actions()
    
    print("JSHLegacyConsoleAdapter: Initialized")

# Signal connections
func _connect_signals():
    # Connect legacy console signals
    if legacy_console:
        if legacy_console.has_signal("command_executed"):
            legacy_console.connect("command_executed", Callable(self, "_on_legacy_command_executed"))
        
        if legacy_console.has_signal("console_output"):
            legacy_console.connect("console_output", Callable(self, "_on_legacy_console_output"))
    
    # Connect JSH console signals
    jsh_console_manager.connect("command_executed", Callable(self, "_on_jsh_command_executed"))
    
    # Connect text screen signals
    if text_screen and text_screen.has_signal("text_updated"):
        text_screen.connect("text_updated", Callable(self, "_on_text_screen_updated"))

# Legacy command import
func _import_legacy_commands():
    # Attempt to get all commands from legacy console
    var commands = []
    
    if legacy_console.has_method("get_all_commands"):
        commands = legacy_console.get_all_commands()
    elif legacy_console.has_method("get_commands"):
        commands = legacy_console.get_commands()
    elif legacy_console.has_property("commands") and legacy_console.commands is Dictionary:
        commands = legacy_console.commands.keys()
    
    # Register each command in our system
    for cmd_name in commands:
        legacy_commands.append(cmd_name)
        
        var cmd_data = {}
        if legacy_console.has_method("get_command_data"):
            cmd_data = legacy_console.get_command_data(cmd_name)
        
        # Create a command entry for our system
        jsh_console_manager.register_command(cmd_name, {
            "description": cmd_data.get("description", "Legacy console command"),
            "usage": cmd_data.get("usage", cmd_name + " [arguments]"),
            "callback": Callable(self, "_execute_legacy_command"),
            "min_args": cmd_data.get("min_args", 0),
            "max_args": cmd_data.get("max_args", -1),
            "legacy_command": true,
            "original_name": cmd_name
        })
        
        # Store mapping
        command_mapping[cmd_name] = cmd_name
    
    print("JSHLegacyConsoleAdapter: Imported " + str(legacy_commands.size()) + " legacy commands")

# Bank action import
func _import_bank_actions():
    var actions = []
    
    if actions_bank.has_method("get_all_actions"):
        actions = actions_bank.get_all_actions()
    elif actions_bank.has_method("get_actions"):
        actions = actions_bank.get_actions()
    elif actions_bank.has_property("actions") and actions_bank.actions is Dictionary:
        actions = actions_bank.actions.keys()
    
    # Register each action as a command
    for action_name in actions:
        var action_data = {}
        if actions_bank.has_method("get_action_data"):
            action_data = actions_bank.get_action_data(action_name)
        
        # Create a command name with bank prefix
        var cmd_name = "bank_" + action_name
        
        # Register command
        jsh_console_manager.register_command(cmd_name, {
            "description": action_data.get("description", "Bank action: " + action_name),
            "usage": cmd_name + " [arguments]",
            "callback": Callable(self, "_execute_bank_action"),
            "min_args": action_data.get("min_args", 0),
            "max_args": action_data.get("max_args", -1),
            "bank_action": true,
            "original_name": action_name
        })
        
        # Store mapping
        command_mapping[cmd_name] = action_name
    
    print("JSHLegacyConsoleAdapter: Imported bank actions as commands")

# Execute legacy command
func _execute_legacy_command(self, args = []) -> Dictionary:
    if not legacy_console:
        return {
            "success": false,
            "message": "Legacy console not available"
        }
    
    # Get command info from args
    var cmd_data = jsh_console_manager.commands[jsh_console_manager.get_command_list()[0]]
    var cmd_name = cmd_data.get("original_name", args[0])
    var cmd_args = args.slice(1) if args.size() > 1 else []
    
    # Execute command in legacy console
    var result = null
    
    if legacy_console.has_method("execute_command"):
        result = legacy_console.execute_command(cmd_name, cmd_args)
    elif legacy_console.has_method("run_command"):
        result = legacy_console.run_command(cmd_name, cmd_args)
    else:
        # Attempt to call method directly
        if legacy_console.has_method(cmd_name):
            result = legacy_console.call(cmd_name, cmd_args)
    
    # Format result as dictionary
    var result_dict = {}
    if result is Dictionary:
        result_dict = result
    else:
        result_dict = {
            "success": true,
            "message": str(result) if result != null else "Command executed"
        }
    
    # Add legacy marker
    result_dict["legacy"] = true
    result_dict["command"] = cmd_name
    
    return result_dict

# Execute bank action
func _execute_bank_action(self, args = []) -> Dictionary:
    if not actions_bank:
        return {
            "success": false,
            "message": "Actions bank not available"
        }
    
    # Get action info from args
    var cmd_data = jsh_console_manager.commands[jsh_console_manager.get_command_list()[0]]
    var action_name = cmd_data.get("original_name", args[0])
    var action_args = args.slice(1) if args.size() > 1 else []
    
    # Execute action in bank
    var result = null
    
    if actions_bank.has_method("execute_action"):
        result = actions_bank.execute_action(action_name, action_args)
    elif actions_bank.has_method("run_action"):
        result = actions_bank.run_action(action_name, action_args)
    else:
        # Attempt to call method directly
        if actions_bank.has_method(action_name):
            result = actions_bank.call(action_name, action_args)
    
    # Format result as dictionary
    var result_dict = {}
    if result is Dictionary:
        result_dict = result
    else:
        result_dict = {
            "success": true,
            "message": str(result) if result != null else "Action executed"
        }
    
    # Add bank marker
    result_dict["bank"] = true
    result_dict["action"] = action_name
    
    return result_dict

# Signal handlers
func _on_legacy_command_executed(command, result):
    if sync_output:
        # Forward result to JSH console
        if result is Dictionary and result.has("message"):
            jsh_console_manager.print_line(result.message)
        else:
            jsh_console_manager.print_line(str(result))

func _on_legacy_console_output(text):
    if sync_output:
        # Forward output to JSH console
        jsh_console_manager.print_line(text)

func _on_jsh_command_executed(command_text, result):
    # Check if command should be forwarded to legacy console
    if not bidirectional_command_execution:
        return
    
    # Skip forwarding of already forwarded commands
    if result.get("legacy", false) or result.get("bank", false):
        return
    
    # Forward to legacy console if appropriate
    if legacy_console and not result.get("command", "") in legacy_commands:
        if legacy_console.has_method("print_line"):
            legacy_console.print_line("> " + command_text)
            
            if result.has("message"):
                legacy_console.print_line(result.message)

func _on_text_screen_updated(text):
    if sync_output and text and not text.is_empty():
        jsh_console_manager.print_line(text)

# Public API
func execute_in_legacy_console(command_text: String) -> Dictionary:
    if not legacy_console:
        return {
            "success": false,
            "message": "Legacy console not available"
        }
    
    # Parse command
    var parts = command_text.split(" ")
    var cmd_name = parts[0]
    var args = parts.slice(1) if parts.size() > 1 else []
    
    # Execute in legacy console
    return _execute_legacy_command(self, [cmd_name] + args)

func execute_bank_action(action_name: String, args: Array = []) -> Dictionary:
    if not actions_bank:
        return {
            "success": false,
            "message": "Actions bank not available"
        }
    
    # Execute bank action
    return _execute_bank_action(self, [action_name] + args)

func get_legacy_commands() -> Array:
    return legacy_commands.duplicate()

func sync_entities_with_records_bank() -> int:
    if not records_bank or not entity_manager:
        return 0
    
    var entity_manager = JSHEntityManager.get_instance()
    var records = []
    var sync_count = 0
    
    # Get records from bank
    if records_bank.has_method("get_all_records"):
        records = records_bank.get_all_records()
    elif records_bank.has_property("records") and records_bank.records is Dictionary:
        records = records_bank.records.values()
    
    # Sync each record to an entity
    for record in records:
        var record_id = record.get("id", "")
        if record_id.is_empty():
            continue
        
        var record_type = record.get("type", "unknown")
        var record_props = record.get("properties", {})
        
        # Create or update entity
        var entity = entity_manager.get_entity_by_property("record_id", record_id)
        
        if not entity:
            # Create new entity
            entity = entity_manager.create_entity(record_type, record_props)
            if entity:
                entity.set_property("record_id", record_id)
                sync_count += 1
        else:
            # Update existing entity
            for key in record_props:
                entity.set_property(key, record_props[key])
            sync_count += 1
    
    print("JSHLegacyConsoleAdapter: Synced " + str(sync_count) + " entities with records bank")
    return sync_count

# Integration commands for JSH console
static func register_integration_commands(console_manager: JSHConsoleManager) -> void:
    console_manager.register_command("legacy", {
        "description": "Execute command in legacy console",
        "usage": "legacy <command> [arguments]",
        "callback": Callable(JSHLegacyConsoleAdapter, "_cmd_legacy"),
        "min_args": 1,
        "max_args": -1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Command to execute in legacy console"]
    })
    
    console_manager.register_command("bank", {
        "description": "Execute action in banks system",
        "usage": "bank <action> [arguments]",
        "callback": Callable(JSHLegacyConsoleAdapter, "_cmd_bank"),
        "min_args": 1,
        "max_args": -1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Action to execute in banks system"]
    })
    
    console_manager.register_command("sync", {
        "description": "Synchronize between systems",
        "usage": "sync <system> [direction]",
        "callback": Callable(JSHLegacyConsoleAdapter, "_cmd_sync"),
        "min_args": 1,
        "max_args": 2,
        "arg_types": [TYPE_STRING, TYPE_STRING],
        "arg_descriptions": ["System to sync (entities, records, zones, all)", "Direction (to_jsh, from_jsh, both)"]
    })

# Static command handlers
static func _cmd_legacy(self, args: Array) -> Dictionary:
    var adapter = self.get_node_or_null("/root/JSHLegacyConsoleAdapter")
    
    if not adapter:
        self.print_error("Legacy console adapter not found")
        return {"success": false, "message": "Adapter not found"}
    
    var command = args[0]
    var command_args = args.slice(1)
    var command_text = command
    
    if command_args.size() > 0:
        command_text += " " + " ".join(command_args)
    
    var result = adapter.execute_in_legacy_console(command_text)
    
    if result.get("success", false):
        self.print_success("Command executed in legacy console: " + command)
    else:
        self.print_error("Failed to execute in legacy console: " + result.get("message", "Unknown error"))
    
    return result

static func _cmd_bank(self, args: Array) -> Dictionary:
    var adapter = self.get_node_or_null("/root/JSHLegacyConsoleAdapter")
    
    if not adapter:
        self.print_error("Legacy console adapter not found")
        return {"success": false, "message": "Adapter not found"}
    
    var action = args[0]
    var action_args = args.slice(1)
    
    var result = adapter.execute_bank_action(action, action_args)
    
    if result.get("success", false):
        self.print_success("Action executed in bank: " + action)
    else:
        self.print_error("Failed to execute bank action: " + result.get("message", "Unknown error"))
    
    return result

static func _cmd_sync(self, args: Array) -> Dictionary:
    var adapter = self.get_node_or_null("/root/JSHLegacyConsoleAdapter")
    
    if not adapter:
        self.print_error("Legacy console adapter not found")
        return {"success": false, "message": "Adapter not found"}
    
    var system = args[0].to_lower()
    var direction = "both"
    
    if args.size() > 1:
        direction = args[1].to_lower()
    
    var result = {
        "success": true,
        "message": "Sync completed",
        "systems": {},
        "count": 0
    }
    
    match system:
        "entities", "records":
            var count = adapter.sync_entities_with_records_bank()
            result.systems["entities"] = count
            result.count += count
            self.print_line("Synced " + str(count) + " entities with records bank")
        
        "all":
            var entities_count = adapter.sync_entities_with_records_bank()
            result.systems["entities"] = entities_count
            result.count += entities_count
            self.print_line("Synced " + str(entities_count) + " entities with records bank")
        
        _:
            self.print_error("Unknown system to sync: " + system)
            return {"success": false, "message": "Unknown system: " + system}
    
    self.print_success("Sync completed: " + str(result.count) + " items synchronized")
    return result