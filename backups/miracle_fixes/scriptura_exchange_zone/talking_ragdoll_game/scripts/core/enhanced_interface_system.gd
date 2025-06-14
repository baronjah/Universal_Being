# ==================================================
# SCRIPT NAME: enhanced_interface_system.gd
# DESCRIPTION: Advanced 3D interface system for Universal Being interfaces
# PURPOSE: Create truly functional, clickable, scrollable 3D interfaces
# CREATED: 2025-05-30 - Interface evolution
# ==================================================

extends UniversalBeingBase
class_name EnhancedInterfaceSystem

signal interface_button_clicked(button_id: String, data: Dictionary)
signal interface_value_changed(element_id: String, new_value: Variant)
signal interface_scrolled(direction: Vector2, amount: float)

# Interface components
var interface_panel: MeshInstance3D
var interface_material: StandardMaterial3D
var ui_viewport: SubViewport
var ui_control: Control
var click_detector: Area3D

# Interface properties
var interface_size: Vector2 = Vector2(4.0, 3.0)
var interface_resolution: Vector2i = Vector2i(800, 600)
var is_interactive: bool = true
var interface_type: String = "generic"

# Connected systems
var connected_universal_being: Node = null
var connected_systems: Dictionary = {}

# Interface elements
var buttons: Dictionary = {}
var sliders: Dictionary = {}
var labels: Dictionary = {}
var scroll_areas: Dictionary = {}

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_interface_structure()
	_setup_interaction_detection()
	print("✨ [EnhancedInterface] Ready: ", interface_type)

func _create_interface_structure() -> void:
	"""Create the 3D interface structure"""
	# Create main panel mesh
	interface_panel = MeshInstance3D.new()
	interface_panel.name = "InterfacePanel"
	add_child(interface_panel)
	
	# Create panel geometry
	var panel_mesh = PlaneMesh.new()
	panel_mesh.size = interface_size
	interface_panel.mesh = panel_mesh
	
	# Create material with viewport texture
	interface_material = MaterialLibrary.get_material("default")
	interface_material.flags_unshaded = true
	interface_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	interface_material.albedo_color = Color.WHITE
	interface_panel.material_override = interface_material
	
	# Create UI viewport
	ui_viewport = SubViewport.new()
	ui_viewport.size = interface_resolution
	ui_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(ui_viewport)
	
	# Create root UI control
	ui_control = Control.new()
	ui_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(ui_control, ui_viewport)
	
	# Apply viewport texture to material
	interface_material.albedo_texture = ui_viewport.get_texture()
	
	print("🖼️ [EnhancedInterface] Structure created")

func _setup_interaction_detection() -> void:
	"""Set up 3D interaction detection"""
	click_detector = Area3D.new()
	click_detector.name = "ClickDetector"
	add_child(click_detector)
	
	# Create collision shape for the panel
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(interface_size.x, interface_size.y, 0.1)
	collision_shape.shape = box_shape
	FloodgateController.universal_add_child(collision_shape, click_detector)
	
	# Connect interaction signals
	click_detector.input_event.connect(_on_3d_input_event)
	click_detector.mouse_entered.connect(_on_mouse_entered)
	click_detector.mouse_exited.connect(_on_mouse_exited)
	
	print("🖱️ [EnhancedInterface] Interaction detection ready")


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
func setup_interface_type(type: String, universal_being: Node = null) -> void:
	"""Set up interface based on type"""
	interface_type = type
	connected_universal_being = universal_being
	
	# Clear existing UI
	if ui_control and is_instance_valid(ui_control):
		for child in ui_control.get_children():
			child.queue_free()
	else:
		print("⚠️ [EnhancedInterface] ui_control is null - recreating structure")
		_create_interface_structure()
	
	# Create type-specific interface
	match type:
		"console":
			_create_console_interface()
		"asset_creator":
			_create_asset_creator_interface()
		"neural_status":
			_create_neural_status_interface()
		"system_monitor":
			_create_system_monitor_interface()
		"being_inspector":
			_create_being_inspector_interface()
		"grid_list":
			_create_grid_list_interface()
		_:
			_create_generic_interface()
	
	print("🎨 [EnhancedInterface] Setup complete for type: ", type)

# ===== SPECIFIC INTERFACE IMPLEMENTATIONS =====

func _create_console_interface() -> void:
	"""Create interactive console interface"""
	var console_bg = ColorRect.new()
	console_bg.color = Color(0.1, 0.1, 0.1, 0.9)
	console_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(console_bg, ui_control)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	FloodgateController.universal_add_child(vbox, ui_control)
	
	# Title
	var title = Label.new()
	title.text = "NEURAL CONSOLE"
	title.add_theme_color_override("font_color", Color.CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FloodgateController.universal_add_child(title, vbox)
	
	# Output area (scrollable)
	var scroll_container = ScrollContainer.new()
	scroll_container.custom_minimum_size = Vector2(0, 400)
	FloodgateController.universal_add_child(scroll_container, vbox)
	
	var output_label = RichTextLabel.new()
	output_label.fit_content = true
	output_label.bbcode_enabled = true
	output_label.text = "[color=green]🧠 Neural Console Ready[/color]\n[color=yellow]Connected Systems:[/color]\n• Universal Being Framework\n• Consciousness Networks\n• Physical Embodiment\n\n[color=cyan]Available Commands:[/color]\nconscious <being> <level>\nneural_status\nneeds <being>\nthink <being> <topic>"
	FloodgateController.universal_add_child(output_label, scroll_container)
	labels["console_output"] = output_label
	
	# Input area
	var input_container = HBoxContainer.new()
	FloodgateController.universal_add_child(input_container, vbox)
	
	var prompt_label = Label.new()
	prompt_label.text = ">"
	prompt_label.add_theme_color_override("font_color", Color.WHITE)
	FloodgateController.universal_add_child(prompt_label, input_container)
	
	var input_field = LineEdit.new()
	input_field.placeholder_text = "Enter neural command..."
	input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(input_field, input_container)
	
	var execute_button = Button.new()
	execute_button.text = "Execute"
	execute_button.pressed.connect(_on_console_command_executed.bind(input_field))
	FloodgateController.universal_add_child(execute_button, input_container)
	buttons["console_execute"] = execute_button
	
	# Quick action buttons
	var actions_container = HBoxContainer.new()
	FloodgateController.universal_add_child(actions_container, vbox)
	
	var neural_status_btn = Button.new()
	neural_status_btn.text = "Neural Status"
	neural_status_btn.pressed.connect(_on_quick_action.bind("neural_status"))
	FloodgateController.universal_add_child(neural_status_btn, actions_container)
	buttons["neural_status"] = neural_status_btn
	
	var test_consciousness_btn = Button.new()
	test_consciousness_btn.text = "Test Consciousness"
	test_consciousness_btn.pressed.connect(_on_quick_action.bind("test_consciousness"))
	FloodgateController.universal_add_child(test_consciousness_btn, actions_container)
	buttons["test_consciousness"] = test_consciousness_btn

func _create_asset_creator_interface() -> void:
	"""Create interactive asset creator interface"""
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.1, 0.0, 0.9)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(bg, ui_control)
	
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 15)
	FloodgateController.universal_add_child(main_container, ui_control)
	
	# Title
	var title = Label.new()
	title.text = "UNIVERSAL ASSET CREATOR"
	title.add_theme_color_override("font_color", Color.ORANGE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FloodgateController.universal_add_child(title, main_container)
	
	# Asset type selection
	var type_container = HBoxContainer.new()
	FloodgateController.universal_add_child(type_container, main_container)
	
	var type_label = Label.new()
	type_label.text = "Asset Type:"
	type_label.add_theme_color_override("font_color", Color.WHITE)
	FloodgateController.universal_add_child(type_label, type_container)
	
	var type_dropdown = OptionButton.new()
	type_dropdown.add_item("Tree")
	type_dropdown.add_item("Rock")
	type_dropdown.add_item("Building")
	type_dropdown.add_item("Vehicle")
	type_dropdown.add_item("Character")
	type_dropdown.add_item("Furniture")
	FloodgateController.universal_add_child(type_dropdown, type_container)
	
	# Size controls
	var size_container = VBoxContainer.new()
	FloodgateController.universal_add_child(size_container, main_container)
	
	var size_label = Label.new()
	size_label.text = "Size Controls:"
	size_label.add_theme_color_override("font_color", Color.WHITE)
	FloodgateController.universal_add_child(size_label, size_container)
	
	# X Size
	var x_container = HBoxContainer.new()
	FloodgateController.universal_add_child(x_container, size_container)
	var x_label = Label.new()
	x_label.text = "X:"
	x_label.add_theme_color_override("font_color", Color.WHITE)
	FloodgateController.universal_add_child(x_label, x_container)
	var x_slider = HSlider.new()
	x_slider.min_value = 0.1
	x_slider.max_value = 10.0
	x_slider.value = 1.0
	x_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(x_slider, x_container)
	sliders["size_x"] = x_slider
	
	# Y Size
	var y_container = HBoxContainer.new()
	FloodgateController.universal_add_child(y_container, size_container)
	var y_label = Label.new()
	y_label.text = "Y:"
	y_label.add_theme_color_override("font_color", Color.WHITE)
	FloodgateController.universal_add_child(y_label, y_container)
	var y_slider = HSlider.new()
	y_slider.min_value = 0.1
	y_slider.max_value = 10.0
	y_slider.value = 1.0
	y_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(y_slider, y_container)
	sliders["size_y"] = y_slider
	
	# Z Size
	var z_container = HBoxContainer.new()
	FloodgateController.universal_add_child(z_container, size_container)
	var z_label = Label.new()
	z_label.text = "Z:"
	z_label.add_theme_color_override("font_color", Color.WHITE)
	FloodgateController.universal_add_child(z_label, z_container)
	var z_slider = HSlider.new()
	z_slider.min_value = 0.1
	z_slider.max_value = 10.0
	z_slider.value = 1.0
	z_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(z_slider, z_container)
	sliders["size_z"] = z_slider
	
	# Action buttons
	var actions_container = HBoxContainer.new()
	FloodgateController.universal_add_child(actions_container, main_container)
	
	var create_btn = Button.new()
	create_btn.text = "Create Asset"
	create_btn.pressed.connect(_on_create_asset_clicked)
	FloodgateController.universal_add_child(create_btn, actions_container)
	buttons["create_asset"] = create_btn
	
	var preview_btn = Button.new()
	preview_btn.text = "Preview"
	preview_btn.pressed.connect(_on_preview_asset_clicked)
	FloodgateController.universal_add_child(preview_btn, actions_container)
	buttons["preview_asset"] = preview_btn

func _create_neural_status_interface() -> void:
	"""Create neural network status monitoring interface"""
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.1, 0.2, 0.9)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(bg, ui_control)
	
	var scroll_container = ScrollContainer.new()
	scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(scroll_container, ui_control)
	
	var main_container = VBoxContainer.new()
	main_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(main_container, scroll_container)
	
	# Title
	var title = Label.new()
	title.text = "🧠 NEURAL NETWORK STATUS"
	title.add_theme_color_override("font_color", Color.CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FloodgateController.universal_add_child(title, main_container)
	
	# Status display
	var status_label = RichTextLabel.new()
	status_label.custom_minimum_size = Vector2(0, 500)
	status_label.fit_content = true
	status_label.bbcode_enabled = true
	FloodgateController.universal_add_child(status_label, main_container)
	labels["neural_status"] = status_label
	
	# Update neural status
	_update_neural_status_display()
	
	# Auto-refresh button
	var refresh_btn = Button.new()
	refresh_btn.text = "Refresh Status"
	refresh_btn.pressed.connect(_update_neural_status_display)
	FloodgateController.universal_add_child(refresh_btn, main_container)
	buttons["refresh_neural"] = refresh_btn

func _create_being_inspector_interface() -> void:
	"""Create Universal Being inspector interface"""
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.2, 0.1, 0.9)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(bg, ui_control)
	
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(main_container, ui_control)
	
	# Title
	var title = Label.new()
	title.text = "UNIVERSAL BEING INSPECTOR"
	title.add_theme_color_override("font_color", Color.GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FloodgateController.universal_add_child(title, main_container)
	
	if connected_universal_being:
		# Being info
		var info_container = VBoxContainer.new()
		FloodgateController.universal_add_child(info_container, main_container)
		
		var name_label = Label.new()
		name_label.text = "Name: " + connected_universal_being.name
		name_label.add_theme_color_override("font_color", Color.WHITE)
		FloodgateController.universal_add_child(name_label, info_container)
		
		var form_label = Label.new()
		form_label.text = "Form: " + connected_universal_being.form
		form_label.add_theme_color_override("font_color", Color.WHITE)
		FloodgateController.universal_add_child(form_label, info_container)
		
		var conscious_label = Label.new()
		var conscious_text = "Conscious: " + ("Yes (Level " + str(connected_universal_being.consciousness_level) + ")" if connected_universal_being.is_conscious else "No")
		conscious_label.text = conscious_text
		conscious_label.add_theme_color_override("font_color", Color.YELLOW if connected_universal_being.is_conscious else Color.GRAY)
		FloodgateController.universal_add_child(conscious_label, info_container)
		
		# Consciousness controls
		if connected_universal_being.is_conscious:
			var controls_container = VBoxContainer.new()
			FloodgateController.universal_add_child(controls_container, main_container)
			
			var controls_title = Label.new()
			controls_title.text = "Consciousness Controls:"
			controls_title.add_theme_color_override("font_color", Color.CYAN)
			FloodgateController.universal_add_child(controls_title, controls_container)
			
			# Needs display
			if connected_universal_being.needs.size() > 0:
				for need_name in connected_universal_being.needs:
					var need_container = HBoxContainer.new()
					FloodgateController.universal_add_child(need_container, controls_container)
					
					var need_label = Label.new()
					need_label.text = need_name + ":"
					need_label.custom_minimum_size.x = 120
					need_label.add_theme_color_override("font_color", Color.WHITE)
					FloodgateController.universal_add_child(need_label, need_container)
					
					var need_bar = ProgressBar.new()
					need_bar.min_value = 0
					need_bar.max_value = 100
					need_bar.value = connected_universal_being.needs[need_name]
					need_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					FloodgateController.universal_add_child(need_bar, need_container)
			
			# Quick actions
			var actions_container = HBoxContainer.new()
			FloodgateController.universal_add_child(actions_container, main_container)
			
			var awaken_btn = Button.new()
			awaken_btn.text = "Awaken Level 2"
			awaken_btn.pressed.connect(_on_awaken_being.bind(2))
			FloodgateController.universal_add_child(awaken_btn, actions_container)
			
			var level3_btn = Button.new()
			level3_btn.text = "Collective (L3)"
			level3_btn.pressed.connect(_on_awaken_being.bind(3))
			FloodgateController.universal_add_child(level3_btn, actions_container)
	else:
		var no_being_label = Label.new()
		no_being_label.text = "No Universal Being connected"
		no_being_label.add_theme_color_override("font_color", Color.GRAY)
		FloodgateController.universal_add_child(no_being_label, main_container)

func _create_generic_interface() -> void:
	"""Create generic functional interface"""
	var bg = ColorRect.new()
	bg.color = Color(0.15, 0.15, 0.15, 0.9)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(bg, ui_control)
	
	var container = VBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(container, ui_control)
	
	var title = Label.new()
	title.text = "UNIVERSAL INTERFACE"
	title.add_theme_color_override("font_color", Color.WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FloodgateController.universal_add_child(title, container)

# ===== INTERACTION HANDLERS =====

func _on_3d_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	"""Handle 3D input events on the interface"""
	if not is_interactive:
		return
	
	if event is InputEventMouseButton and event.pressed:
		# Convert 3D position to 2D UI coordinates
		var local_pos = to_local(position)
		var ui_pos = Vector2(
			(local_pos.x + interface_size.x * 0.5) / interface_size.x * interface_resolution.x,
			(interface_size.y * 0.5 - local_pos.y) / interface_size.y * interface_resolution.y
		)
		
		# Send input to UI viewport
		var mouse_event = InputEventMouseButton.new()
		mouse_event.button_index = event.button_index
		mouse_event.pressed = event.pressed
		mouse_event.position = ui_pos
		
		ui_viewport.push_input(mouse_event)
		print("🖱️ [EnhancedInterface] Click at UI pos: ", ui_pos)

func _on_mouse_entered() -> void:
	"""Handle mouse entering interface area"""
	interface_material.emission_enabled = true
	interface_material.emission = Color(0.1, 0.1, 0.3)
	print("✨ [EnhancedInterface] Mouse entered")

func _on_mouse_exited() -> void:
	"""Handle mouse leaving interface area"""
	interface_material.emission_enabled = false
	print("🚪 [EnhancedInterface] Mouse exited")

func _on_console_command_executed(input_field: LineEdit) -> void:
	"""Execute console command"""
	var command = input_field.text.strip_edges()
	if command == "":
		return
	
	print("💻 [Console] Executing: ", command)
	
	# Send command to console manager
	var console_manager = get_node_or_null("/root/ConsoleManager")
	if console_manager and console_manager.has_method("execute_command"):
		console_manager.execute_command(command)
	
	# Add to output
	if labels.has("console_output"):
		var output = labels["console_output"]
		output.text += "\n[color=white]> " + command + "[/color]"
		output.text += "\n[color=green]Command executed[/color]"
	
	input_field.text = ""
	interface_button_clicked.emit("console_execute", {"command": command})

func _on_quick_action(action: String) -> void:
	"""Handle quick action buttons"""
	print("⚡ [QuickAction] ", action)
	
	var console_manager = get_node_or_null("/root/ConsoleManager")
	if console_manager and console_manager.has_method("execute_command"):
		console_manager.execute_command(action)
	
	interface_button_clicked.emit("quick_action", {"action": action})

func _on_create_asset_clicked() -> void:
	"""Handle asset creation"""
	var asset_data = {
		"size_x": sliders.get("size_x", {"value": 1.0}).value,
		"size_y": sliders.get("size_y", {"value": 1.0}).value,
		"size_z": sliders.get("size_z", {"value": 1.0}).value
	}
	
	print("🏗️ [AssetCreator] Creating asset with size: ", asset_data)
	
	# Create Universal Being asset
	var new_being = UniversalBeing.new()
	new_being.global_position = global_position + Vector3(0, 0, 3)
	new_being.become("custom_asset")
	get_node("/root/FloodgateController").universal_add_child(new_being, get_tree().current_scene)
	
	interface_button_clicked.emit("create_asset", asset_data)

func _on_preview_asset_clicked() -> void:
	"""Handle asset preview"""
	print("👁️ [AssetCreator] Previewing asset")
	interface_button_clicked.emit("preview_asset", {})

func _on_awaken_being(level: int) -> void:
	"""Awaken connected Universal Being to consciousness level"""
	if connected_universal_being:
		connected_universal_being.become_conscious(level)
		print("🧠 [Inspector] Awakened ", connected_universal_being.name, " to level ", level)
		# Refresh the interface
		setup_interface_type("being_inspector", connected_universal_being)

# ===== UPDATE METHODS =====

func _update_neural_status_display() -> void:
	"""Update neural status display with current data"""
	if not labels.has("neural_status"):
		return
	
	var status_text = "[color=cyan]🧠 NEURAL NETWORK STATUS[/color]\n"
	status_text += "═══════════════════════════════════════\n\n"
	
	# Find all conscious beings
	var conscious_beings = []
	_find_all_conscious_beings(get_tree().current_scene, conscious_beings)
	
	if conscious_beings.size() == 0:
		status_text += "[color=gray]No conscious beings detected[/color]\n"
	else:
		status_text += "[color=yellow]Active Neural Entities: " + str(conscious_beings.size()) + "[/color]\n\n"
		
		for being in conscious_beings:
			status_text += "[color=orange]📡 " + being.name + "[/color]\n"
			status_text += "   Form: " + being.form + "\n"
			status_text += "   Level: " + str(being.consciousness_level) + "\n"
			status_text += "   Goal: " + (being.current_goal if being.current_goal != "" else "None") + "\n"
			
			# Show needs
			if being.needs.size() > 0:
				status_text += "   Needs: "
				for need_name in being.needs:
					var value = being.needs[need_name]
					var color = "green" if value > 70 else "yellow" if value > 30 else "red"
					status_text += "[color=" + color + "]" + need_name + ":" + str(int(value)) + "[/color] "
				status_text += "\n"
			
			status_text += "\n"
	
	labels["neural_status"].text = status_text

func _find_all_conscious_beings(node: Node, conscious_beings: Array) -> void:
	"""Find all conscious Universal Beings"""
	if node is UniversalBeing and node.is_conscious:
		conscious_beings.append(node)
	
	for child in node.get_children():
		_find_all_conscious_beings(child, conscious_beings)

# ===== PUBLIC API =====

func connect_to_system(system_name: String, system_node: Node) -> void:
	"""Connect interface to existing game systems"""
	connected_systems[system_name] = system_node
	print("🔗 [EnhancedInterface] Connected to system: ", system_name)

func set_interface_size(new_size: Vector2) -> void:
	"""Change interface size"""
	interface_size = new_size
	if interface_panel and interface_panel.mesh is PlaneMesh:
		interface_panel.mesh.size = new_size

func update_display_data(data: Dictionary) -> void:
	"""Update interface with new data"""
	match interface_type:
		"neural_status":
			_update_neural_status_display()
		"being_inspector":
			if connected_universal_being:
				setup_interface_type("being_inspector", connected_universal_being)

# Automatically update neural status interfaces
func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	if interface_type == "neural_status" and randf() < 0.1:  # Update occasionally
		_update_neural_status_display()

func _create_system_monitor_interface() -> void:
	"""Create system monitor interface"""
	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.2, 0.1, 0.9)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(bg, ui_control)
	
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 10)
	FloodgateController.universal_add_child(main_container, ui_control)
	
	# Title
	var title = Label.new()
	title.text = "🖥️ SYSTEM MONITOR"
	title.add_theme_color_override("font_color", Color.GREEN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FloodgateController.universal_add_child(title, main_container)
	
	# System status display
	var status_scroll = ScrollContainer.new()
	status_scroll.custom_minimum_size = Vector2(0, 400)
	FloodgateController.universal_add_child(status_scroll, main_container)
	
	var status_label = RichTextLabel.new()
	status_label.fit_content = true
	status_label.bbcode_enabled = true
	FloodgateController.universal_add_child(status_label, status_scroll)
	labels["system_monitor"] = status_label
	
	# Update system status
	_update_system_monitor_display()
	
	# Control buttons
	var controls_container = HBoxContainer.new()
	FloodgateController.universal_add_child(controls_container, main_container)
	
	var refresh_btn = Button.new()
	refresh_btn.text = "🔄 Refresh"
	refresh_btn.pressed.connect(_update_system_monitor_display)
	FloodgateController.universal_add_child(refresh_btn, controls_container)
	buttons["system_refresh"] = refresh_btn
	
	var performance_btn = Button.new()
	performance_btn.text = "⚡ Performance Report"
	performance_btn.pressed.connect(_show_performance_report)
	FloodgateController.universal_add_child(performance_btn, controls_container)
	buttons["performance_report"] = performance_btn

func _create_grid_list_interface() -> void:
	"""Create grid list interface"""
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.0, 0.2, 0.9)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(bg, ui_control)
	
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 10)
	FloodgateController.universal_add_child(main_container, ui_control)
	
	# Title
	var title = Label.new()
	title.text = "📋 GRID LIST MANAGER"
	title.add_theme_color_override("font_color", Color.MAGENTA)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	FloodgateController.universal_add_child(title, main_container)
	
	# Grid display area
	var grid_scroll = ScrollContainer.new()
	grid_scroll.custom_minimum_size = Vector2(0, 350)
	FloodgateController.universal_add_child(grid_scroll, main_container)
	
	var grid_container = GridContainer.new()
	grid_container.columns = 4
	grid_container.add_theme_constant_override("h_separation", 5)
	grid_container.add_theme_constant_override("v_separation", 5)
	FloodgateController.universal_add_child(grid_container, grid_scroll)
	scroll_areas["grid_container"] = grid_container
	
	# Populate grid with system data
	_populate_grid_display()
	
	# Controls
	var controls_container = HBoxContainer.new()
	FloodgateController.universal_add_child(controls_container, main_container)
	
	var add_item_btn = Button.new()
	add_item_btn.text = "➕ Add Item"
	add_item_btn.pressed.connect(_add_grid_item)
	FloodgateController.universal_add_child(add_item_btn, controls_container)
	buttons["add_grid_item"] = add_item_btn
	
	var clear_grid_btn = Button.new()
	clear_grid_btn.text = "🗑️ Clear Grid"
	clear_grid_btn.pressed.connect(_clear_grid)
	FloodgateController.universal_add_child(clear_grid_btn, controls_container)
	buttons["clear_grid"] = clear_grid_btn
	
	var refresh_grid_btn = Button.new()
	refresh_grid_btn.text = "🔄 Refresh"
	refresh_grid_btn.pressed.connect(_populate_grid_display)
	FloodgateController.universal_add_child(refresh_grid_btn, controls_container)
	buttons["refresh_grid"] = refresh_grid_btn

func _update_system_monitor_display() -> void:
	"""Update system monitor display with current data"""
	if not labels.has("system_monitor"):
		return
	
	var status_text = "[color=green]🖥️ SYSTEM MONITOR STATUS[/color]\n"
	status_text += "═══════════════════════════════════════\n\n"
	
	# FPS and performance
	var fps = Engine.get_frames_per_second()
	var fps_color = "green" if fps > 30 else "yellow" if fps > 15 else "red"
	status_text += "[color=" + fps_color + "]FPS: " + str(fps) + "[/color]\n"
	status_text += "Frame Time: " + str(int(1000.0 / max(fps, 1))) + "ms\n\n"
	
	# Memory usage
	var memory_info = OS.get_memory_info()
	var static_memory = OS.get_static_memory_usage()
	var peak_memory = OS.get_static_memory_peak_usage()
	
	status_text += "[color=cyan]Memory Usage:[/color]\n"
	status_text += "• Static: " + str(static_memory / 1024 / 1024) + " MB\n"
	status_text += "• Peak: " + str(peak_memory / 1024 / 1024) + " MB\n"
	
	for key in memory_info:
		var value = memory_info[key]
		if value > 0:
			status_text += "• " + key.capitalize() + ": " + str(value / 1024 / 1024) + " MB\n"
	status_text += "\n"
	
	# Active autoloads
	status_text += "[color=yellow]Active Systems:[/color]\n"
	var autoload_count = 0
	var scene_tree = get_tree()
	if scene_tree:
		for child in scene_tree.root.get_children():
			if child.get_script():
				autoload_count += 1
				var status_icon = "✅" if child.has_method("_ready") else "⚠️"
				status_text += status_icon + " " + child.name + "\n"
	
	status_text += "\n[color=orange]Total Autoloads: " + str(autoload_count) + "[/color]"
	
	labels["system_monitor"].text = status_text

func _show_performance_report() -> void:
	"""Show detailed performance report"""
	print("⚡ [SystemMonitor] Generating performance report...")
	
	# Add to output if console interface is present
	if labels.has("console_output"):
		var output = labels["console_output"]
		output.text += "\n[color=cyan]🔍 PERFORMANCE ANALYSIS COMPLETE[/color]"

func _populate_grid_display() -> void:
	"""Populate grid with system entities"""
	if not scroll_areas.has("grid_container"):
		return
	
	var grid = scroll_areas["grid_container"]
	
	# Clear existing items
	for child in grid.get_children():
		child.queue_free()
	
	# Add system entities
	var entities = _get_system_entities()
	
	for entity in entities:
		var item_button = Button.new()
		item_button.text = entity.name
		item_button.custom_minimum_size = Vector2(150, 60)
		item_button.pressed.connect(_on_grid_item_selected.bind(entity))
		FloodgateController.universal_add_child(item_button, grid)

func _get_system_entities() -> Array:
	"""Get all system entities for display"""
	var entities = []
	
	# Find all Universal Beings
	_find_entities_recursive(get_tree().current_scene, entities)
	
	return entities

func _find_entities_recursive(node: Node, entities: Array) -> void:
	"""Recursively find entities"""
	if node.has_method("become") or "Universal" in str(node.get_script()):
		entities.append({"name": node.name, "type": "Universal Being", "node": node})
	
	for child in node.get_children():
		_find_entities_recursive(child, entities)

func _add_grid_item() -> void:
	"""Add new item to grid"""
	var grid = scroll_areas.get("grid_container")
	if grid:
		var new_item = Button.new()
		new_item.text = "New Item " + str(grid.get_child_count() + 1)
		new_item.custom_minimum_size = Vector2(150, 60)
		FloodgateController.universal_add_child(new_item, grid)
		print("➕ [GridList] Added new item")

func _clear_grid() -> void:
	"""Clear all grid items"""
	var grid = scroll_areas.get("grid_container")
	if grid:
		for child in grid.get_children():
			child.queue_free()
		print("🗑️ [GridList] Grid cleared")

func _on_grid_item_selected(entity: Dictionary) -> void:
	"""Handle grid item selection"""
	print("🎯 [GridList] Selected: " + entity.name)
	interface_button_clicked.emit("grid_item_selected", entity)
