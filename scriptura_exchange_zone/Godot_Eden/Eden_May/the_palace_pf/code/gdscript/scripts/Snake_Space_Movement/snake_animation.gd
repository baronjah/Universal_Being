extends Node
# res://code/gdscript/scripts/Snake_Space_Movement/snake_animation.gd
# JSH_World/object
# Animation system for the space snake game


class_name SnakeAnimator


#class_name JSHAnimationController

var animation_queue = []
var active_animations = {}
var animation_speed_modifier = 1.0
var animation_mutex = Mutex.new()

signal animation_completed(object_id, animation_name)


# Animation properties
var animation_speed = 1.0
var elasticity = 0.3 # How elastic the snake movement is
var max_animation_duration = 0.5 # Maximum duration for animations
var frequency = 2.0 # Oscillation frequency for movement
var animation_values = {} # Store animation state

# Visibility animation
var visibility_fade_speed = 2.0
var max_visible_distance = 50.0
var min_visible_distance = 5.0

# Color animation
var color_cycle = false
var color_cycle_speed = 0.5
var color_palette = [
	Color(0.2, 0.7, 0.9), # Blue
	Color(0.3, 0.8, 1.0), # Light blue
	Color(0.1, 0.5, 0.8)  # Dark blue
]

# Model metadata
var segment_metadata = {
	"temperature": 25.0,
	"elasticity_factor": 1.0,
	"rotation_speed": 1.0
}

# References to materials
var materials = []

# Initialize animator
#func _init():
	## Default initialization
	#pass

# Animation templates for reuse
const ANIMATION_TEMPLATES = {
	"snake_move": {
		"duration": 0.2,
		"easing": "ease_out",
		"properties": ["position"]
	},
	"console_appear": {
		"duration": 0.3,
		"easing": "ease_out_bounce",
		"properties": ["position", "modulate"]
	},
	"star_twinkle": {
		"duration": 1.5,
		"easing": "ease_in_out_sine",
		"properties": ["modulate", "scale"],
		"loop": true
	}
}

func register_object(object_id: String, node: Node, template: String = ""):
	animation_mutex.lock()
	active_animations[object_id] = {
		"node": node,
		"animations": {},
		"template": template if template else "",
		"status": "idle"
	}
	animation_mutex.unlock()

func create_animation(object_id: String, animation_name: String, properties: Dictionary, duration: float = 1.0, template: String = ""):
	if not active_animations.has(object_id):
		return false
		
	var template_data = {}
	if template and ANIMATION_TEMPLATES.has(template):
		template_data = ANIMATION_TEMPLATES[template].duplicate(true)
	
	animation_mutex.lock()
	active_animations[object_id]["animations"][animation_name] = {
		"properties": properties,
		"duration": duration,
		"elapsed": 0.0,
		"status": "ready",
		"initial_values": {},
		"template": template if template else active_animations[object_id]["template"]
	}
	animation_mutex.unlock()
	return true

func start_animation(object_id: String, animation_name: String):
	if not active_animations.has(object_id):
		return false
	if not active_animations[object_id]["animations"].has(animation_name):
		return false
		
	var anim_data = active_animations[object_id]["animations"][animation_name]
	var node = active_animations[object_id]["node"]
	
	# Store initial values
	for property in anim_data["properties"].keys():
		anim_data["initial_values"][property] = node.get(property)
	
	anim_data["status"] = "running"
	anim_data["start_time"] = Time.get_ticks_msec()
	
	animation_queue.append({"object_id": object_id, "animation": animation_name})
	return true

func process_animations(delta: float):
	animation_mutex.lock()
	var completed_animations = []
	
	for i in range(animation_queue.size() - 1, -1, -1):
		var anim_ref = animation_queue[i]
		var object_id = anim_ref["object_id"]
		var animation_name = anim_ref["animation"]
		
		if not active_animations.has(object_id) or not active_animations[object_id]["animations"].has(animation_name):
			animation_queue.remove_at(i)
			continue
		
		var anim_data = active_animations[object_id]["animations"][animation_name]
		var node = active_animations[object_id]["node"]
		
		if anim_data["status"] != "running":
			continue
			
		anim_data["elapsed"] += delta * animation_speed_modifier
		var progress = min(anim_data["elapsed"] / anim_data["duration"], 1.0)
		
		# Apply animation
		for property in anim_data["properties"].keys():
			var start_value = anim_data["initial_values"][property]
			var end_value = anim_data["properties"][property]
			
			# Handle different property types
			if start_value is Vector3 and end_value is Vector3:
				node.set(property, start_value.lerp(end_value, progress))
			elif start_value is Vector2 and end_value is Vector2:
				node.set(property, start_value.lerp(end_value, progress))
			elif start_value is Color and end_value is Color:
				node.set(property, start_value.lerp(end_value, progress))
			elif start_value is float and end_value is float:
				node.set(property, lerp(start_value, end_value, progress))
		
		# Check for completion
		if progress >= 1.0:
			anim_data["status"] = "completed"
			completed_animations.append({"object_id": object_id, "animation": animation_name})
			animation_queue.remove_at(i)
	
	animation_mutex.unlock()
	
	# Emit signals for completed animations
	for completed in completed_animations:
		animation_completed.emit(completed["object_id"], completed["animation"])

# Set up materials and meshes
func setup_materials(meshes):
	materials.clear()
	
	for mesh in meshes:
		if mesh.get_node("MeshInstance3D"):
			var material = mesh.get_node("MeshInstance3D").get_surface_material(0)
			if material:
				materials.append(material)
				
				# Initialize animation values for this material
				var id = mesh.get_instance_id()
				animation_values[id] = {
					"original_color": material.albedo_color,
					"target_color": material.albedo_color,
					"color_t": 0.0,
					"original_scale": mesh.scale,
					"target_scale": mesh.scale,
					"scale_t": 0.0,
					"original_position": mesh.position,
					"position_offset": Vector3.ZERO,
					"visibility": 1.0,
					"phase": randf() * 2.0 * PI # Random starting phase
				}

# Process animations

func process_animations_add(delta, snake_segments, camera):
	update_visibility(delta, snake_segments, camera)
	update_movement_animation(delta, snake_segments)
	update_color_animation(delta, snake_segments)
	
	if color_cycle:
		cycle_colors(delta)

# Update segment visibility based on camera distance
func update_visibility(delta, snake_segments, camera):
	if !camera:
		return
		
	for i in range(snake_segments.size()):
		var segment = snake_segments[i]
		var distance = camera.global_transform.origin.distance_to(segment.node.global_transform.origin)
		
		var target_visibility = 1.0
		if distance > max_visible_distance:
			target_visibility = 0.0
		elif distance > min_visible_distance:
			target_visibility = 1.0 - (distance - min_visible_distance) / (max_visible_distance - min_visible_distance)
			
		var id = segment.node.get_instance_id()
		if animation_values.has(id):
			# Smoothly transition visibility
			animation_values[id].visibility = lerp(animation_values[id].visibility, target_visibility, delta * visibility_fade_speed)
			
			# Apply to material
			var mesh_instance = segment.node.get_node("MeshInstance3D")
			if mesh_instance and mesh_instance.material:
				mesh_instance.material.albedo_color.a = animation_values[id].visibility

# Update the elastic movement animation of snake segments
func update_movement_animation(delta, snake_segments):
	# Skip if we have fewer than 2 segments
	if snake_segments.size() < 2:
		return
		
	# Update head first
	var head = snake_segments[0].node
	var head_id = head.get_instance_id()
	
	# Update each segment's position based on previous segment
	for i in range(1, snake_segments.size()):
		var segment = snake_segments[i].node
		var prev_segment = snake_segments[i-1].node
		var id = segment.get_instance_id()
		
		if animation_values.has(id):
			var target_pos = segment.position
			var direction = (prev_segment.position - segment.position).normalized()
			
			# Calculate elasticity offset
			var distance = segment.position.distance_to(prev_segment.position)
			var elastic_factor = clamp(distance * elasticity, 0.0, segment_metadata.elasticity_factor)
			
			# Add sine wave movement for more interesting animation
			var phase = animation_values[id].phase + delta * frequency
			animation_values[id].phase = phase
			
			var side_vector = direction.cross(Vector3.UP).normalized()
			if side_vector.length() < 0.1:
				side_vector = direction.cross(Vector3.RIGHT).normalized()
				
			var wave_offset = side_vector * sin(phase) * 0.1
			
			# Calculate final position offset
			animation_values[id].position_offset = direction * elastic_factor + wave_offset
			
			# Apply position offset
			segment.position = target_pos + animation_values[id].position_offset
			
			# Calculate rotation to face direction of movement
			if direction.length() > 0.01:
				var look_at_pos = segment.position + direction
				segment.look_at(look_at_pos, Vector3.UP)
				# Apply some rotation based on the wave
				segment.rotate_object_local(Vector3.FORWARD, sin(phase) * 0.1)

# Update color animations
func update_color_animation(delta, snake_segments):
	for i in range(snake_segments.size()):
		var segment = snake_segments[i].node
		var id = segment.get_instance_id()
		
		if animation_values.has(id):
			var mesh_instance = segment.get_node("MeshInstance3D")
			if mesh_instance and mesh_instance.material:
				# Smoothly transition between colors
				if animation_values[id].color_t < 1.0:
					animation_values[id].color_t += delta
					var t = min(1.0, animation_values[id].color_t)
					
					var new_color = animation_values[id].original_color.lerp(
						animation_values[id].target_color, t)
					
					# Preserve alpha from visibility
					new_color.a = animation_values[id].visibility
					mesh_instance.material.albedo_color = new_color

# Cycle through colors
func cycle_colors(delta):
	for id in animation_values:
		animation_values[id].color_t = 0.0
		
		# Get next color in palette
		var current_index = color_palette.find(animation_values[id].target_color)
		var next_index = (current_index + 1) % color_palette.size()
		
		animation_values[id].original_color = animation_values[id].target_color
		animation_values[id].target_color = color_palette[next_index]

# Start a "breathing" animation for idle state
func start_breathing_animation(snake_segments):
	for i in range(snake_segments.size()):
		var segment = snake_segments[i].node
		var id = segment.get_instance_id()
		
		if animation_values.has(id):
			animation_values[id].phase = i * 0.5 # Offset phase by segment index
			
			# Set up slight scale pulsing
			animation_values[id].original_scale = segment.scale
			animation_values[id].target_scale = segment.scale * 1.1
			animation_values[id].scale_t = 0.0

# Start a color pulse animation (e.g., when eating food)
func start_color_pulse(snake_segments, pulse_color):
	for i in range(snake_segments.size()):
		var segment = snake_segments[i].node
		var id = segment.get_instance_id()
		
		if animation_values.has(id):
			var mesh_instance = segment.get_node("MeshInstance3D")
			if mesh_instance and mesh_instance.material:
				animation_values[id].original_color = mesh_instance.material.albedo_color
				animation_values[id].target_color = pulse_color
				animation_values[id].color_t = 0.0

# Set elasticity factor (useful when changing speed)
func set_elasticity(new_elasticity):
	elasticity = new_elasticity
	segment_metadata.elasticity_factor = new_elasticity * 2.0

# Set animation speed
func set_animation_speed(new_speed):
	animation_speed = new_speed
	frequency = new_speed * 2.0

# Set color palette
func set_color_palette(palette):
	color_palette = palette

# Toggle color cycling
func toggle_color_cycle():
	color_cycle = !color_cycle
	return color_cycle

# Calculate shape animation key frames
func calculate_keyframes(start_value, end_value, duration, easing_type="linear"):
	var frames = []
	var step_count = int(duration * 60) # 60 fps
	
	for i in range(step_count + 1):
		var t = float(i) / step_count
		var value
		
		match easing_type:
			"linear":
				value = lerp(start_value, end_value, t)
			"ease_in":
				value = lerp(start_value, end_value, t * t)
			"ease_out":
				value = lerp(start_value, end_value, 1.0 - (1.0 - t) * (1.0 - t))
			"ease_in_out":
				if t < 0.5:
					value = lerp(start_value, end_value, 2.0 * t * t)
				else:
					t = t - 0.5
					value = lerp(start_value, end_value, 0.5 + 2.0 * t * (1.0 - t))
		
		frames.append(value)
	
	return frames

# Apply elastic deformation to mesh
func apply_elastic_deformation(mesh_instance, stretch_factor, direction):
	if mesh_instance and mesh_instance.mesh:
		# This is a placeholder for mesh deformation
		# In a real implementation, you would modify the mesh vertices
		# For now, we'll just scale the mesh in the direction of movement
		var scale_factor = Vector3(1.0, 1.0, 1.0)
		
		if direction.x != 0:
			scale_factor.x = 1.0 + stretch_factor
			scale_factor.y = 1.0 - stretch_factor * 0.3
			scale_factor.z = 1.0 - stretch_factor * 0.3
		elif direction.y != 0:
			scale_factor.y = 1.0 + stretch_factor
			scale_factor.x = 1.0 - stretch_factor * 0.3
			scale_factor.z = 1.0 - stretch_factor * 0.3
		elif direction.z != 0:
			scale_factor.z = 1.0 + stretch_factor
			scale_factor.x = 1.0 - stretch_factor * 0.3
			scale_factor.y = 1.0 - stretch_factor * 0.3
			
		mesh_instance.scale = scale_factor
