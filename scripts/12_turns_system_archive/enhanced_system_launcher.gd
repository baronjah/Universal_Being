class_name EnhancedSystemLauncher
extends Node

# ----- CORE COMPONENTS -----
var akashic_system = null
var color_system = null
var ethereal_bridge = null
var visual_system = null
var keyboard_system = null
var migration_tool = null
var color_animation_system = null
var terminal_interface = null
var storage_system = null

# ----- SYSTEM LOADERS -----
var systems_loaded = {}
var required_systems = [
    "AkashicNumberSystem",
    "DimensionalColorSystem",
    "EtherealAkashicBridge",
    "VisualIndicatorSystem",
    "KeyboardCommandSystem", 
    "Godot4MigrationTool",
    "ColorAnimationSystem",
    "UnifiedTerminalInterface",
    "StorageIntegrationSystem"
]

# ----- SETTINGS -----
var config = {
    "auto_initialize": true,
    "default_interface": "terminal", # terminal, notepad3d, browser, visual
    "debug_mode": false,
    "starting_turn": 1,
    "max_wish_tokens": 10000,
    "show_welcome": true,
    "color_frequency": 99,
    "dimensional_depth": 1,
    "migration_backup": true
}

# ----- SIGNALS -----
signal system_loaded(system_name)
signal all_systems_loaded()
signal system_failed(system_name, error)
signal system_ready
signal interface_ready(interface_name)
signal turn_changed(new_turn, old_turn)

# ----- INITIALIZATION -----
func _ready():
    print("Enhanced System Launcher starting...")
    
    # Initialize systems
    if config.auto_initialize:
        initialize_system()

func initialize_system():
    print("Initializing Integrated System...")
    
    # Initialize all required systems
    _initialize_systems()
    
    # Ensure proper initialization order
    initialize_akashic_system()
    initialize_ethereal_bridge()
    initialize_color_systems()
    initialize_terminal_interface()
    initialize_storage_system()
    initialize_keyboard_system()
    
    # Connect signals between components
    connect_signals()
    
    # Set initial interface
    set_interface(config.default_interface)
    
    # Show welcome message
    if config.show_welcome:
        show_welcome()
    
    print("Integrated System initialized successfully")
    emit_signal("system_ready")

func _initialize_systems():
    # Initialize all required systems
    for system_name in required_systems:
        var system = _load_system(system_name)
        
        if system:
            systems_loaded[system_name] = true
            emit_signal("system_loaded", system_name)
            
            # Store reference
            match system_name:
                "AkashicNumberSystem":
                    akashic_system = system
                "DimensionalColorSystem":
                    color_system = system
                "EtherealAkashicBridge":
                    ethereal_bridge = system
                "VisualIndicatorSystem":
                    visual_system = system
                "KeyboardCommandSystem":
                    keyboard_system = system
                "Godot4MigrationTool":
                    migration_tool = system
                "ColorAnimationSystem":
                    color_animation_system = system
                "UnifiedTerminalInterface":
                    terminal_interface = system
                "StorageIntegrationSystem":
                    storage_system = system
        else:
            systems_loaded[system_name] = false
            emit_signal("system_failed", system_name, "Failed to initialize")
    
    # Check if all systems loaded
    var all_loaded = true
    for system_name in systems_loaded:
        if not systems_loaded[system_name]:
            all_loaded = false
            break
    
    if all_loaded:
        _log("All systems loaded successfully")
        emit_signal("all_systems_loaded")
    else:
        _log("Some systems failed to load", true)

func _load_system(system_name: String):
    # Check if system already exists in scene tree
    var node = get_node_or_null("/root/" + system_name)
    if node:
        _log("Found existing " + system_name)
        return node
    
    # Check for node with class
    node = _find_node_with_class(get_tree().root, system_name)
    if node:
        _log("Found existing " + system_name + " by class")
        return node
    
    # Try to instantiate the system
    _log("Creating new instance of " + system_name)
    
    var script_path = "res://12_turns_system/" + system_name.to_snake_case() + ".gd"
    if ResourceLoader.exists(script_path):
        var script = load(script_path)
        var instance = script.new()
        add_child(instance)
        return instance
    else:
        _log("Failed to find script for " + system_name + " at " + script_path, true)
        return null

func _find_node_with_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_with_class(child, class_name_str)
        if found:
            return found
    
    return null

# ----- COMPONENT INITIALIZATION -----
func initialize_akashic_system():
    if akashic_system:
        _log("Starting Akashic Number System")
        
        # Set up required variables
        if akashic_system.has_method("initialize_akashic_records"):
            akashic_system.initialize_akashic_records()
        
        print("Akashic System initialized")

func initialize_ethereal_bridge():
    if ethereal_bridge:
        _log("Starting Ethereal Akashic Bridge")
        
        # Enable the bridge
        if ethereal_bridge.has_method("toggle_bridge"):
            ethereal_bridge.toggle_bridge(true)
        
        # Set connection frequency
        if ethereal_bridge.has_method("set_connection_frequency"):
            ethereal_bridge.set_connection_frequency(0.5)
        
        # Connect to akashic system
        if akashic_system and ethereal_bridge.has_method("connect_systems"):
            ethereal_bridge.connect_systems()
        
        # Set firewall level based on turn
        var firewall_level = "standard"
        if config.starting_turn > 7:
            firewall_level = "divine"
        elif config.starting_turn > 3:
            firewall_level = "enhanced"
        
        if ethereal_bridge.has_method("update_firewall"):
            ethereal_bridge.update_firewall(firewall_level, {
                "dimension_access": config.starting_turn
            })
        
        print("Ethereal Bridge initialized")

func initialize_color_systems():
    if color_system:
        _log("Starting Dimensional Color System")
        
        # Highlight mesh points
        if color_system.has_method("highlight_mesh_centers"):
            color_system.highlight_mesh_centers(5.0)
            color_system.highlight_mesh_edges(5.0)
            color_system.highlight_mesh_corners(5.0)
        
        print("Color System initialized")
    
    if color_animation_system:
        _log("Starting Color Animation System")
        
        # Set enabled state
        if "enabled" in color_animation_system:
            color_animation_system.enabled = true
        
        print("Color Animation System initialized")
    
    if visual_system:
        _log("Starting Visual Indicator System")
        
        # Enable visual system
        if visual_system.has_method("toggle_enabled"):
            visual_system.toggle_enabled()
        
        # Set appropriate mode
        if visual_system.has_method("set_mode"):
            visual_system.set_mode(2)  # Detailed mode
        
        print("Visual System initialized")

func initialize_terminal_interface():
    if terminal_interface:
        _log("Starting Terminal Interface")
        
        print("Terminal Interface initialized")
        
        if terminal_interface.has_method("connect_signals"):
            terminal_interface.connect("terminal_ready", Callable(self, "_on_terminal_ready"))

func initialize_storage_system():
    if storage_system:
        _log("Starting Storage System")
        
        print("Storage System initialized")
        
        if storage_system.has_method("connect_cloud_storage"):
            storage_system.connect("storage_connected", Callable(self, "_on_storage_connected"))

func initialize_keyboard_system():
    if keyboard_system:
        _log("Starting Keyboard Command System")
        
        # Enable command system
        if keyboard_system.has_method("set_command_mode"):
            keyboard_system.set_command_mode(true)
        
        # Enable auto-correction
        if keyboard_system.has_method("set_auto_correction"):
            keyboard_system.set_auto_correction(true)
        
        print("Keyboard System initialized")

# ----- SIGNAL CONNECTIONS -----
func connect_signals():
    # Connect system signals for communication
    
    # Connect Akashic -> Ethereal
    if akashic_system and ethereal_bridge:
        # Connect any relevant signals between these systems
        pass
    
    # Connect Color -> Visual
    if color_system and visual_system:
        if color_system.has_signal("color_frequency_updated") and visual_system.has_method("_on_color_frequency_updated"):
            color_system.connect("color_frequency_updated", Callable(visual_system, "_on_color_frequency_updated"))
        
        if color_system.has_signal("mesh_point_activated") and visual_system.has_method("_on_mesh_point_activated"):
            color_system.connect("mesh_point_activated", Callable(visual_system, "_on_mesh_point_activated"))
    
    # Connect Keyboard -> Other systems
    if keyboard_system:
        if keyboard_system.has_signal("symbol_inserted") and color_system and color_system.has_method("_on_symbol_inserted"):
            keyboard_system.connect("symbol_inserted", Callable(color_system, "_on_symbol_inserted"))
        
        if keyboard_system.has_signal("key_sequence_recognized") and ethereal_bridge and ethereal_bridge.has_method("_on_key_sequence_recognized"):
            keyboard_system.connect("key_sequence_recognized", Callable(ethereal_bridge, "_on_key_sequence_recognized"))
    
    # Connect animation system
    if color_animation_system:
        if color_animation_system.has_signal("color_updated") and visual_system and visual_system.has_method("_on_color_updated"):
            color_animation_system.connect("color_updated", Callable(visual_system, "_on_color_updated"))
        
        if color_animation_system.has_signal("frequency_activated") and ethereal_bridge and ethereal_bridge.has_method("_on_frequency_activated"):
            color_animation_system.connect("frequency_activated", Callable(ethereal_bridge, "_on_frequency_activated"))
    
    # Connect Storage signals
    if storage_system:
        storage_system.connect("storage_connected", Callable(self, "_on_storage_connected"))
        storage_system.connect("wish_created", Callable(self, "_on_wish_created"))
        storage_system.connect("wish_completed", Callable(self, "_on_wish_completed"))
    
    # Connect Akashic Bridge signals
    if ethereal_bridge:
        if ethereal_bridge.has_signal("word_stored"):
            ethereal_bridge.connect("word_stored", Callable(self, "_on_word_stored"))
        
        if ethereal_bridge.has_signal("gate_status_changed"):
            ethereal_bridge.connect("gate_status_changed", Callable(self, "_on_gate_status_changed"))
        
        if ethereal_bridge.has_signal("wish_updated"):
            ethereal_bridge.connect("wish_updated", Callable(self, "_on_wish_updated"))
        
        if ethereal_bridge.has_signal("firewall_breached"):
            ethereal_bridge.connect("firewall_breached", Callable(self, "_on_firewall_breached"))
    
    # Connect Terminal Interface signals
    if terminal_interface:
        if terminal_interface.has_signal("command_executed"):
            terminal_interface.connect("command_executed", Callable(self, "_on_command_executed"))
        
        if terminal_interface.has_signal("wish_processed"):
            terminal_interface.connect("wish_processed", Callable(self, "_on_wish_processed"))
        
        if terminal_interface.has_signal("interface_changed"):
            terminal_interface.connect("interface_changed", Callable(self, "_on_interface_changed"))
        
        if terminal_interface.has_signal("terminal_ready"):
            terminal_interface.connect("terminal_ready", Callable(self, "_on_terminal_ready"))

# ----- INTERFACE MANAGEMENT -----
func set_interface(interface_name):
    match interface_name:
        "terminal":
            print("Setting interface to terminal")
            # In actual implementation, this would show terminal interface
            if terminal_interface and terminal_interface.has_method("activate"):
                terminal_interface.activate()
        "notepad3d":
            print("Setting interface to Notepad 3D")
            # In actual implementation, this would show 3D notepad
        "browser":
            print("Setting interface to browser")
            # In actual implementation, this would show browser interface
        "visual":
            print("Setting interface to visual")
            # In actual implementation, this would show visual interface
            if visual_system and visual_system.has_method("toggle_enabled"):
                visual_system.toggle_enabled()
        _:
            print("Unknown interface: " + interface_name)
    
    emit_signal("interface_ready", interface_name)

# ----- WELCOME MESSAGE -----
func show_welcome():
    var message = "Welcome to the Enhanced 12-Turn System\n"
    message += "Current Turn: " + str(config.starting_turn) + "\n"
    message += "Dimensional Depth: " + str(config.dimensional_depth) + "\n"
    message += "Base Frequency: " + str(config.color_frequency) + "\n"
    
    if terminal_interface and terminal_interface.has_method("print_message"):
        terminal_interface.print_message(message)
    else:
        print(message)
    
    # Highlight welcome in color system
    if color_system and color_system.has_method("start_pulse_animation"):
        color_system.start_pulse_animation(config.color_frequency, 5.0)

# ----- WISH PROCESSING -----
func process_wish(wish_text, priority = "normal", metadata = {}):
    if storage_system:
        var wish = storage_system.create_wish(wish_text, priority, metadata)
        
        if wish and ethereal_bridge and ethereal_bridge.has_method("update_wish"):
            # Update wish in Akashic Records
            ethereal_bridge.update_wish(wish.id, "pending", {
                "text": wish_text,
                "priority": priority,
                "created": Time.get_unix_time_from_system()
            })
        
        return wish
    
    return null

# ----- COMMAND EXECUTION -----
func execute_command(command):
    if terminal_interface and terminal_interface.has_method("process_command"):
        return terminal_interface.process_command(command)
    else:
        print("Terminal interface not available")
        return false

# ----- SIGNAL HANDLERS -----
func _on_storage_connected(platform, status):
    print("Storage connected: " + platform + " - " + str(status))

func _on_wish_created(wish_id, wish_text):
    print("Wish created: " + wish_id + " - " + wish_text)
    
    # Highlight in color system
    if color_animation_system:
        color_animation_system.animate_line(wish_text, "wish_" + wish_id, 1, 5.0)  # Pulse animation

func _on_wish_completed(wish_id):
    print("Wish completed: " + wish_id)

func _on_word_stored(word, power, metadata):
    print("Word stored: " + word + " (power: " + str(power) + ")")
    
    # Highlight in color system
    if color_system and color_system.has_method("start_pulse_animation"):
        var frequency = 99 + (power * 10)  # Scale power to frequency
        frequency = clamp(frequency, 99, 999)
        color_system.start_pulse_animation(frequency, 3.0)

func _on_gate_status_changed(gate_name, status):
    print("Gate status changed: " + gate_name + " - " + str(status))

func _on_wish_updated(wish_id, new_status):
    print("Wish updated: " + wish_id + " -> " + new_status)

func _on_firewall_breached(breach_info):
    print("FIREWALL BREACH: " + breach_info.type + " - " + breach_info.message)
    
    # Flash warning in visual system
    if visual_system and visual_system.has_method("set_mode"):
        visual_system.set_mode(3)  # Symbolic mode (warning)

func _on_command_executed(command, result):
    if config.debug_mode:
        print("Command executed: " + command)
    
    # Highlight command in color system
    if color_animation_system:
        color_animation_system.animate_line(command, "cmd_" + str(Time.get_unix_time_from_system()), 4, 2.0)  # Flash animation

func _on_wish_processed(wish_id, result):
    print("Wish processed: " + wish_id)

func _on_interface_changed(interface_name):
    print("Interface changed to: " + interface_name)

func _on_terminal_ready():
    print("Terminal interface ready")

# ----- TURN MANAGEMENT -----
func change_turn(new_turn):
    var old_turn = config.starting_turn
    config.starting_turn = new_turn
    
    # Update all systems with new turn
    if visual_system and visual_system.has_method("update_turn_indicator"):
        visual_system.update_turn_indicator(new_turn, 12)
    
    if color_animation_system and color_animation_system.has_method("update_turn"):
        color_animation_system.update_turn(new_turn, 12)
    
    if ethereal_bridge and ethereal_bridge.has_method("update_firewall"):
        var firewall_level = "standard"
        if new_turn > 7:
            firewall_level = "divine"
        elif new_turn > 3:
            firewall_level = "enhanced"
        
        ethereal_bridge.update_firewall(firewall_level, {
            "dimension_access": new_turn
        })
    
    print("Turn changed from " + str(old_turn) + " to " + str(new_turn))
    emit_signal("turn_changed", new_turn, old_turn)

# ----- GODOT 4 MIGRATION -----
func run_migration(godot3_path: String, godot4_path: String):
    if migration_tool:
        _log("Starting Godot 4 migration")
        
        # Configure migration
        migration_tool.godot3_project_path = godot3_path
        migration_tool.godot4_project_path = godot4_path
        migration_tool.backup_before_migration = config.migration_backup
        migration_tool.auto_fix_deprecated = true
        migration_tool.migrate_resources = true
        
        # Run migration
        return migration_tool.start_migration()
    else:
        _log("Migration tool not available", true)
        return false

func check_project_compatibility(project_path: String):
    if migration_tool:
        _log("Checking project compatibility")
        return migration_tool.generate_migration_report(project_path)
    else:
        _log("Migration tool not available", true)
        return null

# ----- COLOR SYSTEM CONTROL -----
func highlight_frequency(frequency: int, duration: float = 5.0):
    if color_system and color_system.has_method("start_pulse_animation"):
        _log("Highlighting frequency: " + str(frequency))
        color_system.start_pulse_animation(frequency, duration)
        return true
    return false

func animate_text(text: String, animation_type: int = 0):
    if color_animation_system and color_animation_system.has_method("animate_line"):
        _log("Animating text with " + str(animation_type) + " animation")
        var animation_id = color_animation_system.animate_line(text, "text_" + str(Time.get_unix_time_from_system()), animation_type)
        return animation_id
    return -1

func colorize_text(text: String, frequency: int = 99):
    if color_animation_system and color_animation_system.has_method("colorize_text"):
        return color_animation_system.colorize_text(text, frequency)
    elif color_system and color_system.has_method("colorize_line"):
        return color_system.colorize_line(text, frequency)
    return text

# ----- UTILITY FUNCTIONS -----
func _log(message, is_error = false):
    if config.debug_mode:
        if is_error:
            push_error("EnhancedSystemLauncher: " + message)
        else:
            print("EnhancedSystemLauncher: " + message)

# ----- PUBLIC API -----
func is_system_loaded(system_name):
    return systems_loaded.get(system_name, false)

func get_system_status():
    var status = {
        "akashic_system": akashic_system != null,
        "ethereal_bridge": ethereal_bridge != null,
        "color_system": color_system != null,
        "visual_system": visual_system != null,
        "keyboard_system": keyboard_system != null,
        "migration_tool": migration_tool != null,
        "color_animation_system": color_animation_system != null,
        "terminal_interface": terminal_interface != null,
        "storage_system": storage_system != null,
        "current_turn": config.starting_turn,
        "dimensional_depth": config.dimensional_depth,
        "base_frequency": config.color_frequency
    }
    
    # Add storage status if available
    if storage_system and storage_system.has_method("get_storage_status"):
        status["storage"] = storage_system.get_storage_status()
    
    # Add akashic status if available
    if ethereal_bridge and ethereal_bridge.has_method("get_status"):
        status["akashic"] = ethereal_bridge.get_status()
    
    return status

func create_wish(wish_text, priority = "normal"):
    return process_wish(wish_text, priority)

func run_command(command):
    return execute_command(command)

func connect_cloud_storage(service, credentials = {}):
    if storage_system and storage_system.has_method("connect_cloud_storage"):
        return storage_system.connect_cloud_storage(service, credentials)
    return false