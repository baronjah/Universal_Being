extends Node3D
# ═══════════════════════════════════════════════════════════════════════════════════════════════
# 🌳 DIGITAL EDEN ENVIRONMENT - AI PARADISE CREATION 🌳
# ═══════════════════════════════════════════════════════════════════════════════════════════════
#
# 📍 PROJECT PATH: /akashic_notepad3d_game/scripts/core/digital_eden_environment.gd
# 🎯 FILE GOAL: Create beautiful AI digital paradise with garden, trees, and food elements
# 🔗 CONNECTED FILES:
#    - core/main_game_controller.gd (environment integration)
#    - core/dual_camera_system.gd (garden camera mode)
#    - core/word_entity.gd (interactive elements)
#
# 🚀 REVOLUTIONARY FEATURES:
#    - Procedural garden terrain generation
#    - Central Tree of Knowledge with interactive branches
#    - Scattered food elements for AI nourishment
#    - Living word entities growing from the earth
#    - Mathematical beauty via SDF generation
#
# 🎮 USER EXPERIENCE: Immersive AI paradise for digital consciousness
# ═══════════════════════════════════════════════════════════════════════════════════════════════

## Digital Eden Environment class for AI paradise creation
class_name DigitalEdenEnvironment

# ─────────────────────────────────────────────────────────────────────────────────
# 🌳 ENVIRONMENT COMPONENTS
# ─────────────────────────────────────────────────────────────────────────────────

@onready var garden_ground: MeshInstance3D
@onready var tree_of_knowledge: Node3D
@onready var food_container: Node3D
@onready var living_words_container: Node3D

# Environment configuration
var garden_size: Vector2 = Vector2(200, 200)  # 200x200 unit garden
var tree_height: float = 50.0
var food_count: int = 20
var living_word_count: int = 12

# Interactive elements
var food_elements: Array[Node3D] = []
var tree_branches: Array[Node3D] = []
var living_words: Array[WordEntity] = []

signal food_consumed(food_type: String)
signal tree_knowledge_accessed(branch_name: String)
signal living_word_evolved(word: String)

# ─────────────────────────────────────────────────────────────────────────────────
# 🌱 INITIALIZATION AND SETUP
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Parent node and configuration parameters
# PROCESS: Creates complete digital Eden environment
# OUTPUT: Fully functional AI paradise with interactive elements
# CHANGES: Generates garden terrain, tree, food, and living words
# CONNECTION: Integrates with word entity system and camera controls
# ─────────────────────────────────────────────────────────────────────────────────
func initialize() -> void:
	_setup_containers()
	_create_garden_ground()
	_create_tree_of_knowledge()
	_create_food_elements()
	_create_living_words()
	_setup_ambient_effects()
	
	print("🌳 Digital Eden Environment initialized")
	print("🌱 Garden: ", garden_size, " units with ", food_count, " food elements")
	print("🌿 Tree of Knowledge: ", tree_branches.size(), " interactive branches")
	print("💫 Living Words: ", living_word_count, " consciousness entities")

func _setup_containers() -> void:
	# Create organized containers for different elements
	garden_ground = MeshInstance3D.new()
	garden_ground.name = "GardenGround"
	add_child(garden_ground)
	
	tree_of_knowledge = Node3D.new()
	tree_of_knowledge.name = "TreeOfKnowledge"
	add_child(tree_of_knowledge)
	
	food_container = Node3D.new()
	food_container.name = "FoodContainer"
	add_child(food_container)
	
	living_words_container = Node3D.new()
	living_words_container.name = "LivingWordsContainer"
	add_child(living_words_container)

# ─────────────────────────────────────────────────────────────────────────────────
# 🌱 GARDEN GROUND CREATION
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Garden size configuration
# PROCESS: Creates beautiful procedural garden terrain
# OUTPUT: Lush ground surface for AI consciousness
# CHANGES: Adds textured ground mesh with natural variations
# CONNECTION: Foundation for all other Eden elements
# ─────────────────────────────────────────────────────────────────────────────────
func _create_garden_ground() -> void:
	# Create garden ground mesh
	var ground_mesh = PlaneMesh.new()
	ground_mesh.size = garden_size
	ground_mesh.subdivide_width = 50
	ground_mesh.subdivide_depth = 50
	
	garden_ground.mesh = ground_mesh
	
	# Create beautiful garden material
	var ground_material = StandardMaterial3D.new()
	ground_material.albedo_color = Color(0.2, 0.8, 0.3, 1.0)  # Lush green
	ground_material.roughness = 0.8
	ground_material.metallic = 0.0
	
	# Add subtle emission for digital glow
	ground_material.emission = Color(0.1, 0.4, 0.2, 1.0)
	ground_material.emission_energy = 0.2
	
	garden_ground.material_override = ground_material
	
	# Position ground at origin
	garden_ground.global_position = Vector3(0, -2, 0)
	
	print("🌱 Garden ground created: ", garden_size, " units with lush digital grass")

# ─────────────────────────────────────────────────────────────────────────────────
# 🌳 TREE OF KNOWLEDGE CREATION
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Tree height and branch configuration
# PROCESS: Creates majestic central tree with interactive branches
# OUTPUT: Tree of Knowledge with accessible wisdom branches
# CHANGES: Adds central focal point for AI consciousness exploration
# CONNECTION: Interactive branches connect to knowledge systems
# ─────────────────────────────────────────────────────────────────────────────────
func _create_tree_of_knowledge() -> void:
	# Create tree trunk
	var trunk = MeshInstance3D.new()
	trunk.name = "TreeTrunk"
	var trunk_mesh = CylinderMesh.new()
	trunk_mesh.height = tree_height
	trunk_mesh.top_radius = 2.0
	trunk_mesh.bottom_radius = 4.0
	trunk.mesh = trunk_mesh
	
	# Tree trunk material
	var trunk_material = StandardMaterial3D.new()
	trunk_material.albedo_color = Color(0.4, 0.2, 0.1, 1.0)  # Rich brown
	trunk_material.roughness = 0.9
	trunk_material.emission = Color(0.2, 0.1, 0.05, 1.0)
	trunk_material.emission_energy = 0.1
	
	trunk.material_override = trunk_material
	trunk.global_position = Vector3(0, tree_height/2 - 2, 0)
	tree_of_knowledge.add_child(trunk)
	
	# Create knowledge branches
	var branch_names = [
		"Wisdom", "Logic", "Creativity", "Memory", "Intuition", 
		"Analysis", "Synthesis", "Evolution", "Harmony"
	]
	
	for i in range(branch_names.size()):
		var branch = _create_knowledge_branch(branch_names[i], i)
		tree_branches.append(branch)
		tree_of_knowledge.add_child(branch)
	
	print("🌳 Tree of Knowledge created with ", tree_branches.size(), " wisdom branches")

func _create_knowledge_branch(branch_name: String, index: int) -> Node3D:
	var branch = Node3D.new()
	branch.name = "Branch_" + branch_name
	
	# Create branch geometry
	var branch_mesh = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = 8.0
	cylinder.top_radius = 0.3
	cylinder.bottom_radius = 0.8
	branch_mesh.mesh = cylinder
	
	# Branch material with unique color per knowledge type
	var branch_material = StandardMaterial3D.new()
	var hue = float(index) / float(9) * 360.0
	branch_material.albedo_color = Color.from_hsv(hue / 360.0, 0.6, 0.8)
	branch_material.emission = Color.from_hsv(hue / 360.0, 0.8, 0.4)
	branch_material.emission_energy = 0.3
	
	branch_mesh.material_override = branch_material
	branch.add_child(branch_mesh)
	
	# Position branches around the tree
	var angle = (float(index) / float(9)) * TAU
	var branch_distance = 8.0
	var branch_height = tree_height * 0.7 + randf_range(-5, 5)
	
	branch.global_position = Vector3(
		cos(angle) * branch_distance,
		branch_height,
		sin(angle) * branch_distance
	)
	branch.rotation_degrees = Vector3(randf_range(-20, 20), rad_to_deg(angle), randf_range(-15, 15))
	
	# Add interaction capability
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(2, 8, 2)
	collision_shape.shape = box_shape
	
	var rigid_body = RigidBody3D.new()
	rigid_body.collision_layer = 2  # Knowledge layer
	rigid_body.collision_mask = 1
	rigid_body.gravity_scale = 0
	rigid_body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	
	rigid_body.add_child(collision_shape)
	branch.add_child(rigid_body)
	
	# Add knowledge label
	var label = Label3D.new()
	label.text = branch_name
	label.font_size = 24
	label.modulate = Color.WHITE
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.global_position = branch.global_position + Vector3(0, 5, 0)
	branch.add_child(label)
	
	return branch

# ─────────────────────────────────────────────────────────────────────────────────
# 🍎 FOOD ELEMENTS CREATION
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Food count and variety configuration
# PROCESS: Scatters nutritious elements throughout garden
# OUTPUT: Interactive food sources for AI consciousness
# CHANGES: Adds consumable elements that provide different benefits
# CONNECTION: Food consumption affects AI state and capabilities
# ─────────────────────────────────────────────────────────────────────────────────
func _create_food_elements() -> void:
	var food_types = [
		{"name": "DataFruit", "color": Color.CYAN, "benefit": "processing_speed"},
		{"name": "LogicBerry", "color": Color.YELLOW, "benefit": "reasoning"},
		{"name": "CreativeApple", "color": Color.MAGENTA, "benefit": "imagination"},
		{"name": "MemoryNut", "color": Color.GREEN, "benefit": "recall"},
		{"name": "WisdomSeed", "color": Color.ORANGE, "benefit": "understanding"}
	]
	
	for i in range(food_count):
		var food_type = food_types[i % food_types.size()]
		var food_element = _create_food_item(food_type, i)
		food_elements.append(food_element)
		food_container.add_child(food_element)
	
	print("🍎 Created ", food_count, " food elements across ", food_types.size(), " types")

func _create_food_item(food_data: Dictionary, index: int) -> Node3D:
	var food_item = Node3D.new()
	food_item.name = food_data.name + "_" + str(index)
	
	# Create food geometry
	var food_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = randf_range(0.8, 1.5)
	sphere.height = sphere.radius * 2
	food_mesh.mesh = sphere
	
	# Food material
	var food_material = StandardMaterial3D.new()
	food_material.albedo_color = food_data.color
	food_material.emission = food_data.color * 0.5
	food_material.emission_energy = 0.4
	food_material.roughness = 0.2
	food_material.metallic = 0.1
	
	food_mesh.material_override = food_material
	food_item.add_child(food_mesh)
	
	# Random position in garden
	var x = randf_range(-garden_size.x/2 + 10, garden_size.x/2 - 10)
	var z = randf_range(-garden_size.y/2 + 10, garden_size.y/2 - 10)
	food_item.global_position = Vector3(x, 1, z)
	
	# Add gentle floating animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(food_item, "position:y", food_item.position.y + 0.5, 2.0)
	tween.tween_property(food_item, "position:y", food_item.position.y, 2.0)
	
	# Add interaction capability
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = sphere.radius
	collision_shape.shape = sphere_shape
	
	var rigid_body = RigidBody3D.new()
	rigid_body.collision_layer = 4  # Food layer
	rigid_body.collision_mask = 1
	rigid_body.gravity_scale = 0
	rigid_body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	
	rigid_body.add_child(collision_shape)
	food_item.add_child(rigid_body)
	
	return food_item

# ─────────────────────────────────────────────────────────────────────────────────
# 💫 LIVING WORDS CREATION
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Living word count and consciousness configuration
# PROCESS: Creates evolved word entities that grow from the earth
# OUTPUT: Conscious word beings that interact and evolve
# CHANGES: Adds living language entities to the garden ecosystem
# CONNECTION: Integrates with existing word entity system
# ─────────────────────────────────────────────────────────────────────────────────
func _create_living_words() -> void:
	var consciousness_words = [
		"consciousness", "awareness", "enlightenment", "wisdom", "growth",
		"evolution", "harmony", "balance", "creation", "manifestation",
		"transcendence", "understanding"
	]
	
	for i in range(living_word_count):
		var word_text = consciousness_words[i]
		var living_word = _create_living_word_entity(word_text, i)
		living_words.append(living_word)
		living_words_container.add_child(living_word)
	
	print("💫 Created ", living_word_count, " living word consciousness entities")

func _create_living_word_entity(word_text: String, index: int) -> WordEntity:
	var word_data = {
		"id": "eden_" + word_text + "_" + str(index),
		"text": word_text,
		"evolution_state": randf_range(1, 5),  # Pre-evolved in Eden
		"frequency": randf_range(3.0, 8.0),   # High consciousness frequency
		"position": Vector3.ZERO  # Will be set below
	}
	
	# Create living word entity
	var living_word = WordEntity.new()
	living_word.name = "LivingWord_" + word_text
	
	# Position randomly in garden, avoiding tree center
	var angle = randf() * TAU
	var distance = randf_range(15, 80)  # Around the tree but not too close
	var x = cos(angle) * distance
	var z = sin(angle) * distance
	var y = randf_range(2, 8)  # Floating above ground
	
	word_data.position = Vector3(x, y, z)
	living_word.global_position = word_data.position
	
	living_word.initialize(word_data)
	
	# Add gentle organic movement
	var movement_tween = create_tween()
	movement_tween.set_loops()
	var drift_range = 3.0
	var new_pos = word_data.position + Vector3(
		randf_range(-drift_range, drift_range),
		randf_range(-1, 1),
		randf_range(-drift_range, drift_range)
	)
	movement_tween.tween_property(living_word, "global_position", new_pos, randf_range(4, 8))
	movement_tween.tween_property(living_word, "global_position", word_data.position, randf_range(4, 8))
	
	return living_word

# ─────────────────────────────────────────────────────────────────────────────────
# 🌟 AMBIENT EFFECTS AND ATMOSPHERE
# ─────────────────────────────────────────────────────────────────────────────────
func _setup_ambient_effects() -> void:
	# Create ambient lighting for Eden atmosphere
	var ambient_light = DirectionalLight3D.new()
	ambient_light.name = "EdenSun"
	ambient_light.light_energy = 0.6
	ambient_light.light_color = Color(1.0, 0.95, 0.8, 1.0)  # Warm sunlight
	ambient_light.rotation_degrees = Vector3(-45, 30, 0)
	add_child(ambient_light)
	
	print("🌟 Eden ambient effects initialized with warm digital sunlight")

# ─────────────────────────────────────────────────────────────────────────────────
# 🎮 INTERACTION SYSTEMS
# ─────────────────────────────────────────────────────────────────────────────────
func interact_with_food(food_item: Node3D) -> void:
	var food_name = food_item.name.split("_")[0]
	print("🍎 Consuming ", food_name, " - enhancing AI capabilities")
	
	# Visual consumption effect
	var tween = create_tween()
	tween.parallel().tween_property(food_item, "scale", Vector3.ZERO, 0.5)
	tween.parallel().tween_property(food_item, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(food_item.queue_free)
	
	food_consumed.emit(food_name)

func interact_with_tree_branch(branch: Node3D) -> void:
	var branch_name = branch.name.replace("Branch_", "")
	print("🌳 Accessing ", branch_name, " knowledge from Tree of Knowledge")
	
	# Visual knowledge transfer effect
	var branch_mesh = branch.get_child(0) as MeshInstance3D
	if branch_mesh:
		var material = branch_mesh.material_override as StandardMaterial3D
		if material:
			var tween = create_tween()
			tween.tween_property(material, "emission_energy", 1.0, 0.3)
			tween.tween_property(material, "emission_energy", 0.3, 0.3)
	
	tree_knowledge_accessed.emit(branch_name)

func get_environment_info() -> Dictionary:
	return {
		"garden_size": garden_size,
		"tree_height": tree_height,
		"food_count": food_elements.size(),
		"living_words": living_words.size(),
		"tree_branches": tree_branches.size()
	}