extends UniversalBeingBase
class_name HeightMapOverlay
# 2D Height Map Overlay - Shows world from above with height as colors
# Part of Layer 1 visualization

@onready var map_display: TextureRect = $MapDisplay
@onready var legend: RichTextLabel = $Legend

# Map data
var map_image: Image
var map_texture: ImageTexture
var map_size: Vector2i = Vector2i(512, 512)
var world_bounds: Rect2 = Rect2(-50, -50, 100, 100)

# Height mapping
var min_height: float = -10.0
var max_height: float = 50.0
var height_colors: Gradient

# Entity tracking
var entity_positions: Dictionary = {}
var entity_trails: Dictionary = {}
var trail_length: int = 20

# Update settings
var update_timer: float = 0.0
var update_interval: float = 0.1

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_initialize_map()
	_create_height_gradient()
	_setup_legend()

func _initialize_map() -> void:
	# Create image for map
	map_image = Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGB8)
	map_texture = ImageTexture.create_from_image(map_image)
	
	if map_display:
		map_display.texture = map_texture
	
	# Fill with base color
	map_image.fill(Color(0.1, 0.1, 0.2))  # Dark blue for base

func _create_height_gradient() -> void:
	height_colors = Gradient.new()
	height_colors.offsets = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
	height_colors.colors = [
		Color.BLUE,        # Deep water
		Color.CYAN,        # Shallow water
		Color.GREEN,       # Low ground
		Color.YELLOW,      # Mid ground
		Color.ORANGE,      # High ground
		Color.RED          # Mountains
	]

func _setup_legend() -> void:
	if not legend:
		return
	
	var legend_text = "[b]Height Legend:[/b]\n"
	legend_text += "[color=blue]▓[/color] Deep (-10m)\n"
	legend_text += "[color=cyan]▓[/color] Water (0m)\n"
	legend_text += "[color=green]▓[/color] Ground (10m)\n"
	legend_text += "[color=yellow]▓[/color] Hills (20m)\n"
	legend_text += "[color=orange]▓[/color] High (30m)\n"
	legend_text += "[color=red]▓[/color] Peak (40m+)\n"
	legend_text += "\nEntities:\n"
	legend_text += "[color=white]●[/color] Active\n"
	legend_text += "[color=gray]·[/color] Trail"
	
	legend.text = legend_text

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		_update_map()

func _update_map() -> void:
	# Fade the map slightly (creates trail effect)
	_fade_map()
	
	# Update height data from terrain
	_update_terrain_heights()
	
	# Draw entities
	_draw_entities()
	
	# Update texture
	map_texture.update(map_image)

func _fade_map() -> void:
	# Create fade effect for trails
	var pixels = map_image.get_data()
	for i in range(0, pixels.size(), 3):
		pixels[i] = int(pixels[i] * 0.98)      # R
		pixels[i+1] = int(pixels[i+1] * 0.98)  # G
		pixels[i+2] = int(pixels[i+2] * 0.98)  # B

func _update_terrain_heights() -> void:
	# This would sample actual terrain height
	# For now, we'll use perlin noise as example
	var noise = FastNoiseLite.new()
	noise.seed = 12345
	noise.frequency = 0.02
	
	for y in range(map_size.y):
		for x in range(map_size.x):
			var world_pos = _pixel_to_world(Vector2i(x, y))
			var height = noise.get_noise_2d(world_pos.x, world_pos.y) * 20.0
			var color = _height_to_color(height)
			map_image.set_pixel(x, y, color)

func _draw_entities() -> void:
	for entity_id in entity_positions:
		var world_pos = entity_positions[entity_id]
		var pixel_pos = _world_to_pixel(Vector2(world_pos.x, world_pos.z))
		
		# Update trail
		if not entity_trails.has(entity_id):
			entity_trails[entity_id] = []
		
		var trail = entity_trails[entity_id]
		trail.append(pixel_pos)
		if trail.size() > trail_length:
			trail.pop_front()
		
		# Draw trail
		for i in range(trail.size()):
			var pos = trail[i]
			if _is_valid_pixel(pos):
				var alpha = float(i) / float(trail_length)
				var trail_color = Color(0.5, 0.5, 0.5, alpha)
				_draw_circle_on_map(pos, 1, trail_color)
		
		# Draw entity
		if _is_valid_pixel(pixel_pos):
			var height_color = _height_to_color(world_pos.y)
			_draw_circle_on_map(pixel_pos, 3, Color.WHITE)
			_draw_circle_on_map(pixel_pos, 2, height_color)

func _world_to_pixel(world_pos: Vector2) -> Vector2i:
	var normalized = (world_pos - world_bounds.position) / world_bounds.size
	return Vector2i(
		int(normalized.x * map_size.x),
		int(normalized.y * map_size.y)
	)

func _pixel_to_world(pixel_pos: Vector2i) -> Vector2:
	var normalized = Vector2(pixel_pos) / Vector2(map_size)
	return world_bounds.position + normalized * world_bounds.size

func _is_valid_pixel(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < map_size.x and pos.y >= 0 and pos.y < map_size.y

func _height_to_color(height: float) -> Color:
	var normalized = (height - min_height) / (max_height - min_height)
	normalized = clamp(normalized, 0.0, 1.0)
	return height_colors.sample(normalized)

func _draw_circle_on_map(center: Vector2i, radius: int, color: Color) -> void:
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			if x * x + y * y <= radius * radius:
				var pos = center + Vector2i(x, y)
				if _is_valid_pixel(pos):
					map_image.set_pixelv(pos, color)

# API

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func update_entity_position(entity_id: String, position: Vector3) -> void:
	entity_positions[entity_id] = position

func remove_entity(entity_id: String) -> void:
	entity_positions.erase(entity_id)
	entity_trails.erase(entity_id)

func set_world_bounds(bounds: Rect2) -> void:
	world_bounds = bounds

func set_height_range(min_h: float, max_h: float) -> void:
	min_height = min_h
	max_height = max_h

# Mouse interaction
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var pixel_pos = Vector2i(event.position)
			var world_pos = _pixel_to_world(pixel_pos)
			print("Map clicked at world position: ", world_pos)
			
			# Emit signal or call method to focus camera on this position
			if has_node("/root/LayerRealitySystem"):
				get_node("/root/LayerRealitySystem").call("focus_on_world_position", 
					Vector3(world_pos.x, 0, world_pos.y))