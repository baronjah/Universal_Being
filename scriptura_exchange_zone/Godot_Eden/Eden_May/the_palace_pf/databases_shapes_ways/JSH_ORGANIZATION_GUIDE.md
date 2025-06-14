# JSH Ethereal Engine - Organization Guide

## Project Organization Structure

This guide provides instructions for organizing and maintaining the JSH Ethereal Engine project structure, both in terms of code and documentation.

## Directory Structure

The project follows a mirrored structure between implementation (code) and documentation:

```
Project Root
├── code/                   # Implementation files
│   ├── core/               # Core system components
│   ├── entity/             # Entity-related components
│   ├── word/               # Word-related components
│   ├── console/            # Console and UI components
│   ├── spatial/            # Spatial management components
│   ├── database/           # Data storage components
│   ├── integration/        # Cross-system integration
│   └── visualization/      # Visual representation components
│
├── code_explained/         # Documentation files
│   ├── core/               # Core system documentation
│   ├── entity/             # Entity system documentation
│   ├── word/               # Word system documentation
│   ├── console/            # Console system documentation
│   ├── spatial/            # Spatial system documentation
│   ├── database/           # Database system documentation
│   ├── integration/        # Integration documentation
│   └── visualization/      # Visualization documentation
│
├── scenes/                 # Godot scene files
├── JSH_*.md                # Project-level documentation
└── *.gd                    # Script files
```

## File Naming Conventions

### Implementation Files
- **Core Components**: `Core{ComponentName}.gd`
- **Entity Components**: `JSHEntity{ComponentName}.gd`
- **Word Components**: `JSHWord{ComponentName}.gd`
- **Console Components**: `JSHConsole{ComponentName}.gd`
- **Spatial Components**: `JSHSpatial{ComponentName}.gd`
- **Database Components**: `JSHDatabase{ComponentName}.gd`

### Documentation Files
- **Component Documentation**: `{ComponentName}.md`
- **Index Files**: `_INDEX.md`
- **Project Guidelines**: `{TOPIC}_GUIDELINES.md`
- **System Documentation**: `JSH_{SYSTEM}_README.md`

### Scene Files
- **Main Scene**: `main.tscn`
- **Component Test Scenes**: `{component_name}_test_scene.tscn`
- **Integration Test Scenes**: `{system_name}_integration_test.tscn`

## Documentation Organization

### Top-Level Documentation
1. **Getting Started Guide** (`JSH_GETTING_STARTED.md`)
   - System setup instructions
   - Core concepts explanation
   - Basic usage examples

2. **Implementation Report** (`JSH_IMPLEMENTATION_REPORT.md`)
   - Detailed implementation information
   - Component descriptions
   - Integration approach

3. **System READMEs** (`JSH_{SYSTEM}_README.md`)
   - System-specific documentation
   - API documentation
   - Usage examples

### Component Documentation
Each component should have detailed documentation that includes:

1. **Overview**: Brief description of the component's purpose
2. **Properties**: Description of all properties and their types
3. **Methods**: Documentation of all public methods
4. **Signals**: List of signals emitted by the component
5. **Usage Examples**: Code examples showing how to use the component
6. **Integration Points**: How the component integrates with other parts of the system

### Index Files
Each directory should have an `_INDEX.md` file that:

1. Provides an overview of the subsystem
2. Lists all components in the subsystem
3. Explains how components relate to each other
4. Links to individual component documentation
5. Provides examples of the subsystem in use

## Code Organization

### Component Dependencies
Components should follow these dependency guidelines:

1. **Core Components**: Can depend only on other core components
2. **Subsystem Components**: Can depend on core components and other components in the same subsystem
3. **Integration Components**: Can depend on components from multiple subsystems

### Component Responsibilities
Each component should have clear responsibilities:

1. **Managers**: Handle creation, tracking, and lifecycle management
2. **Interfaces**: Provide public APIs for functionality
3. **Visualizers**: Handle visual representation
4. **Commands**: Process commands and user input
5. **Analyzers**: Process and analyze specific types of data

## Documentation Guidelines

### Writing Style
- Use clear, concise language
- Provide code examples for complex concepts
- Use headings to organize information
- Include diagrams for complex systems

### File Size
- Documentation files should be 300-500 lines (preferred)
- Maximum file size: 1000 lines
- Break large documentation into linked files

### Navigation
- Include table of contents for large files
- Add navigation links between related documentation
- Use consistent linking patterns

## Implementation Guidelines

### Code Style
- Follow Godot's GDScript style guide
- Add comments for complex logic
- Use descriptive variable and method names
- Keep methods focused on a single responsibility

### Signal Usage
- Use signals for loose coupling between components
- Document all signals with their parameters
- Connect signals in the _ready method

### Resource Management
- Clean up resources when components are destroyed
- Use weak references for cyclic dependencies
- Cache resources for better performance

## Navigation Tools

A navigation script is available to help you quickly access project files:

```bash
# In WSL Ubuntu, run:
/home/kamisama/goto_jsh_project.sh
```

This script provides shortcuts to common project locations and files.

## Project Index

The master project index is available at:

```
/home/kamisama/JSH_PROJECT_INDEX.md
```

This file provides links to all major project components and documentation.

## Next Steps for Organization

1. **Complete Documentation**
   - Document remaining entity system components
   - Document word system components
   - Document console system components
   - Document database system components

2. **Organize Implementation Files**
   - Create scenes directory and move .tscn files
   - Update scene references to maintain functionality

3. **Create Visualizations**
   - Add system architecture diagrams
   - Add component relationship diagrams
   - Add data flow diagrams

4. **Implement Missing Components**
   - DynamicMapSystem
   - PlayerController
   - FloatingIndicator
   - PerformanceMonitor