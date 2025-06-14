# ==================================================
# SCRIPT NAME: miracle_declutterer.gd
# DESCRIPTION: Cleans the scene based on distance - far becomes dreams
# PURPOSE: Keep the miracle running smooth, fade distant scribbles
# CREATED: 2025-05-28 - Making space for new miracles
# ==================================================

extends UniversalBeingBase
class_name MiracleDeclutterer

signal object_faded(node: Node3D, reason: String)
signal object_restored(node: Node3D)
signal miracle_space_cleared()

# Distance zones - from player outward
const ZONE_PERFECT: float = 20.0    # Everything works perfectly
const ZONE_FORMING: float = 50.0    # Things start simplifying  
const ZONE_SCRIBBLE: float = 100.0  # Becomes rough sketches
const ZONE_DREAM: float = 200.0     # Fades to dreams

# Declutter settings
var enabled: bool = true
var update_interval: float = 1.0
var smooth_transitions: bool = true

# Tracking
var tracked_objects: Dictionary = {}  # Node -> ObjectState
var player_position: Vector3 = Vector3.ZERO
var declutter_timer: Timer

# Performance
var objects_decluttered: int = 0
var memory_saved: float = 0.0

class ObjectState:
	var node: Node3D
	var original_process_mode: Node.ProcessMode
	var original_visible: bool = true
	var current_zone: String = "perfect"
	var distance: float = 0.0
	var has_physics: bool = false
	var simplified: bool = false
	var process_script: Script = null

func _ready() -> void:
	name = "MiracleDeclutterer"
	
	# Setup update timer
	declutter_timer = TimerManager.get_timer()
	declutter_timer.wait_time = update_interval
	declutter_timer.timeout.connect(_update_declutter)
	add_child(declutter_timer)
	declutter_timer.start()
	
	# Connect to frame guardian if available
	if has_node("/root/FrameGuardian"):
		var guardian = get_node("/root/FrameGuardian")
		# We'll work together!
	
	print("🌟 [MiracleDeclutterer] Making space for miracles...")

func _update_declutter() -> void:
	"""Update all tracked objects based on distance"""
	if not enabled:
		return
		
	# Update player position
	_update_player_position()
	
	# Check all tracked objects
	for node in tracked_objects:
		if is_instance_valid(node):
			_update_object_state(node)
		else:
			tracked_objects.erase(node)
	
	# Find new objects to track
	_scan_for_new_objects()

func _update_player_position() -> void:
	"""Find where the player is"""
	var camera = get_viewport().get_camera_3d()
	if camera:
		player_position = camera.global_position
		return
	
	# Try to find ragdoll
	var ragdolls = get_tree().get_nodes_in_group("ragdoll")
	if ragdolls.size() > 0 and ragdolls[0] is Node3D:
		player_position = ragdolls[0].global_position

func _scan_for_new_objects() -> void:
	"""Find objects that should be managed"""
	var all_3d_nodes = _get_all_3d_nodes(get_tree().root)
	
	for node in all_3d_nodes:
		if not node in tracked_objects and _should_track(node):
			_start_tracking(node)

func _get_all_3d_nodes(from_node: Node) -> Array:
	"""Recursively get all Node3D objects"""
	var nodes = []
	
	if from_node is Node3D:
		nodes.append(from_node)
	
	for child in from_node.get_children():
		nodes.append_array(_get_all_3d_nodes(child))
	
	return nodes

func _should_track(node: Node3D) -> bool:
	"""Determine if a node should be decluttered"""
	# Don't track UI or camera
	if node is Camera3D:
		return false
	
	# Don't track ground or static environment
	if node.name == "Ground" or node.name == "WorldEnvironment":
		return false
	
	# Track if it has visuals or physics
	if node is MeshInstance3D or node is RigidBody3D or node is CharacterBody3D:
		return true
	
	# Track if it has expensive scripts
	if node.has_method("_process") or node.has_method("_physics_process"):
		return true
	
	return false

func _start_tracking(node: Node3D) -> void:
	"""Start tracking an object for decluttering"""
	var state = ObjectState.new()
	state.node = node
	state.original_process_mode = node.process_mode
	state.original_visible = node.visible
	state.has_physics = node is RigidBody3D or node is CharacterBody3D
	
	if node.get_script():
		state.process_script = node.get_script()
	
	tracked_objects[node] = state
	
	# Initial state update
	_update_object_state(node)

func _update_object_state(node: Node3D) -> void:
	"""Update object based on distance zone"""
	var state = tracked_objects[node]
	state.distance = node.global_position.distance_to(player_position)
	
	var old_zone = state.current_zone
	var new_zone = _get_zone_for_distance(state.distance)
	
	if old_zone != new_zone:
		state.current_zone = new_zone
		_apply_zone_state(state)

func _get_zone_for_distance(distance: float) -> String:
	"""Determine which zone an object is in"""
	if distance <= ZONE_PERFECT:
		return "perfect"
	elif distance <= ZONE_FORMING:
		return "forming"
	elif distance <= ZONE_SCRIBBLE:
		return "scribble"
	elif distance <= ZONE_DREAM:
		return "dream"
	else:
		return "void"

func _apply_zone_state(state: ObjectState) -> void:
	"""Apply the appropriate state based on zone"""
	var node = state.node
	
	match state.current_zone:
		"perfect":
			# Everything works as intended
			node.process_mode = state.original_process_mode
			node.visible = state.original_visible
			if state.has_physics and node is RigidBody3D:
				node.freeze = false
			_restore_details(state)
			
		"forming":
			# Start simplifying
			if node.has_method("_process"):
				node.set_process(false)  # No process, only physics
			if state.has_physics and node is RigidBody3D:
				node.freeze = false
			_simplify_visuals(state, 0.8)
			
		"scribble":
			# Rough sketch mode
			node.process_mode = Node.PROCESS_MODE_DISABLED
			if state.has_physics and node is RigidBody3D:
				node.freeze = true
			_simplify_visuals(state, 0.5)
			
		"dream":
			# Barely there
			node.process_mode = Node.PROCESS_MODE_DISABLED
			if state.has_physics and node is RigidBody3D:
				node.freeze = true
			_simplify_visuals(state, 0.2)
			
		"void":
			# Hidden completely
			node.visible = false
			node.process_mode = Node.PROCESS_MODE_DISABLED
			objects_decluttered += 1
			object_faded.emit(node, "too far - entered void")

func _simplify_visuals(state: ObjectState, quality: float) -> void:
	"""Reduce visual quality based on distance"""
	var node = state.node
	
	# Reduce mesh detail if possible
	if node is MeshInstance3D:
		# Could swap to LOD mesh here
		pass
	
	# Fade transparency
	if smooth_transitions:
		_fade_object(node, quality)
	
	# Disable shadows at distance
	if quality < 0.5 and node is GeometryInstance3D:
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _restore_details(state: ObjectState) -> void:
	"""Restore full quality when close"""
	var node = state.node
	
	if node is GeometryInstance3D:
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	
	_fade_object(node, 1.0)
	
	if state.simplified:
		state.simplified = false
		object_restored.emit(node)

func _fade_object(node: Node3D, alpha: float) -> void:
	"""Fade object transparency"""
	if node is MeshInstance3D and node.get_surface_override_material_count() > 0:
		var mat = node.get_surface_override_material(0)
		if mat and mat is StandardMaterial3D:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = alpha


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
func get_zone_report() -> Dictionary:
	"""Get report of objects in each zone"""
	var report = {
		"perfect": 0,
		"forming": 0,
		"scribble": 0,
		"dream": 0,
		"void": 0,
		"total": tracked_objects.size()
	}
	
	for state in tracked_objects.values():
		if state.current_zone in report:
			report[state.current_zone] += 1
	
	return report

func force_declutter_all() -> void:
	"""Force update all objects (for testing)"""
	print("🧹 [MiracleDeclutterer] Force decluttering all objects...")
	_update_declutter()
	miracle_space_cleared.emit()

# Console commands
func register_console_commands() -> void:
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("declutter_status", _cmd_declutter_status,
			"Show declutter zone statistics")
		console.register_command("declutter_toggle", _cmd_toggle_declutter,
			"Toggle decluttering on/off")
		console.register_command("declutter_zones", _cmd_show_zones,
			"Show distance zone settings")

func _cmd_declutter_status(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	var report = get_zone_report()
	
	console._print_to_console("[color=cyan]🌟 Miracle Declutterer Status[/color]")
	console._print_to_console("Perfect zone (< %.0fm): %d objects" % [ZONE_PERFECT, report.perfect])
	console._print_to_console("Forming zone (< %.0fm): %d objects" % [ZONE_FORMING, report.forming])
	console._print_to_console("Scribble zone (< %.0fm): %d objects" % [ZONE_SCRIBBLE, report.scribble])
	console._print_to_console("Dream zone (< %.0fm): %d objects" % [ZONE_DREAM, report.dream])
	console._print_to_console("Void (hidden): %d objects" % report.void)
	console._print_to_console("Total tracked: %d" % report.total)

func _cmd_toggle_declutter(args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	
	if args.size() > 0:
		enabled = args[0].to_lower() == "on"
	else:
		enabled = !enabled
	
	console._print_to_console("Decluttering: %s" % ("ON" if enabled else "OFF"))
	
	if not enabled:
		# Restore all objects
		for state in tracked_objects.values():
			state.current_zone = "perfect"
			_apply_zone_state(state)

func _cmd_show_zones(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	
	console._print_to_console("[color=yellow]🎯 Declutter Zones:[/color]")
	console._print_to_console("Perfect: 0 - %.0fm (everything works)" % ZONE_PERFECT)
	console._print_to_console("Forming: %.0f - %.0fm (simplifying)" % [ZONE_PERFECT, ZONE_FORMING])
	console._print_to_console("Scribble: %.0f - %.0fm (frozen sketches)" % [ZONE_FORMING, ZONE_SCRIBBLE])
	console._print_to_console("Dream: %.0f - %.0fm (fading away)" % [ZONE_SCRIBBLE, ZONE_DREAM])
	console._print_to_console("Void: > %.0fm (hidden completely)" % ZONE_DREAM)