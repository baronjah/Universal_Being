# ==================================================
# UNIVERSAL BEING: LIVING DATABASE VISUALIZER
# TYPE: Backend-as-Frontend Consciousness Data Visualization
# PURPOSE: Make the invisible database visible and interactive
# INSPIRED BY: Matrix + Blender + Your Dream Interface
# ==================================================

extends Node3D
class_name LivingDatabaseVisualizer

## 🌌 LIVING DATABASE - Where Backend Becomes Frontend
## See consciousness data flows, gravity points, input streams in real-time
## Copy/paste reality like Blender with visible data manipulation

# ===== VISUALIZATION CONFIGURATION =====
@export var database_visualization_enabled: bool = true
@export var gravity_points_visible: bool = true
@export var input_streams_visible: bool = true
@export var consciousness_flows_visible: bool = true
@export var reality_editing_enabled: bool = true

# Database Point Types
enum DataPointType {
	CONSCIOUSNESS_DATA,     # Purple flowing points
	GRAVITY_FIELD,         # Orange sphere with falloff
	INPUT_STREAM,          # Green flowing keystrokes
	PHYSICS_CALCULATION,   # Blue computational nodes
	AI_THOUGHT,            # Pink thought bubbles
	MEMORY_ACCESS,         # Cyan database queries
	REALITY_ANCHOR         # Gold fixed reference points
}

# ===== LIVING DATA POINTS =====
class DatabasePoint:
	var point_type: DataPointType
	var world_position: Vector3
	var data_value: Variant
	var consciousness_level: float = 1.0
	var life_time: float = 5.0
	var current_age: float = 0.0
	var flow_velocity: Vector3 = Vector3.ZERO
	var visual_node: Node3D = null
	var gravity_radius: float = 1.0
	var falloff_strength: float = 1.0
	
	func _init(type: DataPointType, pos: Vector3, data: Variant):
		point_type = type
		world_position = pos
		data_value = data
		_set_type_properties()
	
	func _set_type_properties():
		match point_type:
			DataPointType.GRAVITY_FIELD:
				gravity_radius = 5.0
				falloff_strength = 2.0
				life_time = 30.0
			DataPointType.INPUT_STREAM:
				flow_velocity = Vector3(randf_range(-2, 2), 1.0, randf_range(-2, 2))
				life_time = 3.0
			DataPointType.CONSCIOUSNESS_DATA:
				flow_velocity = Vector3(0, randf_range(0.5, 1.5), 0)
				consciousness_level = randf_range(1.0, 5.0)
				life_time = 8.0
			DataPointType.AI_THOUGHT:
				flow_velocity = Vector3(randf_range(-1, 1), 0.5, randf_range(-1, 1))
				life_time = 10.0

# ===== DATABASE STATE =====
var active_data_points: Array[DatabasePoint] = []
var gravity_points: Array[DatabasePoint] = []
var input_history: Array[DatabasePoint] = []
var consciousness_streams: Array[DatabasePoint] = []

# Reality Editing System
var blender_mode: bool = false
var selected_objects: Array[Node3D] = []
var copy_buffer: Array[Dictionary] = []
var edit_cursor: Node3D

# Visual Components
var data_point_material: StandardMaterial3D
var gravity_sphere_material: StandardMaterial3D
var input_stream_material: StandardMaterial3D
var consciousness_material: StandardMaterial3D

# Performance Management
var max_visible_points: int = 500
var octree_depth: int = 6
var lod_distances: Array[float] = [10.0, 25.0, 50.0, 100.0]

# UI References
var database_ui: Control
var gravity_slider: HSlider
var data_flow_toggle: CheckBox

# ===== PENTAGON ARCHITECTURE =====

func _ready() -> void:
	setup_living_database()
	initialize_materials()
	setup_reality_editing_cursor()
	create_database_ui()
	connect_to_universal_being_systems()
	
	print("🌌 Living Database Visualizer: Backend is now frontend!")

func _process(delta: float) -> void:
	if database_visualization_enabled:
		update_data_point_flows(delta)
		update_gravity_field_visualization(delta)
		process_consciousness_streams(delta)
		update_input_stream_visualization(delta)
		
		# Performance optimization
		manage_lod_system(delta)
		cleanup_expired_points(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Visualize every keystroke as floating data
		if input_streams_visible:
			create_input_stream_point(event)
		
		# Blender-like reality editing controls
		match event.keycode:
			KEY_B:  # Toggle Blender mode
				if event.ctrl_pressed:
					toggle_blender_mode()
			KEY_G:  # Grab/Move mode
				if blender_mode and event.pressed:
					enter_grab_mode()
			KEY_C:  # Copy
				if blender_mode and event.ctrl_pressed:
					copy_selected_objects()
			KEY_V:  # Paste
				if blender_mode and event.ctrl_pressed:
					paste_objects_at_cursor()
			KEY_X:  # Delete
				if blender_mode and event.pressed:
					delete_selected_objects()
	
	if event is InputEventMouseButton and blender_mode:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			select_object_at_cursor()

# ===== DATABASE VISUALIZATION SETUP =====

func setup_living_database() -> void:
	"""Initialize the living database visualization system"""
	# Create data point container
	var data_container = Node3D.new()
	data_container.name = "DatabasePoints"
	add_child(data_container)
	
	# Create gravity field container
	var gravity_container = Node3D.new()
	gravity_container.name = "GravityFields"
	add_child(gravity_container)
	
	# Create consciousness flow container
	var consciousness_container = Node3D.new()
	consciousness_container.name = "ConsciousnessStreams"
	add_child(consciousness_container)
	
	print("🗄️ Living database containers initialized")

func initialize_materials() -> void:
	"""Create materials for different data point types"""
	# Consciousness data - purple flowing
	consciousness_material = StandardMaterial3D.new()
	consciousness_material.albedo_color = Color(0.8, 0.3, 1.0, 0.8)
	consciousness_material.emission_enabled = true
	consciousness_material.emission = Color(0.5, 0.1, 0.8)
	consciousness_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# Gravity fields - orange with falloff
	gravity_sphere_material = StandardMaterial3D.new()
	gravity_sphere_material.albedo_color = Color(1.0, 0.6, 0.2, 0.3)
	gravity_sphere_material.emission_enabled = true
	gravity_sphere_material.emission = Color(1.0, 0.4, 0.0)
	gravity_sphere_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# Input streams - green flowing data
	input_stream_material = StandardMaterial3D.new()
	input_stream_material.albedo_color = Color(0.2, 1.0, 0.3, 0.9)
	input_stream_material.emission_enabled = true
	input_stream_material.emission = Color(0.1, 0.8, 0.1)
	
	# General data points - cyan database queries
	data_point_material = StandardMaterial3D.new()
	data_point_material.albedo_color = Color(0.2, 0.8, 1.0, 0.7)
	data_point_material.emission_enabled = true
	data_point_material.emission = Color(0.0, 0.6, 1.0)
	
	print("💎 Database visualization materials created")

# ===== DATA POINT CREATION =====

func create_consciousness_data_point(position: Vector3, data: Variant, level: float = 1.0) -> DatabasePoint:
	"""Create a consciousness data point in 3D space"""
	var point = DatabasePoint.new(DataPointType.CONSCIOUSNESS_DATA, position, data)
	point.consciousness_level = level
	
	# Create visual representation
	var sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.1 + (level * 0.05)
	sphere.mesh = sphere_mesh
	sphere.material_override = consciousness_material
	sphere.position = position
	
	# Add flowing particle effect
	var particles = GPUParticles3D.new()
	particles.emitting = true
	particles.amount = int(level * 10)
	sphere.add_child(particles)
	
	point.visual_node = sphere
	get_node("DatabasePoints").add_child(sphere)
	active_data_points.append(point)
	consciousness_streams.append(point)
	
	print("💭 Consciousness data point created: level %.1f at %s" % [level, position])
	return point

func create_gravity_point(position: Vector3, radius: float = 5.0, strength: float = 1.0) -> DatabasePoint:
	"""Create a gravity point with visible diameter falloff"""
	var point = DatabasePoint.new(DataPointType.GRAVITY_FIELD, position, {"radius": radius, "strength": strength})
	point.gravity_radius = radius
	point.falloff_strength = strength
	
	# Create main gravity sphere
	var gravity_sphere = MeshInstance3D.new()
	var gravity_mesh = SphereMesh.new()
	gravity_mesh.radius = 0.3
	gravity_sphere.mesh = gravity_mesh
	gravity_sphere.material_override = gravity_sphere_material
	gravity_sphere.position = position
	
	# Create falloff visualization sphere
	var falloff_sphere = MeshInstance3D.new()
	var falloff_mesh = SphereMesh.new()
	falloff_mesh.radius = radius
	falloff_sphere.mesh = falloff_mesh
	var falloff_material = gravity_sphere_material.duplicate()
	falloff_material.albedo_color.a = 0.1
	falloff_sphere.material_override = falloff_material
	falloff_sphere.position = position
	
	# Group them together
	var gravity_group = Node3D.new()
	gravity_group.name = "GravityPoint_" + str(Time.get_ticks_msec())
	gravity_group.add_child(gravity_sphere)
	gravity_group.add_child(falloff_sphere)
	
	point.visual_node = gravity_group
	get_node("GravityFields").add_child(gravity_group)
	active_data_points.append(point)
	gravity_points.append(point)
	
	print("🌍 Gravity point created: radius %.1f, strength %.1f at %s" % [radius, strength, position])
	return point

func create_input_stream_point(input_event: InputEvent) -> DatabasePoint:
	"""Create a floating data point for input events"""
	var camera = get_viewport().get_camera_3d()
	var start_pos = camera.global_position + camera.basis.z * -2.0
	
	var point = DatabasePoint.new(DataPointType.INPUT_STREAM, start_pos, input_event)
	
	# Create visual representation with text
	var input_visual = Node3D.new()
	
	# Key display
	var label = Label3D.new()
	if input_event is InputEventKey:
		label.text = OS.get_keycode_string(input_event.keycode)
	else:
		label.text = "INPUT"
	
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color.GREEN
	
	# Flowing cube
	var cube = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = Vector3(0.1, 0.1, 0.1)
	cube.mesh = cube_mesh
	cube.material_override = input_stream_material
	
	input_visual.add_child(cube)
	input_visual.add_child(label)
	input_visual.position = start_pos
	
	point.visual_node = input_visual
	get_node("DatabasePoints").add_child(input_visual)
	active_data_points.append(point)
	input_history.append(point)
	
	print("⌨️ Input stream point created: %s" % label.text)
	return point

# ===== DATA FLOW UPDATES =====

func update_data_point_flows(delta: float) -> void:
	"""Update flowing data points"""
	for point in active_data_points:
		if point.visual_node and is_instance_valid(point.visual_node):
			# Age the point
			point.current_age += delta
			
			# Move based on flow velocity
			point.world_position += point.flow_velocity * delta
			point.visual_node.position = point.world_position
			
			# Fade out over time
			var life_ratio = point.current_age / point.life_time
			if point.visual_node.get_child_count() > 0:
				var mesh = point.visual_node.get_child(0)
				if mesh is MeshInstance3D and mesh.material_override:
					var material = mesh.material_override as StandardMaterial3D
					material.albedo_color.a = 1.0 - life_ratio

func update_gravity_field_visualization(delta: float) -> void:
	"""Update gravity field effects"""
	for gravity_point in gravity_points:
		if not gravity_point.visual_node or not is_instance_valid(gravity_point.visual_node):
			continue
		
		# Pulsing effect
		var pulse = sin(Time.get_time_from_start() * 2.0) * 0.1 + 1.0
		gravity_point.visual_node.scale = Vector3.ONE * pulse
		
		# Attract nearby data points
		for data_point in active_data_points:
			if data_point.point_type == DataPointType.GRAVITY_FIELD:
				continue
			
			var distance = data_point.world_position.distance_to(gravity_point.world_position)
			if distance < gravity_point.gravity_radius:
				# Calculate falloff
				var falloff = 1.0 - (distance / gravity_point.gravity_radius)
				var attraction = (gravity_point.world_position - data_point.world_position).normalized()
				
				# Apply gravity effect
				data_point.flow_velocity += attraction * falloff * gravity_point.falloff_strength * delta

func process_consciousness_streams(delta: float) -> void:
	"""Process consciousness data streams"""
	# Create new consciousness data from Universal Being activity
	var universal_beings = get_tree().get_nodes_in_group("universal_beings")
	for being in universal_beings:
		if being.has_method("get_consciousness_level"):
			var level = being.get_consciousness_level()
			if level > 2.0 and randf() < delta * 0.1:  # 10% chance per second for high consciousness
				var pos = being.global_position + Vector3(randf_range(-2, 2), randf_range(1, 3), randf_range(-2, 2))
				create_consciousness_data_point(pos, {"source": being.name, "level": level}, level)

# ===== BLENDER-LIKE REALITY EDITING =====

func setup_reality_editing_cursor() -> void:
	"""Setup the 3D cursor for reality editing"""
	edit_cursor = MeshInstance3D.new()
	edit_cursor.mesh = SphereMesh.new()
	edit_cursor.mesh.radius = 0.2
	
	var cursor_material = StandardMaterial3D.new()
	cursor_material.albedo_color = Color.WHITE
	cursor_material.emission_enabled = true
	cursor_material.emission = Color.WHITE
	cursor_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cursor_material.albedo_color.a = 0.7
	
	edit_cursor.material_override = cursor_material
	edit_cursor.visible = false
	add_child(edit_cursor)

func toggle_blender_mode() -> void:
	"""Toggle Blender-like reality editing mode"""
	blender_mode = !blender_mode
	edit_cursor.visible = blender_mode
	
	if blender_mode:
		print("🎨 Blender Mode ACTIVE - Copy/paste reality objects!")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		print("🎨 Blender Mode OFF - Normal game mode")
		clear_selection()
	
	update_cursor_position()

func update_cursor_position() -> void:
	"""Update 3D cursor position"""
	if not blender_mode:
		return
	
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	
	# Raycast to find surface or use fixed distance
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * 50)
	var result = space_state.intersect_ray(query)
	
	if result:
		edit_cursor.global_position = result.position
	else:
		edit_cursor.global_position = ray_origin + ray_direction * 10.0

func copy_selected_objects() -> void:
	"""Copy selected objects to buffer"""
	copy_buffer.clear()
	
	for obj in selected_objects:
		if obj and is_instance_valid(obj):
			var obj_data = {
				"scene_path": obj.scene_file_path,
				"position": obj.position,
				"rotation": obj.rotation,
				"scale": obj.scale,
				"name": obj.name
			}
			copy_buffer.append(obj_data)
	
	print("📋 Copied %d objects to reality buffer" % copy_buffer.size())

func paste_objects_at_cursor() -> void:
	"""Paste objects from buffer at cursor position"""
	if copy_buffer.is_empty():
		print("📋 Nothing to paste - copy some objects first!")
		return
	
	var paste_position = edit_cursor.global_position
	
	for obj_data in copy_buffer:
		# Create new instance
		var new_obj: Node3D
		
		if obj_data.scene_path != "":
			var scene = load(obj_data.scene_path)
			if scene:
				new_obj = scene.instantiate()
		else:
			# Create basic spaceclay being if no scene
			new_obj = create_spaceclay_copy(obj_data)
		
		if new_obj:
			new_obj.position = paste_position + obj_data.position
			new_obj.rotation = obj_data.rotation
			new_obj.scale = obj_data.scale
			new_obj.name = obj_data.name + "_copy"
			
			get_tree().current_scene.add_child(new_obj)
			
			# Create consciousness data point for this creation
			create_consciousness_data_point(new_obj.global_position, {"action": "paste", "object": new_obj.name}, 3.0)
	
	print("📋 Pasted %d objects at cursor position" % copy_buffer.size())

func create_spaceclay_copy(obj_data: Dictionary) -> Node3D:
	"""Create a new spaceclay being as copy"""
	var new_obj = MeshInstance3D.new()
	var copy_mesh = BoxMesh.new()
	copy_mesh.size = Vector3.ONE
	new_obj.mesh = copy_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(randf(), randf(), randf())
	new_obj.material_override = material
	
	return new_obj

# ===== LOD AND PERFORMANCE =====

func manage_lod_system(delta: float) -> void:
	"""Manage LOD for database visualization points"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var camera_pos = camera.global_position
	
	for point in active_data_points:
		if not point.visual_node or not is_instance_valid(point.visual_node):
			continue
		
		var distance = point.world_position.distance_to(camera_pos)
		
		# LOD levels based on distance
		if distance < lod_distances[0]:  # Close - full detail
			point.visual_node.visible = true
			point.visual_node.scale = Vector3.ONE
		elif distance < lod_distances[1]:  # Medium - reduced detail
			point.visual_node.visible = true
			point.visual_node.scale = Vector3.ONE * 0.7
		elif distance < lod_distances[2]:  # Far - minimal detail
			point.visual_node.visible = true
			point.visual_node.scale = Vector3.ONE * 0.3
		else:  # Very far - invisible
			point.visual_node.visible = false

func cleanup_expired_points(delta: float) -> void:
	"""Remove expired data points"""
	var points_to_remove = []
	
	for point in active_data_points:
		if point.current_age >= point.life_time:
			points_to_remove.append(point)
	
	for point in points_to_remove:
		if point.visual_node and is_instance_valid(point.visual_node):
			point.visual_node.queue_free()
		
		active_data_points.erase(point)
		gravity_points.erase(point)
		input_history.erase(point)
		consciousness_streams.erase(point)
	
	# Limit total points for performance
	while active_data_points.size() > max_visible_points:
		var oldest_point = active_data_points[0]
		if oldest_point.visual_node and is_instance_valid(oldest_point.visual_node):
			oldest_point.visual_node.queue_free()
		active_data_points.erase(oldest_point)

# ===== SYSTEM INTEGRATION =====

func connect_to_universal_being_systems() -> void:
	"""Connect to existing Universal Being systems"""
	# Connect to Akashic Records for database activity
	var akashic = get_tree().get_first_node_in_group("akashic_records")
	if akashic and akashic.has_signal("data_accessed"):
		akashic.data_accessed.connect(_on_database_access)
	
	# Connect to consciousness systems
	var consciousness_systems = get_tree().get_nodes_in_group("consciousness_systems")
	for system in consciousness_systems:
		if system.has_signal("consciousness_changed"):
			system.consciousness_changed.connect(_on_consciousness_changed)

func _on_database_access(query_type: String, data_size: int, position: Vector3) -> void:
	"""Handle database access visualization"""
	var point = create_consciousness_data_point(position, {"query": query_type, "size": data_size}, 2.0)
	point.flow_velocity = Vector3(0, 2.0, 0)  # Flow upward

func _on_consciousness_changed(being: Node, old_level: float, new_level: float) -> void:
	"""Handle consciousness level changes"""
	if being.has_method("get_global_position"):
		var pos = being.global_position + Vector3(0, 1, 0)
		create_consciousness_data_point(pos, {"change": new_level - old_level}, new_level)

# ===== UI CREATION =====

func create_database_ui() -> void:
	"""Create UI for database visualization controls"""
	database_ui = Control.new()
	database_ui.name = "DatabaseUI"
	database_ui.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	
	var vbox = VBoxContainer.new()
	
	# Database visualization toggle
	var viz_toggle = CheckBox.new()
	viz_toggle.text = "Database Visualization"
	viz_toggle.button_pressed = database_visualization_enabled
	viz_toggle.toggled.connect(_on_database_viz_toggled)
	vbox.add_child(viz_toggle)
	
	# Gravity visualization toggle
	var gravity_toggle = CheckBox.new()
	gravity_toggle.text = "Gravity Points"
	gravity_toggle.button_pressed = gravity_points_visible
	gravity_toggle.toggled.connect(_on_gravity_viz_toggled)
	vbox.add_child(gravity_toggle)
	
	# Input streams toggle
	var input_toggle = CheckBox.new()
	input_toggle.text = "Input Streams"
	input_toggle.button_pressed = input_streams_visible
	input_toggle.toggled.connect(_on_input_viz_toggled)
	vbox.add_child(input_toggle)
	
	# Blender mode button
	var blender_button = Button.new()
	blender_button.text = "Toggle Blender Mode (Ctrl+B)"
	blender_button.pressed.connect(toggle_blender_mode)
	vbox.add_child(blender_button)
	
	database_ui.add_child(vbox)
	add_child(database_ui)

func _on_database_viz_toggled(enabled: bool) -> void:
	database_visualization_enabled = enabled

func _on_gravity_viz_toggled(enabled: bool) -> void:
	gravity_points_visible = enabled

func _on_input_viz_toggled(enabled: bool) -> void:
	input_streams_visible = enabled

# ===== PUBLIC API =====

func create_gravity_field_at_position(position: Vector3, radius: float = 5.0) -> DatabasePoint:
	"""Public API to create gravity field"""
	return create_gravity_point(position, radius, 1.0)

func visualize_database_query(query_type: String, position: Vector3, result_size: int) -> void:
	"""Visualize database query as flowing data"""
	var point = create_consciousness_data_point(position, {"query": query_type, "results": result_size}, 2.0)
	point.life_time = 5.0

func get_database_status() -> Dictionary:
	"""Get current database visualization status"""
	return {
		"active_points": active_data_points.size(),
		"gravity_points": gravity_points.size(),
		"consciousness_streams": consciousness_streams.size(),
		"input_history": input_history.size(),
		"blender_mode": blender_mode,
		"selected_objects": selected_objects.size(),
		"copy_buffer": copy_buffer.size()
	}

func _to_string() -> String:
	return "LivingDatabaseVisualizer [Points: %d, Gravity: %d, Blender: %s]" % [
		active_data_points.size(), gravity_points.size(), "ON" if blender_mode else "OFF"
	]