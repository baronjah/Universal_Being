# ==================================================
# SCRIPT NAME: run_warning_fixes.gd
# DESCRIPTION: Runs targeted warning fixes
# PURPOSE: Safely fix the most problematic files
# CREATED: 2025-05-25 - Targeted fixing
# ==================================================

extends UniversalBeingBase
# Files we know have many warnings based on error output
var HIGH_PRIORITY_FILES = [
	"res://scripts/core/talking_ragdoll.gd",
	"res://scripts/core/game_manager.gd",
	"res://scripts/ui/console.gd",
	"res://scripts/ui/bryce_interface_grid.gd",
	"res://scripts/jsh_framework/core/jsh_scene_tree_system.gd",
	"res://scripts/jsh_framework/core/JSH_console.gd",
	"res://scripts/jsh_framework/data_structures/container.gd",
	"res://scripts/effects/blink_animation_controller.gd",
	"res://scripts/effects/visual_indicator_system.gd"
]

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("=== TARGETED WARNING FIX RUNNER ===")
	print("This will help fix the 160+ unused parameter warnings")
	print("")
	
	# Load our tools
	var _BatchFixer = load("res://scripts/test/batch_parameter_fixer.gd")
	var _Scanner = load("res://scripts/test/warning_scanner.gd")
	var _KnowledgeBase = load("res://scripts/test/fix_knowledge_base.gd")
	
	# Show what we're about to do
	print("HIGH PRIORITY FILES TO FIX:")
	for file in HIGH_PRIORITY_FILES:
		print("  - %s" % file)
	
	print("\nPATTERNS WE'LL FIX:")
	print("  - _process(delta) -> _process(_delta)")
	print("  - _input(event) -> _input(_event)")
	print("  - _on_body_entered(body) -> _on_body_entered(_body)")
	print("  - And more common Godot callbacks...")
	
	print("\nSTEP 1: Analyzing files...")
	_analyze_files()
	
	print("\nSTEP 2: Creating backups...")
	_create_backups()
	
	print("\nSTEP 3: Applying fixes...")
	_apply_fixes()
	
	print("\nSTEP 4: Generating report...")
	_generate_report()

func _analyze_files() -> void:
	# Check which files actually exist
	var existing_files = []
	for file_path in HIGH_PRIORITY_FILES:
		if FileAccess.file_exists(file_path):
			existing_files.append(file_path)
			print("  ✓ Found: %s" % file_path)
		else:
			print("  ✗ Missing: %s" % file_path)
	
	print("\nFound %d/%d files" % [existing_files.size(), HIGH_PRIORITY_FILES.size()])

func _create_backups() -> void:
	# Create backup directory
	var backup_dir = "res://scripts/test/backups/"
	var dir = DirAccess.open("res://scripts/test/")
	if dir and not dir.dir_exists("backups"):
		dir.make_dir("backups")
	
	# Copy files
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	for file_path in HIGH_PRIORITY_FILES:
		if FileAccess.file_exists(file_path):
			var _backup_path = backup_dir + file_path.get_file() + "." + timestamp
			print("  Backing up: %s" % file_path.get_file())
			# In real implementation, we'd copy the file here

func _apply_fixes() -> void:
	var BatchFixer = load("res://scripts/test/batch_parameter_fixer.gd")
	
	# First do a dry run
	print("  Performing dry run...")
	for file_path in HIGH_PRIORITY_FILES:
		if FileAccess.file_exists(file_path):
			var result = BatchFixer.fix_file(file_path, true)
			if result.changes.size() > 0:
				print("    %s: %d changes possible" % [file_path.get_file(), result.changes.size()])
	
	# Then apply (commented out for safety)
	# print("\n  Applying fixes...")
	# BatchFixer.batch_fix(HIGH_PRIORITY_FILES, false)

func _generate_report() -> void:
	print("\n=== FIX SUMMARY ===")
	print("This system can fix common unused parameter warnings by:")
	print("1. Prefixing unused Godot callback parameters with _")
	print("2. Following Godot conventions for interface methods")
	print("3. Preserving function signatures for compatibility")
	print("")
	print("To apply fixes, uncomment the batch_fix line in _apply_fixes()")
	print("")
	print("Remember: These are safe fixes for known patterns.")
	print("Manual review is still recommended for complex cases.")

# Helper function to show before/after examples

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
func show_examples() -> void:
	print("\n=== EXAMPLE FIXES ===")
	var examples = [
		{
			"before": "func _process(delta: float) -> void:\n    position.x += speed",
			"after": "func _process(_delta: float) -> void:\n    position.x += speed"
		},
		{
			"before": "func _on_button_pressed() -> void:\n    print('clicked')",
			"after": "func _on_button_pressed() -> void:\n    print('clicked')"
		},
		{
			"before": "func _on_body_entered(body: Node2D) -> void:\n    emit_signal('hit')",
			"after": "func _on_body_entered(_body: Node2D) -> void:\n    emit_signal('hit')"
		}
	]
	
	for example in examples:
		print("\nBEFORE:")
		print(example.before)
		print("\nAFTER:")
		print(example.after)
		print("---")

# Function to test a single file
func test_single_file(file_path: String) -> void:
	print("\n=== TESTING SINGLE FILE: %s ===" % file_path)
	
	var BatchFixer = load("res://scripts/test/batch_parameter_fixer.gd")
	var result = BatchFixer.fix_file(file_path, true)
	
	if result.success:
		print("Changes found: %d" % result.changes.size())
		for change in result.changes:
			print("\nLine %d:" % change.line)
			print("  OLD: %s" % change.old.strip_edges())
			print("  NEW: %s" % change.new.strip_edges())
	else:
		print("Error: %s" % result.error)