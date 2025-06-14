extends UniversalBeingBase
class_name ConsoleWorldView
# Console World View - Text-based representation of the 3D world
# Shows entities, their states, and relationships in ASCII

@onready var world_display: RichTextLabel = $WorldDisplay
@onready var mini_map: TextureRect = $MiniMap

# World data
var world_entities: Dictionary = {}
var world_grid: Array = []
var grid_size: Vector2i = Vector2i(80, 40)
var view_center: Vector2 = Vector2.ZERO
var zoom_level: float = 1.0

# Display settings
var show_coordinates: bool = true
var show_entity_states: bool = true
var show_distances: bool = false
var update_rate: float = 0.1

# Symbols for different entity types
var entity_symbols: Dictionary = {
	"ragdoll": "@",
	"tree": "T",
	"rock": "o",
	"building": "#",
	"item": "*",
	"npc": "&",
	"player": "@",
	"enemy": "!",
	"pathway": ".",
	"water": "~",
	"grass": ",",
	"wall": "#"
}

# Colors for different states
var state_colors: Dictionary = {
	"idle": "gray",
	"walking": "white",
	"running": "yellow",
	"jumping": "cyan",
	"falling": "red",
	"interacting": "green",
	"combat": "red",
	"dead": "dark_gray"
}

var update_timer: float = 0.0

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Initialize grid
	_initialize_world_grid()
	
	# Connect to layer system
	var layer_system = get_node_or_null("/root/LayerRealitySystem")
	if layer_system:
		layer_system.layer_visibility_changed.connect(_on_layer_visibility_changed)
	
	# Set monospace font for ASCII display
	if world_display:
		var font = load("res://fonts/monospace.tres")
		if font:
			world_display.add_theme_font_override("normal_font", font)

func _initialize_world_grid() -> void:
	world_grid.clear()
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			row.append(" ")
		world_grid.append(row)

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	update_timer += delta
	if update_timer >= update_rate:
		update_timer = 0.0
		_update_world_display()

func _update_world_display() -> void:
	if not world_display:
		return
	
	# Clear grid
	_initialize_world_grid()
	
	# Place entities on grid
	for entity_id in world_entities:
		var entity_data = world_entities[entity_id]
		_place_entity_on_grid(entity_data)
	
	# Convert grid to text
	var display_text = _generate_display_text()
	world_display.text = display_text

func _place_entity_on_grid(entity_data: Dictionary) -> void:
	var world_pos = entity_data.get("position", Vector3.ZERO)
	var grid_pos = _world_to_grid(Vector2(world_pos.x, world_pos.z))
	
	if grid_pos.x >= 0 and grid_pos.x < grid_size.x and grid_pos.y >= 0 and grid_pos.y < grid_size.y:
		var symbol = entity_symbols.get(entity_data.get("type", "generic"), "?")
		var state = entity_data.get("state", "idle")
		
		# Add color based on state
		if state_colors.has(state):
			symbol = "[color=%s]%s[/color]" % [state_colors[state], symbol]
		
		world_grid[grid_pos.y][grid_pos.x] = symbol

func _world_to_grid(world_pos: Vector2) -> Vector2i:
	var adjusted_pos = (world_pos - view_center) / zoom_level
	var grid_x = int((adjusted_pos.x + grid_size.x / 2.0))
	var grid_y = int((adjusted_pos.y + grid_size.y / 2.0))
	return Vector2i(grid_x, grid_y)

func _generate_display_text() -> String:
	var lines = []
	
	# Header
	lines.append("[center][b]== CONSOLE WORLD VIEW ==[/b][/center]")
	lines.append("[center]Center: (%.1f, %.1f) | Zoom: %.1fx[/center]" % [view_center.x, view_center.y, zoom_level])
	lines.append("")
	
	# Top border
	lines.append("+" + "-".repeat(grid_size.x) + "+")
	
	# Grid content
	for y in range(grid_size.y):
		var line = "|"
		for x in range(grid_size.x):
			line += world_grid[y][x]
		line += "|"
		lines.append(line)
	
	# Bottom border
	lines.append("+" + "-".repeat(grid_size.x) + "+")
	
	# Entity list
	if show_entity_states:
		lines.append("")
		lines.append("[b]Active Entities:[/b]")
		for entity_id in world_entities:
			var entity = world_entities[entity_id]
			var pos = entity.get("position", Vector3.ZERO)
			var state = entity.get("state", "unknown")
			lines.append("  %s [%s] @ (%.1f, %.1f, %.1f)" % [
				entity_id,
				state,
				pos.x, pos.y, pos.z
			])
	
	# Coordinate display
	if show_coordinates:
		lines.append("")
		lines.append("[color=gray]Grid: %dx%d | World: %.1f units[/color]" % [
			grid_size.x, grid_size.y,
			grid_size.x * zoom_level
		])
	
	return "\n".join(lines)

# API for updating entities

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func update_entity(entity_id: String, data: Dictionary) -> void:
	world_entities[entity_id] = data

func remove_entity(entity_id: String) -> void:
	world_entities.erase(entity_id)

func clear_entities() -> void:
	world_entities.clear()

# Camera controls
func pan_view(direction: Vector2) -> void:
	view_center += direction * zoom_level

func zoom_view(factor: float) -> void:
	zoom_level = clamp(zoom_level * factor, 0.1, 10.0)

func center_on_position(world_pos: Vector3) -> void:
	view_center = Vector2(world_pos.x, world_pos.z)

# Input handling
func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	if not visible:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_W:
				pan_view(Vector2.UP)
			KEY_S:
				pan_view(Vector2.DOWN)
			KEY_A:
				pan_view(Vector2.LEFT)
			KEY_D:
				pan_view(Vector2.RIGHT)
			KEY_Q:
				zoom_view(0.8)
			KEY_E:
				zoom_view(1.2)
			KEY_R:
				view_center = Vector2.ZERO
				zoom_level = 1.0

func _on_layer_visibility_changed(layer: int, is_visible: bool) -> void:
	if layer == 0:  # TEXT layer
		self.visible = is_visible

# Integration with console commands
func handle_console_command(command: String, args: Array) -> String:
	match command:
		"world_center":
			if args.size() >= 2:
				view_center = Vector2(float(args[0]), float(args[1]))
				return "World view centered at " + str(view_center)
		"world_zoom":
			if args.size() >= 1:
				zoom_level = float(args[0])
				return "World zoom set to " + str(zoom_level)
		"world_show":
			if args.size() >= 1:
				match args[0]:
					"coords":
						show_coordinates = true
					"states":
						show_entity_states = true
					"distances":
						show_distances = true
				return "Enabled " + args[0]
		"world_hide":
			if args.size() >= 1:
				match args[0]:
					"coords":
						show_coordinates = false
					"states":
						show_entity_states = false
					"distances":
						show_distances = false
				return "Disabled " + args[0]
	
	return "Unknown world command"