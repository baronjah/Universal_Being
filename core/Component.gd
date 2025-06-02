# ==================================================
# UNIVERSAL BEING COMPONENT: Base Component
# PURPOSE: Base class for all Universal Being components
# ==================================================

extends Node
class_name Component

# Component identity
var component_name: String = "base_component"
var component_version: String = "1.0.0"
var component_description: String = "Base component class"

# Component state
var is_active: bool = true
var parent_being: UniversalBeing = null
var component_data: Dictionary = {}

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func _init() -> void:
    pentagon_init()

func _ready() -> void:
    pentagon_ready()

func _process(delta: float) -> void:
    if is_active:
        pentagon_process(delta)

func _input(event: InputEvent) -> void:
    if is_active:
        pentagon_input(event)

func _exit_tree() -> void:
    pentagon_sewers()

# Pentagon methods to be implemented by components
func pentagon_init() -> void:
    """Initialize component"""
    pass

func pentagon_ready() -> void:
    """Component is ready"""
    pass

func pentagon_process(delta: float) -> void:
    """Process component logic"""
    pass

func pentagon_input(event: InputEvent) -> void:
    """Handle component input"""
    pass

func pentagon_sewers() -> void:
    """Cleanup component"""
    pass

# ===== COMPONENT MANAGEMENT =====

func set_parent_being(being: UniversalBeing) -> void:
    """Set the parent Universal Being"""
    parent_being = being

func get_parent_being() -> UniversalBeing:
    """Get the parent Universal Being"""
    return parent_being

func activate() -> void:
    """Activate the component"""
    is_active = true

func deactivate() -> void:
    """Deactivate the component"""
    is_active = false

func set_component_data(data: Dictionary) -> void:
    """Set component data"""
    component_data = data

func get_component_data() -> Dictionary:
    """Get component data"""
    return component_data

# ===== UTILITY FUNCTIONS =====

func get_component_info() -> Dictionary:
    """Get component information"""
    return {
        "name": component_name,
        "version": component_version,
        "description": component_description,
        "is_active": is_active,
        "parent_being": parent_being.being_name if parent_being else "none"
    }

func _to_string() -> String:
    return "Component<%s:%s>" % [component_name, component_version] 