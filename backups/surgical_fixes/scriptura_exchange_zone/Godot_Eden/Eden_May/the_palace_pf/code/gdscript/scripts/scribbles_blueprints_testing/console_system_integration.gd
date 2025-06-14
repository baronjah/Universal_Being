extends Node
class_name JSHConsoleSystemIntegration

# This script serves as a bridge between the JSH Console System and the existing
# Akashic Records and Ethereal Engine systems.

# System references
var console_manager: JSHConsoleManager = null
var entity_manager: JSHEntityManager = null
var database_manager: JSHDatabaseManager = null
var spatial_manager: JSHSpatialManager = null

# Existing system references
var akashic_records_manager = null
var universal_bridge = null
var zone_manager = null
var thing_creator = null

# Integration components
var akashic_adapter = null
var ethereal_adapter = null
var ui_adapter = null

func _init() -> void:
    # Get JSH system instances
    console_manager = JSHConsoleManager.get_instance()
    entity_manager = JSHEntityManager.get_instance()
    database_manager = JSHDatabaseManager.get_instance()
    spatial_manager = JSHSpatialManager.get_instance()

func _ready() -> void:
    # Get existing system references - adjust paths as needed
    akashic_records_manager = get_node_or_null("/root/AkashicRecordsManager")
    universal_bridge = get_node_or_null("/root/UniversalBridge")
    zone_manager = get_node_or_null("/root/ZoneManager")
    thing_creator = get_node_or_null("/root/ThingCreator")
    
    # Create adapters for each system
    _create_adapters()
    
    # Register integration commands
    _register_integration_commands()

func _create_adapters() -> void:
    # Create adapters for existing systems
    akashic_adapter = _create_akashic_adapter()
    ethereal_adapter = _create_ethereal_adapter()
    ui_adapter = _create_ui_adapter()

# Akashic Records integration
func _create_akashic_adapter():
    # Create adapter class to bridge between JSH Entity system and Akashic Records
    var adapter = AkashicRecordsAdapter.new()
    adapter.akashic_records_manager = akashic_records_manager
    adapter.entity_manager = entity_manager
    adapter.universal_bridge = universal_bridge
    
    # Connect signals
    if akashic_records_manager and akashic_records_manager.has_signal("entity_created"):
        akashic_records_manager.connect("entity_created", Callable(adapter, "_on_akashic_entity_created"))
    
    if entity_manager and entity_manager.has_signal("entity_created"):
        entity_manager.connect("entity_created", Callable(adapter, "_on_jsh_entity_created"))
    
    return adapter

# Ethereal Engine integration
func _create_ethereal_adapter():
    # Create adapter class to bridge between JSH Spatial system and Ethereal Engine
    var adapter = EtherealEngineAdapter.new()
    adapter.zone_manager = zone_manager
    adapter.spatial_manager = spatial_manager
    
    # Connect signals
    if zone_manager and zone_manager.has_signal("zone_created"):
        zone_manager.connect("zone_created", Callable(adapter, "_on_zone_created"))
    
    if spatial_manager and spatial_manager.has_signal("zone_created"):
        spatial_manager.connect("zone_created", Callable(adapter, "_on_jsh_zone_created"))
    
    return adapter

# UI integration
func _create_ui_adapter():
    # Create adapter for UI integration
    var adapter = UIAdapter.new()
    adapter.console_manager = console_manager
    
    # Set up keyboard handling
    # Add console UI to scene if not already present
    var console_ui = get_node_or_null("/root/JSHConsoleUI")
    if not console_ui:
        var console_scene = load("res://jsh_console_ui.tscn")
        if console_scene:
            console_ui = console_scene.instantiate()
            add_child(console_ui)
    
    return adapter

# Register integration commands
func _register_integration_commands() -> void:
    # Register Akashic Records commands
    console_manager.register_command("akashic", {
        "description": "Akashic Records commands",
        "usage": "akashic <subcommand> [arguments]",
        "callback": Callable(self, "_cmd_akashic"),
        "min_args": 1,
        "max_args": -1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Subcommand: info, status, create, find, query"]
    })
    
    # Register Ethereal Engine commands
    console_manager.register_command("ethereal", {
        "description": "Ethereal Engine commands",
        "usage": "ethereal <subcommand> [arguments]",
        "callback": Callable(self, "_cmd_ethereal"),
        "min_args": 1,
        "max_args": -1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Subcommand: info, status, zone, element, voxel"]
    })
    
    # Register integration commands
    console_manager.register_command("integrate", {
        "description": "Integration commands",
        "usage": "integrate <subcommand> [arguments]",
        "callback": Callable(self, "_cmd_integrate"),
        "min_args": 1,
        "max_args": -1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Subcommand: status, sync, convert"]
    })

# Command handlers
func _cmd_akashic(self, args: Array) -> Dictionary:
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcommand:
        "info":
            return _cmd_akashic_info(self, subargs)
        "status":
            return _cmd_akashic_status(self, subargs)
        "create":
            return _cmd_akashic_create(self, subargs)
        "find":
            return _cmd_akashic_find(self, subargs)
        "query":
            return _cmd_akashic_query(self, subargs)
        _:
            console_manager.print_error("Unknown akashic subcommand: " + subcommand)
            console_manager.print_line("Available subcommands: info, status, create, find, query")
            return {"success": false, "message": "Unknown subcommand: " + subcommand}

func _cmd_akashic_info(self, args: Array) -> Dictionary:
    console_manager.print_line("Akashic Records System", Color(0.2, 0.7, 1.0))
    console_manager.print_line("====================", Color(0.2, 0.7, 1.0))
    
    if akashic_records_manager:
        console_manager.print_line("\nSystem Information:")
        console_manager.print_line("  Status: Active")
        
        # Pull information from the actual system if methods exist
        if akashic_records_manager.has_method("get_entity_count"):
            console_manager.print_line("  Entity Count: " + str(akashic_records_manager.get_entity_count()))
        
        if akashic_records_manager.has_method("get_dictionary_count"):
            console_manager.print_line("  Dictionary Count: " + str(akashic_records_manager.get_dictionary_count()))
        
        console_manager.print_line("\nIntegration Status:")
        console_manager.print_line("  Adapter: " + ("Active" if akashic_adapter else "Inactive"))
        console_manager.print_line("  Entity Sync: " + ("Enabled" if akashic_adapter and akashic_adapter.sync_enabled else "Disabled"))
    else:
        console_manager.print_error("Akashic Records Manager not found in the scene")
    
    return {
        "success": true,
        "message": "Akashic Records information displayed"
    }

func _cmd_akashic_status(self, args: Array) -> Dictionary:
    # Similar to info but with more operational details
    return {"success": true, "message": "Status command not fully implemented yet"}

func _cmd_akashic_create(self, args: Array) -> Dictionary:
    if args.size() < 2:
        console_manager.print_error("Usage: akashic create <type> <name> [properties...]")
        return {"success": false, "message": "Invalid arguments"}
    
    var entity_type = args[0]
    var entity_name = args[1]
    
    # Parse properties
    var properties = {}
    for i in range(2, args.size()):
        var prop = args[i].split("=")
        if prop.size() == 2:
            var key = prop[0]
            var value = prop[1]
            
            # Convert to appropriate type
            if value.to_lower() == "true":
                value = true
            elif value.to_lower() == "false":
                value = false
            elif value.is_valid_int():
                value = int(value)
            elif value.is_valid_float():
                value = float(value)
            
            properties[key] = value
    
    # Use adapter to create entity in Akashic Records
    if akashic_adapter and akashic_adapter.has_method("create_entity"):
        var result = akashic_adapter.create_entity(entity_type, entity_name, properties)
        
        if result.success:
            console_manager.print_success("Entity created in Akashic Records: " + result.entity_id)
        else:
            console_manager.print_error("Failed to create entity: " + result.message)
        
        return result
    else:
        console_manager.print_error("Akashic Records adapter not available")
        return {"success": false, "message": "Adapter not available"}

func _cmd_akashic_find(self, args: Array) -> Dictionary:
    # Implementation of entity search in Akashic Records
    return {"success": true, "message": "Find command not fully implemented yet"}

func _cmd_akashic_query(self, args: Array) -> Dictionary:
    # Implementation of complex queries in Akashic Records
    return {"success": true, "message": "Query command not fully implemented yet"}

func _cmd_ethereal(self, args: Array) -> Dictionary:
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcommand:
        "info":
            return _cmd_ethereal_info(self, subargs)
        "status":
            return _cmd_ethereal_status(self, subargs)
        "zone":
            return _cmd_ethereal_zone(self, subargs)
        "element":
            return _cmd_ethereal_element(self, subargs)
        "voxel":
            return _cmd_ethereal_voxel(self, subargs)
        _:
            console_manager.print_error("Unknown ethereal subcommand: " + subcommand)
            console_manager.print_line("Available subcommands: info, status, zone, element, voxel")
            return {"success": false, "message": "Unknown subcommand: " + subcommand}

func _cmd_ethereal_info(self, args: Array) -> Dictionary:
    console_manager.print_line("Ethereal Engine System", Color(0.2, 0.7, 1.0))
    console_manager.print_line("====================", Color(0.2, 0.7, 1.0))
    
    if zone_manager:
        console_manager.print_line("\nZone Manager Information:")
        console_manager.print_line("  Status: Active")
        
        # Pull information from the actual system if methods exist
        if zone_manager.has_method("get_zone_count"):
            console_manager.print_line("  Zone Count: " + str(zone_manager.get_zone_count()))
    else:
        console_manager.print_error("Zone Manager not found in the scene")
    
    console_manager.print_line("\nIntegration Status:")
    console_manager.print_line("  Adapter: " + ("Active" if ethereal_adapter else "Inactive"))
    console_manager.print_line("  Zone Sync: " + ("Enabled" if ethereal_adapter and ethereal_adapter.sync_enabled else "Disabled"))
    
    return {
        "success": true,
        "message": "Ethereal Engine information displayed"
    }

func _cmd_ethereal_status(self, args: Array) -> Dictionary:
    # Similar to info but with more operational details
    return {"success": true, "message": "Status command not fully implemented yet"}

func _cmd_ethereal_zone(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Usage: ethereal zone <operation> [arguments]")
        console_manager.print_line("Operations: create, load, unload, list, find")
        return {"success": false, "message": "Invalid arguments"}
    
    var operation = args[0].to_lower()
    var op_args = args.slice(1)
    
    match operation:
        "create":
            # Implementation of zone creation
            return {"success": true, "message": "Zone creation not fully implemented yet"}
        "load":
            # Implementation of zone loading
            return {"success": true, "message": "Zone loading not fully implemented yet"}
        "unload":
            # Implementation of zone unloading
            return {"success": true, "message": "Zone unloading not fully implemented yet"}
        "list":
            # Implementation of zone listing
            return {"success": true, "message": "Zone listing not fully implemented yet"}
        "find":
            # Implementation of zone finding
            return {"success": true, "message": "Zone finding not fully implemented yet"}
        _:
            console_manager.print_error("Unknown zone operation: " + operation)
            return {"success": false, "message": "Unknown operation"}

func _cmd_ethereal_element(self, args: Array) -> Dictionary:
    # Implementation of element commands
    return {"success": true, "message": "Element command not fully implemented yet"}

func _cmd_ethereal_voxel(self, args: Array) -> Dictionary:
    # Implementation of voxel commands
    return {"success": true, "message": "Voxel command not fully implemented yet"}

func _cmd_integrate(self, args: Array) -> Dictionary:
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcommand:
        "status":
            return _cmd_integrate_status(self, subargs)
        "sync":
            return _cmd_integrate_sync(self, subargs)
        "convert":
            return _cmd_integrate_convert(self, subargs)
        _:
            console_manager.print_error("Unknown integrate subcommand: " + subcommand)
            console_manager.print_line("Available subcommands: status, sync, convert")
            return {"success": false, "message": "Unknown subcommand: " + subcommand}

func _cmd_integrate_status(self, args: Array) -> Dictionary:
    console_manager.print_line("Integration Status", Color(0.2, 0.7, 1.0))
    console_manager.print_line("=================", Color(0.2, 0.7, 1.0))
    
    console_manager.print_line("\nSystem Availability:")
    console_manager.print_line("  Akashic Records: " + ("Available" if akashic_records_manager else "Not Available"))
    console_manager.print_line("  Universal Bridge: " + ("Available" if universal_bridge else "Not Available"))
    console_manager.print_line("  Zone Manager: " + ("Available" if zone_manager else "Not Available"))
    console_manager.print_line("  Thing Creator: " + ("Available" if thing_creator else "Not Available"))
    
    console_manager.print_line("\nJSH Systems:")
    console_manager.print_line("  Entity Manager: " + ("Active" if entity_manager else "Inactive"))
    console_manager.print_line("  Database Manager: " + ("Active" if database_manager else "Inactive"))
    console_manager.print_line("  Spatial Manager: " + ("Active" if spatial_manager else "Inactive"))
    console_manager.print_line("  Console Manager: " + ("Active" if console_manager else "Inactive"))
    
    console_manager.print_line("\nAdapters:")
    console_manager.print_line("  Akashic Adapter: " + ("Active" if akashic_adapter else "Inactive"))
    console_manager.print_line("  Ethereal Adapter: " + ("Active" if ethereal_adapter else "Inactive"))
    console_manager.print_line("  UI Adapter: " + ("Active" if ui_adapter else "Inactive"))
    
    return {
        "success": true,
        "message": "Integration status displayed"
    }

func _cmd_integrate_sync(self, args: Array) -> Dictionary:
    if args.size() < 2:
        console_manager.print_error("Usage: integrate sync <system> <enable|disable>")
        console_manager.print_line("Systems: akashic, ethereal, all")
        return {"success": false, "message": "Invalid arguments"}
    
    var system = args[0].to_lower()
    var enable = args[1].to_lower() == "enable" or args[1].to_lower() == "true" or args[1].to_lower() == "on"
    
    match system:
        "akashic":
            if akashic_adapter:
                akashic_adapter.sync_enabled = enable
                console_manager.print_success("Akashic Records sync " + ("enabled" if enable else "disabled"))
            else:
                console_manager.print_error("Akashic adapter not available")
        
        "ethereal":
            if ethereal_adapter:
                ethereal_adapter.sync_enabled = enable
                console_manager.print_success("Ethereal Engine sync " + ("enabled" if enable else "disabled"))
            else:
                console_manager.print_error("Ethereal adapter not available")
        
        "all":
            if akashic_adapter:
                akashic_adapter.sync_enabled = enable
            
            if ethereal_adapter:
                ethereal_adapter.sync_enabled = enable
            
            console_manager.print_success("All system sync " + ("enabled" if enable else "disabled"))
        
        _:
            console_manager.print_error("Unknown system: " + system)
            return {"success": false, "message": "Unknown system"}
    
    return {
        "success": true,
        "message": "Sync " + ("enabled" if enable else "disabled") + " for " + system
    }

func _cmd_integrate_convert(self, args: Array) -> Dictionary:
    if args.size() < 2:
        console_manager.print_error("Usage: integrate convert <source> <target> [id]")
        console_manager.print_line("Sources/Targets: akashic, jsh, ethereal")
        return {"success": false, "message": "Invalid arguments"}
    
    var source = args[0].to_lower()
    var target = args[1].to_lower()
    var id = args[2] if args.size() > 2 else ""
    
    console_manager.print_line("Converting from " + source + " to " + target + (": " + id if not id.is_empty() else ""))
    
    # Implementation would depend on the specific conversion logic
    
    return {
        "success": true,
        "message": "Convert command not fully implemented yet"
    }

# Adapter classes
class AkashicRecordsAdapter:
    var akashic_records_manager = null
    var entity_manager = null
    var universal_bridge = null
    var sync_enabled = true
    
    func create_entity(entity_type: String, entity_name: String, properties: Dictionary = {}):
        if not akashic_records_manager:
            return {"success": false, "message": "Akashic Records Manager not available"}
        
        # Call appropriate method on Akashic Records Manager
        var entity = null
        
        if akashic_records_manager.has_method("create_entity"):
            entity = akashic_records_manager.create_entity(entity_type, properties)
        elif akashic_records_manager.has_method("create"):
            entity = akashic_records_manager.create(entity_type, properties)
        
        if entity:
            return {
                "success": true,
                "message": "Entity created successfully",
                "entity_id": entity.id if entity.has("id") else "",
                "entity": entity
            }
        else:
            return {"success": false, "message": "Failed to create entity"}
    
    func _on_akashic_entity_created(entity):
        if not sync_enabled:
            return
        
        # Create corresponding JSH entity
        var jsh_entity = entity_manager.create_entity(
            entity.type if entity.has("type") else "unknown",
            entity.properties if entity.has("properties") else {}
        )
        
        # Store reference to Akashic ID
        if jsh_entity and entity.has("id"):
            jsh_entity.set_property("akashic_id", entity.id)

    func _on_jsh_entity_created(entity):
        if not sync_enabled:
            return
        
        # Create corresponding Akashic entity
        if akashic_records_manager and akashic_records_manager.has_method("create_entity"):
            var properties = entity.get_all_properties()
            var akashic_entity = akashic_records_manager.create_entity(entity.get_type(), properties)
            
            # Store reference to JSH ID
            if akashic_entity and akashic_entity.has("id"):
                entity.set_property("akashic_id", akashic_entity.id)

class EtherealEngineAdapter:
    var zone_manager = null
    var spatial_manager = null
    var sync_enabled = true
    
    func _on_zone_created(zone_id, zone_data):
        if not sync_enabled:
            return
        
        # Create corresponding JSH zone
        spatial_manager.create_zone(zone_id, zone_data)
    
    func _on_jsh_zone_created(zone_id, zone_data):
        if not sync_enabled:
            return
        
        # Create corresponding Ethereal zone
        if zone_manager and zone_manager.has_method("create_zone"):
            zone_manager.create_zone(zone_id, zone_data)

class UIAdapter:
    var console_manager = null
    
    func _ready():
        # Set up input handling
        # Typically this would be done in the JSHConsoleUI directly
        pass