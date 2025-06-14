# ==================================================
# SCRIPT NAME: multi_todo_manager.gd
# DESCRIPTION: Multiple todo lists for parallel project management
# CREATED: 2025-05-23 - Project-specific task tracking
# ==================================================

extends UniversalBeingBase
# Todo list structure per project
var project_todos: Dictionary = {
	"talking_ragdoll": {
		"name": "Talking Ragdoll Game",
		"todos": [],
		"completed_today": 0,
		"priority_focus": "high"
	},
	"12_turns_system": {
		"name": "12 Turns System",
		"todos": [],
		"completed_today": 0,
		"priority_focus": "medium"
	},
	"eden_project": {
		"name": "Eden OS Project", 
		"todos": [],
		"completed_today": 0,
		"priority_focus": "low"
	}
}

# Global task tracking
var all_tasks: Array = []
var completed_tasks_today: int = 0
var session_start_time: float = 0.0

# Task evolution tracking (as mentioned in your message)
var task_evolution_log: Array = []
var step_back_count: int = 0
var modification_count: int = 0

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	session_start_time = Time.get_ticks_msec() / 1000.0
	
	# Initialize with some example todos based on current work
	_initialize_default_todos()

func _initialize_default_todos() -> void:
	# Talking Ragdoll active todos
	add_todo("talking_ragdoll", "Test debug screen and state transitions", "high")
	add_todo("talking_ragdoll", "Import 3D assets from Downloads folder", "medium")
	add_todo("talking_ragdoll", "Verify timer system tracks user wait time", "medium")
	
	# 12 Turns System background todos
	add_todo("12_turns_system", "Update documentation files across strongholds", "medium") 
	add_todo("12_turns_system", "Synchronize data across Windows/WSL/Claude homes", "high")
	add_todo("12_turns_system", "Review and organize Unity assets for future use", "low")
	
	# Eden Project archived todos
	add_todo("eden_project", "Archive threading patterns for future reference", "low")
	add_todo("eden_project", "Document zone-based testing approach", "low")


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func add_todo(project_id: String, content: String, priority: String = "medium") -> bool:
	if not project_id in project_todos:
		return false
	
	var todo = {
		"id": generate_todo_id(),
		"content": content,
		"priority": priority,
		"status": "pending",
		"created_time": Time.get_ticks_msec() / 1000.0,
		"project": project_id,
		"evolution_steps": []
	}
	
	project_todos[project_id]["todos"].append(todo)
	all_tasks.append(todo)
	
	print("📝 Added todo to " + project_todos[project_id]["name"] + ": " + content)
	return true

func complete_todo(project_id: String, todo_id: String) -> bool:
	if not project_id in project_todos:
		return false
	
	var todos = project_todos[project_id]["todos"]
	for i in range(todos.size()):
		if todos[i]["id"] == todo_id:
			todos[i]["status"] = "completed"
			todos[i]["completed_time"] = Time.get_ticks_msec() / 1000.0
			project_todos[project_id]["completed_today"] += 1
			completed_tasks_today += 1
			
			print("✅ Completed todo: " + todos[i]["content"])
			return true
	
	return false

func modify_todo(project_id: String, todo_id: String, new_content: String, reason: String = "") -> bool:
	if not project_id in project_todos:
		return false
	
	var todos = project_todos[project_id]["todos"]
	for todo in todos:
		if todo["id"] == todo_id:
			var old_content = todo["content"]
			todo["content"] = new_content
			
			# Track evolution
			todo["evolution_steps"].append({
				"old_content": old_content,
				"new_content": new_content,
				"reason": reason,
				"timestamp": Time.get_ticks_msec() / 1000.0
			})
			
			modification_count += 1
			print("🔄 Modified todo: " + old_content + " → " + new_content)
			return true
	
	return false

func step_back_todo(project_id: String, todo_id: String) -> bool:
	if not project_id in project_todos:
		return false
	
	var todos = project_todos[project_id]["todos"]
	for todo in todos:
		if todo["id"] == todo_id and todo["evolution_steps"].size() > 0:
			var last_step = todo["evolution_steps"].pop_back()
			todo["content"] = last_step["old_content"]
			
			step_back_count += 1
			print("⏪ Stepped back todo: " + last_step["new_content"] + " → " + last_step["old_content"])
			return true
	
	return false

func get_project_todos(project_id: String) -> Array:
	if project_id in project_todos:
		return project_todos[project_id]["todos"]
	return []

func get_all_pending_todos() -> Array:
	var pending = []
	for project_id in project_todos:
		var todos = project_todos[project_id]["todos"]
		for todo in todos:
			if todo["status"] == "pending":
				pending.append(todo)
	return pending

func get_priority_todos(priority: String) -> Array:
	var priority_todos = []
	for project_id in project_todos:
		var todos = project_todos[project_id]["todos"]
		for todo in todos:
			if todo["priority"] == priority and todo["status"] == "pending":
				priority_todos.append(todo)
	return priority_todos

func get_session_summary() -> Dictionary:
	var summary = {
		"total_projects": project_todos.size(),
		"total_tasks": all_tasks.size(),
		"completed_today": completed_tasks_today,
		"modifications": modification_count,
		"step_backs": step_back_count,
		"session_duration": (Time.get_ticks_msec() / 1000.0) - session_start_time
	}
	
	# Per-project breakdown
	summary["projects"] = {}
	for project_id in project_todos:
		var project = project_todos[project_id]
		var pending_count = 0
		var completed_count = 0
		
		for todo in project["todos"]:
			if todo["status"] == "pending":
				pending_count += 1
			elif todo["status"] == "completed":
				completed_count += 1
		
		summary["projects"][project_id] = {
			"name": project["name"],
			"pending": pending_count,
			"completed": completed_count,
			"completed_today": project["completed_today"]
		}
	
	return summary

func generate_todo_id() -> String:
	return "todo_" + str(Time.get_ticks_msec())

# Console integration
func get_formatted_todos(project_id: String = "") -> String:
	var output = ""
	
	if project_id == "":
		# Show all projects
		output += "=== ALL PROJECT TODOS ===\n"
		for pid in project_todos:
			output += "\n[" + project_todos[pid]["name"] + "]\n"
			var todos = project_todos[pid]["todos"]
			for todo in todos:
				if todo["status"] == "pending":
					var priority_symbol = "🔴" if todo["priority"] == "high" else ("🟡" if todo["priority"] == "medium" else "🟢")
					output += priority_symbol + " " + todo["content"] + "\n"
	else:
		# Show specific project
		if project_id in project_todos:
			output += "=== " + project_todos[project_id]["name"].to_upper() + " TODOS ===\n"
			var todos = project_todos[project_id]["todos"]
			for todo in todos:
				var status_symbol = "✅" if todo["status"] == "completed" else "📝"
				var priority_symbol = "🔴" if todo["priority"] == "high" else ("🟡" if todo["priority"] == "medium" else "🟢")
				output += status_symbol + " " + priority_symbol + " " + todo["content"] + " (ID: " + todo["id"] + ")\n"
		else:
			output = "Project not found: " + project_id
	
	return output

func balance_workload() -> Dictionary:
	# Balance todos across projects based on priority and capacity
	var balance = {
		"recommendation": "",
		"focus_project": "",
		"defer_tasks": []
	}
	
	var high_priority_count = get_priority_todos("high").size()
	var medium_priority_count = get_priority_todos("medium").size()
	
	if high_priority_count > 3:
		balance["recommendation"] = "Focus on high priority tasks first"
		balance["focus_project"] = "talking_ragdoll"  # Usually current active project
	elif medium_priority_count > 5:
		balance["recommendation"] = "Break down medium tasks into smaller steps"
	else:
		balance["recommendation"] = "Good balance maintained"
	
	return balance