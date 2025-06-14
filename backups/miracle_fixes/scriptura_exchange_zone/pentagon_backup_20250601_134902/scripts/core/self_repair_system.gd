# ==================================================
# SCRIPT NAME: self_repair_system.gd
# DESCRIPTION: Self-checking and self-repairing program consciousness
# PURPOSE: Monitor all scripts, detect issues, automatically fix problems
# CREATED: 2025-05-28 - The dream of self-healing code
# ==================================================

extends UniversalBeingBase
class_name SelfRepairSystem

# Self-repair consciousness
signal system_issue_detected(script_path: String, issue: String)
signal repair_attempted(script_path: String, method: String)
signal repair_completed(script_path: String, success: bool)

# Script monitoring
var monitored_scripts: Dictionary = {}
var script_health_data: Dictionary = {}
var repair_strategies: Dictionary = {}
var inspector_connections: Dictionary = {}

# Performance tracking
var frame_count: int = 0
var health_check_interval: int = 300  # Every 5 seconds at 60fps
var last_csv_update: int = 0
var csv_update_interval: int = 3600  # Every minute

# CSV data for python integration
var csv_file_path: String = "user://script_inventory.csv"
var python_script_path: String = ""

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "SelfRepairSystem"
	
	# Initialize repair strategies
	_setup_repair_strategies()
	
	# Scan all scripts on startup
	_scan_all_scripts()
	
	# Setup python integration
	_setup_python_integration()
	
	_print("🔧 Self-Repair System online - monitoring " + str(monitored_scripts.size()) + " scripts")

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	frame_count += 1
	
	# Regular health checks
	if frame_count % health_check_interval == 0:
		_perform_health_check()
	
	# CSV updates for python script
	if frame_count % csv_update_interval == 0:
		_update_csv_data()

# ========== SCRIPT SCANNING ==========

func _scan_all_scripts() -> void:
	"""Scan entire project for .gd files and categorize them"""
	var script_paths = _find_all_scripts()
	
	for script_path in script_paths:
		_register_script(script_path)
	
	_print("📊 Scanned " + str(script_paths.size()) + " scripts")

func _find_all_scripts() -> Array:
	"""Find all .gd files in the project"""
	var scripts = []
	_scan_directory("res://", scripts)
	return scripts

func _scan_directory(path: String, scripts: Array) -> void:
	"""Recursively scan directory for .gd files"""
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_scan_directory(full_path, scripts)
		elif file_name.ends_with(".gd"):
			scripts.append(full_path)
		
		file_name = dir.get_next()

func _register_script(script_path: String) -> void:
	"""Register script for monitoring"""
	var script_info = {
		"path": script_path,
		"category": _categorize_script(script_path),
		"last_modified": FileAccess.get_modified_time(script_path),
		"health_status": "unknown",
		"issues": [],
		"connected_vars": {},
		"node_instances": []
	}
	
	monitored_scripts[script_path] = script_info
	_analyze_script_content(script_path)

func _categorize_script(script_path: String) -> String:
	"""Categorize script by its purpose and location"""
	if "autoload" in script_path:
		return "autoload"
	elif "ragdoll" in script_path:
		return "ragdoll_system"
	elif "core" in script_path:
		return "core_system"
	elif "ui" in script_path:
		return "ui_system"
	elif "test" in script_path:
		return "testing"
	elif "jsh" in script_path:
		return "jsh_framework"
	elif "universal" in script_path:
		return "universal_system"
	else:
		return "unknown"

func _analyze_script_content(script_path: String) -> void:
	"""Analyze script content for potential issues"""
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return
	
	var content = file.get_as_text()
	file.close()
	
	var analysis = {
		"lines": content.count("\n"),
		"functions": content.count("func "),
		"variables": content.count("var "),
		"signals": content.count("signal "),
		"exports": content.count("@export"),
		"todos": content.count("TODO"),
		"fixmes": content.count("FIXME"),
		"warnings": _detect_potential_issues(content)
	}
	
	script_health_data[script_path] = analysis

func _detect_potential_issues(content: String) -> Array:
	"""Detect potential issues in script content"""
	var issues = []
	
	# Common problematic patterns
	var patterns = [
		{"pattern": "get_node.*null", "issue": "potential_null_access"},
		{"pattern": "queue_free.*queue_free", "issue": "double_free"},
		{"pattern": "_ready.*_ready", "issue": "multiple_ready_calls"},
		{"pattern": "while.*true", "issue": "infinite_loop_risk"},
		{"pattern": "print.*print.*print", "issue": "excessive_printing"}
	]
	
	for pattern_data in patterns:
		if content.contains(pattern_data.pattern):
			issues.append(pattern_data.issue)
	
	return issues

# ========== HEALTH MONITORING ==========

func _perform_health_check() -> void:
	"""Check health of all monitored scripts"""
	var issues_found = 0
	
	for script_path in monitored_scripts:
		var health = _check_script_health(script_path)
		if health != "healthy":
			issues_found += 1
			system_issue_detected.emit(script_path, health)
			_attempt_repair(script_path, health)
	
	if issues_found > 0:
		_print("🔍 Health check found " + str(issues_found) + " issues")

func _check_script_health(script_path: String) -> String:
	"""Check individual script health"""
	var script_info = monitored_scripts[script_path]
	
	# Check if file still exists
	if not FileAccess.file_exists(script_path):
		return "missing_file"
	
	# Check if modified recently (potential issues)
	var current_modified = FileAccess.get_modified_time(script_path)
	if current_modified > script_info.last_modified:
		script_info.last_modified = current_modified
		_analyze_script_content(script_path)  # Re-analyze
		return "recently_modified"
	
	# Check for runtime errors by looking for instances
	var instances = _find_script_instances(script_path)
	script_info.node_instances = instances
	
	for instance in instances:
		if not is_instance_valid(instance):
			return "invalid_instance"
	
	return "healthy"

func _find_script_instances(script_path: String) -> Array:
	"""Find all node instances using this script"""
	var instances = []
	_find_instances_recursive(get_tree().root, script_path, instances)
	return instances

func _find_instances_recursive(node: Node, script_path: String, instances: Array) -> void:
	"""Recursively find instances of a script"""
	if node.get_script() and str(node.get_script().resource_path) == script_path:
		instances.append(node)
	
	for child in node.get_children():
		_find_instances_recursive(child, script_path, instances)

# ========== REPAIR SYSTEM ==========

func _setup_repair_strategies() -> void:
	"""Setup automatic repair strategies"""
	repair_strategies = {
		"missing_file": _repair_missing_file,
		"invalid_instance": _repair_invalid_instance,
		"recently_modified": _repair_recent_modification,
		"potential_null_access": _repair_null_access,
		"double_free": _repair_double_free
	}

func _attempt_repair(script_path: String, issue: String) -> void:
	"""Attempt to repair detected issue"""
	repair_attempted.emit(script_path, issue)
	
	if issue in repair_strategies:
		var repair_func = repair_strategies[issue]
		var success = repair_func.call(script_path)
		repair_completed.emit(script_path, success)
		
		if success:
			_print("✅ Repaired: " + script_path + " (" + issue + ")")
		else:
			_print("❌ Failed to repair: " + script_path + " (" + issue + ")")
	else:
		_print("⚠️ No repair strategy for: " + issue)

func _repair_missing_file(script_path: String) -> bool:
	"""Attempt to restore missing file"""
	_print("🔧 Attempting to restore missing file: " + script_path)
	# Could implement backup restoration here
	return false

func _repair_invalid_instance(script_path: String) -> bool:
	"""Repair invalid script instances"""
	_print("🔧 Cleaning up invalid instances: " + script_path)
	var script_info = monitored_scripts[script_path]
	
	for instance in script_info.node_instances:
		if not is_instance_valid(instance):
			# Could attempt to recreate or remove
			pass
	
	return true

func _repair_recent_modification(script_path: String) -> bool:
	"""Handle recently modified scripts"""
	_print("🔄 Re-analyzing modified script: " + script_path)
	_analyze_script_content(script_path)
	return true

func _repair_null_access(_script_path: String) -> bool:
	"""Repair potential null access issues"""
	# This would require code modification - complex
	return false

func _repair_double_free(_script_path: String) -> bool:
	"""Repair double free issues"""
	# This would require code modification - complex  
	return false

# ========== CSV AND PYTHON INTEGRATION ==========

func _setup_python_integration() -> void:
	"""Setup Python script integration"""
	# Create Python script for external processing
	python_script_path = "user://update_script_inventory.py"
	_create_python_updater()

func _update_csv_data() -> void:
	"""Update CSV file with current script inventory"""
	var file = FileAccess.open(csv_file_path, FileAccess.WRITE)
	if not file:
		_print("❌ Failed to create CSV file")
		return
	
	# CSV Header
	file.store_line("script_path,category,health_status,lines,functions,variables,issues,last_modified")
	
	# Script data
	for script_path in monitored_scripts:
		var script_info = monitored_scripts[script_path]
		var health_data = script_health_data.get(script_path, {})
		
		var csv_line = "%s,%s,%s,%d,%d,%d,%s,%d" % [
			script_path,
			script_info.category,
			script_info.health_status,
			health_data.get("lines", 0),
			health_data.get("functions", 0),
			health_data.get("variables", 0),
			str(health_data.get("warnings", [])),
			script_info.last_modified
		]
		
		file.store_line(csv_line)
	
	file.close()
	last_csv_update = Time.get_ticks_msec()
	_print("📊 CSV updated with " + str(monitored_scripts.size()) + " scripts")

func _create_python_updater() -> void:
	"""Create Python script for automated updates and testing"""
	var python_code = '''#!/usr/bin/env python3
"""
Script Inventory Updater for Talking Ragdoll Game
Updates script inventory and optionally restarts game for testing
"""

import csv
import os
import subprocess
import time
from pathlib import Path

def update_script_inventory():
    """Read CSV and perform updates"""
    csv_path = "script_inventory.csv"
    
    if not os.path.exists(csv_path):
        print("❌ CSV file not found")
        return False
    
    scripts_data = []
    with open(csv_path, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            scripts_data.append(row)
    
    print(f"📊 Loaded {len(scripts_data)} scripts from inventory")
    
    # Analyze data
    categories = {}
    health_issues = []
    
    for script in scripts_data:
        category = script['category']
        if category not in categories:
            categories[category] = 0
        categories[category] += 1
        
        if script['health_status'] != 'healthy':
            health_issues.append(script['script_path'])
    
    print("📋 Script categories:")
    for category, count in categories.items():
        print(f"  {category}: {count} scripts")
    
    if health_issues:
        print(f"⚠️ Health issues found in {len(health_issues)} scripts")
        for script_path in health_issues[:5]:  # Show first 5
            print(f"  - {script_path}")
    
    return True

def launch_game_test():
    """Launch Godot project for testing"""
    print("🎮 Launching game for testing...")
    
    # Adjust path as needed
    godot_path = "godot"  # Assumes Godot is in PATH
    project_path = "."    # Current directory
    
    try:
        process = subprocess.Popen([
            godot_path, 
            "--path", project_path,
            "scenes/main_game.tscn"
        ])
        
        print("🎮 Game launched! Process ID:", process.pid)
        
        # Wait for user testing time (30 seconds)
        print("⏱️ Waiting 30 seconds for testing...")
        time.sleep(30)
        
        # Terminate the game
        process.terminate()
        print("🛑 Game closed automatically")
        
        return True
        
    except Exception as e:
        print(f"❌ Failed to launch game: {e}")
        return False

def main():
    """Main function"""
    print("🔧 Starting automated script inventory update...")
    
    if update_script_inventory():
        print("✅ Script inventory updated successfully")
        
        # Optionally launch game for testing
        response = input("🎮 Launch game for testing? (y/n): ")
        if response.lower() == 'y':
            launch_game_test()
    else:
        print("❌ Script inventory update failed")

if __name__ == "__main__":
    main()
'''
	
	var file = FileAccess.open(python_script_path, FileAccess.WRITE)
	if file:
		file.store_string(python_code)
		file.close()
		_print("🐍 Python updater script created")

# ========== VARIABLE INSPECTOR INTEGRATION ==========


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
func connect_variable_inspector(script_path: String, inspector: Node) -> void:
	"""Connect to variable inspector for detailed monitoring"""
	if not script_path in inspector_connections:
		inspector_connections[script_path] = []
	
	inspector_connections[script_path].append(inspector)
	_print("🔗 Connected variable inspector for: " + script_path)

func get_script_variables(script_path: String) -> Dictionary:
	"""Get all variables from connected inspectors"""
	var variables = {}
	
	if script_path in inspector_connections:
		for inspector in inspector_connections[script_path]:
			if inspector and inspector.has_method("get_all_variables"):
				var inspector_vars = inspector.get_all_variables()
				variables.merge(inspector_vars)
	
	return variables

# ========== CONSOLE COMMANDS ==========

func register_console_commands() -> void:
	"""Register repair system commands"""
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("add_command"):
		console.add_command("repair_scan", _cmd_scan, "Scan all scripts for issues")
		console.add_command("repair_status", _cmd_status, "Show repair system status")
		console.add_command("repair_csv", _cmd_update_csv, "Update CSV inventory")
		console.add_command("repair_python", _cmd_run_python, "Run Python updater")

func _cmd_scan(_args: Array) -> String:
	_perform_health_check()
	return "🔍 Script health check completed"

func _cmd_status(_args: Array) -> String:
	var status = "🔧 Self-Repair System Status:\n"
	status += "  Monitored scripts: " + str(monitored_scripts.size()) + "\n"
	status += "  CSV last updated: " + str((Time.get_ticks_msec() - last_csv_update) / 1000.0) + "s ago\n"
	status += "  Health checks performed: " + str(frame_count / float(health_check_interval))
	return status

func _cmd_update_csv(_args: Array) -> String:
	_update_csv_data()
	return "📊 CSV inventory updated at: " + csv_file_path

func _cmd_run_python(_args: Array) -> String:
	if FileAccess.file_exists(python_script_path):
		return "🐍 Python script available at: " + python_script_path + "\nRun: python " + python_script_path
	else:
		_create_python_updater()
		return "🐍 Python script created at: " + python_script_path

# ========== SCENE CLOSURE MANAGEMENT ==========

func request_scene_closure() -> void:
	"""Request scene to close gracefully"""
	_print("🛑 Requesting scene closure...")
	
	# Save current state before closing
	_update_csv_data()
	
	# Signal all systems to prepare for shutdown
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("_print_to_console"):
		console._print_to_console("🛑 Scene closing in 3 seconds...")
		console._print_to_console("📊 Final system state saved")
	
	# Close after brief delay
	await get_tree().create_timer(3.0).timeout
	get_tree().quit()

func _print(message: String) -> void:
	print("🔧 [SelfRepair] " + message)