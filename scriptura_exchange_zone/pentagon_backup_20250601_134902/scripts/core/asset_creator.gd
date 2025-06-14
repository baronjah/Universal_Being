@tool
extends UniversalBeingBase
class_name AssetCreator
## Enhanced Asset Creator - Creates Universal Beings from shapes
## Connected to Asset Library, Zones, and Floodgates
## The missing piece of the Universal Being dream

signal asset_created(universal_being: UniversalBeing)
signal shape_added(shape_data: Dictionary)
signal bone_placed(bone_data: Dictionary)

# Creation workspace
@export var workspace_size: Vector3 = Vector3(10, 10, 10)
@export var grid_snap: float = 0.1
@export var show_grid: bool = true

# Shape creation
var current_shapes: Array[Dictionary] = []
var shape_operations: Array[Dictionary] = []
var preview_mesh: MeshInstance3D
var workspace_boundary: MeshInstance3D

# Bone system
var bone_points: Array[Dictionary] = []
var bone_preview: Node3D

# Connection to other systems
var asset_library: Node
var floodgate: Node
var akashic_records: Node

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	"""Initialize the asset creator"""
	name = "AssetCreator"
	
	# Get system connections
	asset_library = get_node_or_null("/root/AssetLibrary")
	floodgate = get_node_or_null("/root/FloodgateController")
	akashic_records = get_node_or_null("/root/AkashicRecords")
	
	# Setup workspace
	_create_workspace()
	
	print("🔨 Asset Creator: Ready to manifest Universal Beings")

func _create_workspace() -> void:
	"""Create the 10x10x10 creation space"""
	# Boundary visualization
	workspace_boundary = MeshInstance3D.new()
	add_child(workspace_boundary)
	
	var box_mesh = BoxMesh.new()
	box_mesh.size = workspace_size
	workspace_boundary.mesh = box_mesh
	
	# Semi-transparent material
	var mat = MaterialLibrary.get_material("default")
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.2, 0.8, 0.2, 0.1)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	workspace_boundary.material_override = mat
	
	# Grid visualization (basic)
	if show_grid:
		print("Grid visualization enabled")


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
func add_shape_primitive(type: String, params: Dictionary = {}) -> void:
	"""Add a basic shape to the creation"""
	var shape = {
		"type": type,
		"params": params,
		"transform": Transform3D.IDENTITY,
		"id": "shape_" + str(Time.get_ticks_msec())
	}
	
	# Default parameters
	match type:
		"sphere":
			shape.params["radius"] = params.get("radius", 1.0)
		"box":
			shape.params["size"] = params.get("size", Vector3.ONE)
		"cylinder":
			shape.params["radius"] = params.get("radius", 0.5)
			shape.params["height"] = params.get("height", 2.0)
		"torus":
			shape.params["inner_radius"] = params.get("inner_radius", 0.3)
			shape.params["outer_radius"] = params.get("outer_radius", 1.0)
	
	current_shapes.append(shape)
	shape_added.emit(shape)
	print("Added shape: %s" % type)

func add_sdf_operation(operation: String, shape_a_id: String, shape_b_id: String) -> void:
	"""Add SDF operation between shapes"""
	var op = {
		"type": operation,  # union, subtract, intersect, smooth_union
		"shape_a": shape_a_id,
		"shape_b": shape_b_id,
		"blend": 0.1  # For smooth operations
	}
	
	shape_operations.append(op)
	print("Added SDF operation: %s" % operation)

func place_bone(bone_position: Vector3, bone_name: String = "") -> void:
	"""Place a bone point for animation"""
	var bone = {
		"position": bone_position,
		"name": bone_name if bone_name != "" else "bone_" + str(bone_points.size()),
		"influence_radius": 1.0,
		"connected_vertices": []
	}
	
	bone_points.append(bone)
	bone_placed.emit(bone)
	print("Placed bone: %s" % bone.name)

func create_universal_being() -> UniversalBeing:
	"""Create a Universal Being from the current creation"""
	if current_shapes.is_empty():
		push_error("No shapes to create Universal Being from")
		return null
	
	# Create through Floodgate for thread safety
	if floodgate:
		var operation = {
			"type": FloodgateController.OperationType.CREATE_UNIVERSAL_BEING,
			"data": {
				"shapes": current_shapes,
				"operations": shape_operations,
				"bones": bone_points,
				"creator": "AssetCreator",
				"timestamp": Time.get_datetime_string_from_system()
			}
		}
		floodgate.queue_operation(operation)
	
	# Create Universal Being
	var UBClass = load("res://scripts/core/universal_being.gd")
	var being = UBClass.new()
	
	# Set creation data
	being.essence["creation_data"] = {
		"shapes": current_shapes.duplicate(true),
		"operations": shape_operations.duplicate(true),
		"bones": bone_points.duplicate(true)
	}
	
	# Generate mesh from shapes
	var mesh = _generate_mesh_from_shapes()
	being.manifestation = MeshInstance3D.new()
	being.manifestation.mesh = mesh
	FloodgateController.universal_add_child(being.manifestation, being)
	
	# Apply bones if any
	if not bone_points.is_empty():
		print("Applied %d bones to being" % bone_points.size())
	
	# Register with Asset Library
	if asset_library:
		var asset_id = "custom_" + str(Time.get_ticks_msec())
		asset_library.register_custom_asset(asset_id, being)
	
	# Store in Akashic Records
	if akashic_records:
		akashic_records.store_creation(being)
	
	asset_created.emit(being)
	return being

func save_as_asset_definition(asset_name: String, category: String = "custom") -> void:
	"""Save current creation as reusable asset"""
	var _definition = {  # Future: store in asset library
		"name": asset_name,
		"category": category,
		"shapes": current_shapes,
		"operations": shape_operations,
		"bones": bone_points,
		"metadata": {
			"created_by": "AssetCreator",
			"date": Time.get_datetime_string_from_system()
		}
	}
	
	# Save definition (simplified for now)
	print("Asset definition saved: %s (category: %s)" % [asset_name, category])
	print("Shapes: %d, Operations: %d, Bones: %d" % [current_shapes.size(), shape_operations.size(), bone_points.size()])
	
	print("💾 Saved asset definition: %s" % asset_name)

func _generate_mesh_from_shapes() -> Mesh:
	"""Generate mesh from shapes and SDF operations"""
	# For now, create a simple combined mesh
	# TODO: Implement proper SDF evaluation and marching cubes
	var array_mesh = ArrayMesh.new()
	
	for shape in current_shapes:
		match shape.type:
			"sphere":
				var sphere_mesh = SphereMesh.new()
				sphere_mesh.radial_segments = 32
				sphere_mesh.height = shape.params.radius * 2
				sphere_mesh.radius = shape.params.radius
				array_mesh.add_surface_from_arrays(
					Mesh.PRIMITIVE_TRIANGLES,
					sphere_mesh.get_mesh_arrays()
				)
	
	return array_mesh

# Console command integration
func _on_console_command(command: String, args: Array) -> void:
	"""Handle asset creator commands"""
	match command:
		"shape":
			if args.size() > 0:
				add_shape_primitive(args[0])
		"bone":
			if args.size() >= 3:
				var pos = Vector3(
					args[0].to_float(),
					args[1].to_float(),
					args[2].to_float()
				)
				place_bone(pos)
		"create_being":
			create_universal_being()
