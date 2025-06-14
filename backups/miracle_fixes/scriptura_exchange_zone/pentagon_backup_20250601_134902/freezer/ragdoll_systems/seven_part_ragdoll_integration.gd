# ==================================================
# SCRIPT NAME: seven_part_ragdoll_integration.gd
# DESCRIPTION: Integrates 7-part ragdoll from ProceduralWalk project
# PURPOSE: Connect proper walking ragdoll to JSH framework and floodgate system
# CREATED: 2025-05-25 - Ragdoll domino effect fix
# ==================================================

extends UniversalBeingBase
# 7-Part Ragdoll Components (based on ProceduralWalk structure)
var spine_bones = []
var leg_bones = []
var foot_bones = []

# Walking System
var walk_speed: float = 2.0
var step_height: float = 0.3
var step_distance: float = 0.8
var is_walking: bool = false
var target_position: Vector3 = Vector3.ZERO
var walker: Node3D = null
var is_being_dragged: bool = false

# Enhanced Navigation System
var waypoint_queue: Array[Vector3] = []
var patrol_mode: bool = false
var patrol_points: Array[Vector3] = []
var current_patrol_index: int = 0
var avoidance_enabled: bool = true
var navigation_precision: float = 0.5

# Integration with Talking Ragdoll
var dialogue_system: Node = null
var current_speech: String = ""
var speech_timer: float = 0.0

# Dialogue lines
const IDLE_DIALOGUE = [
	"Oh hey there! Nice day for being a ragdoll, isn't it?",
	"You know, I used to have bones... I miss bones.",
	"These joints are amazing! I feel so articulated!",
	"Seven parts, perfectly balanced, as all things should be.",
	"I can feel the physics flowing through my joints!",
	"Is this what evolution feels like? From simple to complex?"
]

const WALKING_DIALOGUE = [
	"Left foot, right foot, left foot, right foot...",
	"Look at me go! I'm practically dancing!",
	"Who needs balance when you have physics joints?",
	"My hip joints are really doing the work here!",
	"This is way better than my old single-body design!"
]

const FALLING_DIALOGUE = [
	"Whoa! Gravity is not my friend!",
	"I regret nothing! This is living!",
	"See you at the bottom!",
	"Physics! Why have you betrayed me?",
	"I meant to do that!"
]

const DRAGGED_DIALOGUE = [
	"Hey! I can walk on my own, you know!",
	"This is undignified! I have legs!",
	"Are we going somewhere fun at least?",
	"I feel like a marionette!",
	"My joints weren't designed for this!"
]

# JSH Framework Connection
var jsh_registered: bool = false
var ragdoll_id: String = ""

# Floodgate Integration
signal ragdoll_state_changed(new_state: String)
signal ragdoll_position_updated(position: Vector3)
signal ragdoll_dialogue_started(text: String)

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🤖 [SevenPartRagdoll] Initializing 7-part walking ragdoll...")
	
	# Add to ragdoll group for controller detection
	add_to_group("ragdolls")
	
	# Set up basic ragdoll structure
	_setup_seven_part_body()
	
	# Add upright controller
	_setup_enhanced_walker()
	
	# Connect to systems
	_connect_to_jsh_framework()
	_connect_to_floodgate()
	_setup_dialogue_system()
	
	# Generate unique ragdoll ID
	ragdoll_id = "ragdoll_7part_" + str(Time.get_unix_time_from_system())
	
	# Start standing!
	await get_tree().create_timer(0.5).timeout  # Give physics time to settle
	if has_node("SimpleWalker"):
		$SimpleWalker.stand_up()
	
	print("✅ [SevenPartRagdoll] Ready - 7-part ragdoll operational!")

func _setup_seven_part_body() -> void:
	# Create the 7 main body parts for lower body in proper positions
	var body_structure = {
		"pelvis": {"pos": Vector3(0, 1.0, 0), "parent": null},  # Start at 1m height
		"left_thigh": {"pos": Vector3(-0.1, -0.1, 0), "parent": "pelvis"},
		"right_thigh": {"pos": Vector3(0.1, -0.1, 0), "parent": "pelvis"},
		"left_shin": {"pos": Vector3(0, -0.4, 0), "parent": "left_thigh"},
		"right_shin": {"pos": Vector3(0, -0.4, 0), "parent": "right_thigh"},
		"left_foot": {"pos": Vector3(0, -0.35, 0.05), "parent": "left_shin"},
		"right_foot": {"pos": Vector3(0, -0.35, 0.05), "parent": "right_shin"}
	}
	
	var created_parts = {}
	
	# Create parts in hierarchy
	for part_name in body_structure:
		var part_info = body_structure[part_name]
		var part = _create_body_part(part_name)
		
		if part:
			# Calculate absolute position based on parent positions
			var absolute_pos = part_info.pos
			if part_info.parent and created_parts.has(part_info.parent):
				# Add parent's position to get absolute position
				absolute_pos = created_parts[part_info.parent].position + part_info.pos
			
			# Set absolute position
			part.position = absolute_pos
			
			# Always add to root (not as child of other RigidBody3D)
			add_child(part)
			
			created_parts[part_name] = part
			
			# Categorize parts
			if "thigh" in part_name or "shin" in part_name:
				leg_bones.append(part)
			elif "foot" in part_name:
				foot_bones.append(part)
			else:
				spine_bones.append(part)
	
	# Add joints between connected parts
	_create_joints(created_parts)
	
	# Store parts for walker access
	set_meta("body_parts", created_parts)

func _setup_enhanced_walker() -> void:
	# Try enhanced walker first
	var enhanced_script = load("res://scripts/core/enhanced_ragdoll_walker.gd")
	if enhanced_script:
		walker = Node3D.new()
		walker.name = "EnhancedWalker"
		walker.set_script(enhanced_script)
		add_child(walker)
		print("🏃 [SevenPartRagdoll] Enhanced walker controller added")
	else:
		# Fallback to simple walker
		var simple_script = load("res://scripts/core/simple_ragdoll_walker.gd")
		if simple_script:
			walker = Node3D.new()
			walker.name = "SimpleWalker"
			walker.set_script(simple_script)
			add_child(walker)
			print("🚶 [SevenPartRagdoll] Simple walker controller added (fallback)")
		else:
			print("❌ [SevenPartRagdoll] Failed to load any walker script!")

func _create_body_part(part_name: String) -> Node3D:
	var part = RigidBody3D.new()
	part.name = part_name
	
	# Create collision shape
	var collision = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	
	# Set size based on body part
	match part_name:
		"pelvis":
			# Use box for pelvis instead of capsule
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(0.4, 0.2, 0.2)
			collision.shape = box_shape
			shape = null  # Don't use capsule
		"left_thigh", "right_thigh":
			shape.radius = 0.08
			shape.height = 0.4
		"left_shin", "right_shin":
			shape.radius = 0.06
			shape.height = 0.35
		"left_foot", "right_foot":
			# Use box for feet
			var box_shape = BoxShape3D.new()
			box_shape.size = Vector3(0.08, 0.05, 0.15)
			collision.shape = box_shape
			shape = null  # Don't use capsule
	
	# Only set capsule shape if we're using it
	if shape != null and collision.shape == null:
		collision.shape = shape
	FloodgateController.universal_add_child(collision, part)
	
	# Create visual mesh matching collision shape
	var mesh_instance = MeshInstance3D.new()
	
	if collision.shape is BoxShape3D:
		var box_mesh = BoxMesh.new()
		box_mesh.size = collision.shape.size
		mesh_instance.mesh = box_mesh
	elif collision.shape is CapsuleShape3D:
		var capsule_mesh = CapsuleMesh.new()
		capsule_mesh.radius = collision.shape.radius
		capsule_mesh.height = collision.shape.height
		mesh_instance.mesh = capsule_mesh
	
	# Color based on part
	var material = MaterialLibrary.get_material("default")
	if "thigh" in part_name:
		material.albedo_color = Color.BROWN
	elif "shin" in part_name:
		material.albedo_color = Color.SANDY_BROWN
	elif "foot" in part_name:
		material.albedo_color = Color.DARK_GRAY
	else:
		material.albedo_color = Color.BURLYWOOD
	
	mesh_instance.material_override = material
	FloodgateController.universal_add_child(mesh_instance, part)
	
	# Set physics properties
	part.mass = 1.0  # 1kg per body part (lighter)
	part.gravity_scale = 1.0
	part.linear_damp = 1.0  # More damping to prevent explosions
	part.angular_damp = 3.0  # Even more angular damping
	# Note: max_linear_velocity and max_angular_velocity removed (not in Godot 4)
	# We'll use damping to control speeds instead
	
	return part

# Create physics joints between body parts (Fixed for proper anatomy)
func _create_joints(parts: Dictionary) -> void:
	# Hip joints (pelvis to thighs) - Allow rotation but limit
	_create_hip_joint(parts, "pelvis", "left_thigh")
	_create_hip_joint(parts, "pelvis", "right_thigh")
	
	# Knee joints (thighs to shins) - Hinge with realistic limits
	_create_knee_joint(parts, "left_thigh", "left_shin")
	_create_knee_joint(parts, "right_thigh", "right_shin")
	
	# Ankle joints (shins to feet) - Limited rotation
	_create_ankle_joint(parts, "left_shin", "left_foot")
	_create_ankle_joint(parts, "right_shin", "right_foot")

func _create_hip_joint(parts: Dictionary, parent_name: String, child_name: String) -> void:
	if parts.has(parent_name) and parts.has(child_name):
		var joint = Generic6DOFJoint3D.new()
		joint.name = parent_name + "_to_" + child_name
		
		# Add joint to scene first
		add_child(joint)
		
		# Position joint at connection point (bottom of pelvis, top of thigh)
		var parent_part = parts[parent_name] as RigidBody3D
		var child_part = parts[child_name] as RigidBody3D
		joint.global_position = parent_part.global_position + Vector3(0, -0.1, 0)
		
		# Set bodies using proper node references AFTER adding to scene
		joint.node_a = parent_part.get_path()
		joint.node_b = child_part.get_path()
		
		# Realistic hip movement limits (Godot 4 API)
		# X axis (forward/backward rotation)
		joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
		joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -PI/4)  # -45 degrees
		joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, PI/4)   # +45 degrees
		joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_DAMPING, 1.0)
		joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LIMIT_SOFTNESS, 0.3)
		
		# Y axis (side rotation)
		joint.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
		joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -PI/6)  # -30 degrees
		joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, PI/6)   # +30 degrees
		
		# Z axis (twist) - limited
		joint.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
		joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -PI/8)  # -22.5 degrees
		joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, PI/8)   # +22.5 degrees

func _create_knee_joint(parts: Dictionary, parent_name: String, child_name: String) -> void:
	if parts.has(parent_name) and parts.has(child_name):
		var joint = HingeJoint3D.new()
		joint.name = parent_name + "_to_" + child_name
		
		# Add joint to scene first
		add_child(joint)
		
		# Position joint at connection point (bottom of thigh, top of shin)
		var parent_part = parts[parent_name] as RigidBody3D
		var child_part = parts[child_name] as RigidBody3D
		joint.global_position = parent_part.global_position + Vector3(0, -0.2, 0)
		
		# Set bodies using proper node references AFTER adding to scene
		joint.node_a = parent_part.get_path()
		joint.node_b = child_part.get_path()
		
		# Realistic knee limits (no backward bend, 90° forward)
		joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 0.0)
		joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, -PI/2)
		joint.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)

func _create_ankle_joint(parts: Dictionary, parent_name: String, child_name: String) -> void:
	if parts.has(parent_name) and parts.has(child_name):
		var joint = HingeJoint3D.new()
		joint.name = parent_name + "_to_" + child_name
		
		# Add joint to scene first
		add_child(joint)
		
		# Position joint at connection point (bottom of shin, top of foot)
		var parent_part = parts[parent_name] as RigidBody3D
		var child_part = parts[child_name] as RigidBody3D
		joint.global_position = parent_part.global_position + Vector3(0, -0.175, 0)
		
		# Set bodies using proper node references AFTER adding to scene
		joint.node_a = parent_part.get_path()
		joint.node_b = child_part.get_path()
		
		# Realistic ankle limits (30° up, 45° down)
		joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, PI/6)
		joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, -PI/4)
		joint.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)

func _connect_to_jsh_framework() -> void:
	# Connect to main game controller's JSH system
	var main_controller = get_node_or_null("/root/main") 
	if not main_controller:
		main_controller = get_tree().current_scene
	
	if main_controller and main_controller.has_method("_on_jsh_branch_added"):
		# Register this ragdoll with JSH system
		var _ragdoll_data = {
			"type": "seven_part_ragdoll",
			"position": global_position,
			"state": "idle",
			"walking": false,
			"dialogue": ""
		}
		
		# This would trigger the JSH branch addition
		print("📡 [SevenPartRagdoll] Registering with JSH Framework...")
		jsh_registered = true

func _connect_to_floodgate() -> void:
	# Connect to FloodgateController
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate:
		print("🌊 [SevenPartRagdoll] Connected to Floodgate system")
		
		# Connect ragdoll signals to floodgate synchronization
		ragdoll_state_changed.connect(_on_ragdoll_state_changed)
		ragdoll_position_updated.connect(_on_ragdoll_position_updated)
		
		# Initial position sync
		floodgate.queue_ragdoll_position_update(ragdoll_id, global_position, "initializing")
		print("🌊 [SevenPartRagdoll] Ragdoll tracking integrated with floodgate")
	else:
		print("❌ [SevenPartRagdoll] No Floodgate system found")

func _setup_dialogue_system() -> void:
	# Setup speech system
	var _speech_phrases = [
		"Look at me go! I'm practically running!",
		"I think I'm getting the hang of this walking thing!",
		"These legs are new! Still getting used to them.",
		"Walking is harder than it looks, you know?",
		"Oh hey there! Nice day for being a ragdoll, isn't it?",
		"You know, I used to have bones... I miss bones."
	]
	
	# Start random dialogue timer
	var timer = TimerManager.get_timer()
	timer.wait_time = randf_range(8.0, 15.0)
	timer.timeout.connect(_speak_random_phrase)
	timer.autostart = true
	add_child(timer)

func _speak_random_phrase() -> void:
	var phrases = [
		"Look at me go! I'm practically running!",
		"I think I'm getting the hang of this walking thing!",
		"These legs are new! Still getting used to them.",
		"Walking is harder than it looks, you know?",
		"Oh hey there! Nice day for being a ragdoll, isn't it?",
		"You know, I used to have bones... I miss bones."
	]
	
	current_speech = phrases[randi() % phrases.size()]
	speech_timer = 3.0
	
	print("Ragdoll says: " + current_speech)
	ragdoll_dialogue_started.emit(current_speech)


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	# Handle speech timer
	if speech_timer > 0:
		speech_timer -= delta
	
	# Update dialogue system
	_update_dialogue(delta)
	
	# Handle walking movement
	if is_walking and target_position != Vector3.ZERO:
		_process_walking_movement(delta)

func _process_walking_movement(_delta: float) -> void:
	# Check if we need to process waypoint queue
	if not waypoint_queue.is_empty() and target_position == Vector3.ZERO:
		target_position = waypoint_queue.pop_front()
		print("🗺️ [SevenPartRagdoll] Next waypoint: " + str(target_position))
	
	# Check patrol mode
	if patrol_mode and not is_walking and waypoint_queue.is_empty():
		_next_patrol_point()
	
	# Calculate movement direction with obstacle avoidance
	var direction = _calculate_movement_direction()
	
	# Use simple walker for walking
	if has_node("SimpleWalker"):
		if direction.length() > 0.1:
			$SimpleWalker.start_walking(direction)
		else:
			$SimpleWalker.stop_walking()
		
		# Check if reached target based on pelvis position
		var pelvis = get_meta("body_parts", {}).get("pelvis")
		if pelvis and pelvis.global_position.distance_to(target_position) < navigation_precision:
			print("🚶 [SevenPartRagdoll] Reached target position")
			_handle_target_reached()
	else:
		print("❌ [SevenPartRagdoll] No SimpleWalker found!")

# Public API for ragdoll controller

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
func come_to_position(pos: Vector3) -> void:
	target_position = pos
	is_walking = true
	ragdoll_state_changed.emit("walking")
	print("🚶 [SevenPartRagdoll] Walking to position: " + str(pos))

func stop_walking() -> void:
	"""Stop walking mode"""
	is_walking = false
	target_position = Vector3.ZERO
	waypoint_queue.clear()
	
	# Stop simple walker
	if has_node("SimpleWalker"):
		$SimpleWalker.stop_walking()
	
	say("Stopping for a rest...")
	ragdoll_state_changed.emit("idle")

func pick_up_nearest_object() -> void:
	print("🤏 [SevenPartRagdoll] Looking for objects to pick up...")
	
	# Find nearest objects
	var bodies = get_tree().get_nodes_in_group("spawned_objects")
	var nearest_object = null
	var nearest_distance = 999.0
	
	for body in bodies:
		if body is RigidBody3D:
			var distance = global_position.distance_to(body.global_position)
			if distance < nearest_distance and distance < 3.0:
				nearest_distance = distance
				nearest_object = body
	
	if nearest_object:
		print("🤏 [SevenPartRagdoll] Picking up: " + nearest_object.name)
		# Simple pickup - move object to ragdoll
		nearest_object.global_position = global_position + Vector3(0, 1, 0)
		ragdoll_state_changed.emit("carrying")
	else:
		print("❌ [SevenPartRagdoll] No objects in range to pick up")

func organize_nearby_objects() -> void:
	print("📦 [SevenPartRagdoll] Organizing objects...")
	
	var objects = get_tree().get_nodes_in_group("spawned_objects")
	var organize_position = global_position + Vector3(2, 0, 0)
	
	for i in range(min(5, objects.size())):
		if objects[i] is RigidBody3D:
			var offset = Vector3(i * 0.5, 0, 0)
			objects[i].global_position = organize_position + offset
	
	ragdoll_state_changed.emit("organizing")
	print("✅ [SevenPartRagdoll] Objects organized!")

func reset_position() -> void:
	# Reset pelvis position (the root of our ragdoll)
	var pelvis = get_meta("body_parts", {}).get("pelvis")
	if pelvis:
		pelvis.global_position = Vector3(0, 1.5, 0)
		pelvis.linear_velocity = Vector3.ZERO
		pelvis.angular_velocity = Vector3.ZERO
	
	global_position = Vector3(0, 0, 0)
	stop_walking()
	
	# Stand up properly
	if has_node("SimpleWalker"):
		$SimpleWalker.stand_up()
	
	ragdoll_position_updated.emit(global_position)
	print("🔄 [SevenPartRagdoll] Position reset to origin")

func say_text(text: String) -> void:
	current_speech = text
	speech_timer = 3.0
	print("Ragdoll says: " + text)
	ragdoll_dialogue_started.emit(text)

# Integration helper functions
func get_ragdoll_status() -> Dictionary:
	return {
		"id": ragdoll_id,
		"position": global_position,
		"walking": is_walking,
		"target": target_position,
		"speech": current_speech,
		"jsh_registered": jsh_registered
	}

# Enhanced Navigation Functions
func _calculate_movement_direction() -> Vector3:
	var direction = (target_position - global_position).normalized()
	
	# Add obstacle avoidance if enabled
	if avoidance_enabled:
		direction = _apply_obstacle_avoidance(direction)
	
	return direction

func _apply_obstacle_avoidance(base_direction: Vector3) -> Vector3:
	# Simple obstacle avoidance using raycasting
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 0.5, 0),
		global_position + base_direction * 2.0 + Vector3(0, 0.5, 0)
	)
	
	var result = space_state.intersect_ray(query)
	if result:
		# Obstacle detected, try to go around it
		var avoid_direction = Vector3(base_direction.z, 0, -base_direction.x)  # Perpendicular
		return (base_direction + avoid_direction * 0.5).normalized()
	
	return base_direction

func _handle_target_reached() -> void:
	# Check for next waypoint
	if not waypoint_queue.is_empty():
		target_position = waypoint_queue.pop_front()
		print("🗺️ [SevenPartRagdoll] Moving to next waypoint: " + str(target_position))
	elif patrol_mode:
		# Continue patrol
		_next_patrol_point()
	else:
		# Stop walking
		stop_walking()

func _next_patrol_point() -> void:
	if patrol_points.size() > 0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		target_position = patrol_points[current_patrol_index]
		is_walking = true
		ragdoll_state_changed.emit("patrolling")
		print("🚁 [SevenPartRagdoll] Patrol to: " + str(target_position))

# Public Navigation API
func add_waypoint(waypoint: Vector3) -> void:
	waypoint_queue.append(waypoint)
	if not is_walking:
		is_walking = true
		ragdoll_state_changed.emit("navigating")
	print("🗺️ [SevenPartRagdoll] Waypoint added: " + str(waypoint))

func clear_waypoints() -> void:
	waypoint_queue.clear()
	print("🗺️ [SevenPartRagdoll] All waypoints cleared")

func start_patrol(points: Array[Vector3]) -> void:
	patrol_points = points
	patrol_mode = true
	current_patrol_index = 0
	if patrol_points.size() > 0:
		come_to_position(patrol_points[0])
	print("🚁 [SevenPartRagdoll] Patrol started with " + str(points.size()) + " points")

func stop_patrol() -> void:
	patrol_mode = false
	patrol_points.clear()
	stop_walking()
	print("🚁 [SevenPartRagdoll] Patrol stopped")

# Floodgate Integration Signal Handlers
func _on_ragdoll_state_changed(new_state: String) -> void:
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate:
		floodgate.queue_ragdoll_position_update(ragdoll_id, global_position, new_state)

func _on_ragdoll_position_updated(pos: Vector3) -> void:
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate:
		var current_state = "idle"
		if is_walking:
			current_state = "walking"
		if patrol_mode:
			current_state = "patrolling"
		floodgate.queue_ragdoll_position_update(ragdoll_id, pos, current_state)

func handle_console_command(command: String, args: Array) -> String:
	match command:
		"come":
			if args.size() >= 3:
				var pos = Vector3(float(args[0]), float(args[1]), float(args[2]))
				come_to_position(pos)
				return "Ragdoll coming to position: " + str(pos)
			else:
				return "Usage: come <x> <y> <z>"
		
		"waypoint":
			if args.size() >= 3:
				var pos = Vector3(float(args[0]), float(args[1]), float(args[2]))
				add_waypoint(pos)
				return "Waypoint added: " + str(pos)
			else:
				return "Usage: waypoint <x> <y> <z>"
		
		"patrol":
			if args.size() == 1 and args[0] == "stop":
				stop_patrol()
				return "Patrol stopped"
			elif args.size() >= 6:  # At least 2 points (x,y,z each)
				var points: Array[Vector3] = []
				for i in range(0, args.size(), 3):
					if i + 2 < args.size():
						points.append(Vector3(float(args[i]), float(args[i+1]), float(args[i+2])))
				start_patrol(points)
				return "Patrol started with " + str(points.size()) + " points"
			else:
				return "Usage: patrol <x1> <y1> <z1> <x2> <y2> <z2> ... or patrol stop"
		
		"pickup":
			pick_up_nearest_object()
			return "Ragdoll looking for objects to pick up"
		
		"organize":
			organize_nearby_objects()
			return "Ragdoll organizing nearby objects"
		
		"reset":
			reset_position()
			return "Ragdoll position reset"
		
		"say":
			if args.size() > 0:
				var text = " ".join(args)
				say_text(text)
				return "Ragdoll saying: " + text
			else:
				return "Usage: say <text>"
		
		"status":
			var status = get_ragdoll_status()
			return "Ragdoll Status: " + str(status)
		
		_:
			return "Unknown ragdoll command: " + command

# ===== DIALOGUE SYSTEM =====
func say(text: String) -> void:
	"""Make the ragdoll speak"""
	current_speech = text
	speech_timer = 3.0
	
	# Get dialogue system if available
	if not dialogue_system:
		dialogue_system = get_node_or_null("/root/DialogueSystem")
	
	if dialogue_system and dialogue_system.has_method("show_ragdoll_dialogue"):
		dialogue_system.show_ragdoll_dialogue(text)
	
	ragdoll_dialogue_started.emit(text)
	print("🗣️ [Ragdoll] " + text)

func _update_dialogue(delta: float) -> void:
	"""Update dialogue timer and trigger random dialogue"""
	if speech_timer > 0:
		speech_timer -= delta
		return
	
	# Random dialogue based on state
	if randf() < 0.002:  # 0.2% chance per frame (reduced spam)
		var state = "idle"
		if walker and walker.get("current_state") != null:
			match walker.current_state:
				2, 3:  # STEPPING=2, BALANCING=3
					state = "walking"
				4:  # FALLING=4
					state = "falling"
				_:
					state = "idle"
		
		match state:
			"walking":
				say(WALKING_DIALOGUE[randi() % WALKING_DIALOGUE.size()])
			"falling":
				say(FALLING_DIALOGUE[randi() % FALLING_DIALOGUE.size()])
			_:
				if is_being_dragged:
					say(DRAGGED_DIALOGUE[randi() % DRAGGED_DIALOGUE.size()])
				else:
					say(IDLE_DIALOGUE[randi() % IDLE_DIALOGUE.size()])

# ===== CONSOLE COMMAND COMPATIBILITY =====
func toggle_walking() -> void:
	"""Toggle walking on/off for console compatibility"""
	is_walking = !is_walking
	if is_walking:
		start_walking()
	else:
		stop_walking()

func start_walking() -> void:
	"""Start walking mode"""
	is_walking = true
	if walker and walker.has_method("stand_up"):
		walker.stand_up()
	say("Time to walk! Let's see what these legs can do!")
