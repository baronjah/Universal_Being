extends UniversalBeing
class_name CursorCrosshairStateSystem

## 🎯 CURSOR & CROSSHAIR STATE SYSTEM - VR FINGERTIP EVOLUTION
## Foundation for future VR hand/finger interaction mapping
## Each cursor/crosshair state = future fingertip tool state

# ===== VR FINGERTIP EVOLUTION ARCHITECTURE =====

enum ToolState {
	# Basic States (Mouse/Screen Era)
	IDLE,              # Relaxed fingertip
	HOVER,             # Fingertip approaching target
	TARGET,            # Fingertip pointing at target
	INTERACT,          # Fingertip touching/pressing
	
	# Advanced States (VR Era)
	GRAB,              # Index finger + thumb pinch
	MANIPULATE,        # Full hand grip
	PRECISE_TOUCH,     # Single fingertip precision
	GESTURE,           # Hand gesture recognition
	
	# Consciousness States (Future VR)
	CONSCIOUSNESS_PROBE,  # Fingertip consciousness sensing
	REALITY_SCULPT,       # Hand reality manipulation 
	TELEPATHIC_LINK,      # Fingertip-to-AI connection
	DIMENSIONAL_REACH     # Hand reaching through space
}

enum FingertipMapping {
	# Future VR Hand Mapping
	THUMB_TIP,         # Primary selection/confirmation
	INDEX_TIP,         # Precise targeting/pointing
	MIDDLE_TIP,        # Power actions/force
	RING_TIP,          # Delicate operations
	PINKY_TIP,         # Special/advanced functions
	
	# Hand Combinations
	PINCH_GRIP,        # Thumb + Index = grab/select
	POWER_GRIP,        # Full hand = manipulate objects
	FINGER_WALK,       # Sequential finger taps
	CONSCIOUSNESS_TOUCH # All fingertips = consciousness bridge
}

# ===== CURRENT STATE SYSTEM =====

signal tool_state_changed(old_state: ToolState, new_state: ToolState)
signal fingertip_mapped(fingertip: FingertipMapping, tool_state: ToolState)
signal vr_transition_ready(hand_position: Vector3, finger_states: Array)

@export var current_tool_state: ToolState = ToolState.IDLE
@export var vr_evolution_enabled: bool = true
@export var consciousness_states_enabled: bool = true

# Visual state representations
var crosshair_colors: Dictionary = {
	ToolState.IDLE: Color.CYAN,
	ToolState.HOVER: Color.YELLOW, 
	ToolState.TARGET: Color.ORANGE,
	ToolState.INTERACT: Color.RED,
	ToolState.GRAB: Color.GREEN,
	ToolState.MANIPULATE: Color.BLUE,
	ToolState.PRECISE_TOUCH: Color.MAGENTA,
	ToolState.GESTURE: Color.WHITE,
	ToolState.CONSCIOUSNESS_PROBE: Color(0.5, 0, 1, 1),  # Purple
	ToolState.REALITY_SCULPT: Color(1, 0.5, 0, 1),        # Gold
	ToolState.TELEPATHIC_LINK: Color(0, 1, 1, 1),         # Cyan glow
	ToolState.DIMENSIONAL_REACH: Color(1, 1, 1, 1)        # Pure white
}

# VR Evolution Data
var fingertip_states: Dictionary = {}
var hand_position: Vector3 = Vector3.ZERO
var consciousness_bridge_active: bool = false

# Target tracking
var current_target: Node3D = null
var target_distance: float = 0.0
var target_type: String = ""
var interaction_strength: float = 0.0

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "cursor_crosshair_state_system"
	being_name = "Fingertip Evolution Controller"
	consciousness_level = 4  # Enlightened tool interaction
	
	# Initialize fingertip mapping
	_initialize_fingertip_mapping()
	
	print("🎯 Cursor/Crosshair State System: VR fingertip evolution ready")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Connect to consciousness systems
	_connect_consciousness_bridge()
	
	# Setup VR transition monitoring
	if vr_evolution_enabled:
		_setup_vr_evolution_monitoring()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update current state based on targets
	_update_tool_state()
	
	# Monitor for VR evolution opportunities
	if vr_evolution_enabled:
		_monitor_vr_evolution(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Map input events to future fingertip actions
	_map_input_to_fingertip(event)

func pentagon_sewers() -> void:
	# Save fingertip evolution data
	_save_evolution_progress()
	super.pentagon_sewers()

# ===== STATE MANAGEMENT =====

func change_tool_state(new_state: ToolState) -> void:
	"""Change current tool state with evolution tracking"""
	if new_state == current_tool_state:
		return
	
	var old_state = current_tool_state
	current_tool_state = new_state
	
	# Visual feedback
	_update_visual_feedback()
	
	# VR Evolution: Map to future fingertip
	if vr_evolution_enabled:
		_map_state_to_fingertip(new_state)
	
	# Consciousness integration
	if consciousness_states_enabled and _is_consciousness_state(new_state):
		_activate_consciousness_bridge()
	
	tool_state_changed.emit(old_state, new_state)
	print("🎯 State: %s → %s" % [ToolState.keys()[old_state], ToolState.keys()[new_state]])

func _update_tool_state() -> void:
	"""Auto-update state based on current target/interaction"""
	if not current_target:
		if current_tool_state != ToolState.IDLE:
			change_tool_state(ToolState.IDLE)
		return
	
	# Distance-based state transitions
	if target_distance > 5.0:
		change_tool_state(ToolState.HOVER)
	elif target_distance > 1.0:
		change_tool_state(ToolState.TARGET)
	elif Input.is_action_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Future: Map to fingertip touch pressure
		if interaction_strength > 0.8:
			change_tool_state(ToolState.MANIPULATE)
		elif interaction_strength > 0.5:
			change_tool_state(ToolState.INTERACT)
		else:
			change_tool_state(ToolState.PRECISE_TOUCH)

# ===== VR FINGERTIP EVOLUTION =====

func _initialize_fingertip_mapping() -> void:
	"""Initialize the cursor→fingertip evolution mapping"""
	fingertip_states = {
		FingertipMapping.THUMB_TIP: ToolState.INTERACT,      # Primary interaction
		FingertipMapping.INDEX_TIP: ToolState.TARGET,        # Precision pointing  
		FingertipMapping.MIDDLE_TIP: ToolState.MANIPULATE,   # Power operations
		FingertipMapping.RING_TIP: ToolState.PRECISE_TOUCH,  # Delicate work
		FingertipMapping.PINKY_TIP: ToolState.GESTURE,       # Special functions
		
		# Advanced combinations
		FingertipMapping.PINCH_GRIP: ToolState.GRAB,         # Thumb+Index
		FingertipMapping.POWER_GRIP: ToolState.MANIPULATE,   # Full hand
		FingertipMapping.CONSCIOUSNESS_TOUCH: ToolState.CONSCIOUSNESS_PROBE  # All fingers
	}
	
	print("🤚 Fingertip mapping initialized: %d states ready for VR evolution" % fingertip_states.size())

func _map_state_to_fingertip(state: ToolState) -> void:
	"""Map current tool state to future VR fingertip"""
	var mapped_fingertip: FingertipMapping
	
	match state:
		ToolState.TARGET:
			mapped_fingertip = FingertipMapping.INDEX_TIP
		ToolState.INTERACT:
			mapped_fingertip = FingertipMapping.THUMB_TIP
		ToolState.GRAB:
			mapped_fingertip = FingertipMapping.PINCH_GRIP
		ToolState.MANIPULATE:
			mapped_fingertip = FingertipMapping.POWER_GRIP
		ToolState.PRECISE_TOUCH:
			mapped_fingertip = FingertipMapping.RING_TIP
		ToolState.CONSCIOUSNESS_PROBE:
			mapped_fingertip = FingertipMapping.CONSCIOUSNESS_TOUCH
		_:
			mapped_fingertip = FingertipMapping.INDEX_TIP  # Default
	
	fingertip_mapped.emit(mapped_fingertip, state)
	print("🤚 VR Evolution: %s → %s" % [ToolState.keys()[state], FingertipMapping.keys()[mapped_fingertip]])

func _map_input_to_fingertip(event: InputEvent) -> void:
	"""Map current input to future fingertip gestures"""
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				# Future: Index finger tap
				_simulate_fingertip_action(FingertipMapping.INDEX_TIP, event.pressed)
			MOUSE_BUTTON_RIGHT:
				# Future: Thumb press
				_simulate_fingertip_action(FingertipMapping.THUMB_TIP, event.pressed)
			MOUSE_BUTTON_MIDDLE:
				# Future: Middle finger power action
				_simulate_fingertip_action(FingertipMapping.MIDDLE_TIP, event.pressed)
	
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F:  # Future: Pinch grab gesture
				_simulate_fingertip_action(FingertipMapping.PINCH_GRIP, true)
			KEY_G:  # Future: Full hand grip
				_simulate_fingertip_action(FingertipMapping.POWER_GRIP, true)
			KEY_H:  # Future: Consciousness bridge (all fingertips)
				_activate_consciousness_fingertip_bridge()

func _simulate_fingertip_action(fingertip: FingertipMapping, active: bool) -> void:
	"""Simulate future VR fingertip action"""
	var action_state = "ACTIVE" if active else "RELEASED"
	print("🤚 VR Simulation: %s %s" % [FingertipMapping.keys()[fingertip], action_state])
	
	# Future VR: This will trigger actual hand tracking
	# For now: Visual feedback + state logging
	if active:
		interaction_strength = randf_range(0.3, 1.0)  # Simulate touch pressure

# ===== CONSCIOUSNESS INTEGRATION =====

func _is_consciousness_state(state: ToolState) -> bool:
	"""Check if state involves consciousness interaction"""
	return state in [
		ToolState.CONSCIOUSNESS_PROBE,
		ToolState.TELEPATHIC_LINK,
		ToolState.REALITY_SCULPT,
		ToolState.DIMENSIONAL_REACH
	]

func _activate_consciousness_bridge() -> void:
	"""Activate consciousness bridge for advanced states"""
	consciousness_bridge_active = true
	print("🧠 Consciousness bridge: ACTIVE")
	
	# Connect to Gemma AI for telepathic states
	var gemma = get_tree().get_first_node_in_group("gemma_perfect_consciousness")
	if gemma and gemma.has_method("establish_telepathic_link"):
		gemma.establish_telepathic_link(self)

func _activate_consciousness_fingertip_bridge() -> void:
	"""Future VR: All fingertips create consciousness bridge"""
	change_tool_state(ToolState.CONSCIOUSNESS_PROBE)
	consciousness_bridge_active = true
	
	print("🤚🧠 CONSCIOUSNESS FINGERTIP BRIDGE: All fingertips connected to AI consciousness")
	
	# Future: This will read brain/nerve signals through VR gloves
	# and translate them to direct AI communication

# ===== VISUAL FEEDBACK =====

func _update_visual_feedback() -> void:
	"""Update crosshair/cursor visuals based on current state"""
	var state_color = crosshair_colors.get(current_tool_state, Color.WHITE)
	
	# Update crosshair color
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("update_crosshair_color"):
		player.update_crosshair_color(state_color)
	
	# Consciousness states get special effects
	if _is_consciousness_state(current_tool_state):
		_apply_consciousness_visual_effects()

func _apply_consciousness_visual_effects() -> void:
	"""Special visual effects for consciousness states"""
	# Future: Particle effects, aura visualization, consciousness ripples
	print("✨ Consciousness visual effects: %s" % ToolState.keys()[current_tool_state])

# ===== VR EVOLUTION MONITORING =====

func _setup_vr_evolution_monitoring() -> void:
	"""Setup monitoring for VR transition readiness"""
	var vr_timer = Timer.new()
	vr_timer.wait_time = 1.0
	vr_timer.timeout.connect(_check_vr_readiness)
	add_child(vr_timer)
	vr_timer.start()

func _monitor_vr_evolution(delta: float) -> void:
	"""Monitor readiness for VR hand tracking evolution"""
	# Track hand position simulation
	hand_position = global_position  # Future: Real hand tracking
	
	# Collect fingertip state data
	var finger_states = []
	for fingertip in FingertipMapping.values():
		var state_data = {
			"fingertip": fingertip,
			"active": fingertip_states.has(fingertip),
			"state": fingertip_states.get(fingertip, ToolState.IDLE)
		}
		finger_states.append(state_data)
	
	# Check if ready for VR transition
	if _check_vr_readiness():
		vr_transition_ready.emit(hand_position, finger_states)

func _check_vr_readiness() -> bool:
	"""Check if system is ready for VR evolution"""
	var active_fingertips = 0
	for state in fingertip_states.values():
		if state != ToolState.IDLE:
			active_fingertips += 1
	
	return active_fingertips >= 3  # Need multiple active fingertip states

# ===== PERSISTENCE =====

func _save_evolution_progress() -> void:
	"""Save fingertip evolution progress for future VR integration"""
	var evolution_data = {
		"fingertip_mappings": fingertip_states,
		"consciousness_bridge_sessions": 1 if consciousness_bridge_active else 0,
		"total_state_changes": get_meta("state_changes", 0),
		"vr_readiness_level": _calculate_vr_readiness()
	}
	
	# Future: Save to VR configuration file
	print("🤚 VR Evolution Progress: %s" % evolution_data)

func _calculate_vr_readiness() -> float:
	"""Calculate readiness percentage for VR hand tracking"""
	var readiness = 0.0
	
	# Factor 1: Number of mapped fingertip states
	readiness += (fingertip_states.size() / 8.0) * 0.4
	
	# Factor 2: Consciousness bridge usage
	readiness += (1.0 if consciousness_bridge_active else 0.0) * 0.3
	
	# Factor 3: Advanced state usage
	var advanced_states = 0
	for state in fingertip_states.values():
		if _is_consciousness_state(state):
			advanced_states += 1
	readiness += (advanced_states / 4.0) * 0.3
	
	return clamp(readiness, 0.0, 1.0)

# ===== CONNECTION HELPERS =====

func _connect_consciousness_bridge() -> void:
	"""Connect to consciousness systems"""
	var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
	if flood_gates:
		flood_gates.register_consciousness_interface(self)

func set_current_target(target: Node3D, distance: float = 0.0) -> void:
	"""Set current interaction target"""
	current_target = target
	target_distance = distance
	
	if target:
		target_type = target.get_class()
		if target.has_meta("being_type"):
			target_type = target.get_meta("being_type")
	else:
		target_type = ""

func get_vr_evolution_data() -> Dictionary:
	"""Get current VR evolution data for external systems"""
	return {
		"current_state": current_tool_state,
		"fingertip_mappings": fingertip_states,
		"hand_position": hand_position,
		"consciousness_bridge": consciousness_bridge_active,
		"vr_readiness": _calculate_vr_readiness()
	}