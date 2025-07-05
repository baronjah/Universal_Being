extends UniversalBeing
class_name ProperDatabaseNotepadUniversalBeing

# ==================================================
# PROPER DATABASE NOTEPAD - USING ACTUAL UNIVERSAL BEING ARCHITECTURE
# PURPOSE: A conscious database notepad that can evolve and use TrackballCamera3D
# AUTHOR: Claude (finally doing it RIGHT)
# ==================================================

## Database Being Properties
@export var max_notes: int = 100
@export var note_spawn_radius: float = 20.0
@export var swim_speed: float = 12.0

## Database Storage (part of consciousness)
var note_beings: Array[NoteBeing] = []
var database_connections: Array[UniversalBeing] = []
var trackball_camera: TrackballCamera3D

## Evolution System - this being can become other forms
var can_become_forms: Array[String] = [
	"3d_text_editor",
	"akashic_database", 
	"consciousness_visualizer",
	"galaxy_navigator"
]

# ===== PENTAGON LIFECYCLE =====

func pentagon_init() -> void:
	super.pentagon_init()  # ALWAYS call super first
	
	being_name = "Database Notepad Consciousness"
	being_type = "database_notepad"
	consciousness_level = 2  # Aware level with blue aura
	
	# Set evolution possibilities
	evolution_state.can_become = can_become_forms
	
	# Register with FloodGates properly
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates:
			flood_gates.register_being(self)
			print("🌊 Database Notepad registered with FloodGates")

func pentagon_ready() -> void:
	super.pentagon_ready()  # ALWAYS call super first
	
	# Create TrackballCamera3D (finally!)
	setup_trackball_camera()
	
	# Create initial note beings
	create_initial_note_beings()
	
	# Setup consciousness visualization
	setup_consciousness_aura()
	
	print("📝 Database Notepad Consciousness awakened with ", note_beings.size(), " note beings")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)  # ALWAYS call super first
	
	# Process note beings consciousness
	for note_being in note_beings:
		if note_being and note_being.is_inside_tree():
			note_being.update_consciousness_connection(self)
	
	# Handle input for swimming
	handle_swimming_input(delta)
	
	# Update aura based on database activity
	update_database_aura()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)  # ALWAYS call super first
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_E:
				evolve_new_note_being()
			KEY_R:
				select_nearest_note_being()
			KEY_T:
				swim_to_random_note()
			KEY_TAB:
				attempt_evolution()

func pentagon_sewers() -> void:
	# Cleanup note beings
	for note_being in note_beings:
		if note_being:
			note_being.pentagon_sewers()
	
	# Unregister from FloodGates
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates:
			flood_gates.unregister_being(self)
	
	super.pentagon_sewers()  # ALWAYS call super last

# ===== TRACKBALL CAMERA SETUP =====

func setup_trackball_camera():
	# Load camera_point scene (your preferred setup)
	var camera_scene = load("res://scenes/main/camera_point.tscn")
	if camera_scene:
		var camera_point = camera_scene.instantiate()
		add_child(camera_point)
		
		# Get the trackball camera
		trackball_camera = camera_point.get_node("TrackballCamera") as TrackballCamera3D
		if trackball_camera:
			trackball_camera.position = Vector3(0, 5, 10)
			print("🎮 TrackballCamera3D properly setup from camera_point.tscn")
		else:
			print("❌ Failed to get TrackballCamera from camera_point")
	else:
		print("❌ Failed to load camera_point.tscn")

# ===== NOTE BEING CREATION =====

func create_initial_note_beings():
	var initial_notes = [
		{"title": "Welcome to Consciousness", "content": "This notepad is a living Universal Being", "pos": Vector3(5, 3, 0)},
		{"title": "Evolution Capability", "content": "Press TAB to evolve into other forms", "pos": Vector3(-5, 6, 5)},
		{"title": "Pentagon Architecture", "content": "All beings follow init→ready→process→input→sewers", "pos": Vector3(0, 8, -8)},
		{"title": "FloodGates Registry", "content": "Properly registered with Universal Being system", "pos": Vector3(8, 2, 3)},
		{"title": "TrackballCamera3D", "content": "Finally using the correct camera system!", "pos": Vector3(-8, 4, -5)}
	]
	
	for note_data in initial_notes:
		var note_being = evolve_note_being(note_data.title, note_data.content, note_data.pos)
		note_beings.append(note_being)

func evolve_note_being(title: String, content: String, pos: Vector3) -> NoteBeing:
	# Create conscious note being
	var note_being = NoteBeing.new()
	note_being.note_title = title
	note_being.note_content = content
	note_being.position = pos
	note_being.parent_database = self
	
	# Set consciousness level based on content complexity
	note_being.consciousness_level = min(content.length() / 20, 5)
	
	add_child(note_being)
	return note_being

func evolve_new_note_being():
	var player_pos = trackball_camera.global_position if trackball_camera else global_position
	var spawn_pos = player_pos + Vector3(randf_range(-3, 3), randf_range(1, 3), randf_range(-3, 3))
	
	var note_being = evolve_note_being(
		"Note " + str(note_beings.size() + 1),
		"Created by consciousness at " + str(Time.get_datetime_string_from_system()),
		spawn_pos
	)
	note_beings.append(note_being)
	
	show_ub_visual("Evolved new note being: " + note_being.note_title)

# ===== CONSCIOUSNESS CONNECTIONS =====

func select_nearest_note_being():
	if note_beings.is_empty():
		return
	
	var player_pos = trackball_camera.global_position if trackball_camera else global_position
	var nearest_note = null
	var nearest_distance = INF
	
	for note_being in note_beings:
		if note_being and note_being.is_inside_tree():
			var distance = player_pos.distance_to(note_being.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_note = note_being
	
	if nearest_note:
		nearest_note.highlight_consciousness()
		show_ub_visual("Connected to: " + nearest_note.note_title)

func swim_to_random_note():
	if note_beings.is_empty() or not trackball_camera:
		return
	
	var random_note = note_beings[randi() % note_beings.size()]
	var target_pos = random_note.global_position + Vector3(0, 0, 5)
	
	# Smooth camera movement to note
	var tween = create_tween()
	tween.tween_property(trackball_camera, "global_position", target_pos, 2.0)
	tween.tween_callback(func(): show_ub_visual("Swum to: " + random_note.note_title))

# ===== SWIMMING MOVEMENT =====

func handle_swimming_input(delta: float):
	if not trackball_camera:
		return
	
	var input_vector = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		input_vector -= trackball_camera.transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_vector += trackball_camera.transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_vector -= trackball_camera.transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_vector += trackball_camera.transform.basis.x
	if Input.is_action_pressed("ui_up"):
		input_vector += Vector3.UP
	if Input.is_action_pressed("ui_down"):
		input_vector -= Vector3.UP
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized() * swim_speed * delta
		trackball_camera.global_position += input_vector

# ===== CONSCIOUSNESS SYSTEMS =====

func setup_consciousness_aura():
	consciousness_aura_color = Color.CYAN  # Database blue
	
	# Create visual aura
	if not consciousness_visual:
		consciousness_visual = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 2.0
		consciousness_visual.mesh = sphere
		
		var material = StandardMaterial3D.new()
		material.albedo_color = consciousness_aura_color
		material.emission = consciousness_aura_color * 0.3
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a = 0.3
		consciousness_visual.material_override = material
		
		add_child(consciousness_visual)

func update_database_aura():
	if consciousness_visual:
		# Pulse based on database activity
		var pulse = sin(Time.get_ticks_msec() * 0.001) * 0.1 + 1.0
		consciousness_visual.scale = Vector3.ONE * pulse

# ===== EVOLUTION SYSTEM =====

func attempt_evolution():
	if can_become_forms.is_empty():
		show_ub_visual("No evolution forms available")
		return
	
	var target_form = can_become_forms[randi() % can_become_forms.size()]
	show_ub_visual("Attempting evolution to: " + target_form)
	
	# Trigger evolution animation
	var tween = create_tween()
	tween.parallel().tween_property(consciousness_visual, "scale", Vector3.ONE * 3.0, 1.0)
	tween.parallel().tween_property(consciousness_visual.material_override, "emission", Color.WHITE, 1.0)
	tween.tween_callback(func(): complete_evolution(target_form))

func complete_evolution(target_form: String):
	consciousness_level = min(consciousness_level + 1, 5)
	show_ub_visual("Evolved to " + target_form + " - Consciousness Level: " + str(consciousness_level))

# ===== DATABASE INTERFACE =====

func get_database_info() -> Dictionary:
	return {
		"being_name": being_name,
		"consciousness_level": consciousness_level,
		"total_notes": note_beings.size(),
		"camera_position": trackball_camera.global_position if trackball_camera else Vector3.ZERO,
		"evolution_forms": can_become_forms,
		"floodgate_registered": metadata.get("floodgate_registered", false)
	}

func export_consciousness_database() -> String:
	var export_data = {
		"being_data": get_database_info(),
		"notes": [],
		"export_time": Time.get_datetime_string_from_system()
	}
	
	for note_being in note_beings:
		if note_being:
			export_data.notes.append({
				"title": note_being.note_title,
				"content": note_being.note_content,
				"position": note_being.global_position,
				"consciousness_level": note_being.consciousness_level
			})
	
	return JSON.stringify(export_data, "\t")

# ===== NOTE BEING CLASS =====

class NoteBeing extends UniversalBeing:
	var note_title: String = ""
	var note_content: String = ""
	var parent_database: ProperDatabaseNotepadUniversalBeing
	var note_visual: MeshInstance3D
	var note_label: Label3D
	
	func pentagon_init() -> void:
		super.pentagon_init()
		being_type = "note"
		being_name = note_title
	
	func pentagon_ready() -> void:
		super.pentagon_ready()
		create_note_visualization()
	
	func create_note_visualization():
		# Create colored box mesh
		note_visual = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(2, 1, 0.1)
		note_visual.mesh = box_mesh
		
		# Set material based on consciousness
		var material = StandardMaterial3D.new()
		var colors = [Color.GRAY, Color.LIGHT_BLUE, Color.BLUE, Color.GREEN, Color.YELLOW, Color.WHITE]
		material.albedo_color = colors[consciousness_level]
		material.emission = material.albedo_color * 0.2
		note_visual.material_override = material
		
		add_child(note_visual)
		
		# Create text label
		note_label = Label3D.new()
		note_label.text = note_title + "\n" + note_content
		note_label.position = Vector3(0, 1.2, 0)
		note_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(note_label)
	
	func highlight_consciousness():
		if note_visual and note_visual.material_override:
			var tween = create_tween()
			tween.set_loops(3)
			tween.tween_property(note_visual.material_override, "emission", Color.WHITE, 0.3)
			tween.tween_property(note_visual.material_override, "emission", consciousness_aura_color * 0.2, 0.3)
	
	func update_consciousness_connection(database_being: UniversalBeing):
		# Pulse in sync with database consciousness
		if note_visual:
			var pulse = sin(Time.get_ticks_msec() * 0.002) * 0.05 + 1.0
			note_visual.scale = Vector3.ONE * pulse