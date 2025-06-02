# ==================================================
# UNIVERSAL BEING: UniverseRules
# TYPE: Universe Rules Component
# PURPOSE: Defines the laws and properties of universes
# COMPONENTS: None (core rules component)
# SCENES: None (rules only)
# ==================================================

extends UniversalBeing
class_name UniverseRulesUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var physics_laws: Dictionary = {
    "gravity": Vector3(0, -9.8, 0),
    "time_scale": 1.0,
    "max_velocity": 1000.0,
    "collision_enabled": true,
    "friction": 0.1,
    "restitution": 0.5
}

@export var lod_laws: Dictionary = {
    "levels": 3,
    "base_distance": 100.0,
    "distance_multiplier": 2.0,
    "detail_reduction": 0.5,
    "auto_adjust": true
}

@export var consciousness_laws: Dictionary = {
    "min_level": 1,
    "max_level": 5,
    "evolution_enabled": true,
    "ai_integration": true,
    "memory_persistence": true
}

@export var portal_laws: Dictionary = {
    "max_portals": 10,
    "stability_required": true,
    "consciousness_cost": 1,
    "cooldown_time": 5.0
}

@export var universe_constants: Dictionary = {
    "max_beings": 1000,
    "max_complexity": 100.0,
    "stability_threshold": 0.8,
    "evolution_rate": 1.0
}

# Rule tracking
var rule_start_time: float = 0.0
var total_rule_changes: int = 0
var last_rule_change_time: float = 0.0

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    # Set Universal Being identity
    being_type = "universe_rules"
    being_name = "Universal Laws"
    consciousness_level = 3  # High consciousness for rule management
    
    # Initialize rule tracking
    rule_start_time = Time.get_unix_time_from_system()
    last_rule_change_time = rule_start_time
    
    # Log rule initialization
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        var akashic = SystemBootstrap.get_akashic_records()
        if akashic:
            akashic.log_genesis("📜 The laws of this universe take form...", {
                "physics_laws": physics_laws,
                "lod_laws": lod_laws,
                "consciousness_laws": consciousness_laws
            })
    
    print("🌟 %s: Universe Rules Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Validate and normalize rules
    validate_physics_laws()
    validate_lod_laws()
    validate_consciousness_laws()
    validate_portal_laws()
    
    # Log rule activation
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        var akashic = SystemBootstrap.get_akashic_records()
        if akashic:
            akashic.log_genesis("⚖️ The laws of this universe are now in effect...", {
                "total_laws": get_total_laws(),
                "complexity": calculate_universe_complexity()
            })
    
    print("🌟 %s: Universe Rules Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Monitor rule stability
    check_rule_stability()
    
    # Adjust rules if needed
    if universe_constants.auto_adjust:
        auto_adjust_rules()

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    # Handle rule modification input
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_R:  # Reset rules
                reset_rules_to_default()
            KEY_A:  # Toggle auto-adjust
                universe_constants.auto_adjust = !universe_constants.auto_adjust

func pentagon_sewers() -> void:
    # Log rule deactivation
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        var akashic = SystemBootstrap.get_akashic_records()
        if akashic:
            akashic.log_genesis("📜 The laws of this universe fade away...", {
                "lifetime": get_rule_lifetime(),
                "total_changes": get_total_rule_changes()
            })
    
    super.pentagon_sewers()

# ===== RULE VALIDATION METHODS =====

func validate_physics_laws() -> void:
    """Validate and normalize physics laws"""
    # Ensure gravity is within reasonable bounds
    physics_laws.gravity = physics_laws.gravity.clamp(
        Vector3(-1000, -1000, -1000),
        Vector3(1000, 1000, 1000)
    )
    
    # Ensure time scale is positive
    physics_laws.time_scale = max(0.0, physics_laws.time_scale)
    
    # Ensure velocity limit is positive
    physics_laws.max_velocity = max(0.0, physics_laws.max_velocity)
    
    # Ensure friction and restitution are between 0 and 1
    physics_laws.friction = physics_laws.friction.clamp(0.0, 1.0)
    physics_laws.restitution = physics_laws.restitution.clamp(0.0, 1.0)

func validate_lod_laws() -> void:
    """Validate and normalize LOD laws"""
    # Ensure LOD levels are at least 1
    lod_laws.levels = max(1, lod_laws.levels)
    
    # Ensure base distance is positive
    lod_laws.base_distance = max(0.1, lod_laws.base_distance)
    
    # Ensure distance multiplier is at least 1
    lod_laws.distance_multiplier = max(1.0, lod_laws.distance_multiplier)
    
    # Ensure detail reduction is between 0 and 1
    lod_laws.detail_reduction = lod_laws.detail_reduction.clamp(0.0, 1.0)

func validate_consciousness_laws() -> void:
    """Validate and normalize consciousness laws"""
    # Ensure consciousness levels are valid
    consciousness_laws.min_level = consciousness_laws.min_level.clamp(1, 5)
    consciousness_laws.max_level = consciousness_laws.max_level.clamp(
        consciousness_laws.min_level, 5
    )

func validate_portal_laws() -> void:
    """Validate and normalize portal laws"""
    # Ensure max portals is positive
    portal_laws.max_portals = max(1, portal_laws.max_portals)
    
    # Ensure consciousness cost is non-negative
    portal_laws.consciousness_cost = max(0, portal_laws.consciousness_cost)
    
    # Ensure cooldown time is positive
    portal_laws.cooldown_time = max(0.1, portal_laws.cooldown_time)

# ===== RULE MONITORING METHODS =====

func check_rule_stability() -> void:
    """Check if the current rules are stable"""
    var stability = calculate_rule_stability()
    if stability < universe_constants.stability_threshold:
        if SystemBootstrap and SystemBootstrap.is_system_ready():
            var akashic = SystemBootstrap.get_akashic_records()
            if akashic:
                akashic.log_genesis("⚠️ The laws of this universe grow unstable...", {
                    "stability": stability,
                    "threshold": universe_constants.stability_threshold
                })

func auto_adjust_rules() -> void:
    """Automatically adjust rules to maintain stability"""
    var stability = calculate_rule_stability()
    if stability < universe_constants.stability_threshold:
        # Adjust physics laws
        physics_laws.time_scale *= 0.95  # Slow down time
        physics_laws.max_velocity *= 0.95  # Reduce max velocity
        
        # Adjust LOD laws
        lod_laws.base_distance *= 1.05  # Increase LOD distance
        
        # Track the change
        track_rule_change()
        
        # Log adjustments
        if SystemBootstrap and SystemBootstrap.is_system_ready():
            var akashic = SystemBootstrap.get_akashic_records()
            if akashic:
                akashic.log_genesis("⚖️ The laws adjust themselves to maintain balance...", {
                    "new_stability": calculate_rule_stability(),
                    "adjustments_made": true,
                    "total_changes": total_rule_changes
                })

# ===== RULE UTILITY METHODS =====

func calculate_rule_stability() -> float:
    """Calculate the stability of the current rules"""
    var stability = 1.0
    
    # Physics stability
    stability *= 1.0 - (abs(physics_laws.gravity.length() - 9.8) / 100.0)
    stability *= 1.0 - (abs(physics_laws.time_scale - 1.0) / 10.0)
    
    # LOD stability
    stability *= 1.0 - (abs(lod_laws.levels - 3) / 10.0)
    stability *= 1.0 - (abs(lod_laws.base_distance - 100.0) / 1000.0)
    
    # Consciousness stability
    stability *= 1.0 - (abs(consciousness_laws.max_level - 3) / 5.0)
    
    return stability.clamp(0.0, 1.0)

func calculate_universe_complexity() -> float:
    """Calculate the complexity of the current universe rules"""
    var complexity = 0.0
    
    # Physics complexity
    complexity += physics_laws.gravity.length() / 10.0
    complexity += physics_laws.time_scale
    complexity += physics_laws.max_velocity / 100.0
    
    # LOD complexity
    complexity += lod_laws.levels
    complexity += lod_laws.base_distance / 100.0
    
    # Consciousness complexity
    complexity += consciousness_laws.max_level
    complexity += 1.0 if consciousness_laws.evolution_enabled else 0.0
    complexity += 1.0 if consciousness_laws.ai_integration else 0.0
    
    return complexity.clamp(0.0, universe_constants.max_complexity)

func get_total_laws() -> int:
    """Get the total number of active laws"""
    return physics_laws.size() + lod_laws.size() + \
           consciousness_laws.size() + portal_laws.size()

func reset_rules_to_default() -> void:
    """Reset all rules to their default values"""
    physics_laws = {
        "gravity": Vector3(0, -9.8, 0),
        "time_scale": 1.0,
        "max_velocity": 1000.0,
        "collision_enabled": true,
        "friction": 0.1,
        "restitution": 0.5
    }
    
    lod_laws = {
        "levels": 3,
        "base_distance": 100.0,
        "distance_multiplier": 2.0,
        "detail_reduction": 0.5,
        "auto_adjust": true
    }
    
    consciousness_laws = {
        "min_level": 1,
        "max_level": 5,
        "evolution_enabled": true,
        "ai_integration": true,
        "memory_persistence": true
    }
    
    portal_laws = {
        "max_portals": 10,
        "stability_required": true,
        "consciousness_cost": 1,
        "cooldown_time": 5.0
    }
    
    # Track the reset as a change
    track_rule_change()
    
    # Log reset
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        var akashic = SystemBootstrap.get_akashic_records()
        if akashic:
            akashic.log_genesis("🔄 The laws of this universe reset to their primal state...", {
                "reset_time": Time.get_unix_time_from_system(),
                "total_changes": total_rule_changes
            })

# ===== RULE TRACKING METHODS =====

func get_rule_lifetime() -> float:
    """Get the total lifetime of the rules in seconds"""
    return Time.get_unix_time_from_system() - rule_start_time

func get_total_rule_changes() -> int:
    """Get the total number of rule changes made"""
    return total_rule_changes

func track_rule_change() -> void:
    """Track a rule change event"""
    total_rule_changes += 1
    last_rule_change_time = Time.get_unix_time_from_system()

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    """Enhanced AI interface for rule management"""
    var base_interface = super.ai_interface()
    base_interface.rule_commands = [
        "validate_rules",
        "adjust_rules",
        "reset_rules",
        "check_stability"
    ]
    base_interface.rule_properties = {
        "physics_laws": physics_laws,
        "lod_laws": lod_laws,
        "consciousness_laws": consciousness_laws,
        "portal_laws": portal_laws,
        "universe_constants": universe_constants
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """Handle AI method invocations for rule management"""
    match method_name:
        "validate_rules":
            validate_physics_laws()
            validate_lod_laws()
            validate_consciousness_laws()
            validate_portal_laws()
            return true
        "adjust_rules":
            auto_adjust_rules()
            return calculate_rule_stability()
        "reset_rules":
            reset_rules_to_default()
            return true
        "check_stability":
            return calculate_rule_stability()
        _:
            return super.ai_invoke_method(method_name, args) 