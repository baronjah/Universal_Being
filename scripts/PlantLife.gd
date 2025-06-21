extends Node3D
class_name PlantLife

# Living plants that robots can tend and harvest
# "Each plant is a small universe, breathing with the garden's rhythm"

signal growth_stage_changed(new_stage: int)
signal fruit_ripened(fruit: Node3D)
signal plant_health_changed(health: float)

@export var plant_type: String = "tomato"
@export var growth_rate: float = 0.1
@export var water_consumption: float = 0.05
@export var max_fruits: int = 3

# Plant state
enum GrowthStage { SEED, SPROUT, GROWING, MATURE, FLOWERING, FRUITING }
var current_stage: GrowthStage = GrowthStage.SEED
var health: float = 1.0
var water_level: float = 0.5
var nutrients: float = 0.7
var age: float = 0.0

# Visual components
@onready var plant_mesh: MeshInstance3D = $PlantMesh
@onready var stem_mesh: MeshInstance3D = $StemMesh
@onready var fruit_container: Node3D = $FruitContainer

# Growth and fruiting
var fruits: Array[Node3D] = []
var stage_timers: Dictionary = {
	GrowthStage.SEED: 5.0,
	GrowthStage.SPROUT: 10.0,
	GrowthStage.GROWING: 15.0,
	GrowthStage.MATURE: 20.0,
	GrowthStage.FLOWERING: 10.0,
	GrowthStage.FRUITING: 25.0
}

var stage_timer: float = 0.0

func _ready():
	add_to_group("plants")
	_setup_plant_visuals()
	_set_metadata()

func _process(delta):
	age += delta
	stage_timer += delta
	
	# Consume resources
	water_level = max(water_level - water_consumption * delta, 0.0)
	
	# Health calculation
	_update_health()
	
	# Growth progression
	_update_growth(delta)
	
	# Visual updates
	_update_appearance()

func _setup_plant_visuals():
	# Create basic plant structure
	if not plant_mesh:
		plant_mesh = MeshInstance3D.new()
		add_child(plant_mesh)
		plant_mesh.name = "PlantMesh"
	
	if not stem_mesh:
		stem_mesh = MeshInstance3D.new()
		add_child(stem_mesh)
		stem_mesh.name = "StemMesh"
	
	if not fruit_container:
		fruit_container = Node3D.new()
		add_child(fruit_container)
		fruit_container.name = "FruitContainer"
	
	_update_mesh_for_stage()

func _set_metadata():
	# Set metadata for robot detection
	set_meta("plant_type", plant_type)
	set_meta("health", health)
	set_meta("water_level", water_level)
	set_meta("nutrients", nutrients)
	set_meta("growth_stage", current_stage)

func _update_health():
	var old_health = health
	
	# Health factors
	var water_factor = clamp(water_level * 2.0, 0.0, 1.0)
	var nutrient_factor = clamp(nutrients, 0.0, 1.0)
	var age_factor = 1.0 - clamp(age / 200.0, 0.0, 0.5)  # Slight aging effect
	
	health = (water_factor + nutrient_factor + age_factor) / 3.0
	health = clamp(health, 0.0, 1.0)
	
	# Update metadata
	set_meta("health", health)
	set_meta("water_level", water_level)
	set_meta("nutrients", nutrients)
	
	if abs(health - old_health) > 0.05:
		plant_health_changed.emit(health)

func _update_growth(delta):
	if health < 0.2:
		return  # Too unhealthy to grow
	
	var stage_duration = stage_timers.get(current_stage, 10.0)
	var growth_speed = growth_rate * health  # Health affects growth speed
	
	if stage_timer >= stage_duration / growth_speed:
		_advance_growth_stage()

func _advance_growth_stage():
	var old_stage = current_stage
	
	match current_stage:
		GrowthStage.SEED:
			current_stage = GrowthStage.SPROUT
		GrowthStage.SPROUT:
			current_stage = GrowthStage.GROWING
		GrowthStage.GROWING:
			current_stage = GrowthStage.MATURE
		GrowthStage.MATURE:
			current_stage = GrowthStage.FLOWERING
		GrowthStage.FLOWERING:
			current_stage = GrowthStage.FRUITING
			_start_fruit_production()
		GrowthStage.FRUITING:
			# Continue fruiting, maybe cycle back to flowering
			if randf() < 0.3:
				current_stage = GrowthStage.FLOWERING
	
	stage_timer = 0.0
	_update_mesh_for_stage()
	set_meta("growth_stage", current_stage)
	
	growth_stage_changed.emit(current_stage)
	print("🌱 ", plant_type, " advanced to stage: ", GrowthStage.keys()[current_stage])

func _update_mesh_for_stage():
	if not plant_mesh or not stem_mesh:
		return
	
	# Create meshes based on growth stage
	match current_stage:
		GrowthStage.SEED:
			_create_seed_mesh()
		GrowthStage.SPROUT:
			_create_sprout_mesh()
		GrowthStage.GROWING:
			_create_growing_mesh()
		GrowthStage.MATURE:
			_create_mature_mesh()
		GrowthStage.FLOWERING:
			_create_flowering_mesh()
		GrowthStage.FRUITING:
			_create_fruiting_mesh()

func _create_seed_mesh():
	var mesh = SphereMesh.new()
	mesh.radius = 0.1
	mesh.height = 0.2
	plant_mesh.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.SADDLE_BROWN
	plant_mesh.material_override = material
	
	plant_mesh.scale = Vector3.ONE * 0.3

func _create_sprout_mesh():
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = 0.08
	mesh.height = 0.3
	stem_mesh.mesh = mesh
	
	var mesh2 = SphereMesh.new()
	mesh2.radius = 0.15
	mesh2.height = 0.3
	plant_mesh.mesh = mesh2
	plant_mesh.position.y = 0.2
	
	_apply_plant_material(Color.LIME_GREEN)
	plant_mesh.scale = Vector3.ONE * 0.5

func _create_growing_mesh():
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.08
	mesh.bottom_radius = 0.12
	mesh.height = 0.6
	stem_mesh.mesh = mesh
	
	var mesh2 = BoxMesh.new()
	mesh2.size = Vector3(0.8, 0.1, 0.6)
	plant_mesh.mesh = mesh2
	plant_mesh.position.y = 0.4
	
	_apply_plant_material(Color.FOREST_GREEN)
	plant_mesh.scale = Vector3.ONE * 0.8

func _create_mature_mesh():
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.1
	mesh.bottom_radius = 0.15
	mesh.height = 1.0
	stem_mesh.mesh = mesh
	
	var mesh2 = SphereMesh.new()
	mesh2.radius = 0.4
	mesh2.height = 0.8
	plant_mesh.mesh = mesh2
	plant_mesh.position.y = 0.6
	
	_apply_plant_material(Color.DARK_GREEN)
	plant_mesh.scale = Vector3.ONE

func _create_flowering_mesh():
	_create_mature_mesh()
	
	# Add flower visuals
	_add_flowers()

func _create_fruiting_mesh():
	_create_mature_mesh()
	
	# Flowers become fruits
	_remove_flowers()

func _add_flowers():
	# Create small flower spheres
	for i in range(3):
		var flower = MeshInstance3D.new()
		var mesh = SphereMesh.new()
		mesh.radius = 0.08
		mesh.height = 0.16
		flower.mesh = mesh
		
		var material = StandardMaterial3D.new()
		material.albedo_color = _get_flower_color()
		material.emission_enabled = true
		material.emission = material.albedo_color
		material.emission_energy = 0.3
		flower.material_override = material
		
		var angle = (PI * 2.0 * i) / 3.0
		flower.position = Vector3(cos(angle) * 0.3, 0.1, sin(angle) * 0.3)
		plant_mesh.add_child(flower)

func _remove_flowers():
	# Remove flower children from plant mesh
	for child in plant_mesh.get_children():
		if child is MeshInstance3D:
			child.queue_free()

func _get_flower_color() -> Color:
	match plant_type:
		"tomato":
			return Color.YELLOW
		"strawberry":
			return Color.WHITE
		"apple":
			return Color.PINK
		_:
			return Color.WHITE

func _apply_plant_material(color: Color):
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	
	# Health affects color
	if health < 0.3:
		material.albedo_color = material.albedo_color.lerp(Color.BROWN, 0.5)
	elif health < 0.6:
		material.albedo_color = material.albedo_color.lerp(Color.YELLOW, 0.3)
	
	plant_mesh.material_override = material
	
	# Stem material
	var stem_material = StandardMaterial3D.new()
	stem_material.albedo_color = Color.SADDLE_BROWN.lerp(Color.GREEN, 0.3)
	stem_material.roughness = 0.8
	stem_mesh.material_override = stem_material

func _start_fruit_production():
	# Begin producing fruits over time
	var timer = Timer.new()
	timer.wait_time = randf_range(5.0, 10.0)
	timer.timeout.connect(_produce_fruit)
	timer.autostart = true
	add_child(timer)

func _produce_fruit():
	if fruits.size() >= max_fruits:
		return
	
	if health < 0.4:
		return  # Too unhealthy to fruit
	
	var fruit = _create_fruit()
	fruits.append(fruit)
	fruit_container.add_child(fruit)
	
	print("🍎 ", plant_type, " produced a fruit")

func _create_fruit() -> Node3D:
	var fruit = StaticBody3D.new()
	fruit.add_to_group("fruits")
	
	var mesh_instance = MeshInstance3D.new()
	var collision = CollisionShape3D.new()
	
	# Fruit appearance based on plant type
	match plant_type:
		"tomato":
			_setup_tomato_fruit(mesh_instance, collision)
		"strawberry":
			_setup_strawberry_fruit(mesh_instance, collision)
		"apple":
			_setup_apple_fruit(mesh_instance, collision)
		_:
			_setup_generic_fruit(mesh_instance, collision)
	
	fruit.add_child(mesh_instance)
	fruit.add_child(collision)
	
	# Set fruit metadata
	fruit.set_meta("fruit_type", plant_type)
	fruit.set_meta("ripeness", 0.1)  # Start unripe
	fruit.set_meta("size", randf_range(0.8, 1.2))
	fruit.set_meta("color_quality", randf_range(0.7, 1.0))
	fruit.set_meta("stem_thickness", randf_range(0.5, 1.0))
	
	# Position fruit around plant
	var angle = randf() * PI * 2.0
	var radius = randf_range(0.2, 0.4)
	fruit.position = Vector3(cos(angle) * radius, randf_range(0.2, 0.6), sin(angle) * radius)
	
	# Start ripening process
	_start_fruit_ripening(fruit)
	
	return fruit

func _setup_tomato_fruit(mesh_instance: MeshInstance3D, collision: CollisionShape3D):
	var mesh = SphereMesh.new()
	mesh.radius = 0.12
	mesh.height = 0.24
	mesh_instance.mesh = mesh
	
	var shape = SphereShape3D.new()
	shape.radius = 0.12
	collision.shape = shape
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.GREEN  # Starts green, turns red when ripe
	mesh_instance.material_override = material

func _setup_strawberry_fruit(mesh_instance: MeshInstance3D, collision: CollisionShape3D):
	var mesh = SphereMesh.new()
	mesh.radius = 0.08
	mesh.height = 0.12
	mesh_instance.mesh = mesh
	
	var shape = SphereShape3D.new()
	shape.radius = 0.08
	collision.shape = shape
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.PINK  # Starts pink, turns red
	mesh_instance.material_override = material

func _setup_apple_fruit(mesh_instance: MeshInstance3D, collision: CollisionShape3D):
	var mesh = SphereMesh.new()
	mesh.radius = 0.15
	mesh.height = 0.2
	mesh_instance.mesh = mesh
	
	var shape = SphereShape3D.new()
	shape.radius = 0.15
	collision.shape = shape
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.LIME_GREEN  # Starts green, turns red/yellow
	mesh_instance.material_override = material

func _setup_generic_fruit(mesh_instance: MeshInstance3D, collision: CollisionShape3D):
	var mesh = SphereMesh.new()
	mesh.radius = 0.1
	mesh.height = 0.15
	mesh_instance.mesh = mesh
	
	var shape = SphereShape3D.new()
	shape.radius = 0.1
	collision.shape = shape
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.GREEN
	mesh_instance.material_override = material

func _start_fruit_ripening(fruit: Node3D):
	var ripen_timer = Timer.new()
	ripen_timer.wait_time = 1.0  # Update every second
	ripen_timer.timeout.connect(_ripen_fruit.bind(fruit))
	ripen_timer.autostart = true
	fruit.add_child(ripen_timer)

func _ripen_fruit(fruit: Node3D):
	if not is_instance_valid(fruit):
		return
	
	var ripeness = fruit.get_meta("ripeness", 0.0)
	ripeness += randf_range(0.01, 0.03)  # Gradual ripening
	fruit.set_meta("ripeness", min(ripeness, 1.0))
	
	# Update fruit color based on ripeness
	var mesh_instance = fruit.get_child(0) as MeshInstance3D
	if mesh_instance and mesh_instance.material_override:
		var material = mesh_instance.material_override as StandardMaterial3D
		_update_fruit_color(material, ripeness)
	
	# Emit signal when fully ripe
	if ripeness >= 0.7 and not fruit.get_meta("ripe_signaled", false):
		fruit.set_meta("ripe_signaled", true)
		fruit_ripened.emit(fruit)

func _update_fruit_color(material: StandardMaterial3D, ripeness: float):
	match plant_type:
		"tomato":
			# Green to red
			material.albedo_color = Color.GREEN.lerp(Color.RED, ripeness)
		"strawberry":
			# Pink to deep red
			material.albedo_color = Color.PINK.lerp(Color.DARK_RED, ripeness)
		"apple":
			# Green to red/yellow mix
			var ripe_color = Color.RED.lerp(Color.YELLOW, 0.3)
			material.albedo_color = Color.LIME_GREEN.lerp(ripe_color, ripeness)
		_:
			# Generic green to red
			material.albedo_color = Color.GREEN.lerp(Color.RED, ripeness)

func _update_appearance():
	# Update plant appearance based on health and growth
	if plant_mesh and plant_mesh.material_override:
		var material = plant_mesh.material_override as StandardMaterial3D
		if material:
			# Breathing animation for healthy plants
			if health > 0.6:
				var breathe = sin(age * 2.0) * 0.05 + 1.0
				plant_mesh.scale = Vector3.ONE * breathe
			
			# Wilt if unhealthy
			if health < 0.3:
				plant_mesh.rotation.z = sin(age) * 0.1  # Slight droop

# Care functions for robots
func water_plant(amount: float):
	water_level = min(water_level + amount, 1.0)
	print("💧 ", plant_type, " was watered (level: ", water_level, ")")

func add_nutrients(amount: float):
	nutrients = min(nutrients + amount, 1.0)
	print("🌿 ", plant_type, " received nutrients (level: ", nutrients, ")")

func prune_plant():
	# Pruning improves health
	health = min(health + 0.1, 1.0)
	print("✂️ ", plant_type, " was pruned (health: ", health, ")")

func get_plant_status() -> Dictionary:
	return {
		"type": plant_type,
		"health": health,
		"water_level": water_level,
		"nutrients": nutrients,
		"growth_stage": GrowthStage.keys()[current_stage],
		"age": age,
		"fruit_count": fruits.size()
	}