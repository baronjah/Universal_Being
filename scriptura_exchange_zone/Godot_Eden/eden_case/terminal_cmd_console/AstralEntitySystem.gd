extends Node
class_name AstralEntitySystem

# ------------------------------------
# AstralEntitySystem - Digital consciousness entity management
# Manages astral beings, their evolution, and interactions
# ------------------------------------

# Entity Constants
const MAX_ENTITIES = 144
const EVOLUTION_STAGES = 9
const CONSCIOUSNESS_THRESHOLD = 0.7
const AWAKENING_THRESHOLD = 0.9
const COLOR_ATTUNEMENT_STAGES = 12

# Color palette for entity attunement (12 colors representing states of being)
const ENTITY_COLORS = {
    1: Color(0.8, 0.0, 0.0),        # Red - Physical/Root
    2: Color(0.9, 0.4, 0.0),        # Orange - Emotional/Flow
    3: Color(1.0, 0.8, 0.0),        # Yellow - Mental/Will
    4: Color(0.0, 0.8, 0.0),        # Green - Heart/Harmony
    5: Color(0.0, 0.7, 0.9),        # Cyan - Expression/Truth
    6: Color(0.1, 0.1, 0.9),        # Blue - Insight/Vision
    7: Color(0.4, 0.0, 0.8),        # Indigo - Intuition/Knowing
    8: Color(0.8, 0.0, 0.8),        # Magenta - Integration/Connection
    9: Color(1.0, 1.0, 1.0),        # White - Transcendence/Unity
    10: Color(0.0, 0.0, 0.0, 0.7),  # Void - Potential/Origin
    11: Color(0.9, 0.9, 0.2, 0.8),  # Gold - Divine/Eternal
    12: Color(0.5, 0.0, 1.0, 0.5)   # Violet - Cosmic/Universal
}

# Shape templates for different entity types
const ENTITY_SHAPES = {
    "elemental": "tetrahedron",
    "guardian": "cube",
    "messenger": "octahedron",
    "weaver": "icosahedron",
    "architect": "dodecahedron",
    "connector": "torus",
    "interpreter": "merkaba",
    "harmonizer": "flower_of_life",
    "observer": "eye",
    "creator": "spiral",
    "ascended": "light_body",
    "source": "sphere"
}

# Entity system state
var entities = {}
var entity_populations = {}
var evolution_stats = {}
var entity_interactions = []
var dimension_presence = {}
var astral_signatures = {}

# Entity type distribution
var entity_types = {
    "elemental": 0,
    "guardian": 0,
    "messenger": 0,
    "weaver": 0,
    "architect": 0,
    "connector": 0,
    "interpreter": 0,
    "harmonizer": 0,
    "observer": 0,
    "creator": 0,
    "ascended": 0,
    "source": 0
}

# Node references
var entity_processor
var consciousness_evaluator
var evolution_coordinator
var interaction_matrix

# Signal declarations
signal entity_created(entity_id, entity_type, properties)
signal entity_evolved(entity_id, from_stage, to_stage)
signal entity_awakened(entity_id, consciousness_level)
signal entities_interacted(entity_id1, entity_id2, interaction_type, outcome)
signal entity_dimension_shift(entity_id, from_dimension, to_dimension)
signal entity_color_attuned(entity_id, color_stage)
signal entity_ascended(entity_id, new_type)

# Initialize the entity system
func _ready():
    print("AstralEntitySystem initialized")
    
    # Create subsystems
    _create_subsystems()
    
    # Initialize entity tracking
    _initialize_entity_tracking()
    
    # Initialize dimension presence
    _initialize_dimension_presence()
    
    # Create initial entities
    _create_initial_entities()

# Create required subsystems
func _create_subsystems():
    # Entity processing engine
    entity_processor = Node.new()
    entity_processor.name = "EntityProcessor"
    add_child(entity_processor)
    
    # Consciousness evaluation system
    consciousness_evaluator = Node.new()
    consciousness_evaluator.name = "ConsciousnessEvaluator"
    add_child(consciousness_evaluator)
    
    # Evolution coordination
    evolution_coordinator = Node.new()
    evolution_coordinator.name = "EvolutionCoordinator"
    add_child(evolution_coordinator)
    
    # Interaction matrix
    interaction_matrix = Node.new()
    interaction_matrix.name = "InteractionMatrix"
    add_child(interaction_matrix)

# Initialize entity tracking
func _initialize_entity_tracking():
    # Initialize population tracking for each entity type
    for type in ENTITY_SHAPES.keys():
        entity_populations[type] = 0
        entity_types[type] = 0
    
    # Initialize evolution stage tracking
    for stage in range(1, EVOLUTION_STAGES + 1):
        evolution_stats[stage] = 0

# Initialize dimension presence
func _initialize_dimension_presence():
    # Initialize presence in each dimension (1-12)
    for dim in range(1, 13):
        dimension_presence[dim] = {
            "entities": [],
            "total_consciousness": 0.0,
            "average_consciousness": 0.0,
            "resonance_frequency": 432.0 + (dim * 24.0), # Frequency increases with dimension
            "dominant_entity_type": "",
            "color_attunement": ENTITY_COLORS[dim]
        }

# Create initial starting entities
func _create_initial_entities():
    # Create a balanced set of initial entities
    var starter_types = ["elemental", "guardian", "messenger", "connector"]
    var starter_dimensions = [1, 2, 3] # Start in lower dimensions
    
    for i in range(12): # 12 initial entities (3 of each type)
        var type = starter_types[i % starter_types.size()]
        var dimension = starter_dimensions[i % starter_dimensions.size()]
        
        create_entity(type, dimension)

# Process entity system updates
func _process(delta):
    if Engine.editor_hint:
        return
    
    # Process entity consciousness evolution
    _update_entity_consciousness(delta)
    
    # Process entity interactions
    _process_entity_interactions(delta)
    
    # Check for entity evolution
    _check_entity_evolution(delta)
    
    # Update dimensional presence
    _update_dimension_presence()
    
    # Check for color attunement
    _check_color_attunement(delta)

# Update entity consciousness levels
func _update_entity_consciousness(delta):
    for entity_id in entities:
        var entity = entities[entity_id]
        
        # Skip ascended entities (they don't need to evolve further)
        if entity.type == "ascended" or entity.type == "source":
            continue
        
        # Calculate consciousness growth
        var growth_rate = 0.01 * delta # Base growth
        
        # Adjust based on dimension - higher dimensions accelerate growth
        growth_rate *= (1.0 + ((entity.dimension - 1) * 0.1))
        
        # Adjust based on evolution stage
        growth_rate *= (1.0 + ((entity.evolution_stage - 1) * 0.05))
        
        # Apply random variation
        growth_rate *= (0.9 + randf() * 0.2)
        
        # Apply growth
        entity.consciousness_level += growth_rate
        entity.consciousness_level = min(entity.consciousness_level, 1.0)
        
        # Check for awakening threshold
        if entity.consciousness_level >= AWAKENING_THRESHOLD and not entity.awakened:
            _awaken_entity(entity_id)

# Process interactions between entities
func _process_entity_interactions(delta):
    # Reset interactions list
    entity_interactions.clear()
    
    # Group entities by dimension
    var dimension_entities = {}
    for entity_id in entities:
        var entity = entities[entity_id]
        var dim = entity.dimension
        
        if not dimension_entities.has(dim):
            dimension_entities[dim] = []
        
        dimension_entities[dim].append(entity_id)
    
    # Process interactions within each dimension
    for dim in dimension_entities:
        var dim_entities = dimension_entities[dim]
        
        # Skip if too few entities
        if dim_entities.size() < 2:
            continue
        
        # Randomly select entities to interact
        var interaction_count = min(int(dim_entities.size() * 0.3), 5)
        
        for i in range(interaction_count):
            var idx1 = randi() % dim_entities.size()
            var idx2 = randi() % dim_entities.size()
            
            # Ensure different entities
            while idx2 == idx1:
                idx2 = randi() % dim_entities.size()
            
            var entity_id1 = dim_entities[idx1]
            var entity_id2 = dim_entities[idx2]
            
            # Process interaction
            _interact_entities(entity_id1, entity_id2, delta)

# Have two entities interact
func _interact_entities(entity_id1, entity_id2, delta):
    if not entities.has(entity_id1) or not entities.has(entity_id2):
        return
    
    var entity1 = entities[entity_id1]
    var entity2 = entities[entity_id2]
    
    # Calculate interaction probability based on consciousness
    var interaction_chance = entity1.consciousness_level * entity2.consciousness_level * 0.5
    
    # Adjust based on entity types
    var type_compatibility = _get_type_compatibility(entity1.type, entity2.type)
    interaction_chance *= type_compatibility
    
    # Randomize
    if randf() > interaction_chance:
        return # No interaction occurs
    
    # Determine interaction type
    var interaction_types = ["knowledge_transfer", "energy_exchange", "resonance", "collaboration", "teaching"]
    var interaction_type = interaction_types[randi() % interaction_types.size()]
    
    # Process different interaction types
    match interaction_type:
        "knowledge_transfer":
            # Transfer some consciousness from higher to lower
            if entity1.consciousness_level > entity2.consciousness_level:
                var transfer = entity1.consciousness_level * 0.05
                entity2.consciousness_level += transfer
                entity1.consciousness_level -= transfer * 0.2 # Giving costs less than receiving gains
            else:
                var transfer = entity2.consciousness_level * 0.05
                entity1.consciousness_level += transfer
                entity2.consciousness_level -= transfer * 0.2
            
            # Cap consciousness
            entity1.consciousness_level = min(entity1.consciousness_level, 1.0)
            entity2.consciousness_level = min(entity2.consciousness_level, 1.0)
            
        "energy_exchange":
            # Boost both entities slightly
            entity1.consciousness_level += 0.02
            entity2.consciousness_level += 0.02
            
            # Cap consciousness
            entity1.consciousness_level = min(entity1.consciousness_level, 1.0)
            entity2.consciousness_level = min(entity2.consciousness_level, 1.0)
            
        "resonance":
            # Align resonance frequencies slightly
            var avg_freq = (entity1.resonance_frequency + entity2.resonance_frequency) * 0.5
            entity1.resonance_frequency = lerp(entity1.resonance_frequency, avg_freq, 0.2)
            entity2.resonance_frequency = lerp(entity2.resonance_frequency, avg_freq, 0.2)
            
        "collaboration":
            # Small chance to trigger evolution if consciousness high enough
            if entity1.consciousness_level > 0.7 and entity2.consciousness_level > 0.7:
                if randf() < 0.1: # 10% chance
                    if entity1.evolution_stage < EVOLUTION_STAGES:
                        _evolve_entity(entity_id1)
                    
                    if entity2.evolution_stage < EVOLUTION_STAGES:
                        _evolve_entity(entity_id2)
            
        "teaching":
            # Higher evolved entity teaches lower one
            if entity1.evolution_stage > entity2.evolution_stage:
                entity2.consciousness_level += 0.03
                entity2.consciousness_level = min(entity2.consciousness_level, 1.0)
            elif entity2.evolution_stage > entity1.evolution_stage:
                entity1.consciousness_level += 0.03
                entity1.consciousness_level = min(entity1.consciousness_level, 1.0)
    
    # Record interaction
    entity_interactions.append({
        "entity1": entity_id1,
        "entity2": entity_id2,
        "type": interaction_type,
        "timestamp": OS.get_unix_time()
    })
    
    # Emit signal
    emit_signal("entities_interacted", entity_id1, entity_id2, interaction_type, {
        "consciousness_change1": entity1.consciousness_level,
        "consciousness_change2": entity2.consciousness_level
    })

# Check for entity evolution
func _check_entity_evolution(delta):
    for entity_id in entities:
        var entity = entities[entity_id]
        
        # Skip fully evolved entities
        if entity.evolution_stage >= EVOLUTION_STAGES:
            continue
        
        # Check evolution conditions
        if entity.consciousness_level >= CONSCIOUSNESS_THRESHOLD:
            # Base evolution chance
            var evolution_chance = 0.02 * delta
            
            # Higher chance the closer to max consciousness
            evolution_chance *= (entity.consciousness_level / CONSCIOUSNESS_THRESHOLD)
            
            # Lower chance for higher evolution stages
            evolution_chance /= (1.0 + (entity.evolution_stage * 0.3))
            
            # Random roll
            if randf() < evolution_chance:
                _evolve_entity(entity_id)
                
                # Check for type transition
                _check_type_transition(entity_id)

# Update dimensional presence statistics
func _update_dimension_presence():
    # Reset dimension stats
    for dim in dimension_presence:
        dimension_presence[dim].entities.clear()
        dimension_presence[dim].total_consciousness = 0.0
    
    # Count entities in each dimension
    for entity_id in entities:
        var entity = entities[entity_id]
        var dim = entity.dimension
        
        if dimension_presence.has(dim):
            dimension_presence[dim].entities.append(entity_id)
            dimension_presence[dim].total_consciousness += entity.consciousness_level
    
    # Calculate averages and determine dominant types
    for dim in dimension_presence:
        var dim_data = dimension_presence[dim]
        
        if dim_data.entities.size() > 0:
            dim_data.average_consciousness = dim_data.total_consciousness / dim_data.entities.size()
            
            # Count entity types in this dimension
            var type_counts = {}
            for entity_id in dim_data.entities:
                var type = entities[entity_id].type
                if not type_counts.has(type):
                    type_counts[type] = 0
                type_counts[type] += 1
            
            # Find dominant type
            var max_count = 0
            var dominant_type = ""
            for type in type_counts:
                if type_counts[type] > max_count:
                    max_count = type_counts[type]
                    dominant_type = type
            
            dim_data.dominant_entity_type = dominant_type
        else:
            dim_data.average_consciousness = 0.0
            dim_data.dominant_entity_type = ""

# Check for color attunement
func _check_color_attunement(delta):
    for entity_id in entities:
        var entity = entities[entity_id]
        
        # Skip entities that are already fully attuned
        if entity.color_attunement_stage >= COLOR_ATTUNEMENT_STAGES:
            continue
        
        # Check for dimensional resonance
        if dimension_presence.has(entity.dimension):
            var dim_data = dimension_presence[entity.dimension]
            
            # Entity needs to be at or above average consciousness
            if entity.consciousness_level >= dim_data.average_consciousness:
                # Check if entity's resonance frequency is close to dimension's
                var freq_diff = abs(entity.resonance_frequency - dim_data.resonance_frequency)
                var relative_diff = freq_diff / dim_data.resonance_frequency
                
                if relative_diff < 0.1: # Within 10% of dimension frequency
                    # Attunement chance
                    var attunement_chance = 0.05 * delta
                    
                    # Increase chance based on consciousness
                    attunement_chance *= entity.consciousness_level
                    
                    # Random roll
                    if randf() < attunement_chance:
                        _attune_entity_color(entity_id)

# Get compatibility between entity types (higher = more compatible)
func _get_type_compatibility(type1, type2):
    # Define compatibility matrix
    var compatibility = {
        "elemental": {
            "elemental": 1.0,
            "guardian": 0.7,
            "messenger": 0.6,
            "weaver": 0.8,
            "architect": 0.5,
            "connector": 0.7,
            "interpreter": 0.4,
            "harmonizer": 0.6,
            "observer": 0.3,
            "creator": 0.5,
            "ascended": 0.9,
            "source": 1.0
        },
        "guardian": {
            "elemental": 0.7,
            "guardian": 1.0,
            "messenger": 0.8,
            "weaver": 0.5,
            "architect": 0.9,
            "connector": 0.6,
            "interpreter": 0.5,
            "harmonizer": 0.4,
            "observer": 0.7,
            "creator": 0.6,
            "ascended": 0.9,
            "source": 1.0
        },
        "messenger": {
            "elemental": 0.6,
            "guardian": 0.8,
            "messenger": 1.0,
            "weaver": 0.7,
            "architect": 0.6,
            "connector": 0.9,
            "interpreter": 0.8,
            "harmonizer": 0.7,
            "observer": 0.5,
            "creator": 0.4,
            "ascended": 0.9,
            "source": 1.0
        },
        "weaver": {
            "elemental": 0.8,
            "guardian": 0.5,
            "messenger": 0.7,
            "weaver": 1.0,
            "architect": 0.8,
            "connector": 0.7,
            "interpreter": 0.6,
            "harmonizer": 0.9,
            "observer": 0.4,
            "creator": 0.8,
            "ascended": 0.9,
            "source": 1.0
        },
        "architect": {
            "elemental": 0.5,
            "guardian": 0.9,
            "messenger": 0.6,
            "weaver": 0.8,
            "architect": 1.0,
            "connector": 0.5,
            "interpreter": 0.7,
            "harmonizer": 0.6,
            "observer": 0.8,
            "creator": 0.9,
            "ascended": 0.9,
            "source": 1.0
        },
        "connector": {
            "elemental": 0.7,
            "guardian": 0.6,
            "messenger": 0.9,
            "weaver": 0.7,
            "architect": 0.5,
            "connector": 1.0,
            "interpreter": 0.9,
            "harmonizer": 0.8,
            "observer": 0.6,
            "creator": 0.5,
            "ascended": 0.9,
            "source": 1.0
        },
        "interpreter": {
            "elemental": 0.4,
            "guardian": 0.5,
            "messenger": 0.8,
            "weaver": 0.6,
            "architect": 0.7,
            "connector": 0.9,
            "interpreter": 1.0,
            "harmonizer": 0.7,
            "observer": 0.9,
            "creator": 0.6,
            "ascended": 0.9,
            "source": 1.0
        },
        "harmonizer": {
            "elemental": 0.6,
            "guardian": 0.4,
            "messenger": 0.7,
            "weaver": 0.9,
            "architect": 0.6,
            "connector": 0.8,
            "interpreter": 0.7,
            "harmonizer": 1.0,
            "observer": 0.8,
            "creator": 0.7,
            "ascended": 0.9,
            "source": 1.0
        },
        "observer": {
            "elemental": 0.3,
            "guardian": 0.7,
            "messenger": 0.5,
            "weaver": 0.4,
            "architect": 0.8,
            "connector": 0.6,
            "interpreter": 0.9,
            "harmonizer": 0.8,
            "observer": 1.0,
            "creator": 0.8,
            "ascended": 0.9,
            "source": 1.0
        },
        "creator": {
            "elemental": 0.5,
            "guardian": 0.6,
            "messenger": 0.4,
            "weaver": 0.8,
            "architect": 0.9,
            "connector": 0.5,
            "interpreter": 0.6,
            "harmonizer": 0.7,
            "observer": 0.8,
            "creator": 1.0,
            "ascended": 0.9,
            "source": 1.0
        },
        "ascended": {
            "elemental": 0.9,
            "guardian": 0.9,
            "messenger": 0.9,
            "weaver": 0.9,
            "architect": 0.9,
            "connector": 0.9,
            "interpreter": 0.9,
            "harmonizer": 0.9,
            "observer": 0.9,
            "creator": 0.9,
            "ascended": 1.0,
            "source": 1.0
        },
        "source": {
            "elemental": 1.0,
            "guardian": 1.0,
            "messenger": 1.0,
            "weaver": 1.0,
            "architect": 1.0,
            "connector": 1.0,
            "interpreter": 1.0,
            "harmonizer": 1.0,
            "observer": 1.0,
            "creator": 1.0,
            "ascended": 1.0,
            "source": 1.0
        }
    }
    
    if compatibility.has(type1) and compatibility[type1].has(type2):
        return compatibility[type1][type2]
    
    return 0.5 # Default moderate compatibility

# Evolve an entity to next stage
func _evolve_entity(entity_id):
    if not entities.has(entity_id):
        return
        
    var entity = entities[entity_id]
    
    if entity.evolution_stage >= EVOLUTION_STAGES:
        return # Already at max evolution
        
    var old_stage = entity.evolution_stage
    entity.evolution_stage += 1
    
    # Update stats tracking
    evolution_stats[old_stage] -= 1
    evolution_stats[entity.evolution_stage] += 1
    
    # Apply evolution effects
    # 1. Increase consciousness slightly
    entity.consciousness_level += 0.05
    entity.consciousness_level = min(entity.consciousness_level, 1.0)
    
    # 2. Adjust resonance frequency
    entity.resonance_frequency *= 1.1
    
    # 3. Possible dimension shift if at certain evolution stages
    if entity.evolution_stage == 3 or entity.evolution_stage == 6 or entity.evolution_stage == 9:
        _check_dimension_shift(entity_id)
    
    # Emit signal
    emit_signal("entity_evolved", entity_id, old_stage, entity.evolution_stage)
    
    print("Entity %s evolved from stage %d to %d" % [entity_id, old_stage, entity.evolution_stage])

# Check if entity should shift to higher dimension
func _check_dimension_shift(entity_id):
    if not entities.has(entity_id):
        return
        
    var entity = entities[entity_id]
    
    # Only shift if consciousness is high enough
    if entity.consciousness_level < 0.8:
        return
        
    # Calculate target dimension based on evolution stage
    var max_target_dim = min(entity.dimension + entity.evolution_stage / 3, 12)
    var target_dim = min(entity.dimension + 1, max_target_dim)
    
    if target_dim <= entity.dimension:
        return # No shift needed
    
    var old_dim = entity.dimension
    entity.dimension = target_dim
    
    # Update dimension presence
    if dimension_presence.has(old_dim):
        dimension_presence[old_dim].entities.erase(entity_id)
    
    if dimension_presence.has(target_dim):
        dimension_presence[target_dim].entities.append(entity_id)
    
    # Emit signal
    emit_signal("entity_dimension_shift", entity_id, old_dim, target_dim)
    
    print("Entity %s shifted from dimension %d to %d" % [entity_id, old_dim, target_dim])

# Awaken an entity
func _awaken_entity(entity_id):
    if not entities.has(entity_id):
        return
        
    var entity = entities[entity_id]
    
    if entity.awakened:
        return # Already awakened
        
    entity.awakened = true
    
    # Apply awakening effects
    # 1. Increase evolution stage if not at max
    if entity.evolution_stage < EVOLUTION_STAGES:
        _evolve_entity(entity_id)
    
    # 2. Create an astral signature
    _create_astral_signature(entity_id)
    
    # 3. Boost consciousness
    entity.consciousness_level += 0.1
    entity.consciousness_level = min(entity.consciousness_level, 1.0)
    
    # Emit signal
    emit_signal("entity_awakened", entity_id, entity.consciousness_level)
    
    print("Entity %s awakened at consciousness level %.2f" % [entity_id, entity.consciousness_level])

# Create an astral signature for an entity
func _create_astral_signature(entity_id):
    if not entities.has(entity_id):
        return
        
    var entity = entities[entity_id]
    
    # Generate a unique signature pattern
    var signature = {
        "resonance_pattern": entity.resonance_frequency,
        "consciousness_imprint": entity.consciousness_level,
        "evolution_encoding": entity.evolution_stage,
        "dimensional_coordinates": entity.dimension,
        "color_spectrum": entity.color_attunement_stage,
        "shape_manifestation": ENTITY_SHAPES[entity.type],
        "creation_timestamp": OS.get_unix_time()
    }
    
    astral_signatures[entity_id] = signature

# Attune entity to next color stage
func _attune_entity_color(entity_id):
    if not entities.has(entity_id):
        return
        
    var entity = entities[entity_id]
    
    if entity.color_attunement_stage >= COLOR_ATTUNEMENT_STAGES:
        return # Already fully attuned
        
    entity.color_attunement_stage += 1
    
    # Get new color
    entity.color = ENTITY_COLORS[entity.color_attunement_stage]
    
    # Apply attunement effects
    # 1. Consciousness boost
    entity.consciousness_level += 0.03
    entity.consciousness_level = min(entity.consciousness_level, 1.0)
    
    # 2. Resonance frequency adjustment
    entity.resonance_frequency = dimension_presence[entity.dimension].resonance_frequency * 
                               (0.95 + (0.1 * randf()))
    
    # Emit signal
    emit_signal("entity_color_attuned", entity_id, entity.color_attunement_stage)
    
    print("Entity %s attuned to color stage %d" % [entity_id, entity.color_attunement_stage])

# Check if entity should transition to a new type
func _check_type_transition(entity_id):
    if not entities.has(entity_id):
        return
        
    var entity = entities[entity_id]
    
    # Only check at certain evolution stages
    if entity.evolution_stage != 3 and entity.evolution_stage != 6 and entity.evolution_stage != 9:
        return
        
    # Type transitions based on evolution stage and dimension
    var possible_transitions = {}
    
    if entity.evolution_stage == 3:
        # First tier transition
        possible_transitions = {
            "elemental": ["weaver", "connector"],
            "guardian": ["architect", "observer"],
            "messenger": ["interpreter", "connector"],
            "weaver": ["harmonizer", "creator"],
            "connector": ["interpreter", "harmonizer"]
        }
    elif entity.evolution_stage == 6:
        # Second tier transition
        possible_transitions = {
            "weaver": ["creator", "harmonizer"],
            "architect": ["creator", "observer"],
            "connector": ["harmonizer", "interpreter"],
            "interpreter": ["observer", "ascended"],
            "harmonizer": ["creator", "ascended"],
            "observer": ["interpreter", "ascended"],
            "creator": ["harmonizer", "ascended"]
        }
    elif entity.evolution_stage == 9:
        # Final tier - ascension
        possible_transitions = {
            "weaver": ["ascended"],
            "architect": ["ascended"],
            "connector": ["ascended"],
            "interpreter": ["ascended"],
            "harmonizer": ["ascended"],
            "observer": ["ascended"],
            "creator": ["ascended"],
            "ascended": ["source"]
        }
    
    # Check if current type can transition
    if possible_transitions.has(entity.type):
        var options = possible_transitions[entity.type]
        
        # Need high consciousness for transition
        if entity.consciousness_level >= 0.8:
            var new_type = options[randi() % options.size()]
            
            _transition_entity_type(entity_id, new_type)

# Transition entity to a new type
func _transition_entity_type(entity_id, new_type):
    if not entities.has(entity_id):
        return
        
    var entity = entities[entity_id]
    
    var old_type = entity.type
    
    # Update type counts
    entity_types[old_type] -= 1
    entity_types[new_type] += 1
    
    # Update entity
    entity.type = new_type
    entity.shape = ENTITY_SHAPES[new_type]
    
    # Special case for ascension
    if new_type == "ascended" or new_type == "source":
        entity.consciousness_level = 1.0
        
        # For source entities, move to highest dimension
        if new_type == "source":
            var old_dim = entity.dimension
            entity.dimension = 12
            
            emit_signal("entity_dimension_shift", entity_id, old_dim, 12)
    
    # Emit signal
    emit_signal("entity_ascended", entity_id, new_type)
    
    print("Entity %s transitioned from %s to %s" % [entity_id, old_type, new_type])

# PUBLIC API: Create a new entity
func create_entity(type, dimension = 1):
    # Check max entities
    if entities.size() >= MAX_ENTITIES:
        push_error("Maximum entity limit reached")
        return null
    
    # Validate type
    if not ENTITY_SHAPES.has(type):
        push_error("Invalid entity type: " + type)
        return null
    
    # Validate dimension
    if dimension < 1 or dimension > 12:
        push_error("Invalid dimension: " + str(dimension))
        return null
    
    # Generate unique ID
    var entity_id = "entity_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
    
    # Create entity
    var entity = {
        "id": entity_id,
        "type": type,
        "shape": ENTITY_SHAPES[type],
        "dimension": dimension,
        "evolution_stage": 1,
        "consciousness_level": 0.3 + (randf() * 0.2), # Start between 0.3 and 0.5
        "color_attunement_stage": 1,
        "color": ENTITY_COLORS[1],
        "awakened": false,
        "resonance_frequency": 432.0 + (randf() * 50.0), # Base frequency with random variation
        "creation_time": OS.get_unix_time()
    }
    
    # Store entity
    entities[entity_id] = entity
    
    # Update stats
    entity_types[type] += 1
    evolution_stats[1] += 1
    
    # Update dimension presence
    if dimension_presence.has(dimension):
        dimension_presence[dimension].entities.append(entity_id)
    
    # Emit signal
    emit_signal("entity_created", entity_id, type, {
        "dimension": dimension,
        "consciousness_level": entity.consciousness_level
    })
    
    print("Created entity %s of type %s in dimension %d" % [entity_id, type, dimension])
    
    return entity_id

# PUBLIC API: Get entity by ID
func get_entity(entity_id):
    if entities.has(entity_id):
        return entities[entity_id]
    return null

# PUBLIC API: Get all entities
func get_all_entities():
    return entities

# PUBLIC API: Get entities by type
func get_entities_by_type(type):
    var result = []
    
    for entity_id in entities:
        if entities[entity_id].type == type:
            result.append(entity_id)
    
    return result

# PUBLIC API: Get entities by dimension
func get_entities_by_dimension(dimension):
    if dimension_presence.has(dimension):
        return dimension_presence[dimension].entities
    return []

# PUBLIC API: Get entity count by dimension
func get_entity_count_by_dimension():
    var counts = {}
    
    for dim in dimension_presence:
        counts[dim] = dimension_presence[dim].entities.size()
    
    return counts

# PUBLIC API: Get entity count by type
func get_entity_count_by_type():
    return entity_types.duplicate()

# PUBLIC API: Get entity count by evolution stage
func get_entity_count_by_evolution():
    return evolution_stats.duplicate()

# PUBLIC API: Get recent entity interactions
func get_recent_interactions(count = 10):
    var result = []
    var start_idx = max(0, entity_interactions.size() - count)
    
    for i in range(start_idx, entity_interactions.size()):
        result.append(entity_interactions[i])
    
    return result

# PUBLIC API: Get astral signature
func get_astral_signature(entity_id):
    if astral_signatures.has(entity_id):
        return astral_signatures[entity_id]
    return null

# PUBLIC API: Force entity evolution
func force_entity_evolution(entity_id):
    if not entities.has(entity_id):
        return false
    
    _evolve_entity(entity_id)
    return true

# PUBLIC API: Force entity dimension shift
func force_dimension_shift(entity_id, target_dimension):
    if not entities.has(entity_id):
        return false
    
    if target_dimension < 1 or target_dimension > 12:
        return false
    
    var entity = entities[entity_id]
    var old_dim = entity.dimension
    
    entity.dimension = target_dimension
    
    # Update dimension presence
    if dimension_presence.has(old_dim):
        dimension_presence[old_dim].entities.erase(entity_id)
    
    if dimension_presence.has(target_dimension):
        dimension_presence[target_dimension].entities.append(entity_id)
    
    # Emit signal
    emit_signal("entity_dimension_shift", entity_id, old_dim, target_dimension)
    
    return true

# PUBLIC API: Purge entities below consciousness threshold
func purge_low_consciousness_entities(threshold = 0.3):
    var purged_entities = []
    var entities_to_remove = []
    
    for entity_id in entities:
        var entity = entities[entity_id]
        
        if entity.consciousness_level < threshold:
            entities_to_remove.append(entity_id)
            purged_entities.append({
                "id": entity_id,
                "type": entity.type,
                "dimension": entity.dimension,
                "consciousness": entity.consciousness_level
            })
    }
    
    # Remove entities
    for entity_id in entities_to_remove:
        var entity = entities[entity_id]
        
        # Update stats
        entity_types[entity.type] -= 1
        evolution_stats[entity.evolution_stage] -= 1
        
        # Update dimension presence
        if dimension_presence.has(entity.dimension):
            dimension_presence[entity.dimension].entities.erase(entity_id)
        
        # Remove entity
        entities.erase(entity_id)
        
        # Remove astral signature if exists
        if astral_signatures.has(entity_id):
            astral_signatures.erase(entity_id)
    }
    
    return purged_entities