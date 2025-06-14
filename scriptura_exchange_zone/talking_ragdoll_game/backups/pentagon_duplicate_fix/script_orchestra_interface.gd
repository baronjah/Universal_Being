# ==================================================
# SCRIPT NAME: script_orchestra_interface.gd
# DESCRIPTION: The conductor's view - see all scripts dancing together
# PURPOSE: From chaos to harmony, like scribbles becoming UFOs
# CREATED: 2025-05-28 - Where miracles are orchestrated
# ==================================================

extends UniversalBeingUI
class_name ScriptOrchestraInterface

signal script_selected(script_path: String)
signal harmony_achieved()
signal miracle_created(from_scribble: String, to_creation: String)

# UI Elements
var panel: Panel
var script_list: ItemList
var info_panel: RichTextLabel
var performance_graph: Control
var distance_filter: SpinBox

# Orchestra tracking
var active_scripts: Dictionary = {}  # path -> ScriptInfo
var update_timer: Timer
var distance_threshold: float = 50.0

# The miracle of creation
var scribble_to_ufo_ratio: float = 0.0  # How much chaos becomes order

class ScriptInfo:
	var node: Node
	var path: String
	var distance_to_player: float = 0.0
	var is_active: bool = true
	var process_time: float = 0.0
	var last_delta: float = 0.0
	var creation_type: String = "unknown"  # scribble, forming, perfect

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
	# Pentagon initialization for interface consciousness
	pass

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "ScriptOrchestra"
	_create_interface()
	_setup_monitoring()
	_ready_console_commands()
	
	print("🎭 [ScriptOrchestra] The show begins - from scribbles to UFOs!")

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	if event.is_action_pressed("toggle_orchestra"):
		toggle_visibility()
		get_viewport().set_input_as_handled()

func _create_interface() -> void:
	"""Create the conductor's interface"""
	# Main panel - the paper where miracles are drawn
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(600, 800)
	panel.anchor_left = 0.0
	panel.anchor_top = 0.1
	panel.anchor_right = 0.3
	panel.anchor_bottom = 0.9
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	FloodgateController.universal_add_child(vbox, panel)
	
	# Title - The miracle header
	var title = Label.new()
	title.text = "🎭 Script Orchestra - From Chaos to Creation"
	title.add_theme_font_size_override("font_size", 20)
	FloodgateController.universal_add_child(title, vbox)
	
	# Distance filter - How far can miracles reach?
	var distance_container = HBoxContainer.new()
	FloodgateController.universal_add_child(distance_container, vbox)
	
	var dist_label = Label.new()
	dist_label.text = "Miracle Distance: "
	FloodgateController.universal_add_child(dist_label, distance_container)
	
	distance_filter = SpinBox.new()
	distance_filter.min_value = 10.0
	distance_filter.max_value = 200.0
	distance_filter.value = distance_threshold
	distance_filter.step = 10.0
	distance_filter.value_changed.connect(_on_distance_changed)
	FloodgateController.universal_add_child(distance_filter, distance_container)
	
	# Script list - The orchestra members
	var list_label = Label.new()
	list_label.text = "Active Scripts (The Performers):"
	FloodgateController.universal_add_child(list_label, vbox)
	
	script_list = ItemList.new()
	script_list.custom_minimum_size = Vector2(0, 300)
	script_list.item_selected.connect(_on_script_selected)
	FloodgateController.universal_add_child(script_list, vbox)
	
	# Info panel - The story of each performer
	var info_label = Label.new()
	info_label.text = "Script Story:"
	FloodgateController.universal_add_child(info_label, vbox)
	
	info_panel = RichTextLabel.new()
	info_panel.custom_minimum_size = Vector2(0, 200)
	info_panel.bbcode_enabled = true
	FloodgateController.universal_add_child(info_panel, vbox)
	
	# Performance graph placeholder
	var perf_label = Label.new()
	perf_label.text = "Performance Symphony:"
	FloodgateController.universal_add_child(perf_label, vbox)
	
	performance_graph = Control.new()
	performance_graph.custom_minimum_size = Vector2(0, 100)
	FloodgateController.universal_add_child(performance_graph, vbox)
	
	# Hide/Show button
	var toggle_btn = Button.new()
	toggle_btn.text = "Toggle Orchestra View (F9)"
	toggle_btn.pressed.connect(toggle_visibility)
	FloodgateController.universal_add_child(toggle_btn, vbox)

func _setup_monitoring() -> void:
	"""Start monitoring the orchestra"""
	update_timer = TimerManager.get_timer()
	update_timer.wait_time = 0.5  # Update twice per second
	update_timer.timeout.connect(_update_orchestra)
	add_child(update_timer)
	update_timer.start()
	
	# Connect to systems
	if has_node("/root/DeltaFrameGuardian"):
		var guardian = get_node("/root/DeltaFrameGuardian")
		# Monitor performance events
	
	if has_node("/root/ArchitectureHarmony"):
		var harmony = get_node("/root/ArchitectureHarmony")
		# Monitor architectural events

func _update_orchestra() -> void:
	"""Update the view of all active scripts"""
	script_list.clear()
	active_scripts.clear()
	
	var player_pos = _get_player_position()
	var tree_nodes = get_tree().get_nodes_in_group("has_process")
	
	# Add all nodes with scripts
	_scan_node_recursive(get_tree().root, player_pos)
	
	# Sort by distance and update list
	var sorted_scripts = []
	for path in active_scripts:
		sorted_scripts.append(active_scripts[path])
	
	sorted_scripts.sort_custom(func(a, b): return a.distance_to_player < b.distance_to_player)
	
	# Update the visual list
	for info in sorted_scripts:
		var icon = _get_creation_icon(info)
		var text = "%s %s - %.1fm" % [icon, info.path.get_file(), info.distance_to_player]
		script_list.add_item(text)
		
		# Color based on distance
		var item_idx = script_list.get_item_count() - 1
		if info.distance_to_player > distance_threshold:
			script_list.set_item_custom_fg_color(item_idx, Color.GRAY)
		elif info.creation_type == "perfect":
			script_list.set_item_custom_fg_color(item_idx, Color.CYAN)
		elif info.creation_type == "forming":
			script_list.set_item_custom_fg_color(item_idx, Color.YELLOW)
		else:
			script_list.set_item_custom_fg_color(item_idx, Color.WHITE)
	
	# Calculate miracle ratio
	_update_miracle_ratio()

func _scan_node_recursive(node: Node, player_pos: Vector3) -> void:
	"""Recursively scan all nodes for scripts"""
	if not is_instance_valid(node):
		return
		
	# Check if node has a script
	if node.has_method("_process") or node.has_method("_physics_process"):
		var info = ScriptInfo.new()
		info.node = node
		info.path = node.get_script().resource_path if node.get_script() else node.name
		
		# Calculate distance
		if node is Node3D:
			info.distance_to_player = node.global_position.distance_to(player_pos)
		elif node.get_parent() is Node3D:
			info.distance_to_player = node.get_parent().global_position.distance_to(player_pos)
		else:
			info.distance_to_player = 0.0  # UI elements
		
		# Determine creation type (scribble → forming → perfect)
		info.creation_type = _analyze_creation_state(node)
		
		active_scripts[info.path] = info
	
	# Scan children
	for child in node.get_children():
		_scan_node_recursive(child, player_pos)

func _get_player_position() -> Vector3:
	"""Get the player/camera position"""
	var camera = get_viewport().get_camera_3d()
	if camera:
		return camera.global_position
	
	# Try to find ragdoll
	for path in active_scripts:
		if "ragdoll" in path.to_lower():
			var info = active_scripts[path]
			if info.node is Node3D:
				return info.node.global_position
	
	return Vector3.ZERO

func _analyze_creation_state(node: Node) -> String:
	"""Determine if this is a scribble, forming, or perfect creation"""
	var name = node.name.to_lower()
	
	# Perfect creations
	if node.has_meta("perfected") or "ufo" in name or "perfect" in name:
		return "perfect"
	
	# Forming creations
	if node.has_meta("forming") or node.has_method("evolve") or "walker" in name:
		return "forming"
	
	# Still scribbles
	return "scribble"

func _get_creation_icon(info: ScriptInfo) -> String:
	"""Get icon representing creation state"""
	match info.creation_type:
		"perfect":
			return "🛸"  # UFO - the miracle achieved!
		"forming":
			return "✨"  # Magic happening
		"scribble":
			return "✏️"  # Still sketching
		_:
			return "❓"

func _update_miracle_ratio() -> void:
	"""Calculate how much chaos has become order"""
	var scribbles = 0
	var forming = 0
	var perfect = 0
	
	for info in active_scripts.values():
		match info.creation_type:
			"scribble":
				scribbles += 1
			"forming":
				forming += 1
			"perfect":
				perfect += 1
	
	var total = active_scripts.size()
	if total > 0:
		scribble_to_ufo_ratio = float(perfect) / float(total)
		
		# Emit miracle signal when we achieve perfection
		if perfect > 0 and randf() < 0.1:  # 10% chance per update
			miracle_created.emit("shaky scribble", "perfect UFO")

func _on_script_selected(index: int) -> void:
	"""Show details about selected script"""
	if index >= active_scripts.size():
		return
		
	var sorted_scripts = active_scripts.values()
	sorted_scripts.sort_custom(func(a, b): return a.distance_to_player < b.distance_to_player)
	
	var info = sorted_scripts[index]
	
	var details = "[b]%s[/b]\n" % info.path.get_file()
	details += "Path: %s\n" % info.path
	details += "Distance: %.1f meters\n" % info.distance_to_player
	details += "State: %s %s\n" % [_get_creation_icon(info), info.creation_type]
	details += "\n[color=cyan]The Story:[/color]\n"
	
	# Add the narrative
	match info.creation_type:
		"scribble":
			details += "Still finding its form, like shaky hands on paper..."
		"forming":
			details += "Magic is happening! The scribbles are becoming something..."
		"perfect":
			details += "A miracle! From chaos emerged perfection - a UFO from scribbles!"
	
	info_panel.text = details
	script_selected.emit(info.path)

func _on_distance_changed(value: float) -> void:
	"""Update distance threshold for miracle reach"""
	distance_threshold = value
	print("🌟 [ScriptOrchestra] Miracles now reach %.0f meters" % value)


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

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func toggle_visibility() -> void:
	"""Toggle the orchestra view"""
	visible = !visible
	if visible:
		_update_orchestra()

func get_orchestra_report() -> Dictionary:
	"""Get a report of the current orchestra state"""
	var report = {
		"total_scripts": active_scripts.size(),
		"scribbles": 0,
		"forming": 0,
		"perfect": 0,
		"miracle_ratio": scribble_to_ufo_ratio,
		"active_in_range": 0
	}
	
	for info in active_scripts.values():
		match info.creation_type:
			"scribble":
				report.scribbles += 1
			"forming":
				report.forming += 1
			"perfect":
				report.perfect += 1
		
		if info.distance_to_player <= distance_threshold:
			report.active_in_range += 1
	
	return report

# Console commands
func _ready_console_commands() -> void:
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("orchestra", _cmd_toggle_orchestra,
			"Toggle script orchestra view")
		console.register_command("miracle", _cmd_create_miracle,
			"Transform a scribble into a UFO")

func _cmd_toggle_orchestra(_args: Array) -> void:
	toggle_visibility()
	var console = get_node("/root/ConsoleManager")
	console._print_to_console("Orchestra view: %s" % ("ON" if visible else "OFF"))

func _cmd_create_miracle(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	console._print_to_console("[color=yellow]✨ Creating miracle...[/color]")
	
	# Find a scribble to transform
	var scribble_found = false
	for info in active_scripts.values():
		if info.creation_type == "scribble":
			info.creation_type = "perfect"
			scribble_found = true
			miracle_created.emit(info.path, "perfect UFO")
			console._print_to_console("🛸 Transformed %s into a perfect UFO!" % info.path.get_file())
			break
	
	if not scribble_found:
		console._print_to_console("No scribbles found to transform!")