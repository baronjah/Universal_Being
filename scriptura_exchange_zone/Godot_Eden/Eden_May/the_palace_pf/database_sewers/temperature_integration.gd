extends Node

# Temperature Integration System
# Handles integration of temperature system with other core systems

# References to systems
var temperature_system
var temperature_visual_effects
var temperature_word_effects
var temperature_ui
var turn_manager
var divine_word_processor
var realism_ratio_system
var blink_system

# Connections between systems
var system_connections = {}

# Integration status
var integration_complete = false

func _ready():
    # Defer initialization until all systems are loaded
    call_deferred("initialize_integration")

# Initialize integration with all systems
func initialize_integration():
    # Get references to all temperature systems
    temperature_system = get_node_or_null("/root/TemperatureSystem")
    temperature_visual_effects = get_node_or_null("/root/TemperatureVisualEffects")
    temperature_word_effects = get_node_or_null("/root/TemperatureWordEffects")
    
    # Get references to core systems
    turn_manager = get_node_or_null("/root/TurnManager")
    divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
    realism_ratio_system = get_node_or_null("/root/RealismRatioSystem")
    blink_system = get_node_or_null("/root/BlinkSystem")
    
    # Load UI
    var ui_scene = load("res://temperature_ui.tscn")
    if ui_scene:
        var ui_instance = ui_scene.instance()
        ui_instance.name = "TemperatureUI"
        get_node("/root/Main/UI").add_child(ui_instance)
        temperature_ui = ui_instance
    
    # Connect systems
    connect_systems()
    
    # Set initial dimension-specific temperature
    if turn_manager and temperature_system:
        set_temperature_for_dimension(turn_manager.current_dimension)
    
    integration_complete = true
    print("Temperature system integration complete")

# Connect all temperature-related systems
func connect_systems():
    if turn_manager and temperature_system:
        # Connect to dimension change
        if not system_connections.has("dimension_change"):
            system_connections["dimension_change"] = true
            turn_manager.connect("dimension_changed", self, "_on_dimension_changed")
    
    if divine_word_processor and temperature_word_effects:
        # Connect word power to temperature effects
        if not system_connections.has("word_power"):
            system_connections["word_power"] = true
            divine_word_processor.connect("word_power_calculated", temperature_word_effects, "_on_word_power_calculated")
    
    if realism_ratio_system and temperature_system:
        # Connect realism ratio to temperature variation
        if not system_connections.has("realism_ratio"):
            system_connections["realism_ratio"] = true
            realism_ratio_system.connect("realism_ratio_changed", self, "_on_realism_ratio_changed")
    
    if blink_system and temperature_visual_effects:
        # Connect blink system to temperature visuals
        if not system_connections.has("blink_system"):
            system_connections["blink_system"] = true
            blink_system.connect("blink", self, "_on_blink")

# Called when dimension changes
func _on_dimension_changed(new_dimension, old_dimension):
    set_temperature_for_dimension(new_dimension)

# Set temperature based on dimension
func set_temperature_for_dimension(dimension):
    if not temperature_system:
        return
    
    # Base temperatures for each dimension
    var dimension_temperatures = {
        "alpha": 25,    # Normal room temperature
        "beta": 10,     # Cool
        "gamma": 40,    # Warm
        "delta": -10,   # Frozen
        "epsilon": 60,  # Hot
        "zeta": 5,      # Cold
        "eta": 90,      # Near boiling
        "theta": 120,   # Boiling
        "iota": -50,    # Deep freeze
        "kappa": 1500,  # Plasma
        "lambda": 35,   # Warm
        "mu": 20        # Mild
    }
    
    if dimension_temperatures.has(dimension):
        var base_temp = dimension_temperatures[dimension]
        # Add slight randomization
        var actual_temp = base_temp + rand_range(-2, 2)
        temperature_system.set_temperature(actual_temp)
        
        # Log dimension temperature
        print("Dimension " + dimension + " temperature: " + str(actual_temp) + "°C")

# Called when realism ratio changes
func _on_realism_ratio_changed(ratio):
    if not temperature_system:
        return
    
    # More abstract perception (lower realism) leads to more extreme temperatures
    var current_temp = temperature_system.current_temperature
    var realism_factor = (1.0 - ratio) * 0.5  # 0.0 to 0.5
    
    # Calculate temperature variation based on realism
    # Lower realism = more extreme temperatures
    if current_temp < 0:
        # Cold temperatures get colder with low realism
        var temp_adjustment = current_temp * realism_factor
        temperature_system.adjust_temperature(temp_adjustment)
    elif current_temp > 50:
        # Hot temperatures get hotter with low realism
        var temp_adjustment = current_temp * realism_factor
        temperature_system.adjust_temperature(temp_adjustment)

# Called when blink occurs
func _on_blink():
    if not temperature_visual_effects or not temperature_system:
        return
    
    # Flash temperature visuals briefly on blink
    temperature_visual_effects.flash_temperature_effect(0.2)

# Get temperature info for the current dimension
func get_dimension_temperature_info():
    if not temperature_system or not turn_manager:
        return "Temperature system not initialized"
    
    var dimension = turn_manager.current_dimension
    var temp = temperature_system.current_temperature
    var state = temperature_system.temperature_state_to_string(temperature_system.current_temperature_state)
    
    return "Dimension " + dimension.to_upper() + ": " + \
           str(int(temp)) + "°C (" + state + ")"

# Console commands
func console_command(command, args):
    match command:
        "temp_integration", "temperature_integration":
            if args.size() > 0:
                match args[0]:
                    "status":
                        var systems = []
                        if temperature_system: systems.append("TemperatureSystem")
                        if temperature_visual_effects: systems.append("TemperatureVisualEffects")
                        if temperature_word_effects: systems.append("TemperatureWordEffects")
                        if temperature_ui: systems.append("TemperatureUI")
                        
                        return "Temperature integration status: " + \
                               (integration_complete as String) + "\n" + \
                               "Connected systems: " + str(systems)
                    
                    "dimension":
                        return get_dimension_temperature_info()
                    
                    "reconnect":
                        # Force reconnect all systems
                        system_connections.clear()
                        connect_systems()
                        return "Reconnected all temperature systems"
            
            return "Available commands: status, dimension, reconnect"