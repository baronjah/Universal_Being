extends Node

class_name FractalTimeDimension

signal time_scale_changed(scale, origin)
signal timeline_branch_created(branch_id, parent_id, origin_time)
signal timeline_branch_merged(source_branch, target_branch, merge_point)
signal temporal_echo_detected(echo_id, origin_time, current_time, intensity)
signal dimensional_shift_occurred(from_dimension, to_dimension, shift_point)

# Fractal time configuration
const BASE_DIMENSION = 2  # Time corresponds to dimension 2
const FRACTAL_DIMENSIONS = {
    "micro": {
        "id": "micro",
        "scale": 0.001,
        "color": Color(0.2, 0.8, 0.3),  # Light Green
        "energy_cost": 5.0,
        "stability": 0.95,
        "oscillation_rate": 1000.0  # Hz
    },
    "milli": {
        "id": "milli",
        "scale": 0.01,
        "color": Color(0.3, 0.9, 0.4),  # Green
        "energy_cost": 3.0,
        "stability": 0.97,
        "oscillation_rate": 100.0  # Hz
    },
    "normal": {
        "id": "normal",
        "scale": 1.0,
        "color": Color(0.3, 1.0, 0.3),  # Standard Green
        "energy_cost": 0.0,
        "stability": 1.0,
        "oscillation_rate": 1.0  # Hz
    },
    "macro": {
        "id": "macro",
        "scale": 10.0,
        "color": Color(0.4, 0.9, 0.3),  # Yellow-Green
        "energy_cost": 7.0,
        "stability": 0.9,
        "oscillation_rate": 0.1  # Hz
    },
    "cosmic": {
        "id": "cosmic",
        "scale": 100.0,
        "color": Color(0.5, 0.8, 0.3),  # Olive Green
        "energy_cost": 15.0,
        "stability": 0.8,
        "oscillation_rate": 0.01  # Hz
    }
}

# Time branches (timelines)
var active_branches = {}
var current_branch_id = "main"

# Fractal time scales
var current_scale_id = "normal"
var current_scale = 1.0
var target_scale = 1.0
var scale_transition_duration = 1.0
var scale_transition_progress = 0.0
var scale_transition_active = false

# Time state
var origin_time = 0
var current_time = 0
var elapsed_time = 0
var time_offset = 0
var time_dilation_factor = 1.0

# Temporal memory
var time_memory = {}
var temporal_echoes = {}
var temporal_imprints = {}

# Oscillation state
var oscillation_phase = 0.0
var oscillation_amplitude = 1.0
var oscillation_frequency = 1.0

# Component references
var tunnel_controller
var ethereal_tunnel_manager
var word_pattern_visualizer
var numeric_token_system
var akashic_record_connector

# Time tunnels
var time_tunnels = {}
var time_anchors = {}

# Visualization state
var visualization_active = false
var visualization_node = null

func _ready():
    # Initialize origin time
    origin_time = Time.get_unix_time_from_system()
    current_time = origin_time
    
    # Create main branch
    _create_timeline_branch("main", "", origin_time)
    
    # Auto-detect components
    _detect_components()
    
    # Set up time anchors
    _create_time_anchors()

func _process(delta):
    # Update current time
    var real_delta = delta * current_scale
    elapsed_time += real_delta
    current_time = origin_time + elapsed_time + time_offset
    
    # Process scale transition if active
    if scale_transition_active:
        _process_scale_transition(delta)
    
    # Update oscillation phase
    oscillation_phase += delta * oscillation_frequency * 2.0 * PI
    while oscillation_phase > 2.0 * PI:
        oscillation_phase -= 2.0 * PI
    
    # Process temporal echoes
    _process_temporal_echoes(delta)
    
    # Update visualization if active
    if visualization_active and visualization_node:
        _update_visualization(delta)

func _detect_components():
    # Find tunnel controller
    if not tunnel_controller:
        var potential_controllers = get_tree().get_nodes_in_group("tunnel_controllers")
        if potential_controllers.size() > 0:
            tunnel_controller = potential_controllers[0]
            print("Found tunnel controller: " + tunnel_controller.name)
            ethereal_tunnel_manager = tunnel_controller.ethereal_tunnel_manager
    
    # Find word pattern visualizer
    if not word_pattern_visualizer:
        var potential_visualizers = get_tree().get_nodes_in_group("word_pattern_visualizers")
        if potential_visualizers.size() > 0:
            word_pattern_visualizer = potential_visualizers[0]
    
    # Find numeric token system
    if not numeric_token_system:
        var potential_systems = get_tree().get_nodes_in_group("numeric_token_systems")
        if potential_systems.size() > 0:
            numeric_token_system = potential_systems[0]
    
    # Find akashic record connector
    if not akashic_record_connector:
        var potential_connectors = get_tree().get_nodes_in_group("akashic_record_connectors")
        if potential_connectors.size() > 0:
            akashic_record_connector = potential_connectors[0]

func _create_time_anchors():
    if not ethereal_tunnel_manager:
        return
    
    # Create an anchor for each fractal time scale
    for scale_id in FRACTAL_DIMENSIONS:
        var scale_data = FRACTAL_DIMENSIONS[scale_id]
        var anchor_id = "time_" + scale_id
        
        # Create anchor at dimension 2 (time)
        var position = Vector3(0, BASE_DIMENSION, scale_data.scale)
        
        # Register anchor if it doesn't exist
        if not ethereal_tunnel_manager.has_anchor(anchor_id):
            ethereal_tunnel_manager.register_anchor(anchor_id, position, "time_scale")
            
            # Record in time anchors
            time_anchors[scale_id] = anchor_id
            
            # Create temporal word pattern
            if word_pattern_visualizer:
                var pattern_text = "time_scale_" + scale_id
                var energy = 10.0 + (abs(scale_data.scale - 1.0) * 5.0)
                var dimension = BASE_DIMENSION
                
                word_pattern_visualizer.add_word_pattern(pattern_text, energy, dimension)
            
            # Create numeric token
            if numeric_token_system:
                var token_value = int(scale_data.scale * 100)
                numeric_token_system.create_token(token_value, "TIME", "time_scale")
        }
    }
    
    # Create tunnels between adjacent scales
    var scale_ids = FRACTAL_DIMENSIONS.keys()
    scale_ids.sort_custom(Callable(self, "_sort_by_scale"))
    
    for i in range(scale_ids.size() - 1):
        var source_scale = scale_ids[i]
        var target_scale = scale_ids[i + 1]
        
        var source_anchor = time_anchors[source_scale]
        var target_anchor = time_anchors[target_scale]
        
        var tunnel_id = source_anchor + "_to_" + target_anchor
        
        # Create tunnel if it doesn't exist
        if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
            var tunnel = ethereal_tunnel_manager.establish_tunnel(source_anchor, target_anchor, BASE_DIMENSION)
            
            if tunnel:
                time_tunnels[source_scale + "_to_" + target_scale] = tunnel.id
                
                # Set tunnel stability based on scale difference
                var stability = min(
                    FRACTAL_DIMENSIONS[source_scale].stability,
                    FRACTAL_DIMENSIONS[target_scale].stability
                )
                
                ethereal_tunnel_manager.set_tunnel_stability(tunnel.id, stability)
        }
    }

func _sort_by_scale(a, b):
    return FRACTAL_DIMENSIONS[a].scale < FRACTAL_DIMENSIONS[b].scale

func shift_time_scale(scale_id, transition_duration = 1.0):
    if not FRACTAL_DIMENSIONS.has(scale_id):
        print("Invalid time scale: " + scale_id)
        return false
    
    if scale_id == current_scale_id:
        return true  # Already at this scale
    
    var old_scale_id = current_scale_id
    var old_scale = current_scale
    
    # Set new scale
    current_scale_id = scale_id
    target_scale = FRACTAL_DIMENSIONS[scale_id].scale
    
    # Set up transition
    scale_transition_duration = max(0.1, transition_duration)
    scale_transition_progress = 0.0
    scale_transition_active = true
    
    # Set oscillation frequency based on scale
    oscillation_frequency = FRACTAL_DIMENSIONS[scale_id].oscillation_rate
    
    # Create temporal echo at transition point
    create_temporal_echo(current_time, old_scale_id, scale_id)
    
    # Record dimensional shift
    if akashic_record_connector:
        var shift_data = {
            "from_scale": old_scale_id,
            "to_scale": scale_id,
            "from_value": old_scale,
            "to_value": target_scale,
            "shift_time": current_time
        }
        
        akashic_record_connector.record_dimensional_data(BASE_DIMENSION, shift_data, "time_scale_shift")
    }
    
    # Create word pattern for scale shift
    if word_pattern_visualizer:
        var pattern_text = "time_shift_" + old_scale_id + "_to_" + scale_id
        var energy = 20.0
        var dimension = BASE_DIMENSION
        
        word_pattern_visualizer.add_word_pattern(pattern_text, energy, dimension)
    }
    
    # Transfer data through time tunnel if available
    if ethereal_tunnel_manager and tunnel_controller:
        var tunnel_key = _find_tunnel_between_scales(old_scale_id, scale_id)
        
        if tunnel_key and time_tunnels.has(tunnel_key):
            var tunnel_id = time_tunnels[tunnel_key]
            
            var shift_info = {
                "type": "time_scale_shift",
                "from_scale": old_scale_id,
                "to_scale": scale_id,
                "timestamp": current_time
            }
            
            tunnel_controller.transfer_through_tunnel(tunnel_id, JSON.stringify(shift_info))
        }
    }
    
    # Emit signal
    emit_signal("time_scale_changed", target_scale, current_time)
    emit_signal("dimensional_shift_occurred", old_scale_id, scale_id, current_time)
    
    return true

func _process_scale_transition(delta):
    if not scale_transition_active:
        return
    
    # Update transition progress
    scale_transition_progress += delta / scale_transition_duration
    
    if scale_transition_progress >= 1.0:
        # Transition complete
        current_scale = target_scale
        scale_transition_active = false
    } else {
        // Smoothly interpolate scale
        var t = _smooth_step(scale_transition_progress)
        current_scale = lerp(current_scale, target_scale, t)
    }

func _smooth_step(t):
    // Cubic smooth step function
    return t * t * (3.0 - 2.0 * t)

func create_timeline_branch(branch_id = "", parent_id = ""):
    if branch_id.empty():
        // Generate unique branch ID
        branch_id = "branch_" + str(randi() % 10000) + "_" + str(current_time)
    }
    
    if parent_id.empty():
        parent_id = current_branch_id
    }
    
    return _create_timeline_branch(branch_id, parent_id, current_time)

func _create_timeline_branch(branch_id, parent_id, branch_origin_time):
    // Check if branch already exists
    if active_branches.has(branch_id):
        print("Branch already exists: " + branch_id)
        return false
    }
    
    // Create branch
    var branch = {
        "id": branch_id,
        "parent_id": parent_id,
        "origin_time": branch_origin_time,
        "current_time": branch_origin_time,
        "events": [],
        "merges": [],
        "divergence_factor": 0.0
    }
    
    // If this has a parent branch, copy its events up to the branch point
    if parent_id != "" and active_branches.has(parent_id):
        var parent_branch = active_branches[parent_id]
        
        for event in parent_branch.events:
            if event.timestamp <= branch_origin_time:
                branch.events.push_back(event.duplicate())
            }
        }
    }
    
    // Store branch
    active_branches[branch_id] = branch
    
    // Create anchor in ethereal space
    if ethereal_tunnel_manager:
        var anchor_id = "timeline_" + branch_id
        
        // Create at dimension 2 (time)
        var position = Vector3(branch.divergence_factor, BASE_DIMENSION, 0)
        
        if not ethereal_tunnel_manager.has_anchor(anchor_id):
            ethereal_tunnel_manager.register_anchor(anchor_id, position, "timeline")
            
            // Create tunnel to parent if it exists
            if parent_id != "" and active_branches.has(parent_id):
                var parent_anchor_id = "timeline_" + parent_id
                
                if ethereal_tunnel_manager.has_anchor(parent_anchor_id):
                    var tunnel_id = parent_anchor_id + "_to_" + anchor_id
                    
                    if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
                        ethereal_tunnel_manager.establish_tunnel(parent_anchor_id, anchor_id, BASE_DIMENSION)
                    }
                }
            }
        }
    }
    
    // Create word pattern for branch
    if word_pattern_visualizer:
        var pattern_text = "timeline_" + branch_id
        var energy = 25.0
        var dimension = BASE_DIMENSION
        
        word_pattern_visualizer.add_word_pattern(pattern_text, energy, dimension)
    }
    
    // Create numeric token
    if numeric_token_system:
        var token_value = int(branch_origin_time % 10000)
        numeric_token_system.create_token(token_value, "TIME", "timeline_branch")
    }
    
    // Record in Akashic records
    if akashic_record_connector:
        var branch_data = {
            "branch_id": branch_id,
            "parent_id": parent_id,
            "origin_time": branch_origin_time,
            "timestamp": current_time
        }
        
        akashic_record_connector.record_dimensional_data(BASE_DIMENSION, branch_data, "timeline_branch")
    }
    
    // Emit signal
    emit_signal("timeline_branch_created", branch_id, parent_id, branch_origin_time)
    
    return true

func switch_timeline_branch(branch_id):
    if not active_branches.has(branch_id):
        print("Timeline branch not found: " + branch_id)
        return false
    }
    
    // Store current branch state
    if active_branches.has(current_branch_id):
        active_branches[current_branch_id].current_time = current_time
    }
    
    // Switch branch
    var old_branch_id = current_branch_id
    current_branch_id = branch_id
    
    // Update time from branch
    var branch = active_branches[branch_id]
    current_time = branch.current_time
    
    // Record time echo
    create_temporal_echo(current_time, old_branch_id, branch_id)
    
    // Create word pattern for branch switch
    if word_pattern_visualizer:
        var pattern_text = "timeline_switch_" + old_branch_id + "_to_" + branch_id
        var energy = 15.0
        var dimension = BASE_DIMENSION
        
        word_pattern_visualizer.add_word_pattern(pattern_text, energy, dimension)
    }
    
    return true

func merge_timeline_branches(source_branch_id, target_branch_id = ""):
    if not active_branches.has(source_branch_id):
        print("Source branch not found: " + source_branch_id)
        return false
    }
    
    if target_branch_id.empty():
        target_branch_id = current_branch_id
    } else if not active_branches.has(target_branch_id):
        print("Target branch not found: " + target_branch_id)
        return false
    }
    
    var source_branch = active_branches[source_branch_id]
    var target_branch = active_branches[target_branch_id]
    
    // Merge events
    var new_events = []
    for event in source_branch.events:
        // Only add events that occurred after the source branch origin
        if event.timestamp > source_branch.origin_time:
            // Check if event already exists in target
            var event_exists = false
            for target_event in target_branch.events:
                if target_event.id == event.id:
                    event_exists = true
                    break
                }
            }
            
            if not event_exists:
                new_events.push_back(event.duplicate())
            }
        }
    }
    
    // Add new events to target branch
    for event in new_events:
        target_branch.events.push_back(event)
    }
    
    // Sort events by timestamp
    target_branch.events.sort_custom(Callable(self, "_sort_events_by_time"))
    
    // Add merge record
    var merge_data = {
        "source_branch": source_branch_id,
        "target_branch": target_branch_id,
        "merge_time": current_time,
        "events_merged": new_events.size()
    }
    
    target_branch.merges.push_back(merge_data)
    
    // Create temporal echo at merge point
    create_temporal_echo(current_time, source_branch_id, target_branch_id, 2.0)
    
    // Record in Akashic records
    if akashic_record_connector:
        akashic_record_connector.record_dimensional_data(BASE_DIMENSION, merge_data, "timeline_merge")
    }
    
    // Create word pattern for merge
    if word_pattern_visualizer:
        var pattern_text = "timeline_merge_" + source_branch_id + "_to_" + target_branch_id
        var energy = 30.0
        var dimension = BASE_DIMENSION
        
        word_pattern_visualizer.add_word_pattern(pattern_text, energy, dimension)
    }
    
    // Create ethereal tunnel merge
    if ethereal_tunnel_manager:
        var source_anchor = "timeline_" + source_branch_id
        var target_anchor = "timeline_" + target_branch_id
        
        if ethereal_tunnel_manager.has_anchor(source_anchor) and ethereal_tunnel_manager.has_anchor(target_anchor):
            var tunnel_id = source_anchor + "_to_" + target_anchor
            
            if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
                ethereal_tunnel_manager.establish_tunnel(source_anchor, target_anchor, BASE_DIMENSION)
            }
        }
    }
    
    // Emit signal
    emit_signal("timeline_branch_merged", source_branch_id, target_branch_id, current_time)
    
    return true

func record_timeline_event(event_data, branch_id = ""):
    if branch_id.empty():
        branch_id = current_branch_id
    }
    
    if not active_branches.has(branch_id):
        print("Branch not found: " + branch_id)
        return false
    }
    
    var branch = active_branches[branch_id]
    
    // Create event record
    var event = {
        "id": "event_" + str(randi() % 100000) + "_" + str(current_time),
        "timestamp": current_time,
        "data": event_data
    }
    
    // Add to branch events
    branch.events.push_back(event)
    
    // Sort events
    branch.events.sort_custom(Callable(self, "_sort_events_by_time"))
    
    // Create memory imprint
    create_temporal_imprint(event.id, event_data)
    
    return event.id

func _sort_events_by_time(a, b):
    return a.timestamp < b.timestamp

func get_timeline_events(branch_id = "", start_time = 0, end_time = 0):
    if branch_id.empty():
        branch_id = current_branch_id
    }
    
    if not active_branches.has(branch_id):
        print("Branch not found: " + branch_id)
        return []
    }
    
    var branch = active_branches[branch_id]
    var events = []
    
    if start_time == 0 and end_time == 0:
        // Return all events
        return branch.events
    } else if end_time == 0:
        // Return events after start_time
        for event in branch.events:
            if event.timestamp >= start_time:
                events.push_back(event)
            }
        }
    } else {
        // Return events between start_time and end_time
        for event in branch.events:
            if event.timestamp >= start_time and event.timestamp <= end_time:
                events.push_back(event)
            }
        }
    }
    
    return events

func get_branch_info(branch_id = ""):
    if branch_id.empty():
        branch_id = current_branch_id
    }
    
    if not active_branches.has(branch_id):
        print("Branch not found: " + branch_id)
        return null
    }
    
    return active_branches[branch_id]

func create_temporal_echo(echo_time, source_id, target_id, intensity = 1.0):
    // Create a temporal echo at the specified time
    var echo_id = "echo_" + str(randi() % 10000) + "_" + str(current_time)
    
    var echo = {
        "id": echo_id,
        "origin_time": echo_time,
        "creation_time": current_time,
        "source_id": source_id,
        "target_id": target_id,
        "intensity": intensity,
        "duration": 10.0 * intensity,  // Longer echoes for higher intensity
        "remaining_time": 10.0 * intensity
    }
    
    temporal_echoes[echo_id] = echo
    
    // Create word pattern for echo
    if word_pattern_visualizer:
        var pattern_text = "temporal_echo_" + echo_id
        var energy = 10.0 * intensity
        var dimension = BASE_DIMENSION
        
        word_pattern_visualizer.add_word_pattern(pattern_text, energy, dimension)
    }
    
    // Record in Akashic records
    if akashic_record_connector:
        var echo_data = {
            "echo_id": echo_id,
            "origin_time": echo_time,
            "source_id": source_id,
            "target_id": target_id,
            "intensity": intensity
        }
        
        akashic_record_connector.record_dimensional_data(BASE_DIMENSION, echo_data, "temporal_echo")
    }
    
    // Emit signal
    emit_signal("temporal_echo_detected", echo_id, echo_time, current_time, intensity)
    
    return echo_id

func _process_temporal_echoes(delta):
    var echoes_to_remove = []
    
    for echo_id in temporal_echoes:
        var echo = temporal_echoes[echo_id]
        
        echo.remaining_time -= delta
        
        if echo.remaining_time <= 0:
            echoes_to_remove.push_back(echo_id)
            
            // Remove word pattern if it exists
            if word_pattern_visualizer and word_pattern_visualizer.has_method("remove_word_pattern"):
                word_pattern_visualizer.remove_word_pattern("temporal_echo_" + echo_id)
            }
        }
    }
    
    for echo_id in echoes_to_remove:
        temporal_echoes.erase(echo_id)
    }

func create_temporal_imprint(imprint_id, imprint_data):
    var imprint = {
        "id": imprint_id,
        "data": imprint_data,
        "creation_time": current_time,
        "branch_id": current_branch_id,
        "scale_id": current_scale_id
    }
    
    temporal_imprints[imprint_id] = imprint
    time_memory[imprint_id] = imprint_data
    
    return imprint_id

func activate_visualization(parent_node = null):
    if visualization_active:
        return
    
    // Create visualization node
    visualization_node = Node3D.new()
    visualization_node.name = "FractalTimeVisualization"
    
    if parent_node:
        parent_node.add_child(visualization_node)
    } else {
        add_child(visualization_node)
    }
    
    // Initialize visualization
    _initialize_visualization()
    
    visualization_active = true

func deactivate_visualization():
    if not visualization_active:
        return
    
    // Remove visualization node
    if visualization_node:
        visualization_node.queue_free()
        visualization_node = null
    }
    
    visualization_active = false

func _initialize_visualization():
    if not visualization_node:
        return
    
    // Create time scale markers
    for scale_id in FRACTAL_DIMENSIONS:
        var scale_data = FRACTAL_DIMENSIONS[scale_id]
        
        // Create visual marker
        var marker = CSGSphere3D.new()
        marker.radius = 0.2 + (scale_data.scale * 0.05)
        marker.name = "TimeScale_" + scale_id
        
        // Position based on scale
        var log_scale = log(scale_data.scale) / log(10)  // Logarithmic scale for better spacing
        marker.position = Vector3(log_scale * 3.0, 0, 0)
        
        // Set color
        var material = StandardMaterial3D.new()
        material.albedo_color = scale_data.color
        material.emission_enabled = true
        material.emission = scale_data.color
        material.emission_energy = 0.5
        marker.material = material
        
        // Add label
        var label = Label3D.new()
        label.text = scale_id + " (" + str(scale_data.scale) + "x)"
        label.position = Vector3(0, 0.3, 0)
        marker.add_child(label)
        
        visualization_node.add_child(marker)
    }
    
    // Create timeline branches
    for branch_id in active_branches:
        _create_branch_visualization(branch_id)
    }
    
    // Create time axis
    var time_axis = CSGCylinder3D.new()
    time_axis.radius = 0.05
    time_axis.height = 10.0
    time_axis.rotation = Vector3(0, 0, PI/2)  // Rotate to be horizontal
    
    var axis_material = StandardMaterial3D.new()
    axis_material.albedo_color = Color(0.7, 0.7, 0.7, 0.7)
    time_axis.material = axis_material
    
    visualization_node.add_child(time_axis)
    
    // Create current time indicator
    var current_time_marker = CSGSphere3D.new()
    current_time_marker.radius = 0.15
    current_time_marker.name = "CurrentTimeMarker"
    
    var marker_material = StandardMaterial3D.new()
    marker_material.albedo_color = Color(1, 1, 1)
    marker_material.emission_enabled = true
    marker_material.emission = Color(1, 1, 1)
    marker_material.emission_energy = 1.0
    current_time_marker.material = marker_material
    
    visualization_node.add_child(current_time_marker)

func _create_branch_visualization(branch_id):
    if not visualization_node:
        return
    
    var branch = active_branches[branch_id]
    
    // Create branch path
    var branch_path = Path3D.new()
    branch_path.name = "Branch_" + branch_id
    
    var curve = Curve3D.new()
    
    // Start at branch origin
    var start_time = branch.origin_time
    var end_time = branch.current_time
    var duration = end_time - start_time
    
    // Create curve points
    var point_count = 10
    for i in range(point_count + 1):
        var t = float(i) / point_count
        var x = t * 10.0 - 5.0  // -5 to 5
        var y = sin(t * PI * 2) * branch.divergence_factor
        var z = cos(t * PI * 2) * branch.divergence_factor
        
        curve.add_point(Vector3(x, y, z))
    }
    
    branch_path.curve = curve
    
    // Create branch line
    var branch_line = CSGPolygon3D.new()
    branch_line.polygon = _create_branch_profile()
    branch_line.mode = CSGPolygon3D.MODE_PATH
    branch_line.path_node = NodePath(".")
    
    // Set material
    var line_material = StandardMaterial3D.new()
    var color = Color(0.3, 0.7, 1.0) if branch_id == current_branch_id else Color(0.5, 0.5, 0.5)
    line_material.albedo_color = color
    
    if branch_id == current_branch_id:
        line_material.emission_enabled = true
        line_material.emission = color
        line_material.emission_energy = 0.5
    }
    
    branch_line.material = line_material
    
    branch_path.add_child(branch_line)
    visualization_node.add_child(branch_path)
    
    // Create event markers
    for event in branch.events:
        _create_event_visualization(event, branch_path)
    }

func _create_event_visualization(event, branch_path):
    // Position based on time
    var branch = active_branches[current_branch_id]
    var t = inverse_lerp(branch.origin_time, branch.current_time, event.timestamp)
    t = clamp(t, 0.0, 1.0)
    
    var path_length = branch_path.curve.get_baked_length()
    var position = branch_path.curve.sample_baked(t * path_length)
    
    // Create marker
    var event_marker = CSGSphere3D.new()
    event_marker.radius = 0.1
    event_marker.name = "Event_" + event.id
    event_marker.position = position
    
    // Set material
    var marker_material = StandardMaterial3D.new()
    marker_material.albedo_color = Color(1, 0.7, 0.2)
    marker_material.emission_enabled = true
    marker_material.emission = Color(1, 0.7, 0.2)
    marker_material.emission_energy = 0.7
    event_marker.material = marker_material
    
    branch_path.add_child(event_marker)

func _create_branch_profile():
    var segment_count = 8
    var radius = 0.05
    
    var points = []
    for i in range(segment_count):
        var angle = 2 * PI * i / segment_count
        points.push_back(Vector2(cos(angle) * radius, sin(angle) * radius))
    }
    
    return points

func _update_visualization(delta):
    if not visualization_node:
        return
    
    // Update current time marker
    var current_marker = visualization_node.get_node("CurrentTimeMarker")
    if current_marker:
        var branch = active_branches[current_branch_id]
        var branch_path = visualization_node.get_node("Branch_" + current_branch_id)
        
        if branch_path:
            var t = inverse_lerp(branch.origin_time, branch.origin_time + 10.0, current_time)
            t = clamp(t, 0.0, 1.0)
            
            var path_length = branch_path.curve.get_baked_length()
            current_marker.position = branch_path.curve.sample_baked(t * path_length)
        }
    }
    
    // Update time scale indicators
    var scale_marker = visualization_node.get_node("TimeScale_" + current_scale_id)
    if scale_marker:
        scale_marker.scale = Vector3(1.0, 1.0, 1.0) * (1.0 + 0.1 * sin(oscillation_phase))
    }
    
    // Update temporal echoes
    for echo_id in temporal_echoes:
        var echo = temporal_echoes[echo_id]
        var echo_marker = visualization_node.get_node_or_null("Echo_" + echo_id)
        
        if not echo_marker:
            // Create echo visualization
            echo_marker = CSGSphere3D.new()
            echo_marker.name = "Echo_" + echo_id
            echo_marker.radius = 0.2 * echo.intensity
            
            var material = StandardMaterial3D.new()
            material.albedo_color = Color(0.2, 0.9, 0.7, 0.7)
            material.emission_enabled = true
            material.emission = Color(0.2, 0.9, 0.7)
            material.emission_energy = echo.intensity
            material.flags_transparent = true
            echo_marker.material = material
            
            // Position between source and target
            var source_branch = visualization_node.get_node_or_null("Branch_" + echo.source_id)
            var target_branch = visualization_node.get_node_or_null("Branch_" + echo.target_id)
            
            if source_branch and target_branch:
                var mid_point = (source_branch.position + target_branch.position) / 2.0
                echo_marker.position = mid_point
            } else {
                echo_marker.position = Vector3(0, 1, 0)
            }
            
            visualization_node.add_child(echo_marker)
        } else {
            // Update existing marker
            var t = echo.remaining_time / (10.0 * echo.intensity)
            var mat = echo_marker.material
            mat.albedo_color.a = t * 0.7
            mat.emission_energy = t * echo.intensity
            
            // Pulsate effect
            echo_marker.scale = Vector3(1, 1, 1) * (1.0 + 0.2 * sin(oscillation_phase * 2.0))
        }
    }

func set_fractal_dimension(scale_id, value):
    if not FRACTAL_DIMENSIONS.has(scale_id):
        return false
    }
    
    var data = FRACTAL_DIMENSIONS[scale_id]
    data.scale = value
    
    // Update oscillation rate based on scale
    data.oscillation_rate = 1.0 / value
    
    // Update current scale if active
    if current_scale_id == scale_id:
        target_scale = value
        
        if not scale_transition_active:
            scale_transition_active = true
            scale_transition_progress = 0.0
        }
    }
    
    return true

func get_current_time_info():
    var time_info = {
        "current_time": current_time,
        "elapsed_time": elapsed_time,
        "origin_time": origin_time,
        "current_scale": current_scale,
        "current_scale_id": current_scale_id,
        "oscillation_phase": oscillation_phase,
        "current_branch": current_branch_id
    }
    
    return time_info

func get_active_branches():
    return active_branches.keys()

func get_fractral_scales():
    return FRACTAL_DIMENSIONS.keys()

func time_to_string(timestamp):
    var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
    return "%04d-%02d-%02d %02d:%02d:%02d" % [
        datetime.year,
        datetime.month,
        datetime.day,
        datetime.hour,
        datetime.minute,
        datetime.second
    ]