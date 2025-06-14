extends Node
class_name MemoryRehabSystem

# Memory Rehabilitation System
# Enhances memory organization using # instead of / or // 
# Creates dimensional memory mapping for better visual representation

# System Constants 
const MEMORY_DIMENSIONS = {
    "RECALL": 1,      # Basic memory retrieval
    "STORE": 2,       # Memory storage and organization
    "ASSOCIATE": 3,   # Memory relationship mapping
    "TRANSFORM": 4,   # Memory transformation and adaptation
    "REFLECT": 5,     # Meta-memory concepts
    "INTEGRATE": 6,   # Integration with other systems
    "CREATE": 7,      # Creation from memory fragments
    "NETWORK": 8,     # Memory network interactions
    "HARMONIZE": 9,   # Memory pattern alignment
    "UNIFY": 10,      # Holistic memory synthesis
    "TRANSCEND": 11,  # Beyond conventional memory
    "META": 12        # Meta-dimensional memory
}

# Memory Structure Tags
const MEMORY_TAGS = {
    "CORE": "##",         # Core memory concept
    "FRAGMENT": "#-",     # Memory fragment
    "LINK": "#>",         # Memory link to another concept
    "EVOLUTION": "#^",    # Memory evolutionary progress
    "INSIGHT": "#*",      # Special insight or realization
    "TIME": "#t",         # Temporal memory marker
    "SPACE": "#s",        # Spatial memory marker
    "EMOTION": "#e",      # Emotional memory component
    "QUESTION": "#?",     # Memory question or uncertainty
    "ANSWER": "#!",       # Memory answer or resolution
    "META": "#m",         # Meta-memory concept
    "CONFLICT": "#x"      # Conflicting memory data
}

# File System Integration
const MEMORY_DIR = "/mnt/c/Users/Percision 15/MemoryRehab"
const MEMORY_EXTENSION = ".mem"

# Memory Structure
class MemoryNode:
    var id: String
    var content: String
    var tags = []
    var dimension: int
    var connections = []
    var metadata = {}
    var timestamp: int
    
    func _init(p_id: String, p_content: String, p_dimension: int = 1):
        id = p_id
        content = p_content
        dimension = p_dimension
        timestamp = OS.get_unix_time()
    
    func add_tag(tag: String):
        if not tags.has(tag):
            tags.append(tag)
    
    func add_connection(target_id: String):
        if not connections.has(target_id):
            connections.append(target_id)
    
    func to_formatted_string() -> String:
        var header = "# MEMORY NODE: " + id + " #"
        var dim_line = "# DIMENSION: " + str(dimension) + " #"
        var tag_line = "# TAGS: " + PoolStringArray(tags).join(", ") + " #"
        var timestamp_line = "# TIMESTAMP: " + str(timestamp) + " #"
        var separator = "# " + "=".repeat(40) + " #"
        
        var result = separator + "\n"
        result += header + "\n"
        result += dim_line + "\n"
        result += tag_line + "\n"
        result += timestamp_line + "\n"
        result += separator + "\n\n"
        
        # Format content with memory tags
        var formatted_content = format_content_with_tags(content)
        result += formatted_content + "\n\n"
        
        # Add connections
        if connections.size() > 0:
            result += "# CONNECTIONS:\n"
            for conn in connections:
                result += "#> " + conn + "\n"
            result += "\n"
        
        result += separator + "\n"
        return result
    
    func format_content_with_tags(text: String) -> String:
        var lines = text.split("\n")
        var formatted_lines = []
        
        for line in lines:
            var formatted = line
            
            # Check if line already has a memory tag
            var has_tag = false
            for tag in MEMORY_TAGS.values():
                if line.strip_edges().begins_with(tag):
                    has_tag = true
                    break
            
            # Add default tag if no tag present and not empty line
            if not has_tag and line.strip_edges().length() > 0:
                formatted = "# " + line
            
            formatted_lines.append(formatted)
        
        return "\n".join(formatted_lines)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "content": content,
            "tags": tags,
            "dimension": dimension,
            "connections": connections,
            "metadata": metadata,
            "timestamp": timestamp
        }
    
    static func from_dict(data: Dictionary) -> MemoryNode:
        var node = MemoryNode.new(data.id, data.content, data.dimension)
        node.tags = data.tags.duplicate()
        node.connections = data.connections.duplicate()
        node.metadata = data.metadata.duplicate()
        node.timestamp = data.timestamp
        return node

# System Variables
var _memories = {}  # id -> MemoryNode
var _dimension_indices = {}  # dimension -> [id]
var _tag_indices = {}  # tag -> [id]
var _file = File.new()
var _dir = Directory.new()
var _initialized = false

# Signals
signal memory_created(id, dimension)
signal memory_updated(id)
signal memory_connected(source_id, target_id)
signal memory_dimension_changed(id, old_dimension, new_dimension)

# System Initialization
func _ready():
    initialize()

func initialize():
    # Create memory directory if it doesn't exist
    if not _dir.dir_exists(MEMORY_DIR):
        var err = _dir.make_dir_recursive(MEMORY_DIR)
        if err != OK:
            push_error("Failed to create memory directory: " + str(err))
            return false
    
    # Initialize dimension indices
    for dimension in MEMORY_DIMENSIONS.values():
        _dimension_indices[dimension] = []
    
    # Initialize tag indices
    for tag in MEMORY_TAGS.values():
        _tag_indices[tag] = []
    
    # Load existing memories if any
    load_memories()
    
    _initialized = true
    return true

# Memory Management Functions
func create_memory(content: String, dimension: int = 1, tags = []) -> String:
    if not _initialized:
        initialize()
    
    var memory_id = "mem_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    var memory = MemoryNode.new(memory_id, content, dimension)
    
    # Add tags
    for tag in tags:
        memory.add_tag(tag)
    
    # Store memory
    _memories[memory_id] = memory
    
    # Update indices
    _dimension_indices[dimension].append(memory_id)
    for tag in tags:
        if not _tag_indices.has(tag):
            _tag_indices[tag] = []
        _tag_indices[tag].append(memory_id)
    
    # Save to file
    save_memory(memory)
    
    emit_signal("memory_created", memory_id, dimension)
    
    return memory_id

func update_memory(memory_id: String, content: String) -> bool:
    if not _memories.has(memory_id):
        return false
    
    var memory = _memories[memory_id]
    memory.content = content
    
    # Save to file
    save_memory(memory)
    
    emit_signal("memory_updated", memory_id)
    
    return true

func connect_memories(source_id: String, target_id: String) -> bool:
    if not _memories.has(source_id) or not _memories.has(target_id):
        return false
    
    var source = _memories[source_id]
    source.add_connection(target_id)
    
    # Save to file
    save_memory(source)
    
    emit_signal("memory_connected", source_id, target_id)
    
    return true

func change_memory_dimension(memory_id: String, new_dimension: int) -> bool:
    if not _memories.has(memory_id) or not _dimension_indices.has(new_dimension):
        return false
    
    var memory = _memories[memory_id]
    var old_dimension = memory.dimension
    
    # Update dimension
    memory.dimension = new_dimension
    
    # Update indices
    _dimension_indices[old_dimension].erase(memory_id)
    _dimension_indices[new_dimension].append(memory_id)
    
    # Save to file
    save_memory(memory)
    
    emit_signal("memory_dimension_changed", memory_id, old_dimension, new_dimension)
    
    return true

func add_tag_to_memory(memory_id: String, tag: String) -> bool:
    if not _memories.has(memory_id):
        return false
    
    var memory = _memories[memory_id]
    memory.add_tag(tag)
    
    # Update indices
    if not _tag_indices.has(tag):
        _tag_indices[tag] = []
    _tag_indices[tag].append(memory_id)
    
    # Save to file
    save_memory(memory)
    
    return true

# Memory Retrieval Functions
func get_memory(memory_id: String) -> MemoryNode:
    if _memories.has(memory_id):
        return _memories[memory_id]
    return null

func get_memories_by_dimension(dimension: int) -> Array:
    if _dimension_indices.has(dimension):
        var result = []
        for id in _dimension_indices[dimension]:
            result.append(_memories[id])
        return result
    return []

func get_memories_by_tag(tag: String) -> Array:
    if _tag_indices.has(tag):
        var result = []
        for id in _tag_indices[tag]:
            result.append(_memories[id])
        return result
    return []

func search_memories(query: String) -> Array:
    var results = []
    
    for id in _memories:
        var memory = _memories[id]
        if memory.content.to_lower().find(query.to_lower()) >= 0:
            results.append(memory)
    
    return results

func get_connected_memories(memory_id: String) -> Array:
    if not _memories.has(memory_id):
        return []
    
    var memory = _memories[memory_id]
    var connected = []
    
    for conn_id in memory.connections:
        if _memories.has(conn_id):
            connected.append(_memories[conn_id])
    
    return connected

# File System Functions
func save_memory(memory: MemoryNode) -> bool:
    var file_path = MEMORY_DIR.plus_file(memory.id + MEMORY_EXTENSION)
    
    var err = _file.open(file_path, File.WRITE)
    if err != OK:
        push_error("Failed to open memory file for writing: " + str(err))
        return false
    
    # Save formatted memory
    _file.store_string(memory.to_formatted_string())
    _file.close()
    
    # Also save as JSON for better data retrieval
    file_path = MEMORY_DIR.plus_file(memory.id + ".json")
    err = _file.open(file_path, File.WRITE)
    if err != OK:
        push_error("Failed to open memory JSON file for writing: " + str(err))
        return false
    
    _file.store_string(JSON.print(memory.to_dict(), "  "))
    _file.close()
    
    return true

func load_memories() -> bool:
    if not _dir.dir_exists(MEMORY_DIR):
        return false
    
    var err = _dir.open(MEMORY_DIR)
    if err != OK:
        push_error("Failed to open memory directory: " + str(err))
        return false
    
    _dir.list_dir_begin(true, true)
    var file_name = _dir.get_next()
    
    while file_name != "":
        if file_name.ends_with(".json"):
            load_memory_from_file(MEMORY_DIR.plus_file(file_name))
        file_name = _dir.get_next()
    
    _dir.list_dir_end()
    
    return true

func load_memory_from_file(file_path: String) -> bool:
    var err = _file.open(file_path, File.READ)
    if err != OK:
        push_error("Failed to open memory file for reading: " + str(err))
        return false
    
    var content = _file.get_as_text()
    _file.close()
    
    var json = JSON.parse(content)
    if json.error != OK:
        push_error("Failed to parse memory JSON: " + str(json.error))
        return false
    
    var data = json.result
    var memory = MemoryNode.from_dict(data)
    
    # Store memory
    _memories[memory.id] = memory
    
    # Update indices
    if not _dimension_indices.has(memory.dimension):
        _dimension_indices[memory.dimension] = []
    _dimension_indices[memory.dimension].append(memory.id)
    
    for tag in memory.tags:
        if not _tag_indices.has(tag):
            _tag_indices[tag] = []
        _tag_indices[tag].append(memory.id)
    
    return true

# Memory Analysis and Visualization Functions
func generate_memory_report() -> String:
    var report = "# MEMORY SYSTEM REPORT #\n\n"
    
    # Overall stats
    report += "## OVERALL STATISTICS ##\n"
    report += "# Total memories: " + str(_memories.size()) + "\n"
    
    # Dimension breakdown
    report += "\n## DIMENSION BREAKDOWN ##\n"
    for dimension in _dimension_indices:
        var count = _dimension_indices[dimension].size()
        var dimension_name = ""
        
        # Find dimension name
        for name in MEMORY_DIMENSIONS:
            if MEMORY_DIMENSIONS[name] == dimension:
                dimension_name = name
                break
        
        report += "# Dimension " + str(dimension) + " (" + dimension_name + "): " + str(count) + " memories\n"
    
    # Tag breakdown
    report += "\n## TAG BREAKDOWN ##\n"
    for tag in _tag_indices:
        var count = _tag_indices[tag].size()
        report += "# Tag " + tag + ": " + str(count) + " memories\n"
    
    # Connections
    var total_connections = 0
    var most_connected = {"id": "", "count": 0}
    
    for id in _memories:
        var conn_count = _memories[id].connections.size()
        total_connections += conn_count
        
        if conn_count > most_connected.count:
            most_connected.id = id
            most_connected.count = conn_count
    
    report += "\n## CONNECTION STATISTICS ##\n"
    report += "# Total connections: " + str(total_connections) + "\n"
    if most_connected.id != "":
        report += "# Most connected memory: " + most_connected.id + " with " + str(most_connected.count) + " connections\n"
    
    return report

func generate_memory_network_visualization() -> String:
    var viz = "# MEMORY NETWORK VISUALIZATION #\n\n"
    
    for dimension in _dimension_indices:
        if _dimension_indices[dimension].size() > 0:
            var dimension_name = ""
            for name in MEMORY_DIMENSIONS:
                if MEMORY_DIMENSIONS[name] == dimension:
                    dimension_name = name
                    break
            
            viz += "## DIMENSION " + str(dimension) + ": " + dimension_name + " ##\n\n"
            
            for id in _dimension_indices[dimension]:
                var memory = _memories[id]
                viz += "# " + id + " #\n"
                
                if memory.connections.size() > 0:
                    for conn_id in memory.connections:
                        if _memories.has(conn_id):
                            var conn_memory = _memories[conn_id]
                            viz += "#> " + id + " --> " + conn_id + " (" + str(conn_memory.dimension) + ")\n"
                
                viz += "\n"
            
            viz += "\n"
    
    return viz

# Utility functions
func get_formatted_memory_content(memory_id: String) -> String:
    if not _memories.has(memory_id):
        return ""
    
    return _memories[memory_id].to_formatted_string()

func export_memory_system() -> Dictionary:
    var export_data = {
        "memories": {},
        "system_info": {
            "version": "1.0",
            "memory_count": _memories.size(),
            "exported_at": OS.get_unix_time(),
            "dimensions": MEMORY_DIMENSIONS
        }
    }
    
    for id in _memories:
        export_data.memories[id] = _memories[id].to_dict()
    
    return export_data

func import_memory_system(data: Dictionary) -> bool:
    if not data.has("memories") or not data.has("system_info"):
        return false
    
    # Clear existing memories
    _memories.clear()
    for dim in _dimension_indices:
        _dimension_indices[dim].clear()
    for tag in _tag_indices:
        _tag_indices[tag].clear()
    
    # Import memories
    for id in data.memories:
        var memory_data = data.memories[id]
        var memory = MemoryNode.from_dict(memory_data)
        
        # Store memory
        _memories[id] = memory
        
        # Update indices
        if not _dimension_indices.has(memory.dimension):
            _dimension_indices[memory.dimension] = []
        _dimension_indices[memory.dimension].append(id)
        
        for tag in memory.tags:
            if not _tag_indices.has(tag):
                _tag_indices[tag] = []
            _tag_indices[tag].append(id)
        
        # Save to file
        save_memory(memory)
    
    return true

# Example Usage
# var rehab_system = MemoryRehabSystem.new()
# rehab_system.initialize()
# 
# var memory_id = rehab_system.create_memory("This is a test memory using # style formatting", 3, ["CORE", "TEST"])
# var another_id = rehab_system.create_memory("This is connected to the first memory", 2, ["FRAGMENT"])
# rehab_system.connect_memories(memory_id, another_id)
# 
# print(rehab_system.generate_memory_report())