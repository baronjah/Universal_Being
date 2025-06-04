# ==================================================
# SCRIPT NAME: run_path_fixes.gd
# DESCRIPTION: Runner script to execute path reference fixes
# PURPOSE: Fix all broken path references found in diagnostic
# CREATED: 2025-06-04 - Foundation Repair Runner
# AUTHOR: JSH + Claude Code
# ==================================================

extends Node

var path_fixer: PathReferenceFixer

func _ready() -> void:
	print("🔧 Path Reference Fix Runner: Starting...")
	
	# Load and create path fixer
	var fixer_script = load("res://tools/path_reference_fixer.gd")
	path_fixer = fixer_script.new()
	add_child(path_fixer)
	
	# Connect signals
	path_fixer.fix_complete.connect(_on_fix_complete)
	path_fixer.fix_progress.connect(_on_fix_progress)
	
	# Wait a moment then start fixing
	await get_tree().create_timer(1.0).timeout
	run_fixes()

func run_fixes() -> void:
	"""Run all path fixes"""
	print("🔧 Starting path reference fixes...")
	
	# Validate critical paths first
	print("🔧 Validating critical paths...")
	var validation = path_fixer.validate_critical_paths()
	
	# Apply fixes
	print("🔧 Applying path reference fixes...")
	await path_fixer.scan_and_fix_all()
	
	# Save report
	print("🔧 Generating fix report...")
	path_fixer.save_fix_report()
	
	# Final validation
	print("🔧 Final validation...")
	var final_validation = path_fixer.validate_critical_paths()
	
	print("🔧 ================================")
	print("🔧 PATH FIXING COMPLETE")
	print("🔧 Critical path health improved from %.1f%% to %.1f%%" % [
		(validation.existing / float(validation.total)) * 100,
		(final_validation.existing / float(final_validation.total)) * 100
	])
	print("🔧 ================================")

func _on_fix_progress(current: int, total: int) -> void:
	"""Handle fix progress updates"""
	if current % 25 == 0 or current == total:
		print("🔧 Progress: %d/%d files processed" % [current, total])

func _on_fix_complete(fixes_count: int) -> void:
	"""Handle fix completion"""
	print("✅ Fix complete! Applied %d total fixes" % fixes_count)

func _input(event: InputEvent) -> void:
	"""Handle input for manual controls"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_Q:
				print("🚪 Q pressed - Exiting path fixer...")
				get_tree().quit()
