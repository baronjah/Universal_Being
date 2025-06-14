extends Node

class_name UniversalDataFlow

# Universal Data Flow
# Manages bidirectional data flow between Terminal, Claude, and game components
# Creates channel-based communication system
# Handles negative generation and difference calculation

signal data_flow_established(source, target, channel, direction)
signal negative_generated(source, negative)
signal difference_calculated(source, target, difference_value)
signal universal_shape_applied(shape_type, affected_components)

# === CONSTANTS ===
const FLOW_DIRECTIONS = {
	"unidirectional": 1,
	"bidirectional": 2,
	"broadcast": 3,
	"conditional": 4
}

const COMPONENT_TYPES = {
	"terminal": 1,
	"claude": 2,
	"game": 3,
	"file_system": 4,
	"api": 5
}

const SHAPE_TYPES = {
	"cube": 1,
	"sphere": 2,
	"pyramid": 3,
	"cylinder": 4,
	"torus": 5
}

# === VARIABLES ===
var data_flows = {}            # Active data flows
var connected_components = {}  # Connected components
var negative_cache = {}        # Cache of generated negatives
var difference_cache = {}      # Cache of calculated differences
var universal_shapes = []      # Shapes that affect all elements
var flow_history = []          # History of data flows

# === INITIALIZATION ===
func _ready():
	# Initialize component connections
	_initialize_component_connections()
	
	print("Universal Data Flow initialized")

# Initialize component connections
func _initialize_component_connections():
	# Set up core components
	connected_components = {
		"terminal": {
			"type": COMPONENT_TYPES.terminal,
			"connections": ["claude", "game"],
			"active": true
		},
		"claude": {
			"type": COMPONENT_TYPES.claude,
			"connections": ["terminal", "game"],
			"active": true
		},
		"game": {
			"type": COMPONENT_TYPES.game,
			"connections": ["terminal", "claude"],
			"active": true
		},
		"file_system": {
			"type": COMPONENT_TYPES.file_system,
			"connections": ["game"],
			"active": true
		},
		"api": {
			"type": COMPONENT_TYPES.api,
			"connections": ["claude", "terminal"],
			"active": true
		}
	}
	
	print("Initialized " + str(connected_components.size()) + " component connections")

# === DATA FLOW MANAGEMENT ===

# Set data flows
func set_data_flows(flows):
	data_flows = flows
	return data_flows

# Establish a data flow between source and target
func establish_flow(source, target, channel, direction = "bidirectional"):
	if not data_flows.has(channel):
		data_flows[channel] = {
			"active": false,
			"source": null,
			"target": null,
			"direction": "bidirectional",
			"amplitude": 1.0,
			"frequency": 0.2
		}
	
	# Update flow parameters
	data_flows[channel].active = true
	data_flows[channel].source = source
	data_flows[channel].target = target
	data_flows[channel].direction = direction
	
	# Record in history
	flow_history.append({
		"action": "establish",
		"source": source,
		"target": target,
		"channel": channel,
		"direction": direction,
		"timestamp": OS.get_ticks_msec()
	})
	
	# Emit signal
	emit_signal("data_flow_established", source, target, channel, direction)
	
	print("Established data flow from " + source + " to " + target + " on channel " + channel)
	return data_flows[channel]

# Terminate a data flow
func terminate_flow(channel):
	if data_flows.has(channel):
		# Store parameters for history
		var source = data_flows[channel].source
		var target = data_flows[channel].target
		
		# Mark as inactive
		data_flows[channel].active = false
		data_flows[channel].source = null
		data_flows[channel].target = null
		
		# Record in history
		flow_history.append({
			"action": "terminate",
			"source": source,
			"target": target,
			"channel": channel,
			"timestamp": OS.get_ticks_msec()
		})
		
		print("Terminated data flow on channel " + channel)
		return true
	
	return false

# Get active flows
func get_active_flows():
	var active = []
	
	for channel in data_flows:
		if data_flows[channel].active:
			active.append(channel)
	
	return active

# === NEGATIVE GENERATION ===

# Initialize negative generator
func initialize_negative_generator():
	# Clear cache
	negative_cache.clear()
	print("Negative generator initialized")

# Generate negative for a component
func generate_negative(component):
	if connected_components.has(component):
		# Generate negative representation
		var negative = {
			"component": component,
			"type": connected_components[component].type,
			"connections": [],
			"active": !connected_components[component].active,
			"generated_at": OS.get_ticks_msec()
		}
		
		# Store in cache
		negative_cache[component] = negative
		
		# Emit signal
		emit_signal("negative_generated", component, negative)
		
		print("Generated negative for component " + component)
		return negative
	
	return null

# Get negative for a component
func get_negative(component):
	if negative_cache.has(component):
		return negative_cache[component]
	
	# Generate if not exists
	return generate_negative(component)

# === DIFFERENCE CALCULATION ===

# Calculate difference between source and target
func calculate_difference(source, target):
	var difference_id = source + "_to_" + target
	
	# Check if source and target exist
	if connected_components.has(source) and connected_components.has(target):
		# Calculate basic difference value
		var difference_value = 0.0
		
		# Different component types
		if connected_components[source].type != connected_components[target].type:
			difference_value += 0.5
		
		# Different connection sets
		var source_connections = connected_components[source].connections
		var target_connections = connected_components[target].connections
		
		var unique_connections = 0
		for conn in source_connections:
			if not target_connections.has(conn):
				unique_connections += 1
		
		for conn in target_connections:
			if not source_connections.has(conn):
				unique_connections += 1
		
		difference_value += unique_connections * 0.1
		
		# Store in cache
		difference_cache[difference_id] = {
			"source": source,
			"target": target,
			"value": difference_value,
			"calculated_at": OS.get_ticks_msec()
		}
		
		# Emit signal
		emit_signal("difference_calculated", source, target, difference_value)
		
		print("Calculated difference between " + source + " and " + target + ": " + str(difference_value))
		return difference_cache[difference_id]
	
	return null

# Get cached difference
func get_difference(source, target):
	var difference_id = source + "_to_" + target
	
	if difference_cache.has(difference_id):
		return difference_cache[difference_id]
	
	# Calculate if not exists
	return calculate_difference(source, target)

# === UNIVERSAL SHAPES ===

# Apply a universal shape to all elements
func apply_universal_shape(shape_type):
	if not SHAPE_TYPES.has(shape_type):
		print("Invalid shape type: " + str(shape_type))
		return null
	
	# Create shape
	var shape = {
		"type": shape_type,
		"affected_components": connected_components.keys(),
		"created_at": OS.get_ticks_msec(),
		"active": true
	}
	
	# Add to list
	universal_shapes.append(shape)
	
	# Emit signal
	emit_signal("universal_shape_applied", shape_type, shape.affected_components)
	
	print("Applied universal shape " + str(shape_type) + " to " + str(shape.affected_components.size()) + " components")
	return shape

# Get active universal shapes
func get_universal_shapes():
	return universal_shapes

# === UTILITY METHODS ===

# Get flow history
func get_flow_history():
	return flow_history

# Get connected components
func get_connected_components():
	return connected_components

# Get negative cache
func get_negative_cache():
	return negative_cache

# Process communication
func _process(delta):
	# Process active flows
	for channel in get_active_flows():
		var flow = data_flows[channel]
		
		# Signal periodically for active flows
		if randf() < 0.01:  # 1% chance per frame
			emit_signal("data_flow_established", flow.source, flow.target, channel, flow.direction)