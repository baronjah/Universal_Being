# Timer Manager - Pentagon Architecture Resource Pooling
# Author: JSH (Pentagon Migration Engine)
# Created: May 31, 2025, 23:46 CEST
# Purpose: Centralized timer resource management for Pentagon architecture
# Connection: Prevents TimerManager.get_timer() violations

extends UniversalBeingBase
# class_name TimerManager  # Commented to avoid autoload conflict

## Centralized timer resource management
## Prevents memory waste from creating new timers repeatedly

# Timer pool
var timer_pool: Array[Timer] = []
var active_timers: Dictionary = {}
var max_pool_size: int = 50

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_timer_pool()
	print("TimerManager: Initialized with Pentagon resource pooling")

func _create_timer_pool() -> void:
	# Pre-create a pool of timers
	for i in range(10):  # Start with 10 timers
		var timer = TimerManager.get_timer()
		timer_pool.append(timer)

## Get timer from pool (Pentagon compliant way)
static func get_timer() -> Timer:
	# Try to find TimerManager singleton
	var timer_manager = null
	if Engine.has_singleton("TimerManager"):
		timer_manager = Engine.get_singleton("TimerManager")
	else:
		# Fallback - create new timer (should not happen in Pentagon architecture)
		push_warning("TimerManager not found - creating new timer (Pentagon violation)")
		return Timer.new()
	
	return timer_manager._get_timer_instance()

func _get_timer_instance() -> Timer:
	var timer: Timer
	
	if timer_pool.size() > 0:
		# Get timer from pool
		timer = timer_pool.pop_back()
	else:
		# Pool empty, create new timer
		timer = TimerManager.get_timer()
		push_warning("Timer pool empty - creating new timer")
	
	# Track active timer
	var timer_id = _generate_timer_id()
	active_timers[timer_id] = timer
	timer.set_meta("timer_id", timer_id)
	
	return timer

func _generate_timer_id() -> String:
	var timestamp = Time.get_ticks_msec()
	var random = randi() % 1000
	return "TIMER_%d_%d" % [timestamp, random]

## Return timer to pool (for recycling)
static func return_timer(timer: Timer) -> void:
	# Try to find TimerManager singleton
	var timer_manager = null
	if Engine.has_singleton("TimerManager"):
		timer_manager = Engine.get_singleton("TimerManager")
	else:
		# No manager available, just free the timer
		if is_instance_valid(timer):
			timer.queue_free()
		return
	
	timer_manager._return_timer_instance(timer)

func _return_timer_instance(timer: Timer) -> void:
	if not is_instance_valid(timer):
		return
	
	# Clean up timer
	timer.stop()
	# Disconnect all timeout connections
	if timer.timeout.get_connections().size() > 0:
		for connection in timer.timeout.get_connections():
			timer.timeout.disconnect(connection.callable)
	
	# Remove from active timers
	var timer_id = timer.get_meta("timer_id", "")
	if timer_id in active_timers:
		active_timers.erase(timer_id)
	
	# Return to pool if not full
	if timer_pool.size() < max_pool_size:
		timer_pool.append(timer)
	else:
		# Pool full, free the timer
		timer.queue_free()

## Clean up expired timers

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
func cleanup_expired_timers() -> void:
	var expired_ids = []
	for timer_id in active_timers:
		var timer = active_timers[timer_id]
		if not is_instance_valid(timer):
			expired_ids.append(timer_id)
	
	for timer_id in expired_ids:
		active_timers.erase(timer_id)

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Periodic cleanup
	if randf() < 0.01:  # 1% chance per frame to cleanup
		cleanup_expired_timers()

## Get timer pool status
func get_pool_status() -> Dictionary:
	return {
		"pool_size": timer_pool.size(),
		"active_timers": active_timers.size(),
		"max_pool_size": max_pool_size
	}

## Console command integration
func console_timer_status() -> String:
	var status = get_pool_status()
	return """Timer Manager Status:
Pool Size: %d
Active Timers: %d
Max Pool Size: %d
Pentagon Compliant: ✅""" % [
		status.pool_size,
		status.active_timers,
		status.max_pool_size
	]