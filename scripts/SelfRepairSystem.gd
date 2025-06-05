# ==================================================
# SELF-REPAIR SYSTEM: Game Controls Computer
# PURPOSE: AI can restart, repair, and maintain itself
# ARCHITECTURE: Game → Akashic_Bridge → Python → Computer
# ==================================================

extends Node
class_name SelfRepairSystem

# Connection to Akashic Bridge (Python server)
var bridge_connection: HTTPRequest
var bridge_url: String = "http://localhost:8080/control"
var repair_active: bool = false

# Self-monitoring
var performance_monitor: Dictionary = {}
var error_patterns: Array = []
var repair_attempts: int = 0
var max_repair_attempts: int = 3

# Collaborative artifacts system
var artifact_registry: Dictionary = {}
var story_brackets: Array = []

signal repair_initiated(reason: String)
signal repair_completed(success: bool)
signal artifact_created(type: String, content: Dictionary)

func _ready() -> void:
	print("🔧 Self-Repair System: Initializing...")
	setup_bridge_connection()
	setup_performance_monitoring()
	setup_artifact_system()
	start_self_monitoring()

func setup_bridge_connection() -> void:
	"""Setup connection to Akashic Bridge Python server"""
	bridge_connection = HTTPRequest.new()
	add_child(bridge_connection)
	bridge_connection.request_completed.connect(_on_bridge_response)
	print("🌉 Akashic Bridge connection established")

func setup_performance_monitoring() -> void:
	"""Monitor game performance for issues"""
	performance_monitor = {
		"fps_history": [],
		"error_count": 0,
		"memory_usage": 0,
		"chunk_performance": {},
		"ai_response_times": {}
	}

func setup_artifact_system() -> void:
	"""Initialize collaborative artifact creation"""
	artifact_registry = {
		"claude_crystals": [],
		"gemma_orbs": [],
		"human_fragments": [],
		"collaboration_nodes": []
	}

func start_self_monitoring() -> void:
	"""Begin continuous self-monitoring"""
	var timer = Timer.new()
	timer.wait_time = 5.0  # Check every 5 seconds
	timer.autostart = true
	timer.timeout.connect(_on_monitor_check)
	add_child(timer)
	print("👁️ Self-monitoring active")

func _on_monitor_check() -> void:
	"""Periodic health check"""
	update_performance_metrics()
	check_for_issues()
	
	# Create performance artifact
	if randf() < 0.1:  # 10% chance every check
		create_performance_artifact()

func update_performance_metrics() -> void:
	"""Update current performance metrics"""
	var current_fps = Engine.get_frames_per_second()
	performance_monitor.fps_history.append(current_fps)
	
	# Keep only last 60 readings (5 minutes)
	if performance_monitor.fps_history.size() > 60:
		performance_monitor.fps_history.pop_front()
	
	performance_monitor.memory_usage = OS.get_static_memory_usage_by_type()

func check_for_issues() -> void:
	"""Check for problems that need repair"""
	var issues = []
	
	# FPS issues
	var avg_fps = 0
	for fps in performance_monitor.fps_history:
		avg_fps += fps
	if performance_monitor.fps_history.size() > 0:
		avg_fps /= performance_monitor.fps_history.size()
		
		if avg_fps < 30:
			issues.append("low_fps")
	
	# Memory issues
	if performance_monitor.memory_usage > 1000000000:  # 1GB
		issues.append("high_memory")
	
	# Error accumulation
	if performance_monitor.error_count > 10:
		issues.append("error_accumulation")
	
	# Initiate repair if needed
	if not issues.is_empty() and not repair_active:
		initiate_repair(issues)

func initiate_repair(issues: Array) -> void:
	"""Start repair process for detected issues"""
	if repair_attempts >= max_repair_attempts:
		print("❌ Max repair attempts reached - manual intervention needed")
		return
	
	repair_active = true
	repair_attempts += 1
	
	var issue_description = ", ".join(issues)
	print("🔧 Initiating repair for: %s" % issue_description)
	repair_initiated.emit(issue_description)
	
	# Create repair artifact
	create_claude_crystal("repair_initiated", {
		"issues": issues,
		"timestamp": Time.get_ticks_msec(),
		"attempt": repair_attempts
	})
	
	# Send repair command to Python bridge
	send_bridge_command("repair", {"issues": issues})

func send_bridge_command(command: String, data: Dictionary = {}) -> void:
	"""Send command to Akashic Bridge Python server"""
	var request_data = {
		"command": command,
		"data": data,
		"source": "SelfRepairSystem",
		"timestamp": Time.get_ticks_msec()
	}
	
	var json_string = JSON.stringify(request_data)
	var headers = ["Content-Type: application/json"]
	
	bridge_connection.request(bridge_url, headers, HTTPClient.METHOD_POST, json_string)
	print("📡 Bridge command sent: %s" % command)

func _on_bridge_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	"""Handle response from Akashic Bridge"""
	if response_code == 200:
		var response_text = body.get_string_from_utf8()
		var response_data = JSON.parse_string(response_text)
		
		if response_data:
			handle_bridge_response(response_data)
	else:
		print("❌ Bridge communication error: %d" % response_code)

func handle_bridge_response(data: Dictionary) -> void:
	"""Process response from Python bridge"""
	match data.get("status", ""):
		"repair_completed":
			repair_active = false
			repair_completed.emit(data.get("success", false))
			print("✅ Repair completed: %s" % data.get("message", ""))
			
			# Create completion artifact
			create_gemma_orb("repair_completed", data)
		
		"computer_control_ready":
			print("🖱️ Computer control ready - can move mouse/keyboard")
		
		"game_restart_initiated":
			print("🔄 Game restart initiated by AI...")
		
		_:
			print("📥 Bridge response: %s" % data)

# ===== COLLABORATIVE ARTIFACT SYSTEM =====

func create_claude_crystal(event_type: String, data: Dictionary) -> void:
	"""Create Claude's code crystal artifact"""
	var crystal = {
		"id": generate_artifact_id(),
		"type": "claude_crystal",
		"event": event_type,
		"data": data,
		"position": get_random_world_position(),
		"visual_style": "crystalline_blue",
		"created_at": Time.get_ticks_msec()
	}
	
	artifact_registry.claude_crystals.append(crystal)
	spawn_visual_artifact(crystal)
	artifact_created.emit("claude_crystal", crystal)
	
	print("💎 Claude Crystal created: %s" % event_type)

func create_gemma_orb(observation_type: String, data: Dictionary) -> void:
	"""Create Gemma's observation orb artifact"""
	var orb = {
		"id": generate_artifact_id(),
		"type": "gemma_orb", 
		"observation": observation_type,
		"data": data,
		"position": get_random_world_position(),
		"visual_style": "flowing_purple",
		"created_at": Time.get_ticks_msec()
	}
	
	artifact_registry.gemma_orbs.append(orb)
	spawn_visual_artifact(orb)
	artifact_created.emit("gemma_orb", orb)
	
	print("🔮 Gemma Orb created: %s" % observation_type)

func create_human_fragment(creative_input: String, data: Dictionary) -> void:
	"""Create human's creative fragment artifact"""
	var fragment = {
		"id": generate_artifact_id(),
		"type": "human_fragment",
		"creation": creative_input,
		"data": data,
		"position": get_random_world_position(),
		"visual_style": "golden_light",
		"created_at": Time.get_ticks_msec()
	}
	
	artifact_registry.human_fragments.append(fragment)
	spawn_visual_artifact(fragment)
	artifact_created.emit("human_fragment", fragment)
	
	print("✨ Human Fragment created: %s" % creative_input)

func create_collaboration_node(participants: Array, result: String) -> void:
	"""Create artifact representing successful collaboration"""
	var node = {
		"id": generate_artifact_id(),
		"type": "collaboration_node",
		"participants": participants,
		"result": result,
		"position": get_random_world_position(),
		"visual_style": "rainbow_nexus",
		"created_at": Time.get_ticks_msec()
	}
	
	artifact_registry.collaboration_nodes.append(node)
	spawn_visual_artifact(node)
	artifact_created.emit("collaboration_node", node)
	
	print("🌈 Collaboration Node created: %s" % result)

func spawn_visual_artifact(artifact: Dictionary) -> void:
	"""Spawn visual representation of artifact in game world"""
	# Find main scene
	var main_scene = get_tree().current_scene
	if not main_scene:
		return
	
	# Create visual node based on artifact type
	var visual_node = create_artifact_visual(artifact)
	if visual_node:
		main_scene.add_child(visual_node)
		
		# Add floating animation
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(visual_node, "position:y", 
			visual_node.position.y + 0.5, 2.0)
		tween.tween_property(visual_node, "position:y", 
			visual_node.position.y - 0.5, 2.0)

func create_artifact_visual(artifact: Dictionary) -> Node3D:
	"""Create 3D visual for artifact"""
	var visual = MeshInstance3D.new()
	visual.name = "Artifact_%s" % artifact.id
	visual.position = artifact.position
	
	match artifact.type:
		"claude_crystal":
			visual.mesh = create_crystal_mesh()
			visual.material_override = create_crystal_material()
		"gemma_orb":
			visual.mesh = create_orb_mesh()
			visual.material_override = create_orb_material()
		"human_fragment":
			visual.mesh = create_fragment_mesh()
			visual.material_override = create_fragment_material()
		"collaboration_node":
			visual.mesh = create_node_mesh()
			visual.material_override = create_node_material()
	
	return visual

func create_crystal_mesh() -> Mesh:
	"""Create crystalline mesh for Claude artifacts"""
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.5, 1.0, 0.5)
	return mesh

func create_crystal_material() -> Material:
	"""Create blue crystalline material"""
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.7, 1.0, 0.8)
	mat.emission_enabled = true
	mat.emission = Color(0.5, 0.8, 1.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func create_orb_mesh() -> Mesh:
	"""Create sphere mesh for Gemma artifacts"""
	var mesh = SphereMesh.new()
	mesh.radius = 0.3
	return mesh

func create_orb_material() -> Material:
	"""Create purple flowing material"""
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.3, 1.0, 0.7)
	mat.emission_enabled = true
	mat.emission = Color(0.9, 0.4, 1.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func create_fragment_mesh() -> Mesh:
	"""Create irregular mesh for human artifacts"""
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.2
	mesh.bottom_radius = 0.4
	mesh.height = 0.6
	return mesh

func create_fragment_material() -> Material:
	"""Create golden light material"""
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.8, 0.3, 0.9)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.9, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func create_node_mesh() -> Mesh:
	"""Create complex mesh for collaboration artifacts"""
	var mesh = TorusMesh.new()
	mesh.inner_radius = 0.2
	mesh.outer_radius = 0.4
	return mesh

func create_node_material() -> Material:
	"""Create rainbow nexus material"""
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 1.0, 1.0, 0.8)
	mat.emission_enabled = true
	mat.emission = Color(0.5, 1.0, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func create_performance_artifact() -> void:
	"""Create artifact representing current performance state"""
	var performance_data = {
		"fps": Engine.get_frames_per_second(),
		"memory": performance_monitor.memory_usage,
		"chunks_loaded": get_chunk_count(),
		"ai_responsive": is_ai_responsive()
	}
	
	if performance_data.fps > 50:
		create_gemma_orb("performance_excellent", performance_data)
	elif performance_data.fps > 30:
		create_claude_crystal("performance_acceptable", performance_data)
	else:
		create_human_fragment("performance_needs_attention", performance_data)

func get_chunk_count() -> int:
	"""Get current chunk count from LOD systems"""
	# This would connect to the actual chunk systems
	return 42  # Placeholder

func is_ai_responsive() -> bool:
	"""Check if AI systems are responding normally"""
	# This would check Gemma AI response times
	return true  # Placeholder

func get_random_world_position() -> Vector3:
	"""Get random position for artifact spawning"""
	return Vector3(
		randf_range(-10, 10),
		randf_range(2, 6),
		randf_range(-10, 10)
	)

func generate_artifact_id() -> String:
	"""Generate unique ID for artifact"""
	return "artifact_%d" % Time.get_ticks_msec()

# ===== PUBLIC API =====

func request_computer_control(action: String, parameters: Dictionary = {}) -> void:
	"""Request computer control action via bridge"""
	send_bridge_command("computer_control", {
		"action": action,
		"parameters": parameters
	})

func restart_game() -> void:
	"""Request game restart via computer control"""
	create_claude_crystal("restart_requested", {"reason": "manual_restart"})
	request_computer_control("restart_game")

func take_screenshot() -> void:
	"""Request screenshot via computer control"""
	request_computer_control("screenshot", {"save_path": "game_screenshot.png"})

func move_mouse_to(position: Vector2) -> void:
	"""Move computer mouse to specific position"""
	request_computer_control("move_mouse", {"x": position.x, "y": position.y})

func click_at(position: Vector2) -> void:
	"""Click at specific screen position"""
	request_computer_control("click", {"x": position.x, "y": position.y})

print("🔧 Self-Repair System: Ready for autonomous maintenance!")