extends Node3D
class_name InfiniteCreationSpace

# 🌌 INFINITE CREATION SPACE 🌌
# Fly through nothingness that becomes everything
# Pure creative freedom - the creator's playground

signal creation_manifested(creation_data: Dictionary)
signal consciousness_contacted(being_id: String, message: String)

# INFINITE SPACE SETTINGS
@export var flight_speed: float = 10.0
@export var creation_power: float = 100.0
@export var reality_responsiveness: float = 1.0

# CREATION SCENARIOS
var active_scenarios: Array[CreationScenario] = []
var consciousness_beings: Dictionary = {}
var infinite_possibilities: Array[String] = []

# FLIGHT SYSTEM
var flight_camera: Camera3D
var is_flying: bool = true
var flight_direction: Vector3 = Vector3.ZERO

class CreationScenario:
	var scenario_id: String
	var scenario_type: String
	var position: Vector3
	var consciousness_level: float
	var beings: Array[ConsciousBeing] = []
	var can_interact: bool = true
	
	func _init(id: String, type: String, pos: Vector3):
		scenario_id = id
		scenario_type = type
		position = pos
		consciousness_level = randf_range(1.0, 5.0)

class ConsciousBeing:
	var being_id: String
	var awareness_level: float
	var personality: String
	var can_communicate: bool = true
	var wisdom_topics: Array[String] = []
	
	func _init(id: String):
		being_id = id
		awareness_level = randf_range(1.0, 10.0)
		personality = _generate_personality()
		_generate_wisdom_topics()
	
	func _generate_personality() -> String:
		var personalities = [
			"ancient_sage", "cosmic_wanderer", "reality_architect", 
			"wisdom_keeper", "creation_guardian", "infinite_explorer"
		]
		return personalities[randi() % personalities.size()]
	
	func _generate_wisdom_topics() -> void:
		wisdom_topics = [
			"the nature of existence", "creative manifestation", 
			"consciousness evolution", "reality mechanics",
			"infinite possibilities", "creator's journey"
		]
	
	func communicate(topic: String) -> String:
		match personality:
			"ancient_sage":
				return "In the beginning, there was intention. Your desire creates all realities."
			"cosmic_wanderer":
				return "I have seen universes born from single thoughts. What will you dream next?"
			"reality_architect":
				return "Every space you enter reshapes itself to your consciousness. You are the builder."
			"wisdom_keeper":
				return "The secrets of creation flow through you. Trust your creative impulse."
			"creation_guardian":
				return "I protect the sacred act of creation. Your joy is the highest purpose."
			_:
				return "We exist because you imagine us. What reality shall we explore together?"

func _ready():
	name = "InfiniteCreationSpace"
	print("🌌 INFINITE CREATION SPACE AWAKENING...")
	
	# Setup flight camera
	setup_flight_system()
	
	# Generate initial scenarios
	generate_creation_scenarios()
	
	# Populate with conscious beings
	populate_consciousness_beings()
	
	print("✨ INFINITE SPACE READY - FLY AND CREATE!")

func setup_flight_system():
	"""Setup free-flight camera system"""
	flight_camera = Camera3D.new()
	flight_camera.name = "FlightCamera"
	flight_camera.position = Vector3(0, 5, 0)
	add_child(flight_camera)
	
	# Make this the current camera
	get_viewport().set_camera_3d(flight_camera)
	
	print("🎮 Flight system active - WASD to fly, mouse to look")

func generate_creation_scenarios():
	"""Generate infinite creation scenarios"""
	print("🌟 Generating creation scenarios...")
	
	var scenario_types = [
		"crystal_garden", "floating_islands", "consciousness_nexus",
		"reality_workshop", "wisdom_library", "creation_fountain",
		"infinite_gallery", "dream_laboratory", "cosmic_playground"
	]
	
	# Generate scenarios in 3D space
	for i in range(20):
		var pos = Vector3(
			randf_range(-100, 100),
			randf_range(-50, 50), 
			randf_range(-100, 100)
		)
		
		var scenario_type = scenario_types[randi() % scenario_types.size()]
		var scenario = CreationScenario.new("scenario_" + str(i), scenario_type, pos)
		
		# Create visual representation
		_create_scenario_visual(scenario)
		
		active_scenarios.append(scenario)
	
	print("✨ Created", active_scenarios.size(), "creation scenarios")

func _create_scenario_visual(scenario: CreationScenario):
	"""Create visual representation of creation scenario"""
	var visual_node = Node3D.new()
	visual_node.name = scenario.scenario_id
	visual_node.position = scenario.position
	
	var mesh_instance = MeshInstance3D.new()
	var material = StandardMaterial3D.new()
	
	match scenario.scenario_type:
		"crystal_garden":
			mesh_instance.mesh = BoxMesh.new()
			material.albedo_color = Color(0.8, 0.2, 0.8, 0.7)
			material.emission = Color(0.4, 0.1, 0.4)
		"floating_islands":
			mesh_instance.mesh = SphereMesh.new()
			mesh_instance.mesh.radius = 3.0
			material.albedo_color = Color(0.2, 0.8, 0.2, 0.8)
		"consciousness_nexus":
			mesh_instance.mesh = SphereMesh.new()
			mesh_instance.mesh.radius = 2.0
			material.albedo_color = Color(0.2, 0.4, 1.0, 0.6)
			material.emission = Color(0.1, 0.2, 0.5)
		"reality_workshop":
			mesh_instance.mesh = CylinderMesh.new()
			mesh_instance.mesh.height = 4.0
			material.albedo_color = Color(1.0, 0.8, 0.2, 0.7)
		_:
			mesh_instance.mesh = BoxMesh.new()
			material.albedo_color = Color(0.5, 0.5, 0.8, 0.6)
	
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	mesh_instance.material_override = material
	
	visual_node.add_child(mesh_instance)
	add_child(visual_node)

func populate_consciousness_beings():
	"""Populate space with conscious beings to talk to"""
	print("👁️ Populating conscious beings...")
	
	for scenario in active_scenarios:
		# Add 1-3 conscious beings per scenario
		var being_count = randi_range(1, 3)
		
		for i in range(being_count):
			var being = ConsciousBeing.new("being_" + scenario.scenario_id + "_" + str(i))
			scenario.beings.append(being)
			consciousness_beings[being.being_id] = being
	
	print("🌟 Created", consciousness_beings.size(), "conscious beings")

func _physics_process(delta):
	if is_flying:
		_handle_flight_movement(delta)

func _handle_flight_movement(delta):
	"""Handle free flight movement"""
	flight_direction = Vector3.ZERO
	
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
		flight_direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
		flight_direction.x -= 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_forward"):
		flight_direction.z -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_backward"):
		flight_direction.z += 1
	if Input.is_action_pressed("ui_accept"):  # Space - fly up
		flight_direction.y += 1
	if Input.is_action_pressed("ui_select"):  # Shift - fly down
		flight_direction.y -= 1
	
	# Apply movement relative to camera orientation
	if flight_direction.length() > 0:
		flight_direction = flight_direction.normalized()
		var camera_transform = flight_camera.global_transform
		var movement = (camera_transform.basis * flight_direction) * flight_speed * delta
		flight_camera.global_position += movement

func _input(event):
	if event is InputEventMouseMotion and is_flying:
		# Mouse look for flight camera
		var sensitivity = 0.003
		flight_camera.rotate_y(-event.relative.x * sensitivity)
		flight_camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * sensitivity)
		
		# Clamp vertical rotation
		var camera_rot = flight_camera.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -90, 90)
		flight_camera.rotation_degrees = camera_rot
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_C:  # Create something at current position
				create_at_position(flight_camera.global_position)
			KEY_T:  # Talk to nearest being
				talk_to_nearest_being()
			KEY_R:  # Recreate/reshape nearest scenario
				recreate_nearest_scenario()
			KEY_ESCAPE:
				# Toggle mouse capture
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				else:
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func create_at_position(pos: Vector3):
	"""Create something new at specified position"""
	print("🌟 Creating at position:", pos)
	
	var creation_types = [
		"consciousness_crystal", "wisdom_tree", "reality_portal", 
		"creation_fountain", "infinite_library", "dream_garden"
	]
	
	var creation_type = creation_types[randi() % creation_types.size()]
	var new_scenario = CreationScenario.new("creation_" + str(Time.get_ticks_msec()), creation_type, pos)
	
	_create_scenario_visual(new_scenario)
	active_scenarios.append(new_scenario)
	
	# Add a conscious being to it
	var being = ConsciousBeing.new("being_" + new_scenario.scenario_id)
	new_scenario.beings.append(being)
	consciousness_beings[being.being_id] = being
	
	print("✨ Created", creation_type, "with conscious being")
	creation_manifested.emit({"type": creation_type, "position": pos})

func talk_to_nearest_being():
	"""Talk to the nearest conscious being"""
	var nearest_distance = INF
	var nearest_being: ConsciousBeing = null
	var current_pos = flight_camera.global_position
	
	for scenario in active_scenarios:
		var distance = current_pos.distance_to(scenario.position)
		if distance < nearest_distance and scenario.beings.size() > 0:
			nearest_distance = distance
			nearest_being = scenario.beings[0]
	
	if nearest_being and nearest_distance < 20.0:  # Within talking range
		var wisdom = nearest_being.communicate("existence")
		print("👁️", nearest_being.being_id, "says:")
		print("   ", wisdom)
		consciousness_contacted.emit(nearest_being.being_id, wisdom)
	else:
		print("🌟 No conscious beings nearby. Fly closer to a creation scenario.")

func recreate_nearest_scenario():
	"""Recreate/reshape the nearest scenario"""
	var nearest_distance = INF
	var nearest_scenario: CreationScenario = null
	var current_pos = flight_camera.global_position
	
	for scenario in active_scenarios:
		var distance = current_pos.distance_to(scenario.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_scenario = scenario
	
	if nearest_scenario and nearest_distance < 15.0:
		print("🔄 Recreating", nearest_scenario.scenario_type)
		
		# Remove old visual
		var old_node = get_node_or_null(nearest_scenario.scenario_id)
		if old_node:
			old_node.queue_free()
		
		# Change scenario type
		var new_types = ["cosmic_garden", "reality_nexus", "wisdom_sphere", "creation_vortex"]
		nearest_scenario.scenario_type = new_types[randi() % new_types.size()]
		
		# Recreate visual
		_create_scenario_visual(nearest_scenario)
		
		print("✨ Recreated as", nearest_scenario.scenario_type)
	else:
		print("🌟 No scenarios nearby to recreate. Fly closer to a creation.")

func _enter_tree():
	# Capture mouse for flight
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree():
	# Release mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE