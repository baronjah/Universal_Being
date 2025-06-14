# 🏛️ Godot Timers System - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# godot_timers_system.gd
# root/godot_timers_system
#
# res://code/gdscript/scripts/Menu_Keyboard_Console/godot_timers_system.gd
# JSH_Patch/Godot_connections/godot_tree_system
#
# Example usage:
#var timer_system = GodotTimersSystem.new()
#add_child(timer_system)
#
# Create and start a simple timer:
#timer_system.create_timer("my_timer", 5.0)
#timer_system.start_timer("my_timer")
#
# Create a repeating timer with callback:
#timer_system.create_timer("repeating_timer", 1.0, func(): print("Tick!"), true)
#timer_system.start_timer("repeating_timer")
#
# Create a timer with user data:
#timer_system.create_timer("data_timer", 3.0, func(data): print("Timer done with data: ", data), false, "custom_data")
#timer_system.start_timer("data_timer")

#
extends UniversalBeingBase
#
class_name GodotTimersSystem
#
#
# Storage for all timers
var _timers: Dictionary = {}
var _removed_timers: Array[String] = []
#
#
signal timer_completed(timer_id: String)
signal timer_started(timer_id: String, duration: float)
signal timer_stopped(timer_id: String)
signal timer_paused(timer_id: String)
signal timer_resumed(timer_id: String)
#
# Timer data structure
class TimerData:
	var timer: Timer
	var duration: float
	var time_left: float
	var is_paused: bool = false
	var is_repeating: bool = false
	var callback: Callable
	var user_data: Variant
	
	func _init(p_timer: Timer, p_duration: float, p_callback: Callable = Callable(), p_user_data: Variant = null):
		timer = p_timer
		duration = p_duration
		time_left = duration
		callback = p_callback
		user_data = p_user_data

# New signal for interval ticks
signal interval_tick(interval_name: String)

# Predefined intervals in seconds
const INTERVALS = {
	"quick": 0.1,    # Very fast updates (0.1 seconds)
	"short": 0.5,    # Short interval (0.5 seconds)
	"medium": 1.0,   # Standard interval (1 second)
	"long": 10.0     # Longer interval (10 seconds)
}

##
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	# Automatically set up all interval timers
	for interval_name in INTERVALS:
		create_timer(
			interval_name + "_interval", 
			INTERVALS[interval_name], 
			func(): emit_signal("interval_tick", interval_name), 
			true  # Repeating
		)
		start_timer(interval_name + "_interval")
##


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
func create_timer(timer_id: String, duration: float, callback: Callable = Callable(), repeating: bool = false, user_data: Variant = null) -> Error:
	if _timers.has(timer_id):
		push_warning("Timer with ID '%s' already exists!" % timer_id)
		return ERR_ALREADY_EXISTS
	
	var timer = TimerManager.get_timer()
	timer.one_shot = !repeating
	timer.wait_time = duration
	timer.timeout.connect(_on_timer_timeout.bind(timer_id))
	add_child(timer)
	
	_timers[timer_id] = TimerData.new(timer, duration, callback, user_data)
	_timers[timer_id].is_repeating = repeating
	
	return OK

func start_timer(timer_id: String) -> Error:
	if not _timers.has(timer_id):
		push_warning("Timer '%s' not found!" % timer_id)
		return ERR_DOES_NOT_EXIST
	
	var timer_data = _timers[timer_id]
	timer_data.timer.start()
	timer_data.is_paused = false
	emit_signal("timer_started", timer_id, timer_data.duration)
	return OK

func stop_timer(timer_id: String) -> Error:
	if not _timers.has(timer_id):
		return ERR_DOES_NOT_EXIST
	
	var timer_data = _timers[timer_id]
	timer_data.timer.stop()
	timer_data.time_left = timer_data.duration
	timer_data.is_paused = false
	emit_signal("timer_stopped", timer_id)
	return OK

func pause_timer(timer_id: String) -> Error:
	if not _timers.has(timer_id):
		return ERR_DOES_NOT_EXIST
	
	var timer_data = _timers[timer_id]
	if timer_data.is_paused:
		return OK
	
	timer_data.time_left = timer_data.timer.time_left
	timer_data.timer.paused = true
	timer_data.is_paused = true
	emit_signal("timer_paused", timer_id)
	return OK

func resume_timer(timer_id: String) -> Error:
	if not _timers.has(timer_id):
		return ERR_DOES_NOT_EXIST
	
	var timer_data = _timers[timer_id]
	if not timer_data.is_paused:
		return OK
	
	timer_data.timer.wait_time = timer_data.time_left
	timer_data.timer.paused = false
	timer_data.is_paused = false
	emit_signal("timer_resumed", timer_id)
	return OK

func remove_timer(timer_id: String) -> Error:
	if not _timers.has(timer_id):
		return ERR_DOES_NOT_EXIST
	
	var timer_data = _timers[timer_id]
	timer_data.timer.stop()
	timer_data.timer.queue_free()
	_timers.erase(timer_id)
	_removed_timers.append(timer_id)
	return OK

func clear_all_timers() -> void:
	for timer_id in _timers.keys():
		remove_timer(timer_id)

func get_time_left(timer_id: String) -> float:
	if not _timers.has(timer_id):
		return -1.0
	
	var timer_data = _timers[timer_id]
	return timer_data.timer.time_left if not timer_data.is_paused else timer_data.time_left

func get_progress(timer_id: String) -> float:
	if not _timers.has(timer_id):
		return -1.0
	
	var timer_data = _timers[timer_id]
	var time_left = get_time_left(timer_id)
	return 1.0 - (time_left / timer_data.duration)

func is_timer_active(timer_id: String) -> bool:
	return _timers.has(timer_id) and _timers[timer_id].timer.time_left > 0

func is_timer_paused(timer_id: String) -> bool:
	return _timers.has(timer_id) and _timers[timer_id].is_paused

func get_active_timers() -> Array[String]:
	var active_timers: Array[String] = []
	for timer_id in _timers:
		if is_timer_active(timer_id):
			active_timers.append(timer_id)
	return active_timers

func _on_timer_timeout(timer_id: String) -> void:
	# Check if timer was removed during its run
	if timer_id in _removed_timers:
		_removed_timers.erase(timer_id)
		return
	
	if not _timers.has(timer_id):
		return
	
	var timer_data = _timers[timer_id]
	
	# Execute callback if provided
	if timer_data.callback.is_valid():
		if timer_data.user_data != null:
			timer_data.callback.call(timer_data.user_data)
		else:
			timer_data.callback.call()
	
	emit_signal("timer_completed", timer_id)
	
	# Handle repeating timers
	if timer_data.is_repeating:
		timer_data.timer.start()
	else:
		remove_timer(timer_id)

func _exit_tree() -> void:
	clear_all_timers()
