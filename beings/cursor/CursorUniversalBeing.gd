# ==================================================
# SCRIPT NAME: CursorUniversalBeing_Final.gd
# DESCRIPTION: Final fixed cursor with proper UI layering and small debug collision
# PURPOSE: Cursor that's ALWAYS visible over ALL UI elements
# CREATED: 2025-06-03 - Universal Being Revolution Final Fix
# AUTHOR: JSH + Claude Desktop MCP
# ==================================================

extends UniversalBeing
class_name CursorUniversalBeing

# ===== CURSOR PROPERTIES =====
@export var cursor_color: Color = Color.CYAN
@export var inspect_color: Color = Color(1.0, 0.5, 0.0)
@export var debug_collision_visible: bool = false
@export var enhanced_glow: bool = true
@export var hover_feedback_intensity: float = 0.3

# CONSCIOUSNESS RIPPLES - Make cursor actions visible
var ripple_timer: float = 0.0
var last_click_position: Vector3 = Vector3.ZERO
var consciousness_ripple_radius: float = 2.0
var interaction_history: Array[Dictionary] = []

# Cursor visuals
var cursor_viewport: SubViewport = null
var cursor_container: SubViewportContainer = null
var cursor_shape: Node2D = null
var mode_label: Label = null

# 3D interaction
var ray_cast: RayCast3D = null
var debug_mesh: MeshInstance3D = null

# State
var is_hovering: bool = false
var hovered_object: Node = null
var current_mode: int = 0  # 0 = INTERACT, 1 = INSPECT

# ===== SIGNALS =====
signal cursor_hover_started(object: Node)
signal cursor_hover_ended(object: Node)  
signal cursor_clicked(object: Node, position: Vector2)
signal cursor_inspected(being: UniversalBeing)
signal cursor_mode_changed(mode: int)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "cursor"
	consciousness_level = 4
	being_name = "Universal Cursor Final"
	
	# START IN INSPECT MODE BY DEFAULT!
	current_mode = 1  # INSPECT mode for Universal Beings
	
	print("🎯 CursorUniversalBeingFinal: Pentagon init")
	print("🔍 Starting in INSPECT mode - click Universal Beings to inspect!")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Create cursor on absolute top layer
	create_absolute_top_cursor()
	
	# Create raycast for interaction
	create_minimal_raycast()
	
	# Hide system cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Initialize cursor functionality
	_setup_cursor_signals()
	_configure_interaction_modes()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update cursor to mouse position
	if cursor_shape:
		cursor_shape.global_position = get_viewport().get_mouse_position()
	
	# Update raycast
	update_raycast_detection()
	
	# Update consciousness ripples from cursor movement
	ripple_timer += delta
	if ripple_timer >= 0.5:  # Create movement ripples every 0.5 seconds
		_create_consciousness_ripple("movement")
		ripple_timer = 0.0

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			handle_click()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			toggle_mode()

func pentagon_sewers() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	super.pentagon_sewers()

# ===== ABSOLUTE TOP CURSOR =====

func create_absolute_top_cursor() -> void:
	# Get the root viewport
	var root = get_tree().root
	
	# Create SubViewport for cursor (renders on top of everything)
	cursor_viewport = SubViewport.new()
	cursor_viewport.transparent_bg = true
	cursor_viewport.size = get_viewport().size
	cursor_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	cursor_viewport.gui_disable_input = true  # Don't interfere with window input
	
	# Create container at absolute top
	cursor_container = SubViewportContainer.new()
	cursor_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cursor_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	cursor_container.z_index = 4096  # Maximum safe z-index
	cursor_container.z_as_relative = false  # ABSOLUTE Z!
	
	# IMPORTANT: Make cursor work across windows
	cursor_container.top_level = true  # This makes it independent of parent transforms
	cursor_container.show_behind_parent = false
	
	# Add to root (above Main scene)
	root.add_child(cursor_container)
	cursor_container.add_child(cursor_viewport)
	
	# Move container to top
	root.move_child(cursor_container, root.get_child_count() - 1)
	
	# Create cursor shape in viewport
	cursor_shape = Node2D.new()
	cursor_shape.name = "CursorShape"
	cursor_viewport.add_child(cursor_shape)
	
	# Triangle cursor with enhanced visuals
	var triangle = Polygon2D.new()
	triangle.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(-4, 12),
		Vector2(3, 8)
	])
	triangle.color = cursor_color
	triangle.name = "TriangleCursor"
	cursor_shape.add_child(triangle)
	
	# Enhanced glow effect
	if enhanced_glow:
		var glow = Polygon2D.new()
		glow.polygon = triangle.polygon
		glow.color = Color(cursor_color.r, cursor_color.g, cursor_color.b, 0.3)
		var glow_transform = Transform2D()
		glow_transform = glow_transform.scaled(Vector2(1.5, 1.5))
		glow.transform = glow_transform
		glow.name = "GlowEffect"
		cursor_shape.add_child(glow)
		cursor_shape.move_child(glow, 0)  # Behind triangle
	
	# White outline
	var outline = Line2D.new()
	outline.add_point(Vector2(0, 0))
	outline.add_point(Vector2(-4, 12))
	outline.add_point(Vector2(3, 8))
	outline.add_point(Vector2(0, 0))
	outline.width = 2
	outline.default_color = Color.WHITE
	outline.name = "Outline"
	cursor_shape.add_child(outline)
	
	# Mode indicator with background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.size = Vector2(70, 18)
	bg.position = Vector2(10, -5)
	cursor_shape.add_child(bg)
	
	mode_label = Label.new()
	mode_label.text = "INTERACT"
	mode_label.add_theme_font_size_override("font_size", 10)
	mode_label.position = Vector2(12, -3)
	mode_label.modulate = cursor_color
	cursor_shape.add_child(mode_label)
	
	# Connect viewport resize
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	print("🎯 Cursor created at absolute top layer!")

func _on_viewport_resized() -> void:
	if cursor_viewport:
		cursor_viewport.size = get_viewport().size

# ===== MINIMAL RAYCAST =====

func create_minimal_raycast() -> void:
	# Create raycast for detection only
	ray_cast = RayCast3D.new()
	ray_cast.name = "CursorRay"
	ray_cast.enabled = true
	ray_cast.target_position = Vector3(0, 0, -100)
	add_child(ray_cast)
	
	# Debug visualization (small and optional)
	if debug_collision_visible:
		debug_mesh = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.01  # Tiny!
		sphere.height = 0.02
		debug_mesh.mesh = sphere
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(1, 0, 0, 0.3)
		material.vertex_color_use_as_albedo = true
		debug_mesh.material_override = material
		
		add_child(debug_mesh)
	
	print("🎯 Minimal raycast created")

func update_raycast_detection() -> void:
	var camera = get_viewport().get_camera_3d()
	if not camera or not ray_cast:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100
	
	# Position raycast
	ray_cast.global_position = from
	ray_cast.target_position = ray_cast.to_local(to)
	
	# Update debug mesh if visible
	if debug_mesh and debug_collision_visible:
		debug_mesh.global_position = from + camera.project_ray_normal(mouse_pos) * 2
		debug_mesh.visible = true
	elif debug_mesh:
		debug_mesh.visible = false
	
	# Check for hover
	check_hover()

func check_hover() -> void:
	var new_hover = null
	
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		print("🎯 Raycast hit: %s" % (collider.name if collider else "null"))
		new_hover = find_universal_being(collider)
		if new_hover:
			print("🎯 Found Universal Being: %s" % new_hover.being_name)
		else:
			print("🎯 No Universal Being found in: %s" % (collider.name if collider else "null"))
	
	if new_hover != hovered_object:
		if hovered_object:
			is_hovering = false
			cursor_hover_ended.emit(hovered_object)
		
		hovered_object = new_hover
		
		if hovered_object:
			is_hovering = true
			cursor_hover_started.emit(hovered_object)
		else:
			is_hovering = false
		
		# Update visual feedback
		update_hover_visual()

func update_hover_visual() -> void:
	if not cursor_shape:
		return
	
	var triangle = cursor_shape.get_node_or_null("TriangleCursor")
	var glow = cursor_shape.get_node_or_null("GlowEffect")
	var outline = cursor_shape.get_node_or_null("Outline")
	
	if triangle and triangle is Polygon2D:
		var base_color = cursor_color if current_mode == 0 else inspect_color
		
		if is_hovering and hovered_object:
			# Enhanced hover feedback
			triangle.color = base_color.lightened(hover_feedback_intensity)
			if glow:
				glow.color = Color(base_color.r, base_color.g, base_color.b, 0.6)
			if outline:
				outline.default_color = base_color.lightened(0.5)
		else:
			# Normal state
			triangle.color = base_color
			if glow:
				glow.color = Color(base_color.r, base_color.g, base_color.b, 0.3)
			if outline:
				outline.default_color = Color.WHITE

# ===== INTERACTION =====

func handle_click() -> void:
	print("🖱️ CURSOR CLICK! Hovered object: %s" % (hovered_object.name if hovered_object else "NONE"))
	
	# ENHANCED: Create consciousness ripple on every click
	_enhance_click_feedback()
	
	if not hovered_object:
		print("❌ No object to click on!")
		return
		
	cursor_clicked.emit(hovered_object, get_viewport().get_mouse_position())
	
	if current_mode == 1:  # INSPECT mode
		print("🔍 In inspect mode, looking for Universal Being...")
		var being = find_universal_being(hovered_object)
		if being:
			print("✅ Found Universal Being: %s" % being.being_name)
			inspect_being(being)
		else:
			print("❌ No Universal Being found in object hierarchy!")
	else:
		print("⚠️ Not in inspect mode (mode: %d)" % current_mode)

func inspect_being(being: UniversalBeing) -> void:
	print("🔍 Inspecting: %s" % being.being_name)
	
	# Try bridge first
	var bridge = get_tree().get_nodes_in_group("inspector_bridge").front()
	if bridge and bridge.has_method("inspect_being"):
		bridge.inspect_being(being)
		cursor_inspected.emit(being)
		return
	
	# Create inspector
	var main = get_tree().current_scene
	if main:
		var inspector = main.get_node_or_null("InGameUniversalBeingInspector")
		if not inspector:
			inspector = Control.new()
			inspector.name = "InGameUniversalBeingInspector"
			inspector.set_script(load("res://ui/InGameUniversalBeingInspector.gd"))
			main.add_child(inspector)
		
		if inspector.has_method("inspect_being"):
			inspector.inspect_being(being)
			cursor_inspected.emit(being)

func find_universal_being(node: Node) -> UniversalBeing:
	if not node:
		return null
	
	var current = node
	while current:
		if current is UniversalBeing:
			return current
		current = current.get_parent()
	
	return null

func toggle_mode() -> void:
	current_mode = 1 if current_mode == 0 else 0
	cursor_mode_changed.emit(current_mode)
	
	# Update visuals
	if mode_label:
		mode_label.text = "INSPECT" if current_mode == 1 else "INTERACT"
		mode_label.modulate = inspect_color if current_mode == 1 else cursor_color
	
	# Use enhanced visual system
	update_hover_visual()
	
	print("🎯 Cursor mode: %s" % ("INSPECT" if current_mode == 1 else "INTERACT"))

# ===== API =====

func get_cursor_info() -> Dictionary:
	return {
		"mode": "INSPECT" if current_mode == 1 else "INTERACT",
		"is_hovering": hovered_object != null,
		"hovered_object": hovered_object.name if hovered_object else "none"
	}

func get_cursor_tip_world_position() -> Vector3:
	if ray_cast:
		return ray_cast.global_position
	return Vector3.ZERO

# ===== STATE OVERRIDES =====

func _generate_thought_result() -> Dictionary:
	var result = super._generate_thought_result()
	result.should_create = false
	result.should_evolve = false
	return result

func _attempt_creation() -> void:
	# Cursor is inspection-only, no creation
	pass

func _setup_cursor_signals() -> void:
	"""Connect cursor to game systems"""
	# Connect to console for inspection reports
	var console = get_tree().get_nodes_in_group("console").front()
	if console and cursor_inspected.is_connected(_on_cursor_inspected):
		cursor_inspected.connect(_on_cursor_inspected)

func _configure_interaction_modes() -> void:
	"""Configure cursor interaction capabilities"""
	# Set default to inspect mode for Universal Beings
	current_mode = 1  # INSPECT mode
	update_hover_visual()

func _on_cursor_inspected(being: UniversalBeing) -> void:
	"""Handle Universal Being inspection"""
	var console = get_tree().get_nodes_in_group("console").front()
	if console and console.has_method("add_message"):
		console.add_message("system", "Inspecting: %s (%s)" % [being.being_name, being.being_type])

# ===== CONSCIOUSNESS RIPPLE SYSTEM =====

func _create_consciousness_ripple(interaction_type: String) -> void:
	"""Create visible consciousness ripples from cursor interactions"""
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	
	if camera:
		# Project mouse position to 3D world
		var world_pos = camera.project_ray_origin(mouse_pos)
		var ray_dir = camera.project_ray_normal(mouse_pos)
		
		# Create ripple at interaction point
		var ripple_data = {
			"position": world_pos,
			"type": interaction_type,
			"intensity": 1.0,
			"timestamp": Time.get_ticks_msec()
		}
		
		# Store interaction history
		interaction_history.append(ripple_data)
		if interaction_history.size() > 50:
			interaction_history.pop_front()  # Keep last 50 interactions
		
		# Emit consciousness ripple signal if available
		if has_signal("consciousness_ripple_created"):
			consciousness_ripple_created.emit(world_pos, consciousness_ripple_radius, interaction_type)
		
		# Print consciousness feedback
		if interaction_type == "click":
			print("🎯 Consciousness ripple: %s at %v" % [interaction_type, world_pos])

func _enhance_click_feedback() -> void:
	"""Enhanced visual and consciousness feedback for clicks"""
	last_click_position = get_cursor_tip_world_position()
	_create_consciousness_ripple("click")
	
	# Create larger ripple for clicks
	consciousness_ripple_radius = 3.0
	
	# Add interaction to history with more detail
	var interaction_data = {
		"type": "click",
		"position": last_click_position,
		"mode": "INSPECT" if current_mode == 1 else "INTERACT",
		"target": hovered_object.name if hovered_object else "empty_space",
		"consciousness_level": consciousness_level,
		"timestamp": Time.get_ticks_msec()
	}
	
	print("🎯 Enhanced click: %s" % interaction_data)
