extends Node3D
class_name SimpleConsole

var console_ui: Control
var output_display: RichTextLabel
var input_field: LineEdit
var command_history: Array[String] = []
var history_index: int = 0
var console_visible: bool = false

func _ready():
	_create_console_ui()
	print("Simple Console initialized")

func _create_console_ui():
	# Create console UI container
	console_ui = Control.new()
	console_ui.name = "ConsoleUI"
	console_ui.set_anchors_preset(Control.PRESET_TOP_WIDE)
	console_ui.size = Vector2(get_viewport().size.x, 400)
	console_ui.visible = console_visible
	
	# Background panel
	var panel = Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.modulate = Color(0.1, 0.1, 0.1, 0.9)
	console_ui.add_child(panel)
	
	# Output display
	output_display = RichTextLabel.new()
	output_display.set_anchors_preset(Control.PRESET_FULL_RECT)
	output_display.offset_bottom = -40
	output_display.bbcode_enabled = true
	output_display.scroll_following = true
	console_ui.add_child(output_display)
	
	# Input field
	input_field = LineEdit.new()
	input_field.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	input_field.position.y = -40
	input_field.size.y = 30
	input_field.placeholder_text = "Type commands here..."
	input_field.text_submitted.connect(_on_command_submitted)
	console_ui.add_child(input_field)
	
	# Add to viewport
	get_viewport().call_deferred("add_child", console_ui)
	
	# Welcome message
	write_output("=== UNIVERSAL CONSOLE ===")
	write_output("Type 'help' for commands")
	write_output("Ready to create game together!")
	write_output("")

func _input(event):
	if event.is_action_pressed("open_console"):
		toggle_console_visibility()
		get_viewport().set_input_as_handled()
		
	# Lock other inputs when console is open
	if console_visible and console_ui and console_ui.visible:
		if event is InputEventKey:
			if event.keycode != KEY_QUOTELEFT:  # Allow tilde to close console
				get_viewport().set_input_as_handled()

func toggle_console_visibility():
	console_visible = not console_visible
	if console_ui:
		console_ui.visible = console_visible
		if console_visible and input_field:
			input_field.grab_focus()

func write_output(text: String):
	if output_display:
		output_display.append_text(text + "\n")

func _on_command_submitted(command: String):
	if command.strip_edges().is_empty():
		return
	
	# Add to history
	command_history.append(command)
	history_index = command_history.size()
	
	# Display command
	write_output("> " + command)
	
	# Process command
	var parts = command.split(" ", false)
	if parts.is_empty():
		return
	
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	match cmd:
		"help":
			write_output("Commands: help, clear, spawn, ai, test")
		"clear":
			output_display.clear()
		"spawn":
			write_output("Spawning Universal Being...")
		"ai":
			write_output("AI Communication ready")
		"test":
			write_output("Console test successful!")
		_:
			write_output("AI: Processing '" + command + "'")
			write_output("Creating game element...")
	
	# Clear input
	input_field.text = ""