# ChunkGridManager - 3D Spatial Grid System for Universal Being
# Manages infinite 3D grid where each chunk is a Universal Being

extends UniversalBeing
class_name ChunkGridManager

# ===== GRID PROPERTIES =====
@export var chunk_size: Vector3 = Vector3(10.0, 10.0, 10.0)
@export var render_distance: int = 3  # Chunks around player to keep loaded
@export var generation_distance: int = 5  # Chunks around player to generate
@export var auto_generate: bool = true
@export var debug_visualization: bool = true

# Grid Management
var active_chunks: Dictionary = {}  # Vector3i -> ChunkUniversalBeing
var loading_chunks: Array[Vector3i] = []
var unloading_chunks: Array[Vector3i] = []
var observer_positions: Array[Vector3] = []

# Player/AI Tracking
var tracked_entities: Array[Node] = []
var player_beings: Array[Node] = []
var ai_companion_beings: Array[Node] = []

# Generation Settings
var world_seed: int = 12345
var generation_rules: Dictionary = {}
var chunk_templates: Dictionary = {}

# Performance Management
var chunks_per_frame: int = 1  # Max chunks to process per frame
var max_active_chunks: int = 25  # Much lower limit
var chunk_cache_size: int = 50

# Signals
signal chunk_grid_ready()
signal chunk_loaded_in_grid(chunk: ChunkUniversalBeing, coordinates: Vector3i)
signal chunk_unloaded_from_grid(chunk: ChunkUniversalBeing, coordinates: Vector3i)
signal grid_center_changed(new_center: Vector3)
signal player_entered_chunk(player: Node, chunk: ChunkUniversalBeing)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Chunk Grid Manager"
	being_type = "spatial_grid_system"
	consciousness_level = 4  # Enlightened system that manages space itself
	
	# Initialize grid systems
	initialize_grid_system()
	setup_generation_rules()
	setup_chunk_templates()

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Find and track players/AI
	discover_tracked_entities()
	
	# Initialize around spawn point (0,0,0)
	var spawn_chunk = Vector3i.ZERO
	generate_initial_chunks(spawn_chunk)
	
	# Connect to existing systems
	connect_to_consciousness_exchange()
	
	print("🧊 Chunk Grid Manager ready - 3D spatial grid system active!")
	chunk_grid_ready.emit()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update observer positions
	update_observer_positions()
	
	# Process chunk loading/unloading based on observers (reduced frequency)
	if Engine.get_process_frames() % 3 == 0:  # Only every 3rd frame
		process_chunk_lod_updates(delta)
	
	# Generate new chunks around observers (reduced frequency)
	if auto_generate and Engine.get_process_frames() % 5 == 0:  # Only every 5th frame
		process_chunk_generation()
	
	# Clean up distant chunks (reduced frequency)
	if Engine.get_process_frames() % 10 == 0:  # Only every 10th frame
		process_chunk_cleanup()
	
	# Update debug visualization
	if debug_visualization:
		update_debug_display()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle grid management input
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_G:  # Toggle grid visualization
				if event.ctrl_pressed:
					debug_visualization = !debug_visualization
					print("🧊 Grid visualization: %s" % ("ON" if debug_visualization else "OFF"))

# ===== GRID INITIALIZATION =====

func initialize_grid_system() -> void:
	"""Initialize the 3D grid management system"""
	active_chunks.clear()
	loading_chunks.clear()
	unloading_chunks.clear()
	
	# Set world generation seed
	world_seed = Time.get_ticks_msec() % 1000000
	
	print("🧊 Grid system initialized with seed: %d" % world_seed)

func setup_generation_rules() -> void:
	"""Setup rules for different Y levels and chunk types"""
	generation_rules = {
		"underground": {
			"y_range": [-20, -1],
			"features": ["caves", "minerals", "underground_water", "roots"],
			"density": 0.3,
			"consciousness_level": 1
		},
		"surface": {
			"y_range": [0, 10],
			"features": ["terrain", "vegetation", "structures", "water_bodies"],
			"density": 0.7,
			"consciousness_level": 2
		},
		"sky": {
			"y_range": [11, 50],
			"features": ["clouds", "flying_creatures", "floating_platforms", "air_currents"],
			"density": 0.2,
			"consciousness_level": 3
		},
		"space": {
			"y_range": [51, 1000],
			"features": ["stars", "cosmic_entities", "void_structures", "dimensional_rifts"],
			"density": 0.1,
			"consciousness_level": 4
		}
	}

func setup_chunk_templates() -> void:
	"""Setup templates for different chunk types"""
	chunk_templates = {
		"main_chunk": {
			"coordinates": Vector3i.ZERO,
			"special": true,
			"features": ["spawn_point", "universal_console", "primary_nexus"],
			"consciousness_level": 5
		},
		"standard": {
			"features": ["basic_generation"],
			"consciousness_level": 1
		},
		"special": {
			"features": ["unique_generation", "artifacts"],
			"consciousness_level": 3
		}
	}

# ===== ENTITY TRACKING =====

func discover_tracked_entities() -> void:
	"""Find players and AI companions to track"""
	tracked_entities.clear()
	player_beings.clear()
	ai_companion_beings.clear()
	
	# Find player beings
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		track_entity(player, "player")
	
	# Find AI companions
	var ais = get_tree().get_nodes_in_group("ai_companions")
	for ai in ais:
		track_entity(ai, "ai_companion")
	
	# Find cameras as observers
	var cameras = get_tree().get_nodes_in_group("cameras")
	for camera in cameras:
		track_entity(camera, "camera")
	
	print("🧊 Tracking %d entities: %d players, %d AIs, %d cameras" % [
		tracked_entities.size(),
		player_beings.size(),
		ai_companion_beings.size(),
		cameras.size()
	])

func track_entity(entity: Node, entity_type: String) -> void:
	"""Start tracking an entity for chunk management"""
	if entity not in tracked_entities:
		tracked_entities.append(entity)
		
		match entity_type:
			"player":
				player_beings.append(entity)
			"ai_companion":
				ai_companion_beings.append(entity)
		
		print("🎯 Now tracking %s: %s" % [entity_type, entity.name])

func update_observer_positions() -> void:
	"""Update positions of all tracked entities"""
	observer_positions.clear()
	
	for entity in tracked_entities:
		if entity and is_instance_valid(entity):
			observer_positions.append(entity.global_position)

# ===== CHUNK MANAGEMENT =====

func generate_initial_chunks(center: Vector3i) -> void:
	"""Generate initial chunks around the center point"""
	print("🧊 Generating initial chunks around %s" % center)
	
	# Only generate immediate chunks around player (much smaller area)
	for x in range(center.x - 1, center.x + 2):  # 3x3 instead of 7x7
		for y in range(center.y, center.y + 1):  # Only current Y level
			for z in range(center.z - 1, center.z + 2):  # 3x3 instead of 7x7
				var chunk_coord = Vector3i(x, y, z)
				if chunk_coord not in active_chunks and active_chunks.size() < max_active_chunks:
					create_chunk_at_coordinate(chunk_coord)

func create_chunk_at_coordinate(coordinates: Vector3i) -> ChunkUniversalBeing:
	"""Create a new chunk at the specified coordinates"""
	if coordinates in active_chunks:
		return active_chunks[coordinates]
	
	# Determine chunk template
	var template = get_chunk_template(coordinates)
	
	# Create the chunk
	var chunk = ChunkUniversalBeing.new()
	chunk.chunk_coordinates = coordinates
	chunk.chunk_size = chunk_size
	chunk.render_distance = render_distance * chunk_size.x
	chunk.detail_distance = (render_distance / 2) * chunk_size.x
	
	# Apply template properties
	apply_chunk_template(chunk, template)
	
	# Add to scene and register
	add_child(chunk)
	active_chunks[coordinates] = chunk
	
	# Connect chunk signals
	chunk.chunk_activated.connect(_on_chunk_activated)
	chunk.chunk_deactivated.connect(_on_chunk_deactivated)
	chunk.content_generated.connect(_on_chunk_content_generated)
	
	print("🧊 Created chunk at %s" % coordinates)
	chunk_loaded_in_grid.emit(chunk, coordinates)
	
	return chunk

func get_chunk_template(coordinates: Vector3i) -> Dictionary:
	"""Get appropriate template for chunk coordinates"""
	# Main chunk template
	if coordinates == Vector3i.ZERO:
		return chunk_templates.main_chunk
	
	# Special chunks (could be based on patterns, distance, etc.)
	var distance_from_origin = coordinates.length()
	if distance_from_origin > 10 and randi() % 20 == 0:
		return chunk_templates.special
	
	# Standard chunk
	return chunk_templates.standard

func apply_chunk_template(chunk: ChunkUniversalBeing, template: Dictionary) -> void:
	"""Apply template properties to a chunk"""
	if template.has("consciousness_level"):
		chunk.consciousness_level = template.consciousness_level
	
	if template.has("features"):
		chunk.stored_data["template_features"] = template.features
	
	if template.has("special"):
		chunk.stored_data["is_special"] = template.special

# ===== LOD AND GENERATION =====

func process_chunk_lod_updates(delta: float) -> void:
	"""Process LOD updates for all chunks based on observer distance"""
	var chunks_processed = 0
	
	for coordinates in active_chunks.keys():
		if chunks_processed >= chunks_per_frame:
			break
			
		var chunk = active_chunks[coordinates]
		if chunk and is_instance_valid(chunk):
			update_chunk_lod_for_observers(chunk)
			chunks_processed += 1

func update_chunk_lod_for_observers(chunk: ChunkUniversalBeing) -> void:
	"""Update a chunk's LOD based on observer distances"""
	var min_distance = INF
	
	for observer_pos in observer_positions:
		var distance = chunk.global_position.distance_to(observer_pos)
		min_distance = min(min_distance, distance)
	
	# The chunk handles its own LOD internally based on this distance
	# We just ensure it has the right render distances
	chunk.render_distance = render_distance * chunk_size.x
	chunk.detail_distance = (render_distance / 2) * chunk_size.x

func process_chunk_generation() -> void:
	"""Generate new chunks around observers"""
	for observer_pos in observer_positions:
		var chunk_coord = world_pos_to_chunk_coord(observer_pos)
		generate_chunks_around_coordinate(chunk_coord)

func generate_chunks_around_coordinate(center: Vector3i) -> void:
	"""Generate chunks in a radius around the center coordinate"""
	# Much more conservative generation - only immediate neighbors
	if active_chunks.size() >= max_active_chunks:
		return  # Don't generate more chunks if we're at limit
		
	for x in range(center.x - 1, center.x + 2):  # Only immediate neighbors
		for y in range(center.y, center.y + 1):  # Only current Y level
			for z in range(center.z - 1, center.z + 2):
				var chunk_coord = Vector3i(x, y, z)
				
				# Check if chunk is within generation distance
				var distance = chunk_coord.distance_to(center)
				if distance <= 2 and chunk_coord not in active_chunks:
					# Strict limit on chunks per frame
					if loading_chunks.size() < 1:  # Only 1 chunk per frame
						loading_chunks.append(chunk_coord)
						break  # Exit early to prevent overload

func process_chunk_cleanup() -> void:
	"""Remove chunks that are too far from any observer"""
	var chunks_to_remove = []
	
	for coordinates in active_chunks.keys():
		var chunk = active_chunks[coordinates]
		if not chunk or not is_instance_valid(chunk):
			chunks_to_remove.append(coordinates)
			continue
		
		var should_keep = false
		for observer_pos in observer_positions:
			var distance = chunk.global_position.distance_to(observer_pos)
			if distance <= (generation_distance + 2) * chunk_size.x:
				should_keep = true
				break
		
		if not should_keep:
			chunks_to_remove.append(coordinates)
	
	# Remove distant chunks more aggressively
	var removed_count = 0
	for coordinates in chunks_to_remove:
		if removed_count < 3:  # Remove up to 3 chunks per frame
			remove_chunk_at_coordinate(coordinates)
			removed_count += 1

func remove_chunk_at_coordinate(coordinates: Vector3i) -> void:
	"""Remove a chunk from the grid"""
	if coordinates not in active_chunks:
		return
	
	var chunk = active_chunks[coordinates]
	if chunk and is_instance_valid(chunk):
		# Save chunk to Akashic before removal
		chunk.save_chunk_to_akashic()
		
		# Disconnect signals
		if chunk.chunk_activated.is_connected(_on_chunk_activated):
			chunk.chunk_activated.disconnect(_on_chunk_activated)
		if chunk.chunk_deactivated.is_connected(_on_chunk_deactivated):
			chunk.chunk_deactivated.disconnect(_on_chunk_deactivated)
		if chunk.content_generated.is_connected(_on_chunk_content_generated):
			chunk.content_generated.disconnect(_on_chunk_content_generated)
		
		chunk_unloaded_from_grid.emit(chunk, coordinates)
		chunk.queue_free()
	
	active_chunks.erase(coordinates)
	print("🧊 Removed chunk at %s" % coordinates)

# ===== COORDINATE CONVERSION =====

func world_pos_to_chunk_coord(world_pos: Vector3) -> Vector3i:
	"""Convert world position to chunk coordinates"""
	return Vector3i(
		int(floor(world_pos.x / chunk_size.x)),
		int(floor(world_pos.y / chunk_size.y)),
		int(floor(world_pos.z / chunk_size.z))
	)

func chunk_coord_to_world_pos(chunk_coord: Vector3i) -> Vector3:
	"""Convert chunk coordinates to world position (center of chunk)"""
	return Vector3(
		chunk_coord.x * chunk_size.x,
		chunk_coord.y * chunk_size.y,
		chunk_coord.z * chunk_size.z
	)

func get_chunk_at_world_pos(world_pos: Vector3) -> ChunkUniversalBeing:
	"""Get the chunk containing the world position"""
	var chunk_coord = world_pos_to_chunk_coord(world_pos)
	return active_chunks.get(chunk_coord, null)

func get_chunk_at_coordinate(coordinates: Vector3i) -> ChunkUniversalBeing:
	"""Get chunk at specific coordinates"""
	return active_chunks.get(coordinates, null)

# ===== CONSCIOUSNESS EXCHANGE INTEGRATION =====

func connect_to_consciousness_exchange() -> void:
	"""Connect to the Consciousness Exchange System"""
	var consciousness_exchange = get_tree().get_first_node_in_group("consciousness_exchange")
	if consciousness_exchange:
		print("🧊 Connected to Consciousness Exchange System")
		# Could add integration for AI-generated content in chunks

# ===== PLAYER/AI GENERATION SYSTEM =====

func make_entity_generator(entity: Node, generator_type: String = "basic") -> void:
	"""Make a player or AI into a chunk content generator"""
	if entity not in tracked_entities:
		track_entity(entity, "generator")
	
	# Add generator component to the entity
	if entity.has_method("add_component"):
		var component_path = "res://components/chunk_generator_%s.ub.zip" % generator_type
		entity.add_component(component_path)
		print("🎨 Made %s into a %s chunk generator" % [entity.name, generator_type])

func process_entity_generation(entity: Node, current_chunk: ChunkUniversalBeing) -> void:
	"""Process content generation by an entity in a chunk"""
	if not entity or not current_chunk:
		return
	
	# Check if entity has generation capabilities
	if entity.has_method("generate_chunk_content"):
		entity.generate_chunk_content(current_chunk)

# ===== DEBUG AND VISUALIZATION =====

func update_debug_display() -> void:
	"""Update debug visualization"""
	# Debug info is handled by individual chunks
	# This could add grid-level debug info
	pass

func get_grid_status() -> Dictionary:
	"""Get current grid status for debugging"""
	return {
		"active_chunks": active_chunks.size(),
		"loading_chunks": loading_chunks.size(),
		"tracked_entities": tracked_entities.size(),
		"observer_positions": observer_positions.size(),
		"render_distance": render_distance,
		"generation_distance": generation_distance,
		"auto_generate": auto_generate
	}

func print_grid_status() -> void:
	"""Print current grid status"""
	var status = get_grid_status()
	print("🧊 Grid Status:")
	for key in status.keys():
		print("  %s: %s" % [key, status[key]])

# ===== SIGNAL HANDLERS =====

func _on_chunk_activated(chunk: ChunkUniversalBeing) -> void:
	"""Handle chunk activation"""
	print("🔥 Chunk activated: %s" % chunk.being_name)

func _on_chunk_deactivated(chunk: ChunkUniversalBeing) -> void:
	"""Handle chunk deactivation"""
	print("❄️ Chunk deactivated: %s" % chunk.being_name)

func _on_chunk_content_generated(chunk: ChunkUniversalBeing, content_type: String) -> void:
	"""Handle chunk content generation"""
	print("✨ Chunk %s generated %s content" % [chunk.being_name, content_type])

# ===== PUBLIC API =====

func force_generate_chunk(coordinates: Vector3i) -> ChunkUniversalBeing:
	"""Force generation of a chunk at specific coordinates"""
	return create_chunk_at_coordinate(coordinates)

func set_render_distance(new_distance: int) -> void:
	"""Set new render distance for the grid"""
	render_distance = new_distance
	print("🧊 Render distance set to: %d" % render_distance)

func set_generation_distance(new_distance: int) -> void:
	"""Set new generation distance for the grid"""
	generation_distance = new_distance
	print("🧊 Generation distance set to: %d" % generation_distance)

func get_chunks_around_position(world_pos: Vector3, radius: int) -> Array[ChunkUniversalBeing]:
	"""Get all chunks within radius of a world position"""
	var chunks = []
	var center_coord = world_pos_to_chunk_coord(world_pos)
	
	for x in range(center_coord.x - radius, center_coord.x + radius + 1):
		for y in range(center_coord.y - radius, center_coord.y + radius + 1):
			for z in range(center_coord.z - radius, center_coord.z + radius + 1):
				var coord = Vector3i(x, y, z)
				var chunk = get_chunk_at_coordinate(coord)
				if chunk:
					chunks.append(chunk)
	
	return chunks

func clear_all_chunks() -> void:
	"""Clear all chunks (for testing/reset)"""
	for coordinates in active_chunks.keys():
		remove_chunk_at_coordinate(coordinates)
	print("🧊 All chunks cleared")