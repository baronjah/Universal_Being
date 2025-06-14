extends RigidBody3D
# ═══════════════════════════════════════════════════════════════════════════════════════════════
# 🌟 WORD ENTITY - INDIVIDUAL 3D WORD MANIFESTATION 🌟  
# ═══════════════════════════════════════════════════════════════════════════════════════════════
#
# 📍 PROJECT PATH: /akashic_notepad3d_game/scripts/core/word_entity.gd
# 🎯 FILE GOAL: Individual word objects that can be interacted with in 3D space
# 🔗 CONNECTED FILES:
#    - core/main_game_controller.gd (E key interaction detection)
#    - core/word_interaction_system.gd (selection and evolution handling)
#    - core/lod_manager.gd (performance optimization)
#    - autoload/word_database.gd (evolution data and properties)
#
# 🚀 REVOLUTIONARY FEATURES:
#    - E KEY INTERACTION: Direct word selection and manipulation
#    - VISUAL EVOLUTION: Color changes based on evolution state
#    - FLOATING ANIMATION: Gentle movement for living word effect
#    - LOD OPTIMIZATION: Distance-based detail adjustment
#    - PHYSICS INTERACTION: Proper collision detection on layer 1
#
# 🎮 USER EXPERIENCE: Words as living entities that respond to interaction
# ═══════════════════════════════════════════════════════════════════════════════════════════════

## Word Entity class for individual 3D word objects
class_name WordEntity

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 CORE WORD PROPERTIES
# ─────────────────────────────────────────────────────────────────────────────────

var word_id: String
var text_content: String
var evolution_state: int = 0
var interaction_count: int = 0
var creation_time: float

# LOD (Level of Detail) properties
var current_lod_level: int = 0
var lod_settings: Dictionary = {}

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var label_3d: Label3D = $Label3D

func initialize(data: Dictionary) -> void:
	word_id = data.get("id", "")
	text_content = data.get("text", "word")
	evolution_state = data.get("evolution_state", 0)
	creation_time = Time.get_unix_time_from_system()
	
	# Set position from data (FIX: maintain stable position)
	position = data.get("position", Vector3.ZERO)
	
	_setup_visual_components(data)
	_setup_physics()

func _setup_visual_components(data: Dictionary) -> void:
	# Create Label3D for text display
	if not label_3d:
		label_3d = Label3D.new()
		add_child(label_3d)
	
	label_3d.text = text_content
	label_3d.font_size = 32
	
	# Use color from data if available, otherwise use evolution color
	var word_color = data.get("color", _get_evolution_color())
	label_3d.modulate = word_color
	
	# Create mesh for interaction
	if not mesh_instance:
		mesh_instance = MeshInstance3D.new()
		add_child(mesh_instance)
	
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(2, 1, 0.2)
	mesh_instance.mesh = box_mesh
	
	# Use frequency for material properties
	var frequency = data.get("frequency", 1.0)
	var material = StandardMaterial3D.new()
	
	# Frequency affects transparency and glow
	var alpha = clamp(0.2 + (frequency * 0.1), 0.2, 0.7)
	material.albedo_color = Color(word_color.r, word_color.g, word_color.b, alpha)
	material.flags_transparent = true
	
	# High frequency words get emission glow
	if frequency > 3.0:
		material.emission = word_color * 0.3
		material.emission_energy = frequency * 0.2
	
	mesh_instance.material_override = material

func _setup_physics() -> void:
	# Create collision shape
	if not collision_shape:
		collision_shape = CollisionShape3D.new()
		add_child(collision_shape)
	
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(2, 1, 0.2)
	collision_shape.shape = box_shape
	
	# Set collision layer and mask for proper detection
	collision_layer = 1  # WordEntities layer
	collision_mask = 1  # Can interact with itself
	
	# Enable contact monitoring for interaction detection
	contact_monitor = true
	max_contacts_reported = 10
	
	# Set body type for better interaction
	gravity_scale = 0.0  # No gravity for floating effect
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC

func _get_evolution_color() -> Color:
	match evolution_state:
		0: return Color.WHITE
		1: return Color.CYAN
		2: return Color.GREEN
		3: return Color.YELLOW
		4: return Color.ORANGE
		_: return Color.RED

# ─────────────────────────────────────────────────────────────────────────────────
# 🔍 GET WORD ENTITY - COLLISION DETECTION INTERFACE
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: Called by collision detection system
# PROCESS: Returns this WordEntity instance for interaction
# OUTPUT: Self reference for E key interaction system
# CHANGES: Enables proper word selection and interaction
# CONNECTION: Required by main_game_controller.gd collision detection
# ─────────────────────────────────────────────────────────────────────────────────
func get_word_entity() -> WordEntity:
	return self

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 HANDLE WORD INTERACTION - VISUAL AND AUDIO FEEDBACK
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: User interaction via E key or mouse click
# PROCESS: Increments interaction count and provides visual feedback
# OUTPUT: Scale animation and console feedback message
# CHANGES: Updates interaction_count and triggers visual response
# CONNECTION: Called by word_interaction_system.gd
# ─────────────────────────────────────────────────────────────────────────────────
func on_interact() -> void:
	interaction_count += 1
	print("🎯 Word '", text_content, "' interacted with (", interaction_count, " times)")
	
	# Enhanced visual feedback for interaction
	var tween = create_tween()
	tween.parallel().tween_property(label_3d, "scale", Vector3.ONE * 1.3, 0.1)
	tween.parallel().tween_property(mesh_instance, "scale", Vector3.ONE * 1.1, 0.1)
	tween.tween_delay(0.1)
	tween.parallel().tween_property(label_3d, "scale", Vector3.ONE, 0.2)
	tween.parallel().tween_property(mesh_instance, "scale", Vector3.ONE, 0.2)
	
	# Pulse the emission for high-evolution words
	if evolution_state > 2:
		var material = mesh_instance.material_override as StandardMaterial3D
		if material:
			var original_energy = material.emission_energy
			tween.parallel().tween_method(_pulse_emission, original_energy, original_energy * 2.0, 0.3)

# ─────────────────────────────────────────────────────────────────────────────────
# ✨ PULSE EMISSION EFFECT - VISUAL ENHANCEMENT
# ─────────────────────────────────────────────────────────────────────────────────
func _pulse_emission(energy_value: float) -> void:
	var material = mesh_instance.material_override as StandardMaterial3D
	if material:
		material.emission_energy = energy_value

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 GET WORD TEXT PROPERTY - EXTERNAL ACCESS  
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: External access to word text content
# PROCESS: Returns current text_content value
# OUTPUT: String containing the word's text
# CHANGES: None - read-only property access
# CONNECTION: Used by main_game_controller.gd for interaction feedback
# ─────────────────────────────────────────────────────────────────────────────────
func get_word_text() -> String:
	return text_content

# ─────────────────────────────────────────────────────────────────────────────────  
# 🎯 SET WORD TEXT PROPERTY - EXTERNAL MODIFICATION
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: New text value to set for this word
# PROCESS: Updates text_content and visual label
# OUTPUT: None - modifies internal state
# CHANGES: Updates text_content and label_3d.text
# CONNECTION: Used for dynamic word content modification
# ─────────────────────────────────────────────────────────────────────────────────
func set_word_text(value: String) -> void:
	text_content = value
	if label_3d:
		label_3d.text = value

func update_properties(properties: Dictionary) -> void:
	if properties.has("evolution_state"):
		evolution_state = properties.evolution_state
		label_3d.modulate = _get_evolution_color()
	
	if properties.has("text"):
		text_content = properties.text
		label_3d.text = text_content

func update(delta: float) -> void:
	# Apply floating animation only if LOD allows it
	var animation_enabled = lod_settings.get("animation_enabled", true)
	
	if animation_enabled:
		# Gentle floating animation (FIX: maintain base position)
		var time = Time.get_unix_time_from_system() - creation_time
		var float_offset = sin(time * 0.5) * 0.1
		
		# Get original Y position from when word was created
		var original_y = position.y
		if has_meta("base_y"):
			original_y = get_meta("base_y")
		else:
			set_meta("base_y", position.y)
		
		# Apply floating relative to base position
		position.y = original_y + float_offset

func set_lod_level(settings: Dictionary) -> void:
	lod_settings = settings
	_apply_lod_settings()

func _apply_lod_settings() -> void:
	# Apply text visibility and size
	if label_3d:
		label_3d.visible = lod_settings.get("text_visible", true)
		if label_3d.visible:
			label_3d.font_size = lod_settings.get("font_size", 32)
	
	# Apply mesh visibility
	if mesh_instance:
		mesh_instance.visible = lod_settings.get("mesh_visible", true)
		
		# Update material transparency
		var material = mesh_instance.material_override
		if material and material is StandardMaterial3D:
			var transparency = lod_settings.get("transparency", 0.3)
			var current_color = material.albedo_color
			material.albedo_color = Color(current_color.r, current_color.g, current_color.b, 1.0 - transparency)
			
			# Enable/disable emission based on LOD
			var emission_enabled = lod_settings.get("emission_enabled", true)
			if not emission_enabled:
				material.emission_energy = 0.0