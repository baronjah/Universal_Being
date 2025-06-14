extends Node
class_name MemoryCommunicationBridge

"""
Memory Communication Bridge
-------------------------
Facilitates communication between computer and user via memory system
Handles memory splitting and marker patterns for advanced interactions
"""

# Communication Constants
const COMMUNICATION_MODES = {
    "DIRECT": 0,      # Direct memory transfer
    "SYMBOLIC": 1,    # Symbol-based communication
    "PATTERN": 2,     # Pattern recognition mode
    "SPLITWISE": 3,   # Split memory communication
    "HOLISTIC": 4,    # Whole-system communication
    "REFLECTIVE": 5,  # Echo/mirror communication
    "RECURSIVE": 6    # Nested memory communication
}

const MARKER_PATTERNS = {
    "SINGLE": "#",           # Basic marker
    "DOUBLE": "##",          # Emphasis marker
    "TRIPLE": "###",         # Strong emphasis
    "QUAD": "####",          # Deep emphasis
    "SEQUENCE": "# ## ###",  # Progressive sequence
    "GRID": "# # #\n# # #",  # Grid pattern
    "WAVE": "# ## # ## #",   # Oscillating pattern
    "CLUSTER": "###\n###"    # Grouped pattern
}

# Splitter Configurations
const MAX_SPLITTERS = 99
const SPLIT_TYPES = {
    "EVEN": 0,        # Equal distribution
    "PROGRESSIVE": 1, # Increasing sizes
    "FIBONACCI": 2,   # Fibonacci sequence
    "PRIME": 3,       # Prime numbers
    "CUSTOM": 4       # User-defined pattern
}

# System components
var _memory_system = null
var _connection_system = null
var _trajectory_system = null
var _visualizer = null
var _secure_channel = null
var _current_mode = COMMUNICATION_MODES.DIRECT
var _active_splitters = 3  # Default number of active splitters
var _current_split_type = SPLIT_TYPES.EVEN
var _custom_split_pattern = []
var _communication_log = []
var _response_templates = {}
var _pattern_recognition_enabled = true

# Communication Context
class CommunicationContext:
    var id: String
    var mode: int
    var splitter_count: int
    var split_type: int
    var markers_used = []
    var session_start: int
    var last_update: int
    var memory_ids = []
    var metadata = {}
    
    func _init(p_id: String, p_mode: int):
        id = p_id
        mode = p_mode
        session_start = OS.get_unix_time()
        last_update = session_start
    
    func set_splitters(count: int, type: int):
        splitter_count = count
        split_type = type
    
    func add_marker(marker: String):
        if not markers_used.has(marker):
            markers_used.append(marker)
    
    func add_memory(memory_id: String):
        if not memory_ids.has(memory_id):
            memory_ids.append(memory_id)
            last_update = OS.get_unix_time()
    
    func update():
        last_update = OS.get_unix_time()
    
    func duration() -> int:
        return last_update - session_start
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "mode": mode,
            "splitter_count": splitter_count,
            "split_type": split_type,
            "markers_used": markers_used,
            "session_start": session_start,
            "last_update": last_update,
            "memory_ids": memory_ids,
            "metadata": metadata
        }
    
    static func from_dict(data: Dictionary) -> CommunicationContext:
        var context = CommunicationContext.new(data.id, data.mode)
        context.set_splitters(data.splitter_count, data.split_type)
        context.markers_used = data.markers_used.duplicate()
        context.session_start = data.session_start
        context.last_update = data.last_update
        context.memory_ids = data.memory_ids.duplicate()
        context.metadata = data.metadata.duplicate()
        return context

class CommunicationEntry:
    var id: String
    var timestamp: int
    var direction: String  # "incoming" or "outgoing"
    var content: String
    var split_fragments = []
    var markers_used = []
    var context_id: String
    var memory_ids = []
    
    func _init(p_id: String, p_direction: String, p_content: String):
        id = p_id
        direction = p_direction
        content = p_content
        timestamp = OS.get_unix_time()
    
    func add_fragment(fragment: String):
        split_fragments.append(fragment)
    
    func add_marker(marker: String):
        if not markers_used.has(marker):
            markers_used.append(marker)
    
    func set_context(p_context_id: String):
        context_id = p_context_id
    
    func add_memory(memory_id: String):
        if not memory_ids.has(memory_id):
            memory_ids.append(memory_id)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "timestamp": timestamp,
            "direction": direction,
            "content": content,
            "split_fragments": split_fragments,
            "markers_used": markers_used,
            "context_id": context_id,
            "memory_ids": memory_ids
        }
    
    static func from_dict(data: Dictionary) -> CommunicationEntry:
        var entry = CommunicationEntry.new(
            data.id,
            data.direction,
            data.content
        )
        
        entry.timestamp = data.timestamp
        entry.split_fragments = data.split_fragments.duplicate()
        entry.markers_used = data.markers_used.duplicate()
        entry.context_id = data.context_id
        entry.memory_ids = data.memory_ids.duplicate()
        
        return entry

# Response Template
class ResponseTemplate:
    var id: String
    var name: String
    var pattern: String
    var response: String
    var markers = []
    var metadata = {}
    
    func _init(p_id: String, p_name: String, p_pattern: String, p_response: String):
        id = p_id
        name = p_name
        pattern = p_pattern
        response = p_response
    
    func add_marker(marker: String):
        if not markers.has(marker):
            markers.append(marker)
    
    func matches(input: String) -> bool:
        # Check if input matches the pattern
        return input.find(pattern) >= 0
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
            "pattern": pattern,
            "response": response,
            "markers": markers,
            "metadata": metadata
        }
    
    static func from_dict(data: Dictionary) -> ResponseTemplate:
        var template = ResponseTemplate.new(
            data.id,
            data.name,
            data.pattern,
            data.response
        )
        
        template.markers = data.markers.duplicate()
        template.metadata = data.metadata.duplicate()
        
        return template

# Signals
signal communication_received(entry_id)
signal communication_sent(entry_id)
signal context_created(context_id)
signal markers_detected(markers)
signal splitters_changed(count)

# System Initialization
func _ready():
    # Initialize custom split pattern
    _initialize_custom_pattern()
    
    # Load response templates
    load_response_templates()
    
    # Load communication log
    load_communication_log()

func initialize(
    memory_system = null,
    connection_system = null,
    trajectory_system = null,
    visualizer = null,
    secure_channel = null
):
    _memory_system = memory_system
    _connection_system = connection_system
    _trajectory_system = trajectory_system
    _visualizer = visualizer
    _secure_channel = secure_channel
    
    return true

# Communication Management
func set_communication_mode(mode: int) -> bool:
    if mode < 0 or mode > COMMUNICATION_MODES.size():
        return false
    
    _current_mode = mode
    return true

func set_active_splitters(count: int) -> bool:
    if count < 1 or count > MAX_SPLITTERS:
        return false
    
    _active_splitters = count
    emit_signal("splitters_changed", count)
    return true

func set_split_type(type: int) -> bool:
    if type < 0 or type >= SPLIT_TYPES.size():
        return false
    
    _current_split_type = type
    return true

func set_custom_split_pattern(pattern: Array) -> bool:
    if pattern.empty():
        return false
    
    _custom_split_pattern = pattern
    return true

# Initialize a default custom pattern
func _initialize_custom_pattern():
    # Create a basic custom pattern (example: 1,2,3,5,8)
    _custom_split_pattern = [1, 2, 3, 5, 8]

# Process incoming memory communication
func receive_communication(content: String) -> Dictionary:
    if content.empty():
        return {"success": false, "error": "Empty content"}
    
    # Create entry ID
    var entry_id = "comm_in_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    
    # Create communication entry
    var entry = CommunicationEntry.new(entry_id, "incoming", content)
    
    # Process content based on current mode
    var result = _process_incoming_content(content, entry)
    
    # Create or update context
    var context_id = ""
    if result.has("context_id") and not result.context_id.empty():
        context_id = result.context_id
    else:
        context_id = _create_communication_context(entry)
        result["context_id"] = context_id
    
    entry.set_context(context_id)
    
    # Store in communication log
    _communication_log.append(entry)
    
    # Save communication log
    save_communication_log()
    
    emit_signal("communication_received", entry_id)
    
    return result

# Process outgoing memory communication
func send_communication(content: String, context_id: String = "") -> Dictionary:
    if content.empty():
        return {"success": false, "error": "Empty content"}
    
    # Create entry ID
    var entry_id = "comm_out_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    
    # Create communication entry
    var entry = CommunicationEntry.new(entry_id, "outgoing", content)
    
    # Process content based on current mode
    var result = _process_outgoing_content(content, entry, context_id)
    
    # Set context
    if result.has("context_id") and not result.context_id.empty():
        entry.set_context(result.context_id)
    elif not context_id.empty():
        entry.set_context(context_id)
    
    # Store in communication log
    _communication_log.append(entry)
    
    # Save communication log
    save_communication_log()
    
    emit_signal("communication_sent", entry_id)
    
    return result

# Processing Functions

func _process_incoming_content(content: String, entry: CommunicationEntry) -> Dictionary:
    var result = {
        "success": true,
        "processed": true,
        "markers_detected": [],
        "split_count": 0,
        "memories_created": [],
        "context_id": ""
    }
    
    # Detect markers
    var markers = _detect_markers(content)
    result.markers_detected = markers
    
    for marker in markers:
        entry.add_marker(marker)
    
    # Handle based on communication mode
    match _current_mode:
        COMMUNICATION_MODES.DIRECT:
            # Direct mode - store as single memory
            if _memory_system:
                var memory_id = _memory_system.create_memory(content)
                if memory_id:
                    entry.add_memory(memory_id)
                    result.memories_created.append(memory_id)
        
        COMMUNICATION_MODES.SYMBOLIC:
            # Symbolic mode - process symbols and store
            if _memory_system:
                var processed_content = _process_symbolic_content(content)
                var memory_id = _memory_system.create_memory(processed_content)
                if memory_id:
                    entry.add_memory(memory_id)
                    result.memories_created.append(memory_id)
        
        COMMUNICATION_MODES.PATTERN:
            # Pattern mode - recognize patterns and respond
            var pattern_result = _process_pattern_content(content)
            result["pattern_recognized"] = pattern_result.recognized
            result["pattern_name"] = pattern_result.pattern_name if pattern_result.has("pattern_name") else ""
            
            if _memory_system and pattern_result.has("processed_content"):
                var memory_id = _memory_system.create_memory(pattern_result.processed_content)
                if memory_id:
                    entry.add_memory(memory_id)
                    result.memories_created.append(memory_id)
        
        COMMUNICATION_MODES.SPLITWISE:
            # Split mode - break into multiple memories
            var split_result = _split_content(content)
            result["split_count"] = split_result.fragments.size()
            
            # Store split fragments
            for fragment in split_result.fragments:
                entry.add_fragment(fragment)
                
                if _memory_system:
                    var memory_id = _memory_system.create_memory(fragment)
                    if memory_id:
                        entry.add_memory(memory_id)
                        result.memories_created.append(memory_id)
        
        _:  # Default or other modes
            if _memory_system:
                var memory_id = _memory_system.create_memory(content)
                if memory_id:
                    entry.add_memory(memory_id)
                    result.memories_created.append(memory_id)
    
    # Check for response templates
    var response_result = _check_response_templates(content)
    if response_result.matched:
        result["response_matched"] = true
        result["response_template"] = response_result.template_id
        result["response_content"] = response_result.response
    
    return result

func _process_outgoing_content(content: String, entry: CommunicationEntry, context_id: String) -> Dictionary:
    var result = {
        "success": true,
        "processed": true,
        "markers_used": [],
        "split_count": 0,
        "memories_created": [],
        "context_id": context_id
    }
    
    # Find existing context or create new one
    var context = null
    if not context_id.empty():
        context = _get_communication_context(context_id)
    
    if not context:
        context_id = _create_communication_context(entry)
        context = _get_communication_context(context_id)
        result.context_id = context_id
    
    # Add markers based on mode
    var markers = []
    match _current_mode:
        COMMUNICATION_MODES.SYMBOLIC:
            markers.append(MARKER_PATTERNS.DOUBLE)
        COMMUNICATION_MODES.PATTERN:
            markers.append(MARKER_PATTERNS.SEQUENCE)
        COMMUNICATION_MODES.SPLITWISE:
            markers.append(MARKER_PATTERNS.WAVE)
        _:
            markers.append(MARKER_PATTERNS.SINGLE)
    
    result.markers_used = markers
    
    for marker in markers:
        entry.add_marker(marker)
        if context:
            context.add_marker(marker)
    
    # Handle based on communication mode
    match _current_mode:
        COMMUNICATION_MODES.SPLITWISE:
            # Split mode - break into multiple memories
            var split_result = _split_content(content)
            result["split_count"] = split_result.fragments.size()
            
            # Store split fragments
            for fragment in split_result.fragments:
                entry.add_fragment(fragment)
                
                if _memory_system:
                    var memory_id = _memory_system.create_memory(fragment)
                    if memory_id:
                        entry.add_memory(memory_id)
                        result.memories_created.append(memory_id)
                        
                        if context:
                            context.add_memory(memory_id)
        
        _:  # Direct or other modes
            if _memory_system:
                var memory_id = _memory_system.create_memory(content)
                if memory_id:
                    entry.add_memory(memory_id)
                    result.memories_created.append(memory_id)
                    
                    if context:
                        context.add_memory(memory_id)
    
    # Update context
    if context:
        context.update()
    
    return result

func _detect_markers(content: String) -> Array:
    var found_markers = []
    
    for marker_name in MARKER_PATTERNS:
        var marker = MARKER_PATTERNS[marker_name]
        if content.find(marker) >= 0:
            found_markers.append(marker)
    
    # Signal emission
    if found_markers.size() > 0:
        emit_signal("markers_detected", found_markers)
    
    return found_markers

func _process_symbolic_content(content: String) -> String:
    # Process symbolic content - replace markers with interpretations
    var processed = content
    
    # Replace known markers with interpretations
    for marker_name in MARKER_PATTERNS:
        var marker = MARKER_PATTERNS[marker_name]
        
        if processed.find(marker) >= 0:
            var interpretation = "{{" + marker_name + "}}"
            processed = processed.replace(marker, interpretation)
    
    return processed

func _process_pattern_content(content: String) -> Dictionary:
    var result = {
        "recognized": false,
        "processed_content": content
    }
    
    if not _pattern_recognition_enabled:
        return result
    
    # Check for known patterns
    var recognized_pattern = ""
    
    # Look for sequence patterns
    if content.find(MARKER_PATTERNS.SEQUENCE) >= 0:
        recognized_pattern = "SEQUENCE"
        result.pattern_name = "Progressive Sequence"
    
    # Look for grid patterns
    elif content.find(MARKER_PATTERNS.GRID) >= 0:
        recognized_pattern = "GRID"
        result.pattern_name = "Grid Layout"
    
    # Look for wave patterns
    elif content.find(MARKER_PATTERNS.WAVE) >= 0:
        recognized_pattern = "WAVE"
        result.pattern_name = "Wave Pattern"
    
    # Look for clusters
    elif content.find(MARKER_PATTERNS.CLUSTER) >= 0:
        recognized_pattern = "CLUSTER"
        result.pattern_name = "Cluster Pattern"
    
    # Look for emphasis markers (multiple #)
    elif content.find(MARKER_PATTERNS.QUAD) >= 0:
        recognized_pattern = "QUAD"
        result.pattern_name = "Strong Emphasis (4x)"
    elif content.find(MARKER_PATTERNS.TRIPLE) >= 0:
        recognized_pattern = "TRIPLE"
        result.pattern_name = "Strong Emphasis (3x)"
    elif content.find(MARKER_PATTERNS.DOUBLE) >= 0:
        recognized_pattern = "DOUBLE"
        result.pattern_name = "Emphasis (2x)"
    elif content.find(MARKER_PATTERNS.SINGLE) >= 0:
        recognized_pattern = "SINGLE"
        result.pattern_name = "Basic Marker"
    
    if not recognized_pattern.empty():
        result.recognized = true
        result.pattern_type = recognized_pattern
        
        # Process content based on pattern
        var processed_content = content
        
        # Add interpretations
        processed_content += "\n[PATTERN: " + result.pattern_name + "]"
        
        result.processed_content = processed_content
    
    return result

func _split_content(content: String) -> Dictionary:
    var result = {
        "fragments": []
    }
    
    # Skip if empty content
    if content.empty():
        return result
    
    # Determine number of splits
    var split_count = _active_splitters
    
    # Calculate split sizes based on split type
    var split_sizes = []
    
    match _current_split_type:
        SPLIT_TYPES.EVEN:
            # Equal distribution
            var avg_size = content.length() / float(split_count)
            for i in range(split_count):
                split_sizes.append(avg_size)
        
        SPLIT_TYPES.PROGRESSIVE:
            # Increasing sizes (1, 2, 3, 4, etc.)
            var total_parts = 0
            for i in range(1, split_count + 1):
                total_parts += i
            
            var unit_size = content.length() / float(total_parts)
            for i in range(1, split_count + 1):
                split_sizes.append(unit_size * i)
        
        SPLIT_TYPES.FIBONACCI:
            # Fibonacci sequence (1, 1, 2, 3, 5, 8, etc.)
            var fib_sequence = [1, 1]
            for i in range(2, split_count):
                fib_sequence.append(fib_sequence[i-1] + fib_sequence[i-2])
            
            var total_parts = 0
            for i in range(split_count):
                total_parts += fib_sequence[i]
            
            var unit_size = content.length() / float(total_parts)
            for i in range(split_count):
                split_sizes.append(unit_size * fib_sequence[i])
        
        SPLIT_TYPES.PRIME:
            # Prime numbers (2, 3, 5, 7, 11, etc.)
            var prime_sequence = []
            var num = 2
            
            while prime_sequence.size() < split_count:
                var is_prime = true
                for i in range(2, num):
                    if num % i == 0:
                        is_prime = false
                        break
                
                if is_prime:
                    prime_sequence.append(num)
                
                num += 1
            
            var total_parts = 0
            for i in range(split_count):
                total_parts += prime_sequence[i]
            
            var unit_size = content.length() / float(total_parts)
            for i in range(split_count):
                split_sizes.append(unit_size * prime_sequence[i])
        
        SPLIT_TYPES.CUSTOM:
            # User-defined pattern
            if _custom_split_pattern.size() > 0:
                var pattern_size = min(_custom_split_pattern.size(), split_count)
                var total_parts = 0
                
                for i in range(pattern_size):
                    total_parts += _custom_split_pattern[i]
                
                var unit_size = content.length() / float(total_parts)
                for i in range(pattern_size):
                    split_sizes.append(unit_size * _custom_split_pattern[i])
            else:
                # Fallback to even distribution
                var avg_size = content.length() / float(split_count)
                for i in range(split_count):
                    split_sizes.append(avg_size)
    
    # Create fragments based on split sizes
    var current_pos = 0
    
    for i in range(split_sizes.size()):
        var split_size = int(split_sizes[i])
        if i == split_sizes.size() - 1:
            # Last fragment gets the rest
            split_size = content.length() - current_pos
        
        var fragment = content.substr(current_pos, split_size)
        result.fragments.append(fragment)
        
        current_pos += split_size
    
    return result

func _check_response_templates(content: String) -> Dictionary:
    var result = {
        "matched": false
    }
    
    for template_id in _response_templates:
        var template = _response_templates[template_id]
        
        if template.matches(content):
            result.matched = true
            result.template_id = template_id
            result.response = template.response
            result.template_name = template.name
            break
    
    return result

# Communication Context Functions

func _create_communication_context(entry: CommunicationEntry) -> String:
    var context_id = "ctx_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    
    var context = CommunicationContext.new(context_id, _current_mode)
    context.set_splitters(_active_splitters, _current_split_type)
    
    for marker in entry.markers_used:
        context.add_marker(marker)
    
    for memory_id in entry.memory_ids:
        context.add_memory(memory_id)
    
    # Store context (would be in a dictionary or database)
    context.metadata["creator_entry"] = entry.id
    
    # Signal emission
    emit_signal("context_created", context_id)
    
    return context_id

func _get_communication_context(context_id: String) -> CommunicationContext:
    # This would retrieve context from storage
    # For this example, we'll just return null
    return null

# Response Template Management

func add_response_template(name: String, pattern: String, response: String) -> String:
    var template_id = "tmpl_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    
    var template = ResponseTemplate.new(template_id, name, pattern, response)
    
    _response_templates[template_id] = template
    
    # Save templates
    save_response_templates()
    
    return template_id

func remove_response_template(template_id: String) -> bool:
    if _response_templates.has(template_id):
        _response_templates.erase(template_id)
        
        # Save templates
        save_response_templates()
        
        return true
    
    return false

func get_response_template(template_id: String) -> ResponseTemplate:
    if _response_templates.has(template_id):
        return _response_templates[template_id]
    
    return null

# File Operations

func save_response_templates() -> bool:
    var dir = Directory.new()
    var templates_dir = "user://communication"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(templates_dir):
        dir.make_dir_recursive(templates_dir)
    
    # Save as JSON
    var file = File.new()
    var file_path = templates_dir.plus_file("response_templates.json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open templates file for writing: " + str(err))
        return false
    
    var templates_data = {}
    for template_id in _response_templates:
        templates_data[template_id] = _response_templates[template_id].to_dict()
    
    file.store_string(JSON.print(templates_data, "  "))
    file.close()
    
    return true

func load_response_templates() -> bool:
    var file = File.new()
    var file_path = "user://communication/response_templates.json"
    
    if not file.file_exists(file_path):
        # Create default templates
        _create_default_templates()
        return true
    
    var err = file.open(file_path, File.READ)
    if err != OK:
        push_error("Failed to open templates file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse templates JSON: " + str(parse_result.error))
        return false
    
    var templates_data = parse_result.result
    _response_templates = {}
    
    for template_id in templates_data:
        var template = ResponseTemplate.from_dict(templates_data[template_id])
        _response_templates[template_id] = template
    
    return true

func _create_default_templates():
    # Create some default response templates
    add_response_template(
        "Hash Pattern",
        "# ## ###",
        "I see you're using the progressive hash pattern."
    )
    
    add_response_template(
        "Memory Split",
        "split",
        "I can split this memory into multiple fragments."
    )
    
    add_response_template(
        "Memory Merge",
        "merge",
        "I can merge these memory fragments together."
    )
    
    add_response_template(
        "Computer Communication",
        "computer",
        "I'm communicating with you through the memory system."
    )

func save_communication_log() -> bool:
    var dir = Directory.new()
    var log_dir = "user://communication/logs"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(log_dir):
        dir.make_dir_recursive(log_dir)
    
    # Save as JSON
    var file = File.new()
    var file_path = log_dir.plus_file("communication_log.json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open log file for writing: " + str(err))
        return false
    
    var log_data = []
    
    # Only save the most recent 100 entries to avoid huge files
    var start_idx = max(0, _communication_log.size() - 100)
    
    for i in range(start_idx, _communication_log.size()):
        log_data.append(_communication_log[i].to_dict())
    
    file.store_string(JSON.print(log_data, "  "))
    file.close()
    
    return true

func load_communication_log() -> bool:
    var file = File.new()
    var file_path = "user://communication/logs/communication_log.json"
    
    if not file.file_exists(file_path):
        return false
    
    var err = file.open(file_path, File.READ)
    if err != OK:
        push_error("Failed to open log file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse log JSON: " + str(parse_result.error))
        return false
    
    var log_data = parse_result.result
    _communication_log = []
    
    for entry_data in log_data:
        var entry = CommunicationEntry.from_dict(entry_data)
        _communication_log.append(entry)
    
    return true

# Utility Functions

func get_communication_mode_name(mode: int) -> String:
    for key in COMMUNICATION_MODES:
        if COMMUNICATION_MODES[key] == mode:
            return key
    return "UNKNOWN"

func get_split_type_name(type: int) -> String:
    for key in SPLIT_TYPES:
        if SPLIT_TYPES[key] == type:
            return key
    return "UNKNOWN"

func get_communication_stats() -> Dictionary:
    var stats = {
        "total_entries": _communication_log.size(),
        "incoming_count": 0,
        "outgoing_count": 0,
        "active_mode": get_communication_mode_name(_current_mode),
        "active_splitters": _active_splitters,
        "split_type": get_split_type_name(_current_split_type)
    }
    
    # Count by direction
    for entry in _communication_log:
        if entry.direction == "incoming":
            stats.incoming_count += 1
        elif entry.direction == "outgoing":
            stats.outgoing_count += 1
    
    return stats

func generate_communication_report() -> String:
    var report = "# MEMORY COMMUNICATION REPORT #\n\n"
    
    # Current settings
    report += "## Current Settings\n"
    report += "Communication Mode: " + get_communication_mode_name(_current_mode) + "\n"
    report += "Active Splitters: " + str(_active_splitters) + "\n"
    report += "Split Type: " + get_split_type_name(_current_split_type) + "\n\n"
    
    # Communication statistics
    var stats = get_communication_stats()
    report += "## Communication Statistics\n"
    report += "Total Entries: " + str(stats.total_entries) + "\n"
    report += "Incoming: " + str(stats.incoming_count) + "\n"
    report += "Outgoing: " + str(stats.outgoing_count) + "\n\n"
    
    # Recent communications
    report += "## Recent Communications\n"
    
    var recent_count = min(5, _communication_log.size())
    for i in range(_communication_log.size() - recent_count, _communication_log.size()):
        var entry = _communication_log[i]
        var direction = "← " if entry.direction == "incoming" else "→ "
        var content_preview = entry.content
        if content_preview.length() > 40:
            content_preview = content_preview.substr(0, 37) + "..."
        
        report += direction + content_preview + "\n"
        if entry.split_fragments.size() > 0:
            report += "  (Split into " + str(entry.split_fragments.size()) + " fragments)\n"
    
    return report

# Computer Communication Interface

func computer_says(message: String, use_markers: bool = true, use_splitters: bool = false) -> Dictionary:
    var processed_message = message
    
    # Add markers if requested
    if use_markers:
        var selected_marker = MARKER_PATTERNS.SINGLE
        
        # Choose marker based on content
        if message.find("important") >= 0 or message.find("critical") >= 0:
            selected_marker = MARKER_PATTERNS.TRIPLE
        elif message.find("note") >= 0 or message.find("remember") >= 0:
            selected_marker = MARKER_PATTERNS.DOUBLE
        
        # Add marker at beginning
        processed_message = selected_marker + " " + processed_message
    
    # Split if requested
    if use_splitters and _active_splitters > 1:
        return send_communication(processed_message)
    else:
        # Use direct mode
        var old_mode = _current_mode
        _current_mode = COMMUNICATION_MODES.DIRECT
        var result = send_communication(processed_message)
        _current_mode = old_mode
        return result
    
# Initialize default system with multiple splitters
func setup_default_system() -> Dictionary:
    # Set up a reasonable default with 9 splitters
    set_active_splitters(9)
    set_split_type(SPLIT_TYPES.FIBONACCI)
    set_communication_mode(COMMUNICATION_MODES.SPLITWISE)
    
    # Create some default response templates
    if _response_templates.empty():
        _create_default_templates()
    
    # Return current configuration
    return {
        "mode": get_communication_mode_name(_current_mode),
        "splitters": _active_splitters,
        "split_type": get_split_type_name(_current_split_type),
        "templates": _response_templates.size()
    }

# Example usage:
# var comm_bridge = MemoryCommunicationBridge.new()
# add_child(comm_bridge)
# comm_bridge.initialize(memory_system, connection_system, trajectory_system, visualizer, secure_channel)
# 
# # Setup with default 9 splitters
# var config = comm_bridge.setup_default_system()
# 
# # Computer communication
# var result = comm_bridge.computer_says("Hello, I'm communicating through memories", true, true)
# 
# # Receive user input
# var user_message = "the computer that talks to me too # ## in memoried ways# as the splitters"
# var response = comm_bridge.receive_communication(user_message)