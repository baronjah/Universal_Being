# ==================================================
# SCRIPT NAME: multi_project_manager.gd
# DESCRIPTION: Manages multiple projects with timing awareness
# CREATED: 2025-05-23 - Project switching and time tracking
# ==================================================

extends UniversalBeingBase
# Project definitions
var projects: Dictionary = {
	"talking_ragdoll": {
		"name": "Talking Ragdoll Game",
		"path": "/mnt/c/Users/Percision 15/talking_ragdoll_game/",
		"status": "active",
		"priority": "high",
		"last_worked": 0.0,
		"total_time": 0.0,
		"todo_lists": ["features", "bugs", "optimizations"],
		"version": "0.1.0"
	},
	"data_sewers": {
		"name": "Data Sewers Project",
		"path": "/mnt/c/Users/Percision 15/data_sewers_22_05/",
		"status": "background",
		"priority": "medium",
		"last_worked": 0.0,
		"total_time": 0.0,
		"todo_lists": ["research", "cleanup", "documentation"],
		"version": "0.0.5"
	},
	"twelve_turns": {
		"name": "12 Turns System",
		"path": "/mnt/c/Users/Percision 15/12_turns_system/",
		"status": "planning",
		"priority": "medium",
		"last_worked": 0.0,
		"total_time": 0.0,
		"todo_lists": ["concept", "implementation", "testing"],
		"version": "0.0.1"
	}
}

# Current state
var current_project: String = "talking_ragdoll"
var user_response_timer: float = 0.0
var waiting_for_user: bool = false
var last_user_interaction: float = 0.0

# Time thresholds
const USER_RESPONSE_TIMEOUT: float = 300.0  # 5 minutes
const BACKGROUND_WORK_INTERVAL: float = 60.0  # 1 minute
const PROJECT_SWITCH_COOLDOWN: float = 30.0  # 30 seconds

# Task lists per project
var project_todos: Dictionary = {}
var current_task: Dictionary = {}

# Timing data
var session_start_time: float = 0.0
var time_waiting: float = 0.0
var time_working: float = 0.0

# Signals
signal project_switched(from_project: String, to_project: String)
signal user_timeout_reached(wait_time: float)
signal background_work_started(project: String)
signal task_completed_in_background(project: String, task: Dictionary)

func _ready() -> void:
	session_start_time = Time.get_ticks_msec() / 1000.0
	_load_project_data()
	_initialize_todo_lists()
	set_process(true)

func _process(delta: float) -> void:
	# Update timers
	if waiting_for_user:
		user_response_timer += delta
		time_waiting += delta
		
		# Check for timeout
		if user_response_timer >= USER_RESPONSE_TIMEOUT:
			_on_user_timeout()
	else:
		time_working += delta
		projects[current_project]["total_time"] += delta


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
func start_waiting_for_user() -> void:
	waiting_for_user = true
	user_response_timer = 0.0
	last_user_interaction = Time.get_ticks_msec() / 1000.0
	
	print("Started waiting for user response...")

func user_responded() -> void:
	if waiting_for_user:
		var wait_time = user_response_timer
		waiting_for_user = false
		user_response_timer = 0.0
		
		print("User responded after " + str(wait_time) + " seconds")
		
		# Update project work time
		projects[current_project]["last_worked"] = Time.get_ticks_msec() / 1000.0

func _on_user_timeout() -> void:
	print("User timeout reached (" + str(USER_RESPONSE_TIMEOUT) + "s), starting background work...")
	
	waiting_for_user = false
	emit_signal("user_timeout_reached", user_response_timer)
	
	# Switch to background work
	_start_background_work()

func _start_background_work() -> void:
	# Find best project to work on
	var background_project = _select_background_project()
	
	if background_project != current_project:
		switch_project(background_project)
	
	emit_signal("background_work_started", background_project)
	
	# Do background tasks
	_perform_background_tasks()

func _select_background_project() -> String:
	var candidates = []
	
	# Find projects that need attention
	for project_id in projects:
		var project = projects[project_id]
		if project["status"] in ["background", "planning"] and project["priority"] != "low":
			candidates.append(project_id)
	
	# Select based on priority and last worked time
	if candidates.is_empty():
		return current_project
	
	candidates.sort_custom(func(a, b):
		var proj_a = projects[a]
		var proj_b = projects[b]
		
		# Priority first
		if proj_a["priority"] != proj_b["priority"]:
			return _priority_value(proj_a["priority"]) > _priority_value(proj_b["priority"])
		
		# Then by least recently worked
		return proj_a["last_worked"] < proj_b["last_worked"]
	)
	
	return candidates[0]

func _priority_value(priority: String) -> int:
	match priority:
		"high": return 3
		"medium": return 2
		"low": return 1
		_: return 0

func _perform_background_tasks() -> void:
	var project_id = current_project
	var tasks = get_project_todos(project_id)
	
	# Find suitable background tasks
	var background_tasks = tasks.filter(func(task): 
		return task.get("type", "") in ["cleanup", "documentation", "research", "optimization"]
	)
	
	if not background_tasks.is_empty():
		var task = background_tasks[0]
		_execute_background_task(task)

func _execute_background_task(task: Dictionary) -> void:
	print("Executing background task: " + task.get("description", "Unknown"))
	
	# Simulate task execution
	match task.get("type", ""):
		"cleanup":
			_cleanup_project_files()
		"documentation":
			_update_documentation()
		"research":
			_research_feature(task.get("topic", ""))
		"optimization":
			_optimize_code(task.get("target", ""))
	
	# Mark task as completed
	task["status"] = "completed"
	task["completed_time"] = Time.get_ticks_msec() / 1000.0
	
	emit_signal("task_completed_in_background", current_project, task)

func switch_project(project_id: String) -> bool:
	if not projects.has(project_id):
		return false
	
	if project_id == current_project:
		return true
	
	var old_project = current_project
	current_project = project_id
	
	# Update timestamps
	projects[old_project]["last_worked"] = Time.get_ticks_msec() / 1000.0
	
	print("Switched from " + old_project + " to " + project_id)
	emit_signal("project_switched", old_project, project_id)
	
	return true

func get_project_todos(project_id: String) -> Array:
	if not project_todos.has(project_id):
		project_todos[project_id] = []
	
	return project_todos[project_id]

func add_task_to_project(project_id: String, task: Dictionary) -> void:
	if not projects.has(project_id):
		return
	
	var todos = get_project_todos(project_id)
	task["created_time"] = Time.get_ticks_msec() / 1000.0
	task["status"] = "pending"
	todos.append(task)

func get_current_project_status() -> Dictionary:
	var project = projects[current_project]
	var todos = get_project_todos(current_project)
	
	return {
		"name": project["name"],
		"version": project["version"],
		"status": project["status"],
		"priority": project["priority"],
		"total_time": project["total_time"],
		"pending_tasks": todos.filter(func(t): return t["status"] == "pending").size(),
		"completed_tasks": todos.filter(func(t): return t["status"] == "completed").size(),
		"waiting_for_user": waiting_for_user,
		"wait_time": user_response_timer if waiting_for_user else 0.0
	}

func get_all_projects_status() -> Dictionary:
	var status = {
		"current_project": current_project,
		"session_time": Time.get_ticks_msec() / 1000.0 - session_start_time,
		"time_waiting": time_waiting,
		"time_working": time_working,
		"projects": {}
	}
	
	for project_id in projects:
		var project = projects[project_id]
		var todos = get_project_todos(project_id)
		
		status["projects"][project_id] = {
			"name": project["name"],
			"status": project["status"],
			"priority": project["priority"],
			"total_time": project["total_time"],
			"pending_tasks": todos.filter(func(t): return t["status"] == "pending").size(),
			"completed_tasks": todos.filter(func(t): return t["status"] == "completed").size()
		}
	
	return status

func _initialize_todo_lists() -> void:
	# Initialize with some default tasks for each project
	
	# Talking Ragdoll tasks
	add_task_to_project("talking_ragdoll", {
		"description": "Implement physics state transitions",
		"type": "feature",
		"priority": "high"
	})
	
	add_task_to_project("talking_ragdoll", {
		"description": "Optimize astral being orbiting",
		"type": "optimization",
		"priority": "medium"
	})
	
	add_task_to_project("talking_ragdoll", {
		"description": "Add more dialogue variations",
		"type": "feature",
		"priority": "low"
	})
	
	# Data Sewers tasks
	add_task_to_project("data_sewers", {
		"description": "Document data flow architecture",
		"type": "documentation",
		"priority": "medium"
	})
	
	add_task_to_project("data_sewers", {
		"description": "Clean up legacy code",
		"type": "cleanup",
		"priority": "low"
	})
	
	# 12 Turns tasks
	add_task_to_project("twelve_turns", {
		"description": "Research turn-based mechanics",
		"type": "research",
		"priority": "high",
		"topic": "turn_based_systems"
	})

func _cleanup_project_files() -> void:
	print("Cleaning up project files for " + current_project)
	# Would actually clean files here

func _update_documentation() -> void:
	print("Updating documentation for " + current_project)
	# Would update docs here

func _research_feature(topic: String) -> void:
	print("Researching " + topic + " for " + current_project)
	# Would do research here

func _optimize_code(target: String) -> void:
	print("Optimizing " + target + " in " + current_project)
	# Would optimize code here

func _load_project_data() -> void:
	# Load saved project data
	var file_path = "user://multi_project_data.dat"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var data = file.get_var()
			if data.has("projects"):
				projects = data["projects"]
			if data.has("project_todos"):
				project_todos = data["project_todos"]
			file.close()

func save_project_data() -> void:
	# Save project data
	var data = {
		"projects": projects,
		"project_todos": project_todos,
		"session_stats": {
			"time_waiting": time_waiting,
			"time_working": time_working,
			"last_save": Time.get_ticks_msec() / 1000.0
		}
	}
	
	var file = FileAccess.open("user://multi_project_data.dat", FileAccess.WRITE)
	if file:
		file.store_var(data)
		file.close()

# Public API for console commands
func list_projects() -> String:
	var result = "=== PROJECTS ===\n"
	
	for project_id in projects:
		var project = projects[project_id]
		var marker = " ← CURRENT" if project_id == current_project else ""
		
		result += project_id + ": " + project["name"] + " (" + project["status"] + ")" + marker + "\n"
		result += "  Priority: " + project["priority"] + ", Time: " + str(int(project["total_time"])) + "s\n"
	
	return result

func get_timing_report() -> String:
	var total_session = Time.get_ticks_msec() / 1000.0 - session_start_time
	var waiting_percent = (time_waiting / total_session) * 100.0
	var working_percent = (time_working / total_session) * 100.0
	
	var report = "=== TIMING REPORT ===\n"
	report += "Session time: " + str(int(total_session)) + "s\n"
	report += "Waiting for user: " + str(int(time_waiting)) + "s (" + str(int(waiting_percent)) + "%)\n"
	report += "Working: " + str(int(time_working)) + "s (" + str(int(working_percent)) + "%)\n"
	
	if waiting_for_user:
		report += "Currently waiting: " + str(int(user_response_timer)) + "s\n"
	
	return report