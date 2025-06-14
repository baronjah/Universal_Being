# ==================================================
# SCRIPT NAME: universal_gizmo_system.gd
# DESCRIPTION: A gizmo system where every arrow, ring, and handle is a Universal Being
# PURPOSE: Everything is a Universal Being, even the tools we use to manipulate objects
# CREATED: 2025-05-29 - The gizmo arrows have consciousness!
# ==================================================

extends UniversalBeingBase
class_name UniversalGizmoSystem

signal transform_started(axis: String, mode: String)
signal transform_updated(delta: Vector3)
signal transform_completed()

# Gizmo components (all are Universal Beings!)
var arrow_beings: Dictionary = {}  # "x", "y", "z" -> UniversalBeing
var plane_beings: Dictionary = {}  # "xy", "xz", "yz" -> UniversalBeing
var rotation_beings: Dictionary = {}  # "x", "y", "z" -> UniversalBeing (rings)
var scale_beings: Dictionary = {}  # "x", "y", "z", "uniform" -> UniversalBeing

# Target object we're manipulating
var target_object: Node3D = null
var is_active: bool = false
var current_mode: String = "translate"  # translate, rotate, scale

# Interaction state
var is_dragging: bool = false
var drag_start_pos: Vector2  # Mouse position when drag started
var drag_axis: String = ""
var drag_mode: String = ""
var initial_transform: Transform3D  # Store initial transform when dragging starts

# Visual settings
var gizmo_scale: float = 1.0
var arrow_length: float = 2.0
var arrow_thickness: float = 0.05
var manual_offset: Vector3 = Vector3.ZERO  # Manual offset for gizmo position

# Colors for axes
const AXIS_COLORS = {
	"x": Color.RED,
	"y": Color.GREEN,
	"z": Color.BLUE,
	"uniform": Color.WHITE,
	"xy": Color(1, 1, 0, 0.3),  # Yellow plane
	"xz": Color(1, 0, 1, 0.3),  # Magenta plane
	"yz": Color(0, 1, 1, 0.3)   # Cyan plane
}

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[UniversalGizmoSystem] Initializing - Every arrow is alive!")
	name = "UniversalGizmoSystem"
	
	# Add to group for console detection
	add_to_group("universal_gizmo_system")
	
	# Create gizmo components
	_create_translation_gizmos()
	_create_rotation_gizmos()
	_create_scale_gizmos()
	
	# Initially hidden
	visible = false
	
	# Register console commands
	_ready_commands()
	
	# Connect to mouse interaction system
	call_deferred("_connect_to_mouse_system")


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func attach_to_object(object: Node3D) -> void:
	"""Attach gizmo to an object"""
	if not object:
		detach()
		return
	
	target_object = object
	is_active = true
	visible = true
	
	# Make sure we have a valid mode
	if current_mode.is_empty():
		current_mode = "translate"
	
	# Update visibility of gizmo components based on mode
	set_mode(current_mode)
	
	# Update position to match target
	_update_gizmo_position()
	
	# Auto-assign to interface layer for always-visible gizmo
	call_deferred("_assign_to_interface_layer")
	
	print("[UniversalGizmoSystem] Attached to: ", object.name)
	print("[UniversalGizmoSystem] Gizmo components visible - arrows: ", arrow_beings.size(), " planes: ", plane_beings.size())

func detach() -> void:
	"""Detach from current object"""
	target_object = null
	is_active = false
	visible = false
	is_dragging = false
	
	print("[UniversalGizmoSystem] Detached")

# Unhandled input integrated into Pentagon Architecture
func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Unhandled input logic
	"""Handle input for gizmo interaction"""
	if not visible or not target_object:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if we clicked on a gizmo component
				var camera = get_viewport().get_camera_3d()
				if not camera:
					return
				
				var from = camera.project_ray_origin(event.position)
				var to = from + camera.project_ray_normal(event.position) * 1000.0
				
				var space_state = camera.get_world_3d().direct_space_state
				var query = PhysicsRayQueryParameters3D.create(from, to)
				query.collision_mask = 0xFFFFFFFF
				query.collide_with_areas = true
				query.collide_with_bodies = true
				
				var result = space_state.intersect_ray(query)
				if result and _is_gizmo_component(result.collider):
					_handle_gizmo_click(result.collider)
					# Stop propagation to prevent regular object selection
					get_viewport().set_input_as_handled()
			else:
				# Mouse released - stop any drag operation
				if is_dragging:
					_end_drag()
	
	elif event is InputEventMouseMotion:
		if is_dragging:
			_update_drag(event.position)

func _create_translation_gizmos() -> void:
	"""Create arrow Universal Beings for translation"""
	
	var unified_system = get_node_or_null("/root/UnifiedBeingSystem")
	if not unified_system:
		print("[UniversalGizmoSystem] Error: UnifiedBeingSystem not found!")
		return
	
	# Create arrow beings for each axis
	for axis in ["x", "y", "z"]:
		# Create a gizmo arrow being
		var arrow_being = _create_gizmo_being("gizmo_arrow_" + axis)
		if arrow_being:
			arrow_beings[axis] = arrow_being
			add_child(arrow_being)
			
			# Make it look like an arrow
			_setup_arrow_visual(arrow_being, axis)
			
			# Give it gizmo properties
			arrow_being.set_property("gizmo_type", "translation_arrow")
			arrow_being.set_property("gizmo_axis", axis)
			arrow_being.set_property("interactive", true)
			
			# Connect interaction
			_setup_gizmo_interaction(arrow_being, axis, "translate")
	
	# Create plane handles for 2-axis translation
	for plane in ["xy", "xz", "yz"]:
		var plane_being = _create_gizmo_being("gizmo_plane_" + plane)
		if plane_being:
			plane_beings[plane] = plane_being
			add_child(plane_being)
			
			_setup_plane_visual(plane_being, plane)
			
			plane_being.set_property("gizmo_type", "translation_plane")
			plane_being.set_property("gizmo_plane", plane)
			plane_being.set_property("interactive", true)
			
			_setup_gizmo_interaction(plane_being, plane, "translate")

func _create_rotation_gizmos() -> void:
	"""Create ring Universal Beings for rotation"""
	
	# Create rotation rings
	for axis in ["x", "y", "z"]:
		var ring_being = _create_gizmo_being("gizmo_ring_" + axis)
		if ring_being:
			rotation_beings[axis] = ring_being
			add_child(ring_being)
			
			_setup_ring_visual(ring_being, axis)
			
			ring_being.set_property("gizmo_type", "rotation_ring")
			ring_being.set_property("gizmo_axis", axis)
			ring_being.set_property("interactive", true)
			
			_setup_gizmo_interaction(ring_being, axis, "rotate")

func _create_scale_gizmos() -> void:
	"""Create cube Universal Beings for scaling"""
	
	# Create scale handles
	for axis in ["x", "y", "z"]:
		var scale_being = _create_gizmo_being("gizmo_scale_" + axis)
		if scale_being:
			scale_beings[axis] = scale_being
			add_child(scale_being)
			
			_setup_scale_visual(scale_being, axis)
			
			scale_being.set_property("gizmo_type", "scale_handle")
			scale_being.set_property("gizmo_axis", axis)
			scale_being.set_property("interactive", true)
			
			_setup_gizmo_interaction(scale_being, axis, "scale")
	
	# Uniform scale handle at center
	var uniform_being = _create_gizmo_being("gizmo_scale_uniform")
	if uniform_being:
		scale_beings["uniform"] = uniform_being
		add_child(uniform_being)
		
		_setup_uniform_scale_visual(uniform_being)
		
		uniform_being.set_property("gizmo_type", "scale_uniform")
		uniform_being.set_property("interactive", true)
		
		_setup_gizmo_interaction(uniform_being, "uniform", "scale")

func _create_gizmo_being(being_name: String) -> Node3D:
	"""Create a Universal Being for gizmo component"""
	
	var being = Node3D.new()
	being.name = being_name
	
	# Apply Universal Being script
	var universal_being_script = load("res://scripts/core/universal_being.gd")
	if universal_being_script:
		being.set_script(universal_being_script)
		
		# Initialize as a gizmo component
		being.form = "gizmo_component"
		being.set_property("is_gizmo", true)
		
		return being
	
	return null

func _setup_arrow_visual(arrow_being: Node3D, axis: String) -> void:
	"""Setup arrow visual for translation gizmo"""
	
	# Create arrow mesh (cylinder + cone)
	var arrow_container = Node3D.new()
	arrow_container.name = "ArrowVisual"
	
	# Shaft
	var shaft = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = arrow_length * 0.8
	cylinder.top_radius = arrow_thickness
	cylinder.bottom_radius = arrow_thickness
	shaft.mesh = cylinder
	shaft.position.y = arrow_length * 0.4
	
	# Arrowhead
	var head = MeshInstance3D.new()
	var cone = CylinderMesh.new()
	cone.height = arrow_length * 0.2
	cone.top_radius = 0.0
	cone.bottom_radius = arrow_thickness * 2.0
	head.mesh = cone
	head.position.y = arrow_length * 0.9
	
	# Material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = AXIS_COLORS[axis]
	material.emission_enabled = true
	material.emission = AXIS_COLORS[axis] * 0.3
	material.emission_energy = 0.5
	
	shaft.material_override = material
	head.material_override = material
	
	FloodgateController.universal_add_child(shaft, arrow_container)
	FloodgateController.universal_add_child(head, arrow_container)
	
	# Rotate based on axis
	match axis:
		"x":
			arrow_container.rotation.z = -PI/2
		"y":
			pass  # Y is already up
		"z":
			arrow_container.rotation.x = PI/2
	
	# Add collision for interaction
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.height = arrow_length
	shape.radius = arrow_thickness * 3.0  # Larger hit area
	collision.shape = shape
	collision.position.y = arrow_length * 0.5
	FloodgateController.universal_add_child(collision, area)
	
	# Apply same rotation to collision
	match axis:
		"x":
			area.rotation.z = -PI/2
		"z":
			area.rotation.x = PI/2
	
	FloodgateController.universal_add_child(arrow_container, arrow_being)
	FloodgateController.universal_add_child(area, arrow_being)
	
	# Store references
	arrow_being.manifestation = arrow_container
	arrow_being.set_property("interaction_area", area)

func _setup_plane_visual(plane_being: Node3D, plane: String) -> void:
	"""Setup plane visual for 2-axis translation"""
	
	var plane_mesh = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = Vector2(arrow_length * 0.3, arrow_length * 0.3)
	plane_mesh.mesh = quad
	
	# Material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = AXIS_COLORS[plane]
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	plane_mesh.material_override = material
	
	# Position and rotate based on plane
	match plane:
		"xy":
			plane_mesh.position = Vector3(arrow_length * 0.3, arrow_length * 0.3, 0)
		"xz":
			plane_mesh.rotation.x = PI/2
			plane_mesh.position = Vector3(arrow_length * 0.3, 0, arrow_length * 0.3)
		"yz":
			plane_mesh.rotation.y = PI/2
			plane_mesh.position = Vector3(0, arrow_length * 0.3, arrow_length * 0.3)
	
	FloodgateController.universal_add_child(plane_mesh, plane_being)
	plane_being.manifestation = plane_mesh

func _setup_ring_visual(ring_being: Node3D, axis: String) -> void:
	"""Setup ring visual for rotation gizmo"""
	
	# Create torus for rotation
	var ring_mesh = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = arrow_length * 0.8
	torus.outer_radius = arrow_length * 0.85
	ring_mesh.mesh = torus
	
	# Material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = AXIS_COLORS[axis]
	material.emission_enabled = true
	material.emission = AXIS_COLORS[axis] * 0.3
	ring_mesh.material_override = material
	
	# Rotate based on axis
	match axis:
		"x":
			ring_mesh.rotation.z = PI/2
		"y":
			pass  # Y ring is already correct
		"z":
			ring_mesh.rotation.x = PI/2
	
	# Add collision for interaction
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.height = arrow_thickness * 2.0  # Thick enough to click
	shape.radius = arrow_length * 0.825   # Match the ring size
	collision.shape = shape
	FloodgateController.universal_add_child(collision, area)
	
	# Apply same rotation to collision
	match axis:
		"x":
			area.rotation.z = PI/2
		"y":
			pass  # Y ring collision is already correct
		"z":
			area.rotation.x = PI/2
	
	FloodgateController.universal_add_child(ring_mesh, ring_being)
	FloodgateController.universal_add_child(area, ring_being)
	ring_being.manifestation = ring_mesh
	ring_being.set_property("interaction_area", area)

func _setup_scale_visual(scale_being: Node3D, axis: String) -> void:
	"""Setup cube visual for scale gizmo"""
	
	var scale_mesh = MeshInstance3D.new()
	var cube = BoxMesh.new()
	cube.size = Vector3.ONE * arrow_thickness * 2.0
	scale_mesh.mesh = cube
	
	# Material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = AXIS_COLORS[axis]
	material.emission_enabled = true
	material.emission = AXIS_COLORS[axis] * 0.3
	scale_mesh.material_override = material
	
	# Position at end of axis
	match axis:
		"x":
			scale_mesh.position.x = arrow_length
		"y":
			scale_mesh.position.y = arrow_length
		"z":
			scale_mesh.position.z = arrow_length
	
	# Add collision for interaction
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3.ONE * arrow_thickness * 3.0  # Larger hit area
	collision.shape = shape
	FloodgateController.universal_add_child(collision, area)
	
	# Position collision same as mesh
	match axis:
		"x":
			area.position.x = arrow_length
		"y":
			area.position.y = arrow_length
		"z":
			area.position.z = arrow_length
	
	FloodgateController.universal_add_child(scale_mesh, scale_being)
	FloodgateController.universal_add_child(area, scale_being)
	scale_being.manifestation = scale_mesh
	scale_being.set_property("interaction_area", area)

func _setup_uniform_scale_visual(uniform_being: Node3D) -> void:
	"""Setup center cube for uniform scaling"""
	
	var scale_mesh = MeshInstance3D.new()
	var cube = BoxMesh.new()
	cube.size = Vector3.ONE * arrow_thickness * 3.0
	scale_mesh.mesh = cube
	
	# Material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = AXIS_COLORS["uniform"]
	material.emission_enabled = true
	material.emission = AXIS_COLORS["uniform"] * 0.5
	scale_mesh.material_override = material
	
	# Add collision for interaction (larger for easier clicking)
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3.ONE * arrow_thickness * 4.0  # Even larger hit area
	collision.shape = shape
	FloodgateController.universal_add_child(collision, area)
	
	FloodgateController.universal_add_child(scale_mesh, uniform_being)
	FloodgateController.universal_add_child(area, uniform_being)
	uniform_being.manifestation = scale_mesh
	uniform_being.set_property("interaction_area", area)

func _setup_gizmo_interaction(gizmo_being: Node3D, axis: String, mode: String) -> void:
	"""Setup interaction for gizmo components"""
	
	# The gizmo beings will respond to mouse interaction
	gizmo_being.set_meta("gizmo_axis", axis)
	gizmo_being.set_meta("gizmo_mode", mode)
	gizmo_being.set_meta("is_gizmo", true)
	
	# Add to gizmo group for easy detection
	gizmo_being.add_to_group("gizmo_components")
	
	# Each gizmo being knows how to respond to being selected
	gizmo_being.set_property("on_select", func(): 
		_on_gizmo_selected(gizmo_being, axis, mode)
	)


func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	if not is_active or not target_object:
		return
	
	# Update gizmo position to follow target
	_update_gizmo_position()
	
	# Handle dragging - improved with better mouse tracking
	if is_dragging:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_handle_drag()
		else:
			# Mouse released
			_end_drag()

func _update_gizmo_position() -> void:
	"""Update gizmo position to match target object"""
	if target_object:
		# Get the object's bounding box to position gizmo better
		var offset = Vector3.ZERO
		
		# Try to find the object's bounds
		var mesh_instance = _find_mesh_instance(target_object)
		if mesh_instance and mesh_instance.mesh:
			var aabb = mesh_instance.mesh.get_aabb()
			# Position gizmo at the bottom of the object instead of center
			offset.y = aabb.position.y  # Move to bottom
		
		global_position = target_object.global_position + offset + manual_offset

func _find_mesh_instance(node: Node) -> MeshInstance3D:
	"""Find the first MeshInstance3D in the node or its children"""
	if node is MeshInstance3D:
		return node
	
	for child in node.get_children():
		var result = _find_mesh_instance(child)
		if result:
			return result
	
	return null

func _handle_drag() -> void:
	"""Handle dragging interaction"""
	if not target_object:
		return
	
	# Get camera for mouse projection
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Get mouse position and project to 3D space
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	# Project movement onto the constrained axis
	var movement_delta = Vector3.ZERO
	var sensitivity = 0.01
	
	match drag_mode:
		"translate":
			match drag_axis:
				"x":
					movement_delta.x = (mouse_pos.x - get_viewport().size.x * 0.5) * sensitivity
				"y":
					movement_delta.y = -(mouse_pos.y - get_viewport().size.y * 0.5) * sensitivity
				"z":
					movement_delta.z = -(mouse_pos.y - get_viewport().size.y * 0.5) * sensitivity
				"xy":
					movement_delta.x = (mouse_pos.x - get_viewport().size.x * 0.5) * sensitivity
					movement_delta.y = -(mouse_pos.y - get_viewport().size.y * 0.5) * sensitivity
				"xz":
					movement_delta.x = (mouse_pos.x - get_viewport().size.x * 0.5) * sensitivity
					movement_delta.z = -(mouse_pos.y - get_viewport().size.y * 0.5) * sensitivity
				"yz":
					movement_delta.y = (mouse_pos.x - get_viewport().size.x * 0.5) * sensitivity
					movement_delta.z = -(mouse_pos.y - get_viewport().size.y * 0.5) * sensitivity
			
			# Apply movement to target object
			target_object.global_position += movement_delta
			
		"rotate":
			var rotation_delta = Vector3.ZERO
			var rot_sensitivity = 0.005
			match drag_axis:
				"x":
					rotation_delta.x = (mouse_pos.y - get_viewport().size.y * 0.5) * rot_sensitivity
				"y":
					rotation_delta.y = (mouse_pos.x - get_viewport().size.x * 0.5) * rot_sensitivity
				"z":
					rotation_delta.z = (mouse_pos.x - get_viewport().size.x * 0.5) * rot_sensitivity
			
			target_object.rotation += rotation_delta
			
		"scale":
			var scale_delta = 1.0 + (mouse_pos.y - get_viewport().size.y * 0.5) * 0.001
			scale_delta = max(0.1, scale_delta)  # Prevent negative scale
			
			match drag_axis:
				"x":
					target_object.scale.x = scale_delta
				"y":
					target_object.scale.y = scale_delta
				"z":
					target_object.scale.z = scale_delta
				"uniform":
					target_object.scale = Vector3(scale_delta, scale_delta, scale_delta)
	
	transform_updated.emit(movement_delta)

func set_mode(mode: String) -> void:
	"""Switch between translate, rotate, scale modes"""
	current_mode = mode
	
	# Show/hide appropriate gizmos
	for being in arrow_beings.values():
		being.visible = (mode == "translate")
	for being in plane_beings.values():
		being.visible = (mode == "translate")
	for being in rotation_beings.values():
		being.visible = (mode == "rotate")
	for being in scale_beings.values():
		being.visible = (mode == "scale")
	
	print("[UniversalGizmoSystem] Mode set to: ", mode)

# Console commands
func _ready_commands() -> void:
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("gizmo", _cmd_gizmo, "Control Universal Gizmo")
		console.register_command("gizmo_scale", _cmd_gizmo_scale, "Set gizmo scale")
		console.register_command("gizmo_offset", _cmd_gizmo_offset, "Set gizmo Y offset")

func _cmd_gizmo(args: Array) -> String:
	if args.is_empty():
		return "Usage: gizmo <show|hide|mode|target> [args]"
	
	match args[0]:
		"show":
			visible = true
			if current_mode.is_empty():
				current_mode = "translate"
			set_mode(current_mode)
			return "Gizmo shown (mode: " + current_mode + ")"
		"hide":
			visible = false
			return "Gizmo hidden"
		"status":
			var status = "Gizmo Status:\n"
			status += "  Visible: " + str(visible) + "\n"
			status += "  Active: " + str(is_active) + "\n"
			status += "  Mode: " + current_mode + "\n"
			status += "  Target: " + (target_object.name if target_object else "None") + "\n"
			status += "  Position: " + str(global_position) + "\n"
			status += "  Scale: " + str(scale) + "\n"
			status += "  Arrow beings: " + str(arrow_beings.size()) + "\n"
			# Check visibility of components
			var visible_count = 0
			for being in arrow_beings.values():
				if being and being.visible:
					visible_count += 1
			status += "  Visible arrows: " + str(visible_count)
			return status
		"mode":
			if args.size() > 1:
				set_mode(args[1])
				return "Gizmo mode: " + args[1]
			return "Modes: translate, rotate, scale"
		"target":
			if args.size() > 1:
				var target_name = args[1]
				var obj = _find_object_by_name(target_name)
				if obj:
					attach_to_object(obj)
					visible = true  # Ensure gizmo is visible
					print("[UniversalGizmoSystem] Debug - Gizmo state:")
					print("  Position: ", global_position)
					print("  Visible: ", visible)
					print("  Mode: ", current_mode)
					print("  Scale: ", scale)
					return "Gizmo attached to: " + obj.name + " (visible: " + str(visible) + ", mode: " + current_mode + ")"
				else:
					return "Target not found: " + target_name
			return "Usage: gizmo target <object_name>"
		_:
			return "Unknown command"

func _find_object_by_name(object_name: String) -> Node3D:
	"""Find object by name in the scene tree"""
	# First try finding in spawned objects group
	for obj in get_tree().get_nodes_in_group("spawned_objects"):
		if obj.name == object_name:
			return obj
	
	# Then try universal beings group
	for obj in get_tree().get_nodes_in_group("universal_beings"):
		if obj.name == object_name:
			return obj
	
	# Finally search all Node3D objects in the scene
	var main_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	return _recursive_find_by_name(main_scene, object_name)

func _recursive_find_by_name(node: Node, target_name: String) -> Node3D:
	"""Recursively search for node by name"""
	if node.name == target_name and node is Node3D:
		return node as Node3D
	
	for child in node.get_children():
		var result = _recursive_find_by_name(child, target_name)
		if result:
			return result
	
	return null

# ========== MOUSE INTEGRATION ==========

func _connect_to_mouse_system() -> void:
	"""Connect to the mouse interaction system to detect gizmo clicks"""
	# Try multiple paths to find the mouse system
	var mouse_system = null
	var paths_to_try = [
		"/root/MouseInteractionSystem",  # As autoload
		"/root/MainGame/MouseInteractionSystem",  # As child of MainGame
		"//MouseInteractionSystem"  # Search from root
	]
	
	for path in paths_to_try:
		mouse_system = get_node_or_null(path)
		if mouse_system:
			print("[UniversalGizmoSystem] Found MouseInteractionSystem at: " + path)
			break
	
	if not mouse_system:
		# Try to find it in the main game controller
		var main_game = get_tree().get_first_node_in_group("main_game")
		if not main_game:
			# Find the main scene root
			main_game = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
		
		if main_game:
			mouse_system = main_game.get_node_or_null("MouseInteractionSystem")
			if mouse_system:
				print("[UniversalGizmoSystem] Found MouseInteractionSystem as child of: " + main_game.name)
	
	if not mouse_system:
		print("[UniversalGizmoSystem] Warning: MouseInteractionSystem not found - gizmo clicking disabled")
		print("[UniversalGizmoSystem] Tip: Use 'gizmo target <object_name>' command to attach gizmo manually")
		return
	
	# Connect to mouse system's input events
	# We need to integrate with the mouse system's click detection
	# Since we can't override methods, we'll use a different approach
	
	# Store reference for later use
	set_meta("mouse_system", mouse_system)
	
	# Enable our own mouse processing to work alongside the mouse system
	set_process_unhandled_input(true)
	
	print("[UniversalGizmoSystem] Connected to mouse interaction system")
	print("[UniversalGizmoSystem] Gizmo components will intercept clicks when active")

func _is_gizmo_component(obj: Node) -> bool:
	"""Check if clicked object is part of a gizmo"""
	if not obj:
		return false
	
	# Check if object itself is a gizmo component
	if obj.is_in_group("gizmo_components"):
		return true
	
	# Check if parent is a gizmo component
	var current = obj
	while current:
		if current.is_in_group("gizmo_components"):
			return true
		
		# Also check by metadata
		if current.has_meta("is_gizmo") and current.get_meta("is_gizmo"):
			return true
		
		current = current.get_parent()
		
		# Don't go past the gizmo system itself
		if current == self:
			break
	
	return false

func _handle_gizmo_click(obj: Node) -> void:
	"""Handle clicking on a gizmo component"""
	print("[UniversalGizmoSystem] Gizmo component clicked: ", obj.name)
	
	# Find the gizmo being that was clicked
	var gizmo_being = _find_gizmo_being(obj)
	if not gizmo_being:
		print("[UniversalGizmoSystem] Could not find gizmo being for clicked object")
		return
	
	# Get axis and mode from the gizmo being
	var axis = gizmo_being.get_property("gizmo_axis") if gizmo_being.has_method("get_property") else ""
	if not axis:
		axis = gizmo_being.get_meta("gizmo_axis", "")
	
	var mode = current_mode  # Use current gizmo mode instead of stored mode
	
	if axis:
		print("[UniversalGizmoSystem] Activating gizmo: ", axis, " mode: ", mode)
		_on_gizmo_selected(gizmo_being, axis, mode)
	else:
		print("[UniversalGizmoSystem] Gizmo missing axis metadata")

func _find_gizmo_being(clicked_obj: Node) -> Node3D:
	"""Find the Universal Being gizmo component from clicked object"""
	var current = clicked_obj
	
	# Walk up the tree to find the gizmo Universal Being
	while current:
		# Check if this is a gizmo Universal Being
		if current.has_meta("is_gizmo") and current.get_meta("is_gizmo"):
			return current as Node3D
		
		# Check if this is in the gizmo_components group
		if current.is_in_group("gizmo_components"):
			return current as Node3D
		
		current = current.get_parent()
		
		# Stop at the gizmo system
		if current == self:
			break
	
	return null
# Temporary file with gizmo drag methods to add

func _on_gizmo_selected(gizmo_being: Node3D, axis: String, mode: String) -> void:
	"""Called when a gizmo component is selected"""
	if not target_object:
		return
	
	# Start drag operation
	is_dragging = true
	drag_start_pos = get_viewport().get_mouse_position()
	drag_mode = mode
	drag_axis = axis
	
	# Store initial state
	initial_transform = target_object.transform
	
	print("[UniversalGizmoSystem] Started dragging - mode: ", mode, " axis: ", axis)

func _update_drag(mouse_pos: Vector2) -> void:
	"""Update drag operation based on mouse movement"""
	if not is_dragging or not target_object:
		return
	
	var delta = mouse_pos - drag_start_pos
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Calculate drag amount based on mode
	match drag_mode:
		"translate":
			_apply_translation(delta, camera)
		"rotate":
			_apply_rotation(delta)
		"scale":
			_apply_scale(delta)

func _end_drag() -> void:
	"""End the current drag operation"""
	if not is_dragging:
		return
	
	is_dragging = false
	print("[UniversalGizmoSystem] Drag ended")
	
	# Emit completion signal
	transform_completed.emit()
	
	# Notify console about the transformation
	var console = get_node_or_null("/root/ConsoleManager")
	if console and target_object:
		var msg = "Gizmo " + drag_mode + " on " + drag_axis + " axis complete"
		console._print_to_console(msg)

func _apply_translation(delta: Vector2, camera: Camera3D) -> void:
	"""Apply translation based on mouse delta"""
	if not target_object:
		return
	
	# Get distance from camera to object for scaling movement
	var cam_pos = camera.global_position
	var obj_pos = target_object.global_position
	var distance = cam_pos.distance_to(obj_pos)
	
	# Scale sensitivity based on distance (closer = less movement, farther = more)
	var base_sensitivity = 0.001
	var sensitivity = base_sensitivity * (distance / 1.0)
	
	# Calculate proper axis-aligned movement
	var movement = Vector3.ZERO
	
	# Use world axes, not camera axes, for predictable movement
	match drag_axis:
		"x":
			# X axis (red) - horizontal screen movement moves along world X
			movement.x = delta.x * sensitivity
		"y":
			# Y axis (green) - vertical screen movement moves along world Y
			movement.y = -delta.y * sensitivity
		"z":
			# Z axis (blue) - vertical screen movement moves along world Z
			# (since we can't move "into" the screen with 2D mouse)
			movement.z = -delta.y * sensitivity
		"xy":
			movement.x = delta.x * sensitivity
			movement.y = -delta.y * sensitivity
		"xz":
			movement.x = delta.x * sensitivity
			movement.z = -delta.y * sensitivity
		"yz":
			movement.y = -delta.y * sensitivity
			movement.z = delta.x * sensitivity
	
	# Apply the movement
	target_object.global_position += movement
	_update_gizmo_position()

func _apply_rotation(delta: Vector2) -> void:
	"""Apply rotation based on mouse delta"""
	if not target_object:
		return
	
	var rotation_speed = 0.01
	var total_delta = delta  # Delta from drag start, not just this frame
	
	# Calculate total rotation from start of drag
	var rotation_delta = Vector3.ZERO
	match drag_axis:
		"x":
			rotation_delta.x = -total_delta.y * rotation_speed
		"y":
			rotation_delta.y = total_delta.x * rotation_speed
		"z":
			rotation_delta.z = total_delta.x * rotation_speed
	
	# Apply rotation relative to initial transform
	if initial_transform:
		var initial_rotation = initial_transform.basis.get_euler()
		target_object.rotation = initial_rotation + rotation_delta
	else:
		# Fallback if no initial transform stored
		target_object.rotation = rotation_delta
	
	_update_gizmo_position()

func _apply_scale(delta: Vector2) -> void:
	"""Apply scale based on mouse delta"""
	if not target_object:
		return
	
	var scale_speed = 0.005  # Reduced for better control
	var total_delta = delta  # Delta from drag start
	var avg_delta = (total_delta.x - total_delta.y) * scale_speed
	
	# Get initial scale
	var initial_scale = Vector3.ONE
	if initial_transform:
		initial_scale = initial_transform.basis.get_scale()
	
	# Calculate new scale relative to initial
	var new_scale = initial_scale
	match drag_axis:
		"x":
			new_scale.x = initial_scale.x * (1.0 + avg_delta)
		"y":
			new_scale.y = initial_scale.y * (1.0 + avg_delta)
		"z":
			new_scale.z = initial_scale.z * (1.0 + avg_delta)
		"uniform":
			var scale_factor = 1.0 + avg_delta
			new_scale = initial_scale * scale_factor
	
	# Prevent negative scaling
	new_scale.x = max(0.1, new_scale.x)
	new_scale.y = max(0.1, new_scale.y)
	new_scale.z = max(0.1, new_scale.z)
	
	# Apply the scale
	target_object.scale = new_scale
	_update_gizmo_position()

func _cmd_gizmo_scale(args: Array) -> String:
	"""Set the scale of the gizmo"""
	if args.is_empty():
		return "Current gizmo scale: " + str(gizmo_scale) + "\nUsage: gizmo_scale <value>"
	
	var new_scale = float(args[0])
	if new_scale <= 0:
		return "Scale must be positive!"
	
	gizmo_scale = new_scale
	
	# Update all gizmo component scales
	scale = Vector3.ONE * gizmo_scale
	
	return "Gizmo scale set to: " + str(gizmo_scale)

func _cmd_gizmo_offset(args: Array) -> String:
	"""Set the Y offset for the gizmo position"""
	if args.is_empty():
		return "Current gizmo offset: " + str(manual_offset) + "\nUsage: gizmo_offset <y_value> or gizmo_offset <x> <y> <z>"
	
	if args.size() == 1:
		# Just Y offset
		manual_offset.y = float(args[0])
	elif args.size() >= 3:
		# Full vector offset
		manual_offset.x = float(args[0])
		manual_offset.y = float(args[1])
		manual_offset.z = float(args[2])
	
	# Update position immediately
	_update_gizmo_position()
	
	return "Gizmo offset set to: " + str(manual_offset)

func _assign_to_interface_layer() -> void:
	"""Assign gizmo to interface layer for always-visible rendering"""
	var layer_system = get_tree().get_first_node_in_group("layer_system")
	if layer_system and layer_system.has_method("add_to_layer"):
		# Add main gizmo system to interface layer
		layer_system.add_to_layer(self, 1)  # 1 = INTERFACE layer
		
		# Add all gizmo components to interface layer
		for beings_dict in [arrow_beings, plane_beings, rotation_beings, scale_beings]:
			for being in beings_dict.values():
				if being and is_instance_valid(being):
					layer_system.add_to_layer(being, 1)
		
		print("[UniversalGizmoSystem] ✨ Assigned to interface layer - now always visible!")