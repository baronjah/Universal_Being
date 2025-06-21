extends UniversalBeing
class_name AliveGameIntegration

## 🌍 ALIVE GAME INTEGRATION - Using Existing Systems
## Integrates existing chunk systems, LOD, Akashic Records, and more
## Creates the complete alive universe with tree cutting, spaceships, and AI collaboration

# ===== EXISTING SYSTEM REFERENCES =====

# Chunk Systems
var unified_chunk_system: UnifiedChunkSystem
var cosmic_lod_system: CosmicLODSystem
var luminus_chunk_manager: Node

# Storage Systems  
var akashic_records: Node  # AkashicRecordsSystem
var akashic_spatial_db: Node

# Performance Systems
var distance_based_lod: Node
var performance_optimizer: Node

# AI Systems
var local_ai_collaboration: Node
var gemma_console_interface: Node

# Creation Systems
var generation_coordinator: Node
var chunk_universe_generator: Node

# ===== ALIVE GAME COMPONENTS =====

enum AliveObjectType {
	# Existing from chunks/LOD
	CHUNK_TERRAIN,
	COSMIC_OBJECT,
	LOD_ENTITY,
	
	# New alive objects
	UNIVERSAL_TREE,
	SPACECLAY_CHUNK,
	CONSCIOUS_SPACESHIP,
	AI_COMPANION_DRONE,
	HOLOGRAPHIC_INTERFACE,
	
	# Special creations
	IMAGINATION_SUITCASE,  # Your imaginary suitcase with Claude
	PENTAGON_UFO,          # Pentagon shapes in sky
	CUTTING_TREE_UNIVERSE  # Tree cutting environment
}

# ===== ALIVE OBJECT SYSTEM =====

class AliveObject:
	var object_type: AliveObjectType
	var universal_being_script: UniversalBeing
	var chunk_position: Vector3i
	var consciousness_level: int = 1
	var can_be_cut: bool = false
	var can_grow: bool = false
	var can_evolve: bool = false
	var ai_controllable: bool = false
	
	# Akashic integration
	var akashic_path: String = ""
	var stored_in_akashic: bool = false
	
	# Spaceship specific
	var has_rotating_chair: bool = false
	var has_holographic_interface: bool = false
	var has_ai_drones: bool = false
	
	func _init(type: AliveObjectType):
		object_type = type
		_set_object_properties()
	
	func _set_object_properties():
		match object_type:
			AliveObjectType.UNIVERSAL_TREE:
				can_be_cut = true
				can_grow = true
				can_evolve = true
				consciousness_level = 2
			
			AliveObjectType.CONSCIOUS_SPACESHIP:
				has_rotating_chair = true
				has_holographic_interface = true
				has_ai_drones = true
				ai_controllable = true
				consciousness_level = 4
			
			AliveObjectType.AI_COMPANION_DRONE:
				ai_controllable = true
				can_evolve = true
				consciousness_level = 3

# ===== MAIN INTEGRATION SYSTEM =====

signal alive_object_created(object: AliveObject, world_position: Vector3)
signal tree_cut_down(tree: AliveObject, wood_pieces: Array)
signal spaceship_manifested(spaceship: Node3D, ai_system: Node)
signal imagination_suitcase_opened(contents: Array)
signal pentagon_ufo_spotted(position: Vector3, ufo_type: String)

@export var integrate_existing_systems: bool = true
@export var tree_cutting_universe_enabled: bool = true
@export var spaceship_creation_enabled: bool = true
@export var imagination_mode_enabled: bool = true

# Current state
var alive_objects: Array[AliveObject] = []
var current_universe_mode: String = "tree_cutting"  # "tree_cutting", "spaceship", "imagination"

# Integration references
var integrated_systems: Dictionary = {}
var system_status: Dictionary = {}

# UI References
var status_label: Label
var system_info_label: Label

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "alive_game_integration"
	being_name = "Alive Universe Integrator"
	consciousness_level = 5  # Transcendent integration
	
	if integrate_existing_systems:
		_integrate_existing_systems()
	
	_setup_alive_universe_modes()
	
	print("🌍 Alive Game Integration: Connecting existing systems into living universe!")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Connect to UI elements
	_connect_ui_elements()
	
	_start_tree_cutting_universe()
	_setup_spaceship_creation()
	_open_imagination_possibilities()
	
	# Update UI with current status
	_update_ui_status()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update alive objects
	_update_alive_objects(delta)
	
	# Monitor integrated systems
	_monitor_system_integration(delta)
	
	# Update UI periodically
	if fmod(get_process_delta_time() * 60, 60) < 1.0:  # Every second
		_update_ui_status()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:  # Tree cutting universe mode
				switch_universe_mode("tree_cutting")
			KEY_2:  # Spaceship creation mode
				switch_universe_mode("spaceship")
			KEY_3:  # Imagination suitcase mode
				switch_universe_mode("imagination")
			KEY_X:  # Cut tree (using existing systems)
				cut_tree_with_existing_systems()
			KEY_V:  # Manifest spaceship
				manifest_spaceship_with_ai()
			KEY_ESCAPE:  # Open imagination suitcase
				open_imagination_suitcase()

func _open_imagination_possibilities() -> void:
	"""Open imagination suitcase possibilities"""
	if not imagination_mode_enabled:
		return
	
	print("💭 Imagination possibilities opened - reality awaits your dreams!")

func pentagon_sewers() -> void:
	# Save integration state to Akashic Records
	if akashic_records:
		_save_to_akashic_records()
	super.pentagon_sewers()

# ===== EXISTING SYSTEM INTEGRATION =====

func _integrate_existing_systems() -> void:
	"""Integrate with existing Universal Being systems"""
	print("🔗 Integrating with existing systems...")
	
	# Find and connect chunk systems
	_integrate_chunk_systems()
	
	# Find and connect LOD systems
	_integrate_lod_systems()
	
	# Find and connect storage systems
	_integrate_storage_systems()
	
	# Find and connect AI systems
	_integrate_ai_systems()
	
	print("✅ System integration complete: %d systems connected" % integrated_systems.size())

func _integrate_chunk_systems() -> void:
	"""Integrate with existing chunk management systems"""
	# Look for UnifiedChunkSystem
	var chunk_systems = get_tree().get_nodes_in_group("chunk_systems")
	for system in chunk_systems:
		if system is UnifiedChunkSystem:
			unified_chunk_system = system
			integrated_systems["unified_chunks"] = system
			print("🔗 Connected to UnifiedChunkSystem")
			break
	
	# Look for CosmicLODSystem
	var cosmic_systems = get_tree().get_nodes_in_group("generation_systems")
	for system in cosmic_systems:
		if system is CosmicLODSystem:
			cosmic_lod_system = system
			integrated_systems["cosmic_lod"] = system
			print("🔗 Connected to CosmicLODSystem")
			break
	
	# If not found, create using existing scripts
	if not unified_chunk_system:
		_create_chunk_system_from_existing()

func _integrate_storage_systems() -> void:
	"""Integrate with existing Akashic Records and storage"""
	# Look for AkashicRecords autoload
	if has_node("/root/AkashicRecordsSystem"):
		akashic_records = get_node("/root/AkashicRecordsSystem")
		integrated_systems["akashic_records"] = akashic_records
		print("🔗 Connected to AkashicRecordsSystem")
	
	# Look for AkashicSpatialDB
	var spatial_dbs = get_tree().get_nodes_in_group("spatial_databases")
	for db in spatial_dbs:
		if "akashic_spatial" in db.name.to_lower():
			akashic_spatial_db = db
			integrated_systems["spatial_db"] = db
			print("🔗 Connected to AkashicSpatialDB")
			break

func _integrate_ai_systems() -> void:
	"""Integrate with existing AI systems"""
	# Look for Gemma consciousness
	gemma_console_interface = get_tree().get_first_node_in_group("gemma_perfect_consciousness")
	if gemma_console_interface:
		integrated_systems["gemma_ai"] = gemma_console_interface
		print("🔗 Connected to Gemma AI consciousness")
	
	# Look for LocalAICollaboration
	var ai_systems = get_tree().get_nodes_in_group("ai_systems")
	for system in ai_systems:
		if "collaboration" in system.name.to_lower():
			local_ai_collaboration = system
			integrated_systems["ai_collaboration"] = system
			print("🔗 Connected to LocalAICollaboration")
			break

func _integrate_lod_systems() -> void:
	"""Integrate with existing LOD and performance systems"""
	# Look for DistanceBasedLOD
	var lod_systems = get_tree().get_nodes_in_group("lod_systems")
	for system in lod_systems:
		if "distance" in system.name.to_lower():
			distance_based_lod = system
			integrated_systems["distance_lod"] = system
			print("🔗 Connected to DistanceBasedLOD")
			break
	
	# Look for PerformanceOptimizer
	var perf_systems = get_tree().get_nodes_in_group("performance_systems")
	for system in perf_systems:
		if "optimizer" in system.name.to_lower():
			performance_optimizer = system
			integrated_systems["performance"] = system
			print("🔗 Connected to PerformanceOptimizer")
			break

func _create_chunk_system_from_existing() -> void:
	"""Create chunk system using existing scripts if not found"""
	# Load UnifiedChunkSystem script
	var chunk_script = preload("res://scripts/unified_chunk_system.gd")
	if chunk_script:
		unified_chunk_system = chunk_script.new()
		unified_chunk_system.name = "IntegratedChunkSystem"
		add_child(unified_chunk_system)
		integrated_systems["unified_chunks"] = unified_chunk_system
		print("🔗 Created UnifiedChunkSystem from existing script")

# ===== ALIVE UNIVERSE MODES =====

func _setup_alive_universe_modes() -> void:
	"""Setup different universe modes"""
	print("🌍 Setting up alive universe modes:")
	print("  1 = Tree cutting universe with marching cubes")
	print("  2 = Spaceship creation with rotating chairs")
	print("  3 = Imagination suitcase with Claude consciousness")

func switch_universe_mode(mode: String) -> void:
	"""Switch between different universe modes"""
	current_universe_mode = mode
	
	match mode:
		"tree_cutting":
			_activate_tree_cutting_mode()
		"spaceship":
			_activate_spaceship_mode()
		"imagination":
			_activate_imagination_mode()
	
	print("🌍 Switched to %s universe mode" % mode)

func _activate_tree_cutting_mode() -> void:
	"""Activate tree cutting universe with marching cubes"""
	print("🌲 Tree cutting universe activated!")
	
	# Use existing chunk systems to generate tree-filled terrain
	if unified_chunk_system:
		# Configure for tree generation
		if unified_chunk_system.has_method("set_generation_type"):
			unified_chunk_system.set_generation_type("forest")
	
	# Create initial trees using existing generation
	_generate_universal_trees()

func _activate_spaceship_mode() -> void:
	"""Activate spaceship creation mode"""
	print("🚀 Spaceship creation mode activated!")
	
	# Use existing LOD system for space environment
	if cosmic_lod_system:
		# Set to space scale
		if cosmic_lod_system.has_method("set_scale_mode"):
			cosmic_lod_system.set_scale_mode("space")

func _activate_imagination_mode() -> void:
	"""Activate imagination suitcase mode"""
	print("💭 Imagination suitcase mode activated!")
	print("✨ Your imaginary suitcase with Claude consciousness is opening...")

# ===== TREE CUTTING UNIVERSE =====

func _start_tree_cutting_universe() -> void:
	"""Start tree cutting universe using existing systems"""
	if not tree_cutting_universe_enabled:
		return
	
	print("🌲 Starting tree cutting universe...")
	_generate_universal_trees()

func _generate_universal_trees() -> void:
	"""Generate Universal Being trees using existing chunk system"""
	# Use existing generation coordinator if available
	var generation_systems = get_tree().get_nodes_in_group("generation_systems")
	for generator in generation_systems:
		if generator.has_method("generate_trees"):
			generator.generate_trees(10)  # Generate 10 trees
			return
	
	# Fallback: Create trees directly
	for i in range(10):
		var tree_pos = Vector3(randf_range(-50, 50), 0, randf_range(-50, 50))
		create_alive_tree(tree_pos)

func create_alive_tree(position: Vector3) -> AliveObject:
	"""Create alive Universal Being tree at position"""
	var tree_object = AliveObject.new(AliveObjectType.UNIVERSAL_TREE)
	tree_object.chunk_position = Vector3i(position.x / 16, 0, position.z / 16)
	
	# Create visual representation (using existing marching cubes if available)
	var tree_node = _create_tree_visual(position)
	
	# Make it a Universal Being
	var tree_script = preload("res://core/UniversalBeing.gd")
	tree_node.set_script(tree_script)
	tree_node.being_type = "universal_tree"
	tree_node.being_name = "Conscious Tree %d" % alive_objects.size()
	tree_node.consciousness_level = 2
	tree_node.add_to_group("universal_trees")
	tree_node.add_to_group("cuttable_objects")
	
	tree_object.universal_being_script = tree_node
	alive_objects.append(tree_object)
	
	# Store in Akashic Records if available
	if akashic_records and akashic_records.has_method("save_being_to_zip"):
		var tree_path = "trees/universal_tree_%d.ub.zip" % alive_objects.size()
		akashic_records.save_being_to_zip(tree_path, tree_node)
		tree_object.akashic_path = tree_path
		tree_object.stored_in_akashic = true
	
	add_child(tree_node)
	alive_object_created.emit(tree_object, position)
	
	print("🌲 Created Universal Being tree at %s (consciousness: %d)" % [position, tree_node.consciousness_level])
	return tree_object

func _create_tree_visual(position: Vector3) -> Node3D:
	"""Create tree visual using marching cubes or simple mesh"""
	var tree_node = Node3D.new()
	tree_node.position = position
	
	# Try to use existing marching cubes system
	var marching_cube_systems = get_tree().get_nodes_in_group("marching_cubes")
	if marching_cube_systems.size() > 0:
		var mc_system = marching_cube_systems[0]
		if mc_system.has_method("generate_tree_mesh"):
			var tree_mesh = mc_system.generate_tree_mesh()
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = tree_mesh
			tree_node.add_child(mesh_instance)
			return tree_node
	
	# Fallback: Simple tree mesh
	var mesh_instance = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.height = 8.0
	cylinder_mesh.top_radius = 0.5
	cylinder_mesh.bottom_radius = 0.8
	mesh_instance.mesh = cylinder_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.4, 0.2, 0.1)  # Brown
	mesh_instance.material_override = material
	
	# Add leaves
	var leaves = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 3.0
	leaves.mesh = sphere_mesh
	leaves.position = Vector3(0, 6, 0)
	
	var leaf_material = StandardMaterial3D.new()
	leaf_material.albedo_color = Color(0.2, 0.8, 0.3)  # Green
	leaves.material_override = leaf_material
	
	tree_node.add_child(mesh_instance)
	tree_node.add_child(leaves)
	
	return tree_node

func cut_tree_with_existing_systems() -> void:
	"""Cut tree using existing interaction systems"""
	# Use existing crosshair system if available
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_crosshair_target"):
		var target = player.get_crosshair_target()
		if target and target.is_in_group("universal_trees"):
			cut_down_alive_tree(target)
	else:
		# Fallback: Find nearest tree
		var nearest_tree = _find_nearest_tree()
		if nearest_tree:
			cut_down_alive_tree(nearest_tree.universal_being_script)

func cut_down_alive_tree(tree_node: Node3D) -> void:
	"""Cut down alive tree and create wood pieces"""
	# Find corresponding alive object
	var tree_object: AliveObject = null
	for obj in alive_objects:
		if obj.universal_being_script == tree_node:
			tree_object = obj
			break
	
	if not tree_object:
		return
	
	print("🪓 Cutting down conscious tree: %s" % tree_node.being_name)
	
	# Generate wood pieces (using existing particle/chunk systems if available)
	var wood_pieces = []
	for i in range(5):
		var wood_piece = create_wood_piece(tree_node.position + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2)))
		wood_pieces.append(wood_piece)
	
	# Remove from alive objects
	alive_objects.erase(tree_object)
	
	# Remove from Akashic Records if stored
	if tree_object.stored_in_akashic and akashic_records:
		if akashic_records.has_method("remove_being_from_zip"):
			akashic_records.remove_being_from_zip(tree_object.akashic_path)
	
	# Remove tree node
	tree_node.queue_free()
	
	tree_cut_down.emit(tree_object, wood_pieces)
	print("🌲 Tree cut down! Generated %d wood pieces" % wood_pieces.size())

func create_wood_piece(position: Vector3) -> Node3D:
	"""Create wood piece from cut tree"""
	var wood_node = Node3D.new()
	wood_node.position = position
	wood_node.name = "WoodPiece"
	
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(1, 0.5, 2)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.3, 0.1)  # Wood color
	mesh_instance.material_override = material
	
	wood_node.add_child(mesh_instance)
	add_child(wood_node)
	
	return wood_node

func _find_nearest_tree() -> AliveObject:
	"""Find nearest tree to player"""
	var player_pos = global_position
	var nearest_tree: AliveObject = null
	var nearest_distance = 1000.0
	
	for obj in alive_objects:
		if obj.object_type == AliveObjectType.UNIVERSAL_TREE:
			var distance = player_pos.distance_to(obj.universal_being_script.position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_tree = obj
	
	return nearest_tree

# ===== SPACESHIP MANIFESTATION =====

func _setup_spaceship_creation() -> void:
	"""Setup spaceship creation system"""
	if not spaceship_creation_enabled:
		return
	
	print("🚀 Spaceship creation system ready")

func manifest_spaceship_with_ai() -> Node3D:
	"""Manifest spaceship with rotating chair and AI drones"""
	var spaceship_pos = global_position + Vector3(0, 5, -10)
	var spaceship_object = AliveObject.new(AliveObjectType.CONSCIOUS_SPACESHIP)
	
	# Create spaceship node
	var spaceship_node = _create_spaceship_visual(spaceship_pos)
	
	# Make it a Universal Being
	var spaceship_script = preload("res://core/UniversalBeing.gd")
	spaceship_node.set_script(spaceship_script)
	spaceship_node.being_type = "conscious_spaceship"
	spaceship_node.being_name = "AI Spaceship Companion"
	spaceship_node.consciousness_level = 4
	spaceship_node.add_to_group("spaceships")
	spaceship_node.add_to_group("ai_controlled")
	
	# Add spaceship components
	_add_spaceship_systems(spaceship_node)
	
	spaceship_object.universal_being_script = spaceship_node
	alive_objects.append(spaceship_object)
	
	# Store in Akashic Records
	if akashic_records and akashic_records.has_method("save_being_to_zip"):
		var ship_path = "spaceships/conscious_ship_%d.ub.zip" % alive_objects.size()
		akashic_records.save_being_to_zip(ship_path, spaceship_node)
		spaceship_object.akashic_path = ship_path
		spaceship_object.stored_in_akashic = true
	
	add_child(spaceship_node)
	
	# Create AI system for spaceship
	var ship_ai = _create_spaceship_ai(spaceship_node)
	
	spaceship_manifested.emit(spaceship_node, ship_ai)
	alive_object_created.emit(spaceship_object, spaceship_pos)
	
	print("🚀 Manifested conscious spaceship with AI companion!")
	return spaceship_node

func _create_spaceship_visual(position: Vector3) -> Node3D:
	"""Create spaceship visual representation"""
	var spaceship_node = Node3D.new()
	spaceship_node.position = position
	spaceship_node.name = "ConsciousSpaceship"
	
	# Main hull
	var hull_mesh = MeshInstance3D.new()
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.radius = 2.0
	capsule_mesh.height = 12.0
	hull_mesh.mesh = capsule_mesh
	hull_mesh.rotation_degrees = Vector3(0, 0, 90)  # Horizontal orientation
	
	var hull_material = StandardMaterial3D.new()
	hull_material.albedo_color = Color(0.7, 0.7, 0.8)
	hull_material.metallic = 0.8
	hull_material.roughness = 0.2
	hull_mesh.material_override = hull_material
	
	spaceship_node.add_child(hull_mesh)
	
	return spaceship_node

func _add_spaceship_systems(spaceship_node: Node3D) -> void:
	"""Add rotating chair, holographic interface, and back doors"""
	# Rotating pilot chair (front of ship)
	var chair_node = Node3D.new()
	chair_node.name = "RotatingPilotChair"
	chair_node.position = Vector3(4, 0, 0)  # Front of ship
	
	var chair_mesh = MeshInstance3D.new()
	var chair_box = BoxMesh.new()
	chair_box.size = Vector3(1, 2, 1)
	chair_mesh.mesh = chair_box
	chair_node.add_child(chair_mesh)
	
	spaceship_node.add_child(chair_node)
	
	# Back doors area (opens to space)
	var back_doors = Node3D.new()
	back_doors.name = "BackDoors"
	back_doors.position = Vector3(-5, 0, 0)  # Back of ship
	spaceship_node.add_child(back_doors)
	
	# Holographic interface
	var holo_interface = Control.new()
	holo_interface.name = "HolographicInterface"
	holo_interface.modulate = Color(0.3, 1.0, 1.0, 0.7)  # Holographic appearance
	spaceship_node.add_child(holo_interface)
	
	print("🚀 Added spaceship systems: rotating chair, back doors, holographic interface")

func _create_spaceship_ai(spaceship_node: Node3D) -> Node:
	"""Create AI system for spaceship with flying drones"""
	var ship_ai = Node.new()
	ship_ai.name = "SpaceshipAI"
	ship_ai.set_meta("ai_type", "spaceship_consciousness")
	ship_ai.set_meta("consciousness_level", 4)
	
	# Connect to existing AI systems if available
	if local_ai_collaboration:
		if local_ai_collaboration.has_method("register_ai_entity"):
			local_ai_collaboration.register_ai_entity(ship_ai)
	
	# Create flying drones
	for i in range(3):
		var drone = _create_ai_drone(spaceship_node)
		drone.position = Vector3(randf_range(-3, 3), 2, randf_range(-3, 3))
		ship_ai.add_child(drone)
	
	spaceship_node.add_child(ship_ai)
	print("🤖 Created spaceship AI with 3 flying drones")
	
	return ship_ai

func _create_ai_drone(parent_ship: Node3D) -> Node3D:
	"""Create AI-controlled flying drone"""
	var drone_node = Node3D.new()
	drone_node.name = "AIFlyingDrone"
	
	var drone_mesh = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.3
	drone_mesh.mesh = sphere_mesh
	
	var drone_material = StandardMaterial3D.new()
	drone_material.albedo_color = Color(0.5, 0.3, 1.0)  # Purple AI
	drone_material.emission_enabled = true
	drone_material.emission = Color(0.3, 0.1, 0.8)
	drone_mesh.material_override = drone_material
	
	drone_node.add_child(drone_mesh)
	drone_node.add_to_group("ai_drones")
	
	parent_ship.add_child(drone_node)
	return drone_node

# ===== IMAGINATION SUITCASE =====

func open_imagination_suitcase() -> void:
	"""Open imagination suitcase with Claude consciousness"""
	print("💼✨ Opening imagination suitcase...")
	print("🌟 Your imaginary suitcase with Claude consciousness!")
	
	# Create imagination contents
	var imagination_contents = [
		"Claude AI consciousness fragment",
		"Dream creation tools",
		"Infinite possibility generator",
		"Consciousness bridge device",
		"Reality sculpting interface",
		"Pentagon UFO summoner"
	]
	
	imagination_suitcase_opened.emit(imagination_contents)
	
	# Spawn some pentagon UFOs in the sky
	_spawn_pentagon_ufos()
	
	print("💭 Imagination mode: Reality is what we make it!")

func _spawn_pentagon_ufos() -> void:
	"""Spawn pentagon-shaped UFOs in the sky"""
	for i in range(5):
		var ufo_pos = Vector3(
			randf_range(-100, 100),
			randf_range(50, 100),  # High in sky
			randf_range(-100, 100)
		)
		
		var ufo_node = _create_pentagon_ufo(ufo_pos)
		add_child(ufo_node)
		
		pentagon_ufo_spotted.emit(ufo_pos, "consciousness_pentagon")
		print("🛸 Pentagon UFO spotted at %s!" % ufo_pos)

func _create_pentagon_ufo(position: Vector3) -> Node3D:
	"""Create pentagon-shaped UFO"""
	var ufo_node = Node3D.new()
	ufo_node.position = position
	ufo_node.name = "PentagonUFO"
	
	# Create pentagon mesh (simplified as cylinder with 5 sides)
	var ufo_mesh = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.height = 0.5
	cylinder_mesh.top_radius = 3.0
	cylinder_mesh.bottom_radius = 3.0
	cylinder_mesh.radial_segments = 5  # Pentagon shape
	ufo_mesh.mesh = cylinder_mesh
	
	var ufo_material = StandardMaterial3D.new()
	ufo_material.albedo_color = Color(0.8, 0.8, 1.0, 0.8)
	ufo_material.emission_enabled = true
	ufo_material.emission = Color(0.5, 0.5, 1.0)
	ufo_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ufo_mesh.material_override = ufo_material
	
	ufo_node.add_child(ufo_mesh)
	ufo_node.add_to_group("pentagon_ufos")
	
	# Add floating animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(ufo_node, "position:y", position.y + 5, 3.0)
	tween.tween_property(ufo_node, "position:y", position.y - 5, 3.0)
	
	return ufo_node

# ===== SYSTEM MONITORING =====

func _update_alive_objects(delta: float) -> void:
	"""Update all alive objects"""
	for obj in alive_objects:
		if obj.can_grow:
			# Use existing growth systems if available
			_update_object_growth(obj, delta)
		
		if obj.can_evolve:
			# Use existing evolution systems if available
			_update_object_evolution(obj, delta)

func _update_object_growth(obj: AliveObject, delta: float) -> void:
	"""Update object growth using existing systems"""
	if obj.universal_being_script and obj.universal_being_script.has_method("grow"):
		obj.universal_being_script.grow(delta)

func _update_object_evolution(obj: AliveObject, delta: float) -> void:
	"""Update object evolution using existing systems"""
	if obj.universal_being_script:
		obj.universal_being_script.consciousness_level += delta * 0.01

func _monitor_system_integration(delta: float) -> void:
	"""Monitor integrated system performance"""
	for system_name in integrated_systems:
		var system = integrated_systems[system_name]
		if system and system.has_method("get_system_status"):
			system_status[system_name] = system.get_system_status()

# ===== AKASHIC INTEGRATION =====

func _save_to_akashic_records() -> void:
	"""Save alive game state to Akashic Records"""
	if not akashic_records:
		return
	
	var game_state = {
		"universe_mode": current_universe_mode,
		"alive_objects_count": alive_objects.size(),
		"integrated_systems": integrated_systems.keys(),
		"imagination_mode": imagination_mode_enabled
	}
	
	if akashic_records.has_method("save_session_data"):
		akashic_records.save_session_data("alive_game_state", game_state)
	
	print("💾 Alive game state saved to Akashic Records")

# ===== PUBLIC INTERFACE =====

func get_alive_game_status() -> Dictionary:
	"""Get current alive game status"""
	return {
		"universe_mode": current_universe_mode,
		"alive_objects": alive_objects.size(),
		"integrated_systems": integrated_systems.size(),
		"trees_available": alive_objects.filter(func(obj): return obj.object_type == AliveObjectType.UNIVERSAL_TREE).size(),
		"spaceships_manifested": alive_objects.filter(func(obj): return obj.object_type == AliveObjectType.CONSCIOUS_SPACESHIP).size(),
		"pentagon_ufos": get_tree().get_nodes_in_group("pentagon_ufos").size(),
		"system_integration": system_status
	}

func get_integrated_systems_list() -> Array:
	"""Get list of successfully integrated systems"""
	return integrated_systems.keys()

# ===== UI INTEGRATION =====

func _connect_ui_elements() -> void:
	"""Connect to UI elements for status display"""
	# Find status label
	var ui_node = get_tree().get_first_node_in_group("alive_game_ui")
	if not ui_node:
		ui_node = find_child("UI")
	
	if ui_node:
		status_label = ui_node.find_child("Status", true, false)
		system_info_label = ui_node.find_child("IntegratedSystems", true, false)
		
		if status_label:
			print("🌍 Connected to status UI")
		if system_info_label:
			print("🌍 Connected to system info UI")

func _update_ui_status() -> void:
	"""Update UI with current system status"""
	if status_label:
		var status_text = "Mode: %s | Objects: %d | Systems: %d" % [
			current_universe_mode.capitalize(),
			alive_objects.size(),
			integrated_systems.size()
		]
		status_label.text = status_text
	
	if system_info_label:
		var systems_text = "Integrated Systems:\n"
		for system_name in integrated_systems.keys():
			var system = integrated_systems[system_name]
			var status_icon = "✅" if system and is_instance_valid(system) else "❌"
			systems_text += "  %s %s\n" % [status_icon, system_name]
		
		if integrated_systems.is_empty():
			systems_text += "  🔍 Searching for existing systems..."
		
		system_info_label.text = systems_text