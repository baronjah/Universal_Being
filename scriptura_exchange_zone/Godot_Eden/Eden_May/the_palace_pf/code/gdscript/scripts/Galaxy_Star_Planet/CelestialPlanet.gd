#OrbitStabilizer a CelestialPlanet.gd

extends Node3D

var planet_sprite: Sprite3D

var star_position_basis: Basis# = Basis.IDENTITY
var planet_data_system

func _ready():
	planet_sprite = get_node("CelestialPlanetSprite")
	if not planet_sprite:
		print("Error: CelestialPlanetSprite not found!")

func _process(delta):
	global_transform.basis = star_position_basis
	
func set_planet_data(data: Dictionary):
	planet_data_system = data
	#print("we tried")
	#print("planet data, send to scene CelestialPlanet data = ", data)
	planet_sprite.set_parameters(data.seed, data.type, data.radius, data.orbit_radius, data.planet_tilt, data.planet_spin_speed, planet_data_system)
	#set_parameters()
	
func get_planet_data_records():
	return planet_data_system
