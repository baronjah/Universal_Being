# ==================================================
# SCRIPT NAME: standardized_objects.gd
# DESCRIPTION: Standardized object definitions and behaviors
# CREATED: 2025-05-23 - Unified object system
# ==================================================

extends UniversalBeingBase
# Object type definitions with properties and default behaviors
var object_definitions = {
	"tree": {
		"type": "static",
		"mesh": "cylinder_sphere",
		"colors": [Color(0.4, 0.2, 0.1), Color(0.2, 0.6, 0.2)],
		"size": Vector3(0.5, 4.0, 0.5),
		"mass": 50.0,
		"actions": []
	},
	"rock": {
		"type": "static", 
		"mesh": "sphere",
		"colors": [Color(0.5, 0.5, 0.5)],
		"size": Vector3(1.0, 1.0, 1.0),
		"mass": 30.0,
		"actions": []
	},
	"box": {
		"type": "rigid",
		"mesh": "box",
		"colors": [Color(0.6, 0.4, 0.2)],
		"size": Vector3(1.5, 1.5, 1.5),
		"mass": 10.0,
		"actions": []
	},
	"ball": {
		"type": "rigid",
		"mesh": "sphere",
		"colors": [Color(0.8, 0.3, 0.3)],
		"size": Vector3(0.5, 0.5, 0.5),
		"mass": 2.0,
		"bounce": 0.8,
		"actions": ["roll"]
	},
	"ramp": {
		"type": "static",
		"mesh": "box",
		"colors": [Color(0.7, 0.7, 0.7)],
		"size": Vector3(3.0, 0.2, 5.0),
		"rotation": Vector3(30, 0, 0),
		"mass": 0.0,
		"actions": []
	},
	"ragdoll": {
		"type": "character",
		"mesh": "compound",  # Multiple parts
		"colors": [Color(0.3, 0.5, 0.8), Color(0.8, 0.3, 0.3)],
		"size": Vector3(0.8, 2.0, 0.4),
		"mass": 15.0,
		"actions": ["walk", "talk", "fall"],
		"dialogue": true
	},
	"skeleton_ragdoll": {
		"type": "skeletal_character",
		"mesh": "skeleton",  # Bone-based
		"colors": [Color(0.5, 0.3, 0.8), Color(0.8, 0.5, 0.3)],
		"size": Vector3(0.8, 2.0, 0.4),
		"mass": 15.0,
		"actions": ["walk", "talk", "fall", "pose"],
		"dialogue": true,
		"has_skeleton": true
	},
	"sun": {
		"type": "light",
		"mesh": "sphere",
		"colors": [Color(1.0, 0.9, 0.3)],
		"size": Vector3(3.0, 3.0, 3.0),
		"mass": 0.0,
		"emissive": true,
		"light_energy": 2.0,
		"actions": ["rise", "set", "pulse"]
	},
	"astral_being": {
		"type": "light_entity",
		"mesh": "point_light",
		"colors": [Color(0.8, 0.6, 1.0)],
		"size": Vector3(0.3, 0.3, 0.3),
		"mass": 0.0,
		"emissive": true,
		"light_energy": 2.0,
		"actions": ["orbit", "blink", "create", "connect"],
		"special_script": "res://scripts/core/talking_astral_being.gd"
	},
	"magical_orb": {
		"type": "divine_cursor",
		"mesh": "sphere",
		"colors": [Color(1.0, 0.8, 0.3, 0.7)],
		"size": Vector3(0.2, 0.2, 0.2),
		"mass": 0.0,
		"emissive": true,
		"light_energy": 1.5,
		"actions": ["point", "click", "hover", "divine_action"],
		"special_properties": {
			"divine_cursor": true,
			"always_visible": true,
			"follows_mouse": true
		}
	},
	"input_interface": {
		"type": "interface_being",
		"mesh": "box",
		"colors": [Color(0.2, 0.7, 1.0, 0.8)],
		"size": Vector3(1.0, 0.1, 0.6),
		"mass": 0.0,
		"emissive": true,
		"light_energy": 0.8,
		"actions": ["receive_input", "process_keys", "divine_typing"],
		"special_properties": {
			"input_type": "keyboard",
			"consciousness_level": 3,
			"divine_interface": true
		}
	},
	"pathway": {
		"type": "static",
		"mesh": "box",
		"colors": [Color(0.4, 0.3, 0.2)],
		"size": Vector3(2.0, 0.1, 10.0),
		"mass": 0.0,
		"actions": []
	},
	"bush": {
		"type": "static",
		"mesh": "sphere",
		"colors": [Color(0.1, 0.5, 0.1)],
		"size": Vector3(1.5, 1.0, 1.5),
		"mass": 5.0,
		"actions": ["rustle"]
	},
	"fruit": {
		"type": "rigid",
		"mesh": "sphere", 
		"colors": [Color(0.9, 0.2, 0.2)],
		"size": Vector3(0.2, 0.2, 0.2),
		"mass": 0.5,
		"actions": ["grow", "fall", "respawn"]
	},
	"wall": {
		"type": "static",
		"mesh": "box",
		"colors": [Color(0.6, 0.6, 0.6)],
		"size": Vector3(4.0, 3.0, 0.3),
		"mass": 0.0,
		"actions": []
	},
	"stick": {
		"type": "rigid",
		"mesh": "cylinder",
		"colors": [Color(0.4, 0.3, 0.2)],
		"size": Vector3(0.1, 1.0, 0.1),
		"mass": 0.5,
		"actions": ["pickup", "throw"]
	},
	"leaf": {
		"type": "rigid",
		"mesh": "box",
		"colors": [Color(0.2, 0.7, 0.2)],
		"size": Vector3(0.3, 0.01, 0.2),
		"mass": 0.01,
		"actions": ["float", "fall"]
	}
}

# Action definitions
var action_definitions = {
	"walk": {
		"type": "movement",
		"requires": ["legs", "body"],
		"parameters": ["speed", "direction"]
	},
	"talk": {
		"type": "dialogue",
		"requires": ["dialogue_system"],
		"parameters": ["text", "mood"]
	},
	"float": {
		"type": "movement",
		"requires": [],
		"parameters": ["height", "speed", "pattern"]
	},
	"follow": {
		"type": "ai",
		"requires": [],
		"parameters": ["target", "distance", "speed"]
	},
	"illuminate": {
		"type": "effect",
		"requires": ["light"],
		"parameters": ["intensity", "color", "radius"]
	},
	"rise": {
		"type": "movement",
		"requires": [],
		"parameters": ["start_pos", "end_pos", "duration"]
	},
	"set": {
		"type": "movement", 
		"requires": [],
		"parameters": ["start_pos", "end_pos", "duration"]
	},
	"pulse": {
		"type": "effect",
		"requires": ["light"],
		"parameters": ["min_intensity", "max_intensity", "speed"]
	}
}

# Create a standardized object

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
func create_object(object_type: String, position: Vector3, properties: Dictionary = {}) -> Node3D:
	if object_definitions == null:
		print("Error: object_definitions is null!")
		return null
	
	if not object_definitions.has(object_type):
		print("Unknown object type: " + object_type)
		return null
	
	var def = object_definitions[object_type]
	var obj: Node3D
	
	# Create base node based on type
	match def["type"]:
		"static":
			obj = StaticBody3D.new()
		"rigid":
			obj = RigidBody3D.new()
			obj.mass = def.get("mass", 1.0)
			if def.has("bounce"):
				var physics_mat = PhysicsMaterial.new()
				physics_mat.bounce = def["bounce"]
				obj.physics_material_override = physics_mat
		"character":
			obj = Node3D.new()  # Characters are compound objects
		"light":
			obj = Node3D.new()  # Light objects have special setup
		"light_entity":
			obj = Node3D.new()  # Astral beings are special
		_:
			obj = Node3D.new()
	
	# Generate unique name with numbering
	obj.name = _generate_unique_name(object_type)
	obj.position = position
	obj.add_to_group("spawned_objects")
	obj.add_to_group(object_type + "s")  # e.g., "trees", "ragdolls"
	
	# Add metadata
	obj.set_meta("object_type", object_type)
	obj.set_meta("actions", def.get("actions", []))
	
	# Create visual representation
	_add_visuals(obj, def)
	
	# Add collision if needed
	if def["type"] in ["static", "rigid"]:
		_add_collision(obj, def)
		# Ensure collision layers are set for mouse interaction
		if obj is RigidBody3D:
			obj.collision_layer = 1  # Default layer
			obj.collision_mask = 1   # Collide with default layer
		elif obj is StaticBody3D:
			obj.collision_layer = 1  # Default layer
			obj.collision_mask = 1   # Collide with default layer
	
	# Apply properties
	for key in properties:
		_apply_property(obj, key, properties[key])
	
	# Special setup for specific types
	match object_type:
		"ragdoll":
			_setup_ragdoll(obj)
		"skeleton_ragdoll":
			_setup_skeleton_ragdoll(obj)
		"sun":
			_setup_sun(obj)
		"astral_being":
			_setup_astral_being(obj)
		"fruit":
			_setup_fruit(obj)
	
	# Apply gravity exceptions for light objects
	if def.get("type") == "light" or def.get("type") == "light_entity":
		_setup_no_gravity(obj)
	
	# Fix positioning for rigid bodies so they don't fall through ground
	if def.get("type") == "rigid" and obj is RigidBody3D:
		# Place rigid bodies slightly above ground to prevent falling through
		obj.position.y = max(obj.position.y, 1.0)
		print("🔧 [StandardizedObjects] Fixed RigidBody position for: " + obj.name)
	
	return obj

func _add_visuals(obj: Node3D, def: Dictionary) -> void:
	var mesh_instance = MeshInstance3D.new()
	
	match def["mesh"]:
		"box":
			var box = BoxMesh.new()
			box.size = def.get("size", Vector3.ONE)
			mesh_instance.mesh = box
		"sphere":
			var sphere = SphereMesh.new()
			sphere.radius = def["size"].x / 2.0
			sphere.height = def["size"].y
			mesh_instance.mesh = sphere
		"cylinder_sphere":  # Tree
			# Trunk
			var trunk_mesh = MeshInstance3D.new()
			var cylinder = CylinderMesh.new()
			cylinder.height = def["size"].y
			cylinder.top_radius = def["size"].x / 2.0
			cylinder.bottom_radius = def["size"].x / 2.0
			trunk_mesh.mesh = cylinder
			trunk_mesh.position.y = def["size"].y / 2.0
			
			var trunk_mat = MaterialLibrary.get_material("default")
			trunk_mat.albedo_color = def["colors"][0]
			trunk_mesh.material_override = trunk_mat
			FloodgateController.universal_add_child(trunk_mesh, obj)
			
			# Leaves
			var leaves_mesh = MeshInstance3D.new()
			var sphere = SphereMesh.new()
			sphere.radius = def["size"].x * 2.0
			leaves_mesh.mesh = sphere
			leaves_mesh.position.y = def["size"].y + sphere.radius / 2.0
			
			var leaves_mat = MaterialLibrary.get_material("default")
			leaves_mat.albedo_color = def["colors"][1]
			leaves_mesh.material_override = leaves_mat
			FloodgateController.universal_add_child(leaves_mesh, obj)
			return
		"compound":  # Skip for compound objects like ragdoll
			return
	
	# Apply material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = def["colors"][0]
	if def.get("emissive", false):
		material.emission_enabled = true
		material.emission = def["colors"][0]
		material.emission_energy = def.get("light_energy", 1.0)
	mesh_instance.material_override = material
	
	FloodgateController.universal_add_child(mesh_instance, obj)

func _add_collision(obj: Node3D, def: Dictionary) -> void:
	var collision = CollisionShape3D.new()
	
	match def["mesh"]:
		"box":
			var shape = BoxShape3D.new()
			shape.size = def.get("size", Vector3.ONE)
			collision.shape = shape
		"sphere":
			var shape = SphereShape3D.new()
			shape.radius = def["size"].x / 2.0
			collision.shape = shape
		"cylinder_sphere":  # Tree gets cylinder collision
			var shape = CylinderShape3D.new()
			shape.height = def["size"].y
			shape.radius = def["size"].x / 2.0
			collision.shape = shape
			collision.position.y = def["size"].y / 2.0
	
	FloodgateController.universal_add_child(collision, obj)

func _apply_property(obj: Node3D, property: String, value) -> void:
	match property:
		"rotation_x":
			obj.rotation.x = deg_to_rad(float(str(value)))
		"rotation_y":
			obj.rotation.y = deg_to_rad(float(str(value)))
		"rotation_z":
			obj.rotation.z = deg_to_rad(float(str(value)))
		"scale":
			obj.scale = Vector3.ONE * float(str(value))
		"action":
			_start_action(obj, str(value))

func _setup_ragdoll(obj: Node3D) -> void:
	# Seven-part ragdoll implementation is frozen - use simplified setup
	# TODO: Create Pentagon-compliant ragdoll system
	print("WARNING: Ragdoll setup temporarily disabled - frozen system needs Pentagon migration")

func _setup_skeleton_ragdoll(obj: Node3D) -> void:
	# Use the new skeleton-based ragdoll
	var script = preload("res://scripts/core/skeleton_ragdoll_hybrid.gd")
	obj.set_script(script)
	obj.add_to_group("ragdolls")  # For console commands
	obj.add_to_group("skeleton_ragdolls")  # For specific targeting

func _setup_sun(obj: Node3D) -> void:
	# Add actual light source
	var light = DirectionalLight3D.new()
	light.light_energy = 2.0
	light.light_color = Color(1.0, 0.9, 0.7)
	light.rotation = Vector3(-45, -45, 0)
	FloodgateController.universal_add_child(light, obj)

func _setup_astral_being(obj: Node3D) -> void:
	# Use unified talking astral being script
	var enhanced_script = load("res://scripts/core/talking_astral_being.gd")
	if enhanced_script:
		obj.set_script(enhanced_script)

func _setup_fruit(obj: Node3D) -> void:
	# Make it edible/collectible
	obj.set_meta("collectible", true)
	obj.set_meta("respawn_time", 30.0)

func _setup_no_gravity(obj: Node3D) -> void:
	# Remove gravity from light objects
	if obj is RigidBody3D:
		var rb = obj as RigidBody3D
		rb.gravity_scale = 0.0
		rb.freeze = true  # Completely freeze in place
		print("[StandardizedObjects] Disabled gravity for: " + obj.name)

func _start_action(obj: Node3D, action: String) -> void:
	# This would connect to an action system
	var actions = obj.get_meta("actions", [])
	if action in actions:
		print("Starting action '" + action + "' on " + obj.name)
		# Action implementation would go here

# Generate unique name with numbering
func _generate_unique_name(object_type: String) -> String:
	var base_name = object_type.capitalize()
	var scene = Engine.get_main_loop().current_scene
	if not scene:
		return base_name + "_1"
	
	# Count existing objects of this type
	var count = 1
	var test_name = base_name + "_" + str(count)
	
	while scene.find_child(test_name, true, false):
		count += 1
		test_name = base_name + "_" + str(count)
	
	return test_name

# Asset persistence system
func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "StandardizedObjects"
	_load_custom_assets()
	print("📦 [StandardizedObjects] Initialized with " + str(object_definitions.size()) + " objects")

const CUSTOM_ASSETS_FILE = "user://custom_assets.json"

func save_custom_assets() -> void:
	"""Save custom assets to persistent storage"""
	var custom_assets = {}
	
	# Find assets that aren't in the base set
	var base_keys = ["tree", "rock", "box", "ball", "ramp", "ragdoll", "sun", "astral_being", "pathway", "bush", "fruit", "wall", "stick", "leaf"]
	
	for key in object_definitions:
		if not key in base_keys:
			custom_assets[key] = object_definitions[key]
	
	if not custom_assets.is_empty():
		var file = FileAccess.open(CUSTOM_ASSETS_FILE, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(custom_assets))
			file.close()
			print("💾 [StandardizedObjects] Saved " + str(custom_assets.size()) + " custom assets")

func _load_custom_assets() -> void:
	"""Load custom assets from persistent storage"""
	if not FileAccess.file_exists(CUSTOM_ASSETS_FILE):
		return
	
	var file = FileAccess.open(CUSTOM_ASSETS_FILE, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var result = json.parse(json_text)
		
		if result == OK and json.data is Dictionary:
			var custom_assets = json.data
			for key in custom_assets:
				object_definitions[key] = custom_assets[key]
			print("📂 [StandardizedObjects] Loaded " + str(custom_assets.size()) + " custom assets")

func add_custom_asset(asset_name: String, properties: Dictionary) -> void:
	"""Add a custom asset and save it"""
	object_definitions[asset_name] = properties
	save_custom_assets()
	print("✨ [StandardizedObjects] Added custom asset: " + asset_name)
