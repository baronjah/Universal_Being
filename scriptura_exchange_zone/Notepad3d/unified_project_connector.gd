extends Node

class_name UnifiedProjectConnector

# Unified Project Connector System
# Connects components across different projects (12_turns_system, LuminusOS, Eden_OS)
# by creating dynamic bridges based on file name and variable matching

# Project paths
const PROJECT_PATHS = {
	"12_turns_system": "/mnt/c/Users/Percision 15/12_turns_system",
	"LuminusOS": "/mnt/c/Users/Percision 15/LuminusOS",
	"Eden_OS": "/mnt/c/Users/Percision 15/Eden_OS",
	"Godot_Eden": "/mnt/c/Users/Percision 15/Godot_Eden"
}

# Connection types
enum ConnectionType {
	FILE_LINK,        # Direct file reference connection
	VARIABLE_MIRROR,  # Mirror variables between components
	SIGNAL_BRIDGE,    # Connect signals between components
	SYSTEM_LINK,      # Link entire subsystems together
	API_CONNECTOR     # Connect via API interface
}

# Component matching criteria
enum MatchCriteria {
	EXACT_NAME,       # Exact file/class name match
	NAME_PATTERN,     # Pattern-based name matching
	FUNCTIONALITY,    # Functionality-based matching
	SEMANTIC_DOMAIN,  # Domain concept matching
	CUSTOM           # Custom matcher function
}

# Tracked connections
var active_connections = {}
var component_registry = {}
var system_bridges = {}

# Signals
signal component_registered(component_id, source_project)
signal connection_established(source_id, target_id, connection_type)
signal data_transferred(source_id, target_id, data_size)

# Tokenization system for content analysis
var tokenizer = null

func _ready():
	print("Unified Project Connector initializing...")
	
	# Initialize tokenization system
	_init_tokenizer()
	
	# Scan project files to build component registry
	_scan_projects()
	
	# Setup default bridges between key systems
	_setup_default_bridges()
	
	print("Unified Project Connector initialized")

func _init_tokenizer():
	# Simple tokenizer implementation
	tokenizer = {
		"split_pattern": "[ \\t\\n\\r.,;:!?(){}\\[\\]<>\"'`=+\\-*/\\\\|@#$%^&]",
		"ignored_words": ["the", "and", "a", "an", "in", "on", "at", "to", "for", "with", "by", "of", "var", "func", "class", "extends"],
		"tokenize": funcref(self, "_tokenize_content")
	}

func _tokenize_content(content):
	if content == null or content.empty():
		return []
	
	var tokens = []
	var pattern = RegEx.new()
	pattern.compile(tokenizer.split_pattern)
	
	var words = pattern.sub(content, " ", true).split(" ", false)
	
	for word in words:
		word = word.strip_edges().to_lower()
		if not word.empty() and not word in tokenizer.ignored_words:
			tokens.append(word)
	
	return tokens

# Register a component in the system
func register_component(project_name, component_path, component_type, metadata = {}):
	if not PROJECT_PATHS.has(project_name):
		push_error("Unknown project: " + project_name)
		return null
	
	var full_path = PROJECT_PATHS[project_name] + "/" + component_path
	
	# Generate a unique component ID
	var component_id = project_name + "::" + component_path
	
	if component_registry.has(component_id):
		print("Component already registered: " + component_id)
		return component_id
	
	# Analyze component content for better matching
	var content_tokens = []
	var file = File.new()
	if file.file_exists(full_path):
		if file.open(full_path, File.READ) == OK:
			var content = file.get_as_text()
			content_tokens = tokenizer.tokenize.call_func(content)
			file.close()
	
	# Store component information
	var component_info = {
		"id": component_id,
		"project": project_name,
		"path": component_path,
		"full_path": full_path,
		"type": component_type,
		"tokens": content_tokens,
		"metadata": metadata,
		"connections": []
	}
	
	component_registry[component_id] = component_info
	emit_signal("component_registered", component_id, project_name)
	
	print("Registered component: " + component_id)
	return component_id

# Connect two components
func connect_components(source_id, target_id, connection_type, config = {}):
	if not component_registry.has(source_id):
		push_error("Source component not found: " + source_id)
		return false
	
	if not component_registry.has(target_id):
		push_error("Target component not found: " + target_id)
		return false
	
	# Generate connection ID
	var connection_id = source_id + "-->" + target_id
	
	if active_connections.has(connection_id):
		print("Connection already exists: " + connection_id)
		return true
	
	var source_info = component_registry[source_id]
	var target_info = component_registry[target_id]
	
	print("Connecting " + source_id + " to " + target_id + " via " + str(connection_type))
	
	# Create the appropriate connection bridge
	var bridge = null
	
	match connection_type:
		ConnectionType.FILE_LINK:
			bridge = _create_file_link(source_info, target_info, config)
		ConnectionType.VARIABLE_MIRROR:
			bridge = _create_variable_mirror(source_info, target_info, config)
		ConnectionType.SIGNAL_BRIDGE:
			bridge = _create_signal_bridge(source_info, target_info, config)
		ConnectionType.SYSTEM_LINK:
			bridge = _create_system_link(source_info, target_info, config)
		ConnectionType.API_CONNECTOR:
			bridge = _create_api_connector(source_info, target_info, config)
	
	if bridge != null:
		# Store connection
		active_connections[connection_id] = {
			"source": source_id,
			"target": target_id,
			"type": connection_type,
			"bridge": bridge,
			"config": config
		}
		
		# Update component connection lists
		source_info.connections.append(connection_id)
		target_info.connections.append(connection_id)
		
		emit_signal("connection_established", source_id, target_id, connection_type)
		print("Successfully connected " + source_id + " to " + target_id)
		return true
	else:
		push_error("Failed to create bridge for connection")
		return false

# Find components matching criteria
func find_components(criteria, value, project_filter = null):
	var matches = []
	
	for component_id in component_registry:
		var component = component_registry[component_id]
		
		# Skip if doesn't match project filter
		if project_filter != null and component.project != project_filter:
			continue
		
		var is_match = false
		
		match criteria:
			MatchCriteria.EXACT_NAME:
				is_match = component.path.get_file().get_basename() == value
			
			MatchCriteria.NAME_PATTERN:
				is_match = component.path.get_file().get_basename().match(value)
			
			MatchCriteria.FUNCTIONALITY:
				# Check if component contains functionality keywords
				for token in component.tokens:
					if token.match(value.to_lower()):
						is_match = true
						break
			
			MatchCriteria.SEMANTIC_DOMAIN:
				# Check if component belongs to semantic domain
				var domain_matches = _check_semantic_domain(component, value)
				is_match = domain_matches
			
			MatchCriteria.CUSTOM:
				# Custom matching provided by caller
				if value is FuncRef:
					is_match = value.call_func(component)
		
		if is_match:
			matches.append(component_id)
	
	return matches

# Transfer data between components
func transfer_data(source_id, target_id, data, channel = "default"):
	if not active_connections.has(source_id + "-->" + target_id):
		# Check if reverse connection exists
		if not active_connections.has(target_id + "-->" + source_id):
			push_error("No connection between components: " + source_id + " and " + target_id)
			return null
		# Use reverse connection
		return transfer_data(target_id, source_id, data, channel)
	
	var connection = active_connections[source_id + "-->" + target_id]
	var bridge = connection.bridge
	
	# Calculate data size (approximate)
	var data_size = typeof(data) == TYPE_STRING ? data.length() : 64
	
	print("Transferring data from " + source_id + " to " + target_id + " via " + channel)
	
	var result = _process_data_transfer(bridge, data, channel)
	
	if result != null:
		emit_signal("data_transferred", source_id, target_id, data_size)
		print("Data transfer successful")
	else:
		push_error("Failed to transfer data")
	
	return result

# Get component status
func get_component_status(component_id):
	if not component_registry.has(component_id):
		return null
	
	var component = component_registry[component_id]
	var status = {
		"id": component.id,
		"project": component.project,
		"path": component.path,
		"connections": component.connections.duplicate(),
		"active": _is_component_active(component)
	}
	
	return status

# Get connection status
func get_connection_status(connection_id):
	if not active_connections.has(connection_id):
		return null
	
	var connection = active_connections[connection_id]
	var status = {
		"source": connection.source,
		"target": connection.target,
		"type": connection.type,
		"active": _is_bridge_active(connection.bridge)
	}
	
	return status

# Get topology of the entire connection network
func get_connection_topology():
	var topology = {
		"components": {},
		"connections": {},
		"projects": {}
	}
	
	# Build component nodes
	for component_id in component_registry:
		var component = component_registry[component_id]
		topology.components[component_id] = {
			"project": component.project,
			"path": component.path,
			"type": component.type
		}
		
		# Update project stats
		if not topology.projects.has(component.project):
			topology.projects[component.project] = {
				"component_count": 0,
				"connection_count": 0
			}
		topology.projects[component.project].component_count += 1
	
	# Build connections
	for connection_id in active_connections:
		var connection = active_connections[connection_id]
		topology.connections[connection_id] = {
			"source": connection.source,
			"target": connection.target,
			"type": connection.type
		}
		
		# Update project stats
		var source_project = component_registry[connection.source].project
		var target_project = component_registry[connection.target].project
		
		topology.projects[source_project].connection_count += 1
		if source_project != target_project:
			topology.projects[target_project].connection_count += 1
	
	return topology

# Implementation-specific methods

func _scan_projects():
	print("Scanning projects for components...")
	
	# Scan each project for components
	for project_name in PROJECT_PATHS:
		_scan_project_directory(project_name, PROJECT_PATHS[project_name])
	
	print("Found " + str(component_registry.size()) + " components across " + str(PROJECT_PATHS.size()) + " projects")

func _scan_project_directory(project_name, project_path, subpath = ""):
	var dir = Directory.new()
	if dir.open(project_path) != OK:
		push_error("Could not open project directory: " + project_path)
		return
	
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = project_path + "/" + file_name
		
		if dir.current_is_dir():
			# Recursively scan subdirectories
			_scan_project_directory(project_name, full_path, subpath + "/" + file_name if subpath else file_name)
		elif file_name.ends_with(".gd"):
			# Register Godot script file
			var component_path = (subpath + "/" + file_name if subpath else file_name).trim_prefix("/")
			register_component(project_name, component_path, "script")
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _setup_default_bridges():
	# Find important connector components
	var universal_connectors = find_components(MatchCriteria.NAME_PATTERN, "*universal*connector*")
	var bridge_components = find_components(MatchCriteria.NAME_PATTERN, "*bridge*")
	
	# Connect universal connectors across projects if found
	for i in range(universal_connectors.size()):
		for j in range(i+1, universal_connectors.size()):
			var connector1 = component_registry[universal_connectors[i]]
			var connector2 = component_registry[universal_connectors[j]]
			
			if connector1.project != connector2.project:
				connect_components(universal_connectors[i], universal_connectors[j], ConnectionType.SYSTEM_LINK)
	
	# Setup dimensional color system bridges
	var color_systems = find_components(MatchCriteria.NAME_PATTERN, "*color*system*")
	for color_system in color_systems:
		# Connect to visualizers
		var visualizers = find_components(MatchCriteria.NAME_PATTERN, "*visualiz*")
		for visualizer in visualizers:
			connect_components(color_system, visualizer, ConnectionType.VARIABLE_MIRROR, {
				"variables": ["color_values", "color_properties"]
			})
	
	# Setup memory system connections
	var memory_systems = find_components(MatchCriteria.NAME_PATTERN, "*memory*system*")
	for i in range(memory_systems.size()):
		for j in range(i+1, memory_systems.size()):
			connect_components(memory_systems[i], memory_systems[j], ConnectionType.VARIABLE_MIRROR, {
				"variables": ["shared_memory"]
			})

func _check_semantic_domain(component, domain):
	# Semantic domains and their associated keywords
	var domains = {
		"memory": ["memory", "storage", "recall", "remember", "forget", "akashic"],
		"visualization": ["visual", "display", "render", "draw", "canvas", "paint"],
		"connection": ["connect", "bridge", "link", "interface", "integration"],
		"processing": ["process", "compute", "calculate", "analyze", "transform"],
		"user_interface": ["ui", "interface", "button", "input", "control", "interact"],
		"data": ["data", "information", "knowledge", "records", "database"],
		"dimension": ["dimension", "plane", "reality", "universe", "world"],
		"color": ["color", "hue", "palette", "rgb", "shade", "tint"]
	}
	
	if not domains.has(domain):
		return false
	
	var domain_keywords = domains[domain]
	
	# Check component tokens for domain matches
	for token in component.tokens:
		for keyword in domain_keywords:
			if token.match("*" + keyword + "*"):
				return true
	
	return false

func _is_component_active(component):
	# Check if component is currently active
	# In a real implementation, would check if file exists and is loaded
	return true

func _is_bridge_active(bridge):
	# Check if bridge is currently active
	# In a real implementation, would check bridge status
	return true

func _process_data_transfer(bridge, data, channel):
	# Process data through the bridge
	# In a real implementation, would use bridge-specific transfer logic
	
	# Simple pass-through implementation
	return data

# Bridge creation methods

func _create_file_link(source_info, target_info, config):
	var bridge = {
		"type": "file_link",
		"source": source_info.full_path,
		"target": target_info.full_path,
		"config": config
	}
	
	return bridge

func _create_variable_mirror(source_info, target_info, config):
	var bridge = {
		"type": "variable_mirror",
		"source": source_info.full_path,
		"target": target_info.full_path,
		"variables": config.get("variables", []),
		"bidirectional": config.get("bidirectional", false),
		"config": config
	}
	
	return bridge

func _create_signal_bridge(source_info, target_info, config):
	var bridge = {
		"type": "signal_bridge",
		"source": source_info.full_path,
		"target": target_info.full_path,
		"signals": config.get("signals", []),
		"config": config
	}
	
	return bridge

func _create_system_link(source_info, target_info, config):
	var bridge = {
		"type": "system_link",
		"source": source_info.full_path,
		"target": target_info.full_path,
		"interaction_mode": config.get("interaction_mode", "proxy"),
		"config": config
	}
	
	return bridge

func _create_api_connector(source_info, target_info, config):
	var bridge = {
		"type": "api_connector",
		"source": source_info.full_path,
		"target": target_info.full_path,
		"api_version": config.get("api_version", "1.0"),
		"endpoints": config.get("endpoints", {}),
		"config": config
	}
	
	return bridge

# Helper method to get name-based connection candidates
func get_name_based_connection_candidates():
	var candidates = []
	
	# Temporary storage to build relationships
	var name_components = {}
	
	# Group components by base name
	for component_id in component_registry:
		var component = component_registry[component_id]
		var base_name = component.path.get_file().get_basename()
		
		# Remove common prefixes/suffixes
		base_name = base_name.replace("_system", "")
		base_name = base_name.replace("_manager", "")
		base_name = base_name.replace("_controller", "")
		base_name = base_name.replace("_interface", "")
		base_name = base_name.replace("_bridge", "")
		base_name = base_name.replace("_connector", "")
		
		if not name_components.has(base_name):
			name_components[base_name] = []
		
		name_components[base_name].append(component_id)
	
	# Find components with the same base name across different projects
	for base_name in name_components:
		var components = name_components[base_name]
		
		if components.size() > 1:
			# Check if components are from different projects
			var projects = {}
			
			for component_id in components:
				var project = component_registry[component_id].project
				if not projects.has(project):
					projects[project] = []
				projects[project].append(component_id)
			
			if projects.size() > 1:
				# Components with same base name in different projects
				for project1 in projects:
					for component1 in projects[project1]:
						for project2 in projects:
							if project1 != project2:
								for component2 in projects[project2]:
									candidates.append({
										"source": component1,
										"target": component2,
										"similarity": "name",
										"base_name": base_name
									})
	
	return candidates

# Helper method to get function-based connection candidates
func get_function_based_connection_candidates():
	var candidates = []
	
	# Analyze component functions by tokenizing file content
	var function_components = {}
	
	for component_id in component_registry:
		var component = component_registry[component_id]
		
		# Extract function names from tokens
		var functions = []
		var file = File.new()
		if file.file_exists(component.full_path):
			if file.open(component.full_path, File.READ) == OK:
				var content = file.get_as_text()
				var lines = content.split("\n")
				
				for line in lines:
					if line.strip_edges().begins_with("func "):
						var func_name = line.strip_edges().substr(5).split("(")[0].strip_edges()
						functions.append(func_name)
				
				file.close()
		
		# Store functions for this component
		if functions.size() > 0:
			component.metadata["functions"] = functions
			
			# Group components by function
			for func_name in functions:
				if not function_components.has(func_name):
					function_components[func_name] = []
				
				function_components[func_name].append(component_id)
	
	# Find components that share function names across different projects
	for func_name in function_components:
		var components = function_components[func_name]
		
		if components.size() > 1:
			# Check if components are from different projects
			var projects = {}
			
			for component_id in components:
				var project = component_registry[component_id].project
				if not projects.has(project):
					projects[project] = []
				projects[project].append(component_id)
			
			if projects.size() > 1:
				# Components with same function in different projects
				for project1 in projects:
					for component1 in projects[project1]:
						for project2 in projects:
							if project1 != project2:
								for component2 in projects[project2]:
									candidates.append({
										"source": component1,
										"target": component2,
										"similarity": "function",
										"function": func_name
									})
	
	return candidates

# Create a visualization file showing connections
func create_visualization(output_path = "/mnt/c/Users/Percision 15/project_connections.json"):
	var visualization = {
		"projects": {},
		"components": [],
		"connections": []
	}
	
	# Add project data
	for project_name in PROJECT_PATHS:
		visualization.projects[project_name] = {
			"path": PROJECT_PATHS[project_name],
			"components": []
		}
	
	# Add component data
	for component_id in component_registry:
		var component = component_registry[component_id]
		
		var component_data = {
			"id": component_id,
			"name": component.path.get_file().get_basename(),
			"project": component.project,
			"path": component.path,
			"type": component.type
		}
		
		visualization.components.append(component_data)
		visualization.projects[component.project].components.append(component_id)
	
	# Add connection data
	for connection_id in active_connections:
		var connection = active_connections[connection_id]
		
		var connection_data = {
			"id": connection_id,
			"source": connection.source,
			"target": connection.target,
			"type": connection.type
		}
		
		visualization.connections.append(connection_data)
	
	# Write visualization file
	var file = File.new()
	if file.open(output_path, File.WRITE) == OK:
		file.store_string(JSON.print(visualization, "  "))
		file.close()
		print("Visualization data written to " + output_path)
		return true
	else:
		push_error("Failed to write visualization file")
		return false