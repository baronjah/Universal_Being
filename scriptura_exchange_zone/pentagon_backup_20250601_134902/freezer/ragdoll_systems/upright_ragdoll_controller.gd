# ==================================================
# SCRIPT NAME: upright_ragdoll_controller.gd
# DESCRIPTION: Keeps ragdoll standing and walking properly
# PURPOSE: Blend physics ragdoll with controlled walking
# CREATED: 2025-05-25 - Making ragdoll walk instead of lay
# ==================================================

extends UniversalBeingBase
# Ragdoll state
enum RagdollMode {
	CONTROLLED,  # Upright walking mode
	PHYSICS,     # Full ragdoll physics
	BLEND        # Blend between both
}

var mode: RagdollMode = RagdollMode.CONTROLLED
var blend_weight: float = 1.0  # 1.0 = full control, 0.0 = full physics

# Body parts references
var pelvis: RigidBody3D
var left_thigh: RigidBody3D
var right_thigh: RigidBody3D
var left_shin: RigidBody3D
var right_shin: RigidBody3D
var left_foot: RigidBody3D
var right_foot: RigidBody3D

# Target positions for controlled mode
var rest_positions = {}
var walking_cycle: float = 0.0
var is_walking: bool = false
var walk_direction: Vector3 = Vector3.ZERO

# Balance control
var balance_force: float = 500.0
var upright_torque: float = 100.0

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Find all body parts
	_find_body_parts()
	# Store rest positions
	_store_rest_positions()
	# Set up physics properties
	_configure_physics()

func _find_body_parts() -> void:
	# Find parts by name in children
	for child in get_children():
		if child is RigidBody3D:
			match child.name:
				"pelvis": pelvis = child
				"left_thigh": left_thigh = child
				"right_thigh": right_thigh = child
				"left_shin": left_shin = child
				"right_shin": right_shin = child
				"left_foot": left_foot = child
				"right_foot": right_foot = child

func _store_rest_positions() -> void:
	# Store the designed rest pose
	rest_positions = {
		"pelvis": Vector3(0, 1.2, 0),
		"left_thigh": Vector3(-0.2, 0.8, 0),
		"right_thigh": Vector3(0.2, 0.8, 0),
		"left_shin": Vector3(-0.2, 0.4, 0),
		"right_shin": Vector3(0.2, 0.4, 0),
		"left_foot": Vector3(-0.2, 0.05, 0.1),
		"right_foot": Vector3(0.2, 0.05, 0.1)
	}

func _configure_physics() -> void:
	# Configure each body part for controlled movement
	var parts = [pelvis, left_thigh, right_thigh, left_shin, right_shin, left_foot, right_foot]
	
	for part in parts:
		if part:
			# Reduce gravity effect when controlled
			part.gravity_scale = 0.3
			# Add damping to prevent wobbling
			part.linear_damp = 2.0
			part.angular_damp = 5.0
			# Keep parts active
			part.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
			part.freeze = false


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	match mode:
		RagdollMode.CONTROLLED:
			_process_controlled_mode(delta)
		RagdollMode.PHYSICS:
			_process_physics_mode(delta)
		RagdollMode.BLEND:
			_process_blend_mode(delta)
	
	# Always try to keep pelvis upright
	_apply_balance_forces()

func _process_controlled_mode(delta: float) -> void:
	if not pelvis:
		return
	
	# Keep pelvis at target height
	var target_height = 1.2
	var current_height = pelvis.global_position.y
	var height_error = target_height - current_height
	
	# Apply upward force to maintain height
	pelvis.apply_central_force(Vector3.UP * height_error * balance_force)
	
	# Keep pelvis rotation upright
	var current_rotation = pelvis.global_basis.get_euler()
	var rotation_error = -current_rotation
	rotation_error.y = 0  # Allow Y rotation
	pelvis.apply_torque(rotation_error * upright_torque)
	
	# Process walking if active
	if is_walking:
		_process_walking(delta)
	else:
		_maintain_rest_pose()

func _process_walking(delta: float) -> void:
	walking_cycle += delta * 2.0  # Walking speed
	
	# Simple walking animation using sine waves
	var left_phase = sin(walking_cycle) * 0.3
	var right_phase = sin(walking_cycle + PI) * 0.3
	
	# Move thighs
	if left_thigh:
		var target_rot = Vector3(left_phase, 0, 0)
		_apply_rotation_force(left_thigh, target_rot)
	
	if right_thigh:
		var target_rot = Vector3(right_phase, 0, 0)
		_apply_rotation_force(right_thigh, target_rot)
	
	# Move shins (knees)
	if left_shin:
		var knee_bend = max(0, -left_phase) * 0.5
		_apply_rotation_force(left_shin, Vector3(knee_bend, 0, 0))
	
	if right_shin:
		var knee_bend = max(0, -right_phase) * 0.5
		_apply_rotation_force(right_shin, Vector3(knee_bend, 0, 0))
	
	# Move pelvis forward
	if pelvis and walk_direction.length() > 0.1:
		pelvis.apply_central_force(walk_direction * 50.0)

func _maintain_rest_pose() -> void:
	# Apply forces to return to rest positions
	for part_name in rest_positions:
		var part = get(part_name)
		if part and part is RigidBody3D:
			var target_pos = global_position + rest_positions[part_name]
			var current_pos = part.global_position
			var position_error = target_pos - current_pos
			
			# Apply corrective force
			part.apply_central_force(position_error * 100.0)

func _apply_rotation_force(body: RigidBody3D, target_euler: Vector3) -> void:
	var current_euler = body.rotation
	var rotation_error = target_euler - current_euler
	body.apply_torque(rotation_error * 50.0)

func _apply_balance_forces() -> void:
	if not pelvis:
		return
	
	# Calculate center of mass
	var com = pelvis.global_position
	var total_mass = pelvis.mass
	
	var parts = [left_thigh, right_thigh, left_shin, right_shin, left_foot, right_foot]
	for part in parts:
		if part:
			com += part.global_position * part.mass
			total_mass += part.mass
	
	com /= total_mass
	
	# If leaning, apply corrective force
	var lean = com.x - pelvis.global_position.x
	if abs(lean) > 0.1:
		pelvis.apply_central_force(Vector3(-lean * balance_force, 0, 0))

func _process_physics_mode(_delta: float) -> void:
	# Full ragdoll - do nothing, let physics handle it
	pass

func _process_blend_mode(delta: float) -> void:
	# Blend between controlled and physics
	_process_controlled_mode(delta * blend_weight)

# Public API

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
func start_walking(direction: Vector3) -> void:
	is_walking = true
	walk_direction = direction.normalized()
	mode = RagdollMode.CONTROLLED

func stop_walking() -> void:
	is_walking = false
	walk_direction = Vector3.ZERO

func set_ragdoll_mode(new_mode: RagdollMode) -> void:
	mode = new_mode
	
	# Adjust physics properties based on mode
	var parts = [pelvis, left_thigh, right_thigh, left_shin, right_shin, left_foot, right_foot]
	
	match mode:
		RagdollMode.CONTROLLED:
			for part in parts:
				if part:
					part.gravity_scale = 0.3
					part.linear_damp = 2.0
		RagdollMode.PHYSICS:
			for part in parts:
				if part:
					part.gravity_scale = 1.0
					part.linear_damp = 0.1

func stand_up() -> void:
	# Force ragdoll to stand up from any position
	mode = RagdollMode.CONTROLLED
	
	# Reset pelvis position and rotation
	if pelvis:
		pelvis.global_position = global_position + Vector3(0, 1.2, 0)
		pelvis.rotation = Vector3.ZERO
		pelvis.linear_velocity = Vector3.ZERO
		pelvis.angular_velocity = Vector3.ZERO
	
	# Reset all parts to rest positions
	_maintain_rest_pose()

func ragdoll_fall() -> void:
	# Switch to full physics ragdoll
	mode = RagdollMode.PHYSICS