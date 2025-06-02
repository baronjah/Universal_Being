# ==================================================
# SCRIPT NAME: LayerDebugOverlay.gd
# DESCRIPTION: Visual debug overlay for Universal Being layer system
# PURPOSE: Display real-time layer information for all beings in the scene
# CREATED: 2025-06-03 - Layer System Evolution
# AUTHOR: Claude Code
# ==================================================

extends CanvasLayer
class_name LayerDebugOverlay

# UI References
var debug_panel: Panel
var layer_list: RichTextLabel
var toggle_button: Button
var update_timer: Timer

# Debug state
var debug_visible: bool = false
var auto_update: bool = true
var update_interval: float = 0.5

# Visual settings
var panel_transparency: float = 0.8
var text_color_by_layer: Dictionary = {
	0: Color.GRAY,
	1: Color.WHITE,
	2: Color.CYAN,
	3: Color.GREEN,
	4: Color.YELLOW,
	5: Color.MAGENTA,
	6: Color.RED,
	7: Color.WHITE
}

func _ready() -> void:
	"""Initialize the layer debug overlay"""
	name = "LayerDebugOverlay"
	layer = 100  # High layer to ensure it's on top
	
	# Create UI structure
	_create_ui()
	
	# Setup update timer
	update_timer = Timer.new()
	update_timer.wait_time = update_interval
	update_timer.timeout.connect(_update_layer_display)
	add_child(update_timer)
	
	# Start hidden
	debug_panel.visible = false
	
	print("🔍 Layer Debug Overlay initialized - Press F9 to toggle")

func _create_ui() -> void:
	"""Create the debug UI structure"""
	# Main panel
	debug_panel = Panel.new()
	debug_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	debug_panel.position = Vector2(get_viewport().size.x - 350, 50)
	debug_panel.size = Vector2(300, 400)
	debug_panel.modulate.a = panel_transparency
	add_child(debug_panel)
	
	# Title label
	var title = Label.new()
	title.text = "🔍 Layer Debug"
	title.position = Vector2(10, 10)
	title.add_theme_font_size_override("font_size", 18)
	debug_panel.add_child(title)
	
	# Toggle button
	toggle_button = Button.new()
	toggle_button.text = "Auto Update: ON"
	toggle_button.position = Vector2(150, 10)
	toggle_button.size = Vector2(140, 30)
	toggle_button.pressed.connect(_toggle_auto_update)
	debug_panel.add_child(toggle_button)
	
	# Layer list
	layer_list = RichTextLabel.new()
	layer_list.position = Vector2(10, 50)
	layer_list.size = Vector2(280, 340)
	layer_list.bbcode_enabled = true
	layer_list.fit_content = true
	debug_panel.add_child(layer_list)
	
	# Manual refresh button
	var refresh_button = Button.new()
	refresh_button.text = "Refresh Now"
	refresh_button.position = Vector2(10, 360)
	refresh_button.size = Vector2(100, 30)
	refresh_button.pressed.connect(_update_layer_display)
	debug_panel.add_child(refresh_button)

func _input(event: InputEvent) -> void:
	"""Handle input for toggling the overlay"""
	if event.is_action_pressed("toggle_layer_debug"):  # F9
		toggle_visibility()

func toggle_visibility() -> void:
	"""Toggle the debug overlay visibility"""
	debug_visible = !debug_visible
	debug_panel.visible = debug_visible
	
	if debug_visible and auto_update:
		update_timer.start()
		_update_layer_display()
	else:
		update_timer.stop()
	
	print("🔍 Layer Debug Overlay: %s" % ("Visible" if debug_visible else "Hidden"))

func _toggle_auto_update() -> void:
	"""Toggle automatic updates"""
	auto_update = !auto_update
	toggle_button.text = "Auto Update: %s" % ("ON" if auto_update else "OFF")
	
	if auto_update and debug_visible:
		update_timer.start()
	else:
		update_timer.stop()

func _update_layer_display() -> void:
	"""Update the layer display with current being information"""
	if not debug_visible:
		return
	
	# Collect all Universal Beings
	var beings = _collect_all_beings()
	
	# Sort by layer (highest first)
	beings.sort_custom(func(a, b): 
		var layer_a = a.get_visual_layer() if a.has_method("get_visual_layer") else 0
		var layer_b = b.get_visual_layer() if b.has_method("get_visual_layer") else 0
		return layer_a > layer_b
	)
	
	# Build display text
	var bbcode_text = "[b]Universal Beings by Layer:[/b]\n\n"
	
	var current_layer = -1
	for being in beings:
		if not being.has_method("get_visual_layer"):
			continue
			
		var layer = being.get_visual_layer()
		var being_name = being.being_name if "being_name" in being else being.name
		var being_type = being.being_type if "being_type" in being else "unknown"
		var consciousness = being.consciousness_level if "consciousness_level" in being else 0
		
		# Add layer header if new layer
		if layer != current_layer:
			current_layer = layer
			var layer_color = text_color_by_layer.get(layer, Color.WHITE)
			bbcode_text += "\n[color=#%s][b]Layer %d:[/b][/color]\n" % [layer_color.to_html(false), layer]
		
		# Add being info
		var consciousness_icon = _get_consciousness_icon(consciousness)
		bbcode_text += "  %s %s (%s)\n" % [consciousness_icon, being_name, being_type]
		
		# Add position info for 3D beings
		if being is Node3D:
			bbcode_text += "    Pos: (%.2f, %.2f, %.2f)\n" % [being.position.x, being.position.y, being.position.z]
	
	# Add summary
	bbcode_text += "\n[b]Total Beings:[/b] %d" % beings.size()
	
	# Update display
	layer_list.clear()
	layer_list.append_text(bbcode_text)

func _collect_all_beings() -> Array:
	"""Collect all Universal Beings in the scene"""
	var beings = []
	
	# Use FloodGates if available
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("get_all_beings"):
			return flood_gates.get_all_beings()
	
	# Fallback: recursive search
	_collect_beings_recursive(get_tree().root, beings)
	return beings

func _collect_beings_recursive(node: Node, beings: Array) -> void:
	"""Recursively collect all beings with get_visual_layer method"""
	if node.has_method("get_visual_layer"):
		beings.append(node)
	
	for child in node.get_children():
		_collect_beings_recursive(child, beings)

func _get_consciousness_icon(level: int) -> String:
	"""Get an icon representing consciousness level"""
	match level:
		0: return "⚫"  # Dormant
		1: return "⚪"  # Awakening
		2: return "🔵"  # Aware
		3: return "🟢"  # Connected
		4: return "🟡"  # Enlightened
		5: return "🟣"  # Transcendent
		6: return "🔴"  # Beyond
		7: return "✨"  # Ultimate
		_: return "❓"  # Unknown
