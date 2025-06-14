extends Node

class_name UniversalAkashicConnector

# ----- CONSTANTS -----
const MAX_CONNECTIONS = 12
const CONNECTION_TYPES = ["direct", "bridge", "portal", "tunnel", "api"]
const AKASHIC_SYSTEMS = ["akashic_database", "akashic_records", "akashic_bridge", "ethereal_akashic"]
const DIMENSION_LEVELS = 12
const SYNCHRONIZATION_MODES = ["instant", "scheduled", "manual", "conditional"]

# ----- CONFIGURATION -----
var config = {
	"auto_connect": true,
	"auto_search": true,
	"max_record_size": 1024 * 1024, # 1MB
	"default_connection_type": "bridge",
	"dimension_access": 3,
	"synchronization_mode": "conditional",
	"retry_on_failure": true,
	"include_metadata": true,
	"log_transfers": true,
	"firewall_enabled": true,
	"cross_project_access": true,
	"memory_persistence": true
}

# ----- CONNECTION DATA -----
var connected_systems = {}
var active_connections = {}
var connection_history = {}
var dimension_registry = {}
var record_cache = {}
var transfer_queue = []
var dimensional_gates = {}

# ----- SYSTEM REFERENCES -----
var _akashic_database = null
var _ethereal_bridge = null
var _project_connector = null
var _claude_bridge = null
var _universal_flow = null

# ----- TIMEOUTS AND TIMERS -----
var connection_timer = null
var sync_timer = null
var cleanup_timer = null
var transfer_timer = null

# ----- SIGNALS -----
signal system_connected(system_id, system_type)
signal system_disconnected(system_id)
signal record_transferred(record_id, source_system, target_system)
signal synchronization_completed(systems_synced)
signal dimension_accessed(dimension_id, access_level)
signal transfer_failed(record_id, error)
signal connection_established(connection_id, connection_type)
signal akashic_system_found(system_id, system_type, path)

# ----- INITIALIZATION -----
func _ready():
	print("Initializing Universal Akashic Connector...")
	
	# Setup timers
	_setup_timers()
	
	# Find essential systems
	_find_systems()
	
	# Initialize dimensional gates
	_initialize_dimensional_gates()
	
	# Auto-connect to systems if enabled
	if config.auto_connect:
		_auto_connect_systems()
	
	# Initialize record cache
	_initialize_record_cache()
	
	print("Universal Akashic Connector initialized with access level: " + str(config.dimension_access))

func _setup_timers():
	# Connection check timer (every 5 seconds)
	connection_timer = Timer.new()
	connection_timer.wait_time = 5.0
	connection_timer.one_shot = false
	connection_timer.autostart = true
	connection_timer.connect("timeout", self, "_on_connection_timer_timeout")
	add_child(connection_timer)
	
	# Synchronization timer (every 30 seconds)
	sync_timer = Timer.new()
	sync_timer.wait_time = 30.0
	sync_timer.one_shot = false
	sync_timer.autostart = true
	sync_timer.connect("timeout", self, "_on_sync_timer_timeout")
	add_child(sync_timer)
	
	# Cleanup timer (every 5 minutes)
	cleanup_timer = Timer.new()
	cleanup_timer.wait_time = 300.0
	cleanup_timer.one_shot = false
	cleanup_timer.autostart = true
	cleanup_timer.connect("timeout", self, "_on_cleanup_timer_timeout")
	add_child(cleanup_timer)
	
	# Transfer queue timer (every 1 second)
	transfer_timer = Timer.new()
	transfer_timer.wait_time = 1.0
	transfer_timer.one_shot = false
	transfer_timer.autostart = true
	transfer_timer.connect("timeout", self, "_on_transfer_timer_timeout")
	add_child(transfer_timer)

func _find_systems():
	# Look for AkashicDatabaseConnector
	_akashic_database = get_node_or_null("/root/AkashicDatabaseConnector")
	if not _akashic_database:
		_akashic_database = get_node_or_null("/root/AkashicDatabase")
	
	# Look for EtherealAkashicBridge
	_ethereal_bridge = get_node_or_null("/root/EtherealAkashicBridge")
	if not _ethereal_bridge:
		_ethereal_bridge = get_node_or_null("/root/EtherealBridge")
	
	# Look for ProjectConnectorSystem
	_project_connector = get_node_or_null("/root/ProjectConnectorSystem")
	
	# Look for ClaudeAkashicBridge
	_claude_bridge = get_node_or_null("/root/ClaudeAkashicBridge")
	
	# Look for UniversalDataFlow
	_universal_flow = get_node_or_null("/root/UniversalDataFlow")
	
	# Register found systems
	if _akashic_database:
		_register_system("akashic_database", _akashic_database)
	
	if _ethereal_bridge:
		_register_system("ethereal_bridge", _ethereal_bridge)
	
	if _claude_bridge:
		_register_system("claude_bridge", _claude_bridge)

func _initialize_dimensional_gates():
	# Create basic dimensional gates
	dimensional_gates = {
		"physical": {
			"level": 1,
			"open": true,
			"description": "Physical file storage layer",
			"systems": []
		},
		"memory": {
			"level": 2,
			"open": true,
			"description": "Memory persistence layer",
			"systems": []
		},
		"ethereal": {
			"level": 3,
			"open": config.dimension_access >= 3,
			"description": "Ethereal dimension access",
			"systems": []
		},
		"akashic": {
			"level": 4,
			"open": config.dimension_access >= 4,
			"description": "Akashic records layer",
			"systems": []
		},
		"cloud": {
			"level": 5,
			"open": config.dimension_access >= 5,
			"description": "Cloud integration layer",
			"systems": []
		},
		"dimensional": {
			"level": 7,
			"open": config.dimension_access >= 7,
			"description": "Higher dimensional access",
			"systems": []
		},
		"transcendent": {
			"level": 12,
			"open": config.dimension_access >= 12,
			"description": "Transcendent layer",
			"systems": []
		}
	}
	
	# Add dimensional registry entries
	for gate_name in dimensional_gates:
		var gate = dimensional_gates[gate_name]
		dimension_registry[gate_name] = {
			"id": gate_name,
			"level": gate.level,
			"active": gate.open,
			"description": gate.description,
			"connections": [],
			"records": []
		}

func _initialize_record_cache():
	# Initialize empty record cache with sections for different dimension levels
	for level in range(1, DIMENSION_LEVELS + 1):
		record_cache[str(level)] = {}

func _auto_connect_systems():
	# Connect to any akashic systems we can find
	if config.auto_search:
		_search_for_akashic_systems()
	
	# Connect known systems
	_connect_known_systems()

func _search_for_akashic_systems():
	print("Searching for Akashic systems...")
	
	# If we have the project connector, use it to find projects
	if _project_connector and _project_connector.has_method("get_projects_by_type"):
		var akashic_projects = _project_connector.get_projects_by_type("akashic")
		
		for project_id in akashic_projects:
			var project = _project_connector.get_project(project_id)
			if project:
				emit_signal("akashic_system_found", project_id, "akashic", project.path)
				_try_connect_system(project_id, "akashic", project.path)
	
	# Search for script files
	_search_directory("/mnt/c/Users/Percision 15", ["akashic_database", "akashic_records", "akashic_bridge"])

func _search_directory(base_path, keywords, depth=0, max_depth=3):
	if depth > max_depth:
		return
	
	var dir = Directory.new()
	
	if not dir.dir_exists(base_path):
		return
	
	if dir.open(base_path) == OK:
		dir.list_dir_begin(true, true)
		
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = base_path + "/" + file_name
			
			if dir.current_is_dir():
				# Recursively scan subdirectories
				_search_directory(full_path, keywords, depth + 1, max_depth)
			else:
				# Check if file matches akashic systems
				if file_name.get_extension() == "gd" or file_name.get_extension() == "js":
					var matches = false
					for keyword in keywords:
						if file_name.find(keyword) >= 0:
							matches = true
							break
					
					if matches:
						var system_id = full_path.get_file().get_basename()
						var system_type = _determine_system_type(file_name)
						
						emit_signal("akashic_system_found", system_id, system_type, full_path)
						_try_connect_system(system_id, system_type, full_path)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()

func _determine_system_type(file_name):
	if file_name.find("database") >= 0:
		return "akashic_database"
	elif file_name.find("ethereal") >= 0:
		return "ethereal_akashic"
	elif file_name.find("claude") >= 0:
		return "claude_akashic"
	elif file_name.find("bridge") >= 0:
		return "akashic_bridge"
	else:
		return "akashic_records"

func _connect_known_systems():
	# Try to connect to default systems
	_try_connect_system("akashic_database_connector", "akashic_database", "/mnt/c/Users/Percision 15/12_turns_system/akashic_database_connector.gd")
	_try_connect_system("claude_akashic_bridge", "claude_akashic", "/mnt/c/Users/Percision 15/12_turns_system/claude_akashic_bridge.gd")
	_try_connect_system("ethereal_akashic_bridge", "ethereal_akashic", "/mnt/c/Users/Percision 15/12_turns_system/ethereal_akashic_bridge.gd")
	_try_connect_system("akashic_number_system", "akashic_records", "/mnt/c/Users/Percision 15/12_turns_system/akashic_number_system.gd")
	_try_connect_system("terminal_akashic_interface", "akashic_bridge", "/mnt/c/Users/Percision 15/12_turns_system/terminal_akashic_interface.gd")

func _try_connect_system(system_id, system_type, path):
	# Skip if already connected
	if connected_systems.has(system_id):
		return connected_systems[system_id]
	
	print("Attempting to connect to system: " + system_id + " of type: " + system_type)
	
	var system_node = null
	
	# Check if already available as a node
	system_node = get_node_or_null("/root/" + system_id)
	
	if not system_node:
		# Try to load script and create instance
		if File.new().file_exists(path):
			var script = load(path)
			if script:
				system_node = Node.new()
				system_node.set_script(script)
				system_node.name = system_id
				add_child(system_node)
				print("Created new instance for: " + system_id)
			else:
				push_warning("Could not load script for system: " + system_id)
		else:
			push_warning("File does not exist: " + path)
	
	if system_node:
		return _register_system(system_id, system_node, system_type)
	
	return null

# ----- REGISTRATION AND CONNECTION -----
func _register_system(system_id, system_node, system_type=""):
	# Determine system type if not provided
	if system_type.empty():
		system_type = _detect_system_type(system_node)
	
	# Store system information
	connected_systems[system_id] = {
		"node": system_node,
		"type": system_type,
		"connected_at": OS.get_unix_time(),
		"status": "connected",
		"dimensions": []
	}
	
	# Register system with appropriate dimensional gates
	match system_type:
		"akashic_database":
			dimensional_gates.physical.systems.append(system_id)
			dimensional_gates.akashic.systems.append(system_id)
		"akashic_records":
			dimensional_gates.memory.systems.append(system_id)
			dimensional_gates.akashic.systems.append(system_id)
		"akashic_bridge":
			dimensional_gates.akashic.systems.append(system_id)
			dimensional_gates.ethereal.systems.append(system_id)
		"ethereal_akashic":
			dimensional_gates.ethereal.systems.append(system_id)
			dimensional_gates.dimensional.systems.append(system_id)
		"claude_akashic":
			dimensional_gates.akashic.systems.append(system_id)
			dimensional_gates.cloud.systems.append(system_id)
	
	# Connect to signals if available
	_connect_system_signals(system_id, system_node)
	
	print("Registered system: " + system_id + " of type: " + system_type)
	emit_signal("system_connected", system_id, system_type)
	
	return system_id

func _detect_system_type(system_node):
	# Try to detect system type based on class and methods
	var script_path = ""
	if system_node.get_script():
		script_path = system_node.get_script().get_path().to_lower()
	
	if script_path.find("database") >= 0:
		return "akashic_database"
	elif script_path.find("ethereal") >= 0:
		return "ethereal_akashic"
	elif script_path.find("claude") >= 0:
		return "claude_akashic"
	elif script_path.find("bridge") >= 0:
		return "akashic_bridge"
	elif script_path.find("record") >= 0:
		return "akashic_records"
	
	# Check based on methods
	if system_node.has_method("add_word") or system_node.has_method("search_word"):
		return "akashic_database"
	elif system_node.has_method("store_record") or system_node.has_method("get_record"):
		return "akashic_records"
	elif system_node.has_method("change_dimension") or system_node.has_method("process_ethereal_data"):
		return "ethereal_akashic"
	elif system_node.has_method("query_akashic_records"):
		return "claude_akashic"
	
	# Default fallback
	return "akashic_bridge"

func _connect_system_signals(system_id, system_node):
	# Connect to system signals if they exist
	
	# Database signals
	if system_node.has_signal("database_connected"):
		system_node.connect("database_connected", self, "_on_database_connected", [system_id])
	
	if system_node.has_signal("database_disconnected"):
		system_node.connect("database_disconnected", self, "_on_database_disconnected", [system_id])
	
	if system_node.has_signal("word_added"):
		system_node.connect("word_added", self, "_on_word_added", [system_id])
	
	# Bridge signals
	if system_node.has_signal("dimension_changed"):
		system_node.connect("dimension_changed", self, "_on_dimension_changed", [system_id])
	
	if system_node.has_signal("word_stored"):
		system_node.connect("word_stored", self, "_on_word_stored", [system_id])
	
	if system_node.has_signal("data_transferred"):
		system_node.connect("data_transferred", self, "_on_data_transferred", [system_id])
	
	# Specific to Claude akashic bridge
	if system_node.has_signal("gate_status_changed"):
		system_node.connect("gate_status_changed", self, "_on_gate_status_changed", [system_id])

func connect_systems(source_id, target_id, connection_type="bridge"):
	# Verify both systems exist
	if not connected_systems.has(source_id) or not connected_systems.has(target_id):
		push_error("Cannot connect systems: One or both systems not found")
		return null
	
	# Generate connection ID
	var connection_id = source_id + "_to_" + target_id
	
	# Check if connection already exists
	if active_connections.has(connection_id):
		return connection_id
	
	print("Connecting systems: " + source_id + " to " + target_id + " via " + connection_type)
	
	# Create connection data
	active_connections[connection_id] = {
		"source": source_id,
		"target": target_id,
		"type": connection_type,
		"established": OS.get_unix_time(),
		"status": "active",
		"transfers": 0,
		"last_sync": 0,
		"metadata": {}
	}
	
	# Store in connection history
	connection_history[connection_id] = {
		"created": OS.get_unix_time(),
		"source": source_id,
		"target": target_id,
		"type": connection_type,
		"status_log": [{
			"timestamp": OS.get_unix_time(),
			"status": "created"
		}]
	}
	
	# Connect their dimensions
	_connect_dimensions(source_id, target_id, connection_type)
	
	emit_signal("connection_established", connection_id, connection_type)
	
	return connection_id

func _connect_dimensions(source_id, target_id, connection_type):
	var source_system = connected_systems[source_id]
	var target_system = connected_systems[target_id]
	
	# Find dimensional overlaps
	var source_dimensions = []
	var target_dimensions = []
	
	for gate_name in dimensional_gates:
		var gate = dimensional_gates[gate_name]
		if gate.systems.has(source_id):
			source_dimensions.append(gate_name)
		if gate.systems.has(target_id):
			target_dimensions.append(gate_name)
	
	# Connect overlapping dimensions
	for dim in source_dimensions:
		if target_dimensions.has(dim):
			dimension_registry[dim].connections.append({
				"source": source_id,
				"target": target_id,
				"connection_id": source_id + "_to_" + target_id,
				"type": connection_type
			})
			
			print("Connected dimension: " + dim + " between " + source_id + " and " + target_id)
	
	# Register dimensions with systems
	source_system.dimensions = source_dimensions
	target_system.dimensions = target_dimensions

# ----- RECORD OPERATIONS -----
func store_record(content, metadata={}):
	# Generate record ID
	var record_id = "record_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
	
	# Validate content size
	if content.length() > config.max_record_size:
		push_error("Record exceeds maximum size limit")
		return null
	
	# Add standard metadata
	metadata["created"] = OS.get_unix_time()
	metadata["dimension"] = metadata.get("dimension", "akashic")
	metadata["source"] = "universal_connector"
	
	# Store in primary system if available
	var primary_stored = false
	var primary_system_id = ""
	
	if _akashic_database:
		primary_system_id = "akashic_database_connector"
		if _akashic_database.has_method("add_word"):
			primary_stored = _akashic_database.add_word(record_id, 60, metadata)
			
			if primary_stored:
				print("Stored record " + record_id + " in primary system")
				
				# Add to record cache
				var dimension_level = _get_dimension_level(metadata.dimension)
				record_cache[str(dimension_level)][record_id] = {
					"content": content,
					"metadata": metadata,
					"storage": [primary_system_id]
				}
	
	# If not stored in primary, try Claude bridge
	if not primary_stored and _claude_bridge:
		primary_system_id = "claude_akashic_bridge"
		if _claude_bridge.has_method("create_protected_record"):
			var result = _claude_bridge.create_protected_record("text", content, metadata)
			
			if result and result.has("id"):
				record_id = result.id
				primary_stored = true
				print("Stored record " + record_id + " in Claude bridge")
				
				# Add to record cache
				var dimension_level = _get_dimension_level(metadata.dimension)
				record_cache[str(dimension_level)][record_id] = {
					"content": content,
					"metadata": metadata,
					"storage": [primary_system_id]
				}
	
	# Queue for distribution to other systems
	if primary_stored:
		_queue_record_distribution(record_id, content, metadata, primary_system_id)
		
		return record_id
	
	push_error("Failed to store record in any primary system")
	return null

func retrieve_record(record_id, source_system_id=""):
	# Check cache first
	for level in record_cache:
		if record_cache[level].has(record_id):
			print("Retrieved record " + record_id + " from cache (level " + level + ")")
			return record_cache[level][record_id]
	
	# If source system specified, try it first
	if not source_system_id.empty() and connected_systems.has(source_system_id):
		var record = _retrieve_from_system(record_id, source_system_id)
		if record:
			return record
	
	# Try all connected systems
	for system_id in connected_systems:
		if system_id == source_system_id:
			continue  # Already tried
			
		var record = _retrieve_from_system(record_id, system_id)
		if record:
			return record
	
	print("Record " + record_id + " not found in any system")
	return null

func _retrieve_from_system(record_id, system_id):
	var system = connected_systems[system_id]
	var system_node = system.node
	
	# Try appropriate retrieval method based on system type
	match system.type:
		"akashic_database":
			if system_node.has_method("search_word"):
				var result = system_node.search_word(record_id)
				if result:
					print("Retrieved record " + record_id + " from system " + system_id)
					
					# Add to cache
					var dimension_level = _get_dimension_level(result.get("dimension", "akashic"))
					record_cache[str(dimension_level)][record_id] = {
						"content": result.get("content", ""),
						"metadata": result,
						"storage": [system_id]
					}
					
					return record_cache[str(dimension_level)][record_id]
		
		"akashic_records":
			if system_node.has_method("get_record"):
				var result = system_node.get_record(record_id)
				if result:
					print("Retrieved record " + record_id + " from system " + system_id)
					
					# Add to cache
					var dimension_level = _get_dimension_level(result.get("dimension", "akashic"))
					record_cache[str(dimension_level)][record_id] = {
						"content": result.get("content", ""),
						"metadata": result,
						"storage": [system_id]
					}
					
					return record_cache[str(dimension_level)][record_id]
		
		"claude_akashic":
			if system_node.has_method("query_akashic_records"):
				var result = system_node.query_akashic_records(record_id)
				if result:
					print("Retrieved record " + record_id + " from system " + system_id)
					
					# Add to cache
					var dimension_level = _get_dimension_level(result.get("dimension", "akashic"))
					record_cache[str(dimension_level)][record_id] = {
						"content": result.get("content", ""),
						"metadata": result,
						"storage": [system_id]
					}
					
					return record_cache[str(dimension_level)][record_id]
		
		"ethereal_akashic":
			if system_node.has_method("search_akashic_records"):
				var results = system_node.search_akashic_records(record_id)
				if results and results.size() > 0:
					print("Retrieved record " + record_id + " from system " + system_id)
					
					# Add to cache
					var dimension_level = _get_dimension_level(results[0].get("dimension", "ethereal"))
					record_cache[str(dimension_level)][record_id] = {
						"content": results[0].get("content", ""),
						"metadata": results[0],
						"storage": [system_id]
					}
					
					return record_cache[str(dimension_level)][record_id]
	
	return null

func search_records(query, options={}):
	# Default options
	var default_options = {
		"dimension": "all",
		"exact_match": false,
		"max_results": 10,
		"include_content": true,
		"source_systems": []  # Empty means all systems
	}
	
	# Merge with provided options
	for key in default_options:
		if not options.has(key):
			options[key] = default_options[key]
	
	print("Searching for records with query: " + query)
	
	var results = []
	var systems_to_search = []
	
	# Determine which systems to search
	if options.source_systems.size() > 0:
		for system_id in options.source_systems:
			if connected_systems.has(system_id):
				systems_to_search.append(system_id)
	else:
		systems_to_search = connected_systems.keys()
	
	# Query dimensions based on dimension constraint
	var dimensions_to_search = []
	if options.dimension == "all":
		dimensions_to_search = dimension_registry.keys()
	else:
		dimensions_to_search = [options.dimension]
	
	# Search in each system
	for system_id in systems_to_search:
		var system = connected_systems[system_id]
		var system_node = system.node
		
		# Only search in systems that handle dimensions we want
		var system_handles_dimension = false
		for dim in dimensions_to_search:
			if system.dimensions.has(dim):
				system_handles_dimension = true
				break
		
		if not system_handles_dimension and options.dimension != "all":
			continue
		
		# Search based on system type
		match system.type:
			"akashic_database":
				if system_node.has_method("search_word"):
					var search_results = system_node.search_word(query)
					if search_results:
						_process_search_results(results, search_results, system_id, options)
			
			"akashic_records":
				if system_node.has_method("search_records"):
					var search_results = system_node.search_records(query)
					if search_results:
						_process_search_results(results, search_results, system_id, options)
			
			"claude_akashic":
				if system_node.has_method("query_akashic_records"):
					var search_options = {}
					if options.dimension != "all":
						search_options.dimension = options.dimension
					search_options.max_results = options.max_results
					
					var search_results = system_node.query_akashic_records(query, search_options)
					if search_results:
						_process_search_results(results, search_results, system_id, options)
			
			"ethereal_akashic":
				if system_node.has_method("search_akashic_records"):
					var dimension_key = options.dimension if options.dimension != "all" else ""
					var search_results = system_node.search_akashic_records(query, dimension_key)
					if search_results:
						_process_search_results(results, search_results, system_id, options)
	
	# Search cache for any missed results
	for level in record_cache:
		for record_id in record_cache[level]:
			var record = record_cache[level][record_id]
			
			# Check dimension constraint
			if options.dimension != "all":
				var record_dimension = record.metadata.get("dimension", "akashic")
				if record_dimension != options.dimension:
					continue
			
			# Check content match
			var content_matches = false
			if options.exact_match:
				content_matches = record.content == query
			else:
				content_matches = record.content.find(query) >= 0
			
			# Check metadata match
			var metadata_matches = false
			for key in record.metadata:
				var value = str(record.metadata[key])
				if value.find(query) >= 0:
					metadata_matches = true
					break
			
			if content_matches or metadata_matches:
				var already_found = false
				for result in results:
					if result.id == record_id:
						already_found = true
						break
				
				if not already_found:
					var result_item = {
						"id": record_id,
						"source_system": record.storage[0],
						"dimension": record.metadata.get("dimension", "akashic")
					}
					
					if options.include_content:
						result_item.content = record.content
					
					result_item.metadata = record.metadata
					results.append(result_item)
	
	# Limit results
	if results.size() > options.max_results:
		results.resize(options.max_results)
	
	print("Found " + str(results.size()) + " records matching query: " + query)
	
	return results

func _process_search_results(results, search_results, system_id, options):
	# Process and format search results from different system types
	
	# Format varies depending on what the system returns, need to normalize
	if typeof(search_results) == TYPE_DICTIONARY:
		# Single result as dictionary
		var result_item = {
			"id": search_results.get("id", "unknown_" + str(OS.get_unix_time())),
			"source_system": system_id
		}
		
		if options.include_content:
			result_item.content = search_results.get("content", "")
		
		result_item.metadata = {}
		for key in search_results:
			if key != "content":
				result_item.metadata[key] = search_results[key]
		
		result_item.dimension = search_results.get("dimension", "akashic")
		
		# Add to results if not duplicate
		var is_duplicate = false
		for existing in results:
			if existing.id == result_item.id:
				is_duplicate = true
				break
		
		if not is_duplicate:
			results.append(result_item)
			
			# Update cache
			var dimension_level = _get_dimension_level(result_item.dimension)
			if not record_cache[str(dimension_level)].has(result_item.id):
				record_cache[str(dimension_level)][result_item.id] = {
					"content": search_results.get("content", ""),
					"metadata": result_item.metadata,
					"storage": [system_id]
				}
	
	elif typeof(search_results) == TYPE_ARRAY:
		# Multiple results as array
		for item in search_results:
			var result_item = {
				"id": item.get("id", "unknown_" + str(OS.get_unix_time())),
				"source_system": system_id
			}
			
			if options.include_content:
				result_item.content = item.get("content", "")
			
			result_item.metadata = {}
			for key in item:
				if key != "content":
					result_item.metadata[key] = item[key]
			
			result_item.dimension = item.get("dimension", "akashic")
			
			# Add to results if not duplicate
			var is_duplicate = false
			for existing in results:
				if existing.id == result_item.id:
					is_duplicate = true
					break
			
			if not is_duplicate:
				results.append(result_item)
				
				# Update cache
				var dimension_level = _get_dimension_level(result_item.dimension)
				if not record_cache[str(dimension_level)].has(result_item.id):
					record_cache[str(dimension_level)][result_item.id] = {
						"content": item.get("content", ""),
						"metadata": result_item.metadata,
						"storage": [system_id]
					}

# ----- DIMENSION OPERATIONS -----
func open_dimensional_gate(gate_name):
	if not dimensional_gates.has(gate_name):
		push_error("Invalid dimensional gate: " + gate_name)
		return false
	
	var gate = dimensional_gates[gate_name]
	
	# Check access level
	if gate.level > config.dimension_access:
		push_error("Insufficient access level for dimension: " + gate_name)
		return false
	
	print("Opening dimensional gate: " + gate_name)
	
	# Open gate
	gate.open = true
	
	# Update dimension registry
	dimension_registry[gate_name].active = true
	
	# Notify connected systems
	for system_id in gate.systems:
		var system = connected_systems[system_id]
		
		# Notify based on system type
		match system.type:
			"claude_akashic":
				if system.node.has_method("open_gate"):
					system.node.open_gate("gate_" + str(_dimensional_gate_to_number(gate_name)))
			
			"ethereal_akashic":
				if system.node.has_method("change_dimension"):
					system.node.change_dimension(gate_name)
	
	emit_signal("dimension_accessed", gate_name, gate.level)
	
	return true

func close_dimensional_gate(gate_name):
	if not dimensional_gates.has(gate_name):
		push_error("Invalid dimensional gate: " + gate_name)
		return false
	
	var gate = dimensional_gates[gate_name]
	
	# Don't close physical or memory gates
	if gate_name == "physical" or gate_name == "memory":
		push_error("Cannot close fundamental gates: " + gate_name)
		return false
	
	print("Closing dimensional gate: " + gate_name)
	
	# Close gate
	gate.open = false
	
	# Update dimension registry
	dimension_registry[gate_name].active = false
	
	# Notify connected systems
	for system_id in gate.systems:
		var system = connected_systems[system_id]
		
		# Notify based on system type
		match system.type:
			"claude_akashic":
				if system.node.has_method("close_gate"):
					system.node.close_gate("gate_" + str(_dimensional_gate_to_number(gate_name)))
	
	return true

func set_dimension_access(level):
	level = int(level)
	if level < 1 or level > DIMENSION_LEVELS:
		push_error("Invalid dimension access level: " + str(level))
		return false
	
	print("Setting dimension access level to: " + str(level))
	
	# Store previous level for comparison
	var previous_level = config.dimension_access
	
	# Update access level
	config.dimension_access = level
	
	# Open or close gates based on new level
	for gate_name in dimensional_gates:
		var gate = dimensional_gates[gate_name]
		
		if gate.level <= level:
			# Should be open
			if not gate.open:
				open_dimensional_gate(gate_name)
		else:
			# Should be closed
			if gate.open:
				close_dimensional_gate(gate_name)
	
	# Notify connected systems of level change
	for system_id in connected_systems:
		var system = connected_systems[system_id]
		
		# Notify based on system type
		match system.type:
			"akashic_database":
				if system.node.has_method("unlock_dimension"):
					system.node.unlock_dimension(level)
			
			"claude_akashic":
				if system.node.has_method("set_dimension_access"):
					system.node.set_dimension_access(level)
			
			"ethereal_akashic":
				if system.node.has_method("set_dimension_access"):
					system.node.set_dimension_access(level)
	
	return true

func _get_dimension_level(dimension_name):
	if dimension_registry.has(dimension_name):
		return dimension_registry[dimension_name].level
	
	# Default mappings for unknown dimensions
	match dimension_name:
		"physical", "file":
			return 1
		"memory", "runtime":
			return 2
		"ethereal", "dream":
			return 3
		"akashic", "record":
			return 4
		"cloud", "network":
			return 5
		"dimensional", "higher":
			return 7
		"transcendent", "divine":
			return 12
	
	return 1  # Default to physical level

func _dimensional_gate_to_number(gate_name):
	# Convert gate name to gate number (for Claude Akashic Bridge)
	match gate_name:
		"physical":
			return 0
		"memory":
			return 1
		"ethereal":
			return 2
		"akashic":
			return 3
		"cloud":
			return 4
		"dimensional":
			return 5
		"transcendent":
			return 9
	
	return 0  # Default to gate 0

# ----- SYNCHRONIZATION -----
func synchronize_systems(options={}):
	# Default options
	var default_options = {
		"force_full_sync": false,
		"systems": [],  # Empty means all systems
		"dimensions": [],  # Empty means all accessible dimensions
		"max_records": 100
	}
	
	# Merge with provided options
	for key in default_options:
		if not options.has(key):
			options[key] = default_options[key]
	
	print("Starting system synchronization...")
	
	var systems_to_sync = []
	
	# Determine which systems to synchronize
	if options.systems.size() > 0:
		for system_id in options.systems:
			if connected_systems.has(system_id):
				systems_to_sync.append(system_id)
	else:
		systems_to_sync = connected_systems.keys()
	
	if systems_to_sync.size() < 2:
		push_warning("Not enough systems to synchronize")
		return false
	
	# Determine which dimensions to synchronize
	var dimensions_to_sync = []
	if options.dimensions.size() > 0:
		for dim in options.dimensions:
			if dimension_registry.has(dim) and dimension_registry[dim].active:
				dimensions_to_sync.append(dim)
	else:
		for dim in dimension_registry:
			if dimension_registry[dim].active:
				dimensions_to_sync.append(dim)
	
	if dimensions_to_sync.size() == 0:
		push_warning("No active dimensions to synchronize")
		return false
	
	print("Synchronizing " + str(systems_to_sync.size()) + " systems across " + str(dimensions_to_sync.size()) + " dimensions")
	
	# Collect records from each system
	var system_records = {}
	
	for system_id in systems_to_sync:
		system_records[system_id] = _collect_system_records(system_id, dimensions_to_sync, options.max_records)
	
	# Synchronize records between systems
	var sync_count = 0
	
	for source_id in system_records:
		for target_id in system_records:
			if source_id == target_id:
				continue
			
			# Check if these systems should be connected
			var connection_id = source_id + "_to_" + target_id
			if not active_connections.has(connection_id):
				connection_id = connect_systems(source_id, target_id, config.default_connection_type)
				
				if not connection_id:
					continue
			
			# Synchronize records from source to target
			var records = system_records[source_id]
			for record_id in records:
				var record = records[record_id]
				
				# Skip if target already has this record
				if system_records[target_id].has(record_id):
					continue
				
				# Transfer record
				if _transfer_record(record_id, record.content, record.metadata, source_id, target_id):
					sync_count += 1
	
	print("Synchronized " + str(sync_count) + " records between systems")
	
	# Update connection timestamps
	for connection_id in active_connections:
		active_connections[connection_id].last_sync = OS.get_unix_time()
	
	emit_signal("synchronization_completed", systems_to_sync)
	
	return sync_count > 0

func _collect_system_records(system_id, dimensions, max_records):
	var system = connected_systems[system_id]
	var records = {}
	var count = 0
	
	# Collect from cache first
	for level in record_cache:
		for record_id in record_cache[level]:
			var record = record_cache[level][record_id]
			
			# Check if this record belongs to a dimension we're syncing
			var record_dimension = record.metadata.get("dimension", "akashic")
			if not dimensions.has(record_dimension):
				continue
			
			# Check if this record is stored in our system
			if record.storage.has(system_id):
				records[record_id] = record
				count += 1
				
				if count >= max_records:
					return records
	
	# If we need more records, query the system directly
	if count < max_records:
		match system.type:
			"akashic_database":
				# Not implemented - would need custom API
				pass
			
			"akashic_records":
				# Not implemented - would need custom API
				pass
			
			"claude_akashic":
				if system.node.has_method("query_akashic_records"):
					for dimension in dimensions:
						var result = system.node.query_akashic_records("*", {
							"dimension": dimension,
							"max_results": max_records - count
						})
						
						if result and typeof(result) == TYPE_ARRAY:
							for item in result:
								var record_id = item.get("id", "unknown_" + str(OS.get_unix_time()))
								
								if not records.has(record_id):
									records[record_id] = {
										"content": item.get("content", ""),
										"metadata": item,
										"storage": [system_id]
									}
									count += 1
									
									if count >= max_records:
										return records
			
			"ethereal_akashic":
				if system.node.has_method("search_akashic_records"):
					for dimension in dimensions:
						var results = system.node.search_akashic_records("", dimension)
						
						if results and results.size() > 0:
							for item in results:
								var record_id = item.get("id", "unknown_" + str(OS.get_unix_time()))
								
								if not records.has(record_id):
									records[record_id] = {
										"content": item.get("content", ""),
										"metadata": item,
										"storage": [system_id]
									}
									count += 1
									
									if count >= max_records:
										return records
	
	return records

func _queue_record_distribution(record_id, content, metadata, source_system_id):
	# Add to transfer queue for distribution to other systems
	var transfer_item = {
		"record_id": record_id,
		"content": content,
		"metadata": metadata,
		"source_system": source_system_id,
		"queued_at": OS.get_unix_time(),
		"attempts": 0,
		"distributed_to": []
	}
	
	transfer_queue.append(transfer_item)
	
	print("Queued record " + record_id + " for distribution")
	
	return true

func _transfer_record(record_id, content, metadata, source_system_id, target_system_id):
	if not connected_systems.has(source_system_id) or not connected_systems.has(target_system_id):
		push_error("Cannot transfer record: Invalid system ID")
		return false
	
	var target_system = connected_systems[target_system_id]
	var target_node = target_system.node
	
	# Check dimension access
	var record_dimension = metadata.get("dimension", "akashic")
	var dimension_level = _get_dimension_level(record_dimension)
	
	if dimension_level > config.dimension_access or not dimensional_gates[record_dimension].open:
		push_error("Cannot transfer record: Insufficient dimension access")
		return false
	
	print("Transferring record " + record_id + " from " + source_system_id + " to " + target_system_id)
	
	# Update metadata for transfer
	var transfer_metadata = metadata.duplicate()
	transfer_metadata["transferred_from"] = source_system_id
	transfer_metadata["transferred_at"] = OS.get_unix_time()
	transfer_metadata["original_timestamp"] = metadata.get("timestamp", metadata.get("created", 0))
	
	# Transfer based on target system type
	var success = false
	
	match target_system.type:
		"akashic_database":
			if target_node.has_method("add_word"):
				success = target_node.add_word(record_id, 60, transfer_metadata)
		
		"akashic_records":
			if target_node.has_method("add_record"):
				success = target_node.add_record({
					"id": record_id,
					"content": content,
					"metadata": transfer_metadata
				})
		
		"claude_akashic":
			if target_node.has_method("create_protected_record"):
				var result = target_node.create_protected_record("text", content, transfer_metadata)
				success = result != null
		
		"ethereal_akashic":
			if target_node.has_method("record_memory"):
				success = target_node.record_memory(content, [record_id], record_dimension)
	
	if success:
		# Update connection data
		var connection_id = source_system_id + "_to_" + target_system_id
		if active_connections.has(connection_id):
			active_connections[connection_id].transfers += 1
		
		# Update cache
		if record_cache.has(str(dimension_level)) and record_cache[str(dimension_level)].has(record_id):
			if not record_cache[str(dimension_level)][record_id].storage.has(target_system_id):
				record_cache[str(dimension_level)][record_id].storage.append(target_system_id)
		else:
			record_cache[str(dimension_level)][record_id] = {
				"content": content,
				"metadata": metadata,
				"storage": [source_system_id, target_system_id]
			}
		
		emit_signal("record_transferred", record_id, source_system_id, target_system_id)
	else:
		emit_signal("transfer_failed", record_id, "Failed to transfer to target system")
	
	return success

# ----- EVENT HANDLERS -----
func _on_connection_timer_timeout():
	# Check for disconnected systems and try to reconnect
	var systems_to_reconnect = []
	
	for system_id in connected_systems:
		var system = connected_systems[system_id]
		if system.status != "connected":
			systems_to_reconnect.append(system_id)
	
	for system_id in systems_to_reconnect:
		# Try to reconnect based on system type
		var system = connected_systems[system_id]
		
		match system.type:
			"akashic_database":
				if system.node.has_method("connect_to_akashic_systems"):
					if system.node.connect_to_akashic_systems():
						system.status = "connected"
						print("Reconnected to system: " + system_id)
			
			"claude_akashic":
				if system.node.has_method("_initialize_bridge"):
					system.node._initialize_bridge()
					system.status = "connected"
					print("Reconnected to system: " + system_id)

func _on_sync_timer_timeout():
	# Perform synchronization if in scheduled mode
	if config.synchronization_mode == "scheduled":
		synchronize_systems()

func _on_cleanup_timer_timeout():
	# Clean up old cache entries
	var current_time = OS.get_unix_time()
	var cache_expiry = 3600  # 1 hour cache lifetime
	
	for level in record_cache:
		var records_to_remove = []
		
		for record_id in record_cache[level]:
			var record = record_cache[level][record_id]
			var record_time = record.metadata.get("timestamp", record.metadata.get("created", 0))
			
			if current_time - record_time > cache_expiry:
				records_to_remove.append(record_id)
		
		for record_id in records_to_remove:
			record_cache[level].erase(record_id)
	
	print("Cleaned up cache, removed " + str(records_to_remove.size()) + " old records")

func _on_transfer_timer_timeout():
	# Process transfer queue
	if transfer_queue.size() == 0:
		return
	
	var max_transfers_per_cycle = 5
	var transfers_this_cycle = 0
	var items_to_remove = []
	
	for i in range(min(transfer_queue.size(), max_transfers_per_cycle)):
		var item = transfer_queue[i]
		
		# Skip items with too many attempts
		if item.attempts >= 3:
			items_to_remove.append(i)
			emit_signal("transfer_failed", item.record_id, "Too many failed attempts")
			continue
		
		# Find target systems
		var target_systems = []
		
		for system_id in connected_systems:
			if system_id == item.source_system:
				continue
			
			if item.distributed_to.has(system_id):
				continue
			
			# Check if system has access to this dimension
			var record_dimension = item.metadata.get("dimension", "akashic")
			if connected_systems[system_id].dimensions.has(record_dimension):
				target_systems.append(system_id)
		
		# Distribute to target systems
		for target_id in target_systems:
			if _transfer_record(item.record_id, item.content, item.metadata, item.source_system, target_id):
				item.distributed_to.append(target_id)
				transfers_this_cycle += 1
			else:
				item.attempts += 1
		
		# If distributed to all systems or too many attempts, remove from queue
		if item.distributed_to.size() >= target_systems.size() or item.attempts >= 3:
			items_to_remove.append(i)
	
	# Remove processed items (in reverse order to maintain indices)
	items_to_remove.sort()
	items_to_remove.invert()
	
	for idx in items_to_remove:
		transfer_queue.remove(idx)
	
	if transfers_this_cycle > 0:
		print("Processed " + str(transfers_this_cycle) + " transfers, " + str(transfer_queue.size()) + " remaining in queue")

func _on_database_connected(system_id):
	if connected_systems.has(system_id):
		connected_systems[system_id].status = "connected"
		print("Database system connected: " + system_id)

func _on_database_disconnected(system_id):
	if connected_systems.has(system_id):
		connected_systems[system_id].status = "disconnected"
		print("Database system disconnected: " + system_id)

func _on_word_added(word, power, system_id):
	# When a word is added to a database system, store in our cache
	var metadata = {
		"word": word,
		"power": power,
		"source_system": system_id,
		"timestamp": OS.get_unix_time()
	}
	
	var dimension_level = 4  # Default to akashic level
	var record_id = "word_" + str(OS.get_unix_time()) + "_" + word
	
	record_cache[str(dimension_level)][record_id] = {
		"content": word,
		"metadata": metadata,
		"storage": [system_id]
	}

func _on_word_stored(word, power, metadata, system_id):
	# When a word is stored by ClaudeAkashicBridge
	_on_word_added(word, power, system_id)

func _on_dimension_changed(previous, current, system_id):
	# When a dimension changes in an ethereal system
	print("Dimension changed in system " + system_id + " from " + previous + " to " + current)
	
	# Update dimension registry
	for dim in dimension_registry:
		if dimension_registry[dim].connections.size() > 0:
			for connection in dimension_registry[dim].connections:
				if connection.source == system_id or connection.target == system_id:
					connection.current_dimension = current

func _on_data_transferred(channel, size, system_id):
	# When data is transferred in an ethereal system
	print("Data transferred in system " + system_id + " - channel: " + channel + ", size: " + str(size))

func _on_gate_status_changed(gate_name, status, system_id):
	# When a gate status changes in ClaudeAkashicBridge
	print("Gate " + gate_name + " status changed to " + str(status) + " in system " + system_id)
	
	# Map gate name to our dimensional gates
	var gate_number = gate_name.split("_")[1].to_int()
	var dimension_name = ""
	
	match gate_number:
		0: dimension_name = "physical"
		1: dimension_name = "memory"
		2: dimension_name = "ethereal"
		3: dimension_name = "akashic"
		4: dimension_name = "cloud"
		5: dimension_name = "dimensional"
		_: dimension_name = "transcendent"
	
	if dimensional_gates.has(dimension_name):
		dimensional_gates[dimension_name].open = status

# ----- PUBLIC API -----
func get_connected_systems():
	return connected_systems

func get_active_connections():
	return active_connections

func get_dimensional_gates():
	return dimensional_gates

func get_dimension_registry():
	return dimension_registry

func get_cache_stats():
	var stats = {
		"total_records": 0,
		"by_level": {}
	}
	
	for level in record_cache:
		stats.by_level[level] = record_cache[level].size()
		stats.total_records += record_cache[level].size()
	
	return stats

func get_transfer_queue_size():
	return transfer_queue.size()

func get_connection_history():
	return connection_history

func set_config(key, value):
	if not config.has(key):
		push_error("Invalid config key: " + key)
		return false
	
	config[key] = value
	
	# Handle special config changes
	match key:
		"dimension_access":
			set_dimension_access(value)
		"synchronization_mode":
			# Update sync timer frequency based on mode
			match value:
				"instant":
					sync_timer.wait_time = 5.0
				"scheduled":
					sync_timer.wait_time = 30.0
				"manual":
					sync_timer.wait_time = 300.0
				"conditional":
					sync_timer.wait_time = 60.0
			
			sync_timer.start()
	
	return true

func disconnect_system(system_id):
	if not connected_systems.has(system_id):
		push_error("Cannot disconnect: System not found")
		return false
	
	print("Disconnecting system: " + system_id)
	
	var system = connected_systems[system_id]
	system.status = "disconnected"
	
	# Remove from dimensional gates
	for gate_name in dimensional_gates:
		var gate = dimensional_gates[gate_name]
		if gate.systems.has(system_id):
			gate.systems.erase(system_id)
	
	# Mark connections as inactive
	for connection_id in active_connections:
		var connection = active_connections[connection_id]
		if connection.source == system_id or connection.target == system_id:
			connection.status = "inactive"
			
			# Update connection history
			if connection_history.has(connection_id):
				connection_history[connection_id].status_log.append({
					"timestamp": OS.get_unix_time(),
					"status": "disconnected"
				})
	
	emit_signal("system_disconnected", system_id)
	
	return true

func clear_cache():
	for level in record_cache:
		record_cache[level].clear()
	
	print("Cache cleared")
	return true

# Class for standalone use
class AkashicRecord:
	var id
	var content
	var metadata
	var dimension
	var timestamp
	
	func _init(p_id, p_content, p_metadata={}, p_dimension="akashic"):
		id = p_id
		content = p_content
		metadata = p_metadata
		dimension = p_dimension
		timestamp = OS.get_unix_time()
		
		# Add basic metadata
		if not metadata.has("created"):
			metadata.created = timestamp
		if not metadata.has("dimension"):
			metadata.dimension = dimension
	
	func to_dict():
		return {
			"id": id,
			"content": content,
			"metadata": metadata,
			"dimension": dimension,
			"timestamp": timestamp
		}