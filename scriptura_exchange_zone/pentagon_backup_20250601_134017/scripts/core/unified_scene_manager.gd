# ==================================================
# SCRIPT NAME: unified_scene_manager.gd
# DESCRIPTION: Manages static scenes and procedural generation
# PURPOSE: Unify scene loading and world generation
# CREATED: 2025-05-24 - Scene management overhaul
# ==================================================

extends UniversalBeingBase
signal scene_changed(scene_name: String)
signal world_cleared

# ================================
# SCENE STATE
# ================================

enum SceneType {
	STATIC,      # Pre-made scenes
	PROCEDURAL,  # Generated worlds
	HYBRID       # Both combined
}

var current_scene_type: SceneType = SceneType.STATIC
var current_scene_name: String = "default"
var original_ground: Node3D = null
var procedural_world: Node3D = null
var static_scene: Node3D = null
var scene_root: Node3D = null

# Scene containers
var terrain_container: Node3D
var objects_container: Node3D
var creatures_container: Node3D

# ================================
# INITIALIZATION
# ================================

func _ready() -> void:
	# Create scene root
	scene_root = Node3D.new()
	scene_root.name = "SceneRoot"
	get_tree().FloodgateController.universal_add_child(scene_root, root)
	
	# Create containers
	_create_containers()
	
	# Store reference to original ground
	_find_original_ground()

func _create_containers() -> void:
	terrain_container = Node3D.new()
	terrain_container.name = "TerrainContainer"
	FloodgateController.universal_add_child(terrain_container, scene_root)
	
	objects_container = Node3D.new()
	objects_container.name = "ObjectsContainer"
	FloodgateController.universal_add_child(objects_container, scene_root)
	
	creatures_container = Node3D.new()
	creatures_container.name = "CreaturesContainer"
	FloodgateController.universal_add_child(creatures_container, scene_root)

func _find_original_ground() -> void:
	# Find the default ground plane
	var main_scene = get_tree().current_scene
	if main_scene:
		original_ground = main_scene.get_node_or_null("Ground")
		if not original_ground:
			# Search for any ground-like object
			for child in main_scene.get_children():
				if child.name.to_lower().contains("ground") or child.name.to_lower().contains("plane"):
					original_ground = child
					break

# ================================
# SCENE MANAGEMENT
# ================================


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func clear_current_scene() -> void:
	print("[SceneManager] Clearing current scene...")
	
	# Clear procedural world
	if procedural_world and is_instance_valid(procedural_world):
		procedural_world.queue_free()
		procedural_world = null
	
	# Clear static scene
	if static_scene and is_instance_valid(static_scene):
		static_scene.queue_free()
		static_scene = null
	
	# Clear containers
	for child in terrain_container.get_children():
		child.queue_free()
	for child in objects_container.get_children():
		child.queue_free()
	
	# Don't clear creatures - let them persist
	
	# Restore ground visibility when clearing scenes
	_ensure_ground_visible()
	
	world_cleared.emit()

func load_static_scene(scene_name: String) -> void:
	print("[SceneManager] Loading static scene: " + scene_name)
	
	# Clear existing scene first
	clear_current_scene()
	
	# Handle ground visibility for static scenes
	if original_ground:
		# Only hide ground if the scene provides its own terrain
		# For now, let's keep the ground visible unless explicitly requested
		print("[SceneManager] Keeping original ground visible for scene: " + scene_name)
		# original_ground.visible = false  # Commented out - keep ground
	
	# Load the scene (SceneLoader.load_scene returns bool, not Node3D)
	var scene_loader = get_node("/root/SceneLoader")
	if scene_loader and scene_loader.has_method("load_scene"):
		var load_success = scene_loader.load_scene(scene_name)
		if load_success:
			# Scene loaded successfully, objects spawned by WorldBuilder
			static_scene = null  # Reset since objects managed by WorldBuilder
			current_scene_type = SceneType.STATIC
			current_scene_name = scene_name
			
			# Ensure ground is visible after scene load
			_ensure_ground_visible()
			
			scene_changed.emit(scene_name)
			print("[SceneManager] Scene '" + scene_name + "' loaded successfully")
		else:
			print("[SceneManager] Failed to load scene: " + scene_name)

func generate_procedural_world(size: int = 128) -> void:
	print("[SceneManager] Generating procedural world...")
	
	# Clear existing scene first
	clear_current_scene()
	
	# Hide original ground for procedural worlds
	if original_ground:
		original_ground.visible = false
	
	# Create world generator
	var world_gen = get_node_or_null("/root/HeightmapWorldGenerator")
	if not world_gen:
		var gen_script = load("res://scripts/core/heightmap_world_generator.gd")
		if gen_script:
			world_gen = Node3D.new()
			world_gen.name = "HeightmapWorldGenerator"
			world_gen.set_script(gen_script)
			get_tree().FloodgateController.universal_add_child(world_gen, root)
	
	if world_gen:
		# Move it to terrain container
		if world_gen.get_parent():
			world_gen.get_parent().remove_child(world_gen)
		FloodgateController.universal_add_child(world_gen, terrain_container)
		
		world_gen.terrain_size = size
		world_gen.generate_world()
		
		procedural_world = world_gen
		current_scene_type = SceneType.PROCEDURAL
		current_scene_name = "procedural_world"
		scene_changed.emit("procedural_world")

func load_hybrid_scene(scene_name: String, with_procedural: bool = true) -> void:
	print("[SceneManager] Loading hybrid scene: " + scene_name)
	
	# Clear first
	clear_current_scene()
	
	# Load static scene
	load_static_scene(scene_name)
	
	# Add procedural elements if requested
	if with_procedural:
		# Generate smaller procedural elements around the static scene
		# This could be vegetation, creatures, etc.
		current_scene_type = SceneType.HYBRID

func restore_default_scene() -> void:
	print("[SceneManager] Restoring default scene...")
	
	# Clear everything
	clear_current_scene()
	
	# Show original ground
	if original_ground:
		original_ground.visible = true
	
	current_scene_type = SceneType.STATIC
	current_scene_name = "default"
	scene_changed.emit("default")

# ================================
# OBJECT MANAGEMENT
# ================================

func add_object_to_scene(object: Node3D, category: String = "object") -> void:
	match category:
		"creature", "bird", "character":
			FloodgateController.universal_add_child(object, creatures_container)
		"terrain", "ground", "water":
			FloodgateController.universal_add_child(object, terrain_container)
		_:
			FloodgateController.universal_add_child(object, objects_container)

func get_spawn_position() -> Vector3:
	# Get appropriate spawn position based on current scene
	var spawn_pos = Vector3.ZERO
	
	if current_scene_type == SceneType.PROCEDURAL and procedural_world:
		# Get height from heightmap
		if procedural_world.has_method("get_height_at_position"):
			spawn_pos.y = procedural_world.get_height_at_position(spawn_pos) + 1.0
	else:
		# Default height
		spawn_pos.y = 1.0
	
	return spawn_pos

func get_ground_height_at(position: Vector3) -> float:
	if current_scene_type == SceneType.PROCEDURAL and procedural_world:
		if procedural_world.has_method("get_height_at_position"):
			return procedural_world.get_height_at_position(position)
	
	# Default ground height
	return 0.0

# ================================
# QUERIES
# ================================

func get_current_scene_info() -> Dictionary:
	return {
		"type": SceneType.keys()[current_scene_type],
		"name": current_scene_name,
		"has_terrain": procedural_world != null or static_scene != null,
		"object_count": objects_container.get_child_count(),
		"creature_count": creatures_container.get_child_count()
	}

func is_procedural_scene() -> bool:
	return current_scene_type == SceneType.PROCEDURAL

func has_terrain() -> bool:
	return procedural_world != null or static_scene != null or (original_ground and original_ground.visible)

func _ensure_ground_visible() -> void:
	"""Ensure ground is visible, restore if missing"""
	if not original_ground:
		_find_original_ground()
	
	if original_ground:
		if not original_ground.visible:
			original_ground.visible = true
			print("[SceneManager] ✅ Ground restored to visible")
		else:
			print("[SceneManager] ✅ Ground already visible")
	else:
		print("[SceneManager] ⚠️ No ground found to restore")
		_create_emergency_ground()

func _create_emergency_ground() -> void:
	"""Create emergency ground if original is missing"""
	print("[SceneManager] Creating emergency ground...")
	
	var ground = StaticBody3D.new()
	ground.name = "EmergencyGround"
	ground.position = Vector3(0, -0.5, 0)
	
	# Collision shape
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(100, 1, 100)
	collision.shape = shape
	FloodgateController.universal_add_child(collision, ground)
	
	# Visual mesh
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(100, 1, 100)
	mesh_instance.mesh = box_mesh
	
	# Green emergency ground material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.2, 0.6, 0.2, 1.0)  # Green
	material.roughness = 0.8
	mesh_instance.material_override = material
	FloodgateController.universal_add_child(mesh_instance, ground)
	
	# Add to main scene
	get_tree().FloodgateController.universal_add_child(ground, current_scene)
	original_ground = ground
	
	print("[SceneManager] ✅ Emergency green ground created")