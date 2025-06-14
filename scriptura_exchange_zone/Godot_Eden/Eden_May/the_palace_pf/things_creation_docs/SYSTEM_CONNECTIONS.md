# Eden Project - System Connections

This document visualizes the connections between the various systems in the Eden project.

## Core System Connections

```mermaid
graph TD
    UB[Universal Bridge] --- AR[Akashic Records]
    UB --- TC[Thing Creator]
    UB --- SS[Space System]
    UB --- WG[World Grid]
    UB --- CS[Console System]
    
    AR --- TC
    AR --- WG
    AR --- ZM[Zone Manager]
    
    TC --- WG
    TC --- W3D[World 3D]
    
    SS --- W3D
    
    WG --- ZM
    
    CS --- AR
    CS --- TC
    CS --- SS
    CS --- WG
```

## Data Flow Diagram

```mermaid
flowchart TD
    User[User Input] --> CS[Console System]
    CS --> UB[Universal Bridge]
    
    UB --> AR[Akashic Records]
    AR --> Dictionary[(Dictionary DB)]
    
    UB --> TC[Thing Creator]
    TC --> Instance[Instance Creation]
    
    AR --> TC
    
    TC --> W3D[World 3D]
    
    UB --> WG[World Grid]
    WG --> ZM[Zone Manager]
    ZM --> Zones[(Zone DB)]
    
    WG --> Instances[(Instance DB)]
    
    UB --> SS[Space System]
    SS --> W3D
```

## Subsystem Details

### Universal Bridge Connections

The Universal Bridge serves as the central hub connecting all major systems. It:

1. **Discovers and Initializes Systems**
   - Finds or creates Akashic Records Manager
   - Finds or creates Thing Creator
   - Connects to Space System and World Grid when available

2. **Provides Unified API**
   - `create_thing_from_word(word_id, position)` - Creates a thing using Thing Creator
   - `process_thing_interaction(thing1_id, thing2_id)` - Manages interactions
   - `transform_thing(thing_id, new_type)` - Transforms an existing thing
   - `register_element(element, type_name)` - Registers elements with Akashic Records

3. **Manages Signals**
   - `entity_registered(entity_id, word_id, element_id)` - When entity is registered
   - `entity_transformed(entity_id, old_type, new_type)` - When entity changes type
   - `interaction_processed(entity1_id, entity2_id, result)` - When interaction completes

### Akashic Records Connections

The Akashic Records system manages the dictionary of all words and their properties:

1. **Interfaces With**:
   - Universal Bridge: For global access
   - Thing Creator: Provides word definitions
   - Zone Manager: For location-based word evolution
   - Dynamic Dictionary: For storing word definitions

2. **Provides**:
   - `create_word(id, category, properties)` - Creates new word definitions
   - `get_word(word_id)` - Retrieves word definitions
   - `process_word_interaction(word1_id, word2_id)` - Processes interactions between words
   - `search_words(query, category)` - Searches for words matching criteria

3. **Receives**:
   - Word creation requests
   - Interaction results for evolution
   - Zone information for context-aware adaptations

### Thing Creator Connections

The Thing Creator instantiates entities in the 3D world based on dictionary definitions:

1. **Interfaces With**:
   - Universal Bridge: For global access
   - Akashic Records: Gets word definitions
   - World 3D: Creates visual representations
   - World Grid: For spatial positioning

2. **Provides**:
   - `create_thing(word_id, position, properties)` - Creates things from words
   - `remove_thing(thing_id)` - Removes things from the world
   - `get_thing(thing_id)` - Gets information about a thing
   - `update_thing_position(thing_id, position)` - Updates thing position

3. **Receives**:
   - Thing creation requests
   - Interaction triggers
   - Position updates

### Console System Connections

The Console System provides a command-line interface for interacting with the game:

1. **Interfaces With**:
   - Universal Bridge: For accessing all systems
   - Akashic Records: For word management
   - Thing Creator: For entity management
   - Various subsystems: For specialized commands

2. **Provides**:
   - Command registration and execution
   - Text output
   - Command history
   - Input parsing

3. **Receives**:
   - User input
   - System status notifications
   - Error messages

## UI Connections

```mermaid
graph TD
    TCUI[Thing Creator UI] --- TC[Thing Creator]
    TCUI --- AR[Akashic Records]
    
    ARUI[Akashic Records UI] --- AR
    
    TCS[Thing Creator Standalone] --- TCUI
    
    CS[Console System] --- CommandReg[Command Registration]
    CommandReg --- TC
    CommandReg --- AR
    CommandReg --- UB[Universal Bridge]
    
    TCUI --- W3D[World 3D]
    W3D --- Preview[3D Preview]
```

## Thread Management

```mermaid
graph TD
    TPM[Thread Pool Manager] --- AR[Akashic Records]
    TPM --- WG[World Grid]
    TPM --- SSG[Star System Generation]
    
    TPM --- TM[Task Manager]
    TM --- Tasks[Task Queue]
    
    TPM --- TT[Thread Tasks]
    TT --- T1[Thread 1]
    TT --- T2[Thread 2]
    TT --- T3[Thread 3]
    TT --- T4[Thread 4]
```

## Data Flow for Entity Creation

```mermaid
sequenceDiagram
    participant User
    participant UI as Thing Creator UI
    participant TC as Thing Creator
    participant AR as Akashic Records
    participant W3D as World 3D
    
    User->>UI: Select word and position
    UI->>TC: create_thing(word_id, position)
    TC->>AR: get_word(word_id)
    AR-->>TC: word definition
    TC->>TC: _create_visual_representation()
    TC->>W3D: add_child(visual)
    TC-->>UI: thing_id
    UI-->>User: Display success
```

## Integration Points for New Systems

When adding new systems to the Eden project, connect them through these integration points:

1. **Universal Bridge Integration**:
   - Register the system with the Universal Bridge
   - Connect to relevant signals
   - Provide a standardized API

2. **Console Integration**:
   - Register commands using ConsoleIntegrationHelper
   - Implement command handlers
   - Connect to console signals

3. **UI Integration**:
   - Create a UI component for the system
   - Connect UI to system through Universal Bridge
   - Standardize UI appearance and behavior

4. **Threading Integration**:
   - Use Thread Pool Manager for concurrent operations
   - Register tasks with Task Manager
   - Handle thread synchronization properly