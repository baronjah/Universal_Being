# JSH Ethereal Engine - Project Overview

## Welcome to the JSH Ethereal Engine Project

The JSH Ethereal Engine is a Godot-based engine where words shape reality. This project implements a system where text can be analyzed, interpreted, and manifested as interactive entities in a virtual environment.

## Project Structure

The project is organized into the following key directories:

```
JSH Ethereal Engine/
├── code/                    # Implementation code
│   ├── gdscript/            # GDScript implementations
│   │   ├── scenes/          # Scene files (.tscn)
│   │   └── scripts/         # Script files (.gd)
│   └── cScripts/            # C# implementations
│
├── code_explained/          # Documentation
│   ├── core/                # Core system documentation
│   ├── entity/              # Entity system documentation
│   ├── word/                # Word system documentation
│   ├── spatial/             # Spatial system documentation
│   ├── console/             # Console system documentation
│   └── ...                  # Other subsystem documentation
│
├── dictionary/              # Word and entity dictionaries
├── space_game_docs/         # Project planning and documentation
├── zero_point_entity/       # Zero Point Entity implementation
├── scenes/                  # Main project scenes
└── shaders/                 # Shader implementations
```

## Key Navigation Points

- [Project Directory Guide](JSH_PROJECT_DIRECTORY.md) - Detailed explanation of the project structure
- [Documentation Index](JSH_DOCUMENTATION_INDEX.md) - Comprehensive index of all documentation files
- [Script Location Index](code/SCRIPT_INDEX.md) - Index of all script files and their locations

## Core Systems

The JSH Ethereal Engine consists of several integrated systems:

1. **Universal Entity System**: Creates entities that can transform, evolve, and interact
2. **Word Manifestation System**: Converts words into entity properties through linguistic analysis
3. **Spatial System**: Manages entities in 3D space with zones and spatial queries
4. **Console System**: Provides a command-line interface for user interaction
5. **Dictionary System**: Manages word definitions, categories, and relationships

## Getting Started

1. **Open the Project**: Open the project.godot file in Godot Engine
2. **Run the Main Scene**: Load and run the main.tscn scene
3. **Use the Console**: Type commands in the creation console to interact with the system

## Key Commands

- `entity create <type> [properties]` - Create a new entity
- `entity list` - Show all entities
- `entity info <id>` - Show detailed information about an entity
- `word manifest <word>` - Convert a word into an entity
- `word analyze <word>` - Analyze a word without creating an entity

## Development Notes

- All new scripts should be placed in their appropriate subdirectories under `code/gdscript/scripts/`
- Documentation should be added to the corresponding directories under `code_explained/`
- Tests should be written for all new functionality
- Follow the established naming conventions and code style

## Migration Information

The project files were previously located in the user directory and have been migrated to this centralized Godot project. The migration included:

1. Documentation files migration (completed)
2. Script files migration (completed)
3. Scene files migration (completed)

## Related Resources

- [WSL Environment](/home/kamisama/JSH_PROJECT_GATEWAY.md) - Gateway for the WSL environment
- [Windows User Directory](/mnt/c/Users/Percision 15/JSH_PROJECT_GATEWAY.md) - Gateway for the Windows user directory

## Project Roadmap

See [JSH_PROJECT_STATUS.md](JSH_PROJECT_STATUS.md) for the current project status and roadmap.

---

This README was last updated: May 10, 2025