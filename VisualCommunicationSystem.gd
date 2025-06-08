
# 3D Visual Communication System for Universal Being
# Replaces all print statements with stellar-colored 3D visual feedback

extends Node

# Stellar color definitions
const STELLAR_COLORS = {
    "gemma_ai": Color(0.7, 0.9, 1.0),  # AI Communications
    "consciousness": Color(1.0, 1.0, 1.0),  # Consciousness Events
    "pentagon_lifecycle": Color(1.0, 1.0, 0.0),  # Pentagon Lifecycle
    "socket_system": Color(1.0, 0.6, 0.0),  # Socket Operations
    "dna_evolution": Color(0.8, 0.2, 0.8),  # DNA & Evolution
    "physics_interaction": Color(1.0, 0.2, 0.2),  # Physics Events
    "debugging": Color(0.4, 0.2, 0.1),  # Debug Messages
    "general": Color(0.2, 0.4, 1.0),  # General Messages

}

# Main visual communication function
func visual_message(message: String, category: String = "general", duration: float = 3.0) -> void:
    var color = STELLAR_COLORS.get(category, STELLAR_COLORS["general"])
    
    # Create 3D text display
    var label_3d = Label3D.new()
    label_3d.text = message
    label_3d.modulate = color
    label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label_3d.font_size = 24
    
    # Position above the being
    label_3d.position = Vector3(0, 2, 0)
    
    # Add to scene
    if get_parent():
        get_parent().add_child(label_3d)
    
    # Animate and remove
    var tween = create_tween()
    tween.parallel().tween_property(label_3d, "position", Vector3(0, 4, 0), duration)
    tween.parallel().tween_property(label_3d, "modulate:a", 0.0, duration)
    tween.tween_callback(label_3d.queue_free)

# Specific functions for each category
func gemma_message(text: String) -> void:
    visual_message("🤖 Gemma: " + text, "gemma_ai")

func consciousness_message(text: String) -> void:
    visual_message("🧠 " + text, "consciousness")

func pentagon_message(text: String) -> void:
    visual_message("🔆 " + text, "pentagon_lifecycle")

func socket_message(text: String) -> void:
    visual_message("🔌 " + text, "socket_system")

func dna_message(text: String) -> void:
    visual_message("🧬 " + text, "dna_evolution")

func physics_message(text: String) -> void:
    visual_message("⚡ " + text, "physics_interaction")

func debug_message(text: String) -> void:
    visual_message("🔧 " + text, "debugging")
