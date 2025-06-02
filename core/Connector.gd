# ==================================================
# CONNECTOR - Logic DNA for Universal Being Interactions
# PURPOSE: Bind components and process interactions
# LOCATION: core/Connector.gd (75 lines)
# ==================================================

extends Node
class_name Connector

## Component binding system
static func bind_components(being: UniversalBeing, components: Array) -> bool:
    """Bind ZIP components to Universal Being"""
    if not being:
        return false
    
    for component_data in components:
        if component_data is Dictionary:
            _bind_single_component(being, component_data)
    
    return true

static func _bind_single_component(being: UniversalBeing, component: Dictionary) -> void:
    """Bind one component to being"""
    var component_name = component.get("name", "unknown")
    var component_type = component.get("type", "generic")
    
    # Add to being's component registry
    if not being.has_meta("components"):
        being.set_meta("components", {})
    
    var components_dict = being.get_meta("components", {})
    components_dict[component_name] = component
    being.set_meta("components", components_dict)

## Interaction processing
static func process_interactions(being: UniversalBeing, dna: Dictionary) -> void:
    """Process Logic DNA for being interactions"""
    if not being or dna.is_empty():
        return
    
    # Process interaction rules
    var interactions = dna.get("interactions", [])
    for interaction in interactions:
        _process_single_interaction(being, interaction)

static func _process_single_interaction(being: UniversalBeing, interaction: Dictionary) -> void:
    """Process one interaction rule"""
    var trigger = interaction.get("trigger", "")
    var action = interaction.get("action", "")
    var target = interaction.get("target", "")
    
    # Simple interaction processor
    if trigger == "collision" and being.has_method("on_collision"):
        being.call("on_collision", target)
    elif trigger == "signal" and being.has_method("on_signal"):
        being.call("on_signal", action, target)

## ZIP Package Integration
static func extract_logic_dna(zip_path: String) -> Dictionary:
    """Extract logic DNA from .ub.zip package"""
    # TODO: Implement ZIP reading
    # For now, return empty DNA
    return {}

static func create_logic_dna(being: UniversalBeing) -> Dictionary:
    """Create logic DNA from current being state"""
    var dna = {
        "being_name": being.being_name,
        "being_type": being.being_type,
        "consciousness_level": being.consciousness_level,
        "interactions": [],
        "components": being.get_meta("components", {}),
        "evolution_paths": being.evolution_state.can_become
    }
    
    return dna