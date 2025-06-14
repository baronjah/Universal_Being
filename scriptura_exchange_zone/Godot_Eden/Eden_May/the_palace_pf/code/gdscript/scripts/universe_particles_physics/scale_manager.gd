extends Node3D
class_name ScaleManager

# Scale properties
var scale_level: String = ""
var is_active: bool = false
var visibility: float = 0.0

# Signals - with unique names to avoid Node3D conflicts
signal scale_ready_for_activation
signal scale_activated
signal scale_deactivated
signal scale_visibility_changed(value)

func _ready():
    # Deactivate by default
    deactivate()

# Virtual functions to be implemented by derived classes
func initialize(data):
    # Initialize this scale with specific data
    pass

func activate():
    # Activate this scale (full processing, full visibility)
    is_active = true
    set_visibility(1.0)
    set_process(true)
    set_physics_process(true)
    
    emit_signal("scale_activated")

func deactivate():
    # Deactivate this scale (minimal processing, invisible)
    is_active = false
    set_visibility(0.0)
    set_process(false)
    set_physics_process(false)
    
    emit_signal("scale_deactivated")

func update(delta: float):
    # Update this scale's logic
    # This is called by the universe controller
    pass

func set_visibility(value: float):
    # Set visibility for transition effects
    visibility = clamp(value, 0.0, 1.0)
    update_visual_components()
    
    emit_signal("scale_visibility_changed", visibility)

func update_visual_components():
    # Update materials and visibility based on transition state
    # To be overridden by derived classes
    pass

func prepare_for_transition_to(target_scale: String):
    # Prepare this scale for a transition to another scale
    pass

func prepare_for_transition_from(source_scale: String):
    # Prepare this scale when transitioning from another scale
    pass

func get_focus_position(screen_position: Vector2) -> Vector3:
    # Get a suitable focus position for zooming
    return Vector3.ZERO

func get_camera_settings() -> Dictionary:
    # Return camera settings appropriate for this scale
    return {
        "fov": 70.0,
        "near": 0.1,
        "far": 1000.0,
        "position": Vector3(0, 0, 5),
        "target": Vector3.ZERO
    }

func get_scale_data() -> Dictionary:
    # Return data about this scale to pass to other scales
    return {
        "scale_level": scale_level,
        "active": is_active
    }

# Resource management
func register_resources():
    # Register all resources used by this scale
    # Called when this scale is activated
    pass

func unregister_resources():
    # Unregister resources when deactivating
    # Called when this scale is deactivated
    pass

# Helper functions
func is_object_visible(object_position: Vector3, camera_position: Vector3, view_distance: float) -> bool:
    # Determine if an object is visible based on distance
    return object_position.distance_to(camera_position) <= view_distance

# Event handling
func _on_object_clicked(object):
    # Handle object selection in this scale
    pass

func _on_transition_requested(target_scale, focus_object):
    # Handle transition request to another scale
    pass