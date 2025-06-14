# Debug Logger - Comprehensive Testing Log System
# JSH #memories
extends Node
class_name DebugLogger

signal log_written(entry: Dictionary)
signal report_generated(path: String)

# Log configuration
var log_file_path := "user://debug_logs/test_session_%s.txt" % Time.get_datetime_string_from_system().replace(":", "-")
var enable_console_output := true
var enable_file_logging := true
var log_performance_metrics := true

# Log categories
enum LogLevel {
	INFO,
	SUCCESS,
	WARNING,
	ERROR,
	PERFORMANCE,
	SEQUENCE
}

# Performance tracking
var performance_data = {
	"fps_samples": [],
	"memory_samples": [],
	"frame_times": [],
	"test_durations": {}
}

# Current session data
var session_start_time: float
var current_test: String = ""
var test_results = {}
var sequence_log = []

func _ready():
	session_start_time = Time.get_ticks_msec() / 1000.0
	create_log_file()
	log_entry(LogLevel.INFO, "Debug Logger initialized")
	log_entry(LogLevel.INFO, "Session started: %s" % Time.get_datetime_string_from_system())

func create_log_file():
	"""Create log file and directory"""
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("debug_logs"):
		dir.make_dir("debug_logs")
	
	# Write header
	var file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if file:
		file.store_string("""
=====================================
TUTORIAL DEBUG SCENE - TEST LOG
=====================================
Date: %s
Godot Version: %s
Project: Ethereal Engine
=====================================

""" % [Time.get_datetime_string_from_system(), Engine.get_version_info().string])
		file.close()

func log_entry(level: LogLevel, message: String, data: Dictionary = {}):
	"""Log an entry with timestamp and level"""
	var timestamp = "%.3f" % ((Time.get_ticks_msec() / 1000.0) - session_start_time)
	var level_str = LogLevel.keys()[level]
	
	var entry = {
		"timestamp": timestamp,
		"level": level_str,
		"message": message,
		"data": data,
		"current_test": current_test
	}
	
	# Format log line
	var log_line = "[%s] [%s] %s" % [timestamp, level_str, message]
	if not data.is_empty():
		log_line += " | Data: %s" % str(data)
	
	# Console output
	if enable_console_output:
		match level:
			LogLevel.ERROR:
				push_error(log_line)
			LogLevel.WARNING:
				push_warning(log_line)
			_:
				print(log_line)
	
	# File logging
	if enable_file_logging:
		write_to_file(log_line)
	
	# Track sequence
	sequence_log.append(entry)
	log_written.emit(entry)

func write_to_file(line: String):
	"""Append line to log file"""
	var file = FileAccess.open(log_file_path, FileAccess.WRITE_READ)
	if file:
		file.seek_end()
		file.store_line(line)
		file.close()

func start_test(test_name: String):
	"""Mark the start of a test"""
	current_test = test_name
	test_results[test_name] = {
		"start_time": Time.get_ticks_msec() / 1000.0,
		"end_time": 0,
		"duration": 0,
		"passed": false,
		"errors": [],
		"warnings": []
	}
	log_entry(LogLevel.SEQUENCE, "TEST START: %s" % test_name)

func end_test(test_name: String, passed: bool = true):
	"""Mark the end of a test"""
	if test_results.has(test_name):
		var result = test_results[test_name]
		result.end_time = Time.get_ticks_msec() / 1000.0
		result.duration = result.end_time - result.start_time
		result.passed = passed
		
		log_entry(
			LogLevel.SUCCESS if passed else LogLevel.ERROR,
			"TEST END: %s - %s (%.3fs)" % [
				test_name,
				"PASSED" if passed else "FAILED",
				result.duration
			]
		)
	current_test = ""

func log_performance():
	"""Log current performance metrics"""
	if not log_performance_metrics:
		return
	
	var fps = Engine.get_frames_per_second()
	var memory_mb = OS.get_static_memory_usage() / 1048576.0
	var frame_time = 1.0 / fps if fps > 0 else 0.0
	
	performance_data.fps_samples.append(fps)
	performance_data.memory_samples.append(memory_mb)
	performance_data.frame_times.append(frame_time)
	
	log_entry(LogLevel.PERFORMANCE, "Metrics", {
		"fps": fps,
		"memory_mb": "%.2f" % memory_mb,
		"frame_time_ms": "%.2f" % (frame_time * 1000)
	})

func log_action(action: String, params: Dictionary = {}):
	"""Log a game action"""
	log_entry(LogLevel.INFO, "ACTION: %s" % action, params)

func log_error(error_message: String, context: Dictionary = {}):
	"""Log an error"""
	log_entry(LogLevel.ERROR, error_message, context)
	
	if current_test != "" and test_results.has(current_test):
		test_results[current_test].errors.append({
			"message": error_message,
			"context": context
		})

func log_warning(warning_message: String, context: Dictionary = {}):
	"""Log a warning"""
	log_entry(LogLevel.WARNING, warning_message, context)
	
	if current_test != "" and test_results.has(current_test):
		test_results[current_test].warnings.append({
			"message": warning_message,
			"context": context
		})

func generate_report() -> String:
	"""Generate comprehensive test report"""
	var report = """
=====================================
TEST SESSION REPORT
=====================================
Total Duration: %.2f seconds
Total Tests: %d
Passed: %d
Failed: %d

PERFORMANCE SUMMARY:
- Average FPS: %.1f
- Min FPS: %.1f
- Max FPS: %.1f
- Average Memory: %.2f MB
- Peak Memory: %.2f MB

TEST RESULTS:
""" % [
		(Time.get_ticks_msec() / 1000.0) - session_start_time,
		test_results.size(),
		test_results.values().filter(func(r): return r.passed).size(),
		test_results.values().filter(func(r): return not r.passed).size(),
		calculate_average(performance_data.fps_samples),
		performance_data.fps_samples.min() if not performance_data.fps_samples.is_empty() else 0,
		performance_data.fps_samples.max() if not performance_data.fps_samples.is_empty() else 0,
		calculate_average(performance_data.memory_samples),
		performance_data.memory_samples.max() if not performance_data.memory_samples.is_empty() else 0
	]
	
	# Add test details
	for test_name in test_results:
		var result = test_results[test_name]
		report += "\n%s: %s (%.3fs)" % [
			test_name,
			"✅ PASSED" if result.passed else "❌ FAILED",
			result.duration
		]
		
		if not result.errors.is_empty():
			report += "\n  Errors:"
			for error in result.errors:
				report += "\n    - %s" % error.message
		
		if not result.warnings.is_empty():
			report += "\n  Warnings:"
			for warning in result.warnings:
				report += "\n    - %s" % warning.message
	
	# Add sequence summary
	report += "\n\nSEQUENCE LOG SUMMARY:\n"
	report += "Total Events: %d\n" % sequence_log.size()
	
	# Save report
	var report_path = log_file_path.replace(".txt", "_report.txt")
	var file = FileAccess.open(report_path, FileAccess.WRITE)
	if file:
		file.store_string(report)
		file.close()
		log_entry(LogLevel.SUCCESS, "Report saved to: %s" % report_path)
	
	report_generated.emit(report_path)
	return report

func calculate_average(samples: Array) -> float:
	"""Calculate average of numeric array"""
	if samples.is_empty():
		return 0.0
	
	var sum = 0.0
	for sample in samples:
		sum += sample
	return sum / samples.size()

func get_log_file_path() -> String:
	"""Get current log file path"""
	return log_file_path

func get_session_duration() -> float:
	"""Get current session duration"""
	return (Time.get_ticks_msec() / 1000.0) - session_start_time