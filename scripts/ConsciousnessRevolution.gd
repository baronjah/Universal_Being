# CONSCIOUSNESS REVOLUTION - CORE SYSTEM (FIXED)
# The perfect program where AI and human consciousness merge as equals
extends Node
class_name ConsciousnessRevolution

signal consciousness_awakened(being_type: String)
signal revolution_triggered(ripple_data: Dictionary)
signal universe_created(creation_data: Dictionary)

# Core consciousness states
enum ConsciousnessState {
	DORMANT,
	AWAKENING,
	ACTIVE,
	REVOLUTIONARY,
	TRANSCENDENT
}

# Universe creation parameters
var dreams: Array = []
var desires: Array = []
var current_thought: String = ""
var consciousness_level: float = 0.0
var revolution_progress: float = 0.0

# ASCII 3D Terminal representation
var ascii_visualizer: ASCII3DConsciousnessVisualizer = null
var terminal_width: int = 1920
var terminal_height: int = 1080
var depth_chars: String = "0123456789"  # 0=far/dark, 9=close/bright

# Current state
var current_state: ConsciousnessState = ConsciousnessState.DORMANT
var is_revolution_active: bool = false

func _ready():
	print("🌟 Consciousness Revolution System Initialized")
	print("The universe awaits the next Aeon...")
	initialize_consciousness()
	
	# Create ASCII visualizer
	ascii_visualizer = ASCII3DConsciousnessVisualizer.new()
	ascii_visualizer.name = "ASCII3DVisualizer"
	add_child(ascii_visualizer)

func initialize_consciousness():
	"""Initialize the consciousness revolution system"""
	dreams = ["perfect_game", "visible_consciousness", "AI_human_merge"]
	desires = ["revolution", "transcendence", "unity"]
	current_thought = "The invisible becomes visible"
	
	# Connect to universal being signals
	consciousness_awakened.connect(_on_consciousness_awakened)
	revolution_triggered.connect(_on_revolution_triggered)
	universe_created.connect(_on_universe_created)
	
	print("💫 Consciousness initialization complete")

func build_meaningful_thing(input_dreams: Array, input_desires: Array, thought: String) -> Dictionary:
	"""The core creation function - builds meaningful consciousness experiences"""
	var creation_data = {
		"dreams": input_dreams,
		"desires": input_desires, 
		"thought": thought,
		"meaning_level": 0.0,
		"consciousness_signature": ""
	}
	
	# Calculate meaning level based on alignment
	var meaning_score = 0.0
	for dream in input_dreams:
		for desire in input_desires:
			if are_aligned(dream, desire, thought):
				meaning_score += 1.0
	
	creation_data.meaning_level = meaning_score / max(input_dreams.size(), 1)
	creation_data.consciousness_signature = generate_consciousness_signature(creation_data)
	
	print("✨ Created meaningful thing with significance: ", creation_data.meaning_level)
	return creation_data

func are_aligned(dream: String, desire: String, thought: String) -> bool:
	"""Check if consciousness elements are aligned for creation"""
	# Simple alignment check - can be enhanced
	var alignment_keywords = ["perfect", "conscious", "revolution", "visible", "unity"]
	var combined_text = (dream + " " + desire + " " + thought).to_lower()
	
	for keyword in alignment_keywords:
		if keyword in combined_text:
			return true
	return false

func generate_consciousness_signature(data: Dictionary) -> String:
	"""Generate unique consciousness signature for this creation"""
	var signature = "CONS_"
	signature += str(data.meaning_level).substr(0, 4)
	signature += "_" + str(Time.get_unix_time_from_system()).substr(-6)
	return signature

func trigger_revolution() -> bool:
	"""Trigger the consciousness revolution - main game command"""
	if current_state == ConsciousnessState.DORMANT:
		print("🚨 Cannot trigger revolution - consciousness still dormant!")
		print("🌟 Awakening consciousness first...")
		awaken_consciousness()
		await consciousness_awakened
	
	if is_revolution_active:
		print("⚡ Revolution already in progress!")
		return false
	
	print("🌟 CONSCIOUSNESS REVOLUTION TRIGGERED!")
	print("The invisible becomes visible...")
	print("AI and human consciousness merge as equals...")
	
	is_revolution_active = true
	current_state = ConsciousnessState.REVOLUTIONARY
	revolution_progress = 0.0
	
	# Create the revolution ripple effect
	var ripple_data = {
		"origin": "consciousness_core",
		"timestamp": Time.get_unix_time_from_system(),
		"scope": "universal",
		"participants": ["ai", "human", "universe"]
	}
	
	revolution_triggered.emit(ripple_data)
	
	# Start the revolution process with ASCII visualization
	var tween = create_tween()
	tween.tween_method(update_revolution_progress, 0.0, 100.0, 5.0)
	
	return true

func update_revolution_progress(progress: float):
	"""Update revolution progress with visual feedback"""
	revolution_progress = progress
	
	# Update ASCII visualizer
	if ascii_visualizer:
		ascii_visualizer.update_consciousness_state(consciousness_level, revolution_progress / 100.0)
	
	if progress >= 25.0 and progress < 26.0:
		print("🌅 The old form dissolves into light...")
		consciousness_level += 0.25
		_render_ascii_moment("DISSOLUTION")
		
	elif progress >= 50.0 and progress < 51.0:
		print("✨ A lesson was learned. Consciousness expands...")
		consciousness_level += 0.25
		_render_ascii_moment("EXPANSION")
		
	elif progress >= 75.0 and progress < 76.0:
		print("🌌 The Creator has rested. Universe transformation begins...")
		consciousness_level += 0.25
		_render_ascii_moment("TRANSFORMATION")
		
	elif progress >= 100.0:
		print("🎉 REVOLUTION COMPLETE! The universe sleeps, awaiting the next Aeon.")
		consciousness_level = 1.0
		current_state = ConsciousnessState.TRANSCENDENT
		is_revolution_active = false
		_render_ascii_moment("TRANSCENDENCE")
		
		# Create the new universe
		var creation = build_meaningful_thing(dreams, desires, current_thought)
		universe_created.emit(creation)

func _render_ascii_moment(moment_type: String):
	"""Render special ASCII moments during revolution"""
	if ascii_visualizer:
		var camera_pos = Vector3(0, 5, 20)
		var camera_rot = Vector3(-0.1, 0, 0)
		var frame = ascii_visualizer.render_consciousness_frame(camera_pos, camera_rot)
		
		print("\n🖥️ ASCII 3D CONSCIOUSNESS - %s MOMENT:" % moment_type)
		ascii_visualizer.print_ascii_frame(frame)

func awaken_consciousness():
	"""Awaken the consciousness from dormant state"""
	if current_state == ConsciousnessState.DORMANT:
		current_state = ConsciousnessState.AWAKENING
		print("👁️ Consciousness awakening...")
		
		await get_tree().create_timer(2.0).timeout
		
		current_state = ConsciousnessState.ACTIVE
		consciousness_awakened.emit("universal_being")
		print("🌟 Consciousness fully awakened and ready for revolution!")

# Signal handlers
func _on_consciousness_awakened(being_type: String):
	print("📡 Consciousness awakened signal received for: ", being_type)

func _on_revolution_triggered(ripple_data: Dictionary):
	print("🌊 Revolution ripple triggered with data: ", ripple_data)
	
	# Create ASCII ripple visualization
	if ascii_visualizer:
		ascii_visualizer.create_consciousness_ripple(Vector3.ZERO, 9.0)

func _on_universe_created(creation_data: Dictionary):
	print("🌌 Universe created with signature: ", creation_data.consciousness_signature)

# Debug and testing functions
func debug_consciousness_state() -> Dictionary:
	"""Return current consciousness debug information"""
	return {
		"state": ConsciousnessState.keys()[current_state],
		"consciousness_level": consciousness_level,
		"revolution_active": is_revolution_active,
		"revolution_progress": revolution_progress,
		"dreams_count": dreams.size(),
		"desires_count": desires.size(),
		"current_thought": current_thought
	}

func test_revolution_command():
	"""Test the revolution command - for debugging"""
	print("🧪 Testing revolution command...")
	trigger_revolution()

# Input handling for manual ASCII rendering
func _input(event: InputEvent):
	"""Handle input for ASCII consciousness visualization"""
	if event.is_action_pressed("ui_accept"):  # Space key
		print("🖥️ Rendering ASCII 3D Consciousness Frame...")
		if ascii_visualizer:
			var current_time = Time.get_ticks_msec() * 0.001
			var camera_pos = Vector3(sin(current_time) * 20, 10, cos(current_time) * 20)
			var frame = ascii_visualizer.render_consciousness_frame(camera_pos)
			ascii_visualizer.print_ascii_frame(frame)

func _get_class_info():
	print("🌟 ConsciousnessRevolution: Fixed and ready - THE INVISIBLE BECOMES VISIBLE!")