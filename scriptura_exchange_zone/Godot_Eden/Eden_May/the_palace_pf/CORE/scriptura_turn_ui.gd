extends Control

# Scriptura Turn System UI
# Visual interface for the advanced turn management system

# Reference to Scriptura Turn System
var turn_system = null

# UI Elements
onready var turn_label = $HeaderPanel/TurnLabel
onready var progress_bar = $HeaderPanel/ProgressBar
onready var ocr_button = $ControlPanel/OCRButton
onready var api_panel = $APIPanel
onready var game_panel = $GamePanel
onready var turn_history_panel = $TurnHistoryPanel
onready var color_indicator = $HeaderPanel/ColorIndicator
onready var file_dialog = $FileDialog
onready var output_text = $OutputPanel/OutputText

# Color transition animation
var color_tween = null

# Connection status
var api_status = {
	"gemini": false,
	"luminous": false,
	"claude": false
}

func _ready():
	print("Scriptura Turn UI initializing")
	initialize_ui()
	find_turn_system()
	setup_connections()

func initialize_ui():
	# Initialize color tween
	color_tween = Tween.new()
	add_child(color_tween)
	
	# Setup file dialog
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	file_dialog.current_path = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.add_filter("*.png ; PNG Images")
	file_dialog.add_filter("*.jpg,*.jpeg ; JPEG Images")
	file_dialog.add_filter("*.bmp ; BMP Images")
	file_dialog.add_filter("*.tiff ; TIFF Images")
	
	# Set initial colors
	color_indicator.color = Color(1.0, 0.9, 0.5)  # Turn 8 color
	
	# Connect buttons
	$ControlPanel/ConnectButton.connect("pressed", self, "_on_connect_button_pressed")
	$ControlPanel/OCRButton.connect("pressed", self, "_on_ocr_button_pressed")
	$GamePanel/CreateGameButton.connect("pressed", self, "_on_create_game_pressed")
	$TurnHistoryPanel/ViewArchiveButton.connect("pressed", self, "_on_view_archive_pressed")
	$ControlPanel/NextTurnButton.connect("pressed", self, "_on_next_turn_pressed")
	
	file_dialog.connect("file_selected", self, "_on_file_selected")
	
	# Initial output text
	output_text.bbcode_text = "[b]Scriptura Turn System[/b]\n"
	output_text.bbcode_text += "A system for text-based game creation across multiple turns.\n\n"
	output_text.bbcode_text += "Current turn: 8 - Lines\n"
	output_text.bbcode_text += "Use the controls to connect APIs, process OCR images, and create games.\n"

func find_turn_system():
	# Try to find the Scriptura Turn System
	turn_system = get_node_or_null("../ScripturaTurnSystem")
	if not turn_system:
		turn_system = get_node_or_null("/root/EdenMayGame/ScripturaTurnSystem")
	
	# Create new instance if not found
	if not turn_system and load("res://Eden_May/scriptura_turn_system.gd"):
		var ScripturaTurnSystem = load("res://Eden_May/scriptura_turn_system.gd")
		turn_system = ScripturaTurnSystem.new()
		turn_system.name = "ScripturaTurnSystem"
		get_parent().add_child(turn_system)
	
	if turn_system:
		print("Scriptura Turn System found/created")
		update_turn_display()
	else:
		print("Failed to create Scriptura Turn System")

func setup_connections():
	if not turn_system:
		print("Scriptura Turn System not available")
		return
	
	# Connect signals
	turn_system.connect("turn_advanced", self, "_on_turn_advanced")
	turn_system.connect("turn_progress_updated", self, "_on_turn_progress_updated")
	turn_system.connect("ocr_result_ready", self, "_on_ocr_result_ready")
	turn_system.connect("game_created", self, "_on_game_created")
	turn_system.connect("api_connection_changed", self, "_on_api_connection_changed")

func update_turn_display():
	if not turn_system:
		return
	
	var turn_number = turn_system.current_turn
	var turn_name = turn_system.get_turn_name(turn_number)
	var progress = turn_system.turn_progress
	
	# Update turn label
	turn_label.text = "Turn " + str(turn_number) + ": " + turn_name
	
	# Update progress bar
	progress_bar.value = progress
	
	# Update between turns indicator
	if turn_system.between_turns:
		$HeaderPanel/BetweenLabel.text = "Transitioning to Turn " + str(turn_number + 1)
		$HeaderPanel/BetweenLabel.visible = true
	else:
		$HeaderPanel/BetweenLabel.visible = false
	
	# Update color
	update_color_display()

func update_color_display():
	if not turn_system:
		return
	
	var target_color
	
	if turn_system.between_turns:
		# Transition between colors
		var from_color = turn_system.get_turn_color(turn_system.current_turn)
		var to_color = turn_system.get_turn_color(turn_system.current_turn + 1)
		
		target_color = from_color.linear_interpolate(to_color, turn_system.turn_transition_phase)
	else:
		target_color = turn_system.get_turn_color(turn_system.current_turn)
	
	# Apply color with animation
	color_tween.interpolate_property(color_indicator, "color", 
								  color_indicator.color, target_color, 0.5, 
								  Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	color_tween.start()

func update_api_status():
	if not turn_system:
		return
	
	# Update API status indicators
	for api_name in api_status:
		var indicator = $APIPanel.get_node(api_name.capitalize() + "Indicator")
		if indicator:
			var status = turn_system.connected_apis[api_name]
			indicator.color = Color(0.2, 0.8, 0.2) if status else Color(0.8, 0.2, 0.2)
			
			var label = $APIPanel.get_node(api_name.capitalize() + "Label")
			if label:
				label.text = api_name.capitalize() + ": " + ("Connected" if status else "Disconnected")

func _on_connect_button_pressed():
	if not turn_system:
		return
	
	var result = turn_system.connect_to_apis()
	
	if result:
		add_output_text("Connecting to APIs...")
	else:
		add_output_text("Failed to connect to APIs")

func _on_ocr_button_pressed():
	if not turn_system:
		return
	
	# Enable OCR if not already active
	if not turn_system.ocr_active:
		turn_system.enable_ocr()
		add_output_text("OCR processing enabled")
	
	# Show file dialog
	file_dialog.popup_centered_ratio(0.7)

func _on_file_selected(path):
	if not turn_system or not turn_system.ocr_active:
		add_output_text("OCR not active. Cannot process image.")
		return
	
	var result = turn_system.process_image(path)
	
	if result:
		add_output_text("Processing image: " + path.get_file())
	else:
		add_output_text("Failed to process image: " + path.get_file())

func _on_create_game_pressed():
	if not turn_system:
		return
	
	if turn_system.current_turn < 9:
		add_output_text("Cannot create games before Turn 9. Current turn: " + str(turn_system.current_turn))
		return
	
	add_output_text("Starting game creation process...")
	if turn_system.game_creator:
		turn_system.game_creator.start_creation(
			turn_system.word_collection,
			turn_system.line_processor.get_pattern_stats() if turn_system.line_processor else {}
		)

func _on_view_archive_pressed():
	if not turn_system:
		return
	
	var archive_size = turn_system.turn_archive.size()
	var archive_text = "Turn Archive (" + str(archive_size) + " turns):\n\n"
	
	for turn_number in turn_system.turn_archive:
		var turn_data = turn_system.turn_archive[turn_number]
		var timestamp = turn_data.timestamp
		var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
		
		archive_text += "Turn " + str(turn_number) + " - " + turn_system.get_turn_name(int(turn_number)) + "\n"
		archive_text += "Completed: " + str(datetime.year) + "-" + str(datetime.month) + "-" + str(datetime.day) + "\n"
		
		if turn_data.has("word_collection"):
			var word_count = turn_data.word_collection.size()
			archive_text += "Words: " + str(word_count) + "\n"
		
		archive_text += "\n"
	
	add_output_text(archive_text)

func _on_next_turn_pressed():
	if not turn_system:
		return
	
	if turn_system.between_turns:
		add_output_text("Already transitioning to next turn")
		return
	
	if turn_system.turn_progress < 100.0:
		turn_system.turn_progress = 100.0
		turn_system.update_turn_progress(0)
		add_output_text("Advancing to next turn...")
	else:
		add_output_text("Turn progress already complete. Transitioning...")

func _on_turn_advanced(turn_number, turn_name):
	add_output_text("Advanced to Turn " + str(turn_number) + ": " + turn_name)
	update_turn_display()

func _on_turn_progress_updated(progress):
	progress_bar.value = progress
	
	# Update between turns indicator if needed
	if turn_system and turn_system.between_turns:
		var phase = turn_system.turn_transition_phase * 100.0
		$HeaderPanel/BetweenLabel.text = "Transitioning to Turn " + str(turn_system.current_turn + 1) + " (" + str(int(phase)) + "%)"
		update_color_display()

func _on_ocr_result_ready(text, source_file):
	add_output_text("OCR processing completed for: " + source_file.get_file())
	add_output_text("Extracted text: " + text.substr(0, 100) + "..." if text.length() > 100 else text)

func _on_game_created(game_data):
	add_output_text("Game created: " + game_data.name)
	add_output_text("Description: " + game_data.description)
	
	# Update game panel
	$GamePanel/GameNameLabel.text = "Game: " + game_data.name
	$GamePanel/GameDescLabel.text = game_data.description
	
	# Update game elements
	var elements_text = ""
	for mechanic in game_data.mechanics:
		elements_text += "- " + mechanic + "\n"
	
	$GamePanel/GameElementsText.text = elements_text

func _on_api_connection_changed(api_name, connected):
	add_output_text(api_name.capitalize() + " API " + ("connected" if connected else "disconnected"))
	update_api_status()

func add_output_text(text):
	output_text.bbcode_text += "\n" + text
	
	# Auto-scroll to bottom
	yield(get_tree(), "idle_frame")
	output_text.scroll_vertical = output_text.get_content_height()