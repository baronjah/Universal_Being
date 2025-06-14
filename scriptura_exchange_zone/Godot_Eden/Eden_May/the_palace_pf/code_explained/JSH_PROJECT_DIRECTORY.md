# JSH Ethereal Engine - Project Directory

## Project Structure

The JSH Ethereal Engine project is organized according to the following structure:

### Code Implementation (`/code`)

- **GDScript**: `/code/gdscript/` - GDScript implementations
  - Scenes: `/code/gdscript/scenes/` - Scene files (.tscn)
  - Scripts: `/code/gdscript/scripts/` - Script files (.gd)

- **C# Scripts**: `/code/cScripts/` - C# implementations

### Documentation (`/code_explained`)

- **Core**: `/code_explained/core/` - Core system documentation
  - Universal Entity
  - Word Manifestor
  - Creation Console
  - Game Controller

- **Entity**: `/code_explained/entity/` - Entity system documentation
  - Entity Manager
  - Entity Evolution
  - Entity Visualizer
  - Entity Commands

- **Word**: `/code_explained/word/` - Word system documentation
  - Dictionary Manager
  - Phonetic Analyzer
  - Semantic Analyzer
  - Pattern Analyzer

- **Spatial**: `/code_explained/spatial/` - Spatial system documentation
  - Spatial Manager
  - Zone Manager
  - Spatial Query

- **Console**: `/code_explained/console/` - Console system documentation
  - Console Manager
  - Console Interface
  - Command Integration

- **UI**: `/code_explained/ui/` - UI system documentation
  - Menu System
  - Terminal Interface
  - Visual Representation

- **Integration**: `/code_explained/summaries/integration/` - Integration guides

### Resources

- **Dictionaries**: `/dictionary/` - Word and entity dictionaries
- **Shaders**: `/shaders/` - Shader implementations
- **Addons**: `/addons/` - Third-party addons and plugins

### External Documentation

- **Project Docs**: `/space_game_docs/` - Project planning and documentation
- **Implementation**: `/zero_point_entity/` - Zero Point Entity implementation

## Key Files

- **Project Entry**: `/project.godot` - Godot project file
- **Main Scene**: `/scenes/main.tscn` - Main project scene
- **Initializer**: `/code/gdscript/scripts/EdenProjectInitializer.gd` - Project initialization

## Navigation Guidelines

1. **Code Exploration**: Start with `/code/gdscript/scripts/` to understand implementation
2. **Documentation**: Refer to `/code_explained/` for comprehensive documentation
3. **Scene Structure**: Examine `/code/gdscript/scenes/` for scene organization
4. **External References**: Check `/space_game_docs/` for planning documents

## Development Workflow

1. **Documentation First**: Always consult documentation before modifying code
2. **Scene Hierarchy**: Maintain the established scene hierarchy
3. **Documentation Updates**: Update documentation when changing code
4. **Integration Testing**: Test integrations between systems thoroughly

## Getting Started

New to the project? Follow these steps:

1. Read the project overview in `/README.md`
2. Review the architecture diagram in `/JSH_Ethereal_Engine_Architecture.md`
3. Explore the core documentation in `/code_explained/core/`
4. Examine the main scene in `/code/gdscript/scenes/main.tscn`

## Integration Points

The JSH Ethereal Engine integrates with:

1. **WSL Environment**: Resources in `/home/kamisama/`
2. **Dictionary System**: Entity and word definitions in `/dictionary/`
3. **Godot Addons**: Third-party tools in `/addons/`

This directory guide was last updated: May 10, 2025