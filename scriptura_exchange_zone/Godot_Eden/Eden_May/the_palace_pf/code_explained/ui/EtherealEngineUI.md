# Script Documentation: EtherealEngineUI

## Overview
EtherealEngineUI provides a comprehensive user interface for interacting with the JSH Ethereal Engine. It creates a tabbed interface with console, entity creation, pattern generation, and information panels to allow users to create, transform, and manage entities in the engine.

## File Information
- **File Path:** `/code/gdscript/scripts/ui/EtherealEngineUI.gd`
- **Class Name:** EtherealEngineUI
- **Extends:** Node

## Dependencies
- CoreThingCreator
- Camera3D

## Properties

### Core References
| Property | Type | Description |
|----------|------|-------------|
| thing_creator | Node | Reference to the CoreThingCreator instance |
| main_controller | Node | Reference to the main controller (main.gd) |
| camera | Camera3D | Reference to the scene camera |

### UI Components
| Property | Type | Description |
|----------|------|-------------|
| ui_root | Control | The root UI control node |
| console_panel | Control | The console panel control |
| creation_panel | Control | The entity creation panel control |
| info_panel | Control | The information panel control |
| pattern_panel | Control | The pattern generation panel control |

### State Tracking
| Property | Type | Description |
|----------|------|-------------|
| ui_visible | bool | Whether the UI is currently visible |
| current_panel | Control | The currently active panel |
| console_history | Array | History of console output |
| console_index | int | Current position in console history |
| command_history | Array | History of entered commands |
| history_index | int | Current position in command history |

## Core Methods

### Initialization
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _ready | | void | Sets up the UI and required components |
| _input | event | void | Handles keyboard input |
| find_required_components | | void | Locates or creates necessary system components |

### UI Construction
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| create_ui | | void | Creates the main UI structure |
| create_console_panel | | Control | Creates the console panel |
| create_creation_panel | | Control | Creates the entity creation panel |
| create_pattern_panel | | Control | Creates the pattern generation panel |
| create_info_panel | | Control | Creates the information panel |

### UI Navigation
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| toggle_ui | | void | Shows/hides the UI |
| hide_all_panels | | void | Hides all panels |
| _on_console_tab_pressed | | void | Activates console panel |
| _on_creation_tab_pressed | | void | Activates creation panel |
| _on_pattern_tab_pressed | | void | Activates pattern panel |
| _on_info_tab_pressed | | void | Activates info panel |

### Console Functionality
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _on_console_input_submitted | text | void | Handles console input |
| process_console_command | text | void | Processes console commands |
| show_help | | void | Shows console help text |
| add_console_text | text, color | void | Adds text to the console |
| set_console_input | text | void | Sets the console input text |

### Creation Panel Functionality
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _on_create_entity_button_pressed | | void | Creates an entity from UI input |
| _on_use_camera_position_pressed | | void | Sets position to camera position |
| _on_refresh_entity_list_pressed | | void | Refreshes entity list |
| _on_remove_entity_pressed | | void | Removes selected entity |
| _on_evolve_entity_pressed | | void | Evolves selected entity |

### Pattern Panel Functionality
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _on_use_pattern_camera_position_pressed | | void | Sets pattern center to camera position |
| _on_generate_pattern_pressed | | void | Generates a pattern from UI input |

## Commands
| Command | Parameters | Description |
|---------|------------|-------------|
| help | | Shows the help text |
| create | word x y z [evolution] | Creates an entity |
| remove | entity_id | Removes an entity |
| evolve | entity_id | Evolves an entity |
| transform | entity_id form | Transforms an entity |
| connect | entity1_id entity2_id [type] | Connects two entities |
| pattern | word type count radius [x y z] | Creates a pattern |
| list | | Lists all entities |

## UI Panels

### Console Panel
Provides a command-line interface for interacting with the Ethereal Engine through text commands. Offers a text output area showing the history of commands and their results, along with an input area for entering new commands.

### Creation Panel
Offers a visual interface for creating and managing entities. Includes fields for specifying the word, position, and evolution stage for entity creation, as well as controls for managing existing entities (refreshing the list, removing entities, and evolving them).

### Pattern Panel
Dedicated to generating patterns of entities. Users can specify the word, pattern type, count, radius, and center position, with options for using the camera position as the center.

### Information Panel
Presents detailed information about the JSH Ethereal Engine, including explanations of the Universal Entity system, Word Manifestation, Entity Evolution, Pattern Generation, and available commands.

## Integration Points

### CoreThingCreator
The UI directly uses the CoreThingCreator for all entity operations, providing a user-friendly interface to the core functionality.

### Akashic Records
Entity creation and management is indirectly connected to the Akashic Records system through the CoreThingCreator.

### Camera System
The UI integrates with the camera system to allow positioning entities at the camera's location, creating a more intuitive placement experience.

## Usage

To use the EtherealEngineUI, simply create an instance and add it to the scene:

```gdscript
var ui = EtherealEngineUI.new()
ui.name = "EtherealEngineUI"
add_child(ui)
```

The UI will automatically locate or create the necessary components (CoreThingCreator, camera references), and provide a toggle interface that users can access by pressing the Tab key.

## Best Practices
- Use the console for quick commands and experimentation
- Use the creation panel for precise entity placement
- Use the pattern panel for creating complex arrangements
- Refer to the information panel for guidance on available functionality