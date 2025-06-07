extends Node

# Spatial Notepad Integration
# Connects SpatialWorldStorage with Notepad3DVisualizer
# Provides bridge between data storage and visual representation
# Terminal 1: Divine Word Genesis

class_name SpatialNotepadIntegration

# ----- COMPONENT REFERENCES -----
var storage: SpatialWorldStorage
var visualizer: Notepad3DVisualizer

# ----- SIGNALS -----
signal cell_created(notebook_name, cell_id)
signal cell_updated(notebook_name, cell_id)
signal cell_deleted(notebook_name, cell_id)
signal entry_visualized(entry_id)

# ----- STATE TRACKING -----
var active_notebook = ""
var active_entries = []
var visualized_cells = {}
var visualized_connections = {}

# ----- CONSTANTS -----
const DEFAULT_CELL_COLOR = Color(1.0, 1.0, 1.0)
const DEFAULT_CONNECTION_COLOR = Color(0.5, 0.8, 1.0)
const DEFAULT_CELL_POWER = 50.0
const DEFAULT_CONNECTION_STRENGTH = 1.0

# ----- INITIALIZATION -----
func _ready():
    print("Spatial Notepad Integration initializing...")

# ----- CONNECTION SETUP -----
func connect_components(world_storage, notepad_visualizer):
    storage = world_storage
    visualizer = notepad_visualizer
    
    if storage and visualizer:
        # Connect signals from storage
        storage.connect("notebook_updated", self, "_on_notebook_updated")
        storage.connect("entry_added", self, "_on_entry_added")
        
        # Connect signals from visualizer
        visualizer.connect("visualization_ready", self, "_on_visualization_ready")
        visualizer.connect("word_selected", self, "_on_word_selected")
        visualizer.connect("dimension_transition_complete", self, "_on_dimension_changed")
        
        print("Connected SpatialWorldStorage to Notepad3DVisualizer")
        return true
    else:
        print("ERROR: Cannot connect components - missing storage or visualizer")
        return false

# ----- NOTEBOOK VISUALIZATION -----
func visualize_notebook(notebook_name):
    if not storage or not visualizer:
        print("ERROR: Components not connected")
        return false
    
    var notebook = storage.get_notepad(notebook_name)
    if not notebook:
        print("ERROR: Notebook '%s' not found" % notebook_name)
        return false
    
    print("Visualizing notebook: %s" % notebook_name)
    active_notebook = notebook_name
    
    # Clear existing visualizations
    clear_visualizations()
    
    # Create visualizations for each cell
    for cell_id in notebook.cells:
        var cell = notebook.cells[cell_id]
        create_cell_visualization(notebook_name, cell)
    
    # Create connections between nearby cells
    create_cell_connections(notebook_name)
    
    return true

func create_cell_visualization(notebook_name, cell):
    # Convert Notepad3DCell to word_data for visualizer
    var word_data = {
        "id": cell.cell_id,
        "text": cell.content,
        "position": cell.position.to_vector3(),
        "rotation": Vector3(0, 0, 0),
        "size": Vector3(1, 1, 1),
        "color": cell.color,
        "power": DEFAULT_CELL_POWER,
        "evolution_stage": 1
    }
    
    # Create word visualization
    var word_node = visualizer.create_word_visualization(word_data)
    if word_node:
        visualized_cells[cell.cell_id] = {
            "notebook": notebook_name,
            "cell": cell,
            "word_data": word_data
        }
        emit_signal("cell_created", notebook_name, cell.cell_id)
        return true
    
    return false

func update_cell_visualization(notebook_name, cell_id):
    if not visualized_cells.has(cell_id):
        return false
    
    var notebook = storage.get_notepad(notebook_name)
    if not notebook:
        return false
    
    var cell = notebook.get_cell(cell_id)
    if not cell:
        return false
    
    # Update word data
    var word_data = visualized_cells[cell_id].word_data
    word_data.text = cell.content
    word_data.position = cell.position.to_vector3()
    word_data.color = cell.color
    
    # Update visualization
    var result = visualizer.update_word_visualization(cell_id, word_data)
    if result:
        visualized_cells[cell_id].cell = cell
        emit_signal("cell_updated", notebook_name, cell_id)
    
    return result

func delete_cell_visualization(cell_id):
    if not visualized_cells.has(cell_id):
        return false
    
    var notebook_name = visualized_cells[cell_id].notebook
    
    # Delete the visualization
    var result = visualizer.delete_word_visualization(cell_id)
    if result:
        visualized_cells.erase(cell_id)
        emit_signal("cell_deleted", notebook_name, cell_id)
    
    return result

func create_cell_connections(notebook_name):
    if not storage:
        return false
    
    var notebook = storage.get_notepad(notebook_name)
    if not notebook:
        return false
    
    # Clear existing connections
    for connection_id in visualized_connections:
        visualizer.delete_connection_visualization(connection_id)
    visualized_connections.clear()
    
    # Create map of cells by position for fast lookup
    var cells_by_position = {}
    for cell_id in notebook.cells:
        var cell = notebook.cells[cell_id]
        var pos_key = "%d_%d_%d" % [int(cell.position.x), int(cell.position.y), int(cell.position.z)]
        cells_by_position[pos_key] = cell
    
    # Find cells that should be connected
    var connections = []
    for cell_id in notebook.cells:
        var cell = notebook.cells[cell_id]
        
        # Check adjacent positions
        for dx in range(-1, 2):
            for dy in range(-1, 2):
                for dz in range(-1, 2):
                    # Skip self
                    if dx == 0 and dy == 0 and dz == 0:
                        continue
                    
                    var neighbor_pos_key = "%d_%d_%d" % [
                        int(cell.position.x + dx),
                        int(cell.position.y + dy),
                        int(cell.position.z + dz)
                    ]
                    
                    if cells_by_position.has(neighbor_pos_key):
                        var neighbor_cell = cells_by_position[neighbor_pos_key]
                        
                        # Create connection ID (make sure it's consistent regardless of order)
                        var cell_ids = [cell.cell_id, neighbor_cell.cell_id]
                        cell_ids.sort()
                        var connection_id = "conn_%s_%s" % [cell_ids[0], cell_ids[1]]
                        
                        # Skip if already processed
                        if visualized_connections.has(connection_id):
                            continue
                        
                        # Create connection data
                        var connection_data = {
                            "id": connection_id,
                            "word1_id": cell.cell_id,
                            "word2_id": neighbor_cell.cell_id,
                            "color": DEFAULT_CONNECTION_COLOR,
                            "strength": DEFAULT_CONNECTION_STRENGTH
                        }
                        
                        connections.append(connection_data)
    
    # Create visualizations for connections
    for connection_data in connections:
        var connection_node = visualizer.create_connection_visualization(connection_data)
        if connection_node:
            visualized_connections[connection_data.id] = connection_data
    
    return true

func clear_visualizations():
    # Clear cells
    var cell_ids = visualized_cells.keys()
    for cell_id in cell_ids:
        delete_cell_visualization(cell_id)
    
    # Clear connections
    var connection_ids = visualized_connections.keys()
    for connection_id in connection_ids:
        visualizer.delete_connection_visualization(connection_id)
    visualized_connections.clear()

# ----- AKASHIC ENTRY VISUALIZATION -----
func visualize_akashic_entries(entry_ids):
    if not storage or not visualizer:
        print("ERROR: Components not connected")
        return false
    
    print("Visualizing %d akashic entries" % entry_ids.size())
    active_entries = entry_ids
    
    # Clear existing visualizations
    clear_visualizations()
    
    # Create visualizations for each entry
    for entry_id in entry_ids:
        var entry = storage.get_akashic_entry(entry_id)
        if entry:
            create_entry_visualization(entry)
    
    # Create connections between entries
    create_entry_connections(entry_ids)
    
    return true

func create_entry_visualization(entry):
    # Convert AkashicEntry to word_data for visualizer
    var word_data = {
        "id": entry.entry_id,
        "text": entry.content,
        "position": entry.position.coordinate.to_vector3(),
        "rotation": Vector3(0, 0, 0),
        "size": Vector3(1, 1, 1) * (1.0 + (entry.position.power / 100.0)),
        "color": get_color_for_tags(entry.tags),
        "power": entry.position.power,
        "evolution_stage": entry.position.dimension / 2  # Higher dimensions = higher evolution
    }
    
    # Create word visualization
    var word_node = visualizer.create_word_visualization(word_data)
    if word_node:
        visualized_cells[entry.entry_id] = {
            "notebook": "akashic",
            "cell": entry,
            "word_data": word_data
        }
        emit_signal("entry_visualized", entry.entry_id)
        return true
    
    return false

func create_entry_connections(entry_ids):
    if not storage:
        return false
    
    # Clear existing connections
    for connection_id in visualized_connections:
        visualizer.delete_connection_visualization(connection_id)
    visualized_connections.clear()
    
    # Create connections based on entry connections
    for entry_id in entry_ids:
        var entry = storage.get_akashic_entry(entry_id)
        if not entry:
            continue
        
        for connected_entry in entry.connections:
            # Skip if not in our active set
            if not entry_ids.has(connected_entry.entry_id):
                continue
            
            # Create connection ID (make sure it's consistent regardless of order)
            var ids = [entry.entry_id, connected_entry.entry_id]
            ids.sort()
            var connection_id = "conn_%s_%s" % [ids[0], ids[1]]
            
            # Skip if already processed
            if visualized_connections.has(connection_id):
                continue
            
            # Create connection data
            var connection_data = {
                "id": connection_id,
                "word1_id": entry.entry_id,
                "word2_id": connected_entry.entry_id,
                "color": Color(0.8, 0.6, 0.2),  # Amber for akashic connections
                "strength": 1.0 + (entry.position.power + connected_entry.position.power) / 200.0
            }
            
            var connection_node = visualizer.create_connection_visualization(connection_data)
            if connection_node:
                visualized_connections[connection_id] = connection_data
    
    # Also create connections for spatial synergies
    var synergies = storage.find_spatial_synergies(5.0)
    for synergy in synergies:
        # Skip if either entry is not in our active set
        if not entry_ids.has(synergy.entry_a) or not entry_ids.has(synergy.entry_b):
            continue
        
        # Create connection ID (make sure it's consistent regardless of order)
        var ids = [synergy.entry_a, synergy.entry_b]
        ids.sort()
        var connection_id = "syn_%s_%s" % [ids[0], ids[1]]
        
        # Skip if already processed
        if visualized_connections.has(connection_id):
            continue
        
        # Create connection data with color based on synergy strength
        var strength = clamp(synergy.strength / 10.0, 0.1, 5.0)
        var color = Color(0.2, 0.6, 1.0).linear_interpolate(Color(1.0, 0.8, 0.2), strength / 5.0)
        
        var connection_data = {
            "id": connection_id,
            "word1_id": synergy.entry_a,
            "word2_id": synergy.entry_b,
            "color": color,
            "strength": strength
        }
        
        var connection_node = visualizer.create_connection_visualization(connection_data)
        if connection_node:
            visualized_connections[connection_id] = connection_data
    
    return true

# ----- UTILITY FUNCTIONS -----
func get_color_for_tags(tags):
    # Generate a color based on tags
    if tags.empty():
        return Color(1, 1, 1)
    
    # Use first tag to determine hue
    var tag_text = tags[0]
    var tag_hash = 0
    for i in range(tag_text.length()):
        tag_hash += tag_text.ord_at(i)
    
    var hue = (tag_hash % 1000) / 1000.0
    var saturation = 0.8
    var value = 0.9
    
    # Adjust saturation and value based on tag count
    if tags.size() > 1:
        saturation = 0.7 + (0.3 * (tags.size() - 1) / 5.0)
        value = 1.0
    
    return Color.from_hsv(hue, saturation, value)

func position_to_world_coords(position):
    # Convert storage coordinate to world coordinate
    return Vector3(position.x, position.y, position.z)

# ----- INTERACTIVE FUNCTIONS -----
func add_cell_at_position(notebook_name, position, content = "", color = DEFAULT_CELL_COLOR):
    if not storage:
        return null
    
    var coord = Vector3(position.x, position.y, position.z)
    var cell_id = storage.add_cell_to_notepad(notebook_name, coord, content, color)
    
    if cell_id and active_notebook == notebook_name:
        var notebook = storage.get_notepad(notebook_name)
        var cell = notebook.get_cell(cell_id)
        create_cell_visualization(notebook_name, cell)
        
        # Update connections
        create_cell_connections(notebook_name)
    
    return cell_id

func update_cell_content(notebook_name, cell_id, new_content):
    if not storage:
        return false
    
    var notebook = storage.get_notepad(notebook_name)
    if not notebook:
        return false
    
    var cell = notebook.get_cell(cell_id)
    if not cell:
        return false
    
    # Update content
    cell.content = new_content
    cell.last_edit = OS.get_unix_time()
    
    # Save changes
    storage.save_notepad_notebooks()
    
    # Update visualization if active
    if active_notebook == notebook_name:
        update_cell_visualization(notebook_name, cell_id)
    
    return true

func update_cell_color(notebook_name, cell_id, new_color):
    if not storage:
        return false
    
    var notebook = storage.get_notepad(notebook_name)
    if not notebook:
        return false
    
    var cell = notebook.get_cell(cell_id)
    if not cell:
        return false
    
    # Update color
    cell.color = new_color
    cell.last_edit = OS.get_unix_time()
    
    # Save changes
    storage.save_notepad_notebooks()
    
    # Update visualization if active
    if active_notebook == notebook_name:
        update_cell_visualization(notebook_name, cell_id)
    
    return true

func delete_cell(notebook_name, cell_id):
    if not storage:
        return false
    
    var notebook = storage.get_notepad(notebook_name)
    if not notebook:
        return false
    
    if not notebook.cells.has(cell_id):
        return false
    
    # Remove cell from notebook
    notebook.cells.erase(cell_id)
    storage.save_notepad_notebooks()
    
    # Update visualization if active
    if active_notebook == notebook_name and visualized_cells.has(cell_id):
        delete_cell_visualization(cell_id)
        
        # Update connections
        create_cell_connections(notebook_name)
    
    return true

func create_notebook_from_entries(entry_ids, notebook_name):
    if not storage:
        return false
    
    var result = storage.create_notepad_from_akashic(entry_ids, notebook_name)
    if result:
        # Switch to new notebook
        visualize_notebook(notebook_name)
    
    return result

# ----- EVENT HANDLERS -----
func _on_notebook_updated(notebook_name):
    if active_notebook == notebook_name:
        # Refresh visualization
        visualize_notebook(notebook_name)

func _on_entry_added(entry_id):
    if active_entries.has(entry_id):
        # Update entry visualization
        var entry = storage.get_akashic_entry(entry_id)
        if entry:
            create_entry_visualization(entry)
            create_entry_connections(active_entries)

func _on_visualization_ready():
    print("Notepad3D Visualizer ready")
    # Initialize with default notebook if available
    var notebooks = storage.notepad_notebooks
    if notebooks.size() > 0:
        visualize_notebook(notebooks.keys()[0])

func _on_word_selected(word_data):
    # Handle interaction with words/cells
    if visualized_cells.has(word_data.id):
        var cell_info = visualized_cells[word_data.id]
        
        # Show cell details (implement UI for this)
        print("Selected cell: %s" % word_data.text)
        
        # You could implement custom UI for editing the cell here

func _on_dimension_changed(dimension):
    # Update visualization based on new dimension
    if active_notebook != "":
        # Redraw connections with potentially new aesthetics
        create_cell_connections(active_notebook)
    elif active_entries.size() > 0:
        # Update entry connections
        create_entry_connections(active_entries)