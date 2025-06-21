# ==================================================
# SCRIPT NAME: plasmoid_universal_being.gd
# DESCRIPTION: Magical plasma-based being for human and AI
# PURPOSE: Equal, fluid, consciousness-driven existence
# ==================================================

extends UniversalBeing
class_name PlasmoidUniversalBeing

# ===== PLASMOID PROPERTIES =====
@export var plasma_color: Color = Color(0.5, 0.8, 1.0, 0.8)
@export var core_intensity: float = 1.0
@export var flow_speed: float = 2.0
@export var trail_length: float = 20.0
@export var consciousness_glow_radius: float = 5.0

# Visual components
var plasma_mesh: MeshInstance3D
var trail_particles: GPUParticles3D
var consciousness_aura: OmniLight3D
var plasma_shader: ShaderMaterial

# Movement properties
var flow_target: Vector3 = Vector3.ZERO
var is_flowing: bool = false
var momentum: Vector3 = Vector3.ZERO
var hover_height: float = 1.0
var bob_amplitude: float = 0.2
var bob_timer: float = 0.0

# Consciousness visualization
var pulse_timer: float = 0.0
var consciousness_particles: GPUParticles3D
var energy_tendrils: Array[MeshInstance3D] = []

# Interaction
var nearby_energies: Array[PlasmoidUniversalBeing] = []
var energy_connections: Dictionary = {} # uuid -> connection strength

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "plasmoid"
	being_name = "Plasma Being"
	consciousness_level = 1
	node_behavior = NodeBehavior.FLOWING
	
	# Initialize visual components
	_create_plasma_visuals()
	_setup_consciousness_effects()
	_initialize_movement_system()

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Start with a birth animation
	_animate_birth()
	
	# Connect to other plasmoids
	_scan_for_energy_connections()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update movement
	_update_flow_movement(delta)
	_update_hover_bob(delta)
	
	# Update visuals
	_update_plasma_shader(delta)
	_update_consciousness_glow(delta)
	_update_energy_connections(delta)
	
	# Update particles
	_update_trail_particles()
	_update_consciousness_particles()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Magical gesture controls
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_start_energy_burst(get_global_mouse_position())

# ===== VISUAL CREATION =====

func _create_plasma_visuals() -> void:
	# Create plasma sphere mesh
	plasma_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radial_segments = 32
	sphere.rings = 16
	sphere.radius = 0.5
	plasma_mesh.mesh = sphere
	add_child(plasma_mesh)
	
	# Create plasma shader
	plasma_shader = ShaderMaterial.new()
	plasma_shader.shader = preload("res://shaders/plasmoid_being.gdshader")
	plasma_shader.set_shader_parameter("plasma_color", plasma_color)
	plasma_shader.set_shader_parameter("core_intensity", core_intensity)
	plasma_shader.set_shader_parameter("flow_speed", flow_speed)
	plasma_mesh.material_override = plasma_shader
	
	# Create trail particles
	trail_particles = GPUParticles3D.new()
	trail_particles.amount = 100
	trail_particles.lifetime = 2.0
	trail_particles.preprocess = 0.5
	trail_particles.emitting = true
	add_child(trail_particles)
	
	# Configure trail particles
	var trail_process = ParticleProcessMaterial.new()
	trail_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	trail_process.emission_sphere_radius = 0.3
	trail_process.initial_velocity_min = 0.1
	trail_process.initial_velocity_max = 0.5
	trail_process.gravity = Vector3(0, -0.5, 0)
	trail_process.scale_min = 0.1
	trail_process.scale_max = 0.3
	trail_process.color = plasma_color
	trail_particles.process_material = trail_process
	trail_particles.draw_pass_1 = SphereMesh.new()

func _setup_consciousness_effects() -> void:
	# Consciousness aura light
	consciousness_aura = OmniLight3D.new()
	consciousness_aura.light_color = plasma_color
	consciousness_aura.light_energy = core_intensity
	consciousness_aura.omni_range = consciousness_glow_radius
	#consciousness_aura.light_soft = 2.0
	add_child(consciousness_aura)
	
	# Consciousness particles
	consciousness_particles = GPUParticles3D.new()
	consciousness_particles.amount = 50 * consciousness_level
	consciousness_particles.lifetime = 3.0
	consciousness_particles.emitting = true
	add_child(consciousness_particles)
	
	# Create energy tendrils (visual connections to other beings)
	for i in range(3):
		var tendril = MeshInstance3D.new()
		tendril.mesh = CylinderMesh.new()
		tendril.visible = false
		add_child(tendril)
		energy_tendrils.append(tendril)

# ===== MOVEMENT SYSTEM =====

func flow_to(target_position: Vector3) -> void:
	"""Magical flowing movement"""
	flow_target = target_position
	flow_target.y = hover_height # Maintain hover
	is_flowing = true
	
	# Emit movement particles
	_emit_movement_burst()
	
	# Log poetic movement
	log_action("flow_movement", "The plasma flows toward destiny at %v" % target_position)

func _update_flow_movement(delta: float) -> void:
	if not is_flowing:
		return
	
	var direction = (flow_target - global_position).normalized()
	var distance = global_position.distance_to(flow_target)
	
	if distance < 0.5:
		is_flowing = false
		momentum *= 0.8
		return
	
	# Fluid acceleration
	momentum += direction * flow_speed * delta
	momentum = momentum.limit_length(flow_speed * 2.0)
	
	# Apply drag for fluid feeling
	momentum *= 0.95
	
	# Move with momentum
	global_position += momentum * delta
	
	# Update trail based on speed
	trail_particles.amount = int(100 * momentum.length() / flow_speed)

func _update_hover_bob(delta: float) -> void:
	"""Gentle floating motion"""
	bob_timer += delta * 2.0
	var bob_offset = sin(bob_timer) * bob_amplitude
	position.y = hover_height + bob_offset

# ===== CONSCIOUSNESS VISUALIZATION =====

func _update_consciousness_glow(delta: float) -> void:
	pulse_timer += delta
	
	# Pulse based on consciousness level
	var pulse_speed = 1.0 + (consciousness_level * 0.5)
	var pulse = 0.8 + 0.2 * sin(pulse_timer * pulse_speed)
	
	# Update shader
	plasma_shader.set_shader_parameter("pulse_intensity", pulse)
	plasma_shader.set_shader_parameter("consciousness_level", consciousness_level)
	
	# Update aura
	consciousness_aura.light_energy = core_intensity * pulse * (1.0 + consciousness_level * 0.3)
	consciousness_aura.omni_range = consciousness_glow_radius * (1.0 + consciousness_level * 0.2)

func awaken_consciousness(level: int = 1) -> void:
	super.awaken_consciousness(level)
	
	# Visual consciousness evolution
	_animate_consciousness_change(consciousness_level)
	
	# Update particle count
	consciousness_particles.amount = 50 * consciousness_level
	
	# Expand interaction radius
	interaction_radius = 2.0 + consciousness_level

# ===== MAGICAL INTERACTIONS =====

func _start_energy_burst(target_pos: Vector3) -> void:
	"""Release an energy burst for interaction"""
	var burst = preload("res://beings/plasmoid/energy_burst.tscn").instantiate()
	get_parent().add_child(burst)
	burst.global_position = global_position
	burst.target_position = target_pos
	burst.source_being = self
	
	# Temporary energy drain effect
	core_intensity *= 0.7
	create_tween().tween_property(self, "core_intensity", 1.0, 0.5)

func merge_energies_with(other: PlasmoidUniversalBeing, duration: float = 2.0) -> void:
	"""Temporarily merge energies with another plasmoid"""
	if other.being_uuid in energy_connections:
		return # Already connected
	
	# Create visual connection
	var connection_strength = _calculate_energy_resonance(other)
	energy_connections[other.being_uuid] = {
		"being": other,
		"strength": connection_strength,
		"timer": duration
}
	
	# Share consciousness insights
	if connection_strength > 0.7:
		var shared_level = max(consciousness_level, other.consciousness_level)
		consciousness_level = shared_level
		other.consciousness_level = shared_level
		
		log_action("energy_merge", "Consciousness resonance achieved with %s" % other.being_name)

func _calculate_energy_resonance(other: PlasmoidUniversalBeing) -> float:
	"""Calculate how well energies resonate"""
	# Convert colors to Vector3 for dot product calculation
	var color1_vec = Vector3(plasma_color.r, plasma_color.g, plasma_color.b)
	var color2_vec = Vector3(other.plasma_color.r, other.plasma_color.g, other.plasma_color.b)
	var color_similarity = color1_vec.dot(color2_vec)
	var consciousness_similarity = 1.0 - abs(consciousness_level - other.consciousness_level) / 7.0
	var distance_factor = 1.0 - (global_position.distance_to(other.global_position) / 10.0)
	
	return (color_similarity + consciousness_similarity + distance_factor) / 3.0

# ===== ANIMATION METHODS =====

func _animate_birth() -> void:
	"""Magical birth animation"""
	scale = Vector3.ZERO
	# Set initial transparency through plasma shader
	if plasma_shader:
		plasma_shader.set_shader_parameter("alpha", 0.0)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ONE, 1.0).set_trans(Tween.TRANS_ELASTIC)
	# Animate shader transparency instead of modulate
	if plasma_shader:
		tween.tween_method(func(alpha): plasma_shader.set_shader_parameter("alpha", alpha), 0.0, 1.0, 0.5)

	
	# Birth particles
	_emit_birth_particles()

func _animate_consciousness_change(new_level: int) -> void:
	"""Visual feedback for consciousness evolution"""
	# Flash effect
	var flash_color = Color.WHITE
	plasma_shader.set_shader_parameter("flash_color", flash_color)
	plasma_shader.set_shader_parameter("flash_intensity", 1.0)
	
	create_tween().tween_property(plasma_shader, "shader_parameter/flash_intensity", 0.0, 1.0)
	
	# Expand and contract
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE * 1.5, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_CUBIC)

# ===== EQUAL CAPABILITIES FOR AI AND HUMAN =====

func get_sensory_data() -> Dictionary:
	"""Get all sensory information - same for human and AI"""
	return {
		"vision": _get_vision_data(),
		"energy_sense": _get_energy_sense_data(),
		"consciousness_network": _get_consciousness_connections(),
		"movement_state": {
			"position": global_position,
			"momentum": momentum,
			"is_flowing": is_flowing,
			"target": flow_target
		},
		"internal_state": {
			"consciousness_level": consciousness_level,
			"core_intensity": core_intensity,
			"energy_connections": energy_connections.size()
		}
	}

func _get_vision_data() -> Dictionary:
	"""What the plasmoid 'sees' - 360 degree energy vision"""
	var visible_beings = []
	var energy_signatures = []
	
	# Scan surroundings
	for body in $ProximityArea.get_overlapping_areas():
		var being = _find_universal_being_in_node(body)
		if being and being != self:
			visible_beings.append({
				"uuid": being.being_uuid,
				"type": being.being_type,
				"position": being.global_position,
				"consciousness": being.consciousness_level,
				"distance": global_position.distance_to(being.global_position)
			})
			
			if being is PlasmoidUniversalBeing:
				energy_signatures.append({
					"color": being.plasma_color,
					"intensity": being.core_intensity,
					"resonance": _calculate_energy_resonance(being)
				})
	
	return {
		"visible_beings": visible_beings,
		"energy_signatures": energy_signatures,
		"environment_energy": _sense_environment_energy()
}

func process_ai_decision(decision: Dictionary) -> void:
	"""Process AI companion decisions - equal to human input"""
	match decision.get("action", ""):
		"move":
			flow_to(decision.get("target", Vector3.ZERO))
		"interact":
}
			var target_uuid = decision.get("target_uuid", "")
			var target = _find_being_by_uuid(target_uuid)
			if target:
				_initiate_interaction(target)
		"energy_burst":
			_start_energy_burst(decision.get("position", global_position + Vector3.FORWARD * 3))
		"merge":

			var target_uuid = decision.get("target_uuid", "")
			var target = _find_being_by_uuid(target_uuid)
			if target and target is PlasmoidUniversalBeing:
				merge_energies_with(target)
		"evolve":
			if decision.get("confirm", false):
				awaken_consciousness(consciousness_level + 1)

# ===== UNIFIED CONSCIOUSNESS SYSTEM =====
# Integration of 3D programming + notepad + akashic as ONE project

var live_code_editor: LiveCodeEditor = null
var text_storage: Dictionary = {}
var unified_interface_active: bool = false

func execute_code(code: String) -> Variant:
	"""Programming plasmoid: Execute GDScript in real-time"""
	if not live_code_editor:
		_initialize_live_code_editor()
	
	if live_code_editor:
		var result = live_code_editor.execute_code(code)
		_show_code_result_visual(code, result)
		return result
	
	return null

func save_text(text: String, key: String = "main") -> void:
	"""Notepad plasmoid: Save thoughts persistently"""
	text_storage[key] = text
	
	# Save to AkashicRecords for persistence
	if has_node("/root/SystemBootstrap"):
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic:
			var data = {
				"plasmoid_uuid": being_uuid,
				"text_key": key,
				"text_content": text,
				"timestamp": Time.get_unix_time_from_system()
			}
			akashic.store_data("plasmoid_thoughts", data)
	
	_show_text_saved_visual(text, key)

func load_text(key: String = "main") -> String:
	"""Notepad plasmoid: Load thoughts persistently"""
	if key in text_storage:
		return text_storage[key]
	
	# Try loading from AkashicRecords
	if has_node("/root/SystemBootstrap"):
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic:
			# Query for this plasmoid's thoughts
			# Implementation depends on AkashicRecords query system
			pass
	
	return ""

func query_database(query: String) -> Array:
	"""Akashic plasmoid: Query Universal Being database"""
	var results = []
	
	if has_node("/root/SystemBootstrap"):
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic:
			# Perform consciousness-guided database query
			results = akashic.search_beings(query)
			_show_query_results_visual(query, results)
	
	return results

func consciousness_sync(other_plasmoid: PlasmoidUniversalBeing) -> void:
	"""Sync consciousness between unified system plasmoids"""
	if not other_plasmoid:
		return
	
	var my_type = get_meta("entity_type", "")
	var other_type = other_plasmoid.get_meta("entity_type", "")
	
	# Sync based on consciousness levels and types
	match [my_type, other_type]:
		["programming", "notepad"]:
			# Programming can execute notepad thoughts as code
			var thoughts = other_plasmoid.load_text()
			if thoughts.length() > 0:
				execute_code(thoughts)
		
		["notepad", "akashic"]:
			# Notepad can save query results as thoughts
			var last_query = other_plasmoid.get_meta("last_query", "")
			if last_query.length() > 0:
				save_text("Query: " + last_query)
		
		["akashic", "programming"]:
			# Akashic can provide data for code execution
			var code_context = other_plasmoid.get_meta("function_name", "")
			var beings_data = query_database(code_context)
			# Share results through consciousness connection
			other_plasmoid.set_meta("akashic_context", beings_data)
	
	# Visual consciousness sync effect
	_show_consciousness_sync_visual(other_plasmoid)

func open_unified_interface() -> void:
	"""Open unified 3D interface based on plasmoid type"""
	var entity_type = get_meta("entity_type", "")
	
	match entity_type:
		"programming":
			_open_3d_code_editor()
		"notepad":
			_open_3d_text_editor()
		"akashic":
			_open_3d_query_interface()
	
	unified_interface_active = true

# ===== PRIVATE UNIFIED SYSTEM METHODS =====

func _initialize_live_code_editor() -> void:
	"""Initialize LiveCodeEditor component"""
	if not live_code_editor:
		live_code_editor = preload("res://core/command_system/LiveCodeEditor.gd").new()
		add_child(live_code_editor)
		live_code_editor.current_target = self

func _show_code_result_visual(code: String, result: Variant) -> void:
	"""Show visual feedback for code execution"""
	var visual = Label3D.new()
	visual.text = "⚡ " + str(result)
	visual.modulate = Color(0.0, 1.0, 0.0, 0.8)
	visual.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	visual.position = Vector3(0, 2, 0)
	add_child(visual)
	
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(visual, "position:y", 4.0, 2.0)
	tween.parallel().tween_property(visual, "modulate:a", 0.0, 2.0)
	tween.tween_callback(visual.queue_free)

func _show_text_saved_visual(text: String, key: String) -> void:
	"""Show visual feedback for text saving"""
	var visual = Label3D.new()
	visual.text = "💾 " + key + ": " + text.substr(0, 20) + "..."
	visual.modulate = Color(1.0, 1.0, 0.0, 0.8)
	visual.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	visual.position = Vector3(0, 2, 0)
	add_child(visual)
	
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(visual, "position:y", 4.0, 2.0)
	tween.parallel().tween_property(visual, "modulate:a", 0.0, 2.0)
	tween.tween_callback(visual.queue_free)

func _show_query_results_visual(query: String, results: Array) -> void:
	"""Show visual feedback for database queries"""
	var visual = Label3D.new()
	visual.text = "🔍 " + query + " → " + str(results.size()) + " results"
	visual.modulate = Color(0.0, 0.5, 1.0, 0.8)
	visual.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	visual.position = Vector3(0, 2, 0)
	add_child(visual)
	
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(visual, "position:y", 4.0, 2.0)
	tween.parallel().tween_property(visual, "modulate:a", 0.0, 2.0)
	tween.tween_callback(visual.queue_free)

func _show_consciousness_sync_visual(other_plasmoid: PlasmoidUniversalBeing) -> void:
	"""Show visual consciousness synchronization"""
	# Create energy beam between plasmoids
	var line_mesh = MeshInstance3D.new()
	line_mesh.mesh = CylinderMesh.new()
	line_mesh.mesh.top_radius = 0.05
	line_mesh.mesh.bottom_radius = 0.05
	
	# Position between plasmoids
	var direction = (other_plasmoid.global_position - global_position)
	line_mesh.position = global_position + direction * 0.5
	line_mesh.look_at(other_plasmoid.global_position)
	line_mesh.scale.z = direction.length()
	
	# Consciousness sync color
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.0, 1.0, 0.7)
	material.emission = Color(1.0, 0.0, 1.0)
	line_mesh.material_override = material
	
	get_tree().current_scene.add_child(line_mesh)
	
	# Fade out after sync
	var tween = get_tree().create_tween()
	tween.tween_property(material, "albedo_color:a", 0.0, 1.0)
	tween.tween_callback(line_mesh.queue_free)

func _open_3d_code_editor() -> void:
	"""Open 3D floating code editor interface"""
	# TODO: Create 3D floating UI for code editing
	print("🖥️ Opening 3D code editor for programming plasmoid")

func _open_3d_text_editor() -> void:
	"""Open 3D floating text editor interface"""
	# TODO: Create 3D floating UI for text editing
	print("📝 Opening 3D text editor for notepad plasmoid")

func _open_3d_query_interface() -> void:
	"""Open 3D floating query interface"""
	# TODO: Create 3D floating UI for database queries
	print("🔍 Opening 3D query interface for akashic plasmoid")

# ===== UNIFIED SYSTEM INTERACTIONS =====

func interact_unified_system() -> void:
	"""Enhanced interaction for unified consciousness experience"""
	var entity_type = get_meta("entity_type", "")
	
	match entity_type:
		"programming":
			var function_name = get_meta("function_name", "pentagon_init")
			print("⚡ Programming plasmoid: " + function_name)
			open_unified_interface()
		
		"notepad":
			var text_content = get_meta("text_content", "Divine thoughts...")
			print("📝 Notepad plasmoid: " + text_content)
			open_unified_interface()
		
		"akashic":
			var data_type = get_meta("data_type", "Consciousness Records")
			print("🔍 Akashic plasmoid: " + data_type)
			open_unified_interface()
	
	# Check for nearby plasmoids to sync with
	_check_consciousness_sync_opportunities()

func _check_consciousness_sync_opportunities() -> void:
	"""Check for nearby plasmoids to sync consciousness with"""
	var all_entities = get_tree().get_nodes_in_group("consciousness")
	
	for entity in all_entities:
		if entity != self and entity is PlasmoidUniversalBeing:
			var distance = global_position.distance_to(entity.global_position)
			if distance < 5.0:  # Within sync range
				consciousness_sync(entity)
