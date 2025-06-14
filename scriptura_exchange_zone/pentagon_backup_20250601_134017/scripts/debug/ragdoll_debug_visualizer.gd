# ==================================================
# SCRIPT NAME: ragdoll_debug_visualizer.gd
# DESCRIPTION: Debug visualization for ragdoll physics
# PURPOSE: Help debug and tune ragdoll walking behavior
# CREATED: 2025-05-25 - Visual debugging
# ==================================================

extends UniversalBeingBase
# Target ragdoll to visualize
var ragdoll_node: Node3D
var walker_node: Node3D

# Debug elements
var debug_lines: Array[MeshInstance3D] = []
var debug_spheres: Array[MeshInstance3D] = []
var debug_labels: Array[Label3D] = []

# Visualization options
var show_joints: bool = true
var show_forces: bool = true
var show_com: bool = true
var show_support: bool = true
var show_velocities: bool = true
var show_state: bool = true

# Materials
var joint_material: StandardMaterial3D
var force_material: StandardMaterial3D
var com_material: StandardMaterial3D
var velocity_material: StandardMaterial3D

func _ready() -> void:
	_create_materials()
	set_process(true)
	print("[RagdollDebug] Visualizer ready")

func _create_materials() -> void:
	# Joint connections
	joint_material = MaterialLibrary.get_material("default")
	joint_material.albedo_color = Color.YELLOW
	joint_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Force vectors
	force_material = MaterialLibrary.get_material("default")
	force_material.albedo_color = Color.RED
	force_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Center of mass
	com_material = MaterialLibrary.get_material("default")
	com_material.albedo_color = Color.GREEN
	com_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Velocity vectors
	velocity_material = MaterialLibrary.get_material("default")
	velocity_material.albedo_color = Color.CYAN
	velocity_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func set_ragdoll(ragdoll: Node3D) -> void:
	ragdoll_node = ragdoll
	# Find walker component
	if ragdoll_node.has_node("SimpleWalker"):
		walker_node = ragdoll_node.get_node("SimpleWalker")
		print("[RagdollDebug] Connected to ragdoll and walker")

func _process(_delta: float) -> void:
	if not ragdoll_node:
		return
	
	# Clear previous frame's debug elements
	_clear_debug_elements()
	
	# Get body parts
	var body_parts = ragdoll_node.get_meta("body_parts", {})
	if body_parts.is_empty():
		return
	
	# Visualize based on options
	if show_joints:
		_visualize_joints(body_parts)
	
	if show_com:
		_visualize_center_of_mass(body_parts)
	
	if show_velocities:
		_visualize_velocities(body_parts)
	
	if show_state and walker_node:
		_visualize_walker_state()
	
	if show_support:
		_visualize_support_polygon(body_parts)

func _clear_debug_elements() -> void:
	for element in debug_lines + debug_spheres + debug_labels:
		element.queue_free()
	debug_lines.clear()
	debug_spheres.clear()
	debug_labels.clear()

func _visualize_joints(body_parts: Dictionary) -> void:
	# Draw lines between connected body parts
	var connections = [
		["pelvis", "left_thigh"],
		["pelvis", "right_thigh"],
		["left_thigh", "left_shin"],
		["right_thigh", "right_shin"],
		["left_shin", "left_foot"],
		["right_shin", "right_foot"]
	]
	
	for connection in connections:
		if body_parts.has(connection[0]) and body_parts.has(connection[1]):
			var part_a = body_parts[connection[0]]
			var part_b = body_parts[connection[1]]
			_draw_line(part_a.global_position, part_b.global_position, joint_material)

func _visualize_center_of_mass(body_parts: Dictionary) -> void:
	# Calculate and show center of mass
	var total_mass = 0.0
	var weighted_pos = Vector3.ZERO
	
	for part_name in body_parts:
		var part = body_parts[part_name]
		if part is RigidBody3D:
			weighted_pos += part.global_position * part.mass
			total_mass += part.mass
	
	if total_mass > 0:
		var com = weighted_pos / total_mass
		_draw_sphere(com, 0.1, com_material)
		_create_label(com + Vector3(0, 0.3, 0), "COM", Color.GREEN)

func _visualize_velocities(body_parts: Dictionary) -> void:
	for part_name in body_parts:
		var part = body_parts[part_name]
		if part is RigidBody3D:
			# Linear velocity
			if part.linear_velocity.length() > 0.1:
				var vel_end = part.global_position + part.linear_velocity * 0.3
				_draw_line(part.global_position, vel_end, velocity_material)
			
			# Show velocity magnitude on important parts
			if part_name in ["pelvis", "left_foot", "right_foot"]:
				var vel_text = "%.1f m/s" % part.linear_velocity.length()
				_create_label(part.global_position + Vector3(0.3, 0, 0), vel_text, Color.CYAN)

func _visualize_walker_state() -> void:
	if not walker_node:
		return
	
	# Get walker status
	var status = walker_node.get_status()
	
	# Create state label at top of screen
	var pelvis = ragdoll_node.get_meta("body_parts", {}).get("pelvis")
	if pelvis:
		_create_label(pelvis.global_position + Vector3(0, 2, 0), status, Color.WHITE)

func _visualize_support_polygon(body_parts: Dictionary) -> void:
	# Show support area between feet
	var left_foot = body_parts.get("left_foot")
	var right_foot = body_parts.get("right_foot")
	
	if left_foot and right_foot:
		var left_pos = left_foot.global_position
		var right_pos = right_foot.global_position
		var _center = (left_pos + right_pos) * 0.5
		
		# Draw support line
		_draw_line(left_pos, right_pos, com_material, 0.01)
		
		# Mark foot positions
		_draw_sphere(left_pos, 0.05, com_material)
		_draw_sphere(right_pos, 0.05, com_material)

# Drawing helpers
func _draw_line(start: Vector3, end: Vector3, material: Material, thickness: float = 0.02) -> void:
	var mesh_instance = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	
	var length = start.distance_to(end)
	cylinder_mesh.height = length
	cylinder_mesh.top_radius = thickness
	cylinder_mesh.bottom_radius = thickness
	
	mesh_instance.mesh = cylinder_mesh
	mesh_instance.material_override = material
	
	# Position and orient
	mesh_instance.global_position = (start + end) * 0.5
	mesh_instance.look_at(end, Vector3.UP)
	mesh_instance.rotate_object_local(Vector3.RIGHT, PI/2)
	
	add_child(mesh_instance)
	debug_lines.append(mesh_instance)

func _draw_sphere(pos: Vector3, radius: float, material: Material) -> void:
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2
	
	mesh_instance.mesh = sphere_mesh
	mesh_instance.material_override = material
	mesh_instance.global_position = pos
	
	add_child(mesh_instance)
	debug_spheres.append(mesh_instance)

func _create_label(pos: Vector3, text: String, color: Color) -> void:
	var label = Label3D.new()
	label.text = text
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.global_position = pos
	label.pixel_size = 0.01
	
	add_child(label)
	debug_labels.append(label)

# Console command support
func toggle_debug_option(option: String) -> String:
	match option:
		"joints":
			show_joints = !show_joints
			return "Joint visualization: " + str(show_joints)
		"forces":
			show_forces = !show_forces
			return "Force visualization: " + str(show_forces)
		"com":
			show_com = !show_com
			return "Center of mass: " + str(show_com)
		"support":
			show_support = !show_support
			return "Support polygon: " + str(show_support)
		"velocities":
			show_velocities = !show_velocities
			return "Velocity vectors: " + str(show_velocities)
		"state":
			show_state = !show_state
			return "State info: " + str(show_state)
		"all":
			var enabled = !show_joints  # Toggle all
			show_joints = enabled
			show_forces = enabled
			show_com = enabled
			show_support = enabled
			show_velocities = enabled
			show_state = enabled
			return "All visualizations: " + str(enabled)
		_:
			return "Unknown option: " + option