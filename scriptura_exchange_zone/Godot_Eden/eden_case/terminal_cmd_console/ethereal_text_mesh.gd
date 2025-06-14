extends Node
class_name EtherealTextMesh

signal mesh_generated(mesh_data: Dictionary)
signal visualization_ready(view_data: Dictionary)
signal dimension_changed(new_dimension: int)

# Core components
var word_database = null
var dream_connector = null
var luno_manager = null

# Visualization settings
var text_mesh_config: Dictionary = {
    "depth": 0.5,
    "extrusion": 0.2,
    "bevel": 0.05,
    "resolution": 64,
    "font_size": 1.0,
    "font_path": "res://fonts/ethereal_font.ttf",
    "material": null,
    "dimension_offset": Vector3(0, 0, 0),
    "auto_rotate": true,
    "rotation_speed": 0.5,
    "vr_mode": false,
    "split_view": false
}

# VR specific settings
var vr_config: Dictionary = {
    "enabled": false,
    "hand_tracking": true,
    "interaction_distance": 1.5,
    "haptic_feedback": true,
    "split_mode": false,
    "hologram_density": 0.8
}

# Current state
var active_texts: Array = []
var current_dimension: int = 3
var ethereal_factor: float = 1.0
var signature_mode: bool = false
var browser_mode: bool = false

# Earth connection simulation
var earth_connection: Dictionary = {
    "active": false,
    "frequency": 7.83, # Schumann resonance
    "signal_strength": 0.5,
    "last_message": "",
    "connection_points": []
}

# Text database
var text_database: Array = []

func _ready():
    # Initialize the text mesh system
    print("🔤 Ethereal Text Mesh initializing...")
    
    # Connect to required systems
    _connect_to_systems()
    
    # Initialize text database
    _initialize_text_database()
    
    # Initialize default material
    _create_default_material()
    
    # Set up earth connection
    _initialize_earth_connection()

func _connect_to_systems():
    # Try to find word database
    word_database = get_node_or_null("/root/WordDreamCreator")
    if word_database:
        print("✓ Connected to Word Dream Creator")
    
    # Connect to Dream Connector
    dream_connector = get_node_or_null("/root/DreamConnector")
    if dream_connector:
        print("✓ Connected to Dream Connector")
        dream_connector.connect("dream_symbol_received", Callable(self, "_on_dream_symbol"))
    
    # Connect to LUNO
    luno_manager = get_node_or_null("/root/LunoCycleManager")
    if luno_manager:
        print("✓ Connected to LUNO Cycle Manager")
        luno_manager.register_participant("EtherealTextMesh", Callable(self, "_on_luno_tick"))

func _initialize_text_database():
    # Initialize with some default texts
    text_database = [
        {
            "text": "ethereal",
            "dimension": 3,
            "creation_date": OS.get_unix_time() - 86400 * 7,
            "power": 7,
            "color": Color(0.5, 0.7, 1.0, 0.9),
            "tags": ["engine", "core", "system"]
        },
        {
            "text": "luminus",
            "dimension": 4,
            "creation_date": OS.get_unix_time() - 86400 * 3,
            "power": 8,
            "color": Color(0.9, 0.8, 0.2, 0.95),
            "tags": ["light", "guide", "vision"]
        },
        {
            "text": "dimension",
            "dimension": 5,
            "creation_date": OS.get_unix_time() - 86400,
            "power": 9,
            "color": Color(0.3, 0.9, 0.7, 0.8),
            "tags": ["space", "reality", "perception"]
        }
    ]
    
    print("📚 Text database initialized with %d entries" % text_database.size())

func _create_default_material():
    # In a real implementation, this would create a shader material
    # For now, we'll just simulate it
    
    text_mesh_config.material = {
        "type": "shader",
        "albedo": Color(0.7, 0.8, 1.0),
        "emission": Color(0.2, 0.5, 0.9),
        "emission_energy": 1.5,
        "roughness": 0.1,
        "rim": 0.6,
        "rim_tint": 0.8,
        "clearcoat": 1.0,
        "clearcoat_roughness": 0.05,
        "refraction": 0.05
    }
    
    print("🎨 Default material created")

func _initialize_earth_connection():
    # Set up simulated earth connection points
    earth_connection.connection_points = [
        { "name": "Sedona", "frequency": 7.83, "strength": 0.9 },
        { "name": "Mount Shasta", "frequency": 8.12, "strength": 0.85 },
        { "name": "Stonehenge", "frequency": 7.94, "strength": 0.78 },
        { "name": "Uluru", "frequency": 8.04, "strength": 0.92 },
        { "name": "Great Pyramid", "frequency": 7.88, "strength": 0.88 }
    ]
    
    print("🌍 Earth connection initialized with %d connection points" % 
          earth_connection.connection_points.size())

func create_text_mesh(text: String, config: Dictionary = {}) -> Dictionary:
    # Create a 3D text mesh with the given text
    
    # Apply any custom config settings
    var mesh_config = text_mesh_config.duplicate()
    for key in config:
        mesh_config[key] = config[key]
    
    # Create text entry
    var text_entry = {
        "id": "mesh_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000),
        "text": text,
        "config": mesh_config,
        "dimension": current_dimension,
        "creation_date": OS.get_unix_time(),
        "position": Vector3(0, 0, 0),
        "rotation": Vector3(0, 0, 0),
        "scale": Vector3(1, 1, 1),
        "ethereal_factor": ethereal_factor,
        "vr_enabled": vr_config.enabled
    }
    
    # In a real implementation, this would create the actual 3D mesh
    # For simulation, we'll just set some properties
    
    print("🔤 Created text mesh: '%s' (dimension: %d)" % [text, current_dimension])
    
    # Add to active texts
    active_texts.append(text_entry)
    
    # Store in database
    var db_entry = {
        "text": text,
        "dimension": current_dimension,
        "creation_date": OS.get_unix_time(),
        "power": int(ethereal_factor * 10),
        "color": Color(randf(), randf(), randf(), 0.8 + randf() * 0.2),
        "tags": []
    }
    
    # Generate some tags based on the text
    var potential_tags = ["vision", "dream", "reality", "digital", "ethereal", 
                          "cosmic", "quantum", "energy", "spirit", "dimension"]
    
    # Add 2-4 random tags
    var tag_count = 2 + randi() % 3
    for i in range(tag_count):
        var tag = potential_tags[randi() % potential_tags.size()]
        if not db_entry.tags.has(tag):
            db_entry.tags.append(tag)
    
    text_database.append(db_entry)
    
    # Emit signal
    emit_signal("mesh_generated", text_entry)
    
    return text_entry

func create_signature_mesh(signature_text: String) -> Dictionary:
    # Create a special signature mesh
    
    signature_mode = true
    
    # Special configuration for signatures
    var signature_config = {
        "depth": 0.8,
        "extrusion": 0.3,
        "bevel": 0.1,
        "font_size": 1.2,
        "material": {
            "type": "signature",
            "albedo": Color(0.9, 0.7, 0.2),
            "emission": Color(1.0, 0.8, 0.0),
            "emission_energy": 2.0,
            "roughness": 0.05,
            "rim": 0.8,
            "rim_tint": 0.9,
            "clearcoat": 1.0,
            "clearcoat_roughness": 0.02,
            "refraction": 0.1
        }
    }
    
    var signature = create_text_mesh(signature_text, signature_config)
    
    print("✍️ Created signature mesh")
    
    return signature

func setup_browser_visualization(container_id: String = "text-mesh-container") -> Dictionary:
    # Set up visualization for web browser
    
    browser_mode = true
    
    var browser_config = {
        "container_id": container_id,
        "width": 800,
        "height": 600,
        "background_color": "#111133",
        "antialiasing": true,
        "enable_shadows": true,
        "ambient_light": Color(0.1, 0.1, 0.2),
        "main_light": {
            "color": Color(1.0, 0.98, 0.9),
            "energy": 1.2,
            "direction": Vector3(-0.5, -0.7, -0.5)
        },
        "camera": {
            "fov": 55.0,
            "position": Vector3(0, 0, 5),
            "target": Vector3(0, 0, 0)
        }
    }
    
    print("🌐 Browser visualization setup complete")
    
    # Emit signal
    emit_signal("visualization_ready", browser_config)
    
    return browser_config

func set_dimension(dimension: int) -> bool:
    # Set the current dimensional space for text
    if dimension < 1 or dimension > 12:
        print("⚠️ Invalid dimension: %d (must be 1-12)" % dimension)
        return false
    
    var old_dimension = current_dimension
    current_dimension = dimension
    
    print("🌀 Dimension changed: %d → %d" % [old_dimension, dimension])
    
    # Calculate dimensional offset
    var offset = Vector3(0, 0, 0)
    
    match dimension:
        3: # Standard 3D
            offset = Vector3(0, 0, 0)
            ethereal_factor = 1.0
        4: # 4D projection
            offset = Vector3(0, 0.5, 0)
            ethereal_factor = 1.2
        5: # 5D projection
            offset = Vector3(0.5, 0.5, 0.5)
            ethereal_factor = 1.5
        6, 7, 8: # Higher dimensions
            offset = Vector3(dimension - 5, dimension - 5, 0)
            ethereal_factor = 1.8
        9, 10, 11, 12: # Transcendent dimensions
            offset = Vector3(0, 0, dimension - 8)
            ethereal_factor = 2.0
    
    text_mesh_config.dimension_offset = offset
    
    # Update all active texts
    for text in active_texts:
        text.dimension = dimension
        text.ethereal_factor = ethereal_factor
    
    # Emit signal
    emit_signal("dimension_changed", dimension)
    
    return true

func toggle_vr_mode(enable: bool) -> bool:
    # Toggle VR mode
    vr_config.enabled = enable
    
    if enable:
        print("🥽 VR mode enabled")
        
        # Enable split view if not already enabled
        if not text_mesh_config.split_view:
            set_split_view(true)
    else:
        print("🥽 VR mode disabled")
    
    # Update all active texts
    for text in active_texts:
        text.vr_enabled = enable
    
    return true

func set_split_view(enable: bool) -> bool:
    # Set split view mode
    text_mesh_config.split_view = enable
    
    if enable:
        print("👓 Split view enabled")
        
        if vr_config.enabled:
            vr_config.split_mode = true
    else:
        print("👓 Split view disabled")
        
        if vr_config.enabled:
            vr_config.split_mode = false
    
    return true

func connect_to_earth(location: String = "") -> bool:
    # Connect to earth's frequency
    
    earth_connection.active = true
    
    # Select specific location if provided
    if not location.empty():
        for point in earth_connection.connection_points:
            if point.name.to_lower() == location.to_lower():
                earth_connection.frequency = point.frequency
                earth_connection.signal_strength = point.strength
                
                print("🌍 Connected to Earth at %s (frequency: %.2f Hz, strength: %.2f)" % [
                    point.name, 
                    earth_connection.frequency, 
                    earth_connection.signal_strength
                ])
                
                break
    else:
        # Use default Schumann resonance
        print("🌍 Connected to Earth's frequency (%.2f Hz)" % earth_connection.frequency)
    
    # Generate a message from Earth
    _receive_earth_message()
    
    return true

func disconnect_from_earth() -> bool:
    # Disconnect from earth's frequency
    earth_connection.active = false
    
    print("🌍 Disconnected from Earth's frequency")
    
    return true

func _receive_earth_message():
    # Generate a simulated message from Earth
    
    var messages = [
        "The boundaries between dimensions are thinner than you think",
        "Remember that all text is energy given form",
        "Words are bridges between worlds",
        "The pattern repeats at every scale",
        "Your consciousness shapes the visualization",
        "Creation flows from symbol to form",
        "The ethereal and physical are one spectrum",
        "Frequencies align when intention is clear"
    ]
    
    earth_connection.last_message = messages[randi() % messages.size()]
    
    print("🌍 Earth message received: \"%s\"" % earth_connection.last_message)
    
    # Create a mesh from this message with special earth properties
    if randf() < earth_connection.signal_strength:
        var earth_config = {
            "material": {
                "type": "earth",
                "albedo": Color(0.2, 0.8, 0.4),
                "emission": Color(0.1, 0.7, 0.3),
                "emission_energy": earth_connection.signal_strength * 3.0,
                "roughness": 0.2,
                "rim": 0.7,
                "rim_tint": 0.5
            }
        }
        
        create_text_mesh(earth_connection.last_message, earth_config)

func _on_dream_symbol(symbol: String):
    # Create text mesh from dream symbol if earth is connected
    if earth_connection.active and randf() < 0.3:  # 30% chance
        var dream_config = {
            "material": {
                "type": "dream",
                "albedo": Color(0.5, 0.3, 0.9),
                "emission": Color(0.4, 0.2, 1.0),
                "emission_energy": 1.8,
                "roughness": 0.1
            }
        }
        
        create_text_mesh(symbol, dream_config)
        
        print("💭 Dream symbol materialized as text mesh")

func _on_luno_tick(turn: int, phase_name: String):
    # Special case for evolution
    if turn == 0 and phase_name == "Evolution":
        print("✨ EtherealTextMesh evolving with system")
        
        # Evolve text mesh capabilities
        text_mesh_config.resolution += 16
        
        # Enhance materials
        if text_mesh_config.material:
            text_mesh_config.material.emission_energy += 0.2
            text_mesh_config.material.clearcoat += 0.1
        
        return
    
    # Process based on current phase
    match phase_name:
        "Genesis":
            # Genesis is good for creating new text
            if earth_connection.active and randf() < 0.5:
                _receive_earth_message()
        
        "Unity", "Beyond":
            # These phases enhance VR capabilities
            if vr_config.enabled:
                vr_config.hologram_density += 0.05
                print("🔄 VR hologram density increased: %.2f" % vr_config.hologram_density)

# Public API methods
func get_active_texts() -> Array:
    return active_texts

func get_text_database() -> Array:
    return text_database

func get_current_dimension() -> int:
    return current_dimension

func get_vr_config() -> Dictionary:
    return vr_config

func get_earth_connection() -> Dictionary:
    return earth_connection

func get_text_mesh_config() -> Dictionary:
    return text_mesh_config

func set_browser_element_id(element_id: String) -> bool:
    # Set browser container element
    if browser_mode:
        setup_browser_visualization(element_id)
        return true
    return false

# Example usage:
# var text_mesh = EtherealTextMesh.new()
# add_child(text_mesh)
# text_mesh.create_text_mesh("ethereal")
# text_mesh.toggle_vr_mode(true)
# text_mesh.connect_to_earth("Sedona")