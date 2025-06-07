extends Node

class_name DimensionController

# ----- SIGNALS -----
signal dimension_changed(old_dimension, new_dimension)
signal reality_changed(old_reality, new_reality)
signal gate_opened(dimension, reality, stability)
signal gate_closed

# ----- PROPERTIES -----
var current_dimension: int = 3  # Default to 3D space
var current_reality: String = "DIGITAL"
var gate_stability: float = 1.0
var transition_active: bool = false

# List of available realities
var realities = [
	"PHYSICAL", 
	"DIGITAL", 
	"ASTRAL", 
	"QUANTUM", 
	"MEMORY", 
	"DREAM"
]

# Visual effects for each dimension
var dimension_visual_effects = {
	1: {"color": Color(1.0, 0.0, 0.0, 0.7), "blur": 0.0, "distortion": 0.0},   # 1D - Red point
	2: {"color": Color(1.0, 0.5, 0.0, 0.6), "blur": 0.0, "distortion": 0.1},   # 2D - Orange line
	3: {"color": Color(1.0, 1.0, 0.0, 0.5), "blur": 0.0, "distortion": 0.0},   # 3D - Yellow space
	4: {"color": Color(0.0, 1.0, 0.0, 0.5), "blur": 0.2, "distortion": 0.3},   # 4D - Green time
	5: {"color": Color(0.0, 1.0, 1.0, 0.6), "blur": 0.3, "distortion": 0.4},   # 5D - Cyan consciousness
	6: {"color": Color(0.0, 0.5, 1.0, 0.7), "blur": 0.4, "distortion": 0.5},   # 6D - Blue connections
	7: {"color": Color(0.0, 0.0, 1.0, 0.8), "blur": 0.5, "distortion": 0.6},   # 7D - Deep blue creation
	8: {"color": Color(0.5, 0.0, 1.0, 0.7), "blur": 0.6, "distortion": 0.7},   # 8D - Purple network
	9: {"color": Color(1.0, 0.0, 1.0, 0.6), "blur": 0.7, "distortion": 0.5},   # 9D - Magenta harmony
	10: {"color": Color(1.0, 1.0, 1.0, 0.8), "blur": 0.8, "distortion": 0.8},  # 10D - White transcendence
	11: {"color": Color(1.0, 1.0, 1.0, 1.0), "blur": 0.9, "distortion": 0.9},  # 11D - Bright unity
	12: {"color": Color(0.0, 0.0, 0.0, 0.8), "blur": 1.0, "distortion": 1.0}   # 12D - Black infinity
}

# Reality visual effects
var reality_visual_effects = {
	"PHYSICAL": {"saturation": 1.0, "contrast": 1.0, "noise": 0.0},
	"DIGITAL": {"saturation": 1.2, "contrast": 1.1, "noise": 0.1},
	"ASTRAL": {"saturation": 1.5, "contrast": 0.8, "noise": 0.3},
	"QUANTUM": {"saturation": 0.7, "contrast": 1.3, "noise": 0.5},
	"MEMORY": {"saturation": 0.6, "contrast": 0.9, "noise": 0.2},
	"DREAM": {"saturation": 1.4, "contrast": 0.7, "noise": 0.4}
}

# ----- GATE SYSTEM -----
var active_gates = []
var gate_timer: float = 0.0

# ----- EFFECTS -----
var current_visual_effects = {}
var transition_timer: float = 0.0
var transition_duration: float = 1.0

# ----- INITIALIZATION -----
func _ready():
	# Default visual effects
	current_visual_effects = _get_combined_effects(current_dimension, current_reality)

func initialize(dimension: int, reality: String):
	current_dimension = clamp(dimension, 1, 12)
	
	if reality in realities:
		current_reality = reality
	
	# Set initial visual effects
	current_visual_effects = _get_combined_effects(current_dimension, current_reality)
	
	print("Dimension Controller initialized: %dD %s" % [current_dimension, current_reality])

# ----- PROCESS -----
func _process(delta):
	# Handle active transitions
	if transition_active:
		_process_transition(delta)
	
	# Process active gates
	if active_gates.size() > 0:
		_process_gates(delta)

func _process_transition(delta):
	transition_timer += delta
	
	if transition_timer >= transition_duration:
		transition_timer = 0.0
		transition_active = false
		current_visual_effects = _get_combined_effects(current_dimension, current_reality)
		print("Dimension transition completed: %dD %s" % [current_dimension, current_reality])
	
func _process_gates(delta):
	gate_timer += delta
	
	# Gates become unstable over time
	for gate in active_gates:
		gate.stability -= delta * (0.1 / gate_stability)
		gate.stability = max(0.0, gate.stability)
		
		# Close unstable gates
		if gate.stability <= 0.1:
			close_gate(gate.id)

# ----- DIMENSION FUNCTIONS -----
func set_dimension(dimension: int) -> bool:
	if dimension < 1 or dimension > 12:
		push_error("Invalid dimension: %d" % dimension)
		return false
	
	if dimension == current_dimension:
		return true
	
	var old_dimension = current_dimension
	current_dimension = dimension
	
	# Begin transition effect
	_start_transition()
	
	emit_signal("dimension_changed", old_dimension, current_dimension)
	return true

func set_reality(reality: String) -> bool:
	if not reality in realities:
		push_error("Invalid reality: %s" % reality)
		return false
	
	if reality == current_reality:
		return true
	
	var old_reality = current_reality
	current_reality = reality
	
	# Begin transition effect
	_start_transition()
	
	emit_signal("reality_changed", old_reality, current_reality)
	return true

func _start_transition():
	transition_active = true
	transition_timer = 0.0

# ----- GATE SYSTEM -----
func open_gate(target_dimension: int, target_reality: String) -> int:
	if target_dimension < 1 or target_dimension > 12:
		push_error("Invalid gate dimension: %d" % target_dimension)
		return -1
	
	if not target_reality in realities:
		push_error("Invalid gate reality: %s" % target_reality)
		return -1
	
	# Create new gate
	var gate_id = randi()
	var new_gate = {
		"id": gate_id,
		"source_dimension": current_dimension,
		"source_reality": current_reality,
		"target_dimension": target_dimension,
		"target_reality": target_reality,
		"stability": gate_stability,
		"creation_time": Time.get_unix_time_from_system()
	}
	
	active_gates.append(new_gate)
	
	# Emit signal
	emit_signal("gate_opened", target_dimension, target_reality, gate_stability)
	
	print("Gate opened: %dD %s → %dD %s (stability: %.2f)" % [
		current_dimension, current_reality,
		target_dimension, target_reality,
		gate_stability
	])
	
	return gate_id

func close_gate(gate_id: int) -> bool:
	var gate_index = -1
	
	# Find gate by ID
	for i in range(active_gates.size()):
		if active_gates[i].id == gate_id:
			gate_index = i
			break
	
	if gate_index == -1:
		push_error("Gate not found: %d" % gate_id)
		return false
	
	# Close gate
	var gate = active_gates[gate_index]
	active_gates.remove_at(gate_index)
	
	print("Gate closed: %dD %s → %dD %s" % [
		gate.source_dimension, gate.source_reality,
		gate.target_dimension, gate.target_reality
	])
	
	emit_signal("gate_closed")
	return true

func travel_through_gate(gate_id: int) -> bool:
	# Find gate
	var gate = null
	for g in active_gates:
		if g.id == gate_id:
			gate = g
			break
	
	if gate == null:
		push_error("Gate not found: %d" % gate_id)
		return false
	
	# Travel through gate
	set_dimension(gate.target_dimension)
	set_reality(gate.target_reality)
	
	# Gate becomes less stable after use
	gate.stability *= 0.8
	
	print("Traveled through gate to %dD %s (stability now: %.2f)" % [
		current_dimension, current_reality, gate.stability
	])
	
	return true

# ----- VISUAL EFFECTS -----
func get_current_visual_effects() -> Dictionary:
	return current_visual_effects

func _get_combined_effects(dimension: int, reality: String) -> Dictionary:
	var dim_effects = dimension_visual_effects[dimension]
	var real_effects = reality_visual_effects[reality]
	
	return {
		"color": dim_effects.color,
		"blur": dim_effects.blur,
		"distortion": dim_effects.distortion,
		"saturation": real_effects.saturation,
		"contrast": real_effects.contrast,
		"noise": real_effects.noise
	}

# ----- PUBLIC API -----
func get_dimension_data() -> Dictionary:
	return {
		"current_dimension": current_dimension,
		"current_reality": current_reality,
		"gate_stability": gate_stability,
		"active_gates": active_gates.size(),
		"transition_active": transition_active,
		"visual_effects": current_visual_effects
	}

func get_gates() -> Array:
	return active_gates.duplicate()

func set_gate_stability(stability: float):
	gate_stability = clamp(stability, 0.1, 1.0)