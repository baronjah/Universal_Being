# mining_system.gd
extends Node
class_name MiningSystem

signal mining_started(target: Node3D)
signal ore_extracted(ore_type: String, amount: float)
signal rare_ore_discovered(ore_type: String, location: Vector3)
signal mining_tool_upgraded(tool_type: String, level: int)

# Mining mechanics
var mining_tools: Dictionary = {
	"basic_laser": {"power": 1.0, "efficiency": 0.5, "range": 50.0},
	"advanced_laser": {"power": 2.5, "efficiency": 0.7, "range": 75.0},
	"quantum_drill": {"power": 5.0, "efficiency": 0.9, "range": 100.0}
}

var current_tool: String = "basic_laser"
var mining_skill: float = 1.0
var ore_inventory: Dictionary = {}

# Special ores with consciousness properties
var consciousness_ores: Dictionary = {
	"Resonite": {"frequency": 432.0, "consciousness_boost": 0.1},
	"Voidstone": {"frequency": 0.0, "consciousness_boost": -0.05},
	"Stellarium": {"frequency": 528.0, "consciousness_boost": 0.2},
	"Akashite": {"frequency": 963.0, "consciousness_boost": 0.3}
}

class Asteroid:
	var ore_composition: Dictionary = {}
	var total_ore: float = 100.0
	var consciousness_ore_chance: float = 0.1
	
	func _init():
		generate_composition()
		
	func generate_composition():
		# Standard ores
		ore_composition["Iron"] = randf_range(20, 40)
		ore_composition["Nickel"] = randf_range(10, 30)
		ore_composition["Platinum"] = randf_range(5, 15)
		
		# Rare consciousness ore
		if randf() < consciousness_ore_chance:
			var consciousness_ore = ["Resonite", "Voidstone", "Stellarium", "Akashite"][randi() % 4]
			ore_composition[consciousness_ore] = randf_range(1, 5)

func _ready():
	initialize_mining_system()
	
func initialize_mining_system():
	# Set up initial ore inventory
	ore_inventory = {
		"Iron": 0.0,
		"Nickel": 0.0,
		"Platinum": 0.0
	}
	
func start_mining(asteroid: Asteroid) -> Dictionary:
	if not asteroid:
		return {"success": false, "reason": "No target"}
		
	mining_started.emit(asteroid)
	
	var tool_stats = mining_tools[current_tool]
	var mining_power = tool_stats["power"] * mining_skill
	var extraction_rate = tool_stats["efficiency"]
	
	# Calculate ore extraction
	var extracted_ores = {}
	for ore_type in asteroid.ore_composition:
		var available = asteroid.ore_composition[ore_type]
		var extracted = min(available, mining_power * extraction_rate)
		
		extracted_ores[ore_type] = extracted
		asteroid.ore_composition[ore_type] -= extracted
		
		# Add to inventory
		if not ore_inventory.has(ore_type):
			ore_inventory[ore_type] = 0.0
		ore_inventory[ore_type] += extracted
		
		ore_extracted.emit(ore_type, extracted)
		
		# Check for rare ore discovery
		if ore_type in consciousness_ores and extracted > 0:
			rare_ore_discovered.emit(ore_type, asteroid.global_position)
			
	asteroid.total_ore -= extracted_ores.values().reduce(func(a, b): return a + b, 0.0)
	
	return {"success": true, "extracted": extracted_ores}
	
func scan_asteroid(asteroid: Asteroid) -> Dictionary:
	# Scanning reveals composition and increases yield
	var scan_results = {
		"composition": asteroid.ore_composition.duplicate(),
		"total_ore": asteroid.total_ore,
		"consciousness_signature": false
	}
	
	# Check for consciousness ores
	for ore_type in asteroid.ore_composition:
		if ore_type in consciousness_ores:
			scan_results["consciousness_signature"] = true
			scan_results["consciousness_frequency"] = consciousness_ores[ore_type]["frequency"]
			break
			
	return scan_results
	
func refine_ore(ore_type: String, amount: float) -> Dictionary:
	if not ore_inventory.has(ore_type) or ore_inventory[ore_type] < amount:
		return {"success": false, "reason": "Insufficient ore"}
		
	ore_inventory[ore_type] -= amount
	
	# Refining process
	var refined_output = amount * 0.8  # 80% efficiency
	var byproducts = {}
	
	# Special refining for consciousness ores
	if ore_type in consciousness_ores:
		refined_output *= 0.5  # Lower yield but special properties
		byproducts["Consciousness Essence"] = amount * 0.1
		
	return {
		"success": true,
		"refined": refined_output,
		"byproducts": byproducts
	}
	
func upgrade_mining_tool(tool_type: String):
	if mining_tools.has(tool_type):
		current_tool = tool_type
		mining_tool_upgraded.emit(tool_type, 1)
		
func calculate_mining_efficiency() -> float:
	var tool_stats = mining_tools[current_tool]
	return tool_stats["efficiency"] * mining_skill


# the thinking 1 ver
# mining_system.gd - Complete mining and resource management
#extends Node

# Resource types that connect to your space game
enum ResourceType {
	METAL,
	CRYSTAL,
	ENERGY,
	QUANTUM,
	DARK_MATTER,
	CONSCIOUSNESS_FRAGMENTS
}

# Asteroid/Resource node that works with your existing scenes
#class_name SpaceResource
#extends StaticBody3D

@export var resource_type: ResourceType = ResourceType.METAL
@export var resource_amount: float = 100.0
@export var mining_difficulty: float = 1.0
@export var respawn_time: float = 300.0  # 5 minutes

var is_depleted: bool = false
var visual_mesh: MeshInstance3D
var glow_effect: OmniLight3D
var original_scale: Vector3

signal resource_depleted
signal resource_mined(amount: float, type: ResourceType)

func pentagon_ready():
	add_to_group("resources")
	_setup_visuals()
	_setup_collision()

func _setup_visuals():
	visual_mesh = MeshInstance3D.new()
	add_child(visual_mesh)
	
	# Different meshes for different resources
	match resource_type:
		ResourceType.METAL:
			var mesh = BoxMesh.new()
			mesh.size = Vector3(5, 5, 5)
			visual_mesh.mesh = mesh
			_apply_metal_material()
		ResourceType.CRYSTAL:
			var mesh = CylinderMesh.new()
			mesh.height = 8
			mesh.radial_segments = 6
			visual_mesh.mesh = mesh
			_apply_crystal_material()
		ResourceType.ENERGY:
			var mesh = SphereMesh.new()
			mesh.radius = 3
			mesh.radial_segments = 32
			visual_mesh.mesh = mesh
			_apply_energy_material()
		ResourceType.QUANTUM:
			var mesh = TorusMesh.new()
			mesh.inner_radius = 2
			mesh.outer_radius = 4
			visual_mesh.mesh = mesh
			_apply_quantum_material()
	
	original_scale = scale
	
	# Add glow for valuable resources
	if resource_type >= ResourceType.QUANTUM:
		glow_effect = OmniLight3D.new()
		glow_effect.light_energy = 2.0
		glow_effect.omni_range = 20.0
		add_child(glow_effect)

func _apply_metal_material():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.6, 0.7)
	mat.metallic = 0.8
	mat.roughness = 0.3
	visual_mesh.material_override = mat

func _apply_crystal_material():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.7, 1.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.8
	mat.emission_enabled = true
	mat.emission = Color(0.3, 0.7, 1.0)
	mat.emission_energy = 0.5
	mat.rim_enabled = true
	mat.rim = 1.0
	mat.rim_tint = 0.5
	visual_mesh.material_override = mat

func _apply_energy_material():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 1.0, 0.3)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.9, 0.0)
	mat.emission_energy = 2.0
	visual_mesh.material_override = mat

func _apply_quantum_material():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.3, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.8, 0.3, 1.0)
	mat.emission_energy = 3.0
	# Animated effect
	mat.rim_enabled = true
	mat.rim = 1.0
	visual_mesh.material_override = mat

func _setup_collision():
	var shape = CollisionShape3D.new()
	var collision_shape = BoxShape3D.new()
	collision_shape.size = Vector3(5, 5, 5)
	shape.shape = collision_shape
	add_child(shape)

func mine(mining_power: float) -> Dictionary:
	if is_depleted:
		return {}
	
	# Calculate mined amount
	var efficiency = mining_power / mining_difficulty
	var mined = min(resource_amount, 10.0 * efficiency)
	resource_amount -= mined
	
	# Visual feedback
	_mining_effect()
	
	# Scale down as resources deplete
	var remaining_ratio = resource_amount / 100.0
	scale = original_scale * (0.3 + 0.7 * remaining_ratio)
	
	# Check if depleted
	if resource_amount <= 0:
		is_depleted = true
		resource_depleted.emit()
		_start_respawn_timer()
	
	# Return mined resources
	var result = {}
	result[resource_type] = mined
	resource_mined.emit(mined, resource_type)
	
	return result

func _mining_effect():
	# Create mining particles
	var particles = CPUParticles3D.new()
	particles.amount = 30
	particles.lifetime = 1.0
	particles.direction = Vector3.UP
	particles.spread = 45.0
	particles.initial_velocity_min = 5.0
	particles.initial_velocity_max = 15.0
	
	# Color based on resource
	match resource_type:
		ResourceType.METAL:
			particles.color = Color(0.7, 0.7, 0.7)
		ResourceType.CRYSTAL:
			particles.color = Color(0.3, 0.7, 1.0)
		ResourceType.ENERGY:
			particles.color = Color(1.0, 1.0, 0.0)
		ResourceType.QUANTUM:
			particles.color = Color(0.8, 0.3, 1.0)
	
	add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	
	# Clean up
	await particles.finished
	particles.queue_free()

func _start_respawn_timer():
	visible = false
	set_collision_layer_value(1, false)
	
	await get_tree().create_timer(respawn_time).timeout
	
	_respawn()

func _respawn():
	resource_amount = 100.0
	is_depleted = false
	visible = true
	set_collision_layer_value(1, true)
	scale = original_scale
	
	# Respawn effect
	var tween = create_tween()
	scale = Vector3.ZERO
	tween.tween_property(self, "scale", original_scale, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
