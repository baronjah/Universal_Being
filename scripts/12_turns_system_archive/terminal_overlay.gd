extends Control

class_name TerminalOverlay

# Terminal overlay with dynamic color shifting and EVE integration

# Color constants
const COLOR_LIGHT_BLUE = Color(0.5, 0.7, 0.9, 0.9)
const COLOR_EVE_BLUE = Color(0.4, 0.6, 0.9, 0.8)
const COLOR_SHIFT_BLUE = Color(0.3, 0.5, 0.8, 0.7)
const COLOR_DEEP_BLUE = Color(0.2, 0.4, 0.7, 0.9)
const COLOR_ETHEREAL_BLUE = Color(0.6, 0.8, 0.95, 0.8)

# EVE shift markers
const EVE_SHIFT_SYMBOLS = ["#", "##", "###", "####", "#####"]

# Terminal properties
export var terminal_font_size = 14
export var terminal_opacity = 0.8
export var terminal_color = COLOR_LIGHT_BLUE
export var terminal_border_size = 2
export var terminal_text_color = Color(1, 1, 1, 0.9)
export var terminal_size = Vector2(800, 600)
export var terminal_position = Vector2(20, 20)

# Terminal state
var is_visible = true
var is_shifting = false
var current_mode = "default"
var terminal_title = "Terminal Overlay # EVE SHIFT"
var terminal_content = []
var terminal_commands = []
var command_history = []
var current_command = ""
var cursor_position = 0
var cursor_visible = true
var cursor_blink_timer = 0
var eve_shift_enabled = false
var current_shift_phase = 0
var shift_colors = []
var terminal_border_color = Color(1, 1, 1, 0.5)

# Terminal animation
var animation_time = 0
var wave_amplitude = 3.0
var wave_frequency = 2.0
var pulse_intensity = 0.2
var glow_intensity = 0.5
var shift_progress = 0.0
var color_transition_duration = 1.2
var color_from = COLOR_LIGHT_BLUE
var color_to = COLOR_LIGHT_BLUE
var symbol_rotation = 0.0

# Memory system connection
var memory_system = null

# Signals
signal command_entered(command)
signal color_changed(color)
signal overlay_toggled(visible)
signal eve_shift_toggled(enabled)

func _ready():
    # Set initial properties
    rect_size = terminal_size
    rect_position = terminal_position
    
    # Setup cursor blink timer
    var timer = Timer.new()
    timer.wait_time = 0.5
    timer.connect("timeout", self, "_on_cursor_blink")
    add_child(timer)
    timer.start()
    
    # Initialize colors
    _initialize_shift_colors()
    
    # Connect to memory system if available
    connect_to_memory_system()
    
    # Set initial content
    add_text("Terminal Overlay Initialized")
    add_text("Color: Light Blue")
    add_text("EVE Shift: Disabled")
    add_text("Type 'help' for commands")
    add_text("# Type 'eve' to activate EVE shift")

func _initialize_shift_colors():
    # Define color shift sequence
    shift_colors = [
        COLOR_LIGHT_BLUE,
        COLOR_EVE_BLUE,
        COLOR_SHIFT_BLUE,
        COLOR_DEEP_BLUE,
        COLOR_ETHEREAL_BLUE
    ]

func connect_to_memory_system():
    # Find memory system node
    if has_node("/root/ProjectMemorySystem") or get_node_or_null("/root/ProjectMemorySystem"):
        memory_system = get_node("/root/ProjectMemorySystem")
        memory_system.connect("color_shifted", self, "_on_memory_color_shifted")
        memory_system.connect("overlay_updated", self, "_on_overlay_updated")
        print("Connected to ProjectMemorySystem")
        return true
    
    # Try SmartAccountSystem path
    if has_node("/root/SmartAccountSystem/ProjectMemorySystem") or get_node_or_null("/root/SmartAccountSystem/ProjectMemorySystem"):
        memory_system = get_node("/root/SmartAccountSystem/ProjectMemorySystem")
        memory_system.connect("color_shifted", self, "_on_memory_color_shifted")
        memory_system.connect("overlay_updated", self, "_on_overlay_updated")
        print("Connected to ProjectMemorySystem under SmartAccountSystem")
        return true
    
    return false

func _process(delta):
    # Update animation time
    animation_time += delta
    
    # Update color transition if shifting
    if is_shifting:
        shift_progress += delta / color_transition_duration
        if shift_progress >= 1.0:
            shift_progress = 1.0
            is_shifting = false
        
        # Interpolate color
        terminal_color = color_from.linear_interpolate(color_to, shift_progress)
        
        # Apply pulse effect during shift
        var pulse = sin(animation_time * 5.0) * pulse_intensity
        terminal_color = terminal_color.lightened(pulse)
    
    # Update symbol rotation for EVE shift
    if eve_shift_enabled:
        symbol_rotation += delta * 0.5
        current_shift_phase = int(animation_time / 3.0) % 5
    
    # Request redraw
    update()

func _draw():
    # Draw terminal background with color
    var background_rect = Rect2(Vector2.ZERO, rect_size)
    draw_rect(background_rect, terminal_color, true)
    
    # Draw terminal border
    var border_rect = Rect2(Vector2.ZERO, rect_size)
    draw_rect(border_rect, terminal_border_color, false, terminal_border_size)
    
    # Draw title bar
    var title_bar_rect = Rect2(Vector2.ZERO, Vector2(rect_size.x, 30))
    draw_rect(title_bar_rect, terminal_color.darkened(0.2), true)
    
    # Draw title
    var title_text = terminal_title
    if eve_shift_enabled:
        # Add EVE shift marker
        title_text += " " + EVE_SHIFT_SYMBOLS[current_shift_phase]
    
    draw_string(get_font("", ""), Vector2(10, 20), title_text, terminal_text_color)
    
    # Draw content
    var content_y = 40
    for line in terminal_content:
        draw_string(get_font("", ""), Vector2(10, content_y), line, terminal_text_color)
        content_y += terminal_font_size + 5
    
    # Draw command line
    var command_prompt = ">> "
    var full_command = command_prompt + current_command
    
    draw_string(get_font("", ""), Vector2(10, content_y), full_command, terminal_text_color)
    
    # Draw cursor if visible
    if cursor_visible:
        var cursor_x = 10 + get_font("", "").get_string_size(command_prompt + current_command.substr(0, cursor_position)).x
        draw_rect(Rect2(Vector2(cursor_x, content_y - terminal_font_size), Vector2(2, terminal_font_size)), terminal_text_color, true)
    
    # Draw EVE shift effects if enabled
    if eve_shift_enabled:
        draw_eve_shift_effects()

func draw_eve_shift_effects():
    # Draw EVE shift symbol in corner
    var symbol = EVE_SHIFT_SYMBOLS[current_shift_phase]
    var symbol_pos = Vector2(rect_size.x - 30, 20)
    
    # Add rotation effect to symbol
    var font = get_font("", "")
    var symbol_size = font.get_string_size(symbol)
    var symbol_center = symbol_pos + symbol_size / 2
    
    # Draw rotated symbol
    draw_set_transform(symbol_center, symbol_rotation, Vector2(1, 1))
    draw_string(font, symbol_pos - symbol_center, symbol, terminal_text_color.lightened(0.3))
    draw_set_transform(Vector2.ZERO, 0, Vector2(1, 1))
    
    # Draw bottom wave effect
    var wave_points = PoolVector2Array()
    var wave_y = rect_size.y - 20
    
    for x in range(0, int(rect_size.x), 5):
        var wave_offset = sin((x / rect_size.x * 5 + animation_time) * wave_frequency) * wave_amplitude
        wave_points.append(Vector2(x, wave_y + wave_offset))
    
    # Draw wave line
    if wave_points.size() >= 2:
        for i in range(wave_points.size() - 1):
            draw_line(wave_points[i], wave_points[i+1], terminal_text_color.lightened(0.2), 2.0)

func _input(event):
    # Handle keyboard input
    if event is InputEventKey and event.pressed:
        match event.scancode:
            KEY_BACKSPACE:
                if cursor_position > 0:
                    current_command = current_command.substr(0, cursor_position - 1) + current_command.substr(cursor_position)
                    cursor_position -= 1
            KEY_DELETE:
                if cursor_position < current_command.length():
                    current_command = current_command.substr(0, cursor_position) + current_command.substr(cursor_position + 1)
            KEY_LEFT:
                cursor_position = max(0, cursor_position - 1)
            KEY_RIGHT:
                cursor_position = min(current_command.length(), cursor_position + 1)
            KEY_HOME:
                cursor_position = 0
            KEY_END:
                cursor_position = current_command.length()
            KEY_UP:
                # Navigate command history (up)
                if command_history.size() > 0:
                    current_command = command_history[command_history.size() - 1]
                    cursor_position = current_command.length()
            KEY_DOWN:
                # Navigate command history (down)
                current_command = ""
                cursor_position = 0
            KEY_RETURN, KEY_ENTER:
                # Process command
                if current_command.strip_edges() != "":
                    process_command(current_command)
                    command_history.append(current_command)
                    if command_history.size() > 50:
                        command_history.pop_front()
                    current_command = ""
                    cursor_position = 0
            _:
                # Add character to command
                if event.unicode > 0:
                    var char = char(event.unicode)
                    current_command = current_command.substr(0, cursor_position) + char + current_command.substr(cursor_position)
                    cursor_position += 1
        
        # Reset cursor blink
        cursor_visible = true
        
        # Ensure redraw
        update()

func _on_cursor_blink():
    cursor_visible = !cursor_visible
    update()

func _on_memory_color_shifted(from_color, to_color):
    # Start color transition
    start_color_transition(from_color, to_color)

func _on_overlay_updated(settings):
    # Update from memory system settings
    if "color" in settings:
        terminal_color = settings["color"]
    
    if "opacity" in settings:
        terminal_opacity = settings["opacity"]
    
    if "dimensions" in settings:
        rect_size = settings["dimensions"]
    
    if "position" in settings:
        rect_position = settings["position"]
    
    if "border" in settings and "size" in settings["border"]:
        terminal_border_size = settings["border"]["size"]
        
    if "border" in settings and "color" in settings["border"]:
        terminal_border_color = settings["border"]["color"]
    
    if "text" in settings and "color" in settings["text"]:
        terminal_text_color = settings["text"]["color"]
        
    if "text" in settings and "size" in settings["text"]:
        terminal_font_size = settings["text"]["size"]
    
    if "title" in settings:
        terminal_title = settings["title"]
    
    if "visible" in settings:
        is_visible = settings["visible"]
        visible = is_visible
    
    # Request redraw
    update()

func add_text(text):
    # Add text to terminal content
    terminal_content.append(text)
    
    # Limit content size
    if terminal_content.size() > 100:
        terminal_content.pop_front()
    
    # Request redraw
    update()

func clear_terminal():
    # Clear terminal content
    terminal_content.clear()
    
    # Request redraw
    update()

func process_command(command):
    # Add command to terminal
    add_text(">> " + command)
    
    # Process command
    var cmd_parts = command.split(" ")
    var cmd_name = cmd_parts[0].to_lower()
    
    match cmd_name:
        "help":
            add_text("Available commands:")
            add_text("  help - Show this help")
            add_text("  clear - Clear terminal")
            add_text("  color - Change terminal color")
            add_text("  shift - Trigger color shift")
            add_text("  eve - Toggle EVE shift mode")
            add_text("  opacity - Set terminal opacity (0.1-1.0)")
            add_text("  memory - Access memory system")
            add_text("  wave - Adjust wave animation")
            add_text("  hide - Hide terminal overlay")
            add_text("  show - Show terminal overlay")
            add_text("  exit - Close terminal")
        
        "clear":
            clear_terminal()
        
        "color":
            if cmd_parts.size() > 1:
                var color_name = cmd_parts[1].to_lower()
                set_color_by_name(color_name)
            else:
                add_text("Current color: " + get_current_color_name())
                add_text("Usage: color [light_blue|eve_blue|shift_blue|deep_blue|ethereal_blue]")
        
        "shift":
            if memory_system:
                var result = memory_system.shift_colors()
                if result:
                    add_text("Shifted colors: " + result["from"] + " -> " + result["to"])
                else:
                    add_text("Color shift in progress, please wait...")
            else:
                trigger_color_shift()
        
        "eve":
            toggle_eve_shift()
        
        "opacity":
            if cmd_parts.size() > 1:
                var opacity = float(cmd_parts[1])
                set_opacity(opacity)
            else:
                add_text("Current opacity: " + str(terminal_opacity))
                add_text("Usage: opacity [0.1-1.0]")
        
        "memory":
            if cmd_parts.size() > 1:
                process_memory_command(cmd_parts)
            else:
                add_text("Memory system commands:")
                add_text("  memory add [content] [category] - Add memory")
                add_text("  memory recall [id] - Recall memory")
                add_text("  memory forget [id] - Forget memory")
                add_text("  memory list - List all memories")
                add_text("  memory stats - Show memory statistics")
        
        "wave":
            if cmd_parts.size() > 2:
                var param = cmd_parts[1].to_lower()
                var value = float(cmd_parts[2])
                set_wave_parameter(param, value)
            else:
                add_text("Wave parameters:")
                add_text("  wave amplitude [value] - Set wave height")
                add_text("  wave frequency [value] - Set wave speed")
                add_text("  wave pulse [value] - Set pulse intensity")
        
        "hide":
            hide_terminal()
        
        "show":
            show_terminal()
        
        "exit":
            hide_terminal()
        
        _:
            add_text("Unknown command: " + cmd_name)
            add_text("Type 'help' for commands")
    
    # Emit signal for command
    emit_signal("command_entered", command)

func process_memory_command(cmd_parts):
    if not memory_system:
        add_text("Memory system not available")
        return
    
    var action = cmd_parts[1].to_lower()
    
    match action:
        "add":
            if cmd_parts.size() >= 4:
                var content = cmd_parts[2]
                var category = cmd_parts[3]
                var memory_id = memory_system.add_memory(content, category)
                if memory_id:
                    add_text("Memory added: " + memory_id)
                else:
                    add_text("Failed to add memory")
            else:
                add_text("Usage: memory add [content] [category]")
        
        "recall":
            if cmd_parts.size() >= 3:
                var memory_id = cmd_parts[2]
                var memory = memory_system.recall_memory(memory_id)
                if memory:
                    add_text("Memory recalled: " + memory["content"])
                else:
                    add_text("Memory not found")
            else:
                add_text("Usage: memory recall [id]")
        
        "forget":
            if cmd_parts.size() >= 3:
                var memory_id = cmd_parts[2]
                var result = memory_system.forget_memory(memory_id)
                if result:
                    add_text("Memory forgotten: " + memory_id)
                else:
                    add_text("Memory not found")
            else:
                add_text("Usage: memory forget [id]")
        
        "list":
            var category = "project_structure"
            if cmd_parts.size() >= 3:
                category = cmd_parts[2]
            
            var memories = memory_system.get_memories_by_category(category)
            add_text("Memories in category " + category + ":")
            
            for memory in memories:
                add_text("  " + memory["id"] + ": " + memory["content"])
            
            if memories.size() == 0:
                add_text("  No memories found")
        
        "stats":
            add_text("Memory system statistics:")
            
            var total_memories = 0
            for category in memory_system.memory_banks:
                var count = memory_system.memory_banks[category]["memories"].size()
                total_memories += count
                add_text("  " + category + ": " + str(count) + " memories")
            
            add_text("Total memories: " + str(total_memories))
            add_text("Forgotten memories: " + str(memory_system.forgotten_memories.size()))
            
            if memory_system.current_memory_focus:
                add_text("Current focus: " + memory_system.current_memory_focus)
            
            if memory_system.project_eve_shift_active:
                add_text("EVE Shift: Active (Phase " + str(memory_system.current_shift_phase) + ")")
            else:
                add_text("EVE Shift: Inactive")
        
        _:
            add_text("Unknown memory command: " + action)
            add_text("Type 'memory' for help")

func set_color_by_name(color_name):
    var color = null
    
    match color_name:
        "light_blue":
            color = COLOR_LIGHT_BLUE
        "eve_blue":
            color = COLOR_EVE_BLUE
        "shift_blue":
            color = COLOR_SHIFT_BLUE
        "deep_blue":
            color = COLOR_DEEP_BLUE
        "ethereal_blue":
            color = COLOR_ETHEREAL_BLUE
        _:
            add_text("Unknown color: " + color_name)
            return
    
    # Set color
    start_color_transition(terminal_color, color)
    
    # Update memory system if connected
    if memory_system:
        memory_system.set_overlay_color(color)
    
    add_text("Color set to: " + color_name)
    emit_signal("color_changed", color)

func get_current_color_name():
    if terminal_color.is_equal_approx(COLOR_LIGHT_BLUE):
        return "light_blue"
    elif terminal_color.is_equal_approx(COLOR_EVE_BLUE):
        return "eve_blue"
    elif terminal_color.is_equal_approx(COLOR_SHIFT_BLUE):
        return "shift_blue"
    elif terminal_color.is_equal_approx(COLOR_DEEP_BLUE):
        return "deep_blue"
    elif terminal_color.is_equal_approx(COLOR_ETHEREAL_BLUE):
        return "ethereal_blue"
    else:
        return "custom"

func start_color_transition(from, to):
    # Start color transition animation
    color_from = from
    color_to = to
    shift_progress = 0.0
    is_shifting = true

func trigger_color_shift():
    # Find next color in shift sequence
    var current_index = shift_colors.find(terminal_color)
    if current_index < 0:
        current_index = 0
    
    var next_index = (current_index + 1) % shift_colors.size()
    var next_color = shift_colors[next_index]
    
    # Start transition
    start_color_transition(terminal_color, next_color)
    
    # Update text
    add_text("Shifting color: " + get_current_color_name() + " -> " + 
             (["light_blue", "eve_blue", "shift_blue", "deep_blue", "ethereal_blue"][next_index]))

func toggle_eve_shift():
    eve_shift_enabled = !eve_shift_enabled
    
    if eve_shift_enabled:
        add_text("EVE Shift activated")
        
        # Set color to EVE blue
        start_color_transition(terminal_color, COLOR_EVE_BLUE)
        
        # Update memory system if connected
        if memory_system:
            memory_system.start_eve_shift()
    else:
        add_text("EVE Shift deactivated")
        
        # Set color back to light blue
        start_color_transition(terminal_color, COLOR_LIGHT_BLUE)
        
        # Update memory system if connected
        if memory_system:
            memory_system.stop_eve_shift()
    
    emit_signal("eve_shift_toggled", eve_shift_enabled)

func set_opacity(opacity):
    # Set terminal opacity
    terminal_opacity = clamp(opacity, 0.1, 1.0)
    modulate.a = terminal_opacity
    
    # Update memory system if connected
    if memory_system:
        memory_system.set_overlay_opacity(terminal_opacity)
    
    add_text("Opacity set to: " + str(terminal_opacity))

func set_wave_parameter(param, value):
    match param:
        "amplitude":
            wave_amplitude = clamp(value, 0.0, 10.0)
            add_text("Wave amplitude set to: " + str(wave_amplitude))
        "frequency":
            wave_frequency = clamp(value, 0.1, 5.0)
            add_text("Wave frequency set to: " + str(wave_frequency))
        "pulse":
            pulse_intensity = clamp(value, 0.0, 0.5)
            add_text("Pulse intensity set to: " + str(pulse_intensity))
        _:
            add_text("Unknown wave parameter: " + param)

func hide_terminal():
    # Hide terminal
    is_visible = false
    visible = false
    
    # Update memory system if connected
    if memory_system:
        memory_system.toggle_overlay_visibility()
    
    emit_signal("overlay_toggled", false)

func show_terminal():
    # Show terminal
    is_visible = true
    visible = true
    
    # Update memory system if connected
    if memory_system:
        memory_system.toggle_overlay_visibility()
    
    emit_signal("overlay_toggled", true)