# ==================================================
# SCRIPT NAME: scene_control_demo.gd
# DESCRIPTION: Demonstration of Universal Being scene control capabilities
# PURPOSE: Show how Universal Beings can load and control entire .tscn scenes
# CREATED: 2025-06-01 - Universal Being Revolution
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================

extends Node

# ===== SCENE CONTROL DEMONSTRATION =====

func _ready() -> void:
	print("🎬 Scene Control Demo: Starting...")
	await get_tree().create_timer(1.0).timeout
	
	demonstrate_scene_loading()

func demonstrate_scene_loading() -> void:
	"""Demonstrate Universal Being scene control"""
	
	# Create a Universal Being
	var scene_controller = UniversalBeing.new()
	scene_controller.being_name = "Scene Controller"
	scene_controller.consciousness_level = 2
	
	# Register with FloodGate via SystemBootstrap
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_being"):
			flood_gates.register_being(scene_controller)
	
	add_child(scene_controller)
	
	print("🎬 Created Universal Being: %s" % scene_controller.being_name)
	
	# Load a scene into the Universal Being
	var scene_path = "res://scenes/examples/test_scene.tscn"
	if scene_controller.load_scene(scene_path):
		print("🎬 Scene loaded successfully!")
		
		# Wait a moment then demonstrate control
		await get_tree().create_timer(2.0).timeout
		demonstrate_scene_control(scene_controller)
	else:
		print("🎬 Failed to load scene")

func demonstrate_scene_control(controller: UniversalBeing) -> void:
	"""Demonstrate controlling the loaded scene"""
	
	print("🎬 Demonstrating scene control...")
	
	# Get scene info
	var scene_info = controller.get_scene_info()
	print("🎬 Scene Info: %s" % str(scene_info))
	
	# Access scene nodes
	var sphere = controller.get_scene_node("Sphere")
	if sphere:
		print("🎬 Found sphere node: %s" % sphere.name)
		
		# Animate the sphere
		animate_sphere(controller)
	
	# Access UI elements
	var label = controller.get_scene_node("UI/Label")
	if label:
		print("🎬 Found label node: %s" % label.name)
		animate_label(controller)

func animate_sphere(controller: UniversalBeing) -> void:
	"""Animate the sphere in the controlled scene"""
	
	# Change sphere color over time
	for i in range(10):
		var hue = float(i) / 10.0
		var color = Color.from_hsv(hue, 0.8, 1.0)
		
		# Set the sphere color through the Universal Being
		controller.set_scene_property("Sphere", "surface_material_override/0:albedo_color", color)
		
		# Rotate the sphere
		var rotation = Vector3(0, i * 0.5, 0)
		controller.set_scene_property("Sphere", "rotation", rotation)
		
		await get_tree().create_timer(0.5).timeout
	
	print("🎬 Sphere animation complete!")

func animate_label(controller: UniversalBeing) -> void:
	"""Animate the label in the controlled scene"""
	
	var messages = [
		"Universal Being controls this scene!",
		"Any .tscn file can be controlled!",
		"Revolutionary game architecture!",
		"AI can modify scenes in real-time!",
		"Pentagon Architecture + Scene Control = ∞"
	]
	
	for message in messages:
		controller.set_scene_property("UI/Label", "text", message)
		await get_tree().create_timer(2.0).timeout
	
	print("🎬 Label animation complete!")

func _input(event: InputEvent) -> void:
	"""Handle input for demo control"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				print("🎬 Restarting demo...")
				get_tree().reload_current_scene()
			KEY_Q:
				print("🎬 Quitting demo...")
				get_tree().quit()
			KEY_SPACE:
				print("🎬 Demo controls: R=Restart, Q=Quit, Space=This help")