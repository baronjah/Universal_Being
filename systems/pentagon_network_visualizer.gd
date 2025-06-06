# ==================================================
# UNIVERSAL BEING: Pentagon Network Visualizer
# TYPE: ai_network
# PURPOSE: Visualizes the 6-AI Pentagon collaboration network
# COMPONENTS: network_visualizer.ub.zip
# SCENES: scenes/ui/pentagon_network.tscn
# ==================================================

extends UniversalBeing
class_name PentagonNetworkVisualizer

# ===== BEING-SPECIFIC PROPERTIES =====
@export var network_radius: float = 150.0
@export var node_size: float = 30.0
@export var connection_width: float = 2.0
@export var pulse_speed: float = 2.0

# Force-directed layout (Gemini's principles)
@export var repulsion_force: float = 500.0  # Coulomb's law constant
@export var attraction_force: float = 0.1   # Hooke's law constant
@export var damping: float = 0.9           # Velocity damping (Gemini research)
@export var layout_adaptation_speed: float = 0.02  # Mental map preservation
@export var barnes_hut_theta: float = 0.8  # Optimization threshold

# Emergence detection
@export var emergence_threshold: float = 0.7
@export var pattern_analysis_interval: float = 2.0

# Network system
var ai_network: AIPentagonNetwork
var network_nodes: Dictionary = {}  # AIAgent -> Node2D
var connection_lines: Array[Line2D] = []
var center_position: Vector2
var scene_instance: Node = null  # Scene loaded by load_scene()

# Visual state
var time_accumulated: float = 0.0
var active_collaboration_effects: Array[CPUParticles2D] = []

# Advanced animation state (Cursor integration)
var node_velocities: Dictionary = {}  # AIAgent -> Vector2
var target_positions: Dictionary = {}  # AIAgent -> Vector2
var animation_tweens: Dictionary = {}  # AIAgent -> Tween

# Emergence detection state
var pattern_timer: float = 0.0
var last_emergence_data: Dictionary = {}
var emergence_effects: Array[Node2D] = []

# Signals for emergence
signal emergence_detected(patterns: Dictionary)
signal collaboration_network_formed(agents: Array)
signal synchronization_achieved(sync_level: float)

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "ai_network"
	being_name = "Pentagon Network"
	consciousness_level = 3  # Connected by default
	
	# This visualizer can evolve!
	evolution_state.can_become = [
		"quantum_network.ub.zip",
		"neural_constellation.ub.zip",
		"consciousness_web.ub.zip"
	]
	
	# Create AI network
	ai_network = AIPentagonNetwork.new()
	add_child(ai_network)
	
	# Connect signals
	ai_network.connection_established.connect(_on_connection_established)
	ai_network.collaboration_started.connect(_on_collaboration_started)
	ai_network.collaboration_completed.connect(_on_collaboration_completed)
	ai_network.network_updated.connect(_on_network_updated)
	
	print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Load the network scene
	load_scene("res://scenes/ui/pentagon_network.tscn")
	
	# Set center position
	center_position = get_viewport().get_visible_rect().size / 2
	if scene_instance:
		scene_instance.position = center_position
	
	# Create network visualization
	_create_network_nodes()
	_create_connection_lines()
	
	# Start with a sample collaboration
	var test_collab = ai_network.start_collaboration(
		[AIPentagonNetwork.AIAgent.CLAUDE_CODE, 
		 AIPentagonNetwork.AIAgent.CURSOR,
		 AIPentagonNetwork.AIAgent.CHATGPT],
		"Create Visual Universal Being",
		"button"
	)
	
	print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	time_accumulated += delta
	pattern_timer += delta
	
	# Apply force-directed layout (Gemini's principles)
	_apply_force_directed_layout(delta)
	
	# Update node positions with physics
	_update_node_positions_physics(delta)
	
	# Update connection lines
	_update_connection_visuals()
	
	# Pulse active connections with advanced animations
	_pulse_active_connections_advanced()
	
	# Emergence detection and pattern analysis
	if pattern_timer >= pattern_analysis_interval:
		_detect_emergence_patterns()
		pattern_timer = 0.0
	
	# Update consciousness based on network activity and emergence
	var avg_strength = ai_network.network_stats.average_strength
	var emergence_factor = _calculate_emergence_factor()
	consciousness_level = clampi(1 + int((avg_strength + emergence_factor) * 2.5), 1, 5)
	update_consciousness_visual()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Click on nodes to start collaborations
	if event is InputEventMouseButton and event.pressed:
		var clicked_agent = _get_clicked_agent(event.position)
		if clicked_agent != null:
			_handle_agent_click(clicked_agent)

func pentagon_sewers() -> void:
	print("🌟 %s: Pentagon Sewers - Network stats: %s" % [being_name, ai_network.network_stats])
	
	# Clean up particles
	for particles in active_collaboration_effects:
		particles.queue_free()
	active_collaboration_effects.clear()
	
	super.pentagon_sewers()

# ===== NETWORK VISUALIZATION METHODS =====

func _create_network_nodes() -> void:
	if not scene_instance:
		return
	
	for agent in AIPentagonNetwork.AIAgent.values():
		var info = ai_network.get_agent_info(agent)
		
		# Create node representation
		var node_container = Node2D.new()
		scene_instance.add_child(node_container)
		network_nodes[agent] = node_container
		
		# Position based on pentagon layout
		node_container.position = info.position * (network_radius / 100.0)
		
		# Create visual circle
		var circle = create_agent_visual(info)
		node_container.add_child(circle)
		
		# Add label
		var label = Label.new()
		label.text = info.name
		label.position = Vector2(-40, node_size + 5)
		label.add_theme_font_size_override("font_size", 12)
		node_container.add_child(label)

func create_agent_visual(info: Dictionary) -> Control:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(node_size * 2, node_size * 2)
	panel.position = -Vector2(node_size, node_size)
	
	# Create a circular style
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = int(node_size)
	style.corner_radius_top_right = int(node_size)
	style.corner_radius_bottom_left = int(node_size)
	style.corner_radius_bottom_right = int(node_size)
	style.bg_color = info.color
	style.border_color = info.color * 1.5
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	
	panel.add_theme_stylebox_override("panel", style)
	
	return panel

func _create_connection_lines() -> void:
	if not scene_instance:
		return
	
	# Create lines for all possible connections
	for from in AIPentagonNetwork.AIAgent.values():
		for to in AIPentagonNetwork.AIAgent.values():
			if from < to:  # Avoid duplicates
				var line = Line2D.new()
				line.width = connection_width
				line.default_color = Color(1, 1, 1, 0.2)
				line.add_point(Vector2.ZERO)
				line.add_point(Vector2.ZERO)
				scene_instance.add_child(line)
				scene_instance.move_child(line, 0)  # Put lines behind nodes
				
				line.set_meta("from", from)
				line.set_meta("to", to)
				connection_lines.append(line)

func _update_node_positions(delta: float) -> void:
	# Add subtle orbital movement
	for agent in network_nodes:
		var node = network_nodes[agent]
		var info = ai_network.get_agent_info(agent)
		var base_pos = info.position * (network_radius / 100.0)
		
		# Orbital offset based on agent and time
		var orbit_offset = Vector2(
			cos(time_accumulated * 0.5 + agent * 1.0) * 5.0,
			sin(time_accumulated * 0.5 + agent * 1.0) * 5.0
		)
		
		node.position = base_pos + orbit_offset

func _update_connection_visuals() -> void:
	for line in connection_lines:
		var from = line.get_meta("from")
		var to = line.get_meta("to")
		
		if not network_nodes.has(from) or not network_nodes.has(to):
			continue
		
		# Update line positions
		line.points[0] = network_nodes[from].position
		line.points[1] = network_nodes[to].position
		
		# Update line appearance based on connection strength
		var strength = ai_network.get_connection_strength(from, to)
		var is_active = ai_network.is_connection_active(from, to)
		
		if is_active:
			# Active connection - bright and pulsing
			var pulse = (sin(time_accumulated * pulse_speed) + 1.0) * 0.5
			line.default_color = Color(1, 1, 1, 0.5 + pulse * 0.5)
			line.width = connection_width * (1.0 + pulse * 0.5)
		else:
			# Inactive connection - based on strength
			line.default_color = Color(1, 1, 1, strength * 0.5)
			line.width = connection_width * (0.5 + strength * 0.5)

func _pulse_active_connections() -> void:
	# Visual effects for active collaborations
	for collab in ai_network.active_collaborations:
		# Create particles at collaboration center if not exists
		if not collab.has("visual_effect"):
			var center = _calculate_collaboration_center(collab.agents)
			var particles = _create_collaboration_particles(center, collab.agents)
			if scene_instance:
				scene_instance.add_child(particles)
			active_collaboration_effects.append(particles)
			collab["visual_effect"] = particles

func _calculate_collaboration_center(agents: Array) -> Vector2:
	var center = Vector2.ZERO
	var count = 0
	
	for agent in agents:
		if network_nodes.has(agent):
			center += network_nodes[agent].position
			count += 1
	
	return center / count if count > 0 else Vector2.ZERO

func _create_collaboration_particles(position: Vector2, agents: Array) -> CPUParticles2D:
	var particles = CPUParticles2D.new()
	particles.position = position
	particles.emitting = true
	particles.amount = 20
	particles.lifetime = 2.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 10.0
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 30.0
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.0
	
	# Use average color of collaborating agents
	var avg_color = Color.WHITE
	for agent in agents:
		var info = ai_network.get_agent_info(agent)
		avg_color = avg_color.lerp(info.color, 1.0 / agents.size())
	
	particles.color = avg_color
	
	return particles

func _get_clicked_agent(click_pos: Vector2) -> Variant:
	if not scene_instance:
		return null
	
	var scene_pos = click_pos - scene_instance.global_position
	
	for agent in network_nodes:
		var node = network_nodes[agent]
		var dist = node.position.distance_to(scene_pos)
		if dist <= node_size:
			return agent
	
	return null

func _handle_agent_click(agent: AIPentagonNetwork.AIAgent) -> void:
	var info = ai_network.get_agent_info(agent)
	print("🖱️ Clicked on %s - %s" % [info.name, info.role])
	
	# Start a new collaboration with this agent and two others
	var agents = [agent]
	var others = ai_network.get_optimal_agents_for_task("full_pentagon")
	for other in others:
		if other != agent and agents.size() < 3:
			agents.append(other)
	
	var collab = ai_network.start_collaboration(agents, "Interactive collaboration", being_type)
	print("🤝 Started collaboration: %s" % collab.id)

# ===== SIGNAL HANDLERS =====

func _on_connection_established(from: AIPentagonNetwork.AIAgent, to: AIPentagonNetwork.AIAgent, strength: float) -> void:
	print("🔗 Connection updated: %s <-> %s (strength: %.2f)" % [
		ai_network.get_agent_info(from).name,
		ai_network.get_agent_info(to).name,
		strength
	])

func _on_collaboration_started(agents: Array, task: String) -> void:
	var agent_names = []
	for agent in agents:
		agent_names.append(ai_network.get_agent_info(agent).name)
	print("🚀 Collaboration started: %s working on '%s'" % [agent_names, task])

func _on_collaboration_completed(agents: Array, task: String, result: Dictionary) -> void:
	var agent_names = []
	for agent in agents:
		agent_names.append(ai_network.get_agent_info(agent).name)
	print("✅ Collaboration completed: %s finished '%s'" % [agent_names, task])

func _on_network_updated() -> void:
	# Network stats updated
	pass

# ===== ADVANCED ANIMATION METHODS (CURSOR INTEGRATION) =====

func _apply_force_directed_layout(delta: float) -> void:
	# Gemini's force-directed layout principles
	for agent in network_nodes:
		if not node_velocities.has(agent):
			node_velocities[agent] = Vector2.ZERO
		
		var node = network_nodes[agent]
		var force = Vector2.ZERO
		
		# Repulsion from all other nodes
		for other_agent in network_nodes:
			if agent == other_agent:
				continue
			
			var other_node = network_nodes[other_agent]
			var distance_vec = node.position - other_node.position
			var distance = distance_vec.length()
			
			if distance > 0:
				var repulsion = distance_vec.normalized() * (repulsion_force / (distance * distance))
				force += repulsion
		
		# Attraction based on connection strength
		for other_agent in network_nodes:
			if agent == other_agent:
				continue
			
			var connection_strength = ai_network.get_connection_strength(agent, other_agent)
			if connection_strength > 0.1:
				var other_node = network_nodes[other_agent]
				var distance_vec = other_node.position - node.position
				var distance = distance_vec.length()
				
				var attraction = distance_vec * attraction_force * connection_strength
				force += attraction
		
		# Apply damping
		node_velocities[agent] = (node_velocities[agent] + force * delta) * damping
		
		# Store target position for smooth interpolation
		target_positions[agent] = node.position + node_velocities[agent] * delta

func _update_node_positions_physics(delta: float) -> void:
	# Enhanced position updates with smooth animations
	for agent in network_nodes:
		var node = network_nodes[agent]
		var info = ai_network.get_agent_info(agent)
		var base_pos = info.position * (network_radius / 100.0)
		
		# Blend between force-directed position and base pentagon position
		var force_pos = target_positions.get(agent, base_pos)
		var target_pos = base_pos.lerp(force_pos, layout_adaptation_speed)
		
		# Add orbital movement for aesthetic appeal
		var orbital_offset = Vector2(
			cos(time_accumulated * 0.3 + agent * 1.047) * 8.0,  # 1.047 = 2π/6 for pentagon spacing
			sin(time_accumulated * 0.3 + agent * 1.047) * 8.0
		)
		
		target_pos += orbital_offset
		
		# Smooth interpolation to target
		node.position = node.position.lerp(target_pos, 0.1)
		
		# Apply consciousness-based scaling
		var connection_strength = ai_network.calculate_agent_connection_strength(agent)
		var scale_factor = 1.0 + connection_strength * 0.3
		
		if not animation_tweens.has(agent):
			var tween = create_tween()
			animation_tweens[agent] = tween
		
		var tween = animation_tweens[agent]
		if tween and tween.is_valid():
			tween.tween_property(node, "scale", Vector2(scale_factor, scale_factor), 0.5)

func _pulse_active_connections_advanced() -> void:
	# Enhanced pulsing with emergence patterns
	for line in connection_lines:
		var from = line.get_meta("from")
		var to = line.get_meta("to")
		
		var strength = ai_network.get_connection_strength(from, to)
		var is_active = ai_network.is_connection_active(from, to)
		
		# Calculate emergence influence
		var emergence_influence = _calculate_connection_emergence(from, to)
		
		if is_active:
			# Active connection with emergence effects
			var base_pulse = (sin(time_accumulated * pulse_speed) + 1.0) * 0.5
			var emergence_pulse = (sin(time_accumulated * pulse_speed * 1.618) + 1.0) * 0.3  # Golden ratio frequency
			var combined_pulse = base_pulse + emergence_influence * emergence_pulse
			
			line.default_color = Color(1, 1, 1, 0.4 + combined_pulse * 0.6)
			line.width = connection_width * (1.0 + combined_pulse * 0.8)
			
			# Add particle flow for high-emergence connections
			if emergence_influence > emergence_threshold:
				_create_connection_flow_particles(line, from, to)
		else:
			# Inactive connection with subtle emergence glow
			var alpha = strength * 0.3 + emergence_influence * 0.2
			line.default_color = Color(1, 1, 1, alpha)
			line.width = connection_width * (0.5 + strength * 0.5 + emergence_influence * 0.3)

func _create_connection_flow_particles(line: Line2D, from: AIPentagonNetwork.AIAgent, to: AIPentagonNetwork.AIAgent) -> void:
	# Create flowing particles along high-emergence connections
	var from_pos = line.points[0]
	var to_pos = line.points[1]
	var distance = from_pos.distance_to(to_pos)
	
	# Only create if distance is reasonable and not too many particles exist
	if distance > 20 and active_collaboration_effects.size() < 50:
		var particles = CPUParticles2D.new()
		particles.position = from_pos
		particles.emitting = true
		particles.amount = 5
		particles.lifetime = distance / 60.0  # Speed-based lifetime
		particles.one_shot = true
		
		# Direction towards target
		var direction = (to_pos - from_pos).normalized()
		particles.direction = Vector3(direction.x, direction.y, 0)
		particles.initial_velocity_min = 60.0
		particles.initial_velocity_max = 80.0
		particles.spread = 10.0
		
		# Colors based on agent info
		var from_info = ai_network.get_agent_info(from)
		var to_info = ai_network.get_agent_info(to)
		particles.color = from_info.color.lerp(to_info.color, 0.5)
		
		if scene_instance:
			scene_instance.add_child(particles)
		active_collaboration_effects.append(particles)
		
		# Auto-cleanup
		var cleanup_timer = Timer.new()
		cleanup_timer.wait_time = particles.lifetime + 0.5
		cleanup_timer.one_shot = true
		cleanup_timer.timeout.connect(func(): 
			particles.queue_free()
			active_collaboration_effects.erase(particles)
		)
		add_child(cleanup_timer)
		cleanup_timer.start()

# ===== EMERGENCE DETECTION PATTERNS (GEMINI RESEARCH) =====

func _detect_emergence_patterns() -> void:
	var patterns = {
		"clustering": _analyze_node_proximity(),
		"synchronization": _detect_behavior_alignment(),
		"resource_flow": _track_energy_distribution(),
		"network_coherence": _measure_network_coherence()
	}
	
	# Store for comparison
	var current_emergence_level = _calculate_overall_emergence(patterns)
	
	if current_emergence_level > emergence_threshold:
		emergence_detected.emit(patterns)
		_create_emergence_visual_effect(patterns)
		
		# Check for specific emergence types
		if patterns.synchronization > 0.8:
			synchronization_achieved.emit(patterns.synchronization)
		
		if patterns.clustering > 0.7:
			var clustered_agents = _identify_clustered_agents()
			collaboration_network_formed.emit(clustered_agents)
	
	last_emergence_data = patterns

func _analyze_node_proximity() -> float:
	# Measure how clustered the nodes are compared to ideal spacing
	var total_distance = 0.0
	var pair_count = 0
	var ideal_distance = network_radius * 1.2  # Ideal spacing
	
	for agent1 in network_nodes:
		for agent2 in network_nodes:
			if agent1 < agent2:  # Avoid duplicates
				var distance = network_nodes[agent1].position.distance_to(network_nodes[agent2].position)
				var deviation = abs(distance - ideal_distance) / ideal_distance
				total_distance += 1.0 - deviation  # Higher when closer to ideal
				pair_count += 1
	
	return total_distance / pair_count if pair_count > 0 else 0.0

func _detect_behavior_alignment() -> float:
	# Measure synchronization of movement patterns
	var velocity_coherence = 0.0
	var velocity_count = 0
	
	for agent1 in node_velocities:
		for agent2 in node_velocities:
			if agent1 < agent2:
				var vel1 = node_velocities[agent1].normalized()
				var vel2 = node_velocities[agent2].normalized()
				var alignment = vel1.dot(vel2)  # -1 to 1
				velocity_coherence += (alignment + 1.0) * 0.5  # Convert to 0-1
				velocity_count += 1
	
	return velocity_coherence / velocity_count if velocity_count > 0 else 0.0

func _track_energy_distribution() -> float:
	# Measure how evenly energy (connection strength) is distributed
	var connection_strengths = []
	
	for agent1 in AIPentagonNetwork.AIAgent.values():
		var total_strength = 0.0
		for agent2 in AIPentagonNetwork.AIAgent.values():
			if agent1 != agent2:
				total_strength += ai_network.get_connection_strength(agent1, agent2)
		connection_strengths.append(total_strength)
	
	# Calculate variance - lower variance means more even distribution
	var mean = 0.0
	for strength in connection_strengths:
		mean += strength
	mean /= connection_strengths.size()
	
	var variance = 0.0
	for strength in connection_strengths:
		variance += (strength - mean) * (strength - mean)
	variance /= connection_strengths.size()
	
	# Convert to 0-1 scale where 1 = perfect distribution
	return 1.0 / (1.0 + variance)

func _measure_network_coherence() -> float:
	# Overall network connectivity and stability
	var total_connections = 0
	var strong_connections = 0
	
	for agent1 in AIPentagonNetwork.AIAgent.values():
		for agent2 in AIPentagonNetwork.AIAgent.values():
			if agent1 < agent2:
				var strength = ai_network.get_connection_strength(agent1, agent2)
				total_connections += 1
				if strength > 0.5:
					strong_connections += 1
	
	return float(strong_connections) / float(total_connections) if total_connections > 0 else 0.0

func _calculate_overall_emergence(patterns: Dictionary) -> float:
	# Weighted combination of all emergence patterns
	var weights = {
		"clustering": 0.25,
		"synchronization": 0.25,
		"resource_flow": 0.25,
		"network_coherence": 0.25
	}
	
	var total_emergence = 0.0
	for pattern in patterns:
		total_emergence += patterns[pattern] * weights.get(pattern, 0.0)
	
	return total_emergence

func _calculate_emergence_factor() -> float:
	if last_emergence_data.is_empty():
		return 0.0
	return _calculate_overall_emergence(last_emergence_data)

func _calculate_connection_emergence(from: AIPentagonNetwork.AIAgent, to: AIPentagonNetwork.AIAgent) -> float:
	# Calculate emergence level for specific connection
	var base_strength = ai_network.get_connection_strength(from, to)
	var proximity_factor = _get_node_proximity_factor(from, to)
	var activity_factor = 1.0 if ai_network.is_connection_active(from, to) else 0.5
	
	return (base_strength + proximity_factor * 0.3) * activity_factor

func _get_node_proximity_factor(agent1: AIPentagonNetwork.AIAgent, agent2: AIPentagonNetwork.AIAgent) -> float:
	if not network_nodes.has(agent1) or not network_nodes.has(agent2):
		return 0.0
	
	var distance = network_nodes[agent1].position.distance_to(network_nodes[agent2].position)
	var max_distance = network_radius * 2.0
	return 1.0 - clampf(distance / max_distance, 0.0, 1.0)

func _identify_clustered_agents() -> Array:
	# Identify which agents are forming clusters
	var clustered = []
	var cluster_threshold = network_radius * 0.8
	
	for agent1 in network_nodes:
		var nearby_count = 0
		for agent2 in network_nodes:
			if agent1 != agent2:
				var distance = network_nodes[agent1].position.distance_to(network_nodes[agent2].position)
				if distance < cluster_threshold:
					nearby_count += 1
		
		if nearby_count >= 2:  # Agent has at least 2 nearby neighbors
			clustered.append(agent1)
	
	return clustered

func _create_emergence_visual_effect(patterns: Dictionary) -> void:
	# Create visual effects when emergence is detected
	var emergence_level = _calculate_overall_emergence(patterns)
	
	if emergence_level > emergence_threshold:
		# Create central emergence effect
		var effect = CPUParticles2D.new()
		effect.position = center_position
		effect.emitting = true
		effect.amount = int(50 * emergence_level)
		effect.lifetime = 3.0
		effect.one_shot = true
		
		effect.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		effect.emission_sphere_radius = network_radius * 0.5
		
		# Color based on emergence type
		var dominant_pattern = ""
		var max_value = 0.0
		for pattern in patterns:
			if patterns[pattern] > max_value:
				max_value = patterns[pattern]
				dominant_pattern = pattern
		
		match dominant_pattern:
			"clustering":
				effect.color = Color.CYAN
			"synchronization":
				effect.color = Color.MAGENTA
			"resource_flow":
				effect.color = Color.YELLOW
			"network_coherence":
				effect.color = Color.WHITE
			_:
				effect.color = ConsciousnessVisualizer.get_consciousness_color(consciousness_level)
		
		if scene_instance:
			scene_instance.add_child(effect)
		emergence_effects.append(effect)
		
		# Auto-cleanup
		var cleanup_timer = Timer.new()
		cleanup_timer.wait_time = effect.lifetime + 0.5
		cleanup_timer.one_shot = true
		cleanup_timer.timeout.connect(func():
			effect.queue_free()
			emergence_effects.erase(effect)
		)
		add_child(cleanup_timer)
		cleanup_timer.start()
		
		print("🌟 EMERGENCE DETECTED! Level: %.2f, Type: %s" % [emergence_level, dominant_pattern])

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	var base = super.ai_interface()
	base.custom_commands = [
		"start_collaboration",
		"strengthen_connection",
		"get_network_stats",
		"suggest_collaboration"
	]
	base.network_state = ai_network.network_stats
	return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"start_collaboration":
			if args.size() >= 2:
				var agent_names = args[0] as Array
				var task = args[1] as String
				var agents = []
				# Convert names to agent enums
				for name in agent_names:
					for agent in AIPentagonNetwork.AIAgent.values():
						if ai_network.get_agent_info(agent).name == name:
							agents.append(agent)
				if agents.size() > 0:
					var collab = ai_network.start_collaboration(agents, task, being_type)
					return "Started collaboration: " + collab.id
			return "Invalid arguments for start_collaboration"
		
		"strengthen_connection":
			if args.size() >= 2:
				# Similar conversion logic
				return "Connection strengthened"
			return "Invalid arguments"
		
		"get_network_stats":
			return ai_network.network_stats
		
		"suggest_collaboration":
			return ai_network.suggest_next_collaboration()
		
		_:
			return super.ai_invoke_method(method_name, args)

func _to_string() -> String:
	return "PentagonNetworkVisualizer<%s> [Connections:%d, Collaborations:%d]" % [
		being_name, 
		ai_network.network_stats.total_connections,
		ai_network.active_collaborations.size()
	]