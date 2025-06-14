extends Node

class_name IntegratedGameSystem

# ----- INTEGRATED GAME SYSTEM -----
# Main controller for the Akashic Notepad3D game
# Manages entities with evolution and dimensions
# Connects all systems together

# ----- CONSTANTS -----
const MAX_ENTITIES = 1000
const EVOLUTION_STAGES = ["seed", "sprout", "sapling", "tree", "transcendent"]
const DIMENSION_NAMES = ["1D", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "11D", "12D"]
const DIMENSION_SYMBOLS = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ"]

# ----- COMPONENT REFERENCES -----
var eden_pitopia_integration = null
var word_manifestation_system = null
var turn_controller = null
var notepad3d_visualizer = null
var ui = null

# ----- GAME STATE -----
var entities = {}
var current_dimension = 2  # Default to 3D (index 2)
var current_dimension_symbol = "γ"
var entity_count = 0
var command_history = []

# ----- SIGNALS -----
signal entity_created(entity_id, entity_data)
signal entity_evolved(entity_id, old_stage, new_stage)
signal command_processed(command, result)
signal dimension_changed(dimension_index, dimension_name, dimension_symbol)

# ----- INITIALIZATION -----
func _ready():
    print("Initializing Integrated Game System...")
    
    # Find component references
    _discover_components()
    
    # Initialize the game UI
    _initialize_ui()
    
    # Load any saved data
    _load_game_data()
    
    # Update initial dimension display
    _update_dimension_display()
    
    print("Integrated Game System initialized")

# ----- COMPONENT DISCOVERY -----
func _discover_components():
    # Find Eden Pitopia Integration
    if has_node("../EdenPitopiaIntegration"):
        eden_pitopia_integration = get_node("../EdenPitopiaIntegration")
    elif has_node("/root/EdenPitopiaIntegration"):
        eden_pitopia_integration = get_node("/root/EdenPitopiaIntegration")
    
    # Find Word Manifestation System
    if has_node("../WordManifestationSystem"):
        word_manifestation_system = get_node("../WordManifestationSystem")
    elif has_node("/root/WordManifestationSystem"):
        word_manifestation_system = get_node("/root/WordManifestationSystem")
    
    # Find Turn Controller
    if has_node("../TurnController"):
        turn_controller = get_node("../TurnController")
    elif has_node("/root/TurnController"):
        turn_controller = get_node("/root/TurnController")
    
    # Find Notepad3D Visualizer
    if has_node("../Notepad3DVisualizer"):
        notepad3d_visualizer = get_node("../Notepad3DVisualizer")
    elif has_node("/root/Notepad3DVisualizer"):
        notepad3d_visualizer = get_node("/root/Notepad3DVisualizer")

# ----- UI INITIALIZATION -----
func _initialize_ui():
    # Find UI elements
    if has_node("../UI"):
        ui = get_node("../UI")
    
    # Connect input signals
    if ui and ui.has_node("CommandPanel/LineEdit"):
        var command_input = ui.get_node("CommandPanel/LineEdit")
        if not command_input.is_connected("text_submitted", Callable(self, "_on_command_entered")):
            command_input.connect("text_submitted", Callable(self, "_on_command_entered"))

# ----- DATA LOADING -----
func _load_game_data():
    # Load entities from save file if exists
    var save_path = "user://entities.json"
    if FileAccess.file_exists(save_path):
        var file = FileAccess.open(save_path, FileAccess.READ)
        var json_string = file.get_as_text()
        var json = JSON.new()
        var error = json.parse(json_string)
        
        if error == OK:
            var data = json.data
            if typeof(data) == TYPE_DICTIONARY and data.has("entities"):
                entities = data.entities
                entity_count = entities.size()
                print("Loaded %d entities" % entity_count)

# ----- ENTITY MANAGEMENT -----
func create_entity(entity_type, data={}):
    # Generate a unique ID
    var entity_id = "entity_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)
    
    # Basic entity properties
    var entity = {
        "id": entity_id,
        "type": entity_type,
        "creation_time": Time.get_unix_time_from_system(),
        "dimension": current_dimension,
        "dimension_name": DIMENSION_NAMES[current_dimension],
        "dimension_symbol": current_dimension_symbol,
        "evolution_stage": 0,  # Start at seed stage
        "data": data
    }
    
    # Store the entity
    entities[entity_id] = entity
    entity_count += 1
    
    # Manifest in connected systems if available
    if eden_pitopia_integration:
        var name = data.get("name", entity_id)
        if entity_type == "word":
            name = data.get("text", entity_id)
        
        var system_ids = eden_pitopia_integration.manifest_word(name)
        
        # Store system IDs in entity data
        entity.system_ids = system_ids
    
    # Emit signal
    emit_signal("entity_created", entity_id, entity)
    
    # Update UI
    _update_entity_display()
    
    return entity_id

func evolve_entity(entity_id, force_stage=null):
    # Check if entity exists
    if not entities.has(entity_id):
        return false
    
    var entity = entities[entity_id]
    var old_stage = entity.evolution_stage
    
    # Calculate new stage
    var new_stage = old_stage + 1
    if force_stage != null:
        new_stage = force_stage
    
    # Cap at maximum stage
    if new_stage >= EVOLUTION_STAGES.size():
        new_stage = EVOLUTION_STAGES.size() - 1
    
    # Update entity
    entity.evolution_stage = new_stage
    entity.last_evolution_time = Time.get_unix_time_from_system()
    
    # Evolve in connected systems
    if eden_pitopia_integration:
        eden_pitopia_integration.evolve_entity(entity_id, new_stage)
    
    # Emit signal
    emit_signal("entity_evolved", entity_id, old_stage, new_stage)
    
    # Update UI
    _update_entity_display()
    
    return true

func get_entity(entity_id):
    if entities.has(entity_id):
        return entities[entity_id]
    return null

func get_entities_in_dimension(dimension):
    var result = []
    for entity_id in entities:
        var entity = entities[entity_id]
        if entity.dimension == dimension:
            result.append(entity)
    return result

func get_entities_by_type(entity_type):
    var result = []
    for entity_id in entities:
        var entity = entities[entity_id]
        if entity.type == entity_type:
            result.append(entity)
    return result

# ----- DIMENSION MANAGEMENT -----
func set_current_dimension(dimension_index):
    if dimension_index < 0 or dimension_index >= DIMENSION_NAMES.size():
        return false
    
    current_dimension = dimension_index
    current_dimension_symbol = DIMENSION_SYMBOLS[dimension_index]
    
    # Synchronize with connected systems
    if eden_pitopia_integration:
        eden_pitopia_integration.synchronize_dimensions(dimension_index)
    
    # Update visualizer if available
    if notepad3d_visualizer:
        notepad3d_visualizer.transition_to_dimension(dimension_index)
    
    # Update UI
    _update_dimension_display()
    
    # Emit signal
    emit_signal("dimension_changed", dimension_index, DIMENSION_NAMES[dimension_index], current_dimension_symbol)
    
    return true

func advance_dimension():
    var next_dimension = (current_dimension + 1) % DIMENSION_NAMES.size()
    return set_current_dimension(next_dimension)

# ----- COMMAND PROCESSING -----
func process_command(command_text):
    print("Processing command: %s" % command_text)
    
    # Add to command history
    command_history.append(command_text)
    
    # Split into command and arguments
    var parts = command_text.split(" ", false)
    var command = parts[0].to_lower()
    var args = parts.slice(1)
    
    var result = {
        "success": false,
        "message": "Unknown command: " + command
    }
    
    # Process different command types
    match command:
        "help":
            result = {
                "success": true,
                "message": "Available commands:\n" +
                          "help - Show this help\n" +
                          "create <type> <name> - Create a new entity\n" +
                          "evolve <entity_id> - Evolve an entity\n" +
                          "list [dimension|type] - List entities\n" +
                          "dimension <index> - Change dimension\n" +
                          "next - Advance to next dimension\n"
            }
        
        "create":
            if args.size() >= 2:
                var type = args[0]
                var name = args[1]
                var entity_data = {"name": name}
                
                if type == "word":
                    entity_data["text"] = name
                
                var entity_id = create_entity(type, entity_data)
                result = {
                    "success": true,
                    "message": "Created %s entity '%s' with ID %s" % [type, name, entity_id]
                }
            else:
                result = {
                    "success": false,
                    "message": "Usage: create <type> <name>"
                }
        
        "evolve":
            if args.size() >= 1:
                var entity_id = args[0]
                var target_stage = null
                
                if args.size() >= 2 and args[1].is_valid_integer():
                    target_stage = int(args[1])
                
                if evolve_entity(entity_id, target_stage):
                    var entity = entities[entity_id]
                    var stage_name = EVOLUTION_STAGES[entity.evolution_stage]
                    result = {
                        "success": true,
                        "message": "Evolved entity to stage %d (%s)" % [entity.evolution_stage, stage_name]
                    }
                else:
                    result = {
                        "success": false,
                        "message": "Failed to evolve entity. Entity not found."
                    }
            else:
                result = {
                    "success": false,
                    "message": "Usage: evolve <entity_id> [target_stage]"
                }
        
        "list":
            var filter = "all"
            if args.size() >= 1:
                filter = args[0]
            
            var entity_list = []
            
            if filter == "dimension":
                entity_list = get_entities_in_dimension(current_dimension)
                result = {
                    "success": true,
                    "message": "Entities in dimension %s (%d total):\n" % [DIMENSION_NAMES[current_dimension], entity_list.size()]
                }
            elif filter == "type" and args.size() >= 2:
                var type = args[1]
                entity_list = get_entities_by_type(type)
                result = {
                    "success": true,
                    "message": "Entities of type '%s' (%d total):\n" % [type, entity_list.size()]
                }
            else:
                # List all entities
                for entity_id in entities:
                    entity_list.append(entities[entity_id])
                result = {
                    "success": true,
                    "message": "All entities (%d total):\n" % entity_list.size()
                }
            
            # Format entity list
            for entity in entity_list:
                var stage = EVOLUTION_STAGES[entity.evolution_stage]
                var name = entity.data.get("name", entity.id)
                result.message += "- %s (%s, Stage: %s)\n" % [name, entity.type, stage]
        
        "dimension":
            if args.size() >= 1 and args[0].is_valid_integer():
                var dimension = int(args[0]) % DIMENSION_NAMES.size()
                if set_current_dimension(dimension):
                    result = {
                        "success": true,
                        "message": "Changed to dimension %s (%s)" % [DIMENSION_NAMES[dimension], DIMENSION_SYMBOLS[dimension]]
                    }
                else:
                    result = {
                        "success": false,
                        "message": "Failed to change dimension"
                    }
            else:
                result = {
                    "success": false,
                    "message": "Usage: dimension <index>"
                }
        
        "next":
            if advance_dimension():
                result = {
                    "success": true,
                    "message": "Advanced to dimension %s (%s)" % [DIMENSION_NAMES[current_dimension], DIMENSION_SYMBOLS[current_dimension]]
                }
            else:
                result = {
                    "success": false,
                    "message": "Failed to advance dimension"
                }
        
        _:
            # If not a command, treat as text to manifest
            if command_text.strip_edges() != "":
                var entity_id = create_entity("word", {"text": command_text})
                result = {
                    "success": true,
                    "message": "Manifested word '%s' with ID %s" % [command_text, entity_id]
                }
    
    # Emit command processed signal
    emit_signal("command_processed", command_text, result)
    
    return result

# ----- UI UPDATES -----
func _update_dimension_display():
    if ui and ui.has_node("InfoPanel/DimensionInfo"):
        var dimension_label = ui.get_node("InfoPanel/DimensionInfo")
        dimension_label.text = "Dimension: %s (%s)" % [DIMENSION_NAMES[current_dimension], DIMENSION_SYMBOLS[current_dimension]]

func _update_entity_display():
    if ui and ui.has_node("InfoPanel/EntityInfo"):
        var entity_label = ui.get_node("InfoPanel/EntityInfo")
        
        var dimension_count = 0
        for entity_id in entities:
            if entities[entity_id].dimension == current_dimension:
                dimension_count += 1
        
        entity_label.text = "Entities: %d total\n%d in current dimension" % [entity_count, dimension_count]

# ----- SIGNAL HANDLERS -----
func _on_command_entered(text):
    # Process the command
    var result = process_command(text)
    
    # Clear the input field
    if ui and ui.has_node("CommandPanel/LineEdit"):
        ui.get_node("CommandPanel/LineEdit").clear()
    
    # Show result in UI or console
    print(result.message)

func _on_turn_changed(turn_number, dimension_symbol, dimension_properties):
    var dimension_index = turn_number % DIMENSION_NAMES.size()
    set_current_dimension(dimension_index)

func _on_dimension_synchronized(dimension_index, dimension_name):
    set_current_dimension(dimension_index)

func _on_entity_mapped(akashic_id, system_mappings):
    # If we have this entity, update its system IDs
    if entities.has(akashic_id):
        entities[akashic_id].system_ids = system_mappings

func _on_word_manifested(word_text, system_name, entity_id):
    # If we don't have this entity yet, create it
    if not entities.has(word_text):
        create_entity("word", {"text": word_text})

# ----- SAVING AND LOADING -----
func save_game_data():
    # Save entities to file
    var save_data = {
        "entities": entities,
        "current_dimension": current_dimension,
        "entity_count": entity_count
    }
    
    var file = FileAccess.open("user://entities.json", FileAccess.WRITE)
    var json_string = JSON.stringify(save_data)
    file.store_string(json_string)
    
    print("Game data saved")
    return true

# ----- CONNECTION UTILITY -----
func connect_folder(folder_path, connection_type="data"):
    print("Connecting folder: %s as %s" % [folder_path, connection_type])
    
    # Different handling based on connection type
    match connection_type:
        "data":
            # Scan for data files
            var dir = DirAccess.open(folder_path)
            if dir:
                dir.list_dir_begin()
                var file_name = dir.get_next()
                while file_name != "":
                    if !dir.current_is_dir() and file_name.ends_with(".json"):
                        # Load data file
                        var file_path = folder_path.path_join(file_name)
                        _load_data_file(file_path)
                    file_name = dir.get_next()
                return true
            else:
                return false
        
        "project":
            # Connect to another Godot project
            return _connect_godot_project(folder_path)
        
        "scripts":
            # Load and register scripts from folder
            return _load_scripts_from_folder(folder_path)
        
        _:
            print("Unknown connection type: %s" % connection_type)
            return false

func _load_data_file(file_path):
    if FileAccess.file_exists(file_path):
        var file = FileAccess.open(file_path, FileAccess.READ)
        var json_string = file.get_as_text()
        var json = JSON.new()
        var error = json.parse(json_string)
        
        if error == OK:
            var data = json.data
            print("Loaded data file: %s" % file_path)
            
            # Process data based on filename
            var filename = file_path.get_file()
            
            if filename.begins_with("entities"):
                # Merge entities
                for entity_id in data:
                    if !entities.has(entity_id):
                        entities[entity_id] = data[entity_id]
                        entity_count += 1
            
            return true
        else:
            print("JSON parse error: %s" % json.get_error_message())
            return false
    else:
        print("File not found: %s" % file_path)
        return false

func _connect_godot_project(folder_path):
    # Check if it's a valid Godot project by looking for project.godot
    if FileAccess.file_exists(folder_path.path_join("project.godot")):
        print("Valid Godot project found: %s" % folder_path)
        
        # Scan for interesting script files
        _scan_for_scripts(folder_path)
        
        return true
    else:
        print("Not a valid Godot project: %s" % folder_path)
        return false

func _scan_for_scripts(folder_path):
    var found_scripts = []
    
    # Recursively scan for .gd files
    var dir = DirAccess.open(folder_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if dir.current_is_dir() and file_name != "." and file_name != "..":
                # Scan subdirectory
                var subdir_path = folder_path.path_join(file_name)
                found_scripts.append_array(_scan_for_scripts(subdir_path))
            elif file_name.ends_with(".gd"):
                # Found a script, check if it's interesting
                var script_path = folder_path.path_join(file_name)
                if _is_interesting_script(script_path):
                    found_scripts.append(script_path)
            file_name = dir.get_next()
    
    return found_scripts

func _is_interesting_script(script_path):
    # Check if script contains keywords we're interested in
    var file = FileAccess.open(script_path, FileAccess.READ)
    var content = file.get_as_text()
    
    var keywords = ["akashic", "notepad", "dimension", "word", "manifestation", "entity"]
    
    for keyword in keywords:
        if content.to_lower().contains(keyword):
            print("Found interesting script: %s" % script_path)
            return true
    
    return false

func _load_scripts_from_folder(folder_path):
    var loaded_scripts = []
    
    var dir = DirAccess.open(folder_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if !dir.current_is_dir() and file_name.ends_with(".gd"):
                var script_path = folder_path.path_join(file_name)
                var script = load(script_path)
                if script:
                    loaded_scripts.append(script_path)
            file_name = dir.get_next()
    
    print("Loaded %d scripts from %s" % [loaded_scripts.size(), folder_path])
    return loaded_scripts.size() > 0