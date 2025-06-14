class_name DOSTerminal
extends Control

# ================ TERMINAL PROPERTIES ================
var prompt = "C:\\>"
var current_directory = "C:\\"
var root_directory = "C:\\"
var universe_directory = "C:\\UNIVERSE\\"
var game_reality_directory = "C:\\UNIVERSE\\PROJECTS\\GAME.REALITY\\"
var movie_directory = "C:\\UNIVERSE\\PROJECTS\\MOVIE.4DM\\"
var system_directory = "C:\\SYSTEM\\"
var history = []
var command_history = []
var command_history_index = -1
var visible_lines = 25
var terminal_width = 80
var screen_buffer = []
var command_aliases = {}
var input_allowed = true
var echo_mode = true
var ansi_colors_enabled = true
var current_text_color = Color.WHITE
var current_bg_color = Color.BLACK
var blink_rate = 0.5
var cursor_visible = true
var last_command_result = ""
var simulation_mode = true
var dimension_mode = "4D"
var current_text_speed = 1.0

# UI Components
var terminal_display: RichTextLabel
var command_input: LineEdit
var cursor_timer: Timer
var status_bar: Label
var text_speed_slider: HSlider

# ================ VISUAL THEME PROPERTIES ================
const COLORS = {
    "black": Color(0, 0, 0),
    "blue": Color(0, 0, 0.8),
    "green": Color(0, 0.8, 0),
    "cyan": Color(0, 0.8, 0.8),
    "red": Color(0.8, 0, 0),
    "magenta": Color(0.8, 0, 0.8),
    "brown": Color(0.8, 0.8, 0),
    "light_gray": Color(0.8, 0.8, 0.8),
    "dark_gray": Color(0.4, 0.4, 0.4),
    "light_blue": Color(0.4, 0.4, 1),
    "light_green": Color(0.4, 1, 0.4),
    "light_cyan": Color(0.4, 1, 1),
    "light_red": Color(1, 0.4, 0.4),
    "light_magenta": Color(1, 0.4, 1),
    "yellow": Color(1, 1, 0.4),
    "white": Color(1, 1, 1)
}

# ================ FILE SYSTEM SIMULATION ================
var file_system = {
    "C:\\": {
        "type": "directory",
        "content": {
            "SYSTEM": {"type": "directory", "content": {}},
            "UNIVERSE": {"type": "directory", "content": {}},
            "USERS": {"type": "directory", "content": {}},
            "DOS": {"type": "directory", "content": {}},
            "AUTOEXEC.BAT": {"type": "file", "content": "ECHO Starting DOS-inspired environment...\nPATH C:\\DOS;C:\\SYSTEM\nPROMPT $P$G\nVER\nECHO System ready."},
            "CONFIG.SYS": {"type": "file", "content": "DEVICE=HIMEM.SYS\nDEVICE=EMM386.EXE\nFILES=50\nBUFFERS=20\nDEVICE=ANSI.SYS"},
            "README.TXT": {"type": "file", "content": "DOS-inspired Terminal for 4D Movie-Game project\nVersion 1.0\n\nThis system provides a nostalgic interface for interacting with the 4D movie-game framework."}
        }
    }
}

# Initialize system directories
func _init_file_system():
    # Initialize SYSTEM directory
    file_system["C:\\"]["content"]["SYSTEM"]["content"] = {
        "COMMAND.COM": {"type": "file", "content": "DOS command processor"},
        "HIMEM.SYS": {"type": "file", "content": "Extended memory manager"},
        "EMM386.EXE": {"type": "file", "content": "Expanded memory manager"},
        "ANSI.SYS": {"type": "file", "content": "ANSI terminal support"},
        "HELP.EXE": {"type": "file", "content": "Help system"},
        "EDIT.COM": {"type": "file", "content": "Text editor"},
        "FORMAT.COM": {"type": "file", "content": "Disk formatter"}
    }
    
    # Initialize DOS directory
    file_system["C:\\"]["content"]["DOS"]["content"] = {
        "VER.EXE": {"type": "file", "content": "Version information"},
        "CLS.COM": {"type": "file", "content": "Clear screen utility"},
        "DIR.COM": {"type": "file", "content": "Directory lister"},
        "CD.COM": {"type": "file", "content": "Change directory"},
        "TYPE.COM": {"type": "file", "content": "Display file contents"},
        "ECHO.COM": {"type": "file", "content": "Echo text to screen"},
        "MEMORY.COM": {"type": "file", "content": "Display memory information"}
    }
    
    # Initialize UNIVERSE directory
    file_system["C:\\"]["content"]["UNIVERSE"]["content"] = {
        "PROJECTS": {"type": "directory", "content": {
            "GAME.REALITY": {"type": "directory", "content": {}},
            "MOVIE.4DM": {"type": "directory", "content": {}},
            "SYSTEM.DOS": {"type": "directory", "content": {}}
        }},
        "CONFIG.UNI": {"type": "file", "content": "Universe Configuration\nDIMENSIONS=4\nTIME_LOOPS=ENABLED\nREALITY_PERSISTENCE=TRUE\nMEMORY_INTEGRATION=FULL"},
        "README.UNI": {"type": "file", "content": "Universal Access System\nThis directory provides access to the interdimensional projects system."}
    }
    
    # Initialize GAME.REALITY directory
    file_system["C:\\"]["content"]["UNIVERSE"]["content"]["PROJECTS"]["content"]["GAME.REALITY"]["content"] = {
        "SCENES": {"type": "directory", "content": {}},
        "ENTITIES": {"type": "directory", "content": {}},
        "RULES": {"type": "directory", "content": {}},
        "MANIFEST.REL": {"type": "file", "content": "Reality Manifest v1.0\nTYPE=INTERACTIVE\nPERSISTENCE=TRUE\nCYCLES=9\nDIMENSIONS=4"},
        "EXECUTE.BAT": {"type": "file", "content": "ECHO Initializing reality engine...\nLOAD MANIFEST.REL\nINIT SCENES\nPREPARE ENTITIES\nMANIFEST"},
        "STATE.DAT": {"type": "file", "content": "Current game state information - binary data"}
    }
    
    # Initialize scenes
    var scenes_dir = file_system["C:\\"]["content"]["UNIVERSE"]["content"]["PROJECTS"]["content"]["GAME.REALITY"]["content"]["SCENES"]["content"]
    for i in range(1, 10):
        scenes_dir["SCENE.00" + str(i)] = {
            "type": "file", 
            "content": "Scene " + str(i) + " configuration\nENTITIES=YES\nINTERACTIVE=TRUE\nPHYSICS=ENABLED"
        }
    
    # Initialize MOVIE.4DM directory
    file_system["C:\\"]["content"]["UNIVERSE"]["content"]["PROJECTS"]["content"]["MOVIE.4DM"]["content"] = {
        "TIMELINE": {"type": "directory", "content": {}},
        "ACTORS": {"type": "directory", "content": {}},
        "EFFECTS": {"type": "directory", "content": {}},
        "SCRIPT.4DM": {"type": "file", "content": "4D Movie Script\nTIMELINE: Linear with branches\nVIEWPOINTS: Multiple\nINTERACTION: Medium\nRESOLUTION: Quantum"},
        "RENDER.BAT": {"type": "file", "content": "ECHO Rendering 4D movie...\nLOAD SCRIPT.4DM\nPREPARE TIMELINE\nLOAD ACTORS\nRENDER"}
    }
    
    # Initialize USERS directory
    file_system["C:\\"]["content"]["USERS"]["content"] = {
        "DEFAULT": {"type": "directory", "content": {
            "PROFILE.USR": {"type": "file", "content": "User profile information"},
            "SETTINGS.CFG": {"type": "file", "content": "User settings"}
        }}
    }

# ================ TERMINAL SETUP AND INITIALIZATION ================
func _ready():
    setup_terminal_ui()
    _init_file_system()
    setup_command_aliases()
    initialize_terminal()
    show_startup_sequence()
    
    # Focus the input field
    command_input.grab_focus()

func setup_terminal_ui():
    # Create terminal display
    terminal_display = RichTextLabel.new()
    terminal_display.bbcode_enabled = true
    terminal_display.scroll_following = true
    terminal_display.size_flags_vertical = SIZE_EXPAND_FILL
    terminal_display.size_flags_horizontal = SIZE_EXPAND_FILL
    add_child(terminal_display)
    
    # Create command input
    command_input = LineEdit.new()
    command_input.placeholder_text = "Enter command..."
    command_input.text_submitted.connect(_on_command_submitted)
    add_child(command_input)
    
    # Create status bar
    status_bar = Label.new()
    status_bar.text = "DOS Terminal Ready | 4D Mode | " + Time.get_datetime_string_from_system()
    add_child(status_bar)
    
    # Create text speed slider
    text_speed_slider = HSlider.new()
    text_speed_slider.min_value = 0.1
    text_speed_slider.max_value = 2.0
    text_speed_slider.step = 0.1
    text_speed_slider.value = 1.0
    text_speed_slider.value_changed.connect(_on_text_speed_changed)
    add_child(text_speed_slider)
    
    # Setup layout
    var vbox = VBoxContainer.new()
    vbox.anchor_right = 1.0
    vbox.anchor_bottom = 1.0
    
    remove_child(terminal_display)
    remove_child(command_input)
    remove_child(status_bar)
    remove_child(text_speed_slider)
    
    vbox.add_child(terminal_display)
    
    var bottom_container = HBoxContainer.new()
    bottom_container.add_child(command_input)
    command_input.size_flags_horizontal = SIZE_EXPAND_FILL
    
    var speed_container = VBoxContainer.new()
    var speed_label = Label.new()
    speed_label.text = "Speed"
    speed_container.add_child(speed_label)
    speed_container.add_child(text_speed_slider)
    bottom_container.add_child(speed_container)
    
    vbox.add_child(bottom_container)
    vbox.add_child(status_bar)
    
    add_child(vbox)
    
    # Set up blinking cursor
    cursor_timer = Timer.new()
    cursor_timer.wait_time = blink_rate
    cursor_timer.autostart = true
    cursor_timer.timeout.connect(_on_cursor_timer_timeout)
    add_child(cursor_timer)

func setup_command_aliases():
    command_aliases = {
        "cd": "CD",
        "dir": "DIR",
        "cls": "CLS",
        "type": "TYPE",
        "ver": "VER",
        "help": "HELP",
        "echo": "ECHO",
        "exit": "EXIT",
        "mem": "MEMORY",
        "copy": "COPY",
        "del": "DEL",
        "ren": "REN",
        "md": "MD",
        "rd": "RD"
    }

func initialize_terminal():
    # Clear screen buffer
    screen_buffer.clear()
    
    # Fill screen buffer with empty lines
    for i in range(visible_lines):
        screen_buffer.append("")
    
    # Set default colors
    current_text_color = COLORS.light_gray
    current_bg_color = COLORS.black
    
    # Setup default command history
    command_history.clear()
    command_history_index = -1

func show_startup_sequence():
    clear_screen()
    
    var startup_messages = [
        {"text": "Starting DOS-inspired 4D Terminal...", "color": COLORS.white, "delay": 0.5},
        {"text": "Loading UNIVERSE drivers...", "color": COLORS.light_cyan, "delay": 0.3},
        {"text": "Initializing 4D support...", "color": COLORS.light_magenta, "delay": 0.4},
        {"text": "Establishing reality anchors...", "color": COLORS.light_green, "delay": 0.2},
        {"text": "Connecting to GAME.REALITY...", "color": COLORS.yellow, "delay": 0.3},
        {"text": "Loading MOVIE.4DM structures...", "color": COLORS.light_red, "delay": 0.3},
        {"text": "Syncing interdimensional timelines...", "color": COLORS.light_blue, "delay": 0.5},
        {"text": "", "color": COLORS.white, "delay": 0.2},
        {"text": "█▀█ █▀█ █▀   ▀█▀ █▀▀ █▀█ █▀▄▀█ █ █▄░█ ▄▀█ █░░", "color": COLORS.yellow, "delay": 0.1},
        {"text": "█▄█ █▄█ ▄█   ░█░ ██▄ █▀▄ █░▀░█ █ █░▀█ █▀█ █▄▄", "color": COLORS.yellow, "delay": 0.1},
        {"text": "", "color": COLORS.white, "delay": 0.2},
        {"text": "4D Movie-Game Environment v1.0", "color": COLORS.light_cyan, "delay": 0.2},
        {"text": "© 2025 JSH Interdimensional Systems", "color": COLORS.light_gray, "delay": 0.2},
        {"text": "", "color": COLORS.white, "delay": 0.5}
    ]
    
    # Show startup sequence with animation
    for message in startup_messages:
        print_text(message.text, message.color)
        await get_tree().create_timer(message.delay * (1.0 / current_text_speed)).timeout
    
    # Show command prompt
    show_prompt()

# ================ INPUT HANDLING ================
func _on_command_submitted(text):
    if not input_allowed:
        return
    
    # Add command to history
    if text.strip_edges() != "":
        command_history.append(text)
        command_history_index = command_history.size()
    
    # Process the command
    process_command(text)
    
    # Clear input field
    command_input.text = ""

func _gui_input(event):
    # Handle special keys
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_UP:
            # Navigate command history up
            if command_history.size() > 0 and command_history_index > 0:
                command_history_index -= 1
                command_input.text = command_history[command_history_index]
                command_input.caret_position = command_input.text.length()
            get_viewport().set_input_as_handled()
        
        elif event.keycode == KEY_DOWN:
            # Navigate command history down
            if command_history.size() > 0 and command_history_index < command_history.size() - 1:
                command_history_index += 1
                command_input.text = command_history[command_history_index]
                command_input.caret_position = command_input.text.length()
            elif command_history_index == command_history.size() - 1:
                command_history_index = command_history.size()
                command_input.text = ""
            get_viewport().set_input_as_handled()
        
        elif event.keycode == KEY_TAB:
            # Command completion
            complete_command()
            get_viewport().set_input_as_handled()
        
        elif event.keycode == KEY_F1:
            # Show help
            process_command("HELP")
            get_viewport().set_input_as_handled()
        
        elif event.keycode == KEY_F5:
            # Refresh display
            refresh_display()
            get_viewport().set_input_as_handled()
        
        elif event.keycode == KEY_ESCAPE:
            # Cancel current command
            command_input.text = ""
            get_viewport().set_input_as_handled()

func _on_cursor_timer_timeout():
    cursor_visible = !cursor_visible
    update_input_display()

func _on_text_speed_changed(value):
    current_text_speed = value
    status_bar.text = "DOS Terminal Ready | 4D Mode | Speed: " + str(current_text_speed) + "x | " + Time.get_datetime_string_from_system()

func complete_command():
    var input_text = command_input.text
    
    # If empty, do nothing
    if input_text.strip_edges() == "":
        return
    
    # Get all command parts
    var parts = input_text.split(" ", false)
    
    # If only one part, try to complete the command
    if parts.size() == 1:
        var partial_cmd = parts[0].to_upper()
        var completions = []
        
        # Check built-in commands
        for cmd in command_aliases.values():
            if cmd.begins_with(partial_cmd) and not completions.has(cmd):
                completions.append(cmd)
        
        # If only one completion found, use it
        if completions.size() == 1:
            command_input.text = completions[0] + " "
            command_input.caret_position = command_input.text.length()
        elif completions.size() > 1:
            # Show possible completions
            print_text("\n")
            for completion in completions:
                print_text(completion + "  ")
            print_text("\n")
            show_prompt()
            command_input.text = input_text
            command_input.grab_focus()
    else:
        # Try to complete file/dir names
        var cmd = parts[0].to_upper()
        var partial_path = ""
        
        if parts.size() > 1:
            partial_path = parts[parts.size() - 1]
        
        # Check if this is a command that uses files
        if cmd == "CD" or cmd == "DIR" or cmd == "TYPE" or cmd == "COPY" or cmd == "DEL":
            # Get possible completions
            var completions = _get_path_completions(partial_path)
            
            if completions.size() == 1:
                # Apply completion
                parts[parts.size() - 1] = completions[0]
                command_input.text = " ".join(parts) + " "
                command_input.caret_position = command_input.text.length()
            elif completions.size() > 1:
                # Show possible completions
                print_text("\n")
                for completion in completions:
                    print_text(completion + "  ")
                print_text("\n")
                show_prompt()
                command_input.text = input_text
                command_input.grab_focus()

func _get_path_completions(partial_path):
    var completions = []
    
    # Resolve the directory to look in
    var dir_path = current_directory
    var partial_name = partial_path
    
    # If partial path contains directory separators, split it
    if partial_path.find("\\") >= 0:
        var last_separator = partial_path.rfind("\\")
        if last_separator >= 0:
            dir_path = resolve_path(partial_path.substr(0, last_separator))
            partial_name = partial_path.substr(last_separator + 1)
    
    # Get directory contents
    var dir_node = get_directory_node(dir_path)
    if dir_node and dir_node.type == "directory":
        for item_name in dir_node.content:
            if item_name.begins_with(partial_name.to_upper()):
                # For directories, add trailing backslash
                if dir_node.content[item_name].type == "directory":
                    completions.append(item_name + "\\")
                else:
                    completions.append(item_name)
    
    return completions

# ================ COMMAND PROCESSING ================
func process_command(command_text):
    # Echo the command if echo is on
    if echo_mode:
        print_text("\n" + prompt + command_text + "\n", COLORS.light_gray)
    else:
        print_text("\n")
    
    # If empty command, just show prompt again
    if command_text.strip_edges() == "":
        show_prompt()
        return
    
    # Parse command and arguments
    var parts = command_text.split(" ", false)
    var command = parts[0].to_upper()
    var args = parts.slice(1)
    
    # Check for alias
    if command.to_lower() in command_aliases:
        command = command_aliases[command.to_lower()]
    
    # Execute appropriate command
    match command:
        "DIR":
            cmd_dir(args)
        "CD":
            cmd_cd(args)
        "CLS":
            cmd_cls(args)
        "TYPE":
            cmd_type(args)
        "ECHO":
            cmd_echo(args)
        "VER":
            cmd_ver(args)
        "HELP":
            cmd_help(args)
        "EXIT":
            cmd_exit(args)
        "MEMORY":
            cmd_memory(args)
        "COPY":
            cmd_copy(args)
        "DEL":
            cmd_del(args)
        "REN":
            cmd_ren(args)
        "MD":
            cmd_md(args)
        "RD":
            cmd_rd(args)
        "DATE":
            cmd_date(args)
        "TIME":
            cmd_time(args)
        "SYSTEM":
            cmd_system(args)
        "MANIFEST":
            cmd_manifest(args)
        "EXPLORE":
            cmd_explore(args)
        "SCENE":
            cmd_scene(args)
        "DIMENSION":
            cmd_dimension(args)
        "MOVIE":
            cmd_movie(args)
        "GAME":
            cmd_game(args)
        "MERGE":
            cmd_merge(args)
        "STATUS":
            cmd_status(args)
        "TIMELINE":
            cmd_timeline(args)
        "EXPORT":
            cmd_export(args)
        _:
            # Unknown command
            print_text("Bad command or file name\n", COLORS.light_red)
            show_prompt()

func show_prompt():
    # Update the prompt based on current directory
    var dir_name = current_directory
    if dir_name.ends_with("\\"):
        dir_name = dir_name.substr(0, dir_name.length() - 1)
    
    prompt = dir_name + ">"
    print_text(prompt, COLORS.light_gray)

# ================ COMMAND IMPLEMENTATIONS ================
func cmd_dir(args):
    var path = current_directory
    var wide_format = false
    var include_system = true
    
    # Process arguments
    for arg in args:
        if arg.begins_with("/"):
            # Handle switches
            match arg.to_upper():
                "/W":
                    wide_format = true
                "/A":
                    include_system = true
        else:
            # Handle path
            path = resolve_path(arg)
    
    # Get directory
    var dir_node = get_directory_node(path)
    if not dir_node or dir_node.type != "directory":
        print_text("Invalid directory\n", COLORS.light_red)
        show_prompt()
        return
    
    # Display directory header
    var header = " Directory of " + path + "\n\n"
    print_text(header, COLORS.white)
    
    # Get directory contents
    var dirs = []
    var files = []
    
    for item_name in dir_node.content:
        var item = dir_node.content[item_name]
        if item.type == "directory":
            dirs.append(item_name)
        else:
            files.append(item_name)
    
    # Sort directories and files
    dirs.sort()
    files.sort()
    
    # Display directories
    for dir_name in dirs:
        print_text(dir_name + "          ", COLORS.light_cyan)
        print_text("<DIR>          ", COLORS.white)
        print_text("\n")
    
    # Display files
    for file_name in files:
        print_text(file_name + "          ", COLORS.light_gray)
        # Show file size (just a placeholder in this simulation)
        print_text(str(randi() % 10000 + 100) + " bytes    ", COLORS.white)
        print_text("\n")
    
    # Display summary
    print_text("\n")
    print_text(str(files.size()) + " File(s)    " + str(randi() % 100000 + 10000) + " bytes\n", COLORS.white)
    print_text(str(dirs.size()) + " Dir(s)     " + str(randi() % 1000000 + 100000) + " bytes free\n", COLORS.white)
    
    show_prompt()

func cmd_cd(args):
    if args.size() == 0:
        # Display current directory
        print_text(current_directory + "\n", COLORS.white)
        show_prompt()
        return
    
    var new_path = args[0]
    
    # Handle special cases
    if new_path == "..":
        # Go up one level
        var parts = current_directory.split("\\")
        if parts.size() > 1:
            parts.pop_back()  # Remove last directory
            if parts.size() == 1:
                current_directory = parts[0] + "\\"  # Root directory
            else:
                current_directory = "\\".join(parts)
        else:
            # Already at root
            current_directory = parts[0] + "\\"
        
        show_prompt()
        return
    
    # Resolve the path
    new_path = resolve_path(new_path)
    
    # Check if directory exists
    var dir_node = get_directory_node(new_path)
    if dir_node and dir_node.type == "directory":
        current_directory = new_path
        if not current_directory.ends_with("\\"):
            current_directory += "\\"
    else:
        print_text("Invalid directory\n", COLORS.light_red)
    
    show_prompt()

func cmd_cls(args):
    clear_screen()
    show_prompt()

func cmd_type(args):
    if args.size() == 0:
        print_text("Required parameter missing\n", COLORS.light_red)
        show_prompt()
        return
    
    var file_path = resolve_path(args[0])
    
    # Get file
    var file_node = get_file_node(file_path)
    if not file_node or file_node.type != "file":
        print_text("File not found\n", COLORS.light_red)
        show_prompt()
        return
    
    # Display file contents
    print_text(file_node.content + "\n", COLORS.white)
    
    show_prompt()

func cmd_echo(args):
    if args.size() == 0:
        # Display echo status
        print_text("ECHO is " + ("on" if echo_mode else "off") + "\n", COLORS.white)
        show_prompt()
        return
    
    # Check for echo on/off
    var message = " ".join(args)
    if message.to_upper() == "ON":
        echo_mode = true
        print_text("ECHO is on\n", COLORS.white)
    elif message.to_upper() == "OFF":
        echo_mode = false
        print_text("ECHO is off\n", COLORS.white)
    else:
        # Echo the message
        print_text(message + "\n", COLORS.white)
    
    show_prompt()

func cmd_ver(args):
    print_text("DOS-Terminal [Version 1.0]\n", COLORS.white)
    print_text("4D Movie-Game Environment\n", COLORS.light_cyan)
    print_text("Current dimension mode: " + dimension_mode + "\n", COLORS.light_magenta)
    
    show_prompt()

func cmd_help(args):
    if args.size() > 0:
        # Show help for specific command
        var command = args[0].to_upper()
        show_command_help(command)
    else:
        // Show general help
        print_text("DOS-Terminal Help System\n", COLORS.yellow)
        print_text("======================\n", COLORS.yellow)
        print_text("\n")
        print_text("Standard Commands:\n", COLORS.light_cyan)
        print_text("  DIR      - Display directory contents\n", COLORS.white)
        print_text("  CD       - Change directory\n", COLORS.white)
        print_text("  CLS      - Clear screen\n", COLORS.white)
        print_text("  TYPE     - Display file contents\n", COLORS.white)
        print_text("  ECHO     - Display message or toggle echo mode\n", COLORS.white)
        print_text("  VER      - Display version information\n", COLORS.white)
        print_text("  HELP     - Display help information\n", COLORS.white)
        print_text("\n")
        print_text("4D Movie-Game Commands:\n", COLORS.light_magenta)
        print_text("  DIMENSION- Change dimensional mode\n", COLORS.white)
        print_text("  MANIFEST - Manifest reality objects\n", COLORS.white)
        print_text("  EXPLORE  - Explore 4D environment\n", COLORS.white)
        print_text("  SCENE    - Manage movie-game scenes\n", COLORS.white)
        print_text("  MOVIE    - Movie-related operations\n", COLORS.white)
        print_text("  GAME     - Game-related operations\n", COLORS.white)
        print_text("  MERGE    - Merge movie and game elements\n", COLORS.white)
        print_text("  TIMELINE - Manage 4D timelines\n", COLORS.white)
        print_text("\n")
        print_text("Type HELP command for more information on a specific command.\n", COLORS.light_gray)
    
    show_prompt()

func show_command_help(command):
    match command:
        "DIR":
            print_text("DIR [drive:][path][filename] [/W] [/A]\n", COLORS.yellow)
            print_text("  Displays a list of files and subdirectories in a directory.\n", COLORS.white)
            print_text("  /W   Uses wide list format.\n", COLORS.white)
            print_text("  /A   Displays all files.\n", COLORS.white)
        
        "CD":
            print_text("CD [drive:][path]\n", COLORS.yellow)
            print_text("  Changes the current directory.\n", COLORS.white)
            print_text("  CD without parameters displays the current directory.\n", COLORS.white)
            print_text("  CD .. moves to the parent directory.\n", COLORS.white)
        
        "CLS":
            print_text("CLS\n", COLORS.yellow)
            print_text("  Clears the screen.\n", COLORS.white)
        
        "TYPE":
            print_text("TYPE [drive:][path]filename\n", COLORS.yellow)
            print_text("  Displays the contents of a text file.\n", COLORS.white)
        
        "ECHO":
            print_text("ECHO [message]\n", COLORS.yellow)
            print_text("  Displays messages, or turns command echoing on or off.\n", COLORS.white)
            print_text("  ECHO without parameters shows the current echo setting.\n", COLORS.white)
            print_text("  ECHO ON turns command echoing on.\n", COLORS.white)
            print_text("  ECHO OFF turns command echoing off.\n", COLORS.white)
        
        "DIMENSION":
            print_text("DIMENSION [mode]\n", COLORS.yellow)
            print_text("  Changes the dimensional mode of the environment.\n", COLORS.white)
            print_text("  Available modes: 1D, 2D, 3D, 4D, 5D\n", COLORS.white)
            print_text("  DIMENSION without parameters shows the current mode.\n", COLORS.white)
        
        "MANIFEST":
            print_text("MANIFEST [entity] [parameters]\n", COLORS.yellow)
            print_text("  Creates and manifests reality objects from definitions.\n", COLORS.white)
            print_text("  MANIFEST SCENE - Manifests a scene in the current reality.\n", COLORS.white)
            print_text("  MANIFEST ENTITY - Creates an entity in the current scene.\n", COLORS.white)
            print_text("  MANIFEST RULE - Establishes a new rule in the reality.\n", COLORS.white)
        
        "SCENE":
            print_text("SCENE [operation] [parameters]\n", COLORS.yellow)
            print_text("  Manages movie-game scenes.\n", COLORS.white)
            print_text("  SCENE LIST - Lists all available scenes.\n", COLORS.white)
            print_text("  SCENE LOAD number - Loads a specific scene.\n", COLORS.white)
            print_text("  SCENE CREATE name - Creates a new scene.\n", COLORS.white)
            print_text("  SCENE DELETE number - Removes a scene.\n", COLORS.white)
        
        "MERGE":
            print_text("MERGE [source1] [source2] [destination]\n", COLORS.yellow)
            print_text("  Combines movie and game elements into a unified reality.\n", COLORS.white)
            print_text("  MERGE MOVIE GAME - Merges movie and game into default output.\n", COLORS.white)
            print_text("  MERGE SCENE1 SCENE2 - Combines two scenes into one.\n", COLORS.white)
        
        _:
            print_text("No help available for " + command + "\n", COLORS.light_red)

func cmd_exit(args):
    print_text("Exiting DOS-Terminal...\n", COLORS.white)
    # In a real implementation, this would close the terminal or switch modes
    await get_tree().create_timer(1.0 * (1.0 / current_text_speed)).timeout
    show_prompt()

func cmd_memory(args):
    print_text("Memory Status:\n", COLORS.yellow)
    print_text("=============\n", COLORS.yellow)
    print_text("\n")
    print_text("Conventional Memory: 640K\n", COLORS.white)
    print_text("Extended Memory:    " + str(randi() % 64000 + 1000) + "K\n", COLORS.white)
    print_text("Reality Memory:     " + str(randi() % 999999 + 100000) + "K\n", COLORS.light_magenta)
    print_text("Dimensional Cache:  " + str(randi() % 99999 + 10000) + "K\n", COLORS.light_cyan)
    print_text("\n")
    print_text("Memory allocation by dimension:\n", COLORS.light_cyan)
    print_text("1D: " + str(randi() % 100) + "%\n", COLORS.white)
    print_text("2D: " + str(randi() % 100) + "%\n", COLORS.white)
    print_text("3D: " + str(randi() % 100) + "%\n", COLORS.white)
    print_text("4D: " + str(randi() % 100) + "%\n", COLORS.white)
    
    show_prompt()

func cmd_copy(args):
    # Simplified copy command
    if args.size() < 2:
        print_text("Required parameter missing\n", COLORS.light_red)
        show_prompt()
        return
    
    var source_path = resolve_path(args[0])
    var dest_path = resolve_path(args[1])
    
    print_text("        1 file(s) copied.\n", COLORS.white)
    show_prompt()

func cmd_del(args):
    # Simplified delete command
    if args.size() < 1:
        print_text("Required parameter missing\n", COLORS.light_red)
        show_prompt()
        return
    
    var file_path = resolve_path(args[0])
    
    print_text("        1 file(s) deleted.\n", COLORS.white)
    show_prompt()

func cmd_ren(args):
    # Simplified rename command
    if args.size() < 2:
        print_text("Required parameter missing\n", COLORS.light_red)
        show_prompt()
        return
    
    var old_path = resolve_path(args[0])
    var new_name = args[1]
    
    print_text("        File renamed.\n", COLORS.white)
    show_prompt()

func cmd_md(args):
    # Simplified make directory command
    if args.size() < 1:
        print_text("Required parameter missing\n", COLORS.light_red)
        show_prompt()
        return
    
    var dir_path = resolve_path(args[0])
    
    print_text("        Directory created.\n", COLORS.white)
    show_prompt()

func cmd_rd(args):
    # Simplified remove directory command
    if args.size() < 1:
        print_text("Required parameter missing\n", COLORS.light_red)
        show_prompt()
        return
    
    var dir_path = resolve_path(args[0])
    
    print_text("        Directory removed.\n", COLORS.white)
    show_prompt()

func cmd_date(args):
    var current_date = Time.get_date_dict_from_system()
    print_text("Current date: " + str(current_date.month) + "-" + 
              str(current_date.day) + "-" + str(current_date.year) + "\n", COLORS.white)
    show_prompt()

func cmd_time(args):
    var current_time = Time.get_time_dict_from_system()
    print_text("Current time: " + str(current_time.hour) + ":" + 
              str(current_time.minute) + ":" + str(current_time.second) + "\n", COLORS.white)
    show_prompt()

# ================ 4D MOVIE-GAME SPECIFIC COMMANDS ================
func cmd_dimension(args):
    if args.size() == 0:
        # Show current dimension mode
        print_text("Current dimension mode: " + dimension_mode + "\n", COLORS.light_magenta)
        show_prompt()
        return
    
    var new_mode = args[0].to_upper()
    if new_mode in ["1D", "2D", "3D", "4D", "5D"]:
        dimension_mode = new_mode
        print_text("Dimension mode set to: " + dimension_mode + "\n", COLORS.light_magenta)
        
        # Apply visual effect based on dimension
        match dimension_mode:
            "1D":
                current_text_color = COLORS.white
                current_bg_color = COLORS.black
            "2D":
                current_text_color = COLORS.light_cyan
                current_bg_color = COLORS.blue
            "3D":
                current_text_color = COLORS.yellow
                current_bg_color = COLORS.dark_gray
            "4D":
                current_text_color = COLORS.light_magenta
                current_bg_color = COLORS.black
            "5D":
                current_text_color = COLORS.light_green
                current_bg_color = COLORS.magenta
    else:
        print_text("Invalid dimension mode. Use 1D, 2D, 3D, 4D, or 5D.\n", COLORS.light_red)
    
    # Update status bar
    status_bar.text = "DOS Terminal Ready | " + dimension_mode + " Mode | Speed: " + str(current_text_speed) + "x | " + Time.get_datetime_string_from_system()
    
    show_prompt()

func cmd_manifest(args):
    if args.size() == 0:
        print_text("Required parameter missing\n", COLORS.light_red)
        show_prompt()
        return
    
    var entity_type = args[0].to_upper()
    var entity_params = args.slice(1)
    
    print_text("Manifesting " + entity_type + "...\n", COLORS.light_magenta)
    
    # Simulate manifestation process
    for i in range(3):
        print_text(".", COLORS.light_magenta)
        await get_tree().create_timer(0.3 * (1.0 / current_text_speed)).timeout
    
    print_text("\n")
    
    match entity_type:
        "SCENE":
            var scene_num = "001"
            if entity_params.size() > 0:
                scene_num = entity_params[0]
            print_text("Scene " + scene_num + " successfully manifested in current reality.\n", COLORS.light_green)
        
        "ENTITY":
            var entity_name = "DEFAULT"
            if entity_params.size() > 0:
                entity_name = entity_params[0]
            print_text("Entity '" + entity_name + "' manifested in current scene.\n", COLORS.light_green)
        
        "RULE":
            var rule_name = "GRAVITY"
            if entity_params.size() > 0:
                rule_name = entity_params[0]
            print_text("Rule '" + rule_name + "' established in current reality.\n", COLORS.light_green)
        
        _:
            print_text("Unknown entity type. Valid types: SCENE, ENTITY, RULE\n", COLORS.light_red)
    
    show_prompt()

func cmd_explore(args):
    print_text("Initiating " + dimension_mode + " exploration mode...\n", COLORS.light_cyan)
    
    # Simulate exploration
    input_allowed = false
    
    for i in range(5):
        print_text("Scanning dimensional layer " + str(i+1) + "...\n", COLORS.light_magenta)
        await get_tree().create_timer(0.5 * (1.0 / current_text_speed)).timeout
        
        # Print random discoveries
        var discoveries = [
            "Found reality anchor point.",
            "Detected temporal fluctuation.",
            "Identified entity cluster.",
            "Mapped spatial coordinates.",
            "Discovered hidden passage.",
            "Located memory fragment.",
            "Established dimensional bridge."
        ]
        
        print_text("  " + discoveries[randi() % discoveries.size()] + "\n", COLORS.light_green)
        await get_tree().create_timer(0.3 * (1.0 / current_text_speed)).timeout
    
    print_text("\nExploration complete. Reality map updated.\n", COLORS.light_cyan)
    
    input_allowed = true
    show_prompt()

func cmd_scene(args):
    if args.size() == 0:
        print_text("Required parameter missing\n", COLORS.light_red)
        show_prompt()
        return
    
    var operation = args[0].to_upper()
    var operation_params = args.slice(1)
    
    match operation:
        "LIST":
            print_text("Available Scenes:\n", COLORS.yellow)
            print_text("================\n", COLORS.yellow)
            
            for i in range(9):
                var scene_num = "00" + str(i+1)
                print_text("SCENE." + scene_num + "  ", COLORS.light_cyan)
                
                # Add random status
                var statuses = ["Active", "Inactive", "Pending", "Completed", "In Progress"]
                print_text(statuses[randi() % statuses.size()] + "\n", COLORS.white)
        
        "LOAD":
            if operation_params.size() == 0:
                print_text("Scene number required\n", COLORS.light_red)
            else:
                var scene_num = operation_params[0]
                print_text("Loading SCENE." + scene_num + "...\n", COLORS.light_magenta)
                
                # Simulate loading
                for i in range(3):
                    print_text(".", COLORS.light_magenta)
                    await get_tree().create_timer(0.3 * (1.0 / current_text_speed)).timeout
                
                print_text("\nScene loaded successfully.\n", COLORS.light_green)
        
        "CREATE":
            if operation_params.size() == 0:
                print_text("Scene name required\n", COLORS.light_red)
            else:
                var scene_name = operation_params[0]
                print_text("Creating new scene: " + scene_name + "\n", COLORS.light_magenta)
                
                # Simulate creation
                await get_tree().create_timer(1.0 * (1.0 / current_text_speed)).timeout
                
                var scene_num = "0" + str(randi() % 90 + 10)
                print_text("Scene created: SCENE." + scene_num + "\n", COLORS.light_green)
        
        "DELETE":
            if operation_params.size() == 0:
                print_text("Scene number required\n", COLORS.light_red)
            else:
                var scene_num = operation_params[0]
                print_text("Deleting SCENE." + scene_num + "...\n", COLORS.light_red)
                
                # Simulate deletion
                await get_tree().create_timer(0.7 * (1.0 / current_text_speed)).timeout
                
                print_text("Scene deleted.\n", COLORS.light_green)
        
        _:
            print_text("Unknown operation. Valid operations: LIST, LOAD, CREATE, DELETE\n", COLORS.light_red)
    
    show_prompt()

func cmd_movie(args):
    if args.size() == 0:
        print_text("Movie subsystem status: ACTIVE\n", COLORS.light_cyan)
        print_text("Current project: MOVIE.4DM\n", COLORS.white)
        print_text("Timeline segments: 12\n", COLORS.white)
        print_text("Reality integration: ENABLED\n", COLORS.white)
        show_prompt()
        return
    
    var operation = args[0].to_upper()
    var operation_params = args.slice(1)
    
    match operation:
        "RENDER":
            print_text("Rendering 4D movie sequence...\n", COLORS.light_magenta)
            
            # Simulate rendering
            input_allowed = false
            
            for i in range(5):
                print_text("Rendering dimension " + str(i+1) + " of " + dimension_mode + "...\n", COLORS.light_cyan)
                
                # Show progress bar
                print_text("[", COLORS.white)
                for j in range(20):
                    print_text("█", COLORS.light_green)
                    await get_tree().create_timer(0.1 * (1.0 / current_text_speed)).timeout
                print_text("] 100%\n", COLORS.white)
            
            print_text("\nRendering complete. Movie exported to MOVIE.4DM\n", COLORS.light_green)
            
            input_allowed = true
        
        "PLAY":
            print_text("Playing movie sequence. Press ESC to stop...\n", COLORS.light_cyan)
            
            # Simulate playback
            input_allowed = false
            
            for i in range(10):
                var scenes = ["Title", "Introduction", "Rising Action", "Conflict", 
                            "Climax", "Falling Action", "Resolution", "Credits"]
                
                print_text("Playing: " + scenes[i % scenes.size()] + "\n", COLORS.light_magenta)
                await get_tree().create_timer(1.0 * (1.0 / current_text_speed)).timeout
            
            print_text("\nPlayback complete.\n", COLORS.light_green)
            
            input_allowed = true
        
        "EDIT":
            print_text("Entering movie edit mode...\n", COLORS.light_cyan)
            print_text("Editor not implemented in this version.\n", COLORS.light_red)
        
        _:
            print_text("Unknown operation. Valid operations: RENDER, PLAY, EDIT\n", COLORS.light_red)
    
    show_prompt()

func cmd_game(args):
    if args.size() == 0:
        print_text("Game subsystem status: ACTIVE\n", COLORS.light_cyan)
        print_text("Current project: GAME.REALITY\n", COLORS.white)
        print_text("Interactive scenes: 9\n", COLORS.white)
        print_text("Reality anchors: STABLE\n", COLORS.white)
        show_prompt()
        return
    
    var operation = args[0].to_upper()
    var operation_params = args.slice(1)
    
    match operation:
        "PLAY":
            print_text("Launching game experience...\n", COLORS.light_magenta)
            
            # Simulate game startup
            input_allowed = false
            
            print_text("Initializing reality engine...\n", COLORS.light_cyan)
            await get_tree().create_timer(0.7 * (1.0 / current_text_speed)).timeout
            
            print_text("Loading game world...\n", COLORS.light_cyan)
            await get_tree().create_timer(1.0 * (1.0 / current_text_speed)).timeout
            
            print_text("Establishing player presence...\n", COLORS.light_cyan)
            await get_tree().create_timer(0.5 * (1.0 / current_text_speed)).timeout
            
            print_text("\nWelcome to the Game Reality! Use your imagination to interact.\n", COLORS.light_green)
            
            # Show game interface simulation
            print_text("\n╔════════════════════════════════════════════════════════╗\n", COLORS.yellow)
            print_text("║                   REALITY ENGINE                       ║\n", COLORS.yellow)
            print_text("╟────────────────────────────────────────────────────────╢\n", COLORS.yellow)
            print_text("║  Location: Starting Area                               ║\n", COLORS.white)
            print_text("║  Objects:  Portal, Cube, Book                          ║\n", COLORS.white)
            print_text("║  Status:   Exploring                                   ║\n", COLORS.white)
            print_text("╟────────────────────────────────────────────────────────╢\n", COLORS.yellow)
            print_text("║  What would you like to do?                            ║\n", COLORS.light_cyan)
            print_text("╚════════════════════════════════════════════════════════╝\n", COLORS.yellow)
            
            await get_tree().create_timer(2.0 * (1.0 / current_text_speed)).timeout
            print_text("\nGame session ended.\n", COLORS.light_green)
            
            input_allowed = true
        
        "DEBUG":
            print_text("Entering game debug mode...\n", COLORS.light_cyan)
            
            # Show debug info
            print_text("Debug Information:\n", COLORS.yellow)
            print_text("=================\n", COLORS.yellow)
            print_text("Engine Version: 1.0.4\n", COLORS.white)
            print_text("Physics Status: Stable\n", COLORS.white)
            print_text("Entity Count: " + str(randi() % 100 + 50) + "\n", COLORS.white)
            print_text("Memory Usage: " + str(randi() % 100) + "%\n", COLORS.white)
            print_text("Reality Stability: " + str(randi() % 100) + "%\n", COLORS.white)
            print_text("Dimension Integrity: " + str(randi() % 100) + "%\n", COLORS.white)
        
        "EDIT":
            print_text("Entering game edit mode...\n", COLORS.light_cyan)
            print_text("Editor not implemented in this version.\n", COLORS.light_red)
        
        _:
            print_text("Unknown operation. Valid operations: PLAY, DEBUG, EDIT\n", COLORS.light_red)
    
    show_prompt()

func cmd_merge(args):
    if args.size() < 2:
        print_text("Required parameters missing\n", COLORS.light_red)
        show_prompt()
        return
    
    var source1 = args[0].to_upper()
    var source2 = args[1].to_upper()
    var destination = "OUTPUT"
    
    if args.size() > 2:
        destination = args[2]
    
    print_text("Merging " + source1 + " with " + source2 + " into " + destination + "...\n", COLORS.light_magenta)
    
    # Simulate merging process
    input_allowed = false
    
    var total_steps = 10
    for i in range(total_steps):
        var step_name = ""
        match i:
            0: step_name = "Analyzing source structures"
            1: step_name = "Mapping dimensional coordinates"
            2: step_name = "Aligning reality anchors"
            3: step_name = "Resolving conflicts"
            4: step_name = "Merging timelines"
            5: step_name = "Integrating entities"
            6: step_name = "Synchronizing rules"
            7: step_name = "Stabilizing merged reality"
            8: step_name = "Verifying consistency"
            9: step_name = "Finalizing merge"
        
        print_text("Step " + str(i+1) + "/" + str(total_steps) + ": " + step_name + "...\n", COLORS.light_cyan)
        
        # Progress bar
        print_text("[", COLORS.white)
        for j in range(20):
            print_text("█", COLORS.light_green)
            await get_tree().create_timer(0.05 * (1.0 / current_text_speed)).timeout
        print_text("] 100%\n", COLORS.white)
    
    print_text("\nMerge complete! Created 4D movie-game experience.\n", COLORS.light_green)
    
    input_allowed = true
    show_prompt()

func cmd_status(args):
    print_text("DOS-Terminal Status Report\n", COLORS.yellow)
    print_text("========================\n", COLORS.yellow)
    print_text("\n")
    
    print_text("System Information\n", COLORS.light_cyan)
    print_text("-----------------\n", COLORS.light_cyan)
    print_text("Terminal Mode:    4D Movie-Game Environment\n", COLORS.white)
    print_text("Current Directory: " + current_directory + "\n", COLORS.white)
    print_text("Dimension Mode:   " + dimension_mode + "\n", COLORS.white)
    print_text("Text Speed:       " + str(current_text_speed) + "x\n", COLORS.white)
    print_text("Echo Mode:        " + ("ON" if echo_mode else "OFF") + "\n", COLORS.white)
    print_text("Simulation Mode:  " + ("ON" if simulation_mode else "OFF") + "\n", COLORS.white)
    print_text("\n")
    
    print_text("Project Status\n", COLORS.light_magenta)
    print_text("-------------\n", COLORS.light_magenta)
    print_text("Movie Status:     ACTIVE\n", COLORS.white)
    print_text("Game Status:      ACTIVE\n", COLORS.white)
    print_text("Merge Status:     " + (["PENDING", "IN PROGRESS", "COMPLETE"][randi() % 3]) + "\n", COLORS.white)
    print_text("Reality Anchors:  " + str(randi() % 10 + 5) + "\n", COLORS.white)
    print_text("Timeline Branches: " + str(randi() % 20 + 10) + "\n", COLORS.white)
    print_text("\n")
    
    print_text("Memory Usage\n", COLORS.light_green)
    print_text("------------\n", COLORS.light_green)
    print_text("Total Memory:     " + str(randi() % 1000 + 500) + "MB\n", COLORS.white)
    print_text("Available Memory: " + str(randi() % 500 + 100) + "MB\n", COLORS.white)
    print_text("Reality Usage:    " + str(randi() % 100) + "%\n", COLORS.white)
    
    show_prompt()

func cmd_timeline(args):
    if args.size() == 0:
        print_text("Timeline management system\n", COLORS.yellow)
        print_text("Current timeline: MAIN\n", COLORS.white)
        print_text("Timeline branches: " + str(randi() % 10 + 3) + "\n", COLORS.white)
        print_text("Timeline stability: " + str(randi() % 100) + "%\n", COLORS.white)
        show_prompt()
        return
    
    var operation = args[0].to_upper()
    var operation_params = args.slice(1)
    
    match operation:
        "LIST":
            print_text("Available Timelines:\n", COLORS.yellow)
            print_text("===================\n", COLORS.yellow)
            
            var timelines = ["MAIN", "ALTERNATE_1", "ALTERNATE_2", "PARADOX_BRANCH", 
                           "QUANTUM_FORK", "STABLE_LOOP", "DIVERGENT_PATH"]
            
            for timeline in timelines:
                print_text(timeline + "  ", COLORS.light_cyan)
                
                # Add random status
                var statuses = ["Active", "Inactive", "Stable", "Unstable", "Locked"]
                print_text(statuses[randi() % statuses.size()] + "\n", COLORS.white)
        
        "SWITCH":
            if operation_params.size() == 0:
                print_text("Timeline name required\n", COLORS.light_red)
            else:
                var timeline = operation_params[0]
                print_text("Switching to timeline: " + timeline + "\n", COLORS.light_magenta)
                
                # Simulate timeline switch
                for i in range(3):
                    print_text(".", COLORS.light_magenta)
                    await get_tree().create_timer(0.3 * (1.0 / current_text_speed)).timeout
                
                print_text("\nTimeline switch complete.\n", COLORS.light_green)
        
        "BRANCH":
            if operation_params.size() == 0:
                print_text("New timeline name required\n", COLORS.light_red)
            else:
                var new_timeline = operation_params[0]
                print_text("Creating branch from current timeline: " + new_timeline + "\n", COLORS.light_magenta)
                
                # Simulate branch creation
                await get_tree().create_timer(1.0 * (1.0 / current_text_speed)).timeout
                
                print_text("Timeline branch created successfully.\n", COLORS.light_green)
        
        "MERGE":
            if operation_params.size() < 2:
                print_text("Source and destination timelines required\n", COLORS.light_red)
            else:
                var source = operation_params[0]
                var destination = operation_params[1]
                
                print_text("Merging timeline " + source + " into " + destination + "...\n", COLORS.light_magenta)
                
                # Simulate merge
                for i in range(5):
                    print_text(".", COLORS.light_magenta)
                    await get_tree().create_timer(0.3 * (1.0 / current_text_speed)).timeout
                
                # Random success/failure
                if randf() < 0.8:
                    print_text("\nTimeline merge successful.\n", COLORS.light_green)
                else:
                    print_text("\nERROR: Timeline merge failed due to paradox.\n", COLORS.light_red)
        
        _:
            print_text("Unknown operation. Valid operations: LIST, SWITCH, BRANCH, MERGE\n", COLORS.light_red)
    
    show_prompt()

func cmd_system(args):
    if args.size() == 0:
        print_text("System management interface\n", COLORS.yellow)
        print_text("Usage: SYSTEM [operation] [parameters]\n", COLORS.white)
        print_text("Operations: CONFIG, MODE, RESET\n", COLORS.white)
        show_prompt()
        return
    
    var operation = args[0].to_upper()
    var operation_params = args.slice(1)
    
    match operation:
        "CONFIG":
            print_text("System Configuration:\n", COLORS.yellow)
            print_text("====================\n", COLORS.yellow)
            print_text("Terminal Mode:    4D Movie-Game\n", COLORS.white)
            print_text("Dimension:        " + dimension_mode + "\n", COLORS.white)
            print_text("Reality Engine:   ACTIVE\n", COLORS.white)
            print_text("Timeline System:  ENABLED\n", COLORS.white)
            print_text("Memory Mode:      EXPANDED\n", COLORS.white)
            print_text("Display Mode:     TEXT\n", COLORS.white)
            print_text("ANSI Colors:      " + ("ENABLED" if ansi_colors_enabled else "DISABLED") + "\n", COLORS.white)
        
        "MODE":
            if operation_params.size() == 0:
                print_text("Mode parameter required\n", COLORS.light_red)
            else:
                var mode = operation_params[0].to_upper()
                
                match mode:
                    "TEXT":
                        print_text("Switching to TEXT mode...\n", COLORS.light_cyan)
                    "GRAPHICS":
                        print_text("Switching to GRAPHICS mode...\n", COLORS.light_cyan)
                        print_text("ERROR: GRAPHICS mode not implemented in this version.\n", COLORS.light_red)
                    "REALITY":
                        print_text("Switching to REALITY mode...\n", COLORS.light_cyan)
                        print_text("WARNING: REALITY mode engages full dimensional participation.\n", COLORS.yellow)
                    _:
                        print_text("Unknown mode. Valid modes: TEXT, GRAPHICS, REALITY\n", COLORS.light_red)
        
        "RESET":
            print_text("WARNING: System reset requested.\n", COLORS.light_red)
            print_text("This will restart the terminal and reset state. Continue? (Y/N)\n", COLORS.yellow)
            
            # In a real implementation, would wait for Y/N input
            await get_tree().create_timer(1.0 * (1.0 / current_text_speed)).timeout
            
            print_text("Reset cancelled.\n", COLORS.light_green)
        
        _:
            print_text("Unknown operation. Valid operations: CONFIG, MODE, RESET\n", COLORS.light_red)
    
    show_prompt()

func cmd_export(args):
    if args.size() < 2:
        print_text("Required parameters missing\n", COLORS.light_red)
        print_text("Usage: EXPORT [source] [format]\n", COLORS.white)
        show_prompt()
        return
    
    var source = args[0].to_upper()
    var format = args[1].to_upper()
    
    print_text("Exporting " + source + " to " + format + " format...\n", COLORS.light_magenta)
    
    # Simulate export process
    input_allowed = false
    
    for i in range(5):
        print_text("Processing part " + str(i+1) + " of 5...\n", COLORS.light_cyan)
        
        # Progress bar
        print_text("[", COLORS.white)
        for j in range(20):
            print_text("█", COLORS.light_green)
            await get_tree().create_timer(0.05 * (1.0 / current_text_speed)).timeout
        print_text("] 100%\n", COLORS.white)
    
    print_text("\nExport complete! File saved as " + source + "." + format + "\n", COLORS.light_green)
    
    input_allowed = true
    show_prompt()

# ================ TERMINAL UTILITIES ================
func print_text(text, color = null):
    if color == null:
        color = current_text_color
    
    # Add text with color
    terminal_display.append_text("[color=#" + color.to_html(false) + "]" + text + "[/color]")

func clear_screen():
    terminal_display.text = ""
    screen_buffer.clear()
    
    # Reset screen buffer
    for i in range(visible_lines):
        screen_buffer.append("")

func update_input_display():
    # Update the command input field
    if cursor_visible:
        command_input.placeholder_text = "Enter command..."
    else:
        command_input.placeholder_text = ""

func refresh_display():
    # Force refresh the terminal display
    var current_text = terminal_display.text
    terminal_display.text = ""
    terminal_display.text = current_text
    
    # Update the status bar
    status_bar.text = "DOS Terminal Ready | " + dimension_mode + " Mode | Speed: " + str(current_text_speed) + "x | " + Time.get_datetime_string_from_system()

# ================ FILE SYSTEM UTILITIES ================
func resolve_path(path):
    # Handle absolute paths
    if path.begins_with("C:\\") or path.begins_with("C:/"):
        # Convert forward slashes to backslashes
        path = path.replace("/", "\\")
        return path
    
    # Handle relative paths
    var current = current_directory
    if not current.ends_with("\\"):
        current += "\\"
    
    return current + path

func get_directory_node(path):
    # Parse path
    path = path.replace("/", "\\")  # Normalize separators
    
    # Handle trailing backslash
    if path.ends_with("\\"):
        path = path.substr(0, path.length() - 1)
    
    # Split path into parts
    var parts = path.split("\\")
    
    # Check for root directory
    if parts.size() > 0 and parts[0] == "C:":
        var current_node = file_system["C:\\"]
        
        # Navigate through path
        for i in range(1, parts.size()):
            var part = parts[i]
            
            # Check if part exists in current node
            if part in current_node.content:
                current_node = current_node.content[part]
            else:
                return null  # Path not found
        
        return current_node
    
    return null  # Invalid path

func get_file_node(path):
    # Handle trailing backslash
    if path.ends_with("\\"):
        path = path.substr(0, path.length() - 1)
    
    # Split path into directory and filename
    var last_separator = path.rfind("\\")
    if last_separator >= 0:
        var dir_path = path.substr(0, last_separator)
        var filename = path.substr(last_separator + 1)
        
        # Get directory
        var dir_node = get_directory_node(dir_path)
        if dir_node and dir_node.type == "directory":
            # Check if file exists
            if filename in dir_node.content:
                return dir_node.content[filename]
    
    return null  # File not found