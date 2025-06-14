# Unified Turn System

The Unified Turn System provides a consistent interface for working with various turn-based systems across the project. It establishes a standardized snake_case naming convention for all components, making the codebase more consistent and easier to maintain.

## Core Components

### UnifiedTurnSystemConnector

The `UnifiedTurnSystemConnector` (in `unified_turn_system_connector.gd`) serves as the main integration point for the various turn systems:

- **TurnSystem**: The core turn system with dimension management
- **TurnController**: Advanced turn controller with power scaling and file-based persistence
- **TurnIntegrator**: Connects different turn systems together
- **TurnPrioritySystem**: Manages turn priorities across categories
- **DimensionalColorSystem**: Handles color themes for different dimensions

The connector provides a consistent snake_case API for working with all these systems, regardless of which ones are present in the current scene.

## Snake Case Naming Convention

All new code should follow the snake_case naming convention for variables, functions, and signals. The `UnifiedTurnSystemConnector` maps Pascal/camelCase names to their snake_case equivalents.

Examples:

| Original Name (PascalCase) | Snake Case Name     |
|---------------------------|---------------------|
| TurnSystem                | turn_system         |
| TurnController            | turn_controller     |
| StartTurn                 | start_turn          |
| CurrentDimension          | current_dimension   |
| PowerPercentage           | power_percentage    |
| TurnStarted               | turn_started        |

### Why Snake Case?

1. **Consistency**: Snake case provides a consistent style across all code elements
2. **Readability**: Separating words with underscores improves readability
3. **Gdscript Convention**: It aligns with the style used in Godot's documentation 
4. **Python Compatibility**: Easier integration with Python-based tools and scripts

## Usage Example

```gdscript
# Create the connector
var turn_connector = UnifiedTurnSystemConnector.new()
add_child(turn_connector)

# Use the unified snake_case API
turn_connector.start_turn(3)
turn_connector.set_dimension(4)
var current_turn = turn_connector.get_current_turn()
var dimension_name = turn_connector.get_dimension_name()

# Register your system to receive turn notifications
turn_connector.register_system(self)
```

See `unified_turn_system_example.gd` for a complete working example.

## Turn System Concepts

The turn system is based on several key concepts:

1. **Turns**: Discrete time periods (default: 9-second sacred interval)
2. **Dimensions**: Different states or modes, from 1D to 12D
3. **Symbols**: Sacred symbols associated with each turn (△, ○, □, etc.)
4. **Power Percentage**: Scaling factor that changes with turn progression (33% to 66%)
5. **Turn Data**: Persistent data stored for each turn

## Integration with Other Systems

The Unified Turn System integrates with:

- **DimensionalColorSystem**: For visual theming based on dimension
- **TaskTransitionAnimator**: For smooth transitions between turns
- **WordCommentSystem**: For documenting turn events
- **WordDreamStorage**: For persisting turn data across sessions

## File Structure

- `unified_turn_system_connector.gd` - Main connector class
- `unified_turn_system_example.gd` - Example usage
- `turn_system.gd` - Core turn system
- `turn_controller.gd` - Advanced turn controller
- `turn_integrator.gd` - System integration
- `turn_priority_system.gd` - Priority management