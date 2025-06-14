extends Control
# ═══════════════════════════════════════════════════════════════════════════════════════════════
# 🎯 CROSSHAIR SYSTEM - PRECISION TARGETING WITH DISTANCE MEASUREMENT 🎯
# ═══════════════════════════════════════════════════════════════════════════════════════════════
#
# 📍 PROJECT PATH: /akashic_notepad3d_game/scripts/core/crosshair_system.gd
# 🎯 FILE GOAL: Center screen crosshair with real-time distance measurement
# 🔗 CONNECTED FILES:
#    - core/main_game_controller.gd (raycast integration)
#    - scenes/main_game.tscn (UI overlay)
#
# 🚀 REVOLUTIONARY FEATURES:
#    - Center screen crosshair for precise aiming
#    - Real-time distance measurement via raycast
#    - Target object identification and info display
#    - Color-coded crosshair based on target type
#    - Console feedback for all interactions
#
# 🎮 USER EXPERIENCE: Professional FPS-style targeting system
# ═══════════════════════════════════════════════════════════════════════════════════════════════

class_name CrosshairSystem

# Crosshair configuration
var crosshair_size: float = 20.0
var crosshair_thickness: float = 2.0
var crosshair_gap: float = 8.0

# Distance measurement
var max_raycast_distance: float = 1000.0
var current_distance: float = 0.0
var target_object: Node3D = null
var target_info: Dictionary = {}

# UI elements
var crosshair_center: Control
var distance_label: Label
var target_info_label: Label
var crosshair_lines: Array[ColorRect] = []

# References
var camera: Camera3D
var main_controller: Node3D

# Crosshair colors
const COLOR_DEFAULT = Color.WHITE
const COLOR_TARGET_WORD = Color.CYAN
const COLOR_TARGET_PLANET = Color.ORANGE
const COLOR_TARGET_PYRAMID = Color.LIME
const COLOR_NO_TARGET = Color.GRAY

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 INITIALIZE CROSSHAIR SYSTEM - PRECISION TARGETING SETUP
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Camera and main controller references for raycast integration
# PROCESS: Creates crosshair UI, distance meter, and targeting system
# OUTPUT: Complete crosshair system with real-time distance measurement
# CHANGES: Adds crosshair UI elements to screen center
# CONNECTION: Integrates with main controller raycast system
# ─────────────────────────────────────────────────────────────────────────────────
func initialize(camera_ref: Camera3D, controller_ref: Node3D) -> void:
	camera = camera_ref
	main_controller = controller_ref
	
	# Set up full screen overlay
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block mouse events
	
	_create_crosshair_elements()
	_create_distance_display()
	_create_target_info_display()
	
	# Start real-time updates
	set_process(true)
	
	print("🎯 Crosshair System initialized - Precision targeting active")

# ─────────────────────────────────────────────────────────────────────────────────
# 🎨 CREATE CROSSHAIR ELEMENTS - VISUAL CROSSHAIR DESIGN
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (uses crosshair configuration)
# PROCESS: Creates 4 crosshair lines in center of screen
# OUTPUT: Visible crosshair with configurable size and thickness
# CHANGES: Adds 4 ColorRect elements forming crosshair shape
# CONNECTION: Visual targeting aid for precise aiming
# ─────────────────────────────────────────────────────────────────────────────────
func _create_crosshair_elements() -> void:
	var screen_center = get_viewport().get_visible_rect().size / 2
	
	# Create 4 crosshair lines (top, bottom, left, right)
	var line_configs = [
		{"pos": Vector2(screen_center.x - crosshair_thickness/2, screen_center.y - crosshair_gap - crosshair_size), "size": Vector2(crosshair_thickness, crosshair_size)},  # Top
		{"pos": Vector2(screen_center.x - crosshair_thickness/2, screen_center.y + crosshair_gap), "size": Vector2(crosshair_thickness, crosshair_size)},  # Bottom
		{"pos": Vector2(screen_center.x - crosshair_gap - crosshair_size, screen_center.y - crosshair_thickness/2), "size": Vector2(crosshair_size, crosshair_thickness)},  # Left
		{"pos": Vector2(screen_center.x + crosshair_gap, screen_center.y - crosshair_thickness/2), "size": Vector2(crosshair_size, crosshair_thickness)}  # Right
	]
	
	for config in line_configs:
		var line = ColorRect.new()
		line.position = config.pos
		line.size = config.size
		line.color = COLOR_DEFAULT
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(line)
		crosshair_lines.append(line)
	
	print("🎨 Crosshair elements created - 4 lines with ", crosshair_size, "px size")

# ─────────────────────────────────────────────────────────────────────────────────
# 📏 CREATE DISTANCE DISPLAY - REAL-TIME DISTANCE MEASUREMENT
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (creates distance label)
# PROCESS: Creates distance label positioned near crosshair
# OUTPUT: Real-time distance display in meters
# CHANGES: Adds distance label to UI
# CONNECTION: Shows raycast distance to targeted objects
# ─────────────────────────────────────────────────────────────────────────────────
func _create_distance_display() -> void:
	distance_label = Label.new()
	distance_label.text = "Distance: --"
	distance_label.add_theme_color_override("font_color", Color.WHITE)
	distance_label.add_theme_font_size_override("font_size", 14)
	
	var screen_center = get_viewport().get_visible_rect().size / 2
	distance_label.position = Vector2(screen_center.x + 30, screen_center.y - 30)
	distance_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(distance_label)
	print("📏 Distance display created")

# ─────────────────────────────────────────────────────────────────────────────────
# 🏷️ CREATE TARGET INFO DISPLAY - OBJECT IDENTIFICATION SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (creates target info label)
# PROCESS: Creates label for displaying target object information
# OUTPUT: Target name and type display
# CHANGES: Adds target info label to UI
# CONNECTION: Shows information about targeted objects
# ─────────────────────────────────────────────────────────────────────────────────
func _create_target_info_display() -> void:
	target_info_label = Label.new()
	target_info_label.text = ""
	target_info_label.add_theme_color_override("font_color", Color.CYAN)
	target_info_label.add_theme_font_size_override("font_size", 12)
	
	var screen_center = get_viewport().get_visible_rect().size / 2
	target_info_label.position = Vector2(screen_center.x + 30, screen_center.y + 10)
	target_info_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(target_info_label)
	print("🏷️ Target info display created")

# ─────────────────────────────────────────────────────────────────────────────────
# 🔄 PROCESS - REAL-TIME CROSSHAIR UPDATES
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Delta time for frame-rate independent updates
# PROCESS: Updates crosshair, distance measurement, and target detection
# OUTPUT: Real-time crosshair feedback and distance measurement
# CHANGES: Updates UI elements based on current targeting
# CONNECTION: Continuous targeting system updates
# ─────────────────────────────────────────────────────────────────────────────────
func _process(_delta: float) -> void:
	if not camera:
		return
	
	_update_crosshair_targeting()
	_update_distance_measurement()
	_update_target_info()

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 UPDATE CROSSHAIR TARGETING - REAL-TIME TARGET DETECTION
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (uses current camera position)
# PROCESS: Performs raycast from screen center and detects targets
# OUTPUT: Updated target object and crosshair color
# CHANGES: Updates target_object and crosshair visual state
# CONNECTION: Core targeting system for E key interactions
# ─────────────────────────────────────────────────────────────────────────────────
func _update_crosshair_targeting() -> void:
	var screen_center = get_viewport().get_visible_rect().size / 2
	var from = camera.project_ray_origin(screen_center)
	var to = from + camera.project_ray_normal(screen_center) * max_raycast_distance
	
	# Get world from camera since this is a Control node, not a 3D node
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 0b11111111  # All layers
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		target_object = result.collider
		current_distance = from.distance_to(result.position)
		target_info = _analyze_target(target_object)
		_update_crosshair_color(_get_target_color(target_info))
	else:
		target_object = null
		current_distance = max_raycast_distance
		target_info = {}
		_update_crosshair_color(COLOR_NO_TARGET)

# ─────────────────────────────────────────────────────────────────────────────────
# 🔍 ANALYZE TARGET - TARGET OBJECT IDENTIFICATION
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Target object from raycast result
# PROCESS: Analyzes object type, name, and properties
# OUTPUT: Dictionary with target information
# CHANGES: No changes (read-only analysis)
# CONNECTION: Provides detailed target information for UI display
# ─────────────────────────────────────────────────────────────────────────────────
func _analyze_target(obj: Node3D) -> Dictionary:
	var info = {
		"name": obj.name,
		"type": "Unknown",
		"details": ""
	}
	
	# Identify object type
	if obj.has_method("get_word_entity") or "word" in obj.name.to_lower():
		info.type = "Word Entity"
		info.details = "Press E to interact"
	elif "planet" in obj.name.to_lower() or obj.get_parent().name.ends_with("_System"):
		info.type = "Planet"
		info.details = "Cosmic hierarchy object"
	elif "pyramid" in obj.name.to_lower():
		info.type = "Pyramid Layer"
		info.details = "9-layer coordinate system"
	elif "marker" in obj.name.to_lower():
		info.type = "Layer Marker"
		info.details = "Clickable layer marker"
	else:
		info.type = "Object"
		info.details = obj.get_class()
	
	return info

# ─────────────────────────────────────────────────────────────────────────────────
# 🎨 GET TARGET COLOR - COLOR-CODED TARGETING
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Target info dictionary
# PROCESS: Determines appropriate crosshair color based on target type
# OUTPUT: Color for crosshair based on target
# CHANGES: No changes (pure color selection)
# CONNECTION: Provides visual feedback for different target types
# ─────────────────────────────────────────────────────────────────────────────────
func _get_target_color(info: Dictionary) -> Color:
	if info.is_empty():
		return COLOR_NO_TARGET
	
	match info.type:
		"Word Entity":
			return COLOR_TARGET_WORD
		"Planet":
			return COLOR_TARGET_PLANET
		"Pyramid Layer":
			return COLOR_TARGET_PYRAMID
		_:
			return COLOR_DEFAULT

# ─────────────────────────────────────────────────────────────────────────────────
# 🎨 UPDATE CROSSHAIR COLOR - VISUAL FEEDBACK SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Color to apply to crosshair lines
# PROCESS: Updates all crosshair line colors
# OUTPUT: Visual crosshair color change
# CHANGES: Updates crosshair_lines color properties
# CONNECTION: Provides immediate visual feedback for targeting
# ─────────────────────────────────────────────────────────────────────────────────
func _update_crosshair_color(color: Color) -> void:
	for line in crosshair_lines:
		line.color = color

# ─────────────────────────────────────────────────────────────────────────────────
# 📏 UPDATE DISTANCE MEASUREMENT - REAL-TIME DISTANCE DISPLAY
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (uses current_distance)
# PROCESS: Updates distance label with formatted distance
# OUTPUT: Updated distance display in meters
# CHANGES: Updates distance_label text
# CONNECTION: Provides precise distance measurement for targeting
# ─────────────────────────────────────────────────────────────────────────────────
func _update_distance_measurement() -> void:
	if current_distance >= max_raycast_distance:
		distance_label.text = "Distance: ∞"
	else:
		distance_label.text = "Distance: %.1fm" % current_distance

# ─────────────────────────────────────────────────────────────────────────────────
# 🏷️ UPDATE TARGET INFO - TARGET INFORMATION DISPLAY
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (uses target_info)
# PROCESS: Updates target info label with object details
# OUTPUT: Updated target information display
# CHANGES: Updates target_info_label text
# CONNECTION: Provides detailed target information for user feedback
# ─────────────────────────────────────────────────────────────────────────────────
func _update_target_info() -> void:
	if target_info.is_empty():
		target_info_label.text = ""
	else:
		target_info_label.text = "%s\n%s" % [target_info.type, target_info.details]

# ─────────────────────────────────────────────────────────────────────────────────
# 📢 GET INTERACTION MESSAGE - CONSOLE FEEDBACK GENERATION
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (uses current target info)
# PROCESS: Generates detailed console message for interactions
# OUTPUT: Formatted string with interaction details
# CHANGES: No changes (pure message generation)
# CONNECTION: Provides detailed console feedback for E key interactions
# ─────────────────────────────────────────────────────────────────────────────────
func get_interaction_message() -> String:
	if target_object and not target_info.is_empty():
		return "🎯 TARGET: %s (%s) at %.1fm - %s" % [
			target_info.name,
			target_info.type,
			current_distance,
			target_info.details
		]
	else:
		return "🎯 NO TARGET - Aiming at empty space"

# ─────────────────────────────────────────────────────────────────────────────────
# 🎮 TOGGLE CROSSHAIR - VISIBILITY CONTROL
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: No parameters (toggles current visibility)
# PROCESS: Shows/hides crosshair system
# OUTPUT: Toggled crosshair visibility
# CHANGES: Updates visible property
# CONNECTION: Allows users to disable crosshair if needed
# ─────────────────────────────────────────────────────────────────────────────────
func toggle_crosshair() -> void:
	visible = !visible
	if visible:
		print("🎯 Crosshair enabled - Precision targeting active")
	else:
		print("🎯 Crosshair disabled")