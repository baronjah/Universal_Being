extends Node
class_name AssetCreatorSystem

# 🎨 ASSET CREATOR SYSTEM 🎨  
# SDF-based 3D shape creation for Universal Being transformation
# The second of the 4 dead-end scripturas - manifestation forge

signal asset_created(asset_data: Dictionary, asset_node: Node3D)
signal sdf_operation_completed(operation_type: String, result_mesh: ArrayMesh)
signal asset_library_updated(asset_count: int)
signal universal_being_asset_ready(being_type: String, asset_path: String)

# SDF Operation types
enum SDFOperation {
	UNION,
	SUBTRACT,
	INTERSECT,
	SMOOTH_UNION,
	SMOOTH_SUBTRACT,
	DISPLACEMENT
}

# Primitive shape types
enum PrimitiveType {
	SPHERE,
	BOX,
	CYLINDER,
	TORUS,
	CAPSULE,
	CONE,
	PLANE,
	OCTAHEDRON
}

# Asset creation configuration
@export var enabled: bool = true
@export var sdf_resolution: int = 32
@export var marching_cubes_enabled: bool = true
@export var auto_generate_uvs: bool = true
@export var auto_generate_normals: bool = true
@export var asset_storage_path: String = "res://akashic_library/generated_assets/"

# Asset creation workspace
var current_workspace: AssetWorkspace
var primitive_library: Dictionary = {}
var sdf_operations: Array[SDFOperationData] = []
var generated_assets: Dictionary = {}
var marching_cubes_generator: MarchingCubesGenerator

# Universal Being integration
var universal_being_templates: Dictionary = {}
var consciousness_influenced_creation: bool = true

class AssetWorkspace:
	var workspace_id: String
	var primitives: Array[PrimitiveData] = []
	var operations: Array[SDFOperationData] = []
	var result_mesh: ArrayMesh
	var consciousness_level: float = 1.0
	var creation_metadata: Dictionary = {}
	
	func _init(id: String):
		workspace_id = id
		creation_metadata = {
			"creation_time": Time.get_ticks_msec() / 1000.0,
			"creator": "AssetCreatorSystem",
			"version": "1.0"
		}

class PrimitiveData:
	var primitive_type: PrimitiveType
	var position: Vector3
	var rotation: Vector3
	var scale: Vector3
	var parameters: Dictionary
	var consciousness_influence: float
	
	func _init(type: PrimitiveType, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE):
		primitive_type = type
		position = pos
		rotation = rot
		scale = scl
		parameters = {}
		consciousness_influence = 1.0

class SDFOperationData:
	var operation: SDFOperation
	var primitive_a: PrimitiveData
	var primitive_b: PrimitiveData
	var blend_factor: float
	var consciousness_modifier: float
	
	func _init(op: SDFOperation, prim_a: PrimitiveData, prim_b: PrimitiveData, blend: float = 0.1):
		operation = op
		primitive_a = prim_a
		primitive_b = prim_b
		blend_factor = blend
		consciousness_modifier = 1.0

class MarchingCubesGenerator:
	var resolution: int
	var iso_value: float = 0.0
	
	func _init(res: int = 32):
		resolution = res
	
	func generate_mesh_from_sdf(sdf_function: Callable, bounds: AABB) -> ArrayMesh:
		var vertices = PackedVector3Array()
		var indices = PackedInt32Array()
		var normals = PackedVector3Array()
		
		var step = bounds.size / float(resolution)
		
		# Simplified marching cubes implementation
		for x in range(resolution - 1):
			for y in range(resolution - 1):
				for z in range(resolution - 1):
					var cube_vertices = []
					var cube_values = []
					
					# Get 8 corners of cube
					for i in range(8):
						var corner_offset = Vector3(
							(i & 1) * step.x,
							((i >> 1) & 1) * step.y,
							((i >> 2) & 1) * step.z
						)
						var world_pos = bounds.position + Vector3(x, y, z) * step + corner_offset
						cube_vertices.append(world_pos)
						cube_values.append(sdf_function.call(world_pos))
					
					# Generate triangles for this cube
					_process_cube(cube_vertices, cube_values, vertices, indices, normals)
		
		if vertices.size() == 0:
			return null
		
		var mesh = ArrayMesh.new()
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_INDEX] = indices
		arrays[Mesh.ARRAY_NORMAL] = normals
		
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		return mesh
	
	func _process_cube(cube_vertices: Array, cube_values: Array, vertices: PackedVector3Array, indices: PackedInt32Array, normals: PackedVector3Array):
		# Simplified cube processing - would need full marching cubes lookup table
		var crossing_count = 0
		for val in cube_values:
			if val < iso_value:
				crossing_count += 1
		
		if crossing_count > 0 and crossing_count < 8:
			# Generate triangles (simplified)
			var base_idx = vertices.size()
			vertices.append(cube_vertices[0])
			vertices.append(cube_vertices[1])
			vertices.append(cube_vertices[2])
			
			normals.append(Vector3.UP)
			normals.append(Vector3.UP)
			normals.append(Vector3.UP)
			
			indices.append(base_idx)
			indices.append(base_idx + 1)
			indices.append(base_idx + 2)

func _ready():
	name = "AssetCreatorSystem"
	print("🎨 ASSET CREATOR SYSTEM INITIALIZED - SDF-based 3D shape creation active")
	
	# Initialize systems
	marching_cubes_generator = MarchingCubesGenerator.new(sdf_resolution)
	_initialize_primitive_library()
	_setup_asset_storage()
	current_workspace = AssetWorkspace.new("default_workspace")

func _initialize_primitive_library():
	"""Initialize library of SDF primitive functions"""
	primitive_library[PrimitiveType.SPHERE] = _sdf_sphere
	primitive_library[PrimitiveType.BOX] = _sdf_box
	primitive_library[PrimitiveType.CYLINDER] = _sdf_cylinder
	primitive_library[PrimitiveType.TORUS] = _sdf_torus
	primitive_library[PrimitiveType.CAPSULE] = _sdf_capsule
	primitive_library[PrimitiveType.CONE] = _sdf_cone
	primitive_library[PrimitiveType.PLANE] = _sdf_plane
	primitive_library[PrimitiveType.OCTAHEDRON] = _sdf_octahedron

func _setup_asset_storage():
	"""Setup asset storage directory"""
	if not DirAccess.dir_exists_absolute(asset_storage_path):
		DirAccess.open("res://").make_dir_recursive(asset_storage_path)

# ===== MAIN ASSET CREATION FUNCTIONS =====

func create_new_workspace(workspace_id: String = "") -> AssetWorkspace:
	"""Create new asset creation workspace"""
	if workspace_id == "":
		workspace_id = "workspace_" + str(Time.get_ticks_msec())
	
	current_workspace = AssetWorkspace.new(workspace_id)
	print("🎨 Created new asset workspace: %s" % workspace_id)
	return current_workspace

func add_primitive_to_workspace(primitive_type: PrimitiveType, position: Vector3 = Vector3.ZERO, rotation: Vector3 = Vector3.ZERO, scale: Vector3 = Vector3.ONE, parameters: Dictionary = {}) -> PrimitiveData:
	"""Add primitive shape to current workspace"""
	var primitive = PrimitiveData.new(primitive_type, position, rotation, scale)
	primitive.parameters = parameters
	
	if consciousness_influenced_creation:
		primitive.consciousness_influence = _get_current_consciousness_level()
	
	current_workspace.primitives.append(primitive)
	print("🎨 Added %s primitive to workspace at %s" % [PrimitiveType.keys()[primitive_type], position])
	return primitive

func apply_sdf_operation(operation: SDFOperation, primitive_a_index: int, primitive_b_index: int, blend_factor: float = 0.1) -> bool:
	"""Apply SDF operation between two primitives"""
	if primitive_a_index >= current_workspace.primitives.size() or primitive_b_index >= current_workspace.primitives.size():
		print("🚨 Invalid primitive indices for SDF operation")
		return false
	
	var prim_a = current_workspace.primitives[primitive_a_index]
	var prim_b = current_workspace.primitives[primitive_b_index]
	
	var sdf_op = SDFOperationData.new(operation, prim_a, prim_b, blend_factor)
	if consciousness_influenced_creation:
		sdf_op.consciousness_modifier = _get_current_consciousness_level()
	
	current_workspace.operations.append(sdf_op)
	print("🎨 Applied %s operation between primitives %d and %d" % [SDFOperation.keys()[operation], primitive_a_index, primitive_b_index])
	return true

func generate_asset_mesh() -> ArrayMesh:
	"""Generate final mesh from current workspace"""
	if current_workspace.primitives.size() == 0:
		print("⚠️ No primitives in workspace to generate mesh")
		return null
	
	# Create combined SDF function
	var combined_sdf = func(pos: Vector3) -> float:
		return _evaluate_workspace_sdf(pos, current_workspace)
	
	# Generate mesh using marching cubes
	var bounds = _calculate_workspace_bounds(current_workspace)
	var result_mesh = marching_cubes_generator.generate_mesh_from_sdf(combined_sdf, bounds)
	
	if result_mesh:
		current_workspace.result_mesh = result_mesh
		sdf_operation_completed.emit("workspace_generation", result_mesh)
		print("✅ Generated mesh with %d vertices" % result_mesh.surface_get_array_len(0, Mesh.ARRAY_VERTEX))
	else:
		print("🚨 Failed to generate mesh from workspace")
	
	return result_mesh

func create_universal_being_asset(being_type: String, consciousness_level: float = 1.0) -> Dictionary:
	"""Create asset specifically for Universal Being transformation"""
	var workspace_id = "ub_" + being_type + "_" + str(Time.get_ticks_msec())
	var workspace = create_new_workspace(workspace_id)
	workspace.consciousness_level = consciousness_level
	
	# Create consciousness-influenced shape based on being type
	match being_type:
		"consciousness_orb":
			add_primitive_to_workspace(PrimitiveType.SPHERE, Vector3.ZERO, Vector3.ZERO, Vector3.ONE * consciousness_level)
		
		"evolution_crystal":
			add_primitive_to_workspace(PrimitiveType.OCTAHEDRON, Vector3.ZERO, Vector3.ZERO, Vector3.ONE * consciousness_level)
			add_primitive_to_workspace(PrimitiveType.SPHERE, Vector3.ZERO, Vector3.ZERO, Vector3.ONE * 0.7)
			apply_sdf_operation(SDFOperation.SMOOTH_UNION, 0, 1, 0.2)
		
		"cosmic_gateway":
			add_primitive_to_workspace(PrimitiveType.TORUS, Vector3.ZERO, Vector3.ZERO, Vector3(consciousness_level, consciousness_level, consciousness_level * 0.3))
			add_primitive_to_workspace(PrimitiveType.CYLINDER, Vector3.ZERO, Vector3.ZERO, Vector3(0.8, 0.1, 0.8))
			apply_sdf_operation(SDFOperation.SUBTRACT, 0, 1, 0.05)
		
		"universal_container":
			add_primitive_to_workspace(PrimitiveType.BOX, Vector3.ZERO, Vector3.ZERO, Vector3.ONE * consciousness_level)
			add_primitive_to_workspace(PrimitiveType.SPHERE, Vector3.ZERO, Vector3.ZERO, Vector3.ONE * 0.9)
			apply_sdf_operation(SDFOperation.INTERSECT, 0, 1, 0.1)
		
		_:
			# Default Universal Being shape
			add_primitive_to_workspace(PrimitiveType.SPHERE, Vector3.ZERO, Vector3.ZERO, Vector3.ONE)
	
	var asset_mesh = generate_asset_mesh()
	var asset_data = {
		"being_type": being_type,
		"consciousness_level": consciousness_level,
		"workspace_id": workspace_id,
		"mesh": asset_mesh,
		"creation_time": Time.get_ticks_msec() / 1000.0
	}
	
	# Store in Universal Being templates
	universal_being_templates[being_type] = asset_data
	
	print("🧬 Created Universal Being asset: %s (consciousness: %.2f)" % [being_type, consciousness_level])
	universal_being_asset_ready.emit(being_type, workspace_id)
	
	return asset_data

func save_asset_to_library(asset_name: String, asset_mesh: ArrayMesh, metadata: Dictionary = {}) -> String:
	"""Save generated asset to Akashic Library"""
	var asset_path = asset_storage_path + asset_name + ".tres"
	
	# Create asset resource
	var asset_resource = preload("res://core/UniversalBeing.gd").new()  # Placeholder - would be actual asset resource
	
	# Save metadata
	var full_metadata = {
		"name": asset_name,
		"creation_time": Time.get_ticks_msec() / 1000.0,
		"creator": "AssetCreatorSystem",
		"sdf_operations": current_workspace.operations.size(),
		"consciousness_level": current_workspace.consciousness_level
	}
	full_metadata.merge(metadata)
	
	generated_assets[asset_name] = {
		"mesh": asset_mesh,
		"metadata": full_metadata,
		"path": asset_path
	}
	
	asset_library_updated.emit(generated_assets.size())
	print("💾 Saved asset to library: %s" % asset_path)
	return asset_path

# ===== SDF PRIMITIVE FUNCTIONS =====

func _sdf_sphere(pos: Vector3, primitive: PrimitiveData) -> float:
	"""SDF function for sphere"""
	var local_pos = _transform_to_local(pos, primitive)
	var radius = primitive.parameters.get("radius", 1.0) * primitive.consciousness_influence
	return local_pos.length() - radius

func _sdf_box(pos: Vector3, primitive: PrimitiveData) -> float:
	"""SDF function for box"""
	var local_pos = _transform_to_local(pos, primitive)
	var size = primitive.parameters.get("size", Vector3.ONE) * primitive.consciousness_influence
	var q = local_pos.abs() - size
	return Vector3(max(q.x, 0), max(q.y, 0), max(q.z, 0)).length() + min(max(q.x, max(q.y, q.z)), 0.0)

func _sdf_cylinder(pos: Vector3, primitive: PrimitiveData) -> float:
	"""SDF function for cylinder"""
	var local_pos = _transform_to_local(pos, primitive)
	var radius = primitive.parameters.get("radius", 1.0) * primitive.consciousness_influence
	var height = primitive.parameters.get("height", 2.0) * primitive.consciousness_influence
	
	var d = Vector2(Vector2(local_pos.x, local_pos.z).length() - radius, abs(local_pos.y) - height)
	return min(max(d.x, d.y), 0.0) + Vector2(max(d.x, 0), max(d.y, 0)).length()

func _sdf_torus(pos: Vector3, primitive: PrimitiveData) -> float:
	"""SDF function for torus"""
	var local_pos = _transform_to_local(pos, primitive)
	var major_radius = primitive.parameters.get("major_radius", 1.0) * primitive.consciousness_influence
	var minor_radius = primitive.parameters.get("minor_radius", 0.3) * primitive.consciousness_influence
	
	var q = Vector2(Vector2(local_pos.x, local_pos.z).length() - major_radius, local_pos.y)
	return q.length() - minor_radius

func _sdf_capsule(pos: Vector3, primitive: PrimitiveData) -> float:
	"""SDF function for capsule"""
	var local_pos = _transform_to_local(pos, primitive)
	var radius = primitive.parameters.get("radius", 0.5) * primitive.consciousness_influence
	var height = primitive.parameters.get("height", 2.0) * primitive.consciousness_influence
	
	local_pos.y -= clamp(local_pos.y, -height, height)
	return local_pos.length() - radius

func _sdf_cone(pos: Vector3, primitive: PrimitiveData) -> float:
	"""SDF function for cone"""
	var local_pos = _transform_to_local(pos, primitive)
	var radius = primitive.parameters.get("radius", 1.0) * primitive.consciousness_influence
	var height = primitive.parameters.get("height", 2.0) * primitive.consciousness_influence
	
	var q = Vector2(Vector2(local_pos.x, local_pos.z).length(), local_pos.y)
	var c = Vector2(sin(atan2(height, radius)), cos(atan2(height, radius)))
	var d1 = max(q.dot(Vector2(c.x, -c.y)), q.y)
	var d2 = q.dot(Vector2(-c.y, c.x)) - radius
	return max(d1, d2)

func _sdf_plane(pos: Vector3, primitive: PrimitiveData) -> float:
	"""SDF function for plane"""
	var local_pos = _transform_to_local(pos, primitive)
	var normal = primitive.parameters.get("normal", Vector3.UP)
	return local_pos.dot(normal)

func _sdf_octahedron(pos: Vector3, primitive: PrimitiveData) -> float:
	"""SDF function for octahedron"""
	var local_pos = _transform_to_local(pos, primitive)
	var size = primitive.parameters.get("size", 1.0) * primitive.consciousness_influence
	local_pos = local_pos.abs()
	return (local_pos.x + local_pos.y + local_pos.z - size) * 0.57735027

# ===== HELPER FUNCTIONS =====

func _transform_to_local(world_pos: Vector3, primitive: PrimitiveData) -> Vector3:
	"""Transform world position to primitive local space"""
	var translated = world_pos - primitive.position
	
	# Apply rotation (simplified - would need proper rotation matrix)
	var rotated = translated
	if primitive.rotation != Vector3.ZERO:
		# Simple rotation around Y axis for now
		var angle = primitive.rotation.y
		rotated = Vector3(
			translated.x * cos(angle) - translated.z * sin(angle),
			translated.y,
			translated.x * sin(angle) + translated.z * cos(angle)
		)
	
	# Apply scale
	return rotated / primitive.scale

func _evaluate_workspace_sdf(pos: Vector3, workspace: AssetWorkspace) -> float:
	"""Evaluate SDF for entire workspace at given position"""
	if workspace.primitives.size() == 0:
		return 1.0  # Outside
	
	# Start with first primitive
	var result = _evaluate_primitive_sdf(pos, workspace.primitives[0])
	
	# Apply operations sequentially (simplified)
	for operation in workspace.operations:
		var sdf_a = _evaluate_primitive_sdf(pos, operation.primitive_a)
		var sdf_b = _evaluate_primitive_sdf(pos, operation.primitive_b)
		
		match operation.operation:
			SDFOperation.UNION:
				result = min(sdf_a, sdf_b)
			SDFOperation.SUBTRACT:
				result = max(sdf_a, -sdf_b)
			SDFOperation.INTERSECT:
				result = max(sdf_a, sdf_b)
			SDFOperation.SMOOTH_UNION:
				result = _smooth_min(sdf_a, sdf_b, operation.blend_factor)
			SDFOperation.SMOOTH_SUBTRACT:
				result = _smooth_max(sdf_a, -sdf_b, operation.blend_factor)
	
	return result

func _evaluate_primitive_sdf(pos: Vector3, primitive: PrimitiveData) -> float:
	"""Evaluate SDF for single primitive"""
	var sdf_func = primitive_library.get(primitive.primitive_type)
	if sdf_func:
		return sdf_func.call(pos, primitive)
	return 1.0

func _smooth_min(a: float, b: float, k: float) -> float:
	"""Smooth minimum function for SDF blending"""
	var h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0)
	return lerp(b, a, h) - k * h * (1.0 - h)

func _smooth_max(a: float, b: float, k: float) -> float:
	"""Smooth maximum function for SDF blending"""
	return -_smooth_min(-a, -b, k)

func _calculate_workspace_bounds(workspace: AssetWorkspace) -> AABB:
	"""Calculate bounding box for workspace"""
	if workspace.primitives.size() == 0:
		return AABB(Vector3(-5, -5, -5), Vector3(10, 10, 10))
	
	var min_pos = Vector3.INF
	var max_pos = Vector3(-INF)
	
	for primitive in workspace.primitives:
		var prim_min = primitive.position - primitive.scale * 2
		var prim_max = primitive.position + primitive.scale * 2
		
		min_pos = Vector3(min(min_pos.x, prim_min.x), min(min_pos.y, prim_min.y), min(min_pos.z, prim_min.z))
		max_pos = Vector3(max(max_pos.x, prim_max.x), max(max_pos.y, prim_max.y), max(max_pos.z, prim_max.z))
	
	return AABB(min_pos, max_pos - min_pos)

func _get_current_consciousness_level() -> float:
	"""Get current consciousness level from scene or system"""
	# Look for consciousness level in scene
	var scene = get_tree().current_scene
	if scene and scene.has_method("get_consciousness_level"):
		return scene.get_consciousness_level()
	return 1.0

# ===== PUBLIC API =====

func get_asset_library() -> Dictionary:
	"""Get generated asset library"""
	return generated_assets

func get_universal_being_templates() -> Dictionary:
	"""Get Universal Being asset templates"""
	return universal_being_templates

func clear_workspace():
	"""Clear current workspace"""
	current_workspace = AssetWorkspace.new("cleared_workspace")

func set_sdf_resolution(resolution: int):
	"""Set SDF resolution for marching cubes"""
	sdf_resolution = resolution
	marching_cubes_generator.resolution = resolution

# 🎨 ASSET CREATOR SYSTEM COMPLETE! 🎨
# SDF-based 3D shape creation for Universal Being manifestation
# Ready to create anything the consciousness can imagine!