# MapWorldController - Controls the map chunk world scene
# Manages UI updates, player-chunk interactions, and debug display

extends Node3D
class_name MapWorldController

# References
var chunk_grid_manager: ChunkGridManager = null
var player: PlayerUniversalBeing = null
var debug_ui: Control = null

# UI Labels
var grid_status_label: Label = null
var player_pos_label: Label = null 
var chunk_info_label: Label = null
var performance_label: Label = null

# Update tracking
var ui_update_timer: float = 0.0
var ui_update_interval: float = 0.1  # Update UI 10 times per second

func _ready() -> void:
	# Find components
	find_scene_components()
	
	# Setup UI updates
	setup_ui_system()
	
	# Connect signals
	connect_signals()
	
	print("🗺️ Map World Controller ready!")

func find_scene_components() -> void:
	"""Find all the important components in the scene"""
	# Find chunk grid manager
	chunk_grid_manager = get_node_or_null("ChunkGridManager")
	if not chunk_grid_manager:
		chunk_grid_manager = find_child("ChunkGridManager")
	
	# Find player
	player = get_node_or_null("Player")
	if not player:
		player = find_child("Player")
	
	# Find UI elements
	debug_ui = get_node_or_null("UI")
	if debug_ui:
		grid_status_label = debug_ui.get_node_or_null("DebugInfo/GridStatus")
		player_pos_label = debug_ui.get_node_or_null("DebugInfo/PlayerPos")
		chunk_info_label = debug_ui.get_node_or_null("DebugInfo/ChunkInfo")
		performance_label = debug_ui.get_node_or_null("DebugInfo/Performance")
	
	print("🗺️ Found components - Grid:%s Player:%s UI:%s" % [
		"✓" if chunk_grid_manager else "✗",
		"✓" if player else "✗", 
		"✓" if debug_ui else "✗"
	])

func setup_ui_system() -> void:
	"""Setup the UI update system"""
	if not debug_ui:
		return
		
	# Initial UI setup
	update_all_ui_labels()

func connect_signals() -> void:
	"""Connect signals from chunk system and player"""
	if chunk_grid_manager:
		chunk_grid_manager.chunk_loaded_in_grid.connect(_on_chunk_loaded)
		chunk_grid_manager.chunk_unloaded_from_grid.connect(_on_chunk_unloaded)
		chunk_grid_manager.player_entered_chunk.connect(_on_player_entered_chunk)
	
	if player:
		# Connect to player movement if it has signals
		pass

func _process(delta: float) -> void:
	# Update UI periodically
	ui_update_timer += delta
	if ui_update_timer >= ui_update_interval:
		ui_update_timer = 0.0
		update_all_ui_labels()
	
	# Check for player chunk transitions
	check_player_chunk_changes()

func update_all_ui_labels() -> void:
	"""Update all UI labels with current information"""
	if not debug_ui:
		return
	
	# Grid status
	if grid_status_label and chunk_grid_manager:
		var status = chunk_grid_manager.get_grid_status()
		grid_status_label.text = "Active Chunks: %d | Loading: %d | Tracked: %d" % [
			status.active_chunks,
			status.loading_chunks,
			status.tracked_entities
		]
	
	# Player position
	if player_pos_label and player:
		var pos = player.global_position
		player_pos_label.text = "Player: (%.1f, %.1f, %.1f)" % [pos.x, pos.y, pos.z]
	
	# Current chunk info
	if chunk_info_label and player and chunk_grid_manager:
		var chunk_coord = chunk_grid_manager.world_pos_to_chunk_coord(player.global_position)
		var current_chunk = chunk_grid_manager.get_chunk_at_coordinate(chunk_coord)
		
		if current_chunk:
			chunk_info_label.text = "Chunk: [%d,%d,%d] Gen:%d LOD:%s" % [
				chunk_coord.x, chunk_coord.y, chunk_coord.z,
				current_chunk.generation_level,
				current_chunk.LODLevel.keys()[current_chunk.current_lod]
			]
		else:
			chunk_info_label.text = "Chunk: [%d,%d,%d] (Loading...)" % [
				chunk_coord.x, chunk_coord.y, chunk_coord.z
			]
	
	# Performance info
	if performance_label:
		performance_label.text = "FPS: %d | Frame: %.1fms" % [
			Engine.get_frames_per_second(),
			Performance.get_monitor(Performance.TIME_PROCESS) * 1000
		]

func check_player_chunk_changes() -> void:
	"""Check if player has moved to a new chunk"""
	if not player or not chunk_grid_manager:
		return
	
	var current_chunk_coord = chunk_grid_manager.world_pos_to_chunk_coord(player.global_position)
	var current_chunk = chunk_grid_manager.get_chunk_at_coordinate(current_chunk_coord)
	
	# Store last chunk for comparison
	if not player.has_meta("last_chunk_coord"):
		player.set_meta("last_chunk_coord", current_chunk_coord)
		return
	
	var last_chunk_coord = player.get_meta("last_chunk_coord")
	
	if current_chunk_coord != last_chunk_coord:
		# Player entered new chunk
		player.set_meta("last_chunk_coord", current_chunk_coord)
		
		if current_chunk:
			chunk_grid_manager.player_entered_chunk.emit(player, current_chunk)
			print("🚶 Player entered chunk [%d,%d,%d]" % [
				current_chunk_coord.x, current_chunk_coord.y, current_chunk_coord.z
			])

# Signal handlers
func _on_chunk_loaded(chunk: ChunkUniversalBeing, coordinates: Vector3i) -> void:
	"""Handle chunk being loaded into the grid"""
	print("📦 Chunk loaded: [%d,%d,%d] - %s" % [
		coordinates.x, coordinates.y, coordinates.z, chunk.being_name
	])

func _on_chunk_unloaded(chunk: ChunkUniversalBeing, coordinates: Vector3i) -> void:
	"""Handle chunk being unloaded from the grid"""
	print("📤 Chunk unloaded: [%d,%d,%d] - %s" % [
		coordinates.x, coordinates.y, coordinates.z, chunk.being_name
	])

func _on_player_entered_chunk(player_being: Node, chunk: ChunkUniversalBeing) -> void:
	"""Handle player entering a new chunk"""
	print("🏠 Player entered chunk: %s (Gen Level: %d)" % [
		chunk.being_name, chunk.generation_level
	])
	
	# Could trigger chunk-specific events here
	if chunk.generation_level == 0:
		print("🌱 Triggering content generation for new chunk...")

func _input(event: InputEvent) -> void:
	"""Handle input for map-specific controls"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				# Toggle debug UI
				if debug_ui:
					debug_ui.visible = !debug_ui.visible
					print("🎛️ Debug UI: %s" % ("ON" if debug_ui.visible else "OFF"))
			
			KEY_F2:
				# Print grid status to console
				if chunk_grid_manager:
					chunk_grid_manager.print_grid_status()
			
			KEY_F3:
				# Force generate chunk at player position
				if player and chunk_grid_manager:
					var player_chunk_coord = chunk_grid_manager.world_pos_to_chunk_coord(player.global_position)
					var new_chunk = chunk_grid_manager.force_generate_chunk(player_chunk_coord)
					print("⚡ Force generated chunk: %s" % new_chunk.being_name)
			
			KEY_F4:
				# Clear all chunks (reset)
				if chunk_grid_manager:
					chunk_grid_manager.clear_all_chunks()
					print("🧹 All chunks cleared!")

# Public API for external control
func get_chunk_grid_manager() -> ChunkGridManager:
	"""Get reference to the chunk grid manager"""
	return chunk_grid_manager

func get_player() -> PlayerUniversalBeing:
	"""Get reference to the player"""
	return player

func teleport_player_to_chunk(coordinates: Vector3i) -> void:
	"""Teleport player to a specific chunk"""
	if not player or not chunk_grid_manager:
		return
	
	var world_pos = chunk_grid_manager.chunk_coord_to_world_pos(coordinates)
	world_pos.y += 2.0  # Add some height so player doesn't spawn in ground
	
	player.teleport_to(world_pos)
	print("✈️ Teleported player to chunk [%d,%d,%d]" % [coordinates.x, coordinates.y, coordinates.z])

func set_generation_distance(distance: int) -> void:
	"""Set the chunk generation distance"""
	if chunk_grid_manager:
		chunk_grid_manager.set_generation_distance(distance)

func set_render_distance(distance: int) -> void:
	"""Set the chunk render distance"""
	if chunk_grid_manager:
		chunk_grid_manager.set_render_distance(distance)
