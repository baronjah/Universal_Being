# Fluid Simulation System for Godot 4.4

This is a comprehensive fluid simulation system for Godot 4.4 that can simulate water and other fluids in both 2D and 3D. It implements SPH (Smoothed Particle Hydrodynamics) for realistic fluid physics, with support for various fluid behaviors:

- Falling water
- Flowing streams
- Splashing effects
- Wave generation
- Merging and splitting
- Vortices and whirlpools

## Features

- **Accurate physics**: Implements full SPH fluid dynamics simulation
- **2D and 3D support**: Works in both 2D and 3D environments
- **Multiple rendering options**: Particles, metaballs, or mesh surfaces
- **Interactive**: Click and drag to interact with fluid
- **Customizable**: Adjust various parameters to achieve different fluid behaviors
- **Visual effects**: Refraction, reflection, foam, caustics, etc.
- **Optimized**: Spatial hashing for neighbor search, adaptive time steps
- **Easy integration**: Designed to be dropped into any Godot 4.4 project

## Getting Started

### Installation

1. Copy the following files to your Godot 4.4 project:
   - `fluid_simulation_core.gd`
   - `fluid_2d_renderer.gd`
   - `fluid_3d_renderer.gd`
   - `fluid_simulation_demo.gd` (optional)

2. Create a shader folder and include two custom shaders (optional):
   - `shaders/fluid_particle.gdshader`
   - `shaders/fluid_metaball.gdshader`

### Basic Usage

```gdscript
# Create a fluid simulation
var simulation = FluidSimulationCore.new()
add_child(simulation)

# Set up a renderer (2D or 3D)
var renderer = Fluid2DRenderer.new()  # or Fluid3DRenderer
add_child(renderer)
renderer.set_simulation(simulation)

# Create some fluid particles
simulation.create_fluid_cube(
    Vector3(-5, -5, -1),  # min position
    Vector3(5, 5, 1),     # max position
    0.5                   # particle spacing
)

# Run the simulation in _process
func _process(delta):
    simulation.simulate_step(delta)
```

## Common Fluid Patterns

### Creating a Water Pool

```gdscript
# Create a rectangular pool of water
simulation.create_fluid_cube(
    Vector3(-10, -5, -10),  # min position
    Vector3(10, 0, 10),     # max position
    0.5                     # particle spacing
)
```

### Creating a Splash

```gdscript
# Create a splash effect
simulation.create_splash(
    Vector3(0, 0, 0),  # center position
    2.0,               # radius
    100,               # particle count
    5.0                # force strength
)
```

### Creating a Wave

```gdscript
# Create a wave pattern
simulation.create_wave(
    Vector3(-10, 0, 0),  # start position
    20.0,                # width
    1.0,                 # height
    3,                   # wave count
    200                  # particle count
)
```

### Creating a Flowing Stream

```gdscript
# Create a flowing stream of particles
var positions = []
var velocities = []

for i in range(50):
    positions.append(Vector3(-10, 5, randf_range(-2, 2)))
    velocities.append(Vector3(5, 0, 0))  # Flowing right

simulation.create_particles(positions, velocities)
```

### Adding Forces

```gdscript
# Add a whirlpool/vortex
simulation.add_vortex(
    Vector3(0, 0, 0),  # center
    Vector3(0, 1, 0),  # axis (vertical)
    5.0,               # radius
    3.0                # strength
)

# Add a force field (like wind or attraction)
simulation.add_force_field(
    Vector3(0, 5, 0),  # center
    10.0,              # radius
    2.0                # strength (negative for attraction)
)
```

## Customization Options

### Fluid Physics Properties

```gdscript
# Adjust fluid properties
simulation.gravity = Vector3(0, -9.8, 0)
simulation.rest_density = 1000.0  # kg/m³
simulation.viscosity = 0.01       # Lower = more watery, Higher = more like honey
simulation.surface_tension = 0.072  # N/m
simulation.restitution = 0.3      # Bounce factor
```

### Simulation Settings

```gdscript
# Performance and quality settings
simulation.particle_mass = 0.02
simulation.smooth_radius = 0.1     # Interaction radius
simulation.max_particles = 10000   # Limit total particles
simulation.use_spatial_hashing = true  # For performance
simulation.adaptive_time_step = true   # For stability
```

### Rendering Settings (2D)

```gdscript
# 2D Rendering options
renderer2D.particle_size = 20.0
renderer2D.use_metaballs = true
renderer2D.metaball_threshold = 0.5
renderer2D.add_ripples = true
renderer2D.add_foam = true
renderer2D.gradient_top_color = Color(0.0, 0.6, 1.0, 0.8)
renderer2D.gradient_bottom_color = Color(0.0, 0.4, 0.8, 0.9)
```

### Rendering Settings (3D)

```gdscript
# 3D Rendering options
renderer3D.render_method = 1  # 0=Particles, 1=Metaballs, 2=Mesh Surface
renderer3D.surface_detail = 1.0
renderer3D.enable_refraction = true
renderer3D.enable_reflection = true
renderer3D.enable_foam = true
renderer3D.add_ripples = true
```

## Demo Usage

The included demo provides an easy way to experiment with different fluid effects:

```gdscript
# Create a fluid simulation demo
var demo = FluidSimulationDemo.new()
add_child(demo)

# Configure demo
demo.use_2d_mode = true
demo.demo_type = 0  # 0=Water Tank, 1=Wave, 2=Splash, 3=Dam Break, 4=Fountain, 5=Vortex
demo.enable_interaction = true
demo.auto_run = true
```

## How It Works

The fluid simulation uses Smoothed Particle Hydrodynamics (SPH), a technique that simulates fluids by representing them as particles that interact with each other:

1. **Density Calculation**: Calculate fluid density at each particle position using neighboring particles
2. **Pressure Calculation**: Calculate pressure from density using an equation of state
3. **Force Calculation**: Compute forces between particles (pressure, viscosity, surface tension)
4. **Integration**: Update velocities and positions using calculated forces
5. **Boundary Handling**: Ensure particles stay within bounds and handle collisions
6. **Rendering**: Visualize particles using various methods (individual particles, metaballs, mesh surfaces)

## Optimization Tips

For best performance:

1. Limit the maximum number of particles (`max_particles`)
2. Use spatial hashing (`use_spatial_hashing = true`)
3. Use adaptive time steps (`adaptive_time_step = true`)
4. Use frustum culling to skip rendering off-screen particles
5. Decrease `smooth_radius` for fewer interactions (but less accuracy)
6. Use instancing for particle rendering (`use_instancing = true`)
7. Use lower resolution for metaball rendering
8. Adjust surface detail based on distance from camera

## Requirements

- Godot 4.4 or higher
- Decent GPU for fluid visualization, especially in 3D
- For large simulations (10,000+ particles), a modern CPU is recommended

## Known Limitations

- Surface tension model is simplified
- No support for multi-phase fluids (e.g., water and oil)
- Limited interaction with complex colliders
- Metaball rendering can be performance-intensive in 3D
- Large simulations may run slowly on low-end hardware

## License

This fluid simulation system is free to use in any project, commercial or non-commercial.

## Credits

Created for the 12 Turns System project.

---

For questions or support, please open an issue on the project repository.