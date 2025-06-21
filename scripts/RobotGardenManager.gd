extends Node3D
class_name RobotGardenManager

# Orchestrates the entire spirit-robot ecosystem
# "The divine conductor of the mechanical garden symphony"

signal garden_status_changed(status: Dictionary)
signal robot_awakened(robot: RobotSpirit)
signal memory_network_updated(shared_memories: int)

# Garden management
@export var max_gardener_robots: int = 5
@export var auto_spawn_robots: bool = true
@export var garden_update_interval: float = 30.0

# Robot collections
var active_robots: Array[RobotSpirit] = []
var gardener_robots: Array[GardenerRobot] = []
var memory_visualizer: MemoryVisualizer
var terrain_warper: TerrainWarper

# Garden state
var garden_productivity: float = 1.0
var collective_consciousness_level: float = 0.0
var shared_memory_count: int = 0
var garden_age: float = 0.0

# Network communication
var rf_beacons: Array[Vector3] = []
var robot_spawn_points: Array[Vector3] = []

# Sigil configurations
var available_sigils: Array[String] = ["lilith", "demeter", "gaia", "asmodeus", "belphegor"]

func _ready():
	_setup_garden_infrastructure()
	_initialize_memory_systems()
	_spawn_initial_robots()
	
	# Start garden management timer
	var timer = Timer.new()
	timer.wait_time = garden_update_interval
	timer.timeout.connect(_update_garden_systems)
	timer.autostart = true
	add_child(timer)

func _setup_garden_infrastructure():
	print("🌱 Setting up Garden Infrastructure")
	
	# Create memory visualizer
	memory_visualizer = MemoryVisualizer.new()
	add_child(memory_visualizer)
	memory_visualizer.memory_cell_selected.connect(_on_memory_selected)
	
	# Create terrain warper
	terrain_warper = TerrainWarper.new()
	add_child(terrain_warper)
	terrain_warper.terrain_warped.connect(_on_terrain_warped)
	
	# Set up RF beacon network
	_place_rf_beacons()
	
	# Define robot spawn points
	_define_spawn_points()

func _initialize_memory_systems():
	print("🧠 Initializing Collective Memory Network")
	
	# Create shared memory visualization
	if memory_visualizer:
		memory_visualizer.set_visualization_mode(MemoryVisualizer.VisualizationMode.SPIRIT)

func _place_rf_beacons():
	# Place beacons in a grid pattern for robot navigation
	var beacon_spacing = 10.0
	var grid_size = 3
	
	for x in range(-grid_size, grid_size + 1):
		for z in range(-grid_size, grid_size + 1):
			var beacon_pos = Vector3(x * beacon_spacing, 2.0, z * beacon_spacing)
			rf_beacons.append(beacon_pos)
			
			# Create visual beacon marker
			_create_beacon_marker(beacon_pos)

func _create_beacon_marker(position: Vector3):
	var marker = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.2
	mesh.bottom_radius = 0.2
	mesh.height = 1.0
	marker.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.CYAN
	material.emission_enabled = true
	material.emission = Color.CYAN
	material.emission_energy = 0.5
	marker.material_override = material
	
	marker.global_position = position
	add_child(marker)

func _define_spawn_points():
	# Define where robots should initially spawn
	robot_spawn_points = [
		Vector3(0, 0.5, 0),      # Center
		Vector3(5, 0.5, 5),      # Northeast
		Vector3(-5, 0.5, 5),     # Northwest
		Vector3(5, 0.5, -5),     # Southeast
		Vector3(-5, 0.5, -5),    # Southwest
	]

func _spawn_initial_robots():
	print("🤖 Spawning Initial Robot Spirits")
	
	for i in range(min(max_gardener_robots, robot_spawn_points.size())):
		var spawn_point = robot_spawn_points[i]
		var sigil = available_sigils[i % available_sigils.size()]
		spawn_gardener_robot(spawn_point, sigil, "Gardener-" + str(i + 1))

func spawn_gardener_robot(position: Vector3, sigil_type: String = "", name: String = "") -> GardenerRobot:
	if gardener_robots.size() >= max_gardener_robots:
		print("⚠️ Maximum gardener robots reached")
		return null
	
	# Load gardener robot scene
	var robot_scene = preload("res://beings/UniversalBeing.tscn")  # Will be replaced with actual gardener scene
	var robot = GardenerRobot.new()
	
	# Configure robot
	robot.global_position = position
	robot.spirit_name = name if name != "" else "Spirit-" + str(Time.get_time_dict_from_system()["unix"])
	robot.sigil_type = sigil_type if sigil_type != "" else available_sigils[randi() % available_sigils.size()]
	
	# Add to scene and collections
	add_child(robot)
	active_robots.append(robot)
	gardener_robots.append(robot)
	
	# Connect signals
	robot.spirit_awakened.connect(_on_robot_awakened)
	robot.memory_shared.connect(_on_memory_shared)
	robot.fruit_harvested.connect(_on_fruit_harvested)
	
	# Set patrol route
	var patrol_route = _generate_patrol_route(position)
	robot.set_patrol_route(patrol_route)
	
	print("🌿 Spawned gardener robot: ", robot.spirit_name, " (", robot.sigil_type, ")")
	robot_awakened.emit(robot)
	
	return robot

func _generate_patrol_route(start_position: Vector3) -> Array[Vector3]:
	var route = [start_position]
	var route_radius = 8.0
	var num_points = 6
	
	for i in range(num_points):
		var angle = (PI * 2.0 * i) / num_points
		var offset = Vector3(cos(angle), 0, sin(angle)) * route_radius
		route.append(start_position + offset)
	
	route.append(start_position)  # Return to start
	return route

func _update_garden_systems():
	garden_age += garden_update_interval
	
	_update_collective_consciousness()
	_update_garden_productivity()
	_process_memory_network()
	_check_robot_health()
	_update_terrain_based_on_memories()
	
	# Emit status update
	var status = get_garden_status()
	garden_status_changed.emit(status)
	
	print("🌱 Garden Update: Age=%.1fs, Productivity=%.2f, Consciousness=%.2f" % [
		garden_age, garden_productivity, collective_consciousness_level
	])

func _update_collective_consciousness():
	var total_consciousness = 0.0
	var robot_count = active_robots.size()
	
	for robot in active_robots:
		if is_instance_valid(robot):
			total_consciousness += robot.consciousness_level
		else:
			active_robots.erase(robot)
			robot_count -= 1
	
	collective_consciousness_level = total_consciousness / max(robot_count, 1)

func _update_garden_productivity():
	# Calculate productivity based on robot efficiency and consciousness
	var base_productivity = 0.5
	var consciousness_bonus = collective_consciousness_level * 0.3
	var robot_efficiency = 0.0
	
	for robot in gardener_robots:
		if is_instance_valid(robot):
			robot_efficiency += robot.plant_care_efficiency
	
	robot_efficiency /= max(gardener_robots.size(), 1)
	garden_productivity = base_productivity + consciousness_bonus + robot_efficiency * 0.2

func _process_memory_network():
	# Collect and process shared memories
	var all_memories = []
	
	for robot in active_robots:
		if is_instance_valid(robot) and robot.notepad3d:
			var robot_memories = robot.notepad3d.get_emotional_memories(0.6)
			all_memories.append_array(robot_memories)
	
	shared_memory_count = all_memories.size()
	
	# Create memory resonance effects
	if all_memories.size() > 5 and terrain_warper:
		var resonance_center = Vector3.ZERO
		for memory in all_memories:
			resonance_center += memory.get("position", Vector3.ZERO)
		resonance_center /= all_memories.size()
		
		terrain_warper.create_memory_resonance(all_memories, resonance_center)
	
	# Update memory visualization
	if memory_visualizer and active_robots.size() > 0:
		var primary_robot = active_robots[0]
		if primary_robot.notepad3d:
			memory_visualizer.visualize_notepad(primary_robot.notepad3d, Vector3.ZERO)
	
	memory_network_updated.emit(shared_memory_count)

func _check_robot_health():
	# Monitor and maintain robot health
	for robot in active_robots:
		if is_instance_valid(robot):
			if robot.energy_level < 0.1:
				print("⚡ ", robot.spirit_name, " needs energy - directing to charging station")
				# Could implement charging station navigation here
			
			if robot.consciousness_level > 10.0:
				print("🧠 ", robot.spirit_name, " has transcended - applying consciousness stabilization")
				robot.consciousness_level = 10.0

func _update_terrain_based_on_memories():
	# Apply terrain modifications based on collective robot memories
	if not terrain_warper:
		return
	
	for robot in active_robots:
		if is_instance_valid(robot) and robot.notepad3d:
			# Find areas with high emotional intensity
			var intense_memories = robot.notepad3d.get_emotional_memories(0.8)
			
			for memory in intense_memories:
				var pos = memory.get("position", Vector3.ZERO)
				var emotion = memory.get("data", {}).get("emotion", 0.5)
				
				if emotion > 0.9:
					# Very high emotion - create terrain feature
					terrain_warper.warp_from_memory(robot.notepad3d, pos, 2.0)

# Command interface for divine interventions
func divine_command(command: String, parameters: Dictionary = {}):
	print("⚡ Divine Command: ", command)
	
	match command.to_lower():
		"spawn_robot":
			var pos = parameters.get("position", Vector3.ZERO)
			var sigil = parameters.get("sigil", "")
			var name = parameters.get("name", "")
			spawn_gardener_robot(pos, sigil, name)
		
		"boost_consciousness":
			var amount = parameters.get("amount", 1.0)
			for robot in active_robots:
				if is_instance_valid(robot):
					robot.consciousness_level += amount
		
		"enhance_garden":
			garden_productivity *= parameters.get("multiplier", 1.5)
		
		"create_memory_storm":
			_create_memory_storm(parameters.get("center", Vector3.ZERO))
		
		"visualize_memories":
			var spirit_name = parameters.get("spirit", "")
			if spirit_name != "":
				memory_visualizer.filter_by_spirit(spirit_name)
			else:
				memory_visualizer.clear_filters()
		
		"terraform":
			var center = parameters.get("center", Vector3.ZERO)
			var type = parameters.get("type", "hill")
			var intensity = parameters.get("intensity", 1.0)
			
			match type:
				"hill":
					terrain_warper.create_hill(center, 5.0, intensity)
				"valley":
					terrain_warper.create_valley(center, 5.0, intensity)
				"soften":
					terrain_warper.soften_terrain_area(center, 5.0, intensity)

func _create_memory_storm(center: Vector3):
	# Create a chaotic burst of shared memories
	for robot in active_robots:
		if is_instance_valid(robot):
			robot.notepad3d.dream_sequence(Vector3i(center), 5)
			robot.activate_sigil_power(randf_range(0.5, 1.0))
	
	# Create terrain distortions
	if terrain_warper:
		terrain_warper.apply_dream_distortion(center, 2.0, 0.8)
	
	print("🌪️ Memory storm unleashed at ", center)

# Information and status
func get_garden_status() -> Dictionary:
	return {
		"age": garden_age,
		"productivity": garden_productivity,
		"collective_consciousness": collective_consciousness_level,
		"active_robots": active_robots.size(),
		"gardener_robots": gardener_robots.size(),
		"shared_memories": shared_memory_count,
		"rf_beacons": rf_beacons.size(),
		"terrain_effects": terrain_warper.get_active_effects_count() if terrain_warper else {}
	}

func get_robot_reports() -> Array:
	var reports = []
	
	for robot in active_robots:
		if is_instance_valid(robot):
			if robot is GardenerRobot:
				reports.append(robot.get_gardening_report())
			else:
				reports.append(robot.get_memory_summary())
	
	return reports

func save_garden_state(filepath: String) -> bool:
	var save_data = {
		"garden_age": garden_age,
		"garden_productivity": garden_productivity,
		"collective_consciousness": collective_consciousness_level,
		"rf_beacons": rf_beacons,
		"robot_spawn_points": robot_spawn_points,
		"robots": []
	}
	
	# Save robot data
	for i in range(active_robots.size()):
		var robot = active_robots[i]
		if is_instance_valid(robot):
			var robot_file = filepath.replace(".json", "_robot_" + str(i) + ".json")
			if robot.save_spirit_data(robot_file):
				save_data["robots"].append({
					"file": robot_file,
					"type": robot.get_script().get_global_name(),
					"position": robot.global_position
				})
	
	# Save main garden data
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if not file:
		return false
	
	file.store_string(JSON.stringify(save_data))
	file.close()
	
	return true

func load_garden_state(filepath: String) -> bool:
	var file = FileAccess.open(filepath, FileAccess.READ)
	if not file:
		return false
	
	var json = JSON.new()
	var parse_result = json.parse(file.get_as_text())
	file.close()
	
	if parse_result != OK:
		return false
	
	var data = json.data
	garden_age = data.get("garden_age", 0.0)
	garden_productivity = data.get("garden_productivity", 1.0)
	collective_consciousness_level = data.get("collective_consciousness", 0.0)
	rf_beacons = data.get("rf_beacons", rf_beacons)
	robot_spawn_points = data.get("robot_spawn_points", robot_spawn_points)
	
	# Clear existing robots
	for robot in active_robots:
		if is_instance_valid(robot):
			robot.queue_free()
	active_robots.clear()
	gardener_robots.clear()
	
	# Load robots
	var robot_data = data.get("robots", [])
	for robot_info in robot_data:
		var robot_file = robot_info.get("file", "")
		var robot_type = robot_info.get("type", "GardenerRobot")
		var position = robot_info.get("position", Vector3.ZERO)
		
		# Create robot based on type
		var robot = GardenerRobot.new()  # For now, only gardener robots
		add_child(robot)
		robot.global_position = position
		
		# Load robot data
		if robot.load_spirit_data(robot_file):
			active_robots.append(robot)
			if robot is GardenerRobot:
				gardener_robots.append(robot)
	
	return true

# Signal handlers
func _on_robot_awakened(robot_name: String):
	print("🌟 Robot awakened: ", robot_name)

func _on_memory_shared(from_spirit: String, to_spirit: String, memory: Dictionary):
	print("📡 Memory shared: ", from_spirit, " → ", to_spirit)

func _on_fruit_harvested(fruit_type: String, position: Vector3, quality: float):
	print("🍎 Fruit harvested: ", fruit_type, " (quality: ", quality, ") at ", position)
	
	# Boost garden productivity slightly
	garden_productivity += quality * 0.01

func _on_memory_selected(position: Vector3i, data: Dictionary):
	print("💭 Memory selected at ", position, ": ", data.get("note", "unnamed"))

func _on_terrain_warped(center: Vector3, radius: float, intensity: float):
	print("🌀 Terrain warped at ", center, " (radius: ", radius, ", intensity: ", intensity, ")")