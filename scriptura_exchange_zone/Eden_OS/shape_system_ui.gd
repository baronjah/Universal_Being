extends Control

class_name ShapeSystemUI

# References to systems
var shape_system: ShapeSystem
var shape_visualizer: ShapeVisualizer
var shape_dimension_controller: ShapeDimensionController
var turn_cycle_manager: TurnCycleManager
var dimensional_color_system: DimensionalColorSystem

# UI elements - to be set in the editor
@onready var canvas_container = $CanvasContainer
@onready var shape_tools_panel = $ShapeToolsPanel
@onready var dimension_selector = $DimensionPanel/DimensionSelector
@onready var current_turn_label = $InfoPanel/CurrentTurnLabel
@onready var current_dimension_label = $InfoPanel/CurrentDimensionLabel
@onready var shape_info_panel = $ShapeInfoPanel
@onready var shape_info_text = $ShapeInfoPanel/ShapeInfoText

# Shape creation parameters
var current_shape_type: int = ShapeSystem.ShapeType.SQUARE
var current_shape_size: float = 50.0
var creation_mode: bool = false
var selection_mode: bool = true

# Interaction state
var dragging: bool = false
var drag_start_position: Vector2
var selected_shape_id: String = ""
var selected_zone_id: String = ""
var selected_point_id: String = ""

func _ready():
	# Create core systems if they don't exist
	_initialize_systems()
	
	# Set up UI
	_setup_ui()
	
	# Connect signals
	if turn_cycle_manager:
		turn_cycle_manager.turn_completed.connect(_on_turn_completed)
	
	if shape_dimension_controller:
		shape_dimension_controller.shape_transcended.connect(_on_shape_transcended)
		shape_dimension_controller.shape_attuned.connect(_on_shape_attuned)
	
	# Initial UI update
	_update_ui()

func _initialize_systems():
	# Get or create shape system
	shape_system = get_node_or_null("/root/ShapeSystem")
	if not shape_system:
		shape_system = ShapeSystem.new()
		add_child(shape_system)
	
	# Create shape visualizer
	shape_visualizer = ShapeVisualizer.new()
	canvas_container.add_child(shape_visualizer)
	
	# Get or create other systems
	dimensional_color_system = get_node_or_null("/root/DimensionalColorSystem")
	if not dimensional_color_system:
		dimensional_color_system = DimensionalColorSystem.new()
		add_child(dimensional_color_system)
	
	turn_cycle_manager = get_node_or_null("/root/TurnCycleManager")
	
	# Create shape dimension controller
	shape_dimension_controller = ShapeDimensionController.new()
	add_child(shape_dimension_controller)

func _setup_ui():
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
	
	# Default to first dimension
	dimension_selector.select(0)
	shape_visualizer.set_active_dimension(1)
	
	# Connect UI signals
	dimension_selector.item_selected.connect(_on_dimension_selected)

func _update_ui():
	# Update turn and dimension info
	if turn_cycle_manager:
		var current_turn = turn_cycle_manager.current_turn
		var current_color = "None"
		
		if current_turn > 0:
			current_color = turn_cycle_manager.get_current_color_name()
		
		current_turn_label.text = "Turn: " + str(current_turn) + " / 12"
		current_dimension_label.text = "Color: " + current_color
	
	# Update shape info if a shape is selected
	if selected_shape_id != "":
		_update_shape_info(selected_shape_id)
	elif selected_zone_id != "":
		_update_zone_info(selected_zone_id)
	elif selected_point_id != "":
		_update_point_info(selected_point_id)
	else:
		shape_info_panel.visible = false

func _update_shape_info(shape_id: String):
	if not shape_system.shapes.has(shape_id):
		shape_info_panel.visible = false
		return
	
	var shape = shape_system.shapes[shape_id]
	var info_text = ""
	
	# Basic info
	info_text += "Shape: " + ShapeSystem.ShapeType.keys()[shape.type] + "\n"
	info_text += "Dimension: " + str(shape.dimension) + "\n"
	info_text += "Points: " + str(shape.points.size()) + "\n"
	
	# Evolution info
	var evolution = shape_dimension_controller.shape_evolution_stages.get(shape_id, 0.0)
	var threshold = shape_dimension_controller.EVOLUTION_THRESHOLD
	info_text += "Evolution: " + str(evolution) + " / " + str(threshold) + "\n"
	
	# Color attunements
	if shape.properties.has("color_attunements"):
		info_text += "\nAttunements:\n"
		for color_enum in shape.properties["color_attunements"]:
			info_text += "- " + dimensional_color_system.DimColor.keys()[color_enum] + "\n"
	
	# Zone info
	if shape.zone_id != "":
		info_text += "\nZone: "
		if shape_system.zones.has(shape.zone_id):
			info_text += shape_system.zones[shape.zone_id].name
		info_text += "\n"
	
	# Set info text
	shape_info_text.text = info_text
	shape_info_panel.visible = true

func _update_zone_info(zone_id: String):
	if not shape_system.zones.has(zone_id):
		shape_info_panel.visible = false
		return
	
	var zone = shape_system.zones[zone_id]
	var info_text = ""
	
	# Basic info
	info_text += "Zone: " + zone.name + "\n"
	info_text += "Dimension: " + str(zone.dimension) + "\n"
	info_text += "Shapes: " + str(zone.shapes.size()) + "\n"
	
	# Evolution info
	var evolution = shape_dimension_controller.zone_evolution_stages.get(zone_id, 0.0)
	var threshold = shape_dimension_controller.EVOLUTION_THRESHOLD
	info_text += "Evolution: " + str(evolution) + " / " + str(threshold) + "\n"
	
	# Evolution level
	if zone.properties.has("evolution_level"):
		info_text += "Level: " + str(zone.properties.evolution_level) + "\n"
	
	# Stability
	if zone.properties.has("stability"):
		info_text += "Stability: " + str(zone.properties.stability) + "\n"
	
	# Set info text
	shape_info_text.text = info_text
	shape_info_panel.visible = true

func _update_point_info(point_id: String):
	if not shape_system.points.has(point_id):
		shape_info_panel.visible = false
		return
	
	var point = shape_system.points[point_id]
	var info_text = ""
	
	# Basic info
	info_text += "Point\n"
	info_text += "Position: " + str(point.position) + "\n"
	info_text += "Dimension: " + str(point.dimension) + "\n"
	info_text += "Connections: " + str(point.connected_points.size()) + "\n"
	
	# Set info text
	shape_info_text.text = info_text
	shape_info_panel.visible = true

func _input(event):
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventKey:
		_handle_key_event(event)

func _handle_mouse_button(event: InputEventMouseButton):
	if not event.pressed:
		if dragging:
			dragging = false
			return
	
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var position = event.position
			
			if creation_mode:
				# Create a new shape at this position
				var shape_id = shape_system.create_standard_shape(
					current_shape_type,
					position,
					current_shape_size,
					shape_visualizer.active_dimension
				)
				
				selected_shape_id = shape_id
				selected_zone_id = ""
				selected_point_id = ""
				shape_visualizer.selected_shape_id = shape_id
				
				_update_ui()
			elif selection_mode:
				# First try to select a shape
				var shape_id = shape_visualizer.select_shape_at(position)
				
				if shape_id != "":
					selected_shape_id = shape_id
					selected_zone_id = ""
					selected_point_id = ""
				else:
					# Try to select a zone
					var zone_id = shape_visualizer.select_zone_at(position)
					
					if zone_id != "":
						selected_zone_id = zone_id
						selected_shape_id = ""
						selected_point_id = ""
					else:
						# Try to select a point
						var point_id = shape_visualizer.select_point_at(position)
						
						if point_id != "":
							selected_point_id = point_id
							selected_shape_id = ""
							selected_zone_id = ""
						else:
							selected_shape_id = ""
							selected_zone_id = ""
							selected_point_id = ""
							shape_visualizer.selected_shape_id = ""
							shape_visualizer.selected_zone_id = ""
							shape_visualizer.selected_point_id = ""
				
				_update_ui()
			
			drag_start_position = position
			dragging = true
		else:
			dragging = false
	
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			# Cancel creation mode
			creation_mode = false
			
			# Show context menu if something is selected
			if selected_shape_id != "" or selected_zone_id != "" or selected_point_id != "":
				_show_context_menu(event.position)
	
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
		# Zoom in
		shape_visualizer.zoom_in()
	
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		# Zoom out
		shape_visualizer.zoom_out()

func _handle_mouse_motion(event: InputEventMouseMotion):
	if dragging:
		if selected_shape_id != "":
			# Move the selected shape
			if shape_system.shapes.has(selected_shape_id):
				var shape = shape_system.shapes[selected_shape_id]
				var offset = event.position - drag_start_position
				
				var params = {
					"offset": offset
				}
				
				shape_system.transform_shape(
					selected_shape_id,
					ShapeSystem.TransformationType.TRANSLATE,
					params
				)
				
				drag_start_position = event.position
		else:
			# Pan the view
			shape_visualizer.pan_view(event.relative)

func _handle_key_event(event: InputEventKey):
	if event.pressed:
		if event.keycode == KEY_DELETE:
			# Delete selected item
			if selected_shape_id != "":
				shape_system.shapes.erase(selected_shape_id)
				selected_shape_id = ""
				shape_visualizer.selected_shape_id = ""
				_update_ui()
			elif selected_zone_id != "":
				shape_system.zones.erase(selected_zone_id)
				selected_zone_id = ""
				shape_visualizer.selected_zone_id = ""
				_update_ui()
			elif selected_point_id != "":
				shape_system.points.erase(selected_point_id)
				selected_point_id = ""
				shape_visualizer.selected_point_id = ""
				_update_ui()
		
		elif event.keycode == KEY_R:
			# Rotate selected shape
			if selected_shape_id != "":
				var params = {
					"angle_degrees": 15.0
				}
				
				shape_system.transform_shape(
					selected_shape_id,
					ShapeSystem.TransformationType.ROTATE,
					params
				)
		
		elif event.keycode == KEY_S:
			# Scale selected shape
			if selected_shape_id != "":
				var params = {
					"scale_factor": 1.1
				}
				
				shape_system.transform_shape(
					selected_shape_id,
					ShapeSystem.TransformationType.SCALE,
					params
				)
		
		elif event.keycode == KEY_C:
			# Create connection between selected shapes
			if selected_shape_id != "" and shape_visualizer.selected_shape_id != "":
				if selected_shape_id != shape_visualizer.selected_shape_id:
					shape_system.connect_shapes(selected_shape_id, shape_visualizer.selected_shape_id)
		
		elif event.keycode == KEY_Z:
			# Create a zone from selected shapes
			if selected_shape_id != "":
				var shapes = [selected_shape_id]
				
				# Look for nearby shapes
				var shape = shape_system.shapes[selected_shape_id]
				var center = shape.get_center()
				var radius = 200.0
				
				for other_id in shape_system.shapes:
					if other_id != selected_shape_id:
						var other_shape = shape_system.shapes[other_id]
						if other_shape.dimension == shape.dimension:
							var other_center = other_shape.get_center()
							if other_center.distance_to(center) <= radius:
								shapes.append(other_id)
				
				if shapes.size() > 1:
					var zone_name = "Zone_" + str(shape_system.zone_id_counter)
					var zone_id = shape_dimension_controller.create_zone_from_shapes(shapes, zone_name)
					
					if zone_id != "":
						selected_zone_id = zone_id
						selected_shape_id = ""
						shape_visualizer.selected_zone_id = zone_id
						shape_visualizer.selected_shape_id = ""
						_update_ui()
		
		elif event.keycode == KEY_ESCAPE:
			# Cancel creation mode
			creation_mode = false
			
			# Deselect all
			selected_shape_id = ""
			selected_zone_id = ""
			selected_point_id = ""
			shape_visualizer.selected_shape_id = ""
			shape_visualizer.selected_zone_id = ""
			shape_visualizer.selected_point_id = ""
			_update_ui()
		
		elif event.keycode == KEY_SPACE:
			# Toggle creation mode
			creation_mode = !creation_mode
			
			if creation_mode:
				selection_mode = false
			else:
				selection_mode = true

func _show_context_menu(position: Vector2):
	# This would create a popup menu with options for the selected item
	var popup = PopupMenu.new()
	add_child(popup)
	
	if selected_shape_id != "":
		popup.add_item("Delete Shape", 1)
		popup.add_item("Rotate Shape", 2)
		popup.add_item("Scale Shape", 3)
		popup.add_item("Create Zone", 4)
		popup.add_item("View Report", 5)
	elif selected_zone_id != "":
		popup.add_item("Delete Zone", 10)
		popup.add_item("Expand Zone", 11)
	elif selected_point_id != "":
		popup.add_item("Delete Point", 20)
		popup.add_item("Connect Points", 21)
	
	popup.position = position
	
	# Connect signals
	popup.id_pressed.connect(_on_context_menu_item_selected)
	
	popup.popup()

func _on_context_menu_item_selected(id: int):
	match id:
		1:  # Delete Shape
			if selected_shape_id != "":
				shape_system.shapes.erase(selected_shape_id)
				selected_shape_id = ""
				shape_visualizer.selected_shape_id = ""
				_update_ui()
		
		2:  # Rotate Shape
			if selected_shape_id != "":
				var params = {
					"angle_degrees": 45.0
				}
				
				shape_system.transform_shape(
					selected_shape_id,
					ShapeSystem.TransformationType.ROTATE,
					params
				)
		
		3:  # Scale Shape
			if selected_shape_id != "":
				var params = {
					"scale_factor": 1.2
				}
				
				shape_system.transform_shape(
					selected_shape_id,
					ShapeSystem.TransformationType.SCALE,
					params
				)
		
		4:  # Create Zone
			if selected_shape_id != "":
				var shapes = [selected_shape_id]
				var zone_name = "Zone_" + str(shape_system.zone_id_counter)
				var zone_id = shape_dimension_controller.create_zone_from_shapes(shapes, zone_name)
				
				if zone_id != "":
					selected_zone_id = zone_id
					selected_shape_id = ""
					shape_visualizer.selected_zone_id = zone_id
					shape_visualizer.selected_shape_id = ""
					_update_ui()
		
		5:  # View Report
			if selected_shape_id != "":
				var report = shape_dimension_controller.generate_shape_report(selected_shape_id)
				shape_info_text.text = report
				shape_info_panel.visible = true
		
		10:  # Delete Zone
			if selected_zone_id != "":
				shape_system.zones.erase(selected_zone_id)
				selected_zone_id = ""
				shape_visualizer.selected_zone_id = ""
				_update_ui()
		
		11:  # Expand Zone
			if selected_zone_id != "" and shape_system.zones.has(selected_zone_id):
				var zone = shape_system.zones[selected_zone_id]
				zone.expand_boundaries(Vector2(50, 50))
				_update_ui()
		
		20:  # Delete Point
			if selected_point_id != "":
				shape_system.points.erase(selected_point_id)
				selected_point_id = ""
				shape_visualizer.selected_point_id = ""
				_update_ui()
		
		21:  # Connect Points
			if selected_point_id != "" and shape_visualizer.selected_point_id != "":
				if selected_point_id != shape_visualizer.selected_point_id:
					shape_system.connect_points(selected_point_id, shape_visualizer.selected_point_id)

func set_shape_type(type: int):
	current_shape_type = type
	creation_mode = true
	selection_mode = false

func _on_dimension_selected(index: int):
	var dimension = dimension_selector.get_item_id(index)
	shape_visualizer.set_active_dimension(dimension)

func _on_turn_completed(turn_number):
	_update_ui()

func _on_shape_transcended(shape_id, from_dimension, to_dimension):
	if shape_id == selected_shape_id:
		_update_shape_info(shape_id)
	
	# If the shape transcended out of the current dimension, update selection
	if to_dimension != shape_visualizer.active_dimension and from_dimension == shape_visualizer.active_dimension:
		if shape_id == selected_shape_id:
			selected_shape_id = ""
			shape_visualizer.selected_shape_id = ""
			_update_ui()

func _on_shape_attuned(shape_id, color_enum):
	if shape_id == selected_shape_id:
		_update_shape_info(shape_id)

func advance_turn():
	if turn_cycle_manager:
		turn_cycle_manager.advance_turn()
		_update_ui()

# UI Button handlers

func _on_create_square_button_pressed():
	set_shape_type(ShapeSystem.ShapeType.SQUARE)

func _on_create_circle_button_pressed():
	set_shape_type(ShapeSystem.ShapeType.CIRCLE)

func _on_create_triangle_button_pressed():
	set_shape_type(ShapeSystem.ShapeType.TRIANGLE)

func _on_create_hexagon_button_pressed():
	set_shape_type(ShapeSystem.ShapeType.HEXAGON)

func _on_create_star_button_pressed():
	set_shape_type(ShapeSystem.ShapeType.STAR)

func _on_advance_turn_button_pressed():
	advance_turn()

func _on_reset_view_button_pressed():
	shape_visualizer.reset_view()

func _on_create_zone_button_pressed():
	if selected_shape_id != "":
		var shapes = [selected_shape_id]
		var zone_name = "Zone_" + str(shape_system.zone_id_counter)
		var zone_id = shape_dimension_controller.create_zone_from_shapes(shapes, zone_name)
		
		if zone_id != "":
			selected_zone_id = zone_id
			selected_shape_id = ""
			shape_visualizer.selected_zone_id = zone_id
			shape_visualizer.selected_shape_id = ""
			_update_ui()

func _on_connect_button_pressed():
	if selected_shape_id != "" and shape_visualizer.selected_shape_id != "":
		if selected_shape_id != shape_visualizer.selected_shape_id:
			shape_system.connect_shapes(selected_shape_id, shape_visualizer.selected_shape_id)
	elif selected_point_id != "" and shape_visualizer.selected_point_id != "":
		if selected_point_id != shape_visualizer.selected_point_id:
			shape_system.connect_points(selected_point_id, shape_visualizer.selected_point_id)

func _on_size_slider_value_changed(value):
	current_shape_size = value