extends Node
class_name MemoryPoolEvolution

"""
Memory Pool Evolution System
---------------------------
A unified system for evolutionary memory manipulation across multiple data sources,
story zones, and temporal states (past, present, and future potential).

This system creates a unified entrance to all memory pools simultaneously,
allowing for parallel processing, cross-source pattern recognition, and
evolutionary progression of narrative elements and NPC behaviors.

Features:
- Multi-source memory pool synchronization
- Evolutionary tracking of story elements across time
- NPC behavior monitoring with causal analysis
- Zone-based memory organization with cross-zone intelligence
- Temporal analysis connecting past and current data streams
- Predictive memory synthesis for anticipatory processing
"""

# Signal declarations
signal memory_evolution_detected(evolution_id, source_memories, result_memory)
signal npc_behavior_changed(npc_id, previous_behavior, current_behavior, reason)
signal story_zones_connected(source_zones, connection_strength)
signal unified_entrance_accessed(timestamp, access_pattern)
signal memory_pool_synchronized(pool_ids, sync_status)
signal evolutionary_threshold_reached(metric_type, current_value, threshold)

# Constants
const MEMORY_SOURCE_TYPES = {
    "PRIMARY": 0,    # Main system memory
    "SECONDARY": 1,  # Extended/device-specific memory
    "TERTIARY": 2,   # Cloud/distributed memory
    "UNIFIED": 3,    # Combined memory layers
    "SHADOW": 4,     # Potential/alternative memory paths
    "META": 5        # Memory about memory patterns
}

const EVOLUTION_STAGES = {
    "SEED": 0,       # Initial memory formation
    "EMERGENCE": 1,  # Pattern development
    "CONNECTION": 2, # Cross-linking with other memories
    "ABSTRACTION": 3,# Conceptual refinement
    "PROPAGATION": 4,# Spread across memory pools
    "MUTATION": 5,   # Transformation into new forms
    "INTEGRATION": 6 # Full system integration
}

const STORY_ZONE_TYPES = {
    "NARRATIVE": 0,  # Story-driven zones
    "SYSTEMIC": 1,   # Process/mechanics zones
    "INTERFACE": 2,  # User interaction zones
    "CONCEPT": 3,    # Abstract concept zones
    "EMOTIONAL": 4,  # Affective/feeling zones
    "CAUSAL": 5,     # Cause-effect relationship zones
    "TEMPORAL": 6    # Time-specific zones
}

const NPC_BEHAVIOR_CATEGORIES = {
    "STATIC": 0,     # Unchanging behaviors
    "REACTIVE": 1,   # Response to stimuli
    "ADAPTIVE": 2,   # Learning from patterns
    "EVOLVING": 3,   # Self-modification over time
    "EMERGENT": 4,   # Unexpected behavioral patterns
    "RESONANT": 5,   # Behavior that echoes across systems
    "TRANSCENDENT": 6# Beyond expected parameters
}

const TEMPORAL_STATES = {
    "PAST_DISTANT": 0,   # Historical/archived
    "PAST_RECENT": 1,    # Recent history
    "PRESENT_ACTIVE": 2, # Current state
    "PRESENT_FORMING": 3,# Actively evolving
    "FUTURE_PROBABLE": 4,# Likely outcomes
    "FUTURE_POTENTIAL": 5,# Possible futures
    "ATEMPORAL": 6      # Outside normal time flow
}

# Configuration
var _config = {
    "multi_source_sync_enabled": true,
    "evolution_threshold": 0.75,  # 0.0-1.0 scale
    "connection_strength_minimum": 0.5,
    "npc_behavior_tracking_level": 3,  # 1-5 scale
    "temporal_analysis_depth": 3,  # How many temporal states to consider
    "zone_boundary_permeability": 0.7,  # How easily memories cross zones
    "unified_entrance_power": 3,  # How many sources can be simultaneously accessed
    "memory_retention_factor": 0.8,  # How strongly memories persist
    "evolution_speed_factor": 1.0,  # Modifier for evolution rate
    "auto_synchronization": true,
    "cross_device_enabled": true,
    "predictive_synthesis_level": 2,  # 1-5 scale
    "combination_ceiling": 6,  # Max number of combined memories
    "debug_logging": false
}

# Runtime variables
var _memory_pools = {}
var _story_zones = {}
var _npc_behaviors = {}
var _temporal_states = {}
var _evolution_tracks = {}
var _active_connections = {}
var _memory_counter = 0
var _evolution_counter = 0
var _zone_counter = 0
var _npc_counter = 0
var _unified_entrance_active = false
var _data_sewer_bridge = null
var _story_data_manager = null
var _hyper_refresh_system = null
var _last_sync_time = 0
var _current_access_pattern = []

# Class definitions
class Memory:
    var id: String
    var content: String
    var source_type: int
    var creation_time: int
    var last_access_time: int
    var access_count: int = 0
    var evolution_stage: int = EVOLUTION_STAGES.SEED
    var connections = []
    var story_zone_id: String = ""
    var temporal_state: int = TEMPORAL_STATES.PRESENT_ACTIVE
    var weight: float = 1.0
    var tags = []
    var metadata = {}
    
    func _init(p_id: String, p_content: String, p_source_type: int):
        id = p_id
        content = p_content
        source_type = p_source_type
        creation_time = OS.get_unix_time()
        last_access_time = creation_time
    
    func access() -> void:
        last_access_time = OS.get_unix_time()
        access_count += 1
    
    func add_connection(memory_id: String) -> void:
        if not connections.has(memory_id):
            connections.append(memory_id)
    
    func add_tag(tag: String) -> void:
        if not tags.has(tag):
            tags.append(tag)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "content": content,
            "source_type": source_type,
            "creation_time": creation_time,
            "last_access_time": last_access_time,
            "access_count": access_count,
            "evolution_stage": evolution_stage,
            "connections": connections,
            "story_zone_id": story_zone_id,
            "temporal_state": temporal_state,
            "weight": weight,
            "tags": tags,
            "metadata": metadata
        }

class StoryZone:
    var id: String
    var name: String
    var type: int
    var memories = []
    var connected_zones = []
    var creation_time: int
    var active: bool = true
    var evolution_level: int = 0
    var boundary_permeability: float = 0.5
    var metadata = {}
    
    func _init(p_id: String, p_name: String, p_type: int):
        id = p_id
        name = p_name
        type = p_type
        creation_time = OS.get_unix_time()
    
    func add_memory(memory_id: String) -> void:
        if not memories.has(memory_id):
            memories.append(memory_id)
    
    func connect_zone(zone_id: String) -> void:
        if not connected_zones.has(zone_id):
            connected_zones.append(zone_id)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
            "type": type,
            "memories": memories,
            "connected_zones": connected_zones,
            "creation_time": creation_time,
            "active": active,
            "evolution_level": evolution_level,
            "boundary_permeability": boundary_permeability,
            "metadata": metadata
        }

class NPCBehavior:
    var id: String
    var npc_id: String
    var behavior_type: int
    var description: String
    var first_observed: int
    var last_observed: int
    var observation_count: int = 1
    var causality = []  # What caused this behavior
    var effects = []    # What this behavior caused
    var evolution_chain = []  # Previous behaviors that led to this
    var stability: float = 0.5  # How consistent this behavior is
    var metadata = {}
    
    func _init(p_id: String, p_npc_id: String, p_behavior_type: int, p_description: String):
        id = p_id
        npc_id = p_npc_id
        behavior_type = p_behavior_type
        description = p_description
        first_observed = OS.get_unix_time()
        last_observed = first_observed
    
    func observe() -> void:
        last_observed = OS.get_unix_time()
        observation_count += 1
        
        # Increase stability with more observations
        stability = min(1.0, stability + 0.05)
    
    func add_cause(cause_id: String) -> void:
        if not causality.has(cause_id):
            causality.append(cause_id)
    
    func add_effect(effect_id: String) -> void:
        if not effects.has(effect_id):
            effects.append(effect_id)
    
    func add_to_evolution(previous_behavior_id: String) -> void:
        if not evolution_chain.has(previous_behavior_id):
            evolution_chain.append(previous_behavior_id)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "npc_id": npc_id,
            "behavior_type": behavior_type,
            "description": description,
            "first_observed": first_observed,
            "last_observed": last_observed,
            "observation_count": observation_count,
            "causality": causality,
            "effects": effects,
            "evolution_chain": evolution_chain,
            "stability": stability,
            "metadata": metadata
        }

class EvolutionTrack:
    var id: String
    var source_memories = []
    var result_memory: String = ""
    var evolution_stage: int
    var creation_time: int
    var completion_time: int = 0
    var evolution_strength: float = 0.0
    var complete: bool = false
    var metadata = {}
    
    func _init(p_id: String, p_sources: Array, p_stage: int):
        id = p_id
        source_memories = p_sources
        evolution_stage = p_stage
        creation_time = OS.get_unix_time()
    
    func complete_evolution(result_id: String, strength: float) -> void:
        result_memory = result_id
        evolution_strength = strength
        completion_time = OS.get_unix_time()
        complete = true
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "source_memories": source_memories,
            "result_memory": result_memory,
            "evolution_stage": evolution_stage,
            "creation_time": creation_time,
            "completion_time": completion_time,
            "evolution_strength": evolution_strength,
            "complete": complete,
            "metadata": metadata
        }

class UnifiedEntrance:
    var active: bool = false
    var access_timestamp: int = 0
    var connected_sources = []
    var current_pattern = []
    var access_strength: float = 0.0
    var metadata = {}
    
    func _init(p_sources: Array = []):
        connected_sources = p_sources
    
    func activate() -> bool:
        active = true
        access_timestamp = OS.get_unix_time()
        return true
    
    func deactivate() -> void:
        active = false
    
    func set_access_pattern(pattern: Array) -> void:
        current_pattern = pattern
    
    func to_dict() -> Dictionary:
        return {
            "active": active,
            "access_timestamp": access_timestamp,
            "connected_sources": connected_sources,
            "current_pattern": current_pattern,
            "access_strength": access_strength,
            "metadata": metadata
        }

# Initialization
func _ready():
    _setup_default_zones()
    _initialize_temporal_states()
    
    _last_sync_time = OS.get_unix_time()
    
    # Create unified entrance
    _unified_entrance_active = false
    _current_access_pattern = []
    
    # Debug message
    if _config.debug_logging:
        print("MemoryPoolEvolution: Initialized with " + str(len(_story_zones)) + " story zones")

# Setup default story zones
func _setup_default_zones():
    # Create default zones
    _create_story_zone("Narrative Core", STORY_ZONE_TYPES.NARRATIVE)
    _create_story_zone("System Mechanics", STORY_ZONE_TYPES.SYSTEMIC)
    _create_story_zone("User Interface", STORY_ZONE_TYPES.INTERFACE)
    _create_story_zone("Conceptual Space", STORY_ZONE_TYPES.CONCEPT)
    _create_story_zone("Emotional Landscape", STORY_ZONE_TYPES.EMOTIONAL)
    _create_story_zone("Causal Network", STORY_ZONE_TYPES.CAUSAL)
    _create_story_zone("Temporal Flow", STORY_ZONE_TYPES.TEMPORAL)

# Initialize temporal states
func _initialize_temporal_states():
    for state in TEMPORAL_STATES.values():
        _temporal_states[state] = []

# Process function for time-dependent functionality
func _process(delta):
    if _config.auto_synchronization:
        _check_for_auto_sync()
    
    if _unified_entrance_active:
        _process_unified_entrance(delta)
    
    # Evolve memories periodically
    _process_memory_evolution(delta)

# Public API Methods

# Set reference to data sewer bridge
func set_data_sewer_bridge(bridge) -> void:
    _data_sewer_bridge = bridge

# Set reference to story data manager
func set_story_data_manager(manager) -> void:
    _story_data_manager = manager

# Set reference to hyper refresh system
func set_hyper_refresh_system(system) -> void:
    _hyper_refresh_system = system

# Create a new memory
func create_memory(content: String, source_type: int, story_zone_id: String = "", temporal_state: int = TEMPORAL_STATES.PRESENT_ACTIVE, tags: Array = []) -> String:
    _memory_counter += 1
    var memory_id = "memory_" + str(_memory_counter)
    
    var memory = Memory.new(memory_id, content, source_type)
    memory.temporal_state = temporal_state
    
    # Add tags
    for tag in tags:
        memory.add_tag(tag)
    
    # If story zone is specified, add to that zone
    if story_zone_id != "" and _story_zones.has(story_zone_id):
        memory.story_zone_id = story_zone_id
        _story_zones[story_zone_id].add_memory(memory_id)
    
    # Add to memory pool
    _memory_pools[memory_id] = memory
    
    # Add to temporal state
    _temporal_states[temporal_state].append(memory_id)
    
    return memory_id

# Create a unified entrance to all memory sources
func create_unified_entrance(sources: Array = [MEMORY_SOURCE_TYPES.PRIMARY, MEMORY_SOURCE_TYPES.SECONDARY, MEMORY_SOURCE_TYPES.TERTIARY]) -> bool:
    # Limit sources to config maximum
    if sources.size() > _config.unified_entrance_power:
        sources = sources.slice(0, _config.unified_entrance_power - 1)
    
    var entrance = UnifiedEntrance.new(sources)
    var success = entrance.activate()
    
    if success:
        _unified_entrance_active = true
        _current_access_pattern = []
        
        emit_signal("unified_entrance_accessed", entrance.access_timestamp, [])
        
        # In a real implementation, this would establish connections to all sources
        if _config.debug_logging:
            print("MemoryPoolEvolution: Unified entrance activated with " + str(sources.size()) + " sources")
    
    return success

# Access a memory
func access_memory(memory_id: String) -> Dictionary:
    if not _memory_pools.has(memory_id):
        return {}
    
    var memory = _memory_pools[memory_id]
    memory.access()
    
    # If this is part of a unified entrance access, record pattern
    if _unified_entrance_active:
        _current_access_pattern.append(memory_id)
        
        # If pattern is getting long, trigger pattern analysis
        if _current_access_pattern.size() >= 3:
            _analyze_access_pattern()
    
    return memory.to_dict()

# Create a new NPC behavior observation
func record_npc_behavior(npc_id: String, behavior_type: int, description: String, causes: Array = []) -> String:
    _npc_counter += 1
    var behavior_id = "behavior_" + str(_npc_counter)
    
    var behavior = NPCBehavior.new(behavior_id, npc_id, behavior_type, description)
    
    # Link causes if provided
    for cause_id in causes:
        behavior.add_cause(cause_id)
    
    # Store the behavior
    if not _npc_behaviors.has(npc_id):
        _npc_behaviors[npc_id] = {}
    
    # Check for behavior changes
    var previous_behavior = null
    var previous_behavior_id = ""
    
    # Find the most recent previous behavior
    var most_recent_time = 0
    for b_id in _npc_behaviors[npc_id]:
        var b = _npc_behaviors[npc_id][b_id]
        if b.last_observed > most_recent_time:
            most_recent_time = b.last_observed
            previous_behavior = b
            previous_behavior_id = b_id
    
    # If we found a previous behavior
    if previous_behavior:
        # Link to evolution chain
        behavior.add_to_evolution(previous_behavior_id)
        
        # Emit signal if behavior type changed
        if previous_behavior.behavior_type != behavior_type:
            emit_signal("npc_behavior_changed", npc_id, previous_behavior_id, behavior_id, "Evolution")
            
            # Create a memory of this behavior change
            var memory_content = "NPC " + npc_id + " behavior changed from " + str(previous_behavior.behavior_type) + " to " + str(behavior_type)
            create_memory(
                memory_content,
                MEMORY_SOURCE_TYPES.PRIMARY,
                "",  # Auto-assign to appropriate zone
                TEMPORAL_STATES.PRESENT_ACTIVE,
                ["npc", "behavior", "change"]
            )
    
    _npc_behaviors[npc_id][behavior_id] = behavior
    
    return behavior_id

# Connect memories through evolutionary process
func evolve_memories(source_memory_ids: Array, evolution_stage: int) -> String:
    if source_memory_ids.size() < 2:
        return ""
    
    # Verify all memories exist
    for memory_id in source_memory_ids:
        if not _memory_pools.has(memory_id):
            return ""
    
    _evolution_counter += 1
    var evolution_id = "evolution_" + str(_evolution_counter)
    
    var evolution = EvolutionTrack.new(evolution_id, source_memory_ids, evolution_stage)
    
    # Start the evolution process
    var result_memory_id = _process_evolution(evolution)
    
    if result_memory_id != "":
        evolution.complete_evolution(result_memory_id, _calculate_evolution_strength(source_memory_ids))
        
        # Connect all source memories to this new evolved memory
        for source_id in source_memory_ids:
            _memory_pools[source_id].add_connection(result_memory_id)
            _memory_pools[result_memory_id].add_connection(source_id)
        
        emit_signal("memory_evolution_detected", evolution_id, source_memory_ids, result_memory_id)
    
    _evolution_tracks[evolution_id] = evolution
    
    return evolution_id

# Create connections between story zones
func connect_story_zones(zone_ids: Array) -> bool:
    if zone_ids.size() < 2:
        return false
    
    # Verify all zones exist
    for zone_id in zone_ids:
        if not _story_zones.has(zone_id):
            return false
    
    # Connect all zones to each other
    for i in range(zone_ids.size()):
        for j in range(i + 1, zone_ids.size()):
            _story_zones[zone_ids[i]].connect_zone(zone_ids[j])
            _story_zones[zone_ids[j]].connect_zone(zone_ids[i])
    
    # Calculate connection strength based on overlapping memories
    var connection_strength = _calculate_zone_connection_strength(zone_ids)
    
    emit_signal("story_zones_connected", zone_ids, connection_strength)
    
    return connection_strength >= _config.connection_strength_minimum

# Get memories from a specific source
func get_memories_from_source(source_type: int) -> Array:
    var result = []
    
    for memory_id in _memory_pools:
        var memory = _memory_pools[memory_id]
        if memory.source_type == source_type:
            result.append(memory.to_dict())
    
    return result

# Get memories from a specific zone
func get_memories_from_zone(zone_id: String) -> Array:
    if not _story_zones.has(zone_id):
        return []
    
    var result = []
    var zone = _story_zones[zone_id]
    
    for memory_id in zone.memories:
        if _memory_pools.has(memory_id):
            result.append(_memory_pools[memory_id].to_dict())
    
    return result

# Get memories from a specific temporal state
func get_memories_from_temporal_state(state: int) -> Array:
    if not _temporal_states.has(state):
        return []
    
    var result = []
    
    for memory_id in _temporal_states[state]:
        if _memory_pools.has(memory_id):
            result.append(_memory_pools[memory_id].to_dict())
    
    return result

# Get NPC behaviors
func get_npc_behaviors(npc_id: String) -> Array:
    if not _npc_behaviors.has(npc_id):
        return []
    
    var result = []
    
    for behavior_id in _npc_behaviors[npc_id]:
        result.append(_npc_behaviors[npc_id][behavior_id].to_dict())
    
    return result

# Synchronize memory pools
func synchronize_memory_pools() -> Dictionary:
    var start_time = OS.get_unix_time()
    
    var pools_synced = []
    var memories_transferred = 0
    var total_memory_count = _memory_pools.size()
    
    # In a real implementation, this would synchronize across devices
    # For now, we simulate the process by marking all pools as synchronized
    
    if _config.cross_device_enabled:
        # Simulate cross-device synchronization
        pools_synced = [
            MEMORY_SOURCE_TYPES.PRIMARY,
            MEMORY_SOURCE_TYPES.SECONDARY,
            MEMORY_SOURCE_TYPES.TERTIARY
        ]
        
        # Simulate transfer of memories between sources
        var memories_by_source = {}
        for source in pools_synced:
            memories_by_source[source] = []
        
        for memory_id in _memory_pools:
            var memory = _memory_pools[memory_id]
            if memory.source_type in pools_synced:
                memories_by_source[memory.source_type].append(memory_id)
        
        # For each memory in each source, ensure it's represented in all other sources
        for source in pools_synced:
            for memory_id in memories_by_source[source]:
                var memory = _memory_pools[memory_id]
                
                # For each other source, create a mirror memory if it doesn't exist
                for target_source in pools_synced:
                    if target_source != source:
                        # In a real implementation, this would actually create the memory in the target source
                        # For now, just increment our transfer counter
                        memories_transferred += 1
    
    _last_sync_time = OS.get_unix_time()
    
    emit_signal("memory_pool_synchronized", pools_synced, true)
    
    return {
        "success": true,
        "pools_synced": pools_synced,
        "memories_transferred": memories_transferred,
        "total_memory_count": total_memory_count,
        "sync_time": _last_sync_time - start_time
    }

# Update configuration
func update_config(new_config: Dictionary) -> bool:
    for key in new_config:
        if _config.has(key):
            _config[key] = new_config[key]
    
    return true

# Internal Implementation Methods

# Create a story zone
func _create_story_zone(name: String, type: int) -> String:
    _zone_counter += 1
    var zone_id = "zone_" + str(_zone_counter)
    
    var zone = StoryZone.new(zone_id, name, type)
    zone.boundary_permeability = _config.zone_boundary_permeability
    
    _story_zones[zone_id] = zone
    
    return zone_id

# Process the evolution of memories to create a new memory
func _process_evolution(evolution: EvolutionTrack) -> String:
    var source_memories = []
    
    # Collect all source memories
    for memory_id in evolution.source_memories:
        if _memory_pools.has(memory_id):
            source_memories.append(_memory_pools[memory_id])
    
    if source_memories.size() < 2:
        return ""
    
    # Combine content from source memories based on evolution stage
    var combined_content = ""
    var metadata = {}
    var tags = []
    var source_type = MEMORY_SOURCE_TYPES.UNIFIED
    
    match evolution.evolution_stage:
        EVOLUTION_STAGES.SEED:
            # Simple combination of early content
            for memory in source_memories:
                if combined_content != "":
                    combined_content += " + "
                combined_content += memory.content.substr(0, min(10, memory.content.length()))
                
                # Collect tags
                for tag in memory.tags:
                    if not tags.has(tag):
                        tags.append(tag)
            
            combined_content = "Seed: " + combined_content
        
        EVOLUTION_STAGES.EMERGENCE:
            # Find common themes
            var common_words = _find_common_words(source_memories)
            combined_content = "Emergence: Pattern detected around " + " ".join(common_words.slice(0, min(5, common_words.size() - 1)))
            
            # Add common tags
            tags = _find_common_tags(source_memories)
        
        EVOLUTION_STAGES.CONNECTION:
            # Create connections between concepts
            combined_content = "Connection: "
            for i in range(source_memories.size()):
                if i > 0:
                    combined_content += " ➜ "
                combined_content += source_memories[i].content.substr(0, min(15, source_memories[i].content.length()))
            
            # Blend tags
            tags = _blend_tags(source_memories)
        
        EVOLUTION_STAGES.ABSTRACTION:
            # Create a higher-level concept
            combined_content = "Abstraction: Concept derived from " + str(source_memories.size()) + " sources"
            
            # Generate common theme
            var common_words = _find_common_words(source_memories)
            if common_words.size() > 0:
                combined_content += " centered on " + " ".join(common_words.slice(0, min(3, common_words.size() - 1)))
            
            # Use most common tags plus "abstract" tag
            tags = _find_common_tags(source_memories)
            tags.append("abstract")
        
        EVOLUTION_STAGES.PROPAGATION:
            # Version for spreading
            combined_content = "Propagation: Spreading concept across memory pools"
            for memory in source_memories:
                combined_content += "\n- " + memory.content.substr(0, min(30, memory.content.length()))
            
            # Add propagation-specific tags
            tags = _blend_tags(source_memories)
            tags.append("propagated")
        
        EVOLUTION_STAGES.MUTATION:
            # Transform into something new
            combined_content = "Mutation: Transformed from original concepts into new form"
            
            # Add mutation-specific metadata
            metadata["mutation_source_count"] = source_memories.size()
            
            # Create variant tags
            tags = _mutate_tags(source_memories)
        
        EVOLUTION_STAGES.INTEGRATION:
            # Full system integration
            combined_content = "Integration: Complete synthesis of " + str(source_memories.size()) + " concepts"
            combined_content += "\nResult is a unified understanding that transcends individual components"
            
            # Use all source metadata
            for memory in source_memories:
                for key in memory.metadata:
                    if not metadata.has(key):
                        metadata[key] = memory.metadata[key]
            
            # Unified tags
            tags = ["integrated", "unified", "synthesis"]
            for memory in source_memories:
                for tag in memory.tags:
                    if not tags.has(tag):
                        tags.append(tag)
    
    # Create the new evolved memory
    var memory_id = create_memory(
        combined_content,
        source_type,
        "",  # Will be assigned automatically
        TEMPORAL_STATES.PRESENT_FORMING,
        tags
    )
    
    # Apply metadata
    if _memory_pools.has(memory_id):
        _memory_pools[memory_id].metadata = metadata
        
        # Set evolution stage
        _memory_pools[memory_id].evolution_stage = evolution.evolution_stage
        
        # Calculate and apply weight based on source memories
        var total_weight = 0.0
        for memory in source_memories:
            total_weight += memory.weight
        
        _memory_pools[memory_id].weight = total_weight / source_memories.size() * (1.0 + evolution.evolution_stage * 0.1)
    
    # Assign to appropriate story zone based on evolution stage
    _assign_memory_to_best_zone(memory_id)
    
    return memory_id

# Find best story zone for a memory
func _assign_memory_to_best_zone(memory_id: String) -> bool:
    if not _memory_pools.has(memory_id):
        return false
    
    var memory = _memory_pools[memory_id]
    
    # If already assigned, nothing to do
    if memory.story_zone_id != "" and _story_zones.has(memory.story_zone_id):
        return true
    
    # Determine best zone based on content and tags
    var best_zone_id = ""
    var best_score = 0.0
    
    for zone_id in _story_zones:
        var zone = _story_zones[zone_id]
        var score = 0.0
        
        # Score based on zone type and memory content
        match zone.type:
            STORY_ZONE_TYPES.NARRATIVE:
                if memory.content.find("story") >= 0 or memory.content.find("narrative") >= 0:
                    score += 5.0
                for tag in memory.tags:
                    if tag in ["story", "narrative", "plot", "character"]:
                        score += 2.0
            
            STORY_ZONE_TYPES.SYSTEMIC:
                if memory.content.find("system") >= 0 or memory.content.find("process") >= 0:
                    score += 5.0
                for tag in memory.tags:
                    if tag in ["system", "process", "mechanic"]:
                        score += 2.0
            
            STORY_ZONE_TYPES.INTERFACE:
                if memory.content.find("interface") >= 0 or memory.content.find("user") >= 0:
                    score += 5.0
                for tag in memory.tags:
                    if tag in ["interface", "ui", "user"]:
                        score += 2.0
            
            STORY_ZONE_TYPES.CONCEPT:
                if memory.content.find("concept") >= 0 or memory.content.find("idea") >= 0:
                    score += 5.0
                if memory.evolution_stage >= EVOLUTION_STAGES.ABSTRACTION:
                    score += 5.0
                for tag in memory.tags:
                    if tag in ["concept", "idea", "abstract"]:
                        score += 2.0
            
            STORY_ZONE_TYPES.EMOTIONAL:
                if memory.content.find("feel") >= 0 or memory.content.find("emotion") >= 0:
                    score += 5.0
                for tag in memory.tags:
                    if tag in ["emotion", "feeling", "mood"]:
                        score += 2.0
            
            STORY_ZONE_TYPES.CAUSAL:
                if memory.content.find("cause") >= 0 or memory.content.find("effect") >= 0:
                    score += 5.0
                for tag in memory.tags:
                    if tag in ["cause", "effect", "reason"]:
                        score += 2.0
            
            STORY_ZONE_TYPES.TEMPORAL:
                if memory.content.find("time") >= 0 or memory.content.find("temporal") >= 0:
                    score += 5.0
                if memory.temporal_state != TEMPORAL_STATES.PRESENT_ACTIVE:
                    score += 3.0
                for tag in memory.tags:
                    if tag in ["time", "temporal", "past", "present", "future"]:
                        score += 2.0
        
        # Additional score for evolution stage matching
        if memory.evolution_stage == EVOLUTION_STAGES.INTEGRATION and zone.type == STORY_ZONE_TYPES.CONCEPT:
            score += 3.0
        if memory.evolution_stage == EVOLUTION_STAGES.PROPAGATION and zone.type == STORY_ZONE_TYPES.NARRATIVE:
            score += 3.0
        
        # If best score, update
        if score > best_score:
            best_score = score
            best_zone_id = zone_id
    
    # Default to narrative zone if no good match
    if best_zone_id == "":
        for zone_id in _story_zones:
            if _story_zones[zone_id].type == STORY_ZONE_TYPES.NARRATIVE:
                best_zone_id = zone_id
                break
    
    # If we found a zone, assign the memory
    if best_zone_id != "":
        memory.story_zone_id = best_zone_id
        _story_zones[best_zone_id].add_memory(memory_id)
        return true
    
    return false

# Calculate the strength of an evolution based on source memories
func _calculate_evolution_strength(memory_ids: Array) -> float:
    var total_weight = 0.0
    var average_age = 0.0
    var connection_factor = 0.0
    
    var memories = []
    for memory_id in memory_ids:
        if _memory_pools.has(memory_id):
            memories.append(_memory_pools[memory_id])
    
    if memories.size() == 0:
        return 0.0
    
    # Calculate total weight
    for memory in memories:
        total_weight += memory.weight
    
    # Calculate average age
    var now = OS.get_unix_time()
    for memory in memories:
        average_age += (now - memory.creation_time)
    average_age /= memories.size()
    
    # Age factor - newer memories are stronger
    var age_factor = clamp(1.0 - (average_age / (86400.0 * 30.0)), 0.1, 1.0)  # Scale based on 30 days
    
    # Connection factor - more cross-connected memories are stronger
    var connection_count = 0
    for i in range(memories.size()):
        for j in range(i + 1, memories.size()):
            if memories[i].connections.has(memories[j].id):
                connection_count += 1
    
    var max_connections = (memories.size() * (memories.size() - 1)) / 2
    connection_factor = max_connections > 0 ? float(connection_count) / max_connections : 0.0
    
    # Source factor - memories from different sources are stronger
    var sources = {}
    for memory in memories:
        sources[memory.source_type] = true
    
    var source_factor = clamp(float(sources.size()) / 3.0, 0.3, 1.0)
    
    # Combine factors
    var strength = (total_weight / memories.size()) * age_factor * (1.0 + connection_factor) * source_factor
    
    return clamp(strength, 0.0, 1.0)

# Calculate the connection strength between story zones
func _calculate_zone_connection_strength(zone_ids: Array) -> float:
    if zone_ids.size() < 2:
        return 0.0
    
    var zones = []
    for zone_id in zone_ids:
        if _story_zones.has(zone_id):
            zones.append(_story_zones[zone_id])
    
    if zones.size() < 2:
        return 0.0
    
    # Count shared memories
    var memories_by_zone = {}
    for zone in zones:
        memories_by_zone[zone.id] = zone.memories
    
    var shared_memories = []
    var memory_counts = {}
    
    # Count occurrences of each memory
    for zone_id in memories_by_zone:
        for memory_id in memories_by_zone[zone_id]:
            if not memory_counts.has(memory_id):
                memory_counts[memory_id] = 0
            memory_counts[memory_id] += 1
    
    # Find memories that appear in multiple zones
    for memory_id in memory_counts:
        if memory_counts[memory_id] > 1:
            shared_memories.append(memory_id)
    
    # Calculate strength based on shared memories
    var total_memories = 0
    for zone in zones:
        total_memories += zone.memories.size()
    
    var connection_strength = total_memories > 0 ? float(shared_memories.size()) / total_memories : 0.0
    
    # Apply permeability modifier
    var avg_permeability = 0.0
    for zone in zones:
        avg_permeability += zone.boundary_permeability
    avg_permeability /= zones.size()
    
    connection_strength *= avg_permeability
    
    return clamp(connection_strength, 0.0, 1.0)

# Check if it's time for auto-synchronization
func _check_for_auto_sync() -> void:
    var current_time = OS.get_unix_time()
    var elapsed_time = current_time - _last_sync_time
    
    if elapsed_time > 300:  # 5 minutes
        synchronize_memory_pools()

# Process unified entrance access patterns
func _process_unified_entrance(delta: float) -> void:
    # In a real implementation, this would handle data flow between sources
    if _current_access_pattern.size() > 0:
        # For now, just simulate the effect
        pass

# Analyze access patterns for interesting sequences
func _analyze_access_pattern() -> void:
    if _current_access_pattern.size() < 3:
        return
    
    # Look for patterns like:
    # - Same source types in sequence
    # - Cross-source transitions
    # - Temporal shifts
    
    var pattern_detected = false
    var pattern_description = ""
    
    # Check source patterns
    var source_sequence = []
    for memory_id in _current_access_pattern:
        if _memory_pools.has(memory_id):
            source_sequence.append(_memory_pools[memory_id].source_type)
    
    # Check for alternating sources
    var alternating = true
    for i in range(2, source_sequence.size()):
        if source_sequence[i] != source_sequence[i - 2]:
            alternating = false
            break
    
    if alternating and source_sequence.size() >= 4:
        pattern_detected = true
        pattern_description = "Alternating source access pattern detected"
    
    # Check for sequential temporal states
    var temporal_sequence = []
    for memory_id in _current_access_pattern:
        if _memory_pools.has(memory_id):
            temporal_sequence.append(_memory_pools[memory_id].temporal_state)
    
    var sequential = true
    for i in range(1, temporal_sequence.size()):
        if abs(temporal_sequence[i] - temporal_sequence[i - 1]) != 1:
            sequential = false
            break
    
    if sequential and temporal_sequence.size() >= 3:
        pattern_detected = true
        pattern_description = "Sequential temporal state traversal detected"
    
    # If pattern detected, create memory of it
    if pattern_detected:
        var memory_id = create_memory(
            pattern_description,
            MEMORY_SOURCE_TYPES.META,
            "",  # Auto-assign
            TEMPORAL_STATES.PRESENT_ACTIVE,
            ["pattern", "access", "unified"]
        )
        
        # Link to all memories in the pattern
        for pattern_memory_id in _current_access_pattern:
            if _memory_pools.has(memory_id) and _memory_pools.has(pattern_memory_id):
                _memory_pools[memory_id].add_connection(pattern_memory_id)
                _memory_pools[pattern_memory_id].add_connection(memory_id)
        
        # Reset pattern after processing
        _current_access_pattern = []
        
        # Trigger evolution if the connection is strong
        emit_signal("unified_entrance_accessed", OS.get_unix_time(), [pattern_description])

# Process memory evolution based on time
func _process_memory_evolution(delta: float) -> void:
    # Apply evolution speed factor
    var evolution_chance = delta * 0.01 * _config.evolution_speed_factor
    
    # Only occasionally check for evolution to avoid performance issues
    if randf() > evolution_chance:
        return
    
    # Look for memories that could be evolved together
    var memory_sets = _find_potential_memory_sets()
    
    for memory_set in memory_sets:
        # Skip if too few memories
        if memory_set.size() < 2:
            continue
        
        # Determine evolution stage based on existing states
        var avg_stage = 0
        for memory_id in memory_set:
            if _memory_pools.has(memory_id):
                avg_stage += _memory_pools[memory_id].evolution_stage
        
        avg_stage = int(avg_stage / memory_set.size())
        
        # Move to next stage
        var next_stage = min(avg_stage + 1, EVOLUTION_STAGES.INTEGRATION)
        
        # Don't evolve too many sets at once
        if randf() <= 0.3:  # 30% chance to actually evolve
            evolve_memories(memory_set, next_stage)

# Find potential memory sets for evolution
func _find_potential_memory_sets() -> Array:
    var all_sets = []
    
    # Prioritize memories from different sources
    var multi_source_sets = _find_multi_source_memory_sets()
    if multi_source_sets.size() > 0:
        all_sets += multi_source_sets
    
    # Find connected memories
    var connected_sets = _find_connected_memory_sets()
    if connected_sets.size() > 0:
        all_sets += connected_sets
    
    # Find memories with similar tags
    var similar_tag_sets = _find_tag_similar_memory_sets()
    if similar_tag_sets.size() > 0:
        all_sets += similar_tag_sets
    
    return all_sets

# Find memory sets from multiple sources
func _find_multi_source_memory_sets() -> Array:
    var results = []
    
    # Group memories by source
    var memories_by_source = {}
    for memory_id in _memory_pools:
        var memory = _memory_pools[memory_id]
        if not memories_by_source.has(memory.source_type):
            memories_by_source[memory.source_type] = []
        memories_by_source[memory.source_type].append(memory_id)
    
    # Need at least 2 sources with memories
    if memories_by_source.size() < 2:
        return results
    
    # Create sets with memories from each available source
    var set_size = min(_config.combination_ceiling, 5)  # Max 5 memories per set
    var source_types = memories_by_source.keys()
    
    # Try to create up to 3 multi-source sets
    for i in range(min(3, memories_by_source.size())):
        var memory_set = []
        
        # Pick a memory from each source, up to set size
        for j in range(min(set_size, source_types.size())):
            var source = source_types[j]
            var memories = memories_by_source[source]
            
            if memories.size() > 0:
                var random_index = randi() % memories.size()
                memory_set.append(memories[random_index])
        
        if memory_set.size() >= 2:
            results.append(memory_set)
    
    return results

# Find sets of connected memories
func _find_connected_memory_sets() -> Array:
    var results = []
    
    # Find pairs with mutual connections
    var connected_pairs = []
    for memory1_id in _memory_pools:
        var memory1 = _memory_pools[memory1_id]
        
        for connection_id in memory1.connections:
            if _memory_pools.has(connection_id):
                var memory2 = _memory_pools[connection_id]
                
                if memory2.connections.has(memory1_id):
                    connected_pairs.append([memory1_id, connection_id])
    
    # Group connected pairs into larger sets
    for pair in connected_pairs:
        var added_to_existing = false
        
        # Try to add to existing sets
        for existing_set in results:
            if existing_set.has(pair[0]) or existing_set.has(pair[1]):
                # Add both to this set
                if not existing_set.has(pair[0]):
                    existing_set.append(pair[0])
                if not existing_set.has(pair[1]):
                    existing_set.append(pair[1])
                
                added_to_existing = true
                break
        
        # If not added to any existing set, create new set
        if not added_to_existing:
            results.append([pair[0], pair[1]])
    
    # Limit sets to combination ceiling
    for i in range(results.size()):
        if results[i].size() > _config.combination_ceiling:
            results[i] = results[i].slice(0, _config.combination_ceiling - 1)
    
    return results

# Find memory sets with similar tags
func _find_tag_similar_memory_sets() -> Array:
    var results = []
    
    # Group memories by tags
    var memories_by_tag = {}
    for memory_id in _memory_pools:
        var memory = _memory_pools[memory_id]
        
        for tag in memory.tags:
            if not memories_by_tag.has(tag):
                memories_by_tag[tag] = []
            memories_by_tag[tag].append(memory_id)
    
    # Create sets of memories sharing the same tags
    for tag in memories_by_tag:
        var memories = memories_by_tag[tag]
        
        if memories.size() >= 2:
            # Create up to 2 sets per tag
            for i in range(min(2, int(memories.size() / 2))):
                var set_size = min(_config.combination_ceiling, memories.size())
                var memory_set = []
                
                # Pick random memories
                var shuffled = memories.duplicate()
                _shuffle_array(shuffled)
                
                for j in range(set_size):
                    memory_set.append(shuffled[j])
                
                results.append(memory_set)
    
    return results

# Find common words between memories
func _find_common_words(memories: Array) -> Array:
    var word_counts = {}
    
    for memory in memories:
        var words = memory.content.split(" ", false)
        
        for word in words:
            var clean_word = word.strip_edges().to_lower()
            if clean_word.length() < 3:  # Skip very short words
                continue
                
            if not word_counts.has(clean_word):
                word_counts[clean_word] = 0
            word_counts[clean_word] += 1
    
    # Find words that appear in multiple memories
    var common_words = []
    for word in word_counts:
        if word_counts[word] > 1:
            common_words.append(word)
    
    # Sort by frequency
    common_words.sort_custom(self, "_sort_by_frequency")
    
    return common_words

# Find common tags between memories
func _find_common_tags(memories: Array) -> Array:
    var tag_counts = {}
    
    for memory in memories:
        for tag in memory.tags:
            if not tag_counts.has(tag):
                tag_counts[tag] = 0
            tag_counts[tag] += 1
    
    # Find tags that appear in multiple memories
    var common_tags = []
    for tag in tag_counts:
        if tag_counts[tag] > 1:
            common_tags.append(tag)
    
    return common_tags

# Blend tags from multiple memories
func _blend_tags(memories: Array) -> Array:
    var all_tags = []
    
    for memory in memories:
        for tag in memory.tags:
            if not all_tags.has(tag):
                all_tags.append(tag)
    
    # Limit to 8 tags
    if all_tags.size() > 8:
        all_tags = all_tags.slice(0, 7)
    
    return all_tags

# Create mutated tags
func _mutate_tags(memories: Array) -> Array:
    var source_tags = []
    
    # Collect all source tags
    for memory in memories:
        for tag in memory.tags:
            if not source_tags.has(tag):
                source_tags.append(tag)
    
    # Create mutated tags
    var mutated_tags = ["mutated"]
    
    for tag in source_tags:
        # 50% chance to include original tag
        if randf() > 0.5:
            mutated_tags.append(tag)
        
        # 30% chance to include a modified version
        if randf() > 0.7:
            mutated_tags.append(tag + "_evolved")
    
    # Add a random new tag
    var possible_new_tags = ["transformed", "evolved", "advanced", "meta", "complex"]
    var random_tag = possible_new_tags[randi() % possible_new_tags.size()]
    
    if not mutated_tags.has(random_tag):
        mutated_tags.append(random_tag)
    
    return mutated_tags

# Sort helpers
func _sort_by_frequency(a, b) -> bool:
    return a[1] > b[1]

# Utility to shuffle an array
func _shuffle_array(arr: Array) -> void:
    for i in range(arr.size() - 1, 0, -1):
        var j = randi() % (i + 1)
        var temp = arr[i]
        arr[i] = arr[j]
        arr[j] = temp

# Example usage:
# var memory_evolution = MemoryPoolEvolution.new()
# add_child(memory_evolution)
# 
# # Connect to data sewer bridge
# var data_bridge = DataSewerBridge.new()
# add_child(data_bridge)
# memory_evolution.set_data_sewer_bridge(data_bridge)
# 
# # Connect to story data manager
# var story_manager = StoryDataManager.new()
# add_child(story_manager)
# memory_evolution.set_story_data_manager(story_manager)
# 
# # Create unified entrance to all memories
# memory_evolution.create_unified_entrance()
# 
# # Create memories in different sources
# var memory1 = memory_evolution.create_memory(
#     "The old castle stands on the hill, watching over the town",
#     MemoryPoolEvolution.MEMORY_SOURCE_TYPES.PRIMARY,
#     "",
#     MemoryPoolEvolution.TEMPORAL_STATES.PAST_RECENT,
#     ["castle", "location", "landmark"]
# )
# 
# var memory2 = memory_evolution.create_memory(
#     "The townspeople gather every year to celebrate the castle's founding",
#     MemoryPoolEvolution.MEMORY_SOURCE_TYPES.SECONDARY,
#     "",
#     MemoryPoolEvolution.TEMPORAL_STATES.PRESENT_ACTIVE,
#     ["celebration", "town", "tradition"]
# )
# 
# var memory3 = memory_evolution.create_memory(
#     "The castle will be renovated next spring to become a museum",
#     MemoryPoolEvolution.MEMORY_SOURCE_TYPES.TERTIARY,
#     "",
#     MemoryPoolEvolution.TEMPORAL_STATES.FUTURE_PROBABLE,
#     ["castle", "renovation", "museum"]
# )
# 
# # Evolve the memories together
# var evolution_id = memory_evolution.evolve_memories(
#     [memory1, memory2, memory3],
#     MemoryPoolEvolution.EVOLUTION_STAGES.CONNECTION
# )
# 
# # Synchronize memory pools across sources
# memory_evolution.synchronize_memory_pools()