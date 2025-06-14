# JSH Ethereal Engine - Quick Reference

## Project Structure

```
Eden_May/
├── code/                              # Implementation code
│   ├── gdscript/                      # GDScript code
│   │   ├── scripts/                   # Script files
│   │   │   ├── core/                  # Core systems
│   │   │   ├── entity/                # Entity system
│   │   │   ├── word/                  # Word system
│   │   │   ├── spatial/               # Spatial system
│   │   │   ├── database/              # Database system
│   │   │   ├── console/               # Console system
│   │   │   ├── akashic/               # Akashic Records system
│   │   │   └── scribbles_blueprints_testing/  # Experimental code
│   │   └── scenes/                    # Scene files
│   │       └── tests/                 # Test scenes
│   └── cScripts/                      # C# code (if used)
│
├── code_explained/                    # Documentation
│   ├── core/                          # Core documentation
│   ├── entity/                        # Entity documentation
│   ├── word/                          # Word documentation
│   ├── spatial/                       # Spatial documentation
│   ├── console/                       # Console documentation
│   ├── database/                      # Database documentation
│   ├── akashic/                       # Akashic documentation
│   └── _TEMPLATES/                    # Documentation templates
│
├── space_game_docs/                   # Project planning documents
├── zero_point_entity/                 # Zero Point Entity implementation
├── dictionary/                        # Word dictionaries
└── scenes/                            # Project scenes
```

## Key System Components

- **Core System**: Universal entity, word manifestation, game controller
- **Entity System**: Entity tracking, evolution, visualization, commands
- **Word System**: Phonetic/semantic analysis, dictionary management
- **Spatial System**: Spatial organization, zones, spatial queries
- **Console System**: Command interface, UI, command integration
- **Database System**: File storage, data management
- **Akashic Records**: Entity memory and history

## Key Files

- **Project Directory**: [JSH_PROJECT_DIRECTORY.md](/JSH_PROJECT_DIRECTORY.md)
- **Documentation Index**: [JSH_DOCUMENTATION_INDEX.md](/JSH_DOCUMENTATION_INDEX.md)
- **Script Index**: [code/SCRIPT_INDEX.md](/code/SCRIPT_INDEX.md)
- **Main README**: [README_JSH_ETHEREAL_ENGINE.md](/README_JSH_ETHEREAL_ENGINE.md)

## Naming Conventions

### Script Files
- **JSH** prefix: Standard system component
- **Core** prefix: Central framework component
- **_test** suffix: Test implementation
- **proto_/exp_/blueprint_**: Experimental scripts

### Documentation Files
- **JSH_[SYSTEM]_README.md**: System overview documentation
- **[Component].md**: Detailed component documentation
- **_INDEX.md**: Navigation index for a directory

## Workflow Guidelines

1. **Documentation First**: Always consult/update documentation when changing code
2. **Experiments**: Use scribbles_blueprints_testing for new ideas
3. **Scene References**: Update scene references when moving scripts
4. **Cross-System Integration**: Document dependencies between systems
5. **Testing**: Create test scenes for new functionality

## Commands Quick Reference

- `entity create <type> [properties]` - Create a new entity
- `entity list` - Show all entities
- `word manifest <word>` - Convert a word into an entity
- `word analyze <word>` - Analyze a word without creating an entity
- `spatial create_zone <name> [parent]` - Create a new spatial zone
- `console help` - List available commands

This quick reference was last updated: May 10, 2025