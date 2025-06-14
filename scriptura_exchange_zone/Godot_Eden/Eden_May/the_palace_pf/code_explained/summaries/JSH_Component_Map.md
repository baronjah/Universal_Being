# JSH Ethereal Engine - Visual Component Map

```
┌─────────────────────────────────────────────────────────────────────┐
│                        JSH Ethereal Engine                           │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                             main.gd                                  │
│                                                                     │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────────────┐    │
│  │ Thread System │  │ Process System │  │ Dimensional Magic    │    │
│  └───────┬───────┘  └───────┬───────┘  └─────────┬─────────────┘    │
│          │                  │                    │                  │
│  ┌───────┴───────┐  ┌───────┴───────┐  ┌─────────┴─────────────┐    │
│  │ Task Manager  │  │ Record System │  │ Reality Management    │    │
│  └───────┬───────┘  └───────┬───────┘  └─────────┬─────────────┘    │
│          │                  │                    │                  │
└──────────┼──────────────────┼────────────────────┼──────────────────┘
           │                  │                    │
           ▼                  ▼                    ▼
┌──────────────────┐ ┌────────────────┐ ┌───────────────────────────┐
│ Container System │ │ Entity System  │ │ UI Rendering System       │
│ (container.gd)   │ │ (Entities)     │ │ (Visualization)           │
└────────┬─────────┘ └────────┬───────┘ └─────────────┬─────────────┘
         │                    │                       │
         ▼                    ▼                       ▼
┌────────────────┐   ┌────────────────┐      ┌────────────────────┐
│ DataPoint      │   │ Guardians      │      │ Texture System     │
│ (data_point.gd)│   │ (Observers)    │      │ (Visual Effects)   │
└────────┬───────┘   └────────┬───────┘      └─────────┬──────────┘
         │                    │                        │
         ▼                    ▼                        ▼
┌────────────────┐   ┌────────────────┐      ┌────────────────────┐
│ Terminal UI    │   │ Reality Layers │      │ Mesh Generation    │
│ (User Input)   │   │ (Contexts)     │      │ (Shapes & Lines)   │
└────────┬───────┘   └───────────────┘       └─────────┬──────────┘
         │                                             │
         └─────────────────────┬─────────────────────┘
                               │
                               ▼
                      ┌────────────────┐
                      │ Line System    │
                      │ (line.gd)      │
                      └────────────────┘
```

## Component Relationships & Data Flow

### Core System Components (main.gd)

1. **Thread System**
   - Manages parallel execution
   - Thread pool implementation
   - Thread safety (mutexes)
   - Task scheduling

2. **Process System**
   - Manages process cycles
   - Handles processing stages
   - Dispatches tasks
   - Manages process timing

3. **Dimensional Magic**
   - Function categorization
   - Abstract operations
   - Cross-component communication
   - Reality-aware operations

4. **Task Manager**
   - Task creation and execution
   - Priority-based dispatching
   - Task status tracking
   - Async operation handling

5. **Record System**
   - Data persistence
   - Record set management
   - Caching mechanisms
   - State tracking

6. **Reality Management**
   - Reality state tracking
   - Reality transitions
   - Reality-specific rules
   - Reality container visibility

### Container System (container.gd)

- **Primary Role**: Organizational structure
- **Contains**: DataPoints
- **Manages**: Spatial organization
- **Interfaces With**: main.gd, DataPoint, Line
- **Key Functions**:
  - `container_start_up()`
  - `get_containers_connected()`

### DataPoint System (data_point.gd)

- **Primary Role**: Interaction and display
- **Contained By**: Container
- **Manages**: Terminal, text, user input
- **Interfaces With**: main.gd, Container, Line
- **Key Functions**:
  - Terminal operations
  - Text input handling
  - Visual state management

### Line System (line.gd)

- **Primary Role**: Visual connection
- **Connects**: Containers and DataPoints
- **Manages**: Visual representation of relationships
- **Interfaces With**: main.gd, Container, DataPoint
- **Key Functions**:
  - Line rendering
  - Connection visualization
  - Position updates

### Entity System

- **Primary Role**: Game objects and characters
- **Types**: Guardians, characters
- **Manages**: Entity behavior and state
- **Interfaces With**: main.gd, reality system

### UI Rendering System

- **Primary Role**: Visual presentation
- **Components**: Textures, materials, meshes
- **Manages**: Visual effects and appearance
- **Interfaces With**: main.gd, all visual components

## Main Data Flows

### Creation Flow
```
main.gd → creates Container → DataPoint → establishes Lines
```

### Command Flow
```
DataPoint → captures input → main.gd → processes → updates components
```

### Rendering Flow
```
main.gd → defines textures/materials → applies to components → rendered
```

### Reality Transition Flow
```
main.gd → changes reality state → updates reality containers → 
affects all components → visual transition effects
```

## Reality Contexts

Each component exists within multiple reality contexts:

1. **Physical Reality**
   - Standard physics rules
   - Blue color theme
   - 1.0x time scale

2. **Digital Reality**
   - Modified physics
   - Green color theme
   - 1.2x time scale

3. **Astral Reality**
   - Abstract physics
   - Purple color theme
   - 0.8x time scale

## Exceptional Connections

### Dimensional Magic Calls
The dimensional magic system allows cross-cutting concerns:

```
1st Dimension: Direct creation
2nd Dimension: Transform operations
3rd Dimension: State management
4th Dimension: Effect application
...
9th Dimension: Advanced operations
```

This magic system enables scripts to communicate across conventional boundaries, allowing for the metaphysical layer of the engine.

### Memory and Déjà Vu
The memory system creates connections between:
- User actions
- Reality states
- Guardian appearances
- Word manifestations

### Thread Safety
Mutexes protect shared resources across components:
- Record access
- Container state
- Tree management
- Task allocation

## Functional Pathways

1. **Terminal → Command → Action**
   - User inputs text in DataPoint terminal
   - main.gd parses as command
   - Command dispatched to appropriate system
   - Visual feedback through component updates

2. **Word → Manifestation → Element**
   - Word specified by user
   - Density field generated from characters
   - Visual representation created
   - Element manifested in reality

3. **Reality → Transition → Perception**
   - Reality state changed
   - Container visibility updated
   - Shader effects applied
   - Time scale adjusted
   - Guardian possibly spawned

This visual component map illustrates the sophisticated relationships between the various systems in the JSH Ethereal Engine, showing how they collaborate to create the unified experience across multiple realities.