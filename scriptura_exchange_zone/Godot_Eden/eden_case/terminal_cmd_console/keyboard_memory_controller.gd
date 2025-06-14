extends Node
class_name KeyboardMemoryController

# Keyboard Memory Controller
# -------------------------
# Enhances memory systems with keyboard shortcuts and control sequences
# Implements special key combinations for memory operations

# Constants
const KEY_COMBINATIONS = {
    "CTRL_L": {
        "name": "Memory List",
        "description": "Show list of active memories",
        "action": "list_memories"
    },
    "CTRL_S": {
        "name": "Memory Save",
        "description": "Save current memory state",
        "action": "save_memory_state"
    },
    "CTRL_R": {
        "name": "Memory Refresh",
        "description": "Refresh memory system",
        "action": "refresh_memories"
    },
    "CTRL_C": {
        "name": "Memory Connect",
        "description": "Connect selected memories",
        "action": "connect_memories"
    },
    "CTRL_SHIFT_C": {
        "name": "Memory Cycle",
        "description": "Create memory cycle",
        "action": "create_memory_cycle"
    },
    "CTRL_SHIFT_S": {
        "name": "Memory Split",
        "description": "Split memory into fragments",
        "action": "split_memory"
    },
    "CTRL_SHIFT_M": {
        "name": "Memory Merge",
        "description": "Merge selected memories",
        "action": "merge_memories"
    },
    "CTRL_E": {
        "name": "Memory Evolve",
        "description": "Evolve selected memory",
        "action": "evolve_memory"
    },
    "CTRL_D": {
        "name": "Memory Debug",
        "description": "Debug memory system",
        "action": "debug_memory_system"
    },
    "CTRL_SHIFT_D": {
        "name": "Memory Dimension",
        "description": "Change memory dimension",
        "action": "change_dimension"
    },
}

# Key Modifiers
enum KeyModifier {
    NONE = 0,
    SHIFT = 1,
    ALT = 2,
    CTRL = 4,
    META = 8
}

# System Variables
var _memory_system = null
var _connection_system = null
var _updater_system = null
var _wish_system = null
var _key_handler_active = false
var _selected_memories = []
var _current_modifier = 0
var _last_key_press_time = 0
var _double_press_threshold = 300  # milliseconds
var _last_key_pressed = -1

# Command History
var _command_history = []
var _max_history_size = 50

# UI Related
var _feedback_label = null
var _feedback_timer = null
var _feedback_duration = 2.0  # seconds

# Signals
signal keyboard_command_executed(command, result)
signal memory_selection_changed(selected_memories)
signal modifier_state_changed(modifier_state)

# System Initialization
func _ready():
    set_process_input(true)
    
    # Create feedback timer
    _feedback_timer = Timer.new()
    _feedback_timer.one_shot = true
    _feedback_timer.wait_time = _feedback_duration
    _feedback_timer.connect("timeout", self, "_hide_feedback")
    add_child(_feedback_timer)

func initialize(memory_system = null, connection_system = null, updater_system = null, wish_system = null):
    _memory_system = memory_system
    _connection_system = connection_system
    _updater_system = updater_system
    _wish_system = wish_system
    
    _key_handler_active = true
    
    return true

func set_feedback_label(label):
    _feedback_label = label

# Input Handling
func _input(event):
    if not _key_handler_active:
        return
    
    if event is InputEventKey:
        # Track modifier keys
        if event.scancode == KEY_SHIFT:
            if event.pressed:
                _current_modifier |= KeyModifier.SHIFT
            else:
                _current_modifier &= ~KeyModifier.SHIFT
            emit_signal("modifier_state_changed", _current_modifier)
            
        elif event.scancode == KEY_ALT:
            if event.pressed:
                _current_modifier |= KeyModifier.ALT
            else:
                _current_modifier &= ~KeyModifier.ALT
            emit_signal("modifier_state_changed", _current_modifier)
            
        elif event.scancode == KEY_CONTROL:
            if event.pressed:
                _current_modifier |= KeyModifier.CTRL
            else:
                _current_modifier &= ~KeyModifier.CTRL
            emit_signal("modifier_state_changed", _current_modifier)
            
        # Handle key combinations
        elif event.pressed:
            # Check for double press
            var current_time = OS.get_ticks_msec()
            var is_double_press = _last_key_pressed == event.scancode and (current_time - _last_key_press_time) < _double_press_threshold
            
            _last_key_press_time = current_time
            _last_key_pressed = event.scancode
            
            # Process combination
            handle_key_combination(event.scancode, _current_modifier, is_double_press)

func handle_key_combination(key_code, modifiers, is_double_press):
    # Handle Ctrl+L
    if key_code == KEY_L and modifiers & KeyModifier.CTRL:
        execute_command("list_memories")
        show_feedback("Listing Memories")
        return
    
    # Handle Ctrl+S
    if key_code == KEY_S and modifiers & KeyModifier.CTRL:
        if modifiers & KeyModifier.SHIFT:
            # Ctrl+Shift+S
            execute_command("split_memory")
            show_feedback("Splitting Memory")
        else:
            # Ctrl+S
            execute_command("save_memory_state")
            show_feedback("Saving Memory State")
        return
    
    # Handle Ctrl+R
    if key_code == KEY_R and modifiers & KeyModifier.CTRL:
        execute_command("refresh_memories")
        show_feedback("Refreshing Memories")
        return
    
    # Handle Ctrl+C
    if key_code == KEY_C and modifiers & KeyModifier.CTRL:
        if modifiers & KeyModifier.SHIFT:
            # Ctrl+Shift+C
            execute_command("create_memory_cycle")
            show_feedback("Creating Memory Cycle")
        else:
            # Ctrl+C
            execute_command("connect_memories")
            show_feedback("Connecting Memories")
        return
    
    # Handle Ctrl+M (merge)
    if key_code == KEY_M and modifiers & KeyModifier.CTRL and modifiers & KeyModifier.SHIFT:
        execute_command("merge_memories")
        show_feedback("Merging Memories")
        return
    
    # Handle Ctrl+E (evolve)
    if key_code == KEY_E and modifiers & KeyModifier.CTRL:
        execute_command("evolve_memory")
        show_feedback("Evolving Memory")
        return
    
    # Handle Ctrl+D (debug)
    if key_code == KEY_D and modifiers & KeyModifier.CTRL:
        if modifiers & KeyModifier.SHIFT:
            # Ctrl+Shift+D
            execute_command("change_dimension")
            show_feedback("Changing Memory Dimension")
        else:
            # Ctrl+D
            execute_command("debug_memory_system")
            show_feedback("Debugging Memory System")
        return

func execute_command(command_name, params = {}):
    var result = null
    
    match command_name:
        "list_memories":
            result = cmd_list_memories(params)
        "save_memory_state":
            result = cmd_save_memory_state(params)
        "refresh_memories":
            result = cmd_refresh_memories(params)
        "connect_memories":
            result = cmd_connect_memories(params)
        "create_memory_cycle":
            result = cmd_create_memory_cycle(params)
        "split_memory":
            result = cmd_split_memory(params)
        "merge_memories":
            result = cmd_merge_memories(params)
        "evolve_memory":
            result = cmd_evolve_memory(params)
        "debug_memory_system":
            result = cmd_debug_memory_system(params)
        "change_dimension":
            result = cmd_change_dimension(params)
    
    # Record in command history
    _command_history.append({
        "command": command_name,
        "params": params,
        "timestamp": OS.get_unix_time(),
        "result": result
    })
    
    # Trim history if needed
    if _command_history.size() > _max_history_size:
        _command_history.pop_front()
    
    emit_signal("keyboard_command_executed", command_name, result)
    
    return result

# Command Implementations
func cmd_list_memories(params):
    if not _memory_system:
        return {"error": "Memory system not initialized"}
    
    var result = {
        "memories": []
    }
    
    # Get active memories
    var memory_count = min(10, _memory_system._memories.size())  # Limit to 10 for display
    var memories = _memory_system._memories.values().slice(0, memory_count - 1)
    
    for memory in memories:
        result.memories.append({
            "id": memory.id,
            "content": memory.content.substr(0, 30) + (memory.content.length() > 30 ? "..." : ""),
            "dimension": memory.dimension,
            "tags": memory.tags
        })
    
    # Include dimension breakdown
    result["dimensions"] = {}
    for dimension in _memory_system._dimension_indices:
        result.dimensions[dimension] = _memory_system._dimension_indices[dimension].size()
    
    return result

func cmd_save_memory_state(params):
    if not _memory_system:
        return {"error": "Memory system not initialized"}
    
    var result = {
        "saved": true,
        "memories_saved": _memory_system._memories.size()
    }
    
    # Use updater if available, otherwise simulate save
    if _updater_system:
        var task_id = _updater_system.create_task(_updater_system.UPDATE_TYPES.SNAPSHOT)
        _updater_system.set_task_parameter(task_id, "save_to_file", true)
        _updater_system.process_updates()
        result["task_id"] = task_id
    
    return result

func cmd_refresh_memories(params):
    var result = {
        "refreshed": true
    }
    
    # Refresh memory system
    if _memory_system:
        # Load existing memories
        _memory_system.load_memories()
        result["memories_loaded"] = _memory_system._memories.size()
    
    # Refresh connection system
    if _connection_system:
        _connection_system.load_connections()
        result["connections_loaded"] = _connection_system._connections.size()
    
    return result

func cmd_connect_memories(params):
    if not _connection_system:
        return {"error": "Connection system not initialized"}
    
    var result = {
        "connected": false,
        "connections_created": []
    }
    
    # Use selected memories or get from params
    var memories_to_connect = _selected_memories
    if params.has("memories"):
        memories_to_connect = params.memories
    
    if memories_to_connect.size() < 2:
        return {"error": "Need at least 2 memories to connect"}
    
    # Determine connection type
    var connection_type = params.has("connection_type") ? params.connection_type : _connection_system.CONNECTION_TYPES.RELATED
    var reason = params.has("reason") ? params.reason : "Connected via keyboard shortcut"
    
    # Create connections
    for i in range(memories_to_connect.size() - 1):
        var source_id = memories_to_connect[i]
        var target_id = memories_to_connect[i + 1]
        
        var connection_id = _connection_system.connect_memories(
            source_id,
            target_id,
            connection_type,
            reason
        )
        
        if connection_id:
            result.connections_created.append(connection_id)
    
    result.connected = result.connections_created.size() > 0
    
    return result

func cmd_create_memory_cycle(params):
    if not _connection_system:
        return {"error": "Connection system not initialized"}
    
    var result = {
        "cycle_created": false,
        "connections_created": []
    }
    
    # Use selected memories or get from params
    var memories_for_cycle = _selected_memories
    if params.has("memories"):
        memories_for_cycle = params.memories
    
    if memories_for_cycle.size() < 3:
        return {"error": "Need at least 3 memories to create a cycle"}
    
    # Create cycle
    var reason = params.has("reason") ? params.reason : "Cycle created via keyboard shortcut"
    var connections = _connection_system.create_cycle(
        memories_for_cycle,
        reason
    )
    
    result.connections_created = connections
    result.cycle_created = connections.size() > 0
    
    return result

func cmd_split_memory(params):
    if not _memory_system:
        return {"error": "Memory system not initialized"}
    
    var result = {
        "split": false,
        "fragments_created": []
    }
    
    # Get memory to split
    var memory_to_split = ""
    if _selected_memories.size() > 0:
        memory_to_split = _selected_memories[0]
    elif params.has("memory_id"):
        memory_to_split = params.memory_id
    
    if memory_to_split.empty():
        return {"error": "No memory selected for splitting"}
    
    # Get number of fragments
    var fragment_count = params.has("fragment_count") ? params.fragment_count : 2
    
    # Use updater if available
    if _updater_system:
        var task_id = _updater_system.create_task(_updater_system.UPDATE_TYPES.SPLIT)
        _updater_system.add_target_to_task(task_id, memory_to_split)
        _updater_system.set_task_parameter(task_id, "split_count", fragment_count)
        
        _updater_system.process_updates()
        
        var task = _updater_system.get_task(task_id)
        if task and task.result:
            result = task.result
    else:
        # Manually implement splitting if no updater
        var memory = _memory_system.get_memory(memory_to_split)
        if not memory:
            return {"error": "Memory not found"}
        
        # Create fragments
        for i in range(fragment_count):
            var content_part = "Fragment " + str(i+1) + " of " + memory_to_split
            var fragment_id = _memory_system.create_memory(content_part, memory.dimension)
            
            result.fragments_created.append(fragment_id)
            
            # Connect to original memory if connection system available
            if _connection_system:
                _connection_system.connect_memories(
                    memory_to_split,
                    fragment_id,
                    _connection_system.CONNECTION_TYPES.SPLITS,
                    "Split via keyboard shortcut"
                )
        
        result.split = true
    
    return result

func cmd_merge_memories(params):
    if not _memory_system:
        return {"error": "Memory system not initialized"}
    
    var result = {
        "merged": false
    }
    
    # Use selected memories or get from params
    var memories_to_merge = _selected_memories
    if params.has("memories"):
        memories_to_merge = params.memories
    
    if memories_to_merge.size() < 2:
        return {"error": "Need at least 2 memories to merge"}
    
    # Use updater if available
    if _updater_system:
        var task_id = _updater_system.create_task(_updater_system.UPDATE_TYPES.MERGE)
        
        for memory_id in memories_to_merge:
            _updater_system.add_target_to_task(task_id, memory_id)
        
        _updater_system.set_task_parameter(task_id, "reason", "Merged via keyboard shortcut")
        
        _updater_system.process_updates()
        
        var task = _updater_system.get_task(task_id)
        if task and task.result:
            result = task.result
    else:
        # Connect memories if connection system available
        if _connection_system:
            result["connections_created"] = []
            
            for i in range(memories_to_merge.size() - 1):
                var source_id = memories_to_merge[i]
                var target_id = memories_to_merge[i + 1]
                
                var connection_id = _connection_system.connect_memories(
                    source_id,
                    target_id,
                    _connection_system.CONNECTION_TYPES.RELATED,
                    "Merged via keyboard shortcut"
                )
                
                if connection_id:
                    result.connections_created.append(connection_id)
            
            result.merged = result.connections_created.size() > 0
    
    return result

func cmd_evolve_memory(params):
    if not _memory_system:
        return {"error": "Memory system not initialized"}
    
    var result = {
        "evolved": false
    }
    
    # Get memory to evolve
    var memory_to_evolve = ""
    if _selected_memories.size() > 0:
        memory_to_evolve = _selected_memories[0]
    elif params.has("memory_id"):
        memory_to_evolve = params.memory_id
    
    if memory_to_evolve.empty():
        return {"error": "No memory selected for evolution"}
    
    # Use updater if available
    if _updater_system:
        var task_id = _updater_system.create_task(_updater_system.UPDATE_TYPES.EVOLVE)
        _updater_system.add_target_to_task(task_id, memory_to_evolve)
        
        _updater_system.process_updates()
        
        var task = _updater_system.get_task(task_id)
        if task and task.result:
            result = task.result
    else:
        # Manually evolve
        var memory = _memory_system.get_memory(memory_to_evolve)
        if not memory:
            return {"error": "Memory not found"}
        
        // Increase dimension as a simple evolution
        var old_dimension = memory.dimension
        var new_dimension = min(old_dimension + 1, 12)  // Max dimension 12
        
        var success = _memory_system.change_memory_dimension(memory_to_evolve, new_dimension)
        
        if success:
            result = {
                "evolved": true,
                "memory_id": memory_to_evolve,
                "old_dimension": old_dimension,
                "new_dimension": new_dimension
            }
            
            // Create evolution connection
            if _connection_system:
                _connection_system.connect_memories(
                    memory_to_evolve,
                    memory_to_evolve,  // Self-connection
                    _connection_system.CONNECTION_TYPES.EVOLVING,
                    "Evolved from dimension " + str(old_dimension) + " to " + str(new_dimension)
                )
    
    return result

func cmd_debug_memory_system(params):
    var result = {
        "debug_completed": false
    }
    
    # Use updater if available
    if _updater_system:
        var task_id = _updater_system.create_task(_updater_system.UPDATE_TYPES.DEBUG)
        _updater_system.set_task_parameter(task_id, "generate_report", true)
        
        _updater_system.process_updates()
        
        var task = _updater_system.get_task(task_id)
        if task and task.result:
            result = task.result
    else:
        # Basic stats if no updater
        result = {
            "debug_completed": true,
            "memory_stats": {}
        }
        
        if _memory_system:
            result.memory_stats = {
                "total_memories": _memory_system._memories.size(),
                "dimensions": {}
            }
            
            # Count by dimension
            for dimension in _memory_system._dimension_indices:
                result.memory_stats.dimensions[dimension] = _memory_system._dimension_indices[dimension].size()
        
        if _connection_system:
            result["connection_stats"] = {
                "total_connections": _connection_system._connections.size()
            }
    
    return result

func cmd_change_dimension(params):
    if not _memory_system:
        return {"error": "Memory system not initialized"}
    
    var result = {
        "dimension_changed": false
    }
    
    # Get memory to change
    var memory_to_change = ""
    if _selected_memories.size() > 0:
        memory_to_change = _selected_memories[0]
    elif params.has("memory_id"):
        memory_to_change = params.memory_id
    
    if memory_to_change.empty():
        return {"error": "No memory selected for dimension change"}
    
    # Get target dimension
    var target_dimension = params.has("dimension") ? params.dimension : 1
    
    // Change dimension
    var memory = _memory_system.get_memory(memory_to_change)
    if not memory:
        return {"error": "Memory not found"}
    
    var old_dimension = memory.dimension
    var success = _memory_system.change_memory_dimension(memory_to_change, target_dimension)
    
    if success:
        result = {
            "dimension_changed": true,
            "memory_id": memory_to_change,
            "old_dimension": old_dimension,
            "new_dimension": target_dimension
        }
    
    return result

# Memory Selection
func select_memory(memory_id):
    if not _selected_memories.has(memory_id):
        _selected_memories.append(memory_id)
        emit_signal("memory_selection_changed", _selected_memories)

func deselect_memory(memory_id):
    if _selected_memories.has(memory_id):
        _selected_memories.erase(memory_id)
        emit_signal("memory_selection_changed", _selected_memories)

func toggle_memory_selection(memory_id):
    if _selected_memories.has(memory_id):
        _selected_memories.erase(memory_id)
    else:
        _selected_memories.append(memory_id)
    
    emit_signal("memory_selection_changed", _selected_memories)

func clear_memory_selection():
    _selected_memories.clear()
    emit_signal("memory_selection_changed", _selected_memories)

func get_selected_memories():
    return _selected_memories

# Feedback Handling
func show_feedback(message):
    if _feedback_label:
        _feedback_label.text = message
        _feedback_label.visible = true
        _feedback_timer.start()

func _hide_feedback():
    if _feedback_label:
        _feedback_label.visible = false

# System Management
func enable_key_handler():
    _key_handler_active = true

func disable_key_handler():
    _key_handler_active = false

func get_command_history():
    return _command_history

func get_last_command_result():
    if _command_history.size() > 0:
        return _command_history.back().result
    return null

# Example usage:
# var kb_controller = KeyboardMemoryController.new()
# add_child(kb_controller)
# kb_controller.initialize(memory_system, connection_system, updater_system)
# 
# # Create a label for feedback
# var feedback = Label.new()
# add_child(feedback)
# kb_controller.set_feedback_label(feedback)
# 
# # Connect to signals
# kb_controller.connect("keyboard_command_executed", self, "_on_command_executed")
# kb_controller.connect("memory_selection_changed", self, "_on_selection_changed")