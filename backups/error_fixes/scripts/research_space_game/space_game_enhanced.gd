# space_game_enhanced.gd - Connects your existing space game with Universal Being
extends Node3D

# Reference your existing systems
@onready var space_game_v2 = preload("res://scenes/SPACE_GAME_ULTIMATE_V2.tscn")
@onready var consciousness_system = get_node("/root/ConsciousnessSystem")
@onready var ai_controller = get_node("/root/AIController")

# Core game state
var player_ship: Node3D
var current_system: Node3D
var active_companions: Array = []
var resource_inventory: Dictionary = {}
var consciousness_level: float = 1.0

# Game constants from your analysis
const MINING_RANGE = 50.0
const INTERACTION_RANGE = 100.0
const SYSTEM_SCALE = 1000.0

func _ready():
	# Load your streamlined V2 as base (it works)
	current_system = space_game_v2.instantiate()
	add_child(current_system)
	
	# Get player ship from scene
	player_ship = current_system.get_node("PlayerShip")
	
	# Initialize systems
	_setup_consciousness_integration()
	_setup_ai_companions()
	_initialize_resources()
	
	# Connect signals
	if consciousness_system:
		consciousness_system.level_changed.connect(_on_consciousness_changed)

func _setup_consciousness_integration():
	# Connect space game to Universal Being consciousness
	if not consciousness_system:
		return
		
	# Your existing consciousness levels affect gameplay
	consciousness_level = consciousness_system.get_current_level()
	
	# Apply consciousness effects
	_apply_consciousness_modifiers()

func _apply_consciousness_modifiers():
	# Higher consciousness = better abilities
	if player_ship:
		var ship_stats = player_ship.get_node("ShipStats")
		if ship_stats:
			ship_stats.mining_efficiency = 1.0 + (consciousness_level * 0.1)
			ship_stats.sensor_range = INTERACTION_RANGE * (1.0 + consciousness_level * 0.5)
			ship_stats.jump_range = 50.0 * consciousness_level

func _setup_ai_companions():
	# Use your Gemma integration for companions
	if not ai_controller:
		return
		
	# Create AI companions based on consciousness
	var num_companions = int(consciousness_level)
	for i in range(num_companions):
		var companion = _create_ai_companion(i)
		active_companions.append(companion)
		current_system.add_child(companion)

func _create_ai_companion(index: int) -> Node3D:
	var companion = preload("res://scripts/space_game/ai_companion.gd").new()
	companion.name = "Companion_" + str(index)
	companion.position = player_ship.position + Vector3(randf() * 100, 0, randf() * 100)
	
	# Connect to your AI system
	if ai_controller.has_method("create_companion_ai"):
		companion.ai_brain = ai_controller.create_companion_ai()
	
	return companion

func _initialize_resources():
	# Start with basic resources
	resource_inventory = {
		"energy": 100,
		"metals": 0,
		"crystals": 0,
		"quantum_matter": 0
	}

func mine_asteroid(asteroid: Node3D) -> bool:
	if not asteroid or not player_ship:
		return false
		
	var distance = player_ship.position.distance_to(asteroid.position)
	if distance > MINING_RANGE:
		return false
		
	# Extract resources
	var resources = asteroid.get_meta("resources", {})
	for resource in resources:
		if resource_inventory.has(resource):
			resource_inventory[resource] += resources[resource]
		else:
			resource_inventory[resource] = resources[resource]
	
	# Consciousness affects yield
	for resource in resource_inventory:
		resource_inventory[resource] *= (1.0 + consciousness_level * 0.1)
	
	# Remove asteroid
	asteroid.queue_free()
	return true

func process_mecha_transformation():
	if not player_ship:
		return
		
	# Your mecha system from ULTIMATE.tscn
	var mecha_scene = preload("res://scenes/mecha.tscn")
	var mecha = mecha_scene.instantiate()
	mecha.position = player_ship.position
	mecha.rotation = player_ship.rotation
	
	# Transfer consciousness
	if consciousness_system:
		consciousness_system.transfer_to_entity(mecha)
	
	# Hide ship, show mecha
	player_ship.visible = false
	current_system.add_child(mecha)
	
	# Update controls
	player_ship = mecha

func interact_with_station(station: Node3D):
	if not station or not player_ship:
		return
		
	var distance = player_ship.position.distance_to(station.position)
	if distance > INTERACTION_RANGE:
		return
		
	# Open trade interface
	var trade_data = {
		"station": station,
		"inventory": resource_inventory,
		"consciousness": consciousness_level
	}
	
	# Your existing trade system
	if station.has_method("open_trade"):
		station.open_trade(trade_data)

func warp_to_system(target_position: Vector3):
	# Consciousness-based warping
	var warp_cost = 50.0 / consciousness_level
	
	if resource_inventory["energy"] < warp_cost:
		print("Insufficient energy for warp")
		return
		
	resource_inventory["energy"] -= warp_cost
	
	# Create warp effect
	var warp_effect = preload("res://effects/warp.tscn").instantiate()
	warp_effect.position = player_ship.position
	current_system.add_child(warp_effect)
	
	# Move player
	player_ship.position = target_position
	
	# Update companions
	for companion in active_companions:
		companion.warp_to(target_position)

func _process(delta):
	# Update UI
	_update_resource_display()
	
	# Process companion AI
	for companion in active_companions:
		if companion.has_method("ai_think"):
			companion.ai_think(delta)

func _update_resource_display():
	# Update your existing UI
	var ui = get_node("/root/GameUI")
	if ui and ui.has_method("update_resources"):
		ui.update_resources(resource_inventory)

func _on_consciousness_changed(new_level: float):
	consciousness_level = new_level
	_apply_consciousness_modifiers()
	
	# Spawn new companion if level increased
	if int(new_level) > active_companions.size():
		var companion = _create_ai_companion(active_companions.size())
		active_companions.append(companion)
		current_system.add_child(companion)

# Integration with your existing one.gd universe simulation
func connect_to_universe_simulation():
	var universe = get_node("/root/UniverseSimulation")
	if universe:
		# Your N-body physics affect the game
		universe.bodies_collided.connect(_on_celestial_collision)
		universe.star_evolved.connect(_on_star_evolution)

func _on_celestial_collision(body1: Node3D, body2: Node3D):
	# Real consequences from your physics
	var explosion_pos = (body1.position + body2.position) / 2.0
	var shockwave_radius = (body1.mass + body2.mass) * 0.001
	
	# Damage nearby ships
	if player_ship.position.distance_to(explosion_pos) < shockwave_radius:
		player_ship.take_damage(shockwave_radius - player_ship.position.distance_to(explosion_pos))

func _on_star_evolution(star: Node3D, new_phase: String):
	match new_phase:
		"red_giant":
			# Evacuate inner planets
			for companion in active_companions:
				companion.flee_from(star.position)
		"supernova":
			# Major event - consciousness surge
			consciousness_level += 0.5
			_apply_consciousness_modifiers()

# Save/Load using your existing system
func save_game_state() -> Dictionary:
	return {
		"resources": resource_inventory,
		"consciousness": consciousness_level,
		"position": player_ship.position,
		"companions": active_companions.size()
	}

func load_game_state(data: Dictionary):
	resource_inventory = data.get("resources", {})
	consciousness_level = data.get("consciousness", 1.0)
	player_ship.position = data.get("position", Vector3.ZERO)
	
	# Recreate companions
	var companion_count = data.get("companions", 0)
	for i in range(companion_count):
		var companion = _create_ai_companion(i)
		active_companions.append(companion)
		current_system.add_child(companion)
