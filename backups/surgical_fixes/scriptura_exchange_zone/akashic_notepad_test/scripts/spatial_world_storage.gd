extends Node

# Remove class_name to avoid conflict with autoload
# class_name SpatialWorldStorage

# ----- SPATIAL WORLD STORAGE -----
# Simplified implementation for testing
# Manages 3D notebooks and akashic records

# ----- CLASSES -----
class Coordinate:
    var x: float
    var y: float
    var z: float
    
    func _init(x_val: float = 0, y_val: float = 0, z_val: float = 0):
        x = x_val
        y = y_val
        z = z_val
    
    func to_vector3() -> Vector3:
        return Vector3(x, y, z)

class DimensionalPoint:
    var coordinate: Coordinate
    var dimension: int
    var power: float
    
    func _init(coord: Coordinate, dim: int = 3, pow: float = 50.0):
        coordinate = coord
        dimension = dim
        power = pow

class AkashicEntry:
    var entry_id: String
    var position: DimensionalPoint
    var content: String
    var author: String
    var timestamp: int
    var tags: Array
    var connections: Array
    
    func _init(id: String, dim_point: DimensionalPoint, text: String, auth: String = "system", tag_list: Array = []):
        entry_id = id
        position = dim_point
        content = text
        author = auth
        timestamp = Time.get_unix_time_from_system()
        tags = tag_list
        connections = []

class Notepad3DCell:
    var cell_id: String
    var position: Coordinate
    var content: String
    var color: Color
    var creation_time: int
    var last_edit: int
    
    func _init(id: String, pos: Coordinate, text: String = "", col: Color = Color.WHITE):
        cell_id = id
        position = pos
        content = text
        color = col
        creation_time = Time.get_unix_time_from_system()
        last_edit = creation_time

class Notepad3D:
    var notebook_name: String
    var cells: Dictionary
    var tags: Array
    var creation_time: int
    
    func _init(name: String, tag_list: Array = []):
        notebook_name = name
        cells = {}
        tags = tag_list
        creation_time = Time.get_unix_time_from_system()
    
    func get_cell(cell_id: String):
        if cells.has(cell_id):
            return cells[cell_id]
        return null

class SpatialSynergy:
    var entry_a: String
    var entry_b: String
    var strength: float
    var synergy_type: String
    
    func _init(a: String, b: String, str: float = 1.0, type: String = "proximity"):
        entry_a = a
        entry_b = b
        strength = str
        synergy_type = type

# ----- STORAGE CONTAINERS -----
var akashic_records: Dictionary = {}
var notepad_notebooks: Dictionary = {}
var spatial_maps: Dictionary = {}

# ----- SIGNALS -----
signal entry_added(entry_id)
signal notebook_updated(notebook_name)

# ----- INITIALIZATION -----
func _ready():
    print("Spatial World Storage initialized")

# ----- AKASHIC RECORDS FUNCTIONS -----
func add_akashic_entry(dim_point: DimensionalPoint, content: String, author: String = "system", tags: Array = []) -> String:
    # Generate unique ID
    var entry_id = "akashic_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)
    
    # Create entry
    var entry = AkashicEntry.new(entry_id, dim_point, content, author, tags)
    
    # Store entry
    akashic_records[entry_id] = entry
    
    # Emit signal
    emit_signal("entry_added", entry_id)
    
    print("Added akashic entry: %s" % entry_id)
    return entry_id

func get_akashic_entry(entry_id: String):
    if akashic_records.has(entry_id):
        return akashic_records[entry_id]
    return null

func find_entries_by_tag(tag: String) -> Array:
    var result = []
    for entry_id in akashic_records:
        var entry = akashic_records[entry_id]
        if tag in entry.tags:
            result.append(entry)
    return result

func find_entries_by_dimension(dimension: int) -> Array:
    var result = []
    for entry_id in akashic_records:
        var entry = akashic_records[entry_id]
        if entry.position.dimension == dimension:
            result.append(entry)
    return result

func connect_entries(source_id: String, target_id: String) -> bool:
    if not akashic_records.has(source_id) or not akashic_records.has(target_id):
        return false
    
    var source_entry = akashic_records[source_id]
    var target_entry = akashic_records[target_id]
    
    # Add connection if not already exists
    if not target_entry in source_entry.connections:
        source_entry.connections.append(target_entry)
    
    if not source_entry in target_entry.connections:
        target_entry.connections.append(source_entry)
    
    return true

func find_spatial_synergies(threshold: float = 5.0) -> Array:
    var synergies = []
    
    var entry_ids = akashic_records.keys()
    for i in range(entry_ids.size()):
        for j in range(i + 1, entry_ids.size()):
            var entry_a = akashic_records[entry_ids[i]]
            var entry_b = akashic_records[entry_ids[j]]
            
            # Calculate distance between entries
            var pos_a = entry_a.position.coordinate.to_vector3()
            var pos_b = entry_b.position.coordinate.to_vector3()
            var distance = pos_a.distance_to(pos_b)
            
            # Check if close enough for synergy
            if distance <= threshold:
                var strength = threshold - distance
                var synergy = SpatialSynergy.new(entry_a.entry_id, entry_b.entry_id, strength)
                synergies.append(synergy)
    
    return synergies

# ----- NOTEPAD FUNCTIONS -----
func create_notepad(name: String, tags: Array = []) -> String:
    if notepad_notebooks.has(name):
        print("Notepad '%s' already exists" % name)
        return ""
    
    var notebook = Notepad3D.new(name, tags)
    notepad_notebooks[name] = notebook
    
    emit_signal("notebook_updated", name)
    
    print("Created notepad: %s" % name)
    return name

func get_notepad(name: String):
    if notepad_notebooks.has(name):
        return notepad_notebooks[name]
    return null

func add_cell_to_notepad(notebook_name: String, position: Vector3, content: String = "", color: Color = Color.WHITE) -> String:
    if not notepad_notebooks.has(notebook_name):
        print("Notepad '%s' does not exist" % notebook_name)
        return ""
    
    var notebook = notepad_notebooks[notebook_name]
    var cell_id = "cell_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)
    var coord = Coordinate.new(position.x, position.y, position.z)
    var cell = Notepad3DCell.new(cell_id, coord, content, color)
    
    notebook.cells[cell_id] = cell
    
    emit_signal("notebook_updated", notebook_name)
    
    print("Added cell to notepad '%s': %s" % [notebook_name, cell_id])
    return cell_id

func create_notepad_from_akashic(entry_ids: Array, notebook_name: String) -> bool:
    if notepad_notebooks.has(notebook_name):
        print("Notepad '%s' already exists" % notebook_name)
        return false
    
    # Create notebook
    var notebook = Notepad3D.new(notebook_name, ["akashic", "generated"])
    
    # Add cells for each entry
    for entry_id in entry_ids:
        if akashic_records.has(entry_id):
            var entry = akashic_records[entry_id]
            var position = entry.position.coordinate.to_vector3()
            var cell_id = add_cell_to_notepad(notebook_name, position, entry.content, Color.CYAN)
    
    notepad_notebooks[notebook_name] = notebook
    emit_signal("notebook_updated", notebook_name)
    
    return true

# ----- PERSISTENCE FUNCTIONS -----
func save_akashic_records():
    print("Saving akashic records...")
    # In a real implementation, this would save to file
    
func save_notepad_notebooks():
    print("Saving notepad notebooks...")
    # In a real implementation, this would save to file
    
func save_spatial_maps():
    print("Saving spatial maps...")
    # In a real implementation, this would save to file

func load_all_data():
    print("Loading all data...")
    # In a real implementation, this would load from files