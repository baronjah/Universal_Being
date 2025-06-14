extends Node
class_name ResourceManagerSingleton

# Resource limits - these are dynamic based on scale
var MAX_LIGHTS = 8
var MAX_PARTICLES = 16
var MAX_PHYSICS_OBJECTS = 100
var MAX_VISIBLE_OBJECTS = 200

# Scale-dependent limits
const SCALE_LIMITS = {
    "universe": {
        "lights": 4,
        "particles": 8,
        "physics": 50,
        "visible": 100
    },
    "galaxy": {
        "lights": 8,
        "particles": 16,
        "physics": 100,
        "visible": 200
    },
    "star_system": {
        "lights": 12,
        "particles": 24,
        "physics": 150,
        "visible": 300
    },
    "planet": {
        "lights": 16,
        "particles": 32,
        "physics": 200,
        "visible": 400
    },
    "element": {
        "lights": 8,
        "particles": 16,
        "physics": 100,
        "visible": 200
    }
}

# Resource tracking
var active_lights = []
var active_particles = []
var visible_objects = []
var physics_objects = []

# Task queues
var light_queue = []
var particle_queue = []
var object_queue = []
var physics_queue = []

# Current scale
var current_scale = "universe"

# Performance monitoring
var frame_time = 0
var fps_timer = 0
var frame_count = 0
var current_fps = 60
var target_fps = 60

# Signals
signal resource_limits_updated
signal resource_queue_processed
signal performance_updated(fps, frame_time)

func _ready():
    process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(delta):
    # Update performance metrics
    update_performance_metrics(delta)
    
    # Process resource queues
    process_resource_queues()
    
    # Dynamically adjust limits based on performance
    if fps_timer >= 1.0:
        adjust_resource_limits()

# Set current scale and update limits
func set_scale(scale_name: String):
    if not SCALE_LIMITS.has(scale_name):
        push_error("Invalid scale name: " + scale_name)
        return
        
    current_scale = scale_name
    
    # Update limits
    MAX_LIGHTS = SCALE_LIMITS[scale_name]["lights"]
    MAX_PARTICLES = SCALE_LIMITS[scale_name]["particles"]
    MAX_PHYSICS_OBJECTS = SCALE_LIMITS[scale_name]["physics"]
    MAX_VISIBLE_OBJECTS = SCALE_LIMITS[scale_name]["visible"]
    
    # Clean up resources that exceed the new limits
    clean_up_excess_resources()
    
    emit_signal("resource_limits_updated")

# Register a light source
func register_light(light_node: Node, priority: int = 0) -> bool:
    # Clean up invalid references
    clean_invalid_references(active_lights)
    
    # Check if we can add more lights
    if active_lights.size() >= MAX_LIGHTS:
        # Queue for later if we're at the limit
        light_queue.append({
            "node": light_node,
            "priority": priority,
            "timestamp": Time.get_ticks_msec()
        })
        
        # Hide the light for now
        light_node.visible = false
        return false
    
    # Check if light is already registered
    if active_lights.has(light_node):
        return true
    
    # Add to active lights
    active_lights.append(light_node)
    light_node.visible = true
    return true

# Unregister a light source
func unregister_light(light_node: Node) -> bool:
    # Check if light is in active list
    var index = active_lights.find(light_node)
    if index != -1:
        active_lights.remove_at(index)
        
        # Process queued lights
        process_light_queue()
        return true
    
    # Also check the queue
    for i in range(light_queue.size()):
        if light_queue[i].node == light_node:
            light_queue.remove_at(i)
            return true
    
    return false

# Register a particle system
func register_particles(particle_node: Node, priority: int = 0) -> bool:
    # Clean up invalid references
    clean_invalid_references(active_particles)
    
    # Check if we can add more particle systems
    if active_particles.size() >= MAX_PARTICLES:
        # Queue for later
        particle_queue.append({
            "node": particle_node,
            "priority": priority,
            "timestamp": Time.get_ticks_msec()
        })
        
        # Turn off emitting for now
        particle_node.emitting = false
        return false
    
    # Check if particle system is already registered
    if active_particles.has(particle_node):
        return true
    
    # Add to active particles
    active_particles.append(particle_node)
    particle_node.emitting = true
    return true

# Unregister a particle system
func unregister_particles(particle_node: Node) -> bool:
    # Check if in active list
    var index = active_particles.find(particle_node)
    if index != -1:
        active_particles.remove_at(index)
        
        # Process queued particles
        process_particle_queue()
        return true
    
    # Also check the queue
    for i in range(particle_queue.size()):
        if particle_queue[i].node == particle_node:
            particle_queue.remove_at(i)
            return true
    
    return false

# Register an object for physics processing
func register_for_physics(object: Node, priority: int = 0) -> bool:
    # Clean up invalid references
    clean_invalid_references(physics_objects)
    
    # Check if we can add more physics objects
    if physics_objects.size() >= MAX_PHYSICS_OBJECTS:
        # Queue for later
        physics_queue.append({
            "node": object,
            "priority": priority,
            "timestamp": Time.get_ticks_msec()
        })
        return false
    
    # Check if already registered
    if physics_objects.has(object):
        return true
    
    # Add to physics objects
    physics_objects.append(object)
    return true

# Unregister an object from physics processing
func register_for_visibility(object: Node, priority: int = 0) -> bool:
    # Clean up invalid references
    clean_invalid_references(visible_objects)
    
    # Check if we can add more visible objects
    if visible_objects.size() >= MAX_VISIBLE_OBJECTS:
        # Queue for later
        object_queue.append({
            "node": object,
            "priority": priority,
            "timestamp": Time.get_ticks_msec()
        })
        
        # Hide the object for now
        object.visible = false
        return false
    
    # Check if already registered
    if visible_objects.has(object):
        return true
    
    # Add to visible objects
    visible_objects.append(object)
    object.visible = true
    return true

# Unregister an object from visibility
func unregister_from_visibility(object: Node) -> bool:
    # Check if in active list
    var index = visible_objects.find(object)
    if index != -1:
        visible_objects.remove_at(index)
        object.visible = false
        
        # Process queued visible objects
        process_object_queue()
        return true
    
    # Also check the queue
    for i in range(object_queue.size()):
        if object_queue[i].node == object:
            object_queue.remove_at(i)
            return true
    
    return false

# Process all resource queues
func process_resource_queues():
    process_light_queue()
    process_particle_queue()
    process_physics_queue()
    process_object_queue()
    
    emit_signal("resource_queue_processed")

# Process light queue
func process_light_queue():
    # Sort by priority and timestamp
    light_queue.sort_custom(Callable(self, "sort_queue_items"))
    
    # Process as many as we can
    while light_queue.size() > 0 and active_lights.size() < MAX_LIGHTS:
        var item = light_queue.pop_front()
        
        # Skip if node is no longer valid
        if not is_instance_valid(item.node):
            continue
            
        # Add to active lights
        active_lights.append(item.node)
        item.node.visible = true

# Process particle queue
func process_particle_queue():
    # Sort by priority and timestamp
    particle_queue.sort_custom(Callable(self, "sort_queue_items"))
    
    # Process as many as we can
    while particle_queue.size() > 0 and active_particles.size() < MAX_PARTICLES:
        var item = particle_queue.pop_front()
        
        # Skip if node is no longer valid
        if not is_instance_valid(item.node):
            continue
            
        # Add to active particles
        active_particles.append(item.node)
        item.node.emitting = true

# Process physics queue
func process_physics_queue():
    # Sort by priority and timestamp
    physics_queue.sort_custom(Callable(self, "sort_queue_items"))
    
    # Process as many as we can
    while physics_queue.size() > 0 and physics_objects.size() < MAX_PHYSICS_OBJECTS:
        var item = physics_queue.pop_front()
        
        # Skip if node is no longer valid
        if not is_instance_valid(item.node):
            continue
            
        # Add to physics objects
        physics_objects.append(item.node)

# Process visibility queue
func process_object_queue():
    # Sort by priority and timestamp
    object_queue.sort_custom(Callable(self, "sort_queue_items"))
    
    # Process as many as we can
    while object_queue.size() > 0 and visible_objects.size() < MAX_VISIBLE_OBJECTS:
        var item = object_queue.pop_front()
        
        # Skip if node is no longer valid
        if not is_instance_valid(item.node):
            continue
            
        # Add to visible objects
        visible_objects.append(item.node)
        item.node.visible = true

# Helper to sort queue items by priority and timestamp
func sort_queue_items(a, b):
    if a.priority != b.priority:
        return a.priority > b.priority
    return a.timestamp < b.timestamp

# Clean up references to invalid objects
func clean_invalid_references(array):
    for i in range(array.size() - 1, -1, -1):
        if not is_instance_valid(array[i]):
            array.remove_at(i)

# Clean up excess resources when limits change
func clean_up_excess_resources():
    # Clean lights
    while active_lights.size() > MAX_LIGHTS:
        var light = active_lights.pop_back()
        if is_instance_valid(light):
            light.visible = false
    
    # Clean particles
    while active_particles.size() > MAX_PARTICLES:
        var particles = active_particles.pop_back()
        if is_instance_valid(particles):
            particles.emitting = false
    
    # Clean physics objects
    while physics_objects.size() > MAX_PHYSICS_OBJECTS:
        physics_objects.pop_back()
    
    # Clean visible objects
    while visible_objects.size() > MAX_VISIBLE_OBJECTS:
        var object = visible_objects.pop_back()
        if is_instance_valid(object):
            object.visible = false

# Update performance metrics
func update_performance_metrics(delta):
    # Update FPS counter
    frame_count += 1
    fps_timer += delta
    
    if fps_timer >= 1.0:
        current_fps = frame_count
        frame_count = 0
        fps_timer = 0
        
        # Calculate frame time
        frame_time = 1000.0 / max(1, current_fps)
        
        # Emit signal with performance data
        emit_signal("performance_updated", current_fps, frame_time)

# Adjust resource limits based on performance
func adjust_resource_limits():
    # Target framerate is 60fps (16.67ms per frame)
    var target_frame_time = 1000.0 / target_fps
    
    # Calculate performance margin
    var performance_margin = (target_frame_time - frame_time) / target_frame_time
    
    # If we're running slower than target FPS, reduce limits
    if performance_margin < -0.2:  # More than 20% below target
        # Reduce limits to improve performance
        MAX_LIGHTS = max(2, int(MAX_LIGHTS * 0.8))
        MAX_PARTICLES = max(4, int(MAX_PARTICLES * 0.8))
        MAX_PHYSICS_OBJECTS = max(20, int(MAX_PHYSICS_OBJECTS * 0.8))
        MAX_VISIBLE_OBJECTS = max(50, int(MAX_VISIBLE_OBJECTS * 0.8))
        
        # Clean up excess resources
        clean_up_excess_resources()
        
        emit_signal("resource_limits_updated")
    
    # If we have headroom, gradually increase limits
    elif performance_margin > 0.2 and current_fps >= target_fps * 0.9:  # More than 20% above target
        # Get base limits for current scale
        var base_limits = SCALE_LIMITS[current_scale]
        
        # Increase limits, but don't go more than 50% above the base
        MAX_LIGHTS = min(int(base_limits["lights"] * 1.5), MAX_LIGHTS + 1)
        MAX_PARTICLES = min(int(base_limits["particles"] * 1.5), MAX_PARTICLES + 2)
        MAX_PHYSICS_OBJECTS = min(int(base_limits["physics"] * 1.5), MAX_PHYSICS_OBJECTS + 10)
        MAX_VISIBLE_OBJECTS = min(int(base_limits["visible"] * 1.5), MAX_VISIBLE_OBJECTS + 20)
        
        emit_signal("resource_limits_updated")

# Get resource usage information
func get_resource_stats() -> Dictionary:
    return {
        "lights": {
            "active": active_lights.size(),
            "max": MAX_LIGHTS,
            "queued": light_queue.size()
        },
        "particles": {
            "active": active_particles.size(),
            "max": MAX_PARTICLES,
            "queued": particle_queue.size()
        },
        "physics": {
            "active": physics_objects.size(),
            "max": MAX_PHYSICS_OBJECTS,
            "queued": physics_queue.size()
        },
        "visible": {
            "active": visible_objects.size(),
            "max": MAX_VISIBLE_OBJECTS,
            "queued": object_queue.size()
        },
        "performance": {
            "fps": current_fps,
            "frame_time": frame_time,
            "target_fps": target_fps
        }
    }

# Check if any resources are available or must be queued
func can_add_light() -> bool:
    clean_invalid_references(active_lights)
    return active_lights.size() < MAX_LIGHTS

func can_add_particles() -> bool:
    clean_invalid_references(active_particles)
    return active_particles.size() < MAX_PARTICLES

func can_add_physics_object() -> bool:
    clean_invalid_references(physics_objects)
    return physics_objects.size() < MAX_PHYSICS_OBJECTS

func can_add_visible_object() -> bool:
    clean_invalid_references(visible_objects)
    return visible_objects.size() < MAX_VISIBLE_OBJECTS