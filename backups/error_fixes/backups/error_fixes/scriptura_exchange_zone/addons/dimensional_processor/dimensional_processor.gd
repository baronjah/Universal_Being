extends Node

"""
Dimensional Processor Singleton
----------------------------
Provides global access to the 12-dimensional data processing system.
This singleton acts as a centralized manager for all dimensional processing
operations throughout the application.
"""

# Main components
var data_bridge: DimensionalDataBridge
var data_processor: OfflineDataProcessor

# Configuration
var config = {
    "auto_initialize": true,
    "default_dimension": 3,  # SPACE dimension
    "active_dimensions": [3, 4, 5],  # SPACE, TIME, FORM
    "enable_logging": true,
    "cache_results": true
}

# Caching
var _transformation_cache = {}
var _max_cache_entries = 100

# Dimension transition tracking
var dimension_history = []
var max_history_length = 20

# Signals
signal dimension_changed(old_dimension, new_dimension)
signal transformation_performed(source_dim, target_dim, data_type)
signal dimension_activated(dimension)
signal dimension_deactivated(dimension)

func _ready():
    # Initialize systems
    if config.auto_initialize:
        initialize()

func initialize() -> bool:
    # Create the dimensional bridge
    data_bridge = DimensionalDataBridge.new()
    add_child(data_bridge)
    
    # Get reference to the processor
    data_processor = data_bridge.get_processor()
    
    # Set up initial dimensions
    data_bridge.set_dimension(config.default_dimension)
    
    # Activate default dimensions
    for dim in config.active_dimensions:
        if dim != config.default_dimension:  # Current dimension is already active
            data_bridge.activate_dimension(dim)
    
    # Connect bridge signals
    data_bridge.connect("dimension_changed", self, "_on_dimension_changed")
    data_bridge.connect("transformation_completed", self, "_on_transformation_completed")
    
    # Log initialization
    if config.enable_logging:
        print("Dimensional Processor initialized with %d active dimensions" % config.active_dimensions.size())
    
    return true

# Primary API Methods
func transform(data, target_dimension: int):
    """Transform data from current dimension to the target dimension"""
    
    # Check if result is in cache
    var source_dimension = get_current_dimension()
    var cache_key = _generate_cache_key(data, source_dimension, target_dimension)
    
    if config.cache_results and _transformation_cache.has(cache_key):
        return _transformation_cache[cache_key]
    
    # Perform transformation
    var result = data_bridge.transform(data, target_dimension)
    
    # Cache successful results
    if config.cache_results and result.success:
        _transformation_cache[cache_key] = result
        _clean_cache_if_needed()
    
    return result

func transform_between(data, source_dimension: int, target_dimension: int):
    """Transform data between specific dimensions"""
    
    # Check if result is in cache
    var cache_key = _generate_cache_key(data, source_dimension, target_dimension)
    
    if config.cache_results and _transformation_cache.has(cache_key):
        return _transformation_cache[cache_key]
    
    # Perform transformation
    var result = data_bridge.transform_between(data, source_dimension, target_dimension)
    
    # Cache successful results
    if config.cache_results and result.success:
        _transformation_cache[cache_key] = result
        _clean_cache_if_needed()
    
    return result

func transform_by_names(data, source_name: String, target_name: String):
    """Transform data between dimensions using their names"""
    return data_bridge.transform_by_names(data, source_name, target_name)

func set_dimension(dimension: int):
    """Set the current active dimension"""
    var old_dimension = get_current_dimension()
    
    if old_dimension != dimension:
        # Add to dimension history
        _add_to_dimension_history(old_dimension)
        
        # Change dimension
        data_bridge.set_dimension(dimension)
    
func set_dimension_by_name(dimension_name: String) -> bool:
    """Set the current active dimension by name"""
    var old_dimension = get_current_dimension()
    var result = data_bridge.set_dimension_by_name(dimension_name)
    
    if result and old_dimension != get_current_dimension():
        # Add to dimension history
        _add_to_dimension_history(old_dimension)
    
    return result

func get_current_dimension() -> int:
    """Get current dimension ID"""
    return data_processor.get_current_dimension()

func get_current_dimension_name() -> String:
    """Get the name of the current dimension"""
    return data_bridge.get_current_dimension_name()

func activate_dimension(dimension: int) -> bool:
    """Activate an additional dimension"""
    var active_dims = get_active_dimensions()
    
    if not active_dims.has(dimension):
        var result = data_bridge.activate_dimension(dimension)
        emit_signal("dimension_activated", dimension)
        return result
    
    return true

func deactivate_dimension(dimension: int) -> bool:
    """Deactivate a dimension"""
    var active_dims = get_active_dimensions()
    
    if active_dims.has(dimension) and dimension != get_current_dimension():
        var result = data_bridge.deactivate_dimension(dimension)
        emit_signal("dimension_deactivated", dimension)
        return result
    
    return false

func get_active_dimensions() -> Array:
    """Get all currently active dimensions"""
    return data_processor.get_active_dimensions()

func get_dimension_stats() -> Dictionary:
    """Get current stats for all dimensions"""
    return data_bridge.get_dimension_stats()

func save_data(data, file_path: String, dimension: int = -1) -> bool:
    """Save data processed through a specific dimension"""
    
    # Use current dimension if not specified
    if dimension < 0:
        dimension = get_current_dimension()
    
    return data_bridge.save_dimensional_data(data, file_path, dimension)

func load_data(file_path: String) -> Dictionary:
    """Load dimensionally processed data"""
    return data_bridge.load_dimensional_data(file_path)

func transform_chain(data, dimension_chain: Array):
    """Apply a sequence of dimensional transformations"""
    return data_bridge.transform_chain(data, dimension_chain)

func get_dimension_influence(dimension: int) -> float:
    """Get the current influence level of a dimension"""
    var influence = data_bridge.get_dimension_influence(dimension)
    if influence:
        return influence.strength
    return 0.0

func set_dimension_influence(dimension: int, strength: float) -> bool:
    """Set the influence level of a dimension"""
    var influence = data_bridge.get_dimension_influence(dimension)
    if influence:
        influence.strength = clamp(strength, 0.0, 1.0)
        return true
    return false

func modify_dimension_aspect(dimension: int, aspect: String, value: float) -> bool:
    """Modify a specific aspect of a dimension"""
    return data_bridge.modify_aspect(dimension, aspect, value)

# Helper methods
func _generate_cache_key(data, source_dim: int, target_dim: int) -> String:
    """Generate a unique key for the transformation cache"""
    var data_hash = str(data).hash()
    return "%d_%d_%d" % [data_hash, source_dim, target_dim]

func _clean_cache_if_needed():
    """Clean the cache if it exceeds the maximum size"""
    if _transformation_cache.size() > _max_cache_entries:
        # Remove oldest entries (simple approach)
        var excess = _transformation_cache.size() - _max_cache_entries
        var keys = _transformation_cache.keys()
        
        for i in range(excess):
            if i < keys.size():
                _transformation_cache.erase(keys[i])

func _add_to_dimension_history(dimension: int):
    """Add a dimension to the transition history"""
    dimension_history.append(dimension)
    
    # Trim history if needed
    if dimension_history.size() > max_history_length:
        dimension_history.pop_front()

# Signal handlers
func _on_dimension_changed(dimension_id, dimension_name):
    """Handle dimension change events from the bridge"""
    var old_dimension = -1
    if dimension_history.size() > 0:
        old_dimension = dimension_history[-1]
    
    emit_signal("dimension_changed", old_dimension, dimension_id)

func _on_transformation_completed(source_dim, target_dim, success):
    """Handle transformation completion events from the bridge"""
    if success:
        emit_signal("transformation_performed", source_dim, target_dim, typeof(data))

# Convenience transformations (pass-through to data bridge)
func essence_transform(data): return data_bridge.essence_transform(data)
func energize(data): return data_bridge.energize(data)  
func spatialize(data): return data_bridge.spatialize(data)
func temporalize(data): return data_bridge.temporalize(data)
func formalize(data): return data_bridge.formalize(data)
func harmonize(data): return data_bridge.harmonize(data)
func reflect(data): return data_bridge.reflect(data)
func intend(data): return data_bridge.intend(data)
func create_new(data): return data_bridge.create_new(data)
func synthesize(data): return data_bridge.synthesize(data)
func transcend(data): return data_bridge.transcend(data)