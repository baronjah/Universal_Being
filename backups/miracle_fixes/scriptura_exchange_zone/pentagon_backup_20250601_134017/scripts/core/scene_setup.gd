# ==================================================
# SCRIPT NAME: scene_setup.gd
# DESCRIPTION: Automatically sets up ragdoll controller and astral beings in main scene
# PURPOSE: Ensure proper integration of our new systems
# CREATED: 2025-05-24 - Scene integration helper
# ==================================================

extends UniversalBeingBase
func _ready() -> void:
	print("[SceneSetup] Setting up ragdoll and astral beings systems...")
	
	# Wait a moment for other systems to initialize
	await get_tree().create_timer(1.0).timeout
	
	_setup_ragdoll_system()
	# _setup_astral_beings()  # Disabled - using new talking astral being system
	
	print("[SceneSetup] Scene setup complete!")

func _setup_ragdoll_system() -> void:
	# Check if RagdollController already exists
	if get_node_or_null("../RagdollController"):
		print("[SceneSetup] RagdollController already exists")
		return
	
	# Create RagdollController
	var ragdoll_controller_script = load("res://scripts/core/ragdoll_controller.gd")
	if ragdoll_controller_script:
		var ragdoll_controller = Node3D.new()
		ragdoll_controller.name = "RagdollController"
		ragdoll_controller.set_script(ragdoll_controller_script)
		
		# Add to main scene
		var main_scene = get_tree().current_scene
		if main_scene:
			FloodgateController.universal_add_child(ragdoll_controller, main_scene)
			print("[SceneSetup] RagdollController created and added to scene")
		else:
			print("[SceneSetup] Could not find main scene to add RagdollController")
	else:
		print("[SceneSetup] Could not load ragdoll_controller.gd script")

func _setup_astral_beings() -> void:
	# Check if AstralBeings already exists
	if get_node_or_null("../AstralBeings"):
		print("[SceneSetup] AstralBeings already exists")
		return
	
	# Create AstralBeings
	# var astral_beings_script = load("res://scripts/core/astral_beings.gd")  # OLD SYSTEM
	# if astral_beings_script:
	# 	var astral_beings = Node3D.new()
	# 	astral_beings.name = "AstralBeings"
	# 	astral_beings.set_script(astral_beings_script)
	# 	
	# 	# Add to main scene
	# 	var main_scene = get_tree().current_scene
	# 	if main_scene:
	# 		FloodgateController.universal_add_child(astral_beings, main_scene)
	# 		print("[SceneSetup] AstralBeings created and added to scene")
	# 	else:
	# 		print("[SceneSetup] Could not find main scene to add AstralBeings")
	# else:
	# 	print("[SceneSetup] Could not load astral_beings.gd script")
	print("[SceneSetup] Using new talking astral being system via world_builder")

func _setup_existing_ragdoll() -> void:
	# Look for existing ragdolls and enhance them
	var ragdolls = get_tree().get_nodes_in_group("ragdoll")
	
	for ragdoll in ragdolls:
		if ragdoll and not ragdoll.is_in_group("enhanced_ragdoll"):
			# Add objects group for tracking
			if not ragdoll.is_in_group("objects"):
				ragdoll.add_to_group("objects")
			
			# Mark as enhanced
			ragdoll.add_to_group("enhanced_ragdoll")
			
			print("[SceneSetup] Enhanced existing ragdoll: " + ragdoll.name)


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func create_test_objects() -> void:
	# Create some test objects for the ragdoll to interact with
	var world_builder = get_node("/root/WorldBuilder")
	if world_builder:
		print("[SceneSetup] Creating test objects...")
		
		# Create a few trees and boxes for testing
		for i in range(3):
			var tree_pos = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
			world_builder.create_tree_at_position(tree_pos, "test_tree_" + str(i))
			
		for i in range(2):
			var box_pos = Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
			world_builder.create_box_at_position(box_pos, "test_box_" + str(i))
		
		print("[SceneSetup] Test objects created")

# Console command to manually run setup
func cmd_setup_scene() -> void:
	_setup_ragdoll_system()
	# _setup_astral_beings()  # Disabled - using new talking astral being system
	_setup_existing_ragdoll()
	print("[SceneSetup] Manual scene setup completed")

func cmd_create_test_objects() -> void:
	create_test_objects()