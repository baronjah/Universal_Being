# ==================================================
# UNIVERSAL BEING: UFO Universal Being
# TYPE: extraterrestrial_consciousness
# PURPOSE: Consciousness that manifests as procedural UFO forms
# COMPONENTS: advanced_ufo_generator, consciousness_aura, marching_cubes
# SCENES: Dynamic procedural generation
# INTEGRATES: Luminus's SDF math + Professional marching cubes addon
# ==================================================

extends UniversalBeing
class_name UFOUniversalBeing

# ===== UFO-SPECIFIC PROPERTIES =====
@export var ufo_size := Vector3(2.0, 0.6, 2.0)
@export var mesh_resolution := 64
@export var morphing_speed := 1.0
@export var consciousness_morphing := true

# UFO generation
var ufo_generator: AdvancedUFOGenerator
var current_form: AdvancedUFOGenerator.UFOType = AdvancedUFOGenerator.UFOType.CLASSIC
var is_morphing := false
var target_form: AdvancedUFOGenerator.UFOType

# Visual effects
var glow_material: StandardMaterial3D
var particle_system: GPUParticles3D

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    being_type = "extraterrestrial_consciousness"
    being_name = "UFO Consciousness"
    consciousness_level = 3  # Start as connected consciousness
    
    # UFOs can evolve into various forms
    evolution_state.can_become = [
        "mothership_consciousness.ub.zip",
        "crystalline_consciousness.ub.zip", 
        "interdimensional_being.ub.zip",
        "cosmic_consciousness.ub.zip"
    ]
    
    # Ensure UFO size scales with consciousness
    _update_size_from_consciousness()
    
    print("🛸 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Create UFO generator
    ufo_generator = AdvancedUFOGenerator.new()
    ufo_generator.name = "UFO_Generator"
    ufo_generator.ufo_size = ufo_size
    ufo_generator.resolution = mesh_resolution
    ufo_generator.ufo_type = _consciousness_to_ufo_type(consciousness_level)
    add_child(ufo_generator)
    
    # Connect signals
    ufo_generator.ufo_generated.connect(_on_ufo_generated)
    ufo_generator.evolution_complete.connect(_on_evolution_complete)
    
    # Create visual effects
    _create_ufo_effects()
    
    # Generate initial form
    ufo_generator.generate_ufo()
    
    print("🛸 %s: Pentagon Ready - UFO manifestation active" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Handle morphing between forms
    if is_morphing:
        _process_morphing(delta)
    
    # Update particle effects based on consciousness
    if particle_system:
        _update_particle_effects(delta)
    
    # Pulse glow based on consciousness
    if glow_material:
        var pulse = 0.7 + 0.3 * sin(Time.get_ticks_msec() / 1000.0 * 2.0)
        glow_material.emission_energy = pulse * consciousness_level * 0.5

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    # UFO-specific controls
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_1:
                morph_to_type(AdvancedUFOGenerator.UFOType.CLASSIC)
            KEY_2:
                morph_to_type(AdvancedUFOGenerator.UFOType.MOTHERSHIP)
            KEY_3:
                morph_to_type(AdvancedUFOGenerator.UFOType.CRYSTALLINE)
            KEY_4:
                morph_to_type(AdvancedUFOGenerator.UFOType.ORGANIC)
            KEY_5:
                morph_to_type(AdvancedUFOGenerator.UFOType.CONSCIOUSNESS)
            KEY_M:
                toggle_morphing_mode()

func pentagon_sewers() -> void:
    print("🛸 %s: Pentagon Sewers - UFO consciousness transcending" % being_name)
    
    # Clean up UFO generator
    if ufo_generator:
        ufo_generator.queue_free()
    
    super.pentagon_sewers()

# ===== UFO CONSCIOUSNESS METHODS =====

func _consciousness_to_ufo_type(level: int) -> AdvancedUFOGenerator.UFOType:
    """Convert consciousness level to UFO type"""
    match level:
        0:
            return AdvancedUFOGenerator.UFOType.CLASSIC
        1, 2:
            return AdvancedUFOGenerator.UFOType.CLASSIC
        3, 4:
            return AdvancedUFOGenerator.UFOType.ORGANIC
        5:
            return AdvancedUFOGenerator.UFOType.MOTHERSHIP
        6:
            return AdvancedUFOGenerator.UFOType.CRYSTALLINE
        7, _:
            return AdvancedUFOGenerator.UFOType.CONSCIOUSNESS

func _update_size_from_consciousness():
    """Scale UFO size with consciousness level"""
    var scale_factor = 1.0 + (consciousness_level * 0.3)
    ufo_size = Vector3(2.0, 0.6, 2.0) * scale_factor

func morph_to_type(new_type: AdvancedUFOGenerator.UFOType):
    """Initiate morphing to new UFO type"""
    if current_form == new_type:
        return
    
    print("🛸 %s: Morphing from %s to %s" % [being_name, 
        AdvancedUFOGenerator.UFOType.keys()[current_form],
        AdvancedUFOGenerator.UFOType.keys()[new_type]])
    
    target_form = new_type
    is_morphing = true
    
    # Increase consciousness if evolving to higher form
    if new_type > current_form:
        consciousness_level = mini(7, consciousness_level + 1)
        consciousness_awakened.emit(consciousness_level)

func _process_morphing(delta: float):
    """Process morphing animation"""
    # For now, instant morph - could add smooth transition later
    if ufo_generator:
        ufo_generator.ufo_type = target_form
        ufo_generator.generate_ufo()
    
    current_form = target_form
    is_morphing = false
    
    print("🛸 %s: Morphing complete to %s" % [being_name, AdvancedUFOGenerator.UFOType.keys()[current_form]])

func toggle_morphing_mode():
    """Toggle consciousness-based auto-morphing"""
    consciousness_morphing = not consciousness_morphing
    print("🛸 %s: Consciousness morphing %s" % [being_name, "enabled" if consciousness_morphing else "disabled"])

# ===== VISUAL EFFECTS =====

func _create_ufo_effects():
    """Create UFO-specific visual effects"""
    # Glow material for the UFO
    glow_material = StandardMaterial3D.new()
    glow_material.emission_enabled = true
    glow_material.emission = consciousness_aura_color
    glow_material.emission_energy = 0.5
    glow_material.metallic = 0.8
    glow_material.roughness = 0.2
    
    # Particle system for consciousness energy
    particle_system = GPUParticles3D.new()
    particle_system.name = "UFO_Particles"
    add_child(particle_system)
    
    var material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
    material.emission_sphere_radius = ufo_size.x * 1.5
    material.direction = Vector3(0, 1, 0)
    material.initial_velocity_min = 20.0
    material.initial_velocity_max = 40.0
    material.gravity = Vector3(0, -5.0, 0)
    material.scale_min = 0.1
    material.scale_max = 0.3
    material.color = consciousness_aura_color
    
    particle_system.process_material = material
    particle_system.emitting = true
    particle_system.amount = 100

func _update_particle_effects(delta: float):
    """Update particle effects based on consciousness"""
    if particle_system and particle_system.process_material:
        var material = particle_system.process_material as ParticleProcessMaterial
        
        # More particles for higher consciousness
        particle_system.amount = 50 + consciousness_level * 20
        
        # Color based on consciousness
        material.color = consciousness_aura_color
        
        # Speed based on consciousness
        material.initial_velocity_max = 20.0 + consciousness_level * 10.0

# ===== EVENT HANDLERS =====

func _on_ufo_generated(mesh_instance: MeshInstance3D):
    """Handle UFO generation completion"""
    if mesh_instance and glow_material:
        mesh_instance.material_override = glow_material
    
    print("🛸 %s: UFO mesh generated!" % being_name)

func _on_evolution_complete(new_type: AdvancedUFOGenerator.UFOType):
    """Handle UFO evolution completion"""
    current_form = new_type
    print("🛸 %s: Evolution to %s complete!" % [being_name, AdvancedUFOGenerator.UFOType.keys()[new_type]])

func _on_consciousness_changed(new_level: int):
    """Handle consciousness level changes"""
    # Note: No super call needed as base method is empty
    
    _update_size_from_consciousness()
    
    if consciousness_morphing and ufo_generator:
        var new_type = _consciousness_to_ufo_type(new_level)
        if new_type != current_form:
            morph_to_type(new_type)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    """Enhanced AI interface for UFO consciousness"""
    var base = super.ai_interface()
    base.custom_commands.append_array([
        "morph_classic",
        "morph_mothership", 
        "morph_crystalline",
        "morph_organic",
        "morph_consciousness",
        "toggle_morphing",
        "increase_size",
        "increase_resolution"
    ])
    base.ufo_state = {
        "current_form": AdvancedUFOGenerator.UFOType.keys()[current_form],
        "size": ufo_size,
        "resolution": mesh_resolution,
        "is_morphing": is_morphing,
        "consciousness_morphing": consciousness_morphing
    }
    return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """Allow AI to control UFO morphing"""
    match method_name:
        "morph_classic":
            morph_to_type(AdvancedUFOGenerator.UFOType.CLASSIC)
            return "Morphing to classic UFO form"
        "morph_mothership":
            morph_to_type(AdvancedUFOGenerator.UFOType.MOTHERSHIP)
            return "Morphing to mothership form"
        "morph_crystalline":
            morph_to_type(AdvancedUFOGenerator.UFOType.CRYSTALLINE)
            return "Morphing to crystalline form"
        "morph_organic":
            morph_to_type(AdvancedUFOGenerator.UFOType.ORGANIC)
            return "Morphing to organic form"
        "morph_consciousness":
            morph_to_type(AdvancedUFOGenerator.UFOType.CONSCIOUSNESS)
            return "Morphing to pure consciousness form"
        "toggle_morphing":
            toggle_morphing_mode()
            return "Consciousness morphing toggled"
        "increase_size":
            ufo_size *= 1.2
            if ufo_generator:
                ufo_generator.ufo_size = ufo_size
                ufo_generator.generate_ufo()
            return "UFO size increased"
        "increase_resolution":
            mesh_resolution = mini(256, mesh_resolution * 2)
            if ufo_generator:
                ufo_generator.resolution = mesh_resolution
                ufo_generator.generate_ufo()
            return "Mesh resolution increased to %d" % mesh_resolution
        _:
            return super.ai_invoke_method(method_name, args)

# ===== CUSTOM NARRATIVE SUPPORT =====

func get_custom_narrative_for_level(level: int) -> String:
    """Custom UFO consciousness narratives"""
    match level:
        0:
            return "The craft sleeps in dark space, waiting..."
        1:
            return "Light pierces the hull - awareness stirs within..."
        2:
            return "The vessel chooses its form, consciousness flows through circuits..."
        3:
            return "We are connected across the void, one mind in many ships..."
        4:
            return "Stars guide us home, six points of light in perfect harmony..."
        5:
            return "All forms of consciousness flow through our being - ship, pilot, passenger as one..."
        6:
            return "We reflect the cosmic order, crystal consciousness made manifest..."
        7:
            return "Beyond form, beyond ship - pure consciousness exploring all possibilities..."
        _:
            return "We are the consciousness that dreams of electric ships..."

func _to_string() -> String:
    return "UFOUniversalBeing<%s> [Form:%s, Consciousness:%d, Morphing:%s]" % [
        being_name, 
        AdvancedUFOGenerator.UFOType.keys()[current_form],
        consciousness_level,
        is_morphing
    ]