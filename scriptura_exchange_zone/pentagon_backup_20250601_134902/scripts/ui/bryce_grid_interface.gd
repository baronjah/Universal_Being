# ==================================================
# SCRIPT NAME: bryce_grid_interface.gd
# DESCRIPTION: Bryce-style grid interface for entity selection
# PURPOSE: Clickable grid interface with optimal 16:9 layout
# CREATED: 2025-05-25 - Grid-based entity browser
# ==================================================

extends UniversalBeingBase
# Grid Configuration
const MIN_VERTICAL_GRIDS: int = 10
const ASPECT_RATIO_16_9: float = 16.0 / 9.0
const GRID_PADDING: int = 4
const CELL_MARGIN: int = 2

# Grid properties
var grid_columns: int = 0
var grid_rows: int = 0
var cell_size: Vector2 = Vector2.ZERO
var grid_cells: Array[Control] = []

# Visual properties
var grid_color: Color = Color(0.3, 0.3, 0.3, 0.8)
var cell_color: Color = Color(0.1, 0.1, 0.1, 0.6)
var hover_color: Color = Color(0.4, 0.6, 0.8, 0.8)
var selected_color: Color = Color(0.2, 0.8, 0.2, 0.8)

# Selection state
var selected_cell: int = -1
var hovered_cell: int = -1

# Entity data
var entity_catalog: Array[Dictionary] = []

signal cell_selected(cell_index: int, entity_data: Dictionary)
signal cell_hovered(cell_index: int, entity_data: Dictionary)

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[BryceGrid] Initializing grid interface...")
	
	# Calculate optimal grid layout
	_calculate_grid_layout()
	
	# Create grid cells
	_create_grid_cells()
	
	# Connect to resize events
	resized.connect(_on_window_resized)
	
	# Load sample entities
	_load_sample_entities()

## Calculate optimal grid layout for 16:9 ratio
# INPUT: None (uses window size)
# PROCESS: Calculates grid dimensions ensuring min 10 vertical cells
# OUTPUT: None
# CHANGES: grid_columns, grid_rows, cell_size
# CONNECTION: Called on ready and resize
func _calculate_grid_layout() -> void:
	var window_size = get_viewport_rect().size
	var usable_size = window_size - Vector2(GRID_PADDING * 2, GRID_PADDING * 2)
	
	# Start with minimum vertical grids
	grid_rows = MIN_VERTICAL_GRIDS
	
	# Calculate cell height based on rows
	var cell_height = usable_size.y / grid_rows
	
	# Calculate columns based on aspect ratio
	# For 16:9, we want cells to be roughly square
	var cell_width = cell_height  # Square cells
	grid_columns = int(usable_size.x / cell_width)
	
	# Ensure we have a reasonable number of columns
	grid_columns = max(grid_columns, int(grid_rows * ASPECT_RATIO_16_9))
	
	# Recalculate cell size to fit exactly
	cell_size = Vector2(
		usable_size.x / grid_columns,
		usable_size.y / grid_rows
	)
	
	print("[BryceGrid] Grid layout: %d x %d, cell size: %s" % [grid_columns, grid_rows, cell_size])

## Create grid cells
# INPUT: None
# PROCESS: Creates clickable grid cells
# OUTPUT: None
# CHANGES: Populates grid_cells array
# CONNECTION: Called after layout calculation
func _create_grid_cells() -> void:
	# Clear existing cells
	for cell in grid_cells:
		cell.queue_free()
	grid_cells.clear()
	
	# Create new cells
	for row in range(grid_rows):
		for col in range(grid_columns):
			var cell = _create_cell(col, row)
			add_child(cell)
			grid_cells.append(cell)

func _create_cell(col: int, row: int) -> Control:
	var cell = Panel.new()
	var cell_index = row * grid_columns + col
	
	# Position and size
	cell.position = Vector2(
		GRID_PADDING + col * cell_size.x + CELL_MARGIN,
		GRID_PADDING + row * cell_size.y + CELL_MARGIN
	)
	cell.size = cell_size - Vector2(CELL_MARGIN * 2, CELL_MARGIN * 2)
	
	# Styling
	var style = StyleBoxFlat.new()
	style.bg_color = cell_color
	style.border_color = grid_color
	style.set_border_width_all(1)
	cell.add_theme_stylebox_override("panel", style)
	
	# Make it interactive
	cell.mouse_filter = Control.MOUSE_FILTER_PASS
	cell.gui_input.connect(_on_cell_input.bind(cell_index))
	cell.mouse_entered.connect(_on_cell_hover.bind(cell_index))
	cell.mouse_exited.connect(_on_cell_unhover.bind(cell_index))
	
	# Add content label
	var label = Label.new()
	label.text = str(cell_index)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	FloodgateController.universal_add_child(label, cell)
	
	return cell

func _on_cell_input(event: InputEvent, cell_index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_select_cell(cell_index)

func _on_cell_hover(cell_index: int) -> void:
	hovered_cell = cell_index
	_update_cell_visual(cell_index)
	
	if cell_index < entity_catalog.size():
		emit_signal("cell_hovered", cell_index, entity_catalog[cell_index])

func _on_cell_unhover(cell_index: int) -> void:
	if hovered_cell == cell_index:
		hovered_cell = -1
		_update_cell_visual(cell_index)

func _select_cell(cell_index: int) -> void:
	# Deselect previous
	if selected_cell >= 0:
		_update_cell_visual(selected_cell)
	
	selected_cell = cell_index
	_update_cell_visual(cell_index)
	
	if cell_index < entity_catalog.size():
		emit_signal("cell_selected", cell_index, entity_catalog[cell_index])
		print("[BryceGrid] Selected: %s" % entity_catalog[cell_index].name)

func _update_cell_visual(cell_index: int) -> void:
	if cell_index >= grid_cells.size():
		return
		
	var cell = grid_cells[cell_index]
	var style = cell.get_theme_stylebox("panel") as StyleBoxFlat
	
	# Determine color based on state
	if cell_index == selected_cell:
		style.bg_color = selected_color
	elif cell_index == hovered_cell:
		style.bg_color = hover_color
	else:
		style.bg_color = cell_color
	
	# Update entity preview if available
	if cell_index < entity_catalog.size():
		var label = cell.get_child(0) as Label
		label.text = entity_catalog[cell_index].name

func _on_window_resized() -> void:
	_calculate_grid_layout()
	_create_grid_cells()
	_populate_grid()

## Load sample entities for testing
# INPUT: None
# PROCESS: Creates sample entity catalog
# OUTPUT: None
# CHANGES: entity_catalog array
# CONNECTION: Called on ready
func _load_sample_entities() -> void:
	entity_catalog = [
		{"name": "Ragdoll", "type": "character", "icon": "👤"},
		{"name": "Tree", "type": "nature", "icon": "🌳"},
		{"name": "Rock", "type": "terrain", "icon": "🪨"},
		{"name": "Bird", "type": "creature", "icon": "🦅"},
		{"name": "Cube", "type": "primitive", "icon": "⬜"},
		{"name": "Sphere", "type": "primitive", "icon": "⚪"},
		{"name": "Light", "type": "effect", "icon": "💡"},
		{"name": "Water", "type": "terrain", "icon": "💧"},
		{"name": "Fire", "type": "effect", "icon": "🔥"},
		{"name": "Grass", "type": "nature", "icon": "🌿"},
		{"name": "Cloud", "type": "atmosphere", "icon": "☁️"},
		{"name": "Star", "type": "celestial", "icon": "⭐"},
	]
	
	_populate_grid()

func _populate_grid() -> void:
	for i in range(min(entity_catalog.size(), grid_cells.size())):
		_update_cell_visual(i)

## Get grid info for external use
# INPUT: None
# PROCESS: Returns current grid configuration
# OUTPUT: Dictionary with grid info
# CHANGES: None
# CONNECTION: Can be called by other systems

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
func get_grid_info() -> Dictionary:
	return {
		"columns": grid_columns,
		"rows": grid_rows,
		"total_cells": grid_columns * grid_rows,
		"cell_size": cell_size,
		"aspect_ratio": float(grid_columns) / float(grid_rows)
	}