extends Node

class_name EtherealAkashicBridge

# ----- BRIDGE SETTINGS -----
@export_category("Bridge Configuration")
@export var enabled: bool = true
@export var auto_connect: bool = true
@export var ethereal_engine_path: String = "res://ethereal_engine_integration.gd"
@export var akashic_bridge_path: String = "res://claude_akashic_bridge.gd"
@export var connection_frequency: float = 0.5  # How often to synchronize (in seconds)
@export var dimensional_depth: int = 8
@export var max_data_transfer: int = 888

# ----- CONNECTION VARIABLES -----
var ethereal_engine: Node = null
var akashic_bridge: Node = null
var memory_system: Node = null
var turn_system: Node = null

# ----- DATA CHANNELS -----
var data_channels: Dictionary = {}
var active_channels: Array = []
var frequency_channels: Dictionary = {}

# ----- DIMENSIONAL CONNECTIONS -----
var dimension_map: Dictionary = {}
var current_dimension: String = "0-0-0"
var dimension_stack: Array = []

# ----- VISUALIZATION DATA -----
var fractal_points: Array = []
var connection_nodes: Array = []
var visualization_ready: bool = false

# ----- PROCESSING -----
var process_interval: float = 0.1
var last_process_time: float = 0.0
var connection_timer: Timer
var sync_timer: Timer

# ----- SIGNALS -----
signal connection_established(system_name)
signal dimension_changed(previous, current)
signal data_transferred(channel, size)
signal bridge_synchronization_completed()
signal fractal_data_updated(points)
signal memory_recorded(content, dimension)

# ----- INITIALIZATION -----
func _ready():
    # Initialize timers
    _setup_timers()
    
    # Find components
    _find_components()
    
    # Initialize dimension map
    _initialize_dimension_map()
    
    # Initialize fractal points for visualization
    _initialize_fractal_visualization()
    
    # Auto-connect if enabled
    if auto_connect:
        connect_systems()
    
    print("Ethereal Akashic Bridge initialized in dimension: " + current_dimension)

func _setup_timers():
    # Create connection timer
    connection_timer = Timer.new()
    connection_timer.wait_time = 1.0  # Check connections every second
    connection_timer.one_shot = false
    connection_timer.autostart = true
    connection_timer.connect("timeout", _on_connection_timer_timeout)
    add_child(connection_timer)
    
    # Create sync timer
    sync_timer = Timer.new()
    sync_timer.wait_time = connection_frequency
    sync_timer.one_shot = false
    sync_timer.autostart = true
    sync_timer.connect("timeout", _on_sync_timer_timeout)
    add_child(sync_timer)

func _find_components():
    # Find Ethereal Engine
    ethereal_engine = _load_or_find_node("EtherealEngine")
    
    # Find Akashic Bridge
    akashic_bridge = _load_or_find_node("ClaudeAkashicBridge")
    
    # Find Memory System
    memory_system = _find_node_by_class(get_tree().root, "IntegratedMemorySystem")
    
    # Find Turn System
    turn_system = _find_node_by_class(get_tree().root, "TurnSystem")
    if not turn_system:
        turn_system = _find_node_by_class(get_tree().root, "TurnCycleController")

func _load_or_find_node(class_name_str):
    # First try to find existing node
    var node = _find_node_by_class(get_tree().root, class_name_str)
    
    if node:
        print("Found existing " + class_name_str + ": " + node.name)
        return node
    
    # If not found, check if we can instance from script
    var script_path = ""
    if class_name_str == "EtherealEngine":
        script_path = ethereal_engine_path
    elif class_name_str == "ClaudeAkashicBridge":
        script_path = akashic_bridge_path
    
    if script_path and ResourceLoader.exists(script_path):
        var script = load(script_path)
        if script:
            var instance = Node.new()
            instance.set_script(script)
            instance.name = class_name_str + "Instance"
            add_child(instance)
            print("Instantiated " + class_name_str + " from script")
            return instance
    
    return null

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _initialize_dimension_map():
    # Create dimension coordinates centered at 0,0,0
    for x in range(-dimensional_depth, dimensional_depth + 1):
        for y in range(-dimensional_depth, dimensional_depth + 1):
            for z in range(-dimensional_depth, dimensional_depth + 1):
                # Only create dimensions within a sphere
                var distance = sqrt(x*x + y*y + z*z)
                if distance <= dimensional_depth:
                    var dim_key = str(x) + "-" + str(y) + "-" + str(z)
                    dimension_map[dim_key] = {
                        "coordinates": Vector3(x, y, z),
                        "distance": distance,
                        "connections": [],
                        "data": {},
                        "frequency": _calculate_dimension_frequency(distance),
                        "last_visited": 0,
                        "stability": _calculate_stability(distance)
                    }
                    
                    # Connect to adjacent dimensions
                    _connect_adjacent_dimensions(dim_key, x, y, z)

func _connect_adjacent_dimensions(dim_key, x, y, z):
    # Connect to the 6 adjacent dimensions (if they exist)
    var adjacent = [
        [x+1, y, z], [x-1, y, z],
        [x, y+1, z], [x, y-1, z],
        [x, y, z+1], [x, y, z-1]
    ]
    
    for adj in adjacent:
        var adj_key = str(adj[0]) + "-" + str(adj[1]) + "-" + str(adj[2])
        if dimension_map.has(adj_key):
            dimension_map[dim_key].connections.append(adj_key)

func _calculate_dimension_frequency(distance):
    # Dimensions closer to center have higher frequencies
    return 1.0 - (distance / (dimensional_depth * 1.5))

func _calculate_stability(distance):
    # Dimensions closer to center are more stable
    var stability = 1.0 - (distance / (dimensional_depth * 2.0))
    return clamp(stability, 0.1, 0.95)  # Never fully stable or unstable

func _initialize_fractal_visualization():
    fractal_points.clear()
    connection_nodes.clear()
    
    # Create fractal points from dimension map
    for dim_key in dimension_map:
        var dim_data = dimension_map[dim_key]
        
        # Scale coordinates for visualization
        var coords = dim_data.coordinates * 20.0
        
        fractal_points.append({
            "position": coords,
            "frequency": dim_data.frequency,
            "stability": dim_data.stability,
            "key": dim_key
        })
        
        # Create connection nodes (edges of the graph)
        for connection in dim_data.connections:
            if connection > dim_key:  # Only add each connection once
                if dimension_map.has(connection):
                    var conn_coords = dimension_map[connection].coordinates * 20.0
                    
                    connection_nodes.append({
                        "from": coords,
                        "to": conn_coords,
                        "strength": (dim_data.stability + dimension_map[connection].stability) / 2.0
                    })
    
    visualization_ready = true
    emit_signal("fractal_data_updated", fractal_points)

# ----- CONNECTION MANAGEMENT -----
func connect_systems():
    if not enabled:
        return false
    
    var success = true
    
    # Connect to Ethereal Engine
    if ethereal_engine:
        _setup_ethereal_engine()
        emit_signal("connection_established", "EtherealEngine")
    else:
        print("Warning: Ethereal Engine not found")
        success = false
    
    # Connect to Akashic Bridge
    if akashic_bridge:
        _setup_akashic_bridge()
        emit_signal("connection_established", "AkashicBridge")
    else:
        print("Warning: Akashic Bridge not found")
        success = false
    
    # Connect to Memory System
    if memory_system:
        _setup_memory_system()
        emit_signal("connection_established", "MemorySystem")
    else:
        print("Warning: Memory System not found")
    
    # Connect to Turn System
    if turn_system:
        _setup_turn_system()
        emit_signal("connection_established", "TurnSystem")
    else:
        print("Warning: Turn System not found")
    
    # Initialize data channels
    _initialize_data_channels()
    
    return success

func _setup_ethereal_engine():
    # Connect signals if available
    if ethereal_engine.has_signal("dimension_shifted"):
        ethereal_engine.connect("dimension_shifted", _on_ethereal_dimension_shifted)
    
    if ethereal_engine.has_signal("data_processed"):
        ethereal_engine.connect("data_processed", _on_ethereal_data_processed)
    
    # Initialize engine with our current dimension
    if ethereal_engine.has_method("set_current_dimension"):
        ethereal_engine.set_current_dimension(current_dimension)

func _setup_akashic_bridge():
    # Connect signals if available
    if akashic_bridge.has_signal("record_accessed"):
        akashic_bridge.connect("record_accessed", _on_akashic_record_accessed)
    
    if akashic_bridge.has_signal("data_stored"):
        akashic_bridge.connect("data_stored", _on_akashic_data_stored)
    
    # Initialize bridge with our dimension map
    if akashic_bridge.has_method("set_dimension_data"):
        var simplified_dimensions = {}
        for dim_key in dimension_map:
            simplified_dimensions[dim_key] = {
                "frequency": dimension_map[dim_key].frequency,
                "stability": dimension_map[dim_key].stability
            }
        
        akashic_bridge.set_dimension_data(simplified_dimensions)

func _setup_memory_system():
    # Connect signals if available
    if memory_system.has_signal("memory_stored"):
        memory_system.connect("memory_stored", _on_memory_stored)
    
    if memory_system.has_signal("wish_added"):
        memory_system.connect("wish_added", _on_wish_added)

func _setup_turn_system():
    # Connect signals if available
    if turn_system.has_signal("turn_advanced"):
        turn_system.connect("turn_advanced", _on_turn_advanced)
    
    if turn_system.has_method("get_current_turn"):
        var turn = turn_system.get_current_turn()
        _update_frequency_for_turn(turn)

func _initialize_data_channels():
    # Create standard data channels
    data_channels = {
        "memory": { "active": true, "buffer": [], "capacity": max_data_transfer, "frequency": 1.0 },
        "akashic": { "active": true, "buffer": [], "capacity": max_data_transfer, "frequency": 0.8 },
        "ethereal": { "active": true, "buffer": [], "capacity": max_data_transfer, "frequency": 0.7 },
        "dimensional": { "active": true, "buffer": [], "capacity": max_data_transfer, "frequency": 0.9 },
        "turn": { "active": true, "buffer": [], "capacity": max_data_transfer, "frequency": 0.5 },
        "wish": { "active": true, "buffer": [], "capacity": max_data_transfer, "frequency": 0.3 }
    }
    
    # Update active channels list
    _update_active_channels()

func _update_active_channels():
    active_channels.clear()
    
    for channel_name in data_channels:
        var channel = data_channels[channel_name]
        if channel.active:
            active_channels.append(channel_name)
    
    # Update frequency channels
    _update_frequency_channels()

func _update_frequency_channels():
    frequency_channels.clear()
    
    for channel_name in data_channels:
        var channel = data_channels[channel_name]
        var freq_key = str(snappedf(channel.frequency, 0.1))
        
        if not frequency_channels.has(freq_key):
            frequency_channels[freq_key] = []
        
        frequency_channels[freq_key].append(channel_name)

# ----- DIMENSION MANAGEMENT -----
func change_dimension(dimension_key: String):
    if not dimension_map.has(dimension_key):
        print("Warning: Dimension " + dimension_key + " does not exist")
        return false
    
    var previous = current_dimension
    current_dimension = dimension_key
    
    # Update dimension stack
    dimension_stack.append(previous)
    if dimension_stack.size() > 12:  # Keep only last 12 dimensions
        dimension_stack.remove_at(0)
    
    # Update dimension data
    dimension_map[current_dimension].last_visited = Time.get_unix_time_from_system()
    
    # Notify connected systems
    if ethereal_engine and ethereal_engine.has_method("set_current_dimension"):
        ethereal_engine.set_current_dimension(current_dimension)
    
    # Update data channel
    var dimension_data = {
        "previous": previous,
        "current": current_dimension,
        "timestamp": Time.get_unix_time_from_system(),
        "stack": dimension_stack.duplicate()
    }
    
    _add_to_channel("dimensional", dimension_data)
    
    # Emit signal
    emit_signal("dimension_changed", previous, current_dimension)
    
    return true

func get_connected_dimensions():
    if dimension_map.has(current_dimension):
        return dimension_map[current_dimension].connections
    return []

func get_dimension_at_coordinates(x, y, z):
    var key = str(x) + "-" + str(y) + "-" + str(z)
    if dimension_map.has(key):
        return key
    return null

func store_in_dimension(dimension_key, key, value):
    if dimension_map.has(dimension_key):
        dimension_map[dimension_key].data[key] = value
        return true
    return false

func retrieve_from_dimension(dimension_key, key):
    if dimension_map.has(dimension_key) and dimension_map[dimension_key].data.has(key):
        return dimension_map[dimension_key].data[key]
    return null

# ----- DATA CHANNEL MANAGEMENT -----
func _add_to_channel(channel_name, data):
    if not data_channels.has(channel_name):
        return false
    
    var channel = data_channels[channel_name]
    
    # Add timestamp if not present
    if typeof(data) == TYPE_DICTIONARY and not data.has("_timestamp"):
        data["_timestamp"] = Time.get_unix_time_from_system()
    
    # Add to buffer
    channel.buffer.append(data)
    
    # Ensure buffer doesn't exceed capacity
    while channel.buffer.size() > channel.capacity:
        channel.buffer.remove_at(0)
    
    return true

func clear_channel(channel_name):
    if not data_channels.has(channel_name):
        return false
    
    data_channels[channel_name].buffer.clear()
    return true

func get_channel_data(channel_name):
    if not data_channels.has(channel_name):
        return []
    
    return data_channels[channel_name].buffer.duplicate()

func set_channel_frequency(channel_name, frequency):
    if not data_channels.has(channel_name):
        return false
    
    data_channels[channel_name].frequency = clamp(frequency, 0.0, 1.0)
    _update_frequency_channels()
    
    return true

func toggle_channel(channel_name, active: bool):
    if not data_channels.has(channel_name):
        return false
    
    data_channels[channel_name].active = active
    _update_active_channels()
    
    return true

# ----- AKASHIC RECORD OPERATIONS -----
func record_memory(content, tags = [], dimension_key = ""):
    if dimension_key.is_empty():
        dimension_key = current_dimension
    
    if not dimension_map.has(dimension_key):
        return false
    
    # Create memory structure
    var memory = {
        "content": content,
        "tags": tags,
        "dimension": dimension_key,
        "timestamp": Time.get_unix_time_from_system(),
        "frequency": dimension_map[dimension_key].frequency
    }
    
    # Store in akashic channel
    _add_to_channel("akashic", memory)
    
    # If memory system is available, also store there
    if memory_system and memory_system.has_method("store_memory"):
        # Add dimension info to tags
        var combined_tags = tags.duplicate()
        combined_tags.append("dimension:" + dimension_key)
        
        var memory_id = memory_system.store_memory(content, combined_tags, "akashic", -1)
        memory["memory_id"] = memory_id
    
    # Emit signal
    emit_signal("memory_recorded", content, dimension_key)
    
    return true

func search_akashic_records(query, dimension_key = ""):
    var results = []
    
    # Search in akashic channel
    var akashic_data = get_channel_data("akashic")
    
    for entry in akashic_data:
        if typeof(entry) != TYPE_DICTIONARY:
            continue
        
        # Check dimension constraint
        if not dimension_key.is_empty() and entry.has("dimension") and entry.dimension != dimension_key:
            continue
        
        # Check query match
        if entry.has("content") and entry.content.to_lower().contains(query.to_lower()):
            results.append(entry)
    
    # If memory system is available, also search there
    if memory_system and memory_system.has_method("search_memories"):
        var tags = []
        if not dimension_key.is_empty():
            tags.append("dimension:" + dimension_key)
        
        var memory_results = memory_system.search_memories(query, tags)
        
        # Add results that aren't already included
        for memory in memory_results:
            var already_included = false
            
            for existing in results:
                if existing.has("memory_id") and memory.id == existing.memory_id:
                    already_included = true
                    break
            
            if not already_included:
                results.append({
                    "content": memory.content,
                    "tags": memory.tags,
                    "timestamp": memory.timestamp,
                    "memory_id": memory.id,
                    "dimension": dimension_key.is_empty() ? current_dimension : dimension_key
                })
    
    return results

# ----- ETHEREAL ENGINE OPERATIONS -----
func process_ethereal_data(data_type, content):
    if not ethereal_engine:
        return false
    
    # Create data structure
    var data = {
        "type": data_type,
        "content": content,
        "dimension": current_dimension,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Store in ethereal channel
    _add_to_channel("ethereal", data)
    
    # Forward to ethereal engine if it has the method
    if ethereal_engine.has_method("process_data"):
        ethereal_engine.process_data(data_type, content, current_dimension)
    
    return true

func create_ethereal_scene(scene_data):
    if not ethereal_engine:
        return false
    
    # Store in ethereal channel
    _add_to_channel("ethereal", {
        "type": "scene",
        "data": scene_data,
        "dimension": current_dimension,
        "timestamp": Time.get_unix_time_from_system()
    })
    
    # Forward to ethereal engine if it has the method
    if ethereal_engine.has_method("create_scene"):
        return ethereal_engine.create_scene(scene_data, current_dimension)
    
    return false

func perform_ethereal_action(action_name, parameters = {}):
    if not ethereal_engine:
        return false
    
    # Store in ethereal channel
    _add_to_channel("ethereal", {
        "type": "action",
        "name": action_name,
        "parameters": parameters,
        "dimension": current_dimension,
        "timestamp": Time.get_unix_time_from_system()
    })
    
    # Forward to ethereal engine if it has the method
    if ethereal_engine.has_method("perform_action"):
        return ethereal_engine.perform_action(action_name, parameters, current_dimension)
    
    return false

# ----- BRIDGE SYNCHRONIZATION -----
func _process(delta):
    if not enabled:
        return
    
    # Update processing at regular intervals
    last_process_time += delta
    if last_process_time >= process_interval:
        last_process_time = 0.0
        _process_active_channels(delta)

func _process_active_channels(delta):
    # Process channels based on their frequency
    for channel_name in active_channels:
        var channel = data_channels[channel_name]
        
        # Skip empty channels
        if channel.buffer.is_empty():
            continue
        
        # Process based on frequency and random chance
        if randf() < (channel.frequency * process_interval / connection_frequency):
            _process_channel_data(channel_name)

func _process_channel_data(channel_name):
    var channel = data_channels[channel_name]
    
    # Skip empty channels
    if channel.buffer.is_empty():
        return
    
    match channel_name:
        "memory":
            _process_memory_channel()
        "akashic":
            _process_akashic_channel()
        "ethereal":
            _process_ethereal_channel()
        "dimensional":
            _process_dimensional_channel()
        "turn":
            _process_turn_channel()
        "wish":
            _process_wish_channel()

func _process_memory_channel():
    # Process a few items from the memory channel
    var channel = data_channels["memory"]
    var count = min(3, channel.buffer.size())
    
    if count == 0:
        return
    
    for i in range(count):
        var memory = channel.buffer[i]
        
        # If memory system is available, ensure it's stored there
        if memory_system and memory_system.has_method("store_memory") and not memory.has("memory_id"):
            var tags = memory.has("tags") ? memory.tags.duplicate() : []
            
            # Add dimension tag
            if memory.has("dimension"):
                tags.append("dimension:" + memory.dimension)
            
            var memory_id = memory_system.store_memory(
                memory.content,
                tags,
                "bridge_memory",
                -1
            )
            
            memory["memory_id"] = memory_id
    
    # Remove processed items
    for i in range(count):
        channel.buffer.remove_at(0)
    
    emit_signal("data_transferred", "memory", count)

func _process_akashic_channel():
    # Process a few items from the akashic channel
    var channel = data_channels["akashic"]
    var count = min(2, channel.buffer.size())
    
    if count == 0:
        return
    
    for i in range(count):
        var record = channel.buffer[i]
        
        # Forward to akashic bridge if available
        if akashic_bridge and akashic_bridge.has_method("store_record"):
            akashic_bridge.store_record(record.content, record.dimension, record.has("tags") ? record.tags : [])
    
    # Remove processed items
    for i in range(count):
        channel.buffer.remove_at(0)
    
    emit_signal("data_transferred", "akashic", count)

func _process_ethereal_channel():
    # Process a few items from the ethereal channel
    var channel = data_channels["ethereal"]
    var count = min(2, channel.buffer.size())
    
    if count == 0:
        return
    
    # Most ethereal operations are processed immediately when called,
    # so we just need to clean up old items
    var current_time = Time.get_unix_time_from_system()
    var items_to_remove = []
    
    for i in range(channel.buffer.size()):
        var data = channel.buffer[i]
        
        # Remove items older than 5 minutes
        if data.has("_timestamp") and (current_time - data._timestamp) > 300:
            items_to_remove.append(i)
    
    # Remove old items (in reverse order to maintain indices)
    items_to_remove.sort()
    items_to_remove.reverse()
    
    for idx in items_to_remove:
        channel.buffer.remove_at(idx)
    
    emit_signal("data_transferred", "ethereal", items_to_remove.size())

func _process_dimensional_channel():
    # Process a few items from the dimensional channel
    var channel = data_channels["dimensional"]
    var count = min(1, channel.buffer.size())
    
    if count == 0:
        return
    
    # Most dimensional operations are processed immediately when called,
    # so we just update dimension stability based on frequency of use
    
    var current_time = Time.get_unix_time_from_system()
    var items_to_remove = []
    
    for i in range(channel.buffer.size()):
        var data = channel.buffer[i]
        
        # Process dimensional stability updates
        if data.has("current") and dimension_map.has(data.current):
            var dim_data = dimension_map[data.current]
            
            # More frequent visits improve stability slightly
            if data.has("_timestamp") and (current_time - data._timestamp) < 3600:  # Within last hour
                dim_data.stability = min(dim_data.stability + 0.01, 0.95)
            
            # Update last visited time
            dim_data.last_visited = data._timestamp if data.has("_timestamp") else current_time
        
        # Remove items older than 10 minutes
        if data.has("_timestamp") and (current_time - data._timestamp) > 600:
            items_to_remove.append(i)
    
    # Remove old items (in reverse order to maintain indices)
    items_to_remove.sort()
    items_to_remove.reverse()
    
    for idx in items_to_remove:
        channel.buffer.remove_at(idx)
    
    emit_signal("data_transferred", "dimensional", items_to_remove.size())

func _process_turn_channel():
    # Process a few items from the turn channel
    var channel = data_channels["turn"]
    var count = min(1, channel.buffer.size())
    
    if count == 0:
        return
    
    # Most turn operations are processed immediately when turn changes,
    # so we just need to clean up old items
    var current_time = Time.get_unix_time_from_system()
    var items_to_remove = []
    
    for i in range(channel.buffer.size()):
        var data = channel.buffer[i]
        
        # Remove items older than 5 minutes
        if data.has("_timestamp") and (current_time - data._timestamp) > 300:
            items_to_remove.append(i)
    
    # Remove old items (in reverse order to maintain indices)
    items_to_remove.sort()
    items_to_remove.reverse()
    
    for idx in items_to_remove:
        channel.buffer.remove_at(idx)
    
    emit_signal("data_transferred", "turn", items_to_remove.size())

func _process_wish_channel():
    # Process a few items from the wish channel
    var channel = data_channels["wish"]
    var count = min(1, channel.buffer.size())
    
    if count == 0:
        return
    
    for i in range(count):
        var wish = channel.buffer[i]
        
        # If memory system is available, add wish there
        if memory_system and memory_system.has_method("add_wish") and not wish.has("wish_id"):
            var tags = wish.has("tags") ? wish.tags.duplicate() : []
            
            # Add dimension tag
            if wish.has("dimension"):
                tags.append("dimension:" + wish.dimension)
            
            var wish_id = memory_system.add_wish(
                wish.content,
                wish.has("priority") ? wish.priority : 5,
                tags
            )
            
            wish["wish_id"] = wish_id
    
    # Remove processed items
    for i in range(count):
        channel.buffer.remove_at(0)
    
    emit_signal("data_transferred", "wish", count)

# ----- FRACTAL VISUALIZATION -----
func get_fractal_visualization_data():
    return {
        "points": fractal_points,
        "connections": connection_nodes,
        "current_dimension": current_dimension,
        "dimension_stack": dimension_stack
    }

func get_dimension_fractal(dimension_key = ""):
    if dimension_key.is_empty():
        dimension_key = current_dimension
    
    if not dimension_map.has(dimension_key):
        return null
    
    # Get dimension data
    var dim_data = dimension_map[dimension_key]
    
    # Create fractal representation
    var fractal = {
        "position": dim_data.coordinates,
        "frequency": dim_data.frequency,
        "stability": dim_data.stability,
        "connections": dim_data.connections.duplicate(),
        "data_size": dim_data.data.size(),
        "last_visited": dim_data.last_visited
    }
    
    return fractal

# ----- EVENT HANDLERS -----
func _on_connection_timer_timeout():
    # Check connections and reconnect if needed
    if not ethereal_engine:
        ethereal_engine = _load_or_find_node("EtherealEngine")
        if ethereal_engine:
            _setup_ethereal_engine()
            emit_signal("connection_established", "EtherealEngine")
    
    if not akashic_bridge:
        akashic_bridge = _load_or_find_node("ClaudeAkashicBridge")
        if akashic_bridge:
            _setup_akashic_bridge()
            emit_signal("connection_established", "AkashicBridge")
    
    if not memory_system:
        memory_system = _find_node_by_class(get_tree().root, "IntegratedMemorySystem")
        if memory_system:
            _setup_memory_system()
            emit_signal("connection_established", "MemorySystem")
    
    if not turn_system:
        turn_system = _find_node_by_class(get_tree().root, "TurnSystem")
        if not turn_system:
            turn_system = _find_node_by_class(get_tree().root, "TurnCycleController")
        
        if turn_system:
            _setup_turn_system()
            emit_signal("connection_established", "TurnSystem")

func _on_sync_timer_timeout():
    # Perform full synchronization
    _synchronize_all_systems()
    emit_signal("bridge_synchronization_completed")

func _synchronize_all_systems():
    # Update connection between all systems
    
    # 1. Update dimension frequencies based on turn
    if turn_system:
        var turn = 1
        if turn_system.has_method("get_current_turn"):
            turn = turn_system.get_current_turn()
        
        _update_frequency_for_turn(turn)
    
    # 2. Update ethereal engine with current dimension data
    if ethereal_engine and ethereal_engine.has_method("update_dimension_data"):
        var dim_data = null
        if dimension_map.has(current_dimension):
            dim_data = dimension_map[current_dimension]
        
        ethereal_engine.update_dimension_data(current_dimension, dim_data)
    
    # 3. Update akashic bridge with current frequencies
    if akashic_bridge and akashic_bridge.has_method("update_frequencies"):
        var frequencies = {}
        for channel_name in data_channels:
            frequencies[channel_name] = data_channels[channel_name].frequency
        
        akashic_bridge.update_frequencies(frequencies)
    
    # 4. Update fractal visualization
    _update_fractal_visualization()

func _update_frequency_for_turn(turn_number):
    var turn_factor = float(turn_number) / 12.0  # Assuming 12 turns max
    
    # Adjust channel frequencies based on turn
    data_channels["memory"].frequency = 0.7 + turn_factor * 0.3
    data_channels["akashic"].frequency = 0.5 + turn_factor * 0.5
    data_channels["ethereal"].frequency = 0.4 + turn_factor * 0.6
    data_channels["dimensional"].frequency = 0.6 + turn_factor * 0.4
    data_channels["turn"].frequency = 0.3 + turn_factor * 0.7
    data_channels["wish"].frequency = 0.2 + turn_factor * 0.8
    
    # Update channel lists
    _update_active_channels()
    
    # Add to turn channel
    _add_to_channel("turn", {
        "turn": turn_number,
        "frequencies_updated": true,
        "timestamp": Time.get_unix_time_from_system()
    })

func _update_fractal_visualization():
    # Update fractal points based on current data
    for i in range(fractal_points.size()):
        var point = fractal_points[i]
        var dim_key = point.key
        
        if dimension_map.has(dim_key):
            point.frequency = dimension_map[dim_key].frequency
            point.stability = dimension_map[dim_key].stability
    
    # Update connection strengths
    for i in range(connection_nodes.size()):
        var conn = connection_nodes[i]
        var from_point = null
        var to_point = null
        
        # Find corresponding points
        for p in fractal_points:
            if p.position == conn.from:
                from_point = p
            if p.position == conn.to:
                to_point = p
            
            if from_point and to_point:
                break
        
        if from_point and to_point:
            conn.strength = (dimension_map[from_point.key].stability + dimension_map[to_point.key].stability) / 2.0
    
    emit_signal("fractal_data_updated", fractal_points)

func _on_ethereal_dimension_shifted(from_dim, to_dim):
    # Update our dimension to match
    if dimension_map.has(to_dim):
        change_dimension(to_dim)

func _on_ethereal_data_processed(data_type, content, dim):
    # Add to memory channel
    _add_to_channel("memory", {
        "content": "Ethereal data processed: " + data_type + " in dimension " + dim,
        "dimension": dim,
        "timestamp": Time.get_unix_time_from_system(),
        "type": "ethereal_data"
    })

func _on_akashic_record_accessed(record_id, content):
    # Add to akashic channel
    _add_to_channel("akashic", {
        "content": content,
        "record_id": record_id,
        "dimension": current_dimension,
        "timestamp": Time.get_unix_time_from_system(),
        "type": "record_access"
    })

func _on_akashic_data_stored(record_id, content):
    # Data already in akashic channel, nothing to do
    pass

func _on_memory_stored(memory_id, content):
    # Add to memory channel
    _add_to_channel("memory", {
        "content": content,
        "memory_id": memory_id,
        "dimension": current_dimension,
        "timestamp": Time.get_unix_time_from_system(),
        "type": "memory_storage"
    })

func _on_wish_added(wish_id, content):
    # Add to wish channel
    _add_to_channel("wish", {
        "content": content,
        "wish_id": wish_id,
        "dimension": current_dimension,
        "timestamp": Time.get_unix_time_from_system(),
        "type": "wish_creation"
    })

func _on_turn_advanced(old_turn, new_turn):
    # Update frequencies for new turn
    _update_frequency_for_turn(new_turn)
    
    # Record in memory
    record_memory("Advanced from Turn " + str(old_turn) + " to Turn " + str(new_turn), ["turn_change"])

# ----- PUBLIC API -----
func toggle_bridge(enabled_state: bool):
    enabled = enabled_state
    return enabled

func create_wish(content, priority = 5, tags = []):
    # Add to wish channel
    _add_to_channel("wish", {
        "content": content,
        "priority": priority,
        "tags": tags,
        "dimension": current_dimension,
        "timestamp": Time.get_unix_time_from_system()
    })
    
    # Forward to memory system if available
    if memory_system and memory_system.has_method("add_wish"):
        var combined_tags = tags.duplicate()
        combined_tags.append("dimension:" + current_dimension)
        
        return memory_system.add_wish(content, priority, combined_tags)
    
    return true

func set_connection_frequency(freq: float):
    connection_frequency = max(0.1, freq)
    sync_timer.wait_time = connection_frequency
    return connection_frequency

func get_active_dimensions():
    var active = []
    
    # Get dimensions visited in the last 24 hours
    var current_time = Time.get_unix_time_from_system()
    var time_threshold = current_time - 86400  # 24 hours
    
    for dim_key in dimension_map:
        var dim_data = dimension_map[dim_key]
        if dim_data.last_visited > time_threshold:
            active.append({
                "key": dim_key,
                "coordinates": dim_data.coordinates,
                "last_visited": dim_data.last_visited,
                "frequency": dim_data.frequency,
                "stability": dim_data.stability
            })
    
    return active

func get_bridge_status():
    return {
        "enabled": enabled,
        "current_dimension": current_dimension,
        "connections": {
            "ethereal_engine": ethereal_engine != null,
            "akashic_bridge": akashic_bridge != null,
            "memory_system": memory_system != null,
            "turn_system": turn_system != null
        },
        "channels": {
            "active_count": active_channels.size(),
            "channel_sizes": {
                "memory": data_channels.memory.buffer.size(),
                "akashic": data_channels.akashic.buffer.size(),
                "ethereal": data_channels.ethereal.buffer.size(),
                "dimensional": data_channels.dimensional.buffer.size(),
                "turn": data_channels.turn.buffer.size(),
                "wish": data_channels.wish.buffer.size()
            }
        },
        "dimensions": {
            "count": dimension_map.size(),
            "stack_size": dimension_stack.size()
        }
    }