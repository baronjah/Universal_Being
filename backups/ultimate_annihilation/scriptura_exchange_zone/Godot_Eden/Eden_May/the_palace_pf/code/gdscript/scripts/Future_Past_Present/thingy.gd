# thingy.gd
extends MultiMeshInstance3D

#extends Node3D

var mesh_data_file = "res://mesh_data.txt"  # Path to the text file with coordinates

func _ready():
	# Step 1: Load the array from the text file
	var points = load_array_from_file(mesh_data_file)
	
	# Step 2: Create the array mesh
	create_array_mesh(points)

func load_array_from_file(file_path: String) -> Array:
	var points = []
	#var file = File.new()
	#if file.file_exists(file_path):
		#file.open(file_path, File.READ)
		#while not file.eof_reached():
			#var line = file.get_line()
			#if line.strip() != "":
				#var coords# = line.split(",").map(lambda x: float(x))
				#points.append(Vector3(coords[0], coords[1], coords[2]))
		#file.close()
	return points

func create_array_mesh(points: Array):
	# Step 3: Define the array mesh
	var mesh = ArrayMesh.new()
	var surface_arrays = []
	var vertices = points
	surface_arrays.resize(Mesh.ARRAY_MAX)
	surface_arrays[Mesh.ARRAY_VERTEX] = vertices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)
	
	# Step 4: Create the mesh instance
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
