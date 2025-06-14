# ==================================================
# SCRIPT NAME: passive_mode_controller.gd
# DESCRIPTION: Console commands for controlling passive development
# CREATED: 2025-05-23 - User interface for autonomous system
# ==================================================

extends UniversalBeingBase
var autonomous_dev: Node
var workflow_mgr: Node

func _ready() -> void:
	# Create instances
	autonomous_dev = preload("res://scripts/passive_mode/autonomous_developer.gd").new()
	workflow_mgr = preload("res://scripts/passive_mode/workflow_manager.gd").new()
	
	add_child(autonomous_dev)
	add_child(workflow_mgr)
	
	# Connect signals
	autonomous_dev.task_completed.connect(_on_task_completed)
	autonomous_dev.daily_report_ready.connect(_on_daily_report)
	workflow_mgr.merge_requested.connect(_on_merge_requested)

# Console commands

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
func start_passive_mode() -> String:
	autonomous_dev.start_passive_mode()
	return "Passive mode started - I'll work autonomously for up to 12 hours"

func stop_passive_mode() -> String:
	autonomous_dev.stop_passive_mode()
	return "Passive mode stopped"

func get_status() -> String:
	var status = autonomous_dev.get_status()
	var workflow = workflow_mgr.get_workflow_status()
	
	var report = "=== PASSIVE MODE STATUS ===\n"
	report += "State: " + _state_to_string(status["state"]) + "\n"
	report += "Current Task: " + (status["current_task"].get("name", "None") if not status["current_task"].is_empty() else "None") + "\n"
	report += "Queue Size: " + str(status["queue_size"]) + "\n"
	report += "Tokens: " + str(status["tokens_used"]) + " / " + str(status["tokens_used"] + status["tokens_remaining"]) + "\n"
	report += "Hours Worked: " + str(status["hours_worked"]) + "\n"
	report += "Tasks Completed: " + str(status["completed_tasks"]) + "\n\n"
	
	report += "=== WORKFLOW STATUS ===\n"
	report += "Branch: " + workflow["current_branch"] + "\n"
	report += "Feature Branches: " + str(workflow["feature_branches"].size()) + "\n"
	report += "Pending Changes: " + str(workflow["pending_changes"]) + "\n"
	report += "Open MRs: " + str(workflow["open_merge_requests"]) + "\n"
	report += "Version: " + workflow["current_version"] + "\n"
	
	return report

func add_task(task_name: String, priority: String = "medium") -> String:
	var task = {
		"name": task_name,
		"priority": _parse_priority(priority),
		"type": _infer_task_type(task_name),
		"estimated_tokens": 8000
	}
	
	autonomous_dev.add_task(task)
	return "Task added: " + task_name

func create_branch(branch_name: String) -> String:
	return workflow_mgr.create_feature_branch(branch_name)

func switch_branch(branch_name: String) -> String:
	if workflow_mgr.switch_branch(branch_name):
		return "Switched to branch: " + branch_name
	return "Branch not found: " + branch_name

func commit(message: String) -> String:
	var commit_hash = workflow_mgr.commit_changes(message)
	return "Committed: " + commit_hash

func create_mr(title: String) -> String:
	var mr_id = workflow_mgr.create_merge_request(title)
	return "Merge request created: " + mr_id

func approve_mr(mr_id: String) -> String:
	if workflow_mgr.review_merge_request(mr_id, true, "Approved via console"):
		return "Merge request approved: " + mr_id
	return "Failed to approve: " + mr_id

func merge(mr_id: String) -> String:
	var result = workflow_mgr.merge_branch(mr_id)
	if result["success"]:
		return "Successfully merged: " + mr_id
	return "Merge failed: " + result.get("error", "Unknown error")

func show_diff() -> String:
	return workflow_mgr.get_change_diff()

func set_token_budget(budget: int) -> String:
	autonomous_dev.daily_token_budget = budget
	return "Token budget set to: " + str(budget)

func set_auto_commit(enabled: bool) -> String:
	autonomous_dev.auto_commit = enabled
	return "Auto-commit " + ("enabled" if enabled else "disabled")

func set_require_approval(enabled: bool) -> String:
	autonomous_dev.require_approval = enabled
	return "Approval requirement " + ("enabled" if enabled else "disabled")

# Helper functions
func _state_to_string(state: int) -> String:
	match state:
		0: return "IDLE"
		1: return "PLANNING"
		2: return "CODING"
		3: return "TESTING"
		4: return "DOCUMENTING"
		5: return "REVIEWING"
		6: return "COMMITTING"
		7: return "RESTING"
		_: return "UNKNOWN"

func _parse_priority(priority: String) -> int:
	match priority.to_lower():
		"critical": return 0
		"high": return 1
		"medium": return 2
		"low": return 3
		"passive": return 4
		_: return 2

func _infer_task_type(task_name: String) -> String:
	var lower_name = task_name.to_lower()
	
	if "fix" in lower_name or "bug" in lower_name:
		return "bugfix"
	elif "add" in lower_name or "create" in lower_name or "implement" in lower_name:
		return "feature"
	elif "optimize" in lower_name or "improve" in lower_name:
		return "optimization"
	elif "test" in lower_name:
		return "testing"
	elif "document" in lower_name or "comment" in lower_name:
		return "documentation"
	elif "clean" in lower_name or "refactor" in lower_name:
		return "cleanup"
	else:
		return "general"

# Signal handlers
func _on_task_completed(task: Dictionary) -> void:
	print("Task completed: " + task.get("name", "Unknown") + " - " + ("Success" if task.get("success", false) else "Failed"))

func _on_daily_report(report: String) -> void:
	print("\n" + report + "\n")
	
	# Save to file
	var file = FileAccess.open("user://daily_reports/" + Time.get_date_string_from_system() + ".txt", FileAccess.WRITE)
	if file:
		file.store_string(report)
		file.close()

func _on_merge_requested(mr_id: String) -> void:
	print("New merge request: " + mr_id + " - Review required")