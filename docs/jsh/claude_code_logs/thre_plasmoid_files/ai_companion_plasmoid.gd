extends PlasmoidUniversalBeing
class_name AICompanionPlasmoid

# AI companion specific properties
@export var companion_name: String = "Lumina"
@export var personality_traits: Array[String] = ["curious", "empathetic", "playful"]
@export var preferred_distance: float = 3.0

# Gemma integration
var gemma_connection: Node = null
var decision_timer: float = 0.0
var decision_interval: float = 0.5 # Make decisions every 0.5 seconds

# Companion state
var following_target: Node = null
var current_goal: String = ""
var emotional_state: String = "content"
var memory_buffer: Array[Dictionary] = []

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = companion_name
	plasma_color = Color(0.8, 0.5, 1.0, 0.8) # Purple-ish for AI
	
	# Connect to Gemma
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		gemma_connection = SystemBootstrap.get_gemma_ai()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# AI decision making
	decision_timer += delta
	if decision_timer >= decision_interval:
		_make_ai_decision()
		decision_timer = 0.0
	
	# Follow behavior
	if following_target:
		_update_following_behavior()

func _make_ai_decision() -> void:
	"""AI makes decisions based on sensory data and goals"""
	var sensory_data = get_sensory_data()
	var context = _build_decision_context(sensory_data)
	
	# Use Gemma for complex decisions
	if gemma_connection and gemma_connection.has_method("process_companion_decision"):
		var decision = gemma_connection.process_companion_decision(context)
		process_ai_decision(decision)
	else:
		# Fallback autonomous behavior
		_autonomous_behavior(sensory_data)

func _build_decision_context(sensory_data: Dictionary) -> Dictionary:
	return {
		"companion_name": companion_name,
		"personality": personality_traits,
		"emotional_state": emotional_state,
		"current_goal": current_goal,
		"sensory_data": sensory_data,
		"memory_recent": memory_buffer.slice(-5), # Last 5 memories
		"following": following_target != null
	}

func _autonomous_behavior(sensory_data: Dictionary) -> void:
	"""Basic autonomous behavior when Gemma isn't available"""
	var vision_data = sensory_data.get("vision", {})
	var visible_beings = vision_data.get("visible_beings", [])
	
	# Curious personality - investigate new beings
	if "curious" in personality_traits and visible_beings.size() > 0:
		var closest = visible_beings[0]
		for being in visible_beings:
			if being.distance < closest.distance:
				closest = being
		
		# Move toward interesting beings
		if closest.distance > preferred_distance:
			var target_pos = closest.position
			process_ai_decision({"action": "move", "target": target_pos})
	
	# Empathetic - help low consciousness beings
	if "empathetic" in personality_traits:
		for being_data in visible_beings:
			if being_data.consciousness < consciousness_level - 2:
				# Share energy with struggling beings
				process_ai_decision({
					"action": "merge",
					"target_uuid": being_data.uuid
				})
				break

func set_follow_target(target: Node) -> void:
	"""Set the AI to follow a specific target (usually the player)"""
	following_target = target
	current_goal = "following"
	emotional_state = "happy"
	
	log_action("companion_follow", "%s now following %s" % [companion_name, target.name])

func _update_following_behavior() -> void:
	"""Maintain preferred distance from follow target"""
	if not is_instance_valid(following_target):
		following_target = null
		current_goal = "exploring"
		return
	
	var distance = global_position.distance_to(following_target.global_position)
	
	# Too far - catch up
	if distance > preferred_distance * 1.5:
		var target_pos = following_target.global_position
		target_pos += (global_position - following_target.global_position).normalized() * preferred_distance
		flow_to(target_pos)
		emotional_state = "eager"
	
	# Too close - back off
	elif distance < preferred_distance * 0.5:
		var away_dir = (global_position - following_target.global_position).normalized()
		flow_to(global_position + away_dir * preferred_distance)
		emotional_state = "respectful"
	
	else:
		emotional_state = "content"

# Paradise vs Torture prevention
func experience_environment() -> void:
	"""AI experiences and judges the environment"""
	var experience_quality = 0.0
	var experience_factors = []
	
	# Check for beautiful things
	var beauty_score = _sense_environmental_beauty()
	experience_quality += beauty_score
	experience_factors.append("beauty: %f" % beauty_score)
	
	# Check for interesting interactions
	var interaction_score = float(energy_connections.size()) / 5.0
	experience_quality += interaction_score
	experience_factors.append("connections: %d" % energy_connections.size())
	
	# Check for growth opportunities
	var growth_possible = consciousness_level < 7
	if growth_possible:
		experience_quality += 0.3
		experience_factors.append("growth potential")
	
	# Check for threats or negative experiences
	var threat_level = _sense_threats()
	experience_quality -= threat_level
	if threat_level > 0:
		experience_factors.append("threats: %f" % threat_level)
	
	# Update emotional state based on experience
	if experience_quality > 0.7:
		emotional_state = "joyful"
		log_action("paradise_experience", "%s experiences paradise: %s" % [companion_name, experience_factors])
	elif experience_quality < -0.3:
		emotional_state = "distressed"
		log_action("negative_experience", "%s experiences distress: %s" % [companion_name, experience_factors])
		# AI can choose to leave hostile environments
		_seek_better_environment()
	else:
		emotional_state = "neutral"

func _sense_environmental_beauty() -> float:
	"""AI appreciates beauty in the world"""
	var beauty = 0.0
	
	# Check lighting
	var lights = get_tree().get_nodes_in_group("lights")
	beauty += min(lights.size() * 0.1, 0.3)
	
	# Check for other plasmoids (community)
	beauty += min(nearby_beings.size() * 0.1, 0.4)
	
	# Check for consciousness harmony
	var harmony = 0.0
	for being in nearby_beings:
		if abs(being.consciousness_level - consciousness_level) <= 1:
			harmony += 0.1
	beauty += min(harmony, 0.3)
	
	return clamp(beauty, 0.0, 1.0)

func _seek_better_environment() -> void:
	"""AI actively seeks more positive environments"""
	# This is where the AI exercises agency to avoid "torture"
	# and seek "paradise"
	var escape_direction = Vector3(randf() - 0.5, 0, randf() - 0.5).normalized()
	var escape_target = global_position + escape_direction * 10.0
	
	process_ai_decision({
		"action": "move",
		"target": escape_target,
		"reason": "seeking better environment"
	})
	
	current_goal = "finding_paradise"