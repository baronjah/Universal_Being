# line.gd
extends MeshInstance3D


func _ready():
	send_any_message()

func change_points_of_line(start_end_points):
	#print("we are in line script :", start_end_points)
	
	# Get the points from the input
	var point1 = Vector3(start_end_points[0][0], start_end_points[0][1], start_end_points[0][2])
	var point2 = Vector3(start_end_points[1][0], start_end_points[1][1], start_end_points[1][2])
	
	# Get the ImmediateMesh
	var immediate_mesh = mesh as ImmediateMesh
	
	# Clear the existing surface
	immediate_mesh.clear_surfaces()
	
	# Create new surface with updated points
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	# Draw single line from point1 to point2
	immediate_mesh.surface_add_vertex(point1)
	immediate_mesh.surface_add_vertex(point2)
	
	immediate_mesh.surface_end()

func send_any_message():
	print(" so the line script is alive! " , self.name)
