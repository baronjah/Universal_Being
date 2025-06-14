extends Spatial

class_name CenteredVisualizer3D

# Centered 3D Visualizer with console integration
# Creates a visualization space for multi-source data with frame capture
# Supports debug console and shows center point with 8 corner points

# Node references
var console_node
var center_marker
var corner_markers = []
var frame_displays = []
var data_parser
var text_overlay

# Visualization settings
export var center_color = Color(1.0, 1.0, 0.0)  # Yellow
export var corner_color = Color(0.7, 0.7, 0.7)  # Light gray
export var background_color = Color(0.1, 0.1, 0.1)  # Very dark gray
export var console_color = Color(1.0, 1.0, 0.0, 0.8)  # Yellow with transparency
export var line_color = Color(0.5, 0.5, 0.5)  # Medium gray

# Frame capture settings
export var capture_interval = 0.5  # Seconds between frame captures
export var max_frames = 12  # Maximum frames to store (12 turn system)
export var frame_spacing = 1.5  # Space between frames
var current_frame = 0
var frames = []
var capture_timer = 0

# Console settings
export var max_console_lines = 20
export var console_fade_time = 10.0
var console_lines = []
var console_active = true

# Data source tracking
var data_sources = {}
var active_source = ""

# Debug markers for spatial reference
var debug_markers_visible = true
var debug_lines_visible = true

# Signals
signal frame_captured(frame_number, frame_data)
signal console_updated(message)
signal source_changed(source_name)

func _ready():
	# Create the visualization environment
	_setup_environment()
	
	# Create center and corner markers
	_create_spatial_markers()
	
	# Create frame display nodes
	_create_frame_displays()
	
	# Create text overlay
	_create_text_overlay()
	
	# Initialize console
	_initialize_console()
	
	# Register default data sources
	register_data_source("godot", "Internal Godot Engine")
	register_data_source("file", "File System Reader")
	register_data_source("memory", "Memory Snapshot")
	register_data_source("akashic", "Akashic Records")
	
	# Set default active source
	set_active_source("godot")
	
	# Output initialization message
	console_log("Centered Visualizer 3D initialized")
	console_log("12 turn system active - " + str(max_frames) + " frames maximum")
	console_log("Default sources registered: godot, file, memory, akashic")

func _process(delta):
	# Update capture timer
	capture_timer += delta
	if capture_timer >= capture_interval:
		capture_timer = 0
		capture_frame()
	
	# Update console fade
	_update_console_fade(delta)
	
	# Update frame positions
	_update_frame_positions(delta)

# Setup the 3D environment
func _setup_environment():
	# Create environment
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = background_color
	environment.ambient_light_color = Color(0.3, 0.3, 0.3)
	environment.fog_enabled = true
	environment.fog_color = background_color
	environment.fog_depth_begin = 10
	environment.fog_depth_end = 30
	
	# Apply environment
	var world_environment = WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
	
	# Create camera
	var camera = Camera.new()
	camera.translation = Vector3(0, 0, 5)
	camera.current = true
	add_child(camera)
	
	# Add lighting
	var dir_light = DirectionalLight.new()
	dir_light.translation = Vector3(2, 3, 5)
	dir_light.look_at(Vector3.ZERO, Vector3.UP)
	add_child(dir_light)

# Create center and corner markers
func _create_spatial_markers():
	# Center marker
	center_marker = _create_marker(Vector3.ZERO, center_color, 0.2)
	add_child(center_marker)
	
	# Corner markers (8 points forming a cube)
	var corners = [
		Vector3(-1, -1, -1),
		Vector3( 1, -1, -1),
		Vector3(-1,  1, -1),
		Vector3( 1,  1, -1),
		Vector3(-1, -1,  1),
		Vector3( 1, -1,  1),
		Vector3(-1,  1,  1),
		Vector3( 1,  1,  1)
	]
	
	for corner in corners:
		var marker = _create_marker(corner, corner_color, 0.1)
		corner_markers.append(marker)
		add_child(marker)
	
	# Add lines connecting corners
	_add_corner_lines()

# Create a marker mesh instance
func _create_marker(position, color, size):
	var marker = MeshInstance.new()
	var mesh = SphereMesh.new()
	mesh.radius = size
	mesh.height = size * 2
	marker.mesh = mesh
	
	var material = SpatialMaterial.new()
	material.albedo_color = color
	material.emission = color
	material.emission_energy = 0.5
	marker.material_override = material
	
	marker.translation = position
	return marker

# Add lines connecting the corner markers
func _add_corner_lines():
	# Define connections between corners (edges of the cube)
	var connections = [
		[0, 1], [0, 2], [1, 3], [2, 3],  # Front face
		[4, 5], [4, 6], [5, 7], [6, 7],  # Back face
		[0, 4], [1, 5], [2, 6], [3, 7]   # Connecting edges
	]
	
	# Create immediate geometry for lines
	var line_drawer = ImmediateGeometry.new()
	line_drawer.name = "CornerLines"
	add_child(line_drawer)
	
	# Create material for lines
	var line_material = SpatialMaterial.new()
	line_material.albedo_color = line_color
	line_material.flags_unshaded = true
	
	# Connect corners with lines
	line_drawer.material_override = line_material
	line_drawer.begin(Mesh.PRIMITIVE_LINES)
	
	for connection in connections:
		var pos1 = corner_markers[connection[0]].translation
		var pos2 = corner_markers[connection[1]].translation
		
		line_drawer.add_vertex(pos1)
		line_drawer.add_vertex(pos2)
	
	line_drawer.end()

# Create frame display nodes
func _create_frame_displays():
	# Create a parent node for all frames
	var frames_node = Spatial.new()
	frames_node.name = "Frames"
	add_child(frames_node)
	
	# Create frame display objects
	for i in range(max_frames):
		var frame = _create_frame_display()
		frame.name = "Frame_" + str(i)
		frames_node.add_child(frame)
		frame_displays.append(frame)
		
		# Initialize frame data
		frames.append({
			"number": i,
			"data": null,
			"source": "",
			"timestamp": 0
		})
		
		# Position the frame (will be updated in _update_frame_positions)
		frame.visible = false

# Create a single frame display object
func _create_frame_display():
	# Create parent for the frame
	var frame_node = Spatial.new()
	
	# Create quad for display
	var quad = MeshInstance.new()
	var mesh = QuadMesh.new()
	mesh.size = Vector2(1, 1)
	quad.mesh = mesh
	
	# Create material for the quad
	var material = SpatialMaterial.new()
	material.albedo_color = Color.white
	material.flags_transparent = true
	quad.material_override = material
	
	# Add the quad to the frame
	frame_node.add_child(quad)
	
	# Add text label for frame info
	var label = Label3D.new()
	label.text = "Frame"
	label.font_size = 14
	label.translate(Vector3(0, -0.6, 0))
	frame_node.add_child(label)
	
	return frame_node

# Create text overlay for console
func _create_text_overlay():
	# Create viewport for text
	var viewport = Viewport.new()
	viewport.size = Vector2(800, 600)
	viewport.transparent_bg = true
	viewport.render_target_v_flip = true
	add_child(viewport)
	
	# Create control for text
	var control = Control.new()
	control.rect_size = viewport.size
	viewport.add_child(control)
	
	# Create RichTextLabel for console
	var console = RichTextLabel.new()
	console.rect_size = Vector2(780, 300)
	console.rect_position = Vector2(10, 290)
	console.bbcode_enabled = true
	console.scroll_following = true
	console.scroll_active = true
	console.name = "Console"
	control.add_child(console)
	
	# Store reference
	console_node = console
	
	# Create spatial quad to display the viewport
	var quad = MeshInstance.new()
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(4, 3)
	quad.mesh = quad_mesh
	
	# Create material that uses the viewport as texture
	var material = SpatialMaterial.new()
	material.flags_transparent = true
	material.flags_unshaded = true
	material.albedo_color = console_color
	
	# Create viewport texture
	var viewport_texture = ViewportTexture.new()
	viewport_texture.viewport_path = viewport.get_path()
	material.albedo_texture = viewport_texture
	
	quad.material_override = material
	quad.translation = Vector3(0, 0, -3)
	quad.visible = console_active
	add_child(quad)
	
	# Store reference to the quad
	text_overlay = quad

# Initialize console
func _initialize_console():
	# Clear console
	console_node.bbcode_text = ""
	console_lines.clear()
	
	# Add initial content
	console_log("=== CENTERED VISUALIZER 3D ===")
	console_log("Press 'C' to toggle console")
	console_log("Press 'D' to toggle debug markers")
	console_log("Press 'F' to capture frame manually")
	console_log("Press '1-4' to switch data sources")
	console_log("============================")

# Capture a frame from the active data source
func capture_frame():
	# Get frame data from active source
	var frame_data = _get_data_from_source(active_source)
	
	# Store frame data
	current_frame = (current_frame + 1) % max_frames
	frames[current_frame] = {
		"number": current_frame,
		"data": frame_data,
		"source": active_source,
		"timestamp": OS.get_unix_time()
	}
	
	# Update visual frame
	_update_frame_visual(current_frame)
	
	# Show the frame
	frame_displays[current_frame].visible = true
	
	# Emit signal
	emit_signal("frame_captured", current_frame, frame_data)
	
	return current_frame

# Update the visual representation of a frame
func _update_frame_visual(frame_index):
	var frame_data = frames[frame_index]
	var frame_node = frame_displays[frame_index]
	
	if frame_data.data == null:
		frame_node.visible = false
		return
	
	# Get the quad mesh and update material
	var quad = frame_node.get_child(0)
	var material = quad.material_override
	
	# Display frame data (would normally use a texture)
	var text_node = frame_node.get_child(1)
	text_node.text = "Frame " + str(frame_index) + "\n" + active_source

# Update positions of all frame displays
func _update_frame_positions(delta):
	var center_pos = Vector3.ZERO
	var radius = frame_spacing * 2
	
	for i in range(frame_displays.size()):
		var frame = frame_displays[i]
		
		if frames[i].data != null:
			# Calculate position in a circle around center point
			var angle = 2 * PI * i / max_frames
			var target_pos = center_pos + Vector3(cos(angle) * radius, sin(angle) * radius, 0)
			
			# Smoothly move to target position
			frame.translation = frame.translation.linear_interpolate(target_pos, delta * 2)
			
			# Make frame face center
			frame.look_at(center_pos, Vector3.UP)
			
			# If this is the current frame, show it more prominently
			if i == current_frame:
				frame.scale = Vector3.ONE.linear_interpolate(Vector3(1.2, 1.2, 1.2), delta * 3)
			else:
				frame.scale = frame.scale.linear_interpolate(Vector3.ONE, delta * 3)
				
			# Ensure visibility
			frame.visible = true
		else:
			# Hide frames with no data
			frame.visible = false

# Update console fade effect
func _update_console_fade(delta):
	if console_lines.size() > 0:
		# Update fade time for each line
		for i in range(console_lines.size() - 1, -1, -1):
			console_lines[i].time += delta
			
			# Remove old lines
			if console_lines[i].time > console_fade_time:
				console_lines.remove(i)
		
		# Update console text
		_update_console_text()

# Update the console text display
func _update_console_text():
	var text = ""
	
	for line in console_lines:
		var alpha = 1.0 - min(line.time / console_fade_time, 1.0)
		var alpha_hex = "%02X" % int(alpha * 255)
		
		text += "[color=#" + line.color + alpha_hex + "]" + line.text + "[/color]\n"
	
	console_node.bbcode_text = text

# Add a message to the console
func console_log(message, color_code = "FFFF00"):
	console_lines.append({
		"text": message,
		"color": color_code,
		"time": 0.0
	})
	
	# Trim excess lines
	while console_lines.size() > max_console_lines:
		console_lines.remove(0)
	
	# Update console display
	_update_console_text()
	
	# Emit signal
	emit_signal("console_updated", message)

# Toggle console visibility
func toggle_console():
	console_active = !console_active
	text_overlay.visible = console_active
	console_log("Console " + ("activated" if console_active else "deactivated"))

# Toggle debug markers visibility
func toggle_debug_markers():
	debug_markers_visible = !debug_markers_visible
	
	# Update visibility
	center_marker.visible = debug_markers_visible
	for marker in corner_markers:
		marker.visible = debug_markers_visible
	
	# Find and update corner lines
	var lines = get_node("CornerLines")
	if lines:
		lines.visible = debug_markers_visible and debug_lines_visible
	
	console_log("Debug markers " + ("visible" if debug_markers_visible else "hidden"))

# Toggle debug lines visibility
func toggle_debug_lines():
	debug_lines_visible = !debug_lines_visible
	
	# Find and update corner lines
	var lines = get_node("CornerLines")
	if lines:
		lines.visible = debug_markers_visible and debug_lines_visible
	
	console_log("Debug lines " + ("visible" if debug_lines_visible else "hidden"))

# Register a new data source
func register_data_source(source_name, source_description, source_handler = null):
	data_sources[source_name] = {
		"name": source_name,
		"description": source_description,
		"handler": source_handler
	}
	
	console_log("Registered data source: " + source_name)
	return true

# Set the active data source
func set_active_source(source_name):
	if data_sources.has(source_name):
		active_source = source_name
		console_log("Active source: " + source_name + " - " + data_sources[source_name].description)
		emit_signal("source_changed", source_name)
		return true
	else:
		console_log("Unknown source: " + source_name, "FF0000")
		return false

# Get data from a specific source
func _get_data_from_source(source_name):
	if not data_sources.has(source_name):
		return null
	
	var source = data_sources[source_name]
	
	# If the source has a handler, use it
	if source.handler != null:
		return source.handler.call_func()
	
	# Otherwise, generate sample data based on source type
	match source_name:
		"godot":
			return {
				"type": "engine",
				"fps": Engine.get_frames_per_second(),
				"time": OS.get_ticks_msec() / 1000.0,
				"memory": OS.get_static_memory_usage()
			}
		"file":
			return {
				"type": "file",
				"files_scanned": randi() % 100,
				"lines_read": randi() % 1000,
				"tokens_parsed": randi() % 5000
			}
		"memory":
			return {
				"type": "memory",
				"blocks": randi() % 200,
				"usage": randi() % 1024,
				"allocations": randi() % 500
			}
		"akashic":
			return {
				"type": "akashic",
				"records": randi() % 12,
				"dimension": randi() % 9 + 1,
				"connections": randi() % 50
			}
	
	return null

# Input handling
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_C:
				toggle_console()
			KEY_D:
				toggle_debug_markers()
			KEY_L:
				toggle_debug_lines()
			KEY_F:
				capture_frame()
			KEY_1:
				set_active_source("godot")
			KEY_2:
				set_active_source("file")
			KEY_3:
				set_active_source("memory")
			KEY_4:
				set_active_source("akashic")

# Connect to a token analyzer to get data
func connect_token_analyzer(analyzer):
	if analyzer == null:
		console_log("Invalid token analyzer", "FF0000")
		return false
	
	# Register a new data source that uses the analyzer
	register_data_source("tokens", "Token Analysis", funcref(self, "_get_token_data_from_analyzer"))
	
	# Store the analyzer reference
	data_parser = analyzer
	
	console_log("Connected to token analyzer")
	return true

# Get token data from the analyzer
func _get_token_data_from_analyzer():
	if data_parser == null:
		return null
	
	# Generate some sample data from the analyzer
	return {
		"type": "tokens",
		"count": randi() % 1000,
		"patterns": randi() % 20,
		"matches": randi() % 100
	}

# Connect to a project connector for multi-project visualization
func connect_project_connector(connector):
	if connector == null:
		console_log("Invalid project connector", "FF0000")
		return false
	
	# Register a new data source that uses the connector
	register_data_source("projects", "Project Connections", funcref(self, "_get_project_data_from_connector"))
	
	# Store the connector reference (reusing data_parser variable)
	data_parser = connector
	
	console_log("Connected to project connector")
	return true

# Get project connection data 
func _get_project_data_from_connector():
	if data_parser == null:
		return null
	
	# Get data from the connector
	var topology = data_parser.get_connection_topology()
	
	return {
		"type": "projects",
		"components": topology.components.size(),
		"connections": topology.connections.size(),
		"projects": topology.projects.size()
	}