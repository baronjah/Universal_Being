# JSH Ethereal Engine - Code

This directory contains the implementation code for the JSH Ethereal Engine.

## Directory Structure

- **gdscript/**: GDScript code
  - **scripts/**: Script files
    - **core/**: Core system scripts
    - **akashic_records/**: Record-related scripts
    - **ui/**: UI component scripts
    - **tests/**: Test scripts
  - **scenes/**: Scene files
- **resources/**: Resources used by the code
  - **materials/**: Material definitions
  - **models/**: 3D models
  - **textures/**: Texture files

## Core Components

### Universal Entity System

The UniversalEntity class (`core/CoreUniversalEntity.gd`) is the foundation of the system, representing entities that can transform, evolve, and interact with each other.

### Word Manifestation System

The WordManifestor class (`core/CoreWordManifestor.gd`) converts words into entity properties through linguistic analysis, enabling the creation of entities directly from words.

### Creation Console

The CreationConsole class (`ui/CoreCreationConsole.gd`) provides a user interface for interacting with the system through text commands.

### Game Controller

The GameController class (`core/CoreGameController.gd`) initializes and coordinates all system components.

## Usage

To use the JSH Ethereal Engine:

1. Set main.tscn as the main scene in your project
2. Run the project
3. Press TAB to open the creation console
4. Type words to create entities

## Development

When adding new code to the project:

1. Follow the existing directory structure
2. Use the "Core" prefix for classes to avoid conflicts with autoload singletons
3. Update the corresponding documentation in the code_explained directory
4. Follow the coding standards in CLAUDE.md

### Class Naming Conventions

All newly added classes that might conflict with autoload singletons should have the "Core" prefix:

- Original class names: ThingCreator, ThingCreatorUI, UniversalBridge, AkashicRecordsManager
- New class names: CoreThingCreator, CoreThingCreatorUI, CoreUniversalBridge, CoreAkashicRecordsManager

For more detailed information, refer to the documentation in the code_explained directory.