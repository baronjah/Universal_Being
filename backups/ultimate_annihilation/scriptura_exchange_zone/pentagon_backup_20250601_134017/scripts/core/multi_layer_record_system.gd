# ==================================================
# SCRIPT NAME: multi_layer_record_system.gd
# DESCRIPTION: Multi-layer movable array/dictionary system
# PURPOSE: Three-layer state management (active/pending/archived)
# CREATED: 2025-05-25 - Based on main.gd patterns
# ==================================================

extends UniversalBeingBase
# State Layers (from your main.gd concept)
var record_layers: Dictionary = {
	"active": {},      # Currently in use
	"pending": {},     # Being processed/loaded
	"cached": {},      # Ready for quick access
	"archived": {}     # Long-term storage
}

# Mutex for thread safety
var layer_mutex: Mutex = Mutex.new()

# State tracking
var current_states: Dictionary = {
	"containers": {},
	"datapoints": {},
	"interactions": {}
}

# Tree structure (nicely split dictionary)
var state_tree: Dictionary = {
	"root": {
		"active_branch": {},
		"pending_branch": {},
		"archived_branch": {}
	}
}

signal state_changed(layer: String, key: String, value: Variant)
signal layer_transition(from_layer: String, to_layer: String, data: Dictionary)

## Move data between layers
# INPUT: Data key, source layer, target layer
# PROCESS: Transfers data between state layers
# OUTPUT: Success boolean
# CHANGES: record_layers contents
# CONNECTION: Called by state management

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func move_between_layers(data_key: String, from_layer: String, to_layer: String) -> bool:
	layer_mutex.lock()
	
	# Validate layers exist
	if not record_layers.has(from_layer) or not record_layers.has(to_layer):
		layer_mutex.unlock()
		return false
	
	# Check if data exists in source
	if not record_layers[from_layer].has(data_key):
		layer_mutex.unlock()
		return false
	
	# Move the data
	var data = record_layers[from_layer][data_key]
	record_layers[to_layer][data_key] = data
	record_layers[from_layer].erase(data_key)
	
	layer_mutex.unlock()
	
	emit_signal("layer_transition", from_layer, to_layer, {"key": data_key, "data": data})
	return true

## Check state in all layers
# INPUT: Data key to search
# PROCESS: Searches all layers for key
# OUTPUT: Dictionary with layer info
# CHANGES: None
# CONNECTION: Status queries
func check_state_in_layers(data_key: String) -> Dictionary:
	var result = {
		"found": false,
		"layer": "",
		"status": -1  # -1 = not found, 0 = empty, 1 = has data
	}
	
	layer_mutex.lock()
	
	for layer_name in record_layers:
		if record_layers[layer_name].has(data_key):
			result.found = true
			result.layer = layer_name
			
			var data = record_layers[layer_name][data_key]
			if data is Dictionary and data.is_empty():
				result.status = 0
			elif data is Array and data.is_empty():
				result.status = 0
			else:
				result.status = 1
			break
	
	layer_mutex.unlock()
	return result

## Smart state promotion
# INPUT: Data key
# PROCESS: Promotes data towards active layer
# OUTPUT: New layer name
# CHANGES: Moves data up hierarchy
# CONNECTION: Access patterns
func promote_to_active(data_key: String) -> String:
	var state = check_state_in_layers(data_key)
	
	if not state.found:
		return ""
	
	# Promotion hierarchy: archived -> cached -> pending -> active
	match state.layer:
		"archived":
			move_between_layers(data_key, "archived", "cached")
			return "cached"
		"cached":
			move_between_layers(data_key, "cached", "pending")
			return "pending"
		"pending":
			move_between_layers(data_key, "pending", "active")
			return "active"
		"active":
			return "active"  # Already at top
	
	return state.layer

## Demote inactive data
# INPUT: Data key
# PROCESS: Demotes data towards archived
# OUTPUT: New layer name
# CHANGES: Moves data down hierarchy
# CONNECTION: Memory management
func demote_from_active(data_key: String) -> String:
	var state = check_state_in_layers(data_key)
	
	if not state.found:
		return ""
	
	# Demotion hierarchy: active -> pending -> cached -> archived
	match state.layer:
		"active":
			move_between_layers(data_key, "active", "pending")
			return "pending"
		"pending":
			move_between_layers(data_key, "pending", "cached")
			return "cached"
		"cached":
			move_between_layers(data_key, "cached", "archived")
			return "archived"
		"archived":
			return "archived"  # Already at bottom
	
	return state.layer

## Batch operations
# INPUT: Array of keys, operation type
# PROCESS: Performs operation on multiple items
# OUTPUT: Results dictionary
# CHANGES: Multiple layer transitions
# CONNECTION: Bulk management
func batch_operation(keys: Array, operation: String) -> Dictionary:
	var results = {}
	
	for key in keys:
		match operation:
			"promote":
				results[key] = promote_to_active(key)
			"demote":
				results[key] = demote_from_active(key)
			"archive":
				var current = check_state_in_layers(key)
				if current.found and current.layer != "archived":
					move_between_layers(key, current.layer, "archived")
					results[key] = "archived"
			"activate":
				var current = check_state_in_layers(key)
				if current.found and current.layer != "active":
					move_between_layers(key, current.layer, "active")
					results[key] = "active"
	
	return results

## Get layer statistics
# INPUT: None
# PROCESS: Counts items in each layer
# OUTPUT: Statistics dictionary
# CHANGES: None
# CONNECTION: Monitoring
func get_layer_stats() -> Dictionary:
	var stats = {}
	
	layer_mutex.lock()
	
	for layer_name in record_layers:
		stats[layer_name] = {
			"count": record_layers[layer_name].size(),
			"keys": record_layers[layer_name].keys()
		}
	
	layer_mutex.unlock()
	
	return stats

## Clean up empty entries
# INPUT: None
# PROCESS: Removes empty data from all layers
# OUTPUT: Number of entries cleaned
# CHANGES: Removes empty entries
# CONNECTION: Maintenance
func cleanup_empty_entries() -> int:
	var cleaned_count = 0
	
	layer_mutex.lock()
	
	for layer_name in record_layers:
		var to_remove = []
		
		for key in record_layers[layer_name]:
			var data = record_layers[layer_name][key]
			
			if data == null:
				to_remove.append(key)
			elif data is Dictionary and data.is_empty():
				to_remove.append(key)
			elif data is Array and data.is_empty():
				to_remove.append(key)
		
		for key in to_remove:
			record_layers[layer_name].erase(key)
			cleaned_count += 1
	
	layer_mutex.unlock()
	
	return cleaned_count

## Store data with metadata
# INPUT: Key, data, initial layer
# PROCESS: Stores data with timestamp and metadata
# OUTPUT: Success boolean
# CHANGES: Adds to specified layer
# CONNECTION: Data creation
func store_with_metadata(key: String, data: Variant, layer: String = "pending") -> bool:
	if not record_layers.has(layer):
		return false
	
	layer_mutex.lock()
	
	var wrapped_data = {
		"data": data,
		"metadata": {
			"created": Time.get_ticks_msec(),
			"last_accessed": Time.get_ticks_msec(),
			"access_count": 0,
			"original_layer": layer
		}
	}
	
	record_layers[layer][key] = wrapped_data
	
	layer_mutex.unlock()
	
	emit_signal("state_changed", layer, key, wrapped_data)
	return true

## Access data with tracking
# INPUT: Data key
# PROCESS: Returns data and updates access metadata
# OUTPUT: Data or null
# CHANGES: Updates access timestamp and count
# CONNECTION: Data retrieval
func access_data(key: String) -> Variant:
	var state = check_state_in_layers(key)
	
	if not state.found:
		return null
	
	layer_mutex.lock()
	
	var wrapped = record_layers[state.layer][key]
	if wrapped is Dictionary and wrapped.has("data"):
		# Update access metadata
		if wrapped.has("metadata"):
			wrapped.metadata.last_accessed = Time.get_ticks_msec()
			wrapped.metadata.access_count += 1
		
		layer_mutex.unlock()
		return wrapped.data
	
	layer_mutex.unlock()
	return wrapped  # Return raw data if not wrapped