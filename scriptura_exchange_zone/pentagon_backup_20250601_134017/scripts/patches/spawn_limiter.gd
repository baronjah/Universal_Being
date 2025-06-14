# ==================================================
# SCRIPT NAME: spawn_limiter.gd
# DESCRIPTION: Limits automatic spawning to prevent performance issues
# PURPOSE: Keep object count under control (max 20 objects)
# CREATED: 2025-05-28 10:00 AM - Fixing spawn spam
# ==================================================

extends UniversalBeingBase
# Spawn tracking
var spawn_counts: Dictionary = {
	"box": 0,
	"tree": 0,
	"total": 0
}

var max_total_objects: int = 20
var max_per_type: int = 10

func _ready() -> void:
	print("🚦 [SpawnLimiter] Active - Max objects: %d" % max_total_objects)
	
	# Monitor scene for new objects
	get_tree().node_added.connect(_on_node_added)
	
	# Count existing objects
	_count_existing_objects()

func _count_existing_objects() -> void:
	"""Count objects already in scene"""
	await get_tree().process_frame
	
	var all_nodes = get_tree().get_nodes_in_group("spawned_objects")
	for node in all_nodes:
		if "box" in node.name.to_lower():
			spawn_counts["box"] += 1
		elif "tree" in node.name.to_lower():
			spawn_counts["tree"] += 1
		spawn_counts["total"] += 1
	
	print("📊 [SpawnLimiter] Current counts: Boxes=%d, Trees=%d, Total=%d" % [
		spawn_counts["box"], spawn_counts["tree"], spawn_counts["total"]
	])

func _on_node_added(node: Node) -> void:
	"""Check new nodes and limit spawning"""
	if not node is Node3D:
		return
		
	var node_name = node.name.to_lower()
	
	# Check if it's a spawned object
	if "box" in node_name or "tree" in node_name:
		# Check limits
		if spawn_counts["total"] >= max_total_objects:
			print("⛔ [SpawnLimiter] Max objects reached! Removing: %s" % node.name)
			node.queue_free()
			return
		
		# Check per-type limits
		if "box" in node_name and spawn_counts["box"] >= max_per_type:
			print("⛔ [SpawnLimiter] Max boxes reached! Removing: %s" % node.name)
			node.queue_free()
			return
			
		if "tree" in node_name and spawn_counts["tree"] >= max_per_type:
			print("⛔ [SpawnLimiter] Max trees reached! Removing: %s" % node.name)
			node.queue_free()
			return
		
		# Allow spawn and track it
		if "box" in node_name:
			spawn_counts["box"] += 1
		elif "tree" in node_name:
			spawn_counts["tree"] += 1
		spawn_counts["total"] += 1
		
		# Add to spawned objects group for tracking
		node.add_to_group("spawned_objects")
		
		# Make it clickable if it has collision
		_make_clickable(node)
		
		print("✅ [SpawnLimiter] Allowed: %s (Total: %d/%d)" % [
			node.name, spawn_counts["total"], max_total_objects
		])

func _make_clickable(node: Node3D) -> void:
	"""Ensure spawned objects are clickable"""
	# Look for StaticBody3D or add one
	var body: StaticBody3D = null
	
	if node is StaticBody3D:
		body = node
	else:
		# Find StaticBody3D child
		for child in node.get_children():
			if child is StaticBody3D:
				body = child
				break
	
	if body:
		# Ensure it's in the clickable layer
		body.collision_layer = 1  # Ground/clickable layer
		body.collision_mask = 1
		
		# Add metadata for inspector
		if not node.has_meta("uuid"):
			node.set_meta("uuid", "obj_" + str(Time.get_ticks_msec()))
		if not node.has_meta("type"):
			if "box" in node.name.to_lower():
				node.set_meta("type", "box")
			elif "tree" in node.name.to_lower():
				node.set_meta("type", "tree")
		
		print("🖱️ [SpawnLimiter] Made clickable: %s" % node.name)


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
func reset_counts() -> void:
	"""Reset spawn counts"""
	spawn_counts = {
		"box": 0,
		"tree": 0,
		"total": 0
	}
	_count_existing_objects()

func get_status() -> String:
	"""Get current spawn status"""
	return "Spawn Status: Boxes=%d/%d, Trees=%d/%d, Total=%d/%d" % [
		spawn_counts["box"], max_per_type,
		spawn_counts["tree"], max_per_type,
		spawn_counts["total"], max_total_objects
	]