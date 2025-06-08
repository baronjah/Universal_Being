extends Node

# Integrated Game System
# Combines 12 Turns, Notepad3D, Akashic Records, and Word Evolution
# into a complete game experience with unified interface and gameplay

class_name IntegratedGameSystem

# ----- COMPONENT REFERENCES -----
var akashic_controller = null
var system_integrator = null
var main_controller = null
var word_manifestation_system = null
var universal_connector = null
var spatial_storage = null
var notepad_visualizer = null

# ----- INTEGRATION NODES -----
var akashic_scene = null
var dimension_scene = null
var terminal_ui = null
var word_ui = null
var entity_manager = null

# ----- STATE VARIABLES -----
var current_turn = 3  # Default to 3D dimension
var current_symbol = "γ"
var current_dimension = "3D"
var current_cosmic_age = "Complexity"
var current_project = "12_turns_system"
var visualization_active = false
var current_entities = {}
var entity_types = ["word", "note", "akashic", "shape", "terminal", "node"]
var evolution_stages = ["seed", "sprout", "sapling", "tree", "transcendent"]
var active_folder_paths = []
var connected_folders = {}

# ----- SIGNAL HANDLING -----
signal system_initialized
signal entity_created(entity_id, entity_type, entity_data)
signal entity_evolved(entity_id, old_stage, new_stage)
signal dimension_changed(turn_number, symbol, dimension_name)
signal folder_connected(folder_path, connection_type)
signal project_changed(old_project, new_project)

# ----- INITIALIZATION -----
func _ready():
    print("Initializing Integrated Game System...")
    
    # Create core components
    setup_components()
    
    # Initialize folder connections
    initialize_folder_connections()
    
    # Wait for all components to be ready
    call_deferred("finalize_initialization")

func setup_components():
    # Create universal connector
    universal_connector = UniversalAkashicConnector.new()
    add_child(universal_connector)
    
    # Create spatial storage
    spatial_storage = SpatialWorldStorage.new()
    add_child(spatial_storage)
    
    # Create system integrator
    system_integrator = load("res://system_integrator.gd").new()
    add_child(system_integrator)
    
    # Create akashic controller
    akashic_controller = load("res://akashic_notepad_controller.gd").new()
    add_child(akashic_controller)
    
    # Create word manifestation system
    word_manifestation_system = load("res://word_manifestation_system.gd").new()
    add_child(word_manifestation_system)
    
    # Create main controller if needed
    if not has_node("/root/MainController"):
        main_controller = load("res://main.gd").new()
        main_controller.name = "MainController"
        add_child(main_controller)
    else:
        main_controller = get_node("/root/MainController")
    
    # Create terminal UI
    terminal_ui = Control.new()
    terminal_ui.name = "TerminalUI"
    terminal_ui.anchor_right = 1.0
    terminal_ui.anchor_bottom = 1.0
    add_child(terminal_ui)
    
    # Create entity manager
    entity_manager = Node.new()
    entity_manager.name = "EntityManager"
    add_child(entity_manager)

func initialize_folder_connections():
    # Define important folders to connect
    var folders_to_connect = [
        "/mnt/c/Users/Percision 15/12_turns_system",
        "/mnt/c/Users/Percision 15/Eden_OS",
        "/mnt/c/Users/Percision 15/LuminusOS"
    ]
    
    # Connect to each folder
    for folder_path in folders_to_connect:
        connect_folder(folder_path)
    
    # Connect subdirectories for deeper integration
    connect_folder("/mnt/c/Users/Percision 15/12_turns_system/data")
    connect_folder("/mnt/c/Users/Percision 15/12_turns_system/core")
    connect_folder("/mnt/c/Users/Percision 15/12_turns_system/messages")
    connect_folder("/mnt/c/Users/Percision 15/LuminusOS/scripts")

func finalize_initialization():
    # Connect components
    connect_components()
    
    # Setup UI elements
    setup_ui()
    
    # Start in 3D mode (default dimension)
    set_current_dimension(current_turn)
    
    # Initialize visualization scene
    setup_visualization_scene()
    
    # Emit initialization signal
    print("Integrated Game System initialization complete!")
    emit_signal("system_initialized")

# ----- COMPONENT CONNECTIONS -----
func connect_components():
    # Connect akashic controller to main controller
    akashic_controller.set_main_controller(main_controller)
    
    # Connect word manifestation system
    if word_manifestation_system:
        akashic_controller.set_word_manifestation_system(word_manifestation_system)
        
        # Connect word manifestation to main controller
        if main_controller and main_controller.has_method("connect_word_manifestation"):
            main_controller.connect_word_manifestation(word_manifestation_system)
    
    # Connect system integrator to akashic controller
    system_integrator.akashic_controller = akashic_controller
    
    # Connect signals from main controller
    if main_controller:
        main_controller.connect("turn_advanced", self, "_on_turn_advanced")
        main_controller.connect("note_created", self, "_on_note_created")
        main_controller.connect("word_manifested", self, "_on_word_manifested")
        
        if main_controller.has_signal("reality_changed"):
            main_controller.connect("reality_changed", self, "_on_reality_changed")
    
    # Connect signals from universal connector
    universal_connector.connect("system_connected", self, "_on_system_connected")
    universal_connector.connect("dimension_accessed", self, "_on_dimension_accessed")
    universal_connector.connect("record_transferred", self, "_on_record_transferred")
    
    # Connect signals from akashic controller
    akashic_controller.connect("record_created", self, "_on_record_created")
    akashic_controller.connect("akashic_synergy_detected", self, "_on_akashic_synergy_detected")
    akashic_controller.connect("dimension_power_calculated", self, "_on_dimension_power_calculated")

func setup_ui():
    # Create the main layout
    var main_layout = VBoxContainer.new()
    main_layout.anchor_right = 1.0
    main_layout.anchor_bottom = 1.0
    terminal_ui.add_child(main_layout)
    
    # Add dimension indicator
    var dimension_label = Label.new()
    dimension_label.name = "DimensionLabel"
    dimension_label.text = "%s: %s (%s)" % [current_turn, current_symbol, current_dimension]
    dimension_label.align = Label.ALIGN_CENTER
    main_layout.add_child(dimension_label)
    
    # Add status bar
    var status_bar = HBoxContainer.new()
    status_bar.name = "StatusBar"
    main_layout.add_child(status_bar)
    
    var turn_label = Label.new()
    turn_label.name = "TurnLabel"
    turn_label.text = "Turn: %d" % current_turn
    status_bar.add_child(turn_label)
    
    var spacer = Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    status_bar.add_child(spacer)
    
    var entity_count_label = Label.new()
    entity_count_label.name = "EntityCountLabel"
    entity_count_label.text = "Entities: 0"
    status_bar.add_child(entity_count_label)
    
    # Add folder list
    var folder_list = ItemList.new()
    folder_list.name = "FolderList"
    folder_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
    folder_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    folder_list.rect_min_size = Vector2(0, 100)
    folder_list.connect("item_selected", self, "_on_folder_selected")
    main_layout.add_child(folder_list)
    
    # Add command line
    var command_line = LineEdit.new()
    command_line.name = "CommandLine"
    command_line.placeholder_text = "Enter command..."
    command_line.clear_button_enabled = true
    command_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    command_line.connect("text_entered", self, "_on_command_entered")
    main_layout.add_child(command_line)
    
    # Add visualization toggle
    var button_container = HBoxContainer.new()
    button_container.name = "ButtonContainer"
    main_layout.add_child(button_container)
    
    var vis_button = Button.new()
    vis_button.name = "VisualizationButton"
    vis_button.text = "Toggle 3D View"
    vis_button.connect("pressed", self, "_on_visualization_button_pressed")
    button_container.add_child(vis_button)
    
    var evolution_button = Button.new()
    evolution_button.name = "EvolutionButton"
    evolution_button.text = "Evolve Entities"
    evolution_button.connect("pressed", self, "_on_evolution_button_pressed")
    button_container.add_child(evolution_button)
    
    var connect_folder_button = Button.new()
    connect_folder_button.name = "ConnectFolderButton"
    connect_folder_button.text = "Connect Folder"
    connect_folder_button.connect("pressed", self, "_on_connect_folder_button_pressed")
    button_container.add_child(connect_folder_button)
    
    # Update folder list
    update_folder_list()

# ----- FOLDER MANAGEMENT -----
func connect_folder(folder_path, connection_type = "standard"):
    if not Directory.new().dir_exists(folder_path):
        print("Cannot connect folder: Directory does not exist: %s" % folder_path)
        return false
    
    # Skip if already connected
    if connected_folders.has(folder_path):
        return true
    
    print("Connecting folder: %s" % folder_path)
    
    # Register the folder
    connected_folders[folder_path] = {
        "connection_type": connection_type,
        "connected_at": OS.get_unix_time(),
        "file_count": 0,
        "godot_files": 0,
        "entities": [],
        "synced": false
    }
    
    # Add to active paths
    if not active_folder_paths.has(folder_path):
        active_folder_paths.append(folder_path)
    
    # Count files and scan for Godot scripts
    var file_count = 0
    var godot_files = 0
    _scan_directory(folder_path, file_count, godot_files)
    
    connected_folders[folder_path].file_count = file_count
    connected_folders[folder_path].godot_files = godot_files
    
    # Create akashic entry for the connection
    if akashic_controller:
        var content = "Connected folder: %s with %d files (%d Godot scripts)" % [
            folder_path, file_count, godot_files
        ]
        
        var position = Vector3(
            randf() * 10 - 5,
            randf() * 10,
            randf() * 10 - 5
        )
        
        akashic_controller.create_akashic_entry(
            content,
            position,
            current_turn,
            ["folder", "connection", "project"]
        )
    
    # Update UI if available
    update_folder_list()
    
    # Emit signal
    emit_signal("folder_connected", folder_path, connection_type)
    
    return true

func disconnect_folder(folder_path):
    if not connected_folders.has(folder_path):
        return false
    
    print("Disconnecting folder: %s" % folder_path)
    
    # Remove from connected folders
    var folder_data = connected_folders[folder_path]
    connected_folders.erase(folder_path)
    
    # Remove from active paths
    if active_folder_paths.has(folder_path):
        active_folder_paths.erase(folder_path)
    
    # Update UI
    update_folder_list()
    
    return true

func update_folder_list():
    var folder_list = terminal_ui.get_node_or_null("FolderList")
    if not folder_list:
        folder_list = terminal_ui.find_node("FolderList", true, false)
    
    if not folder_list:
        return
    
    # Clear list
    folder_list.clear()
    
    # Add connected folders
    for folder_path in connected_folders:
        var folder_data = connected_folders[folder_path]
        var folder_name = folder_path.get_file()
        
        var item_text = "%s - %d files" % [folder_name, folder_data.file_count]
        folder_list.add_item(item_text, null, true)
        
        # Store folder path as metadata
        var idx = folder_list.get_item_count() - 1
        folder_list.set_item_metadata(idx, folder_path)
        
        # Set tooltip
        folder_list.set_item_tooltip(idx, folder_path)

func _scan_directory(directory_path, file_count, godot_files):
    var dir = Directory.new()
    
    if dir.open(directory_path) == OK:
        dir.list_dir_begin(true, true)
        
        var file_name = dir.get_next()
        while file_name != "":
            var full_path = directory_path.plus_file(file_name)
            
            if dir.current_is_dir():
                # Recursively scan subdirectory
                _scan_directory(full_path, file_count, godot_files)
            else:
                file_count += 1
                
                # Check for Godot script
                if file_name.ends_with(".gd"):
                    godot_files += 1
                    
                    # Register script with universal connector if appropriate
                    if file_name.find("akashic") >= 0 or file_name.find("word") >= 0 or 
                       file_name.find("note") >= 0 or file_name.find("dimension") >= 0:
                        _register_script_with_connector(full_path, file_name)
            
            file_name = dir.get_next()
        
        dir.list_dir_end()

func _register_script_with_connector(script_path, script_name):
    if universal_connector:
        # Try to determine script type
        var system_type = ""
        
        if script_name.find("akashic") >= 0:
            system_type = "akashic_records"
        elif script_name.find("word") >= 0:
            system_type = "word_processor"
        elif script_name.find("note") >= 0:
            system_type = "notepad"
        elif script_name.find("dimension") >= 0:
            system_type = "dimension_controller"
        else:
            system_type = "unknown"
        
        # Register with universal connector
        universal_connector._try_connect_system(script_name.get_basename(), system_type, script_path)

# ----- VISUALIZATION -----
func setup_visualization_scene():
    # Create akashic scene
    akashic_scene = load("res://akashic_notepad_scene.tscn").instance()
    add_child(akashic_scene)
    
    # Get notepad visualizer reference
    notepad_visualizer = akashic_scene.get_node("VisualizationContainer/Notepad3DVisualizer")
    
    # Connect visualizer to akashic controller
    if notepad_visualizer and akashic_controller:
        akashic_controller.set_visualizer(notepad_visualizer)
        
        # Set visualizer as inactive initially
        toggle_visualization(false)
    
    # Initialize the first dimension
    if akashic_controller:
        akashic_controller.visualize_akashic_record(current_turn)

func toggle_visualization(active = true):
    visualization_active = active
    
    if akashic_scene:
        # Toggle visibility of visualization elements
        var vis_container = akashic_scene.get_node("VisualizationContainer")
        if vis_container:
            vis_container.visible = active
        
        # Toggle camera
        var camera = akashic_scene.get_node("VisualizationContainer/VisualizationCamera")
        if camera:
            camera.current = active
    
    # Update button text
    var vis_button = terminal_ui.find_node("VisualizationButton", true, false)
    if vis_button:
        vis_button.text = "3D View: %s" % ("ON" if active else "OFF")
    
    return active

# ----- ENTITY MANAGEMENT -----
func create_entity(entity_type, data):
    if not entity_type in entity_types:
        push_error("Invalid entity type: %s" % entity_type)
        return null
    
    # Generate entity ID
    var entity_id = "entity_%s_%d" % [entity_type, OS.get_unix_time()]
    
    # Create entity data
    var entity = {
        "id": entity_id,
        "type": entity_type,
        "data": data,
        "created_at": OS.get_unix_time(),
        "turn": current_turn,
        "dimension": current_dimension,
        "symbol": current_symbol,
        "stage": "seed",
        "evolution_points": 0,
        "connections": []
    }
    
    # Add to entity manager
    current_entities[entity_id] = entity
    
    # Update label
    update_entity_count_label()
    
    # Create 3D representation if appropriate
    create_entity_visualization(entity)
    
    # Emit signal
    emit_signal("entity_created", entity_id, entity_type, data)
    
    return entity_id

func evolve_entity(entity_id, force_stage = ""):
    if not current_entities.has(entity_id):
        return false
    
    var entity = current_entities[entity_id]
    var old_stage = entity.stage
    var new_stage = old_stage
    
    # Determine evolution
    if force_stage != "" and evolution_stages.has(force_stage):
        new_stage = force_stage
    else:
        # Increment evolution points
        entity.evolution_points += 1
        
        # Determine new stage based on points
        var stage_index = evolution_stages.find(old_stage)
        
        if entity.evolution_points >= (stage_index + 1) * 5:
            stage_index += 1
            
            if stage_index < evolution_stages.size():
                new_stage = evolution_stages[stage_index]
    
    # Update if stage changed
    if new_stage != old_stage:
        entity.stage = new_stage
        
        # Update visualization
        update_entity_visualization(entity)
        
        # Log the evolution
        print("Entity %s evolved from %s to %s" % [entity_id, old_stage, new_stage])
        
        # Emit signal
        emit_signal("entity_evolved", entity_id, old_stage, new_stage)
        
        return true
    
    return false

func create_entity_visualization(entity):
    if not visualization_active or not akashic_controller:
        return null
    
    # Create visualization based on entity type
    match entity.type:
        "word":
            if "text" in entity.data:
                var position = Vector3(
                    randf() * 10 - 5,
                    randf() * 2 + 1,
                    randf() * 10 - 5
                )
                
                var power = entity.data.get("power", 50)
                
                akashic_controller.create_akashic_entry(
                    entity.data.text,
                    position,
                    current_turn,
                    ["word", entity.stage]
                )
                
                # Remember visualization ID
                entity.visualization_id = entity.data.text
        
        "note":
            if "content" in entity.data:
                var position = Vector3(
                    randf() * 10 - 5,
                    randf() * 2 + 3,
                    randf() * 10 - 5
                )
                
                akashic_controller.create_akashic_entry(
                    entity.data.content,
                    position,
                    current_turn,
                    ["note", entity.stage]
                )
                
                # Remember visualization ID
                entity.visualization_id = entity.data.content
        
        "akashic":
            # Already visualized directly
            pass
        
        "shape":
            if "dimensions" in entity.data:
                var notebook_name = "shapes_%d" % current_turn
                
                # Create notepad if needed
                if not akashic_controller.get_spatial_storage().get_notepad(notebook_name):
                    akashic_controller.create_notepad(notebook_name, ["shape", "geometry"])
                
                # Create 3D cells to represent the shape
                var width = entity.data.dimensions.x
                var height = entity.data.dimensions.y
                var depth = entity.data.dimensions.z
                
                for x in range(width):
                    for y in range(height):
                        for z in range(depth):
                            var cell_pos = Vector3(x, y, z)
                            var content = "Shape: %s" % entity.id
                            var color = entity.data.get("color", Color.white)
                            
                            akashic_controller.add_notepad_cell(notebook_name, cell_pos, content, color)
        
        "terminal":
            if "command" in entity.data:
                var position = Vector3(
                    randf() * 10 - 5,
                    randf() * 2 + 5,
                    randf() * 10 - 5
                )
                
                akashic_controller.create_akashic_entry(
                    "Terminal: " + entity.data.command,
                    position,
                    current_turn,
                    ["terminal", "command", entity.stage]
                )
        
        "node":
            if "script_path" in entity.data:
                var position = Vector3(
                    randf() * 10 - 5,
                    randf() * 2 + 7,
                    randf() * 10 - 5
                )
                
                var script_name = entity.data.script_path.get_file()
                
                akashic_controller.create_akashic_entry(
                    "Script: " + script_name,
                    position,
                    current_turn,
                    ["node", "script", entity.stage]
                )

func update_entity_visualization(entity):
    if not visualization_active or not akashic_controller:
        return false
    
    # Simply recreate the visualization with updated stage
    create_entity_visualization(entity)
    
    return true

func update_entity_count_label():
    var entity_count_label = terminal_ui.find_node("EntityCountLabel", true, false)
    if entity_count_label:
        entity_count_label.text = "Entities: %d" % current_entities.size()

# ----- DIMENSION MANAGEMENT -----
func set_current_dimension(turn_number):
    var prev_turn = current_turn
    current_turn = turn_number
    
    # Update dimension info
    if turn_number > 0 and turn_number <= 12:
        var turn_symbols = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ"]
        var turn_dimensions = ["1D", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "11D", "12D"]
        var cosmic_ages = [
            "Genesis", "Formation", "Complexity", "Consciousness", 
            "Awakening", "Enlightenment", "Manifestation", "Connection", 
            "Harmony", "Transcendence", "Unity", "Beyond"
        ]
        
        current_symbol = turn_symbols[turn_number - 1]
        current_dimension = turn_dimensions[turn_number - 1]
        current_cosmic_age = cosmic_ages[turn_number - 1]
    
    # Update UI
    var dimension_label = terminal_ui.find_node("DimensionLabel", true, false)
    if dimension_label:
        dimension_label.text = "%s: %s (%s)" % [current_turn, current_symbol, current_dimension]
    
    var turn_label = terminal_ui.find_node("TurnLabel", true, false)
    if turn_label:
        turn_label.text = "Turn: %d" % current_turn
    
    # Update visualization
    if visualization_active and akashic_controller:
        akashic_controller.visualize_akashic_record(current_turn)
    
    # Set universal connector dimension access
    if universal_connector:
        universal_connector.set_dimension_access(current_turn)
    
    # Emit signal
    emit_signal("dimension_changed", current_turn, current_symbol, current_dimension)
    
    return current_turn

# ----- COMMAND PROCESSING -----
func process_command(command_text):
    if command_text.empty():
        return "Please enter a command"
    
    # Split command and arguments
    var parts = command_text.split(" ", false, 1)
    var cmd = parts[0].to_lower()
    var args = parts[1] if parts.size() > 1 else ""
    
    # Process command
    match cmd:
        "connect":
            return process_connect_command(args)
        
        "dimension", "turn":
            return process_dimension_command(args)
        
        "create":
            return process_create_command(args)
        
        "evolve":
            return process_evolve_command(args)
        
        "list":
            return process_list_command(args)
        
        "visualize":
            return process_visualize_command(args)
        
        "project":
            return process_project_command(args)
        
        "synergy":
            return process_synergy_command(args)
        
        "help":
            return get_help_text()
        
        _:
            # Try to forward to other systems
            if akashic_controller:
                var result = akashic_controller.process_command(cmd, args.split(" "))
                if result != "Unknown command: " + cmd:
                    return result
            
            if main_controller and main_controller.has_method("execute_command"):
                var result = main_controller.execute_command(command_text)
                if result and typeof(result) == TYPE_STRING and not result.begins_with("Unknown command"):
                    return result
            
            return "Unknown command: " + cmd

func process_connect_command(args):
    if args.empty():
        return "Usage: connect <folder_path> [connection_type]"
    
    var parts = args.split(" ", false, 1)
    var folder_path = parts[0]
    var connection_type = parts[1] if parts.size() > 1 else "standard"
    
    if connect_folder(folder_path, connection_type):
        return "Successfully connected folder: " + folder_path
    else:
        return "Failed to connect folder: " + folder_path

func process_dimension_command(args):
    if args.empty():
        return "Current dimension: %s: %s (%s)" % [current_turn, current_symbol, current_dimension]
    
    var parts = args.split(" ")
    var subcommand = parts[0]
    
    match subcommand:
        "goto", "set", "change":
            if parts.size() < 2 or not parts[1].is_valid_integer():
                return "Usage: dimension goto <1-12>"
            
            var turn = int(parts[1])
            if turn < 1 or turn > 12:
                return "Invalid dimension number. Must be between 1 and 12."
            
            set_current_dimension(turn)
            return "Dimension changed to %d: %s (%s)" % [current_turn, current_symbol, current_dimension]
        
        "next":
            var next_turn = (current_turn % 12) + 1
            set_current_dimension(next_turn)
            return "Advanced to dimension %d: %s (%s)" % [current_turn, current_symbol, current_dimension]
        
        "prev", "previous":
            var prev_turn = current_turn - 1
            if prev_turn < 1:
                prev_turn = 12
            
            set_current_dimension(prev_turn)
            return "Went back to dimension %d: %s (%s)" % [current_turn, current_symbol, current_dimension]
        
        "info":
            return "Dimension %d: %s (%s)\nCosmic Age: %s" % [
                current_turn, current_symbol, current_dimension, current_cosmic_age
            ]
        
        _:
            return "Unknown dimension subcommand: " + subcommand

func process_create_command(args):
    if args.empty():
        return "Usage: create <entity_type> <data>"
    
    var parts = args.split(" ", false, 1)
    if parts.size() < 2:
        return "Usage: create <entity_type> <data>"
    
    var entity_type = parts[0]
    var data_text = parts[1]
    
    if not entity_type in entity_types:
        return "Invalid entity type. Valid types: " + str(entity_types)
    
    # Create entity based on type
    var entity_data = {}
    
    match entity_type:
        "word":
            entity_data = {
                "text": data_text,
                "power": 50 + (current_turn * 5)
            }
        
        "note":
            entity_data = {
                "content": data_text
            }
        
        "akashic":
            entity_data = {
                "content": data_text,
                "tags": ["user_created", current_dimension.to_lower()]
            }
            
            # Create actual akashic entry
            if akashic_controller:
                var position = Vector3(
                    randf() * 10 - 5,
                    randf() * 5,
                    randf() * 10 - 5
                )
                
                akashic_controller.create_akashic_entry(
                    data_text,
                    position,
                    current_turn,
                    ["user_created", current_dimension.to_lower()]
                )
        
        "shape":
            # Parse dimensions from format like 3x3x3
            var dimensions = Vector3(1, 1, 1)
            var color = Color.white
            
            if data_text.find("x") >= 0:
                var dim_parts = data_text.split("x")
                
                if dim_parts.size() >= 3:
                    dimensions = Vector3(
                        int(dim_parts[0]),
                        int(dim_parts[1]),
                        int(dim_parts[2])
                    )
                elif dim_parts.size() == 2:
                    dimensions = Vector3(
                        int(dim_parts[0]),
                        int(dim_parts[1]),
                        1
                    )
            
            entity_data = {
                "dimensions": dimensions,
                "color": color
            }
        
        "terminal":
            entity_data = {
                "command": data_text
            }
        
        "node":
            entity_data = {
                "script_path": data_text
            }
    
    var entity_id = create_entity(entity_type, entity_data)
    
    if entity_id:
        return "Created %s entity: %s" % [entity_type, entity_id]
    else:
        return "Failed to create entity"

func process_evolve_command(args):
    if args.empty():
        return "Usage: evolve <entity_id or 'all'> [target_stage]"
    
    var parts = args.split(" ")
    var entity_id = parts[0]
    var target_stage = parts[1] if parts.size() > 1 else ""
    
    if entity_id == "all":
        var evolved_count = 0
        
        for id in current_entities:
            if evolve_entity(id, target_stage):
                evolved_count += 1
        
        return "Evolved %d entities" % evolved_count
    else:
        if not current_entities.has(entity_id):
            return "Entity not found: " + entity_id
        
        if evolve_entity(entity_id, target_stage):
            var entity = current_entities[entity_id]
            return "Evolved entity %s to stage: %s" % [entity_id, entity.stage]
        else:
            return "Entity did not evolve (insufficient evolution points)"

func process_list_command(args):
    if args.empty():
        return "Usage: list <entities|folders|dimensions|projects>"
    
    match args:
        "entities":
            var result = "Entities (%d):\n" % current_entities.size()
            
            for entity_id in current_entities:
                var entity = current_entities[entity_id]
                result += "- %s (%s): Stage %s\n" % [entity_id, entity.type, entity.stage]
            
            return result
        
        "folders":
            var result = "Connected Folders (%d):\n" % connected_folders.size()
            
            for folder_path in connected_folders:
                var folder_data = connected_folders[folder_path]
                result += "- %s: %d files (%d Godot scripts)\n" % [
                    folder_path, folder_data.file_count, folder_data.godot_files
                ]
            
            return result
        
        "dimensions":
            var result = "Available Dimensions:\n"
            
            for i in range(1, 13):
                var turn_symbols = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ"]
                var turn_dimensions = ["1D", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "11D", "12D"]
                var symbol = turn_symbols[i-1]
                var dimension = turn_dimensions[i-1]
                
                result += "%d: %s (%s)%s\n" % [
                    i, symbol, dimension,
                    " - Current" if i == current_turn else ""
                ]
            
            return result
        
        "projects":
            var result = "Available Projects:\n"
            
            var projects = ["12_turns_system", "Eden_OS", "LuminusOS"]
            for project in projects:
                result += "- %s%s\n" % [
                    project,
                    " - Current" if project == current_project else ""
                ]
            
            return result
        
        _:
            return "Unknown list type. Valid types: entities, folders, dimensions, projects"

func process_visualize_command(args):
    if args.empty():
        visualize_all_entities()
        return "Visualizing all entities"
    
    match args:
        "on", "true", "enable":
            toggle_visualization(true)
            return "3D visualization enabled"
        
        "off", "false", "disable":
            toggle_visualization(false)
            return "3D visualization disabled"
        
        "toggle":
            toggle_visualization(!visualization_active)
            return "3D visualization %s" % ("enabled" if visualization_active else "disabled")
        
        "entities":
            visualize_all_entities()
            return "Visualizing all entities"
        
        "dimension", "akashic":
            if akashic_controller:
                akashic_controller.visualize_akashic_record(current_turn)
                return "Visualizing current dimension (%d)" % current_turn
            return "Akashic controller not available"
        
        _:
            # Assume it's an entity ID
            if current_entities.has(args):
                update_entity_visualization(current_entities[args])
                return "Visualizing entity: " + args
            
            return "Unknown visualization option or entity ID: " + args

func process_project_command(args):
    if args.empty():
        return "Current project: " + current_project
    
    var old_project = current_project
    current_project = args
    
    # Change active folder
    var project_path = "/mnt/c/Users/Percision 15/" + current_project
    
    if Directory.new().dir_exists(project_path):
        # Connect to the project folder if not already connected
        if not connected_folders.has(project_path):
            connect_folder(project_path)
        
        # Emit signal
        emit_signal("project_changed", old_project, current_project)
        
        return "Switched to project: " + current_project
    else:
        current_project = old_project
        return "Project directory not found: " + project_path

func process_synergy_command(args):
    if args.empty() or args == "detect":
        if akashic_controller:
            # Force synergy detection
            akashic_controller._check_for_synergies()
            return "Checking for synergies..."
    
    match args:
        "connect":
            # Connect all entities to form synergies
            var connections_made = 0
            
            var entities = current_entities.values()
            for i in range(entities.size()):
                for j in range(i + 1, entities.size()):
                    if entities[i].stage == entities[j].stage:
                        entities[i].connections.append(entities[j].id)
                        entities[j].connections.append(entities[i].id)
                        connections_made += 1
            
            return "Created %d synergistic connections" % connections_made
        
        "evolve":
            # Evolve entities with many connections
            var evolved_count = 0
            
            for entity_id in current_entities:
                var entity = current_entities[entity_id]
                
                if entity.connections.size() >= 3:
                    var stage_index = evolution_stages.find(entity.stage)
                    
                    if stage_index < evolution_stages.size() - 1:
                        var new_stage = evolution_stages[stage_index + 1]
                        evolve_entity(entity_id, new_stage)
                        evolved_count += 1
            
            return "Evolved %d entities through synergy" % evolved_count
        
        _:
            return "Unknown synergy subcommand: " + args

func visualize_all_entities():
    if not visualization_active:
        toggle_visualization(true)
    
    for entity_id in current_entities:
        update_entity_visualization(current_entities[entity_id])

func get_help_text():
    return """
Available commands:

DIMENSION CONTROL:
  dimension goto <1-12> - Change to specific dimension
  dimension next - Advance to next dimension
  dimension prev - Go back to previous dimension
  dimension info - Show current dimension info

ENTITY MANAGEMENT:
  create <entity_type> <data> - Create new entity
    Types: word, note, akashic, shape, terminal, node
  evolve <entity_id> [stage] - Evolve entity to next stage
  evolve all - Evolve all entities

VISUALIZATION:
  visualize on/off - Toggle 3D visualization
  visualize entities - Visualize all entities
  visualize <entity_id> - Visualize specific entity
  visualize dimension - Visualize current dimension

PROJECT MANAGEMENT:
  project <name> - Switch active project
  connect <folder_path> - Connect a folder to the system
  
SYNERGY SYSTEM:
  synergy detect - Detect synergies in akashic records
  synergy connect - Create connections between entities
  synergy evolve - Evolve entities through synergistic connections

INFORMATION:
  list entities - List all entities
  list folders - List connected folders
  list dimensions - List available dimensions
  list projects - List available projects
  help - Show this help text
"""

# ----- EVENT HANDLERS -----
func _on_turn_advanced(turn_number, symbol, dimension):
    set_current_dimension(turn_number)

func _on_note_created(note_data):
    # Create entity from note
    create_entity("note", {
        "content": note_data.text,
        "power": note_data.power,
        "turn": note_data.turn
    })

func _on_word_manifested(word, position, power):
    # Create entity from manifested word
    create_entity("word", {
        "text": word,
        "power": power,
        "position": position
    })

func _on_reality_changed(reality_data):
    # Update based on reality change
    print("Reality changed: ", reality_data)

func _on_system_connected(system_id, system_type):
    print("Connected to %s system: %s" % [system_type, system_id])

func _on_dimension_accessed(dimension_id, access_level):
    print("Dimension accessed: %s (level %s)" % [dimension_id, access_level])

func _on_record_transferred(record_id, source_system, target_system):
    print("Record transferred: %s from %s to %s" % [record_id, source_system, target_system])

func _on_record_created(entry_id):
    # Create entity from akashic record
    if akashic_controller:
        var entry = akashic_controller.get_akashic_entry(entry_id)
        if entry:
            create_entity("akashic", {
                "content": entry.content,
                "tags": entry.tags,
                "position": entry.position.coordinate,
                "dimension": entry.position.dimension
            })

func _on_akashic_synergy_detected(synergies):
    print("Detected %d akashic synergies" % synergies.size())
    
    # Evolve entities based on synergies
    var evolved_count = 0
    
    for entity_id in current_entities:
        var entity = current_entities[entity_id]
        
        if entity.type == "akashic" and entity.stage != "transcendent":
            # Give a chance to evolve based on number of synergies
            var evolution_chance = min(0.2 + (synergies.size() * 0.05), 0.8)
            
            if randf() < evolution_chance:
                evolve_entity(entity_id)
                evolved_count += 1
    
    if evolved_count > 0:
        print("Evolved %d entities due to akashic synergies" % evolved_count)

func _on_dimension_power_calculated(dimension, power):
    print("Dimension %d power calculated: %f" % [dimension, power])
    
    # Chance to evolve entities in this dimension
    var evolved_count = 0
    
    for entity_id in current_entities:
        var entity = current_entities[entity_id]
        
        if entity.turn == dimension and entity.stage != "transcendent":
            var evolution_chance = min(0.1 + (power / 1000.0), 0.9)
            
            if randf() < evolution_chance:
                evolve_entity(entity_id)
                evolved_count += 1
    
    if evolved_count > 0:
        print("Evolved %d entities due to dimension power" % evolved_count)

func _on_folder_selected(index):
    var folder_list = terminal_ui.find_node("FolderList", true, false)
    if folder_list:
        var folder_path = folder_list.get_item_metadata(index)
        
        if folder_path and connected_folders.has(folder_path):
            var folder_data = connected_folders[folder_path]
            
            # Create entity for this folder
            create_entity("node", {
                "script_path": folder_path,
                "file_count": folder_data.file_count,
                "godot_files": folder_data.godot_files
            })
            
            # Show info in command line
            var command_line = terminal_ui.find_node("CommandLine", true, false)
            if command_line:
                command_line.text = "create note Connected to folder: " + folder_path

func _on_command_entered(text):
    var result = process_command(text)
    
    # Create terminal entity from command
    if text.strip_edges() != "":
        create_entity("terminal", {
            "command": text,
            "result": result
        })
    
    # Clear command line
    var command_line = terminal_ui.find_node("CommandLine", true, false)
    if command_line:
        command_line.text = ""
        
        # Show result temporarily
        command_line.placeholder_text = result
        
        # Reset placeholder after delay
        yield(get_tree().create_timer(3.0), "timeout")
        command_line.placeholder_text = "Enter command..."

func _on_visualization_button_pressed():
    toggle_visualization(!visualization_active)

func _on_evolution_button_pressed():
    var evolved_count = 0
    
    for entity_id in current_entities:
        if evolve_entity(entity_id):
            evolved_count += 1
    
    # Show result
    var command_line = terminal_ui.find_node("CommandLine", true, false)
    if command_line:
        command_line.placeholder_text = "Evolved %d entities" % evolved_count
        
        # Reset placeholder after delay
        yield(get_tree().create_timer(2.0), "timeout")
        command_line.placeholder_text = "Enter command..."

func _on_connect_folder_button_pressed():
    var command_line = terminal_ui.find_node("CommandLine", true, false)
    if command_line:
        command_line.text = "connect /mnt/c/Users/Percision 15/"
        command_line.grab_focus()