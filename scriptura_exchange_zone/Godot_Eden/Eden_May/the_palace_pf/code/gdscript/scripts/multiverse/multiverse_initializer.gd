extends Node
class_name MultiverseInitializer

# This script initializes the Multiverse Navigation system
# Add it to an autoload node or call initialize() from your main scene

const MULTIVERSE_KEY_BINDING = KEY_F8

var system_integration = null
var ui_instance = null
var initialized = false

func _ready():
    # Initialize on ready if this script is attached to a node
    initialize()
    
    # Set up input handling for toggling the UI
    set_process_input(true)

func _input(event):
    # Toggle multiverse UI with F8 key
    if initialized and event is InputEventKey and event.pressed and event.keycode == MULTIVERSE_KEY_BINDING:
        toggle_multiverse_ui()

func initialize():
    if initialized:
        return
    
    print("Initializing Multiverse Navigation System...")
    
    # Get or create the system integration singleton
    system_integration = MultiverseSystemIntegration.get_instance()
    
    # Register the system with the engine
    if not Engine.has_singleton("MultiverseSystem"):
        Engine.register_singleton("MultiverseSystem", system_integration)
    
    # Connect signals
    system_integration.universe_changed.connect(_on_universe_changed)
    system_integration.cosmic_turn_advanced.connect(_on_cosmic_turn_advanced)
    system_integration.metanarrative_progressed.connect(_on_metanarrative_progressed)
    system_integration.access_point_discovered.connect(_on_access_point_discovered)
    
    # Create UI instance (initially hidden)
    ui_instance = system_integration.create_ui_instance()
    if ui_instance:
        ui_instance.visible = false
    
    # Mark as initialized
    initialized = true
    
    # Load universe data immediately
    system_integration.advance_cosmic_turn()
    
    print("Multiverse Navigation System initialized successfully")
    print("Press F8 to toggle the Multiverse Navigation UI")

func toggle_multiverse_ui():
    if system_integration:
        system_integration.toggle_ui_visibility()

# Signal handlers
func _on_universe_changed(universe_id):
    print("Active universe changed to: " + universe_id)
    
    # Update any connected systems (e.g., Akashic Records)
    var universe_data = system_integration.get_universe_data(universe_id)
    if universe_data:
        # Example: update the background environment based on universe type
        if universe_data.type == "Void" or universe_data.type == "Echo":
            # Apply darker environment
            # This would be integrated with your environment system
            pass
        elif universe_data.type == "Prime" or universe_data.type == "Convergent":
            # Apply brighter environment
            pass

func _on_cosmic_turn_advanced(turn):
    print("Cosmic turn advanced to: " + str(turn))
    
    # This might trigger various systems in your game
    # For example, entity evolution or world generation

func _on_metanarrative_progressed(progress):
    # Only log significant changes
    if int(progress) % 10 == 0:
        print("Metanarrative progress: " + str(int(progress)) + "%")
    
    # This might trigger story events or quest updates in your game

func _on_access_point_discovered(universe_id):
    print("New universe access point discovered: " + universe_id)
    
    # This might trigger UI notifications or new mission objectives

# Integration with JSH Ethereal Engine core systems
func integrate_with_ethereal_engine():
    # This function would integrate the multiverse system with other JSH systems
    # Such as the Akashic Records, Entity Evolution, etc.
    
    # Example: Connect to Akashic Records system
    var akashic_records = system_integration.akashic_records_manager
    if akashic_records:
        # Register multiverse system events with Akashic Records
        system_integration.universe_changed.connect(
            func(universe_id): akashic_records.record_event(
                "universe_travel", 
                {
                    "universe_id": universe_id, 
                    "cosmic_turn": system_integration.get_cosmic_turn()
                }
            )
        )
    
    # Example: Connect to Entity Evolution system
    var entity_evolution = system_integration.entity_evolution
    if entity_evolution:
        # Apply universal constants based on current universe
        system_integration.universe_changed.connect(
            func(universe_id): _apply_universal_constants(universe_id)
        )
    
    print("Multiverse system integrated with JSH Ethereal Engine core systems")

func _apply_universal_constants(universe_id):
    # This would apply different rules to entities based on the current universe
    var universe_data = system_integration.get_universe_data(universe_id)
    if not universe_data:
        return
    
    # Example: Each universe type could have different evolution rates
    var evolution_rate = 1.0
    match universe_data.type:
        "Nascent":
            evolution_rate = 1.5  # Faster evolution in new universes
        "Divergent":
            evolution_rate = 1.2  # Slightly faster evolution in divergent universes
        "Convergent":
            evolution_rate = 0.8  # Slower evolution in convergent universes
    
    # Apply the rate to entity evolution system
    var entity_evolution = system_integration.entity_evolution
    if entity_evolution and entity_evolution.has_method("set_evolution_rate"):
        entity_evolution.set_evolution_rate(evolution_rate)