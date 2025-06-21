# ==================================================
# UNIVERSAL BEING: MAGNETIC SPHERE MOTOR SYSTEM
# TYPE: Any-Axis Quaternion Rotation Motor
# PURPOSE: Trackball-like magnetic sphere for perfect rotation
# INSPIRED BY: Your description of alien magnetic sphere motors
# ==================================================

extends Node3D
class_name MagneticSphereMotor

## 🧲 MAGNETIC SPHERE MOTOR - Perfect quaternion rotation like your eyeballs
## Magnetic field-based rotation system for any-axis movement
## Stabilized horizon like human eye muscles, even when tilted

# ===== MOTOR CONFIGURATION =====
@export var motor_enabled: bool = true
@export var magnetic_field_strength: float = 1.0
@export var rotation_sensitivity: float = 2.0
@export var horizon_stabilization: bool = true
@export var auto_level_strength: float = 0.5

# Motor Types
enum MotorType {
	TRACKBALL,          # Free 3D rotation like trackball
	EYEBALL,            # Eye-like rotation with stabilization
	GIMBAL,             # Traditional gimbal-style
	MAGNETIC_LEVITATION,# Full 6DOF floating rotation
	PLANETARY,          # Orbiting rotation system
	CONSCIOUSNESS       # Consciousness-driven rotation
}

# ===== MAGNETIC FIELD SYSTEM =====
class MagneticField:
	var field_center: Vector3
	var field_strength: float
	var field_radius: float
	var polarity: int  # 1 or -1
	var field_type: String
	var visual_representation: Node3D
	
	func _init(center: Vector3, strength: float, radius: float = 1.0, polar: int = 1):
		field_center = center
		field_strength = strength
		field_radius = radius
		polarity = polar
		field_type = "spherical"

class RotationConstraint:
	var constraint_type: String
	var axis: Vector3
	var min_angle: float
	var max_angle: float
	var strength: float
	
	func _init(type: String, constraint_axis: Vector3 = Vector3.UP):
		constraint_type = type
		axis = constraint_axis
		min_angle = -PI
		max_angle = PI
		strength = 1.0

# ===== MOTOR STATE =====
@export var motor_type: MotorType = MotorType.EYEBALL
var target_object: Node3D  # Object to rotate
var motor_sphere: Node3D   # Visual motor sphere

# Magnetic system
var magnetic_fields: Array[MagneticField] = []
var rotation_constraints: Array[RotationConstraint] = []
var magnetic_torque: Vector3 = Vector3.ZERO

# Rotation state
var current_rotation: Quaternion = Quaternion.IDENTITY
var target_rotation: Quaternion = Quaternion.IDENTITY
var angular_velocity: Vector3 = Vector3.ZERO
var stabilization_target: Vector3 = Vector3.UP

# Eye stabilization (like human eyes)
var eye_base_orientation: Quaternion = Quaternion.IDENTITY
var horizon_reference: Vector3 = Vector3.UP
var tilt_compensation: float = 0.0

# Performance
var motor_update_rate: float = 120.0  # High precision updates
var smoothing_factor: float = 0.1

# Visual components
var field_visualizers: Array[Node3D] = []
var magnetic_field_material: StandardMaterial3D
var rotation_indicator: Node3D

# ===== PENTAGON INTEGRATION =====

func _ready() -> void:
	setup_magnetic_motor()
	initialize_motor_materials()
	create_magnetic_fields()
	setup_rotation_constraints()
	connect_to_consciousness_systems()
	
	print("🧲 Magnetic Sphere Motor: Any-axis quaternion rotation system active!")

func _process(delta: float) -> void:
	if motor_enabled and target_object:
		update_magnetic_fields(delta)
		calculate_magnetic_torque(delta)
		apply_rotation_forces(delta)
		update_eye_stabilization(delta)
		update_motor_visualization(delta)

func _input(event: InputEvent) -> void:
	if motor_enabled:
		handle_motor_input(event)

# ===== MOTOR SETUP =====

func setup_magnetic_motor() -> void:
	"""Initialize the magnetic sphere motor system"""
	# Create motor sphere visual
	motor_sphere = MeshInstance3D.new()
	motor_sphere.mesh = SphereMesh.new()
	motor_sphere.mesh.radius = 0.5
	motor_sphere.name = "MotorSphere"
	add_child(motor_sphere)
	
	# Create rotation indicator
	rotation_indicator = Node3D.new()
	rotation_indicator.name = "RotationIndicator"
	add_child(rotation_indicator)
	
	var indicator_mesh = MeshInstance3D.new()
	indicator_mesh.mesh = CylinderMesh.new()
	indicator_mesh.mesh.top_radius = 0.1
	indicator_mesh.mesh.bottom_radius = 0.0
	indicator_mesh.mesh.height = 1.0
	rotation_indicator.add_child(indicator_mesh)
	
	print("🧲 Motor sphere and indicators created")

func initialize_motor_materials() -> void:
	"""Create materials for magnetic field visualization"""
	# Magnetic field material - translucent blue with energy
	magnetic_field_material = StandardMaterial3D.new()
	magnetic_field_material.albedo_color = Color(0.3, 0.6, 1.0, 0.3)
	magnetic_field_material.emission_enabled = true
	magnetic_field_material.emission = Color(0.2, 0.4, 0.8)
	magnetic_field_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# Motor sphere material - metallic magnetic
	var motor_material = StandardMaterial3D.new()
	motor_material.albedo_color = Color(0.7, 0.7, 0.8, 0.9)
	motor_material.metallic = 0.8
	motor_material.roughness = 0.2
	motor_material.emission_enabled = true
	motor_material.emission = Color(0.1, 0.1, 0.3)
	
	motor_sphere.material_override = motor_material
	
	print("💎 Magnetic motor materials initialized")

func create_magnetic_fields() -> void:
	"""Create the magnetic field configuration"""
	match motor_type:
		MotorType.EYEBALL:
			create_eyeball_magnetic_configuration()
		MotorType.TRACKBALL:
			create_trackball_magnetic_configuration()
		MotorType.MAGNETIC_LEVITATION:
			create_levitation_magnetic_configuration()
		MotorType.CONSCIOUSNESS:
			create_consciousness_magnetic_configuration()
		_:
			create_default_magnetic_configuration()

func create_eyeball_magnetic_configuration() -> void:
	"""Create eyeball-like magnetic field (like human eye muscles)"""
	# Six primary magnetic fields (like 6 eye muscles)
	var field_positions = [
		Vector3(1, 0, 0),   # Right
		Vector3(-1, 0, 0),  # Left
		Vector3(0, 1, 0),   # Up
		Vector3(0, -1, 0),  # Down
		Vector3(0, 0, 1),   # Forward
		Vector3(0, 0, -1)   # Back
	]
	
	for i in range(field_positions.size()):
		var pos = field_positions[i] * 2.0
		var field = MagneticField.new(pos, magnetic_field_strength, 1.5)
		field.field_type = "eye_muscle_" + str(i)
		magnetic_fields.append(field)
		create_field_visualizer(field)
	
	print("👁️ Eyeball magnetic configuration created - 6 muscle fields active")

func create_trackball_magnetic_configuration() -> void:
	"""Create trackball-like magnetic field configuration"""
	# 8 corner fields for full 3D rotation
	var corners = [
		Vector3(1, 1, 1), Vector3(-1, 1, 1), Vector3(1, -1, 1), Vector3(-1, -1, 1),
		Vector3(1, 1, -1), Vector3(-1, 1, -1), Vector3(1, -1, -1), Vector3(-1, -1, -1)
	]
	
	for corner in corners:
		var field = MagneticField.new(corner.normalized() * 2.0, magnetic_field_strength, 1.0)
		field.field_type = "trackball_corner"
		magnetic_fields.append(field)
		create_field_visualizer(field)
	
	print("🎛️ Trackball magnetic configuration created - 8 corner fields")

func create_consciousness_magnetic_configuration() -> void:
	"""Create consciousness-driven magnetic field"""
	# Dynamic fields that respond to consciousness level
	var consciousness_level = get_consciousness_level()
	var field_count = int(consciousness_level * 2) + 4  # 4-14 fields based on consciousness
	
	for i in range(field_count):
		var angle = (TAU / field_count) * i
		var pos = Vector3(cos(angle), sin(angle * 0.5), sin(angle)) * 2.0
		var field = MagneticField.new(pos, magnetic_field_strength * consciousness_level, 1.0)
		field.field_type = "consciousness_field"
		magnetic_fields.append(field)
		create_field_visualizer(field)
	
	print("🧠 Consciousness magnetic configuration created - %d fields" % field_count)

func create_field_visualizer(field: MagneticField) -> void:
	"""Create visual representation of magnetic field"""
	var visualizer = Node3D.new()
	visualizer.name = "MagneticField_" + field.field_type
	visualizer.position = field.field_center
	
	# Field sphere
	var field_sphere = MeshInstance3D.new()
	field_sphere.mesh = SphereMesh.new()
	field_sphere.mesh.radius = field.field_radius
	field_sphere.material_override = magnetic_field_material
	
	# Field lines (simplified)
	var field_lines = Node3D.new()
	for i in range(8):
		var line = MeshInstance3D.new()
		line.mesh = CylinderMesh.new()
		line.mesh.top_radius = 0.02
		line.mesh.bottom_radius = 0.02
		line.mesh.height = field.field_radius * 2
		line.material_override = magnetic_field_material
		line.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
		field_lines.add_child(line)
	
	visualizer.add_child(field_sphere)
	visualizer.add_child(field_lines)
	add_child(visualizer)
	
	field.visual_representation = visualizer
	field_visualizers.append(visualizer)

# ===== MAGNETIC FORCE CALCULATIONS =====

func update_magnetic_fields(delta: float) -> void:
	"""Update magnetic field states"""
	for field in magnetic_fields:
		if field.visual_representation:
			# Pulsing magnetic field effect
			var pulse = sin(Time.get_time_from_start() * 3.0 + field.field_center.length()) * 0.1 + 1.0
			field.visual_representation.scale = Vector3.ONE * pulse
			
			# Rotate field lines
			var field_lines = field.visual_representation.get_child(1)
			if field_lines:
				field_lines.rotation_degrees += Vector3(10, 15, 20) * delta

func calculate_magnetic_torque(delta: float) -> void:
	"""Calculate magnetic torque based on field interactions"""
	magnetic_torque = Vector3.ZERO
	
	if not target_object:
		return
	
	var object_position = target_object.global_position
	var total_torque = Vector3.ZERO
	
	for field in magnetic_fields:
		var field_global_pos = global_position + field.field_center
		var distance_vector = object_position - field_global_pos
		var distance = distance_vector.length()
		
		if distance < field.field_radius:
			# Calculate magnetic force (simplified magnetic dipole interaction)
			var force_strength = field.field_strength * field.polarity / (distance * distance + 0.1)
			var force_direction = distance_vector.normalized()
			
			# Convert force to torque
			var torque = distance_vector.cross(force_direction) * force_strength
			total_torque += torque
	
	magnetic_torque = total_torque * rotation_sensitivity

func apply_rotation_forces(delta: float) -> void:
	"""Apply magnetic torque to create rotation"""
	if not target_object:
		return
	
	# Apply magnetic torque to angular velocity
	angular_velocity += magnetic_torque * delta
	
	# Apply damping
	angular_velocity *= (1.0 - smoothing_factor)
	
	# Convert angular velocity to quaternion rotation
	var rotation_delta = Quaternion(angular_velocity.normalized(), angular_velocity.length() * delta)
	current_rotation = current_rotation * rotation_delta
	
	# Apply constraints
	apply_rotation_constraints()
	
	# Apply to target object
	target_object.quaternion = current_rotation

func apply_rotation_constraints() -> void:
	"""Apply rotation constraints to prevent impossible rotations"""
	for constraint in rotation_constraints:
		match constraint.constraint_type:
			"horizon_lock":
				if horizon_stabilization:
					apply_horizon_stabilization()
			"gimbal_lock_prevention":
				prevent_gimbal_lock()
			"range_limit":
				apply_angle_range_limits(constraint)

func apply_horizon_stabilization() -> void:
	"""Apply horizon stabilization like human eyes"""
	if not target_object:
		return
	
	# Calculate current horizon tilt
	var current_up = target_object.transform.basis.y
	var horizon_tilt = current_up.angle_to(horizon_reference)
	
	# Calculate correction needed
	var correction_axis = current_up.cross(horizon_reference).normalized()
	var correction_strength = horizon_tilt * auto_level_strength
	
	# Apply gradual correction
	if correction_strength > 0.01:
		var correction_rotation = Quaternion(correction_axis, correction_strength * 0.1)
		current_rotation = current_rotation * correction_rotation

func prevent_gimbal_lock() -> void:
	"""Prevent gimbal lock by avoiding problematic orientations"""
	var euler = current_rotation.get_euler()
	
	# Avoid near-vertical orientations that cause gimbal lock
	if abs(euler.x) > PI * 0.48:  # Near 90 degrees
		euler.x = sign(euler.x) * PI * 0.48
		current_rotation = Quaternion.from_euler(euler)

# ===== EYE STABILIZATION SYSTEM =====

func update_eye_stabilization(delta: float) -> void:
	"""Update eye-like stabilization system"""
	if motor_type != MotorType.EYEBALL or not horizon_stabilization:
		return
	
	# Simulate human eye stabilization mechanisms
	update_vestibular_stabilization(delta)
	update_visual_stabilization(delta)
	update_smooth_pursuit(delta)

func update_vestibular_stabilization(delta: float) -> void:
	"""Simulate vestibular system stabilization"""
	# Detect head tilt (parent object tilt)
	var parent_tilt = Vector3.ZERO
	if get_parent() is Node3D:
		var parent_3d = get_parent() as Node3D
		parent_tilt = parent_3d.transform.basis.get_euler()
	
	# Compensate for tilt
	tilt_compensation = lerp(tilt_compensation, -parent_tilt.z, delta * 2.0)
	
	# Apply compensation to maintain horizon
	var compensation_rotation = Quaternion(Vector3.FORWARD, tilt_compensation)
	current_rotation = current_rotation * compensation_rotation

func update_visual_stabilization(delta: float) -> void:
	"""Simulate visual stabilization (keeping objects in view)"""
	# This would typically track visual targets
	# For now, just maintain general stability
	pass

func update_smooth_pursuit(delta: float) -> void:
	"""Simulate smooth pursuit eye movements"""
	# This would track moving objects smoothly
	# Implementation depends on target tracking system
	pass

# ===== INPUT HANDLING =====

func handle_motor_input(event: InputEvent) -> void:
	"""Handle input for manual motor control"""
	if event is InputEventMouseMotion and Input.is_action_pressed("motor_control"):
		var motion = event as InputEventMouseMotion
		apply_mouse_rotation(motion.relative)
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_H:  # Toggle horizon stabilization
				if event.ctrl_pressed:
					toggle_horizon_stabilization()
			KEY_M:  # Cycle motor type
				if event.ctrl_pressed:
					cycle_motor_type()

func apply_mouse_rotation(mouse_delta: Vector2) -> void:
	"""Apply mouse movement to rotation"""
	var rotation_x = Quaternion(Vector3.RIGHT, -mouse_delta.y * 0.01 * rotation_sensitivity)
	var rotation_y = Quaternion(Vector3.UP, -mouse_delta.x * 0.01 * rotation_sensitivity)
	
	target_rotation = rotation_y * rotation_x * target_rotation
	
	# Add to angular velocity for smooth movement
	angular_velocity += Vector3(-mouse_delta.y, -mouse_delta.x, 0) * 0.01 * rotation_sensitivity

# ===== MOTOR CONTROLS =====

func set_target_object(obj: Node3D) -> void:
	"""Set the object to be rotated by this motor"""
	target_object = obj
	if target_object:
		current_rotation = target_object.quaternion
		print("🧲 Motor target set: %s" % target_object.name)

func toggle_horizon_stabilization() -> void:
	"""Toggle horizon stabilization on/off"""
	horizon_stabilization = !horizon_stabilization
	print("🧲 Horizon stabilization: %s" % ("ON" if horizon_stabilization else "OFF"))

func cycle_motor_type() -> void:
	"""Cycle through different motor types"""
	var current_index = motor_type as int
	var next_index = (current_index + 1) % MotorType.size()
	motor_type = next_index as MotorType
	
	# Recreate magnetic fields for new type
	clear_magnetic_fields()
	create_magnetic_fields()
	
	print("🧲 Motor type changed to: %s" % MotorType.keys()[motor_type])

func clear_magnetic_fields() -> void:
	"""Clear existing magnetic fields"""
	for visualizer in field_visualizers:
		if is_instance_valid(visualizer):
			visualizer.queue_free()
	
	magnetic_fields.clear()
	field_visualizers.clear()

# ===== SYSTEM INTEGRATION =====

func connect_to_consciousness_systems() -> void:
	"""Connect to consciousness systems for consciousness-driven rotation"""
	var consciousness_systems = get_tree().get_nodes_in_group("consciousness_systems")
	for system in consciousness_systems:
		if system.has_signal("consciousness_level_changed"):
			system.consciousness_level_changed.connect(_on_consciousness_changed)

func _on_consciousness_changed(new_level: float) -> void:
	"""Handle consciousness level changes"""
	if motor_type == MotorType.CONSCIOUSNESS:
		# Recreate magnetic fields based on new consciousness level
		clear_magnetic_fields()
		create_magnetic_fields()

func get_consciousness_level() -> float:
	"""Get consciousness level from connected systems"""
	var consciousness_beings = get_tree().get_nodes_in_group("universal_beings")
	var total_consciousness = 0.0
	var count = 0
	
	for being in consciousness_beings:
		if being.has_method("get_consciousness_level"):
			total_consciousness += being.get_consciousness_level()
			count += 1
	
	return total_consciousness / max(1, count)

# ===== VISUALIZATION UPDATES =====

func update_motor_visualization(delta: float) -> void:
	"""Update motor visualization elements"""
	if rotation_indicator:
		# Point rotation indicator in current rotation direction
		rotation_indicator.rotation = current_rotation.get_euler()
		
		# Scale based on angular velocity
		var velocity_magnitude = angular_velocity.length()
		rotation_indicator.scale = Vector3.ONE * (1.0 + velocity_magnitude * 0.5)

# ===== PUBLIC API =====

func apply_magnetic_impulse(direction: Vector3, strength: float) -> void:
	"""Apply a magnetic impulse in a direction"""
	angular_velocity += direction.normalized() * strength

func set_magnetic_field_strength(strength: float) -> void:
	"""Set overall magnetic field strength"""
	magnetic_field_strength = strength
	for field in magnetic_fields:
		field.field_strength = strength

func get_motor_status() -> Dictionary:
	"""Get current motor status"""
	return {
		"motor_type": MotorType.keys()[motor_type],
		"enabled": motor_enabled,
		"target_object": target_object.name if target_object else "None",
		"magnetic_fields": magnetic_fields.size(),
		"angular_velocity": angular_velocity,
		"horizon_stabilization": horizon_stabilization,
		"current_rotation": current_rotation,
		"field_strength": magnetic_field_strength
	}

func _to_string() -> String:
	return "MagneticSphereMotor [Type: %s, Fields: %d, Target: %s]" % [
		MotorType.keys()[motor_type], magnetic_fields.size(), 
		target_object.name if target_object else "None"
	]