extends Control
class_name LuminousUIController

# UI Components
@onready var path_display: Label = $PathBar/PathDisplay
@onready var command_input: LineEdit = $CommandBar/CommandInput
@onready var command_output: RichTextLabel = $OutputPanel/CommandOutput
@onready var file_preview: Control = $FilePreviewPanel
@onready var divine_message_panel: Panel = $DivineMessagePanel
@onready var divine_message_label: Label = $DivineMessagePanel/MessageLabel
@onready var help_panel: Panel = $HelpPanel

# File preview components
@onready var text_preview: TextEdit = $FilePreviewPanel/TextPreview
@onready var image_preview: TextureRect = $FilePreviewPanel/ImagePreview
@onready var model_preview: SubViewport = $FilePreviewPanel/ModelPreviewContainer/ModelViewport
@onready var audio_player: AudioStreamPlayer = $AudioPlayer

# Reference to main controller
var os_controller: LuminousOSController

# Theme settings
var normal_theme: Theme
var divine_theme: Theme

# Divine message animation
var divine_message_tween: Tween

func _ready():
	# Connect signals
	command_input.text_submitted.connect(_on_command_submitted)
	
	# Hide panels initially
	file_preview.visible = false
	divine_message_panel.visible = false
	help_panel.visible = false
	
	# Set up themes
	normal_theme = theme
	divine_theme = theme.duplicate()
	var divine_style = divine_theme.get_stylebox("normal", "Button").duplicate()
	divine_style.bg_color = Color(0.2, 0.0, 0.3)
	divine_theme.set_stylebox("normal", "Button", divine_style)
	
	# Initialize with empty path
	set_path_display("/")

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			toggle_help_panel()
		elif event.pressed and event.keycode == KEY_ESCAPE:
			# Close any open panels
			if file_preview.visible:
				file_preview.visible = false
			elif divine_message_panel.visible:
				hide_divine_message()
			elif help_panel.visible:
				help_panel.visible = false

func set_path_display(path: String):
	path_display.text = path

func update_directory_contents(dir_data: Dictionary):
	var output_text = "[b]Directory: " + dir_data["path"] + "[/b]\n\n"
	
	# Add directories
	if dir_data["directories"].size() > 0:
		output_text += "[color=#88AAFF][b]STARS (Directories):[/b][/color]\n"
		for dir in dir_data["directories"]:
			output_text += "  ★ " + dir["name"] + "\n"
		output_text += "\n"
	
	# Add files grouped by type
	if dir_data["files"].size() > 0:
		var files_by_type = {}
		for file in dir_data["files"]:
			if not files_by_type.has(file["type"]):
				files_by_type[file["type"]] = []
			files_by_type[file["type"]].append(file["name"])
		
		output_text += "[color=#AAFFAA][b]PLANETS (Files):[/b][/color]\n"
		for type in files_by_type:
			output_text += "  [color=#DDDDDD][b]" + type + ":[/b][/color]\n"
			for filename in files_by_type[type]:
				output_text += "    ○ " + filename + "\n"
	
	command_output.text = output_text

func add_command_output(command: String, output: String):
	var timestamp = Time.get_datetime_string_from_system().split(" ")[1]
	command_output.text += "\n[color=#AAAAAA]" + timestamp + "[/color] [color=#FFAA00]> " + command + "[/color]\n"
	command_output.text += output + "\n"
	
	# Scroll to bottom
	command_output.scroll_to_line(command_output.get_line_count())

func show_file_preview(file_path: String, file_type: String):
	# Hide all preview components first
	text_preview.visible = false
	image_preview.visible = false
	model_preview.get_parent().visible = false
	
	# Set title
	$FilePreviewPanel/TitleBar/TitleLabel.text = file_path.get_file()
	
	match file_type:
		"TEXT", "SCRIPT":
			# Display text content
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var content = file.get_as_text()
				text_preview.text = content
				text_preview.visible = true
				
				# Set syntax highlighting for scripts
				if file_type == "SCRIPT":
					if file_path.ends_with(".gd"):
						text_preview.syntax_highlighter = GDScriptSyntaxHighlighter.new()
		
		"TEXTURE":
			# Display image
			var texture = load(file_path)
			if texture:
				image_preview.texture = texture
				image_preview.visible = true
		
		"MODEL":
			# Display model (simplified)
			model_preview.get_parent().visible = true
			# In a real implementation, we would load the model into the SubViewport
		
		"AUDIO":
			# Play audio
			var stream = load(file_path)
			if stream:
				audio_player.stream = stream
				audio_player.play()
				
				# Show waveform placeholder
				text_preview.text = "🎵 Audio Playback: " + file_path.get_file() + " 🎵"
				text_preview.visible = true
		
		_:
			# Generic text display for unknown types
			text_preview.text = "Preview not available for this file type:\n" + file_path
			text_preview.visible = true
	
	file_preview.visible = true

func show_divine_message(message: String):
	# Set message
	divine_message_label.text = message
	
	# Show panel with animation
	divine_message_panel.modulate = Color(1, 1, 1, 0)
	divine_message_panel.visible = true
	
	# Cancel previous tween if exists
	if divine_message_tween:
		divine_message_tween.kill()
	
	# Create new fade-in tween
	divine_message_tween = create_tween()
	divine_message_tween.tween_property(divine_message_panel, "modulate", Color(1, 1, 1, 1), 0.5)
	
	# Auto-hide after delay
	divine_message_tween.tween_interval(4.0)
	divine_message_tween.tween_property(divine_message_panel, "modulate", Color(1, 1, 1, 0), 0.5)
	divine_message_tween.tween_callback(hide_divine_message)

func hide_divine_message():
	divine_message_panel.visible = false

func toggle_help_panel():
	help_panel.visible = !help_panel.visible

func switch_to_divine_mode(enabled: bool):
	if enabled:
		theme = divine_theme
		$PathBar.modulate = Color(1.0, 0.8, 1.0)
		$CommandBar.modulate = Color(1.0, 0.8, 1.0)
	else:
		theme = normal_theme
		$PathBar.modulate = Color(1.0, 1.0, 1.0)
		$CommandBar.modulate = Color(1.0, 1.0, 1.0)

func _on_command_submitted(command: String):
	if command.strip_edges() == "":
		return
		
	var result = os_controller.execute_command(command)
	add_command_output(command, result)
	
	# Clear command input
	command_input.text = ""

func _on_close_preview_pressed():
	file_preview.visible = false
	# Stop audio if playing
	audio_player.stop()

func _on_help_button_pressed():
	toggle_help_panel()

func _on_close_help_pressed():
	help_panel.visible = false