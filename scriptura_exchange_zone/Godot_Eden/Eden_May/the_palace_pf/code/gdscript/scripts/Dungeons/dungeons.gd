class_name DungeonGenerator
extends Node3D

# Settings for the dungeon
@export var width: int = 20
@export var height: int = 20
@export var room_min_size: int = 4
@export var room_max_size: int = 8
@export var max_rooms: int = 15
@export var min_room_distance: int = 2

# GridMap reference
@export var grid_map: GridMap

# MeshLibrary cell IDs
@export var floor_cell: int = 0
@export var wall_cell: int = 1
@export var door_cell: int = 2

# Generation data
var rooms: Array = []
var corridors: Array = []
var _rng = RandomNumberGenerator.new()

class Room:
	var x: int
	var y: int
	var width: int
	var height: int
	
	func _init(x_pos: int, y_pos: int, w: int, h: int):
		x = x_pos
		y = y_pos
		width = w
		height = h
	
	func intersects(other_room: Room, min_distance: int) -> bool:
		# Check if the rooms are too close to each other
		return x - min_distance < other_room.x + other_room.width and \
			   x + width + min_distance > other_room.x and \
			   y - min_distance < other_room.y + other_room.height and \
			   y + height + min_distance > other_room.y

func ready_new():
	_rng.randomize()
	generate_dungeon()

func generate_dungeon():
	# Clear previous dungeon if any
	clear_dungeon()
	
	# Generate rooms
	generate_rooms()
	
	# Connect rooms with corridors
	connect_rooms()
	
	# Place walls around the floors
	place_walls()
	
	# Place doors between rooms and corridors
	place_doors()

func clear_dungeon():
	pass
	
func clear_dungeon_new():
	grid_map.clear()
	rooms.clear()
	corridors.clear()

func generate_rooms():
	for _i in range(max_rooms):
		# Generate random room size and position
		var room_width = _rng.randi_range(room_min_size, room_max_size)
		var room_height = _rng.randi_range(room_min_size, room_max_size)
		var room_x = _rng.randi_range(1, width - room_width - 1)
		var room_y = _rng.randi_range(1, height - room_height - 1)
		
		var new_room = Room.new(room_x, room_y, room_width, room_height)
		
		# Check if this room intersects with any existing room
		var can_place = true
		for room in rooms:
			if new_room.intersects(room, min_room_distance):
				can_place = false
				break
		
		if can_place:
			# Place floor tiles for this room
			place_room(new_room)
			rooms.append(new_room)

func place_room(room: Room):
	for x in range(room.x, room.x + room.width):
		for y in range(room.y, room.y + room.height):
			grid_map.set_cell_item(Vector3i(x, 0, y), floor_cell)

func connect_rooms():
	# Skip if we have less than 2 rooms
	if rooms.size() < 2:
		return
	
	# Sort rooms by x position to help create a more natural flow
	rooms.sort_custom(func(a, b): return a.x < b.x)
	
	# Connect consecutive rooms
	for i in range(1, rooms.size()):
		var prev_room = rooms[i-1]
		var curr_room = rooms[i]
		
		# Find centers of the rooms
		var prev_center = Vector2(prev_room.x + prev_room.width / 2, prev_room.y + prev_room.height / 2)
		var curr_center = Vector2(curr_room.x + curr_room.width / 2, curr_room.y + curr_room.height / 2)
		
		# 50% chance to draw corridors in a specific order
		if _rng.randf() < 0.5:
			create_h_corridor(prev_center.x, curr_center.x, prev_center.y)
			create_v_corridor(prev_center.y, curr_center.y, curr_center.x)
		else:
			create_v_corridor(prev_center.y, curr_center.y, prev_center.x)
			create_h_corridor(prev_center.x, curr_center.x, curr_center.y)

func create_h_corridor(start_x: float, end_x: float, y: float):
	var x1 = min(start_x, end_x)
	var x2 = max(start_x, end_x)
	
	for x in range(int(x1), int(x2) + 1):
		grid_map.set_cell_item(Vector3i(x, 0, int(y)), floor_cell)
		corridors.append(Vector2i(x, int(y)))

func create_v_corridor(start_y: float, end_y: float, x: float):
	var y1 = min(start_y, end_y)
	var y2 = max(start_y, end_y)
	
	for y in range(int(y1), int(y2) + 1):
		grid_map.set_cell_item(Vector3i(int(x), 0, y), floor_cell)
		corridors.append(Vector2i(int(x), y))

func place_walls():
	# Create a temp array of all floor positions
	var floor_positions = []
	
	# Get all floor positions from the GridMap
	for cell in grid_map.get_used_cells():
		if grid_map.get_cell_item(cell) == floor_cell:
			floor_positions.append(Vector2i(cell.x, cell.z))
	
	# Check adjacent cells to place walls
	for pos in floor_positions:
		var neighbors = [
			Vector2i(pos.x + 1, pos.y),
			Vector2i(pos.x - 1, pos.y),
			Vector2i(pos.x, pos.y + 1),
			Vector2i(pos.x, pos.y - 1)
		]
		
		for neighbor in neighbors:
			var cell = Vector3i(neighbor.x, 0, neighbor.y)
			if grid_map.get_cell_item(cell) == -1:  # If the cell is empty
				grid_map.set_cell_item(cell, wall_cell)

func place_doors():
	# For each corridor tile that connects to a room, consider placing a door
	for corridor_pos in corridors:
		var neighbors_count = 0
		var is_corridor_end = false
		
		# Check if this corridor tile is at the end of a corridor
		var neighbors = [
			Vector2i(corridor_pos.x + 1, corridor_pos.y),
			Vector2i(corridor_pos.x - 1, corridor_pos.y),
			Vector2i(corridor_pos.x, corridor_pos.y + 1),
			Vector2i(corridor_pos.x, corridor_pos.y - 1)
		]
		
		for neighbor in neighbors:
			var cell = Vector3i(neighbor.x, 0, neighbor.y)
			if grid_map.get_cell_item(cell) == floor_cell:
				neighbors_count += 1
		
		# If this corridor tile has exactly 1 floor neighbor, it's an end
		if neighbors_count == 1:
			is_corridor_end = true
		
		# Place door at corridor ends with some randomness
		if is_corridor_end and _rng.randf() < 0.7:  # 70% chance to place a door
			grid_map.set_cell_item(Vector3i(corridor_pos.x, 0, corridor_pos.y), door_cell)
