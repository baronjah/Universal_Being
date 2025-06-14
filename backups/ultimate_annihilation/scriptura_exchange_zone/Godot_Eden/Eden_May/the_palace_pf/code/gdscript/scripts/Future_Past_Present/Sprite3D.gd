# CelestialBody.gd res://Scripts/CelestialBody.gd
@tool
extends Sprite3D

var shader_material: ShaderMaterial
var star_id: int
var star_seed: int
var star_temperature: float
var star_brightness: float
var material
var camera: Camera3D

var position_basis: Basis

func _ready():
	setup_ColorTest()
	camera = get_viewport().get_camera_3d()

func _process(delta):
	
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
	var information3 = 0.5 + information2#(0.5 - information2)
	var information4 = 2 + (2.0 * oscillation2)
	shader_material.set_shader_parameter("time", Time.get_ticks_msec() / 10000.0)
	shader_material.set_shader_parameter("offset_one", information2)
	shader_material.set_shader_parameter("offset_two", information3)
	shader_material.set_shader_parameter("offset_three", information4)
	shader_material.set_shader_parameter("time_int", time3)


func setup_ColorTest():

	var image = Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))
	var star_texture = ImageTexture.create_from_image(image)
	self.texture = star_texture

	var shader = load("res://ColorTest.gdshader")
	if shader == null:
		print("Error: Could not load CelestialBody.gdshader file")
		return

	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	material_override = shader_material

	star_id = get_instance_id()
