# 🏛️ Gizmo Direct Interaction Fix - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: gizmo_direct_interaction_fix.gd
# DESCRIPTION: Direct fix for gizmo interaction by improving raycast detection
# PURPOSE: Make gizmo components properly clickable and draggable
# CREATED: 2025-05-30
# ==================================================

extends UniversalBeingBase
var gizmo_system: Node3D = null
var mouse_held: bool = false
var dragging_gizmo: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	print("[GizmoDirectFix] Initializing direct gizmo interaction fix...")
	set_process_unhandled_input(true)
	call_deferred("_setup_gizmo_fix")

func _setup_gizmo_fix() -> void:
	"""Setup the gizmo interaction fix after scene is ready"""
	await get_tree().create_timer(0.5).timeout
	
	# Find gizmo system using new finder
	gizmo_system = GizmoSystemFinder.find_gizmo_system()
	if gizmo_system:
		print("[GizmoDirectFix] Found gizmo system: ", gizmo_system.get_path())
	else:
		print("[GizmoDirectFix] No gizmo system found yet")
	
	# Find or create gizmo system
	_ensure_gizmo_collision_layers()
	
	print("[GizmoDirectFix] Gizmo interaction fix ready!")

func _ensure_gizmo_collision_layers() -> void:
	"""Ensure all gizmo components are on proper collision layers"""
	# Set gizmo components to be on layer 2 (bit 1)
	# This separates them from regular objects on layer 1
	
	var gizmos = get_tree().get_nodes_in_group("gizmo_components")
	print("[GizmoDirectFix] Found ", gizmos.size(), " gizmo components")
	
	for gizmo in gizmos:
		if gizmo is CollisionObject3D:
			gizmo.collision_layer = 2  # Only on layer 2
			gizmo.collision_mask = 0   # Don't detect others
			print("[GizmoDirectFix] Set collision layer for: ", gizmo.name)

func _unhandled_input(event: InputEvent) -> void:
	"""Handle mouse input for gizmo interaction"""
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_on_mouse_pressed(event.position)
			else:
				_on_mouse_released()
	
	elif event is InputEventMouseMotion and dragging_gizmo:
		_on_mouse_dragged(event.position)

func _on_mouse_pressed(mouse_pos: Vector2) -> void:
	"""Handle mouse press - check if we hit a gizmo"""
	mouse_held = true
	drag_start_pos = mouse_pos
	
	# Try to detect gizmo components first
	var gizmo_hit = _raycast_for_gizmo(mouse_pos)
	if gizmo_hit:
		dragging_gizmo = true
		print("[GizmoDirectFix] Started dragging gizmo component: ", gizmo_hit.collider.name)
		
		# Find the gizmo system and notify it
		gizmo_system = get_tree().get_first_node_in_group("universal_gizmo_system")
		if gizmo_system and gizmo_system.has_method("_handle_gizmo_click"):
			gizmo_system._handle_gizmo_click(gizmo_hit.collider)
			# Prevent other systems from handling this click
			get_viewport().set_input_as_handled()

func _on_mouse_released() -> void:
	"""Handle mouse release"""
	if dragging_gizmo and gizmo_system:
		if gizmo_system.has_method("_end_drag"):
			gizmo_system._end_drag()
	
	mouse_held = false
	dragging_gizmo = false

func _on_mouse_dragged(mouse_pos: Vector2) -> void:
	"""Handle mouse drag"""
	if dragging_gizmo and gizmo_system:
		if gizmo_system.has_method("_update_drag"):
			gizmo_system._update_drag(mouse_pos)

func _raycast_for_gizmo(mouse_pos: Vector2) -> Dictionary:
	"""Perform raycast specifically for gizmo components"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return {}
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100.0
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	# Only check layer 2 (gizmo layer)
	query.collision_mask = 2
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		print("[GizmoDirectFix] Raycast hit: ", result.collider.name, " at ", result.position)
	
	return result


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
func cmd_debug_gizmo_collisions() -> void:
	"""Debug command to visualize gizmo collisions"""
	get_tree().debug_collisions_hint = !get_tree().debug_collisions_hint
	print("[GizmoDirectFix] Collision visualization: ", "ON" if get_tree().debug_collisions_hint else "OFF")

func cmd_list_gizmo_components() -> void:
	"""List all gizmo components in the scene"""
	var components = get_tree().get_nodes_in_group("gizmo_components")
	print("[GizmoDirectFix] Gizmo components (", components.size(), "):")
	for comp in components:
		var layer_info = ""
		if comp is CollisionObject3D:
			layer_info = " [Layer: " + str(comp.collision_layer) + "]"
		print("  - ", comp.name, " (", comp.get_class(), ")", layer_info)