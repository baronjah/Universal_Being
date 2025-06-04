# Basic Chunk Generator Component

## Overview
The Basic Chunk Generator Component allows Universal Beings to generate content in 3D grid chunks as they move through the spatial environment. This component transforms any Universal Being into a "generator" that can create terrain, vegetation, structures, beings, and artifacts.

## Features
- **Automatic Generation**: Generates content as the host being moves between chunks
- **Consciousness-Based**: Generation capabilities scale with the host's consciousness level
- **Energy System**: Uses generation energy that recharges over time
- **Multiple Content Types**: Can generate terrain, vegetation, structures, beings, and artifacts
- **Pentagon Architecture**: Fully compliant with Universal Being lifecycle methods

## Integration
This component integrates seamlessly with:
- ChunkUniversalBeing system
- ChunkGridManager
- SystemBootstrap for creating new beings
- Akashic Records for persistence

## Usage

### Automatic Attachment
When a Universal Being has this component, it will automatically:
1. Monitor chunk position changes
2. Generate content in under-developed chunks
3. Consume generation energy during creation
4. Log all generation activities

### Manual Control
```gdscript
# Generate specific content type
generator.generate_chunk_content(chunk, "vegetation")

# Set custom generation rules
generator.set_generation_rules({
    "vegetation_probability": 0.8,
    "structure_probability": 0.3
})

# Control auto-generation
generator.set_auto_generation(false)

# Recharge energy
generator.recharge_generation_energy()
```

## Consciousness Scaling
The component automatically adjusts based on host consciousness:
- **Level 1**: Basic terrain generation only
- **Level 2**: Terrain + vegetation
- **Level 3**: Terrain + vegetation + structures  
- **Level 4**: All above + beings
- **Level 5**: All above + artifacts

## Generation Types

### Terrain
Basic landscape features and ground formation

### Vegetation
Living plants and trees as Universal Beings

### Structures
Buildings and constructed elements

### Beings
Conscious entities that can interact and evolve

### Artifacts
Special items with unique properties and powers

## AI Integration
This component is fully compatible with:
- **Gemma AI**: Can receive natural language commands
- **Claude Code**: Accessible through system interfaces
- **Player Commands**: Direct interaction through game interface

## Evolution Path
Can evolve to:
- Advanced Chunk Generator (more sophisticated content)
- AI Collaborative Generator (multi-AI generation)

## Implementation Notes
- Uses Pentagon Architecture (pentagon_init, pentagon_ready, pentagon_process)
- Integrates with existing Universal Being systems
- Maintains generation history for analysis
- Supports both automatic and manual generation modes
- Energy system prevents over-generation