extends Node3D

# Multiverse Shape Visualizer for JSH Ethereal Engine
# Transforms abstract concepts and stories into 3D visual representations
# across different reality zones and scales

# ------ Configuration ------
export var transition_speed: float = 1.5
export var shape_complexity_max: int = 5
export var use_procedural_generation: bool = true
export var connect_to_word_system: bool = true
export var enable_dream_shapes: bool = true

# ------ Shape Libraries ------
var basic_shapes = ["sphere", "cube", "cylinder", "torus", "pyramid", "plane"]
var complex_shapes = ["fractal", "nebula", "constellation", "wave", "spiral", "vortex"]
var dream_shapes = ["memory_fragment", "thought_bubble", "imagination_flow", "dream_crystal", "nightmare_shadow"]

# ------ Node References ------
var shape_container: Node3D
var transition_animator: AnimationPlayer
var particle_systems: Dictionary = {}
var shape_instances: Dictionary = {}
var current_zone_id: String = ""

# ------ Material Libraries ------
var shape_materials: Dictionary = {}
var zone_materials: Dictionary = {}
var transition_materials: Dictionary = {}

# ------ Signals ------
signal shape_transformed(old_shape, new_shape)
signal zone_transition_completed(old_zone, new_zone)
signal shape_story_updated(shape_id, story_fragment)

# ------ System References ------
var multiverse_system = null
var word_manifestor = null

# ========== Initialization ==========

func _ready():
	initialize_nodes()
	initialize_materials()
	initialize_particle_systems()
	
	if connect_to_word_system:
		connect_word_system()

func initialize_nodes():
	# Create shape container if it doesn't exist
	if not shape_container:
		shape_container = Node3D.new()
		shape_container.name = "ShapeContainer"
		add_child(shape_container)
	
	# Create animation player if it doesn't exist
	if not transition_animator:
		transition_animator = AnimationPlayer.new()
		transition_animator.name = "TransitionAnimator"
		add_child(transition_animator)
		create_default_animations()

func initialize_materials():
	# Create base materials for each basic shape
	for shape_name in basic_shapes:
		var material = StandardMaterial3D.new()
		material.metallic = 0.3
		material.roughness = 0.2
		
		match shape_name:
			"sphere":
				material.albedo_color = Color(0.2, 0.4, 0.8)
			"cube":
				material.albedo_color = Color(0.8, 0.2, 0.2)
			"cylinder":
				material.albedo_color = Color(0.2, 0.8, 0.2)
			"torus":
				material.albedo_color = Color(0.8, 0.8, 0.2)
			"pyramid":
				material.albedo_color = Color(0.8, 0.2, 0.8)
			"plane":
				material.albedo_color = Color(0.4, 0.4, 0.4)
		
		shape_materials[shape_name] = material
	
	# Create zone materials
	var zones = ["physical", "digital", "astral", "dream", "quantum", "conceptual"]
	for zone_name in zones:
		var material = StandardMaterial3D.new()
		material.metallic = 0.5
		material.roughness = 0.1
		material.emission_enabled = true
		
		match zone_name:
			"physical":
				material.albedo_color = Color(0.1, 0.3, 0.7)
				material.emission = Color(0.0, 0.1, 0.3) * 0.5
			"digital":
				material.albedo_color = Color(0.1, 0.7, 0.3)
				material.emission = Color(0.0, 0.3, 0.1) * 0.5
			"astral":
				material.albedo_color = Color(0.7, 0.3, 0.7)
				material.emission = Color(0.3, 0.1, 0.3) * 0.5
			"dream":
				material.albedo_color = Color(0.3, 0.1, 0.7)
				material.emission = Color(0.1, 0.0, 0.3) * 0.5
			"quantum":
				material.albedo_color = Color(0.7, 0.7, 0.1)
				material.emission = Color(0.3, 0.3, 0.0) * 0.5
			"conceptual":
				material.albedo_color = Color(0.7, 0.1, 0.1)
				material.emission = Color(0.3, 0.0, 0.0) * 0.5
		
		zone_materials[zone_name] = material
	
	# Create transition materials
	var transition_shader = load("res://shaders/transition_shader.tres")
	if transition_shader:
		var transition_mat = ShaderMaterial.new()
		transition_mat.shader = transition_shader
		transition_materials["default"] = transition_mat

func initialize_particle_systems():
	# Create particle systems for different effects
	var effect_types = ["transform", "evolve", "shift", "dream"]
	
	for effect in effect_types:
		var particles = GPUParticles3D.new()
		particles.name = effect + "_particles"
		particles.emitting = false
		particles.one_shot = true
		particles.explosiveness = 0.8
		
		var material = ParticleProcessMaterial.new()
		material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		material.emission_sphere_radius = 1.0
		material.direction = Vector3(0, 1, 0)
		material.spread = 180.0
		material.gravity = Vector3(0, -0.5, 0)
		
		match effect:
			"transform":
				material.color = Color(0.8, 0.4, 0.1)
				particles.amount = 100
				particles.lifetime = 1.5
			"evolve":
				material.color = Color(0.1, 0.8, 0.4)
				particles.amount = 50
				particles.lifetime = 2.0
			"shift":
				material.color = Color(0.4, 0.1, 0.8)
				particles.amount = 200
				particles.lifetime = 1.0
			"dream":
				material.color = Color(0.7, 0.7, 0.9)
				particles.amount = 150
				particles.lifetime = 3.0
		
		particles.process_material = material
		add_child(particles)
		particle_systems[effect] = particles

func create_default_animations():
	# Create default transition animations
	
	# Fade transition
	var fade_anim = Animation.new()
	var track_idx = fade_anim.add_track(Animation.TYPE_VALUE)
	fade_anim.track_set_path(track_idx, ".:transparency")
	fade_anim.track_insert_key(track_idx, 0.0, 0.0)
	fade_anim.track_insert_key(track_idx, 0.5, 1.0)
	fade_anim.track_insert_key(track_idx, 1.0, 0.0)
	fade_anim.length = 1.0
	
	transition_animator.add_animation("fade", fade_anim)
	
	# Scale transition
	var scale_anim = Animation.new()
	track_idx = scale_anim.add_track(Animation.TYPE_VALUE)
	scale_anim.track_set_path(track_idx, ".:scale")
	scale_anim.track_insert_key(track_idx, 0.0, Vector3(1, 1, 1))
	scale_anim.track_insert_key(track_idx, 0.5, Vector3(0.1, 0.1, 0.1))
	scale_anim.track_insert_key(track_idx, 1.0, Vector3(1, 1, 1))
	scale_anim.length = 1.0
	
	transition_animator.add_animation("scale", scale_anim)
	
	# Rotation transition
	var rotation_anim = Animation.new()
	track_idx = rotation_anim.add_track(Animation.TYPE_VALUE)
	rotation_anim.track_set_path(track_idx, ".:rotation")
	rotation_anim.track_insert_key(track_idx, 0.0, Vector3(0, 0, 0))
	rotation_anim.track_insert_key(track_idx, 1.0, Vector3(0, TAU, 0))
	rotation_anim.length = 1.0
	
	transition_animator.add_animation("rotation", rotation_anim)

func connect_word_system():
	# Connect to word manifestor if available in scene
	word_manifestor = get_node_or_null("/root/WordManifestor")
	if not word_manifestor:
		word_manifestor = get_node_or_null("../WordManifestor")
	
	if word_manifestor:
		if word_manifestor.has_signal("word_manifested"):
			word_manifestor.connect("word_manifested", self, "_on_word_manifested")
		print("JSH Shape Visualizer: Connected to Word Manifestor")

# ========== Shape Creation and Management ==========

func create_shape(shape_type: String, position: Vector3, properties: Dictionary = {}) -> Node3D:
	var shape_node: Node3D
	
	match shape_type:
		"sphere":
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = SphereMesh.new()
			shape_node = mesh_instance
		"cube":
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = BoxMesh.new()
			shape_node = mesh_instance
		"cylinder":
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = CylinderMesh.new()
			shape_node = mesh_instance
		"torus":
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = TorusMesh.new()
			shape_node = mesh_instance
		"pyramid":
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = PrismMesh.new()
			shape_node = mesh_instance
		"plane":
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = PlaneMesh.new()
			shape_node = mesh_instance
		_:
			# Default to sphere if shape not recognized
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = SphereMesh.new()
			shape_node = mesh_instance
	
	# Apply material based on shape type
	if shape_node is MeshInstance3D:
		if shape_materials.has(shape_type):
			shape_node.material_override = shape_materials[shape_type]
	
	# Apply properties
	shape_node.position = position
	
	if properties.has("scale"):
		shape_node.scale = properties.scale
	
	if properties.has("rotation"):
		shape_node.rotation = properties.rotation
	
	if properties.has("zone") and zone_materials.has(properties.zone):
		if shape_node is MeshInstance3D:
			shape_node.material_override = zone_materials[properties.zone]
	
	# Add to scene
	shape_container.add_child(shape_node)
	
	# Generate a unique ID for this shape
	var shape_id = "shape_" + str(shape_container.get_child_count())
	shape_instances[shape_id] = shape_node
	
	return shape_node

func transform_shape(shape_id: String, new_type: String, duration: float = 1.0):
	if not shape_instances.has(shape_id):
		print("JSH Shape Visualizer: Shape ID not found - " + shape_id)
		return null
	
	var old_shape = shape_instances[shape_id]
	var old_transform = old_shape.global_transform
	
	# Create new shape
	var new_shape = create_shape(new_type, old_transform.origin)
	new_shape.scale = Vector3(0.1, 0.1, 0.1)  # Start small
	
	# Play transformation effect
	if particle_systems.has("transform"):
		var particles = particle_systems["transform"]
		particles.global_position = old_transform.origin
		particles.emitting = true
	
	# Animate transition
	var tween = create_tween()
	tween.tween_property(old_shape, "scale", Vector3(0.1, 0.1, 0.1), duration * 0.5)
	tween.parallel().tween_property(old_shape, "rotation", old_shape.rotation + Vector3(0, PI, 0), duration * 0.5)
	
	tween.tween_callback(self, "_on_transform_halfway", [old_shape, new_shape, shape_id])
	
	tween.tween_property(new_shape, "scale", Vector3(1, 1, 1), duration * 0.5)
	
	return new_shape

func _on_transform_halfway(old_shape, new_shape, shape_id):
	# Remove old shape
	old_shape.queue_free()
	
	# Update dictionary reference
	shape_instances[shape_id] = new_shape
	
	emit_signal("shape_transformed", old_shape, new_shape)

func create_procedural_shape(complexity: int, position: Vector3, zone_type: String = "physical") -> Node3D:
	# Create a procedurally generated shape based on complexity level
	# Higher complexity = more detailed and intricate shapes
	
	# For now, we'll use a simplified version that combines basic shapes
	var container = Node3D.new()
	container.position = position
	
	var core_shape_type = basic_shapes[randi() % basic_shapes.size()]
	var core_shape = create_shape(core_shape_type, Vector3.ZERO)
	container.add_child(core_shape)
	
	# Add satellite shapes based on complexity
	for i in range(min(complexity, 5)):
		var satellite_type = basic_shapes[randi() % basic_shapes.size()]
		var orbit_radius = 0.5 + (0.3 * i)
		var orbit_angle = TAU * (i / float(complexity))
		var satellite_pos = Vector3(
			orbit_radius * cos(orbit_angle),
			0.2 * sin(orbit_radius),
			orbit_radius * sin(orbit_angle)
		)
		
		var satellite = create_shape(satellite_type, satellite_pos)
		satellite.scale = Vector3(0.3, 0.3, 0.3) * (1.0 - (i * 0.1))
		container.add_child(satellite)
	
	# Apply zone-specific material to all children
	if zone_materials.has(zone_type):
		for child in container.get_children():
			if child is MeshInstance3D:
				child.material_override = zone_materials[zone_type]
	
	shape_container.add_child(container)
	
	# Apply random rotation animation
	var tween = create_tween()
	tween.tween_property(container, "rotation", Vector3(randf(), TAU * randf(), randf()), 10.0 + (randf() * 20.0))
	tween.set_loops()
	
	# Generate a unique ID for this procedural shape
	var shape_id = "proc_" + str(shape_container.get_child_count())
	shape_instances[shape_id] = container
	
	return container

# ========== Zone and Reality Transitions ==========

func transition_to_zone(zone_id: String, transition_type: String = "fade", duration: float = 2.0):
	# Save current zone
	var old_zone_id = current_zone_id
	current_zone_id = zone_id
	
	# Play appropriate particle effect
	if particle_systems.has("shift"):
		var particles = particle_systems["shift"]
		particles.emitting = true
	
	# Play transition animation
	if transition_animator.has_animation(transition_type):
		transition_animator.play(transition_type)
		
		# Set up completion callback
		await transition_animator.animation_finished
		_on_zone_transition_completed(old_zone_id, zone_id)
	else:
		# Fallback if animation doesn't exist
		await get_tree().create_timer(duration).timeout
		_on_zone_transition_completed(old_zone_id, zone_id)
	
	return true

func _on_zone_transition_completed(old_zone_id: String, new_zone_id: String):
	print("JSH Shape Visualizer: Transitioned from " + old_zone_id + " to " + new_zone_id)
	
	# Update all shape materials to match new zone
	if zone_materials.has(new_zone_id):
		for shape_id in shape_instances:
			var shape = shape_instances[shape_id]
			
			if shape is MeshInstance3D:
				# Create a blend between shape material and zone material
				var original_material = shape.material_override
				var zone_material = zone_materials[new_zone_id]
				
				var blended_material = StandardMaterial3D.new()
				blended_material.albedo_color = original_material.albedo_color.lerp(zone_material.albedo_color, 0.3)
				
				if zone_material.emission_enabled:
					blended_material.emission_enabled = true
					blended_material.emission = zone_material.emission
				
				shape.material_override = blended_material
	
	# Emit signal
	emit_signal("zone_transition_completed", old_zone_id, new_zone_id)

# ========== Dream and Story Shapes ==========

func create_dream_shape_from_story(story_fragment: String, position: Vector3) -> Node3D:
	if not enable_dream_shapes:
		return null
	
	# Parse the story fragment to determine shape characteristics
	var complexity = 1 + (story_fragment.length() % 5)  # 1-5 based on length
	var dream_type = dream_shapes[story_fragment.length() % dream_shapes.size()]
	
	# Create base container
	var dream_container = Node3D.new()
	dream_container.position = position
	
	# Words in the story influence the dream shape composition
	var words = story_fragment.split(" ")
	var word_count = min(words.size(), 8)  # Limit to 8 shapes max
	
	for i in range(word_count):
		var word = words[i]
		var shape_type = basic_shapes[word.length() % basic_shapes.size()]
		
		# Position based on word position in story
		var angle = TAU * (i / float(word_count))
		var radius = 0.5 + (0.2 * i)
		var vertical_offset = 0.1 * sin(i * 0.7)
		
		var pos = Vector3(
			radius * cos(angle),
			vertical_offset,
			radius * sin(angle)
		)
		
		var shape = create_shape(shape_type, pos, {"zone": "dream"})
		shape.scale = Vector3(0.2, 0.2, 0.2) * (1.0 - (i * 0.05))
		
		# Apply animation based on word length
		var tween = create_tween()
		tween.tween_property(shape, "rotation", 
			Vector3(word.length() * 0.1, word.length() * 0.2, word.length() * 0.1), 
			5.0 + (word.length() * 0.5))
		tween.set_loops()
		
		dream_container.add_child(shape)
	
	# Apply dream particles
	if particle_systems.has("dream"):
		var particles = particle_systems["dream"]
		var particles_instance = particles.duplicate()
		particles_instance.emitting = true
		dream_container.add_child(particles_instance)
	
	shape_container.add_child(dream_container)
	
	# Generate a unique ID
	var dream_id = "dream_" + str(shape_container.get_child_count())
	shape_instances[dream_id] = dream_container
	
	# Emit signal with story information
	emit_signal("shape_story_updated", dream_id, story_fragment)
	
	return dream_container

# ========== Signal Handlers ==========

func _on_word_manifested(word: String, position: Vector3):
	if not connect_to_word_system:
		return
	
	# Create a shape based on the manifested word
	var shape_type = basic_shapes[word.length() % basic_shapes.size()]
	var shape = create_shape(shape_type, position)
	
	# Add label with the word text
	var label = Label3D.new()
	label.text = word
	label.pixel_size = 0.01
	label.position = Vector3(0, 0.5, 0)
	shape.add_child(label)
	
	# Apply pulsing effect
	var tween = create_tween()
	tween.tween_property(shape, "scale", Vector3(1.1, 1.1, 1.1), 1.0)
	tween.tween_property(shape, "scale", Vector3(1.0, 1.0, 1.0), 1.0)
	tween.set_loops()
	
	print("JSH Shape Visualizer: Created shape for word: " + word)

# ========== Public API ==========

func create_shape_for_concept(concept: String, position: Vector3) -> Node3D:
	# Create a shape that represents an abstract concept
	var words = concept.split(" ")
	var core_word = words[0] if words.size() > 0 else concept
	
	var complexity = min(1 + (concept.length() / 10), shape_complexity_max)
	
	if use_procedural_generation:
		return create_procedural_shape(complexity, position, "conceptual")
	else:
		var shape_type = basic_shapes[core_word.length() % basic_shapes.size()]
		return create_shape(shape_type, position, {"zone": "conceptual"})

func visualize_reality_transition(old_reality: String, new_reality: String, duration: float = 2.0):
	# Create a visual effect for transitioning between realities
	
	# Play shift particles
	if particle_systems.has("shift"):
		var particles = particle_systems["shift"] 
		particles.emitting = true
		
		# Change particle color based on target reality
		if zone_materials.has(new_reality):
			var material = particles.process_material
			material.color = zone_materials[new_reality].albedo_color
	
	# Apply visual effect to all shapes
	for shape_id in shape_instances:
		var shape = shape_instances[shape_id]
		
		# Create scale/fade effect
		var tween = create_tween()
		tween.tween_property(shape, "scale", shape.scale * 0.8, duration * 0.5)
		tween.tween_property(shape, "scale", shape.scale, duration * 0.5)
		
		# Apply new zone material gradually
		if shape is MeshInstance3D and zone_materials.has(new_reality):
			var original_material = shape.material_override
			var target_material = zone_materials[new_reality]
			
			if original_material and target_material:
				var blend_material = StandardMaterial3D.new()
				blend_material.albedo_color = original_material.albedo_color.lerp(target_material.albedo_color, 0.5)
				
				if target_material.emission_enabled:
					blend_material.emission_enabled = true
					blend_material.emission = target_material.emission
				
				shape.material_override = blend_material
	
	return true

func clear_all_shapes():
	# Remove all shapes from the scene
	for shape_id in shape_instances:
		if shape_instances[shape_id]:
			shape_instances[shape_id].queue_free()
	
	shape_instances.clear()
	
	# Also clear any leftover children in the container
	for child in shape_container.get_children():
		child.queue_free()
	
	print("JSH Shape Visualizer: Cleared all shapes")

func get_shape_count() -> int:
	return shape_instances.size()

func update_shape_position(shape_id: String, new_position: Vector3, duration: float = 1.0):
	if not shape_instances.has(shape_id):
		return false
	
	var shape = shape_instances[shape_id]
	
	var tween = create_tween()
	tween.tween_property(shape, "position", new_position, duration)
	
	return true