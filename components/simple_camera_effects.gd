# ==================================================
# SCRIPT NAME: camera_effects.gd
# DESCRIPTION: Consciousness-based camera effects component
# PURPOSE: Apply visual effects based on consciousness level
# LOCATION: components/camera_effects.gd
# ==================================================

extends Node
class_name SimpleCameraEffects

## References
var camera_being: Node  # CameraUniversalBeing
var post_process_layer: CanvasLayer
var current_effects: Dictionary = {}
var viewport: SubViewport

## Effect scenes
const EFFECT_SCENES = {
	"post_process": "res://effects/camera/camera_consciousness_post_process.tscn",
	"particles": "res://effects/camera/camera_aura_particles.tscn",
	"overlay": "res://effects/camera/consciousness_overlay.tscn"
}

## Shader paths by consciousness level
const LEVEL_SHADERS = {
	0: "",  # No shader
	1: "res://components/camera_effects/shaders/vignette_soft.gdshader",
	2: "res://components/camera_effects/shaders/depth_of_field.gdshader",
	3: "res://components/camera_effects/shaders/bloom_consciousness.gdshader",
	4: "res://components/camera_effects/shaders/chromatic_aberration.gdshader",
	5: "res://components/camera_effects/shaders/reality_distortion.gdshader",
	6: "res://components/camera_effects/shaders/quantum_vision.gdshader",
	7: "res://components/camera_effects/shaders/consciousness_pulse.gdshader"
}

const MATERIAL_PRESETS = {
	0: "",
	1: "res://materials/camera/consciousness_level_1.tres",
	2: "res://materials/camera/consciousness_level_2.tres",
	3: "res://materials/camera/consciousness_level_3.tres",
	4: "res://materials/camera/consciousness_level_4.tres",
	5: "res://materials/camera/consciousness_level_5.tres",
	6: "res://materials/camera/consciousness_level_6.tres",
	7: "res://materials/camera/consciousness_level_7.tres"
}

## Current state
var current_consciousness_level: int = 0
var effects_enabled: bool = true
var transition_speed: float = 1.0

# ===== LIFECYCLE =====

func _ready() -> void:
	camera_being = get_parent()
	
	if not camera_being:
		push_error("CameraEffectsComponent: No parent CameraUniversalBeing found!")
		return
	
	# Connect to consciousness changes
	if camera_being.has_signal("consciousness_changed"):
		camera_being.consciousness_changed.connect(_on_consciousness_changed)
	
	# Setup post-process layer
	setup_post_process_layer()
	
	# Apply initial effects
	if "consciousness_level" in camera_being:
		_on_consciousness_changed(0, camera_being.consciousness_level)

func _exit_tree() -> void:
	cleanup_all_effects()

# ===== SETUP =====

func setup_post_process_layer() -> void:
	"""Create post-process rendering layer"""
	post_process_layer = CanvasLayer.new()
	post_process_layer.name = "CameraEffectsLayer"
	post_process_layer.layer = 100  # Render on top
	
	# Add to camera's viewport
	if camera_being.has_method("get_viewport"):
		camera_being.get_viewport().add_child(post_process_layer)

# ===== CONSCIOUSNESS HANDLING =====

func _on_consciousness_changed(old_level: int, new_level: int) -> void:
	"""React to consciousness level changes"""
	current_consciousness_level = new_level
	print("📸 Camera effects: Consciousness %d -> %d" % [old_level, new_level])
	
	if effects_enabled:
		transition_effects(old_level, new_level)

func transition_effects(from_level: int, to_level: int) -> void:
	"""Smoothly transition between effect levels"""
	# Clear old effects if going down
	if to_level < from_level:
		for level in range(to_level + 1, from_level + 1):
			remove_effect_for_level(level)
	
	# Add new effects if going up
	if to_level > from_level:
		for level in range(from_level + 1, to_level + 1):
			add_effect_for_level(level)
	
	# Update shader parameters
	update_all_shader_parameters()

# ===== EFFECT MANAGEMENT =====

func add_effect_for_level(level: int) -> void:
	"""Add visual effect for specific consciousness level"""
	match level:
		1:
			add_vignette_effect()
		2:
			add_depth_of_field_effect()
		3:
			add_bloom_effect()
		4:
			add_chromatic_aberration_effect()
		5:
			add_reality_distortion_effect()
		6:
			add_quantum_vision_effect()
		7:
			add_consciousness_pulse_effect()

func remove_effect_for_level(level: int) -> void:
	"""Remove visual effect for specific consciousness level"""
	var effect_name = get_effect_name_for_level(level)
	if effect_name in current_effects:
		current_effects[effect_name].queue_free()
		current_effects.erase(effect_name)

func get_effect_name_for_level(level: int) -> String:
	"""Get effect identifier for consciousness level"""
	match level:
		1: return "vignette"
		2: return "depth_of_field"
		3: return "bloom"
		4: return "chromatic_aberration"
		5: return "reality_distortion"
		6: return "quantum_vision"
		7: return "consciousness_pulse"
		_: return ""

# ===== INDIVIDUAL EFFECTS =====

func add_vignette_effect() -> void:
	"""Level 1: Subtle screen edge darkening"""
	var rect = create_shader_rect("vignette", 1)
	if rect:
		print("🌑 Added vignette effect")

func add_depth_of_field_effect() -> void:
	"""Level 2: Focus blur on distant objects"""
	var rect = create_shader_rect("depth_of_field", 2)
	if rect:
		# Set initial parameters
		var mat = rect.material as ShaderMaterial
		mat.set_shader_parameter("focus_distance", 10.0)
		mat.set_shader_parameter("blur_amount", 0.3)
		print("🔍 Added depth of field effect")

func add_bloom_effect() -> void:
	"""Level 3: Consciousness glow on beings"""
	var rect = create_shader_rect("bloom", 3)
	if rect:
		print("✨ Added bloom effect")

func add_chromatic_aberration_effect() -> void:
	"""Level 4: RGB channel separation"""
	var rect = create_shader_rect("chromatic_aberration", 4)
	if rect:
		print("🌈 Added chromatic aberration effect")

func add_reality_distortion_effect() -> void:
	"""Level 5: Space-time warping"""
	var rect = create_shader_rect("reality_distortion", 5)
	if rect:
		print("🌀 Added reality distortion effect")

func add_quantum_vision_effect() -> void:
	"""Level 6: Multiple reality perception"""
	var rect = create_shader_rect("quantum_vision", 6)
	if rect:
		print("👁️ Added quantum vision effect")

func add_consciousness_pulse_effect() -> void:
	"""Level 7: All effects + breathing reality"""
	var rect = create_shader_rect("consciousness_pulse", 7)
	if rect:
		# This shader combines all previous effects
		print("🎆 Added consciousness pulse effect - MAXIMUM AWARENESS")

# ===== SHADER CREATION =====

func create_shader_rect(effect_name: String, level: int) -> ColorRect:
	"""Create a fullscreen ColorRect with shader"""
	if effect_name in current_effects:
		return current_effects[effect_name]
	
	var rect = ColorRect.new()
	rect.name = effect_name + "_effect"
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	
	# Try to load material preset first
	var preset_path = MATERIAL_PRESETS.get(level, "")
	if preset_path != "" and ResourceLoader.exists(preset_path):
		var preset_material = load(preset_path)
		rect.material = preset_material
		print("✅ Loaded material preset for level %d" % level)
	else:
		# Fallback: Create material from shader
		var shader_path = LEVEL_SHADERS.get(level, "")
		if shader_path != "" and ResourceLoader.exists(shader_path):
			var shader = load(shader_path)
			var material = ShaderMaterial.new()
			material.shader = shader
			rect.material = material
			
			# Set default parameters
			material.set_shader_parameter("consciousness_level", float(level))
			material.set_shader_parameter("effect_intensity", level / 7.0)
			print("✅ Created material from shader for level %d" % level)
		else:
			# Final fallback: Color overlay
			rect.color = get_fallback_color_for_level(level)
			print("⚠️ Using fallback color for level %d" % level)
	
	# Add to post-process layer
	if post_process_layer:
		post_process_layer.add_child(rect)
		current_effects[effect_name] = rect
	
	return rect

func get_fallback_color_for_level(level: int) -> Color:
	"""Fallback colors when shaders aren't available"""
	match level:
		1: return Color(0.9, 0.9, 0.9, 0.1)  # Slight white tint
		2: return Color(0.2, 0.4, 1.0, 0.1)  # Blue tint
		3: return Color(0.2, 1.0, 0.2, 0.1)  # Green tint
		4: return Color(1.0, 0.84, 0.0, 0.1) # Gold tint
		5: return Color(1.0, 0.2, 1.0, 0.1)  # Magenta tint
		6: return Color(1.0, 0.2, 0.2, 0.1)  # Red tint
		7: return Color(1.0, 1.0, 1.0, 0.2)  # Bright white
		_: return Color.TRANSPARENT

# ===== SHADER UPDATES =====

func update_all_shader_parameters() -> void:
	"""Update shader parameters for all active effects"""
	for effect_name in current_effects:
		var rect = current_effects[effect_name]
		if rect and rect.material:
			var mat = rect.material as ShaderMaterial
			update_shader_time(mat)
			update_shader_consciousness(mat)

func update_shader_time(material: ShaderMaterial) -> void:
	"""Update time-based shader parameters"""
	var time = Time.get_ticks_msec() / 1000.0
	if material.shader and material.shader.has_uniform("time"):
		material.set_shader_parameter("time", time)

func update_shader_consciousness(material: ShaderMaterial) -> void:
	"""Update consciousness-based parameters"""
	if material.shader and material.shader.has_uniform("consciousness_level"):
		material.set_shader_parameter("consciousness_level", float(current_consciousness_level))
	
	if material.shader and material.shader.has_uniform("effect_intensity"):
		var intensity = current_consciousness_level / 7.0
		material.set_shader_parameter("effect_intensity", intensity)

# ===== UTILITY =====

func cleanup_all_effects() -> void:
	"""Remove all active effects"""
	for effect_name in current_effects:
		current_effects[effect_name].queue_free()
	current_effects.clear()
	
	if post_process_layer:
		post_process_layer.queue_free()

func set_effects_enabled(enabled: bool) -> void:
	"""Toggle all effects on/off"""
	effects_enabled = enabled
	
	if not enabled:
		cleanup_all_effects()
	else:
		_on_consciousness_changed(0, current_consciousness_level)

func get_active_effects() -> Array[String]:
	"""Get list of currently active effects"""
	return current_effects.keys()

# ===== PROCESS =====

func _process(_delta: float) -> void:
	"""Update time-based shader parameters"""
	if current_effects.size() > 0:
		for effect_name in current_effects:
			var rect = current_effects[effect_name]
			if rect and rect.material:
				update_shader_time(rect.material)

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	"""AI interface for camera effects"""
	return {
		"component_type": "camera_effects",
		"consciousness_level": current_consciousness_level,
		"active_effects": get_active_effects(),
		"effects_enabled": effects_enabled,
		"available_levels": range(8),
		"commands": [
			"set_effects_enabled [true/false]",
			"force_level [0-7]",
			"cleanup_effects"
		]
	}

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	"""AI method invocation"""
	match method_name:
		"set_effects_enabled":
			if args.size() > 0:
				set_effects_enabled(args[0])
				return "Effects enabled: %s" % str(args[0])
			return "Error: Missing argument for set_effects_enabled"
		"force_level":
			if args.size() > 0:
				_on_consciousness_changed(current_consciousness_level, args[0])
				return "Forced to level: %d" % args[0]
			return "Error: Missing argument for force_level"
		"cleanup_effects":
			cleanup_all_effects()
			return "All effects cleaned up"
		_:
			return "Unknown command: %s" % method_name
