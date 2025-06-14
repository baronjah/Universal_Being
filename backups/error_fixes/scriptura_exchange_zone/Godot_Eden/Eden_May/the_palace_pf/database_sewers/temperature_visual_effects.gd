extends Node

# Temperature Visual Effects System
# Handles visual representation of temperature states in the Notepad3D system

const FROZEN_COLOR = Color(0.7, 0.9, 1.0, 0.8)
const COLD_COLOR = Color(0.8, 0.95, 1.0, 0.6)
const NORMAL_COLOR = Color(1.0, 1.0, 1.0, 0.3)
const WARM_COLOR = Color(1.0, 0.9, 0.7, 0.4)
const HOT_COLOR = Color(1.0, 0.7, 0.4, 0.5)
const BOILING_COLOR = Color(1.0, 0.5, 0.2, 0.7)
const PLASMA_COLOR = Color(0.8, 0.4, 1.0, 0.9)

# Particle scenes for different temperature states
var particle_scenes = {
    "FROZEN": preload("res://particles/frozen_particles.tscn"),
    "COLD": preload("res://particles/cold_particles.tscn"),
    "WARM": preload("res://particles/warm_particles.tscn"),
    "HOT": preload("res://particles/hot_particles.tscn"),
    "BOILING": preload("res://particles/boiling_particles.tscn"),
    "PLASMA": preload("res://particles/plasma_particles.tscn")
}

# References to systems
var temperature_system
var word_manifestation_system

# Current active particle instances
var active_particles = {}

func _ready():
    # Get references to required systems
    temperature_system = get_node("/root/TemperatureSystem")
    word_manifestation_system = get_node("/root/WordManifestationSystem")
    
    # Connect to temperature change signal
    temperature_system.connect("temperature_changed", self, "_on_temperature_changed")
    
    # Connect to word creation signal
    word_manifestation_system.connect("word_created", self, "_on_word_created")
    word_manifestation_system.connect("word_removed", self, "_on_word_removed")
    
    # Apply initial temperature effects
    apply_global_temperature_effects(temperature_system.current_temperature_state)

# Update word material based on temperature
func apply_temperature_material(word_node, temp_state):
    if not is_instance_valid(word_node):
        return
        
    var material = word_node.get_material_override().duplicate()
    
    # Apply color tint based on temperature
    match temp_state:
        temperature_system.TemperatureState.FROZEN:
            material.albedo_color = FROZEN_COLOR
            material.metallic = 0.9
            material.roughness = 0.1
        temperature_system.TemperatureState.COLD:
            material.albedo_color = COLD_COLOR
            material.metallic = 0.6
            material.roughness = 0.3
        temperature_system.TemperatureState.NORMAL:
            material.albedo_color = NORMAL_COLOR
            material.metallic = 0.3
            material.roughness = 0.5
        temperature_system.TemperatureState.WARM:
            material.albedo_color = WARM_COLOR
            material.metallic = 0.2
            material.roughness = 0.6
        temperature_system.TemperatureState.HOT:
            material.albedo_color = HOT_COLOR
            material.metallic = 0.1
            material.roughness = 0.7
            material.emission_enabled = true
            material.emission = HOT_COLOR
            material.emission_energy = 0.5
        temperature_system.TemperatureState.BOILING:
            material.albedo_color = BOILING_COLOR
            material.metallic = 0.0
            material.roughness = 0.8
            material.emission_enabled = true
            material.emission = BOILING_COLOR
            material.emission_energy = 1.0
        temperature_system.TemperatureState.PLASMA:
            material.albedo_color = PLASMA_COLOR
            material.metallic = 0.0
            material.roughness = 0.2
            material.emission_enabled = true
            material.emission = PLASMA_COLOR
            material.emission_energy = 2.0
    
    word_node.set_material_override(material)

# Add temperature particles to a word
func apply_temperature_particles(word_node, temp_state, word_id):
    # Remove any existing particles
    remove_temperature_particles(word_id)
    
    # Don't add particles for normal temperature
    if temp_state == temperature_system.TemperatureState.NORMAL:
        return
    
    # Get the appropriate particle scene
    var particle_scene
    match temp_state:
        temperature_system.TemperatureState.FROZEN:
            particle_scene = particle_scenes["FROZEN"]
        temperature_system.TemperatureState.COLD:
            particle_scene = particle_scenes["COLD"]
        temperature_system.TemperatureState.WARM:
            particle_scene = particle_scenes["WARM"]
        temperature_system.TemperatureState.HOT:
            particle_scene = particle_scenes["HOT"]
        temperature_system.TemperatureState.BOILING:
            particle_scene = particle_scenes["BOILING"]
        temperature_system.TemperatureState.PLASMA:
            particle_scene = particle_scenes["PLASMA"]
    
    if particle_scene:
        var particles = particle_scene.instance()
        word_node.add_child(particles)
        active_particles[word_id] = particles

# Remove temperature particles from a word
func remove_temperature_particles(word_id):
    if active_particles.has(word_id):
        if is_instance_valid(active_particles[word_id]):
            active_particles[word_id].queue_free()
        active_particles.erase(word_id)

# Apply temperature effects to the global environment
func apply_global_temperature_effects(temp_state):
    var world_environment = get_node_or_null("/root/Main/WorldEnvironment")
    if not world_environment:
        return
    
    var environment = world_environment.environment.duplicate()
    
    # Apply environmental effects based on temperature
    match temp_state:
        temperature_system.TemperatureState.FROZEN:
            environment.background_color = Color(0.7, 0.8, 0.9)
            environment.fog_enabled = true
            environment.fog_color = Color(0.8, 0.9, 1.0)
            environment.fog_depth_begin = 10
            environment.fog_depth_end = 50
            environment.dof_blur_far_enabled = true
            environment.dof_blur_far_distance = 20
            environment.dof_blur_far_amount = 0.05
        
        temperature_system.TemperatureState.COLD:
            environment.background_color = Color(0.8, 0.9, 0.95)
            environment.fog_enabled = true
            environment.fog_color = Color(0.9, 0.95, 1.0)
            environment.fog_depth_begin = 20
            environment.fog_depth_end = 70
            environment.dof_blur_far_enabled = false
        
        temperature_system.TemperatureState.NORMAL:
            environment.background_color = Color(0.9, 0.9, 0.9)
            environment.fog_enabled = false
            environment.dof_blur_far_enabled = false
        
        temperature_system.TemperatureState.WARM:
            environment.background_color = Color(0.95, 0.9, 0.8)
            environment.fog_enabled = false
            environment.adjustment_enabled = true
            environment.adjustment_saturation = 1.1
            environment.adjustment_brightness = 1.05
        
        temperature_system.TemperatureState.HOT:
            environment.background_color = Color(1.0, 0.85, 0.7)
            environment.fog_enabled = true
            environment.fog_color = Color(1.0, 0.8, 0.6, 0.2)
            environment.fog_depth_begin = 10
            environment.fog_depth_end = 30
            environment.adjustment_enabled = true
            environment.adjustment_saturation = 1.2
            environment.adjustment_brightness = 1.1
            environment.glow_enabled = true
            environment.glow_intensity = 0.3
        
        temperature_system.TemperatureState.BOILING:
            environment.background_color = Color(1.0, 0.7, 0.5)
            environment.fog_enabled = true
            environment.fog_color = Color(1.0, 0.6, 0.4, 0.4)
            environment.fog_depth_begin = 5
            environment.fog_depth_end = 20
            environment.adjustment_enabled = true
            environment.adjustment_saturation = 1.3
            environment.adjustment_brightness = 1.2
            environment.glow_enabled = true
            environment.glow_intensity = 0.6
            environment.glow_bloom = 0.3
        
        temperature_system.TemperatureState.PLASMA:
            environment.background_color = Color(0.7, 0.4, 0.9)
            environment.fog_enabled = true
            environment.fog_color = Color(0.6, 0.3, 0.8, 0.6)
            environment.fog_depth_begin = 2
            environment.fog_depth_end = 15
            environment.adjustment_enabled = true
            environment.adjustment_saturation = 1.5
            environment.adjustment_brightness = 1.3
            environment.glow_enabled = true
            environment.glow_intensity = 1.0
            environment.glow_bloom = 0.5
            environment.glow_hdr_threshold = 0.7
    
    world_environment.environment = environment

# Apply temperature effects to a specific word
func apply_temperature_effects_to_word(word_node, temp_state, word_id):
    if not is_instance_valid(word_node):
        return
    
    apply_temperature_material(word_node, temp_state)
    apply_temperature_particles(word_node, temp_state, word_id)
    
    # Apply physical effects based on temperature
    var physics_body = word_node.get_node_or_null("PhysicsBody")
    if physics_body:
        match temp_state:
            temperature_system.TemperatureState.FROZEN:
                physics_body.gravity_scale = 1.5
                physics_body.linear_damp = 5.0
                physics_body.angular_damp = 5.0
            temperature_system.TemperatureState.COLD:
                physics_body.gravity_scale = 1.2
                physics_body.linear_damp = 2.0
                physics_body.angular_damp = 2.0
            temperature_system.TemperatureState.NORMAL:
                physics_body.gravity_scale = 1.0
                physics_body.linear_damp = 0.5
                physics_body.angular_damp = 0.5
            temperature_system.TemperatureState.WARM:
                physics_body.gravity_scale = 0.8
                physics_body.linear_damp = 0.2
                physics_body.angular_damp = 0.2
            temperature_system.TemperatureState.HOT:
                physics_body.gravity_scale = 0.5
                physics_body.linear_damp = 0.1
                physics_body.angular_damp = 0.1
            temperature_system.TemperatureState.BOILING:
                physics_body.gravity_scale = 0.2
                physics_body.linear_damp = 0.05
                physics_body.angular_damp = 0.05
            temperature_system.TemperatureState.PLASMA:
                physics_body.gravity_scale = -0.2  # Words float up
                physics_body.linear_damp = 0.1
                physics_body.angular_damp = 0.1

# Called when temperature changes
func _on_temperature_changed(new_temp, new_state):
    # Update global environment
    apply_global_temperature_effects(new_state)
    
    # Update all existing words
    for word_id in word_manifestation_system.active_words:
        var word_node = word_manifestation_system.active_words[word_id]
        apply_temperature_effects_to_word(word_node, new_state, word_id)

# Called when a new word is created
func _on_word_created(word_node, word_id):
    apply_temperature_effects_to_word(
        word_node, 
        temperature_system.current_temperature_state,
        word_id
    )

# Called when a word is removed
func _on_word_removed(word_id):
    remove_temperature_particles(word_id)

# Get visual state text description
func get_temperature_visual_description(temp_state):
    match temp_state:
        temperature_system.TemperatureState.FROZEN:
            return "Words are crystallized in frozen state, glittering with ice particles."
        temperature_system.TemperatureState.COLD:
            return "Words move sluggishly, with frost forming along their edges."
        temperature_system.TemperatureState.NORMAL:
            return "Words appear in their natural state, flowing with normal dynamics."
        temperature_system.TemperatureState.WARM:
            return "Words move more fluidly, glowing with a subtle warmth."
        temperature_system.TemperatureState.HOT:
            return "Words shimmer with heat, their edges blurring as they move rapidly."
        temperature_system.TemperatureState.BOILING:
            return "Words bubble and transform constantly, emitting waves of heat."
        temperature_system.TemperatureState.PLASMA:
            return "Words have transcended their form, existing as pure energy in plasma state."
    
    return "Temperature visual state unknown."

# Console commands
func console_command(command, args):
    match command:
        "temp_visual", "temperature_visual":
            if args.size() > 0:
                match args[0]:
                    "describe":
                        var state = temperature_system.current_temperature_state
                        if args.size() > 1:
                            # Try to parse specific state
                            state = temperature_system.string_to_temperature_state(args[1])
                        return get_temperature_visual_description(state)
                    "status":
                        return "Current temperature visual effects active: " + \
                               temperature_system.temperature_state_to_string(
                                   temperature_system.current_temperature_state
                               )
                    "refresh":
                        _on_temperature_changed(
                            temperature_system.current_temperature, 
                            temperature_system.current_temperature_state
                        )
                        return "Refreshed all temperature visual effects."
            
            return "Available commands: describe, status, refresh"