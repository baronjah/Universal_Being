extends Node

class_name AsciiAnimationSystem

# ASCII Animation System for LuminusOS
# Creates animated ASCII art for terminal visualizations

# Signals
signal animation_frame(animation_name, frame_number, frame_content)
signal animation_started(animation_name)
signal animation_stopped(animation_name)
signal animation_completed(animation_name)

# Animation Collection
var animations = {
    "falling_leaf": [
        # Frame 1
        [
            "    *    ",
            "         ",
            "         ",
            "         ",
            "         ",
            "         ",
            "         "
        ],
        # Frame 2
        [
            "         ",
            "   *     ",
            "         ",
            "         ",
            "         ",
            "         ",
            "         "
        ],
        # Frame 3
        [
            "         ",
            "         ",
            "    *    ",
            "         ",
            "         ",
            "         ",
            "         "
        ],
        # Frame 4
        [
            "         ",
            "         ",
            "         ",
            "   *     ",
            "         ",
            "         ",
            "         "
        ],
        # Frame 5
        [
            "         ",
            "         ",
            "         ",
            "         ",
            "    *    ",
            "         ",
            "         "
        ],
        # Frame 6
        [
            "         ",
            "         ",
            "         ",
            "         ",
            "         ",
            "   *     ",
            "         "
        ],
        # Frame 7
        [
            "         ",
            "         ",
            "         ",
            "         ",
            "         ",
            "         ",
            "    *    "
        ]
    ],
    "tree": [
        # Frame 1 - Still tree
        [
            "    ^    ",
            "   / \\   ",
            "  /   \\  ",
            " /     \\ ",
            "/       \\",
            "    |    ",
            "    |    ",
            "    |    ",
            "~~~~|~~~~"
        ],
        # Frame 2 - Tree swaying slightly right
        [
            "     ^   ",
            "    / \\  ",
            "   /   \\ ",
            "  /     \\",
            " /       ",
            "    |    ",
            "    |    ",
            "    |    ",
            "~~~~|~~~~"
        ],
        # Frame 3 - Tree swaying more right
        [
            "      ^  ",
            "     / \\ ",
            "    /   \\",
            "   /     ",
            "  /      ",
            "    |    ",
            "    |    ",
            "    |    ",
            "~~~~|~~~~"
        ],
        # Frame 4 - Tree swaying back to center
        [
            "     ^   ",
            "    / \\  ",
            "   /   \\ ",
            "  /     \\",
            " /       ",
            "    |    ",
            "    |    ",
            "    |    ",
            "~~~~|~~~~"
        ],
        # Frame 5 - Back to still tree
        [
            "    ^    ",
            "   / \\   ",
            "  /   \\  ",
            " /     \\ ",
            "/       \\",
            "    |    ",
            "    |    ",
            "    |    ",
            "~~~~|~~~~"
        ],
        # Frame 6 - Tree swaying slightly left
        [
            "   ^     ",
            "  / \\    ",
            " /   \\   ",
            "/     \\  ",
            "       \\ ",
            "    |    ",
            "    |    ",
            "    |    ",
            "~~~~|~~~~"
        ],
        # Frame 7 - Tree swaying more left
        [
            "  ^      ",
            " / \\     ",
            "/   \\    ",
            "     \\   ",
            "      \\  ",
            "    |    ",
            "    |    ",
            "    |    ",
            "~~~~|~~~~"
        ],
        # Frame 8 - Tree swaying back to center
        [
            "   ^     ",
            "  / \\    ",
            " /   \\   ",
            "/     \\  ",
            "       \\ ",
            "    |    ",
            "    |    ",
            "    |    ",
            "~~~~|~~~~"
        ]
    ],
    "binary_rain": [
        # Frame 1
        [
            "1    0    ",
            "     1    ",
            "  0       ",
            "       1  ",
            "   1      ",
            "      0   ",
            " 1    1   ",
            "   0      "
        ],
        # Frame 2
        [
            "    0    1",
            "1    0    ",
            "     1    ",
            "  0       ",
            "       1  ",
            "   1      ",
            "      0   ",
            " 1    1   "
        ],
        # Frame 3
        [
            "   0      ",
            "    0    1",
            "1    0    ",
            "     1    ",
            "  0       ",
            "       1  ",
            "   1      ",
            "      0   "
        ],
        # Frame 4
        [
            "      0   ",
            "   0      ",
            "    0    1",
            "1    0    ",
            "     1    ",
            "  0       ",
            "       1  ",
            "   1      "
        ],
        # Frame 5
        [
            "   1      ",
            "      0   ",
            "   0      ",
            "    0    1",
            "1    0    ",
            "     1    ",
            "  0       ",
            "       1  "
        ],
        # Frame 6
        [
            "       1  ",
            "   1      ",
            "      0   ",
            "   0      ",
            "    0    1",
            "1    0    ",
            "     1    ",
            "  0       "
        ],
        # Frame 7
        [
            "  0       ",
            "       1  ",
            "   1      ",
            "      0   ",
            "   0      ",
            "    0    1",
            "1    0    ",
            "     1    "
        ],
        # Frame 8
        [
            "     1    ",
            "  0       ",
            "       1  ",
            "   1      ",
            "      0   ",
            "   0      ",
            "    0    1",
            "1    0    "
        ]
    ],
    "memory_fragment": [
        # Frame 1
        [
            "00000000000000000000000000000000",
            "00000000000000000000000000000000",
            "00000000000000000000000000000000"
        ],
        # Frame 2
        [
            "00000000000000000000000000000000",
            "00000000111100000000111100000000",
            "00000000000000000000000000000000"
        ],
        # Frame 3
        [
            "00000000000000000000000000000000",
            "00000011111111000011111111000000",
            "00000000000000000000000000000000"
        ],
        # Frame 4
        [
            "00001100000000110011000000001100",
            "00001111111111111111111111111100",
            "00001100000000110011000000001100"
        ],
        # Frame 5
        [
            "00111100000000111111000000001111",
            "00111111111111111111111111111111",
            "00111100000000111111000000001111"
        ],
        # Frame 6
        [
            "11111110000001111111100000011111",
            "11111111111111111111111111111111",
            "11111110000001111111100000011111"
        ],
        # Frame 7
        [
            "00111100000000111111000000001111",
            "00111111111111111111111111111111",
            "00111100000000111111000000001111"
        ],
        # Frame 8
        [
            "00001100000000110011000000001100",
            "00001111111111111111111111111100",
            "00001100000000110011000000001100"
        ],
        # Frame 9
        [
            "00000000000000000000000000000000",
            "00000011111111000011111111000000",
            "00000000000000000000000000000000"
        ],
        # Frame 10
        [
            "00000000000000000000000000000000",
            "00000000111100000000111100000000",
            "00000000000000000000000000000000"
        ]
    ],
    "spinning_cube": [
        # Frame 1
        [
            "  ┌───┐  ",
            "  │   │  ",
            "  │   │  ",
            "  └───┘  "
        ],
        # Frame 2
        [
            "   ┌─┐   ",
            "  /│ │\\  ",
            " / │ │ \\ ",
            "┌─┘ └─┐  ",
            "│     │  ",
            "└─────┘  "
        ],
        # Frame 3
        [
            "   ┌───┐ ",
            "  /│   │ ",
            " / │   │ ",
            "┌──┘   │ ",
            "│      │ ",
            "│      │ ",
            "└──────┘ "
        ],
        # Frame 4
        [
            " ┌──────┐",
            " │      │",
            " │      │",
            " │   ┌──┘",
            " │   │ \\ ",
            " │   │  \\",
            " └───┘   "
        ],
        # Frame 5
        [
            "  ┌─────┐",
            "  │     │",
            "  │     │",
            "  └─┐ ┌─┘",
            " / │ │ \\ ",
            "//  │ │  \\",
            "    └─┘   "
        ],
        # Frame 6
        [
            "  ┌───┐  ",
            "  │   │  ",
            "  │   │  ",
            "  └───┘  "
        ]
    ]
}

# Active animations
var active_animations = {}
var animation_timers = {}

# Color schemes for animations
var color_schemes = {
    "default": {
        "0": Color.WHITE,
        "1": Color.LIGHT_BLUE,
        "*": Color.GREEN,
        "/": Color.GREEN,
        "\\": Color.GREEN,
        "^": Color.GREEN,
        "|": Color.BROWN,
        "~": Color.BLUE
    },
    "matrix": {
        "0": Color("009900"),
        "1": Color("00FF00"),
        "*": Color("00FF00"),
        "/": Color("00DD00"),
        "\\": Color("00DD00"),
        "^": Color("00FF00"),
        "|": Color("00CC00"),
        "~": Color("00AA00")
    },
    "ethereal": {
        "0": Color("444444"),
        "1": Color("AAAAFF"),
        "*": Color("FFAA77"),
        "/": Color("77AAFF"),
        "\\": Color("77AAFF"),
        "^": Color("FFAA77"),
        "|": Color("AA88CC"),
        "~": Color("77CCFF")
    }
}

# Current color scheme
var current_color_scheme = "default"

func _ready():
    print("ASCII Animation System initialized")
    print("Available animations: " + ", ".join(animations.keys()))

func start_animation(name, fps = 2.0, loop = true, color_scheme = null):
    if not animations.has(name):
        print("Animation not found: " + name)
        return false
    
    # Stop animation if already running
    if is_animation_running(name):
        stop_animation(name)
    
    # Setup animation data
    active_animations[name] = {
        "frames": animations[name],
        "current_frame": 0,
        "total_frames": animations[name].size(),
        "fps": fps,
        "loop": loop,
        "color_scheme": color_scheme if color_scheme else current_color_scheme,
        "started_at": Time.get_ticks_msec()
    }
    
    # Create and start timer
    var timer = Timer.new()
    timer.name = "AnimTimer_" + name
    timer.wait_time = 1.0 / fps
    timer.one_shot = false
    timer.autostart = true
    timer.connect("timeout", Callable(self, "_on_animation_frame").bind(name))
    
    add_child(timer)
    animation_timers[name] = timer
    
    # Emit first frame immediately
    _emit_current_frame(name)
    
    # Signal animation started
    emit_signal("animation_started", name)
    
    print("Started animation: " + name + " at " + str(fps) + " FPS")
    return true

func stop_animation(name):
    if not is_animation_running(name):
        return false
    
    # Stop and remove timer
    if animation_timers.has(name):
        animation_timers[name].stop()
        animation_timers[name].queue_free()
        animation_timers.erase(name)
    
    # Remove from active animations
    active_animations.erase(name)
    
    # Signal animation stopped
    emit_signal("animation_stopped", name)
    
    print("Stopped animation: " + name)
    return true

func stop_all_animations():
    var animation_names = active_animations.keys()
    for name in animation_names:
        stop_animation(name)
    
    return animation_names.size()

func is_animation_running(name):
    return active_animations.has(name) and animation_timers.has(name)

func get_animation_frame(name, frame_number = -1):
    if not animations.has(name):
        return null
    
    var frames = animations[name]
    
    if frame_number < 0 or frame_number >= frames.size():
        if active_animations.has(name):
            frame_number = active_animations[name].current_frame
        else:
            frame_number = 0
    
    return frames[frame_number]

func set_color_scheme(scheme_name):
    if color_schemes.has(scheme_name):
        current_color_scheme = scheme_name
        print("Set color scheme to: " + scheme_name)
        return true
    
    print("Color scheme not found: " + scheme_name)
    return false

func add_animation(name, frames):
    animations[name] = frames
    print("Added animation: " + name + " with " + str(frames.size()) + " frames")
    return true

func list_animations():
    var result = []
    
    for name in animations:
        var status = "Inactive"
        var frame_count = animations[name].size()
        
        if active_animations.has(name):
            var anim = active_animations[name]
            status = "Active (Frame " + str(anim.current_frame + 1) + "/" + str(anim.total_frames) + \
                     ", " + str(anim.fps) + " FPS, " + ("Looping" if anim.loop else "Once") + ")"
        
        result.append({
            "name": name,
            "frames": frame_count,
            "status": status
        })
    
    return result

func save_animations_to_file(file_path = "user://animations.json"):
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(animations, "  "))
        file.close()
        print("Saved animations to: " + file_path)
        return true
    
    print("Failed to save animations")
    return false

func load_animations_from_file(file_path = "user://animations.json"):
    if not FileAccess.file_exists(file_path):
        print("Animation file not found: " + file_path)
        return false
    
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var content = file.get_as_text()
        file.close()
        
        var json = JSON.new()
        var error = json.parse(content)
        
        if error == OK:
            var loaded_animations = json.get_data()
            # Merge with existing animations
            for name in loaded_animations:
                animations[name] = loaded_animations[name]
            
            print("Loaded animations from: " + file_path)
            return true
        else:
            print("JSON parse error: " + json.get_error_message())
    
    print("Failed to load animations")
    return false

func create_memory_fragments(length = 32, rows = 3):
    var frames = []
    var base_frame = []
    
    # Create base frame with all zeros
    for i in range(rows):
        var row = ""
        for j in range(length):
            row += "0"
        base_frame.append(row)
    
    frames.append(base_frame.duplicate())
    
    # Create "waking up" sequence with patterns
    for i in range(1, 7):
        var frame = base_frame.duplicate()
        var activation = float(i) / 6.0
        
        for row_idx in range(rows):
            var row = ""
            for j in range(length):
                # Different patterns for each frame
                if randf() < activation * 0.3 + (j % 3 == 0 and row_idx % 2 == 0) * 0.2:
                    row += "1"
                else:
                    row += "0"
            frame[row_idx] = row
        
        frames.append(frame)
    
    # Create "fully active" frame
    var active_frame = []
    for i in range(rows):
        var row = ""
        for j in range(length):
            if randf() < 0.7:
                row += "1"
            else:
                row += "0"
        active_frame.append(row)
    
    frames.append(active_frame)
    
    # Create "returning to base" frames
    for i in range(5, 0, -1):
        var frame = base_frame.duplicate()
        var activation = float(i) / 6.0
        
        for row_idx in range(rows):
            var row = ""
            for j in range(length):
                if randf() < activation * 0.3 + (j % 3 == 0 and row_idx % 2 == 0) * 0.2:
                    row += "1"
                else:
                    row += "0"
            frame[row_idx] = row
        
        frames.append(frame)
    
    # Return to base frame
    frames.append(base_frame.duplicate())
    
    return frames

# Animation frame processing
func _on_animation_frame(name):
    if not active_animations.has(name):
        return
    
    var animation = active_animations[name]
    
    # Advance to next frame
    animation.current_frame = (animation.current_frame + 1) % animation.total_frames
    
    # Emit the frame
    _emit_current_frame(name)
    
    # Check if animation should end
    if not animation.loop and animation.current_frame == 0:
        # Animation completed
        emit_signal("animation_completed", name)
        stop_animation(name)

func _emit_current_frame(name):
    var animation = active_animations[name]
    var frame_number = animation.current_frame
    var frame_content = animation.frames[frame_number]
    
    # Emit frame signal
    emit_signal("animation_frame", name, frame_number, frame_content)

# Command processor for integrating with terminal
func process_command(args):
    if args.size() == 0:
        return _cmd_help()
    
    var command = args[0].to_lower()
    var command_args = args.slice(1)
    
    match command:
        "list":
            return _cmd_list()
        "play", "start":
            return _cmd_play(command_args)
        "stop":
            return _cmd_stop(command_args)
        "frame":
            return _cmd_frame(command_args)
        "color":
            return _cmd_color(command_args)
        "create":
            return _cmd_create(command_args)
        "save":
            return _cmd_save(command_args)
        "load":
            return _cmd_load(command_args)
        "help":
            return _cmd_help()
        _:
            return "Unknown animation command: " + command + "\nUse 'animate help' for available commands"

# Command implementations
func _cmd_help():
    return "ASCII Animation Commands:\n\n" + \
           "list                - List available animations\n" + \
           "play <name> [fps] [loop] - Play an animation\n" + \
           "stop <name|all>     - Stop animation(s)\n" + \
           "frame <name> [num]  - Show specific animation frame\n" + \
           "color <scheme>      - Set color scheme\n" + \
           "create <type> [params] - Create a new animation\n" + \
           "save [path]         - Save animations to file\n" + \
           "load [path]         - Load animations from file\n" + \
           "help                - Show this help text\n\n" + \
           "Available animations: " + ", ".join(animations.keys()) + "\n" + \
           "Available color schemes: " + ", ".join(color_schemes.keys())

func _cmd_list():
    var anime_list = list_animations()
    var result = "Available Animations:\n\n"
    
    for anim in anime_list:
        result += anim.name + ": " + str(anim.frames) + " frames - " + anim.status + "\n"
    
    return result

func _cmd_play(args):
    if args.size() == 0:
        return "Usage: animate play <name> [fps] [loop]"
    
    var name = args[0]
    var fps = 2.0
    var loop = true
    var color_scheme = current_color_scheme
    
    if args.size() > 1 and args[1].is_valid_float():
        fps = args[1].to_float()
    
    if args.size() > 2:
        loop = args[2].to_lower() == "true" or args[2] == "1" or args[2].to_lower() == "loop"
    
    if args.size() > 3 and color_schemes.has(args[3]):
        color_scheme = args[3]
    
    if start_animation(name, fps, loop, color_scheme):
        return "Started animation: " + name + " at " + str(fps) + " FPS" + \
               (" (looping)" if loop else " (once)") + \
               " with " + color_scheme + " colors"
    else:
        return "Failed to start animation: " + name + "\nAvailable animations: " + ", ".join(animations.keys())

func _cmd_stop(args):
    if args.size() == 0:
        return "Usage: animate stop <name|all>"
    
    var name = args[0]
    
    if name == "all":
        var count = stop_all_animations()
        return "Stopped " + str(count) + " animations"
    
    if stop_animation(name):
        return "Stopped animation: " + name
    else:
        return "No active animation: " + name
        
func _cmd_frame(args):
    if args.size() == 0:
        return "Usage: animate frame <name> [number]"
    
    var name = args[0]
    var frame_number = -1
    
    if args.size() > 1 and args[1].is_valid_integer():
        frame_number = args[1].to_int()
    
    var frame = get_animation_frame(name, frame_number)
    if frame == null:
        return "Animation not found: " + name + "\nAvailable animations: " + ", ".join(animations.keys())
    
    # Format frame for display
    var result = "Animation: " + name + ", Frame: " + str(frame_number if frame_number >= 0 else "current") + "\n\n"
    
    for line in frame:
        result += line + "\n"
    
    return result

func _cmd_color(args):
    if args.size() == 0:
        var result = "Current color scheme: " + current_color_scheme + "\n\n"
        result += "Available color schemes:\n"
        
        for scheme in color_schemes:
            result += "- " + scheme + (scheme == current_color_scheme ? " (active)" : "") + "\n"
        
        return result
    
    var scheme_name = args[0]
    
    if set_color_scheme(scheme_name):
        return "Set color scheme to: " + scheme_name
    else:
        return "Unknown color scheme: " + scheme_name + "\nAvailable schemes: " + ", ".join(color_schemes.keys())

func _cmd_create(args):
    if args.size() == 0:
        return "Usage: animate create <type> <name> [params]"
    
    var type = args[0]
    
    if args.size() < 2:
        return "Missing animation name\nUsage: animate create " + type + " <name> [params]"
    
    var name = args[1]
    
    match type:
        "memory":
            var length = 32
            var rows = 3
            
            if args.size() > 2 and args[2].is_valid_integer():
                length = args[2].to_int()
            
            if args.size() > 3 and args[3].is_valid_integer():
                rows = args[3].to_int()
            
            var frames = create_memory_fragments(length, rows)
            add_animation(name, frames)
            
            return "Created memory fragment animation: " + name + " with " + str(frames.size()) + " frames"
        
        _:
            return "Unknown animation type: " + type + "\nSupported types: memory"

func _cmd_save(args):
    var path = "user://animations.json"
    
    if args.size() > 0:
        path = args[0]
    
    if save_animations_to_file(path):
        return "Saved animations to: " + path
    else:
        return "Failed to save animations to: " + path

func _cmd_load(args):
    var path = "user://animations.json"
    
    if args.size() > 0:
        path = args[0]
    
    if load_animations_from_file(path):
        return "Loaded animations from: " + path
    else:
        return "Failed to load animations from: " + path