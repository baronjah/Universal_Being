# ==================================================
# SCRIPT NAME: mouse_interaction_system.gd
# DESCRIPTION: Handle mouse clicking on objects and show debug info
# PURPOSE: Allow clicking any object in the scene to inspect it
# CREATED: 2025-05-24 - Interactive object inspection
# ==================================================

extends UniversalBeingBase
# UI Elements
var debug_panel: PanelContainer = null
var debug_label: RichTextLabel = null
var selected_object: Node3D = null

# Raycast for mouse picking
var camera: Camera3D = null
var raycast_length: float = 1000.0

# Combo detection system (from Eden)
var combo_array: Array = []
var mouse_status: Vector2 = Vector2.ZERO
var highlighted_colliders: Array = []

# Visual feedback colors
var hover_color: Color = Color(1, 1, 0, 0.8)  # Yellow for hover
var click_color: Color = Color(0, 1, 0, 0.8)  # Green for click
var hold_color: Color = Color(1, 0, 0, 0.8)   # Red for hold

# Eden action system
var action_system: EdenActionSystem = null

# Shape gesture system
var gesture_system: ShapeGestureSystem = null
var is_gesture_mode: bool = false

# Debug panel settings
var panel_margin: int = 20
var panel_width: int = 350
var panel_min_height: int = 200
var panel_offset_from_camera: Vector2 = Vector2(20, 100)  # Offset from top-left of viewport
var panel_follows_camera: bool = true  # Toggle for camera-following behavior

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[MouseInteraction] Initializing mouse interaction system...")
	
	# Find camera
	_find_camera()
	
	# Create debug UI
	_create_debug_panel()
	
	# Initialize Eden action system - temporarily disabled
	print("[MouseInteraction] Eden systems temporarily disabled - fixing compilation errors...")
	
	# var action_script = load("res://scripts/core/eden_action_system.gd")
	# if action_script:
	#	action_system = Node.new()
	#	action_system.set_script(action_script)
	#	action_system.name = "ActionSystem"
	#	add_child(action_system)
	#	
	#	# Connect action system signals
	#	action_system.action_started.connect(_on_action_started)
	#	action_system.action_completed.connect(_on_action_completed)
	#	action_system.combo_triggered.connect(_on_combo_triggered)
	
	# Initialize shape gesture system - temporarily disabled
	# var gesture_script = load("res://scripts/core/shape_gesture_system.gd")
	# if gesture_script:
	#	gesture_system = Node.new()
	#	gesture_system.set_script(gesture_script)
	#	gesture_system.name = "GestureSystem"
	#	add_child(gesture_system)
	#	
	#	# Connect gesture signals
	#	gesture_system.shape_detected.connect(_on_shape_detected)
	#	gesture_system.spell_gesture_recognized.connect(_on_spell_gesture)
	
	# Enable input processing
	set_process_unhandled_input(true)
	set_process(true)
	
	print("[MouseInteraction] Ready - Click any object to inspect it!")

# Exit tree logic integrated into Pentagon sewers
func pentagon_sewers() -> void:
	super.pentagon_sewers()
	# Tree exit cleanup
	# Clean up debug panel from viewport when this node is removed
	if debug_panel:
		var canvas_layer = debug_panel.get_parent()
		if canvas_layer and canvas_layer.get_parent():
			canvas_layer.get_parent().remove_child.call_deferred(canvas_layer)
			canvas_layer.queue_free()

func _find_camera() -> void:
	# Look for the main camera
	var viewport = get_viewport()
	if viewport:
		camera = viewport.get_camera_3d()
		if camera:
			print("[MouseInteraction] Found camera: " + camera.name)
		else:
			push_error("[MouseInteraction] No camera found in viewport!")

func _create_debug_panel() -> void:
	# Create main panel
	debug_panel = PanelContainer.new()
	debug_panel.name = "DebugPanel"
	debug_panel.visible = false
	
	# Set panel style
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	panel_style.border_color = Color(0.3, 0.3, 0.3, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(5)
	panel_style.set_content_margin_all(10)
	debug_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Create label for debug info
	debug_label = RichTextLabel.new()
	debug_label.name = "DebugLabel"
	debug_label.bbcode_enabled = true
	debug_label.fit_content = true
	debug_label.custom_minimum_size = Vector2(panel_width - 20, panel_min_height)
	
	# Add label to panel
	FloodgateController.universal_add_child(debug_label, debug_panel)
	
	# Add panel directly to the main viewport's GUI layer - this is the key fix!
	var main_viewport = get_viewport()
	if main_viewport:
		# Create canvas layer with high layer number to ensure it's on top
		var canvas_layer = CanvasLayer.new()
		canvas_layer.name = "DebugCanvasLayer"
		canvas_layer.layer = 100  # High layer to be on top of everything
		
		# Add to viewport directly, not to this node - use deferred to avoid setup conflict
		main_viewport.call_deferred("add_child", canvas_layer)
		canvas_layer.call_deferred("add_child", debug_panel)
		
		print("[MouseInteraction] Debug panel added to viewport GUI layer")
	else:
		push_error("[MouseInteraction] Could not find main viewport for debug panel")
	
	# Position panel at fixed screen position
	debug_panel.position = panel_offset_from_camera
	debug_panel.size = Vector2(panel_width, panel_min_height)

# Unhandled input integrated into Pentagon Architecture
func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Unhandled input logic
	# Handle gesture mode toggle (hold Shift)
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			is_gesture_mode = event.pressed
			if is_gesture_mode:
				print("[MouseInteraction] Gesture mode ON - Draw shapes to cast spells!")
			else:
				print("[MouseInteraction] Gesture mode OFF")
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_status.x = 1 if event.pressed else 0
			
			# Gesture mode temporarily disabled
			# if is_gesture_mode and gesture_system:
			#	# Gesture mode - track shapes
			#	if event.pressed:
			#		gesture_system.start_gesture(event.position)
			#	else:
			#		gesture_system.end_gesture()
			# else:
			
			# Normal click mode
			if event.pressed:
				_handle_mouse_click(event.position)
			else:
				_handle_mouse_release(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_status.y = 1 if event.pressed else 0
			if event.pressed:
				_clear_selection()
	elif event is InputEventMouseMotion:
		# Gesture mode temporarily disabled
		# if is_gesture_mode and gesture_system and mouse_status.x > 0:
		#	# Drawing gesture
		#	gesture_system.add_gesture_point(event.position)
		# else:
		
		# Normal hover
		_handle_mouse_hover(event.position)

func _handle_mouse_click(mouse_pos: Vector2) -> void:
	if not camera:
		return
	
	# Create ray from camera
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * raycast_length
	
	# Perform raycast
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 0xFFFFFFFF  # Check all layers
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.exclude = []  # Don't exclude anything
	
	print("[MouseInteraction] Raycasting from ", from, " to direction ", camera.project_ray_normal(mouse_pos))
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		print("[MouseInteraction] Hit object: ", collider.name, " (", collider.get_class(), ")")
		print("[MouseInteraction] Hit position: ", result.position)
		_select_object(collider)
		# Add to combo detection
		combo_checker(collider, 1)
		# Visual feedback
		highlight_collision_shape(collider, click_color)
		# Eden action system integration - temporarily disabled
		# if action_system:
		#	action_system.process_combo_input("click", collider)
	else:
		print("[MouseInteraction] No collision detected")
		_clear_selection()

func _select_object(obj: Node) -> void:
	# Find the root object (might be a child collider)
	var target = obj
	
	# First, check if this object has a UniversalBeing parent
	var current = obj
	while current:
		var parent = current.get_parent()
		if parent and parent.has_method("get_script") and parent.get_script():
			var script_path = parent.get_script().resource_path
			if "universal_being" in script_path.to_lower():
				target = parent
				print("[MouseInteraction] Found UniversalBeing parent: ", parent.name)
				break
		
		# Also check if parent is a recognized spawned object
		if parent and parent.is_in_group("spawned_objects"):
			target = parent
			break
			
		# Don't go past the scene root
		if not parent or parent == get_tree().root or parent.name == "MainGame":
			break
			
		current = parent
	
	selected_object = target as Node3D
	if selected_object:
		print("[MouseInteraction] Selected: " + selected_object.name)
		
		# Show click feedback in console immediately
		var console = get_node_or_null("/root/ConsoleManager")
		if console and console.has_method("_print_to_console"):
			console._print_to_console("🔍 CLICKED: " + selected_object.name + " (" + selected_object.get_class() + ")")
			console._print_to_console("  Position: " + str(selected_object.position))
			console._print_to_console("  Type: " + str(selected_object.get_meta("object_type", "unknown")))
			console._print_to_console("  Use 'inspect_by_name " + selected_object.name + "' for details")
		
		# Try to use Enhanced Object Inspector
		var inspector = get_node_or_null("/root/EnhancedObjectInspector")
		if not inspector:
			inspector = get_tree().get_first_node_in_group("object_inspector")
		
		if inspector and inspector.has_method("inspect_object"):
			inspector.inspect_object(selected_object)
			print("[MouseInteraction] Sent to Enhanced Object Inspector")
		else:
			# Fallback to built-in debug panel
			_update_debug_panel()
			debug_panel.visible = true

func _clear_selection() -> void:
	selected_object = null
	debug_panel.visible = false
	
	# Also close enhanced inspector
	var inspector = get_node_or_null("/root/EnhancedObjectInspector")
	if inspector and inspector.has_method("_on_close_pressed"):
		inspector._on_close_pressed()
	
	print("[MouseInteraction] Selection cleared")

func _update_debug_panel() -> void:
	if not selected_object or not debug_label:
		return
	
	var info = "[center][b]Object Inspector[/b][/center]\n\n"
	
	# Basic info
	info += "[color=yellow]Name:[/color] " + selected_object.name + "\n"
	info += "[color=yellow]Type:[/color] " + selected_object.get_class() + "\n"
	
	# Position
	var pos = selected_object.global_position
	info += "[color=yellow]Position:[/color] (%.2f, %.2f, %.2f)\n" % [pos.x, pos.y, pos.z]
	
	# Rotation
	var rot = selected_object.rotation_degrees
	info += "[color=yellow]Rotation:[/color] (%.1f°, %.1f°, %.1f°)\n" % [rot.x, rot.y, rot.z]
	
	# Scale
	var scale = selected_object.scale
	info += "[color=yellow]Scale:[/color] (%.2f, %.2f, %.2f)\n" % [scale.x, scale.y, scale.z]
	
	# Physics info if RigidBody3D
	if selected_object is RigidBody3D:
		var rb = selected_object as RigidBody3D
		info += "\n[b]Physics:[/b]\n"
		info += "[color=cyan]Mass:[/color] %.2f kg\n" % rb.mass
		info += "[color=cyan]Linear Velocity:[/color] %.2f m/s\n" % rb.linear_velocity.length()
		info += "[color=cyan]Angular Velocity:[/color] %.2f rad/s\n" % rb.angular_velocity.length()
		info += "[color=cyan]Gravity Scale:[/color] %.2f\n" % rb.gravity_scale
		info += "[color=cyan]Freeze Mode:[/color] " + str(rb.freeze_mode) + "\n"
		
	# Check for custom metadata
	info += "\n[b]Metadata:[/b]\n"
	var meta_list = selected_object.get_meta_list()
	if meta_list.size() > 0:
		for meta_key in meta_list:
			var value = selected_object.get_meta(meta_key)
			info += "[color=green]%s:[/color] %s\n" % [meta_key, str(value)]
	else:
		info += "[color=gray]No metadata[/color]\n"
	
	# Groups
	var groups = selected_object.get_groups()
	if groups.size() > 0:
		info += "\n[b]Groups:[/b] " + ", ".join(groups) + "\n"
	
	# Child count
	var child_count = selected_object.get_child_count()
	if child_count > 0:
		info += "\n[b]Children:[/b] " + str(child_count) + "\n"
		for i in range(min(child_count, 5)):  # Show first 5 children
			var child = selected_object.get_child(i)
			info += "  - " + child.name + " (" + child.get_class() + ")\n"
		if child_count > 5:
			info += "  ... and " + str(child_count - 5) + " more\n"
	
	# Script info
	if selected_object.get_script():
		var script_path = selected_object.get_script().resource_path
		info += "\n[b]Script:[/b]\n" + script_path.get_file() + "\n"
	
	# Update label
	debug_label.text = info

func _update_panel_position() -> void:
	# Keep panel at consistent viewport position (always in screen space)
	if debug_panel:
		debug_panel.position = panel_offset_from_camera
		# Ensure panel stays within viewport bounds
		var viewport_size = get_viewport().get_visible_rect().size
		var panel_size = debug_panel.size
		
		# Clamp position to keep panel visible
		debug_panel.position.x = clamp(debug_panel.position.x, 0, viewport_size.x - panel_size.x)
		debug_panel.position.y = clamp(debug_panel.position.y, 0, viewport_size.y - panel_size.y)

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Update panel position to follow camera
	if debug_panel and panel_follows_camera:
		_update_panel_position()
	
	# Update debug info in real-time
	if selected_object and debug_panel.visible:
		_update_debug_panel()

# Console commands

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func sewers() -> void:
	pentagon_sewers()

func cmd_toggle_debug_panel() -> void:
	if debug_panel:
		debug_panel.visible = !debug_panel.visible
		print("[MouseInteraction] Debug panel " + ("shown" if debug_panel.visible else "hidden"))
		if debug_panel.visible:
			print("[MouseInteraction] Panel position: " + str(debug_panel.position))
			print("[MouseInteraction] Panel size: " + str(debug_panel.size))
	else:
		print("[MouseInteraction] Debug panel not found!")

func cmd_inspect_scene() -> void:
	var all_objects = get_tree().get_nodes_in_group("objects")
	print("[MouseInteraction] Scene contains " + str(all_objects.size()) + " objects:")
	for obj in all_objects:
		print("  - " + obj.name + " at " + str(obj.global_position))

func cmd_set_panel_offset(x: float, y: float) -> void:
	panel_offset_from_camera = Vector2(x, y)
	print("[MouseInteraction] Panel offset set to: " + str(panel_offset_from_camera))

func cmd_toggle_panel_follow() -> void:
	panel_follows_camera = !panel_follows_camera
	print("[MouseInteraction] Panel follow camera: " + str(panel_follows_camera))

# New functions for enhanced interaction

func _handle_mouse_release(mouse_pos: Vector2) -> void:
	# Process combo on release
	var result = _get_object_at_position(mouse_pos)
	if result and result.collider:
		combo_checker(result.collider, 0)
		check_combo_patterns()
		# Eden action system - temporarily disabled
		# if action_system:
		#	action_system.process_combo_input("release", result.collider)

func _handle_mouse_hover(mouse_pos: Vector2) -> void:
	# Visual feedback on hover
	reset_debug_colors()
	var result = _get_object_at_position(mouse_pos)
	if result and result.collider:
		highlight_collision_shape(result.collider, hover_color)

func _get_object_at_position(mouse_pos: Vector2) -> Dictionary:
	if not camera:
		return {}
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * raycast_length
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 0xFFFFFFFF
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	return space_state.intersect_ray(query)

# Visual feedback system (from Eden)

func highlight_collision_shape(collider: Node, color: Color) -> void:
	# Track highlighted collider
	if not collider in highlighted_colliders:
		highlighted_colliders.append(collider)
	
	# Find mesh instances to highlight
	var meshes_to_highlight: Array = []
	
	# Check if collider itself is a MeshInstance3D
	if collider is MeshInstance3D:
		meshes_to_highlight.append(collider)
	
	# Check children for MeshInstance3D
	for child in collider.get_children():
		if child is MeshInstance3D:
			meshes_to_highlight.append(child)
	
	# If no mesh found in children, check parent
	if meshes_to_highlight.is_empty() and collider.get_parent():
		var parent = collider.get_parent()
		if parent is MeshInstance3D:
			meshes_to_highlight.append(parent)
		for sibling in parent.get_children():
			if sibling is MeshInstance3D:
				meshes_to_highlight.append(sibling)
	
	# Apply highlight to all found meshes
	for mesh in meshes_to_highlight:
		# Store original material if not already stored
		if not mesh.has_meta("original_material"):
			var original_mat = mesh.get_surface_override_material(0)
			if not original_mat and mesh.mesh and mesh.mesh.surface_get_material(0):
				original_mat = mesh.mesh.surface_get_material(0)
			mesh.set_meta("original_material", original_mat)
		
		# Create highlight material
		var highlight_material = MaterialLibrary.get_material("default")
		var original = mesh.get_meta("original_material")
		if original and original is StandardMaterial3D:
			# Copy relevant properties from original
			highlight_material.albedo_color = original.albedo_color
			highlight_material.albedo_texture = original.albedo_texture
			highlight_material.metallic = original.metallic
			highlight_material.roughness = original.roughness
		
		# Add emission for highlight
		highlight_material.emission_enabled = true
		highlight_material.emission = color
		highlight_material.emission_energy = 0.5
		highlight_material.rim_enabled = true
		highlight_material.rim = 1.0
		highlight_material.rim_tint = 0.5
		
		# Apply the material
		mesh.set_surface_override_material(0, highlight_material)

func reset_debug_colors() -> void:
	# Reset all highlighted objects
	for collider in highlighted_colliders:
		if is_instance_valid(collider):
			# Check all possible mesh locations
			var meshes_to_reset: Array = []
			
			# Check collider itself
			if collider is MeshInstance3D:
				meshes_to_reset.append(collider)
			
			# Check children
			for child in collider.get_children():
				if child is MeshInstance3D:
					meshes_to_reset.append(child)
			
			# Check parent and siblings
			if collider.get_parent():
				var parent = collider.get_parent()
				if parent is MeshInstance3D:
					meshes_to_reset.append(parent)
				for sibling in parent.get_children():
					if sibling is MeshInstance3D and sibling != collider:
						meshes_to_reset.append(sibling)
			
			# Reset materials
			for mesh in meshes_to_reset:
				if mesh.has_meta("original_material"):
					var original = mesh.get_meta("original_material")
					mesh.set_surface_override_material(0, original)
					mesh.remove_meta("original_material")
				else:
					# Clear any override material
					mesh.set_surface_override_material(0, null)
	
	highlighted_colliders.clear()

# Combo detection system (from Eden)

func combo_checker(node: Node, state: int) -> void:
	var current_time = Time.get_ticks_msec()
	
	# Clear old combos
	if combo_array.is_empty() or (current_time - combo_array[-1][2]) > 1000:
		combo_array = [[node, state, current_time]]
		return
	
	# Add to combo
	combo_array.append([node, state, current_time])
	
	# Keep array size manageable
	if combo_array.size() > 10:
		combo_array.pop_front()
	
	print("[MouseInteraction] Combo: " + format_combo_for_display())

func check_combo_patterns() -> void:
	if combo_array.size() >= 2:
		var last_two = [combo_array[-2][1], combo_array[-1][1]]
		if last_two == [1, 0] and combo_array[-2][0] == combo_array[-1][0]:
			print("[MouseInteraction] COMBO: Click completed on " + combo_array[-1][0].name)
			_on_combo_click(combo_array[-1][0])
	
	if combo_array.size() >= 4:
		# Check for double click
		var times_match = (combo_array[-1][2] - combo_array[-3][2]) < 500
		var same_object = combo_array[-1][0] == combo_array[-3][0]
		var pattern_match = [combo_array[-4][1], combo_array[-3][1], combo_array[-2][1], combo_array[-1][1]] == [1, 0, 1, 0]
		
		if times_match and same_object and pattern_match:
			print("[MouseInteraction] COMBO: Double click on " + combo_array[-1][0].name)
			_on_combo_double_click(combo_array[-1][0])

func format_combo_for_display() -> String:
	var display = []
	for entry in combo_array:
		var node_name = entry[0].name if entry[0] else "unknown"
		var action = "release" if entry[1] == 0 else "press"
		display.append(node_name + ":" + action)
	return str(display)

# Combo action handlers

func _on_combo_click(_node: Node) -> void:
	# Normal click action
	pass

func _on_combo_double_click(node: Node) -> void:
	# Double click - could trigger special action
	if node.is_in_group("objects"):
		print("[MouseInteraction] Double-clicked object: " + node.name)
		# Could trigger pickup, info panel, etc.
		if action_system:
			action_system.queue_action("activate", node)

# Eden action system callbacks

func _on_action_started(action_name: String, target: Node) -> void:
	print("[MouseInteraction] Action started: %s on %s" % [action_name, target.name])
	# Show visual feedback
	if target is Node3D:
		highlight_collision_shape(target, Color(0, 1, 1, 0.8))  # Cyan for active action

func _on_action_completed(action_name: String, result: Dictionary) -> void:
	print("[MouseInteraction] Action completed: %s" % action_name)
	if result.has("data"):
		print("  Result: " + str(result.data))
	# Reset visual feedback
	if result.has("target") and result.target:
		reset_debug_colors()

func _on_combo_triggered(combo_name: String, targets: Array) -> void:
	print("[MouseInteraction] Combo triggered: %s" % combo_name)
	for target in targets:
		print("  - Target: " + target.name)

# Shape gesture callbacks

func _on_shape_detected(shape: String, confidence: float) -> void:
	print("[MouseInteraction] Shape detected: %s (confidence: %.2f)" % [shape, confidence])
	
	# Visual feedback for shape
	_create_shape_feedback(shape)
	
	# Update debug panel
	if debug_panel.visible:
		var info = debug_label.text
		info += "\n[b][color=cyan]Last Shape:[/color][/b] " + shape
		debug_label.text = info

func _on_spell_gesture(spell: String) -> void:
	print("[MouseInteraction] SPELL CAST: %s" % spell)
	
	# Find ragdoll to cast spell
	var ragdoll = _find_dimensional_ragdoll()
	if ragdoll and ragdoll.has_method("cast_spell"):
		ragdoll.cast_spell(spell)
	
	# Visual effect
	_create_spell_effect(spell)

func _create_shape_feedback(shape: String) -> void:
	# TODO: Create visual feedback for drawn shape
	match shape:
		"circle":
			print("  → Protection circle drawn")
		"triangle":
			print("  → Focus triangle drawn")
		"star":
			print("  → Cosmic star drawn")
		"spiral":
			print("  → Dimensional spiral drawn")

func _create_spell_effect(spell: String) -> void:
	# TODO: Create particle effects for spells
	match spell:
		"protection_aura":
			print("  ✨ Protection aura activated!")
		"dimension_portal":
			print("  🌀 Portal opening...")
		"cosmic_power":
			print("  ⭐ Cosmic energy flowing!")

func _find_dimensional_ragdoll() -> Node:
	# Search for dimensional ragdoll system
	var paths = [
		"/root/MainGame/DimensionalRagdollSystem",
		"/root/Main/DimensionalRagdollSystem",
		"//DimensionalRagdollSystem"
	]
	
	for path in paths:
		var system = get_node_or_null(path)
		if system:
			return system
	
	return null
