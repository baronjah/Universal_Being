extends Node3D
class_name WorkingDatabaseNotepad3D

# WORKING 3D DATABASE NOTEPAD - ACTUAL FUNCTIONING VERSION
# You can swim through data, create notes, see them in 3D space

signal note_created(note_data: Dictionary)
signal note_selected(note_data: Dictionary)
signal data_swum_to(position: Vector3)

# REAL DATABASE STORAGE
var notes_database: Array[Dictionary] = []
var note_id_counter: int = 0

# 3D SWIMMING PLAYER
var player_body: CharacterBody3D
var camera: Camera3D
var swim_speed: float = 15.0
var look_sensitivity: float = 0.002

# 3D NOTE VISUALIZATION
var note_meshes: Array[MeshInstance3D] = []
var note_labels: Array[Label3D] = []
var selected_note: Dictionary = {}

# INPUT STATE
var mouse_captured: bool = false

func _ready():
	name = "WorkingDatabaseNotepad3D"
	print("🗄️ WORKING DATABASE NOTEPAD 3D - INITIALIZING...")
	
	# Create the swimming player
	create_swimming_player()
	
	# Create some initial test data
	create_test_data()
	
	# Setup input
	setup_input_capture()
	
	print("✅ Database Notepad 3D ready - Press WASD to swim, mouse to look, E to create note, R to select nearest")

func create_swimming_player():
	# Create player body
	player_body = CharacterBody3D.new()
	player_body.position = Vector3(0, 5, 0)
	add_child(player_body)
	
	# Create collision shape
	var collision = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.height = 2.0
	shape.radius = 0.5
	collision.shape = shape
	player_body.add_child(collision)
	
	# Create camera
	camera = Camera3D.new()
	camera.position = Vector3(0, 0.5, 0)
	player_body.add_child(camera)
	
	print("🏊 Swimming player created at:", player_body.position)

func create_test_data():
	# Create initial database entries
	add_note("Welcome Note", "This is your first note in 3D space!", Vector3(5, 3, 0))
	add_note("Database Info", "This notepad stores data in real 3D coordinates", Vector3(-5, 6, 5))
	add_note("Swimming Guide", "Use WASD to swim through your data", Vector3(0, 8, -8))
	add_note("Creation Help", "Press E to create new notes at your position", Vector3(8, 2, 3))
	
	print("📝 Created", notes_database.size(), "initial notes in database")

func add_note(title: String, content: String, pos: Vector3 = Vector3.ZERO) -> Dictionary:
	var note_data = {
		"id": note_id_counter,
		"title": title,
		"content": content,
		"position": pos if pos != Vector3.ZERO else player_body.global_position + Vector3(randf_range(-3, 3), randf_range(1, 3), randf_range(-3, 3)),
		"created_time": Time.get_ticks_msec(),
		"color": Color(randf(), randf(), randf(), 0.8)
	}
	note_id_counter += 1
	
	# Add to database
	notes_database.append(note_data)
	
	# Create 3D visualization
	create_note_visualization(note_data)
	
	note_created.emit(note_data)
	print("📝 Note created:", note_data.title, "at", note_data.position)
	return note_data

func create_note_visualization(note_data: Dictionary):
	# Create mesh for the note
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(2, 1, 0.1)
	mesh_instance.mesh = box_mesh
	mesh_instance.position = note_data.position
	
	# Create material with note color
	var material = StandardMaterial3D.new()
	material.albedo_color = note_data.color
	material.emission = note_data.color * 0.3
	mesh_instance.material_override = material
	
	add_child(mesh_instance)
	note_meshes.append(mesh_instance)
	
	# Create label
	var label = Label3D.new()
	label.text = note_data.title + "\n" + note_data.content
	label.position = note_data.position + Vector3(0, 1.2, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color.WHITE
	add_child(label)
	note_labels.append(label)

func setup_input_capture():
	set_process_input(true)
	set_process(true)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if mouse_captured:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			mouse_captured = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			mouse_captured = true
	
	if event is InputEventMouseMotion and mouse_captured:
		# Rotate camera with mouse
		player_body.rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_E:
				create_note_at_player()
			KEY_R:
				select_nearest_note()
			KEY_T:
				swim_to_random_note()

func _process(delta):
	if not player_body:
		return
	
	# Swimming movement
	var input_vector = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		input_vector -= player_body.transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_vector += player_body.transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_vector -= player_body.transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_vector += player_body.transform.basis.x
	if Input.is_action_pressed("ui_up"):
		input_vector += Vector3.UP
	if Input.is_action_pressed("ui_down"):
		input_vector -= Vector3.UP
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized() * swim_speed
		player_body.velocity = input_vector
		player_body.move_and_slide()

func create_note_at_player():
	var title = "Note " + str(note_id_counter + 1)
	var content = "Created at " + str(Time.get_datetime_string_from_system())
	var pos = player_body.global_position + camera.transform.basis.z * -3
	add_note(title, content, pos)

func select_nearest_note():
	if notes_database.is_empty():
		print("❌ No notes in database")
		return
	
	var nearest_note = null
	var nearest_distance = INF
	
	for note in notes_database:
		var distance = player_body.global_position.distance_to(note.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_note = note
	
	if nearest_note:
		selected_note = nearest_note
		note_selected.emit(selected_note)
		print("🎯 Selected note:", selected_note.title, "- Distance:", nearest_distance)
		
		# Highlight selected note
		highlight_note(selected_note)

func swim_to_random_note():
	if notes_database.is_empty():
		return
	
	var random_note = notes_database[randi() % notes_database.size()]
	var target_pos = random_note.position + Vector3(0, 0, 3)
	
	# Create swimming tween
	var tween = create_tween()
	tween.tween_property(player_body, "global_position", target_pos, 2.0)
	tween.tween_callback(func(): data_swum_to.emit(target_pos))
	
	print("🏊 Swimming to note:", random_note.title)

func highlight_note(note_data: Dictionary):
	# Find the mesh for this note
	for i in range(notes_database.size()):
		if notes_database[i].id == note_data.id and i < note_meshes.size():
			var mesh = note_meshes[i]
			var material = mesh.material_override as StandardMaterial3D
			if material:
				# Create highlight effect
				var tween = create_tween()
				tween.set_loops(3)
				tween.tween_property(material, "emission", Color.WHITE, 0.3)
				tween.tween_property(material, "emission", note_data.color * 0.3, 0.3)
			break

func get_database_info() -> Dictionary:
	return {
		"total_notes": notes_database.size(),
		"player_position": player_body.global_position if player_body else Vector3.ZERO,
		"selected_note": selected_note,
		"database": notes_database
	}

func export_database() -> String:
	var export_data = {
		"notes": notes_database,
		"export_time": Time.get_datetime_string_from_system()
	}
	return JSON.stringify(export_data, "\t")

func import_database(json_string: String) -> bool:
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("❌ Failed to parse database JSON")
		return false
	
	var data = json.data
	if not data.has("notes"):
		print("❌ Invalid database format")
		return false
	
	# Clear existing
	clear_all_notes()
	
	# Import notes
	for note_data in data.notes:
		notes_database.append(note_data)
		create_note_visualization(note_data)
		note_id_counter = max(note_id_counter, note_data.id + 1)
	
	print("✅ Imported", notes_database.size(), "notes from database")
	return true

func clear_all_notes():
	# Remove all visualizations
	for mesh in note_meshes:
		mesh.queue_free()
	for label in note_labels:
		label.queue_free()
	
	note_meshes.clear()
	note_labels.clear()
	notes_database.clear()
	selected_note = {}

func _get_info_string() -> String:
	var info = get_database_info()
	return "📊 DATABASE NOTEPAD 3D STATUS:\n" + \
		   "Notes: " + str(info.total_notes) + "\n" + \
		   "Position: " + str(info.player_position) + "\n" + \
		   "Selected: " + (info.selected_note.get("title", "None")) + "\n" + \
		   "Controls: WASD+Space/Shift=swim, E=create, R=select, T=swim to random"