# res://scenes/test/test_consciousness_icons.gd
# res://scenes/test/test_consciousness_icons.tscn
# Main node named as "TestConsciousnessIcons" with script attached "test_consciousness_icons.gd"
# TestConsciousnessIcons

# Create a simple test scene to see all your icons
# Save as: test_consciousness_icons.tscn
#extends Control
#
#func _ready():
	#var grid = GridContainer.new()
	#grid.columns = 4
	#
	#for i in 8:
		#var tex = TextureRect.new()
		#tex.texture = load("res://assets/icons/consciousness/level_%d.png" % i)
		#tex.custom_minimum_size = Vector2(64, 64)  # Show them bigger
		#grid.add_child(tex)
	#
	#add_child(grid)


# res://scenes/test/test_consciousness_icons.gd
extends Control

# Icon display settings
@export var icon_scale: float = 2.0  # Show icons at 2x size
@export var spacing: int = 80
@export var show_labels: bool = true
@export var animate_icons: bool = true

var grid: GridContainer
var icon_nodes: Array[TextureRect] = []

func _ready():
	# Set background color
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.1)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)
	
	# Create title
	var title = Label.new()
	title.text = "Consciousness Level Icons"
	title.add_theme_font_size_override("font_size", 24)
	title.position = Vector2(20, 20)
	add_child(title)
	
	# Create grid container
	grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", spacing)
	grid.add_theme_constant_override("v_separation", spacing)
	grid.position = Vector2(50, 80)
	add_child(grid)
	
	# Load and display all icons
	for i in 8:
		create_icon_display(i)
	
	# Add test controls
	create_test_controls()

func create_icon_display(level: int) -> void:
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 10)
	
	# Icon holder with background
	var icon_bg = Panel.new()
	icon_bg.custom_minimum_size = Vector2(64, 64) * icon_scale
	
	# Apply consciousness color to background
	var style = StyleBoxFlat.new()
	style.bg_color = get_consciousness_bg_color(level)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	icon_bg.add_theme_stylebox_override("panel", style)
	
	# Icon
	var icon = TextureRect.new()
	var texture_path = "res://assets/icons/consciousness/level_%d.png" % level
	icon.texture = load(texture_path)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(32, 32) * icon_scale
	icon.position = Vector2(16, 16) * icon_scale - Vector2(16, 16)
	icon_bg.add_child(icon)
	
	container.add_child(icon_bg)
	icon_nodes.append(icon)
	
	if show_labels:
		# Level number
		var level_label = Label.new()
		level_label.text = "Level %d" % level
		level_label.add_theme_font_size_override("font_size", 16)
		level_label.modulate = get_consciousness_color(level)
		container.add_child(level_label)
		
		# Level name
		var name_label = Label.new()
		name_label.text = get_consciousness_name(level)
		name_label.add_theme_font_size_override("font_size", 12)
		container.add_child(name_label)
	
	grid.add_child(container)
	
	# Add hover effect
	if animate_icons:
		setup_hover_effect(icon_bg, icon, level)

func setup_hover_effect(bg: Panel, icon: TextureRect, level: int) -> void:
	bg.gui_input.connect(func(event):
		if event is InputEventMouseMotion:
			# Scale up on hover
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_ELASTIC)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(icon, "scale", Vector2(1.2, 1.2), 0.3)
			
			# Add glow
			icon.modulate = Color(1.2, 1.2, 1.2)
		elif event is InputEventMouseButton and event.pressed:
			print("Clicked consciousness level %d: %s" % [level, get_consciousness_name(level)])
			flash_icon(icon, level)
	)
	
	bg.mouse_exited.connect(func():
		# Scale back down
		var tween = create_tween()
		tween.tween_property(icon, "scale", Vector2.ONE, 0.2)
		icon.modulate = Color.WHITE
	)

func flash_icon(icon: TextureRect, level: int) -> void:
	var color = get_consciousness_color(level)
	var tween = create_tween()
	tween.tween_property(icon, "modulate", color * 2.0, 0.1)
	tween.tween_property(icon, "modulate", Color.WHITE, 0.3)

func create_test_controls() -> void:
	var controls = VBoxContainer.new()
	controls.position = Vector2(20, 400)
	add_child(controls)
	
	# Animate all button
	var animate_btn = Button.new()
	animate_btn.text = "Animate All Icons"
	animate_btn.pressed.connect(animate_all_icons)
	controls.add_child(animate_btn)
	
	# Cycle consciousness button
	var cycle_btn = Button.new()
	cycle_btn.text = "Cycle Through Levels"
	cycle_btn.pressed.connect(cycle_consciousness)
	controls.add_child(cycle_btn)
	
	# Scale slider
	var scale_label = Label.new()
	scale_label.text = "Icon Scale:"
	controls.add_child(scale_label)
	
	var scale_slider = HSlider.new()
	scale_slider.min_value = 0.5
	scale_slider.max_value = 4.0
	scale_slider.value = icon_scale
	scale_slider.custom_minimum_size.x = 200
	scale_slider.value_changed.connect(func(value):
		icon_scale = value
		# Recreate display with new scale
		for child in grid.get_children():
			child.queue_free()
		icon_nodes.clear()
		for i in 8:
			create_icon_display(i)
	)
	controls.add_child(scale_slider)

func animate_all_icons() -> void:
	for i in icon_nodes.size():
		var icon = icon_nodes[i]
		var delay = i * 0.1
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BOUNCE)
		
		# Bounce effect
		tween.tween_property(icon, "position:y", icon.position.y - 20, 0.3).set_delay(delay)
		tween.tween_property(icon, "position:y", icon.position.y, 0.3)
		
		# Rotate
		tween.parallel().tween_property(icon, "rotation", TAU, 1.0).set_delay(delay)

func cycle_consciousness() -> void:
	var highlight_duration = 0.5
	
	for i in 8:
		var icon = icon_nodes[i]
		var delay = i * highlight_duration
		
		var tween = create_tween()
		tween.tween_callback(func():
			flash_icon(icon, i)
			print("Consciousness Level %d: %s" % [i, get_consciousness_name(i)])
		).set_delay(delay)

func get_consciousness_name(level: int) -> String:
	var names = [
		"Dormant",
		"Awakening",
		"Aware",
		"Conscious",
		"Enlightened",
		"Transcendent",
		"Cosmic",
		"Beyond"
	]
	return names[clamp(level, 0, names.size() - 1)]

func get_consciousness_color(level: int) -> Color:
	var colors = [
		Color(0.5, 0.5, 0.5),   # Gray
		Color(0.9, 0.9, 0.9),   # Light gray
		Color(0.2, 0.4, 1.0),   # Blue
		Color(0.2, 1.0, 0.2),   # Green
		Color(1.0, 0.84, 0.0),  # Gold
		Color(1.0, 1.0, 1.0),   # White
		Color(1.0, 0.2, 0.2),   # Red
		Color(1.0, 0.5, 0.0)    # Orange/Rainbow
	]
	return colors[clamp(level, 0, colors.size() - 1)]

func get_consciousness_bg_color(level: int) -> Color:
	var color = get_consciousness_color(level)
	color.a = 0.2  # Transparent background
	return color

func _input(event: InputEvent) -> void:
	# Test keyboard shortcuts
	if event.is_action_pressed("ui_accept"):  # Enter
		animate_all_icons()
	elif event.is_action_pressed("ui_select"):  # Space
		cycle_consciousness()
	
	# Number keys to highlight specific level
	for i in 8:
		if event.is_action_pressed("key_%d" % i):
			if i < icon_nodes.size():
				flash_icon(icon_nodes[i], i)
				print("Selected Level %d: %s" % [i, get_consciousness_name(i)])
