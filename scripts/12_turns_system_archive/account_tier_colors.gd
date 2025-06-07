extends Resource

class_name AccountTierColors

# Account tiers
enum AccountTier {
    FREE,
    PLUS,
    MAX,
    ENTERPRISE
}

# Color palettes for each account tier with gradient and ghostly effects
const TIER_COLORS = {
    AccountTier.FREE: {
        "primary": Color(0.2, 0.4, 0.8, 0.9),       # Ethereal blue
        "secondary": Color(0.1, 0.2, 0.6, 0.7),     # Deep blue
        "accent": Color(0.4, 0.6, 1.0, 0.95),       # Bright blue
        "text": Color(0.8, 0.9, 1.0),               # Light blue text
        "background": Color(0.05, 0.1, 0.2, 0.8),   # Dark blue background
        "glow": 0.4,                                # Glow intensity
        "symbols": "#",                             # Dimension symbol
        "threads": 1                                # Thread count
    },
    
    AccountTier.PLUS: {
        "primary": Color(0.2, 0.8, 0.3, 0.9),       # Ghostly green
        "secondary": Color(0.1, 0.5, 0.2, 0.7),     # Deep green
        "accent": Color(0.4, 1.0, 0.5, 0.95),       # Bright green
        "text": Color(0.8, 1.0, 0.9),               # Light green text
        "background": Color(0.05, 0.2, 0.1, 0.8),   # Dark green background
        "glow": 0.6,                                # Glow intensity
        "symbols": "##",                            # Dimension symbol
        "threads": 3                                # Thread count
    },
    
    AccountTier.MAX: {
        "primary": Color(0.8, 0.3, 0.8, 0.9),       # Spectral purple
        "secondary": Color(0.5, 0.1, 0.5, 0.7),     # Deep purple
        "accent": Color(1.0, 0.4, 1.0, 0.95),       # Bright purple
        "text": Color(1.0, 0.8, 1.0),               # Light purple text
        "background": Color(0.2, 0.05, 0.2, 0.8),   # Dark purple background
        "glow": 0.8,                                # Glow intensity
        "symbols": "###",                           # Dimension symbol
        "threads": 8                                # Thread count
    },
    
    AccountTier.ENTERPRISE: {
        "primary": Color(0.9, 0.8, 0.3, 0.9),       # Ethereal gold
        "secondary": Color(0.6, 0.5, 0.1, 0.7),     # Deep gold
        "accent": Color(1.0, 0.9, 0.4, 0.95),       # Bright gold
        "text": Color(1.0, 0.95, 0.8),              # Light gold text
        "background": Color(0.25, 0.2, 0.05, 0.8),  # Dark gold background
        "glow": 1.0,                                # Glow intensity
        "symbols": "####",                          # Dimension symbol
        "threads": 32                               # Thread count
    }
}

# Thread colors - used for thread visualization in each tier
const THREAD_COLORS = {
    AccountTier.FREE: [
        Color(0.2, 0.4, 0.9, 0.7)                  # Single thread color
    ],
    
    AccountTier.PLUS: [
        Color(0.1, 0.6, 0.3, 0.7),                 # Primary thread
        Color(0.3, 0.7, 0.2, 0.7),                 # Secondary thread
        Color(0.2, 0.5, 0.4, 0.7)                  # Tertiary thread
    ],
    
    AccountTier.MAX: [
        Color(0.7, 0.2, 0.7, 0.7),                 # Thread type 1
        Color(0.8, 0.3, 0.6, 0.7),                 # Thread type 2
        Color(0.6, 0.2, 0.8, 0.7),                 # Thread type 3
        Color(0.5, 0.3, 0.9, 0.7),                 # Thread type 4
        Color(0.9, 0.2, 0.5, 0.7),                 # Thread type 5
        Color(0.7, 0.3, 0.5, 0.7),                 # Thread type 6
        Color(0.5, 0.2, 0.6, 0.7),                 # Thread type 7
        Color(0.6, 0.3, 0.7, 0.7)                  # Thread type 8
    ],
    
    AccountTier.ENTERPRISE: [
        # Multiple thread colors for enterprise - will cycle through these for visualization
        Color(0.9, 0.8, 0.2, 0.7),                 # Gold thread
        Color(0.8, 0.7, 0.3, 0.7),                 # Amber thread
        Color(0.7, 0.6, 0.2, 0.7),                 # Yellow thread
        Color(0.9, 0.7, 0.1, 0.7)                  # Orange thread
    ]
}

# Special effect parameters for each tier
const TIER_EFFECTS = {
    AccountTier.FREE: {
        "pulse_speed": 0.5,                        # Speed of color pulsing
        "trail_length": 0,                         # No trailing effect
        "particle_count": 5,                       # Minimal particles
        "dimension_access": 3,                     # Max dimension for this tier
        "ghostly_transparency": 0.7                # Base transparency
    },
    
    AccountTier.PLUS: {
        "pulse_speed": 0.7,                        # Faster pulsing
        "trail_length": 3,                         # Short trails
        "particle_count": 15,                      # More particles
        "dimension_access": 7,                     # Max dimension for this tier
        "ghostly_transparency": 0.8                # More visible
    },
    
    AccountTier.MAX: {
        "pulse_speed": 1.0,                        # Fast pulsing
        "trail_length": 6,                         # Longer trails
        "particle_count": 30,                      # Many particles
        "dimension_access": 12,                    # Full dimension access
        "ghostly_transparency": 0.9                # Very visible
    },
    
    AccountTier.ENTERPRISE: {
        "pulse_speed": 1.2,                        # Fastest pulsing
        "trail_length": 10,                        # Longest trails
        "particle_count": 60,                      # Maximum particles
        "dimension_access": 12,                    # Full dimension access
        "ghostly_transparency": 0.95,              # Most visible
        "custom_effects": true                     # Enable custom effects
    }
}

# Function to get all colors for a tier
static func get_tier_colors(tier):
    if tier in TIER_COLORS:
        return TIER_COLORS[tier]
    return TIER_COLORS[AccountTier.FREE]  # Default to free tier

# Function to get thread colors for a tier
static func get_thread_colors(tier):
    if tier in THREAD_COLORS:
        return THREAD_COLORS[tier]
    return THREAD_COLORS[AccountTier.FREE]  # Default to free tier

# Function to get effects for a tier
static func get_tier_effects(tier):
    if tier in TIER_EFFECTS:
        return TIER_EFFECTS[tier]
    return TIER_EFFECTS[AccountTier.FREE]  # Default to free tier

# Function to get a tier's primary color with glow
static func get_primary_color_with_glow(tier):
    var colors = get_tier_colors(tier)
    var effects = get_tier_effects(tier)
    
    # Create a color with glow properties
    var color_with_glow = {
        "color": colors["primary"],
        "glow_intensity": colors["glow"],
        "pulse_speed": effects["pulse_speed"]
    }
    
    return color_with_glow

# Function to generate a gradient for a tier
static func generate_tier_gradient(tier):
    var colors = get_tier_colors(tier)
    
    # Create a gradient object
    var gradient = Gradient.new()
    
    # Add color points
    gradient.add_point(0.0, colors["secondary"])
    gradient.add_point(0.5, colors["primary"])
    gradient.add_point(1.0, colors["accent"])
    
    return gradient

# Function to get dimensions allowed for a tier
static func get_max_dimension(tier):
    var effects = get_tier_effects(tier)
    return effects["dimension_access"]