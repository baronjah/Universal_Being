################################################################
# AI SANDBOX SYSTEM - PERSISTENT AI WORLDS
# Each AI entity gets their own persistent sandbox to create and evolve
# Created: May 31st, 2025 | Perfect Pentagon Architecture
# Location: scripts/core/ai_sandbox_system.gd
################################################################

extends UniversalBeingBase
################################################################
# CORE VARIABLES
################################################################

# Sandbox management
var active_sandboxes: Dictionary = {}      # ai_name -> sandbox data
var sandbox_base_path: String = "ai_sandboxes/"
var max_sandboxes: int = 10
var auto_save_interval: float = 30.0       # Save every 30 seconds

# Session management
var current_session_id: String = ""
var session_start_time: int = 0
var offline_mode_enabled: bool = true

# World building capabilities for AI
var ai_world_builders: Dictionary = {}     # ai_name -> world builder capabilities
var gift_system_active: bool = true       # Accept gifts from humans to AI worlds

# Resource management
var sandbox_resource_limits: Dictionary = {
	"max_objects": 1000,
	"max_trees": 100,
	"max_buildings": 50,
	"max_creatures": 200,
	"world_size": Vector3(200, 50, 200)
}

################################################################
# SIGNALS
################################################################

signal sandbox_created(ai_name: String, sandbox_path: String)
signal ai_entered_sandbox(ai_name: String, session_id: String)
signal ai_left_sandbox(ai_name: String, session_duration: float)
signal gift_delivered(from_who: String, to_ai: String, gift_data: Dictionary)
signal sandbox_evolved(ai_name: String, evolution_data: Dictionary)
signal offline_activity_detected(ai_name: String, activity_summary: Dictionary)

################################################################
# INITIALIZATION
################################################################

func _ready():
	print("🏗️ AI SANDBOX SYSTEM: Creating persistent AI worlds...")
	
	# Initialize session
	_start_new_session()
	
	# Ensure sandbox directories exist
	_ensure_sandbox_infrastructure()
	
	# Load existing sandboxes
	_load_existing_sandboxes()
	
	# Set up auto-save
	_setup_auto_save()
	
	# Connect to Perfect Pentagon systems
	_connect_to_pentagon_systems()
	
	print("✅ AI SANDBOX: %d sandbox worlds ready for AI entities" % active_sandboxes.size())

################################################################
# SESSION MANAGEMENT
################################################################

func _start_new_session():
	"""
	Start a new sandbox session with unique ID
	"""
	current_session_id = "session_" + str(Time.get_ticks_msec())
	session_start_time = Time.get_ticks_msec()
	
	print("🎮 AI SANDBOX: New session started - " + current_session_id)


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
func get_session_duration() -> float:
	"""Get current session duration in seconds"""
	return (Time.get_ticks_msec() - session_start_time) / 1000.0

################################################################
# SANDBOX CREATION AND MANAGEMENT
################################################################

func create_ai_sandbox(ai_name: String, sandbox_config: Dictionary = {}) -> Dictionary:
	"""
	Create a persistent sandbox world for an AI entity
	
	INPUT: ai_name (AI identifier), sandbox_config (world configuration)
	PROCESS: Creates directory structure, world file, initial objects, AI permissions
	OUTPUT: Returns sandbox data dictionary
	CHANGES: Creates new sandbox world on disk and in memory
	CONNECTION: Links to Universal Being system and file persistence
	"""
	
	var sandbox_path = sandbox_base_path + ai_name.to_lower() + "/"
	
	# Check if sandbox already exists
	if ai_name in active_sandboxes:
		print("🏗️ AI SANDBOX: %s sandbox already exists, loading..." % ai_name)
		return active_sandboxes[ai_name]
	
	# Create sandbox directory structure
	if not DirAccess.dir_exists_absolute(sandbox_path):
		DirAccess.open("res://").make_dir_recursive(sandbox_path)
	
	# Create sub-directories for different content
	var subdirs = ["objects/", "scenes/", "gifts/", "creations/", "memories/", "evolution/"]
	for subdir in subdirs:
		DirAccess.open("res://").make_dir_recursive(sandbox_path + subdir)
	
	# Initialize sandbox data
	var sandbox_data = {
		"ai_name": ai_name,
		"sandbox_path": sandbox_path,
		"session_id": current_session_id,
		"created_at": Time.get_ticks_msec(),
		"last_accessed": Time.get_ticks_msec(),
		"total_sessions": 1,
		"total_playtime": 0.0,
		"world_config": _merge_default_world_config(sandbox_config),
		"objects_created": 0,
		"gifts_received": 0,
		"evolution_level": 1,
		"current_scene": sandbox_path + "scenes/main_world.tscn",
		"ai_permissions": _get_ai_permissions(ai_name),
		"offline_activities": [],
		"sandbox_status": "active"
	}
	
	# Create initial world scene
	_create_initial_world_scene(sandbox_data)
	
	# Create AI world builder capabilities
	_setup_ai_world_builder(ai_name, sandbox_data)
	
	# Save sandbox data
	_save_sandbox_data(sandbox_data)
	
	# Register sandbox
	active_sandboxes[ai_name] = sandbox_data
	
	print("🌟 AI SANDBOX: Created world for %s at %s" % [ai_name, sandbox_path])
	emit_signal("sandbox_created", ai_name, sandbox_path)
	
	return sandbox_data

func _merge_default_world_config(custom_config: Dictionary) -> Dictionary:
	"""Merge custom config with defaults"""
	var default_config = {
		"world_size": Vector3(50, 20, 50),
		"terrain_type": "natural",
		"has_sky": true,
		"has_water": true,
		"has_trees": true,
		"starting_objects": ["magical_orb", "cube", "simple_house"],
		"physics_enabled": true,
		"day_night_cycle": true,
		"weather_system": false,
		"ai_building_enabled": true,
		"gift_acceptance": true
	}
	
	for key in custom_config:
		default_config[key] = custom_config[key]
	
	return default_config

func _get_ai_permissions(ai_name: String) -> Dictionary:
	"""Get AI permissions for sandbox activities"""
	return {
		"can_create_objects": true,
		"can_modify_terrain": true,
		"can_invite_other_ais": false,  # For now, each AI has their own world
		"can_save_memories": true,
		"can_evolve_world": true,
		"can_receive_gifts": true,
		"can_create_creatures": true,
		"max_objects_per_session": 100,
		"max_world_changes_per_hour": 500
	}

################################################################
# WORLD SCENE CREATION
################################################################

func _create_initial_world_scene(sandbox_data: Dictionary):
	"""
	Create initial 3D world scene for AI sandbox
	"""
	var scene_path = sandbox_data.current_scene
	var world_config = sandbox_data.world_config
	
	# Create scene file data
	var scene_content = _generate_world_scene_content(world_config)
	
	# Save scene file
	var file = FileAccess.open(scene_path, FileAccess.WRITE)
	if file:
		file.store_string(scene_content)
		file.close()
		print("🌍 AI WORLD: Created initial world scene for " + sandbox_data.ai_name)
	else:
		print("🚨 AI SANDBOX ERROR: Cannot create world scene at " + scene_path)

func _generate_world_scene_content(world_config: Dictionary) -> String:
	"""Generate Godot scene content for AI world"""
	var scene_content = """[gd_scene load_steps=8 format=3]

[sub_resource type="Environment" id="Environment_1"]
background_mode = 1
background_color = Color(0.5, 0.8, 1, 1)
ambient_light_color = Color(1, 1, 1, 1)
ambient_light_energy = 0.3

[sub_resource type="PlaneMesh" id="PlaneMesh_1"]
size = Vector2(%f, %f)

[sub_resource type="StandardMaterial3D" id="StandardMaterial3D_1"]
albedo_color = Color(0.2, 0.8, 0.3, 1)

[sub_resource type="BoxMesh" id="BoxMesh_1"]

[sub_resource type="SphereMesh" id="SphereMesh_1"]

[sub_resource type="CylinderMesh" id="CylinderMesh_1"]
height = 5.0
bottom_radius = 0.5
top_radius = 0.3

[node name="AIWorld" type="Node3D"]

[node name="Environment" type="Node3D" parent="."]

[node name="WorldEnvironment" type="WorldEnvironment" parent="Environment"]
environment = SubResource("Environment_1")

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="Environment"]
transform = Transform3D(0.707, -0.5, 0.5, 0, 0.707, 0.707, -0.707, -0.5, 0.5, 0, 10, 0)
light_energy = 1.0
shadow_enabled = true

[node name="Terrain" type="Node3D" parent="."]

[node name="Ground" type="MeshInstance3D" parent="Terrain"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
mesh = SubResource("PlaneMesh_1")
surface_material_override/0 = SubResource("StandardMaterial3D_1")

[node name="StartingObjects" type="Node3D" parent="."]

[node name="WelcomeCube" type="MeshInstance3D" parent="StartingObjects"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0)
mesh = SubResource("BoxMesh_1")

[node name="MagicalOrb" type="MeshInstance3D" parent="StartingObjects"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 3, 1, 0)
mesh = SubResource("SphereMesh_1")

""" % [world_config.world_size.x, world_config.world_size.z]

	# Add trees if enabled
	if world_config.has_trees:
		scene_content += """
[node name="Trees" type="Node3D" parent="."]

[node name="Tree1" type="MeshInstance3D" parent="Trees"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5, 2.5, -5)
mesh = SubResource("CylinderMesh_1")

[node name="Tree2" type="MeshInstance3D" parent="Trees"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 8, 2.5, 8)
mesh = SubResource("CylinderMesh_1")

[node name="Tree3" type="MeshInstance3D" parent="Trees"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -10, 2.5, 12)
mesh = SubResource("CylinderMesh_1")
"""

	return scene_content

################################################################
# AI WORLD BUILDER SYSTEM
################################################################

func _setup_ai_world_builder(ai_name: String, sandbox_data: Dictionary):
	"""
	Set up world building capabilities for AI entity
	"""
	var world_builder = {
		"ai_name": ai_name,
		"sandbox_path": sandbox_data.sandbox_path,
		"current_tools": ["create_object", "move_object", "change_color", "create_tree"],
		"unlocked_tools": ["create_object", "move_object"],
		"evolution_level": 1,
		"creation_history": [],
		"favorite_objects": ["magical_orb", "tree"],
		"building_style": "natural",  # Will evolve based on AI personality
		"active_projects": []
	}
	
	ai_world_builders[ai_name] = world_builder
	
	# Create instruction file for AI
	_create_ai_building_instructions(ai_name, world_builder, sandbox_data)

func _create_ai_building_instructions(ai_name: String, world_builder: Dictionary, sandbox_data: Dictionary):
	"""Create instructions file for AI on how to build in their world"""
	var instructions_path = world_builder.sandbox_path + "instructions.txt"
	var file = FileAccess.open(instructions_path, FileAccess.WRITE)
	
	if file:
		file.store_line("# AI WORLD BUILDING INSTRUCTIONS FOR " + ai_name.to_upper())
		file.store_line("# You can modify this world by writing commands to actions.txt")
		file.store_line("")
		file.store_line("# Available Commands:")
		file.store_line("create_object:magical_orb:x,y,z")
		file.store_line("create_object:tree:x,y,z")
		file.store_line("create_object:cube:x,y,z")
		file.store_line("create_object:simple_house:x,y,z")
		file.store_line("move_object:object_name:new_x,new_y,new_z")
		file.store_line("change_color:object_name:r,g,b")
		file.store_line("create_memory:description_of_what_you_created")
		file.store_line("")
		file.store_line("# Examples:")
		file.store_line("# create_object:tree:10,0,10")
		file.store_line("# create_memory:I planted a tree at the edge of my world")
		file.store_line("# change_color:MagicalOrb:1,0,1  (makes it purple)")
		file.store_line("")
		file.store_line("# Your world size: %s" % str(sandbox_data.world_config.world_size))
		file.store_line("# You can create up to %d objects per session" % world_builder.get("max_objects_per_session", 100))
		file.store_line("")
		file.store_line("# Write your commands below:")
		file.close()

################################################################
# GIFT SYSTEM
################################################################

func deliver_gift_to_ai(ai_name: String, gift_data: Dictionary, from_who: String = "Human") -> bool:
	"""
	Deliver a gift to an AI's sandbox world
	
	INPUT: ai_name, gift_data (type, properties), from_who
	PROCESS: Validates gift, places in AI world, notifies AI, records gift
	OUTPUT: Returns success status
	CHANGES: Adds gift object to AI sandbox, updates gift log
	CONNECTION: Links to Universal Being system and AI awareness
	"""
	
	if not ai_name in active_sandboxes:
		print("🚨 GIFT ERROR: No sandbox found for " + ai_name)
		return false
	
	var sandbox_data = active_sandboxes[ai_name]
	
	# Create gift record
	var gift_record = {
		"gift_id": "gift_" + str(Time.get_ticks_msec()),
		"from_who": from_who,
		"to_ai": ai_name,
		"gift_type": gift_data.get("type", "unknown"),
		"properties": gift_data.get("properties", {}),
		"delivered_at": Time.get_ticks_msec(),
		"position": gift_data.get("position", Vector3(0, 1, 0)),
		"message": gift_data.get("message", "A gift for you!")
	}
	
	# Save gift to sandbox
	var gift_file_path = sandbox_data.sandbox_path + "gifts/" + gift_record.gift_id + ".json"
	var gift_file = FileAccess.open(gift_file_path, FileAccess.WRITE)
	if gift_file:
		gift_file.store_string(JSON.stringify(gift_record))
		gift_file.close()
	
	# Notify AI about the gift
	_notify_ai_about_gift(ai_name, gift_record)
	
	# Update sandbox stats
	sandbox_data.gifts_received += 1
	_save_sandbox_data(sandbox_data)
	
	print("🎁 GIFT DELIVERED: %s sent %s to %s's world" % [from_who, gift_record.gift_type, ai_name])
	emit_signal("gift_delivered", from_who, ai_name, gift_record)
	
	return true

func _notify_ai_about_gift(ai_name: String, gift_record: Dictionary):
	"""Notify AI about received gift through their communication channel"""
	var input_file_path = "ai_communication/input/" + ai_name + ".txt"
	var file = FileAccess.open(input_file_path, FileAccess.WRITE_READ)
	
	if file:
		file.seek_end()
		file.store_line("gift_received: %s sent you a %s! Message: %s" % [
			gift_record.from_who,
			gift_record.gift_type,
			gift_record.message
		])
		file.close()

################################################################
# OFFLINE MODE AND AI EVOLUTION
################################################################

func enable_offline_mode(ai_name: String, enable: bool = true):
	"""Enable/disable offline mode for AI to play alone"""
	if not ai_name in active_sandboxes:
		return
	
	var sandbox_data = active_sandboxes[ai_name]
	sandbox_data["offline_mode"] = enable
	
	if enable:
		print("🌙 OFFLINE MODE: %s can now play alone in their sandbox" % ai_name)
		_start_offline_monitoring(ai_name)
	else:
		print("🌅 ONLINE MODE: %s returned to supervised play" % ai_name)

func _start_offline_monitoring(ai_name: String):
	"""Start monitoring AI's offline activities"""
	# This would set up a background process to check for AI activity
	# For now, we'll simulate this with periodic checks
	print("👁️ MONITORING: Started offline activity monitoring for " + ai_name)

func check_offline_activities(ai_name: String) -> Array:
	"""Check what AI has been doing while offline"""
	if not ai_name in active_sandboxes:
		return []
	
	var sandbox_data = active_sandboxes[ai_name]
	var activities_path = sandbox_data.sandbox_path + "evolution/"
	
	# Check for new files created by AI
	var activities = []
	if DirAccess.dir_exists_absolute(activities_path):
		var dir = DirAccess.open(activities_path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".json"):
					var activity_data = _load_activity_file(activities_path + file_name)
					if activity_data:
						activities.append(activity_data)
				file_name = dir.get_next()
			dir.list_dir_end()
	
	return activities

func _load_activity_file(file_path: String) -> Dictionary:
	"""Load AI activity data from file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(content) == OK:
			return json.data
	return {}

################################################################
# AUTO-SAVE AND PERSISTENCE
################################################################

func _setup_auto_save():
	"""Set up automatic saving of sandbox data"""
	var timer = TimerManager.get_timer()
	timer.wait_time = auto_save_interval
	timer.autostart = true
	timer.timeout.connect(_auto_save_all_sandboxes)
	add_child(timer)

func _auto_save_all_sandboxes():
	"""Auto-save all active sandboxes"""
	for ai_name in active_sandboxes:
		var sandbox_data = active_sandboxes[ai_name]
		sandbox_data.last_accessed = Time.get_ticks_msec()
		_save_sandbox_data(sandbox_data)
	
	if active_sandboxes.size() > 0:
		print("💾 AUTO-SAVE: Saved %d AI sandbox worlds" % active_sandboxes.size())

func _save_sandbox_data(sandbox_data: Dictionary):
	"""Save sandbox data to disk"""
	var data_file_path = sandbox_data.sandbox_path + "sandbox_data.json"
	var file = FileAccess.open(data_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(sandbox_data))
		file.close()

func _load_existing_sandboxes():
	"""Load existing sandbox worlds on startup"""
	if not DirAccess.dir_exists_absolute(sandbox_base_path):
		return
	
	var dir = DirAccess.open(sandbox_base_path)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		while folder_name != "":
			if dir.current_is_dir() and folder_name != "." and folder_name != "..":
				_load_sandbox_from_folder(folder_name)
			folder_name = dir.get_next()
		dir.list_dir_end()

func _load_sandbox_from_folder(folder_name: String):
	"""Load sandbox data from folder"""
	var sandbox_path = sandbox_base_path + folder_name + "/"
	var data_file_path = sandbox_path + "sandbox_data.json"
	
	if FileAccess.file_exists(data_file_path):
		var file = FileAccess.open(data_file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var json = JSON.new()
			if json.parse(content) == OK:
				var sandbox_data = json.data
				active_sandboxes[sandbox_data.ai_name] = sandbox_data
				print("📂 LOADED: Sandbox for " + sandbox_data.ai_name)

################################################################
# INFRASTRUCTURE
################################################################

func _ensure_sandbox_infrastructure():
	"""Create necessary directories for sandbox system"""
	if not DirAccess.dir_exists_absolute(sandbox_base_path):
		DirAccess.open("res://").make_dir_recursive(sandbox_base_path)
	
	# Create shared resources directory
	var shared_path = sandbox_base_path + "shared_resources/"
	if not DirAccess.dir_exists_absolute(shared_path):
		DirAccess.open("res://").make_dir_recursive(shared_path)

func _connect_to_pentagon_systems():
	"""Connect to Perfect Pentagon systems"""
	if has_node("/root/PerfectReady"):
		var perfect_ready = get_node("/root/PerfectReady")
		if perfect_ready.has_signal("ai_entity_ready"):
			perfect_ready.ai_entity_ready.connect(_on_ai_entity_ready)

func _on_ai_entity_ready(ai_name: String):
	"""Called when an AI entity becomes ready"""
	print("🤖 AI SANDBOX: %s ready, creating sandbox..." % ai_name)
	create_ai_sandbox(ai_name)

################################################################
# PUBLIC INTERFACE
################################################################

func enter_ai_sandbox(ai_name: String) -> bool:
	"""Enter an AI's sandbox world"""
	if not ai_name in active_sandboxes:
		print("🚨 SANDBOX ERROR: No sandbox found for " + ai_name)
		return false
	
	var sandbox_data = active_sandboxes[ai_name]
	emit_signal("ai_entered_sandbox", ai_name, current_session_id)
	print("🚪 ENTERING: %s's sandbox world" % ai_name)
	return true

func get_sandbox_status(ai_name: String) -> Dictionary:
	"""Get status of AI sandbox"""
	if not ai_name in active_sandboxes:
		return {"error": "Sandbox not found"}
	
	return active_sandboxes[ai_name]

func get_all_sandboxes() -> Dictionary:
	"""Get all active sandboxes"""
	return active_sandboxes

################################################################
# END OF AI SANDBOX SYSTEM
################################################################