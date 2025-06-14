# voxel_world.gd
extends Spatial

const CHUNK_SIZE = 16
const BLOCK_SIZE = 1.0

var chunks = {}  # Dictionary of Vector3 -> VoxelChunk

func _ready():
	# Initialize the world
	pass
	
func add_element_at_position(element, position, size):
	# Convert world position to voxel coordinates
	var voxel_pos = world_to_voxel(position)
	var voxel_size = Vector3(
		ceil(size.x / BLOCK_SIZE),
		ceil(size.y / BLOCK_SIZE),
		ceil(size.z / BLOCK_SIZE)
	)
	
	# Determine which chunks are affected
	var affected_chunks = get_affected_chunks(voxel_pos, voxel_size)
	
	# Update each affected chunk
	for chunk_pos in affected_chunks:
		var chunk = get_or_create_chunk(chunk_pos)
		chunk.add_element(element, voxel_pos - chunk_pos * CHUNK_SIZE, voxel_size)
		
func world_to_voxel(world_pos):
	return Vector3(
		floor(world_pos.x / BLOCK_SIZE),
		floor(world_pos.y / BLOCK_SIZE),
		floor(world_pos.z / BLOCK_SIZE)
	)
	
func get_or_create_chunk(chunk_pos):
	if chunk_pos in chunks:
		return chunks[chunk_pos]
	else:
		var new_chunk = VoxelChunk.new(chunk_pos, CHUNK_SIZE)
		chunks[chunk_pos] = new_chunk
		add_child(new_chunk)
		return new_chunk
		
func get_affected_chunks(voxel_pos, voxel_size):
	var result = []
	var start_chunk = Vector3(
		floor(voxel_pos.x / CHUNK_SIZE),
		floor(voxel_pos.y / CHUNK_SIZE),
		floor(voxel_pos.z / CHUNK_SIZE)
	)
	var end_chunk = Vector3(
		floor((voxel_pos.x + voxel_size.x - 1) / CHUNK_SIZE),
		floor((voxel_pos.y + voxel_size.y - 1) / CHUNK_SIZE),
		floor((voxel_pos.z + voxel_size.z - 1) / CHUNK_SIZE)
	)
	
	for x in range(start_chunk.x, end_chunk.x + 1):
		for y in range(start_chunk.y, end_chunk.y + 1):
			for z in range(start_chunk.z, end_chunk.z + 1):
				result.append(Vector3(x, y, z))
				
	return result
