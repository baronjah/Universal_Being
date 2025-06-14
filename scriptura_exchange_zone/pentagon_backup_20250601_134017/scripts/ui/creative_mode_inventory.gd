# ==================================================
# SCRIPT NAME: creative_mode_inventory.gd
# DESCRIPTION: Minecraft-style creative mode inventory with "i" key
# PURPOSE: Visual asset browser for quick world building
# CREATED: 2025-05-24 - Creative mode interface
# ==================================================

extends UniversalBeingBase
signal item_selected(item_type: String, item_data: Dictionary)

# ================================
# UI COMPONENTS
# ================================

var main_panel: PanelContainer
var category_bar: HBoxContainer
var grid_container: GridContainer
var scroll_container: ScrollContainer
var close_button: Button

# Grid settings
const GRID_COLUMNS = 8
const SLOT_SIZE = Vector2(80, 100)
const PREVIEW_SIZE = Vector2(64, 64)

# ================================
# DATA
# ================================

var asset_library: Node
var current_category: String = "all"
var item_slots: Array = []

# Categories from existing system
var categories = {
	"all": {"name": "All Items", "color": Color.WHITE},
	"objects": {"name": "Objects", "color": Color.GREEN},
	"creatures": {"name": "Creatures", "color": Color.CYAN},
	"terrain": {"name": "Terrain", "color": Color.BROWN},
	"effects": {"name": "Effects", "color": Color.YELLOW},
	"custom": {"name": "Custom", "color": Color.PURPLE}
}

# Asset type to category mapping
var type_to_category = {
	"tree": "objects",
	"rock": "objects", 
	"box": "objects",
	"ball": "objects",
	"ramp": "objects",
	"bush": "objects",
	"fruit": "objects",
	"ragdoll": "creatures",
	"bird": "creatures",
	"pigeon": "creatures",
	"astral_being": "creatures",
	"world": "terrain",
	"pathway": "terrain", 
	"sun": "effects"
}

# ================================
# INITIALIZATION
# ================================

func _ready() -> void:
	# Hide by default
	visible = false
	set_process_unhandled_input(true)
	
	# Create UI
	_create_ui()
	
	# Get asset library reference
	asset_library = get_node_or_null("/root/AssetLibrary")
	if not asset_library:
		print("[CreativeInventory] AssetLibrary not found!")
		return
	
	# Populate with assets
	_populate_inventory()

func _create_ui() -> void:
	# Main panel
	main_panel = PanelContainer.new()
	main_panel.name = "CreativeInventoryPanel"
	add_child(main_panel)
	
	# Set size and position
	main_panel.size = Vector2(700, 500)
	main_panel.position = (get_viewport().size - main_panel.size) / 2
	
	# Panel styling
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color.CYAN
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	main_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Main VBox
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	FloodgateController.universal_add_child(vbox, main_panel)
	
	# Title bar
	var title_bar = HBoxContainer.new()
	FloodgateController.universal_add_child(title_bar, vbox)
	
	var title_label = Label.new()
	title_label.text = "Creative Mode Inventory"
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color.CYAN)
	FloodgateController.universal_add_child(title_label, title_bar)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(spacer, title_bar)
	
	# Close button
	close_button = Button.new()
	close_button.text = "✕"
	close_button.custom_minimum_size = Vector2(30, 30)
	close_button.pressed.connect(_on_close_pressed)
	FloodgateController.universal_add_child(close_button, title_bar)
	
	# Category bar
	category_bar = HBoxContainer.new()
	category_bar.add_theme_constant_override("separation", 5)
	FloodgateController.universal_add_child(category_bar, vbox)
	
	# Create category buttons
	for cat_id in categories:
		var cat_data = categories[cat_id]
		var btn = Button.new()
		btn.text = cat_data.name
		btn.custom_minimum_size = Vector2(80, 30)
		btn.toggle_mode = true
		btn.button_group = ButtonGroup.new() if cat_id == "all" else category_bar.get_child(0).button_group
		btn.pressed.connect(_on_category_selected.bind(cat_id))
		
		# Style the button
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = cat_data.color * 0.3
		btn_style.border_width_left = 1
		btn_style.border_width_right = 1
		btn_style.border_width_top = 1
		btn_style.border_width_bottom = 1
		btn_style.border_color = cat_data.color
		btn.add_theme_stylebox_override("normal", btn_style)
		
		FloodgateController.universal_add_child(btn, category_bar)
	
	# Select "All" by default
	category_bar.get_child(0).button_pressed = true
	
	# Scroll container for grid
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(scroll_container, vbox)
	
	# Grid container
	grid_container = GridContainer.new()
	grid_container.columns = GRID_COLUMNS
	grid_container.add_theme_constant_override("h_separation", 5)
	grid_container.add_theme_constant_override("v_separation", 5)
	FloodgateController.universal_add_child(grid_container, scroll_container)

# ================================
# INPUT HANDLING
# ================================

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_toggle"):
		toggle_inventory()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and visible:
		hide_inventory()
		get_viewport().set_input_as_handled()

# ================================
# INVENTORY MANAGEMENT
# ================================


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
func toggle_inventory() -> void:
	if visible:
		hide_inventory()
	else:
		show_inventory()

func show_inventory() -> void:
	visible = true
	# Pause game or dim background
	get_tree().paused = true

func hide_inventory() -> void:
	visible = false
	get_tree().paused = false

func _populate_inventory() -> void:
	# Clear existing slots
	for slot in item_slots:
		slot.queue_free()
	item_slots.clear()
	
	# Get available items
	var items = _get_filtered_items()
	
	# Create slots for each item
	for item_id in items:
		var item_data = items[item_id]
		_create_item_slot(item_id, item_data)

func _get_filtered_items() -> Dictionary:
	# Get items from console commands list
	var all_items = {
		"tree": {"name": "Tree", "description": "Spawn a tree"},
		"rock": {"name": "Rock", "description": "Spawn a rock"},
		"box": {"name": "Box", "description": "Spawn a box"},
		"ball": {"name": "Ball", "description": "Spawn a bouncy ball"},
		"ramp": {"name": "Ramp", "description": "Spawn a ramp"},
		"bush": {"name": "Bush", "description": "Spawn a bush"},
		"fruit": {"name": "Fruit", "description": "Spawn a fruit"},
		"sun": {"name": "Sun", "description": "Spawn a light source"},
		"pathway": {"name": "Path", "description": "Spawn a pathway"},
		"ragdoll": {"name": "Ragdoll", "description": "Spawn a ragdoll character"},
		"bird": {"name": "Bird", "description": "Spawn a triangular bird"},
		"astral_being": {"name": "Astral Being", "description": "Spawn an astral helper"},
		"world": {"name": "World", "description": "Generate procedural terrain"}
	}
	
	# Filter by category
	if current_category == "all":
		return all_items
	
	var filtered = {}
	for item_id in all_items:
		var item_category = type_to_category.get(item_id, "custom")
		if item_category == current_category:
			filtered[item_id] = all_items[item_id]
	
	return filtered

func _create_item_slot(item_id: String, item_data: Dictionary) -> void:
	# Create slot container
	var slot = PanelContainer.new()
	slot.custom_minimum_size = SLOT_SIZE
	
	# Slot styling
	var slot_style = StyleBoxFlat.new()
	slot_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	slot_style.border_width_left = 1
	slot_style.border_width_right = 1
	slot_style.border_width_top = 1
	slot_style.border_width_bottom = 1
	slot_style.border_color = Color.GRAY
	slot.add_theme_stylebox_override("panel", slot_style)
	
	# Slot content
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	FloodgateController.universal_add_child(vbox, slot)
	
	# Preview image (placeholder for now)
	var preview = TextureRect.new()
	preview.custom_minimum_size = PREVIEW_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.texture = _generate_placeholder_icon(item_id)
	FloodgateController.universal_add_child(preview, vbox)
	
	# Item name
	var name_label = Label.new()
	name_label.text = item_data.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	FloodgateController.universal_add_child(name_label, vbox)
	
	# Click handling
	var button = Button.new()
	button.flat = true
	button.custom_minimum_size = SLOT_SIZE
	button.pressed.connect(_on_item_selected.bind(item_id, item_data))
	FloodgateController.universal_add_child(button, slot)
	
	# Add to grid
	FloodgateController.universal_add_child(slot, grid_container)
	item_slots.append(slot)

func _generate_placeholder_icon(item_id: String) -> ImageTexture:
	# Create a simple colored square as placeholder
	var image = Image.create(64, 64, false, Image.FORMAT_RGB8)
	
	# Choose color based on item type
	var color = Color.GRAY
	match item_id:
		"tree": color = Color.GREEN
		"rock": color = Color.GRAY
		"box": color = Color.BROWN
		"ball": color = Color.RED
		"bush": color = Color.DARK_GREEN
		"fruit": color = Color.ORANGE
		"sun": color = Color.YELLOW
		"water": color = Color.BLUE
		"ragdoll": color = Color.PINK
		"bird": color = Color.CYAN
		"astral_being": color = Color.PURPLE
		"world": color = Color.DARK_GRAY
	
	image.fill(color)
	
	var texture = ImageTexture.new()
	texture = ImageTexture.create_from_image(image)
	return texture

# ================================
# EVENT HANDLERS
# ================================

func _on_category_selected(category_id: String) -> void:
	current_category = category_id
	_populate_inventory()

func _on_item_selected(item_id: String, item_data: Dictionary) -> void:
	print("[CreativeInventory] Selected: " + item_id)
	
	# Execute the corresponding console command
	var console_manager = get_node_or_null("/root/ConsoleManager")
	if console_manager and console_manager.has_method("execute_command"):
		console_manager.execute_command(item_id, [])
	
	# Emit signal for other systems
	item_selected.emit(item_id, item_data)
	
	# Close inventory after selection (optional)
	# hide_inventory()

func _on_close_pressed() -> void:
	hide_inventory()

# ================================
# PUBLIC METHODS
# ================================

func refresh_inventory() -> void:
	_populate_inventory()

func set_category(category_id: String) -> void:
	if category_id in categories:
		current_category = category_id
		_populate_inventory()
		
		# Update button states
		for i in range(category_bar.get_child_count()):
			var btn = category_bar.get_child(i)
			var cat_keys = categories.keys()
			btn.button_pressed = (cat_keys[i] == category_id)