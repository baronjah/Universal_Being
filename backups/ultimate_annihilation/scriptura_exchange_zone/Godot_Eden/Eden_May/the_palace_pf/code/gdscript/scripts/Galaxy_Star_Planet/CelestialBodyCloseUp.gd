# CelestialBodyCloseUp.gd in CelestialBodyCloseUp.tscn
extends Node3D
var planet_sprite: Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	planet_sprite = get_node("CelestialBody")
	if not planet_sprite:
		print("Error: CelestialPlanetSprite not found!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup_planet():
	pass
	# so right now lets just make it create the same sprite like it used to do previously? but we wont be tilting the planet?

func setup_planet_data(data: Dictionary):
	# okay so somehow, we need to get that data to our sprite :) we will need to store it somewhere
	#print("we tried")
	#print("planet data, send to scene CelestialPlanet data = ", data)
	planet_sprite.set_parameters(data.seed, data.type, data.radius, data.orbit_radius, data.planet_tilt, data.planet_spin_speed)

func setup_star():
	pass
	# create instance of some 3d node, which will be holding everything, star and other planets, and also will be orbiting around the planet we are on
	# tilt that Sky_canvas in different way than it was previously! when planet was orbiting a sun at 23.5 degrees, now it will be tilting a star at -23.5 lol the world in reverse
	# the star shall be as far away from planet, as planet was far away from star! in previous scene
	# on that star we will put all the planets from previous scene, but not the one we are on!
	
	
func setup_planets():
	pass
	
func return_to_Star_scene():
	pass 
	# we will be needing similar functions, like in previous scene! here we will be able to travel to the moons, if there are any on that planet :) also we will be able to travel back to that
	# hmmm, im not sure how we will be placing moon? i think also at tilt? just like the sun? but moons here will be orbiting a planet? and a star will also orbit a planet?
	
func apply_skybox():
	pass
	# we will be using GlobalState.get_star_offest_skybox_texture()
