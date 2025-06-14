@tool
extends Node3D

var combiner: int
var camera: Camera3D

var previous_basis: Basis
var interpolation_speed: float = 5.0  # Adjust this for smoother or quicker transitions

var initial_up = Vector3.UP
var initial_position: Vector3

var rotator_bas

var position_basis: Basis
signal current_position_basis(current_basis)

func _ready():
	#setup_star()
	camera = get_viewport().get_camera_3d()
	initial_position = global_transform.origin
	

func _process(delta):
	
	#update_orientation()
	
	#camera node, current viewport 3d 
	var camera = get_viewport().get_camera_3d()
	#position matrix
	var player_position = camera.global_transform.origin
	var to_camera = player_position - global_transform.origin
	to_camera = to_camera.normalized()
	var camera_up = camera.global_transform.basis.y.normalized()
	var up = Vector3.UP
	var right = up.cross(to_camera).normalized()
	var left = -up.cross(to_camera).normalized()
	up = to_camera.cross(right).normalized()
	var position_matrix = Basis(left, up, -to_camera).orthonormalized()
	
	
	#camera matrix
	var camera_x = -camera.global_transform.basis.x
	var camera_y = camera.global_transform.basis.y
	var camera_z = -camera.global_transform.basis.z
	var camera_matrix  = Basis(camera_x, camera_y, camera_z).orthonormalized()
	var happy_little_mistakes = camera_z * to_camera
	var happy_little_mistakes2 =  camera_z * -to_camera
	var happy_little_mistakes3
	var happy_little_mistakes4
	var sad_try = camera_matrix * position_matrix
	var thats_stupid = sad_try * camera_matrix
	#apply to shader
	var final_matrix = Basis(camera_x, camera_y, happy_little_mistakes2)
	
	var camera_pos = camera.global_transform.origin
	var object_pos = global_transform.origin
	
	var view_dir = (object_pos - camera_pos).normalized()
	enhanced_look_at(self, camera_pos)
	
	var basis_1_x = (camera_matrix.x + position_basis.x) / 2
	var basis_1_y = (camera_matrix.y + position_basis.y) / 2
	var basis_1_z = (camera_matrix.z + position_basis.z) / 2
	
	var new_final_matrix = Basis(basis_1_x, basis_1_y, basis_1_z)
	
	
	#var new_final = camera_matrix * position_basis
	
	#print("main positioner position_basis = ", position_basis)
	global_transform.basis = position_basis
	emit_signal("current_position_basis", position_basis)
	#print("do we go there?")
	#shader_material.set_shader_parameter("rotation_matrix", position_basis)
	
	#previous_basis = interpolated_basis

# Enhanced look-at function that adjusts the basis of the node considering all three axes
func enhanced_look_at(node: Node3D, target: Vector3) -> void:
	var origin: Vector3 = node.global_transform.origin
	var forward: Vector3 = (target - origin).normalized()

	# Just return if at the same position
	if origin == target:
		return

	# Calculate right and up vectors based on the camera's basis
	var camera_cam_x = camera.global_transform.basis.x
	var camera_cam_y = camera.global_transform.basis.y
	var right: Vector3 = -camera_cam_x
	var up: Vector3 = -camera_cam_y

	# If the forward vector is too close to the up vector, adjust the up vector to avoid gimbal lock
	if abs(forward.dot(up)) > 0.999:
		up = Vector3.UP if abs(forward.dot(Vector3.UP)) < 0.999 else Vector3.RIGHT

	# Recalculate right and up vectors
	right = up.cross(forward).normalized()
	up = forward.cross(right).normalized()

	# Create a new basis with the calculated vectors
	var new_basis = Basis(right, -up, -forward)
	position_basis = new_basis

	# Apply the new basis to the node without moving it
	#node.global_transform = Transform3D(new_basis, node.global_transform.origin)
