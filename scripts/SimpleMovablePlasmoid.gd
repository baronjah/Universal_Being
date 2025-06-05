# Simple movable plasmoid for testing WASD movement
extends CharacterBody3D
class_name SimpleMovablePlasmoid

@export var move_speed: float = 5.0
@export var plasma_color: Color = Color(0.5, 0.8, 1.0, 0.8)

func _ready():
	print("✨ SimpleMovablePlasmoid ready for WASD movement!")
	
	# Set up visual appearance
	var mesh_instance = get_node("MeshInstance3D")
	if mesh_instance:
		var material = StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = plasma_color
		material.emission_enabled = true
		material.emission = plasma_color
		material.emission_energy = 1.0
		mesh_instance.material_override = material

func _physics_process(delta):
	var input_vector = Vector3.ZERO
	
	# Get WASD input
	if Input.is_key_pressed(KEY_W):
		input_vector -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		input_vector += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		input_vector -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		input_vector += transform.basis.x
	
	# Vertical movement
	if Input.is_key_pressed(KEY_SPACE):
		input_vector += Vector3.UP
	if Input.is_key_pressed(KEY_SHIFT):
		input_vector -= Vector3.UP
	
	# Apply movement
	if input_vector.length() > 0.1:
		input_vector = input_vector.normalized()
		velocity = input_vector * move_speed
		print("Moving! Velocity: ", velocity, " Position: ", global_position)
	else:
		velocity = velocity.lerp(Vector3.ZERO, delta * 5.0)
	
	# Move the character
	move_and_slide()