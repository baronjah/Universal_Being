# ==================================================
# SCRIPT NAME: UniverseSimulator.gd
# DESCRIPTION: Visual Universe Simulator for recursive reality creation
# PURPOSE: Provide interactive 3D visualization of infinite nested universes
# CREATED: 2025-06-03 - Universal Being Evolution
# ==================================================

extends Control

# ===== UNIVERSE SIMULATOR - THE INFINITE CANVAS =====

# Visual style constants
const UNIVERSE_SPHERE_SIZE = 100.0
const UNIVERSE_COLORS = [
	Color(0.2, 0.4, 0.8, 0.8),  # Blue cosmos
	Color(0.8, 0.2, 0.8, 0.8),  # Purple void
	Color(0.2, 0.8, 0.4, 0.8),  # Green life
	Color(0.8, 0.8, 0.2, 0.8),  # Golden consciousness
	Color(0.8, 0.2, 0.2, 0.8),  # Red energy
	Color(0.2, 0.8, 0.8, 0.8),  # Cyan dream
]

# References
var viewport: SubViewport
var camera: Camera3D
var universe_root: Node3D
var info_panel: Panel
var creation_panel: Panel
var selected_universe: Node3D = null
var universe_representations: Dictionary = {}  # universe_being -> visual_node

# Camera controls
var camera_rotation = Vector2(0, 0)
var camera_distance = 500.0
var is_dragging = false

# Genesis state
var universe_count = 0
func _ready():
	name = "UniverseSimulator"
	custom_minimum_size = Vector2(1200, 800)
	
	# Build UI structure
	_create_ui()
	_setup_3d_viewport()
	_create_info_panel()
	_create_creation_panel()
	
	# Initialize universe discovery
	_discover_existing_universes()
	
	# Log genesis moment
	_log_genesis("🌌 Universe Simulator awakened - the infinite canvas unfolds...")

func _create_ui():
	"""Create the main UI layout"""
	var main_container = HSplitContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.split_offset = 900
	add_child(main_container)
	
	# Left: 3D Viewport
	var viewport_container = SubViewportContainer.new()
	viewport_container.stretch = true
	main_container.add_child(viewport_container)
	
	viewport = SubViewport.new()
	viewport.size = Vector2(900, 800)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(viewport)
	
	# Right: Control panels
	var right_panel = VBoxContainer.new()
	right_panel.custom_minimum_size = Vector2(300, 0)
	main_container.add_child(right_panel)
	
	info_panel = Panel.new()
	info_panel.custom_minimum_size = Vector2(0, 400)
	right_panel.add_child(info_panel)
	
	creation_panel = Panel.new()
	creation_panel.custom_minimum_size = Vector2(0, 400)
	right_panel.add_child(creation_panel)

func _setup_3d_viewport():
	"""Setup the 3D visualization space"""
	# Root for universes
	universe_root = Node3D.new()
	universe_root.name = "UniverseRoot"
	viewport.add_child(universe_root)
	
	# Camera
	camera = Camera3D.new()
	camera.position = Vector3(0, 0, camera_distance)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	camera.fov = 60
	viewport.add_child(camera)
	
	# Ambient light
	var ambient_light = DirectionalLight3D.new()
	ambient_light.rotation_degrees = Vector3(-45, -45, 0)
	ambient_light.light_energy = 0.5
	viewport.add_child(ambient_light)
	
	# Environment
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.05, 0.1)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.1, 0.1, 0.2)
	env.ambient_light_energy = 0.3
	
	camera.environment = env
func _create_info_panel():
	"""Create the universe information panel"""
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	info_panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "🌌 Universe Inspector"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)
	
	# Info display
	var info_text = RichTextLabel.new()
	info_text.name = "InfoText"
	info_text.bbcode_enabled = true
	info_text.fit_content = true
	info_text.text = "[i]Select a universe to inspect...[/i]"
	vbox.add_child(info_text)

func _create_creation_panel():
	"""Create the universe creation panel"""
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	creation_panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "✨ Universe Genesis"
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)
	
	# Create button
	var create_btn = Button.new()
	create_btn.text = "Birth New Universe"
	create_btn.pressed.connect(_on_create_universe_pressed)
	vbox.add_child(create_btn)
	
	# Template selector
	var template_label = Label.new()
	template_label.text = "Universe Template:"
	vbox.add_child(template_label)
	
	var template_option = OptionButton.new()
	template_option.name = "TemplateOption"
	template_option.add_item("Empty Void")
	template_option.add_item("Physics Sandbox")
	template_option.add_item("Narrative Realm")
	template_option.add_item("Quantum Paradise")
	template_option.add_item("Consciousness Garden")
	vbox.add_child(template_option)
	# Nested universe option
	var nested_check = CheckBox.new()
	nested_check.name = "NestedCheck"
	nested_check.text = "Create Inside Selected Universe"
	vbox.add_child(nested_check)
	
	# Physics controls
	var physics_label = Label.new()
	physics_label.text = "Physics Scale:"
	vbox.add_child(physics_label)
	
	var physics_slider = HSlider.new()
	physics_slider.name = "PhysicsSlider"
	physics_slider.min_value = 0.1
	physics_slider.max_value = 10.0
	physics_slider.value = 1.0
	physics_slider.step = 0.1
	vbox.add_child(physics_slider)
	
	# Time controls
	var time_label = Label.new()
	time_label.text = "Time Dilation:"
	vbox.add_child(time_label)
	
	var time_slider = HSlider.new()
	time_slider.name = "TimeSlider"
	time_slider.min_value = 0.1
	time_slider.max_value = 10.0
	time_slider.value = 1.0
	time_slider.step = 0.1
	vbox.add_child(time_slider)

func _discover_existing_universes():
	"""Find all existing universes in the scene"""
	var main = get_node_or_null("/root/Main")
	if not main:
		return
	
	for being in main.demo_beings:
		if being.has_method("get") and being.get("being_type") == "universe":
			_add_universe_visualization(being)
func _add_universe_visualization(universe_being: Node):
	"""Add a visual representation of a universe"""
	# Create sphere mesh
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radial_segments = 32
	sphere_mesh.height_segments = 16
	sphere_mesh.radius = UNIVERSE_SPHERE_SIZE
	sphere_mesh.height = UNIVERSE_SPHERE_SIZE * 2
	mesh_instance.mesh = sphere_mesh
	
	# Create material with universe color
	var material = StandardMaterial3D.new()
	material.albedo_color = UNIVERSE_COLORS[universe_count % UNIVERSE_COLORS.size()]
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_energy = 0.3
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.set_surface_override_material(0, material)
	
	# Position in space
	var angle = (universe_count * TAU) / 6.0
	var radius = 200.0 + (universe_count * 50.0)
	mesh_instance.position = Vector3(
		cos(angle) * radius,
		sin(universe_count * 0.5) * 100.0,
		sin(angle) * radius
	)
	
	# Add to scene
	universe_root.add_child(mesh_instance)
	universe_representations[universe_being] = mesh_instance
	
	# Add interaction
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = UNIVERSE_SPHERE_SIZE
	collision.shape = shape
	area.add_child(collision)
	mesh_instance.add_child(area)
	
	area.input_event.connect(_on_universe_clicked.bind(universe_being))
	area.mouse_entered.connect(_on_universe_hover_entered.bind(universe_being))
	area.mouse_exited.connect(_on_universe_hover_exited.bind(universe_being))
	
	universe_count += 1
	
	# Animate entrance
	_animate_universe_birth(mesh_instance)
func _animate_universe_birth(universe_node: Node3D):
	"""Animate a universe coming into existence"""
	universe_node.scale = Vector3.ZERO
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(universe_node, "scale", Vector3.ONE, 1.5)
	
	# Pulse effect
	tween.tween_property(universe_node, "scale", Vector3.ONE * 1.1, 0.3)
	tween.tween_property(universe_node, "scale", Vector3.ONE, 0.3)

func _on_universe_clicked(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int, universe_being: Node):
	"""Handle universe selection"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_universe(universe_being)

func _on_universe_hover_entered(universe_being: Node):
	"""Handle hover enter"""
	if universe_being in universe_representations:
		var mesh = universe_representations[universe_being]
		var tween = get_tree().create_tween()
		tween.tween_property(mesh, "scale", Vector3.ONE * 1.2, 0.2)

func _on_universe_hover_exited(universe_being: Node):
	"""Handle hover exit"""
	if universe_being in universe_representations:
		var mesh = universe_representations[universe_being]
		var tween = get_tree().create_tween()
		tween.tween_property(mesh, "scale", Vector3.ONE, 0.2)

func _select_universe(universe_being: Node):
	"""Select and inspect a universe"""
	selected_universe = universe_being
	_update_info_panel(universe_being)
	
	# Visual selection feedback
	for being in universe_representations:
		var mesh = universe_representations[being]
		var material = mesh.get_surface_override_material(0)
		if being == universe_being:
			material.emission_energy = 0.8
			material.rim_enabled = true
			material.rim = 1.0
			material.rim_tint = 0.5
		else:
			material.emission_energy = 0.3
			material.rim_enabled = false
func _update_info_panel(universe_being: Node):
	"""Update the info panel with universe details"""
	var info_text = info_panel.get_node("VBoxContainer/InfoText")
	if not info_text:
		return
	
	var universe_name = universe_being.get("universe_name") if universe_being.has_method("get") else "Unknown"
	var physics_scale = universe_being.get("physics_scale") if universe_being.has_method("get") else 1.0
	var time_scale = universe_being.get("time_scale") if universe_being.has_method("get") else 1.0
	var being_count = universe_being.get_child_count() if universe_being.has_method("get_child_count") else 0
	
	info_text.text = "[b]Universe: %s[/b]\n\n" % universe_name
	info_text.text += "[color=cyan]Physics Scale:[/color] %.1fx\n" % physics_scale
	info_text.text += "[color=yellow]Time Dilation:[/color] %.1fx\n" % time_scale
	info_text.text += "[color=green]Beings:[/color] %d\n" % being_count
	info_text.text += "\n[i]Double-click to enter universe[/i]"

func _on_create_universe_pressed():
	"""Handle universe creation button"""
	var template_option = creation_panel.get_node("VBoxContainer/TemplateOption")
	var nested_check = creation_panel.get_node("VBoxContainer/NestedCheck")
	var physics_slider = creation_panel.get_node("VBoxContainer/PhysicsSlider")
	var time_slider = creation_panel.get_node("VBoxContainer/TimeSlider")
	
	var template = ["empty", "sandbox", "narrative", "quantum", "consciousness"][template_option.selected]
	var is_nested = nested_check.button_pressed and selected_universe != null
	
	# Get main node
	var main = get_node_or_null("/root/Main")
	if not main or not main.has_method("create_universe_universal_being"):
		push_error("Cannot access Main node for universe creation")
		return
	
	# Create universe through main
	var new_universe = main.create_universe_universal_being()
	if new_universe:
		# Configure universe
		if new_universe.has_method("set"):
			new_universe.set("physics_scale", physics_slider.value)
			new_universe.set("time_scale", time_slider.value)
			new_universe.set("universe_template", template)
		
		# Add visualization
		_add_universe_visualization(new_universe)
		
		# Log genesis
		_log_genesis("✨ Universe '%s' born from the void with template '%s'" % [
			new_universe.get("universe_name"),
			template
		])
func _input(event: InputEvent):
	"""Handle input for camera controls"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = max(100, camera_distance - 50)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = min(2000, camera_distance + 50)
			_update_camera()
	
	elif event is InputEventMouseMotion and is_dragging:
		camera_rotation.x -= event.relative.y * 0.01
		camera_rotation.y -= event.relative.x * 0.01
		camera_rotation.x = clamp(camera_rotation.x, -PI/2, PI/2)
		_update_camera()

func _update_camera():
	"""Update camera position based on rotation and distance"""
	var x = sin(camera_rotation.y) * cos(camera_rotation.x) * camera_distance
	var y = sin(camera_rotation.x) * camera_distance
	var z = cos(camera_rotation.y) * cos(camera_rotation.x) * camera_distance
	
	camera.position = Vector3(x, y, z)
	camera.look_at(Vector3.ZERO, Vector3.UP)

func _log_genesis(message: String):
	"""Log genesis events in poetic style"""
	print("🌌 GENESIS: " + message)
	
	# Try to log to Akashic Library
	var bootstrap = get_node_or_null("/root/SystemBootstrap")
	if bootstrap and bootstrap.has_method("get_akashic_library"):
		var akashic = bootstrap.get_akashic_library()
		if akashic and akashic.has_method("log_universe_event"):
			akashic.log_universe_event("simulator", message, {
				"timestamp": Time.get_unix_time_from_system(),
				"universe_count": universe_count
			})
