class_name DungeonPathfinder
extends Node3D

# References
@export var grid_map: GridMap
@export var navigation_map: NavigationRegion3D

# Map cell IDs
@export var floor_cell: int = 0
@export var wall_cell: int = 1
@export var door_cell: int = 2

# Path settings
@export var path_width: int = 1
@export var apply_noise: bool = true
@export var noise_amount: float = 0.3

var rooms: Array = []
var nav_mesh: NavigationMesh

func ready_new():
	nav_mesh = navigation_map.navigation_mesh

func create_paths_between_rooms():
	# Make sure we have at least 2 rooms
	if rooms.size() < 2:
		return
	
	# Create a navigation mesh from the existing floor
	update_nav_mesh()
	
	# Connect all rooms to ensure the dungeon is fully connected
	for i in range(1, rooms.size()):
		var start_room = rooms[i-1]
		var end_room = rooms[i]
		
		connect_rooms_with_path(start_room, end_room)

func update_nav_mesh():
	# This is a simplified version - in reality you'd need to 
	# generate a proper navigation mesh from your grid
	
	# Clear existing nav mesh
	nav_mesh.clear()
	
	# Add all floor tiles to the navigation mesh
	for cell in grid_map.get_used_cells():
		if grid_map.get_cell_item(cell) == floor_cell:
			var vertices = []
			vertices.append(Vector3(cell.x - 0.5, 0, cell.z - 0.5))
			vertices.append(Vector3(cell.x + 0.5, 0, cell.z - 0.5))
			vertices.append(Vector3(cell.x + 0.5, 0, cell.z + 0.5))
			vertices.append(Vector3(cell.x - 0.5, 0, cell.z + 0.5))
			
			nav_mesh.add_polygon(vertices)
	
	# Bake the navigation mesh
	navigation_map.bake_navigation_mesh(true)

func connect_rooms_with_path(start_room, end_room):
	# Get centers of the rooms
	var start_pos = Vector3(
		start_room.x + start_room.width / 2, 
		0,
		start_room.y + start_room.height / 2
	)
	
	var end_pos = Vector3(
		end_room.x + end_room.width / 2, 
		0,
		end_room.y + end_room.height / 2
	)
	
	# Calculate path
	var path = navigation_map.get_simple_path(start_pos, end_pos, true)
	
	# Apply some noise to the path for more organic corridors
	if apply_noise:
		path = apply_path_noise(path)
	
	# Create corridor along the path
	create_corridor_from_path(path)

func apply_path_noise(path: Array) -> Array:
	var noisy_path = []
	noisy_path.append(path[0])  # Keep start point
	
	# Apply noise to middle points
	for i in range(1, path.size() - 1):
		var point = path[i]
		var noise_x = randf_range(-noise_amount, noise_amount)
		var noise_z = randf_range(-noise_amount, noise_amount)
		
		var noisy_point = Vector3(point.x + noise_x, point.y, point.z + noise_z)
		noisy_path.append(noisy_point)
	
	noisy_path.append(path[path.size() - 1])  # Keep end point
	
	return noisy_path

func create_corridor_from_path(path: Array):
	# For each point in the path, place floor tiles
	for i in range(1, path.size()):
		var start = path[i-1]
		var end = path[i]
		
		# Convert to grid coordinates
		var start_grid = Vector2i(int(start.x), int(start.z))
		var end_grid = Vector2i(int(end.x), int(end.z))
		
		# Create a line of floor cells between the points
		var points = get_line_points(start_grid, end_grid)
		
		for point in points:
			# Place the floor and surrounding floors for wider corridors
			for dx in range(-path_width, path_width + 1):
				for dz in range(-path_width, path_width + 1):
					var grid_pos = Vector3i(point.x + dx, 0, point.y + dz)
					
					# Only place if it's currently a wall or empty
					var current_cell = grid_map.get_cell_item(grid_pos)
					if current_cell == wall_cell or current_cell == -1:
						grid_map.set_cell_item(grid_pos, floor_cell)

func get_line_points(start: Vector2i, end: Vector2i) -> Array:
	var points = []
	
	var x = start.x
	var y = start.y
	var dx = abs(end.x - start.x)
	var dy = abs(end.y - start.y)
	var sx = 1 if start.x < end.x else -1
	var sy = 1 if start.y < end.y else -1
	var err = dx - dy
	
	while true:
		points.append(Vector2i(x, y))
		
		if x == end.x and y == end.y:
			break
		
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy
	
	return points
