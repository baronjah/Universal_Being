extends Spatial

# Base class for temperature-related particle effects
class_name TemperatureParticles

# Particle emitters for different effects
var primary_emitter
var secondary_emitter

# Effect lifetime management
export var lifetime = 0.0  # 0 = permanent, > 0 = seconds before auto-destruction
var time_alive = 0.0

# Effect intensity (0.0 to 1.0)
export(float, 0.0, 1.0) var intensity = 1.0

# Respond to word power
export var scale_with_word_power = true
var word_power = 1.0

func _ready():
    # Find emitters
    primary_emitter = $PrimaryEmitter
    secondary_emitter = $SecondaryEmitter
    
    # Set initial intensity
    set_intensity(intensity)

func _process(delta):
    # Handle lifetime if not permanent
    if lifetime > 0:
        time_alive += delta
        if time_alive >= lifetime:
            queue_free()
            return
        
        # Fade out in the last second
        if time_alive > lifetime - 1.0:
            var fade_factor = 1.0 - (time_alive - (lifetime - 1.0))
            set_intensity(intensity * fade_factor)

# Set the effect intensity (0.0 - 1.0)
func set_intensity(value):
    intensity = clamp(value, 0.0, 1.0)
    
    if primary_emitter:
        primary_emitter.amount = int(primary_emitter.amount_ratio * intensity)
        primary_emitter.lifetime = primary_emitter.lifetime_ratio * intensity
        
    if secondary_emitter:
        secondary_emitter.amount = int(secondary_emitter.amount_ratio * intensity)
        secondary_emitter.lifetime = secondary_emitter.lifetime_ratio * intensity

# Set the word power to scale the effect
func set_word_power(power):
    if not scale_with_word_power:
        return
        
    word_power = max(1.0, power)
    
    # Scale particles based on word power
    var scale_factor = 1.0 + min(2.0, word_power * 0.1)
    
    if primary_emitter:
        primary_emitter.amount = int(primary_emitter.amount_ratio * intensity * scale_factor)
        
    if secondary_emitter:
        secondary_emitter.amount = int(secondary_emitter.amount_ratio * intensity * scale_factor)
    
    # Update emitters
    update_emitters()

# To be overridden by specific temperature effect implementations
func update_emitters():
    pass

# Restart the effect
func restart():
    if primary_emitter:
        primary_emitter.restart()
    
    if secondary_emitter:
        secondary_emitter.restart()

# Specific particle implementations

# Frozen particles
class_name FrozenParticles
extends TemperatureParticles

func _ready():
    ._ready()
    
    # Set specific properties for frozen effect
    if primary_emitter:
        primary_emitter.amount_ratio = primary_emitter.amount
        primary_emitter.lifetime_ratio = primary_emitter.lifetime
        
        # Store ice crystal particles at rest
        primary_emitter.process_material.gravity = Vector3(0, -0.5, 0)
        primary_emitter.process_material.initial_velocity = 0.2
        primary_emitter.process_material.color = Color(0.8, 0.95, 1.0, 0.8)
    
    if secondary_emitter:
        secondary_emitter.amount_ratio = secondary_emitter.amount
        secondary_emitter.lifetime_ratio = secondary_emitter.lifetime
        
        # Small frost particles
        secondary_emitter.process_material.gravity = Vector3(0, -0.1, 0)
        secondary_emitter.process_material.initial_velocity = 0.1
        secondary_emitter.process_material.color = Color(0.9, 0.98, 1.0, 0.4)

func update_emitters():
    .update_emitters()
    
    # Adjust frozen particle behavior based on word power
    if primary_emitter:
        # Stronger words have more ice crystals
        primary_emitter.process_material.scale = 0.05 + (word_power * 0.005)

# Hot particles
class_name HotParticles
extends TemperatureParticles

func _ready():
    ._ready()
    
    # Set specific properties for hot effect
    if primary_emitter:
        primary_emitter.amount_ratio = primary_emitter.amount
        primary_emitter.lifetime_ratio = primary_emitter.lifetime
        
        # Heat ripples rising
        primary_emitter.process_material.gravity = Vector3(0, 1.0, 0)
        primary_emitter.process_material.initial_velocity = 0.5
        primary_emitter.process_material.color = Color(1.0, 0.7, 0.4, 0.6)
    
    if secondary_emitter:
        secondary_emitter.amount_ratio = secondary_emitter.amount
        secondary_emitter.lifetime_ratio = secondary_emitter.lifetime
        
        # Spark particles
        secondary_emitter.process_material.gravity = Vector3(0, 0.5, 0)
        secondary_emitter.process_material.initial_velocity = 1.0
        secondary_emitter.process_material.color = Color(1.0, 0.5, 0.2, 0.7)

func update_emitters():
    .update_emitters()
    
    # Adjust hot particle behavior based on word power
    if primary_emitter:
        # Stronger words generate more heat
        primary_emitter.process_material.gravity.y = 1.0 + (word_power * 0.2)

# Plasma particles
class_name PlasmaParticles
extends TemperatureParticles

var time_passed = 0.0
var color_shift = 0.0

func _ready():
    ._ready()
    
    # Set specific properties for plasma effect
    if primary_emitter:
        primary_emitter.amount_ratio = primary_emitter.amount
        primary_emitter.lifetime_ratio = primary_emitter.lifetime
        
        # Plasma core
        primary_emitter.process_material.gravity = Vector3(0, 0, 0)
        primary_emitter.process_material.initial_velocity = 2.0
        primary_emitter.process_material.color = Color(0.8, 0.4, 1.0, 0.9)
    
    if secondary_emitter:
        secondary_emitter.amount_ratio = secondary_emitter.amount
        secondary_emitter.lifetime_ratio = secondary_emitter.lifetime
        
        # Ionized particles
        secondary_emitter.process_material.gravity = Vector3(0, 0, 0)
        secondary_emitter.process_material.initial_velocity = 3.0
        secondary_emitter.process_material.color = Color(0.6, 0.3, 0.9, 0.8)

func _process(delta):
    ._process(delta)
    
    # Animate plasma colors
    time_passed += delta
    color_shift = sin(time_passed * 2.0) * 0.5 + 0.5
    
    if primary_emitter:
        var color1 = Color(0.8, 0.4, 1.0, 0.9)
        var color2 = Color(0.6, 0.2, 0.8, 0.9)
        primary_emitter.process_material.color = color1.linear_interpolate(color2, color_shift)
    
    if secondary_emitter:
        var color1 = Color(0.6, 0.3, 0.9, 0.8)
        var color2 = Color(0.9, 0.5, 0.3, 0.7)
        secondary_emitter.process_material.color = color1.linear_interpolate(color2, color_shift)

func update_emitters():
    .update_emitters()
    
    # Adjust plasma particle behavior based on word power
    if primary_emitter and secondary_emitter:
        # Stronger words create more chaotic plasma
        var chaos_factor = 1.0 + min(3.0, word_power * 0.2)
        secondary_emitter.process_material.initial_velocity = 3.0 * chaos_factor

# Create particle scene instances for different temperatures

static func create_frozen_particles():
    var scene = preload("res://particles/frozen_particles.tscn").instance()
    return scene

static func create_cold_particles():
    var scene = preload("res://particles/cold_particles.tscn").instance()
    return scene

static func create_warm_particles():
    var scene = preload("res://particles/warm_particles.tscn").instance()
    return scene

static func create_hot_particles():
    var scene = preload("res://particles/hot_particles.tscn").instance()
    return scene

static func create_boiling_particles():
    var scene = preload("res://particles/boiling_particles.tscn").instance()
    return scene

static func create_plasma_particles():
    var scene = preload("res://particles/plasma_particles.tscn").instance()
    return scene