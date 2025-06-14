# ==================================================
# SCRIPT NAME: astral_being_manager.gd
# DESCRIPTION: Manages magical astral beings and test panel
# PURPOSE: Central control for astral beings
# CREATED: 2025-05-28 - Astral being management
# ==================================================

extends UniversalBeingBase
signal being_spawned(being: Node3D)
signal task_completed(being_name: String, task: String)

# Beings
var astral_beings: Array = []
var being_scene = preload("res://freezer/astral_beings/magical_astral_being.gd")

# Test panel
var test_panel: Control

# Settings
var max_beings: int = 12
var auto_organize: bool = true
var being_colors = [
	Color(0.5, 0.8, 1.0),  # Blue
	Color(1.0, 0.5, 0.8),  # Pink
	Color(0.5, 1.0, 0.8),  # Green
	Color(1.0, 0.8, 0.5),  # Gold
	Color(0.8, 0.5, 1.0),  # Purple
	Color(1.0, 1.0, 0.5)   # Yellow
]

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_register_commands()
	_create_test_panel()
	print("[AstralBeingManager] Astral dimension connected")

func _register_commands() -> void:
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		# Being management
		console.register_command("astral_spawn", _cmd_spawn_being, "Spawn a magical astral being")
		console.register_command("astral_list", _cmd_list_beings, "List all astral beings")
		console.register_command("astral_clear", _cmd_clear_beings, "Remove all astral beings")
		console.register_command("astral_task", _cmd_assign_task, "Assign task to being")
		
		# Being actions
		console.register_command("astral_organize", _cmd_organize_scene, "Astral beings organize the scene")
		console.register_command("astral_patrol", _cmd_start_patrol, "Start astral patrol")
		console.register_command("astral_help", _cmd_help_ragdoll, "Astral beings help ragdoll")
		console.register_command("astral_lights", _cmd_create_lights, "Create magical lights")
		
		# Test panel
		console.register_command("test_panel", _cmd_toggle_test_panel, "Toggle feature test panel")
		console.register_command("test_all", _cmd_test_all_features, "Run all feature tests")

func _create_test_panel() -> void:
	if ResourceLoader.exists("res://scripts/ui/feature_test_panel.gd"):
		var TestPanel = preload("res://scripts/ui/feature_test_panel.gd")
		test_panel = TestPanel.new()
		test_panel.name = "FeatureTestPanel"
		get_tree().root.call_deferred("add_child", test_panel)
		test_panel.hide()  # Start hidden

# ================================
# BEING COMMANDS
# ================================

func _cmd_spawn_being(args: Array) -> void:
	if astral_beings.size() >= max_beings:
		_print("Maximum astral beings reached (%d)" % max_beings)
		return
	
	var being_name = "Astral Being " + str(astral_beings.size() + 1)
	if args.size() > 0:
		being_name = args[0]
	
	var being = await spawn_astral_being(being_name)
	if being:
		var name_to_print = being_name if being_name != "" else "Astral Being " + str(astral_beings.size())
		_print("[color=cyan]Spawned: " + name_to_print + "[/color]")
	else:
		_print("[color=red]Failed to spawn astral being[/color]")

func _cmd_list_beings(_args: Array) -> void:
	if astral_beings.is_empty():
		_print("No astral beings present")
		return
	
	_print("[color=cyan]=== Astral Beings (%d) ===[/color]" % astral_beings.size())
	for being in astral_beings:
		if not is_instance_valid(being):
			continue
		
		# Safely access properties
		var being_name = being.name
		if being.has_method("get_being_name"):
			being_name = being.get_being_name()
		
		var is_busy = false
		if being.has_method("is_busy"):
			is_busy = being.is_busy()
		elif "is_busy" in being:
			is_busy = being.is_busy
		
		var current_task = {}
		if "current_task" in being:
			current_task = being.current_task
		
		var task_queue_size = 0
		if "task_queue" in being:
			task_queue_size = being.task_queue.size()
		
		var status = "Idle" if not is_busy else "Working on: " + current_task.get("type", "unknown")
		_print("  • %s - %s" % [being_name, status])
		_print("    Position: %s" % being.position)
		_print("    Tasks queued: %d" % task_queue_size)

func _cmd_clear_beings(_args: Array) -> void:
	var count = astral_beings.size()
	for being in astral_beings:
		being.queue_free()
	astral_beings.clear()
	_print("[color=yellow]Cleared %d astral beings[/color]" % count)

func _cmd_assign_task(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: astral_task <being_name/index> <task_type> [params]")
		_print("Tasks: move_to, collect_objects, organize_area, create_light, patrol")
		return
	
	var being = _find_being(args[0])
	if not being:
		_print("[color=red]Being not found: " + args[0] + "[/color]")
		return
	
	var task_type = args[1]
	var params = {}
	
	# Parse additional parameters
	if args.size() > 2:
		match task_type:
			"move_to":
				if args.size() >= 5:
					params.position = Vector3(float(args[2]), float(args[3]), float(args[4]))
			"collect_objects":
				params.radius = float(args[2])
			"organize_area":
				if args.size() >= 5:
					params.center = Vector3(float(args[2]), float(args[3]), float(args[4]))
	
	being.add_task(task_type, params)
	_print("[color=green]Task assigned to " + being.being_name + "[/color]")

func _cmd_organize_scene(_args: Array) -> void:
	if astral_beings.is_empty():
		spawn_astral_being("Organizer")
	
	# Divide scene into areas
	var areas = [
		Vector3(-5, 0, -5),
		Vector3(5, 0, -5),
		Vector3(-5, 0, 5),
		Vector3(5, 0, 5),
		Vector3.ZERO
	]
	
	for i in range(min(astral_beings.size(), areas.size())):
		astral_beings[i].add_task("organize_area", {"center": areas[i]})
	
	_print("[color=cyan]Astral beings organizing scene...[/color]")

func _cmd_start_patrol(_args: Array) -> void:
	if astral_beings.is_empty():
		spawn_astral_being("Patrol Guard")
	
	# Create patrol routes
	var routes = [
		[Vector3(-10, 2, -10), Vector3(10, 2, -10), Vector3(10, 2, 10), Vector3(-10, 2, 10)],
		[Vector3(0, 2, -15), Vector3(15, 2, 0), Vector3(0, 2, 15), Vector3(-15, 2, 0)],
		[Vector3(-5, 2, -5), Vector3(5, 2, -5), Vector3(5, 2, 5), Vector3(-5, 2, 5)]
	]
	
	for i in range(min(astral_beings.size(), routes.size())):
		astral_beings[i].add_task("patrol", {"points": routes[i]})
	
	_print("[color=cyan]Astral patrol started[/color]")

func _cmd_help_ragdoll(_args: Array) -> void:
	if astral_beings.is_empty():
		spawn_astral_being("Helper")
	
	for being in astral_beings:
		being.add_task("help_ragdoll")
	
	_print("[color=cyan]Astral beings helping ragdoll[/color]")

func _cmd_create_lights(_args: Array) -> void:
	if astral_beings.is_empty():
		spawn_astral_being("Light Bringer")
	
	# Create lights in pattern
	var positions = []
	for x in range(-10, 11, 5):
		for z in range(-10, 11, 5):
			positions.append(Vector3(x, 3, z))
	
	# Distribute light creation tasks
	for i in range(positions.size()):
		var being_index = i % astral_beings.size()
		astral_beings[being_index].add_task("create_light", {"position": positions[i]})
	
	_print("[color=cyan]Creating magical light grid[/color]")

# ================================
# TEST PANEL COMMANDS
# ================================

func _cmd_toggle_test_panel(_args: Array) -> void:
	if test_panel:
		test_panel.visible = !test_panel.visible
		_print("Test panel: " + ("visible" if test_panel.visible else "hidden"))
	else:
		_print("[color=red]Test panel not available[/color]")

func _cmd_test_all_features(_args: Array) -> void:
	if test_panel:
		test_panel.show()
		# Trigger all tests programmatically
		_print("[color=cyan]Running all feature tests...[/color]")
		_print("[color=yellow]Check test panel for results[/color]")
	else:
		_print("[color=red]Test panel not available[/color]")

# ================================
# PUBLIC API
# ================================


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
func spawn_astral_being(being_name: String = "", position: Vector3 = Vector3.ZERO) -> Node3D:
	var being = being_scene.new()
	
	# Set name
	if being_name == "":
		being_name = "Astral Being " + str(astral_beings.size() + 1)
	being.set_being_name(being_name)
	
	# Set random color from palette
	var color = being_colors[astral_beings.size() % being_colors.size()]
	being.set_color(color)
	
	# Set position
	if position == Vector3.ZERO:
		position = Vector3(
			randf_range(-5, 5),
			randf_range(2, 4),
			randf_range(-5, 5)
		)
	being.position = position
	
	# Queue creation through Floodgate so it can be inspected
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate:
		# Create through Floodgate
		var params = {
			"class_name": "Node3D",
			"parent_path": get_tree().current_scene.get_path(),
			"name": being_name,
			"properties": {
				"position": position
			}
		}
		
		# Queue the creation operation  
		var _op_id = floodgate.queue_operation(floodgate.OperationType.CREATE_NODE, params, 5)
		
		# Wait a frame for node to be created
		await get_tree().process_frame
		
		# Find the created node and attach script
		var created_being = get_tree().current_scene.get_node(being_name)
		if created_being:
			created_being.set_script(being_scene)
			
			# Initialize the being properties through method calls
			if created_being.has_method("set_being_name"):
				created_being.set_being_name(being_name)
			if created_being.has_method("set_color"):
				created_being.set_color(color)
			
			astral_beings.append(created_being)
			
			# Connect signals
			created_being.task_completed.connect(_on_task_completed.bind(created_being))
			
			being_spawned.emit(created_being)
			return created_being
		else:
			_print("[color=red]Failed to create being through Floodgate[/color]")
			return null
	else:
		# Fallback: Add directly with deferred call
		_print("[color=yellow]Warning: FloodgateController not found, adding directly[/color]")
		get_tree().current_scene.call_deferred("add_child", being)
		astral_beings.append(being)
		
		# Connect signals
		being.task_completed.connect(_on_task_completed.bind(being))
		
		being_spawned.emit(being)
		return being

func get_nearest_being(position: Vector3) -> Node3D:
	var nearest = null
	var min_distance = INF
	
	for being in astral_beings:
		var distance = being.position.distance_to(position)
		if distance < min_distance:
			min_distance = distance
			nearest = being
	
	return nearest

func assign_task_to_nearest(position: Vector3, task: String, params: Dictionary = {}) -> void:
	var being = get_nearest_being(position)
	if being:
		being.add_task(task, params)

# ================================
# HELPER FUNCTIONS
# ================================

func _find_being(identifier: String) -> Node3D:
	# Try as index
	if identifier.is_valid_int():
		var index = int(identifier)
		if index >= 0 and index < astral_beings.size():
			return astral_beings[index]
	
	# Try as name
	for being in astral_beings:
		if being.being_name == identifier:
			return being
	
	return null

func _print(text: String) -> void:
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console._print_to_console(text)
	else:
		print(text)

func _on_task_completed(task: String, being: Node3D) -> void:
	task_completed.emit(being.being_name, task)
	
	# Auto-organize if enabled
	if auto_organize and task != "organize_area" and task != "patrol":
		# Check if area needs organizing
		var nearby_objects = being._find_nearby_objects(being.position, 5.0)
		if nearby_objects.size() > 5:
			being.add_task("organize_area", {"center": being.position})