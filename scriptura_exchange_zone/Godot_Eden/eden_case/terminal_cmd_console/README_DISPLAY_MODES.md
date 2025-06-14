# Terminal Display Modes

## Overview
The Terminal Display Manager provides multiple display modes optimized for different scenarios, including night mode, battery saving mode, and a unique fractal visualization mode.

## Display Modes

### Standard Mode
- Default terminal experience
- Balanced colors and performance
- Full animation effects
- Font size: 14px

### Night Mode
- Reduced blue light emission
- Darker background with softer text colors
- Slightly larger font (16px) for easier reading
- Reduced animation speed (80%)

### Battery Saver Mode
- Minimal power consumption
- Black background with reduced brightness
- Disabled animations and transitions
- Simplified UI elements
- Automatic activation at <20% battery

### AirMax Mode
- Apple-inspired clean interface
- Light background with crisp typography
- Optimized for high-DPI displays
- Enhanced animations (120% speed)
- Compact font size (13px)

### Fractal Mode
- Advanced visualization layer
- Dynamic text arrangement with fractal patterns
- Text offset with dimensional depth
- Color cycling based on LUNO cycle phase
- Pattern complexity increases with each evolution

## Fractal Visualization

The fractal display mode creates an immersive terminal experience by arranging text and UI elements in fractal patterns that evolve with the system:

- **Depth**: Controls complexity (2-5 levels)
- **Offset**: Adjusts position of fractal center point
- **Scale**: Controls overall size of the pattern
- **Rotation**: Dynamic rotation tied to LUNO cycles
- **Color Shift**: Progressive color cycling through the spectrum

Fractal patterns correspond to LUNO phases:
- **Genesis**: Simple patterns (depth 2)
- **Formation**: Structured patterns (depth 3)
- **Complexity**: Intricate patterns (depth 4)
- **Transcendence/Unity/Beyond**: Maximum complexity (depth 5)

## Battery Management

The system automatically monitors battery status and optimizes the display accordingly:

- Battery level checked every minute
- Auto-enables Battery Saver mode when level drops below 20%
- Auto-disables Battery Saver when charging and above 30%
- Provides battery state notifications

## Usage Examples

### Toggle Display Modes
```gdscript
# Access the display manager
var display_manager = get_node("TerminalDisplayManager")

# Toggle night mode
display_manager.toggle_night_mode(true)

# Enable battery saver
display_manager.toggle_battery_saver(true)

# Switch to AirMax mode
display_manager.toggle_airmax_mode(true)

# Enable fractal visualization
display_manager.toggle_fractal_mode(true)
```

### Adjust Fractal Parameters
```gdscript
# Set fractal center offset
display_manager.set_fractal_offset(Vector2(10, 5))

# Adjust text offset for 3D effect
display_manager.set_text_offset(1.5)
```

### Monitor Mode Changes
```gdscript
# Connect to mode change signal
display_manager.connect("mode_changed", self, "_on_display_mode_changed")

func _on_display_mode_changed(mode_name):
    print("Display mode changed to: " + mode_name)
```

## LUNO Cycle Integration

The display manager is deeply integrated with the LUNO Cycle System:

1. Registers as a LUNO participant
2. Adjusts fractal properties based on current phase
3. Evolves display capabilities after each complete 12-turn cycle
4. Creates new color themes through evolutionary algorithms

## Technical Notes

- Color themes defined as dictionaries of color values
- Automatic theme switching based on system state
- Battery monitoring simulates real hardware integration
- Fractal visualization parameters update dynamically