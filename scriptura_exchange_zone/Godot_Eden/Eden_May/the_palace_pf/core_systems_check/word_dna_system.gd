extends Node

# ----- DNA SYSTEM SETTINGS -----
class_name WordDNASystem

@export_category("DNA System Settings")
@export var use_dna_colors: bool = true
@export var use_dna_transformations: bool = true
@export var use_dna_particles: bool = true
@export var use_dna_sound: bool = false

# ----- DNA COMPONENTS -----
# DNA Structure: A string of characters that defines visual and behavioral aspects
# Format: 
# - First section (4 chars): Color DNA
# - Second section (4 chars): Shape DNA
# - Third section (4 chars): Behavior DNA
# - Fourth section (4 chars): Sound DNA
# Example: "ACTG-TGCA-GACT-CATG"

# ----- COLOR DNA MAPPING -----
const COLOR_NUCLEOTIDES = {
    "A": Color(0.8, 0.2, 0.2),  # Red
    "C": Color(0.2, 0.8, 0.2),  # Green
    "G": Color(0.2, 0.2, 0.8),  # Blue
    "T": Color(0.8, 0.8, 0.2),  # Yellow
    "U": Color(0.8, 0.2, 0.8),  # Magenta
    "X": Color(0.2, 0.8, 0.8),  # Cyan
    "Y": Color(0.8, 0.8, 0.8),  # White
    "Z": Color(0.2, 0.2, 0.2),  # Dark Gray
}

# ----- SHAPE DNA MAPPING -----
const SHAPE_TRANSFORMATIONS = {
    "A": {"scale": Vector3(1.2, 1.0, 1.0), "rotation": Vector3(0, 0, 0)},      # Wider
    "C": {"scale": Vector3(1.0, 1.2, 1.0), "rotation": Vector3(0, 0, 0)},      # Taller
    "G": {"scale": Vector3(1.0, 1.0, 1.2), "rotation": Vector3(0, 0, 0)},      # Deeper
    "T": {"scale": Vector3(0.8, 0.8, 0.8), "rotation": Vector3(0, 0, 0)},      # Smaller
    "U": {"scale": Vector3(1.0, 1.0, 1.0), "rotation": Vector3(15, 0, 0)},     # Rotate X
    "X": {"scale": Vector3(1.0, 1.0, 1.0), "rotation": Vector3(0, 15, 0)},     # Rotate Y
    "Y": {"scale": Vector3(1.0, 1.0, 1.0), "rotation": Vector3(0, 0, 15)},     # Rotate Z
    "Z": {"scale": Vector3(1.1, 1.1, 1.1), "rotation": Vector3(10, 10, 10)},   # Scale + Rotate
}

# ----- BEHAVIOR DNA MAPPING -----
const BEHAVIOR_PATTERNS = {
    "A": {"pulsate": true, "speed": 1.0, "intensity": 0.2},                    # Gentle pulsing
    "C": {"orbit": true, "radius": 0.2, "speed": 1.0},                         # Orbiting
    "G": {"bounce": true, "height": 0.3, "speed": 1.5},                        # Bouncing
    "T": {"spin": true, "axis": Vector3(0, 1, 0), "speed": 1.0},               # Spinning
    "U": {"flow": true, "direction": Vector3(0, 0.2, 0), "cycle": 2.0},        # Flowing
    "X": {"static": true},                                                      # Static/still
    "Y": {"jitter": true, "amount": 0.05, "speed": 3.0},                       # Jittering
    "Z": {"wave": true, "axis": Vector3(0, 1, 0), "amplitude": 0.2, "speed": 1.0}, # Waving
}

# ----- SOUND DNA MAPPING -----
const SOUND_PROFILES = {
    "A": {"pitch": 1.0, "timbre": "sine", "duration": 0.2},     # High pure tone
    "C": {"pitch": 0.8, "timbre": "square", "duration": 0.3},   # Mid square wave
    "G": {"pitch": 0.6, "timbre": "saw", "duration": 0.4},      # Low saw wave
    "T": {"pitch": 1.2, "timbre": "noise", "duration": 0.1},    # Short noise burst
    "U": {"pitch": 0.7, "timbre": "pad", "duration": 1.0},      # Long pad sound
    "X": {"pitch": 1.1, "timbre": "bell", "duration": 0.5},     # Bell-like sound
    "Y": {"pitch": 0.9, "timbre": "wind", "duration": 0.8},     # Wind-like sound
    "Z": {"pitch": 0.5, "timbre": "bass", "duration": 0.3},     # Bass thump
}

# ----- FONT MAPPING -----
const FONT_STYLES = {
    "A": {"font": "Arial", "style": "normal"},
    "C": {"font": "Times New Roman", "style": "italic"},
    "G": {"font": "Courier New", "style": "bold"},
    "T": {"font": "Verdana", "style": "normal"},
    "U": {"font": "Georgia", "style": "bold italic"},
    "X": {"font": "Impact", "style": "normal"},
    "Y": {"font": "Comic Sans MS", "style": "normal"},
    "Z": {"font": "Tahoma", "style": "normal"},
}

# ----- DNA GENERATION -----
static func generate_dna_for_word(word: String) -> String:
    var base_chars = ["A", "C", "G", "T", "U", "X", "Y", "Z"]
    var dna = ""
    var seed_value = 0
    
    # Use the word as a seed for deterministic but unique DNA
    for i in range(word.length()):
        seed_value += word.unicode_at(i)
    
    # Seed the random number generator
    seed(seed_value)
    
    # Generate color DNA (4 chars)
    for i in range(4):
        dna += base_chars[randi() % base_chars.size()]
    
    dna += "-"
    
    # Generate shape DNA (4 chars)
    for i in range(4):
        dna += base_chars[randi() % base_chars.size()]
    
    dna += "-"
    
    # Generate behavior DNA (4 chars)
    for i in range(4):
        dna += base_chars[randi() % base_chars.size()]
    
    dna += "-"
    
    # Generate sound DNA (4 chars)
    for i in range(4):
        dna += base_chars[randi() % base_chars.size()]
    
    return dna

# ----- DNA ANALYSIS -----
static func get_primary_color_from_dna(dna: String) -> Color:
    # Extract color DNA
    var color_dna = dna.split("-")[0]
    
    # Start with a neutral color
    var final_color = Color(0.5, 0.5, 0.5)
    
    # Add influence from each nucleotide
    for i in range(min(color_dna.length(), 4)):
        var nucleotide = color_dna[i]
        if COLOR_NUCLEOTIDES.has(nucleotide):
            var nucleotide_color = COLOR_NUCLEOTIDES[nucleotide]
            # First nucleotide has strongest influence, then decreasing
            var weight = 1.0 - (i * 0.2)
            final_color = final_color.lerp(nucleotide_color, weight * 0.5)
    
    return final_color

static func get_shape_transform_from_dna(dna: String) -> Dictionary:
    # Extract shape DNA
    var shape_dna = dna.split("-")[1]
    
    # Start with identity transform
    var transform = {
        "scale": Vector3(1.0, 1.0, 1.0),
        "rotation": Vector3(0.0, 0.0, 0.0)
    }
    
    # Apply transformations from each nucleotide
    for i in range(min(shape_dna.length(), 4)):
        var nucleotide = shape_dna[i]
        if SHAPE_TRANSFORMATIONS.has(nucleotide):
            var nucleotide_transform = SHAPE_TRANSFORMATIONS[nucleotide]
            # First nucleotide has strongest influence, then decreasing
            var weight = 1.0 - (i * 0.2)
            
            # Blend scale
            transform.scale.x += (nucleotide_transform.scale.x - 1.0) * weight
            transform.scale.y += (nucleotide_transform.scale.y - 1.0) * weight
            transform.scale.z += (nucleotide_transform.scale.z - 1.0) * weight
            
            # Add rotation
            transform.rotation += nucleotide_transform.rotation * weight
    
    return transform

static func get_behavior_from_dna(dna: String) -> Dictionary:
    # Extract behavior DNA
    var behavior_dna = dna.split("-")[2]
    
    # Start with no behaviors
    var behavior = {"active_behaviors": []}
    
    # Apply influences from each nucleotide
    for i in range(min(behavior_dna.length(), 4)):
        var nucleotide = behavior_dna[i]
        if BEHAVIOR_PATTERNS.has(nucleotide):
            var nucleotide_behavior = BEHAVIOR_PATTERNS[nucleotide]
            # Each nucleotide adds its behavior with decreasing priority
            var weight = 1.0 - (i * 0.2)
            
            # Copy behavior properties with weight applied to intensities
            var behavior_copy = nucleotide_behavior.duplicate(true)
            
            # Adjust intensity based on weight
            for key in behavior_copy:
                if key is float:
                    behavior_copy[key] *= weight
            
            # Add to active behaviors list
            behavior.active_behaviors.append(behavior_copy)
    
    return behavior

static func get_sound_profile_from_dna(dna: String) -> Dictionary:
    # Extract sound DNA
    var sound_dna = dna.split("-")[3]
    
    # Start with default sound profile
    var sound_profile = {
        "pitch": 1.0,
        "timbre": "sine",
        "duration": 0.3,
        "volume": 1.0
    }
    
    # Apply influences from each nucleotide
    var primary_nucleotide = sound_dna[0] if sound_dna.length() > 0 else "A"
    
    if SOUND_PROFILES.has(primary_nucleotide):
        sound_profile = SOUND_PROFILES[primary_nucleotide].duplicate()
    
    # Secondary nucleotides modify the primary profile
    for i in range(1, min(sound_dna.length(), 4)):
        var nucleotide = sound_dna[i]
        if SOUND_PROFILES.has(nucleotide):
            var nucleotide_profile = SOUND_PROFILES[nucleotide]
            var weight = 0.3 - (i * 0.1)  # Secondary influences are smaller
            
            # Blend pitch and duration
            sound_profile.pitch = lerp(sound_profile.pitch, nucleotide_profile.pitch, weight)
            sound_profile.duration = lerp(sound_profile.duration, nucleotide_profile.duration, weight)
    
    return sound_profile

static func get_font_style_from_dna(dna: String) -> Dictionary:
    # Extract from both color and shape DNA for font style
    var color_dna = dna.split("-")[0]
    var primary_nucleotide = color_dna[0] if color_dna.length() > 0 else "A"
    
    if FONT_STYLES.has(primary_nucleotide):
        return FONT_STYLES[primary_nucleotide].duplicate()
    else:
        return {"font": "Arial", "style": "normal"}

# ----- INTERACTION FACTORS -----
static func get_compatibility_score(dna_a: String, dna_b: String) -> float:
    # Calculate how compatible two DNA sequences are (0.0 to 1.0)
    var score = 0.0
    var color_a = get_primary_color_from_dna(dna_a)
    var color_b = get_primary_color_from_dna(dna_b)
    
    # Color compatibility (complementary colors score higher)
    var color_diff = abs(color_a.r - color_b.r) + abs(color_a.g - color_b.g) + abs(color_a.b - color_b.b)
    var color_compatibility = 1.0 - (color_diff / 3.0)
    
    # Shape compatibility
    var shape_a = get_shape_transform_from_dna(dna_a)
    var shape_b = get_shape_transform_from_dna(dna_b)
    
    var scale_diff = (shape_a.scale - shape_b.scale).length() / 3.0
    var rotation_diff = (shape_a.rotation - shape_b.rotation).length() / 180.0
    
    var shape_compatibility = 1.0 - ((scale_diff + rotation_diff) / 2.0)
    
    # Behavior compatibility
    var behavior_a = dna_a.split("-")[2]
    var behavior_b = dna_b.split("-")[2]
    
    var behavior_matches = 0
    for i in range(min(behavior_a.length(), behavior_b.length())):
        if behavior_a[i] == behavior_b[i]:
            behavior_matches += 1
    
    var behavior_compatibility = float(behavior_matches) / 4.0
    
    # Calculate final score (with weights)
    score = (color_compatibility * 0.4) + (shape_compatibility * 0.3) + (behavior_compatibility * 0.3)
    return clamp(score, 0.0, 1.0)

static func generate_child_dna(parent_a: String, parent_b: String) -> String:
    # Create a child DNA by combining two parent DNAs
    var sections_a = parent_a.split("-")
    var sections_b = parent_b.split("-")
    var child_dna = ""
    
    # For each section, randomly choose from parent A or B, with occasional mutation
    for i in range(4):
        var section = ""
        var parent_section = randf() < 0.5 ? sections_a[i] : sections_b[i]
        
        for j in range(4):
            var nucleotide = parent_section[j]
            
            # Chance of mutation
            if randf() < 0.1:  # 10% chance of mutation
                var base_chars = ["A", "C", "G", "T", "U", "X", "Y", "Z"]
                nucleotide = base_chars[randi() % base_chars.size()]
            
            section += nucleotide
        
        child_dna += section
        if i < 3:
            child_dna += "-"
    
    return child_dna

# ----- UTILITY FUNCTIONS -----
static func dna_to_string_representation(dna: String) -> String:
    # Create a human-readable representation of DNA
    var sections = dna.split("-")
    var result = ""
    
    result += "Color: " + sections[0] + "\n"
    result += "Shape: " + sections[1] + "\n"
    result += "Behavior: " + sections[2] + "\n"
    result += "Sound: " + sections[3]
    
    return result

static func apply_dna_to_material(material: Material, dna: String) -> Material:
    # Modify a material based on DNA properties
    var color = get_primary_color_from_dna(dna)
    
    if material is StandardMaterial3D:
        material.albedo_color = color
        material.emission = color
        material.emission_enabled = true
        material.emission_energy_multiplier = 0.3
    
    return material

static func apply_dna_to_transform(node: Node3D, dna: String):
    # Apply DNA-based transformations to a node
    var transform_data = get_shape_transform_from_dna(dna)
    
    node.scale = transform_data.scale
    node.rotation_degrees = transform_data.rotation