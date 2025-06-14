extends Control

# Temperature UI System
# Provides visual indicators and controls for the temperature system

# References to components
var temperature_system
var temperature_visual_system

# UI elements
onready var temperature_label = $TemperatureLabel
onready var temperature_slider = $TemperatureSlider
onready var state_icon = $StateIcon
onready var description_label = $DescriptionLabel

# Temperature icons for different states
var temperature_icons = {
    "FROZEN": preload("res://icons/temp_frozen.png"),
    "COLD": preload("res://icons/temp_cold.png"),
    "NORMAL": preload("res://icons/temp_normal.png"),
    "WARM": preload("res://icons/temp_warm.png"),
    "HOT": preload("res://icons/temp_hot.png"),
    "BOILING": preload("res://icons/temp_boiling.png"),
    "PLASMA": preload("res://icons/temp_plasma.png")
}

# Color gradients for different temperature states
const FROZEN_COLOR = Color(0.7, 0.9, 1.0)
const COLD_COLOR = Color(0.8, 0.95, 1.0)
const NORMAL_COLOR = Color(1.0, 1.0, 1.0)
const WARM_COLOR = Color(1.0, 0.9, 0.7)
const HOT_COLOR = Color(1.0, 0.7, 0.4)
const BOILING_COLOR = Color(1.0, 0.5, 0.2)
const PLASMA_COLOR = Color(0.8, 0.4, 1.0)

func _ready():
    # Get references to required systems
    temperature_system = get_node("/root/TemperatureSystem")
    temperature_visual_system = get_node("/root/TemperatureVisualEffects")
    
    # Connect to temperature change signal
    temperature_system.connect("temperature_changed", self, "_on_temperature_changed")
    
    # Connect UI elements
    temperature_slider.connect("value_changed", self, "_on_slider_value_changed")
    
    # Initialize UI with current temperature
    update_temperature_ui(
        temperature_system.current_temperature,
        temperature_system.current_temperature_state
    )

# Update all UI elements based on current temperature
func update_temperature_ui(temperature, temp_state):
    # Update temperature value display
    temperature_label.text = str(int(temperature)) + "°C"
    
    # Update slider position without triggering callback
    temperature_slider.value = temperature
    
    # Update state icon
    var state_name = temperature_system.temperature_state_to_string(temp_state)
    if temperature_icons.has(state_name):
        state_icon.texture = temperature_icons[state_name]
    
    # Update description
    description_label.text = temperature_visual_system.get_temperature_visual_description(temp_state)
    
    # Update colors based on temperature state
    match temp_state:
        temperature_system.TemperatureState.FROZEN:
            temperature_label.add_color_override("font_color", FROZEN_COLOR)
        temperature_system.TemperatureState.COLD:
            temperature_label.add_color_override("font_color", COLD_COLOR)
        temperature_system.TemperatureState.NORMAL:
            temperature_label.add_color_override("font_color", NORMAL_COLOR)
        temperature_system.TemperatureState.WARM:
            temperature_label.add_color_override("font_color", WARM_COLOR)
        temperature_system.TemperatureState.HOT:
            temperature_label.add_color_override("font_color", HOT_COLOR)
        temperature_system.TemperatureState.BOILING:
            temperature_label.add_color_override("font_color", BOILING_COLOR)
        temperature_system.TemperatureState.PLASMA:
            temperature_label.add_color_override("font_color", PLASMA_COLOR)

# Called when temperature changes
func _on_temperature_changed(new_temp, new_state):
    update_temperature_ui(new_temp, new_state)

# Called when slider value changes
func _on_slider_value_changed(value):
    # Update temperature system
    temperature_system.set_temperature(value)

# Show/hide temperature UI
func toggle_visibility():
    visible = !visible

# Console command integration
func console_command(command, args):
    match command:
        "temp_ui", "temperature_ui":
            if args.size() > 0:
                match args[0]:
                    "show":
                        visible = true
                        return "Temperature UI shown."
                    "hide":
                        visible = false
                        return "Temperature UI hidden."
                    "toggle":
                        toggle_visibility()
                        return "Temperature UI toggled: " + ("visible" if visible else "hidden")
            
            return "Available commands: show, hide, toggle"