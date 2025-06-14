extends Node
class_name EntityBehaviorSystem

# Singleton instance
static var _instance = null

static func get_instance() -> EntityBehaviorSystem:
	if not _instance:
		_instance = EntityBehaviorSystem.new()
	return _instance

# References
var thing_creator = null
var ray_caster = null

# Behavior settings
var behavior_active = true
var update_interval = 0.5 # Seconds between behavior updates
var update_timer = 0.0

# Entity tracking
var interactive_entities = {}  # Map of entity_id to interaction data
var selected_entity = null
var hovered_entity = null

# Behavior definitions for entity types
var behavior_definitions = {
	"fire": {
		"hover_response": "grow",
		"click_response": "flame_burst",
		"nearby_responses": {
			"water": "diminish",
			"wood": "spread",
			"air": "intensify"
		},
		"autonomous_behaviors": ["flicker", "emit_particles"],
		"movement_pattern": "slight_bob"
	},
	"water": {
		"hover_response": "ripple",
		"click_response": "splash",
		"nearby_responses": {
			"fire": "evaporate",
			"earth": "flow_around",
			"wood": "be_absorbed"
		},
		"autonomous_behaviors": ["flow", "shimmer"],
		"movement_pattern": "gentle_wave"
	},
	"earth": {
		"hover_response": "rumble",
		"click_response": "crack",
		"nearby_responses": {
			"water": "erode",
			"fire": "harden",
			"metal": "enrich"
		},
		"autonomous_behaviors": ["settle", "erode"],
		"movement_pattern": "stationary_with_slight_rotation"
	},
	"air": {
		"hover_response": "wisp",
		"click_response": "gust",
		"nearby_responses": {
			"fire": "fan",
			"water": "create_mist",
			"earth": "dust_cloud"
		},
		"autonomous_behaviors": ["swirl", "dissipate"],
		"movement_pattern": "drift"
	},
	"crystal": {
		"hover_response": "glow",
		"click_response": "refract",
		"nearby_responses": {
			"light": "amplify",
			"dark": "absorb",
			"sound": "resonate"
		},
		"autonomous_behaviors": ["pulse", "hum"],
		"movement_pattern": "slow_rotation"
	},
	"light_mote": {
		"hover_response": "brighten",
		"click_response": "flash",
		"nearby_responses": {
			"dark": "diminish",
			"crystal": "refract",
			"void": "flicker"
		},
		"autonomous_behaviors": ["pulse", "orbit"],
		"movement_pattern": "erratic_float"
	},
	"void_spark": {
		"hover_response": "distort",
		"click_response": "implode",
		"nearby_responses": {
			"light": "consume",
			"matter": "pull",
			"energy": "absorb"
		},
		"autonomous_behaviors": ["pulse_negative", "draw_in"],
		"movement_pattern": "slow_orbit"
	},
	# Default for when no specific type is matched
	"default": {
		"hover_response": "highlight",
		"click_response": "bounce",
		"nearby_responses": {},
		"autonomous_behaviors": ["idle"],
		"movement_pattern": "none"
	}
}

# Movement patterns
var movement_patterns = {
	"none": funcref(self, "_movement_none"),
	"slight_bob": funcref(self, "_movement_slight_bob"),
	"gentle_wave": funcref(self, "_movement_gentle_wave"),
	"drift": funcref(self, "_movement_drift"),
	"erratic_float": funcref(self, "_movement_erratic_float"),
	"slow_rotation": funcref(self, "_movement_slow_rotation"),
	"stationary_with_slight_rotation": funcref(self, "_movement_stationary_with_slight_rotation"),
	"slow_orbit": funcref(self, "_movement_slow_orbit")
}

# Behavior responses
var behavior_responses = {
	# Hover responses
	"highlight": funcref(self, "_response_highlight"),
	"grow": funcref(self, "_response_grow"),
	"ripple": funcref(self, "_response_ripple"),
	"rumble": funcref(self, "_response_rumble"),
	"wisp": funcref(self, "_response_wisp"),
	"glow": funcref(self, "_response_glow"),
	"brighten": funcref(self, "_response_brighten"),
	"distort": funcref(self, "_response_distort"),
	
	# Click responses
	"bounce": funcref(self, "_response_bounce"),
	"flame_burst": funcref(self, "_response_flame_burst"),
	"splash": funcref(self, "_response_splash"),
	"crack": funcref(self, "_response_crack"),
	"gust": funcref(self, "_response_gust"),
	"refract": funcref(self, "_response_refract"),
	"flash": funcref(self, "_response_flash"),
	"implode": funcref(self, "_response_implode"),
	
	# Nearby responses
	"diminish": funcref(self, "_response_diminish"),
	"spread": funcref(self, "_response_spread"),
	"intensify": funcref(self, "_response_intensify"),
	"evaporate": funcref(self, "_response_evaporate"),
	"flow_around": funcref(self, "_response_flow_around"),
	"be_absorbed": funcref(self, "_response_be_absorbed"),
	"erode": funcref(self, "_response_erode"),
	"harden": funcref(self, "_response_harden"),
	"enrich": funcref(self, "_response_enrich"),
	"fan": funcref(self, "_response_fan"),
	"create_mist": funcref(self, "_response_create_mist"),
	"dust_cloud": funcref(self, "_response_dust_cloud"),
	"amplify": funcref(self, "_response_amplify"),
	"absorb": funcref(self, "_response_absorb"),
	"resonate": funcref(self, "_response_resonate"),
	"consume": funcref(self, "_response_consume"),
	"pull": funcref(self, "_response_pull"),
	
	# Autonomous behaviors
	"idle": funcref(self, "_behavior_idle"),
	"flicker": funcref(self, "_behavior_flicker"),
	"emit_particles": funcref(self, "_behavior_emit_particles"),
	"flow": funcref(self, "_behavior_flow"),
	"shimmer": funcref(self, "_behavior_shimmer"),
	"settle": funcref(self, "_behavior_settle"),
	"erode": funcref(self, "_behavior_erode"),
	"swirl": funcref(self, "_behavior_swirl"),
	"dissipate": funcref(self, "_behavior_dissipate"),
	"pulse": funcref(self, "_behavior_pulse"),
	"hum": funcref(self, "_behavior_hum"),
	"orbit": funcref(self, "_behavior_orbit"),
	"pulse_negative": funcref(self, "_behavior_pulse_negative"),
	"draw_in": funcref(self, "_behavior_draw_in")
}

func _init():
	name = "EntityBehaviorSystem"

func _ready():
	# Find the thing creator
	if has_node("/root/CoreThingCreator"):
		thing_creator = get_node("/root/CoreThingCreator")
	else:
		var ThingCreator = load("res://code/gdscript/scripts/core/CoreThingCreator.gd")
		if ThingCreator:
			thing_creator = ThingCreator.get_instance()
			
	# Set up ray casting for entity picking
	ray_caster = RayCast3D.new()
	ray_caster.name = "EntityRayCaster"
	ray_caster.enabled = true
	ray_caster.collision_mask = 1
	ray_caster.collide_with_areas = true
	
	# Add ray caster to the camera
	var camera = find_camera()
	if camera:
		camera.add_child(ray_caster)
		
	# Set up input handling
	set_process_input(true)
	
	# Register for entity creation notifications from thing creator
	if thing_creator:
		thing_creator.connect("entity_created", _on_entity_created)
		thing_creator.connect("entity_transformed", _on_entity_transformed)
		thing_creator.connect("entity_evolved", _on_entity_evolved)

func _process(delta):
	if not behavior_active:
		return
		
	# Update behaviors on interval
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0
		_update_entity_behaviors()
		
	# Update ray cast direction for entity picking
	if ray_caster:
		var camera = ray_caster.get_parent()
		if camera is Camera3D:
			var mouse_pos = get_viewport().get_mouse_position()
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * 1000
			ray_caster.global_position = from
			ray_caster.target_position = to - from
			
			# Check for hover entity
			var new_hovered = _get_entity_under_mouse()
			if new_hovered != hovered_entity:
				if hovered_entity:
					_on_entity_mouse_exit(hovered_entity)
				hovered_entity = new_hovered
				if hovered_entity:
					_on_entity_mouse_enter(hovered_entity)

func _input(event):
	if not behavior_active:
		return
		
	# Handle mouse clicks
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_entity = _get_entity_under_mouse()
		if clicked_entity:
			_on_entity_clicked(clicked_entity)
			selected_entity = clicked_entity
		else:
			selected_entity = null

# Tracks a newly created entity for behaviors
func _on_entity_created(entity_id, word, position):
	if thing_creator:
		var entity = thing_creator.get_entity(entity_id)
		if entity:
			# Prepare interactive data
			var entity_type = entity.entity_type if entity.has("entity_type") else "default"
			var entity_form = entity.current_form if entity.has("current_form") else "default"
			
			# Use form or type to determine behaviors
			var behavior_key = entity_form
			if not behavior_definitions.has(behavior_key):
				behavior_key = entity_type
			if not behavior_definitions.has(behavior_key):
				behavior_key = "default"
			
			# Apply interaction behaviors
			interactive_entities[entity_id] = {
				"entity": entity,
				"behavior_key": behavior_key,
				"type": entity_type,
				"form": entity_form,
				"position": position,
				"last_update": 0,
				"state": {
					"hover": false,
					"selected": false,
					"autonomous_state": {}
				}
			}
			
			# Set up the entity for interaction
			_setup_entity_for_interaction(entity_id)

# Updates tracked entity when it transforms
func _on_entity_transformed(entity_id, old_form, new_form):
	if interactive_entities.has(entity_id):
		interactive_entities[entity_id].form = new_form
		
		# Update behavior key based on new form
		var behavior_key = new_form
		if not behavior_definitions.has(behavior_key):
			behavior_key = interactive_entities[entity_id].type
		if not behavior_definitions.has(behavior_key):
			behavior_key = "default"
			
		interactive_entities[entity_id].behavior_key = behavior_key

# Updates tracked entity when it evolves
func _on_entity_evolved(entity_id, old_stage, new_stage):
	if interactive_entities.has(entity_id):
		interactive_entities[entity_id].state.evolution_stage = new_stage

# Sets up an entity for interaction
func _setup_entity_for_interaction(entity_id):
	if not interactive_entities.has(entity_id) or not thing_creator:
		return
		
	var entity = thing_creator.get_entity(entity_id)
	if not entity:
		return
		
	# Set up collision for interaction if needed
	if entity is Node3D:
		var has_collision = false
		
		# Check if entity already has collision
		for child in entity.get_children():
			if child is CollisionShape3D or child is Area3D:
				has_collision = true
				break
		
		# Add collision if needed
		if not has_collision:
			var area = Area3D.new()
			area.name = "InteractionArea"
			
			var collision = CollisionShape3D.new()
			collision.name = "CollisionShape"
			
			var shape = SphereShape3D.new()
			shape.radius = 0.5  # Default radius
			collision.shape = shape
			
			area.add_child(collision)
			entity.add_child(area)
			
			# Set interaction data
			area.set_meta("entity_id", entity_id)

# Update behaviors for all entities
func _update_entity_behaviors():
	for entity_id in interactive_entities:
		var data = interactive_entities[entity_id]
		var entity = data.entity
		
		if not is_instance_valid(entity):
			continue
			
		# Get behavior definition
		var behavior_key = data.behavior_key
		var definition = behavior_definitions.get(behavior_key, behavior_definitions.default)
		
		# Apply movement pattern
		var pattern_name = definition.movement_pattern
		if movement_patterns.has(pattern_name):
			movement_patterns[pattern_name].call_func(entity_id, entity)
		
		# Apply autonomous behaviors
		for behavior in definition.autonomous_behaviors:
			if behavior_responses.has(behavior):
				behavior_responses[behavior].call_func(entity_id, entity)
		
		# Check for nearby entity interactions
		_check_nearby_entity_interactions(entity_id, entity, definition)

# Check for interactions with nearby entities
func _check_nearby_entity_interactions(entity_id, entity, definition):
	if not entity is Node3D:
		return
		
	var nearby_responses = definition.nearby_responses
	if nearby_responses.is_empty():
		return
		
	# Find nearby entities
	var entity_pos = entity.global_position
	var nearby_range = 2.0  # Units for nearby check
	
	for other_id in interactive_entities:
		if other_id == entity_id:
			continue
			
		var other_data = interactive_entities[other_id]
		var other_entity = other_data.entity
		
		if not is_instance_valid(other_entity) or not other_entity is Node3D:
			continue
			
		# Check if in range
		var other_pos = other_entity.global_position
		var distance = entity_pos.distance_to(other_pos)
		
		if distance <= nearby_range:
			# Check if there's a response for this entity type
			var other_type = other_data.behavior_key
			if nearby_responses.has(other_type):
				var response_name = nearby_responses[other_type]
				if behavior_responses.has(response_name):
					behavior_responses[response_name].call_func(entity_id, entity, other_id, other_entity)

# Handle entity mouse enter
func _on_entity_mouse_enter(entity_id):
	if not interactive_entities.has(entity_id):
		return
		
	var data = interactive_entities[entity_id]
	data.state.hover = true
	
	# Get hover response
	var definition = behavior_definitions.get(data.behavior_key, behavior_definitions.default)
	var response_name = definition.hover_response
	
	if behavior_responses.has(response_name):
		behavior_responses[response_name].call_func(entity_id, data.entity)

# Handle entity mouse exit
func _on_entity_mouse_exit(entity_id):
	if not interactive_entities.has(entity_id):
		return
		
	var data = interactive_entities[entity_id]
	data.state.hover = false
	
	# Reset hover state
	if data.entity is Node3D:
		data.entity.scale = Vector3(1, 1, 1)

# Handle entity click
func _on_entity_clicked(entity_id):
	if not interactive_entities.has(entity_id):
		return
		
	var data = interactive_entities[entity_id]
	
	# Get click response
	var definition = behavior_definitions.get(data.behavior_key, behavior_definitions.default)
	var response_name = definition.click_response
	
	if behavior_responses.has(response_name):
		behavior_responses[response_name].call_func(entity_id, data.entity)

# Get entity under mouse cursor
func _get_entity_under_mouse():
	if not ray_caster or not ray_caster.is_colliding():
		return null
		
	var collider = ray_caster.get_collider()
	if not collider:
		return null
		
	# Check if the collider has entity_id metadata
	if collider.has_meta("entity_id"):
		return collider.get_meta("entity_id")
		
	# Check if any parent has entity_id metadata
	var parent = collider.get_parent()
	while parent:
		if parent.has_meta("entity_id"):
			return parent.get_meta("entity_id")
		parent = parent.get_parent()
		
	return null

# Helper to find the camera
func find_camera():
	# Look for main camera paths
	var camera_paths = [
		"/root/main/Player_Head/cameramove/TrackballCamera",
		"/root/layer_0/Player_Head/cameramove/TrackballCamera",
		"/root/Main/Camera",
		"/root/Camera"
	]
	
	for path in camera_paths:
		if has_node(path):
			return get_node(path)
	
	# If not found in common paths, search the scene tree
	return _find_camera_in_tree(get_tree().root)

# Recursive camera finder
func _find_camera_in_tree(node):
	if node is Camera3D:
		return node
		
	for child in node.get_children():
		var found = _find_camera_in_tree(child)
		if found:
			return found
			
	return null

# ----- MOVEMENT PATTERN IMPLEMENTATIONS -----

func _movement_none(entity_id, entity):
	pass

func _movement_slight_bob(entity_id, entity):
	if not entity is Node3D:
		return
		
	var t = Time.get_ticks_msec() / 1000.0
	var new_y = entity.global_position.y + sin(t * 2) * 0.02
	entity.global_position.y = new_y

func _movement_gentle_wave(entity_id, entity):
	if not entity is Node3D:
		return
		
	var t = Time.get_ticks_msec() / 1000.0
	var new_y = entity.global_position.y + sin(t * 1.5) * 0.03
	var new_x = entity.global_position.x + cos(t * 0.8) * 0.02
	entity.global_position.y = new_y
	entity.global_position.x = new_x

func _movement_drift(entity_id, entity):
	if not entity is Node3D:
		return
		
	var t = Time.get_ticks_msec() / 1000.0
	var new_x = entity.global_position.x + sin(t * 0.5) * 0.02
	var new_z = entity.global_position.z + cos(t * 0.7) * 0.02
	entity.global_position.x = new_x
	entity.global_position.z = new_z

func _movement_erratic_float(entity_id, entity):
	if not entity is Node3D:
		return
		
	var t = Time.get_ticks_msec() / 1000.0
	var noise_val = sin(t * 3) * cos(t * 2.3) * 0.03
	entity.global_position += Vector3(
		sin(t * 2.7) * 0.02,
		noise_val,
		cos(t * 1.9) * 0.02
	)

func _movement_slow_rotation(entity_id, entity):
	if not entity is Node3D:
		return
		
	var t = Time.get_ticks_msec() / 1000.0
	entity.rotate_y(0.01)
	
	# Slight bob with rotation
	var new_y = entity.global_position.y + sin(t * 0.5) * 0.01
	entity.global_position.y = new_y

func _movement_stationary_with_slight_rotation(entity_id, entity):
	if not entity is Node3D:
		return
		
	entity.rotate_y(0.003)

func _movement_slow_orbit(entity_id, entity):
	if not entity is Node3D or not interactive_entities.has(entity_id):
		return
		
	var data = interactive_entities[entity_id]
	var original_pos = data.position
	var t = Time.get_ticks_msec() / 1000.0
	
	# Orbit around original position
	var radius = 0.5
	var new_x = original_pos.x + cos(t * 0.5) * radius
	var new_z = original_pos.z + sin(t * 0.5) * radius
	entity.global_position.x = new_x
	entity.global_position.z = new_z

# ----- BEHAVIOR RESPONSE IMPLEMENTATIONS -----

# Hover responses
func _response_highlight(entity_id, entity):
	if entity is Node3D:
		entity.scale = Vector3(1.1, 1.1, 1.1)

func _response_grow(entity_id, entity):
	if entity is Node3D:
		entity.scale = Vector3(1.2, 1.2, 1.2)

func _response_ripple(entity_id, entity):
	if entity is Node3D:
		# TODO: Add ripple shader effect
		entity.scale = Vector3(1.1, 0.9, 1.1)

func _response_rumble(entity_id, entity):
	if entity is Node3D:
		# Slight shake effect
		var offset = Vector3(
			randf_range(-0.02, 0.02),
			randf_range(-0.01, 0.01),
			randf_range(-0.02, 0.02)
		)
		entity.global_position += offset

func _response_wisp(entity_id, entity):
	if entity is Node3D:
		# Add trailing effect
		entity.scale = Vector3(1.1, 1.2, 1.1)
		# TODO: Add particle effect for wisp trail

func _response_glow(entity_id, entity):
	if entity is Node3D:
		# Find material to modify
		for child in entity.get_children():
			if child is MeshInstance3D and child.material_override:
				var material = child.material_override
				if material is StandardMaterial3D:
					material.emission_enabled = true
					material.emission = Color(1, 1, 1)
					material.emission_energy = 2.0

func _response_brighten(entity_id, entity):
	if entity is Node3D:
		# Find material to modify
		for child in entity.get_children():
			if child is MeshInstance3D and child.material_override:
				var material = child.material_override
				if material is StandardMaterial3D:
					material.emission_enabled = true
					material.emission = Color(1, 1, 0.8)
					material.emission_energy = 5.0

func _response_distort(entity_id, entity):
	if entity is Node3D:
		# Pulsing distortion effect
		var t = Time.get_ticks_msec() / 1000.0
		var scale_factor = 1.0 + sin(t * 10) * 0.1
		entity.scale = Vector3(scale_factor, 1/scale_factor, scale_factor)

# Click responses
func _response_bounce(entity_id, entity):
	if entity is Node3D:
		# Create a tween for bounce effect
		var tween = create_tween()
		var start_pos = entity.global_position
		var up_pos = start_pos + Vector3(0, 0.5, 0)
		
		# Up and down animation
		tween.tween_property(entity, "global_position", up_pos, 0.2)
		tween.tween_property(entity, "global_position", start_pos, 0.2)

func _response_flame_burst(entity_id, entity):
	if entity is Node3D:
		# Scale up and down quickly
		var tween = create_tween()
		tween.tween_property(entity, "scale", Vector3(1.5, 1.5, 1.5), 0.2)
		tween.tween_property(entity, "scale", Vector3(1.0, 1.0, 1.0), 0.3)
		
		# TODO: Add particle burst effect

func _response_splash(entity_id, entity):
	if entity is Node3D:
		# Flatten and then restore
		var tween = create_tween()
		tween.tween_property(entity, "scale", Vector3(1.4, 0.6, 1.4), 0.2)
		tween.tween_property(entity, "scale", Vector3(1.0, 1.0, 1.0), 0.3)
		
		# TODO: Add splash particle effect

func _response_crack(entity_id, entity):
	if entity is Node3D:
		# Quick shake then settle
		var tween = create_tween()
		var start_pos = entity.global_position
		
		# Shake effect
		for i in range(5):
			var offset = Vector3(
				randf_range(-0.05, 0.05),
				randf_range(-0.05, 0.05),
				randf_range(-0.05, 0.05)
			)
			tween.tween_property(entity, "global_position", start_pos + offset, 0.05)
			
		# Return to original position
		tween.tween_property(entity, "global_position", start_pos, 0.1)

func _response_gust(entity_id, entity):
	if entity is Node3D:
		# Stretch and push in one direction
		var tween = create_tween()
		tween.tween_property(entity, "scale", Vector3(1.5, 0.8, 1.0), 0.15)
		tween.tween_property(entity, "scale", Vector3(1.0, 1.0, 1.0), 0.2)
		
		# TODO: Add wind particle effect

func _response_refract(entity_id, entity):
	if entity is Node3D:
		# Find material to modify for rainbow effect
		for child in entity.get_children():
			if child is MeshInstance3D and child.material_override:
				var material = child.material_override
				if material is StandardMaterial3D:
					material.emission_enabled = true
					
					# Rainbow color rotation
					var tween = create_tween()
					var colors = [
						Color(1,0,0), # Red
						Color(1,0.5,0), # Orange
						Color(1,1,0), # Yellow
						Color(0,1,0), # Green
						Color(0,0,1), # Blue
						Color(0.5,0,1), # Indigo
						Color(1,0,1)  # Violet
					]
					
					for color in colors:
						tween.tween_property(material, "emission", color, 0.15)
					
					# Reset
					tween.tween_property(material, "emission_enabled", false, 0.2)

func _response_flash(entity_id, entity):
	if entity is Node3D:
		# Find material to create quick flash
		for child in entity.get_children():
			if child is MeshInstance3D and child.material_override:
				var material = child.material_override
				if material is StandardMaterial3D:
					# Store original values
					var original_albedo = material.albedo_color
					var original_emission = material.emission_enabled
					
					# Flash
					var tween = create_tween()
					material.emission_enabled = true
					material.emission = Color(1, 1, 1)
					material.emission_energy = 8.0
					material.albedo_color = Color(1, 1, 1)
					
					# Restore original
					tween.tween_interval(0.1)
					tween.tween_property(material, "emission_energy", 0.0, 0.2)
					tween.tween_property(material, "albedo_color", original_albedo, 0.2)
					tween.tween_property(material, "emission_enabled", original_emission, 0.0)

func _response_implode(entity_id, entity):
	if entity is Node3D:
		# Implode effect
		var tween = create_tween()
		tween.tween_property(entity, "scale", Vector3(0.1, 0.1, 0.1), 0.3)
		tween.tween_property(entity, "scale", Vector3(1.5, 1.5, 1.5), 0.1)
		tween.tween_property(entity, "scale", Vector3(1.0, 1.0, 1.0), 0.2)
		
		# TODO: Add implosion particle effect

# Nearby responses - these methods have additional parameters for the other entity
func _response_diminish(entity_id, entity, other_id, other_entity):
	if entity is Node3D:
		# Gradually become smaller when near opposing element
		var tween = create_tween()
		tween.tween_property(entity, "scale", Vector3(0.8, 0.8, 0.8), 0.5)
		tween.tween_property(entity, "scale", Vector3(1.0, 1.0, 1.0), 1.0)

func _response_spread(entity_id, entity, other_id, other_entity):
	if entity is Node3D and other_entity is Node3D:
		# Move slightly toward the other entity
		var direction = (other_entity.global_position - entity.global_position).normalized() * 0.1
		entity.global_position += direction

func _response_intensify(entity_id, entity, other_id, other_entity):
	if entity is Node3D:
		# Grow slightly and become more intense
		entity.scale = Vector3(1.1, 1.2, 1.1)
		
		# Find material to modify
		for child in entity.get_children():
			if child is MeshInstance3D and child.material_override:
				var material = child.material_override
				if material is StandardMaterial3D:
					material.emission_enabled = true
					material.emission_energy = 2.0

func _response_evaporate(entity_id, entity, other_id, other_entity):
	if entity is Node3D:
		# Start to rise and become more transparent
		entity.global_position.y += 0.05
		
		# Find material to modify
		for child in entity.get_children():
			if child is MeshInstance3D and child.material_override:
				var material = child.material_override
				if material is StandardMaterial3D:
					material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					material.albedo_color.a = 0.7

func _response_flow_around(entity_id, entity, other_id, other_entity):
	if entity is Node3D and other_entity is Node3D:
		# Flow around the other entity
		var direction = (entity.global_position - other_entity.global_position).normalized()
		direction = direction.rotated(Vector3.UP, PI/4)  # Add a bit of rotation to the avoidance
		entity.global_position += direction * 0.1

func _response_be_absorbed(entity_id, entity, other_id, other_entity):
	if entity is Node3D and other_entity is Node3D:
		# Move toward the other entity and become smaller
		var direction = (other_entity.global_position - entity.global_position).normalized() * 0.1
		entity.global_position += direction
		entity.scale = Vector3(0.9, 0.9, 0.9)

func _response_erode(entity_id, entity, other_id, other_entity):
	if entity is Node3D:
		# Slightly reduce and deform
		var tween = create_tween()
		tween.tween_property(entity, "scale", Vector3(0.95, 0.9, 0.95), 0.5)
		tween.tween_property(entity, "scale", Vector3(1.0, 1.0, 1.0), 1.0)

func _response_harden(entity_id, entity, other_id, other_entity):
	if entity is Node3D:
		# Become slightly smaller but more defined
		entity.scale = Vector3(0.95, 0.95, 0.95)
		
		# Find material to modify
		for child in entity.get_children():
			if child is MeshInstance3D and child.material_override:
				var material = child.material_override
				if material is StandardMaterial3D:
					material.metallic = 0.8
					material.roughness = 0.2

func _response_enrich(entity_id, entity, other_id, other_entity):
	if entity is Node3D:
		# Slight glow effect
		for child in entity.get_children():
			if child is MeshInstance3D and child.material_override:
				var material = child.material_override
				if material is StandardMaterial3D:
					material.emission_enabled = true
					material.emission_energy = 0.5

func _response_fan(entity_id, entity, other_id, other_entity):
	if entity is Node3D and other_entity is Node3D:
		# Intensify with increased size
		var tween = create_tween()
		tween.tween_property(entity, "scale", Vector3(1.2, 1.3, 1.2), 0.5)
		tween.tween_property(entity, "scale", Vector3(1.0, 1.0, 1.0), 1.0)

func _response_create_mist(entity_id, entity, other_id, other_entity):
	# TODO: Add mist particle effect
	pass

func _response_dust_cloud(entity_id, entity, other_id, other_entity):
	# TODO: Add dust particle effect
	pass

func _response_amplify(entity_id, entity, other_id, other_entity):
	if entity is Node3D:
		# Increase emission
		for child in entity.get_children():
			if child is MeshInstance3D and child.material_override:
				var material = child.material_override
				if material is StandardMaterial3D:
					material.emission_enabled = true
					material.emission_energy = 3.0

func _response_absorb(entity_id, entity, other_id, other_entity):
	if entity is Node3D:
		# Increase size slightly
		entity.scale = Vector3(1.05, 1.05, 1.05)

func _response_resonate(entity_id, entity, other_id, other_entity):
	if entity is Node3D:
		# Pulsing effect
		var t = Time.get_ticks_msec() / 1000.0
		var pulse = 1.0 + sin(t * 10) * 0.05
		entity.scale = Vector3(pulse, pulse, pulse)

func _response_consume(entity_id, entity, other_id, other_entity):
	if entity is Node3D and other_entity is Node3D:
		# Move toward the other entity
		var direction = (other_entity.global_position - entity.global_position).normalized() * 0.1
		entity.global_position += direction

func _response_pull(entity_id, entity, other_id, other_entity):
	if entity is Node3D and other_entity is Node3D:
		# Pull the other entity slightly
		var pull_dir = (entity.global_position - other_entity.global_position).normalized() * 0.05
		other_entity.global_position += pull_dir

# Autonomous behavior implementations
func _behavior_idle(entity_id, entity):
	pass  # Do nothing

func _behavior_flicker(entity_id, entity):
	if entity is Node3D:
		# Random slight scale changes for flame flicker
		var flicker = 1.0 + randf_range(-0.05, 0.05)
		entity.scale = Vector3(flicker, flicker + randf_range(-0.05, 0.05), flicker)

func _behavior_emit_particles(entity_id, entity):
	# This would typically create particles, handled in entity's visual system
	pass

func _behavior_flow(entity_id, entity):
	if entity is Node3D:
		# Gentle wave motion
		var t = Time.get_ticks_msec() / 1000.0
		var wave = sin(t * 2) * 0.03
		entity.global_position.y += wave

func _behavior_shimmer(entity_id, entity):
	if entity is Node3D:
		# Random slight emission changes
		for child in entity.get_children():
			if child is MeshInstance3D and child.material_override:
				var material = child.material_override
				if material is StandardMaterial3D and material.emission_enabled:
					material.emission_energy = 1.0 + randf_range(-0.2, 0.2)

func _behavior_settle(entity_id, entity):
	if entity is Node3D and entity.global_position.y > 0:
		# Gradually settle to ground
		entity.global_position.y = max(0, entity.global_position.y - 0.01)

func _behavior_erode(entity_id, entity):
	if not interactive_entities.has(entity_id):
		return
		
	# Track erosion in entity state
	var data = interactive_entities[entity_id]
	if not data.state.has("erosion"):
		data.state.erosion = 0.0
		
	data.state.erosion += 0.001
	
	if data.state.erosion > 0.1:
		# Apply erosion effect
		if entity is Node3D:
			entity.scale = Vector3(1.0 - data.state.erosion * 0.5, 
								  1.0 - data.state.erosion,
								  1.0 - data.state.erosion * 0.5)

func _behavior_swirl(entity_id, entity):
	if entity is Node3D:
		# Swirling motion
		var t = Time.get_ticks_msec() / 1000.0
		entity.rotate_y(0.02)

func _behavior_dissipate(entity_id, entity):
	if not interactive_entities.has(entity_id):
		return
		
	# Track dissipation in entity state
	var data = interactive_entities[entity_id]
	if not data.state.has("dissipation"):
		data.state.dissipation = 0.0
		
	data.state.dissipation += 0.0005
	
	if data.state.dissipation > 0.05:
		# Apply dissipation effect
		for child in entity.get_children():
			if child is MeshInstance3D and child.material_override:
				var material = child.material_override
				if material is StandardMaterial3D:
					material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					material.albedo_color.a = 1.0 - data.state.dissipation * 5

func _behavior_pulse(entity_id, entity):
	if entity is Node3D:
		# Pulsing effect
		var t = Time.get_ticks_msec() / 1000.0
		var pulse = 1.0 + sin(t * 3) * 0.05
		entity.scale = Vector3(pulse, pulse, pulse)

func _behavior_hum(entity_id, entity):
	# This would typically play a sound, we'll just do a small visual effect
	if entity is Node3D:
		var t = Time.get_ticks_msec() / 1000.0
		var hum = 1.0 + sin(t * 10) * 0.01
		entity.scale.y = hum

func _behavior_orbit(entity_id, entity):
	if not interactive_entities.has(entity_id):
		return
		
	# Track orbit center in entity state
	var data = interactive_entities[entity_id]
	if not data.state.has("orbit_center"):
		data.state.orbit_center = entity.global_position
		data.state.orbit_angle = 0.0
		data.state.orbit_radius = 0.2
		
	# Update orbit angle
	data.state.orbit_angle += 0.02
	
	# Calculate new position
	var center = data.state.orbit_center
	var radius = data.state.orbit_radius
	var angle = data.state.orbit_angle
	
	var new_pos = center + Vector3(
		cos(angle) * radius,
		sin(angle * 2) * radius * 0.5,
		sin(angle) * radius
	)
	
	entity.global_position = new_pos

func _behavior_pulse_negative(entity_id, entity):
	if entity is Node3D:
		# Negative pulse effect (shrinking and growing)
		var t = Time.get_ticks_msec() / 1000.0
		var pulse = 1.0 - sin(t * 2) * 0.1
		entity.scale = Vector3(pulse, pulse, pulse)

func _behavior_draw_in(entity_id, entity):
	# This would typically affect nearby entities, pulling them in
	pass