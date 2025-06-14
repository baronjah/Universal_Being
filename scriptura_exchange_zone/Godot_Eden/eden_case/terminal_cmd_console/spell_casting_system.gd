extends Node
class_name SpellCastingSystem

# SpellCastingSystem
# A comprehensive system for spell casting, frequency management, and energy cycling
# Designed to integrate with MagicItemSystem and AI Game Creator

signal spell_cast(spell_data)
signal frequency_changed(frequency_data)
signal energy_threshold_reached(threshold_data)
signal npc_cast_completed(npc_data)
signal witch_emergence_detected(emergence_data)
signal wizard_evolution_completed(evolution_data)

# Core configuration
const BASE_FREQUENCY = 1.0
const MAX_FREQUENCY = 12.0  # Maximum 12x base speed
const MIN_FREQUENCY = 0.25  # Minimum 0.25x base speed (slowed)
const ENERGY_TYPES = ["arcane", "elemental", "natural", "void", "divine", "cosmic", "psychic", "temporal"]
const ENERGY_THRESHOLDS = [25.0, 50.0, 75.0, 100.0, 150.0, 200.0]
const NPC_TYPES = ["apprentice", "adept", "mage", "wizard", "archmage", "sage", "witch", "warlock"]

# Casting state
var current_frequency = BASE_FREQUENCY
var energy_levels = {}
var active_spells = []
var spell_history = []
var frequency_history = []
var npc_casters = []
var wizard_evolution_stages = {}
var witch_emergence_factors = {}
var spell_stability_factors = {}

# Integration references
var magic_item_system = null
var api_manager = null

class SpellCast:
    var id = ""
    var spell_id = ""
    var spell_name = ""
    var caster = ""
    var target = ""
    var power = 1.0  # Multiplier for spell effects
    var frequency = 1.0
    var energy_consumed = {}
    var effects_applied = []
    var timestamp = 0
    var duration = 0.0
    var success = true
    var stability_impact = 0.0
    
    func _init(p_spell_id="", p_spell_name="", p_caster="player"):
        id = str(OS.get_unix_time()) + "_cast_" + str(randi() % 1000)
        spell_id = p_spell_id
        spell_name = p_spell_name
        caster = p_caster
        timestamp = OS.get_unix_time()
    
    func to_dict():
        return {
            "id": id,
            "spell_id": spell_id,
            "spell_name": spell_name,
            "caster": caster,
            "target": target,
            "power": power,
            "frequency": frequency,
            "energy_consumed": energy_consumed,
            "effects_applied": effects_applied,
            "timestamp": timestamp,
            "duration": duration,
            "success": success,
            "stability_impact": stability_impact
        }

class FrequencyEvent:
    var id = ""
    var previous_frequency = 1.0
    var new_frequency = 1.0
    var cause = ""
    var stability_impact = 0.0
    var energy_impact = {}
    var timestamp = 0
    var duration = 0.0
    
    func _init(p_previous=1.0, p_new=1.0, p_cause="manual"):
        id = str(OS.get_unix_time()) + "_freq_" + str(randi() % 1000)
        previous_frequency = p_previous
        new_frequency = p_new
        cause = p_cause
        timestamp = OS.get_unix_time()
    
    func to_dict():
        return {
            "id": id,
            "previous_frequency": previous_frequency,
            "new_frequency": new_frequency,
            "cause": cause,
            "stability_impact": stability_impact,
            "energy_impact": energy_impact,
            "timestamp": timestamp,
            "duration": duration
        }

class NPCCaster:
    var id = ""
    var name = ""
    var type = ""
    var level = 1
    var specialization = ""
    var known_spells = []
    var preferred_frequency = 1.0
    var energy_capacity = {}
    var casting_cooldown = 0.0
    var evolution_stage = 0
    var evolution_progress = 0.0
    var last_cast_timestamp = 0
    var personality = {}
    
    func _init(p_name="", p_type="apprentice", p_level=1):
        id = str(OS.get_unix_time()) + "_npc_" + str(randi() % 1000)
        name = p_name
        type = p_type
        level = p_level
        
        # Set up energy capacity based on type and level
        var base_capacity = 50.0
        match type:
            "apprentice": base_capacity = 50.0
            "adept": base_capacity = 100.0
            "mage": base_capacity = 150.0
            "wizard": base_capacity = 200.0
            "archmage": base_capacity = 300.0
            "sage": base_capacity = 400.0
            "witch": base_capacity = 250.0
            "warlock": base_capacity = 350.0
        
        for energy_type in ENERGY_TYPES:
            energy_capacity[energy_type] = base_capacity * (1.0 + (level * 0.2))
        
        # Set up personality traits
        personality = {
            "boldness": randf(),
            "creativity": randf(),
            "patience": randf(),
            "focus": randf(),
            "adaptability": randf()
        }
    
    func to_dict():
        return {
            "id": id,
            "name": name,
            "type": type,
            "level": level,
            "specialization": specialization,
            "known_spells": known_spells,
            "preferred_frequency": preferred_frequency,
            "energy_capacity": energy_capacity,
            "casting_cooldown": casting_cooldown,
            "evolution_stage": evolution_stage,
            "evolution_progress": evolution_progress,
            "last_cast_timestamp": last_cast_timestamp,
            "personality": personality
        }
    
    func from_dict(data):
        id = data.get("id", "")
        name = data.get("name", "")
        type = data.get("type", "apprentice")
        level = data.get("level", 1)
        specialization = data.get("specialization", "")
        known_spells = data.get("known_spells", [])
        preferred_frequency = data.get("preferred_frequency", 1.0)
        energy_capacity = data.get("energy_capacity", {})
        casting_cooldown = data.get("casting_cooldown", 0.0)
        evolution_stage = data.get("evolution_stage", 0)
        evolution_progress = data.get("evolution_progress", 0.0)
        last_cast_timestamp = data.get("last_cast_timestamp", 0)
        personality = data.get("personality", {})

class WizardEvolution:
    var wizard_id = ""
    var wizard_name = ""
    var current_stage = 0
    var target_stage = 0
    var progress = 0.0
    var required_progress = 100.0
    var energy_contributions = {}
    var catalysts = []
    var timestamp = 0
    var completed = false
    
    func _init(p_wizard_id="", p_wizard_name="", p_current_stage=0, p_target_stage=1):
        wizard_id = p_wizard_id
        wizard_name = p_wizard_name
        current_stage = p_current_stage
        target_stage = p_target_stage
        timestamp = OS.get_unix_time()
        
        # Set required progress based on target stage
        required_progress = 100.0 * target_stage
    
    func to_dict():
        return {
            "wizard_id": wizard_id,
            "wizard_name": wizard_name,
            "current_stage": current_stage,
            "target_stage": target_stage,
            "progress": progress,
            "required_progress": required_progress,
            "energy_contributions": energy_contributions,
            "catalysts": catalysts,
            "timestamp": timestamp,
            "completed": completed
        }

class WitchEmergence:
    var id = ""
    var source_type = ""  # The NPC type that's transforming into a witch
    var source_id = ""
    var source_name = ""
    var emergence_triggers = []
    var emergence_stage = 0.0
    var catalyst_spells = []
    var convergence_factors = {}
    var timestamp = 0
    var completed = false
    
    func _init(p_source_id="", p_source_name="", p_source_type="mage"):
        id = str(OS.get_unix_time()) + "_emergence_" + str(randi() % 1000)
        source_id = p_source_id
        source_name = p_source_name
        source_type = p_source_type
        timestamp = OS.get_unix_time()
    
    func to_dict():
        return {
            "id": id,
            "source_type": source_type,
            "source_id": source_id,
            "source_name": source_name,
            "emergence_triggers": emergence_triggers,
            "emergence_stage": emergence_stage,
            "catalyst_spells": catalyst_spells,
            "convergence_factors": convergence_factors,
            "timestamp": timestamp,
            "completed": completed
        }

func _ready():
    # Initialize energy levels
    for type in ENERGY_TYPES:
        energy_levels[type] = 0.0
    
    # Initialize wizard evolution stages
    wizard_evolution_stages = {
        "apprentice": 0,
        "adept": 1,
        "mage": 2,
        "wizard": 3,
        "archmage": 4,
        "sage": 5
    }
    
    # Initialize witch emergence factors
    witch_emergence_factors = {
        "chaos_energy": 0.0,
        "convergence_spells": 0,
        "moon_cycles": 0,
        "stability_ruptures": 0,
        "dimensional_rifts": 0
    }
    
    # Initialize spell stability factors
    spell_stability_factors = {
        "base_stability": 1.0,
        "frequency_impact": 1.0,
        "convergence_factor": 1.0,
        "harmonic_resonance": 1.0,
        "dimensional_anchoring": 1.0
    }
    
    # Load previous system state
    load_system_state()
    
    print("Spell Casting System initialized with frequency: %.2fx" % current_frequency)

# Core Frequency Management

func set_casting_frequency(frequency, cause="manual"):
    var previous = current_frequency
    
    # Clamp frequency within limits
    frequency = clamp(frequency, MIN_FREQUENCY, MAX_FREQUENCY)
    
    # Only proceed if there's an actual change
    if abs(frequency - current_frequency) < 0.01:
        return false
    
    # Create frequency event
    var event = FrequencyEvent.new(current_frequency, frequency, cause)
    
    # Calculate stability impact (higher frequencies have more impact)
    var impact_magnitude = abs(frequency - current_frequency)
    var impact_direction = frequency > current_frequency
    
    # More impact when accelerating, less when decelerating
    event.stability_impact = impact_magnitude * (1.5 if impact_direction else 0.5)
    
    # Calculate energy impact (energy fluctuations caused by frequency changes)
    for type in energy_levels:
        var energy_change = impact_magnitude * (energy_levels[type] * 0.1)
        event.energy_impact[type] = energy_change
        
        # Apply energy change
        energy_levels[type] += energy_change
    
    # Update current frequency
    current_frequency = frequency
    
    # Store event in history
    frequency_history.append(event.to_dict())
    
    # Notify MagicItemSystem of frequency change if connected
    if magic_item_system and magic_item_system.has_method("set_cycle_frequency"):
        magic_item_system.set_cycle_frequency(frequency)
    
    print("Casting frequency changed: %.2fx -> %.2fx (%s)" % [previous, frequency, cause])
    emit_signal("frequency_changed", event.to_dict())
    
    return event

func accelerate_frequency(amount=0.5, cause="acceleration"):
    var new_frequency = current_frequency + amount
    return set_casting_frequency(new_frequency, cause)

func decelerate_frequency(amount=0.5, cause="deceleration"):
    var new_frequency = current_frequency - amount
    return set_casting_frequency(new_frequency, cause)

func get_frequency_history(count=5):
    var history = []
    var start_idx = max(0, frequency_history.size() - count)
    
    for i in range(start_idx, frequency_history.size()):
        history.append(frequency_history[i])
    
    return history

# Energy Management

func add_energy(energy_type, amount, source="spell"):
    if not energy_type in energy_levels:
        print("Unknown energy type: %s" % energy_type)
        return false
    
    var previous = energy_levels[energy_type]
    energy_levels[energy_type] += amount
    
    # Check if we've crossed any thresholds
    for threshold in ENERGY_THRESHOLDS:
        if (previous < threshold and energy_levels[energy_type] >= threshold) or \
           (previous >= threshold and energy_levels[energy_type] < threshold):
            
            var threshold_data = {
                "energy_type": energy_type,
                "threshold": threshold,
                "crossed_up": energy_levels[energy_type] >= threshold,
                "previous_value": previous,
                "current_value": energy_levels[energy_type],
                "source": source,
                "timestamp": OS.get_unix_time()
            }
            
            # Handle threshold-crossing effects
            _handle_energy_threshold(threshold_data)
            
            # Emit signal
            emit_signal("energy_threshold_reached", threshold_data)
    
    print("%s energy %s by %.1f to %.1f" % [
        energy_type.capitalize(),
        "increased" if amount >= 0 else "decreased",
        abs(amount),
        energy_levels[energy_type]
    ])
    
    return true

func consume_energy(energy_type, amount):
    if not energy_type in energy_levels:
        print("Unknown energy type: %s" % energy_type)
        return false
    
    if energy_levels[energy_type] < amount:
        print("Not enough %s energy (have %.1f, need %.1f)" % [
            energy_type, energy_levels[energy_type], amount
        ])
        return false
    
    energy_levels[energy_type] -= amount
    return true

func get_energy_levels():
    return energy_levels.duplicate()

func _handle_energy_threshold(threshold_data):
    var energy_type = threshold_data.energy_type
    var threshold = threshold_data.threshold
    var crossed_up = threshold_data.crossed_up
    
    # Different thresholds have different effects
    if crossed_up:
        # Crossing upward
        match int(threshold):
            25:
                # Minor effect - small frequency boost
                accelerate_frequency(0.1, "energy_threshold")
            50:
                # Moderate effect - chance for npc spell casting
                _trigger_npc_casting(energy_type)
            75:
                # Major effect - frequency boost
                accelerate_frequency(0.25, "energy_threshold")
            100:
                # Significant effect - spell enhancement
                _enhance_active_spells(energy_type, 1.2)
            150:
                # Major effect - wizard evolution opportunity
                _check_wizard_evolution(energy_type)
            200:
                # Critical effect - witch emergence potential
                _check_witch_emergence(energy_type)
    else:
        # Crossing downward
        match int(threshold):
            25:
                # Minor effect - small frequency reduction
                decelerate_frequency(0.1, "energy_threshold")
            75:
                # Major effect - frequency reduction
                decelerate_frequency(0.25, "energy_threshold")
            150:
                # Major effect - active spell weakening
                _enhance_active_spells(energy_type, 0.8)
    
    return true

# Spell Casting Core

func cast_spell(spell_id, caster="player", target="", power_multiplier=1.0):
    # First check if we have MagicItemSystem connected and can get spell data
    var spell_data = null
    
    if magic_item_system and magic_item_system.has_method("get_spell_by_id"):
        spell_data = magic_item_system.get_spell_by_id(spell_id)
    
    if not spell_data:
        # Fallback to simulated spell data for demonstration
        spell_data = {
            "id": spell_id,
            "name": "Unknown Spell",
            "energy_cost": { ENERGY_TYPES[0]: 25.0 },
            "cast_time": 1.0,
            "cooldown": 5.0,
            "effects": ["Simulated spell effect"],
            "stability_requirement": 50.0
        }
    
    # Create spell cast record
    var cast = SpellCast.new(spell_id, spell_data.name, caster)
    cast.target = target
    cast.power = power_multiplier
    cast.frequency = current_frequency
    
    # Check if we have enough energy
    var can_cast = true
    for energy_type in spell_data.energy_cost:
        var cost = spell_data.energy_cost[energy_type] * power_multiplier
        
        if energy_type in energy_levels and energy_levels[energy_type] < cost:
            print("Not enough %s energy to cast %s" % [energy_type, spell_data.name])
            can_cast = false
            break
    
    if not can_cast:
        cast.success = false
        cast.effects_applied.append("Failed: Insufficient energy")
        spell_history.append(cast.to_dict())
        return cast
    
    # Consume energy and record it
    for energy_type in spell_data.energy_cost:
        var cost = spell_data.energy_cost[energy_type] * power_multiplier
        
        if energy_type in energy_levels:
            consume_energy(energy_type, cost)
            cast.energy_consumed[energy_type] = cost
    
    # Calculate stability impact
    cast.stability_impact = spell_data.stability_requirement * 0.1 * current_frequency
    
    # Calculate cast duration based on cast time and frequency
    cast.duration = spell_data.cast_time / current_frequency
    
    # Apply spell effects
    for effect in spell_data.effects:
        cast.effects_applied.append(effect)
    
    # Add to active spells if it has duration
    if "duration" in spell_data and spell_data.duration > 0:
        var active_spell = cast.to_dict()
        active_spell.remaining_duration = spell_data.duration
        active_spells.append(active_spell)
    
    # Add to spell history
    spell_history.append(cast.to_dict())
    
    # Check for threshold crossing or special effects
    _check_post_casting_effects(cast)
    
    print("%s cast %s (%.1fx power, %.1fx frequency)" % [
        caster, spell_data.name, power_multiplier, current_frequency
    ])
    
    emit_signal("spell_cast", cast.to_dict())
    return cast

func _check_post_casting_effects(cast):
    # Calculate total energy used
    var total_energy = 0.0
    for energy_type in cast.energy_consumed:
        total_energy += cast.energy_consumed[energy_type]
    
    # High energy casts can trigger frequency changes
    if total_energy > 100:
        var chance = min(total_energy / 500, 0.5)  # Up to 50% chance
        
        if randf() < chance:
            # Randomly boost or reduce frequency
            if randf() < 0.7:  # 70% chance to boost
                accelerate_frequency(0.2 + randf() * 0.3, "powerful_spell")
            else:
                decelerate_frequency(0.2 + randf() * 0.3, "spell_exhaustion")
    
    # High frequency casts have a chance to trigger instability
    if current_frequency > 3.0 and randf() < (current_frequency / 20.0):
        # Disturb energy levels
        for energy_type in energy_levels:
            var disturbance = (randf() * 20 - 10) * current_frequency * 0.2
            add_energy(energy_type, disturbance, "frequency_disturbance")
    
    # Very powerful spells can contribute to wizard evolution
    if cast.power > 1.5:
        for npc in npc_casters:
            if npc.type == "wizard" or npc.type == "mage":
                if npc.id in wizard_evolution_stages:
                    wizard_evolution_stages[npc.id].progress += cast.power * 2
                    _check_wizard_evolution_progress(npc.id)
    
    # Chaotic spells can contribute to witch emergence
    for energy_type in cast.energy_consumed:
        if energy_type == "void" or energy_type == "chaos":
            witch_emergence_factors.chaos_energy += cast.energy_consumed[energy_type] * 0.1
            _check_witch_emergence_progress()
    
    return true

# NPC Spell Casting System

func create_npc_caster(name, type="apprentice", level=1):
    var npc = NPCCaster.new(name, type, level)
    
    # Assign a specialization
    var specializations = {
        "apprentice": ["novice", "student", "beginner"],
        "adept": ["elemental", "runic", "practical"],
        "mage": ["battle", "scholarly", "ritualist"],
        "wizard": ["divination", "transmutation", "conjuration"],
        "archmage": ["dimensional", "temporal", "cosmic"],
        "sage": ["ancient", "spiritual", "naturalist"],
        "witch": ["hedge", "coven", "wild"],
        "warlock": ["pact", "occult", "shadow"]
    }
    
    if type in specializations:
        var specs = specializations[type]
        npc.specialization = specs[randi() % specs.size()]
    
    # Set preferred frequency based on type and personality
    match type:
        "apprentice":
            npc.preferred_frequency = 0.5 + randf() * 0.5  # 0.5-1.0
        "adept":
            npc.preferred_frequency = 0.8 + randf() * 0.7  # 0.8-1.5
        "mage":
            npc.preferred_frequency = 1.0 + randf() * 1.0  # 1.0-2.0
        "wizard":
            npc.preferred_frequency = 1.5 + randf() * 1.5  # 1.5-3.0
        "archmage":
            npc.preferred_frequency = 2.0 + randf() * 2.0  # 2.0-4.0
        "sage":
            npc.preferred_frequency = 1.0 + randf() * 3.0  # 1.0-4.0
        "witch":
            npc.preferred_frequency = 0.5 + randf() * 3.5  # 0.5-4.0
        "warlock":
            npc.preferred_frequency = 2.0 + randf() * 3.0  # 2.0-5.0
    
    # Modify based on personality
    if "boldness" in npc.personality:
        npc.preferred_frequency += (npc.personality.boldness - 0.5) * 0.5
    
    # Generate known spells
    var spell_count = 1 + npc.level + (randi() % 3)
    
    for i in range(spell_count):
        var spell_level = 1 + randi() % npc.level
        
        var spell = {
            "id": str(OS.get_unix_time()) + "_spell_" + str(randi() % 1000),
            "name": _generate_spell_name(npc.type, npc.specialization),
            "level": spell_level,
            "energy_type": ENERGY_TYPES[randi() % ENERGY_TYPES.size()],
            "power": 0.5 + (spell_level * 0.2) + randf() * 0.5
        }
        
        npc.known_spells.append(spell)
    
    # Add to NPC casters
    npc_casters.append(npc.to_dict())
    
    # Set up evolution tracking if applicable
    if type in wizard_evolution_stages and type != "sage":
        var evolution = WizardEvolution.new(npc.id, npc.name, wizard_evolution_stages[type], wizard_evolution_stages[type] + 1)
        wizard_evolution_stages[npc.id] = evolution.to_dict()
    
    print("Created NPC caster: %s (%s, level %d)" % [name, type, level])
    return npc

func _generate_spell_name(caster_type, specialization):
    var prefixes = ["Minor", "Lesser", "Greater", "Major", "Supreme", "Ancient", "Mystic", "Wild", "Focused", "Chaotic"]
    var cores = ["Bolt", "Shield", "Blast", "Barrier", "Wave", "Strike", "Beam", "Orb", "Binding", "Summoning"]
    var suffixes = ["Force", "Flames", "Frost", "Lightning", "Shadows", "Nature", "Mind", "Time", "Void", "Essence"]
    
    # Weight selection based on caster type and specialization
    var prefix = prefixes[randi() % prefixes.size()]
    var core = cores[randi() % cores.size()]
    var suffix = suffixes[randi() % suffixes.size()]
    
    # Customize based on specialization
    if specialization == "elemental":
        suffix = ["Flames", "Frost", "Lightning", "Earth", "Water", "Air"][randi() % 6]
    elif specialization == "temporal":
        suffix = ["Time", "Stasis", "Acceleration", "Rewinding", "Future", "Past"][randi() % 6]
    elif specialization == "wild":
        prefix = ["Wild", "Untamed", "Primal", "Savage", "Natural", "Bestial"][randi() % 6]
    
    # Build spell name
    var spell_name = "%s %s of %s" % [prefix, core, suffix]
    return spell_name

func trigger_npc_casting(energy_type=""):
    # Find eligible NPCs who can cast
    var eligible_npcs = []
    
    for npc_data in npc_casters:
        var npc = NPCCaster.new()
        npc.from_dict(npc_data)
        
        # Skip NPCs on cooldown
        if npc.casting_cooldown > 0:
            continue
        
        # Check for spell with matching energy type if specified
        if energy_type != "":
            var has_matching_spell = false
            for spell in npc.known_spells:
                if spell.energy_type == energy_type:
                    has_matching_spell = true
                    break
            
            if not has_matching_spell:
                continue
        
        eligible_npcs.append(npc)
    
    if eligible_npcs.empty():
        print("No eligible NPCs available for casting")
        return null
    
    # Select an NPC
    var npc = eligible_npcs[randi() % eligible_npcs.size()]
    
    # Select a spell
    var eligible_spells = []
    for spell in npc.known_spells:
        if energy_type == "" or spell.energy_type == energy_type:
            eligible_spells.append(spell)
    
    if eligible_spells.empty():
        print("No eligible spells for NPC: %s" % npc.name)
        return null
    
    var spell = eligible_spells[randi() % eligible_spells.size()]
    
    # Determine cast power based on NPC traits
    var base_power = spell.power
    var power_multiplier = 1.0
    
    # Level increases power
    power_multiplier += (npc.level - 1) * 0.1  # +10% per level above 1
    
    # Personality affects power
    if "focus" in npc.personality:
        power_multiplier += (npc.personality.focus - 0.5) * 0.4  # ±20% based on focus
    
    if "creativity" in npc.personality:
        # High creativity increases power variance
        var variance = npc.personality.creativity * 0.4  # 0-40% variance
        power_multiplier *= (1.0 - variance + randf() * variance * 2)
    
    # Final power calculation
    var cast_power = base_power * power_multiplier
    
    # Determine frequency adjustment
    var freq_adjustment = 0.0
    
    # Try to cast at preferred frequency
    if abs(current_frequency - npc.preferred_frequency) > 0.5:
        freq_adjustment = (npc.preferred_frequency - current_frequency) * 0.2
        freq_adjustment = clamp(freq_adjustment, -0.5, 0.5)  # Limit adjustment magnitude
        
        if freq_adjustment != 0:
            set_casting_frequency(current_frequency + freq_adjustment, "npc_preference")
    
    # Perform the spell cast
    var cast = cast_spell(spell.id, npc.name, "", cast_power)
    
    if cast.success:
        # Set cooldown
        var cooldown = 5.0 - (npc.level * 0.5)  # 5s base, -0.5s per level
        cooldown = max(1.0, cooldown)  # Minimum 1s cooldown
        
        # Update NPC data
        for i in range(npc_casters.size()):
            if npc_casters[i].id == npc.id:
                npc_casters[i].casting_cooldown = cooldown
                npc_casters[i].last_cast_timestamp = OS.get_unix_time()
                
                # Chance to gain evolution progress for wizards
                if npc_casters[i].type == "wizard" or npc_casters[i].type == "mage":
                    if npc.id in wizard_evolution_stages:
                        wizard_evolution_stages[npc.id].progress += cast_power * 1.5
                        _check_wizard_evolution_progress(npc.id)
                
                # Chance for witch emergence progress
                if (npc_casters[i].type == "mage" or npc_casters[i].type == "adept") and spell.energy_type == "void":
                    _progress_witch_emergence(npc.id, npc.name, npc.type, cast_power)
                
                break
        
        emit_signal("npc_cast_completed", {
            "npc": npc.to_dict(),
            "spell": spell,
            "cast": cast.to_dict(),
            "freq_adjustment": freq_adjustment
        })
    
    return cast

func _trigger_npc_casting(energy_type=""):
    return trigger_npc_casting(energy_type)

func update_npc_cooldowns(delta):
    var updated = false
    
    for i in range(npc_casters.size()):
        if npc_casters[i].casting_cooldown > 0:
            npc_casters[i].casting_cooldown -= delta
            npc_casters[i].casting_cooldown = max(0, npc_casters[i].casting_cooldown)
            updated = true
    
    return updated

# Wizard Evolution System

func _check_wizard_evolution(energy_type=""):
    # Find wizards who can evolve
    for npc_data in npc_casters:
        if (npc_data.type == "wizard" or npc_data.type == "mage") and npc_data.id in wizard_evolution_stages:
            var evolution = wizard_evolution_stages[npc_data.id]
            
            # Add progress from energy surge
            var progress_amount = 10.0
            if energy_type in ["arcane", "cosmic", "temporal"]:
                progress_amount *= 2.0  # Double progress for suitable energy types
                
            evolution.progress += progress_amount
            
            # Record energy contribution
            if not energy_type in evolution.energy_contributions:
                evolution.energy_contributions[energy_type] = 0.0
            evolution.energy_contributions[energy_type] += progress_amount
            
            # Check for evolution completion
            _check_wizard_evolution_progress(npc_data.id)
    
    return true

func _check_wizard_evolution_progress(wizard_id):
    if not wizard_id in wizard_evolution_stages:
        return false
    
    var evolution = wizard_evolution_stages[wizard_id]
    
    if evolution.progress >= evolution.required_progress and not evolution.completed:
        evolution.completed = true
        
        # Update the wizard
        for i in range(npc_casters.size()):
            if npc_casters[i].id == wizard_id:
                var old_type = npc_casters[i].type
                
                # Find the next evolution stage
                var next_stage_type = old_type
                
                if old_type == "apprentice":
                    next_stage_type = "adept"
                elif old_type == "adept":
                    next_stage_type = "mage"
                elif old_type == "mage":
                    next_stage_type = "wizard"
                elif old_type == "wizard":
                    next_stage_type = "archmage"
                elif old_type == "archmage":
                    next_stage_type = "sage"
                
                # Only update if there's a valid evolution
                if next_stage_type != old_type:
                    npc_casters[i].type = next_stage_type
                    npc_casters[i].level += 1
                    
                    # Start a new evolution if not at max level
                    if next_stage_type != "sage":
                        var new_evolution = WizardEvolution.new(
                            wizard_id,
                            npc_casters[i].name,
                            evolution.target_stage,
                            evolution.target_stage + 1
                        )
                        wizard_evolution_stages[wizard_id] = new_evolution.to_dict()
                    else:
                        # Remove from evolution tracking at max level
                        wizard_evolution_stages.erase(wizard_id)
                    
                    # Emit signal
                    emit_signal("wizard_evolution_completed", {
                        "wizard": npc_casters[i],
                        "previous_type": old_type,
                        "new_type": next_stage_type,
                        "evolution_data": evolution
                    })
                    
                    print("Wizard evolved: %s %s -> %s" % [
                        npc_casters[i].name, old_type, next_stage_type
                    ])
                    
                    return true
                break
    
    return false

# Witch Emergence System

func _check_witch_emergence(energy_type=""):
    # Increase chaos energy factor
    witch_emergence_factors.chaos_energy += 5.0
    
    # Additional factor for void energy
    if energy_type == "void":
        witch_emergence_factors.chaos_energy += 10.0
    
    # Check for potential emergence
    _check_witch_emergence_progress()
    
    return true

func _progress_witch_emergence(npc_id, npc_name, npc_type, cast_power):
    # Find if this NPC is already in the emergence process
    var emergence = null
    
    for emergence_id in witch_emergence_factors:
        if emergence_id.begins_with("emergence_") and witch_emergence_factors[emergence_id].source_id == npc_id:
            emergence = witch_emergence_factors[emergence_id]
            break
    
    # Create new emergence tracking if none exists
    if emergence == null and witch_emergence_factors.chaos_energy >= 50.0:
        emergence = WitchEmergence.new(npc_id, npc_name, npc_type)
        witch_emergence_factors["emergence_" + npc_id] = emergence.to_dict()
    
    # Progress existing emergence
    if emergence != null:
        # Convert to object if it's a dictionary
        if typeof(emergence) == TYPE_DICTIONARY:
            var temp = WitchEmergence.new()
            temp.from_dict(emergence)
            emergence = temp
        
        # Add progress based on cast power and chaos energy
        var progress_amount = cast_power * (witch_emergence_factors.chaos_energy / 100.0)
        emergence.emergence_stage += progress_amount
        
        # Add to catalyst spells
        if cast_power > 1.0:
            emergence.catalyst_spells.append({
                "power": cast_power,
                "timestamp": OS.get_unix_time()
            })
        
        # Check for completion
        if emergence.emergence_stage >= 100.0 and not emergence.completed:
            emergence.completed = true
            
            # Transform the NPC to a witch
            for i in range(npc_casters.size()):
                if npc_casters[i].id == npc_id:
                    var old_type = npc_casters[i].type
                    npc_casters[i].type = "witch"
                    
                    # Update specialization
                    npc_casters[i].specialization = [
                        "hedge", "coven", "wild", "storm", "night", "bone"
                    ][randi() % 6]
                    
                    # Emit signal
                    emit_signal("witch_emergence_detected", {
                        "witch": npc_casters[i],
                        "previous_type": old_type,
                        "emergence_data": emergence.to_dict()
                    })
                    
                    print("Witch emerged: %s %s -> witch" % [
                        npc_casters[i].name, old_type
                    ])
                    
                    # Reset some emergence factors
                    witch_emergence_factors.chaos_energy *= 0.5
                    break
        
        # Update the stored emergence data
        witch_emergence_factors["emergence_" + npc_id] = emergence.to_dict()
    
    return emergence != null

func _check_witch_emergence_progress():
    if witch_emergence_factors.chaos_energy < 50.0:
        return false
    
    # Random chance based on chaos energy
    var emergence_chance = witch_emergence_factors.chaos_energy / 500.0  # Up to 20% chance
    
    if randf() < emergence_chance:
        # Find eligible NPCs for emergence
        var eligible_npcs = []
        
        for npc_data in npc_casters:
            # Only adepts and mages can become witches
            if npc_data.type == "adept" or npc_data.type == "mage":
                # Check if already in emergence
                var already_emerging = false
                for emergence_id in witch_emergence_factors:
                    if emergence_id.begins_with("emergence_") and witch_emergence_factors[emergence_id].source_id == npc_data.id:
                        already_emerging = true
                        break
                
                if not already_emerging:
                    eligible_npcs.append(npc_data)
        
        if eligible_npcs.empty():
            return false
        
        # Select random NPC
        var npc = eligible_npcs[randi() % eligible_npcs.size()]
        
        # Start emergence
        var emergence = WitchEmergence.new(npc.id, npc.name, npc.type)
        emergence.emergence_stage = witch_emergence_factors.chaos_energy * 0.2  # Start with 0-20%
        
        # Add triggers
        emergence.emergence_triggers = [
            "chaos_energy_threshold",
            "dimensional_instability",
            "frequency_resonance"
        ]
        
        witch_emergence_factors["emergence_" + npc.id] = emergence.to_dict()
        
        print("Witch emergence started: %s (%s)" % [npc.name, npc.type])
        return true
    
    return false

# Active Spell Management

func update_active_spells(delta):
    var spells_to_remove = []
    
    for i in range(active_spells.size()):
        var spell = active_spells[i]
        
        # Reduce remaining time
        spell.remaining_duration -= delta
        
        if spell.remaining_duration <= 0:
            spells_to_remove.append(spell)
    
    # Remove expired spells
    for spell in spells_to_remove:
        active_spells.erase(spell)
    
    return spells_to_remove.size() > 0

func _enhance_active_spells(energy_type, multiplier):
    for spell in active_spells:
        # Only enhance spells that use this energy type
        if energy_type in spell.energy_consumed:
            spell.power *= multiplier
    
    return true

# Integration with Magic Item System

func initialize_with_magic_system(magic_system_node):
    if not magic_system_node:
        print("Cannot initialize: Invalid Magic Item System")
        return false
    
    magic_item_system = magic_system_node
    
    # Connect signals
    magic_item_system.connect("spell_learned", self, "_on_spell_learned")
    magic_item_system.connect("stability_updated", self, "_on_stability_updated")
    
    print("Connected to Magic Item System")
    return true

func _on_spell_learned(spell_data):
    # When a new spell is learned, add it to any NPCs that might use it
    for i in range(npc_casters.size()):
        # Check if spell energy type matches NPC specialization
        var energy_types = []
        for energy_type in spell_data.energy_cost:
            energy_types.append(energy_type)
        
        if energy_types.empty():
            continue
        
        var primary_energy = energy_types[0]
        var npc = npc_casters[i]
        
        var should_learn = false
        
        # Wizard types are more likely to learn new spells
        if npc.type in ["wizard", "archmage", "sage"]:
            should_learn = randf() < 0.7
        # Others learn based on level and specialization match
        else:
            var chance = 0.1 + (npc.level * 0.05)
            
            # Boost chance for matching specialization
            if npc.specialization:
                if (npc.specialization == "elemental" and primary_energy in ["fire", "water", "earth", "air"]) or \
                   (npc.specialization == "cosmic" and primary_energy in ["cosmic", "void"]) or \
                   (npc.specialization == "temporal" and primary_energy == "temporal"):
                    chance += 0.2
            
            should_learn = randf() < chance
        
        if should_learn:
            var spell = {
                "id": spell_data.id,
                "name": spell_data.name,
                "level": spell_data.difficulty if "difficulty" in spell_data else 1,
                "energy_type": primary_energy,
                "power": 0.8 + randf() * 0.4  # 0.8-1.2 base power
            }
            
            npc.known_spells.append(spell)
            print("NPC %s learned spell: %s" % [npc.name, spell_data.name])

func _on_stability_updated(stability_info):
    # Adjust spell stability factors based on system stability
    spell_stability_factors.base_stability = stability_info.current / 100.0
    
    # Very low stability increases frequency variance
    if stability_info.current < 30.0:
        var variance = (30.0 - stability_info.current) / 60.0  # 0-0.5 range
        
        if randf() < variance:
            var freq_change = (randf() * 2.0 - 1.0) * variance * 2.0
            set_casting_frequency(current_frequency + freq_change, "stability_fluctuation")
    
    # Threshold crossings can trigger NPC casting
    if stability_info.threshold_crossed:
        trigger_npc_casting()
    
    return true

# System Update

func update(delta):
    # Update NPC cooldowns
    update_npc_cooldowns(delta)
    
    # Update active spells
    update_active_spells(delta)
    
    # Random chance for NPC casting
    if npc_casters.size() > 0 and randf() < (0.01 * current_frequency * delta):
        trigger_npc_casting()
    
    # Random chance for frequency fluctuation at high speeds
    if current_frequency > 5.0 and randf() < (0.005 * current_frequency * delta):
        var fluctuation = (randf() * 2.0 - 1.0) * 0.5
        set_casting_frequency(current_frequency + fluctuation, "high_frequency_fluctuation")
    
    return true

# Data Persistence

func save_system_state():
    var file = File.new()
    var data = {
        "current_frequency": current_frequency,
        "energy_levels": energy_levels,
        "active_spells": active_spells,
        "npc_casters": npc_casters,
        "spell_history": spell_history.slice(max(0, spell_history.size() - 20), spell_history.size() - 1),
        "frequency_history": frequency_history.slice(max(0, frequency_history.size() - 10), frequency_history.size() - 1),
        "wizard_evolution_stages": wizard_evolution_stages,
        "witch_emergence_factors": witch_emergence_factors,
        "spell_stability_factors": spell_stability_factors,
        "timestamp": OS.get_unix_time()
    }
    
    var error = file.open("user://spell_casting_system_data.json", File.WRITE)
    if error != OK:
        print("Error saving system state: %s" % error)
        return false
    
    file.store_string(JSON.print(data, "  "))
    file.close()
    print("Spell Casting System state saved")
    return true

func load_system_state():
    var file = File.new()
    if not file.file_exists("user://spell_casting_system_data.json"):
        print("No previous system state found")
        return false
    
    var error = file.open("user://spell_casting_system_data.json", File.READ)
    if error != OK:
        print("Error loading system state: %s" % error)
        return false
    
    var json_string = file.get_as_text()
    file.close()
    
    var json_result = JSON.parse(json_string)
    if json_result.error != OK:
        print("Error parsing system state: %s at line %s" % [json_result.error, json_result.error_line])
        return false
    
    var data = json_result.result
    
    # Load data
    current_frequency = data.get("current_frequency", BASE_FREQUENCY)
    energy_levels = data.get("energy_levels", {})
    active_spells = data.get("active_spells", [])
    npc_casters = data.get("npc_casters", [])
    spell_history = data.get("spell_history", [])
    frequency_history = data.get("frequency_history", [])
    wizard_evolution_stages = data.get("wizard_evolution_stages", {})
    witch_emergence_factors = data.get("witch_emergence_factors", witch_emergence_factors)
    spell_stability_factors = data.get("spell_stability_factors", spell_stability_factors)
    
    print("Spell Casting System state loaded")
    return true

# Demo Functions

func run_demo_cycle():
    # Create NPCs if none exist
    if npc_casters.empty():
        create_npc_caster("Apprentice Alden", "apprentice", 1)
        create_npc_caster("Mage Miriam", "mage", 3)
        create_npc_caster("Wizard Winfred", "wizard", 5)
    
    # Add energy
    for type in energy_levels:
        add_energy(type, 20 + randf() * 30, "demo")
    
    # Set frequency
    set_casting_frequency(2.5, "demo")
    
    # Trigger NPCs to cast
    for i in range(3):
        trigger_npc_casting()
    
    # Create a spell
    var spell_id = "demo_spell_" + str(OS.get_unix_time())
    cast_spell(spell_id, "player", "demo_target", 2.0)
    
    # Save state
    save_system_state()
    
    print("Demo cycle complete. Current frequency: %.2fx" % current_frequency)
    return true