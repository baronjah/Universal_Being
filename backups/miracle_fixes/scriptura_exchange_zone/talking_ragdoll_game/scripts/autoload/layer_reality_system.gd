extends UniversalBeingBase
# Layer Reality System - Multi-dimensional world visualization
# Layer 0: Text/Console reality
# Layer 1: 2D Map/Height visualization
# Layer 2: Debug shapes and lines
# Layer 3: Full 3D models and shaders

signal layer_visibility_changed(layer_id: int, visible: bool)
signal reality_mode_changed(mode: String)  # Connected by UI systems for mode switching

enum Layer {
	TEXT = 0,      # Console/text representation
	MAP_2D = 1,    # 2D height/color map
	DEBUG_3D = 2,  # Debug shapes and lines
	FULL_3D = 3    # Full 3D models
}

enum ViewMode {
	SINGLE,        # Show one layer
	DUAL,          # Show two layers
	TRIPLE,        # Show three layers
	ALL            # Show all layers
}

# Layer containers
var layer_nodes: Dictionary = {}
var layer_visibility: Dictionary = {}
var active_layers: Array = []

# View settings
var current_view_mode: ViewMode = ViewMode.SINGLE
var primary_layer: Layer = Layer.FULL_3D
var secondary_layer: Layer = Layer.DEBUG_3D
var tertiary_layer: Layer = Layer.MAP_2D

# Camera references
var main_camera: Camera3D
var layer_cameras: Dictionary = {}

# Debug visualization
var debug_mesh_instance: MeshInstance3D
var debug_mesh: ImmediateMesh
var debug_material: StandardMaterial3D
var debug_lines: Array = []
var debug_points: Array = []

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	set_process_unhandled_input(true)
	_initialize_layers()
	_setup_debug_draw()

func _initialize_layers() -> void:
	# Create layer containers
	for layer in Layer.values():
		var container = Node3D.new()
		container.name = "Layer_" + str(layer)
		add_child(container)
		layer_nodes[layer] = container
		layer_visibility[layer] = false
	
	# Set initial visibility
	set_layer_visibility(Layer.FULL_3D, true)
	active_layers = [Layer.FULL_3D]
	
	# Emit initial mode
	reality_mode_changed.emit("full_3d")

func _setup_debug_draw() -> void:
	# Create immediate mesh for debug drawing
	if not debug_mesh_instance:
		debug_mesh_instance = MeshInstance3D.new()
		debug_mesh_instance.name = "DebugDraw"
		
		debug_mesh = ImmediateMesh.new()
		debug_mesh_instance.mesh = debug_mesh
		
		debug_material = _create_debug_material()
		debug_mesh_instance.material_override = debug_material
		
		layer_nodes[Layer.DEBUG_3D].add_child(debug_mesh_instance)

func _create_debug_material() -> StandardMaterial3D:
	var mat = MaterialLibrary.get_material("default")
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color.WHITE
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat

# Unhandled input integrated into Pentagon Architecture
func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Unhandled input logic
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				toggle_layer(Layer.TEXT)
			KEY_F2:
				toggle_layer(Layer.MAP_2D)
			KEY_F3:
				toggle_layer(Layer.DEBUG_3D)
			KEY_F4:
				toggle_layer(Layer.FULL_3D)
			KEY_F5:
				cycle_view_mode()
			KEY_F6:
				toggle_split_screen()
			KEY_F7:
				align_to_camera()
			KEY_F8:
				align_to_origin()

# Layer Management

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

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func set_layer_visibility(layer: Layer, visible: bool) -> void:
	if layer_nodes.has(layer):
		layer_nodes[layer].visible = visible
		layer_visibility[layer] = visible
		
		if visible and layer not in active_layers:
			active_layers.append(layer)
		elif not visible and layer in active_layers:
			active_layers.erase(layer)
		
		layer_visibility_changed.emit(layer, visible)
		_update_viewport_layout()

func toggle_layer(layer: Layer) -> void:
	set_layer_visibility(layer, not layer_visibility.get(layer, false))

func cycle_view_mode() -> void:
	current_view_mode = ((current_view_mode + 1) % ViewMode.size()) as ViewMode
	_apply_view_mode()

func _apply_view_mode() -> void:
	# Clear all layers first
	for layer in Layer.values():
		set_layer_visibility(layer, false)
	
	# Apply new mode
	match current_view_mode:
		ViewMode.SINGLE:
			set_layer_visibility(primary_layer, true)
		ViewMode.DUAL:
			set_layer_visibility(primary_layer, true)
			set_layer_visibility(secondary_layer, true)
		ViewMode.TRIPLE:
			set_layer_visibility(primary_layer, true)
			set_layer_visibility(secondary_layer, true)
			set_layer_visibility(tertiary_layer, true)
		ViewMode.ALL:
			for layer in Layer.values():
				set_layer_visibility(layer, true)

# Viewport Layout
func _update_viewport_layout() -> void:
	var viewport_count = active_layers.size()
	if viewport_count == 0:
		return
	
	var root_viewport = get_viewport()
	var screen_size = root_viewport.get_visible_rect().size
	
	match viewport_count:
		1:
			_setup_single_view(screen_size)
		2:
			_setup_dual_view(screen_size)
		3:
			_setup_triple_view(screen_size)
		4:
			_setup_quad_view(screen_size)

func _setup_single_view(_screen_size: Vector2) -> void:
	# Single fullscreen view
	pass

func _setup_dual_view(_screen_size: Vector2) -> void:
	# Split screen vertically or horizontally
	pass

func _setup_triple_view(_screen_size: Vector2) -> void:
	# One large view on top, two smaller below
	pass

func _setup_quad_view(_screen_size: Vector2) -> void:
	# Four equal quadrants
	pass

# Debug Drawing
func add_debug_point(position: Vector3, color: Color = Color.WHITE, size: float = 0.1) -> void:
	debug_points.append({
		"position": position,
		"color": color,
		"size": size
	})
	_update_debug_draw()

func add_debug_line(from: Vector3, to: Vector3, color: Color = Color.WHITE) -> void:
	debug_lines.append({
		"from": from,
		"to": to,
		"color": color
	})
	_update_debug_draw()

func add_debug_path(points: PackedVector3Array, color: Color = Color.GREEN) -> void:
	for i in range(points.size() - 1):
		add_debug_line(points[i], points[i + 1], color)

func clear_debug_draw() -> void:
	debug_points.clear()
	debug_lines.clear()
	_update_debug_draw()

func _update_debug_draw() -> void:
	if not debug_mesh or not debug_mesh_instance:
		return
	
	# Clear previous mesh
	debug_mesh.clear_surfaces()
	
	# Start building mesh
	debug_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	# Draw lines
	for line in debug_lines:
		debug_mesh.surface_set_color(line.color)
		debug_mesh.surface_add_vertex(line.from)
		debug_mesh.surface_add_vertex(line.to)
	
	# Draw points as small crosses
	for point in debug_points:
		var p = point.position
		var s = point.size
		debug_mesh.surface_set_color(point.color)
		
		# X axis
		debug_mesh.surface_add_vertex(p - Vector3(s, 0, 0))
		debug_mesh.surface_add_vertex(p + Vector3(s, 0, 0))
		# Y axis
		debug_mesh.surface_add_vertex(p - Vector3(0, s, 0))
		debug_mesh.surface_add_vertex(p + Vector3(0, s, 0))
		# Z axis
		debug_mesh.surface_add_vertex(p - Vector3(0, 0, s))
		debug_mesh.surface_add_vertex(p + Vector3(0, 0, s))
	
	# Finish mesh
	debug_mesh.surface_end()

# Alignment Functions
func align_to_camera() -> void:
	if not main_camera:
		main_camera = get_viewport().get_camera_3d()
	
	if main_camera:
		var cam_transform = main_camera.global_transform
		# Align layer containers to camera view
		for layer in active_layers:
			if layer_nodes.has(layer):
				# Keep position but align rotation
				layer_nodes[layer].global_transform.basis = cam_transform.basis

func align_to_origin() -> void:
	# Reset all layers to origin
	for layer in Layer.values():
		if layer_nodes.has(layer):
			layer_nodes[layer].global_transform = Transform3D.IDENTITY

# Layer Content Management
func add_to_layer(node: Node, layer: Layer) -> void:
	if layer_nodes.has(layer):
		layer_nodes[layer].add_child(node)

func remove_from_layer(node: Node, layer: Layer) -> void:
	if layer_nodes.has(layer) and node.get_parent() == layer_nodes[layer]:
		layer_nodes[layer].remove_child(node)

# Text Layer Functions (Layer 0)
func add_text_entity(id: String, text: String, world_pos: Vector3) -> void:
	# Store text representation of world entities
	var text_data = {
		"id": id,
		"text": text,
		"position": world_pos,
		"last_update": Time.get_ticks_msec()
	}
	# This would connect to console manager for text display
	if has_node("/root/ConsoleManager"):
		get_node("/root/ConsoleManager").call("display_world_text", text_data)

# 2D Map Layer Functions (Layer 1)
func update_height_map(position: Vector2, height: float, color: Color) -> void:
	# Update 2D representation of 3D world - ACTIVELY USED by multi_layer_entity.gd
	var map_data = {
		"position": position,
		"height": height,
		"color": color,
		"timestamp": Time.get_ticks_msec()
	}
	
	# Store in height map data structure
	if not has_meta("height_map_data"):
		set_meta("height_map_data", {})
	
	var height_map = get_meta("height_map_data")
	var key = str(int(position.x)) + "," + str(int(position.y))
	height_map[key] = map_data
	
	# Emit layer update signal
	layer_visibility_changed.emit(Layer.MAP_2D, true)
	
	# Update 2D texture if layer is active (future implementation)
	if layer_visibility.get(Layer.MAP_2D, false):
		_update_2d_texture(position, height, color)

# Helper function for 2D texture updates
func _update_2d_texture(position: Vector2, height: float, color: Color) -> void:
	# Future: Update actual 2D texture/tilemap representation
	print("[LayerReality] Height map updated at ", position, " height=", height, " color=", color)

# Split Screen Toggle
func toggle_split_screen() -> void:
	if active_layers.size() < 2:
		push_warning("Need at least 2 active layers for split screen")
		return
	
	# Implementation for split screen viewports
	pass

# API for other systems
func get_active_layers() -> Array:
	return active_layers.duplicate()

func is_layer_visible(layer: Layer) -> bool:
	return layer_visibility.get(layer, false)

func get_layer_node(layer: Layer) -> Node3D:
	return layer_nodes.get(layer, null)

# Console commands integration
func register_console_commands() -> void:
	if has_node("/root/ConsoleManager"):
		var console = get_node("/root/ConsoleManager")
		if "commands" in console:
			console.commands["layer"] = _console_layer_command
			console.commands["reality"] = _console_reality_command
			print("[LayerRealitySystem] Console commands registered")
		else:
			push_error("[LayerRealitySystem] Console doesn't have commands dictionary")

func _console_layer_command(args: Array) -> String:
	if args.is_empty():
		return "Usage: layer [show|hide|toggle] [text|map|debug|full]"
	
	var action = args[0]
	var layer_name = args[1] if args.size() > 1 else ""
	
	var layer_map = {
		"text": Layer.TEXT,
		"map": Layer.MAP_2D,
		"debug": Layer.DEBUG_3D,
		"full": Layer.FULL_3D
	}
	
	if layer_name in layer_map:
		var layer = layer_map[layer_name]
		match action:
			"show":
				set_layer_visibility(layer, true)
				return "Layer " + layer_name + " shown"
			"hide":
				set_layer_visibility(layer, false)
				return "Layer " + layer_name + " hidden"
			"toggle":
				toggle_layer(layer)
				return "Layer " + layer_name + " toggled"
	
	return "Invalid layer or action"

func _console_reality_command(args: Array) -> String:
	if args.is_empty():
		return "Current view mode: " + str(current_view_mode)
	
	cycle_view_mode()
	return "Switched to view mode: " + str(current_view_mode)