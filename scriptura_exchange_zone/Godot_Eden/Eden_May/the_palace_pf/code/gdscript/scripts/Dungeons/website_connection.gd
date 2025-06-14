class_name WebsiteConnectionManager
extends Node

# Core components of the system
enum ComponentType {
	JSH_ETHEREAL_ENGINE,
	KIT_ANALYZER,
	NETSUITE_CONSOLE,
	INTEGRATED_SOLUTION,
	ENTERPRISE_DEV_SUITE
}

# Connection types between components
enum ConnectionType {
	DATA_FLOW,
	NAVIGATION,
	DEPENDENCY,
	API_CALL
}

# Data structures to store components and their connections
var components = {}
var connections = []
var data_stores = {}
var active_component = null

# Signal for when navigation occurs
signal component_navigated(from_component, to_component)
signal data_transferred(from_component, to_component, data)

func _ready():
	# Initialize the core components
	initialize_components()
	
	# Set up the connections between them
	establish_connections()
	
	# Register data stores
	register_data_stores()

func initialize_components():
	# Set up the JSH Ethereal Engine (core)
	components[ComponentType.JSH_ETHEREAL_ENGINE] = {
		"id": "jsh_ethereal",
		"name": "JSH Ethereal Engine",
		"path": "res://components/jsh_ethereal_engine/",
		"entry_point": "index.html",
		"data_handlers": ["ram_storage", "file_system"],
		"api_endpoints": ["core_api", "connection_manager"]
	}
	
	# Set up Kit Analyzer
	components[ComponentType.KIT_ANALYZER] = {
		"id": "kit_analyzer",
		"name": "Kit Analyzer",
		"path": "res://components/kit_analyzer/",
		"entry_point": "kit-analyzer.html",
		"data_handlers": ["csv_processor", "date_calculator"],
		"api_endpoints": ["analyze_api", "report_generator"]
	}
	
	# Set up NetSuite Console
	components[ComponentType.NETSUITE_CONSOLE] = {
		"id": "netsuite_console",
		"name": "NetSuite Console",
		"path": "res://components/netsuite_console/",
		"entry_point": "netsuite-console.html",
		"data_handlers": ["galaxy_view", "code_editor"],
		"api_endpoints": ["console_api", "visualization_api"]
	}
	
	# Set up Integrated Solution
	components[ComponentType.INTEGRATED_SOLUTION] = {
		"id": "integrated_solution",
		"name": "Integrated Solution",
		"path": "res://components/integrated_solution/",
		"entry_point": "integrated-solution.html",
		"data_handlers": ["kit_analyzer", "visualization", "code_editor"],
		"api_endpoints": ["integrated_api"]
	}
	
	# Set up Enterprise Development Suite
	components[ComponentType.ENTERPRISE_DEV_SUITE] = {
		"id": "enterprise_dev_suite",
		"name": "Enterprise Development Suite",
		"path": "res://components/enterprise_dev_suite/",
		"entry_point": "integrated-app.html",
		"data_handlers": ["project_manager", "application_launcher"],
		"api_endpoints": ["suite_api"]
	}

func establish_connections():
	# JSH Ethereal Engine connects to all components
	create_connection(ComponentType.JSH_ETHEREAL_ENGINE, ComponentType.KIT_ANALYZER, ConnectionType.DATA_FLOW)
	create_connection(ComponentType.JSH_ETHEREAL_ENGINE, ComponentType.NETSUITE_CONSOLE, ConnectionType.DATA_FLOW)
	create_connection(ComponentType.JSH_ETHEREAL_ENGINE, ComponentType.INTEGRATED_SOLUTION, ConnectionType.DATA_FLOW)
	
	# Kit Analyzer connects to Integrated Solution
	create_connection(ComponentType.KIT_ANALYZER, ComponentType.INTEGRATED_SOLUTION, ConnectionType.DATA_FLOW)
	
	# NetSuite Console connects to Integrated Solution
	create_connection(ComponentType.NETSUITE_CONSOLE, ComponentType.INTEGRATED_SOLUTION, ConnectionType.DATA_FLOW)
	
	# Enterprise Dev Suite connects to all applications
	create_connection(ComponentType.ENTERPRISE_DEV_SUITE, ComponentType.KIT_ANALYZER, ConnectionType.NAVIGATION)
	create_connection(ComponentType.ENTERPRISE_DEV_SUITE, ComponentType.NETSUITE_CONSOLE, ConnectionType.NAVIGATION)
	create_connection(ComponentType.ENTERPRISE_DEV_SUITE, ComponentType.INTEGRATED_SOLUTION, ConnectionType.NAVIGATION)

func register_data_stores():
	# Register different data storage mechanisms
	data_stores["ram_storage"] = RAMStorage.new()
	data_stores["file_system"] = FileSystemStorage.new()
	data_stores["csv_storage"] = CSVStorage.new()
	
	# Initialize data stores
	for store_name in data_stores:
		data_stores[store_name].initialize()

func create_connection(from_component, to_component, conn_type):
	connections.append({
		"from": from_component,
		"to": to_component,
		"type": conn_type,
		"active": true,
		"data_flow": [],
		"created_at": Time.get_unix_time_from_system()
	})

func navigate_to_component(component_type):
	var previous_component = active_component
	active_component = component_type
	
	# Emit signal for navigation events
	emit_signal("component_navigated", previous_component, active_component)
	
	# Get the component entry point path
	var entry_point = components[component_type]["entry_point"]
	print("Navigating to: ", components[component_type]["name"], " (", entry_point, ")")
	
	return entry_point

func transfer_data(from_component, to_component, data_payload):
	# Check if there's a valid connection
	var connection_exists = false
	for conn in connections:
		if conn["from"] == from_component and conn["to"] == to_component and conn["active"]:
			connection_exists = true
			break
	
	if not connection_exists:
		push_error("No active connection between components")
		return false
	
	# Process the data through the appropriate handlers
	var processed_data = _process_data_through_handlers(from_component, to_component, data_payload)
	
	# Record the data flow
	_record_data_flow(from_component, to_component, processed_data)
	
	# Emit signal
	emit_signal("data_transferred", from_component, to_component, processed_data)
	
	return processed_data

func _process_data_through_handlers(from_component, to_component, data_payload):
	# Get handlers from both components
	var source_handlers = components[from_component]["data_handlers"]
	var target_handlers = components[to_component]["data_handlers"]
	
	# Process data through source component's output handlers
	var intermediate_data = data_payload
	for handler in source_handlers:
		if handler in data_stores:
			intermediate_data = data_stores[handler].process_outgoing_data(intermediate_data)
	
	# Process data through target component's input handlers
	var processed_data = intermediate_data
	for handler in target_handlers:
		if handler in data_stores:
			processed_data = data_stores[handler].process_incoming_data(processed_data)
	
	return processed_data

func _record_data_flow(from_component, to_component, data):
	# Find the connection and record this data flow
	for conn in connections:
		if conn["from"] == from_component and conn["to"] == to_component:
			var flow_record = {
				"timestamp": Time.get_unix_time_from_system(),
				"data_size": len(str(data)),
				"data_type": typeof(data),
				"success": true
			}
			conn["data_flow"].append(flow_record)
			
			# Limit the history to prevent memory overflow
			if conn["data_flow"].size() > 100:
				conn["data_flow"].pop_front()
			
			break

func store_data(storage_type, key, data):
	if storage_type in data_stores:
		return data_stores[storage_type].store(key, data)
	return false

func retrieve_data(storage_type, key):
	if storage_type in data_stores:
		return data_stores[storage_type].retrieve(key)
	return null

func evolve_component(component_type, evolution_data):
	if component_type in components:
		# Backup current state
		var backup = components[component_type].duplicate(true)
		
		# Apply evolution
		for key in evolution_data:
			if key in components[component_type]:
				if key == "api_endpoints" or key == "data_handlers":
					# For arrays, we want to merge, not replace
					for item in evolution_data[key]:
						if not item in components[component_type][key]:
							components[component_type][key].append(item)
				else:
					# For other properties, replace
					components[component_type][key] = evolution_data[key]
		
		# Store backup for potential rollback
		store_data("ram_storage", "backup_" + str(component_type), backup)
		
		print("Component evolved: ", components[component_type]["name"])
		return true
	
	return false
