class_name GalaxyConnectionVisualizer
extends Node2D

# References
@export var connection_manager: WebsiteConnectionManager

# Visual properties
@export var node_radius: float = 40.0
@export var node_spacing: float = 150.0
@export var line_width: float = 2.0
@export var active_line_width: float = 4.0
@export var use_gradient: bool = true
@export var add_glow_effect: bool = true

# Node positions
var node_positions = {}
var selected_node = null
var hover_node = null

# Animation properties
var animation_time = 0.0
var node_pulse_speed = 1.0
var line_flow_speed = 0.5

# Interaction signals
signal node_selected(component_type)
signal node_hover(component_type)

func ready_new():
	# Calculate positions for the nodes in a galaxy-like pattern
	calculate_node_positions()
	
	# Connect to connection manager signals
	if connection_manager:
		connection_manager.connect("component_navigated", Callable(self, "_on_component_navigated"))
		connection_manager.connect("data_transferred", Callable(self, "_on_data_transferred"))

func process_new(delta):
	# Update animation time
	animation_time += delta
	
	# Request redraw to update animations
	queue_redraw()

func draw():
	if not connection_manager:
		return
	
	# Draw connections first (so they're behind nodes)
	draw_connections()
	
	# Draw nodes
	draw_nodes()

func calculate_node_positions():
	# Place JSH Ethereal Engine in the center
	node_positions[WebsiteConnectionManager.ComponentType.JSH_ETHEREAL_ENGINE] = Vector2(0, 0)
	
	# Calculate positions for other components in a circle around the center
	var angle_step = 2 * PI / 4  # 4 other components
	var radius = node_spacing * 1.5
	
	var angle = 0
	
	# Place Kit Analyzer
	node_positions[WebsiteConnectionManager.ComponentType.KIT_ANALYZER] = Vector2(
		cos(angle) * radius,
		sin(angle) * radius
	)
	angle += angle_step
	
	# Place NetSuite Console
	node_positions[WebsiteConnectionManager.ComponentType.NETSUITE_CONSOLE] = Vector2(
		cos(angle) * radius,
		sin(angle) * radius
	)
	angle += angle_step
	
	# Place Integrated Solution
	node_positions[WebsiteConnectionManager.ComponentType.INTEGRATED_SOLUTION] = Vector2(
		cos(angle) * radius,
		sin(angle) * radius
	)
	angle += angle_step
	
	# Place Enterprise Dev Suite
	node_positions[WebsiteConnectionManager.ComponentType.ENTERPRISE_DEV_SUITE] = Vector2(
		cos(angle) * radius,
		sin(angle) * radius
	)

func draw_connections():
	# Draw lines between connected components
	for connection in connection_manager.connections:
		var from_pos = node_positions[connection["from"]]
		var to_pos = node_positions[connection["to"]]
		
		# Determine line properties based on connection type and activity
		var line_color = Color.WHITE
		var current_line_width = line_width
		
		match connection["type"]:
			WebsiteConnectionManager.ConnectionType.DATA_FLOW:
				line_color = Color(0.2, 0.6, 1.0)  # Blue
			WebsiteConnectionManager.ConnectionType.NAVIGATION:
				line_color = Color(1.0, 0.6, 0.2)  # Orange
			WebsiteConnectionManager.ConnectionType.DEPENDENCY:
				line_color = Color(0.8, 0.2, 0.8)  # Purple
			WebsiteConnectionManager.ConnectionType.API_CALL:
				line_color = Color(0.2, 0.8, 0.2)  # Green
		
		# Increase width for active connection or selected nodes
		if connection["active"]:
			if selected_node != null and (selected_node == connection["from"] or selected_node == connection["to"]):
				current_line_width = active_line_width
				line_color = line_color.lightened(0.3)
		else:
			# Inactive connections are more transparent
			line_color.a = 0.3
		
		# Draw the connection line
		if use_gradient:
			# Create a gradient along the line
			draw_line_with_gradient(from_pos, to_pos, line_color, current_line_width)
		else:
			draw_line(from_pos, to_pos, line_color, current_line_width)
			
		# If there's active data flow, show animated particles
		if connection["data_flow"].size() > 0 and connection["active"]:
			draw_flow_particles(from_pos, to_pos, line_color)

func draw_line_with_gradient(from_pos, to_pos, color, width):
	# Create a gradient from source to destination
	var direction = (to_pos - from_pos).normalized()
	var length = from_pos.distance_to(to_pos)
	var points = []
	var colors = []
	
	# Calculate points along the line
	var steps = max(int(length / 20), 2)
	for i in range(steps):
		var t = float(i) / (steps - 1)
		var point = from_pos + direction * length * t
		points.append(point)
		
		# Calculate color with alpha based on position and animation
		var gradient_color = color
		gradient_color.a = 0.5 + 0.5 * sin(animation_time * line_flow_speed + t * PI * 2)
		colors.append(gradient_color)
	
	# Draw the multicolor line
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], colors[i], width)

func draw_flow_particles(from_pos, to_pos, color):
	var direction = (to_pos - from_pos).normalized()
	var length = from_pos.distance_to(to_pos)
	var particle_count = int(length / 20)
	
	for i in range(particle_count):
		var offset = fmod(animation_time * 50 + i * (length / particle_count), length)
		var pos = from_pos + direction * offset
		var particle_size = 3 + sin(animation_time * 5 + i) * 2
		
		draw_circle(pos, particle_size, color.lightened(0.5))

func draw_nodes():
	pass
	
func draw_nodes_new():
	for component_type in node_positions:
		var pos = node_positions[component_type]
		var name = connection_manager.components[component_type]["name"]
		var color = get_component_color(component_type)
		var radius = node_radius
		
		# If this is the selected node, make it larger
		if selected_node == component_type:
			radius *= 1.2
			color = color.lightened(0.2)
		
		# If this is the hover node, add a glow
		if hover_node == component_type:
			draw_circle(pos, radius * 1.5, color.darkened(0.5).with_alpha(0.3))
		
		# If this is the active component, make it pulse
		if connection_manager.active_component == component_type:
			radius += sin(animation_time * node_pulse_speed * 5) * 5
			
		# Draw the node
		draw_circle(pos, radius, color)
		
		# Add glow effect
		if add_glow_effect:
			for i in range(3):
				var glow_radius = radius * (1.0 + i * 0.15)
				var glow_color = color
				glow_color.a = 0.1 - i * 0.03
				draw_circle(pos, glow_radius, glow_color)
		
		# Draw node label
		var font# = get_theme_font("font", "Label")
		# Line 199:Function "get_theme_font()" not found in base self.

		var font_size# = get_theme_font_size("font_size", "Label")
		var text_color = Color.WHITE
		
		# Calculate text position (centered below the node)
		var text_pos = pos + Vector2(0, radius + 10)
		
		# Draw the text with a slight shadow for readability
		var short_name = name.split(" ")[0]  # Just use first word for space
		draw_string(font, text_pos + Vector2(1, 1), short_name, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0, 0, 0, 0.5))
		draw_string(font, text_pos, short_name, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, text_color)

func get_component_color(component_type):
	match component_type:
		WebsiteConnectionManager.ComponentType.JSH_ETHEREAL_ENGINE:
			return Color(0.2, 0.6, 1.0)  # Blue
		WebsiteConnectionManager.ComponentType.KIT_ANALYZER:
			return Color(0.2, 0.8, 0.2)  # Green
		WebsiteConnectionManager.ComponentType.NETSUITE_CONSOLE:
			return Color(1.0, 0.6, 0.2)  # Orange
		WebsiteConnectionManager.ComponentType.INTEGRATED_SOLUTION:
			return Color(0.8, 0.2, 0.8)  # Purple
		WebsiteConnectionManager.ComponentType.ENTERPRISE_DEV_SUITE:
			return Color(1.0, 0.2, 0.4)  # Red
		_:
			return Color.WHITE

func _input(event):
	# Handle mouse interactions
	if event is InputEventMouseMotion:
		check_hover(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		check_click(event.position)

func check_hover(mouse_pos):
	var old_hover = hover_node
	hover_node = null
	
	# Check if mouse is over any node
	for component_type in node_positions:
		var pos = node_positions[component_type]
		if pos.distance_to(mouse_pos) <= node_radius:
			hover_node = component_type
			break
	
	# Emit signal if hover changed
	if old_hover != hover_node:
		emit_signal("node_hover", hover_node)

func check_click(mouse_pos):
	# Check if mouse is over any node
	for component_type in node_positions:
		var pos = node_positions[component_type]
		if pos.distance_to(mouse_pos) <= node_radius:
			select_node(component_type)
			break

func select_node(component_type):
	selected_node = component_type
	emit_signal("node_selected", component_type)
	
	# Request component navigation
	connection_manager.navigate_to_component(component_type)

func _on_component_navigated(from_component, to_component):
	# Update the selected node
	selected_node = to_component
	queue_redraw()

func _on_data_transferred(from_component, to_component, data):
	# Could trigger a special animation for data flow
	queue_redraw()
