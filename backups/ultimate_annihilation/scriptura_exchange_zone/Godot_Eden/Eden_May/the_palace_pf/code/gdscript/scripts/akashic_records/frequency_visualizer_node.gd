extends Node3D
class_name FrequencyVisualizerNode

# Signal when this node is selected/clicked
signal clicked(node)

# References
var word = null  # Reference to the WordEntry this node represents
var visualizer = null  # Reference to the parent FrequencyVisualizer

# Visual components
var mesh_instance: MeshInstance3D
var pulse_animation: AnimationPlayer
var label_3d: Label3D
var connection_lines = []

# Visual properties
var base_size: float = 0.2
var max_size: float = 1.0
var base_color = Color(0.2, 0.5, 1.0)
var highlight_color = Color(1.0, 0.5, 0.2)
var selected_color = Color(1.0, 0.8, 0.0)
var is_selected = false
var is_highlighted = false

# Frequency and pulse properties
var frequency: float = 1.0
var pulse_speed: float = 1.0
var pulse_strength: float = 0.2

func _init(p_word, p_visualizer):
	word = p_word
	visualizer = p_visualizer
	
	# Create the visual elements
	_create_mesh()
	_create_pulse_animation()
	_create_label()
	
	# Set up interaction
	var area = Area3D.new()
	add_child(area)
	
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = max_size * 1.2  # Slightly larger than the node for easier selection
	collision_shape.shape = sphere_shape
	area.add_child(collision_shape)
	
	# Connect signals
	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

func _create_mesh():
	# Create a sphere mesh for the node
	mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = base_size
	sphere_mesh.height = base_size * 2
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = base_color
	material.emission_enabled = true
	material.emission = base_color
	material.emission_energy_multiplier = 0.5
	
	sphere_mesh.material = material
	mesh_instance.mesh = sphere_mesh
	
	add_child(mesh_instance)

func _create_pulse_animation():
	# Create animation player for pulsing effect
	pulse_animation = AnimationPlayer.new()
	add_child(pulse_animation)
	
	# Create pulse animation
	var animation = Animation.new()
	var track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_idx, "mesh_instance:mesh:radius")
	
	# Add keyframes for pulsing
	animation.track_insert_key(track_idx, 0.0, base_size)
	animation.track_insert_key(track_idx, 0.5, base_size * (1.0 + pulse_strength))
	animation.track_insert_key(track_idx, 1.0, base_size)
	
	# Same for height (2x radius)
	track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_idx, "mesh_instance:mesh:height")
	animation.track_insert_key(track_idx, 0.0, base_size * 2)
	animation.track_insert_key(track_idx, 0.5, base_size * 2 * (1.0 + pulse_strength))
	animation.track_insert_key(track_idx, 1.0, base_size * 2)
	
	# Add track for emission energy
	track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_idx, "mesh_instance:mesh:material:emission_energy_multiplier")
	animation.track_insert_key(track_idx, 0.0, 0.5)
	animation.track_insert_key(track_idx, 0.5, 1.0)
	animation.track_insert_key(track_idx, 1.0, 0.5)
	
	# Add the animation to the player
	pulse_animation.add_animation("pulse", animation)
	pulse_animation.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
	pulse_animation.playback_default_blend_time = 0.1
	
	# Play the animation on loop
	pulse_animation.play("pulse")
	pulse_animation.speed_scale = pulse_speed

func _create_label():
	# Create 3D label for the word text
	label_3d = Label3D.new()
	label_3d.text = word.text
	label_3d.font_size = 18
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_3d.no_depth_test = true
	label_3d.position.y = base_size * 1.5  # Position above the sphere
	
	add_child(label_3d)

func create_connection_to(target_node, line_width=0.05, color=Color(0.5, 0.5, 0.5, 0.3)):
	# Create a line connecting this node to another node
	var line = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	line.mesh = immediate_mesh
	
	# Create material for the line
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.flags_transparent = true
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	line.material_override = material
	
	# Add line to the scene
	visualizer.add_child(line)
	connection_lines.append({"line": line, "target": target_node, "width": line_width})
	
	# Draw initial line
	_update_connection_line({"line": line, "target": target_node, "width": line_width})
	
	return line

func update_connections():
	# Update all connection lines positions
	for connection in connection_lines:
		_update_connection_line(connection)

func _update_connection_line(connection):
	var line = connection.line
	var target = connection.target
	var width = connection.width
	
	# Skip if target no longer exists
	if not is_instance_valid(target):
		if is_instance_valid(line):
			line.queue_free()
		connection_lines.erase(connection)
		return
	
	# Get start and end positions
	var start_pos = global_position
	var end_pos = target.global_position
	
	# Calculate direction and length
	var direction = (end_pos - start_pos).normalized()
	var length = start_pos.distance_to(end_pos)
	
	# Adjust start and end to be on the surface of the spheres
	start_pos += direction * base_size
	end_pos -= direction * target.base_size
	
	# Recalculate length
	length = start_pos.distance_to(end_pos)
	
	# Draw the line
	var immediate_mesh = line.mesh as ImmediateMesh
	immediate_mesh.clear_surfaces()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Create a simple line mesh with width
	var right = direction.cross(Vector3.UP).normalized()
	if right.length() < 0.1:  # Handle case when direction is parallel to UP
		right = direction.cross(Vector3.RIGHT).normalized()
	
	var up = direction.cross(right).normalized()
	
	# Create quad vertices for the line
	var half_width = width / 2.0
	var v1 = start_pos + right * half_width
	var v2 = start_pos - right * half_width
	var v3 = end_pos + right * half_width
	var v4 = end_pos - right * half_width
	
	# Add triangles (two to form a quad)
	immediate_mesh.surface_add_vertex(v1)
	immediate_mesh.surface_add_vertex(v2)
	immediate_mesh.surface_add_vertex(v3)
	
	immediate_mesh.surface_add_vertex(v2)
	immediate_mesh.surface_add_vertex(v4)
	immediate_mesh.surface_add_vertex(v3)
	
	immediate_mesh.surface_end()
	
	# Update line transform to global space
	line.global_transform = Transform3D(Basis(), Vector3())

func update_visual(based_on_usage=true):
	# Update the visual representation based on word properties
	if word == null:
		return
	
	# Calculate size based on usage count
	var size_factor = 0.0
	if based_on_usage and word.usage_count > 0:
		size_factor = min(1.0, log(word.usage_count + 1) / log(20))  # Logarithmic scaling
	else:
		# Calculate from properties if any exist
		if "energy_level" in word.properties:
			size_factor = word.properties.energy_level
		elif "importance" in word.properties:
			size_factor = word.properties.importance
		else:
			size_factor = 0.5  # Default
	
	# Calculate frequency based on properties
	if "resonance_frequency" in word.properties:
		frequency = word.properties.resonance_frequency
	elif "vibrational_state" in word.properties:
		frequency = word.properties.vibrational_state / 5.0
	else:
		frequency = 1.0
	
	# Update the size
	base_size = lerp(0.2, max_size, size_factor)
	
	# Update the mesh
	if mesh_instance and mesh_instance.mesh:
		mesh_instance.mesh.radius = base_size
		mesh_instance.mesh.height = base_size * 2
	
	# Update pulse speed based on frequency
	pulse_speed = frequency
	if pulse_animation:
		pulse_animation.speed_scale = pulse_speed
	
	# Update label size based on node size
	if label_3d:
		label_3d.font_size = int(18 + (10 * size_factor))
		label_3d.position.y = base_size * 1.5
		
	# Update collision shape if it exists
	var area = get_node_or_null("Area3D")
	if area:
		var collision = area.get_node_or_null("CollisionShape3D")
		if collision and collision.shape:
			collision.shape.radius = base_size * 1.2

func set_selected(selected):
	is_selected = selected
	_update_material_color()

func set_highlighted(highlighted):
	is_highlighted = highlighted
	_update_material_color()

func _update_material_color():
	if not mesh_instance or not mesh_instance.mesh or not mesh_instance.mesh.material:
		return
		
	var material = mesh_instance.mesh.material
	
	if is_selected:
		material.albedo_color = selected_color
		material.emission = selected_color
		material.emission_energy_multiplier = 1.0
	elif is_highlighted:
		material.albedo_color = highlight_color
		material.emission = highlight_color
		material.emission_energy_multiplier = 0.8
	else:
		material.albedo_color = base_color
		material.emission = base_color
		material.emission_energy_multiplier = 0.5

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Left click - emit signal for selection
			clicked.emit(self)

func _on_mouse_entered():
	set_highlighted(true)

func _on_mouse_exited():
	set_highlighted(false)