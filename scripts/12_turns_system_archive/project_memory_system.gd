extends Node

class_name ProjectMemorySystem

# Project Memory System with dynamic color shifting and terminal overlay

# Color constants
const COLOR_LIGHT_BLUE = Color(0.5, 0.7, 0.9, 0.9)
const COLOR_EVE_BLUE = Color(0.4, 0.6, 0.9, 0.8)
const COLOR_SHIFT_BLUE = Color(0.3, 0.5, 0.8, 0.7)
const COLOR_DEEP_BLUE = Color(0.2, 0.4, 0.7, 0.9)
const COLOR_ETHEREAL_BLUE = Color(0.6, 0.8, 0.95, 0.8)

# Memory structures
var memory_banks = {}
var active_memories = []
var memory_connections = {}
var forgotten_memories = []
var shifting_patterns = {}
var color_state = "light_blue"
var color_transition_active = false
var terminal_overlay_visible = true
var current_memory_focus = ""
var memory_paths = []
var memory_shift_frequency = 3.6 # seconds
var project_hash_id = ""

# Memory categories
var categories = [
    "project_structure",
    "interaction_patterns", 
    "visual_elements",
    "data_connections",
    "terminal_commands",
    "color_schemes",
    "overlay_settings",
    "user_preferences",
    "dimension_rules",
    "evolution_paths"
]

# Terminal overlay properties
var overlay_opacity = 0.8
var overlay_dimensions = Vector2(800, 600)
var overlay_position = Vector2(0, 0)
var overlay_color = COLOR_LIGHT_BLUE
var overlay_border_size = 2
var overlay_border_color = Color(1, 1, 1, 0.5)
var overlay_text_color = Color(1, 1, 1, 0.9)
var overlay_font_size = 14
var overlay_title = "Project Memory System # EVE SHIFT"

# Shift timer
var shift_timer = null
var auto_shift_enabled = true
var current_shift_phase = 0
var shift_duration = 1.2 # seconds
var project_eve_shift_active = false

# Signals
signal memory_added(id, category)
signal memory_recalled(id, content)
signal memory_forgotten(id)
signal color_shifted(from_color, to_color)
signal overlay_updated(settings)
signal project_shift_completed(phase)

func _ready():
    # Initialize memory system
    _initialize_memory_banks()
    
    # Generate project hash
    project_hash_id = _generate_project_hash()
    
    # Setup shift timer
    shift_timer = Timer.new()
    shift_timer.wait_time = memory_shift_frequency
    shift_timer.connect("timeout", self, "_on_shift_timer")
    add_child(shift_timer)
    
    # Start the shift process if auto-shift is enabled
    if auto_shift_enabled:
        shift_timer.start()
        
    # Initialize color shifting pattern
    _initialize_color_shift_pattern()
    
    print("Project Memory System initialized")
    print("Color state: " + color_state)
    print("Project EVE ID: " + project_hash_id)

func _initialize_memory_banks():
    # Create memory banks for each category
    for category in categories:
        memory_banks[category] = {
            "memories": {},
            "connections": [],
            "last_accessed": 0,
            "importance": 0.5,
            "color": COLOR_LIGHT_BLUE,
            "is_locked": false
        }

func _initialize_color_shift_pattern():
    # Define color shift sequence
    shifting_patterns["blue_cycle"] = [
        {"color": COLOR_LIGHT_BLUE, "name": "light_blue", "duration": 3.6},
        {"color": COLOR_EVE_BLUE, "name": "eve_blue", "duration": 4.1},
        {"color": COLOR_SHIFT_BLUE, "name": "shift_blue", "duration": 2.9},
        {"color": COLOR_DEEP_BLUE, "name": "deep_blue", "duration": 3.3},
        {"color": COLOR_ETHEREAL_BLUE, "name": "ethereal_blue", "duration": 4.8}
    ]
    
    # Set initial overlay color
    overlay_color = COLOR_LIGHT_BLUE

func _on_shift_timer():
    # Shift colors based on pattern
    shift_colors()
    
    # If in EVE shift mode, advance phase
    if project_eve_shift_active:
        advance_project_shift()

func shift_colors():
    if not color_transition_active:
        # Start color transition
        color_transition_active = true
        
        # Get current pattern
        var pattern = shifting_patterns["blue_cycle"]
        
        # Find current color index
        var current_index = 0
        for i in range(pattern.size()):
            if pattern[i]["name"] == color_state:
                current_index = i
                break
        
        # Get next color in pattern
        var next_index = (current_index + 1) % pattern.size()
        var next_color_data = pattern[next_index]
        
        # Store old color for signal
        var old_color = overlay_color
        
        # Update color state
        color_state = next_color_data["name"]
        overlay_color = next_color_data["color"]
        
        # Update shift timer duration
        shift_timer.wait_time = next_color_data["duration"]
        
        # Emit signal about color change
        emit_signal("color_shifted", old_color, overlay_color)
        
        # Update all memory banks with new color tint
        for category in memory_banks:
            memory_banks[category]["color"] = overlay_color.lightened(0.2)
        
        # End transition
        color_transition_active = false
        
        # Update overlay
        _update_overlay()
        
        return {"from": old_color, "to": overlay_color, "state": color_state}
    
    return null

func add_memory(content, category, tags = []):
    # Validate category
    if not category in categories:
        print("Invalid memory category: " + category)
        return null
    
    # Generate unique memory ID
    var memory_id = _generate_memory_id()
    
    # Create memory structure
    var memory = {
        "id": memory_id,
        "content": content,
        "category": category,
        "tags": tags,
        "created_at": OS.get_unix_time(),
        "last_accessed": OS.get_unix_time(),
        "access_count": 0,
        "importance": 0.5,
        "connections": [],
        "color": memory_banks[category]["color"],
        "is_active": true
    }
    
    # Store in appropriate memory bank
    memory_banks[category]["memories"][memory_id] = memory
    
    # Add to active memories
    active_memories.append(memory_id)
    
    # Update memory bank last accessed
    memory_banks[category]["last_accessed"] = OS.get_unix_time()
    
    # Emit signal
    emit_signal("memory_added", memory_id, category)
    
    print("Memory added: " + memory_id + " [" + category + "]")
    return memory_id

func recall_memory(memory_id):
    # Find memory in banks
    for category in memory_banks:
        if memory_id in memory_banks[category]["memories"]:
            var memory = memory_banks[category]["memories"][memory_id]
            
            # Update access metrics
            memory["last_accessed"] = OS.get_unix_time()
            memory["access_count"] += 1
            
            # Update bank access time
            memory_banks[category]["last_accessed"] = OS.get_unix_time()
            
            # Set as current focus
            current_memory_focus = memory_id
            
            # Emit signal
            emit_signal("memory_recalled", memory_id, memory["content"])
            
            print("Memory recalled: " + memory_id)
            return memory
    
    print("Memory not found: " + memory_id)
    return null

func forget_memory(memory_id):
    # Find and remove memory
    for category in memory_banks:
        if memory_id in memory_banks[category]["memories"]:
            var memory = memory_banks[category]["memories"][memory_id]
            
            # Remove from active memories
            active_memories.erase(memory_id)
            
            # Add to forgotten memories
            forgotten_memories.append({
                "id": memory_id,
                "category": category,
                "forgotten_at": OS.get_unix_time()
            })
            
            # Remove from memory bank
            memory_banks[category]["memories"].erase(memory_id)
            
            # Emit signal
            emit_signal("memory_forgotten", memory_id)
            
            print("Memory forgotten: " + memory_id)
            return true
    
    print("Memory not found: " + memory_id)
    return false

func connect_memories(source_id, target_id, connection_type = "related"):
    # Verify both memories exist
    var source_memory = null
    var target_memory = null
    var source_category = ""
    var target_category = ""
    
    # Find source memory
    for category in memory_banks:
        if source_id in memory_banks[category]["memories"]:
            source_memory = memory_banks[category]["memories"][source_id]
            source_category = category
            break
    
    # Find target memory
    for category in memory_banks:
        if target_id in memory_banks[category]["memories"]:
            target_memory = memory_banks[category]["memories"][target_id]
            target_category = category
            break
    
    if source_memory == null or target_memory == null:
        print("One or both memories not found")
        return false
    
    # Create the connection
    var connection_id = source_id + "_" + target_id
    
    # Add to connection database
    memory_connections[connection_id] = {
        "source": source_id,
        "target": target_id,
        "type": connection_type,
        "source_category": source_category,
        "target_category": target_category,
        "created_at": OS.get_unix_time(),
        "strength": 0.5
    }
    
    # Add connection to both memories
    source_memory["connections"].append(connection_id)
    target_memory["connections"].append(connection_id)
    
    # Add to category connections
    memory_banks[source_category]["connections"].append(connection_id)
    if source_category != target_category:
        memory_banks[target_category]["connections"].append(connection_id)
    
    print("Connected memories: " + source_id + " -> " + target_id)
    return connection_id

func get_memories_by_category(category):
    if not category in categories:
        print("Invalid category: " + category)
        return []
    
    var memories = []
    for memory_id in memory_banks[category]["memories"]:
        memories.append(memory_banks[category]["memories"][memory_id])
    
    return memories

func get_memory_paths():
    # Generate memory path visualization
    memory_paths = []
    
    # Extract memory nodes
    var nodes = []
    for category in memory_banks:
        for memory_id in memory_banks[category]["memories"]:
            var memory = memory_banks[category]["memories"][memory_id]
            nodes.append({
                "id": memory_id,
                "category": category,
                "importance": memory["importance"],
                "color": memory["color"]
            })
    
    # Extract connections as edges
    var edges = []
    for connection_id in memory_connections:
        var connection = memory_connections[connection_id]
        edges.append({
            "source": connection["source"],
            "target": connection["target"],
            "type": connection["type"],
            "strength": connection["strength"]
        })
    
    # Create path structure
    memory_paths = {
        "nodes": nodes,
        "edges": edges,
        "categories": categories,
        "generated_at": OS.get_unix_time()
    }
    
    return memory_paths

func _update_overlay():
    # Update terminal overlay with current settings
    var overlay_settings = {
        "color": overlay_color,
        "position": overlay_position,
        "dimensions": overlay_dimensions,
        "opacity": overlay_opacity,
        "border": {
            "size": overlay_border_size,
            "color": overlay_border_color
        },
        "text": {
            "color": overlay_text_color,
            "size": overlay_font_size
        },
        "title": overlay_title,
        "visible": terminal_overlay_visible
    }
    
    emit_signal("overlay_updated", overlay_settings)
    return overlay_settings

func set_overlay_color(color):
    overlay_color = color
    _update_overlay()
    return true

func toggle_overlay_visibility():
    terminal_overlay_visible = !terminal_overlay_visible
    _update_overlay()
    return terminal_overlay_visible

func set_overlay_title(title):
    overlay_title = title
    _update_overlay()
    return true

func set_overlay_opacity(opacity):
    overlay_opacity = clamp(opacity, 0.1, 1.0)
    _update_overlay()
    return overlay_opacity

func start_eve_shift():
    # Activate EVE shift mode
    project_eve_shift_active = true
    current_shift_phase = 0
    
    # Update overlay title
    overlay_title = "Project Memory System # EVE SHIFT ACTIVE"
    
    # Set special color mode
    color_state = "eve_blue"
    overlay_color = COLOR_EVE_BLUE
    
    # Update overlay
    _update_overlay()
    
    print("EVE Shift activated")
    return true

func stop_eve_shift():
    # Deactivate EVE shift mode
    project_eve_shift_active = false
    
    # Reset overlay title
    overlay_title = "Project Memory System # EVE SHIFT"
    
    # Update overlay
    _update_overlay()
    
    print("EVE Shift deactivated")
    return true

func advance_project_shift():
    if project_eve_shift_active:
        current_shift_phase += 1
        
        # Process the shift phase
        var phase_data = {
            "phase": current_shift_phase,
            "time": OS.get_unix_time(),
            "color": overlay_color,
            "active_memories": active_memories.size()
        }
        
        # Emit signal for phase completion
        emit_signal("project_shift_completed", phase_data)
        
        print("EVE Shift phase " + str(current_shift_phase) + " completed")
        return phase_data
    
    return null

func _generate_memory_id():
    # Generate unique memory ID
    return "mem_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)

func _generate_project_hash():
    # Generate a hash for this project instance
    var time = OS.get_unix_time()
    var random_component = randi() % 1000000
    var hash_input = str(time) + "_" + str(random_component) + "_EVE_SHIFT"
    
    # Simple hash generation (in real implementation would use proper hash function)
    var hash_value = 0
    for i in range(hash_input.length()):
        hash_value = ((hash_value << 5) - hash_value) + ord(hash_input[i])
    
    # Format as hexadecimal string
    return "%x" % hash_value