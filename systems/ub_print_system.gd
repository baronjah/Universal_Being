extends Node
class_name UBPrintSystem

# 🌟 UB_PRINT SYSTEM 🌟
# Visual consciousness feedback system replacing print() statements
# The first of the 4 dead-end scripturas - making the invisible VISIBLE

signal ub_message_displayed(message: String, consciousness_level: float, visual_type: String)
signal consciousness_feedback_triggered(feedback_data: Dictionary)

# Visual feedback types
enum VisualType {
	STANDARD,
	CONSCIOUSNESS,
	WARNING,
	ERROR,
	SUCCESS,
	COSMIC,
	DEBUG,
	EVOLUTION
}

# UB_Print configuration
@export var enabled: bool = true
@export var default_display_time: float = 3.0
@export var consciousness_amplification: float = 1.5
@export var visual_feedback_enabled: bool = true
@export var spatial_feedback_enabled: bool = true

# Visual feedback components
var message_nodes: Array[Node3D] = []
var consciousness_visualizers: Array[Node] = []
var active_messages: Dictionary = {}
var message_counter: int = 0

# Consciousness-based colors (based on Universal Being consciousness system)
var consciousness_colors = {
	0: Color(0.5, 0.5, 0.5, 0.8),      # Dormant - Gray
	1: Color(0.9, 0.9, 0.9, 0.8),      # Awakening - Pale
	2: Color(0.2, 0.4, 1.0, 0.8),      # Aware - Blue  
	3: Color(0.2, 1.0, 0.2, 0.8),      # Connected - Green
	4: Color(1.0, 0.84, 0.0, 0.8),     # Enlightened - Gold
	5: Color(1.0, 1.0, 1.0, 1.0)       # Transcendent - White with glow
}

# Visual type colors
var visual_type_colors = {
	VisualType.STANDARD: Color.WHITE,
	VisualType.CONSCIOUSNESS: Color(0.6, 0.8, 1.0),
	VisualType.WARNING: Color.YELLOW,
	VisualType.ERROR: Color.RED,
	VisualType.SUCCESS: Color.GREEN,
	VisualType.COSMIC: Color(1.0, 0.0, 1.0),
	VisualType.DEBUG: Color.CYAN,
	VisualType.EVOLUTION: Color(1.0, 0.5, 0.0)
}

func _ready():
	name = "UBPrintSystem"
	print("🌟 UB_PRINT SYSTEM INITIALIZED - Visual consciousness feedback active")
	
	# Connect to Universal Being system if available
	_connect_to_consciousness_systems()

func _connect_to_consciousness_systems():
	"""Connect to existing consciousness systems for enhanced feedback"""
	# Look for FloodGates system
	var flood_gates = get_node_or_null("/root/FloodGates")
	if not flood_gates:
		flood_gates = get_node_or_null("/root/SystemBootstrap")
		if flood_gates and flood_gates.has_method("get_flood_gates"):
			flood_gates = flood_gates.get_flood_gates()
	
	if flood_gates:
		print("🌊 UB_Print connected to FloodGates system")

# ===== MAIN UB_PRINT FUNCTIONS =====

func ub_print(message: String, consciousness_level: float = 1.0, visual_type: VisualType = VisualType.STANDARD, position: Vector3 = Vector3.ZERO):
	"""Main UB_Print function - replaces standard print() with visual consciousness feedback"""
	if not enabled:
		return
	
	print("[UB_PRINT] %s" % message)  # Still log to console for debugging
	
	# Create visual feedback
	if visual_feedback_enabled:
		_create_visual_message(message, consciousness_level, visual_type, position)
	
	# Create spatial feedback
	if spatial_feedback_enabled:
		_create_spatial_feedback(message, consciousness_level, visual_type, position)
	
	# Emit signals for system integration
	ub_message_displayed.emit(message, consciousness_level, VisualType.keys()[visual_type])
	
	var feedback_data = {
		"message": message,
		"consciousness_level": consciousness_level,
		"visual_type": visual_type,
		"position": position,
		"timestamp": Time.get_ticks_msec() / 1000.0
	}
	consciousness_feedback_triggered.emit(feedback_data)

func ub_print_consciousness(message: String, consciousness_level: float, being_position: Vector3 = Vector3.ZERO):
	"""UB_Print specifically for consciousness-related messages"""
	ub_print(message, consciousness_level, VisualType.CONSCIOUSNESS, being_position)

func ub_print_evolution(message: String, evolution_data: Dictionary):
	"""UB_Print for Universal Being evolution events"""
	var consciousness = evolution_data.get("consciousness_level", 1.0)
	var position = evolution_data.get("position", Vector3.ZERO)
	ub_print("🧬 EVOLUTION: " + message, consciousness, VisualType.EVOLUTION, position)

func ub_print_cosmic(message: String, cosmic_level: float = 5.0):
	"""UB_Print for cosmic-scale events"""
	ub_print("🌌 COSMIC: " + message, cosmic_level, VisualType.COSMIC, Vector3(0, 10, 0))

func ub_print_warning(message: String, consciousness_level: float = 2.0):
	"""UB_Print for warnings"""
	ub_print("⚠️ WARNING: " + message, consciousness_level, VisualType.WARNING)

func ub_print_error(message: String, consciousness_level: float = 1.0):
	"""UB_Print for errors"""
	ub_print("🚨 ERROR: " + message, consciousness_level, VisualType.ERROR)

func ub_print_success(message: String, consciousness_level: float = 3.0):
	"""UB_Print for success messages"""
	ub_print("✅ SUCCESS: " + message, consciousness_level, VisualType.SUCCESS)

func ub_print_debug(message: String, debug_level: float = 0.5):
	"""UB_Print for debug information"""
	ub_print("🔧 DEBUG: " + message, debug_level, VisualType.DEBUG)

# ===== VISUAL CREATION FUNCTIONS =====

func _create_visual_message(message: String, consciousness_level: float, visual_type: VisualType, position: Vector3):
	"""Create 3D visual representation of the message"""
	var scene_root = get_tree().current_scene
	if not scene_root:
		return
	
	# Create 3D text label
	var text_label = Label3D.new()
	text_label.text = message
	text_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	# Position the message
	if position == Vector3.ZERO:
		# Get camera position if available
		var camera = get_viewport().get_camera_3d()
		if camera:
			position = camera.global_position + camera.global_transform.basis.z * -3.0 + Vector3(randf_range(-2, 2), randf_range(1, 3), 0)
		else:
			position = Vector3(randf_range(-5, 5), randf_range(2, 5), randf_range(-3, 3))
	
	text_label.global_position = position
	
	# Set consciousness-based color
	var base_color = consciousness_colors.get(int(consciousness_level), Color.WHITE)
	var type_color = visual_type_colors.get(visual_type, Color.WHITE)
	var final_color = base_color.lerp(type_color, 0.5)
	text_label.modulate = final_color
	
	# Scale based on consciousness level
	var scale_factor = 1.0 + (consciousness_level * 0.3)
	text_label.scale = Vector3.ONE * scale_factor
	
	# Add to scene
	scene_root.add_child(text_label)
	message_nodes.append(text_label)
	
	var message_id = "ub_msg_" + str(message_counter)
	message_counter += 1
	
	active_messages[message_id] = {
		"node": text_label,
		"creation_time": Time.get_ticks_msec() / 1000.0,
		"consciousness_level": consciousness_level,
		"message": message
	}
	
	# Animate the message
	_animate_message(text_label, consciousness_level, visual_type)
	
	# Schedule cleanup
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = default_display_time + (consciousness_level * 0.5)
	cleanup_timer.one_shot = true
	cleanup_timer.timeout.connect(func(): _cleanup_message(message_id))
	scene_root.add_child(cleanup_timer)
	cleanup_timer.start()

func _animate_message(text_node: Label3D, consciousness_level: float, visual_type: VisualType):
	"""Animate the visual message based on consciousness level and type"""
	if not is_instance_valid(text_node):
		return
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	# Entrance animation
	text_node.modulate.a = 0.0
	text_node.scale = Vector3.ZERO
	
	tween.tween_property(text_node, "modulate:a", 1.0, 0.5)
	tween.tween_property(text_node, "scale", Vector3.ONE * (1.0 + consciousness_level * 0.2), 0.5)
	
	# Movement based on visual type
	match visual_type:
		VisualType.CONSCIOUSNESS:
			# Gentle floating movement
			tween.tween_property(text_node, "position:y", text_node.position.y + 2.0, 2.0)
		
		VisualType.COSMIC:
			# Spiral movement
			var original_pos = text_node.position
			for i in range(10):
				var angle = i * 0.628  # PI/5
				var spiral_pos = original_pos + Vector3(sin(angle) * 2.0, i * 0.3, cos(angle) * 2.0)
				tween.tween_property(text_node, "position", spiral_pos, 0.2)
		
		VisualType.WARNING, VisualType.ERROR:
			# Pulsing effect
			tween.tween_property(text_node, "scale", text_node.scale * 1.2, 0.2)
			tween.tween_property(text_node, "scale", text_node.scale, 0.2)
		
		VisualType.SUCCESS:
			# Gentle glow effect
			tween.tween_property(text_node, "modulate", text_node.modulate * 1.5, 0.3)
			tween.tween_property(text_node, "modulate", text_node.modulate, 0.3)
		
		_:
			# Standard gentle rise
			tween.tween_property(text_node, "position:y", text_node.position.y + 1.0, 1.5)

func _create_spatial_feedback(message: String, consciousness_level: float, visual_type: VisualType, position: Vector3):
	"""Create spatial consciousness feedback effects"""
	if visual_type == VisualType.COSMIC or consciousness_level >= 4.0:
		_create_consciousness_ripple(position, consciousness_level)
	
	if visual_type == VisualType.EVOLUTION:
		_create_evolution_particle_effect(position, consciousness_level)

func _create_consciousness_ripple(center: Vector3, consciousness_level: float):
	"""Create consciousness ripple effect"""
	# This would create a visual ripple effect in 3D space
	# For now, we'll create a simple expanding circle representation
	
	var scene_root = get_tree().current_scene
	if not scene_root:
		return
	
	var ripple_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	sphere.height = 0.2
	ripple_mesh.mesh = sphere
	
	# Create material
	var material = StandardMaterial3D.new()
	material.flags_transparent = true
	material.albedo_color = consciousness_colors.get(int(consciousness_level), Color.WHITE)
	material.albedo_color.a = 0.3
	material.emission_enabled = true
	material.emission_color = material.albedo_color
	ripple_mesh.material_override = material
	
	ripple_mesh.global_position = center
	scene_root.add_child(ripple_mesh)
	
	# Animate ripple expansion
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	var final_scale = consciousness_level * 5.0
	tween.tween_property(ripple_mesh, "scale", Vector3.ONE * final_scale, 2.0)
	tween.tween_property(ripple_mesh, "modulate:a", 0.0, 2.0)
	
	tween.finished.connect(func(): ripple_mesh.queue_free())

func _create_evolution_particle_effect(position: Vector3, consciousness_level: float):
	"""Create particle effect for evolution events"""
	# Simple particle effect using multiple small spheres
	var scene_root = get_tree().current_scene
	if not scene_root:
		return
	
	for i in range(int(consciousness_level * 5)):
		var particle = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.05
		sphere.height = 0.1
		particle.mesh = sphere
		
		var material = StandardMaterial3D.new()
		material.emission_enabled = true
		material.emission_color = Color(1.0, 0.5, 0.0)  # Orange evolution color
		particle.material_override = material
		
		particle.global_position = position + Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1), 
			randf_range(-1, 1)
		)
		
		scene_root.add_child(particle)
		
		# Animate particles
		var tween = get_tree().create_tween()
		var end_pos = particle.global_position + Vector3(
			randf_range(-3, 3),
			randf_range(2, 5),
			randf_range(-3, 3)
		)
		
		tween.parallel().tween_property(particle, "global_position", end_pos, 1.5)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 1.5)
		
		tween.finished.connect(func(): particle.queue_free())

# ===== CLEANUP AND MANAGEMENT =====

func _cleanup_message(message_id: String):
	"""Clean up expired messages"""
	if active_messages.has(message_id):
		var message_data = active_messages[message_id]
		var node = message_data["node"]
		
		if is_instance_valid(node):
			# Fade out animation
			var tween = get_tree().create_tween()
			tween.tween_property(node, "modulate:a", 0.0, 0.5)
			tween.finished.connect(func(): node.queue_free())
		
		active_messages.erase(message_id)

func clear_all_messages():
	"""Clear all active UB_Print messages"""
	for message_id in active_messages.keys():
		_cleanup_message(message_id)
	
	message_nodes.clear()
	active_messages.clear()

func get_active_message_count() -> int:
	"""Get count of currently active messages"""
	return active_messages.size()

func set_consciousness_amplification(amplification: float):
	"""Set consciousness amplification factor"""
	consciousness_amplification = amplification

# ===== INTEGRATION FUNCTIONS =====

func integrate_with_universal_being(being: Node):
	"""Integrate UB_Print with a Universal Being"""
	if being and being.has_method("show_ub_visual"):
		# Replace the being's visual system with UB_Print
		being.ub_print_system = self

func register_consciousness_visualizer(visualizer: Node):
	"""Register a consciousness visualizer for enhanced feedback"""
	consciousness_visualizers.append(visualizer)

# ===== STATIC HELPER FUNCTIONS =====

static func get_ub_print_system() -> UBPrintSystem:
	"""Get the active UB_Print system"""
	var scene_tree = Engine.get_main_loop() as SceneTree
	if scene_tree and scene_tree.current_scene:
		return scene_tree.current_scene.find_child("UBPrintSystem") as UBPrintSystem
	return null

# 🌟 UB_PRINT SYSTEM COMPLETE! 🌟
# Visual consciousness feedback replacing print() statements
# Ready to make the invisible VISIBLE in the Universal Being revolution!