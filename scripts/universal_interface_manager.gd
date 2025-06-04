# ==================================================
# SCRIPT NAME: universal_interface_manager.gd
# DESCRIPTION: Normalized interface system - all windows follow the same rules
# PURPOSE: Moveable windows, ESC closing, click selection - the obvious basics
# CREATED: 2025-06-04 - Interface Normalization
# AUTHOR: JSH + Claude Code + Captain Claude
# ==================================================

extends Node
class_name UniversalInterfaceManager

# ===== INTERFACE CONSTANTS =====
const WINDOW_LAYERS = {
	"background": 0,
	"game_ui": 50,
	"console": 95,
	"inspector": 100,
	"cursor": 105,  # Always on top
	"modal": 110    # Critical dialogs only
}

const INTERFACE_THEMES = {
	"default": {
		"bg_color": Color(0.1, 0.1, 0.15, 0.9),
		"border_color": Color(0.3, 0.3, 0.4),
		"text_color": Color(0.9, 0.9, 0.9),
		"accent_color": Color(0.2, 0.6, 1.0)
	},
	"console": {
		"bg_color": Color(0.05, 0.05, 0.1, 0.95),
		"border_color": Color(0.2, 0.2, 0.3),
		"text_color": Color(0.9, 0.9, 0.9),
		"accent_color": Color(0.0, 1.0, 0.5)
	},
	"inspector": {
		"bg_color": Color(0.15, 0.1, 0.1, 0.9),
		"border_color": Color(0.4, 0.3, 0.3),
		"text_color": Color(0.9, 0.9, 0.9),
		"accent_color": Color(1.0, 0.6, 0.2)
	}
}

# ===== INTERFACE REGISTRY =====
static var instance: UniversalInterfaceManager
var registered_windows: Dictionary = {}
var active_window: Window = null
var dragging_window: Window = null
var drag_offset: Vector2

# ===== INITIALIZATION =====
func _ready() -> void:
	instance = self
	set_process_input(true)
	print("🎯 Universal Interface Manager initialized - All interfaces normalized!")

# ===== UNIVERSAL WINDOW CREATION =====
func create_normalized_window(config: Dictionary) -> Window:
	"""Create a window that follows Universal Interface standards"""
	var window = Window.new()
	
	# Apply configuration
	window.title = config.get("title", "Universal Window")
	window.size = config.get("size", Vector2(400, 300))
	window.position = config.get("position", Vector2(100, 100))
	
	# Apply theme
	var theme_name = config.get("theme", "default")
	apply_theme(window, theme_name)
	
	# Set layer priority
	var layer = config.get("layer", "game_ui")
	set_window_layer(window, layer)
	
	# Add universal behaviors
	setup_universal_behaviors(window, config)
	
	# Register window
	var window_id = config.get("id", "window_" + str(Time.get_ticks_msec()))
	registered_windows[window_id] = window
	
	print("🎯 Created normalized window: %s (layer: %s)" % [window.title, layer])
	return window

func apply_theme(window: Window, theme_name: String) -> void:
	"""Apply visual theme to window"""
	if not INTERFACE_THEMES.has(theme_name):
		theme_name = "default"
	
	var theme = INTERFACE_THEMES[theme_name]
	
	# Apply theme colors (this is a simplified version)
	# In a full implementation, you'd set up proper theme resources
	window.set_meta("theme_config", theme)

func set_window_layer(window: Window, layer_name: String) -> void:
	"""Set window layer priority"""
	var layer_value = WINDOW_LAYERS.get(layer_name, WINDOW_LAYERS.game_ui)
	
	# Note: In Godot 4, Window doesn't have a direct layer property
	# We use a workaround with z-order and metadata
	window.set_meta("layer_priority", layer_value)
	window.set_meta("layer_name", layer_name)

func setup_universal_behaviors(window: Window, config: Dictionary) -> void:
	"""Add universal behaviors to window"""
	
	# ESC key closing (if enabled)
	if config.get("esc_closes", true):
		enable_esc_closing(window)
	
	# Moveable behavior (if enabled)
	if config.get("moveable", true):
		enable_window_dragging(window)
	
	# Click to focus behavior
	enable_click_focus(window)
	
	# Close button behavior
	window.close_requested.connect(_on_window_close_requested.bind(window))

# ===== UNIVERSAL BEHAVIORS =====
func enable_esc_closing(window: Window) -> void:
	"""Enable ESC key to close window"""
	window.set_meta("esc_closes", true)

func enable_window_dragging(window: Window) -> void:
	"""Enable window dragging"""
	window.set_meta("draggable", true)

func enable_click_focus(window: Window) -> void:
	"""Enable click to focus window"""
	window.set_meta("click_focus", true)

# ===== INPUT HANDLING =====
func _input(event: InputEvent) -> void:
	# Global ESC key handling
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		handle_esc_pressed()
	
	# Global window dragging
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_window_drag(event.global_position)
			else:
				stop_window_drag()
	
	elif event is InputEventMouseMotion and dragging_window:
		drag_window(event.global_position)

func handle_esc_pressed() -> void:
	"""Handle ESC key press - close topmost window that supports it"""
	var topmost_window = find_topmost_escapable_window()
	if topmost_window:
		close_window(topmost_window)

func find_topmost_escapable_window() -> Window:
	"""Find the topmost window that can be closed with ESC"""
	var highest_priority = -1
	var topmost_window = null
	
	for window in registered_windows.values():
		if window.visible and window.get_meta("esc_closes", false):
			var priority = window.get_meta("layer_priority", 0)
			if priority > highest_priority:
				highest_priority = priority
				topmost_window = window
	
	return topmost_window

func start_window_drag(mouse_pos: Vector2) -> void:
	"""Start dragging window under cursor"""
	var window = find_window_under_cursor(mouse_pos)
	if window and window.get_meta("draggable", false):
		dragging_window = window
		drag_offset = mouse_pos - window.position
		focus_window(window)

func drag_window(mouse_pos: Vector2) -> void:
	"""Update window position during drag"""
	if dragging_window:
		dragging_window.position = mouse_pos - drag_offset

func stop_window_drag() -> void:
	"""Stop window dragging"""
	dragging_window = null

func find_window_under_cursor(mouse_pos: Vector2) -> Window:
	"""Find which registered window is under the cursor"""
	var highest_priority = -1
	var topmost_window = null
	
	for window in registered_windows.values():
		if window.visible and _is_point_in_window(window, mouse_pos):
			var priority = window.get_meta("layer_priority", 0)
			if priority > highest_priority:
				highest_priority = priority
				topmost_window = window
	
	return topmost_window

func _is_point_in_window(window: Window, point: Vector2) -> bool:
	"""Check if point is inside window bounds"""
	var rect = Rect2(window.position, window.size)
	return rect.has_point(point)

# ===== WINDOW MANAGEMENT =====
func focus_window(window: Window) -> void:
	"""Bring window to front"""
	if active_window != window:
		active_window = window
		# Move to front in scene tree for visual priority
		if window.get_parent():
			window.get_parent().move_child(window, -1)

func close_window(window: Window) -> void:
	"""Close a window properly"""
	if window.visible:
		window.visible = false
		if active_window == window:
			active_window = null
		print("🎯 Window closed: %s" % window.title)

func _on_window_close_requested(window: Window) -> void:
	"""Handle window close button"""
	close_window(window)

# ===== UTILITY METHODS =====
func get_registered_window(window_id: String) -> Window:
	"""Get registered window by ID"""
	return registered_windows.get(window_id, null)

func register_existing_window(window: Window, window_id: String, config: Dictionary = {}) -> void:
	"""Register an existing window with the manager"""
	registered_windows[window_id] = window
	
	# Apply universal behaviors to existing window
	setup_universal_behaviors(window, config)
	
	print("🎯 Registered existing window: %s" % window.title)

func get_interface_status() -> Dictionary:
	"""Get status of all registered interfaces"""
	var status = {}
	for id in registered_windows:
		var window = registered_windows[id]
		status[id] = {
			"visible": window.visible,
			"title": window.title,
			"layer": window.get_meta("layer_name", "unknown"),
			"position": window.position,
			"size": window.size
		}
	return status

# ===== STATIC ACCESS =====
static func get_instance() -> UniversalInterfaceManager:
	"""Get singleton instance"""
	return instance

static func create_universal_window(config: Dictionary) -> Window:
	"""Static method to create normalized window"""
	if instance:
		return instance.create_normalized_window(config)
	else:
		push_error("UniversalInterfaceManager not initialized!")
		return null