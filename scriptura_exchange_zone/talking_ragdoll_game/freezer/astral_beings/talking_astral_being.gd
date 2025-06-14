# ==================================================
# SCRIPT NAME: talking_astral_being.gd
# DESCRIPTION: Unified astral being system with talking, helping, and advanced behaviors
# PURPOSE: Combines all astral being features into one comprehensive system
# CREATED: 2025-05-24 - Complete ethereal helper system
# ==================================================

extends UniversalBeingBase
# class_name TalkingAstralBeing  # Removed to avoid global class conflict

signal being_spoke(being: Node3D, message: String)
signal being_action_taken(being: Node3D, action: String, target: Node)
signal connection_made(being: Node3D, object: Node)
# signal assistance_completed(being: Node3D, mode: int)  # TODO: Emit when assistance tasks are completed

# ================================
# ENUMS AND CONSTANTS
# ================================

## Personality types
enum Personality {
	HELPFUL,
	CURIOUS,
	WISE,
	PLAYFUL,
	GUARDIAN
}

## Movement modes (from enhanced system)
enum MovementMode {
	FREE_FLIGHT,
	ORBITING,
	CREATING,
	FOLLOWING,
	ASSISTING,
	HOVERING
}

## Assistance modes (from original system)
enum AssistanceMode {
	RAGDOLL_SUPPORT,
	OBJECT_MANIPULATION,
	SCENE_ORGANIZATION,
	ENVIRONMENTAL_HARMONY,
	CREATIVE_ASSISTANCE
}

# ================================
# PROPERTIES
# ================================

## Core properties
var being_id: int = 0
var being_name: String = ""
var personality: Personality = Personality.HELPFUL
var movement_mode: MovementMode = MovementMode.FREE_FLIGHT
var assistance_mode: AssistanceMode = AssistanceMode.RAGDOLL_SUPPORT

## Energy system (from original)
var energy_level: float = 100.0
var max_energy: float = 100.0
var energy_drain_rate: float = 0.5
var energy_regen_rate: float = 2.0

## Visual components
var light_point: OmniLight3D
var particles: GPUParticles3D
var glow_mesh: MeshInstance3D
var creation_particles: Array = []

## Movement and behavior
var hover_center: Vector3 = Vector3.ZERO
var hover_radius: float = 2.0
var hover_speed: float = 1.5
var phase_offset: float = 0.0
var movement_pattern: String = "circle"

## Advanced movement (from enhanced)
var orbit_target: Node3D = null
var orbit_radius: float = 5.0
var orbit_speed: float = 1.0
var orbit_angle: float = 0.0
var follow_target: Node3D = null
var assistance_target: Node3D = null

## Connection awareness (from enhanced)
var connected_objects: Array = []
var touching_objects: Array = []
var nearby_objects: Array = []
var area_detector: Area3D

## Blinking properties (from enhanced)
var blink_timer: float = 0.0
var blink_interval: float = randf_range(2.0, 5.0)
var blink_duration: float = 0.3
var is_blinking: bool = false
var base_energy: float = 2.0

## Creation mode properties
var infinity_timer: float = 0.0
var creation_scale: float = 2.0

## Communication
var vocabulary: Array = []
var recent_messages: Array = []
var last_speak_time: float = 0.0
var speak_cooldown: float = 5.0
var conversation_topics: Array = []

## Personality data
var personality_data = {
	Personality.HELPFUL: {
		"color": Color(0.5, 1.0, 0.5),  # Green
		"speed": 1.0,
		"vocab": ["I can help!", "Let me assist you", "What needs organizing?", "I see potential here"],
		"topics": ["organization", "improvement", "assistance"],
		"pattern": "circle",
		"assistance_preference": AssistanceMode.SCENE_ORGANIZATION
	},
	Personality.CURIOUS: {
		"color": Color(1.0, 0.8, 0.3),  # Yellow
		"speed": 2.0,
		"vocab": ["What's this?", "How fascinating!", "I wonder what happens if...", "Let's explore!"],
		"topics": ["discovery", "exploration", "questions"],
		"pattern": "figure8",
		"assistance_preference": AssistanceMode.CREATIVE_ASSISTANCE
	},
	Personality.WISE: {
		"color": Color(0.7, 0.5, 1.0),  # Purple
		"speed": 0.7,
		"vocab": ["Consider the balance", "All things connect", "Patience brings clarity", "The pattern emerges"],
		"topics": ["philosophy", "balance", "wisdom"],
		"pattern": "spiral",
		"assistance_preference": AssistanceMode.ENVIRONMENTAL_HARMONY
	},
	Personality.PLAYFUL: {
		"color": Color(1.0, 0.5, 0.8),  # Pink
		"speed": 3.0,
		"vocab": ["Wheee!", "This is fun!", "Let's play!", "Tag, you're it!"],
		"topics": ["games", "fun", "movement"],
		"pattern": "random",
		"assistance_preference": AssistanceMode.OBJECT_MANIPULATION
	},
	Personality.GUARDIAN: {
		"color": Color(0.3, 0.7, 1.0),  # Blue
		"speed": 1.5,
		"vocab": ["I'll protect this", "Standing watch", "All is well", "Safety first"],
		"topics": ["protection", "safety", "vigilance"],
		"pattern": "patrol",
		"assistance_preference": AssistanceMode.RAGDOLL_SUPPORT
	}
}

## References
var ragdoll_controller: Node = null
var floodgate: Node = null
var physics_state_manager: Node = null

# ================================
# INITIALIZATION
# ================================

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Add to astral beings group for console command discovery
	add_to_group("astral_beings")
	
	# Get system references
	ragdoll_controller = get_node_or_null("/root/RagdollController")
	floodgate = get_node_or_null("/root/FloodgateController")
	physics_state_manager = get_node_or_null("/root/PhysicsStateManager")
	
	# Create visual components
	_create_visual_components()
	
	# Set up detection area
	_create_detection_area()
	
	# Initialize properties
	phase_offset = randf() * TAU
	
	# Apply personality
	_apply_personality()
	
	# Connect to systems
	if ragdoll_controller:
		if ragdoll_controller.has_signal("player_needs_help"):
			ragdoll_controller.connect("player_needs_help", _on_player_needs_help)
			
	set_physics_process(true)

func _create_visual_components() -> void:
	# Light source
	light_point = OmniLight3D.new()
	light_point.name = "BeingLight"
	light_point.light_energy = base_energy
	light_point.omni_range = 10.0
	light_point.shadow_enabled = false
	add_child(light_point)
	
	# Particle system
	particles = GPUParticles3D.new()
	particles.name = "BeingParticles"
	particles.amount = 50
	particles.lifetime = 2.0
	particles.speed_scale = 0.5
	add_child(particles)
	
	# Particle material
	var process_mat = ParticleProcessMaterial.new()
	process_mat.direction = Vector3.ZERO
	process_mat.initial_velocity_min = 0.1
	process_mat.initial_velocity_max = 0.5
	process_mat.angular_velocity_min = -180.0
	process_mat.angular_velocity_max = 180.0
	process_mat.scale_min = 0.1
	process_mat.scale_max = 0.3
	particles.process_material = process_mat
	
	# Glow sphere
	glow_mesh = MeshInstance3D.new()
	glow_mesh.name = "BeingGlow"
	var sphere = SphereMesh.new()
	sphere.radius = 0.3
	sphere.height = 0.6
	glow_mesh.mesh = sphere
	
	# Glow material
	var glow_mat = MaterialLibrary.get_material("default")
	glow_mat.emission_enabled = true
	glow_mat.emission_energy = 1.0
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.albedo_color.a = 0.5
	glow_mesh.material_override = glow_mat
	add_child(glow_mesh)

func _create_detection_area() -> void:
	# Area for detecting nearby objects
	area_detector = Area3D.new()
	area_detector.name = "DetectionArea"
	add_child(area_detector)
	
	var collision = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 5.0
	collision.shape = sphere_shape
	FloodgateController.universal_add_child(collision, area_detector)
	
	# Connect signals
	area_detector.body_entered.connect(_on_body_entered)
	area_detector.body_exited.connect(_on_body_exited)

func _apply_personality() -> void:
	var data = personality_data.get(personality, {})
	
	# Apply visual properties
	var color = data.get("color", Color.WHITE)
	light_point.light_color = color
	if particles.process_material:
		particles.process_material.color = color
	if glow_mesh.material_override:
		glow_mesh.material_override.emission = color
		glow_mesh.material_override.albedo_color = Color(color.r, color.g, color.b, 0.5)
	
	# Apply behavior properties
	hover_speed = data.get("speed", 1.5)
	movement_pattern = data.get("pattern", "circle")
	vocabulary = data.get("vocab", [])
	conversation_topics = data.get("topics", [])
	assistance_mode = data.get("assistance_preference", AssistanceMode.RAGDOLL_SUPPORT)

# ================================
# PHYSICS PROCESS
# ================================


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	# Update energy
	_update_energy(delta)
	
	# Process movement based on mode
	match movement_mode:
		MovementMode.FREE_FLIGHT:
			_process_free_flight(delta)
		MovementMode.ORBITING:
			_process_orbiting(delta)
		MovementMode.CREATING:
			_process_creating(delta)
		MovementMode.FOLLOWING:
			_process_following(delta)
		MovementMode.ASSISTING:
			_process_assisting(delta)
		MovementMode.HOVERING:
			_process_hovering(delta)
	
	# Process blinking
	_process_blinking(delta)
	
	# Update connections
	_update_connection_awareness()
	
	# Process assistance
	_process_assistance(delta)
	
	# Consider speaking
	_consider_speaking(delta)

# ================================
# MOVEMENT BEHAVIORS
# ================================

func _process_free_flight(delta: float) -> void:
	# Move in pattern around hover center
	var time = Time.get_ticks_msec() / 1000.0
	var pattern_pos = _calculate_pattern_position(time)
	
	var target_pos = hover_center + pattern_pos
	global_position = global_position.lerp(target_pos, hover_speed * delta)
	
	# Occasionally switch to other modes
	if randf() < 0.01 * delta:
		var closest = _find_closest_object()
		if closest and global_position.distance_to(closest.global_position) < orbit_radius * 1.5:
			start_orbiting(closest)

func _process_orbiting(delta: float) -> void:
	if not orbit_target or not is_instance_valid(orbit_target):
		movement_mode = MovementMode.FREE_FLIGHT
		orbit_target = null
		return
	
	# Calculate orbit position
	orbit_angle += orbit_speed * delta
	var orbit_pos = orbit_target.global_position + Vector3(
		cos(orbit_angle) * orbit_radius,
		sin(orbit_angle * 0.5) * orbit_radius * 0.3,
		sin(orbit_angle) * orbit_radius
	)
	
	# Smooth movement
	global_position = global_position.lerp(orbit_pos, 5.0 * delta)
	
	# Face the orbited object
	if orbit_target.global_position != global_position:
		look_at(orbit_target.global_position, Vector3.UP)

func _process_creating(delta: float) -> void:
	# Infinity pattern creation
	infinity_timer += delta * 2.0
	
	var t = infinity_timer
	var x = creation_scale * sin(t) / (1 + cos(t) * cos(t))
	var y = creation_scale * sin(t) * cos(t) / (1 + cos(t) * cos(t))
	
	# Create light trails
	if creation_particles.size() < 20:
		var trail_light = _create_trail_light()
		trail_light.position = Vector3(x, y, 0)
		creation_particles.append(trail_light)
	
	# Update trail positions
	for i in range(creation_particles.size()):
		var particle = creation_particles[i]
		if is_instance_valid(particle):
			var offset = float(i) / creation_particles.size() * TAU
			var trail_t = t - offset * 0.1
			var trail_x = creation_scale * sin(trail_t) / (1 + cos(trail_t) * cos(trail_t))
			var trail_y = creation_scale * sin(trail_t) * cos(trail_t) / (1 + cos(trail_t) * cos(trail_t))
			particle.position = Vector3(trail_x, trail_y, 0)

func _process_following(delta: float) -> void:
	if not follow_target or not is_instance_valid(follow_target):
		movement_mode = MovementMode.FREE_FLIGHT
		follow_target = null
		return
	
	# Follow at a distance
	var target_pos = follow_target.global_position + Vector3(2, 3, 2)
	global_position = global_position.lerp(target_pos, 2.0 * delta)

func _process_assisting(delta: float) -> void:
	if not assistance_target:
		movement_mode = MovementMode.FREE_FLIGHT
		return
	
	# Move near assistance target
	var assist_pos = assistance_target.global_position + Vector3(0, 2, 0)
	global_position = global_position.lerp(assist_pos, 3.0 * delta)
	
	# Perform assistance based on mode
	_perform_assistance(delta)

func _process_hovering(_delta: float) -> void:
	# Simple hovering motion
	var time = Time.get_ticks_msec() / 1000.0
	var hover_offset = Vector3(0, sin(time * 2.0) * 0.5, 0)
	global_position = hover_center + hover_offset

# ================================
# ASSISTANCE BEHAVIORS
# ================================

func _process_assistance(delta: float) -> void:
	match assistance_mode:
		AssistanceMode.RAGDOLL_SUPPORT:
			_assist_ragdoll(delta)
		AssistanceMode.OBJECT_MANIPULATION:
			_assist_objects(delta)
		AssistanceMode.SCENE_ORGANIZATION:
			_organize_scene(delta)
		AssistanceMode.ENVIRONMENTAL_HARMONY:
			_harmonize_environment(delta)
		AssistanceMode.CREATIVE_ASSISTANCE:
			_assist_creation(delta)

func _assist_ragdoll(_delta: float) -> void:
	if not ragdoll_controller:
		return
		
	# Get ragdoll body and help stabilize
	var ragdoll_body = ragdoll_controller.get("ragdoll_body")
	if ragdoll_body and ragdoll_body.has_method("get_body"):
		var main_body = ragdoll_body.get_body()
		if main_body and energy_level > 10:
			# Apply gentle upward force if falling
			if main_body.linear_velocity.y < -5:
				main_body.apply_central_impulse(Vector3(0, 2, 0))
				energy_level -= 1.0

func _assist_objects(_delta: float) -> void:
	# Help move objects that are stuck or misplaced
	for obj in nearby_objects:
		if obj.has_method("get_linear_velocity") and energy_level > 5:
			var vel = obj.get_linear_velocity()
			if vel.length() < 0.1:  # Object is stuck
				obj.apply_central_impulse(Vector3(randf() - 0.5, 1, randf() - 0.5))
				energy_level -= 0.5

func _organize_scene(_delta: float) -> void:
	# Help organize objects by type or position
	pass

func _harmonize_environment(_delta: float) -> void:
	# Maintain environmental balance
	pass

func _assist_creation(_delta: float) -> void:
	# Help with creative tasks
	if movement_mode != MovementMode.CREATING and randf() < 0.01:
		movement_mode = MovementMode.CREATING

# ================================
# UTILITY FUNCTIONS
# ================================

func _calculate_pattern_position(time: float) -> Vector3:
	match movement_pattern:
		"circle":
			return Vector3(
				cos(time * hover_speed + phase_offset) * hover_radius,
				sin(time * 2.0) * 0.5,
				sin(time * hover_speed + phase_offset) * hover_radius
			)
		"figure8":
			var t = time * hover_speed + phase_offset
			return Vector3(
				sin(t) * hover_radius,
				sin(t * 2.0) * 0.5,
				sin(t * 2.0) * hover_radius * 0.5
			)
		"spiral":
			var t = time * hover_speed + phase_offset
			var r = hover_radius * (1.0 + sin(t * 0.3) * 0.3)
			return Vector3(
				cos(t) * r,
				sin(t * 2.0) * 0.5 + t * 0.01,
				sin(t) * r
			)
		"random":
			if randf() < 0.05:
				phase_offset = randf() * TAU
			return Vector3(
				cos(phase_offset) * hover_radius,
				sin(time * 2.0) * 0.5,
				sin(phase_offset) * hover_radius
			)
		"patrol":
			var t = time * hover_speed * 0.5
			var segment = int(t) % 4
			var progress = fmod(t, 1.0)
			
			var points = [
				Vector3(-hover_radius, 0, -hover_radius),
				Vector3(hover_radius, 0, -hover_radius),
				Vector3(hover_radius, 0, hover_radius),
				Vector3(-hover_radius, 0, hover_radius)
			]
			
			var from = points[segment]
			var to = points[(segment + 1) % 4]
			return from.lerp(to, progress) + Vector3(0, sin(time * 2.0) * 0.5, 0)
		_:
			return Vector3.ZERO

func _process_blinking(delta: float) -> void:
	blink_timer += delta
	
	if blink_timer >= blink_interval:
		is_blinking = true
		blink_timer = 0.0
		blink_interval = randf_range(2.0, 5.0)
	
	if is_blinking:
		var blink_progress = (blink_timer / blink_duration)
		if blink_progress < 0.5:
			light_point.light_energy = base_energy * (1.0 - blink_progress * 2.0)
		else:
			light_point.light_energy = base_energy * ((blink_progress - 0.5) * 2.0)
		
		if blink_timer >= blink_duration:
			is_blinking = false
			light_point.light_energy = base_energy

func _update_connection_awareness() -> void:
	# Update visual feedback based on connections
	if connected_objects.size() > 0:
		base_energy = 3.0  # Brighter when connected
	else:
		base_energy = 2.0  # Normal brightness

func _update_energy(delta: float) -> void:
	# Drain energy when active, regenerate when idle
	if movement_mode == MovementMode.ASSISTING or movement_mode == MovementMode.CREATING:
		energy_level = max(0, energy_level - energy_drain_rate * delta)
	else:
		energy_level = min(max_energy, energy_level + energy_regen_rate * delta)

func _consider_speaking(delta: float) -> void:
	last_speak_time += delta
	
	if last_speak_time > speak_cooldown:
		# Check for conversation triggers
		if nearby_objects.size() > 0 and randf() < 0.1:
			speak(vocabulary[randi() % vocabulary.size()])
		elif connected_objects.size() > 0 and randf() < 0.2:
			speak("We are connected!")

func _create_trail_light() -> Node3D:
	var trail = Node3D.new()
	add_child(trail)
	
	var trail_light = OmniLight3D.new()
	trail_light.light_color = light_point.light_color
	trail_light.light_energy = 0.5
	trail_light.omni_range = 2.0
	FloodgateController.universal_add_child(trail_light, trail)
	
	return trail

func _find_closest_object() -> Node3D:
	var closest: Node3D = null
	var min_dist = INF
	
	for obj in nearby_objects:
		var dist = global_position.distance_to(obj.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = obj
	
	return closest

func _perform_assistance(_delta: float) -> void:
	if not assistance_target:
		return
		
	# Apply assistance effects
	if assistance_target.has_method("receive_assistance"):
		assistance_target.receive_assistance(self, assistance_mode)
		energy_level -= 0.1

# ================================
# PUBLIC METHODS
# ================================


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

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
func set_personality(new_personality: Personality) -> void:
	personality = new_personality
	_apply_personality()

func start_orbiting(target: Node3D) -> void:
	orbit_target = target
	movement_mode = MovementMode.ORBITING
	orbit_angle = 0.0
	speak("I'll orbit around this!")

func start_following(target: Node3D) -> void:
	follow_target = target
	movement_mode = MovementMode.FOLLOWING
	speak("I'll follow you!")

func start_assisting(target: Node3D, mode: AssistanceMode) -> void:
	assistance_target = target
	assistance_mode = mode
	movement_mode = MovementMode.ASSISTING
	speak("Let me help!")

func speak(message: String) -> void:
	if last_speak_time < speak_cooldown:
		return
		
	recent_messages.append(message)
	if recent_messages.size() > 5:
		recent_messages.pop_front()
	
	last_speak_time = 0.0
	being_spoke.emit(self, message)
	
	# Visual feedback
	is_blinking = true
	blink_timer = 0.0

func request_help_with(object: Node3D, help_type: String) -> void:
	being_action_taken.emit(self, help_type, object)
	
	match help_type:
		"move":
			start_assisting(object, AssistanceMode.OBJECT_MANIPULATION)
		"organize":
			start_assisting(object, AssistanceMode.SCENE_ORGANIZATION)
		"support":
			start_assisting(object, AssistanceMode.RAGDOLL_SUPPORT)

# ================================
# SIGNAL HANDLERS
# ================================

func _on_body_entered(body: Node3D) -> void:
	if not body in nearby_objects:
		nearby_objects.append(body)
		
		# Check if it's something we should connect with
		if body.is_in_group("connectable") or body.has_method("connect_to_being"):
			connected_objects.append(body)
			connection_made.emit(self, body)

func _on_body_exited(body: Node3D) -> void:
	nearby_objects.erase(body)
	connected_objects.erase(body)
	touching_objects.erase(body)

func _on_player_needs_help() -> void:
	if ragdoll_controller and energy_level > 50:
		start_assisting(ragdoll_controller.get("ragdoll_body"), AssistanceMode.RAGDOLL_SUPPORT)

# ================================
# CONSOLE COMMAND INTERFACE
# ================================

func handle_console_command(command: String, args: Array) -> String:
	match command:
		"follow":
			if args.size() > 0:
				var target_name = args[0]
				var target = get_tree().get_first_node_in_group(target_name)
				if target:
					set_follow_target(target)
					return "Astral being " + being_name + " now following " + target_name
				else:
					return "Could not find target: " + target_name
			else:
				return "Usage: follow <target_name>"
		
		"orbit":
			if args.size() > 0:
				var target_name = args[0]
				var target = get_tree().get_first_node_in_group(target_name)
				if target:
					set_orbit_target(target)
					return "Astral being " + being_name + " now orbiting " + target_name
				else:
					return "Could not find target: " + target_name
			else:
				return "Usage: orbit <target_name>"
		
		"move":
			if args.size() >= 3:
				var pos = Vector3(float(args[0]), float(args[1]), float(args[2]))
				set_hover_center(pos)
				return "Astral being " + being_name + " moving to " + str(pos)
			else:
				return "Usage: move <x> <y> <z>"
		
		"mode":
			if args.size() > 0:
				var mode_name = args[0].to_upper()
				match mode_name:
					"FREE_FLIGHT":
						set_movement_mode(MovementMode.FREE_FLIGHT)
						return "Astral being " + being_name + " set to free flight mode"
					"ORBITING":
						set_movement_mode(MovementMode.ORBITING)
						return "Astral being " + being_name + " set to orbiting mode"
					"FOLLOWING":
						set_movement_mode(MovementMode.FOLLOWING)
						return "Astral being " + being_name + " set to following mode"
					"HOVERING":
						set_movement_mode(MovementMode.HOVERING)
						return "Astral being " + being_name + " set to hovering mode"
					"CREATING":
						set_movement_mode(MovementMode.CREATING)
						return "Astral being " + being_name + " set to creating mode"
					"ASSISTING":
						set_movement_mode(MovementMode.ASSISTING)
						return "Astral being " + being_name + " set to assisting mode"
					_:
						return "Invalid mode. Options: FREE_FLIGHT, ORBITING, FOLLOWING, HOVERING, CREATING, ASSISTING"
			else:
				return "Usage: mode <mode_name>"
		
		"assist":
			if args.size() > 0:
				var assist_mode = args[0].to_upper()
				match assist_mode:
					"RAGDOLL":
						set_assistance_mode(AssistanceMode.RAGDOLL_SUPPORT)
						return "Astral being " + being_name + " set to ragdoll support"
					"OBJECTS":
						set_assistance_mode(AssistanceMode.OBJECT_MANIPULATION)
						return "Astral being " + being_name + " set to object manipulation"
					"ORGANIZE":
						set_assistance_mode(AssistanceMode.SCENE_ORGANIZATION)
						return "Astral being " + being_name + " set to scene organization"
					"HARMONY":
						set_assistance_mode(AssistanceMode.ENVIRONMENTAL_HARMONY)
						return "Astral being " + being_name + " set to environmental harmony"
					"CREATIVE":
						set_assistance_mode(AssistanceMode.CREATIVE_ASSISTANCE)
						return "Astral being " + being_name + " set to creative assistance"
					_:
						return "Invalid assist mode. Options: RAGDOLL, OBJECTS, ORGANIZE, HARMONY, CREATIVE"
			else:
				return "Usage: assist <mode>"
		
		"speak":
			if args.size() > 0:
				var message = " ".join(args)
				speak(message)
				return "Astral being " + being_name + " says: " + message
			else:
				return "Usage: speak <message>"
		
		"energy":
			if args.size() > 0:
				var new_energy = float(args[0])
				energy_level = clamp(new_energy, 0.0, max_energy)
				return "Astral being " + being_name + " energy set to " + str(energy_level)
			else:
				return "Astral being " + being_name + " energy: " + str(energy_level) + "/" + str(max_energy)
		
		"personality":
			if args.size() > 0:
				var pers_name = args[0].to_upper()
				match pers_name:
					"HELPFUL":
						personality = Personality.HELPFUL
						return "Astral being " + being_name + " personality set to helpful"
					"CURIOUS":
						personality = Personality.CURIOUS
						return "Astral being " + being_name + " personality set to curious"
					"WISE":
						personality = Personality.WISE
						return "Astral being " + being_name + " personality set to wise"
					"PLAYFUL":
						personality = Personality.PLAYFUL
						return "Astral being " + being_name + " personality set to playful"
					"GUARDIAN":
						personality = Personality.GUARDIAN
						return "Astral being " + being_name + " personality set to guardian"
					_:
						return "Invalid personality. Options: HELPFUL, CURIOUS, WISE, PLAYFUL, GUARDIAN"
			else:
				var current_pers = ["HELPFUL", "CURIOUS", "WISE", "PLAYFUL", "GUARDIAN"][personality]
				return "Astral being " + being_name + " personality: " + current_pers
		
		"status":
			var status_info = get_being_status()
			return "Astral being " + being_name + " status: " + str(status_info)
		
		"reset":
			global_position = Vector3(0, 5, 0)
			energy_level = max_energy
			set_movement_mode(MovementMode.FREE_FLIGHT)
			return "Astral being " + being_name + " reset to default state"
		
		_:
			return "Unknown astral being command: " + command + ". Available: follow, orbit, move, mode, assist, speak, energy, personality, status, reset"

func get_being_status() -> Dictionary:
	return {
		"id": being_id,
		"name": being_name,
		"position": global_position,
		"energy": str(energy_level) + "/" + str(max_energy),
		"personality": ["HELPFUL", "CURIOUS", "WISE", "PLAYFUL", "GUARDIAN"][personality],
		"movement_mode": ["FREE_FLIGHT", "ORBITING", "CREATING", "FOLLOWING", "ASSISTING", "HOVERING"][movement_mode],
		"assistance_mode": ["RAGDOLL_SUPPORT", "OBJECT_MANIPULATION", "SCENE_ORGANIZATION", "ENVIRONMENTAL_HARMONY", "CREATIVE_ASSISTANCE"][assistance_mode],
		"connected_objects": connected_objects.size(),
		"nearby_objects": nearby_objects.size()
	}

# Missing movement control functions
func set_follow_target(target: Node3D) -> void:
	"""Set target to follow"""
	follow_target = target
	movement_mode = MovementMode.FOLLOWING
	
func set_orbit_target(target: Node3D) -> void:
	"""Set target to orbit around"""
	orbit_target = target
	movement_mode = MovementMode.ORBITING
	
func set_hover_center(center_position: Vector3) -> void:
	"""Set hover position"""
	hover_center = center_position
	movement_mode = MovementMode.HOVERING
	
func set_movement_mode(mode: MovementMode) -> void:
	"""Change movement mode"""
	movement_mode = mode
	
func set_assistance_mode(mode: AssistanceMode) -> void:
	"""Change assistance mode"""
	assistance_mode = mode