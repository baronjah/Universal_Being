# 🏛️ Blink Animation Controller - System controller for Pentagon architecture
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: System controller for Pentagon architecture
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
class_name BlinkAnimationController

# ----- ANIMATION SETTINGS -----
@export_category("Blink Settings")
@export var enabled: bool = true
@export var blink_interval_min: float = 0.5  # Minimum time between blinks in seconds
@export var blink_interval_max: float = 3.0  # Maximum time between blinks in seconds
@export var blink_duration: float = 0.15     # Duration of a single blink in seconds
@export var double_blink_chance: float = 0.3 # Chance of a double blink (0-1)
@export var triple_blink_chance: float = 0.1 # Chance of a triple blink (0-1)

# ----- WINK SETTINGS -----
@export_category("Wink Settings")
@export var wink_enabled: bool = true
@export var wink_interval_min: float = 5.0   # Minimum time between winks
@export var wink_interval_max: float = 15.0  # Maximum time between winks
@export var wink_duration: float = 0.3       # Duration of a wink
@export var left_wink_chance: float = 0.5    # Chance of winking with left eye (vs right)

# ----- FLICKER SETTINGS -----
@export_category("Flicker Settings")
@export var flicker_enabled: bool = true
@export var flicker_interval_min: float = 10.0  # Minimum time between flickers
@export var flicker_interval_max: float = 30.0  # Maximum time between flickers
@export var flicker_duration: float = 0.05      # Duration of a single flicker
@export var flicker_count_min: int = 2          # Minimum flickers in sequence
@export var flicker_count_max: int = 6          # Maximum flickers in sequence
@export var flicker_intensity: float = 0.7      # Intensity of the flicker (0-1)

# ----- TURN INTEGRATION -----
@export_category("Turn Integration")
@export var increase_frequency_per_turn: bool = true
@export var turn_frequency_multiplier: float = 0.9  # Reduces intervals by 10% per turn
@export var max_frequency_multiplier: float = 0.3   # Max reduction is 70% of original

# ----- STATE VARIABLES -----
var blink_timer: Timer
var wink_timer: Timer
var flicker_timer: Timer
var is_blinking: bool = false
var is_winking: bool = false
var is_flickering: bool = false
var current_turn: int = 1
var turn_controller = null
var registered_nodes = {}  # Dictionary of nodes that receive blink animations
var animation_player: AnimationPlayer

# ----- SIGNALS -----
signal blink_started(node_name, blink_count)
signal blink_ended(node_name)
signal wink_started(node_name, is_left)
signal wink_ended(node_name)
signal flicker_started(node_name, flicker_count)
signal flicker_ended(node_name)

# ----- INITIALIZATION -----
func _ready():
    # Initialize timers
    _initialize_timers()
    
    # Find turn controller
    turn_controller = get_node_or_null("/root/TurnController")
    if not turn_controller:
        turn_controller = _find_node_by_class(get_tree().root, "TurnController")
    
    # Set up animation player
    animation_player = AnimationPlayer.new()
    add_child(animation_player)
    _create_default_animations()
    
    # Connect to turn controller if available
    if turn_controller:
        turn_controller.connect("turn_started", Callable(self, "_on_turn_started"))
        turn_controller.register_system(self)
        current_turn = turn_controller.get_current_turn()
    
    # Start timers if enabled
    if enabled:
        _schedule_next_blink()
    
    if wink_enabled:
        _schedule_next_wink()
    
    if flicker_enabled:
        _schedule_next_flicker()
    
    print("Blink Animation Controller initialized")
    print("Blink interval: " + str(blink_interval_min) + "-" + str(blink_interval_max) + "s")

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _initialize_timers():
    # Blink timer
    blink_timer = TimerManager.get_timer()
    blink_timer.one_shot = true
    blink_timer.connect("timeout", Callable(self, "_on_blink_timer_timeout"))
    add_child(blink_timer)
    
    # Wink timer
    wink_timer = TimerManager.get_timer()
    wink_timer.one_shot = true
    wink_timer.connect("timeout", Callable(self, "_on_wink_timer_timeout"))
    add_child(wink_timer)
    
    # Flicker timer
    flicker_timer = TimerManager.get_timer()
    flicker_timer.one_shot = true
    flicker_timer.connect("timeout", Callable(self, "_on_flicker_timer_timeout"))
    add_child(flicker_timer)

func _create_default_animations():
    # Create a library for animations
    var library = AnimationLibrary.new()
    
    # Blink animation
    var blink_anim = Animation.new()
    var track_idx = blink_anim.add_track(Animation.TYPE_VALUE)
    blink_anim.track_set_path(track_idx, ":opacity")
    blink_anim.track_insert_key(track_idx, 0.0, 1.0)
    blink_anim.track_insert_key(track_idx, blink_duration / 2, 0.0)
    blink_anim.track_insert_key(track_idx, blink_duration, 1.0)
    library.add_animation("blink", blink_anim)
    
    # Left wink animation
    var left_wink_anim = Animation.new()
    track_idx = left_wink_anim.add_track(Animation.TYPE_VALUE)
    left_wink_anim.track_set_path(track_idx, ":left_eye_opacity")
    left_wink_anim.track_insert_key(track_idx, 0.0, 1.0)
    left_wink_anim.track_insert_key(track_idx, wink_duration / 2, 0.0)
    left_wink_anim.track_insert_key(track_idx, wink_duration, 1.0)
    library.add_animation("left_wink", left_wink_anim)
    
    # Right wink animation
    var right_wink_anim = Animation.new()
    track_idx = right_wink_anim.add_track(Animation.TYPE_VALUE)
    right_wink_anim.track_set_path(track_idx, ":right_eye_opacity")
    right_wink_anim.track_insert_key(track_idx, 0.0, 1.0)
    right_wink_anim.track_insert_key(track_idx, wink_duration / 2, 0.0)
    right_wink_anim.track_insert_key(track_idx, wink_duration, 1.0)
    library.add_animation("right_wink", right_wink_anim)
    
    # Flicker animation
    var flicker_anim = Animation.new()
    track_idx = flicker_anim.add_track(Animation.TYPE_VALUE)
    flicker_anim.track_set_path(track_idx, ":opacity")
    flicker_anim.track_insert_key(track_idx, 0.0, 1.0)
    flicker_anim.track_insert_key(track_idx, flicker_duration / 2, flicker_intensity)
    flicker_anim.track_insert_key(track_idx, flicker_duration, 1.0)
    library.add_animation("flicker", flicker_anim)
    
    # Add library to animation player
    animation_player.add_animation_library("blinks", library)

# ----- ANIMATION SCHEDULING -----
func _schedule_next_blink():
    if not enabled:
        return
    
    # Calculate interval based on turn if applicable
    var min_interval = blink_interval_min
    var max_interval = blink_interval_max
    
    if increase_frequency_per_turn and turn_controller:
        var multiplier = max(max_frequency_multiplier, 
                            pow(turn_frequency_multiplier, current_turn - 1))
        min_interval *= multiplier
        max_interval *= multiplier
    
    # Random time until next blink
    var interval = min_interval + randf() * (max_interval - min_interval)
    blink_timer.wait_time = interval
    blink_timer.start()
    
    if OS.is_debug_build():
        print("Next blink in " + str(interval) + "s")

func _schedule_next_wink():
    if not wink_enabled:
        return
    
    # Calculate interval based on turn if applicable
    var min_interval = wink_interval_min
    var max_interval = wink_interval_max
    
    if increase_frequency_per_turn and turn_controller:
        var multiplier = max(max_frequency_multiplier, 
                            pow(turn_frequency_multiplier, current_turn - 1))
        min_interval *= multiplier
        max_interval *= multiplier
    
    # Random time until next wink
    var interval = min_interval + randf() * (max_interval - min_interval)
    wink_timer.wait_time = interval
    wink_timer.start()
    
    if OS.is_debug_build():
        print("Next wink in " + str(interval) + "s")

func _schedule_next_flicker():
    if not flicker_enabled:
        return
    
    # Calculate interval based on turn if applicable
    var min_interval = flicker_interval_min
    var max_interval = flicker_interval_max
    
    if increase_frequency_per_turn and turn_controller:
        var multiplier = max(max_frequency_multiplier, 
                            pow(turn_frequency_multiplier, current_turn - 1))
        min_interval *= multiplier
        max_interval *= multiplier
    
    # Random time until next flicker
    var interval = min_interval + randf() * (max_interval - min_interval)
    flicker_timer.wait_time = interval
    flicker_timer.start()
    
    if OS.is_debug_build():
        print("Next flicker in " + str(interval) + "s")

# ----- ANIMATION EXECUTION -----
func _execute_blink():
    is_blinking = true
    
    # Determine blink count (single, double, or triple)
    var blink_count = 1
    var rand_val = randf()
    
    if rand_val < triple_blink_chance:
        blink_count = 3
    elif rand_val < triple_blink_chance + double_blink_chance:
        blink_count = 2
    
    if OS.is_debug_build():
        print("Executing " + str(blink_count) + "x blink")
    
    # Apply to all registered nodes
    for node_name in registered_nodes:
        _blink_node(node_name, blink_count)
    
    # Schedule next blink after this one completes
    var total_duration = blink_duration * blink_count * 1.5  # Add some gap between multiple blinks
    await get_tree().create_timer(total_duration).timeout
    
    is_blinking = false
    _schedule_next_blink()

func _execute_wink():
    is_winking = true
    
    # Determine which eye to wink
    var is_left_wink = randf() < left_wink_chance
    
    if OS.is_debug_build():
        print("Executing wink (" + ("left" if is_left_wink else "right") + " eye)")
    
    # Apply to all registered nodes
    for node_name in registered_nodes:
        _wink_node(node_name, is_left_wink)
    
    # Schedule next wink after this one completes
    await get_tree().create_timer(wink_duration * 1.2).timeout
    
    is_winking = false
    _schedule_next_wink()

func _execute_flicker():
    is_flickering = true
    
    # Determine flicker count
    var flicker_count = flicker_count_min + randi() % (flicker_count_max - flicker_count_min + 1)
    
    if OS.is_debug_build():
        print("Executing " + str(flicker_count) + "x flicker")
    
    # Apply to all registered nodes
    for node_name in registered_nodes:
        _flicker_node(node_name, flicker_count)
    
    # Schedule next flicker after this one completes
    var total_duration = flicker_duration * flicker_count * 2  # Account for gaps
    await get_tree().create_timer(total_duration).timeout
    
    is_flickering = false
    _schedule_next_flicker()

func _blink_node(node_name: String, blink_count: int):
    if not registered_nodes.has(node_name):
        return
    
    var node = registered_nodes[node_name]
    if not is_instance_valid(node):
        registered_nodes.erase(node_name)
        return
    
    emit_signal("blink_started", node_name, blink_count)
    
    # Check if node has custom blink method
    if node.has_method("apply_blink"):
        node.apply_blink(blink_count, blink_duration)
    else:
        # Apply default animation
        for i in range(blink_count):
            # Use property animation or shader parameter if available
            if node.has_method("set_shader_parameter") and node.material.has_parameter("opacity"):
                var tween = create_tween()
                tween.tween_property(node.material, "shader_parameter/opacity", 0.0, blink_duration / 2)
                tween.tween_property(node.material, "shader_parameter/opacity", 1.0, blink_duration / 2)
                await tween.finished
                
                # Add small gap between multiple blinks
                if i < blink_count - 1:
                    await get_tree().create_timer(blink_duration * 0.5).timeout
            elif node.has_property("modulate"):
                var original_color = node.modulate
                var tween = create_tween()
                tween.tween_property(node, "modulate:a", 0.0, blink_duration / 2)
                tween.tween_property(node, "modulate:a", original_color.a, blink_duration / 2)
                await tween.finished
                
                # Add small gap between multiple blinks
                if i < blink_count - 1:
                    await get_tree().create_timer(blink_duration * 0.5).timeout
    
    emit_signal("blink_ended", node_name)

func _wink_node(node_name: String, is_left: bool):
    if not registered_nodes.has(node_name):
        return
    
    var node = registered_nodes[node_name]
    if not is_instance_valid(node):
        registered_nodes.erase(node_name)
        return
    
    emit_signal("wink_started", node_name, is_left)
    
    # Check if node has custom wink method
    if node.has_method("apply_wink"):
        node.apply_wink(is_left, wink_duration)
    else:
        # Check if node has left/right eye components
        var left_eye = node.get_node_or_null("LeftEye") if node.has_method("get_node") else null
        var right_eye = node.get_node_or_null("RightEye") if node.has_method("get_node") else null
        
        if left_eye and right_eye:
            var eye = left_eye if is_left else right_eye
            var original_color = eye.modulate
            
            var tween = create_tween()
            tween.tween_property(eye, "modulate:a", 0.0, wink_duration / 2)
            tween.tween_property(eye, "modulate:a", original_color.a, wink_duration / 2)
        else:
            # Apply basic wink using shader or property if available
            # This is a simplified version since we can't easily distinguish eyes
            if node.has_method("set_shader_parameter") and node.material.has_parameter("wink"):
                var tween = create_tween()
                tween.tween_property(node.material, "shader_parameter/wink", 1.0, wink_duration / 2)
                tween.tween_property(node.material, "shader_parameter/wink", 0.0, wink_duration / 2)
            else:
                # Just do a half-opacity effect as fallback
                var original_color = node.modulate if node.has_property("modulate") else Color(1,1,1,1)
                
                var tween = create_tween()
                tween.tween_property(node, "modulate:a", original_color.a * 0.5, wink_duration / 2)
                tween.tween_property(node, "modulate:a", original_color.a, wink_duration / 2)
    
    emit_signal("wink_ended", node_name)

func _flicker_node(node_name: String, flicker_count: int):
    if not registered_nodes.has(node_name):
        return
    
    var node = registered_nodes[node_name]
    if not is_instance_valid(node):
        registered_nodes.erase(node_name)
        return
    
    emit_signal("flicker_started", node_name, flicker_count)
    
    # Check if node has custom flicker method
    if node.has_method("apply_flicker"):
        node.apply_flicker(flicker_count, flicker_duration, flicker_intensity)
    else:
        # Apply default flicker animation
        for i in range(flicker_count):
            # Use property animation or shader parameter if available
            if node.has_method("set_shader_parameter") and node.material.has_parameter("opacity"):
                var tween = create_tween()
                tween.tween_property(node.material, "shader_parameter/opacity", flicker_intensity, flicker_duration / 2)
                tween.tween_property(node.material, "shader_parameter/opacity", 1.0, flicker_duration / 2)
                await tween.finished
                
                # Add random gap between flickers
                await get_tree().create_timer(randf() * flicker_duration).timeout
            elif node.has_property("modulate"):
                var original_color = node.modulate
                var tween = create_tween()
                tween.tween_property(node, "modulate:a", original_color.a * flicker_intensity, flicker_duration / 2)
                tween.tween_property(node, "modulate:a", original_color.a, flicker_duration / 2)
                await tween.finished
                
                # Add random gap between flickers
                await get_tree().create_timer(randf() * flicker_duration).timeout
    
    emit_signal("flicker_ended", node_name)

# ----- TIMER CALLBACKS -----
func _on_blink_timer_timeout():
    if not is_blinking and enabled:
        _execute_blink()

func _on_wink_timer_timeout():
    if not is_winking and wink_enabled and not is_blinking:
        _execute_wink()

func _on_flicker_timer_timeout():
    if not is_flickering and flicker_enabled and not is_blinking and not is_winking:
        _execute_flicker()

# ----- TURN SYSTEM INTEGRATION -----
func _on_turn_started(turn_number):
    # Update current turn
    current_turn = turn_number
    
    # Check if we need to adjust timers for new turn
    if increase_frequency_per_turn:
        # Restart timers with new frequency
        blink_timer.stop()
        wink_timer.stop()
        flicker_timer.stop()
        
        _schedule_next_blink()
        _schedule_next_wink()
        _schedule_next_flicker()
        
        print("Adjusted animation frequencies for turn " + str(turn_number))
    
    # Special effect for turn change: triple blink
    if enabled:
        await get_tree().create_timer(0.5).timeout
        for node_name in registered_nodes:
            _blink_node(node_name, 3)

# ----- PUBLIC API -----

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func register_node(node_name: String, node: Node) -> bool:
    # Register a node for blink animations
    if registered_nodes.has(node_name):
        print("Node already registered with name: " + node_name)
        return false
    
    registered_nodes[node_name] = node
    print("Registered node for blink animations: " + node_name)
    
    return true

func unregister_node(node_name: String) -> bool:
    # Unregister a node
    if not registered_nodes.has(node_name):
        print("No node registered with name: " + node_name)
        return false
    
    registered_nodes.erase(node_name)
    print("Unregistered node: " + node_name)
    
    return true

func trigger_blink(node_name: String = "", blink_count: int = 1) -> bool:
    # Trigger a blink on a specific node (or all if empty)
    if node_name.is_empty():
        # Blink all registered nodes
        for node_name_iter in registered_nodes:
            _blink_node(node_name_iter, blink_count)
        return true
    elif registered_nodes.has(node_name):
        _blink_node(node_name, blink_count)
        return true
    else:
        print("No node registered with name: " + node_name)
        return false

func trigger_wink(node_name: String = "", is_left: bool = true) -> bool:
    # Trigger a wink on a specific node (or all if empty)
    if node_name.is_empty():
        # Wink all registered nodes
        for node_name_iter in registered_nodes:
            _wink_node(node_name_iter, is_left)
        return true
    elif registered_nodes.has(node_name):
        _wink_node(node_name, is_left)
        return true
    else:
        print("No node registered with name: " + node_name)
        return false

func trigger_flicker(node_name: String = "", flicker_count: int = 3) -> bool:
    # Trigger a flicker on a specific node (or all if empty)
    if node_name.is_empty():
        # Flicker all registered nodes
        for node_name_iter in registered_nodes:
            _flicker_node(node_name_iter, flicker_count)
        return true
    elif registered_nodes.has(node_name):
        _flicker_node(node_name, flicker_count)
        return true
    else:
        print("No node registered with name: " + node_name)
        return false

func set_enabled(is_enabled: bool) -> void:
    # Enable or disable blink animations
    enabled = is_enabled
    
    if enabled and not blink_timer.is_stopped():
        _schedule_next_blink()
    elif not enabled:
        blink_timer.stop()
    
    print("Blink animations " + ("enabled" if enabled else "disabled"))

func set_wink_enabled(is_enabled: bool) -> void:
    # Enable or disable wink animations
    wink_enabled = is_enabled
    
    if wink_enabled and not wink_timer.is_stopped():
        _schedule_next_wink()
    elif not wink_enabled:
        wink_timer.stop()
    
    print("Wink animations " + ("enabled" if wink_enabled else "disabled"))

func set_flicker_enabled(is_enabled: bool) -> void:
    # Enable or disable flicker animations
    flicker_enabled = is_enabled
    
    if flicker_enabled and not flicker_timer.is_stopped():
        _schedule_next_flicker()
    elif not flicker_enabled:
        flicker_timer.stop()
    
    print("Flicker animations " + ("enabled" if flicker_enabled else "disabled"))

func on_turn_changed(turn_number: int, turn_data: Dictionary) -> void:
    # Required method for turn system integration
    current_turn = turn_number
    
    # Adjust timers for new turn frequency
    if increase_frequency_per_turn:
        blink_timer.stop()
        wink_timer.stop()
        flicker_timer.stop()
        
        _schedule_next_blink()
        _schedule_next_wink()
        _schedule_next_flicker()
    
    # Get any turn-specific flags
    if turn_data.has("flags"):
        var flags = turn_data.flags
        if flags.has("blink_enabled"):
            enabled = flags.blink_enabled
        if flags.has("wink_enabled"):
            wink_enabled = flags.wink_enabled
        if flags.has("flicker_enabled"):
            flicker_enabled = flags.flicker_enabled