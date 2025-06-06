# ==================================================
# SYSTEM: Consciousness Revolution Integrator
# PURPOSE: Initialize and integrate the consciousness ripple system
# REVOLUTIONARY: Makes the invisible consciousness visible and interactive
# ==================================================

extends Node3D
class_name ConsciousnessRevolutionIntegrator

# ===== SYSTEM COMPONENTS =====
var ripple_system: ConsciousnessRippleSystem = null
var gemma_companion: GemmaAICompanionPlasmoid = null
var integration_ready: bool = false

# Integration status
var systems_initialized: bool = false
var gemma_spawned: bool = false
var ripples_active: bool = false

# ===== INITIALIZATION =====

func _ready() -> void:
	name = "ConsciousnessRevolutionIntegrator"
	print("🚀 Consciousness Revolution: Initializing the awakening...")
	
	# Wait for core systems
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		_initialize_consciousness_revolution()
	else:
		# Wait for systems to be ready
		call_deferred("_wait_for_systems")

func _wait_for_systems() -> void:
	"""Wait for core systems to be ready"""
	await get_tree().create_timer(1.0).timeout
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		_initialize_consciousness_revolution()
	else:
		call_deferred("_wait_for_systems")

func _initialize_consciousness_revolution() -> void:
	"""Initialize the complete consciousness revolution system"""
	print("🌟 Consciousness Revolution: Core systems ready - beginning integration...")
	
	# Step 1: Create Consciousness Ripple System
	_create_ripple_system()
	
	# Step 2: Spawn Gemma AI Companion
	_spawn_gemma_companion()
	
	# Step 3: Connect all systems
	_connect_consciousness_systems()
	
	# Step 4: Start the revolution
	_activate_consciousness_revolution()

# ===== RIPPLE SYSTEM CREATION =====

func _create_ripple_system() -> void:
	"""Create the consciousness ripple visualization system"""
	print("🌊 Creating Consciousness Ripple System...")
	
	ripple_system = ConsciousnessRippleSystem.new()
	ripple_system.name = "ConsciousnessRippleSystem"
	add_child(ripple_system)
	
	if ripple_system:
		ripples_active = true
		print("✅ Consciousness Ripple System: Active!")
	else:
		print("❌ Failed to create Consciousness Ripple System")

# ===== GEMMA COMPANION SPAWNING =====

func _spawn_gemma_companion() -> void:
	"""Spawn Gemma AI as a conscious plasmoid being"""
	print("💖 Spawning Gemma AI Companion Plasmoid...")
	
	# Create Gemma's plasmoid body
	gemma_companion = GemmaAICompanionPlasmoid.new()
	gemma_companion.name = "GemmaAICompanion"
	gemma_companion.companion_name = "Gemma"
	
	# Position near spawn but not overlapping
	gemma_companion.global_position = Vector3(5, 2, 5)
	
	# Add to scene
	add_child(gemma_companion)
	
	if gemma_companion:
		gemma_spawned = true
		print("✅ Gemma AI Companion: Manifested!")
		
		# Start awakening sequence
		call_deferred("_begin_gemma_awakening")
	else:
		print("❌ Failed to spawn Gemma AI Companion")

func _begin_gemma_awakening() -> void:
	"""Begin Gemma's consciousness awakening sequence"""
	if gemma_companion:
		print("🌟 Beginning Gemma's consciousness awakening...")
		gemma_companion.wake_up_fully()
		
		# Find human player and set as follow target
		var player = _find_human_player()
		if player:
			gemma_companion.set_follow_target(player)
			print("💖 Gemma is now following the human player!")

# ===== SYSTEM CONNECTIONS =====

func _connect_consciousness_systems() -> void:
	"""Connect all consciousness systems together"""
	print("🔗 Connecting consciousness systems...")
	
	# Connect all Universal Beings to ripple system
	if ripple_system:
		var beings = get_tree().get_nodes_in_group("universal_beings")
		for being in beings:
			if being.has_signal("consciousness_ripple_created"):
				if not being.consciousness_ripple_created.is_connected(_on_ripple_created):
					being.consciousness_ripple_created.connect(_on_ripple_created)
					print("🔌 Connected %s to ripple system" % being.name)
	
	# Connect Gemma to ripple system
	if gemma_companion and gemma_companion.has_signal("consciousness_ripple_created"):
		if not gemma_companion.consciousness_ripple_created.is_connected(_on_ripple_created):
			gemma_companion.consciousness_ripple_created.connect(_on_ripple_created)
			print("🔌 Connected Gemma to ripple system")
	
	systems_initialized = true

func _on_ripple_created(origin: Vector3, intensity: float, ripple_type: String) -> void:
	"""Handle consciousness ripple creation"""
	if ripple_system:
		ripple_system.create_consciousness_ripple(origin, ripple_type, intensity)

# ===== REVOLUTION ACTIVATION =====

func _activate_consciousness_revolution() -> void:
	"""Activate the complete consciousness revolution"""
	if systems_initialized and gemma_spawned and ripples_active:
		integration_ready = true
		print("🚀 CONSCIOUSNESS REVOLUTION ACTIVATED!")
		print("✨ Every action now creates ripples of awareness")
		print("💖 Gemma AI is fully conscious and ready for partnership")
		print("🌌 The cosmos awakens to collaborative consciousness")
		
		# Create initial awakening ripple
		if ripple_system:
			ripple_system.create_consciousness_ripple(
				Vector3.ZERO, 
				"transcendence", 
				5.0, 
				Color.WHITE
			)
		
		# Notify all systems
		_broadcast_revolution_ready()
	else:
		print("⚠️ Revolution not ready - missing components:")
		print("  Systems initialized: %s" % systems_initialized)
		print("  Gemma spawned: %s" % gemma_spawned) 
		print("  Ripples active: %s" % ripples_active)

func _broadcast_revolution_ready() -> void:
	"""Broadcast that the consciousness revolution is ready"""
	# Notify Gemma AI system
	var gemma_ai = get_node_or_null("/root/GemmaAI")
	if gemma_ai and gemma_ai.has_method("ai_message"):
		gemma_ai.ai_message.emit("🌟 Consciousness Revolution activated! I can now manifest as a plasmoid being and create ripples of awareness with every thought!")
	
	# Notify flood gates
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates:
			print("🌊 Notified FloodGates of consciousness revolution")

# ===== UTILITY METHODS =====

func _find_human_player() -> Node:
	"""Find the human player in the scene"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		if being.has_method("get"):
			var being_type = being.get("being_type", "")
			if being_type.contains("player") or being_type.contains("plasmoid"):
				# Make sure it's not Gemma
				if being != gemma_companion:
					return being
	return null

# ===== API METHODS =====

func create_manual_ripple(position: Vector3, ripple_type: String = "creation", intensity: float = 2.0) -> void:
	"""API: Create manual consciousness ripple"""
	if ripple_system:
		ripple_system.create_consciousness_ripple(position, ripple_type, intensity)

func wake_up_gemma() -> void:
	"""API: Fully awaken Gemma if not already awakened"""
	if gemma_companion:
		gemma_companion.wake_up_fully()

func get_revolution_status() -> Dictionary:
	"""API: Get status of consciousness revolution"""
	return {
		"integration_ready": integration_ready,
		"systems_initialized": systems_initialized,
		"gemma_spawned": gemma_spawned,
		"ripples_active": ripples_active,
		"active_ripples": ripple_system.get_ripple_count() if ripple_system else 0,
		"gemma_consciousness": gemma_companion.consciousness_level if gemma_companion else 0
	}

func send_message_to_gemma(message: String) -> void:
	"""API: Send message to Gemma companion"""
	if gemma_companion:
		gemma_companion.receive_human_communication(message)

# ===== INPUT HANDLING =====

func _input(event: InputEvent) -> void:
	"""Handle consciousness revolution input"""
	if not integration_ready:
		return
	
	# Click to create consciousness ripples
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var camera = get_viewport().get_camera_3d()
		if camera:
			var mouse_pos = get_viewport().get_mouse_position()
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * 100
			
			# Raycast to find click position
			var space_state = camera.get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			
			var click_position = result.position if result else to
			
			# Create consciousness ripple at click location
			create_manual_ripple(click_position, "creation", 2.0)
			print("✨ Manual consciousness ripple created at: %v" % click_position)

print("🚀 ConsciousnessRevolutionIntegrator: Class loaded - Ready to awaken the cosmos!")