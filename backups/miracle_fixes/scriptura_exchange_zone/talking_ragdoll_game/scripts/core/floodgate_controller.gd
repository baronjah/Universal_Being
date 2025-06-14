extends UniversalBeingBase
# FLOODGATE CONTROLLER - Central Control System Based on Eden Pattern
# All node operations, asset loading, and scene manipulations pass through this system
# Uses the dimensional magic pattern for thread-safe queued operations
# Based on the Eden main.gd floodgate system

# ----- SYSTEM CONFIGURATION -----
const MAX_QUEUE_SIZE = 1000
const MAX_OBJECTS_IN_SCENE = 144  # Sacred limit - 12 squared
const MAX_ASTRAL_BEINGS = 12      # Spiritual helpers limit

# Process limits per cycle (matching Eden pattern)
var max_actions_per_cycle: int = 10
var max_nodes_added_per_cycle: int = 5
var max_data_send_per_cycle: int = 8
var max_movements_per_cycle: int = 15
var max_nodes_to_unload_per_cycle: int = 3
var max_functions_called_per_cycle: int = 12
var max_additionals_per_cycle: int = 6
var max_messages_per_cycle: int = 7
var max_textures_applied_per_turn: int = 369

# Operation types
enum OperationType {
	CREATE_NODE,
	DELETE_NODE,
	MOVE_NODE,
	ROTATE_NODE,
	SCALE_NODE,
	REPARENT_NODE,
	LOAD_ASSET,
	UNLOAD_ASSET,
	MODIFY_PROPERTY,
	CALL_METHOD,
	EMIT_SIGNAL,
	CONNECT_SIGNAL,
	DISCONNECT_SIGNAL,
	CHANGE_PHYSICS_STATE,
	SYNC_PHYSICS_STATE,
	UPDATE_RAGDOLL_POSITION,
	CREATE_UNIVERSAL_BEING,
	TRANSFORM_UNIVERSAL_BEING,
	CONNECT_UNIVERSAL_BEINGS
}

# Asset types
enum AssetType {
	SCENE,
	MESH,
	TEXTURE,
	AUDIO,
	SCRIPT,
	SHADER,
	MATERIAL
}

# ----- DIMENSIONAL MAGIC QUEUES (Eden Pattern) -----
var actions_to_be_called = []          # System 0 - Primary actions
var nodes_to_be_added = []             # System 1 - Node creation
var data_to_be_send = []               # System 2 - Data transmission
var things_to_be_moved = []            # System 3 - Movement operations
var nodes_to_be_unloaded = []          # System 4 - Node deletion
var functions_to_be_called = []        # System 5 - Function calls
var additionals_to_be_called = []      # System 6 - Additional operations
var messages_to_be_called = []         # System 7 - Message passing
var container_state_operations = []    # System 8 - Container states
var texture_storage = {}               # System 9 - Texture management
var physics_state_updates = []         # System 10 - Physics state sync
var ragdoll_position_updates = []      # System 11 - Ragdoll tracking

# ----- THREAD SAFETY MUTEXES (Eden Pattern) -----
var mutex_actions = Mutex.new()
var mutex_nodes_to_be_added = Mutex.new()
var mutex_data_to_send = Mutex.new()
var movmentes_mutex = Mutex.new()
var mutex_for_unloading_nodes = Mutex.new()
var mutex_function_call = Mutex.new()
var mutex_additionals_call = Mutex.new()
var mutex_messages_call = Mutex.new()
var mutex_for_container_state = Mutex.new()
var texture_storage_mutex = Mutex.new()
var physics_state_mutex = Mutex.new()
var ragdoll_position_mutex = Mutex.new()

# ----- ASSET MANAGEMENT -----
var loaded_assets = {}
var pending_assets = []
var asset_approval_required = true
var approved_assets = []

# ----- NODE REGISTRY -----
var registered_nodes = {}
var node_hierarchy = {}
var node_operation_locks = {}

# ----- SCENE TREE TRACKER -----
var scene_tree_tracker: Node3D = null

# ----- PHYSICS STATE MANAGER -----
var physics_state_manager: Node3D = null

# ----- OPERATION QUEUE (Legacy compatibility) -----
var operation_queue = []
var processing_operation = false
var current_operation = null
var operation_history = []
var failed_operations = []

# ----- THREAD SAFETY (Legacy compatibility) -----
var mutex = Mutex.new()
var max_threads = 4
var thread_pool = []

# ----- MEMORY TRACKING -----
var stored_delta_memory = []
var memory_metadata = {
	"last_cleanup": 0,
	"cleanup_thresholds": {
		"time_between_cleanups": 5000  # 5 seconds
	}
}

# ----- OBJECT LIMIT MANAGEMENT -----
var tracked_objects: Array[Dictionary] = []  # {node, creation_time, type}
var astral_beings: Array[Node] = []
var object_creation_order: Array[Node] = []

# ----- LOGGING SYSTEM -----
var log_to_file = true
var log_file_path = "user://floodgate_log.txt"
var log_file = null
var log_buffer = []
var max_log_buffer = 100

# ----- SIGNALS -----
signal operation_queued(operation)
signal operation_started(operation)
signal operation_completed(operation, success)
signal operation_failed(operation, error)
signal asset_loaded(asset_path, asset)
signal asset_approval_needed(asset_path)
signal node_registered(node_path)
signal node_unregistered(node_path)

# ----- INITIALIZATION -----
func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[FloodgateController] Initializing central control system...")
	
	# Initialize scene tree tracker
	var tracker_script = load("res://scripts/core/scene_tree_tracker.gd")
	if tracker_script:
		scene_tree_tracker = Node3D.new()
		scene_tree_tracker.name = "SceneTreeTracker"
		scene_tree_tracker.set_script(tracker_script)
		add_child(scene_tree_tracker)
		print("[FloodgateController] Scene tree tracker initialized")
	else:
		print("[FloodgateController] Warning: Could not load scene tree tracker")
	
	# Initialize physics state manager
	var physics_script = load("res://scripts/core/physics_state_manager.gd")
	if physics_script:
		physics_state_manager = Node3D.new()
		physics_state_manager.name = "PhysicsStateManager"
		physics_state_manager.set_script(physics_script)
		add_child(physics_state_manager)
		print("[FloodgateController] Physics state manager initialized")
	else:
		print("[FloodgateController] Warning: Could not load physics state manager")
	
	# Initialize logging
	if log_to_file:
		log_file = FileAccess.open(log_file_path, FileAccess.WRITE)
		_log("=== FLOODGATE CONTROLLER INITIALIZED ===", "SYSTEM")
		_log("Time: " + Time.get_datetime_string_from_system(), "SYSTEM")
	
	# Initialize thread pool
	for i in range(max_threads):
		var thread = Thread.new()
		thread_pool.append(thread)
	
	# Start operation processor
	set_process(true)
	
	_log("Floodgate Controller ready for operations", "SYSTEM")

# Exit tree logic integrated into Pentagon sewers
func pentagon_sewers() -> void:
	super.pentagon_sewers()
	# Tree exit cleanup
	# Clean up threads
	for thread in thread_pool:
		if thread.is_started():
			thread.wait_to_finish()
	
	# Close log file
	if log_file:
		_flush_log_buffer()
		log_file.close()

# ----- MAIN PROCESS (Eden Pattern) -----
func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Track delta memory (Eden pattern)
	each_blimp_of_delta()
	
	# Process all systems in order
	process_system()


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func each_blimp_of_delta():
	var each_blimp_time = Time.get_ticks_msec()
	stored_delta_memory.append(each_blimp_time)
	if stored_delta_memory.size() > 9:
		var _last_delta_to_forget = stored_delta_memory.pop_front()

func process_system():
	process_system_0()  # Primary actions
	process_system_1()  # Node creation
	process_system_2()  # Data transmission
	process_system_3()  # Movement operations
	process_system_4()  # Node deletion
	process_system_5()  # Function calls
	process_system_6()  # Additional operations
	process_system_7()  # Message passing
	process_system_8()  # Container states
	process_system_9()  # Texture management
	process_system_10() # Physics state sync
	process_system_11() # Ragdoll tracking

# ----- OPERATION MANAGEMENT -----
func queue_operation(type: OperationType, params: Dictionary, priority: int = 0) -> String:
	mutex.lock()
	
	var operation = {
		"id": _generate_operation_id(),
		"type": type,
		"params": params,
		"priority": priority,
		"timestamp": Time.get_unix_time_from_system(),
		"status": "queued",
		"caller_info": _get_caller_info()
	}
	
	# Check queue size
	if operation_queue.size() >= MAX_QUEUE_SIZE:
		mutex.unlock()
		_log("Operation queue full! Rejecting operation: " + str(type), "ERROR")
		emit_signal("operation_failed", operation, "Queue full")
		return ""
	
	# Add to queue based on priority
	var inserted = false
	for i in range(operation_queue.size()):
		if operation.priority > operation_queue[i].priority:
			operation_queue.insert(i, operation)
			inserted = true
			break
	
	if not inserted:
		operation_queue.append(operation)
	
	_log("Operation queued: " + operation.id + " Type: " + _get_operation_name(type), "QUEUE", operation.caller_info)
	emit_signal("operation_queued", operation)
	
	mutex.unlock()
	return operation.id

func _process_next_operation():
	mutex.lock()
	
	if operation_queue.size() == 0:
		mutex.unlock()
		return
	
	current_operation = operation_queue.pop_front()
	processing_operation = true
	
	mutex.unlock()
	
	_log("Processing operation: " + current_operation.id, "PROCESS", current_operation.caller_info)
	emit_signal("operation_started", current_operation)
	
	# Execute operation
	var success = await _execute_operation(current_operation)
	
	# Record in history
	current_operation.status = "completed" if success else "failed"
	current_operation.completion_time = Time.get_unix_time_from_system()
	
	mutex.lock()
	operation_history.append(current_operation)
	if operation_history.size() > 1000:
		operation_history.pop_front()
	
	if not success:
		failed_operations.append(current_operation)
	
	processing_operation = false
	mutex.unlock()
	
	emit_signal("operation_completed", current_operation, success)

func _execute_operation(operation: Dictionary) -> bool:
	var success = true
	var error_msg = ""
	
	match operation.type:
		OperationType.CREATE_NODE:
			success = _op_create_node(operation.params)
		OperationType.DELETE_NODE:
			success = _op_delete_node(operation.params)
		OperationType.MOVE_NODE:
			success = _op_move_node(operation.params)
		OperationType.ROTATE_NODE:
			success = _op_rotate_node(operation.params)
		OperationType.SCALE_NODE:
			success = _op_scale_node(operation.params)
		OperationType.REPARENT_NODE:
			success = _op_reparent_node(operation.params)
		OperationType.LOAD_ASSET:
			success = _op_load_asset(operation.params)
		OperationType.UNLOAD_ASSET:
			success = _op_unload_asset(operation.params)
		OperationType.MODIFY_PROPERTY:
			success = await _op_modify_property(operation.params)
		OperationType.CALL_METHOD:
			success = await _op_call_method(operation.params)
		OperationType.EMIT_SIGNAL:
			success = await _op_emit_signal(operation.params)
		OperationType.CONNECT_SIGNAL:
			success = await _op_connect_signal(operation.params)
		OperationType.DISCONNECT_SIGNAL:
			success = await _op_disconnect_signal(operation.params)
		OperationType.CREATE_UNIVERSAL_BEING:
			success = await _op_create_universal_being(operation.params)
		OperationType.TRANSFORM_UNIVERSAL_BEING:
			success = await _op_transform_universal_being(operation.params)
		OperationType.CONNECT_UNIVERSAL_BEINGS:
			success = await _op_connect_universal_beings(operation.params)
		_:
			error_msg = "Unknown operation type"
			success = false
	
	if not success and error_msg != "":
		_log("Operation failed: " + error_msg, "ERROR", operation.caller_info)
	
	return success

# ----- NODE OPERATIONS -----
func _op_create_node(params: Dictionary) -> bool:
	if not params.has("class_name") or not params.has("parent_path"):
		_log("Create node missing required parameters", "ERROR")
		return false
	
	var parent = get_node_or_null(params.parent_path)
	if not parent:
		_log("Parent node not found: " + params.parent_path, "ERROR")
		return false
	
	# Create node instance
	var node_class = params.class_name
	var node = ClassDB.instantiate(node_class)
	if not node:
		_log("Failed to instantiate class: " + node_class, "ERROR")
		return false
	
	# Set properties if provided
	if params.has("properties"):
		for prop in params.properties:
			if node.has(prop):
				node.set(prop, params.properties[prop])
	
	# Set name if provided
	if params.has("name"):
		node.name = params.name
	
	# Register node
	var node_id = _register_node(node)
	
	# Add to parent (check if already has parent first)
	if node.get_parent() == null:
		floodgate_add_child(node, parent)
	else:
		_log("Warning: Node already has parent, skipping add_child: " + node.name, "WARNING")
		return false
	
	_log("Created node: " + node.get_path() + " (ID: " + node_id + ")", "CREATE")
	return true

## FLOODGATE ADD CHILD - Final authority using direct add_child
## This breaks the infinite recursion by NOT calling universal_add_child
func floodgate_add_child(child: Node, parent: Node) -> void:
	"""Final authority for adding children - uses direct add_child to prevent recursion"""
	if child.get_parent() == null:
		# Direct add_child - this is the final destination
		parent.add_child(child)
		_log("Floodgate added child: " + child.name + " to " + parent.name, "FLOODGATE")
		
		# Register the child node
		_register_node(child)
	else:
		_log("Warning: Child already has parent in floodgate_add_child: " + child.name, "WARNING")

## UNIVERSAL ADD CHILD - The function everyone calls
## This is the main Pentagon Architecture entry point for all node additions
func universal_add_child(child: Node, parent: Node = null) -> void:
	"""Universal entry point for adding children through Pentagon Architecture"""
	if not child:
		_log("Error: universal_add_child called with null child", "ERROR")
		return
	
	# Use current scene as default parent if none provided
	var target_parent = parent if parent else get_tree().current_scene
	if not target_parent:
		_log("Error: No valid parent for universal_add_child", "ERROR")
		return
	
	# Use the floodgate system to handle the actual addition
	floodgate_add_child(child, target_parent)
	_log("Universal add child: " + child.name + " to " + target_parent.name, "UNIVERSAL")

func _op_delete_node(params: Dictionary) -> bool:
	if not params.has("node_path"):
		_log("Delete node missing node_path parameter", "ERROR")
		return false
	
	var node = get_node_or_null(params.node_path)
	if not node:
		_log("Node not found for deletion: " + params.node_path, "ERROR")
		return false
	
	# Unregister node and its children
	_unregister_node_recursive(node)
	
	# Queue free the node
	node.queue_free()
	
	_log("Deleted node: " + params.node_path, "DELETE")
	return true

func _op_move_node(params: Dictionary) -> bool:
	if not params.has("node_path") or not params.has("position"):
		_log("Move node missing required parameters", "ERROR")
		return false
	
	var node = get_node_or_null(params.node_path)
	if not node:
		_log("Node not found for move: " + params.node_path, "ERROR")
		return false
	
	if not node.has_method("set_position") and not node.has_method("set_global_position"):
		_log("Node cannot be moved: " + params.node_path, "ERROR")
		return false
	
	# Lock node for operation
	_lock_node(node)
	
	# Apply movement
	if node is Node3D:
		if params.has("global") and params.global:
			node.global_position = params.position
		else:
			node.position = params.position
	elif node is Node2D:
		if params.has("global") and params.global:
			node.global_position = params.position
		else:
			node.position = params.position
	
	# Unlock node
	_unlock_node(node)
	
	_log("Moved node: " + params.node_path + " to " + str(params.position), "MOVE")
	return true

func _op_rotate_node(params: Dictionary) -> bool:
	if not params.has("node_path") or not params.has("rotation"):
		_log("Rotate node missing required parameters", "ERROR")
		return false
	
	var node = get_node_or_null(params.node_path)
	if not node:
		_log("Node not found for rotation: " + params.node_path, "ERROR")
		return false
	
	if not node is Node3D and not node is Node2D:
		_log("Node cannot be rotated: " + params.node_path, "ERROR")
		return false
	
	# Lock node for operation
	_lock_node(node)
	
	# Apply rotation
	if node is Node3D:
		if params.has("global") and params.global:
			node.global_rotation = params.rotation
		else:
			node.rotation = params.rotation
	elif node is Node2D:
		if params.has("global") and params.global:
			node.global_rotation = params.rotation
		else:
			node.rotation = params.rotation
	
	# Unlock node
	_unlock_node(node)
	
	_log("Rotated node: " + params.node_path + " to " + str(params.rotation), "ROTATE")
	return true

func _op_scale_node(params: Dictionary) -> bool:
	if not params.has("node_path") or not params.has("scale"):
		_log("Scale node missing required parameters", "ERROR")
		return false
	
	var node = get_node_or_null(params.node_path)
	if not node:
		_log("Node not found for scale: " + params.node_path, "ERROR")
		return false
	
	if not node is Node3D and not node is Node2D:
		_log("Node cannot be scaled: " + params.node_path, "ERROR")
		return false
	
	# Lock node for operation
	_lock_node(node)
	
	# Apply scale
	node.scale = params.scale
	
	# Unlock node
	_unlock_node(node)
	
	_log("Scaled node: " + params.node_path + " to " + str(params.scale), "SCALE")
	return true

func _op_reparent_node(params: Dictionary) -> bool:
	if not params.has("node_path") or not params.has("new_parent_path"):
		_log("Reparent node missing required parameters", "ERROR")
		return false
	
	var node = get_node_or_null(params.node_path)
	var new_parent = get_node_or_null(params.new_parent_path)
	
	if not node:
		_log("Node not found for reparent: " + params.node_path, "ERROR")
		return false
	
	if not new_parent:
		_log("New parent not found: " + params.new_parent_path, "ERROR")
		return false
	
	# Lock both nodes
	_lock_node(node)
	_lock_node(new_parent)
	
	# Store transform if needed
	var keep_transform = params.get("keep_global_transform", false)
	var global_transform = null
	if keep_transform and node is Node3D:
		global_transform = node.global_transform
	elif keep_transform and node is Node2D:
		global_transform = node.global_transform
	
	# Reparent (safe operation)
	var old_parent = node.get_parent()
	if old_parent:
		old_parent.remove_child(node)
	if node.get_parent() == null:
		floodgate_add_child(node, new_parent)
	else:
		_log("Warning: Node still has parent after removal, cannot reparent: " + node.name, "WARNING")
		return false
	
	# Restore transform if needed
	if keep_transform and global_transform:
		if node is Node3D:
			node.global_transform = global_transform
		elif node is Node2D:
			node.global_transform = global_transform
	
	# Unlock nodes
	_unlock_node(node)
	_unlock_node(new_parent)
	
	_log("Reparented node: " + params.node_path + " to " + params.new_parent_path, "REPARENT")
	return true

# ----- ASSET OPERATIONS -----
func _op_load_asset(params: Dictionary) -> bool:
	if not params.has("path") or not params.has("type"):
		_log("Load asset missing required parameters", "ERROR")
		return false
	
	var asset_path = params.path
	var asset_type = params.type
	
	# Check if already loaded
	if loaded_assets.has(asset_path):
		_log("Asset already loaded: " + asset_path, "INFO")
		return true
	
	# Check if approval required
	if asset_approval_required and not approved_assets.has(asset_path):
		_log("Asset requires approval: " + asset_path, "APPROVAL")
		pending_assets.append(asset_path)
		emit_signal("asset_approval_needed", asset_path)
		return false
	
	# Load the asset
	var resource = load(asset_path)
	if not resource:
		_log("Failed to load asset: " + asset_path, "ERROR")
		return false
	
	# Store loaded asset
	loaded_assets[asset_path] = {
		"resource": resource,
		"type": asset_type,
		"load_time": Time.get_unix_time_from_system(),
		"reference_count": 1
	}
	
	_log("Loaded asset: " + asset_path + " Type: " + str(asset_type), "ASSET")
	emit_signal("asset_loaded", asset_path, resource)
	return true

func _op_unload_asset(params: Dictionary) -> bool:
	if not params.has("path"):
		_log("Unload asset missing path parameter", "ERROR")
		return false
	
	var asset_path = params.path
	
	if not loaded_assets.has(asset_path):
		_log("Asset not loaded: " + asset_path, "WARNING")
		return true
	
	# Decrease reference count
	loaded_assets[asset_path].reference_count -= 1
	
	# Unload if no more references
	if loaded_assets[asset_path].reference_count <= 0:
		loaded_assets.erase(asset_path)
		_log("Unloaded asset: " + asset_path, "ASSET")
	else:
		_log("Decreased reference count for asset: " + asset_path + " to " + str(loaded_assets[asset_path].reference_count), "ASSET")
	
	return true

# ----- PROPERTY OPERATIONS -----
func _op_modify_property(params: Dictionary) -> bool:
	if not params.has("node_path") or not params.has("property") or not params.has("value"):
		_log("Modify property missing required parameters", "ERROR")
		return false
	
	var node = get_node_or_null(params.node_path)
	if not node:
		_log("Node not found for property modification: " + params.node_path, "ERROR")
		return false
	
	var property = params.property
	if not node.has(property):
		_log("Node does not have property: " + property, "ERROR")
		return false
	
	# Lock node
	_lock_node(node)
	
	# Store old value for logging
	var old_value = node.get(property)
	
	# Set new value
	node.set(property, params.value)
	
	# Unlock node
	_unlock_node(node)
	
	_log("Modified property: " + params.node_path + "." + property + " from " + str(old_value) + " to " + str(params.value), "PROPERTY")
	return true

# ----- METHOD OPERATIONS -----
func _op_call_method(params: Dictionary) -> bool:
	if not params.has("node_path") or not params.has("method"):
		_log("Call method missing required parameters", "ERROR")
		return false
	
	var node = get_node_or_null(params.node_path)
	if not node:
		_log("Node not found for method call: " + params.node_path, "ERROR")
		return false
	
	var method = params.method
	if not node.has_method(method):
		_log("Node does not have method: " + method, "ERROR")
		return false
	
	# Lock node
	_lock_node(node)
	
	# Call method with arguments if provided
	var result = null
	if params.has("args") and params.args is Array:
		result = node.callv(method, params.args)
	else:
		result = node.call(method)
	
	# Unlock node
	_unlock_node(node)
	
	_log("Called method: " + params.node_path + "." + method + "()", "METHOD")
	
	# Note: Results are logged but not returned to maintain bool return type
	if params.has("store_result") and params.store_result:
		_log("Method result: " + str(result), "METHOD")
	
	return true

# ----- SIGNAL OPERATIONS -----
func _op_emit_signal(params: Dictionary) -> bool:
	if not params.has("node_path") or not params.has("signal_name"):
		_log("Emit signal missing required parameters", "ERROR")
		return false
	
	var node = get_node_or_null(params.node_path)
	if not node:
		_log("Node not found for signal emission: " + params.node_path, "ERROR")
		return false
	
	var signal_name = params.signal_name
	if not node.has_signal(signal_name):
		_log("Node does not have signal: " + signal_name, "ERROR")
		return false
	
	# Emit signal with arguments if provided
	if params.has("args") and params.args is Array:
		node.emit_signal(signal_name, params.args)
	else:
		node.emit_signal(signal_name)
	
	_log("Emitted signal: " + params.node_path + "." + signal_name, "SIGNAL")
	return true

func _op_connect_signal(params: Dictionary) -> bool:
	if not params.has("source_path") or not params.has("signal_name") or not params.has("target_path") or not params.has("method"):
		_log("Connect signal missing required parameters", "ERROR")
		return false
	
	var source = get_node_or_null(params.source_path)
	var target = get_node_or_null(params.target_path)
	
	if not source:
		_log("Source node not found: " + params.source_path, "ERROR")
		return false
	
	if not target:
		_log("Target node not found: " + params.target_path, "ERROR")
		return false
	
	var signal_name = params.signal_name
	if not source.has_signal(signal_name):
		_log("Source node does not have signal: " + signal_name, "ERROR")
		return false
	
	var method = params.method
	if not target.has_method(method):
		_log("Target node does not have method: " + method, "ERROR")
		return false
	
	# Connect signal
	var flags = params.get("flags", 0)
	source.connect(signal_name, Callable(target, method).bind(), flags)
	
	_log("Connected signal: " + params.source_path + "." + signal_name + " to " + params.target_path + "." + method, "SIGNAL")
	return true

func _op_disconnect_signal(params: Dictionary) -> bool:
	if not params.has("source_path") or not params.has("signal_name") or not params.has("target_path") or not params.has("method"):
		_log("Disconnect signal missing required parameters", "ERROR")
		return false
	
	var source = get_node_or_null(params.source_path)
	var target = get_node_or_null(params.target_path)
	
	if not source:
		_log("Source node not found: " + params.source_path, "ERROR")
		return false
	
	if not target:
		_log("Target node not found: " + params.target_path, "ERROR")
		return false
	
	var signal_name = params.signal_name
	var method = params.method
	
	# Disconnect signal
	if source.is_connected(signal_name, Callable(target, method)):
		source.disconnect(signal_name, Callable(target, method))
		_log("Disconnected signal: " + params.source_path + "." + signal_name + " from " + params.target_path + "." + method, "SIGNAL")
	else:
		_log("Signal not connected: " + params.source_path + "." + signal_name + " to " + params.target_path + "." + method, "WARNING")
	
	return true

# ----- NODE REGISTRATION -----
func _register_node(node: Node) -> String:
	var node_id = _generate_node_id()
	registered_nodes[node_id] = {
		"node": node,
		"path": node.get_path(),
		"class": node.get_class(),
		"registered_time": Time.get_unix_time_from_system()
	}
	
	emit_signal("node_registered", node.get_path())
	return node_id

func _unregister_node_recursive(node: Node):
	# Unregister this node
	for node_id in registered_nodes:
		if registered_nodes[node_id].node == node:
			registered_nodes.erase(node_id)
			emit_signal("node_unregistered", node.get_path())
			break
	
	# Unregister children
	for child in node.get_children():
		_unregister_node_recursive(child)

# ----- THREAD SAFETY -----
func _lock_node(node: Node):
	var node_path = node.get_path()
	mutex.lock()
	
	while node_operation_locks.has(node_path):
		mutex.unlock()
		OS.delay_msec(1)
		mutex.lock()
	
	node_operation_locks[node_path] = true
	mutex.unlock()

func _unlock_node(node: Node):
	var node_path = node.get_path()
	mutex.lock()
	node_operation_locks.erase(node_path)
	mutex.unlock()

# ----- ASSET APPROVAL -----
func approve_asset(asset_path: String):
	if asset_path in pending_assets:
		pending_assets.erase(asset_path)
		approved_assets.append(asset_path)
		_log("Asset approved: " + asset_path, "APPROVAL")
		
		# Try to load the asset now
		queue_operation(OperationType.LOAD_ASSET, {
			"path": asset_path,
			"type": AssetType.SCENE  # Default type
		})

func reject_asset(asset_path: String):
	if asset_path in pending_assets:
		pending_assets.erase(asset_path)
		_log("Asset rejected: " + asset_path, "APPROVAL")

func set_asset_approval_required(required: bool):
	asset_approval_required = required
	_log("Asset approval required: " + str(required), "CONFIG")

# ----- LOGGING -----
func _log(message: String, category: String = "INFO", caller_info: Dictionary = {}):
	var timestamp = Time.get_datetime_string_from_system()
	var log_entry = "[" + timestamp + "] [" + category + "] "
	
	# Add caller info if available
	if caller_info.has("script") and caller_info.has("line"):
		log_entry += "[" + caller_info.script + ":" + str(caller_info.line) + "] "
	
	log_entry += message
	
	# Print to console
	print(log_entry)
	
	# Add to buffer
	if log_to_file:
		log_buffer.append(log_entry)

func _flush_log_buffer():
	if not log_file or log_buffer.is_empty():
		return
	
	for entry in log_buffer:
		log_file.store_line(entry)
	
	log_file.flush()
	log_buffer.clear()

func _get_caller_info() -> Dictionary:
	# Get stack trace to identify caller
	var stack = get_stack()
	if stack.size() > 3:  # Skip internal calls
		var frame = stack[3]
		return {
			"script": frame.source.get_file(),
			"line": frame.line,
			"function": frame.function
		}
	return {}

# ----- UTILITY FUNCTIONS -----
func _generate_operation_id() -> String:
	return "OP_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)

func _generate_node_id() -> String:
	return "NODE_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)

func _get_operation_name(type: OperationType) -> String:
	match type:
		OperationType.CREATE_NODE: return "CREATE_NODE"
		OperationType.DELETE_NODE: return "DELETE_NODE"
		OperationType.MOVE_NODE: return "MOVE_NODE"
		OperationType.ROTATE_NODE: return "ROTATE_NODE"
		OperationType.SCALE_NODE: return "SCALE_NODE"
		OperationType.REPARENT_NODE: return "REPARENT_NODE"
		OperationType.LOAD_ASSET: return "LOAD_ASSET"
		OperationType.UNLOAD_ASSET: return "UNLOAD_ASSET"
		OperationType.MODIFY_PROPERTY: return "MODIFY_PROPERTY"
		OperationType.CALL_METHOD: return "CALL_METHOD"
		OperationType.EMIT_SIGNAL: return "EMIT_SIGNAL"
		OperationType.CONNECT_SIGNAL: return "CONNECT_SIGNAL"
		OperationType.DISCONNECT_SIGNAL: return "DISCONNECT_SIGNAL"
		_: return "UNKNOWN"

# ----- EDEN-STYLE PROCESS SYSTEMS -----
func process_system_0():
	# Primary actions processor
	var try_turn_0 = mutex_actions.try_lock()
	if try_turn_0:
		mutex_actions.unlock()
	else:
		mutex_actions.unlock()
		return
	
	mutex_actions.lock()
	if actions_to_be_called.size() > 0:
		for i in range(min(max_actions_per_cycle, actions_to_be_called.size())):
			_log("Processing action: " + str(actions_to_be_called.size()) + " remaining", "SYSTEM0")
			var data_to_process = actions_to_be_called.pop_front()
			var type_of_action = data_to_process[0]
			var target_node = data_to_process[1]
			var additional_data = data_to_process[2] if data_to_process.size() > 2 else null
			
			match type_of_action:
				"update_position":
					if target_node is Node3D:
						target_node.position = additional_data
				"update_rotation":
					if target_node is Node3D:
						target_node.rotation = additional_data
				"update_scale":
					if target_node is Node3D:
						target_node.scale = additional_data
				"update_property":
					if additional_data is Dictionary:
						for prop in additional_data:
							if target_node.has(prop):
								target_node.set(prop, additional_data[prop])
				_:
					_log("Unknown action type: " + type_of_action, "ERROR")
	mutex_actions.unlock()

func process_system_1():
	# Node creation processor
	var try_turn_1 = mutex_nodes_to_be_added.try_lock()
	if try_turn_1:
		mutex_nodes_to_be_added.unlock()
	else:
		mutex_nodes_to_be_added.unlock()
		return
	
	mutex_nodes_to_be_added.lock()
	if nodes_to_be_added.size() > 0:
		for i in range(min(max_nodes_added_per_cycle, nodes_to_be_added.size())):
			var data_to_process = nodes_to_be_added.pop_front()
			var data_type = data_to_process[0]
			
			match data_type:
				0:  # Add to root
					var container_to_add = data_to_process[2]
					var container_name = data_to_process[1]
					
					# Check object limits before adding (with safety check)
					if container_to_add and is_instance_valid(container_to_add):
						if _should_enforce_object_limits(container_to_add):
							if not _check_and_enforce_object_limits(container_to_add):
								_log("Object limit reached, oldest object replaced", "LIMIT")
					else:
						# Object was freed, skip processing
						continue
					
					# Check if node is valid and doesn't already have a parent
					if container_to_add != null and container_to_add.get_parent() == null:
						floodgate_add_child(container_to_add, get_tree().current_scene)
						_track_new_object(container_to_add)
						# Use the node reference directly instead of searching for it
						_register_node(container_to_add)
						# Track in JSH-style tree
						if scene_tree_tracker:
							scene_tree_tracker.track_node(container_to_add, "object")
						_log("Added root node: " + container_name, "SYSTEM1")
					else:
						_log("Cannot add node - either null or already has parent", "ERROR")
				1:  # Add to parent
					var parent_path = data_to_process[1]
					var node_name = data_to_process[2]
					var main_node_to_add = data_to_process[3]
					var parent_node = get_node_or_null(parent_path)
					if parent_node:
						floodgate_add_child(main_node_to_add, parent_node)
						var combined_path = parent_path + "/" + node_name
						var just_added_node = get_node_or_null(combined_path)
						if just_added_node:
							_register_node(just_added_node)
							_log("Added child node: " + combined_path, "SYSTEM1")
						else:
							# Don't re-queue to avoid infinite loops
							_log("Failed to find added child: " + combined_path + " (not re-queueing)", "ERROR")
					else:
						# Parent not found, don't re-queue
						_log("Parent not found: " + parent_path + " (not re-queueing)", "ERROR")
	mutex_nodes_to_be_added.unlock()

func process_system_2():
	# Data transmission processor
	var try_turn_2 = mutex_data_to_send.try_lock()
	if try_turn_2:
		mutex_data_to_send.unlock()
	else:
		mutex_data_to_send.unlock()
		return
	
	mutex_data_to_send.lock()
	if data_to_be_send.size() > 0:
		for i in range(min(max_data_send_per_cycle, data_to_be_send.size())):
			var data_to_process = data_to_be_send.pop_front()
			var data_type = data_to_process[0]
			var target_path = data_to_process[1]
			var data_payload = data_to_process[2] if data_to_process.size() > 2 else null
			
			var target_node = get_node_or_null(target_path)
			if target_node:
				match data_type:
					"property_update":
						if data_payload is Dictionary:
							for prop in data_payload:
								if target_node.has(prop):
									target_node.set(prop, data_payload[prop])
					"method_call":
						if data_payload is Dictionary and data_payload.has("method"):
							var method = data_payload.method
							var args = data_payload.get("args", [])
							if target_node.has_method(method):
								target_node.callv(method, args)
				_log("Processed data for: " + target_path, "SYSTEM2")
			else:
				data_to_be_send.append(data_to_process)
				_log("Target node not found: " + target_path, "ERROR")
	mutex_data_to_send.unlock()

func process_system_3():
	# Movement processor
	var try_turn_3 = movmentes_mutex.try_lock()
	if try_turn_3:
		movmentes_mutex.unlock()
	else:
		movmentes_mutex.unlock()
		return
	
	movmentes_mutex.lock()
	if things_to_be_moved.size() > 0:
		for i in range(min(max_movements_per_cycle, things_to_be_moved.size())):
			var data_to_process = things_to_be_moved.pop_front()
			var operation_type = data_to_process[0]
			var target_node = data_to_process[1]
			var movement_data = data_to_process[2]
			
			if target_node and is_instance_valid(target_node):
				match operation_type:
					"move":
						if target_node is Node3D:
							target_node.position = movement_data
						elif target_node is Node2D:
							target_node.position = movement_data
					"rotate":
						if target_node is Node3D:
							target_node.rotation = movement_data
						elif target_node is Node2D:
							target_node.rotation = movement_data
					"scale":
						if target_node is Node3D or target_node is Node2D:
							target_node.scale = movement_data
				_log("Moved node: " + str(operation_type), "SYSTEM3")
	movmentes_mutex.unlock()

func process_system_4():
	# Node deletion processor
	var try_turn_4 = mutex_for_unloading_nodes.try_lock()
	if try_turn_4:
		mutex_for_unloading_nodes.unlock()
	else:
		mutex_for_unloading_nodes.unlock()
		return
	
	mutex_for_unloading_nodes.lock()
	if nodes_to_be_unloaded.size() > 0:
		for i in range(min(max_nodes_to_unload_per_cycle, nodes_to_be_unloaded.size())):
			var data_to_process = nodes_to_be_unloaded.pop_front()
			var _unload_type = data_to_process[0]
			var node_path = data_to_process[1]
			
			var target_node = get_node_or_null(node_path)
			if target_node:
				_unregister_node_recursive(target_node)
				target_node.queue_free()
				_log("Unloaded node: " + node_path, "SYSTEM4")
			else:
				_log("Node already gone: " + node_path, "SYSTEM4")
	mutex_for_unloading_nodes.unlock()

func process_system_5():
	# Function call processor
	var try_turn_5 = mutex_function_call.try_lock()
	if try_turn_5:
		mutex_function_call.unlock()
	else:
		mutex_function_call.unlock()
		return
	
	mutex_function_call.lock()
	if functions_to_be_called.size() > 0:
		for i in range(min(max_functions_called_per_cycle, functions_to_be_called.size())):
			var data_to_process = functions_to_be_called.pop_front()
			var function_type = data_to_process[0]
			var target_node = data_to_process[1]
			var function_name = data_to_process[2]
			var function_args = data_to_process[3] if data_to_process.size() > 3 else []
			
			match function_type:
				"call_on_node":
					if target_node and is_instance_valid(target_node):
						if target_node.has_method(function_name):
							target_node.callv(function_name, function_args)
							_log("Called method: " + function_name, "SYSTEM5")
				"call_on_path":
					var node = get_node_or_null(target_node)
					if node and node.has_method(function_name):
						node.callv(function_name, function_args)
						_log("Called method on path: " + str(target_node), "SYSTEM5")
	mutex_function_call.unlock()

func process_system_6():
	# Additional operations processor
	var try_turn_6 = mutex_additionals_call.try_lock()
	if try_turn_6:
		mutex_additionals_call.unlock()
	else:
		mutex_additionals_call.unlock()
		return
	
	mutex_additionals_call.lock()
	if additionals_to_be_called.size() > 0:
		for i in range(min(max_additionals_per_cycle, additionals_to_be_called.size())):
			var data_to_process = additionals_to_be_called.pop_front()
			var operation_type = data_to_process[0]
			var operation_data = data_to_process[1]
			var operation_count = data_to_process[2] if data_to_process.size() > 2 else 1
			
			if operation_count > 0:
				match operation_type:
					"load_scene":
						if ResourceLoader.exists(operation_data):
							var scene = load(operation_data)
							if scene:
								loaded_assets[operation_data] = scene
								_log("Loaded scene: " + operation_data, "SYSTEM6")
					"cleanup_memory":
						_cleanup_memory()
					_:
						_log("Unknown additional operation: " + operation_type, "ERROR")
	mutex_additionals_call.unlock()
	
	# Memory cleanup check
	var current_time = Time.get_ticks_msec()
	if current_time - memory_metadata["last_cleanup"] > memory_metadata["cleanup_thresholds"]["time_between_cleanups"]:
		_cleanup_memory()
		memory_metadata["last_cleanup"] = current_time

func process_system_7():
	# Message passing processor
	var try_turn_7 = mutex_messages_call.try_lock()
	if try_turn_7:
		mutex_messages_call.unlock()
	else:
		mutex_messages_call.unlock()
		return
	
	mutex_messages_call.lock()
	if messages_to_be_called.size() > 0:
		for i in range(min(max_messages_per_cycle, messages_to_be_called.size())):
			var data_to_process = messages_to_be_called.pop_front()
			var message_type = data_to_process[0]
			var message_content = data_to_process[1]
			var receiver = data_to_process[2]
			
			var receiver_node = get_node_or_null(receiver)
			if receiver_node:
				match message_type:
					"signal_emit":
						if message_content is Dictionary and message_content.has("signal"):
							var signal_name = message_content.signal
							var signal_args = message_content.get("args", [])
							if receiver_node.has_signal(signal_name):
								receiver_node.emit_signal(signal_name, signal_args)
					"property_set":
						if message_content is Dictionary:
							for prop in message_content:
								if receiver_node.has(prop):
									receiver_node.set(prop, message_content[prop])
				_log("Sent message to: " + receiver, "SYSTEM7")
			else:
				messages_to_be_called.append(data_to_process)
	mutex_messages_call.unlock()

func process_system_8():
	# Container state processor
	var try_turn_8 = mutex_for_container_state.try_lock()
	if try_turn_8:
		mutex_for_container_state.unlock()
	else:
		mutex_for_container_state.unlock()
		return
	
	# Container state operations would go here
	# Currently placeholder for Eden pattern compatibility

func process_system_9():
	# Texture management processor
	var try_turn_9 = texture_storage_mutex.try_lock()
	if try_turn_9:
		if texture_storage.size() > 0:
			for i in range(min(max_textures_applied_per_turn, texture_storage.size())):
				for key in texture_storage:
					var node_to_apply_texture = get_node_or_null(key)
					if node_to_apply_texture and node_to_apply_texture is MeshInstance3D:
						var texture_data = texture_storage[key]
						var material = MaterialLibrary.get_material("default")
						if texture_data.has("texture"):
							material.albedo_texture = texture_data.texture
						node_to_apply_texture.material_override = material
						texture_storage.erase(key)
						_log("Applied texture to: " + key, "SYSTEM9")
						break  # Only process one per cycle
		texture_storage_mutex.unlock()
	else:
		texture_storage_mutex.unlock()
		return

func process_system_10():
	# Physics state synchronization processor
	var try_physics_lock = physics_state_mutex.try_lock()
	if try_physics_lock:
		if physics_state_updates.size() > 0:
			for i in range(min(max_actions_per_cycle, physics_state_updates.size())):
				var update = physics_state_updates.pop_front()
				if physics_state_manager:
					match update.operation:
						"state_change":
							physics_state_manager.set_object_state(update.object, update.state)
							_log("Physics state changed for " + str(update.object.name) + " to " + str(update.state), "PHYSICS")
						"gravity_update":
							physics_state_manager.set_gravity_center(update.center, update.strength)
							_log("Gravity updated: center=" + str(update.center) + " strength=" + str(update.strength), "PHYSICS")
						"scene_zero_update":
							physics_state_manager.set_scene_zero_point(update.point)
							_log("Scene zero point updated: " + str(update.point), "PHYSICS")
		physics_state_mutex.unlock()
	else:
		physics_state_mutex.unlock()
		return

func process_system_11():
	# Ragdoll position tracking processor
	var try_ragdoll_lock = ragdoll_position_mutex.try_lock()
	if try_ragdoll_lock:
		if ragdoll_position_updates.size() > 0:
			for i in range(min(max_movements_per_cycle, ragdoll_position_updates.size())):
				var update = ragdoll_position_updates.pop_front()
				# Update ragdoll tracking in JSH framework
				if scene_tree_tracker:
					scene_tree_tracker.track_ragdoll_movement(update.ragdoll_id, update.position, update.state)
				_log("Ragdoll " + str(update.ragdoll_id) + " updated: pos=" + str(update.position) + " state=" + str(update.state), "RAGDOLL")
		ragdoll_position_mutex.unlock()
	else:
		ragdoll_position_mutex.unlock()
		return

# ----- DIMENSIONAL MAGIC FUNCTIONS (Eden Pattern) -----
func first_dimensional_magic(type_of_action: String, target_node: Node, additional_data = null):
	var action_array = []
	action_array.append(type_of_action)
	action_array.append(target_node)
	action_array.append(additional_data)
	mutex_actions.lock()
	actions_to_be_called.append(action_array)
	mutex_actions.unlock()
	_log("Queued first dimensional magic: " + type_of_action, "MAGIC1")

func second_dimensional_magic(data_type: int, node_path: String, node_to_add: Node, additional_data = null):
	var creation_array = []
	creation_array.append(data_type)
	creation_array.append(node_path)
	creation_array.append(node_to_add)
	if additional_data:
		creation_array.append(additional_data)
	mutex_nodes_to_be_added.lock()
	nodes_to_be_added.append(creation_array)
	mutex_nodes_to_be_added.unlock()
	_log("Queued second dimensional magic: node creation", "MAGIC2")

func third_dimensional_magic(data_type: String, target_path: String, data_payload):
	var data_array = []
	data_array.append(data_type)
	data_array.append(target_path)
	data_array.append(data_payload)
	mutex_data_to_send.lock()
	data_to_be_send.append(data_array)
	mutex_data_to_send.unlock()
	_log("Queued third dimensional magic: " + data_type, "MAGIC3")

func fourth_dimensional_magic(operation_type: String, target_node: Node, movement_data):
	var movement_array = []
	movement_array.append(operation_type)
	movement_array.append(target_node)
	movement_array.append(movement_data)
	movmentes_mutex.lock()
	things_to_be_moved.append(movement_array)
	movmentes_mutex.unlock()
	_log("Queued fourth dimensional magic: " + operation_type, "MAGIC4")

func fifth_dimensional_magic(unload_type: String, node_path: String):
	var unload_array = []
	unload_array.append(unload_type)
	unload_array.append(node_path)
	mutex_for_unloading_nodes.lock()
	nodes_to_be_unloaded.append(unload_array)
	mutex_for_unloading_nodes.unlock()
	_log("Queued fifth dimensional magic: " + unload_type, "MAGIC5")

func sixth_dimensional_magic(function_type: String, target_node, function_name: String, function_args = []):
	var function_array = []
	function_array.append(function_type)
	function_array.append(target_node)
	function_array.append(function_name)
	function_array.append(function_args)
	mutex_function_call.lock()
	functions_to_be_called.append(function_array)
	mutex_function_call.unlock()
	_log("Queued sixth dimensional magic: " + function_name, "MAGIC6")

func seventh_dimensional_magic(operation_type: String, operation_data: String, operation_count: int = 1):
	var additional_array = []
	additional_array.append(operation_type)
	additional_array.append(operation_data)
	additional_array.append(operation_count)
	mutex_additionals_call.lock()
	additionals_to_be_called.append(additional_array)
	mutex_additionals_call.unlock()
	_log("Queued seventh dimensional magic: " + operation_type, "MAGIC7")

func eighth_dimensional_magic(message_type: String, message_content, receiver: String):
	var message_array = []
	message_array.append(message_type)
	message_array.append(message_content)
	message_array.append(receiver)
	mutex_messages_call.lock()
	messages_to_be_called.append(message_array)
	mutex_messages_call.unlock()
	_log("Queued eighth dimensional magic: " + message_type, "MAGIC8")

func ninth_dimensional_magic(texture_path: String, texture_data: Dictionary):
	texture_storage_mutex.lock()
	texture_storage[texture_path] = texture_data
	texture_storage_mutex.unlock()
	_log("Queued ninth dimensional magic: texture storage", "MAGIC9")

func _cleanup_memory():
	# Clean up old delta memory
	if stored_delta_memory.size() > 9:
		stored_delta_memory = stored_delta_memory.slice(-9)
	
	# Clean up old operation history
	if operation_history.size() > 1000:
		operation_history = operation_history.slice(-500)
	
	# Clean up failed operations
	if failed_operations.size() > 100:
		failed_operations = failed_operations.slice(-50)
	
	_log("Memory cleanup completed", "SYSTEM")

# ----- PUBLIC API -----
func get_operation_status(operation_id: String) -> Dictionary:
	# Check current operation
	if current_operation and current_operation.id == operation_id:
		return current_operation
	
	# Check queue
	for op in operation_queue:
		if op.id == operation_id:
			return op
	
	# Check history
	for op in operation_history:
		if op.id == operation_id:
			return op
	
	return {}

func get_queue_size() -> int:
	return operation_queue.size()

func get_loaded_assets() -> Array:
	return loaded_assets.keys()

func get_pending_assets() -> Array:
	return pending_assets.duplicate()

func get_registered_nodes() -> Dictionary:
	var result = {}
	for node_id in registered_nodes:
		var node_info = registered_nodes[node_id]
		if is_instance_valid(node_info.node):
			result[node_id] = {
				"path": node_info.node.get_path(),
				"class": node_info.class,
				"registered_time": node_info.registered_time
			}
	return result

func clear_failed_operations():
	failed_operations.clear()
	_log("Cleared failed operations", "SYSTEM")

func get_failed_operations() -> Array:
	return failed_operations.duplicate()

# ----- OBJECT LIMIT MANAGEMENT FUNCTIONS -----

func _should_enforce_object_limits(node: Node) -> bool:
	# Only enforce limits on certain types of objects
	if node.is_in_group("spawned_objects") or node.is_in_group("astral_beings"):
		return true
	if node.has_meta("object_type"):
		return true
	return false

func _check_and_enforce_object_limits(node: Node) -> bool:
	# Check astral beings limit
	if node.is_in_group("astral_beings"):
		_cleanup_astral_beings()
		if astral_beings.size() >= MAX_ASTRAL_BEINGS:
			_remove_oldest_astral_being()
		return true
	
	# Check general object limit
	_cleanup_tracked_objects()
	if tracked_objects.size() >= MAX_OBJECTS_IN_SCENE:
		_remove_oldest_object()
		return false  # Indicates replacement occurred
	
	return true  # Indicates can add without replacement

func _track_new_object(node: Node) -> void:
	var current_time = Time.get_ticks_msec()
	
	if node.is_in_group("astral_beings"):
		astral_beings.append(node)
		_log("Tracking new astral being: " + node.name, "TRACK")
	else:
		var object_data = {
			"node": node,
			"creation_time": current_time,
			"type": node.get_meta("object_type", "unknown")
		}
		tracked_objects.append(object_data)
		object_creation_order.append(node)
		_log("Tracking new object: " + node.name + " (Total: " + str(tracked_objects.size()) + "/144)", "TRACK")

func _remove_oldest_object() -> void:
	if tracked_objects.is_empty():
		return
	
	# Find oldest object
	var oldest_index = 0
	var oldest_time = tracked_objects[0].creation_time
	
	for i in range(1, tracked_objects.size()):
		if tracked_objects[i].creation_time < oldest_time:
			oldest_time = tracked_objects[i].creation_time
			oldest_index = i
	
	var oldest_object = tracked_objects[oldest_index]
	var node_to_remove = oldest_object.node
	
	if node_to_remove and is_instance_valid(node_to_remove):
		# Let astral beings comment on the replacement
		_notify_beings_of_replacement(node_to_remove)
		
		_log("Removing oldest object: " + node_to_remove.name + " (Created: " + str(oldest_time) + ")", "LIMIT")
		node_to_remove.queue_free()
		
		# Remove from tracking
		tracked_objects.remove_at(oldest_index)
		object_creation_order.erase(node_to_remove)

func _remove_oldest_astral_being() -> void:
	if astral_beings.is_empty():
		return
	
	var oldest_being = astral_beings[0]
	if oldest_being and is_instance_valid(oldest_being):
		if oldest_being.has_method("speak"):
			oldest_being.speak("My time here ends, but new consciousness arrives!")
		
		_log("Removing oldest astral being: " + oldest_being.name, "LIMIT")
		oldest_being.queue_free()
		astral_beings.remove_at(0)

func _cleanup_tracked_objects() -> void:
	# Remove invalid objects from tracking
	for i in range(tracked_objects.size() - 1, -1, -1):
		var obj_data = tracked_objects[i]
		if not obj_data.node or not is_instance_valid(obj_data.node):
			tracked_objects.remove_at(i)
	
	# Clean object creation order
	object_creation_order = object_creation_order.filter(func(node): return node and is_instance_valid(node))

func _cleanup_astral_beings() -> void:
	# Remove invalid astral beings from tracking
	astral_beings = astral_beings.filter(func(being): return being and is_instance_valid(being))

func _notify_beings_of_replacement(removed_object: Node) -> void:
	# Let astral beings comment on object replacement
	for being in astral_beings:
		if being and is_instance_valid(being) and being.has_method("speak"):
			var messages = [
				"The old makes way for the new",
				"Transformation continues in our garden", 
				"Another cycle completes",
				"Evolution never stops"
			]
			being.speak(messages[randi() % messages.size()])
			break  # Only one being speaks

func get_object_statistics() -> Dictionary:
	_cleanup_tracked_objects()
	_cleanup_astral_beings()
	
	var type_counts = {}
	for obj_data in tracked_objects:
		var type = obj_data.type
		type_counts[type] = type_counts.get(type, 0) + 1
	
	return {
		"total_objects": tracked_objects.size(),
		"max_objects": MAX_OBJECTS_IN_SCENE,
		"astral_beings": astral_beings.size(),
		"max_astral_beings": MAX_ASTRAL_BEINGS,
		"objects_by_type": type_counts,
		"space_remaining": MAX_OBJECTS_IN_SCENE - tracked_objects.size()
	}

# ----- PHYSICS STATE SYNCHRONIZATION API -----
func queue_physics_state_change(object: Node3D, state: int) -> void:
	physics_state_mutex.lock()
	physics_state_updates.append({
		"operation": "state_change",
		"object": object,
		"state": state,
		"timestamp": Time.get_unix_time_from_system()
	})
	physics_state_mutex.unlock()
	_log("Queued physics state change for " + str(object.name), "PHYSICS")

func queue_gravity_update(center: Vector3, strength: float) -> void:
	physics_state_mutex.lock()
	physics_state_updates.append({
		"operation": "gravity_update",
		"center": center,
		"strength": strength,
		"timestamp": Time.get_unix_time_from_system()
	})
	physics_state_mutex.unlock()
	_log("Queued gravity update", "PHYSICS")

func queue_scene_zero_update(point: Vector3) -> void:
	physics_state_mutex.lock()
	physics_state_updates.append({
		"operation": "scene_zero_update",
		"point": point,
		"timestamp": Time.get_unix_time_from_system()
	})
	physics_state_mutex.unlock()
	_log("Queued scene zero point update", "PHYSICS")

func queue_ragdoll_position_update(ragdoll_id: String, position: Vector3, state: String) -> void:
	ragdoll_position_mutex.lock()
	ragdoll_position_updates.append({
		"ragdoll_id": ragdoll_id,
		"position": position,
		"state": state,
		"timestamp": Time.get_unix_time_from_system()
	})
	ragdoll_position_mutex.unlock()
	_log("Queued ragdoll position update for " + ragdoll_id, "RAGDOLL")

func get_physics_sync_status() -> Dictionary:
	return {
		"physics_updates_pending": physics_state_updates.size(),
		"ragdoll_updates_pending": ragdoll_position_updates.size(),
		"physics_manager_active": physics_state_manager != null,
		"scene_tracker_active": scene_tree_tracker != null
	}

# ----- UNIVERSAL BEING OPERATIONS -----
func _op_create_universal_being(params: Dictionary) -> bool:
	"""Create a Universal Being through the floodgate system"""
	if not params.has("type"):
		_log("Create Universal Being failed: missing type parameter", "ERROR")
		return false
		
	# Get asset library
	var asset_library = get_node_or_null("/root/AssetLibrary")
	if not asset_library:
		_log("Create Universal Being failed: AssetLibrary not found", "ERROR")
		return false
	
	# Check object limits
	if tracked_objects.size() >= MAX_OBJECTS_IN_SCENE:
		_log("Create Universal Being failed: object limit reached (" + str(MAX_OBJECTS_IN_SCENE) + ")", "WARNING")
		# Find oldest non-essential object to remove
		var removed = false
		for obj in tracked_objects:
			if obj.type != "essential" and obj.type != "universal_being":
				_unregister_node_recursive(obj.node)
				obj.node.queue_free()
				tracked_objects.erase(obj)
				removed = true
				break
		if not removed:
			return false
	
	# Create Universal Being
	var being_type = params.get("type", "generic")
	var position = params.get("position", Vector3.ZERO)
	var properties = params.get("properties", {})
	
	# Use asset library to create Universal Being
	if asset_library.has_method("create_universal_being"):
		var universal_being = asset_library.create_universal_being(being_type, properties)
		if universal_being:
			# Add to scene
			var parent = params.get("parent", get_tree().current_scene)
			floodgate_add_child(universal_being, parent)
			universal_being.global_position = position
			
			# Register with floodgate
			var _node_id = _register_node(universal_being)
			tracked_objects.append({
				"node": universal_being,
				"creation_time": Time.get_unix_time_from_system(),
				"type": "universal_being"
			})
			
			_log("Created Universal Being: " + being_type + " at " + str(position), "UBEING")
			return true
	else:
		_log("AssetLibrary missing create_universal_being method", "ERROR")
		
	return false

func _op_transform_universal_being(params: Dictionary) -> bool:
	"""Transform a Universal Being to a different form"""
	if not params.has_all(["node_path", "new_form"]):
		_log("Transform Universal Being failed: missing required parameters", "ERROR")
		return false
		
	var node = get_node_or_null(params.node_path)
	if not node:
		_log("Transform Universal Being failed: node not found at " + params.node_path, "ERROR")
		return false
		
	if not node.has_method("transform_to"):
		_log("Transform Universal Being failed: node is not a Universal Being", "ERROR")
		return false
		
	# Execute transformation
	var new_form = params.get("new_form")
	var transform_params = params.get("transform_params", {})
	
	node.transform_to(new_form, transform_params)
	_log("Transformed Universal Being to: " + new_form, "UBEING")
	
	return true

func _op_connect_universal_beings(params: Dictionary) -> bool:
	"""Connect two Universal Beings together"""
	if not params.has_all(["source_path", "target_path", "connection_type"]):
		_log("Connect Universal Beings failed: missing required parameters", "ERROR")
		return false
		
	var source = get_node_or_null(params.source_path)
	var target = get_node_or_null(params.target_path)
	
	if not source or not target:
		_log("Connect Universal Beings failed: one or both nodes not found", "ERROR")
		return false
		
	if not source.has_method("connect_to") or not target.has_method("accept_connection"):
		_log("Connect Universal Beings failed: nodes are not Universal Beings", "ERROR")
		return false
		
	# Create connection
	var connection_type = params.get("connection_type", "energy")
	var connection_data = params.get("connection_data", {})
	
	source.connect_to(target, connection_type, connection_data)
	_log("Connected Universal Beings: " + source.name + " -> " + target.name + " (" + connection_type + ")", "UBEING")
	
	return true

# ----- UNIVERSAL BEING QUEUE HELPERS -----
func queue_create_universal_being(being_type: String, position: Vector3 = Vector3.ZERO, properties: Dictionary = {}) -> String:
	"""Queue a Universal Being creation operation"""
	return queue_operation(OperationType.CREATE_UNIVERSAL_BEING, {
		"type": being_type,
		"position": position,
		"properties": properties
	})

func queue_transform_universal_being(node_path: String, new_form: String, transform_params: Dictionary = {}) -> String:
	"""Queue a Universal Being transformation"""
	return queue_operation(OperationType.TRANSFORM_UNIVERSAL_BEING, {
		"node_path": node_path,
		"new_form": new_form,
		"transform_params": transform_params
	})

func queue_connect_universal_beings(source_path: String, target_path: String, connection_type: String, connection_data: Dictionary = {}) -> String:
	"""Queue a connection between Universal Beings"""
	return queue_operation(OperationType.CONNECT_UNIVERSAL_BEINGS, {
		"source_path": source_path,
		"target_path": target_path,
		"connection_type": connection_type,
		"connection_data": connection_data
	})