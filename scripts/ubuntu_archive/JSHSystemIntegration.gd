extends Node
class_name JSHSystemIntegration

# This is the main integration node that ties all JSH systems together

# System references
var entity_manager: JSHEntityManager = null
var database_manager: JSHDatabaseManager = null
var spatial_manager: JSHSpatialManager = null
var console_manager: JSHConsoleManager = null

# UI references
var console_ui: JSHConsoleUI = null
var entity_visualizer: JSHEntityVisualizer = null

# Command modules
var command_integration: JSHConsoleCommandIntegration = null

# Configuration
var auto_initialize: bool = true
var debug_mode: bool = false
var config: Dictionary = {
    "db_root_path": "user://jsh_database/",
    "visualizer_enabled": true,
    "auto_save_interval": 30.0,
    "console_key": KEY_QUOTELEFT  # Tilde key
}

# Signal
signal systems_initialized
signal systems_error(error_message)

func _ready() -> void:
    if auto_initialize:
        initialize()

func initialize() -> bool:
    print("JSHSystemIntegration: Initializing systems")
    
    # Initialize managers in dependency order
    _initialize_entity_manager()
    _initialize_database_manager()
    _initialize_spatial_manager()
    _initialize_console_manager()
    
    # Set up UI components
    _initialize_console_ui()
    _initialize_visualizer()
    
    # Connect systems together
    _connect_systems()
    
    print("JSHSystemIntegration: Systems initialized")
    emit_signal("systems_initialized")
    
    return true

# Manager initialization
func _initialize_entity_manager() -> void:
    print("JSHSystemIntegration: Initializing Entity Manager")
    
    # Create entity manager
    entity_manager = JSHEntityManager.get_instance()
    add_child(entity_manager)

func _initialize_database_manager() -> void:
    print("JSHSystemIntegration: Initializing Database Manager")
    
    # Create file system database backend
    var database = JSHFileSystemDatabase.new(config.db_root_path)
    
    # Create file storage adapter
    var file_storage = JSHFileStorageAdapter.new(config.db_root_path)
    
    # Create database manager
    database_manager = JSHDatabaseManager.get_instance()
    add_child(database_manager)
    
    # Initialize database manager
    if not database_manager.initialize(database, file_storage):
        push_error("JSHSystemIntegration: Failed to initialize Database Manager")
        emit_signal("systems_error", "Failed to initialize Database Manager")
        return
    
    # Configure auto-save interval
    database_manager.auto_save_interval = config.get("auto_save_interval", 30.0)

func _initialize_spatial_manager() -> void:
    print("JSHSystemIntegration: Initializing Spatial Manager")
    
    # Create spatial manager
    spatial_manager = JSHSpatialManager.get_instance()
    add_child(spatial_manager)

func _initialize_console_manager() -> void:
    print("JSHSystemIntegration: Initializing Console Manager")
    
    # Create console manager
    console_manager = JSHConsoleManager.get_instance()
    add_child(console_manager)
    
    # Set up command integration
    command_integration = JSHConsoleCommandIntegration.new()
    add_child(command_integration)

# UI initialization
func _initialize_console_ui() -> void:
    print("JSHSystemIntegration: Initializing Console UI")
    
    # Create console UI
    var console_scene = load("res://jsh_console_ui.tscn")
    console_ui = console_scene.instantiate()
    add_child(console_ui)
    
    # Set initial visibility
    console_ui.visible = false

func _initialize_visualizer() -> void:
    if config.get("visualizer_enabled", true):
        print("JSHSystemIntegration: Initializing Entity Visualizer")
        
        # Create entity visualizer
        entity_visualizer = JSHEntityVisualizer.new()
        add_child(entity_visualizer)
        
        # Set initial visibility
        entity_visualizer.visible = false

# System connections
func _connect_systems() -> void:
    print("JSHSystemIntegration: Connecting systems")
    
    # Connect entity manager to database manager
    if entity_manager and database_manager:
        entity_manager.connect("entity_created", Callable(database_manager, "_on_entity_created"))
        entity_manager.connect("entity_updated", Callable(database_manager, "_on_entity_updated"))
        entity_manager.connect("entity_destroyed", Callable(database_manager, "_on_entity_destroyed"))
    
    # Connect entity manager to spatial manager
    if entity_manager and spatial_manager:
        entity_manager.connect("entity_created", Callable(spatial_manager, "_on_entity_created"))
        entity_manager.connect("entity_destroyed", Callable(spatial_manager, "_on_entity_destroyed"))
        entity_manager.connect("entity_updated", Callable(spatial_manager, "_on_entity_updated"))
    
    # Connect console UI to console manager
    if console_ui and console_manager:
        console_manager.connect("console_output_updated", Callable(console_ui, "_on_console_output_updated"))
        console_manager.connect("console_visibility_changed", Callable(console_ui, "_on_console_visibility_changed"))
        console_manager.connect("command_executed", Callable(console_ui, "_on_command_executed"))
    
    # Connect visualizer to console (for visualization commands)
    if entity_visualizer and console_manager:
        # Register visualization commands
        _register_visualization_commands()

# Visualization commands
func _register_visualization_commands() -> void:
    print("JSHSystemIntegration: Registering visualization commands")
    
    console_manager.register_command("visualize", {
        "description": "Entity visualization commands",
        "usage": "visualize <subcommand> [arguments]",
        "callback": Callable(self, "cmd_visualize"),
        "min_args": 1,
        "max_args": -1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Subcommand: entity, zone, mode, options, show, hide"]
    })

# Visualization command handler
func cmd_visualize(self, args: Array) -> Dictionary:
    if not entity_visualizer:
        console_manager.print_error("Entity visualizer not available")
        return {"success": false, "message": "Entity visualizer not available"}
    
    if args.size() < 1:
        console_manager.print_error("Missing subcommand for visualize")
        return {"success": false, "message": "Missing subcommand"}
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcommand:
        "entity":
            return cmd_visualize_entity(self, subargs)
        "zone":
            return cmd_visualize_zone(self, subargs)
        "mode":
            return cmd_visualize_mode(self, subargs)
        "options":
            return cmd_visualize_options(self, subargs)
        "show":
            entity_visualizer.visible = true
            console_manager.print_success("Entity visualizer shown")
            return {"success": true, "message": "Entity visualizer shown"}
        "hide":
            entity_visualizer.visible = false
            console_manager.print_success("Entity visualizer hidden")
            return {"success": true, "message": "Entity visualizer hidden"}
        _:
            console_manager.print_error("Unknown visualize subcommand: " + subcommand)
            console_manager.print_line("Available subcommands: entity, zone, mode, options, show, hide")
            return {"success": false, "message": "Unknown subcommand: " + subcommand}

# Visualization subcommands
func cmd_visualize_entity(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Entity ID required")
        return {"success": false, "message": "Entity ID required"}
    
    var entity_id = args[0]
    
    # Find entity with ID or partial ID
    var full_id = entity_id
    if entity_id.length() < 32:  # Not a full ID, try to find matching entity
        for id in entity_manager.entities:
            if id.begins_with(entity_id):
                full_id = id
                break
    
    # Show visualization and focus on entity
    entity_visualizer.visible = true
    entity_visualizer.set_focus_entity(full_id)
    
    console_manager.print_success("Visualizing entity " + full_id)
    return {
        "success": true,
        "message": "Visualizing entity",
        "entity_id": full_id
    }

func cmd_visualize_zone(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Zone ID required")
        return {"success": false, "message": "Zone ID required"}
    
    var zone_id = args[0]
    
    # Show visualization and focus on zone
    entity_visualizer.visible = true
    entity_visualizer.set_focus_zone(zone_id)
    
    console_manager.print_success("Visualizing entities in zone " + zone_id)
    return {
        "success": true,
        "message": "Visualizing zone",
        "zone_id": zone_id
    }

func cmd_visualize_mode(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Mode required (graph, spatial, hierarchy)")
        return {"success": false, "message": "Mode required"}
    
    var mode = args[0].to_lower()
    
    if mode in ["graph", "spatial", "hierarchy"]:
        entity_visualizer.set_mode(mode)
        console_manager.print_success("Visualization mode set to: " + mode)
        return {
            "success": true,
            "message": "Visualization mode set",
            "mode": mode
        }
    else:
        console_manager.print_error("Invalid mode: " + mode)
        console_manager.print_line("Valid modes: graph, spatial, hierarchy")
        return {"success": false, "message": "Invalid mode"}

func cmd_visualize_options(self, args: Array) -> Dictionary:
    var updated = false
    
    for arg in args:
        var option = arg.split("=")
        if option.size() == 2:
            var key = option[0]
            var value = option[1].to_lower() == "true"
            
            match key:
                "labels":
                    entity_visualizer.show_labels = value
                    updated = true
                "types":
                    entity_visualizer.show_types = value
                    updated = true
                "properties":
                    entity_visualizer.show_properties = value
                    updated = true
                "connections":
                    entity_visualizer.show_connections = value
                    updated = true
    
    if updated:
        entity_visualizer.queue_redraw()
        console_manager.print_success("Visualization options updated")
        return {
            "success": true,
            "message": "Visualization options updated",
            "options": {
                "labels": entity_visualizer.show_labels,
                "types": entity_visualizer.show_types,
                "properties": entity_visualizer.show_properties,
                "connections": entity_visualizer.show_connections
            }
        }
    else:
        console_manager.print_error("No valid options provided")
        console_manager.print_line("Valid options: labels=true/false, types=true/false, properties=true/false, connections=true/false")
        return {"success": false, "message": "No valid options provided"}

# Input handling for global shortcuts
func _input(event: InputEvent) -> void:
    # Toggle console with configured key
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == config.get("console_key", KEY_QUOTELEFT):
            if console_ui:
                console_ui.toggle_visibility()

# System shutdown
func shutdown() -> void:
    print("JSHSystemIntegration: Shutting down systems")
    
    # Save all pending entities
    if database_manager:
        database_manager.save_pending_entities()
    
    # Shutdown components in reverse order
    if console_ui:
        console_ui.queue_free()
    
    if entity_visualizer:
        entity_visualizer.queue_free()
    
    # Managers will be cleaned up by the scene tree

# Full system reset
func reset() -> void:
    print("JSHSystemIntegration: Resetting all systems")
    
    # Shutdown
    shutdown()
    
    # Clear all children
    for child in get_children():
        child.queue_free()
    
    # Reinitialize
    call_deferred("initialize")