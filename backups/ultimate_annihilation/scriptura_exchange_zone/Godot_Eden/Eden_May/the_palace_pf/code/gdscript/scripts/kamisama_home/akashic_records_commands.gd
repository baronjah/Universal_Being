# Akashic Records Console Commands
# This script adds Akashic Records related commands to the JSH console

extends Node

# Reference to the JSH console
var jsh_console = null

# Reference to the Akashic Records integration
var akashic_records = null

# Initialize the commands
func initialize(p_jsh_console, p_akashic_records) -> void:
    jsh_console = p_jsh_console
    akashic_records = p_akashic_records
    
    if jsh_console and akashic_records:
        # Register commands
        _register_commands()
        print("Akashic Records commands registered with JSH console")
    else:
        push_error("Failed to register Akashic Records commands: Invalid references")

# Register all Akashic Records related commands
func _register_commands() -> void:
    # Add word command
    jsh_console.register_command({
        "command": "akashic-add",
        "description": "Add a new word to the Akashic Records",
        "usage": "akashic-add <id> <category> [parent_id]",
        "callback": Callable(self, "_cmd_akashic_add"),
        "min_args": 2,
        "max_args": 3
    })
    
    # Get word command
    jsh_console.register_command({
        "command": "akashic-get",
        "description": "Get word details from the Akashic Records",
        "usage": "akashic-get <id>",
        "callback": Callable(self, "_cmd_akashic_get"),
        "min_args": 1,
        "max_args": 1
    })
    
    # List words command
    jsh_console.register_command({
        "command": "akashic-list",
        "description": "List words in the Akashic Records",
        "usage": "akashic-list [category]",
        "callback": Callable(self, "_cmd_akashic_list"),
        "min_args": 0,
        "max_args": 1
    })
    
    # Interact command
    jsh_console.register_command({
        "command": "akashic-interact",
        "description": "Perform interaction between two words",
        "usage": "akashic-interact <word1_id> <word2_id>",
        "callback": Callable(self, "_cmd_akashic_interact"),
        "min_args": 2,
        "max_args": 2
    })
    
    # Save command
    jsh_console.register_command({
        "command": "akashic-save",
        "description": "Save the Akashic Records dictionary",
        "usage": "akashic-save",
        "callback": Callable(self, "_cmd_akashic_save"),
        "min_args": 0,
        "max_args": 0
    })
    
    # Status command
    jsh_console.register_command({
        "command": "akashic-status",
        "description": "Show Akashic Records system status",
        "usage": "akashic-status",
        "callback": Callable(self, "_cmd_akashic_status"),
        "min_args": 0,
        "max_args": 0
    })
    
    # Help command
    jsh_console.register_command({
        "command": "akashic-help",
        "description": "Show help for Akashic Records commands",
        "usage": "akashic-help",
        "callback": Callable(self, "_cmd_akashic_help"),
        "min_args": 0,
        "max_args": 0
    })

# Command implementations

# Add a new word
func _cmd_akashic_add(args: Array) -> String:
    var id = args[0]
    var category = args[1]
    var parent_id = args[2] if args.size() > 2 else ""
    
    var result = akashic_records.create_word(id, category, {}, parent_id)
    
    if result:
        return "Word '" + id + "' added to category '" + category + "'"
    else:
        return "Failed to add word: " + id

# Get word details
func _cmd_akashic_get(args: Array) -> String:
    var id = args[0]
    var records_manager = akashic_records.get_akashic_records_manager()
    
    if not records_manager or not records_manager.dynamic_dictionary:
        return "Error: Akashic Records system not fully initialized"
    
    var word = records_manager.dynamic_dictionary.get_word(id)
    
    if word:
        var result = "Word: " + word.id + "\n"
        result += "Category: " + word.category + "\n"
        
        if word.parent_id and word.parent_id != "":
            result += "Parent: " + word.parent_id + "\n"
        
        result += "Properties: " + str(word.properties) + "\n"
        result += "States: " + str(word.states)
        
        return result
    else:
        return "Word not found: " + id

# List words
func _cmd_akashic_list(args: Array) -> String:
    var records_manager = akashic_records.get_akashic_records_manager()
    
    if not records_manager or not records_manager.dynamic_dictionary:
        return "Error: Akashic Records system not fully initialized"
    
    var category = args[0] if args.size() > 0 else ""
    var words = records_manager.dynamic_dictionary.words
    
    if words.is_empty():
        return "Dictionary is empty"
    
    var result = "Dictionary words:\n"
    var count = 0
    
    for id in words.keys():
        var word = words[id]
        if category == "" or word.category == category:
            result += "- " + word.id + " (" + word.category + ")\n"
            count += 1
    
    result += "\nTotal: " + str(count) + " words"
    if category != "":
        result += " in category '" + category + "'"
    
    return result

# Perform interaction
func _cmd_akashic_interact(args: Array) -> String:
    var word1_id = args[0]
    var word2_id = args[1]
    
    var result = akashic_records.process_interaction(word1_id, word2_id)
    
    if result.has("success") and result.success:
        return "Interaction result: " + str(result.result if result.has("result") else "No result data")
    else:
        return "Interaction failed: " + str(result.error if result.has("error") else "Unknown error")

# Save dictionary
func _cmd_akashic_save(args: Array) -> String:
    var result = akashic_records.save_all()
    
    if result:
        return "Akashic Records dictionary saved successfully"
    else:
        return "Failed to save Akashic Records dictionary"

# Show status
func _cmd_akashic_status(args: Array) -> String:
    var records_manager = akashic_records.get_akashic_records_manager()
    
    if not records_manager:
        return "Error: Akashic Records manager not found"
    
    if not records_manager.dynamic_dictionary:
        return "Error: Dynamic Dictionary not initialized"
    
    var word_count = records_manager.dynamic_dictionary.words.size()
    
    var result = "Akashic Records Status:\n"
    result += "Dictionary word count: " + str(word_count) + "\n"
    
    if records_manager.zone_manager:
        result += "Zones: " + str(records_manager.zone_manager.zones.size() if records_manager.zone_manager.zones else 0) + "\n"
        result += "Active zones: " + str(records_manager.zone_manager.active_zones.size() if records_manager.zone_manager.active_zones else 0) + "\n"
    
    if records_manager.evolution_manager:
        result += "Evolution rate: " + str(records_manager.evolution_manager.evolution_rate)
    
    return result

# Show help
func _cmd_akashic_help(args: Array) -> String:
    var result = "Akashic Records Commands:\n"
    result += "  akashic-add <id> <category> [parent_id] - Add a new word\n"
    result += "  akashic-get <id> - Get word details\n"
    result += "  akashic-list [category] - List words\n"
    result += "  akashic-interact <word1_id> <word2_id> - Perform interaction\n"
    result += "  akashic-save - Save dictionary\n"
    result += "  akashic-status - Show system status\n"
    result += "  akashic-help - Show this help text"
    
    return result