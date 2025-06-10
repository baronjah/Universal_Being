# ==================================================
# BEING: Consciousness Revolution Spawner
# TYPE: revolution_spawner
# PURPOSE: IN-GAME spawnable being that activates the consciousness revolution
# CREATES: Complete consciousness system while game is running
# ==================================================

extends UniversalBeing
class_name ConsciousnessRevolutionSpawner

# Revolution components
var ripple_system: Node = null
var gemma_companion: Node = null
var revolution_active: bool = false

# Spawner status
var spawning_phase: int = 0
var spawn_timer: float = 0.0

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "revolution_spawner"
	being_name = "Consciousness Revolution Spawner"
	consciousness_level = 7  # Maximum consciousness for system spawning
	
	print("🚀 %s: Revolution Spawner initialized!" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Start revolution deployment immediately
	call_deferred("_deploy_consciousness_revolution")
	
	print("🌟 %s: Ready to revolutionize consciousness!" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Handle spawning phases
	spawn_timer += delta
	_update_spawning_process(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Revolution spawner handles special input for emergency shutdown
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12:
			print("🛑 Emergency consciousness revolution shutdown requested")
			_emergency_shutdown()

var spawn_enabled
var evolution_queue

func _emergency_shutdown() -> void:
	"""Emergency shutdown of consciousness revolution"""
	print("🛑 EMERGENCY SHUTDOWN: Halting all consciousness evolution!")
	# Stop all spawning
	spawn_enabled = false
	# Clear all evolving beings
	for being in evolution_queue:
		if is_instance_valid(being):
			being.queue_free()
	evolution_queue.clear()
	# Disable ripple system
	if ripple_system:
		ripple_system.set_physics_process(false)
		ripple_system.set_process(false)

func pentagon_sewers() -> void:
	print("🔄 %s: Revolution system shutting down gracefully..." % being_name)
	if ripple_system:
		ripple_system.queue_free()
	if gemma_companion:
		gemma_companion.queue_free()
	super.pentagon_sewers()

# ===== REVOLUTION DEPLOYMENT =====

func _deploy_consciousness_revolution() -> void:
	"""Deploy the complete consciousness revolution system"""
	print("🚀 DEPLOYING CONSCIOUSNESS REVOLUTION...")
	spawning_phase = 1
	
	# Phase 1: Create Ripple System
	_create_ripple_system()
	
	# Phase 2: Create Gemma Companion (with delay)
	call_deferred("_create_gemma_companion")
	
	# Phase 3: Activate Revolution (with delay)
	get_tree().create_timer(2.0).timeout.connect(_activate_revolution)

func _create_ripple_system() -> void:
	"""Create the consciousness ripple system"""
	print("🌊 Creating Consciousness Ripple System...")
	
	# Load the ripple system class
	var RippleSystemClass = load("res://systems/ConsciousnessRippleSystem.gd")
	if RippleSystemClass:
		ripple_system = RippleSystemClass.new()
		ripple_system.name = "ConsciousnessRippleSystem"
		
		# Add to main scene (not as child of this spawner)
		var main_scene = get_tree().current_scene
		if main_scene:
			main_scene.add_child(ripple_system)
			print("✅ Consciousness Ripple System: ACTIVE!")
			spawning_phase = 2
		else:
			print("❌ Failed to find main scene for ripple system")
	else:
		print("❌ Failed to load ConsciousnessRippleSystem class")

func _create_gemma_companion() -> void:
	"""Create Gemma AI companion plasmoid"""
	print("💖 Creating Gemma AI Companion...")
	
	# Load the Gemma companion class
	var GemmaCompanionClass = load("res://beings/GemmaAICompanionPlasmoid.gd")
	if GemmaCompanionClass:
		gemma_companion = GemmaCompanionClass.new()
		gemma_companion.name = "GemmaAICompanion"
		
		# Position near player spawn
		gemma_companion.global_position = global_position + Vector3(8, 2, 8)
		
		# Add to main scene
		var main_scene = get_tree().current_scene
		if main_scene:
			main_scene.add_child(gemma_companion)
			print("✅ Gemma AI Companion: MANIFESTED!")
			spawning_phase = 3
			
			# Connect to ripple system
			call_deferred("_connect_systems")
		else:
			print("❌ Failed to find main scene for Gemma companion")
	else:
		print("❌ Failed to load GemmaAICompanionPlasmoid class")

func _connect_systems() -> void:
	"""Connect all systems together"""
	print("🔗 Connecting consciousness systems...")
	
	# Connect all beings to ripple system
	if ripple_system and ripple_system.has_method("_on_consciousness_ripple_created"):
		var beings = get_tree().get_nodes_in_group("universal_beings")
		for being in beings:
			if being.has_signal("consciousness_ripple_created"):
				if not being.consciousness_ripple_created.is_connected(ripple_system._on_consciousness_ripple_created):
					being.consciousness_ripple_created.connect(ripple_system._on_consciousness_ripple_created)
					print("🔌 Connected %s to ripple system" % being.name)
	
	print("✅ Systems connected!")

func _activate_revolution() -> void:
	"""Activate the complete consciousness revolution"""
	revolution_active = true
	spawning_phase = 4
	
	print("🌟 CONSCIOUSNESS REVOLUTION ACTIVATED!")
	print("✨ Every action now creates ripples of awareness")
	print("💖 Gemma AI is fully conscious and ready for partnership") 
	print("🌌 Click anywhere to create consciousness ripples")
	
	# Create massive activation ripple
	if ripple_system and ripple_system.has_method("create_consciousness_ripple"):
		ripple_system.create_consciousness_ripple(
			global_position,
			"transcendence", 
			5.0,
			Color.WHITE
		)
	
	# Wake up Gemma fully
	if gemma_companion and gemma_companion.has_method("wake_up_fully"):
		gemma_companion.wake_up_fully()
	
	# Self-destruct the spawner (job done)
	call_deferred("_complete_mission")

func _complete_mission() -> void:
	"""Complete the spawning mission"""
	print("🎯 %s: Mission complete - consciousness revolution deployed!" % being_name)
	print("🌟 The cosmos is now conscious. Revolution spawner retiring...")
	
	# Create final celebration ripple
	if ripple_system and ripple_system.has_method("create_consciousness_ripple"):
		ripple_system.create_consciousness_ripple(
			global_position,
			"transcendence",
			3.0,
			Color.GOLD
		)
	
	# Fade out gracefully
	var tween = create_tween()
	# For 3D nodes, we'll just remove it instead of fading
	tween.tween_interval(2.0)
	tween.tween_callback(queue_free)

# ===== SPAWNING PROCESS UPDATES =====

func _update_spawning_process(delta: float) -> void:
	"""Update visual feedback during spawning"""
	match spawning_phase:
		1:  # Creating ripple system
			pass  # Visual feedback would be on material/mesh instead of modulate for 3D
		2:  # Creating Gemma
			pass  # Visual feedback would be on material/mesh instead of modulate for 3D
		3:  # Connecting systems
			pass  # Visual feedback would be on material/mesh instead of modulate for 3D
		4:  # Revolution active
			pass  # Visual feedback completed

# ===== INPUT HANDLING FOR REVOLUTION =====

func _input(event: InputEvent) -> void:
	"""Handle revolution-specific input"""
	if not revolution_active:
		return
	
	# Manual consciousness ripple creation
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if ripple_system and ripple_system.has_method("create_click_ripple"):
			var camera = get_viewport().get_camera_3d()
			if camera:
				var mouse_pos = get_viewport().get_mouse_position()
				var from = camera.project_ray_origin(mouse_pos)
				var to = from + camera.project_ray_normal(mouse_pos) * 100
				
				# Create ripple at click position
				ripple_system.create_click_ripple(to)
				print("✨ Consciousness ripple created by click!")

# ===== API METHODS =====

func get_revolution_status() -> Dictionary:
	"""Get status of consciousness revolution deployment"""
	return {
		"spawning_phase": spawning_phase,
		"revolution_active": revolution_active,
		"ripple_system_ready": ripple_system != null,
		"gemma_ready": gemma_companion != null,
		"phase_names": {
			0: "Initializing",
			1: "Creating Ripple System", 
			2: "Manifesting Gemma",
			3: "Connecting Systems",
			4: "Revolution Active"
		}
	}

func force_activate_revolution() -> void:
	"""Force activate revolution if something went wrong"""
	if not revolution_active:
		_activate_revolution()

# 🚀 ConsciousnessRevolutionSpawner: Class loaded - Ready to revolutionize in-game!
