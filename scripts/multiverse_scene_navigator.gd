extends Node3D
class_name MultiverseSceneNavigator

# Connected to: All scene files in Universal Being project
# Uses: beings/plasmoid_universal_being.gd (flying navigation)
# Required by: Multiverse ball navigation system

## Multiverse Scene Navigator - Fly into glowing balls to enter any scene
## Each scene becomes a cosmic orb floating in 3D space

var scene_orbs: Array[MultiverseOrb] = []
var scene_paths: Array[String] = []
var current_scene_index: int = -1
var orb_material: StandardMaterial3D
var navigation_camera: Camera3D

# Multiverse layout
var orbs_per_ring: int = 8
var ring_radius: float = 15.0
var ring_spacing: float = 8.0
var orb_scale: float = 2.0

signal scene_entered(scene_path: String)
signal multiverse_loaded(orb_count: int)

class MultiverseOrb extends RigidBody3D:
	var scene_path: String = ""
	var scene_name: String = ""
	var orb_mesh: MeshInstance3D
	var label: Label3D
	var particles: GPUParticles3D
	var consciousness_level: float = 0.0
	
	signal orb_entered(scene_path: String)
	
	func setup_orb(path: String, position: Vector3, consciousness: float):
		scene_path = path
		scene_name = path.get_file().get_basename()
		consciousness_level = consciousness
		global_position = position
		
		create_orb_visuals()
		create_scene_label()
		create_particle_effects()
		setup_collision_detection()
	
	func create_orb_visuals():
		orb_mesh = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 2.0
		sphere.height = 4.0
		
		var material = StandardMaterial3D.new()
		material.albedo_color = get_scene_color()
		material.emission_enabled = true
		material.emission = material.albedo_color * 0.8
		material.flags_transparent = true
		material.albedo_color.a = 0.7
		
		orb_mesh.mesh = sphere
		orb_mesh.material_override = material
		add_child(orb_mesh)
	
	func create_scene_label():
		label = Label3D.new()
		label.text = scene_name.replace("_", " ").to_upper()
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.position = Vector3(0, 3, 0)
		label.font_size = 24
		label.modulate = get_scene_color()
		add_child(label)
	
	func create_particle_effects():
		particles = GPUParticles3D.new()
		var material = ParticleProcessMaterial.new()
		material.direction = Vector3(0, 1, 0)
		material.initial_velocity_min = 1.0
		material.initial_velocity_max = 3.0
		material.gravity = Vector3(0, -1, 0)
		material.color = get_scene_color()
		
		particles.process_material = material
		particles.amount = int(consciousness_level * 20 + 10)
		particles.lifetime = 3.0
		particles.emitting = true
		add_child(particles)
	
	func get_scene_color() -> Color:
		# Color based on scene type
		if "PERFECT" in scene_name:
			return Color.GOLD
		elif "SPACE" in scene_name:
			return Color.CYAN
		elif "NOTEPAD" in scene_name:
			return Color.GREEN
		elif "VR" in scene_name:
			return Color.MAGENTA
		elif "DIVINE" in scene_name:
			return Color.WHITE
		elif "COSMIC" in scene_name:
			return Color.PURPLE
		else:
			return Color(randf(), randf(), randf())
	
	func setup_collision_detection():
		var collision = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = 3.0  # Slightly larger for easy entry
		collision.shape = sphere_shape
		add_child(collision)
		
		# Connect body entered signal
		body_entered.connect(_on_body_entered)
	
	func _on_body_entered(body):
		if body.has_method("get") and body.get("being_type") == "player":
			print("🌌 Entering scene: %s" % scene_name)
			orb_entered.emit(scene_path)

func _ready():
	print("🌌 Multiverse Scene Navigator: Initializing cosmic scene selection...")
	setup_orb_material()
	scan_available_scenes()
	create_multiverse_layout()

func setup_orb_material():
	"""Create base material for scene orbs"""
	orb_material = StandardMaterial3D.new()
	orb_material.emission_enabled = true
	orb_material.flags_transparent = true

func scan_available_scenes():
	"""Scan project for all .tscn scene files"""
	scene_paths.clear()
	
	# Scan scenes directory
	var scenes_dir = DirAccess.open("res://scenes/")
	if scenes_dir:
		scan_directory_recursive(scenes_dir, "res://scenes/", scene_paths)
	
	# Add main scene
	scene_paths.append("res://main.tscn")
	
	print("🌌 Found %d scenes for multiverse navigation" % scene_paths.size())

func scan_directory_recursive(dir: DirAccess, path: String, found_scenes: Array):
	"""Recursively scan for .tscn files"""
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			var sub_dir = DirAccess.open(full_path)
			if sub_dir:
				scan_directory_recursive(sub_dir, full_path + "/", found_scenes)
		elif file_name.ends_with(".tscn"):
			found_scenes.append(full_path)
		
		file_name = dir.get_next()

func create_multiverse_layout():
	"""Create 3D layout of scene orbs in cosmic formation"""
	var total_scenes = scene_paths.size()
	var rings_needed = (total_scenes / orbs_per_ring) + 1
	
	for i in range(total_scenes):
		var ring_index = i / orbs_per_ring
		var orb_index = i % orbs_per_ring
		
		# Calculate position in ring
		var angle = (orb_index * TAU) / orbs_per_ring
		var radius = ring_radius + (ring_index * 2.0)  # Expand outer rings
		var height = ring_index * ring_spacing
		
		var position = Vector3(
			cos(angle) * radius,
			height,
			sin(angle) * radius
		)
		
		create_scene_orb(scene_paths[i], position, i)
	
	multiverse_loaded.emit(scene_orbs.size())
	print("🌌 Multiverse created: %d scene orbs in %d rings" % [scene_orbs.size(), rings_needed])

func create_scene_orb(scene_path: String, position: Vector3, index: int):
	"""Create a glowing orb for a scene"""
	var orb = MultiverseOrb.new()
	
	# Calculate consciousness level based on scene importance
	var consciousness = calculate_scene_consciousness(scene_path)
	
	orb.setup_orb(scene_path, position, consciousness)
	orb.orb_entered.connect(_on_orb_entered)
	
	add_child(orb)
	scene_orbs.append(orb)

func calculate_scene_consciousness(scene_path: String) -> float:
	"""Calculate consciousness level for scene coloring"""
	var path = scene_path.to_upper()
	
	if "PERFECT" in path or "ULTIMATE" in path:
		return 5.0  # Transcendent
	elif "DIVINE" in path or "COSMIC" in path:
		return 4.0  # Enlightened
	elif "COMPLETE" in path or "GAME" in path:
		return 3.0  # Conscious
	elif "SIMPLE" in path or "TEST" in path:
		return 2.0  # Aware
	else:
		return 1.0  # Awakening

func _on_orb_entered(scene_path: String):
	"""Handle player entering a scene orb"""
	print("🌌 Transitioning to scene: %s" % scene_path)
	scene_entered.emit(scene_path)
	
	# Smooth scene transition
	transition_to_scene(scene_path)

func transition_to_scene(scene_path: String):
	"""Smoothly transition to the selected scene"""
	# Create transition effect
	create_transition_effect()
	
	# Wait for effect, then change scene
	await get_tree().create_timer(1.0).timeout
	
	# Load the new scene
	get_tree().change_scene_to_file(scene_path)

func create_transition_effect():
	"""Create visual transition effect"""
	var effect = ColorRect.new()
	effect.color = Color.WHITE
	effect.modulate.a = 0.0
	
	# Add to UI layer
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().current_scene.add_child(canvas)
	canvas.add_child(effect)
	
	# Fade effect
	var tween = create_tween()
	tween.tween_property(effect, "modulate:a", 1.0, 0.5)
	tween.tween_property(effect, "modulate:a", 0.0, 0.5)

func get_scene_info(scene_path: String) -> Dictionary:
	"""Get information about a scene"""
	return {
		"path": scene_path,
		"name": scene_path.get_file().get_basename(),
		"consciousness_level": calculate_scene_consciousness(scene_path),
		"category": get_scene_category(scene_path)
	}

func get_scene_category(scene_path: String) -> String:
	"""Categorize scene by type"""
	var path = scene_path.to_upper()
	
	if "SPACE" in path:
		return "space_exploration"
	elif "NOTEPAD" in path:
		return "3d_programming"
	elif "VR" in path:
		return "vr_experience"
	elif "CONSOLE" in path:
		return "consciousness_interface"
	elif "TEST" in path:
		return "testing_ground"
	else:
		return "universal_experience"

func fly_to_orb(orb_index: int):
	"""Fly camera to specific orb for close inspection"""
	if orb_index >= 0 and orb_index < scene_orbs.size():
		var target_orb = scene_orbs[orb_index]
		var camera = get_viewport().get_camera_3d()
		
		if camera:
			var tween = create_tween()
			var target_pos = target_orb.global_position + Vector3(0, 2, 8)
			tween.tween_property(camera, "global_position", target_pos, 2.0)

func _input(event):
	"""Navigation controls"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_M:
				print("🌌 Multiverse Navigator: %d scenes available" % scene_orbs.size())
				list_available_scenes()
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
				var index = event.keycode - KEY_1
				fly_to_orb(index)

func list_available_scenes():
	"""List all available scenes with their categories"""
	print("🌌 Available Multiverse Scenes:")
	for i in range(min(scene_paths.size(), 20)):  # Show first 20
		var info = get_scene_info(scene_paths[i])
		print("  %d. %s (%s)" % [i + 1, info.name, info.category])