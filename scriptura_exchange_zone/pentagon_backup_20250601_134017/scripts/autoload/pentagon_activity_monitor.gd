# PENTAGON ACTIVITY MONITOR - Live Script Tracking System
# Author: Claude & JSH
# Created: May 31, 2025, 13:30 CEST
# Purpose: Track which Pentagon functions are actively running across all 282 scripts
# Connection: Part of "One Ready, One Init, One Process, One Input" unified system

extends UniversalBeingBase
# class_name PentagonActivityMonitor  # Commented to avoid autoload conflict

## Tracks all Pentagon function calls across the entire codebase in real-time
## Creates run histories similar to Godot's console logs (last X game runs)
## Combines temporal header analysis with active script detection
## Provides unified view of which scripts are alive vs dormant

# ==================== CORE DATA STRUCTURES ====================

# Pentagon function tracking
var pentagon_calls: Dictionary = {
	"_init": {},      # script_path -> call_count
	"_ready": {},     # script_path -> call_count  
	"_process": {},   # script_path -> call_count
	"_input": {},     # script_path -> call_count
	"sewers": {}      # script_path -> call_count
}

# Active scripts monitoring
var active_scripts: Array[String] = []          # Currently running scripts
var dormant_scripts: Array[String] = []         # Scripts that exist but not running
var pentagon_compliant: Array[String] = []     # Scripts following Pentagon pattern
var pentagon_violators: Array[String] = []     # Scripts not following Pentagon

# Run history tracking (like Godot console logs)
var run_histories: Array[Dictionary] = []      # Last X game runs
var current_run: Dictionary = {}               # Current session data
var max_run_histories: int = 5                 # Keep last 5 runs like Godot

# Performance tracking
var performance_data: Dictionary = {
	"total_pentagon_calls": 0,
	"calls_per_second": 0.0,
	"heaviest_scripts": [],
	"lightest_scripts": []
}

# ==================== INITIALIZATION ====================

func _ready() -> void:
	_log_pentagon_call("_ready", get_script().resource_path)
	_initialize_monitoring_system()
	_start_current_run()
	print("Pentagon Activity Monitor initialized - tracking 282 scripts")

func _initialize_monitoring_system() -> void:
	# Set up monitoring infrastructure
	set_process(true)
	set_physics_process(false)  # We don't need physics for monitoring
	
	# Create run history directory if it doesn't exist
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("pentagon_runs"):
		dir.make_dir("pentagon_runs")
	
	# Load previous run histories
	_load_run_histories()

# ==================== PENTAGON FUNCTION TRACKING ====================

## Register a Pentagon function call from any script

# Simple autoload - no Pentagon inheritance needed for monitoring system

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
func log_pentagon_call(function_name: String, script_path: String, extra_data: Dictionary = {}) -> void:
	_log_pentagon_call(function_name, script_path, extra_data)

func _log_pentagon_call(function_name: String, script_path: String, extra_data: Dictionary = {}) -> void:
	# Increment call counter
	if function_name not in pentagon_calls:
		pentagon_calls[function_name] = {}
	
	if script_path not in pentagon_calls[function_name]:
		pentagon_calls[function_name][script_path] = 0
	
	pentagon_calls[function_name][script_path] += 1
	performance_data.total_pentagon_calls += 1
	
	# Mark script as active
	if script_path not in active_scripts:
		active_scripts.append(script_path)
		# Remove from dormant if it was there
		if script_path in dormant_scripts:
			dormant_scripts.erase(script_path)
	
	# Store in current run data
	var timestamp = Time.get_ticks_msec()
	if "pentagon_calls" not in current_run:
		current_run.pentagon_calls = []
	
	current_run.pentagon_calls.append({
		"function": function_name,
		"script": script_path,
		"timestamp": timestamp,
		"extra": extra_data
	})

# ==================== SCRIPT LIFECYCLE TRACKING ====================

## Track when a script becomes active
func mark_script_active(script_path: String) -> void:
	if script_path not in active_scripts:
		active_scripts.append(script_path)
	
	# Remove from dormant list
	if script_path in dormant_scripts:
		dormant_scripts.erase(script_path)

## Track when a script becomes dormant
func mark_script_dormant(script_path: String) -> void:
	if script_path not in dormant_scripts:
		dormant_scripts.append(script_path)
	
	# Remove from active list
	if script_path in active_scripts:
		active_scripts.erase(script_path)

## Analyze Pentagon compliance
func analyze_pentagon_compliance(script_path: String, has_functions: Dictionary) -> void:
	var required_functions = ["_init", "_ready", "_process", "_input", "sewers"]
	var compliance_score = 0
	
	for func_name in required_functions:
		if has_functions.get(func_name, false):
			compliance_score += 1
	
	# Consider script compliant if it has at least 3/5 Pentagon functions
	if compliance_score >= 3:
		if script_path not in pentagon_compliant:
			pentagon_compliant.append(script_path)
		# Remove from violators if it was there
		if script_path in pentagon_violators:
			pentagon_violators.erase(script_path)
	else:
		if script_path not in pentagon_violators:
			pentagon_violators.append(script_path)
		# Remove from compliant if it was there
		if script_path in pentagon_compliant:
			pentagon_compliant.erase(script_path)

# ==================== RUN HISTORY MANAGEMENT ====================

func _start_current_run() -> void:
	current_run = {
		"start_time": Time.get_datetime_dict_from_system(),
		"start_timestamp": Time.get_ticks_msec(),
		"pentagon_calls": [],
		"active_scripts": [],
		"performance": {},
		"session_id": _generate_session_id()
	}

func _end_current_run() -> void:
	current_run.end_time = Time.get_datetime_dict_from_system()
	current_run.end_timestamp = Time.get_ticks_msec()
	current_run.duration_ms = current_run.end_timestamp - current_run.start_timestamp
	current_run.final_active_scripts = active_scripts.duplicate()
	current_run.final_performance = performance_data.duplicate()
	
	# Add to run histories
	run_histories.append(current_run.duplicate())
	
	# Keep only last X runs
	while run_histories.size() > max_run_histories:
		run_histories.pop_front()
	
	# Save to disk
	_save_run_histories()

func _generate_session_id() -> String:
	var time = Time.get_datetime_dict_from_system()
	return "%04d%02d%02d_%02d%02d%02d" % [
		time.year, time.month, time.day,
		time.hour, time.minute, time.second
	]

# ==================== PERSISTENCE ====================

func _save_run_histories() -> void:
	var file = FileAccess.open("user://pentagon_runs/run_histories.json", FileAccess.WRITE)
	if file:
		var data = {
			"run_histories": run_histories,
			"saved_at": Time.get_datetime_dict_from_system()
		}
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func _load_run_histories() -> void:
	var file = FileAccess.open("user://pentagon_runs/run_histories.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.data
			if "run_histories" in data:
				var loaded_histories = data.run_histories
				run_histories.clear()
				for history in loaded_histories:
					if history is Dictionary:
						run_histories.append(history)

# ==================== REAL-TIME MONITORING ====================

var last_update_time: float = 0.0
var update_interval: float = 1.0  # Update stats every second

func _process(delta: float) -> void:
	_log_pentagon_call("_process", get_script().resource_path)
	
	last_update_time += delta
	if last_update_time >= update_interval:
		_update_performance_stats()
		last_update_time = 0.0

func _update_performance_stats() -> void:
	# Calculate calls per second
	var total_calls = performance_data.total_pentagon_calls
	var session_duration = (Time.get_ticks_msec() - current_run.start_timestamp) / 1000.0
	if session_duration > 0:
		performance_data.calls_per_second = total_calls / session_duration
	
	# Find heaviest scripts (most calls)
	var script_call_counts: Dictionary = {}
	for function_type in pentagon_calls:
		for script_path in pentagon_calls[function_type]:
			if script_path not in script_call_counts:
				script_call_counts[script_path] = 0
			script_call_counts[script_path] += pentagon_calls[function_type][script_path]
	
	# Sort scripts by call count
	var sorted_scripts = []
	for script_path in script_call_counts:
		sorted_scripts.append({
			"script": script_path,
			"calls": script_call_counts[script_path]
		})
	
	sorted_scripts.sort_custom(func(a, b): return a.calls > b.calls)
	
	performance_data.heaviest_scripts = sorted_scripts.slice(0, 10)  # Top 10
	performance_data.lightest_scripts = sorted_scripts.slice(-10)    # Bottom 10

# ==================== REPORTING & ANALYTICS ====================

## Get comprehensive activity report
func get_activity_report() -> Dictionary:
	return {
		"active_scripts": active_scripts.size(),
		"dormant_scripts": dormant_scripts.size(),
		"pentagon_compliant": pentagon_compliant.size(),
		"pentagon_violators": pentagon_violators.size(),
		"total_pentagon_calls": performance_data.total_pentagon_calls,
		"calls_per_second": performance_data.calls_per_second,
		"session_duration_ms": Time.get_ticks_msec() - current_run.start_timestamp,
		"heaviest_scripts": performance_data.heaviest_scripts,
		"run_histories_count": run_histories.size()
	}

## Get detailed script activity
func get_script_activity(script_path: String) -> Dictionary:
	var activity = {
		"script_path": script_path,
		"is_active": script_path in active_scripts,
		"is_dormant": script_path in dormant_scripts,
		"is_pentagon_compliant": script_path in pentagon_compliant,
		"pentagon_calls": {}
	}
	
	for function_type in pentagon_calls:
		if script_path in pentagon_calls[function_type]:
			activity.pentagon_calls[function_type] = pentagon_calls[function_type][script_path]
		else:
			activity.pentagon_calls[function_type] = 0
	
	return activity

## Get run history comparison
func get_run_comparison() -> Array:
	if run_histories.size() < 2:
		return []
	
	var comparisons = []
	for i in range(1, run_histories.size()):
		var prev_run = run_histories[i-1]
		var curr_run = run_histories[i]
		
		comparisons.append({
			"prev_session": prev_run.session_id,
			"curr_session": curr_run.session_id,
			"active_scripts_change": curr_run.final_active_scripts.size() - prev_run.final_active_scripts.size(),
			"performance_change": curr_run.final_performance.get("calls_per_second", 0) - prev_run.final_performance.get("calls_per_second", 0)
		})
	
	return comparisons

# ==================== CONSOLE INTEGRATION ====================

## Console command: pentagon_status
func console_pentagon_status() -> String:
	var report = get_activity_report()
	return """PENTAGON ACTIVITY STATUS:
	
Active Scripts: %d
Dormant Scripts: %d
Pentagon Compliant: %d
Pentagon Violators: %d

Performance:
  Total Pentagon Calls: %d
  Calls per Second: %.2f
  Session Duration: %.1fs

Top 3 Heaviest Scripts:
%s

Run Histories: %d stored
""" % [
		report.active_scripts,
		report.dormant_scripts, 
		report.pentagon_compliant,
		report.pentagon_violators,
		report.total_pentagon_calls,
		report.calls_per_second,
		report.session_duration_ms / 1000.0,
		_format_top_scripts(report.heaviest_scripts.slice(0, 3)),
		report.run_histories_count
	]

func _format_top_scripts(scripts: Array) -> String:
	var result = ""
	for i in range(scripts.size()):
		var script_data = scripts[i]
		var script_name = script_data.script.get_file()
		result += "  %d. %s (%d calls)\n" % [i+1, script_name, script_data.calls]
	return result

## Console command: pentagon_history  
func console_pentagon_history() -> String:
	if run_histories.is_empty():
		return "No run histories available yet."
	
	var result = "PENTAGON RUN HISTORY:\n\n"
	for i in range(run_histories.size()):
		var run = run_histories[i]
		result += "Run %d - %s\n" % [i+1, run.session_id]
		result += "  Duration: %.1fs\n" % [run.get("duration_ms", 0) / 1000.0]
		result += "  Active Scripts: %d\n" % [run.get("final_active_scripts", []).size()]
		result += "  Pentagon Calls: %d\n\n" % [run.get("pentagon_calls", []).size()]
	
	return result

# ==================== SHUTDOWN ====================

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_end_current_run()
		get_tree().quit()

# ==================== HELPER FUNCTIONS ====================

## Scan all scripts in project for Pentagon compliance (one-time analysis)
func scan_all_scripts() -> Dictionary:
	var script_files = []
	_find_script_files("res://", script_files)
	
	var compliance_report = {
		"total_scripts": script_files.size(),
		"scanned": 0,
		"compliant": 0,
		"violators": 0,
		"details": []
	}
	
	for script_path in script_files:
		var analysis = _analyze_script_file(script_path)
		compliance_report.details.append(analysis)
		
		if analysis.is_compliant:
			compliance_report.compliant += 1
		else:
			compliance_report.violators += 1
		
		compliance_report.scanned += 1
	
	return compliance_report

func _find_script_files(path: String, found_files: Array) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = path + "/" + file_name
			if dir.current_is_dir() and not file_name.begins_with("."):
				_find_script_files(full_path, found_files)
			elif file_name.ends_with(".gd"):
				found_files.append(full_path)
			file_name = dir.get_next()

func _analyze_script_file(script_path: String) -> Dictionary:
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return {"script": script_path, "error": "Could not read file"}
	
	var content = file.get_as_text()
	file.close()
	
	var has_functions = {
		"_init": "_init" in content,
		"_ready": "_ready" in content,
		"_process": "_process" in content,
		"_input": "_input" in content,
		"sewers": "sewers" in content
	}
	
	var function_count = 0
	for has_func in has_functions.values():
		if has_func:
			function_count += 1
	
	return {
		"script": script_path,
		"has_functions": has_functions,
		"function_count": function_count,
		"is_compliant": function_count >= 3,
		"compliance_score": function_count / 5.0
	}