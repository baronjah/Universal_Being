extends Node3D
## Main Controller for 12 Turns System
## Integrates all subsystems with 5-layer visualization
class_name MainController

# ==================================================
# SCRIPT NAME: main_controller.gd
# DESCRIPTION: Central coordination for 12 turns system
# UPDATED: 2025-05-24 - Integrated with layer system
# ==================================================

# ----- REFERENCES -----
var screen_capture = null
var ocr_processor = null
var offline_ocr = null
var auto_updater = null
var auto_connector = null
var color_theme_system = null
var task_animator = null

# New 12 Turns System References
@onready var camera: Camera3D = $Camera3D
@onready var turn_layer_environment = $TurnLayerEnvironment
@onready var turn_system_controller = $TurnSystemController
@onready var ui_panel = $UI/InfoPanel
@onready var debug_label = $UI/DebugInfo

# System state
var layers_visible: bool = true
var current_focus_layer: int = 0
var fps_timer: float = 0.0

# ----- CONFIGURATION -----
@export var auto_initialize: bool = true
@export var debug_mode: bool = false
@export var default_theme: String = "default"
@export var enable_animations: bool = true
@export var enable_auto_updates: bool = true
@export var enable_auto_connection: bool = true
@export var capture_hotkey: String = "Ctrl+Shift+P"
@export var ocr_hotkey: String = "Ctrl+Shift+O"

# ----- SIGNALS -----
signal initialization_completed()
signal component_initialized(component_name)
signal component_failed(component_name, error)
signal capture_completed(image_path)
signal ocr_completed(text)
signal theme_changed(theme_name)
signal connection_status_changed(status)

# ----- INITIALIZATION -----
func _ready():
	# Initialize systems
	if auto_initialize:
		initialize_all()
	
	# Initialize turn layer environment
	if turn_layer_environment and camera:
		turn_layer_environment.initialize(camera, self)
		turn_layer_environment.layer_focus_changed.connect(_on_layer_focus_changed)
		turn_layer_environment.turn_advanced.connect(_on_turn_advanced)
	
	# Connect turn system signals
	if turn_system_controller:
		turn_system_controller.turn_changed.connect(_on_turn_changed)
	
	print("🎮 12 Turns Main Controller initialized")
	print("🎬 Press N to toggle layer view | Space to advance turn")

func initialize_all() -> void:
	print("Initializing all components...")
	
	# Attempt to find existing systems first
	_find_existing_systems()
	
	# Create any missing systems
	_create_missing_systems()
	
	# Connect signals
	_connect_signals()
	
	# Initialize default settings
	_initialize_default_settings()
	
	emit_signal("initialization_completed")
	
	print("All components initialized")

func _find_existing_systems():
	# Find existing screen capture system
	screen_capture = get_node_or_null("/root/ScreenCaptureUtility")
	if not screen_capture:
		screen_capture = _find_node_by_class(get_tree().root, "ScreenCaptureUtility")
	
	# Find existing OCR processor
	ocr_processor = get_node_or_null("/root/OCRProcessor")
	if not ocr_processor:
		ocr_processor = _find_node_by_class(get_tree().root, "OCRProcessor")
	
	# Find existing offline OCR processor
	offline_ocr = get_node_or_null("/root/OfflineOCRProcessor")
	if not offline_ocr:
		offline_ocr = _find_node_by_class(get_tree().root, "OfflineOCRProcessor")
	
	# Find existing auto updater
	auto_updater = get_node_or_null("/root/AutoUpdater")
	if not auto_updater:
		auto_updater = _find_node_by_class(get_tree().root, "AutoUpdater")
	
	# Find existing auto connector
	auto_connector = get_node_or_null("/root/AutoConnector")
	if not auto_connector:
		auto_connector = _find_node_by_class(get_tree().root, "AutoConnector")
	
	# Find existing color theme system
	color_theme_system = get_node_or_null("/root/ExtendedColorThemeSystem")
	if not color_theme_system:
		color_theme_system = _find_node_by_class(get_tree().root, "ExtendedColorThemeSystem")
	
	# If not found, try other color systems
	if not color_theme_system:
		color_theme_system = get_node_or_null("/root/DimensionalColorSystem")
		if not color_theme_system:
			color_theme_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
	
	# Find existing task animator
	task_animator = get_node_or_null("/root/TaskTransitionAnimator")
	if not task_animator:
		task_animator = _find_node_by_class(get_tree().root, "TaskTransitionAnimator")

func _find_node_by_class(node, class_name_str):
	if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
		return node
	
	for child in node.get_children():
		var found = _find_node_by_class(child, class_name_str)
		if found:
			return found
	
	return null

func _create_missing_systems():
	# Create screen capture if missing
	if not screen_capture:
		screen_capture = ScreenCaptureUtility.new()
		add_child(screen_capture)
		print("Created ScreenCaptureUtility")
		emit_signal("component_initialized", "ScreenCaptureUtility")
	
	# Create OCR processor if missing
	if not ocr_processor:
		ocr_processor = OCRProcessor.new()
		add_child(ocr_processor)
		print("Created OCRProcessor")
		emit_signal("component_initialized", "OCRProcessor")
	
	# Create offline OCR processor if missing
	if not offline_ocr:
		offline_ocr = OfflineOCRProcessor.new()
		add_child(offline_ocr)
		print("Created OfflineOCRProcessor")
		emit_signal("component_initialized", "OfflineOCRProcessor")
	
	# Create auto updater if missing
	if not auto_updater:
		auto_updater = AutoUpdater.new()
		add_child(auto_updater)
		print("Created AutoUpdater")
		emit_signal("component_initialized", "AutoUpdater")
	
	# Create auto connector if missing
	if not auto_connector:
		auto_connector = AutoConnector.new()
		add_child(auto_connector)
		print("Created AutoConnector")
		emit_signal("component_initialized", "AutoConnector")
	
	# Create color theme system if missing
	if not color_theme_system:
		color_theme_system = ExtendedColorThemeSystem.new()
		add_child(color_theme_system)
		print("Created ExtendedColorThemeSystem")
		emit_signal("component_initialized", "ExtendedColorThemeSystem")
	
	# Create task animator if missing
	if not task_animator:
		task_animator = TaskTransitionAnimator.new()
		add_child(task_animator)
		print("Created TaskTransitionAnimator")
		emit_signal("component_initialized", "TaskTransitionAnimator")

func _connect_signals():
	# Connect screen capture signals
	if screen_capture:
		screen_capture.connect("capture_completed", Callable(self, "_on_capture_completed"))
		screen_capture.connect("capture_failed", Callable(self, "_on_capture_failed"))
	
	# Connect OCR processor signals
	if ocr_processor:
		ocr_processor.connect("processing_completed", Callable(self, "_on_ocr_completed"))
		ocr_processor.connect("processing_failed", Callable(self, "_on_ocr_failed"))
	
	# Connect offline OCR processor signals
	if offline_ocr:
		offline_ocr.connect("processing_completed", Callable(self, "_on_offline_ocr_completed"))
		offline_ocr.connect("processing_failed", Callable(self, "_on_offline_ocr_failed"))
	
	# Connect auto updater signals
	if auto_updater:
		auto_updater.connect("update_available", Callable(self, "_on_update_available"))
		auto_updater.connect("update_check_failed", Callable(self, "_on_update_check_failed"))
	
	# Connect auto connector signals
	if auto_connector:
		auto_connector.connect("connection_status_changed", Callable(self, "_on_connection_status_changed"))
		auto_connector.connect("all_connections_established", Callable(self, "_on_all_connections_established"))
	
	# Connect color theme system signals
	if color_theme_system:
		color_theme_system.connect("theme_changed", Callable(self, "_on_theme_changed"))
	
	# Connect task animator signals
	if task_animator:
		task_animator.connect("transition_completed", Callable(self, "_on_transition_completed"))

func _initialize_default_settings():
	# Initialize default settings for each system
	
	# Screen capture settings
	if screen_capture:
		screen_capture.default_capture_method = "native"
		screen_capture.capture_format = "png"
	
	# OCR processor settings
	if ocr_processor:
		# No special settings needed
		pass
	
	# Offline OCR processor settings
	if offline_ocr:
		# No special settings needed
		pass
	
	# Auto updater settings
	if auto_updater:
		auto_updater.auto_download_updates = enable_auto_updates
	
	# Auto connector settings
	if auto_connector:
		auto_connector.auto_connect_on_startup = enable_auto_connection
	
	# Color theme system settings
	if color_theme_system:
		color_theme_system.apply_theme(default_theme, false)
	
	# Task animator settings
	if task_animator:
		task_animator.enabled = enable_animations

# ----- EVENT HANDLERS -----
func _on_capture_completed(capture_id, image_path):
	print("Capture completed: " + image_path)
	emit_signal("capture_completed", image_path)
	
	# Automatically perform OCR if both systems are available
	if ocr_processor and screen_capture:
		ocr_processor.process_image(image_path)

func _on_capture_failed(capture_id, error):
	print("Capture failed: " + error)
	
	if debug_mode:
		print_debug("Capture failure details: ID=" + capture_id + ", Error=" + error)

func _on_ocr_completed(image_id, results):
	print("OCR completed for image: " + image_id)
	emit_signal("ocr_completed", results.text)
	
	# Log OCR results for debugging
	if debug_mode:
		print_debug("OCR results: " + results.text.substr(0, 100) + "...")
		print_debug("OCR confidence: " + str(results.confidence))

func _on_ocr_failed(image_id, error):
	print("OCR failed for image: " + image_id)
	print("Error: " + error)
	
	# Try offline OCR as fallback
	if offline_ocr:
		print("Trying offline OCR as fallback...")
		offline_ocr.process_image(screen_capture.get_last_capture_path())

func _on_offline_ocr_completed(image_id, results):
	print("Offline OCR completed for image: " + image_id)
	emit_signal("ocr_completed", results.text)

func _on_offline_ocr_failed(image_id, error):
	print("Offline OCR failed for image: " + image_id)
	print("Error: " + error)

func _on_update_available(version, release_notes):
	print("Update available: " + version)
	print("Release notes: " + release_notes)
	
	# Auto-download if enabled
	if enable_auto_updates and auto_updater:
		auto_updater.download_update()

func _on_update_check_failed(error):
	print("Update check failed: " + error)

func _on_connection_status_changed(type, status):
	print("Connection status changed: " + type + " -> " + status)
	emit_signal("connection_status_changed", type + ":" + status)

func _on_all_connections_established():
	print("All connections established")

func _on_theme_changed(theme_name):
	print("Theme changed to: " + theme_name)
	emit_signal("theme_changed", theme_name)

func _on_transition_completed(id, type, task):
	print("Transition completed: " + str(id) + " to task " + task)

# ----- PUBLIC API -----
func capture_screen() -> void:
	if screen_capture:
		screen_capture.capture_screen()
	else:
		print("Screen capture utility not available")

func perform_ocr(image_path: String) -> void:
	if ocr_processor:
		ocr_processor.process_image(image_path)
	else:
		print("OCR processor not available")

func capture_and_ocr() -> void:
	if screen_capture and ocr_processor:
		var capture_id = screen_capture.capture_screen()
		# OCR will be triggered by capture_completed signal
	else:
		print("Screen capture or OCR processor not available")

func change_theme(theme_name: String) -> void:
	if color_theme_system:
		color_theme_system.apply_theme(theme_name)
	else:
		print("Color theme system not available")

func check_for_updates() -> void:
	if auto_updater:
		auto_updater.check_for_updates()
	else:
		print("Auto updater not available")

func connect_services() -> void:
	if auto_connector:
		auto_connector.connect_all()
	else:
		print("Auto connector not available")

func get_system_status() -> Dictionary:
	var status = {
		"screen_capture": screen_capture != null,
		"ocr_processor": ocr_processor != null,
		"offline_ocr": offline_ocr != null,
		"auto_updater": auto_updater != null,
		"auto_connector": auto_connector != null,
		"color_theme_system": color_theme_system != null,
		"task_animator": task_animator != null,
		"current_theme": color_theme_system.current_theme if color_theme_system else "unknown",
		"animations_enabled": task_animator.enabled if task_animator else false,
		"auto_updates_enabled": auto_updater.auto_download_updates if auto_updater else false,
		"auto_connection_enabled": auto_connector.auto_connect_on_startup if auto_connector else false,
	}
	
	return status

# ----- PROCESS -----
func _process(delta: float) -> void:
	# Update FPS counter
	fps_timer += delta
	if fps_timer >= 1.0:
		fps_timer = 0.0
		_update_debug_info()

# ----- INPUT HANDLING -----
func _input(event):
	# Handle keyboard shortcuts
	if event is InputEventKey and event.pressed:
		# Toggle layer view (N key)
		if event.keycode == KEY_N:
			toggle_layer_view()
		
		# Advance turn (Space key)
		elif event.keycode == KEY_SPACE:
			advance_turn()
		
		# Focus next layer (Tab key)
		elif event.keycode == KEY_TAB:
			focus_next_layer()
		
		# Auto-frame view (F key)
		elif event.keycode == KEY_F:
			auto_frame_view()
		
		# Check for capture hotkey (Ctrl+Shift+P)
		elif event.ctrl_pressed and event.shift_pressed and event.keycode == KEY_P:
			capture_screen()
		
		# Check for OCR hotkey (Ctrl+Shift+O)
		elif event.ctrl_pressed and event.shift_pressed and event.keycode == KEY_O:
			if screen_capture:
				var last_capture = screen_capture.get_last_capture_path()
				if last_capture:
					perform_ocr(last_capture)
				else:
					print("No recent capture available for OCR")
			else:
				print("Screen capture utility not available")
# ----- LAYER CONTROL FUNCTIONS -----
## Toggle visibility of layer environment
# INPUT: None
# PROCESS: Shows/hides the 5-layer system
# OUTPUT: None
# CHANGES: Layer visibility
# CONNECTION: Controls turn_layer_environment
func toggle_layer_view() -> void:
	if turn_layer_environment:
		turn_layer_environment.toggle_visibility()
		layers_visible = \!layers_visible
		print("🎬 Layers %s" % ("visible" if layers_visible else "hidden"))

## Advance to next turn
# INPUT: None
# PROCESS: Progresses turn system
# OUTPUT: None
# CHANGES: Current turn
# CONNECTION: Updates all turn displays
func advance_turn() -> void:
	if turn_layer_environment:
		turn_layer_environment.advance_turn()
	if turn_system_controller:
		turn_system_controller.advance_turn()

## Focus on next layer
# INPUT: None
# PROCESS: Cycles through layers
# OUTPUT: None
# CHANGES: Camera focus
# CONNECTION: Camera control
func focus_next_layer() -> void:
	current_focus_layer = (current_focus_layer + 1) % 5
	if turn_layer_environment:
		turn_layer_environment.focus_on_layer(current_focus_layer)

## Auto-frame current view
# INPUT: None
# PROCESS: Optimizes camera position
# OUTPUT: None
# CHANGES: Camera transform
# CONNECTION: Camera positioning
func auto_frame_view() -> void:
	if camera and turn_layer_environment:
		var target_pos = Vector3(0, 0, -40)
		camera.position = target_pos
		camera.look_at(Vector3.ZERO, Vector3.UP)
		print("📸 Camera auto-framed")

# ----- SIGNAL HANDLERS -----
func _on_layer_focus_changed(layer_index: int) -> void:
	current_focus_layer = layer_index
	print("📍 Focused on layer %d" % layer_index)

func _on_turn_advanced(new_turn: int) -> void:
	print("🔄 Turn advanced to %d" % new_turn)
	_update_ui()

func _on_turn_changed(turn_data: Dictionary) -> void:
	print("📊 Turn system updated: %s" % turn_data)
	_update_ui()

# ----- UI UPDATES -----
func _update_ui() -> void:
	if not ui_panel:
		return
	
	var info_label = ui_panel.get_node_or_null("TurnInfo")
	if info_label and info_label is RichTextLabel:
		var current_turn = turn_layer_environment.current_turn if turn_layer_environment else 5
		var current_dim = turn_layer_environment.current_dimension if turn_layer_environment else 4
		
		info_label.clear()
		info_label.append_text("[b]12 TURNS SYSTEM[/b]\n\n")
		info_label.append_text("Current Turn: %d\n" % current_turn)
		info_label.append_text("Phase: %s\n" % _get_turn_name(current_turn))
		info_label.append_text("Dimension: %dD\n\n" % (current_dim + 1))
		info_label.append_text("[color=cyan]Controls:[/color]\n")
		info_label.append_text("N - Toggle layer view\n")
		info_label.append_text("Space - Advance turn\n")
		info_label.append_text("Tab - Focus next layer\n")
		info_label.append_text("F - Auto-frame view")

func _update_debug_info() -> void:
	if debug_label:
		var fps = Engine.get_frames_per_second()
		var thread_info = _get_thread_info()
		var word_count = _get_word_count()
		
		debug_label.text = "FPS: %d\nThreads: %s\nWords: %d" % [fps, thread_info, word_count]

func _get_thread_info() -> String:
	var thread_manager = get_node_or_null("/root/ThreadManager")
	if thread_manager:
		var stats = thread_manager.get_statistics()
		return "%d/%d" % [stats.available_threads, stats.thread_count]
	return "0/0"

func _get_word_count() -> int:
	# Could count actual word entities in the scene
	return 0

func _get_turn_name(turn: int) -> String:
	var turn_names = [
		"Genesis", "Formation", "Complexity", "Consciousness",
		"Awakening", "Enlightenment", "Manifestation", "Connection",
		"Harmony", "Transcendence", "Unity", "Beyond"
	]
	if turn > 0 and turn <= turn_names.size():
		return turn_names[turn - 1]
	return "Unknown"
