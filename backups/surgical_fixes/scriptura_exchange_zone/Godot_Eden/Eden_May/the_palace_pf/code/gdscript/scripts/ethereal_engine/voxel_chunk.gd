# voxel_chunk.gd
class_name VoxelChunk
extends Spatial

var chunk_position: Vector3
var chunk_size: int
var voxels = {}  # Dictionary of local positions to element data

func _init(pos, size):
	chunk_position = pos
	chunk_size = size
	name = "Chunk_" + str(pos.x) + "_" + str(pos.y) + "_" + str(pos.z)
	
	# Set world position
	translation = chunk_position * chunk_size
	
func add_element(element, local_pos, size):
	# Create voxels for this element
	for x in range(size.x):
		for y in range(size.y):
			for z in range(size.z):
				var pos = local_pos + Vector3(x, y, z)
				
				# Check if position is within chunk bounds
				if is_position_valid(pos):
					voxels[pos] = {
						"element": element.duplicate(),
						"properties": element.properties.duplicate()
					}
	
	# Update visual representation
	update_mesh()
	
func is_position_valid(pos):
	return pos.x >= 0 and pos.x < chunk_size and \
		   pos.y >= 0 and pos.y < chunk_size and \
		   pos.z >= 0 and pos.z < chunk_size
		   
func update_mesh():
	# Clear existing meshes
	for child in get_children():
		child.queue_free()
		
	# Create new mesh based on voxel data
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# For each voxel, add faces if needed
	for pos in voxels:
		var element = voxels[pos].element
		var color = element.properties.color
		
		st.add_color(color)
		
		# Add cube faces (simplified - would need proper culling)
		add_cube_faces(st, pos)
	
	st.index()
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = st.commit()
	
	# Add collision shape
	var collision_shape = CollisionShape.new()
	collision_shape.shape = mesh_instance.mesh.create_trimesh_shape()
	
	# Add both to the chunk
	add_child(mesh_instance)
	add_child(collision_shape)
	
func add_cube_faces(st, pos):
	# Add all faces of a cube at the given position
	# (Implementation omitted for brevity - would add vertices for each face)
	pass
