# 🏛️ Organize Project Files - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
## Project File Organizer
## Moves documentation to proper folders


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
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
func organize_files() -> void:
	print("=== PROJECT FILE ORGANIZATION ===")
	
	var dir = DirAccess.open("res://")
	if not dir:
		print("Failed to open project directory")
		return
	
	# Create docs subfolders if needed
	if not dir.dir_exists("docs/status"):
		dir.make_dir("docs/status")
	if not dir.dir_exists("docs/technical"):
		dir.make_dir("docs/technical")
	
	# Files to move
	var status_files = [
		"CURRENT_STATE_MAY_26_2025.md",
		"RAGDOLL_STATUS_MAY_26.md",
		"TODAYS_PROGRESS_MAY_26.md",
		"WORKING_STATUS_MAY_26.md",
		"PROJECT_SUMMARY.md",
		"THREE_STRONGHOLDS_STATUS_REPORT.md"
	]
	
	var technical_files = [
		"BIOMECHANICAL_WALKER_README.md",
		"CLASS_USAGE_SCHEMES.md",
		"DEBUGGING_PATTERNS_REFERENCE.md",
		"DOMINO_EFFECT_MAP.md",
		"ERROR_FIXES_SUMMARY.md",
		"GODOT_CLASS_TO_SCRIPT_MAPPING.md",
		"GODOT_KNOWLEDGE_VAULT_STRATEGY.md",
		"IMMEDIATE_RAGDOLL_CLASS_FIXES.md",
		"KEYPOINT_RAGDOLL_SYSTEM_DESIGN.md",
		"MASTER_GODOT_CLASSES_INVENTORY.md",
		"RAGDOLL_SYSTEM_CONSOLIDATION.md",
		"RAGDOLL_V2_SYSTEM_SUMMARY.md",
		"SYSTEM_CONNECTION_SCHEME.md"
	]
	
	var guide_files = [
		"CONSOLE_CREATION_GAME_VISION.md",
		"DEVELOPMENT_WISDOM_NOTES.md",
		"QUICK_TEST_GUIDE.md",
		"RAGDOLL_GARDEN_GUIDE.md",
		"RAGDOLL_TUTORIAL_SYSTEM_PLAN.md",
		"TEST_COMMANDS.md",
		"UNIFIED_INTERFACE_SYSTEM_2025_05_25.md"
	]
	
	# Move files
	_move_files_to_folder(dir, status_files, "docs/status/")
	_move_files_to_folder(dir, technical_files, "docs/technical/")
	_move_files_to_folder(dir, guide_files, "docs/guides/")
	
	print("\n✅ Project files organized!")

func _move_files_to_folder(dir: DirAccess, files: Array, target_folder: String) -> void:
	print("\nMoving files to %s:" % target_folder)
	for file in files:
		if dir.file_exists(file):
			var err = dir.rename(file, target_folder + file)
			if err == OK:
				print("  ✅ Moved: %s" % file)
			else:
				print("  ❌ Failed to move: %s (error: %d)" % [file, err])
		else:
			print("  ⚠️ Not found: %s" % file)