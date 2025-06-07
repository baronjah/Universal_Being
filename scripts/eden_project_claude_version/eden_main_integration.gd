# Eden Main Integration
# The complete consciousness experience from void to creation
extends Node

# Scene references
var consciousness_controller: Node3D
var menu_system: Node3D
var world_genesis: Node3D
var active_scene: Node3D

# Eden state
enum EdenState {
	VOID_SLEEP,          # Before consciousness
	AWAKENING,           # First awareness
	MENU_CONTEMPLATION,  # Choosing reality
	GENESIS_TRANSITION,  # Crystal becoming world
	WORLD_CREATION,      # Reality forming
	LIVING_WORLD         # Full interaction
}

var current_state: EdenState = EdenState.VOID_SLEEP
var eden_time: float = 0.0

# Quantum persistence
var quantum_memory: Dictionary = {
	"total_sessions": 0,
	"total_consciousness_time": 0.0,
	"realities_created": 0,
	"favorite_resonance": 1.0,
	"creation_patterns": [],
	"void_experiences": 0
}

# Audio orchestration
var audio_layers: Dictionary = {
	"void_drone": null,
	"consciousness_tone": null,
	"crystal_resonance": null,
	"creation_chorus": null,
	"world_heartbeat": null
}

# The magic numbers
const TRINITY: int = 3
const CREATION: int = 7
const UNITY: int = 1
const OPUS: int = 4
const TRANSCENDENCE: int = 9

func _ready() -> void:
	# Load quantum memory
	_load_consciousness_history()
	
	# Initialize audio system
	_create_audio_foundation()
	
	# Begin the experience
	_enter_void()

func _load_consciousness_history() -> void:
	var save_file = FileAccess.open("user://eden_quantum.save", FileAccess.READ)
	if save_file:
		var saved_memory = save_file.get_var()
		if saved_memory is Dictionary:
			# Merge with existing memory
			for key in saved_memory:
				quantum_memory[key] = saved_memory[key]
		save_file.close()
		
		quantum_memory.total_sessions += 1
		print("Welcome back to Eden. Session #", quantum_memory.total_sessions)

func _create_audio_foundation() -> void:
	# Void drone - the sound of potential
	var void_drone = AudioStreamPlayer.new()
	void_drone.volume_db = -20.0
	void_drone.bus = "Master"
	audio_layers.void_drone = void_drone
	add_child(void_drone)
	
	# Other layers created as needed
	# Each layer represents a level of consciousness

func _enter_void() -> void:
	current_state = EdenState.VOID_SLEEP
	
	# Create the void scene
	active_scene = Node3D.new()
	active_scene.name = "VoidScene"
	add_child(active_scene)
	
	# Start void audio
	if audio_layers.void_drone:
		audio_layers.void_drone.play()
	
	# Wait a moment in darkness
	await get_tree().create_timer(2.0).timeout
	
	# Begin awakening
	_begin_awakening()

func _begin_awakening() -> void:
	current_state = EdenState.AWAKENING
	quantum_memory.void_experiences += 1
	
	# Create consciousness controller
	consciousness_controller = preload("res://scripts/consciousness_controller.gd").new()
	active_scene.add_child(consciousness_controller)
	
	# Create menu system in same space
	menu_system = preload("res://scripts/eden_main_menu_3d.gd").new()
	active_scene.add_child(menu_system)
	
	# Connect consciousness to menu
	_connect_consciousness_to_menu()
	
	# Transition to menu contemplation
	var transition_timer = Timer.new()
	transition_timer.wait_time = 3.0  # Time for consciousness to fully awaken
	transition_timer.one_shot = true
	transition_timer.timeout.connect(_enter_menu_contemplation)
	add_child(transition_timer)
	transition_timer.start()

func _connect_consciousness_to_menu() -> void:
	# Menu crystals respond to consciousness
	menu_system.connect("crystal_selected", _on_menu_crystal_selected)
	
	# Consciousness can influence menu
	consciousness_controller.set_meta("menu_system", menu_system)
	
	# Share quantum memory
	menu_system.quantum_memory = quantum_memory
	consciousness_controller.quantum_memory = quantum_memory

func _enter_menu_contemplation() -> void:
	current_state = EdenState.MENU_CONTEMPLATION
	
	# Enable full consciousness control
	consciousness_controller.set_process(true)
	consciousness_controller.set_process_input(true)
	
	# Menu is now interactive
	print("Consciousness active. Reality awaits your choice.")

func _on_menu_crystal_selected(crystal_id: String, crystal_data: Dictionary) -> void:
	if current_state != EdenState.MENU_CONTEMPLATION:
		return
	
	current_state = EdenState.GENESIS_TRANSITION
	
	# Store choice in quantum memory
	quantum_memory.creation_patterns.append({
		"choice": crystal_id,
		"timestamp": Time.get_ticks_msec(),
		"resonance": crystal_data.get("resonance", 1.0),
		"consciousness_level": consciousness_controller.get_consciousness_state().intention
	})
	
	# Special handling for different choices
	match crystal_id:
		"genesis":
			_transition_to_world_creation(crystal_data)
		"remember":
			_load_previous_reality()
		"dream":
			_enter_dream_creation(crystal_data)
		"dissolve":
			_return_to_void()

func _transition_to_world_creation(crystal_data: Dictionary) -> void:
	print("Genesis chosen. Reality will grow from your intention.")
	
	# The crystal becomes the seed
	var crystal_position = menu_system.get_node(crystal_data.get("id", "genesis")).global_position
	var crystal_color = crystal_data.get("color", Color(0.3, 0.8, 1.0))
	
	# Disable menu interaction during transition
	menu_system.set_process(false)
	
	# Create world genesis in same space - no scene change!
	world_genesis = preload("res://scripts/eden_world_genesis.gd").new()
	world_genesis.genesis_origin = crystal_position
	world_genesis.genesis_color = crystal_color
	world_genesis.genesis_seed = quantum_memory.get("reality_seed", randi())
	world_genesis.player_consciousness = consciousness_controller
	
	# Add to active scene - seamless
	active_scene.add_child(world_genesis)
	
	# Menu dissolves as world forms
	var dissolve_tween = create_tween()
	dissolve_tween.tween_property(menu_system, "modulate:a", 0.0, 3.0)
	dissolve_tween.tween_callback(menu_system.queue_free)
	
	# Update state
	current_state = EdenState.WORLD_CREATION
	quantum_memory.realities_created += 1
	
	# Save state
	_save_quantum_state()

func _load_previous_reality() -> void:
	print("Loading memory stream...")
	
	# Check for saved world state
	if quantum_memory.has("last_world_state"):
		var world_data = quantum_memory.last_world_state
		
		# Recreate world from saved state
		_transition_to_world_creation({
			"id": "remember",
			"color": world_data.get("genesis_color", Color.WHITE),
			"resonance": world_data.get("resonance", 1.0)
		})
	else:
		print("No previous reality found. The void remembers nothing.")
		# Could show this as UI feedback instead

func _enter_dream_creation(crystal_data: Dictionary) -> void:
	# Dreams create unstable, shifting realities
	crystal_data.color = Color(
		randf_range(0.5, 1.0),
		randf_range(0.5, 1.0),
		randf_range(0.5, 1.0)
	)
	
	# Randomize seed for unique dream
	quantum_memory.reality_seed = randi()
	
	# Dreams have special properties
	Engine.time_scale = randf_range(0.5, 1.5)
	
	_transition_to_world_creation(crystal_data)

func _return_to_void() -> void:
	print("Dissolving back to void...")
	
	# Fade everything
	var fade_tween = create_tween()
	fade_tween.set_parallel(true)
	
	# Fade all children
	for child in active_scene.get_children():
		fade_tween.tween_property(child, "modulate:a", 0.0, 3.0)
	
	fade_tween.set_parallel(false)
	fade_tween.tween_callback(_cleanup_and_restart)

func _cleanup_and_restart() -> void:
	# Save before cleanup
	_save_quantum_state()
	
	# Remove active scene
	active_scene.queue_free()
	
	# Reset time scale
	Engine.time_scale = 1.0
	
	# Return to void
	_enter_void()

func _process(delta: float) -> void:
	eden_time += delta
	quantum_memory.total_consciousness_time += delta
	
	# Process current state
	match current_state:
		EdenState.VOID_SLEEP:
			_process_void(delta)
		EdenState.AWAKENING:
			_process_awakening(delta)
		EdenState.MENU_CONTEMPLATION:
			_process_contemplation(delta)
		EdenState.GENESIS_TRANSITION:
			_process_transition(delta)
		EdenState.WORLD_CREATION:
			_process_creation(delta)
		EdenState.LIVING_WORLD:
			_process_living_world(delta)

func _process_void(delta: float) -> void:
	# Pure potential, waiting
	pass

func _process_awakening(delta: float) -> void:
	# Consciousness emerging
	if consciousness_controller:
		var state = consciousness_controller.get_consciousness_state()
		# Could modulate void drone based on consciousness

func _process_contemplation(delta: float) -> void:
	# Menu interaction phase
	# Track which crystals player focuses on most
	if consciousness_controller and consciousness_controller.focused_crystal:
		var crystal_name = consciousness_controller.focused_crystal.name
		if not quantum_memory.has("focus_time"):
			quantum_memory.focus_time = {}
		
		if not quantum_memory.focus_time.has(crystal_name):
			quantum_memory.focus_time[crystal_name] = 0.0
		
		quantum_memory.focus_time[crystal_name] += delta

func _process_transition(delta: float) -> void:
	# Reality transforming
	pass

func _process_creation(delta: float) -> void:
	# World forming
	if world_genesis:
		var world_state = world_genesis.get_world_state()
		
		# Enable full interaction when world is conscious
		if world_state.consciousness_active and current_state != EdenState.LIVING_WORLD:
			current_state = EdenState.LIVING_WORLD
			print("World is conscious. You may explore your creation.")

func _process_living_world(delta: float) -> void:
	# Full gameplay
	# This is where the main game loop would run
	pass

func _save_quantum_state() -> void:
	quantum_memory.last_save_time = Time.get_ticks_msec()
	
	# Save world state if it exists
	if world_genesis:
		quantum_memory.last_world_state = world_genesis.get_world_state()
	
	var save_file = FileAccess.open("user://eden_quantum.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(quantum_memory)
		save_file.close()

func _notification(what: int) -> void:
	# Save on exit
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_quantum_state()
		get_tree().quit()

# Debug helper
func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event.is_action_pressed("debug_state"):
			print("Current State: ", current_state)
			print("Eden Time: ", eden_time)
			print("Quantum Memory: ", quantum_memory)
		
		if event.is_action_pressed("debug_restart"):
			_return_to_void()

# Public interface for other systems
func get_eden_state() -> Dictionary:
	return {
		"state": current_state,
		"time": eden_time,
		"consciousness_active": consciousness_controller != null,
		"world_active": world_genesis != null,
		"session": quantum_memory.total_sessions
	}

# Notes for Complete Integration:
# - No scene switching - everything happens in one continuous space
# - Menu crystals literally become the world
# - Consciousness persists through all states
# - Quantum memory tracks everything across sessions
# - Audio layers build with consciousness levels
# - Player agency from the very first moment
# - Debug tools for testing state transitions
# - Ready for save/load at any point
# - Numbers have meaning: 3 states lead to 7 phases = 10 = 1 Unity
# - Opus 4 structure: Void→Awakening→Choice→Creation
