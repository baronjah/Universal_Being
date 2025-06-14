# ==================================================
# SCRIPT NAME: universal_cursor.gd
# DESCRIPTION: Universal Being cursor that bridges 3D space and 2D interface interaction
# PURPOSE: Pentagon-compliant cursor for spatial interface interaction
# CREATED: 2025-06-01 - Universal Cursor Implementation
# AUTHOR: JSH + Claude Code
# ==================================================

extends UniversalBeingBase
class_name UniversalCursor

signal interface_clicked(interface: Node, pixel_position: Vector2)
signal interface_hovered(interface: Node, pixel_position: Vector2)
signal interface_exited(interface: Node)

# Cursor components
var cursor_visual: MeshInstance3D
var raycast: RayCast3D
var trail_particles: GPUParticles3D

# Cursor properties
var cursor_size: float = 0.1
var cursor_color: Color = Color(0.0, 1.0, 1.0, 0.8)  # Cyan
var raycast_distance: float = 1000.0
var is_active: bool = true

# Interface interaction
var current_interface: Node = null
var hovered_interface: Node = null
var last_raycast_result: Dictionary = {}

# Visual feedback
var hover_material: StandardMaterial3D
var click_material: StandardMaterial3D
var normal_material: StandardMaterial3D

# Connection to systems
var mouse_system: Node = null
var camera: Camera3D = null

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	form = "universal_cursor"
	name = "UniversalCursor"
	become_conscious(2)  # Level 2: Interactive consciousness

func pentagon_ready() -> void:
	super.pentagon_ready()
	_setup_cursor_visual()
	_setup_raycast_system()
	_setup_trail_effects()
	_connect_to_systems()
	print("🎯 [UniversalCursor] Pentagon-compliant cursor ready!")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	if is_active:
		_update_cursor_position()
		_update_raycast()
		_update_interface_interaction()
		_update_visual_feedback()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	if is_active and event is InputEventMouseButton:
		_handle_click_event(event)

func pentagon_sewers() -> void:
	super.pentagon_sewers()
	# Send interaction data to Akashic Records
	if current_interface:
		var interaction_data = {
			"cursor_position": global_position,
			"interface_name": current_interface.name,
			"interaction_type": "interface_focus"
		}
		# Connect to Akashic when available

func _setup_cursor_visual() -> void:
	"""Create 3D cursor visual representation"""
	cursor_visual = MeshInstance3D.new()
	cursor_visual.name = "CursorVisual"
	
	# Create cursor geometry (small sphere)
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = cursor_size
	sphere_mesh.radial_segments = 8
	sphere_mesh.rings = 6
	cursor_visual.mesh = sphere_mesh
	
	# Create materials
	normal_material = MaterialLibrary.get_material("cursor_normal")
	normal_material.flags_unshaded = true
	normal_material.albedo_color = cursor_color
	normal_material.emission_enabled = true
	normal_material.emission = cursor_color * 0.5
	
	hover_material = MaterialLibrary.get_material("cursor_hover")
	hover_material.flags_unshaded = true
	hover_material.albedo_color = Color.YELLOW
	hover_material.emission_enabled = true
	hover_material.emission = Color.YELLOW * 0.8
	
	click_material = MaterialLibrary.get_material("cursor_click")
	click_material.flags_unshaded = true
	click_material.albedo_color = Color.RED
	click_material.emission_enabled = true
	click_material.emission = Color.RED * 1.0
	
	cursor_visual.material_override = normal_material
	FloodgateController.universal_add_child(cursor_visual, self)

func _setup_raycast_system() -> void:
	"""Set up 3D raycast for interface detection"""
	raycast = RayCast3D.new()
	raycast.name = "InterfaceRaycast"
	raycast.target_position = Vector3(0, 0, -raycast_distance)
	raycast.collision_mask = 1 << 10  # Interface layer (layer 10)
	raycast.enabled = true
	FloodgateController.universal_add_child(raycast, self)

func _setup_trail_effects() -> void:
	"""Create particle trail for cursor movement"""
	trail_particles = GPUParticles3D.new()
	trail_particles.name = "CursorTrail"
	trail_particles.emitting = true
	trail_particles.amount = 50
	trail_particles.lifetime = 2.0
	
	# Create simple particle material
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 0, 1)
	particle_material.initial_velocity_min = 0.5
	particle_material.initial_velocity_max = 1.0
	particle_material.scale_min = 0.1
	particle_material.scale_max = 0.3
	trail_particles.process_material = particle_material
	
	FloodgateController.universal_add_child(trail_particles, self)

func _connect_to_systems() -> void:
	"""Connect to mouse system and camera"""
	mouse_system = get_node_or_null("/root/MouseInteractionSystem")
	if not mouse_system:
		# Try to find mouse system in scene
		var scene = get_tree().current_scene
		mouse_system = _find_node_by_class(scene, "MouseInteractionSystem")
	
	camera = get_viewport().get_camera_3d()
	if not camera:
		print("⚠️ [UniversalCursor] No camera found!")

func _update_cursor_position() -> void:
	"""Update cursor position based on mouse and camera"""
	if not camera:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	
	# Position cursor slightly in front of camera
	global_position = ray_origin + ray_direction * 2.0

func _update_raycast() -> void:
	"""Update raycast for interface detection"""
	if not camera:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	
	# Update raycast position and direction
	raycast.global_position = ray_origin
	raycast.target_position = ray_direction * raycast_distance
	
	# Force raycast update
	raycast.force_raycast_update()

func _update_interface_interaction() -> void:
	"""Handle interface hover and interaction"""
	var new_interface = null
	var intersection_point = Vector3.ZERO
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		intersection_point = raycast.get_collision_point()
		
		# Find the interface system
		new_interface = _find_interface_system(collider)
	
	# Handle interface changes
	if new_interface != hovered_interface:
		# Exit previous interface
		if hovered_interface:
			_on_interface_exit(hovered_interface)
		
		# Enter new interface
		hovered_interface = new_interface
		if hovered_interface:
			_on_interface_enter(hovered_interface, intersection_point)

func _find_interface_system(collider: Node) -> Node:
	"""Find the EnhancedInterfaceSystem from collision"""
	var node = collider
	while node:
		if node.has_method("setup_interface_type"):  # EnhancedInterfaceSystem
			return node
		node = node.get_parent()
	return null

func _on_interface_enter(interface: Node, intersection_point: Vector3) -> void:
	"""Handle entering interface area"""
	cursor_visual.material_override = hover_material
	print("🎯 [UniversalCursor] Hovering interface: ", interface.name)
	
	# Convert 3D point to 2D coordinates
	var pixel_pos = _convert_3d_to_interface_coords(intersection_point, interface)
	interface_hovered.emit(interface, pixel_pos)

func _on_interface_exit(interface: Node) -> void:
	"""Handle exiting interface area"""
	cursor_visual.material_override = normal_material
	print("🚪 [UniversalCursor] Exited interface: ", interface.name)
	interface_exited.emit(interface)

func _handle_click_event(event: InputEventMouseButton) -> void:
	"""Handle mouse clicks on interfaces"""
	if not hovered_interface or not event.pressed:
		return
	
	# Visual feedback
	cursor_visual.material_override = click_material
	
	# Get intersection point
	var intersection_point = raycast.get_collision_point()
	var pixel_pos = _convert_3d_to_interface_coords(intersection_point, hovered_interface)
	
	# Send click to interface
	_send_click_to_interface(hovered_interface, pixel_pos, event)
	
	# Emit signal
	interface_clicked.emit(hovered_interface, pixel_pos)
	
	print("🖱️ [UniversalCursor] Clicked interface: ", hovered_interface.name, " at ", pixel_pos)
	
	# Reset visual after short delay
	await get_tree().create_timer(0.1).timeout
	if hovered_interface:
		cursor_visual.material_override = hover_material
	else:
		cursor_visual.material_override = normal_material

func _convert_3d_to_interface_coords(intersection_point: Vector3, interface: Node) -> Vector2:
	"""Convert 3D world position to 2D interface coordinates"""
	# Get the interface panel (MeshInstance3D with PlaneMesh)
	var interface_panel = interface.get_node_or_null("InterfacePanel")
	if not interface_panel:
		return Vector2.ZERO
	
	# Convert world space intersection to local mesh coordinates
	var local_pos = interface_panel.to_local(intersection_point)
	
	# Get mesh size (assuming PlaneMesh)
	var mesh = interface_panel.mesh
	var mesh_size = Vector2(4.0, 3.0)  # Default interface size
	if mesh and mesh.has_method("get_size"):
		mesh_size = mesh.size
	
	# Convert to UV coordinates (0-1 range)
	var uv_coords = Vector2(
		(local_pos.x + mesh_size.x * 0.5) / mesh_size.x,
		(mesh_size.y * 0.5 - local_pos.y) / mesh_size.y
	)
	
	# Clamp to interface bounds
	uv_coords = uv_coords.clamp(Vector2.ZERO, Vector2.ONE)
	
	# Convert UV to viewport pixel coordinates
	var viewport_size = interface.interface_resolution
	var pixel_coords = Vector2(
		uv_coords.x * viewport_size.x,
		uv_coords.y * viewport_size.y
	)
	
	return pixel_coords

func _send_click_to_interface(interface: Node, pixel_pos: Vector2, event: InputEventMouseButton) -> void:
	"""Send mouse event to interface's SubViewport"""
	var ui_viewport = interface.ui_viewport
	if not ui_viewport or not is_instance_valid(ui_viewport):
		print("⚠️ [UniversalCursor] No valid viewport in interface: ", interface.name)
		return
	
	# Create properly formatted mouse event
	var interface_event = InputEventMouseButton.new()
	interface_event.button_index = event.button_index
	interface_event.pressed = event.pressed
	interface_event.position = pixel_pos
	interface_event.global_position = pixel_pos
	
	# Send to interface's SubViewport
	ui_viewport.push_input(interface_event)
	
	# Visual feedback - create click ripple
	_show_click_ripple(pixel_pos, interface)

func _show_click_ripple(pixel_pos: Vector2, interface: Node) -> void:
	"""Show visual click ripple effect"""
	print("💫 [UniversalCursor] Click ripple at: ", pixel_pos)
	# TODO: Implement actual ripple effect

func _update_visual_feedback() -> void:
	"""Update cursor visual feedback"""
	if trail_particles:
		trail_particles.global_position = global_position

func _find_node_by_class(node: Node, class_name: String) -> Node:
	"""Recursively find node by class name"""
	if node.get_script() and node.get_script().get_global_name() == class_name:
		return node
	
	for child in node.get_children():
		var result = _find_node_by_class(child, class_name)
		if result:
			return result
	
	return null

# Console command support
func set_cursor_active(active: bool) -> void:
	"""Enable/disable cursor"""
	is_active = active
	visible = active
	print("🎯 [UniversalCursor] Active: ", active)

func set_cursor_size(size: float) -> void:
	"""Change cursor size"""
	cursor_size = size
	if cursor_visual and cursor_visual.mesh:
		cursor_visual.mesh.radius = size

func debug_cursor_status() -> void:
	"""Print cursor debug information"""
	print("🎯 [UniversalCursor] Debug Status:")
	print("  Active: ", is_active)
	print("  Position: ", global_position)
	print("  Hovered Interface: ", hovered_interface.name if hovered_interface else "None")
	print("  Camera: ", camera.name if camera else "None")
	print("  Mouse System: ", mouse_system.name if mouse_system else "None")
	print("  Raycast Colliding: ", raycast.is_colliding() if raycast else "No raycast")