extends Node
class_name JSHSystemInitializer

# System Components
var entity_manager = null
var word_manifestor = null
var console_manager = null
var interaction_matrix = null
var zone_manager = null

# Flags
var is_initialized = false
var initialization_attempted = false

# Initialization options
var auto_initialize = true
var debug_mode = true

func _ready() -> void:
    print("JSHSystemInitializer: System initializer starting...")
    
    if auto_initialize:
        initialize()

func initialize() -> bool:
    if is_initialized:
        return true
    
    if initialization_attempted:
        print("JSHSystemInitializer: Already attempted initialization")
        return false
    
    print("JSHSystemInitializer: Initializing JSH Systems...")
    initialization_attempted = true
    
    # Initialize managers in correct order
    var success = true
    
    # 1. Entity Manager
    success = success and _initialize_entity_manager()
    
    # 2. Zone Manager
    success = success and _initialize_zone_manager()
    
    # 3. Interaction Matrix
    success = success and _initialize_interaction_matrix()
    
    # 4. Word Manifestor
    success = success and _initialize_word_manifestor()
    
    # 5. Console Manager and Commands
    success = success and _initialize_console_system()
    
    # Set initialization status
    is_initialized = success
    
    if success:
        print("JSHSystemInitializer: All systems initialized successfully")
    else:
        print("JSHSystemInitializer: System initialization failed")
    
    return success

func _initialize_entity_manager() -> bool:
    print("JSHSystemInitializer: Initializing Entity Manager...")
    
    # Try JSHEntityManager first
    if ClassDB.class_exists("JSHEntityManager"):
        entity_manager = JSHEntityManager.get_instance()
        print("JSHSystemInitializer: JSHEntityManager initialized")
        return true
    
    # Fall back to ThingCreatorA
    if ClassDB.class_exists("ThingCreatorA"):
        entity_manager = ThingCreatorA.get_instance()
        print("JSHSystemInitializer: ThingCreatorA initialized as entity manager")
        return true
    
    print("JSHSystemInitializer: Failed to initialize Entity Manager")
    return false

func _initialize_zone_manager() -> bool:
    print("JSHSystemInitializer: Initializing Zone Manager...")
    
    # Not critical for basic functionality
    if ClassDB.class_exists("JSHSpatialManager"):
        zone_manager = JSHSpatialManager.get_instance()
        print("JSHSystemInitializer: JSHSpatialManager initialized")
        return true
    
    if ClassDB.class_exists("ZoneManager"):
        zone_manager = ZoneManager.get_instance()
        print("JSHSystemInitializer: ZoneManager initialized")
        return true
    
    print("JSHSystemInitializer: Zone Manager not found, skipping")
    return true  # Not critical, so return true anyway

func _initialize_interaction_matrix() -> bool:
    print("JSHSystemInitializer: Initializing Interaction Matrix...")
    
    # Not critical for basic functionality
    if ClassDB.class_exists("JSHInteractionMatrix"):
        interaction_matrix = JSHInteractionMatrix.get_instance()
        print("JSHSystemInitializer: JSHInteractionMatrix initialized")
        return true
    
    if ClassDB.class_exists("InteractionMatrix"):
        interaction_matrix = InteractionMatrix.get_instance()
        print("JSHSystemInitializer: InteractionMatrix initialized")
        return true
    
    print("JSHSystemInitializer: Interaction Matrix not found, skipping")
    return true  # Not critical, so return true anyway

func _initialize_word_manifestor() -> bool:
    print("JSHSystemInitializer: Initializing Word Manifestor...")
    
    if ClassDB.class_exists("JSHWordManifestor"):
        word_manifestor = JSHWordManifestor.get_instance()
        print("JSHSystemInitializer: JSHWordManifestor initialized")
        return true
    
    print("JSHSystemInitializer: Failed to initialize Word Manifestor")
    return false

func _initialize_console_system() -> bool:
    print("JSHSystemInitializer: Initializing Console System...")
    
    var console_initialized = false
    var commands_initialized = false
    
    # Try to initialize console manager
    if ClassDB.class_exists("JSHConsoleManager"):
        console_manager = JSHConsoleManager.get_instance()
        console_initialized = true
        print("JSHSystemInitializer: JSHConsoleManager initialized")
    
    # Try to initialize word commands
    if console_initialized and ClassDB.class_exists("JSHWordCommands"):
        var word_commands = JSHWordCommands.new()
        commands_initialized = true
        print("JSHSystemInitializer: JSHWordCommands initialized")
    
    # Not critical for base functionality
    if !console_initialized:
        print("JSHSystemInitializer: Console manager not found, skipping")
    
    if console_initialized and !commands_initialized:
        print("JSHSystemInitializer: Word commands not found, skipping")
    
    return true  # Not critical, so return true anyway

# Public getter methods
func get_entity_manager():
    return entity_manager

func get_word_manifestor():
    return word_manifestor

func get_console_manager():
    return console_manager

func get_interaction_matrix():
    return interaction_matrix

func get_zone_manager():
    return zone_manager

# Status checks
func is_system_ready() -> bool:
    return is_initialized

func get_system_status() -> Dictionary:
    return {
        "initialized": is_initialized,
        "entity_manager_available": entity_manager != null,
        "word_manifestor_available": word_manifestor != null,
        "console_manager_available": console_manager != null,
        "interaction_matrix_available": interaction_matrix != null,
        "zone_manager_available": zone_manager != null
    }