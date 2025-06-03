# UnifiedChunkSystem - Combines JSH's detailed approach with Luminus's elegance
# The best of both worlds for Universal Being spatial grid management

extends UniversalBeing
class_name UnifiedChunkSystem

# ===== SYSTEM PROPERTIES =====
@export var use_luminus_approach: bool = true
@export var use_detailed_approach: bool = true
@export var chunk_size: Vector3 = Vector3(10.0, 10.0, 10.0)
@export var hybrid_mode: bool = true

# System Components
var luminus_manager: LuminusChunkGridManager = null
var detailed_manager: ChunkGridManager = null
var current_approach: String = "hybrid"

# Integration State
var active_chunks: Dictionary = {}
var system_performance: Dictionary = {}
var approach_metrics: Dictionary = {}

# Signals
signal approach_switched(new_approach: String)
signal chunk_system_ready()
signal performance_metrics_updated(metrics: Dictionary)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Unified Chunk System"
	being_type = "spatial_system_coordinator"
	consciousness_level = 5  # Transcendent system coordination
	
	initialize_unified_system()

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Start with hybrid approach
	setup_hybrid_system()
	monitor_performance()
	
	print("🌌 Unified Chunk System ready - best of JSH + Luminus approaches!")
	chunk_system_ready.emit()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Monitor both systems and optimize
	update_performance_metrics(delta)
	
	# Dynamic approach switching based on context
	if hybrid_mode:
		optimize_approach_selection(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle unified system controls
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F8:  # Switch approach
				if event.ctrl_pressed:
					cycle_chunk_approach()

# ===== SYSTEM INITIALIZATION =====

func initialize_unified_system() -> void:
	"""Initialize both chunk systems for comparison and hybrid use"""
	# Setup approach metrics
	approach_metrics = {
		"luminus": {
			"performance": 0.0,
			"memory_usage": 0.0,
			"chunk_load_time": 0.0,
			"simplicity_score": 10.0
		},
		"detailed": {
			"performance": 0.0,
			"memory_usage": 0.0,
			"chunk_load_time": 0.0,
			"feature_richness": 10.0
		},
		"hybrid": {
			"performance": 0.0,
			"memory_usage": 0.0,
			"adaptability": 10.0
		}
	}

func setup_hybrid_system() -> void:
	"""Setup the hybrid system that uses both approaches intelligently"""
	current_approach = "hybrid"
	
	# Create both managers
	if use_luminus_approach:
		luminus_manager = LuminusChunkGridManager.new()
		luminus_manager.name = "LuminusChunkManager"
		add_child(luminus_manager)
	
	if use_detailed_approach:
		detailed_manager = ChunkGridManager.new()
		detailed_manager.name = "DetailedChunkManager"
		add_child(detailed_manager)
	
	print("🔄 Hybrid chunk system initialized with both approaches")

# ===== APPROACH MANAGEMENT =====

func cycle_chunk_approach() -> void:
	"""Cycle between different chunk approaches"""
	match current_approach:
		"luminus":
			switch_to_detailed_approach()
		"detailed":
			switch_to_hybrid_approach()
		"hybrid":
			switch_to_luminus_approach()

func switch_to_luminus_approach() -> void:
	"""Switch to Luminus's elegant approach"""
	if not luminus_manager:
		return
	
	print("🌟 Switching to Luminus approach - elegant simplicity")
	current_approach = "luminus"
	
	# Disable detailed manager
	if detailed_manager:
		detailed_manager.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
	# Enable luminus manager
	luminus_manager.set_process_mode(Node.PROCESS_MODE_INHERIT)
	
	approach_switched.emit("luminus")

func switch_to_detailed_approach() -> void:
	"""Switch to JSH's detailed approach"""
	if not detailed_manager:
		return
	
	print("🔧 Switching to detailed approach - rich features")
	current_approach = "detailed"
	
	# Disable luminus manager
	if luminus_manager:
		luminus_manager.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
	# Enable detailed manager
	detailed_manager.set_process_mode(Node.PROCESS_MODE_INHERIT)
	
	approach_switched.emit("detailed")

func switch_to_hybrid_approach() -> void:
	"""Switch to hybrid approach using both systems"""
	print("⚡ Switching to hybrid approach - adaptive intelligence")
	current_approach = "hybrid"
	
	# Enable both managers with coordination
	if luminus_manager:
		luminus_manager.set_process_mode(Node.PROCESS_MODE_INHERIT)
	if detailed_manager:
		detailed_manager.set_process_mode(Node.PROCESS_MODE_INHERIT)
	
	approach_switched.emit("hybrid")

# ===== PERFORMANCE MONITORING =====

func monitor_performance() -> void:
	"""Start performance monitoring for both approaches"""
	system_performance = {
		"start_time": Time.get_ticks_msec(),
		"frame_times": [],
		"memory_samples": [],
		"chunk_operations": 0
	}

func update_performance_metrics(delta: float) -> void:
	"""Update performance metrics for optimization"""
	system_performance.frame_times.append(delta)
	
	# Keep only recent samples
	if system_performance.frame_times.size() > 60:
		system_performance.frame_times = system_performance.frame_times.slice(-30)
	
	# Update approach metrics
	var avg_frame_time = calculate_average_frame_time()
	
	match current_approach:
		"luminus":
			approach_metrics.luminus.performance = 1.0 / avg_frame_time
		"detailed":
			approach_metrics.detailed.performance = 1.0 / avg_frame_time
		"hybrid":
			approach_metrics.hybrid.performance = 1.0 / avg_frame_time
	
	performance_metrics_updated.emit(approach_metrics)

func calculate_average_frame_time() -> float:
	"""Calculate average frame time from recent samples"""
	if system_performance.frame_times.is_empty():
		return 0.016  # Default 60 FPS
	
	var total = 0.0
	for time in system_performance.frame_times:
		total += time
	
	return total / system_performance.frame_times.size()

# ===== HYBRID OPTIMIZATION =====

func optimize_approach_selection(delta: float) -> void:
	"""Dynamically optimize which approach to use based on context"""
	var context = analyze_current_context()
	var optimal_approach = determine_optimal_approach(context)
	
	if optimal_approach != current_approach:
		print("🧠 Context-based optimization: switching to %s approach" % optimal_approach)
		match optimal_approach:
			"luminus":
				switch_to_luminus_approach()
			"detailed":
				switch_to_detailed_approach()
			"hybrid":
				switch_to_hybrid_approach()

func analyze_current_context() -> Dictionary:
	"""Analyze current context to determine optimal approach"""
	var context = {
		"player_count": get_tree().get_nodes_in_group("players").size(),
		"ai_count": get_tree().get_nodes_in_group("ai_companions").size(),
		"active_chunk_count": get_active_chunk_count(),
		"memory_pressure": get_memory_pressure(),
		"cpu_load": calculate_average_frame_time(),
		"generation_demand": get_generation_demand()
	}
	
	return context

func determine_optimal_approach(context: Dictionary) -> String:
	"""Determine which approach is optimal for current context"""
	var scores = {
		"luminus": 0.0,
		"detailed": 0.0,
		"hybrid": 0.0
	}
	
	# Score based on context factors
	
	# Simple scenarios favor Luminus
	if context.player_count <= 1 and context.ai_count <= 1:
		scores.luminus += 3.0
	
	# Complex scenarios favor detailed approach
	if context.active_chunk_count > 50 or context.generation_demand > 0.7:
		scores.detailed += 3.0
	
	# High memory pressure favors Luminus
	if context.memory_pressure > 0.8:
		scores.luminus += 2.0
	
	# High CPU load favors Luminus
	if context.cpu_load > 0.020:  # Worse than 50 FPS
		scores.luminus += 2.0
	
	# Multiple entities favor detailed
	if context.player_count + context.ai_count > 2:
		scores.detailed += 2.0
	
	# Hybrid gets base adaptability score
	scores.hybrid += 1.0
	
	# Return highest scoring approach
	var best_approach = "hybrid"
	var best_score = scores.hybrid
	
	for approach in scores.keys():
		if scores[approach] > best_score:
			best_score = scores[approach]
			best_approach = approach
	
	return best_approach

# ===== UTILITY FUNCTIONS =====

func get_active_chunk_count() -> int:
	"""Get total active chunks across both systems"""
	var count = 0
	
	if luminus_manager and luminus_manager.has_method("get_active_chunk_count"):
		count += luminus_manager.get_active_chunk_count()
	elif luminus_manager:
		count += luminus_manager._active_chunks.size()
	
	if detailed_manager and detailed_manager.has_method("get_active_chunk_count"):
		count += detailed_manager.get_active_chunk_count()
	elif detailed_manager:
		count += detailed_manager.active_chunks.size()
	
	return count

func get_memory_pressure() -> float:
	"""Estimate memory pressure (placeholder - could integrate with actual memory monitoring)"""
	var chunk_count = get_active_chunk_count()
	return min(1.0, chunk_count / 100.0)  # Normalize to 0-1

func get_generation_demand() -> float:
	"""Estimate content generation demand"""
	var generators = get_tree().get_nodes_in_group("chunk_generators")
	return min(1.0, generators.size() / 10.0)  # Normalize to 0-1

func get_system_status() -> Dictionary:
	"""Get comprehensive system status"""
	return {
		"current_approach": current_approach,
		"active_chunks": get_active_chunk_count(),
		"approach_metrics": approach_metrics,
		"performance": system_performance,
		"luminus_active": luminus_manager != null and luminus_manager.get_process_mode() != Node.PROCESS_MODE_DISABLED,
		"detailed_active": detailed_manager != null and detailed_manager.get_process_mode() != Node.PROCESS_MODE_DISABLED
	}

func print_system_status() -> void:
	"""Print current system status for debugging"""
	var status = get_system_status()
	print("🌌 Unified Chunk System Status:")
	print("  Current Approach: %s" % status.current_approach)
	print("  Active Chunks: %d" % status.active_chunks)
	print("  Luminus Active: %s" % status.luminus_active)
	print("  Detailed Active: %s" % status.detailed_active)
	print("  Avg Frame Time: %.3f ms" % (calculate_average_frame_time() * 1000))

# ===== INTEGRATION HELPERS =====

func create_chunk_at_position(world_pos: Vector3, approach: String = "") -> Node:
	"""Create a chunk at world position using specified approach"""
	var use_approach = approach if approach != "" else current_approach
	
	match use_approach:
		"luminus":
			if luminus_manager:
				var coords = luminus_manager._world_to_chunk_coords(world_pos)
				return luminus_manager._load_chunk(coords)
		"detailed":
			if detailed_manager:
				var coords = detailed_manager.world_pos_to_chunk_coord(world_pos)
				return detailed_manager.create_chunk_at_coordinate(coords)
		"hybrid":
			# Use context to decide which system to use for this chunk
			var context = analyze_current_context()
			if context.memory_pressure < 0.5:
				return create_chunk_at_position(world_pos, "detailed")
			else:
				return create_chunk_at_position(world_pos, "luminus")
	
	return null

func get_chunk_at_position(world_pos: Vector3) -> Node:
	"""Get chunk at world position from either system"""
	var chunk = null
	
	if luminus_manager:
		var coords = luminus_manager._world_to_chunk_coords(world_pos)
		chunk = luminus_manager._active_chunks.get(coords)
		if chunk:
			return chunk
	
	if detailed_manager:
		chunk = detailed_manager.get_chunk_at_world_pos(world_pos)
		if chunk:
			return chunk
	
	return null