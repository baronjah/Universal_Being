# ==================================================
# SCRIPT NAME: claude_timer_system.gd
# DESCRIPTION: Multi-project timer with user wait-time tracking
# CREATED: 2025-05-23 - Autonomous work during user delays
# ==================================================

extends UniversalBeingBase
# Project tracking
var active_projects: Dictionary = {
	"talking_ragdoll": {"name": "Talking Ragdoll Game", "time": 0.0, "status": "active"},
	"12_turns_system": {"name": "12 Turns System", "time": 0.0, "status": "background"},
	"eden_project": {"name": "Eden OS Project", "time": 0.0, "status": "archived"}
}

# Timer states
var current_project: String = "talking_ragdoll"
var session_start_time: float = 0.0
var last_user_message_time: float = 0.0
var user_response_timer: float = 0.0
var task_start_time: float = 0.0
var current_task: String = ""

# Autonomous work triggers
var wait_threshold_for_autonomous_work: float = 300.0  # 5 minutes
var is_autonomous_mode: bool = false
var autonomous_project_queue: Array = []

# Performance tracking
var tasks_completed_this_session: int = 0
var user_interactions: int = 0
var total_autonomous_time: float = 0.0

# Signals
signal user_wait_threshold_reached(wait_time: float)
signal autonomous_work_started(project: String)
# signal session_metrics_updated(metrics: Dictionary)  # UNUSED - for future metrics dashboard

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	session_start_time = Time.get_ticks_msec() / 1000.0
	last_user_message_time = session_start_time
	set_process(true)
	
	# Connect to autonomous work
	user_wait_threshold_reached.connect(_on_user_wait_threshold)

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Update active project time
	if current_project in active_projects:
		active_projects[current_project]["time"] += delta
	
	# Update user response timer
	user_response_timer = current_time - last_user_message_time
	
	# Check for autonomous work trigger
	if not is_autonomous_mode and user_response_timer > wait_threshold_for_autonomous_work:
		user_wait_threshold_reached.emit(user_response_timer)


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
func start_task(task_name: String, project: String = "") -> void:
	if project == "":
		project = current_project
	
	current_task = task_name
	task_start_time = Time.get_ticks_msec() / 1000.0
	
	print("⏱️ Task started: " + task_name + " (Project: " + project + ")")

func complete_task() -> float:
	if current_task == "":
		return 0.0
	
	var task_duration = (Time.get_ticks_msec() / 1000.0) - task_start_time
	tasks_completed_this_session += 1
	
	print("✅ Task completed: " + current_task + " (" + str(task_duration) + "s)")
	current_task = ""
	
	return task_duration

func user_message_received() -> void:
	last_user_message_time = Time.get_ticks_msec() / 1000.0
	user_response_timer = 0.0
	user_interactions += 1
	
	# Exit autonomous mode if active
	if is_autonomous_mode:
		_exit_autonomous_mode()

func switch_project(project_id: String) -> bool:
	if project_id in active_projects:
		current_project = project_id
		print("🔄 Switched to project: " + active_projects[project_id]["name"])
		return true
	return false

func get_session_metrics() -> Dictionary:
	var current_time = Time.get_ticks_msec() / 1000.0
	var session_duration = current_time - session_start_time
	
	return {
		"session_duration": session_duration,
		"current_project": active_projects[current_project]["name"],
		"user_wait_time": user_response_timer,
		"tasks_completed": tasks_completed_this_session,
		"user_interactions": user_interactions,
		"autonomous_time": total_autonomous_time,
		"current_task": current_task,
		"projects": active_projects
	}

func get_project_time(project_id: String) -> float:
	if project_id in active_projects:
		return active_projects[project_id]["time"]
	return 0.0

func add_autonomous_project(project_id: String, priority: int = 1) -> void:
	autonomous_project_queue.append({
		"project": project_id,
		"priority": priority,
		"added_time": Time.get_ticks_msec() / 1000.0
	})
	autonomous_project_queue.sort_custom(_sort_by_priority)

func _sort_by_priority(a, b) -> bool:
	return a["priority"] > b["priority"]

func _on_user_wait_threshold(_wait_time: float) -> void:
	if autonomous_project_queue.size() > 0:
		_start_autonomous_mode()

func _start_autonomous_mode() -> void:
	is_autonomous_mode = true
	var _autonomous_start_time = Time.get_ticks_msec() / 1000.0
	
	# Pick next autonomous project
	var next_project = autonomous_project_queue[0]["project"]
	autonomous_work_started.emit(next_project)
	
	print("🤖 AUTONOMOUS MODE: Starting work on " + active_projects[next_project]["name"])
	print("⏳ User has been away for " + str(int(user_response_timer)) + " seconds")
	
	# Simulate autonomous work (in real implementation, this would trigger actual tasks)
	_perform_autonomous_work(next_project)

func _perform_autonomous_work(project_id: String) -> void:
	# Example autonomous tasks based on project
	match project_id:
		"talking_ragdoll":
			print("🔍 Autonomous: Testing debug system, reading documentation")
			print("📝 Autonomous: Checking for code improvements")
		"12_turns_system":
			print("📚 Autonomous: Reviewing project documentation")
			print("🔄 Autonomous: Updating project status files")
		"eden_project":
			print("🗃️ Autonomous: Archiving old files, organizing resources")
	
	# In real implementation, these would be actual function calls

func _exit_autonomous_mode() -> void:
	if is_autonomous_mode:
		var autonomous_duration = user_response_timer
		total_autonomous_time += autonomous_duration
		is_autonomous_mode = false
		
		print("👋 User returned! Autonomous work completed (" + str(int(autonomous_duration)) + "s)")

# Console integration
func get_timer_report() -> String:
	var metrics = get_session_metrics()
	var report = "=== TIMER REPORT ===\n"
	report += "Session: " + str(int(metrics["session_duration"])) + "s\n"
	report += "Current: " + metrics["current_project"] + "\n"
	report += "User wait: " + str(int(metrics["user_wait_time"])) + "s\n"
	report += "Tasks done: " + str(metrics["tasks_completed"]) + "\n"
	report += "Autonomous: " + str(int(metrics["autonomous_time"])) + "s\n"
	
	if current_task != "":
		var task_duration = (Time.get_ticks_msec() / 1000.0) - task_start_time
		report += "Active task: " + current_task + " (" + str(int(task_duration)) + "s)\n"
	
	return report

func set_wait_threshold(seconds: float) -> void:
	wait_threshold_for_autonomous_work = seconds
	print("⏰ Autonomous work threshold set to " + str(seconds) + " seconds")
