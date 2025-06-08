# StellarProgressionSystem.gd
extends UniversalBeing
class_name StellarProgressionSystem_Eden

# Stellar events
signal system_discovered(system_data: Dictionary)
signal star_chart_updated(new_systems: Array)
signal warp_jump_initiated(from_system: String, to_system: String)
signal warp_jump_completed()
signal anomaly_detected(anomaly: Dictionary)
signal navigation_route_calculated(route: Array)
signal stellar_phenomenon_observed(phenomenon: Dictionary)
signal consciousness_beacon_found(beacon_data: Dictionary)

# Galaxy configuration
@export var galaxy_seed: int = 12345
@export var galaxy_radius: float = 10000.0
@export var sector_size: float = 1000.0
@export var stars_per_sector: int = 5
@export var consciousness_beacon_chance: float = 0.1

# Navigation properties
@export var warp_drive_level: int = 1
@export var max_warp_range: float = 100.0
@export var warp_energy_cost: float = 50.0
@export var scan_radius: float = 200.0

# Current state
var current_system: StarSystem = null
var current_sector: Vector3 = Vector3.ZERO
var discovered_systems: Dictionary = {} # name -> StarSystem
var visited_systems: Array[String] = []
var active_route: Array = []
var is_warping: bool = false

# Stellar catalog
var star_catalog: Dictionary = {} # position hash -> StarSystem
var loaded_sectors: Dictionary = {} # sector -> systems array
var stellar_phenomena: Array = []

# Navigation data
var star_map_data: Dictionary = {}
var navigation_computer: NavigationComputer
var stellar_knowledge: float = 0.0

# Visual components
var star_map_3d: Node3D
var warp_effect: GPUParticles3D
var scan_visualizer: MeshInstance3D
var route_line_renderer: ImmediateMesh

# Consciousness beacons
var consciousness_beacons: Array = []
var beacon_connections: Dictionary = {}

# Star system class
class StarSystem:
	var name: String
	var position: Vector3
	var sector: Vector3
	var star_data: Dictionary
	var planets: Array = []
	var discovered: bool = false
	var visited: bool = false
	var resources: Dictionary = {}
	var phenomena: Array = []
	var consciousness_level: float = 0.0
	var has_consciousness_beacon: bool = false
	
	func _init(p_name: String, p_position: Vector3):
		name = p_name
		position = p_position
		sector = (position / 1000.0).floor()
		star_data = {
			"type": "G-Type",
			"mass": 1.0,
			"temperature": 5778,
			"luminosity": 1.0
		}
	
	func get_info() -> Dictionary:
		return {
			"name": name,
			"position": position,
			"star_type": star_data["type"],
			"planets": planets.size(),
			"discovered": discovered,
			"visited": visited,
			"consciousness_level": consciousness_level
		}

class Planet:
	var name: String
	var type: String
	var radius: float
	var orbital_distance: float
	var resources: Dictionary = {}
	var has_life: bool = false
	var consciousness_artifact: bool = false
	
	func _init(p_name: String, p_type: String, p_distance: float):
		name = p_name
		type = p_type
		orbital_distance = p_distance
		radius = _calculate_radius_from_type()
	
	func _calculate_radius_from_type() -> float:
		match type:
			"Rocky": return randf_range(3000, 7000)
			"Gas Giant": return randf_range(20000, 80000)
			"Ice": return randf_range(2000, 5000)
			"Desert": return randf_range(4000, 8000)
			"Ocean": return randf_range(5000, 10000)
			_: return 5000

class NavigationComputer:
	var known_systems: Dictionary = {}
	var jump_history: Array = []
	var calculated_routes: Dictionary = {}
	
	func calculate_route(from: StarSystem, to: StarSystem, max_range: float) -> Array:
		# A* pathfinding through star systems
		if calculated_routes.has(from.name + "->" + to.name):
			return calculated_routes[from.name + "->" + to.name]
		
		var route = _astar_pathfind(from, to, max_range)
		calculated_routes[from.name + "->" + to.name] = route
		return route
	
	func _astar_pathfind(from: StarSystem, to: StarSystem, max_range: float) -> Array:
		# Simplified pathfinding
		var route = []
		var current = from
		
		while current != to:
			var next_hop = _find_nearest_system_toward(current, to, max_range)
			if not next_hop:
				return []  # No route found
			route.append(next_hop)
			current = next_hop
		
		return route
	
	func _find_nearest_system_toward(from: StarSystem, to: StarSystem, max_range: float) -> StarSystem:
		# Find system within range that's closest to destination
		return null  # Simplified for now

# Pentagon implementation
func pentagon_init() -> void:
	super.pentagon_init()
	name = "StellarProgressionSystem"
	navigation_computer = NavigationComputer.new()
	_initialize_galaxy_seed()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_visual_components()
	_generate_starting_sector()
	_initialize_sol_system()
	set_process(true)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_update_star_map(delta)
	_process_warp_drive(delta) # Line 165:Function "_process_warp_drive()" not found in base self.= means we must create it or connect it
	_update_stellar_phenomena(delta) # Line 166:Function "_update_stellar_phenomena()" not found in base self.= means we must create it or connect it
	_check_consciousness_beacons(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event.is_action_pressed("open_star_map"):
		_toggle_star_map()
	elif event.is_action_pressed("initiate_warp"):
		_attempt_warp_jump()
	elif event.is_action_pressed("scan_systems"):
		scan_nearby_systems()

func pentagon_sewers() -> void:
	_save_stellar_data()
	_cleanup_visuals()
	super.pentagon_sewers()

# Initialization
func _initialize_galaxy_seed() -> void:
	# Set random seed for consistent galaxy generation
	seed(galaxy_seed)
	print("Stellar Progression System initialized with galaxy seed: ", galaxy_seed)

func _create_visual_components() -> void:
	# 3D star map visualization
	star_map_3d = Node3D.new()
	star_map_3d.name = "StarMap3D"
	star_map_3d.visible = false
	add_child(star_map_3d)
	
	# Warp effect particles
	warp_effect = GPUParticles3D.new()
	warp_effect.amount = 1000
	warp_effect.lifetime = 2.0
	warp_effect.visibility_aabb = AABB(Vector3(-100, -100, -100), Vector3(200, 200, 200))
	warp_effect.emitting = false
	
	var warp_material = ParticleProcessMaterial.new()
	warp_material.direction = Vector3(0, 0, -1)
	warp_material.initial_velocity_min = 50.0
	warp_material.initial_velocity_max = 200.0
	warp_material.spread = 5.0
	warp_material.scale_min = 0.1
	warp_material.scale_max = 2.0
	warp_material.color = Color(0.5, 0.8, 1.0)
	
	warp_effect.process_material = warp_material
	warp_effect.draw_pass_1 = SphereMesh.new()
	warp_effect.draw_pass_1.radius = 0.1
	
	add_child(warp_effect)
	
	# Scan visualizer
	_create_scan_visualizer()
	
	# Route line renderer
	var route_mesh_instance = MeshInstance3D.new()
	route_line_renderer = ImmediateMesh.new()
	route_mesh_instance.mesh = route_line_renderer
	
	var line_material = StandardMaterial3D.new()
	line_material.vertex_color_use_as_albedo = true
	line_material.albedo_color = Color(0.0, 1.0, 0.5)
	line_material.emission_enabled = true
	line_material.emission = Color(0.0, 1.0, 0.5)
	line_material.emission_energy = 0.5
	route_mesh_instance.material_override = line_material
	
	star_map_3d.add_child(route_mesh_instance)

func _create_scan_visualizer() -> void:
	scan_visualizer = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = scan_radius
	sphere_mesh.height = scan_radius * 2
	sphere_mesh.radial_segments = 32
	sphere_mesh.rings = 16
	scan_visualizer.mesh = sphere_mesh
	
	var scan_material = StandardMaterial3D.new()
	scan_material.albedo_color = Color(0.0, 1.0, 0.5, 0.1)
	scan_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	scan_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	scan_material.rim_enabled = true
	scan_material.rim = 1.0
	scan_material.rim_tint = 0.8
	scan_visualizer.material_override = scan_material
	scan_visualizer.visible = false
	
	add_child(scan_visualizer)

# Galaxy generation
func _generate_starting_sector() -> void:
	generate_local_cluster(Vector3.ZERO)

func generate_local_cluster(center_sector: Vector3 = Vector3.ZERO) -> void:
	# Generate sectors around center
	for x in range(-1, 2):
		for y in range(-1, 2):
			for z in range(-1, 2):
				var sector = center_sector + Vector3(x, y, z)
				if not loaded_sectors.has(sector):
					_generate_sector(sector)

func _generate_sector(sector: Vector3) -> void:
	var systems = []
	var sector_seed = hash(sector) ^ galaxy_seed
	seed(sector_seed)
	
	# Generate star systems for this sector
	for i in range(stars_per_sector):
		var system = _generate_star_system(sector, i)
		systems.append(system)
		star_catalog[system.position] = system
		
		# Check for consciousness beacon
		if randf() < consciousness_beacon_chance:
			system.has_consciousness_beacon = true
			_create_consciousness_beacon(system)
	
	loaded_sectors[sector] = systems

func _generate_star_system(sector: Vector3, index: int) -> StarSystem:
	# Generate position within sector
	var sector_pos = sector * sector_size
	var local_pos = Vector3(
		randf_range(0, sector_size),
		randf_range(-sector_size * 0.2, sector_size * 0.2),
		randf_range(0, sector_size)
	)
	var position = sector_pos + local_pos
	
	# Generate name
	var name = _generate_star_name(sector, index)
	
	var system = StarSystem.new(name, position)
	
	# Generate star type
	system.star_data["type"] = _generate_star_type()
	
	# Generate planets
	var planet_count = randi() % 9  # 0-8 planets
	for p in range(planet_count):
		var planet = _generate_planet(system, p)
		system.planets.append(planet)
		
		# Add planet resources
		_generate_planet_resources(planet)
	
	# Consciousness level based on phenomena
	system.consciousness_level = randf() * randf()  # Bias toward lower values
	
	return system

func _generate_star_name(sector: Vector3, index: int) -> String:
	var prefixes = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa"]
	var suffixes = ["Centauri", "Draconis", "Ursae", "Aquarii", "Phoenicis", "Lyrae", "Cygni", "Andromedae"]
	
	var prefix_idx = abs(int(sector.x + sector.y * 10 + index)) % prefixes.size()
	var suffix_idx = abs(int(sector.z + index * 5)) % suffixes.size()
	
	return prefixes[prefix_idx] + " " + suffixes[suffix_idx]

func _generate_star_type() -> String:
	var roll = randf()
	if roll < 0.7:
		return "M-Type"  # Red dwarf - most common
	elif roll < 0.85:
		return "K-Type"  # Orange dwarf
	elif roll < 0.95:
		return "G-Type"  # Yellow dwarf (like our Sun)
	elif roll < 0.98:
		return "F-Type"  # Yellow-white
	elif roll < 0.99:
		return "A-Type"  # White
	else:
		return "B-Type"  # Blue-white

func _generate_planet(system: StarSystem, index: int) -> Planet:
	var types = ["Rocky", "Gas Giant", "Ice", "Desert", "Ocean"]
	var type = types[randi() % types.size()]
	
	# Orbital distance increases with index
	var distance = (index + 1) * 50.0 + randf() * 30.0
	
	var name = system.name + " " + ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"][index]
	var planet = Planet.new(name, type, distance)
	
	# Life and artifacts
	if type in ["Rocky", "Ocean"] and randf() < 0.1:
		planet.has_life = true
	
	if randf() < 0.05:
		planet.consciousness_artifact = true
	
	return planet

func _generate_planet_resources(planet: Planet) -> void:
	var resources = ["Helium-3", "Rare Metals", "Crystals", "Organic Compounds", "Water", "Consciousness Crystals"]
	
	match planet.type:
		"Rocky":
			if randf() < 0.7: planet.resources["Rare Metals"] = randi_range(100, 1000)
			if randf() < 0.3: planet.resources["Crystals"] = randi_range(50, 500)
		"Gas Giant":
			planet.resources["Helium-3"] = randi_range(500, 5000)
		"Ice":
			planet.resources["Water"] = randi_range(1000, 10000)
			if randf() < 0.2: planet.resources["Crystals"] = randi_range(100, 500)
		"Ocean":
			planet.resources["Water"] = randi_range(5000, 20000)
			if randf() < 0.4: planet.resources["Organic Compounds"] = randi_range(100, 1000)
		"Desert":
			if randf() < 0.5: planet.resources["Rare Metals"] = randi_range(200, 800)
			if randf() < 0.1: planet.resources["Consciousness Crystals"] = randi_range(10, 100)

func _initialize_sol_system() -> void:
	# Create our solar system
	var sol = StarSystem.new("Sol", Vector3.ZERO)
	sol.star_data["type"] = "G-Type"
	sol.discovered = true
	sol.visited = true
	
	# Add planets
	var earth = Planet.new("Earth", "Rocky", 150.0)
	earth.has_life = true
	earth.resources["Water"] = 10000
	earth.resources["Organic Compounds"] = 5000
	sol.planets.append(earth)
	
	# Add more planets as needed...
	
	current_system = sol
	discovered_systems["Sol"] = sol
	visited_systems.append("Sol")
	star_catalog[sol.position] = sol

# Navigation
func travel_to_system(target_system_name: String) -> Dictionary:
	if not discovered_systems.has(target_system_name):
		return {"success": false, "reason": "System not discovered"}
	
	var target = discovered_systems[target_system_name]
	var distance = current_system.position.distance_to(target.position)
	
	if distance > max_warp_range * warp_drive_level:
		return {"success": false, "reason": "System out of range"}
	
	# Check energy
	var player = get_tree().get_first_node_in_group("player")
	if player and player.energy < warp_energy_cost:
		return {"success": false, "reason": "Insufficient energy"}
	
	# Calculate route if needed
	if distance > max_warp_range:
		active_route = navigation_computer.calculate_route(current_system, target, max_warp_range)
		if active_route.is_empty():
			return {"success": false, "reason": "No valid route found"}
	
	# Initiate warp
	_initiate_warp_jump(target)
	
	return {"success": true, "travel_time": distance / (warp_drive_level * 100.0)}

func _initiate_warp_jump(target: StarSystem) -> void:
	is_warping = true
	warp_jump_initiated.emit(current_system.name, target.name)
	
	# Visual effect
	warp_effect.emitting = true
	
	# Consume energy
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player._consume_energy(warp_energy_cost)
	
	# Create timer for arrival
	var travel_time = current_system.position.distance_to(target.position) / (warp_drive_level * 100.0)
	var timer = Timer.new()
	timer.wait_time = min(travel_time, 3.0)  # Cap at 3 seconds for gameplay
	timer.one_shot = true
	timer.timeout.connect(_complete_warp_jump.bind(target))
	add_child(timer)
	timer.start()

func _complete_warp_jump(target: StarSystem) -> void:
	current_system = target
	current_sector = target.sector
	is_warping = false
	
	warp_effect.emitting = false
	
	if not target.visited:
		target.visited = true
		visited_systems.append(target.name)
		stellar_knowledge += 10.0
	
	warp_jump_completed.emit()
	
	# Check for phenomena
	_check_system_phenomena(target)
	
	# Update star chart
	_update_discovered_systems()

func _attempt_warp_jump() -> void:
	# Find nearest discovered system
	var nearest_system: StarSystem = null
	var nearest_distance: float = INF
	
	for sys_name in discovered_systems:
		var system = discovered_systems[sys_name]
		if system != current_system:
			var distance = current_system.position.distance_to(system.position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_system = system
	
	if nearest_system:
		travel_to_system(nearest_system.name)

# Scanning
func scan_nearby_systems() -> Array:
	var scanned = []
	var scan_pos = current_system.position
	
	# Visual feedback
	scan_visualizer.visible = true
	scan_visualizer.global_position = Vector3.ZERO  # Relative to current system
	
	var tween = create_tween()
	tween.tween_property(scan_visualizer, "scale", Vector3.ONE * 2, 1.0)
	tween.parallel().tween_property(scan_visualizer.material_override, "albedo_color:a", 0.0, 1.0)
	tween.tween_callback(func(): scan_visualizer.visible = false)
	
	# Scan for systems
	for system in star_catalog.values():
		var distance = scan_pos.distance_to(system.position)
		if distance <= scan_radius * warp_drive_level and distance > 0:
			if not system.discovered:
				system.discovered = true
				discovered_systems[system.name] = system
				scanned.append(system)
				
				# Check for special discoveries
				if system.has_consciousness_beacon:
					_on_consciousness_beacon_discovered(system)
	
	if scanned.size() > 0:
		star_chart_updated.emit(scanned)
		stellar_knowledge += scanned.size() * 2.0
	
	return scanned

# Phenomena
func _check_system_phenomena(system: StarSystem) -> void:
	# Random chance of phenomena
	if randf() < 0.2:
		var phenomenon = _generate_stellar_phenomenon()
		system.phenomena.append(phenomenon)
		stellar_phenomenon_observed.emit(phenomenon)

func _generate_stellar_phenomenon() -> Dictionary:
	var types = [
		{
			"type": "Nebula",
			"description": "A beautiful cosmic cloud of gas and dust",
			"effect": "consciousness_boost",
			"value": 0.1
		},
		{
			"type": "Asteroid Field",
			"description": "Rich in rare minerals",
			"effect": "mining_bonus",
			"value": 0.2
		},
		{
			"type": "Quantum Anomaly",
			"description": "Space-time behaves strangely here",
			"effect": "time_dilation",
			"value": 0.5
		},
		{
			"type": "Ancient Structure",
			"description": "Remnants of an advanced civilization",
			"effect": "knowledge_boost",
			"value": 20.0
		},
		{
			"type": "Consciousness Nexus",
			"description": "A convergence point of universal consciousness",
			"effect": "awareness_expansion",
			"value": 1
		}
	]
	
	return types[randi() % types.size()]

# Consciousness beacons
func _create_consciousness_beacon(system: StarSystem) -> void:
	var beacon = {
		"system": system,
		"frequency": randf_range(400, 500),
		"message": _generate_beacon_message(),
		"discovered": false
	}
	consciousness_beacons.append(beacon)

func _generate_beacon_message() -> String:
	var messages = [
		"We were like you once...",
		"The answer lies within",
		"Unity through diversity",
		"Consciousness is the bridge",
		"Time is an illusion",
		"All paths lead to One"
	]
	return messages[randi() % messages.size()]

func _on_consciousness_beacon_discovered(system: StarSystem) -> void:
	for beacon in consciousness_beacons:
		if beacon["system"] == system:
			beacon["discovered"] = true
			consciousness_beacon_found.emit({
				"location": system.name,
				"frequency": beacon["frequency"],
				"message": beacon["message"]
			})
			break

func _check_consciousness_beacons(delta: float) -> void:
	# Check if player is near any beacons
	for beacon in consciousness_beacons:
		if beacon["discovered"] and beacon["system"] == current_system:
			# Player is at beacon system
			_activate_consciousness_beacon(beacon)

func _activate_consciousness_beacon(beacon: Dictionary) -> void:
	# Connect to other discovered beacons
	for other_beacon in consciousness_beacons:
		if other_beacon != beacon and other_beacon["discovered"]:
			var key = beacon["system"].name + "-" + other_beacon["system"].name
			if not beacon_connections.has(key):
				beacon_connections[key] = true
				# Could create visual connection line

# Star map
func _toggle_star_map() -> void:
	star_map_3d.visible = !star_map_3d.visible
	
	if star_map_3d.visible:
		_update_star_map_visual()

func _update_star_map(delta: float) -> void:
	if not star_map_3d.visible:
		return
	
	# Rotate map slowly
	star_map_3d.rotate_y(delta * 0.1)

func _update_star_map_visual() -> void:
	# Clear existing
	for child in star_map_3d.get_children():
		if child.name.begins_with("Star_"):
			child.queue_free()
	
	# Create star representations
	for sys_name in discovered_systems:
		var system = discovered_systems[sys_name]
		var star_marker = _create_star_marker(system)
		star_map_3d.add_child(star_marker)
	
	# Draw route if active
	if not active_route.is_empty():
		_draw_navigation_route()

func _create_star_marker(system: StarSystem) -> Node3D:
	var marker = Node3D.new()
	marker.name = "Star_" + system.name
	marker.position = system.position / 100.0  # Scale down for display
	
	# Visual representation
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.5
	mesh_instance.mesh = sphere_mesh
	
	# Color based on star type
	var star_colors = {
		"M-Type": Color(1.0, 0.5, 0.3),
		"K-Type": Color(1.0, 0.7, 0.4),
		"G-Type": Color(1.0, 1.0, 0.7),
		"F-Type": Color(1.0, 1.0, 0.9),
		"A-Type": Color(0.9, 0.9, 1.0),
		"B-Type": Color(0.7, 0.8, 1.0)
	}
	
	var material = StandardMaterial3D.new()
	material.albedo_color = star_colors.get(system.star_data["type"], Color.WHITE)
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_energy = 2.0
	
	if system == current_system:
		material.emission_energy = 5.0  # Highlight current system
	
	mesh_instance.material_override = material
	marker.add_child(mesh_instance)
	
	# Label
	var label = Label3D.new()
	label.text = system.name
	label.position.y = 1.0
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 12
	marker.add_child(label)
	
	return marker

func _draw_navigation_route() -> void:
	route_line_renderer.clear_surfaces()
	route_line_renderer.surface_begin(Mesh.PRIMITIVE_LINES)
	
	var prev_pos = current_system.position / 100.0
	route_line_renderer.surface_set_color(Color(0.0, 1.0, 0.5))
	
	for system in active_route:
		var pos = system.position / 100.0
		route_line_renderer.surface_add_vertex(prev_pos)
		route_line_renderer.surface_add_vertex(pos)
		prev_pos = pos
	
	route_line_renderer.surface_end()

# Progression
func upgrade_warp_drive() -> void:
	warp_drive_level += 1
	max_warp_range = 100.0 * warp_drive_level
	scan_radius = 200.0 * warp_drive_level
	print("Warp drive upgraded to level ", warp_drive_level)

func get_discovered_systems() -> Array:
	return discovered_systems.values()

func get_current_system() -> StarSystem:
	return current_system

func get_visited_systems_count() -> int:
	return visited_systems.size()

# Save/Load
func _save_stellar_data() -> void:
	if AkashicRecordsSystem: # Line 719:Could not resolve class "AkashicRecordsSystem", because of a parser error hmm we must take a look at that class too, where it was??
		var save_data = {
			"current_system": current_system.name if current_system else "",
			"discovered_systems": {},
			"visited_systems": visited_systems,
			"warp_drive_level": warp_drive_level,
			"stellar_knowledge": stellar_knowledge
		}
		
		# Save discovered systems
		for name in discovered_systems:
			var system = discovered_systems[name]
			save_data["discovered_systems"][name] = system.get_info()
		
		AkashicRecordsSystem.save_stellar_data(save_data)

func load_stellar_data(data: Dictionary) -> void:
	visited_systems = data.get("visited_systems", [])
	warp_drive_level = data.get("warp_drive_level", 1)
	stellar_knowledge = data.get("stellar_knowledge", 0.0)
	
	# Restore current system
	var current_name = data.get("current_system", "Sol")
	if discovered_systems.has(current_name):
		current_system = discovered_systems[current_name]

# Cleanup
func _cleanup_visuals() -> void:
	if warp_effect:
		warp_effect.emitting = false

# API for other systems
func enable_temporal_navigation() -> void:
	# Special navigation mode for temporal perception
	print("Temporal navigation enabled - time flows differently during warp")

func update_visible_sectors(player_sector: Vector3) -> void:
	current_sector = player_sector
	
	# Load nearby sectors
	generate_local_cluster(current_sector)
	
	# Unload distant sectors to save memory
	var sectors_to_unload = []
	for sector in loaded_sectors:
		if sector.distance_to(current_sector) > 3:
			sectors_to_unload.append(sector)
	
	for sector in sectors_to_unload:
		loaded_sectors.erase(sector)

func find_consciousness_artifacts() -> Array:
	var artifacts = []
	
	for system in visited_systems:
		if discovered_systems.has(system):
			var sys = discovered_systems[system]
			for planet in sys.planets:
				if planet.consciousness_artifact:
					artifacts.append({
						"location": planet.name,
						"system": system,
						"type": "Consciousness Artifact"
					})
	
	return artifacts

func pause_simulation() -> void:
	set_process(false)
	
func resume_simulation() -> void:
	set_process(true)

func start_exploration_mode() -> void:
	# Begin automatic exploration
	set_process(true)

# Debug
func debug_discover_all_local_systems() -> void:
	generate_local_cluster(current_sector)
	for system in star_catalog.values():
		if system.position.distance_to(current_system.position) < 1000:
			system.discovered = true
			discovered_systems[system.name] = system
	star_chart_updated.emit(discovered_systems.values())

func _update_discovered_systems() -> void:
	# Check for nearby systems to auto-discover
	for system in star_catalog.values():
		if not system.discovered:
			var distance = current_system.position.distance_to(system.position)
			if distance < 50.0:  # Auto-discover very close systems
				system.discovered = true
				discovered_systems[system.name] = system
