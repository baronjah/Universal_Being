# Notepad3D.gd
extends UniversalBeing
class_name Notepad3D

# Core note management
var notes: Dictionary = {} # id -> Note3D
var connections: Array = [] # Line connections between notes
var selected_notes: Array = []
var hovered_note: Note3D = null

# Visual settings
@export var note_default_size: Vector2 = Vector2(400, 300)
@export var note_min_size: Vector2 = Vector2(100, 100)
@export var note_max_size: Vector2 = Vector2(1200, 900)
@export var lod_distances: Array[float] = [50.0, 100.0, 200.0, 500.0, 1000.0]
@export var occlusion_culling: bool = true
@export var max_visible_notes: int = 100

# Interaction
var camera: Camera3D
var interaction_ray: RayCast3D
var current_tool: String = "select"
var drag_offset: Vector3
var is_dragging: bool = false
var is_resizing: bool = false
var is_connecting: bool = false
var connection_start_note: Note3D = null

# Folding and organization
var folders: Dictionary = {} # folder_name -> Array of note_ids
var fold_groups: Dictionary = {} # group_id -> fold settings

# LOD system
var lod_update_timer: float = 0.0
var lod_update_interval: float = 0.1

# Autosave
var autosave_timer: float = 0.0
var autosave_interval: float = 30.0
var unsaved_changes: bool = false

# Note class
class Note3D extends Node3D:
	var id: String
	var title: String = "Untitled"
	var content: String = ""
	var color: Color = Color.WHITE
	var size: Vector2 = Vector2(400, 300)
	var folded: bool = false
	var fold_level: int = 0
	var tags: Array[String] = []
	var creation_time: float
	var last_modified: float
	var locked: bool = false
	var opacity: float = 1.0
	
	# Visual components
	var mesh_instance: MeshInstance3D
	var label_3d: Label3D
	var content_label: Label3D
	var collision_area: Area3D
	var outline_mesh: MeshInstance3D
	
	# LOD
	var current_lod: int = 0
	var distance_to_camera: float = 0.0
	
	func _init():
		id = str(Time.get_unix_time_from_system()) + "_" + str(randi())
		creation_time = Time.get_unix_time_from_system()
		last_modified = creation_time

# Pentagon implementation
func pentagon_init() -> void:
	super.pentagon_init()
	name = "Notepad3D"
	_setup_camera_system()
	_initialize_tools()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_ui_overlay()
	_load_saved_notes()
	set_process(true)
	set_process_input(true)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_update_lod_system(delta)
	_update_hover_detection()
	_update_autosave(delta)
	_update_note_physics(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventKey:
		_handle_keyboard_input(event)

func pentagon_sewers() -> void:
	save_all_notes()
	_cleanup_connections()
	super.pentagon_sewers()

# Setup functions
func _setup_camera_system() -> void:
	# Get or create camera
	camera = get_viewport().get_camera_3d()
	if not camera:
		camera = Camera3D.new()
		add_child(camera)
	
	# Setup interaction ray
	interaction_ray = RayCast3D.new()
	interaction_ray.target_position = Vector3(0, 0, -1000)
	interaction_ray.collision_mask = 2 # Note layer
	camera.add_child(interaction_ray)

func _initialize_tools() -> void:
	# Available tools for notepad
	var tools = {
		"select": preload("res://cursors/select.png"),
		"create": preload("res://cursors/create.png"),
		"connect": preload("res://cursors/connect.png"),
		"delete": preload("res://cursors/delete.png"),
		"fold": preload("res://cursors/fold.png")
	}

# Note creation and management
func create_note(title: String, content: String, position: Vector3, color: Color = Color.WHITE) -> Note3D:
	var note = Note3D.new()
	note.title = title
	note.content = content
	note.global_position = position
	note.color = color
	
	# Create visual representation
	_create_note_visual(note)
	
	# Add to scene and registry
	add_child(note)
	notes[note.id] = note
	
	unsaved_changes = true
	return note

func _create_note_visual(note: Note3D) -> void:
	# Create mesh for note background
	var mesh = QuadMesh.new()
	mesh.size = note.size
	
	note.mesh_instance = MeshInstance3D.new()
	note.mesh_instance.mesh = mesh
	note.add_child(note.mesh_instance)
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = note.color
	material.albedo_color.a = note.opacity
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	note.mesh_instance.material_override = material
	
	# Create title label
	note.label_3d = Label3D.new()
	note.label_3d.text = note.title
	note.label_3d.position = Vector3(0, note.size.y * 0.4, 0.1)
	note.label_3d.font_size = 24
	note.label_3d.modulate = Color.BLACK
	note.label_3d.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	note.add_child(note.label_3d)
	
	# Create content label
	note.content_label = Label3D.new()
	note.content_label.text = note.content
	note.content_label.position = Vector3(0, 0, 0.1)
	note.content_label.font_size = 16
	note.content_label.modulate = Color.BLACK
	note.content_label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	note.content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.content_label.width = note.size.x * 0.9
	note.add_child(note.content_label)
	
	# Create collision area
	note.collision_area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(note.size.x, note.size.y, 10)
	collision_shape.shape = box_shape
	note.collision_area.add_child(collision_shape)
	note.collision_area.collision_layer = 2 # Note layer
	note.add_child(note.collision_area)
	
	# Create outline (hidden by default)
	_create_note_outline(note)

func _create_note_outline(note: Note3D) -> void:
	var outline_mesh = QuadMesh.new()
	outline_mesh.size = note.size * 1.05
	
	note.outline_mesh = MeshInstance3D.new()
	note.outline_mesh.mesh = outline_mesh
	note.outline_mesh.position = Vector3(0, 0, -0.1)
	
	var outline_material = StandardMaterial3D.new()
	outline_material.albedo_color = Color.YELLOW
	outline_material.emission_enabled = true
	outline_material.emission = Color.YELLOW
	outline_material.emission_energy = 0.5
	outline_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	note.outline_mesh.material_override = outline_material
	note.outline_mesh.visible = false
	
	note.add_child(note.outline_mesh)

# Note operations
func delete_note(note_id: String) -> void:
	if not notes.has(note_id):
		return
	
	var note = notes[note_id]
	
	# Remove connections
	_remove_note_connections(note_id)
	
	# Remove from folders
	for folder in folders:
		folders[folder].erase(note_id)
	
	# Remove from scene
	note.queue_free()
	notes.erase(note_id)
	
	unsaved_changes = true

func fold_note(note: Note3D, level: int = 1) -> void:
	note.fold_level = level
	note.folded = true
	
	# Adjust visual size based on fold level
	var scale_factor = 1.0 / (level + 1)
	var tween = create_tween()
	tween.tween_property(note, "scale", Vector3.ONE * scale_factor, 0.3)
	
	# Hide content at higher fold levels
	if level > 1:
		note.content_label.visible = false
	if level > 2:
		note.label_3d.font_size = 12
	
	unsaved_changes = true

func unfold_note(note: Note3D) -> void:
	note.folded = false
	note.fold_level = 0
	
	var tween = create_tween()
	tween.tween_property(note, "scale", Vector3.ONE, 0.3)
	
	note.content_label.visible = true
	note.label_3d.font_size = 24
	
	unsaved_changes = true

# Connection system
func create_connection(from_note: Note3D, to_note: Note3D, color: Color = Color.CYAN) -> void:
	var connection = {
		"from": from_note.id,
		"to": to_note.id,
		"color": color,
		"line": null
	}
	
	# Create 3D line
	var line = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	line.mesh = immediate_mesh
	
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	line.material_override = material
	
	add_child(line)
	connection["line"] = line
	
	connections.append(connection)
	_update_connection_line(connection)
	
	unsaved_changes = true

func _update_connection_line(connection: Dictionary) -> void:
	var from_note = notes.get(connection["from"])
	var to_note = notes.get(connection["to"])
	
	if not from_note or not to_note:
		return
	
	var line = connection["line"]
	var mesh = line.mesh as ImmediateMesh
	
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_set_color(connection["color"])
	mesh.surface_add_vertex(from_note.global_position)
	mesh.surface_add_vertex(to_note.global_position)
	mesh.surface_end()

# LOD system
func _update_lod_system(delta: float) -> void:
	lod_update_timer += delta
	if lod_update_timer < lod_update_interval:
		return
	
	lod_update_timer = 0.0
	
	if not camera:
		return
	
	var camera_pos = camera.global_position
	
	# Sort notes by distance
	var sorted_notes = []
	for note in notes.values():
		note.distance_to_camera = camera_pos.distance_to(note.global_position)
		sorted_notes.append(note)
	
	sorted_notes.sort_custom(func(a, b): return a.distance_to_camera < b.distance_to_camera)
	
	# Apply LOD and visibility
	var visible_count = 0
	for i in range(sorted_notes.size()):
		var note = sorted_notes[i]
		
		# Visibility culling
		if visible_count >= max_visible_notes:
			note.visible = false
			continue
		
		# Frustum culling
		if occlusion_culling and not camera.is_position_in_frustum(note.global_position):
			note.visible = false
			continue
		
		note.visible = true
		visible_count += 1
		
		# Determine LOD level
		var new_lod = _calculate_lod_level(note.distance_to_camera)
		if new_lod != note.current_lod:
			_apply_lod_level(note, new_lod)
			note.current_lod = new_lod

func _calculate_lod_level(distance: float) -> int:
	for i in range(lod_distances.size()):
		if distance < lod_distances[i]:
			return i
	return lod_distances.size()

func _apply_lod_level(note: Note3D, lod: int) -> void:
	match lod:
		0: # Highest detail
			note.label_3d.visible = true
			note.content_label.visible = true
			note.label_3d.font_size = 24
			note.content_label.font_size = 16
		1: # Medium-high detail
			note.label_3d.visible = true
			note.content_label.visible = true
			note.label_3d.font_size = 20
			note.content_label.font_size = 14
		2: # Medium detail
			note.label_3d.visible = true
			note.content_label.visible = true
			note.label_3d.font_size = 16
			note.content_label.font_size = 12
		3: # Low detail
			note.label_3d.visible = true
			note.content_label.visible = false
			note.label_3d.font_size = 14
		4: # Lowest detail
			note.label_3d.visible = true
			note.content_label.visible = false
			note.label_3d.font_size = 12
		_: # Icon only
			note.label_3d.visible = false
			note.content_label.visible = false

# Interaction handling
func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_on_left_click(event)
		else:
			_on_left_release(event)
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_on_right_click(event)
	elif event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
		_on_middle_click(event)

func _on_left_click(event: InputEventMouseButton) -> void:
	# Update ray from camera
	var mouse_pos = event.position
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	interaction_ray.global_position = from
	interaction_ray.target_position = camera.global_transform.basis.inverse() * (to - from)
	interaction_ray.force_raycast_update()
	
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		var note = _get_note_from_collider(collider)
		
		if note:
			match current_tool:
				"select":
					_select_note(note, event.shift_pressed)
					if not event.shift_pressed:
						is_dragging = true
						drag_offset = note.global_position - _get_world_position_from_mouse(mouse_pos)
				"delete":
					delete_note(note.id)
				"fold":
					if note.folded:
						unfold_note(note)
					else:
						fold_note(note)
				"connect":
					if connection_start_note:
						create_connection(connection_start_note, note)
						connection_start_note = null
						is_connecting = false
					else:
						connection_start_note = note
						is_connecting = true
	else:
		# Click on empty space
		if current_tool == "create":
			var world_pos = _get_world_position_from_mouse(mouse_pos)
			create_note("New Note", "Click to edit", world_pos)
		elif current_tool == "select" and not event.shift_pressed:
			_clear_selection()

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if is_dragging and selected_notes.size() > 0:
		var world_pos = _get_world_position_from_mouse(event.position)
		for note in selected_notes:
			note.global_position = world_pos + drag_offset
		
		# Update connections
		for connection in connections:
			if connection["from"] in selected_notes or connection["to"] in selected_notes:
				_update_connection_line(connection)
		
		unsaved_changes = true

func _handle_keyboard_input(event: InputEventKey) -> void:
	if not event.pressed:
		return
	
	match event.keycode:
		KEY_DELETE:
			for note in selected_notes:
				delete_note(note.id)
		KEY_C:
			if event.ctrl_pressed:
				_copy_selected_notes()
		KEY_V:
			if event.ctrl_pressed:
				_paste_notes()
		KEY_S:
			if event.ctrl_pressed:
				save_all_notes()
		KEY_A:
			if event.ctrl_pressed:
				_select_all_notes()
		KEY_F:
			current_tool = "fold"
		KEY_N:
			current_tool = "create"
		KEY_L:
			current_tool = "connect"
		KEY_ESCAPE:
			current_tool = "select"
			is_connecting = false
			connection_start_note = null

# Selection system
func _select_note(note: Note3D, add_to_selection: bool = false) -> void:
	if not add_to_selection:
		_clear_selection()
	
	if note in selected_notes:
		selected_notes.erase(note)
		note.outline_mesh.visible = false
	else:
		selected_notes.append(note)
		note.outline_mesh.visible = true

func _clear_selection() -> void:
	for note in selected_notes:
		note.outline_mesh.visible = false
	selected_notes.clear()

func _select_all_notes() -> void:
	_clear_selection()
	for note in notes.values():
		selected_notes.append(note)
		note.outline_mesh.visible = true

# Utility functions
func _get_note_from_collider(collider: Node3D) -> Note3D:
	var parent = collider.get_parent()
	while parent:
		if parent is Note3D:
			return parent
		parent = parent.get_parent()
	return null

func _get_world_position_from_mouse(mouse_pos: Vector2, distance: float = 50.0) -> Vector3:
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * distance
	return to

# Save/Load system
func save_all_notes() -> void:
	var save_data = {
		"notes": {},
		"connections": [],
		"folders": folders,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Save notes
	for id in notes:
		var note = notes[id]
		save_data["notes"][id] = {
			"title": note.title,
			"content": note.content,
			"position": note.global_position,
			"color": note.color,
			"size": note.size,
			"folded": note.folded,
			"fold_level": note.fold_level,
			"tags": note.tags,
			"locked": note.locked,
			"opacity": note.opacity
		}
	
	# Save connections
	for connection in connections:
		save_data["connections"].append({
			"from": connection["from"],
			"to": connection["to"],
			"color": connection["color"]
		})
	
	# Save to akashic records
	if AkashicRecordsSystem:
		AkashicRecordsSystem.save_notepad3d_data(save_data)
	
	unsaved_changes = false
	print("Notepad3D saved: %d notes, %d connections" % [notes.size(), connections.size()])

func load_notes(save_data: Dictionary) -> void:
	# Clear existing
	_clear_all_notes()
	
	# Load notes
	if save_data.has("notes"):
		for id in save_data["notes"]:
			var note_data = save_data["notes"][id]
			var note = create_note(
				note_data["title"],
				note_data["content"],
				note_data["position"],
				note_data.get("color", Color.WHITE)
			)
			
			# Restore properties
			note.id = id
			note.size = note_data.get("size", note_default_size)
			note.folded = note_data.get("folded", false)
			note.fold_level = note_data.get("fold_level", 0)
			note.tags = note_data.get("tags", [])
			note.locked = note_data.get("locked", false)
			note.opacity = note_data.get("opacity", 1.0)
			
			# Update visual
			_update_note_visual(note)
	
	# Load connections
	if save_data.has("connections"):
		for conn_data in save_data["connections"]:
			var from_note = notes.get(conn_data["from"])
			var to_note = notes.get(conn_data["to"])
			if from_note and to_note:
				create_connection(from_note, to_note, conn_data.get("color", Color.CYAN))
	
	# Load folders
	if save_data.has("folders"):
		folders = save_data["folders"]
	
	unsaved_changes = false

func _clear_all_notes() -> void:
	for note in notes.values():
		note.queue_free()
	notes.clear()
	
	for connection in connections:
		if connection["line"]:
			connection["line"].queue_free()
	connections.clear()

# Export for game saving
func export_notes() -> Dictionary:
	var export_data = {}
	save_all_notes() # Ensure latest data
	
	if AkashicRecordsSystem:
		export_data = AkashicRecordsSystem.get_notepad3d_data()
	
	return export_data

# Physics and animation
func _update_note_physics(delta: float) -> void:
	# Gentle floating animation for notes
	for note in notes.values():
		if not note.locked:
			var time = Time.get_ticks_msec() / 1000.0
			var offset = sin(time + note.creation_time) * 2.0
			note.position.y += offset * delta

# Auto-save
func _update_autosave(delta: float) -> void:
	if not unsaved_changes:
		return
	
	autosave_timer += delta
	if autosave_timer >= autosave_interval:
		save_all_notes()
		autosave_timer = 0.0

# Hover detection
func _update_hover_detection() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	interaction_ray.global_position = from
	interaction_ray.target_position = camera.global_transform.basis.inverse() * (to - from)
	interaction_ray.force_raycast_update()
	
	var new_hover = null
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		new_hover = _get_note_from_collider(collider)
	
	if new_hover != hovered_note:
		if hovered_note and hovered_note not in selected_notes:
			hovered_note.outline_mesh.visible = false
		
		hovered_note = new_hover
		
		if hovered_note and hovered_note not in selected_notes:
			hovered_note.outline_mesh.visible = true
			hovered_note.outline_mesh.material_override.emission = Color.CYAN

# UI overlay
func _create_ui_overlay() -> void:
	# Tool indicator
	var tool_label = Label.new()
	tool_label.name = "ToolLabel"
	tool_label.text = "Tool: Select"
	tool_label.position = Vector2(10, 10)
	add_child(tool_label)

# Search functionality
func search_notes(query: String) -> Array:
	var results = []
	var lower_query = query.to_lower()
	
	for note in notes.values():
		if lower_query in note.title.to_lower() or lower_query in note.content.to_lower():
			results.append(note)
		else:
			for tag in note.tags:
				if lower_query in tag.to_lower():
					results.append(note)
					break
	
	return results

# Focus on note
func focus_on_note(note: Note3D) -> void:
	var tween = create_tween()
	tween.tween_property(camera, "global_position", 
		note.global_position + Vector3(0, 0, 50), 0.5)
	
	_select_note(note)

# Cleanup
func _cleanup_connections() -> void:
	for connection in connections:
		if connection["line"]:
			connection["line"].queue_free()

func _remove_note_connections(note_id: String) -> void:
	var to_remove = []
	for i in range(connections.size()):
		var connection = connections[i]
		if connection["from"] == note_id or connection["to"] == note_id:
			if connection["line"]:
				connection["line"].queue_free()
			to_remove.append(i)
	
	# Remove in reverse order
	for i in range(to_remove.size() - 1, -1, -1):
		connections.remove_at(to_remove[i])

func _update_note_visual(note: Note3D) -> void:
	# Update mesh size
	if note.mesh_instance and note.mesh_instance.mesh:
		note.mesh_instance.mesh.size = note.size
	
	# Update collision
	if note.collision_area:
		var shape = note.collision_area.get_child(0).shape as BoxShape3D
		shape.size = Vector3(note.size.x, note.size.y, 10)
	
	# Apply fold state
	if note.folded:
		fold_note(note, note.fold_level)

# Helper functions
func get_visible_notes() -> Array:
	var visible = []
	for note in notes.values():
		if note.visible:
			visible.append(note)
	return visible

func get_selected_note_ids() -> Array:
	var ids = []
	for note in selected_notes:
		ids.append(note.id)
	return ids

func create_folder(name: String) -> void:
	if not folders.has(name):
		folders[name] = []
		unsaved_changes = true

func add_note_to_folder(note_id: String, folder_name: String) -> void:
	if folders.has(folder_name) and notes.has(note_id):
		if note_id not in folders[folder_name]:
			folders[folder_name].append(note_id)
			unsaved_changes = true

func toggle_visibility() -> bool:
	visible = !visible
	return visible

func is_visible() -> bool:
	return visible

func _on_left_release(_event: InputEventMouseButton) -> void:
	is_dragging = false
	
func _on_right_click(_event: InputEventMouseButton) -> void:
	# Context menu would go here
	pass
	
func _on_middle_click(_event: InputEventMouseButton) -> void:
	# Reset view or other middle click action
	pass

func _copy_selected_notes() -> void:
	# Copy implementation
	pass
	
func _paste_notes() -> void:
	# Paste implementation
	pass

func _load_saved_notes() -> void:
	if AkashicRecordsSystem:
		var saved_data = AkashicRecordsSystem.get_notepad3d_data()
		if saved_data:
			load_notes(saved_data)

# Initialize with parameters
func initialize(params: Dictionary) -> void:
	if params.has("start_position") and camera:
		camera.global_position = params["start_position"]
	if params.has("max_notes"):
		max_visible_notes = params["max_notes"]
	if params.has("occlusion_culling"):
		occlusion_culling = params["occlusion_culling"]
	if params.has("autosave_interval"):
		autosave_interval = params["autosave_interval"]

# Enable special modes
func enable_akashic_mode() -> void:
	# Special mode where notes connect to akashic records
	print("Akashic mode enabled - notes now sync with universal consciousness")
