# ==================================================
# SCRIPT NAME: universal_loader_unloader.gd
# DESCRIPTION: Universal system for loading/unloading nodes and resources
# PURPOSE: Keep the game stable by managing memory and performance
# CREATED: 2025-05-27 - The Universal Entity Core
# ==================================================

extends UniversalBeingBase
class_name UniversalLoaderUnloader

signal node_loaded(node: Node, load_time: float)
signal node_unloaded(path: String, freed_memory: int)
signal performance_warning(message: String)
signal memory_optimized(freed_bytes: int)

# Performance thresholds
const MAX_NODES_IN_SCENE = 22000
const MAX_MEMORY_MB = 4096
const TARGET_FPS = 60
const MIN_FPS_THRESHOLD = 30

# Loading queues
var load_queue: Array[Dictionary] = []
var unload_queue: Array[Node] = []
var resource_cache: Dictionary = {}

# Performance tracking
var performance_data = {
	"current_nodes": 0,
	"memory_usage": 0,
	"fps_history": [],
	"load_times": {},
	"heaviest_nodes": []
}

# Unload priorities
enum UnloadPriority {
	KEEP_ALWAYS = 0,      # Never unload (player, core systems)
	KEEP_IMPORTANT = 1,   # Only unload if critical
	NORMAL = 2,           # Standard game objects
	DISPOSABLE = 3        # Can unload anytime
}

var floodgate: FloodgateController
var console: Node

func _ready() -> void:
	name = "UniversalLoaderUnloader"
	
	# Get references
	floodgate = get_node_or_null("/root/FloodgateController")
	console = get_node_or_null("/root/ConsoleManager")
	
	# Start monitoring
	set_process(true)
	
	_print("[UniversalLoaderUnloader] System initialized - keeping your game stable!")

# ========== LOADING SYSTEM ==========


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

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func load_node(path: String, parent: Node = null, priority: int = 0) -> void:
	"""Queue a node for loading with smart memory management"""
	
	# Check if we can load
	if not _can_load_new_node():
		_optimize_memory()
		if not _can_load_new_node():
			_print("[LOADER] Cannot load %s - memory/node limit reached!" % path)
			return
	
	load_queue.append({
		"path": path,
		"parent": parent if parent else get_tree().current_scene,
		"priority": priority,
		"timestamp": Time.get_ticks_msec()
	})
	
	# Sort by priority
	load_queue.sort_custom(func(a, b): return a.priority > b.priority)

func load_node_immediate(path: String, parent: Node = null) -> Node:
	"""Load a node immediately with safety checks"""
	var start_time = Time.get_ticks_msec()
	
	# Check resource cache first
	var resource = resource_cache.get(path)
	if not resource:
		if ResourceLoader.exists(path):
			resource = load(path)
			resource_cache[path] = resource
		else:
			_print("[LOADER] Resource not found: %s" % path)
			return null
	
	# Instance the node
	var instance = resource.instantiate() if resource.has_method("instantiate") else null
	if not instance:
		_print("[LOADER] Failed to instantiate: %s" % path)
		return null
	
	# Add to parent
	var target_parent = parent if parent else get_tree().current_scene
	FloodgateController.universal_add_child(instance, target_parent)
	
	# Track performance
	var load_time = Time.get_ticks_msec() - start_time
	performance_data.load_times[path] = load_time
	
	# Register with floodgate
	if floodgate:
		floodgate.second_dimensional_magic(0, instance.name, instance)
	
	node_loaded.emit(instance, load_time)
	return instance

# ========== UNLOADING SYSTEM ==========

func unload_node(node: Node, priority: UnloadPriority = UnloadPriority.NORMAL) -> void:
	"""Queue a node for unloading based on priority"""
	if not is_instance_valid(node):
		return
	
	# Don't unload critical nodes
	if node.is_in_group("critical_systems") or priority == UnloadPriority.KEEP_ALWAYS:
		return
	
	node.set_meta("unload_priority", priority)
	unload_queue.append(node)

func unload_nodes_by_distance(center: Vector3, max_distance: float) -> int:
	"""Unload nodes beyond a certain distance from center"""
	var unloaded_count = 0
	
	for node in get_tree().get_nodes_in_group("spawned_objects"):
		if node is Node3D:
			var distance = node.global_position.distance_to(center)
			if distance > max_distance:
				unload_node(node, UnloadPriority.DISPOSABLE)
				unloaded_count += 1
	
	return unloaded_count

func unload_heavy_nodes(memory_threshold_mb: float = 50) -> void:
	"""Unload nodes using too much memory"""
	# This is simplified - in reality we'd need to measure actual memory
	var heavy_nodes = []
	
	for node in get_tree().get_nodes_in_group("spawned_objects"):
		if node.has_method("get_configuration_warnings"):
			# Estimate memory usage (simplified)
			var estimated_memory = _estimate_node_memory(node)
			if estimated_memory > memory_threshold_mb * 1024 * 1024:
				heavy_nodes.append(node)
	
	# Sort by memory usage and unload heaviest first
	heavy_nodes.sort_custom(func(a, b): return _estimate_node_memory(a) > _estimate_node_memory(b))
	
	for node in heavy_nodes:
		unload_node(node, UnloadPriority.DISPOSABLE)

# ========== FREEZER SYSTEM ==========

func freeze_node_scripts(node: Node) -> void:
	"""Disable scripts on a node to save performance"""
	if not is_instance_valid(node):
		return
	
	# NEVER freeze camera movement system - essential for gameplay
	if node.name == "CameraMovementSystem" or node.get_class() == "CameraMovementSystem":
		print("🔒 [UniversalLoaderUnloader] Protecting camera system from freeze")
		return
	
	# NEVER freeze cameras themselves
	if node is Camera3D:
		print("🔒 [UniversalLoaderUnloader] Protecting camera from freeze")
		return
	
	# NEVER freeze console system - essential for debugging
	if "Console" in node.name or "console" in node.name.to_lower():
		return
	
	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)
	node.set_process_unhandled_input(false)
	
	# Store original script for unfreezing
	if node.get_script():
		node.set_meta("frozen_script", node.get_script())
		node.set_script(null)
	
	# Freeze children too
	for child in node.get_children():
		freeze_node_scripts(child)

func unfreeze_node_scripts(node: Node) -> void:
	"""Re-enable scripts on a frozen node"""
	if not is_instance_valid(node):
		return
	
	# Restore script
	if node.has_meta("frozen_script"):
		node.set_script(node.get_meta("frozen_script"))
		node.remove_meta("frozen_script")
	
	node.set_process(true)
	node.set_physics_process(true)
	
	# Unfreeze children
	for child in node.get_children():
		unfreeze_node_scripts(child)

# ========== PERFORMANCE MONITORING ==========

func _process(_delta: float) -> void:
	# Update performance data
	performance_data.current_nodes = get_tree().get_node_count()
	performance_data.fps_history.append(Engine.get_frames_per_second())
	if performance_data.fps_history.size() > 60:
		performance_data.fps_history.pop_front()
	
	# Process queues
	_process_load_queue()
	_process_unload_queue()
	
	# Check performance
	if _get_average_fps() < MIN_FPS_THRESHOLD:
		_emergency_optimization()

func _process_load_queue() -> void:
	"""Process pending loads"""
	if load_queue.is_empty():
		return
	
	# Load one item per frame to avoid stuttering
	var item = load_queue.pop_front()
	load_node_immediate(item.path, item.parent)

func _process_unload_queue() -> void:
	"""Process pending unloads"""
	if unload_queue.is_empty():
		return
	
	# Unload up to 5 nodes per frame
	var unloaded = 0
	while not unload_queue.is_empty() and unloaded < 5:
		var node = unload_queue.pop_front()
		if is_instance_valid(node):
			_perform_unload(node)
		unloaded += 1

func _perform_unload(node: Node) -> void:
	"""Actually unload a node and free memory"""
	var node_path = node.get_path()
	
	# Notify floodgate
	if floodgate:
		floodgate.fifth_dimensional_magic("node_unload", str(node_path))
	
	# Free the node
	node.queue_free()
	
	node_unloaded.emit(str(node_path), 0)

# ========== OPTIMIZATION ==========

func _can_load_new_node() -> bool:
	"""Check if we can safely load a new node"""
	return (performance_data.current_nodes < MAX_NODES_IN_SCENE and 
			_get_average_fps() > MIN_FPS_THRESHOLD)

func _optimize_memory() -> void:
	"""Free up memory by unloading disposable nodes"""
	var freed = 0
	
	# Clear resource cache of unused resources
	for path in resource_cache:
		if not ResourceLoader.has_cached(path):
			resource_cache.erase(path)
			freed += 1
	
	# Unload disposable nodes
	for node in get_tree().get_nodes_in_group("spawned_objects"):
		if node.get_meta("unload_priority", UnloadPriority.NORMAL) >= UnloadPriority.DISPOSABLE:
			unload_node(node, UnloadPriority.DISPOSABLE)
			freed += 1
	
	memory_optimized.emit(freed)

func _emergency_optimization() -> void:
	"""Emergency optimization when FPS is too low"""
	_print("[LOADER] Emergency optimization triggered!")
	
	# Freeze distant objects
	var camera = get_viewport().get_camera_3d()
	if camera:
		for node in get_tree().get_nodes_in_group("spawned_objects"):
			if node is Node3D:
				var distance = node.global_position.distance_to(camera.global_position)
				if distance > 50:
					freeze_node_scripts(node)
	
	# Unload heavy nodes
	unload_heavy_nodes(25)
	
	performance_warning.emit("Low FPS detected - optimizing scene")

func _get_average_fps() -> float:
	"""Get average FPS from history"""
	if performance_data.fps_history.is_empty():
		return 60.0
	
	var sum = 0.0
	for fps in performance_data.fps_history:
		sum += fps
	return sum / performance_data.fps_history.size()

func _estimate_node_memory(node: Node) -> int:
	"""Rough estimate of node memory usage"""
	var estimate = 1024  # Base 1KB
	
	# Add for mesh instances
	if node is MeshInstance3D and node.mesh:
		estimate += 1024 * 100  # 100KB per mesh (rough)
	
	# Add for textures
	if node is Sprite3D and node.texture:
		estimate += 1024 * 50  # 50KB per texture (rough)
	
	# Add for children
	estimate += node.get_child_count() * 512
	
	return estimate

# ========== PUBLIC API ==========

func get_performance_report() -> Dictionary:
	"""Get current performance statistics"""
	return {
		"node_count": performance_data.current_nodes,
		"average_fps": _get_average_fps(),
		"memory_usage_mb": performance_data.memory_usage / 10204.0 / 10204.0,
		"load_queue_size": load_queue.size(),
		"unload_queue_size": unload_queue.size(),
		"cached_resources": resource_cache.size()
	}

func force_cleanup(aggressive: bool = false) -> void:
	"""Force memory cleanup"""
	_optimize_memory()
	
	if aggressive:
		# Clear all caches
		resource_cache.clear()
		
		# Unload all non-critical nodes
		for node in get_tree().get_nodes_in_group("spawned_objects"):
			if not node.is_in_group("critical_systems"):
				unload_node(node, UnloadPriority.DISPOSABLE)

func _print(message: String) -> void:
	if console and console.has_method("_print_to_console"):
		console._print_to_console(message)
	else:
		print(message)
