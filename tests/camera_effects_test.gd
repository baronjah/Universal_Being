# ==================================================
# UNIVERSAL BEING: CameraEffectsTest
# TYPE: Test
# PURPOSE: Test camera effects system with different consciousness levels
# ==================================================

extends UniversalBeing
class_name CameraEffectsTest

const SimpleCameraEffects = preload("res://components/simple_camera_effects.gd")

# ===== TEST PROPERTIES =====
@export var auto_evolve: bool = false
@export var evolution_interval: float = 3.0

# ===== INTERNAL STATE =====
var _camera_effects: SimpleCameraEffects
var _current_level: int = 0
var _evolution_timer: float = 0.0
var _test_scene: Node

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	# Set up test being identity
	being_type = "test"
	being_name = "CameraEffectsTest"
	consciousness_level = 0
	
	print("🌟 CameraEffectsTest: Pentagon Init Complete")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Create test scene with some bright objects
	_create_test_scene()
	
	# Initialize camera effects
	_camera_effects = SimpleCameraEffects.new()
	add_child(_camera_effects)
	_camera_effects.initialize(self)
	
	print("🌟 CameraEffectsTest: Pentagon Ready Complete")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	if auto_evolve:
		_evolution_timer += delta
		if _evolution_timer >= evolution_interval:
			_evolution_timer = 0.0
			_evolve_to_next_level()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Test different consciousness levels with number keys
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _set_consciousness_level(1)  # Vignette
			KEY_2: _set_consciousness_level(2)  # Depth of Field (not implemented yet)
			KEY_3: _set_consciousness_level(3)  # Bloom
			KEY_4: _set_consciousness_level(4)  # Chromatic Aberration
			KEY_5: _set_consciousness_level(5)  # Reality Distortion (not implemented yet)
			KEY_6: _set_consciousness_level(6)  # Quantum Vision (not implemented yet)
			KEY_7: _set_consciousness_level(7)  # All Effects
			KEY_0: _set_consciousness_level(0)  # No Effects
			KEY_ENTER: 
				auto_evolve = !auto_evolve
				print("Auto-evolution %s" % ("enabled" if auto_evolve else "disabled"))

func pentagon_sewers() -> void:
	if _test_scene:
		_test_scene.queue_free()
	if _camera_effects:
		_camera_effects.queue_free()
	
	super.pentagon_sewers()
	print("🌟 CameraEffectsTest: Pentagon Sewers Complete")

# ===== TEST IMPLEMENTATION =====

func _create_test_scene() -> void:
	"""Create a test scene with various objects to test effects"""
	_test_scene = Node3D.new()
	add_child(_test_scene)
	
	# Add a bright sphere
	var sphere = CSGSphere3D.new()
	sphere.radius = 1.0
	sphere.position = Vector3(0, 0, -5)
	sphere.material = StandardMaterial3D.new()
	sphere.material.emission_enabled = true
	sphere.material.emission = Color(1, 1, 0.5)
	sphere.material.emission_energy_multiplier = 2.0
	_test_scene.add_child(sphere)
	
	# Add some colored cubes
	var colors = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW]
	for i in range(4):
		var cube = CSGBox3D.new()
		cube.size = Vector3(0.5, 0.5, 0.5)
		cube.position = Vector3(2 * sin(i * PI/2), 2 * cos(i * PI/2), -4)
		cube.material = StandardMaterial3D.new()
		cube.material.albedo_color = colors[i]
		_test_scene.add_child(cube)
	
	# Add a camera
	var camera = Camera3D.new()
	camera.position = Vector3(0, 0, 0)
	camera.look_at(Vector3(0, 0, -5))
	_test_scene.add_child(camera)
	get_viewport().current_camera = camera

func _set_consciousness_level(level: int) -> void:
	"""Set consciousness level and notify effects system"""
	_current_level = level
	consciousness_level = level
	print("Setting consciousness level to %d" % level)
	
	# Emit signal for effects system
	if has_signal("consciousness_changed"):
		emit_signal("consciousness_changed", _current_level, level)

func _evolve_to_next_level() -> void:
	"""Automatically evolve to next consciousness level"""
	var next_level = (_current_level + 1) % 8
	_set_consciousness_level(next_level)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	"""Enhanced AI interface for test being"""
	var base_interface = super.ai_interface()
	base_interface.custom_commands = [
		"set_consciousness_level",
		"toggle_auto_evolve",
		"get_current_level"
	]
	base_interface.custom_properties = {
		"current_level": _current_level,
		"auto_evolve": auto_evolve,
		"evolution_interval": evolution_interval
	}
	return base_interface 
