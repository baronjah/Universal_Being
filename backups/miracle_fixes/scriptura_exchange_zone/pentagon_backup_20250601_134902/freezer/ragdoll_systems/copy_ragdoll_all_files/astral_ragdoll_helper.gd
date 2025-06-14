# ==================================================
# SCRIPT NAME: astral_ragdoll_helper.gd
# DESCRIPTION: Makes astral beings actively help ragdoll walk
# PURPOSE: Coordinate astral beings to support ragdoll movement
# CREATED: 2025-05-24 - Astral assistance system
# ==================================================

extends Node

# ================================
# PROPERTIES
# ================================

var active_helpers: Array = []
var ragdoll_target: Node3D = null
var is_helping: bool = false

# Helper positions relative to ragdoll
var helper_positions = [
	Vector3(-1.0, 1.0, 0),    # Left side
	Vector3(1.0, 1.0, 0),     # Right side
	Vector3(0, 1.5, -1.0),    # Behind
	Vector3(0, 2.0, 1.0)      # Front above
]

# ================================
# INITIALIZATION
# ================================

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	set_process(false)  # Only process when helping

# ================================
# HELPER MANAGEMENT
# ================================

func start_helping_ragdoll() -> void:
	print("[AstralHelper] Starting ragdoll assistance...")
	
	# Find ragdoll
	ragdoll_target = _find_ragdoll()
	if not ragdoll_target:
		print("[AstralHelper] No ragdoll found to help")
		return
	
	# Find astral beings
	var astral_beings = get_tree().get_nodes_in_group("astral_beings")
	if astral_beings.is_empty():
		print("[AstralHelper] No astral beings found")
		return
	
	# Assign helpers
	active_helpers.clear()
	for i in range(min(astral_beings.size(), helper_positions.size())):
		var being = astral_beings[i]
		active_helpers.append(being)
		
		# Set the being to assist mode
		if being.has_method("start_assisting"):
			being.start_assisting(ragdoll_target, 0)  # 0 = RAGDOLL_SUPPORT
			
	is_helping = true
	set_process(true)
	print("[AstralHelper] " + str(active_helpers.size()) + " astral beings now helping ragdoll")

func stop_helping() -> void:
	is_helping = false
	set_process(false)
	
	# Release helpers
	for being in active_helpers:
		if being and being.has_method("set_movement_mode"):
			being.set_movement_mode(0)  # FREE_FLIGHT
			
	active_helpers.clear()
	print("[AstralHelper] Stopped helping ragdoll")

# ================================
# PHYSICS PROCESS
# ================================

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	if not is_helping or not ragdoll_target:
		return
		
	# Get ragdoll body
	var ragdoll_body = null
	if ragdoll_target.has_method("get_body"):
		ragdoll_body = ragdoll_target.get_body()
	elif ragdoll_target.get("ragdoll_body"):
		ragdoll_body = ragdoll_target.ragdoll_body
		if ragdoll_body and ragdoll_body.has_method("get_body"):
			ragdoll_body = ragdoll_body.get_body()
	
	if not ragdoll_body:
		return
		
	# Position helpers around ragdoll
	for i in range(active_helpers.size()):
		var being = active_helpers[i]
		if not being or not is_instance_valid(being):
			continue
			
		var target_pos = ragdoll_body.global_position + helper_positions[i]
		
		# Make beings hover around target positions
		if being.has_property("hover_center"):
			being.hover_center = target_pos
		
		# Apply gentle upward force if ragdoll is falling
		if ragdoll_body.has_method("get_linear_velocity"):
			var velocity = ragdoll_body.get_linear_velocity()
			if velocity.y < -3.0:  # Falling fast
				if ragdoll_body.has_method("apply_central_impulse"):
					ragdoll_body.apply_central_impulse(Vector3(0, 1.5, 0))
					
					# Visual feedback from being
					if being.has_method("speak"):
						if randf() < 0.1:  # Don't spam
							being.speak("I've got you!")

# ================================
# UTILITY FUNCTIONS
# ================================

func _find_ragdoll() -> Node3D:
	# Try multiple methods to find ragdoll
	
	# Method 1: Look for RagdollController
	var controller = get_node_or_null("/root/RagdollController")
	if controller:
		return controller
		
	# Method 2: Search in main scene
	var main_scene = get_tree().current_scene
	if main_scene:
		var ragdoll = main_scene.get_node_or_null("RagdollController")
		if ragdoll:
			return ragdoll
			
		# Method 3: Search by group
		var ragdolls = get_tree().get_nodes_in_group("ragdoll")
		if not ragdolls.is_empty():
			return ragdolls[0]
			
		# Method 4: Search spawned ragdolls
		var spawned = get_tree().get_nodes_in_group("spawned_ragdoll")
		if not spawned.is_empty():
			return spawned[0]
	
	return null

# ================================
# PUBLIC METHODS
# ================================

func toggle_help() -> void:
	if is_helping:
		stop_helping()
	else:
		start_helping_ragdoll()

func assign_specific_being(being: Node3D) -> void:
	if not being in active_helpers:
		active_helpers.append(being)
		if being.has_method("start_assisting") and ragdoll_target:
			being.start_assisting(ragdoll_target, 0)  # RAGDOLL_SUPPORT