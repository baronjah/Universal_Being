extends Node

class_name EtherealEngine

# Ethereal Engine - Core System
# Central controller for the 12-turn Ethereal Engine system
# Manages connections between all subsystems

# ----- SIGNALS -----
signal engine_initialized
signal reality_shifted(old_reality, new_reality)
signal word_manifested(word, power, location)
signal dimension_changed(old_dimension, new_dimension)
signal moon_phase_changed(old_phase, new_phase)

# ----- CONSTANTS -----
const ENGINE_VERSION = "1.0.0"
const MAX_WORD_POWER = 12.0
const REALITY_TYPES = [
	"PHYSICAL", "DIGITAL", "ASTRAL", 
	"QUANTUM", "MEMORY", "DREAM"
]

# ----- PROPERTIES -----
var initialized: bool = false
var active_reality: String = "DIGITAL"
var active_dimension: int = 3  # Start in 3D
var quantum_loop_active: bool = false
var moon_phase: int = 4  # Full moon
var gate_stability: float = 1.0
var entity_count: int = 0
var word_power_accumulator: float = 0.0

# ----- SYSTEMS -----
@onready var turn_manager = get_node("/root/TurnManager")
@onready var word_system = get_node("/root/WordManifestationSystem")
@onready var dimension_controller = get_node("/root/DimensionController")

# ----- INITIALIZATION -----
func _ready():
	print("Ethereal Engine v%s initializing..." % ENGINE_VERSION)
	
	# Wait one frame to ensure all systems are loaded
	await get_tree().process_frame
	
	# Connect signals
	_connect_signals()
	
	# Initialize subsystems
	_initialize_subsystems()
	
	# Mark as initialized
	initialized = true
	emit_signal("engine_initialized")
	
	print("Ethereal Engine initialized. Reality: %s, Dimension: %dD" % [active_reality, active_dimension])

func _connect_signals():
	if turn_manager:
		turn_manager.connect("turn_advanced", _on_turn_advanced)
		turn_manager.connect("cycle_completed", _on_cycle_completed)
	
	if word_system:
		word_system.connect("word_created", _on_word_created)
		
	if dimension_controller:
		dimension_controller.connect("dimension_changed", _on_dimension_changed)

func _initialize_subsystems():
	# Initialize TurnManager
	if turn_manager:
		turn_manager.initialize(3)  # Start at turn 3 (Complexity - 3D Space)
	
	# Initialize WordManifestationSystem
	if word_system:
		word_system.initialize(active_reality, active_dimension)
		
	# Initialize DimensionController
	if dimension_controller:
		dimension_controller.initialize(active_dimension, active_reality)

# ----- PROCESS -----
func _process(delta):
	if not initialized:
		return
		
	# Update word power accumulator
	if word_power_accumulator > 0:
		word_power_accumulator -= delta * 0.1
		word_power_accumulator = max(0, word_power_accumulator)
	
	# Check for gate stability in Full Moon phase
	if moon_phase == 4:  # Full Moon
		# Gate stability fluctuates naturally
		gate_stability += sin(Time.get_ticks_msec() * 0.001) * delta * 0.05
		gate_stability = clamp(gate_stability, 0.0, 1.0)

# ----- PUBLIC API -----
func get_engine_status() -> Dictionary:
	return {
		"version": ENGINE_VERSION,
		"reality": active_reality,
		"dimension": active_dimension,
		"moon_phase": moon_phase,
		"gate_stability": gate_stability,
		"current_turn": turn_manager.current_turn if turn_manager else 0,
		"current_phase": turn_manager.get_current_phase_name() if turn_manager else "",
		"entity_count": entity_count,
		"word_power": word_power_accumulator,
		"quantum_loop": quantum_loop_active
	}

func shift_reality(new_reality: String) -> bool:
	if not new_reality in REALITY_TYPES:
		push_error("Invalid reality type: %s" % new_reality)
		return false
	
	var old_reality = active_reality
	active_reality = new_reality
	
	# Update subsystems
	if word_system:
		word_system.set_reality(new_reality)
	
	if dimension_controller:
		dimension_controller.set_reality(new_reality)
	
	emit_signal("reality_shifted", old_reality, new_reality)
	print("Reality shifted: %s → %s" % [old_reality, new_reality])
	
	return true

func change_dimension(new_dimension: int) -> bool:
	if new_dimension < 1 or new_dimension > 12:
		push_error("Invalid dimension: %d (must be 1-12)" % new_dimension)
		return false
	
	var old_dimension = active_dimension
	active_dimension = new_dimension
	
	# Sync with turn manager
	if turn_manager and turn_manager.current_turn != new_dimension:
		turn_manager.set_turn(new_dimension)
	
	# Update dimension controller
	if dimension_controller:
		dimension_controller.set_dimension(new_dimension)
	
	emit_signal("dimension_changed", old_dimension, new_dimension)
	print("Dimension changed: %dD → %dD" % [old_dimension, new_dimension])
	
	return true

func toggle_quantum_loop() -> bool:
	quantum_loop_active = !quantum_loop_active
	
	if turn_manager:
		turn_manager.set_quantum_loop(quantum_loop_active)
	
	print("Quantum Loop: %s" % ("ACTIVE" if quantum_loop_active else "INACTIVE"))
	return quantum_loop_active

func create_entity(entity_type: String, position: Vector3) -> int:
	entity_count += 1
	
	# Return entity ID
	return entity_count

func get_word_power(word: String) -> float:
	# Calculate word power based on various factors
	var base_power = 1.0
	
	# Length factor (longer words have more power)
	var length_factor = clamp(float(word.length()) / 10.0, 0.1, 1.0)
	
	# Current turn factor
	var turn_factor = 1.0
	if turn_manager:
		turn_factor = float(turn_manager.current_turn) / 12.0
	
	# Reality factor
	var reality_factor = 1.0
	match active_reality:
		"ASTRAL": reality_factor = 1.5
		"QUANTUM": reality_factor = 2.0
		"DREAM": reality_factor = 1.8
		"MEMORY": reality_factor = 1.2
	
	# Moon phase factor
	var moon_factor = 1.0 + (float(moon_phase) / 8.0)
	
	# Calculate final power
	var power = base_power * length_factor * turn_factor * reality_factor * moon_factor
	
	# Clamp to max power
	return clamp(power, 0.1, MAX_WORD_POWER)

# ----- EVENT HANDLERS -----
func _on_turn_advanced(old_turn, new_turn):
	print("Turn advanced: %d → %d" % [old_turn, new_turn])
	
	# Sync dimension with turn
	if active_dimension != new_turn:
		change_dimension(new_turn)

func _on_cycle_completed():
	print("12-turn cycle completed!")
	
	# Enhance word power temporarily
	word_power_accumulator = MAX_WORD_POWER
	
	# Change moon phase
	_advance_moon_phase()

func _on_word_created(word, power, position):
	emit_signal("word_manifested", word, power, position)
	
	# Word creation affects gate stability
	gate_stability += (power / MAX_WORD_POWER) * 0.1
	gate_stability = clamp(gate_stability, 0.0, 1.0)

func _on_dimension_changed(old_dim, new_dim):
	active_dimension = new_dim

func _advance_moon_phase():
	var old_phase = moon_phase
	moon_phase = (moon_phase % 8) + 1
	
	emit_signal("moon_phase_changed", old_phase, moon_phase)
	print("Moon phase changed: %d → %d" % [old_phase, moon_phase])