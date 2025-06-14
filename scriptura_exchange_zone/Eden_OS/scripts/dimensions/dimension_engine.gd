extends Node

class_name DimensionEngine

# Dimension Engine for Eden_OS
# Manages the multi-dimensional aspects of the World of Words game

signal dimension_created(dimension_name)
signal dimension_shifted(old_dimension, new_dimension)
signal dimension_merged(source_dimension, target_dimension)
signal dimension_property_changed(dimension_name, property, value)

# Dimension constants
const MAX_DIMENSIONS = 25  # 5D with 5 options per dimension
const DEFAULT_DIMENSIONS = ["alpha", "beta", "gamma", "delta", "epsilon"]
const DIMENSION_TYPES = ["primary", "linguistic", "temporal", "spatial", "conceptual"]

# Dimension state
var active_dimensions = {}
var current_dimension = "alpha"
var dimension_connections = {}
var dimension_stability = {}
var dimension_properties = {}

# Dimensional coordinates (5D)
var dimension_coordinates = {}

# Word storage per dimension
var dimension_words = {}

# Dimension traversal history
var dimension_history = []
var dimension_branches = {}

func _ready():
    initialize_dimension_engine()
    print("Dimension Engine initialized with " + str(DEFAULT_DIMENSIONS.size()) + " dimensions")

func initialize_dimension_engine():
    # Create default dimensions
    for i in range(DEFAULT_DIMENSIONS.size()):
        var dimension_name = DEFAULT_DIMENSIONS[i]
        var dimension_type = DIMENSION_TYPES[i % DIMENSION_TYPES.size()]
        
        create_dimension(dimension_name, dimension_type)
    
    # Set current dimension
    current_dimension = DEFAULT_DIMENSIONS[0]
    
    # Create some connections between dimensions
    connect_dimensions("alpha", "beta")
    connect_dimensions("beta", "gamma")
    connect_dimensions("gamma", "delta")
    connect_dimensions("delta", "epsilon")
    connect_dimensions("alpha", "epsilon")

func create_dimension(dimension_name, dimension_type="primary", properties={}):
    if active_dimensions.has(dimension_name):
        return "Dimension '" + dimension_name + "' already exists"
    
    # Create dimension
    active_dimensions[dimension_name] = {
        "type": dimension_type,
        "created": Time.get_unix_time_from_system(),
        "connections": [],
        "stability": randf_range(0.5, 1.0)
    }
    
    # Initialize word storage
    dimension_words[dimension_name] = []
    
    # Set properties
    dimension_properties[dimension_name] = properties
    
    # Assign 5D coordinates
    dimension_coordinates[dimension_name] = {
        "x": randi() % 5,
        "y": randi() % 5,
        "z": randi() % 5,
        "w": randi() % 5,
        "t": randi() % 5
    }
    
    # Set stability
    dimension_stability[dimension_name] = {
        "value": randf_range(0.5, 1.0),
        "fluctuation": randf_range(0.0, 0.2),
        "last_update": Time.get_unix_time_from_system()
    }
    
    # Emit signal
    emit_signal("dimension_created", dimension_name)
    
    return "Dimension '" + dimension_name + "' created (" + dimension_type + ")"

func connect_dimensions(dimension1, dimension2, bidirectional=true):
    if not active_dimensions.has(dimension1):
        return "Dimension '" + dimension1 + "' not found"
    
    if not active_dimensions.has(dimension2):
        return "Dimension '" + dimension2 + "' not found"
    
    # Check if already connected
    if dimension2 in active_dimensions[dimension1]["connections"]:
        return "Dimensions already connected"
    
    # Create connection
    active_dimensions[dimension1]["connections"].append(dimension2)
    
    if bidirectional:
        active_dimensions[dimension2]["connections"].append(dimension1)
    
    # Store connection details
    var connection_id = dimension1 + "_" + dimension2
    dimension_connections[connection_id] = {
        "created": Time.get_unix_time_from_system(),
        "stability": (dimension_stability[dimension1]["value"] + dimension_stability[dimension2]["value"]) / 2.0,
        "traffic": 0
    }
    
    return "Dimensions connected: '" + dimension1 + "' and '" + dimension2 + "'"

func shift_dimension(dimension_name):
    if not active_dimensions.has(dimension_name):
        return "Dimension '" + dimension_name + "' not found"
    
    # Check if connected to current dimension
    if not dimension_name in active_dimensions[current_dimension]["connections"] and dimension_name != current_dimension:
        return "Cannot shift to dimension '" + dimension_name + "' - not connected to current dimension"
    
    var old_dimension = current_dimension
    current_dimension = dimension_name
    
    # Update connection traffic
    if old_dimension != dimension_name:
        var connection_id = old_dimension + "_" + dimension_name
        if not dimension_connections.has(connection_id):
            connection_id = dimension_name + "_" + old_dimension
        
        if dimension_connections.has(connection_id):
            dimension_connections[connection_id]["traffic"] += 1
    
    # Add to history
    dimension_history.append({
        "from": old_dimension,
        "to": dimension_name,
        "time": Time.get_unix_time_from_system()
    })
    
    # Emit signal
    emit_signal("dimension_shifted", old_dimension, dimension_name)
    
    return "Shifted from '" + old_dimension + "' to '" + dimension_name + "'"

func add_word_to_dimension(word, dimension_name=null):
    if dimension_name == null:
        dimension_name = current_dimension
    
    if not active_dimensions.has(dimension_name):
        return "Dimension '" + dimension_name + "' not found"
    
    if word in dimension_words[dimension_name]:
        return "Word '" + word + "' already exists in dimension '" + dimension_name + "'"
    
    dimension_words[dimension_name].append(word)
    
    return "Word '" + word + "' added to dimension '" + dimension_name + "'"

func merge_dimensions(source_dimension, target_dimension):
    if not active_dimensions.has(source_dimension):
        return "Source dimension '" + source_dimension + "' not found"
    
    if not active_dimensions.has(target_dimension):
        return "Target dimension '" + target_dimension + "' not found"
    
    # Check stability
    var source_stability = dimension_stability[source_dimension]["value"]
    var target_stability = dimension_stability[target_dimension]["value"]
    
    if source_stability < 0.3 or target_stability < 0.3:
        return "Cannot merge dimensions - stability too low"
    
    # Transfer words
    for word in dimension_words[source_dimension]:
        if not word in dimension_words[target_dimension]:
            dimension_words[target_dimension].append(word)
    
    # Transfer connections
    for connected_dimension in active_dimensions[source_dimension]["connections"]:
        if not connected_dimension in active_dimensions[target_dimension]["connections"] and connected_dimension != target_dimension:
            active_dimensions[target_dimension]["connections"].append(connected_dimension)
            active_dimensions[connected_dimension]["connections"].append(target_dimension)
            
            # Remove connection to source
            active_dimensions[connected_dimension]["connections"].erase(source_dimension)
    
    # Update properties
    for property in dimension_properties[source_dimension]:
        if not dimension_properties[target_dimension].has(property):
            dimension_properties[target_dimension][property] = dimension_properties[source_dimension][property]
    
    # Remove source dimension
    active_dimensions.erase(source_dimension)
    dimension_words.erase(source_dimension)
    dimension_properties.erase(source_dimension)
    dimension_stability.erase(source_dimension)
    dimension_coordinates.erase(source_dimension)
    
    # If current dimension was the source, shift to target
    if current_dimension == source_dimension:
        current_dimension = target_dimension
    
    # Emit signal
    emit_signal("dimension_merged", source_dimension, target_dimension)
    
    return "Dimensions merged: '" + source_dimension + "' into '" + target_dimension + "'"

func create_branch(branch_name, source_dimension=null):
    if source_dimension == null:
        source_dimension = current_dimension
    
    if not active_dimensions.has(source_dimension):
        return "Source dimension '" + source_dimension + "' not found"
    
    if active_dimensions.has(branch_name):
        return "Dimension '" + branch_name + "' already exists"
    
    # Create new dimension as a branch
    create_dimension(branch_name, active_dimensions[source_dimension]["type"], dimension_properties[source_dimension].duplicate())
    
    # Copy words
    for word in dimension_words[source_dimension]:
        dimension_words[branch_name].append(word)
    
    # Connect to source
    connect_dimensions(source_dimension, branch_name)
    
    # Record branch
    dimension_branches[branch_name] = {
        "source": source_dimension,
        "created": Time.get_unix_time_from_system(),
        "divergence": 0.0
    }
    
    return "Branch created: '" + branch_name + "' from '" + source_dimension + "'"

func get_dimension_info(dimension_name=null):
    if dimension_name == null:
        dimension_name = current_dimension
    
    if not active_dimensions.has(dimension_name):
        return "Dimension '" + dimension_name + "' not found"
    
    var info = "Dimension: " + dimension_name + "\n"
    info += "Type: " + active_dimensions[dimension_name]["type"] + "\n"
    info += "Created: " + str(Time.get_datetime_string_from_unix_time(active_dimensions[dimension_name]["created"])) + "\n"
    info += "Stability: " + str(dimension_stability[dimension_name]["value"] * 100) + "%\n"
    info += "Words: " + str(dimension_words[dimension_name].size()) + "\n"
    
    if active_dimensions[dimension_name]["connections"].size() > 0:
        info += "Connected to: " + ", ".join(active_dimensions[dimension_name]["connections"]) + "\n"
    
    if dimension_branches.has(dimension_name):
        info += "Branch from: " + dimension_branches[dimension_name]["source"] + "\n"
        info += "Divergence: " + str(dimension_branches[dimension_name]["divergence"] * 100) + "%\n"
    
    info += "Coordinates: "
    var coords = dimension_coordinates[dimension_name]
    info += "(" + str(coords["x"]) + "," + str(coords["y"]) + "," + str(coords["z"]) + "," + str(coords["w"]) + "," + str(coords["t"]) + ")\n"
    
    return info

func list_dimensions():
    var result = "Active Dimensions (" + str(active_dimensions.size()) + "):\n"
    
    for dimension_name in active_dimensions:
        var status = " "
        if dimension_name == current_dimension:
            status = "*"
            
        result += status + " " + dimension_name + " (" + active_dimensions[dimension_name]["type"] + ") - "
        result += "Words: " + str(dimension_words[dimension_name].size()) + ", "
        result += "Stability: " + str(int(dimension_stability[dimension_name]["value"] * 100)) + "%\n"
    
    return result

func get_connected_dimensions(dimension_name=null):
    if dimension_name == null:
        dimension_name = current_dimension
    
    if not active_dimensions.has(dimension_name):
        return []
    
    return active_dimensions[dimension_name]["connections"]

func update_dimension_stability():
    # Update stability of all dimensions over time
    for dimension_name in dimension_stability:
        var stability = dimension_stability[dimension_name]
        
        # Calculate time since last update
        var current_time = Time.get_unix_time_from_system()
        var time_diff = current_time - stability["last_update"]
        
        # Only update if significant time has passed
        if time_diff > 60:  # 1 minute
            # Apply random fluctuation
            var fluctuation = randf_range(-stability["fluctuation"], stability["fluctuation"])
            stability["value"] += fluctuation
            
            # Clamp value
            stability["value"] = clamp(stability["value"], 0.1, 1.0)
            
            # Update timestamp
            stability["last_update"] = current_time
            
            # Emit signal
            emit_signal("dimension_property_changed", dimension_name, "stability", stability["value"])

func set_dimension_property(dimension_name, property, value):
    if not active_dimensions.has(dimension_name):
        return "Dimension '" + dimension_name + "' not found"
    
    dimension_properties[dimension_name][property] = value
    
    # Emit signal
    emit_signal("dimension_property_changed", dimension_name, property, value)
    
    return "Property '" + property + "' set to '" + str(value) + "' for dimension '" + dimension_name + "'"

func process_command(args):
    if args.size() == 0:
        return "Dimension Engine. Current dimension: " + current_dimension + "\nUse 'dimension goto', 'dimension create', 'dimension info', 'dimension list'"
    
    match args[0]:
        "goto", "shift":
            if args.size() < 2:
                return "Usage: dimension goto <dimension_name>"
                
            return shift_dimension(args[1])
        "create":
            if args.size() < 2:
                return "Usage: dimension create <dimension_name> [type]"
                
            var dimension_type = "primary"
            if args.size() >= 3:
                dimension_type = args[2]
                
            return create_dimension(args[1], dimension_type)
        "info":
            if args.size() < 2:
                return get_dimension_info()
                
            return get_dimension_info(args[1])
        "list":
            return list_dimensions()
        "connect":
            if args.size() < 3:
                return "Usage: dimension connect <dimension1> <dimension2>"
                
            return connect_dimensions(args[1], args[2])
        "merge":
            if args.size() < 3:
                return "Usage: dimension merge <source_dimension> <target_dimension>"
                
            return merge_dimensions(args[1], args[2])
        "branch":
            if args.size() < 2:
                return "Usage: dimension branch <branch_name> [source_dimension]"
                
            var source_dimension = null
            if args.size() >= 3:
                source_dimension = args[2]
                
            return create_branch(args[1], source_dimension)
        "property":
            if args.size() < 3:
                return "Usage: dimension property <dimension_name> <property> [value]"
                
            if args.size() >= 4:
                return set_dimension_property(args[1], args[2], args[3])
            else:
                var dimension_name = args[1]
                var property = args[2]
                
                if active_dimensions.has(dimension_name) and dimension_properties.has(dimension_name) and dimension_properties[dimension_name].has(property):
                    return "Property '" + property + "' = " + str(dimension_properties[dimension_name][property])
                else:
                    return "Property not found"
        "words":
            if args.size() < 2:
                var words = dimension_words[current_dimension]
                return "Words in dimension '" + current_dimension + "' (" + str(words.size()) + "):\n" + ", ".join(words)
            else:
                var dimension_name = args[1]
                
                if not active_dimensions.has(dimension_name):
                    return "Dimension '" + dimension_name + "' not found"
                    
                var words = dimension_words[dimension_name]
                return "Words in dimension '" + dimension_name + "' (" + str(words.size()) + "):\n" + ", ".join(words)
        "history":
            var count = min(10, dimension_history.size())
            var result = "Dimension Traversal History (last " + str(count) + "):\n"
            
            for i in range(max(0, dimension_history.size() - count), dimension_history.size()):
                var entry = dimension_history[i]
                var timestamp = Time.get_datetime_string_from_unix_time(entry["time"])
                result += timestamp + ": " + entry["from"] + " → " + entry["to"] + "\n"
                
            return result
        "map":
            return generate_dimension_map()
        "stability":
            update_dimension_stability()
            return "Dimension stability updated"
        _:
            return "Unknown dimension command: " + args[0]

func generate_dimension_map():
    var map = "Dimension Map:\n"
    map += "-------------\n"
    
    # Create a visual representation of connections
    var connections_map = {}
    
    for dimension_name in active_dimensions:
        connections_map[dimension_name] = []
        
        for connected in active_dimensions[dimension_name]["connections"]:
            connections_map[dimension_name].append(connected)
    
    # Generate simple ASCII map
    for dimension_name in active_dimensions:
        var prefix = "  "
        if dimension_name == current_dimension:
            prefix = "* "
            
        map += prefix + dimension_name + " → "
        
        if connections_map[dimension_name].size() > 0:
            map += ", ".join(connections_map[dimension_name])
        else:
            map += "(no connections)"
            
        map += "\n"
    
    return map