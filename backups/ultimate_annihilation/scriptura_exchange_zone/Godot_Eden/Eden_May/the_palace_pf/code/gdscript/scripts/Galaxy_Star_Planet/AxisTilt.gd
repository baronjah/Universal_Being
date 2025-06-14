#AxisTilt
@tool
extends Node3D

var tilt_angle: float = 23.5

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation_degrees.x = tilt_angle

