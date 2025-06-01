# 📦 Universal Being Component (.ub.zip) Specification v1.0

## Overview

The `.ub.zip` format is the standard component package for Universal Beings in Godot 4.4+. Each component is a self-contained ZIP archive containing scripts, resources, scenes, and metadata that can be dynamically loaded and applied to any Universal Being.

## File Structure

```
component_name.ub.zip
├── manifest.json         # Required: Component metadata and configuration
├── scripts/             # GDScript files
│   ├── main.gd         # Optional: Primary component script
│   └── *.gd            # Additional scripts
├── resources/          # Godot resources
│   ├── *.tres         # Text resources
│   └── *.res          # Binary resources
├── scenes/            # Godot scenes
│   └── *.tscn        # Scene files
└── assets/           # Optional: Additional assets
    ├── textures/
    ├── sounds/
    └── shaders/
```

## Manifest.json Specification

```json
{
    "name": "Component Name",
    "version": "1.0.0",
    "author": "Author Name",
    "description": "Brief description of component functionality",
    "compatibility": {
        "godot": "4.4+",
        "universal_being": "1.0+",
        "dependencies": ["other_component.ub.zip"]
    },
    "entry_point": "scripts/main.gd",
    "metadata": {
        "category": "ui|gameplay|system|visual|audio",
        "consciousness_requirement": 0,
        "custom_key": "custom_value"
    },
    "properties": [
        {
            "name": "property_name",
            "type": "int|float|string|bool|color|vector2|vector3",
            "default": "default_value",
            "description": "Property description"
        }
    ],
    "methods": [
        {
            "name": "method_name",
            "description": "What this method does",
            "parameters": ["param1: type", "param2: type"],
            "returns": "return_type"
        }
    ],
    "signals": [
        {
            "name": "signal_name",
            "parameters": ["param1: type"],
            "description": "When this signal is emitted"
        }
    ],
    "evolution": {
        "enables": ["next_component.ub.zip"],
        "requires_consciousness": 5,
        "conditions": "click_count >= 42"
    }
}
```

## Component Types

### 1. Behavior Components
Modify AI behavior, input handling, or game logic.

Example: `ui_behavior.ub.zip`
```json
{
    "name": "UI Behavior",
    "category": "ui",
    "entry_point": "scripts/ui_behavior.gd"
}
```

### 2. Visual Components
Add visual effects, shaders, or appearance modifications.

Example: `particle_aura.ub.zip`
```json
{
    "name": "Particle Aura",
    "category": "visual",
    "resources": ["particle_system.tres"],
    "consciousness_requirement": 3
}
```

### 3. System Components
Integrate with game systems like save/load, networking, or analytics.

Example: `save_system.ub.zip`
```json
{
    "name": "Save System Integration",
    "category": "system",
    "methods": [
        {
            "name": "save_state",
            "returns": "Dictionary"
        }
    ]
}
```

### 4. Evolution Components
Transform the being into a different type entirely.

Example: `consciousness_portal.ub.zip`
```json
{
    "name": "Consciousness Portal",
    "category": "evolution",
    "evolution": {
        "transforms_to": "portal_being",
        "requires_consciousness": 5
    }
}
```

## Loading Process

1. **Discovery**: Component loader finds .ub.zip file
2. **Validation**: Manifest is parsed and validated
3. **Compatibility Check**: Godot/Universal Being version compatibility verified
4. **Resource Loading**: Scripts, scenes, and resources are loaded into memory
5. **Application**: Component is applied to the Universal Being
6. **Initialization**: Entry point script's `_ready()` is called

## Best Practices

### 1. Keep Components Small
- Single responsibility principle
- One feature per component
- Minimal dependencies

### 2. Version Control
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Document breaking changes
- Maintain backwards compatibility when possible

### 3. Resource Management
- Use relative paths within the component
- Optimize asset sizes
- Clean up resources in `_exit_tree()`

### 4. Documentation
- Clear manifest descriptions
- Comment complex logic
- Include usage examples

## Example Components

### Basic UI Component
```
button_enhancer.ub.zip
├── manifest.json
├── scripts/
│   └── button_enhancer.gd
└── resources/
    └── button_style.tres
```

### Complex Game System
```
inventory_system.ub.zip
├── manifest.json
├── scripts/
│   ├── main.gd
│   ├── inventory.gd
│   └── item.gd
├── scenes/
│   └── inventory_ui.tscn
└── assets/
    └── textures/
        └── item_icons/
```

## Security Considerations

1. Components run with full GDScript permissions
2. Validate all inputs from untrusted sources
3. Sandboxing is the responsibility of the host application
4. Never include sensitive data in components

## Future Extensions

- Signed components for authenticity
- Component marketplace integration
- Hot-reload support
- Network-loaded components
- Component editor tool