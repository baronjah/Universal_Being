# Galaxies.gd in Galaxies scene
#@tool

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#
extends Node3D

@export var galaxy_count = 100
@export var field_size = Vector3(1000, 1000, 1000)
@export var base_resolution = 512  # Base resolution for scaling
@export var main_seed = 12345  # Add this line

@export var visible_galaxy_distance: float = 369.0

var galaxy_scene = preload("res://Scenes/GalaxySprite.tscn")
var galaxy_core_scene = preload("res://Scenes/GalaxyCore.tscn")
var rng = RandomNumberGenerator.new()

var debug_rect: TextureRect

# Galaxy Types
enum GalaxyType {
	SPIRAL,
	ELLIPTICAL,
	IRREGULAR,
	RING,
	DWARF
}

var galaxy_type_params = {
	GalaxyType.SPIRAL: {
		"arm_count_range": [2, 6],
		"arm_width_range": [0.2, 0.5],
		"spiral_factor_range": [0.3, 0.7],
		"star_density_range": [0.3, 1.0],
		"color_range": ["blue_white", "yellow", "orange_red"]
	},
	GalaxyType.ELLIPTICAL: {
		"shape_factor_range": [0.6, 1.2],
		"density_falloff_range": [0.3, 0.8],
		"star_density_range": [0.4, 1.2],
		"color_range": ["yellow", "orange", "red"]
	},
	GalaxyType.IRREGULAR: {
		"chaos_factor_range": [0.4, 0.9],
		"density_clusters_range": [3, 8],
		"star_density_range": [0.2, 0.8],
		"color_range": ["blue", "white", "mixed"]
	},
	GalaxyType.RING: {
		"ring_width_range": [0.1, 0.3],
		"ring_radius_range": [0.6, 0.9],
		"star_density_range": [0.3, 0.7],
		"color_range": ["blue_white", "white"]
	},
	GalaxyType.DWARF: {
		"size_factor_range": [0.2, 0.5],
		"density_range": [0.8, 1.5],
		"star_density_range": [0.4, 0.9],
		"color_range": ["red", "orange"]
	}
}

# Original parameter ranges - keeping for backward compatibility
var arm_count_range = [2, 3, 4, 5, 6]
var arm_width_range = {
	2: [0.2, 0.4],
	3: [0.3, 0.5],
	4: [0.2, 0.4],
	5: [0.3, 0.5],
	6: [0.3, 0.5]
}
var circle_size_range = [0.4, 0.5]
var star_density_range = [0.01, 0.03]
var galaxy_size_range = [10.0, 10.0]
var resolution_range = [128.0, 512.0]

var galaxy_seed
var galaxy_rng
var galaxy_temp
var cube_cam
var panorama
var galaxy
var skybox_galaxy
var resolution

var galaxies_offset_done = false




#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#
func _ready():
	var will_this_help = GlobalState.starting_zone() # GlobalSTate
	if GlobalState.is_returning_from_galaxy:
		print("Returning from galaxy, setting up return camera")
		setup_return_camera()
		rng.seed = main_seed
		generate_galaxy_field()
		#GlobalState.clear_return_from_star_data()
	else:
		print("Starting new galaxy field generation")
		rng.seed = main_seed
		generate_galaxy_field()






#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#
func generate_galaxy_field():
	for i in range(galaxy_count):
		#await get_tree().create_timer(0.001).timeout
		galaxy = galaxy_scene.instantiate()
		# Create and set up the galaxy core
		var galaxy_core = galaxy_core_scene.instantiate()
		
		# Generate a unique, deterministic seed for each galaxy
		galaxy_seed = generate_galaxy_seed(i)
		add_child(galaxy)
		galaxy.add_child(galaxy_core)
		
		# Determine the galaxy type based on the seed
		var galaxy_type = determine_galaxy_type(galaxy_seed)
		
		# Generate parameters for this galaxy type
		var galaxy_params = generate_galaxy_parameters(galaxy_type, galaxy_seed)
		
		# Use this seed to set up a separate RNG for this galaxy's parameters
		galaxy_rng = RandomNumberGenerator.new()
		galaxy_rng.seed = galaxy_seed
		var position_galaxy = generate_spherical_position(field_size, galaxy_rng)
		galaxy.transform.origin = position_galaxy

		# Set parameters based on galaxy type
		var arm_count
		var arm_width
		var circle_size
		var star_density
		var fog_density
		var fog_arm_width_multiplier
		var galaxy_fog_swirl
		
		# For backward compatibility, set default values first
		circle_size = galaxy_rng.randf_range(circle_size_range[0], circle_size_range[1])
		fog_density = galaxy_rng.randf_range(0.05, 0.1)
		fog_arm_width_multiplier = galaxy_rng.randf_range(1.5, 2.0)
		resolution = resolution_range[galaxy_rng.randi() % resolution_range.size()]
		var galaxy_fog_temperature = random_temperature()
		var galaxy_fog_color = random_color(galaxy_fog_temperature)
		
		# Apply type-specific parameters
		match galaxy_type:
			GalaxyType.SPIRAL:
				arm_count = galaxy_params.arm_count
				arm_width = galaxy_params.arm_width
				star_density = galaxy_rng.randf_range(star_density_range[0], star_density_range[1])
				galaxy_fog_swirl = galaxy_params.spiral_factor * 20.0  # Convert to proper range
				
			GalaxyType.ELLIPTICAL:
				# Elliptical galaxies have no arms
				arm_count = 0
				arm_width = 0
				circle_size = galaxy_params.shape_factor
				star_density = galaxy_rng.randf_range(star_density_range[0], star_density_range[1]) * 1.5
				fog_density = galaxy_rng.randf_range(0.1, 0.2)  # More diffuse fog
				galaxy_fog_swirl = 0.0
				
			GalaxyType.IRREGULAR:
				# Irregular galaxies have chaotic structure
				arm_count = galaxy_rng.randi_range(1, 3)  # Few distinguishable arms
				arm_width = galaxy_rng.randf_range(0.5, 0.8)  # Wider arms
				circle_size = galaxy_rng.randf_range(0.3, 0.7)
				star_density = galaxy_rng.randf_range(star_density_range[0], star_density_range[1]) * 0.8
				fog_density = galaxy_rng.randf_range(0.07, 0.15)
				galaxy_fog_swirl = galaxy_rng.randf_range(0.1, 5.0)  # Random swirl
				
			GalaxyType.RING:
				# Ring galaxies have a prominent ring structure
				arm_count = galaxy_rng.randi_range(1, 2)  # Few arms
				arm_width = galaxy_params.ring_width
				circle_size = galaxy_params.ring_radius
				star_density = galaxy_rng.randf_range(star_density_range[0], star_density_range[1]) * 0.7
				fog_density = galaxy_rng.randf_range(0.05, 0.1)
				galaxy_fog_swirl = galaxy_rng.randf_range(8.0, 12.0)  # High swirl
				
			GalaxyType.DWARF:
				# Dwarf galaxies are smaller with fewer stars
				arm_count = galaxy_rng.randi_range(0, 2)  # Few or no arms
				arm_width = galaxy_rng.randf_range(0.2, 0.4)
				circle_size = galaxy_rng.randf_range(0.6, 0.8)  # More concentrated
				star_density = galaxy_rng.randf_range(star_density_range[0], star_density_range[1]) * 0.5
				fog_density = galaxy_rng.randf_range(0.03, 0.08)  # Less fog
				galaxy_fog_swirl = galaxy_rng.randf_range(1.0, 5.0)
		
		if galaxy_type == GalaxyType.SPIRAL:
			galaxy_fog_swirl = random_swirld(arm_count)  # Use traditional function for spirals
		
		if not galaxy.has_method("set_parameters"):
			print("Error: galaxy instance does not have set_parameters method")
			continue
			
		galaxy.set_parameters(
			galaxy_seed,
			arm_count,
			arm_width,
			circle_size,
			star_density,
			resolution,
			fog_density,
			fog_arm_width_multiplier,
			galaxy_fog_color,
			galaxy_temp,
			galaxy_fog_temperature,
			galaxy_fog_swirl
		)
		
		# Store galaxy type for later reference
		galaxy.set_meta("galaxy_type", galaxy_type)
		
		galaxy_core.set_parameters(galaxy_fog_color, resolution * 4)
		
		# Set galaxy size based on type
		var scale_factor
		match galaxy_type:
			GalaxyType.DWARF:
				scale_factor = galaxy_params.size_factor * 5.0  # Smaller
			GalaxyType.RING, GalaxyType.IRREGULAR:
				scale_factor = galaxy_rng.randf_range(7.0, 12.0)  # Average
			GalaxyType.ELLIPTICAL:
				scale_factor = galaxy_rng.randf_range(10.0, 15.0)  # Larger
			_:  # Default/Spiral
				scale_factor = galaxy_rng.randf_range(8.0, 12.0)  # Standard
				
		galaxy.scale = Vector3(scale_factor, scale_factor, scale_factor)
		galaxy.rotation = Vector3(
			galaxy_rng.randf_range(0, 2 * PI),
			galaxy_rng.randf_range(0, 2 * PI),
			galaxy_rng.randf_range(0, 2 * PI)
		)
		galaxy.add_to_group("galaxies")
	print("Galaxy field generation complete!")
	
func generate_spherical_position(field_size: Vector3, rng: RandomNumberGenerator) -> Vector3:
	var radius = field_size.x / 2  # Assuming field_size is cubic
	
	# Generate random spherical coordinates
	var theta = rng.randf_range(0, 2 * PI)  # Azimuthal angle
	var phi = acos(rng.randf_range(-1, 1))  # Polar angle
	var r = radius * pow(rng.randf(), 1.0/3.0)  # Radius
	
	# Convert spherical coordinates to Cartesian
	var x = r * sin(phi) * cos(theta)
	var y = r * sin(phi) * sin(theta)
	var z = r * cos(phi)
	
	return Vector3(x, y, z)
	
func generate_galaxy_seed(index: int) -> int:
	# Generate a base value from the main seed
	rng.seed = main_seed
	var base = rng.randi()
	# Combine the base value with the galaxy index to create a unique seed
	return base + index
	
func determine_galaxy_type(seed_value):
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Distribution of galaxy types
	var roll = rng.randf()
	if roll < 0.5:
		return GalaxyType.SPIRAL  # 50% chance
	elif roll < 0.75:
		return GalaxyType.ELLIPTICAL  # 25% chance
	elif roll < 0.85:
		return GalaxyType.IRREGULAR  # 10% chance
	elif roll < 0.95:
		return GalaxyType.RING  # 10% chance
	else:
		return GalaxyType.DWARF  # 5% chance

func generate_galaxy_parameters(galaxy_type, seed_value):
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	var params = {}
	var type_params = galaxy_type_params[galaxy_type]
	
	# Common parameters for all galaxy types
	params.size = rng.randf_range(80.0, 120.0)
	params.star_count = int(rng.randf_range(500, 2000))
	
	# Type-specific parameters
	match galaxy_type:
		GalaxyType.SPIRAL:
			params.arm_count = rng.randi_range(type_params.arm_count_range[0], type_params.arm_count_range[1])
			params.arm_width = rng.randf_range(type_params.arm_width_range[0], type_params.arm_width_range[1])
			params.spiral_factor = rng.randf_range(type_params.spiral_factor_range[0], type_params.spiral_factor_range[1])
		GalaxyType.ELLIPTICAL:
			params.shape_factor = rng.randf_range(type_params.shape_factor_range[0], type_params.shape_factor_range[1])
			params.density_falloff = rng.randf_range(type_params.density_falloff_range[0], type_params.density_falloff_range[1])
		GalaxyType.IRREGULAR:
			params.chaos_factor = rng.randf_range(type_params.chaos_factor_range[0], type_params.chaos_factor_range[1])
			params.density_clusters = rng.randi_range(type_params.density_clusters_range[0], type_params.density_clusters_range[1])
		GalaxyType.RING:
			params.ring_width = rng.randf_range(type_params.ring_width_range[0], type_params.ring_width_range[1])
			params.ring_radius = rng.randf_range(type_params.ring_radius_range[0], type_params.ring_radius_range[1])
		GalaxyType.DWARF:
			params.size_factor = rng.randf_range(type_params.size_factor_range[0], type_params.size_factor_range[1])
			params.density = rng.randf_range(type_params.density_range[0], type_params.density_range[1])
	
	# Choose color scheme
	var color_options = type_params.color_range
	params.color_scheme = color_options[rng.randi() % color_options.size()]
	
	return params

func capture_visible_galaxies(target_galaxy):
	var visible_galaxies = []
	var target_position = target_galaxy.global_transform.origin
	for galaxy in get_tree().get_nodes_in_group("galaxies"):
		if galaxy != target_galaxy and is_galaxy_visible(galaxy, target_position):
			visible_galaxies.append({
				"position": galaxy.global_transform.origin - target_position,
				"scale": galaxy.scale,
				"parameters": galaxy.get_shader_parameters()
			})
	return visible_galaxies

func is_galaxy_visible(galaxy, from_position):
	if galaxy == null or from_position == null:
		return false
	var distance = galaxy.global_transform.origin.distance_to(from_position)
	return distance <= visible_galaxy_distance
	
func capture_galaxy_field(target_galaxy: Node3D) -> Dictionary:
	var field_data = {}
	for galaxy in get_tree().get_nodes_in_group("galaxies"):
		if galaxy != target_galaxy:
			field_data[galaxy.get_instance_id()] = {
				"position": galaxy.global_transform.origin - target_galaxy.global_transform.origin,
				"scale": galaxy.scale,
				"color": galaxy.get_node("Sprite3D").modulate,
				"parameters": galaxy.get_shader_parameters()
			}
	return field_data

func store_galaxy_field_data(target_galaxy: Node3D):
	var field_data = capture_galaxy_field(target_galaxy)
	GlobalState.store_galaxy_field(field_data)

func transition_to_galaxy(target_galaxy):
	if target_galaxy == null:
		print("Error: target_galaxy is null")
		return
	# a variant that becomes a function of a variant
	var visible_galaxies = capture_visible_galaxies(target_galaxy)
	GlobalState.store_visible_galaxies(visible_galaxies)
	#Global state function to store galaxy data, something can be like var something = null, and then we make something that is in function in different script in its (word) so that word becomes {} for example
	GlobalState.store_galaxy_data({
		"id": target_galaxy.get_galaxy_id(),
		"seed": target_galaxy.get_galaxy_seed(),
		"shader_params": target_galaxy.get_shader_parameters(),
		"texture": target_galaxy.get_galaxy_texture(),
		"scale": target_galaxy.scale,
		"rotation": target_galaxy.rotation,
		"shader_path": target_galaxy.material_override.shader.resource_path if target_galaxy.material_override and target_galaxy.material_override.shader else null,
		"rotation_quat": target_galaxy.global_transform.basis,  # Capture full rotation
		"galaxy_position": target_galaxy.global_transform.origin
	})
	
	# Store camera information
	var camera = $Camera3D
	print("galaxies pitch stuff transition to a galaxy  camera._total_pitch = ",  camera._total_pitch)
	GlobalState.store_camera_data({
		"position": camera.global_transform.origin - target_galaxy.global_transform.origin,
		"rotation": camera.global_rotation,
		"total_pitch": camera._total_pitch if "_total_pitch" in camera else 0.0
	})
	skybox_galaxy = target_galaxy
	#set up 360 camera, load scene and stuff
	setup_360_camera()
	# generating skybox function
	generate_and_store_skybox(target_galaxy)
	# because of await stuff, i had to move it to where we play around with cubecam
	#get_tree().change_scene_to_file("res://Scenes/GalaxyCloseUp.tscn")

func setup_debug_display():
	debug_rect = TextureRect.new()
	debug_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	debug_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	debug_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(debug_rect)
	
func random_color(galaxy_temperature: float) -> Color:
	var galaxy_type = galaxy_rng.randi() % 5  # 0-4 for different galaxy types
	#print("galaxy temp in function = ", galaxy_temperature)
	
	# Define color ranges for different temperature brackets
	var colors = [
		Color(1.0, 0.0, 0.0),   # Red
		Color(1.0, 0.5, 0.0),   # Orange
		Color(1.0, 1.0, 0.0),   # Yellow
		Color(1.0, 1.0, 1.0),   # White
		Color(0.5, 1.0, 1.0),   # Light Blue
		Color(0.0, 0.0, 1.0),   # Blue
		Color(0.5, 0.0, 1.0)    # Purple
	]

	# Define the temperature range
	var min_temp = 2000.0
	var max_temp = 18000.0

	# Clamp temperature between min_temp and max_temp
	var clamped_temp = clamp(galaxy_temperature, min_temp, max_temp)
	
	# Normalize temperature to 0-1 range
	var normalized_temp = (clamped_temp - min_temp) / (max_temp - min_temp)
	
	# Ensure normalized_temp is exactly 0.0 or 1.0 at the extremes
	if is_equal_approx(normalized_temp, 0.0):
		normalized_temp = 0.0
	elif is_equal_approx(normalized_temp, 1.0):
		normalized_temp = 1.0
	
	# Calculate color index
	var color_index = normalized_temp * (colors.size() - 1)
	
	var index1 = int(floor(color_index))
	var index2 = int(ceil(color_index))
	index2 = min(index2, colors.size() - 1)  # Ensure we don't go out of bounds
	
	var t = fmod(color_index, 1.0)
	
	# Interpolate between the two closest colors
	var final_color = colors[index1].lerp(colors[index2], t)
	
	# Apply gamma correction
	final_color.r = pow(final_color.r, 1.0 / 2.2)
	final_color.g = pow(final_color.g, 1.0 / 2.2)
	final_color.b = pow(final_color.b, 1.0 / 2.2)
	
	#print("final color maybe lol = ", final_color)
	return final_color

func random_temperature():
	var galaxy_temperature = galaxy_rng.randf_range(0.0, 20000.0)
	
	if (galaxy_temperature < 2000.0):
		galaxy_temp = 0 # Red
	elif (galaxy_temperature < 4000.0):
		galaxy_temp = 1 # Orange
	elif (galaxy_temperature < 5000.0):
		galaxy_temp = 2 # Yellow
	elif (galaxy_temperature < 7000.0):
		galaxy_temp = 3 # White
	elif (galaxy_temperature < 8000.0):
		galaxy_temp = 4 # Light Blue
	elif (galaxy_temperature < 10000.0):
		galaxy_temp = 5 # Light Blue
	elif (galaxy_temperature < 14000.0):
		galaxy_temp = 6 # Blue
	elif (galaxy_temperature > 18000.0):
		galaxy_temp = 7 # Purple
	#print(galaxy_temp)
	return galaxy_temperature
	
func random_swirld(arm_count):
	var galaxy_swirld #= galaxy_rng.randf_range(5.0, 13.0)
	#print("arm_count = ", arm_count)
	match arm_count:
		2:  # Two armed galaxies
			galaxy_swirld = galaxy_rng.randf_range(13.0, 22.0)
		3:  # Three armed galaxies
			galaxy_swirld = galaxy_rng.randf_range(9.0, 15.0)
		4:  # Four armed galaxies
			galaxy_swirld = galaxy_rng.randf_range(7.0, 9.0)
		5:  # Five armed galaxies
			galaxy_swirld = galaxy_rng.randf_range(6.0, 8.0)
		6:  # Six armed galaxies
			galaxy_swirld = galaxy_rng.randf_range(5.0, 7.0)
	
	#print("galaxy_swirld = ", galaxy_swirld)
	return galaxy_swirld
func setup_360_camera():
	print("func setup_360_camera():")
	#preloading the scene to add it as node later
	cube_cam = preload("res://addons/camera360/CubeCam.tscn").instantiate()
	#after loading a scene, we add it as node
	add_child(cube_cam)
	cube_cam.cube_size = 1024
	cube_cam.far = 100000  # Adjust based on the scale of your universe

func generate_and_store_skybox(target_galaxy):
	offset_galaxies_first_impact(target_galaxy) #offset_galaxies_first_impact
	cube_cam.global_position = target_galaxy.global_transform.origin
	cube_cam.global_transform.origin = target_galaxy.global_transform.origin
	var target_galaxy_first_position = target_galaxy.global_transform.origin 
	target_galaxy.global_transform.origin = Vector3(2137, 2137, 2137)

	$SubViewportContainer/SubViewport/Panorama.set_from_cubemap(cube_cam)
	
	# Wait for a few frames to ensure the Panorama node is updated
	await get_tree().process_frame
	#await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	
	
	
	var sub_viewport = $SubViewportContainer/SubViewport
	#print("rotation of cubecam = ", cube_cam.global_rotation)
	#print("SubViewport size: ", sub_viewport.size)
	#print("$SubViewportContainer size: ", $SubViewportContainer.size)
	#print("$SubViewportContainer/SubViewport/Panorama size: ", $SubViewportContainer/SubViewport/Panorama.size)
	var viewport_texture = $SubViewportContainer/SubViewport.get_texture()
	
	var viewport = $SubViewportContainer/SubViewport
	var image = viewport.get_texture().get_image()
	
	# Create a texture from the captured image
	var skybox_texture = ImageTexture.create_from_image(image)
	
	# Ensure the texture is not a placeholder
	if skybox_texture == null:
		print("Error: Panorama texture is null")
		return
	
	GlobalState.store_skybox_texture(skybox_texture)
	print("Skybox texture stored successfully")

	offset_galaxies(target_galaxy_first_position) #offset_galaxies_first_impact


func setup_return_camera():
	if GlobalState.return_camera_data and GlobalState.return_galaxy_data:
		var camera = $Camera3D as FreeLookCamera  # Make sure this matches your camera class name
		
		# Set camera position
		camera.global_transform.origin = GlobalState.return_camera_data.position
		print("Camera return position: ", camera.global_transform.origin)
		
		# Set camera rotation
		camera.global_rotation = GlobalState.return_camera_data.rotation
		print("Camera return rotation: ", camera.global_rotation)
		
		# Set camera pitch
		camera._total_pitch = GlobalState.return_camera_data.total_pitch
		print("Camera return pitch: ", camera._total_pitch)
		
		# Print galaxy data for reference
		print("Returned from galaxy ID: ", GlobalState.return_galaxy_data.id)
		print("Galaxy position: ", GlobalState.return_galaxy_data.galaxy_position)
		
		# You might want to highlight or focus on the galaxy you returned from
		# This depends on how you want to handle the return visually
		highlight_returned_galaxy(GlobalState.return_galaxy_data.galaxy_position)
		
		# Clear the return data after using it
		GlobalState.clear_return_data()
	else:
		print("No return data available, using default position")

func highlight_returned_galaxy(position: Vector3):
	# This is a placeholder function. Implement this based on how you want to
	# visually indicate the galaxy you returned from.
	print("Highlighting galaxy at position: ", position)
	# For example, you might want to create a temporary visual indicator
	# or move the camera to focus on this position

func offset_galaxies_first_impact(target_galaxy_first_position):
	for galaxy in get_tree().get_nodes_in_group("galaxies"):
		var current_position = galaxy.global_transform.origin
		var new_position = current_position * 2
		galaxy.global_transform.origin = new_position
	print("All galaxies have been offset")

func offset_galaxies(target_galaxy_first_position):
	for galaxy in get_tree().get_nodes_in_group("galaxies"):
		var current_position = galaxy.global_transform.origin
		var new_position = current_position * 2
		galaxy.global_transform.origin = new_position
	print("All galaxies have been offset")
	generate_and_store_offset_skybox(target_galaxy_first_position)
	
func offset_galaxies_last_supper(target_galaxy_first_position):
	for galaxy in get_tree().get_nodes_in_group("galaxies"):
		var current_position = galaxy.global_transform.origin
		var new_position = current_position * 2
		galaxy.global_transform.origin = new_position
	print("All galaxies have been offset")
	generate_and_store_celestialbody_skybox(target_galaxy_first_position)

func generate_and_store_offset_skybox(target_galaxy_first_position):

	
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	
	
	var sub_viewport = $SubViewportContainer/SubViewport
	print("rotation of cubecam = ", cube_cam.global_rotation)
	print("SubViewport size: ", sub_viewport.size)
	print("$SubViewportContainer size: ", $SubViewportContainer.size)
	print("$SubViewportContainer/SubViewport/Panorama size: ", $SubViewportContainer/SubViewport/Panorama.size)
	var viewport_texture = $SubViewportContainer/SubViewport.get_texture()
	
	var viewport = $SubViewportContainer/SubViewport
	var image = viewport.get_texture().get_image()
	
	# Create a texture from the captured image
	var skybox_texture = ImageTexture.create_from_image(image)
	
	# Ensure the texture is not a placeholder
	if skybox_texture == null:
		print("Error: Panorama texture is null")
		return
	
	# Store the skybox texture in GlobalState
	GlobalState.store_offset_skybox_texture(skybox_texture)
	print("Skybox texture stored successfully")
	
	offset_galaxies_last_supper(target_galaxy_first_position)
	#get_tree().change_scene_to_file("res://Scenes/GalaxyCloseUp.tscn")
	
	
#GlobalState.store_celestialbody_skybox_texture(skybox_texture)
func generate_and_store_celestialbody_skybox(target_galaxy_first_position):

	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	var sub_viewport = $SubViewportContainer/SubViewport
	print("rotation of cubecam = ", cube_cam.global_rotation)
	print("SubViewport size: ", sub_viewport.size)
	print("$SubViewportContainer size: ", $SubViewportContainer.size)
	print("$SubViewportContainer/SubViewport/Panorama size: ", $SubViewportContainer/SubViewport/Panorama.size)
	var viewport_texture = $SubViewportContainer/SubViewport.get_texture()
	
	var viewport = $SubViewportContainer/SubViewport
	var image = viewport.get_texture().get_image()
	
	# Create a texture from the captured image
	var skybox_texture = ImageTexture.create_from_image(image)
	
	# Ensure the texture is not a placeholder
	if skybox_texture == null:
		print("Error: Panorama texture is null")
		return
	
	# Store the skybox texture in GlobalState
	GlobalState.store_celestialbody_skybox_texture(skybox_texture)
	print("Skybox texture stored successfully")
	GlobalState.update_elapsed_time()
	get_tree().change_scene_to_file("res://Scenes/GalaxyCloseUp.tscn")
