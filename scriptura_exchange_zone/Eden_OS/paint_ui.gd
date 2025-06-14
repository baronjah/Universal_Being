extends Control

class_name PaintUI

# References to systems
var paint_system: PaintSystem
var shape_system: ShapeSystem
var dimensional_color_system: DimensionalColorSystem
var turn_cycle_manager: TurnCycleManager

# UI elements - to be assigned in the scene
@onready var paint_canvas = $PaintCanvas
@onready var brush_tools_panel = $BrushToolsPanel
@onready var brush_size_slider = $BrushToolsPanel/VBoxContainer/BrushSizeSlider
@onready var brush_opacity_slider = $BrushToolsPanel/VBoxContainer/BrushOpacitySlider
@onready var brush_hardness_slider = $BrushToolsPanel/VBoxContainer/BrushHardnessSlider
@onready var brush_type_selector = $BrushToolsPanel/VBoxContainer/BrushTypeSelector
@onready var dimension_selector = $BrushToolsPanel/VBoxContainer/DimensionSelector
@onready var color_picker = $BrushToolsPanel/VBoxContainer/ColorPicker
@onready var shape_list = $ShapePanel/ShapeList
@onready var layer_list = $LayerPanel/LayerList
@onready var texture_preview = $TexturePanel/TexturePreview

# Mode selection
var painting_mode: bool = true
var shape_paint_mode: bool = false
var selected_shape_id: String = ""
var selected_texture_id: String = ""

func _ready():
	# Get references to systems
	paint_system = get_node_or_null("/root/PaintSystem")
	if not paint_system:
		paint_system = PaintSystem.new()
		add_child(paint_system)
	
	shape_system = get_node_or_null("/root/ShapeSystem")
	dimensional_color_system = get_node_or_null("/root/DimensionalColorSystem")
	turn_cycle_manager = get_node_or_null("/root/TurnCycleManager")
	
	# Connect signals
	paint_canvas.brush_changed.connect(_on_brush_changed)
	paint_canvas.stroke_completed.connect(_on_stroke_completed)
	
	if turn_cycle_manager:
		turn_cycle_manager.turn_completed.connect(_on_turn_completed)
	
	# Set up UI
	_setup_ui()
	
	# Initial UI update
	_update_brush_ui()
	_populate_shape_list()
	_populate_texture_list()

func _setup_ui():
	# Set up brush type selector
	brush_type_selector.clear()
	brush_type_selector.add_item("Brush", PaintSystem.StrokeType.BRUSH)
	brush_type_selector.add_item("Water", PaintSystem.StrokeType.WATER)
	brush_type_selector.add_item("Glow", PaintSystem.StrokeType.GLOW)
	brush_type_selector.add_item("Particle", PaintSystem.StrokeType.PARTICLE)
	brush_type_selector.add_item("Dimensional", PaintSystem.StrokeType.DIMENSIONAL)
	brush_type_selector.add_item("Pattern", PaintSystem.StrokeType.PATTERN)
	
	# Set up dimension selector
	dimension_selector.clear()
	for i in range(1, 10):
		var dimension_name = ""
		match i:
			1: dimension_name = "Foundation (AZURE)"
			2: dimension_name = "Growth (EMERALD)"
			3: dimension_name = "Energy (AMBER)"
			4: dimension_name = "Insight (VIOLET)"
			5: dimension_name = "Force (CRIMSON)"
			6: dimension_name = "Vision (INDIGO)"
			7: dimension_name = "Wisdom (SAPPHIRE)"
			8: dimension_name = "Transcendence (GOLD)"
			9: dimension_name = "Unity (SILVER)"
		
		dimension_selector.add_item(dimension_name, i)
	
	# Set initial sliders
	brush_size_slider.value = paint_system.current_brush_settings.size
	brush_opacity_slider.value = paint_system.current_brush_settings.opacity
	brush_hardness_slider.value = paint_system.current_brush_settings.hardness
	
	# Set initial brush type
	for i in range(brush_type_selector.get_item_count()):
		if brush_type_selector.get_item_id(i) == paint_system.current_brush_settings.stroke_type:
			brush_type_selector.select(i)
			break
	
	# Set initial dimension
	for i in range(dimension_selector.get_item_count()):
		if dimension_selector.get_item_id(i) == paint_system.current_brush_settings.dimension:
			dimension_selector.select(i)
			break
	
	# Set initial color
	color_picker.color = paint_system.current_brush_settings.color
	
	# Connect UI signals
	brush_size_slider.value_changed.connect(_on_brush_size_changed)
	brush_opacity_slider.value_changed.connect(_on_brush_opacity_changed)
	brush_hardness_slider.value_changed.connect(_on_brush_hardness_changed)
	brush_type_selector.item_selected.connect(_on_brush_type_selected)
	dimension_selector.item_selected.connect(_on_dimension_selected)
	color_picker.color_changed.connect(_on_color_changed)
	shape_list.item_selected.connect(_on_shape_selected)
	layer_list.item_selected.connect(_on_layer_selected)

func _update_brush_ui():
	brush_size_slider.value = paint_system.current_brush_settings.size
	brush_opacity_slider.value = paint_system.current_brush_settings.opacity
	brush_hardness_slider.value = paint_system.current_brush_settings.hardness
	
	for i in range(brush_type_selector.get_item_count()):
		if brush_type_selector.get_item_id(i) == paint_system.current_brush_settings.stroke_type:
			brush_type_selector.select(i)
			break
	
	for i in range(dimension_selector.get_item_count()):
		if dimension_selector.get_item_id(i) == paint_system.current_brush_settings.dimension:
			dimension_selector.select(i)
			break
	
	color_picker.color = paint_system.current_brush_settings.color

func _populate_shape_list():
	if not shape_system:
		return
	
	shape_list.clear()
	
	# Get current dimension
	var dimension = paint_system.current_brush_settings.dimension
	
	# Add shapes from current dimension
	for shape_id in shape_system.shapes:
		var shape = shape_system.shapes[shape_id]
		if shape.dimension == dimension:
			var shape_name = "Shape " + shape_id.split("_")[1]
			if shape.properties.has("name"):
				shape_name = shape.properties.name
			
			var shape_type_name = ShapeSystem.ShapeType.keys()[shape.type]
			var item_text = shape_name + " (" + shape_type_name + ")"
			
			shape_list.add_item(item_text)
			shape_list.set_item_metadata(shape_list.get_item_count() - 1, shape_id)
			
			# Highlight painted shapes
			if shape.properties.has("painted") and shape.properties.painted:
				shape_list.set_item_custom_bg_color(shape_list.get_item_count() - 1, Color(0.2, 0.4, 0.2))

func _populate_texture_list():
	layer_list.clear()
	
	# Get current dimension
	var dimension = paint_system.current_brush_settings.dimension
	
	# Add textures from current dimension
	for texture_id in paint_system.textures:
		var texture = paint_system.textures[texture_id]
		if texture.dimension == dimension:
			var texture_name = "Texture " + texture_id.split("_")[1]
			
			layer_list.add_item(texture_name)
			layer_list.set_item_metadata(layer_list.get_item_count() - 1, texture_id)
			
			# Highlight the current texture
			if texture_id == paint_canvas.current_texture_id:
				layer_list.select(layer_list.get_item_count() - 1)
				selected_texture_id = texture_id
				_update_texture_preview(texture_id)

func _update_texture_preview(texture_id: String):
	if not paint_system.textures.has(texture_id):
		texture_preview.texture = null
		return
	
	var preview = paint_system.generate_texture_preview(texture_id, texture_preview.size)
	texture_preview.texture = preview

func _on_brush_size_changed(value: float):
	paint_canvas.set_brush_properties("size", value)

func _on_brush_opacity_changed(value: float):
	paint_canvas.set_brush_properties("opacity", value)

func _on_brush_hardness_changed(value: float):
	paint_canvas.set_brush_properties("hardness", value)

func _on_brush_type_selected(index: int):
	var stroke_type = brush_type_selector.get_item_id(index)
	paint_canvas.set_brush_properties("stroke_type", stroke_type)

func _on_dimension_selected(index: int):
	var dimension = dimension_selector.get_item_id(index)
	paint_canvas.set_brush_properties("dimension", dimension)
	
	# Update shape and texture lists for the new dimension
	_populate_shape_list()
	_populate_texture_list()

func _on_color_changed(color: Color):
	paint_canvas.set_brush_properties("color", color)

func _on_shape_selected(index: int):
	var shape_id = shape_list.get_item_metadata(index)
	selected_shape_id = shape_id
	
	# Display shape outline in canvas
	paint_canvas.set_shape_overlay(shape_id)
	
	# Check if shape has a texture already
	if shape_system.shapes[shape_id].properties.has("texture_id"):
		var texture_id = shape_system.shapes[shape_id].properties.texture_id
		if paint_system.textures.has(texture_id):
			selected_texture_id = texture_id
			
			# Find and select this texture in the layer list
			for i in range(layer_list.get_item_count()):
				if layer_list.get_item_metadata(i) == texture_id:
					layer_list.select(i)
					break
			
			_update_texture_preview(texture_id)

func _on_layer_selected(index: int):
	var texture_id = layer_list.get_item_metadata(index)
	selected_texture_id = texture_id
	
	# Load this texture into the canvas
	paint_canvas.load_texture(texture_id)
	
	_update_texture_preview(texture_id)

func _on_brush_changed(settings):
	# Update UI to match brush settings
	brush_size_slider.value = settings.size
	brush_opacity_slider.value = settings.opacity
	brush_hardness_slider.value = settings.hardness
	color_picker.color = settings.color
	
	for i in range(brush_type_selector.get_item_count()):
		if brush_type_selector.get_item_id(i) == settings.stroke_type:
			brush_type_selector.select(i)
			break
	
	for i in range(dimension_selector.get_item_count()):
		if dimension_selector.get_item_id(i) == settings.dimension:
			dimension_selector.select(i)
			break

func _on_stroke_completed(stroke_id: String):
	# Update texture preview
	if selected_texture_id != "":
		_update_texture_preview(selected_texture_id)

func _on_turn_completed(turn_number: int):
	# Update brush color based on the new turn
	if turn_cycle_manager and dimensional_color_system:
		var current_color = turn_cycle_manager.turn_color_mapping[turn_number - 1]
		var color = dimensional_color_system.get_color_value(current_color)
		
		# Only update if in painting mode
		if painting_mode:
			color_picker.color = color
			paint_canvas.set_brush_properties("color", color)

func _on_create_texture_button_pressed():
	var canvas_size = paint_canvas.canvas_size
	var texture_id = paint_system.create_texture(canvas_size, paint_system.current_brush_settings.dimension)
	paint_canvas.load_texture(texture_id)
	
	_populate_texture_list()

func _on_clear_canvas_button_pressed():
	paint_canvas.clear_canvas()
	
	if selected_texture_id != "":
		_update_texture_preview(selected_texture_id)

func _on_apply_to_shape_button_pressed():
	if selected_shape_id == "" or selected_texture_id == "":
		return
	
	paint_system.paint_shape(selected_shape_id, selected_texture_id)
	
	# Update shape list to show which shapes are painted
	_populate_shape_list()

func _on_create_shape_texture_button_pressed():
	if selected_shape_id == "":
		return
	
	var texture_id = paint_system.create_texture_for_shape(selected_shape_id)
	if texture_id != "":
		paint_canvas.load_texture(texture_id)
		selected_texture_id = texture_id
		
		_populate_texture_list()
		_update_texture_preview(texture_id)

func _on_toggle_grid_button_pressed():
	paint_canvas.show_grid = !paint_canvas.show_grid
	paint_canvas._update_grid()

func _on_painter_mode_toggled(button_pressed: bool):
	painting_mode = button_pressed
	shape_paint_mode = !button_pressed
	
	# Update UI based on mode
	$ShapePanel.visible = shape_paint_mode
	$TexturePanel.visible = shape_paint_mode

func _on_shape_paint_mode_toggled(button_pressed: bool):
	shape_paint_mode = button_pressed
	painting_mode = !button_pressed
	
	# Update UI based on mode
	$ShapePanel.visible = shape_paint_mode
	$TexturePanel.visible = shape_paint_mode