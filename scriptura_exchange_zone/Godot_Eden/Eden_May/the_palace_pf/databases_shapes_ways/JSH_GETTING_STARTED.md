# JSH Ethereal Engine - Getting Started Guide

## Introduction

Welcome to the JSH Ethereal Engine, a system designed for creating a dynamic, entity-based universe where words shape reality. This system allows you to manifest entities from words, transform them, evolve them, and create complex interactions between them.

This guide will help you understand the core concepts, set up the system, and start creating your own universe.

## Core Concepts

### Universal Entities

The foundation of the JSH Ethereal Engine is the Universal Entity system. Each entity:
- Can be created from words
- Has a visual representation in 3D space
- Can transform between different forms
- Evolves through stages of complexity
- Can interact with other entities
- Exists across multiple reality contexts

### Word Manifestation

Words shape reality in this system. When you enter a word:
1. The word is analyzed for phonetic, semantic, and pattern properties
2. These properties determine the entity's characteristics
3. The word manifests as an entity with a specific form and properties
4. The entity begins in a "seed" form that can evolve and transform

### Entity Evolution

Entities grow in complexity over time:
- They progress through evolution stages (0-5)
- Higher stages unlock new abilities and visual effects
- Complex entities can split into multiple entities
- Multiple entities can be merged into more complex forms

### Reality Contexts

Entities exist across multiple layers of reality:
- Physical: The base tangible reality
- Digital: Information and data-based existence
- Astral: Conceptual and thought-based existence
- Ethereal: The bridge between all realities

## Setup Instructions

Follow these steps to get started with the JSH Ethereal Engine:

### 1. Create a New Godot Project

1. Create a new Godot 4.x project
2. Set up the following project structure:
   ```
   project_root/
     ├── code/
     │   ├── core/
     │   ├── entity/
     │   ├── word/
     │   ├── console/
     │   ├── spatial/
     │   └── integration/
     ├── code_explained/
     │   ├── core/
     │   ├── entity/
     │   ├── word/
     │   ├── console/
     │   ├── spatial/
     │   └── integration/
     └── scenes/
         ├── main.tscn
         ├── creation_console.tscn
         └── universal_entity.tscn
   ```

### 2. Copy Implementation Files

Copy the following files to your project:

1. Core files:
   - `UniversalEntity_Enhanced.gd` → `code/core/CoreUniversalEntity.gd`
   - `CoreWordManifestor.gd` → `code/core/CoreWordManifestor.gd`
   - `CoreGameController.gd` → `code/core/CoreGameController.gd`
   - `CoreCreationConsole.gd` → `code/console/CoreCreationConsole.gd`

2. Analysis components:
   - `JSHPhoneticAnalyzer.gd` → `code/word/CorePhoneticAnalyzer.gd`
   - `JSHSemanticAnalyzer.gd` → `code/word/CoreSemanticAnalyzer.gd`
   - `JSHPatternAnalyzer.gd` → `code/word/CorePatternAnalyzer.gd`
   - `JSHDictionaryManager.gd` → `code/word/CoreDictionaryManager.gd`

3. Scene files:
   - `main.tscn` → `scenes/main.tscn`
   - `creation_console.tscn` → `scenes/creation_console.tscn`
   - `universal_entity.tscn` → `scenes/universal_entity.tscn`

### 3. Update Paths

Open all scene files (.tscn) and update the paths to script files according to your project structure. For example:

```
[ext_resource type="Script" path="res://UniversalEntity_Enhanced.gd" id=1]
```

should become:

```
[ext_resource type="Script" path="res://code/core/CoreUniversalEntity.gd" id=1]
```

### 4. Run the Project

1. Set `scenes/main.tscn` as the main scene in your project settings
2. Run the project
3. Press TAB to open the creation console
4. Type words to create entities

## Using the Creation Console

The Creation Console is your primary interface with the system:

1. Press `Tab` to toggle the console visibility
2. Type a word and press `Enter` to manifest an entity
3. Use special commands for advanced operations
4. Use the up/down arrow keys to navigate command history

### Basic Commands

| Command | Description | Example |
|---------|-------------|---------|
| [word] | Create an entity from a word | `fire` |
| create [word] | Explicitly create an entity | `create water` |
| combine [words] | Combine multiple words | `combine fire water` |
| evolve [word] | Evolve an existing entity | `evolve crystal` |
| transform [word] to [form] | Change entity form | `transform fire to plasma` |
| connect [word1] to [word2] | Connect entities | `connect water to fire` |
| help | Show available commands | `help` |

### Advanced Usage

#### Creating Complex Entities
Combine multiple words to create more complex entities:
```
combine fire water earth
```

#### Evolution Sequences
Evolve entities multiple times to reach higher stages:
```
create crystal
evolve crystal
evolve crystal
```

#### Entity Connections
Create networks of connected entities:
```
create sun
create planet
create moon
connect planet to sun
connect moon to planet
```

## Core Components

### CoreUniversalEntity

The base entity class that can transform into different forms and evolve over time. Key features:

- Entity creation and identification
- Property management
- Transformation and evolution
- Visual representation in 3D space
- Connection with other entities

### CoreWordManifestor

The system that converts words into entity properties. Key features:

- Word analysis (phonetic, semantic, pattern)
- Property generation based on analysis
- Word database for saving/loading entity properties
- Word combination functionality
- Command processing

### CoreCreationConsole

The UI for interacting with the system. Key features:

- Command input and history
- Command processing through WordManifestor
- Result display with color-coding
- Toggle visibility with TAB key

### CoreGameController

The main controller that initializes and connects all components. Key features:

- System initialization and connection
- Input handling for console toggle
- Public API for word manifestation
- Error handling and system fallbacks

## Entity Forms

The system supports various entity forms, each with unique visual appearances:

- **Seed**: The initial form of most entities, a small orb with potential
- **Flame**: Fire-based entity with particle effects
- **Droplet**: Water-based entity with fluid properties
- **Crystal**: Earth-based entity with geometric structure
- **Wisp**: Air-based entity with flowing movement
- **Void Spark**: Abstract entity representing emptiness
- **Light Mote**: Entity of pure light energy
- **Shadow Essence**: Entity of shadow and darkness
- **Flow**: Entity representing fluid movement
- **Pattern**: Entity with structured geometry
- **Spark**: Small, highly energetic entity
- **Orb**: Metallic, spherical entity
- **Sprout**: Plant-based, growing entity

## Customization

You can customize the system by:

1. Adding new entity types in CoreWordManifestor._determine_entity_type()
2. Creating new visual representations in CoreUniversalEntity._update_visual_representation()
3. Adding new commands in CoreWordManifestor.process_command()
4. Customizing the console UI in CoreCreationConsole

## Next Steps

To enhance the system, consider implementing the following components:

1. **DynamicMapSystem** - For spatial organization of entities
2. **PlayerController** - For movement and interaction with entities
3. **FloatingIndicator** - For entity selection and information display
4. **PerformanceMonitor** - For monitoring system performance

## Project Structure and Documentation

The JSH Ethereal Engine uses a mirrored structure for code and documentation:

- **code/** - Contains implementation files organized by subsystem
- **code_explained/** - Contains documentation organized with the same structure

Each script has corresponding documentation explaining:
- Properties and methods
- Integration points
- Usage examples
- Related components

## Troubleshooting

### Common Issues

**Issue**: Console not appearing
**Solution**: Check that the TAB key is properly mapped to toggle_console

**Issue**: Entities not appearing
**Solution**: Check that the entity scene path is correct

**Issue**: Words not manifesting as expected
**Solution**: The word database may need to be rebuilt. Delete the user://word_database.json file

**Issue**: Errors in the console
**Solution**: Check the error logs for details

### Getting Help

For more detailed information, refer to the following documents:

- `code_explained/_INDEX.md` - Overview of documentation structure
- `JSH_INTEGRATION_PLAN.md` - Details on integration approach and tasks
- `JSH_IMPLEMENTATION_REPORT.md` - Complete implementation details

## Resources

- [Core Documentation](code_explained/core/_INDEX.md) - Documentation for core components
- [Entity System](code_explained/entity/_INDEX.md) - Entity management and evolution
- [Word System](code_explained/word/_INDEX.md) - Word analysis and manifestation
- [Console System](code_explained/console/_INDEX.md) - User interface documentation
- [Spatial System](code_explained/spatial/_INDEX.md) - Spatial organization documentation

Happy creation!