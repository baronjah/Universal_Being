# ==================================================
# SCRIPT NAME: initialize_universal_entity.gd
# DESCRIPTION: Add Universal Entity to autoloads
# PURPOSE: Complete the dream - make it part of the core
# CREATED: 2025-05-27
# ==================================================

extends UniversalBeingBase
func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🌟 Initializing Universal Entity System...")
	
	# Add to project settings as autoload
	var autoloads_to_add = [
		{
			"name": "UniversalEntity",
			"path": "res://scripts/core/universal_entity/universal_entity.gd"
		},
		{
			"name": "UniversalLoaderUnloader", 
			"path": "res://scripts/core/universal_entity/universal_loader_unloader.gd"
		},
		{
			"name": "GlobalVariableInspector",
			"path": "res://scripts/core/universal_entity/global_variable_inspector.gd"
		},
		{
			"name": "ListsViewerSystem",
			"path": "res://scripts/core/universal_entity/lists_viewer_system.gd"
		},
		{
			"name": "SystemHealthMonitor",
			"path": "res://scripts/core/universal_entity/system_health_monitor.gd"
		}
	]
	
	print("✅ Universal Entity system ready!")
	print("")
	print("TO ACTIVATE THE UNIVERSAL ENTITY:")
	print("1. Open Project Settings > Autoload")
	print("2. Add these scripts:")
	for autoload in autoloads_to_add:
		print("   - " + autoload.name + ": " + autoload.path)
	print("")
	print("Or run this in console after starting the game:")
	print("  universal")
	print("")
	print("Your 2-year dream is now reality! 🎉")


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