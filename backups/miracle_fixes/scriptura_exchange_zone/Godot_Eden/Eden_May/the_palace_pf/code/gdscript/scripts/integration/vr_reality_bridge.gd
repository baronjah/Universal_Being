extends Node
class_name VRRealityBridge

# Singleton instance
static var _instance = null

# Signals
signal vr_reality_change(old_reality, new_reality)
signal entity_manifestation_in_vr(entity_id, position)
signal gesture_detected(gesture_name, gesture_data)
signal vr_hand_interaction(hand, interaction_type, target_id)
signal vr_scale_changed(new_scale)
signal scan_visualization_ready(scan_id)

# Main references
var multi_device_controller = null
var vr_manager = null
var word_manifestor = null
var entity_manager = null
var records_system = null
var thread_pool = null

# VR specific
var current_reality: String = "physical"
var current_scale: String = "human"
var hand_tracking_active: bool = false
var teleport_enabled: bool = true
var passthrough_enabled: bool = false
var vr_initialized: bool = false

# Scale system (synchronized with VRManager)
var scale_levels = ["cosmic", "galactic", "stellar", "planetary", "human", "microscopic", "quantum"]
var scale_factors = {
    "cosmic": 0.000000001,    # 1 unit = 1 billion light years
    "galactic": 0.0000001,    # 1 unit = 100 million light years
    "stellar": 0.00001,       # 1 unit = 10,000 light years
    "planetary": 0.001,       # 1 unit = 1 million km
    "human": 1.0,             # 1 unit = 1 meter
    "microscopic": 1000.0,    # 1 unit = 1 millimeter
    "quantum": 1000000.0      # 1 unit = 1 micrometer
}

# Visualization settings
var point_cloud_max_points: int = 100000
var entity_highlight_color: Color = Color(0.2, 0.8, 0.8, 0.8)
var scan_visualization_type: String = "mesh"  # "mesh" or "point_cloud"
var hand_ray_length: float = 10.0
var hand_ray_width: float = 0.01

# Entity manipulation
var selected_entity = null
var grab_mode: bool = false
var entity_hover_effects = {}
var entity_cache = {}
var entity_mutex = Mutex.new()

# Performance settings
var lod_enabled: bool = true
var dynamic_quality: bool = true
var max_visible_entities: int = 1000
var physics_update_frequency: float = 0.1  # Seconds

# Internal state
var last_interaction_time: int = 0
var physics_update_timer: float = 0
var entity_update_list: Array = []
var thread_running: bool = false
var update_thread: Thread = null

# Get singleton instance
static func get_instance():
    if not _instance:
        _instance = VRRealityBridge.new()
    return _instance

func _init():
    # Register this node as singleton if needed
    if not Engine.has_singleton("VRRealityBridge"):
        Engine.register_singleton("VRRealityBridge", self)

func _ready():
    # Find required components
    multi_device_controller = MultiDeviceController.get_instance() if ClassDB.class_exists("MultiDeviceController") else null
    vr_manager = VRManager.get_instance() if ClassDB.class_exists("VRManager") else null
    
    # Look for other components in /root/main
    if has_node("/root/main"):
        var main = get_node("/root/main")
        if main:
            if main.has_method("get_word_manifestor"):
                word_manifestor = main.get_word_manifestor()
            if main.has_method("get_entity_manager"):
                entity_manager = main.get_entity_manager()
            if main.has_method("get_records_system"):
                records_system = main.get_records_system()
    
    # Get thread pool
    if has_node("/root/thread_pool_autoload"):
        thread_pool = get_node("/root/thread_pool_autoload")
    
    # Connect to VR Manager signals if available
    if vr_manager:
        if not vr_manager.is_connected("scale_transition_requested", Callable(self, "_on_vr_scale_transition")):
            vr_manager.connect("scale_transition_requested", Callable(self, "_on_vr_scale_transition"))
        
        if not vr_manager.is_connected("interaction_triggered", Callable(self, "_on_vr_interaction")):
            vr_manager.connect("interaction_triggered", Callable(self, "_on_vr_interaction"))
        
        if not vr_manager.is_connected("controller_gesture_detected", Callable(self, "_on_vr_gesture")):
            vr_manager.connect("controller_gesture_detected", Callable(self, "_on_vr_gesture"))
        
        if not vr_manager.is_connected("teleport_requested", Callable(self, "_on_vr_teleport")):
            vr_manager.connect("teleport_requested", Callable(self, "_on_vr_teleport"))

    # Connect to multi device controller signals if available
    if multi_device_controller:
        if not multi_device_controller.is_connected("reality_synchronized", Callable(self, "_on_reality_synchronized")):
            multi_device_controller.connect("reality_synchronized", Callable(self, "_on_reality_synchronized"))
        
        if not multi_device_controller.is_connected("scan_data_received", Callable(self, "_on_scan_data_received")):
            multi_device_controller.connect("scan_data_received", Callable(self, "_on_scan_data_received"))

    # Start background thread for physics/entity updates
    _start_update_thread()

# Initialize the VR bridge
func initialize() -> bool:
    print("VRRealityBridge: Initializing...")
    
    if not vr_manager:
        push_error("VRRealityBridge initialization failed: VRManager not found")
        return false
    
    # Initialize VR if not already initialized
    if not vr_manager.is_vr_initialized:
        vr_initialized = vr_manager.initialize()
    else:
        vr_initialized = true
    
    if vr_initialized:
        print("VR system initialized successfully")
        
        # Set up initial reality state
        _setup_reality(current_reality)
        
        # Set up initial scale
        _setup_scale(current_scale)
        
        # Set up controllers for entity interaction
        _setup_controllers_for_interaction()
    else:
        push_error("VR system initialization failed")
    
    return vr_initialized

# Process function called every frame
func _process(delta):
    if not vr_initialized:
        return
    
    # Update physics timer
    physics_update_timer += delta
    if physics_update_timer >= physics_update_frequency:
        physics_update_timer = 0
        _update_physics()
    
    # Process entity hover effects
    _process_entity_hover_effects(delta)
    
    # Process controller positions for hand tracking if enabled
    if hand_tracking_active:
        _process_hand_tracking(delta)

# Start background thread for physics updates
func _start_update_thread():
    if thread_running:
        return
    
    thread_running = true
    update_thread = Thread.new()
    update_thread.start(Callable(self, "_update_thread_function"))

# Background thread function
func _update_thread_function():
    print("VR Reality Bridge update thread started")
    
    while thread_running:
        # Process any entity updates in the background
        if not entity_update_list.is_empty():
            var entities_to_update = []
            
            entity_mutex.lock()
            entities_to_update = entity_update_list.duplicate()
            entity_update_list.clear()
            entity_mutex.unlock()
            
            for entity_id in entities_to_update:
                _update_entity_in_thread(entity_id)
        
        # Throttle thread
        OS.delay_msec(50)  # 20Hz updates

# Update entity in background thread
func _update_entity_in_thread(entity_id):
    if entity_manager and entity_manager.has_method("get_entity"):
        var entity = entity_manager.get_entity(entity_id)
        if entity:
            # Cache entity data for access from main thread
            entity_mutex.lock()
            entity_cache[entity_id] = {
                "position": entity.global_position if entity.has_method("global_position") else Vector3.ZERO,
                "type": entity.get_type() if entity.has_method("get_type") else "unknown",
                "scale": entity.scale if entity.has_method("scale") else Vector3.ONE,
                "last_update": Time.get_ticks_msec()
            }
            entity_mutex.unlock()

# Handle physical updates
func _update_physics():
    # Queue physics updates for background processing
    if entity_manager and entity_manager.has_method("get_all_entities"):
        var entities = entity_manager.get_all_entities()
        
        entity_mutex.lock()
        entity_update_list.append_array(entities)
        entity_mutex.unlock()

# Process hover effects for entities
func _process_entity_hover_effects(delta):
    entity_mutex.lock()
    for entity_id in entity_hover_effects:
        var effect = entity_hover_effects[entity_id]
        
        # Update effect time
        effect.time += delta
        
        # Apply effect based on type
        match effect.type:
            "pulse":
                _apply_pulse_effect(entity_id, effect)
            "highlight":
                _apply_highlight_effect(entity_id, effect)
            "bounce":
                _apply_bounce_effect(entity_id, effect)
    entity_mutex.unlock()

# Process hand tracking if enabled
func _process_hand_tracking(delta):
    if not vr_manager:
        return
    
    var left_controller = vr_manager.left_controller
    var right_controller = vr_manager.right_controller
    
    if left_controller and left_controller.get_is_active():
        _update_hand_interaction(left_controller, "left", delta)
    
    if right_controller and right_controller.get_is_active():
        _update_hand_interaction(right_controller, "right", delta)

# Update hand interaction with environment
func _update_hand_interaction(controller, hand_name, delta):
    # Check for ray intersection
    var ray = controller.get_node("RayCast3D") if controller.has_node("RayCast3D") else null
    
    if ray and ray.is_colliding():
        var collider = ray.get_collider()
        if collider:
            # Check if this is an entity
            if collider.has_meta("entity_id"):
                var entity_id = collider.get_meta("entity_id")
                
                # Add hover effect if not already present
                if not entity_hover_effects.has(entity_id):
                    entity_mutex.lock()
                    entity_hover_effects[entity_id] = {
                        "type": "highlight",
                        "time": 0.0,
                        "duration": 1.0,
                        "intensity": 0.5
                    }
                    entity_mutex.unlock()
                
                # Emit hand interaction signal
                emit_signal("vr_hand_interaction", hand_name, "hover", entity_id)

# Apply pulse visual effect to entity
func _apply_pulse_effect(entity_id, effect):
    if entity_manager and entity_manager.has_method("get_entity"):
        var entity = entity_manager.get_entity(entity_id)
        if entity and entity is Node3D:
            var pulse = 1.0 + sin(effect.time * 5) * 0.1 * effect.intensity
            entity.scale = Vector3(pulse, pulse, pulse)

# Apply highlight visual effect to entity
func _apply_highlight_effect(entity_id, effect):
    if entity_manager and entity_manager.has_method("get_entity"):
        var entity = entity_manager.get_entity(entity_id)
        if entity and entity is Node3D:
            # Look for mesh instances to apply material effect
            for child in entity.get_children():
                if child is MeshInstance3D and child.material_override:
                    var material = child.material_override
                    if material is StandardMaterial3D:
                        material.emission_enabled = true
                        material.emission = entity_highlight_color
                        material.emission_energy = 0.5 + sin(effect.time * 3) * 0.5 * effect.intensity

# Apply bounce visual effect to entity
func _apply_bounce_effect(entity_id, effect):
    if entity_manager and entity_manager.has_method("get_entity"):
        var entity = entity_manager.get_entity(entity_id)
        if entity and entity is Node3D:
            var bounce = sin(effect.time * 3) * 0.1 * effect.intensity
            var original_pos = entity_cache[entity_id].position if entity_cache.has(entity_id) else entity.global_position
            entity.global_position.y = original_pos.y + bounce

# Set up VR controllers for entity interaction
func _setup_controllers_for_interaction():
    if not vr_manager:
        return
    
    var left_controller = vr_manager.left_controller
    var right_controller = vr_manager.right_controller
    
    if left_controller:
        # Make sure controller has a ray cast for interaction
        if not left_controller.has_node("RayCast3D"):
            var ray = RayCast3D.new()
            ray.enabled = true
            ray.target_position = Vector3(0, 0, -hand_ray_length)
            ray.collision_mask = 1  # Set to entity collision layer
            left_controller.add_child(ray)
            
            # Add visual representation of ray
            var ray_mesh = ImmediateMesh.new()
            var ray_material = StandardMaterial3D.new()
            ray_material.albedo_color = Color(0.2, 0.8, 0.2, 0.5)
            ray_material.emission_enabled = true
            ray_material.emission = Color(0.2, 0.8, 0.2)
            ray_material.emission_energy = 1.0
            
            var ray_instance = MeshInstance3D.new()
            ray_instance.name = "RayVisual"
            ray_instance.mesh = ray_mesh
            ray_instance.material_override = ray_material
            
            # Draw line in immediate mesh
            ray_mesh.clear_surfaces()
            ray_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
            ray_mesh.surface_add_vertex(Vector3.ZERO)
            ray_mesh.surface_add_vertex(Vector3(0, 0, -hand_ray_length))
            ray_mesh.surface_end()
            
            left_controller.add_child(ray_instance)
    
    if right_controller:
        # Make sure controller has a ray cast for interaction
        if not right_controller.has_node("RayCast3D"):
            var ray = RayCast3D.new()
            ray.enabled = true
            ray.target_position = Vector3(0, 0, -hand_ray_length)
            ray.collision_mask = 1  # Set to entity collision layer
            right_controller.add_child(ray)
            
            # Add visual representation of ray
            var ray_mesh = ImmediateMesh.new()
            var ray_material = StandardMaterial3D.new()
            ray_material.albedo_color = Color(0.2, 0.2, 0.8, 0.5)
            ray_material.emission_enabled = true
            ray_material.emission = Color(0.2, 0.2, 0.8)
            ray_material.emission_energy = 1.0
            
            var ray_instance = MeshInstance3D.new()
            ray_instance.name = "RayVisual"
            ray_instance.mesh = ray_mesh
            ray_instance.material_override = ray_material
            
            # Draw line in immediate mesh
            ray_mesh.clear_surfaces()
            ray_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
            ray_mesh.surface_add_vertex(Vector3.ZERO)
            ray_mesh.surface_add_vertex(Vector3(0, 0, -hand_ray_length))
            ray_mesh.surface_end()
            
            right_controller.add_child(ray_instance)

# Set up reality visualization
func _setup_reality(reality_type: String):
    print("Setting up VR reality: ", reality_type)
    
    # Update current reality
    current_reality = reality_type
    
    # Apply visual changes based on reality type
    match reality_type:
        "physical":
            # Standard physical reality visualization
            _apply_physical_reality_visuals()
        
        "digital":
            # Digital/grid-like visualization
            _apply_digital_reality_visuals()
        
        "astral":
            # Ethereal/astral visualization
            _apply_astral_reality_visuals()
    
    # Emit signal for reality change
    emit_signal("vr_reality_change", null, reality_type)

# Apply physical reality visuals
func _apply_physical_reality_visuals():
    # This would adjust the visual style to represent physical reality
    # For example, disable any special post-processing effects
    _set_environment_effects({
        "bloom_enabled": false,
        "glow_enabled": false,
        "fog_enabled": false
    })

# Apply digital reality visuals
func _apply_digital_reality_visuals():
    # Apply grid-like visuals for digital reality
    _set_environment_effects({
        "bloom_enabled": true,
        "glow_enabled": true,
        "glow_intensity": 0.8,
        "glow_bloom": 0.4,
        "fog_enabled": true,
        "fog_color": Color(0, 0.1, 0.2),
        "fog_sun_color": Color(0, 0.4, 0.8)
    })

# Apply astral reality visuals
func _apply_astral_reality_visuals():
    # Apply ethereal visuals for astral reality
    _set_environment_effects({
        "bloom_enabled": true,
        "glow_enabled": true,
        "glow_intensity": 1.2,
        "glow_bloom": 0.8,
        "fog_enabled": true,
        "fog_color": Color(0.1, 0, 0.2),
        "fog_sun_color": Color(0.6, 0.3, 0.8)
    })

# Apply environmental visual effects
func _set_environment_effects(effects: Dictionary):
    # Find the environment
    var env = null
    
    # Try to find WorldEnvironment node
    var world_env = get_tree().get_nodes_in_group("world_environment")
    if world_env.size() > 0:
        env = world_env[0].environment
    
    # If not found, try camera environment
    if not env and vr_manager and vr_manager.xr_origin:
        var camera = vr_manager.xr_origin.get_node("XRCamera")
        if camera and camera.environment:
            env = camera.environment
    
    # Apply effects if we found an environment
    if env:
        # Apply bloom settings
        if effects.has("bloom_enabled"):
            env.glow_enabled = effects.bloom_enabled
        
        # Apply glow settings
        if effects.has("glow_enabled"):
            env.glow_enabled = effects.glow_enabled
        
        if effects.has("glow_intensity"):
            env.glow_intensity = effects.glow_intensity
        
        if effects.has("glow_bloom"):
            env.glow_bloom = effects.glow_bloom
        
        # Apply fog settings
        if effects.has("fog_enabled"):
            env.fog_enabled = effects.fog_enabled
        
        if effects.has("fog_color"):
            env.fog_color = effects.fog_color
        
        if effects.has("fog_sun_color"):
            env.fog_sun_color = effects.fog_sun_color

# Set up world scale 
func _setup_scale(scale_name: String):
    if not scale_levels.has(scale_name):
        push_error("Invalid scale name: " + scale_name)
        return
    
    print("Setting up VR scale: ", scale_name)
    
    # Update current scale
    current_scale = scale_name
    
    # Get scale factor
    var scale_factor = scale_factors[scale_name] if scale_factors.has(scale_name) else 1.0
    
    # Apply scale factor to VR origin if needed
    if vr_manager and vr_manager.xr_origin:
        # This would adjust how the player perceives scale in VR
        # You might not directly scale the XR Origin, but instead
        # scale the world around it or adjust rendering parameters
        
        # Emit scale changed signal
        emit_signal("vr_scale_changed", scale_name)
    
    # If using multi-device controller, notify it of scale change
    if multi_device_controller:
        # Update scale in multi-device controller
        multi_device_controller.queue_scene_sync("scale_change", {
            "scale": scale_name,
            "factor": scale_factor
        })

# Handle a requested scale transition from VR
func _on_vr_scale_transition(from_scale, to_scale):
    # Only proceed if the target scale is valid
    if scale_levels.has(to_scale):
        # Update our scale
        _setup_scale(to_scale)
        
        # Notify the VR manager that transition is complete if needed
        vr_manager.complete_scale_transition()

# Handle reality synchronization from multi-device controller
func _on_reality_synchronized(reality_type):
    if reality_type != current_reality:
        _setup_reality(reality_type)

# Handle VR interactions with entities
func _on_vr_interaction(object, interaction_type):
    if object is Node and object.has_meta("entity_id"):
        var entity_id = object.get_meta("entity_id")
        
        match interaction_type:
            "interact":
                # Handle interaction with entity
                _interact_with_entity(entity_id)
            
            "select":
                # Handle selection of entity
                _select_entity(entity_id)
            
            "grab":
                # Handle grabbing entity
                _grab_entity(entity_id)
            
            "release":
                # Handle releasing entity
                _release_entity(entity_id)

# Handle gesture detected in VR
func _on_vr_gesture(controller, gesture_type, gesture_data):
    # Forward gesture to other systems
    emit_signal("gesture_detected", gesture_type, gesture_data)
    
    # Handle specific gestures
    match gesture_type:
        "pinch":
            # Handle pinch gesture (zoom in)
            var current_index = scale_levels.find(current_scale)
            if current_index < scale_levels.size() - 1:
                _setup_scale(scale_levels[current_index + 1])
        
        "spread":
            # Handle spread gesture (zoom out)
            var current_index = scale_levels.find(current_scale)
            if current_index > 0:
                _setup_scale(scale_levels[current_index - 1])
        
        "wave":
            # Handle wave gesture (switch reality)
            _cycle_reality()
        
        "point":
            # Handle point gesture (select)
            # This would raycast from the gesture position
            pass

# Handle teleport request from VR
func _on_vr_teleport(position):
    if vr_manager:
        vr_manager.execute_teleport(position)

# Handle scan data received
func _on_scan_data_received(scan_id, scan_data):
    print("VR Reality Bridge: Scan data received, preparing visualization")
    
    # Submit to thread pool for visualization preparation
    if thread_pool:
        thread_pool.submit_task(self, "_prepare_scan_visualization", {"scan_id": scan_id, "scan_data": scan_data}, "scan_viz")
    else:
        _prepare_scan_visualization({"scan_id": scan_id, "scan_data": scan_data})

# Prepare scan visualization
func _prepare_scan_visualization(scan_info):
    var scan_id = scan_info.scan_id
    var scan_data = scan_info.scan_data
    
    # Create visualization components
    # In a real implementation, this would process point cloud or mesh data
    # For this example, we'll just emit the signal
    
    print("Scan visualization ready: ", scan_id)
    emit_signal("scan_visualization_ready", scan_id)

# Interact with entity
func _interact_with_entity(entity_id):
    print("VR interaction with entity: ", entity_id)
    
    # Add bounce effect
    entity_mutex.lock()
    entity_hover_effects[entity_id] = {
        "type": "bounce",
        "time": 0.0,
        "duration": 1.0,
        "intensity": 1.0
    }
    entity_mutex.unlock()
    
    # If this entity has a word source, speak it
    if entity_manager and entity_manager.has_method("get_entity"):
        var entity = entity_manager.get_entity(entity_id)
        if entity and entity.has_method("get_property"):
            var source_word = entity.get_property("source_word", "")
            if not source_word.is_empty():
                print("Entity source word: ", source_word)
                
                # This would trigger text-to-speech or other feedback
                pass

# Select entity
func _select_entity(entity_id):
    print("VR selecting entity: ", entity_id)
    
    # Store selected entity
    selected_entity = entity_id
    
    # Add highlight effect
    entity_mutex.lock()
    entity_hover_effects[entity_id] = {
        "type": "highlight",
        "time": 0.0,
        "duration": -1.0,  # Indefinite until selection changes
        "intensity": 1.0
    }
    entity_mutex.unlock()
    
    # Provide haptic feedback if supported
    if vr_manager and vr_manager.right_controller:
        # This would trigger haptic feedback
        pass

# Grab entity
func _grab_entity(entity_id):
    print("VR grabbing entity: ", entity_id)
    
    # Mark as in grab mode
    grab_mode = true
    
    # If the entity manager supports it, set entity to grabbed state
    if entity_manager and entity_manager.has_method("set_entity_grabbed"):
        entity_manager.set_entity_grabbed(entity_id, true)

# Release entity
func _release_entity(entity_id):
    print("VR releasing entity: ", entity_id)
    
    # Mark as not in grab mode
    grab_mode = false
    
    # If the entity manager supports it, set entity to not grabbed
    if entity_manager and entity_manager.has_method("set_entity_grabbed"):
        entity_manager.set_entity_grabbed(entity_id, false)

# Create entity from word in VR
func create_entity_from_word(word: String, position: Vector3, options: Dictionary = {}) -> String:
    print("Creating entity from word in VR: ", word, " at ", position)
    
    # Use word manifestor if available
    if word_manifestor and word_manifestor.has_method("manifest_word"):
        # Prepare options with position
        var manifest_options = options.duplicate()
        manifest_options["position"] = position
        manifest_options["reality"] = current_reality
        
        # Manifest the word
        var entity_id = word_manifestor.manifest_word(word, manifest_options)
        
        # Add pulse effect to highlight new entity
        if not entity_id.is_empty():
            entity_mutex.lock()
            entity_hover_effects[entity_id] = {
                "type": "pulse",
                "time": 0.0,
                "duration": 2.0,
                "intensity": 1.0
            }
            entity_mutex.unlock()
            
            # Notify creation in VR
            emit_signal("entity_manifestation_in_vr", entity_id, position)
            
            # If multi-device controller is available, sync to other devices
            if multi_device_controller:
                multi_device_controller.queue_word_sync(word, manifest_options)
            
            return entity_id
    
    return ""

# Cycle reality type
func _cycle_reality():
    var reality_types = ["physical", "digital", "astral"]
    var current_index = reality_types.find(current_reality)
    var next_index = (current_index + 1) % reality_types.size()
    var next_reality = reality_types[next_index]
    
    # Change reality
    _setup_reality(next_reality)
    
    # If multi-device controller is available, sync to other devices
    if multi_device_controller:
        multi_device_controller.change_reality(next_reality)

# Get current state in dictionary form
func get_state() -> Dictionary:
    return {
        "vr_initialized": vr_initialized,
        "current_reality": current_reality,
        "current_scale": current_scale,
        "hand_tracking_active": hand_tracking_active,
        "selected_entity": selected_entity,
        "grab_mode": grab_mode,
        "entity_hover_effects": entity_hover_effects.size(),
        "thread_running": thread_running
    }