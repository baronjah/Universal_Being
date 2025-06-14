extends Node
class_name EdenGardenSystem

"""
Eden Garden System
-----------------
A holistic ecosystem for nurturing and developing ideas, concepts, and data
through natural growth patterns inspired by garden cultivation.

This system connects human and digital realms through echo hatches, phase-based
growth cycles, and harmonious energy management, enabling seamless transitions
between online and offline states while preserving memory continuity.

Features:
- Echo hatches for bidirectional idea transmission
- Fruit cultivation for concept maturation
- Garden craft system for structured creation
- Phase-based turn planning with to-do integration
- Comprehensive token/energy physics system
- Offline-mode human synchronization
- Eden connectivity for cross-dimensional access
- Dynamic data display with flexible token rendering
"""

# Signal declarations
signal echo_hatched(hatch_id, content, source_type)
signal fruit_ripened(fruit_id, maturity_level, nutrients)
signal garden_phase_changed(old_phase, new_phase, reason)
signal craft_created(craft_id, materials_used, complexity)
signal token_physics_updated(physics_model, energy_level)
signal eden_memory_stored(memory_id, memory_type, retention_factor)
signal offline_sync_completed(sync_id, duration, success_rate)
signal button_interaction_processed(button_id, action, result)

# Constants
const ECHO_SOURCE_TYPES = {
    "HUMAN": 0,      # Direct human input
    "GARDEN": 1,     # Garden-generated echo
    "MEMORY": 2,     # Echo from memory system
    "HYBRID": 3,     # Combined human-garden echo
    "QUANTUM": 4,    # Quantum probability echo
    "COMMAND": 5     # System command echo
}

const FRUIT_TYPES = {
    "CONCEPT": 0,    # Conceptual fruit
    "NARRATIVE": 1,  # Story-based fruit
    "SYSTEM": 2,     # System/mechanical fruit
    "VISUAL": 3,     # Visual/design fruit
    "TACTILE": 4,    # Sensory/experiential fruit
    "HYBRID": 5      # Multi-domain fruit
}

const GARDEN_PHASES = {
    "SEEDING": 0,     # Initial ideas planting
    "GERMINATION": 1, # Early growth
    "GROWTH": 2,      # Active development
    "BUDDING": 3,     # Form taking shape
    "FLOWERING": 4,   # Expression/flourishing
    "FRUITING": 5,    # Producing output
    "HARVESTING": 6,  # Collecting results
    "COMPOSTING": 7   # Recycling/transforming
}

const CRAFT_CATEGORIES = {
    "TOOL": 0,        # Functional tool
    "CONTAINER": 1,   # Storage/organization
    "PATHWAY": 2,     # Connecting element
    "SHELTER": 3,     # Protective structure
    "ORNAMENT": 4,    # Decorative element
    "ENERGY": 5,      # Power-generating
    "HYBRID": 6       # Multi-purpose
}

const TOKEN_PHYSICS_MODELS = {
    "FLUID": 0,       # Continuous flow model
    "QUANTUM": 1,     # Probabilistic model
    "CRYSTALLINE": 2, # Structured grid model
    "NETWORK": 3,     # Connection-based model
    "WAVE": 4,        # Oscillation-based model
    "FIELD": 5,       # Field theory model
    "HYBRID": 6       # Combined physics model
}

const EDEN_MEMORY_TYPES = {
    "EPISODIC": 0,    # Event-based memory
    "SEMANTIC": 1,    # Factual knowledge
    "PROCEDURAL": 2,  # Process/skill memory
    "EMOTIONAL": 3,   # Feeling-based memory
    "SENSORY": 4,     # Perception-based memory
    "COLLECTIVE": 5,  # Shared/group memory
    "QUANTUM": 6      # State-independent memory
}

const SYNC_MODES = {
    "ONLINE": 0,      # Fully connected
    "OFFLINE": 1,     # Fully disconnected
    "HYBRID": 2,      # Partial connection
    "TRANSITIONING": 3, # Moving between states
    "QUANTUM": 4      # Superposition state
}

const BUTTON_TYPES = {
    "ACTION": 0,      # Performs direct action
    "TOGGLE": 1,      # On/off state
    "CYCLE": 2,       # Cycles through options
    "COMMAND": 3,     # Issues system command
    "CONNECT": 4,     # Establishes connection
    "EMERGENT": 5     # Context-dependent
}

# Configuration
var _config = {
    "default_garden_phase": GARDEN_PHASES.SEEDING,
    "auto_phase_progression": true,
    "phase_duration_hours": 3.0,
    "fruit_maturation_rate": 0.05,  # Per hour
    "echo_retention_factor": 0.85,  # How well echoes persist
    "max_concurrent_fruits": 12,
    "craft_complexity_limit": 5,   # 1-10 scale
    "token_display_minimum": 4,    # Minimum tokens to display
    "token_display_maximum": 678,  # Maximum tokens to display
    "offline_sync_frequency": 24.0, # Hours
    "energy_regeneration_rate": 0.1, # Per hour
    "enable_ctrl_connections": true,
    "use_hash_commands": true,
    "button_responsiveness": 0.9,  # 0-1 scale
    "echo_hatch_sensitivity": 0.7, # 0-1 scale
    "debug_logging": false
}

# Runtime variables
var _echo_hatches = {}
var _fruits = {}
var _crafts = {}
var _garden_plots = {}
var _active_memory_echoes = {}
var _token_physics_state = {}
var _garden_resources = {}
var _current_phase = GARDEN_PHASES.SEEDING
var _phase_start_time = 0
var _sync_status = SYNC_MODES.ONLINE
var _last_sync_time = 0
var _energy_level = 1.0
var _active_buttons = {}
var _command_history = []
var _planning_todos = {}
var _data_sewer_bridge = null
var _memory_pool_evolution = null
var _quantum_wish_system = null
var _story_data_manager = null
var _echo_counter = 0
var _fruit_counter = 0
var _craft_counter = 0
var _button_counter = 0
var _todo_counter = 0
var _current_physics_model = TOKEN_PHYSICS_MODELS.FLUID

# Class definitions
class EchoHatch:
    var id: String
    var source_type: int
    var content: String
    var creation_time: int
    var last_echo_time: int
    var echo_count: int = 0
    var connected_hatches = []
    var is_command: bool = false
    var command_type: String = ""
    var hatch_strength: float = 1.0
    var is_ctrl_activated: bool = false
    var metadata = {}
    
    func _init(p_id: String, p_source_type: int, p_content: String):
        id = p_id
        source_type = p_source_type
        content = p_content
        creation_time = OS.get_unix_time()
        last_echo_time = creation_time
        
        # Check if this is a command echo
        if content.begins_with("#"):
            is_command = true
            command_type = "refresh"
        elif content.begins_with("!"):
            is_command = true
            command_type = "action"
        
        # Check for ctrl activation
        if content.find("ctrl") >= 0 or content.find("Ctrl") >= 0:
            is_ctrl_activated = true
    
    func echo() -> void:
        last_echo_time = OS.get_unix_time()
        echo_count += 1
    
    func connect_hatch(hatch_id: String) -> void:
        if not connected_hatches.has(hatch_id):
            connected_hatches.append(hatch_id)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "source_type": source_type,
            "content": content,
            "creation_time": creation_time,
            "last_echo_time": last_echo_time,
            "echo_count": echo_count,
            "connected_hatches": connected_hatches,
            "is_command": is_command,
            "command_type": command_type,
            "hatch_strength": hatch_strength,
            "is_ctrl_activated": is_ctrl_activated,
            "metadata": metadata
        }

class Fruit:
    var id: String
    var type: int
    var name: String
    var seed_content: String
    var planting_time: int
    var maturity: float = 0.0  # 0-1 scale
    var nutrients = {}
    var growth_factors = []
    var dependencies = []
    var ripened: bool = false
    var harvested: bool = false
    var harvest_time: int = 0
    var metadata = {}
    
    func _init(p_id: String, p_type: int, p_name: String, p_seed_content: String):
        id = p_id
        type = p_type
        name = p_name
        seed_content = p_seed_content
        planting_time = OS.get_unix_time()
    
    func add_nutrient(nutrient_type: String, amount: float) -> void:
        if not nutrients.has(nutrient_type):
            nutrients[nutrient_type] = 0.0
        nutrients[nutrient_type] += amount
    
    func add_growth_factor(factor: String) -> void:
        if not growth_factors.has(factor):
            growth_factors.append(factor)
    
    func add_dependency(fruit_id: String) -> void:
        if not dependencies.has(fruit_id):
            dependencies.append(fruit_id)
    
    func mature(amount: float) -> float:
        var previous = maturity
        maturity = clamp(maturity + amount, 0.0, 1.0)
        
        # Check if fruit has ripened
        if maturity >= 1.0 and not ripened:
            ripened = true
        
        return maturity - previous
    
    func harvest() -> bool:
        if ripened and not harvested:
            harvested = true
            harvest_time = OS.get_unix_time()
            return true
        return false
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "type": type,
            "name": name,
            "seed_content": seed_content,
            "planting_time": planting_time,
            "maturity": maturity,
            "nutrients": nutrients,
            "growth_factors": growth_factors,
            "dependencies": dependencies,
            "ripened": ripened,
            "harvested": harvested,
            "harvest_time": harvest_time,
            "metadata": metadata
        }

class GardenCraft:
    var id: String
    var category: int
    var name: String
    var description: String
    var creation_time: int
    var materials = []
    var complexity: int = 1
    var functionality = []
    var creator_type: String
    var energy_requirement: float = 0.0
    var durability: float = 1.0
    var metadata = {}
    
    func _init(p_id: String, p_category: int, p_name: String, p_description: String):
        id = p_id
        category = p_category
        name = p_name
        description = p_description
        creation_time = OS.get_unix_time()
        creator_type = "human"  # Default
    
    func add_material(material: String) -> void:
        if not materials.has(material):
            materials.append(material)
    
    func add_functionality(function: String) -> void:
        if not functionality.has(function):
            functionality.append(function)
    
    func set_creator(creator: String) -> void:
        creator_type = creator
    
    func use() -> bool:
        # Reduce durability slightly with use
        durability = max(0.0, durability - 0.01)
        return durability > 0.0
    
    func repair(amount: float) -> float:
        var previous = durability
        durability = clamp(durability + amount, 0.0, 1.0)
        return durability - previous
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "category": category,
            "name": name,
            "description": description,
            "creation_time": creation_time,
            "materials": materials,
            "complexity": complexity,
            "functionality": functionality,
            "creator_type": creator_type,
            "energy_requirement": energy_requirement,
            "durability": durability,
            "metadata": metadata
        }

class GardenPlot:
    var id: String
    var size: Vector2
    var planted_fruits = []
    var fertility: float = 1.0
    var water_level: float = 0.5
    var sunlight: float = 0.5
    var obstacles = []
    var connected_plots = []
    var special_properties = {}
    var current_phase: int
    var metadata = {}
    
    func _init(p_id: String, p_size: Vector2, p_phase: int):
        id = p_id
        size = p_size
        current_phase = p_phase
    
    func plant_fruit(fruit_id: String) -> bool:
        if planted_fruits.size() < size.x * size.y:
            if not planted_fruits.has(fruit_id):
                planted_fruits.append(fruit_id)
            return true
        return false
    
    func add_special_property(property_name: String, value) -> void:
        special_properties[property_name] = value
    
    func connect_plot(plot_id: String) -> void:
        if not connected_plots.has(plot_id):
            connected_plots.append(plot_id)
    
    func update_resources(water_change: float, sunlight_change: float) -> void:
        water_level = clamp(water_level + water_change, 0.0, 1.0)
        sunlight = clamp(sunlight + sunlight_change, 0.0, 1.0)
    
    func calculate_growth_rate() -> float:
        return fertility * (0.5 * water_level + 0.5 * sunlight)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "size": {"x": size.x, "y": size.y},
            "planted_fruits": planted_fruits,
            "fertility": fertility,
            "water_level": water_level,
            "sunlight": sunlight,
            "obstacles": obstacles,
            "connected_plots": connected_plots,
            "special_properties": special_properties,
            "current_phase": current_phase,
            "metadata": metadata
        }

class EdenMemory:
    var id: String
    var type: int
    var content: String
    var creation_time: int
    var last_access_time: int
    var access_count: int = 0
    var retention_factor: float = 0.8
    var associations = []
    var emotional_valence: float = 0.0
    var is_ctrl_associated: bool = false
    var clarity: float = 1.0
    var metadata = {}
    
    func _init(p_id: String, p_type: int, p_content: String):
        id = p_id
        type = p_type
        content = p_content
        creation_time = OS.get_unix_time()
        last_access_time = creation_time
    
    func access() -> void:
        last_access_time = OS.get_unix_time()
        access_count += 1
    
    func add_association(memory_id: String) -> void:
        if not associations.has(memory_id):
            associations.append(memory_id)
    
    func set_ctrl_association(value: bool) -> void:
        is_ctrl_associated = value
    
    func decay(amount: float) -> float:
        var previous = clarity
        clarity = max(0.0, clarity - amount * (1.0 - retention_factor))
        return previous - clarity
    
    func refresh() -> float:
        var previous = clarity
        clarity = min(1.0, clarity + 0.2)
        return clarity - previous
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "type": type,
            "content": content,
            "creation_time": creation_time,
            "last_access_time": last_access_time,
            "access_count": access_count,
            "retention_factor": retention_factor,
            "associations": associations,
            "emotional_valence": emotional_valence,
            "is_ctrl_associated": is_ctrl_associated,
            "clarity": clarity,
            "metadata": metadata
        }

class TokenPhysics:
    var model: int
    var state: Dictionary
    var energy_capacity: float = 1.0
    var current_energy: float = 1.0
    var token_count: int = 0
    var display_count: int = 4
    var velocity: Vector2 = Vector2(0, 0)
    var acceleration: Vector2 = Vector2(0, 0)
    var field_strength: float = 1.0
    var last_update_time: int
    var metadata = {}
    
    func _init(p_model: int):
        model = p_model
        last_update_time = OS.get_unix_time()
        
        # Initialize state based on model
        _initialize_state()
    
    func _initialize_state() -> void:
        state = {}
        
        match model:
            TOKEN_PHYSICS_MODELS.FLUID:
                state = {
                    "viscosity": 0.6,
                    "flow_rate": 0.3,
                    "direction": Vector2(1, 0),
                    "turbulence": 0.1
                }
            
            TOKEN_PHYSICS_MODELS.QUANTUM:
                state = {
                    "superposition": 0.5,
                    "entanglement": 0.3,
                    "coherence": 0.7,
                    "uncertainty": 0.4
                }
            
            TOKEN_PHYSICS_MODELS.CRYSTALLINE:
                state = {
                    "lattice_density": 0.8,
                    "symmetry": 0.9,
                    "rigidity": 0.7,
                    "conductivity": 0.5
                }
            
            TOKEN_PHYSICS_MODELS.NETWORK:
                state = {
                    "node_count": 16,
                    "connection_density": 0.4,
                    "transmission_speed": 0.7,
                    "redundancy": 0.5
                }
            
            TOKEN_PHYSICS_MODELS.WAVE:
                state = {
                    "frequency": 0.3,
                    "amplitude": 0.5,
                    "phase": 0.0,
                    "interference": 0.2
                }
            
            TOKEN_PHYSICS_MODELS.FIELD:
                state = {
                    "potential": 0.6,
                    "gradient": 0.3,
                    "polarity": 1.0,
                    "stability": 0.8
                }
            
            TOKEN_PHYSICS_MODELS.HYBRID:
                state = {
                    "primary_model": TOKEN_PHYSICS_MODELS.FLUID,
                    "secondary_model": TOKEN_PHYSICS_MODELS.WAVE,
                    "blend_factor": 0.5,
                    "adaptation_rate": 0.3
                }
    
    func update(delta_time: float) -> void:
        last_update_time = OS.get_unix_time()
        
        # Update model-specific physics
        match model:
            TOKEN_PHYSICS_MODELS.FLUID:
                _update_fluid(delta_time)
            
            TOKEN_PHYSICS_MODELS.QUANTUM:
                _update_quantum(delta_time)
            
            TOKEN_PHYSICS_MODELS.CRYSTALLINE:
                _update_crystalline(delta_time)
            
            TOKEN_PHYSICS_MODELS.NETWORK:
                _update_network(delta_time)
            
            TOKEN_PHYSICS_MODELS.WAVE:
                _update_wave(delta_time)
            
            TOKEN_PHYSICS_MODELS.FIELD:
                _update_field(delta_time)
            
            TOKEN_PHYSICS_MODELS.HYBRID:
                _update_hybrid(delta_time)
    
    func _update_fluid(delta_time: float) -> void:
        # Update fluid dynamics
        var flow = delta_time * state.flow_rate
        velocity = state.direction * flow * (1.0 + randf() * state.turbulence)
        
        # Apply viscosity as damping
        velocity *= (1.0 - state.viscosity * delta_time)
    
    func _update_quantum(delta_time: float) -> void:
        # Quantum fluctuations
        if randf() < state.uncertainty * delta_time:
            state.superposition = clamp(state.superposition + (randf() * 0.4 - 0.2), 0.0, 1.0)
        
        # Entanglement effects
        if state.entanglement > 0.5:
            token_count = int(token_count * (1.0 + delta_time * (state.entanglement - 0.5)))
        
        # Coherence decay
        state.coherence = max(0.0, state.coherence - delta_time * 0.05)
    
    func _update_crystalline(delta_time: float) -> void:
        # Crystalline structure changes slowly
        if randf() < 0.1 * delta_time:
            state.lattice_density = clamp(state.lattice_density + (randf() * 0.2 - 0.1), 0.1, 1.0)
        
        # Energy flows based on conductivity
        var energy_flow = delta_time * state.conductivity
        current_energy = clamp(current_energy * (1.0 - energy_flow) + energy_capacity * energy_flow, 0.0, energy_capacity)
    
    func _update_network(delta_time: float) -> void:
        # Network reconfiguration
        if randf() < 0.2 * delta_time:
            state.connection_density = clamp(state.connection_density + (randf() * 0.2 - 0.1), 0.1, 0.9)
        
        # Information transmission
        var info_transfer = delta_time * state.transmission_speed
        token_count = int(token_count * (1.0 + info_transfer * 0.1))
    
    func _update_wave(delta_time: float) -> void:
        # Wave propagation
        state.phase += state.frequency * delta_time * 2.0 * PI
        state.phase = fmod(state.phase, 2.0 * PI)
        
        # Calculate current amplitude
        var current_amplitude = state.amplitude * sin(state.phase)
        
        # Apply to token display
        display_count = int(max(4, token_count * (1.0 + current_amplitude * 0.3)))
    
    func _update_field(delta_time: float) -> void:
        # Field fluctuations
        if randf() < 0.15 * delta_time:
            state.potential = clamp(state.potential + (randf() * 0.2 - 0.1), 0.1, 1.0)
        
        # Field affects energy
        var energy_change = delta_time * state.gradient * state.polarity
        current_energy = clamp(current_energy + energy_change, 0.0, energy_capacity)
    
    func _update_hybrid(delta_time: float) -> void:
        # Blend between primary and secondary models
        var blend = state.blend_factor
        
        # Create temporary physics models for both components
        var primary = TokenPhysics.new(state.primary_model)
        var secondary = TokenPhysics.new(state.secondary_model)
        
        # Update both
        primary.token_count = token_count
        secondary.token_count = token_count
        primary.update(delta_time)
        secondary.update(delta_time)
        
        # Blend results
        token_count = int(primary.token_count * (1.0 - blend) + secondary.token_count * blend)
        
        # Adaptation
        if randf() < state.adaptation_rate * delta_time:
            state.blend_factor = clamp(state.blend_factor + (randf() * 0.2 - 0.1), 0.1, 0.9)
    
    func apply_energy(amount: float) -> float:
        var previous = current_energy
        current_energy = clamp(current_energy + amount, 0.0, energy_capacity)
        return current_energy - previous
    
    func set_token_count(count: int) -> void:
        token_count = max(0, count)
        update_display_count()
    
    func update_display_count() -> int:
        # Calculate display count based on physics model
        match model:
            TOKEN_PHYSICS_MODELS.FLUID:
                display_count = int(max(4, token_count * state.flow_rate))
            
            TOKEN_PHYSICS_MODELS.QUANTUM:
                display_count = int(max(4, token_count * state.superposition))
            
            TOKEN_PHYSICS_MODELS.CRYSTALLINE:
                display_count = int(max(4, token_count * state.lattice_density))
            
            TOKEN_PHYSICS_MODELS.NETWORK:
                display_count = int(max(4, token_count * state.connection_density))
            
            TOKEN_PHYSICS_MODELS.WAVE:
                display_count = int(max(4, token_count * (0.5 + 0.5 * sin(state.phase))))
            
            TOKEN_PHYSICS_MODELS.FIELD:
                display_count = int(max(4, token_count * state.potential))
            
            TOKEN_PHYSICS_MODELS.HYBRID:
                display_count = int(max(4, token_count * state.blend_factor))
            
            _:
                display_count = max(4, token_count)
        
        return display_count
    
    func to_dict() -> Dictionary:
        return {
            "model": model,
            "state": state,
            "energy_capacity": energy_capacity,
            "current_energy": current_energy,
            "token_count": token_count,
            "display_count": display_count,
            "velocity": {"x": velocity.x, "y": velocity.y},
            "acceleration": {"x": acceleration.x, "y": acceleration.y},
            "field_strength": field_strength,
            "last_update_time": last_update_time,
            "metadata": metadata
        }

class Button:
    var id: String
    var type: int
    var label: String
    var action: String
    var state: bool = false
    var position: Vector2
    var size: Vector2
    var color: Color
    var creation_time: int
    var press_count: int = 0
    var last_press_time: int = 0
    var responsiveness: float = 1.0
    var connected_buttons = []
    var metadata = {}
    
    func _init(p_id: String, p_type: int, p_label: String, p_action: String):
        id = p_id
        type = p_type
        label = p_label
        action = p_action
        creation_time = OS.get_unix_time()
        
        # Default appearance
        position = Vector2(0, 0)
        size = Vector2(100, 50)
        color = Color(0.5, 0.5, 0.5)
    
    func press() -> bool:
        press_count += 1
        last_press_time = OS.get_unix_time()
        
        # For toggle buttons, switch state
        if type == BUTTON_TYPES.TOGGLE:
            state = !state
        
        # Return success based on responsiveness
        return randf() <= responsiveness
    
    func connect_button(button_id: String) -> void:
        if not connected_buttons.has(button_id):
            connected_buttons.append(button_id)
    
    func set_appearance(pos: Vector2, sz: Vector2, col: Color) -> void:
        position = pos
        size = sz
        color = col
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "type": type,
            "label": label,
            "action": action,
            "state": state,
            "position": {"x": position.x, "y": position.y},
            "size": {"width": size.x, "height": size.y},
            "color": {"r": color.r, "g": color.g, "b": color.b, "a": color.a},
            "creation_time": creation_time,
            "press_count": press_count,
            "last_press_time": last_press_time,
            "responsiveness": responsiveness,
            "connected_buttons": connected_buttons,
            "metadata": metadata
        }

class PhaseTodo:
    var id: String
    var title: String
    var description: String
    var phase: int
    var state: String = "pending"  # pending, in_progress, completed, cancelled
    var priority: int = 2  # 1-5 scale
    var creation_time: int
    var completion_time: int = 0
    var dependencies = []
    var assigned_to: String = ""
    var energy_cost: float = 0.1
    var metadata = {}
    
    func _init(p_id: String, p_title: String, p_description: String, p_phase: int):
        id = p_id
        title = p_title
        description = p_description
        phase = p_phase
        creation_time = OS.get_unix_time()
    
    func start() -> void:
        state = "in_progress"
    
    func complete() -> void:
        state = "completed"
        completion_time = OS.get_unix_time()
    
    func cancel() -> void:
        state = "cancelled"
        completion_time = OS.get_unix_time()
    
    func add_dependency(todo_id: String) -> void:
        if not dependencies.has(todo_id):
            dependencies.append(todo_id)
    
    func assign(assignee: String) -> void:
        assigned_to = assignee
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "title": title,
            "description": description,
            "phase": phase,
            "state": state,
            "priority": priority,
            "creation_time": creation_time,
            "completion_time": completion_time,
            "dependencies": dependencies,
            "assigned_to": assigned_to,
            "energy_cost": energy_cost,
            "metadata": metadata
        }

# Initialization
func _ready():
    _phase_start_time = OS.get_unix_time()
    
    # Initialize default garden plot
    _create_garden_plot(Vector2(3, 3), _current_phase)
    
    # Initialize token physics
    _token_physics_state = TokenPhysics.new(_current_physics_model)
    _token_physics_state.set_token_count(100)
    
    # Initialize button for Ctrl
    if _config.enable_ctrl_connections:
        _create_button(BUTTON_TYPES.CONNECT, "Ctrl", "connect")
    
    # Setup default garden resources
    _garden_resources = {
        "water": 1.0,
        "nutrients": 1.0,
        "sunlight": 1.0,
        "seeds": 10,
        "tools": 5,
        "energy": 1.0
    }
    
    # Create initial echo hatch
    _create_echo_hatch(ECHO_SOURCE_TYPES.GARDEN, "Welcome to the Eden Garden System")
    
    if _config.debug_logging:
        print("EdenGardenSystem: Initialized at phase " + _get_phase_name(_current_phase))

# Process function for time-dependent functionality
func _process(delta):
    # Update garden
    _update_garden(delta)
    
    # Update token physics
    if _token_physics_state:
        _token_physics_state.update(delta)
    
    # Check for phase progression
    if _config.auto_phase_progression:
        _check_phase_progression()
    
    # Update energy level
    _update_energy(delta)
    
    # Check for offline sync
    _check_offline_sync()

# Public API Methods

# Set reference to other systems
func set_data_sewer_bridge(bridge) -> void:
    _data_sewer_bridge = bridge

func set_memory_pool_evolution(pool) -> void:
    _memory_pool_evolution = pool

func set_quantum_wish_system(system) -> void:
    _quantum_wish_system = system

func set_story_data_manager(manager) -> void:
    _story_data_manager = manager

# Create new echo hatch
func create_echo(content: String, source_type: int = ECHO_SOURCE_TYPES.HUMAN) -> String:
    var hatch_id = _create_echo_hatch(source_type, content)
    
    # If this is a command echo, process it
    var hatch = _echo_hatches[hatch_id]
    if hatch.is_command:
        _process_command_echo(hatch)
    
    # Special handling for Ctrl-related echo
    if hatch.is_ctrl_activated:
        _handle_ctrl_activation(hatch)
    
    return hatch_id

# Plant a new fruit
func plant_fruit(name: String, type: int, seed_content: String) -> String:
    _fruit_counter += 1
    var fruit_id = "fruit_" + str(_fruit_counter)
    
    var fruit = Fruit.new(fruit_id, type, name, seed_content)
    
    # Add initial nutrients
    fruit.add_nutrient("energy", 0.3)
    fruit.add_nutrient("data", 0.2)
    fruit.add_nutrient("memory", 0.2)
    
    # Store the fruit
    _fruits[fruit_id] = fruit
    
    # Plant in an available garden plot
    for plot_id in _garden_plots:
        var plot = _garden_plots[plot_id]
        if plot.plant_fruit(fruit_id):
            break
    
    # Consume gardening resources
    _garden_resources.seeds = max(0, _garden_resources.seeds - 1)
    _garden_resources.water = max(0, _garden_resources.water - 0.1)
    
    return fruit_id

# Create garden craft
func create_craft(name: String, category: int, description: String, materials: Array = []) -> String:
    _craft_counter += 1
    var craft_id = "craft_" + str(_craft_counter)
    
    var craft = GardenCraft.new(craft_id, category, name, description)
    
    # Add materials
    for material in materials:
        craft.add_material(material)
    
    # Set complexity based on materials and description
    craft.complexity = min(10, 1 + materials.size() + int(description.length() / 20))
    
    # Calculate energy requirement
    craft.energy_requirement = 0.1 * craft.complexity
    
    # Store the craft
    _crafts[craft_id] = craft
    
    # Consume energy
    _energy_level = max(0.0, _energy_level - craft.energy_requirement)
    
    # Emit signal
    emit_signal("craft_created", craft_id, materials, craft.complexity)
    
    return craft_id

# Store Eden memory
func store_memory(content: String, type: int = EDEN_MEMORY_TYPES.EPISODIC) -> String:
    var memory_id = "memory_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
    
    var memory = EdenMemory.new(memory_id, type, content)
    memory.retention_factor = _config.echo_retention_factor
    
    # Check for Ctrl association
    if content.find("ctrl") >= 0 or content.find("Ctrl") >= 0:
        memory.set_ctrl_association(true)
    
    # Store the memory
    _active_memory_echoes[memory_id] = memory
    
    # Set emotional valence based on content keywords
    memory.emotional_valence = _calculate_emotional_valence(content)
    
    # Emit signal
    emit_signal("eden_memory_stored", memory_id, type, memory.retention_factor)
    
    return memory_id

# Create phase-based to-do
func create_todo(title: String, description: String, phase: int = -1) -> String:
    if phase < 0:
        phase = _current_phase
    
    _todo_counter += 1
    var todo_id = "todo_" + str(_todo_counter)
    
    var todo = PhaseTodo.new(todo_id, title, description, phase)
    
    # Add to planning todos
    if not _planning_todos.has(phase):
        _planning_todos[phase] = {}
    
    _planning_todos[phase][todo_id] = todo
    
    return todo_id

# Start to-do
func start_todo(todo_id: String) -> bool:
    # Find todo in all phases
    for phase in _planning_todos:
        if _planning_todos[phase].has(todo_id):
            _planning_todos[phase][todo_id].start()
            return true
    
    return false

# Complete to-do
func complete_todo(todo_id: String) -> bool:
    # Find todo in all phases
    for phase in _planning_todos:
        if _planning_todos[phase].has(todo_id):
            _planning_todos[phase][todo_id].complete()
            
            # Apply energy cost
            _energy_level = max(0.0, _energy_level - _planning_todos[phase][todo_id].energy_cost)
            
            return true
    
    return false

# Press button
func press_button(button_id: String) -> Dictionary:
    if not _active_buttons.has(button_id):
        return {"success": false, "action": "", "result": "Button not found"}
    
    var button = _active_buttons[button_id]
    var success = button.press()
    
    var result = ""
    if success:
        result = _execute_button_action(button)
    else:
        result = "Button not responsive"
    
    # Emit signal
    emit_signal("button_interaction_processed", button_id, button.action, result)
    
    return {
        "success": success,
        "action": button.action,
        "result": result
    }

# Change garden phase
func change_phase(new_phase: int) -> bool:
    if new_phase < 0 or new_phase >= GARDEN_PHASES.size():
        return false
    
    var old_phase = _current_phase
    _current_phase = new_phase
    _phase_start_time = OS.get_unix_time()
    
    # Update all garden plots to new phase
    for plot_id in _garden_plots:
        _garden_plots[plot_id].current_phase = new_phase
    
    # Emit signal
    emit_signal("garden_phase_changed", old_phase, new_phase, "Manual change")
    
    return true

# Harvest ripened fruit
func harvest_fruit(fruit_id: String) -> bool:
    if not _fruits.has(fruit_id):
        return false
    
    var fruit = _fruits[fruit_id]
    if not fruit.ripened:
        return false
    
    var success = fruit.harvest()
    
    if success:
        # Add new echo based on fruit
        var echo_content = "Harvested " + fruit.name + " fruit with " + str(int(fruit.maturity * 100)) + "% maturity"
        create_echo(echo_content, ECHO_SOURCE_TYPES.GARDEN)
        
        # Create memory of the harvest
        if fruit.maturity > 0.7:
            store_memory("Successfully harvested " + fruit.name + " fruit", EDEN_MEMORY_TYPES.EPISODIC)
            
            # Create story if story manager available
            if _story_data_manager:
                _story_data_manager.create_story(
                    "Fruit Harvest: " + fruit.name,
                    _story_data_manager.STORY_TYPES.NARRATIVE,
                    "A fruit was harvested from the Eden Garden with excellent maturity.",
                    [],
                    {"fruit_id": fruit_id, "maturity": fruit.maturity},
                    ["eden", "garden", "harvest", "fruit"]
                )
    }
    
    return success

# Get garden phase info
func get_phase_info() -> Dictionary:
    var todos_in_phase = 0
    var completed_todos = 0
    
    if _planning_todos.has(_current_phase):
        for todo_id in _planning_todos[_current_phase]:
            todos_in_phase += 1
            if _planning_todos[_current_phase][todo_id].state == "completed":
                completed_todos += 1
    
    return {
        "phase": _current_phase,
        "name": _get_phase_name(_current_phase),
        "start_time": _phase_start_time,
        "elapsed_time": OS.get_unix_time() - _phase_start_time,
        "todos_count": todos_in_phase,
        "completed_todos": completed_todos,
        "next_phase": (_current_phase + 1) % GARDEN_PHASES.size(),
        "next_phase_name": _get_phase_name((_current_phase + 1) % GARDEN_PHASES.size())
    }

# Get token display info
func get_token_display_info() -> Dictionary:
    if not _token_physics_state:
        return {}
    
    _token_physics_state.update_display_count()
    
    return {
        "token_count": _token_physics_state.token_count,
        "display_count": _token_physics_state.display_count,
        "model": _token_physics_state.model,
        "model_name": _get_physics_model_name(_token_physics_state.model),
        "energy_level": _token_physics_state.current_energy,
        "min_display": _config.token_display_minimum,
        "max_display": _config.token_display_maximum
    }

# Toggle online/offline mode
func toggle_sync_mode() -> int:
    if _sync_status == SYNC_MODES.ONLINE:
        _sync_status = SYNC_MODES.OFFLINE
        
        # Create memory of going offline
        store_memory("Transitioned to offline mode", EDEN_MEMORY_TYPES.PROCEDURAL)
        
        # Create echo
        create_echo("Entered offline mode. Memory retention set to local.", ECHO_SOURCE_TYPES.SYSTEM)
    else:
        _sync_status = SYNC_MODES.ONLINE
        
        # Perform sync when going online
        _perform_offline_sync()
        
        # Create echo
        create_echo("Reconnected to online mode. Synchronizing memories.", ECHO_SOURCE_TYPES.SYSTEM)
    
    return _sync_status

# Update configuration
func update_config(new_config: Dictionary) -> bool:
    for key in new_config:
        if _config.has(key):
            _config[key] = new_config[key]
    
    return true

# Internal Implementation Methods

# Create echo hatch
func _create_echo_hatch(source_type: int, content: String) -> String:
    _echo_counter += 1
    var hatch_id = "echo_" + str(_echo_counter)
    
    var hatch = EchoHatch.new(hatch_id, source_type, content)
    
    # Set hatch strength based on source
    match source_type:
        ECHO_SOURCE_TYPES.HUMAN:
            hatch.hatch_strength = 1.0
        ECHO_SOURCE_TYPES.GARDEN:
            hatch.hatch_strength = 0.8
        ECHO_SOURCE_TYPES.MEMORY:
            hatch.hatch_strength = 0.6
        ECHO_SOURCE_TYPES.HYBRID:
            hatch.hatch_strength = 0.9
        ECHO_SOURCE_TYPES.QUANTUM:
            hatch.hatch_strength = 0.7
        ECHO_SOURCE_TYPES.COMMAND:
            hatch.hatch_strength = 1.0
    
    # Store the hatch
    _echo_hatches[hatch_id] = hatch
    
    # Emit signal
    emit_signal("echo_hatched", hatch_id, content, source_type)
    
    return hatch_id

# Create garden plot
func _create_garden_plot(size: Vector2, phase: int) -> String:
    var plot_id = "plot_" + str(_garden_plots.size() + 1)
    
    var plot = GardenPlot.new(plot_id, size, phase)
    
    # Initialize with moderate resources
    plot.water_level = 0.5
    plot.sunlight = 0.5
    
    # Add special property based on phase
    match phase:
        GARDEN_PHASES.SEEDING:
            plot.add_special_property("seed_boost", 0.2)
        GARDEN_PHASES.GERMINATION:
            plot.add_special_property("growth_boost", 0.2)
        GARDEN_PHASES.GROWTH:
            plot.add_special_property("nutrient_efficiency", 0.3)
        GARDEN_PHASES.BUDDING:
            plot.add_special_property("structure_quality", 0.4)
        GARDEN_PHASES.FLOWERING:
            plot.add_special_property("beauty_factor", 0.5)
        GARDEN_PHASES.FRUITING:
            plot.add_special_property("yield_multiplier", 0.3)
        GARDEN_PHASES.HARVESTING:
            plot.add_special_property("harvest_efficiency", 0.4)
        GARDEN_PHASES.COMPOSTING:
            plot.add_special_property("renewal_factor", 0.5)
    
    # Store the plot
    _garden_plots[plot_id] = plot
    
    return plot_id

# Create a button
func _create_button(type: int, label: String, action: String) -> String:
    _button_counter += 1
    var button_id = "button_" + str(_button_counter)
    
    var button = Button.new(button_id, type, label, action)
    button.responsiveness = _config.button_responsiveness
    
    # Set appearance based on button type
    match type:
        BUTTON_TYPES.ACTION:
            button.set_appearance(Vector2(50, 50), Vector2(100, 50), Color(0.2, 0.6, 0.8))
        BUTTON_TYPES.TOGGLE:
            button.set_appearance(Vector2(50, 120), Vector2(100, 50), Color(0.8, 0.4, 0.2))
        BUTTON_TYPES.CYCLE:
            button.set_appearance(Vector2(50, 190), Vector2(100, 50), Color(0.4, 0.8, 0.2))
        BUTTON_TYPES.COMMAND:
            button.set_appearance(Vector2(50, 260), Vector2(100, 50), Color(0.8, 0.2, 0.6))
        BUTTON_TYPES.CONNECT:
            button.set_appearance(Vector2(50, 330), Vector2(100, 50), Color(0.5, 0.5, 0.9))
        BUTTON_TYPES.EMERGENT:
            button.set_appearance(Vector2(50, 400), Vector2(100, 50), Color(0.9, 0.9, 0.2))
    
    # Store the button
    _active_buttons[button_id] = button
    
    return button_id

# Execute button action
func _execute_button_action(button: Button) -> String:
    var result = ""
    
    match button.action:
        "connect":
            # Create connection to another system component
            if button.is_ctrl_activated:
                # Find other ctrl-related elements and connect
                _connect_ctrl_elements()
                result = "Connected Ctrl elements"
            else:
                result = "No connection target specified"
        
        "refresh":
            # Refresh the garden
            _refresh_garden()
            result = "Garden refreshed"
        
        "change_phase":
            # Move to next phase
            var next_phase = (_current_phase + 1) % GARDEN_PHASES.size()
            change_phase(next_phase)
            result = "Changed to phase: " + _get_phase_name(next_phase)
        
        "toggle_sync":
            # Toggle between online and offline
            var new_mode = toggle_sync_mode()
            result = "Sync mode set to: " + _get_sync_mode_name(new_mode)
        
        "change_physics":
            # Cycle through physics models
            _cycle_physics_model()
            result = "Physics model set to: " + _get_physics_model_name(_current_physics_model)
        
        _:
            result = "Unknown action: " + button.action
    
    # For connected buttons, press them too
    if button.connected_buttons.size() > 0:
        for connected_id in button.connected_buttons:
            if _active_buttons.has(connected_id):
                _active_buttons[connected_id].press()
    
    return result

# Update garden
func _update_garden(delta: float) -> void:
    # Update fruits
    for fruit_id in _fruits:
        var fruit = _fruits[fruit_id]
        
        # Skip harvested fruits
        if fruit.harvested:
            continue
        
        # Find which plot the fruit is in
        var plot = null
        for plot_id in _garden_plots:
            if _garden_plots[plot_id].planted_fruits.has(fruit_id):
                plot = _garden_plots[plot_id]
                break
        
        if plot:
            # Calculate growth rate based on plot conditions and phase
            var growth_rate = plot.calculate_growth_rate() * _config.fruit_maturation_rate * delta
            
            # Phase-specific modifiers
            match _current_phase:
                GARDEN_PHASES.GERMINATION, GARDEN_PHASES.GROWTH:
                    growth_rate *= 1.5
                GARDEN_PHASES.BUDDING, GARDEN_PHASES.FLOWERING:
                    growth_rate *= 1.2
                GARDEN_PHASES.FRUITING:
                    growth_rate *= 2.0
            
            # Apply growth
            fruit.mature(growth_rate)
            
            # Check if fruit has ripened
            if fruit.ripened and not fruit.ripened_notified:
                create_echo("The " + fruit.name + " fruit has ripened and is ready for harvest!", ECHO_SOURCE_TYPES.GARDEN)
                fruit.metadata["ripened_notified"] = true
                
                # Create a ripened fruit memory
                store_memory("A " + fruit.name + " fruit has ripened in the garden", EDEN_MEMORY_TYPES.SENSORY)
                
                # Emit signal
                emit_signal("fruit_ripened", fruit_id, fruit.maturity, fruit.nutrients)
        }
    
    # Update resources in plots
    for plot_id in _garden_plots:
        var plot = _garden_plots[plot_id]
        
        # Natural resource changes
        var water_change = -0.01 * delta  # Water evaporates
        var sunlight_change = sin(OS.get_ticks_msec() / 10000.0) * 0.02 * delta  # Sun cycles
        
        plot.update_resources(water_change, sunlight_change)
    }
    
    # Update memories
    for memory_id in _active_memory_echoes.keys():
        var memory = _active_memory_echoes[memory_id]
        
        // Memory decay based on retention factor
        var decay_amount = 0.01 * delta
        memory.decay(decay_amount)
        
        // Remove very faded memories
        if memory.clarity < 0.1:
            _active_memory_echoes.erase(memory_id)
    }

# Check for phase progression
func _check_phase_progression() -> void:
    var current_time = OS.get_unix_time()
    var elapsed_hours = (current_time - _phase_start_time) / 3600.0
    
    if elapsed_hours >= _config.phase_duration_hours:
        // Check if phase tasks are complete
        var can_progress = true
        
        if _planning_todos.has(_current_phase):
            for todo_id in _planning_todos[_current_phase]:
                var todo = _planning_todos[_current_phase][todo_id]
                if todo.priority >= 4 and todo.state != "completed" and todo.state != "cancelled":
                    can_progress = false
                    break
        }
        
        if can_progress:
            var old_phase = _current_phase
            _current_phase = (_current_phase + 1) % GARDEN_PHASES.size()
            _phase_start_time = current_time
            
            // Update all garden plots to new phase
            for plot_id in _garden_plots:
                _garden_plots[plot_id].current_phase = _current_phase
            
            // Create phase transition echo
            create_echo("Garden has transitioned from " + _get_phase_name(old_phase) + 
                       " to " + _get_phase_name(_current_phase), ECHO_SOURCE_TYPES.GARDEN)
            
            // Emit signal
            emit_signal("garden_phase_changed", old_phase, _current_phase, "Automatic progression")
        }
    }

# Update energy level
func _update_energy(delta: float) -> void:
    // Natural regeneration
    _energy_level = min(1.0, _energy_level + _config.energy_regeneration_rate * delta)
    
    // Update token physics energy
    if _token_physics_state:
        _token_physics_state.current_energy = _energy_level
    }

# Check for offline sync
func _check_offline_sync() -> void:
    if _sync_status != SYNC_MODES.OFFLINE:
        return
    
    var current_time = OS.get_unix_time()
    var hours_since_sync = (current_time - _last_sync_time) / 3600.0
    
    if hours_since_sync >= _config.offline_sync_frequency:
        _perform_offline_sync()
    }

# Perform offline sync
func _perform_offline_sync() -> Dictionary:
    var sync_id = "sync_" + str(OS.get_unix_time())
    var start_time = OS.get_ticks_msec()
    
    // Create transitional state
    _sync_status = SYNC_MODES.TRANSITIONING
    
    // Simulate sync operations
    var success_rate = randf()
    
    // Sync operations would go here in a real implementation
    
    // Refresh memories
    for memory_id in _active_memory_echoes:
        var memory = _active_memory_echoes[memory_id]
        memory.refresh()
    }
    
    // Restore energy
    _energy_level = min(1.0, _energy_level + 0.3)
    
    // Update token physics
    if _token_physics_state:
        _token_physics_state.current_energy = _energy_level
    }
    
    // Create memory of the sync
    store_memory("Performed offline sync with " + str(int(success_rate * 100)) + "% success", 
                EDEN_MEMORY_TYPES.PROCEDURAL)
    
    // Create echo
    create_echo("Offline sync completed. Memory integrity at " + 
               str(int(success_rate * 100)) + "%", ECHO_SOURCE_TYPES.SYSTEM)
    
    // Complete transition
    _sync_status = SYNC_MODES.ONLINE
    _last_sync_time = OS.get_unix_time()
    
    var duration = (OS.get_ticks_msec() - start_time) / 1000.0
    
    // Emit signal
    emit_signal("offline_sync_completed", sync_id, duration, success_rate)
    
    return {
        "sync_id": sync_id,
        "duration": duration,
        "success_rate": success_rate,
        "memories_refreshed": _active_memory_echoes.size(),
        "energy_restored": 0.3,
        "sync_status": _sync_status
    }

# Process command echo
func _process_command_echo(hatch: EchoHatch) -> void:
    // Check hash count for refresh commands
    var hash_count = 0
    var content = hatch.content
    
    while hash_count < content.length() and content[hash_count] == '#':
        hash_count += 1
    
    if hash_count > 0:
        // Use the hash count to determine refresh intensity
        var refresh_intensity = min(hash_count / 7.0, 1.0)
        
        // Apply refresh with the given intensity
        _apply_refresh(refresh_intensity)
        
        // Add to command history
        _command_history.append({
            "type": "refresh",
            "hash_count": hash_count,
            "intensity": refresh_intensity,
            "timestamp": OS.get_unix_time()
        })
    }
    
    // Check for other command types
    if content.begins_with("!"):
        var command_text = content.substr(1).strip_edges()
        var command_parts = command_text.split(" ", false)
        
        if command_parts.size() > 0:
            match command_parts[0]:
                "phase":
                    // Change garden phase
                    if command_parts.size() > 1:
                        var phase_num = int(command_parts[1])
                        if phase_num >= 0 and phase_num < GARDEN_PHASES.size():
                            change_phase(phase_num)
                
                "sync":
                    // Toggle sync mode
                    toggle_sync_mode()
                
                "physics":
                    // Change physics model
                    if command_parts.size() > 1:
                        var model_num = int(command_parts[1])
                        if model_num >= 0 and model_num < TOKEN_PHYSICS_MODELS.size():
                            _change_physics_model(model_num)
                
                "todo":
                    // Create a to-do item
                    if command_parts.size() > 1:
                        var todo_title = command_text.substr(5).strip_edges()
                        create_todo(todo_title, "Command-generated todo")
                
                "plant":
                    // Plant a fruit
                    if command_parts.size() > 1:
                        var fruit_name = command_text.substr(6).strip_edges()
                        plant_fruit(fruit_name, FRUIT_TYPES.CONCEPT, "Command-planted " + fruit_name)
    }

# Apply refresh to the garden
func _apply_refresh(intensity: float) -> void:
    // Refresh garden resources
    _garden_resources.water = min(1.0, _garden_resources.water + 0.2 * intensity)
    _garden_resources.nutrients = min(1.0, _garden_resources.nutrients + 0.2 * intensity)
    _garden_resources.energy = min(1.0, _garden_resources.energy + 0.3 * intensity)
    
    // Update energy level
    _energy_level = min(1.0, _energy_level + 0.3 * intensity)
    
    // Refresh memories
    for memory_id in _active_memory_echoes:
        _active_memory_echoes[memory_id].refresh()
    }
    
    // Create echo
    create_echo("Garden refreshed with intensity " + str(intensity), ECHO_SOURCE_TYPES.SYSTEM)
    
    // Create refresh memory
    store_memory("Garden refreshed at " + str(OS.get_time().hour) + ":" + 
                str(OS.get_time().minute), EDEN_MEMORY_TYPES.PROCEDURAL)
}

# Handle Ctrl activation
func _handle_ctrl_activation(hatch: EchoHatch) -> void:
    // Find Ctrl button
    var ctrl_button_id = ""
    
    for button_id in _active_buttons:
        var button = _active_buttons[button_id]
        if button.label == "Ctrl" and button.type == BUTTON_TYPES.CONNECT:
            ctrl_button_id = button_id
            break
    }
    
    if ctrl_button_id != "":
        // Press the Ctrl button
        press_button(ctrl_button_id)
    }
    
    // Create Ctrl-associated memory
    store_memory("Ctrl activation: " + hatch.content, EDEN_MEMORY_TYPES.PROCEDURAL)
    
    // Connect this hatch to other Ctrl-activated hatches
    for other_id in _echo_hatches:
        if other_id != hatch.id and _echo_hatches[other_id].is_ctrl_activated:
            hatch.connect_hatch(other_id)
            _echo_hatches[other_id].connect_hatch(hatch.id)
    }
}

# Connect all Ctrl-related elements
func _connect_ctrl_elements() -> void:
    // Find all Ctrl-activated elements
    var ctrl_hatches = []
    var ctrl_memories = []
    
    // Find hatches
    for hatch_id in _echo_hatches:
        if _echo_hatches[hatch_id].is_ctrl_activated:
            ctrl_hatches.append(hatch_id)
    }
    
    // Find memories
    for memory_id in _active_memory_echoes:
        if _active_memory_echoes[memory_id].is_ctrl_associated:
            ctrl_memories.append(memory_id)
    }
    
    // Connect hatches to each other
    for i in range(ctrl_hatches.size()):
        for j in range(i + 1, ctrl_hatches.size()):
            _echo_hatches[ctrl_hatches[i]].connect_hatch(ctrl_hatches[j])
            _echo_hatches[ctrl_hatches[j]].connect_hatch(ctrl_hatches[i])
    }
    
    // Connect memories to each other
    for i in range(ctrl_memories.size()):
        for j in range(i + 1, ctrl_memories.size()):
            _active_memory_echoes[ctrl_memories[i]].add_association(ctrl_memories[j])
            _active_memory_echoes[ctrl_memories[j]].add_association(ctrl_memories[i])
    }
    
    // Create connection echo
    var connection_count = ctrl_hatches.size() + ctrl_memories.size()
    create_echo("Connected " + str(connection_count) + " Ctrl elements", ECHO_SOURCE_TYPES.SYSTEM)
}

# Refresh the garden
func _refresh_garden() -> void:
    // Water all plots
    for plot_id in _garden_plots:
        _garden_plots[plot_id].water_level = 1.0
    }
    
    // Accelerate all fruits
    for fruit_id in _fruits:
        if not _fruits[fruit_id].harvested:
            _fruits[fruit_id].mature(0.1)
    }
    
    // Replenish energy
    _energy_level = 1.0
    
    // Create echo
    create_echo("Garden fully refreshed!", ECHO_SOURCE_TYPES.GARDEN)
}

# Cycle through physics models
func _cycle_physics_model() -> int:
    _current_physics_model = (_current_physics_model + 1) % TOKEN_PHYSICS_MODELS.size()
    
    // Create new physics state
    _token_physics_state = TokenPhysics.new(_current_physics_model)
    _token_physics_state.set_token_count(100)
    _token_physics_state.current_energy = _energy_level
    
    // Create echo
    create_echo("Physics model changed to " + _get_physics_model_name(_current_physics_model), 
               ECHO_SOURCE_TYPES.SYSTEM)
    
    // Create memory
    store_memory("Token physics model changed to " + _get_physics_model_name(_current_physics_model), 
                EDEN_MEMORY_TYPES.PROCEDURAL)
    
    // Emit signal
    emit_signal("token_physics_updated", _current_physics_model, _energy_level)
    
    return _current_physics_model
}

# Change to specific physics model
func _change_physics_model(model: int) -> int:
    if model < 0 or model >= TOKEN_PHYSICS_MODELS.size():
        return _current_physics_model
    
    _current_physics_model = model
    
    // Create new physics state
    _token_physics_state = TokenPhysics.new(_current_physics_model)
    _token_physics_state.set_token_count(100)
    _token_physics_state.current_energy = _energy_level
    
    // Create echo
    create_echo("Physics model set to " + _get_physics_model_name(_current_physics_model), 
               ECHO_SOURCE_TYPES.SYSTEM)
    
    // Emit signal
    emit_signal("token_physics_updated", _current_physics_model, _energy_level)
    
    return _current_physics_model
}

# Calculate emotional valence of text
func _calculate_emotional_valence(text: String) -> float:
    var positive_words = ["good", "great", "joy", "happy", "love", "beautiful", "success", "wonderful", "excellent"]
    var negative_words = ["bad", "terrible", "sad", "hate", "awful", "failure", "pain", "ugly", "horrible"]
    
    var positive_count = 0
    var negative_count = 0
    
    var text_lower = text.to_lower()
    
    // Count positive words
    for word in positive_words:
        if text_lower.find(word) >= 0:
            positive_count += 1
    }
    
    // Count negative words
    for word in negative_words:
        if text_lower.find(word) >= 0:
            negative_count += 1
    }
    
    // Calculate valence (-1.0 to 1.0)
    var valence = 0.0
    var total_count = positive_count + negative_count
    
    if total_count > 0:
        valence = (positive_count - negative_count) / float(total_count)
    }
    
    return valence
}

# Get garden phase name
func _get_phase_name(phase: int) -> String:
    for name in GARDEN_PHASES:
        if GARDEN_PHASES[name] == phase:
            return name
    return "UNKNOWN"
}

# Get physics model name
func _get_physics_model_name(model: int) -> String:
    for name in TOKEN_PHYSICS_MODELS:
        if TOKEN_PHYSICS_MODELS[name] == model:
            return name
    return "UNKNOWN"
}

# Get sync mode name
func _get_sync_mode_name(mode: int) -> String:
    for name in SYNC_MODES:
        if SYNC_MODES[name] == mode:
            return name
    return "UNKNOWN"
}

# Example usage:
# var eden_system = EdenGardenSystem.new()
# add_child(eden_system)
#
# # Set up reference to other systems
# var wish_system = QuantumWishSystem.new()
# add_child(wish_system)
# eden_system.set_quantum_wish_system(wish_system)
#
# # Create an echo
# eden_system.create_echo("Hello Eden Garden!", EdenGardenSystem.ECHO_SOURCE_TYPES.HUMAN)
#
# # Plant a fruit
# var fruit_id = eden_system.plant_fruit(
#     "Knowledge Apple",
#     EdenGardenSystem.FRUIT_TYPES.CONCEPT,
#     "A fruit that contains wisdom and understanding"
# )
#
# # Create a garden craft
# var craft_id = eden_system.create_craft(
#     "Data Weaver", 
#     EdenGardenSystem.CRAFT_CATEGORIES.TOOL,
#     "A tool for weaving together different data streams",
#     ["memory threads", "quantum fibers", "wisdom strands"]
# )
#
# # Create a todo for the current phase
# var todo_id = eden_system.create_todo(
#     "Nurture knowledge fruits",
#     "Ensure all concept fruits receive proper care and attention"
# )
#
# # Store a memory
# eden_system.store_memory(
#     "I planted my first knowledge fruit today",
#     EdenGardenSystem.EDEN_MEMORY_TYPES.EPISODIC
# )
#
# # Get token display information
# var token_info = eden_system.get_token_display_info()
# print("Currently displaying " + str(token_info.display_count) + " tokens")