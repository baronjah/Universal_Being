extends Node
# res://code/gdscript/scripts/Menu_Keyboard_Console/jsh_digital_earthlings.gd
# JSH_World/JSH_digital_earthlings
####################
#
# JSH Digital Earthlings Integration
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓• •      ┓    ┏┓   •                   
#       888  `"Y8888o.   888ooooo888     ┣┫┓┏┓┓╋┏┓┏┓┃    ┣ ┏┓┏┓┫┏┏┓┏┓┏┓┏┓╋┓┏┓┏┓    
#       888      `"Y88b  888     888     ┛┗┗┗┫┗┗┫┛ ┗┗    ┻ ┗┫┛┗┗┗┗ ┗┫┛┗┗┻┗┗┗ ┛    
#       888 oo     .d8P  888     888           ┛  ┛         ┛    ┛          ┛     
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Digital Earthlings Integration
#
####################
## jsh_digital_earthlings.gd
## with snake update, so what we have in here, what connections we need per script, per functions, each script have its own pathways
## how do i remember all 100000000 mutex names from words and letters?


# Node references
@onready var main_node = get_node("/root/main")
@onready var records_system = get_node_or_null("/root/main/JSH_records_system")
@onready var thread_pool = get_node_or_null("/root/thread_pool_autoload")

# Internal state
const VERSION = "1.0.0"
const AI_MODEL_PATH = "res://models/gemma-2-2b-it-Q4_K_M.gguf"
const REALITY_STATES = ["physical", "digital", "astral"]

var command_history = []
var last_guardian_message = ""
var current_command = ""
var game_initialized = false
var transition_in_progress = false
var current_reality = "physical"
var deja_vu_counter = 0
var player_memory = {}
var gemma_loaded = false

# Configuration
var config = {
	"thread_allocation": {
		"ai_thread_percent": 40,
		"physics_thread_percent": 20,
		"entity_thread_percent": 20,
		"reality_thread_percent": 10,
		"memory_thread_percent": 10
	},
	"reality": {
		"transition_duration": 1.0,
		"glitch_intensity": 0.25,
		"auto_shift_count": 3
	},
	"ai": {
		"context_size": 1024,
		"max_tokens": 256,
		"temperature": 0.7
	}
}

# Signals
signal reality_shifted(old_reality, new_reality)
signal guardian_spawned(guardian_type, location)
signal entity_created(entity_type, entity_id)
signal entity_transformed(entity_id, new_form)
signal deja_vu_triggered(trigger_data)
signal command_processed(command, result)

# ==========================================
# JSH Digital Earthlings Integration - Initialization
# ==========================================



###############




#extends Node3D
#class_name JSHDataGrid

# Signals
signal grid_updated
signal cell_selected(x, y, value)
signal data_threshold_reached(threshold_type, value)

# Grid properties
var grid_width = 10
var grid_height = 10
var cell_size = 0.2
var cell_spacing = 0.05
var grid_depth = 0.5  # Maximum height for values
var value_scale = 1.0 # Multiplier for visual height

# Visualization properties
var use_color_gradient = true
var min_color = 0.2  # For get_spectrum_color
var max_color = 0.8  # For get_spectrum_color
var base_opacity = 0.8
var highlight_opacity = 1.0
var animation_speed = 1.0

# Data properties
var grid_data = []
var current_min_value = 0.0
var current_max_value = 0.0
var data_label = "Value"
var data_units = ""

# Node references
var cells = []
var labels = []
var grid_container = null
var x_axis_labels = []
var y_axis_labels = []
var title_label = null
var info_panel = null

# References to other systems
var main_scene_reference = null
var task_manager = null
var records_bank = null
var position
var rotation_degrees

# Public methods
func _ready_add():
	initialize_grid()
	
	# Connect to task manager if available
	task_manager = get_node_or_null("/root/JSHTaskManager")
	if task_manager:
		print("Data grid connected to task manager")

func initialize_grid():
	# Create container node
	grid_container = Node3D.new()
	grid_container.name = "GridContainer"
	add_child(grid_container)
	
	# Initialize empty data grid
	grid_data = []
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(0.0)
		grid_data.append(row)
	
	# Create visual grid
	create_grid_cells()
	create_axis_labels()
	create_title()
	create_info_panel()

func set_grid_size(width, height):
	if width == grid_width and height == grid_height:
		return
		
	grid_width = width
	grid_height = height
	
	# Clear existing grid
	clear_grid()
	
	# Recreate with new dimensions
	initialize_grid()

func set_data(data_array):
	# Check if data array matches our grid dimensions
	if data_array.size() != grid_height or data_array[0].size() != grid_width:
		print("Data dimensions don't match grid dimensions")
		return false
	
	grid_data = data_array
	
	# Find min/max values for scaling
	current_min_value = INF
	current_max_value = -INF
	
	for y in range(grid_height):
		for x in range(grid_width):
			var value = grid_data[y][x]
			current_min_value = min(current_min_value, value)
			current_max_value = max(current_max_value, value)
	
	# Update visualization
	update_grid_visualization()
	
	# Track in task manager
	if task_manager and task_manager.has_method("track_data_flow"):
		task_manager.track_data_flow(
			"DataSource", 
			"DataGrid", 
			"grid_data_update", 
			grid_width * grid_height
		)
	
	emit_signal("grid_updated")
	return true

func update_cell_value(x, y, value):
	if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
		return false
	
	grid_data[y][x] = value
	
	# Update min/max if needed
	if value < current_min_value:
		current_min_value = value
	if value > current_max_value:
		current_max_value = value
	
	# Update just this cell
	update_cell_visualization(x, y)
	
	# Record this interaction
	if task_manager and task_manager.has_method("record_interaction"):
		var cell_position = cells[y][x].global_position
		task_manager.record_interaction(
			cell_position,
			"cell_update",
			{
				"x": x,
				"y": y,
				"value": value,
				"prev_min": current_min_value,
				"prev_max": current_max_value
			}
		)
	
	return true

func highlight_cell(x, y, highlight = true):
	if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
		return
	
	var cell = cells[y][x]
	var material = cell.material_override
	
	if highlight:
		material.albedo_color.a = highlight_opacity
		# Option: Make it slightly larger
		cell.scale = Vector3(1.1, 1.1, 1.1)
	else:
		material.albedo_color.a = base_opacity
		cell.scale = Vector3(1.0, 1.0, 1.0)

func set_title(title_text):
	if title_label:
		title_label.text = title_text

func set_data_properties(label, units):
	data_label = label
	data_units = units
	update_info_panel()

func animate_to_new_data(new_data, duration = 1.0):
	# Store initial data for interpolation
	var initial_data = []
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(grid_data[y][x])
		initial_data.append(row)
	
	# Create a tween for smooth animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	# Custom property to track interpolation
	var interpolation_object = {"value": 0.0}
	
	# Tween the interpolation value from 0 to 1
	tween.tween_property(interpolation_object, "value", 1.0, duration)
	
	# Connect to the tween's step signal
	tween.tween_callback(func():
		var t = interpolation_object.value
		var interpolated_data = []
		
		# Create interpolated data
		for y in range(grid_height):
			var row = []
			for x in range(grid_width):
				var start_val = initial_data[y][x]
				var end_val = new_data[y][x]
				var current_val = lerp(start_val, end_val, t)
				row.append(current_val)
			interpolated_data.append(row)
		
		# Set the interpolated data
		set_data(interpolated_data)
	).set_delay(0.0)
	
	# Wait for animation to complete
	await tween.finished
	
	# Ensure we end with exactly the target data
	set_data(new_data)

# Pattern generation functions
func generate_wave_pattern():
	var animation_time = Time.get_ticks_msec() / 1000.0
	var data = []
	
	# Initialize data array
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(0.0)
		data.append(row)
	
	# Generate wave pattern
	for y in range(grid_height):
		for x in range(grid_width):
			var nx = float(x) / grid_width
			var ny = float(y) / grid_height
			
			# Create wave pattern
			var value = sin(nx * 4 + animation_time) * cos(ny * 4 + animation_time * 0.7) * 0.5 + 0.5
			data[y][x] = value
	
	return data

func generate_ripple_pattern():
	var animation_time = Time.get_ticks_msec() / 1000.0
	var data = []
	
	# Initialize data array
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(0.0)
		data.append(row)
	
	# Generate ripple pattern
	var center_x = grid_width / 2.0
	var center_y = grid_height / 2.0
	
	for y in range(grid_height):
		for x in range(grid_width):
			var dx = x - center_x
			var dy = y - center_y
			var distance = sqrt(dx*dx + dy*dy) / grid_width * 10.0
			
			# Create ripple pattern
			var value = sin(distance - animation_time * 3) * 0.5 + 0.5
			data[y][x] = value
	
	return data

func generate_random_pattern():
	var data = []
	
	# Initialize data array
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(0.0)
		data.append(row)
	
	# Generate random pattern with noise
	var noise = FastNoiseLite.new()
	noise.seed = int(Time.get_unix_time_from_system() * 1000) % 1000000
	noise.frequency = 0.2
	
	var animation_time = Time.get_ticks_msec() / 1000.0
	
	for y in range(grid_height):
		for x in range(grid_width):
			# Create random pattern that changes with time
			var value = noise.get_noise_2d(x + animation_time * 5, y + animation_time * 3) * 0.5 + 0.5
			data[y][x] = value
	
	return data

func generate_gradient_pattern():
	var data = []
	
	# Initialize data array
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(0.0)
		data.append(row)
	
	# Generate gradient pattern
	for y in range(grid_height):
		for x in range(grid_width):
			# Create a simple diagonal gradient
			var nx = float(x) / grid_width
			var ny = float(y) / grid_height
			
			# Diagonal gradient from bottom-left to top-right
			var value = (nx + ny) / 2.0
			data[y][x] = value
	
	return data

func generate_mountain_pattern():
	var data = []
	
	# Initialize data array
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(0.0)
		data.append(row)
	
	# Generate terrain-like pattern with noise
	var noise = FastNoiseLite.new()
	noise.seed = int(Time.get_unix_time_from_system() * 1000) % 1000000
	noise.frequency = 0.1
	noise.fractal_octaves = 4
	
	for y in range(grid_height):
		for x in range(grid_width):
			var nx = float(x) / grid_width
			var ny = float(y) / grid_height
			
			# Create mountain pattern with noise and some peaks
			var base_noise = noise.get_noise_2d(x * 3, y * 3) * 0.5 + 0.5
			
			# Add some peaks
			var dist_from_center = sqrt(pow((nx - 0.5), 2) + pow((ny - 0.5), 2)) * 2
			var peak_factor = max(0, 1 - dist_from_center)
			
			var value = base_noise * 0.7 + peak_factor * 0.3
			data[y][x] = value
	
	return data

# Private methods
func create_grid_cells():
	cells = []
	
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			var cell = create_cell(x, y)
			row.append(cell)
			grid_container.add_child(cell)
		cells.append(row)

func create_cell(x, y):
	var cell = MeshInstance3D.new()
	cell.name = "Cell_%d_%d" % [x, y]
	
	# Create box mesh for the cell
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(cell_size, 0.01, cell_size) # Start with minimal height
	cell.mesh = box_mesh
	
	# Position cell in grid
	var x_pos = x * (cell_size + cell_spacing) - (grid_width * (cell_size + cell_spacing)) / 2 + cell_size/2
	var y_pos = 0.0 # Will be adjusted based on value
	var z_pos = y * (cell_size + cell_spacing) - (grid_height * (cell_size + cell_spacing)) / 2 + cell_size/2
	cell.position = Vector3(x_pos, y_pos, z_pos)
	
	# Create material
	var material = StandardMaterial3D.new()
	if main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
		material.albedo_color = main_scene_reference.get_spectrum_color(min_color)
	else:
		material.albedo_color = Color(0.3, 0.5, 0.8, base_opacity)
	
	material.albedo_color.a = base_opacity
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	cell.material_override = material
	
	# Add collision for interaction
	var area = Area3D.new()
	cell.add_child(area)
	
	var collision = CollisionShape3D.new()
	area.add_child(collision)
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(cell_size, grid_depth, cell_size) # Full height for collision
	collision.shape = box_shape
	
	# Connect area signals
	area.input_event.connect(func(camera, event, position, normal, shape_idx): 
		_on_cell_input_event(x, y, camera, event, position, normal, shape_idx)
	)
	area.mouse_entered.connect(func(): _on_cell_mouse_entered(x, y))
	area.mouse_exited.connect(func(): _on_cell_mouse_exited(x, y))
	
	# Add value label above cell
	var label = Label3D.new()
	label.name = "Value_Label"
	label.text = "0.0"
	label.font_size = 8
	label.position = Vector3(0, grid_depth + 0.05, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = Color(1, 1, 1, 0)  # Start invisible
	cell.add_child(label)
	
	return cell

func create_axis_labels():
	# Create X-axis labels
	for x in range(grid_width):
		var label = Label3D.new()
		label.text = str(x)
		label.font_size = 10
		
		var x_pos = x * (cell_size + cell_spacing) - (grid_width * (cell_size + cell_spacing)) / 2 + cell_size/2
		var z_pos = (grid_height * (cell_size + cell_spacing)) / 2 + cell_spacing*2
		
		label.position = Vector3(x_pos, 0, z_pos)
		grid_container.add_child(label)
		x_axis_labels.append(label)
	
	# Create Y-axis labels
	for y in range(grid_height):
		var label = Label3D.new()
		label.text = str(y)
		label.font_size = 10
		
		var x_pos = -(grid_width * (cell_size + cell_spacing)) / 2 - cell_spacing*2
		var z_pos = y * (cell_size + cell_spacing) - (grid_height * (cell_size + cell_spacing)) / 2 + cell_size/2
		
		label.position = Vector3(x_pos, 0, z_pos)
		grid_container.add_child(label)
		y_axis_labels.append(label)

func create_title():
	title_label = Label3D.new()
	title_label.text = "Data Grid Visualization"
	title_label.font_size = 16
	title_label.position = Vector3(0, grid_depth + 0.2, -(grid_height * (cell_size + cell_spacing)) / 2 - cell_size)
	grid_container.add_child(title_label)

func create_info_panel():
	info_panel = Node3D.new()
	info_panel.name = "InfoPanel"
	grid_container.add_child(info_panel)
	
	# Position panel to the right of the grid
	var panel_x = (grid_width * (cell_size + cell_spacing)) / 2 + cell_size
	info_panel.position = Vector3(panel_x, 0, 0)
	
	# Create background quad
	var panel_mesh = MeshInstance3D.new()
	panel_mesh.name = "PanelBackground"
	info_panel.add_child(panel_mesh)
	
	var quad = QuadMesh.new()
	quad.size = Vector2(1.5, 1.0)
	panel_mesh.mesh = quad
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.2, 0.2, 0.7)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	panel_mesh.material_override = material
	
	# Set up info labels
	var y_offset = 0.3
	
	var min_value_label = Label3D.new()
	min_value_label.name = "MinValue"
	min_value_label.position = Vector3(0, y_offset, 0.01)
	min_value_label.font_size = 10
	min_value_label.text = "Min: 0.0"
	info_panel.add_child(min_value_label)
	
	var max_value_label = Label3D.new()
	max_value_label.name = "MaxValue"
	max_value_label.position = Vector3(0, y_offset - 0.15, 0.01)
	max_value_label.font_size = 10
	max_value_label.text = "Max: 0.0"
	info_panel.add_child(max_value_label)
	
	var avg_value_label = Label3D.new()
	avg_value_label.name = "AvgValue"
	avg_value_label.position = Vector3(0, y_offset - 0.3, 0.01)
	avg_value_label.font_size = 10
	avg_value_label.text = "Avg: 0.0"
	info_panel.add_child(avg_value_label)
	
	# Add color legend
	create_color_legend()

func create_color_legend():
	var legend = Node3D.new()
	legend.name = "ColorLegend"
	info_panel.add_child(legend)
	
	# Position at bottom of info panel
	legend.position = Vector3(0, -0.3, 0.01)
	
	# Create colored boxes
	var segments = 5
	var box_size = 0.1
	var total_width = segments * box_size
	
	for i in range(segments):
		var box = MeshInstance3D.new()
		legend.add_child(box)
		
		var mesh = QuadMesh.new()
		mesh.size = Vector2(box_size, box_size)
		box.mesh = mesh
		
		# Position along horizontal line
		var x_pos = (i - segments/2.0 + 0.5) * box_size
		box.position = Vector3(x_pos, 0, 0)
		
		# Create gradient color
		var t = float(i) / (segments - 1)
		var material = StandardMaterial3D.new()
		
		if main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
			var color_val = lerp(min_color, max_color, t)
			material.albedo_color = main_scene_reference.get_spectrum_color(color_val)
		else:
			material.albedo_color = Color(t, t*0.8, 1.0-t, base_opacity)
		
		box.material_override = material
	
	# Add min/max labels
	var min_label = Label3D.new()
	min_label.text = "Min"
	min_label.font_size = 8
	min_label.position = Vector3(-total_width/2 - 0.05, 0, 0)
	legend.add_child(min_label)
	
	var max_label = Label3D.new()
	max_label.text = "Max"
	max_label.font_size = 8
	max_label.position = Vector3(total_width/2 + 0.05, 0, 0)
	legend.add_child(max_label)

func update_grid_visualization():
	# Update each cell based on data
	for y in range(grid_height):
		for x in range(grid_width):
			update_cell_visualization(x, y)
	
	# Update info panel
	update_info_panel()

func update_cell_visualization(x, y):
	var cell = cells[y][x]
	var value = grid_data[y][x]
	
	# Skip if cell doesn't exist
	if not cell:
		return
	
	# Calculate normalized value (0-1)
	var normalized_value = 0.0
	if current_max_value != current_min_value:
		normalized_value = (value - current_min_value) / (current_max_value - current_min_value)
	
	# Update height
	var box_mesh = cell.mesh as BoxMesh
	var height = normalized_value * grid_depth * value_scale
	height = max(0.01, height)  # Ensure minimum height for visibility
	
	box_mesh.size = Vector3(cell_size, height, cell_size)
	
	# Center the box vertically
	cell.position.y = height / 2
	
	# Update color
	var material = cell.material_override
	
	if use_color_gradient and main_scene_reference and main_scene_reference.has_method("get_spectrum_color"):
		var color_val = lerp(min_color, max_color, normalized_value)
		material.albedo_color = main_scene_reference.get_spectrum_color(color_val)
		material.albedo_color.a = base_opacity
	else:
		# Fallback color gradient
		material.albedo_color = Color(
			normalized_value * 0.8 + 0.2,
			(1.0 - normalized_value) * 0.8 + 0.2,
			0.5,
			base_opacity
		)
	
	# Update value label
	var label = cell.get_node("Value_Label")
	if label:
		label.text = "%0.1f" % value
		label.position.y = height + 0.05

func update_info_panel():
	if not info_panel:
		return
	
	# Calculate stats
	var min_label = info_panel.get_node("MinValue")
	var max_label = info_panel.get_node("MaxValue")
	var avg_label = info_panel.get_node("AvgValue")
	
	if min_label:
		min_label.text = "Min %s: %0.2f%s" % [data_label, current_min_value, data_units]
	
	if max_label:
		max_label.text = "Max %s: %0.2f%s" % [data_label, current_max_value, data_units]
	
	if avg_label:
		var total = 0.0
		for y in range(grid_height):
			for x in range(grid_width):
				total += grid_data[y][x]
		
		var avg = total / (grid_width * grid_height)
		avg_label.text = "Avg %s: %0.2f%s" % [data_label, avg, data_units]

func clear_grid():
	# Remove all grid elements
	if grid_container:
		for child in grid_container.get_children():
			child.queue_free()
		
		grid_container.queue_free()
		grid_container = null
	
	cells = []
	x_axis_labels = []
	y_axis_labels = []
	title_label = null
	info_panel = null

# Signal handlers
func _on_cell_input_event(x, y, camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("cell_selected", x, y, grid_data[y][x])
			
			# Record this interaction
			if task_manager and task_manager.has_method("record_interaction"):
				task_manager.record_interaction(
					position,
					"cell_click",
					{
						"x": x,
						"y": y,
						"value": grid_data[y][x]
					}
				)

func _on_cell_mouse_entered(x, y):
	highlight_cell(x, y, true)
	
	# Show value label
	var cell = cells[y][x]
	var label = cell.get_node("Value_Label")
	if label:
		label.modulate = Color(1, 1, 1, 1)  # Make visible

func _on_cell_mouse_exited(x, y):
	highlight_cell(x, y, false)
	
	# Hide value label
	var cell = cells[y][x]
	var label = cell.get_node("Value_Label")
	if label:
		label.modulate = Color(1, 1, 1, 0)  # Make invisible

# Set up reference to main scene
func setup_main_reference(main_ref):
	main_scene_reference = main_ref
	# Need to refresh all materials
	update_grid_visualization()

# Integration with RecordsBank
func create_from_records(record_map_id, record_index):
	if not records_bank:
		records_bank = get_node_or_null("/root/RecordsBank")
		if not records_bank:
			print("RecordsBank not found!")
			return false
	
	# Access the records map
	var record_maps = {
		0: records_bank.records_map_0,
		1: records_bank.records_map_1,
		2: records_bank.records_map_2,
		3: records_bank.records_map_3,
		4: records_bank.records_map_4,
		5: records_bank.records_map_5,
		6: records_bank.records_map_6,
		7: records_bank.records_map_7,
		8: records_bank.records_map_8
	}
	
	if not record_maps.has(record_map_id):
		print("Record map ID not found: ", record_map_id)
		return false
	
	var records_map = record_maps[record_map_id]
	if not records_map.has(record_index):
		print("Record index not found: ", record_index)
		return false
	
	var record = records_map[record_index]
	if record.size() < 2:
		print("Record has insufficient data")
		return false
	
	# Parse record data
	var header = record[0]
	var data = record[1]
	
	# Extract position and rotation
	if header.size() >= 3:
		var pos_parts = header[1].split(",")
		if pos_parts.size() >= 3:
			position = Vector3(float(pos_parts[0]), float(pos_parts[1]), float(pos_parts[2]))
		
		var rot_parts = header[2].split(",")
		if rot_parts.size() >= 3:
			rotation_degrees = Vector3(float(rot_parts[0]), float(rot_parts[1]), float(rot_parts[2]))
	
	# Set title if available
	if header.size() >= 7:
		set_title(header[6])
	
	# Create example data if none is provided
	set_data(generate_wave_pattern())
	
	return true






#################




func _ready_old():
	print("\n🚀 [READY] Initializing Digital Earthlings Game v" + VERSION + "...\n")
	
	# Will be fully initialized by main.gd calling initialize_integration()
	
	print("\n✅ Digital Earthlings ready for initialization.\n")

func initialize_integration():
	# Register Digital Earthlings data with Records System
	register_records()
	
	# Initialize AI system
	#initialize_ai_system()
	
	# Initialize reality systems
	initialize_reality_systems()
	
	# Initialize command system
	initialize_command_system()
	
	# Connect signals
#	connect_signals()
	
	# Start game with a short delay
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(initialize_game)
	
	print("🎮 Digital Earthlings integration initialized")

#func connect_signals():
#	if main_node:
		# Connect to main node signals
#3#		if main_node.has_signal("main_node_signal"):
#			main_node.main_node_signal.connect(_on_main_node_signal)
	
	# Connect local signals
#

func register_records():
	# This is now handled by main.gd's register_digital_earthlings_records function
	print("📝 Digital Earthlings records registration delegated to main node")

#
func initialize_reality_systems():
	print("🌐 Initializing reality systems")
	
	# Initialize physical reality
	if main_node and main_node.has_method("create_new_task"):
		main_node.create_new_task("initialize_physical_reality", "standard")
		main_node.create_new_task("initialize_digital_reality", "ps2_era")
		main_node.create_new_task("initialize_astral_reality", "geometric")
	
	print("🌐 Reality systems initialized")

func initialize_command_system():
	print("⌨️ Initializing command system")
	
	# Create command parser
	setup_command_processor()
	
	print("⌨️ Command system initialized")

func setup_command_processor():
	# Set up command processor for handling text commands
	set_meta("command_processor", {
		"commands": {
			"help": "_cmd_help",
			"create": "_cmd_create",
			"transform": "_cmd_transform",
			"remember": "_cmd_remember",
			"shift": "_cmd_shift",
			"speak": "_cmd_speak",
			"glitch": "_cmd_glitch",
			"spawn": "_cmd_spawn",
			"guardian": "_cmd_guardian",
			"reality": "_cmd_reality",
			"deja": "_cmd_deja_vu"
		},
		"history": []
	})

func initialize_game():
	if game_initialized:
		return
	
	print("\n🎮 Starting Digital Earthlings game...\n")
	
	# Load the main game container
	if main_node and main_node.has_method("create_new_task"):
		main_node.create_new_task("three_stages_of_creation", "digital_earthlings")
		
		# Load reality containers (initially hidden)
		main_node.create_new_task("three_stages_of_creation", "physical_reality")
	
	# Add welcome message to the command interface
	get_tree().create_timer(3.0).timeout.connect(show_welcome_message)
	
	game_initialized = true

func show_welcome_message():
	var welcome_message = """
	===============================================
		DIGITAL EARTHLINGS - REALITY SIMULATOR    
	===============================================
	
	Welcome, godlike entity. You exist across multiple
	realities simultaneously.
	
	Type 'help' for available commands.
	
	Current reality: PHYSICAL
	"""
	
	# Find command interface text
	var command_text_node = find_interface_text_node()
	if command_text_node and command_text_node is Label3D:
		command_text_node.text = welcome_message
	
	print(welcome_message)

func find_interface_text_node():
	# Find the command text node in the hierarchy
	var container = get_node_or_null("/root/main/digital_earthlings_container")
	if container:
		return container.get_node_or_null("thing_3")
	return null

# ==========================================
# JSH Digital Earthlings Integration - Game Processing
# ==========================================

#func _process(delta):
	# Handle periodic reality anomalies (very rare)
	#if Engine.time_scale > 0 and randf() < 0.0005 * delta:
		# 0.05% chance per second
		#create_anomaly()

# ==========================================
# JSH Digital Earthlings Integration - Command Processing
# ==========================================

func parse_command(command_text: String):
	# Split the command into parts
	var parts = command_text.strip_edges().split(" ", false)
	if parts.size() == 0:
		return {"success": false, "message": "Empty command"}
	
	var cmd = parts[0].to_lower()
	var processor = get_meta("command_processor")
	
	# Check if command exists
	if !processor.commands.has(cmd):
		return {"success": false, "message": "Unknown command: " + cmd}
	
	# Extract arguments
	var args = []
	if parts.size() > 1:
		args = parts.slice(1, parts.size() - 1)
	
	# Execute command
	var method_name = processor.commands[cmd]
	if has_method(method_name):
		var result = call(method_name, args)
		
		# Record command in history
		processor.history.append({
			"command": command_text,
			"timestamp": Time.get_ticks_msec()
		})
		
		# Emit signal
		command_processed.emit(command_text, result)
		
		return result
	else:
		return {"success": false, "message": "Command method not implemented: " + method_name}

# ==========================================
# JSH Digital Earthlings Integration - Command Implementations
# ==========================================

func _cmd_help(args):
	var help_text = """
	===============================================
	  DIGITAL EARTHLINGS - COMMAND REFERENCE      
	===============================================
	
	BASIC COMMANDS:
	help                - Show this help text
	create [type] [name] - Create an entity
	transform [entity] [form] - Change entity form
	remember [concept] [details] - Store memory
	shift [reality]     - Change reality state
	speak [entity] [message] - Talk to an entity
	
	SPECIAL COMMANDS:
	glitch [param] [intensity] - Create glitch
	spawn [entity]     - Spawn an entity
	guardian [type]    - Summon a guardian
	reality           - Show current reality
	deja              - Trigger déjà vu
	
	Available realities: physical, digital, astral
	"""
	
	# Show help text in command interface
	var command_text_node = find_interface_text_node()
	if command_text_node and command_text_node is Label3D:
		command_text_node.text = help_text
	
	print(help_text)
	
	return {"success": true, "message": "Help displayed"}

func _cmd_create(args):
	if args.size() < 2:
		return {"success": false, "message": "Usage: create [type] [name]"}
	
	var type = args[0]
	var name = args[1]
	
	# Parse attributes (optional)
	var attributes = {}
	for i in range(2, args.size(), 2):
		if i + 1 < args.size():
			attributes[args[i]] = args[i + 1]
	
	# Create entity in current reality
	var container_path = current_reality + "_reality_container"
	
	# Use JSH's creation system
	if main_node and main_node.has_method("first_dimensional_magic"):
		main_node.first_dimensional_magic(
			"create_entity",
			container_path,
			{
				"type": type,
				"name": name,
				"attributes": attributes
			}
		)
	
	# Remember this creation
	#remember("creation_" + name, {"type": type, "attributes": attributes})
	
	# Check for déjà vu
	#check_for_deja_vu("create", {"entity": name, "type": type})
	
	return {
		"success": true,
		"message": "Created " + type + " named " + name
	}

func _cmd_transform(args):
	if args.size() < 2:
		return {"success": false, "message": "Usage: transform [entity_name] [new_form]"}
	
	var entity_name = args[0]
	var new_form = args[1]
	
	# Parse attributes (optional)
	var attributes = {}
	for i in range(2, args.size(), 2):
		if i + 1 < args.size():
			attributes[args[i]] = args[i + 1]
	
	# Transform entity in current reality
	var container_path = current_reality + "_reality_container"
	var entity_path = container_path + "/" + entity_name
	
	# Use JSH's transformation system
	if main_node and main_node.has_method("the_fourth_dimensional_magic"):
		main_node.the_fourth_dimensional_magic(
			"transform",
			entity_path,
			{
				"form": new_form,
				"attributes": attributes
			}
		)
	
	# Remember this transformation
	#remember("transform_" + entity_name, {"new_form": new_form})
	
	# Check for déjà vu
	#check_for_deja_vu("transform", {"entity": entity_name, "new_form": new_form})
	
	return {
		"success": true,
		"message": "Transformed " + entity_name + " into " + new_form
	}

func _cmd_remember(args):
	if args.size() < 2:
		return {"success": false, "message": "Usage: remember [concept] [details...]"}
	
	var concept = args[0]
	var details = " ".join(args.slice(1, args.size() - 1))
	
	# Store in memory
	#remember(concept, details)
	
	return {
		"success": true,
		"message": "Remembered: " + concept
	}

func _cmd_shift(args):
	if args.size() < 1:
		return {"success": false, "message": "Usage: shift [reality_type]"}
	
	var reality_type = args[0].to_lower()
	
	# Check if valid reality type
	if !REALITY_STATES.has(reality_type):
		return {
			"success": false,
			"message": "Unknown reality type: " + reality_type + ". Valid types: " + str(REALITY_STATES)
		}
	
	# Shift reality
	shift_reality(reality_type)
	
	return {
		"success": true,
		"message": "Shifting to " + reality_type + " reality"
	}

func _cmd_speak(args):
	if args.size() < 2:
		return {"success": false, "message": "Usage: speak [entity_name] [message]"}
	
	var entity_name = args[0]
	var message = " ".join(args.slice(1, args.size() - 1))
	
	# Use JSH's messaging system
	if main_node and main_node.has_method("eight_dimensional_magic"):
		main_node.eight_dimensional_magic(
			"player_message",
			message,
			entity_name
		)
	
	# Remember this conversation
	#remember("conversation_" + entity_name, {"message": message})
	
	# Check for déjà vu
#	check_for_deja_vu("speak", {"entity": entity_name})
	
	return {
		"success": true,
		"message": "Said to " + entity_name + ": " + message
	}

func _cmd_glitch(args):
	if args.size() < 2:
		return {"success": false, "message": "Usage: glitch [parameter] [intensity]"}
	
	var parameter = args[0]
	var intensity = args[1]
	var duration = "5s"
	
	if args.size() > 2:
		duration = args[2]
	
	# Create glitch effect
	create_glitch_effect(parameter, intensity, duration)
	
	return {
		"success": true,
		"message": "Creating " + parameter + " glitch"
	}

func _cmd_spawn(args):
	if args.size() < 1:
		return {"success": false, "message": "Usage: spawn [entity_type]"}
	
	var entity_type = args[0]
	
	# Get spawn location (default to center)
	var location = Vector3(0, 0, 0)
	
	# Spawn entity in current reality
	if main_node and main_node.has_method("first_dimensional_magic"):
		main_node.first_dimensional_magic(
			"create_entity",
			current_reality + "_reality_container",
			{
				"type": entity_type,
				"position": location,
				"reality": current_reality
			}
		)
	
	return {
		"success": true,
		"message": "Spawned " + entity_type
	}

func _cmd_guardian(args):
	if args.size() < 1:
		return {"success": false, "message": "Usage: guardian [type]"}
	
	var guardian_type = args.join(" ")
	var location = Vector3(0, 0.5, -2)
	
	# Spawn guardian
#	spawn_guardian(guardian_type, location)
	
	return {
		"success": true,
		"message": "Summoned " + guardian_type + " guardian"
	}

func _cmd_reality(args):
	var reality_info = """
	==============================================
	  CURRENT REALITY: %s
	==============================================
	
	You exist across multiple realities:
	- PHYSICAL: The tangible world of matter
	- DIGITAL: The world of information and code
	- ASTRAL: The realm of consciousness and light
	
	Current déjà vu count: %d
	""" % [current_reality.to_upper(), deja_vu_counter]
	
	# Show reality info in command interface
	var command_text_node = find_interface_text_node()
	if command_text_node and command_text_node is Label3D:
		command_text_node.text = reality_info
	
	print(reality_info)
	
	return {
		"success": true,
		"message": "Current reality: " + current_reality
	}

func _cmd_deja_vu(args):
	# Trigger déjà vu directly
	#trigger_deja_vu("manual", Vector3(0, 0, -2))
	
	return {
		"success": true,
		"message": "Déjà vu triggered"
	}

# ==========================================
# JSH Digital Earthlings Integration - Reality System
# ==========================================

func shift_reality(new_reality):
	# Check if valid reality type
	if !REALITY_STATES.has(new_reality) or transition_in_progress:
		return
	
	# Lock reality during transition
	transition_in_progress = true
	var old_reality = current_reality
	current_reality = new_reality
	
	print("🔄 Shifting reality from " + old_reality + " to " + new_reality)
	
	# Update reality text
	var reality_text_node = get_node_or_null("/root/main/digital_earthlings_container/thing_6")
	if reality_text_node and reality_text_node is Label3D:
		reality_text_node.text = new_reality.to_upper()
	
	# Update reality indicator color
	var reality_indicator = get_node_or_null("/root/main/digital_earthlings_container/thing_5")
	if reality_indicator and reality_indicator is MeshInstance3D:
		var material = reality_indicator.get_surface_material(0)
		if material:
			var color = get_reality_color(new_reality)
			material.albedo_color = color
	
	# Toggle container visibility
	toggle_reality_containers(old_reality, new_reality)
	
	# Apply visual effects with JSH system
	if main_node and main_node.has_method("sixth_dimensional_magic"):
		main_node.sixth_dimensional_magic(
			"call_function_single_get_node",
			"/root/main",
			"create_glitch_effect",
			["visuals", 50, "2s"]
		)
	
	# Emit signal for other systems
	reality_shifted.emit(old_reality, new_reality)
	
	# End transition after effects
	get_tree().create_timer(2.0).timeout.connect(func(): transition_in_progress = false)

func toggle_reality_containers(old_reality, new_reality):
	# Hide old reality container
	var old_container = get_node_or_null("/root/main/" + old_reality + "_reality_container")
	if old_container:
		old_container.visible = false
	
	# Show new reality container
	var new_container = get_node_or_null("/root/main/" + new_reality + "_reality_container")
	if new_container:
		new_container.visible = true

func get_reality_color(reality):
	match reality:
		"physical":
			return Color(0.2, 0.6, 1.0, 0.8)  # Blue
		"digital":
			return Color(0.1, 0.8, 0.2, 0.8)  # Green
		"astral":
			return Color(0.8, 0.3, 0.8, 0.8)  # Purple
		_:
			return Color(1.0, 1.0, 1.0, 0.8)  # White

func create_glitch_effect(parameter, intensity, duration_str):
	# Convert intensity to value
	var intensity_value = 50
	if intensity is String:
		match intensity:
			"low": intensity_value = 25
			"medium": intensity_value = 50
			"high": intensity_value = 75
			"extreme": intensity_value = 100
			_:
				# Try parsing as number
				var parsed = int(intensity)
				if parsed > 0:
					intensity_value = min(parsed, 100)
	else:
		intensity_value = min(int(intensity), 100)
	
	# Parse duration
	var duration = 2.0
	if duration_str.ends_with("s"):
		var seconds = float(duration_str.substr(0, duration_str.length() - 1))
		if seconds > 0:
			duration = seconds
	
	# Apply effects based on parameter
	match parameter:
		"visuals":
			apply_visual_glitch(intensity_value, duration)
		"physics":
			apply_physics_glitch(intensity_value, duration)
		"audio":
			apply_audio_glitch(intensity_value, duration)
	#	"time":
	#		apply_time_glitch(intensity_value, duration)
		_:
			# Default to visual glitch
			apply_visual_glitch(intensity_value, duration)
	
	# Remember this glitch
#	remember("glitch_" + parameter, {"intensity": intensity_value, "duration": duration})

func apply_visual_glitch(intensity, duration):
	# Apply screen distortion effect
	var glitch_strength = intensity / 100.0
	
	# In a real implementation, this would apply shader effects
	# For JSH integration we'll use the fourth dimensional magic
	if main_node and main_node.has_method("the_fourth_dimensional_magic"):
		# Apply to all reality containers
		for reality in REALITY_STATES:
			var container_path = reality + "_reality_container"
			main_node.the_fourth_dimensional_magic(
				"apply_effect",
				container_path,
				{
					"effect": "glitch",
					"strength": glitch_strength,
					"duration": duration
				}
			)
	
	# Reset after duration
	get_tree().create_timer(duration).timeout.connect(func(): print("Visual glitch effect ended"))

func apply_physics_glitch(intensity, duration):
	# Apply physics anomalies
	var glitch_strength = intensity / 100.0
	var original_gravity = Vector2(0, 9.8)
	
	# Alter gravity based on intensity
	var new_gravity = Vector2(
		(randf() - 0.5) * glitch_strength * 5.0,
		9.8 * (1.0 - glitch_strength / 2.0)
	)
	


func apply_audio_glitch(intensity, duration):
	# Apply audio distortion
	var glitch_strength = intensity / 100.0
	
	# In a real implementation, this would apply audio effects
	# For now, just simulate
	print("🔊 Audio glitch applied with strength " + str(glitch_strength))
	
	# Reset after duration













#################
## snakes know things too
## i know








# Add these functions to your main script that handles menu interactions

# Handler for Snake game menu options
func handle_snake_menu_interaction(option, difficulty = "normal"):
	print("Snake menu option: ", option)
	
	match option:
		"Snake Game":
			# Show Snake Game submenu
			print("something")
			#show_menu_scene("akashic_records", 11)  # Show the difficulty selection menu
		"Back":
			# Return to main menu
			print("something")
			#show_menu_scene("akashic_records", 10)  # Back to main menu with Snake option
		"Easy Mode":
			# Launch Snake game with easy settings
			launch_snake_game("easy")
		"Normal Mode":
			# Launch Snake game with normal settings
			launch_snake_game("normal")
		"Hard Mode":
			# Launch Snake game with hard settings
			launch_snake_game("hard")
		"Instructions":
			# Show instructions
			print("something")
			#show_menu_scene("akashic_records", 12)  # Show the instructions screen
		"High Scores":
			# Show high scores (would need to be implemented)
			display_high_scores()

# Launch the Snake game with the given difficulty
func launch_snake_game(difficulty):
	print("Launching Snake game with difficulty: ", difficulty)
	
	# First make sure the snake game container exists
	var container_name = "snake_game_container"
	var container_node# = get_node_or_null(container_name)
	
	if not container_node:
		# Create it if it doesn't exist
		#three_stages_of_creation_snake("snake_game")
		container_node# = get_node_or_null(container_name)
	
	if container_node:
		# Set difficulty
		var snake_game = container_node.get_node_or_null("JSHSnakeGame")
		if snake_game:
			# Apply difficulty settings if the snake game supports it
			match difficulty:
				"easy":
					# Slower game speed, larger food, etc.
					snake_game.current_speed = 1
				"normal":
					# Default settings
					snake_game.current_speed = 2
				"hard":
					# Faster game speed, obstacles, etc.
					snake_game.current_speed = 3
		
		# Hide the menu
		var menu_container# = get_node_or_null("akashic_records")
		if menu_container:
			menu_container.visible = false
		
		# Show the snake game
		#show_snake_game()
	else:
		print("Failed to create snake game container")

# Display high scores
func display_high_scores():
	print("Displaying high scores")
	
	# This would need to be implemented with your score saving/loading system
	# For now, just display a placeholder message
	var info_text# = get_node_or_null("snake_game_container/thing_103")
	if info_text and info_text is Label3D:
		info_text.text = "High scores not implemented yet."
	
	# You might want to show this on a different UI element in your menu system

# Snake Game Button Event Handler
# Add this to wherever you process button interactions in your game
func process_snake_button_click(button_name):
	# Check if the button is in the Snake Game menu
	if button_name in ["Snake Game", "Easy Mode", "Normal Mode", "Hard Mode", 
					  "Instructions", "High Scores"]:
		handle_snake_menu_interaction(button_name)
		return true
	# Check for back button in Snake submenu contexts
	elif button_name == "Back":
		# You'll need logic to determine which menu we're backing out from
		var current_menu = get_current_menu_context()
		if current_menu in ["snake_difficulty", "snake_instructions", "snake_highscores"]:
			handle_snake_menu_interaction("Back")
			return true
	
	# Not a Snake Game related button
	return false

# Helper to determine current menu context
func get_current_menu_context():
	# This would need to be implemented based on your menu system
	# Here's a simple version based on visible scene IDs
	
	var records_node# = get_node_or_null("akashic_records")
	if records_node:
		var thing_7 = records_node.get_node_or_null("thing_7")
		if thing_7 and thing_7.has_meta("current_scene"):
			var scene_id = thing_7.get_meta("current_scene")
			match scene_id:
				"scene_11": return "snake_difficulty"
				"scene_12": return "snake_instructions"
				# Add other contexts as needed
	
	return "unknown"
