extends Node

class_name UniversalDataFlow

# Universal Data Flow System
# Manages bidirectional data flow between Terminal, Claude, and game components
# with synchronized shaping of all elements and their negatives/differences

# ----- CONSTANTS -----
const MAX_QUEUE_SIZE = 100
const FLOW_DIRECTIONS = {
    "TERMINAL_TO_CLAUDE": 0,
    "CLAUDE_TO_TERMINAL": 1,
    "CLAUDE_TO_GAME": 2,
    "GAME_TO_CLAUDE": 3,
    "TERMINAL_TO_GAME": 4,
    "GAME_TO_TERMINAL": 5,
    "CIRCULAR": 6,
    "OMNIDIRECTIONAL": 7
}
const FLOW_TYPES = {
    "COMMAND": 0,
    "RESPONSE": 1,
    "DATA": 2,
    "SHAPE": 3,
    "TRANSFORM": 4,
    "NEGATIVE": 5,
    "DIFFERENCE": 6,
    "UNIVERSAL": 7
}
const SHAPE_DIMENSIONS = {
    "SPACE": 0,
    "TIME": 1,
    "FORM": 2,
    "MOTION": 3,
    "MEANING": 4,
    "POTENTIAL": 5,
    "NEGATION": 6,
    "REVERSAL": 7
}

# ----- SYSTEM REFERENCES -----
var terminal_bridge = null
var claude_bridge = null
var spatial_connector = null
var auto_agent = null
var ethereal_bridge = null
var akashic_system = null
var turn_system = null

# ----- DATA STRUCTURES -----
var flow_queues = {}      # Queues for different flow directions
var message_history = []  # Complete history of all messages
var shape_transforms = {} # Record of shape transformations
var universal_shapes = {} # Shapes that affect all elements
var negative_maps = {}    # Map of elements to their negatives
var difference_matrices = {} # Matrices of differences between elements

# ----- STATE TRACKING -----
var active_flows = []
var paused_flows = []
var shape_operations = {}
var simultaneous_mode = false
var negative_mode = false
var difference_mode = false

# ----- SIGNALS -----
signal data_flowed(direction, data_type, content)
signal shapes_transformed(shape_id, elements_count)
signal negatives_generated(elements_count)
signal differences_calculated(matrix_size)
signal universal_flow_completed(flow_id, affected_count)
signal simultaneous_mode_changed(enabled)

# ----- INITIALIZATION -----
func _ready():
    print("Initializing Universal Data Flow system...")
    
    # Connect to required systems
    _connect_systems()
    
    # Initialize queues
    _initialize_queues()
    
    # Set up universal shapes
    _initialize_universal_shapes()
    
    print("Universal Data Flow system initialized")

func _connect_systems():
    # Connect to Terminal API Bridge
    terminal_bridge = get_node_or_null("/root/TerminalAPIBridge")
    if terminal_bridge:
        terminal_bridge.connect("data_received", self, "_on_terminal_data_received")
    
    # Connect to Claude Bridge
    claude_bridge = get_node_or_null("/root/ClaudeAkashicBridge")
    if not claude_bridge:
        claude_bridge = get_node_or_null("/root/ClaudeEtherealBridge")
    
    # Connect to Spatial Linguistic Connector
    spatial_connector = get_node_or_null("/root/SpatialLinguisticConnector")
    if spatial_connector:
        spatial_connector.connect("linguistic_mapped", self, "_on_linguistic_mapped")
        spatial_connector.connect("spatial_structured", self, "_on_spatial_structured")
    
    # Connect to Auto Agent Mode
    auto_agent = get_node_or_null("/root/AutoAgentMode")
    if auto_agent:
        auto_agent.connect("transform_applied", self, "_on_transform_applied")
    
    # Connect to Ethereal Bridge
    ethereal_bridge = get_node_or_null("/root/EtherealAkashicBridge")
    
    # Connect to Akashic System
    akashic_system = get_node_or_null("/root/AkashicNumberSystem")
    
    # Connect to Turn System
    turn_system = get_node_or_null("/root/TurnSystem")
    if turn_system:
        turn_system.connect("turn_advanced", self, "_on_turn_advanced")

func _initialize_queues():
    # Create a queue for each flow direction
    for direction in FLOW_DIRECTIONS.values():
        flow_queues[direction] = []
    
    # Add all flows to active flows
    for direction in FLOW_DIRECTIONS.values():
        active_flows.append(direction)

func _initialize_universal_shapes():
    # Create basic universal shapes that affect all elements
    universal_shapes = {
        "sphere": {
            "dimensions": {
                SHAPE_DIMENSIONS.SPACE: 1.0,
                SHAPE_DIMENSIONS.TIME: 0.5,
                SHAPE_DIMENSIONS.FORM: 0.8,
                SHAPE_DIMENSIONS.MOTION: 0.3
            },
            "affects_all": true,
            "has_negative": true
        },
        "cube": {
            "dimensions": {
                SHAPE_DIMENSIONS.SPACE: 1.0,
                SHAPE_DIMENSIONS.TIME: 0.2,
                SHAPE_DIMENSIONS.FORM: 1.0,
                SHAPE_DIMENSIONS.MOTION: 0.1
            },
            "affects_all": true,
            "has_negative": true
        },
        "spiral": {
            "dimensions": {
                SHAPE_DIMENSIONS.SPACE: 0.7,
                SHAPE_DIMENSIONS.TIME: 0.9,
                SHAPE_DIMENSIONS.FORM: 0.6,
                SHAPE_DIMENSIONS.MOTION: 0.8
            },
            "affects_all": true,
            "has_negative": true
        },
        "wave": {
            "dimensions": {
                SHAPE_DIMENSIONS.SPACE: 0.5,
                SHAPE_DIMENSIONS.TIME: 1.0,
                SHAPE_DIMENSIONS.FORM: 0.4,
                SHAPE_DIMENSIONS.MOTION: 1.0
            },
            "affects_all": true,
            "has_negative": true
        }
    }
    
    # Generate negative shapes
    for shape_name in universal_shapes:
        var shape = universal_shapes[shape_name]
        if shape.has_negative:
            var negative_name = "negative_" + shape_name
            var negative_shape = {
                "dimensions": {},
                "affects_all": shape.affects_all,
                "has_negative": false,
                "is_negative_of": shape_name
            }
            
            # Create inverse dimensions
            for dimension in shape.dimensions:
                negative_shape.dimensions[dimension] = 1.0 - shape.dimensions[dimension]
            
            # Add negative shape to universal shapes
            universal_shapes[negative_name] = negative_shape
            
            # Map to negative_maps
            negative_maps[shape_name] = negative_name
            negative_maps[negative_name] = shape_name

# ----- QUEUING LOGIC -----
func queue_data(direction, data_type, content, metadata=null):
    if not flow_queues.has(direction):
        push_error("Invalid flow direction: " + str(direction))
        return null
    
    if direction in paused_flows:
        print("Flow direction " + str(direction) + " is paused, data not queued")
        return null
    
    # Create flow data structure
    var flow_data = {
        "id": str(OS.get_unix_time()) + "_" + str(data_type) + "_" + str(randi() % 1000),
        "direction": direction,
        "type": data_type,
        "content": content,
        "metadata": metadata if metadata else {},
        "timestamp": OS.get_unix_time(),
        "processed": false,
        "transformed": false,
        "has_negative": false,
        "has_difference": false
    }
    
    # Add to queue
    flow_queues[direction].append(flow_data)
    
    # Trim queue if needed
    if flow_queues[direction].size() > MAX_QUEUE_SIZE:
        flow_queues[direction].pop_front()
    
    # Add to history
    message_history.append(flow_data)
    
    # If in simultaneous mode, process all flows now
    if simultaneous_mode:
        _process_all_queues()
    
    return flow_data.id

func pause_flow(direction):
    if not direction in paused_flows:
        paused_flows.append(direction)
        return true
    return false

func resume_flow(direction):
    if direction in paused_flows:
        paused_flows.erase(direction)
        return true
    return false

func clear_queue(direction):
    if not flow_queues.has(direction):
        return false
    
    flow_queues[direction].clear()
    return true

# ----- PROCESSING LOGIC -----
func _process(delta):
    # Process one item from each active queue
    for direction in active_flows:
        if direction in paused_flows:
            continue
        
        if flow_queues.has(direction) and flow_queues[direction].size() > 0:
            _process_flow_item(flow_queues[direction][0])
            flow_queues[direction].pop_front()

func _process_flow_item(flow_data):
    if flow_data.processed:
        return
    
    # Mark as processed
    flow_data.processed = true
    
    # Route data based on direction and type
    match flow_data.direction:
        FLOW_DIRECTIONS.TERMINAL_TO_CLAUDE:
            _route_terminal_to_claude(flow_data)
        
        FLOW_DIRECTIONS.CLAUDE_TO_TERMINAL:
            _route_claude_to_terminal(flow_data)
        
        FLOW_DIRECTIONS.CLAUDE_TO_GAME:
            _route_claude_to_game(flow_data)
        
        FLOW_DIRECTIONS.GAME_TO_CLAUDE:
            _route_game_to_claude(flow_data)
        
        FLOW_DIRECTIONS.TERMINAL_TO_GAME:
            _route_terminal_to_game(flow_data)
        
        FLOW_DIRECTIONS.GAME_TO_TERMINAL:
            _route_game_to_terminal(flow_data)
        
        FLOW_DIRECTIONS.CIRCULAR:
            _route_circular(flow_data)
        
        FLOW_DIRECTIONS.OMNIDIRECTIONAL:
            _route_omnidirectional(flow_data)
    
    # Apply shape transformations if needed
    if not flow_data.transformed:
        _apply_shape_transformations(flow_data)
    
    # Generate negatives if in negative mode
    if negative_mode and not flow_data.has_negative:
        _generate_negative(flow_data)
    
    # Calculate differences if in difference mode
    if difference_mode and not flow_data.has_difference:
        _calculate_differences(flow_data)
    
    # Emit signal
    emit_signal("data_flowed", flow_data.direction, flow_data.type, flow_data.content)

func _process_all_queues():
    # Process all queues at once in simultaneous mode
    var items_processed = 0
    
    # Gather all items
    var all_items = []
    for direction in flow_queues:
        for item in flow_queues[direction]:
            all_items.append(item)
    
    # Process each item
    for item in all_items:
        _process_flow_item(item)
        items_processed += 1
    
    # Clear all queues
    for direction in flow_queues:
        flow_queues[direction].clear()
    
    print("Processed " + str(items_processed) + " items simultaneously")
    return items_processed

# ----- ROUTING LOGIC -----
func _route_terminal_to_claude(flow_data):
    if not claude_bridge:
        return
    
    match flow_data.type:
        FLOW_TYPES.COMMAND:
            # Forward terminal command to Claude
            if claude_bridge.has_method("process_command"):
                claude_bridge.process_command(flow_data.content)
            elif claude_bridge.has_method("handle_command"):
                claude_bridge.handle_command(flow_data.content)
        
        FLOW_TYPES.DATA:
            # Forward data to Claude
            if claude_bridge.has_method("receive_data"):
                claude_bridge.receive_data(flow_data.content)
        
        FLOW_TYPES.SHAPE:
            # Apply shape information to Claude connection
            if flow_data.content is String and universal_shapes.has(flow_data.content):
                if claude_bridge.has_method("apply_shape"):
                    claude_bridge.apply_shape(flow_data.content, universal_shapes[flow_data.content])

func _route_claude_to_terminal(flow_data):
    if not terminal_bridge:
        return
    
    match flow_data.type:
        FLOW_TYPES.RESPONSE:
            # Forward Claude response to terminal
            if terminal_bridge.has_method("process_api_response"):
                var data = {"response": flow_data.content}
                if flow_data.metadata and flow_data.metadata.has("api_name"):
                    terminal_bridge._process_api_response(flow_data.metadata.api_name, {}, data)
        
        FLOW_TYPES.DATA:
            # Forward data to terminal
            if terminal_bridge.has_method("send_data") and flow_data.metadata and flow_data.metadata.has("api_name"):
                terminal_bridge.send_data(
                    flow_data.metadata.api_name,
                    "/data",
                    flow_data.content
                )
        
        FLOW_TYPES.SHAPE:
            # Shape information doesn't directly route to terminal but affects visualization
            if terminal_bridge.has_method("update_visualization") and flow_data.content is String:
                terminal_bridge.update_visualization(flow_data.content)

func _route_claude_to_game(flow_data):
    match flow_data.type:
        FLOW_TYPES.COMMAND:
            # Execute game commands from Claude
            if auto_agent and auto_agent.has_method("process_command"):
                auto_agent.process_command(flow_data.content, "claude")
            elif spatial_connector and spatial_connector.has_method("translate_command"):
                spatial_connector.translate_command(flow_data.content)
        
        FLOW_TYPES.DATA:
            # Forward data to game systems
            if spatial_connector and spatial_connector.has_method("process_data"):
                spatial_connector.process_data(flow_data.content)
        
        FLOW_TYPES.SHAPE:
            # Apply shape to game elements
            if flow_data.content is String and spatial_connector and spatial_connector.has_method("apply_shape"):
                spatial_connector.apply_shape(flow_data.content)

func _route_game_to_claude(flow_data):
    if not claude_bridge:
        return
    
    match flow_data.type:
        FLOW_TYPES.DATA:
            # Send game data to Claude
            if claude_bridge.has_method("receive_data"):
                claude_bridge.receive_data(flow_data.content)
        
        FLOW_TYPES.SHAPE:
            # Send shape information to Claude
            if flow_data.content is String and claude_bridge.has_method("apply_shape"):
                claude_bridge.apply_shape(flow_data.content)

func _route_terminal_to_game(flow_data):
    match flow_data.type:
        FLOW_TYPES.COMMAND:
            # Forward terminal command to game
            if auto_agent and auto_agent.has_method("process_command"):
                auto_agent.process_command(flow_data.content, "terminal")
            elif spatial_connector and spatial_connector.has_method("translate_command"):
                spatial_connector.translate_command(flow_data.content)
        
        FLOW_TYPES.DATA:
            # Forward data to game
            if spatial_connector and spatial_connector.has_method("process_data"):
                spatial_connector.process_data(flow_data.content)
        
        FLOW_TYPES.SHAPE:
            # Apply shape to game elements
            if flow_data.content is String and spatial_connector and spatial_connector.has_method("apply_shape"):
                spatial_connector.apply_shape(flow_data.content)

func _route_game_to_terminal(flow_data):
    if not terminal_bridge:
        return
    
    match flow_data.type:
        FLOW_TYPES.RESPONSE:
            # Send game response to terminal
            if terminal_bridge.has_method("process_response"):
                terminal_bridge.process_response(flow_data.content)
        
        FLOW_TYPES.DATA:
            # Send game data to terminal
            if terminal_bridge.has_method("send_data") and flow_data.metadata and flow_data.metadata.has("api_name"):
                terminal_bridge.send_data(
                    flow_data.metadata.api_name,
                    "/game_data",
                    flow_data.content
                )

func _route_circular(flow_data):
    # Circular routes through all three systems in sequence
    match flow_data.type:
        FLOW_TYPES.COMMAND, FLOW_TYPES.DATA:
            # Terminal -> Claude -> Game -> Terminal
            if flow_data.metadata and flow_data.metadata.has("stage"):
                match flow_data.metadata.stage:
                    0: # Terminal to Claude
                        flow_data.metadata.stage = 1
                        _route_terminal_to_claude(flow_data)
                    
                    1: # Claude to Game
                        flow_data.metadata.stage = 2
                        _route_claude_to_game(flow_data)
                    
                    2: # Game to Terminal
                        flow_data.metadata.stage = 3
                        _route_game_to_terminal(flow_data)
                    
                    3: # Complete
                        flow_data.metadata.stage = 4
                        emit_signal("universal_flow_completed", flow_data.id, 3)
            else:
                # Start at terminal
                flow_data.metadata = {"stage": 0}
                _route_circular(flow_data)
        
        FLOW_TYPES.SHAPE:
            # Shapes affect all systems
            if flow_data.content is String:
                # Apply to all systems simultaneously
                _route_terminal_to_claude(flow_data)
                _route_claude_to_game(flow_data)
                _route_game_to_terminal(flow_data)

func _route_omnidirectional(flow_data):
    # Send to all systems simultaneously
    _route_terminal_to_claude(flow_data)
    _route_claude_to_terminal(flow_data)
    _route_claude_to_game(flow_data)
    _route_game_to_claude(flow_data)
    _route_terminal_to_game(flow_data)
    _route_game_to_terminal(flow_data)
    
    emit_signal("universal_flow_completed", flow_data.id, 6)

# ----- SHAPE TRANSFORMATION -----
func _apply_shape_transformations(flow_data):
    # Skip if already transformed
    if flow_data.transformed:
        return
    
    # Apply universal shape transformations to the data
    for shape_name in universal_shapes:
        var shape = universal_shapes[shape_name]
        
        # Only apply active shape operations
        if shape_operations.has(shape_name) and shape_operations[shape_name].active:
            var operation = shape_operations[shape_name]
            
            # Transform the content based on shape
            if operation.has_method("transform"):
                flow_data.content = operation.transform(flow_data.content, shape)
            else:
                # Default transformation based on shape dimensions
                flow_data.content = _default_shape_transform(flow_data.content, shape)
            
            # Record the transformation
            if not shape_transforms.has(shape_name):
                shape_transforms[shape_name] = []
            
            shape_transforms[shape_name].append({
                "flow_id": flow_data.id,
                "timestamp": OS.get_unix_time(),
                "content": flow_data.content
            })
    
    flow_data.transformed = true
    
    # Emit signal if we have at least one shape
    if universal_shapes.size() > 0:
        emit_signal("shapes_transformed", flow_data.id, universal_shapes.size())

func _default_shape_transform(content, shape):
    # Apply basic transformations based on shape dimensions
    if content is String:
        # Text transformations
        var transformed = content
        
        # Space dimension affects layout
        if shape.dimensions.has(SHAPE_DIMENSIONS.SPACE) and shape.dimensions[SHAPE_DIMENSIONS.SPACE] > 0.7:
            # Add spacing for high space dimension
            transformed = transformed.replace(" ", "  ")
        
        # Time dimension affects ordering
        if shape.dimensions.has(SHAPE_DIMENSIONS.TIME) and shape.dimensions[SHAPE_DIMENSIONS.TIME] > 0.7:
            # Reverse for high time dimension (reverses flow of time)
            var words = transformed.split(" ")
            words.invert()
            transformed = words.join(" ")
        
        # Form dimension affects capitalization
        if shape.dimensions.has(SHAPE_DIMENSIONS.FORM) and shape.dimensions[SHAPE_DIMENSIONS.FORM] > 0.7:
            # Capitalize for high form dimension
            transformed = transformed.capitalize()
        
        # Motion dimension affects repetition
        if shape.dimensions.has(SHAPE_DIMENSIONS.MOTION) and shape.dimensions[SHAPE_DIMENSIONS.MOTION] > 0.7:
            # Repeat some elements for high motion
            var words = transformed.split(" ")
            var repeated = []
            for word in words:
                repeated.append(word)
                if randf() < 0.3:  # 30% chance to repeat
                    repeated.append(word)
            transformed = repeated.join(" ")
        
        return transformed
    elif content is Dictionary:
        # Dictionary transformations - modify values
        var transformed = content.duplicate()
        
        for key in transformed:
            if transformed[key] is String:
                transformed[key] = _default_shape_transform(transformed[key], shape)
        
        return transformed
    elif content is Array:
        # Array transformations - modify elements
        var transformed = content.duplicate()
        
        for i in range(transformed.size()):
            if transformed[i] is String:
                transformed[i] = _default_shape_transform(transformed[i], shape)
        
        # Space dimension affects array layout
        if shape.dimensions.has(SHAPE_DIMENSIONS.SPACE) and shape.dimensions[SHAPE_DIMENSIONS.SPACE] > 0.8:
            # Spread out array (add nulls between items)
            var spread = []
            for item in transformed:
                spread.append(item)
                if randf() < 0.3:  # 30% chance to add space
                    spread.append(null)
            transformed = spread
        
        # Time dimension affects ordering
        if shape.dimensions.has(SHAPE_DIMENSIONS.TIME) and shape.dimensions[SHAPE_DIMENSIONS.TIME] > 0.7:
            # Reverse for high time dimension
            transformed.invert()
        
        return transformed
    
    # Default - return unchanged if not a supported type
    return content

# ----- NEGATIVES AND DIFFERENCES -----
func _generate_negative(flow_data):
    # Skip if already has negative
    if flow_data.has_negative:
        return
    
    # Create a negative version of the data
    var negative_data = flow_data.duplicate()
    negative_data.id = "negative_" + flow_data.id
    negative_data.has_negative = true
    
    # Generate negative content
    if flow_data.content is String:
        negative_data.content = _generate_negative_text(flow_data.content)
    elif flow_data.content is Dictionary:
        negative_data.content = _generate_negative_dictionary(flow_data.content)
    elif flow_data.content is Array:
        negative_data.content = _generate_negative_array(flow_data.content)
    
    # Store mapping
    negative_maps[flow_data.id] = negative_data.id
    negative_maps[negative_data.id] = flow_data.id
    
    # Mark original as having a negative
    flow_data.has_negative = true
    
    # Add to history
    message_history.append(negative_data)
    
    # Add to appropriate queue with inverse direction
    var inverse_direction = _get_inverse_direction(flow_data.direction)
    if flow_queues.has(inverse_direction):
        flow_queues[inverse_direction].append(negative_data)
    
    emit_signal("negatives_generated", 1)

func _generate_negative_text(text):
    # Simple negative: reverse and change case
    var negative = ""
    
    # Reverse the string
    for i in range(text.length() - 1, -1, -1):
        var char = text[i]
        
        # Swap case
        if char.to_upper() == char:
            negative += char.to_lower()
        else:
            negative += char.to_upper()
    
    return negative

func _generate_negative_dictionary(dict):
    var negative = {}
    
    # Invert keys and values where possible
    for key in dict:
        var value = dict[key]
        
        if value is String:
            negative[key] = _generate_negative_text(value)
        elif value is int or value is float:
            negative[key] = -value
        elif value is bool:
            negative[key] = !value
        else:
            # Unchanged for complex types
            negative[key] = value
    
    return negative

func _generate_negative_array(arr):
    var negative = []
    
    # Reverse the array and transform elements
    for i in range(arr.size() - 1, -1, -1):
        var item = arr[i]
        
        if item is String:
            negative.append(_generate_negative_text(item))
        elif item is int or item is float:
            negative.append(-item)
        elif item is bool:
            negative.append(!item)
        else:
            # Unchanged for complex types
            negative.append(item)
    
    return negative

func _get_inverse_direction(direction):
    match direction:
        FLOW_DIRECTIONS.TERMINAL_TO_CLAUDE:
            return FLOW_DIRECTIONS.CLAUDE_TO_TERMINAL
        FLOW_DIRECTIONS.CLAUDE_TO_TERMINAL:
            return FLOW_DIRECTIONS.TERMINAL_TO_CLAUDE
        FLOW_DIRECTIONS.CLAUDE_TO_GAME:
            return FLOW_DIRECTIONS.GAME_TO_CLAUDE
        FLOW_DIRECTIONS.GAME_TO_CLAUDE:
            return FLOW_DIRECTIONS.CLAUDE_TO_GAME
        FLOW_DIRECTIONS.TERMINAL_TO_GAME:
            return FLOW_DIRECTIONS.GAME_TO_TERMINAL
        FLOW_DIRECTIONS.GAME_TO_TERMINAL:
            return FLOW_DIRECTIONS.TERMINAL_TO_GAME
        FLOW_DIRECTIONS.CIRCULAR:
            return FLOW_DIRECTIONS.CIRCULAR
        FLOW_DIRECTIONS.OMNIDIRECTIONAL:
            return FLOW_DIRECTIONS.OMNIDIRECTIONAL
    
    return direction

func _calculate_differences(flow_data):
    # Skip if already has differences
    if flow_data.has_difference:
        return
    
    # Find related items to calculate differences with
    var related_items = []
    
    # Get last 5 items from history (excluding this one)
    var start_idx = max(0, message_history.size() - 6)
    for i in range(start_idx, message_history.size()):
        if message_history[i].id != flow_data.id:
            related_items.append(message_history[i])
    
    # Calculate differences for up to 3 items
    var differences = {}
    for i in range(min(3, related_items.size())):
        var item = related_items[i]
        var diff_id = "diff_" + flow_data.id + "_" + item.id
        
        differences[diff_id] = {
            "source_id": flow_data.id,
            "target_id": item.id,
            "timestamp": OS.get_unix_time(),
            "difference": _calculate_difference(flow_data.content, item.content)
        }
    
    # Store in difference matrices
    if differences.size() > 0:
        difference_matrices[flow_data.id] = differences
        flow_data.has_difference = true
        
        emit_signal("differences_calculated", differences.size())

func _calculate_difference(a, b):
    # Calculate difference between two values
    if a is String and b is String:
        return _calculate_text_difference(a, b)
    elif (a is int or a is float) and (b is int or b is float):
        return a - b
    elif a is Dictionary and b is Dictionary:
        return _calculate_dict_difference(a, b)
    elif a is Array and b is Array:
        return _calculate_array_difference(a, b)
    
    # Default: cannot calculate difference
    return null

func _calculate_text_difference(a, b):
    # Simple difference: identify what's in a but not in b, and vice versa
    var in_a_not_b = ""
    var in_b_not_a = ""
    
    # Words in a not in b
    var a_words = a.split(" ")
    var b_words = b.split(" ")
    
    for word in a_words:
        if not word in b_words:
            in_a_not_b += word + " "
    
    for word in b_words:
        if not word in a_words:
            in_b_not_a += word + " "
    
    return {
        "unique_to_a": in_a_not_b.strip_edges(),
        "unique_to_b": in_b_not_a.strip_edges(),
        "length_diff": a.length() - b.length()
    }

func _calculate_dict_difference(a, b):
    var difference = {
        "keys_only_in_a": [],
        "keys_only_in_b": [],
        "value_differences": {}
    }
    
    # Keys only in a
    for key in a:
        if not b.has(key):
            difference.keys_only_in_a.append(key)
    
    # Keys only in b
    for key in b:
        if not a.has(key):
            difference.keys_only_in_b.append(key)
    
    # Value differences for common keys
    for key in a:
        if b.has(key) and a[key] != b[key]:
            difference.value_differences[key] = {
                "a_value": a[key],
                "b_value": b[key]
            }
    
    return difference

func _calculate_array_difference(a, b):
    var difference = {
        "items_only_in_a": [],
        "items_only_in_b": [],
        "length_diff": a.size() - b.size(),
        "position_differences": []
    }
    
    # Find items only in a
    for item in a:
        if not b.has(item):
            difference.items_only_in_a.append(item)
    
    # Find items only in b
    for item in b:
        if not a.has(item):
            difference.items_only_in_b.append(item)
    
    # Find position differences for common items
    var common_items = []
    for item in a:
        if b.has(item):
            common_items.append(item)
    
    for item in common_items:
        var a_index = a.find(item)
        var b_index = b.find(item)
        
        if a_index != b_index:
            difference.position_differences.append({
                "item": item,
                "a_position": a_index,
                "b_position": b_index,
                "position_diff": a_index - b_index
            })
    
    return difference

# ----- EVENT HANDLERS -----
func _on_terminal_data_received(api_name, data):
    # Queue data from terminal to appropriate destinations
    if data.has("type") and data.has("content"):
        var metadata = {"api_name": api_name}
        var type = FLOW_TYPES.DATA
        
        # Determine data type
        if data.type == "command":
            type = FLOW_TYPES.COMMAND
        elif data.type == "shape":
            type = FLOW_TYPES.SHAPE
        
        # Queue to Claude
        queue_data(FLOW_DIRECTIONS.TERMINAL_TO_CLAUDE, type, data.content, metadata)
        
        # Also queue to game if appropriate
        if type == FLOW_TYPES.COMMAND or type == FLOW_TYPES.SHAPE:
            queue_data(FLOW_DIRECTIONS.TERMINAL_TO_GAME, type, data.content, metadata)

func _on_linguistic_mapped(word, space_type, coordinates):
    # When words are mapped spatially, update data flow
    var data = {
        "word": word,
        "space_type": space_type,
        "coordinates": coordinates
    }
    
    # Queue to Claude
    queue_data(FLOW_DIRECTIONS.GAME_TO_CLAUDE, FLOW_TYPES.DATA, data)
    
    # Also queue to terminal
    queue_data(FLOW_DIRECTIONS.GAME_TO_TERMINAL, FLOW_TYPES.DATA, data)

func _on_spatial_structured(structure_id, shape_type, boundaries):
    # When spatial structures are created, send shape information
    var data = {
        "structure_id": structure_id,
        "shape": shape_type,
        "boundaries": boundaries
    }
    
    # Queue as shape to all directions
    queue_data(FLOW_DIRECTIONS.OMNIDIRECTIONAL, FLOW_TYPES.SHAPE, data)

func _on_transform_applied(word, action, result):
    # When transformations are applied, update data flow
    var data = {
        "word": word,
        "action": action,
        "result": result
    }
    
    # Queue to all systems
    queue_data(FLOW_DIRECTIONS.OMNIDIRECTIONAL, FLOW_TYPES.TRANSFORM, data)

func _on_turn_advanced(old_turn, new_turn):
    # When turn advances, update flow operations
    if (new_turn % 3) == 0:
        # Every third turn, toggle simultaneous mode
        set_simultaneous_mode(!simultaneous_mode)
    
    if (new_turn % 4) == 0:
        # Every fourth turn, toggle negative mode
        set_negative_mode(!negative_mode)
    
    if (new_turn % 6) == 0:
        # Every sixth turn, toggle difference mode
        set_difference_mode(!difference_mode)

# ----- PUBLIC API -----
func set_simultaneous_mode(enabled):
    simultaneous_mode = enabled
    emit_signal("simultaneous_mode_changed", enabled)
    
    print("Simultaneous mode " + ("enabled" if enabled else "disabled"))
    
    # If enabling, process all queues now
    if enabled:
        _process_all_queues()
    
    return simultaneous_mode

func set_negative_mode(enabled):
    negative_mode = enabled
    
    print("Negative mode " + ("enabled" if enabled else "disabled"))
    
    # If enabling, generate negatives for recent history
    if enabled:
        var processed = 0
        for i in range(max(0, message_history.size() - 10), message_history.size()):
            if not message_history[i].has_negative:
                _generate_negative(message_history[i])
                processed += 1
        
        emit_signal("negatives_generated", processed)
    
    return negative_mode

func set_difference_mode(enabled):
    difference_mode = enabled
    
    print("Difference mode " + ("enabled" if enabled else "disabled"))
    
    # If enabling, calculate differences for recent history
    if enabled:
        var processed = 0
        for i in range(max(0, message_history.size() - 10), message_history.size()):
            if not message_history[i].has_difference:
                _calculate_differences(message_history[i])
                processed += 1
    
    return difference_mode

func register_shape_operation(shape_name, operation):
    # Register a custom operation for a shape
    shape_operations[shape_name] = operation
    
    # Create shape if it doesn't exist
    if not universal_shapes.has(shape_name):
        universal_shapes[shape_name] = {
            "dimensions": {
                SHAPE_DIMENSIONS.SPACE: 0.5,
                SHAPE_DIMENSIONS.TIME: 0.5,
                SHAPE_DIMENSIONS.FORM: 0.5,
                SHAPE_DIMENSIONS.MOTION: 0.5
            },
            "affects_all": true,
            "has_negative": true
        }
    
    return shape_operations.has(shape_name)

func create_universal_shape(shape_name, dimensions):
    # Create a new universal shape
    universal_shapes[shape_name] = {
        "dimensions": dimensions,
        "affects_all": true,
        "has_negative": true
    }
    
    # Generate its negative automatically
    var negative_name = "negative_" + shape_name
    var negative_dimensions = {}
    
    for dimension in dimensions:
        negative_dimensions[dimension] = 1.0 - dimensions[dimension]
    
    universal_shapes[negative_name] = {
        "dimensions": negative_dimensions,
        "affects_all": true,
        "has_negative": false,
        "is_negative_of": shape_name
    }
    
    # Add to negatives map
    negative_maps[shape_name] = negative_name
    negative_maps[negative_name] = shape_name
    
    return shape_name

func get_message_history():
    return message_history

func get_negative_pairs():
    return negative_maps

func get_difference_matrices():
    return difference_matrices

func get_active_shapes():
    return universal_shapes

func send_to_all(content, type=FLOW_TYPES.DATA):
    return queue_data(FLOW_DIRECTIONS.OMNIDIRECTIONAL, type, content)

func get_flow_statistics():
    var stats = {
        "active_flows": active_flows.size(),
        "paused_flows": paused_flows.size(),
        "total_messages": message_history.size(),
        "shapes": universal_shapes.size(),
        "negatives": negative_maps.size() / 2,  # Each pair counts as 1
        "difference_matrices": difference_matrices.size(),
        "simultaneous_mode": simultaneous_mode,
        "negative_mode": negative_mode,
        "difference_mode": difference_mode,
        "queue_sizes": {}
    }
    
    # Get queue sizes
    for direction in flow_queues:
        stats.queue_sizes[direction] = flow_queues[direction].size()
    
    return stats

func clear_all_queues():
    for direction in flow_queues:
        flow_queues[direction].clear()
    
    return true

# ----- UTILITY CLASSES -----
class ShapeTransformer:
    var shape_name
    var transform_rules
    
    func _init(name, rules=null):
        shape_name = name
        transform_rules = rules if rules else {}
    
    func transform(content, shape):
        # Apply transformation based on content type
        if content is String:
            return _transform_text(content, shape)
        elif content is Dictionary:
            return _transform_dict(content, shape)
        elif content is Array:
            return _transform_array(content, shape)
        
        # Default: return unchanged
        return content
    
    func _transform_text(text, shape):
        # Apply text transformations based on shape
        var transformed = text
        
        # Check transformation rules
        if transform_rules.has("text_transform"):
            var rule = transform_rules.text_transform
            
            if rule == "uppercase":
                transformed = transformed.to_upper()
            elif rule == "lowercase":
                transformed = transformed.to_lower()
            elif rule == "reverse":
                transformed = _reverse_string(transformed)
            elif rule == "randomize":
                transformed = _randomize_words(transformed)
        
        return transformed
    
    func _transform_dict(dict, shape):
        # Apply dictionary transformations
        var transformed = dict.duplicate()
        
        # Apply rules to each value
        for key in transformed:
            if transformed[key] is String:
                transformed[key] = _transform_text(transformed[key], shape)
        
        return transformed
    
    func _transform_array(arr, shape):
        # Apply array transformations
        var transformed = arr.duplicate()
        
        # Transform each element
        for i in range(transformed.size()):
            if transformed[i] is String:
                transformed[i] = _transform_text(transformed[i], shape)
        
        # Check array-specific rules
        if transform_rules.has("array_transform"):
            var rule = transform_rules.array_transform
            
            if rule == "reverse":
                transformed.invert()
            elif rule == "shuffle":
                transformed.shuffle()
        
        return transformed
    
    func _reverse_string(text):
        var reversed = ""
        for i in range(text.length() - 1, -1, -1):
            reversed += text[i]
        return reversed
    
    func _randomize_words(text):
        var words = text.split(" ")
        words.shuffle()
        return words.join(" ")

class DifferenceCalculator:
    func calculate(a, b):
        # Calculate difference between two values
        if a is String and b is String:
            return _text_difference(a, b)
        elif a is Dictionary and b is Dictionary:
            return _dict_difference(a, b)
        elif a is Array and b is Array:
            return _array_difference(a, b)
        elif (a is int or a is float) and (b is int or b is float):
            return a - b
        
        # Cannot calculate difference
        return null
    
    func _text_difference(a, b):
        # LCS-based difference
        var lcs = _longest_common_subsequence(a, b)
        
        return {
            "lcs_length": lcs.length(),
            "a_unique": a.length() - lcs.length(),
            "b_unique": b.length() - lcs.length(),
            "similarity": float(lcs.length()) / max(a.length(), b.length())
        }
    
    func _dict_difference(a, b):
        var result = {
            "keys_only_in_a": [],
            "keys_only_in_b": [],
            "different_values": {},
            "similarity": 0.0
        }
        
        # Keys only in a
        for key in a:
            if not b.has(key):
                result.keys_only_in_a.append(key)
        
        # Keys only in b
        for key in b:
            if not a.has(key):
                result.keys_only_in_b.append(key)
        
        # Different values
        for key in a:
            if b.has(key) and a[key] != b[key]:
                result.different_values[key] = {
                    "a_value": a[key],
                    "b_value": b[key]
                }
        
        # Calculate similarity
        var total_keys = a.size() + b.size()
        var common_keys = a.size() - result.keys_only_in_a.size()
        
        if total_keys > 0:
            result.similarity = float(2 * common_keys) / total_keys
        
        return result
    
    func _array_difference(a, b):
        var result = {
            "items_only_in_a": [],
            "items_only_in_b": [],
            "similarity": 0.0
        }
        
        # Items only in a
        for item in a:
            if not b.has(item):
                result.items_only_in_a.append(item)
        
        # Items only in b
        for item in b:
            if not a.has(item):
                result.items_only_in_b.append(item)
        
        # Calculate similarity
        var total_items = a.size() + b.size()
        var common_items = a.size() - result.items_only_in_a.size()
        
        if total_items > 0:
            result.similarity = float(2 * common_items) / total_items
        
        return result
    
    func _longest_common_subsequence(a, b):
        var m = a.length()
        var n = b.length()
        var L = []
        
        # Initialize 2D array
        for i in range(m + 1):
            var row = []
            for j in range(n + 1):
                row.append(0)
            L.append(row)
        
        # Build the DP table
        for i in range(1, m + 1):
            for j in range(1, n + 1):
                if a[i-1] == b[j-1]:
                    L[i][j] = L[i-1][j-1] + 1
                else:
                    L[i][j] = max(L[i-1][j], L[i][j-1])
        
        # Reconstruct the LCS
        var lcs = ""
        var i = m
        var j = n
        
        while i > 0 and j > 0:
            if a[i-1] == b[j-1]:
                lcs = a[i-1] + lcs
                i -= 1
                j -= 1
            elif L[i-1][j] > L[i][j-1]:
                i -= 1
            else:
                j -= 1
        
        return lcs