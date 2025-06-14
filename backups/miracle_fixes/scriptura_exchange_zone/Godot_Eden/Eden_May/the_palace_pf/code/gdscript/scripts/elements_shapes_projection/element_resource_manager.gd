extends Node
class_name ElementResourceManager

# Resource limits
const MAX_ACTIVE_LIGHTS = 8
const MAX_ACTIVE_PARTICLES = 16
const MAX_VISIBLE_ELEMENTS = 200
const MAX_PHYSICS_ELEMENTS = 100

# Resource tracking
var active_lights = []
var active_particles = []
var visible_elements = []
var physics_elements = []

# Task queue for creation/deletion
var element_tasks = []
var task_mutex = Mutex.new()

# Performance metrics
var frame_time = 0
var physics_time = 0
var render_time = 0
var last_frame_count = 0
var last_culled_count = 0
var target_fps = 60

# Signal for resource status changes
signal resource_status_changed(resource_type, count, max_count)

func _ready():
	# Initialize pools
	active_lights = []
	active_particles = []
	visible_elements = []
	physics_elements = []
	
	# Start task processor
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(delta):
	# Process tasks in queue
	process_element_tasks()
	
	# Update performance metrics
	update_performance_metrics(delta)
	
	# Apply dynamic resource limits based on performance
	adjust_resource_limits()

# Register a light for resource management
func register_light(light_node):
	# Skip if we've hit the limit
	if active_lights.size() >= MAX_ACTIVE_LIGHTS:
		light_node.visible = false
		return false
		
	# Add to active lights
	if not active_lights.has(light_node):
		active_lights.append(light_node)
		light_node.visible = true
		emit_signal("resource_status_changed", "lights", active_lights.size(), MAX_ACTIVE_LIGHTS)
		return true
		
	return false

# Unregister a light
func unregister_light(light_node):
	if active_lights.has(light_node):
		active_lights.erase(light_node)
		emit_signal("resource_status_changed", "lights", active_lights.size(), MAX_ACTIVE_LIGHTS)
		return true
	return false

# Register particle system
func register_particles(particle_node):
	# Skip if we've hit the limit
	if active_particles.size() >= MAX_ACTIVE_PARTICLES:
		particle_node.emitting = false
		return false
		
	# Add to active particles
	if not active_particles.has(particle_node):
		active_particles.append(particle_node)
		particle_node.emitting = true
		emit_signal("resource_status_changed", "particles", active_particles.size(), MAX_ACTIVE_PARTICLES)
		return true
		
	return false

# Unregister particle system
func unregister_particles(particle_node):
	if active_particles.has(particle_node):
		active_particles.erase(particle_node)
		emit_signal("resource_status_changed", "particles", active_particles.size(), MAX_ACTIVE_PARTICLES)
		return true
	return false

# Register element for physics processing
func register_for_physics(element):
	# Skip if we've hit the limit
	if physics_elements.size() >= MAX_PHYSICS_ELEMENTS:
		# Create a task to add it when resources are available
		queue_element_task("add_physics", element)
		return false
		
	# Add to physics elements
	if not physics_elements.has(element):
		physics_elements.append(element)
		emit_signal("resource_status_changed", "physics", physics_elements.size(), MAX_PHYSICS_ELEMENTS)
		return true
		
	return false

# Unregister element from physics processing
func unregister_from_physics(element):
	if physics_elements.has(element):
		physics_elements.erase(element)
		emit_signal("resource_status_changed", "physics", physics_elements.size(), MAX_PHYSICS_ELEMENTS)
		
		# Check waiting tasks
		process_waiting_physics_tasks()
		return true
	return false

# Register element for visibility
func register_for_visibility(element):
	# Skip if we've hit the limit
	if visible_elements.size() >= MAX_VISIBLE_ELEMENTS:
		# Create a task to add it when resources are available
		queue_element_task("add_visible", element)
		element.visible = false
		return false
		
	# Add to visible elements
	if not visible_elements.has(element):
		visible_elements.append(element)
		element.visible = true
		emit_signal("resource_status_changed", "visible", visible_elements.size(), MAX_VISIBLE_ELEMENTS)
		return true
		
	return false

# Unregister element from visibility
func unregister_from_visibility(element):
	if visible_elements.has(element):
		visible_elements.erase(element)
		element.visible = false
		emit_signal("resource_status_changed", "visible", visible_elements.size(), MAX_VISIBLE_ELEMENTS)
		
		# Check waiting tasks
		process_waiting_visibility_tasks()
		return true
	return false

# Queue an element task for later processing
func queue_element_task(task_type, element, priority = 0):
	task_mutex.lock()
	element_tasks.append({
		"type": task_type,
		"element": element,
		"priority": priority,
		"timestamp": Time.get_ticks_msec()
	})
	task_mutex.unlock()

# Process element tasks from queue
func process_element_tasks():
	task_mutex.lock()
	
	# Sort by priority and timestamp
	element_tasks.sort_custom(Callable(self, "sort_tasks"))
	
	# Process a limited number of tasks per frame
	var tasks_to_process = min(5, element_tasks.size())
	
	for i in range(tasks_to_process):
		if element_tasks.size() > 0:
			var task = element_tasks.pop_front()
			
			# Skip if element is no longer valid
			if not is_instance_valid(task.element):
				continue
				
			# Process based on task type
			match task.type:
				"add_physics":
					if physics_elements.size() < MAX_PHYSICS_ELEMENTS:
						physics_elements.append(task.element)
						emit_signal("resource_status_changed", "physics", physics_elements.size(), MAX_PHYSICS_ELEMENTS)
				
				"add_visible":
					if visible_elements.size() < MAX_VISIBLE_ELEMENTS:
						visible_elements.append(task.element)
						task.element.visible = true
						emit_signal("resource_status_changed", "visible", visible_elements.size(), MAX_VISIBLE_ELEMENTS)
				
				"remove_physics":
					if physics_elements.has(task.element):
						physics_elements.erase(task.element)
						emit_signal("resource_status_changed", "physics", physics_elements.size(), MAX_PHYSICS_ELEMENTS)
				
				"remove_visible":
					if visible_elements.has(task.element):
						visible_elements.erase(task.element)
						task.element.visible = false
						emit_signal("resource_status_changed", "visible", visible_elements.size(), MAX_VISIBLE_ELEMENTS)
	
	task_mutex.unlock()

# Process waiting physics tasks if we have space
func process_waiting_physics_tasks():
	task_mutex.lock()
	
	var space_available = MAX_PHYSICS_ELEMENTS - physics_elements.size()
	var processed = 0
	
	if space_available > 0:
		# Find "add_physics" tasks to process
		for i in range(element_tasks.size() - 1, -1, -1):
			if processed >= space_available:
				break
				
			if i < element_tasks.size() and element_tasks[i].type == "add_physics":
				var task = element_tasks[i]
				
				# Skip if element is no longer valid
				if not is_instance_valid(task.element):
					element_tasks.remove_at(i)
					continue
					
				# Process the task
				physics_elements.append(task.element)
				element_tasks.remove_at(i)
				processed += 1
				emit_signal("resource_status_changed", "physics", physics_elements.size(), MAX_PHYSICS_ELEMENTS)
	
	task_mutex.unlock()

# Process waiting visibility tasks if we have space
func process_waiting_visibility_tasks():
	task_mutex.lock()
	
	var space_available = MAX_VISIBLE_ELEMENTS - visible_elements.size()
	var processed = 0
	
	if space_available > 0:
		# Find "add_visible" tasks to process
		for i in range(element_tasks.size() - 1, -1, -1):
			if processed >= space_available:
				break
				
			if i < element_tasks.size() and element_tasks[i].type == "add_visible":
				var task = element_tasks[i]
				
				# Skip if element is no longer valid
				if not is_instance_valid(task.element):
					element_tasks.remove_at(i)
					continue
					
				# Process the task
				visible_elements.append(task.element)
				task.element.visible = true
				element_tasks.remove_at(i)
				processed += 1
				emit_signal("resource_status_changed", "visible", visible_elements.size(), MAX_VISIBLE_ELEMENTS)
	
	task_mutex.unlock()

# Sort tasks by priority and timestamp
func sort_tasks(task_a, task_b):
	if task_a.priority != task_b.priority:
		return task_a.priority > task_b.priority
	return task_a.timestamp < task_b.timestamp

# Update performance metrics
func update_performance_metrics(delta):
	# Calculate FPS manually for more accuracy
	var current_frames = Engine.get_frames_drawn()
	var frames_this_second = current_frames - last_frame_count
	last_frame_count = current_frames
	
	# Update metrics if we have at least 10 new frames
	if frames_this_second >= 10:
		frame_time = 1000.0 / frames_this_second
		
		# Get physics and render time if available
		if Engine.get_physics_frames() > 0:
			physics_time = Engine.get_physics_interpolation_fraction() * 1000.0
		
		# Calculate actual FPS
		var actual_fps = frames_this_second / delta
		
		# Debug output
		if Engine.get_frames_drawn() % 60 == 0:
			print("Performance: FPS=", actual_fps, 
				", Frame time=", frame_time, "ms",
				", Lights=", active_lights.size(), "/", MAX_ACTIVE_LIGHTS,
				", Particles=", active_particles.size(), "/", MAX_ACTIVE_PARTICLES,
				", Visible=", visible_elements.size(), "/", MAX_VISIBLE_ELEMENTS,
				", Physics=", physics_elements.size(), "/", MAX_PHYSICS_ELEMENTS)

# Adjust resource limits based on performance
func adjust_resource_limits():
	# Only adjust if we have enough data
	if frame_time <= 0:
		return
		
	# Calculate performance margin
	var target_frame_time = 1000.0 / target_fps
	var performance_margin = (target_frame_time - frame_time) / target_frame_time
	
	# If we're running slower than target FPS, reduce limits
	if performance_margin < -0.1:  # More than 10% below target
		# Prioritize reducing expensive resources first
		prune_resources()
	
	# If we have a lot of headroom, we could increase limits
	# (Omitted for safety - manual increases preferred)

# Prune resources when performance is suffering
func prune_resources():
	# First, remove excess lights (most expensive)
	while active_lights.size() > 0 and frame_time > (1000.0 / target_fps) * 1.2:
		var light = active_lights.pop_back()
		if is_instance_valid(light):
			light.visible = false
		emit_signal("resource_status_changed", "lights", active_lights.size(), MAX_ACTIVE_LIGHTS)
		
	# Next, remove particles if still needed
	while active_particles.size() > 0 and frame_time > (1000.0 / target_fps) * 1.1:
		var particles = active_particles.pop_back()
		if is_instance_valid(particles):
			particles.emitting = false
		emit_signal("resource_status_changed", "particles", active_particles.size(), MAX_ACTIVE_PARTICLES)

# Check if we can create a light
func can_create_light():
	return active_lights.size() < MAX_ACTIVE_LIGHTS

# Check if we can create particles
func can_create_particles():
	return active_particles.size() < MAX_ACTIVE_PARTICLES

# Clean up invalid references
func cleanup_resources():
	# Clean up invalid references in all lists
	for i in range(active_lights.size() - 1, -1, -1):
		if not is_instance_valid(active_lights[i]):
			active_lights.remove_at(i)
			
	for i in range(active_particles.size() - 1, -1, -1):
		if not is_instance_valid(active_particles[i]):
			active_particles.remove_at(i)
			
	for i in range(visible_elements.size() - 1, -1, -1):
		if not is_instance_valid(visible_elements[i]):
			visible_elements.remove_at(i)
			
	for i in range(physics_elements.size() - 1, -1, -1):
		if not is_instance_valid(physics_elements[i]):
			physics_elements.remove_at(i)
			
	# Update signals
	emit_signal("resource_status_changed", "lights", active_lights.size(), MAX_ACTIVE_LIGHTS)
	emit_signal("resource_status_changed", "particles", active_particles.size(), MAX_ACTIVE_PARTICLES)
	emit_signal("resource_status_changed", "visible", visible_elements.size(), MAX_VISIBLE_ELEMENTS)
	emit_signal("resource_status_changed", "physics", physics_elements.size(), MAX_PHYSICS_ELEMENTS)