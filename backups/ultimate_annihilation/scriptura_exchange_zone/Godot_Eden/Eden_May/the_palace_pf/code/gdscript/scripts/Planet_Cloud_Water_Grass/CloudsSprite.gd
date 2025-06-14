@tool
extends Sprite3D

var shader_material: ShaderMaterial
var tip_of_dome: Vector3 = Vector3.ZERO
var over_player_head: Vector3 = Vector3.ZERO
var basis_in_direction_of_player: Basis = Basis.IDENTITY
var basis_of_camera: Basis = Basis.IDENTITY
var cloud_seed: int = 1
var camera: Camera3D
var player_position: Vector3

func _ready():
	camera = get_viewport().get_camera_3d()
	setup_clouds()

func setup_clouds():
	# Create a high-resolution texture
	var image = Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))  # White base color
	var cloud_texture = ImageTexture.create_from_image(image)
	
	# Set the texture to the Sprite3D
	self.texture = cloud_texture
	
	# Load and set up the shader
	var shader = load("res://Shaders/CloudsSprite.gdshader")
	if shader == null:
		print("Error: Could not load CloudShader.gdshader file")
		return
	
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	material_override = shader_material

	# Ensure the sprite is large enough and always faces the camera
	pixel_size = 0.01  # Adjust as needed
	billboard = StandardMaterial3D.BILLBOARD_ENABLED
	

func _process(delta):
	update_shader_parameters()

func update_shader_parameters():
	player_position = camera.global_transform.origin
	material_override.set_shader_parameter("tip_of_dome", tip_of_dome)
	material_override.set_shader_parameter("over_player_head", over_player_head)
	material_override.set_shader_parameter("basis_in_direction_of_player", basis_in_direction_of_player)
	material_override.set_shader_parameter("basis_of_camera", basis_of_camera)
	material_override.set_shader_parameter("cloud_seed", cloud_seed)
	material_override.set_shader_parameter("world_pos", global_transform.origin)
	material_override.set_shader_parameter("player_position", player_position)
	material_override.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)

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

