# 🏛️ Text Screen - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
class_name JSHTextWindow

# ===== CONFIGURABLE PROPERTIES =====
@export var window_width := 4.0
@export var window_height := 3.0
@export var text_margin := 0.1
@export var max_visible_lines := 10
@export var font_size := 24
@export var text_color := Color(0.9, 0.9, 0.9, 1.0)
@export var background_color := Color(0.1, 0.1, 0.15, 0.8)
@export var border_color := Color(0.3, 0.5, 0.8, 1.0)
@export var border_width := 0.05
@export var command_prefix := "/"

# ===== CONSTANTS =====
const DEFAULT_WIDTH = 2.0
const DEFAULT_HEIGHT = 1.5
const MARGIN = 0.05
const FADE_TIME = 0.5
const MAX_MESSAGES = 50

# ===== INTERNAL REFERENCES =====
var window_mesh: MeshInstance3D
var background_mesh: MeshInstance3D
var title_bar: MeshInstance3D
var title_label: Label3D
var text_label: Label3D
var input_line: Label3D
var cursor: MeshInstance3D
var cursor_timer: Timer
var command_processor: CommandProcessor
var text_container: Node3D
var content_label: Label3D
var content_text: TextMesh
var scroll_up_button: Node3D
var scroll_down_button: Node3D
var close_button: Node3D
var minimize_button: Node3D
var message_container: Node3D
var input_field: Node3D

# ===== INTERNAL STATE =====
var text_buffer := []
var input_text := ""
var cursor_position := 0
var cursor_visible := true
var is_focused := false
var command_history := []
var command_history_index := -1
var window_title = "JSH Text Viewer"
var window_color = 0.4  # Color index for get_spectrum_color
var window_opacity = 0.8
var is_minimized = false
var can_be_dragged = true
var can_be_edited = false
var supports_links = true
var auto_scroll = true
var full_text = ""
var formatted_text = []
var scroll_offset = 0
var is_dragging = false
var drag_start_position = Vector3.ZERO
var window_initial_position = Vector3.ZERO
var visible_lines = 0
var total_lines = 0
var links = {}
var lines = []
var cursor_blink_time = 0.0
var current_input

# ===== INTEGRATION REFERENCES =====
var main_scene_reference = null
var task_manager = null
var csharp_integration = null

## ===== CONFIGURABLE PROPERTIES =====
#@export var window_width := 4.0
#@export var window_height := 3.0
#@export var text_margin := 0.1
#@export var max_visible_lines := 10
#@export var font_size := 24
#@export var text_color := Color(0.9, 0.9, 0.9, 1.0)
#@export var background_color := Color(0.1, 0.1, 0.15, 0.8)
#@export var border_color := Color(0.3, 0.5, 0.8, 1.0)
#@export var border_width := 0.05
#@export var command_prefix := "/"
#
## ===== CONSTANTS =====
#const DEFAULT_WIDTH = 2.0
#const DEFAULT_HEIGHT = 1.5
#const MARGIN = 0.05
#const FADE_TIME = 0.5
#const MAX_MESSAGES = 50
#
## ===== INTERNAL REFERENCES =====
#var window_mesh: MeshInstance3D
#var background_mesh: MeshInstance3D
#var title_bar: MeshInstance3D
#var title_label: Label3D
#var text_label: Label3D
#var input_line: Label3D
#var cursor: MeshInstance3D
#var cursor_timer: Timer
#var text_container: Node3D
#var content_label: Label3D
#var scroll_up_button: Node3D
#var scroll_down_button: Node3D
#var close_button: Node3D
#var minimize_button: Node3D
#
## ===== INTERNAL STATE =====
#var text_buffer := []
#var input_text := ""
#var cursor_position := 0
#var cursor_visible := true
#var is_focused := false
#var command_history := []
#var command_history_index := -1
#var window_title = "JSH Snake Game"
#var window_color = 0.4  # Color index for get_spectrum_color
#var window_opacity = 0.8
#var is_minimized = false
#var can_be_dragged = true
#var supports_links = true
#var auto_scroll = true
#var full_text = ""
#var scroll_offset = 0
#var is_dragging = false
#var drag_start_position = Vector3.ZERO
#var window_initial_position = Vector3.ZERO
#var visible_lines = 0
#var total_lines = 0
#var links = {}
#var cursor_blink_time = 0.0
#
## ===== INTEGRATION REFERENCES =====
#var main_scene_reference = null
#var task_manager = null

# ===== SIGNALS =====
signal window_closed
signal window_focused
signal window_unfocused
signal window_resized(new_size)
signal text_updated(new_text)
# TODO: Unused signals - consider implementing or removing
# signal link_clicked(link_id)
signal command_executed(command: String, args: Array)
signal text_submitted(text: String)
# signal game_started
# signal game_restarted
# signal game_paused
# signal game_resumed
# signal high_score_viewed

# ===== COMMAND PROCESSOR CLASS =====
class CommandProcessor:
	extends UniversalBeingBase
	var commands = {}
	

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
	func register_command(command_name: String, callback: Callable):
		commands[command_name.to_lower()] = callback
	
	func unregister_command(command_name: String):
		if commands.has(command_name.to_lower()):
			commands.erase(command_name.to_lower())
	
	func execute_command(command_name: String, _args: Array) -> Dictionary:
		var cmd_name = command_name.to_lower()
		
		if not commands.has(cmd_name):
			return {"success": false, "message": "Unknown command: " + command_name}
		
		var _callback = commands[cmd_name]
		
		# Execute the command and return result
		var result = {"success": true, "message": "Command executed"}
		return result
		#try:
			#result = callback.call(args)
			## If the command returns nothing, assume success
			#if result == null:
				#return {"success": true, "message": "Command executed successfully"}
			#
			## If the command returns a dictionary with success/message, use that
			#if result is Dictionary and result.has("success"):
				#return result
				#
			## Otherwise wrap the result
			#return {"success": true, "message": str(result)}
		#except:
			#return {"success": false, "message": "Error executing command"}
#
#
## ===== SIGNALS =====
#signal window_closed
#signal window_focused
#signal window_unfocused
#signal window_resized(new_size)
#signal text_updated(new_text)
#signal link_clicked(link_id)
#signal command_executed(command: String, args: Array)
#signal text_submitted(text: String)
signal message_sent(message, sender)

## ===== COMMAND PROCESSOR CLASS =====
#class CommandProcessor:
	#extends UniversalBeingBase
	#
	#var commands = {}
	#
	#func register_command(name: String, callback: Callable):
		#commands[name.to_lower()] = callback
	#
	#func unregister_command(name: String):
		#if commands.has(name.to_lower()):
			#commands.erase(name.to_lower())


# ===== INITIALIZATION =====
func _ready():
	_setup_components()
	_update_display()
	_setup_signals()
	
	# Find integration node or task manager
	find_integration_nodes()
	
	# Send initial signal
	emit_signal("window_focused")
#
 #===== INPUT HANDLING =====
func _process(delta):
	if is_focused:
		_update_cursor_position()
	
	# Update cursor blink
	if is_focused:
		cursor_blink_time += delta
		if cursor_blink_time >= 1.0:
			cursor_blink_time = 0.0
			cursor_visible = !cursor_visible
		cursor.visible = cursor_visible
		
	# Handle window dragging
	if is_dragging:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var current_mouse_pos = get_viewport().get_mouse_position()
			var camera = get_viewport().get_camera_3d()
			
			if camera:
				var ray_origin = camera.project_ray_origin(current_mouse_pos)
				var ray_dir = camera.project_ray_normal(current_mouse_pos)
				
				var plane = Plane(Vector3(0, 0, 1), window_initial_position.z)
				var intersection = plane.intersects_ray(ray_origin, ray_dir)
				
				if intersection:
					var offset = intersection - drag_start_position
					global_position = window_initial_position + offset
		else:
			is_dragging = false

func _input(event):
	if not is_focused:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				unfocus()
			KEY_BACKSPACE:
				if cursor_position > 0:
					input_text = input_text.substr(0, cursor_position - 1) + input_text.substr(cursor_position)
					cursor_position -= 1
					_update_display()
			KEY_DELETE:
				if cursor_position < input_text.length():
					input_text = input_text.substr(0, cursor_position) + input_text.substr(cursor_position + 1)
					_update_display()
			KEY_LEFT:
				if cursor_position > 0:
					cursor_position -= 1
			KEY_RIGHT:
				if cursor_position < input_text.length():
					cursor_position += 1
			KEY_HOME:
				cursor_position = 0
			KEY_END:
				cursor_position = input_text.length()
			KEY_UP:
				_navigate_command_history(true)
			KEY_DOWN:
				_navigate_command_history(false)
			KEY_ENTER, KEY_KP_ENTER:
				_submit_text()
			_:
				# Handle regular character input
				if event.unicode != 0 and event.unicode < 128:
					var char = char(event.unicode)
					input_text = input_text.substr(0, cursor_position) + char + input_text.substr(cursor_position)
					cursor_position += 1
					_update_display()
	
	# Handle mouse wheel for scrolling
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_messages_up()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_messages_down()

# ===== INITIALIZATION =====
func _ready_0():
	setup_window()
	setup_signals()
	
	# Find integration node or task manager
	find_integration_nodes()
	
	# Register default commands
	register_default_commands()
	
	# Set initial text
	set_text("Welcome to JSH Snake Game!\n\nUse /help for available commands.")
	
	# Send initial signal
	emit_signal("window_focused")

# ===== INPUT HANDLING =====
func _process_0(delta):
	if is_focused:
		_update_cursor_position()
	
	# Update cursor blink
	if is_focused:
		cursor_blink_time += delta
		if cursor_blink_time >= 1.0:
			cursor_blink_time = 0.0
			cursor_visible = !cursor_visible
		cursor.visible = cursor_visible
		
	# Handle window dragging
	if is_dragging:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var current_mouse_pos = get_viewport().get_mouse_position()
			var camera = get_viewport().get_camera_3d()
			
			if camera:
				var ray_origin = camera.project_ray_origin(current_mouse_pos)
				var ray_dir = camera.project_ray_normal(current_mouse_pos)
				
				var plane = Plane(Vector3(0, 0, 1), window_initial_position.z)
				var intersection = plane.intersects_ray(ray_origin, ray_dir)
				
				if intersection:
					var offset = intersection - drag_start_position
					global_position = window_initial_position + offset
		else:
			is_dragging = false

func _input_0(event):
	if not is_focused:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				unfocus()
			KEY_BACKSPACE:
				if cursor_position > 0:
					input_text = input_text.substr(0, cursor_position - 1) + input_text.substr(cursor_position)
					cursor_position -= 1
					_update_display()
			KEY_DELETE:
				if cursor_position < input_text.length():
					input_text = input_text.substr(0, cursor_position) + input_text.substr(cursor_position + 1)
					_update_display()
			KEY_LEFT:
				if cursor_position > 0:
					cursor_position -= 1
			KEY_RIGHT:
				if cursor_position < input_text.length():
					cursor_position += 1
			KEY_HOME:
				cursor_position = 0
			KEY_END:
				cursor_position = input_text.length()
			KEY_UP:
				_navigate_command_history(true)
			KEY_DOWN:
				_navigate_command_history(false)
			KEY_ENTER, KEY_KP_ENTER:
				_submit_text()
			_:
				# Handle regular character input
				if event.unicode != 0 and event.unicode < 128:
					var char = char(event.unicode)
					input_text = input_text.substr(0, cursor_position) + char + input_text.substr(cursor_position)
					cursor_position += 1
					_update_display()
	
	# Handle mouse wheel for scrolling
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_messages_up()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_messages_down()




















func _setup_components():
	# Create window background
	window_mesh = MeshInstance3D.new()
	var window_material = MaterialLibrary.get_material("default")
	window_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	window_material.albedo_color = background_color
	
	var window_shape = BoxMesh.new()
	window_shape.size = Vector3(window_width, window_height, 0.01)
	window_mesh.mesh = window_shape
	window_mesh.material_override = window_material
	add_child(window_mesh)
	
	# Create border (using multiple quads for simplicity)
	_create_border()
	
	# Create text display
	text_label = Label3D.new()
	text_label.text = ""
	text_label.font_size = font_size
	text_label.modulate = text_color
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	text_label.width = window_width - (text_margin * 2)
	text_label.position = Vector3(-window_width/2 + text_margin, window_height/2 - text_margin, 0.011)
	add_child(text_label)
	
	# Create input line
	input_line = Label3D.new()
	input_line.text = ""
	input_line.font_size = font_size
	input_line.modulate = text_color
	input_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	input_line.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	input_line.width = window_width - (text_margin * 2)
	input_line.position = Vector3(-window_width/2 + text_margin, -window_height/2 + text_margin, 0.011)
	add_child(input_line)
	
	# Create cursor
	cursor = MeshInstance3D.new()
	var cursor_mesh = BoxMesh.new()
	cursor_mesh.size = Vector3(0.05, 0.05, 0.01)
	cursor.mesh = cursor_mesh
	cursor.material_override = window_material.duplicate()
	cursor.material_override.albedo_color = text_color
	cursor.position = Vector3(-window_width/2 + text_margin, -window_height/2 + text_margin, 0.012)
	add_child(cursor)
	
	# Setup cursor blinking timer
	cursor_timer = TimerManager.get_timer()
	cursor_timer.wait_time = 0.5
	cursor_timer.autostart = true
	add_child(cursor_timer)
	
	# Initialize command processor
	command_processor = CommandProcessor.new()
	add_child(command_processor)
	
	# Set up control buttons
	create_control_buttons()
	
	# Create text container for more complex text display
	create_text_area()

func _create_border():
	# Top border
	var top_border = MeshInstance3D.new()
	var top_mesh = BoxMesh.new()
	top_mesh.size = Vector3(window_width, border_width, 0.015)
	top_border.mesh = top_mesh
	top_border.position = Vector3(0, window_height/2, 0.005)
	
	# Bottom border
	var bottom_border = MeshInstance3D.new()
	var bottom_mesh = BoxMesh.new()
	bottom_mesh.size = Vector3(window_width, border_width, 0.015)
	bottom_border.mesh = bottom_mesh
	bottom_border.position = Vector3(0, -window_height/2, 0.005)
	
	# Left border
	var left_border = MeshInstance3D.new()
	var left_mesh = BoxMesh.new()
	left_mesh.size = Vector3(border_width, window_height, 0.015)
	left_border.mesh = left_mesh
	left_border.position = Vector3(-window_width/2, 0, 0.005)
	
	# Right border
	var right_border = MeshInstance3D.new()
	var right_mesh = BoxMesh.new()
	right_mesh.size = Vector3(border_width, window_height, 0.015)
	right_border.mesh = right_mesh
	right_border.position = Vector3(window_width/2, 0, 0.005)
	
	# Create border material
	var border_material = MaterialLibrary.get_material("default")
	border_material.albedo_color = border_color
	
	# Apply material and add borders
	top_border.material_override = border_material
	bottom_border.material_override = border_material
	left_border.material_override = border_material
	right_border.material_override = border_material
	
	add_child(top_border)
	add_child(bottom_border)
	add_child(left_border)
	add_child(right_border)

func _setup_signals():
	cursor_timer.timeout.connect(_on_cursor_timer_timeout)

func find_integration_nodes():
	# Try to find C# integration node
	csharp_integration = get_node_or_null("/root/JSHSystemIntegration")
	
	# Find task manager if not already set
	if not task_manager:
		task_manager = get_node_or_null("/root/JSHTaskManager")
		if task_manager and task_manager.has_method("track_data_flow"):
			task_manager.track_data_flow(
				"TextWindow", 
				window_title, 
				"window_opened", 
				1.0
			)
#
##
#
#
#
#
#
#
#
#
#
#
#extends UniversalBeingBase
#class_name JSHTextWindow













func setup_window():
	# Create window background
	create_window_background()
	
	# Create title bar
	create_title_bar()
	
	# Create text display area
	create_text_area()
	
	# Create control buttons
	create_control_buttons()
	
	# Create input line
	create_input_line()
	
	# Create cursor
	create_cursor()

func setup_signals():
	cursor_timer.timeout.connect(_on_cursor_timer_timeout)

func find_integration_nodes_0():
	# Try to find task manager if not already set
	if not task_manager:
		task_manager = get_node_or_null("/root/JSHTaskManager")
		if task_manager and task_manager.has_method("track_data_flow"):
			task_manager.track_data_flow(
				"TextWindow", 
				window_title, 
				"window_opened", 
				1.0
			)

func register_default_commands():
	#register_command("help", _cmd_help)
	register_command("clear", _cmd_clear)
	#register_command("start", _cmd_start_game)
	#register_command("pause", _cmd_pause_game)
	#register_command("resume", _cmd_resume_game)
	#register_command("restart", _cmd_restart_game)
	#register_command("score", _cmd_show_high_score)

# ===== COMMAND HANDLERS =====
#func _cmd_help(args: Array) -> Dictionary:
	#var help_text = "JSH Snake Game - Available commands:\n"
	#help_text += "/help - Show this help message\n"
	#help_text += "/clear - Clear the text window\n"



























	
	register_command("color", _cmd_color)
	register_command("resize", _cmd_resize)

# ===== WINDOW CREATION FUNCTIONS =====
func create_window_background():
	background_mesh = MeshInstance3D.new()
	add_child(background_mesh)
	
	# Create a rectangular mesh for the window
	var window_shape = BoxMesh.new()
	window_shape.size = Vector3(window_width, window_height, 0.01)
	background_mesh.mesh = window_shape
	
	# Create material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = background_color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	background_mesh.material_override = material
	
	# Add border
	create_border()
	
	# Add collision for interaction
	add_window_collision()

func create_border():
	# Top border
	var top_border = MeshInstance3D.new()
	var top_mesh = BoxMesh.new()
	top_mesh.size = Vector3(window_width, border_width, 0.015)
	top_border.mesh = top_mesh
	top_border.position = Vector3(0, window_height/2, 0.005)
	
	# Bottom border
	var bottom_border = MeshInstance3D.new()
	var bottom_mesh = BoxMesh.new()
	bottom_mesh.size = Vector3(window_width, border_width, 0.015)
	bottom_border.mesh = bottom_mesh
	bottom_border.position = Vector3(0, -window_height/2, 0.005)
	
	# Left border
	var left_border = MeshInstance3D.new()
	var left_mesh = BoxMesh.new()
	left_mesh.size = Vector3(border_width, window_height, 0.015)
	left_border.mesh = left_mesh
	left_border.position = Vector3(-window_width/2, 0, 0.005)
	
	# Right border
	var right_border = MeshInstance3D.new()
	var right_mesh = BoxMesh.new()
	right_mesh.size = Vector3(border_width, window_height, 0.015)
	right_border.mesh = right_mesh
	right_border.position = Vector3(window_width/2, 0, 0.005)
	
	# Create border material
	var border_material = MaterialLibrary.get_material("default")
	border_material.albedo_color = border_color
	
	# Apply material and add borders
	top_border.material_override = border_material
	bottom_border.material_override = border_material
	left_border.material_override = border_material
	right_border.material_override = border_material
	
	add_child(top_border)
	add_child(bottom_border)
	add_child(left_border)
	add_child(right_border)

func create_title_bar():
	title_bar = MeshInstance3D.new()
	add_child(title_bar)
	
	# Create a rectangular mesh for the title bar
	var bar_height = 0.15
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(window_width, bar_height)
	title_bar.mesh = quad_mesh
	
	# Position the title bar
	title_bar.position = Vector3(0, window_height/2 - bar_height/2, 0.002)
	
	# Create material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.15, 0.15, 0.25, window_opacity)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	title_bar.material_override = material
	
	# Add title text
	title_label = Label3D.new()
	add_child(title_label)
	title_label.text = window_title
	title_label.font_size = font_size
	title_label.modulate = text_color
	title_label.position = Vector3(0, window_height/2 - bar_height/2, 0.003)
	title_label.no_depth_test = true

func create_text_area():
	text_container = Node3D.new()
	text_container.name = "TextContainer"
	add_child(text_container)
	
	# Calculate text area dimensions
	var title_height = 0.15
	var input_height = 0.2
	var text_area_height = window_height - title_height - input_height - MARGIN * 3
	
	# Create main text label
	text_label = Label3D.new()
	FloodgateController.universal_add_child(text_label, text_container)
	text_label.text = ""
	text_label.font_size = font_size - 2
	text_label.width = window_width - text_margin * 2
	text_label.height = text_area_height
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	text_label.modulate = text_color
	text_label.no_depth_test = true
	
	# Position label
	text_label.position = Vector3(-window_width/2 + text_margin, 
		window_height/2 - title_height - MARGIN - text_area_height/2, 
		0.003)
	
	# Calculate visible lines
	var line_height = 0.07  # Approximate height of one line of text
	visible_lines = int(text_area_height / line_height)

func create_control_buttons():
	# Close button
	close_button = create_button(
		"CloseButton",
		Vector3(window_width/2 - MARGIN*2, window_height/2 - MARGIN*1.5, 0.003),
		Vector2(0.1, 0.1),
		Color(1, 0.3, 0.3, 1),
		"X"
	)
	
	# Minimize button
	minimize_button = create_button(
		"MinimizeButton",
		Vector3(window_width/2 - MARGIN*4, window_height/2 - MARGIN*1.5, 0.003),
		Vector2(0.1, 0.1),
		Color(0.3, 0.7, 1, 1),
		"-"
	)
	
	# Scroll buttons
	scroll_up_button = create_button(
		"ScrollUpButton",
		Vector3(window_width/2 - MARGIN*2, window_height/4, 0.003),
		Vector2(0.1, 0.1),
		Color(0.7, 0.7, 0.7, 1),
		"↑"
	)
	
	scroll_down_button = create_button(
		"ScrollDownButton",
		Vector3(window_width/2 - MARGIN*2, -window_height/4, 0.003),
		Vector2(0.1, 0.1),
		Color(0.7, 0.7, 0.7, 1),
		"↓"
	)

func create_input_line():
	input_line = Label3D.new()
	add_child(input_line)
	input_line.text = ""
	input_line.font_size = font_size
	input_line.modulate = text_color
	input_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	input_line.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	input_line.width = window_width - text_margin * 2
	input_line.position = Vector3(-window_width/2 + text_margin, -window_height/2 + text_margin, 0.003)

func create_cursor():
	cursor = MeshInstance3D.new()
	add_child(cursor)
	var cursor_mesh = BoxMesh.new()
	cursor_mesh.size = Vector3(0.02, 0.05, 0.01)
	cursor.mesh = cursor_mesh
	
	var cursor_material = MaterialLibrary.get_material("default")
	cursor_material.albedo_color = text_color
	cursor.material_override = cursor_material
	
	cursor.position = Vector3(-window_width/2 + text_margin, -window_height/2 + text_margin, 0.004)
	
	# Setup cursor blinking timer
	cursor_timer = TimerManager.get_timer()
	add_child(cursor_timer)
	cursor_timer.wait_time = 0.5
	cursor_timer.autostart = true

func create_button(button_name, button_position, size, color, label_text):
	var button = Node3D.new()
	button.name = button_name
	add_child(button)
	
	# Create button background
	var button_mesh = MeshInstance3D.new()
	FloodgateController.universal_add_child(button_mesh, button)
	
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = size
	button_mesh.mesh = quad_mesh
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	button_mesh.material_override = material
	
	# Add label
	var text = Label3D.new()
	FloodgateController.universal_add_child(text, button)
	text.text = label_text
	text.font_size = font_size
	text.position.z = 0.001
	text.no_depth_test = true
	
	# Position the button
	button.position = button_position
	
	# Add collision shape for interaction
	var area = Area3D.new()
	FloodgateController.universal_add_child(area, button)
	
	var collision = CollisionShape3D.new()
	FloodgateController.universal_add_child(collision, area)
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(size.x, size.y, 0.05)
	collision.shape = box_shape
	
	# Connect area signals
	area.input_event.connect(func(camera, event, pos, normal, shape_idx): 
		_on_button_input_event(button_name, camera, event, pos, normal, shape_idx)
	)
	
	return button

func add_window_collision():
	var area = Area3D.new()
	area.name = "WindowArea"
	add_child(area)
	
	var collision = CollisionShape3D.new()
	FloodgateController.universal_add_child(collision, area)
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(window_width, window_height, 0.05)
	collision.shape = box_shape
	
	# Connect signals
	area.input_event.connect(_on_window_input_event)
	area.mouse_entered.connect(_on_window_mouse_entered)
	area.mouse_exited.connect(_on_window_mouse_exited)



# ===== EVENT HANDLERS =====
func _on_window_input_event(_camera, event, event_position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Check for title bar drag
			var local_position = event_position - global_position
			if local_position.y > window_height/2 - 0.15:
				if can_be_dragged:
					is_dragging = true
					drag_start_position = event_position
					window_initial_position = global_position
			
			# Focus the window
			focus()

func _on_window_mouse_entered():
	# Visual feedback when mouse enters
	if background_mesh and background_mesh.material_override:
		var material = background_mesh.material_override
		material.albedo_color.a = min(1.0, window_opacity + 0.1)

func _on_window_mouse_exited():
	# Reset visual feedback
	if background_mesh and background_mesh.material_override:
		var material = background_mesh.material_override
		material.albedo_color.a = window_opacity

func _on_button_input_event(button_name, _camera, event, _pos, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match button_name:
			"CloseButton":
				emit_signal("window_closed")
				if get_parent():
					get_parent().remove_child(self)
				queue_free()
			"MinimizeButton":
				is_minimized = !is_minimized
				toggle_minimized()
			"ScrollUpButton":
				scroll_messages_up()
			"ScrollDownButton":
				scroll_messages_down()

func _on_cursor_timer_timeout():
	cursor_visible = !cursor_visible
	cursor.visible = cursor_visible and is_focused

# ===== USER INTERACTION =====
func _submit_text():
	if input_text.strip_edges() == "":
		return
		
	# Add the submitted text to the buffer
	add_text("> " + input_text)
	
	# Add to command history
	command_history.push_front(input_text)
	if command_history.size() > 20:  # Limit history size
		command_history.pop_back()
	command_history_index = -1
	
	# Process as command if it starts with the command prefix
	if input_text.begins_with(command_prefix):
		_process_command(input_text.substr(command_prefix.length()))
	else:
		text_submitted.emit(input_text)
	
	# Clear input line
	input_text = ""
	cursor_position = 0
	_update_display()

func _navigate_command_history(up: bool):
	if command_history.is_empty():
		return
		
	if up:
		# Move back in history
		if command_history_index < command_history.size() - 1:
			command_history_index += 1
			input_text = command_history[command_history_index]
			cursor_position = input_text.length()
			_update_display()
	else:
		# Move forward in history
		if command_history_index > 0:
			command_history_index -= 1
			input_text = command_history[command_history_index]
			cursor_position = input_text.length()
			_update_display()
		elif command_history_index == 0:
			command_history_index = -1
			input_text = ""
			cursor_position = 0
			_update_display()

func _update_cursor_position():
	# Calculate cursor position based on the text up to cursor_position
	var partial_text = input_text.substr(0, cursor_position)
	
	# Approximate cursor position based on character count
	var char_width = 0.04  # Approximate character width in 3D units
	var x_offset = ("> ".length() + partial_text.length()) * char_width
	
	cursor.position = Vector3(-window_width/2 + text_margin + x_offset, -window_height/2 + text_margin, 0.004)

func _process_command(command_text: String):
	var parts = command_text.strip_edges().split(" ", false)
	if parts.size() == 0:
		return
		
	var command_name = parts[0]
	var args = parts.slice(1)
	
	var command_processor = $CommandProcessor as CommandProcessor
	var result = command_processor.execute_command(command_name, args)
	if not result.success:
		add_text("Error: " + result.message)
	
	command_executed.emit(command_name, args)

# ===== DISPLAY MANAGEMENT =====
func _update_display():
	# Update main text area
	text_label.text = "\n".join(text_buffer)
	
	# Update input line with cursor
	var display_text = input_text
	if is_focused:
		input_line.text = "> " + display_text
	else:
		input_line.text = ""
		
	# Update border color based on focus state
	_update_border_color()

func _update_border_color():
	for i in range(1, 5):  # Skip the window_mesh at index 0
		var border = get_child(i)
		if border is MeshInstance3D and border != background_mesh and border != text_label and border != input_line:
			var material = border.material_override
			if material:
				if is_focused:
					material.albedo_color = Color(0.4, 0.7, 1.0)
				else:
					material.albedo_color = border_color

func toggle_minimized():
	if is_minimized:
		# Show only title bar
		background_mesh.visible = false
		text_label.visible = false
		input_line.visible = false
		cursor.visible = false
		scroll_up_button.visible = false
		scroll_down_button.visible = false
	else:
		# Show full window
		background_mesh.visible = true
		text_label.visible = true
		input_line.visible = true
		cursor.visible = is_focused and cursor_visible
		scroll_up_button.visible = true
		scroll_down_button.visible = true
	
	# Update text display
	_update_display()

func scroll_messages_up():
	var max_scroll = max(0, text_buffer.size() - max_visible_lines)
	scroll_offset = min(max_scroll, scroll_offset + 1)
	update_text_display()

func scroll_messages_down():
	scroll_offset = max(0, scroll_offset - 1)
	update_text_display()

func update_text_display():
	# Implementation for updating text display
	if text_label:
		# Split text into lines
		var lines = full_text.split("\n")
		
		# Determine which lines to show based on scroll offset
		var start_line = scroll_offset
		var end_line = min(lines.size(), start_line + visible_lines)
		
		# Join only the visible lines
		var visible_text = ""
		for i in range(start_line, end_line):
			visible_text += lines[i]
			if i < end_line - 1:
				visible_text += "\n"
		
		# Update the label
		text_label.text = visible_text

# ===== PUBLIC API =====
func add_text(text: String):
	text_buffer.append(text)
	if text_buffer.size() > max_visible_lines:
		text_buffer.remove_at(0)
	_update_display()

func clear_text():
	text_buffer.clear()
	_update_display()

func focus():
	is_focused = true
	window_focused.emit()
	_update_display()

func unfocus():
	is_focused = false
	window_unfocused.emit()
	_update_display()

func register_command(command_name: String, callback: Callable):
	var command_processor = $CommandProcessor as CommandProcessor
	if command_processor:
		command_processor.register_command(command_name, callback)

func resize(new_width, new_height):
	# Store old values to detect changes
	var old_width = window_width
	var old_height = window_height
	
	# Update properties
	window_width = new_width
	window_height = new_height
	
	# Only rebuild if dimensions actually changed
	if old_width != new_width or old_height != new_height:
		# Remove all children
		for child in get_children():
			remove_child(child)
			child.queue_free()
			
		# Setup components again with new dimensions
		setup_window()
		_update_display()
		setup_signals()
		
		# Emit resize signal for external listeners
		emit_signal("window_resized", Vector2(new_width, new_height))

func set_text(text_content, format_links = true):
	full_text = text_content
	total_lines = text_content.count("\n") + 1
	
	# Track data in task manager
	if task_manager and task_manager.has_method("track_data_flow"):
		task_manager.track_data_flow(
			"TextWindow", 
			window_title, 
			"text_updated", 
			text_content.length()
		)
	
	# Process any links in the text if enabled
	if supports_links and format_links:
		process_text_links()
	else:
		text_buffer = text_content.split("\n")
		
	# Update scroll position
	if auto_scroll:
		scroll_offset = max(0, text_buffer.size() - visible_lines)

	_update_display()
	
	emit_signal("text_updated", full_text)

func process_text_links():
	# Parse links from the full_text and update the links dictionary
	var processed_text = full_text
	var link_regex = RegEx.new()
	link_regex.compile("\\[link:([^|]+)\\|([^\\]]+)\\]")
	
	links.clear()
	
	var matches = link_regex.search_all(full_text)
	for match_result in matches:
		var link_id = match_result.get_string(1)
		var link_text = match_result.get_string(2)
		
		# Store link info
		links[link_id] = {
			"text": link_text,
			"start": match_result.get_start(),
			"end": match_result.get_end()
		}
		
		# Replace the link with just the text
		processed_text = processed_text.replace(match_result.get_string(), link_text)
	
	# Update the text buffer with processed text
	text_buffer = processed_text.split("\n")


# ===== USER INTERACTION =====
func _submit_text_0():
	if input_text.strip_edges() == "":
		return
		
	# Add the submitted text to the buffer
	add_text("> " + input_text)
	
	# Add to command history
	command_history.push_front(input_text)
	if command_history.size() > 20:  # Limit history size
		command_history.pop_back()
	command_history_index = -1
	
	# Process as command if it starts with the command prefix
	if input_text.begins_with(command_prefix):
		_process_command(input_text.substr(command_prefix.length()))
	else:
		text_submitted.emit(input_text)
	
	# Clear input line
	input_text = ""
	cursor_position = 0
	_update_display()

func _navigate_command_history_0(up: bool):
	if command_history.is_empty():
		return
		
	if up:
		# Move back in history
		if command_history_index < command_history.size() - 1:
			command_history_index += 1
			input_text = command_history[command_history_index]
			cursor_position = input_text.length()
			_update_display()
	else:
		# Move forward in history
		if command_history_index > 0:
			command_history_index -= 1
			input_text = command_history[command_history_index]
			cursor_position = input_text.length()
			_update_display()
		elif command_history_index == 0:
			command_history_index = -1
			input_text = ""
			cursor_position = 0
			_update_display()

func _update_cursor_position_0():
	# Calculate cursor position based on the text up to cursor_position
	var font = text_label.font
	var partial_text = input_text.substr(0, cursor_position)
	
	# Approximate cursor position based on character count
	# This is a simplified approach - for a more accurate one, you'd need to measure text width
	var char_width = 0.04  # Approximate character width in 3D units
	var x_offset = ("> ".length() + partial_text.length()) * char_width
	
	cursor.position = Vector3(-window_width/2 + text_margin + x_offset, -window_height/2 + text_margin, 0.012)

func _process_command_0(command_text: String):
	var parts = command_text.strip_edges().split(" ", false)
	if parts.size() == 0:
		return
		
	var command_name = parts[0]
	var args = parts.slice(1)
	
	var result = command_processor.execute_command(command_name, args)
	if not result.success:
		add_text("Error: " + result.message)
	
	command_executed.emit(command_name, args)

func _on_cursor_timer_timeout_0():
	cursor_visible = !cursor_visible
	cursor.visible = cursor_visible and is_focused

# ===== DISPLAY MANAGEMENT =====
func _update_display_0():
	# Update main text area
	text_label.text = "\n".join(text_buffer)
	
	# Update input line with cursor
	var display_text = input_text
	if is_focused:
		input_line.text = "> " + display_text
	else:
		input_line.text = ""
		
	# Update border color based on focus state
	_update_border_color()

func _update_border_color_0():
	for i in range(1, 5):  # Skip the window_mesh at index 0
		var border = get_child(i)
		if border is MeshInstance3D and border != window_mesh and border != text_label and border != input_line:
			var material = border.material_override
			if material:
				if is_focused:
					material.albedo_color = Color(0.4, 0.7, 1.0)
				else:
					material.albedo_color = border_color

# ===== PUBLIC API =====
func add_text_0(text: String):
	text_buffer.append(text)
	if text_buffer.size() > max_visible_lines:
		text_buffer.remove_at(0)
	_update_display()

func clear_text_0():
	text_buffer.clear()
	_update_display()

func focus_0():
	is_focused = true
	window_focused.emit()
	_update_display()

func unfocus_0():
	is_focused = false
	window_unfocused.emit()
	_update_display()

func register_command_0(command_name: String, callback: Callable):
	command_processor.register_command(command_name, callback)

func resize_0(new_width, new_height):
	# Store old values to detect changes
	var old_width = window_width
	var old_height = window_height
	
	# Update properties
	window_width = new_width
	window_height = new_height
	
	# Only rebuild if dimensions actually changed
	if old_width != new_width or old_height != new_height:
		# Remove all children
		for child in get_children():
			remove_child(child)
			child.queue_free()
			
		# Setup components again with new dimensions
		_setup_components()
		_update_display()
		_setup_signals()
		
		# Emit resize signal for external listeners
		emit_signal("window_resized", Vector2(new_width, new_height))

func set_text_0(text_content, format_links = true):
	full_text = text_content
	total_lines = text_content.count("\n") + 1
	
	# Track data in task manager
	if task_manager and task_manager.has_method("track_data_flow"):
		task_manager.track_data_flow(
			"TextWindow", 
			window_title, 
			"text_updated", 
			text_content.length()
		)
	
	# Process any links in the text if enabled
	if supports_links and format_links:
		process_text_links()
	else:
		content_label.text = full_text
	
	# Update scroll position
	if auto_scroll:
		scroll_offset = max(0, total_lines - visible_lines)
		update_text_display()
	else:
		update_text_display()
	
	emit_signal("text_updated", full_text)

func update_text_display_0():
	# Implementation for updating text display
	if content_label:
		# Split text into lines
		var lines = full_text.split("\n")
		
		# Determine which lines to show based on scroll offset
		var start_line = scroll_offset
		var end_line = min(lines.size(), start_line + visible_lines)
		
		# Join only the visible lines
		var visible_text = ""
		for i in range(start_line, end_line):
			visible_text += lines[i]
			if i < end_line - 1:
				visible_text += "\n"
		
		# Update the label
		content_label.text = visible_text

func process_text_links_0():
	# Parse links from the full_text and update the links dictionary
	var processed_text = full_text
	var link_regex = RegEx.new()
	link_regex.compile("\\[link:([^|]+)\\|([^\\]]+)\\]")
	
	links.clear()
	
	var matches = link_regex.search_all(full_text)
	for match_result in matches:
		var link_id = match_result.get_string(1)
		var link_text = match_result.get_string(2)
		
		# Store link info
		links[link_id] = {
			"text": link_text,
			"start": match_result.get_start(),
			"end": match_result.get_end()
		}
		
		# Replace the link with just the text
		processed_text = processed_text.replace(match_result.get_string(), link_text)
	
	# Update the display text
	if content_label:
		content_label.text = processed_text

# ===== UI ELEMENTS =====
func create_control_buttons_0():
	# Close button
	close_button = create_button(
		"CloseButton",
		Vector3(window_width/2 - MARGIN*2, window_height/2 - MARGIN*1.5, 0.002),
		Vector2(0.1, 0.1),
		Color(1, 0.3, 0.3, 1),
		"X"
	)
	
	# Minimize button
	minimize_button = create_button(
		"MinimizeButton",
		Vector3(window_width/2 - MARGIN*4, window_height/2 - MARGIN*1.5, 0.002),
		Vector2(0.1, 0.1),
		Color(0.3, 0.7, 1, 1),
		"-"
	)
	
	# Scroll buttons
	scroll_up_button = create_button(
		"ScrollUpButton",
		Vector3(window_width/2 - MARGIN*2, 0, 0.002),
		Vector2(0.1, 0.1),
		Color(0.7, 0.7, 0.7, 1),
		"↑"
	)
	
	scroll_down_button = create_button(
		"ScrollDownButton",
		Vector3(window_width/2 - MARGIN*2, -window_height/2 + MARGIN*4, 0.002),
		Vector2(0.1, 0.1),
		Color(0.7, 0.7, 0.7, 1),
		"↓"
	)

func create_button_0(button_name, button_position, size, color, label_text):
	var button = Node3D.new()
	button.name = button_name
	add_child(button)
	
	# Create button background
	var button_mesh = MeshInstance3D.new()
	FloodgateController.universal_add_child(button_mesh, button)
	
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = size
	button_mesh.mesh = quad_mesh
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	button_mesh.material_override = material
	
	# Add label
	var text = Label3D.new()
	FloodgateController.universal_add_child(text, button)
	text.text = label_text
	text.font_size = font_size
	text.position.z = 0.001
	text.no_depth_test = true
	
	# Position the button
	button.position = button_position
	
	# Add collision shape for interaction
	var area = Area3D.new()
	FloodgateController.universal_add_child(area, button)
	
	var collision = CollisionShape3D.new()
	FloodgateController.universal_add_child(collision, area)
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(size.x, size.y, 0.05)
	collision.shape = box_shape
	
	# Connect area signals
	area.input_event.connect(func(camera, event, pos, normal, shape_idx): 
		_on_button_input_event(button_name, camera, event, pos, normal, shape_idx)
	)
	
	return button

func _on_button_input_event_0(button_name, _camera, event, _pos, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match button_name:
			"CloseButton":
				emit_signal("window_closed")
				if get_parent():
					get_parent().remove_child(self)
				queue_free()
			"MinimizeButton":
				is_minimized = !is_minimized
				toggle_minimized()
			"ScrollUpButton":
				scroll_messages_up()
			"ScrollDownButton":
				scroll_messages_down()

func toggle_minimized_0():
	if is_minimized:
		# Show only title bar
		window_mesh.visible = false
		text_label.visible = false
		input_line.visible = false
		scroll_up_button.visible = false
		scroll_down_button.visible = false
	else:
		# Show full window
		window_mesh.visible = true
		text_label.visible = true
		input_line.visible = true
		scroll_up_button.visible = true
		scroll_down_button.visible = true
	
	# Update text display
	_update_display()

func scroll_messages_up_0():
	var max_scroll = max(0, text_buffer.size() - max_visible_lines)
	scroll_offset = min(max_scroll, scroll_offset + 1)
	update_text_display()

func scroll_messages_down_0():
	scroll_offset = max(0, scroll_offset - 1)
	update_text_display()

# ===== CHAT FUNCTIONALITY =====
func add_system_message(message):
	return add_message(message, "System")

func add_message(message, sender_name = "User"):
	var msg = {
		"text": message,
		"sender": sender_name,
		"timestamp": Time.get_time_string_from_system()
	}
	
	# Assuming we're storing messages in text_buffer
	var formatted_message = "[%s] %s: %s" % [msg.timestamp, msg.sender, msg.text]
	add_text(formatted_message)
	
	# Record in task manager if available
	if task_manager and task_manager.has_method("track_data_flow"):
		task_manager.track_data_flow(
			sender_name, 
			window_title, 
			"chat_message", 
			message.length()
		)
	
	emit_signal("message_sent", message, sender_name)
	return msg

# ===== INTEGRATION WITH RECORDS SYSTEM =====
func link_to_datapoint(datapoint_path: String):
	# Implement integration with your records system here
	if task_manager and task_manager.has_method("register_window"):
		task_manager.register_window(self, datapoint_path)
		
	# Load any data from the datapoint
	if task_manager and task_manager.has_method("get_datapoint_data"):
		var data = task_manager.get_datapoint_data(datapoint_path)
		if data:
			set_text(str(data))
	
	return {"success": true, "message": "Linked to datapoint: " + datapoint_path}

func update_from_datapoint(datapoint_path: String):
	# Refresh data from datapoint
	if task_manager and task_manager.has_method("get_datapoint_data"):
		var data = task_manager.get_datapoint_data(datapoint_path)
		if data:
			set_text(str(data))
	
	return {"success": true, "message": "Updated from datapoint: " + datapoint_path}

# ===== CREATE TEXT DISPLAY AREA =====
func create_text_area_0():
	text_container = Node3D.new()
	text_container.name = "TextContainer"
	add_child(text_container)
	
	# Calculate text area dimensions
	var title_height = 0.15
	var button_margin = 0.1
	var text_area_height = DEFAULT_HEIGHT - title_height - button_margin * 2
	
	# Position the container
	text_container.position = Vector3(
		0, 
		(DEFAULT_HEIGHT - title_height)/2 - text_area_height/2,
		0.002
	)
	
	# Create main text label
	content_label = Label3D.new()
	FloodgateController.universal_add_child(content_label, text_container)
	content_label.text = ""
	content_label.font_size = font_size - 2
	content_label.width = DEFAULT_WIDTH - MARGIN * 4
	content_label.height = text_area_height
	content_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	content_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	content_label.modulate = text_color
	content_label.no_depth_test = true
	
	# Position label within container
	content_label.position = Vector3(-DEFAULT_WIDTH/2 + MARGIN*2, text_area_height/2 - MARGIN, 0)
	
	# Calculate visible lines
	var line_height = 0.07
	visible_lines = int(text_area_height / line_height)
	
	# Add collision to make the text area interactive
	add_window_collision()

# Add collision to the window for interaction
func add_window_collision_0():
	var area = Area3D.new()
	area.name = "WindowArea"
	add_child(area)
	
	var collision = CollisionShape3D.new()
	FloodgateController.universal_add_child(collision, area)
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(DEFAULT_WIDTH, DEFAULT_HEIGHT, 0.05)
	collision.shape = box_shape
	
	# Connect signals
	area.input_event.connect(_on_window_input_event)
	area.mouse_entered.connect(_on_window_mouse_entered)
	area.mouse_exited.connect(_on_window_mouse_exited)

func _setup_components_old():
	# Create window background
	window_mesh = MeshInstance3D.new()
	var window_material = MaterialLibrary.get_material("default")
	window_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	window_material.albedo_color = background_color
	
	var window_shape = BoxMesh.new()
	window_shape.size = Vector3(window_width, window_height, 0.01)
	window_mesh.mesh = window_shape
	window_mesh.material_override = window_material
	add_child(window_mesh)
	
	# Create border (using multiple quads for simplicity)
	_create_border()
	
	# Create text display
	text_label = Label3D.new()
	text_label.text = ""
	text_label.font_size = font_size
	text_label.modulate = text_color
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	text_label.width = window_width - (text_margin * 2)
	text_label.position = Vector3(-window_width/2 + text_margin, window_height/2 - text_margin, 0.011)
	add_child(text_label)
	
	# Create input line
	input_line = Label3D.new()
	input_line.text = ""
	input_line.font_size = font_size
	input_line.modulate = text_color
	input_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	input_line.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	input_line.width = window_width - (text_margin * 2)
	input_line.position = Vector3(-window_width/2 + text_margin, -window_height/2 + text_margin, 0.011)
	add_child(input_line)
	
	# Create cursor
	cursor = MeshInstance3D.new()
	var cursor_mesh = BoxMesh.new()
	cursor_mesh.size = Vector3(0.05, 0.05, 0.01)
	cursor.mesh = cursor_mesh
	cursor.material_override = window_material.duplicate()
	cursor.material_override.albedo_color = text_color
	cursor.position = Vector3(-window_width/2 + text_margin, -window_height/2 + text_margin, 0.012)
	add_child(cursor)
	
	# Setup cursor blinking timer
	cursor_timer = TimerManager.get_timer()
	cursor_timer.wait_time = 0.5
	cursor_timer.autostart = true
	add_child(cursor_timer)
	
	# Initialize command processor
	command_processor = CommandProcessor.new()
	add_child(command_processor)
	
	# Set up control buttons
	create_control_buttons()

func _create_border_old():
	# Top border
	var top_border = MeshInstance3D.new()
	var top_mesh = BoxMesh.new()
	top_mesh.size = Vector3(window_width, border_width, 0.015)
	top_border.mesh = top_mesh
	top_border.position = Vector3(0, window_height/2, 0.005)
	
	# Bottom border
	var bottom_border = MeshInstance3D.new()
	var bottom_mesh = BoxMesh.new()
	bottom_mesh.size = Vector3(window_width, border_width, 0.015)
	bottom_border.mesh = bottom_mesh
	bottom_border.position = Vector3(0, -window_height/2, 0.005)
	
	# Left border
	var left_border = MeshInstance3D.new()
	var left_mesh = BoxMesh.new()
	left_mesh.size = Vector3(border_width, window_height, 0.015)
	left_border.mesh = left_mesh
	left_border.position = Vector3(-window_width/2, 0, 0.005)
	
	# Right border
	var right_border = MeshInstance3D.new()
	var right_mesh = BoxMesh.new()
	right_mesh.size = Vector3(border_width, window_height, 0.015)
	right_border.mesh = right_mesh
	right_border.position = Vector3(window_width/2, 0, 0.005)
	
	# Create border material
	var border_material = MaterialLibrary.get_material("default")
	border_material.albedo_color = border_color
	
	# Apply material and add borders
	top_border.material_override = border_material
	bottom_border.material_override = border_material
	left_border.material_override = border_material
	right_border.material_override = border_material
	
	add_child(top_border)
	add_child(bottom_border)
	add_child(left_border)
	add_child(right_border)

func _setup_signals_old():
	cursor_timer.timeout.connect(_on_cursor_timer_timeout)

func find_integration_nodes_old():
	# Try to find C# integration node
	csharp_integration = get_node_or_null("/root/JSHSystemIntegration")
	
	# Find task manager if not already set
	if not task_manager:
		task_manager = get_node_or_null("/root/JSHTaskManager")
		if task_manager and task_manager.has_method("track_data_flow"):
			task_manager.track_data_flow(
				"TextWindow", 
				window_title, 
				"window_opened", 
				1.0
			)

# ===== INPUT HANDLING =====
func _process_old_v3(delta):
	if is_focused:
		_update_cursor_position()
	
	# Update cursor blink
	if is_focused:
		cursor_blink_time += delta
		if cursor_blink_time >= 1.0:
			cursor_blink_time = 0.0
			cursor_visible = !cursor_visible
		cursor.visible = cursor_visible

func _input_old_v4(event):
	if not is_focused:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				unfocus()
			KEY_BACKSPACE:
				if cursor_position > 0:
					input_text = input_text.substr(0, cursor_position - 1) + input_text.substr(cursor_position)
					cursor_position -= 1
					_update_display()
			KEY_DELETE:
				if cursor_position < input_text.length():
					input_text = input_text.substr(0, cursor_position) + input_text.substr(cursor_position + 1)
					_update_display()
			KEY_LEFT:
				if cursor_position > 0:
					cursor_position -= 1
			KEY_RIGHT:
				if cursor_position < input_text.length():
					cursor_position += 1
			KEY_HOME:
				cursor_position = 0
			KEY_END:
				cursor_position = input_text.length()
			KEY_UP:
				_navigate_command_history(true)
			KEY_DOWN:
				_navigate_command_history(false)
			KEY_ENTER, KEY_KP_ENTER:
				_submit_text()
			_:
				# Handle regular character input
				if event.unicode != 0 and event.unicode < 128:
					var char = char(event.unicode)
					input_text = input_text.substr(0, cursor_position) + char + input_text.substr(cursor_position)
					cursor_position += 1
					_update_display()
	
	# Handle mouse wheel for scrolling
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_messages_up()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_messages_down()

# ===== USER INTERACTION =====
func _submit_text_old():
	if input_text.strip_edges() == "":
		return
		
	# Add the submitted text to the buffer
	add_text("> " + input_text)
	
	# Add to command history
	command_history.push_front(input_text)
	if command_history.size() > 20:  # Limit history size
		command_history.pop_back()
	command_history_index = -1
	
	# Process as command if it starts with the command prefix
	if input_text.begins_with(command_prefix):
		_process_command(input_text.substr(command_prefix.length()))
	else:
		text_submitted.emit(input_text)
	
	# Clear input line
	input_text = ""
	cursor_position = 0
	_update_display()

func _navigate_command_history_old(up: bool):
	if command_history.is_empty():
		return
		
	if up:
		# Move back in history
		if command_history_index < command_history.size() - 1:
			command_history_index += 1
			input_text = command_history[command_history_index]
			cursor_position = input_text.length()
			_update_display()
	else:
		# Move forward in history
		if command_history_index > 0:
			command_history_index -= 1
			input_text = command_history[command_history_index]
			cursor_position = input_text.length()
			_update_display()
		elif command_history_index == 0:
			command_history_index = -1
			input_text = ""
			cursor_position = 0
			_update_display()

func _update_cursor_position_old():
	# Calculate cursor position based on the text up to cursor_position
	var font = text_label.font
	var partial_text = input_text.substr(0, cursor_position)
	
	# Approximate cursor position based on character count
	# This is a simplified approach - for a more accurate one, you'd need to measure text width
	var char_width = 0.04  # Approximate character width in 3D units
	var x_offset = ("> ".length() + partial_text.length()) * char_width
	
	cursor.position = Vector3(-window_width/2 + text_margin + x_offset, -window_height/2 + text_margin, 0.012)

func _process_command_old(command_text: String):
	var parts = command_text.strip_edges().split(" ", false)
	if parts.size() == 0:
		return
		
	var command_name = parts[0]
	var args = parts.slice(1)
	
	var result = command_processor.execute_command(command_name, args)
	if not result.success:
		add_text("Error: " + result.message)
	
	command_executed.emit(command_name, args)

func _on_cursor_timer_timeout_old():
	cursor_visible = !cursor_visible
	cursor.visible = cursor_visible and is_focused

# ===== DISPLAY MANAGEMENT =====
func _update_display_old():
	# Update main text area
	text_label.text = "\n".join(text_buffer)
	
	# Update input line with cursor
	var display_text = input_text
	if is_focused:
		input_line.text = "> " + display_text
	else:
		input_line.text = ""
		
	# Update border color based on focus state
	_update_border_color()

func _update_border_color_old():
	for i in range(1, 5):  # Skip the window_mesh at index 0
		var border = get_child(i)
		if border is MeshInstance3D and border != window_mesh and border != text_label and border != input_line:
			var material = border.material_override
			if material:
				if is_focused:
					material.albedo_color = Color(0.4, 0.7, 1.0)
				else:
					material.albedo_color = border_color

# ===== PUBLIC API =====
func add_text_old(text: String):
	text_buffer.append(text)
	if text_buffer.size() > max_visible_lines:
		text_buffer.remove_at(0)
	_update_display()

func clear_text_old():
	text_buffer.clear()
	_update_display()

func focus_old():
	is_focused = true
	window_focused.emit()
	_update_display()

func unfocus_old():
	is_focused = false
	window_unfocused.emit()
	_update_display()

func register_command_old(command_name: String, callback: Callable):
	command_processor.register_command(command_name, callback)

func resize_old(new_width, new_height):
	# We would need to recreate or rescale all meshes
	window_width = new_width
	window_height = new_height
	
	# This would involve recreating the meshes with new dimensions
	# For now just emit the signal
	emit_signal("window_resized", Vector2(new_width, new_height))

func set_text_old(text_content, format_links = true):
	full_text = text_content
	total_lines = text_content.count("\n") + 1
	
	# Track data in task manager
	if task_manager and task_manager.has_method("track_data_flow"):
		task_manager.track_data_flow(
			"TextWindow", 
			window_title, 
			"text_updated", 
			text_content.length()
		)
	
	# Process any links in the text if enabled
	if supports_links and format_links:
		process_text_links()
	else:
		content_label.text = full_text
	
	# Update scroll position
	if auto_scroll:
		scroll_offset = max(0, total_lines - visible_lines)
		update_text_display()
	else:
		update_text_display()
	
	emit_signal("text_updated", full_text)

func update_text_display_old():
	# Implementation for updating text display
	if content_label:
		# Split text into lines
		var lines = full_text.split("\n")
		
		# Determine which lines to show based on scroll offset
		var start_line = scroll_offset
		var end_line = min(lines.size(), start_line + visible_lines)
		
		# Join only the visible lines
		var visible_text = ""
		for i in range(start_line, end_line):
			visible_text += lines[i]
			if i < end_line - 1:
				visible_text += "\n"
		
		# Update the label
		content_label.text = visible_text

func process_text_links_old():
	# Parse links from the full_text and update the links dictionary
	var processed_text = full_text
	var link_regex = RegEx.new()
	link_regex.compile("\\[link:([^|]+)\\|([^\\]]+)\\]")
	
	links.clear()
	
	var matches = link_regex.search_all(full_text)
	for match_result in matches:
		var link_id = match_result.get_string(1)
		var link_text = match_result.get_string(2)
		
		# Store link info
		links[link_id] = {
			"text": link_text,
			"start": match_result.get_start(),
			"end": match_result.get_end()
		}
		
		# Replace the link with just the text
		processed_text = processed_text.replace(match_result.get_string(), link_text)
	
	# Update the display text
	if content_label:
		content_label.text = processed_text

# ===== UI ELEMENTS =====
func create_control_buttons_old():
	# Close button
	close_button = create_button(
		"CloseButton",
		Vector3(window_width/2 - MARGIN*2, window_height/2 - MARGIN*1.5, 0.002),
		Vector2(0.1, 0.1),
		Color(1, 0.3, 0.3, 1),
		"X"
	)
	
	# Minimize button
	minimize_button = create_button(
		"MinimizeButton",
		Vector3(window_width/2 - MARGIN*4, window_height/2 - MARGIN*1.5, 0.002),
		Vector2(0.1, 0.1),
		Color(0.3, 0.7, 1, 1),
		"-"
	)
	
	# Scroll buttons
	scroll_up_button = create_button(
		"ScrollUpButton",
		Vector3(window_width/2 - MARGIN*2, 0, 0.002),
		Vector2(0.1, 0.1),
		Color(0.7, 0.7, 0.7, 1),
		"↑"
	)
	
	scroll_down_button = create_button(
		"ScrollDownButton",
		Vector3(window_width/2 - MARGIN*2, -window_height/2 + MARGIN*4, 0.002),
		Vector2(0.1, 0.1),
		Color(0.7, 0.7, 0.7, 1),
		"↓"
	)

func create_button_old(button_name, button_position, size, color, label_text):
	var button = Node3D.new()
	button.name = button_name
	add_child(button)
	
	# Create button background
	var button_mesh = MeshInstance3D.new()
	FloodgateController.universal_add_child(button_mesh, button)
	
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = size
	button_mesh.mesh = quad_mesh
	
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	button_mesh.material_override = material
	
	# Add label
	var text = Label3D.new()
	FloodgateController.universal_add_child(text, button)
	text.text = label_text
	text.font_size = font_size
	text.position.z = 0.001
	text.no_depth_test = true
	
	# Position the button
	button.position = button_position
	
	# Add collision shape for interaction
	var area = Area3D.new()
	FloodgateController.universal_add_child(area, button)
	
	var collision = CollisionShape3D.new()
	FloodgateController.universal_add_child(collision, area)
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(size.x, size.y, 0.05)
	collision.shape = box_shape
	
	# Connect area signals
	area.input_event.connect(func(camera, event, pos, normal, shape_idx): 
		_on_button_input_event(button_name, camera, event, pos, normal, shape_idx)
	)
	
	return button

func _on_button_input_event_old(button_name, _camera, event, _pos, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match button_name:
			"CloseButton":
				emit_signal("window_closed")
				if get_parent():
					get_parent().remove_child(self)
				queue_free()
			"MinimizeButton":
				is_minimized = !is_minimized
				toggle_minimized()
			"ScrollUpButton":
				scroll_messages_up()
			"ScrollDownButton":
				scroll_messages_down()

func toggle_minimized_old():
	if is_minimized:
		# Show only title bar
		window_mesh.visible = false
		text_label.visible = false
		input_line.visible = false
		scroll_up_button.visible = false
		scroll_down_button.visible = false
	else:
		# Show full window
		window_mesh.visible = true
		text_label.visible = true
		input_line.visible = true
		scroll_up_button.visible = true
		scroll_down_button.visible = true
	
	# Update text display
	_update_display()

func scroll_messages_up_old():
	var max_scroll = max(0, text_buffer.size() - max_visible_lines)
	scroll_offset = min(max_scroll, scroll_offset + 1)
	update_text_display()

func scroll_messages_down_old():
	scroll_offset = max(0, scroll_offset - 1)
	update_text_display()

# ===== CHAT FUNCTIONALITY =====
func add_system_message_old(message):
	return add_message(message, "System")

func add_message_old(message, sender_name = "User"):
	var msg = {
		"text": message,
		"sender": sender_name,
		"timestamp": Time.get_time_string_from_system()
	}
	
	# Assuming we're storing messages in text_buffer
	var formatted_message = "[%s] %s: %s" % [msg.timestamp, msg.sender, msg.text]
	add_text(formatted_message)
	
	# Record in task manager if available
	if task_manager and task_manager.has_method("track_data_flow"):
		task_manager.track_data_flow(
			sender_name, 
			window_title, 
			"chat_message", 
			message.length()
		)
	
	emit_signal("message_sent", message, sender_name)
	return msg

# ===== INTEGRATION FUNCTIONS FOR JSH ETHEREAL ENGINE =====
func create_text_window_container(container_name: String, position: Vector3, size: Vector2 = Vector2(4, 3)) -> Dictionary:
	# This function would be called from your main.gd by your existing three_stages_of_creation system
	var window_data = {
		"container_name": container_name,
		"position": position,
		"size": size,
		"node_type": "TextWindowSystem",
		"metadata": {
			"max_lines": 10,
			"command_enabled": true,
			"visible": true
		}
	}
	
	return window_data

func setup_text_window_commands(window_node: JSHTextWindow):
	# Register default commands
	#window_node.register_command("help", _cmd_help)
	window_node.register_command("clear", _cmd_clear)
	window_node.register_command("teleport", _cmd_teleport)
	window_node.register_command("resize", _cmd_resize)
	window_node.register_command("color", _cmd_color)

func _cmd_help_0(args: Array) -> Dictionary:
	var help_text = "Available commands:\n"
	help_text += "/help - Show this help message\n"
	help_text += "/clear - Clear the text window\n"
	help_text += "/teleport x y z - Teleport to coordinates\n"
	help_text += "/resize width height - Resize the window\n"
	help_text += "/color r g b - Change text color (0-255)"
	
	return {"success": true, "message": help_text}

func _cmd_clear(_args: Array) -> Dictionary:
	clear_text()
	return {"success": true, "message": "Text cleared"}


# ===== UTILITY FUNCTIONS =====
func change_color_of_letter_or_s(string):
	# Change colors of specific letters in text
	# This could implement color interpolation, easing effects, etc.
	# Example implementation would colorize specific characters or words
	pass

# ===== WINDOW INTERACTION FUNCTIONS =====
func _on_window_input_event_0(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Check for title bar drag
			if position.y > DEFAULT_HEIGHT/2 - 0.15:
				if can_be_dragged:
					is_dragging = true
					drag_start_position = position
					window_initial_position = global_position
			
			# Focus the window
			is_focused = true
			emit_signal("window_focused")

func _on_window_mouse_entered_0():
	# Visual feedback when mouse enters
	if background_mesh and background_mesh.material_override:
		var material = background_mesh.material_override
		material.albedo_color.a = min(1.0, window_opacity + 0.1)

func _on_window_mouse_exited_0():
	# Reset visual feedback
	if background_mesh and background_mesh.material_override:
		var material = background_mesh.material_override
		material.albedo_color.a = window_opacity

# ===== TEXT WINDOW CREATION =====
func setup_window_0():
	# Create primary components
	create_window_background()
	create_title_bar()

var text_color_old = Color(1, 1, 1, 1)
var font_size_old = 16

var is_focused_old = false


# References to nodes
var window_mesh_old: MeshInstance3D

# TODO: Unused signal - consider implementing or removing
# signal window_focused_old


######################
# ===== COMMAND PROCESSOR CLASS =====
class CommandProcessor_new:
	extends UniversalBeingBase
	var commands = {}
	
	func register_command(command_name: String, callback: Callable):
		commands[command_name.to_lower()] = callback
	
	func unregister_command(command_name: String):
		if commands.has(command_name.to_lower()):
			commands.erase(command_name.to_lower())





















func _ready_old_v3():
	setup_window()
	setup_input_handling()
	
	# Connect to task manager if available
	task_manager = get_node_or_null("/root/JSHTaskManager")
	if task_manager:
		print("Text window connected to task manager")
func _ready_old_v2():
	_setup_components()
	_update_display()
	_setup_signals()

func _ready_old():
	setup_window()
	setup_cursor_blink()
	setup_input_handling()
	
	# Connect to task manager if available
	task_manager = get_node_or_null("/root/JSHTaskManager")
	if task_manager:
		print("Chat window connected to task manager")
func _ready_old_v1():
	setup_window()
	setup_input_handling()
	
	# Find integration node or task manager
	find_integration_nodes()
	
	# Send initial signal
	emit_signal("window_focused")


# Process input for the chat window
func _process_old(delta):
	# Process inputs only if focused
	if is_focused:
		process_keyboard_input()
	
	# Update cursor blink
	cursor_blink_time += delta
	if cursor_blink_time >= 1.0:
		cursor_blink_time = 0.0
		cursor_visible = !cursor_visible
	
	cursor.visible = cursor_visible and is_focused
# ===== INITIALIZATION =====



# ===== INTERNAL METHODS =====
func _process_old_v1(delta):
	if is_focused:
		_update_cursor_position()

func _input_old(event):
	if not is_focused:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				unfocus()
			KEY_BACKSPACE:
				if cursor_position > 0:
					input_text = input_text.substr(0, cursor_position - 1) + input_text.substr(cursor_position)
					cursor_position -= 1
					_update_display()
			KEY_DELETE:
				if cursor_position < input_text.length():
					input_text = input_text.substr(0, cursor_position) + input_text.substr(cursor_position + 1)
					_update_display()
			KEY_LEFT:
				if cursor_position > 0:
					cursor_position -= 1
			KEY_RIGHT:
				if cursor_position < input_text.length():
					cursor_position += 1
			KEY_HOME:
				cursor_position = 0
			KEY_END:
				cursor_position = input_text.length()
			KEY_UP:
				_navigate_command_history(true)
			KEY_DOWN:
				_navigate_command_history(false)
			KEY_ENTER, KEY_KP_ENTER:
				_submit_text()
			_:
				# Handle regular character input
				if event.unicode != 0 and event.unicode < 128:
					var char = char(event.unicode)
					input_text = input_text.substr(0, cursor_position) + char + input_text.substr(cursor_position)
					cursor_position += 1
					_update_display()


# Handle input events
func _input_old_v1(event):
	if !is_focused:
		return
	
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_BACKSPACE:
					if cursor_position > 0:
						current_input = current_input.substr(0, cursor_position - 1) + current_input.substr(cursor_position)
						cursor_position -= 1
				KEY_DELETE:
					if cursor_position < current_input.length():
						current_input = current_input.substr(0, cursor_position) + current_input.substr(cursor_position + 1)
				KEY_LEFT:
					cursor_position = max(0, cursor_position - 1)
				KEY_RIGHT:
					cursor_position = min(current_input.length(), cursor_position + 1)
				KEY_HOME:
					cursor_position = 0
				KEY_END:
					cursor_position = current_input.length()
				KEY_ENTER:
					if current_input.strip_edges() != "":
						add_message(current_input)
						emit_signal("message_sent", current_input, "User")
						current_input = ""
						cursor_position = 0
				KEY_UP:
					scroll_messages_up()
				KEY_DOWN:
					scroll_messages_down()
				_:
					if event.unicode >= 32 and event.unicode <= 126:  # Printable ASCII
						var char_to_add = char(event.unicode)
						current_input = current_input.substr(0, cursor_position) + char_to_add + current_input.substr(cursor_position)
						cursor_position += 1
			
			# Reset cursor blink
			cursor_visible = true
			cursor_blink_time = 0
			
			# Update text and cursor
			input_text#.text
			var text# = current_input
			text = current_input
			update_cursor_position()
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_messages_up()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_messages_down()


func _setup_signals_old_v1():
	cursor_timer.timeout.connect(_on_cursor_timer_timeout)
func clear_text_old_v1():
	text_buffer.clear()
	_update_display()

func focus_old_v1():
	is_focused = true
	window_focused.emit()
	_update_display()

func unfocus_old_v1():
	is_focused = false
	window_unfocused.emit()
	_update_display()

func register_command_old_v1(command_name: String, callback: Callable):
	command_processor.register_command(command_name, callback)

# Add a system message
func add_system_message_old_v1(message):
	return add_message(message, "System")









func _cmd_teleport(args: Array) -> Dictionary:
	if args.size() < 3:
		return {"success": false, "message": "Usage: /teleport x y z"}
	
	# Try to parse coordinates
	var coords = Vector3()

	
	return {"success": true, "message": "Teleported to " + str(coords)}

func _cmd_resize(args: Array) -> Dictionary:
	if args.size() < 2:
		return {"success": false, "message": "Usage: /resize width height"}
	
	# Try to parse dimensions
	var width = 0.0
	var height = 0.0

	resize(width, height)
	
	return {"success": true, "message": "Window resized to " + str(width) + "x" + str(height)}

func _cmd_color(args: Array) -> Dictionary:
	if args.size() < 3:
		return {"success": false, "message": "Usage: /color r g b (0-255)"}
	
	# Try to parse color
	var color = Color()

	
	# Update text color
	text_color = color
	text_label.modulate = color
	input_line.modulate = color
	
	return {"success": true, "message": "Text color changed"}

# Handle input events
func setup_input_handling():
	print(" setup input handling ")
	# Nothing needed here as input is handled in _input or by areas

# Handle keyboard input for text entry
func process_keyboard_input():
	print(" some input stuff")
	# We'll implement this in _input

# Handle cursor blinking
func _on_cursor_blink():
	if is_focused:
		cursor_visible = !cursor_visible

func setup_text_window_commands_old(window_node: JSHTextWindow):
	# Register default commands
	#window_node.register_command("help", _cmd_help)
	window_node.register_command("clear", _cmd_clear)
	window_node.register_command("teleport", _cmd_teleport)
	window_node.register_command("resize", _cmd_resize)
	window_node.register_command("color", _cmd_color)

# Set up the cursor blink timer
func setup_cursor_blink():
	# Create a timer for cursor blinking
	var timer = TimerManager.get_timer()
	add_child(timer)
	timer.wait_time = 0.5
	timer.timeout.connect(_on_cursor_blink)
	timer.start()

# Update cursor position based on current input text
func update_cursor_position():
	# This is a simplified approach - ideally you'd measure the text width
	var estimated_char_width = 0.02
	cursor.position = Vector3(
		-DEFAULT_WIDTH/2 + MARGIN*2 + cursor_position * estimated_char_width,
		-DEFAULT_HEIGHT/2 + 0.1 + MARGIN,
		0.003
	)

# Set up reference to main scene
func setup_main_reference(main_ref):
	main_scene_reference = main_ref
	# Refresh materials since we have access to get_spectrum_color now
	if background_mesh and background_mesh.material_override:
		var material = background_mesh.material_override
		material.albedo_color = main_scene_reference.get_spectrum_color(window_color)
		material.albedo_color.a = window_opacity

# Create the main window background
func create_window_background_0():
	background_mesh = MeshInstance3D.new()
	add_child(background_mesh)
	# Create a simple rectangular mesh for the window
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	# Define corners of the window
	var p1 = Vector3(-DEFAULT_WIDTH/2, -DEFAULT_HEIGHT/2, 0)
	var p2 = Vector3(DEFAULT_WIDTH/2, -DEFAULT_HEIGHT/2, 0)
	var p3 = Vector3(DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2, 0)
	var p4 = Vector3(-DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2, 0)
	# Add vertices
	vertices.append(p1)
	vertices.append(p2)
	vertices.append(p3)
	vertices.append(p4)
	# Create triangles
	indices.append(0)
	indices.append(1)
	indices.append(2)
	indices.append(0)
	indices.append(2)
	indices.append(3)
	# Create the mesh
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	background_mesh.mesh = arr_mesh
	# Create material
	var material = MaterialLibrary.get_material("default")
	if csharp_integration and csharp_integration.has_method("GetSpectrumColor"):
		material.albedo_color = csharp_integration.GetSpectrumColor(window_color)
	elif main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
		material.albedo_color = main_scene_reference.get_spectrum_color(window_color)
	else:
		material.albedo_color = Color(0.2, 0.2, 0.3, window_opacity)
	material.albedo_color.a = window_opacity
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	background_mesh.material_override = material
	# Add collision
	add_window_collision()

# Create the title bar at the top of the window
func create_title_bar_0():
	title_bar = MeshInstance3D.new()
	add_child(title_bar)
	# Create a rectangular mesh for the title bar
	var bar_height = 0.15
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	# Define corners of the title bar
	var p1 = Vector3(-DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2 - bar_height, 0.001)
	var p2 = Vector3(DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2 - bar_height, 0.001)
	var p3 = Vector3(DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2, 0.001)
	var p4 = Vector3(-DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2, 0.001)
	# Add vertices
	vertices.append(p1)
	vertices.append(p2)
	vertices.append(p3)
	vertices.append(p4)
	# Create triangles
	indices.append(0)
	indices.append(1)
	indices.append(2)
	indices.append(0)
	indices.append(2)
	indices.append(3)
	# Create the mesh
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	title_bar.mesh = arr_mesh
	# Create material with a slightly different color
	var material = MaterialLibrary.get_material("default")
	if csharp_integration and csharp_integration.has_method("GetSpectrumColor"):
		material.albedo_color = csharp_integration.GetSpectrumColor(window_color + 0.1)
	elif main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
		material.albedo_color = main_scene_reference.get_spectrum_color(window_color + 0.1)
	else:
		material.albedo_color = Color(0.25, 0.25, 0.35, window_opacity)
	material.albedo_color.a = window_opacity
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	title_bar.material_override = material
	# Add title text
	title_label = Label3D.new()
	add_child(title_label)
	title_label.text = window_title
	title_label.font_size = font_size
	title_label.modulate = text_color
	title_label.position = Vector3(0, DEFAULT_HEIGHT/2 - bar_height/2, 0.002)
	title_label.no_depth_test = true
# Create the message display area
func create_message_area():
	message_container = Node3D.new()
	message_container.name = "MessageContainer"
	add_child(message_container)
	# Calculate message area dimensions
	var input_height = 0.2
	var title_height = 0.15
	var message_area_height = DEFAULT_HEIGHT - title_height - input_height - MARGIN * 3
	# Position the container
	message_container.position = Vector3(
		0, 
		DEFAULT_HEIGHT/2 - title_height - message_area_height/2 - MARGIN,
		0.002
	)
# Create the input field at the bottom
func create_input_field():
	input_field = Node3D.new()
	input_field.name = "InputField"
	add_child(input_field)
	# Create background for input field
	var input_mesh = MeshInstance3D.new()
	FloodgateController.universal_add_child(input_mesh, input_field)
	var input_height = 0.2
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	# Define corners of the input field
	var p1 = Vector3(-DEFAULT_WIDTH/2 + MARGIN, -DEFAULT_HEIGHT/2 + MARGIN, 0.001)
	var p2 = Vector3(DEFAULT_WIDTH/2 - MARGIN, -DEFAULT_HEIGHT/2 + MARGIN, 0.001)
	var p3 = Vector3(DEFAULT_WIDTH/2 - MARGIN, -DEFAULT_HEIGHT/2 + input_height + MARGIN, 0.001)
	var p4 = Vector3(-DEFAULT_WIDTH/2 + MARGIN, -DEFAULT_HEIGHT/2 + input_height + MARGIN, 0.001)
	# Add vertices
	vertices.append(p1)
	vertices.append(p2)
	vertices.append(p3)
	vertices.append(p4)
	# Create triangles
	indices.append(0)
	indices.append(1)
	indices.append(2)
	indices.append(0)
	indices.append(2)
	indices.append(3)
	# Create the mesh
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	input_mesh.mesh = arr_mesh
	# Create material with a slightly different color
	var material = MaterialLibrary.get_material("default")
	if main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
		material.albedo_color = main_scene_reference.get_spectrum_color(window_color - 0.1)
	else:
		material.albedo_color = Color(0.15, 0.15, 0.25, window_opacity)
	material.albedo_color.a = window_opacity
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	input_mesh.material_override = material
	# Add text label for input
	var input_text
	input_text = Label3D.new()
	FloodgateController.universal_add_child(input_text, input_field)
	input_text.text = ""
	input_text.font_size = font_size
	input_text.modulate = text_color
	input_text.position = Vector3(-DEFAULT_WIDTH/2 + MARGIN*2, -DEFAULT_HEIGHT/2 + input_height/2 + MARGIN, 0.002)
	input_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	input_text.width = DEFAULT_WIDTH - MARGIN*4
	input_text.no_depth_test = true
	# Create cursor
	cursor = MeshInstance3D.new()
	FloodgateController.universal_add_child(cursor, input_field)
	var cursor_mesh = QuadMesh.new()
	cursor_mesh.size = Vector2(0.01, input_height * 0.7)
	cursor.mesh = cursor_mesh
	var cursor_material = MaterialLibrary.get_material("default")
	cursor_material.albedo_color = text_color
	cursor_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	cursor_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	cursor.material_override = cursor_material
	# Position cursor at beginning of input field
	update_cursor_position()
# Update the message display
func update_message_display():
	# Clear existing messages
	for child in message_container.get_children():
		child.queue_free()
	# Calculate message area dimensions
	var input_height = 0.2
	var title_height = 0.15
	var message_area_height = DEFAULT_HEIGHT - title_height - input_height - MARGIN * 3
	var message_area_width = DEFAULT_WIDTH - MARGIN * 4
	# Maximum visible messages that can fit in the area
	var line_height = 0.07
	var max_visible = int(message_area_height / line_height)
	# Calculate which messages to show based on scroll offset
	var messages
	var start_index = max(0, messages.size() - max_visible - scroll_offset)
	var end_index = min(messages.size(), start_index + max_visible)
	# Create labels for visible messages
	for i in range(start_index, end_index):
		var message = messages[i]
		var msg_text = "[%s] %s: %s" % [message.timestamp, message.sender, message.text]
		var label = Label3D.new()
		FloodgateController.universal_add_child(label, message_container)
		label.text = msg_text
		label.font_size = font_size - 2
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.width = message_area_width
		label.no_depth_test = true
		# Color code by sender
		match message.sender:
			"System":
				label.modulate = Color(0.5, 0.8, 1, 1)
			"Task Manager":
				label.modulate = Color(0.8, 0.8, 0.2, 1)
			_:
				label.modulate = text_color
		# Position vertically in the message container
		var rel_index = i - start_index
		label.position = Vector3(
			-DEFAULT_WIDTH/2 + MARGIN*2,
			message_area_height/2 - rel_index * line_height - line_height/2,
			0
		)





























































	
	#func execute_command(name: String, args: Array) -> Dictionary:
		#var command_name = name.to_lower()
		#
		#if not commands.has(command_name):
			#return {"success": false, "message": "Unknown command: " + name}
		#
		#var callback = commands[command_name]
		#
		## Execute the command and return result
		#var result
		#try:
			#result = callback.call(args)
			## If the command returns nothing, assume success
			#if result == null:
				#return {"success": true, "message": "Command executed successfully"}
			#
			## If the command returns a dictionary with success/message, use that
			#if result is Dictionary and result.has("success"):
				#return result
				#
			## Otherwise wrap the result
			#return {"success": true, "message": str(result)}
		#except Exception as e:
			#return {"success": false, "message": "Error executing command: " + str(e)}



## ===== WINDOW INTERACTION FUNCTIONS =====
#func _on_window_input_event(camera, event, position, normal, shape_idx):
	#if event is InputEventMouseButton:
		#if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			## Check for title bar drag
			#if position.y > DEFAULT_HEIGHT/2 - 0.15:
				#if can_be_dragged:
					#is_dragging = true
					#drag_start_position = position
					#window_initial_position = global_position
			#
			## Focus the window
			#is_focused = true
			#emit



	#func execute_command(name: String, args: Array) -> Dictionary:
		#var command_name = name.to_lower()
		#
		#if not commands.has(command_name):
			#return {"success": false, "message": "Unknown command: " + name}
		#
		#var callback = commands[command_name]
		#
		## Execute the command and return result
		#var result
		#try:
			#result = callback.call(args)
			## If the command returns nothing, assume success
			#if result == null:
				#return {"success": true, "message": "Command executed successfully"}
			#
			## If the command returns a dictionary with success/message, use that
			#if result is Dictionary and result.has("success"):
				#return result
				#
			## Otherwise wrap the result
			#return {"success": true, "message": str(result)}
		#except Exception as e:
			#return {"success": false, "message": "Error executing command: " + str(e)}

#func _cmd_teleport(args: Array) -> Dictionary:
	#if args.size() < 3:
		#return {"success": false, "message": "Usage: /teleport x y z"}
	#
	## Try to parse coordinates
	#var coords = Vector3()
	#try:
		#coords.x = float(args[0])
		#coords.y = float(args[1])
		#coords.z = float(args[2])
	#except:
		#return {"success": false, "message": "Invalid coordinates"}
	#
	## Implementation would interact with your existing system
	## Example: main_node.first_dimensional_magic("move_camera", coords)
	#
	#return {"success": true, "message": "Teleported to " + str(coords)}
#
#func _cmd_resize(args: Array) -> Dictionary:
	#if args.size() < 2:
		#return {"success": false, "message": "Usage: /resize width height"}
	#
	## Try to parse dimensions
	#var width = 0.0
	#var height = 0.0
	#try:
		#width = float(args[0])
		#height = float(args[1])
	#except:
		#return {"success": false, "message": "Invalid dimensions"}
	#
	## Resize the window
	#resize(width, height)
	#
	#return {"success": true, "message": "Window resized to " + str(width) + "x" + str(height)}
#
#func _cmd_color(args: Array) -> Dictionary:
	#if args.size() < 3:
		#return {"success": false, "message": "Usage: /color r g b (0-255)"}
	#
	## Try to parse color
	#var color = Color()
	#try:
		#color.r = float(args[0]) / 255.0
		#color.g = float(args[1]) / 255.0
		#color.b = float(args[2]) / 255.0
	#except:
		#return {"success": false, "message": "Invalid color values"}
	#
	## Update text color
	#text_color = color
	#text_label.modulate = color
	#input_line.modulate = color
	#
	#return {"success": true, "message": "Text color changed"}


























## global stuff
#extends UniversalBeingBase
#class_name JSHTextWindow
#
##extends UniversalBeingBase
##class_name JSHTextWindow
#
## ===== CONFIGURABLE PROPERTIES =====
#@export var window_width := 4.0
#@export var window_height := 3.0
#@export var text_margin := 0.1
#@export var max_visible_lines := 10
#@export var font_size := 24
#@export var text_color := Color(0.9, 0.9, 0.9, 1.0)
#@export var background_color := Color(0.1, 0.1, 0.15, 0.8)
#@export var border_color := Color(0.3, 0.5, 0.8, 1.0)
#@export var border_width := 0.05
#@export var command_prefix := "/"
#
## ===== CONSTANTS =====
#const DEFAULT_WIDTH = 2.0
#const DEFAULT_HEIGHT = 1.5
#const MARGIN = 0.05
#const FADE_TIME = 0.5
#const MAX_MESSAGES = 50
#
## ===== INTERNAL REFERENCES =====
#var window_mesh: MeshInstance3D
#var background_mesh: MeshInstance3D
#var title_bar: MeshInstance3D
#var title_label: Label3D
#var text_label: Label3D
#var input_line: Label3D
#var cursor: MeshInstance3D
#var cursor_timer: Timer
#var command_processor: CommandProcessor
#var text_container: Node3D
#var content_label: Label3D
#var content_text: TextMesh
#var scroll_up_button: Node3D
#var scroll_down_button: Node3D
#var close_button: Node3D
#var minimize_button: Node3D
#var message_container: Node3D
#var input_field: Node3D
#
## ===== INTERNAL STATE =====
#var text_buffer := []
#var input_text := ""
#var cursor_position := 0
#var cursor_visible := true
#var is_focused := false
#var command_history := []
#var command_history_index := -1
#var window_title = "JSH Text Viewer"
#var window_color = 0.4  # Color index for get_spectrum_color
#var window_opacity = 0.8
#var is_minimized = false
#var can_be_dragged = true
#var can_be_edited = false
#var supports_links = true
#var auto_scroll = true
#var full_text = ""
#var formatted_text = []
#var scroll_offset = 0
#var is_dragging = false
#var drag_start_position = Vector3.ZERO
#var window_initial_position = Vector3.ZERO
#var visible_lines = 0
#var total_lines = 0
#var links = {}
#var lines = []
#var cursor_blink_time = 0.0
#var current_input
#
## ===== INTEGRATION REFERENCES =====
#var main_scene_reference = null
#var task_manager = null
#var csharp_integration = null
#
## ===== SIGNALS =====
#signal window_closed
#signal window_focused
#signal window_unfocused
#signal window_resized(new_size)
#signal text_updated(new_text)
#signal link_clicked(link_id)
#signal command_executed(command: String, args: Array)
#signal text_submitted(text: String)
#signal message_sent(message, sender)
#
## ===== COMMAND PROCESSOR CLASS =====
#class CommandProcessor:
	#extends UniversalBeingBase
	#
	#var commands = {}
	#
	#func register_command(name: String, callback: Callable):
		#commands[name.to_lower()] = callback
	#
	#func unregister_command(name: String):
		#if commands.has(name.to_lower()):
			#commands.erase(name.to_lower())
	#
## ===== INITIALIZATION =====
#func _ready():
	#_setup_components()
	#_update_display()
	#_setup_signals()
	#
	## Find integration node or task manager
	#find_integration_nodes()
	#
	## Send initial signal
	#emit_signal("window_focused")



#var is_minimized = false#var can_be_dragged = true
#var can_be_edited = false
#var supports_links = true
#var auto_scroll = true

#
#
#@export var window_width := 4.0
#@export var window_height := 3.0
#@export var text_margin := 0.1
#@export var max_visible_lines := 10
#@export var font_size := 24
#@export var text_color := Color(0.9, 0.9, 0.9, 1.0)
#@export var background_color := Color(0.1, 0.1, 0.15, 0.8)
#@export var border_color := Color(0.3, 0.5, 0.8, 1.0)
#@export var border_width := 0.05
#@export var command_prefix := "/"
#
## ===== INTERNAL REFERENCES =====
#var window_mesh: MeshInstance3D
#var text_label: Label3D
#var input_line: Label3D
#var cursor: MeshInstance3D
#var cursor_timer: Timer
#var command_processor: CommandProcessor
#
## ===== INTERNAL STATE =====
#var text_buffer := []
#var input_text := ""
#var cursor_position := 0
#var cursor_visible := true
#var is_focused := false
#var command_history := []
#var command_history_index := -1
#
#
#
## Signals
#signal window_closed
#signal window_focused
#signal window_resized(new_size)
#signal text_updated(new_text)
#signal link_clicked(link_id)
#
## Constants
#const DEFAULT_WIDTH = 2.0
#const DEFAULT_HEIGHT = 1.5
#const MARGIN = 0.05
#const FADE_TIME = 0.5
#
## Window properties
#var window_title = "JSH Text Viewer"
#var window_color = 0.4  # Color index for get_spectrum_color
#var window_opacity = 0.8	#try:
		#color.r = float(args[0]) / 255.0
		#color.g = float(args[1]) / 255.0
		#color.b = float(args[2]) / 255.0
	#except:
		#return {"success": false, "message": "Invalid color values"}	#try:
		#width = float(args[0])
		#height = float(args[1])
	#except:
		#return {"success": false, "message": "Invalid dimensions"}
	
	# Resize the window	#try:
		#coords.x = float(args[0])
		#coords.y = float(args[1])
		#coords.z = float(args[2])
	#except:
		#return {"success": false, "message": "Invalid coordinates"}
	
	# Implementation would interact with your existing system
	# Example: main_node.first_dimensional_magic("move_camera", coords)	
	#func execute_command(name: String, args: Array) -> Dictionary:
		#var command_name = name.to_lower()
		#
		#if not commands.has(command_name):
			#return {"success": false, "message": "Unknown command: " + name}
		#
		#var callback = commands[command_name]
		#
		## Execute the command and return result
		#var result
		#try:
			#result = callback.call(args)
			# If the command returns nothing, assume success
			#if result == null:
				#return {"success": true, "message": "Command executed successfully"}
			#
			## If the command returns a dictionary with success/message, use that
			#if result is Dictionary and result.has("success"):
				#return result
				#
			## Otherwise wrap the result
			#return {"success": true, "message": str(result)}
		#except Exception as e:
			#return {"success": false, "message": "Error executing command: " + str(e)}#var background_mesh: MeshInstance3D
#var title_bar: MeshInstance3D
#var title_label: Label3D
#var text_container: Node3D
#var content_label: Label3D
#var scroll_up_button: Node3D
#var scroll_down_button: Node3D
#var close_button: Node3D
#var minimize_button: Node3D

## Text state
#var full_text = ""
#var formatted_text = []
#var scroll_offset = 0
#var is_dragging = false
#var drag_start_position = Vector3.ZERO
#var window_initial_position = Vector3.ZERO
#var visible_lines = 0
#var total_lines = 0
#var links = {}
#
## C# integration
#var csharp_integration = null
#var task_manager = null
#
## ===== SIGNALS =====
#signal command_executed(command: String, args: Array)
#signal text_submitted(text: String)#signal window_unfocused	
	#func execute_command(name: String, args: Array) -> Dictionary:
		#var command_name = name.to_lower()
		#
		#if not commands.has(command_name):
			#return {"success": false, "message": "Unknown command: " + name}
		#
		#var callback = commands[command_name]
		#
		## Execute the command and return result
		#var result
		#try:
			#result = callback.call(args)
			## If the command returns nothing, assume success
			#if result == null:
				#return {"success": true, "message": "Command executed successfully"}
			#
			## If the command returns a dictionary with success/message, use that
			#if result is Dictionary and result.has("success"):
				#return result
				#
			## Otherwise wrap the result
			#return {"success": true, "message": str(result)}
		#except Exception as e:
			#return {"success": false, "message": "Error executing command: " + str(e)}




##### some older additions







# Signals
#signal window_closed
#signal window_focused
#signal window_resized(new_size)
#signal text_updated(new_text)
#
## Constants
#const DEFAULT_WIDTH = 2.0
#const DEFAULT_HEIGHT = 1.5
#const MARGIN = 0.05
#const FADE_TIME = 0.5
#
## Window properties
#var window_title = "JSH Text Viewer"
#var window_color = 0.4  # Color index for get_spectrum_color
#var window_opacity = 0.8
#var text_color = Color(1, 1, 1, 1)
#var font_size = 16
#var is_minimized = false
#var is_focused = false
#var can_be_dragged = true
#var can_be_edited = false

## References to nodes
#var window_mesh: MeshInstance3D
#var background_mesh: MeshInstance3D
#var title_bar: MeshInstance3D
#var title_label: Label3D
#var text_container: Node3D#var close_button: Node3D
#var minimize_button: Node3D
#var scroll_up_button: Node3D
#var scroll_down_button: Node3D
#
## Text state
#var full_text = ""
#var scroll_offset = 0
#var is_dragging = false
#var drag_start_position = Vector3.ZERO
#var window_initial_position = Vector3.ZERO
#var lines = []
#var visible_lines = 0

# Creation references
#var main_scene_reference = null
#var task_manager = null

#extends UniversalBeingBase
#class_name JSHChatWindow

# Signals
#signal message_sent(message, sender)
#signal window_closed
#signal window_focused
#signal window_resized(new_size)

# Constants
#const DEFAULT_WIDTH = 2.0
#const DEFAULT_HEIGHT = 1.5
#const MARGIN = 0.05
#const MAX_MESSAGES = 50
#const FADE_TIME = 0.5

# Chat window properties
#var window_title = "JSH Chat"
#var window_color = 0.3  # Color index for get_spectrum_color
#var window_opacity = 0.8
#var text_color = Color(1, 1, 1, 1)
#var font_size = 16
#var is_minimized = false
#var is_focused = false
#var can_be_dragged = true
#var auto_scroll = true

# References to nodes
#var window_mesh: MeshInstance3D
#var background_mesh: MeshInstance3D
#var title_bar: MeshInstance3D
#var title_label: Label3D
#var message_container: Node3D
#var input_field: Node3D
#var input_text: Label3D
#var cursor: MeshInstance3D
#var close_button: Node3D
#var minimize_button: Node3D
#var scroll_up_button: Node3D
#var scroll_down_button: Node3D

# Chat state
#var messages = []
#var current_input = ""
#var cursor_position = 0
#var cursor_visible = true
#v#ar cursor_blink_time = 0.0
#var scroll_offset = 0
#var is_dragging = false
#var drag_start_position = Vector3.ZERO
#var window_initial_position = Vector3.ZERO

# Creation references
#var main_scene_reference = null
#var task_manager = null
# Try to parse coordinates	#try:
		#coords.x = float(args[0])
		#coords.y = float(args[1])
		#coords.z = float(args[2])
	#except:
		#return {"success": false, "message": "Invalid coordinates"}
	
	# Implementation would interact with your existing system
	# Example: main_node.first_dimensional_magic("move_camera", coords)
		#try:
		#width = float(args[0])
		#height = float(args[1])
	#except:
		#return {"success": false, "message": "Invalid dimensions"}
	
	# Implementation would resize the window
	# This would be handled by the window instance itself
		#try:
		#color.r = float(args[0]) / 255.0
		#color.g = float(args[1]) / 255.0
		#color.b = float(args[2]) / 255.0
	#except:
		#return {"success": false, "message": "Invalid color values"}
	
	# Implementation would change the text color
	# This would be handled by the window instance itself# text_screen.gd in scripts folder
# not on node yet
# similar is line script

## some new additions :


#extends UniversalBeingBase
#class_name JSHTextWindow








#extends UniversalBeingBase
#class_name JSHTextWindow






#class_name TextWindowSystem
#extends UniversalBeingBase
# ===== CONFIGURABLE PROPERTIES =====

#
#var content_text: TextMesh
#
## ===== CONFIGURABLE PROPERTIES =====
#@export var window_width := 4.0
#@export var window_height := 3.0
#@export var text_margin := 0.1
#@export var max_visible_lines := 10
#@export var font_size := 24
#@export var text_color := Color(0.9, 0.9, 0.9, 1.0)
#@export var background_color := Color(0.1, 0.1, 0.15, 0.8)
#@export var border_color := Color(0.3, 0.5, 0.8, 1.0)
#@export var border_width := 0.05
#@export var command_prefix := "/"
#
## ===== CONSTANTS =====
#const DEFAULT_WIDTH = 2.0
#const DEFAULT_HEIGHT = 1.5
#const MARGIN = 0.05
#const FADE_TIME = 0.5
#const MAX_MESSAGES = 50
#
## ===== INTERNAL REFERENCES =====
#var window_mesh: MeshInstance3D
#var background_mesh: MeshInstance3D
#var title_bar: MeshInstance3D
#var title_label: Label3D
#var text_label: Label3D
#var input_line: Label3D
#var cursor: MeshInstance3D
#var cursor_timer: Timer
#var command_processor: CommandProcessor
#var text_container: Node3D
#var content_label: Label3D
#var scroll_up_button: Node3D
#var scroll_down_button: Node3D
#var close_button: Node3D
#var minimize_button: Node3D
#var message_container: Node3D
#var input_field: Node3D
#
## ===== INTERNAL STATE =====
#var text_buffer := []
#var input_text := ""
#var cursor_position := 0
#var cursor_visible := true
#var is_focused := false
#var command_history := []
#var command_history_index := -1
#var window_title = "JSH Text Viewer"
#var window_color = 0.4  # Color index for get_spectrum_color
#var window_opacity = 0.8
#var is_minimized = false
#var can_be_dragged = true
#var can_be_edited = false
#var supports_links = true
#var auto_scroll = true
#var full_text = ""
#var formatted_text = []
#var scroll_offset = 0
#var is_dragging = false
#var drag_start_position = Vector3.ZERO
#var window_initial_position = Vector3.ZERO
#var visible_lines = 0
#var total_lines = 0
#var links = {}
#var lines = []
#var cursor_blink_time = 0.0
#
## ===== INTEGRATION REFERENCES =====
#var main_scene_reference = null
#var task_manager = null
#var csharp_integration = null
#var current_input
## ===== SIGNALS =====
#signal window_closed
#signal window_focused
#signal window_unfocused
#signal window_resized(new_size)
#signal text_updated(new_text)
#signal link_clicked(link_id)
#signal command_executed(command: String, args: Array)
#signal text_submitted(text: String)
#signal message_sent(message, sender)
#
## ===== COMMAND PROCESSOR CLASS =====
#class CommandProcessor:
	#extends UniversalBeingBase
	#
	#var commands = {}
	#
	#func register_command(name: String, callback: Callable):
		#commands[name.to_lower()] = callback
	#
	#func unregister_command(name: String):
		#if commands.has(name.to_lower()):
			#commands.erase(name.to_lower())

#
#
### godot functions
## ===== INITIALIZATION =====
#func _ready():
	#_setup_components()
	#_update_display()
	#_setup_signals()
	## Find integration node or task manager
	#find_integration_nodes()
	## Send initial signal
	#emit_signal("window_focused")
# Main setup function
#
## ===== INPUT HANDLING =====
#func _process(delta):
	#if is_focused:
		#_update_cursor_position()

#
#func _input(event):
	#if not is_focused:
		#return
		#
	#if event is InputEventKey and event.pressed:
		#match event.keycode:
			#KEY_ESCAPE:
				#unfocus()
			#KEY_BACKSPACE:
				#if cursor_position > 0:
					#input_text = input_text.substr(0, cursor_position - 1) + input_text.substr(cursor_position)
					#cursor_position -= 1
					#_update_display()
			#KEY_DELETE:
				#if cursor_position < input_text.length():
					#input_text = input_text.substr(0, cursor_position) + input_text.substr(cursor_position + 1)
					#_update_display()
			#KEY_LEFT:
				#if cursor_position > 0:
					#cursor_position -= 1
			#KEY_RIGHT:
				#if cursor_position < input_text.length():
					#cursor_position += 1
			#KEY_HOME:
				#cursor_position = 0
			#KEY_END:
				#cursor_position = input_text.length()
			#KEY_UP:
				#_navigate_command_history(true)
			#KEY_DOWN:
				#_navigate_command_history(false)
			#KEY_ENTER, KEY_KP_ENTER:
				#_submit_text()
			#_:
				## Handle regular character input
				#if event.unicode != 0 and event.unicode < 128:
					#var char = char(event.unicode)
					#input_text = input_text.substr(0, cursor_position) + char + input_text.substr(cursor_position)
					#cursor_position += 1
					#_update_display()



#func setup_window():
	## Create window background
	#create_window_background()
	#
	## Create title bar
	#create_title_bar()
	#
	## Create text display area
	#create_text_area()
	#
	## Create control buttons
	#create_control_buttons()
	#
	## Add initial welcome text
	#set_text("JSH Text Window System\n\nUse this window to display important information to the user.")
#

## old godot mains? similars too?


#
#
#









#
### new things
#
#func _setup_components():
	## Create window background
	#window_mesh = MeshInstance3D.new()
	#var window_material = MaterialLibrary.get_material("default")
	#window_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#window_material.albedo_color = background_color
	#
	#var window_shape = BoxMesh.new()
	#window_shape.size = Vector3(window_width, window_height, 0.01)
	#window_mesh.mesh = window_shape
	#window_mesh.material_override = window_material
	#add_child(window_mesh)
	#
	## Create border (using multiple quads for simplicity)
	#_create_border()
	#
	## Create text display
	#text_label = Label3D.new()
	#text_label.text = ""
	#text_label.font_size = font_size
	#text_label.modulate = text_color
	#text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	#text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	#text_label.width = window_width - (text_margin * 2)
	#text_label.position = Vector3(-window_width/2 + text_margin, window_height/2 - text_margin, 0.011)
	#add_child(text_label)
	#
	## Create input line
	#input_line = Label3D.new()
	#input_line.text = ""
	#input_line.font_size = font_size
	#input_line.modulate = text_color
	#input_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	#input_line.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	#input_line.width = window_width - (text_margin * 2)
	#input_line.position = Vector3(-window_width/2 + text_margin, -window_height/2 + text_margin, 0.011)
	#add_child(input_line)
	#
	## Create cursor
	#cursor = MeshInstance3D.new()
	#var cursor_mesh = BoxMesh.new()
	#cursor_mesh.size = Vector3(0.05, 0.05, 0.01)
	#cursor.mesh = cursor_mesh
	#cursor.material_override = window_material.duplicate()
	#cursor.material_override.albedo_color = text_color
	#cursor.position = Vector3(-window_width/2 + text_margin, -window_height/2 + text_margin, 0.012)
	#add_child(cursor)
	#
	## Setup cursor blinking timer
	#cursor_timer = TimerManager.get_timer()
	#cursor_timer.wait_time = 0.5
	#cursor_timer.autostart = true
	#add_child(cursor_timer)
	#
	## Initialize command processor
	#command_processor = CommandProcessor.new()
	#add_child(command_processor)
	#
	## Set up control buttons
	#create_control_buttons()
#
#func _create_border():
	## Top border
	#var top_border = MeshInstance3D.new()
	#var top_mesh = BoxMesh.new()
	#top_mesh.size = Vector3(window_width, border_width, 0.015)
	#top_border.mesh = top_mesh
	#top_border.position = Vector3(0, window_height/2, 0.005)
	#
	## Bottom border
	#var bottom_border = MeshInstance3D.new()
	#var bottom_mesh = BoxMesh.new()
	#bottom_mesh.size = Vector3(window_width, border_width, 0.015)
	#bottom_border.mesh = bottom_mesh
	#bottom_border.position = Vector3(0, -window_height/2, 0.005)
	#
	## Left border
	#var left_border = MeshInstance3D.new()
	#var left_mesh = BoxMesh.new()
	#left_mesh.size = Vector3(border_width, window_height, 0.015)
	#left_border.mesh = left_mesh
	#left_border.position = Vector3(-window_width/2, 0, 0.005)
	#
	## Right border
	#var right_border = MeshInstance3D.new()
	#var right_mesh = BoxMesh.new()
	#right_mesh.size = Vector3(border_width, window_height, 0.015)
	#right_border.mesh = right_mesh
	#right_border.position = Vector3(window_width/2, 0, 0.005)
	#
	## Create border material
	#var border_material = MaterialLibrary.get_material("default")
	#border_material.albedo_color = border_color
	#
	## Apply material and add borders
	#top_border.material_override = border_material
	#bottom_border.material_override = border_material
	#left_border.material_override = border_material
	#right_border.material_override = border_material
	#
	#add_child(top_border)
	#add_child(bottom_border)
	#add_child(left_border)
	#add_child(right_border)
#
#func _setup_signals():
	#cursor_timer.timeout.connect(_on_cursor_timer_timeout)
#
#func find_integration_nodes():
	## Try to find C# integration node
	#csharp_integration = get_node_or_null("/root/JSHSystemIntegration")
	#
	## Find task manager if not already set
	#if not task_manager:
		#task_manager = get_node_or_null("/root/JSHTaskManager")
		#if task_manager and task_manager.has_method("track_data_flow"):
			#task_manager.track_data_flow(
				#"TextWindow", 
				#window_title, 
				#"window_opened", 
				#1.0
			#)
#
## ===== USER INTERACTION =====
#func _submit_text():
	#if input_text.strip_edges() == "":
		#return
		#
	## Add the submitted text to the buffer
	#add_text("> " + input_text)
	#
	## Add to command history
	#command_history.push_front(input_text)
	#if command_history.size() > 20:  # Limit history size
		#command_history.pop_back()
	#command_history_index = -1
	#
	## Process as command if it starts with the command prefix
	#if input_text.begins_with(command_prefix):
		#_process_command(input_text.substr(command_prefix.length()))
	#else:
		#text_submitted.emit(input_text)
	#
	## Clear input line
	#input_text = ""
	#cursor_position = 0
	#_update_display()
#
#func _navigate_command_history(up: bool):
	#if command_history.is_empty():
		#return
		#
	#if up:
		## Move back in history
		#if command_history_index < command_history.size() - 1:
			#command_history_index += 1
			#input_text = command_history[command_history_index]
			#cursor_position = input_text.length()
			#_update_display()
	#else:
		## Move forward in history
		#if command_history_index > 0:
			#command_history_index -= 1
			#input_text = command_history[command_history_index]
			#cursor_position = input_text.length()
			#_update_display()
		#elif command_history_index == 0:
			#command_history_index = -1
			#input_text = ""
			#cursor_position = 0
			#_update_display()
#
#func _update_cursor_position():
	## Calculate cursor position based on the text up to cursor_position
	#var font = text_label.font
	#var partial_text = input_text.substr(0, cursor_position)
	#
	## Approximate cursor position based on character count
	## This is a simplified approach - for a more accurate one, you'd need to measure text width
	#var char_width = 0.04  # Approximate character width in 3D units
	#var x_offset = ("> ".length() + partial_text.length()) * char_width
	#
	#cursor.position = Vector3(-window_width/2 + text_margin + x_offset, -window_height/2 + text_margin, 0.012)
#
#func _process_command(command_text: String):
	#var parts = command_text.strip_edges().split(" ", false)
	#if parts.size() == 0:
		#return
		#
	#var command_name = parts[0]
	#var args = parts.slice(1)
	#
	#var result = command_processor.execute_command(command_name, args)
	#if not result.success:
		#add_text("Error: " + result.message)
	#
	#command_executed.emit(command_name, args)
#
#func _on_cursor_timer_timeout():
	#cursor_visible = !cursor_visible
	#cursor.visible = cursor_visible and is_focused
#
## ===== DISPLAY MANAGEMENT =====
#func _update_display():
	## Update main text area
	#text_label.text = "\n".join(text_buffer)
	#
	## Update input line with cursor
	#var display_text = input_text
	#if is_focused:
		#input_line.text = "> " + display_text
	#else:
		#input_line.text = ""
		#
	## Update border color based on focus state
	#_update_border_color()
#
#func _update_border_color():
	#for i in range(1, 5):  # Skip the window_mesh at index 0
		#var border = get_child(i)
		#if border is MeshInstance3D and border != window_mesh and border != text_label and border != input_line:
			#var material = border.material_override
			#if material:
				#if is_focused:
					#material.albedo_color = Color(0.4, 0.7, 1.0)
				#else:
					#material.albedo_color = border_color
#
## ===== PUBLIC API =====
#func add_text(text: String):
	#text_buffer.append(text)
	#if text_buffer.size() > max_visible_lines:
		#text_buffer.remove_at(0)
	#_update_display()
#
#func clear_text():
	#text_buffer.clear()
	#_update_display()
#
#func focus():
	#is_focused = true
	#window_focused.emit()
	#_update_display()
#
#func unfocus():
	#is_focused = false
	#window_unfocused.emit()
	#_update_display()
#
#func register_command(command_name: String, callback: Callable):
	#command_processor.register_command(command_name, callback)
#
#func resize(new_width, new_height):
	## We would need to recreate or rescale all meshes
	#window_width = new_width
	#window_height = new_height
	#
	## This would involve recreating the meshes with new dimensions
	## For now just emit the signal
	#emit_signal("window_resized", Vector2(new_width, new_height))
#
#func set_text(text_content, format_links = true):
	#full_text = text_content
	#total_lines = text_content.count("\n") + 1
	#
	## Track data in task manager
	#if task_manager and task_manager.has_method("track_data_flow"):
		#task_manager.track_data_flow(
			#"TextWindow", 
			#window_title, 
			#"text_updated", 
			#text_content.length()
		#)
	#
	## Process any links in the text if enabled
	#if supports_links and format_links:
		#process_text_links()
	#else:
		#content_label.text = full_text
	#
	## Update scroll position
	#if auto_scroll:
		#scroll_offset = max(0, total_lines - visible_lines)
		#update_text_display()
	#else:
		#update_text_display()
	#
	#emit_signal("text_updated", full_text)
#
#func update_text_display():
	## Implementation for updating text display
	## This would update the content_label with the right portion of text
	## based on scroll_offset
	#pass
#
#func process_text_links():
	## Placeholder for processing text links
	## This would parse links from the full_text and update the links dictionary
	#pass
#
## ===== UI ELEMENTS =====
#func create_control_buttons():
	## Close button
	#close_button = create_button(
		#"CloseButton",
		#Vector3(window_width/2 - MARGIN*2, window_height/2 - MARGIN*1.5, 0.002),
		#Vector2(0.1, 0.1),
		#Color(1, 0.3, 0.3, 1),
		#"X"
	#)
	#
	## Minimize button
	#minimize_button = create_button(
		#"MinimizeButton",
		#Vector3(window_width/2 - MARGIN*4, window_height/2 - MARGIN*1.5, 0.002),
		#Vector2(0.1, 0.1),
		#Color(0.3, 0.7, 1, 1),
		#"-"
	#)
	#
	## Scroll buttons
	#scroll_up_button = create_button(
		#"ScrollUpButton",
		#Vector3(window_width/2 - MARGIN*2, 0, 0.002),
		#Vector2(0.1, 0.1),
		#Color(0.7, 0.7, 0.7, 1),
		#"↑"
	#)
	#
	#scroll_down_button = create_button(
		#"ScrollDownButton",
		#Vector3(window_width/2 - MARGIN*2, -window_height/2 + MARGIN*4, 0.002),
		#Vector2(0.1, 0.1),
		#Color(0.7, 0.7, 0.7, 1),
		#"↓"
	#)
#
#func create_button(name, position, size, color, label_text):
	#var button = Node3D.new()
	#button.name = name
	#add_child(button)
	#
	## Create button background
	#var button_mesh = MeshInstance3D.new()
	#FloodgateController.universal_add_child(button_mesh, button)
	#
	#var quad_mesh = QuadMesh.new()
	#quad_mesh.size = size
	#button_mesh.mesh = quad_mesh
	#
	#var material = MaterialLibrary.get_material("default")
	#material.albedo_color = color
	#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	#material.cull_mode = BaseMaterial3D.CULL_DISABLED
	#button_mesh.material_override = material
	#
	## Add label
	#var text = Label3D.new()
	#FloodgateController.universal_add_child(text, button)
	#text.text = label_text
	#text.font_size = font_size
	#text.position.z = 0.001
	#text.no_depth_test = true
	#
	## Position the button
	#button.position = position
	#
	## Add collision shape for interaction
	#var area = Area3D.new()
	#FloodgateController.universal_add_child(area, button)
	#
	#var collision = CollisionShape3D.new()
	#FloodgateController.universal_add_child(collision, area)
	#
	#var box_shape = BoxShape3D.new()
	#box_shape.size = Vector3(size.x, size.y, 0.05)
	#collision.shape = box_shape
	#
	## Connect area signals
	#area.input_event.connect(func(camera, event, pos, normal, shape_idx): 
		#_on_button_input_event(name, camera, event, pos, normal, shape_idx)
	#)
	#
	#return button
#
#func _on_button_input_event(name, camera, event, pos, normal, shape_idx):
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#match name:
			#"CloseButton":
				#emit_signal("window_closed")
				#if get_parent():
					#get_parent().remove_child(self)
				#queue_free()
			#"MinimizeButton":
				#is_minimized = !is_minimized
				#toggle_minimized()
			#"ScrollUpButton":
				#scroll_messages_up()
			#"ScrollDownButton":
				#scroll_messages_down()
#
#func toggle_minimized():
	#if is_minimized:
		## Show only title bar
		#window_mesh.visible = false
		#text_label.visible = false
		#input_line.visible = false
		#scroll_up_button.visible = false
		#scroll_down_button.visible = false
	#else:
		## Show full window
		#window_mesh.visible = true
		#text_label.visible = true
		#input_line.visible = true
		#scroll_up_button.visible = true
		#scroll_down_button.visible = true
	#
	## Update text display
	#_update_display()
#
#func scroll_messages_up():
	#var max_scroll = max(0, text_buffer.size() - max_visible_lines)
	#scroll_offset = min(max_scroll, scroll_offset + 1)
	#update_text_display()
#
#func scroll_messages_down():
	#scroll_offset = max(0, scroll_offset - 1)
	#update_text_display()
#
## ===== CHAT FUNCTIONALITY =====
#func add_system_message(message):
	#return add_message(message, "System")
#
#func add_message(message, sender_name = "User"):
	#var msg = {
		#"text": message,
		#"sender": sender_name,
		#"timestamp": Time.get_time_string_from_system()
	#}
	#
	## Assuming we're storing messages in text_buffer
	#var formatted_message = "[%s] %s: %s" % [msg.timestamp, msg.sender, msg.text]
	#add_text(formatted_message)
	#
	## Record in task manager if available
	#if task_manager and task_manager.has_method("track_data_flow"):
		#task_manager.track_data_flow(
			#sender_name, 
			#window_title, 
			#"chat_message", 
			#message.length()
		#)
	#
	#emit_signal("message_sent", message, sender_name)
	#return msg
#
## ===== INTEGRATION FUNCTIONS FOR JSH ETHEREAL ENGINE =====
#func create_text_window_container(container_name: String, position: Vector3, size: Vector2 = Vector2(4, 3)) -> Dictionary:
	## This function would be called from your main.gd by your existing three_stages_of_creation system
	#var window_data = {
		#"container_name": container_name,
		#"position": position,
		#"size": size,
		#"node_type": "TextWindowSystem",
		#"metadata": {
			#"max_lines": 10,
			#"command_enabled": true,
			#"visible": true
		#}
	#}
	#
	#return window_data
#
#func setup_text_window_commands(window_node: JSHTextWindow):
	## Register default commands
	#window_node.register_command("help", _cmd_help)
	#window_node.register_command("clear", _cmd_clear)
	#window_node.register_command("teleport", _cmd_teleport)
	#window_node.register_command("resize", _cmd_resize)
	#window_node.register_command("color", _cmd_color)
#
#func _cmd_help(args: Array) -> Dictionary:
	#var help_text = "Available commands:\n"
	#help_text += "/help - Show this help message\n"
	#help_text += "/clear - Clear the text window\n"
	#help_text += "/teleport x y z - Teleport to coordinates\n"
	#help_text += "/resize width height - Resize the window\n"
	#help_text += "/color r g b - Change text color (0-255)"
	#
	#return {"success": true, "message": help_text}
#
#func _cmd_clear(_args: Array) -> Dictionary:
	#clear_text()
	#return {"success": true, "message": "Text cleared"}
#
## ===== UTILITY FUNCTIONS =====
#func change_color_of_letter_or_s(string):
	## Placeholder for changing color based on properties
	## This function could be implemented to apply color effects to text
	#pass
## Handle mouse over window
#func _on_window_mouse_entered():
	## Visual feedback when mouse enters
	#if background_mesh and background_mesh.material_override:
		#var material = background_mesh.material_override
		#material.albedo_color.a = min(1.0, window_opacity + 0.1)
#
## Handle mouse leaving window
#func _on_window_mouse_exited():
	## Reset visual feedback
	#if background_mesh and background_mesh.material_override:
		#var material = background_mesh.material_override
		#material.albedo_color.a = window_opacity
# Handle window input events
#func _on_window_input_event(camera, event, position, normal, shape_idx):
	#if event is InputEventMouseButton:
		#if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			## Check for title bar drag
			#if position.y > DEFAULT_HEIGHT/2 - 0.15:
				#if can_be_dragged:
					#is_dragging = true
					#drag_start_position = position
					#window_initial_position = global_position
			## Focus the window
			#is_focused = true
			#emit_signal("window_focused")
			## Check for button clicks
			#var local_position = position - global_position
			## Close button
			#if local_position.distance_to(close_button.position) < 0.1:
				#emit_signal("window_closed")
				#if get_parent():
					#get_parent().remove_child(self)
				#queue_free()
				#return
			## Minimize button
			#if local_position.distance_to(minimize_button.position) < 0.1:
				#is_minimized = !is_minimized
				#toggle_minimized()
				#return
			## Scroll up button
			#if local_position.distance_to(scroll_up_button.position) < 0.1:
				#scroll_messages_up()
				#return
			## Scroll down button
			#if local_position.distance_to(scroll_down_button.position) < 0.1:
				#scroll_messages_down()
				#return









# Resize the window
func resize_old_v1(new_width, new_height):
	# We would need to recreate or rescale all meshes
	# This is a placeholder for that functionality
	emit_signal("window_resized", Vector2(new_width, new_height))


func setup_input_handling_old():
	print(" settings maybe ")

func set_text_old_v1(string_text):
	print(" data as text somewhere ")
	
func change_color_of_letter_or_s_old(string):
	print(" here we change color based on lenght, amount, easing, and the scale? and duration of change")

func create_control_buttons_old_v1():
	print(" setup input handling ")

func create_text_area_old():
	print(" create text area")

func create_title_bar_old_v1():
	print(" create title bar ")




func _setup_components_old_v1():
	# Create window background
	window_mesh = MeshInstance3D.new()
	var window_material = MaterialLibrary.get_material("default")
	window_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	window_material.albedo_color = background_color
	
	var window_shape = BoxMesh.new()
	window_shape.size = Vector3(window_width, window_height, 0.01)
	window_mesh.mesh = window_shape
	window_mesh.material_override = window_material
	add_child(window_mesh)
	
	# Create border (using multiple quads for simplicity)
	_create_border()
	
	# Create text display
	text_label = Label3D.new()
	text_label.text = ""
	text_label.font_size = font_size
	text_label.modulate = text_color
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	text_label.width = window_width - (text_margin * 2)
	text_label.position = Vector3(-window_width/2 + text_margin, window_height/2 - text_margin, 0.011)
	add_child(text_label)
	
	# Create input line
	input_line = Label3D.new()
	input_line.text = ""
	input_line.font_size = font_size
	input_line.modulate = text_color
	input_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	input_line.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	input_line.width = window_width - (text_margin * 2)
	input_line.position = Vector3(-window_width/2 + text_margin, -window_height/2 + text_margin, 0.011)
	add_child(input_line)
	
	# Create cursor
	cursor = MeshInstance3D.new()
	var cursor_mesh = BoxMesh.new()
	cursor_mesh.size = Vector3(0.05, 0.05, 0.01)
	cursor.mesh = cursor_mesh
	cursor.material_override = window_material.duplicate()
	cursor.material_override.albedo_color = text_color
	cursor.position = Vector3(-window_width/2 + text_margin, -window_height/2 + text_margin, 0.012)
	add_child(cursor)
	
	# Setup cursor blinking timer
	cursor_timer = TimerManager.get_timer()
	cursor_timer.wait_time = 0.5
	cursor_timer.autostart = true
	add_child(cursor_timer)
	
	# Initialize command processor
	command_processor = CommandProcessor.new()
	add_child(command_processor)

func _create_border_old_v1():
	# Top border
	var top_border = MeshInstance3D.new()
	var top_mesh = BoxMesh.new()
	top_mesh.size = Vector3(window_width, border_width, 0.015)
	top_border.mesh = top_mesh
	top_border.position = Vector3(0, window_height/2, 0.005)
	
	# Bottom border
	var bottom_border = MeshInstance3D.new()
	var bottom_mesh = BoxMesh.new()
	bottom_mesh.size = Vector3(window_width, border_width, 0.015)
	bottom_border.mesh = bottom_mesh
	bottom_border.position = Vector3(0, -window_height/2, 0.005)
	
	# Left border
	var left_border = MeshInstance3D.new()
	var left_mesh = BoxMesh.new()
	left_mesh.size = Vector3(border_width, window_height, 0.015)
	left_border.mesh = left_mesh
	left_border.position = Vector3(-window_width/2, 0, 0.005)
	
	# Right border
	var right_border = MeshInstance3D.new()
	var right_mesh = BoxMesh.new()
	right_mesh.size = Vector3(border_width, window_height, 0.015)
	right_border.mesh = right_mesh
	right_border.position = Vector3(window_width/2, 0, 0.005)
	
	# Create border material
	var border_material = MaterialLibrary.get_material("default")
	border_material.albedo_color = border_color
	
	# Apply material and add borders
	top_border.material_override = border_material
	bottom_border.material_override = border_material
	left_border.material_override = border_material
	right_border.material_override = border_material
	
	add_child(top_border)
	add_child(bottom_border)
	add_child(left_border)
	add_child(right_border)


func _submit_text_old_v1():
	if input_text.strip_edges() == "":
		return
		
	# Add the submitted text to the buffer
	add_text("> " + input_text)
	
	# Add to command history
	command_history.push_front(input_text)
	if command_history.size() > 20:  # Limit history size
		command_history.pop_back()
	command_history_index = -1
	
	# Process as command if it starts with the command prefix
	if input_text.begins_with(command_prefix):
		_process_command(input_text.substr(command_prefix.length()))
	else:
		text_submitted.emit(input_text)
	
	# Clear input line
	input_text = ""
	cursor_position = 0
	_update_display()

func _navigate_command_history_old_v1(up: bool):
	if command_history.is_empty():
		return
		
	if up:
		# Move back in history
		if command_history_index < command_history.size() - 1:
			command_history_index += 1
			input_text = command_history[command_history_index]
			cursor_position = input_text.length()
			_update_display()
	else:
		# Move forward in history
		if command_history_index > 0:
			command_history_index -= 1
			input_text = command_history[command_history_index]
			cursor_position = input_text.length()
			_update_display()
		elif command_history_index == 0:
			command_history_index = -1
			input_text = ""
			cursor_position = 0
			_update_display()

# ===== PUBLIC API =====
func add_text_old_v1(text: String):
	text_buffer.append(text)
	if text_buffer.size() > max_visible_lines:
		text_buffer.remove_at(0)
	_update_display()

func _update_display_old_v1():
	# Update main text area
	text_label.text = "\n".join(text_buffer)
	# Update input line with cursor
	var display_text = input_text
	if is_focused:
		input_line.text = "> " + display_text
	else:
		input_line.text = ""
	# Update border color based on focus state
	_update_border_color()

func _update_border_color_old_v1():
	for i in range(1, 5):  # Skip the window_mesh at index 0
		var border = get_child(i)
		if border is MeshInstance3D and border != window_mesh and border != text_label and border != input_line:
			var material = border.material_override
			if material:
				if is_focused:
					material.albedo_color = Color(0.4, 0.7, 1.0)
				else:
					material.albedo_color = border_color

func _update_cursor_position_old_v1():
	# Calculate cursor position based on the text up to cursor_position
	var font = text_label.font
	var partial_text = input_text.substr(0, cursor_position)
	# Approximate cursor position based on character count
	# This is a simplified approach - for a more accurate one, you'd need to measure text width
	var char_width = 0.04  # Approximate character width in 3D units
	var x_offset = ("> ".length() + partial_text.length()) * char_width
	
	cursor.position = Vector3(-window_width/2 + text_margin + x_offset, -window_height/2 + text_margin, 0.012)

func _process_command_old_v1(command_text: String):
	var parts = command_text.strip_edges().split(" ", false)
	if parts.size() == 0:
		return
	var command_name = parts[0]
	var args = parts.slice(1)
	var result = command_processor.execute_command(command_name, args)
	if not result.success:
		add_text("Error: " + result.message)
	command_executed.emit(command_name, args)

func _on_cursor_timer_timeout_old_v1():
	cursor_visible = !cursor_visible
	cursor.visible = cursor_visible and is_focused

# ===== INTEGRATION FUNCTIONS FOR JSH ETHEREAL ENGINE =====
func create_text_window_container_old(container_name: String, position: Vector3, size: Vector2 = Vector2(4, 3)) -> Dictionary:
	# This function would be called from your main.gd by your existing three_stages_of_creation system
	var window_data = {
		"container_name": container_name,
		"position": position,
		"size": size,
		"node_type": "TextWindowSystem",
		"metadata": {
			"max_lines": 10,
			"command_enabled": true,
			"visible": true
		}
	}
	
	return window_data

func _cmd_help_old(args: Array) -> Dictionary:
	var help_text = "Available commands:\n"
	help_text += "/help - Show this help message\n"
	help_text += "/clear - Clear the text window\n"
	help_text += "/teleport x y z - Teleport to coordinates\n"
	help_text += "/resize width height - Resize the window\n"
	help_text += "/color r g b - Change text color (0-255)"
	
	return {"success": true, "message": help_text}

func _cmd_clear_old(_args: Array) -> Dictionary:
	# The window will call its own clear_text() function
	return {"success": true, "message": "Text cleared"}

func _cmd_teleport_old(args: Array) -> Dictionary:
	if args.size() < 3:
		return {"success": false, "message": "Usage: /teleport x y z"}
	var coords = Vector3()

	return {"success": true, "message": "Teleported to " + str(coords)}

func _cmd_resize_old(args: Array) -> Dictionary:
	if args.size() < 2:
		return {"success": false, "message": "Usage: /resize width height"}
	# Try to parse dimensions
	var width = 0.0
	var height = 0.0
	return {"success": true, "message": "Window resized to " + str(width) + "x" + str(height)}

func _cmd_color_old(args: Array) -> Dictionary:
	if args.size() < 3:
		return {"success": false, "message": "Usage: /color r g b (0-255)"}
	# Try to parse color
	var color = Color()
	return {"success": true, "message": "Text color changed"}



func find_integration_nodes_old_v1():
	# Try to find C# integration node
	csharp_integration = get_node_or_null("/root/JSHSystemIntegration")
	
	# Find task manager if not already set
	if not task_manager:
		task_manager = get_node_or_null("/root/JSHTaskManager")
		if task_manager and task_manager.has_method("track_data_flow"):
			task_manager.track_data_flow(
				"TextWindow", 
				window_title, 
				"window_opened", 
				1.0
			)

# Scroll messages up
func scroll_messages_up_old_v1():
	var messages
	var max_scroll = max(0, messages.size() - int(DEFAULT_HEIGHT / 0.07) + 1)
	scroll_offset = min(max_scroll, scroll_offset + 1)
	update_message_display()

# Scroll messages down
func scroll_messages_down_old_v1():
	scroll_offset = max(0, scroll_offset - 1)
	update_message_display()

# Create the text display area
func create_text_area_old_v1():
	text_container = Node3D.new()
	text_container.name = "TextContainer"
	add_child(text_container)
	# Calculate text area dimensions
	var title_height = 0.15
	var button_margin = 0.1
	var text_area_height = DEFAULT_HEIGHT - title_height - button_margin * 2
	# Position the container
	text_container.position = Vector3(
		0, 
		(DEFAULT_HEIGHT - title_height)/2 - text_area_height/2,
		0.002
	)
	# Create main text label
	content_label = Label3D.new()
	FloodgateController.universal_add_child(content_label, text_container)
	content_label.text = ""
	content_label.font_size = font_size - 2
	content_label.width = DEFAULT_WIDTH - MARGIN * 4
	content_label.height = text_area_height
	content_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	content_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	content_label.modulate = text_color
	content_label.no_depth_test = true
	# Position label within container
	content_label.position = Vector3(-DEFAULT_WIDTH/2 + MARGIN*2, text_area_height/2 - MARGIN, 0)
	# Calculate visible lines
	var line_height = 0.07
	visible_lines = int(text_area_height / line_height)
# Create control buttons (close, minimize, scroll)
func create_control_buttons_old_v2():
	# Close button
	close_button = create_button(
		"CloseButton",
		Vector3(DEFAULT_WIDTH/2 - MARGIN*2, DEFAULT_HEIGHT/2 - MARGIN*1.5, 0.002),
		Vector2(0.1, 0.1),
		Color(1, 0.3, 0.3, 1),
		"X"
	)
	# Minimize button
	minimize_button = create_button(
		"MinimizeButton",
		Vector3(DEFAULT_WIDTH/2 - MARGIN*4, DEFAULT_HEIGHT/2 - MARGIN*1.5, 0.002),
		Vector2(0.1, 0.1),
		Color(0.3, 0.7, 1, 1),
		"-"
	)
	# Scroll buttons
	scroll_up_button = create_button(
		"ScrollUpButton",
		Vector3(DEFAULT_WIDTH/2 - MARGIN*2, 0, 0.002),
		Vector2(0.1, 0.1),
		Color(0.7, 0.7, 0.7, 1),
		"↑"
	)
	scroll_down_button = create_button(
		"ScrollDownButton",
		Vector3(DEFAULT_WIDTH/2 - MARGIN*2, -DEFAULT_HEIGHT/2 + MARGIN*4, 0.002),
		Vector2(0.1, 0.1),
		Color(0.7, 0.7, 0.7, 1),
		"↓"
	)
# Helper function to create buttons
func create_button_old_v1(button_name, button_position, size, color, label_text):
	var button = Node3D.new()
	button.name = button_name
	add_child(button)
	# Create button background
	var button_mesh = MeshInstance3D.new()
	FloodgateController.universal_add_child(button_mesh, button)
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = size
	button_mesh.mesh = quad_mesh
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	button_mesh.material_override = material
	# Add label
	var text = Label3D.new()
	FloodgateController.universal_add_child(text, button)
	text.text = label_text
	text.font_size = font_size
	text.position.z = 0.001
	text.no_depth_test = true
	# Position the button
	button.position = button_position
	# Add collision shape for interaction
	var area = Area3D.new()
	FloodgateController.universal_add_child(area, button)
	var collision = CollisionShape3D.new()
	FloodgateController.universal_add_child(collision, area)
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(size.x, size.y, 0.05)
	collision.shape = box_shape
	# Connect area signals
	area.input_event.connect(func(camera, event, pos, normal, shape_idx): 
		_on_button_input_event(button_name, camera, event, pos, normal, shape_idx)
	)
	return button

func _on_button_input_event_old_v1(button_name, _camera, event, _pos, _normal, _shape_idx):
	print(" on button input event, a lot of data cmon")

# Add collision to the window for interaction
func add_window_collision_old():
	var area = Area3D.new()
	area.name = "WindowArea"
	add_child(area)
	var collision = CollisionShape3D.new()
	FloodgateController.universal_add_child(collision, area)
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(DEFAULT_WIDTH, DEFAULT_HEIGHT, 0.05)
	collision.shape = box_shape
	# Connect signals
	area.input_event.connect(_on_window_input_event)
	area.mouse_entered.connect(_on_window_mouse_entered)
	area.mouse_exited.connect(_on_window_mouse_exited)

# Set text content with optional formatting
func set_text_old_v2(text_content, format_links = true):
	full_text = text_content
	total_lines = text_content.count("\n") + 1
	# Track data in task manager
	if task_manager and task_manager.has_method("track_data_flow"):
		task_manager.track_data_flow(
			"TextWindow", 
			window_title, 
			"text_updated", 
			text_content.length()
		)
	# Process any links in the text if enabled
	if supports_links and format_links:
		process_text_links()
	else:
		content_label.text = full_text
	# Update scroll position
	if auto_scroll:
		scroll_offset = max(0, total_lines - visible_lines)
		update_text_display()
	else:
		update_text_display()
	emit_signal("text_updated", full_text)

func update_text_display_old_v1():
	print(" which screen, maybe i have more than one")

# Process any links in the text (format [link:id|text])
func process_text_links_old_v2():
	var processed_text = full_text
	var link_regex = RegEx.new()
	link_regex.compile("\\[link:([^|]+)\\|([^\\]]+)\\]")
	links.clear()
	var matches = link_regex.search_all(full_text)
	for match_result in matches:
		var link_id = match_result.get_string(1)
		var link_text
# Create the main window background
func create_window_background_old():
	background_mesh = MeshInstance3D.new()
	add_child(background_mesh)
	# Create a simple rectangular mesh for the window
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	# Define corners of the window
	var p1 = Vector3(-DEFAULT_WIDTH/2, -DEFAULT_HEIGHT/2, 0)
	var p2 = Vector3(DEFAULT_WIDTH/2, -DEFAULT_HEIGHT/2, 0)
	var p3 = Vector3(DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2, 0)
	var p4 = Vector3(-DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2, 0)
	# Add vertices
	vertices.append(p1)
	vertices.append(p2)
	vertices.append(p3)
	vertices.append(p4)
	# Create triangles
	indices.append(0)
	indices.append(1)
	indices.append(2)
	indices.append(0)
	indices.append(2)
	indices.append(3)
	# Create the mesh
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	background_mesh.mesh = arr_mesh
	# Create material
	var material = MaterialLibrary.get_material("default")
	if main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
		material.albedo_color = main_scene_reference.get_spectrum_color(window_color)
	else:
		material.albedo_color = Color(0.2, 0.2, 0.3, window_opacity)
	material.albedo_color.a = window_opacity
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	background_mesh.material_override = material
	# Add collision
	add_window_collision()
# Create the title bar at the top of the window
func create_title_bar_old():
	title_bar = MeshInstance3D.new()
	add_child(title_bar)
	# Create a rectangular mesh for the title bar
	var bar_height = 0.15
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	# Define corners of the title bar
	var p1 = Vector3(-DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2 - bar_height, 0.001)
	var p2 = Vector3(DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2 - bar_height, 0.001)
	var p3 = Vector3(DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2, 0.001)
	var p4 = Vector3(-DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2, 0.001)
	# Add vertices
	vertices.append(p1)
	vertices.append(p2)
	vertices.append(p3)
	vertices.append(p4)
	# Create triangles
	indices.append(0)
	indices.append(1)
	indices.append(2)
	indices.append(0)
	indices.append(2)
	indices.append(3)
	# Create the mesh
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	title_bar.mesh = arr_mesh
	# Create material with a slightly different color
	var material = MaterialLibrary.get_material("default")
	if main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
		material.albedo_color = main_scene_reference.get_spectrum_color(window_color + 0.1)
	else:
		material.albedo_color = Color(0.25, 0.25, 0.35, window_opacity)
	material.albedo_color.a = window_opacity
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	title_bar.material_override = material
	# Add title text
	title_label = Label3D.new()
	add_child(title_label)
	title_label.text = window_title
	title_label.font_size = font_size
	title_label.modulate = text_color
	title_label.position = Vector3(0, DEFAULT_HEIGHT/2 - bar_height/2, 0.002)
	title_label.no_depth_test = true

# Create control buttons (close, minimize, scroll)
func create_control_buttons_old_v3():
	# Close button
	close_button = create_button(
		"CloseButton",
		Vector3(DEFAULT_WIDTH/2 - MARGIN*2, DEFAULT_HEIGHT/2 - MARGIN*1.5, 0.002),
		Vector2(0.1, 0.1),
		Color(1, 0.3, 0.3, 1),
		"X"
	)
	# Minimize button
	minimize_button = create_button(
		"MinimizeButton",
		Vector3(DEFAULT_WIDTH/2 - MARGIN*4, DEFAULT_HEIGHT/2 - MARGIN*1.5, 0.002),
		Vector2(0.1, 0.1),
		Color(0.3, 0.7, 1, 1),
		"-"
	)
	# Scroll buttons
	scroll_up_button = create_button(
		"ScrollUpButton",
		Vector3(DEFAULT_WIDTH/2 - MARGIN*2, 0, 0.002),
		Vector2(0.1, 0.1),
		Color(0.7, 0.7, 0.7, 1),
		"↑"
	)
	scroll_down_button = create_button(
		"ScrollDownButton",
		Vector3(DEFAULT_WIDTH/2 - MARGIN*2, -DEFAULT_HEIGHT/2 + MARGIN*4, 0.002),
		Vector2(0.1, 0.1),
		Color(0.7, 0.7, 0.7, 1),
		"↓"
	)
# Helper function to create buttons
func create_button_old_v2(button_name, button_position, size, color, label_text):
	var button = Node3D.new()
	button.name = button_name
	add_child(button)
	# Create button background
	var button_mesh = MeshInstance3D.new()
	FloodgateController.universal_add_child(button_mesh, button)
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = size
	button_mesh.mesh = quad_mesh
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	button_mesh.material_override = material
	# Add label
	var text = Label3D.new()
	FloodgateController.universal_add_child(text, button)
	text.text = label_text
	text.font_size = font_size
	text.position.z = 0.001
	text.no_depth_test = true
	# Position the button
	button.position = button_position
	# Add collision shape for interaction
	var area = Area3D.new()
	FloodgateController.universal_add_child(area, button)
	var collision = CollisionShape3D.new()
	FloodgateController.universal_add_child(collision, area)
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(size.x, size.y, 0.05)
	collision.shape = box_shape
	return button
# Add collision to the window for interaction
func add_window_collision_old_v1():
	var area = Area3D.new()
	area.name = "WindowArea"
	add_child(area)
	var collision = CollisionShape3D.new()
	FloodgateController.universal_add_child(collision, area)
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(DEFAULT_WIDTH, DEFAULT_HEIGHT, 0.05)
	collision.shape = box_shape
	# Connect signals
	area.input_event.connect(_on_window_input_event)
	area.mouse_entered.connect(_on_window_mouse_entered)
	area.mouse_exited.connect(_on_window_mouse_exited)
# Add a message to the chat
func add_message_old_v1(message, sender_name = "User"):
	var msg = {
		"text": message,
		"sender": sender_name,
		"timestamp": Time.get_time_string_from_system()
	}
	var messages
	messages.append(msg)
	# Limit the number of messages
	if messages.size() > MAX_MESSAGES:
		messages.remove_at(0)
	# Update the display
	update_message_display()
	# Record in task manager if available
	if task_manager and task_manager.has_method("track_data_flow"):
		task_manager.track_data_flow(
			sender_name, 
			window_title, 
			"chat_message", 
			message.length()
		)
	return msg


# Toggle window minimized state
func toggle_minimized_old_v1():
	if is_minimized:
		# Show only title bar
		background_mesh.visible = false
		message_container.visible = false
		input_field.visible = false
		scroll_up_button.visible = false
		scroll_down_button.visible = false
	else:
		# Show full window
		background_mesh.visible = true
		message_container.visible = true
		input_field.visible = true
		scroll_up_button.visible = true
		scroll_down_button.visible = true
	# Update message display
	update_message_display()
# Create the main window background
func create_window_background_old_v1():
	background_mesh = MeshInstance3D.new()
	add_child(background_mesh)
	# Create a simple rectangular mesh for the window
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	# Define corners of the window
	var p1 = Vector3(-DEFAULT_WIDTH/2, -DEFAULT_HEIGHT/2, 0)
	var p2 = Vector3(DEFAULT_WIDTH/2, -DEFAULT_HEIGHT/2, 0)
	var p3 = Vector3(DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2, 0)
	var p4 = Vector3(-DEFAULT_WIDTH/2, DEFAULT_HEIGHT/2, 0)
	# Add vertices
	vertices.append(p1)
	vertices.append(p2)
	vertices.append(p3)
	vertices.append(p4)
	# Create triangles
	indices.append(0)
	indices.append(1)
	indices.append(2)
	indices.append(0)
	indices.append(2)
	indices.append(3)
	# Create the mesh
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	background_mesh.mesh = arr_mesh
# Main setup function
func setup_window_old():
	# Create window background
	create_window_background()
	
	# Create title bar
	create_title_bar()
	
	# Create message display area
	create_message_area()
	
	# Create input field
	create_input_field()
	
	# Create control buttons
	create_control_buttons()
	
	# Add initial welcome message
	add_system_message("Welcome to JSH Chat System")

# Main setup function
func setup_window_old_v1():
	# Create window background
	create_window_background()
	
	# Create title bar
	create_title_bar()
	
	# Create text display area
	create_text_area()
	
	# Create control buttons
	create_control_buttons()
	
	# Add initial welcome message
	set_text("JSH Text Window System\n\nUse this window to display important information to the user.")


func _setup_signals_old_v2():
	cursor_timer.timeout.connect(_on_cursor_timer_timeout)
func clear_text_old_v2():
	text_buffer.clear()
	_update_display()

func focus_old_v2():
	is_focused = true
	window_focused.emit()
	_update_display()

func unfocus_old_v2():
	is_focused = false
	window_unfocused.emit()
	_update_display()

func register_command_old_v2(command_name: String, callback: Callable):
	command_processor.register_command(command_name, callback)

# Add a system message
func add_system_message_old_v2(message):
	return add_message(message, "System")
