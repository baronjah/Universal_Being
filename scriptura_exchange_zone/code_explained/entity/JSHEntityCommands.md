# JSHEntityCommands

The `JSHEntityCommands` system provides a command-line interface to the entity system through the console. It enables users to create, manage, inspect, and manipulate entities using text commands.

## Overview

The Entity Commands system bridges the console interface with the entity management system, allowing developers and users to work with entities through a command-line interface. This provides a powerful way to test, debug, and manipulate the entity system without needing a graphical interface.

## Core Concepts

### Command Structure

The system follows a structured command pattern:
- **Main Commands**: Top-level commands like `entity` and `entities`
- **Subcommands**: Secondary commands like `list`, `create`, `delete`
- **Arguments**: Parameters specific to each subcommand

### Command Results

Each command returns a standardized result dictionary containing:
- Success status (true/false)
- Message string for display
- Command-specific data (entities, counts, etc.)
- Error information when applicable

### Output Formatting

Commands display information to the console using:
- Success messages (typically in green)
- Error messages (typically in red)
- Warning messages (typically in yellow)
- Standard output (for general information)

## Key Features

### Entity Creation

Create new entities with specified types and properties:
```
entity create water volume=10 temperature=5
```

### Entity Listing

List all entities or filter by type/tag:
```
entities
entities type water
entities tag important
```

### Entity Information

Display detailed information about a specific entity:
```
entity info 1234abcd
```

### Entity Deletion

Remove entities from the system:
```
entity delete 1234abcd
```

### Entity Search

Find entities matching specific criteria:
```
entity find type water
entity find property temperature 5
entity find tag important
```

### Entity Tagging

Add or remove tags from entities:
```
entity tag add 1234abcd important
entity tag remove 1234abcd temporary
```

### System Statistics

Display overall statistics about the entity system:
```
entity stats
```

## Implementation Details

### Command Registration

Commands are registered with the console system through a dictionary structure that defines:
- Command description
- Usage syntax
- Callback function
- Argument requirements (min/max)
- Argument types
- Argument descriptions

### Entity ID Resolution

The system supports partial entity ID matching:
- Full 32-character UUIDs can be used
- Shorter partial IDs are matched against the beginning of full IDs
- First match is used when multiple entities share the same prefix

### Property Parsing

Properties for entity creation can be specified as key=value pairs:
- String values remain as strings
- Numeric values are automatically converted to integers or floats
- Properties are combined into a dictionary for entity creation

### Search Mechanisms

The system offers multiple search approaches:
- By entity type
- By entity tag
- By specific property values
- Additional search criteria can be implemented as needed

## Practical Use

### Creating Entities from the Console

```
# Create a basic fire entity
entity create fire

# Create a water entity with properties
entity create water volume=50 flow_rate=2.5 temperature=5

# Create an earth entity with complex properties
entity create earth mass=100 density=3.5 hardness=7 tag=mountain
```

### Finding and Managing Entities

```
# List all entities
entities

# Find entities with a specific property
entity find property temperature 5

# Get detailed information about an entity
entity info 1234abcd

# Tag an entity for later reference
entity tag add 1234abcd important

# Find all important entities
entity find tag important

# Delete an entity
entity delete 1234abcd
```

### Analyzing Entity System

```
# Get overall statistics
entity stats

# Check entities by type
entities type water

# Check entities at a specific evolution stage
entity find property evolution_stage 2
```

## Integration with Other Systems

The `JSHEntityCommands` system integrates with:

- **JSHConsoleManager**: Registers commands and displays output
- **JSHEntityManager**: Performs the actual entity operations
- **JSHUniversalEntity**: Operates on individual entities
- **JSHEntityEvolution**: Indirectly accessed through entity properties

## Technical Considerations

### Command Validation

Commands are validated before execution:
- Required arguments are checked
- Argument types are validated
- Entity existence is confirmed before operations

### Error Handling

The system provides clear error messages for:
- Missing or invalid arguments
- Entity not found errors
- Action failures (e.g., tag already exists)
- Unknown commands or subcommands

### Command Extensions

New commands can be added by:
1. Adding a new entry to the `commands` dictionary
2. Implementing a corresponding command handler function
3. Registering the command with the console manager

### Entity Reference Safety

For operations involving entity references:
- Entity existence is verified before any operation
- Partial IDs are safely resolved to full IDs
- Operations on non-existent entities fail gracefully with clear error messages