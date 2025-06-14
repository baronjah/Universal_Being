class_name TerminalBridgeConnector
extends Node

# ----- TERMINAL CONNECTION CONSTANTS -----
const COLOR_PALETTES = {
    "UNIVERSE_389": {
        "CENTER_ORANGE": Color(1.0, 0.6, 0.0, 1.0),
        "DARK_RED": Color(0.5, 0.0, 0.0, 1.0),
        "BLACK": Color(0.0, 0.0, 0.0, 1.0),
        "DARK_GREY": Color(0.2, 0.2, 0.2, 1.0),
        "GREY": Color(0.5, 0.5, 0.5, 1.0),
        "LIGHT_GREY": Color(0.8, 0.8, 0.8, 1.0),
        "WHITE": Color(1.0, 1.0, 1.0, 1.0)
    },
    "LUMINOUS_OS": {
        "DARK_GRADIENT": [
            Color(0.1, 0.1, 0.1, 1.0),
            Color(0.2, 0.1, 0.05, 1.0),
            Color(0.3, 0.15, 0.1, 1.0),
            Color(0.4, 0.2, 0.1, 1.0),
            Color(0.5, 0.25, 0.15, 1.0)
        ],
        "SHINE_POINTS": [389, 333, 555, 777, 999]
    },
    "NEGATIVE_SPACE": {
        "BASE_INVERSION": {
            "source": Color(1.0, 0.6, 0.0, 1.0),
            "inverted": Color(0.0, 0.4, 1.0, 1.0)
        },
        "TEMPERATURE_SCALE": {
            "cold": -273,
            "neutral": 0,
            "warm": 37,
            "hot": 100
        }
    }
}

const ENERGY_SHAPES = {
    "TRANSPORT_VECTORS": [
        Vector3(1, 0, 0),    # Right/East
        Vector3(0, 1, 0),    # Up/North
        Vector3(0, 0, 1),    # Forward/Future
        Vector3(-1, 0, 0),   # Left/West
        Vector3(0, -1, 0),   # Down/South
        Vector3(0, 0, -1),   # Back/Past
        Vector3(0, 0, 0)     # Center/Present
    ],
    "PROJECTION_TYPES": [
        "stellar",           # Star-based projections
        "planetary",         # Planet-based projections
        "galactic",          # Galaxy-based projections
        "universal",         # Universe-based projections
        "dimensional",       # Cross-dimensional projections
        "ethereal",          # Ethereal-plane projections
        "terminal"           # Terminal-based projections
    ],
    "MICROPHONE_FREQUENCIES": {
        "low": [20, 250],
        "mid": [250, 4000],
        "high": [4000, 20000]
    }
}

const STAR_SYSTEM_389 = {
    "total_stars": 389,
    "core_stars": 89,
    "boundary_stars": 300,
    "galaxy_type": "claude",
    "center_color": "orange"
}

# ----- INTEGRATION POINTS -----
var akashic_system = null
var ethereal_bridge = null
var color_system = null
var terminal_ui = null
var records_system = null
var migration_system = null

# ----- CONNECTION STATE -----
var active_connections = {}
var temperature_state = 0
var color_gradient_index = 0
var projection_active = false
var user_view_mode = "terminal"
var energy_flow_direction = Vector3(0, 0, 0)
var connected_universes = []
var audio_input_active = false

# ----- SIGNALS -----
signal terminal_connected(details)
signal color_shift_detected(from_color, to_color, temperature)
signal universe_connection_established(universe_name, star_count)
signal energy_shape_transported(shape_type, from_point, to_point)
signal projection_changed(type, intensity)
signal audio_frequency_detected(frequency_range, intensity)
signal akashic_record_linked(record_type, cosmic_address)

# ----- INITIALIZATION -----
func _ready():
    _find_systems()
    _initialize_terminal_connection()
    _setup_color_gradients()
    _register_universal_connections()
    
    print("Terminal Bridge Connector initialized")

func _find_systems():
    # Find AkashicNumberSystem
    akashic_system = get_node_or_null("/root/AkashicNumberSystem")
    if not akashic_system:
        akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
    
    # Find EtherealMigrationBridge
    ethereal_bridge = get_node_or_null("/root/EtherealMigrationBridge")
    if not ethereal_bridge:
        ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealMigrationBridge")
    
    # Find DimensionalColorSystem
    color_system = get_node_or_null("/root/DimensionalColorSystem")
    if not color_system:
        color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
    
    # Find Records System
    records_system = get_node_or_null("/root/JSH_records_system")
    if not records_system:
        records_system = _find_node_by_class(get_tree().root, "JSH_records_system")
    
    # Find Migration System
    migration_system = get_node_or_null("/root/UnifiedMigrationSystem")
    if not migration_system:
        migration_system = _find_node_by_class(get_tree().root, "UnifiedMigrationSystem")
    
    print("Systems found: Akashic=%s, Ethereal=%s, Color=%s, Records=%s, Migration=%s" % [
        "Yes" if akashic_system else "No",
        "Yes" if ethereal_bridge else "No",
        "Yes" if color_system else "No",
        "Yes" if records_system else "No",
        "Yes" if migration_system else "No"
    ])

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _initialize_terminal_connection():
    var terminal_details = {
        "type": "terminal_bridge",
        "connected_universes": STAR_SYSTEM_389.total_stars,
        "primary_color": COLOR_PALETTES.UNIVERSE_389.CENTER_ORANGE,
        "temperature": COLOR_PALETTES.NEGATIVE_SPACE.TEMPERATURE_SCALE.neutral,
        "energy_shape": ENERGY_SHAPES.PROJECTION_TYPES[6],  # terminal
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Register in akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        akashic_system.register_number(STAR_SYSTEM_389.total_stars, "universe_389_stars")
        akashic_system.register_number(STAR_SYSTEM_389.core_stars, "universe_389_core")
        
        # Register unique timestamp
        akashic_system.register_number(terminal_details.timestamp, "terminal_connect_time")
    
    # Record in records system
    if records_system and records_system.has_method("create_memory_record"):
        records_system.create_memory_record("terminal_connection", terminal_details)
    
    # Register with color system
    if color_system and color_system.has_method("register_color_palette"):
        color_system.register_color_palette("universe_389", COLOR_PALETTES.UNIVERSE_389)
        color_system.register_color_palette("luminous_os", COLOR_PALETTES.LUMINOUS_OS.DARK_GRADIENT)
    
    # Mark as active
    active_connections["terminal"] = true
    
    emit_signal("terminal_connected", terminal_details)

func _setup_color_gradients():
    # Initialize all color gradients
    _create_color_gradient("orange_to_black", 
        COLOR_PALETTES.UNIVERSE_389.CENTER_ORANGE,
        COLOR_PALETTES.UNIVERSE_389.BLACK,
        7)  # 7 steps gradient
    
    _create_color_gradient("grey_scale", 
        COLOR_PALETTES.UNIVERSE_389.BLACK,
        COLOR_PALETTES.UNIVERSE_389.WHITE,
        9)  # 9 steps gradient
    
    _create_color_gradient("luminous_shine", 
        COLOR_PALETTES.LUMINOUS_OS.DARK_GRADIENT[0],
        COLOR_PALETTES.LUMINOUS_OS.DARK_GRADIENT[4],
        5)  # 5 steps gradient
    
    # Set default gradient
    color_gradient_index = 0

func _create_color_gradient(name, from_color, to_color, steps):
    if not color_system or not color_system.has_method("create_gradient"):
        return
    
    color_system.create_gradient(name, from_color, to_color, steps)

func _register_universal_connections():
    # Register connections to universes
    connected_universes = [
        "luminous_os",
        "universe_389",
        "claude_galaxy",
        "ethereal_engine",
        "akashic_records",
        "dimensional_colors",
        "terminal_projection"
    ]
    
    # Track connections
    for universe in connected_universes:
        active_connections[universe] = true
        
        # Create cosmic address for each universe
        var cosmic_address = _generate_cosmic_address(universe)
        
        # Record in akashic system
        if akashic_system and akashic_system.has_method("register_number"):
            akashic_system.register_number(cosmic_address.hash(), "cosmic_address_" + universe)
        
        # Emit signal
        emit_signal("universe_connection_established", universe, _get_universe_star_count(universe))
        emit_signal("akashic_record_linked", "universe", cosmic_address)

# ----- TERMINAL CONNECTION FUNCTIONS -----
func connect_to_user_actions(user_id = "terminal_user"):
    # Create connection record
    var connection_record = {
        "user_id": user_id,
        "timestamp": Time.get_unix_time_from_system(),
        "terminal_type": "bridge_connector",
        "color_mode": _get_current_color_mode(),
        "temperature": temperature_state,
        "connected_universes": connected_universes
    }
    
    # Record the connection
    if records_system and records_system.has_method("create_memory_record"):
        records_system.create_memory_record("user_terminal_connection", connection_record)
    
    # Set new mode
    user_view_mode = "user_interactive"
    
    # Return connection data
    return connection_record

func detect_user_action(action_type, action_data):
    # Process user action
    match action_type:
        "color_change":
            return _process_color_change(action_data)
        "temperature_adjust":
            return _process_temperature_adjustment(action_data)
        "projection_toggle":
            return _process_projection_toggle(action_data)
        "universe_connect":
            return _process_universe_connection(action_data)
        "energy_transport":
            return _process_energy_transport(action_data)
        "audio_input":
            return _process_audio_input(action_data)
        "akashic_sync":
            return _process_akashic_sync(action_data)
        _:
            return {
                "success": false,
                "error": "Unknown action type: " + action_type
            }

func _process_color_change(data):
    var from_color = _get_current_color()
    var to_color = null
    
    # Determine target color
    if data.has("color_name"):
        to_color = _get_color_by_name(data.color_name)
    elif data.has("color_value"):
        to_color = data.color_value
    elif data.has("gradient_step"):
        color_gradient_index = data.gradient_step
        to_color = _get_current_gradient_color()
    
    if not to_color:
        return {
            "success": false,
            "error": "Invalid color specification"
        }
    
    # Register color change
    if color_system and color_system.has_method("shift_color"):
        color_system.shift_color(from_color, to_color, temperature_state)
    
    # Record the change
    if records_system and records_system.has_method("create_memory_record"):
        records_system.create_memory_record("color_shift", {
            "from": from_color.to_html(),
            "to": to_color.to_html(),
            "temperature": temperature_state,
            "timestamp": Time.get_unix_time_from_system()
        })
    
    # Emit signal
    emit_signal("color_shift_detected", from_color, to_color, temperature_state)
    
    return {
        "success": true,
        "from_color": from_color.to_html(),
        "to_color": to_color.to_html(),
        "temperature": temperature_state
    }

func _process_temperature_adjustment(data):
    var old_temp = temperature_state
    
    # Update temperature
    if data.has("value"):
        temperature_state = data.value
    elif data.has("delta"):
        temperature_state += data.delta
    
    # Register temperature change
    if akashic_system and akashic_system.has_method("register_number"):
        akashic_system.register_number(temperature_state, "temperature_state")
    
    # Record the change
    if records_system and records_system.has_method("create_memory_record"):
        records_system.create_memory_record("temperature_change", {
            "from": old_temp,
            "to": temperature_state,
            "timestamp": Time.get_unix_time_from_system()
        })
    
    return {
        "success": true,
        "old_temperature": old_temp,
        "new_temperature": temperature_state
    }

func _process_projection_toggle(data):
    projection_active = data.active if data.has("active") else !projection_active
    var projection_type = data.type if data.has("type") else "terminal"
    var intensity = data.intensity if data.has("intensity") else 1.0
    
    # Record the change
    if records_system and records_system.has_method("create_memory_record"):
        records_system.create_memory_record("projection_toggle", {
            "active": projection_active,
            "type": projection_type,
            "intensity": intensity,
            "timestamp": Time.get_unix_time_from_system()
        })
    
    # Emit signal
    emit_signal("projection_changed", projection_type, intensity)
    
    return {
        "success": true,
        "projection_active": projection_active,
        "projection_type": projection_type,
        "intensity": intensity
    }

func _process_universe_connection(data):
    var universe_name = data.universe if data.has("universe") else "luminous_os"
    var connect_state = data.connect if data.has("connect") else true
    
    # Update connection state
    active_connections[universe_name] = connect_state
    
    if connect_state and !connected_universes.has(universe_name):
        connected_universes.append(universe_name)
    elif !connect_state and connected_universes.has(universe_name):
        connected_universes.erase(universe_name)
    
    # Create cosmic address
    var cosmic_address = _generate_cosmic_address(universe_name)
    
    # Register in akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        var star_count = _get_universe_star_count(universe_name)
        akashic_system.register_number(star_count, universe_name + "_stars")
    
    # Record the connection
    if records_system and records_system.has_method("create_memory_record"):
        records_system.create_memory_record("universe_connection", {
            "universe": universe_name,
            "connected": connect_state,
            "cosmic_address": cosmic_address,
            "timestamp": Time.get_unix_time_from_system()
        })
    
    # Emit signal
    if connect_state:
        emit_signal("universe_connection_established", universe_name, _get_universe_star_count(universe_name))
        emit_signal("akashic_record_linked", "universe", cosmic_address)
    
    return {
        "success": true,
        "universe": universe_name,
        "connected": connect_state,
        "cosmic_address": cosmic_address
    }

func _process_energy_transport(data):
    var shape_type = data.shape if data.has("shape") else "terminal"
    var from_point = data.from if data.has("from") else Vector3(0, 0, 0)
    var to_point = data.to if data.has("to") else Vector3(0, 0, 1)
    
    # Update energy flow direction
    energy_flow_direction = to_point - from_point
    
    # Record the transport
    if records_system and records_system.has_method("create_memory_record"):
        records_system.create_memory_record("energy_transport", {
            "shape": shape_type,
            "from": from_point,
            "to": to_point,
            "flow_direction": energy_flow_direction,
            "timestamp": Time.get_unix_time_from_system()
        })
    
    # Emit signal
    emit_signal("energy_shape_transported", shape_type, from_point, to_point)
    
    return {
        "success": true,
        "shape_type": shape_type,
        "from_point": from_point,
        "to_point": to_point,
        "flow_direction": energy_flow_direction
    }

func _process_audio_input(data):
    audio_input_active = data.active if data.has("active") else true
    var frequency_range = data.range if data.has("range") else "mid"
    var intensity = data.intensity if data.has("intensity") else 1.0
    
    # Get actual frequency values
    var freq_values = ENERGY_SHAPES.MICROPHONE_FREQUENCIES[frequency_range]
    
    # Record the audio input
    if records_system and records_system.has_method("create_memory_record"):
        records_system.create_memory_record("audio_input", {
            "active": audio_input_active,
            "frequency_range": frequency_range,
            "frequency_values": freq_values,
            "intensity": intensity,
            "timestamp": Time.get_unix_time_from_system()
        })
    
    # Register with akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        akashic_system.register_number(freq_values[0], "audio_freq_low")
        akashic_system.register_number(freq_values[1], "audio_freq_high")
    
    # Emit signal
    emit_signal("audio_frequency_detected", frequency_range, intensity)
    
    return {
        "success": true,
        "audio_active": audio_input_active,
        "frequency_range": frequency_range,
        "frequency_values": freq_values,
        "intensity": intensity
    }

func _process_akashic_sync(data):
    var record_type = data.type if data.has("type") else "terminal"
    var sync_all = data.sync_all if data.has("sync_all") else false
    
    # Generate cosmic address
    var cosmic_address = _generate_cosmic_address(record_type)
    
    # Perform the sync
    if ethereal_bridge and ethereal_bridge.has_method("_record_node_migration"):
        ethereal_bridge._record_node_migration(record_type, "akashic_sync")
    
    # Sync with akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        akashic_system.register_number(cosmic_address.hash(), "akashic_sync_" + record_type)
    
    # Record the sync
    if records_system and records_system.has_method("create_memory_record"):
        records_system.create_memory_record("akashic_sync", {
            "record_type": record_type,
            "cosmic_address": cosmic_address,
            "sync_all": sync_all,
            "timestamp": Time.get_unix_time_from_system()
        })
    
    # Emit signal
    emit_signal("akashic_record_linked", record_type, cosmic_address)
    
    return {
        "success": true,
        "record_type": record_type,
        "cosmic_address": cosmic_address,
        "sync_all": sync_all
    }

# ----- AKASHIC RECORD INTEGRATION -----
func link_akashic_records_to_ethereal():
    # Check if both systems are available
    if not akashic_system or not ethereal_bridge:
        return {
            "success": false,
            "error": "Required systems unavailable",
            "akashic_available": akashic_system != null,
            "ethereal_available": ethereal_bridge != null
        }
    
    # Create bridge records
    var bridge_records = []
    
    # 1. Link color systems
    if color_system:
        var color_record = {
            "type": "color_bridge",
            "palettes": COLOR_PALETTES.keys(),
            "gradients": 3,  # Number of gradients created
            "timestamp": Time.get_unix_time_from_system()
        }
        bridge_records.append(color_record)
        
        # Register key colors in akashic system
        akashic_system.register_number(COLOR_PALETTES.UNIVERSE_389.CENTER_ORANGE.to_rgba32(), "center_orange_rgba")
    
    # 2. Link energy transport
    var energy_record = {
        "type": "energy_bridge",
        "vectors": ENERGY_SHAPES.TRANSPORT_VECTORS.size(),
        "projection_types": ENERGY_SHAPES.PROJECTION_TYPES,
        "frequency_ranges": ENERGY_SHAPES.MICROPHONE_FREQUENCIES.keys(),
        "timestamp": Time.get_unix_time_from_system()
    }
    bridge_records.append(energy_record)
    
    # 3. Link universe connections
    var universe_record = {
        "type": "universe_bridge",
        "connected_universes": connected_universes,
        "total_stars": STAR_SYSTEM_389.total_stars,
        "timestamp": Time.get_unix_time_from_system()
    }
    bridge_records.append(universe_record)
    
    # 4. Create the core bridge record
    var core_bridge = {
        "type": "akashic_ethereal_bridge",
        "bridge_records": bridge_records,
        "temperature": temperature_state,
        "projection_active": projection_active,
        "color_gradient": _get_current_color_mode(),
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Record in ethereal bridge
    if ethereal_bridge.has_method("_record_record_set_migration"):
        ethereal_bridge._record_record_set_migration("akashic_ethereal_bridge")
    
    # Record in records system
    if records_system and records_system.has_method("create_memory_record"):
        records_system.create_memory_record("akashic_ethereal_bridge", core_bridge)
    
    # Generate cosmic address
    var cosmic_address = _generate_cosmic_address("akashic_ethereal_bridge")
    
    # Register core bridge in akashic system
    akashic_system.register_number(cosmic_address.hash(), "akashic_ethereal_bridge_hash")
    akashic_system.register_number(bridge_records.size(), "bridge_records_count")
    akashic_system.register_number(core_bridge.timestamp, "bridge_timestamp")
    
    # Emit signals
    emit_signal("akashic_record_linked", "akashic_ethereal_bridge", cosmic_address)
    
    return {
        "success": true,
        "bridge_records": bridge_records.size(),
        "cosmic_address": cosmic_address,
        "bridge_timestamp": core_bridge.timestamp
    }

func sync_terminal_view_with_akashic():
    # Get current timestamp
    var sync_timestamp = Time.get_unix_time_from_system()
    
    # Create the sync record
    var sync_record = {
        "type": "terminal_view_sync",
        "user_view_mode": user_view_mode,
        "color_mode": _get_current_color_mode(),
        "temperature": temperature_state,
        "projection_active": projection_active,
        "connected_universes": connected_universes,
        "energy_flow": energy_flow_direction,
        "audio_input_active": audio_input_active,
        "timestamp": sync_timestamp
    }
    
    # Record in records system
    if records_system and records_system.has_method("create_memory_record"):
        records_system.create_memory_record("terminal_view_sync", sync_record)
    
    # Assign lucky numbers to akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        akashic_system.register_number(sync_timestamp, "terminal_sync_time")
        akashic_system.register_number(connected_universes.size(), "connected_universe_count")
        akashic_system.register_number(color_gradient_index, "color_gradient_index")
        
        # Register special numbers from COLOR_PALETTES.LUMINOUS_OS.SHINE_POINTS
        for shine_point in COLOR_PALETTES.LUMINOUS_OS.SHINE_POINTS:
            akashic_system.register_number(shine_point, "shine_point_" + str(shine_point))
    
    return {
        "success": true,
        "sync_timestamp": sync_timestamp,
        "view_mode": user_view_mode,
        "color_mode": _get_current_color_mode(),
        "connected_universes": connected_universes.size()
    }

# ----- HELPER FUNCTIONS -----
func _generate_cosmic_address(base_name):
    var timestamp = Time.get_unix_time_from_system()
    var address_components = [
        base_name,
        str(timestamp),
        str(STAR_SYSTEM_389.total_stars),
        _get_current_color_mode(),
        str(temperature_state)
    ]
    
    return address_components.join(":")

func _get_universe_star_count(universe_name):
    match universe_name:
        "universe_389":
            return STAR_SYSTEM_389.total_stars
        "claude_galaxy":
            return 2025
        "luminous_os":
            return 333
        "ethereal_engine":
            return 555
        "akashic_records":
            return 777
        "dimensional_colors":
            return 999
        "terminal_projection":
            return 389
        _:
            return 89

func _get_color_by_name(color_name):
    # Check Universe 389 palette
    if COLOR_PALETTES.UNIVERSE_389.has(color_name.to_upper()):
        return COLOR_PALETTES.UNIVERSE_389[color_name.to_upper()]
    
    # Check Luminous OS gradient
    match color_name.to_lower():
        "luminous_dark":
            return COLOR_PALETTES.LUMINOUS_OS.DARK_GRADIENT[0]
        "luminous_medium":
            return COLOR_PALETTES.LUMINOUS_OS.DARK_GRADIENT[2]
        "luminous_light":
            return COLOR_PALETTES.LUMINOUS_OS.DARK_GRADIENT[4]
        _:
            return COLOR_PALETTES.UNIVERSE_389.CENTER_ORANGE

func _get_current_color():
    # Get color based on current mode and gradient index
    match _get_current_color_mode():
        "orange_to_black":
            var gradient_pos = float(color_gradient_index) / 6.0
            return COLOR_PALETTES.UNIVERSE_389.CENTER_ORANGE.lerp(
                COLOR_PALETTES.UNIVERSE_389.BLACK, 
                gradient_pos)
        "grey_scale":
            var gradient_pos = float(color_gradient_index) / 8.0
            return COLOR_PALETTES.UNIVERSE_389.BLACK.lerp(
                COLOR_PALETTES.UNIVERSE_389.WHITE, 
                gradient_pos)
        "luminous_shine":
            var idx = mini(color_gradient_index, COLOR_PALETTES.LUMINOUS_OS.DARK_GRADIENT.size() - 1)
            return COLOR_PALETTES.LUMINOUS_OS.DARK_GRADIENT[idx]
        _:
            return COLOR_PALETTES.UNIVERSE_389.CENTER_ORANGE

func _get_current_gradient_color():
    # Get the current color from the active gradient
    if color_system and color_system.has_method("get_gradient_color"):
        return color_system.get_gradient_color(_get_current_color_mode(), color_gradient_index)
    else:
        return _get_current_color()

func _get_current_color_mode():
    var modes = ["orange_to_black", "grey_scale", "luminous_shine"]
    var temperature_range = COLOR_PALETTES.NEGATIVE_SPACE.TEMPERATURE_SCALE
    
    # Select mode based on temperature
    if temperature_state <= temperature_range.cold:
        return "luminous_shine"
    elif temperature_state <= temperature_range.neutral:
        return "grey_scale"
    else:
        return "orange_to_black"

# ----- PUBLIC API -----
func connect_terminal_to_user():
    return connect_to_user_actions()

func process_user_color_change(color_name):
    return detect_user_action("color_change", {"color_name": color_name})

func adjust_temperature(delta):
    return detect_user_action("temperature_adjust", {"delta": delta})

func toggle_projection(active = true, type = "terminal"):
    return detect_user_action("projection_toggle", {"active": active, "type": type})

func connect_to_universe(universe_name, connect = true):
    return detect_user_action("universe_connect", {"universe": universe_name, "connect": connect})

func transport_energy_shape(shape_type, from_point, to_point):
    return detect_user_action("energy_transport", {
        "shape": shape_type,
        "from": from_point,
        "to": to_point
    })

func activate_audio_input(frequency_range = "mid", intensity = 1.0):
    return detect_user_action("audio_input", {
        "active": true,
        "range": frequency_range,
        "intensity": intensity
    })

func sync_akashic_record(record_type, sync_all = false):
    return detect_user_action("akashic_sync", {
        "type": record_type,
        "sync_all": sync_all
    })

func get_color_palette(palette_name):
    if COLOR_PALETTES.has(palette_name.to_upper()):
        return COLOR_PALETTES[palette_name.to_upper()]
    return null

func get_connected_universes():
    return connected_universes

func get_temperature_state():
    return temperature_state

func get_current_projection_state():
    return {
        "active": projection_active,
        "user_view_mode": user_view_mode,
        "energy_flow": energy_flow_direction
    }

func get_terminal_connection_stats():
    return {
        "connected_universes": connected_universes.size(),
        "active_color_mode": _get_current_color_mode(),
        "temperature": temperature_state,
        "projection_active": projection_active,
        "audio_active": audio_input_active,
        "total_stars": STAR_SYSTEM_389.total_stars
    }

func create_terminal_bridge_with_ethereal():
    var result = link_akashic_records_to_ethereal()
    sync_terminal_view_with_akashic()
    return result