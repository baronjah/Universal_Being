# ==================================================
# SCRIPT NAME: unified_grid_list_system.gd
# DESCRIPTION: Unified Grid/List/Page system with 999 items per page
# PURPOSE: Console-like navigation for visual interfaces
# CREATED: 2025-05-25 - Grid = List = Console Commands
# ==================================================

extends UniversalBeingBase
# Page Constants
const MAX_ITEMS_PER_PAGE: int = 999
const GRID_MAX_COLUMNS: int = 33  # 33x30 ≈ 990 items
const GRID_MAX_ROWS: int = 30
const LIST_ITEMS_PER_SCREEN: int = 50

# Display Modes
enum DisplayMode {
	GRID_VIEW,      # Visual grid layout
	LIST_VIEW,      # Vertical list
	CONSOLE_VIEW,   # Text commands
	HYBRID_VIEW     # Grid with console overlay
}

# Navigation States
enum NavState {
	BROWSING,       # Can move cursor
	SELECTING,      # Choosing item
	EXECUTING,      # Running command
	MENU_OPEN       # Sub-menu active
}

# Data Structure (matches your main.gd pattern)
var data_pages: Dictionary = {
	"active": {},     # Currently visible page
	"pending": {},    # Loading/transitioning
	"cached": {},     # Previously viewed
	"archived": {}    # Long-term storage
}

# Current State
var current_page: int = 0
var current_mode: DisplayMode = DisplayMode.GRID_VIEW
var nav_state: NavState = NavState.BROWSING
var cursor_position: Vector2i = Vector2i.ZERO
var selected_items: Array[int] = []

# Visual Components
@onready var grid_container: GridContainer = $GridContainer
@onready var list_container: VBoxContainer = $ListContainer
@onready var console_overlay: LineEdit = $ConsoleOverlay
@onready var page_indicator: Label = $PageIndicator
@onready var mode_switcher: Control = $ModeSwitcher

# Input Mapping
var input_actions: Dictionary = {
	"move_up": _move_cursor.bind(Vector2i.UP),
	"move_down": _move_cursor.bind(Vector2i.DOWN),
	"move_left": _move_cursor.bind(Vector2i.LEFT),
	"move_right": _move_cursor.bind(Vector2i.RIGHT),
	"select": _select_current,
	"execute": _execute_current,
	"next_page": _next_page,
	"prev_page": _prev_page,
	"toggle_mode": _cycle_display_mode,
	"open_console": _toggle_console
}

# Floodgate States (from your description)
var player_states: Dictionary = {
	"can_move_camera": true,
	"can_move_player": true,
	"menu_active": false,
	"console_active": false,
	"ui_active": false
}

signal item_selected(page: int, index: int, data: Dictionary)
signal command_executed(command: String, args: Array)
signal page_changed(new_page: int)
signal mode_changed(new_mode: DisplayMode)

func _ready() -> void:
	print("[UnifiedGrid] Initializing unified grid/list system...")
	
	# Setup display modes
	_setup_grid_container()
	_setup_list_container()
	_setup_console_overlay()
	
	# Load first page
	_load_page(0)
	
	# Connect input
	set_process_unhandled_input(true)

## Page Management
# INPUT: Page number to load
# PROCESS: Moves page from cached/pending to active
# OUTPUT: None
# CHANGES: data_pages active state
# CONNECTION: Called on navigation
func _load_page(page_num: int) -> void:
	# Move current to cached
	if data_pages.active.has("current"):
		var current = data_pages.active.current
		data_pages.cached[current_page] = current
	
	# Check if requested page exists
	if data_pages.cached.has(page_num):
		data_pages.active.current = data_pages.cached[page_num]
		data_pages.cached.erase(page_num)
	elif data_pages.pending.has(page_num):
		# Wait for pending to load
		_wait_for_pending_page(page_num)
	else:
		# Generate new page
		_generate_page_data(page_num)
	
	current_page = page_num
	_refresh_display()
	emit_signal("page_changed", page_num)

func _generate_page_data(page_num: int) -> void:
	var page_data = {
		"items": [],
		"metadata": {
			"page_number": page_num,
			"timestamp": Time.get_ticks_msec(),
			"item_count": 0
		}
	}
	
	# Generate items based on page number
	var start_index = page_num * MAX_ITEMS_PER_PAGE
	var item_count = min(MAX_ITEMS_PER_PAGE, 100)  # Demo: 100 items per page
	
	for i in range(item_count):
		var item_index = start_index + i
		page_data.items.append({
			"id": "item_%d" % item_index,
			"name": "Item %d" % item_index,
			"type": _get_item_type(item_index),
			"command": "use item_%d" % item_index,
			"icon": _get_item_icon(item_index),
			"state": "active"
		})
	
	page_data.metadata.item_count = item_count
	data_pages.active.current = page_data

func _get_item_type(index: int) -> String:
	var types = ["entity", "action", "setting", "tool", "data"]
	return types[index % types.size()]

func _get_item_icon(index: int) -> String:
	var icons = ["📦", "⚡", "⚙️", "🔧", "💾", "🎮", "🌟", "🔥"]
	return icons[index % icons.size()]

## Display Mode Management
# INPUT: None
# PROCESS: Cycles through display modes
# OUTPUT: None
# CHANGES: current_mode and visible containers
# CONNECTION: Input action or UI button
func _cycle_display_mode() -> void:
	current_mode = ((current_mode as int) + 1) % DisplayMode.values().size() as DisplayMode
	
	# Update visibility
	grid_container.visible = current_mode in [DisplayMode.GRID_VIEW, DisplayMode.HYBRID_VIEW]
	list_container.visible = current_mode == DisplayMode.LIST_VIEW
	console_overlay.visible = current_mode in [DisplayMode.CONSOLE_VIEW, DisplayMode.HYBRID_VIEW]
	
	_refresh_display()
	emit_signal("mode_changed", current_mode)

## Grid Navigation
# INPUT: Direction vector
# PROCESS: Moves cursor in grid
# OUTPUT: None
# CHANGES: cursor_position
# CONNECTION: Arrow keys or WASD
func _move_cursor(direction: Vector2i) -> void:
	if nav_state != NavState.BROWSING:
		return
	
	var new_pos = cursor_position + direction
	
	# Wrap around grid
	if current_mode == DisplayMode.GRID_VIEW:
		new_pos.x = wrapi(new_pos.x, 0, GRID_MAX_COLUMNS)
		new_pos.y = wrapi(new_pos.y, 0, GRID_MAX_ROWS)
	elif current_mode == DisplayMode.LIST_VIEW:
		new_pos.y = clamp(new_pos.y, 0, LIST_ITEMS_PER_SCREEN - 1)
		new_pos.x = 0
	
	cursor_position = new_pos
	_update_cursor_visual()

func _update_cursor_visual() -> void:
	# Update visual cursor based on mode
	if current_mode == DisplayMode.GRID_VIEW:
		var index = cursor_position.y * GRID_MAX_COLUMNS + cursor_position.x
		if index < grid_container.get_child_count():
			_highlight_item(grid_container.get_child(index))
	elif current_mode == DisplayMode.LIST_VIEW:
		if cursor_position.y < list_container.get_child_count():
			_highlight_item(list_container.get_child(cursor_position.y))

## Console Integration
# INPUT: Console command string
# PROCESS: Parses and executes command
# OUTPUT: Command result
# CHANGES: Depends on command
# CONNECTION: Console overlay or direct call
func _execute_console_command(command: String) -> void:
	var parts = command.split(" ")
	if parts.size() == 0:
		return
	
	var cmd = parts[0]
	var args = parts.slice(1)
	
	# Page navigation commands
	match cmd:
		"page":
			if args.size() > 0:
				_load_page(int(args[0]))
		"next":
			_next_page()
		"prev":
			_prev_page()
		"goto":
			if args.size() > 0:
				var index = int(args[0])
				_goto_item(index)
		"select":
			if args.size() > 0:
				_select_item_by_id(args[0])
		"mode":
			if args.size() > 0:
				_set_display_mode(args[0])
		_:
			# Forward to game console
			emit_signal("command_executed", cmd, args)

func _goto_item(global_index: int) -> void:
	var page = global_index / MAX_ITEMS_PER_PAGE
	var local_index = global_index % MAX_ITEMS_PER_PAGE
	
	if page != current_page:
		_load_page(page)
	
	# Position cursor
	if current_mode == DisplayMode.GRID_VIEW:
		cursor_position.x = local_index % GRID_MAX_COLUMNS
		cursor_position.y = local_index / GRID_MAX_COLUMNS
	else:
		cursor_position.y = local_index

## State Management (Floodgates)
# INPUT: State name and value
# PROCESS: Updates player state
# OUTPUT: None
# CHANGES: player_states
# CONNECTION: Game state changes

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
func set_player_state(state_name: String, value: bool) -> void:
	if player_states.has(state_name):
		player_states[state_name] = value
		
		# Update UI based on states
		if state_name == "menu_active":
			set_process_unhandled_input(value)
			visible = value
			
			if value:
				# Disable player/camera movement
				player_states.can_move_camera = false
				player_states.can_move_player = false
			else:
				# Restore movement
				player_states.can_move_camera = true
				player_states.can_move_player = true

## Unified Input Handler
# INPUT: Input event
# PROCESS: Routes to appropriate handler based on state
# OUTPUT: None
# CHANGES: Various based on input
# CONNECTION: _unhandled_input
func _unhandled_input(event: InputEvent) -> void:
	# Console takes priority
	if console_overlay.visible and console_overlay.has_focus():
		return
	
	# Check floodgate states
	if not player_states.menu_active:
		return
	
	# Tab cycles through items
	if event.is_action_pressed("ui_focus_next"):
		_cycle_focus(1)
	elif event.is_action_pressed("ui_focus_prev"):
		_cycle_focus(-1)
	
	# Execute mapped actions
	for action in input_actions:
		if event.is_action_pressed(action):
			input_actions[action].call()

func _cycle_focus(direction: int) -> void:
	if current_mode == DisplayMode.LIST_VIEW:
		cursor_position.y = wrapi(cursor_position.y + direction, 0, LIST_ITEMS_PER_SCREEN)
	else:
		var current_index = cursor_position.y * GRID_MAX_COLUMNS + cursor_position.x
		current_index = wrapi(current_index + direction, 0, MAX_ITEMS_PER_PAGE)
		cursor_position.x = current_index % GRID_MAX_COLUMNS
		cursor_position.y = current_index / GRID_MAX_COLUMNS
	
	_update_cursor_visual()

## Grid/List Builders
func _setup_grid_container() -> void:
	grid_container.columns = GRID_MAX_COLUMNS
	grid_container.add_theme_constant_override("h_separation", 2)
	grid_container.add_theme_constant_override("v_separation", 2)

func _setup_list_container() -> void:
	# List shows fewer items but with more detail
	pass

func _refresh_display() -> void:
	if not data_pages.active.has("current"):
		return
	
	var page_data = data_pages.active.current
	
	# Clear existing
	for child in grid_container.get_children():
		child.queue_free()
	for child in list_container.get_children():
		child.queue_free()
	
	# Populate based on mode
	if current_mode in [DisplayMode.GRID_VIEW, DisplayMode.HYBRID_VIEW]:
		_populate_grid(page_data.items)
	
	if current_mode == DisplayMode.LIST_VIEW:
		_populate_list(page_data.items)
	
	# Update page indicator
	page_indicator.text = "Page %d | Items: %d" % [current_page, page_data.metadata.item_count]

func _populate_grid(items: Array) -> void:
	for item in items:
		var cell = _create_grid_cell(item)
		FloodgateController.universal_add_child(cell, grid_container)

func _populate_list(items: Array) -> void:
	for item in items:
		var row = _create_list_row(item)
		FloodgateController.universal_add_child(row, list_container)

func _create_grid_cell(item: Dictionary) -> Control:
	var cell = Button.new()
	cell.text = item.icon
	cell.tooltip_text = item.name
	cell.custom_minimum_size = Vector2(32, 32)
	cell.pressed.connect(_on_item_clicked.bind(item))
	return cell

func _create_list_row(item: Dictionary) -> Control:
	var row = HBoxContainer.new()
	
	var icon = Label.new()
	icon.text = item.icon
	FloodgateController.universal_add_child(icon, row)
	
	var name_label = Label.new()
	name_label.text = item.name
	name_label.custom_minimum_size.x = 200
	FloodgateController.universal_add_child(name_label, row)
	
	var type = Label.new()
	type.text = "[%s]" % item.type
	FloodgateController.universal_add_child(type, row)
	
	return row

## Selection and Execution
func _select_current() -> void:
	var index = cursor_position.y * GRID_MAX_COLUMNS + cursor_position.x
	if data_pages.active.has("current"):
		var items = data_pages.active.current.items
		if index < items.size():
			emit_signal("item_selected", current_page, index, items[index])

func _execute_current() -> void:
	var index = cursor_position.y * GRID_MAX_COLUMNS + cursor_position.x
	if data_pages.active.has("current"):
		var items = data_pages.active.current.items
		if index < items.size():
			var command = items[index].command
			_execute_console_command(command)

## Helper Functions
func _next_page() -> void:
	_load_page(current_page + 1)

func _prev_page() -> void:
	if current_page > 0:
		_load_page(current_page - 1)

func _toggle_console() -> void:
	console_overlay.visible = !console_overlay.visible
	if console_overlay.visible:
		console_overlay.grab_focus()
		player_states.console_active = true
	else:
		player_states.console_active = false

func _highlight_item(item: Control) -> void:
	# Visual feedback for cursor
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.5, 0.8, 0.5)
	item.add_theme_stylebox_override("hover", style)

func _on_item_clicked(item: Dictionary) -> void:
	emit_signal("item_selected", current_page, -1, item)

## Setup console overlay
func _setup_console_overlay() -> void:
	console_overlay = LineEdit.new()
	console_overlay.name = "ConsoleOverlay"
	console_overlay.visible = false
	console_overlay.text_submitted.connect(_execute_console_command)
	add_child(console_overlay)

## Wait for pending page to load
func _wait_for_pending_page(page_num: int) -> void:
	# Simple wait - in real implementation would use signals
	var wait_time = 0.0
	while data_pages.pending.has(page_num) and wait_time < 2.0:
		await get_tree().process_frame
		wait_time += get_process_delta_time()
	
	if data_pages.pending.has(page_num):
		data_pages.active.current = data_pages.pending[page_num]
		data_pages.pending.erase(page_num)

## Select item by ID
func _select_item_by_id(item_id: String) -> void:
	if data_pages.active.has("current"):
		var items = data_pages.active.current.items
		for i in range(items.size()):
			if items[i].id == item_id:
				emit_signal("item_selected", current_page, i, items[i])
				break

## Set display mode by name
func _set_display_mode(mode_name: String) -> void:
	match mode_name.to_lower():
		"grid":
			current_mode = DisplayMode.GRID_VIEW
		"list":
			current_mode = DisplayMode.LIST_VIEW
		"console":
			current_mode = DisplayMode.CONSOLE_VIEW
		"hybrid":
			current_mode = DisplayMode.HYBRID_VIEW
	
	_cycle_display_mode()
