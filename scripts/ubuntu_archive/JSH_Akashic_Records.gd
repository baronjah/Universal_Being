extends Node
class_name JSH_AkashicRecords

# System references
var jsh_records_system: Node = null
var jsh_data_splitter: Node = null
var jsh_database_system: Node = null
var akashic_records_manager: Node = null
var universal_bridge: Node = null
var database_integrator: Node = null
var thing_creator: Node = null

# Debug UI
var debug_ui: Control = null
var debug_ui_visible: bool = false

# Signals
signal system_initialized
signal entity_created(entity)
signal entity_transformed(entity, old_type, new_type)
signal entity_interaction(entity1, entity2, result)
signal database_split(file_path, new_files)

func _ready() -> void:
    print("JSH_AkashicRecords: Initializing...")
    # First, try to find existing JSH systems in the scene
    find_existing_systems()
    # Then initialize our components
    initialize()
    # Add keyboard shortcut to toggle debug UI (F3)
    set_process_input(true)

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_F3:
            toggle_debug_ui()

# Register commands with JSH console
func register_console_commands(jsh_console) -> void:
    print("JSH_AkashicRecords: Registering console commands...")

    if jsh_console == null:
        print("JSH_AkashicRecords: No console to register commands with")
        return

    # Define commands for the Akashic Records system
    var commands = [
        {
            "name": "akashic_create",
            "description": "Create a new entity",
            "callback": Callable(self, "cmd_create_entity")
        },
        {
            "name": "akashic_list",
            "description": "List entities by type",
            "callback": Callable(self, "cmd_list_entities")
        },
        {
            "name": "akashic_info",
            "description": "Get information about an entity",
            "callback": Callable(self, "cmd_entity_info")
        },
        {
            "name": "akashic_transform",
            "description": "Transform an entity to a new type",
            "callback": Callable(self, "cmd_transform_entity")
        },
        {
            "name": "akashic_interact",
            "description": "Make two entities interact",
            "callback": Callable(self, "cmd_interact_entities")
        }
    ]

    # Register the commands
    for cmd in commands:
        var method_name = "register_command"
        var method_info = jsh_console.get_method_list().filter(func(m): return m.name == method_name)

        if method_info.size() > 0 and method_info[0].args.size() >= 3:
            if method_info[0].args[1].type == TYPE_OBJECT:
                # If it expects an object for description, wrap it in a Label
                var desc_label = Label.new()
                desc_label.text = cmd["description"]
                jsh_console.call("register_command", cmd["name"], desc_label, cmd["callback"])
            else:
                # Otherwise pass the description as a string
                jsh_console.call("register_command", cmd["name"], cmd["description"], cmd["callback"])
        else:
            # Fallback to alternative registration method
            jsh_console.call("add_command", cmd["name"], cmd["description"], cmd["callback"])

    print("Console commands registered")

func find_existing_systems() -> void:
    print("JSH_AkashicRecords: Looking for existing JSH systems...")

    # Try to find systems in the scene tree
    var tree = get_tree()
    if tree == null:
        print("JSH_AkashicRecords: Tree not available yet, will look for systems later")
        call_deferred("find_existing_systems")
        return

    # Look for nodes in the jsh_systems group
    var jsh_systems = tree.get_nodes_in_group("jsh_systems")
    for system in jsh_systems:
        if system.name.begins_with("JSH_records_system"):
            jsh_records_system = system
            print("Found JSH records system: ", system.name)
        elif system.name.begins_with("JSH_data_splitter"):
            jsh_data_splitter = system
            print("Found JSH data splitter: ", system.name)
        elif system.name.begins_with("JSH_database_system"):
            jsh_database_system = system
            print("Found JSH database system: ", system.name)

    # If we didn't find the systems in the group, try with known paths
    if jsh_records_system == null and tree.root != null:
        var node = tree.root.find_node("JSH_records_system", true, false)
        if node:
            jsh_records_system = node
            print("Found JSH records system by path: ", node.name)

    if jsh_data_splitter == null and tree.root != null:
        var node = tree.root.find_node("JSH_data_splitter", true, false)
        if node:
            jsh_data_splitter = node
            print("Found JSH data splitter by path: ", node.name)

    if jsh_database_system == null and tree.root != null:
        var node = tree.root.find_node("JSH_database_system", true, false)
        if node:
            jsh_database_system = node
            print("Found JSH database system by path: ", node.name)

    print("JSH_AkashicRecords: System finding completed")

func initialize() -> void:
    print("JSH_AkashicRecords: Setting up systems...")

    # Create placeholder systems if they weren't found in the scene
    if jsh_records_system == null:
        _initialize_records_system()
    if jsh_database_system == null:
        _initialize_database_system()
    if jsh_data_splitter == null:
        _initialize_data_splitter()

    # Initialize Akashic Records components
    _initialize_akashic_records_manager()
    _initialize_thing_creator()
    _initialize_universal_bridge()
    _initialize_database_integrator()

    # Initialize debug UI
    _initialize_debug_ui()

    # Skip demo entries for now to avoid errors
    print("Skipping demo entries creation while fixing initialization issues")

    emit_signal("system_initialized")
    print("JSH_AkashicRecords: Initialization complete!")

func _initialize_records_system() -> void:
    print("JSH_AkashicRecords: Initializing records system...")
    # In a real implementation, you would get reference to your existing systems
    # For now, creating a placeholder
    jsh_records_system = Node.new()
    jsh_records_system.name = "JSH_RecordsSystem"
    add_child(jsh_records_system)
    print("Records system initialized")

func _initialize_database_system() -> void:
    print("JSH_AkashicRecords: Initializing database system...")
    # In a real implementation, you would get reference to your existing systems
    # For now, creating a placeholder
    jsh_database_system = Node.new()
    jsh_database_system.name = "JSH_DatabaseSystem"
    add_child(jsh_database_system)
    print("Database system initialized")

func _initialize_data_splitter() -> void:
    print("JSH_AkashicRecords: Initializing data splitter...")
    # In a real implementation, you would get reference to your existing systems
    # For now, creating a placeholder
    jsh_data_splitter = Node.new()
    jsh_data_splitter.name = "JSH_DataSplitter"
    add_child(jsh_data_splitter)
    print("Data splitter initialized")

func _initialize_akashic_records_manager() -> void:
    print("JSH_AkashicRecords: Initializing records manager...")

    # Initialize Akashic Records Manager safely
    # Try to use get_instance() if available
    if ClassDB.class_exists("AkashicRecordsManagerA"):
        var script = load("res://akashic_records_manager.gd")
        if script and script.has_method("get_instance"):
            akashic_records_manager = script.call("get_instance")
            print("Akashic records manager instance obtained")

            # Call initialize if available
            if akashic_records_manager.has_method("initialize"):
                akashic_records_manager.call("initialize", jsh_records_system, jsh_database_system)
                print("Akashic records manager initialized with parameters")
        else:
            # Create an instance directly if get_instance isn't available
            akashic_records_manager = AkashicRecordsManagerA.new()
            add_child(akashic_records_manager)

            # Initialize directly
            if akashic_records_manager.has_method("initialize"):
                akashic_records_manager.initialize(jsh_records_system, jsh_database_system)
                print("Akashic records manager initialized directly")
    else:
        print("WARNING: AkashicRecordsManagerA class not found")

    # Make sure the manager is marked as initialized
    if akashic_records_manager != null:
        akashic_records_manager.is_initialized = true

    print("Records manager initialized")

func _initialize_thing_creator() -> void:
    print("JSH_AkashicRecords: Initializing thing creator...")

    # Initialize Thing Creator safely
    # Try to use get_instance() if available
    if ClassDB.class_exists("ThingCreatorA"):
        var script = load("res://thing_creator.gd")
        if script and script.has_method("get_instance"):
            thing_creator = script.call("get_instance")
            print("Thing creator instance obtained")
        else:
            # Create an instance directly if get_instance isn't available
            thing_creator = ThingCreatorA.new()
            add_child(thing_creator)
            print("Thing creator created directly")
    else:
        print("WARNING: ThingCreatorA class not found")

    print("Thing creator initialized")

func _initialize_universal_bridge() -> void:
    print("JSH_AkashicRecords: Initializing universal bridge...")
    # Load and instance the UniversalBridge class
    var UniversalBridge = load("res://universal_bridge.gd")
    universal_bridge = UniversalBridge.new()
    universal_bridge.name = "UniversalBridge"
    add_child(universal_bridge)
    
    # Initialize with system references
    universal_bridge.initialize(
        akashic_records_manager,
        jsh_records_system,
        jsh_database_system
    )

    # Connect new systems to each other
    universal_bridge.akashic_records_manager = akashic_records_manager
    universal_bridge.thing_creator = thing_creator
    
    # Connect signals
    universal_bridge.connect("entity_created", Callable(self, "_on_entity_created"))
    universal_bridge.connect("entity_transformed", Callable(self, "_on_entity_transformed"))
    universal_bridge.connect("entity_interaction", Callable(self, "_on_entity_interaction"))
    
    print("Universal bridge initialized")

func _initialize_database_integrator() -> void:
    print("JSH_AkashicRecords: Initializing database integrator...")
    
    # Load and instance the AkashicDatabaseIntegrator class
    var AkashicDatabaseIntegrator = load("res://database_integrator.gd")
    database_integrator = AkashicDatabaseIntegrator.new()
    database_integrator.name = "DatabaseIntegrator"
    add_child(database_integrator)
    
    # Initialize with system references
    database_integrator.initialize(
        akashic_records_manager,
        jsh_data_splitter,
        jsh_records_system,
        jsh_database_system
    )
    
    # Connect signals
    database_integrator.connect("database_split", Callable(self, "_on_database_split"))
    
    print("Database integrator initialized")

func _initialize_debug_ui() -> void:
    print("JSH_AkashicRecords: Initializing debug UI...")
    
    # Load and instance the DebugUI class
    var DebugUI = load("res://debug_ui.gd")
    debug_ui = DebugUI.new()
    debug_ui.name = "DebugUI"
    add_child(debug_ui)
    
    # Initialize with system references
    debug_ui.initialize(
        self,
        universal_bridge,
        akashic_records_manager,
        database_integrator
    )
    
    # Hide initially
    debug_ui.visible = false
    debug_ui_visible = false
    
    print("Debug UI initialized")

func toggle_debug_ui() -> void:
    debug_ui_visible = !debug_ui_visible
    debug_ui.visible = debug_ui_visible
    print("Debug UI visibility: ", debug_ui_visible)

# Signal handlers
func _on_entity_created(entity) -> void:
    print("Entity created: ", entity.get_id())
    emit_signal("entity_created", entity)

func _on_entity_transformed(entity, old_type, new_type) -> void:
    print("Entity transformed: ", entity.get_id(), " from ", old_type, " to ", new_type)
    emit_signal("entity_transformed", entity, old_type, new_type)

func _on_entity_interaction(entity1, entity2, result) -> void:
    print("Entity interaction: ", entity1.get_id(), " + ", entity2.get_id(), " = ", result)
    emit_signal("entity_interaction", entity1, entity2, result)

func _on_database_split(file_path, new_files) -> void:
    print("Database split: ", file_path, " into ", new_files)
    emit_signal("database_split", file_path, new_files)

# Public API
func create_entity(type: String = "primordial", properties: Dictionary = {}) -> Node:
    if universal_bridge != null:
        return universal_bridge.create_entity(type, properties)
    return null

func transform_entity(entity: Node, new_type: String) -> bool:
    if universal_bridge != null:
        return universal_bridge.transform_entity(entity, new_type)
    return false

func process_interaction(entity1: Node, entity2: Node) -> Dictionary:
    if universal_bridge != null:
        return universal_bridge.process_interaction(entity1, entity2)
    return {}

func get_entity_by_id(entity_id: String) -> Node:
    if akashic_records_manager != null:
        return akashic_records_manager.get_entity_by_id(entity_id)
    return null

func get_entities_by_type(type: String) -> Array:
    if akashic_records_manager != null:
        return akashic_records_manager.get_entities_by_type(type)
    return []

func get_database_files() -> Array:
    if database_integrator != null:
        return database_integrator.get_database_files()
    return []

func trigger_database_check() -> void:
    if database_integrator != null:
        database_integrator.check_database_sizes()

# Console command handlers
func cmd_create_entity(args: Array) -> String:
    if args.size() < 1:
        return "Usage: akashic_create <type> [property1=value1] [property2=value2] ..."

    var type = args[0]
    var properties = {}

    # Parse properties from arguments
    for i in range(1, args.size()):
        var arg = args[i]
        var parts = arg.split("=")
        if parts.size() == 2:
            properties[parts[0]] = parts[1]

    # Create the entity
    var entity = create_entity(type, properties)
    if entity != null:
        return "Created entity of type " + type + " with ID: " + entity.get_id()
    else:
        return "Failed to create entity"

func cmd_list_entities(args: Array) -> String:
    var type = "all"
    if args.size() > 0:
        type = args[0]

    var result = ""

    if type == "all":
        # List all entity types and counts
        var all_types = []
        if akashic_records_manager != null:
            all_types = akashic_records_manager.get_all_entity_types()

        if all_types.size() == 0:
            return "No entities found"

        result = "Entity types:\n"
        for entity_type in all_types:
            var count = akashic_records_manager.get_entity_count_by_type(entity_type)
            result += "- " + entity_type + ": " + str(count) + " entities\n"
    else:
        # List entities of specific type
        var entities = []
        if akashic_records_manager != null:
            entities = akashic_records_manager.get_entities_by_type(type)

        if entities.size() == 0:
            return "No entities found of type: " + type

        result = "Entities of type '" + type + "':\n"
        for entity in entities:
            result += "- " + entity.get_id() + "\n"

    return result

func cmd_entity_info(args: Array) -> String:
    if args.size() < 1:
        return "Usage: akashic_info <entity_id>"

    var entity_id = args[0]
    var entity = get_entity_by_id(entity_id)

    if entity == null:
        return "Entity not found: " + entity_id

    var result = "Entity Info:\n"
    result += "ID: " + entity.get_id() + "\n"
    result += "Type: " + entity.get_type() + "\n"
    result += "Created: " + entity.get_creation_timestamp() + "\n"

    # List properties
    var properties = entity.get_properties()
    if properties.size() > 0:
        result += "Properties:\n"
        for key in properties.keys():
            result += "- " + key + ": " + str(properties[key]) + "\n"
    else:
        result += "No properties\n"

    # List transformations
    var transformations = entity.get_transformation_history()
    if transformations.size() > 0:
        result += "Transformation History:\n"
        for t in transformations:
            result += "- " + t.timestamp + ": " + t.action + " from " + t.from_type + " to " + t.to_type + "\n"

    return result

func cmd_transform_entity(args: Array) -> String:
    if args.size() < 2:
        return "Usage: akashic_transform <entity_id> <new_type>"

    var entity_id = args[0]
    var new_type = args[1]

    var entity = get_entity_by_id(entity_id)
    if entity == null:
        return "Entity not found: " + entity_id

    var old_type = entity.get_type()
    var success = transform_entity(entity, new_type)

    if success:
        return "Transformed entity " + entity_id + " from " + old_type + " to " + new_type
    else:
        return "Failed to transform entity " + entity_id + " to " + new_type

func cmd_interact_entities(args: Array) -> String:
    if args.size() < 2:
        return "Usage: akashic_interact <entity_id1> <entity_id2>"

    var entity_id1 = args[0]
    var entity_id2 = args[1]

    var entity1 = get_entity_by_id(entity_id1)
    var entity2 = get_entity_by_id(entity_id2)

    if entity1 == null:
        return "Entity not found: " + entity_id1
    if entity2 == null:
        return "Entity not found: " + entity_id2

    var result = process_interaction(entity1, entity2)

    if result.has("success") and result.success:
        var effect = result.effect
        return "Interaction between " + entity_id1 + " and " + entity_id2 + " resulted in: " + effect
    else:
        return "Interaction between " + entity_id1 + " and " + entity_id2 + " failed"

# Demo entries for Akashic Records
func _create_demo_entries() -> void:
    print("JSH_AkashicRecords: Creating demo entries...")

    # Check if akashic_records_manager is available
    if akashic_records_manager == null:
        print("Cannot create demo entries - akashic_records_manager is null")
        return

    # Check if it's properly initialized
    if not akashic_records_manager.is_initialized:
        print("Cannot create demo entries - akashic_records_manager is not initialized")
        return

    # Skip the demo entries creation to avoid errors for now
    print("JSH_AkashicRecords: Demo entries skipped")
    return

    print("JSH_AkashicRecords: Demo entries created")