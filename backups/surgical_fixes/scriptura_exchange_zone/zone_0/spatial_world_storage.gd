extends Node

# Spatial World Storage System
# Handles storage and management of 3D spaces, maps and akashic record data
# Terminal 1: Divine Word Genesis

class_name SpatialWorldStorage

# Coordinate system definitions
const MAX_DIMENSION = 12
const SACRED_NUMBER = 9

# Basic 3D space structure
class Coordinate:
	var x: float
	var y: float
	var z: float
	
	func _init(x_val = 0, y_val = 0, z_val = 0):
		x = x_val
		y = y_val
		z = z_val
	
	func to_string():
		return "(%f, %f, %f)" % [x, y, z]
	
	func to_vector3():
		return Vector3(x, y, z)

# Extended space with dimensional properties
class DimensionalPoint:
	var coordinate: Coordinate
	var dimension: int
	var power: float
	var timestamp: int
	
	func _init(coord, dim = 1, pwr = 0):
		coordinate = coord
		dimension = dim
		power = pwr
		timestamp = OS.get_unix_time()
	
	func to_dict():
		return {
			"x": coordinate.x,
			"y": coordinate.y,
			"z": coordinate.z,
			"dimension": dimension,
			"power": power,
			"timestamp": timestamp
		}
	
	static func from_dict(data):
		var coord = Coordinate.new(data.x, data.y, data.z)
		var point = DimensionalPoint.new(coord, data.dimension, data.power)
		point.timestamp = data.timestamp
		return point

# Akashic record entry
class AkashicEntry:
	var position: DimensionalPoint
	var content: String
	var author: String
	var tags: Array
	var connections: Array
	var entry_id: String
	
	func _init(pos, cont, auth, entry_tags = []):
		position = pos
		content = cont
		author = auth
		tags = entry_tags
		connections = []
		entry_id = "entry_%d_%d" % [OS.get_unix_time(), randi() % 10000]
	
	func to_dict():
		var conn_ids = []
		for connection in connections:
			conn_ids.append(connection.entry_id)
		
		return {
			"position": position.to_dict(),
			"content": content,
			"author": author,
			"tags": tags,
			"connections": conn_ids,
			"entry_id": entry_id
		}

# 3D world map
class SpatialMap:
	var name: String
	var dimension: int
	var grid: Dictionary
	var entities: Dictionary
	var creation_time: int
	var last_update: int
	
	func _init(map_name, dim = 1):
		name = map_name
		dimension = dim
		grid = {}
		entities = {}
		creation_time = OS.get_unix_time()
		last_update = creation_time
	
	func add_point(key, point_data):
		grid[key] = point_data
		last_update = OS.get_unix_time()
	
	func get_point(key):
		if grid.has(key):
			return grid[key]
		return null
	
	func add_entity(entity_id, entity_data):
		entities[entity_id] = entity_data
		last_update = OS.get_unix_time()
	
	func to_dict():
		var grid_data = {}
		for key in grid:
			grid_data[key] = grid[key].to_dict()
		
		return {
			"name": name,
			"dimension": dimension,
			"grid": grid_data,
			"entities": entities,
			"creation_time": creation_time,
			"last_update": last_update
		}

# Notepad3D Cell
class Notepad3DCell:
	var position: Coordinate
	var content: String
	var color: Color
	var cell_id: String
	var last_edit: int
	
	func _init(pos, cont = "", col = Color.white):
		position = pos
		content = cont
		color = col
		cell_id = "cell_%d_%d" % [OS.get_unix_time(), randi() % 10000]
		last_edit = OS.get_unix_time()
	
	func to_dict():
		return {
			"position": {
				"x": position.x,
				"y": position.y,
				"z": position.z
			},
			"content": content,
			"color": {
				"r": color.r,
				"g": color.g,
				"b": color.b,
				"a": color.a
			},
			"cell_id": cell_id,
			"last_edit": last_edit
		}

# Notepad3D notebook
class Notepad3D:
	var name: String
	var cells: Dictionary
	var creation_time: int
	var last_update: int
	var tags: Array
	
	func _init(notebook_name, notebook_tags = []):
		name = notebook_name
		cells = {}
		creation_time = OS.get_unix_time()
		last_update = creation_time
		tags = notebook_tags
	
	func add_cell(cell):
		cells[cell.cell_id] = cell
		last_update = OS.get_unix_time()
	
	func get_cell(cell_id):
		if cells.has(cell_id):
			return cells[cell_id]
		return null
	
	func get_cell_at_position(position):
		for cell_id in cells:
			var cell = cells[cell_id]
			if cell.position.x == position.x and cell.position.y == position.y and cell.position.z == position.z:
				return cell
		return null
	
	func to_dict():
		var cells_data = {}
		for cell_id in cells:
			cells_data[cell_id] = cells[cell_id].to_dict()
		
		return {
			"name": name,
			"cells": cells_data,
			"creation_time": creation_time,
			"last_update": last_update,
			"tags": tags
		}

# Main storage variables
var akashic_entries = {}
var spatial_maps = {}
var notepad_notebooks = {}

# Signal connections
signal entry_added(entry_id)
signal map_created(map_name)
signal notebook_updated(notebook_name)

func _ready():
	load_all_data()

func load_all_data():
	load_akashic_records()
	load_spatial_maps()
	load_notepad_notebooks()

# Akashic Records functions
func add_akashic_entry(position, content, author, tags = []):
	var entry = AkashicEntry.new(position, content, author, tags)
	akashic_entries[entry.entry_id] = entry
	save_akashic_records()
	emit_signal("entry_added", entry.entry_id)
	return entry.entry_id

func get_akashic_entry(entry_id):
	if akashic_entries.has(entry_id):
		return akashic_entries[entry_id]
	return null

func find_entries_by_tag(tag):
	var result = []
	for entry_id in akashic_entries:
		var entry = akashic_entries[entry_id]
		if tag in entry.tags:
			result.append(entry)
	return result

func find_entries_by_dimension(dimension):
	var result = []
	for entry_id in akashic_entries:
		var entry = akashic_entries[entry_id]
		if entry.position.dimension == dimension:
			result.append(entry)
	return result

func connect_entries(source_id, target_id):
	if akashic_entries.has(source_id) and akashic_entries.has(target_id):
		var source = akashic_entries[source_id]
		var target = akashic_entries[target_id]
		
		if not target in source.connections:
			source.connections.append(target)
			save_akashic_records()
			return true
	return false

func save_akashic_records():
	var file = File.new()
	var data = {}
	
	for entry_id in akashic_entries:
		data[entry_id] = akashic_entries[entry_id].to_dict()
	
	file.open("user://akashic_records.json", File.WRITE)
	file.store_string(JSON.print(data, "  "))
	file.close()

func load_akashic_records():
	var file = File.new()
	if file.file_exists("user://akashic_records.json"):
		file.open("user://akashic_records.json", File.READ)
		var data_text = file.get_as_text()
		file.close()
		
		var data = JSON.parse(data_text).result
		if typeof(data) == TYPE_DICTIONARY:
			akashic_entries.clear()
			
			# First pass: Create all entries
			var temp_entries = {}
			for entry_id in data:
				var entry_data = data[entry_id]
				var position_data = entry_data.position
				
				var coord = Coordinate.new(position_data.x, position_data.y, position_data.z)
				var dim_point = DimensionalPoint.new(coord, position_data.dimension, position_data.power)
				dim_point.timestamp = position_data.timestamp
				
				var entry = AkashicEntry.new(dim_point, entry_data.content, entry_data.author, entry_data.tags)
				entry.entry_id = entry_id
				
				temp_entries[entry_id] = entry
			
			# Second pass: Connect entries
			for entry_id in data:
				var entry_data = data[entry_id]
				var entry = temp_entries[entry_id]
				
				for connection_id in entry_data.connections:
					if temp_entries.has(connection_id):
						entry.connections.append(temp_entries[connection_id])
			
			akashic_entries = temp_entries

# Spatial Maps functions
func create_spatial_map(name, dimension = 1):
	var map = SpatialMap.new(name, dimension)
	spatial_maps[name] = map
	save_spatial_maps()
	emit_signal("map_created", name)
	return name

func get_spatial_map(name):
	if spatial_maps.has(name):
		return spatial_maps[name]
	return null

func add_point_to_map(map_name, key, point_data):
	if spatial_maps.has(map_name):
		spatial_maps[map_name].add_point(key, point_data)
		save_spatial_maps()
		return true
	return false

func add_entity_to_map(map_name, entity_id, entity_data):
	if spatial_maps.has(map_name):
		spatial_maps[map_name].add_entity(entity_id, entity_data)
		save_spatial_maps()
		return true
	return false

func save_spatial_maps():
	var file = File.new()
	var data = {}
	
	for map_name in spatial_maps:
		data[map_name] = spatial_maps[map_name].to_dict()
	
	file.open("user://spatial_maps.json", File.WRITE)
	file.store_string(JSON.print(data, "  "))
	file.close()

func load_spatial_maps():
	var file = File.new()
	if file.file_exists("user://spatial_maps.json"):
		file.open("user://spatial_maps.json", File.READ)
		var data_text = file.get_as_text()
		file.close()
		
		var data = JSON.parse(data_text).result
		if typeof(data) == TYPE_DICTIONARY:
			spatial_maps.clear()
			
			for map_name in data:
				var map_data = data[map_name]
				var map = SpatialMap.new(map_name, map_data.dimension)
				map.creation_time = map_data.creation_time
				map.last_update = map_data.last_update
				
				# Load grid points
				for key in map_data.grid:
					var point_data = map_data.grid[key]
					var coord = Coordinate.new(point_data.x, point_data.y, point_data.z)
					var dim_point = DimensionalPoint.new(coord, point_data.dimension, point_data.power)
					dim_point.timestamp = point_data.timestamp
					map.add_point(key, dim_point)
				
				# Load entities
				for entity_id in map_data.entities:
					map.add_entity(entity_id, map_data.entities[entity_id])
				
				spatial_maps[map_name] = map

# Notepad3D functions
func create_notepad(name, tags = []):
	var notebook = Notepad3D.new(name, tags)
	notepad_notebooks[name] = notebook
	save_notepad_notebooks()
	emit_signal("notebook_updated", name)
	return name

func get_notepad(name):
	if notepad_notebooks.has(name):
		return notepad_notebooks[name]
	return null

func add_cell_to_notepad(notebook_name, position, content, color = Color.white):
	if notepad_notebooks.has(notebook_name):
		var coord = Coordinate.new(position.x, position.y, position.z)
		var cell = Notepad3DCell.new(coord, content, color)
		notepad_notebooks[notebook_name].add_cell(cell)
		save_notepad_notebooks()
		emit_signal("notebook_updated", notebook_name)
		return cell.cell_id
	return null

func get_cell_from_notepad(notebook_name, cell_id):
	if notepad_notebooks.has(notebook_name):
		return notepad_notebooks[notebook_name].get_cell(cell_id)
	return null

func get_cell_at_position(notebook_name, position):
	if notepad_notebooks.has(notebook_name):
		var coord = Coordinate.new(position.x, position.y, position.z)
		return notepad_notebooks[notebook_name].get_cell_at_position(coord)
	return null

func save_notepad_notebooks():
	var file = File.new()
	var data = {}
	
	for notebook_name in notepad_notebooks:
		data[notebook_name] = notepad_notebooks[notebook_name].to_dict()
	
	file.open("user://notepad3d_notebooks.json", File.WRITE)
	file.store_string(JSON.print(data, "  "))
	file.close()

func load_notepad_notebooks():
	var file = File.new()
	if file.file_exists("user://notepad3d_notebooks.json"):
		file.open("user://notepad3d_notebooks.json", File.READ)
		var data_text = file.get_as_text()
		file.close()
		
		var data = JSON.parse(data_text).result
		if typeof(data) == TYPE_DICTIONARY:
			notepad_notebooks.clear()
			
			for notebook_name in data:
				var notebook_data = data[notebook_name]
				var notebook = Notepad3D.new(notebook_name, notebook_data.tags)
				notebook.creation_time = notebook_data.creation_time
				notebook.last_update = notebook_data.last_update
				
				# Load cells
				for cell_id in notebook_data.cells:
					var cell_data = notebook_data.cells[cell_id]
					var position_data = cell_data.position
					var color_data = cell_data.color
					
					var coord = Coordinate.new(position_data.x, position_data.y, position_data.z)
					var color = Color(color_data.r, color_data.g, color_data.b, color_data.a)
					
					var cell = Notepad3DCell.new(coord, cell_data.content, color)
					cell.cell_id = cell_id
					cell.last_edit = cell_data.last_edit
					notebook.add_cell(cell)
				
				notepad_notebooks[notebook_name] = notebook

# Conversion functions
func create_notepad_from_akashic(entry_ids, notebook_name):
	if notepad_notebooks.has(notebook_name):
		return false
	
	var notebook = Notepad3D.new(notebook_name)
	var z_index = 0
	
	for entry_id in entry_ids:
		if akashic_entries.has(entry_id):
			var entry = akashic_entries[entry_id]
			var coord = Coordinate.new(entry.position.coordinate.x, entry.position.coordinate.y, z_index)
			var color = Color(1.0, 0.8, 0.2, 1.0)  # Amber color for akashic entries
			
			var cell = Notepad3DCell.new(coord, entry.content, color)
			notebook.add_cell(cell)
			
			z_index += 1
	
	notepad_notebooks[notebook_name] = notebook
	save_notepad_notebooks()
	emit_signal("notebook_updated", notebook_name)
	return true

func create_map_from_akashic(entry_ids, map_name, dimension = 1):
	if spatial_maps.has(map_name):
		return false
	
	var map = SpatialMap.new(map_name, dimension)
	var i = 0
	
	for entry_id in entry_ids:
		if akashic_entries.has(entry_id):
			var entry = akashic_entries[entry_id]
			var key = "point_%d" % i
			map.add_point(key, entry.position)
			
			var entity_id = "entity_%d" % i
			map.add_entity(entity_id, {
				"content": entry.content,
				"author": entry.author,
				"tags": entry.tags,
				"position": {
					"x": entry.position.coordinate.x,
					"y": entry.position.coordinate.y,
					"z": entry.position.coordinate.z
				}
			})
			
			i += 1
	
	spatial_maps[map_name] = map
	save_spatial_maps()
	emit_signal("map_created", map_name)
	return true

# Synergistic connections (finds relationships between entries in similar spaces)
func find_spatial_synergies(threshold = 5.0):
	var synergies = []
	
	# Iterate through all entries
	var entry_ids = akashic_entries.keys()
	for i in range(entry_ids.size()):
		var entry_a_id = entry_ids[i]
		var entry_a = akashic_entries[entry_a_id]
		
		for j in range(i + 1, entry_ids.size()):
			var entry_b_id = entry_ids[j]
			var entry_b = akashic_entries[entry_b_id]
			
			# Calculate spatial distance
			var dx = entry_a.position.coordinate.x - entry_b.position.coordinate.x
			var dy = entry_a.position.coordinate.y - entry_b.position.coordinate.y
			var dz = entry_a.position.coordinate.z - entry_b.position.coordinate.z
			
			var distance = sqrt(dx*dx + dy*dy + dz*dz)
			
			# Calculate dimensional energy (entries in same dimension have stronger synergy)
			var dim_factor = 1.0
			if entry_a.position.dimension == entry_b.position.dimension:
				dim_factor = 2.0  # Double strength for same dimension
			
			# Sacred 9 harmonic (enhance connection if distance is a multiple of 9)
			var sacred_factor = 1.0
			if abs(int(distance) % SACRED_NUMBER) < 0.1:  # Close to multiple of 9
				sacred_factor = 3.0  # Triple strength for sacred harmony
			
			# Calculate overall synergy strength
			var synergy_strength = (entry_a.position.power + entry_b.position.power) * sacred_factor * dim_factor / (distance + 1.0)
			
			if synergy_strength > threshold:
				synergies.append({
					"entry_a": entry_a_id,
					"entry_b": entry_b_id,
					"strength": synergy_strength,
					"distance": distance
				})
	
	return synergies

# Find entries in dimensional clusters
func find_dimensional_clusters(min_cluster_size = 3, max_distance = 10.0):
	var clusters = {}
	
	# Initialize clusters by dimension
	for i in range(1, MAX_DIMENSION + 1):
		clusters[i] = []
	
	# Add entries to their dimensional clusters
	for entry_id in akashic_entries:
		var entry = akashic_entries[entry_id]
		var dim = entry.position.dimension
		
		if dim >= 1 and dim <= MAX_DIMENSION:
			clusters[dim].append(entry)
	
	# Find sub-clusters by spatial proximity
	var result_clusters = []
	for dim in clusters:
		var entries = clusters[dim]
		
		if entries.size() < min_cluster_size:
			continue
		
		var sub_clusters = []
		var processed = {}
		
		for entry in entries:
			if processed.has(entry.entry_id):
				continue
				
			var cluster = [entry]
			processed[entry.entry_id] = true
			
			var added = true
			while added:
				added = false
				
				for other_entry in entries:
					if processed.has(other_entry.entry_id):
						continue
					
					# Check if other_entry is close to any entry in current cluster
					for cluster_entry in cluster:
						var dx = cluster_entry.position.coordinate.x - other_entry.position.coordinate.x
						var dy = cluster_entry.position.coordinate.y - other_entry.position.coordinate.y
						var dz = cluster_entry.position.coordinate.z - other_entry.position.coordinate.z
						
						var distance = sqrt(dx*dx + dy*dy + dz*dz)
						
						if distance <= max_distance:
							cluster.append(other_entry)
							processed[other_entry.entry_id] = true
							added = true
							break
			
			if cluster.size() >= min_cluster_size:
				sub_clusters.append({
					"dimension": dim,
					"entries": cluster,
					"size": cluster.size()
				})
		
		result_clusters.append_array(sub_clusters)
	
	return result_clusters