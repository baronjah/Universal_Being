# ==================================================
# UNIVERSAL BEING UI: Universe Simulator
# TYPE: Visual Interface
# PURPOSE: Visual simulation and exploration of recursive universes
# AUTHOR: Claude Desktop + Universal Being Evolution
# DATE: 2025-06-03
# ==================================================

extends Control
class_name UniverseSimulator

# ===== UI ELEMENTS =====
var universe_viewport: SubViewport = null
var universe_camera: Camera3D = null
var info_panel: Panel = null
var control_panel: Panel = null
var timeline_slider: HSlider = null
var zoom_slider: HSlider = null
var universe_tree: Tree = null

# ===== SIMULATION STATE =====
var current_universe: UniverseUniversalBeing = null
var simulation_speed: float = 1.0
var view_depth: int = 0  # How deep into nested universes we're viewing
var selected_being: UniversalBeing = null
var universe_history: Array[UniverseUniversalBeing] = []

# ===== VISUAL SETTINGS =====
var universe_colors: Dictionary = {
	"sandbox": Color.CYAN,
	"narrative": Color.PURPLE,
	"quantum": Color.GREEN,
	"paradise": Color.GOLD
}

# ===== SIGNALS =====
signal universe_entered(universe: UniverseUniversalBeing)
signal universe_exited(universe: UniverseUniversalBeing)
signal being_selected(being: UniversalBeing)
signal simulation_speed_changed(speed: float)

func _ready() -> void:
	custom_minimum_size = Vector2(1024, 768)
	_create_interface()
	_setup_viewport()
	print("🌌 Universe Simulator initialized - ready to explore infinite realities!")

# ===== INTERFACE CREATION =====

func _create_interface() -> void:
	"""Create the complete simulator interface"""
	var main_split = HSplitContainer.new()
	main_split.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_split)
	
	# Left panel - Universe tree and info
	var left_panel = VSplitContainer.new()
	left_panel.custom_minimum_size.x = 300
	main_split.add_child(left_panel)
	
	# Universe hierarchy tree
	_create_universe_tree(left_panel)
	
	# Info panel
	_create_info_panel(left_panel)
	
	# Right side - Viewport and controls
	var right_container = VBoxContainer.new()
	main_split.add_child(right_container)
	
	# Control panel at top
	_create_control_panel(right_container)
	
	# Viewport container
	_create_viewport_container(right_container)

func _create_universe_tree(parent: Control) -> void:
	"""Create universe hierarchy tree"""
	var tree_panel = Panel.new()
	tree_panel.custom_minimum_size.y = 400
	parent.add_child(tree_panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tree_panel.add_child(vbox)
	
	var label = Label.new()
	label.text = "🌌 Universe Hierarchy"
	label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(label)
	
	universe_tree = Tree.new()
	universe_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	universe_tree.connect("item_selected", _on_universe_selected)
	vbox.add_child(universe_tree)
	
	# Create root
	var root = universe_tree.create_item()
	universe_tree.hide_root = true

func _create_info_panel(parent: Control) -> void:
	"""Create universe info panel"""
	info_panel = Panel.new()
	info_panel.custom_minimum_size.y = 300
	parent.add_child(info_panel)
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	info_panel.add_child(scroll)
	
	var info_label = RichTextLabel.new()
	info_label.name = "InfoLabel"
	info_label.bbcode_enabled = true
	info_label.fit_content = true
	scroll.add_child(info_label)

func _create_control_panel(parent: Control) -> void:
	"""Create simulation control panel"""
	control_panel = Panel.new()
	control_panel.custom_minimum_size.y = 80
	parent.add_child(control_panel)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 20)
	control_panel.add_child(hbox)
	
	# Play/Pause button
	var play_pause = Button.new()
	play_pause.text = "⏸️"
	play_pause.custom_minimum_size = Vector2(60, 60)
	play_pause.connect("pressed", _toggle_simulation)
	hbox.add_child(play_pause)
	
	# Speed controls
	var speed_container = VBoxContainer.new()
	hbox.add_child(speed_container)
	
	var speed_label = Label.new()
	speed_label.text = "Simulation Speed: 1.0x"
	speed_label.name = "SpeedLabel"
	speed_container.add_child(speed_label)
	
	var speed_slider = HSlider.new()
	speed_slider.min_value = 0.1
	speed_slider.max_value = 10.0
	speed_slider.value = 1.0
	speed_slider.custom_minimum_size.x = 200
	speed_slider.connect("value_changed", _on_speed_changed)
	speed_container.add_child(speed_slider)
	
	# Timeline controls
	var timeline_container = VBoxContainer.new()
	hbox.add_child(timeline_container)
	
	var timeline_label = Label.new()
	timeline_label.text = "Timeline: 0.0s"
	timeline_label.name = "TimelineLabel"
	timeline_container.add_child(timeline_label)
	
	timeline_slider = HSlider.new()
	timeline_slider.min_value = 0.0
	timeline_slider.max_value = 3600.0  # 1 hour
	timeline_slider.custom_minimum_size.x = 300
	timeline_slider.connect("value_changed", _on_timeline_changed)
	timeline_container.add_child(timeline_slider)
	
	# Zoom controls
	var zoom_container = VBoxContainer.new()
	hbox.add_child(zoom_container)
	
	var zoom_label = Label.new()
	zoom_label.text = "Zoom: 1.0x"
	zoom_label.name = "ZoomLabel"
	zoom_container.add_child(zoom_label)
	
	zoom_slider = HSlider.new()
	zoom_slider.min_value = 0.1
	zoom_slider.max_value = 10.0
	zoom_slider.value = 1.0
	zoom_slider.custom_minimum_size.x = 150
	zoom_slider.connect("value_changed", _on_zoom_changed)
	zoom_container.add_child(zoom_slider)

func _create_viewport_container(parent: Control) -> void:
	"""Create the viewport for universe visualization"""
	var viewport_container = SubViewportContainer.new()
	viewport_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	viewport_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(viewport_container)
	
	universe_viewport = SubViewport.new()
	universe_viewport.size = Vector2(800, 600)
	viewport_container.add_child(universe_viewport)

func _setup_viewport() -> void:
	"""Setup the viewport camera and environment"""
	# Create camera
	universe_camera = Camera3D.new()
	universe_camera.position = Vector3(0, 10, 20)
	universe_camera.look_at(Vector3.ZERO, Vector3.UP)
	universe_camera.fov = 60
	universe_viewport.add_child(universe_camera)
	
	# Add lighting
	var light = DirectionalLight3D.new()
	light.rotation = Vector3(-PI/4, -PI/4, 0)
	universe_viewport.add_child(light)
	
	# Environment
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.05, 0.1)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.2, 0.2, 0.3)
	env.ambient_light_energy = 0.3
	
	universe_camera.environment = env

# ===== UNIVERSE LOADING =====

func load_universe(universe: UniverseUniversalBeing) -> void:
	"""Load a universe into the simulator"""
	if current_universe:
		_unload_current_universe()
	
	current_universe = universe
	universe_history.append(universe)
	
	# Add universe to viewport
	universe_viewport.add_child(universe)
	
	# Update UI
	_update_universe_tree()
	_update_info_panel()
	
	# Center camera on universe
	_center_camera_on_universe()
	
	universe_entered.emit(universe)
	
	print("🌌 Loaded universe: %s" % universe.being_name)

func enter_child_universe(child_universe: UniverseUniversalBeing) -> void:
	"""Enter a child universe (go deeper)"""
	view_depth += 1
	load_universe(child_universe)
	
	# Visual transition effect
	_play_universe_transition(true)

func exit_to_parent_universe() -> void:
	"""Exit to parent universe (go up)"""
	if universe_history.size() > 1:
		universe_history.pop_back()
		var parent = universe_history[-1]
		view_depth -= 1
		load_universe(parent)
		
		# Visual transition effect
		_play_universe_transition(false)

# ===== SIMULATION CONTROL =====

func _toggle_simulation() -> void:
	"""Toggle simulation play/pause"""
	var button = control_panel.get_node("HBoxContainer/Button")
	if simulation_speed > 0:
		simulation_speed = 0
		button.text = "▶️"
	else:
		simulation_speed = 1.0
		button.text = "⏸️"
	
	simulation_speed_changed.emit(simulation_speed)

func _on_speed_changed(value: float) -> void:
	"""Handle simulation speed change"""
	simulation_speed = value
	var label = control_panel.get_node("HBoxContainer/VBoxContainer/SpeedLabel")
	label.text = "Simulation Speed: %.1fx" % value
	
	# Apply to current universe
	if current_universe:
		current_universe.time_scale = value
	
	simulation_speed_changed.emit(simulation_speed)

func _on_timeline_changed(value: float) -> void:
	"""Handle timeline scrubbing"""
	var label = control_panel.get_node("HBoxContainer/VBoxContainer2/TimelineLabel")
	label.text = "Timeline: %.1fs" % value
	
	# TODO: Implement timeline scrubbing

func _on_zoom_changed(value: float) -> void:
	"""Handle camera zoom"""
	var label = control_panel.get_node("HBoxContainer/VBoxContainer3/ZoomLabel")
	label.text = "Zoom: %.1fx" % value
	
	if universe_camera:
		var base_distance = 20.0
		universe_camera.position = universe_camera.position.normalized() * (base_distance / value)

# ===== UI UPDATES =====

func _update_universe_tree() -> void:
	"""Update the universe hierarchy tree"""
	universe_tree.clear()
	var root = universe_tree.create_item()
	
	# Find all universes
	var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
	if not flood_gates:
		return
	
	var all_beings = flood_gates.get_all_beings()
	var universes = []
	
	for being in all_beings:
		if being is UniverseUniversalBeing:
			universes.append(being)
	
	# Build tree
	for universe in universes:
		var item = universe_tree.create_item(root)
		item.set_text(0, "🌌 " + universe.being_name)
		item.set_metadata(0, universe)
		
		# Color based on type
		var universe_type = universe.get("universe_type") if universe.has_method("get") else "sandbox"
		if universe_type in universe_colors:
			item.set_custom_color(0, universe_colors[universe_type])
		
		# Mark current universe
		if universe == current_universe:
			item.set_custom_bg_color(0, Color(0.3, 0.3, 0.5, 0.5))

func _update_info_panel() -> void:
	"""Update universe information panel"""
	var info_label = info_panel.get_node("ScrollContainer/InfoLabel")
	if not info_label or not current_universe:
		return
	
	var info_text = "[b]🌌 Universe: %s[/b]\n\n" % current_universe.being_name
	
	# Basic properties
	info_text += "[color=cyan]Properties:[/color]\n"
	info_text += "• Physics Scale: %.2fx\n" % current_universe.physics_scale
	info_text += "• Time Scale: %.2fx\n" % current_universe.time_scale
	info_text += "• LOD Level: %d\n" % current_universe.lod_level
	info_text += "• View Depth: %d\n\n" % view_depth
	
	# Universe DNA
	if current_universe.has_method("get_universe_dna"):
		var dna = current_universe.get_universe_dna()
		if dna:
			info_text += "[color=green]DNA Traits:[/color]\n"
			if dna.has("physics_traits"):
				info_text += "• Gravity Variance: %.2f\n" % dna.physics_traits.get("gravity_variance", 1.0)
				info_text += "• Time Elasticity: %.2f\n" % dna.physics_traits.get("time_elasticity", 1.0)
			if dna.has("consciousness_traits"):
				info_text += "• Awareness Level: %d\n" % dna.consciousness_traits.get("awareness_level", 0)
				info_text += "• Creativity: %.2f\n" % dna.consciousness_traits.get("creativity_factor", 0.0)
	
	# Child universes
	info_text += "\n[color=yellow]Child Universes:[/color] %d\n" % current_universe.child_universes.size()
	
	# Beings in universe
	var being_count = 0
	for child in current_universe.get_children():
		if child is UniversalBeing:
			being_count += 1
	info_text += "[color=magenta]Beings:[/color] %d\n" % being_count
	
	info_label.text = info_text

# ===== VISUAL EFFECTS =====

func _center_camera_on_universe() -> void:
	"""Center camera on current universe"""
	if not universe_camera or not current_universe:
		return
	
	# Calculate bounding box of universe contents
	var bounds_min = Vector3.INF
	var bounds_max = -Vector3.INF
	
	for child in current_universe.get_children():
		if child is Node3D:
			bounds_min = bounds_min.min(child.position)
			bounds_max = bounds_max.max(child.position)
	
	var center = (bounds_min + bounds_max) / 2.0
	var size = (bounds_max - bounds_min).length()
	
	# Position camera
	var distance = max(20.0, size * 2.0)
	universe_camera.position = center + Vector3(0, distance * 0.7, distance)
	universe_camera.look_at(center, Vector3.UP)

func _play_universe_transition(entering: bool) -> void:
	"""Play transition effect when entering/exiting universes"""
	# Create transition overlay
	var overlay = ColorRect.new()
	overlay.color = Color.WHITE if entering else Color.BLACK
	overlay.modulate.a = 0.0
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	
	# Animate
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.3)
	tween.tween_callback(overlay.queue_free)

# ===== EVENT HANDLERS =====

func _on_universe_selected() -> void:
	"""Handle universe selection in tree"""
	var selected = universe_tree.get_selected()
	if not selected:
		return
	
	var universe = selected.get_metadata(0)
	if universe and universe is UniverseUniversalBeing:
		load_universe(universe)

func _unload_current_universe() -> void:
	"""Unload the current universe from viewport"""
	if current_universe and universe_viewport:
		universe_viewport.remove_child(current_universe)
		universe_exited.emit(current_universe)

# ===== SIMULATION HELPERS =====

func simulate_years(years: float) -> void:
	"""Fast-forward universe simulation"""
	if not current_universe:
		return
	
	print("🌌 Simulating %.1f years in universe '%s'..." % [years, current_universe.being_name])
	
	# Convert years to seconds (simplified)
	var seconds = years * 365.25 * 24 * 60 * 60
	var time_step = 1.0 / 60.0  # 60 FPS simulation
	var steps = int(seconds / time_step)
	
	# Run simulation
	for i in steps:
		if current_universe.has_method("pentagon_process"):
			current_universe.pentagon_process(time_step * current_universe.time_scale)
		
		# Update every 1000 steps
		if i % 1000 == 0:
			_update_info_panel()
			await get_tree().process_frame
	
	print("🌌 Simulation complete!")

# ===== PUBLIC API =====

func get_current_universe() -> UniverseUniversalBeing:
	"""Get the currently loaded universe"""
	return current_universe

func get_view_depth() -> int:
	"""Get current recursive view depth"""
	return view_depth

func get_simulation_speed() -> float:
	"""Get current simulation speed"""
	return simulation_speed
