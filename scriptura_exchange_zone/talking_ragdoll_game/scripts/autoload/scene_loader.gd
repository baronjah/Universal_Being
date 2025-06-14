# ==================================================
# SCRIPT NAME: scene_loader.gd
# DESCRIPTION: Loads and saves scene configurations from text files
# CREATED: 2025-05-23 - Dynamic scene creation system
# ==================================================

extends UniversalBeingBase
signal scene_loaded(scene_name: String)
signal scene_saved(scene_name: String)

# Scene data directory
const SCENES_DIR = "user://scenes/"
const SCENE_EXTENSION = ".scene.txt"

# Current scene data
var current_scene_name: String = "default"
var current_scene_objects: Array = []

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Create scenes directory if it doesn't exist
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("scenes"):
		dir.make_dir("scenes")
	
	# Copy example scenes if they don't exist
	_copy_example_scenes()
	
	# Create default scene if it doesn't exist
	if not FileAccess.file_exists(SCENES_DIR + "default" + SCENE_EXTENSION):
		save_default_scene()

func _copy_example_scenes() -> void:
	# Check if we need to copy example scenes
	var example_scenes = {
		"playground": """# Playground Scene
# A fun obstacle course for the ragdoll

# Central platform
box 0 0 0 scale=3

# Ramps on all sides
ramp 5 0 0 rotation_y=90
ramp -5 0 0 rotation_y=-90
ramp 0 0 5 rotation_y=0
ramp 0 0 -5 rotation_y=180

# Trees for decoration
tree 8 0 8
tree -8 0 8
tree 8 0 -8
tree -8 0 -8

# Bouncy balls
ball 3 5 3
ball -3 5 3
ball 3 5 -3
ball -3 5 -3

# Some rocks to stumble over
rock 2 0 2
rock -2 0 -2

# Ragdoll spawn point
ragdoll 0 5 0""",
		
		"forest": """# Forest Scene
# A peaceful forest environment

# Trees in a grid pattern
tree -10 0 -10
tree -5 0 -10
tree 0 0 -10
tree 5 0 -10
tree 10 0 -10

tree -10 0 -5
tree 5 0 -5
tree 10 0 -5

tree -10 0 0
tree 10 0 0

tree -10 0 5
tree -5 0 5
tree 10 0 5

tree -10 0 10
tree -5 0 10
tree 0 0 10
tree 5 0 10
tree 10 0 10

# Rocks scattered around
rock -7 0 -3
rock 3 0 -7
rock -4 0 6
rock 6 0 4
rock 0 0 0

# A box to sit on
box 0 0.5 3

# Peaceful ragdoll
ragdoll 0 5 3""",
		
		"physics_test": """# Physics Test Scene
# Test different physics interactions

# Tower of boxes
box 0 1 0
box 0 2 0
box 0 3 0
box 0 4 0
box 0 5 0

# Ball pit
ball -3 1 -3
ball -2 1 -3
ball -1 1 -3
ball 0 1 -3
ball 1 1 -3
ball 2 1 -3
ball 3 1 -3

# Domino line
box -5 1 5 scale=0.5
box -4 1 5 scale=0.5
box -3 1 5 scale=0.5
box -2 1 5 scale=0.5
box -1 1 5 scale=0.5
box 0 1 5 scale=0.5
box 1 1 5 scale=0.5
box 2 1 5 scale=0.5
box 3 1 5 scale=0.5
box 4 1 5 scale=0.5
box 5 1 5 scale=0.5

# Launch ramp
ramp 0 0 8 rotation_x=45

# Ragdoll ready to cause chaos
ragdoll 0 10 10"""
	}
	
	# Copy each example scene to user directory
	for scene_name in example_scenes:
		var file_path = SCENES_DIR + scene_name + SCENE_EXTENSION
		if not FileAccess.file_exists(file_path):
			var file = FileAccess.open(file_path, FileAccess.WRITE)
			file.store_string(example_scenes[scene_name])
			file.close()
			print("Created example scene: " + scene_name)


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

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func save_default_scene() -> void:
	var default_scene = """# Default Scene
# Format: object_type x y z [properties]

# Ground is already in the scene

# Some starter objects
tree 5 0 0
rock -5 0 0
box 0 0 -5
ramp 0 0 5 rotation_y=30

# Ragdoll spawn point
ragdoll 0 5 0 walking=false
"""
	
	var file = FileAccess.open(SCENES_DIR + "default" + SCENE_EXTENSION, FileAccess.WRITE)
	file.store_string(default_scene)
	file.close()

func load_scene(scene_name: String) -> bool:
	var file_path = SCENES_DIR + scene_name + SCENE_EXTENSION
	
	if not FileAccess.file_exists(file_path):
		print("Scene file not found: " + file_path)
		return false
	
	# Clear current scene
	WorldBuilder.clear_all_objects()
	
	# Reset ragdoll if exists
	var ragdolls = get_tree().get_nodes_in_group("ragdoll")
	for ragdoll in ragdolls:
		ragdoll.queue_free()
	
	# Load new scene
	var file = FileAccess.open(file_path, FileAccess.READ)
	var line_number = 0
	
	while not file.eof_reached():
		line_number += 1
		var line = file.get_line().strip_edges()
		
		# Skip comments and empty lines
		if line.begins_with("#") or line.is_empty():
			continue
		
		# Parse line
		_parse_scene_line(line, line_number)
	
	file.close()
	current_scene_name = scene_name
	emit_signal("scene_loaded", scene_name)
	return true

func _parse_scene_line(line: String, line_number: int) -> void:
	var parts = line.split(" ", false)
	if parts.size() < 4:
		print("Invalid scene line " + str(line_number) + ": " + line)
		return
	
	var object_type = parts[0].to_lower()
	var x = parts[1].to_float()
	var y = parts[2].to_float()
	var z = parts[3].to_float()
	var position = Vector3(x, y, z)
	
	# Parse additional properties
	var properties = {}
	for i in range(4, parts.size()):
		var prop = parts[i]
		if "=" in prop:
			var kv = prop.split("=")
			properties[kv[0]] = kv[1]
	
	# Create object based on type
	match object_type:
		"tree":
			_create_object_at_position("tree", position, properties)
		"rock":
			_create_object_at_position("rock", position, properties)
		"box":
			_create_object_at_position("box", position, properties)
		"ball":
			_create_object_at_position("ball", position, properties)
		"ramp":
			_create_object_at_position("ramp", position, properties)
		"sun":
			_create_object_at_position("sun", position, properties)
		"astral_being":
			_create_object_at_position("astral_being", position, properties)
		"pathway":
			_create_object_at_position("pathway", position, properties)
		"bush":
			_create_object_at_position("bush", position, properties)
		"fruit":
			_create_object_at_position("fruit", position, properties)
		"ragdoll":
			_create_ragdoll_at_position(position, properties)
		_:
			print("Unknown object type: " + object_type)

func _create_object_at_position(type: String, position: Vector3, properties: Dictionary) -> void:
	# Store the position for WorldBuilder to use
	WorldBuilder.override_spawn_position = position
	WorldBuilder.use_override_position = true
	
	# Create object
	match type:
		"tree":
			WorldBuilder.create_tree()
		"rock":
			WorldBuilder.create_rock()
		"box":
			WorldBuilder.create_box()
		"ball":
			WorldBuilder.create_ball()
		"ramp":
			WorldBuilder.create_ramp()
		"sun":
			WorldBuilder.create_sun()
		"astral_being":
			WorldBuilder.create_astral_being()
		"pathway":
			WorldBuilder.create_pathway()
		"bush":
			WorldBuilder.create_bush()
		"fruit":
			WorldBuilder.create_fruit()
	
	# Reset override
	WorldBuilder.use_override_position = false
	
	# Apply properties to the last created object
	var objects = WorldBuilder.get_spawned_objects()
	if not objects.is_empty():
		var obj = objects[-1]
		_apply_properties(obj, properties)

func _create_ragdoll_at_position(position: Vector3, properties: Dictionary) -> void:
	# Check if a ragdoll already exists
	var existing_ragdolls = get_tree().get_nodes_in_group("ragdolls")
	if not existing_ragdolls.is_empty():
		print("Ragdoll already exists in scene, skipping creation")
		return
	
	# Create ragdoll using world builder for consistency
	WorldBuilder.override_spawn_position = position
	WorldBuilder.use_override_position = true
	WorldBuilder.create_ragdoll()
	WorldBuilder.use_override_position = false
	
	# Apply properties to the ragdoll
	await get_tree().process_frame  # Wait for ragdoll to be created
	var ragdolls = get_tree().get_nodes_in_group("ragdolls")
	if not ragdolls.is_empty():
		var ragdoll = ragdolls[0]
		# Apply any action properties
		if properties.has("action"):
			match properties["action"]:
				"walk":
					if ragdoll.has_method("start_walking"):
						ragdoll.start_walking()
				"talk":
					if ragdoll.has_method("_speak_random_dialogue"):
						ragdoll._speak_random_dialogue()

func _apply_properties(obj: Node3D, properties: Dictionary) -> void:
	for key in properties:
		match key:
			"rotation_x":
				obj.rotation.x = deg_to_rad(properties[key].to_float())
			"rotation_y":
				obj.rotation.y = deg_to_rad(properties[key].to_float())
			"rotation_z":
				obj.rotation.z = deg_to_rad(properties[key].to_float())
			"scale":
				var scale_val = properties[key].to_float()
				obj.scale = Vector3.ONE * scale_val

func save_current_scene() -> void:
	var file = FileAccess.open(SCENES_DIR + current_scene_name + SCENE_EXTENSION, FileAccess.WRITE)
	
	# Header
	file.store_line("# Scene: " + current_scene_name)
	file.store_line("# Saved: " + Time.get_datetime_string_from_system())
	file.store_line("")
	
	# Save all spawned objects
	var objects = WorldBuilder.get_spawned_objects()
	for obj in objects:
		var line = _object_to_scene_line(obj)
		if not line.is_empty():
			file.store_line(line)
	
	# Save ragdoll if exists
	var ragdolls = get_tree().get_nodes_in_group("ragdoll")
	for ragdoll in ragdolls:
		file.store_line("ragdoll " + _vector_to_string(ragdoll.global_position))
	
	file.close()
	emit_signal("scene_saved", current_scene_name)

func _object_to_scene_line(obj: Node3D) -> String:
	var type = ""
	
	# Determine type from name
	if "Tree" in obj.name:
		type = "tree"
	elif "Rock" in obj.name:
		type = "rock"
	elif "Box" in obj.name:
		type = "box"
	elif "Ball" in obj.name:
		type = "ball"
	elif "Ramp" in obj.name:
		type = "ramp"
	else:
		return ""
	
	var line = type + " " + _vector_to_string(obj.global_position)
	
	# Add rotation if not default
	if obj.rotation != Vector3.ZERO:
		if obj.rotation.x != 0:
			line += " rotation_x=" + str(rad_to_deg(obj.rotation.x))
		if obj.rotation.y != 0:
			line += " rotation_y=" + str(rad_to_deg(obj.rotation.y))
		if obj.rotation.z != 0:
			line += " rotation_z=" + str(rad_to_deg(obj.rotation.z))
	
	return line

func _vector_to_string(v: Vector3) -> String:
	return str(v.x) + " " + str(v.y) + " " + str(v.z)

func list_available_scenes() -> Array:
	var scenes = []
	var dir = DirAccess.open(SCENES_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(SCENE_EXTENSION):
				scenes.append(file_name.replace(SCENE_EXTENSION, ""))
			file_name = dir.get_next()
	return scenes

func create_scene_from_template(scene_name: String, template: String) -> void:
	var file_path = SCENES_DIR + scene_name + SCENE_EXTENSION
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(template)
	file.close()