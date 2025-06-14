#Orbit.gd in new test scene
@tool
extends Node3D

var orbit_speed: float = 0.5
var orbit_radius: float = 10.0

func set_orbit_data(speed: float, radius: float):
	orbit_speed = speed
	orbit_radius = radius

func _process(delta):
	orbit_speed = 0.000009
	rotate_y(orbit_speed * delta)
	#print("orbit_speed * delta = ", orbit_speed * delta)
