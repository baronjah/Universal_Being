extends Node

# System Integrator
# Initializes and connects all 3D visualization and storage components
# Serves as a bridge between main controller and akashic/notepad systems

# ----- NODE REFERENCES -----
onready var main_controller = $"/root/MainController" if has_node("/root/MainController") else null

# ----- COMPONENT REFERENCES -----
var spatial_storage: SpatialWorldStorage
var spatial_visualizer: Notepad3DVisualizer
var integration: SpatialNotepadIntegration
var akashic_controller: AkashicNotepadController
var word_manifestation_system = null
var divine_word_processor = null

# ----- STATE VARIABLES -----
var initialized = false
var startup_complete = false
var auto_visualize_entries = true
var initial_dimension = 3  # Default to 3D dimension

# ----- INITIALIZATION -----
func _ready():
    print("System Integrator initializing...")
    
    # Initialization is done in stages to ensure proper dependencies
    call_deferred("initialize_systems")

func initialize_systems():
    # Create storage system
    spatial_storage = SpatialWorldStorage.new()
    add_child(spatial_storage)
    
    # Create akashic controller
    akashic_controller = AkashicNotepadController.new()
    add_child(akashic_controller)
    
    # Setup connections to main controller if available
    if main_controller:
        # Connect controller signals
        main_controller.connect("turn_advanced", self, "_on_turn_advanced")
        main_controller.connect("note_created", self, "_on_note_created")
        main_controller.connect("word_manifested", self, "_on_word_manifested")
        
        # Tell akashic controller about main controller
        akashic_controller.set_main_controller(main_controller)
        
        # Get reference to word processor if available
        if main_controller.has_method("get_word_processor"):
            divine_word_processor = main_controller.get_word_processor()
        
        # Get initial dimension from main controller
        initial_dimension = main_controller.current_turn
    
    # Connect components
    connect_components()
    
    # Setup 3D visualization
    setup_visualization()
    
    # Complete initialization
    initialized = true
    print("System Integrator initialized")
    
    # Perform startup operations after a short delay to ensure all systems are ready
    var startup_timer = Timer.new()
    startup_timer.wait_time = 1.0
    startup_timer.one_shot = true
    startup_timer.connect("timeout", self, "complete_startup")
    add_child(startup_timer)
    startup_timer.start()

func complete_startup():
    # Perform any operations that should happen after all systems are initialized
    if auto_visualize_entries and akashic_controller:
        akashic_controller.visualize_akashic_record(initial_dimension)
    
    startup_complete = true
    print("Startup complete - systems operational")
    
    # Extend main controller's command system
    extend_command_system()

# ----- SETUP FUNCTIONS -----
func connect_components():
    # Find or create word manifestation system
    word_manifestation_system = get_node_or_null("/root/WordManifestationSystem")
    
    if not word_manifestation_system and has_node("/root/DivineWordProcessor"):
        # Create word manifestation system if it doesn't exist
        word_manifestation_system = load("res://word_manifestation_system.gd").new()
        add_child(word_manifestation_system)
        
        # Connect to word processor
        var word_processor = get_node("/root/DivineWordProcessor")
        if word_processor:
            word_manifestation_system.set_word_processor(word_processor)
    
    # Connect to akashic controller
    if word_manifestation_system and akashic_controller:
        akashic_controller.set_word_manifestation_system(word_manifestation_system)

func setup_visualization():
    # Create visualization scene if not already in tree
    if not has_node("VisualizationContainer"):
        var container = Spatial.new()
        container.name = "VisualizationContainer"
        add_child(container)
        
        # Create visualizer
        spatial_visualizer = Notepad3DVisualizer.new()
        spatial_visualizer.name = "Notepad3DVisualizer"
        container.add_child(spatial_visualizer)
        
        # Setup camera and environment
        _setup_visualization_camera(container)
    else:
        # Get existing visualizer
        spatial_visualizer = get_node("VisualizationContainer/Notepad3DVisualizer")
    
    # Connect visualizer to akashic controller
    if spatial_visualizer and akashic_controller:
        akashic_controller.set_visualizer(spatial_visualizer)
        
        # Connect additional signals
        akashic_controller.connect("record_created", self, "_on_record_created")
        akashic_controller.connect("notebook_created", self, "_on_notebook_created")
        akashic_controller.connect("akashic_synergy_detected", self, "_on_akashic_synergy_detected")
        
        print("3D visualization system setup complete")

func _setup_visualization_camera(container):
    # Create camera
    var camera = Camera.new()
    camera.name = "VisualizationCamera"
    camera.translation = Vector3(0, 5, 10)
    camera.rotation_degrees = Vector3(-30, 0, 0)
    camera.far = 1000
    camera.current = false  # Don't make current by default
    container.add_child(camera)
    
    # Create environment for visual effects
    var environment = Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.01, 0.01, 0.05)
    environment.ambient_light_color = Color(0.1, 0.1, 0.2)
    environment.fog_enabled = true
    environment.fog_color = Color(0.01, 0.01, 0.05)
    environment.fog_depth_begin = 20
    environment.fog_depth_end = 100
    environment.glow_enabled = true
    
    var world_environment = WorldEnvironment.new()
    world_environment.name = "VisualizationEnvironment"
    world_environment.environment = environment
    container.add_child(world_environment)
    
    # Create light
    var light = DirectionalLight.new()
    light.name = "MainLight"
    light.translation = Vector3(0, 10, 0)
    light.rotation_degrees = Vector3(-45, 0, 0)
    light.shadow_enabled = true
    container.add_child(light)

func extend_command_system():
    # Add command handling for akashic/notepad systems
    if main_controller and main_controller.has_method("register_command_handler"):
        main_controller.register_command_handler("akashic", self, "_process_command")
        main_controller.register_command_handler("notepad", self, "_process_command")
        main_controller.register_command_handler("notebook", self, "_process_command")
        main_controller.register_command_handler("visualize", self, "_process_command")
        main_controller.register_command_handler("3d", self, "_process_command")
        print("Extended command system for akashic/notepad functionality")

# ----- EVENT HANDLERS -----
func _on_turn_advanced(turn_number, symbol, dimension):
    if not initialized or not akashic_controller:
        return
    
    # Create entry for turn transition
    var position = Vector3(0, turn_number, 0)
    var content = "Advancing to dimension %d (%s - %s)" % [
        turn_number,
        symbol,
        dimension
    ]
    
    akashic_controller.create_akashic_entry(
        content, 
        position, 
        turn_number, 
        ["transition", "dimension", "turn"]
    )
    
    # Visualize akashic entries for new dimension if automatic visualization is enabled
    if auto_visualize_entries:
        akashic_controller.visualize_akashic_record(turn_number)

func _on_note_created(note_data):
    if not initialized or not akashic_controller:
        return
    
    # Automatic processing is handled by the akashic controller

func _on_word_manifested(word, position, power):
    if not initialized or not akashic_controller:
        return
    
    # Automatic processing is handled by the akashic controller

func _on_record_created(entry_id):
    print("Akashic record created: %s" % entry_id)
    
    # Additional processing can be done here if needed

func _on_notebook_created(notebook_name):
    print("Notebook created: %s" % notebook_name)
    
    # Additional processing can be done here if needed

func _on_akashic_synergy_detected(synergies):
    print("Detected %d akashic synergies" % synergies.size())
    
    # Create a visual effect or special notification here if desired

# ----- COMMAND PROCESSING -----
func _process_command(command, args):
    if not initialized or not akashic_controller:
        return "System not fully initialized"
    
    # Forward command to akashic controller
    return akashic_controller.process_command(command, args)

# ----- PUBLIC API -----
func get_akashic_controller():
    return akashic_controller

func get_spatial_visualizer():
    return spatial_visualizer

func get_spatial_storage():
    return spatial_storage

func toggle_visualization(active = true):
    if not spatial_visualizer:
        return false
    
    # Toggle visualization camera
    var camera = get_node_or_null("VisualizationContainer/VisualizationCamera")
    if camera:
        camera.current = active
    
    # Toggle auto visualization
    auto_visualize_entries = active
    
    return true

func create_akashic_entry(content, position, dimension = 0, tags = []):
    if not akashic_controller:
        return null
    
    return akashic_controller.create_akashic_entry(content, position, dimension, tags)

func visualize_dimension(dimension = 0):
    if not akashic_controller:
        return false
    
    return akashic_controller.visualize_akashic_record(dimension)

func create_notepad_from_dimension(dimension, notebook_name = ""):
    if not akashic_controller:
        return false
    
    return akashic_controller.create_notebook_from_akashic(dimension, notebook_name)

func save_all_data():
    if not akashic_controller:
        return false
    
    akashic_controller.save_all_data()
    return true