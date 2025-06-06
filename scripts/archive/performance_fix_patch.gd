# Performance Fix Patch Script
# Run this to apply performance fixes to the Universal Being game
# This script can be attached to a Node and run once to patch the scene

extends Node

func _ready():
	print("🔧 Applying performance fixes...")
	
	# Check if generation coordinator already exists
	var coordinator = get_node_or_null("/root/Main/GenerationCoordinator")
	if coordinator:
		print("✅ Generation Coordinator already exists")
		return
	
	# Create and add generation coordinator
	var coordinator_scene = load("res://scenes/generation_coordinator.tscn")
	if coordinator_scene:
		var coordinator_instance = coordinator_scene.instantiate()
		get_node("/root/Main").add_child(coordinator_instance)
		print("✅ Added Generation Coordinator")
	else:
		# Create coordinator directly if scene not found
		var new_coordinator = GenerationCoordinator.new()
		new_coordinator.name = "GenerationCoordinator"
		get_node("/root/Main").add_child(new_coordinator)
		print("✅ Created Generation Coordinator directly")
	
	# Apply additional fixes
	_fix_player_groups()
	_configure_generation_systems()
	
	print("🎉 Performance fixes applied successfully!")
	print("🎉 Only one generation system will run at a time based on player scale")
	print("🎉 Emergency optimization will trigger if FPS drops below 20")
	
	# Self-destruct after applying fixes
	queue_free()

func _fix_player_groups():
	"""Ensure player is in correct groups"""
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if not player.is_in_group("players"):
			player.add_to_group("players")
			print("✅ Added player to 'players' group")

func _configure_generation_systems():
	"""Configure generation systems for optimal performance"""
	# Set initial process states
	var cosmic = get_node_or_null("/root/Main/CosmicLODSystem")
	var matrix = get_node_or_null("/root/Main/MatrixChunkSystem")
	var lightweight = get_node_or_null("/root/Main/LightweightChunkSystem")
	
	# Initially disable all but lightweight
	if cosmic:
		cosmic.set_process(false)
		cosmic.set_physics_process(false)
		print("✅ Disabled Cosmic LOD System initially")
	
	if matrix:
		matrix.set_process(false)
		matrix.set_physics_process(false)
		print("✅ Disabled Matrix Chunk System initially")
	
	if lightweight:
		lightweight.set_process(true)
		lightweight.set_physics_process(true)
		print("✅ Enabled Lightweight Chunk System as default")