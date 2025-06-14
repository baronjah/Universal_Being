extends Control

# References to UI components
onready var input_field = $VBoxContainer/InputContainer/InputField
onready var output_text = $VBoxContainer/OutputContainer/OutputText
onready var status_bar = $VBoxContainer/StatusBar
onready var prompt_label = $VBoxContainer/InputContainer/PromptLabel

# References to other systems
var word_animator
var word_translator
var turn_tracker

# Terminal styling
var terminal_colors = {
    "background": Color(0.08, 0.08, 0.12),
    "text": Color(0.8, 0.8, 0.9),
    "prompt": Color(0.5, 0.25, 0.75),
    "command": Color(0.25, 0.75, 0.5),
    "error": Color(0.75, 0.25, 0.25),
    "system": Color(0.25, 0.5, 0.75)
}

# Terminal state
var command_history = []
var command_index = -1
var terminal_mode = "command"  # command, visual, code
var sin_mode_active = false

# Logo animation state
var logo_text = "GODTERMINAL"
var logo_index = 0
var logo_timer = 0
var logo_colors = [
    Color(0.5, 0.25, 0.75),  # Purple
    Color(0.25, 0.5, 0.75),  # Blue
    Color(0.25, 0.75, 0.5),  # Teal
    Color(0.5, 0.75, 0.25),  # Green
    Color(0.75, 0.5, 0.25),  # Orange
    Color(0.75, 0.25, 0.5)   # Pink
]

func _ready():
    # Get references to other systems
    word_animator = get_node_or_null("/root/Main/WordAnimator")
    word_translator = get_node_or_null("/root/Main/WordTranslator")
    turn_tracker = get_node_or_null("/root/Main/TurnTracker")
    
    # Connect input field signals
    input_field.connect("text_entered", self, "_on_input_entered")
    
    # Initial terminal setup
    _setup_terminal()
    
    # Start animation timers
    set_process(true)

# Process animations and dynamic elements
func _process(delta):
    # Animate the logo in the status bar
    _animate_logo(delta)
    
    # Update turn information if available
    if turn_tracker:
        var status_text = "Turn: " + str(turn_tracker.current_turn) + "/" + str(turn_tracker.max_turns_per_phase)
        status_text += " | Phase: " + turn_tracker.get_current_phase_name()
        $VBoxContainer/StatusBar/TurnLabel.text = status_text

# Set up the terminal appearance and initial state
func _setup_terminal():
    # Set colors
    output_text.get("custom_styles/normal").bg_color = terminal_colors["background"]
    output_text.add_color_override("default_color", terminal_colors["text"])
    
    # Set the prompt
    prompt_label.text = "λ"
    prompt_label.add_color_override("font_color", terminal_colors["prompt"])
    
    # Focus the input field
    input_field.grab_focus()
    
    # Initial welcome message
    _print_output("GodTerminal System v1.0", terminal_colors["system"])
    _print_output("Phase 5: Awakening - Word Translator Active", terminal_colors["prompt"])
    _print_output("Type 'help' for available commands.", terminal_colors["text"])
    _print_output("", terminal_colors["text"])  # Empty line

# Handle input from the terminal
func _on_input_entered(text):
    # Don't process empty input
    if text.strip_edges().empty():
        input_field.text = ""
        return
    
    # Add command to history
    command_history.append(text)
    command_index = command_history.size()
    
    # Echo the command
    _print_output(prompt_label.text + " " + text, terminal_colors["command"])
    
    # Process the command
    _process_command(text)
    
    # Clear the input field
    input_field.text = ""

# Process keyboard input for special commands
func _input(event):
    if not input_field.has_focus():
        return
        
    if event is InputEventKey and event.pressed:
        # Command history navigation
        if event.scancode == KEY_UP:
            _navigate_history(-1)
            accept_event()
        elif event.scancode == KEY_DOWN:
            _navigate_history(1)
            accept_event()
        
        # Mode switching with Alt key
        if event.scancode == KEY_TAB and event.alt:
            _cycle_terminal_mode()
            accept_event()
            
        # Sin mode toggle with Shift+Ctrl+S
        if event.scancode == KEY_S and event.shift and event.control:
            sin_mode_active = !sin_mode_active
            
            if sin_mode_active:
                _print_output("Sin-to-Creation Translator Activated", Color(0.8, 0.2, 0.5))
                prompt_label.text = "✧"
            else:
                _print_output("Sin-to-Creation Translator Deactivated", terminal_colors["system"])
                prompt_label.text = "λ"
            
            accept_event()

# Navigate command history
func _navigate_history(direction):
    if command_history.empty():
        return
        
    command_index = clamp(command_index + direction, 0, command_history.size())
    
    if command_index == command_history.size():
        input_field.text = ""
    else:
        input_field.text = command_history[command_index]
        
    # Move cursor to end of text
    input_field.caret_position = input_field.text.length()

# Cycle through different terminal modes
func _cycle_terminal_mode():
    match terminal_mode:
        "command":
            terminal_mode = "visual"
            prompt_label.text = "◆"
            _print_output("Switched to visual mode", terminal_colors["system"])
        "visual":
            terminal_mode = "code"
            prompt_label.text = "{"
            _print_output("Switched to code mode", terminal_colors["system"])
        "code":
            terminal_mode = "command"
            prompt_label.text = "λ"
            _print_output("Switched to command mode", terminal_colors["system"])

# Process a command
func _process_command(text):
    # Check for built-in commands first
    var command = text.strip_edges().to_lower()
    var parts = command.split(" ", false)
    
    if parts.empty():
        return
    
    match parts[0]:
        "help":
            _show_help()
        "clear":
            _clear_output()
        "mode":
            if parts.size() > 1:
                _set_terminal_mode(parts[1])
            else:
                _print_output("Current mode: " + terminal_mode, terminal_colors["system"])
        "echo":
            var echo_text = text.substr(5)  # Remove 'echo ' from the start
            _print_output(echo_text, terminal_colors["text"])
        "manifest":
            if parts.size() > 1:
                _manifest_word(text.substr(9))  # Remove 'manifest ' from the start
            else:
                _print_output("Usage: manifest <word/phrase>", terminal_colors["error"])
        "translate":
            if parts.size() > 2:
                _translate_text(parts[1], text.substr(text.find(parts[2])))
            else:
                _print_output("Usage: translate <mode> <text>", terminal_colors["error"])
                _print_output("Modes: body, visual, sound, system, human, sin", terminal_colors["error"])
        "turn":
            if turn_tracker:
                if parts.size() > 1 and parts[1] == "advance":
                    turn_tracker.advance_turn()
                    _print_output("Advanced to turn " + str(turn_tracker.current_turn) + " of phase " + turn_tracker.get_current_phase_name(), terminal_colors["system"])
                else:
                    _print_output("Current turn: " + str(turn_tracker.current_turn) + "/" + str(turn_tracker.max_turns_per_phase), terminal_colors["system"])
                    _print_output("Current phase: " + turn_tracker.get_current_phase_name(), terminal_colors["system"])
            else:
                _print_output("Turn system not available", terminal_colors["error"])
        "exit":
            _print_output("Terminal will remain active.", terminal_colors["system"])
        _:
            # Process with the translator if available
            if word_translator:
                var translation_mode = word_translator.TranslationMode.HUMAN_TO_SYSTEM
                
                # Use sin mode if active
                if sin_mode_active:
                    translation_mode = word_translator.TranslationMode.SIN_TO_CREATION
                
                var result = word_translator.translate(text, translation_mode)
                _print_output(result, terminal_colors["system"])
            else:
                # Fall back to standard response
                _print_output("Unknown command: " + parts[0], terminal_colors["error"])
                _print_output("Type 'help' for available commands.", terminal_colors["text"])

# Show help information
func _show_help():
    _print_output("Available commands:", terminal_colors["system"])
    _print_output("  help - Show this help information", terminal_colors["text"])
    _print_output("  clear - Clear the terminal output", terminal_colors["text"])
    _print_output("  mode [type] - Set terminal mode (command, visual, code)", terminal_colors["text"])
    _print_output("  echo <text> - Display text in the terminal", terminal_colors["text"])
    _print_output("  manifest <word> - Create visual manifestation of a word", terminal_colors["text"])
    _print_output("  translate <mode> <text> - Translate text using specified mode", terminal_colors["text"])
    _print_output("    Modes: body, visual, sound, system, human, sin", terminal_colors["text"])
    _print_output("  turn [advance] - Show current turn or advance to next", terminal_colors["text"])
    _print_output("", terminal_colors["text"])
    _print_output("Special keys:", terminal_colors["system"])
    _print_output("  Up/Down - Navigate command history", terminal_colors["text"])
    _print_output("  Alt+Tab - Cycle between terminal modes", terminal_colors["text"])
    _print_output("  Shift+Ctrl+S - Toggle Sin-to-Creation translator", terminal_colors["text"])

# Clear the terminal output
func _clear_output():
    output_text.text = ""

# Set terminal mode
func _set_terminal_mode(mode):
    match mode:
        "command":
            terminal_mode = "command"
            prompt_label.text = "λ"
            _print_output("Switched to command mode", terminal_colors["system"])
        "visual":
            terminal_mode = "visual"
            prompt_label.text = "◆"
            _print_output("Switched to visual mode", terminal_colors["system"])
        "code":
            terminal_mode = "code"
            prompt_label.text = "{"
            _print_output("Switched to code mode", terminal_colors["system"])
        _:
            _print_output("Unknown mode: " + mode, terminal_colors["error"])
            _print_output("Available modes: command, visual, code", terminal_colors["text"])

# Manifest a word visually
func _manifest_word(word_text):
    if word_animator:
        var words = word_text.split(" ", false)
        var manifested = 0
        
        for word in words:
            if not word.empty():
                word_animator.manifest_random_word(word)
                manifested += 1
        
        _print_output("Manifested " + str(manifested) + " words in visual space", terminal_colors["system"])
    else:
        _print_output("Word Animator not available", terminal_colors["error"])

# Translate text using specified mode
func _translate_text(mode, text):
    if not word_translator:
        _print_output("Word Translator not available", terminal_colors["error"])
        return
    
    var translation_mode = word_translator.TranslationMode.SYSTEM_TO_HUMAN  # Default
    
    match mode:
        "body":
            translation_mode = word_translator.TranslationMode.BODY_TO_WORD
        "visual":
            translation_mode = word_translator.TranslationMode.WORD_TO_VISUAL
        "sound":
            translation_mode = word_translator.TranslationMode.WORD_TO_SOUND
        "system":
            translation_mode = word_translator.TranslationMode.SYSTEM_TO_HUMAN
        "human":
            translation_mode = word_translator.TranslationMode.HUMAN_TO_SYSTEM
        "sin":
            translation_mode = word_translator.TranslationMode.SIN_TO_CREATION
        _:
            _print_output("Unknown translation mode: " + mode, terminal_colors["error"])
            _print_output("Available modes: body, visual, sound, system, human, sin", terminal_colors["text"])
            return
    
    var result = word_translator.translate(text, translation_mode)
    _print_output(result, terminal_colors["system"])

# Print text to output with specified color
func _print_output(text, color=terminal_colors["text"]):
    # Add colored text to output
    output_text.push_color(color)
    output_text.add_text(text)
    output_text.pop()
    output_text.newline()
    
    # Scroll to bottom
    output_text.scroll_vertical = output_text.get_line_count()

# Animate the terminal logo
func _animate_logo(delta):
    logo_timer += delta
    
    # Update every 0.5 seconds
    if logo_timer >= 0.5:
        logo_timer = 0
        
        # Update logo color based on current phase
        var color_index = 0
        if turn_tracker:
            color_index = turn_tracker.current_phase - 1
        
        color_index = color_index % logo_colors.size()
        
        # Set the logo text and color
        var logo_label = $VBoxContainer/StatusBar/LogoLabel
        logo_label.text = logo_text
        logo_label.add_color_override("font_color", logo_colors[color_index])
        
        # If in sin mode, add special effects
        if sin_mode_active:
            logo_label.text = "✧ " + logo_text + " ✧"