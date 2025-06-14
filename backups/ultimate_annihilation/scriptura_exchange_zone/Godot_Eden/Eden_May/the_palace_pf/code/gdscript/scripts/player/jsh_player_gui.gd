extends Control
class_name JSHPlayerGUI

# GUI for the JSH Player Controller
# Displays current movement mode, reality, energy, and word information

# Node references
@onready var mode_label = $TopPanel/ModeLabel
@onready var reality_label = $TopPanel/RealityLabel
@onready var energy_bar = $TopPanel/EnergyBar
@onready var position_label = $TopPanel/PositionLabel
@onready var speed_label = $TopPanel/SpeedLabel
@onready var stats_label = $TopPanel/StatsLabel

@onready var word_panel = $WordPanel
@onready var word_title = $WordPanel/WordTitle
@onready var word_category = $WordPanel/WordCategory
@onready var word_properties = $WordPanel/WordProperties
@onready var word_connections = $WordPanel/WordConnections

@onready var console_panel = $ConsolePanel
@onready var console_output = $ConsolePanel/ConsoleOutput
@onready var console_input = $ConsolePanel/InputContainer/ConsoleInput

@onready var notification_panel = $NotificationPanel
@onready var notification_label = $NotificationPanel/NotificationLabel
@onready var notification_timer = $NotificationPanel/NotificationTimer

# Current state
var player_info = {}
var word_info = {}
var console_visible = false
var notification_queue = []
var is_showing_notification = false

# Color coding
var reality_colors = {
    "physical": Color(0.2, 0.7, 0.2),
    "digital": Color(0.2, 0.5, 0.9),
    "astral": Color(0.8, 0.2, 0.8)
}

var mode_colors = {
    "WALKING": Color(0.8, 0.8, 0.2),
    "FLYING": Color(0.2, 0.8, 0.8),
    "SPECTATOR": Color(0.7, 0.7, 0.7),
    "WORD SURFING": Color(0.8, 0.2, 0.8)
}

var word_category_colors = {
    "concept": Color(0.8, 0.2, 0.8),
    "object": Color(0.2, 0.6, 0.9),
    "action": Color(0.9, 0.3, 0.2),
    "property": Color(0.2, 0.8, 0.3),
    "relation": Color(0.9, 0.8, 0.2)
}

# Ready function
func _ready():
    # Initialize panels
    word_panel.visible = false
    console_panel.visible = false
    notification_panel.visible = false
    
    # Connect signals
    notification_timer.timeout.connect(_on_notification_timer_timeout)
    
    # Connect console input
    console_input.text_submitted.connect(_on_console_input_submitted)

# Process function
func _process(delta):
    # Keep updating position display
    if player_info.has("position"):
        var pos = player_info.position
        position_label.text = "Position: %.1f, %.1f, %.1f" % [pos.x, pos.y, pos.z]
    
    if player_info.has("speed"):
        speed_label.text = "Speed: %.1f m/s" % player_info.speed

# Update player information
func update_player_info(info: Dictionary):
    player_info = info
    
    # Update mode label
    if info.has("mode"):
        mode_label.text = "Mode: " + info.mode
        if mode_colors.has(info.mode):
            mode_label.add_theme_color_override("font_color", mode_colors[info.mode])
    
    # Update reality label
    if info.has("reality"):
        reality_label.text = "Reality: " + info.reality
        var reality_name = info.reality.split(" ")[0].to_lower()  # Get just the first word
        if reality_colors.has(reality_name):
            reality_label.add_theme_color_override("font_color", reality_colors[reality_name])
    
    # Update energy bar
    if info.has("energy"):
        energy_bar.value = info.energy * 100
        
        # Set color based on energy level
        var energy_color = Color(0.2, 0.8, 0.2)  # Green for high energy
        if info.energy < 0.3:
            energy_color = Color(0.9, 0.3, 0.2)  # Red for low energy
        elif info.energy < 0.7:
            energy_color = Color(0.9, 0.7, 0.2)  # Yellow for medium energy
        
        energy_bar.modulate = energy_color
    
    # Update stats label
    var stats_text = ""
    if info.has("words_collected"):
        stats_text += "Words Collected: " + str(info.words_collected)
    
    if info.has("words_created"):
        stats_text += " | Created: " + str(info.words_created)
    
    stats_label.text = stats_text
    
    # Update word panel visibility
    word_panel.visible = info.has("hovered_word") and info.hovered_word != ""

# Update word information
func update_word_info(info: Dictionary):
    word_info = info
    
    # Update word title
    if info.has("text"):
        word_title.text = info.text.to_upper()
    
    # Update word category
    if info.has("category"):
        word_category.text = "Category: " + info.category
        if word_category_colors.has(info.category):
            word_category.add_theme_color_override("font_color", word_category_colors[info.category])
    
    # Update word properties
    var properties_text = ""
    if info.has("properties"):
        for prop in info.properties:
            properties_text += prop + ": " + str(info.properties[prop]) + "\n"
    
    if info.has("color"):
        properties_text += "Color: " + str(info.color) + "\n"
    
    if info.has("size"):
        properties_text += "Size: " + str(info.size) + "\n"
    
    word_properties.text = properties_text
    
    # Update word connections
    var connections_text = ""
    if info.has("connections") and info.connections.size() > 0:
        connections_text = "Connected to:\n"
        for connection in info.connections:
            connections_text += "- " + connection + "\n"
    else:
        connections_text = "No connections"
    
    word_connections.text = connections_text

# Show a notification
func show_notification(text: String, duration: float = 3.0):
    # Add to queue
    notification_queue.append({
        "text": text,
        "duration": duration
    })
    
    # Process queue
    _process_notification_queue()

# Process notification queue
func _process_notification_queue():
    if is_showing_notification or notification_queue.size() == 0:
        return
    
    # Get next notification
    var notification = notification_queue[0]
    notification_queue.remove_at(0)
    
    # Show notification
    notification_label.text = notification.text
    notification_panel.visible = true
    is_showing_notification = true
    
    # Start timer
    notification_timer.wait_time = notification.duration
    notification_timer.start()

# Notification timer timeout
func _on_notification_timer_timeout():
    # Hide notification
    notification_panel.visible = false
    is_showing_notification = false
    
    # Process next notification
    _process_notification_queue()

# Toggle console visibility
func toggle_console():
    console_visible = !console_visible
    console_panel.visible = console_visible
    
    # Focus input if visible
    if console_visible:
        console_input.grab_focus()

# Add text to console
func add_console_text(text: String, color: Color = Color.WHITE):
    console_output.push_color(color)
    console_output.add_text(text + "\n")
    console_output.pop()

# Handle console input submission
func _on_console_input_submitted(text: String):
    if text.strip_edges().is_empty():
        return
    
    # Echo input
    add_console_text("> " + text, Color(0.8, 0.8, 0.8))
    
    # Process command
    var response = _process_console_command(text)
    
    # Show response
    add_console_text(response.message, response.color)
    
    # Clear input
    console_input.text = ""

# Process console command
func _process_console_command(text: String) -> Dictionary:
    var parts = text.strip_edges().split(" ", false)
    if parts.size() == 0:
        return {"message": "Invalid command", "color": Color(0.9, 0.3, 0.2)}
    
    var command = parts[0].to_lower()
    
    match command:
        "help":
            return _cmd_help(parts)
        
        "reality":
            return _cmd_reality(parts)
        
        "mode":
            return _cmd_mode(parts)
        
        "create":
            return _cmd_create(parts)
        
        "collect":
            return _cmd_collect(parts)
        
        "connect":
            return _cmd_connect(parts)
        
        "energy":
            return _cmd_energy(parts)
        
        "goto":
            return _cmd_goto(parts)
        
        _:
            return {"message": "Unknown command: " + command, "color": Color(0.9, 0.3, 0.2)}

# Command handlers
func _cmd_help(args: Array) -> Dictionary:
    var help_text = """Available commands:
help - Show this help text
reality [physical|digital|astral] - Get or set reality
mode [walking|flying|spectator|surfing] - Get or set movement mode
create <word> [position] - Create a word entity
collect <word_id> - Collect a word
connect <word1_id> <word2_id> - Connect two words
energy [amount] - Get or set energy level
goto <position> - Move to position"""

    return {"message": help_text, "color": Color(0.2, 0.8, 0.2)}

func _cmd_reality(args: Array) -> Dictionary:
    # Signal to player controller
    # This is a simple example; in practice you would connect to the player controller
    if args.size() > 1:
        var target_reality = args[1].to_lower()
        if target_reality in ["physical", "digital", "astral"]:
            # Signal parent (player) to change reality
            get_parent().shift_reality(target_reality)
            return {"message": "Shifting to " + target_reality + " reality...", "color": Color(0.2, 0.8, 0.8)}
        else:
            return {"message": "Invalid reality: " + target_reality, "color": Color(0.9, 0.3, 0.2)}
    else:
        return {"message": "Current reality: " + player_info.reality, "color": Color(0.8, 0.8, 0.2)}

func _cmd_mode(args: Array) -> Dictionary:
    if args.size() > 1:
        var target_mode = args[1].to_lower()
        var mode_index = -1
        
        match target_mode:
            "walking":
                mode_index = 0
            "flying":
                mode_index = 1
            "spectator":
                mode_index = 2
            "surfing":
                mode_index = 3
        
        if mode_index >= 0:
            # Signal parent (player) to change mode
            get_parent().set_movement_mode(mode_index)
            return {"message": "Changing to " + target_mode + " mode...", "color": Color(0.2, 0.8, 0.8)}
        else:
            return {"message": "Invalid mode: " + target_mode, "color": Color(0.9, 0.3, 0.2)}
    else:
        return {"message": "Current mode: " + player_info.mode, "color": Color(0.8, 0.8, 0.2)}

func _cmd_create(args: Array) -> Dictionary:
    # Simple placeholder - in practice would connect to word manifestor
    if args.size() > 1:
        var word = args[1]
        return {"message": "Creating word: " + word, "color": Color(0.2, 0.8, 0.8)}
    else:
        return {"message": "Usage: create <word> [position]", "color": Color(0.9, 0.3, 0.2)}

func _cmd_collect(args: Array) -> Dictionary:
    # Simple placeholder
    if args.size() > 1:
        var word_id = args[1]
        return {"message": "Collecting word: " + word_id, "color": Color(0.2, 0.8, 0.8)}
    else:
        return {"message": "Usage: collect <word_id>", "color": Color(0.9, 0.3, 0.2)}

func _cmd_connect(args: Array) -> Dictionary:
    # Simple placeholder
    if args.size() > 2:
        var word1 = args[1]
        var word2 = args[2]
        return {"message": "Connecting " + word1 + " to " + word2, "color": Color(0.2, 0.8, 0.8)}
    else:
        return {"message": "Usage: connect <word1_id> <word2_id>", "color": Color(0.9, 0.3, 0.2)}

func _cmd_energy(args: Array) -> Dictionary:
    if args.size() > 1:
        var amount = float(args[1])
        # Signal parent (player) to set energy
        return {"message": "Setting energy to " + str(amount), "color": Color(0.2, 0.8, 0.8)}
    else:
        return {"message": "Current energy: " + str(int(player_info.energy * 100)) + "%", "color": Color(0.8, 0.8, 0.2)}

func _cmd_goto(args: Array) -> Dictionary:
    # Simple placeholder
    if args.size() > 3:
        var x = float(args[1])
        var y = float(args[2])
        var z = float(args[3])
        return {"message": "Moving to position: " + str(x) + ", " + str(y) + ", " + str(z), "color": Color(0.2, 0.8, 0.8)}
    else:
        return {"message": "Usage: goto <x> <y> <z>", "color": Color(0.9, 0.3, 0.2)}

# Input function
func _input(event):
    # Toggle console on ~ or Tab
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_QUOTELEFT or event.keycode == KEY_TAB:
            toggle_console()