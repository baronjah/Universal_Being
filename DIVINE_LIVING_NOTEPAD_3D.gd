# ==================================================
# SCRIPT NAME: DIVINE_LIVING_NOTEPAD_3D.gd
# DESCRIPTION: 3D Database Notepad - Swim through living data
# PURPOSE: Universal Being that creates immersive 3D data environment
# CREATED: 2025-06-30 - Response to Divine Mandate
# AUTHOR: Claude + JSH Divine Collaboration
# ==================================================

extends UniversalBeing
class_name DivineLivingNotepad3D

# ===== 3D DATA SWIMMING SYSTEM =====

## 3D Data Swimming Properties
@export var swim_speed: float = 10.0
@export var data_density: float = 0.5
@export var note_spawn_distance: float = 50.0
@export var max_visible_notes: int = 100

## Data Structure
var active_notes: Array[Node3D] = []
var note_database: Dictionary = {}
var current_note_id: int = 0

## Swimming Physics
var swim_velocity: Vector3 = Vector3.ZERO
var swim_drag: float = 0.9
var swim_acceleration: float = 20.0

## 3D Text Input System
var text_input_sphere: Node3D = null
var is_typing: bool = false
var current_text: String = ""

# ===== PENTAGON LIFECYCLE METHODS =====

func pentagon_init() -> void:
	super.pentagon_init()  # ALWAYS FIRST
	being_type = "divine_notepad_3d"
	being_name = "Divine Living Notepad 3D"
	consciousness_level = 4  # Gold level - Enlightened data consciousness
	
	# Initialize 3D data environment
	_setup_3d_data_space()
	show_ub_visual("✨ Divine 3D Notepad consciousness awakening...")

func pentagon_ready() -> void:
	super.pentagon_ready()  # ALWAYS FIRST
	
	# Setup camera system using TrackballCamera
	_setup_camera_system()
	
	# Create initial data spheres
	_generate_initial_data_spheres()
	
	# Setup input handling
	set_process_input(true)
	
	show_ub_visual("🌊 3D Data swimming environment ready - dive in!")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)  # ALWAYS FIRST
	
	# Update swimming physics
	_update_swimming_physics(delta)
	
	# Update data sphere positions
	_update_data_spheres(delta)
	
	# Manage note visibility based on distance
	_manage_note_visibility()
	
	# Update text input sphere
	if text_input_sphere and is_typing:
		_update_text_input_sphere(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)  # ALWAYS FIRST
	
	if event is InputEventKey:
		_handle_keyboard_input(event)
	elif event is InputEventMouseButton:
		_handle_mouse_input(event)

func pentagon_sewers() -> void:
	# Cleanup 3D data environment
	_cleanup_data_spheres()
	
	super.pentagon_sewers()  # ALWAYS LAST

# ===== 3D DATA SWIMMING IMPLEMENTATION =====

func _setup_3d_data_space() -> void:
	"""Initialize the 3D data swimming environment"""
	# Create the data ocean floor
	var ocean_floor = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(1000, 1000)
	ocean_floor.mesh = plane_mesh
	
	var floor_material = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.1, 0.2, 0.4, 0.7)
	floor_material.flags_transparent = true
	floor_material.emission_enabled = true
	floor_material.emission = Color(0.2, 0.4, 0.8)
	ocean_floor.material_override = floor_material
	
	ocean_floor.position = Vector3(0, -50, 0)
	add_child(ocean_floor)

func _setup_camera_system() -> void:
	"""Use existing camera system - don't create new cameras"""
	# Just connect to existing camera system - user already has TrackballCamera
	show_ub_visual("📹 Using existing camera system for data swimming")

func _generate_initial_data_spheres() -> void:
	"""Generate initial floating data notes as 3D spheres"""
	for i in range(20):
		_create_data_note_sphere("Welcome to 3D Data Swimming!\nNote #%d" % i, 
								 Vector3(randf_range(-30, 30), randf_range(0, 20), randf_range(-30, 30)))

func _create_data_note_sphere(text: String, pos: Vector3) -> Node3D:
	"""Create a single 3D data note sphere"""
	var note_sphere = Node3D.new()
	note_sphere.name = "DataNote_%d" % current_note_id
	
	# Visual sphere
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 1.5
	mesh_instance.mesh = sphere_mesh
	
	# Material based on consciousness level
	var material = StandardMaterial3D.new()
	material.albedo_color = _get_consciousness_color()
	material.emission_enabled = true
	material.emission = _get_consciousness_color() * 0.3
	material.metallic = 0.7
	material.roughness = 0.3
	mesh_instance.material_override = material
	
	note_sphere.add_child(mesh_instance)
	
	# 3D Text label
	var label = Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 2.5, 0)
	label.modulate = Color.WHITE
	note_sphere.add_child(label)
	
	# Floating animation
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(note_sphere, "position:y", pos.y + 2, 2.0)
	tween.tween_property(note_sphere, "position:y", pos.y - 2, 2.0)
	
	note_sphere.position = pos
	add_child(note_sphere)
	
	# Store in database
	note_database[current_note_id] = {
		"text": text,
		"position": pos,
		"created_time": Time.get_unix_time_from_system(),
		"node": note_sphere
	}
	
	active_notes.append(note_sphere)
	current_note_id += 1
	
	return note_sphere

func _get_consciousness_color() -> Color:
	"""Get color based on consciousness level"""
	match consciousness_level:
		0: return Color(0.5, 0.5, 0.5)      # Gray - Dormant
		1: return Color(0.9, 0.9, 0.9)      # Pale - Awakening
		2: return Color(0.2, 0.4, 1.0)      # Blue - Aware
		3: return Color(0.2, 1.0, 0.2)      # Green - Connected
		4: return Color(1.0, 0.84, 0.0)     # Gold - Enlightened
		5: return Color(1.0, 1.0, 1.0)      # White - Transcendent
		_: return Color.WHITE

func _handle_keyboard_input(event: InputEventKey) -> void:
	"""Handle keyboard input for 3D swimming and text entry"""
	if event.pressed:
		var camera = get_viewport().get_camera_3d()
		if camera:
			var camera_forward = -camera.global_transform.basis.z
			var camera_right = camera.global_transform.basis.x
			var camera_up = camera.global_transform.basis.y
			
			match event.keycode:
				KEY_W:
					swim_velocity += camera_forward * swim_acceleration
				KEY_S:
					swim_velocity -= camera_forward * swim_acceleration
				KEY_A:
					swim_velocity -= camera_right * swim_acceleration
				KEY_D:
					swim_velocity += camera_right * swim_acceleration
				KEY_SPACE:
					swim_velocity += camera_up * swim_acceleration
				KEY_SHIFT:
					swim_velocity -= camera_up * swim_acceleration
			KEY_ENTER:
				if is_typing:
					_finish_text_input()
				else:
					_start_text_input()
			KEY_ESCAPE:
				if is_typing:
					_cancel_text_input()
		
		# Text input while typing
		if is_typing and event.unicode > 0:
			if event.keycode == KEY_BACKSPACE:
				if current_text.length() > 0:
					current_text = current_text.substr(0, current_text.length() - 1)
			else:
				current_text += char(event.unicode)
			_update_text_input_display()

func _handle_mouse_input(event: InputEventMouseButton) -> void:
	"""Handle mouse clicks for interacting with data spheres"""
	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Raycast to detect clicked data spheres
		var space_state = get_world_3d().direct_space_state
		var camera = get_viewport().get_camera_3d()
		if camera:
			var from = camera.global_position
			var to = from + camera.project_ray_normal(event.position) * 1000
			
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			
			if result:
				var clicked_node = result.collider
				_interact_with_data_sphere(clicked_node)

func _update_swimming_physics(delta: float) -> void:
	"""Update 3D swimming movement"""
	# Apply swimming physics
	swim_velocity *= swim_drag
	position += swim_velocity * delta * swim_speed

func _update_data_spheres(delta: float) -> void:
	"""Update floating data sphere animations"""
	for note in active_notes:
		if is_instance_valid(note):
			# Subtle rotation
			note.rotation.y += delta * 0.5
			# Gentle bobbing is handled by tween

func _manage_note_visibility() -> void:
	"""Show/hide notes based on distance and max visible count"""
	if active_notes.size() <= max_visible_notes:
		return
	
	# Sort by distance from player
	var sorted_notes = active_notes.duplicate()
	sorted_notes.sort_custom(func(a, b): return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position))
	
	# Hide distant notes
	for i in range(sorted_notes.size()):
		if is_instance_valid(sorted_notes[i]):
			sorted_notes[i].visible = i < max_visible_notes

func _start_text_input() -> void:
	"""Start 3D text input mode"""
	is_typing = true
	current_text = ""
	
	# Create text input sphere
	text_input_sphere = Node3D.new()
	
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 2.0
	mesh_instance.mesh = sphere_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.CYAN
	material.emission_enabled = true
	material.emission = Color.CYAN * 0.5
	material.flags_transparent = true
	material.albedo_color.a = 0.7
	mesh_instance.material_override = material
	
	text_input_sphere.add_child(mesh_instance)
	text_input_sphere.position = position + Vector3(0, 3, 0)
	add_child(text_input_sphere)
	
	show_ub_visual("✍️ Text input mode activated - type your note!")

func _update_text_input_sphere(delta: float) -> void:
	"""Update the text input sphere display"""
	if text_input_sphere:
		# Follow player
		text_input_sphere.position = position + Vector3(0, 3, 0)
		# Gentle pulse
		var scale = 1.0 + sin(Time.get_ticks_msec() * 0.003) * 0.1
		text_input_sphere.scale = Vector3.ONE * scale

func _update_text_input_display() -> void:
	"""Update the text being typed"""
	if text_input_sphere:
		# Remove existing label if any
		for child in text_input_sphere.get_children():
			if child is Label3D:
				child.queue_free()
		
		# Add new label with current text
		var label = Label3D.new()
		label.text = current_text + "_"  # Cursor
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.position = Vector3(0, 2.5, 0)
		text_input_sphere.add_child(label)

func _finish_text_input() -> void:
	"""Finish text input and create new data note"""
	if current_text.strip_edges() != "":
		var new_pos = position + Vector3(randf_range(-5, 5), randf_range(-2, 2), randf_range(-5, 5))
		_create_data_note_sphere(current_text, new_pos)
		show_ub_visual("💫 Created new data note: " + current_text.substr(0, 20) + "...")
	
	_cancel_text_input()

func _cancel_text_input() -> void:
	"""Cancel text input mode"""
	is_typing = false
	current_text = ""
	if text_input_sphere:
		text_input_sphere.queue_free()
		text_input_sphere = null
	show_ub_visual("❌ Text input cancelled")

func _interact_with_data_sphere(sphere_node: Node) -> void:
	"""Interact with a clicked data sphere"""
	# Find the note data
	for note_id in note_database:
		var note_data = note_database[note_id]
		if note_data.node == sphere_node or sphere_node.get_parent() == note_data.node:
			show_ub_visual("📝 Viewing note: " + note_data.text)
			# Could add edit functionality here
			break

func _cleanup_data_spheres() -> void:
	"""Cleanup all data spheres"""
	for note in active_notes:
		if is_instance_valid(note):
			note.queue_free()
	active_notes.clear()
	note_database.clear()

# ===== DATA PERSISTENCE SYSTEM =====

func save_notepad_data() -> void:
	"""Save all notes to persistent storage"""
	var save_data = {
		"notes": note_database,
		"player_position": position,
		"consciousness_level": consciousness_level
	}
	
	# Use AkashicRecords for storage if available
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic:
			akashic.store_being_data(being_uuid, save_data)
			show_ub_visual("💾 Notepad data saved to Akashic Records")

func load_notepad_data() -> void:
	"""Load notes from persistent storage"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic:
			var save_data = akashic.get_being_data(being_uuid)
			if save_data and save_data.has("notes"):
				_restore_notes_from_data(save_data.notes)
				show_ub_visual("📚 Notepad data loaded from Akashic Records")

func _restore_notes_from_data(notes_data: Dictionary) -> void:
	"""Restore notes from saved data"""
	for note_id in notes_data:
		var note_data = notes_data[note_id]
		_create_data_note_sphere(note_data.text, note_data.position)