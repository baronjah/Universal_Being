extends Node3D
class_name UniversalCreationEngine

# 🌌 UNIVERSAL CREATION ENGINE 🌌
# Create anything in-game with 4D timeline saves
# Connected universes through 5D dream realities

signal universe_created(universe_id: String)
signal timeline_saved(timeline_data: Dictionary)
signal reality_connected(source_universe: String, target_universe: String)

# CREATION SETTINGS
@export var creation_power: float = 100.0
@export var timeline_enabled: bool = true
@export var multiverse_mode: bool = true

# 4D TIMELINE SYSTEM
var active_timelines: Dictionary = {}
var universe_saves: Dictionary = {}
var current_universe_id: String = "universe_main"
var timeline_depth: int = 0

# 5D DREAM REALITY CONNECTIONS
var connected_universes: Dictionary = {}
var reality_bridges: Array[RealityBridge] = []

# IN-GAME CREATION
var creation_cursor: Node3D
var created_objects: Dictionary = {}
var creation_history: Array[Dictionary] = []

class Timeline4D:
	var timeline_id: String
	var universe_state: Dictionary
	var creation_events: Array[Dictionary] = []
	var timestamp: float
	var branch_point: bool = false
	
	func _init(id: String):
		timeline_id = id
		timestamp = Time.get_ticks_msec() / 1000.0
		universe_state = {}

class RealityBridge:
	var bridge_id: String
	var source_universe: String
	var target_universe: String
	var connection_type: String = "dream_portal"
	var active: bool = true
	
	func _init(source: String, target: String):
		bridge_id = "bridge_" + str(Time.get_ticks_msec())
		source_universe = source
		target_universe = target

class CreatedObject:
	var object_id: String
	var object_type: String
	var position: Vector3
	var properties: Dictionary = {}
	var timeline_created: String
	var visual_node: Node3D
	
	func _init(id: String, type: String, pos: Vector3):
		object_id = id
		object_type = type
		position = pos

func _ready():
	name = "UniversalCreationEngine"
	print("🌌 UNIVERSAL CREATION ENGINE STARTING...")
	
	# Initialize creation system
	setup_creation_interface()
	
	# Initialize 4D timeline system
	setup_4d_timeline_system()
	
	# Initialize multiverse connections
	setup_5d_reality_system()
	
	# Setup creation cursor
	setup_creation_cursor()
	
	print("✨ UNIVERSAL CREATION ENGINE READY!")
	print("🎮 Click to create | T: Timeline | U: New Universe")

func setup_creation_interface():
	"""Setup in-game creation interface"""
	print("🎨 Setting up creation interface...")

func setup_4d_timeline_system():
	"""Setup 4D timeline save system"""
	print("⏰ Setting up 4D timeline system...")
	
	# Create initial timeline
	var main_timeline = Timeline4D.new("timeline_main")
	active_timelines[main_timeline.timeline_id] = main_timeline
	
	print("📅 Main timeline created")

func setup_5d_reality_system():
	"""Setup 5D dream reality connections"""
	print("🌀 Setting up 5D reality system...")
	
	# Initialize main universe
	universe_saves[current_universe_id] = {
		"created_objects": {},
		"timeline_branches": [],
		"reality_state": "active"
	}
	
	print("🌌 Main universe initialized")

func setup_creation_cursor():
	"""Setup creation cursor for in-game creation"""
	creation_cursor = Node3D.new()
	creation_cursor.name = "CreationCursor"
	
	# Visual indicator
	var cursor_visual = MeshInstance3D.new()
	cursor_visual.mesh = SphereMesh.new()
	cursor_visual.mesh.radius = 0.2
	
	var cursor_material = StandardMaterial3D.new()
	cursor_material.albedo_color = Color(1, 1, 0, 0.8)
	cursor_material.emission_enabled = true
	cursor_material.emission = Color(1, 1, 0)
	cursor_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cursor_visual.material_override = cursor_material
	
	creation_cursor.add_child(cursor_visual)
	add_child(creation_cursor)
	
	print("🎯 Creation cursor ready")

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			create_object_at_cursor()
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				create_specific_object("cube")
			KEY_2:
				create_specific_object("sphere")
			KEY_3:
				create_specific_object("tree")
			KEY_4:
				create_specific_object("building")
			KEY_5:
				create_specific_object("portal")
			KEY_T:
				save_current_timeline()
			KEY_U:
				create_new_universe()
			KEY_L:
				load_timeline()
			KEY_B:
				create_reality_bridge()

func create_object_at_cursor():
	"""Create object at cursor position"""
	var cursor_pos = creation_cursor.global_position
	create_object("generic", cursor_pos)

func create_specific_object(object_type: String):
	"""Create specific object type"""
	var camera = get_viewport().get_camera_3d()
	if camera:
		var pos = camera.global_position + camera.global_transform.basis.z * -5
		create_object(object_type, pos)

func create_object(object_type: String, position: Vector3):
	"""Core object creation function"""
	var object_id = "obj_" + str(created_objects.size()) + "_" + object_type
	var created_obj = CreatedObject.new(object_id, object_type, position)
	created_obj.timeline_created = current_universe_id
	
	# Create visual representation
	var visual_node = Node3D.new()
	visual_node.name = object_id
	visual_node.position = position
	
	var mesh_instance = MeshInstance3D.new()
	var material = StandardMaterial3D.new()
	
	match object_type:
		"cube":
			mesh_instance.mesh = BoxMesh.new()
			material.albedo_color = Color(0.8, 0.3, 0.3)
		"sphere":
			mesh_instance.mesh = SphereMesh.new()
			material.albedo_color = Color(0.3, 0.8, 0.3)
		"tree":
			mesh_instance.mesh = CylinderMesh.new()
			mesh_instance.mesh.height = 4.0
			mesh_instance.mesh.top_radius = 0.2
			mesh_instance.mesh.bottom_radius = 0.4
			material.albedo_color = Color(0.4, 0.2, 0.1)
		"building":
			mesh_instance.mesh = BoxMesh.new()
			mesh_instance.mesh.size = Vector3(3, 6, 3)
			material.albedo_color = Color(0.6, 0.6, 0.8)
		"portal":
			mesh_instance.mesh = TorusMesh.new()
			mesh_instance.mesh.inner_radius = 1.0
			mesh_instance.mesh.outer_radius = 2.0
			material.albedo_color = Color(0.5, 0.2, 1.0, 0.7)
			material.emission_enabled = true
			material.emission = Color(0.3, 0.1, 0.8)
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_:
			mesh_instance.mesh = SphereMesh.new()
			material.albedo_color = Color(0.8, 0.8, 0.8)
	
	mesh_instance.material_override = material
	visual_node.add_child(mesh_instance)
	created_obj.visual_node = visual_node
	add_child(visual_node)
	
	# Store in systems
	created_objects[object_id] = created_obj
	
	# Record creation event
	var creation_event = {
		"type": "object_created",
		"object_id": object_id,
		"object_type": object_type,
		"position": position,
		"timestamp": Time.get_ticks_msec() / 1000.0,
		"universe_id": current_universe_id
	}
	creation_history.append(creation_event)
	
	print("✨ Created", object_type, "at", position)

func save_current_timeline():
	"""Save current state as 4D timeline"""
	var timeline_id = "timeline_" + str(Time.get_ticks_msec())
	var timeline = Timeline4D.new(timeline_id)
	
	# Capture current universe state
	timeline.universe_state = {
		"objects": {},
		"creation_count": created_objects.size(),
		"universe_id": current_universe_id
	}
	
	# Save all created objects
	for obj_id in created_objects:
		var obj = created_objects[obj_id]
		timeline.universe_state.objects[obj_id] = {
			"type": obj.object_type,
			"position": obj.position,
			"properties": obj.properties
		}
	
	# Save creation events
	timeline.creation_events = creation_history.duplicate()
	
	active_timelines[timeline_id] = timeline
	universe_saves[current_universe_id]["timeline_branches"].append(timeline_id)
	
	print("💾 Timeline saved:", timeline_id)
	print("📊 Captured", created_objects.size(), "objects")
	timeline_saved.emit(timeline.universe_state)

func create_new_universe():
	"""Create new connected universe"""
	var new_universe_id = "universe_" + str(universe_saves.size())
	
	# Initialize new universe
	universe_saves[new_universe_id] = {
		"created_objects": {},
		"timeline_branches": [],
		"reality_state": "active",
		"parent_universe": current_universe_id
	}
	
	# Create reality bridge
	var bridge = RealityBridge.new(current_universe_id, new_universe_id)
	reality_bridges.append(bridge)
	
	if not connected_universes.has(current_universe_id):
		connected_universes[current_universe_id] = []
	connected_universes[current_universe_id].append(new_universe_id)
	
	print("🌌 New universe created:", new_universe_id)
	print("🌉 Reality bridge established")
	universe_created.emit(new_universe_id)

func load_timeline():
	"""Load previous timeline state"""
	if active_timelines.size() <= 1:
		print("📋 No additional timelines to load")
		return
	
	# Get latest timeline
	var timeline_keys = active_timelines.keys()
	var latest_key = timeline_keys[timeline_keys.size() - 1]
	var timeline = active_timelines[latest_key]
	
	print("⏪ Loading timeline:", latest_key)
	_apply_timeline_state(timeline)

func _apply_timeline_state(timeline: Timeline4D):
	"""Apply timeline state to current reality"""
	# Clear current objects
	for obj_id in created_objects:
		var obj = created_objects[obj_id]
		if obj.visual_node:
			obj.visual_node.queue_free()
	created_objects.clear()
	
	# Recreate objects from timeline
	for obj_id in timeline.universe_state.objects:
		var obj_data = timeline.universe_state.objects[obj_id]
		var recreated_obj = CreatedObject.new(obj_id, obj_data.type, obj_data.position)
		recreated_obj.properties = obj_data.properties
		
		# Recreate visual
		_recreate_object_visual(recreated_obj)
		created_objects[obj_id] = recreated_obj
	
	print("✨ Timeline applied:", timeline.timeline_id)
	print("🔄 Recreated", created_objects.size(), "objects")

func _recreate_object_visual(obj: CreatedObject):
	"""Recreate visual for loaded object"""
	create_object(obj.object_type, obj.position)

func create_reality_bridge():
	"""Create bridge between current and another universe"""
	if universe_saves.size() < 2:
		create_new_universe()
		return
	
	var universe_keys = universe_saves.keys()
	var other_universe = universe_keys[0] if universe_keys[0] != current_universe_id else universe_keys[1]
	
	var bridge = RealityBridge.new(current_universe_id, other_universe)
	reality_bridges.append(bridge)
	
	# Create visual portal
	create_object("portal", Vector3(0, 2, -10))
	
	print("🌉 Reality bridge created to:", other_universe)
	reality_connected.emit(current_universe_id, other_universe)

func _physics_process(delta):
	_update_creation_cursor(delta)

func _update_creation_cursor(delta):
	"""Update creation cursor position"""
	var camera = get_viewport().get_camera_3d()
	if camera:
		creation_cursor.global_position = camera.global_position + camera.global_transform.basis.z * -3
	
	# Gentle floating animation
	creation_cursor.position.y += sin(Time.get_ticks_msec() * 0.003) * 0.1 * delta