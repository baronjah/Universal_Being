extends Node

class_name JSHTerminalVisualizer

# JSH Terminal Visualizer - Advanced terminal graphics for LUMINUS CORE
# Combines 3D visualization with ASCII art in a terminal interface
# Supports dimensional shifts through the 12-turn system

# Constants
const ASPECT_RATIO = 0.5 # Terminal characters are taller than wide
const DEFAULT_WIDTH = 80
const DEFAULT_HEIGHT = 40
const BRAILLE_CHARS = [
	"⠀", "⠁", "⠂", "⠃", "⠄", "⠅", "⠆", "⠇", 
	"⠈", "⠉", "⠊", "⠋", "⠌", "⠍", "⠎", "⠏", 
	"⠐", "⠑", "⠒", "⠓", "⠔", "⠕", "⠖", "⠗", 
	"⠘", "⠙", "⠚", "⠛", "⠜", "⠝", "⠞", "⠟", 
	"⠠", "⠡", "⠢", "⠣", "⠤", "⠥", "⠦", "⠧", 
	"⠨", "⠩", "⠪", "⠫", "⠬", "⠭", "⠮", "⠯", 
	"⠰", "⠱", "⠲", "⠳", "⠴", "⠵", "⠶", "⠷", 
	"⠸", "⠹", "⠺", "⠻", "⠼", "⠽", "⠾", "⠿"
]
const BLOCK_CHARS = [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉", "█"]
const SHADING_CHARS = [" ", ".", ":", "-", "=", "+", "*", "#", "@"]
const ANSI_PREFIX = "\u001b["
const ANSI_RESET = "\u001b[0m"

# Configuration
var use_ansi_colors = true
var use_braille = true
var use_block_chars = true
var current_dimension = 3
var camera_position = Vector3(0, 0, -5)
var camera_target = Vector3(0, 0, 0)
var camera_up = Vector3(0, 1, 0)
var field_of_view = 60.0
var clear_color = Color(0, 0, 0)
var width = DEFAULT_WIDTH
var height = DEFAULT_HEIGHT

# Internal state
var _buffer = []
var _depth_buffer = []
var _light_position = Vector3(10, 10, 10)
var _projection_matrix = Transform3D()
var _view_matrix = Transform3D()
var _models = []
var _dimension_filters = {}
var _last_frame_time = 0
var _frame_count = 0
var _fps = 0

# Signals
signal frame_rendered(frame_data)

# Initialize the visualizer
func _ready():
	_init_buffers()
	_init_matrices()
	_init_dimension_filters()
	print("JSH Terminal Visualizer initialized - width: %d, height: %d" % [width, height])

# Initialize screen buffers
func _init_buffers():
	_buffer = []
	_depth_buffer = []
	
	for y in range(height):
		var row = []
		var depth_row = []
		for x in range(width):
			row.append({
				"char": " ",
				"color": clear_color,
				"intensity": 0.0
			})
			depth_row.append(9999.0) # Far depth
		_buffer.append(row)
		_depth_buffer.append(depth_row)

# Initialize projection and view matrices
func _init_matrices():
	# Set up perspective projection
	var near = 0.1
	var far = 100.0
	var aspect = float(width) / float(height) * ASPECT_RATIO
	_projection_matrix = Transform3D()
	
	# Create perspective matrix
	var f = 1.0 / tan(deg_to_rad(field_of_view) / 2.0)
	_projection_matrix[0][0] = f / aspect
	_projection_matrix[1][1] = f
	_projection_matrix[2][2] = (far + near) / (near - far)
	_projection_matrix[2][3] = (2.0 * far * near) / (near - far)
	_projection_matrix[3][2] = -1.0
	_projection_matrix[3][3] = 0.0
	
	# Initialize view matrix
	_update_view_matrix()

# Initialize dimension filters for each turn
func _init_dimension_filters():
	# 1D: Point - Shows everything as points
	_dimension_filters[1] = {
		"process_vertex": func(v): return v,
		"process_fragment": func(color, depth): 
			return {
				"char": ".",
				"color": Color(1, 1, 1),
				"intensity": 1.0
			}
	}
	
	# 2D: Line - Shows everything as wireframes
	_dimension_filters[2] = {
		"process_vertex": func(v): return v,
		"process_fragment": func(color, depth): 
			return {
				"char": "-",
				"color": color,
				"intensity": 1.0 - clamp(depth / 20.0, 0, 1)
			}
	}
	
	# 3D: Space - Standard 3D shading
	_dimension_filters[3] = {
		"process_vertex": func(v): return v,
		"process_fragment": func(color, depth):
			var intensity = 1.0 - clamp(depth / 20.0, 0, 1)
			var char_index = int(intensity * (SHADING_CHARS.size() - 1))
			return {
				"char": SHADING_CHARS[char_index],
				"color": color,
				"intensity": intensity
			}
	}
	
	# 4D: Time - Shows motion blur effect
	_dimension_filters[4] = {
		"process_vertex": func(v):
			var time_offset = sin(Time.get_unix_time_from_system() * 2.0) * 0.1
			return Vector3(v.x + time_offset, v.y, v.z),
		"process_fragment": func(color, depth):
			var intensity = 1.0 - clamp(depth / 20.0, 0, 1)
			var char_index = int(intensity * (BLOCK_CHARS.size() - 1))
			return {
				"char": BLOCK_CHARS[char_index],
				"color": color,
				"intensity": intensity
			}
	}
	
	# 5D: Consciousness - Shows pulse effect
	_dimension_filters[5] = {
		"process_vertex": func(v):
			var pulse = sin(Time.get_unix_time_from_system() * 3.0) * 0.2 + 0.8
			return Vector3(v.x * pulse, v.y * pulse, v.z),
		"process_fragment": func(color, depth):
			var pulse = sin(Time.get_unix_time_from_system() * 3.0) * 0.5 + 0.5
			var intensity = 1.0 - clamp(depth / 20.0, 0, 1)
			intensity *= pulse
			var braille_index = int(intensity * 63)
			braille_index = clamp(braille_index, 0, 63)
			return {
				"char": BRAILLE_CHARS[braille_index],
				"color": Color(color.r * pulse, color.g * pulse, color.b * pulse),
				"intensity": intensity
			}
	}
	
	# 6D: Connection - Shows lines between vertices
	_dimension_filters[6] = {
		"process_vertex": func(v): 
			var angle = Time.get_unix_time_from_system() * 0.5
			var rotation = Transform3D().rotated(Vector3(0, 1, 0), angle)
			return rotation * v,
		"process_fragment": func(color, depth):
			var intensity = 1.0 - clamp(depth / 20.0, 0, 1)
			var connection_factor = sin(Time.get_unix_time_from_system() * 2.0) * 0.5 + 0.5
			return {
				"char": connection_factor > 0.5 ? "+" : "×",
				"color": color.lerp(Color(0.2, 0.8, 1.0), connection_factor),
				"intensity": intensity
			}
	}
	
	# 7D: Creation - Shows particles forming
	_dimension_filters[7] = {
		"process_vertex": func(v):
			var creation_factor = sin(Time.get_unix_time_from_system() + v.length()) * 0.5 + 0.5
			return v * creation_factor,
		"process_fragment": func(color, depth):
			var intensity = 1.0 - clamp(depth / 20.0, 0, 1)
			var creation_factor = sin(Time.get_unix_time_from_system() * 3.0) * 0.5 + 0.5
			var char_options = ["✧", "✦", "✶", "✹", "✺", "✷", "✵", "✴", "✻"]
			var char_index = int(creation_factor * (char_options.size() - 1))
			return {
				"char": char_options[char_index],
				"color": color.lerp(Color(1, 1, 0), creation_factor),
				"intensity": intensity
			}
	}
	
	# 8D: Network - Shows connection network
	_dimension_filters[8] = {
		"process_vertex": func(v):
			var network_pulse = sin(Time.get_unix_time_from_system() * 2.0 + v.x + v.y + v.z) * 0.1
			return Vector3(v.x, v.y + network_pulse, v.z),
		"process_fragment": func(color, depth):
			var intensity = 1.0 - clamp(depth / 20.0, 0, 1)
			var network_options = ["┌", "┐", "└", "┘", "├", "┤", "┬", "┴", "┼", "─", "│"]
			var network_index = int(fmod(depth * 17.31 + Time.get_unix_time_from_system() * 3.0, network_options.size()))
			return {
				"char": network_options[network_index],
				"color": Color(0.2, 0.8, 1.0).lerp(color, intensity),
				"intensity": intensity
			}
	}
	
	# 9D: Harmony - Shows balanced patterns
	_dimension_filters[9] = {
		"process_vertex": func(v):
			var harmony = cos(v.x * 2.0) * sin(v.y * 2.0) * 0.1
			return Vector3(v.x, v.y, v.z + harmony),
		"process_fragment": func(color, depth):
			var intensity = 1.0 - clamp(depth / 20.0, 0, 1)
			var harmony_factor = (cos(depth * 0.5) + 1.0) * 0.5
			var harmony_chars = ["○", "◎", "◉", "●"]
			var harmony_index = int(harmony_factor * (harmony_chars.size() - 1))
			return {
				"char": harmony_chars[harmony_index],
				"color": color,
				"intensity": intensity
			}
	}
	
	# 10D: Unity - Everything connects to center
	_dimension_filters[10] = {
		"process_vertex": func(v):
			var unity_factor = sin(Time.get_unix_time_from_system() * 0.5) * 0.5 + 0.5
			return v.lerp(Vector3.ZERO, unity_factor * 0.2),
		"process_fragment": func(color, depth):
			var intensity = 1.0 - clamp(depth / 20.0, 0, 1)
			var unity_factor = sin(Time.get_unix_time_from_system() * 0.5) * 0.5 + 0.5
			var unity_color = Color(1, 1, 1)
			return {
				"char": "∞",
				"color": color.lerp(unity_color, unity_factor),
				"intensity": intensity
			}
	}
	
	# 11D: Transcendence - Reality begins to dissolve
	_dimension_filters[11] = {
		"process_vertex": func(v):
			var transcendence = sin(Time.get_unix_time_from_system() + v.length() * 2.0) * 0.3
			return Vector3(v.x + transcendence, v.y + transcendence, v.z),
		"process_fragment": func(color, depth):
			var intensity = 1.0 - clamp(depth / 20.0, 0, 1)
			var transcendence_factor = sin(Time.get_unix_time_from_system() * 2.0 + depth) * 0.5 + 0.5
			var transcendence_chars = ["⊹", "⊶", "⊷", "⊸", "⊿", "⋀", "⋁", "⋆"]
			var transcendence_index = int(transcendence_factor * (transcendence_chars.size() - 1))
			return {
				"char": transcendence_chars[transcendence_index],
				"color": Color(1, 1, 1).lerp(color, transcendence_factor),
				"intensity": intensity
			}
	}
	
	# 12D: Beyond - Complete transformation
	_dimension_filters[12] = {
		"process_vertex": func(v):
			var beyond_factor = sin(Time.get_unix_time_from_system() * 0.25 + v.x + v.y + v.z)
			return Vector3(
				v.x * cos(beyond_factor * PI),
				v.y * sin(beyond_factor * PI),
				v.z
			),
		"process_fragment": func(color, depth):
			var intensity = 1.0 - clamp(depth / 20.0, 0, 1)
			var beyond_factor = sin(Time.get_unix_time_from_system() * 0.5 + depth * 0.1) * 0.5 + 0.5
			var inverted_color = Color(1 - color.r, 1 - color.g, 1 - color.b)
			var beyond_chars = ["Ω", "∞", "※", "⊛", "⊕", "⊗", "⊙", "⊚", "∇", "∆"]
			var beyond_index = int(beyond_factor * (beyond_chars.size() - 1))
			return {
				"char": beyond_chars[beyond_index],
				"color": color.lerp(inverted_color, beyond_factor),
				"intensity": intensity
			}
	}

# Update the camera's view matrix
func _update_view_matrix():
	# Simplified look-at matrix calculation
	var z_axis = (camera_position - camera_target).normalized()
	var x_axis = camera_up.cross(z_axis).normalized()
	var y_axis = z_axis.cross(x_axis)
	
	_view_matrix = Transform3D(
		Vector3(x_axis.x, y_axis.x, z_axis.x),
		Vector3(x_axis.y, y_axis.y, z_axis.y),
		Vector3(x_axis.z, y_axis.z, z_axis.z),
		camera_position
	)
	
	# Invert the matrix (simplified approach)
	_view_matrix = _view_matrix.affine_inverse()

# Clear the screen buffer
func clear_screen():
	for y in range(height):
		for x in range(width):
			_buffer[y][x] = {
				"char": " ",
				"color": clear_color,
				"intensity": 0.0
			}
			_depth_buffer[y][x] = 9999.0

# Process a frame and return terminal-friendly output
func render_frame():
	var start_time = Time.get_ticks_msec()
	
	# Clear the screen
	clear_screen()
	
	# Update matrices
	_update_view_matrix()
	
	# Process all models
	for model in _models:
		_render_model(model)
	
	# Generate frame output
	var frame_output = ""
	var frame_data = []
	
	for y in range(height):
		var row = ""
		var row_data = []
		
		for x in range(width):
			var pixel = _buffer[y][x]
			var color_code = ""
			
			if use_ansi_colors:
				var r = int(pixel.color.r * 255)
				var g = int(pixel.color.g * 255)
				var b = int(pixel.color.b * 255)
				color_code = "%s38;2;%d;%d;%dm" % [ANSI_PREFIX, r, g, b]
			
			row += color_code + pixel.char
			row_data.append({
				"char": pixel.char, 
				"color": pixel.color, 
				"intensity": pixel.intensity
			})
		
		if use_ansi_colors:
			row += ANSI_RESET
		
		frame_output += row + "\n"
		frame_data.append(row_data)
	
	# Calculate FPS
	var end_time = Time.get_ticks_msec()
	var frame_time = end_time - start_time
	_last_frame_time = frame_time
	_frame_count += 1
	
	if _frame_count >= 10:
		_fps = 1000.0 / max(frame_time, 1)
		_frame_count = 0
	
	# Add FPS counter
	if use_ansi_colors:
		frame_output += "%s37mFPS: %.1f%s\n" % [ANSI_PREFIX, _fps, ANSI_RESET]
	else:
		frame_output += "FPS: %.1f\n" % _fps
	
	# Emit signal with frame data
	emit_signal("frame_rendered", {
		"text": frame_output,
		"data": frame_data,
		"fps": _fps,
		"dimension": current_dimension
	})
	
	return frame_output

# Render a 3D model to the buffer
func _render_model(model):
	# Get dimension filter
	var dim_filter = _dimension_filters.get(current_dimension, _dimension_filters[3])
	
	# Process vertices
	var positions = []
	var normals = []
	var colors = []
	
	for v in model.vertices:
		var vertex = Vector3(v.x, v.y, v.z)
		
		# Apply dimension vertex filter
		vertex = dim_filter.process_vertex.call(vertex)
		
		# Model transform
		vertex = model.transform * vertex
		
		# View transform
		var view_vertex = _view_matrix * vertex
		
		# Store transformed vertex
		positions.append(view_vertex)
		
		# Transform normal (simplified)
		var normal = model.transform.basis * v.normal
		normals.append(normal)
		
		# Store color
		colors.append(v.color)
	
	# Process triangles
	for triangle in model.triangles:
		_rasterize_triangle(
			positions[triangle.a], positions[triangle.b], positions[triangle.c],
			normals[triangle.a], normals[triangle.b], normals[triangle.c],
			colors[triangle.a], colors[triangle.b], colors[triangle.c]
		)

# Rasterize a triangle
func _rasterize_triangle(v0, v1, v2, n0, n1, n2, c0, c1, c2):
	# Simplified backface culling
	var face_normal = (v1 - v0).cross(v2 - v0).normalized()
	var view_dir = -Vector3(0, 0, 1)
	if face_normal.dot(view_dir) <= 0:
		return
	
	# Project vertices to clip space
	var clip0 = _projection_matrix * Vector4(v0.x, v0.y, v0.z, 1.0)
	var clip1 = _projection_matrix * Vector4(v1.x, v1.y, v1.z, 1.0)
	var clip2 = _projection_matrix * Vector4(v2.x, v2.y, v2.z, 1.0)
	
	# Perspective division
	var ndc0 = Vector3(clip0.x / clip0.w, clip0.y / clip0.w, clip0.z / clip0.w)
	var ndc1 = Vector3(clip1.x / clip1.w, clip1.y / clip1.w, clip1.z / clip1.w)
	var ndc2 = Vector3(clip2.x / clip2.w, clip2.y / clip2.w, clip2.z / clip2.w)
	
	# Transform to screen space
	var screen0 = Vector2(
		(ndc0.x + 1.0) * 0.5 * width,
		(1.0 - ndc0.y) * 0.5 * height
	)
	var screen1 = Vector2(
		(ndc1.x + 1.0) * 0.5 * width,
		(1.0 - ndc1.y) * 0.5 * height
	)
	var screen2 = Vector2(
		(ndc2.x + 1.0) * 0.5 * width,
		(1.0 - ndc2.y) * 0.5 * height
	)
	
	# Get bounding box
	var min_x = max(0, floor(min(min(screen0.x, screen1.x), screen2.x)))
	var min_y = max(0, floor(min(min(screen0.y, screen1.y), screen2.y)))
	var max_x = min(width - 1, ceil(max(max(screen0.x, screen1.x), screen2.x)))
	var max_y = min(height - 1, ceil(max(max(screen0.y, screen1.y), screen2.y)))
	
	# Rasterize
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var point = Vector2(x + 0.5, y + 0.5)
			
			# Barycentric coordinates
			var area = _edge_function(screen0, screen1, screen2)
			var w0 = _edge_function(screen1, screen2, point) / area
			var w1 = _edge_function(screen2, screen0, point) / area
			var w2 = _edge_function(screen0, screen1, point) / area
			
			# Check if point is inside triangle
			if w0 >= 0 and w1 >= 0 and w2 >= 0:
				# Interpolate Z (depth)
				var z = w0 * v0.z + w1 * v1.z + w2 * v2.z
				
				# Depth test
				if z < _depth_buffer[y][x]:
					_depth_buffer[y][x] = z
					
					# Interpolate color
					var color = Color(
						w0 * c0.r + w1 * c1.r + w2 * c2.r,
						w0 * c0.g + w1 * c1.g + w2 * c2.g,
						w0 * c0.b + w1 * c1.b + w2 * c2.b
					)
					
					# Simplified lighting
					var normal = Vector3(
						w0 * n0.x + w1 * n1.x + w2 * n2.x,
						w0 * n0.y + w1 * n1.y + w2 * n2.y,
						w0 * n0.z + w1 * n1.z + w2 * n2.z
					).normalized()
					
					var light_dir = (_light_position - Vector3(0, 0, 0)).normalized()
					var diffuse = max(normal.dot(light_dir), 0.2)
					color = Color(
						color.r * diffuse,
						color.g * diffuse,
						color.b * diffuse
					)
					
					# Process fragment with dimension filter
					var fragment = _dimension_filters[current_dimension].process_fragment.call(color, z)
					_buffer[y][x] = fragment

# Calculate edge function for barycentric coordinates
func _edge_function(a, b, c):
	return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)

# Set the current dimension (1-12)
func set_dimension(dimension):
	current_dimension = clamp(dimension, 1, 12)
	print("Set dimension to %d" % current_dimension)

# Add a 3D model to the scene
func add_model(model_data):
	_models.append(model_data)
	print("Added model with %d vertices and %d triangles" % 
		[model_data.vertices.size(), model_data.triangles.size()])

# Remove a model from the scene
func remove_model(model_index):
	if model_index >= 0 and model_index < _models.size():
		_models.remove_at(model_index)
		return true
	return false

# Create a cube model
func create_cube(size=1.0, color=Color(1, 1, 1)):
	var half = size / 2.0
	
	var vertices = []
	var triangles = []
	
	# Define 8 vertices
	vertices.append({"x": -half, "y": -half, "z": -half, "normal": Vector3(-1, -1, -1).normalized(), "color": color})
	vertices.append({"x": half, "y": -half, "z": -half, "normal": Vector3(1, -1, -1).normalized(), "color": color})
	vertices.append({"x": half, "y": half, "z": -half, "normal": Vector3(1, 1, -1).normalized(), "color": color})
	vertices.append({"x": -half, "y": half, "z": -half, "normal": Vector3(-1, 1, -1).normalized(), "color": color})
	vertices.append({"x": -half, "y": -half, "z": half, "normal": Vector3(-1, -1, 1).normalized(), "color": color})
	vertices.append({"x": half, "y": -half, "z": half, "normal": Vector3(1, -1, 1).normalized(), "color": color})
	vertices.append({"x": half, "y": half, "z": half, "normal": Vector3(1, 1, 1).normalized(), "color": color})
	vertices.append({"x": -half, "y": half, "z": half, "normal": Vector3(-1, 1, 1).normalized(), "color": color})
	
	# Define 12 triangles (2 per face)
	# Front face
	triangles.append({"a": 0, "b": 1, "c": 2})
	triangles.append({"a": 0, "b": 2, "c": 3})
	
	# Back face
	triangles.append({"a": 4, "b": 6, "c": 5})
	triangles.append({"a": 4, "b": 7, "c": 6})
	
	# Left face
	triangles.append({"a": 0, "b": 3, "c": 7})
	triangles.append({"a": 0, "b": 7, "c": 4})
	
	# Right face
	triangles.append({"a": 1, "b": 5, "c": 6})
	triangles.append({"a": 1, "b": 6, "c": 2})
	
	# Top face
	triangles.append({"a": 3, "b": 2, "c": 6})
	triangles.append({"a": 3, "b": 6, "c": 7})
	
	# Bottom face
	triangles.append({"a": 0, "b": 4, "c": 5})
	triangles.append({"a": 0, "b": 5, "c": 1})
	
	# Create model
	var model = {
		"vertices": vertices,
		"triangles": triangles,
		"transform": Transform3D()
	}
	
	add_model(model)
	return _models.size() - 1

# Create a sphere model
func create_sphere(radius=1.0, segments=8, color=Color(1, 1, 1)):
	var vertices = []
	var triangles = []
	
	# Generate vertices
	for i in range(segments + 1):
		var v = float(i) / segments
		var phi = v * PI
		
		for j in range(segments):
			var u = float(j) / segments
			var theta = u * PI * 2
			
			var x = sin(phi) * cos(theta)
			var y = cos(phi)
			var z = sin(phi) * sin(theta)
			
			var vertex = {
				"x": x * radius,
				"y": y * radius,
				"z": z * radius,
				"normal": Vector3(x, y, z),
				"color": color
			}
			
			vertices.append(vertex)
	
	# Generate triangles
	for i in range(segments):
		for j in range(segments):
			var i0 = i * (segments + 1) + j
			var i1 = i0 + 1
			var i2 = i0 + (segments + 1)
			var i3 = i2 + 1
			
			if i != 0:
				triangles.append({"a": i0, "b": i2, "c": i1})
			
			if i != segments - 1:
				triangles.append({"a": i1, "b": i2, "c": i3})
	
	# Create model
	var model = {
		"vertices": vertices,
		"triangles": triangles,
		"transform": Transform3D()
	}
	
	add_model(model)
	return _models.size() - 1

# Create a text model that renders 3D text
func create_text_model(text, size=1.0, color=Color(1, 1, 1)):
	var vertices = []
	var triangles = []
	var offset = 0
	
	for i in range(text.length()):
		var char_code = text.unicode_at(i)
		var x_offset = i * size * 0.8
		
		# Simplified character geometry (just a square per character)
		var char_verts = [
			{"x": x_offset, "y": 0, "z": 0, "normal": Vector3(0, 0, 1), "color": color},
			{"x": x_offset + size * 0.7, "y": 0, "z": 0, "normal": Vector3(0, 0, 1), "color": color},
			{"x": x_offset + size * 0.7, "y": size, "z": 0, "normal": Vector3(0, 0, 1), "color": color},
			{"x": x_offset, "y": size, "z": 0, "normal": Vector3(0, 0, 1), "color": color}
		]
		
		for v in char_verts:
			vertices.append(v)
		
		triangles.append({"a": offset, "b": offset + 1, "c": offset + 2})
		triangles.append({"a": offset, "b": offset + 2, "c": offset + 3})
		
		offset += 4
	
	# Create model
	var model = {
		"vertices": vertices,
		"triangles": triangles,
		"transform": Transform3D(),
		"character_data": {
			"text": text,
			"char_codes": text.to_utf8_buffer()
		}
	}
	
	add_model(model)
	return _models.size() - 1

# Create ASCII model from ASCII art
func create_ascii_model(ascii_art, size=0.2, color=Color(1, 1, 1)):
	var lines = ascii_art.split("\n")
	var max_width = 0
	for line in lines:
		max_width = max(max_width, line.length())
	
	var vertices = []
	var triangles = []
	var offset = 0
	
	for y in range(lines.size()):
		var line = lines[y]
		
		for x in range(line.length()):
			var char = line[x]
			if char == " ":
				continue
			
			# Position based on character position
			var px = x * size - (max_width * size / 2)
			var py = -y * size + (lines.size() * size / 2)
			
			# Create square for character
			var char_verts = [
				{"x": px, "y": py - size, "z": 0, "normal": Vector3(0, 0, 1), "color": color},
				{"x": px + size, "y": py - size, "z": 0, "normal": Vector3(0, 0, 1), "color": color},
				{"x": px + size, "y": py, "z": 0, "normal": Vector3(0, 0, 1), "color": color},
				{"x": px, "y": py, "z": 0, "normal": Vector3(0, 0, 1), "color": color}
			]
			
			for v in char_verts:
				vertices.append(v)
			
			triangles.append({"a": offset, "b": offset + 1, "c": offset + 2})
			triangles.append({"a": offset, "b": offset + 2, "c": offset + 3})
			
			offset += 4
	
	# Create model
	var model = {
		"vertices": vertices,
		"triangles": triangles,
		"transform": Transform3D(),
		"ascii_data": {
			"art": ascii_art,
			"width": max_width,
			"height": lines.size()
		}
	}
	
	add_model(model)
	return _models.size() - 1

# Rotate a model around an axis
func rotate_model(model_index, axis, angle):
	if model_index >= 0 and model_index < _models.size():
		var transform = Transform3D().rotated(axis, angle)
		_models[model_index].transform = transform * _models[model_index].transform
		return true
	return false

# Move a model
func translate_model(model_index, translation):
	if model_index >= 0 and model_index < _models.size():
		var transform = Transform3D().translated(translation)
		_models[model_index].transform = transform * _models[model_index].transform
		return true
	return false

# Scale a model
func scale_model(model_index, scale):
	if model_index >= 0 and model_index < _models.size():
		var transform = Transform3D().scaled(scale)
		_models[model_index].transform = transform * _models[model_index].transform
		return true
	return false

# Create a scene with a cube and rotating text
func create_demo_scene():
	# Create a cube
	var cube_index = create_cube(2.0, Color(0.2, 0.6, 1.0))
	
	# Create text
	var text_index = create_text_model("JSH TERMINAL", 0.5, Color(1, 0.8, 0.2))
	translate_model(text_index, Vector3(0, 2, 0))
	
	# Create ASCII art
	var ascii_art = """
   __   ___  _  _ 
   \ \\ / / || || |
    \\ V /| || || |
     \\_/ |_||_||_|
   """
	var ascii_index = create_ascii_model(ascii_art, 0.3, Color(0.5, 1.0, 0.5))
	translate_model(ascii_index, Vector3(0, -2, 0))
	
	# Create animation
	var timer = Timer.new()
	timer.wait_time = 1.0 / 30.0  # 30 FPS
	timer.autostart = true
	timer.timeout.connect(func():
		rotate_model(cube_index, Vector3(0, 1, 0), 0.02)
		rotate_model(text_index, Vector3(0, 1, 0), 0.01)
		render_frame()
	)
	add_child(timer)
	
	print("Demo scene created")

# Output a visualization test to terminal
func render_visualization_test():
	# Set up dimensions for visualization
	var visualization = ""
	var dimensions = min(current_dimension, 12)
	
	visualization += "JSH Terminal Visualizer - Dimension Test\n"
	visualization += "========================================\n\n"
	
	for d in range(1, dimensions + 1):
		var gradient = ""
		var dimension_name = ""
		
		match d:
			1: dimension_name = "1D: Point"
			2: dimension_name = "2D: Line"
			3: dimension_name = "3D: Space"
			4: dimension_name = "4D: Time"
			5: dimension_name = "5D: Consciousness"
			6: dimension_name = "6D: Connection"
			7: dimension_name = "7D: Creation"
			8: dimension_name = "8D: Network"
			9: dimension_name = "9D: Harmony"
			10: dimension_name = "10D: Unity"
			11: dimension_name = "11D: Transcendence"
			12: dimension_name = "12D: Beyond"
		
		visualization += dimension_name + ":\n"
		
		if use_ansi_colors:
			for i in range(40):
				var t = float(i) / 40
				var color = get_spectrum_color(t)
				var r = int(color.r * 255)
				var g = int(color.g * 255)
				var b = int(color.b * 255)
				gradient += "%s38;2;%d;%d;%dm█%s" % [ANSI_PREFIX, r, g, b, ANSI_RESET]
		else:
			gradient = "|" + "=".repeat(40) + "|"
		
		visualization += gradient + "\n\n"
	
	visualization += "\nCurrent dimension: " + str(current_dimension) + "\n"
	
	return visualization

# Get a color gradient for the current dimension
func get_dimension_gradient(length=40):
	var gradient = []
	var dimension_filter = _dimension_filters.get(current_dimension, _dimension_filters[3])
	
	for i in range(length):
		var t = float(i) / length
		var depth = 5.0 + t * 15.0  # Depth from 5 to 20
		var color = get_spectrum_color(t)
		var fragment = dimension_filter.process_fragment.call(color, depth)
		gradient.append(fragment)
	
	return gradient

# Create a WoW-inspired interface
func create_wow_interface():
	# Clear models
	_models.clear()
	
	# Create WoW logo ASCII art
	var wow_logo = """
  _       __          ____      __
 | |     / /___  ____/ / /___  / /_
 | | /| / / __ \\/ __  / / __ \\/ __/
 | |/ |/ / /_/ / /_/ / / /_/ / /_
 |__/|__/\\____/\\__,_/_/\\____/\\__/
   """
	var logo_index = create_ascii_model(wow_logo, 0.3, Color(0.2, 0.6, 1.0))
	translate_model(logo_index, Vector3(0, 3, 0))
	
	# Create character model (simplified)
	var character_ascii = """
       o
      /|\\
      / \\
    """
	var character_index = create_ascii_model(character_ascii, 0.5, Color(1, 0.8, 0.2))
	translate_model(character_index, Vector3(0, 0, 0))
	
	# Create world elements
	var tree_ascii = """
      /\\
     //\\\\
    ///\\\\\\
     ||
    """
	var tree_index = create_ascii_model(tree_ascii, 0.3, Color(0.2, 0.8, 0.3))
	translate_model(tree_index, Vector3(-3, 0, 0))
	
	var tree2_index = create_ascii_model(tree_ascii, 0.3, Color(0.2, 0.8, 0.3))
	translate_model(tree2_index, Vector3(3, 0, 0))
	
	# Create ground
	var ground_ascii = """
  _______________________________________
 /                                       \\
/_________________________________________\\
    """
	var ground_index = create_ascii_model(ground_ascii, 0.2, Color(0.6, 0.4, 0.2))
	translate_model(ground_index, Vector3(0, -2, 0))
	
	# Create UI elements
	var health_bar = create_text_model("Health: [=========]", 0.3, Color(1, 0.2, 0.2))
	translate_model(health_bar, Vector3(-5, -3, 0))
	
	var mana_bar = create_text_model("Mana:   [=========]", 0.3, Color(0.2, 0.2, 1))
	translate_model(mana_bar, Vector3(-5, -3.5, 0))
	
	# Create animation
	var timer = Timer.new()
	timer.wait_time = 1.0 / 30.0  # 30 FPS
	timer.autostart = true
	
	var time = 0.0
	timer.timeout.connect(func():
		time += 0.02
		
		# Make character bounce slightly
		var bounce = sin(time * 2.0) * 0.1
		_models[character_index].transform = Transform3D().translated(Vector3(0, bounce, 0))
		
		# Make trees sway
		var sway1 = sin(time) * 0.05
		var sway2 = sin(time + 1.0) * 0.05
		_models[tree_index].transform = Transform3D().rotated(Vector3(0, 0, 1), sway1).translated(Vector3(-3, 0, 0))
		_models[tree2_index].transform = Transform3D().rotated(Vector3(0, 0, 1), sway2).translated(Vector3(3, 0, 0))
		
		render_frame()
	)
	add_child(timer)
	
	print("WoW interface created")

# Create a Bitcoin mining visualization
func create_bitcoin_visualization():
	# Clear models
	_models.clear()
	
	# Create Bitcoin logo
	var btc_logo = """
      _____  
     |  __ \\ 
     | |__) |__ _  ___ 
     |  ___/ _ \\ |/ __|
     | |  |  __/ | (__ 
     |_|   \\___|_|\\___|
    """
	var logo_index = create_ascii_model(btc_logo, 0.25, Color(1, 0.7, 0))
	translate_model(logo_index, Vector3(0, 3, 0))
	
	# Create price display
	var price_index = create_text_model("BTC: $300.00", 0.3, Color(0.2, 1, 0.2))
	translate_model(price_index, Vector3(-2, 1.5, 0))
	
	# Create mining visualization
	var mining = """
     ⚡ MINING BLOCKS ⚡
    [■■■■■■□□□□] 60%
    
    Hash rate: 25 MH/s
    Network: 120 TH/s
    """
	var mining_index = create_ascii_model(mining, 0.2, Color(0.9, 0.9, 0.9))
	translate_model(mining_index, Vector3(0, 0, 0))
	
	# Create transactions view
	var transactions = """
    +------------------------+
    | Recent Transactions    |
    +------------------------+
    | → 0.5 BTC | 14m ago   |
    | ← 1.2 BTC | 35m ago   |
    | → 0.8 BTC | 52m ago   |
    +------------------------+
    """
	var tx_index = create_ascii_model(transactions, 0.15, Color(0.8, 0.8, 1))
	translate_model(tx_index, Vector3(0, -2, 0))
	
	# Create animation
	var timer = Timer.new()
	timer.wait_time = 1.0 / 15.0  # 15 FPS
	timer.autostart = true
	
	var time = 0.0
	var progress = 0
	
	timer.timeout.connect(func():
		time += 0.1
		
		# Update mining progress
		progress = (progress + 1) % 10
		var mining_update = """
     ⚡ MINING BLOCKS ⚡
    [""" + "■".repeat(progress) + "□".repeat(10 - progress) + """] """ + str(progress * 10) + """%
    
    Hash rate: """ + str(20 + int(randf() * 10)) + """ MH/s
    Network: """ + str(115 + int(randf() * 10)) + """ TH/s
    """
		
		var new_mining_index = create_ascii_model(mining_update, 0.2, Color(0.9, 0.9, 0.9))
		translate_model(new_mining_index, Vector3(0, 0, 0))
		
		# Remove old mining visualization
		remove_model(mining_index)
		mining_index = new_mining_index
		
		# Update price
		var price = 300 + sin(time * 0.2) * 20
		var price_text = "BTC: $%.2f" % price
		var color_intensity = 0.5 + sin(time * 0.2) * 0.5
		
		var price_color
		if sin(time * 0.2) > 0:
			price_color = Color(0.2, 1 * color_intensity, 0.2)
		else:
			price_color = Color(1 * color_intensity, 0.2, 0.2)
		
		var new_price_index = create_text_model(price_text, 0.3, price_color)
		translate_model(new_price_index, Vector3(-2, 1.5, 0))
		
		# Remove old price display
		remove_model(price_index)
		price_index = new_price_index
		
		render_frame()
	)
	add_child(timer)
	
	print("Bitcoin visualization created")

# Create Wildstar visualization
func create_wildstar_visualization():
	# Clear models
	_models.clear()
	
	# Create Wildstar logo
	var wildstar_logo = """
  _    _ _ _     _     _             
 | |  | (_) |   | |   | |            
 | |  | |_| | __| |___| |_ __ _ _ __ 
 | |/\\| | | |/ _` / __| __/ _` | '__|
 \\  /\\  / | | (_| \\__ \\ || (_| | |   
  \\/  \\/|_|_|\\__,_|___/\\__\\__,_|_|   
    """
	var logo_index = create_ascii_model(wildstar_logo, 0.2, Color(0.2, 0.6, 1.0))
	translate_model(logo_index, Vector3(0, 3, 0))
	
	# Create character display
	var character = """
       o 
      /|\\
      / \\
    """
	var char_index = create_ascii_model(character, 0.5, Color(1, 0.5, 0))
	translate_model(char_index, Vector3(0, 0, 0))
	
	# Create UI elements
	var ui_text = """
    +-------------------+
    | Level 50 Spellslinger |
    +-------------------+
    | Health: 24500/24500 |
    | Shield: 12300/12300 |
    +-------------------+
    """
	var ui_index = create_ascii_model(ui_text, 0.15, Color(0.9, 0.9, 0.9))
	translate_model(ui_index, Vector3(-4, -3, 0))
	
	# Create environment
	var environment = """
                   /\\
        /\\        /  \\        /\\
       /  \\      /    \\      /  \\
      /    \\    /      \\    /    \\
     /      \\  /        \\  /      \\
    /________\\/          \\/________\\
    """
	var env_index = create_ascii_model(environment, 0.2, Color(0.2, 0.8, 0.3))
	translate_model(env_index, Vector3(0, -1, 0))
	
	# Create ability bar
	var abilities = """
    [1][2][3][4][5][6][7][8]
    """
	var abilities_index = create_ascii_model(abilities, 0.3, Color(0.8, 0.8, 0.2))
	translate_model(abilities_index, Vector3(0, -4, 0))
	
	# Create animation
	var timer = Timer.new()
	timer.wait_time = 1.0 / 30.0  # 30 FPS
	timer.autostart = true
	
	var time = 0.0
	timer.timeout.connect(func():
		time += 0.05
		
		# Make character move
		var move_x = sin(time) * 3
		var jumping = max(0, sin(time * 3.0)) * 0.5
		translate_model(char_index, Vector3(move_x, jumping, 0))
		
		# Update ability cooldowns
		var cooldown_char = "_"
		if int(time * 8) % 8 < 4:
			cooldown_char = "■"
		else:
			cooldown_char = "□"
		
		var abilities_update = """
    [1][""" + cooldown_char + """][3][4][5][6][7][8]
    """
		var new_abilities_index = create_ascii_model(abilities_update, 0.3, Color(0.8, 0.8, 0.2))
		translate_model(new_abilities_index, Vector3(0, -4, 0))
		
		# Remove old abilities display
		remove_model(abilities_index)
		abilities_index = new_abilities_index
		
		render_frame()
	)
	add_child(timer)
	
	print("Wildstar visualization created")

# Process function for real-time updates
func _process(delta):
	# You can add automatic camera movement or other updates here
	pass