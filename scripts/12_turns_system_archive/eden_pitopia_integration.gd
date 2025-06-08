extends Node

# Eden Pitopia Integration
# Integrates Eden Harmony and Pitopia systems with the Akashic Notepad3D game
# Connects the word manifestation and dimensional systems across projects

class_name EdenPitopiaIntegration

# ----- COMPONENT REFERENCES -----
var akashic_controller = null
var system_integrator = null 
var universal_connector = null
var integrated_game_system = null
var harmony_connector = null
var pitopia_main = null

# ----- EDEN COMPONENTS -----
var word_manifestor = null
var ethereal_engine = null
var dimension_controller = null
var turn_system = null
var entity_manager = null
var color_system = null

# ----- CONFIGURATION -----
export var auto_initialize = true
export var default_dimension = 3
export var auto_sync_dimensions = true
export var record_words_to_akashic = true
export var enable_dimension_effects = true
export var enable_turn_system_integration = true
export var debug_mode = false

# ----- STATE VARIABLES -----
var initialized = false
var active_dimension = 3
var pitopia_dimension = 3
var harmony_dimension = 3
var manifested_words = {}
var entity_mappings = {}
var dimension_sync_active = true
var akashic_record_cache = {}
var turn_callbacks = {}
var dimensional_transition_active = false

# ----- SIGNALS -----
signal integration_initialized
signal word_manifested(word, entity_id, system_name)
signal entity_created(entity_id, entity_data, system_name)
signal dimension_synchronized(dimension_number, source_system)
signal turn_advanced(turn_number)
signal akashic_record_created(record_id, content, tags)

# ----- INITIALIZATION -----
func _ready():
    if auto_initialize:
        initialize()

func initialize():
    print("Initializing Eden Pitopia Integration...")
    
    # Find system integrator
    system_integrator = find_system_integrator()
    
    # Find akashic controller through system integrator
    if system_integrator and system_integrator.has_method("get_akashic_controller"):
        akashic_controller = system_integrator.get_akashic_controller()
    else:
        akashic_controller = find_node_by_class("AkashicNotepadController")
    
    # Find integrated game system
    integrated_game_system = find_node_by_class("IntegratedGameSystem")
    
    # Find universal connector
    universal_connector = find_node_by_class("UniversalAkashicConnector")
    
    # Connect to Harmony and Pitopia systems
    connect_to_eden_harmony()
    connect_to_pitopia()
    
    # Set initial dimension
    active_dimension = default_dimension
    
    # Connect signals
    connect_signals()
    
    # Mark as initialized
    initialized = true
    print("Eden Pitopia Integration initialized")
    emit_signal("integration_initialized")
    
    # Synchronize dimensions
    if auto_sync_dimensions:
        synchronize_dimensions(active_dimension)

# ----- COMPONENT DISCOVERY -----
func find_system_integrator():
    # First try to find it in the scene
    var integrator = find_node_by_class("SystemIntegrator")
    
    # If not found, try to find it globally
    if not integrator:
        if has_node("/root/SystemIntegrator"):
            integrator = get_node("/root/SystemIntegrator")
    
    return integrator

func find_node_by_class(class_name):
    # First check if it's a child of this node
    for child in get_children():
        if child.get_class() == class_name:
            return child
    
    # Try to find it in the scene tree
    var root = get_tree().get_root()
    
    for child in root.get_children():
        var found = find_node_recursive(child, class_name)
        if found:
            return found
    
    return null

func find_node_recursive(node, class_name):
    if node.get_class() == class_name:
        return node
    
    for child in node.get_children():
        var found = find_node_recursive(child, class_name)
        if found:
            return found
    
    return null

# ----- EDEN HARMONY CONNECTION -----
func connect_to_eden_harmony():
    # Try to find EdenHarmonyConnector
    harmony_connector = find_node_by_class("EdenHarmonyConnector")
    
    if not harmony_connector:
        # Try to load the script and create an instance
        var harmony_script = load_script_file("eden_harmony_connector.gd")
        if harmony_script:
            harmony_connector = Node.new()
            harmony_connector.set_script(harmony_script)
            harmony_connector.name = "EdenHarmonyConnector"
            add_child(harmony_connector)
            print("Created new Eden Harmony Connector instance")
    
    if harmony_connector:
        # Get references to Eden components
        word_manifestor = harmony_connector.get_word_manifestor()
        turn_system = harmony_connector.get_turn_system()
        ethereal_engine = harmony_connector.get_ethereal_engine()
        dimension_controller = harmony_connector.get_dimension_controller()
        entity_manager = harmony_connector.get_entity_manager()
        color_system = harmony_connector.get_color_system()
        
        print("Connected to Eden Harmony system")
        return true
    
    print("Failed to connect to Eden Harmony system")
    return false

# ----- PITOPIA CONNECTION -----
func connect_to_pitopia():
    # Try to find PitopiaMain
    pitopia_main = find_node_by_class("PitopiaMain")
    
    if not pitopia_main:
        # Try to load the script and create an instance
        var pitopia_script = load_script_file("pitopia_main.gd")
        if pitopia_script:
            pitopia_main = Node.new()
            pitopia_main.set_script(pitopia_script)
            pitopia_main.name = "PitopiaMain"
            add_child(pitopia_main)
            print("Created new Pitopia Main instance")
    
    if pitopia_main:
        # If we have a Pitopia main instance but no Eden components, get them from Pitopia
        if not word_manifestor and pitopia_main.has_method("get_word_manifestor"):
            word_manifestor = pitopia_main.get_word_manifestor()
        
        if not turn_system and pitopia_main.has_method("get_turn_system"):
            turn_system = pitopia_main.get_turn_system()
        
        if not ethereal_engine and pitopia_main.has_method("get_ethereal_engine"):
            ethereal_engine = pitopia_main.get_ethereal_engine()
        
        if not dimension_controller and pitopia_main.has_method("get_dimension_controller"):
            dimension_controller = pitopia_main.get_dimension_controller()
        
        if not color_system and pitopia_main.has_method("get_color_system"):
            color_system = pitopia_main.get_color_system()
        
        print("Connected to Pitopia system")
        return true
    
    print("Failed to connect to Pitopia system")
    return false

func load_script_file(script_name):
    # Check in several locations for the script
    var potential_paths = [
        "/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/" + script_name,
        "/mnt/c/Users/Percision 15/Godot_Eden/Eden_May/the_palace_pf/code/gdscript/scripts/" + script_name,
        "/mnt/c/Users/Percision 15/12_turns_system/" + script_name,
        "/mnt/c/Users/Percision 15/Eden_OS/scripts/" + script_name,
        "res://" + script_name,
        "res://scripts/" + script_name,
        "res://addons/" + script_name
    ]
    
    for path in potential_paths:
        if File.new().file_exists(path):
            if debug_mode:
                print("Found script at: " + path)
            return load(path)
    
    # If not found, try to search for it
    for base_dir in ["/mnt/c/Users/Percision 15/12_turns_system", "/mnt/c/Users/Percision 15/Godot_Eden/Eden_May", "/mnt/c/Users/Percision 15/Eden_OS"]:
        var script_path = search_for_script(base_dir, script_name)
        if script_path:
            if debug_mode:
                print("Found script by searching at: " + script_path)
            return load(script_path)
    
    if debug_mode:
        print("Failed to find script: " + script_name)
    return null

func search_for_script(base_dir, script_name):
    var dir = Directory.new()
    
    if not dir.dir_exists(base_dir):
        return null
    
    if dir.open(base_dir) == OK:
        dir.list_dir_begin(true, true)
        
        var file_name = dir.get_next()
        while file_name != "":
            var full_path = base_dir + "/" + file_name
            
            if dir.current_is_dir():
                # Recursively search subdirectories
                var found_in_subdir = search_for_script(full_path, script_name)
                if found_in_subdir:
                    return found_in_subdir
            else:
                # Check if this is the script we're looking for
                if file_name == script_name:
                    return full_path
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    return null

# ----- SIGNAL CONNECTIONS -----
func connect_signals():
    # Connect signals from Eden Harmony
    if harmony_connector:
        if harmony_connector.has_signal("word_manifested"):
            harmony_connector.connect("word_manifested", self, "_on_harmony_word_manifested")
        
        if harmony_connector.has_signal("dimension_changed"):
            harmony_connector.connect("dimension_changed", self, "_on_harmony_dimension_changed")
        
        if harmony_connector.has_signal("turn_advanced"):
            harmony_connector.connect("turn_advanced", self, "_on_harmony_turn_advanced")
        
        if harmony_connector.has_signal("entity_created"):
            harmony_connector.connect("entity_created", self, "_on_harmony_entity_created")
    
    # Connect signals from Pitopia
    if pitopia_main:
        if pitopia_main.has_signal("word_manifested"):
            pitopia_main.connect("word_manifested", self, "_on_pitopia_word_manifested")
        
        if pitopia_main.has_signal("dimension_changed"):
            pitopia_main.connect("dimension_changed", self, "_on_pitopia_dimension_changed")
        
        if pitopia_main.has_signal("turn_advanced"):
            pitopia_main.connect("turn_advanced", self, "_on_pitopia_turn_advanced")
    
    # Connect signals from integrated game system
    if integrated_game_system:
        if integrated_game_system.has_signal("dimension_changed"):
            integrated_game_system.connect("dimension_changed", self, "_on_integrated_dimension_changed")
        
        if integrated_game_system.has_signal("entity_created"):
            integrated_game_system.connect("entity_created", self, "_on_integrated_entity_created")
    
    # Connect signals from akashic controller
    if akashic_controller:
        if akashic_controller.has_signal("record_created"):
            akashic_controller.connect("record_created", self, "_on_akashic_record_created")

# ----- DIMENSION MANAGEMENT -----
func synchronize_dimensions(dimension_number):
    if not dimension_sync_active or dimensional_transition_active:
        return false
    
    dimensional_transition_active = true
    active_dimension = dimension_number
    
    # Update Eden Harmony dimension
    if harmony_connector and harmony_connector.has_method("set_dimension"):
        harmony_connector.set_dimension(dimension_number)
        harmony_dimension = dimension_number
    elif dimension_controller and dimension_controller.has_method("change_dimension"):
        dimension_controller.change_dimension(dimension_number)
        harmony_dimension = dimension_number
    
    # Update Pitopia dimension
    if pitopia_main and pitopia_main.has_method("set_dimension"):
        pitopia_main.set_dimension(dimension_number)
        pitopia_dimension = dimension_number
    
    # Update integrated game system
    if integrated_game_system and integrated_game_system.has_method("set_current_dimension"):
        integrated_game_system.set_current_dimension(dimension_number)
    
    # Update akashic controller
    if akashic_controller and akashic_controller.has_method("visualize_akashic_record"):
        akashic_controller.visualize_akashic_record(dimension_number)
    
    # Apply dimensional effects
    if enable_dimension_effects:
        apply_dimensional_effects(dimension_number)
    
    # Emit signal
    emit_signal("dimension_synchronized", dimension_number, "integration")
    
    dimensional_transition_active = false
    return true

func apply_dimensional_effects(dimension_number):
    # Apply different visual effects based on dimension
    var dimension_props = get_dimension_properties(dimension_number)
    
    # Apply color effects
    if color_system and color_system.has_method("set_dimension_color"):
        color_system.set_dimension_color(dimension_number)
    
    # Update environment if needed
    var environment = null
    
    if pitopia_main and pitopia_main.has_method("get_environment"):
        environment = pitopia_main.get_environment()
    elif has_node("/root/WorldEnvironment"):
        environment = get_node("/root/WorldEnvironment").environment
    
    if environment:
        # Update fog color
        if dimension_props.has("fog_color"):
            environment.fog_color = dimension_props.fog_color
        
        # Update fog density
        if dimension_props.has("fog_density"):
            environment.fog_depth_begin = dimension_props.fog_density.begin
            environment.fog_depth_end = dimension_props.fog_density.end
        
        # Update ambient light
        if dimension_props.has("ambient_color"):
            environment.ambient_light_color = dimension_props.ambient_color
            environment.ambient_light_energy = dimension_props.ambient_energy
        
        # Update background color
        if dimension_props.has("background_color"):
            environment.background_color = dimension_props.background_color
    
    # Activate dimension-specific effects if entity manager exists
    if entity_manager and entity_manager.has_method("apply_dimension_effect"):
        entity_manager.apply_dimension_effect(dimension_number)

func get_dimension_properties(dimension_number):
    var dimension_data = {
        "name": "",
        "symbol": "",
        "fog_color": Color(0.05, 0.05, 0.1),
        "fog_density": {"begin": 20.0, "end": 100.0},
        "ambient_color": Color(0.1, 0.1, 0.2),
        "ambient_energy": 0.3,
        "background_color": Color(0.01, 0.01, 0.05)
    }
    
    # Set dimension-specific properties
    match dimension_number:
        1: # Linear Expression (1D)
            dimension_data.name = "Linear Expression"
            dimension_data.symbol = "α"
            dimension_data.fog_color = Color(0.1, 0.05, 0.05)
            dimension_data.fog_density = {"begin": 10.0, "end": 30.0}
            dimension_data.ambient_color = Color(0.2, 0.1, 0.1)
            dimension_data.ambient_energy = 0.2
            dimension_data.background_color = Color(0.05, 0.01, 0.01)
            
        2: # Planar Reflection (2D)
            dimension_data.name = "Planar Reflection"
            dimension_data.symbol = "β"
            dimension_data.fog_color = Color(0.1, 0.1, 0.05)
            dimension_data.fog_density = {"begin": 15.0, "end": 40.0}
            dimension_data.ambient_color = Color(0.2, 0.2, 0.1)
            dimension_data.ambient_energy = 0.25
            dimension_data.background_color = Color(0.05, 0.05, 0.01)
            
        3: # Spatial Manifestation (3D)
            dimension_data.name = "Spatial Manifestation"
            dimension_data.symbol = "γ"
            dimension_data.fog_color = Color(0.05, 0.1, 0.05)
            dimension_data.fog_density = {"begin": 20.0, "end": 60.0}
            dimension_data.ambient_color = Color(0.1, 0.2, 0.1)
            dimension_data.ambient_energy = 0.3
            dimension_data.background_color = Color(0.01, 0.05, 0.01)
            
        4: # Temporal Flow (4D)
            dimension_data.name = "Temporal Flow"
            dimension_data.symbol = "δ"
            dimension_data.fog_color = Color(0.05, 0.05, 0.1)
            dimension_data.fog_density = {"begin": 25.0, "end": 70.0}
            dimension_data.ambient_color = Color(0.1, 0.1, 0.2)
            dimension_data.ambient_energy = 0.35
            dimension_data.background_color = Color(0.01, 0.01, 0.05)
            
        5: # Probability Waves (5D)
            dimension_data.name = "Probability Waves"
            dimension_data.symbol = "ε"
            dimension_data.fog_color = Color(0.1, 0.05, 0.1)
            dimension_data.fog_density = {"begin": 30.0, "end": 80.0}
            dimension_data.ambient_color = Color(0.2, 0.1, 0.2)
            dimension_data.ambient_energy = 0.4
            dimension_data.background_color = Color(0.05, 0.01, 0.05)
            
        6: # Phase Resonance (6D)
            dimension_data.name = "Phase Resonance"
            dimension_data.symbol = "ζ"
            dimension_data.fog_color = Color(0.05, 0.1, 0.1)
            dimension_data.fog_density = {"begin": 30.0, "end": 100.0}
            dimension_data.ambient_color = Color(0.1, 0.2, 0.2)
            dimension_data.ambient_energy = 0.45
            dimension_data.background_color = Color(0.01, 0.05, 0.05)
            
        7: # Dream Weaving (7D)
            dimension_data.name = "Dream Weaving"
            dimension_data.symbol = "η"
            dimension_data.fog_color = Color(0.1, 0.05, 0.15)
            dimension_data.fog_density = {"begin": 40.0, "end": 120.0}
            dimension_data.ambient_color = Color(0.2, 0.1, 0.3)
            dimension_data.ambient_energy = 0.5
            dimension_data.background_color = Color(0.05, 0.01, 0.1)
            
        8: # Interconnection (8D)
            dimension_data.name = "Interconnection"
            dimension_data.symbol = "θ"
            dimension_data.fog_color = Color(0.05, 0.15, 0.1)
            dimension_data.fog_density = {"begin": 50.0, "end": 150.0}
            dimension_data.ambient_color = Color(0.1, 0.3, 0.2)
            dimension_data.ambient_energy = 0.55
            dimension_data.background_color = Color(0.01, 0.1, 0.05)
            
        9: # Divine Judgment (9D)
            dimension_data.name = "Divine Judgment"
            dimension_data.symbol = "ι"
            dimension_data.fog_color = Color(0.15, 0.15, 0.05)
            dimension_data.fog_density = {"begin": 70.0, "end": 200.0}
            dimension_data.ambient_color = Color(0.3, 0.3, 0.1)
            dimension_data.ambient_energy = 0.6
            dimension_data.background_color = Color(0.1, 0.1, 0.01)
            
        10: # Harmonic Convergence (10D)
            dimension_data.name = "Harmonic Convergence"
            dimension_data.symbol = "κ"
            dimension_data.fog_color = Color(0.15, 0.05, 0.15)
            dimension_data.fog_density = {"begin": 100.0, "end": 300.0}
            dimension_data.ambient_color = Color(0.3, 0.1, 0.3)
            dimension_data.ambient_energy = 0.7
            dimension_data.background_color = Color(0.1, 0.01, 0.1)
            
        11: # Conscious Reflection (11D)
            dimension_data.name = "Conscious Reflection"
            dimension_data.symbol = "λ"
            dimension_data.fog_color = Color(0.05, 0.15, 0.15)
            dimension_data.fog_density = {"begin": 150.0, "end": 400.0}
            dimension_data.ambient_color = Color(0.1, 0.3, 0.3)
            dimension_data.ambient_energy = 0.8
            dimension_data.background_color = Color(0.01, 0.1, 0.1)
            
        12: # Divine Manifestation (12D)
            dimension_data.name = "Divine Manifestation"
            dimension_data.symbol = "μ"
            dimension_data.fog_color = Color(0.15, 0.15, 0.15)
            dimension_data.fog_density = {"begin": 200.0, "end": 500.0}
            dimension_data.ambient_color = Color(0.3, 0.3, 0.3)
            dimension_data.ambient_energy = 1.0
            dimension_data.background_color = Color(0.1, 0.1, 0.1)
    
    return dimension_data

# ----- WORD MANIFESTATION -----
func manifest_word(word, system_name = "integration", dimension = 0):
    if word.empty():
        return null
    
    if dimension == 0:
        dimension = active_dimension
    
    var entity_id = null
    
    # Track the word
    if not manifested_words.has(word):
        manifested_words[word] = {
            "entity_ids": {},
            "power": 50,
            "dimension": dimension,
            "timestamp": OS.get_unix_time()
        }
    
    # Try to manifest using the appropriate system
    match system_name:
        "harmony":
            if harmony_connector and harmony_connector.has_method("manifest_word"):
                entity_id = harmony_connector.manifest_word(word)
            elif word_manifestor and word_manifestor.has_method("manifest_word"):
                entity_id = word_manifestor.manifest_word(word)
                
        "pitopia":
            if pitopia_main and pitopia_main.has_method("manifest_word"):
                entity_id = pitopia_main.manifest_word(word)
                
        "integrated":
            if integrated_game_system and integrated_game_system.has_method("create_entity"):
                entity_id = integrated_game_system.create_entity("word", {
                    "text": word,
                    "power": manifested_words[word].power,
                    "dimension": dimension
                })
                
        "akashic":
            if akashic_controller and akashic_controller.has_method("create_akashic_entry"):
                var position = Vector3(
                    randf() * 10 - 5,
                    randf() * 5,
                    randf() * 10 - 5
                )
                
                entity_id = akashic_controller.create_akashic_entry(
                    word,
                    position,
                    dimension,
                    ["word", "manifested"]
                )
                
        _: # Use best available system
            # Try integrated system first
            if integrated_game_system and integrated_game_system.has_method("create_entity"):
                entity_id = integrated_game_system.create_entity("word", {
                    "text": word,
                    "power": manifested_words[word].power,
                    "dimension": dimension
                })
            # Then try Eden Harmony
            elif harmony_connector and harmony_connector.has_method("manifest_word"):
                entity_id = harmony_connector.manifest_word(word)
            # Then try Pitopia
            elif pitopia_main and pitopia_main.has_method("manifest_word"):
                entity_id = pitopia_main.manifest_word(word)
            # Fallback to akashic records
            elif akashic_controller and akashic_controller.has_method("create_akashic_entry"):
                var position = Vector3(
                    randf() * 10 - 5,
                    randf() * 5,
                    randf() * 10 - 5
                )
                
                entity_id = akashic_controller.create_akashic_entry(
                    word,
                    position,
                    dimension,
                    ["word", "manifested"]
                )
    
    # Record the entity ID if successful
    if entity_id:
        manifested_words[word].entity_ids[system_name] = entity_id
        
        # Record in entity mappings for cross-system reference
        entity_mappings[entity_id] = {
            "word": word,
            "system": system_name,
            "dimension": dimension,
            "created_at": OS.get_unix_time()
        }
        
        # Create akashic record if enabled
        if record_words_to_akashic and akashic_controller and system_name != "akashic":
            var position = Vector3(
                randf() * 10 - 5,
                randf() * 5,
                randf() * 10 - 5
            )
            
            var akashic_id = akashic_controller.create_akashic_entry(
                word,
                position,
                dimension,
                ["word", "manifested", system_name]
            )
            
            # Record this mapping
            if akashic_id:
                entity_mappings[akashic_id] = {
                    "word": word,
                    "system": "akashic",
                    "original_system": system_name,
                    "original_id": entity_id,
                    "dimension": dimension,
                    "created_at": OS.get_unix_time()
                }
        
        # Emit signal
        emit_signal("word_manifested", word, entity_id, system_name)
    
    return entity_id

func connect_entities(entity1_id, entity2_id, connection_type = "default"):
    # Verify both entities exist
    if not entity_mappings.has(entity1_id) or not entity_mappings.has(entity2_id):
        return false
    
    var entity1 = entity_mappings[entity1_id]
    var entity2 = entity_mappings[entity2_id]
    
    # Try to connect in the appropriate systems
    var connected = false
    
    # Try connecting in Eden Harmony if both entities are from there
    if entity1.system == "harmony" and entity2.system == "harmony":
        if harmony_connector and harmony_connector.has_method("connect_entities"):
            connected = harmony_connector.connect_entities(entity1_id, entity2_id, connection_type)
    
    # Try connecting in Pitopia if both entities are from there
    elif entity1.system == "pitopia" and entity2.system == "pitopia":
        if pitopia_main and pitopia_main.has_method("connect_entities"):
            connected = pitopia_main.connect_entities(entity1_id, entity2_id, connection_type)
    
    # Try connecting in integrated system
    elif entity1.system == "integrated" and entity2.system == "integrated":
        if integrated_game_system and integrated_game_system.has_method("connect_entities"):
            connected = integrated_game_system.connect_entities(entity1_id, entity2_id, connection_type)
    
    # Try connecting in akashic system
    elif entity1.system == "akashic" and entity2.system == "akashic":
        if akashic_controller and akashic_controller.has_method("connect_akashic_entries"):
            connected = akashic_controller.connect_akashic_entries(entity1_id, entity2_id)
    
    # Cross-system connection - create a record of the connection in akashic records
    else:
        if akashic_controller and akashic_controller.has_method("create_akashic_entry"):
            var word1 = entity1.word
            var word2 = entity2.word
            var dimension = max(entity1.dimension, entity2.dimension)
            
            var position = Vector3(
                randf() * 10 - 5,
                randf() * 5,
                randf() * 10 - 5
            )
            
            var connection_text = "Connection between '%s' and '%s' (%s)" % [word1, word2, connection_type]
            
            var akashic_id = akashic_controller.create_akashic_entry(
                connection_text,
                position,
                dimension,
                ["connection", entity1.system, entity2.system]
            )
            
            if akashic_id:
                connected = true
                
                # Connect the entities in their original systems if possible
                var original_entity1 = entity1.get("original_id", entity1_id)
                var original_entity2 = entity2.get("original_id", entity2_id)
                
                var original_system1 = entity1.get("original_system", entity1.system)
                var original_system2 = entity2.get("original_system", entity2.system)
                
                # Create connection in universal connector if available
                if universal_connector and universal_connector.has_method("connect_systems"):
                    if original_system1 != original_system2:
                        universal_connector.connect_systems(original_system1, original_system2, "entity_connection")
    
    return connected

func evolve_entity(entity_id):
    # Verify entity exists
    if not entity_mappings.has(entity_id):
        return false
    
    var entity = entity_mappings[entity_id]
    var evolved = false
    
    # Try to evolve in the appropriate system
    match entity.system:
        "harmony":
            if harmony_connector and harmony_connector.has_method("evolve_entity"):
                evolved = harmony_connector.evolve_entity(entity_id)
            elif entity_manager and entity_manager.has_method("evolve_entity"):
                evolved = entity_manager.evolve_entity(entity_id)
                
        "pitopia":
            if pitopia_main and pitopia_main.has_method("evolve_entity"):
                evolved = pitopia_main.evolve_entity(entity_id)
                
        "integrated":
            if integrated_game_system and integrated_game_system.has_method("evolve_entity"):
                evolved = integrated_game_system.evolve_entity(entity_id)
                
        "akashic":
            # Can't directly evolve akashic entities, but can create a new evolved version
            if akashic_controller and akashic_controller.has_method("create_akashic_entry"):
                var position = Vector3(
                    randf() * 10 - 5,
                    randf() * 5 + 2,  # Slightly higher to represent evolution
                    randf() * 10 - 5
                )
                
                var word = entity.word
                var dimension = entity.dimension
                
                var evolved_id = akashic_controller.create_akashic_entry(
                    "Evolved: " + word,
                    position,
                    dimension,
                    ["evolved", "word", "manifested"]
                )
                
                if evolved_id:
                    evolved = true
                    
                    # Connect the original and evolved entities
                    if akashic_controller.has_method("connect_akashic_entries"):
                        akashic_controller.connect_akashic_entries(entity_id, evolved_id)
    
    return evolved

# ----- TURN SYSTEM INTEGRATION -----
func advance_turn():
    # Try to advance turn in the appropriate systems
    var advanced = false
    
    // Try integrated system first
    if integrated_game_system and integrated_game_system.has_method("set_current_dimension"):
        var next_turn = (active_dimension % 12) + 1
        advanced = integrated_game_system.set_current_dimension(next_turn)
        active_dimension = next_turn
    
    // Try Eden Harmony
    elif harmony_connector and harmony_connector.has_method("advance_turn"):
        advanced = harmony_connector.advance_turn()
        if harmony_connector.has_method("get_current_turn"):
            harmony_dimension = harmony_connector.get_current_turn()
            active_dimension = harmony_dimension
    
    // Try turn system directly
    elif turn_system and turn_system.has_method("advance_turn"):
        advanced = turn_system.advance_turn()
        if turn_system.has_method("get_current_turn"):
            active_dimension = turn_system.get_current_turn()
    
    // Try Pitopia
    elif pitopia_main and pitopia_main.has_method("advance_turn"):
        advanced = pitopia_main.advance_turn()
        if pitopia_main.has_method("get_current_turn"):
            pitopia_dimension = pitopia_main.get_current_turn()
            active_dimension = pitopia_dimension
    
    // Synchronize dimensions
    if advanced and auto_sync_dimensions:
        synchronize_dimensions(active_dimension)
    
    // Emit signal
    emit_signal("turn_advanced", active_dimension)
    
    return advanced

func register_turn_callback(turn_number, callback_object, callback_method, callback_args = []):
    if not turn_callbacks.has(turn_number):
        turn_callbacks[turn_number] = []
    
    turn_callbacks[turn_number].append({
        "object": callback_object,
        "method": callback_method,
        "args": callback_args
    })
    
    return true

func process_turn_callbacks(turn_number):
    if not turn_callbacks.has(turn_number):
        return false
    
    var callbacks = turn_callbacks[turn_number]
    var processed_count = 0
    
    for callback in callbacks:
        var object = callback.object
        var method = callback.method
        var args = callback.args
        
        if is_instance_valid(object) and object.has_method(method):
            object.callv(method, args)
            processed_count += 1
    
    return processed_count > 0

# ----- EVENT HANDLERS -----
func _on_harmony_word_manifested(word, entity_id):
    if debug_mode:
        print("Eden Harmony word manifested: %s (Entity ID: %s)" % [word, entity_id])
    
    # Record the mapping
    entity_mappings[entity_id] = {
        "word": word,
        "system": "harmony",
        "dimension": harmony_dimension,
        "created_at": OS.get_unix_time()
    }
    
    # Create akashic record if enabled
    if record_words_to_akashic and akashic_controller:
        manifest_word(word, "akashic", harmony_dimension)
    
    # Emit signal
    emit_signal("word_manifested", word, entity_id, "harmony")

func _on_harmony_dimension_changed(new_dimension, old_dimension):
    if debug_mode:
        print("Eden Harmony dimension changed: %d -> %d" % [old_dimension, new_dimension])
    
    harmony_dimension = new_dimension
    
    # Synchronize dimensions if enabled
    if auto_sync_dimensions and not dimensional_transition_active:
        synchronize_dimensions(new_dimension)

func _on_harmony_turn_advanced(turn_number):
    if debug_mode:
        print("Eden Harmony turn advanced: %d" % turn_number)
    
    # Process turn callbacks
    process_turn_callbacks(turn_number)
    
    # Emit signal
    emit_signal("turn_advanced", turn_number)

func _on_harmony_entity_created(entity_id, entity_data):
    if debug_mode:
        print("Eden Harmony entity created: %s" % entity_id)
    
    # Record the mapping
    entity_mappings[entity_id] = {
        "word": entity_data.get("word", "unknown"),
        "system": "harmony",
        "dimension": harmony_dimension,
        "data": entity_data,
        "created_at": OS.get_unix_time()
    }
    
    # Emit signal
    emit_signal("entity_created", entity_id, entity_data, "harmony")

func _on_pitopia_word_manifested(word, entity_id):
    if debug_mode:
        print("Pitopia word manifested: %s (Entity ID: %s)" % [word, entity_id])
    
    # Record the mapping
    entity_mappings[entity_id] = {
        "word": word,
        "system": "pitopia",
        "dimension": pitopia_dimension,
        "created_at": OS.get_unix_time()
    }
    
    # Create akashic record if enabled
    if record_words_to_akashic and akashic_controller:
        manifest_word(word, "akashic", pitopia_dimension)
    
    # Emit signal
    emit_signal("word_manifested", word, entity_id, "pitopia")

func _on_pitopia_dimension_changed(new_dimension, old_dimension):
    if debug_mode:
        print("Pitopia dimension changed: %d -> %d" % [old_dimension, new_dimension])
    
    pitopia_dimension = new_dimension
    
    # Synchronize dimensions if enabled
    if auto_sync_dimensions and not dimensional_transition_active:
        synchronize_dimensions(new_dimension)

func _on_pitopia_turn_advanced(turn_number):
    if debug_mode:
        print("Pitopia turn advanced: %d" % turn_number)
    
    # Process turn callbacks
    process_turn_callbacks(turn_number)
    
    # Emit signal
    emit_signal("turn_advanced", turn_number)

func _on_integrated_dimension_changed(turn_number, symbol, dimension_name):
    if debug_mode:
        print("Integrated system dimension changed: %d (%s - %s)" % [turn_number, symbol, dimension_name])
    
    # Synchronize dimensions if enabled
    if auto_sync_dimensions and not dimensional_transition_active:
        synchronize_dimensions(turn_number)

func _on_integrated_entity_created(entity_id, entity_type, entity_data):
    if debug_mode:
        print("Integrated system entity created: %s (Type: %s)" % [entity_id, entity_type])
    
    # Record the mapping
    entity_mappings[entity_id] = {
        "word": entity_data.get("text", entity_type),
        "system": "integrated",
        "type": entity_type,
        "dimension": active_dimension,
        "data": entity_data,
        "created_at": OS.get_unix_time()
    }
    
    # Create akashic record if enabled and entity type is word
    if record_words_to_akashic and akashic_controller and entity_type == "word":
        var word = entity_data.get("text", "")
        if not word.empty():
            manifest_word(word, "akashic", active_dimension)
    
    # Emit signal
    emit_signal("entity_created", entity_id, entity_data, "integrated")

func _on_akashic_record_created(record_id):
    if debug_mode:
        print("Akashic record created: %s" % record_id)
    
    # Get the record
    if akashic_controller and akashic_controller.has_method("get_akashic_entry"):
        var record = akashic_controller.get_akashic_entry(record_id)
        
        if record:
            # Add to cache
            akashic_record_cache[record_id] = {
                "content": record.content,
                "position": record.position.coordinate,
                "dimension": record.position.dimension,
                "power": record.position.power,
                "tags": record.tags,
                "created_at": OS.get_unix_time()
            }
            
            # Emit signal
            emit_signal("akashic_record_created", record_id, record.content, record.tags)

# ----- PUBLIC API -----
func get_manifested_words():
    return manifested_words

func get_entity_mappings():
    return entity_mappings

func get_akashic_record_cache():
    return akashic_record_cache

func get_current_dimension():
    return active_dimension

func get_turn_callbacks():
    return turn_callbacks

func toggle_dimension_sync(active = true):
    dimension_sync_active = active
    return dimension_sync_active

func get_dimension_symbols():
    return ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ"]

func get_dimension_names():
    return [
        "Linear Expression",
        "Planar Reflection",
        "Spatial Manifestation",
        "Temporal Flow",
        "Probability Waves",
        "Phase Resonance",
        "Dream Weaving",
        "Interconnection",
        "Divine Judgment",
        "Harmonic Convergence",
        "Conscious Reflection",
        "Divine Manifestation"
    ]

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
        "manifest":
            return process_manifest_command(args)
        
        "dimension":
            return process_dimension_command(args)
        
        "connect":
            return process_connect_command(args)
        
        "evolve":
            return process_evolve_command(args)
        
        "turn":
            return process_turn_command(args)
        
        "sync":
            return process_sync_command(args)
        
        "help":
            return get_help_text()
        
        _:
            # Try to manifest the word directly
            if enable_direct_word_manifestation:
                var entity_id = manifest_word(command_text)
                if entity_id:
                    return "Manifested word: %s (Entity ID: %s)" % [command_text, entity_id]
            
            return "Unknown command: " + cmd

func process_manifest_command(args):
    if args.empty():
        return "Usage: manifest <word> [system]"
    
    var parts = args.split(" ")
    var word = parts[0]
    var system = parts[1] if parts.size() > 1 else "integration"
    
    var entity_id = manifest_word(word, system)
    
    if entity_id:
        return "Manifested word '%s' in %s system (Entity ID: %s)" % [word, system, entity_id]
    else:
        return "Failed to manifest word: " + word

func process_dimension_command(args):
    if args.empty():
        return "Current dimension: %d (%s - %s)" % [
            active_dimension,
            get_dimension_symbols()[active_dimension - 1],
            get_dimension_names()[active_dimension - 1]
        ]
    
    if args.is_valid_integer():
        var dimension = int(args)
        if dimension < 1 or dimension > 12:
            return "Invalid dimension. Must be between 1 and 12."
        
        if synchronize_dimensions(dimension):
            return "Changed to dimension %d (%s - %s)" % [
                dimension,
                get_dimension_symbols()[dimension - 1],
                get_dimension_names()[dimension - 1]
            ]
        else:
            return "Failed to change dimension"
    
    return "Usage: dimension [1-12]"

func process_connect_command(args):
    if args.empty():
        return "Usage: connect <entity1_id> <entity2_id> [connection_type]"
    
    var parts = args.split(" ")
    
    if parts.size() < 2:
        return "Usage: connect <entity1_id> <entity2_id> [connection_type]"
    
    var entity1_id = parts[0]
    var entity2_id = parts[1]
    var connection_type = parts[2] if parts.size() > 2 else "default"
    
    if connect_entities(entity1_id, entity2_id, connection_type):
        return "Connected entities: %s and %s (%s)" % [entity1_id, entity2_id, connection_type]
    else:
        return "Failed to connect entities"

func process_evolve_command(args):
    if args.empty():
        return "Usage: evolve <entity_id>"
    
    var entity_id = args
    
    if evolve_entity(entity_id):
        return "Evolved entity: " + entity_id
    else:
        return "Failed to evolve entity: " + entity_id

func process_turn_command(args):
    if args == "advance" or args.empty():
        if advance_turn():
            return "Advanced to turn %d: %s (%s)" % [
                active_dimension,
                get_dimension_symbols()[active_dimension - 1],
                get_dimension_names()[active_dimension - 1]
            ]
        else:
            return "Failed to advance turn"
    
    return "Usage: turn [advance]"

func process_sync_command(args):
    if args.empty():
        return "Dimension sync is currently: " + ("ON" if dimension_sync_active else "OFF")
    
    match args:
        "on":
            dimension_sync_active = true
            return "Dimension synchronization enabled"
        "off":
            dimension_sync_active = false
            return "Dimension synchronization disabled"
        "force":
            synchronize_dimensions(active_dimension)
            return "Forced dimension synchronization to: " + str(active_dimension)
        _:
            return "Usage: sync [on|off|force]"

func get_help_text():
    return """
Available Commands:

WORD MANIFESTATION:
  manifest <word> [system] - Manifest a word into an entity
  evolve <entity_id> - Evolve an entity to next stage
  connect <entity1_id> <entity2_id> [type] - Connect two entities

DIMENSION CONTROL:
  dimension [1-12] - View or change dimension
  
TURN SYSTEM:
  turn [advance] - View or advance turn
  
SYNCHRONIZATION:
  sync [on|off|force] - Control dimension synchronization
  
HELP:
  help - Show this help text
  
You can also type any word directly to manifest it.
"""