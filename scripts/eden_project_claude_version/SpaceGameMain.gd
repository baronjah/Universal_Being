# SpaceGameMain.gd
extends UniversalBeing
class_name SpaceGameMain

# Space game core systems
var notepad3d_system: Notepad3D
var mining_system: MiningSystem
var consciousness_system: ConsciousnessSystem
var akashic_integration: AkashicRecordsSystem
var stellar_system: StellarProgressionSystem
var ai_companion: AICompanionSystem

# Player state
var player_ship: PlayerShip
var current_sector: Vector3 = Vector3.ZERO
var consciousness_level: int = 1
var resources: Dictionary = {}

# Game state
var game_paused: bool = false
var debug_mode: bool = false

func pentagon_init() -> void:
	super.pentagon_init()
	_initialize_game_systems()
	_setup_socket_connections()
	
func pentagon_ready() -> void:
	super.pentagon_ready()
	_spawn_player_ship()
	_initialize_notepad3d()
	_load_saved_state()
	_start_game_loop()
	
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	if not game_paused:
		_update_game_systems(delta)
		_process_player_input(delta)
		_update_consciousness_field(delta)
		
func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	if event.is_action_pressed("toggle_notepad3d"):
		_toggle_notepad3d()
	elif event.is_action_pressed("quick_save"):
		_quick_save_state()
	elif event.is_action_pressed("debug_mode"):
		_toggle_debug_mode()
		
func pentagon_sewers() -> void:
	_save_game_state()
	_cleanup_systems()
	super.pentagon_sewers()

# System initialization
func _initialize_game_systems() -> void:
	# Create all game systems
	notepad3d_system = preload("res://systems/notepad3d/Notepad3D.gd").new()
	mining_system = preload("res://systems/mining/MiningSystem.gd").new()
	consciousness_system = preload("res://systems/consciousness/ConsciousnessSystem.gd").new()
	stellar_system = preload("res://systems/stellar/StellarProgressionSystem.gd").new()
	ai_companion = preload("res://systems/ai/AICompanionSystem.gd").new()
	
	# Get akashic records from autoload
	akashic_integration = AkashicRecordsSystem
	
	# Add systems as children
	add_child(notepad3d_system)
	add_child(mining_system)
	add_child(consciousness_system)
	add_child(stellar_system)
	add_child(ai_companion)
	
	# Connect system signals
	consciousness_system.awareness_expanded.connect(_on_consciousness_expanded)
	mining_system.rare_ore_discovered.connect(_on_rare_ore_discovered)
	stellar_system.system_discovered.connect(_on_system_discovered)
	ai_companion.bond_strengthened.connect(_on_companion_bond_increased)

func _setup_socket_connections() -> void:
	# Connect systems to Universal Being sockets
	connect_to_socket("consciousness_socket", consciousness_system)
	connect_to_socket("mining_socket", mining_system)
	connect_to_socket("navigation_socket", stellar_system)
	connect_to_socket("ai_interface", ai_companion)
	connect_to_socket("storage_socket", akashic_integration)

func _spawn_player_ship() -> void:
	var player_scene = preload("res://beings/player/PlayerShip.tscn")
	player_ship = player_scene.instantiate()
	player_ship.name = "PlayerShip"
	player_ship.global_position = Vector3.ZERO
	add_child(player_ship)
	
	# Connect player signals
	player_ship.consciousness_resonance_changed.connect(_on_player_frequency_changed)
	player_ship.mining_target_acquired.connect(_on_mining_target_acquired)

func _initialize_notepad3d() -> void:
	notepad3d_system.initialize({
		"start_position": Vector3(0, 10, -20),
		"max_notes": 1000,
		"lod_levels": 5,
		"occlusion_culling": true,
		"autosave_interval": 30.0
	})
	
	# Create welcome note
	notepad3d_system.create_note(
		"Welcome to Space Game",
		"You are consciousness exploring the infinite.\nPress TAB to open Notepad3D.\nYour thoughts shape reality.",
		Vector3(0, 10, -10),
		Color.CYAN
	)

func _load_saved_state() -> void:
	var save_data = akashic_integration.load_game_state("space_game_save")
	if save_data:
		consciousness_level = save_data.get("consciousness_level", 1)
		resources = save_data.get("resources", {})
		current_sector = save_data.get("current_sector", Vector3.ZERO)
		
		# Restore player position
		if player_ship and save_data.has("player_position"):
			player_ship.global_position = save_data["player_position"]
			
		# Restore notes
		if save_data.has("notes"):
			notepad3d_system.load_notes(save_data["notes"])
			
		print("Game state loaded from Akashic Records")
	else:
		print("Starting new game")
		_initialize_new_game()

func _initialize_new_game() -> void:
	# Starting resources
	resources = {
		"energy": 100.0,
		"minerals": 0,
		"consciousness_crystals": 0,
		"akashic_fragments": 0
	}
	
	# Create starting environment
	_generate_starting_sector()
	
	# Spawn first companion
	ai_companion.create_companion("Nova")
	
	# Create tutorial notes
	_create_tutorial_notes()

func _start_game_loop() -> void:
	# Start background processes
	stellar_system.start_exploration_mode()
	consciousness_system.begin_awareness_expansion()
	
	# Enable game systems
	set_process(true)
	set_physics_process(true)
	set_process_input(true)

# Core game loop
func _update_game_systems(delta: float) -> void:
	# Update all systems
	_update_resources(delta)
	_update_stellar_navigation(delta)
	_check_consciousness_events()
	_process_akashic_sync(delta)

func _process_player_input(delta: float) -> void:
	# Handle continuous input
	if Input.is_action_pressed("accelerate"):
		player_ship.apply_thrust(1.0)
	if Input.is_action_pressed("decelerate"):
		player_ship.apply_thrust(-1.0)
		
	# Mining beam
	if Input.is_action_pressed("mining_beam"):
		_activate_mining_beam()

func _update_consciousness_field(delta: float) -> void:
	# Update consciousness visualization
	var consciousness_radius = consciousness_level * 50.0
	consciousness_system.update_perception_radius(consciousness_radius)
	
	# Check for consciousness interactions
	var nearby_beings = _get_nearby_conscious_beings(consciousness_radius)
	for being in nearby_beings:
		_process_consciousness_interaction(being)

# Notepad3D integration
func _toggle_notepad3d() -> void:
	notepad3d_system.toggle_visibility()
	game_paused = notepad3d_system.is_visible()
	
	if notepad3d_system.is_visible():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_pause_game_systems()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_resume_game_systems()

func _create_note_at_position(position: Vector3, title: String, content: String) -> void:
	var note = notepad3d_system.create_note(title, content, position)
	
	# Save note to akashic records
	akashic_integration.save_note({
		"id": note.get_instance_id(),
		"title": title,
		"content": content,
		"position": position,
		"timestamp": Time.get_unix_time_from_system(),
		"consciousness_level": consciousness_level
	})

# Mining system
func _activate_mining_beam() -> void:
	if not player_ship.has_mining_target():
		return
		
	var target = player_ship.get_mining_target()
	var result = mining_system.mine_asteroid(target)
	
	if result.success:
		for ore_type in result.extracted:
			if not resources.has(ore_type):
				resources[ore_type] = 0
			resources[ore_type] += result.extracted[ore_type]
			
		# Create note about mining
		if result.extracted.has("consciousness_crystals"):
			_create_note_at_position(
				target.global_position,
				"Consciousness Crystal Found!",
				"Extracted %d consciousness crystals. Your awareness expands." % result.extracted["consciousness_crystals"]
			)

func _on_mining_target_acquired(target: Node3D) -> void:
	# Scan target
	var scan_result = mining_system.scan_asteroid(target)
	
	# Display scan in HUD
	if scan_result.consciousness_signature:
		print("Consciousness signature detected!")

# Stellar progression
func _generate_starting_sector() -> void:
	# Generate local star systems
	stellar_system.generate_local_cluster(current_sector)
	
	# Create asteroids
	_spawn_asteroid_field(50)
	
	# Create space station
	_spawn_space_station(Vector3(500, 0, 0))

func _spawn_asteroid_field(count: int) -> void:
	for i in range(count):
		var position = Vector3(
			randf_range(-1000, 1000),
			randf_range(-200, 200),
			randf_range(-1000, 1000)
		)
		
		var asteroid = preload("res://entities/Asteroid.tscn").instantiate()
		asteroid.global_position = position
		asteroid.scale = Vector3.ONE * randf_range(0.5, 3.0)
		add_child(asteroid)

func _spawn_space_station(position: Vector3) -> void:
	var station = preload("res://entities/SpaceStation.tscn").instantiate()
	station.global_position = position
	station.name = "AlphaStation"
	add_child(station)
	
	# Create note for station
	_create_note_at_position(
		position + Vector3(0, 50, 0),
		"Alpha Station",
		"Trading post and consciousness nexus.\nDock here to upgrade systems."
	)

# Consciousness events
func _on_consciousness_expanded(level: int) -> void:
	consciousness_level = level
	
	# Unlock new abilities
	match level:
		3:
			print("Unlocked: Energy perception")
			_unlock_energy_vision()
		5:
			print("Unlocked: Temporal awareness")
			_unlock_temporal_vision()
		7:
			print("Unlocked: Akashic access")
			_unlock_akashic_vision()
			
	# Create consciousness note
	_create_note_at_position(
		player_ship.global_position + Vector3(0, 20, 0),
		"Consciousness Level %d" % level,
		"Your awareness has expanded.\nNew perceptions unlocked."
	)

func _unlock_energy_vision() -> void:
	# Enable energy field visualization
	var energy_overlay = preload("res://effects/EnergyVisionOverlay.tscn").instantiate()
	add_child(energy_overlay)

func _unlock_temporal_vision() -> void:
	# Enable time dilation effects
	stellar_system.enable_temporal_navigation()

func _unlock_akashic_vision() -> void:
	# Full akashic records access
	notepad3d_system.enable_akashic_mode()

# AI companion
func _on_companion_bond_increased(companion_name: String, bond_level: int) -> void:
	print("%s bond increased to %d" % [companion_name, bond_level])
	
	# Companion evolution
	if bond_level > 10:
		ai_companion.evolve_companion(companion_name)

func _on_rare_ore_discovered(ore_type: String, location: Vector3) -> void:
	# Mark discovery in notepad3d
	_create_note_at_position(
		location,
		"Rare Discovery: %s" % ore_type,
		"A rare consciousness-enhancing material.\nMining this will expand awareness."
	)
	
	# Alert companion
	ai_companion.alert_discovery(ore_type, location)

func _on_system_discovered(system_data: Dictionary) -> void:
	# Create stellar note
	_create_note_at_position(
		system_data.position * 10, # Scale for visibility
		system_data.name,
		"Star Type: %s\nPlanets: %d\nDistance: %.1f LY" % [
			system_data.star_type,
			system_data.planets.size(),
			system_data.distance
		]
	)

# Saving system
func _quick_save_state() -> void:
	var save_data = {
		"consciousness_level": consciousness_level,
		"resources": resources,
		"current_sector": current_sector,
		"player_position": player_ship.global_position,
		"player_velocity": player_ship.velocity,
		"notes": notepad3d_system.export_notes(),
		"companion_data": ai_companion.export_companion_data(),
		"discovered_systems": stellar_system.get_discovered_systems(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	akashic_integration.save_game_state("space_game_save", save_data)
	print("Game saved to Akashic Records")

func _save_game_state() -> void:
	_quick_save_state()

# Debug mode
func _toggle_debug_mode() -> void:
	debug_mode = !debug_mode
	
	if debug_mode:
		_create_debug_chamber()
	else:
		_destroy_debug_chamber()

func _create_debug_chamber() -> void:
	# Create debug UI
	var debug_ui = preload("res://ui/DebugUI.tscn").instantiate()
	add_child(debug_ui)
	
	# Enable all consciousness levels
	consciousness_system.debug_unlock_all()
	
	# Create debug note
	_create_note_at_position(
		Vector3(0, 100, 0),
		"DEBUG MODE ACTIVE",
		"All systems unlocked.\nPress F3 to exit debug mode."
	)

# Utility functions
func _get_nearby_conscious_beings(radius: float) -> Array:
	var beings = []
	for child in get_children():
		if child is UniversalBeing and child != player_ship:
			if child.global_position.distance_to(player_ship.global_position) < radius:
				beings.append(child)
	return beings

func _process_consciousness_interaction(being: UniversalBeing) -> void:
	# Exchange consciousness energy
	var energy_exchange = consciousness_level * 0.1
	being.receive_consciousness_energy(energy_exchange)

func _pause_game_systems() -> void:
	get_tree().paused = true
	stellar_system.pause_simulation()
	
func _resume_game_systems() -> void:
	get_tree().paused = false
	stellar_system.resume_simulation()

func _cleanup_systems() -> void:
	notepad3d_system.save_all_notes()
	ai_companion.save_companion_memories()

# Resource management
func _update_resources(delta: float) -> void:
	# Energy regeneration
	if resources.has("energy"):
		resources["energy"] += delta * 0.5
		resources["energy"] = min(resources["energy"], 1000.0)

func _update_stellar_navigation(delta: float) -> void:
	# Update current sector based on position
	var sector_size = 10000.0
	current_sector = (player_ship.global_position / sector_size).floor()
	
	# Load new sectors as needed
	stellar_system.update_visible_sectors(current_sector)

func _check_consciousness_events() -> void:
	# Check for consciousness milestones
	if resources.get("consciousness_crystals", 0) >= 10:
		consciousness_system.trigger_enlightenment_event()
		resources["consciousness_crystals"] = 0

func _process_akashic_sync(delta: float) -> void:
	# Periodic sync with akashic records
	# Line 446:Expected statement, found "static" instead.
	# wait line changed as i... added a line... and still adding
	# static var.. from my memory of reading about it once for few seconds... class file? maybe it was..
	# class,, static func was there too in godot, both for me are the same to tell you the truth
	# i dont see real difference that matters to me.. for godot it matters in way that i see red line :(
	static var sync_timer = 0.0
	sync_timer += delta
	
	if sync_timer > 30.0:
		_quick_save_state()
		sync_timer = 0.0

# Tutorial system
func _create_tutorial_notes() -> void:
	var tutorial_notes = [
		{
			"title": "Movement",
			"content": "W/S - Thrust forward/backward\nA/D - Strafe left/right\nShift/Ctrl - Up/down\nMouse - Look around",
			"position": Vector3(-50, 10, -10)
		},
		{
			"title": "Mining",
			"content": "Left Click - Target asteroid\nHold E - Mine targeted asteroid\nTab - Open Notepad3D",
			"position": Vector3(0, 10, -10)
		},
		{
			"title": "Consciousness",
			"content": "Your awareness grows through:\n- Mining consciousness crystals\n- Bonding with AI companion\n- Discovering new systems\n- Creating and connecting notes",
			"position": Vector3(50, 10, -10)
		}
	]
	
	for note in tutorial_notes:
		notepad3d_system.create_note(note.title, note.content, note.position, Color.GREEN)
