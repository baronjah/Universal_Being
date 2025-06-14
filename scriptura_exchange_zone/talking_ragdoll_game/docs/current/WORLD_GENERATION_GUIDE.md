# World Generation & Bird System Guide

## Quick Start

1. Generate a world:
```
world           # Generate default 128x128 terrain
world 256       # Generate larger 256x256 terrain
```

2. Spawn birds:
```
bird            # Spawn a triangular physics bird
pigeon          # Same as bird
```

## What's New

### Heightmap World Generator
- **Terrain**: Generated from noise with island-like shape
- **Trees**: Placed on higher ground with fruits in canopy (torus pattern)
- **Bushes**: Placed randomly with fruits on sides
- **Water**: Pools in low areas where birds can drink
- **Colors**: Height-based (water=blue, beach=sand, grass=green, mountain=brown)

### Triangular Bird Physics
- **Structure**: 5 points connected by physics joints
  - Head (front elevated)
  - Left/Right wing tips (sides)
  - Left/Right legs (ground contact points)
  - Tail (back balance weight)
- **Walking**: Only legs touch ground, alternating lift pattern
- **Balance**: Tail acts as counterweight

### Bird AI Behavior
- **States**: Wandering, Seeking Food, Eating, Seeking Water, Drinking, Resting
- **Needs**: Hunger and thirst decrease over time
- **Detection**: Birds automatically find nearby fruits and water
- **Eating**: Birds peck at fruits until consumed
- **Drinking**: Birds approach water pools to drink

## Console Commands

```
world [size]        # Generate terrain (64-512)
bird               # Spawn AI-controlled bird
clear              # Clear all objects
list               # List spawned objects
```

## How It Works

1. **Terrain Generation**:
   - Uses FastNoiseLite for heightmap
   - Applies radial gradient for island shape
   - Creates mesh with vertex colors
   - Adds trimesh collision

2. **Vegetation Placement**:
   - Trees avoid water and steep slopes
   - Fruits placed in torus pattern around tree canopy
   - Bushes have fruits on their sides
   - All fruits are RigidBody3D (can fall when eaten)

3. **Bird Behavior**:
   - Birds walk on their leg tips only
   - Wings and head stay elevated
   - Tail moves opposite to maintain balance
   - AI makes them seek food when hungry
   - They peck at fruits to eat them

## Tips

- Generate world first, then spawn birds
- Birds will automatically explore and find food
- Watch them walk to fruits and peck at them
- They'll seek water when thirsty
- Multiple birds will compete for food

## Troubleshooting

- If birds don't walk properly, check console for physics errors
- If world is too slow, use smaller size (64 or 128)
- Birds may get stuck on steep terrain - they prefer flat areas
- Fruits start frozen on trees/bushes until disturbed