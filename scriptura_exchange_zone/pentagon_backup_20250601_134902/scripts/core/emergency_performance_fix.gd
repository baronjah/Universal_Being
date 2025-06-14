################################################################
# EMERGENCY PERFORMANCE FIX - CRITICAL FPS RESCUE
# Disables heavy systems when FPS drops critically low
# Created: May 31st, 2025 | Performance Emergency Protocol
# Location: scripts/core/emergency_performance_fix.gd
################################################################

extends UniversalBeingBase
################################################################
# PERFORMANCE MONITORING
################################################################

var target_fps: float = 30.0
var critical_fps: float = 15.0
var emergency_mode: bool = false
var disabled_systems: Array[String] = []

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("⚡ EMERGENCY PERFORMANCE FIX: Monitoring FPS...")
	set_process(true)

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	var current_fps = Engine.get_frames_per_second()
	
	if current_fps < critical_fps and not emergency_mode:
		print("🚨 CRITICAL FPS: %d - ACTIVATING EMERGENCY MODE!" % current_fps)
		_activate_emergency_mode()
	elif current_fps > target_fps and emergency_mode:
		print("✅ FPS RECOVERED: %d - Deactivating emergency mode" % current_fps)
		_deactivate_emergency_mode()

func _activate_emergency_mode():
	"""Disable heavy systems to improve performance"""
	emergency_mode = true
	
	# Disable heavy autoloads
	var heavy_systems = [
		"ArchitectureHarmony",
		"FrameGuardian", 
		"PerfectDelta",
		"UniversalInspectionBridge"
	]
	
	for system_name in heavy_systems:
		if has_node("/root/" + system_name):
			var system = get_node("/root/" + system_name)
			if system.has_method("set_process"):
				system.set_process(false)
			if system.has_method("set_physics_process"):
				system.set_physics_process(false)
			disabled_systems.append(system_name)
			print("🛑 DISABLED: " + system_name)

func _deactivate_emergency_mode():
	"""Re-enable systems when performance improves"""
	emergency_mode = false
	
	for system_name in disabled_systems:
		if has_node("/root/" + system_name):
			var system = get_node("/root/" + system_name)
			if system.has_method("set_process"):
				system.set_process(true)
			if system.has_method("set_physics_process"):
				system.set_physics_process(true)
			print("✅ RE-ENABLED: " + system_name)
	
	disabled_systems.clear()

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