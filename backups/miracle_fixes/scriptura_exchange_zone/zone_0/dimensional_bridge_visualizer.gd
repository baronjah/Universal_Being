extends Node2D
class_name DimensionalBridgeVisualizer

# Visualization system for the Claude-Ethereal Bridge
# Creates visual representations of dimensional connections, memory flows,
# and resonance patterns between Claude AI and Ethereal Engine

# Appearance settings
var color_palette = {
	"claude": Color(0.2, 0.4, 0.8),        # Blue
	"ethereal": Color(0.8, 0.3, 0.7),      # Purple
	"memory": Color(0.3, 0.7, 0.4),        # Green
	"command": Color(0.8, 0.6, 0.2),       # Orange
	"data": Color(0.7, 0.2, 0.3),          # Red
	"astral": Color(0.8, 0.8, 0.2),        # Yellow
	"temporal": Color(0.2, 0.6, 0.8),      # Cyan
	"resonance": Color(1.0, 1.0, 1.0),     # White
	"background": Color(0.05, 0.05, 0.1)   # Dark blue
}

# Animation settings
const FLOW_SPEED = 2.0
const PULSE_SPEED = 0.8
const ROTATION_SPEED = 0.1

# Visualization elements
var dimensions = {}
var connections = {}
var memory_flows = {}
var resonances = {}

# References to required components
var claude_ethereal_bridge
var ethereal_engine_integration

# Dimensional layout
var center_position = Vector2(512, 300)
var radius = 200
var inner_radius = 100

# Signal declarations
signal dimension_clicked(dimension_name, dimension_type)
signal connection_clicked(source_name, target_name)
signal flow_completed(flow_id, source, target)

func _ready():
	print("🎨 Initializing Dimensional Bridge Visualizer")
	
	# Set background
	VisualServer.set_default_clear_color(color_palette.background)
	
	# Connect to required components
	_connect_to_systems()
	
	# Set up dimensions
	_setup_dimensions()
	
	# Set up initial connections
	_setup_connections()
	
	# Set up signal handlers
	_connect_signals()
	
	print("✨ Dimensional Bridge Visualizer ready")

func _connect_to_systems():
	# Find Claude Ethereal Bridge
	if has_node("/root/ClaudeEtherealBridge"):
		claude_ethereal_bridge = get_node("/root/ClaudeEtherealBridge")
		print("✓ Connected to Claude Ethereal Bridge")
	else:
		print("⚠ Claude Ethereal Bridge not found")
	
	# Find Ethereal Engine Integration
	if has_node("/root/EtherealEngineIntegration"):
		ethereal_engine_integration = get_node("/root/EtherealEngineIntegration")
		print("✓ Connected to Ethereal Engine Integration")
	else:
		print("⚠ Ethereal Engine Integration not found")

func _setup_dimensions():
	# Claude dimensions (inner circle)
	var claude_dimensions = ["short_term", "conversation", "long_term", "intuition", "imagination"]
	var claude_angle_step = 2 * PI / claude_dimensions.size()
	
	for i in range(claude_dimensions.size()):
		var angle = i * claude_angle_step
		var pos = center_position + Vector2(cos(angle), sin(angle)) * inner_radius
		
		dimensions[claude_dimensions[i]] = {
			"position": pos,
			"type": "claude",
			"color": color_palette.claude.lightened(0.2 * (i % 3)),
			"size": 30,
			"active": true,
			"pulse_phase": randf() * PI * 2,
			"angle": angle
		}
	
	# Ethereal dimensions (outer circle)
	var ethereal_dimensions = ["Memory", "Command", "Visual", "Data", "Temporal", "Astral", "Ethereal"]
	var ethereal_angle_step = 2 * PI / ethereal_dimensions.size()
	
	for i in range(ethereal_dimensions.size()):
		var angle = i * ethereal_angle_step
		var pos = center_position + Vector2(cos(angle), sin(angle)) * radius
		
		dimensions[ethereal_dimensions[i]] = {
			"position": pos,
			"type": "ethereal",
			"color": color_palette.ethereal.lightened(0.15 * (i % 5)),
			"size": 40,
			"active": true,
			"pulse_phase": randf() * PI * 2,
			"angle": angle
		}
	
	print("🔵 Initialized " + str(dimensions.size()) + " dimensions")

func _setup_connections():
	# Setup initial connections based on memory mapping
	if claude_ethereal_bridge:
		var mapping = claude_ethereal_bridge.memory_mapping
		
		# Connect Claude dimensions to Ethereal dimensions
		for claude_dim in mapping.claude:
			var ethereal_dim = mapping.claude[claude_dim]
			_add_connection(claude_dim, ethereal_dim)
	else:
		# Manual default mapping if bridge not available
		_add_connection("short_term", "Command")
		_add_connection("conversation", "Memory")
		_add_connection("long_term", "Data")
		_add_connection("intuition", "Astral")
		_add_connection("imagination", "Ethereal")
	
	print("🔗 Initialized " + str(connections.size()) + " connections")

func _connect_signals():
	if claude_ethereal_bridge:
		claude_ethereal_bridge.connect("claude_message_sent", _on_claude_message_sent)
		claude_ethereal_bridge.connect("claude_response_received", _on_claude_response_received)
		claude_ethereal_bridge.connect("memory_synchronized", _on_memory_synchronized)
		claude_ethereal_bridge.connect("dimension_resonance_detected", _on_dimension_resonance_detected)
	
	if ethereal_engine_integration:
		ethereal_engine_integration.connect("pathway_established", _on_pathway_established)
		ethereal_engine_integration.connect("luno_cycle_changed", _on_luno_cycle_changed)
		ethereal_engine_integration.connect("token_usage_updated", _on_token_usage_updated)

# Adding visual elements
func _add_connection(source: String, target: String):
	if source not in dimensions or target not in dimensions:
		print("⚠ Cannot add connection: dimensions not found")
		return null
	
	var connection_id = source + "_to_" + target
	
	if connection_id in connections:
		return connections[connection_id]
	
	connections[connection_id] = {
		"source": source,
		"target": target,
		"color": dimensions[source].color.linear_interpolate(dimensions[target].color, 0.5),
		"width": 2.0,
		"active": true,
		"flow_particles": [],
		"resonance": 0.0
	}
	
	print("🔗 Added connection: " + connection_id)
	return connections[connection_id]

func create_memory_flow(source: String, target: String, size: float = 1.0):
	if source not in dimensions or target not in dimensions:
		print("⚠ Cannot create memory flow: dimensions not found")
		return null
	
	var connection_id = source + "_to_" + target
	if connection_id not in connections:
		_add_connection(source, target)
	
	var flow_id = "flow_" + str(memory_flows.size())
	
	memory_flows[flow_id] = {
		"source": source,
		"target": target,
		"position": dimensions[source].position,
		"progress": 0.0,
		"size": size * 10, # Visual size of the memory particle
		"color": color_palette.memory,
		"speed": FLOW_SPEED * (0.8 + randf() * 0.4), # Randomize speed slightly
		"active": true,
		"completion_callback": null
	}
	
	print("💫 Created memory flow: " + flow_id)
	return flow_id

func create_resonance(source: String, target: String, strength: float = 0.8):
	if source not in dimensions or target not in dimensions:
		print("⚠ Cannot create resonance: dimensions not found")
		return null
	
	var connection_id = source + "_to_" + target
	if connection_id not in connections:
		_add_connection(source, target)
	
	var resonance_id = "resonance_" + str(resonances.size())
	
	resonances[resonance_id] = {
		"source": source,
		"target": target,
		"strength": strength,
		"pulse_speed": PULSE_SPEED * (1.0 + strength),
		"pulse_phase": randf() * PI * 2,
		"color": color_palette.resonance,
		"lifetime": 10.0, # Seconds until resonance fades
		"remaining_time": 10.0,
		"active": true
	}
	
	# Update connection resonance
	connections[connection_id].resonance = strength
	connections[connection_id].width = 2.0 + (strength * 6.0)
	
	print("✨ Created resonance: " + resonance_id + " (strength: " + str(strength) + ")")
	return resonance_id

func set_dimension_active(dimension: String, active: bool):
	if dimension not in dimensions:
		return
	
	dimensions[dimension].active = active
	
	print("🔵 Dimension " + dimension + " set to " + ("active" if active else "inactive"))

func set_connection_active(source: String, target: String, active: bool):
	var connection_id = source + "_to_" + target
	if connection_id not in connections:
		return
	
	connections[connection_id].active = active
	
	print("🔗 Connection " + connection_id + " set to " + ("active" if active else "inactive"))

func highlight_dimension(dimension: String, duration: float = 1.0):
	if dimension not in dimensions:
		return
	
	var original_size = dimensions[dimension].size
	dimensions[dimension].size *= 1.5
	
	# Revert after duration
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = duration
	timer.one_shot = true
	timer.connect("timeout", _on_highlight_timeout.bind(dimension, original_size))
	timer.start()
	
	print("🔆 Highlighting dimension: " + dimension)

func _on_highlight_timeout(dimension: String, original_size: float):
	if dimension in dimensions:
		dimensions[dimension].size = original_size

# Update and drawing
func _process(delta):
	# Update flow particles
	_update_flows(delta)
	
	# Update resonances
	_update_resonances(delta)
	
	# Update dimension pulses
	_update_dimensions(delta)
	
	# Request redraw
	queue_redraw()

func _update_flows(delta):
	var flows_to_remove = []
	
	for flow_id in memory_flows:
		var flow = memory_flows[flow_id]
		
		if not flow.active:
			continue
		
		# Update progress
		flow.progress += flow.speed * delta
		
		if flow.progress >= 1.0:
			# Flow completed, mark for removal
			emit_signal("flow_completed", flow_id, flow.source, flow.target)
			flows_to_remove.append(flow_id)
			continue
		
		# Update position
		var source_pos = dimensions[flow.source].position
		var target_pos = dimensions[flow.target].position
		flow.position = source_pos.linear_interpolate(target_pos, flow.progress)
	
	# Remove completed flows
	for flow_id in flows_to_remove:
		memory_flows.erase(flow_id)

func _update_resonances(delta):
	var resonances_to_remove = []
	
	for resonance_id in resonances:
		var resonance = resonances[resonance_id]
		
		if not resonance.active:
			continue
		
		# Update phase
		resonance.pulse_phase += resonance.pulse_speed * delta
		
		# Update lifetime
		resonance.remaining_time -= delta
		if resonance.remaining_time <= 0:
			resonances_to_remove.append(resonance_id)
			
			# Reset connection width
			var connection_id = resonance.source + "_to_" + resonance.target
			if connection_id in connections:
				connections[connection_id].resonance = 0.0
				connections[connection_id].width = 2.0
	
	# Remove expired resonances
	for resonance_id in resonances_to_remove:
		resonances.erase(resonance_id)

func _update_dimensions(delta):
	for dimension in dimensions.values():
		dimension.pulse_phase += PULSE_SPEED * delta
		
		# Slowly rotate dimensions
		dimension.angle += ROTATION_SPEED * delta
		var new_pos
		
		if dimension.type == "claude":
			new_pos = center_position + Vector2(cos(dimension.angle), sin(dimension.angle)) * inner_radius
		else:
			new_pos = center_position + Vector2(cos(dimension.angle), sin(dimension.angle)) * radius
			
		dimension.position = dimension.position.linear_interpolate(new_pos, delta * 0.5)

func _draw():
	# Draw connections
	for connection in connections.values():
		if not connection.active:
			continue
		
		var source_pos = dimensions[connection.source].position
		var target_pos = dimensions[connection.target].position
		
		# Calculate connection width with pulsing based on resonance
		var width = connection.width
		if connection.resonance > 0:
			var pulse_effect = sin(OS.get_ticks_msec() / 100.0) * 0.2 * connection.resonance
			width = max(1.0, width * (1.0 + pulse_effect))
		
		draw_line(source_pos, target_pos, connection.color, width, true)
	
	# Draw resonances
	for resonance in resonances.values():
		if not resonance.active:
			continue
		
		var source_pos = dimensions[resonance.source].position
		var target_pos = dimensions[resonance.target].position
		
		# Get the middle point for the resonance glow
		var mid_point = source_pos.linear_interpolate(target_pos, 0.5)
		
		# Calculate size based on phase
		var pulse = (sin(resonance.pulse_phase) * 0.5 + 0.5) * resonance.strength
		var size = 20 + (pulse * 40)
		
		# Draw glow
		var color = resonance.color
		color.a = resonance.strength * (resonance.remaining_time / 10.0) * 0.7
		
		draw_circle(mid_point, size, color)
	
	# Draw dimensions
	for dim_name in dimensions:
		var dimension = dimensions[dim_name]
		
		if not dimension.active:
			continue
		
		# Calculate pulse effect for size
		var pulse = sin(dimension.pulse_phase) * 0.1 + 0.9
		var size = dimension.size * pulse
		
		# Draw dimension circle
		draw_circle(dimension.position, size, dimension.color)
		
		# Draw dimension name
		var font_color = Color(1, 1, 1, 0.9)
		draw_string(default_font, dimension.position + Vector2(-dim_name.length() * 3, -size - 5), 
			dim_name, font_color)
	
	# Draw memory flows
	for flow in memory_flows.values():
		if not flow.active:
			continue
		
		# Draw particle with trail effect
		draw_circle(flow.position, flow.size, flow.color)
		
		# Optional: Draw trail
		var source_pos = dimensions[flow.source].position
		var current_pos = flow.position
		var trail_progress = flow.progress * 0.8  # Trail length as percentage of progress
		var trail_start = source_pos.linear_interpolate(current_pos, max(0, flow.progress - trail_progress))
		
		var trail_color = flow.color
		trail_color.a = 0.4
		draw_line(trail_start, current_pos, trail_color, flow.size * 0.7, true)

# Input handling
func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		# Check if clicked on a dimension
		for dim_name in dimensions:
			var dimension = dimensions[dim_name]
			var distance = dimension.position.distance_to(event.position)
			
			if distance <= dimension.size:
				print("🖱️ Dimension clicked: " + dim_name)
				emit_signal("dimension_clicked", dim_name, dimension.type)
				highlight_dimension(dim_name)
				return
		
		# Check if clicked on a connection (simplified)
		for connection_id in connections:
			var connection = connections[connection_id]
			var source_pos = dimensions[connection.source].position
			var target_pos = dimensions[connection.target].position
			
			# Check if click is near the line
			var closest_point = Geometry.get_closest_point_to_segment_2d(event.position, source_pos, target_pos)
			var distance = closest_point.distance_to(event.position)
			
			if distance <= 10:  # 10px threshold for clicking connections
				print("🖱️ Connection clicked: " + connection_id)
				emit_signal("connection_clicked", connection.source, connection.target)
				return

# Signal handlers
func _on_claude_message_sent(message, tokens_used):
	# Create memory flow from Command to Ethereal
	create_memory_flow("conversation", "Command", 1.0 + (tokens_used / 1000.0))
	highlight_dimension("conversation")

func _on_claude_response_received(response, tokens_used):
	# Create memory flow from Ethereal to Memory
	create_memory_flow("Command", "Memory", 1.0 + (tokens_used / 1000.0))
	highlight_dimension("Memory")

func _on_memory_synchronized(source_type, target_type, memory_count):
	if source_type in dimensions and target_type in dimensions:
		create_memory_flow(source_type, target_type, 0.5 + (memory_count / 20.0))
		highlight_dimension(target_type)

func _on_dimension_resonance_detected(claude_dimension, ethereal_dimension, strength):
	if claude_dimension in dimensions and ethereal_dimension in dimensions:
		create_resonance(claude_dimension, ethereal_dimension, strength)
		highlight_dimension(claude_dimension)
		highlight_dimension(ethereal_dimension)

func _on_pathway_established(from_dimension, to_dimension, pathway_id):
	if from_dimension in dimensions and to_dimension in dimensions:
		_add_connection(from_dimension, to_dimension)
		create_memory_flow(from_dimension, to_dimension, 1.5)

func _on_luno_cycle_changed(cycle, name):
	# Update visualization to reflect LUNO cycle
	var cycle_colors = [
		Color(0.7, 0.3, 0.3),  # Genesis (Red)
		Color(0.8, 0.4, 0.2),  # Formation (Orange)
		Color(0.8, 0.7, 0.2),  # Complexity (Yellow)
		Color(0.5, 0.8, 0.3),  # Consciousness (Green)
		Color(0.3, 0.8, 0.6),  # Awakening (Teal)
		Color(0.2, 0.6, 0.8),  # Enlightenment (Blue)
		Color(0.4, 0.4, 0.8),  # Manifestation (Indigo)
		Color(0.6, 0.3, 0.8),  # Connection (Purple)
		Color(0.8, 0.3, 0.7),  # Harmony (Pink)
		Color(0.8, 0.2, 0.4),  # Transcendence (Rose)
		Color(0.9, 0.9, 0.9),  # Unity (White)
		Color(0.3, 0.3, 0.3)   # Beyond (Gray)
	]
	
	# Update ethereal dimensions color
	for dim_name in dimensions:
		var dimension = dimensions[dim_name]
		if dimension.type == "ethereal":
			dimension.color = cycle_colors[(cycle - 1) % 12].lightened(0.1 * (dim_name.length() % 3))
	
	# Create resonance pulses in all dimensions
	var ethereal_dimensions = []
	for dim_name in dimensions:
		if dimensions[dim_name].type == "ethereal":
			ethereal_dimensions.append(dim_name)
	
	for i in range(ethereal_dimensions.size()):
		var dim1 = ethereal_dimensions[i]
		var dim2 = ethereal_dimensions[(i + 1) % ethereal_dimensions.size()]
		create_resonance(dim1, dim2, 0.5)

func _on_token_usage_updated(used, total, percentage):
	# Visualize token usage by adjusting dimension sizes
	for dim_name in dimensions:
		var dimension = dimensions[dim_name]
		if dimension.type == "claude":
			dimension.size = 30 * (1.0 - (percentage * 0.3))  # Shrink as tokens are used up
	
	# If usage is high, create memory flows to visualize
	if percentage > 0.7:
		create_memory_flow("short_term", "Command", percentage)