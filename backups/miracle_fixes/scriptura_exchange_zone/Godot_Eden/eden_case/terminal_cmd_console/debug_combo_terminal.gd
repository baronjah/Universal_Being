extends Control

class_name DebugComboTerminal

"""
Debug Combo Terminal
A 2D terminal interface for rapidly navigating data seas with combo inputs
Visualizes drive contents and enables fast traversal through keyboard combos
"""

# Terminal display settings
var terminal_width = 80
var terminal_height = 24
var terminal_buffer = []
var terminal_color_codes = {}
var cursor_position = Vector2(0, 0)

# Input combo system
var combo_buffer = []
var combo_timeout = 1.0  # seconds
var last_input_time = 0.0
var active_combos = {}

# Data navigation
var current_path = ""
var search_results = []
var data_cache = {}
var view_mode = "list"  # list, tree, hex, preview
var filter_mode = ""    # extension filter like "*.txt"

# Debug state
var debug_enabled = true
var debug_level = 2  # 0=off, 1=minimal, 2=normal, 3=verbose
var command_history = []
var history_position = -1

# Performance tracking
var operation_times = {}
var frame_times = []
var last_frame_time = 0

# Signals
signal command_executed(command, success, result)
signal combo_activated(combo_name, params)
signal data_loaded(path, size)

func _ready():
    # Initialize terminal buffer
    _init_terminal_buffer()
    
    # Set up color codes
    _init_color_codes()
    
    # Register default combos
    _register_default_combos()
    
    # Initialize current path to user's home directory
    current_path = OS.get_executable_path().get_base_dir()
    
    # Display welcome message
    _print_welcome()
    
    # Display initial prompt
    _display_prompt()
    
    # Set up frame timer
    last_frame_time = Time.get_ticks_msec()

func _process(delta):
    # Track frame time for performance monitoring
    var current_time = Time.get_ticks_msec()
    var frame_duration = current_time - last_frame_time
    last_frame_time = current_time
    
    frame_times.append(frame_duration)
    if frame_times.size() > 60:  # Keep last 60 frames
        frame_times.remove_at(0)
    
    # Check for combo timeout
    if combo_buffer.size() > 0:
        if current_time - last_input_time > combo_timeout * 1000:
            # Reset combo buffer if timed out
            combo_buffer.clear()
            _update_status("Combo reset", "system")

func _input(event):
    if event is InputEventKey and event.pressed:
        _handle_keyboard_input(event)
    elif event is InputEventJoypadButton and event.pressed:
        _handle_joypad_input(event)

func _handle_keyboard_input(event):
    last_input_time = Time.get_ticks_msec()
    
    # Special keys
    if event.keycode == KEY_ENTER:
        _execute_current_line()
    elif event.keycode == KEY_BACKSPACE:
        _handle_backspace()
    elif event.keycode == KEY_UP:
        _history_previous()
    elif event.keycode == KEY_DOWN:
        _history_next()
    elif event.keycode == KEY_TAB:
        _handle_tab_completion()
    elif event.is_command_or_control_pressed() and event.keycode == KEY_C:
        _handle_ctrl_c()
    elif event.is_command_or_control_pressed() and event.keycode == KEY_L:
        _clear_terminal()
    elif event.is_command_or_control_pressed():
        # Add to combo buffer for combo commands
        var key_char = char(event.unicode)
        if key_char.length() > 0:
            combo_buffer.append("CTRL+" + key_char)
            _check_combos()
    else:
        # Regular character input
        var key_char = char(event.unicode)
        if key_char.length() > 0:
            _insert_character(key_char)

func _handle_joypad_input(event):
    last_input_time = Time.get_ticks_msec()
    
    # Map joypad buttons to combo inputs
    if event.button_index >= 0 and event.button_index < 16:
        var button_name = "JOY_" + str(event.button_index)
        combo_buffer.append(button_name)
        _check_combos()

func _init_terminal_buffer():
    terminal_buffer.clear()
    for i in range(terminal_height):
        terminal_buffer.append("")

func _init_color_codes():
    terminal_color_codes = {
        "reset": "\u001b[0m",
        "bold": "\u001b[1m",
        "black": "\u001b[30m",
        "red": "\u001b[31m",
        "green": "\u001b[32m",
        "yellow": "\u001b[33m",
        "blue": "\u001b[34m",
        "magenta": "\u001b[35m",
        "cyan": "\u001b[36m",
        "white": "\u001b[37m",
        "bg_black": "\u001b[40m",
        "bg_red": "\u001b[41m",
        "bg_green": "\u001b[42m",
        "bg_yellow": "\u001b[43m",
        "bg_blue": "\u001b[44m",
        "bg_magenta": "\u001b[45m",
        "bg_cyan": "\u001b[46m",
        "bg_white": "\u001b[47m",
        "system": "\u001b[36m",  # Cyan for system messages
        "error": "\u001b[31m",   # Red for errors
        "warning": "\u001b[33m",  # Yellow for warnings
        "success": "\u001b[32m",  # Green for success
        "data": "\u001b[37m",    # White for data
        "command": "\u001b[35m",  # Magenta for commands
        "path": "\u001b[34m",    # Blue for paths
        "debug": "\u001b[90m"    # Gray for debug info
    }

func _register_default_combos():
    # Fast navigation combos
    register_combo(["CTRL+F"], "quick_find", self._quick_find)
    register_combo(["CTRL+G"], "go_to_path", self._go_to_path)
    register_combo(["CTRL+H"], "show_history", self._show_history)
    register_combo(["CTRL+D"], "toggle_debug", self._toggle_debug)
    
    # View mode combos
    register_combo(["CTRL+1"], "list_view", func(): _set_view_mode("list"))
    register_combo(["CTRL+2"], "tree_view", func(): _set_view_mode("tree"))
    register_combo(["CTRL+3"], "hex_view", func(): _set_view_mode("hex"))
    register_combo(["CTRL+4"], "preview_view", func(): _set_view_mode("preview"))
    
    # Advanced combos (sequences)
    register_combo(["CTRL+X", "CTRL+F"], "advanced_find", self._advanced_find)
    register_combo(["CTRL+X", "CTRL+S"], "save_results", self._save_results)
    register_combo(["CTRL+X", "CTRL+L"], "load_session", self._load_session)
    
    # Play-5 pad special combos
    register_combo(["JOY_0", "JOY_1", "JOY_0"], "refresh_all", self._refresh_all_data)
    register_combo(["JOY_2", "JOY_3", "JOY_2"], "toggle_filter", self._toggle_filter_mode)
    register_combo(["JOY_0", "JOY_3", "JOY_1", "JOY_2"], "deep_scan", self._deep_scan)

# Core Terminal Functions

func _print_welcome():
    _print_line("╔══════════════════════════════════════════════════════════════════════════════╗", "system")
    _print_line("║             DEBUG COMBO TERMINAL - DATA SEA NAVIGATION SYSTEM                ║", "system")
    _print_line("║                                                                              ║", "system")
    _print_line("║  Use keyboard or gamepad for combo commands                                  ║", "system")
    _print_line("║  CTRL+F: Quick Find    CTRL+G: Go To Path    CTRL+H: History                 ║", "system")
    _print_line("║  View Modes: CTRL+1 (List)  CTRL+2 (Tree)  CTRL+3 (Hex)  CTRL+4 (Preview)    ║", "system")
    _print_line("║  Type 'help' for more commands or 'combos' to see all combo shortcuts        ║", "system")
    _print_line("╚══════════════════════════════════════════════════════════════════════════════╝", "system")

func _print_line(text, color_type="reset"):
    # Add color codes
    var color_code = terminal_color_codes.get(color_type, terminal_color_codes["reset"])
    var reset_code = terminal_color_codes["reset"]
    var colored_text = color_code + text + reset_code
    
    # Add to buffer
    terminal_buffer.append(colored_text)
    
    # Maintain buffer size
    while terminal_buffer.size() > terminal_height:
        terminal_buffer.remove_at(0)
    
    # Update display
    _update_terminal_display()

func _update_terminal_display():
    # In a real implementation, this would update the actual terminal widget
    # For this example, we'll just print to console
    var display_text = ""
    for line in terminal_buffer:
        display_text += line + "\n"
    
    print(display_text)

func _display_prompt():
    var prompt_text = current_path + " $ "
    _print_line(prompt_text, "path")
    cursor_position = Vector2(prompt_text.length(), terminal_buffer.size() - 1)

func _execute_current_line():
    # Get the current line
    var current_line = terminal_buffer[terminal_buffer.size() - 1]
    
    # Extract the command (remove prompt)
    var prompt_end = current_line.find("$") + 2
    var command = current_line.substr(prompt_end).strip_edges()
    
    # Add to history
    if command.length() > 0:
        command_history.append(command)
        history_position = command_history.size()
    
    # Execute the command
    _print_line("", "reset")  # New line
    _execute_command(command)
    
    # Display new prompt
    _display_prompt()

func _execute_command(command):
    if command.length() == 0:
        return
    
    # Track execution time
    var start_time = Time.get_ticks_msec()
    var result = null
    var success = false
    
    # Process built-in commands
    var cmd_parts = command.split(" ", false)
    var cmd_name = cmd_parts[0].to_lower()
    
    match cmd_name:
        "help":
            _show_help()
            success = true
        "ls", "dir":
            result = _list_directory(cmd_parts)
            success = result != null
        "cd":
            result = _change_directory(cmd_parts)
            success = result != null
        "find":
            result = _find_files(cmd_parts)
            success = result != null
        "cat", "type":
            result = _display_file(cmd_parts)
            success = result != null
        "hex":
            result = _hex_view(cmd_parts)
            success = result != null
        "clear", "cls":
            _clear_terminal()
            success = true
        "combos":
            _show_combos()
            success = true
        "debug":
            _set_debug_level(cmd_parts)
            success = true
        "exit", "quit":
            _print_line("Exiting Debug Combo Terminal...", "system")
            # In a real implementation, this would close the terminal
            success = true
        _:
            # Try to execute as a system command
            result = _execute_system_command(command)
            success = result != null
    
    # Track command execution time
    var duration = Time.get_ticks_msec() - start_time
    operation_times[cmd_name] = duration
    
    # Show execution time if debug is enabled
    if debug_enabled and debug_level >= 2:
        _print_line("Command executed in " + str(duration) + "ms", "debug")
    
    # Emit signal
    emit_signal("command_executed", command, success, result)

# Command Implementations

func _show_help():
    _print_line("Available Commands:", "system")
    _print_line("  help                 - Show this help", "command")
    _print_line("  ls, dir [path]       - List directory contents", "command")
    _print_line("  cd <path>            - Change directory", "command")
    _print_line("  find <pattern>       - Find files matching pattern", "command")
    _print_line("  cat, type <file>     - Display file contents", "command")
    _print_line("  hex <file>           - Display hex view of a file", "command")
    _print_line("  clear, cls           - Clear the terminal", "command")
    _print_line("  combos               - Show available combo shortcuts", "command")
    _print_line("  debug [0-3]          - Set debug level", "command")
    _print_line("  exit, quit           - Exit the terminal", "command")
    _print_line("")
    _print_line("Special Keys:", "system")
    _print_line("  Tab                  - Auto-complete paths and commands", "command")
    _print_line("  Up/Down Arrows       - Navigate command history", "command")
    _print_line("  Ctrl+C               - Cancel current operation", "command")
    _print_line("  Ctrl+L               - Clear screen", "command")

func _list_directory(cmd_parts):
    var path = current_path
    if cmd_parts.size() > 1:
        path = cmd_parts[1]
        if not path.begins_with("/"):
            path = current_path.path_join(path)
    
    var dir = DirAccess.open(path)
    if dir:
        var files = []
        var directories = []
        
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if dir.current_is_dir():
                directories.append(file_name)
            else:
                files.append(file_name)
            file_name = dir.get_next()
        
        directories.sort()
        files.sort()
        
        _print_line("Directory: " + path, "path")
        _print_line("", "reset")
        
        # Display directories first
        for directory in directories:
            _print_line("📁 " + directory + "/", "system")
        
        # Then display files
        for file in files:
            var extension = file.get_extension().to_lower()
            var color = "data"
            
            # Color code by extension
            if extension in ["txt", "md", "cfg", "ini", "json", "xml"]:
                color = "green"
            elif extension in ["exe", "com", "bat", "sh"]:
                color = "red"
            elif extension in ["jpg", "png", "gif", "bmp"]:
                color = "magenta"
            elif extension in ["mp3", "wav", "ogg"]:
                color = "cyan"
            
            _print_line("📄 " + file, color)
        
        return {
            "directories": directories,
            "files": files,
            "path": path
        }
    else:
        _print_line("Error: Could not open directory: " + path, "error")
        return null

func _change_directory(cmd_parts):
    if cmd_parts.size() < 2:
        _print_line("Current directory: " + current_path, "path")
        return current_path
    
    var new_path = cmd_parts[1]
    if not new_path.begins_with("/"):
        new_path = current_path.path_join(new_path)
    
    var dir = DirAccess.open(new_path)
    if dir:
        current_path = new_path
        _print_line("Changed directory to: " + current_path, "path")
        return current_path
    else:
        _print_line("Error: Directory does not exist: " + new_path, "error")
        return null

func _find_files(cmd_parts):
    if cmd_parts.size() < 2:
        _print_line("Usage: find <pattern>", "error")
        return null
    
    var pattern = cmd_parts[1]
    var recursive = true if cmd_parts.size() > 2 and cmd_parts[2] == "-r" else false
    
    # Start search timer
    var start_time = Time.get_ticks_msec()
    
    # Clear previous results
    search_results.clear()
    
    # Perform the search
    _print_line("Searching for: " + pattern + " in " + current_path + "...", "system")
    
    var results = _find_files_recursive(current_path, pattern, recursive)
    var duration = Time.get_ticks_msec() - start_time
    
    if results.size() > 0:
        _print_line("Found " + str(results.size()) + " matches in " + str(duration) + "ms:", "success")
        for result in results:
            _print_line(result, "path")
    else:
        _print_line("No matches found. Search completed in " + str(duration) + "ms.", "warning")
    
    search_results = results
    return {
        "pattern": pattern,
        "matches": results,
        "duration": duration
    }

func _find_files_recursive(path, pattern, recursive=false):
    var results = []
    var dir = DirAccess.open(path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            var full_path = path.path_join(file_name)
            
            if dir.current_is_dir() and file_name != "." and file_name != "..":
                if recursive:
                    results.append_array(_find_files_recursive(full_path, pattern, true))
            elif file_name.match(pattern):
                results.append(full_path)
            
            file_name = dir.get_next()
    
    return results

func _display_file(cmd_parts):
    if cmd_parts.size() < 2:
        _print_line("Usage: cat <file>", "error")
        return null
    
    var file_path = cmd_parts[1]
    if not file_path.begins_with("/"):
        file_path = current_path.path_join(file_path)
    
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var content = file.get_as_text()
        file.close()
        
        # Display file content with line numbers
        var lines = content.split("\n")
        for i in range(lines.size()):
            var line_num = "%4d | " % (i + 1)
            _print_line(line_num + lines[i], "data")
        
        return {
            "file": file_path,
            "lines": lines.size(),
            "size": content.length()
        }
    else:
        _print_line("Error: Could not open file: " + file_path, "error")
        return null

func _hex_view(cmd_parts):
    if cmd_parts.size() < 2:
        _print_line("Usage: hex <file>", "error")
        return null
    
    var file_path = cmd_parts[1]
    if not file_path.begins_with("/"):
        file_path = current_path.path_join(file_path)
    
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var size = file.get_length()
        var bytes_per_row = 16
        var max_rows = 16  # Limit number of rows to display
        
        _print_line("Hex view of " + file_path + " (" + str(size) + " bytes):", "system")
        _print_line("       0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F | 0123456789ABCDEF", "system")
        _print_line("----------------------------------------------------------------------", "system")
        
        for row in range(min(max_rows, ceil(size / float(bytes_per_row)))):
            var offset = row * bytes_per_row
            var hex_str = "%06X " % offset
            var ascii_str = ""
            
            for col in range(bytes_per_row):
                if offset + col < size:
                    var byte_val = file.get_8()
                    hex_str += "%02X " % byte_val
                    if byte_val >= 32 and byte_val < 127:  # Printable ASCII
                        ascii_str += char(byte_val)
                    else:
                        ascii_str += "."
                else:
                    hex_str += "   "
                    ascii_str += " "
            
            _print_line(hex_str + "| " + ascii_str, "data")
        
        if size > max_rows * bytes_per_row:
            _print_line("... (file too large, showing first " + str(max_rows) + " rows only)", "warning")
        
        file.close()
        return {
            "file": file_path,
            "size": size
        }
    else:
        _print_line("Error: Could not open file: " + file_path, "error")
        return null

func _clear_terminal():
    _init_terminal_buffer()
    _display_prompt()

func _show_combos():
    _print_line("Available Combo Shortcuts:", "system")
    
    for combo in active_combos:
        var combo_str = ""
        var keys = active_combos[combo].keys
        
        for i in range(keys.size()):
            combo_str += keys[i]
            if i < keys.size() - 1:
                combo_str += " → "
        
        _print_line("  " + combo_str + " - " + active_combos[combo].name, "command")

func _set_debug_level(cmd_parts):
    if cmd_parts.size() > 1:
        var level = int(cmd_parts[1])
        if level >= 0 and level <= 3:
            debug_level = level
            debug_enabled = level > 0
            _print_line("Debug level set to " + str(debug_level), "system")
        else:
            _print_line("Error: Debug level must be 0-3", "error")
    else:
        _print_line("Current debug level: " + str(debug_level), "system")

func _execute_system_command(command):
    # This would execute an external command
    # For safety, we'll just simulate it
    _print_line("Simulating execution of: " + command, "system")
    
    # For demo purposes, we'll just return success
    var result = {
        "command": command,
        "output": "Command executed successfully.",
        "exit_code": 0
    }
    
    _print_line(result.output, "data")
    return result

# Combo System Functions

func register_combo(key_sequence, name, callback):
    """
    Register a key combination shortcut
    key_sequence: Array of key names like ["CTRL+F", "CTRL+X"]
    name: String identifier for the combo
    callback: Function to call when combo is activated
    """
    active_combos[name] = {
        "keys": key_sequence,
        "name": name,
        "callback": callback
    }

func _check_combos():
    # Check if current buffer matches any registered combo
    for combo_name in active_combos:
        var combo = active_combos[combo_name]
        var keys = combo.keys
        
        # Check if the buffer contains a complete combo sequence
        if combo_buffer.size() >= keys.size():
            var match_found = true
            
            # Check each key in the sequence
            for i in range(keys.size()):
                if combo_buffer[combo_buffer.size() - keys.size() + i] != keys[i]:
                    match_found = false
                    break
            
            if match_found:
                # Execute the combo callback
                combo.callback.call()
                
                # Emit signal
                emit_signal("combo_activated", combo_name, {"keys": keys})
                
                # Clear the buffer
                combo_buffer.clear()
                
                # Show feedback
                _update_status("Combo activated: " + combo_name, "success")
                return

# Combo Command Implementations

func _quick_find():
    _print_line("Quick Find Mode - Enter search pattern:", "system")
    # In a real implementation, this would wait for user input
    # For this example, we'll simulate it
    _print_line("$ *.txt", "command")
    _find_files(["find", "*.txt"])

func _go_to_path():
    _print_line("Go To Path - Enter path:", "system")
    # Simulate input
    _print_line("$ /mnt/c/Users", "command")
    _change_directory(["cd", "/mnt/c/Users"])

func _show_history():
    _print_line("Command History:", "system")
    for i in range(command_history.size()):
        _print_line(str(i+1) + ": " + command_history[i], "data")

func _toggle_debug():
    debug_enabled = !debug_enabled
    _print_line("Debug " + ("enabled" if debug_enabled else "disabled"), "system")

func _set_view_mode(mode):
    view_mode = mode
    _print_line("View mode set to: " + mode, "system")
    
    # Apply view mode changes
    match mode:
        "list":
            _list_directory(["ls"])
        "tree":
            _print_line("Tree view:", "system")
            _display_directory_tree(current_path, 0)
        "hex":
            _print_line("Hex view mode - Select a file with 'hex <filename>'", "system")
        "preview":
            _print_line("Preview mode - Select a file to preview", "system")

func _display_directory_tree(path, level):
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name != "." and file_name != "..":
                var full_path = path.path_join(file_name)
                var indent = "  ".repeat(level)
                
                if dir.current_is_dir():
                    _print_line(indent + "📁 " + file_name + "/", "system")
                    
                    # Limit recursion depth
                    if level < 2:
                        _display_directory_tree(full_path, level + 1)
                else:
                    _print_line(indent + "📄 " + file_name, "data")
            
            file_name = dir.get_next()

func _advanced_find():
    _print_line("Advanced Find - Enter search criteria:", "system")
    _print_line("Path: " + current_path, "path")
    _print_line("Pattern: *.gd", "data")
    _print_line("Content: extends Node", "data")
    _print_line("Searching...", "system")
    
    # Simulate search results
    _print_line("Found 3 matches:", "success")
    _print_line("1: /mnt/c/Users/Percision 15/debug_combo_terminal.gd", "path")
    _print_line("2: /mnt/c/Users/Percision 15/multi_account_api_controller.gd", "path")
    _print_line("3: /mnt/c/Users/Percision 15/emotion_pricing_system.gd", "path")

func _save_results():
    _print_line("Saving search results...", "system")
    
    if search_results.size() == 0:
        _print_line("No search results to save.", "warning")
        return
    
    # Simulate saving
    _print_line("Results saved to: " + current_path + "/search_results.txt", "success")

func _load_session():
    _print_line("Loading saved session...", "system")
    _print_line("Session restored.", "success")

func _refresh_all_data():
    _print_line("Refreshing all data...", "system")
    _list_directory(["ls"])
    _print_line("Data refreshed.", "success")

func _toggle_filter_mode():
    if filter_mode == "":
        filter_mode = "*.gd"
    else:
        filter_mode = ""
    
    _print_line("Filter mode: " + (filter_mode if filter_mode != "" else "none"), "system")
    _list_directory(["ls"])

func _deep_scan():
    _print_line("Starting deep scan of data sea...", "system")
    _print_line("Scanning drives for tainted data patterns...", "system")
    
    # Simulate progress
    for i in range(5):
        _print_line("Scanning sector " + str(i+1) + "/5...", "system")
    
    # Simulate results
    _print_line("Deep scan complete!", "success")
    _print_line("Found 42 unique data patterns", "data")
    _print_line("Identified 7 potentially tainted data sources", "warning")
    _print_line("Run 'analyze <pattern>' to investigate specific patterns", "system")

# Helper Functions

func _handle_backspace():
    # Get current line
    var line = terminal_buffer[terminal_buffer.size() - 1]
    
    # Find command part (after prompt)
    var prompt_end = line.find("$") + 2
    var command = line.substr(prompt_end)
    
    if command.length() > 0:
        # Remove last character
        command = command.substr(0, command.length() - 1)
        
        # Update line
        terminal_buffer[terminal_buffer.size() - 1] = line.substr(0, prompt_end) + command
        
        # Update cursor
        cursor_position.x = prompt_end + command.length()
        
        # Update display
        _update_terminal_display()

func _insert_character(character):
    # Get current line
    var line = terminal_buffer[terminal_buffer.size() - 1]
    
    # Find command part (after prompt)
    var prompt_end = line.find("$") + 2
    var command = line.substr(prompt_end)
    
    # Insert character
    command = command + character
    
    # Update line
    terminal_buffer[terminal_buffer.size() - 1] = line.substr(0, prompt_end) + command
    
    # Update cursor
    cursor_position.x = prompt_end + command.length()
    
    # Update display
    _update_terminal_display()

func _history_previous():
    if command_history.size() == 0 or history_position <= 0:
        return
    
    history_position -= 1
    _replace_current_command(command_history[history_position])

func _history_next():
    if command_history.size() == 0 or history_position >= command_history.size():
        return
    
    history_position += 1
    
    if history_position == command_history.size():
        _replace_current_command("")
    else:
        _replace_current_command(command_history[history_position])

func _replace_current_command(new_command):
    # Get current line
    var line = terminal_buffer[terminal_buffer.size() - 1]
    
    # Find prompt
    var prompt_end = line.find("$") + 2
    
    # Replace command
    terminal_buffer[terminal_buffer.size() - 1] = line.substr(0, prompt_end) + new_command
    
    # Update cursor
    cursor_position.x = prompt_end + new_command.length()
    
    # Update display
    _update_terminal_display()

func _handle_tab_completion():
    # Get current line
    var line = terminal_buffer[terminal_buffer.size() - 1]
    
    # Find command part (after prompt)
    var prompt_end = line.find("$") + 2
    var command = line.substr(prompt_end)
    
    # Find last word (for path completion)
    var parts = command.split(" ", false)
    
    if parts.size() == 0:
        return
    
    var last_word = parts[parts.size() - 1]
    var prefix = command.substr(0, command.length() - last_word.length())
    
    # Try to complete path
    var completions = _get_path_completions(last_word)
    
    if completions.size() == 1:
        # Single match - complete the word
        _replace_current_command(prefix + completions[0])
    elif completions.size() > 1:
        # Multiple matches - show options
        _print_line("", "reset")
        _print_line("Possible completions:", "system")
        
        for completion in completions:
            _print_line("  " + completion, "data")
        
        # Re-display prompt with current command
        _print_line("", "reset")
        _display_prompt()
        _replace_current_command(command)

func _get_path_completions(partial_path):
    var completions = []
    var dir_path = current_path
    var search_pattern = partial_path
    
    # If partial path contains a directory separator, extract the directory part
    if partial_path.find("/") >= 0:
        var last_separator = partial_path.rfind("/")
        dir_path = current_path.path_join(partial_path.substr(0, last_separator))
        search_pattern = partial_path.substr(last_separator + 1)
    
    # Try to open the directory
    var dir = DirAccess.open(dir_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.begins_with(search_pattern):
                if dir.current_is_dir():
                    completions.append(file_name + "/")
                else:
                    completions.append(file_name)
            
            file_name = dir.get_next()
    
    return completions

func _handle_ctrl_c():
    _print_line("^C", "system")
    _display_prompt()

func _update_status(message, message_type="system"):
    # Display a status message without disrupting the current prompt
    var last_line = terminal_buffer[terminal_buffer.size() - 1]
    
    # Add the status message
    _print_line(message, message_type)
    
    # Re-display the prompt line
    terminal_buffer[terminal_buffer.size() - 1] = last_line
    
    # Update display
    _update_terminal_display()

# Create a 5-pad combo chamber interface
func create_combo_chamber():
    _print_line("", "reset")
    _print_line("╔═════════════════════ COMBO CHAMBER ═════════════════════╗", "system")
    _print_line("║                                                         ║", "system")
    _print_line("║   [A]───────[B]                                         ║", "system")
    _print_line("║    │         │                                          ║", "system")
    _print_line("║    │    ┌────┼────┐                                     ║", "system")
    _print_line("║    │    │    │    │                                     ║", "system")
    _print_line("║   [C]───[D]──[E]                                        ║", "system")
    _print_line("║                                                         ║", "system")
    _print_line("║   Input: _ _ _ _                Combo: None             ║", "system")
    _print_line("║                                                         ║", "system")
    _print_line("╚═════════════════════════════════════════════════════════╝", "system")
    
    # Register 5-pad specific combos
    register_combo(["JOY_0"], "pad_a", func(): _pad_input("A"))
    register_combo(["JOY_1"], "pad_b", func(): _pad_input("B"))
    register_combo(["JOY_2"], "pad_c", func(): _pad_input("C"))
    register_combo(["JOY_3"], "pad_d", func(): _pad_input("D"))
    register_combo(["JOY_4"], "pad_e", func(): _pad_input("E"))
    
    # Special 5-pad combo sequences
    register_combo(["JOY_0", "JOY_2", "JOY_3", "JOY_4"], "super_scan", self._super_scan)
    register_combo(["JOY_0", "JOY_1", "JOY_0", "JOY_1"], "data_analyzer", self._data_analyzer)
    register_combo(["JOY_2", "JOY_3", "JOY_4", "JOY_2"], "tainted_data_clean", self._tainted_data_clean)

func _pad_input(button):
    _print_line("5-Pad input: " + button, "command")
    # Update the combo chamber display with the input sequence

func _super_scan():
    _print_line("SUPER SCAN ACTIVATED", "success")
    _print_line("Deep scanning all connected drives...", "system")
    
    # Simulate scan results
    _print_line("Scan complete! Found 157 files across 23 directories", "success")
    _print_line("Top 3 data clusters:", "data")
    _print_line("1. /mnt/c/Users/Percision 15/12_turns_system/ (42 files)", "path")
    _print_line("2. /mnt/c/Users/Percision 15/LuminusOS/ (31 files)", "path")
    _print_line("3. /mnt/c/Users/Percision 15/Desktop/ (26 files)", "path")

func _data_analyzer():
    _print_line("DATA ANALYZER ACTIVATED", "success")
    _print_line("Analyzing data patterns across drives...", "system")
    
    # Simulate analysis
    _print_line("Analysis complete!", "success")
    _print_line("Data format distribution:", "data")
    _print_line("- GDScript files: 32%", "data")
    _print_line("- Shell scripts: 18%", "data")
    _print_line("- Text files: 15%", "data")
    _print_line("- Media files: 35%", "data")
    
    _print_line("Potential data connections found between:", "system")
    _print_line("- multi_account_api_controller.gd and emotion_pricing_system.gd", "path")
    _print_line("- terminal_grid_creator.gd and word_visualization_3d.gd", "path")

func _tainted_data_clean():
    _print_line("TAINTED DATA CLEANUP INITIATED", "warning")
    _print_line("Scanning for corrupted or tainted data patterns...", "system")
    
    # Simulate cleanup process
    _print_line("Found 7 instances of tainted data:", "warning")
    _print_line("1. Fragmented data in smart_account_manager.gd", "path")
    _print_line("2. Duplicate records in word_database.txt", "path")
    _print_line("3. Corrupted entries in memory_investment_system.gd", "path")
    _print_line("4-7. Various minor inconsistencies", "path")
    
    _print_line("Apply fixes? (y/n)", "system")
    # Simulate confirmation
    _print_line("y", "data")
    _print_line("Cleaning tainted data...", "system")
    _print_line("Cleanup complete! System integrity improved by 23%", "success")