extends Node3D
class_name ModelLoader

# This class will handle the dynamic creation of models that are missing in the project
# It will serve as a replacement for the preloaded models

signal models_ready

# Store created models here
var _head_model: PackedScene
var _segment_model: PackedScene
var _debug_material: StandardMaterial3D

# Colors
var head_color = Color(0.9, 0.3, 0.3)  # Red for head
var segment_color = Color(0.2, 0.7, 0.9)  # Blue for segments
var debug_color = Color(0.5, 0.8, 0.5, 0.3)  # Green semi-transparent for debug

func _ready():
	# Create models on ready
	create_models()

func create_models():
	# Create the head model
	_head_model = _create_head_model()
	
	# Create the segment model
	_segment_model = _create_segment_model()
	
	# Create debug material
	_debug_material = _create_debug_material()
	
	# Emit signal that models are ready
	emit_signal("models_ready")
	
	print("ModelLoader: Models created successfully")

func _create_head_model() -> PackedScene:
	# Create a new scene root
	var scene_root = Node3D.new()
	scene_root.name = "SnakeHead"
	
	# Create the mesh instance for the head
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	
	# Create a spherical mesh for the head
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.5
	sphere_mesh.height = 1.0
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = head_color
	material.metallic = 0.7
	material.roughness = 0.2
	
	# Apply mesh and material
	mesh_instance.mesh = sphere_mesh
	mesh_instance.set_surface_override_material(0, material)
	
	# Add a collision shape
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.5
	collision_shape.shape = sphere_shape
	
	# Add children to root
	scene_root.add_child(mesh_instance)
	scene_root.add_child(collision_shape)
	
	# Create packed scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene_root)
	
	return packed_scene

func _create_segment_model() -> PackedScene:
	# Create a new scene root
	var scene_root = Node3D.new()
	scene_root.name = "SnakeSegment"
	
	# Create the mesh instance for the segment
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	
	# Create a capsule mesh for the body segment
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.4
	capsule_mesh.height = 0.8
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = segment_color
	material.metallic = 0.5
	material.roughness = 0.3
	
	# Apply mesh and material
	mesh_instance.mesh = capsule_mesh
	mesh_instance.set_surface_override_material(0, material)
	
	# Add a collision shape
	var collision_shape = CollisionShape3D.new()
	var capsule_shape = CapsuleShape3D.new()
	capsule_shape.radius = 0.4
	capsule_shape.height = 0.8
	collision_shape.shape = capsule_shape
	
	# Add children to root
	scene_root.add_child(mesh_instance)
	scene_root.add_child(collision_shape)
	
	# Create packed scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene_root)
	
	return packed_scene

func _create_debug_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = debug_color
	material.flags_transparent = true
	material.cull_mode = StandardMaterial3D.CULL_DISABLED
	return material

# Public access functions
func get_head_model() -> PackedScene:
	return _head_model

func get_segment_model() -> PackedScene:
	return _segment_model

func get_debug_material() -> StandardMaterial3D:
	return _debug_material
