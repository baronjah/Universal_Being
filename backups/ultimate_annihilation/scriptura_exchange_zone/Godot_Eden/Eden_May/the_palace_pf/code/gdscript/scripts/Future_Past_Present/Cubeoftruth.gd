#the cube of truth
@tool
extends MeshInstance3D

var position_basis: Basis
var camera: Camera3D



# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_viewport().get_camera_3d()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera_x = -camera.global_transform.basis.x
	var camera_y = camera.global_transform.basis.y
	var camera_z = -camera.global_transform.basis.z
	var camera_matrix  = Basis(camera_x, camera_y, camera_z).orthonormalized()
	var camera_pos = camera.global_transform.origin
	enhanced_look_at(self, camera_pos)
	var basis_1_x = (camera_matrix.x + position_basis.x) / 2
	var basis_1_y = (camera_matrix.y + position_basis.y) / 2
	var basis_1_z = (camera_matrix.z + position_basis.z) / 2
	var new_final_matrix = Basis(basis_1_x, basis_1_y, basis_1_z)
	var new_final_matrix2 = Basis(-basis_1_x, basis_1_y, -basis_1_z)
	var moon_rotation = global_transform.basis
	var moon_rotation_x = moon_rotation.x
	var moon_rotation_y = moon_rotation.y
	var moon_rotation_z = moon_rotation.z
	var rotation_moon = Basis(-moon_rotation_x, -moon_rotation_y, moon_rotation_z)
	var combined_basis = rotation_moon * new_final_matrix
	global_transform.basis = new_final_matrix2

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
