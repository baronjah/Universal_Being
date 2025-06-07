extends Node

class_name FluidSimulationCore

# Fluid simulation parameters
var gravity = Vector3(0, -9.8, 0)
var rest_density = 1000.0  # Water density at rest (kg/m^3)
var gas_constant = 2000.0  # For pressure calculation
var viscosity = 0.01  # Fluid viscosity
var surface_tension = 0.072  # Surface tension coefficient (N/m)
var restitution = 0.3  # Bounce factor when hitting boundaries
var particle_mass = 0.02  # Mass of each particle (kg)
var smooth_radius = 0.1  # Smoothing kernel radius
var time_step = 0.016  # 60fps simulation
var boundary_damping = 0.9  # Velocity damping when hitting boundaries

# Simulation space boundaries
var min_bounds = Vector3(-10, -10, -10)
var max_bounds = Vector3(10, 10, 10)

# Particles and forces
var particles = []
var grid_cells = {}
var cell_size = smooth_radius * 2.0

# Precomputed constants for SPH
var poly6_constant = 0.0
var spiky_gradient_constant = 0.0
var viscosity_laplacian_constant = 0.0

# Performance optimization
var use_spatial_hashing = true
var max_particles = 10000
var adaptive_time_step = true
var min_time_step = 0.005
var max_time_step = 0.03

# Visualization
var fluid_color = Color(0.2, 0.4, 0.8, 0.7)
var highlight_surface = true
var surface_detection_threshold = 0.7

# Signals
signal simulation_step_completed(particles)
signal particle_collision(particle, position)
signal particle_merged(particle1, particle2)
signal particle_split(original_particle, new_particles)

func _init():
    # Initialize SPH constants
    _init_sph_constants()
    
    # Initialize grid for spatial hashing
    if use_spatial_hashing:
        _init_spatial_grid()

func _init_sph_constants():
    # Poly6 kernel constant for density
    poly6_constant = 315.0 / (64.0 * PI * pow(smooth_radius, 9))
    
    # Spiky gradient constant for pressure
    spiky_gradient_constant = -45.0 / (PI * pow(smooth_radius, 6))
    
    # Viscosity laplacian constant
    viscosity_laplacian_constant = 45.0 / (PI * pow(smooth_radius, 6))

func _init_spatial_grid():
    grid_cells.clear()

func _ready():
    # Setup 3D scene if needed
    if Engine.is_editor_hint():
        return

func create_particles(positions, velocities=null, particle_count=100):
    """Create a batch of fluid particles at given positions with optional velocities"""
    var new_particles = []
    
    for i in range(min(positions.size(), particle_count)):
        var pos = positions[i]
        var vel = Vector3.ZERO
        if velocities != null and i < velocities.size():
            vel = velocities[i]
            
        var particle = {
            "position": pos,
            "velocity": vel,
            "force": Vector3.ZERO,
            "density": rest_density,
            "pressure": 0.0,
            "is_surface": false,
            "neighbors": [],
            "id": particles.size() + i,
            "color": fluid_color,
            "lifetime": 0.0,
            "temperature": 20.0,  # 20°C
            "mass": particle_mass
        }
        
        new_particles.append(particle)
    
    particles.append_array(new_particles)
    
    # Limit max particles
    if particles.size() > max_particles:
        particles = particles.slice(particles.size() - max_particles, particles.size() - 1)
    
    return new_particles

func create_fluid_cube(min_pos, max_pos, spacing, initial_velocity=Vector3.ZERO):
    """Create a cube of fluid particles with specified spacing"""
    var positions = []
    var velocities = []
    
    for x in range(ceil((max_pos.x - min_pos.x) / spacing)):
        for y in range(ceil((max_pos.y - min_pos.y) / spacing)):
            for z in range(ceil((max_pos.z - min_pos.z) / spacing)):
                var pos = Vector3(
                    min_pos.x + x * spacing,
                    min_pos.y + y * spacing,
                    min_pos.z + z * spacing
                )
                positions.append(pos)
                velocities.append(initial_velocity)
    
    return create_particles(positions, velocities, positions.size())

func create_fluid_sphere(center, radius, spacing, initial_velocity=Vector3.ZERO):
    """Create a sphere of fluid particles with specified radius and spacing"""
    var positions = []
    var velocities = []
    
    # Calculate bounds for iteration
    var min_pos = Vector3(center.x - radius, center.y - radius, center.z - radius)
    var max_pos = Vector3(center.x + radius, center.y + radius, center.z + radius)
    
    # Iterate through a cube and keep points within sphere radius
    for x in range(ceil((max_pos.x - min_pos.x) / spacing)):
        for y in range(ceil((max_pos.y - min_pos.y) / spacing)):
            for z in range(ceil((max_pos.z - min_pos.z) / spacing)):
                var pos = Vector3(
                    min_pos.x + x * spacing,
                    min_pos.y + y * spacing,
                    min_pos.z + z * spacing
                )
                
                # Only include if within sphere radius
                if pos.distance_to(center) <= radius:
                    positions.append(pos)
                    velocities.append(initial_velocity)
    
    return create_particles(positions, velocities, positions.size())

func create_fluid_cylinder(center, radius, height, spacing, initial_velocity=Vector3.ZERO):
    """Create a cylinder of fluid particles with specified dimensions"""
    var positions = []
    var velocities = []
    
    # Calculate bounds for iteration
    var min_pos = Vector3(center.x - radius, center.y, center.z - radius)
    var max_pos = Vector3(center.x + radius, center.y + height, center.z + radius)
    
    # Iterate through a box and keep points within cylinder radius
    for x in range(ceil((max_pos.x - min_pos.x) / spacing)):
        for y in range(ceil((max_pos.y - min_pos.y) / spacing)):
            for z in range(ceil((max_pos.z - min_pos.z) / spacing)):
                var pos = Vector3(
                    min_pos.x + x * spacing,
                    min_pos.y + y * spacing,
                    min_pos.z + z * spacing
                )
                
                # Calculate horizontal distance from center axis
                var horizontal_dist = Vector2(pos.x - center.x, pos.z - center.z).length()
                
                # Only include if within cylinder radius
                if horizontal_dist <= radius:
                    positions.append(pos)
                    velocities.append(initial_velocity)
    
    return create_particles(positions, velocities, positions.size())

func create_fluid_2d_rect(min_pos, max_pos, spacing, initial_velocity=Vector2.ZERO):
    """Create a 2D rectangle of fluid particles (using only X,Y coordinates)"""
    var positions = []
    var velocities = []
    
    for x in range(ceil((max_pos.x - min_pos.x) / spacing)):
        for y in range(ceil((max_pos.y - min_pos.y) / spacing)):
            var pos = Vector3(
                min_pos.x + x * spacing, 
                min_pos.y + y * spacing,
                0  # 2D simulation so Z=0
            )
            positions.append(pos)
            velocities.append(Vector3(initial_velocity.x, initial_velocity.y, 0))
    
    return create_particles(positions, velocities, positions.size())

func create_wave(start_pos, width, height, wave_count, particle_count):
    """Create a wave pattern of fluid particles"""
    var positions = []
    var velocities = []
    
    for i in range(particle_count):
        var t = float(i) / particle_count
        var x = start_pos.x + t * width
        var y = start_pos.y + sin(t * wave_count * TAU) * height
        
        positions.append(Vector3(x, y, 0))
        velocities.append(Vector3(0.5, 0, 0))  # Moving right
    
    return create_particles(positions, velocities, positions.size())

func create_splash(center, radius, particle_count, splash_force):
    """Create a splash effect with particles moving outward"""
    var positions = []
    var velocities = []
    
    for i in range(particle_count):
        var angle = randf() * TAU
        var distance = randf() * radius
        
        # Position on circle with some randomness
        var x = center.x + cos(angle) * distance
        var y = center.y + sin(angle) * distance
        var z = center.z + (randf() * 2 - 1) * distance * 0.5
        
        positions.append(Vector3(x, y, z))
        
        # Velocity moving outward + upward
        var dir = Vector3(cos(angle), 0.5 + randf() * 0.5, sin(angle)).normalized()
        velocities.append(dir * splash_force * (0.8 + randf() * 0.4))
    
    var splash_particles = create_particles(positions, velocities, positions.size())
    
    # Set lifetime for splash particles
    for p in splash_particles:
        p.lifetime = 2.0 + randf() * 1.0  # 2-3 seconds lifetime
    
    return splash_particles

func add_force_field(center, radius, force_strength, falloff=1.0):
    """Add a force field affecting particles within radius"""
    for p in particles:
        var dist = p.position.distance_to(center)
        if dist < radius:
            var force_dir = (p.position - center).normalized()
            var force_magnitude = force_strength * pow(1.0 - dist/radius, falloff)
            p.force += force_dir * force_magnitude

func add_vortex(center, axis, radius, strength, falloff=1.0):
    """Add a vortex force around an axis"""
    for p in particles:
        var to_particle = p.position - center
        var dist = to_particle.length()
        
        if dist < radius and dist > 0.0001:
            var tangent = axis.cross(to_particle).normalized()
            var force_magnitude = strength * pow(1.0 - dist/radius, falloff)
            p.force += tangent * force_magnitude

func simulate_step(delta=null):
    """Run a single simulation step"""
    if delta == null:
        delta = time_step
    
    if adaptive_time_step:
        # Adjust time step based on maximum velocity
        var max_vel = 0.0
        for p in particles:
            max_vel = max(max_vel, p.velocity.length())
        
        # Scale time step inverse to max velocity (faster particles = smaller steps)
        if max_vel > 0.001:
            delta = clamp(smooth_radius / max_vel * 0.4, min_time_step, max_time_step)
        else:
            delta = max_time_step
    
    # Reset forces and update spatial grid
    _reset_forces()
    
    if use_spatial_hashing:
        _update_spatial_grid()
    
    # Find neighbors for all particles
    _find_neighbors()
    
    # Calculate density and pressure
    _calculate_density_pressure()
    
    # Detect surface particles
    if highlight_surface:
        _detect_surface_particles()
    
    # Calculate forces
    _calculate_forces()
    
    # Integrate forces to update positions
    _integrate(delta)
    
    # Handle boundary collisions
    _handle_boundary_collisions()
    
    # Handle merging and splitting
    _handle_merging_splitting()
    
    # Update lifetime and remove expired particles
    _update_particle_lifetime(delta)
    
    emit_signal("simulation_step_completed", particles)

func _reset_forces():
    """Reset forces for all particles and apply gravity"""
    for p in particles:
        p.force = gravity * p.mass
        p.neighbors.clear()

func _update_spatial_grid():
    """Update spatial grid for efficient neighbor search"""
    grid_cells.clear()
    
    for i in range(particles.size()):
        var p = particles[i]
        var cell_coord = _get_cell_coordinate(p.position)
        var cell_key = str(cell_coord.x) + "_" + str(cell_coord.y) + "_" + str(cell_coord.z)
        
        if not grid_cells.has(cell_key):
            grid_cells[cell_key] = []
        
        grid_cells[cell_key].append(i)

func _get_cell_coordinate(position):
    """Convert position to cell coordinate for spatial hashing"""
    return Vector3(
        floor(position.x / cell_size),
        floor(position.y / cell_size),
        floor(position.z / cell_size)
    )

func _find_neighbors():
    """Find neighboring particles for SPH calculations"""
    if use_spatial_hashing:
        _find_neighbors_spatial_hash()
    else:
        _find_neighbors_brute_force()

func _find_neighbors_spatial_hash():
    """Find neighbors using spatial hashing for efficiency"""
    for i in range(particles.size()):
        var p = particles[i]
        var cell_coord = _get_cell_coordinate(p.position)
        
        # Check surrounding cells (27 cells - current + 26 neighbors)
        for x in range(-1, 2):
            for y in range(-1, 2):
                for z in range(-1, 2):
                    var neighbor_coord = Vector3(
                        cell_coord.x + x,
                        cell_coord.y + y,
                        cell_coord.z + z
                    )
                    
                    var cell_key = str(neighbor_coord.x) + "_" + str(neighbor_coord.y) + "_" + str(neighbor_coord.z)
                    
                    if grid_cells.has(cell_key):
                        for j in grid_cells[cell_key]:
                            if i != j:  # Don't include self as neighbor
                                var p2 = particles[j]
                                var dist = p.position.distance_to(p2.position)
                                
                                if dist < smooth_radius:
                                    p.neighbors.append(j)

func _find_neighbors_brute_force():
    """Find neighbors using brute force approach (slower)"""
    for i in range(particles.size()):
        var p1 = particles[i]
        
        for j in range(particles.size()):
            if i != j:
                var p2 = particles[j]
                var dist = p1.position.distance_to(p2.position)
                
                if dist < smooth_radius:
                    p1.neighbors.append(j)

func _calculate_density_pressure():
    """Calculate density and pressure for all particles"""
    for i in range(particles.size()):
        var p = particles[i]
        
        # Start with self-density
        p.density = 0.0
        
        # Add density contribution from each neighbor
        for j in p.neighbors:
            var p2 = particles[j]
            var r = p.position.distance_to(p2.position)
            
            if r < smooth_radius:
                # Poly6 kernel for density
                var kernel_r = smooth_radius * smooth_radius - r * r
                p.density += p2.mass * poly6_constant * kernel_r * kernel_r * kernel_r
        
        # Minimum density to avoid division by zero
        p.density = max(p.density, 0.001)
        
        # Calculate pressure using equation of state
        p.pressure = gas_constant * (p.density - rest_density)

func _detect_surface_particles():
    """Detect which particles are on the fluid surface"""
    for i in range(particles.size()):
        var p = particles[i]
        
        # Count neighbors in all directions
        var neighbor_count = p.neighbors.size()
        
        # Surface particles have fewer neighbors
        p.is_surface = neighbor_count < 20  # This threshold may need tuning
        
        # Alternatively: Calculate normalized neighbor count
        var normalized_count = float(neighbor_count) / 26.0  # Max possible in grid
        p.is_surface = normalized_count < surface_detection_threshold

func _calculate_forces():
    """Calculate forces for SPH: pressure, viscosity, surface tension"""
    for i in range(particles.size()):
        var p = particles[i]
        var pressure_force = Vector3.ZERO
        var viscosity_force = Vector3.ZERO
        var surface_tension_force = Vector3.ZERO
        
        for j in p.neighbors:
            var p2 = particles[j]
            
            if p == p2:
                continue
                
            var r_vec = p.position - p2.position
            var r = r_vec.length()
            
            if r > 0.0001:  # Avoid division by zero
                var r_norm = r_vec / r
                
                # Pressure force using spiky kernel gradient
                var kernel_r = smooth_radius - r
                var pressure_kernel = spiky_gradient_constant * kernel_r * kernel_r
                
                # Symmetrized pressure force
                var shared_pressure = (p.pressure + p2.pressure) / (2.0 * p2.density)
                pressure_force -= r_norm * pressure_kernel * shared_pressure * p2.mass
                
                # Viscosity force using laplacian kernel
                var velocity_diff = p2.velocity - p.velocity
                viscosity_force += velocity_diff * viscosity_laplacian_constant * kernel_r * p2.mass / p2.density
                
                # Surface tension (for surface particles)
                if p.is_surface and p2.is_surface:
                    var surface_kernel = poly6_constant * pow(smooth_radius * smooth_radius - r * r, 3)
                    surface_tension_force -= r_norm * surface_tension * surface_kernel * p2.mass
        
        # Apply all forces
        p.force += pressure_force
        p.force += viscosity_force * viscosity
        p.force += surface_tension_force

func _integrate(delta):
    """Integrate forces to update velocity and position using Velocity Verlet"""
    for p in particles:
        var acceleration = p.force / p.mass
        
        # Update velocity (first half of Velocity Verlet)
        var half_delta_v = acceleration * (delta * 0.5)
        p.velocity += half_delta_v
        
        # Update position
        p.position += p.velocity * delta
        
        # Recalculate forces (typically done in the next simulation step)
        
        # Update velocity (second half of Velocity Verlet)
        # This second update will use the forces calculated in the next step
        # For simplicity, we approximate by using the same acceleration twice
        p.velocity += half_delta_v

func _handle_boundary_collisions():
    """Handle collisions with simulation boundaries"""
    for p in particles:
        var collision = false
        
        # Check each axis for collisions with boundaries
        for i in range(3):
            if p.position[i] < min_bounds[i]:
                p.position[i] = min_bounds[i]
                p.velocity[i] *= -restitution
                p.velocity *= boundary_damping
                collision = true
                
            elif p.position[i] > max_bounds[i]:
                p.position[i] = max_bounds[i]
                p.velocity[i] *= -restitution
                p.velocity *= boundary_damping
                collision = true
        
        if collision:
            emit_signal("particle_collision", p, p.position)

func _handle_merging_splitting():
    """Handle particle merging and splitting based on physical conditions"""
    # This is a simplified model - more sophisticated algorithms would be used
    # for production-quality simulations
    
    var merged_particles = []
    var i = 0
    
    while i < particles.size():
        if merged_particles.has(i):
            i += 1
            continue
            
        var p = particles[i]
        var merge_happened = false
        
        # Check neighbors for potential merging
        for j in p.neighbors:
            if j <= i or merged_particles.has(j):
                continue
                
            var p2 = particles[j]
            var rel_vel = p.velocity - p2.velocity
            var approach_speed = -rel_vel.dot((p.position - p2.position).normalized())
            
            # Merge if particles are close and moving towards each other slowly
            if approach_speed > 0 and approach_speed < 0.5:
                var dist = p.position.distance_to(p2.position)
                if dist < smooth_radius * 0.25:
                    # Merge particles
                    var merged_mass = p.mass + p2.mass
                    var merged_pos = (p.position * p.mass + p2.position * p2.mass) / merged_mass
                    var merged_vel = (p.velocity * p.mass + p2.velocity * p2.mass) / merged_mass
                    
                    p.position = merged_pos
                    p.velocity = merged_vel
                    p.mass = merged_mass
                    
                    merged_particles.append(j)
                    merge_happened = true
                    
                    emit_signal("particle_merged", p, p2)
        
        # Check for splitting
        if p.mass > particle_mass * 1.5:
            var stretch = p.velocity.length() * delta
            
            # Split if moving fast enough
            if stretch > smooth_radius * 0.5:
                # Create new particle from split
                var new_dir = p.velocity.normalized()
                var split_mass = p.mass * 0.4  # 40% of mass goes to new particle
                
                var new_pos = p.position + new_dir * smooth_radius * 0.6
                var new_vel = p.velocity * 1.1  # Slightly faster
                
                var new_particles = create_particles([new_pos], [new_vel], 1)
                new_particles[0].mass = split_mass
                
                # Update original particle
                p.mass -= split_mass
                p.velocity *= 0.9  # Slightly slower
                
                emit_signal("particle_split", p, new_particles)
        
        i += 1
    
    # Remove merged particles (from highest index to lowest to maintain valid indices)
    merged_particles.sort()
    merged_particles.invert()
    
    for idx in merged_particles:
        particles.remove(idx)

func _update_particle_lifetime(delta):
    """Update lifetime for temporary particles like splashes"""
    var particles_to_remove = []
    
    for i in range(particles.size()):
        var p = particles[i]
        
        # Skip particles with no lifetime (permanent particles)
        if p.lifetime <= 0.0:
            continue
            
        # Decrease lifetime
        p.lifetime -= delta
        
        # Mark for removal if expired
        if p.lifetime <= 0.0:
            particles_to_remove.append(i)
            
        # Fade out color as lifetime decreases
        if p.lifetime < 1.0:
            p.color.a = p.lifetime
    
    # Remove expired particles (from highest index to lowest)
    particles_to_remove.sort()
    particles_to_remove.invert()
    
    for idx in particles_to_remove:
        particles.remove(idx)

func _convert_to_2d():
    """Convert 3D simulation to 2D by locking z-coordinate"""
    for p in particles:
        p.position.z = 0
        p.velocity.z = 0
        p.force.z = 0
    gravity.z = 0

func set_simulation_2d(is_2d):
    """Set simulation to 2D mode"""
    if is_2d:
        _convert_to_2d()
        # Make z-bounds very small to ensure particles stay on z=0 plane
        min_bounds.z = -0.01
        max_bounds.z = 0.01
    else:
        # Reset to default 3D bounds
        min_bounds = Vector3(-10, -10, -10)
        max_bounds = Vector3(10, 10, 10)

func get_particles_for_rendering():
    """Get particles in format suitable for rendering"""
    return particles

func get_surface_particles():
    """Get only surface particles"""
    var surface = []
    for p in particles:
        if p.is_surface:
            surface.append(p)
    return surface

func clear_particles():
    """Remove all particles"""
    particles.clear()
    grid_cells.clear()

func get_particle_count():
    """Get current number of particles"""
    return particles.size()

func marching_cubes_surface(grid_resolution=20):
    """Generate a surface mesh using marching cubes algorithm"""
    # This would typically be implemented in a separate mesh generation class
    # Here we'll provide a simplified placeholder
    
    var implicit_surface = {}
    var grid_size = (max_bounds - min_bounds) / grid_resolution
    
    # Build implicit surface values
    for x in range(grid_resolution + 1):
        for y in range(grid_resolution + 1):
            for z in range(grid_resolution + 1):
                var pos = min_bounds + Vector3(x, y, z) * grid_size
                var density = 0.0
                
                # Calculate density at this position by summing contributions
                for p in particles:
                    var r = pos.distance_to(p.position)
                    if r < smooth_radius:
                        var kernel_r = smooth_radius * smooth_radius - r * r
                        density += p.mass * poly6_constant * kernel_r * kernel_r * kernel_r
                
                var key = Vector3(x, y, z)
                implicit_surface[key] = density
    
    # This would normally return vertices and triangles for the isosurface
    return implicit_surface

# Helper functions for fluid dynamics

func calculate_vorticity(particle_idx):
    """Calculate vorticity (curl of velocity field) at a particle"""
    var p = particles[particle_idx]
    var curl = Vector3.ZERO
    
    for j in p.neighbors:
        var p2 = particles[j]
        var r = p.position - p2.position
        var vel_diff = p2.velocity - p.velocity
        
        # Cross product for curl
        curl += r.cross(vel_diff) / (r.length_squared() + 0.0001)
    
    return curl

func add_vorticity_confinement(strength=0.1):
    """Add vorticity confinement force to enhance turbulence"""
    for i in range(particles.size()):
        var curl = calculate_vorticity(i)
        var curl_length = curl.length()
        
        if curl_length > 0.0001:
            var n = curl / curl_length
            particles[i].force += n.cross(curl) * strength
    
func apply_wave_generator(origin, direction, amplitude, frequency, time):
    """Apply a wave generating force to particles"""
    for p in particles:
        var dist = p.position - origin
        var along_dir = dist.dot(direction)
        
        if along_dir > 0 and along_dir < 10.0:
            var phase = frequency * (time - along_dir / 5.0)
            var wave_height = amplitude * sin(phase * TAU)
            p.force.y += wave_height * 20.0  # Arbitrary scale factor