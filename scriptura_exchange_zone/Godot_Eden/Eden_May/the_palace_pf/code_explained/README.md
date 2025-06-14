# Code Explained

This directory contains documentation, explanations, and summaries for the various components of the JSH Ethereal Engine.

## Directory Structure

- **core/**: Documentation for core system scripts
  - Universal Entity system
  - Word Manifestation system
  - Dictionary Manager
  - Game Controller
  - Analysis components (Phonetic, Semantic, Pattern)

- **akashic_records/**: Documentation for record-related scripts
  - Akashic Records Manager
  - Database systems
  - File storage and retrieval

- **ui/**: Documentation for UI components
  - Creation Console
  - Floating Indicators
  - Debug interfaces

- **scenes/**: Documentation for scene structures
  - Main scene
  - Entity scenes
  - Test scenes

- **summaries/**: Overall system summaries
  - **entity_system/**: Universal Entity summaries
  - **word_system/**: Word Manifestation summaries
  - **console_system/**: Console system summaries
  - **integration/**: Integration docs and plans

- **phase_planning/**: Phase implementation plans
  - Phase 1-7 planning documents
  - Script connection documentation

## Purpose

This documentation hierarchy mirrors the structure of the `code` directory, making it easy to find explanations for specific scripts and systems. Each component of the JSH Ethereal Engine is documented with:

1. **Overview**: High-level description of what the component does
2. **Key Classes**: Important classes and their relationships
3. **Core Functionality**: Main features and capabilities
4. **Usage Examples**: Examples of how to use the component
5. **Integration Points**: How the component integrates with other systems

## Contributing

When adding new code to the project, please also update the corresponding documentation in this directory. Follow the existing structure and format to maintain consistency.

## Reading Order

If you're new to the project, it's recommended to read the documentation in this order:

1. `summaries/integration/JSH_GETTING_STARTED.md`: Basic introduction to the system
2. `summaries/entity_system/`: Understanding the Universal Entity system
3. `summaries/word_system/`: Learning about Word Manifestation
4. `summaries/console_system/`: Console UI and commands
5. Individual component documentation as needed

This structured approach will help you understand the overall architecture before diving into specific components.

---

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