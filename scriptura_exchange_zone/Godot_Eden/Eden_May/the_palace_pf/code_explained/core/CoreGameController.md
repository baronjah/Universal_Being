# Script Documentation: CoreGameController

## Overview
CoreGameController serves as the central manager for the JSH Ethereal Engine, initializing and connecting all major system components. It coordinates the interaction between the entity system, word manifestation system, map system, and UI components. The controller provides a centralized API for system-wide operations and handles fallbacks when specific components are unavailable.

## File Information
- **File Path:** `/code/core/CoreGameController.gd`
- **Lines of Code:** 191
- **Class Name:** CoreGameController
- **Extends:** Node

## Dependencies
- CoreWordManifestor/JSHWordManifestor (for word processing)
- CoreEntityManager/JSHEntityManager/ThingCreatorA (for entity management)
- DynamicMapSystem (optional, for spatial organization)
- CoreCreationConsole (for UI)

## Properties

### Component References
| Property | Type | Description |
|----------|------|-------------|
| word_manifestor | Object | Reference to the word manifestation system |
| entity_manager | Object | Reference to the entity management system |
| creation_console | Node | Reference to the creation console UI |
| player | Node | Reference to the player node (if available) |
| map_system | Node | Reference to the map/world management system |

### Preloaded Scenes
| Property | Type | Description |
|----------|------|-------------|
| console_scene | PackedScene | Preloaded creation console scene |
| entity_scene | PackedScene | Preloaded universal entity scene |

## Signals
| Signal | Parameters | Description |
|--------|------------|-------------|
| initialization_complete | | Emitted when all systems are successfully initialized |
| system_error | system_name, error_message | Emitted when a system fails to initialize |

## Methods

### Initialization
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _ready | | void | Initializes all systems in the correct order |
| _initialize_entity_system | | bool | Sets up entity management system |
| _initialize_word_system | | bool | Sets up word manifestation system |
| _initialize_map_system | | bool | Sets up map/world system |
| _initialize_ui_system | | bool | Sets up UI components |
| _connect_systems | | void | Connects initialized systems together |
| _setup_input_handling | | void | Configures input maps for system interaction |

### Public API
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| toggle_console | | void | Shows or hides the creation console |
| manifest_word | word, position | Object | Creates an entity from a word |
| process_command | command | Dictionary | Processes a console command |

### Input Handling
| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| _input | event | void | Handles input events for system control |

## Initialization Flow
1. **Entity System**: Initializes entity management (creation, tracking, evolution)
2. **Word System**: Initializes word manifestation (word analysis, entity properties)
3. **Map System**: Initializes spatial organization (or creates a fallback)
4. **UI System**: Initializes user interface components (console)
5. **System Connections**: Connects all systems for communication
6. **Input Setup**: Configures input handling for system interaction

## Fallback Mechanisms
The controller implements several fallback mechanisms:

1. **Entity Management Fallbacks**:
   - Tries CoreEntityManager first
   - Falls back to JSHEntityManager if available
   - Falls back to ThingCreatorA as last resort

2. **Word System Fallbacks**:
   - Tries CoreWordManifestor first
   - Falls back to JSHWordManifestor if available

3. **Map System Fallbacks**:
   - Looks for existing map_system nodes in the scene
   - Tries to create a DynamicMapSystem if class exists
   - Creates a minimal dummy map system as last resort

## Usage Examples

### Setting Up the Game Controller
```gdscript
# Add to the main scene
var controller = CoreGameController.new()
controller.name = "GameController"
add_child(controller)

# Listen for initialization
controller.initialization_complete.connect(_on_initialization_complete)
controller.system_error.connect(_on_system_error)

func _on_initialization_complete():
    print("System ready!")
    
func _on_system_error(system_name, error_message):
    print("Error in " + system_name + ": " + error_message)
```

### Using the Controller API
```gdscript
# Get reference to the controller
var controller = get_node("GameController")

# Create an entity from a word
var position = Vector3(0, 1, 0)
var entity = controller.manifest_word("crystal", position)

# Process a command
var result = controller.process_command("combine fire water")
if result.success:
    print("Created: " + result.entity.source_word)

# Toggle the console
controller.toggle_console()
```

## Dummy Map System
When no map system is available, the controller creates a minimalist dummy implementation:

```gdscript
extends Node

func add_entity_to_world(entity, position = Vector3.ZERO):
    add_child(entity)
    if entity is Node3D:
        entity.global_position = position
    return true
    
func get_entities():
    return get_children()
```

This ensures basic functionality even without a complete spatial system.

## Integration Points

### Entity System Integration
- Obtains entity manager instance through class detection
- Prioritizes CoreEntityManager > JSHEntityManager > ThingCreatorA
- Provides entity creation capabilities through word manifestation

### Word System Integration
- Obtains word manifestor instance through class detection
- Prioritizes CoreWordManifestor > JSHWordManifestor
- Connects word manifestor to map system and player for positioning

### Map System Integration
- Finds existing map system in scene tree
- Creates one when needed with fallback to dummy implementation
- Provides add_entity_to_world and get_entities functionality

### UI System Integration
- Creates and adds creation console from scene
- Connects console to word manifestor for command processing
- Configures input handling for console visibility toggling

## Notes and Considerations
- The controller is designed to work even with partial system availability
- Dummy systems are created for critical missing components
- The controller centralizes system initialization to ensure correct order
- Input mappings are created if they don't exist (toggle_console on Tab key)
- Player reference is optional but enables better positioning of entities

## Related Documentation
- [CoreUniversalEntity](CoreUniversalEntity.md)
- [CoreWordManifestor](CoreWordManifestor.md)
- [CoreCreationConsole](CoreCreationConsole.md)
- [DynamicMapSystem](../spatial/DynamicMapSystem.md)