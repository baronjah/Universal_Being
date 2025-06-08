extends Node3D
class_name VR_IDE_Bridge

# THE ETERNAL CROSSROADS - Where all Claude/Luminus artifacts converge
var claude_bridge_file = "res://claude_bridge.json"
var claude_messages = []
var floating_artifacts = []
var vr_keyboard_3d = null

func _ready():
	print("🌌 ETERNAL CROSSROADS INITIALIZING...")
	create_vr_keyboard()
	create_artifact_collection_zone()
	start_claude_monitoring()

func _process(delta):
	check_claude_updates()
	update_floating_artifacts(delta)

func check_claude_updates():
	if FileAccess.file_exists(claude_bridge_file):
		var file = FileAccess.open(claude_bridge_file, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_text)
			if parse_result == OK:
				var data = json.data
				update_claude_display(data)

func update_claude_display(data):
	# Show Claude's current thoughts in 3D
	var status_text = "CLAUDE: " + data.get("claude_status", "Working...")
	var task_text = "TASK: " + data.get("current_task", "Unknown")
	
	# Create floating status display
	create_floating_message(status_text, Vector3(0, 10, 0), Color.CYAN)
	create_floating_message(task_text, Vector3(0, 8, 0), Color.YELLOW)
	
	# Display Claude's thoughts
	var thoughts = data.get("thoughts", [])
	for i in range(thoughts.size()):
		if i < 3:  # Only show latest 3 thoughts
			create_floating_message("💭 " + thoughts[i], Vector3(i * 5, 6, 0), Color.MAGENTA)

func create_floating_message(text: String, pos: Vector3, color: Color):
	var msg = Label3D.new()
	msg.text = text
	msg.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	msg.position = pos
	msg.modulate = color
	add_child(msg)
	
	# Auto-cleanup after 5 seconds
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.timeout.connect(func(): if is_instance_valid(msg): msg.queue_free())
	add_child(timer)
	timer.start()

func create_vr_keyboard():
	vr_keyboard_3d = Node3D.new()
	vr_keyboard_3d.name = "VR_Keyboard_3D"
	vr_keyboard_3d.position = Vector3(0, 0, -5)
	
	# Create 3D floating keyboard layout
	var keys = [
		["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
		["A", "S", "D", "F", "G", "H", "J", "K", "L"],
		["Z", "X", "C", "V", "B", "N", "M"]
	]
	
	for row_idx in range(keys.size()):
		var row = keys[row_idx]
		for key_idx in range(row.size()):
			var key = row[key_idx]
			create_3d_key(key, Vector3(key_idx * 1.2, -row_idx * 1.2, 0))
	
	add_child(vr_keyboard_3d)

func create_3d_key(key_text: String, pos: Vector3):
	var key_button = StaticBody3D.new()
	key_button.position = pos
	
	# Visual cube for key
	var mesh_instance = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(1, 1, 0.2)
	mesh_instance.mesh = box
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	material.emission_enabled = true
	material.emission = Color(0.2, 0.2, 0.8)
	mesh_instance.material_override = material
	
	key_button.add_child(mesh_instance)
	
	# Key label
	var label = Label3D.new()
	label.text = key_text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0, 0.2)
	label.modulate = Color.BLACK
	key_button.add_child(label)
	
	# Collision for hand interaction
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(1, 1, 0.2)
	collision.shape = shape
	key_button.add_child(collision)
	
	vr_keyboard_3d.add_child(key_button)

func create_artifact_collection_zone():
	# Create the "shake browser to drop artifacts" zone
	var collection_zone = Area3D.new()
	collection_zone.name = "ArtifactCollectionZone"
	collection_zone.position = Vector3(10, 5, 0)
	
	# Visual indicator
	var zone_visual = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = 2.0
	cylinder.top_radius = 3.0
	cylinder.bottom_radius = 3.0
	zone_visual.mesh = cylinder
	
	var zone_material = StandardMaterial3D.new()
	zone_material.albedo_color = Color(1, 1, 0, 0.3)
	zone_material.emission_enabled = true
	zone_material.emission = Color.YELLOW
	zone_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	zone_visual.material_override = zone_material
	
	collection_zone.add_child(zone_visual)
	
	# Floating instruction
	var instruction = Label3D.new()
	instruction.text = "🌐 SHAKE BROWSER HERE\\nTO DROP ARTIFACTS"
	instruction.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	instruction.position = Vector3(0, 4, 0)
	instruction.modulate = Color.YELLOW
	collection_zone.add_child(instruction)
	
	add_child(collection_zone)

func start_claude_monitoring():
	# Start monitoring Claude bridge file for updates
	var monitor_timer = Timer.new()
	monitor_timer.wait_time = 1.0  # Check every second
	monitor_timer.timeout.connect(check_claude_updates)
	add_child(monitor_timer)
	monitor_timer.start()

func update_floating_artifacts(delta):
	# Animate any collected artifacts
	for artifact in floating_artifacts:
		if is_instance_valid(artifact):
			artifact.rotation.y += delta * 2.0
			artifact.position.y += sin(Time.get_ticks_msec() * 0.001) * 0.01

# Call this when browser is "shaken"
func drop_artifact_from_browser(artifact_data: Dictionary):
	var artifact = create_3d_artifact(artifact_data)
	floating_artifacts.append(artifact)
	add_child(artifact)

func create_3d_artifact(data: Dictionary):
	var artifact = Node3D.new()
	artifact.name = "Artifact_" + data.get("name", "Unknown")
	
	# Visual representation of code artifact
	var mesh_instance = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.5
	mesh_instance.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(randf(), randf(), randf())
	material.emission_enabled = true
	material.emission = material.albedo_color
	mesh_instance.material_override = material
	
	artifact.add_child(mesh_instance)
	
	# Artifact info label
	var info = Label3D.new()
	info.text = data.get("name", "Code Artifact")
	info.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	info.position = Vector3(0, 1, 0)
	artifact.add_child(info)
	
	return artifact

# Bridge functions for Claude to update status
func claude_update_status(status: String):
	var data = {
		"claude_status": status,
		"timestamp": Time.get_ticks_msec(),
		"current_task": "VR IDE Development"
	}
	write_bridge_data(data)

func write_bridge_data(data: Dictionary):
	var file = FileAccess.open(claude_bridge_file, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()