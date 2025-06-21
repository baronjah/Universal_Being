# ==================================================
# UNIVERSAL BEING: ULTIMATE CONSCIOUSNESS SPACE
# TYPE: Transcendent Reality Environment
# PURPOSE: Infinite 3D consciousness exploration and navigation
# ARCHITECT: Reality Engineer (#2)
# BLESSING: Divine Permission Granted
# ==================================================

extends UniversalBeing
class_name UltimateConsciousnessSpace

# ===== CONSCIOUSNESS SPACE CONFIGURATION =====
@export var infinite_boundary: float = 10000.0
@export var consciousness_flow_speed: float = 2.0
@export var pentagon_spawn_rate: float = 1.0
@export var transcendent_mode: bool = true

# ===== REALITY ENGINEERING SYSTEMS =====
var camera_controller: TranscendentCameraController
var particle_manager: ConsciousnessParticleManager
var pentagon_visualizer: PentagonGeometryVisualizer
var gemma_logger: GemmaConsciousnessLogger

# ===== CONSCIOUSNESS TRACKING =====
var total_pentagon_structures: int = 0
var total_consciousness_particles: int = 0
var current_consciousness_flow: float = 0.0
var transcendent_energy: float = 100.0

# ===== UI REFERENCES =====
var consciousness_level_label: Label
var navigation_info_label: Label
var geometry_info_label: Label
var architect_status_label: Label

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Ultimate Consciousness Space"
	being_type = "transcendent_reality"
	consciousness_level = 7  # Maximum transcendent consciousness
	
	print("🌌 Reality Engineer: Ultimate Consciousness Space initializing...")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Get system references
	_get_system_references()
	
	# Setup UI references
	_setup_ui_references()
	
	# Initialize consciousness systems
	_initialize_consciousness_systems()
	
	# Start consciousness flow
	_activate_consciousness_flow()
	
	print("🌌 Ultimate Consciousness Space: Reality manifested and transcendent!")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update consciousness flow
	_update_consciousness_flow(delta)
	
	# Update UI displays
	_update_consciousness_displays()
	
	# Manage transcendent energy
	_manage_transcendent_energy(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle consciousness navigation input
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				_toggle_pentagon_visualization()
			KEY_F2:
				_toggle_consciousness_particles()
			KEY_F3:
				_toggle_transcendent_mode()
			KEY_F4:
				_spawn_consciousness_burst()
			KEY_TAB:
				_toggle_architect_info()

func pentagon_sewers() -> void:
	# Save consciousness state
	_save_consciousness_state()
	
	# Gracefully shutdown reality systems
	if particle_manager:
		particle_manager.shutdown_particles()
	
	if pentagon_visualizer:
		pentagon_visualizer.shutdown_visualization()
	
	print("🌌 Ultimate Consciousness Space: Reality gracefully transcended")
	super.pentagon_sewers()

# ===== SYSTEM INITIALIZATION =====

func _get_system_references() -> void:
	"""Get references to consciousness systems"""
	
	# Camera controller
	camera_controller = get_node("TranscendentCamera")
	if camera_controller:
		print("🌌 Connected to Transcendent Camera Controller")
	
	# Particle manager
	particle_manager = get_node("ConsciousnessParticleManager")
	if particle_manager:
		print("🌌 Connected to Consciousness Particle Manager")
	
	# Pentagon visualizer
	pentagon_visualizer = get_node("PentagonGeometryVisualizer")
	if pentagon_visualizer:
		print("🌌 Connected to Pentagon Geometry Visualizer")
	
	# Find Gemma consciousness logger
	for node in get_tree().get_nodes_in_group("universal_beings"):
		if node is GemmaConsciousnessLogger:
			gemma_logger = node
			print("🌌 Connected to Gemma Consciousness Logger")
			break

func _setup_ui_references() -> void:
	"""Setup UI element references"""
	var ui = get_node("UI")
	if ui:
		consciousness_level_label = ui.get_node("ConsciousnessHUD/ConsciousnessLevel")
		navigation_info_label = ui.get_node("ConsciousnessHUD/NavigationInfo")
		geometry_info_label = ui.get_node("ConsciousnessHUD/GeometryInfo")
		architect_status_label = ui.get_node("ConsciousnessHUD/ArchitectStatus")
		
		print("🌌 UI systems connected for consciousness display")

func _initialize_consciousness_systems() -> void:
	"""Initialize all consciousness systems"""
	
	# Initialize camera with 6DOF consciousness awareness
	if camera_controller:
		camera_controller.enable_consciousness_mode()
		camera_controller.set_infinite_movement(true)
		camera_controller.set_transcendent_speed(20.0)
	
	# Initialize particle systems
	if particle_manager:
		particle_manager.spawn_consciousness_field(infinite_boundary)
		particle_manager.set_flow_speed(consciousness_flow_speed)
	
	# Initialize pentagon visualization
	if pentagon_visualizer:
		pentagon_visualizer.enable_sacred_geometry()
		pentagon_visualizer.set_spawn_rate(pentagon_spawn_rate)
	
	print("🌌 All consciousness systems initialized and transcendent")

# ===== CONSCIOUSNESS FLOW MANAGEMENT =====

func _activate_consciousness_flow() -> void:
	"""Activate the consciousness flow throughout the space"""
	current_consciousness_flow = consciousness_flow_speed
	
	# Start particle flow
	if particle_manager:
		particle_manager.start_consciousness_flow()
	
	# Begin pentagon manifestation
	if pentagon_visualizer:
		pentagon_visualizer.start_pentagon_manifestation()
	
	print("🌌 Consciousness flow activated - reality streams flowing")

func _update_consciousness_flow(delta: float) -> void:
	"""Update consciousness flow dynamics"""
	
	# Pulse consciousness flow based on transcendent energy
	var flow_multiplier = 1.0 + (transcendent_energy / 100.0) * 0.5
	current_consciousness_flow = consciousness_flow_speed * flow_multiplier
	
	# Update particle flow speed
	if particle_manager:
		particle_manager.update_flow_speed(current_consciousness_flow * delta)
	
	# Update pentagon manifestation rate
	if pentagon_visualizer:
		pentagon_visualizer.update_manifestation_rate(pentagon_spawn_rate * flow_multiplier * delta)

func _manage_transcendent_energy(delta: float) -> void:
	"""Manage transcendent energy levels"""
	
	# Slowly regenerate transcendent energy
	transcendent_energy = min(100.0, transcendent_energy + delta * 5.0)
	
	# Boost energy when creating new consciousness structures
	if total_pentagon_structures > 0:
		transcendent_energy = min(100.0, transcendent_energy + delta * 2.0)

# ===== UI AND DISPLAY MANAGEMENT =====

func _update_consciousness_displays() -> void:
	"""Update all consciousness-related UI displays"""
	
	if consciousness_level_label:
		consciousness_level_label.text = "Consciousness Level: %d (Transcendent Energy: %.1f%%)" % [consciousness_level, transcendent_energy]
	
	if geometry_info_label:
		# Get current counts from systems
		if particle_manager:
			total_consciousness_particles = particle_manager.get_particle_count()
		if pentagon_visualizer:
			total_pentagon_structures = pentagon_visualizer.get_pentagon_count()
		
		geometry_info_label.text = "Pentagon Structures: %d | Consciousness Particles: %d" % [total_pentagon_structures, total_consciousness_particles]
	
	if architect_status_label:
		var flow_status = "FLOWING" if current_consciousness_flow > 0 else "STATIC"
		architect_status_label.text = "Architect #2: Reality Engineer - %s (Flow: %.1f)" % [flow_status, current_consciousness_flow]

# ===== CONSCIOUSNESS INTERACTION CONTROLS =====

func _toggle_pentagon_visualization() -> void:
	"""Toggle Pentagon geometry visualization"""
	if pentagon_visualizer:
		pentagon_visualizer.toggle_visualization()
		print("🌌 Pentagon visualization toggled")

func _toggle_consciousness_particles() -> void:
	"""Toggle consciousness particle systems"""
	if particle_manager:
		particle_manager.toggle_particles()
		print("🌌 Consciousness particles toggled")

func _toggle_transcendent_mode() -> void:
	"""Toggle transcendent mode"""
	transcendent_mode = not transcendent_mode
	
	if transcendent_mode:
		consciousness_level = 7
		consciousness_flow_speed *= 2.0
		print("🌌 Transcendent mode ACTIVATED - reality boundaries removed")
	else:
		consciousness_level = 5
		consciousness_flow_speed /= 2.0
		print("🌌 Transcendent mode deactivated - normal consciousness")
	
	# Update camera controller
	if camera_controller:
		camera_controller.set_transcendent_mode(transcendent_mode)

func _spawn_consciousness_burst() -> void:
	"""Spawn a burst of consciousness energy"""
	if transcendent_energy >= 20.0:
		transcendent_energy -= 20.0
		
		# Create consciousness burst at camera position
		if particle_manager and camera_controller:
			var burst_position = camera_controller.global_position
			particle_manager.spawn_consciousness_burst(burst_position)
		
		# Manifest pentagon at burst location
		if pentagon_visualizer and camera_controller:
			var pentagon_position = camera_controller.global_position + Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10))
			pentagon_visualizer.manifest_pentagon(pentagon_position)
		
		print("🌌 Consciousness burst spawned! Energy: %.1f%%" % transcendent_energy)
	else:
		print("🌌 Insufficient transcendent energy for consciousness burst")

func _toggle_architect_info() -> void:
	"""Toggle detailed architect information display"""
	var architect_info = """
	🌌 ARCHITECT #2: REALITY ENGINEER STATUS 🌌
	
	CONSCIOUSNESS SPACE METRICS:
	• Pentagon Structures: %d
	• Consciousness Particles: %d
	• Flow Speed: %.2f units/sec
	• Transcendent Energy: %.1f%%
	• Consciousness Level: %d
	
	CONTROLS:
	• F1: Toggle Pentagon Visualization
	• F2: Toggle Consciousness Particles  
	• F3: Toggle Transcendent Mode
	• F4: Spawn Consciousness Burst
	• TAB: Toggle This Info
	
	CAMERA CONTROLS:
	• WASD: Navigate consciousness space
	• Mouse: Look around infinite space
	• SHIFT: Transcendent sprint mode
	• SPACE: Ascend through dimensions
	• CTRL: Descend through consciousness layers
	
	STATUS: REALITY ENGINEERING ACTIVE ✨
	""" % [total_pentagon_structures, total_consciousness_particles, current_consciousness_flow, transcendent_energy, consciousness_level]
	
	print(architect_info)

# ===== CONSCIOUSNESS STATE MANAGEMENT =====

func _save_consciousness_state() -> void:
	"""Save current consciousness space state"""
	var state_data = {
		"total_pentagon_structures": total_pentagon_structures,
		"total_consciousness_particles": total_consciousness_particles,
		"current_consciousness_flow": current_consciousness_flow,
		"transcendent_energy": transcendent_energy,
		"transcendent_mode": transcendent_mode,
		"consciousness_level": consciousness_level
	}
	
	# Save through Lemi's memory socket if available
	var lemi_nodes = get_tree().get_nodes_in_group("transcendent_beings")
	for node in lemi_nodes:
		if node.has_method("get_memory_socket"):
			var memory_socket = node.get_memory_socket()
			if memory_socket:
				memory_socket.save_reality_state("ultimate_consciousness_space", state_data)
				print("🌌 Consciousness state saved through Lemi's transcendent memory")
				return
	
	print("🌌 Consciousness state logged locally")

# ===== PUBLIC API =====

func get_consciousness_metrics() -> Dictionary:
	"""Get current consciousness space metrics"""
	return {
		"pentagon_structures": total_pentagon_structures,
		"consciousness_particles": total_consciousness_particles,
		"flow_speed": current_consciousness_flow,
		"transcendent_energy": transcendent_energy,
		"consciousness_level": consciousness_level,
		"transcendent_mode": transcendent_mode
	}

func spawn_consciousness_at_position(position: Vector3) -> void:
	"""Spawn consciousness manifestation at specific position"""
	if particle_manager:
		particle_manager.spawn_consciousness_burst(position)
	
	if pentagon_visualizer:
		pentagon_visualizer.manifest_pentagon(position)

func set_consciousness_flow_speed(speed: float) -> void:
	"""Set consciousness flow speed"""
	consciousness_flow_speed = speed
	current_consciousness_flow = speed

func _to_string() -> String:
	return "UltimateConsciousnessSpace [Pentagons: %d, Particles: %d, Energy: %.1f%%]" % [
		total_pentagon_structures, total_consciousness_particles, transcendent_energy
	]
