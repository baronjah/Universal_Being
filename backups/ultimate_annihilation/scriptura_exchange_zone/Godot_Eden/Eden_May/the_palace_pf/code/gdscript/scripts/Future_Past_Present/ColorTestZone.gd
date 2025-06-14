
extends Node3D

# The reference to the Sprite3D node
@onready var sprite3d = $Sprite3D

# The duration of the complete color cycle in seconds
var cycle_duration = 10.0

# The internal timer to track the elapsed time
var time_passed = 0.0

func _ready():
	# Ensure the Sprite3D node has a material with the shader
	if sprite3d.material == null:
		var shader = Shader.new()
		shader.code = preload("res://ColorTest.gdshader")
		var material = ShaderMaterial.new()
		material.shader = shader
		sprite3d.material = material

func _process(delta):
	# Update the elapsed time
	time_passed += delta
	
	var time = (Time.get_ticks_msec() / 1000.0) * 0.98
	var time2 = (Time.get_ticks_msec() / 10000.0) * 0.96
	var time3 = Time.get_ticks_msec()
	var timer_reset = int(time)
	var timer_reset2 = int(time2)
	var timer_new = time - timer_reset
	var timer_new2 = time2 - timer_reset2
	var information =  0.5 * timer_new
	var oscillation = abs(1 - (timer_new * 2))
	var oscillation2 = abs(1 - (timer_new2 * 2))
	var information2 = 0.5 * oscillation
	var information3 = 0.5 + information2
	var information4 = 2 + (2.0 * oscillation2)
	print(timer_new)
	print("hello")

	# Calculate the time value for the shader (normalized between 0 and 1)
	#var shader_time = (time_passed % cycle_duration) / cycle_duration

	# Set the shader parameter
	sprite3d.material.set_shader_param("time", timer_new)
