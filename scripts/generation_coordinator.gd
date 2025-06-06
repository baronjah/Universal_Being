# GenerationCoordinator - STOPS THE EMERGENCY OPTIMIZATION LOOP!
# Prevents all three generation systems from running simultaneously
# Only one system generates at a time based on player scale

extends Node
class_name GenerationCoordinator

# Performance monitoring
var current_fps: float = 60.0
var fps_history: Array[float] = []
var fps_history_size: int = 30
var emergency_active: bool = false
var emergency_start_time: float = 0.0

# System references
var cosmic_lod: CosmicLODSystem = null
var matrix_chunks: MatrixChunkSystem = null  
var lightweight_chunks: LightweightChunkSystem = null
var player: Node3D = null

# Current active system
enum GenerationMode { NONE, LIGHTWEIGHT, MATRIX, COSMIC }
var current_mode: GenerationMode = GenerationMode.NONE
var last_mode_check: float = 0.0

func _ready():
	print("🎯 GENERATION COORDINATOR ACTIVE - EMERGENCY OPTIMIZATION PREVENTION ENABLED")
	
	# Find systems
	call_deferred("_find_systems")

func _find_systems():
	"""Find all generation systems after scene is ready"""
	var generation_systems = get_tree().get_nodes_in_group("generation_systems")
	
	for system in generation_systems:
		if system is CosmicLODSystem:
			cosmic_lod = system
		elif system is MatrixChunkSystem:
			matrix_chunks = system
		elif system is LightweightChunkSystem:
			lightweight_chunks = system
	
	# Find player
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]
	
	print("🎯 Found %d generation systems" % generation_systems.size())
	if cosmic_lod:
		print("  ✅ Cosmic LOD System")
	if matrix_chunks:
		print("  ✅ Matrix Chunk System") 
	if lightweight_chunks:
		print("  ✅ Lightweight Chunk System")

func _process(delta):
	# Monitor performance
	update_fps_monitoring()
	
	# Check for emergency optimization needs
	handle_emergency_optimization()
	
	# Coordinate generation systems (only when not in emergency)
	if not emergency_active:
		coordinate_generation_systems()

func update_fps_monitoring():
	"""Track FPS and detect performance issues"""
	current_fps = Engine.get_frames_per_second()
	
	# Add to history
	fps_history.append(current_fps)
	if fps_history.size() > fps_history_size:
		fps_history.pop_front()
	
	# Calculate average FPS
	var avg_fps = 0.0
	for fps in fps_history:
		avg_fps += fps
	avg_fps /= fps_history.size()

func handle_emergency_optimization():
	"""Handle emergency optimization when FPS drops too low"""
	
	# Trigger emergency if FPS drops below 45 (raised threshold for better performance)
	if current_fps < 45 and not emergency_active:
		print("🚨 EMERGENCY OPTIMIZATION ACTIVATED - FPS TOO LOW: %.1f" % current_fps)
		emergency_active = true
		emergency_start_time = Time.get_ticks_msec() / 1000.0
		
		# STOP ALL GENERATION IMMEDIATELY
		stop_all_generation()
		
		# Force garbage collection
		call_deferred("_emergency_cleanup")
	
	# Exit emergency when FPS recovers above 55 (raised from 40)
	elif current_fps > 55 and emergency_active:
		var emergency_duration = (Time.get_ticks_msec() / 1000.0) - emergency_start_time
		print("✅ EMERGENCY OPTIMIZATION ENDED - FPS RECOVERED: %.1f (Duration: %.1fs)" % [current_fps, emergency_duration])
		emergency_active = false
		
		# Resume appropriate generation
		determine_generation_mode()

func stop_all_generation():
	"""Stop all generation systems immediately"""
	if cosmic_lod:
		cosmic_lod.set_process(false)
		cosmic_lod.cleanup_distant_objects()
	
	if matrix_chunks:
		matrix_chunks.set_process(false)
	
	if lightweight_chunks:
		lightweight_chunks.set_process(false)
	
	current_mode = GenerationMode.NONE
	print("🛑 ALL GENERATION STOPPED")

func _emergency_cleanup():
	"""Force cleanup during emergency"""
	# Additional cleanup for each system
	if cosmic_lod:
		cosmic_lod.cleanup_distant_objects()
	
	# Clear any remaining references to help with memory

func coordinate_generation_systems():
	"""Coordinate which system should be active based on player scale"""
	if not player:
		return
	
	# REMOVED 2-second delay for instant chunk loading
	# Only check every 2 seconds to prevent rapid switching
	#var current_time = Time.get_ticks_msec() / 1000.0
	#if current_time - last_mode_check < 2.0:
	#	return
	
	#last_mode_check = current_time
	
	# Determine appropriate mode
	var target_mode = determine_generation_mode()
	
	# Switch if needed
	if target_mode != current_mode:
		switch_generation_mode(target_mode)

func determine_generation_mode() -> GenerationMode:
	"""Determine which generation system should be active"""
	if not player:
		return GenerationMode.NONE
	
	var player_pos = player.global_position
	var distance_from_origin = player_pos.length()
	
	# Scale-based system selection
	if distance_from_origin > 500:
		return GenerationMode.COSMIC  # Galactic scale
	elif distance_from_origin > 50:
		return GenerationMode.MATRIX   # Stellar scale
	else:
		return GenerationMode.LIGHTWEIGHT  # Surface scale

func switch_generation_mode(new_mode: GenerationMode):
	"""Switch between generation systems"""
	# Stop current system
	match current_mode:
		GenerationMode.COSMIC:
			if cosmic_lod:
				cosmic_lod.set_process(false)
		GenerationMode.MATRIX:
			if matrix_chunks:
				matrix_chunks.set_process(false)
		GenerationMode.LIGHTWEIGHT:
			if lightweight_chunks:
				lightweight_chunks.set_process(false)
	
	# Start new system
	match new_mode:
		GenerationMode.COSMIC:
			if cosmic_lod:
				cosmic_lod.set_process(true)
			print("🌌 COSMIC LOD PRIORITY - GALACTIC SCALE")
		GenerationMode.MATRIX:
			if matrix_chunks:
				matrix_chunks.set_process(true)
			print("🔴 MATRIX CHUNKS PRIORITY - STELLAR SCALE")
		GenerationMode.LIGHTWEIGHT:
			if lightweight_chunks:
				lightweight_chunks.set_process(true)
			print("📦 LIGHTWEIGHT PRIORITY - SURFACE SCALE")
		GenerationMode.NONE:
			print("🛑 NO GENERATION - EMERGENCY OR IDLE")
	
	current_mode = new_mode

func get_performance_stats() -> Dictionary:
	"""Get performance statistics"""
	var avg_fps = 0.0
	if fps_history.size() > 0:
		for fps in fps_history:
			avg_fps += fps
		avg_fps /= fps_history.size()
	
	return {
		"current_fps": current_fps,
		"average_fps": avg_fps,
		"emergency_active": emergency_active,
		"current_mode": GenerationMode.keys()[current_mode],
		"total_chunks": get_total_chunk_count()
	}

func get_total_chunk_count() -> int:
	"""Get total number of active chunks across all systems"""
	var total = 0
	
	if cosmic_lod:
		var stats = cosmic_lod.get_cosmic_stats()
		total += stats.get("cosmic_objects", 0)
	
	if matrix_chunks:
		var stats = matrix_chunks.get_matrix_stats()
		total += stats.get("active_chunks", 0)
	
	if lightweight_chunks:
		var stats = lightweight_chunks.get_debug_info()
		total += stats.get("visible_chunks", 0)
	
	return total

# Public API for emergency triggers
func force_emergency_optimization():
	"""Force emergency optimization (for testing)"""
	emergency_active = true
	stop_all_generation()

func force_emergency_recovery():
	"""Force emergency recovery (for testing)"""
	emergency_active = false
	determine_generation_mode()