# ==================================================
# SCRIPT NAME: simple_task_manager.gd
# DESCRIPTION: Simple task management for Universal Being consciousness
# PURPOSE: Handle basic goal planning when JSH Task Manager unavailable
# CREATED: 2025-05-30 - Neural consciousness evolution
# ==================================================

extends UniversalBeingBase
# Simple task management for conscious Universal Beings
var current_task: Dictionary = {}
var task_queue: Array[Dictionary] = []
var task_history: Array[Dictionary] = []

signal task_started(task_name: String)
signal task_completed(task_name: String, success: bool)
signal task_failed(task_name: String, reason: String)

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	set_process(true)
	print("🧠 [SimpleTaskManager] Ready for consciousness task management")


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
func create_task(task_name: String, priority: int = 1) -> Dictionary:
	"""Create a new task"""
	var task = {
		"name": task_name,
		"priority": priority,
		"status": "pending",
		"created_time": Time.get_ticks_msec(),
		"steps": [],
		"current_step": 0
	}
	
	return task

func add_task(task: Dictionary) -> void:
	"""Add task to queue"""
	task_queue.append(task)
	_sort_tasks_by_priority()
	print("📋 [SimpleTaskManager] Task added: ", task.name)

func add_task_step(task: Dictionary, step_action: String, duration: float = 1.0) -> void:
	"""Add a step to a task"""
	task.steps.append({
		"action": step_action,
		"duration": duration,
		"status": "pending"
	})

func start_next_task() -> bool:
	"""Start the next task in queue"""
	if task_queue.size() == 0:
		return false
	
	if current_task.size() > 0:  # Already working on something
		return false
	
	current_task = task_queue.pop_front()
	current_task.status = "active"
	current_task.started_time = Time.get_ticks_msec()
	
	task_started.emit(current_task.name)
	print("🎬 [SimpleTaskManager] Starting task: ", current_task.name)
	return true

func complete_current_task(success: bool = true) -> void:
	"""Complete the current task"""
	if current_task.size() == 0:
		return
	
	current_task.status = "completed" if success else "failed"
	current_task.completed_time = Time.get_ticks_msec()
	
	# Move to history
	task_history.append(current_task.duplicate())
	
	# Emit completion signal
	if success:
		task_completed.emit(current_task.name, true)
	else:
		task_failed.emit(current_task.name, "Task marked as failed")
	
	print("✅ [SimpleTaskManager] Task completed: ", current_task.name, " (success: ", success, ")")
	
	# Clear current task
	current_task.clear()
	
	# Keep history limited
	if task_history.size() > 20:
		task_history.pop_front()

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	"""Process current task steps"""
	if current_task.size() == 0:
		return
	
	# Simple step processing
	if current_task.steps.size() > 0:
		var current_step_index = current_task.current_step
		if current_step_index < current_task.steps.size():
			var step = current_task.steps[current_step_index]
			
			if step.status == "pending":
				step.status = "active"
				step.start_time = Time.get_ticks_msec()
				print("⚡ [SimpleTaskManager] Starting step: ", step.action)
			
			elif step.status == "active":
				# Check if step duration is complete
				var elapsed = (Time.get_ticks_msec() - step.start_time) / 1000.0
				if elapsed >= step.duration:
					step.status = "completed"
					current_task.current_step += 1
					print("✨ [SimpleTaskManager] Step completed: ", step.action)
					
					# Check if all steps completed
					if current_task.current_step >= current_task.steps.size():
						complete_current_task(true)

func _sort_tasks_by_priority() -> void:
	"""Sort tasks by priority (higher first)"""
	task_queue.sort_custom(func(a, b): return a.priority > b.priority)

func get_task_status() -> String:
	"""Get status of current task"""
	if current_task.size() == 0:
		return "idle"
	
	return current_task.name + " (" + current_task.status + ")"

func has_active_task() -> bool:
	"""Check if there's an active task"""
	return current_task.size() > 0

func get_queue_size() -> int:
	"""Get number of pending tasks"""
	return task_queue.size()

# Methods for consciousness integration
func plan_action(needs: Dictionary) -> String:
	"""Plan action based on needs (simple version)"""
	# Find most urgent need
	var most_urgent = ""
	var lowest_value = 1000.0
	
	for need_name in needs:
		if needs[need_name] < lowest_value:
			lowest_value = needs[need_name]
			most_urgent = need_name
	
	# Create appropriate task
	if lowest_value < 30.0:  # Urgent need
		match most_urgent:
			"hunger":
				return "seek_food"
			"growth_desire":
				return "grow_fruit"
			"balance":
				return "stabilize"
			"movement":
				return "walk_around"
			"energy":
				return "rest"
	
	return ""

func create_action_chain(goal: String) -> Array:
	"""Create sequence of actions for a goal"""
	match goal:
		"seek_food":
			return ["scan_environment", "locate_food", "move_to_food", "consume"]
		"grow_fruit":
			return ["gather_nutrients", "form_fruit", "mature_fruit"]
		"walk_around":
			return ["choose_direction", "start_walking", "maintain_balance"]
		"stabilize":
			return ["check_balance", "adjust_posture", "confirm_stable"]
		_:
			return [goal]  # Single action