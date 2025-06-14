# Core Components Documentation

## Overview
The core components form the foundation of the JSH Ethereal Engine. They provide the basic functionality for entity creation, word manifestation, and system control. These components are designed to work together as the central framework of the system.

## Core Files

### Universal Entity System
- [CoreUniversalEntity](CoreUniversalEntity.md) - The foundation entity class that represents all entities in the system. Provides functionality for manifestation, evolution, transformation, and interaction.

### Word Manifestation System
- [CoreWordManifestor](CoreWordManifestor.md) - The system that converts words into entity properties through linguistic analysis. Central to the "words shape reality" concept.

### Creation Interface
- [CoreCreationConsole](CoreCreationConsole.md) - The user interface for entering commands to create and manipulate entities.

### System Management
- [CoreGameController](CoreGameController.md) - The main controller that initializes and connects all components of the system.
- [JSHSystemInitializer](JSHSystemInitializer.md) - Handles system initialization and module loading.

## Component Relationships

```
┌─────────────────────┐       ┌──────────────────────┐
│                     │       │                      │
│  CoreGameController ├───────► CoreWordManifestor   │
│                     │       │                      │
└─────────┬───────────┘       └──────────┬───────────┘
          │                              │
          │                              │ Creates
          │                              ▼
          │                   ┌──────────────────────┐
          │                   │                      │
          └───────────────────►  CoreUniversalEntity │
            Manages           │                      │
                              └──────────┬───────────┘
                                         │
                                         │ Interfaces with
                                         ▼
                              ┌──────────────────────┐
                              │                      │
                              │ CoreCreationConsole  │
                              │                      │
                              └──────────────────────┘
```

## System Initialization Flow

1. **CoreGameController** initializes first
2. **CoreGameController** creates and initializes **CoreWordManifestor**
3. **CoreWordManifestor** loads word databases and connects to analyzers
4. **CoreGameController** sets up **CoreCreationConsole** and connects it to the word manifestor
5. **CoreCreationConsole** processes user input into commands for the word manifestor
6. **CoreWordManifestor** creates **CoreUniversalEntity** instances from words

## Integration with Other Systems

The core components integrate with several other systems:

- **Entity System**: CoreUniversalEntity integrates with JSHEntityManager for entity tracking
- **Word System**: CoreWordManifestor connects with word analyzers and dictionary management
- **Database System**: Core components use database components for persistent storage
- **Spatial System**: Entities integrate with the spatial management system
- **Visualization System**: Entities connect with visualization components for rendering

## Key Concepts

- **Universal Entity**: A fundamental game object that can transform and evolve
- **Word Manifestation**: The process of converting words into entity properties
- **Entity Evolution**: The progression of entities through stages of complexity
- **Word Analysis**: The linguistic breakdown of words into characteristic properties
- **Entity Relationships**: Connections between entities through references and links

## Next Steps

After understanding the core components, explore these related systems:

- [Entity System](../entity/_INDEX.md) - Entity management and evolution
- [Word System](../word/_INDEX.md) - Word analysis and dictionary management
- [Console System](../console/_INDEX.md) - User interface and command processing
- [Spatial System](../spatial/_INDEX.md) - Spatial organization and management