# ==================================================
# UNIVERSAL BEING: CameraEffectsComponent
# TYPE: Component
# PURPOSE: Manages consciousness-based camera effects
# COMPONENTS: camera_effects.ub.zip
# SCENES: camera_consciousness_post_process.tscn, camera_aura_particles.tscn, consciousness_overlay.tscn
# ==================================================

# res://scripts/camera_effects_component.gd
extends UniversalBeing
class_name CameraEffectsComponent

# ===== COMPONENT PROPERTIES =====
@export var use_subviewport: bool = true
@export var subviewport_size: Vector2i = Vector2i(1280, 720)
@export var performance_mode: String = "high"  # high, medium, low

# ===== INTERNAL STATE =====
var _camera_being: Node  # Reference to the camera Universal Being
var _post_process_layer: ColorRect
var _aura_particles: GPUParticles3D
var _consciousness_overlay: Control
var _current_effects: Array[String] = []
var _shader_materials: Dictionary = {}
var _manifest_data: Dictionary = {}
var _is_initialized: bool = false

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	# Load manifest data
	var manifest_path = "res://components/camera_effects/manifest.json"
	var manifest_file = FileAccess.open(manifest_path, FileAccess.READ)
	if manifest_file:
		var json = JSON.new()
		var error = json.parse(manifest_file.get_as_text())
		if error == OK:
			_manifest_data = json.get_data()
		else:
			push_error("Failed to parse camera effects manifest: %s" % json.get_error_message())
	
	# Initialize shader materials dictionary
	_initialize_shader_materials()
	
	print("🌟 CameraEffectsComponent: Pentagon Init Complete")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	if not _is_initialized:
		push_error("CameraEffectsComponent: Not properly initialized with a camera being")
		return
	
	# Create post-process layer
	_create_post_process_layer()
	
	# Create aura particles
	_create_aura_particles()
	
	# Create consciousness overlay
	_create_consciousness_overlay()
	
	# Connect to camera being's consciousness changes
	if _camera_being.has_signal("consciousness_changed"):
		_camera_being.consciousness_changed.connect(_on_consciousness_changed)
	
	print("🌟 CameraEffectsComponent: Pentagon Ready Complete")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	if not _is_initialized or not _post_process_layer:
		return
	
	# Update effect parameters based on camera movement and consciousness
	_update_effect_parameters(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle any camera effect specific input
	if event.is_action_pressed("toggle_camera_effects"):
		_toggle_effects_visibility()

func pentagon_sewers() -> void:
	# Cleanup resources
	if _post_process_layer:
		_post_process_layer.queue_free()
	if _aura_particles:
		_aura_particles.queue_free()
	if _consciousness_overlay:
		_consciousness_overlay.queue_free()
	
	# Disconnect signals
	if _camera_being and _camera_being.has_signal("consciousness_changed"):
		_camera_being.consciousness_changed.disconnect(_on_consciousness_changed)
	
	super.pentagon_sewers()
	print("🌟 CameraEffectsComponent: Pentagon Sewers Complete")

# ===== PUBLIC INTERFACE =====

func initialize(camera_being: Node) -> void:
	"""Initialize the camera effects component with a camera Universal Being"""
	_camera_being = camera_being
	_is_initialized = true
	
	# Set initial consciousness level
	if _camera_being.has_method("get_consciousness_level"):
		var level = _camera_being.get_consciousness_level()
		_apply_consciousness_level(level)

func set_performance_mode(mode: String) -> void:
	"""Set the performance mode (high, medium, low)"""
	if mode in ["high", "medium", "low"]:
		performance_mode = mode
		_update_performance_settings()

# ===== PRIVATE IMPLEMENTATION =====

func _initialize_shader_materials() -> void:
	"""Initialize all shader materials from the manifest"""
	for shader_path in _manifest_data.get("files", {}).get("shaders", []):
		var shader = load("res://components/camera_effects/" + shader_path)
		if shader:
			var material = ShaderMaterial.new()
			material.shader = shader
			_shader_materials[shader_path.get_file().get_basename()] = material

func _create_post_process_layer() -> void:
	"""Create the post-process layer with appropriate shader material"""
	var post_process_scene = load("res://effects/camera/camera_consciousness_post_process.tscn")
	if post_process_scene:
		_post_process_layer = post_process_scene.instantiate()
		_camera_being.add_child(_post_process_layer)
		
		if use_subviewport:
			var subviewport = SubViewport.new()
			subviewport.size = subviewport_size
			subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			_post_process_layer.add_child(subviewport)

func _create_aura_particles() -> void:
	"""Create the consciousness aura particle system"""
	var aura_scene = load("res://effects/camera/camera_aura_particles.tscn")
	if aura_scene:
		_aura_particles = aura_scene.instantiate()
		_camera_being.add_child(_aura_particles)

func _create_consciousness_overlay() -> void:
	"""Create the consciousness level overlay"""
	var overlay_scene = load("res://effects/camera/consciousness_overlay.tscn")
	if overlay_scene:
		_consciousness_overlay = overlay_scene.instantiate()
		_camera_being.add_child(_consciousness_overlay)

func _on_consciousness_changed(new_level: int) -> void:
	"""Handle consciousness level changes"""
	_apply_consciousness_level(new_level)

func _apply_consciousness_level(level: int) -> void:
	"""Apply effects based on consciousness level"""
	var level_data = _manifest_data.get("consciousness_levels", {}).get(str(level), {})
	if level_data.is_empty():
		return
	
	# Clear current effects
	_current_effects.clear()
	
	# Apply new effects
	for effect in level_data.get("effects", []):
		_apply_effect(effect)
	
	# Update aura color
	_update_aura_color(level_data.get("color", "gray"))
	
	# Update overlay
	_update_consciousness_overlay(level, level_data)

func _apply_effect(effect_name: String) -> void:
	"""Apply a specific effect to the post-process layer"""
	if effect_name == "all_effects":
		# Apply all effects for level 7
		for effect in _shader_materials.keys():
			_current_effects.append(effect)
	elif _shader_materials.has(effect_name):
		_current_effects.append(effect_name)
	
	_update_post_process_material()

func _update_post_process_material() -> void:
	"""Update the post-process material with current effects"""
	if not _post_process_layer or _current_effects.is_empty():
		return
	
	# Combine shaders for multiple effects
	var combined_shader = _combine_shaders(_current_effects)
	if combined_shader:
		_post_process_layer.material = combined_shader

func _combine_shaders(effect_names: Array[String]) -> ShaderMaterial:
	"""Combine multiple shaders into a single material"""
	var combined = ShaderMaterial.new()
	var shader_code = "shader_type canvas_item;\n\n"
	
	# Add uniforms from all shaders
	for effect in effect_names:
		if _shader_materials.has(effect):
			var material = _shader_materials[effect]
			shader_code += material.shader.code + "\n"
	
	# Create combined shader
	var shader = Shader.new()
	shader.code = shader_code
	combined.shader = shader
	
	# Copy parameters from original materials
	for effect in effect_names:
		if _shader_materials.has(effect):
			var material = _shader_materials[effect]
			for param in material.get_shader_parameter_list():
				combined.set_shader_parameter(param.name, material.get_shader_parameter(param.name))
	
	return combined

func _update_effect_parameters(delta: float) -> void:
	"""Update effect parameters based on camera movement and consciousness"""
	if not _post_process_layer or not _post_process_layer.material:
		return
	
	var material = _post_process_layer.material as ShaderMaterial
	if not material:
		return
	
	# Update time-based parameters
	material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	
	# Update camera movement parameters
	if _camera_being.has_method("get_velocity"):
		var velocity = _camera_being.get_velocity()
		material.set_shader_parameter("camera_velocity", velocity)
	
	# Update consciousness pulse
	if _camera_being.has_method("get_consciousness_pulse"):
		var pulse = _camera_being.get_consciousness_pulse()
		material.set_shader_parameter("consciousness_pulse", pulse)

func _update_aura_color(color_name: String) -> void:
	"""Update the aura particle color based on consciousness level"""
	if not _aura_particles:
		return
	
	var color = _get_color_from_name(color_name)
	var material = _aura_particles.process_material as ParticleProcessMaterial
	if material:
		material.color = color

func _update_consciousness_overlay(level: int, level_data: Dictionary) -> void:
	"""Update the consciousness level overlay"""
	if not _consciousness_overlay:
		return
	
	# Update overlay with level information
	if _consciousness_overlay.has_method("set_level"):
		_consciousness_overlay.set_level(level, level_data)

func _update_performance_settings() -> void:
	"""Update effect quality based on performance mode"""
	var settings = _manifest_data.get("performance_settings", {}).get("lod_levels", {}).get(performance_mode, {})
	
	# Update shader parameters for all effects
	for material in _shader_materials.values():
		if material.has_shader_parameter("blur_samples"):
			material.set_shader_parameter("blur_samples", settings.get("blur_samples", 8))
	
	# Update subviewport if enabled
	if use_subviewport and _post_process_layer:
		var subviewport = _post_process_layer.get_node_or_null("SubViewport")
		if subviewport:
			var scale = 1.0
			match performance_mode:
				"medium": scale = 0.75
				"low": scale = 0.5
			subviewport.size = subviewport_size * scale

func _toggle_effects_visibility() -> void:
	"""Toggle the visibility of all camera effects"""
	if _post_process_layer:
		_post_process_layer.visible = !_post_process_layer.visible
	if _aura_particles:
		_aura_particles.visible = !_aura_particles.visible
	if _consciousness_overlay:
		_consciousness_overlay.visible = !_consciousness_overlay.visible

func _get_color_from_name(color_name: String) -> Color:
	"""Convert color name to Color value"""
	match color_name:
		"gray": return Color(0.5, 0.5, 0.5)
		"white": return Color(1, 1, 1)
		"blue": return Color(0, 0.5, 1)
		"green": return Color(0, 1, 0.5)
		"yellow": return Color(1, 1, 0)
		"cyan": return Color(0, 1, 1)
		"red": return Color(1, 0, 0)
		"rainbow": 
			var time = Time.get_ticks_msec() / 1000.0
			return Color.from_hsv(fmod(time * 0.1, 1.0), 1.0, 1.0)
		_: return Color(1, 1, 1)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	"""Enhanced AI interface for camera effects component"""
	var base_interface = super.ai_interface()
	base_interface.custom_commands = [
		"set_performance_mode",
		"toggle_effects",
		"get_current_effects"
	]
	base_interface.custom_properties = {
		"performance_mode": performance_mode,
		"use_subviewport": use_subviewport,
		"current_effects": _current_effects
	}
	return base_interface 
