extends Control
# ═══════════════════════════════════════════════════════════════════════════════════════════════
# 🛠️ DEBUG SCENE MANAGER - TASK MANAGER FOR 3D GAME 🛠️
# ═══════════════════════════════════════════════════════════════════════════════════════════════
#
# 📍 PROJECT PATH: /akashic_notepad3d_game/scripts/core/debug_scene_manager.gd
# 🎯 FILE GOAL: Real-time debugging and control interface for all game systems
# 🔗 CONNECTED FILES:
#    - core/main_game_controller.gd (main coordination and input)
#    - core/notepad3d_environment.gd (layer management and settings)
#    - core/interactive_3d_ui_system.gd (UI controls and debugging)
#    - core/word_entity.gd (entity inspection and modification)
#    - autoload/*.gd (global system monitoring)
#
# 🚀 REVOLUTIONARY FEATURES:
#    - Real-time system monitoring (like Windows Task Manager)
#    - Live settings modification without restarting
#    - Visual debugging with wireframes and glow effects
#    - Function inspector for cooperation acceleration
#    - 2D/3D debug windows for any component
#
# 🎮 USER EXPERIENCE: Developer-friendly real-time debugging and modification
# ═══════════════════════════════════════════════════════════════════════════════════════════════

class_name DebugSceneManager

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 CORE DEBUG MANAGER PROPERTIES
# ─────────────────────────────────────────────────────────────────────────────────

signal debug_setting_changed(system: String, property: String, value: Variant)
signal debug_function_called(system: String, function: String, parameters: Array)

# Manager state
var is_debug_visible: bool = false
var debug_panels: Dictionary = {}
var monitored_systems: Dictionary = {}
var debug_overlay_3d: Node3D
var debug_overlay_2d: Control

# Visual debugging
var wireframe_enabled: bool = false
var glow_enabled: bool = false
var debug_lines: Array = []  # Will contain Line3D objects when created

# Function templates for modular code creation
var function_templates: Dictionary = {}

# System monitoring
var system_performance: Dictionary = {}
var update_timer: float = 0.0
var update_interval: float = 0.1  # Update 10 times per second

# ─────────────────────────────────────────────────────────────────────────────────
# 🎮 DEBUG MANAGER INITIALIZATION
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Game systems to monitor and debug
# PROCESS: Sets up debug interfaces, monitoring, and visual debugging
# OUTPUT: Complete debug environment ready for use
# CHANGES: Creates debug UI overlays and monitoring systems
# CONNECTION: Integrates with all game systems for real-time control
# ─────────────────────────────────────────────────────────────────────────────────
func _ready() -> void:
	# Set up debug manager for proper UI layer display
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow interaction when hidden
	
	_setup_debug_interface()
	_setup_function_templates()
	_setup_visual_debugging()
	_register_debug_systems()
	print("🛠️ Debug Scene Manager initialized in UI layer - Press ` (backtick) to toggle")

func _setup_debug_interface() -> void:
	# Create main debug panel
	var _main_panel = _create_debug_panel("main", "Debug Scene Manager", Vector2(300, 500))
	
	# Create system monitoring panel
	var _monitor_panel = _create_debug_panel("monitor", "System Monitor", Vector2(400, 300))
	
	# Create function inspector panel
	var _inspector_panel = _create_debug_panel("inspector", "Function Inspector", Vector2(350, 400))
	
	# Create visual debug panel
	var _visual_panel = _create_debug_panel("visual", "Visual Debugging", Vector2(250, 200))
	
	# Initially hide all panels
	set_debug_visibility(false)

# ─────────────────────────────────────────────────────────────────────────────────
# 🏗️ CREATE DEBUG PANEL - MODULAR PANEL CREATION
# ─────────────────────────────────────────────────────────────────────────────────
func _create_debug_panel(panel_id: String, title: String, panel_size: Vector2) -> Control:
	var panel = PanelContainer.new()
	panel.name = "DebugPanel_" + panel_id
	panel.custom_minimum_size = panel_size
	
	# Position panels in a cascade pattern on screen
	var offset_x = 50 + debug_panels.size() * 20  # Small horizontal offset
	var offset_y = 50 + debug_panels.size() * 30  # Vertical cascade
	panel.position = Vector2(offset_x, offset_y)
	
	# Ensure panel stays on screen
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	
	# Make panel draggable
	panel.gui_input.connect(_on_panel_gui_input.bind(panel))
	
	# Create header
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var header = Label.new()
	header.text = "🛠️ " + title
	header.add_theme_font_size_override("font_size", 16)
	vbox.add_child(header)
	
	var content_area = VBoxContainer.new()
	content_area.name = "ContentArea"
	vbox.add_child(content_area)
	
	# Add specific content based on panel type
	match panel_id:
		"main":
			_setup_main_panel_content(content_area)
		"monitor":
			_setup_monitor_panel_content(content_area)
		"inspector":
			_setup_inspector_panel_content(content_area)
		"visual":
			_setup_visual_panel_content(content_area)
	
	add_child(panel)
	debug_panels[panel_id] = panel
	
	return panel

# ─────────────────────────────────────────────────────────────────────────────────
# 📊 SYSTEM MONITORING PANELS
# ─────────────────────────────────────────────────────────────────────────────────
func _setup_main_panel_content(container: VBoxContainer) -> void:
	# System toggle buttons
	var systems = ["Notepad3D", "Interactive3DUI", "WordEntities", "Camera", "LOD"]
	for system in systems:
		var button = CheckBox.new()
		button.text = system + " System"
		button.button_pressed = true
		button.toggled.connect(_on_system_toggle.bind(system))
		container.add_child(button)
	
	# Settings shortcuts
	container.add_child(HSeparator.new())
	var settings_label = Label.new()
	settings_label.text = "🎛️ Quick Settings"
	container.add_child(settings_label)
	
	var wireframe_btn = CheckBox.new()
	wireframe_btn.text = "Wireframe Debug"
	wireframe_btn.toggled.connect(_on_wireframe_toggle)
	container.add_child(wireframe_btn)
	
	var glow_btn = CheckBox.new()
	glow_btn.text = "Glow Effects"
	glow_btn.toggled.connect(_on_glow_toggle)
	container.add_child(glow_btn)

func _setup_monitor_panel_content(container: VBoxContainer) -> void:
	# Performance monitoring
	var perf_label = Label.new()
	perf_label.name = "PerformanceLabel"
	perf_label.text = "📈 Performance Monitor"
	container.add_child(perf_label)
	
	# System status labels
	var systems = ["Camera", "WordEntities", "Notepad3D", "UI", "LOD"]
	for system in systems:
		var status_label = Label.new()
		status_label.name = system + "_Status"
		status_label.text = system + ": Monitoring..."
		container.add_child(status_label)

func _setup_inspector_panel_content(container: VBoxContainer) -> void:
	# Function inspector
	var func_label = Label.new()
	func_label.text = "🔍 Function Inspector"
	container.add_child(func_label)
	
	# Function search
	var search_field = LineEdit.new()
	search_field.placeholder_text = "Search functions..."
	search_field.text_changed.connect(_on_function_search)
	container.add_child(search_field)
	
	# Function list
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(300, 200)
	container.add_child(scroll)
	
	var func_list = VBoxContainer.new()
	func_list.name = "FunctionList"
	scroll.add_child(func_list)

func _setup_visual_panel_content(container: VBoxContainer) -> void:
	# Visual debugging controls
	var visual_label = Label.new()
	visual_label.text = "👁️ Visual Debug"
	container.add_child(visual_label)
	
	# Color controls
	var color_picker = ColorPicker.new()
	color_picker.custom_minimum_size = Vector2(200, 150)
	color_picker.color_changed.connect(_on_debug_color_changed)
	container.add_child(color_picker)

# ─────────────────────────────────────────────────────────────────────────────────
# 🔧 FUNCTION TEMPLATE SYSTEM - MODULAR CODE CREATION
# ─────────────────────────────────────────────────────────────────────────────────
func _setup_function_templates() -> void:
	# Template for string-based function variations
	function_templates["string_processor"] = {
		"template": """
func process_{name}(input_data: String, separator: String = ",") -> Array:
	# Process {description} with custom separator
	var parts = input_data.split(separator)
	var processed = []
	for part in parts:
		processed.append({processing_logic})
	return processed
""",
		"variations": [
			{"name": "words", "description": "word data", "processing_logic": "part.strip_edges()"},
			{"name": "coordinates", "description": "coordinate data", "processing_logic": "Vector3.from_string(part)"},
			{"name": "colors", "description": "color data", "processing_logic": "Color(part)"}
		]
	}
	
	# Template for debug window creation
	function_templates["debug_window"] = {
		"template": """
func create_debug_window_{name}(target_object: {object_type}) -> Control:
	var window = _create_debug_panel("{name}_debug", "{title}", Vector2({width}, {height}))
	var content = window.get_node("ContentArea")
	
	# Add {name} specific controls
	{controls_code}
	
	return window
""",
		"variations": [
			{"name": "camera", "object_type": "Camera3D", "title": "Camera Debug", "width": 300, "height": 200},
			{"name": "word_entity", "object_type": "WordEntity", "title": "Word Entity Debug", "width": 350, "height": 300},
			{"name": "notepad", "object_type": "Notepad3DEnvironment", "title": "Notepad 3D Debug", "width": 400, "height": 350}
		]
	}

# ─────────────────────────────────────────────────────────────────────────────────
# 🎨 VISUAL DEBUGGING SYSTEM
# ─────────────────────────────────────────────────────────────────────────────────
func _setup_visual_debugging() -> void:
	# Create 3D debug overlay
	debug_overlay_3d = Node3D.new()
	debug_overlay_3d.name = "DebugOverlay3D"
	get_tree().current_scene.add_child(debug_overlay_3d)
	
	# Create wireframe material
	var wireframe_material = StandardMaterial3D.new()
	wireframe_material.flags_unshaded = true
	wireframe_material.wireframe = true
	wireframe_material.albedo_color = Color.CYAN

# ─────────────────────────────────────────────────────────────────────────────────
# 🎮 TOGGLE DEBUG INTERFACE - PRIMARY VISIBILITY CONTROL
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Called by main controller when ` key is pressed
# PROCESS: Toggles debug interface visibility and updates all debug panels
# OUTPUT: Shows/hides complete debug system interface
# CHANGES: Updates visibility state and refreshes debug panels
# CONNECTION: Primary interface control for debug manager
# ─────────────────────────────────────────────────────────────────────────────────
func toggle_debug_interface() -> void:
	is_debug_visible = !is_debug_visible
	set_debug_visibility(is_debug_visible)
	
	if is_debug_visible:
		print("🛠️ Debug Manager activated - Real-time system monitoring enabled")
		print("📊 Systems registered: ", monitored_systems.keys())
		_update_system_monitoring()  # Refresh data when shown
	else:
		print("🛠️ Debug Manager deactivated")

func set_debug_visibility(debug_visible: bool) -> void:
	is_debug_visible = debug_visible
	self.visible = debug_visible
	
	# Update 3D debug overlay
	if debug_overlay_3d:
		debug_overlay_3d.visible = debug_visible
	
	print("🛠️ Debug Scene Manager ", "shown" if debug_visible else "hidden")

# ─────────────────────────────────────────────────────────────────────────────────
# 📊 SYSTEM REGISTRATION AND MONITORING
# ─────────────────────────────────────────────────────────────────────────────────
func _register_debug_systems() -> void:
	# Register main game systems for monitoring
	monitored_systems["main_controller"] = null
	monitored_systems["notepad3d"] = null
	monitored_systems["interactive_ui"] = null
	monitored_systems["word_entities"] = []
	monitored_systems["camera"] = null

func register_system(system_name: String, system_object: Node) -> void:
	monitored_systems[system_name] = system_object
	print("🛠️ Registered ", system_name, " for debug monitoring")

# ─────────────────────────────────────────────────────────────────────────────────
# ⚡ REAL-TIME MONITORING AND UPDATES
# ─────────────────────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if not is_debug_visible:
		return
	
	update_timer += delta
	if update_timer >= update_interval:
		_update_system_monitoring()
		update_timer = 0.0

func _update_system_monitoring() -> void:
	# Update performance labels
	var monitor_panel = debug_panels.get("monitor")
	if not monitor_panel:
		return
	
	var fps = Engine.get_frames_per_second()
	var perf_label = monitor_panel.find_child("PerformanceLabel")
	if perf_label:
		perf_label.text = "📈 FPS: %d | Memory: %.1f MB" % [fps, OS.get_static_memory_usage() / 1024.0 / 1024.0]

# ─────────────────────────────────────────────────────────────────────────────────
# 🎮 INPUT HANDLING
# ─────────────────────────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	# Toggle debug manager with backtick key
	if event is InputEventKey and event.pressed and event.keycode == KEY_QUOTELEFT:
		set_debug_visibility(!is_debug_visible)

# ─────────────────────────────────────────────────────────────────────────────────
# 📡 SIGNAL HANDLERS
# ─────────────────────────────────────────────────────────────────────────────────
func _on_system_toggle(system_name: String, enabled: bool) -> void:
	print("🛠️ ", system_name, " system ", "enabled" if enabled else "disabled")
	debug_setting_changed.emit(system_name, "enabled", enabled)

func _on_wireframe_toggle(enabled: bool) -> void:
	wireframe_enabled = enabled
	print("🛠️ Wireframe debug ", "enabled" if enabled else "disabled")

func _on_glow_toggle(enabled: bool) -> void:
	glow_enabled = enabled
	print("🛠️ Glow effects ", "enabled" if enabled else "disabled")

func _on_function_search(search_text: String) -> void:
	# Update function list based on search
	var func_list = debug_panels["inspector"].find_child("FunctionList")
	if func_list:
		# Clear existing list
		for child in func_list.get_children():
			child.queue_free()
		
		# Add matching functions
		_populate_function_list(func_list, search_text)

func _on_debug_color_changed(color: Color) -> void:
	# Update debug visualization color
	print("🛠️ Debug color changed to: ", color)

func _on_panel_gui_input(event: InputEvent, panel: Control) -> void:
	# Handle panel dragging
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				panel.set_meta("dragging", true)
				panel.set_meta("drag_offset", event.position)
	elif event is InputEventMouseMotion and panel.get_meta("dragging", false):
		panel.position += event.relative

# ─────────────────────────────────────────────────────────────────────────────────
# 🔍 FUNCTION INSPECTION UTILITIES
# ─────────────────────────────────────────────────────────────────────────────────
func _populate_function_list(container: VBoxContainer, filter: String = "") -> void:
	# Get all available functions from registered systems
	var functions = _get_all_system_functions()
	
	for func_info in functions:
		if filter.is_empty() or func_info.name.to_lower().contains(filter.to_lower()):
			var func_button = Button.new()
			func_button.text = func_info.name + " (" + func_info.system + ")"
			func_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			func_button.pressed.connect(_on_function_selected.bind(func_info))
			container.add_child(func_button)

func _get_all_system_functions() -> Array:
	var functions = []
	# This would be expanded to inspect actual registered systems
	# For now, return example functions
	functions.append({"name": "toggle_3d_interface", "system": "Notepad3D", "parameters": []})
	functions.append({"name": "create_ui_button", "system": "Interactive3DUI", "parameters": ["config: Dictionary"]})
	functions.append({"name": "set_cinema_perspective", "system": "MainController", "parameters": []})
	return functions

func _on_function_selected(func_info: Dictionary) -> void:
	print("🔍 Selected function: ", func_info.name, " from ", func_info.system)
	# Could open detailed function inspector or call the function