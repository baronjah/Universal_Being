# ==================================================
# SCRIPT NAME: InteractiveTestEnvironment.gd
# DESCRIPTION: Interactive test environment for Universal Being physics and interactions
# PURPOSE: Demonstrate and test merge, split, evolution, creation mechanics
# CREATED: 2025-06-03 - Universal Being Evolution Testing
# ==================================================

extends UniversalBeing
class_name InteractiveTestEnvironment

# ===== TEST ENVIRONMENT PROPERTIES =====

var test_beings: Array[UniversalBeing] = []
var interaction_logs: Array[String] = []
var test_arena_size: Vector3 = Vector3(20, 0, 20)
var auto_spawn_timer: float = 0.0
var auto_spawn_interval: float = 5.0
var max_test_beings: int = 10

# UI Elements
var ui_panel: Panel = null
var log_display: RichTextLabel = null
var controls_display: Label = null
var stats_display: Label = null

# Test mode settings
var auto_spawn_enabled: bool = true
var debug_mode: bool = true
var interaction_visualization: bool = true

# Visual effects
var interaction_lines: Array[Node3D] = []
var resonance_indicators: Array[Node3D] = []

signal test_interaction_occurred(being1: UniversalBeing, being2: UniversalBeing, interaction_type: String)
signal test_being_created(being: UniversalBeing)
signal test_being_evolved(being: UniversalBeing, old_level: int, new_level: int)

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Interactive Test Environment"
	being_type = "test_environment"
	consciousness_level = 7
	
	# Initialize test environment
	_setup_test_arena()
	_create_ui()
	_spawn_initial_beings()
	
	print("🧪 Interactive Test Environment: Initialized")
	print("🧪 Arena size: %s" % test_arena_size)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Connect to being signals to monitor interactions
	for being in test_beings:
		_connect_being_signals(being)
	
	# Log genesis moment
	_log_interaction("🧪 Test Environment ready - Universal Being mechanics demonstration begins!")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Auto-spawn new beings periodically
	if auto_spawn_enabled:
		auto_spawn_timer += delta
		if auto_spawn_timer >= auto_spawn_interval and test_beings.size() < max_test_beings:
			_spawn_random_test_being()
			auto_spawn_timer = 0.0
	
	# Update visual effects
	_update_interaction_visualizations()
	
	# Update UI displays
	_update_ui_displays()
	
	# Clean up invalid beings
	_cleanup_invalid_beings()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: # Spawn consciousness level 1 being
				_spawn_test_being(1)
			KEY_2: # Spawn consciousness level 2 being
				_spawn_test_being(2)
			KEY_3: # Spawn consciousness level 3 being
				_spawn_test_being(3)
			KEY_4: # Spawn consciousness level 4 being
				_spawn_test_being(4)
			KEY_5: # Spawn consciousness level 5 being
				_spawn_test_being(5)
			KEY_C: # Clear all test beings
				_clear_all_beings()
			KEY_A: # Toggle auto-spawn
				_toggle_auto_spawn()
			KEY_V: # Toggle interaction visualization
				_toggle_interaction_visualization()
			KEY_R: # Reset environment
				_reset_environment()
			KEY_F: # Force random interactions
				_force_random_interactions()

func _setup_test_arena() -> void:
	"""Setup the test arena boundaries and visual indicators"""
	# Create arena floor visualization
	var floor_mesh = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(test_arena_size.x, test_arena_size.z)
	floor_mesh.mesh = plane_mesh
	
	var floor_material = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.1, 0.1, 0.2, 0.5)
	floor_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	floor_material.emission_enabled = true
	floor_material.emission = Color(0.0, 0.2, 0.4)
	floor_material.emission_energy = 0.3
	floor_mesh.set_surface_override_material(0, floor_material)
	
	add_child(floor_mesh)
	
	# Create boundary markers
	_create_boundary_markers()

func _create_boundary_markers() -> void:
	"""Create visual markers for arena boundaries"""
	var boundary_points = [
		Vector3(-test_arena_size.x/2, 1, -test_arena_size.z/2),
		Vector3(test_arena_size.x/2, 1, -test_arena_size.z/2),
		Vector3(test_arena_size.x/2, 1, test_arena_size.z/2),
		Vector3(-test_arena_size.x/2, 1, test_arena_size.z/2)
	]
	
	for i in range(boundary_points.size()):
		var marker = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.3
		marker.mesh = sphere_mesh
		marker.position = boundary_points[i]
		
		var marker_material = StandardMaterial3D.new()
		marker_material.albedo_color = Color.CYAN
		marker_material.emission_enabled = true
		marker_material.emission = Color.CYAN
		marker_material.emission_energy = 0.5
		marker.set_surface_override_material(0, marker_material)
		
		add_child(marker)

func _create_ui() -> void:
	"""Create the UI panel for test controls and information"""
	# Create UI panel
	ui_panel = Panel.new()
	ui_panel.name = "TestEnvironmentUI"
	ui_panel.size = Vector2(400, 600)
	ui_panel.position = Vector2(20, 20)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.0, 0.0, 0.1, 0.8)
	panel_style.border_color = Color.CYAN
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	ui_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Create vertical layout
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	ui_panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "🧪 Interactive Test Environment"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color.CYAN)
	vbox.add_child(title)
	
	# Controls
	controls_display = Label.new()
	controls_display.text = """🎮 Controls:
1-5: Spawn being (consciousness level)
C: Clear all beings
A: Toggle auto-spawn
V: Toggle interaction visualization
R: Reset environment
F: Force random interactions"""
	controls_display.add_theme_font_size_override("font_size", 12)
	controls_display.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(controls_display)
	
	# Stats display
	stats_display = Label.new()
	stats_display.add_theme_font_size_override("font_size", 12)
	stats_display.add_theme_color_override("font_color", Color.YELLOW)
	vbox.add_child(stats_display)
	
	# Log display
	var log_label = Label.new()
	log_label.text = "📝 Interaction Log:"
	log_label.add_theme_font_size_override("font_size", 14)
	log_label.add_theme_color_override("font_color", Color.GREEN)
	vbox.add_child(log_label)
	
	log_display = RichTextLabel.new()
	log_display.bbcode_enabled = true
	log_display.scroll_following = true
	log_display.custom_minimum_size = Vector2(0, 300)
	log_display.add_theme_color_override("default_color", Color.WHITE)
	vbox.add_child(log_display)
	
	# Add to scene tree (find the main UI layer)
	var main = get_tree().get_first_node_in_group("main")
	if main:
		main.add_child(ui_panel)
	else:
		# Fallback: add to parent
		if get_parent():
			get_parent().add_child(ui_panel)

func _spawn_initial_beings() -> void:
	"""Spawn initial test beings with different consciousness levels"""
	var initial_beings = [
		{"level": 1, "position": Vector3(-5, 2, -5)},
		{"level": 2, "position": Vector3(5, 2, -5)},
		{"level": 3, "position": Vector3(-5, 2, 5)},
		{"level": 4, "position": Vector3(5, 2, 5)},
		{"level": 2, "position": Vector3(0, 2, 0)}
	]
	
	for being_data in initial_beings:
		var being = _create_test_being(being_data.level)
		if being:
			being.position = being_data.position
			_log_interaction("🌟 Spawned initial being: %s (Level %d)" % [being.being_name, being.consciousness_level])

func _spawn_test_being(consciousness_level: int) -> UniversalBeing:
	"""Spawn a test being with specified consciousness level"""
	var being = _create_test_being(consciousness_level)
	if being:
		# Random position within arena
		being.position = Vector3(
			randf_range(-test_arena_size.x/2 + 2, test_arena_size.x/2 - 2),
			2,
			randf_range(-test_arena_size.z/2 + 2, test_arena_size.z/2 - 2)
		)
		_log_interaction("✨ Manual spawn: %s (Level %d)" % [being.being_name, being.consciousness_level])
	return being

func _spawn_random_test_being() -> UniversalBeing:
	"""Spawn a random test being"""
	var random_level = randi_range(1, 5)
	var being = _spawn_test_being(random_level)
	if being:
		_log_interaction("🎲 Auto-spawn: %s (Level %d)" % [being.being_name, being.consciousness_level])
	return being

func _create_test_being(consciousness_level: int) -> UniversalBeing:
	"""Create a new test being with visual representation"""
	var being = UniversalBeing.new()
	being.being_name = "TestBeing_%d" % test_beings.size()
	being.being_type = "test_subject"
	being.consciousness_level = consciousness_level
	
	# Add visual representation
	var visual = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.5 + (consciousness_level * 0.1)
	visual.mesh = sphere_mesh
	
	# Apply consciousness-based material
	var material = StandardMaterial3D.new()
	material.albedo_color = being._get_consciousness_color()
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_energy = 0.3 + (consciousness_level * 0.1)
	visual.set_surface_override_material(0, material)
	
	being.add_child(visual)
	
	# Add to scene and tracking
	add_child(being)
	test_beings.append(being)
	_connect_being_signals(being)
	
	test_being_created.emit(being)
	return being

func _connect_being_signals(being: UniversalBeing) -> void:
	"""Connect to being signals to monitor interactions"""
	if not being.state_changed.is_connected(_on_being_state_changed):
		being.state_changed.connect(_on_being_state_changed.bind(being))
	
	if not being.being_entered_proximity.is_connected(_on_being_proximity_entered):
		being.being_entered_proximity.connect(_on_being_proximity_entered.bind(being))
	
	if not being.collision_detected.is_connected(_on_being_collision_detected):
		being.collision_detected.connect(_on_being_collision_detected.bind(being))
	
	if not being.interaction_initiated.is_connected(_on_interaction_initiated):
		being.interaction_initiated.connect(_on_interaction_initiated.bind(being))

func _on_being_state_changed(being: UniversalBeing, old_state: UniversalBeing.BeingState, new_state: UniversalBeing.BeingState) -> void:
	"""Handle being state changes"""
	var old_name = being._state_to_string(old_state)
	var new_name = being._state_to_string(new_state)
	_log_interaction("🧠 %s: %s → %s" % [being.being_name, old_name, new_name])
	
	# Special handling for evolution
	if new_state == UniversalBeing.BeingState.EVOLVING:
		_log_interaction("🦋 %s is attempting evolution!" % being.being_name)

func _on_being_proximity_entered(being: UniversalBeing, other_being: UniversalBeing) -> void:
	"""Handle proximity detection"""
	var resonance = being._calculate_consciousness_resonance(other_being)
	_log_interaction("📡 Proximity: %s ↔ %s (Resonance: %.2f)" % [being.being_name, other_being.being_name, resonance])
	
	# Create visual connection if resonance is high
	if resonance > 0.6 and interaction_visualization:
		_create_resonance_line(being, other_being, resonance)

func _on_being_collision_detected(being: UniversalBeing, other_being: UniversalBeing) -> void:
	"""Handle collision detection"""
	_log_interaction("💥 Collision: %s ⚡ %s" % [being.being_name, other_being.being_name])
	test_interaction_occurred.emit(being, other_being, "collision")

func _on_interaction_initiated(being: UniversalBeing, other_being: UniversalBeing, interaction_type: String) -> void:
	"""Handle interaction initiation"""
	_log_interaction("🤝 Interaction: %s %s %s" % [being.being_name, interaction_type, other_being.being_name])
	test_interaction_occurred.emit(being, other_being, interaction_type)
	
	# Special logging for different interaction types
	match interaction_type:
		"merge":
			_log_interaction("🌊 MERGE initiated between consciousness levels %d and %d!" % [being.consciousness_level, other_being.consciousness_level])
		"consciousness_transfer":
			_log_interaction("⚡ CONSCIOUSNESS TRANSFER in progress!")
		"evolution_trigger":
			_log_interaction("🦋 EVOLUTION triggered by interaction!")

func _create_resonance_line(being1: UniversalBeing, being2: UniversalBeing, resonance: float) -> void:
	"""Create visual line showing consciousness resonance"""
	var line_node = Node3D.new()
	line_node.name = "ResonanceLine_%s_%s" % [being1.being_name, being2.being_name]
	
	# Create line mesh
	var mesh_instance = MeshInstance3D.new()
	var array_mesh = ArrayMesh.new()
	var vertices = PackedVector3Array()
	var colors = PackedColorArray()
	
	vertices.append(being1.position)
	vertices.append(being2.position)
	
	var line_color = Color(resonance, 1.0 - resonance, 0.5, 0.7)
	colors.append(line_color)
	colors.append(line_color)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	mesh_instance.mesh = array_mesh
	
	line_node.add_child(mesh_instance)
	add_child(line_node)
	resonance_indicators.append(line_node)
	
	# Auto-remove after short time
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func(): 
		if is_instance_valid(line_node):
			line_node.queue_free()
			resonance_indicators.erase(line_node)
	)

func _update_interaction_visualizations() -> void:
	"""Update visual effects for interactions"""
	# Clean up expired visualization elements
	for i in range(resonance_indicators.size() - 1, -1, -1):
		var indicator = resonance_indicators[i]
		if not is_instance_valid(indicator):
			resonance_indicators.remove_at(i)

func _update_ui_displays() -> void:
	"""Update UI displays with current stats"""
	if stats_display:
		var active_beings = test_beings.size()
		var total_consciousness = 0
		var state_counts = {}
		
		for being in test_beings:
			if is_instance_valid(being):
				total_consciousness += being.consciousness_level
				var state_name = being._state_to_string(being.current_state)
				state_counts[state_name] = state_counts.get(state_name, 0) + 1
		
		var avg_consciousness = total_consciousness / float(max(active_beings, 1))
		
		var stats_text = """📊 Environment Stats:
Active Beings: %d/%d
Total Consciousness: %d
Average Level: %.1f
Auto-spawn: %s

🧠 Being States:""" % [active_beings, max_test_beings, total_consciousness, avg_consciousness, "ON" if auto_spawn_enabled else "OFF"]
		
		for state_name in state_counts:
			stats_text += "\n%s: %d" % [state_name, state_counts[state_name]]
		
		stats_display.text = stats_text

func _cleanup_invalid_beings() -> void:
	"""Remove invalid beings from tracking"""
	for i in range(test_beings.size() - 1, -1, -1):
		var being = test_beings[i]
		if not is_instance_valid(being):
			test_beings.remove_at(i)

func _log_interaction(message: String) -> void:
	"""Log interaction message to display and console"""
	var timestamp = Time.get_datetime_string_from_system().split(" ")[1].substr(0, 8)
	var log_entry = "[%s] %s" % [timestamp, message]
	
	interaction_logs.append(log_entry)
	print("🧪 " + log_entry)
	
	# Keep log size manageable
	if interaction_logs.size() > 50:
		interaction_logs.pop_front()
	
	# Update log display
	if log_display:
		var display_text = ""
		for log in interaction_logs:
			display_text += log + "\n"
		log_display.text = display_text

func _clear_all_beings() -> void:
	"""Clear all test beings"""
	_log_interaction("🧹 Clearing all test beings...")
	
	for being in test_beings:
		if is_instance_valid(being):
			being.queue_free()
	
	test_beings.clear()
	
	# Clear visual effects
	for indicator in resonance_indicators:
		if is_instance_valid(indicator):
			indicator.queue_free()
	resonance_indicators.clear()

func _toggle_auto_spawn() -> void:
	"""Toggle auto-spawn mode"""
	auto_spawn_enabled = !auto_spawn_enabled
	_log_interaction("🎲 Auto-spawn: %s" % ("ENABLED" if auto_spawn_enabled else "DISABLED"))

func _toggle_interaction_visualization() -> void:
	"""Toggle interaction visualization"""
	interaction_visualization = !interaction_visualization
	_log_interaction("👁️ Interaction visualization: %s" % ("ENABLED" if interaction_visualization else "DISABLED"))

func _reset_environment() -> void:
	"""Reset the entire test environment"""
	_log_interaction("🔄 Resetting test environment...")
	_clear_all_beings()
	auto_spawn_timer = 0.0
	interaction_logs.clear()
	_spawn_initial_beings()

func _force_random_interactions() -> void:
	"""Force random beings to interact for testing"""
	_log_interaction("⚡ Forcing random interactions...")
	
	var valid_beings = []
	for being in test_beings:
		if is_instance_valid(being):
			valid_beings.append(being)
	
	if valid_beings.size() < 2:
		_log_interaction("❌ Need at least 2 beings for forced interactions")
		return
	
	# Force a few random interactions
	for i in range(min(3, valid_beings.size() / 2)):
		var being1 = valid_beings[randi() % valid_beings.size()]
		var being2 = valid_beings[randi() % valid_beings.size()]
		
		if being1 != being2:
			# Move beings closer to trigger interaction
			var midpoint = (being1.position + being2.position) / 2
			being1.position = midpoint + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
			being2.position = midpoint + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
			
			# Force them to thinking state to trigger interactions
			being1.change_state(UniversalBeing.BeingState.THINKING, "forced interaction test")
			being2.change_state(UniversalBeing.BeingState.THINKING, "forced interaction test")

func get_test_summary() -> Dictionary:
	"""Get summary of test results"""
	var summary = {
		"total_beings_created": test_beings.size(),
		"interaction_count": interaction_logs.size(),
		"consciousness_levels": {},
		"active_states": {},
		"resonance_connections": resonance_indicators.size()
	}
	
	for being in test_beings:
		if is_instance_valid(being):
			var level = being.consciousness_level
			summary.consciousness_levels[level] = summary.consciousness_levels.get(level, 0) + 1
			
			var state = being._state_to_string(being.current_state)
			summary.active_states[state] = summary.active_states.get(state, 0) + 1
	
	return summary

func pentagon_sewers() -> void:
	"""Cleanup test environment"""
	_clear_all_beings()
	
	if ui_panel and is_instance_valid(ui_panel):
		ui_panel.queue_free()
	
	super.pentagon_sewers()
