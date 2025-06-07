# ai_companion.gd - AI companion that uses your existing AI system
extends CharacterBody3D

# Companion properties
var companion_name: String = "AI_Companion"
var ai_brain = null  # Connected to your Gemma/AI system
var personality_traits: Dictionary = {}

# Movement and behavior
var target_position: Vector3
var follow_target: Node3D
var behavior_state: String = "follow"
var detection_range: float = 500.0
var attack_range: float = 100.0

# Stats
var health: float = 100.0
var energy: float = 100.0
var mining_power: float = 5.0

# Visual components
@onready var mesh = $MeshInstance3D
@onready var trail = $Trail3D
@onready var weapon_system = $WeaponSystem

func _ready():
	# Generate personality
	personality_traits = {
		"aggression": randf(),
		"curiosity": randf(),
		"loyalty": 0.8 + randf() * 0.2,  # Always loyal
		"efficiency": randf()
	}
	
	# Set up visuals
	_setup_appearance()
	
	# Connect to player
	var player = get_node("/root/Game/PlayerShip")
	if player:
		follow_target = player

func _setup_appearance():
	# Create simple companion mesh
	if not mesh:
		mesh = MeshInstance3D.new()
		add_child(mesh)
	
	var companion_mesh = SphereMesh.new()
	companion_mesh.radius = 2.0
	companion_mesh.height = 4.0
	mesh.mesh = companion_mesh
	
	# Material based on personality
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(
		personality_traits["aggression"],
		personality_traits["loyalty"],
		personality_traits["curiosity"]
	)
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.5
	material.emission_energy = 0.5
	mesh.material_override = material

func ai_think(delta: float):
	if not ai_brain:
		# Simple fallback AI
		_simple_ai_behavior(delta)
		return
	
	# Use your Gemma integration
	if ai_brain.has_method("get_companion_action"):
		var action = ai_brain.get_companion_action({
			"position": position,
			"health": health,
			"energy": energy,
			"nearby_objects": _scan_area(),
			"player_position": follow_target.position if follow_target else Vector3.ZERO
		})
		
		_execute_ai_action(action)
	else:
		_simple_ai_behavior(delta)

func _simple_ai_behavior(delta: float):
	match behavior_state:
		"follow":
			_follow_behavior(delta)
		"mine":
			_mining_behavior(delta)
		"defend":
			_defend_behavior(delta)
		"explore":
			_explore_behavior(delta)

func _follow_behavior(delta: float):
	if not follow_target:
		return
		
	var desired_distance = 20.0
	var distance = position.distance_to(follow_target.position)
	
	if distance > desired_distance:
		# Move towards player
		var direction = (follow_target.position - position).normalized()
		target_position = follow_target.position - direction * desired_distance
		_move_to_target(delta)
	
	# Look for nearby threats or resources
	var nearby = _scan_area()
	
	# Personality affects decisions
	if personality_traits["aggression"] > 0.7 and nearby["threats"].size() > 0:
		behavior_state = "defend"
	elif personality_traits["curiosity"] > 0.7 and nearby["resources"].size() > 0:
		behavior_state = "mine"

func _mining_behavior(delta: float):
	var nearby = _scan_area()
	
	if nearby["resources"].size() == 0:
		behavior_state = "follow"
		return
	
	# Find closest resource
	var closest_resource = null
	var min_distance = INF
	
	for resource in nearby["resources"]:
		var dist = position.distance_to(resource.position)
		if dist < min_distance:
			min_distance = dist
			closest_resource = resource
	
	if closest_resource:
		target_position = closest_resource.position
		_move_to_target(delta)
		
		# Mine if close enough
		if min_distance < 10.0:
			_mine_resource(closest_resource)

func _defend_behavior(delta: float):
	var nearby = _scan_area()
	
	if nearby["threats"].size() == 0:
		behavior_state = "follow"
		return
	
	# Engage closest threat
	var closest_threat = nearby["threats"][0]
	var distance = position.distance_to(closest_threat.position)
	
	if distance < attack_range:
		_attack_target(closest_threat)
	else:
		target_position = closest_threat.position
		_move_to_target(delta)

func _explore_behavior(delta: float):
	# Random exploration based on curiosity
	if not target_position or position.distance_to(target_position) < 5.0:
		# Pick new random target
		var angle = randf() * TAU
		var distance = randf_range(50, 200)
		target_position = position + Vector3(
			cos(angle) * distance,
			randf_range(-20, 20),
			sin(angle) * distance
		)
	
	_move_to_target(delta)
	
	# Return to follow after exploring
	if position.distance_to(follow_target.position) > 200:
		behavior_state = "follow"

func _move_to_target(delta: float):
	var direction = (target_position - position).normalized()
	var speed = 50.0 * (1.0 + personality_traits["efficiency"] * 0.5)
	
	velocity = direction * speed
	move_and_slide()
	
	# Face direction of movement
	if velocity.length() > 0:
		look_at(position + velocity, Vector3.UP)

func _scan_area() -> Dictionary:
	var results = {
		"resources": [],
		"threats": [],
		"allies": []
	}
	
	# Get all nodes in detection range
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = SphereShape3D.new()
	query.shape.radius = detection_range
	query.transform = Transform3D(Basis(), position)
	
	var hits = space_state.intersect_shape(query)
	
	for hit in hits:
		var body = hit["collider"]
		if body.is_in_group("resources"):
			results["resources"].append(body)
		elif body.is_in_group("enemies"):
			results["threats"].append(body)
		elif body.is_in_group("allies"):
			results["allies"].append(body)
	
	return results

func _mine_resource(resource: Node3D):
	if not resource.has_method("mine"):
		return
		
	var mined_amount = resource.mine(mining_power)
	
	# Send resources to player
	var game = get_node("/root/Game")
	if game and game.has_method("add_resources"):
		game.add_resources(mined_amount)
	
	# Visual feedback
	_create_mining_effect(resource.position)

func _attack_target(target: Node3D):
	if not weapon_system:
		return
	
	if weapon_system.has_method("fire_at"):
		weapon_system.fire_at(target)
		
		# Use energy
		energy -= 5.0
		energy = max(0, energy)

func _create_mining_effect(pos: Vector3):
	# Simple particle effect for mining
	var particles = CPUParticles3D.new()
	particles.position = pos
	particles.amount = 20
	particles.lifetime = 1.0
	particles.direction = Vector3.UP
	particles.initial_velocity_min = 5.0
	particles.initial_velocity_max = 10.0
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.0
	particles.emitting = true
	get_parent().add_child(particles)
	
	# Auto-remove
	particles.connect("finished", particles.queue_free)

func warp_to(target_pos: Vector3):
	# Warp effect
	var warp_offset = Vector3(
		randf_range(-10, 10),
		0,
		randf_range(-10, 10)
	)
	position = target_pos + warp_offset
	
	# Reset velocity
	velocity = Vector3.ZERO

func take_damage(amount: float):
	health -= amount
	health = max(0, health)
	
	if health <= 0:
		_on_destroyed()

func _on_destroyed():
	# Explosion effect
	var explosion = preload("res://effects/explosion.tscn").instantiate()
	explosion.position = position
	get_parent().add_child(explosion)
	
	# Notify player
	var message = companion_name + " was destroyed!"
	if get_node("/root/GameUI"):
		get_node("/root/GameUI").show_message(message)
	
	queue_free()

func flee_from(danger_position: Vector3):
	# Emergency flee behavior
	behavior_state = "follow"  # Return to player
	var flee_direction = (position - danger_position).normalized()
	target_position = position + flee_direction * 500.0
	
	# Boost speed
	velocity = flee_direction * 100.0

func set_personality(traits: Dictionary):
	personality_traits = traits
	_setup_appearance()  # Update appearance based on personality

func get_status() -> Dictionary:
	return {
		"name": companion_name,
		"health": health,
		"energy": energy,
		"behavior": behavior_state,
		"position": position,
		"personality": personality_traits
	}
