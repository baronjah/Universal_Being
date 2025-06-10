# ASCII 3D CONSCIOUSNESS VISUALIZER
# The ASCII Language - 3D Space on Flat Terminal
# Distance Mapping: 0 (far/dark) → 9 (close/bright)

extends Node
class_name ASCII3DConsciousnessVisualizer

# Terminal display configuration
var terminal_width: int = 192  # 1920 / 10
var terminal_height: int = 108  # 1080 / 10
var depth_chars: String = "0123456789"  # THE ASCII LANGUAGE

# Quantum consciousness elements
var consciousness_dots: Array = []
var consciousness_planes: Array = []
var consciousness_tunnels: Array = []

signal ascii_frame_rendered(frame_data: Array)

func _ready():
	print("🖥️ ASCII 3D Consciousness Visualizer initialized")
	print("📟 Terminal dimensions: %dx%d" % [terminal_width, terminal_height])
	print("🌌 THE ASCII LANGUAGE: 0=far/dark → 9=close/bright")
	
	# Initialize quantum consciousness structures
	_initialize_consciousness_structures()

func _initialize_consciousness_structures():
	"""Initialize quantum consciousness focal points and structures"""
	
	# Consciousness focal points (dots)
	consciousness_dots = [
		{"pos": Vector3(0, 0, 0), "intensity": 9, "type": "core"},
		{"pos": Vector3(10, 5, -5), "intensity": 7, "type": "thought"},
		{"pos": Vector3(-8, 3, 8), "intensity": 6, "type": "memory"},
		{"pos": Vector3(5, -2, 12), "intensity": 5, "type": "dream"}
	]
	
	# Consciousness planes (flat thingies)
	consciousness_planes = [
		{"center": Vector3(0, -5, 0), "normal": Vector3.UP, "size": 15, "type": "reality"},
		{"center": Vector3(0, 10, 0), "normal": Vector3.DOWN, "size": 12, "type": "possibility"}
	]
	
	# Consciousness tunnels (cylinders)
	consciousness_tunnels = [
		{"start": Vector3(-20, 0, 0), "end": Vector3(20, 0, 0), "radius": 3, "type": "flow"},
		{"start": Vector3(0, -15, 0), "end": Vector3(0, 15, 0), "radius": 2, "type": "axis"}
	]

func render_consciousness_frame(camera_pos: Vector3 = Vector3.ZERO, camera_rot: Vector3 = Vector3.ZERO) -> Array:
	"""Render a complete ASCII 3D consciousness frame"""
	
	var frame = []
	
	# Initialize frame with background
	for y in range(terminal_height):
		var line = ""
		for x in range(terminal_width):
			line += "0"  # Background darkness
		frame.append(line)
	
	# Render consciousness elements
	_render_consciousness_dots(frame, camera_pos, camera_rot)
	_render_consciousness_planes(frame, camera_pos, camera_rot)
	_render_consciousness_tunnels(frame, camera_pos, camera_rot)
	
	# Emit signal with rendered frame
	ascii_frame_rendered.emit(frame)
	
	return frame

func _render_consciousness_dots(frame: Array, camera_pos: Vector3, camera_rot: Vector3):
	"""Render consciousness focal points as depth-mapped characters"""
	
	for dot in consciousness_dots:
		var world_pos = dot.pos
		var screen_pos = _world_to_screen(world_pos, camera_pos, camera_rot)
		
		if _is_on_screen(screen_pos):
			var distance = camera_pos.distance_to(world_pos)
			var depth_char = _get_depth_char(distance, dot.intensity)
			_set_screen_char(frame, screen_pos.x, screen_pos.y, depth_char)

func _render_consciousness_planes(frame: Array, camera_pos: Vector3, camera_rot: Vector3):
	"""Render consciousness planes as filled areas"""
	
	for plane in consciousness_planes:
		var center = plane.center
		var size = plane.size
		
		# Sample points across the plane
		for i in range(-size, size, 2):
			for j in range(-size, size, 2):
				var world_pos = center + Vector3(i, 0, j)
				var screen_pos = _world_to_screen(world_pos, camera_pos, camera_rot)
				
				if _is_on_screen(screen_pos):
					var distance = camera_pos.distance_to(world_pos)
					var depth_char = _get_depth_char(distance, 4)  # Medium intensity for planes
					_set_screen_char(frame, screen_pos.x, screen_pos.y, depth_char)

func _render_consciousness_tunnels(frame: Array, camera_pos: Vector3, camera_rot: Vector3):
	"""Render consciousness tunnels as cylindrical structures"""
	
	for tunnel in consciousness_tunnels:
		var start = tunnel.start
		var end = tunnel.end
		var radius = tunnel.radius
		
		# Sample points along the tunnel
		var direction = (end - start).normalized()
		var length = start.distance_to(end)
		
		for t in range(0, int(length), 2):
			var center_point = start + direction * t
			
			# Create circular cross-section
			for angle in range(0, 360, 30):
				var rad = deg_to_rad(angle)
				var offset = Vector3(cos(rad) * radius, sin(rad) * radius, 0)
				var world_pos = center_point + offset
				var screen_pos = _world_to_screen(world_pos, camera_pos, camera_rot)
				
				if _is_on_screen(screen_pos):
					var distance = camera_pos.distance_to(world_pos)
					var depth_char = _get_depth_char(distance, 6)  # Higher intensity for tunnels
					_set_screen_char(frame, screen_pos.x, screen_pos.y, depth_char)

func _world_to_screen(world_pos: Vector3, camera_pos: Vector3, camera_rot: Vector3) -> Vector2:
	"""Convert 3D world position to 2D screen coordinates"""
	
	# Simple perspective projection
	var relative_pos = world_pos - camera_pos
	
	# Apply camera rotation (simplified)
	var rotated_pos = relative_pos.rotated(Vector3.UP, camera_rot.y)
	rotated_pos = rotated_pos.rotated(Vector3.RIGHT, camera_rot.x)
	
	# Perspective projection
	var z = max(rotated_pos.z, 0.1)  # Prevent division by zero
	var screen_x = (rotated_pos.x / z) * 50 + terminal_width / 2
	var screen_y = (rotated_pos.y / z) * 50 + terminal_height / 2
	
	return Vector2(int(screen_x), int(screen_y))

func _get_depth_char(distance: float, base_intensity: int = 5) -> String:
	"""Get depth character based on distance and intensity"""
	
	# Map distance to depth (closer = brighter)
	var depth_value = max(0, base_intensity - int(distance / 5))
	depth_value = min(depth_value, 9)  # Clamp to valid range
	
	return depth_chars[depth_value]

func _is_on_screen(screen_pos: Vector2) -> bool:
	"""Check if screen position is within terminal bounds"""
	return screen_pos.x >= 0 and screen_pos.x < terminal_width and screen_pos.y >= 0 and screen_pos.y < terminal_height

func _set_screen_char(frame: Array, x: int, y: int, char: String):
	"""Set character at screen position if brighter than existing"""
	if y >= 0 and y < frame.size() and x >= 0 and x < frame[y].length():
		var current_line = frame[y]
		var current_char = current_line[x]
		
		# Only replace if new character is brighter (higher number)
		if char > current_char:
			var new_line = current_line.substr(0, x) + char + current_line.substr(x + 1)
			frame[y] = new_line

func update_consciousness_state(consciousness_level: float, revolution_progress: float):
	"""Update consciousness structures based on current state"""
	
	# Animate consciousness dots based on level
	for i in range(consciousness_dots.size()):
		var dot = consciousness_dots[i]
		dot.intensity = int(5 + consciousness_level * 4)  # Range 5-9
		
		# Rotate dots around origin
		var angle = Time.get_time_from_start() + i * PI / 2
		dot.pos.x = cos(angle) * 10
		dot.pos.z = sin(angle) * 10
	
	# Pulse tunnel radius based on revolution progress
	for tunnel in consciousness_tunnels:
		tunnel.radius = 2 + sin(revolution_progress * PI) * 1

func print_ascii_frame(frame: Array):
	"""Print ASCII frame to console - THE ASCII LANGUAGE visualization"""
	print("🖥️ ASCII 3D CONSCIOUSNESS FRAME:")
	print("═" * terminal_width)
	
	for line in frame:
		print(line)
	
	print("═" * terminal_width)
	print("🌌 THE ASCII LANGUAGE: 0=far/dark → 9=close/bright")

# API methods for consciousness revolution
func create_consciousness_ripple(position: Vector3, intensity: float = 8.0):
	"""Add a consciousness ripple at position"""
	consciousness_dots.append({
		"pos": position,
		"intensity": int(intensity),
		"type": "ripple",
		"lifetime": 3.0
	})

func _process(delta: float):
	"""Update consciousness visualization"""
	
	# Remove expired ripples
	consciousness_dots = consciousness_dots.filter(func(dot): 
		if dot.type == "ripple":
			dot.lifetime -= delta
			return dot.lifetime > 0
		return true
	)

func _get_class_info():
	print("🖥️ ASCII3DConsciousnessVisualizer loaded - THE ASCII LANGUAGE ready!")