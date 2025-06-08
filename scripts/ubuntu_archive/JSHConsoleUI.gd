extends Control
class_name JSHConsoleUI

# UI references
@onready var output_text: RichTextLabel = $VBoxContainer/OutputPanel/ScrollContainer/RichTextLabel
@onready var input_field: LineEdit = $VBoxContainer/InputContainer/LineEdit
@onready var autocomplete_panel: Panel = $VBoxContainer/AutocompletePanel
@onready var autocomplete_list: ItemList = $VBoxContainer/AutocompletePanel/ItemList

# Console manager reference
var console_manager: JSHConsoleManager = null

# Autocomplete tracking
var autocomplete_index: int = -1
var autocomplete_suggestions: Array = []

# History navigation
var history_index: int = -1
var current_input: String = ""

# Console settings
var max_console_lines: int = 1000
var console_font_size: int = 14
var console_opacity: float = 0.9
var console_theme: String = "dark"  # dark or light

# Console themes
var themes = {
    "dark": {
        "background": Color(0.1, 0.1, 0.15, 0.9),
        "input_background": Color(0.15, 0.15, 0.2, 1.0),
        "text": Color(0.9, 0.9, 0.9),
        "prompt": Color(0.2, 0.7, 1.0)
    },
    "light": {
        "background": Color(0.9, 0.9, 0.95, 0.9),
        "input_background": Color(1.0, 1.0, 1.0, 1.0),
        "text": Color(0.1, 0.1, 0.1),
        "prompt": Color(0.0, 0.5, 0.8)
    }
}

func _ready() -> void:
    # Get console manager
    console_manager = JSHConsoleManager.get_instance()
    
    # Hide by default
    visible = false
    autocomplete_panel.visible = false
    
    # Connect signals
    console_manager.connect("console_output_updated", Callable(self, "_on_console_output_updated"))
    console_manager.connect("console_visibility_changed", Callable(self, "_on_console_visibility_changed"))
    console_manager.connect("command_executed", Callable(self, "_on_command_executed"))
    
    input_field.connect("text_submitted", Callable(self, "_on_input_submitted"))
    input_field.connect("text_changed", Callable(self, "_on_input_text_changed"))
    input_field.connect("gui_input", Callable(self, "_on_input_gui_input"))
    
    autocomplete_list.connect("item_selected", Callable(self, "_on_autocomplete_item_selected"))
    
    # Apply theme
    apply_theme(console_theme)
    
    # Welcome message
    console_manager.print_line("JSH Eden Console System v1.0", Color(0.2, 0.7, 1.0))
    console_manager.print_line("Type 'help' for a list of commands", Color(0.7, 0.7, 0.7))
    console_manager.print_line("", Color.WHITE)  # Empty line

func _process(delta: float) -> void:
    if visible:
        # Ensure input has focus when console is visible
        if not input_field.has_focus():
            input_field.grab_focus()

func _input(event: InputEvent) -> void:
    # Toggle console visibility with tilde key
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_QUOTELEFT or event.keycode == KEY_F1:  # Tilde or F1
            toggle_visibility()
            get_viewport().set_input_as_handled()
    
    # Disable all other input when console is visible
    if visible and event is InputEventKey:
        if event.keycode == KEY_ESCAPE and event.pressed and not event.echo:
            hide_console()
            get_viewport().set_input_as_handled()

# Console visibility
func show_console() -> void:
    visible = true
    console_manager.set_visible(true)
    input_field.grab_focus()
    
    # Reset any pending autocomplete
    hide_autocomplete()

func hide_console() -> void:
    visible = false
    console_manager.set_visible(false)
    
    # Reset input field and history when hiding
    input_field.text = ""
    history_index = -1
    current_input = ""
    
    # Hide autocomplete
    hide_autocomplete()

func toggle_visibility() -> void:
    if visible:
        hide_console()
    else:
        show_console()

# Console output
func update_output() -> void:
    var output_buffer = console_manager.output_buffer
    
    # Limit output buffer size
    if output_buffer.size() > max_console_lines:
        output_buffer = output_buffer.slice(output_buffer.size() - max_console_lines)
    
    # Clear output
    output_text.clear()
    
    # Add output lines
    for line in output_buffer:
        var color = line.color
        var text = line.text
        
        # Add text with color
        output_text.push_color(color)
        output_text.add_text(text)
        output_text.pop()
        output_text.add_text("\n")
    
    # Scroll to bottom
    output_text.scroll_to_line(output_text.get_line_count() - 1)

# Command input
func submit_command(command: String) -> void:
    if command.strip_edges().is_empty():
        return
    
    # Add command to output with prompt
    var theme_color = themes[console_theme].prompt
    console_manager.print_line("> " + command, theme_color)
    
    # Reset input field
    input_field.text = ""
    
    # Execute command
    console_manager.execute_command(command)
    
    # Reset autocomplete
    hide_autocomplete()
    
    # Reset history navigation
    history_index = -1
    current_input = ""

# History navigation
func navigate_history(direction: int) -> void:
    var history = console_manager.get_command_history()
    
    if history.size() == 0:
        return
    
    # Save current input if starting navigation
    if history_index == -1:
        current_input = input_field.text
    
    # Navigate
    history_index += direction
    
    # Clamp history index
    if history_index < -1:
        history_index = -1
    elif history_index >= history.size():
        history_index = history.size() - 1
    
    # Update input field
    if history_index == -1:
        input_field.text = current_input
    else:
        input_field.text = history[history_index]
    
    # Move cursor to end
    input_field.caret_column = input_field.text.length()

# Autocomplete
func update_autocomplete() -> void:
    var input_text = input_field.text
    var cursor_pos = input_field.caret_column
    
    # Only autocomplete at end of input
    if cursor_pos < input_text.length():
        hide_autocomplete()
        return
    
    # Get suggestions
    autocomplete_suggestions = console_manager.get_autocomplete_suggestions(input_text)
    
    if autocomplete_suggestions.size() == 0:
        hide_autocomplete()
        return
    
    # Show autocomplete panel
    autocomplete_panel.visible = true
    
    # Update autocomplete list
    autocomplete_list.clear()
    for suggestion in autocomplete_suggestions:
        autocomplete_list.add_item(suggestion)
    
    # Reset selection
    autocomplete_index = -1

func navigate_autocomplete(direction: int) -> void:
    if autocomplete_suggestions.size() == 0:
        return
    
    # Update index
    autocomplete_index += direction
    
    # Wrap around
    if autocomplete_index < 0:
        autocomplete_index = autocomplete_suggestions.size() - 1
    elif autocomplete_index >= autocomplete_suggestions.size():
        autocomplete_index = 0
    
    # Update selection
    autocomplete_list.select(autocomplete_index)
    autocomplete_list.ensure_current_is_visible()

func complete_with_suggestion(index: int = -1) -> void:
    if autocomplete_suggestions.size() == 0:
        return
    
    # Use selected index or current index
    if index >= 0:
        autocomplete_index = index
    
    # Ensure valid index
    if autocomplete_index < 0 or autocomplete_index >= autocomplete_suggestions.size():
        return
    
    # Extract command parts
    var parts = input_field.text.split(" ")
    
    # Replace command or last argument
    if parts.size() <= 1:
        # Replace command
        input_field.text = autocomplete_suggestions[autocomplete_index]
    else:
        # Replace last argument
        parts[parts.size() - 1] = autocomplete_suggestions[autocomplete_index]
        input_field.text = " ".join(parts)
    
    # Move cursor to end
    input_field.caret_column = input_field.text.length()
    
    # Hide autocomplete
    hide_autocomplete()

func hide_autocomplete() -> void:
    autocomplete_panel.visible = false
    autocomplete_suggestions.clear()
    autocomplete_index = -1

# Theme management
func apply_theme(theme_name: String) -> void:
    if not themes.has(theme_name):
        theme_name = "dark"  # Default to dark
    
    console_theme = theme_name
    var theme = themes[theme_name]
    
    # Background
    modulate.a = console_opacity
    $Background.color = theme.background
    
    # Input field
    var style_normal = StyleBoxFlat.new()
    style_normal.bg_color = theme.input_background
    style_normal.border_width_bottom = 2
    style_normal.border_color = theme.prompt
    style_normal.corner_radius_bottom_right = 5
    style_normal.corner_radius_bottom_left = 5
    input_field.add_theme_stylebox_override("normal", style_normal)
    input_field.add_theme_color_override("font_color", theme.text)
    
    # Output text
    output_text.add_theme_color_override("default_color", theme.text)
    
    # Autocomplete panel
    var style_autocomplete = StyleBoxFlat.new()
    style_autocomplete.bg_color = theme.input_background
    style_autocomplete.border_width_bottom = 1
    style_autocomplete.border_color = theme.prompt
    style_autocomplete.corner_radius_bottom_right = 5
    style_autocomplete.corner_radius_bottom_left = 5
    autocomplete_panel.add_theme_stylebox_override("panel", style_autocomplete)
    
    # Command prompt
    $VBoxContainer/InputContainer/PromptLabel.add_theme_color_override("font_color", theme.prompt)

# UI Signal handlers
func _on_input_submitted(text: String) -> void:
    submit_command(text)

func _on_input_text_changed(new_text: String) -> void:
    # Update autocomplete
    update_autocomplete()

func _on_input_gui_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_UP:
                if autocomplete_panel.visible:
                    navigate_autocomplete(-1)
                else:
                    navigate_history(-1)
                get_viewport().set_input_as_handled()
            
            KEY_DOWN:
                if autocomplete_panel.visible:
                    navigate_autocomplete(1)
                else:
                    navigate_history(1)
                get_viewport().set_input_as_handled()
            
            KEY_TAB:
                if autocomplete_panel.visible and autocomplete_index >= 0:
                    complete_with_suggestion(autocomplete_index)
                elif autocomplete_suggestions.size() > 0:
                    complete_with_suggestion(0)
                get_viewport().set_input_as_handled()
            
            KEY_ESCAPE:
                if autocomplete_panel.visible:
                    hide_autocomplete()
                    get_viewport().set_input_as_handled()

func _on_autocomplete_item_selected(index: int) -> void:
    complete_with_suggestion(index)

# Console manager signal handlers
func _on_console_output_updated() -> void:
    update_output()

func _on_console_visibility_changed(is_visible: bool) -> void:
    visible = is_visible
    
    if is_visible:
        input_field.grab_focus()
    else:
        # Reset input field and autocomplete
        input_field.text = ""
        hide_autocomplete()

func _on_command_executed(command_text: String, result: Dictionary) -> void:
    # Commands are already displayed via print_line in the console manager