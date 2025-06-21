extends Node3D

@export var consciousness_level: float = 1.0
@export var growth_rate: float = 0.1
var connections: Array = []
var creation_time: float = 0.0
var material: ShaderMaterial

@onready var mesh_instance := $Body/MeshInstance3D

func _ready():
	# Setup material
	if mesh_instance and mesh_instance.mesh:
		material = mesh_instance.get_surface_override_material(0)
		if not material:
			material = mesh_instance.mesh.surface_get_material(0)
	
	# Random starting consciousness
	consciousness_level = randf_range(0.5, 2.0)
	growth_rate = randf_range(0.05, 0.15)
	
	# Create more interesting shapes than just spheres
	_create_unique_form()
	
	# Add glow
	_update_visual()

func _process(delta):
	creation_time += delta
	
	# Breathing animation
	var breath = sin(creation_time * 2.0) * 0.05 + 1.0
	scale = Vector3.ONE * (consciousness_level * breath * 0.5)
	
	# Consciousness evolution
	consciousness_level += growth_rate * delta * (1.0 + connections.size() * 0.1)
	consciousness_level = min(consciousness_level, 10.0)
	
	# Update shader
	if material:
		material.set_shader_parameter("consciousness", consciousness_level)
		material.set_shader_parameter("time_alive", creation_time)
	
	# Rotate based on consciousness
	rotate_y(delta * consciousness_level * 0.1)
	
	# Connection influence
	for being in connections:
		if is_instance_valid(being):
			var dir = (being.global_position - global_position).normalized()
			global_position += dir * delta * 0.05

func connect_to(other):
	if other == self or other in connections:
		return
	
	connections.append(other)
	other.connections.append(self)
	
	# Boost consciousness
	consciousness_level *= 1.5
	other.consciousness_level *= 1.5
	
	# Visual feedback
	_create_connection_visual(other)

func interact():
	# Player interaction
	growth_rate *= 2.0
	consciousness_level += 1.0
	
	# Pulse effect
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "scale", scale * 1.5, 0.1)
	tween.chain().tween_property(self, "scale", scale, 0.2)
	
	print("🧠 Consciousness: ", consciousness_level)

func _update_visual():
	if mesh_instance:
		# Create glow
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
		# Add omni light for glow effect
		var light = OmniLight3D.new()
		light.light_color = Color(consciousness_level * 0.5, 0.5, 1.0 - consciousness_level * 0.3)
		light.light_energy = consciousness_level * 0.5
		light.omni_range = consciousness_level * 2.0
		add_child(light)

func _create_unique_form():
	# Create varied forms instead of just spheres
	var form_type = randi() % 5
	var new_mesh: Mesh
	
	match form_type:
		0: # Sphere (original)
			new_mesh = SphereMesh.new()
			new_mesh.radial_segments = 16
			new_mesh.height_segments = 12
		1: # Box being
			new_mesh = BoxMesh.new()
			new_mesh.size = Vector3(1, 1, 1)
		2: # Cylinder being
			new_mesh = CylinderMesh.new()
			new_mesh.top_radius = 0.5
			new_mesh.bottom_radius = 0.5
			new_mesh.height = 1.0
		3: # Capsule being  
			new_mesh = CapsuleMesh.new()
			new_mesh.radius = 0.5
			new_mesh.height = 1.5
		4: # Prism being
			new_mesh = PrismMesh.new()
			new_mesh.left_to_right = 1.0
			new_mesh.size = Vector3(1, 1, 1)
	
	# Apply the new mesh while preserving shader material
	if mesh_instance:
		var old_material = mesh_instance.get_surface_override_material(0)
		mesh_instance.mesh = new_mesh
		if old_material:
			mesh_instance.set_surface_override_material(0, old_material)

func _create_connection_visual(other):
	# Create line between beings
	var line_mesh = ImmediateMesh.new()
	var line_instance = MeshInstance3D.new()
	line_instance.mesh = line_mesh
	line_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(line_instance)
	
	# Simple line material
	var line_mat = StandardMaterial3D.new()
	line_mat.vertex_color_use_as_albedo = true
	line_mat.emission_enabled = true
	line_mat.emission = Color(0.5, 0.8, 1.0)
	line_mat.emission_energy = 2.0
	line_instance.material_override = line_mat
