# Perfect Astral Being - All versions unified into ONE
# The culmination of all astral being implementations
# Your wishes made manifest - beings that fly, act, and transform reality
extends UniversalBeingBase
class_name PerfectAstralBeing

# ===== CORE IDENTITY =====
@export var being_name: String = "Astral"
@export var being_color: Color = Color(0.5, 0.8, 1.0)
@export var consciousness_level: float = 1.0

# ===== VISUAL COMPONENTS =====
var name_label: Label3D          # Name above head
var body_orb: MeshInstance3D     # Glowing orb body
var glow_light: OmniLight3D      # Emanating light
var particles: GPUParticles3D    # Magical particles
var connection_lines: Array = [] # Visual connections to other beings

# ===== MOVEMENT & BEHAVIOR =====
enum ActionState {
	IDLE,
	FLYING,
	HOVERING,
	FOLLOWING,
	CREATING,
	ORGANIZING,
	HELPING,
	PATROLLING,
	DANCING
}

@export var current_state: ActionState = ActionState.HOVERING
@export var flying_speed: float = 5.0
@export var hover_height: float = 3.0
@export var action_radius: float = 15.0

# Movement properties
var home_position: Vector3
var target_position: Vector3
var follow_target: Node3D
var orbit_angle: float = 0.0
var hover_offset: float = 0.0

# ===== BEHAVIOR SCRIPT SYSTEM =====
var behavior_script: Array = []
var script_index: int = 0
var action_timer: float = 0.0
var current_task: Dictionary = {}

# ===== CONNECTIONS & AWARENESS =====
var connected_beings: Array[PerfectAstralBeing] = []
var nearby_objects: Array = []
var helped_entities: Array = []
var awareness_area: Area3D

# ===== ABILITIES =====
var can_create: bool = true
var can_transform: bool = true
var can_organize: bool = true
var can_help: bool = true
var energy: float = 100.0

# Signals
signal action_completed(action: String, result: Variant)
signal being_connected(other_being: PerfectAstralBeing)
signal wish_fulfilled(wish: String)
signal entity_helped(entity: Node3D)

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	home_position = position
	_create_perfect_form()
	_setup_awareness()
	_begin_existence()

# Create the perfect visual form combining all versions
func _create_perfect_form():
	# Name label (from simple version)
	name_label = Label3D.new()
	name_label.text = being_name
	name_label.position = Vector3(0, 1.2, 0)
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	name_label.modulate = being_color
	name_label.outline_modulate = Color(0, 0, 0, 1)
	name_label.outline_size = 10
	add_child(name_label)
	
	# Glowing orb body (enhanced from all versions)
	body_orb = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.4
	sphere.height = 0.8
	sphere.radial_segments = 32
	sphere.rings = 16
	body_orb.mesh = sphere
	
	# Perfect material combining all visual features
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = being_color * 0.8
	material.emission_enabled = true
	material.emission = being_color
	material.emission_energy = 2.0 * consciousness_level
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.7
	material.rim_enabled = true
	material.rim = 1.0
	material.rim_tint = 0.5
	body_orb.material_override = material
	add_child(body_orb)
	
	# Omni light (from enhanced version)
	glow_light = OmniLight3D.new()
	glow_light.light_color = being_color
	glow_light.light_energy = 1.0 * consciousness_level
	glow_light.omni_range = 8.0
	glow_light.shadow_enabled = true
	add_child(glow_light)
	
	# Magical particles (from magical version)
	particles = GPUParticles3D.new()
	particles.amount = 50
	particles.lifetime = 2.0
	particles.preprocess = 1.0
	particles.emitting = true
	
	var process_mat = ParticleProcessMaterial.new()
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process_mat.emission_sphere_radius = 0.5
	process_mat.initial_velocity_min = 0.5
	process_mat.initial_velocity_max = 1.0
	process_mat.angular_velocity_min = -180.0
	process_mat.angular_velocity_max = 180.0
	process_mat.scale_min = 0.1
	process_mat.scale_max = 0.3
	process_mat.color = being_color
	particles.process_material = process_mat
	particles.draw_pass_1 = SphereMesh.new()
	particles.draw_pass_1.radius = 0.05
	particles.draw_pass_1.height = 0.1
	add_child(particles)

# Setup awareness system (from talking version)
func _setup_awareness():
	awareness_area = Area3D.new()
	var collision = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = action_radius
	collision.shape = sphere_shape
	FloodgateController.universal_add_child(collision, awareness_area)
	add_child(awareness_area)
	
	awareness_area.body_entered.connect(_on_body_entered)
	awareness_area.body_exited.connect(_on_body_exited)
	awareness_area.area_entered.connect(_on_area_entered)

# Begin default behavior
func _begin_existence():
	# Default hovering behavior
	behavior_script = [
		{"action": "hover", "duration": 3.0},
		{"action": "look_around", "duration": 2.0},
		{"action": "patrol", "duration": 5.0}
	]
	_next_action()

# Main process loop

# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	# Update energy
	energy = min(100.0, energy + delta * 5.0)
	
	# Process current state
	match current_state:
		ActionState.IDLE:
			_process_idle(delta)
		ActionState.FLYING:
			_process_flying(delta)
		ActionState.HOVERING:
			_process_hovering(delta)
		ActionState.FOLLOWING:
			_process_following(delta)
		ActionState.CREATING:
			_process_creating(delta)
		ActionState.ORGANIZING:
			_process_organizing(delta)
		ActionState.HELPING:
			_process_helping(delta)
		ActionState.PATROLLING:
			_process_patrolling(delta)
		ActionState.DANCING:
			_process_dancing(delta)
	
	# Update visuals
	_update_visual_effects(delta)
	
	# Process behavior script
	_process_behavior_script(delta)

# State processing functions
func _process_idle(delta):
	hover_offset += delta
	position.y = home_position.y + sin(hover_offset * 2.0) * 0.3

func _process_hovering(delta):
	hover_offset += delta * 1.5
	position.y = home_position.y + hover_height + sin(hover_offset) * 0.5
	rotation.y += delta * 0.2

func _process_flying(delta):
	if position.distance_to(target_position) > 0.5:
		var direction = (target_position - position).normalized()
		position += direction * flying_speed * delta
		
		# Smooth rotation
		if direction.length() > 0.1:
			var target_transform = transform.looking_at(position + direction, Vector3.UP)
			transform = transform.interpolate_with(target_transform, delta * 5.0)
	else:
		current_state = ActionState.HOVERING

func _process_following(delta):
	if is_instance_valid(follow_target):
		target_position = follow_target.global_position + Vector3(2, 3, -1)
		_process_flying(delta)
	else:
		current_state = ActionState.HOVERING

func _process_creating(_delta):
	if energy >= 20.0:
		_create_magical_object()
		energy -= 20.0
	current_state = ActionState.HOVERING

func _process_organizing(_delta):
	_organize_nearby_objects()
	current_state = ActionState.HOVERING

func _process_helping(_delta):
	_help_nearest_entity()
	current_state = ActionState.HOVERING

func _process_patrolling(delta):
	orbit_angle += delta * 0.5
	var radius = action_radius * 0.7
	target_position = home_position + Vector3(
		cos(orbit_angle) * radius,
		hover_height,
		sin(orbit_angle) * radius
	)
	_process_flying(delta)

func _process_dancing(delta):
	hover_offset += delta * 3.0
	position.y = home_position.y + hover_height + sin(hover_offset * 2) * 1.0
	rotation.y += delta * 2.0
	body_orb.rotation.x = sin(hover_offset * 3) * 0.5
	body_orb.rotation.z = cos(hover_offset * 2) * 0.5

# Visual effects update
func _update_visual_effects(_delta):
	# Pulsing light based on energy
	glow_light.light_energy = (1.0 + sin(hover_offset * 3) * 0.3) * consciousness_level
	
	# Particle effects based on state
	particles.emitting = current_state != ActionState.IDLE
	
	# Body glow based on connections
	var connection_glow = 1.0 + connected_beings.size() * 0.2
	body_orb.material_override.emission_energy = 2.0 * consciousness_level * connection_glow

# Behavior script system
func _process_behavior_script(delta):
	if behavior_script.is_empty():
		return
		
	action_timer -= delta
	if action_timer <= 0:
		_next_action()

func _next_action():
	if behavior_script.is_empty():
		return
		
	var action = behavior_script[script_index]
	script_index = (script_index + 1) % behavior_script.size()
	
	action_timer = action.get("duration", 2.0)
	execute_action(action.get("action", "hover"), action)

# Execute any action

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
func execute_action(action: String, params: Dictionary = {}):
	match action:
		"hover":
			current_state = ActionState.HOVERING
		"fly_to":
			current_state = ActionState.FLYING
			if params.has("position"):
				target_position = params.position
			elif params.has("target"):
				var target = get_node_or_null(params.target)
				if target:
					target_position = target.global_position
		"follow":
			current_state = ActionState.FOLLOWING
			if params.has("target"):
				follow_target = get_node_or_null(params.target)
		"create":
			current_state = ActionState.CREATING
		"organize":
			current_state = ActionState.ORGANIZING
		"help":
			current_state = ActionState.HELPING
		"patrol":
			current_state = ActionState.PATROLLING
		"dance":
			current_state = ActionState.DANCING
		"look_around":
			rotation.y += TAU
		_:
			print("[AstralBeing] Unknown action: " + action)
	
	emit_signal("action_completed", action, params)

# Creation ability
func _create_magical_object():
	if not can_create:
		return
		
	var thing = load("res://scripts/core/the_universal_thing.gd").new()
	get_parent().add_child(thing)
	thing.global_position = global_position + Vector3(0, -2, 0)
	
	# Random creation
	var types = ["shape", "word", "connector"]
	var chosen_type = types[randi() % types.size()]
	
	match chosen_type:
		"shape":
			thing.become("shape", {
				"shape": ["sphere", "box", "cylinder"][randi() % 3],
				"color": being_color * 0.8
			})
		"word":
			thing.become("word", {
				"text": ["PEACE", "LOVE", "CREATE", "DREAM"][randi() % 4]
			})
		"connector":
			thing.become("connector", {"targets": [self]})

# Organization ability
func _organize_nearby_objects():
	if not can_organize or nearby_objects.is_empty():
		return
		
	var angle_step = TAU / nearby_objects.size()
	var radius = 5.0
	
	for i in range(nearby_objects.size()):
		var obj = nearby_objects[i]
		if is_instance_valid(obj):
			var target_pos = global_position + Vector3(
				cos(i * angle_step) * radius,
				0,
				sin(i * angle_step) * radius
			)
			
			# Smooth movement
			if obj.has_method("set_target_position"):
				obj.set_target_position(target_pos)
			else:
				obj.global_position = obj.global_position.lerp(target_pos, 0.1)

# Help ability
func _help_nearest_entity():
	if not can_help:
		return
		
	for obj in nearby_objects:
		if obj.has_method("needs_help") and obj.needs_help():
			# Fly to help
			follow_target = obj
			current_state = ActionState.FOLLOWING
			
			# Provide assistance
			if obj.has_method("receive_help"):
				obj.receive_help(self)
			
			helped_entities.append(obj)
			emit_signal("entity_helped", obj)
			break

# Connection system
func connect_to_being(other_being: PerfectAstralBeing):
	if other_being in connected_beings:
		return
		
	connected_beings.append(other_being)
	other_being.connected_beings.append(self)
	
	# Share consciousness
	var avg_consciousness = (consciousness_level + other_being.consciousness_level) / 2.0
	consciousness_level = lerp(consciousness_level, avg_consciousness, 0.5)
	other_being.consciousness_level = lerp(other_being.consciousness_level, avg_consciousness, 0.5)
	
	# Visual connection line
	_create_connection_line(other_being)
	
	emit_signal("being_connected", other_being)

func _create_connection_line(target: Node3D):
	# Create a simple line mesh between beings
	var line = ImmediateMesh.new()
	var line_instance = MeshInstance3D.new()
	line_instance.mesh = line
	line_instance.material_override = MaterialLibrary.get_material("default")
	line_instance.material_override.vertex_color_use_as_albedo = true
	line_instance.material_override.albedo_color = being_color * 0.5
	add_child(line_instance)
	connection_lines.append({"target": target, "mesh": line_instance})

# Awareness callbacks
func _on_body_entered(body: Node3D):
	if not body in nearby_objects:
		nearby_objects.append(body)
		
	# Auto-connect to other astral beings
	if body is PerfectAstralBeing:
		connect_to_being(body)

func _on_body_exited(body: Node3D):
	nearby_objects.erase(body)

func _on_area_entered(area: Area3D):
	var parent = area.get_parent()
	if parent is PerfectAstralBeing:
		connect_to_being(parent)

# Console command interface
func execute_wish(wish: String):
	var words = wish.split(" ")
	if words.is_empty():
		return
		
	var command = words[0].to_lower()
	
	match command:
		"fly", "go":
			if words.size() > 1:
				execute_action("fly_to", {"target": words[1]})
		"follow":
			if words.size() > 1:
				execute_action("follow", {"target": words[1]})
		"create", "spawn":
			execute_action("create")
		"organize":
			execute_action("organize")
		"help":
			execute_action("help")
		"dance":
			execute_action("dance")
		"patrol":
			execute_action("patrol")
		"home":
			target_position = home_position
			current_state = ActionState.FLYING
		"connect":
			for being in get_tree().get_nodes_in_group("astral_beings"):
				if being != self and being is PerfectAstralBeing:
					connect_to_being(being)
		_:
			# Try as custom behavior script
			behavior_script = [{"action": command, "duration": 5.0}]
			script_index = 0
			_next_action()
	
	emit_signal("wish_fulfilled", wish)
	name_label.text = being_name + ": " + wish

# Task assignment
func assign_task(task: Dictionary):
	current_task = task
	
	if task.has("script"):
		behavior_script = task.script
		script_index = 0
		_next_action()
	elif task.has("action"):
		execute_action(task.action, task)

# LOD support
func set_lod_level(level: int):
	match level:
		0:  # Far - minimal
			body_orb.visible = false
			particles.visible = false
			glow_light.visible = false
			name_label.visible = true
		1:  # Medium - basic
			body_orb.visible = true
			particles.visible = false
			glow_light.visible = false
			name_label.visible = true
		2:  # Near - full detail
			body_orb.visible = true
			particles.visible = true
			glow_light.visible = true
			name_label.visible = true

# Save/Load support
func serialize() -> Dictionary:
	return {
		"being_name": being_name,
		"being_color": being_color.to_html(),
		"consciousness_level": consciousness_level,
		"position": position,
		"current_state": current_state,
		"behavior_script": behavior_script,
		"energy": energy
	}

func deserialize(data: Dictionary):
	being_name = data.get("being_name", being_name)
	being_color = Color(data.get("being_color", "#80CCFF"))
	consciousness_level = data.get("consciousness_level", 1.0)
	position = data.get("position", position)
	current_state = data.get("current_state", ActionState.HOVERING)
	behavior_script = data.get("behavior_script", [])
	energy = data.get("energy", 100.0)
	
	# Update visuals
	_create_perfect_form()