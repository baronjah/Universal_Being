# Unified Project Connector System

This system provides tools to connect and integrate components across different Godot projects, allowing them to share code, functionality, and data.

## Overview

The Unified Project Connector system consists of several components that work together to:

1. Analyze project structures and file relationships
2. Identify similar components across projects
3. Create connections between related components
4. Visualize project relationships
5. Enable cross-project data transfer and integration

## Components

### UnifiedProjectConnector (unified_project_connector.gd)

The core connector system that manages component registration, connections, and data transfer. It:

- Scans projects to build a component registry
- Creates different types of connections between components
- Provides tools to find components matching various criteria
- Enables data transfer between connected components
- Tracks the active connection topology

### TokenAnalyzer (token_analyzer.gd)

Analyzes file content by breaking it down into tokens for matching and comparison. Features:

- Multiple tokenization strategies (code, natural language, semantic)
- Support for different token types (keywords, identifiers, etc.)
- Token similarity calculations for component matching
- Function and variable name extraction

### ProjectLinker (project_linker.gd)

Automatically creates links between similar components across projects. It:

- Finds connection candidates based on name similarity
- Identifies components with similar functions
- Matches components based on content similarity
- Creates appropriate connections between related components
- Generates reports of created connections

### ProjectConnectionVisualizer (project_connection_visualizer.gd)

Visualizes connections between components across different projects. Features:

- Interactive 2D visualization of component connections
- Project grouping and color coding
- Zoomable and pannable interface
- Component selection and highlighting
- Export to HTML for interactive web viewing

## Usage

### Basic Setup

```gdscript
# Create the connector
var connector = UnifiedProjectConnector.new()

# Create a token analyzer
var analyzer = TokenAnalyzer.new()

# Create a project linker
var linker = ProjectLinker.new(connector, analyzer)

# Link projects automatically
linker.link_projects()

# Create a visualizer
var visualizer = ProjectConnectionVisualizer.new()
visualizer.connect_to_connector(connector)

# Export visualization
visualizer.export_html_visualization("/path/to/visualization.html")
```

### Manual Component Registration

```gdscript
# Register components manually
var component_id = connector.register_component(
    "12_turns_system",
    "universal_connector.gd",
    "script"
)

# Connect components
connector.connect_components(
    component_id,
    "LuminusOS::scripts/multi_core_system.gd",
    connector.ConnectionType.SYSTEM_LINK
)
```

### Finding Components

```gdscript
# Find components by name pattern
var color_systems = connector.find_components(
    connector.MatchCriteria.NAME_PATTERN,
    "*color*system*"
)

# Find components by functionality
var memory_systems = connector.find_components(
    connector.MatchCriteria.SEMANTIC_DOMAIN,
    "memory"
)
```

### Transferring Data

```gdscript
# Transfer data between components
var result = connector.transfer_data(
    "12_turns_system::dimensional_color_system.gd",
    "Eden_OS::dimensional_color_system.gd",
    { "color_values": color_data }
)
```

## Connection Types

The system supports several types of connections:

1. **FILE_LINK**: Basic connection between related files
2. **VARIABLE_MIRROR**: Synchronizes variables between components
3. **SIGNAL_BRIDGE**: Connects signals between components
4. **SYSTEM_LINK**: Links entire subsystems together
5. **API_CONNECTOR**: Connects components via an API interface

## Project Integration

The system works with the following projects:

- **12_turns_system**: The turn-based system project
- **LuminusOS**: The custom OS and terminal system
- **Eden_OS**: The Eden operating system project
- **Godot_Eden**: Additional Eden components

## Visualization

The visualization tools provide multiple ways to understand component relationships:

- **2D Godot Visualization**: Interactive in-editor component map
- **HTML Visualization**: Web-based interactive component browser
- **JSON Export**: Data format for custom visualizations

## Example: Connecting Color Systems

```gdscript
# Find all color system components
var color_systems = connector.find_components(
    connector.MatchCriteria.NAME_PATTERN,
    "*color*system*"
)

# Connect them all together
for i in range(color_systems.size()):
    for j in range(i+1, color_systems.size()):
        connector.connect_components(
            color_systems[i],
            color_systems[j],
            connector.ConnectionType.VARIABLE_MIRROR,
            {
                "variables": ["color_values", "color_properties"],
                "bidirectional": true
            }
        )
```

## Implementation Details

### Tokenization

The TokenAnalyzer uses several strategies to break down code:

- **CODE_TOKENS**: Parse code with awareness of programming syntax
- **NATURAL_LANGUAGE**: Tokenize natural language text
- **SEMANTIC_TOKENS**: Create semantic token representations (concepts)
- **VARIABLE_NAMES**: Extract variable names for matching
- **FUNCTION_NAMES**: Extract function names for matching

### Similarity Calculation

Components are matched using various similarity metrics:

- String similarity using modified Levenshtein distance
- Jaccard similarity for token sets
- Function signature matching
- Semantic domain matching

### Visualization Format

The HTML visualization includes:

- Project grouping with color coding
- Component lists with interactive highlighting
- Connection visualization by type
- Component details panel
- Statistics on projects and connections