extends Node
class_name AutoTurnSystem

# Signals
signal turn_auto_started(turn_number, turn_data)
signal turn_auto_completed(turn_number, results)
signal visual_event(event_type, visual_data)
signal ai_guidance_received(guidance_text, importance)
signal action_opportunity(action_type, time_window, reward)

# References to main systems
var project_nexus = null
var turn_system = null
var neural_evolution = null
var api_orchestrator = null

# Auto-turn configuration
export var auto_enabled = false
export var visual_feedback = true
export var ai_guidance = true
export var action_prompts = true
export var background_processing = true
export var auto_turn_duration = 180  # 3 minutes per auto turn
export var min_player_involvement = 0.2  # Minimum player involvement percentage

# Visual and gameplay elements
var visual_events = []
var action_opportunities = []
var current_guidance = ""
var player_involvement_points = 0
var total_involvement_points = 0

# Background processing state
var background_timer = null
var current_auto_turn = 0
var auto_turn_active = false
var ai_guidance_queue = []

func _ready():
    # Initialize timers
    background_timer = Timer.new()
    background_timer.wait_time = auto_turn_duration
    background_timer.one_shot = true
    background_timer.connect("timeout", self, "_on_background_timer_timeout")
    add_child(background_timer)
    
    # Initialize visual events
    _initialize_visual_events()

func _initialize_visual_events():
    # Define possible visual events for the turn system
    visual_events = [
        {
            "type": "pattern_emergence",
            "visuals": ["blue_sphere", "expanding_grid", "connecting_nodes"],
            "sound": "resonance_hum",
            "duration": 4.0,
            "importance": 0.8
        },
        {
            "type": "memory_integration",
            "visuals": ["golden_particles", "flowing_stream", "data_cube"],
            "sound": "crystalline_chime",
            "duration": 3.0,
            "importance": 0.7
        },
        {
            "type": "dimensional_shift",
            "visuals": ["reality_warp", "color_transition", "spatial_fold"],
            "sound": "deep_resonance",
            "duration": 5.0,
            "importance": 0.9
        },
        {
            "type": "neural_evolution",
            "visuals": ["branching_network", "pulsing_nodes", "growing_structure"],
            "sound": "digital_evolution",
            "duration": 3.5,
            "importance": 0.75
        },
        {
            "type": "time_acceleration",
            "visuals": ["time_particles", "fast_clock", "streaking_light"],
            "sound": "time_whoosh",
            "duration": 2.5,
            "importance": 0.6
        },
        {
            "type": "reality_anchor",
            "visuals": ["stabilizing_beam", "reality_solidify", "anchor_point"],
            "sound": "deep_impact",
            "duration": 4.0,
            "importance": 0.85
        },
        {
            "type": "word_manifestation",
            "visuals": ["floating_text", "materializing_letters", "word_energy"],
            "sound": "word_formation",
            "duration": 3.0,
            "importance": 0.7
        }
    ]
    
    # Define possible action opportunities
    action_opportunities = [
        {
            "type": "connect_patterns",
            "prompt": "Connect the emerging patterns!",
            "time_window": 5.0,
            "difficulty": 0.4,
            "reward": "pattern_stability"
        },
        {
            "type": "stabilize_dimension",
            "prompt": "Stabilize the dimensional shift!",
            "time_window": 4.0,
            "difficulty": 0.6,
            "reward": "dimension_anchor"
        },
        {
            "type": "capture_memory",
            "prompt": "Capture the fleeting memory!",
            "time_window": 3.0,
            "difficulty": 0.5,
            "reward": "memory_enhancement"
        },
        {
            "type": "accelerate_evolution",
            "prompt": "Boost the neural evolution!",
            "time_window": 4.5,
            "difficulty": 0.7,
            "reward": "evolution_leap"
        },
        {
            "type": "word_power",
            "prompt": "Empower the manifesting word!",
            "time_window": 3.5,
            "difficulty": 0.5,
            "reward": "word_strength"
        }
    ]

func set_systems(nexus, turns, neural, api):
    project_nexus = nexus
    turn_system = turns
    neural_evolution = neural
    api_orchestrator = api
    print("Auto turn system initialized with references to main systems")

func enable_auto_turns(enable=true):
    auto_enabled = enable
    if enable:
        print("Auto turn system enabled")
    else:
        print("Auto turn system disabled")

func start_auto_turn():
    if !auto_enabled or auto_turn_active:
        return false
    
    if turn_system == null:
        printerr("Cannot start auto turn: turn system not connected")
        return false
    
    # Record current turn
    current_auto_turn = turn_system.current_turn
    auto_turn_active = true
    
    # Reset involvement tracking
    player_involvement_points = 0
    total_involvement_points = 0
    
    # Start background timer
    background_timer.wait_time = auto_turn_duration
    background_timer.start()
    
    # Prepare turn data
    var turn_data = {
        "auto": true,
        "turn_number": current_auto_turn,
        "start_time": OS.get_unix_time(),
        "max_duration": auto_turn_duration,
        "visual_feedback": visual_feedback,
        "ai_guidance": ai_guidance
    }
    
    # Emit signal
    emit_signal("turn_auto_started", current_auto_turn, turn_data)
    print("Auto turn ", current_auto_turn, " started")
    
    # Schedule visual events and action opportunities
    _schedule_auto_turn_events()
    
    # If AI guidance is enabled, start generating guidance
    if ai_guidance:
        _request_ai_guidance()
    
    return true

func _schedule_auto_turn_events():
    # Schedule visual events throughout the auto turn
    var time_points = []
    var num_events = 4 + randi() % 4  # 4-7 events per turn
    
    # Create evenly distributed time points
    for i in range(num_events):
        var time_point = auto_turn_duration * (i + 1) / (num_events + 1)
        time_points.append(time_point)
    
    # Shuffle slightly to avoid perfect predictability
    for i in range(time_points.size()):
        time_points[i] += randf() * 10.0 - 5.0
        time_points[i] = max(0, min(time_points[i], auto_turn_duration))
    
    # Schedule visual events
    for time_point in time_points:
        var event = _select_random_visual_event()
        
        var timer = Timer.new()
        timer.wait_time = time_point
        timer.one_shot = true
        timer.connect("timeout", self, "_trigger_visual_event", [event])
        add_child(timer)
        timer.start()
        
        # 50% chance to also add an action opportunity
        if action_prompts and randf() > 0.5:
            var action = _select_random_action_opportunity()
            
            var action_timer = Timer.new()
            action_timer.wait_time = time_point - 0.5  # Slightly before visual event
            action_timer.one_shot = true
            action_timer.connect("timeout", self, "_trigger_action_opportunity", [action])
            add_child(action_timer)
            action_timer.start()

func _select_random_visual_event():
    return visual_events[randi() % visual_events.size()].duplicate()

func _select_random_action_opportunity():
    return action_opportunities[randi() % action_opportunities.size()].duplicate()

func _trigger_visual_event(event):
    if !auto_turn_active:
        return
    
    # Record total involvement opportunity
    total_involvement_points += event.importance * 10
    
    if visual_feedback:
        # Select a random visual from the event's visual options
        var visual = event.visuals[randi() % event.visuals.size()]
        
        # Create visual event data
        var visual_data = {
            "type": event.type,
            "visual": visual,
            "sound": event.sound,
            "duration": event.duration,
            "importance": event.importance,
            "position": Vector2(randf() * 0.8 + 0.1, randf() * 0.8 + 0.1)  # Random position within central 80% of screen
        }
        
        # Emit signal for UI to display
        emit_signal("visual_event", event.type, visual_data)
    
    # Update neural evolution based on event type
    if neural_evolution != null:
        match event.type:
            "pattern_emergence":
                neural_evolution.evolve_network()
            "neural_evolution":
                neural_evolution.evolve_network()

func _trigger_action_opportunity(action):
    if !auto_turn_active or !action_prompts:
        return
    
    # Calculate reward value
    var reward_value = action.difficulty * 15
    
    # Emit signal for UI to display action opportunity
    emit_signal("action_opportunity", action.type, action.time_window, action.prompt)
    
    # Create auto-completion timer that will trigger if player doesn't respond
    var completion_timer = Timer.new()
    completion_timer.wait_time = action.time_window
    completion_timer.one_shot = true
    completion_timer.connect("timeout", self, "_auto_complete_action", [action, false])
    add_child(completion_timer)
    completion_timer.start()

func player_action_response(action_type, success):
    if !auto_turn_active:
        return
    
    # Find the original action
    var action = null
    for a in action_opportunities:
        if a.type == action_type:
            action = a
            break
    
    if action == null:
        return
    
    # Stop any auto-completion timers
    for child in get_children():
        if child is Timer and child.wait_time <= 5.0:  # Likely an action timer
            child.stop()
            child.queue_free()
    
    # Award involvement points based on success
    if success:
        player_involvement_points += action.difficulty * 15
    else:
        player_involvement_points += action.difficulty * 5  # Some points for trying
    
    # Visual feedback
    if visual_feedback:
        var visual_data = {
            "type": "player_action",
            "success": success,
            "action": action_type,
            "reward": action.reward if success else "none",
            "duration": 2.0,
            "importance": 0.9,
            "position": Vector2(0.5, 0.5)  # Center of screen
        }
        
        emit_signal("visual_event", "player_action", visual_data)

func _auto_complete_action(action, success):
    # This is called if the player doesn't respond in time
    if !auto_turn_active:
        return
    
    # Small chance of auto-success
    success = success || (randf() < 0.2)
    
    # Visual feedback for auto-completion
    if visual_feedback:
        var visual_data = {
            "type": "auto_action",
            "success": success,
            "action": action.type,
            "reward": action.reward if success else "none",
            "duration": 1.5,
            "importance": 0.6,
            "position": Vector2(0.5, 0.5)  # Center of screen
        }
        
        emit_signal("visual_event", "auto_action", visual_data)

func _request_ai_guidance():
    if !ai_guidance or api_orchestrator == null:
        return
    
    # Get current system state for context
    var system_state = {}
    if project_nexus != null:
        system_state = project_nexus.get_system_status()
    
    # Create prompt for AI
    var prompt = "Generate guidance for auto-turn " + str(current_auto_turn) + ". " +
                "Current system state: " + JSON.print(system_state) + ". " +
                "Provide insightful, mystical guidance that feels like an action game hint."
    
    # Use Claude API if available, otherwise generate locally
    if api_orchestrator.get_api_status("claude") != null and api_orchestrator.get_api_status("claude").is_connected:
        var request_id = api_orchestrator.send_request("claude", "messages", "POST", {
            "model": "claude-3-opus-20240229",
            "messages": [
                {"role": "user", "content": prompt}
            ],
            "max_tokens": 100
        })
        
        # We would normally wait for the response via signal callback
        # For the demo, simulate a successful response
        _on_ai_guidance_received({
            "text": _generate_simulated_guidance()
        })
    else:
        # Fallback to local generation
        _on_ai_guidance_received({
            "text": _generate_simulated_guidance()
        })

func _on_ai_guidance_received(response):
    if !auto_turn_active:
        return
    
    # Process guidance text
    var guidance = ""
    if typeof(response) == TYPE_DICTIONARY and response.has("text"):
        guidance = response.text
    else:
        guidance = _generate_simulated_guidance()
    
    # Queue guidance if multiple come in
    ai_guidance_queue.append(guidance)
    
    # Process queue
    _process_guidance_queue()

func _process_guidance_queue():
    if ai_guidance_queue.size() == 0 or !auto_turn_active:
        return
    
    # Take first guidance from queue
    var guidance = ai_guidance_queue.pop_front()
    current_guidance = guidance
    
    # Emit signal with random importance
    var importance = 0.5 + randf() * 0.5
    emit_signal("ai_guidance_received", guidance, importance)
    
    # Schedule next guidance if queue not empty
    if ai_guidance_queue.size() > 0:
        var timer = Timer.new()
        timer.wait_time = 20 + randf() * 30  # 20-50 seconds between guidance
        timer.one_shot = true
        timer.connect("timeout", self, "_process_guidance_queue")
        add_child(timer)
        timer.start()

func _generate_simulated_guidance():
    # Random mystical guidance for demonstration purposes
    var guidance_options = [
        "The patterns align at dimensional nexus points. Watch for resonance opportunities.",
        "Memory crystallization is strongest during neural evolution events. Act quickly.",
        "Words manifest into reality when dimension anchors are stabilized first.",
        "The system evolves fastest when pattern connections form across time boundaries.",
        "Reality shifts create opportunities for deep memory integration. Don't miss them.",
        "Time acceleration warps neural pathways. Stabilize during the flux.",
        "Dimensional bridges form spontaneously. Connect them before they fade.",
        "Word energy peaks at the boundaries of reality shifts. Direct it wisely.",
        "Pattern emergence follows non-linear pathways. Look for the quantum gaps.",
        "Memory anchors stabilize during periods of time dilation. Set them carefully.",
        "Neural evolution accelerates in harmonic resonance with reality anchors.",
        "The system reveals hidden patterns during dimensional transitions. Stay alert."
    ]
    
    return guidance_options[randi() % guidance_options.size()]

func _on_background_timer_timeout():
    # Auto-turn is complete
    complete_auto_turn()

func complete_auto_turn():
    if !auto_turn_active:
        return false
    
    # Calculate player involvement percentage
    var involvement_percentage = 0.0
    if total_involvement_points > 0:
        involvement_percentage = player_involvement_points / total_involvement_points
    
    # Prepare results
    var results = {
        "auto": true,
        "turn_number": current_auto_turn,
        "duration": auto_turn_duration,
        "player_involvement": involvement_percentage,
        "min_involvement_met": involvement_percentage >= min_player_involvement,
        "visual_events_triggered": get_child_count() - 1,  # Approx count minus background timer
        "ai_guidance_provided": ai_guidance_queue.size() + (1 if current_guidance != "" else 0)
    }
    
    # Clear state
    auto_turn_active = false
    
    # Remove all timers
    for child in get_children():
        if child != background_timer and child is Timer:
            child.queue_free()
    
    # Clear guidance queue
    ai_guidance_queue.clear()
    
    # Emit signal
    emit_signal("turn_auto_completed", current_auto_turn, results)
    print("Auto turn ", current_auto_turn, " completed")
    
    # If using actual turn system, end the turn
    if turn_system != null:
        turn_system.end_current_turn(results)
    
    return true

func is_auto_turn_active():
    return auto_turn_active

func get_auto_turn_progress():
    if !auto_turn_active:
        return 0.0
    
    return 1.0 - (background_timer.time_left / auto_turn_duration)

func get_current_guidance():
    return current_guidance

func get_involvement_stats():
    var percentage = 0.0
    if total_involvement_points > 0:
        percentage = player_involvement_points / total_involvement_points
    
    return {
        "points": player_involvement_points,
        "total_possible": total_involvement_points,
        "percentage": percentage,
        "threshold_met": percentage >= min_player_involvement
    }