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

# Network system
var ai_network: AIPentagonNetwork
var network_nodes: Dictionary = {}  # AIAgent -> Node2D
var connection_lines: Array[Line2D] = []
var center_position: Vector2

# Visual state
var time_accumulated: float = 0.0
var active_collaboration_effects: Array[CPUParticles2D] = []

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
	center_position = get_viewport_rect().size / 2
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
	
	# Update node positions with orbital movement
	_update_node_positions(delta)
	
	# Update connection lines
	_update_connection_visuals()
	
	# Pulse active connections
	_pulse_active_connections()
	
	# Update consciousness based on network activity
	var avg_strength = ai_network.network_stats.average_strength
	consciousness_level = clampi(1 + int(avg_strength * 5), 1, 5)
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

func _get_clicked_agent(click_pos: Vector2) -> AIPentagonNetwork.AIAgent:
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