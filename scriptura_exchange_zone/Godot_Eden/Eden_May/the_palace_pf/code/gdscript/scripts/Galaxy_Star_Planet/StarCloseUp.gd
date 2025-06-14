#StarCloseUp.gd a Node3D, just a startpoint, it should be a next scene, where in first we generate galaxies, then we go to a single galaxy made from stars, and then we go to a single star that was made in second scene
extends Node3D

var cube_cam
var star_scene = preload("res://Scenes/CelestialBody.tscn")
var Cassiopeia_offset_system
var camera_distance = 100.0
var star_seed
var rng = RandomNumberGenerator.new()
var planet_seed
var planet_scene = preload("res://Scenes/CelestialPlanet.tscn")
var orbit_scene = preload("res://Scenes/Orbit.tscn")
var planets = []
var furthest_planet_distance = 0
var last_planet_distance = 50
var camera_distance_to_star

var return_distance
var camera_fist_distance
var camera_first_position
var camera_return_distance

var closest_planet = null
var closest_distance = INF
var transition_distance = 33.0

# ready function, run once at scene initialization
func _ready():
	star_seed = GlobalState.current_star_data.seed
	rng.seed = star_seed
	setup_star()
	apply_skybox()
	generate_planets()
#	print_planet_info()
	setup_camera()

	

# a function to setup star with previously generated data! that shader is faya tho
func setup_star():
	if GlobalState.current_star_data:
		print("GlobalState.current_star_data = ", GlobalState.current_star_data)
		print("GlobalState.current_star_data.brightness = ", GlobalState.current_star_data.brightness)
		print("so division shall happen here huh? = GlobalState.current_star_data.brightness / 100 = ", GlobalState.current_star_data.brightness / 100)
		var star = star_scene.instantiate()
		star.position = Vector3(0,0,0)
		star.scale = GlobalState.current_star_data.scale
		add_child(star)
		var celestial_body_seed = GlobalState.current_star_data.seed
		var celestial_body_temperature = GlobalState.current_star_data.temperature
		var celestial_body_size = GlobalState.current_star_data.brightness
		star.set_parameters(celestial_body_seed, celestial_body_temperature, celestial_body_size)

# setup camera, its pitch rotations and coordinates
func setup_camera():
	var camera = $Camera3D as FreeLookCamera2
	print("setup camera function star closeup")
	var camera_data = GlobalState.get_galaxy_to_star_camera_data()
	var star_position = GlobalState.current_star_data.position
	if camera_data:
		camera.global_transform.origin = camera_data.position - star_position #* camera_distance
		camera_first_position = camera.global_transform.origin
		var coordinator = Vector3(0,0,0)
		camera_fist_distance = camera.global_transform.origin.distance_to(coordinator)
		Cassiopeia_offset_system = furthest_planet_distance / camera_fist_distance
		
		camera.global_transform.origin = (camera.global_transform.origin * Cassiopeia_offset_system)
		
		camera_distance_to_star = camera.global_transform.origin.distance_to(coordinator)
		
		camera.global_rotation = camera_data.rotation
		print("camera_data.total_pitch = ", camera_data.total_pitch)
		camera._total_pitch = camera_data.total_pitch

# the Panorama image put on sphere inversed, mortals call it skybox, a box that is a sphere?
func apply_skybox():
	var skybox_texture = GlobalState.get_star_skybox_texture()
	if skybox_texture:
		var env = get_environment()
		env.background_mode = Environment.BG_SKY
		var sky = Sky.new()
		var sky_material = PanoramaSkyMaterial.new()
		sky_material.panorama = skybox_texture
		sky.sky_material = sky_material
		env.sky = sky
	else:
		print("No star skybox texture found in GlobalState")
		# Apply a debug color if no skybox is available

# the thingy where we add environment, i kinda dunno why we need it as we already are just adding image as our world? maybe the lights and ambients are there
func get_environment():
	var world = get_viewport().get_world_3d()
	if not world.environment:
		world.environment = Environment.new()
	return world.environment

# we run it each and every frame :)
func _process(delta):
	check_for_return()
	check_for_planet_transition()
	update_closest_planet()

# check if distance from center of scene is further than 1.2 disance from furthest planet
func check_for_return():
	var camera = $Camera3D
	return_distance = furthest_planet_distance * 1.3
	if camera.global_transform.origin.length() > return_distance:
		transition_to_galaxy()

# after we are too far away, we just go back to that fire galaxy made from stars! and them stars were dots previously lol
func transition_to_galaxy():
	var camera = $Camera3D
	GlobalState.store_star_to_galaxy_camera_data({
		"position": camera.global_transform.origin,
		"rotation": camera.global_rotation,
		"total_pitch": camera._total_pitch
	})
	
	var camera_coord_new = (camera.global_transform.origin / (Cassiopeia_offset_system * 0.8))# hmm that line i think
	
	var current_distance_to_star = camera.global_transform.origin.length()
	var some_new_thing = camera_coord_new.distance_to(Vector3(0,0,0))
	GlobalState.store_return_from_star_data({
		"position": camera_coord_new,
		"rotation": camera.global_rotation,
		"total_pitch": camera._total_pitch,
		"previous_star_coordinates": GlobalState.current_star_data.position
	})
	GlobalState.update_elapsed_time()
	get_tree().change_scene_to_file("res://Scenes/GalaxyCloseUp.tscn")

# generate planets! take that tasty seed from my star! then make me them planets
func generate_planets():
	var planet_count = rng.randi_range(1, 8)
	for i in range(planet_count):
		var planet_seed = star_seed * 1000 + i
		var planet_data = generate_planet_data(planet_seed, i)
		create_planet(planet_data, i)

# here we are generating data to create them planets! from here we are also going to few other functions
func generate_planet_data(planet_seed: int, index: int) -> Dictionary:
	rng.seed = planet_seed
	var planet_type = generate_planet_type(index)
	#var radius = rng.randf_range(5.0, 20.0)
	var radius = generate_radius(planet_type)
	var orbit_radius = calculate_orbit_radius(planet_type, radius, index)
	
	var planet = {
		"seed": planet_seed,
		"type": planet_type,
		"radius": radius,
		"mass": calculate_mass(planet_type, radius),
		"orbit_radius": orbit_radius,
		"orbit_speed": calculate_orbit_speed(orbit_radius),
		"moons": rng.randi_range(0, 5),
		"habitable": rng.randf() < 0.1,
		"water": rng.randf() < 0.3,
		"basic_resources": rng.randf() < 0.7,
		"rare_resources": rng.randf() < 0.2,
		"planet_tilt": rng.randf_range(0.0, 360.0),
		"planet_spin_speed": rng.randf_range(0.01, 0.001)
	}
	return planet

func generate_radius(planet_type: int):
	match planet_type:
		0: # Earth-like
			return rng.randf_range(9.0, 22.0)
		1: # Rocky Red
			return rng.randf_range(8.0, 18.0)
		2: # Ice Planet
			return rng.randf_range(12.0, 29.0)
		3: # Lava Planet
			return rng.randf_range(13.0, 22.0)
		4: # Exo Planet
			return rng.randf_range(9.0, 28.0)
		5: # Rocky Grey
			return rng.randf_range(4.0, 15.0)
		6: # Gas Giant
			return rng.randf_range(22.0, 43.0)
# here we shall generate type of planets based on how far away it is from a Star :)
func generate_planet_type(index: int) -> int:
	match index:
		0: # planet_type = 1 or 3
			return [1, 3][rng.randi_range(0, 1)] # Rocky Red, Lava Planet
		1: # planet_type 1 or 5
			return [1, 5][rng.randi_range(0, 1)] # Rocky Red, Rocky Grey
		2: # planet type = 0 or 4
			return [0, 4][rng.randi_range(0, 1)] # Earth-like, Exo Planet
		3: #planet type = 0 or 4
			return [0, 4][rng.randi_range(0, 1)] # Earth-like, Exo Planet
		4: # planet_type = 1 or 5
			return [1, 5][rng.randi_range(0, 1)] # Rocky Red, Rocky Grey
		5: # planet_type = 1 or 5 or 2
			return [1, 5, 2][rng.randi_range(0, 2)] # Rocky Red, Rocky Grey, Ice Planet
		_: # # planet_type = 2 or 5 or 6
			return [2, 5, 6][rng.randi_range(0, 2)]  # Ice Planet, Rocky Grey, or Gas Giant

# here we are calculating orbit radius based on few variable numbers
func calculate_orbit_radius(planet_type: int, radius: float, index: int) -> float:
	var min_distance = last_planet_distance + 20  # Minimum 20 units from the last planet
	var max_distance = min_distance + 50 + (index * 20)  # Increase max distance for outer planets
	
	var new_radius = rng.randf_range(min_distance, max_distance)
	last_planet_distance = new_radius  # Update the last planet distance
	print("new radius = ", new_radius)
	return new_radius

# how fast that baby conna spin around our super star!
func calculate_orbit_speed(orbit_radius: float) -> float:
	# Simplified orbit speed calculation (inverse square law)
	return (1.0 / sqrt(orbit_radius) / 10000)

# here we calculate the mass of planet! gotta change it to something more logical to my monkey brain as i put there whatever lol and the gravity tho!
func calculate_mass(planet_type: int, radius: float) -> float:
	match planet_type: #planet_type
		0: return radius ** 3.7  # Earth-like
		1: return radius ** 3.3  # Rocky Red
		2: return radius ** 3.5  # Ice Giant
		3: return radius ** 3.2  # Lava Giant
		4: return radius ** 4.2  # Exo Planet
		5: return radius ** 3.6  # Rocky Grey
		6: return radius ** 1.2 # Gas Giant
	return 0.0

# adding a scene with nodes and sprite and shader! to make me see the flat image as a 3d hallucination!
func create_planet(planet_data: Dictionary, index: int):
	var orbit_instance = orbit_scene.instantiate()
	add_child(orbit_instance)
	
	var planet_instance = planet_scene.instantiate()
	orbit_instance.add_child(planet_instance)
	
	planet_instance.set_planet_data(planet_data)
	orbit_instance.set_orbit_data(planet_data.orbit_speed, planet_data.orbit_radius)
	# Calculate a random angle for the planet's position in its orbit
	var angle = rng.randf_range(0, 2 * PI)
	
	# Calculate the planet's position using trigonometry, ancient schollars still dont know whatever it is about lol
	var x = cos(angle) * planet_data.orbit_radius
	var z = sin(angle) * planet_data.orbit_radius
	
	# Set the planet's position
	planet_instance.position = Vector3(x, 0, z)
	orbit_instance.Alpha_delta()
	
	# Tilt the orbit slightly (optional)
	var tilt_angle = rng.randf_range(-0.1, 0.1)  # Tilt by up to 0.1 radians (about 5.7 degrees)
	orbit_instance.rotate_x(tilt_angle)
	
	planets.append({
		"instance": planet_instance,
		"orbit": orbit_instance,
		"data": planet_data
	})
	furthest_planet_distance = max(furthest_planet_distance, planet_data.orbit_radius)
	planet_instance.add_to_group("planets")

func update_closest_planet():
	var camera = $Camera3D
	closest_planet = null
	closest_distance = INF
	for planet in get_tree().get_nodes_in_group("planets"):
		var distance = camera.global_transform.origin.distance_to(planet.global_transform.origin)
		if distance < closest_distance:
			closest_planet = planet
			closest_distance = distance

func check_for_planet_transition():
	if closest_planet and closest_distance < transition_distance:  # Define transition_distance
		var planet_data_AR = closest_planet.get_planet_data_records()
		transition_to_planet(planet_data_AR)

func store_planet_system_data():
	GlobalState.store_planet_system(planets)

func transition_to_planet(current_planet_data: Dictionary):
	store_planet_system_data()
	var current_planet_recorda = current_planet_data
	GlobalState.store_planet_data(current_planet_recorda)
	
	# Store camera data
	var camera = $Camera3D
	GlobalState.store_star_to_planet_camera_data({
		"position": camera.global_transform.origin,
		"rotation": camera.global_rotation,
		"total_pitch": camera._total_pitch
	})
	
	# Transition to the CelestialBodyCloseUp scene
	#get_tree().change_scene_to_file("res://Scenes/CelestialBodyCloseUp.tscn")
