# 🏛️ Performance Guardian - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: performance_guardian.gd
# DESCRIPTION: Keeps the game running smooth no matter what
# PURPOSE: Auto-optimize, freeze, unload to maintain sanity
# CREATED: 2025-05-27
# ==================================================

extends UniversalBeingBase
signal optimization_triggered(reason: String)
signal beings_frozen(count: int)
signal beings_unloaded(count: int)

# Thresholds
const TARGET_FPS: float = 30.0
const CRITICAL_FPS: float = 20.0
const EMERGENCY_FPS: float = 15.0
const MAX_MEMORY_MB: float = 4096.0
const MAX_NODES: int = 10000
const MAX_BEINGS: int = 1000

# Tracking
var fps_history: Array[float] = []
var optimization_level: int = 0
var last_optimization: int = 0
var frozen_beings: Array = []  # Array[UniversalBeing]
var unloaded_nodes: Array = []

# References
var universal_object_manager: Node = null
var floodgate: Node = null

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "PerformanceGuardian"
	set_process(true)
	
	# Get system references
	universal_object_manager = get_node_or_null("/root/UniversalObjectManager")
	floodgate = get_node_or_null("/root/FloodgateController")
	
	print("🛡️ [PerformanceGuardian] Protecting game sanity...")

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Track FPS
	var current_fps = Engine.get_frames_per_second()
	fps_history.append(current_fps)
	if fps_history.size() > 60:  # Keep last 60 frames
		fps_history.pop_front()
	
	# Check every 30 frames
	if Engine.get_process_frames() % 30 == 0:
		_check_performance()

func _check_performance() -> void:
	"""Main performance check"""
	var avg_fps = _get_average_fps()
	var node_count = get_tree().get_node_count()
	var being_count = get_tree().get_nodes_in_group("universal_beings").size()
	
	# Determine optimization level needed
	if avg_fps < EMERGENCY_FPS:
		_emergency_optimization()
	elif avg_fps < CRITICAL_FPS:
		_critical_optimization()
	elif avg_fps < TARGET_FPS:
		_standard_optimization()
	elif optimization_level > 0 and avg_fps > TARGET_FPS + 10:
		_reduce_optimization()
	
	# Check other limits
	if node_count > MAX_NODES:
		_reduce_nodes()
	
	if being_count > MAX_BEINGS:
		_reduce_beings()

func _get_average_fps() -> float:
	"""Calculate average FPS"""
	if fps_history.is_empty():
		return 60.0
	
	var sum = 0.0
	for fps in fps_history:
		sum += fps
	return sum / fps_history.size()

# ========== OPTIMIZATION LEVELS ==========

func _standard_optimization() -> void:
	"""Level 1: Basic optimization"""
	if optimization_level >= 1:
		return
		
	optimization_level = 1
	print("⚡ [Performance] Standard optimization triggered")
	
	# Freeze distant beings
	var player = _get_player_position()
	var frozen_count = 0
	
	for being in get_tree().get_nodes_in_group("universal_beings"):
		if being.has_method("become") and being.has_method("get_property"):  # is UniversalBeing
			being.freeze()
			frozen_beings.append(being)
			frozen_count += 1
	
	if frozen_count > 0:
		beings_frozen.emit(frozen_count)
		print("❄️ [Performance] Froze " + str(frozen_count) + " distant beings")
	
	optimization_triggered.emit("standard")

func _critical_optimization() -> void:
	"""Level 2: Aggressive optimization"""
	if optimization_level >= 2:
		return
		
	optimization_level = 2
	print("⚠️ [Performance] Critical optimization triggered")
	
	# First do standard
	_standard_optimization()
	
	# Unload decorative objects
	var unloaded = 0
	for node in get_tree().get_nodes_in_group("decorative"):
		node.queue_free()
		unloaded_nodes.append(node.name)
		unloaded += 1
	
	# Reduce particle effects
	for particle in get_tree().get_nodes_in_group("particles"):
		if particle is CPUParticles3D:
			particle.amount = int(particle.amount * 0.5)
	
	# Disable shadows on small objects
	for mesh in get_tree().get_nodes_in_group("meshes"):
		if mesh is MeshInstance3D and mesh.get_aabb().size.length() < 2.0:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	beings_unloaded.emit(unloaded)
	optimization_triggered.emit("critical")

func _emergency_optimization() -> void:
	"""Level 3: Emergency measures"""
	optimization_level = 3
	print("🚨 [Performance] EMERGENCY optimization triggered")
	
	# Clear everything non-essential
	var preserved_groups = ["player", "ground", "critical_systems"]
	var cleared = 0
	
	for node in get_tree().get_nodes_in_group("spawned_objects"):
		var preserve = false
		for group in preserved_groups:
			if node.is_in_group(group):
				preserve = true
				break
		
		if not preserve:
			node.queue_free()
			cleared += 1
	
	# Freeze ALL beings except nearest 5
	var beings = get_tree().get_nodes_in_group("universal_beings")
	var player_pos = _get_player_position()
	
	# Sort by distance
	beings.sort_custom(func(a, b): 
		return a.position.distance_to(player_pos) < b.position.distance_to(player_pos)
	)
	
	# Keep only nearest 5 active
	for i in range(beings.size()):
		if i >= 5 and beings[i].has_method("become"):  # is UniversalBeing
			beings[i].freeze()
	
	print("🧹 [Performance] Emergency cleared " + str(cleared) + " objects")
	beings_unloaded.emit(cleared)
	optimization_triggered.emit("emergency")

func _reduce_optimization() -> void:
	"""Gradually reduce optimization when performance improves"""
	if optimization_level == 0:
		return
	
	optimization_level = max(0, optimization_level - 1)
	print("✅ [Performance] Reducing optimization to level " + str(optimization_level))
	
	# Unfreeze some beings
	var unfrozen = 0
	for being in frozen_beings:
		if is_instance_valid(being) and unfrozen < 10:
			being.unfreeze()
			unfrozen += 1
	
	frozen_beings = frozen_beings.slice(unfrozen)

# ========== SPECIFIC OPTIMIZATIONS ==========

func _reduce_nodes() -> void:
	"""Reduce total node count"""
	print("📉 [Performance] Reducing node count...")
	
	# Find and remove duplicate objects at same position
	var positions = {}
	for obj in get_tree().get_nodes_in_group("spawned_objects"):
		if obj is Node3D:
			var key = str(obj.position.snapped(Vector3.ONE))
			if positions.has(key):
				obj.queue_free()
			else:
				positions[key] = true

func _reduce_beings() -> void:
	"""Reduce number of Universal Beings"""
	print("📉 [Performance] Reducing being count...")
	
	# Merge nearby void beings
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for i in range(beings.size()):
		if not is_instance_valid(beings[i]):
			continue
		for j in range(i + 1, beings.size()):
			if not is_instance_valid(beings[j]):
				continue
			if beings[i].form == "void" and beings[j].form == "void":
				if beings[i].position.distance_to(beings[j].position) < 1.0:
					beings[j].queue_free()

# ========== UTILITY ==========

func _get_player_position() -> Vector3:
	"""Get player position for distance calculations"""
	var player = get_tree().get_first_node_in_group("player")
	if player and player is Node3D:
		return player.position
	
	# Fallback to camera
	var camera = get_viewport().get_camera_3d()
	if camera:
		return camera.position
	
	return Vector3.ZERO


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
func get_performance_stats() -> Dictionary:
	"""Get current performance statistics"""
	return {
		"fps": Engine.get_frames_per_second(),
		"avg_fps": _get_average_fps(),
		"node_count": get_tree().get_node_count(),
		"being_count": get_tree().get_nodes_in_group("universal_beings").size(),
		"frozen_beings": frozen_beings.size(),
		"optimization_level": optimization_level,
		"memory_usage": OS.get_static_memory_usage() / 1024.0 / 1024.0  # MB
	}

func force_optimization(level: int) -> void:
	"""Manually trigger optimization level"""
	match level:
		1: _standard_optimization()
		2: _critical_optimization()
		3: _emergency_optimization()
		_: _reduce_optimization()