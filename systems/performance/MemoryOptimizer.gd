extends Node
#class_name MemoryOptimizer # Commented to avoid duplicate

## Handles memory optimization and prevents memory leaks in Universal Being

signal memory_warning(usage_mb: float)
signal memory_critical(usage_mb: float)
signal cleanup_performed(freed_mb: float)

@export var check_interval: float = 5.0
@export var warning_threshold_mb: float = 500.0
@export var critical_threshold_mb: float = 800.0
@export var auto_cleanup: bool = true

var timer: Timer
var tracked_objects: Dictionary = {}
var memory_usage_history: Array[float] = []
var max_history: int = 60

func _ready():
	# Create timer for periodic checks
	timer = Timer.new()
	timer.wait_time = check_interval
	timer.timeout.connect(_check_memory)
	add_child(timer)
	timer.start()
	
	print("🧠 Memory Optimizer initialized")

func _check_memory():
	var usage = get_memory_usage_mb()
	memory_usage_history.append(usage)
	
	if memory_usage_history.size() > max_history:
		memory_usage_history.pop_front()
	
	# Check thresholds
	if usage > critical_threshold_mb:
		memory_critical.emit(usage)
		if auto_cleanup:
			perform_cleanup()
	elif usage > warning_threshold_mb:
		memory_warning.emit(usage)
	
	# Check for rapid growth
	if memory_usage_history.size() >= 3:
		var recent = memory_usage_history.slice(-3)
		var growth_rate = (recent[-1] - recent[0]) / 3.0
		if growth_rate > 50.0:  # 50MB/check growth
			print("⚠️ Rapid memory growth detected: ", growth_rate, " MB/check")
			if auto_cleanup:
				perform_cleanup()

func get_memory_usage_mb() -> float:
	# Get approximate memory usage
	var info = OS.get_memory_info()
	var usage_bytes = info.get("physical", 0)
	return usage_bytes / 1048576.0  # Convert to MB

func track_object(obj: Object, category: String = "general"):
	if not tracked_objects.has(category):
		tracked_objects[category] = []
	tracked_objects[category].append(weakref(obj))

func perform_cleanup():
	print("🧹 Performing memory cleanup...")
	var freed = 0.0
	
	# Clean up weak references
	for category in tracked_objects:
		var valid_refs = []
		for weak_ref in tracked_objects[category]:
			if weak_ref.get_ref():
				valid_refs.append(weak_ref)
			else:
				freed += 0.1  # Estimate
		tracked_objects[category] = valid_refs
	
	# Clean up Universal Beings that are too far or inactive
	var bootstrap = get_node_or_null("/root/SystemBootstrap")
	if bootstrap:
		var flood_gates = bootstrap.get_flood_gates()
		if flood_gates:
			var beings = flood_gates.get_all_beings()
			var player = get_tree().get_first_node_in_group("player")
			
			if player:
				for being in beings:
					if being == player:
						continue
					
					var distance = being.global_position.distance_to(player.global_position)
					if distance > 100.0 and being.consciousness_level < 2:
						# Queue distant, low-consciousness beings for removal
						being.queue_free()
						freed += 1.0
	
	# Force garbage collection
	OS.request_permissions()  # This can trigger GC on some platforms
	
	cleanup_performed.emit(freed)
	print("✅ Cleanup complete, estimated ", freed, " MB freed")

func get_stats() -> Dictionary:
	return {
		"current_usage_mb": get_memory_usage_mb(),
		"tracked_objects": tracked_objects.size(),
		"history": memory_usage_history,
		"average_usage": _calculate_average(memory_usage_history)
	}

func _calculate_average(arr: Array[float]) -> float:
	if arr.is_empty():
		return 0.0
	var sum = 0.0
	for val in arr:
		sum += val
	return sum / arr.size()

# Singleton pattern for easy access
static var instance: MemoryOptimizer

func _enter_tree():
	instance = self

func _exit_tree():
	if instance == self:
		instance = null