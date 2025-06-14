# GalaxyCloseUp.gd in GalaxyCloseUp scene
extends Node3D

@export var visible_star_distance: float = 50.0
@export var transition_distance: float = 5.0

var closest_star = null
var closest_distance = INF

var star_scene = preload("res://Scenes/Star.tscn")
var rd: RenderingDevice
var shader: RID
var pipeline: RID
var uniform_set: RID
var buffer: RID

var rng = RandomNumberGenerator.new()
var galaxy_seed
var galaxy_rng

var star_seed
var star_rng
var offset_star
var star_data
var star_container
var initial_distance

var cube_cam
var panorama

var sphere_center: Vector3
var sphere_radius: float
var current_look_thingy
var current_look_thingy2
var current_distance_thingy: float
var furthest_distance_thingy: float
var closetst_distance_thingy: float

var shader_material#: ShaderMaterial

var skybox_state = false

func _ready():
	rng.seed = GlobalState.current_galaxy_data.seed
	star_container = Node3D.new()
	star_container.name = "StarContainer"
	add_child(star_container)
	if GlobalState.is_returning_from_star:
		setup_return_camera()
	else:
		setup_camera()
	apply_skybox()
	setup_compute_shader()
	generate_stars()

func _process(delta):
	update_closest_star()
	check_for_transition()
	check_for_return()

	if skybox_state == true:
		var result = calculate_look_distance()
		var look_distance = result[0]
		var horizontal_factor = result[1]
		
		var closest_distance = initial_distance * 0.1
		var furthest_distance = initial_distance * 2.0
		
		var vertical_depth_factor = map_range(look_distance, closest_distance, furthest_distance, 1.1, 0.9)
		var horizontal_depth_factor = map_range(look_distance, closest_distance, furthest_distance, 0.9, 1.1)
		
		var depth_factor = lerp(vertical_depth_factor, horizontal_depth_factor, horizontal_factor)
		depth_factor = clamp(depth_factor, 0.9, 1.1)
		shader_material.set_shader_parameter("depth_factor", depth_factor)
	if skybox_state == false:
		print("the skybox has changed, and we no more need to calculate stuff for depth factor here and now")

func map_range(value, start1, stop1, start2, stop2):
	return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1))

func setup_compute_shader():
	rd = RenderingServer.create_local_rendering_device()
	
	var shader_file = load("res://ComputeShaders/StarPositions.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	
	pipeline = rd.compute_pipeline_create(shader)
	
	var params = GlobalState.current_galaxy_data.shader_params
	var uniform_data = PackedFloat32Array([
		params.u_seed,
		params.u_arm_count,
		params.u_arm_width,
		params.u_star_density,
		params.u_star_size,
		params.u_star_circle_radius,
		params.u_swirl_amount,
		params.u_star_size # Adding resolution as the last parameter
	])
	var uniform_bytes = uniform_data.to_byte_array()
	var uniform_buffer = rd.uniform_buffer_create(uniform_bytes.size(), uniform_bytes)
	
	var resolution = int(params.u_star_size)
	buffer = rd.storage_buffer_create(resolution * resolution * 16)  # 16 bytes per vec4
	
	var uniform_1 = RDUniform.new()
	uniform_1.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	uniform_1.binding = 0
	uniform_1.add_id(uniform_buffer)
	
	var uniform_2 = RDUniform.new()
	uniform_2.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform_2.binding = 1
	uniform_2.add_id(buffer)
	
	uniform_set = rd.uniform_set_create([uniform_1, uniform_2], shader, 0)

func generate_stars():
	var params = GlobalState.current_galaxy_data.shader_params
	var resolution = int(params.u_star_size)
	var max_offset = GlobalState.current_galaxy_data.shader_params.u_star_size * 2

	var compute_list = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, resolution / 16, resolution / 16, 1)
	rd.compute_list_end()
	rd.submit()
	rd.sync()
	var output_bytes = rd.buffer_get_data(buffer)
	var output = output_bytes.to_float32_array()
	
	galaxy_seed = GlobalState.current_galaxy_data.seed
	
	for i in range(0, output.size(), 4):
		if output[i + 3] > 0.01:  # Check alpha value
			var pos = Vector3(((output[i] * 0.5 * resolution) - ( resolution / 4)) * 10, ((output[i + 1] * 0.5 * resolution) - ( resolution / 4))  * 10, 0)
			var star_hash = output[i + 2]
			star_seed = generate_star_seed(galaxy_seed, i / 4)
			star_data = GlobalState.generate_star_data(star_seed)
			var y_offset = calculate_spherical_offset(pos, max_offset, star_seed)
			pos.z = y_offset
			create_star_at_position(pos, star_hash)
	var galaxy_rotation = GlobalState.current_galaxy_data.rotation
	$StarContainer.rotation = galaxy_rotation

func create_star_at_position(pos: Vector3, star_hash: float):
	var star = star_scene.instantiate()
	star.position = pos
	star.scale = Vector3.ONE * (star_hash * 0.01 + 0.005)
	var celestial_body_seed = GlobalState.current_star_data.seed
	var celestial_body_temperature = GlobalState.current_star_data.temperature
	var celestial_body_size = GlobalState.current_star_data.size
	$StarContainer.add_child(star)
	star.set_parameters(celestial_body_seed, celestial_body_temperature, celestial_body_size)




# the one that shiftes the timespace
func apply_skybox():
	var skybox_texture = GlobalState.get_skybox_texture()
	if skybox_texture:
		var env = get_environment()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0, 0, 0)
		await get_tree().create_timer(0.01).timeout
		env.background_mode = Environment.BG_SKY
		var sky = Sky.new()
		var sky_material = ShaderMaterial.new()
		sky_material.shader = load("res://Shaders/SkySphere.gdshader")
		sky_material.set_shader_parameter("panorama_texture", skybox_texture)
		shader_material = sky_material
		#var shader_material: ShaderMaterial
		#sky_material.panorama = skybox_texture
		sky.sky_material = sky_material
		env.sky = sky
		skybox_state = true
		#print("Skybox applied successfully")
	else:
		print("No skybox texture found in GlobalState")
		# If no skybox texture, display a debug color
		var env = get_environment()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(1, 0, 0)  # Red background for debugging

func get_environment():
	var world = get_viewport().get_world_3d()
	if not world.environment:
		world.environment = Environment.new()
	return world.environment
	
func setup_galaxy():
	if GlobalState.current_galaxy_data:
		var close_up_sprite = $Sprite3D
		# Create a placeholder texture (same as in GalaxySprite)
		var image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
		image.fill(Color(1, 1, 1, 1))  # White color
		var texture = ImageTexture.create_from_image(image)
		# Assign the texture to the Sprite3D
		close_up_sprite.texture = texture
		# Load the shader directly (same as in GalaxySprite)
		var shader = load("res://Shaders/EnhancedGalaxy.gdshader")
		# Create a new ShaderMaterial with the loaded shader
		var shader_material = ShaderMaterial.new()
		shader_material.shader = shader
		var params = GlobalState.current_galaxy_data.shader_params
		var resolution = int(params.u_star_size)
		# Set shader parameters
		for param in GlobalState.current_galaxy_data.shader_params:
			shader_material.set_shader_parameter(param, GlobalState.current_galaxy_data.shader_params[param])
		# Assign the material to the Sprite3D
		close_up_sprite.material_override = shader_material
		# Position the sprite at the center
		close_up_sprite.global_transform.origin = Vector3.ZERO
		# Apply scale
		var stored_scale = GlobalState.current_galaxy_data.scale
		close_up_sprite.scale = Vector3((resolution), (resolution), (resolution))
		close_up_sprite.rotation = GlobalState.current_galaxy_data.rotation
		close_up_sprite.global_transform.origin = Vector3.ZERO
	else:
		print("No galaxy data available")

func setup_camera():
	if GlobalState.camera_data:
		var camera = $Camera3D as FreeLookCamera2  # Ensure this is the correct type
		camera.global_transform.origin = (GlobalState.camera_data.position * 50)
		camera.global_rotation = GlobalState.camera_data.rotation
		camera._total_pitch = GlobalState.camera_data.total_pitch  # Set this
		var coordinator = Vector3(0,0,0)
		initial_distance = camera.global_transform.origin.distance_to(coordinator)
		GlobalState.clear_return_from_star_data()
	else:
		print("No camera data available, using default position")
		
func setup_return_camera():
	if GlobalState.star_to_galaxy_camera_data: # get_return_from_star_data()
		var camera = $Camera3D as FreeLookCamera2  # Ensure this is the correct type
		camera.global_transform.origin = (GlobalState.star_to_galaxy_camera_data.position)
		camera.global_rotation = GlobalState.star_to_galaxy_camera_data.rotation
		camera._total_pitch = GlobalState.star_to_galaxy_camera_data.total_pitch  # Set this
		var coordinator_helper = (GlobalState.camera_data.position * 50)
		var coordinator = Vector3(0,0,0)
		coordinator_helper.distance_to(coordinator)
		var second_distance_for_camera_information = GlobalState.camera_data.position.distance_to(GlobalState.star_to_galaxy_camera_data.previous_star_coordinates)
		initial_distance = coordinator_helper.distance_to(coordinator)
		GlobalState.clear_return_from_star_data()
	else:
		print("No camera data available, using default position")

func generate_star_seed(galaxy_seed: int, star_index: int) -> int:
	return galaxy_seed * 1000000 + star_index
	
func calculate_spherical_offset(pos: Vector3, max_offset: float, star_seed: int) -> float:
	var star_rng = RandomNumberGenerator.new()
	star_rng.seed = star_seed

	var radius = max_offset * 1.1
	var distance_2d = Vector2(pos.x, pos.y).length()

	var max_z_offset
	if distance_2d < radius:
		max_z_offset = sqrt(radius * radius - distance_2d * distance_2d)
	else:
		max_z_offset = 0

	var z_offset = star_rng.randf_range(-max_z_offset, max_z_offset)
	return z_offset / 2.0
	
func update_closest_star():
	var stars = get_tree().get_nodes_in_group("stars")
	closest_star = null
	closest_distance = INF
	for star in stars:
		if star == null:
			print("Found a null star in the group")
			continue
		var distance = $Camera3D.global_transform.origin.distance_to(star.global_transform.origin)
		if distance < closest_distance:
			closest_star = star
			closest_distance = distance
			
	if closest_star:
		var closinger_starminger = 2137
	else:
		print("No closest star found")

func check_for_transition():
	if closest_star and closest_distance < transition_distance:
		transition_to_star(closest_star)

func transition_to_star(target_star):
	print("transition_to_star function")
	var camera = $Camera3D
	if target_star == null:
		print("Error: target_star is null")
		return
	var visible_stars = capture_visible_stars(target_star)
	GlobalState.store_visible_stars(visible_stars)
	var coordinator_2 = Vector3(0,0,0)
	var current_distance_2 = camera.global_transform.origin.distance_to(coordinator_2)
	GlobalState.store_star_data({
		"position": target_star.global_transform.origin,
		"scale": target_star.scale,
		"color": target_star.modulate,
		"seed": target_star.get_star_seed(),
		"temperature": target_star.get_star_temperature(),
		"brightness": target_star.get_star_brightness()
	})
	#print("global store_galaxy_to_star_camera_data camera._total_pitch = ", camera._total_pitch)
	GlobalState.store_galaxy_to_star_camera_data({
		"position": camera.global_transform.origin,
		"rotation": camera.global_rotation,
		"total_pitch": camera._total_pitch
	})
	setup_360_camera()
	store_star_skybox_texture(closest_star)

func capture_visible_stars(target_star):
	var visible_stars = []
	var target_position = target_star.global_transform.origin
	for star in get_tree().get_nodes_in_group("stars"):
		if star != target_star and is_star_visible(star, target_position):
			visible_stars.append({
				"position": star.global_transform.origin - target_position,
				"scale": star.scale,
				"color": star.modulate,
				"seed": star.get_star_seed(),
				"temperature": star.get_star_temperature()
			})
	return visible_stars

func is_star_visible(star, from_position):
	if star == null or from_position == null:
		return false
	var distance = star.global_transform.origin.distance_to(from_position)
	return distance <= visible_star_distance

func check_for_return():
	var camera = $Camera3D as FreeLookCamera2
	var coordinator = Vector3(0,0,0)
	var current_distance = camera.global_transform.origin.distance_to(coordinator)
	var current_coordinates = camera.global_transform.origin
	var furtherst_distance = initial_distance * 1.2
	furthest_distance_thingy = furtherst_distance
	#print("furtherst_distance = ", furtherst_distance)
	current_distance_thingy = current_distance
	#print("current_distance = ", current_distance)
	if current_distance > furtherst_distance:
		
		var stored_galaxy_position = GlobalState.current_galaxy_data.galaxy_position
		transition_to_galaxies()

# the vertical strettch that one day will be better
func calculate_look_distance():
	var player = $Camera3D
	var player_position = player.global_transform.origin
	var look_direction = -player.global_transform.basis.z
	
	# Calculate vertical angle
	var vertical_angle = acos(abs(look_direction.y))
	
	# Calculate horizontal factor (0 when looking straight up/down, 1 when looking horizontally)
	var horizontal_factor = sin(vertical_angle)
	
	sphere_center = Vector3.ZERO
	sphere_radius = initial_distance * 1.2
	
	# Calculate intersection
	var to_center = sphere_center - player_position
	var b = to_center.dot(look_direction)
	var c = to_center.dot(to_center) - sphere_radius * sphere_radius
	var discriminant = b * b - c
	
	if discriminant < 0:
		return INF
	
	var t = b - sqrt(discriminant)
	var intersection_point = player_position + look_direction * t
	var distance = player_position.distance_to(intersection_point)
	
	# Return both the distance and the horizontal factor
	return [distance, horizontal_factor]


func transition_to_galaxies():
	var camera = $Camera3D as FreeLookCamera2
	var stored_galaxy_position = GlobalState.current_galaxy_data.galaxy_position
	var new_camera_position = (camera.global_transform.origin / 50.0) + stored_galaxy_position
	GlobalState.store_return_data(
		{
			"position": new_camera_position,
			"rotation": camera.global_rotation,
			"total_pitch": camera._total_pitch
		},
		GlobalState.current_galaxy_data
	)
	GlobalState.update_elapsed_time()
	get_tree().change_scene_to_file("res://Scenes/Galaxies.tscn")



#Setting up 360 camera, to make a panorama picture for next scene
func setup_360_camera():
	cube_cam = preload("res://addons/camera360/CubeCam.tscn").instantiate()
	add_child(cube_cam)
	cube_cam.cube_size = 1024
	cube_cam.far = 100000  # Adjust based on the scale of your universe
# first texture being created for next scene
func store_star_skybox_texture(target_star):
	#cube_cam = $CubeCam
	skybox_state = false
	change_skybox()
	offset_stars(target_star)
	cube_cam.global_transform.origin = target_star.global_transform.origin
	target_star.global_transform.origin = Vector3(2137, 2137, 2137)
	cube_cam.rotate_y(deg_to_rad(90))
	$SubViewportContainer/SubViewport/Panorama.set_from_cubemap(cube_cam)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	var sub_viewport = $SubViewportContainer/SubViewport
	var viewport_texture = $SubViewportContainer/SubViewport.get_texture()
	var viewport = $SubViewportContainer/SubViewport
	var image = sub_viewport.get_texture().get_image()
	var skybox_texture = ImageTexture.create_from_image(image)
	GlobalState.store_star_skybox_texture(skybox_texture)
	#get_tree().change_scene_to_file("res://Scenes/StarCloseUp.tscn")
	store_star_offset_skybox_texture(target_star)
# changing the skybox panorama into second panorama from galaxies scene
func change_skybox():
	var skybox_offset_texture = GlobalState.get_offset_skybox_texture() #skybox_galaxy_texture
	if skybox_offset_texture:
		var env = get_environment()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0, 0, 0)
		await get_tree().create_timer(0.01).timeout
		env.background_mode = Environment.BG_SKY
		var sky = Sky.new()
		var sky_material = PanoramaSkyMaterial.new()
		sky_material.panorama = skybox_offset_texture
		sky.sky_material = sky_material
		env.sky = sky
		#print("Skybox applied successfully")
	else:
		print("No skybox texture found in GlobalState")
		# If no skybox texture, display a debug color
		var env = get_environment()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(1, 0, 0)  # Red background for debugging
# offsetting stars function used twice
func offset_stars(target_star_first_position):
	#var stars = get_tree().get_nodes_in_group("stars")
	for star in get_tree().get_nodes_in_group("stars"):
		var current_position = star.global_transform.origin
		var new_position = current_position * 2
		star.global_transform.origin = new_position
	print("All stars have been offset")
# storing second panorma texture
func store_star_offset_skybox_texture(target_star):
	offset_stars(target_star)
	change_skybox_offset()
	$SubViewportContainer/SubViewport/Panorama.set_from_cubemap(cube_cam)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	var sub_viewport = $SubViewportContainer/SubViewport
	var viewport_texture = $SubViewportContainer/SubViewport.get_texture()
	var viewport = $SubViewportContainer/SubViewport
	var image = sub_viewport.get_texture().get_image()
	var skybox_texture = ImageTexture.create_from_image(image)
	GlobalState.store_star_skybox_texture(skybox_texture)
	GlobalState.update_elapsed_time()
	get_tree().change_scene_to_file("res://Scenes/StarCloseUp.tscn") 
	

# changing texture to third panorma from first scene
func change_skybox_offset():
	var skybox_offset_texture = GlobalState.get_celestialbody_skybox_texture()
	if skybox_offset_texture:
		var env = get_environment()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0, 0, 0)
		await get_tree().create_timer(0.01).timeout
		env.background_mode = Environment.BG_SKY
		var sky = Sky.new()
		var sky_material = PanoramaSkyMaterial.new()
		shader_material = sky_material
		sky_material.panorama = skybox_offset_texture
		sky.sky_material = sky_material
		env.sky = sky
		#print("Skybox applied successfully")
	else:
		print("No skybox texture found in GlobalState")
		# If no skybox texture, display a debug color
		var env = get_environment()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(1, 0, 0)  # Red background for debugging
