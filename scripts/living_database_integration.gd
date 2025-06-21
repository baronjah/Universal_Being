# ==================================================
# UNIVERSAL BEING: LIVING DATABASE INTEGRATION
# TYPE: System Integration and Orchestration
# PURPOSE: Connect all living database systems together
# ROLE: Master coordinator for the living database experience
# ==================================================

extends Node
class_name LivingDatabaseIntegration

## 🌌 LIVING DATABASE INTEGRATION - The Master Orchestrator
## Connects database visualizer, input streams, magnetic motors, and reality editing
## Creates the seamless "backend as frontend" experience

# ===== SYSTEM REFERENCES =====
var database_visualizer: LivingDatabaseVisualizer
var input_stream_visualizer: InputStreamVisualizer
var magnetic_sphere_motor: MagneticSphereMotor
var alive_game_universe: AliveGameUniverse

# Integration state
var systems_ready: bool = false
var integration_active: bool = false
var demo_mode: bool = true

# Demo automation
var auto_demo_timer: Timer
var demo_actions: Array[Dictionary] = []
var current_demo_step: int = 0

# Cross-system data sharing
var shared_consciousness_data: Dictionary = {}
var global_gravity_points: Array[Vector3] = []
var system_performance_metrics: Dictionary = {}

# ===== PENTAGON INTEGRATION =====

func _ready() -> void:
	await get_tree().process_frame  # Wait for systems to initialize
	discover_and_connect_systems()
	setup_system_integration()
	setup_demo_automation()
	
	print("🌌 Living Database Integration: All systems connected and orchestrated!")

func _process(delta: float) -> void:
	if integration_active:
		coordinate_system_interactions(delta)
		update_shared_consciousness_data(delta)
		monitor_system_performance(delta)

# ===== SYSTEM DISCOVERY =====

func discover_and_connect_systems() -> void:
	"""Find and connect to all living database systems"""
	# Find database visualizer
	database_visualizer = find_system_by_class("LivingDatabaseVisualizer")
	if database_visualizer:
		print("🗄️ Found Database Visualizer")
		connect_database_visualizer()
	
	# Find input stream visualizer
	input_stream_visualizer = find_system_by_class("InputStreamVisualizer")
	if input_stream_visualizer:
		print("🌊 Found Input Stream Visualizer")
		connect_input_stream_visualizer()
	
	# Find magnetic sphere motor
	magnetic_sphere_motor = find_system_by_class("MagneticSphereMotor")
	if magnetic_sphere_motor:
		print("🧲 Found Magnetic Sphere Motor")
		connect_magnetic_sphere_motor()
	
	# Find alive game universe
	alive_game_universe = find_system_by_class("AliveGameUniverse")
	if alive_game_universe:
		print("🌍 Found Alive Game Universe")
		connect_alive_game_universe()
	
	systems_ready = true

func find_system_by_class(class_name: String) -> Node:
	"""Find a system by its class name in the scene tree"""
	return find_node_with_script_class(get_tree().current_scene, class_name)

func find_node_with_script_class(node: Node, class_name: String) -> Node:
	"""Recursively find node with specific script class"""
	if node.get_script() and node.get_script().get_global_name() == class_name:
		return node
	
	for child in node.get_children():
		var result = find_node_with_script_class(child, class_name)
		if result:
			return result
	
	return null

# ===== SYSTEM CONNECTIONS =====

func connect_database_visualizer() -> void:
	"""Connect to the database visualizer system"""
	if not database_visualizer:
		return
	
	# Connect signals if they exist
	if database_visualizer.has_signal("database_query_visualized"):
		database_visualizer.database_query_visualized.connect(_on_database_query)
	
	# Setup initial gravity points
	create_initial_gravity_points()

func connect_input_stream_visualizer() -> void:
	"""Connect to the input stream visualizer"""
	if not input_stream_visualizer:
		return
	
	# Connect input streams to database visualization
	if input_stream_visualizer.has_signal("input_stream_created"):
		input_stream_visualizer.input_stream_created.connect(_on_input_stream_created)

func connect_magnetic_sphere_motor() -> void:
	"""Connect to the magnetic sphere motor system"""
	if not magnetic_sphere_motor:
		return
	
	# Connect motor to camera for rotation control
	var camera_point = get_tree().get_first_node_in_group("camera_points")
	if camera_point:
		magnetic_sphere_motor.set_target_object(camera_point)
		print("🧲 Magnetic motor connected to camera")
	
	# Connect motor rotation to consciousness visualization
	if magnetic_sphere_motor.has_signal("rotation_changed"):
		magnetic_sphere_motor.rotation_changed.connect(_on_motor_rotation_changed)

func connect_alive_game_universe() -> void:
	"""Connect to the alive game universe system"""
	if not alive_game_universe:
		return
	
	# Connect universe events to visualization
	if alive_game_universe.has_signal("spaceclay_being_created"):
		alive_game_universe.spaceclay_being_created.connect(_on_spaceclay_being_created)
	
	if alive_game_universe.has_signal("universe_evolution"):
		alive_game_universe.universe_evolution.connect(_on_universe_evolution)

# ===== SYSTEM INTEGRATION =====

func setup_system_integration() -> void:
	"""Setup integration between all systems"""
	integration_active = true
	
	# Create shared consciousness field
	setup_shared_consciousness_field()
	
	# Setup cross-system gravity interactions
	setup_gravity_interactions()
	
	# Setup reality editing integration
	setup_reality_editing_integration()
	
	print("🔗 System integration established")

func setup_shared_consciousness_field() -> void:
	"""Create a shared consciousness field across all systems"""
	shared_consciousness_data = {
		"global_consciousness_level": 3.0,
		"active_beings": [],
		"consciousness_flows": [],
		"gravity_influences": [],
		"input_consciousness_mapping": {}
	}

func setup_gravity_interactions() -> void:
	"""Setup gravity interactions between systems"""
	# Create gravity points that affect both input streams and consciousness data
	if database_visualizer:
		var gravity_positions = [
			Vector3(0, 5, 0),      # Central up
			Vector3(-5, 2, -5),    # Left back
			Vector3(5, 2, -5),     # Right back
			Vector3(0, 1, 8)       # Front low
		]
		
		for pos in gravity_positions:
			var gravity_point = database_visualizer.create_gravity_field_at_position(pos, 8.0)
			global_gravity_points.append(pos)
			
			# Connect gravity to input stream attraction
			if input_stream_visualizer:
				connect_gravity_to_input_streams(pos)

func connect_gravity_to_input_streams(gravity_pos: Vector3) -> void:
	"""Connect a gravity point to input stream attraction"""
	# This would be implemented in the input stream visualizer
	# For now, just record the connection
	shared_consciousness_data.gravity_influences.append({
		"position": gravity_pos,
		"affects_input_streams": true,
		"strength": 1.0
	})

func setup_reality_editing_integration() -> void:
	"""Setup integration for Blender-like reality editing"""
	if database_visualizer and alive_game_universe:
		# Connect reality editing to spaceclay being creation
		print("🎨 Reality editing integration ready")

# ===== DEMO AUTOMATION =====

func setup_demo_automation() -> void:
	"""Setup automated demo actions"""
	if not demo_mode:
		return
	
	demo_actions = [
		{"action": "create_consciousness_burst", "delay": 3.0},
		{"action": "show_input_stream_explanation", "delay": 2.0},
		{"action": "demonstrate_gravity_attraction", "delay": 4.0},
		{"action": "show_magnetic_motor_rotation", "delay": 3.0},
		{"action": "demonstrate_blender_mode", "delay": 5.0},
		{"action": "show_universe_evolution", "delay": 4.0}
	]
	
	auto_demo_timer = Timer.new()
	auto_demo_timer.timeout.connect(_execute_next_demo_action)
	add_child(auto_demo_timer)
	
	# Start first demo action
	_execute_next_demo_action()

func _execute_next_demo_action() -> void:
	"""Execute the next automated demo action"""
	if current_demo_step >= demo_actions.size():
		current_demo_step = 0  # Loop demo
	
	var action = demo_actions[current_demo_step]
	execute_demo_action(action.action)
	
	auto_demo_timer.wait_time = action.delay
	auto_demo_timer.start()
	current_demo_step += 1

func execute_demo_action(action_name: String) -> void:
	"""Execute a specific demo action"""
	match action_name:
		"create_consciousness_burst":
			create_demo_consciousness_burst()
		"show_input_stream_explanation":
			show_demo_input_streams()
		"demonstrate_gravity_attraction":
			demonstrate_demo_gravity()
		"show_magnetic_motor_rotation":
			demonstrate_demo_motor()
		"demonstrate_blender_mode":
			demonstrate_demo_blender()
		"show_universe_evolution":
			demonstrate_demo_evolution()

func create_demo_consciousness_burst() -> void:
	"""Create a burst of consciousness data points for demo"""
	if not database_visualizer:
		return
	
	for i in range(10):
		var random_pos = Vector3(
			randf_range(-8, 8),
			randf_range(2, 6),
			randf_range(-8, 8)
		)
		database_visualizer.create_consciousness_data_point(
			random_pos, 
			{"demo": "consciousness_burst", "index": i}, 
			randf_range(2.0, 5.0)
		)
	
	print("✨ Demo: Consciousness burst created!")

func show_demo_input_streams() -> void:
	"""Show explanation of input streams"""
	if input_stream_visualizer:
		# Create some demo input streams
		var demo_positions = [
			Vector3(-3, 3, 2),
			Vector3(0, 4, 1),
			Vector3(3, 3, 2)
		]
		
		for pos in demo_positions:
			input_stream_visualizer.create_custom_stream(
				InputStreamVisualizer.StreamType.KEYBOARD_INPUT,
				pos,
				"DEMO"
			)
	
	print("⌨️ Demo: Input streams demonstration!")

func demonstrate_demo_gravity() -> void:
	"""Demonstrate gravity field attraction"""
	if database_visualizer:
		# Create a temporary strong gravity point
		var center_pos = Vector3(0, 4, 0)
		database_visualizer.create_gravity_field_at_position(center_pos, 12.0)
	
	print("🌍 Demo: Gravity field demonstration!")

func demonstrate_demo_motor() -> void:
	"""Demonstrate magnetic sphere motor"""
	if magnetic_sphere_motor:
		# Apply some magnetic impulses
		magnetic_sphere_motor.apply_magnetic_impulse(Vector3.UP, 2.0)
		await get_tree().create_timer(1.0).timeout
		magnetic_sphere_motor.apply_magnetic_impulse(Vector3.RIGHT, 1.5)
	
	print("🧲 Demo: Magnetic motor demonstration!")

func demonstrate_demo_blender() -> void:
	"""Demonstrate Blender-like reality editing"""
	if database_visualizer:
		# Show the blender mode briefly
		database_visualizer.toggle_blender_mode()
		await get_tree().create_timer(2.0).timeout
		database_visualizer.toggle_blender_mode()
	
	print("🎨 Demo: Blender mode demonstration!")

func demonstrate_demo_evolution() -> void:
	"""Demonstrate universe evolution"""
	if alive_game_universe:
		# Trigger some evolution
		alive_game_universe.request_ai_creation(
			AliveGameUniverse.SpaceclayType.CONSCIOUSNESS_CLAY,
			AliveGameUniverse.CreationTemplate.CONSCIOUSNESS_FLOWER,
			Vector3(randf_range(-5, 5), 1, randf_range(-5, 5))
		)
	
	print("🌱 Demo: Universe evolution demonstration!")

# ===== SYSTEM COORDINATION =====

func coordinate_system_interactions(delta: float) -> void:
	"""Coordinate interactions between all systems"""
	# Update consciousness level based on all systems
	update_global_consciousness_level()
	
	# Coordinate gravity effects
	coordinate_gravity_effects()
	
	# Sync magnetic motor with input streams
	sync_motor_with_input_streams()

func update_global_consciousness_level() -> void:
	"""Update global consciousness level from all systems"""
	var total_consciousness = 0.0
	var count = 0
	
	# Get consciousness from alive game universe
	if alive_game_universe:
		total_consciousness += alive_game_universe.consciousness_level
		count += 1
	
	# Get consciousness from magnetic motor
	if magnetic_sphere_motor:
		total_consciousness += magnetic_sphere_motor.get_consciousness_level()
		count += 1
	
	# Update shared data
	if count > 0:
		shared_consciousness_data.global_consciousness_level = total_consciousness / count

func coordinate_gravity_effects() -> void:
	"""Coordinate gravity effects across systems"""
	# This would synchronize gravity points between database visualizer and input streams
	pass

func sync_motor_with_input_streams() -> void:
	"""Synchronize magnetic motor with input stream activity"""
	if magnetic_sphere_motor and input_stream_visualizer:
		var stream_stats = input_stream_visualizer.get_stream_statistics()
		if stream_stats.total_active_streams > 10:
			# High input activity - boost motor sensitivity
			magnetic_sphere_motor.set_magnetic_field_strength(2.0)
		else:
			# Normal activity
			magnetic_sphere_motor.set_magnetic_field_strength(1.0)

# ===== EVENT HANDLERS =====

func _on_database_query(query_type: String, position: Vector3) -> void:
	"""Handle database query visualization"""
	if input_stream_visualizer:
		input_stream_visualizer.create_custom_stream(
			InputStreamVisualizer.StreamType.SYSTEM_COMMAND,
			position,
			{"query": query_type}
		)

func _on_input_stream_created(stream_data) -> void:
	"""Handle input stream creation"""
	# Create corresponding consciousness data point
	if database_visualizer:
		database_visualizer.create_consciousness_data_point(
			stream_data.world_position,
			{"source": "input_stream", "type": stream_data.stream_type},
			2.0
		)

func _on_motor_rotation_changed(new_rotation: Quaternion) -> void:
	"""Handle magnetic motor rotation changes"""
	# Could trigger consciousness flows based on rotation
	pass

func _on_spaceclay_being_created(being, position: Vector3) -> void:
	"""Handle spaceclay being creation"""
	if database_visualizer:
		database_visualizer.create_consciousness_data_point(
			position,
			{"event": "being_created", "type": being.creation_template},
			3.0
		)

func _on_universe_evolution(consciousness_level: float, new_beings: int) -> void:
	"""Handle universe evolution events"""
	shared_consciousness_data.global_consciousness_level = consciousness_level

# ===== SYSTEM MANAGEMENT =====

func update_shared_consciousness_data(delta: float) -> void:
	"""Update shared consciousness data across systems"""
	# Update active beings list
	shared_consciousness_data.active_beings = get_tree().get_nodes_in_group("universal_beings")
	
	# Update consciousness flows
	if database_visualizer:
		shared_consciousness_data.consciousness_flows = database_visualizer.consciousness_streams

func monitor_system_performance(delta: float) -> void:
	"""Monitor performance across all systems"""
	system_performance_metrics = {
		"fps": Engine.get_frames_per_second(),
		"active_data_points": database_visualizer.active_data_points.size() if database_visualizer else 0,
		"active_streams": input_stream_visualizer.active_streams.size() if input_stream_visualizer else 0,
		"magnetic_fields": magnetic_sphere_motor.magnetic_fields.size() if magnetic_sphere_motor else 0,
		"consciousness_level": shared_consciousness_data.global_consciousness_level
	}

# ===== PUBLIC API =====

func get_integration_status() -> Dictionary:
	"""Get comprehensive integration status"""
	return {
		"systems_ready": systems_ready,
		"integration_active": integration_active,
		"demo_mode": demo_mode,
		"connected_systems": {
			"database_visualizer": database_visualizer != null,
			"input_stream_visualizer": input_stream_visualizer != null,
			"magnetic_sphere_motor": magnetic_sphere_motor != null,
			"alive_game_universe": alive_game_universe != null
		},
		"shared_consciousness": shared_consciousness_data,
		"performance": system_performance_metrics,
		"gravity_points": global_gravity_points.size()
	}

func toggle_demo_mode() -> void:
	"""Toggle automated demo mode"""
	demo_mode = !demo_mode
	if demo_mode and auto_demo_timer:
		auto_demo_timer.start()
	elif auto_demo_timer:
		auto_demo_timer.stop()
	
	print("🎭 Demo mode: %s" % ("ON" if demo_mode else "OFF"))

func create_initial_gravity_points() -> void:
	"""Create initial gravity points for the demo"""
	if not database_visualizer:
		return
	
	# Create a central consciousness gravity well
	database_visualizer.create_gravity_field_at_position(Vector3(0, 3, 0), 6.0)
	
	# Create corner gravity points
	var corners = [
		Vector3(-8, 2, -8), Vector3(8, 2, -8),
		Vector3(-8, 2, 8), Vector3(8, 2, 8)
	]
	
	for corner in corners:
		database_visualizer.create_gravity_field_at_position(corner, 4.0)

func _to_string() -> String:
	return "LivingDatabaseIntegration [Systems: %d, Active: %s, Demo: %s]" % [
		get_connected_system_count(), 
		"YES" if integration_active else "NO",
		"YES" if demo_mode else "NO"
	]

func get_connected_system_count() -> int:
	var count = 0
	if database_visualizer: count += 1
	if input_stream_visualizer: count += 1
	if magnetic_sphere_motor: count += 1
	if alive_game_universe: count += 1
	return count