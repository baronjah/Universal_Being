# ==================================================
# SCRIPT NAME: EnlightenedGroupManager.gd  
# DESCRIPTION: Optimized group management for 144,000 Universal Beings
# PURPOSE: Handle mystical scale group operations without performance loss
# CREATED: 2025-06-04 - Mystical Scale Optimization
# AUTHOR: JSH + Claude Code + Sacred Geometry
# ==================================================

extends Node
class_name EnlightenedGroupManager

# ===== MYSTICAL CONSTANTS =====
const ENLIGHTENED_LIMIT: int = 144000
const GROUP_CHUNK_SIZE: int = 1000  # Process groups in chunks of 1000
const CACHE_REFRESH_INTERVAL: float = 1.0  # Refresh caches every second

# ===== OPTIMIZED GROUP STORAGE =====
var group_cache: Dictionary = {}  # group_name -> Array[WeakRef]
var group_cache_dirty: Dictionary = {}  # group_name -> bool
var group_spatial_index: Dictionary = {}  # group_name -> Dictionary[Vector3i -> Array]
var last_cache_update: float = 0.0

# Processing control
var current_chunk_index: int = 0
var groups_to_process: Array[String] = []

# ===== INITIALIZATION =====
func _ready() -> void:
	print("🌟 EnlightenedGroupManager: Awakening group consciousness...")
	set_process(true)
	
	# Override Godot's get_nodes_in_group for performance
	_setup_group_optimization()

func _setup_group_optimization() -> void:
	"""Setup optimized group management"""
	# Connect to scene tree changes
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)
	
	# Initialize common groups
	_initialize_group_cache("universal_beings")
	_initialize_group_cache("players") 
	_initialize_group_cache("ai_companions")
	_initialize_group_cache("dormant_beings")

func _initialize_group_cache(group_name: String) -> void:
	"""Initialize cache for a specific group"""
	group_cache[group_name] = []
	group_cache_dirty[group_name] = true
	group_spatial_index[group_name] = {}

# ===== OPTIMIZED GROUP OPERATIONS =====
func get_beings_in_group_optimized(group_name: String) -> Array[Node]:
	"""Optimized version of get_nodes_in_group for Universal Beings"""
	
	# Check if cache needs refresh
	if _should_refresh_cache(group_name):
		_refresh_group_cache(group_name)
	
	# Convert WeakRefs back to Nodes (removing invalid ones)
	var valid_beings: Array[Node] = []
	var cached_refs = group_cache.get(group_name, [])
	
	for weak_ref in cached_refs:
		var being = weak_ref.get_ref()
		if being and is_instance_valid(being):
			valid_beings.append(being)
		else:
			# Mark cache as dirty if we find invalid references
			group_cache_dirty[group_name] = true
	
	return valid_beings

func get_beings_in_group_near_position(group_name: String, position: Vector3, radius: float) -> Array[Node]:
	"""Get beings in group near a specific position (spatial optimization)"""
	var spatial_index = group_spatial_index.get(group_name, {})
	var nearby_beings: Array[Node] = []
	
	# Calculate chunk coordinates to search
	var chunk_size = 50.0  # 50 unit chunks for spatial indexing
	var search_radius_chunks = int(radius / chunk_size) + 1
	
	var center_chunk = Vector3i(
		int(position.x / chunk_size),
		int(position.y / chunk_size),
		int(position.z / chunk_size)
	)
	
	# Search nearby chunks
	for x in range(-search_radius_chunks, search_radius_chunks + 1):
		for y in range(-search_radius_chunks, search_radius_chunks + 1):
			for z in range(-search_radius_chunks, search_radius_chunks + 1):
				var chunk_coord = center_chunk + Vector3i(x, y, z)
				var chunk_beings = spatial_index.get(chunk_coord, [])
				
				for weak_ref in chunk_beings:
					var being = weak_ref.get_ref()
					if being and is_instance_valid(being):
						var distance = position.distance_to(being.global_position)
						if distance <= radius:
							nearby_beings.append(being)
	
	return nearby_beings

# ===== CACHE MANAGEMENT =====
func _should_refresh_cache(group_name: String) -> bool:
	"""Check if group cache needs refreshing"""
	var current_time = Time.get_ticks_msec() / 1000.0
	return (
		group_cache_dirty.get(group_name, true) or
		(current_time - last_cache_update) > CACHE_REFRESH_INTERVAL
	)

func _refresh_group_cache(group_name: String) -> void:
	"""Refresh cache for a specific group"""
	var start_time = Time.get_ticks_msec()
	
	# Get current nodes from Godot's group system
	var current_nodes = get_tree().get_nodes_in_group(group_name)
	
	# Convert to WeakRefs for memory efficiency
	var weak_refs: Array = []
	var spatial_index: Dictionary = {}
	
	for node in current_nodes:
		var weak_ref = weakref(node)
		weak_refs.append(weak_ref)
		
		# Add to spatial index if it's a Node3D
		if node is Node3D:
			var chunk_coord = _world_to_spatial_chunk(node.global_position)
			if not chunk_coord in spatial_index:
				spatial_index[chunk_coord] = []
			spatial_index[chunk_coord].append(weak_ref)
	
	# Update caches
	group_cache[group_name] = weak_refs
	group_spatial_index[group_name] = spatial_index
	group_cache_dirty[group_name] = false
	last_cache_update = Time.get_ticks_msec() / 1000.0
	
	var processing_time = Time.get_ticks_msec() - start_time
	
	# Only log if significant group or long processing time
	if current_nodes.size() > 1000 or processing_time > 10:
		print("🌟 EnlightenedGroupManager: Refreshed %s cache (%d beings, %d ms)" % [
			group_name, current_nodes.size(), processing_time
		])

func _world_to_spatial_chunk(world_pos: Vector3) -> Vector3i:
	"""Convert world position to spatial chunk coordinate"""
	var chunk_size = 50.0
	return Vector3i(
		int(world_pos.x / chunk_size),
		int(world_pos.y / chunk_size),
		int(world_pos.z / chunk_size)
	)

# ===== PROCESSING LOOP =====
func _process(delta: float) -> void:
	"""Process group optimizations in chunks to avoid frame drops"""
	
	# Don't process every frame if we have many groups
	if groups_to_process.is_empty():
		groups_to_process = group_cache.keys()
		current_chunk_index = 0
	
	# Process a chunk of groups this frame
	var groups_this_frame = min(3, groups_to_process.size() - current_chunk_index)
	
	for i in range(groups_this_frame):
		var group_index = current_chunk_index + i
		if group_index < groups_to_process.size():
			var group_name = groups_to_process[group_index]
			_process_group_maintenance(group_name)
	
	current_chunk_index += groups_this_frame
	
	# Reset when we've processed all groups
	if current_chunk_index >= groups_to_process.size():
		groups_to_process.clear()

func _process_group_maintenance(group_name: String) -> void:
	"""Perform maintenance on a group (remove invalid refs, etc.)"""
	var cached_refs = group_cache.get(group_name, [])
	var valid_refs: Array = []
	var removed_count = 0
	
	for weak_ref in cached_refs:
		var being = weak_ref.get_ref()
		if being and is_instance_valid(being):
			valid_refs.append(weak_ref)
		else:
			removed_count += 1
	
	# Update cache if we removed invalid references
	if removed_count > 0:
		group_cache[group_name] = valid_refs
		group_cache_dirty[group_name] = true
		
		if removed_count > 10:  # Only log significant cleanups
			print("🌟 EnlightenedGroupManager: Cleaned %d invalid refs from %s" % [
				removed_count, group_name
			])

# ===== NODE LIFECYCLE =====
func _on_node_added(node: Node) -> void:
	"""Handle when nodes are added to scene tree"""
	# Mark all group caches as potentially dirty
	# We could be more precise here but this is simpler and still performant
	for group_name in group_cache.keys():
		if node.is_in_group(group_name):
			group_cache_dirty[group_name] = true

func _on_node_removed(node: Node) -> void:
	"""Handle when nodes are removed from scene tree"""
	# Mark all group caches as potentially dirty
	for group_name in group_cache.keys():
		group_cache_dirty[group_name] = true

# ===== MYSTICAL STATISTICS =====
func get_enlightenment_statistics() -> Dictionary:
	"""Get statistics about group management at mystical scale"""
	var stats = {
		"groups_managed": group_cache.size(),
		"total_cached_beings": 0,
		"cache_efficiency": {},
		"memory_usage_estimate": 0
	}
	
	for group_name in group_cache.keys():
		var cached_count = group_cache[group_name].size()
		var actual_count = get_tree().get_nodes_in_group(group_name).size()
		
		stats.total_cached_beings += cached_count
		stats.cache_efficiency[group_name] = {
			"cached": cached_count,
			"actual": actual_count,
			"accuracy": float(cached_count) / max(actual_count, 1) * 100.0
		}
		
		# Estimate memory usage (rough calculation)
		stats.memory_usage_estimate += cached_count * 16  # ~16 bytes per WeakRef
	
	return stats

# ===== UTILITY FUNCTIONS =====
func force_refresh_all_caches() -> void:
	"""Force refresh of all group caches (use sparingly)"""
	print("🌟 EnlightenedGroupManager: Force refreshing all caches...")
	for group_name in group_cache.keys():
		group_cache_dirty[group_name] = true
		_refresh_group_cache(group_name)

func get_group_distribution_by_consciousness() -> Dictionary:
	"""Get distribution of universal_beings by consciousness level"""
	var distribution = {}
	var beings = get_beings_in_group_optimized("universal_beings")
	
	for being in beings:
		if being.has_method("get"):
			var consciousness = being.get("consciousness_level")
			if consciousness in distribution:
				distribution[consciousness] += 1
			else:
				distribution[consciousness] = 1
	
	return distribution

# ===== INTEGRATION WITH QUANTUM FLOODGATES =====
func notify_being_lod_changed(being: Node, old_lod: int, new_lod: int) -> void:
	"""Notification from QuantumFloodGates about LOD changes"""
	# We could optimize group queries based on LOD level
	# For now, just mark universal_beings cache as dirty
	group_cache_dirty["universal_beings"] = true