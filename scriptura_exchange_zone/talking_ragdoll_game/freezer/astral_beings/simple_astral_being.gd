# Simple Astral Being - Flying entities with names that do things
# Your wishes made manifest - beings that act on whims
extends UniversalBeingBase
class_name SimpleAstralBeing

# Core properties - just what we need NOW
@export var being_name: String = "Astral"
@export var flying_speed: float = 3.0
@export var action_radius: float = 10.0

# Visual elements
var name_label: Label3D
var body_mesh: MeshInstance3D
var glow_light: OmniLight3D

# Current state
var current_action: String = "idle"
var current_target: Node3D
var home_position: Vector3

# Simple script/scenario system
var behavior_script: Array = [
	{"action": "fly_to", "target": "random", "duration": 3.0},
	{"action": "hover", "duration": 2.0},
	{"action": "look_around", "duration": 1.5},
	{"action": "return_home", "duration": 4.0}
]
var script_index: int = 0
var action_timer: float = 0.0

signal action_completed(action: String)
signal wish_granted(wish: String)

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	home_position = position
	_create_visual_form()
	_start_behavior()

# Create the simple visual form
func _create_visual_form():
	# Name above head
	name_label = Label3D.new()
	name_label.text = being_name
	name_label.position = Vector3(0, 1.5, 0)
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	name_label.modulate = Color.CYAN
	add_child(name_label)
	
	# Simple glowing orb body
	body_mesh = MeshInstance3D.new()
	body_mesh.mesh = SphereMesh.new()
	body_mesh.mesh.radial_segments = 16
	body_mesh.mesh.rings = 8
	body_mesh.mesh.radius = 0.3
	body_mesh.mesh.height = 0.6
	
	# Glowing material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.5, 0.8, 1.0, 0.8)
	material.emission_enabled = true
	material.emission = Color(0.3, 0.6, 1.0)
	material.emission_energy = 2.0
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	body_mesh.material_override = material
	add_child(body_mesh)
	
	# Simple light
	glow_light = OmniLight3D.new()
	glow_light.light_color = Color(0.5, 0.8, 1.0)
	glow_light.light_energy = 0.5
	glow_light.omni_range = 5.0
	add_child(glow_light)

# Simple behavior system

# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	# Execute current behavior
	_process_current_action(delta)
	
	# Simple floating animation
	body_mesh.position.y = sin(Time.get_ticks_msec() * 0.002) * 0.1

# Process the current action in the script
func _process_current_action(delta):
	action_timer -= delta
	
	if action_timer <= 0:
		# Move to next action
		_next_action()
		return
	
	# Execute current action
	match current_action:
		"fly_to":
			_fly_to_target(delta)
		"hover":
			_hover_in_place(delta)
		"look_around":
			_look_around(delta)
		"return_home":
			_fly_to_position(home_position, delta)
		"follow":
			_follow_target(delta)
		"create":
			_create_something()
		"transform":
			_transform_something()

# Move to next action in script
func _next_action():
	if behavior_script.is_empty():
		current_action = "idle"
		return
		
	var action_data = behavior_script[script_index]
	current_action = action_data.action
	action_timer = action_data.get("duration", 2.0)
	
	# Setup action
	match current_action:
		"fly_to":
			var target_type = action_data.get("target", "random")
			if target_type == "random":
				current_target = _find_random_target()
			else:
				current_target = _find_named_target(target_type)
	
	script_index = (script_index + 1) % behavior_script.size()
	emit_signal("action_completed", current_action)

# Flying behaviors
func _fly_to_target(delta):
	if not current_target:
		return
		
	var direction = (current_target.global_position - global_position).normalized()
	global_position += direction * flying_speed * delta
	
	# Face direction of movement
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)

func _fly_to_position(target_pos: Vector3, delta):
	var direction = (target_pos - global_position).normalized()
	var distance = global_position.distance_to(target_pos)
	
	if distance > 0.5:
		global_position += direction * flying_speed * delta

func _hover_in_place(delta):
	# Gentle floating motion
	position.y += sin(Time.get_ticks_msec() * 0.001) * 0.5 * delta

func _look_around(delta):
	rotate_y(delta * 0.5)

func _follow_target(delta):
	if current_target:
		var desired_pos = current_target.global_position + Vector3(2, 3, 0)
		_fly_to_position(desired_pos, delta)

# Creation abilities
func _create_something():
	# Create a simple shape at current position
	var thing = preload("res://scripts/core/the_universal_thing.gd").new()
	get_parent().add_child(thing)
	thing.global_position = global_position + Vector3(0, -1, 0)
	thing.become("shape", {"shape": "sphere", "color": Color(randf(), randf(), randf())})

func _transform_something():
	# Transform nearest object
	var nearest = _find_nearest_object()
	if nearest and nearest.has_method("become"):
		nearest.become("shape", {"shape": "box", "color": Color.CYAN})

# Target finding
func _find_random_target() -> Node3D:
	var objects = get_tree().get_nodes_in_group("targetable")
	if objects.is_empty():
		# Create a random position as target
		var dummy = Node3D.new()
		dummy.position = Vector3(
			randf_range(-action_radius, action_radius),
			randf_range(1, 5),
			randf_range(-action_radius, action_radius)
		)
		get_parent().add_child(dummy)
		return dummy
	
	return objects[randi() % objects.size()]

func _find_named_target(target_name: String) -> Node3D:
	var node = get_node_or_null("/root/" + target_name)
	if not node:
		node = get_tree().get_first_node_in_group(target_name)
	return node

func _find_nearest_object() -> Node3D:
	var nearest: Node3D = null
	var min_distance: float = INF
	
	for node in get_tree().get_nodes_in_group("objects"):
		if node != self:
			var distance = global_position.distance_to(node.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest = node
	
	return nearest

# Console command interface

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

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
func execute_wish(wish: String):
	var words = wish.split(" ")
	if words.is_empty():
		return
		
	var command = words[0].to_lower()
	
	match command:
		"go", "fly":
			if words.size() > 1:
				var target = words[1]
				current_action = "fly_to"
				current_target = _find_named_target(target)
				action_timer = 5.0
		"create", "make":
			current_action = "create"
			action_timer = 0.1
		"follow":
			if words.size() > 1:
				current_target = _find_named_target(words[1])
				current_action = "follow"
				action_timer = 10.0
		"home", "return":
			current_action = "return_home"
			action_timer = 5.0
		"dance":
			behavior_script = [
				{"action": "hover", "duration": 0.5},
				{"action": "look_around", "duration": 1.0},
				{"action": "fly_to", "target": "random", "duration": 2.0}
			]
			script_index = 0
		"transform":
			current_action = "transform"
			action_timer = 0.1
	
	emit_signal("wish_granted", wish)
	name_label.text = being_name + ": " + command

# Change behavior script at runtime
func set_behavior_script(new_script: Array):
	behavior_script = new_script
	script_index = 0
	_next_action()

# Start default behavior
func _start_behavior():
	_next_action()

# LOD support - simpler at distance
func set_lod_level(level: int):
	match level:
		0:  # Far - just the name
			body_mesh.visible = false
			glow_light.visible = false
			name_label.visible = true
		1:  # Medium - simple form
			body_mesh.visible = true
			glow_light.visible = false
			name_label.visible = true
		2:  # Close - full detail
			body_mesh.visible = true
			glow_light.visible = true
			name_label.visible = true