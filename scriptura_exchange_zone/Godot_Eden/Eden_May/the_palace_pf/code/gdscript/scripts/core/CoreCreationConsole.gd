class_name CoreCreationConsole
extends Control

# UI References
@onready var output_display: RichTextLabel = $VBoxContainer/OutputDisplay
@onready var input_field: LineEdit = $VBoxContainer/HBoxContainer/InputField
@onready var history_button: Button = $VBoxContainer/HBoxContainer/HistoryButton
@onready var clear_button: Button = $VBoxContainer/HBoxContainer/ClearButton

# Command history
var command_history = []
var history_index = -1
var max_history = 20

# References to other systems
var word_manifestor = null

# Signals
signal command_entered(command)
signal command_processed(result)

func _ready():
    # Connect signals
    input_field.text_submitted.connect(_on_text_submitted)
    history_button.pressed.connect(_on_history_button_pressed)
    clear_button.pressed.connect(_on_clear_button_pressed)
    
    # Focus input field
    input_field.grab_focus()
    
    # Find word manifestor
    _connect_to_word_manifestor()
    
    # Welcome message
    display_message("Welcome to the Creation Console.\nType words to create entities or 'help' for commands.")

func _connect_to_word_manifestor():
    # Try to get word manifestor instance
    if ClassDB.class_exists("CoreWordManifestor"):
        word_manifestor = CoreWordManifestor.get_instance()
        print("CoreCreationConsole: Connected to CoreWordManifestor")
    elif ClassDB.class_exists("JSHWordManifestor"):
        word_manifestor = JSHWordManifestor.get_instance()
        print("CoreCreationConsole: Connected to JSHWordManifestor")
    else:
        print("CoreCreationConsole: Word manifestor not found")

func _on_text_submitted(text: String):
    if text.strip_edges().is_empty():
        return
    
    # Add to history
    command_history.push_front(text)
    if command_history.size() > max_history:
        command_history.pop_back()
    
    # Reset history index
    history_index = -1
    
    # Display command
    display_message("> " + text, Color(0.8, 0.9, 1.0))
    
    # Emit signal
    command_entered.emit(text)
    
    # Process command if word manifestor is available
    if word_manifestor:
        var result = word_manifestor.process_command(text)
        
        # Display result
        if result.success:
            display_message(result.message, Color(0.2, 0.9, 0.2))
        else:
            display_message(result.message, Color(0.9, 0.5, 0.2))
        
        # Emit command processed signal
        command_processed.emit(result)
    else:
        display_message("Cannot process command - Word Manifestor not available", Color(0.9, 0.2, 0.2))
    
    # Clear input field
    input_field.text = ""

func _on_history_button_pressed():
    # Show history popup
    var popup = PopupMenu.new()
    add_child(popup)
    
    for i in range(command_history.size()):
        popup.add_item(command_history[i], i)
    
    popup.id_pressed.connect(_on_history_selected)
    popup.position = history_button.global_position + Vector2(0, history_button.size.y)
    popup.popup()

func _on_history_selected(id: int):
    input_field.text = command_history[id]
    input_field.grab_focus()
    input_field.caret_column = input_field.text.length()

func _on_clear_button_pressed():
    output_display.text = ""

func display_message(message: String, color: Color = Color.WHITE):
    var color_hex = color.to_html(false)
    output_display.append_text("[color=#" + color_hex + "]" + message + "[/color]\n")

func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_UP:
            # Navigate history upward
            if command_history.size() > 0:
                history_index = min(history_index + 1, command_history.size() - 1)
                input_field.text = command_history[history_index]
                input_field.caret_column = input_field.text.length()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_DOWN:
            # Navigate history downward
            if history_index > 0:
                history_index -= 1
                input_field.text = command_history[history_index]
            elif history_index == 0:
                history_index = -1
                input_field.text = ""
            input_field.caret_column = input_field.text.length()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_TAB and not event.echo:
            # Hide or show console
            toggle_visibility()
            get_viewport().set_input_as_handled()

func toggle_visibility():
    visible = !visible
    if visible:
        input_field.grab_focus()
    else:
        # Release focus when hiding
        input_field.release_focus()

# Public API for sending commands to the console
func execute_command(command: String):
    input_field.text = command
    _on_text_submitted(command)

# Public API for creating console scene
static func create_console_scene() -> CoreCreationConsole:
    # Create a new Control node as the parent
    var console = CoreCreationConsole.new()
    console.name = "CreationConsole"
    console.anchor_right = 1.0
    console.anchor_bottom = 0.3
    console.visible = false  # Start hidden
    
    # Create the main layout container
    var vbox = VBoxContainer.new()
    vbox.name = "VBoxContainer"
    vbox.anchor_right = 1.0
    vbox.anchor_bottom = 1.0
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    console.add_child(vbox)
    
    # Create the output display
    var output = RichTextLabel.new()
    output.name = "OutputDisplay"
    output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    output.size_flags_vertical = Control.SIZE_EXPAND_FILL
    output.scroll_following = true
    output.bbcode_enabled = true
    vbox.add_child(output)
    
    # Create the input container
    var hbox = HBoxContainer.new()
    hbox.name = "HBoxContainer"
    hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.add_child(hbox)
    
    # Create the input field
    var input = LineEdit.new()
    input.name = "InputField"
    input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    input.placeholder_text = "Enter a word or command..."
    hbox.add_child(input)
    
    # Create the history button
    var history_btn = Button.new()
    history_btn.name = "HistoryButton"
    history_btn.text = "History"
    hbox.add_child(history_btn)
    
    # Create the clear button
    var clear_btn = Button.new()
    clear_btn.name = "ClearButton"
    clear_btn.text = "Clear"
    hbox.add_child(clear_btn)
    
    # Set up style
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
    panel_style.border_width_bottom = 2
    panel_style.border_color = Color(0.3, 0.3, 0.3)
    console.add_theme_stylebox_override("panel", panel_style)
    
    # Make sure the node is a Control
    console.mouse_filter = Control.MOUSE_FILTER_STOP
    
    return console