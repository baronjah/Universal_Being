extends Node
class_name MemoryConnectionSystem

# Memory Connection System
# -----------------------
# Enhances connections between memory fragments using # tags and dimensional linking
# Allows for reason-based memory associations and temporal syncing

# Connection Types
const CONNECTION_TYPES = {
    "SEQUENTIAL": "#>",  # Sequential flow connection
    "CAUSAL": "#=>",     # Cause and effect connection
    "RELATED": "#~",     # Related concept connection
    "OPPOSING": "#<>",   # Opposing or contrasting connection
    "EVOLVING": "#^",    # Evolutionary progression
    "CONTAINS": "#[]",   # Container/contained relationship
    "TRANSFORMS": "#->", # Transformation relationship
    "CYCLES": "#○",      # Cyclical relationship
    "SPLITS": "#Y",      # Diverging paths
    "MERGES": "#Λ",      # Converging paths
    "REASON": "#?",      # Reasoning or explanation
    "META": "#M"         # Meta-connection (connection about connections)
}

# Connection Strength
enum ConnectionStrength {
    WEAK = 1,      # Subtle, tentative connection
    MODERATE = 2,  # Clear but not dominant
    STRONG = 3,    # Prominent relationship
    CRITICAL = 4   # Essential, defining relationship
}

# Temporal Patterns
enum TemporalPattern {
    INSTANT,       # One-time, immediate
    RECURRING,     # Repeating at intervals
    CONTINUOUS,    # Ongoing, persistent
    EVOLVING,      # Changing over time
    CYCLICAL       # Regularly returning to origin
}

# Connection Structures
class MemoryConnection:
    var id: String
    var source_id: String
    var target_id: String
    var type: String  # One of CONNECTION_TYPES
    var strength: int # ConnectionStrength
    var description: String
    var metadata = {}
    var temporal_pattern: int # TemporalPattern
    var reason: String
    var created_at: int
    var updated_at: int
    
    func _init(p_id: String, p_source_id: String, p_target_id: String, p_type: String):
        id = p_id
        source_id = p_source_id
        target_id = p_target_id
        type = p_type
        strength = ConnectionStrength.MODERATE
        created_at = OS.get_unix_time()
        updated_at = created_at
        temporal_pattern = TemporalPattern.INSTANT
    
    func set_reason(p_reason: String):
        reason = p_reason
        updated_at = OS.get_unix_time()
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "source_id": source_id,
            "target_id": target_id,
            "type": type,
            "strength": strength,
            "description": description,
            "metadata": metadata,
            "temporal_pattern": temporal_pattern,
            "reason": reason,
            "created_at": created_at,
            "updated_at": updated_at
        }
    
    static func from_dict(data: Dictionary) -> MemoryConnection:
        var conn = MemoryConnection.new(
            data.id,
            data.source_id,
            data.target_id,
            data.type
        )
        conn.strength = data.strength
        conn.description = data.description
        conn.metadata = data.metadata.duplicate() if data.has("metadata") else {}
        conn.temporal_pattern = data.temporal_pattern
        conn.reason = data.reason
        conn.created_at = data.created_at
        conn.updated_at = data.updated_at
        return conn

class ConnectionCluster:
    var id: String
    var name: String
    var connections = [] # Array of connection IDs
    var pattern: String  # Pattern or shape of connections
    var metadata = {}
    var created_at: int
    var updated_at: int
    
    func _init(p_id: String, p_name: String):
        id = p_id
        name = p_name
        created_at = OS.get_unix_time()
        updated_at = created_at
    
    func add_connection(connection_id: String):
        if not connections.has(connection_id):
            connections.append(connection_id)
            updated_at = OS.get_unix_time()
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
            "connections": connections,
            "pattern": pattern,
            "metadata": metadata,
            "created_at": created_at,
            "updated_at": updated_at
        }
    
    static func from_dict(data: Dictionary) -> ConnectionCluster:
        var cluster = ConnectionCluster.new(data.id, data.name)
        cluster.connections = data.connections.duplicate()
        cluster.pattern = data.pattern
        cluster.metadata = data.metadata.duplicate() if data.has("metadata") else {}
        cluster.created_at = data.created_at
        cluster.updated_at = data.updated_at
        return cluster

# System variables
var _connections = {} # id -> MemoryConnection
var _clusters = {}    # id -> ConnectionCluster
var _memory_indices = {} # memory_id -> [connection_ids]
var _pattern_indices = {} # pattern_type -> [connection_ids]
var _temporal_indices = {} # temporal_pattern -> [connection_ids]
var _rehab_system = null # Reference to MemoryRehabSystem
var _knowledge_system = null # Reference to WishKnowledgeSystem

# Signals
signal connection_created(connection_id, source_id, target_id, type)
signal connection_updated(connection_id)
signal cluster_created(cluster_id, name)
signal pattern_detected(pattern_type, connection_ids)

# System Initialization
func _ready():
    pass

func initialize(rehab_system = null, knowledge_system = null):
    _rehab_system = rehab_system
    _knowledge_system = knowledge_system
    
    # Initialize indices
    for pattern in TemporalPattern.values():
        _temporal_indices[pattern] = []
    
    for conn_type in CONNECTION_TYPES.values():
        _pattern_indices[conn_type] = []
    
    # Load existing connections
    load_connections()
    
    return true

# Connection Management
func connect_memories(source_id: String, target_id: String, type: String, reason: String = "") -> String:
    if not CONNECTION_TYPES.values().has(type):
        push_error("Invalid connection type: " + type)
        return ""
    
    # Generate unique connection ID
    var connection_id = "conn_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    var connection = MemoryConnection.new(connection_id, source_id, target_id, type)
    
    if reason:
        connection.set_reason(reason)
    
    # Store connection
    _connections[connection_id] = connection
    
    # Update indices
    if not _memory_indices.has(source_id):
        _memory_indices[source_id] = []
    _memory_indices[source_id].append(connection_id)
    
    if not _memory_indices.has(target_id):
        _memory_indices[target_id] = []
    _memory_indices[target_id].append(connection_id)
    
    if not _pattern_indices.has(type):
        _pattern_indices[type] = []
    _pattern_indices[type].append(connection_id)
    
    if not _temporal_indices.has(connection.temporal_pattern):
        _temporal_indices[connection.temporal_pattern] = []
    _temporal_indices[connection.temporal_pattern].append(connection_id)
    
    # Save connection
    save_connection(connection)
    
    # Emit signal
    emit_signal("connection_created", connection_id, source_id, target_id, type)
    
    # Link to MemoryRehabSystem if available
    if _rehab_system:
        _rehab_system.connect_memories(source_id, target_id)
    
    detect_patterns()
    
    return connection_id

func update_connection_strength(connection_id: String, strength: int) -> bool:
    if not _connections.has(connection_id):
        return false
    
    if strength < ConnectionStrength.WEAK or strength > ConnectionStrength.CRITICAL:
        push_error("Invalid connection strength: " + str(strength))
        return false
    
    var connection = _connections[connection_id]
    connection.strength = strength
    connection.updated_at = OS.get_unix_time()
    
    # Save connection
    save_connection(connection)
    
    emit_signal("connection_updated", connection_id)
    
    return true

func update_connection_temporal_pattern(connection_id: String, pattern: int) -> bool:
    if not _connections.has(connection_id):
        return false
    
    var connection = _connections[connection_id]
    
    # Update indices
    _temporal_indices[connection.temporal_pattern].erase(connection_id)
    
    connection.temporal_pattern = pattern
    connection.updated_at = OS.get_unix_time()
    
    if not _temporal_indices.has(pattern):
        _temporal_indices[pattern] = []
    _temporal_indices[pattern].append(connection_id)
    
    # Save connection
    save_connection(connection)
    
    emit_signal("connection_updated", connection_id)
    
    return true

func create_cluster(name: String, connection_ids: Array = []) -> String:
    var cluster_id = "cluster_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    var cluster = ConnectionCluster.new(cluster_id, name)
    
    for conn_id in connection_ids:
        if _connections.has(conn_id):
            cluster.add_connection(conn_id)
    
    # Store cluster
    _clusters[cluster_id] = cluster
    
    # Save cluster
    save_cluster(cluster)
    
    emit_signal("cluster_created", cluster_id, name)
    
    return cluster_id

# Pattern Detection
func detect_patterns():
    # Detect typical connection patterns
    detect_causal_chains()
    detect_cycles()
    detect_frequent_splits()
    detect_knowledge_patterns()

func detect_causal_chains():
    # Look for chains of causal connections
    var causal_chains = []
    
    if _pattern_indices.has(CONNECTION_TYPES.CAUSAL):
        var causal_connections = []
        for conn_id in _pattern_indices[CONNECTION_TYPES.CAUSAL]:
            causal_connections.append(_connections[conn_id])
        
        # Build causal connection graph
        var graph = {}
        for conn in causal_connections:
            if not graph.has(conn.source_id):
                graph[conn.source_id] = []
            graph[conn.source_id].append(conn.target_id)
        
        # Find chains of at least 3 elements
        for start_id in graph.keys():
            var chain = find_chain(start_id, graph, 3)
            if chain.size() >= 3:
                causal_chains.append(chain)
        
        if causal_chains.size() > 0:
            for chain in causal_chains:
                var chain_ids = []
                for i in range(chain.size() - 1):
                    for conn in causal_connections:
                        if conn.source_id == chain[i] and conn.target_id == chain[i+1]:
                            chain_ids.append(conn.id)
                            break
                
                emit_signal("pattern_detected", "causal_chain", chain_ids)

func find_chain(start_id: String, graph: Dictionary, min_length: int, chain = null, visited = null) -> Array:
    if chain == null:
        chain = [start_id]
    
    if visited == null:
        visited = {start_id: true}
    
    if not graph.has(start_id) or graph[start_id].empty():
        return chain if chain.size() >= min_length else []
    
    var longest_chain = chain.duplicate()
    
    for next_id in graph[start_id]:
        if visited.has(next_id):
            continue
            
        var new_visited = visited.duplicate()
        new_visited[next_id] = true
        
        var new_chain = chain.duplicate()
        new_chain.append(next_id)
        
        var extended_chain = find_chain(next_id, graph, min_length, new_chain, new_visited)
        
        if extended_chain.size() > longest_chain.size():
            longest_chain = extended_chain
    
    return longest_chain

func detect_cycles():
    # Look for cyclic connection patterns
    var cycles = []
    
    # Focus on cycle connection type and related types
    var cycle_types = [CONNECTION_TYPES.CYCLES, CONNECTION_TYPES.SEQUENTIAL]
    var cycle_connections = []
    
    for type in cycle_types:
        if _pattern_indices.has(type):
            for conn_id in _pattern_indices[type]:
                cycle_connections.append(_connections[conn_id])
    
    # Build connection graph
    var graph = {}
    for conn in cycle_connections:
        if not graph.has(conn.source_id):
            graph[conn.source_id] = []
        graph[conn.source_id].append(conn.target_id)
    
    # Find cycles
    for start_id in graph.keys():
        var cycle = find_cycle(start_id, graph)
        if cycle.size() >= 3: # Only consider cycles with at least 3 elements
            cycles.append(cycle)
    
    if cycles.size() > 0:
        for cycle in cycles:
            var cycle_ids = []
            for i in range(cycle.size()):
                var src = cycle[i]
                var tgt = cycle[(i + 1) % cycle.size()]
                
                for conn in cycle_connections:
                    if conn.source_id == src and conn.target_id == tgt:
                        cycle_ids.append(conn.id)
                        break
            
            emit_signal("pattern_detected", "cycle", cycle_ids)

func find_cycle(start_id: String, graph: Dictionary, path = null, visited = null) -> Array:
    if path == null:
        path = [start_id]
    
    if visited == null:
        visited = {}
    
    visited[start_id] = true
    
    if not graph.has(start_id):
        return []
    
    for next_id in graph[start_id]:
        if path.has(next_id):
            if path[0] == next_id and path.size() > 2:
                return path # We found a cycle back to the start
            continue
        
        if visited.has(next_id):
            continue
        
        var new_path = path.duplicate()
        new_path.append(next_id)
        
        var new_visited = visited.duplicate()
        
        var cycle = find_cycle(next_id, graph, new_path, new_visited)
        if cycle.size() > 0:
            return cycle
    
    return []

func detect_frequent_splits():
    # Detect memory nodes that frequently split into multiple paths
    if not _pattern_indices.has(CONNECTION_TYPES.SPLITS):
        return
    
    var split_connections = []
    for conn_id in _pattern_indices[CONNECTION_TYPES.SPLITS]:
        split_connections.append(_connections[conn_id])
    
    # Count outgoing connections for each source
    var split_counts = {}
    for conn in _connections.values():
        if not split_counts.has(conn.source_id):
            split_counts[conn.source_id] = 0
        split_counts[conn.source_id] += 1
    
    # Find sources with many outgoing connections
    var frequent_splits = []
    for source_id in split_counts:
        if split_counts[source_id] >= 3: # Consider 3+ outgoing connections a split node
            var outgoing_connections = []
            for conn in _connections.values():
                if conn.source_id == source_id:
                    outgoing_connections.append(conn.id)
            
            frequent_splits.append({
                "source_id": source_id,
                "connection_count": split_counts[source_id],
                "connections": outgoing_connections
            })
    
    if frequent_splits.size() > 0:
        for split in frequent_splits:
            emit_signal("pattern_detected", "split_node", split.connections)

func detect_knowledge_patterns():
    # If we have a connection to the knowledge system, look for patterns
    if not _knowledge_system:
        return
    
    # This would analyze connections for patterns relevant to the knowledge system
    # For now, this is just a placeholder
    pass

# Connection Retrieval
func get_connection(connection_id: String) -> MemoryConnection:
    if _connections.has(connection_id):
        return _connections[connection_id]
    return null

func get_connections_for_memory(memory_id: String) -> Array:
    var results = []
    
    if _memory_indices.has(memory_id):
        for conn_id in _memory_indices[memory_id]:
            if _connections.has(conn_id):
                results.append(_connections[conn_id])
    
    return results

func get_connected_memories(memory_id: String, type: String = "", only_targets: bool = false) -> Array:
    var connected_memories = []
    
    if _memory_indices.has(memory_id):
        for conn_id in _memory_indices[memory_id]:
            var conn = _connections[conn_id]
            
            # Skip if not matching the specified type
            if type and conn.type != type:
                continue
            
            if only_targets:
                # Only include target memories
                if conn.source_id == memory_id:
                    connected_memories.append(conn.target_id)
            else:
                # Include both source and target
                if conn.source_id == memory_id:
                    connected_memories.append(conn.target_id)
                elif conn.target_id == memory_id:
                    connected_memories.append(conn.source_id)
    
    return connected_memories

func get_connections_by_type(type: String) -> Array:
    var results = []
    
    if _pattern_indices.has(type):
        for conn_id in _pattern_indices[type]:
            if _connections.has(conn_id):
                results.append(_connections[conn_id])
    
    return results

func get_connections_by_temporal_pattern(pattern: int) -> Array:
    var results = []
    
    if _temporal_indices.has(pattern):
        for conn_id in _temporal_indices[pattern]:
            if _connections.has(conn_id):
                results.append(_connections[conn_id])
    
    return results

func get_connections_by_reason(reason_fragment: String) -> Array:
    var results = []
    
    for conn in _connections.values():
        if conn.reason and conn.reason.to_lower().find(reason_fragment.to_lower()) >= 0:
            results.append(conn)
    
    return results

# Cluster Management
func get_cluster(cluster_id: String) -> ConnectionCluster:
    if _clusters.has(cluster_id):
        return _clusters[cluster_id]
    return null

func add_connection_to_cluster(cluster_id: String, connection_id: String) -> bool:
    if not _clusters.has(cluster_id) or not _connections.has(connection_id):
        return false
    
    _clusters[cluster_id].add_connection(connection_id)
    
    # Save cluster
    save_cluster(_clusters[cluster_id])
    
    return true

# File Operations
func save_connection(connection: MemoryConnection) -> bool:
    var dir = Directory.new()
    var connection_dir = "user://connections"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(connection_dir):
        dir.make_dir_recursive(connection_dir)
    
    # Save as JSON
    var file = File.new()
    var file_path = connection_dir.plus_file(connection.id + ".json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open connection file for writing: " + str(err))
        return false
    
    file.store_string(JSON.print(connection.to_dict(), "  "))
    file.close()
    
    return true

func save_cluster(cluster: ConnectionCluster) -> bool:
    var dir = Directory.new()
    var cluster_dir = "user://connection_clusters"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(cluster_dir):
        dir.make_dir_recursive(cluster_dir)
    
    # Save as JSON
    var file = File.new()
    var file_path = cluster_dir.plus_file(cluster.id + ".json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open cluster file for writing: " + str(err))
        return false
    
    file.store_string(JSON.print(cluster.to_dict(), "  "))
    file.close()
    
    return true

func load_connections() -> bool:
    var dir = Directory.new()
    var connection_dir = "user://connections"
    var cluster_dir = "user://connection_clusters"
    
    # Load connections
    if dir.dir_exists(connection_dir):
        dir.open(connection_dir)
        dir.list_dir_begin(true, true)
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".json"):
                var file_path = connection_dir.plus_file(file_name)
                load_connection_from_file(file_path)
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    # Load clusters
    if dir.dir_exists(cluster_dir):
        dir.open(cluster_dir)
        dir.list_dir_begin(true, true)
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name.ends_with(".json"):
                var file_path = cluster_dir.plus_file(file_name)
                load_cluster_from_file(file_path)
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    return true

func load_connection_from_file(file_path: String) -> bool:
    var file = File.new()
    var err = file.open(file_path, File.READ)
    
    if err != OK:
        push_error("Failed to open connection file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse connection JSON: " + str(parse_result.error))
        return false
    
    var connection_data = parse_result.result
    var connection = MemoryConnection.from_dict(connection_data)
    
    # Store connection
    _connections[connection.id] = connection
    
    # Update indices
    if not _memory_indices.has(connection.source_id):
        _memory_indices[connection.source_id] = []
    _memory_indices[connection.source_id].append(connection.id)
    
    if not _memory_indices.has(connection.target_id):
        _memory_indices[connection.target_id] = []
    _memory_indices[connection.target_id].append(connection.id)
    
    if not _pattern_indices.has(connection.type):
        _pattern_indices[connection.type] = []
    _pattern_indices[connection.type].append(connection.id)
    
    if not _temporal_indices.has(connection.temporal_pattern):
        _temporal_indices[connection.temporal_pattern] = []
    _temporal_indices[connection.temporal_pattern].append(connection.id)
    
    return true

func load_cluster_from_file(file_path: String) -> bool:
    var file = File.new()
    var err = file.open(file_path, File.READ)
    
    if err != OK:
        push_error("Failed to open cluster file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse cluster JSON: " + str(parse_result.error))
        return false
    
    var cluster_data = parse_result.result
    var cluster = ConnectionCluster.from_dict(cluster_data)
    
    # Store cluster
    _clusters[cluster.id] = cluster
    
    return true

# Visualization Methods
func generate_connection_visualization() -> String:
    var viz = "# MEMORY CONNECTION VISUALIZATION #\n\n"
    
    # Create visualization based on connection types
    for conn_type in CONNECTION_TYPES:
        var type_marker = CONNECTION_TYPES[conn_type]
        
        if _pattern_indices.has(type_marker) and _pattern_indices[type_marker].size() > 0:
            viz += "## " + conn_type + " CONNECTIONS (" + type_marker + ") ##\n\n"
            
            for conn_id in _pattern_indices[type_marker]:
                var conn = _connections[conn_id]
                viz += type_marker + " " + conn.source_id + " -> " + conn.target_id
                
                if conn.reason:
                    viz += " (" + conn.reason + ")"
                    
                viz += "\n"
            
            viz += "\n"
    
    # Add some clusters visualization
    if _clusters.size() > 0:
        viz += "## CONNECTION CLUSTERS ##\n\n"
        
        for cluster_id in _clusters:
            var cluster = _clusters[cluster_id]
            viz += "# CLUSTER: " + cluster.name + " #\n"
            
            for conn_id in cluster.connections:
                if _connections.has(conn_id):
                    var conn = _connections[conn_id]
                    viz += "  " + conn.type + " " + conn.source_id + " -> " + conn.target_id + "\n"
            
            viz += "\n"
    
    return viz

func generate_memory_map(memory_id: String, depth: int = 2) -> String:
    if not _memory_indices.has(memory_id):
        return "# No connections found for memory " + memory_id + " #"
    
    var map = "# MEMORY MAP FOR " + memory_id + " #\n\n"
    var visited = {}
    
    _build_memory_map(memory_id, map, "", 0, depth, visited)
    
    return map

func _build_memory_map(memory_id: String, map: String, indent: String, current_depth: int, max_depth: int, visited: Dictionary):
    visited[memory_id] = true
    
    if current_depth > max_depth:
        return
    
    if _memory_indices.has(memory_id):
        for conn_id in _memory_indices[memory_id]:
            var conn = _connections[conn_id]
            
            var target_id = ""
            if conn.source_id == memory_id:
                target_id = conn.target_id
                map += indent + conn.type + " -> " + target_id
            elif conn.target_id == memory_id:
                target_id = conn.source_id
                map += indent + conn.type + " <- " + target_id
            else:
                continue
            
            if conn.reason:
                map += " (" + conn.reason + ")"
            
            map += "\n"
            
            if target_id and not visited.has(target_id):
                _build_memory_map(target_id, map, indent + "  ", current_depth + 1, max_depth, visited)

# System Analysis
func generate_connection_stats() -> Dictionary:
    var stats = {
        "total_connections": _connections.size(),
        "total_clusters": _clusters.size(),
        "connection_types": {},
        "temporal_patterns": {},
        "most_connected_memories": []
    }
    
    # Count by type
    for type in CONNECTION_TYPES.values():
        stats.connection_types[type] = _pattern_indices.has(type) ? _pattern_indices[type].size() : 0
    
    # Count by temporal pattern
    for pattern in TemporalPattern.values():
        stats.temporal_patterns[pattern] = _temporal_indices.has(pattern) ? _temporal_indices[pattern].size() : 0
    
    # Find most connected memories
    var memory_connection_counts = {}
    
    for memory_id in _memory_indices:
        memory_connection_counts[memory_id] = _memory_indices[memory_id].size()
    
    var sorted_memories = []
    for memory_id in memory_connection_counts:
        sorted_memories.append({
            "id": memory_id,
            "connection_count": memory_connection_counts[memory_id]
        })
    
    # Sort by connection count, descending
    sorted_memories.sort_custom(self, "_sort_by_connection_count")
    
    # Take top 5
    for i in range(min(5, sorted_memories.size())):
        stats.most_connected_memories.append(sorted_memories[i])
    
    return stats

func _sort_by_connection_count(a: Dictionary, b: Dictionary) -> bool:
    return a.connection_count > b.connection_count

# Batch Operations
func create_sequential_chain(memory_ids: Array, reason: String = "") -> Array:
    var created_connections = []
    
    if memory_ids.size() < 2:
        return created_connections
    
    for i in range(memory_ids.size() - 1):
        var source_id = memory_ids[i]
        var target_id = memory_ids[i + 1]
        
        var connection_id = connect_memories(
            source_id,
            target_id,
            CONNECTION_TYPES.SEQUENTIAL,
            reason
        )
        
        if connection_id:
            created_connections.append(connection_id)
    
    return created_connections

func create_cycle(memory_ids: Array, reason: String = "") -> Array:
    var created_connections = []
    
    if memory_ids.size() < 3:
        return created_connections
    
    # Create sequential connections for all but the last one
    for i in range(memory_ids.size() - 1):
        var source_id = memory_ids[i]
        var target_id = memory_ids[i + 1]
        
        var connection_id = connect_memories(
            source_id,
            target_id,
            CONNECTION_TYPES.CYCLES,
            reason
        )
        
        if connection_id:
            created_connections.append(connection_id)
    
    # Connect the last one back to the first
    var last_connection_id = connect_memories(
        memory_ids[memory_ids.size() - 1],
        memory_ids[0],
        CONNECTION_TYPES.CYCLES,
        reason
    )
    
    if last_connection_id:
        created_connections.append(last_connection_id)
    
    return created_connections

# Integration with External Systems
func sync_with_rehab_system():
    if not _rehab_system:
        return
    
    # This would sync connections with the MemoryRehabSystem
    # For now, this is just a placeholder
    pass

func integrate_with_knowledge_system():
    if not _knowledge_system:
        return
    
    # This would integrate with the WishKnowledgeSystem
    # For now, this is just a placeholder
    pass

# Example Usage
# var connection_system = MemoryConnectionSystem.new()
# connection_system.initialize(memory_rehab_system, wish_knowledge_system)
#
# var connection_id = connection_system.connect_memories(
#   "memory_123", 
#   "memory_456", 
#   MemoryConnectionSystem.CONNECTION_TYPES.CAUSAL,
#   "This memory causes the other one"
# )
#
# var connected_memories = connection_system.get_connected_memories("memory_123")
# print(connection_system.generate_memory_map("memory_123"))