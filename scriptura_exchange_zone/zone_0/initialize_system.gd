extends Node

# Main initialization script for Smart Account System with all components

func _ready():
    print("Initializing Smart Account System...")
    
    # Wait for all nodes to be ready
    yield(get_tree().create_timer(0.5), "timeout")
    
    # Get references to all system components
    var components = {
        "account_manager": get_node_or_null("/root/SmartAccountSystem/SmartAccountManager"),
        "connector": get_node_or_null("/root/SmartAccountSystem/SharedAccountConnector"),
        "akashic": get_node_or_null("/root/SmartAccountSystem/AkashicDatabaseConnector"),
        "analyzer": get_node_or_null("/root/SmartAccountSystem/PlayerPreferenceAnalyzer"),
        "auto_correction": get_node_or_null("/root/SmartAccountSystem/AutoCorrectionSystem"),
        "multi_account": get_node_or_null("/root/SmartAccountSystem/MultiAccountManager"),
        "processor": get_node_or_null("/root/SmartAccountSystem/MultiThreadedProcessor"),
        "cloud_storage": get_node_or_null("/root/SmartAccountSystem/CloudStorageConnector"),
        "google_drive": get_node_or_null("/root/SmartAccountSystem/GoogleDriveConnector"),
        "api_manager": get_node_or_null("/root/SmartAccountSystem/ApiKeyManager")
    }
    
    # Verify all components exist
    var missing_components = []
    for component_name in components:
        if components[component_name] == null:
            missing_components.append(component_name)
    
    if missing_components.size() > 0:
        print("ERROR: Missing components: " + str(missing_components))
        return
    
    print("All system components found")
    
    # Set up API keys
    setup_api_keys(components)
    
    # Create and configure account tiers
    setup_account_tiers(components)
    
    # Connect to Google Drive
    connect_to_google_drive(components)
    
    # Initialize point distribution system
    initialize_points_system(components)
    
    # Configure multi-threading
    configure_threading(components)
    
    print("Smart Account System initialization complete")

func setup_api_keys(components):
    # Set OpenAI API key
    var openai_api_key = "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"
    
    # Import to API manager
    var api_key_id = components["api_manager"].import_openai_api_key(openai_api_key)
    print("Imported OpenAI API key: " + str(api_key_id))
    
    # Set for Google Drive
    components["google_drive"].set_openai_api_key(openai_api_key)
    
    # Set simulated Google API credentials
    components["google_drive"].configure_google_drive(
        "simulated_google_key",
        "simulated_client_id",
        "simulated_client_secret"
    )
    
    print("API keys configured")

func setup_account_tiers(components):
    # Create accounts for different tiers
    var free_account = components["multi_account"].create_account(
        "Free Account",
        components["multi_account"].AccountTier.FREE
    )
    
    var plus_account = components["multi_account"].create_account(
        "Plus Account",
        components["multi_account"].AccountTier.PLUS
    )
    
    var max_account = components["multi_account"].create_account(
        "Max Account",
        components["multi_account"].AccountTier.MAX
    )
    
    var enterprise_account = components["multi_account"].create_account(
        "Google Drive 2TB",
        components["multi_account"].AccountTier.ENTERPRISE
    )
    
    # Set Google Drive account as active
    components["multi_account"].switch_account(enterprise_account)
    
    # Link 2TB storage
    components["multi_account"].link_luno_storage(enterprise_account, 2000)
    
    print("Account tiers created")

func connect_to_google_drive(components):
    # Connect to Google Drive
    components["google_drive"].connect_provider(components["cloud_storage"].StorageProvider.GOOGLE_DRIVE)
    
    # Configure sync folders
    components["google_drive"].add_sync_folder("user://game_data", "GameData", "both")
    components["google_drive"].add_sync_folder("user://saved_games", "SavedGames", "both")
    components["google_drive"].add_sync_folder("user://exports", "Exports", "upload")
    
    # Start synchronization
    components["google_drive"].synchronize_folders()
    
    print("Connected to Google Drive")

func initialize_points_system(components):
    # Configure dimension progression
    var account_manager = components["account_manager"]
    
    # Initialize with some points in each category
    account_manager.add_points(100, "creation")
    account_manager.add_points(75, "exploration")
    account_manager.add_points(50, "interaction")
    account_manager.add_points(25, "challenge")
    account_manager.add_points(25, "mastery")
    
    # Configure auto-correction
    components["auto_correction"].adjustment_intensity = 0.7
    components["auto_correction"].notification_level = 1
    
    print("Points system initialized")

func configure_threading(components):
    # Configure thread pool
    var processor = components["processor"]
    
    # Allocate threads for key tasks
    var storage_thread = processor.allocate_thread(
        components["multi_account"].active_account_id,
        "Storage synchronization",
        processor.Priority.NORMAL
    )
    
    var analytics_thread = processor.allocate_thread(
        components["multi_account"].active_account_id,
        "User analytics processing",
        processor.Priority.LOW
    )
    
    var ai_thread = processor.allocate_thread(
        components["multi_account"].active_account_id,
        "AI document analysis",
        processor.Priority.HIGH
    )
    
    print("Threading configured with " + str(processor.get_active_thread_count()) + " active threads")