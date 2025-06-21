# ==================================================
# KNOWLEDGE LOD MANAGER - Interface Integration
# PURPOSE: Integrate Knowledge LOD system with main game
# USAGE: Add to main game scene for N key toggle
# ==================================================

extends Node
class_name KnowledgeLODManager

## Toggle knowledge interface in main game
## Handles scene switching and state preservation

# Knowledge LOD Scene
var knowledge_scene: PackedScene
var knowledge_instance: Node3D
var is_knowledge_active: bool = false

# Main game references
var main_scene: Node3D
var player: Node3D
var original_camera: Camera3D

# Status tracking
var current_space: String = "claude_desktop"
var current_lod: String = "MEDIUM"
var active_chunks: int = 0
var cache_status: String = "0/1000"

signal knowledge_lod_opened()
signal knowledge_lod_closed()
signal knowledge_space_changed(space_name: String)

func _ready() -> void:
	# Load knowledge LOD scene
	knowledge_scene = preload("res://scenes/knowledge_lod_interface.tscn")
	
	# Find main game components
	main_scene = get_tree().current_scene
	find_player_and_camera()
	
	print("📚 Knowledge LOD Manager: Ready (Press N to toggle)")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("notepad_toggle"):
		toggle_knowledge_lod()

func find_player_and_camera() -> void:
	"""Find player and camera in the main scene"""
	# Look for player (CharacterBody3D with specific script)
	for child in main_scene.get_children():
		if child is CharacterBody3D:
			player = child
			break
	
	# Find camera
	if player:
		original_camera = find_camera_in_node(player)
	
	if not original_camera:
		# Fallback: find any Camera3D in scene
		original_camera = find_camera_in_node(main_scene)

func find_camera_in_node(node: Node) -> Camera3D:
	"""Recursively find Camera3D in node tree"""
	if node is Camera3D:
		return node
	
	for child in node.get_children():
		var camera = find_camera_in_node(child)
		if camera:
			return camera
	
	return null

func toggle_knowledge_lod() -> void:
	"""Toggle knowledge LOD interface"""
	if is_knowledge_active:
		close_knowledge_lod()
	else:
		open_knowledge_lod()

func open_knowledge_lod() -> void:
	"""Open knowledge LOD interface"""
	if is_knowledge_active:
		return
	
	print("📚 Opening Knowledge LOD Interface...")
	
	# Instance knowledge scene
	knowledge_instance = knowledge_scene.instantiate()
	get_tree().current_scene.add_child(knowledge_instance)
	
	# Connect signals from knowledge system
	if knowledge_instance.has_signal("pentagon_sewers"):
		knowledge_instance.connect("pentagon_sewers", _on_knowledge_closed)
	
	# Setup UI updates
	setup_ui_updates()
	
	# Switch input focus
	set_process_input(true)
	
	is_knowledge_active = true
	knowledge_lod_opened.emit()
	
	print("✅ Knowledge LOD Interface opened! Use 1-5 to switch spaces, Tab for LOD")

func close_knowledge_lod() -> void:
	"""Close knowledge LOD interface"""
	if not is_knowledge_active:
		return
	
	print("📚 Closing Knowledge LOD Interface...")
	
	# Remove knowledge instance
	if knowledge_instance:
		knowledge_instance.queue_free()
		knowledge_instance = null
	
	# Restore input focus
	set_process_input(false)
	
	is_knowledge_active = false
	knowledge_lod_closed.emit()
	
	print("✅ Knowledge LOD Interface closed")

func setup_ui_updates() -> void:
	"""Setup real-time UI updates"""
	if not knowledge_instance:
		return
	
	# Find UI elements
	var current_space_label = knowledge_instance.get_node_or_null("NavigationUI/HUD/StatusPanel/StatusInfo/CurrentSpace")
	var lod_label = knowledge_instance.get_node_or_null("NavigationUI/HUD/StatusPanel/StatusInfo/LODLevel")
	var chunks_label = knowledge_instance.get_node_or_null("NavigationUI/HUD/StatusPanel/StatusInfo/ActiveChunks")
	var cache_label = knowledge_instance.get_node_or_null("NavigationUI/HUD/StatusPanel/StatusInfo/CacheStatus")
	
	# Start update timer
	var timer = Timer.new()
	timer.wait_time = 0.5  # Update every 500ms
	timer.timeout.connect(_update_ui_status)
	timer.autostart = true
	knowledge_instance.add_child(timer)

func _update_ui_status() -> void:
	"""Update UI with current knowledge LOD status"""
	if not knowledge_instance:
		return
	
	# Get status from knowledge system
	var status = get_knowledge_status()
	
	# Update UI labels
	var current_space_label = knowledge_instance.get_node_or_null("NavigationUI/HUD/StatusPanel/StatusInfo/CurrentSpace")
	var lod_label = knowledge_instance.get_node_or_null("NavigationUI/HUD/StatusPanel/StatusInfo/LODLevel")
	var chunks_label = knowledge_instance.get_node_or_null("NavigationUI/HUD/StatusPanel/StatusInfo/ActiveChunks")
	var cache_label = knowledge_instance.get_node_or_null("NavigationUI/HUD/StatusPanel/StatusInfo/CacheStatus")
	
	if current_space_label:
		current_space_label.text = "Space: " + status.current_space
	if lod_label:
		lod_label.text = "LOD: " + status.lod_level
	if chunks_label:
		chunks_label.text = "Active Chunks: " + str(status.active_chunks)
	if cache_label:
		cache_label.text = "Cache: " + status.cache_status

func get_knowledge_status() -> Dictionary:
	"""Get current status from knowledge LOD system"""
	if not knowledge_instance:
		return {
			"current_space": current_space,
			"lod_level": current_lod,
			"active_chunks": active_chunks,
			"cache_status": cache_status
		}
	
	# Get real status from knowledge system
	return {
		"current_space": knowledge_instance.current_space,
		"lod_level": knowledge_instance.KnowledgeLOD.keys()[knowledge_instance.current_lod_level],
		"active_chunks": knowledge_instance.active_chunks.size(),
		"cache_status": str(knowledge_instance.knowledge_cache.size()) + "/" + str(knowledge_instance.cache_max_size)
	}

func _on_knowledge_closed() -> void:
	"""Handle knowledge system closure"""
	close_knowledge_lod()

# ===== CONSOLE INTEGRATION =====

func get_console_status() -> String:
	"""Get status for console display"""
	if not is_knowledge_active:
		return "📚 Knowledge LOD: Inactive (Press N to activate)"
	
	var status = get_knowledge_status()
	return """
📚 KNOWLEDGE LOD STATUS

Current Space: %s
LOD Level: %s
Active Chunks: %d
Cache: %s
Knowledge Nodes: %d

Press N to close
""" % [
		status.current_space,
		status.lod_level,
		status.active_chunks,
		status.cache_status,
		knowledge_instance.knowledge_nodes.size() if knowledge_instance else 0
	]

# ===== AUTOLOAD INTEGRATION =====

func switch_knowledge_space(space_name: String) -> void:
	"""Switch knowledge space (can be called from console)"""
	if knowledge_instance and knowledge_instance.has_method("switch_to_knowledge_space"):
		knowledge_instance.switch_to_knowledge_space(space_name)
		knowledge_space_changed.emit(space_name)
		print("🌌 Switched to knowledge space: " + space_name)

func cycle_lod_level() -> void:
	"""Cycle LOD level (can be called from console)"""
	if knowledge_instance and knowledge_instance.has_method("cycle_lod_level"):
		knowledge_instance.cycle_lod_level()

func search_knowledge(query: String = "") -> void:
	"""Search knowledge (can be called from console)"""
	if knowledge_instance:
		print("🔍 Searching knowledge for: " + query)
		# Implement search functionality