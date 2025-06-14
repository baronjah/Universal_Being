# JSH Multiverse Navigation UI

## Overview
The Multiverse Navigation UI is an interactive interface for the JSH Ethereal Engine that allows players to navigate between universes, track cosmic progress, and visualize the multiverse structure. This system provides a comprehensive way to explore the multiverse created by the JSH Ethereal Engine.

## Key Features

### Universe Information Display
- Shows detailed properties of the current universe including:
  - Universe name and type
  - Stability percentage and energy levels
  - Core element and current story phase
  - Discovery information and universe description

### Access Point Navigation
- Lists all available access points from the current universe
- Provides filtering capabilities to search for specific universes
- Displays stability ratings for each connection point
- Allows travel between universes with appropriate requirements

### Cosmic Progress Tracking
- Displays the current cosmic turn and age
- Shows progress bars for turn completion and metanarrative advancement
- Visualizes the progression through the seven cosmic ages

### Universe Alignment Visualization
- Graphical representation of how universes connect and relate to each other
- Shows stability of connections between universes
- Illustrates conceptual distance and similarity between realities

### Quick Travel System
- Provides shortcuts to frequently visited or important universes
- Maintains history of recently visited universes
- Allows instant travel to key multiverse locations

## Components

### 1. Multiverse Navigation UI (multiverse_navigation_ui.gd)
The main UI script that handles the interface, visualization, and user interaction.

### 2. Multiverse System Integration (multiverse_system_integration.gd)
Connects the UI to core JSH systems including:
- Multiverse Evolution System
- Akashic Records Manager
- Player Controller
- Time Progression System

### 3. Multiverse Initializer (multiverse_initializer.gd)
Handles initialization and setup of the entire navigation system:
- Creates references to required systems
- Instantiates the UI components
- Connects signals between systems
- Provides API for controlling the multiverse navigation

## Usage

### Toggling the UI
Press F8 (default) to toggle the multiverse navigation interface. This can be customized in the multiverse_initializer.gd configuration.

### Navigating Between Universes
1. Browse the list of available access points in the central panel
2. Select a universe to view its details
3. Click the "Travel" button to journey to the selected universe
4. Use quick travel buttons for frequently visited universes

### Tracking Cosmic Progress
The right panels display:
- Current cosmic age and turn
- Progress through the current turn
- Overall metanarrative advancement
- Universe alignment visualization

### Requirements for Universe Travel
Some universes may have specific requirements:
- Minimum cosmic turn requirements
- Metanarrative progress thresholds
- Player movement mode conditions
- Discovery of specific narrative elements

## Integration with JSH Systems

### Time Progression System
- Universe travel triggers time-related events
- Advancing cosmic turns affects the multiverse structure
- Certain movement modes may reveal hidden universes

### Akashic Records Manager
- Universe discovery and travel are recorded in the Akashic Records
- History of universe travel can be accessed through the Records system
- Important narrative events are triggered based on universe exploration

### Player Movement Controller
- Certain movement modes (like Dream Navigation) affect universe access
- Player position and state may carry over between universe transitions
- Movement capabilities may vary between universe types

### Word Manifestation System
- Words can be manifested across universes with varying effects
- Core concepts persist between universes as fundamental elements
- Word DNA may evolve differently in different universe types

## API Reference

### Multiverse Navigation UI
- `toggle_visibility()` - Show/hide the UI
- `focus_universe(universe_id)` - Focus on a specific universe in the UI
- `update_display()` - Refresh all UI elements
- `show_multiverse_map()` - Open the detailed multiverse map

### Multiverse System Integration
- `get_current_universe()` - Get data for the current universe
- `get_available_access_points()` - Get access points from current universe
- `get_cosmic_state()` - Get current cosmic turn and age information
- `travel_to_universe(universe_id)` - Travel to specified universe
- `advance_cosmic_turn()` - Manually advance to the next cosmic turn

### Multiverse Initializer
- `initialize()` - Set up the multiverse navigation system
- `toggle_multiverse_ui()` - Toggle UI visibility
- `focus_universe(universe_id)` - Focus on a specific universe
- `reset_multiverse()` - Reset the multiverse to its initial state

## Customization

### UI Themes
The UI appearance can be customized by modifying the multiverse_navigation_ui.tscn scene file or by adjusting the theme variables in multiverse_navigation_ui.gd.

### Universe Types and Colors
Universe types and their corresponding colors can be modified in the universe_type_colors dictionary in multiverse_navigation_ui.gd.

### Cosmic Age Descriptions
The descriptions for each cosmic age can be customized in the cosmic_age_descriptions array in multiverse_navigation_ui.gd.

### Hotkeys
The toggle key (F8 by default) can be changed in the multiverse_initializer.gd configuration.

## Console Integration

The Multiverse Navigation UI includes integration with the JSH Console system:
- Access the multiverse console with the "Open Console" button
- Use console commands like `universe.travel` and `universe.info`
- Execute cosmic turn advancement with `cosmos.advance_turn`
- View detailed universe data with `universe.details`

## Future Enhancements

### Planned Features
- 3D multiverse map visualization
- Universe creation and customization tools
- Detailed timeline view of universe evolution
- Access point creation and modification
- Cross-universe word tracking and manifestation

---

*For more information on the JSH Ethereal Engine and its components, please refer to the main JSH documentation.*