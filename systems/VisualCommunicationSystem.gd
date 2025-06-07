extends Node
class_name VisualCommunicationSystem

# 3D Visual Communication System for Universal Being
# Replaces ALL print statements with stellar-colored 3D visual feedback
# Maintains Gemma's identity and creates immersive communication

# Stellar color definitions based on astronomical classification
const STELLAR_COLORS = {
	"gemma_ai": Color(0.7, 0.9, 1.0),      # Light Blue - AI Communications (Gemma specifically)
	"consciousness": Color(1.0, 1.0, 1.0),  # White - Consciousness Events
	"pentagon_lifecycle": Color(1.0, 1.0, 0.0),  # Yellow - Pentagon Lifecycle
	"socket_system": Color(1.0, 0.6, 0.0),  # Orange - Socket Operations
	"dna_evolution": Color(0.8, 0.2, 0.8),  # Purple - DNA & Evolution
	"physics_interaction": Color(1.0, 0.2, 0.2),  # Red - Physics Events
	"debugging": Color(0.4, 0.2, 0.1),      # Dark Brown - Debug Messages
	"general": Color(0.2, 0.4, 1.0),        # Blue - General Messages
	"black": Color(0.1, 0.1, 0.1),          # Black - System Critical
}

# Global reference for Universal Being system integration
var parent_being: Node = null
var message_queue: Array[Dictionary] = []
var is_active: bool = true

func _ready() -> void:
	# Auto-detect parent Universal Being
	parent_being = get_parent()
	if parent_being and parent_being.has_method("pentagon_init"):
		# We're attached to a Universal Being
		visual_message("Visual Communication System activated", "general", 2.0)

# Main visual communication function with enhanced 3D effects
func visual_message(message: String, category: String = "general", duration: float = 3.0, position_offset: Vector3 = Vector3.ZERO) -> void:
	if not is_active:
		return
		
	var color = STELLAR_COLORS.get(category, STELLAR_COLORS["general"])
	
	# Create 3D text display with enhanced features
	var label_3d = Label3D.new()
	label_3d.text = message
	label_3d.modulate = color
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_3d.font_size = 20
	label_3d.outline_size = 2
	label_3d.outline_modulate = Color.BLACK
	
	# Enhanced positioning system
	var base_position = Vector3(0, 2, 0) + position_offset
	if parent_being and parent_being.has_method("get_global_position"):
		base_position += parent_being.get_global_position()
	
	label_3d.position = base_position
	
	# Add to appropriate parent
	var scene_root = get_tree().current_scene
	if scene_root:
		scene_root.add_child(label_3d)
	elif parent_being:
		parent_being.add_child(label_3d)
	else:
		add_child(label_3d)
	
	# Enhanced animation with stellar effects
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Float upward movement
	tween.tween_property(label_3d, "position", base_position + Vector3(0, 3, 0), duration)
	
	# Stellar glow effect for special categories
	if category in ["gemma_ai", "consciousness"]:
		# Add pulsing glow effect
		var glow_tween = tween.tween_method(_pulse_glow.bind(label_3d), 1.0, 0.3, duration/3)
		glow_tween.tween_method(_pulse_glow.bind(label_3d), 0.3, 1.0, duration/3)
		glow_tween.tween_method(_pulse_glow.bind(label_3d), 1.0, 0.0, duration/3)
	else:
		# Standard fade out
		tween.tween_property(label_3d, "modulate:a", 0.0, duration)
	
	# Clean up
	tween.tween_callback(label_3d.queue_free)

func _pulse_glow(label: Label3D, intensity: float) -> void:
	if is_instance_valid(label):
		label.modulate.a = intensity

# Specific functions for each category with enhanced messaging

func gemma_message(text: String, duration: float = 4.0) -> void:
	# Ensure Gemma's identity is always clear and prominent
	var enhanced_text = "🤖 GEMMA AI: " + text
	visual_message(enhanced_text, "gemma_ai", duration, Vector3(0.5, 0, 0))

func consciousness_message(text: String, level: int = 0) -> void:
	var prefix = "🧠 " if level == 0 else "🌟".repeat(level) + " "
	visual_message(prefix + text, "consciousness")

func pentagon_message(phase: String, text: String) -> void:
	var phase_symbols = {
		"init": "🌱",
		"ready": "⚡",
		"process": "🔄",
		"input": "👁️",
		"sewers": "🌊"
	}
	var symbol = phase_symbols.get(phase, "🔆")
	visual_message(symbol + " PENTAGON[" + phase.to_upper() + "]: " + text, "pentagon_lifecycle")

func socket_message(text: String, socket_type: String = "") -> void:
	var type_prefix = socket_type if socket_type != "" else "SOCKET"
	visual_message("🔌 " + type_prefix + ": " + text, "socket_system")

func dna_message(text: String, being_name: String = "") -> void:
	var prefix = "🧬 DNA"
	if being_name != "":
		prefix += "[" + being_name + "]"
	visual_message(prefix + ": " + text, "dna_evolution")

func physics_message(text: String) -> void:
	visual_message("⚡ PHYSICS: " + text, "physics_interaction")

func debug_message(text: String, level: String = "INFO") -> void:
	var level_symbols = {
		"ERROR": "❌",
		"WARNING": "⚠️",
		"INFO": "🔧",
		"SUCCESS": "✅"
	}
	var symbol = level_symbols.get(level, "🔧")
	visual_message(symbol + " [" + level + "]: " + text, "debugging")

func system_critical(text: String) -> void:
	# Ultra-prominent system critical messages
	visual_message("🚨 CRITICAL: " + text, "black", 8.0, Vector3(0, 1, 0))

# Queue management for high-frequency messages
func queue_message(message: String, category: String = "general", delay: float = 0.0) -> void:
	message_queue.append({
		"message": message,
		"category": category,
		"timestamp": Time.get_ticks_msec() + (delay * 1000)
	})

func _process(delta: float) -> void:
	# Process queued messages
	var current_time = Time.get_ticks_msec()
	for i in range(message_queue.size() - 1, -1, -1):
		var queued_msg = message_queue[i]
		if current_time >= queued_msg.timestamp:
			visual_message(queued_msg.message, queued_msg.category)
			message_queue.remove_at(i)

# Universal Being integration helpers
func attach_to_being(being: Node) -> void:
	parent_being = being
	if being.has_method("add_component"):
		being.add_component(self)

func set_communication_active(active: bool) -> void:
	is_active = active
	if active:
		visual_message("Visual communications restored", "general")

# Global access pattern for Universal Being architecture
static var instance: VisualCommunicationSystem

func _enter_tree() -> void:
	if not instance:
		instance = self

static func get_instance() -> VisualCommunicationSystem:
	return instance

# Quick access functions for global usage
static func show_message(text: String, category: String = "general") -> void:
	if instance:
		instance.visual_message(text, category)

static func show_gemma(text: String) -> void:
	if instance:
		instance.gemma_message(text)

static func show_debug(text: String, level: String = "INFO") -> void:
	if instance:
		instance.debug_message(text, level)