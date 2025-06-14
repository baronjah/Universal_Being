extends Node3D
class_name ElementManager

# Scale manager properties (for universe integration)
var scale_level: String = "element"
var is_active: bool = false
var visibility: float = 0.0

# Scale manager signals (with unique names to avoid conflicts)
signal element_ready_for_activation
signal element_activated
signal element_deactivated
signal element_visibility_changed(value)

# Signals
signal world_generated
signal element_created(element, type)
signal element_transformed(old_element, new_element)
signal word_manifested(word, elements)

# Constants
const MAX_ELEMENTS = 5000
const ELEMENT_TYPES = ["fire", "water", "wood", "ash"]
const PROCESSING_ZONES = [
	Vector3(-50, -50, -50),
	Vector3(50, 50, 50)
]

# References to element scene/script paths
var element_scripts = {
	"fire": load("res://code/gdscript/scripts/elements_shapes_projection/fire_element.gd"),
	"water": load("res://code/gdscript/scripts/elements_shapes_projection/water_element.gd"),
	"wood": load("res://code/gdscript/scripts/elements_shapes_projection/wood_element.gd"),
	"ash": load("res://code/gdscript/scripts/elements_shapes_projection/ash_element.gd")
}

# World state
var is_world_active = false
var is_physics_active = true
var active_elements = {}
var total_element_count = 0
var current_frame = 0
var physics_intensity = 1.0

# Word database
var word_database = {}
var word_connections = {}
var manifested_words = {}

# Performance tracking
var process_time = 0
var last_process_time = 0
var processing_elements_per_frame = 100
var fps_timer = 0
var frame_count = 0
var current_fps = 0

# Resource management
var resource_manager = null
var global_resource_manager = null

# LOD (Level of Detail) system
var camera_position = Vector3.ZERO
var lod_distances = [
	15.0,   # LOD 0 - Full detail (closest)
	30.0,   # LOD 1 - Medium detail
	60.0,   # LOD 2 - Low detail
	120.0   # LOD 3 - Minimal detail (furthest)
]
var element_lod_states = {}  # Element instance ID -> LOD level

# Initialize the element system
func _ready():
	# Set scale level
	scale_level = "element"
	
	# Initialize element tracking
	for type in ELEMENT_TYPES:
		active_elements[type] = []
	
	# Set up processing mode
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Initialize local resource manager
	resource_manager = ElementResourceManager.new()
	resource_manager.name = "ElementResourceManager"
	add_child(resource_manager)
	
	# Try to get global resource manager if available
	if Engine.has_singleton("ResourceManager"):
		global_resource_manager = Engine.get_singleton("ResourceManager")
	
	# Create debug visualization
	create_debug_visualization()
	
	# Deactivate by default - will be activated by universe controller
	deactivate()

# Use update instead of _process to match ScaleManager interface
func _process(delta):
	if is_active:
		update(delta)

# ScaleManager interface implementation
func update(delta):
	if not is_world_active:
		return
	
	# FPS counter
	frame_count += 1
	fps_timer += delta
	if fps_timer >= 1.0:
		current_fps = frame_count
		frame_count = 0
		fps_timer = 0
		# Print FPS info for debugging
		print("FPS: ", current_fps, " | Elements: ", total_element_count, " | Processing per frame: ", processing_elements_per_frame)
	
	# Update camera position (for LOD calculations)
	update_camera_position()
		
	# Process element physics in chunks (not all at once for performance)
	var start_time = Time.get_ticks_msec()
	var elements_processed = 0
	
	# Calculate how many elements to process this frame
	var elements_to_process = min(processing_elements_per_frame, total_element_count)
	
	# Perform frustum culling - get the camera and frustum
	var camera = get_viewport().get_camera_3d()
	var frustum_planes = []
	
	if camera:
		# Get camera frustum planes
		frustum_planes = camera.get_frustum()
		
		# Perform initial culling pass (mark elements out of view for skipping)
		for type in active_elements:
			for element in active_elements[type]:
				if element and is_instance_valid(element):
					# Calculate distance to camera (quick check)
					var distance = element.global_position.distance_to(camera_position)
					
					# If element is beyond max LOD distance, mark it for minimal processing
					if distance > lod_distances[lod_distances.size() - 1] * 1.5:
						element.visible = false
					else:
						# More detailed frustum check
						var is_in_view = true
						
						# Quick sphere-vs-frustum test
						for plane in frustum_planes:
							var radius = element.scale.length() * 2.0  # Approximate element radius
							if plane.distance_to(element.global_position) < -radius:
								is_in_view = false
								break
						
						# Update visibility based on frustum check
						element.visible = is_in_view
	
	# Process a subset of elements each frame
	for type in active_elements:
		var type_elements = active_elements[type]
		var type_count = type_elements.size()
		
		if type_count == 0:
			continue
			
		# Calculate how many elements of this type to process
		var type_process_count = int(float(type_count) / total_element_count * elements_to_process)
		type_process_count = min(type_process_count, type_count)
		
		# Process the calculated number of elements
		for i in range(type_process_count):
			var element_index = (current_frame + i) % type_count
			var element = type_elements[element_index]
			
			if element and is_instance_valid(element):
				# Determine LOD level for this element
				var lod_level = calculate_element_lod(element)
				
				# Apply LOD optimizations
				apply_element_lod(element, lod_level)
				
				# Process element with physics and behavior
				if lod_level < 2:  # Only do full processing for detailed elements
					process_element(element, delta)
				elif current_frame % 3 == 0 and lod_level == 2:
					# Medium distance - process less frequently
					process_element(element, delta)
				elif current_frame % 10 == 0 and lod_level == 3:
					# Far distance - process very infrequently
					process_element(element, delta * 2)  # With larger delta to compensate
				
				elements_processed += 1
	
	# Update processing metrics
	current_frame = (current_frame + elements_processed) % max(1, total_element_count)
	process_time = Time.get_ticks_msec() - start_time
	
	# Adapt processing based on performance
	adapt_processing_load()
	
	# Check for element interactions periodically (less frequently when FPS is low)
	if current_frame % (10 + max(0, (30 - current_fps))) == 0:
		check_element_interactions()
		
	# Update environment effects
	update_environment_effects(delta)

# Update camera position for LOD calculations
func update_camera_position():
	# Get the active camera from scene
	var camera = get_viewport().get_camera_3d()
	if camera:
		camera_position = camera.global_position

# Calculate LOD level based on distance to camera
func calculate_element_lod(element):
	var distance = element.global_position.distance_to(camera_position)
	
	for i in range(lod_distances.size()):
		if distance < lod_distances[i]:
			return i
			
	return lod_distances.size()  # Furthest LOD level
	
# Apply LOD optimizations to element
func apply_element_lod(element, lod_level):
	var element_id = element.get_instance_id()
	
	# If LOD hasn't changed, do nothing
	if element_lod_states.has(element_id) and element_lod_states[element_id] == lod_level:
		return
		
	# Store new LOD state
	element_lod_states[element_id] = lod_level
	
	# Apply LOD-specific optimizations
	match lod_level:
		0:  # Highest detail
			# Full detail - particles, connections, light
			element.visible = true
			show_element_details(element, true)
			
		1:  # Medium detail
			# Reduced detail - simple visuals, still visible
			element.visible = true
			show_element_details(element, false)
			
		2:  # Low detail
			# Minimal detail - just the core element
			element.visible = true
			show_element_details(element, false)
			
		3:  # Minimal detail
			# Very minimal - simplified representation
			element.visible = true  # Keep visible but minimal
			show_element_details(element, false)
			
		_:  # Beyond rendering range
			# Don't render at all for very distant elements
			element.visible = false

# Helper to show/hide element details
func show_element_details(element, show_details):
	# Choose which resource manager to use
	var active_manager = global_resource_manager if global_resource_manager else resource_manager
	
	# Register/unregister with resource manager for visibility
	if show_details:
		active_manager.register_for_visibility(element)
	
	# Toggle detailed features based on LOD
	if element.has_method("set_detail_level"):
		element.set_detail_level(show_details)
	else:
		# Generic implementation if element doesn't have custom method
		if show_details:
			# Show particles, lights, etc. through resource manager
			if element.has_node("FireLight"):
				active_manager.register_light(element.get_node("FireLight"))
			if element.has_node("FlameParticles"):
				active_manager.register_particles(element.get_node("FlameParticles"))
			if element.has_node("SparkParticles"):
				active_manager.register_particles(element.get_node("SparkParticles"))
		else:
			# Hide particles, lights, etc.
			if element.has_node("FireLight"):
				element.get_node("FireLight").visible = false
				active_manager.unregister_light(element.get_node("FireLight"))
			if element.has_node("FlameParticles"):
				element.get_node("FlameParticles").emitting = false
				active_manager.unregister_particles(element.get_node("FlameParticles"))
			if element.has_node("SparkParticles"):
				element.get_node("SparkParticles").emitting = false
				active_manager.unregister_particles(element.get_node("SparkParticles"))

# Process a single element
func process_element(element, delta):
	if not is_instance_valid(element):
		return
		
	if is_physics_active:
		# Choose which resource manager to use
		var active_manager = global_resource_manager if global_resource_manager else resource_manager
		
		# Register for physics processing with resource manager
		if active_manager.register_for_physics(element):
			element.process_behavior(delta * physics_intensity)

# Create a new element
func create_element(type, position=Vector3.ZERO):
	if not element_scripts.has(type):
		printerr("Element type not found: " + type)
		return null
		
	if total_element_count >= MAX_ELEMENTS:
		# Replace oldest element instead of creating a new one
		remove_oldest_element()
	
	# Create the element
	var element = element_scripts[type].new()
	element.global_position = position
	
	# Add to scene and tracking
	add_child(element)
	active_elements[type].append(element)
	total_element_count += 1
	
	# Register with resource manager (initial state)
	if element.visible:
		resource_manager.register_for_visibility(element)
	
	# Emit signal for UI/other systems
	emit_signal("element_created", element, type)
	
	return element

# Remove oldest element (for memory management)
func remove_oldest_element():
	var oldest_type = ""
	var oldest_element = null
	var oldest_age = 0
	
	# Find oldest element across all types
	for type in active_elements:
		for element in active_elements[type]:
			if element and is_instance_valid(element):
				if element.properties.has("age") and element.properties["age"] > oldest_age:
					oldest_age = element.properties["age"]
					oldest_element = element
					oldest_type = type
	
	# Remove if found
	if oldest_element and is_instance_valid(oldest_element):
		# Unregister from resource manager
		resource_manager.unregister_from_visibility(oldest_element)
		resource_manager.unregister_from_physics(oldest_element)
		
		# Clean up any lights or particles
		if oldest_element.has_node("FireLight"):
			resource_manager.unregister_light(oldest_element.get_node("FireLight"))
		if oldest_element.has_node("FlameParticles"):
			resource_manager.unregister_particles(oldest_element.get_node("FlameParticles"))
		if oldest_element.has_node("SparkParticles"):
			resource_manager.unregister_particles(oldest_element.get_node("SparkParticles"))
			
		# Remove from scene and tracking
		active_elements[oldest_type].erase(oldest_element)
		oldest_element.queue_free()
		total_element_count -= 1

# Generate a world with elements
func generate_world(settings):
	# Clear existing elements
	clear_all_elements()
	
	# Apply settings
	physics_intensity = settings.get("physics_intensity", 1.0)
	
	# Create initial elements
	var world_size = settings.get("world_size", Vector3(100, 100, 100))
	var initial_elements = settings.get("initial_elements", {})
	
	for type in initial_elements:
		var count = initial_elements[type]
		for i in range(count):
			var pos = Vector3(
				randf_range(-world_size.x/2, world_size.x/2),
				randf_range(-world_size.y/2, world_size.y/2),
				randf_range(-world_size.z/2, world_size.z/2)
			)
			create_element(type, pos)
	
	# Activate the world
	is_world_active = true
	emit_signal("world_generated")

# Clear all elements
func clear_all_elements():
	for type in active_elements:
		for element in active_elements[type]:
			if element and is_instance_valid(element):
				# Unregister from resource manager before freeing
				resource_manager.unregister_from_visibility(element)
				resource_manager.unregister_from_physics(element)
				
				# Clean up any lights or particles
				if element.has_node("FireLight"):
					resource_manager.unregister_light(element.get_node("FireLight"))
				if element.has_node("FlameParticles"):
					resource_manager.unregister_particles(element.get_node("FlameParticles"))
				if element.has_node("SparkParticles"):
					resource_manager.unregister_particles(element.get_node("SparkParticles"))
				
				# Free the element
				element.queue_free()
		active_elements[type].clear()
	
	total_element_count = 0
	
	# Clean up any lingering resources
	resource_manager.cleanup_resources()

# Adapt processing based on performance
func adapt_processing_load():
	# Target framerate is 60fps (16.67ms per frame)
	# We want to use at most 10ms for element processing (leaving time for other game systems)
	var target_process_time = 10  # milliseconds
	
	# If FPS is too low, be more aggressive in reducing processing
	var fps_factor = 1.0
	if current_fps < 30:
		fps_factor = 0.5  # Cut processing in half if FPS is low
	elif current_fps < 45:
		fps_factor = 0.75  # Cut by 25% if FPS is moderate
	
	# If processing takes too long, reduce elements processed per frame
	if process_time > target_process_time: 
		# More aggressive reduction when performance is poor
		var reduction = max(5, int(processing_elements_per_frame * 0.1))  # Reduce by at least 5 or 10%
		processing_elements_per_frame = max(10, processing_elements_per_frame - reduction)
	elif process_time < target_process_time * 0.5 and current_fps > 55:
		# Slowly increase when performance is good
		processing_elements_per_frame = min(1000, processing_elements_per_frame + 5)
		
	# Apply FPS-based adjustment
	processing_elements_per_frame = int(processing_elements_per_frame * fps_factor)
	
	# Always ensure a minimum processing count
	processing_elements_per_frame = max(10, processing_elements_per_frame)

# Check for interactions between elements
func check_element_interactions():
	# This would be a more complex implementation in practice
	# For now, we'll just do basic proximity checks
	pass

# Update environment effects
func update_environment_effects(delta):
	# Apply global forces or effects
	pass
	
	# Update debug visualization (every 10 frames to avoid performance impact)
	if current_frame % 10 == 0:
		update_debug_visualization()

# Create debug visualization for LOD system
func create_debug_visualization():
	# Create a canvas layer for UI
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "DebugCanvasLayer"
	add_child(canvas_layer)
	
	# Create debug panel
	var panel = Panel.new()
	panel.name = "DebugPanel"
	panel.anchor_right = 0.3
	panel.anchor_bottom = 0.4  # Increased to make room for resource info
	panel.visible = false  # Hidden by default, can be toggled with a key
	canvas_layer.add_child(panel)
	
	# Create labels
	var fps_label = Label.new()
	fps_label.name = "FPSLabel"
	fps_label.text = "FPS: 0"
	fps_label.position = Vector2(10, 10)
	panel.add_child(fps_label)
	
	var elements_label = Label.new()
	elements_label.name = "ElementsLabel"
	elements_label.text = "Elements: 0"
	elements_label.position = Vector2(10, 30)
	panel.add_child(elements_label)
	
	var lod_label = Label.new()
	lod_label.name = "LODLabel"
	lod_label.text = "LOD Levels:"
	lod_label.position = Vector2(10, 50)
	panel.add_child(lod_label)
	
	for i in range(4):
		var level_label = Label.new()
		level_label.name = "LODLevel" + str(i)
		level_label.text = "  Level " + str(i) + ": 0"
		level_label.position = Vector2(10, 70 + i * 20)
		panel.add_child(level_label)
	
	# Add resource manager information
	var resource_label = Label.new()
	resource_label.name = "ResourceLabel"
	resource_label.text = "Resource Manager:"
	resource_label.position = Vector2(10, 160)
	panel.add_child(resource_label)
	
	var lights_label = Label.new()
	lights_label.name = "LightsLabel"
	lights_label.text = "  Lights: 0/" + str(resource_manager.MAX_ACTIVE_LIGHTS)
	lights_label.position = Vector2(10, 180)
	panel.add_child(lights_label)
	
	var particles_label = Label.new()
	particles_label.name = "ParticlesLabel"
	particles_label.text = "  Particles: 0/" + str(resource_manager.MAX_ACTIVE_PARTICLES)
	particles_label.position = Vector2(10, 200)
	panel.add_child(particles_label)
	
	var visible_label = Label.new()
	visible_label.name = "VisibleLabel"
	visible_label.text = "  Visible: 0/" + str(resource_manager.MAX_VISIBLE_ELEMENTS)
	visible_label.position = Vector2(10, 220)
	panel.add_child(visible_label)
	
	var physics_label = Label.new()
	physics_label.name = "PhysicsLabel"
	physics_label.text = "  Physics: 0/" + str(resource_manager.MAX_PHYSICS_ELEMENTS)
	physics_label.position = Vector2(10, 240)
	panel.add_child(physics_label)
	
	# Connect to resource manager signals
	resource_manager.connect("resource_status_changed", Callable(self, "_on_resource_status_changed"))
	
	# Add toggle button for debug visualization
	var toggle_button = Button.new()
	toggle_button.name = "ToggleDebugButton"
	toggle_button.text = "Toggle Debug"
	toggle_button.position = Vector2(10, 10)
	toggle_button.size = Vector2(120, 30)
	toggle_button.pressed.connect(Callable(self, "_on_toggle_debug_pressed"))
	canvas_layer.add_child(toggle_button)

# Update debug visualization
func update_debug_visualization():
	var panel = get_node_or_null("DebugCanvasLayer/DebugPanel")
	if panel and panel.visible:
		# Update FPS
		var fps_label = panel.get_node_or_null("FPSLabel")
		if fps_label:
			fps_label.text = "FPS: " + str(current_fps)
		
		# Update element count
		var elements_label = panel.get_node_or_null("ElementsLabel")
		if elements_label:
			elements_label.text = "Elements: " + str(total_element_count)
		
		# Count elements in each LOD level
		var lod_counts = [0, 0, 0, 0, 0]  # Five levels (0-3 + beyond)
		
		for lod_level in element_lod_states.values():
			if lod_level >= lod_counts.size():
				lod_counts[lod_counts.size() - 1] += 1
			else:
				lod_counts[lod_level] += 1
				
		# Update LOD level counts
		for i in range(4):
			var level_label = panel.get_node_or_null("LODLevel" + str(i))
			if level_label:
				level_label.text = "  Level " + str(i) + ": " + str(lod_counts[i])

# Toggle debug visualization
func _on_toggle_debug_pressed():
	var panel = get_node_or_null("DebugCanvasLayer/DebugPanel")
	if panel:
		panel.visible = !panel.visible

# Handle resource status changes from the resource manager
func _on_resource_status_changed(resource_type, count, max_count):
	var panel = get_node_or_null("DebugCanvasLayer/DebugPanel")
	if panel and panel.visible:
		match resource_type:
			"lights":
				var label = panel.get_node_or_null("LightsLabel")
				if label:
					label.text = "  Lights: " + str(count) + "/" + str(max_count)
			
			"particles":
				var label = panel.get_node_or_null("ParticlesLabel")
				if label:
					label.text = "  Particles: " + str(count) + "/" + str(max_count)
			
			"visible":
				var label = panel.get_node_or_null("VisibleLabel")
				if label:
					label.text = "  Visible: " + str(count) + "/" + str(max_count)
			
			"physics":
				var label = panel.get_node_or_null("PhysicsLabel")
				if label:
					label.text = "  Physics: " + str(count) + "/" + str(max_count)

# Manifest a word as elements
func manifest_word(word, position=Vector3.ZERO, size=10.0):
	if manifested_words.has(word):
		return manifested_words[word]
		
	var elements = []
	var points = generate_word_points(word, position, size)
	
	for point in points:
		var type = determine_element_type_for_word(word, point)
		var element = create_element(type, point)
		if element:
			elements.append(element)
	
	# Connect elements based on proximity
	connect_word_elements(elements)
	
	# Store manifested word
	manifested_words[word] = elements
	emit_signal("word_manifested", word, elements)
	
	return elements

# Generate points for a word
func generate_word_points(word, center, size):
	var points = []
	
	# This is placeholder logic
	# In a real implementation, you'd use a more sophisticated algorithm
	# to generate a point cloud that resembles the word
	
	# Simple example: create a sphere of points
	var char_count = word.length()
	var points_per_char = 5
	var total_points = char_count * points_per_char
	
	for i in range(total_points):
		var angle1 = randf() * TAU
		var angle2 = randf() * TAU
		
		var x = cos(angle1) * sin(angle2) * size
		var y = sin(angle1) * sin(angle2) * size
		var z = cos(angle2) * size
		
		points.append(center + Vector3(x, y, z))
	
	return points

# Determine element type for a word point
func determine_element_type_for_word(word, point):
	# Simple deterministic mapping
	var word_hash = 0
	for i in range(word.length()):
		word_hash += word.unicode_at(i)
	
	# Use hash and position to determine element type
	var position_hash = int(point.x + point.y * 10 + point.z * 100) % 100
	var combined_hash = (word_hash + position_hash) % ELEMENT_TYPES.size()
	
	return ELEMENT_TYPES[combined_hash]

# Connect elements in a word manifestation
func connect_word_elements(elements):
	var connection_threshold = 5.0  # Maximum distance for connection
	
	for i in range(elements.size()):
		var element_a = elements[i]
		if not is_instance_valid(element_a):
			continue
			
		for j in range(i+1, elements.size()):
			var element_b = elements[j]
			if not is_instance_valid(element_b):
				continue
				
			var distance = element_a.global_position.distance_to(element_b.global_position)
			if distance <= connection_threshold:
				element_a.connect_to(element_b)

# Save the current state to a file
func save_state(filepath):
	var save_data = {
		"elements": {},
		"manifested_words": {}
	}
	
	# Save elements by type
	for type in active_elements:
		save_data["elements"][type] = []
		for element in active_elements[type]:
			if element and is_instance_valid(element):
				save_data["elements"][type].append(element.archive())
	
	# Save manifested words
	for word in manifested_words:
		save_data["manifested_words"][word] = []
		for element in manifested_words[word]:
			if element and is_instance_valid(element):
				save_data["manifested_words"][word].append(element.get_instance_id())
	
	# Save to file
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "  "))
		file.close()
		return true
	return false

# Load state from a file
func load_state(filepath):
	var file = FileAccess.open(filepath, FileAccess.READ)
	if not file:
		return false
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return false
		
	var save_data = json.get_data()
	
	# Clear current state
	clear_all_elements()
	
	# Load elements by type
	# This would require more complex deserialization 
	# in a real implementation
	
	is_world_active = true
	return true

# ScaleManager interface implementation

# Activate the element system
func activate():
	# Set element system state
	is_active = true
	is_world_active = true
	set_visibility(1.0)
	
	# Enable processing
	set_process(true)
	set_physics_process(true)
	
	# Try to update resource manager
	if global_resource_manager and global_resource_manager.has_method("set_scale"):
		global_resource_manager.set_scale("element")
	
	# Make elements visible
	for type in active_elements:
		for element in active_elements[type]:
			if element and is_instance_valid(element):
				element.visible = true
	
	# Emit activation signal
	emit_signal("element_activated")

# Deactivate the element system
func deactivate():
	# Set element system state
	is_active = false
	is_world_active = false
	set_visibility(0.0)
	
	# Disable processing for efficiency
	set_process(false)
	set_physics_process(false)
	
	# Make elements invisible
	for type in active_elements:
		for element in active_elements[type]:
			if element and is_instance_valid(element):
				element.visible = false
	
	# Emit deactivation signal
	emit_signal("element_deactivated")

# Initialize from planet data
func initialize(planet_data):
	# Generate elements based on planet data
	var settings = {
		"world_size": Vector3(100, 100, 100),
		"initial_elements": {}
	}
	
	# Configure element generation based on planet type
	if planet_data:
		if planet_data.has("type"):
			match planet_data.type:
				"earth_like":
					settings.initial_elements = {
						"fire": 20,
						"water": 40,
						"wood": 30,
						"ash": 10
					}
				"rocky":
					settings.initial_elements = {
						"fire": 30,
						"water": 10,
						"wood": 5,
						"ash": 40
					}
				"gas":
					settings.initial_elements = {
						"fire": 50,
						"water": 20,
						"wood": 0,
						"ash": 0
					}
				"ocean":
					settings.initial_elements = {
						"fire": 5,
						"water": 80,
						"wood": 10,
						"ash": 5
					}
				_:  # Default
					settings.initial_elements = {
						"fire": 25,
						"water": 25,
						"wood": 25,
						"ash": 25
					}
					
		# Apply planet gravity
		if planet_data.has("gravity"):
			settings.physics_intensity = planet_data.gravity / 9.8
	else:
		# Default element distribution if no planet data
		settings.initial_elements = {
			"fire": 25,
			"water": 25,
			"wood": 25,
			"ash": 25
		}
	
	# Generate the element world
	generate_world(settings)
	
	emit_signal("element_ready_for_activation")

# Set visibility during transitions
func set_visibility(value: float):
	# Clamp visibility between 0 and 1
	visibility = clamp(value, 0.0, 1.0)
	
	# Update visual elements
	update_visual_components()
	
	# Emit signal with unique name
	emit_signal("element_visibility_changed", visibility)

# Update visual appearance during transitions
func update_visual_components():
	# Update element visibility based on transition state
	for type in active_elements:
		for element in active_elements[type]:
			if is_instance_valid(element):
				# Basic visibility (only show if visibility is high enough)
				element.visible = visibility > 0.1 && is_active
				
				# Material opacity
				var mesh = element.get_node_or_null("MeshInstance3D")
				if mesh and mesh.material_override:
					var material = mesh.material_override
					if material:
						# Simple solution - just modulate the alpha channel
						if material is StandardMaterial3D:
							var original_color = material.albedo_color
							material.albedo_color.a = visibility
						elif material is ShaderMaterial:
							material.set_shader_parameter("alpha", visibility)
				
				# Light intensity
				var light = element.get_node_or_null("FireLight")
				if light:
					# Store original energy if not already stored
					if not light.has_meta("original_energy"):
						light.set_meta("original_energy", light.light_energy)
						
					# Set energy based on visibility
					var original_energy = light.get_meta("original_energy")
					light.light_energy = original_energy * visibility
