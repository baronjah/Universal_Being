# ==================================================
# UNIVERSAL BEING: DNA Visualizer
# TYPE: visual
# PURPOSE: Visual representation of Universal Being DNA
# COMPONENTS: None (visual only)
# SCENES: None (self-contained)
# ==================================================

extends Node2D

# ===== DNA VISUALIZATION =====

## Helix Properties
var helix_radius: float = 32.0
var helix_height: float = 64.0
var helix_segments: int = 16
var helix_rotation_speed: float = 0.5
var helix_animation_phase: float = 0.0

## Trait Visualization
var trait_points: Dictionary = {}  # category.trait -> Node2D
var trait_colors: Dictionary = {}  # category.trait -> Color
var trait_radii: Dictionary = {}  # category.trait -> float

## Strand Properties
var strand_width: float = 2.0
var strand_opacity: float = 0.8
var strand_colors: Dictionary = {
    "physical": Color(0.2, 0.8, 0.2, 0.8),  # Green
    "consciousness": Color(0.8, 0.2, 0.8, 0.8),  # Purple
    "interaction": Color(0.2, 0.2, 0.8, 0.8),  # Blue
    "essence": Color(0.8, 0.8, 0.2, 0.8)  # Yellow
}

# ===== CORE FUNCTIONS =====

func _ready() -> void:
    """Initialize DNA visualizer"""
    # Create helix strands
    create_helix_strands()
    
    # Setup interaction area
    setup_interaction_area()

func _process(delta: float) -> void:
    """Update DNA visualization"""
    # Update helix animation
    helix_animation_phase += delta * helix_rotation_speed
    update_helix_animation()
    
    # Update trait points
    update_trait_points()

# ===== HELIX CREATION =====

func create_helix_strands() -> void:
    """Create the DNA helix strands"""
    var base = $HelixBase
    
    # Create strands for each category
    for category in strand_colors:
        var strand = base.get_node_or_null(category.capitalize() + "Strand")
        if strand:
            create_strand_points(strand, category)

func create_strand_points(strand: Node2D, category: String) -> void:
    """Create points along a strand"""
    for i in range(helix_segments):
        var angle = (i * TAU) / helix_segments
        var point = Node2D.new()
        point.name = "Point%d" % i
        point.position = get_helix_point(angle, i)
        strand.add_child(point)

func get_helix_point(angle: float, segment: int) -> Vector2:
    """Calculate point position on helix"""
    var x = cos(angle) * helix_radius
    var y = (segment * helix_height / helix_segments) - (helix_height / 2)
    return Vector2(x, y)

# ===== HELIX ANIMATION =====

func update_helix_animation() -> void:
    """Update helix animation state"""
    var base = $HelixBase
    
    # Update each strand
    for category in strand_colors:
        var strand = base.get_node_or_null(category.capitalize() + "Strand")
        if strand:
            update_strand_animation(strand, category)

func update_strand_animation(strand: Node2D, category: String) -> void:
    """Update animation for a single strand"""
    for i in range(strand.get_child_count()):
        var point = strand.get_child(i)
        var angle = (i * TAU / helix_segments) + helix_animation_phase
        point.position = get_helix_point(angle, i)
        
        # Update trait points if they exist
        var trait_key = "%s.trait%d" % [category, i]
        if trait_points.has(trait_key):
            update_trait_point_animation(trait_key, point.position)

func update_trait_point_animation(trait_key: String, position: Vector2) -> void:
    """Update animation for a trait point"""
    var point = trait_points.get(trait_key)
    if point:
        point.position = position

# ===== TRAIT VISUALIZATION =====

func update_trait(category_name: String, trait_name: String, trait_color: Color) -> void:
    """Update visual representation of a trait"""
    var trait_key: String = "%s.%s" % [category_name, trait_name]
    trait_colors[trait_key] = trait_color
    
    # Create or update trait point
    if not trait_points.has(trait_key):
        create_trait_point(trait_key, category_name)
    
    # Update trait point appearance
    var point = trait_points[trait_key]
    if point:
        point.modulate = trait_color
        point.scale = Vector2.ONE * (0.5 + trait_color.v * 0.5)  # Size based on value

func create_trait_point(trait_key: String, category: String) -> void:
    """Create a new trait point"""
    var point = Node2D.new()
    point.name = "Trait_" + trait_key
    
    # Add visual representation
    var visual = ColorRect.new()
    visual.size = Vector2(8, 8)
    visual.color = trait_colors.get(trait_key, Color.WHITE)
    point.add_child(visual)
    
    # Add to trait points
    $TraitPoints.add_child(point)
    trait_points[trait_key] = point
    
    # Set initial position
    var strand = $HelixBase.get_node_or_null(category.capitalize() + "Strand")
    if strand and strand.get_child_count() > 0:
        point.position = strand.get_child(0).position

func update_trait_points() -> void:
    """Update all trait point positions"""
    for trait_key in trait_points:
        var point = trait_points[trait_key]
        if point:
            # Find closest helix point
            var category = trait_key.split(".")[0]
            var strand = $HelixBase.get_node_or_null(category.capitalize() + "Strand")
            if strand:
                var closest_point = find_closest_helix_point(point.position, strand)
                if closest_point:
                    point.position = closest_point.position

func find_closest_helix_point(position: Vector2, strand: Node2D) -> Node2D:
    """Find the closest point on the helix to a position"""
    var closest = null
    var min_distance = INF
    
    for point in strand.get_children():
        var distance = position.distance_to(point.position)
        if distance < min_distance:
            min_distance = distance
            closest = point
    
    return closest

# ===== INTERACTION =====

func setup_interaction_area() -> void:
    """Setup interaction area for trait selection"""
    var area = $InteractionArea
    if area:
        area.input_event.connect(_on_interaction_area_input)

func _on_interaction_area_input(viewport: Node, event: InputEvent, shape_idx: int) -> void:
    """Handle input on the DNA visualization"""
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            var clicked_trait = get_trait_at_position(event.position)
            if clicked_trait:
                trait_clicked.emit(clicked_trait)

func get_trait_at_position(position: Vector2) -> Dictionary:
    """Get trait information at a position"""
    for trait_key in trait_points:
        var point = trait_points[trait_key]
        if point and point.position.distance_to(position) < 16.0:
            var parts = trait_key.split(".")
            return {
                "category": parts[0],
                "trait": parts[1],
                "value": trait_colors[trait_key].v
            }
    return {}

# ===== SIGNALS =====

signal trait_clicked(trait_data: Dictionary)

# ===== EVOLUTION EFFECTS =====

func play_evolution_effect(trait_key: String) -> void:
    """Play visual effect for trait evolution"""
    var effects = $EvolutionEffects
    if not effects:
        return
    
    # Create evolution particle effect
    var effect = Node2D.new()
    effect.name = "Evolution_" + trait_key
    
    # Add particles
    var particles = GPUParticles2D.new()
    particles.amount = 16
    particles.lifetime = 1.0
    particles.one_shot = true
    particles.explosiveness = 0.8
    particles.emission_shape = 1  # Sphere
    particles.emission_sphere_radius = 16.0
    
    # Set particle properties
    var material = ParticleProcessMaterial.new()
    material.direction = Vector3(0, -1, 0)
    material.spread = 45.0
    material.gravity = Vector3(0, 98, 0)
    material.initial_velocity_min = 50.0
    material.initial_velocity_max = 100.0
    material.scale_min = 2.0
    material.scale_max = 4.0
    particles.process_material = material
    
    # Set particle color
    var color = trait_colors.get(trait_key, Color.WHITE)
    particles.modulate = color
    
    # Add to effect
    effect.add_child(particles)
    effects.add_child(effect)
    
    # Position effect
    var trait_point = trait_points.get(trait_key)
    if trait_point:
        effect.position = trait_point.position
    
    # Start effect
    particles.emitting = true
    
    # Cleanup after effect
    await get_tree().create_timer(particles.lifetime + 0.1).timeout
    effect.queue_free() 