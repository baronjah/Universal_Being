# 🏛️ Pallets Racing Game - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
class_name PalletsRacingGame

# References
var main_node = null
var camera = null
var race_track = null
var player_vehicle = null
var race_ui = null

# Race state
var race_started = false
var race_finished = false
var lap_count = 0
var total_laps = 3
var race_time = 0.0
var best_lap_time = 999.0
var current_lap_time = 0.0
var checkpoint_count = 0
var total_checkpoints = 0

# Vehicle settings
var vehicle_speed = 0.0
var max_speed = 50.0
var acceleration = 10.0
var steering_speed = 2.0
var friction = 0.9

# Initialize with reference to main node

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func setup_main_reference(main_ref):
	main_node = main_ref
	print("Pallets Racing Game initialized with main reference")

# Called when node enters the scene tree
func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("Pallets Racing Game node is ready")
	initialize_racing_game()

# Main game initialization
func initialize_racing_game():
	print("Initializing Pallets Racing Game...")
	
	# Setup simple race track (temporary for testing)
	setup_race_track()
	
	# Setup player vehicle
	setup_player_vehicle()
	
	# Setup race UI
	setup_race_ui()
	
	print("Pallets Racing Game initialization complete")

# Set up a basic race track with checkpoints
func setup_race_track():
	print("Setting up race track...")
	
	# Create a simple track using CSG shapes for now
	race_track = Node3D.new()
	race_track.name = "RaceTrack"
	add_child(race_track)
	
	# Create ground plane
	var ground = CSGBox3D.new()
	ground.name = "Ground"
	ground.size = Vector3(100, 1, 100)
	ground.position = Vector3(0, -0.5, 0)
	
	var ground_material = MaterialLibrary.get_material("default")
	ground_material.albedo_color = Color(0.2, 0.2, 0.2) # Asphalt color
	ground.material = ground_material
	
	FloodgateController.universal_add_child(ground, race_track)
	
	# Add some obstacles (pallets)
	create_pallet_obstacle(Vector3(10, 0.5, 5))
	create_pallet_obstacle(Vector3(-8, 0.5, 12))
	create_pallet_obstacle(Vector3(15, 0.5, -10))
	create_pallet_obstacle(Vector3(-5, 0.5, -15))
	
	# Set up checkpoints
	setup_checkpoints()

# Create a pallet obstacle
func create_pallet_obstacle(spawn_position: Vector3):
	var pallet = CSGBox3D.new()
	pallet.name = "Pallet"
	pallet.size = Vector3(1.2, 0.15, 0.8)
	pallet.position = spawn_position
	
	var pallet_material = MaterialLibrary.get_material("default")
	pallet_material.albedo_color = Color(0.6, 0.4, 0.2) # Wood color
	pallet.material = pallet_material
	
	FloodgateController.universal_add_child(pallet, race_track)

# Setup race checkpoints
func setup_checkpoints():
	var checkpoints = Node3D.new()
	checkpoints.name = "Checkpoints"
	FloodgateController.universal_add_child(checkpoints, race_track)
	
	# Add some checkpoint positions
	var checkpoint_positions = [
		Vector3(0, 0.5, 20),
		Vector3(20, 0.5, 0),
		Vector3(0, 0.5, -20),
		Vector3(-20, 0.5, 0)
	]
	
	for i in range(checkpoint_positions.size()):
		var checkpoint = CSGCylinder3D.new()
		checkpoint.name = "Checkpoint" + str(i)
		checkpoint.radius = 2.0
		checkpoint.height = 5.0
		checkpoint.position = checkpoint_positions[i]
		
		var checkpoint_material = MaterialLibrary.get_material("default")
		checkpoint_material.albedo_color = Color(0, 1, 0, 0.5) # Semi-transparent green
		checkpoint_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		checkpoint.material = checkpoint_material
		
		FloodgateController.universal_add_child(checkpoint, checkpoints)
	
	total_checkpoints = checkpoint_positions.size()

# Setup player vehicle
func setup_player_vehicle():
	print("Setting up player vehicle...")
	
	player_vehicle = CSGBox3D.new()
	player_vehicle.name = "PlayerVehicle"
	player_vehicle.size = Vector3(2, 1, 4)
	player_vehicle.position = Vector3(0, 0.5, 0)
	
	var vehicle_material = MaterialLibrary.get_material("default")
	vehicle_material.albedo_color = Color(1, 0, 0) # Red vehicle
	player_vehicle.material = vehicle_material
	
	add_child(player_vehicle)
	
	# Add camera to vehicle
	camera = Camera3D.new()
	camera.name = "VehicleCamera"
	camera.position = Vector3(0, 5, 10)
	camera.rotation_degrees = Vector3(-20, 180, 0)
	FloodgateController.universal_add_child(camera, player_vehicle)

# Setup race UI
func setup_race_ui():
	print("Setting up race UI...")
	
	race_ui = Node3D.new()
	race_ui.name = "RaceUI"
	add_child(race_ui)
	
	# Simple text display for now
	var race_info = Label3D.new()
	race_info.name = "RaceInfo"
	race_info.text = "World of Pallets Racing\nPress SPACE to start"
	race_info.position = Vector3(0, 3, -10)
	race_info.font_size = 24
	FloodgateController.universal_add_child(race_info, race_ui)

# Start the race
func start_race():
	if !race_started:
		race_started = true
		race_time = 0.0
		current_lap_time = 0.0
		lap_count = 0
		checkpoint_count = 0
		
		var race_info = race_ui.get_node("RaceInfo")
		if race_info:
			race_info.text = "Race Started!"
		
		print("Race started!")

# Process player input
func process_input(delta):
	if !race_started or race_finished:
		if Input.is_action_just_pressed("ui_accept"): # Space key
			start_race()
		return
	
	# Forward/backward movement
	if Input.is_action_pressed("ui_up"):
		vehicle_speed += acceleration * delta
	elif Input.is_action_pressed("ui_down"):
		vehicle_speed -= acceleration * delta
	else:
		vehicle_speed *= friction
	
	vehicle_speed = clamp(vehicle_speed, -max_speed/2, max_speed)
	
	# Left/right steering
	if Input.is_action_pressed("ui_left"):
		player_vehicle.rotate_y(steering_speed * delta)
	elif Input.is_action_pressed("ui_right"):
		player_vehicle.rotate_y(-steering_speed * delta)
	
	# Move vehicle forward based on its orientation
	player_vehicle.position += player_vehicle.transform.basis.z * vehicle_speed * delta

# Process frame update
func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	if race_started and !race_finished:
		race_time += delta
		current_lap_time += delta
		
		# Update UI
		var race_info = race_ui.get_node("RaceInfo")
		if race_info:
			var time_text = "Time: " + str(snapped(race_time, 0.01))
			var lap_text = "Lap: " + str(lap_count) + "/" + str(total_laps)
			race_info.text = time_text + "\n" + lap_text
		
		# Check if race is complete
		if lap_count >= total_laps:
			finish_race()
	
	# Process player input
	process_input(delta)

# Handle race completion
func finish_race():
	race_finished = true
	print("Race finished! Time: ", race_time)
	
	var race_info = race_ui.get_node("RaceInfo")
	if race_info:
		race_info.text = "Race Finished!\nTime: " + str(snapped(race_time, 0.01)) + "\nPress SPACE to restart"

# Reset the race
func reset_race():
	race_started = false
	race_finished = false
	player_vehicle.position = Vector3(0, 0.5, 0)
	player_vehicle.rotation = Vector3.ZERO
	vehicle_speed = 0.0
	
	var race_info = race_ui.get_node("RaceInfo")
	if race_info:
		race_info.text = "World of Pallets Racing\nPress SPACE to start"

# Exit race and return to main menu
func exit_to_menu():
	print("Exiting to main menu")
	if main_node and main_node.has_method("hide_racing_game"):
		main_node.hide_racing_game()
