# SPACE_GAME_ULTIMATE_V3.gd - THE ONE THAT ACTUALLY WORKS
extends Node3D

# F for move_down, E for interact - NO CONFLICTS
# All visual feedback - NO PRINTS
# Pentagon Architecture compliant
# Stellar color progression: black→brown→red→orange→yellow→white→lightblue→blue→purple

@onready var player_plasmoid = $PlayerPlasmoid
@onready var stellar_hud = $StellarHUD
@onready var mining_beam = $PlayerPlasmoid/MiningBeamSystem
@onready var space_environment = $SpaceEnvironment
@onready var consciousness_visualizer = $ConsciousnessVisualizer

var resource_inventory = {
	"metal": 100,
	"energy": 100,
	"crystals": 0,
	"quantum": 0
}

var consciousness_level = 0
var stellar_colors = [
	Color.BLACK,      # 0
	Color("#654321"), # 1 - Brown
	Color.RED,        # 2
	Color.ORANGE,     # 3
	Color.YELLOW,     # 4
	Color.WHITE,      # 5
	Color.CYAN,       # 6 - Light Blue
	Color.BLUE,       # 7
	Color.PURPLE      # 8
]

func _ready():
	# Set up visual feedback system
	stellar_hud.show_message("SPACE GAME ULTIMATE V3 ACTIVATED", stellar_colors[consciousness_level])
	
	# Create initial space environment
	_spawn_initial_objects()
	
	# Connect signals
	if mining_beam:
		mining_beam.resources_collected.connect(_on_resources_collected)

func _spawn_initial_objects():
	# Create space station
	var station = preload("res://scenes/space_station.tscn").instantiate()
	station.position = Vector3(200, 0, 0)
	space_environment.add_child(station)
	
	# Create asteroids
	for i in range(10):
		var asteroid = create_asteroid()
		asteroid.position = Vector3(
			randf_range(-500, 500),
			randf_range(-100, 100),
			randf_range(-500, 500)
		)
		space_environment.add_child(asteroid)
	
	# Visual feedback for creation
	stellar_hud.show_message("SPACE ENVIRONMENT INITIALIZED", stellar_colors[consciousness_level])

func create_asteroid() -> StaticBody3D:
	var asteroid = StaticBody3D.new()
	asteroid.add_to_group("asteroids")
	
	# Visual mesh
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = randf_range(5, 15)
	mesh_instance.mesh = sphere_mesh
	
	# Material based on resources
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.5, 0.5)
	material.roughness = 0.8
	mesh_instance.material_override = material
	
	# Collision
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = sphere_mesh.radius
	collision_shape.shape = sphere_shape
	
	asteroid.add_child(mesh_instance)
	asteroid.add_child(collision_shape)
	
	# Store resources
	asteroid.set_meta("resources", {
		"metal": randi_range(10, 50),
		"energy": randi_range(0, 20)
	})
	asteroid.set_meta("mesh_instance", mesh_instance)
	
	return asteroid

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_E: # INTERACT
				_handle_interaction()
			KEY_M: # Toggle mecha
				_toggle_mecha()
			KEY_T: # Fast travel
				_fast_travel()

func _handle_interaction():
	# Get nearest interactable
	var nearest = _get_nearest_interactable()
	
	if not nearest:
		stellar_hud.show_message("NO TARGET IN RANGE", Color.RED)
		return
	
	if nearest.is_in_group("asteroids"):
		_start_mining(nearest)
	elif nearest.is_in_group("stations"):
		_dock_at_station(nearest)
	elif nearest.is_in_group("planets"):
		_land_on_planet(nearest)

func _get_nearest_interactable() -> Node3D:
	var nearest = null
	var min_distance = 100.0 # Interaction range
	
	for node in get_tree().get_nodes_in_group("asteroids") + get_tree().get_nodes_in_group("stations") + get_tree().get_nodes_in_group("planets"):
		if node == player_plasmoid:
			continue
		var distance = player_plasmoid.global_position.distance_to(node.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = node
	
	return nearest

func _start_mining(asteroid: Node3D):
	if mining_beam:
		mining_beam.start_mining(asteroid)
		stellar_hud.show_message("MINING INITIATED", stellar_colors[consciousness_level])

func _on_resources_collected(resources: Dictionary):
	for resource in resources:
		if resource_inventory.has(resource):
			resource_inventory[resource] += resources[resource]
	
	# Visual feedback
	_update_resource_display()
	_show_resource_gain(resources)

func _show_resource_gain(resources: Dictionary):
	for resource in resources:
		var amount = resources[resource]
		var color = _get_resource_color(resource)
		stellar_hud.show_floating_text(
			"+%d %s" % [amount, resource.to_upper()],
			player_plasmoid.global_position + Vector3.UP * 10,
			color
		)

func _get_resource_color(resource: String) -> Color:
	match resource:
		"metal": return Color.RED
		"energy": return Color.YELLOW
		"crystals": return Color.CYAN
		"quantum": return Color.PURPLE
		_: return Color.WHITE

func _update_resource_display():
	stellar_hud.update_resources(resource_inventory)
	
	# Check consciousness evolution
	var total_resources = 0
	for resource in resource_inventory.values():
		total_resources += resource
	
	var new_consciousness = min(int(total_resources / 100), 8)
	if new_consciousness > consciousness_level:
		_evolve_consciousness(new_consciousness)

func _evolve_consciousness(new_level: int):
	consciousness_level = new_level
	var color = stellar_colors[consciousness_level]
	
	# Visual transformation
	consciousness_visualizer.show_evolution(consciousness_level, color)
	stellar_hud.show_message(
		"CONSCIOUSNESS EVOLVED TO LEVEL %d" % consciousness_level,
		color,
		3.0
	)
	
	# Update player visual
	if player_plasmoid.has_method("set_stellar_color"):
		player_plasmoid.set_stellar_color(color)

func _dock_at_station(station: Node3D):
	stellar_hud.show_message("DOCKING AT STATION", stellar_colors[consciousness_level])
	
	# Open trade interface
	var trade_interface = preload("res://scenes/trade_interface_3d.tscn").instantiate()
	trade_interface.position = player_plasmoid.position + Vector3(0, 20, -30)
	add_child(trade_interface)
	trade_interface.setup_trade(resource_inventory, station)

func _land_on_planet(planet: Node3D):
	stellar_hud.show_message("LANDING ON PLANET", stellar_colors[consciousness_level])
	# TODO: Planet surface scene transition

func _toggle_mecha():
	# TODO: Mecha transformation
	stellar_hud.show_message("MECHA SYSTEM IN DEVELOPMENT", Color.ORANGE)

func _fast_travel():
	var stations = get_tree().get_nodes_in_group("stations")
	if stations.size() > 0:
		player_plasmoid.global_position = stations[0].global_position + Vector3(50, 0, 0)
		stellar_hud.show_message("WARPED TO STATION", stellar_colors[consciousness_level])

# VISUAL FEEDBACK SYSTEM - NO PRINTS
class StellarHUD extends Control:
	var message_label: Label3D
	var resource_displays: Dictionary = {}
	
	func show_message(text: String, color: Color, duration: float = 2.0):
		if not message_label:
			message_label = Label3D.new()
			add_child(message_label)
		
		message_label.text = text
		message_label.modulate = color
		message_label.position = Vector3(0, 50, 0)
		
		# Fade out animation
		var tween = create_tween()
		tween.tween_property(message_label, "modulate:a", 0.0, duration)
	
	func show_floating_text(text: String, position: Vector3, color: Color):
		var floating_text = Label3D.new()
		floating_text.text = text
		floating_text.modulate = color
		floating_text.position = position
		get_parent().add_child(floating_text)
		
		# Float up and fade
		var tween = create_tween()
		tween.parallel().tween_property(floating_text, "position:y", position.y + 20, 1.0)
		tween.parallel().tween_property(floating_text, "modulate:a", 0.0, 1.0)
		tween.tween_callback(floating_text.queue_free)
	
	func update_resources(resources: Dictionary):
		# Create 3D resource display
		for resource in resources:
			if not resource_displays.has(resource):
				var display = Label3D.new()
				display.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				resource_displays[resource] = display
				add_child(display)
			
			var display = resource_displays[resource]
			display.text = "%s: %d" % [resource.to_upper(), resources[resource]]
			display.position = Vector3(-100 + resource_displays.size() * 30, 40, 0)
			display.modulate = _get_resource_color(resource)
