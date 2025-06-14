@tool
extends Node3D

# Speed of the planet's rotation
var spin_speed: float = 4.0


func _process(delta):
	self.rotate_y(-spin_speed * delta)
