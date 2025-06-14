extends Node

class_name TerminalTunnelControl

signal command_executed(command, result)
signal log_message(message, level)

# Terminal configuration
const TERMINAL_PROMPT = "tunnel> "
const MAX_COMMAND_HISTORY = 50
const LOG_LEVELS = {
    "info": Color(0.2, 0.7, 1.0),
    "success": Color(0.2, 0.9, 0.4),
    "warning": Color(1.0, 0.8, 0.0),
    "error": Color(1.0, 0.3, 0.3),
    "system": Color(0.8, 0.8, 0.8)
}

# Command history
var command_history = []
var history_position = -1

# Terminal state
var terminal_visible = false
var input_locked = false
var command_in_progress = false

# References
var tunnel_controller
var ethereal_tunnel_manager
var tunnel_visualizer
var desktop_connector

# UI elements
var terminal_panel
var terminal_output
var command_input
var status_bar

# Command handlers
var command_handlers = {}

# Auto-completion
var command_suggestions = []
var current_suggestion_index = -1

func _ready():
    # Set up UI elements
    _setup_terminal_ui()
    
    # Register commands
    _register_commands()
    
    # Auto-detect components
    _detect_components()
    
    # Connect signals
    _connect_signals()
    
    # Start with terminal hidden
    toggle_terminal(false)

func _setup_terminal_ui():
    # Create main panel
    terminal_panel = Panel.new()
    terminal_panel.anchor_right = 1.0
    terminal_panel.anchor_bottom = 0.5  # Take up half the screen
    terminal_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    terminal_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    
    # Add style
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
    style.border_width_bottom = 2
    style.border_color = Color(0.3, 0.6, 1.0)
    terminal_panel.add_theme_stylebox_override("panel", style)
    
    # Create VBox for layout
    var vbox = VBoxContainer.new()
    vbox.anchor_right = 1.0
    vbox.anchor_bottom = 1.0
    vbox.margin_left = 10
    vbox.margin_right = -10
    vbox.margin_top = 10
    vbox.margin_bottom = -10
    terminal_panel.add_child(vbox)
    
    # Terminal output (rich text label)
    terminal_output = RichTextLabel.new()
    terminal_output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    terminal_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
    terminal_output.bbcode_enabled = true
    terminal_output.scroll_following = true
    terminal_output.threaded = true
    vbox.add_child(terminal_output)
    
    # Command input
    var input_hbox = HBoxContainer.new()
    input_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.add_child(input_hbox)
    
    var prompt_label = Label.new()
    prompt_label.text = TERMINAL_PROMPT
    prompt_label.theme.set_color("font_color", "Label", Color(0.3, 0.7, 1.0))
    input_hbox.add_child(prompt_label)
    
    command_input = LineEdit.new()
    command_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    command_input.caret_blink = true
    command_input.theme.set_color("font_color", "LineEdit", Color(0.9, 0.9, 0.95))
    command_input.theme.set_color("caret_color", "LineEdit", Color(1, 1, 1))
    var input_style = StyleBoxFlat.new()
    input_style.bg_color = Color(0.15, 0.15, 0.2)
    input_style.border_width_left = 0
    input_style.border_width_right = 0
    input_style.border_width_top = 0
    input_style.border_width_bottom = 1
    input_style.border_color = Color(0.3, 0.7, 1.0)
    command_input.add_theme_stylebox_override("normal", input_style)
    input_hbox.add_child(command_input)
    
    # Status bar
    status_bar = Label.new()
    status_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    status_bar.theme.set_color("font_color", "Label", Color(0.7, 0.7, 0.7))
    status_bar.text = "Tunnel Terminal v1.0 - Type 'help' for commands"
    vbox.add_child(status_bar)
    
    # Add everything to the scene
    add_child(terminal_panel)
    
    # Connect input signals
    command_input.connect("text_submitted", Callable(self, "_on_command_submitted"))
    command_input.connect("gui_input", Callable(self, "_on_input_key"))

func _register_commands():
    # Basic commands
    command_handlers["help"] = {
        "function": "_cmd_help",
        "description": "Display available commands",
        "usage": "help [command]",
        "args": 0
    }
    
    command_handlers["clear"] = {
        "function": "_cmd_clear",
        "description": "Clear the terminal",
        "usage": "clear",
        "args": 0
    }
    
    command_handlers["exit"] = {
        "function": "_cmd_exit",
        "description": "Hide the terminal",
        "usage": "exit",
        "args": 0
    }
    
    # System commands
    command_handlers["status"] = {
        "function": "_cmd_status",
        "description": "Show tunnel system status",
        "usage": "status",
        "args": 0
    }
    
    command_handlers["turn"] = {
        "function": "_cmd_turn",
        "description": "Advance to next turn or show current turn",
        "usage": "turn [advance]",
        "args": 0
    }
    
    command_handlers["dimension"] = {
        "function": "_cmd_dimension",
        "description": "Shift to a new dimension or show current dimension",
        "usage": "dimension [1-9]",
        "args": 0
    }
    
    command_handlers["energy"] = {
        "function": "_cmd_energy",
        "description": "Show current energy levels",
        "usage": "energy",
        "args": 0
    }
    
    # Anchor commands
    command_handlers["anchors"] = {
        "function": "_cmd_anchors",
        "description": "List all dimensional anchors",
        "usage": "anchors",
        "args": 0
    }
    
    command_handlers["anchor"] = {
        "function": "_cmd_anchor",
        "description": "Create, modify or get anchor info",
        "usage": "anchor <name> [x y z] [type]",
        "args": 1
    }
    
    # Tunnel commands
    command_handlers["tunnels"] = {
        "function": "_cmd_tunnels",
        "description": "List all tunnels",
        "usage": "tunnels [filter]",
        "args": 0
    }
    
    command_handlers["tunnel"] = {
        "function": "_cmd_tunnel",
        "description": "Create or manipulate tunnels",
        "usage": "tunnel <create|collapse|info> [arguments]",
        "args": 1
    }
    
    command_handlers["transfer"] = {
        "function": "_cmd_transfer",
        "description": "Transfer data through a tunnel",
        "usage": "transfer <tunnel_id> <data>",
        "args": 2
    }
    
    # Desktop integration commands
    command_handlers["desktop"] = {
        "function": "_cmd_desktop",
        "description": "Manage desktop connection",
        "usage": "desktop <connect|disconnect|status|dir>",
        "args": 1
    }
    
    # Visual commands
    command_handlers["visual"] = {
        "function": "_cmd_visual",
        "description": "Control visualization settings",
        "usage": "visual <quality|color|effects> [arguments]",
        "args": 1
    }
    
    command_handlers["focus"] = {
        "function": "_cmd_focus",
        "description": "Focus camera on a tunnel or anchor",
        "usage": "focus <tunnel|anchor> <id>",
        "args": 2
    }

func _detect_components():
    # Find tunnel controller
    if not tunnel_controller:
        var potential_controllers = get_tree().get_nodes_in_group("tunnel_controllers")
        if potential_controllers.size() > 0:
            tunnel_controller = potential_controllers[0]
            print("Automatically found tunnel controller: " + tunnel_controller.name)
    
    # Get references from controller
    if tunnel_controller:
        ethereal_tunnel_manager = tunnel_controller.ethereal_tunnel_manager
        tunnel_visualizer = tunnel_controller.tunnel_visualizer
    
    # Look for desktop connector
    if not desktop_connector:
        var potential_connectors = get_tree().get_nodes_in_group("desktop_connectors")
        if potential_connectors.size() > 0:
            desktop_connector = potential_connectors[0]
            print("Automatically found desktop connector: " + desktop_connector.name)

func _connect_signals():
    # Connect to tunnel controller signals
    if tunnel_controller:
        tunnel_controller.connect("connection_status_changed", Callable(self, "_on_connection_status_changed"))
        tunnel_controller.connect("tunnel_transfer_completed", Callable(self, "_on_tunnel_transfer_completed"))
    
    # Connect to desktop connector signals
    if desktop_connector:
        desktop_connector.connect("file_transfer_started", Callable(self, "_on_file_transfer_started"))
        desktop_connector.connect("file_transfer_completed", Callable(self, "_on_file_transfer_completed"))
        desktop_connector.connect("desktop_notification", Callable(self, "_on_desktop_notification"))

func _input(event):
    # Toggle terminal with grave key (tilde/backtick)
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_QUOTELEFT or event.keycode == KEY_ASCIITILDE:
            toggle_terminal(!terminal_visible)
            get_viewport().set_input_as_handled()

func toggle_terminal(visible):
    terminal_visible = visible
    terminal_panel.visible = visible
    
    if visible:
        # Show and focus input
        command_input.grab_focus()
        
        # Update status
        update_status()
    else:
        # Hide and reset
        command_input.text = ""
        history_position = -1

func update_status():
    if not tunnel_controller:
        status_bar.text = "No tunnel controller found"
        return
    
    var dimension_info = tunnel_controller.get_current_dimension()
    var turn_info = tunnel_controller.get_current_turn_info()
    var energy_info = tunnel_controller.get_energy_status()
    
    status_bar.text = "Dimension: " + str(dimension_info.dimension) + " | " +
                       "Turn: " + str(turn_info.turn) + " (" + turn_info.name + ") | " +
                       "Energy: " + str(int(energy_info.current)) + "/" + str(int(energy_info.max))

func _on_command_submitted(text):
    if text.strip_edges().empty() or input_locked:
        return
    
    # Add to output
    print_line(TERMINAL_PROMPT + text, "command")
    
    # Add to history
    add_to_history(text)
    
    # Process command
    execute_command(text)
    
    # Clear input
    command_input.text = ""
    history_position = -1
    
    # Update suggestions
    command_suggestions.clear()
    current_suggestion_index = -1

func _on_input_key(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_UP:
            # Navigate history up
            if command_history.size() > 0:
                if history_position < command_history.size() - 1:
                    history_position += 1
                    command_input.text = command_history[history_position]
                    command_input.caret_column = command_input.text.length()
            get_viewport().set_input_as_handled()
        
        elif event.keycode == KEY_DOWN:
            # Navigate history down
            if history_position > 0:
                history_position -= 1
                command_input.text = command_history[history_position]
                command_input.caret_column = command_input.text.length()
            elif history_position == 0:
                history_position = -1
                command_input.text = ""
            get_viewport().set_input_as_handled()
        
        elif event.keycode == KEY_TAB:
            # Auto-completion
            if command_suggestions.empty():
                # Generate suggestions based on current input
                generate_suggestions()
            
            if not command_suggestions.empty():
                # Cycle through suggestions
                current_suggestion_index = (current_suggestion_index + 1) % command_suggestions.size()
                command_input.text = command_suggestions[current_suggestion_index]
                command_input.caret_column = command_input.text.length()
            
            get_viewport().set_input_as_handled()

func add_to_history(command):
    # Add at the beginning
    command_history.push_front(command)
    
    # Trim if too large
    if command_history.size() > MAX_COMMAND_HISTORY:
        command_history.resize(MAX_COMMAND_HISTORY)
    
    # Reset position
    history_position = -1

func generate_suggestions():
    var input_text = command_input.text.strip_edges()
    command_suggestions.clear()
    
    if input_text.empty():
        return
    
    # Check for partial command
    var parts = input_text.split(" ", false)
    var cmd = parts[0]
    
    if parts.size() == 1:
        # Suggesting command names
        for command_name in command_handlers.keys():
            if command_name.begins_with(cmd):
                command_suggestions.push_back(command_name)
    else:
        # Suggesting arguments based on command
        if command_handlers.has(cmd):
            var handler = command_handlers[cmd]
            
            match cmd:
                "anchor":
                    if parts.size() == 2:
                        # Suggest existing anchor names
                        for anchor_id in ethereal_tunnel_manager.get_anchors():
                            if anchor_id.begins_with(parts[1]):
                                command_suggestions.push_back(cmd + " " + anchor_id)
                
                "tunnel":
                    if parts.size() == 2:
                        # Suggest subcommands
                        var subcmds = ["create", "collapse", "info"]
                        for subcmd in subcmds:
                            if subcmd.begins_with(parts[1]):
                                command_suggestions.push_back(cmd + " " + subcmd)
                    elif parts.size() == 3 and parts[1] == "collapse":
                        # Suggest tunnel IDs for collapse
                        for tunnel_id in ethereal_tunnel_manager.get_tunnels():
                            if tunnel_id.begins_with(parts[2]):
                                command_suggestions.push_back(cmd + " " + parts[1] + " " + tunnel_id)
                
                "focus":
                    if parts.size() == 2:
                        # Suggest target types
                        var targets = ["tunnel", "anchor"]
                        for target in targets:
                            if target.begins_with(parts[1]):
                                command_suggestions.push_back(cmd + " " + target)
                    elif parts.size() == 3:
                        if parts[1] == "tunnel":
                            # Suggest tunnel IDs
                            for tunnel_id in ethereal_tunnel_manager.get_tunnels():
                                if tunnel_id.begins_with(parts[2]):
                                    command_suggestions.push_back(cmd + " " + parts[1] + " " + tunnel_id)
                        elif parts[1] == "anchor":
                            # Suggest anchor IDs
                            for anchor_id in ethereal_tunnel_manager.get_anchors():
                                if anchor_id.begins_with(parts[2]):
                                    command_suggestions.push_back(cmd + " " + parts[1] + " " + anchor_id)
                
                "dimension":
                    if parts.size() == 2:
                        # Suggest dimensions 1-9
                        for i in range(1, 10):
                            if str(i).begins_with(parts[1]):
                                command_suggestions.push_back(cmd + " " + str(i))
                
                "desktop":
                    if parts.size() == 2:
                        # Suggest subcommands
                        var subcmds = ["connect", "disconnect", "status", "dir"]
                        for subcmd in subcmds:
                            if subcmd.begins_with(parts[1]):
                                command_suggestions.push_back(cmd + " " + subcmd)
                
                "visual":
                    if parts.size() == 2:
                        # Suggest subcommands
                        var subcmds = ["quality", "color", "effects"]
                        for subcmd in subcmds:
                            if subcmd.begins_with(parts[1]):
                                command_suggestions.push_back(cmd + " " + subcmd)
    
    # Sort suggestions
    command_suggestions.sort()
    current_suggestion_index = -1

func execute_command(command_text):
    var parts = command_text.strip_edges().split(" ", false)
    if parts.size() == 0:
        return
    
    var cmd = parts[0].to_lower()
    var args = parts.slice(1)
    
    if command_handlers.has(cmd):
        var handler = command_handlers[cmd]
        
        # Check if we have minimum required args
        if args.size() < handler.args:
            print_line("Error: Not enough arguments. Usage: " + handler.usage, "error")
            return
        
        # Lock input during command execution
        input_locked = true
        command_in_progress = true
        
        # Call handler method
        var method = handler.function
        var result
        
        if args.size() > 0:
            result = call(method, args)
        else:
            result = call(method)
        
        # Unlock input
        input_locked = false
        command_in_progress = false
        
        # Emit signal
        emit_signal("command_executed", command_text, result)
        
        # Update status after command
        update_status()
    else:
        print_line("Unknown command: " + cmd, "error")
        print_line("Type 'help' for available commands", "info")

func print_line(text, level = "system"):
    var color_code = LOG_LEVELS.get(level, Color(1, 1, 1))
    var color_tag = "[color=#" + color_code.to_html(false) + "]"
    
    terminal_output.append_text(color_tag + text + "[/color]\n")
    emit_signal("log_message", text, level)

# Command handler methods

func _cmd_help(args = []):
    if args.size() == 0:
        # List all commands
        print_line("Available commands:", "info")
        
        var command_list = command_handlers.keys()
        command_list.sort()
        
        for cmd in command_list:
            var handler = command_handlers[cmd]
            print_line("  " + cmd.ljust(12) + " - " + handler.description)
        
        print_line("\nType 'help <command>' for usage details", "info")
    else:
        # Show help for specific command
        var cmd = args[0].to_lower()
        
        if command_handlers.has(cmd):
            var handler = command_handlers[cmd]
            print_line("Command: " + cmd, "info")
            print_line("Description: " + handler.description)
            print_line("Usage: " + handler.usage)
        else:
            print_line("Unknown command: " + cmd, "error")
    
    return true

func _cmd_clear():
    terminal_output.clear()
    return true

func _cmd_exit():
    toggle_terminal(false)
    return true

func _cmd_status():
    if not tunnel_controller:
        print_line("Error: No tunnel controller found", "error")
        return false
    
    print_line("Tunnel System Status:", "info")
    
    # Dimension info
    var dimension_info = tunnel_controller.get_current_dimension()
    print_line("Current Dimension: " + str(dimension_info.dimension))
    
    # Turn info
    var turn_info = tunnel_controller.get_current_turn_info()
    print_line("Current Turn: " + str(turn_info.turn) + " - " + turn_info.name)
    
    var effect_text = "Effects: "
    for effect in turn_info.effects:
        if effect != "name":
            effect_text += effect + "=" + str(turn_info.effects[effect]) + " "
    print_line(effect_text)
    
    # Energy info
    var energy_info = tunnel_controller.get_energy_status()
    print_line("Energy: " + str(int(energy_info.current)) + "/" + str(int(energy_info.max)) + 
               " (" + str(int(energy_info.percentage)) + "%)")
    
    # System stats
    var anchor_count = ethereal_tunnel_manager.get_anchors().size()
    var tunnel_count = ethereal_tunnel_manager.get_tunnels().size()
    
    print_line("Anchors: " + str(anchor_count) + ", Tunnels: " + str(tunnel_count))
    
    # Desktop connection
    if desktop_connector:
        var desktop_status = desktop_connector.get_connection_status()
        var status_text = "Desktop Connection: "
        
        match desktop_status.state:
            0: status_text += "Disconnected"
            1: status_text += "Connecting..."
            2: status_text += "Connected (" + str(desktop_status.watched_directories.size()) + " directories)"
            3: status_text += "Error: " + desktop_status.error
        
        print_line(status_text)
    
    return true

func _cmd_turn(args = []):
    if not tunnel_controller:
        print_line("Error: No tunnel controller found", "error")
        return false
    
    if args.size() == 0 or args[0] != "advance":
        # Show current turn info
        var turn_info = tunnel_controller.get_current_turn_info()
        print_line("Current Turn: " + str(turn_info.turn) + " - " + turn_info.name, "info")
        
        print_line("Effects:")
        for effect in turn_info.effects:
            if effect != "name":
                print_line("  " + effect + ": " + str(turn_info.effects[effect]))
        
        print_line("\nUse 'turn advance' to advance to the next turn", "info")
    else:
        # Advance turn
        var new_turn_info = tunnel_controller.advance_turn()
        print_line("Advanced to Turn: " + str(new_turn_info.turn) + " - " + new_turn_info.name, "success")
    
    return true

func _cmd_dimension(args = []):
    if not tunnel_controller:
        print_line("Error: No tunnel controller found", "error")
        return false
    
    if args.size() == 0:
        # Show current dimension
        var dimension_info = tunnel_controller.get_current_dimension()
        print_line("Current Dimension: " + str(dimension_info.dimension), "info")
        
        var color_hex = dimension_info.color.to_html(false)
        print_line("Color: #" + color_hex)
        
        print_line("\nUse 'dimension <1-9>' to shift dimensions", "info")
    else:
        # Try to shift dimension
        var target_dim = int(args[0])
        
        if target_dim < 1 or target_dim > 9:
            print_line("Error: Dimension must be between 1 and 9", "error")
            return false
        
        var current_dim = tunnel_controller.get_current_dimension().dimension
        
        if target_dim == current_dim:
            print_line("Already in dimension " + str(target_dim), "warning")
            return true
        
        var result = tunnel_controller.shift_dimension(target_dim)
        
        if result:
            print_line("Shifted to dimension " + str(target_dim), "success")
            
            // Update tunnels with color transitions
            if tunnel_visualizer and tunnel_visualizer.has_method("start_color_transition"):
                for tunnel_id in ethereal_tunnel_manager.get_tunnels():
                    tunnel_visualizer.start_color_transition(tunnel_id, target_dim, 1.0)
        else:
            print_line("Failed to shift to dimension " + str(target_dim), "error")
    
    return true

func _cmd_energy():
    if not tunnel_controller:
        print_line("Error: No tunnel controller found", "error")
        return false
    
    var energy_info = tunnel_controller.get_energy_status()
    
    print_line("Energy Status:", "info")
    print_line("Current: " + str(int(energy_info.current)) + " / " + str(int(energy_info.max)))
    print_line("Percentage: " + str(int(energy_info.percentage)) + "%")
    
    // Add energy usage info
    print_line("\nEnergy Costs:")
    print_line("  Dimension Shift: " + str(tunnel_controller.DIMENSION_SHIFT_COST) + " per dimension level")
    print_line("  Tunnel Establishment: " + str(tunnel_controller.BASE_TRANSFER_COST) + " + distance + dimension")
    print_line("  Data Transfer: 0.05 per character / stability")
    
    return true

func _cmd_anchors():
    if not ethereal_tunnel_manager:
        print_line("Error: No tunnel manager found", "error")
        return false
    
    var anchors = ethereal_tunnel_manager.get_anchors()
    
    if anchors.size() == 0:
        print_line("No anchors registered", "warning")
        return true
    
    print_line("Registered Anchors (" + str(anchors.size()) + "):", "info")
    
    for anchor_id in anchors:
        var anchor_data = ethereal_tunnel_manager.get_anchor_data(anchor_id)
        
        if anchor_data:
            var coords = anchor_data.coordinates
            var type = anchor_data.type if anchor_data.has("type") else "unknown"
            
            var tunnels = ethereal_tunnel_manager.get_tunnels_for_anchor(anchor_id)
            var tunnel_count = tunnels.size()
            
            print_line(anchor_id + " (" + type + ")")
            print_line("  Coords: (" + str(coords.x).pad_decimals(2) + ", " + 
                                       str(coords.y).pad_decimals(2) + ", " + 
                                       str(coords.z).pad_decimals(2) + ")")
            print_line("  Tunnels: " + str(tunnel_count))
    
    return true

func _cmd_anchor(args):
    if not ethereal_tunnel_manager:
        print_line("Error: No tunnel manager found", "error")
        return false
    
    var anchor_id = args[0]
    
    if args.size() == 1:
        // Show anchor info
        if ethereal_tunnel_manager.has_anchor(anchor_id):
            var anchor_data = ethereal_tunnel_manager.get_anchor_data(anchor_id)
            
            print_line("Anchor: " + anchor_id, "info")
            
            var coords = anchor_data.coordinates
            var type = anchor_data.type if anchor_data.has("type") else "unknown"
            
            print_line("Type: " + type)
            print_line("Coordinates: (" + str(coords.x).pad_decimals(2) + ", " + 
                                        str(coords.y).pad_decimals(2) + ", " + 
                                        str(coords.z).pad_decimals(2) + ")")
            
            // List connected tunnels
            var tunnels = ethereal_tunnel_manager.get_tunnels_for_anchor(anchor_id)
            print_line("Connected Tunnels (" + str(tunnels.size()) + "):")
            
            for tunnel_id in tunnels:
                var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
                var other_end = tunnel_data.source if tunnel_data.target == anchor_id else tunnel_data.target
                print_line("  " + tunnel_id + " -> " + other_end)
        else:
            print_line("Anchor not found: " + anchor_id, "error")
    else:
        // Create or update anchor
        var coords = Vector3.ZERO
        var type = "custom"
        
        if args.size() >= 4:
            // Parse coordinates
            coords.x = float(args[1])
            coords.y = float(args[2])
            coords.z = float(args[3])
            
            if args.size() >= 5:
                type = args[4]
        
        // Register or update anchor
        var anchor_data = ethereal_tunnel_manager.register_anchor(anchor_id, coords, type)
        
        if anchor_data:
            print_line("Anchor " + anchor_id + " registered successfully", "success")
        else:
            print_line("Failed to register anchor " + anchor_id, "error")
    
    return true

func _cmd_tunnels(args = []):
    if not ethereal_tunnel_manager:
        print_line("Error: No tunnel manager found", "error")
        return false
    
    var tunnels = ethereal_tunnel_manager.get_tunnels()
    
    if tunnels.size() == 0:
        print_line("No tunnels established", "warning")
        return true
    
    var filter = ""
    if args.size() > 0:
        filter = args[0]
    
    var filtered_tunnels = []
    for tunnel_id in tunnels:
        if filter.empty() or tunnel_id.find(filter) >= 0:
            filtered_tunnels.push_back(tunnel_id)
    
    print_line("Tunnels (" + str(filtered_tunnels.size()) + "/" + str(tunnels.size()) + "):", "info")
    
    for tunnel_id in filtered_tunnels:
        var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
        
        var source = tunnel_data.source
        var target = tunnel_data.target
        var dimension = tunnel_data.dimension
        var stability = tunnel_data.stability
        var active = tunnel_data.active
        
        var status = "Active" if active else "Inactive"
        var stab_str = str(stability).pad_decimals(2)
        
        print_line(tunnel_id + " (Dim: " + str(dimension) + ", Stab: " + stab_str + ", " + status + ")")
        print_line("  " + source + " -> " + target)
    
    return true

func _cmd_tunnel(args):
    if not ethereal_tunnel_manager or not tunnel_controller:
        print_line("Error: Required components not found", "error")
        return false
    
    var subcommand = args[0].to_lower()
    
    match subcommand:
        "create":
            if args.size() < 3:
                print_line("Error: Not enough arguments", "error")
                print_line("Usage: tunnel create <source_anchor> <target_anchor> [dimension]", "info")
                return false
            
            var source = args[1]
            var target = args[2]
            
            var dimension = tunnel_controller.current_dimension
            if args.size() >= 4:
                dimension = int(args[3])
            
            if not ethereal_tunnel_manager.has_anchor(source):
                print_line("Error: Source anchor not found: " + source, "error")
                return false
            
            if not ethereal_tunnel_manager.has_anchor(target):
                print_line("Error: Target anchor not found: " + target, "error")
                return false
            
            var tunnel = tunnel_controller.establish_tunnel(source, target)
            
            if tunnel:
                print_line("Tunnel established: " + tunnel.id, "success")
            else:
                print_line("Failed to establish tunnel", "error")
        
        "collapse":
            if args.size() < 2:
                print_line("Error: Not enough arguments", "error")
                print_line("Usage: tunnel collapse <tunnel_id>", "info")
                return false
            
            var tunnel_id = args[1]
            
            if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
                print_line("Error: Tunnel not found: " + tunnel_id, "error")
                return false
            
            var result = tunnel_controller.collapse_tunnel(tunnel_id)
            
            if result:
                print_line("Tunnel collapsed: " + tunnel_id, "success")
            else:
                print_line("Failed to collapse tunnel", "error")
        
        "info":
            if args.size() < 2:
                print_line("Error: Not enough arguments", "error")
                print_line("Usage: tunnel info <tunnel_id>", "info")
                return false
            
            var tunnel_id = args[1]
            
            if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
                print_line("Error: Tunnel not found: " + tunnel_id, "error")
                return false
            
            var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
            
            print_line("Tunnel: " + tunnel_id, "info")
            print_line("Source: " + tunnel_data.source)
            print_line("Target: " + tunnel_data.target)
            print_line("Dimension: " + str(tunnel_data.dimension))
            print_line("Stability: " + str(tunnel_data.stability).pad_decimals(2))
            print_line("Status: " + ("Active" if tunnel_data.active else "Inactive"))
            
            if tunnel_data.has("established"):
                var time_str = Time.get_datetime_string_from_unix_time(tunnel_data.established)
                print_line("Established: " + time_str)
            
            if tunnel_data.has("length"):
                print_line("Length: " + str(tunnel_data.length).pad_decimals(2))
        
        _:
            print_line("Error: Unknown subcommand: " + subcommand, "error")
            print_line("Available subcommands: create, collapse, info", "info")
            return false
    
    return true

func _cmd_transfer(args):
    if not tunnel_controller:
        print_line("Error: No tunnel controller found", "error")
        return false
    
    var tunnel_id = args[0]
    var content = args[1]
    
    // Handle multi-word content
    if args.size() > 2:
        content = ""
        for i in range(1, args.size()):
            if content.length() > 0:
                content += " "
            content += args[i]
    
    if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
        print_line("Error: Tunnel not found: " + tunnel_id, "error")
        return false
    
    print_line("Starting transfer through tunnel: " + tunnel_id, "info")
    
    var result = tunnel_controller.transfer_through_tunnel(tunnel_id, content)
    
    if result:
        print_line("Transfer queued (" + str(content.length()) + " characters)", "success")
    else:
        print_line("Failed to initiate transfer", "error")
    
    return result

func _cmd_desktop(args):
    if not desktop_connector:
        print_line("Error: No desktop connector found", "error")
        return false
    
    var subcommand = args[0].to_lower()
    
    match subcommand:
        "connect":
            print_line("Connecting to desktop environment...", "info")
            
            var result = desktop_connector.connect_to_desktop()
            
            if result:
                print_line("Connected to desktop environment", "success")
                
                var status = desktop_connector.get_connection_status()
                print_line("Watching " + str(status.watched_directories.size()) + " directories")
            else:
                var status = desktop_connector.get_connection_status()
                print_line("Connection failed: " + status.error, "error")
        
        "disconnect":
            print_line("Disconnecting from desktop environment...", "info")
            
            desktop_connector.disconnect_from_desktop()
            print_line("Disconnected from desktop environment", "success")
        
        "status":
            var status = desktop_connector.get_connection_status()
            
            print_line("Desktop Connection Status:", "info")
            
            var state_text = ""
            match status.state:
                0: state_text = "Disconnected"
                1: state_text = "Connecting..."
                2: state_text = "Connected"
                3: state_text = "Error: " + status.error
            
            print_line("State: " + state_text)
            
            if status.state == 2:  // Connected
                print_line("Watched Directories (" + str(status.watched_directories.size()) + "):")
                for dir in status.watched_directories:
                    print_line("  " + dir)
                
                print_line("Registered Anchors: " + str(status.registered_anchors))
                print_line("Active Transfers: " + str(status.active_transfers))
                print_line("Pending Transfers: " + str(status.pending_transfers))
                
                if status.last_sync > 0:
                    var time_str = Time.get_datetime_string_from_unix_time(status.last_sync)
                    print_line("Last Sync: " + time_str)
        
        "dir":
            if args.size() < 2:
                print_line("Error: Not enough arguments", "error")
                print_line("Usage: desktop dir <add|remove|list> [directory]", "info")
                return false
            
            var dir_command = args[1].to_lower()
            
            match dir_command:
                "add":
                    if args.size() < 3:
                        print_line("Error: Directory path required", "error")
                        return false
                    
                    var dir_path = args[2]
                    
                    var result = desktop_connector.add_watched_directory(dir_path)
                    
                    if result:
                        print_line("Added directory to watch list: " + dir_path, "success")
                    else:
                        print_line("Failed to add directory: " + dir_path, "error")
                
                "remove":
                    if args.size() < 3:
                        print_line("Error: Directory path required", "error")
                        return false
                    
                    var dir_path = args[2]
                    
                    var result = desktop_connector.remove_watched_directory(dir_path)
                    
                    if result:
                        print_line("Removed directory from watch list: " + dir_path, "success")
                    else:
                        print_line("Failed to remove directory: " + dir_path, "error")
                
                "list":
                    var status = desktop_connector.get_connection_status()
                    
                    print_line("Watched Directories (" + str(status.watched_directories.size()) + "):", "info")
                    for dir in status.watched_directories:
                        print_line("  " + dir)
                
                _:
                    print_line("Error: Unknown dir command: " + dir_command, "error")
                    print_line("Available commands: add, remove, list", "info")
                    return false
        
        _:
            print_line("Error: Unknown subcommand: " + subcommand, "error")
            print_line("Available subcommands: connect, disconnect, status, dir", "info")
            return false
    
    return true

func _cmd_visual(args):
    if not tunnel_visualizer:
        print_line("Error: No tunnel visualizer found", "error")
        return false
    
    var subcommand = args[0].to_lower()
    
    match subcommand:
        "quality":
            if args.size() < 2:
                // Show current quality
                var quality = 2  // Default medium
                
                if tunnel_visualizer.has_method("get_animation_quality"):
                    quality = tunnel_visualizer.get_animation_quality()
                
                var quality_name = ["Lowest", "Low", "Medium", "High", "Ultra"][quality]
                
                print_line("Current visual quality: " + quality_name + " (" + str(quality) + ")", "info")
                print_line("Use 'visual quality <0-4>' to change", "info")
            else:
                // Set quality
                var quality = int(args[1])
                quality = clamp(quality, 0, 4)
                
                if tunnel_visualizer.has_method("set_animation_quality"):
                    tunnel_visualizer.set_animation_quality(quality)
                    
                    var quality_name = ["Lowest", "Low", "Medium", "High", "Ultra"][quality]
                    print_line("Visual quality set to: " + quality_name, "success")
                else:
                    print_line("Visualizer doesn't support quality adjustment", "warning")
        
        "color":
            if args.size() < 2:
                print_line("Available color commands:", "info")
                print_line("  scheme - View or change color scheme")
                print_line("  flash <tunnel_id> - Create color flash effect")
                print_line("  transition <tunnel_id> <dimension> - Transition tunnel colors")
            else:
                var color_command = args[1].to_lower()
                
                match color_command:
                    "scheme":
                        if desktop_connector:
                            if args.size() < 3:
                                // Show available schemes
                                var schemes = desktop_connector.config.color_schemes.keys()
                                var active = desktop_connector.config.active_color_scheme
                                
                                print_line("Available color schemes:", "info")
                                for scheme in schemes:
                                    var prefix = "* " if scheme == active else "  "
                                    print_line(prefix + scheme)
                            else:
                                // Set scheme
                                var scheme_name = args[2]
                                
                                var result = desktop_connector.apply_color_scheme(scheme_name)
                                
                                if result:
                                    print_line("Applied color scheme: " + scheme_name, "success")
                                else:
                                    print_line("Unknown color scheme: " + scheme_name, "error")
                        else:
                            print_line("No desktop connector available", "error")
                    
                    "flash":
                        if args.size() < 3:
                            print_line("Error: Tunnel ID required", "error")
                            return false
                        
                        var tunnel_id = args[2]
                        
                        if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
                            print_line("Error: Tunnel not found: " + tunnel_id, "error")
                            return false
                        
                        if tunnel_visualizer.has_method("add_color_flash"):
                            var color = null
                            if args.size() >= 4:
                                // Parse color
                                var color_name = args[3]
                                
                                match color_name:
                                    "red": color = Color(1, 0, 0)
                                    "green": color = Color(0, 1, 0)
                                    "blue": color = Color(0, 0, 1)
                                    "yellow": color = Color(1, 1, 0)
                                    "cyan": color = Color(0, 1, 1)
                                    "magenta": color = Color(1, 0, 1)
                                    "white": color = Color(1, 1, 1)
                                    _: color = null
                            
                            tunnel_visualizer.add_color_flash(tunnel_id, color)
                            print_line("Added color flash to tunnel: " + tunnel_id, "success")
                        else:
                            print_line("Visualizer doesn't support color flash effect", "warning")
                    
                    "transition":
                        if args.size() < 4:
                            print_line("Error: Not enough arguments", "error")
                            print_line("Usage: visual color transition <tunnel_id> <dimension>", "info")
                            return false
                        
                        var tunnel_id = args[2]
                        var dimension = int(args[3])
                        
                        if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
                            print_line("Error: Tunnel not found: " + tunnel_id, "error")
                            return false
                        
                        if dimension < 1 or dimension > 9:
                            print_line("Error: Dimension must be between 1 and 9", "error")
                            return false
                        
                        if tunnel_visualizer.has_method("start_color_transition"):
                            tunnel_visualizer.start_color_transition(tunnel_id, dimension)
                            print_line("Started color transition for tunnel: " + tunnel_id, "success")
                        else:
                            print_line("Visualizer doesn't support color transitions", "warning")
                    
                    _:
                        print_line("Error: Unknown color command: " + color_command, "error")
                        return false
        
        "effects":
            if args.size() < 2:
                print_line("Available effects commands:", "info")
                print_line("  list - List available effects")
                print_line("  add <tunnel_id> <effect> - Add effect to tunnel")
                print_line("  clear <tunnel_id> - Clear effects from tunnel")
            else:
                var effect_command = args[1].to_lower()
                
                match effect_command:
                    "list":
                        print_line("Available visual effects:", "info")
                        print_line("  pulse - Energy pulse along tunnel")
                        print_line("  ripple - Ripple moving through tunnel")
                        print_line("  flash - Color flash effect")
                    
                    "add":
                        if args.size() < 4:
                            print_line("Error: Not enough arguments", "error")
                            print_line("Usage: visual effects add <tunnel_id> <effect>", "info")
                            return false
                        
                        var tunnel_id = args[2]
                        var effect = args[3].to_lower()
                        
                        if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
                            print_line("Error: Tunnel not found: " + tunnel_id, "error")
                            return false
                        
                        if tunnel_visualizer.has_method("_add_tunnel_pulse_animation") and effect == "pulse":
                            tunnel_visualizer._add_tunnel_pulse_animation(tunnel_id)
                            print_line("Added pulse effect to tunnel: " + tunnel_id, "success")
                        elif tunnel_visualizer.has_method("add_color_flash") and effect == "flash":
                            tunnel_visualizer.add_color_flash(tunnel_id)
                            print_line("Added flash effect to tunnel: " + tunnel_id, "success")
                        else:
                            print_line("Effect not supported: " + effect, "warning")
                    
                    "clear":
                        print_line("Effect clearing not implemented yet", "warning")
                    
                    _:
                        print_line("Error: Unknown effects command: " + effect_command, "error")
                        return false
        
        _:
            print_line("Error: Unknown subcommand: " + subcommand, "error")
            print_line("Available subcommands: quality, color, effects", "info")
            return false
    
    return true

func _cmd_focus(args):
    if not tunnel_visualizer:
        print_line("Error: No tunnel visualizer found", "error")
        return false
    
    var target_type = args[0].to_lower()
    var target_id = args[1]
    
    match target_type:
        "tunnel":
            if not ethereal_tunnel_manager.has_tunnel(target_id):
                print_line("Error: Tunnel not found: " + target_id, "error")
                return false
            
            if tunnel_visualizer.has_method("zoom_to_tunnel"):
                tunnel_visualizer.zoom_to_tunnel(target_id)
                print_line("Camera focused on tunnel: " + target_id, "success")
            else:
                print_line("Visualizer doesn't support tunnel focusing", "warning")
        
        "anchor":
            if not ethereal_tunnel_manager.has_anchor(target_id):
                print_line("Error: Anchor not found: " + target_id, "error")
                return false
            
            if tunnel_visualizer.has_method("zoom_to_anchor"):
                tunnel_visualizer.zoom_to_anchor(target_id)
                print_line("Camera focused on anchor: " + target_id, "success")
            else:
                print_line("Visualizer doesn't support anchor focusing", "warning")
        
        _:
            print_line("Error: Unknown target type: " + target_type, "error")
            print_line("Valid types: tunnel, anchor", "info")
            return false
    
    return true

# Signal handlers

func _on_connection_status_changed(status, message):
    var level = "info"
    
    match status:
        "success": level = "success"
        "error": level = "error"
        "warning": level = "warning"
    
    print_line(message, level)

func _on_tunnel_transfer_completed(tunnel_id, content):
    print_line("Transfer completed through tunnel: " + tunnel_id, "success")
    
    if content.length() < 50:
        print_line("Content: " + content)
    else:
        print_line("Content: " + content.substr(0, 47) + "... (" + str(content.length()) + " characters)")

func _on_file_transfer_started(source_file, target_file):
    print_line("File transfer started:", "info")
    print_line("  From: " + source_file)
    print_line("  To: " + target_file)

func _on_file_transfer_completed(source_file, target_file):
    print_line("File transfer completed:", "success")
    print_line("  From: " + source_file)
    print_line("  To: " + target_file)

func _on_desktop_notification(title, message, level):
    print_line(title + ": " + message, level)