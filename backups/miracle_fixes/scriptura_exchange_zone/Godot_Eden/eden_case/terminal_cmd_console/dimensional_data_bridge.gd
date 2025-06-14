extends Node
class_name DimensionalDataBridge

"""
DimensionalDataBridge
-------------------
A user-friendly wrapper for the OfflineDataProcessor that simplifies
working with the 12-dimensional data processing system.

This bridge provides convenient methods for working with dimensional
data transformations and operations across the 12 dimensions.
"""

# Reference to the main processor
var _processor: OfflineDataProcessor
var _auto_setup_processor: bool = true

# Dimension names for easier reference
const DIMENSION_NAMES = {
    0: "VOID",
    1: "ESSENCE",
    2: "ENERGY",
    3: "SPACE",
    4: "TIME",
    5: "FORM",
    6: "HARMONY",
    7: "AWARENESS",
    8: "REFLECTION",
    9: "INTENT",
    10: "GENESIS",
    11: "SYNTHESIS",
    12: "TRANSCENDENCE"
}

# Signal forwarding
signal dimension_changed(dimension_id, dimension_name)
signal transformation_completed(source_dim, target_dim, success)

func _ready():
    if _auto_setup_processor:
        _setup_processor()

func _setup_processor():
    # Create the processor if it doesn't exist
    if not _processor:
        _processor = OfflineDataProcessor.new()
        add_child(_processor)
        _processor.initialize()
        print("DimensionalDataBridge: Initialized Offline Data Processor")

# Core dimensional API methods
func set_dimension(dimension_id: int) -> void:
    """Change the current active dimension"""
    
    if not _processor:
        _setup_processor()
    
    _processor.set_current_dimension(dimension_id)
    emit_signal("dimension_changed", dimension_id, DIMENSION_NAMES.get(dimension_id, "UNKNOWN"))

func set_dimension_by_name(dimension_name: String) -> bool:
    """Change the current active dimension using its name"""
    
    dimension_name = dimension_name.to_upper()
    
    # Find the dimension ID by name
    var dimension_id = -1
    for id in DIMENSION_NAMES:
        if DIMENSION_NAMES[id] == dimension_name:
            dimension_id = id
            break
    
    if dimension_id == -1:
        push_error("DimensionalDataBridge: Unknown dimension name: " + dimension_name)
        return false
    
    set_dimension(dimension_id)
    return true

func transform(data, target_dimension: int) -> Dictionary:
    """Transform data from the current dimension to the target dimension"""
    
    if not _processor:
        _setup_processor()
    
    var source_dimension = _processor.get_current_dimension()
    var result = _processor.transform_data_across_dimensions(data, source_dimension, target_dimension)
    
    emit_signal("transformation_completed", source_dimension, target_dimension, result.success)
    return result

func transform_between(data, source_dimension: int, target_dimension: int) -> Dictionary:
    """Transform data between specific dimensions"""
    
    if not _processor:
        _setup_processor()
    
    var result = _processor.transform_data_across_dimensions(data, source_dimension, target_dimension)
    
    emit_signal("transformation_completed", source_dimension, target_dimension, result.success)
    return result

func transform_by_names(data, source_name: String, target_name: String) -> Dictionary:
    """Transform data between dimensions using their names"""
    
    source_name = source_name.to_upper()
    target_name = target_name.to_upper()
    
    # Find the dimension IDs by name
    var source_id = -1
    var target_id = -1
    
    for id in DIMENSION_NAMES:
        if DIMENSION_NAMES[id] == source_name:
            source_id = id
        if DIMENSION_NAMES[id] == target_name:
            target_id = id
    
    if source_id == -1 or target_id == -1:
        push_error("DimensionalDataBridge: Unknown dimension name(s): " + 
                  (source_name if source_id == -1 else "") + 
                  (", " if source_id == -1 and target_id == -1 else "") +
                  (target_name if target_id == -1 else ""))
        return {"success": false, "error": "Unknown dimension name(s)"}
    
    return transform_between(data, source_id, target_id)

func get_current_dimension_name() -> String:
    """Get the name of the current dimension"""
    
    if not _processor:
        _setup_processor()
    
    var current_dim = _processor.get_current_dimension()
    return DIMENSION_NAMES.get(current_dim, "UNKNOWN")

func get_active_dimension_names() -> Array:
    """Get the names of all active dimensions"""
    
    if not _processor:
        _setup_processor()
    
    var active_dims = _processor.get_active_dimensions()
    var dimension_names = []
    
    for dim_id in active_dims:
        dimension_names.append(DIMENSION_NAMES.get(dim_id, "UNKNOWN"))
    
    return dimension_names

# Dimension influence modifiers
func boost_dimension(dimension_id: int, amount: float = 0.2) -> void:
    """Increase the influence of a specific dimension"""
    
    if not _processor:
        _setup_processor()
    
    var influence = _processor.get_dimension_influence(dimension_id)
    if influence:
        influence.strength = min(1.0, influence.strength + amount)
    
    # Activate the dimension if not already active
    _processor.activate_dimension(dimension_id)

func reduce_dimension(dimension_id: int, amount: float = 0.2) -> void:
    """Decrease the influence of a specific dimension"""
    
    if not _processor:
        _setup_processor()
    
    var influence = _processor.get_dimension_influence(dimension_id)
    if influence:
        influence.strength = max(0.0, influence.strength - amount)
        
        # If influence is very low, consider deactivating
        if influence.strength < 0.1:
            _processor.deactivate_dimension(dimension_id)

func modify_aspect(dimension_id: int, aspect_name: String, value: float) -> bool:
    """Modify a specific aspect of a dimension"""
    
    if not _processor:
        _setup_processor()
    
    var influence = _processor.get_dimension_influence(dimension_id)
    if influence:
        influence.modify_aspect(aspect_name, value)
        return true
    
    return false

# High-level convenience methods
func essence_transform(data):
    """Extract the essence/core of the data"""
    return transform(data, OfflineDataProcessor.DimensionalPlane.ESSENCE).data

func energize(data):
    """Amplify and energize the data"""
    return transform(data, OfflineDataProcessor.DimensionalPlane.ENERGY).data

func spatialize(data):
    """Apply spatial transformation to the data"""
    return transform(data, OfflineDataProcessor.DimensionalPlane.SPACE).data

func temporalize(data):
    """Apply temporal transformation to the data"""
    return transform(data, OfflineDataProcessor.DimensionalPlane.TIME).data

func formalize(data):
    """Apply form/shape transformation to the data"""
    return transform(data, OfflineDataProcessor.DimensionalPlane.FORM).data

func harmonize(data):
    """Create harmony and balance in the data"""
    return transform(data, OfflineDataProcessor.DimensionalPlane.HARMONY).data

func reflect(data):
    """Create a reflection/mirror of the data"""
    return transform(data, OfflineDataProcessor.DimensionalPlane.REFLECTION).data

func intend(data):
    """Apply purpose and direction to the data"""
    return transform(data, OfflineDataProcessor.DimensionalPlane.INTENT).data

func create_new(data):
    """Generate new creations from the data"""
    return transform(data, OfflineDataProcessor.DimensionalPlane.GENESIS).data

func synthesize(data):
    """Integrate and unify elements in the data"""
    return transform(data, OfflineDataProcessor.DimensionalPlane.SYNTHESIS).data

func transcend(data):
    """Transform the data beyond its limitations"""
    return transform(data, OfflineDataProcessor.DimensionalPlane.TRANSCENDENCE).data

# Utility method for applying a chain of dimensional transformations
func transform_chain(data, dimension_chain: Array):
    """Apply a sequence of dimensional transformations"""
    
    var result = {"success": true, "data": data, "error": null}
    var current_data = data
    
    for dimension in dimension_chain:
        var dim_id = dimension
        
        # Handle string dimension names
        if typeof(dimension) == TYPE_STRING:
            for id in DIMENSION_NAMES:
                if DIMENSION_NAMES[id] == dimension.to_upper():
                    dim_id = id
                    break
        
        var transform_result
        if typeof(dim_id) == TYPE_INT:
            transform_result = transform(current_data, dim_id)
        else:
            result.success = false
            result.error = "Invalid dimension in chain: " + str(dimension)
            break
        
        if transform_result.success:
            current_data = transform_result.data
        else:
            result.success = false
            result.error = "Transformation failed at dimension " + str(dimension) + ": " + str(transform_result.error)
            break
    
    if result.success:
        result.data = current_data
    
    return result

# Data type-specific transformations
func transform_text(text: String, target_dimension: int) -> String:
    var result = transform(text, target_dimension)
    return result.data if result.success else text

func transform_dict(dict: Dictionary, target_dimension: int) -> Dictionary:
    var result = transform(dict, target_dimension)
    return result.data if result.success else dict

func transform_array(array: Array, target_dimension: int) -> Array:
    var result = transform(array, target_dimension)
    return result.data if result.success else array

func transform_number(number: float, target_dimension: int) -> float:
    var result = transform(number, target_dimension)
    return result.data if result.success else number

# Persistence and file operations
func save_dimensional_data(data, file_path: String, dimension: int) -> bool:
    """Save data that has been processed through a specific dimension"""
    
    if not _processor:
        _setup_processor()
    
    # Transform the data through the specified dimension
    var transform_result = transform(data, dimension)
    if not transform_result.success:
        return false
    
    # Convert to string for storage if needed
    var content = transform_result.data
    if typeof(content) == TYPE_DICTIONARY or typeof(content) == TYPE_ARRAY:
        # Add dimensional metadata
        if typeof(content) == TYPE_DICTIONARY:
            content["_dimension"] = dimension
            content["_dimension_name"] = DIMENSION_NAMES.get(dimension, "UNKNOWN")
        
        content = JSON.print(content, "  ")
    elif typeof(content) != TYPE_STRING:
        content = str(content)
    
    # Save the file
    return _processor.write_text_file(file_path, content)

func load_dimensional_data(file_path: String) -> Dictionary:
    """Load data that has been processed through a dimension"""
    
    if not _processor:
        _setup_processor()
    
    var content = _processor.read_text_file(file_path)
    if not content:
        return {"success": false, "data": null, "error": "Failed to read file"}
    
    # Try to parse as JSON first
    var parsed_json = JSON.parse(content)
    if parsed_json.error == OK:
        var result = {"success": true, "data": parsed_json.result, "source_dimension": 0}
        
        # Extract dimensional metadata if present
        if typeof(parsed_json.result) == TYPE_DICTIONARY:
            if parsed_json.result.has("_dimension"):
                result.source_dimension = parsed_json.result._dimension
            
            if parsed_json.result.has("_dimension_name"):
                result.dimension_name = parsed_json.result._dimension_name
        
        return result
    else:
        # Return as string if not valid JSON
        return {"success": true, "data": content, "source_dimension": 0}

# Access to the underlying processor
func get_processor() -> OfflineDataProcessor:
    if not _processor:
        _setup_processor()
    
    return _processor

func get_dimension_stats() -> Dictionary:
    if not _processor:
        _setup_processor()
    
    var stats = _processor.get_dimension_stats()
    
    # Add dimension names for easier use
    var enhanced_stats = stats.duplicate(true)
    enhanced_stats.dimension_names = {}
    
    for dim in stats.active_dimensions:
        enhanced_stats.dimension_names[dim] = DIMENSION_NAMES.get(dim, "UNKNOWN")
    
    enhanced_stats.current_dimension_name = DIMENSION_NAMES.get(stats.current_dimension, "UNKNOWN")
    
    return enhanced_stats

# Example usage:
# var dimension_bridge = DimensionalDataBridge.new()
# add_child(dimension_bridge)
#
# # Simple text transformation through different dimensions
# var original_text = "The dimensional data bridge transforms information across planes of reality"
# 
# # Transform through the ESSENCE dimension (core meaning)
# var essence_text = dimension_bridge.essence_transform(original_text)
# print("Essence:", essence_text)
# 
# # Transform through the ENERGY dimension (amplification)
# var energized_text = dimension_bridge.energize(original_text)
# print("Energized:", energized_text)
# 
# # Apply a chain of dimensional transformations
# var transformed_text = dimension_bridge.transform_chain(
#     original_text,
#     ["ESSENCE", "ENERGY", "FORM"]
# ).data
# print("Chain result:", transformed_text)
# 
# # Save dimensionally-processed data
# dimension_bridge.save_dimensional_data(
#     {"message": original_text, "timestamp": OS.get_unix_time()},
#     "user://dimensional_data.json", 
#     OfflineDataProcessor.DimensionalPlane.TRANSCENDENCE
# )