# 🏛️ Gizmo Collision Fix - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: gizmo_collision_fix.gd
# DESCRIPTION: Fix gizmo collision detection to enable dragging
# PURPOSE: Add collision shapes to gizmo components for mouse interaction
# CREATED: 2025-05-30
# ==================================================

extends UniversalBeingBase
func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[GizmoCollisionFix] Initializing gizmo collision fix...")
	call_deferred("_fix_gizmo_collisions")

func _fix_gizmo_collisions() -> void:
	"""Add collision shapes to all gizmo components"""
	
	# Wait a bit more to ensure gizmo system is ready
	await get_tree().create_timer(1.0).timeout
	
	# Use the new finder system
	var gizmo_system = GizmoSystemFinder.find_gizmo_system()
	if not gizmo_system:
		print("[GizmoCollisionFix] No gizmo system found with GizmoSystemFinder!")
		return
	
	print("[GizmoCollisionFix] Found gizmo system at: ", gizmo_system.get_path())
	print("[GizmoCollisionFix] Gizmo visible: ", gizmo_system.visible)
	
	# Add collisions to all gizmo beings
	var components_fixed = 0
	
	# Fix arrow beings (translation)
	if "arrow_beings" in gizmo_system:
		for axis in gizmo_system.arrow_beings:
			var being = gizmo_system.arrow_beings[axis]
			if being and is_instance_valid(being):
				_add_collision_to_gizmo(being, axis, "translate")
				components_fixed += 1
			else:
				print("[GizmoCollisionFix] Invalid arrow being for axis: ", axis)
	
	# Fix plane beings (2-axis translation)
	if "plane_beings" in gizmo_system:
		for plane in gizmo_system.plane_beings:
			var being = gizmo_system.plane_beings[plane]
			if being and is_instance_valid(being):
				_add_collision_to_gizmo(being, plane, "translate")
				components_fixed += 1
	
	# Fix rotation beings
	if "rotation_beings" in gizmo_system:
		for axis in gizmo_system.rotation_beings:
			var being = gizmo_system.rotation_beings[axis]
			if being and is_instance_valid(being):
				_add_collision_to_gizmo(being, axis, "rotate")
				components_fixed += 1
	
	# Fix scale beings
	if "scale_beings" in gizmo_system:
		for axis in gizmo_system.scale_beings:
			var being = gizmo_system.scale_beings[axis]
			if being and is_instance_valid(being):
				_add_collision_to_gizmo(being, axis, "scale")
				components_fixed += 1
	
	print("[GizmoCollisionFix] Fixed ", components_fixed, " gizmo components")

func _add_collision_to_gizmo(gizmo_being: Node3D, axis: String, mode: String) -> void:
	"""Add collision shape to a gizmo component"""
	
	# Check if collision already exists
	var existing_body = null
	for child in gizmo_being.get_children():
		if child is StaticBody3D:
			existing_body = child
			break
	
	if existing_body:
		print("[GizmoCollisionFix] Collision already exists for ", gizmo_being.name)
		return
	
	# Create collision body
	var collision_body = StaticBody3D.new()
	collision_body.name = "GizmoCollider"
	collision_body.add_to_group("gizmo_components")
	collision_body.set_meta("is_gizmo", true)
	collision_body.set_meta("gizmo_axis", axis)
	collision_body.set_meta("gizmo_mode", mode)
	
	# Create collision shape based on gizmo type
	var collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape"
	
	# Determine shape based on mode and axis
	if mode == "translate":
		if len(axis) == 1:  # Single axis arrow
			# Use capsule for arrow shaft
			var capsule = CapsuleShape3D.new()
			capsule.radius = 0.1
			capsule.height = 2.0
			collision_shape.shape = capsule
			
			# Position based on axis
			match axis:
				"x":
					collision_shape.rotation.z = PI/2
					collision_shape.position.x = 1.0
				"y":
					collision_shape.position.y = 1.0
				"z":
					collision_shape.rotation.x = PI/2
					collision_shape.position.z = 1.0
		else:  # Plane handle
			# Use box for plane
			var box = BoxShape3D.new()
			box.size = Vector3(0.6, 0.6, 0.1)
			collision_shape.shape = box
			
			# Position based on plane
			match axis:
				"xy":
					collision_shape.position = Vector3(0.6, 0.6, 0)
				"xz":
					collision_shape.rotation.x = PI/2
					collision_shape.position = Vector3(0.6, 0, 0.6)
				"yz":
					collision_shape.rotation.y = PI/2
					collision_shape.position = Vector3(0, 0.6, 0.6)
	
	elif mode == "rotate":
		# Use torus approximation with multiple boxes
		var box = BoxShape3D.new()
		box.size = Vector3(0.2, 0.2, 1.6)
		collision_shape.shape = box
		
		# Position based on axis
		match axis:
			"x":
				collision_shape.rotation.x = PI/2
			"y":
				collision_shape.rotation.y = PI/2
			"z":
				pass  # Default orientation
	
	elif mode == "scale":
		# Use box for scale handles
		var box = BoxShape3D.new()
		if axis == "uniform":
			box.size = Vector3(0.3, 0.3, 0.3)
			collision_shape.position = Vector3.ZERO
		else:
			box.size = Vector3(0.15, 0.15, 0.15)
			# Position based on axis
			match axis:
				"x":
					collision_shape.position.x = 2.0
				"y":
					collision_shape.position.y = 2.0
				"z":
					collision_shape.position.z = 2.0
		collision_shape.shape = box
	
	# Add collision shape to body
	FloodgateController.universal_add_child(collision_shape, collision_body)
	
	# Add body to gizmo being
	FloodgateController.universal_add_child(collision_body, gizmo_being)
	
	print("[GizmoCollisionFix] Added collision to ", gizmo_being.name, " (", mode, " ", axis, ")")

# Helper function to visualize collision shapes during debug
func _visualize_collision_shapes(enable: bool = true) -> void:
	"""Toggle collision shape visualization for debugging"""
	get_tree().debug_collisions_hint = enable
	print("[GizmoCollisionFix] Collision visualization: ", "ON" if enable else "OFF")

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