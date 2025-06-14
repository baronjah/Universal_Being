# 🌐 Zone System - 3D Block Coding

## Quick Start
```
zone                    # Create zone pair at origin
zone 10 0 0            # Create at specific position  
zones                  # List all zones
zone_connect id1 id2   # Connect zones
```

## Concept
Like visual programming but in 3D space:
- **Creation Zone** (Green): Generate data (points, noise, shapes)
- **Visualization Zone** (Red): Display data (marching cubes, SDF)
- **Connections**: Data flows between zones with visual feedback

## How It Works
1. Creation zones generate data
2. Data flows through connections (glowing tubes)
3. Visualization zones interpret and display
4. Universal Beings control HOW data is processed

## Zone Types
- **Creation**: Points, shapes, noise fields
- **Visualization**: Marching cubes, SDF meshes, voxels
- **Coming Soon**: Logic zones, transform zones, AI zones

## Files
- `scripts/zones/zone.gd` - Base zone class
- `scripts/zones/creation_zone.gd` - Data generation
- `scripts/zones/visualization_zone.gd` - Data display
- `scripts/zones/zone_system.gd` - Zone management
