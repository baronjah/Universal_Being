# MiningSystem.gd
extends UniversalBeing
class_name MiningSystem

# Mining events
signal mining_started(asteroid: Asteroid, player: PlayerShip)
signal ore_extracted(ore_type: String, amount: float)
signal asteroid_depleted(asteroid: Asteroid)
signal rare_ore_discovered(ore_type: String, location: Vector3)
signal mining_interrupted()
signal scan_completed(asteroid: Asteroid, composition: Dictionary)

# Mining configuration
@export var base_mining_power: float = 10.0
@export var mining_range: float = 50.0
@export var energy_cost_per_second: float = 5.0
@export var scan_duration: float = 2.0
@export var extraction_particle_count: int = 50

# Ore types and properties
var ore_types: Dictionary = {
	# Common ores
	"iron": {
		"color": Color(0.5, 0.5, 0.5),
		"density": 1.0,
		"value": 1,
		"hardness": 0.5
	},
	"copper": {
		"color": Color(0.8, 0.4, 0.2),
		"density": 1.2,
		"value": 2,
		"hardness": 0.6
	},
	"gold": {
		"color": Color(1.0, 0.8, 0.0),
		"density": 2.0,
		"value": 10,
		"hardness": 0.3
	},
	# Consciousness ores
	"resonite": {
		"color": Color(0.0, 0.8, 1.0),
		"density": 0.5,
		"value": 50,
		"hardness": 1.0,
		"consciousness": true,
		"frequency": 432.0,
		"effect": "awareness_boost"
	},
	"voidstone": {
		"color": Color(0.1, 0.0, 0.2),
		"density": 3.0,
		"value": 100,
		"hardness": 2.0,
		"consciousness": true,
		"frequency": 0.0,
		"effect": "void_meditation"
	},
	"stellarium": {
		"color": Color(1.0, 1.0, 0.8),
		"density": 0.1,
		"value": 200,
		"hardness": 0.8,
		"consciousness": true,
		"frequency": 528.0,
		"effect": "stellar_connection"
	}
}

# Active mining state
var active_mining_sessions: Dictionary = {} # player -> mining_data
var scanning_asteroids: Dictionary = {} # asteroid -> scan_progress

# Visual effects pool
var mining_beam_pool: Array[MiningBeam] = []
var extraction_particle_pool: Array[GPUParticles3D] = []
var scan_effect_pool: Array[MeshInstance3D] = []

# Asteroid management
var registered_asteroids: Dictionary = {} # asteroid -> data
var depleted_asteroids: Array = []

# Upgrade levels
var mining_efficiency: float = 1.0
var scan_speed: float = 1.0
var rare_ore_chance_multiplier: float = 1.0

# Pentagon implementation
func pentagon_init() -> void:
	super.pentagon_init()
	name = "MiningSystem"
	_initialize_ore_database()
	_create_effect_pools()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_register_with_systems()
	_load_mining_upgrades()
	set_process(true)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_process_active_mining(delta)
	_process_scanning(delta)
	_update_visual_effects(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Mining system doesn't need direct input

func pentagon_sewers() -> void:
	_cleanup_mining_sessions()
	_save_mining_state()
	super.pentagon_sewers()

# Initialization
func _initialize_ore_database() -> void:
	# Expand ore types with procedural variations
	for ore_name in ore_types:
		var base_ore = ore_types[ore_name]
		# Add quality variations
		for quality in ["poor", "normal", "rich", "pure"]:
			if quality != "normal":
				var variant_name = quality + "_" + ore_name
				ore_types[variant_name] = base_ore.duplicate()
				match quality:
					"poor":
						ore_types[variant_name]["value"] *= 0.5
						ore_types[variant_name]["density"] *= 0.7
					"rich":
						ore_types[variant_name]["value"] *= 2.0
						ore_types[variant_name]["density"] *= 1.3
					"pure":
						ore_types[variant_name]["value"] *= 5.0
						ore_types[variant_name]["density"] *= 1.5

func _create_effect_pools() -> void:
	# Pre-create visual effects for performance
	for i in range(10):
		_create_mining_beam()
		_create_scan_effect()
	
	for i in range(extraction_particle_count):
		_create_extraction_particles()

func _create_mining_beam() -> MiningBeam:
	var beam = MiningBeam.new()
	beam.visible = false
	add_child(beam)
	mining_beam_pool.append(beam)
	return beam

func _create_extraction_particles() -> GPUParticles3D:
	var particles = GPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 2.0
	particles.visibility_aabb = AABB(Vector3(-5, -5, -5), Vector3(10, 10, 10))
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 1, 0)
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	material.angular_velocity_min = -180.0
	material.angular_velocity_max = 180.0
	material.spread = 30.0
	material.gravity = Vector3(0, -2, 0)
	material.scale_min = 0.1
	material.scale_max = 0.3
	
	particles.process_material = material
	particles.draw_pass_1 = SphereMesh.new()
	particles.draw_pass_1.radius = 0.1
	particles.draw_pass_1.height = 0.2
	particles.visible = false
	
	add_child(particles)
	extraction_particle_pool.append(particles)
	return particles

func _create_scan_effect() -> MeshInstance3D:
	var scan_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	scan_mesh.mesh = sphere
	
	var scan_material = StandardMaterial3D.new()
	scan_material.albedo_color = Color(0.0, 1.0, 0.5, 0.3)
	scan_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	scan_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	scan_material.emission_enabled = true
	scan_material.emission = Color(0.0, 1.0, 0.5)
	scan_material.emission_energy = 0.5
	scan_material.rim_enabled = true
	scan_material.rim = 1.0
	scan_mesh.material_override = scan_material
	scan_mesh.visible = false
	
	add_child(scan_mesh)
	scan_effect_pool.append(scan_mesh)
	return scan_mesh

func _register_with_systems() -> void:
	# Register with FloodGates
	if FloodGates:
		FloodGates.register_being(self)
	
	# Connect to consciousness system for ore effects
	var consciousness_system = get_node_or_null("/root/SpaceGame/ConsciousnessSystem")
	if consciousness_system:
		rare_ore_discovered.connect(consciousness_system._on_rare_ore_discovered)

# Mining operations
func start_mining(player: PlayerShip, asteroid: Asteroid) -> bool:
	if not _validate_mining_conditions(player, asteroid):
		return false
	
	# Create mining session
	var mining_data = {
		"asteroid": asteroid,
		"start_time": Time.get_ticks_msec(),
		"extracted": {},
		"beam": _get_available_beam(),
		"particles": []
	}
	
	active_mining_sessions[player] = mining_data
	
	# Setup visual effects
	if mining_data["beam"]:
		mining_data["beam"].setup(player, asteroid)
		mining_data["beam"].visible = true
	
	# Start extraction particles
	_start_extraction_particles(asteroid, mining_data)
	
	mining_started.emit(asteroid, player)
	return true

func stop_mining(player: PlayerShip) -> void:
	if not active_mining_sessions.has(player):
		return
	
	var mining_data = active_mining_sessions[player]
	
	# Hide visual effects
	if mining_data["beam"]:
		mining_data["beam"].visible = false
	
	for particles in mining_data["particles"]:
		particles.emitting = false
		particles.visible = false
	
	# Report extracted resources
	for ore_type in mining_data["extracted"]:
		ore_extracted.emit(ore_type, mining_data["extracted"][ore_type])
	
	active_mining_sessions.erase(player)
	mining_interrupted.emit()

func _validate_mining_conditions(player: PlayerShip, asteroid: Asteroid) -> bool:
	# Check range
	var distance = player.global_position.distance_to(asteroid.global_position)
	if distance > mining_range:
		return false
	
	# Check if asteroid is depleted
	if asteroid in depleted_asteroids:
		return false
	
	# Check if player has energy
	if player.energy < energy_cost_per_second:
		return false
	
	return true

func _process_active_mining(delta: float) -> void:
	var to_remove = []
	
	for player in active_mining_sessions:
		var mining_data = active_mining_sessions[player]
		var asteroid = mining_data["asteroid"]
		
		# Validate continued mining
		if not is_instance_valid(player) or not is_instance_valid(asteroid):
			to_remove.append(player)
			continue
		
		if not _validate_mining_conditions(player, asteroid):
			to_remove.append(player)
			continue
		
		# Consume energy
		player._consume_energy(energy_cost_per_second * delta)
		
		# Calculate mining power
		var power = _calculate_mining_power(player, asteroid)
		
		# Extract ores
		var extracted_this_frame = _extract_ores(asteroid, power * delta, mining_data)
		
		# Check if asteroid is depleted
		if asteroid.is_depleted():
			_on_asteroid_depleted(asteroid)
			to_remove.append(player)
		
		# Update visual effects
		_update_mining_visuals(mining_data, asteroid)
	
	# Clean up finished sessions
	for player in to_remove:
		stop_mining(player)

func _calculate_mining_power(player: PlayerShip, asteroid: Asteroid) -> float:
	var power = base_mining_power * mining_efficiency
	
	# Player consciousness affects mining
	power *= (1.0 + player.consciousness_level * 0.1)
	
	# Asteroid hardness affects extraction
	var avg_hardness = asteroid.get_average_hardness()
	power /= (1.0 + avg_hardness)
	
	return power

func _extract_ores(asteroid: Asteroid, amount: float, mining_data: Dictionary) -> Dictionary:
	var extracted = {}
	var composition = asteroid.get_composition()
	
	for ore_type in composition:
		if not ore_types.has(ore_type):
			continue
		
		var ore_amount = composition[ore_type]
		var extract_amount = min(ore_amount, amount * ore_types[ore_type]["density"])
		
		if extract_amount > 0:
			# Extract from asteroid
			asteroid.extract_ore(ore_type, extract_amount)
			
			# Add to session total
			if not mining_data["extracted"].has(ore_type):
				mining_data["extracted"][ore_type] = 0
			mining_data["extracted"][ore_type] += extract_amount
			
			extracted[ore_type] = extract_amount
			
			# Emit individual extraction
			ore_extracted.emit(ore_type, extract_amount)
			
			# Check for rare ore discovery
			if ore_types[ore_type].has("consciousness") and extract_amount > 0:
				rare_ore_discovered.emit(ore_type, asteroid.global_position)
	
	return extracted

# Scanning system
func scan_asteroid(player: PlayerShip, asteroid: Asteroid) -> void:
	if scanning_asteroids.has(asteroid):
		return # Already scanning
	
	var scan_data = {
		"player": player,
		"progress": 0.0,
		"effect": _get_available_scan_effect()
	}
	
	scanning_asteroids[asteroid] = scan_data
	
	# Start scan visual
	if scan_data["effect"]:
		scan_data["effect"].global_position = asteroid.global_position
		scan_data["effect"].scale = Vector3.ONE * asteroid.get_radius()
		scan_data["effect"].visible = true

func _process_scanning(delta: float) -> void:
	var completed_scans = []
	
	for asteroid in scanning_asteroids:
		var scan_data = scanning_asteroids[asteroid]
		
		# Update progress
		scan_data["progress"] += delta * scan_speed / scan_duration
		
		if scan_data["progress"] >= 1.0:
			_complete_scan(asteroid, scan_data)
			completed_scans.append(asteroid)
		else:
			# Update visual effect
			if scan_data["effect"]:
				var pulse = sin(scan_data["progress"] * PI * 4) * 0.2 + 1.0
				scan_data["effect"].scale = Vector3.ONE * asteroid.get_radius() * pulse
	
	# Remove completed scans
	for asteroid in completed_scans:
		var scan_data = scanning_asteroids[asteroid]
		if scan_data["effect"]:
			scan_data["effect"].visible = false
		scanning_asteroids.erase(asteroid)

func _complete_scan(asteroid: Asteroid, scan_data: Dictionary) -> void:
	var composition = asteroid.get_detailed_composition()
	
	# Enhance composition data with ore properties
	for ore_type in composition:
		if ore_types.has(ore_type):
			composition[ore_type]["properties"] = ore_types[ore_type]
	
	scan_completed.emit(asteroid, composition)
	
	# Save scan to akashic records
	if AkashicRecordsSystem:
		AkashicRecordsSystem.save_scan_data({
			"asteroid_id": asteroid.get_instance_id(),
			"position": asteroid.global_position,
			"composition": composition,
			"scan_time": Time.get_unix_time_from_system()
		})

# Visual effects
func _start_extraction_particles(asteroid: Asteroid, mining_data: Dictionary) -> void:
	# Get ore colors for particles
	var ore_colors = []
	var composition = asteroid.get_composition()
	for ore_type in composition:
		if ore_types.has(ore_type):
			ore_colors.append(ore_types[ore_type]["color"])
	
	if ore_colors.is_empty():
		ore_colors = [Color.GRAY]
	
	# Start multiple particle emitters
	for i in range(3):
		var particles = _get_available_particles()
		if particles:
			particles.global_position = asteroid.global_position
			particles.process_material.color = ore_colors[i % ore_colors.size()]
			particles.emitting = true
			particles.visible = true
			mining_data["particles"].append(particles)

func _update_mining_visuals(mining_data: Dictionary, asteroid: Asteroid) -> void:
	# Update beam position
	if mining_data["beam"]:
		mining_data["beam"].update_positions()
	
	# Randomize particle positions on asteroid surface
	for particles in mining_data["particles"]:
		if randf() < 0.1: # 10% chance per frame
			var random_surface_point = asteroid.get_random_surface_point()
			particles.global_position = random_surface_point

func _update_visual_effects(delta: float) -> void:
	# Update active mining beams
	for session in active_mining_sessions.values():
		if session["beam"]:
			session["beam"].update_animation(delta)

# Asteroid management
func register_asteroid(asteroid: Asteroid) -> void:
	if not registered_asteroids.has(asteroid):
		registered_asteroids[asteroid] = {
			"initial_composition": asteroid.get_composition().duplicate(),
			"total_extracted": {},
			"discovered_ores": []
		}

func _on_asteroid_depleted(asteroid: Asteroid) -> void:
	depleted_asteroids.append(asteroid)
	asteroid_depleted.emit(asteroid)
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property(asteroid, "modulate:a", 0.3, 1.0)

# Effect pool management
func _get_available_beam() -> MiningBeam:
	for beam in mining_beam_pool:
		if not beam.visible:
			return beam
	
	# Create new if none available
	return _create_mining_beam()

func _get_available_particles() -> GPUParticles3D:
	for particles in extraction_particle_pool:
		if not particles.visible:
			return particles
	
	return _create_extraction_particles()

func _get_available_scan_effect() -> MeshInstance3D:
	for effect in scan_effect_pool:
		if not effect.visible:
			return effect
	
	return _create_scan_effect()

# Upgrades
func upgrade_mining_power(multiplier: float) -> void:
	mining_efficiency *= multiplier

func upgrade_scan_speed(multiplier: float) -> void:
	scan_speed *= multiplier

func upgrade_rare_ore_chance(multiplier: float) -> void:
	rare_ore_chance_multiplier *= multiplier

# Save/Load
func _save_mining_state() -> void:
	if AkashicRecordsSystem:
		var save_data = {
			"mining_efficiency": mining_efficiency,
			"scan_speed": scan_speed,
			"rare_ore_multiplier": rare_ore_chance_multiplier,
			"depleted_asteroids": []
		}
		
		# Save depleted asteroid positions
		for asteroid in depleted_asteroids:
			if is_instance_valid(asteroid):
				save_data["depleted_asteroids"].append(asteroid.global_position)
		
		AkashicRecordsSystem.save_mining_system_data(save_data)

func _load_mining_upgrades() -> void:
	if AkashicRecordsSystem:
		var save_data = AkashicRecordsSystem.get_mining_system_data()
		if save_data:
			mining_efficiency = save_data.get("mining_efficiency", 1.0)
			scan_speed = save_data.get("scan_speed", 1.0)
			rare_ore_chance_multiplier = save_data.get("rare_ore_multiplier", 1.0)

# Cleanup
func _cleanup_mining_sessions() -> void:
	for player in active_mining_sessions:
		stop_mining(player)

# Helper classes
class MiningBeam extends MeshInstance3D:
	var source: Node3D
	var target: Node3D
	var beam_material: ShaderMaterial
	var time: float = 0.0
	
	func _init():
		# Create beam mesh
		var cylinder = CylinderMesh.new()
		cylinder.top_radius = 0.5
		cylinder.bottom_radius = 2.0
		cylinder.height = 1.0
		mesh = cylinder
		
		# Create beam shader
		beam_material = ShaderMaterial.new()
		beam_material.shader = preload("res://shaders/mining_beam.gdshader")
		material_override = beam_material
	
	func setup(p_source: Node3D, p_target: Node3D) -> void:
		source = p_source
		target = p_target
		update_positions()
	
	func update_positions() -> void:
		if not source or not target:
			return
		
		# Position beam between source and target
		global_position = (source.global_position + target.global_position) / 2.0
		
		# Point at target
		look_at(target.global_position, Vector3.UP)
		rotate_x(PI/2) # Cylinder points up by default
		
		# Scale to reach
		var distance = source.global_position.distance_to(target.global_position)
		var cylinder = mesh as CylinderMesh
		cylinder.height = distance
		scale.y = 1.0 # Reset scale
	
	func update_animation(delta: float) -> void:
		time += delta
		if beam_material:
			beam_material.set_shader_parameter("time", time)

# Public API for game
func mine_asteroid(asteroid: Asteroid) -> Dictionary:
	# Simple mine function for direct use
	if not is_instance_valid(asteroid):
		return {"success": false, "reason": "Invalid asteroid"}
	
	if asteroid.is_depleted():
		return {"success": false, "reason": "Asteroid depleted"}
	
	# Extract a chunk of resources
	var power = base_mining_power * mining_efficiency
	var extracted = _extract_ores(asteroid, power, {"extracted": {}})
	
	return {"success": true, "extracted": extracted}

func get_asteroid_scan_data(asteroid: Asteroid) -> Dictionary:
	if registered_asteroids.has(asteroid):
		return registered_asteroids[asteroid]
	return {}

# Get mining statistics
func get_mining_stats() -> Dictionary:
	var total_extracted = {}
	for asteroid_data in registered_asteroids.values():
		for ore_type in asteroid_data["total_extracted"]:
			if not total_extracted.has(ore_type):
				total_extracted[ore_type] = 0
			total_extracted[ore_type] += asteroid_data["total_extracted"][ore_type]
	
	return {
		"total_asteroids_mined": registered_asteroids.size(),
		"depleted_asteroids": depleted_asteroids.size(),
		"total_extracted": total_extracted,
		"mining_efficiency": mining_efficiency,
		"scan_speed": scan_speed
	}
