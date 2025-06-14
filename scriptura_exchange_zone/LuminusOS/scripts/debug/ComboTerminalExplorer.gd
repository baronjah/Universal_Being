extends Control
class_name ComboTerminalExplorer

# Terminal UI components
var terminal_display: RichTextLabel
var input_field: LineEdit
var combo_bar: ProgressBar
var status_label: Label
var quick_buttons: HBoxContainer

# Data exploration state
var current_path = "/mnt/c/Users/Percision 15"
var history = []
var search_results = []
var combo_counter = 0
var combo_timer = 0.0
var combo_active = false
var last_search_term = ""
var result_cache = {}
var visible_lines = 40

# Input modes
enum InputMode {COMMAND, COMBO, SEARCH, NAVIGATE}
var current_mode = InputMode.COMMAND

# Controller input mapping
var button_mappings = {
    "cross": "execute",
    "circle": "cancel",
    "square": "search",
    "triangle": "mode_switch",
    "l1": "history_back",
    "r1": "history_forward",
    "dpad_up": "navigate_up",
    "dpad_down": "navigate_down",
    "dpad_left": "navigate_left", 
    "dpad_right": "navigate_right"
}

# Signals
signal path_changed(new_path)
signal search_completed(term, results)
signal combo_executed(combo_name)
signal file_selected(file_path)

func _ready():
    _setup_ui()
    _initialize_combo_system()
    refresh_terminal()
    
    # Start at home directory
    navigate_to(current_path)

func _setup_ui():
    # Main container
    var main_container = VBoxContainer.new()
    main_container.anchor_right = 1.0
    main_container.anchor_bottom = 1.0
    add_child(main_container)
    
    # Terminal display
    terminal_display = RichTextLabel.new()
    terminal_display.bbcode_enabled = true
    terminal_display.selection_enabled = true
    terminal_display.size_flags_vertical = SIZE_EXPAND_FILL
    main_container.add_child(terminal_display)
    
    # Status bar
    var status_container = HBoxContainer.new()
    main_container.add_child(status_container)
    
    status_label = Label.new()
    status_label.text = "Ready"
    status_label.size_flags_horizontal = SIZE_EXPAND_FILL
    status_container.add_child(status_label)
    
    combo_bar = ProgressBar.new()
    combo_bar.max_value = 100
    combo_bar.value = 0
    combo_bar.custom_minimum_size = Vector2(200, 15)
    status_container.add_child(combo_bar)
    
    # Quick access buttons
    quick_buttons = HBoxContainer.new()
    main_container.add_child(quick_buttons)
    
    _add_quick_button("Search [□]", "search")
    _add_quick_button("Execute [×]", "execute")
    _add_quick_button("Back [L1]", "history_back")
    _add_quick_button("Mode [△]", "mode_switch")
    
    # Input field
    var input_container = HBoxContainer.new()
    main_container.add_child(input_container)
    
    var input_label = Label.new()
    input_label.text = "> "
    input_container.add_child(input_label)
    
    input_field = LineEdit.new()
    input_field.size_flags_horizontal = SIZE_EXPAND_FILL
    input_field.placeholder_text = "Enter command or search term..."
    input_field.text_submitted.connect(_on_input_submitted)
    input_container.add_child(input_field)
    
    # Set focus to input
    input_field.grab_focus()

func _add_quick_button(text, action):
    var button = Button.new()
    button.text = text
    button.pressed.connect(_on_quick_button_pressed.bind(action))
    quick_buttons.add_child(button)

func _on_quick_button_pressed(action):
    match action:
        "search":
            enter_search_mode()
        "execute":
            execute_current_input()
        "history_back":
            navigate_history_back()
        "mode_switch":
            cycle_input_mode()

func _initialize_combo_system():
    # Define combo sequences
    var combo_sequences = {
        "quick_scan": ["dpad_up", "dpad_up", "dpad_right", "square"],
        "deep_search": ["square", "square", "dpad_down", "cross"],
        "file_jump": ["triangle", "dpad_right", "dpad_right", "cross"],
        "super_combo": ["l1", "r1", "l1", "r1", "triangle"]
    }

func enter_search_mode():
    current_mode = InputMode.SEARCH
    input_field.placeholder_text = "Search term..."
    input_field.text = ""
    status_label.text = "SEARCH MODE"
    input_field.grab_focus()

func enter_command_mode():
    current_mode = InputMode.COMMAND
    input_field.placeholder_text = "Enter command..."
    status_label.text = "COMMAND MODE"
    input_field.grab_focus()

func enter_navigate_mode():
    current_mode = InputMode.NAVIGATE
    input_field.placeholder_text = "Navigate (use arrow keys or enter path)..."
    status_label.text = "NAVIGATE MODE"
    input_field.grab_focus()

func enter_combo_mode():
    current_mode = InputMode.COMBO
    input_field.placeholder_text = "Combo active! Enter sequence..."
    status_label.text = "COMBO MODE - Chain inputs quickly!"
    combo_active = true
    combo_counter = 0
    combo_timer = 3.0  # 3 second window for combo
    combo_bar.value = 100
    input_field.grab_focus()

func cycle_input_mode():
    # Cycle through available modes
    match current_mode:
        InputMode.COMMAND:
            enter_search_mode()
        InputMode.SEARCH:
            enter_navigate_mode()
        InputMode.NAVIGATE:
            enter_combo_mode()
        InputMode.COMBO:
            enter_command_mode()

func _on_input_submitted(text):
    if text.strip_edges() == "":
        return
    
    match current_mode:
        InputMode.COMMAND:
            execute_command(text)
        InputMode.SEARCH:
            search_for_term(text)
        InputMode.NAVIGATE:
            navigate_to(text)
        InputMode.COMBO:
            record_combo_input(text)
    
    # Clear input for next command
    input_field.text = ""

func execute_current_input():
    _on_input_submitted(input_field.text)

func execute_command(command):
    add_terminal_text("\n> " + command + "\n", "command")
    
    # Split command into parts
    var parts = command.split(" ", false)
    if parts.size() == 0:
        return
    
    var cmd = parts[0].to_lower()
    var args = parts.slice(1)
    
    match cmd:
        "ls":
            cmd_list_directory(args)
        "cd":
            cmd_change_directory(args)
        "find":
            cmd_find_files(args)
        "cat":
            cmd_view_file(args)
        "help":
            cmd_show_help()
        "clear":
            clear_terminal()
        "combo":
            enter_combo_mode()
        "mode":
            cycle_input_mode()
        _:
            add_terminal_text("Unknown command: " + cmd + "\n", "error")

func cmd_list_directory(args):
    var path = current_path
    if args.size() > 0:
        path = resolve_path(args[0])
    
    # Execute bash command to list directory
    add_terminal_text("Listing directory: " + path + "\n", "system")
    
    # Simulated directory listing (would use bash in real implementation)
    var files = list_directory_contents(path)
    
    if files.size() == 0:
        add_terminal_text("Directory is empty or could not be accessed.\n", "error")
        return
    
    # Format directory contents
    var formatted_text = ""
    for file in files:
        var name = file.name
        var type = file.type
        var color_code = "[color=#ffffff]"
        
        if type == "directory":
            color_code = "[color=#4e94ce]"
            name += "/"
        elif type == "executable":
            color_code = "[color=#42cf54]"
            name += "*"
        elif _is_data_file(name):
            color_code = "[color=#f1c40f]"
        
        formatted_text += color_code + name + "[/color]  "
    
    add_terminal_text(formatted_text + "\n", "output")

func cmd_change_directory(args):
    if args.size() == 0:
        add_terminal_text("Usage: cd <directory>\n", "error")
        return
    
    var new_path = resolve_path(args[0])
    navigate_to(new_path)

func cmd_find_files(args):
    if args.size() == 0:
        add_terminal_text("Usage: find <pattern>\n", "error")
        return
    
    var pattern = args[0]
    var search_path = current_path
    
    if args.size() > 1:
        search_path = resolve_path(args[1])
    
    add_terminal_text("Searching for '" + pattern + "' in " + search_path + "...\n", "system")
    
    # Simulated search (would use bash find command in real implementation)
    var results = search_directory(search_path, pattern)
    search_results = results
    
    add_terminal_text("Found " + str(results.size()) + " matches:\n", "system")
    
    for i in range(results.size()):
        add_terminal_text(str(i+1) + ". " + results[i] + "\n", "result")
    
    if results.size() > 0:
        add_terminal_text("\nUse 'cat <number>' to view a result.\n", "system")

func cmd_view_file(args):
    if args.size() == 0:
        add_terminal_text("Usage: cat <file or number>\n", "error")
        return
    
    var file_path = ""
    
    # Check if argument is a number (referencing search results)
    if args[0].is_valid_int():
        var index = args[0].to_int() - 1
        if index >= 0 and index < search_results.size():
            file_path = search_results[index]
        else:
            add_terminal_text("Invalid result number.\n", "error")
            return
    else:
        file_path = resolve_path(args[0])
    
    add_terminal_text("Viewing file: " + file_path + "\n", "system")
    
    # Simulated file reading (would use real file access in actual implementation)
    var content = read_file_content(file_path)
    
    if content == null:
        add_terminal_text("Could not read file or file does not exist.\n", "error")
        return
    
    add_terminal_text("--- File content ---\n", "separator")
    add_terminal_text(content + "\n", "file_content")
    add_terminal_text("--- End of file ---\n", "separator")
    
    emit_signal("file_selected", file_path)

func cmd_show_help():
    var help_text = """
[color=#f1c40f]=== Debug Terminal Explorer Help ===
[color=#ffffff]Available commands:
  [color=#4e94ce]ls [path][color=#ffffff] - List files in directory
  [color=#4e94ce]cd <path>[color=#ffffff] - Change directory
  [color=#4e94ce]find <pattern> [path][color=#ffffff] - Search for files
  [color=#4e94ce]cat <file or number>[color=#ffffff] - View file content
  [color=#4e94ce]clear[color=#ffffff] - Clear terminal
  [color=#4e94ce]combo[color=#ffffff] - Enter combo mode
  [color=#4e94ce]mode[color=#ffffff] - Switch input mode
  [color=#4e94ce]help[color=#ffffff] - Show this help

[color=#f1c40f]Input Modes:
[color=#ffffff]  [color=#4e94ce]COMMAND[color=#ffffff] - Execute terminal commands
  [color=#4e94ce]SEARCH[color=#ffffff] - Quickly search for files
  [color=#4e94ce]NAVIGATE[color=#ffffff] - Directory navigation
  [color=#4e94ce]COMBO[color=#ffffff] - Execute powerful command combos

[color=#f1c40f]Controller Shortcuts:
[color=#ffffff]  [color=#4e94ce]Square[color=#ffffff] - Search mode
  [color=#4e94ce]Cross[color=#ffffff] - Execute
  [color=#4e94ce]Triangle[color=#ffffff] - Cycle modes
  [color=#4e94ce]L1/R1[color=#ffffff] - Navigate history
  [color=#4e94ce]D-pad[color=#ffffff] - Navigation
"""
    add_terminal_text(help_text, "help")

func navigate_to(path):
    # Verify the path exists
    if not directory_exists(path):
        add_terminal_text("Cannot navigate to: " + path + " - Directory does not exist.\n", "error")
        return false
    
    # Add current path to history before changing
    if current_path != path:
        history.append(current_path)
    
    # Update current path
    current_path = path
    add_terminal_text("Changed directory to: " + current_path + "\n", "system")
    update_status_label()
    
    # List contents of new directory
    cmd_list_directory([])
    
    emit_signal("path_changed", current_path)
    return true

func navigate_history_back():
    if history.size() > 0:
        var previous_path = history.pop_back()
        
        # Don't add to history when navigating history
        var old_path = current_path
        current_path = previous_path
        
        add_terminal_text("Navigated back to: " + current_path + "\n", "system")
        update_status_label()
        
        # List contents without adding to history again
        cmd_list_directory([])
        
        emit_signal("path_changed", current_path)
        return true
    else:
        add_terminal_text("No previous directory in history.\n", "error")
        return false

func search_for_term(term):
    last_search_term = term
    add_terminal_text("\nSearching for: " + term + "\n", "system")
    
    # Check cache first
    var cache_key = current_path + ":" + term
    if cache_key in result_cache:
        search_results = result_cache[cache_key]
        _display_search_results(search_results)
        return
    
    # Perform search
    search_results = search_directory(current_path, term, true) # Recursive search
    
    # Cache results
    result_cache[cache_key] = search_results
    
    _display_search_results(search_results)
    
    emit_signal("search_completed", term, search_results)

func _display_search_results(results):
    add_terminal_text("Found " + str(results.size()) + " results:\n", "system")
    
    for i in range(results.size()):
        var result = results[i]
        var display_path = result
        
        # Highlight the search term in results
        if last_search_term != "":
            var highlight_start = display_path.find(last_search_term)
            if highlight_start >= 0:
                var before = display_path.substr(0, highlight_start)
                var term = display_path.substr(highlight_start, last_search_term.length())
                var after = display_path.substr(highlight_start + last_search_term.length())
                display_path = before + "[color=#f1c40f]" + term + "[/color]" + after
        
        add_terminal_text(str(i+1) + ". " + display_path + "\n", "result")
    
    if results.size() > 0:
        add_terminal_text("\nUse 'cat <number>' to view a result.\n", "system")
    else:
        add_terminal_text("No results found.\n", "error")

func record_combo_input(input):
    if not combo_active:
        return
    
    # Record input in combo sequence
    combo_counter += 1
    combo_timer = 3.0  # Reset timer
    
    add_terminal_text("Combo Input " + str(combo_counter) + ": " + input + "\n", "combo")
    
    # Check for special combo patterns
    if combo_counter >= 3:
        check_combo_sequence()

func check_combo_sequence():
    # Simplified combo detection
    if combo_counter >= 5:
        add_terminal_text("SUPER COMBO ACTIVATED!\n", "combo")
        execute_super_combo()
    elif combo_counter >= 3:
        add_terminal_text("COMBO ACTIVATED!\n", "combo")
        execute_basic_combo()

func execute_basic_combo():
    # Execute a basic combo based on the input
    add_terminal_text("Executing fast directory scan...\n", "system")
    
    # Simulate quick directory scan
    var scan_results = {}
    scan_results["file_count"] = 157
    scan_results["dir_count"] = 23
    scan_results["data_files"] = 42
    scan_results["largest_files"] = ["data.bin", "backup.zip", "movie.mp4"]
    
    # Display results
    add_terminal_text("Scan complete! Found:\n", "system")
    add_terminal_text("- " + str(scan_results.file_count) + " files\n", "output")
    add_terminal_text("- " + str(scan_results.dir_count) + " directories\n", "output")
    add_terminal_text("- " + str(scan_results.data_files) + " data files\n", "output")
    add_terminal_text("- Largest files: " + str(scan_results.largest_files) + "\n", "output")
    
    combo_active = false
    enter_command_mode()

func execute_super_combo():
    # Execute a super combo with more powerful effects
    add_terminal_text("EXECUTING SUPER COMBO: DEEP SYSTEM ANALYSIS\n", "combo")
    
    # Simulate deep system analysis
    add_terminal_text("Scanning drive structure...\n", "system")
    await get_tree().create_timer(0.5).timeout
    
    add_terminal_text("Analyzing file patterns...\n", "system")
    await get_tree().create_timer(0.5).timeout
    
    add_terminal_text("Generating data map...\n", "system")
    await get_tree().create_timer(0.5).timeout
    
    # Display ASCII art data map
    var data_map = """
[color=#4e94ce]╔══════════════════════════════════════════════════════╗
║                     DATA SEA MAP                      ║
╠══════════════════════════════════════════════════════╣
║  [color=#f1c40f]■■■[/color]                                              ║
║  [color=#f1c40f]■■■■■[/color]                                            ║
║  [color=#f1c40f]■■■■■■■[/color]  [color=#e74c3c]▓▓▓[/color]                                  ║
║  [color=#f1c40f]■■■■■[/color]    [color=#e74c3c]▓▓▓▓▓[/color]                                ║
║  [color=#f1c40f]■■■[/color]      [color=#e74c3c]▓▓▓▓▓▓▓[/color]                              ║
║          [color=#e74c3c]▓▓▓▓▓▓▓▓▓[/color]      [color=#9b59b6]░░░[/color]                    ║
║            [color=#e74c3c]▓▓▓▓▓[/color]        [color=#9b59b6]░░░░░[/color]                  ║
║              [color=#e74c3c]▓▓▓[/color]        [color=#9b59b6]░░░░░░░[/color]                ║
║                          [color=#9b59b6]░░░░░░░░░[/color]              ║
║                            [color=#9b59b6]░░░░░[/color]      [color=#2ecc71]●●●[/color]      ║
║                              [color=#9b59b6]░░░[/color]      [color=#2ecc71]●●●●●[/color]    ║
║                                      [color=#2ecc71]●●●●●●●[/color]  ║
║                                        [color=#2ecc71]●●●●●[/color]  ║
║                                          [color=#2ecc71]●●●[/color]  ║
╚══════════════════════════════════════════════════════╝[/color]

[color=#f1c40f]■[/color] - Documents   [color=#e74c3c]▓[/color] - Media   [color=#9b59b6]░[/color] - Programs   [color=#2ecc71]●[/color] - System
"""
    add_terminal_text(data_map, "art")
    
    add_terminal_text("Super combo completed! Data map generated.\n", "system")
    
    combo_active = false
    enter_command_mode()

func resolve_path(path):
    if path.begins_with("/"):
        return path
    elif path == "..":
        # Go up one directory
        var parts = current_path.split("/")
        parts.pop_back()
        if parts.size() == 0:
            return "/"
        return "/".join(parts)
    elif path == "~":
        # Home directory
        return "/home/user"
    else:
        # Relative path
        if current_path.ends_with("/"):
            return current_path + path
        else:
            return current_path + "/" + path

func add_terminal_text(text, style = "normal"):
    var styled_text = ""
    
    match style:
        "command":
            styled_text = "[color=#42cf54]" + text + "[/color]"
        "system":
            styled_text = "[color=#4e94ce]" + text + "[/color]"
        "error":
            styled_text = "[color=#e74c3c]" + text + "[/color]"
        "output":
            styled_text = "[color=#ffffff]" + text + "[/color]"
        "result":
            styled_text = "[color=#9b59b6]" + text + "[/color]"
        "combo":
            styled_text = "[color=#f39c12][b]" + text + "[/b][/color]"
        "file_content":
            styled_text = "[color=#ecf0f1]" + text + "[/color]"
        "separator":
            styled_text = "[color=#7f8c8d]" + text + "[/color]"
        "help":
            styled_text = text  # Already contains BBCode
        "art":
            styled_text = text  # Already contains BBCode
        _:
            styled_text = text
    
    terminal_display.append_text(styled_text)
    terminal_display.scroll_to_line(terminal_display.get_line_count() - 1)

func clear_terminal():
    terminal_display.text = ""
    add_terminal_text("Terminal cleared.\n", "system")

func refresh_terminal():
    clear_terminal()
    add_terminal_text("Debug Terminal Explorer v1.0\n", "system")
    add_terminal_text("Current path: " + current_path + "\n", "system")
    add_terminal_text("Type 'help' for available commands.\n", "system")
    add_terminal_text("\n")

func update_status_label():
    status_label.text = "Path: " + current_path + " | Mode: " + InputMode.keys()[current_mode]

# Simulated file system functions (would use real fs access in actual implementation)

func list_directory_contents(path):
    # Simulated directory listing
    var contents = []
    
    # Add some fake entries to simulate directory contents
    contents.append({"name": "documents", "type": "directory"})
    contents.append({"name": "pictures", "type": "directory"})
    contents.append({"name": "data", "type": "directory"})
    contents.append({"name": "config.json", "type": "file"})
    contents.append({"name": "log.txt", "type": "file"})
    contents.append({"name": "data.bin", "type": "file"})
    contents.append({"name": "script.sh", "type": "executable"})
    
    return contents

func directory_exists(path):
    # Simulated directory check
    # In a real implementation, would check if directory exists
    return true

func search_directory(path, pattern, recursive=false):
    # Simulated file search
    var results = []
    
    # Add some fake results to simulate search
    results.append(path + "/data/match_" + pattern + ".txt")
    results.append(path + "/config/settings_" + pattern + ".json")
    results.append(path + "/logs/" + pattern + "_log.txt")
    
    if recursive:
        results.append(path + "/system/subsystem/" + pattern + "_module.bin")
        results.append(path + "/apps/utils/" + pattern + "_tool.sh")
    
    return results

func read_file_content(path):
    # Simulated file reading
    # In a real implementation, would read actual file content
    
    # Check if it's a binary file
    if path.ends_with(".bin") or path.ends_with(".exe") or path.ends_with(".dat"):
        var hex_dump = """
00000000: 89 50 4E 47 0D 0A 1A 0A 00 00 00 0D 49 48 44 52  .PNG........IHDR
00000010: 00 00 02 00 00 00 02 00 08 06 00 00 00 F4 78 D4  ..............xÔ
00000020: FA 00 00 00 04 73 42 49 54 08 08 08 08 7C 08 64  ú....sBIT....|.d
00000030: 88 00 00 00 09 70 48 59 73 00 00 0E C3 00 00 0E  ....pHYs...Ã...
00000040: C3 01 C7 6F A8 64 00 00 00 19 74 45 58 74 53 6F  Ã.ÇoXd....tEXtSo
00000050: 66 74 77 61 72 65 00 77 77 77 2E 69 6E 6B 73 63  ftware.www.inksc
"""
        return hex_dump
    
    # Return fake content based on file extension
    if path.ends_with(".json"):
        return """
{
  "name": "Debug Terminal Explorer",
  "version": "1.0.0",
  "description": "Fast terminal-based data explorer",
  "settings": {
    "theme": "dark",
    "max_history": 100,
    "cache_enabled": true
  },
  "shortcuts": {
    "search": "ctrl+f",
    "clear": "ctrl+l",
    "quit": "ctrl+q"
  }
}
"""
    elif path.ends_with(".txt"):
        return """
Debug Terminal Explorer Log
==========================

System initialized at 2024-05-12 10:23:45
- Loaded 24 command modules
- Cache directory at /tmp/explorer_cache
- Controller support enabled

Last scan completed at 2024-05-12 11:45:12
- 1,457 files indexed
- 128 directories processed
- 3 errors encountered
"""
    elif path.ends_with(".sh"):
        return """
#!/bin/bash

# Debug Helper Script
# ------------------

echo "Starting debug process..."

# Check for data directory
if [ ! -d "./data" ]; then
    mkdir -p ./data
    echo "Created data directory"
fi

# Scan for log files
log_count=$(find . -name "*.log" | wc -l)
echo "Found $log_count log files"

# Process each log file
for log_file in $(find . -name "*.log"); do
    echo "Processing $log_file..."
    grep "ERROR" "$log_file" >> ./data/errors.txt
done

echo "Debug process complete!"
"""
    else:
        return "File content simulation not available for this file type."

func _is_data_file(filename):
    # Check if file is a data file (for highlighting)
    var data_extensions = [".bin", ".dat", ".json", ".csv", ".xml", ".db"]
    
    for ext in data_extensions:
        if filename.ends_with(ext):
            return true
    
    return false

func _process(delta):
    # Process combo timer
    if combo_active:
        combo_timer -= delta
        combo_bar.value = (combo_timer / 3.0) * 100
        
        if combo_timer <= 0:
            combo_active = false
            add_terminal_text("Combo timed out.\n", "error")
            enter_command_mode()
            combo_bar.value = 0