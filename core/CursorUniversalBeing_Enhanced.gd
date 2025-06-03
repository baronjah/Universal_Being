# ==================================================
# SCRIPT NAME: CursorUniversalBeing_Enhanced.gd
# DESCRIPTION: Enhanced Universal Being cursor that always renders on top
# PURPOSE: Ensure cursor visibility over all 2D and 3D interfaces
# CREATED: 2025-06-03 - Universal Being Revolution Enhancement
# AUTHOR: JSH + Claude Desktop MCP
# ==================================================

extends UniversalBeing
class_name CursorUniversalBeingEnhanced

# ===== ENHANCED CURSOR UNIVERSAL BEING =====

## Cursor Properties
var cursor_shape: Node2D = null
var interaction_sphere: Area3D = null
var cursor_tip_position: Vector2 = Vector2.ZERO
var cursor_canvas_layer: CanvasLayer = null
var cursor_3d_viewport: SubViewport = null
var cursor_3d_container: SubViewportContainer = null

## Interaction State
var is_hovering: bool = false
var hovered_object: Node = null
var is_clicking: bool = false

## Cursor Modes
enum CursorMode {
	INTERACT,  # Normal interaction mode (click to activate)
	INSPECT    # Inspection mode (click to inspect)
}
var current_mode: CursorMode = CursorMode.INTERACT
var mode_visual_indicator: Node2D = null

# ===== SIGNALS =====

signal cursor_hover_started(object: Node)
signal cursor_hover_ended(object: Node)
signal cursor_clicked(object: Node, position: Vector2)
signal cursor_dragging(object: Node, delta_position: Vector2)
signal cursor_inspected(being: UniversalBeing)
signal cursor_mode_changed(mode: CursorMode)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	# Call parent init
	super.pentagon_init()
	
	# Set cursor-specific properties
	being_type = "cursor"
	consciousness_level = 4  # High consciousness for precise interaction
	being_name = "Universal Cursor Enhanced"
	visual_layer = 1000  # Very high layer to appear on top of everything
	
	print("🎯 CursorUniversalBeingEnhanced: Pentagon cursor initialization")

func pentagon_ready() -> void:
	# Call parent ready
	super.pentagon_ready()
	
	# Create enhanced cursor system
	create_enhanced_cursor_system()
	
	# Create cursor visual
	create_cursor_triangle()
	
	# Create interaction sphere
	create_interaction_sphere()
	
	# Create mode indicator
	create_mode_indicator()
	
	# Hide system cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	print("🎯 Enhanced Universal Cursor ready! Mode: %s" % ("INSPECT" if current_mode == CursorMode.INSPECT else "INTERACT"))

func pentagon_process(delta: float) -> void:
	# Call parent process
	super.pentagon_process(delta)
	
	# Update cursor position
	update_cursor_position()
	
	# Update 3D viewport for cursor sphere
	update_3d_cursor_viewport()
	
	# Update mode indicator position
	if mode_visual_indicator and cursor_shape:
		mode_visual_indicator.global_position = cursor_shape.global_position
	
	# Process interactions
	process_cursor_interactions(delta)

func pentagon_input(event: InputEvent) -> void:
	# Call parent input
	super.pentagon_input(event)
	
	# Handle cursor-specific input
	process_cursor_input(event)

func pentagon_sewers() -> void:
	# Restore system cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Call parent cleanup
	super.pentagon_sewers()

# ===== ENHANCED CURSOR SYSTEM =====

func create_enhanced_cursor_system() -> void:
	# Create a dedicated CanvasLayer for 2D cursor with maximum layer
	cursor_canvas_layer = CanvasLayer.new()
	cursor_canvas_layer.name = "EnhancedCursorLayer"
	cursor_canvas_layer.layer = 2147483647  # Maximum possible layer for absolute top
	add_child(cursor_canvas_layer)
	
	# Create SubViewport for 3D cursor elements
	cursor_3d_viewport = SubViewport.new()
	cursor_3d_viewport.name = "Cursor3DViewport"
	cursor_3d_viewport.size = get_viewport().size
	cursor_3d_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	cursor_3d_viewport.transparent_bg = true
	
	# Create container for 3D viewport with maximum z_index
	cursor_3d_container = SubViewportContainer.new()
	cursor_3d_container.name = "Cursor3DContainer"
	cursor_3d_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cursor_3d_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	cursor_3d_container.z_index = 2147483647  # Maximum z_index
	cursor_canvas_layer.add_child(cursor_3d_container)
	cursor_3d_container.add_child(cursor_3d_viewport)
	
	# Connect viewport size changes
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	print("🎯 Enhanced cursor system created with maximum rendering priority")

func _on_viewport_size_changed() -> void:
	# Update viewport sizes when window resizes
	if cursor_3d_viewport:
		cursor_3d_viewport.size = get_viewport().size
	if cursor_3d_container:
		cursor_3d_container.set_anchors_preset(Control.PRESET_FULL_RECT)

# ===== CURSOR CREATION =====

func create_cursor_triangle() -> void:
	# Create cursor shape on the enhanced canvas layer
	cursor_shape = Node2D.new()
	cursor_shape.name = "CursorTriangle"
	cursor_shape.z_index = 2147483647  # Maximum z_index
	cursor_canvas_layer.add_child(cursor_shape)
	
	# Create triangle points (tip matches Windows cursor tip position)
	var triangle_points = PackedVector2Array([
		Vector2(0, 0),      # Top tip (interaction point) - matches Windows cursor
		Vector2(-4, 12),    # Bottom left (smaller triangle)
		Vector2(3, 8)       # Bottom right (asymmetric like Windows cursor)
	])
	
	# Create triangle polygon
	var polygon = Polygon2D.new()
	polygon.polygon = triangle_points
	polygon.color = Color.CYAN if current_mode == CursorMode.INTERACT else Color(1.0, 0.5, 0.0)  # Orange for inspect mode
	cursor_shape.add_child(polygon)
	
	# Add outline for visibility with glow effect
	var line = Line2D.new()
	line.add_point(Vector2(0, 0))
	line.add_point(Vector2(-4, 12))
	line.add_point(Vector2(3, 8))
	line.add_point(Vector2(0, 0))
	line.width = 2
	line.default_color = Color.WHITE
	# Add glow effect
	line.modulate = Color(1.2, 1.2, 1.2)
	cursor_shape.add_child(line)
	
	# Set tip position for precise interaction (Windows cursor tip)
	cursor_tip_position = Vector2(0, 0)
	
	print("🎯 Enhanced cursor triangle created with glow")

func create_interaction_sphere() -> void:
	# Create 3D sphere in the 3D viewport
	interaction_sphere = Area3D.new()
	interaction_sphere.name = "InteractionSphere"
	cursor_3d_viewport.add_child(interaction_sphere)
	
	# Create tiny sphere collision shape - same size as visual
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.02  # Very small for precise interaction
	collision_shape.shape = sphere_shape
	interaction_sphere.add_child(collision_shape)
	
	# Create tiny visual sphere
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.02  # Same as collision
	sphere_mesh.height = 0.04  # Diameter = 2 * radius
	mesh_instance.mesh = sphere_mesh
	
	# Make it glow with enhanced visibility
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.CYAN
	material.emission_enabled = true
	material.emission = Color.CYAN
	material.emission_energy = 2.0  # Higher emission for visibility
	material.flags_transparent = true
	material.albedo_color.a = 0.9  # More visible
	material.flags_unshaded = true  # Always bright
	mesh_instance.material_override = material
	
	interaction_sphere.add_child(mesh_instance)
	
	# Add camera to 3D viewport that follows main camera
	var viewport_camera = Camera3D.new()
	viewport_camera.name = "CursorViewportCamera"
	cursor_3d_viewport.add_child(viewport_camera)
	
	# Connect interaction signals
	interaction_sphere.area_entered.connect(_on_area_entered)
	interaction_sphere.area_exited.connect(_on_area_exited)
	interaction_sphere.body_entered.connect(_on_body_entered)
	interaction_sphere.body_exited.connect(_on_body_exited)
	
	print("🎯 Enhanced 3D cursor sphere created in dedicated viewport")

func update_3d_cursor_viewport() -> void:
	# Update viewport camera to match main camera
	var main_camera = get_viewport().get_camera_3d()
	if main_camera and cursor_3d_viewport:
		var viewport_camera = cursor_3d_viewport.get_node_or_null("CursorViewportCamera")
		if viewport_camera:
			viewport_camera.global_transform = main_camera.global_transform
			viewport_camera.fov = main_camera.fov
			viewport_camera.near = main_camera.near
			viewport_camera.far = main_camera.far

# ===== CURSOR BEHAVIOR =====

func update_cursor_position() -> void:
	# Update cursor position to follow mouse
	if cursor_shape:
		var mouse_pos = get_viewport().get_mouse_position()
		cursor_shape.global_position = mouse_pos
		
		# Update 3D sphere position (project to 3D space)
		if interaction_sphere:
			var camera = get_viewport().get_camera_3d()
			if camera:
				# Project 2D mouse to 3D ray
				var ray_origin = camera.project_ray_origin(mouse_pos)
				var ray_direction = camera.project_ray_normal(mouse_pos)
				
				# Position sphere slightly forward from camera
				interaction_sphere.global_position = ray_origin + ray_direction * 2.0

func process_cursor_interactions(delta: float) -> void:
	# Process cursor interactions with objects
	if is_hovering and hovered_object:
		# Update hover state
		if hovered_object.has_method("on_cursor_hover"):
			hovered_object.on_cursor_hover(cursor_tip_position)

func process_cursor_input(event: InputEvent) -> void:
	# Process cursor-specific input
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_clicking = true
				if hovered_object:
					cursor_clicked.emit(hovered_object, cursor_tip_position)
					
					# Different behavior based on mode
					if current_mode == CursorMode.INSPECT:
						# Always inspect in inspect mode
						trigger_inspector_for_object(hovered_object)
					else:
						# Normal interaction in interact mode
						if hovered_object.has_method("on_cursor_click"):
							hovered_object.on_cursor_click(cursor_tip_position)
			else:
				is_clicking = false
	
	elif event is InputEventMouseMotion:
		if is_clicking and hovered_object:
			cursor_dragging.emit(hovered_object, event.relative)
			if hovered_object.has_method("on_cursor_drag"):
				hovered_object.on_cursor_drag(event.relative)

func trigger_inspector_for_object(object: Node) -> void:
	# Trigger inspector interface for clicked Universal Being
	# Check if object is a Universal Being or related to one
	var universal_being = find_universal_being(object)
	
	if universal_being:
		print("🔍 Cursor Inspect Mode: Inspecting %s" % universal_being.being_name)
		
		# Try to use the Universal Inspector Bridge first
		var bridge = get_tree().get_nodes_in_group("inspector_bridge").front()
		if not bridge:
			# Create bridge if it doesn't exist
			var main_scene = get_tree().current_scene
			if main_scene:
				var BridgeClass = load("res://systems/UniversalInspectorBridge.gd")
				if BridgeClass:
					bridge = BridgeClass.new()
					bridge.name = "UniversalInspectorBridge"
					bridge.add_to_group("inspector_bridge")
					main_scene.add_child(bridge)
					print("🔗 Created Universal Inspector Bridge from cursor")
					
					# Wait for bridge to initialize
					await get_tree().create_timer(0.1).timeout
		
		# Use bridge to inspect
		if bridge and bridge.has_method("inspect_being"):
			bridge.inspect_being(universal_being)
			cursor_inspected.emit(universal_being)
			return
		
		# Fallback to direct inspector creation
		var main_scene = get_tree().current_scene
		if main_scene:
			# Load inspector class
			var inspector_script = load("res://ui/InGameUniversalBeingInspector.gd")
			if inspector_script:
				# Get or create inspector
				var inspector = main_scene.get_node_or_null("InGameUniversalBeingInspector")
				if not inspector:
					inspector = inspector_script.new()
					main_scene.add_child(inspector)
				
				# Open inspector for this being
				inspector.inspect_being(universal_being)
				cursor_inspected.emit(universal_being)
		
		# Also send to Gemma AI if available
		if GemmaAI:
			# Create inspection report
			var inspection_data = get_being_inspection_data(universal_being)
			var message = "🔍 CURSOR INSPECTION:\n"
			message += "🌟 Being: %s\n" % inspection_data.get("name", "Unknown")
			message += "🧠 Type: %s\n" % inspection_data.get("type", "unknown")
			message += "💫 Consciousness: %d\n" % inspection_data.get("consciousness", 0)
			message += "📍 Position: %s\n" % str(universal_being.global_position)
			
			if GemmaAI.has_method("ai_message"):
				GemmaAI.ai_message.emit(message)

func find_universal_being(node: Node) -> UniversalBeing:
	# Find Universal Being from clicked node
	var current = node
	
	# Traverse up the tree to find a Universal Being
	while current:
		if current is UniversalBeing:
			return current as UniversalBeing
		elif current.has_method("get") and current.has_method("pentagon_init"):
			# This looks like a Universal Being
			return current
		
		current = current.get_parent()
	
	return null

func get_being_inspection_data(being: Node) -> Dictionary:
	# Get inspection data for a Universal Being
	var data = {}
	
	if being.has_method("get"):
		data["name"] = being.get("being_name") if being.has_method("get") else being.name
		data["type"] = being.get("being_type") if being.has_method("get") else "unknown"
		data["consciousness"] = being.get("consciousness_level") if being.has_method("get") else 0
	else:
		data["name"] = being.name
		data["type"] = "scene_object"
		data["consciousness"] = 0
	
	return data

# ===== INTERACTION CALLBACKS =====

func _on_area_entered(area: Area3D) -> void:
	# Handle area entered by cursor sphere
	if not is_hovering:
		is_hovering = true
		hovered_object = area
		cursor_hover_started.emit(area)
		print("🎯 Cursor: Hovering over area - %s" % area.name)

func _on_area_exited(area: Area3D) -> void:
	# Handle area exited by cursor sphere
	if is_hovering and hovered_object == area:
		is_hovering = false
		cursor_hover_ended.emit(area)
		hovered_object = null
		print("🎯 Cursor: Stopped hovering over area - %s" % area.name)

func _on_body_entered(body: Node3D) -> void:
	# Handle body entered by cursor sphere
	if not is_hovering:
		is_hovering = true
		hovered_object = body
		cursor_hover_started.emit(body)
		print("🎯 Cursor: Hovering over body - %s" % body.name)

func _on_body_exited(body: Node3D) -> void:
	# Handle body exited by cursor sphere
	if is_hovering and hovered_object == body:
		is_hovering = false
		cursor_hover_ended.emit(body)
		hovered_object = null
		print("🎯 Cursor: Stopped hovering over body - %s" % body.name)

# ===== CURSOR UTILITIES =====

func get_cursor_tip_world_position() -> Vector3:
	# Get the world position of cursor tip in 3D space
	if interaction_sphere:
		return interaction_sphere.global_position
	return Vector3.ZERO

func set_cursor_visibility(visible: bool) -> void:
	# Set cursor visibility
	if cursor_shape:
		cursor_shape.visible = visible
	if cursor_3d_container:
		cursor_3d_container.visible = visible

func set_cursor_color(color: Color) -> void:
	# Set cursor color
	if cursor_shape:
		var polygon = cursor_shape.get_child(0)
		if polygon is Polygon2D:
			polygon.color = color

func toggle_mode() -> void:
	# Toggle between interact and inspect modes
	if current_mode == CursorMode.INTERACT:
		set_mode(CursorMode.INSPECT)
	else:
		set_mode(CursorMode.INTERACT)

func set_mode(mode: CursorMode) -> void:
	# Set cursor mode
	if current_mode != mode:
		current_mode = mode
		update_cursor_appearance()
		update_mode_indicator()
		cursor_mode_changed.emit(mode)
		
		print("🎯 Cursor mode changed to: %s" % ("INSPECT" if mode == CursorMode.INSPECT else "INTERACT"))

func update_cursor_appearance() -> void:
	# Update cursor visual based on mode
	if current_mode == CursorMode.INSPECT:
		set_cursor_color(Color(1.0, 0.5, 0.0))  # Orange for inspect
		if interaction_sphere:
			var mesh_instance = interaction_sphere.get_child(1) if interaction_sphere.get_child_count() > 1 else null
			if mesh_instance and mesh_instance is MeshInstance3D:
				var material = mesh_instance.material_override as StandardMaterial3D
				if material:
					material.albedo_color = Color(1.0, 0.5, 0.0)
					material.emission = Color(1.0, 0.5, 0.0)
	else:
		set_cursor_color(Color.CYAN)  # Cyan for interact
		if interaction_sphere:
			var mesh_instance = interaction_sphere.get_child(1) if interaction_sphere.get_child_count() > 1 else null
			if mesh_instance and mesh_instance is MeshInstance3D:
				var material = mesh_instance.material_override as StandardMaterial3D
				if material:
					material.albedo_color = Color.CYAN
					material.emission = Color.CYAN

func create_mode_indicator() -> void:
	# Create visual mode indicator on the enhanced canvas layer
	mode_visual_indicator = Node2D.new()
	mode_visual_indicator.name = "ModeIndicator"
	mode_visual_indicator.z_index = 2147483646  # Just below cursor
	cursor_canvas_layer.add_child(mode_visual_indicator)
	
	# Create mode label with background for visibility
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)
	background.size = Vector2(60, 16)
	background.position = Vector2(12, -8)
	mode_visual_indicator.add_child(background)
	
	var label = Label.new()
	label.name = "ModeLabel"
	label.text = "INTERACT"
	label.add_theme_font_size_override("font_size", 10)
	label.position = Vector2(15, -5)  # Position near cursor
	mode_visual_indicator.add_child(label)

func update_mode_indicator() -> void:
	# Update mode indicator visual
	if mode_visual_indicator:
		var label = mode_visual_indicator.get_node_or_null("ModeLabel")
		if label and label is Label:
			label.text = "INSPECT" if current_mode == CursorMode.INSPECT else "INTERACT"
			label.modulate = Color(1.0, 0.5, 0.0) if current_mode == CursorMode.INSPECT else Color.CYAN

# ===== DEBUG FUNCTIONS =====

func get_cursor_info() -> Dictionary:
	# Get cursor information for debugging
	return {
		"mode": "INSPECT" if current_mode == CursorMode.INSPECT else "INTERACT",
		"is_hovering": is_hovering,
		"hovered_object": hovered_object.name if hovered_object else "none",
		"is_clicking": is_clicking,
		"tip_position": cursor_tip_position,
		"consciousness_level": consciousness_level
	}

# ===== STATE MACHINE OVERRIDES =====
# Prevent cursor from creating offspring and reduce state transitions

func _generate_thought_result() -> Dictionary:
	# Override thought generation - cursor should not create beings
	var result = super._generate_thought_result()
	# Cursor should never create offspring
	result.should_create = false
	# Cursor should rarely evolve
	result.should_evolve = randf() < 0.01  # 1% chance instead of 20%
	return result

func _process_idle_state(delta: float) -> void:
	# Override idle state - cursor should be less active
	# Don't randomly start thinking as often
	if randf() < 0.001:  # 0.1% chance instead of 1%
		change_state(BeingState.THINKING, "cursor contemplation")
	
	# Still check for interactions but less frequently
	if not nearby_beings.is_empty() and randf() < 0.002:  # Reduced from 0.005
		change_state(BeingState.INTERACTING, "cursor proximity check")

func _attempt_creation() -> void:
	# Override creation - cursor should not create offspring
	# Do nothing - cursor cannot create beings
	print("🎯 Cursor: Creation blocked - cursors don't create offspring")
	log_action("creation_blocked", "Cursor creation attempt blocked")

func _process_creating_state(delta: float) -> void:
	# Override creating state - immediately return to idle
	print("🎯 Cursor: Exiting CREATING state - cursors don't create")
	change_state(BeingState.IDLE, "cursor cannot create")
