extends Node
class_name Ethereal_Engine_Connector

"""
Ethereal_Engine_Connector
------------------------
Connects memory systems to the Ethereal Engine framework
Manages snake_case naming and case-sensitive memory patterns
Handles memory transmission between small_ and BIG letter systems
"""

# Engine Constants
const ENGINE_MODES = {
    "standard_mode": 0,      # Normal operation
    "ethereal_mode": 1,      # Enhanced memory operations
    "dimensional_mode": 2,   # Multi-dimensional memory handling
    "integration_mode": 3,   # System integration focus
    "development_mode": 4,   # For engine development
    "debug_mode": 5,         # Debugging operations
    "performance_mode": 6    # High-performance operations
}

const NAMING_CONVENTIONS = {
    "snake_case": 0,         # word_word_word
    "camelCase": 1,          # wordWordWord
    "PascalCase": 2,         # WordWordWord
    "kebab-case": 3,         # word-word-word
    "SCREAMING_SNAKE": 4,    # WORD_WORD_WORD
    "small_BIG": 5,          # small_BIG_small
    "Mixed_Case": 6          # Mixed_Case_Pattern
}

const ANIMATION_STYLES = {
    "portal": 0,            # Portal-based transitions
    "glitch": 1,            # Glitch effect animations
    "flow": 2,              # Flowing transitions
    "dimension_shift": 3,   # Dimensional shift effects
    "gradient_morph": 4,    # Gradient morphing
    "pulse": 5,             # Pulsing animations
    "ethereal_glow": 6      # Glowing ethereal effect
}

# System Components
var _memory_system = null
var _yoyo_catcher = null
var _connection_system = null
var _main_system = null
var _current_engine_mode = ENGINE_MODES.standard_mode
var _current_naming_convention = NAMING_CONVENTIONS.snake_case
var _current_animation_style = ANIMATION_STYLES.ethereal_glow
var _connected_devices = []
var _engine_initialized = false
var _integration_level = 0  # 0-10 scale
var _auto_sync_enabled = true
var _naming_converter = null
var _animation_controller = null

# Data Structures
class EngineComponent:
    var id: String
    var name: String
    var type: String
    var naming_convention: int
    var dependencies = []
    var interfaces = []
    var is_active: bool = false
    var metadata = {}
    
    func _init(p_id: String, p_name: String, p_type: String):
        id = p_id
        name = p_name
        type = p_type
        naming_convention = NAMING_CONVENTIONS.snake_case
    
    func activate():
        is_active = true
    
    func deactivate():
        is_active = false
    
    func add_dependency(component_id: String):
        if not dependencies.has(component_id):
            dependencies.append(component_id)
    
    func add_interface(interface_name: String):
        if not interfaces.has(interface_name):
            interfaces.append(interface_name)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
            "type": type,
            "naming_convention": naming_convention,
            "dependencies": dependencies,
            "interfaces": interfaces,
            "is_active": is_active,
            "metadata": metadata
        }
    
    static func from_dict(data: Dictionary) -> EngineComponent:
        var component = EngineComponent.new(
            data.id,
            data.name,
            data.type
        )
        
        component.naming_convention = data.naming_convention
        component.dependencies = data.dependencies.duplicate()
        component.interfaces = data.interfaces.duplicate()
        component.is_active = data.is_active
        component.metadata = data.metadata.duplicate()
        
        return component

class EngineIntegration:
    var id: String
    var source_component: String
    var target_component: String
    var integration_level: int  # 0-10 scale
    var naming_map = {}  # source_name -> target_name
    var active_channels = []
    var is_bidirectional: bool
    var metadata = {}
    
    func _init(p_id: String, p_source: String, p_target: String):
        id = p_id
        source_component = p_source
        target_component = p_target
        integration_level = 5  # Default middle level
        is_bidirectional = false
    
    func add_name_mapping(source_name: String, target_name: String):
        naming_map[source_name] = target_name
    
    func add_channel(channel_name: String):
        if not active_channels.has(channel_name):
            active_channels.append(channel_name)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "source_component": source_component,
            "target_component": target_component,
            "integration_level": integration_level,
            "naming_map": naming_map,
            "active_channels": active_channels,
            "is_bidirectional": is_bidirectional,
            "metadata": metadata
        }
    
    static func from_dict(data: Dictionary) -> EngineIntegration:
        var integration = EngineIntegration.new(
            data.id,
            data.source_component,
            data.target_component
        )
        
        integration.integration_level = data.integration_level
        for key in data.naming_map:
            integration.naming_map[key] = data.naming_map[key]
        integration.active_channels = data.active_channels.duplicate()
        integration.is_bidirectional = data.is_bidirectional
        integration.metadata = data.metadata.duplicate()
        
        return integration

class AnimationController:
    var current_style: int
    var animation_speed: float = 1.0
    var is_active: bool = false
    var supported_styles = []
    var active_animations = {}  # id -> animation properties
    var target_canvas = null
    
    func _init(p_style: int = ANIMATION_STYLES.ethereal_glow):
        current_style = p_style
        
        # Add all supported styles
        for style in ANIMATION_STYLES.values():
            supported_styles.append(style)
    
    func set_style(style: int) -> bool:
        if supported_styles.has(style):
            current_style = style
            return true
        return false
    
    func set_speed(speed: float) -> bool:
        if speed > 0:
            animation_speed = speed
            return true
        return false
    
    func start():
        is_active = true
    
    func stop():
        is_active = false
    
    func create_animation(element_id: String, properties: Dictionary) -> String:
        var animation_id = "anim_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
        
        var animation_data = properties.duplicate()
        animation_data["element_id"] = element_id
        animation_data["style"] = current_style
        animation_data["speed"] = animation_speed
        animation_data["created_at"] = OS.get_unix_time()
        animation_data["is_active"] = true
        
        active_animations[animation_id] = animation_data
        
        return animation_id
    
    func update_animation(animation_id: String, properties: Dictionary) -> bool:
        if not active_animations.has(animation_id):
            return false
        
        var animation_data = active_animations[animation_id]
        
        for key in properties:
            animation_data[key] = properties[key]
        
        active_animations[animation_id] = animation_data
        
        return true
    
    func stop_animation(animation_id: String) -> bool:
        if not active_animations.has(animation_id):
            return false
        
        active_animations[animation_id].is_active = false
        
        return true
    
    func render_animations(delta: float):
        if not is_active or not target_canvas:
            return
        
        for animation_id in active_animations:
            var animation = active_animations[animation_id]
            
            if not animation.is_active:
                continue
            
            # Render based on style
            match animation.style:
                ANIMATION_STYLES.portal:
                    _render_portal_animation(animation, delta)
                
                ANIMATION_STYLES.glitch:
                    _render_glitch_animation(animation, delta)
                
                ANIMATION_STYLES.flow:
                    _render_flow_animation(animation, delta)
                
                ANIMATION_STYLES.dimension_shift:
                    _render_dimension_shift_animation(animation, delta)
                
                ANIMATION_STYLES.gradient_morph:
                    _render_gradient_morph_animation(animation, delta)
                
                ANIMATION_STYLES.pulse:
                    _render_pulse_animation(animation, delta)
                
                ANIMATION_STYLES.ethereal_glow:
                    _render_ethereal_glow_animation(animation, delta)
    
    func _render_portal_animation(animation: Dictionary, delta: float):
        # Implementation would draw portal effect on canvas
        pass
    
    func _render_glitch_animation(animation: Dictionary, delta: float):
        # Implementation would draw glitch effect on canvas
        pass
    
    func _render_flow_animation(animation: Dictionary, delta: float):
        # Implementation would draw flow effect on canvas
        pass
    
    func _render_dimension_shift_animation(animation: Dictionary, delta: float):
        # Implementation would draw dimension shift effect on canvas
        pass
    
    func _render_gradient_morph_animation(animation: Dictionary, delta: float):
        # Implementation would draw gradient morph effect on canvas
        pass
    
    func _render_pulse_animation(animation: Dictionary, delta: float):
        # Implementation would draw pulse effect on canvas
        pass
    
    func _render_ethereal_glow_animation(animation: Dictionary, delta: float):
        # Implementation would draw ethereal glow effect on canvas
        pass
    
    func to_dict() -> Dictionary:
        var animations_data = {}
        for anim_id in active_animations:
            animations_data[anim_id] = active_animations[anim_id]
        
        return {
            "current_style": current_style,
            "animation_speed": animation_speed,
            "is_active": is_active,
            "supported_styles": supported_styles,
            "active_animations": animations_data
        }

class NamingConverter:
    var default_convention: int
    var mapping_rules = {}  # source_convention -> target_convention -> rules
    
    func _init(p_default: int = NAMING_CONVENTIONS.snake_case):
        default_convention = p_default
        _initialize_mapping_rules()
    
    func _initialize_mapping_rules():
        # Setup conversion rules between naming conventions
        for source in NAMING_CONVENTIONS.values():
            mapping_rules[source] = {}
            
            for target in NAMING_CONVENTIONS.values():
                if source == target:
                    continue
                
                # Each rule is a function reference to do the conversion
                mapping_rules[source][target] = funcref(self, "_convert_" + str(source) + "_to_" + str(target))
    
    func convert_name(name: String, source_convention: int, target_convention: int) -> String:
        if source_convention == target_convention:
            return name
        
        if not mapping_rules.has(source_convention) or not mapping_rules[source_convention].has(target_convention):
            # Fall back to default splitter/joiner approach
            var parts = split_name(name, source_convention)
            return join_parts(parts, target_convention)
        
        # Use specific conversion rule if available
        var rule = mapping_rules[source_convention][target_convention]
        if rule and rule.is_valid():
            return rule.call_func(name)
        
        # Fall back to default approach
        var parts = split_name(name, source_convention)
        return join_parts(parts, target_convention)
    
    func split_name(name: String, convention: int) -> Array:
        match convention:
            NAMING_CONVENTIONS.snake_case:
                return name.split("_")
            
            NAMING_CONVENTIONS.camelCase:
                # Split camelCase into parts
                var parts = []
                var current_part = ""
                
                for i in range(name.length()):
                    var c = name[i]
                    if i > 0 and c.to_upper() == c and c.is_valid_identifier():
                        parts.append(current_part)
                        current_part = c
                    else:
                        current_part += c
                
                if not current_part.empty():
                    parts.append(current_part)
                
                return parts
            
            NAMING_CONVENTIONS.PascalCase:
                # Split PascalCase into parts
                var parts = []
                var current_part = ""
                
                for i in range(name.length()):
                    var c = name[i]
                    if i > 0 and c.to_upper() == c and c.is_valid_identifier():
                        parts.append(current_part)
                        current_part = c
                    else:
                        current_part += c
                
                if not current_part.empty():
                    parts.append(current_part)
                
                return parts
            
            NAMING_CONVENTIONS.kebab-case:
                return name.split("-")
            
            NAMING_CONVENTIONS.SCREAMING_SNAKE:
                return name.split("_")
            
            NAMING_CONVENTIONS.small_BIG:
                # Handle small_BIG pattern
                var parts = name.split("_")
                var result = []
                
                for part in parts:
                    if part.length() > 0:
                        if part[0].to_upper() == part[0]:
                            # This is a BIG part
                            result.append(part)
                        else:
                            # This is a small part
                            result.append(part)
                
                return result
            
            NAMING_CONVENTIONS.Mixed_Case:
                # Handle Mixed_Case_Pattern
                return name.split("_")
            
            _:
                # Default: just split on non-alphanumeric
                var regex = RegEx.new()
                regex.compile("[^a-zA-Z0-9]+")
                return regex.split(name, true)
    
    func join_parts(parts: Array, convention: int) -> String:
        match convention:
            NAMING_CONVENTIONS.snake_case:
                # Convert all parts to lowercase
                var lower_parts = []
                for part in parts:
                    lower_parts.append(part.to_lower())
                return PoolStringArray(lower_parts).join("_")
            
            NAMING_CONVENTIONS.camelCase:
                # First part lowercase, rest capitalized
                var result = ""
                for i in range(parts.size()):
                    var part = parts[i]
                    if i == 0:
                        result += part.to_lower()
                    else:
                        result += part.substr(0, 1).to_upper() + part.substr(1).to_lower()
                return result
            
            NAMING_CONVENTIONS.PascalCase:
                # All parts capitalized
                var result = ""
                for part in parts:
                    result += part.substr(0, 1).to_upper() + part.substr(1).to_lower()
                return result
            
            NAMING_CONVENTIONS.kebab-case:
                # All parts lowercase with dash separator
                var lower_parts = []
                for part in parts:
                    lower_parts.append(part.to_lower())
                return PoolStringArray(lower_parts).join("-")
            
            NAMING_CONVENTIONS.SCREAMING_SNAKE:
                # All parts uppercase
                var upper_parts = []
                for part in parts:
                    upper_parts.append(part.to_upper())
                return PoolStringArray(upper_parts).join("_")
            
            NAMING_CONVENTIONS.small_BIG:
                # Alternate small and BIG cases
                var result = []
                for i in range(parts.size()):
                    if i % 2 == 0:
                        # small
                        result.append(parts[i].to_lower())
                    else:
                        # BIG
                        result.append(parts[i].to_upper())
                return PoolStringArray(result).join("_")
            
            NAMING_CONVENTIONS.Mixed_Case:
                # Capitalize each part but keep underscore
                var result = []
                for part in parts:
                    result.append(part.substr(0, 1).to_upper() + part.substr(1).to_lower())
                return PoolStringArray(result).join("_")
            
            _:
                # Default: snake_case
                var lower_parts = []
                for part in parts:
                    lower_parts.append(part.to_lower())
                return PoolStringArray(lower_parts).join("_")
    
    # Example of a specific conversion rule
    func _convert_0_to_1(name: String) -> String:
        # snake_case to camelCase
        var parts = name.split("_")
        var result = parts[0].to_lower()
        
        for i in range(1, parts.size()):
            result += parts[i].substr(0, 1).to_upper() + parts[i].substr(1).to_lower()
        
        return result

# Manager classes
var _components = {}  # id -> EngineComponent
var _integrations = {}  # id -> EngineIntegration
var _animation_queue = []

# Signals
signal engine_initialized()
signal component_activated(component_id)
signal integration_established(integration_id)
signal animation_started(animation_id)
signal naming_convention_changed(old_convention, new_convention)

# System Initialization
func _ready():
    # Initialize animation controller
    _animation_controller = AnimationController.new(_current_animation_style)
    
    # Initialize naming converter
    _naming_converter = NamingConverter.new(_current_naming_convention)
    
    # Load components
    load_components()
    
    # Load integrations
    load_integrations()

func _process(delta):
    if _engine_initialized and _animation_controller and _animation_controller.is_active:
        _animation_controller.render_animations(delta)

func initialize(
    main_system = null,
    memory_system = null,
    yoyo_catcher = null,
    connection_system = null
):
    _main_system = main_system
    _memory_system = memory_system
    _yoyo_catcher = yoyo_catcher
    _connection_system = connection_system
    
    # Register core components
    register_core_components()
    
    # Create core integrations
    create_core_integrations()
    
    _engine_initialized = true
    
    emit_signal("engine_initialized")
    
    return true

# Component Management
func register_component(name: String, type: String, naming_convention: int = -1) -> String:
    if naming_convention < 0:
        naming_convention = _current_naming_convention
    
    var component_id = "comp_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    
    var component = EngineComponent.new(component_id, name, type)
    component.naming_convention = naming_convention
    
    _components[component_id] = component
    
    # Save components
    save_components()
    
    return component_id

func activate_component(component_id: String) -> bool:
    if not _components.has(component_id):
        return false
    
    _components[component_id].activate()
    
    emit_signal("component_activated", component_id)
    
    return true

func get_component(component_id: String) -> EngineComponent:
    if _components.has(component_id):
        return _components[component_id]
    
    return null

func register_core_components():
    # Register standard engine components
    var memory_component_id = register_component("memory_system", "core", NAMING_CONVENTIONS.snake_case)
    var yoyo_component_id = register_component("yoyo_catcher", "core", NAMING_CONVENTIONS.snake_case)
    var animation_component_id = register_component("animation_controller", "visual", NAMING_CONVENTIONS.snake_case)
    var integration_component_id = register_component("integration_manager", "system", NAMING_CONVENTIONS.snake_case)
    var naming_component_id = register_component("naming_converter", "utility", NAMING_CONVENTIONS.snake_case)
    
    # Activate core components
    activate_component(memory_component_id)
    activate_component(yoyo_component_id)
    activate_component(animation_component_id)
    activate_component(integration_component_id)
    activate_component(naming_component_id)
    
    # Register special case components
    var small_BIG_component_id = register_component("small_BIG_handler", "special", NAMING_CONVENTIONS.small_BIG)
    var ethereal_component_id = register_component("Ethereal_Engine", "engine", NAMING_CONVENTIONS.Mixed_Case)
    
    activate_component(small_BIG_component_id)
    activate_component(ethereal_component_id)

# Integration Management
func create_integration(source_component_id: String, target_component_id: String) -> String:
    if not _components.has(source_component_id) or not _components.has(target_component_id):
        return ""
    
    var integration_id = "integ_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    
    var integration = EngineIntegration.new(
        integration_id,
        source_component_id,
        target_component_id
    )
    
    _integrations[integration_id] = integration
    
    # Initialize naming mappings based on component conventions
    var source_component = _components[source_component_id]
    var target_component = _components[target_component_id]
    
    if source_component.naming_convention != target_component.naming_convention:
        # Add automatic name mappings for component interfaces
        for interface in source_component.interfaces:
            var converted_name = _naming_converter.convert_name(
                interface,
                source_component.naming_convention,
                target_component.naming_convention
            )
            
            integration.add_name_mapping(interface, converted_name)
    
    # Save integrations
    save_integrations()
    
    emit_signal("integration_established", integration_id)
    
    return integration_id

func add_name_mapping(integration_id: String, source_name: String, target_name: String) -> bool:
    if not _integrations.has(integration_id):
        return false
    
    _integrations[integration_id].add_name_mapping(source_name, target_name)
    
    # Save integrations
    save_integrations()
    
    return true

func enable_bidirectional_integration(integration_id: String) -> bool:
    if not _integrations.has(integration_id):
        return false
    
    _integrations[integration_id].is_bidirectional = true
    
    # Save integrations
    save_integrations()
    
    return true

func get_integration(integration_id: String) -> EngineIntegration:
    if _integrations.has(integration_id):
        return _integrations[integration_id]
    
    return null

func create_core_integrations():
    # Find component IDs by name pattern
    var memory_id = ""
    var yoyo_id = ""
    var animation_id = ""
    var integration_id = ""
    var naming_id = ""
    var small_big_id = ""
    var ethereal_id = ""
    
    for comp_id in _components:
        var component = _components[comp_id]
        
        if component.name == "memory_system":
            memory_id = comp_id
        elif component.name == "yoyo_catcher":
            yoyo_id = comp_id
        elif component.name == "animation_controller":
            animation_id = comp_id
        elif component.name == "integration_manager":
            integration_id = comp_id
        elif component.name == "naming_converter":
            naming_id = comp_id
        elif component.name == "small_BIG_handler":
            small_big_id = comp_id
        elif component.name == "Ethereal_Engine":
            ethereal_id = comp_id
    
    # Create integrations between components
    if not memory_id.empty() and not yoyo_id.empty():
        create_integration(memory_id, yoyo_id)
    
    if not memory_id.empty() and not animation_id.empty():
        create_integration(memory_id, animation_id)
    
    if not small_big_id.empty() and not naming_id.empty():
        create_integration(small_big_id, naming_id)
    
    if not ethereal_id.empty() and not integration_id.empty():
        create_integration(ethereal_id, integration_id)

# Animation Management
func set_animation_style(style: int) -> bool:
    if not _animation_controller:
        return false
    
    return _animation_controller.set_style(style)

func set_animation_speed(speed: float) -> bool:
    if not _animation_controller:
        return false
    
    return _animation_controller.set_speed(speed)

func start_animations():
    if not _animation_controller:
        return
    
    _animation_controller.start()

func stop_animations():
    if not _animation_controller:
        return
    
    _animation_controller.stop()

func create_animation(element_id: String, properties: Dictionary) -> String:
    if not _animation_controller:
        return ""
    
    var animation_id = _animation_controller.create_animation(element_id, properties)
    
    emit_signal("animation_started", animation_id)
    
    return animation_id

func set_animation_canvas(canvas):
    if _animation_controller:
        _animation_controller.target_canvas = canvas

# Naming Convention Management
func set_naming_convention(convention: int) -> bool:
    if convention < 0 or convention >= NAMING_CONVENTIONS.size():
        return false
    
    var old_convention = _current_naming_convention
    _current_naming_convention = convention
    
    emit_signal("naming_convention_changed", old_convention, convention)
    
    return true

func convert_name(name: String, source_convention: int, target_convention: int) -> String:
    if not _naming_converter:
        return name
    
    return _naming_converter.convert_name(name, source_convention, target_convention)

func convert_to_snake_case(name: String, source_convention: int = -1) -> String:
    if source_convention < 0:
        source_convention = _current_naming_convention
    
    return convert_name(name, source_convention, NAMING_CONVENTIONS.snake_case)

func convert_to_small_BIG(name: String, source_convention: int = -1) -> String:
    if source_convention < 0:
        source_convention = _current_naming_convention
    
    return convert_name(name, source_convention, NAMING_CONVENTIONS.small_BIG)

# Engine Mode Management
func set_engine_mode(mode: int) -> bool:
    if mode < 0 or mode >= ENGINE_MODES.size():
        return false
    
    _current_engine_mode = mode
    
    return true

func get_engine_mode_name(mode: int = -1) -> String:
    if mode < 0:
        mode = _current_engine_mode
    
    for key in ENGINE_MODES:
        if ENGINE_MODES[key] == mode:
            return key
    
    return "unknown_mode"

# File Operations
func save_components() -> bool:
    var dir = Directory.new()
    var save_dir = "user://ethereal_engine"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(save_dir):
        dir.make_dir_recursive(save_dir)
    
    # Save as JSON
    var file = File.new()
    var file_path = save_dir.plus_file("components.json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open components file for writing: " + str(err))
        return false
    
    var components_data = {}
    for comp_id in _components:
        components_data[comp_id] = _components[comp_id].to_dict()
    
    file.store_string(JSON.print(components_data, "  "))
    file.close()
    
    return true

func load_components() -> bool:
    var file = File.new()
    var file_path = "user://ethereal_engine/components.json"
    
    if not file.file_exists(file_path):
        return false
    
    var err = file.open(file_path, File.READ)
    if err != OK:
        push_error("Failed to open components file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse components JSON: " + str(parse_result.error))
        return false
    
    var components_data = parse_result.result
    _components = {}
    
    for comp_id in components_data:
        var component = EngineComponent.from_dict(components_data[comp_id])
        _components[comp_id] = component
    
    return true

func save_integrations() -> bool:
    var dir = Directory.new()
    var save_dir = "user://ethereal_engine"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(save_dir):
        dir.make_dir_recursive(save_dir)
    
    # Save as JSON
    var file = File.new()
    var file_path = save_dir.plus_file("integrations.json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open integrations file for writing: " + str(err))
        return false
    
    var integrations_data = {}
    for integ_id in _integrations:
        integrations_data[integ_id] = _integrations[integ_id].to_dict()
    
    file.store_string(JSON.print(integrations_data, "  "))
    file.close()
    
    return true

func load_integrations() -> bool:
    var file = File.new()
    var file_path = "user://ethereal_engine/integrations.json"
    
    if not file.file_exists(file_path):
        return false
    
    var err = file.open(file_path, File.READ)
    if err != OK:
        push_error("Failed to open integrations file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse integrations JSON: " + str(parse_result.error))
        return false
    
    var integrations_data = parse_result.result
    _integrations = {}
    
    for integ_id in integrations_data:
        var integration = EngineIntegration.from_dict(integrations_data[integ_id])
        _integrations[integ_id] = integration
    
    return true

# Utility Functions
func generate_engine_report() -> String:
    var report = "# ETHEREAL_ENGINE REPORT #\n\n"
    
    # Engine status
    report += "## Engine Status\n"
    report += "Initialized: " + str(_engine_initialized) + "\n"
    report += "Mode: " + get_engine_mode_name() + "\n"
    report += "Naming Convention: " + get_naming_convention_name() + "\n"
    report += "Animation Style: " + get_animation_style_name() + "\n"
    report += "Integration Level: " + str(_integration_level) + "/10\n\n"
    
    # Components
    report += "## Components\n"
    for comp_id in _components:
        var component = _components[comp_id]
        var status = component.is_active ? "ACTIVE" : "INACTIVE"
        
        report += "- " + component.name + " (" + component.type + ") [" + status + "]\n"
        report += "  Convention: " + get_naming_convention_name(component.naming_convention) + "\n"
        
        if component.interfaces.size() > 0:
            report += "  Interfaces: " + PoolStringArray(component.interfaces).join(", ") + "\n"
    
    report += "\n"
    
    # Integrations
    report += "## Integrations\n"
    for integ_id in _integrations:
        var integration = _integrations[integ_id]
        var bidirectional = integration.is_bidirectional ? "↔" : "→"
        
        var source_name = "Unknown"
        var target_name = "Unknown"
        
        if _components.has(integration.source_component):
            source_name = _components[integration.source_component].name
        
        if _components.has(integration.target_component):
            target_name = _components[integration.target_component].name
        
        report += "- " + source_name + " " + bidirectional + " " + target_name + "\n"
        report += "  Level: " + str(integration.integration_level) + "/10\n"
        
        if integration.naming_map.size() > 0:
            report += "  Mappings: " + str(integration.naming_map.size()) + "\n"
    
    report += "\n"
    
    # Animations
    if _animation_controller:
        report += "## Animations\n"
        report += "Style: " + get_animation_style_name() + "\n"
        report += "Speed: " + str(_animation_controller.animation_speed) + "x\n"
        report += "Active: " + str(_animation_controller.is_active) + "\n"
        
        var active_count = 0
        for anim_id in _animation_controller.active_animations:
            if _animation_controller.active_animations[anim_id].is_active:
                active_count += 1
        
        report += "Running Animations: " + str(active_count) + "\n"
    
    return report

func get_naming_convention_name(convention: int = -1) -> String:
    if convention < 0:
        convention = _current_naming_convention
    
    for key in NAMING_CONVENTIONS:
        if NAMING_CONVENTIONS[key] == convention:
            return key
    
    return "unknown_convention"

func get_animation_style_name(style: int = -1) -> String:
    if style < 0:
        style = _current_animation_style
    
    for key in ANIMATION_STYLES:
        if ANIMATION_STYLES[key] == style:
            return key
    
    return "unknown_style"

# Integration with main.gd
func connect_to_main(main_system_reference) -> bool:
    _main_system = main_system_reference
    
    if not _main_system:
        return false
    
    # Register main system component
    var main_component_id = register_component("main_system", "core", NAMING_CONVENTIONS.snake_case)
    
    # Add interfaces based on main system methods
    var main_component = _components[main_component_id]
    
    # Add known interfaces
    if _main_system.has_method("add_word"):
        main_component.add_interface("add_word")
    
    if _main_system.has_method("update_word_list"):
        main_component.add_interface("update_word_list")
    
    if _main_system.has_method("update_memory_display"):
        main_component.add_interface("update_memory_display")
    
    activate_component(main_component_id)
    
    # Create integration with engine
    for comp_id in _components:
        if _components[comp_id].name == "Ethereal_Engine":
            create_integration(comp_id, main_component_id)
            break
    
    return true

# Portal Animation creation
func create_portal_animation(position: Vector2, size: Vector2, target_node = null) -> String:
    if not _animation_controller:
        return ""
    
    # Save current style
    var old_style = _animation_controller.current_style
    
    # Set portal style
    _animation_controller.set_style(ANIMATION_STYLES.portal)
    
    var properties = {
        "position": position,
        "size": size,
        "color": Color(0.3, 0.5, 0.9, 0.8),
        "pulse_rate": 1.5,
        "depth": 4.0,
        "target_node": target_node
    }
    
    var animation_id = _animation_controller.create_animation("portal", properties)
    
    # Restore previous style
    _animation_controller.set_style(old_style)
    
    start_animations()
    
    return animation_id

# Glitch Effect animation
func create_glitch_effect(position: Vector2, size: Vector2, target_node = null) -> String:
    if not _animation_controller:
        return ""
    
    # Save current style
    var old_style = _animation_controller.current_style
    
    # Set glitch style
    _animation_controller.set_style(ANIMATION_STYLES.glitch)
    
    var properties = {
        "position": position,
        "size": size,
        "intensity": 0.7,
        "frequency": 0.8,
        "color_shift": true,
        "displacement": 5.0,
        "target_node": target_node
    }
    
    var animation_id = _animation_controller.create_animation("glitch", properties)
    
    # Restore previous style
    _animation_controller.set_style(old_style)
    
    start_animations()
    
    return animation_id

# Flow Animation
func create_flow_animation(start_position: Vector2, end_position: Vector2, path_type: String = "curve") -> String:
    if not _animation_controller:
        return ""
    
    # Save current style
    var old_style = _animation_controller.current_style
    
    # Set flow style
    _animation_controller.set_style(ANIMATION_STYLES.flow)
    
    var properties = {
        "start_position": start_position,
        "end_position": end_position,
        "path_type": path_type,
        "color": Color(0.2, 0.6, 0.9, 0.7),
        "width": 3.0,
        "particle_count": 20,
        "duration": 3.0
    }
    
    var animation_id = _animation_controller.create_animation("flow", properties)
    
    # Restore previous style
    _animation_controller.set_style(old_style)
    
    start_animations()
    
    return animation_id

# Dimension Shift animation
func create_dimension_shift(position: Vector2, size: Vector2, from_dimension: int, to_dimension: int) -> String:
    if not _animation_controller:
        return ""
    
    # Save current style
    var old_style = _animation_controller.current_style
    
    # Set dimension shift style
    _animation_controller.set_style(ANIMATION_STYLES.dimension_shift)
    
    var properties = {
        "position": position,
        "size": size,
        "from_dimension": from_dimension,
        "to_dimension": to_dimension,
        "transition_time": 2.0,
        "warp_factor": 1.5,
        "color_shift": true
    }
    
    var animation_id = _animation_controller.create_animation("dimension_shift", properties)
    
    # Restore previous style
    _animation_controller.set_style(old_style)
    
    start_animations()
    
    return animation_id

# Gradient animation for toolbar
func create_toolbar_gradient(rect: Rect2, colors: Array, speed: float = 1.0) -> String:
    if not _animation_controller:
        return ""
    
    # Save current style
    var old_style = _animation_controller.current_style
    
    # Set gradient morph style
    _animation_controller.set_style(ANIMATION_STYLES.gradient_morph)
    
    var properties = {
        "rect": rect,
        "colors": colors,
        "speed": speed,
        "direction": "horizontal",
        "oscillate": true,
        "alpha": 0.9
    }
    
    var animation_id = _animation_controller.create_animation("toolbar_gradient", properties)
    
    # Restore previous style
    _animation_controller.set_style(old_style)
    
    start_animations()
    
    return animation_id

# Example usage:
# var engine = Ethereal_Engine_Connector.new()
# add_child(engine)
# engine.initialize(main_system, memory_system, yoyo_catcher, connection_system)
# 
# # Set naming convention
# engine.set_naming_convention(Ethereal_Engine_Connector.NAMING_CONVENTIONS.snake_case)
# 
# # Create animations
# var canvas = $Canvas
# engine.set_animation_canvas(canvas)
# var portal_id = engine.create_portal_animation(Vector2(100, 100), Vector2(200, 200))
# 
# # Convert between naming conventions
# var snake_name = "word_memory_system"
# var small_BIG_name = engine.convert_to_small_BIG(snake_name)
# print(small_BIG_name)  # "word_MEMORY_system"