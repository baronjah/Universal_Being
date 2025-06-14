extends Node

class_name AkashicRecordConnector

signal record_saved(record_id, record_type)
signal record_retrieved(record_id, data)
signal connection_established(source)
signal connection_status_changed(status, message)
signal records_synchronized(count, source)

# Connection status
enum ConnectionState {
    DISCONNECTED,
    CONNECTING,
    CONNECTED,
    ERROR
}

# Record types
enum RecordType {
    CODE_FRAGMENT,
    PROJECT_STATE,
    SCRIPT_MAPPING,
    WORD_PATTERN,
    DIMENSIONAL_DATA,
    FILE_MIGRATION,
    WORD_MANIFESTATION,
    TOKEN_CLUSTER,
    TUNNEL_TRANSFER,
    BRIDGE_EVENT
}

# Connection properties
const DEFAULT_CONNECTION_TIMEOUT = 5.0
const SYNC_INTERVAL = 300.0  # 5 minutes
const MEMORY_IMPRINT_LIFETIME = 2592000.0  # 30 days

# Akashic database organization
const RECORD_COLLECTIONS = {
    RecordType.CODE_FRAGMENT: "code_fragments",
    RecordType.PROJECT_STATE: "project_states",
    RecordType.SCRIPT_MAPPING: "script_mappings",
    RecordType.WORD_PATTERN: "word_patterns",
    RecordType.DIMENSIONAL_DATA: "dimensional_data",
    RecordType.FILE_MIGRATION: "file_migrations",
    RecordType.WORD_MANIFESTATION: "word_manifestations",
    RecordType.TOKEN_CLUSTER: "token_clusters",
    RecordType.TUNNEL_TRANSFER: "tunnel_transfers",
    RecordType.BRIDGE_EVENT: "bridge_events"
}

# Paths for storage
const DEFAULT_AKASHIC_PATH = "user://akashic_records"
const CACHE_PATH = "user://akashic_cache"
const BACKUP_PATH = "user://akashic_backup"

# References to connected systems
var tunnel_controller
var ethereal_tunnel_manager
var word_pattern_visualizer
var numeric_token_system

# Connection state
var connection_state = ConnectionState.DISCONNECTED
var connection_error = ""
var connection_source = ""
var last_sync_time = 0

# In-memory record cache
var memory_cache = {}
var memory_imprints = {}

# On-disk storage
var storage_path = DEFAULT_AKASHIC_PATH
var collection_indexes = {}
var collection_manifests = {}

# Query system
var active_queries = []
var query_results = {}

# Bridge connections
var bridge_connections = []
var active_bridges = {}

# Encryption and security
var use_encryption = false
var encryption_key = ""

# Ethereal anchor for Akashic records
var akashic_anchor_id = "akashic_records"

func _ready():
    # Create storage directories
    _initialize_storage()
    
    # Auto-detect components
    _detect_components()
    
    # Load indexes
    _load_collection_indexes()
    
    # Create initial ethereal anchor
    _create_akashic_anchor()

func _process(delta):
    # Check for periodic sync
    if connection_state == ConnectionState.CONNECTED:
        var current_time = Time.get_unix_time_from_system()
        if current_time - last_sync_time >= SYNC_INTERVAL:
            synchronize_records()
    
    # Process bridge connections
    _process_bridge_connections()
    
    # Process queries
    _process_queries()
    
    # Clean expired memory imprints
    _clean_expired_imprints()

func _detect_components():
    # Find tunnel controller
    if not tunnel_controller:
        var potential_controllers = get_tree().get_nodes_in_group("tunnel_controllers")
        if potential_controllers.size() > 0:
            tunnel_controller = potential_controllers[0]
            print("Found tunnel controller: " + tunnel_controller.name)
            ethereal_tunnel_manager = tunnel_controller.ethereal_tunnel_manager
    
    # Find word pattern visualizer
    if not word_pattern_visualizer:
        var potential_visualizers = get_tree().get_nodes_in_group("word_pattern_visualizers")
        if potential_visualizers.size() > 0:
            word_pattern_visualizer = potential_visualizers[0]
            print("Found word pattern visualizer: " + word_pattern_visualizer.name)
    
    # Find numeric token system
    if not numeric_token_system:
        var potential_systems = get_tree().get_nodes_in_group("numeric_token_systems")
        if potential_systems.size() > 0:
            numeric_token_system = potential_systems[0]
            print("Found numeric token system: " + numeric_token_system.name)

func _initialize_storage():
    # Create storage directories
    var dir = DirAccess.open("res://")
    
    if not DirAccess.dir_exists_absolute(storage_path):
        dir.make_dir_recursive(storage_path)
    
    if not DirAccess.dir_exists_absolute(CACHE_PATH):
        dir.make_dir_recursive(CACHE_PATH)
    
    if not DirAccess.dir_exists_absolute(BACKUP_PATH):
        dir.make_dir_recursive(BACKUP_PATH)
    
    # Create collection subdirectories
    for collection in RECORD_COLLECTIONS.values():
        var collection_path = storage_path.path_join(collection)
        if not DirAccess.dir_exists_absolute(collection_path):
            dir.make_dir_recursive(collection_path)

func _load_collection_indexes():
    # Load existing collection indexes or create new ones
    for record_type in RECORD_COLLECTIONS:
        var collection = RECORD_COLLECTIONS[record_type]
        var index_path = storage_path.path_join(collection + "_index.json")
        
        if FileAccess.file_exists(index_path):
            var file = FileAccess.open(index_path, FileAccess.READ)
            var json = file.get_as_text()
            file.close()
            
            var parse_result = JSON.parse_string(json)
            if parse_result:
                collection_indexes[collection] = parse_result
            else:
                # Create new index if parsing failed
                collection_indexes[collection] = {"records": {}, "last_updated": 0}
        } else {
            # Create new index
            collection_indexes[collection] = {"records": {}, "last_updated": 0}
        }
        
        # Load manifest
        var manifest_path = storage_path.path_join(collection + "_manifest.json")
        
        if FileAccess.file_exists(manifest_path):
            var file = FileAccess.open(manifest_path, FileAccess.READ)
            var json = file.get_as_text()
            file.close()
            
            var parse_result = JSON.parse_string(json)
            if parse_result:
                collection_manifests[collection] = parse_result
            else:
                collection_manifests[collection] = {
                    "record_count": 0,
                    "last_updated": 0,
                    "schema_version": 1,
                    "tags": []
                }
        } else {
            # Create new manifest
            collection_manifests[collection] = {
                "record_count": 0,
                "last_updated": 0,
                "schema_version": 1,
                "tags": []
            }
        }
    }

func _save_collection_index(collection):
    # Save collection index to disk
    var index_path = storage_path.path_join(collection + "_index.json")
    
    var file = FileAccess.open(index_path, FileAccess.WRITE)
    var json = JSON.stringify(collection_indexes[collection])
    file.store_string(json)
    file.close()
    
    # Update and save manifest
    var manifest = collection_manifests[collection]
    manifest.record_count = collection_indexes[collection].records.size()
    manifest.last_updated = Time.get_unix_time_from_system()
    
    var manifest_path = storage_path.path_join(collection + "_manifest.json")
    file = FileAccess.open(manifest_path, FileAccess.WRITE)
    json = JSON.stringify(manifest)
    file.store_string(json)
    file.close()

func _create_akashic_anchor():
    # Create an ethereal anchor for the Akashic records
    if ethereal_tunnel_manager and not ethereal_tunnel_manager.has_anchor(akashic_anchor_id):
        # Position in the information dimension (5)
        var position = Vector3(0, 5, 0)
        ethereal_tunnel_manager.register_anchor(akashic_anchor_id, position, "akashic_records")
        
        # Create a word pattern for the Akashic records
        if word_pattern_visualizer:
            word_pattern_visualizer.add_word_pattern("akashic_records", 30.0, 5)
        
        # Create a numeric token for the Akashic dimension
        if numeric_token_system:
            numeric_token_system.create_token(555, "INFO", "akashic_anchor")
    }

func connect_to_akashic_database(source = "local", connection_data = {}):
    # Already connected
    if connection_state == ConnectionState.CONNECTED:
        return true
    
    # Set connecting state
    connection_state = ConnectionState.CONNECTING
    connection_source = source
    
    emit_signal("connection_status_changed", "connecting", "Connecting to Akashic Records from " + source)
    
    var success = false
    
    match source:
        "local":
            success = _connect_local()
        "claude":
            success = _connect_claude(connection_data)
        "external":
            success = _connect_external_database(connection_data)
        "bridge":
            success = _connect_bridge(connection_data)
        _:
            connection_error = "Unknown connection source: " + source
            connection_state = ConnectionState.ERROR
            emit_signal("connection_status_changed", "error", connection_error)
            return false
    
    if success:
        connection_state = ConnectionState.CONNECTED
        last_sync_time = Time.get_unix_time_from_system()
        emit_signal("connection_established", source)
        emit_signal("connection_status_changed", "connected", "Connected to Akashic Records from " + source)
        
        # Create an ethereal memory imprint
        _create_memory_imprint("connection_" + source)
        
        return true
    else:
        connection_state = ConnectionState.ERROR
        emit_signal("connection_status_changed", "error", connection_error)
        return false

func _connect_local():
    # Connect to local storage
    var dir = DirAccess.open(storage_path)
    if not dir:
        connection_error = "Cannot access local storage at: " + storage_path
        return false
    
    # Verify the required directories
    for collection in RECORD_COLLECTIONS.values():
        var collection_path = storage_path.path_join(collection)
        if not DirAccess.dir_exists_absolute(collection_path):
            connection_error = "Missing collection directory: " + collection
            return false
    
    return true

func _connect_claude(connection_data):
    # Connection to Claude API for Akashic records
    if not connection_data.has("api_key"):
        connection_error = "Missing Claude API key"
        return false
    
    # Would implement actual Claude API connection here
    # For demonstration, we'll simulate success
    
    # Create a bridge connection for Claude
    var bridge_id = "claude_akashic_bridge"
    bridge_connections.push_back({
        "id": bridge_id,
        "type": "claude",
        "status": "connected",
        "last_sync": Time.get_unix_time_from_system(),
        "connection_data": connection_data
    })
    
    # Create tunnel to Claude if tunnel system is available
    if ethereal_tunnel_manager and ethereal_tunnel_manager.has_anchor(akashic_anchor_id):
        var claude_anchor_id = "claude_api"
        
        # Create Claude anchor if it doesn't exist
        if not ethereal_tunnel_manager.has_anchor(claude_anchor_id):
            ethereal_tunnel_manager.register_anchor(claude_anchor_id, Vector3(0, 6, 0), "claude_api")
        
        # Check if tunnel already exists
        var tunnel_id = akashic_anchor_id + "_to_" + claude_anchor_id
        if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
            // Create tunnel in the information dimension (5)
            ethereal_tunnel_manager.establish_tunnel(akashic_anchor_id, claude_anchor_id, 5)
        }
    }
    
    return true

func _connect_external_database(connection_data):
    # Connect to external database
    # For demonstration purposes, simulation only
    
    if not connection_data.has("url"):
        connection_error = "Missing database URL"
        return false
    
    # Would implement actual database connection here
    
    # Create a bridge connection
    var bridge_id = "external_db_bridge"
    bridge_connections.push_back({
        "id": bridge_id,
        "type": "external_db",
        "status": "connected",
        "last_sync": Time.get_unix_time_from_system(),
        "connection_data": connection_data
    })
    
    return true

func _connect_bridge(connection_data):
    if not connection_data.has("bridge_id"):
        connection_error = "Missing bridge ID"
        return false
    
    var bridge_id = connection_data.bridge_id
    
    # Create bridge connection
    bridge_connections.push_back({
        "id": bridge_id,
        "type": connection_data.get("type", "generic"),
        "status": "connected",
        "last_sync": Time.get_unix_time_from_system(),
        "connection_data": connection_data
    })
    
    # Create bridge tunnel if needed
    if ethereal_tunnel_manager and ethereal_tunnel_manager.has_anchor(akashic_anchor_id):
        var bridge_anchor_id = "bridge_" + bridge_id
        
        # Create bridge anchor if it doesn't exist
        if not ethereal_tunnel_manager.has_anchor(bridge_anchor_id):
            ethereal_tunnel_manager.register_anchor(bridge_anchor_id, Vector3(0, 7, 0), "bridge")
        
        # Check if tunnel already exists
        var tunnel_id = akashic_anchor_id + "_to_" + bridge_anchor_id
        if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
            // Create tunnel in the connection dimension (7)
            ethereal_tunnel_manager.establish_tunnel(akashic_anchor_id, bridge_anchor_id, 7)
        }
    }
    
    return true

func disconnect_from_akashic_database():
    if connection_state == ConnectionState.DISCONNECTED:
        return true
    
    // Save any pending records
    synchronize_records()
    
    // Close bridge connections
    for bridge in bridge_connections:
        if bridge.status == "connected":
            bridge.status = "disconnected"
            
            // Record disconnection
            record_bridge_event(bridge.id, "disconnection", {
                "source": connection_source,
                "timestamp": Time.get_unix_time_from_system()
            })
        }
    }
    
    connection_state = ConnectionState.DISCONNECTED
    emit_signal("connection_status_changed", "disconnected", "Disconnected from Akashic Records")
    
    return true

func synchronize_records():
    if connection_state != ConnectionState.CONNECTED:
        return false
    
    // Save all collection indexes
    for collection in collection_indexes.keys():
        _save_collection_index(collection)
    }
    
    // Synchronize with bridges
    var sync_count = 0
    for bridge in bridge_connections:
        if bridge.status == "connected":
            _synchronize_with_bridge(bridge)
            sync_count += 1
        }
    }
    
    last_sync_time = Time.get_unix_time_from_system()
    emit_signal("records_synchronized", sync_count, connection_source)
    
    return true

func _synchronize_with_bridge(bridge):
    // Implement specific bridge synchronization
    match bridge.type:
        "claude":
            _synchronize_with_claude(bridge)
        "external_db":
            _synchronize_with_external_db(bridge)
        "generic":
            // Generic bridge synchronization
            pass

func _synchronize_with_claude(bridge):
    // This would implement actual Claude API communication
    // For demonstration, we'll record the synchronization event
    
    record_bridge_event(bridge.id, "synchronization", {
        "source": "claude",
        "timestamp": Time.get_unix_time_from_system(),
        "records_processed": collection_indexes.size()
    })
    
    bridge.last_sync = Time.get_unix_time_from_system()

func _synchronize_with_external_db(bridge):
    // This would implement external database synchronization
    // For demonstration, we'll record the synchronization event
    
    record_bridge_event(bridge.id, "synchronization", {
        "source": "external_db",
        "timestamp": Time.get_unix_time_from_system(),
        "records_processed": collection_indexes.size()
    })
    
    bridge.last_sync = Time.get_unix_time_from_system()

func _process_bridge_connections():
    for bridge in bridge_connections:
        if bridge.status == "connected":
            // Check for sync timeout
            var current_time = Time.get_unix_time_from_system()
            if current_time - bridge.last_sync >= SYNC_INTERVAL:
                _synchronize_with_bridge(bridge)
            }
        }
    }

func _process_queries():
    var completed_queries = []
    
    for query in active_queries:
        if query.status == "completed" or query.status == "error":
            completed_queries.push_back(query)
            continue
        }
        
        // Process query
        if query.status == "pending":
            query.status = "processing"
            
            // Execute query
            var result = _execute_query(query)
            
            if result:
                query.status = "completed"
                query.result = result
                query_results[query.id] = result
                
                emit_signal("record_retrieved", query.id, result)
            } else {
                query.status = "error"
                query.error = "Query execution failed"
            }
        }
    }
    
    // Remove completed queries
    for query in completed_queries:
        active_queries.erase(query)
    }

func _execute_query(query):
    match query.type:
        "id":
            return _query_by_id(query.record_type, query.criteria.id)
        "tag":
            return _query_by_tag(query.record_type, query.criteria.tag)
        "text":
            return _query_by_text(query.record_type, query.criteria.text)
        "date_range":
            return _query_by_date_range(
                query.record_type, 
                query.criteria.start_date,
                query.criteria.end_date
            )
        "complex":
            return _query_complex(query.record_type, query.criteria)
        _:
            return null

func _query_by_id(record_type, record_id):
    var collection = RECORD_COLLECTIONS[record_type]
    
    // Check memory cache first
    var cache_key = collection + "/" + record_id
    if memory_cache.has(cache_key):
        return memory_cache[cache_key]
    }
    
    // Check collection index
    if collection_indexes.has(collection):
        var index = collection_indexes[collection]
        
        if index.records.has(record_id):
            var record_path = storage_path.path_join(collection).path_join(record_id + ".json")
            
            if FileAccess.file_exists(record_path):
                var file = FileAccess.open(record_path, FileAccess.READ)
                var json = file.get_as_text()
                file.close()
                
                var record = JSON.parse_string(json)
                if record:
                    // Cache the record
                    memory_cache[cache_key] = record
                    return record
                }
            }
        }
    }
    
    return null

func _query_by_tag(record_type, tag):
    var collection = RECORD_COLLECTIONS[record_type]
    var results = []
    
    if collection_indexes.has(collection):
        var index = collection_indexes[collection]
        
        for record_id in index.records:
            var record_info = index.records[record_id]
            
            if record_info.has("tags") and record_info.tags.has(tag):
                var record = _query_by_id(record_type, record_id)
                if record:
                    results.push_back(record)
                }
            }
        }
    }
    
    return results

func _query_by_text(record_type, text):
    var collection = RECORD_COLLECTIONS[record_type]
    var results = []
    
    if collection_indexes.has(collection):
        var index = collection_indexes[collection]
        
        for record_id in index.records:
            var record = _query_by_id(record_type, record_id)
            
            if record:
                // Simple text search implementation
                var found = false
                
                // Search in content
                if record.has("content") and typeof(record.content) == TYPE_STRING:
                    if record.content.find(text) >= 0:
                        found = true
                    }
                }
                
                // Search in metadata description
                if not found and record.has("metadata"):
                    var metadata = record.metadata
                    
                    if metadata.has("description") and typeof(metadata.description) == TYPE_STRING:
                        if metadata.description.find(text) >= 0:
                            found = true
                        }
                    }
                }
                
                if found:
                    results.push_back(record)
                }
            }
        }
    }
    
    return results

func _query_by_date_range(record_type, start_date, end_date):
    var collection = RECORD_COLLECTIONS[record_type]
    var results = []
    
    if collection_indexes.has(collection):
        var index = collection_indexes[collection]
        
        for record_id in index.records:
            var record_info = index.records[record_id]
            
            if record_info.has("timestamp"):
                var timestamp = record_info.timestamp
                
                if timestamp >= start_date and timestamp <= end_date:
                    var record = _query_by_id(record_type, record_id)
                    if record:
                        results.push_back(record)
                    }
                }
            }
        }
    }
    
    return results

func _query_complex(record_type, criteria):
    // Complex query with multiple criteria
    var initial_results = null
    
    // Start with ID if provided
    if criteria.has("id"):
        var record = _query_by_id(record_type, criteria.id)
        if record:
            initial_results = [record]
        } else {
            initial_results = []
        }
    }
    
    // Start with tag if provided and no ID results
    if initial_results == null and criteria.has("tag"):
        initial_results = _query_by_tag(record_type, criteria.tag)
    }
    
    // Start with text if provided and no previous results
    if initial_results == null and criteria.has("text"):
        initial_results = _query_by_text(record_type, criteria.text)
    }
    
    // Start with date range if provided and no previous results
    if initial_results == null and criteria.has("start_date") and criteria.has("end_date"):
        initial_results = _query_by_date_range(
            record_type, 
            criteria.start_date,
            criteria.end_date
        )
    }
    
    // If no initial results, return empty array
    if initial_results == null:
        return []
    }
    
    // Apply additional filters
    var filtered_results = initial_results
    
    // Filter by tag if not already used
    if criteria.has("tag") and initial_results != _query_by_tag(record_type, criteria.tag):
        filtered_results = filtered_results.filter(func(record):
            return record.has("metadata") and record.metadata.has("tags") and record.metadata.tags.has(criteria.tag)
        )
    }
    
    // Filter by text if not already used
    if criteria.has("text") and initial_results != _query_by_text(record_type, criteria.text):
        filtered_results = filtered_results.filter(func(record):
            if record.has("content") and typeof(record.content) == TYPE_STRING:
                if record.content.find(criteria.text) >= 0:
                    return true
            }
            
            if record.has("metadata") and record.metadata.has("description"):
                if record.metadata.description.find(criteria.text) >= 0:
                    return true
            }
            
            return false
        )
    }
    
    // Filter by date range if not already used
    if criteria.has("start_date") and criteria.has("end_date") and 
       initial_results != _query_by_date_range(record_type, criteria.start_date, criteria.end_date):
        filtered_results = filtered_results.filter(func(record):
            if record.has("metadata") and record.metadata.has("timestamp"):
                var timestamp = record.metadata.timestamp
                return timestamp >= criteria.start_date and timestamp <= criteria.end_date
            }
            return false
        )
    }
    
    return filtered_results

func save_record(record_type, content, metadata = {}):
    if connection_state != ConnectionState.CONNECTED:
        return null
    
    var collection = RECORD_COLLECTIONS[record_type]
    
    // Generate record ID if not provided
    var record_id = metadata.get("id", _generate_record_id(collection))
    
    // Add timestamp if not provided
    if not metadata.has("timestamp"):
        metadata.timestamp = Time.get_unix_time_from_system()
    }
    
    // Ensure tags is an array
    if not metadata.has("tags"):
        metadata.tags = []
    }
    
    // Create full record
    var record = {
        "id": record_id,
        "type": record_type,
        "content": content,
        "metadata": metadata
    }
    
    // Save to disk
    var record_path = storage_path.path_join(collection).path_join(record_id + ".json")
    var file = FileAccess.open(record_path, FileAccess.WRITE)
    
    if not file:
        print("Failed to save record: " + record_id)
        return null
    }
    
    var json = JSON.stringify(record)
    file.store_string(json)
    file.close()
    
    // Update index
    if not collection_indexes.has(collection):
        collection_indexes[collection] = {"records": {}, "last_updated": Time.get_unix_time_from_system()}
    }
    
    collection_indexes[collection].records[record_id] = {
        "id": record_id,
        "timestamp": metadata.timestamp,
        "tags": metadata.tags
    }
    
    collection_indexes[collection].last_updated = Time.get_unix_time_from_system()
    
    // Add to manifest tags
    var manifest = collection_manifests[collection]
    for tag in metadata.tags:
        if not manifest.tags.has(tag):
            manifest.tags.push_back(tag)
        }
    }
    
    // Update memory cache
    var cache_key = collection + "/" + record_id
    memory_cache[cache_key] = record
    
    // Create memory imprint
    _create_memory_imprint(record_id)
    
    // Connect to word pattern visualizer if available
    if word_pattern_visualizer and (
        record_type == RecordType.WORD_PATTERN or 
        record_type == RecordType.WORD_MANIFESTATION
    ):
        var pattern_text = "akashic_" + record_id
        var energy = 15.0
        var dimension = 5  // Information dimension
        
        word_pattern_visualizer.add_word_pattern(pattern_text, energy, dimension)
    }
    
    // Create numeric token if available
    if numeric_token_system:
        // Generate a token based on record timestamp
        var timestamp = int(metadata.timestamp)
        numeric_token_system.create_token(timestamp % 10000, "INFO", "akashic_record")
    }
    
    emit_signal("record_saved", record_id, record_type)
    return record_id

func get_record(record_type, record_id):
    if connection_state != ConnectionState.CONNECTED:
        return null
    
    var record = _query_by_id(record_type, record_id)
    
    if record:
        emit_signal("record_retrieved", record_id, record)
    }
    
    return record

func query_records(record_type, criteria, query_type = "complex"):
    if connection_state != ConnectionState.CONNECTED:
        return null
    
    // Create query
    var query_id = "query_" + str(randi() % 100000) + "_" + str(Time.get_unix_time_from_system())
    
    var query = {
        "id": query_id,
        "type": query_type,
        "record_type": record_type,
        "criteria": criteria,
        "status": "pending",
        "timestamp": Time.get_unix_time_from_system()
    }
    
    active_queries.push_back(query)
    
    // For synchronous operation, immediately execute
    _process_queries()
    
    // Return query ID to check results later
    return query_id

func get_query_results(query_id):
    if query_results.has(query_id):
        return query_results[query_id]
    }
    
    // Check if query is still in progress
    for query in active_queries:
        if query.id == query_id:
            return {"status": query.status}
        }
    }
    
    return null

func record_code_fragment(code, language, source_file, metadata = {}):
    // Add specific metadata for code fragments
    metadata.language = language
    metadata.source_file = source_file
    
    if not metadata.has("tags"):
        metadata.tags = []
    }
    
    metadata.tags.push_back("code")
    metadata.tags.push_back(language)
    
    return save_record(RecordType.CODE_FRAGMENT, code, metadata)

func record_project_state(project_path, version, metadata = {}):
    metadata.project_path = project_path
    metadata.version = version
    
    if not metadata.has("tags"):
        metadata.tags = []
    }
    
    metadata.tags.push_back("project_state")
    metadata.tags.push_back(version)
    
    // Would implement project scanning here
    var project_data = {
        "path": project_path,
        "version": version,
        "files": [],
        "timestamp": Time.get_unix_time_from_system()
    }
    
    return save_record(RecordType.PROJECT_STATE, project_data, metadata)

func record_script_mapping(mapping_data, source_project, target_project, metadata = {}):
    metadata.source_project = source_project
    metadata.target_project = target_project
    
    if not metadata.has("tags"):
        metadata.tags = []
    }
    
    metadata.tags.push_back("script_mapping")
    
    return save_record(RecordType.SCRIPT_MAPPING, mapping_data, metadata)

func record_word_pattern(pattern, dimension, energy, metadata = {}):
    metadata.dimension = dimension
    metadata.energy = energy
    
    if not metadata.has("tags"):
        metadata.tags = []
    }
    
    metadata.tags.push_back("word_pattern")
    metadata.tags.push_back("dimension_" + str(dimension))
    
    return save_record(RecordType.WORD_PATTERN, pattern, metadata)

func record_dimensional_data(dimension, data, source, metadata = {}):
    metadata.dimension = dimension
    metadata.source = source
    
    if not metadata.has("tags"):
        metadata.tags = []
    }
    
    metadata.tags.push_back("dimensional_data")
    metadata.tags.push_back("dimension_" + str(dimension))
    
    return save_record(RecordType.DIMENSIONAL_DATA, data, metadata)

func record_file_migration(source_file, target_file, source_version, target_version, metadata = {}):
    metadata.source_file = source_file
    metadata.target_file = target_file
    metadata.source_version = source_version
    metadata.target_version = target_version
    
    if not metadata.has("tags"):
        metadata.tags = []
    }
    
    metadata.tags.push_back("file_migration")
    metadata.tags.push_back("godot_" + source_version)
    metadata.tags.push_back("godot_" + target_version)
    
    var migration_data = {
        "source_file": source_file,
        "target_file": target_file,
        "source_version": source_version,
        "target_version": target_version,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    return save_record(RecordType.FILE_MIGRATION, migration_data, metadata)

func record_word_manifestation(word, dimension, energy, effects, metadata = {}):
    metadata.dimension = dimension
    metadata.energy = energy
    
    if not metadata.has("tags"):
        metadata.tags = []
    }
    
    metadata.tags.push_back("word_manifestation")
    metadata.tags.push_back("dimension_" + str(dimension))
    
    var manifestation_data = {
        "word": word,
        "dimension": dimension,
        "energy": energy,
        "effects": effects,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    return save_record(RecordType.WORD_MANIFESTATION, manifestation_data, metadata)

func record_token_cluster(cluster_id, tokens, dimension, total_energy, metadata = {}):
    metadata.dimension = dimension
    metadata.total_energy = total_energy
    
    if not metadata.has("tags"):
        metadata.tags = []
    }
    
    metadata.tags.push_back("token_cluster")
    metadata.tags.push_back("dimension_" + str(dimension))
    
    var cluster_data = {
        "cluster_id": cluster_id,
        "tokens": tokens,
        "dimension": dimension,
        "total_energy": total_energy,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    return save_record(RecordType.TOKEN_CLUSTER, cluster_data, metadata)

func record_tunnel_transfer(tunnel_id, content, source, target, metadata = {}):
    metadata.tunnel_id = tunnel_id
    metadata.source = source
    metadata.target = target
    
    if not metadata.has("tags"):
        metadata.tags = []
    }
    
    metadata.tags.push_back("tunnel_transfer")
    
    var transfer_data = {
        "tunnel_id": tunnel_id,
        "content_length": content.length() if typeof(content) == TYPE_STRING else 0,
        "source": source,
        "target": target,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    return save_record(RecordType.TUNNEL_TRANSFER, transfer_data, metadata)

func record_bridge_event(bridge_id, event_type, event_data, metadata = {}):
    metadata.bridge_id = bridge_id
    metadata.event_type = event_type
    
    if not metadata.has("tags"):
        metadata.tags = []
    }
    
    metadata.tags.push_back("bridge_event")
    metadata.tags.push_back(event_type)
    
    return save_record(RecordType.BRIDGE_EVENT, event_data, metadata)

func _generate_record_id(collection):
    var timestamp = Time.get_unix_time_from_system()
    var random_suffix = str(randi() % 10000).pad_zeros(4)
    
    return collection + "_" + str(timestamp) + "_" + random_suffix

func _create_memory_imprint(record_id):
    // Create a memory imprint for this record
    var imprint = {
        "id": record_id,
        "timestamp": Time.get_unix_time_from_system(),
        "expiration": Time.get_unix_time_from_system() + MEMORY_IMPRINT_LIFETIME
    }
    
    memory_imprints[record_id] = imprint
    
    // Connect to word pattern visualizer if available
    if word_pattern_visualizer:
        var pattern_text = "memory_imprint_" + record_id
        var energy = 8.0
        var dimension = 6  // Consciousness dimension
        
        word_pattern_visualizer.add_word_pattern(pattern_text, energy, dimension)
    }

func _clean_expired_imprints():
    var current_time = Time.get_unix_time_from_system()
    var imprints_to_remove = []
    
    for record_id in memory_imprints:
        var imprint = memory_imprints[record_id]
        
        if current_time >= imprint.expiration:
            imprints_to_remove.push_back(record_id)
            
            // Remove from word pattern visualizer
            if word_pattern_visualizer:
                var pattern_text = "memory_imprint_" + record_id
                if word_pattern_visualizer.has_method("remove_word_pattern"):
                    word_pattern_visualizer.remove_word_pattern(pattern_text)
                }
            }
        }
    }
    
    for record_id in imprints_to_remove:
        memory_imprints.erase(record_id)
    }

func get_collection_stats():
    var stats = {}
    
    for collection in collection_manifests:
        stats[collection] = {
            "record_count": collection_manifests[collection].record_count,
            "last_updated": collection_manifests[collection].last_updated,
            "tag_count": collection_manifests[collection].tags.size()
        }
    }
    
    return stats

func get_connection_status():
    return {
        "state": connection_state,
        "source": connection_source,
        "error": connection_error,
        "bridges": bridge_connections.size(),
        "last_sync": last_sync_time
    }

func backup_database():
    // Create backup directory with timestamp
    var timestamp = Time.get_datetime_string_from_system()
    var backup_dir = BACKUP_PATH.path_join("backup_" + timestamp.replace(":", "-"))
    
    var dir = DirAccess.open("res://")
    dir.make_dir_recursive(backup_dir)
    
    // Copy collection files and indexes
    for collection in RECORD_COLLECTIONS.values():
        var collection_path = storage_path.path_join(collection)
        var backup_collection_path = backup_dir.path_join(collection)
        dir.make_dir_recursive(backup_collection_path)
        
        // Copy index
        var index_path = storage_path.path_join(collection + "_index.json")
        if FileAccess.file_exists(index_path):
            var file = FileAccess.open(index_path, FileAccess.READ)
            var content = file.get_as_text()
            file.close()
            
            file = FileAccess.open(backup_dir.path_join(collection + "_index.json"), FileAccess.WRITE)
            file.store_string(content)
            file.close()
        }
        
        // Copy manifest
        var manifest_path = storage_path.path_join(collection + "_manifest.json")
        if FileAccess.file_exists(manifest_path):
            var file = FileAccess.open(manifest_path, FileAccess.READ)
            var content = file.get_as_text()
            file.close()
            
            file = FileAccess.open(backup_dir.path_join(collection + "_manifest.json"), FileAccess.WRITE)
            file.store_string(content)
            file.close()
        }
        
        // Copy records
        var collection_dir = DirAccess.open(collection_path)
        if collection_dir:
            collection_dir.list_dir_begin()
            var file_name = collection_dir.get_next()
            
            while file_name != "":
                if not collection_dir.current_is_dir() and file_name.ends_with(".json"):
                    var file = FileAccess.open(collection_path.path_join(file_name), FileAccess.READ)
                    var content = file.get_as_text()
                    file.close()
                    
                    file = FileAccess.open(backup_collection_path.path_join(file_name), FileAccess.WRITE)
                    file.store_string(content)
                    file.close()
                }
                
                file_name = collection_dir.get_next()
            }
            
            collection_dir.list_dir_end()
        }
    }
    
    return backup_dir