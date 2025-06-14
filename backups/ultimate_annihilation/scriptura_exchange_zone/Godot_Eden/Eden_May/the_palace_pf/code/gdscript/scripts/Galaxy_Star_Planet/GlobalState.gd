# it was in galaxies now it is in eden
# i think i added it in one project in autoload
# now we mostly load in copy of luminus
#
# so we add snake game for some reason too
#
# GlobalState
#
# res://code/gdscript/scripts/Galaxy_Star_Planet/GlobalState.gd
#
# uid://dxkmdghkhlyf3
#
#GlobalSTate.gd a script that is setup in autoload so it is always in background and we can store and save things with help of it and send between scenes some informations
#
# expect problem as you see tool and autload and any process and input and ready stuff
#
# as we must check inbetween and connect them somehow
#
@tool


#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

# a scripts that runs underneath and keeps data, needs some help in seeing

extends Node

var current_galaxy_data = null
var visible_galaxies = []
var camera_data = null
var current_star_data = null
var return_galaxy_data = null
var visible_stars = []
var galaxy_field_data: Dictionary
var all_star_data = {}
var return_star_coordinates = null

var current_planet_system = []
var current_planet_data = null

var skybox_texture: Texture2D
var skybox_galaxy_texture: Texture2D
var skybox_galaxy_celestialbody_texture: Texture2D

var star_skybox_texture: Texture2D
var star_skybox_celestialbody_texture: Texture2D
var sphere_of_creation_texture: Texture2D

var is_returning_from_galaxy = false
var is_returning_from_star = false
var is_returning_from_celestialbody = false
var is_returning_from_sphere_of_creation = false

var return_camera_data = null
var galaxy_to_star_camera_data = null
var star_to_galaxy_camera_data = null
var star_to_planet_camera_data = null
var celestialbody_to_star_camera_data = null
var sphere_of_creation_return_data = null

var elapsed_time_seconds: float = 0.0
var last_update_time: int = 0




#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#


func update_elapsed_time():
	var current_time = Time.get_ticks_msec()
	if last_update_time != 0:
		var delta_time = (current_time - last_update_time) / 1000.0
		elapsed_time_seconds += delta_time
	last_update_time = current_time

func store_galaxy_field(field_data: Dictionary):
	galaxy_field_data = field_data

func get_galaxy_field() -> Dictionary:
	return galaxy_field_data

func store_galaxy_data(galaxy_data: Dictionary):
	current_galaxy_data = {
		"id": galaxy_data.id,
		"seed": galaxy_data.seed,
		"shader_path": galaxy_data.shader_path if "shader_path" in galaxy_data else null,
		"shader_params": galaxy_data.shader_params,
		"texture": galaxy_data.texture if "texture" in galaxy_data else null,
		"scale": galaxy_data.scale if "scale" in galaxy_data else Vector3.ONE,
		"rotation": galaxy_data.rotation if "rotation" in galaxy_data else Vector3.ZERO,
		"rotation_quat": galaxy_data.rotation_quat,
		"galaxy_position": galaxy_data.galaxy_position
	}

func store_visible_galaxies(galaxies):
	visible_galaxies = galaxies
	print("GlobalState: Stored ", visible_galaxies.size(), " visible galaxies")

func store_camera_data(data):
	camera_data = data
	print("Stored camera data: ", camera_data)

func store_visible_stars(stars):
	visible_stars = stars
	print("GlobalState: Stored ", visible_stars.size(), " visible stars")
	
func generate_star_data(star_seed: int) -> Dictionary:
	var star_rng = RandomNumberGenerator.new()
	star_rng.seed = star_seed + 1

	var galaxy_color = current_galaxy_data.shader_params.u_galaxy_color
	
	# Calculate a temperature bias based on the galaxy color
	var temp_bias# = (galaxy_color.r * 15000 + galaxy_color.g * 10000 + galaxy_color.b * 25000) / (galaxy_color.r + galaxy_color.g + galaxy_color.b)
	var galaxy_temp_type = current_galaxy_data.shader_params.u_galaxy_temp
	var galaxy_temperature = current_galaxy_data.shader_params.u_galaxy_temperature
	#print("galaxy temperature = " , galaxy_temperature)
	# Generate star temperature with a bias towards the galaxy color
	var base_temp = galaxy_temperature
	temp_bias = star_rng.randf_range(1000, 20000)
	#print("temp_bias = ", temp_bias, " base_temp = ", base_temp)
	var temperature = (base_temp + temp_bias) / 2
	#print("temperature = ", temperature)
	temperature = clamp(temperature, 1000, 20000)
	
	var star_size = star_rng.randf_range(0.5, 2.0)
	var star_color = temperature_to_color(temperature)

	var star_data = {
		"seed": star_seed,
		"size": star_size,
		"color": star_color,
		"temperature": temperature
	}
	#print("global state star data = ", star_data)
	#print("star_data = ", star_data,  "star_seed = " , star_seed)
	all_star_data[star_seed] = star_data
	current_star_data = star_data

	return star_data

func temperature_to_color(temperature: float) -> Color:
	# This is a simplified version. You can make it more accurate.
	if temperature < 3500:
		return Color(1.0, 0.5, 0.0)  # Red
	elif temperature < 5000:
		return Color(1.0, 0.8, 0.0)  # Orange
	elif temperature < 6000:
		return Color(1.0, 1.0, 1.0)  # White
	elif temperature < 10000:
		return Color(0.8, 0.8, 1.0)  # Light Blue
	else:
		return Color(0.6, 0.6, 1.0)  # Blue

func store_star_data(star_data: Dictionary):
	#print("you are in store star data in global state and here is star_data = ", star_data)
	current_star_data = {
		"seed": star_data.get("seed"),
		"brightness": star_data.get("brightness"), #"brightness": target_star.get_star_brightness()
		"color": star_data.get("color"),
		"temperature": star_data.get("temperature"),
		"position": star_data.get("position"),
		"scale": star_data.get("scale")
	}
	#print("Stored star data: ", current_star_data, "star_data = ", star_data)

func get_visible_galaxies() -> Array:
	return visible_galaxies

func store_planet_data(planet_data: Dictionary):
	print(" ")
	print("Global State planet_data = ", planet_data)
	current_planet_data = {
		"seed": planet_data.seed,
		"type": planet_data.type,
		"radius": planet_data.radius,
		"mass": planet_data.mass,
		"orbit_radius": planet_data.orbit_radius,
		"orbit_speed": planet_data.orbit_speed,
		"moons": planet_data.moons,
		"habitable": planet_data.habitable,
		"water": planet_data.water,
		"basic_resource": planet_data.basic_resources,
		"rare_resources": planet_data.rare_resources,
		"planet_tilt": planet_data.planet_tilt,
		"planet_spin_speed": planet_data.planet_spin_speed
	}
	print(" and we are done here")
func get_current_planet_data() -> Array:
	return current_planet_data

func store_skybox_texture(texture: Texture2D):
	skybox_texture = texture
	#print("Skybox texture stored in GlobalState")
	if skybox_texture:
		print("Texture size: ", skybox_texture.get_size())
	else:
		print("Stored texture is null")

func get_skybox_texture() -> Texture2D:
	if skybox_texture:
		print("Returning skybox texture from GlobalState. Size: ", skybox_texture.get_size())
	else:
		print("No skybox texture found in GlobalState")
	return skybox_texture

func store_offset_skybox_texture(texture: Texture2D):
	skybox_galaxy_texture = texture
	#print("Skybox texture stored in GlobalState")
	if skybox_galaxy_texture:
		print("Texture size: ", skybox_galaxy_texture.get_size())
	else:
		print("Stored texture is null")

func get_offset_skybox_texture() -> Texture2D:
	if skybox_galaxy_texture:
		print("Returning skybox texture from GlobalState. Size: ", skybox_galaxy_texture.get_size())
	else:
		print("No skybox texture found in GlobalState")
	return skybox_galaxy_texture

#skybox_galaxy_celestialbody_texture

func store_celestialbody_skybox_texture(texture: Texture2D):
	skybox_galaxy_celestialbody_texture = texture
	#print("Skybox texture stored in GlobalState")
	if skybox_galaxy_celestialbody_texture:
		print("Texture size: ", skybox_galaxy_celestialbody_texture.get_size())
	else:
		print("Stored texture is null")

func get_celestialbody_skybox_texture() -> Texture2D:
	if skybox_galaxy_celestialbody_texture:
		print("Returning skybox texture from GlobalState. Size: ", skybox_galaxy_celestialbody_texture.get_size())
	else:
		print("No skybox texture found in GlobalState")
	return skybox_galaxy_celestialbody_texture


#store_star_skybox_texture
func store_star_skybox_texture(texture: Texture2D):
	star_skybox_texture = texture

func get_star_skybox_texture() -> Texture2D:
	return star_skybox_texture


func store_star_offest_skybox_texture(texture: Texture2D):
	star_skybox_celestialbody_texture = texture

func get_star_offest_skybox_texture() -> Texture2D:
	return star_skybox_celestialbody_texture


func store_return_data(camera_data: Dictionary, galaxy_data: Dictionary):
	is_returning_from_galaxy = true
	return_camera_data = camera_data
	return_galaxy_data = galaxy_data

func clear_return_data():
	is_returning_from_galaxy = false
	return_camera_data = null

func get_star_data() -> Dictionary:
	return current_star_data

func clear_star_data():
	current_star_data = null

func store_galaxy_to_star_camera_data(data):
	galaxy_to_star_camera_data = data
	#print("Stored galaxy to star camera data: ", galaxy_to_star_camera_data)

func get_galaxy_to_star_camera_data():
	return galaxy_to_star_camera_data

func store_star_to_galaxy_camera_data(data):
	star_to_galaxy_camera_data = data
	#print("Stored star to galaxy camera data: ", star_to_galaxy_camera_data)

func get_star_to_galaxy_camera_data():
	return star_to_galaxy_camera_data

func store_return_from_star_data(camera_data: Dictionary):
	is_returning_from_star = true
	star_to_galaxy_camera_data = camera_data
	#print("global state camera_data = ", camera_data)
	#print("global state star_to_galaxy_camera_data.position = ", star_to_galaxy_camera_data.position)
	#print("global state camera data ,previous_star_coordinates", camera_data.previous_star_coordinates)
	return_star_coordinates = camera_data.previous_star_coordinates
	var someting_test = camera_data.previous_star_coordinates + star_to_galaxy_camera_data.position
	star_to_galaxy_camera_data.position = someting_test
	#print("so maybe what we need? someting_test = ", someting_test)
	#print("star_to_galaxy_camera_data.position = ", star_to_galaxy_camera_data.position)
	#print("Stored return from star data")

func get_return_from_star_data():
	return star_to_galaxy_camera_data


func store_star_to_planet_camera_data(data):
	star_to_planet_camera_data = data
	#star_to_planet_camera_data
	
func get_star_to_planet_camera_data():
	return star_to_planet_camera_data

func clear_return_from_star_data():
	is_returning_from_star = false
	star_to_galaxy_camera_data = null

func starting_zone():
	var helping_hand
	#print("global_state thingy maybe?")
	return is_returning_from_galaxy


# storing planets
func store_planet_system(planet_data):
	print("store_planet_system in Global state = ", planet_data)
	print("thats done")
	print(" ")
	current_planet_system = planet_data
	
func get_planet_system():
	return current_planet_system
