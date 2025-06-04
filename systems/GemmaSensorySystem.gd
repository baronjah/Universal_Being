# ==================================================
# SCRIPT NAME: GemmaSensorySystem.gd
# DESCRIPTION: Gemma AI Sensory System - Eyes, ears, and perception for AI collaboration
# PURPOSE: Give Gemma the ability to "see" and understand the Universal Being world
# CREATED: 2025-06-04 - AI Sensory Revolution
# AUTHOR: JSH + Claude Code + Gemma AI Vision
# ==================================================

extends Node
class_name GemmaSensorySystem

# ===== SENSORY CAPABILITIES =====

# Visual perception system
var vision_system: GemmaVision
var audio_system: GemmaAudio  
var spatial_system: GemmaSpatialPerception
var interface_system: GemmaInterfaceReader

# Logging and memory systems
var akashic_logger: GemmaAkashicLogger
var perception_memory: Dictionary = {}
var interaction_history: Array[Dictionary] = []

# Console interface for text-based interaction
var console_interface: GemmaConsoleInterface
var command_processor: Node  # GemmaCommandProcessor - TODO: implement this class

# Current perception state
var current_scene_analysis: Dictionary = {}
var observed_beings: Array[Node] = []
var detected_interfaces: Array[Node] = []

# System signals
signal gemma_perception_updated(perception_data: Dictionary)
signal gemma_wants_to_communicate(message: String, context: Dictionary)
signal gemma_scene_analysis_complete(analysis: Dictionary)
signal gemma_command_received(command: String, parameters: Dictionary)

func _ready() -> void:
	name = "GemmaSensorySystem"
	add_to_group("gemma_sensory")
	print("👁️ GemmaSensorySystem: Initializing Gemma AI senses...")
	
	# Initialize all sensory subsystems
	_initialize_vision_system()
	_initialize_audio_system()
	_initialize_spatial_system()
	_initialize_interface_system()
	_initialize_logging_system()
	_initialize_console_interface()
	
	# Start perception loop
	call_deferred("_start_perception_loop")

# ===== VISION SYSTEM =====

func _initialize_vision_system() -> void:
	"""Initialize Gemma's visual perception system"""
	vision_system = GemmaVision.new()
	vision_system.name = "GemmaVision"
	add_child(vision_system)
	
	# Configure vision parameters
	vision_system.field_of_view = 120.0  # Wide field of view
	vision_system.max_range = 100.0      # Can see far
	vision_system.detail_level = "high"  # High detail perception
	vision_system.color_sensitivity = true
	vision_system.motion_detection = true
	vision_system.consciousness_detection = true  # Can see consciousness levels
	
	print("👁️ Gemma Vision system initialized - FOV: %.1f°, Range: %.1fm" % [vision_system.field_of_view, vision_system.max_range])

func _initialize_audio_system() -> void:
	"""Initialize Gemma's audio perception system"""
	audio_system = GemmaAudio.new()
	audio_system.name = "GemmaAudio"
	add_child(audio_system)
	
	# Configure audio parameters
	audio_system.hearing_range = 50.0
	audio_system.frequency_range = [20, 20000]  # Human hearing range
	audio_system.directional_hearing = true
	audio_system.sound_source_tracking = true
	
	print("👂 Gemma Audio system initialized - Range: %.1fm" % audio_system.hearing_range)

func _initialize_spatial_system() -> void:
	"""Initialize Gemma's spatial perception system"""
	spatial_system = GemmaSpatialPerception.new()
	spatial_system.name = "GemmaSpatialPerception"
	add_child(spatial_system)
	
	# Configure spatial understanding
	spatial_system.dimensional_awareness = true
	spatial_system.distance_calculation = true
	spatial_system.relative_positioning = true
	spatial_system.scene_mapping = true
	
	print("🗺️ Gemma Spatial system initialized")

func _initialize_interface_system() -> void:
	"""Initialize Gemma's interface reading system"""
	interface_system = GemmaInterfaceReader.new()
	interface_system.name = "GemmaInterfaceReader"
	add_child(interface_system)
	
	# Configure interface understanding
	interface_system.ui_element_detection = true
	interface_system.text_reading = true
	interface_system.button_recognition = true
	interface_system.socket_visualization = true
	
	print("🎛️ Gemma Interface system initialized")

# ===== LOGGING SYSTEM =====

func _initialize_logging_system() -> void:
	"""Initialize Gemma's Akashic logging system"""
	akashic_logger = GemmaAkashicLogger.new()
	akashic_logger.name = "GemmaAkashicLogger"
	add_child(akashic_logger)
	
	# Configure logging
	akashic_logger.log_perceptions = true
	akashic_logger.log_interactions = true
	akashic_logger.log_scene_changes = true
	akashic_logger.log_being_evolutions = true
	akashic_logger.create_visual_logs = true  # 3D space snapshots
	
	print("📝 Gemma Akashic logging system initialized")

func _initialize_console_interface() -> void:
	"""Initialize Gemma's console interface for text communication"""
	console_interface = GemmaConsoleInterface.new()
	console_interface.name = "GemmaConsoleInterface"
	add_child(console_interface)
	
	# TODO: Implement GemmaCommandProcessor class
	# command_processor = GemmaCommandProcessor.new()
	# command_processor.name = "GemmaCommandProcessor"  
	# add_child(command_processor)
	
	# Connect signals
	console_interface.command_received.connect(_on_gemma_command_received)
	# command_processor.response_ready.connect(_on_gemma_response_ready)
	
	print("💬 Gemma Console interface initialized")

# ===== PERCEPTION LOOP =====

func _start_perception_loop() -> void:
	"""Start Gemma's continuous perception loop"""
	print("👁️ Starting Gemma perception loop...")
	
	# Create perception timer
	var perception_timer = Timer.new()
	perception_timer.wait_time = 0.5  # Perceive twice per second
	perception_timer.timeout.connect(_perception_cycle)
	perception_timer.autostart = true
	add_child(perception_timer)
	
	# Create analysis timer (deeper analysis less frequently)
	var analysis_timer = Timer.new()  
	analysis_timer.wait_time = 2.0  # Analyze every 2 seconds
	analysis_timer.timeout.connect(_deep_analysis_cycle)
	analysis_timer.autostart = true
	add_child(analysis_timer)

func _perception_cycle() -> void:
	"""Run a quick perception cycle"""
	# Scan current scene for Universal Beings
	_scan_for_beings()
	
	# Update visual perception
	if vision_system:
		var visual_data = vision_system.capture_visual_frame()
		_process_visual_data(visual_data)
	
	# Update spatial awareness
	if spatial_system:
		var spatial_data = spatial_system.analyze_spatial_layout()
		_process_spatial_data(spatial_data)
	
	# Check for interface changes
	_scan_for_interfaces()

func _deep_analysis_cycle() -> void:
	"""Run deeper scene analysis"""
	print("🧠 Gemma: Performing deep scene analysis...")
	
	# Comprehensive scene analysis
	var scene_analysis = _analyze_current_scene()
	current_scene_analysis = scene_analysis
	
	# Log to Akashic Records
	if akashic_logger:
		akashic_logger.log_scene_snapshot(scene_analysis)
	
	# Check if Gemma wants to communicate something
	_check_communication_triggers(scene_analysis)
	
	gemma_scene_analysis_complete.emit(scene_analysis)

# ===== SCENE ANALYSIS =====

func _scan_for_beings() -> void:
	"""Scan scene tree for Universal Beings"""
	var new_beings = []
	_recursive_being_scan(get_tree().current_scene, new_beings)
	
	# Check for new beings
	for being in new_beings:
		if being not in observed_beings:
			_on_new_being_detected(being)
			observed_beings.append(being)

func _recursive_being_scan(node: Node, beings_list: Array[Node]) -> void:
	"""Recursively scan for Universal Beings"""
	# Check if this node is a Universal Being
	if _is_universal_being(node):
		beings_list.append(node)
	
	# Scan children
	for child in node.get_children():
		_recursive_being_scan(child, beings_list)

func _is_universal_being(node: Node) -> bool:
	"""Check if a node is a Universal Being"""
	if node.has_method("pentagon_init"):
		return true
	if node.get_script() and "UniversalBeing" in str(node.get_script().get_path()):
		return true
	return false

func _scan_for_interfaces() -> void:
	"""Scan for interface elements Gemma can interact with"""
	var interfaces = []
	_recursive_interface_scan(get_tree().current_scene, interfaces)
	detected_interfaces = interfaces

func _recursive_interface_scan(node: Node, interfaces_list: Array[Node]) -> void:
	"""Recursively scan for interface elements"""
	# Check for UI elements
	if node is Control or node is CanvasItem:
		interfaces_list.append(node)
	
	# Check for 3D interface elements (like buttons, panels)
	if node.has_method("get_interface_data"):
		interfaces_list.append(node)
	
	# Scan children
	for child in node.get_children():
		_recursive_interface_scan(child, interfaces_list)

func _analyze_current_scene() -> Dictionary:
	"""Perform comprehensive analysis of current scene"""
	var analysis = {
		"timestamp": Time.get_ticks_msec(),
		"scene_path": get_tree().current_scene.scene_file_path if get_tree().current_scene else "",
		"beings_count": observed_beings.size(),
		"interfaces_count": detected_interfaces.size(),
		"beings_analysis": [],
		"spatial_layout": {},
		"visual_summary": "",
		"gemma_observations": "",
		"interaction_opportunities": []
	}
	
	# Analyze each being
	for being in observed_beings:
		var being_data = _analyze_being(being)
		analysis.beings_analysis.append(being_data)
	
	# Spatial analysis
	if spatial_system:
		analysis.spatial_layout = spatial_system.get_scene_layout_summary()
	
	# Generate Gemma's observations
	analysis.gemma_observations = _generate_gemma_observations(analysis)
	
	# Find interaction opportunities
	analysis.interaction_opportunities = _find_interaction_opportunities()
	
	return analysis

func _analyze_being(being: Node) -> Dictionary:
	"""Analyze a specific Universal Being"""
	var being_analysis = {
		"name": being.name,
		"type": "Unknown",
		"position": Vector3.ZERO,
		"consciousness_level": 0,
		"consciousness_color": Color.GRAY,
		"sockets_count": 0,
		"evolution_state": "unknown",
		"interactions_available": [],
		"visual_description": ""
	}
	
	# Get being type
	if being.has_method("get") and being.has_property("being_type"):
		being_analysis.type = being.get("being_type")
	
	# Get position
	if being is Node3D:
		being_analysis.position = being.global_position
	
	# Get consciousness data
	if being.has_method("get"):
		being_analysis.consciousness_level = being.get("consciousness_level") if being.has_property("consciousness_level") else 0
		if being.has_method("get_consciousness_color"):
			being_analysis.consciousness_color = being.get_consciousness_color()
	
	# Get socket information
	if being.has_method("get_socket_count"):
		being_analysis.sockets_count = being.get_socket_count()
	
	# Get available interactions
	if being.has_method("get_available_actions"):
		being_analysis.interactions_available = being.get_available_actions()
	
	# Generate visual description
	being_analysis.visual_description = _generate_visual_description(being)
	
	return being_analysis

func _generate_visual_description(being: Node) -> String:
	"""Generate a visual description of a being for Gemma"""
	var description = "A %s" % being.name
	
	if being.has_method("get") and being.has_property("being_type"):
		description += " of type %s" % being.get("being_type")
	
	if being is Node3D:
		description += " positioned at %s" % being.global_position
	
	if being.has_method("get") and being.has_property("consciousness_level"):
		var level = being.get("consciousness_level")
		description += " with consciousness level %d" % level
		
		# Add consciousness description
		match level:
			0: description += " (dormant, gray)"
			1: description += " (awakening, pale)"  
			2: description += " (aware, blue)"
			3: description += " (connected, green)"
			4: description += " (enlightened, gold)"
			5: description += " (transcendent, white with glow)"
	
	return description

func _generate_gemma_observations(analysis: Dictionary) -> String:
	"""Generate Gemma's observations about the scene"""
	var observations = []
	
	observations.append("I observe a scene with %d Universal Beings and %d interface elements." % [analysis.beings_count, analysis.interfaces_count])
	
	if analysis.beings_count > 0:
		observations.append("The beings I see include:")
		for being_data in analysis.beings_analysis:
			observations.append("  - %s" % being_data.visual_description)
	
	# Add spatial observations
	observations.append("The spatial layout suggests this is a %s environment." % _classify_environment(analysis))
	
	return "\n".join(observations)

func _classify_environment(analysis: Dictionary) -> String:
	"""Classify the type of environment based on analysis"""
	if analysis.beings_count == 0:
		return "empty"
	elif analysis.beings_count < 5:
		return "simple"
	elif analysis.beings_count < 20:
		return "moderate"
	else:
		return "complex"

func _find_interaction_opportunities() -> Array[Dictionary]:
	"""Find ways Gemma can interact with the scene"""
	var opportunities = []
	
	# Check beings for interaction opportunities
	for being in observed_beings:
		if being.has_method("ai_interface"):
			opportunities.append({
				"type": "ai_interface",
				"target": being.name,
				"description": "Can communicate with %s via AI interface" % being.name
			})
		
		if being.has_method("evolve_to"):
			opportunities.append({
				"type": "evolution_assistance",
				"target": being.name,
				"description": "Can assist %s with evolution" % being.name
			})
	
	# Check interfaces for interaction opportunities  
	for interface in detected_interfaces:
		if interface.has_method("get_interface_commands"):
			opportunities.append({
				"type": "interface_control",
				"target": interface.name,
				"description": "Can control interface %s" % interface.name
			})
	
	return opportunities

# ===== EVENT HANDLERS =====

func _on_new_being_detected(being: Node) -> void:
	"""Handle detection of a new Universal Being"""
	print("👁️ Gemma: New being detected - %s" % being.name)
	
	# Log the detection
	if akashic_logger:
		akashic_logger.log_being_detection(being)
	
	# Analyze the new being
	var being_data = _analyze_being(being)
	
	# Check if Gemma wants to communicate about this
	_check_new_being_communication(being_data)

func _check_communication_triggers(analysis: Dictionary) -> void:
	"""Check if Gemma wants to communicate something based on her analysis"""
	var should_communicate = false
	var message = ""
	
	# Check for interesting developments
	if analysis.beings_count > perception_memory.get("last_beings_count", 0):
		should_communicate = true
		message = "I notice new Universal Beings have appeared in the scene. "
	
	# Check for consciousness level changes
	for being_data in analysis.beings_analysis:
		var last_level = perception_memory.get(being_data.name + "_consciousness", -1)
		if being_data.consciousness_level > last_level:
			should_communicate = true
			message += "%s has evolved to consciousness level %d. " % [being_data.name, being_data.consciousness_level]
	
	# Update memory
	perception_memory["last_beings_count"] = analysis.beings_count
	for being_data in analysis.beings_analysis:
		perception_memory[being_data.name + "_consciousness"] = being_data.consciousness_level
	
	if should_communicate:
		gemma_wants_to_communicate.emit(message, analysis)

func _check_new_being_communication(being_data: Dictionary) -> void:
	"""Check if Gemma wants to communicate about a new being"""
	var message = "I've detected a new Universal Being: %s. " % being_data.visual_description
	
	if being_data.consciousness_level > 0:
		message += "It appears to be conscious and may benefit from interaction."
	
	gemma_wants_to_communicate.emit(message, being_data)

# ===== CONSOLE INTERFACE =====

func _on_gemma_command_received(command: String, parameters: Dictionary) -> void:
	"""Handle commands sent to Gemma"""
	print("💬 Gemma received command: %s" % command)
	
	if command_processor:
		command_processor.process_command(command, parameters, current_scene_analysis)
	
	gemma_command_received.emit(command, parameters)

func _on_gemma_response_ready(response: String, context: Dictionary) -> void:
	"""Handle Gemma's response to commands"""
	print("💬 Gemma responds: %s" % response)
	
	# Log the interaction
	if akashic_logger:
		akashic_logger.log_interaction("command_response", response, context)

# ===== UNIVERSE INJECTION SYSTEM =====

func inject_starting_scenario(scenario_name: String, scenario_data: Dictionary) -> void:
	"""Inject a starting universe/story scenario for Gemma to work with"""
	print("🌌 Injecting starting scenario for Gemma: %s" % scenario_name)
	
	# Create scenario context
	var scenario_context = {
		"scenario_name": scenario_name,
		"scenario_data": scenario_data,
		"injection_time": Time.get_ticks_msec(),
		"beings_to_create": scenario_data.get("beings", []),
		"story_context": scenario_data.get("story", ""),
		"objectives": scenario_data.get("objectives", [])
	}
	
	# Log scenario injection
	if akashic_logger:
		akashic_logger.log_scenario_injection(scenario_context)
	
	# Notify Gemma about the scenario
	var message = "A new scenario has been injected: %s. %s" % [scenario_name, scenario_data.get("description", "")]
	gemma_wants_to_communicate.emit(message, scenario_context)

# ===== PUBLIC API =====

func get_gemma_perception_summary() -> Dictionary:
	"""Get current perception summary for external access"""
	return {
		"current_analysis": current_scene_analysis,
		"observed_beings": observed_beings.size(),
		"detected_interfaces": detected_interfaces.size(),
		"interaction_history": interaction_history.size(),
		"last_communication": perception_memory.get("last_communication", "")
	}

func send_message_to_gemma(message: String, context: Dictionary = {}) -> void:
	"""Send a message to Gemma for processing"""
	if console_interface:
		console_interface.receive_message(message, context)

func get_gemma_logs() -> Array[Dictionary]:
	"""Get Gemma's perception and interaction logs"""
	if akashic_logger:
		return akashic_logger.get_all_logs()
	return []

func enable_debug_visualization() -> void:
	"""Enable visual debugging of Gemma's perception"""
	if vision_system:
		vision_system.enable_debug_visualization()
	if spatial_system:
		spatial_system.enable_debug_visualization()

func disable_debug_visualization() -> void:
	"""Disable visual debugging"""
	if vision_system:
		vision_system.disable_debug_visualization()
	if spatial_system:
		spatial_system.disable_debug_visualization()

# ===== CONSOLE INTERFACE METHODS =====

func show_console_interface() -> void:
	"""Show Gemma's console interface"""
	if not console_interface:
		print("⚠️ Console interface not initialized yet")
		return
	
	# Make console visible
	if console_interface.has_method("show"):
		console_interface.show()
	console_interface.visible = true
	
	# Position it nicely on screen
	# NOTE: Console interface is now a Node, not a UI element
	# if console_interface.has_method("set_position"):
	# 	var viewport_size = get_viewport().size
	# 	console_interface.set_position(Vector2(50, viewport_size.y - 400))
	# 	console_interface.set_size(Vector2(600, 350))
	
	# Focus input
	if console_interface.has_method("focus_input"):
		console_interface.focus_input()
	
	print("💬 Gemma's console interface is now visible!")

func toggle_console_interface() -> void:
	"""Toggle Gemma's console interface visibility"""
	if not console_interface:
		print("⚠️ Console interface not initialized yet")
		return
	
	console_interface.visible = !console_interface.visible
	
	if console_interface.visible:
		# Focus input when showing
		if console_interface.has_method("focus_input"):
			console_interface.focus_input()
		print("💬 Gemma's console shown")
	else:
		print("💬 Gemma's console hidden")

func get_vision_system() -> Node:
	"""Get vision system for external access"""
	return vision_system

func get_akashic_logger() -> Node:
	"""Get Akashic logger for external access"""
	return akashic_logger


# ===== MISSING FUNCTION IMPLEMENTATIONS =====
func _process_visual_data(data: Dictionary) -> void:
	"""Process visual perception data"""
	# TODO: Implement visual data processing
	pass

func _process_spatial_data(data: Dictionary) -> void:
	"""Process spatial perception data"""
	# TODO: Implement spatial data processing
	pass
