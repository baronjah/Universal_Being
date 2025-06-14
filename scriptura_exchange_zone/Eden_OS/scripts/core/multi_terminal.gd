extends Node

class_name MultiTerminal

# Multi-Terminal System for Eden_OS
# Manages multiple terminal windows for parallel operations

signal terminal_created(terminal_id)
signal terminal_closed(terminal_id)
signal terminal_output(terminal_id, output)
signal terminal_command_executed(terminal_id, command, result)
signal terminal_focus_changed(terminal_id)

# Terminal config
const MAX_TERMINALS = 12
const DEFAULT_TERMINALS = 3
const DEFAULT_TERMINAL_NAMES = ["main", "words", "dimensions"]

# Terminal state
var active_terminals = {}
var focused_terminal = "main"
var terminal_history = {}
var terminal_settings = {}

# Terminal appearance
var terminal_colors = {
    "main": Color(0.1, 0.1, 0.3),
    "words": Color(0.1, 0.3, 0.1),
    "dimensions": Color(0.3, 0.1, 0.1),
    "default": Color(0.2, 0.2, 0.2)
}

var terminal_layouts = {
    "horizontal": {"distribution": [0.33, 0.33, 0.34], "direction": "horizontal"},
    "vertical": {"distribution": [0.33, 0.33, 0.34], "direction": "vertical"},
    "grid": {"rows": 2, "columns": 2},
    "main_with_sidebars": {"main": 0.6, "sides": 0.2, "direction": "horizontal"}
}

var current_layout = "horizontal"

# Window UI references
var terminal_nodes = {}
var container_node = null

func _ready():
    initialize_terminal_system()
    print("Multi-Terminal System initialized with " + str(DEFAULT_TERMINALS) + " terminals")

func initialize_terminal_system():
    # Create default terminals
    for i in range(DEFAULT_TERMINALS):
        var terminal_id = DEFAULT_TERMINAL_NAMES[i]
        create_terminal(terminal_id)
    
    # Set focus to main terminal
    set_focus("main")
    
    # Apply default layout
    apply_layout(current_layout)

func create_terminal(terminal_id, settings={}):
    if active_terminals.size() >= MAX_TERMINALS:
        return "Maximum number of terminals reached (" + str(MAX_TERMINALS) + ")"
    
    if active_terminals.has(terminal_id):
        return "Terminal '" + terminal_id + "' already exists"
    
    # Create terminal
    active_terminals[terminal_id] = {
        "created": Time.get_unix_time_from_system(),
        "last_active": Time.get_unix_time_from_system(),
        "command_count": 0,
        "status": "active"
    }
    
    # Initialize history
    terminal_history[terminal_id] = []
    
    # Apply settings
    terminal_settings[terminal_id] = settings
    
    # Set default color
    if not settings.has("color") and terminal_colors.has(terminal_id):
        terminal_settings[terminal_id]["color"] = terminal_colors[terminal_id]
    elif not settings.has("color"):
        terminal_settings[terminal_id]["color"] = terminal_colors["default"]
    
    # Emit signal
    emit_signal("terminal_created", terminal_id)
    
    return "Terminal '" + terminal_id + "' created"

func close_terminal(terminal_id):
    if not active_terminals.has(terminal_id):
        return "Terminal '" + terminal_id + "' not found"
    
    # Check if we have at least one terminal left
    if active_terminals.size() <= 1:
        return "Cannot close the last terminal"
    
    # Remove terminal
    active_terminals.erase(terminal_id)
    
    # Change focus if needed
    if focused_terminal == terminal_id:
        set_focus(active_terminals.keys()[0])
    
    # Emit signal
    emit_signal("terminal_closed", terminal_id)
    
    return "Terminal '" + terminal_id + "' closed"

func set_focus(terminal_id):
    if not active_terminals.has(terminal_id):
        return "Terminal '" + terminal_id + "' not found"
    
    var previous = focused_terminal
    focused_terminal = terminal_id
    
    # Update last active time
    active_terminals[terminal_id]["last_active"] = Time.get_unix_time_from_system()
    
    # Emit signal
    emit_signal("terminal_focus_changed", terminal_id)
    
    return "Focus changed from '" + previous + "' to '" + terminal_id + "'"

func process_command(command, terminal_id=null):
    if terminal_id == null:
        terminal_id = focused_terminal
    
    if not active_terminals.has(terminal_id):
        return "Terminal '" + terminal_id + "' not found"
    
    # Update statistics
    active_terminals[terminal_id]["command_count"] += 1
    active_terminals[terminal_id]["last_active"] = Time.get_unix_time_from_system()
    
    # Add to history
    terminal_history[terminal_id].append({
        "command": command,
        "timestamp": Time.get_unix_time_from_system()
    })
    
    # Process the command through EdenCore
    var result = ""
    if has_node("/root/EdenCore"):
        result = get_node("/root/EdenCore").process_command(command, terminal_id)
    else:
        result = "EdenCore not found - command not processed"
    
    # Check for terminal-specific commands
    var parts = command.strip_edges().split(" ", false)
    var cmd = parts[0].to_lower()
    var args = parts.slice(1)
    
    if cmd == "terminal":
        result = process_terminal_command(args, terminal_id)
    
    # Emit signal
    emit_signal("terminal_command_executed", terminal_id, command, result)
    
    return result

func process_terminal_command(args, terminal_id):
    if args.size() == 0:
        return "Terminal System. Current terminal: " + terminal_id + "\nUse 'terminal create', 'terminal close', 'terminal focus', 'terminal list', 'terminal layout'"
    
    match args[0]:
        "create":
            if args.size() < 2:
                return "Usage: terminal create <id>"
                
            return create_terminal(args[1])
        "close":
            if args.size() < 2:
                return "Usage: terminal close <id>"
                
            return close_terminal(args[1])
        "focus":
            if args.size() < 2:
                return "Usage: terminal focus <id>"
                
            return set_focus(args[1])
        "list":
            return list_terminals()
        "layout":
            if args.size() < 2:
                return "Current layout: " + current_layout + "\nAvailable layouts: " + ", ".join(terminal_layouts.keys())
                
            return apply_layout(args[1])
        "color":
            if args.size() < 2:
                return "Current color: " + str(terminal_settings[terminal_id]["color"]) + "\nUsage: terminal color <r> <g> <b>"
                
            if args.size() >= 4:
                var r = float(args[1])
                var g = float(args[2])
                var b = float(args[3])
                
                terminal_settings[terminal_id]["color"] = Color(r, g, b)
                return "Terminal color changed"
            else:
                return "Usage: terminal color <r> <g> <b> (values from 0.0 to 1.0)"
        "clear":
            # This would normally clear the terminal display
            return "Terminal cleared"
        "info":
            return get_terminal_info(terminal_id)
        _:
            return "Unknown terminal command: " + args[0]

func list_terminals():
    var result = "Active Terminals (" + str(active_terminals.size()) + "/" + str(MAX_TERMINALS) + "):\n"
    
    for id in active_terminals:
        var status = " "
        if id == focused_terminal:
            status = "*"
            
        result += status + " " + id + " - Commands: " + str(active_terminals[id]["command_count"]) + "\n"
    
    return result

func get_terminal_info(terminal_id):
    if not active_terminals.has(terminal_id):
        return "Terminal '" + terminal_id + "' not found"
    
    var result = "Terminal: " + terminal_id + "\n"
    result += "Status: " + active_terminals[terminal_id]["status"] + "\n"
    result += "Created: " + str(Time.get_datetime_string_from_unix_time(active_terminals[terminal_id]["created"])) + "\n"
    result += "Last Active: " + str(Time.get_datetime_string_from_unix_time(active_terminals[terminal_id]["last_active"])) + "\n"
    result += "Commands Executed: " + str(active_terminals[terminal_id]["command_count"]) + "\n"
    
    if terminal_settings.has(terminal_id):
        result += "Color: " + str(terminal_settings[terminal_id]["color"]) + "\n"
    
    if terminal_history.has(terminal_id) and terminal_history[terminal_id].size() > 0:
        result += "\nLast 5 Commands:\n"
        
        var history = terminal_history[terminal_id]
        var start = max(0, history.size() - 5)
        
        for i in range(start, history.size()):
            var timestamp = Time.get_datetime_string_from_unix_time(history[i]["timestamp"])
            result += timestamp + ": " + history[i]["command"] + "\n"
    
    return result

func apply_layout(layout_name):
    if not terminal_layouts.has(layout_name):
        return "Unknown layout: " + layout_name
    
    current_layout = layout_name
    
    # In a real implementation, this would rearrange the terminal UI
    # For this simulation, we just return the layout description
    
    var layout = terminal_layouts[layout_name]
    var description = "Applied layout: " + layout_name + "\n"
    
    match layout_name:
        "horizontal":
            description += "Terminals arranged horizontally with distribution: " + str(layout["distribution"])
        "vertical":
            description += "Terminals arranged vertically with distribution: " + str(layout["distribution"])
        "grid":
            description += "Terminals arranged in a " + str(layout["rows"]) + "x" + str(layout["columns"]) + " grid"
        "main_with_sidebars":
            description += "Main terminal (" + str(layout["main"] * 100) + "%) with sidebars (" + str(layout["sides"] * 100) + "% each)"
    
    return description

func output_to_terminal(terminal_id, text):
    if not active_terminals.has(terminal_id):
        return false
    
    # Emit signal
    emit_signal("terminal_output", terminal_id, text)
    
    return true

func split_terminal(terminal_id, direction="horizontal"):
    if not active_terminals.has(terminal_id):
        return "Terminal '" + terminal_id + "' not found"
    
    if active_terminals.size() >= MAX_TERMINALS:
        return "Maximum number of terminals reached (" + str(MAX_TERMINALS) + ")"
    
    # Create new terminal
    var new_id = terminal_id + "_" + str(active_terminals.size() + 1)
    create_terminal(new_id)
    
    # Apply split layout
    var result = "Terminal '" + terminal_id + "' split " + direction + "ly\n"
    result += "New terminal: '" + new_id + "'"
    
    return result

func set_container_node(node):
    container_node = node

func register_terminal_node(terminal_id, node):
    terminal_nodes[terminal_id] = node