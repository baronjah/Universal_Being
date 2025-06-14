@tool
#Dome.gd it is a Node named Dome, we shall create a shader for i!
extends MeshInstance3D


var tip_of_dome: Vector3 = Vector3.ZERO  # Initializes to (0, 0, 0)
var over_player_head: Vector3 = Vector3.ZERO
var basis_in_direction_of_player: Basis = Basis.IDENTITY  # Identity matrix
var basis_of_camera: Basis = Basis.IDENTITY
var cloud_seed: int = 1  # As you suggested, we'll start with 1

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up your shader material here if you haven't already
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://path/to/your/dome_shader.gdshader")
	material_override = shader_material
	
	# Set the initial seed
	material_override.set_shader_parameter("cloud_seed", cloud_seed)
	update_shader_parameters()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_shader_parameters()
	#print(global_transform.origin)
func update_shader_parameters():
	material_override.set_shader_parameter("tip_of_dome", tip_of_dome)
	material_override.set_shader_parameter("over_player_head", over_player_head)
	material_override.set_shader_parameter("basis_in_direction_of_player", basis_in_direction_of_player)
	material_override.set_shader_parameter("basis_of_camera", basis_of_camera)
	material_override.set_shader_parameter("world_pos", global_transform.origin)
	
	# You can also update other parameters here, like time for cloud movement
	material_override.set_shader_parameter("TIME", Time.get_ticks_msec() / 1000.0)

# rotation from planet center, in direction of a player camera!
func _on_over_player_head_current_position_basis(current_basis):
	basis_in_direction_of_player = current_basis

# over player head when on planet, between player and planet, when flying away from it!
func _on_over_player_head_dometopheight_over_head_position(origin_position):
	over_player_head = origin_position

# camera basis, from node that is rotating dome! maybe we can just use global_transform.basis here?
func _on_direction_of_camera_current_basis_camera_matrix(camera_basis):
	basis_of_camera = camera_basis

# tip of the dome! in center of the dome! its position in global_transform
func _on_tip_of_dome_tip_of_dome_position(origin_position):
	tip_of_dome = origin_position
