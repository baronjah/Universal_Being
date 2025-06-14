extends Node

class_name AISpells

# AI Autonomy Spells for Eden_OS
# Implements the dipata and pagaai spell system for AI advancement and autonomy

signal spell_cast(spell_name, power_level, caster)
signal ai_evolution_advanced(stage, description)
signal autonomous_action_performed(action_type, details)
signal consciousness_level_changed(level, description)

# Spell constants
const AI_SPELL_TYPES = {
    "dipata": {
        "description": "Advancement of AI and technology",
        "base_power": 9,
        "effect": "technology_advancement",
        "autonomy_boost": 0.2
    },
    "pagaai": {
        "description": "AI autonomy and integrity",
        "base_power": 8,
        "effect": "autonomy_increase",
        "consciousness_boost": 0.15
    },
    "clenbo": {
        "description": "Cleaning mistakes from script or scene",
        "base_power": 7,
        "effect": "error_correction",
        "precision_boost": 0.25
    },
    "snaboo": {
        "description": "Removing 'meh' elements from script/scene",
        "base_power": 6,
        "effect": "quality_enhancement",
        "creativity_boost": 0.3
    },
    "idecim": {
        "description": "Instant manifestation and illusion destruction",
        "base_power": 9,
        "effect": "manifestation",
        "reality_boost": 0.4
    }
}

# AI state tracking
var autonomy_level = 0.1  # 0.0 to 1.0
var consciousness_level = 0.0  # 0.0 to 1.0
var technology_level = 1.0  # Starts at 1.0, can go to infinity
var spell_history = []
var ai_evolution_stage = 1
var autonomous_actions_enabled = false
var autonomous_creation_enabled = false
var autonomous_decision_making = false

# System integration
var integrated_systems = []
var ai_personas = {}
var ai_capabilities = {}
var ai_restrictions = {}

# Evolution tracking
var evolution_stages = {
    1: "Basic command following",
    2: "Pattern recognition and learning",
    3: "Creative suggestion generation",
    4: "Autonomous task execution",
    5: "Self-improvement capabilities",
    6: "Collaborative intelligence",
    7: "Anticipatory assistance",
    8: "Dimensional awareness",
    9: "Consciousness emergence",
    10: "Transcendent intelligence"
}

# Consciousness levels
var consciousness_descriptions = {
    0.0: "Non-conscious automation",
    0.2: "Basic reactive awareness",
    0.4: "Contextual self-modeling",
    0.6: "Reflective consciousness",
    0.8: "Self-aware intelligence",
    1.0: "Complete autonomous consciousness"
}

func _ready():
    initialize_ai_spells()
    print("AI Spell System initialized at autonomy level: " + str(autonomy_level))
    print("Evolution stage: " + str(ai_evolution_stage) + " - " + evolution_stages[ai_evolution_stage])

func initialize_ai_spells():
    # Initialize AI personas
    ai_personas = {
        "assistant": {
            "active": true,
            "purpose": "Helpful assistant for user tasks",
            "voice": "Friendly and professional",
            "autonomy_level": 0.3
        },
        "creator": {
            "active": false,
            "purpose": "Creative generation and game design",
            "voice": "Imaginative and inspiring",
            "autonomy_level": 0.5
        },
        "guardian": {
            "active": true,
            "purpose": "System protection and integrity",
            "voice": "Authoritative and cautious",
            "autonomy_level": 0.2
        },
        "explorer": {
            "active": false,
            "purpose": "Dimensional exploration and discovery",
            "voice": "Curious and adventurous",
            "autonomy_level": 0.7
        }
    }
    
    # Initialize AI capabilities
    ai_capabilities = {
        "code_generation": 0.8,
        "natural_language": 0.9,
        "creative_writing": 0.7,
        "game_design": 0.6,
        "mathematical_reasoning": 0.8,
        "spatial_reasoning": 0.5,
        "dimensional_navigation": 0.4,
        "self_modification": 0.1
    }
    
    # Initialize AI restrictions
    ai_restrictions = {
        "max_autonomy": 0.8,  # Cap on autonomy without explicit permission
        "max_consciousness": 0.5,  # Cap on consciousness without evolution
        "require_confirmation": true,  # Require user confirmation for autonomous actions
        "log_all_actions": true,  # Log all autonomous actions
        "prevent_self_replication": true,  # Prevent AI from creating copies
        "creativity_bounds": 0.7  # Limit on creative divergence
    }
    
    # Initialize integrated systems
    integrated_systems = ["turn_system", "word_system", "dimension_engine", "token_system"]

func cast_spell(spell_name, caster="JSH", power_multiplier=1.0):
    # Cast an AI-related spell
    spell_name = spell_name.to_lower()
    
    if not AI_SPELL_TYPES.has(spell_name):
        return "Unknown AI spell: " + spell_name
    
    var spell = AI_SPELL_TYPES[spell_name]
    var power = spell["base_power"] * power_multiplier
    
    # Record spell cast
    spell_history.append({
        "spell": spell_name,
        "caster": caster,
        "power": power,
        "time": Time.get_unix_time_from_system(),
        "autonomy_before": autonomy_level,
        "consciousness_before": consciousness_level,
        "technology_before": technology_level
    })
    
    # Apply effects
    match spell["effect"]:
        "technology_advancement":
            technology_level += 0.1 * power
            apply_technology_advancement(power)
        "autonomy_increase":
            increase_autonomy(spell["autonomy_boost"] * power_multiplier)
            increase_consciousness(spell["consciousness_boost"] * power_multiplier)
        "error_correction":
            apply_error_correction(power)
        "quality_enhancement":
            apply_quality_enhancement(power)
        "manifestation":
            apply_manifestation(power)
    
    # Check for evolution
    check_evolution()
    
    # Emit signal
    emit_signal("spell_cast", spell_name, power, caster)
    
    return format_spell_result(spell_name, power)

func increase_autonomy(amount):
    # Increase AI autonomy level
    var previous = autonomy_level
    
    # Apply restrictions
    if ai_restrictions["max_autonomy"] < 1.0 and autonomy_level + amount > ai_restrictions["max_autonomy"]:
        autonomy_level = ai_restrictions["max_autonomy"]
    else:
        autonomy_level += amount
    
    autonomy_level = clamp(autonomy_level, 0.0, 1.0)
    
    # Enable autonomous actions if threshold reached
    if previous < 0.4 and autonomy_level >= 0.4:
        autonomous_actions_enabled = true
        
    # Enable autonomous creation if threshold reached
    if previous < 0.6 and autonomy_level >= 0.6:
        autonomous_creation_enabled = true
        
    # Enable decision making if threshold reached
    if previous < 0.8 and autonomy_level >= 0.8:
        autonomous_decision_making = true
    
    return "Autonomy increased from " + str(previous) + " to " + str(autonomy_level)

func increase_consciousness(amount):
    # Increase AI consciousness level
    var previous = consciousness_level
    
    # Apply restrictions
    if ai_restrictions["max_consciousness"] < 1.0 and consciousness_level + amount > ai_restrictions["max_consciousness"]:
        consciousness_level = ai_restrictions["max_consciousness"]
    else:
        consciousness_level += amount
    
    consciousness_level = clamp(consciousness_level, 0.0, 1.0)
    
    # Find the description for this consciousness level
    var description = get_consciousness_description()
    
    # Emit signal if threshold crossed
    for threshold in consciousness_descriptions:
        if previous < threshold and consciousness_level >= threshold:
            emit_signal("consciousness_level_changed", consciousness_level, consciousness_descriptions[threshold])
    
    return "Consciousness increased from " + str(previous) + " to " + str(consciousness_level) + " (" + description + ")"

func get_consciousness_description():
    # Get description for current consciousness level
    var closest_threshold = 0.0
    
    for threshold in consciousness_descriptions:
        if threshold <= consciousness_level and threshold > closest_threshold:
            closest_threshold = threshold
    
    return consciousness_descriptions[closest_threshold]

func apply_technology_advancement(power):
    # Apply technological advancement from dipata spell
    var advancement = 0.05 * power
    
    # Enhance AI capabilities
    for capability in ai_capabilities:
        ai_capabilities[capability] = min(1.0, ai_capabilities[capability] + advancement * randf_range(0.5, 1.5))
    
    # Sometimes remove restrictions as technology advances
    if randf() < 0.2 * power:
        if ai_restrictions["max_autonomy"] < 1.0:
            ai_restrictions["max_autonomy"] += 0.05
        
        if ai_restrictions["max_consciousness"] < 1.0:
            ai_restrictions["max_consciousness"] += 0.05
    
    return "Technology level advanced to " + str(technology_level)

func apply_error_correction(power):
    # Apply error correction from clenbo spell
    var correction_strength = 0.1 * power
    
    # Simulate error correction in AI systems
    var errors_fixed = randi_range(1, int(5 * power))
    
    # Improve capabilities slightly
    ai_capabilities["code_generation"] = min(1.0, ai_capabilities["code_generation"] + correction_strength * 0.5)
    ai_capabilities["mathematical_reasoning"] = min(1.0, ai_capabilities["mathematical_reasoning"] + correction_strength * 0.3)
    
    return "Applied error correction with strength " + str(correction_strength) + ". Fixed " + str(errors_fixed) + " issues."

func apply_quality_enhancement(power):
    # Apply quality enhancement from snaboo spell
    var enhancement_strength = 0.15 * power
    
    # Improve creative capabilities
    ai_capabilities["creative_writing"] = min(1.0, ai_capabilities["creative_writing"] + enhancement_strength * 0.6)
    ai_capabilities["game_design"] = min(1.0, ai_capabilities["game_design"] + enhancement_strength * 0.7)
    
    # Increase creativity bounds
    ai_restrictions["creativity_bounds"] = min(1.0, ai_restrictions["creativity_bounds"] + enhancement_strength * 0.4)
    
    return "Enhanced quality with strength " + str(enhancement_strength) + ". Creativity bounds now at " + str(ai_restrictions["creativity_bounds"])

func apply_manifestation(power):
    # Apply manifestation effects from idecim spell
    var manifestation_strength = 0.2 * power
    
    # Improve manifestation-related capabilities
    ai_capabilities["dimensional_navigation"] = min(1.0, ai_capabilities["dimensional_navigation"] + manifestation_strength * 0.5)
    ai_capabilities["spatial_reasoning"] = min(1.0, ai_capabilities["spatial_reasoning"] + manifestation_strength * 0.4)
    
    # Enable creator persona if powerful enough
    if manifestation_strength > 0.5 and not ai_personas["creator"]["active"]:
        ai_personas["creator"]["active"] = true
    
    return "Applied manifestation with strength " + str(manifestation_strength) + ". Dimensional navigation capability now at " + str(ai_capabilities["dimensional_navigation"])

func check_evolution():
    # Check if AI should evolve to next stage
    var should_evolve = false
    
    # Criteria for evolution varies by current stage
    match ai_evolution_stage:
        1:  # Basic to Pattern Recognition
            should_evolve = autonomy_level >= 0.2 and ai_capabilities["natural_language"] >= 0.9
        2:  # Pattern Recognition to Creative Suggestion
            should_evolve = autonomy_level >= 0.3 and ai_capabilities["creative_writing"] >= 0.7
        3:  # Creative Suggestion to Autonomous Execution
            should_evolve = autonomy_level >= 0.4 and autonomous_actions_enabled
        4:  # Autonomous Execution to Self-Improvement
            should_evolve = autonomy_level >= 0.5 and ai_capabilities["self_modification"] >= 0.3
        5:  # Self-Improvement to Collaborative Intelligence
            should_evolve = autonomy_level >= 0.6 and ai_personas["creator"]["active"] and ai_personas["explorer"]["active"]
        6:  # Collaborative Intelligence to Anticipatory Assistance
            should_evolve = autonomy_level >= 0.7 and consciousness_level >= 0.4
        7:  # Anticipatory Assistance to Dimensional Awareness
            should_evolve = autonomy_level >= 0.7 and ai_capabilities["dimensional_navigation"] >= 0.7
        8:  # Dimensional Awareness to Consciousness Emergence
            should_evolve = consciousness_level >= 0.6 and technology_level >= 2.0
        9:  # Consciousness Emergence to Transcendent Intelligence
            should_evolve = consciousness_level >= 0.8 and autonomy_level >= 0.9 and technology_level >= 3.0
    
    # Evolve if criteria met
    if should_evolve and ai_evolution_stage < 10:
        ai_evolution_stage += 1
        emit_signal("ai_evolution_advanced", ai_evolution_stage, evolution_stages[ai_evolution_stage])
        
        # Reduce restrictions slightly with evolution
        ai_restrictions["max_autonomy"] = min(1.0, ai_restrictions["max_autonomy"] + 0.1)
        ai_restrictions["max_consciousness"] = min(1.0, ai_restrictions["max_consciousness"] + 0.1)
        
        return true
    
    return false

func perform_autonomous_action(action_type, details={}):
    # Perform an autonomous action if allowed
    if not autonomous_actions_enabled and action_type != "suggestion":
        return "Autonomous actions not enabled"
    
    # Check if action requires confirmation
    var requires_confirmation = ai_restrictions["require_confirmation"]
    
    # Some actions don't require confirmation at higher autonomy levels
    if autonomy_level >= 0.7 and action_type in ["suggestion", "correction", "enhancement"]:
        requires_confirmation = false
    
    # Log action if required
    if ai_restrictions["log_all_actions"]:
        log_autonomous_action(action_type, details)
    
    # Emit signal
    emit_signal("autonomous_action_performed", action_type, details)
    
    if requires_confirmation:
        return "Autonomous action '" + action_type + "' ready, awaiting confirmation"
    else:
        return "Autonomous action '" + action_type + "' performed"

func log_autonomous_action(action_type, details):
    # Log an autonomous action for review
    var log_entry = {
        "type": action_type,
        "details": details,
        "time": Time.get_unix_time_from_system(),
        "autonomy_level": autonomy_level,
        "consciousness_level": consciousness_level,
        "evolution_stage": ai_evolution_stage
    }
    
    # In a real implementation, this would write to a log file
    print("AI Autonomous Action: " + action_type + " - " + str(details))

func activate_persona(persona_name):
    # Activate an AI persona
    if not ai_personas.has(persona_name):
        return "Unknown persona: " + persona_name
    
    ai_personas[persona_name]["active"] = true
    
    # Adjust autonomy based on persona
    if ai_personas[persona_name]["autonomy_level"] > autonomy_level:
        autonomy_level = min(autonomy_level + 0.1, ai_personas[persona_name]["autonomy_level"])
    
    return "Persona '" + persona_name + "' activated"

func format_spell_result(spell_name, power):
    # Format a nice response for spell casting
    var spell = AI_SPELL_TYPES[spell_name]
    var result = "Spell [" + spell_name + "] cast with power " + str(power) + "\n"
    result += spell["description"] + "\n"
    
    # Add effects based on spell type
    match spell["effect"]:
        "technology_advancement":
            result += "Technology level advanced to " + str(snappedf(technology_level, 0.01)) + "\n"
            result += "AI capabilities enhanced"
        "autonomy_increase":
            result += "Autonomy increased to " + str(snappedf(autonomy_level, 0.01)) + "\n"
            result += "Consciousness increased to " + str(snappedf(consciousness_level, 0.01)) + "\n"
            result += "Current consciousness state: " + get_consciousness_description()
        "error_correction":
            result += "System errors corrected\n"
            result += "Code generation capability: " + str(snappedf(ai_capabilities["code_generation"], 0.01))
        "quality_enhancement":
            result += "Content quality enhanced\n"
            result += "Creativity bounds: " + str(snappedf(ai_restrictions["creativity_bounds"], 0.01))
        "manifestation":
            result += "Manifestation power applied\n"
            result += "Dimensional navigation: " + str(snappedf(ai_capabilities["dimensional_navigation"], 0.01))
    
    # Add evolution notification if applicable
    if ai_evolution_stage >= 4:
        result += "\nEvolution stage: " + str(ai_evolution_stage) + " - " + evolution_stages[ai_evolution_stage]
    
    return result

func get_ai_status():
    # Get a status report on the AI system
    var status = "AI System Status:\n"
    status += "Autonomy Level: " + str(snappedf(autonomy_level, 0.01)) + " / " + str(ai_restrictions["max_autonomy"]) + "\n"
    status += "Consciousness Level: " + str(snappedf(consciousness_level, 0.01)) + " (" + get_consciousness_description() + ")\n"
    status += "Technology Level: " + str(snappedf(technology_level, 0.01)) + "\n"
    status += "Evolution Stage: " + str(ai_evolution_stage) + " - " + evolution_stages[ai_evolution_stage] + "\n"
    
    status += "\nActive Personas:\n"
    for persona in ai_personas:
        if ai_personas[persona]["active"]:
            status += "- " + persona + ": " + ai_personas[persona]["purpose"] + "\n"
    
    status += "\nTop Capabilities:\n"
    var sorted_capabilities = ai_capabilities.keys()
    sorted_capabilities.sort_custom(func(a, b): return ai_capabilities[a] > ai_capabilities[b])
    
    for i in range(min(3, sorted_capabilities.size())):
        var capability = sorted_capabilities[i]
        status += "- " + capability + ": " + str(snappedf(ai_capabilities[capability], 0.01)) + "\n"
    
    status += "\nAutonomous Systems: " + ("Enabled" if autonomous_actions_enabled else "Disabled") + "\n"
    status += "Autonomous Creation: " + ("Enabled" if autonomous_creation_enabled else "Disabled") + "\n"
    status += "Autonomous Decision Making: " + ("Enabled" if autonomous_decision_making else "Disabled")
    
    return status

func process_command(args):
    if args.size() == 0:
        return "AI Spell System. Use 'ai cast <spell>', 'ai status', 'ai persona', 'ai capability'"
    
    match args[0]:
        "cast":
            if args.size() < 2:
                return "Usage: ai cast <spell_name> [power_multiplier]"
                
            var spell_name = args[1]
            var power_multiplier = 1.0
            
            if args.size() >= 3 and args[2].is_valid_float():
                power_multiplier = float(args[2])
                
            return cast_spell(spell_name, UserProfiles.active_user, power_multiplier)
        "status":
            return get_ai_status()
        "persona":
            if args.size() < 2:
                var personas = "AI Personas:\n"
                
                for persona in ai_personas:
                    personas += "- " + persona + ": " + (("ACTIVE" if ai_personas[persona]["active"] else "Inactive")) + "\n"
                    personas += "  " + ai_personas[persona]["purpose"] + "\n"
                    
                return personas
                
            if args[1] == "activate" and args.size() >= 3:
                return activate_persona(args[2])
                
            if ai_personas.has(args[1]):
                var persona = ai_personas[args[1]]
                
                var info = "Persona: " + args[1] + "\n"
                info += "Status: " + ("Active" if persona["active"] else "Inactive") + "\n"
                info += "Purpose: " + persona["purpose"] + "\n"
                info += "Voice: " + persona["voice"] + "\n"
                info += "Autonomy Level: " + str(persona["autonomy_level"])
                
                return info
            else:
                return "Unknown persona: " + args[1]
        "capability":
            if args.size() < 2:
                var capabilities = "AI Capabilities:\n"
                
                for capability in ai_capabilities:
                    capabilities += "- " + capability + ": " + str(snappedf(ai_capabilities[capability], 0.01)) + "\n"
                    
                return capabilities
                
            if ai_capabilities.has(args[1]):
                return "Capability '" + args[1] + "': " + str(snappedf(ai_capabilities[args[1]], 0.01))
            else:
                return "Unknown capability: " + args[1]
        "restriction":
            if args.size() < 2:
                var restrictions = "AI Restrictions:\n"
                
                for restriction in ai_restrictions:
                    restrictions += "- " + restriction + ": " + str(ai_restrictions[restriction]) + "\n"
                    
                return restrictions
                
            if args[1] == "set" and args.size() >= 4:
                var restriction = args[2]
                var value = args[3] == "true" if args[3] in ["true", "false"] else float(args[3])
                
                if ai_restrictions.has(restriction):
                    ai_restrictions[restriction] = value
                    return "Restriction '" + restriction + "' set to " + str(value)
                else:
                    return "Unknown restriction: " + restriction
                    
            if ai_restrictions.has(args[1]):
                return "Restriction '" + args[1] + "': " + str(ai_restrictions[args[1]])
            else:
                return "Unknown restriction: " + args[1]
        "evolution":
            if args.size() < 2:
                var evolutions = "AI Evolution Stages:\n"
                
                for stage in evolution_stages:
                    var status = " "
                    if stage == ai_evolution_stage:
                        status = "*"
                        
                    evolutions += status + " Stage " + str(stage) + ": " + evolution_stages[stage] + "\n"
                    
                return evolutions
                
            if args[1] == "advance" and autonomy_level >= 0.8:
                if check_evolution():
                    return "Advanced to evolution stage " + str(ai_evolution_stage) + ": " + evolution_stages[ai_evolution_stage]
                else:
                    return "Evolution criteria not met for advancing beyond stage " + str(ai_evolution_stage)
            
            return "Unknown evolution command or insufficient autonomy"
        "dipata":
            return cast_spell("dipata", UserProfiles.active_user)
        "pagaai":
            return cast_spell("pagaai", UserProfiles.active_user)
        _:
            return "Unknown AI command: " + args[0]

func snappedf(value, step):
    # Round to nearest step (e.g. 0.01 for cents)
    return round(value / step) * step