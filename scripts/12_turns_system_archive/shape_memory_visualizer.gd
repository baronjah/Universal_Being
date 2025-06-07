extends Node2D

class_name ShapeMemoryVisualizer

# ----- NEURAL VISUALIZATION SETTINGS -----
@export_category("Neural Shape Settings")
@export var enabled: bool = true
@export var max_nodes: int = 88
@export var min_nodes: int = 8
@export var connection_threshold: float = 0.4
@export var memory_density: float = 1.0
@export var update_frequency: float = 0.5
@export var neural_size_multiplier: float = 1.0
@export var lucky_pulse_rate: float = 2.0  # Pulse rate for lucky numbers
@export var number_influence: float = 0.75  # How much numbers influence shape

# ----- SHAPE APPEARANCE -----
@export_category("Shape Appearance")
@export var node_min_size: float = 3.0
@export var node_max_size: float = 12.0
@export var connection_width: float = 1.5
@export var main_color: Color = Color(0.3, 0.7, 0.9, 0.8)
@export var secondary_color: Color = Color(0.9, 0.4, 0.7, 0.6)
@export var lucky_color: Color = Color(1.0, 0.8, 0.2, 0.9)
@export var background_fade: float = 0.2

# ----- INTEGRATION -----
var time_tracker: Node = null
var turn_system: Node = null

# ----- NEURAL NETWORK REPRESENTATION -----
var nodes: Array = []
var connections: Array = []
var active_nodes: Array = []
var memory_points: Array = []
var number_points: Array = []
var lucky_active: bool = false

# ----- ANIMATION -----
var pulse_timer: float = 0.0
var current_pulse: float = 0.0
var pulse_dir: int = 1
var animation_time: float = 0.0
var number_morph_time: float = 0.0

# ----- MEMORY -----
var memory_usage: float = 0.0  # 0-1 range
var current_turn: int = 1
var active_number: int = 0
var lucky_number: int = 1333
var number_sequence: Array = [8, 88, 888, 1333]
var sequence_index: int = 0

# ----- TIMERS -----
var update_timer: Timer
var data_timer: Timer

# ----- INITIALIZATION -----
func _ready():
    _setup_timers()
    _find_systems()
    _initialize_network()
    
    print("Shape Memory Visualizer initialized with " + str(nodes.size()) + " nodes")

func _setup_timers():
    # Update timer for visual updates
    update_timer = Timer.new()
    update_timer.wait_time = update_frequency
    update_timer.one_shot = false
    update_timer.autostart = true
    update_timer.connect("timeout", _on_update_timer_timeout)
    add_child(update_timer)
    
    # Data update timer
    data_timer = Timer.new()
    data_timer.wait_time = 2.0  # Update data every 2 seconds
    data_timer.one_shot = false
    data_timer.autostart = true
    data_timer.connect("timeout", _on_data_timer_timeout)
    add_child(data_timer)

func _find_systems():
    # Find time tracker
    time_tracker = _find_node_by_class(get_tree().root, "UsageTimeTracker")
    if time_tracker:
        print("Found time tracker: " + time_tracker.name)
        
        # Update lucky number from tracker if available
        if "lucky_number" in time_tracker:
            lucky_number = time_tracker.lucky_number
    
    # Find turn system
    var potential_turns = get_tree().get_nodes_in_group("turn_systems")
    if potential_turns.size() > 0:
        turn_system = potential_turns[0]
        print("Found turn system: " + turn_system.name)
    else:
        turn_system = _find_node_by_class(get_tree().root, "TurnSystem")
        if not turn_system:
            turn_system = _find_node_by_class(get_tree().root, "TurnCycleController")
            
        if turn_system:
            print("Found turn system by class: " + turn_system.name)
            
            # Get current turn
            if "current_turn" in turn_system:
                current_turn = turn_system.current_turn

func _find_node_by_class(node, class_name):
    if node.get_class() == class_name:
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name)
        if found:
            return found
    
    return null

func _initialize_network():
    # Clear existing network
    nodes.clear()
    connections.clear()
    active_nodes.clear()
    memory_points.clear()
    number_points.clear()
    
    # Create initial dynamic number of nodes
    var node_count = min_nodes + randi() % (max_nodes - min_nodes + 1)
    
    # Create nodes
    for i in range(node_count):
        var node = {
            "position": Vector2(randf_range(20, 980), randf_range(20, 580)),
            "size": randf_range(node_min_size, node_max_size),
            "activity": randf(),
            "type": randi() % 3,  # 0: standard, 1: memory, 2: number
            "connections": []
        }
        nodes.append(node)
    
    # Create connections between nodes
    for i in range(nodes.size()):
        for j in range(i+1, nodes.size()):
            if randf() < connection_threshold:
                var connection = {
                    "from": i,
                    "to": j,
                    "weight": randf(),
                    "active": randf() < 0.5
                }
                connections.append(connection)
                nodes[i].connections.append(j)
                nodes[j].connections.append(i)
    
    # Create special memory points based on the digit 8
    _create_number_shape(8, 100, 150, 0.5)
    _create_number_shape(8, 200, 150, 0.5)
    _create_number_shape(8, 300, 150, 0.5)
    
    # Create initial active nodes
    _update_active_nodes()

# ----- PROCESS -----
func _process(delta):
    if not enabled:
        return
    
    # Update animations
    _update_animation(delta)
    
    # Draw the visualization each frame
    queue_redraw()

func _update_animation(delta):
    animation_time += delta
    
    # Update pulse
    pulse_timer += delta * (lucky_active ? lucky_pulse_rate : 1.0)
    current_pulse += delta * pulse_dir * (lucky_active ? lucky_pulse_rate : 1.0)
    if current_pulse > 1.0:
        current_pulse = 1.0
        pulse_dir = -1
    elif current_pulse < 0.0:
        current_pulse = 0.0
        pulse_dir = 1
    
    # Gradually transition number shape if needed
    number_morph_time += delta * 0.2
    if number_morph_time >= 1.0:
        number_morph_time = 0.0
        # Update to next number in sequence if memory usage changes significantly
        if memory_usage > 0.8 and sequence_index < number_sequence.size() - 1:
            sequence_index += 1
            active_number = number_sequence[sequence_index]
            _reorganize_for_number(active_number)
    
    # Animate node positions slightly
    for i in range(nodes.size()):
        var noise_x = sin(animation_time * 0.5 + i * 0.1) * 2.0
        var noise_y = cos(animation_time * 0.4 + i * 0.13) * 2.0
        nodes[i].position += Vector2(noise_x, noise_y)
        
        # Keep within bounds
        nodes[i].position.x = clamp(nodes[i].position.x, 10, 990)
        nodes[i].position.y = clamp(nodes[i].position.y, 10, 590)
        
        # Update node activity
        if nodes[i].type == 1:  # Memory nodes
            nodes[i].activity = 0.3 + 0.7 * memory_usage
        elif nodes[i].type == 2:  # Number nodes
            nodes[i].activity = 0.5 + 0.5 * current_pulse

# ----- DRAWING -----
func _draw():
    if not enabled:
        return
    
    # Draw background
    var bg_color = Color(0, 0, 0, background_fade)
    draw_rect(Rect2(0, 0, 1000, 600), bg_color)
    
    # Draw connections
    for connection in connections:
        if connection.active:
            var from_node = nodes[connection.from]
            var to_node = nodes[connection.to]
            var weight = connection.weight
            
            # Determine connection color
            var color
            if from_node.type == 2 or to_node.type == 2:  # Number node
                color = lucky_active ? lucky_color : secondary_color
                color.a = 0.3 + 0.7 * current_pulse
            else:
                color = main_color
                color.a = 0.2 + weight * 0.5
            
            draw_line(from_node.position, to_node.position, color, connection_width * weight)
    
    # Draw nodes
    for i in range(nodes.size()):
        var node = nodes[i]
        var size = node.size * (active_nodes.has(i) ? 1.5 : 1.0)
        
        # Adjust size based on memory for memory nodes
        if node.type == 1:
            size *= (0.8 + memory_usage * 0.5)
        
        # Pulse size for number nodes
        if node.type == 2:
            size *= (1.0 + current_pulse * 0.5)
        
        # Adjust all sizes based on neural size multiplier
        size *= neural_size_multiplier
        
        # Determine node color
        var color
        match node.type:
            0:  # Standard node
                color = main_color
                color.a = 0.2 + node.activity * 0.8
            1:  # Memory node
                color = secondary_color
                color.a = 0.3 + node.activity * 0.7
            2:  # Number node
                color = lucky_active ? lucky_color : secondary_color
                color.a = 0.5 + current_pulse * 0.5
        
        draw_circle(node.position, size, color)

# ----- EVENT HANDLERS -----
func _on_update_timer_timeout():
    # Update active nodes
    _update_active_nodes()
    
    # Update connection activity
    for connection in connections:
        connection.active = randf() < (0.3 + memory_usage * 0.7)
    
    # Adjust number of active nodes based on memory usage
    var target_active = min_nodes + int((max_nodes - min_nodes) * memory_usage)
    
    if active_nodes.size() > target_active:
        # Remove some active nodes
        while active_nodes.size() > target_active:
            active_nodes.remove_at(randi() % active_nodes.size())
    elif active_nodes.size() < target_active:
        # Add some active nodes
        var available = []
        for i in range(nodes.size()):
            if not active_nodes.has(i) and nodes[i].type == 0:
                available.append(i)
        
        while active_nodes.size() < target_active and available.size() > 0:
            var idx = randi() % available.size()
            active_nodes.append(available[idx])
            available.remove_at(idx)

func _on_data_timer_timeout():
    # Update data from connected systems
    if time_tracker:
        var usage_summary = time_tracker.get_usage_summary() if time_tracker.has_method("get_usage_summary") else null
        
        if usage_summary:
            # Update memory usage based on total time
            memory_usage = min(1.0, usage_summary.total_usage_time / (3600.0 * 4))  # Max out at 4 hours
            
            # Check for lucky state
            lucky_active = usage_summary.has("lucky") and usage_summary.lucky.is_lucky
            
            # Update neural size based on current session length
            neural_size_multiplier = 0.8 + min(usage_summary.current_session_time / 3600.0, 1.0)
    
    if turn_system:
        # Update current turn
        if "current_turn" in turn_system:
            var new_turn = turn_system.current_turn
            if new_turn != current_turn:
                current_turn = new_turn
                _reorganize_on_turn_change()

# ----- NEURAL NETWORK MANAGEMENT -----
func _update_active_nodes():
    active_nodes.clear()
    
    # Activate nodes based on memory usage and type
    for i in range(nodes.size()):
        var node = nodes[i]
        
        if node.type == 1 and memory_usage > 0.3:
            # Memory nodes activate when memory usage is high enough
            active_nodes.append(i)
        elif node.type == 2:
            # Number nodes are always active
            active_nodes.append(i)
        else:
            # Standard nodes activate based on activity threshold
            if node.activity > 0.6 or randf() < 0.2:
                active_nodes.append(i)

func _reorganize_on_turn_change():
    # Reorganize network based on turn number
    if current_turn > 6:
        # Later turns have more structured networks
        connection_threshold = 0.6
        memory_density = 1.2
    else:
        # Earlier turns have looser networks
        connection_threshold = 0.4
        memory_density = 0.8
    
    # For turns divisible by 4, reorganize around the current number
    if current_turn % 4 == 0:
        sequence_index = (sequence_index + 1) % number_sequence.size()
        active_number = number_sequence[sequence_index]
        _reorganize_for_number(active_number)

func _reorganize_for_number(number: int):
    # Clear old number points
    for i in range(nodes.size()-1, -1, -1):
        if nodes[i].type == 2:
            nodes.remove_at(i)
    
    # Create new number shape
    match number:
        8:
            _create_number_shape(8, 300, 300, 1.0)
        88:
            _create_number_shape(8, 250, 300, 0.8)
            _create_number_shape(8, 350, 300, 0.8)
        888:
            _create_number_shape(8, 200, 300, 0.7)
            _create_number_shape(8, 300, 300, 0.7)
            _create_number_shape(8, 400, 300, 0.7)
        1333:
            _create_number_shape(1, 200, 300, 0.7)
            _create_number_shape(3, 300, 300, 0.7)
            _create_number_shape(3, 350, 300, 0.7)
            _create_number_shape(3, 400, 300, 0.7)
        _:
            # Default to 8 if unknown number
            _create_number_shape(8, 300, 300, 1.0)
    
    # Update connections
    _rebuild_connections()
    
    # Update active nodes
    _update_active_nodes()

func _create_number_shape(digit: int, center_x: float, center_y: float, scale: float):
    var points = []
    
    match digit:
        1:
            # Create a "1" shape
            for i in range(10):
                points.append(Vector2(center_x, center_y - 50 * scale + i * 10 * scale))
        3:
            # Create a "3" shape
            var radius = 25 * scale
            var segments = 10
            
            # Top arc
            for i in range(segments+1):
                var angle = PI - i * PI / segments
                points.append(Vector2(
                    center_x + cos(angle) * radius,
                    center_y - 25 * scale + sin(angle) * radius
                ))
            
            # Bottom arc
            for i in range(segments+1):
                var angle = 0 - i * PI / segments
                points.append(Vector2(
                    center_x + cos(angle) * radius,
                    center_y + 25 * scale + sin(angle) * radius
                ))
        8:
            # Create an "8" shape
            var radius = 25 * scale
            var segments = 12
            
            # Top circle
            for i in range(segments):
                var angle = i * 2 * PI / segments
                points.append(Vector2(
                    center_x + cos(angle) * radius,
                    center_y - 25 * scale + sin(angle) * radius
                ))
            
            # Bottom circle
            for i in range(segments):
                var angle = i * 2 * PI / segments
                points.append(Vector2(
                    center_x + cos(angle) * radius,
                    center_y + 25 * scale + sin(angle) * radius
                ))
    
    # Create nodes from points
    for point in points:
        var node = {
            "position": point,
            "size": randf_range(node_min_size, node_max_size),
            "activity": 0.8,
            "type": 2,  # Number type
            "connections": []
        }
        nodes.append(node)
        number_points.append(nodes.size() - 1)

func _rebuild_connections():
    connections.clear()
    
    # Reset node connections
    for node in nodes:
        node.connections.clear()
    
    # Create connections between nodes
    for i in range(nodes.size()):
        for j in range(i+1, nodes.size()):
            var node_i = nodes[i]
            var node_j = nodes[j]
            
            var distance = node_i.position.distance_to(node_j.position)
            var max_dist = 150
            
            # Nodes of the same type connect more easily
            var type_factor = 1.0
            if node_i.type == node_j.type:
                type_factor = 1.5
            
            # Number nodes connect to nearby nodes more easily
            if node_i.type == 2 or node_j.type == 2:
                max_dist = 100
            
            var chance = connection_threshold * type_factor * (1.0 - distance / max_dist)
            
            if distance < max_dist and randf() < chance:
                var connection = {
                    "from": i,
                    "to": j,
                    "weight": 1.0 - distance / max_dist,
                    "active": randf() < 0.7
                }
                connections.append(connection)
                node_i.connections.append(j)
                node_j.connections.append(i)

# ----- PUBLIC API -----
func set_number_sequence(new_sequence: Array):
    if new_sequence.size() > 0:
        number_sequence = new_sequence
        # Immediately use the first number
        active_number = number_sequence[0]
        sequence_index = 0
        _reorganize_for_number(active_number)
    return number_sequence

func set_lucky_number(number: int):
    lucky_number = number
    return lucky_number

func toggle_enabled():
    enabled = !enabled
    return enabled

func force_next_number():
    sequence_index = (sequence_index + 1) % number_sequence.size()
    active_number = number_sequence[sequence_index]
    _reorganize_for_number(active_number)
    return active_number