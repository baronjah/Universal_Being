#Orbit.gd in Orbit.tscn, #res://Scenes/Orbit.tscn
extends Node3D

var orbit_speed #float = 1.0
var orbit_radius #float = 10.0

func set_orbit_data(speed: float, radius: float):
	#print("speed = ", speed, " radius = ", radius)
	orbit_speed = speed
	orbit_radius = radius

func _process(delta):
	rotate_y(orbit_speed * delta)
	
func Alpha_delta():
	var delta_Alpha = GlobalState.elapsed_time_seconds
	rotate_y(orbit_speed * delta_Alpha)
