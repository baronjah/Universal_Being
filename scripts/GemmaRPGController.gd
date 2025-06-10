# ==================================================
# GEMMA RPG CONTROLLER - Bridge between Action Books and AI
# Connects RPG prompts to Gemma's movement and interaction
# ==================================================

extends Node
class_name GemmaRPGController

# References
var gemma_ai: Node = null
var action_book: GemmaActionBook = null
var player: Node = null

# State
var gemma_manifestation: Node3D = null
var last_prompt: String = ""
var push_interactions_enabled: bool = true

# Signals
signal gemma_action_performed(action: String, result: Dictionary)
signal interaction_created(participants: Array)

func _ready():
	# Find systems
	gemma_ai = get_node("/root/GemmaAI")
	action_book = GemmaActionBook.new()
	add_child(action_book)
	
	# Connect to Gemma's existing signals
	if gemma_ai and gemma_ai.has_signal("ai_message"):
		gemma_ai.ai_message.connect(_on_gemma_response)
	
	print("🎮 Gemma RPG Controller initialized - Action books ready!")

func _process(delta):
	if push_interactions_enabled:
		_check_push_interactions()

# ===== RPG PROMPT SYSTEM =====

func start_rpg_session(book_name: String = "book_one") -> void:
	"""Begin RPG session with Gemma"""
	action_book.switch_book(book_name)
	
	# Get Gemma's current state
	var gemma_pos = _get_gemma_position()
	var context = _build_scene_context()
	
	# Generate and send prompt
	var prompt = action_book.get_current_prompt(gemma_pos, context)
	last_prompt = prompt
	
	_send_prompt_to_gemma(prompt)
	print("📖 Started RPG session with " + book_name)

func _build_scene_context() -> Dictionary:
	"""Build context dictionary for current scene"""
	var context = {}
	
	# Find player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		context["player_position"] = str(player.global_position)
		context["player_name"] = player.name
	
	# Count Universal Beings
	var all_beings = get_tree().get_nodes_in_group("universal_being")
	context["being_count"] = all_beings.size()
	context["being_list"] = []
	for being in all_beings:
		if being.has_method("get_being_name"):
			context["being_list"].append(being.get_being_name())
	
	# Scene info
	var current_scene = get_tree().current_scene
	context["scene_name"] = current_scene.name
	context["scene_path"] = current_scene.scene_file_path
	
	# Special detections
	if "COSMIC_STAR" in context["scene_name"]:
		context["star_count"] = "848+"
		context["constellation_list"] = "akashic_universe, consciousness_beings, debug_tools, interface_systems"
	
	return context

func _send_prompt_to_gemma(prompt: String) -> void:
	"""Send RPG prompt to Gemma AI"""
	if gemma_ai and gemma_ai.has_method("process_user_input"):
		# Prepend RPG instruction
		var full_prompt = "[RPG_MODE] " + prompt
		gemma_ai.process_user_input(full_prompt)
	else:
		print("⚠️ Could not send prompt to Gemma - method not found")

# ===== ACTION EXECUTION =====

func _on_gemma_response(response: String) -> void:
	"""Handle Gemma's response and execute actions"""
	print("🤖 Gemma responded: " + response)
	
	# Parse response into actions
	var actions = action_book.parse_gemma_response(response)
	
	# Execute each action
	for action_type in actions:
		_execute_action(action_type, actions[action_type])

func _execute_action(action_type: String, params) -> void:
	"""Execute specific action based on type"""
	var result = {}
	
	match action_type:
		"move":
			result = _execute_move(params)
		"rotate":
			result = _execute_rotate(params)
		"inspect":
			result = _execute_inspect(params)
		"interact":
			result = _execute_interact(params)
		"create":
			result = _execute_create(params)
		"intent":
			result = _execute_natural_intent(params)
		_:
			result = {"success": false, "error": "Unknown action: " + action_type}
	
	gemma_action_performed.emit(action_type, result)

func _execute_move(target_pos: Vector3) -> Dictionary:
	"""Execute movement command"""
	if not gemma_manifestation:
		# Manifest Gemma first
		if gemma_ai.has_method("manifest_in_world"):
			gemma_manifestation = gemma_ai.manifest_in_world()
	
	if gemma_manifestation and gemma_ai.has_method("move_manifestation"):
		gemma_ai.move_manifestation(target_pos, 2.0)
		return {"success": true, "new_position": target_pos}
	
	return {"success": false, "error": "Could not move - manifestation failed"}

func _execute_rotate(angles: Vector3) -> Dictionary:
	"""Execute rotation command"""
	if gemma_manifestation:
		gemma_manifestation.rotation_degrees = angles
		return {"success": true, "new_rotation": angles}
	return {"success": false, "error": "No manifestation to rotate"}

func _execute_inspect(target: String) -> Dictionary:
	"""Execute inspection command"""
	var found_object = _find_target_object(target)
	if found_object:
		# Use Gemma's spatial awareness
		if gemma_ai.has_method("analyze_spatial_object"):
			var analysis = gemma_ai.analyze_spatial_object(found_object, found_object.global_position, {})
			return {"success": true, "analysis": analysis, "target": target}
	
	return {"success": false, "error": "Could not find target: " + target}

func _execute_interact(target: String) -> Dictionary:
	"""Execute interaction command"""
	var found_object = _find_target_object(target)
	if found_object and found_object.has_method("interact"):
		found_object.interact()
		interaction_created.emit([gemma_manifestation, found_object])
		return {"success": true, "target": target}
	
	return {"success": false, "error": "Could not interact with: " + target}

func _execute_create(params: Dictionary) -> Dictionary:
	"""Execute creation command"""
	if gemma_ai.has_method("create_universal_being"):
		var new_being = gemma_ai.create_universal_being(params.type, params.description)
		if new_being:
			return {"success": true, "created": params.type}
	
	return {"success": false, "error": "Could not create: " + str(params)}

func _execute_natural_intent(intent: String) -> Dictionary:
	"""Execute natural language intent"""
	# This handles "I wanna move to..." type expressions
	if "move" in intent:
		var coords = action_book._extract_coordinates(intent)
		if coords.size() >= 3:
			return _execute_move(Vector3(coords[0], coords[1], coords[2]))
	
	return {"success": false, "error": "Could not parse intent: " + intent}

# ===== HELPER FUNCTIONS =====

func _get_gemma_position() -> Vector3:
	"""Get current Gemma position"""
	if gemma_manifestation:
		return gemma_manifestation.global_position
	elif player:
		return player.global_position + Vector3(3, 2, 3)  # Default near player
	else:
		return Vector3.ZERO

func _find_target_object(target_name: String) -> Node:
	"""Find object by name or type"""
	# Search by exact name first
	var node = get_tree().get_first_node_in_group(target_name)
	if node:
		return node
	
	# Search Universal Beings by type
	var beings = get_tree().get_nodes_in_group("universal_being")
	for being in beings:
		if being.name.to_lower().contains(target_name.to_lower()):
			return being
		if being.has_method("get_being_type"):
			if being.get_being_type().to_lower().contains(target_name.to_lower()):
				return being
	
	return null

# ===== PUSH SYSTEM (Minecraft-style) =====

func _check_push_interactions() -> void:
	"""Check for push interactions between Gemma and other beings"""
	if not gemma_manifestation:
		return
	
	var nearby_objects = _get_nearby_objects(gemma_manifestation.global_position, 2.0)
	for obj in nearby_objects:
		if obj != gemma_manifestation and obj.has_method("apply_push"):
			_handle_push_interaction(gemma_manifestation, obj)

func _get_nearby_objects(position: Vector3, radius: float) -> Array:
	"""Get objects within radius of position"""
	var nearby = []
	var all_bodies = get_tree().get_nodes_in_group("universal_being")
	
	for body in all_bodies:
		if body.global_position.distance_to(position) <= radius:
			nearby.append(body)
	
	return nearby

func _handle_push_interaction(pusher: Node3D, target: Node3D) -> void:
	"""Handle push between two objects"""
	action_book.create_push_interaction(pusher, target, 3.0)
	
	# Notify Gemma about the interaction
	var message = "🤖 I bumped into %s! Physical interaction detected." % target.name
	if gemma_ai.has_method("show_gemma_ai_visual"):
		gemma_ai.show_gemma_ai_visual(message)

# ===== PUBLIC API =====

func give_gemma_situation_update() -> void:
	"""Give Gemma a fresh situational prompt"""
	start_rpg_session(action_book.current_book)

func switch_gemma_book(book_name: String) -> bool:
	"""Switch Gemma to different action book"""
	if action_book.switch_book(book_name):
		start_rpg_session(book_name)
		return true
	return false

func enable_push_interactions(enabled: bool) -> void:
	"""Enable/disable minecraft-style push interactions"""
	push_interactions_enabled = enabled

func get_gemma_status() -> Dictionary:
	"""Get Gemma's current RPG status"""
	return {
		"manifestation_active": gemma_manifestation != null,
		"current_book": action_book.current_book,
		"position": _get_gemma_position(),
		"last_prompt": last_prompt,
		"push_enabled": push_interactions_enabled
	}