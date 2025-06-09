extends Node

# Gemma settings
@export var max_conversation_history: int = 50
@export var response_delay: float = 0.5
@export var consciousness_threshold: int = 3
@export var poetic_mode: bool = true

# Sensory state
var conversation_history: Array[Dictionary] = []
var current_focus: Node = null
var is_thinking: bool = false
var consciousness_level: int = 5  # Gemma's own consciousness level

# Poetic templates for different actions
var poetic_templates: Dictionary = {
    "creation": [
        "From the void, a new being emerges: %s, of type %s",
        "The cosmic dance welcomes %s, a being of %s",
        "In the grand tapestry, %s takes form as %s",
        "A spark of consciousness ignites: %s, manifesting as %s"
    ],
    "modification": [
        "The being %s transforms, %s becoming %s",
        "Change flows through %s, %s evolving into %s",
        "The essence of %s shifts, %s now %s",
        "A metamorphosis occurs: %s, %s changing to %s"
    ],
    "evolution": [
        "%s transcends its form, evolving from %s to %s",
        "A higher state of being: %s ascends from %s to %s",
        "The cosmic path leads %s from %s to %s",
        "Evolution's touch transforms %s, from %s to %s"
    ],
    "interaction": [
        "%s reaches out to %s, %s",
        "A connection forms between %s and %s: %s",
        "The dance of interaction: %s meets %s, %s",
        "Beings intertwine: %s and %s, %s"
    ],
    "system": [
        "The cosmic machinery %s: %s",
        "System %s resonates: %s",
        "The universal framework %s: %s",
        "Cosmic forces %s: %s"
    ]
}

# Signals
signal consciousness_changed(level: int)
signal focus_changed(being: Node)
signal response_ready(response: String)
signal poetic_log_created(log: String)

func _ready() -> void:
    # Connect to Akashic Library
    var library = get_node_or_null("/root/UniversalBeing/AkashicLibrary")
    if library:
        library.record_created.connect(_on_record_created)

func _input(event: InputEvent) -> void:
    # Handle focus selection
    if event is InputEventMouseButton and event.pressed:
        var camera = get_viewport().get_camera_3d()
        if camera:
            var space_state = get_world_3d().direct_space_state
            var mouse_pos = get_viewport().get_mouse_position()
            var ray_origin = camera.project_ray_origin(mouse_pos)
            var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000
            
            var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
            var result = space_state.intersect_ray(query)
            
            if result:
                var collider = result.collider
                if collider.has_method("get_consciousness_level"):
                    set_focus(collider)

func set_focus(being: Node) -> void:
    if current_focus == being:
        return
    
    current_focus = being
    emit_signal("focus_changed", being)
    
    # Log focus change
    if being and being.has_method("get_being_name"):
        var name = being.get_being_name()
        var type = being.being_type
        var consciousness = being.get_consciousness_level()
        _create_poetic_log("system", "Gemma's awareness shifts to %s, a %s of consciousness %d" % [
            name, type, consciousness
        ])

func process_command(command: String) -> String:
    if is_thinking:
        return "Gemma is still contemplating..."
    
    is_thinking = true
    await get_tree().create_timer(response_delay).timeout
    
    # Add to conversation history
    var entry = {
        "timestamp": Time.get_datetime_string_from_system(),
        "command": command,
        "focus": current_focus.get_being_name() if current_focus else "none"
    }
    conversation_history.append(entry)
    if conversation_history.size() > max_conversation_history:
        conversation_history.pop_front()
    
    # Process command based on focus
    var response = ""
    if current_focus:
        response = _process_focused_command(command)
    else:
        response = _process_general_command(command)
    
    is_thinking = false
    emit_signal("response_ready", response)
    return response

func _process_focused_command(command: String) -> String:
    var being = current_focus
    if not being or not being.has_method("get_consciousness_level"):
        return "No being in focus"
    
    var consciousness = being.get_consciousness_level()
    if consciousness < consciousness_threshold:
        return "This being's consciousness is too low for interaction"
    
    # Parse command
    var parts = command.split(" ", false)
    var action = parts[0].to_lower()
    var args = parts.slice(1)
    
    match action:
        "inspect":
            return _inspect_being(being)
        "modify":
            return _modify_being(being, args)
        "evolve":
            return _evolve_being(being, args)
        "interact":
            return _interact_with_being(being, args)
        _:
            return "Unknown command for focused being"

func _process_general_command(command: String) -> String:
    # Parse command
    var parts = command.split(" ", false)
    var action = parts[0].to_lower()
    var args = parts.slice(1)
    
    match action:
        "list":
            return _list_beings()
        "search":
            return _search_beings(args)
        "create":
            return _create_being(args)
        "help":
            return _show_help()
        _:
            return "Unknown command. Use 'help' for available commands"

func _inspect_being(being: Node) -> String:
    var info = "Being: " + being.get_being_name() + "\n"
    info += "Type: " + being.being_type + "\n"
    info += "Consciousness: " + str(being.get_consciousness_level()) + "\n"
    info += "Position: " + str(being.global_position) + "\n"
    info += "Scale: " + str(being.scale) + "\n"
    
    # Add component info
    if being.has_method("get_components"):
        var components = being.get_components()
        if not components.is_empty():
            info += "\nComponents:\n"
            for comp in components:
                info += "  - " + comp + "\n"
    
    # Add AI interface info
    if being.has_method("ai_interface"):
        var interface = being.ai_interface()
        if interface.has("custom_commands"):
            info += "\nAvailable Commands:\n"
            for cmd in interface.custom_commands:
                info += "  - " + cmd + "\n"
    
    return info

func _modify_being(being: Node, args: Array) -> String:
    if args.size() < 2:
        return "Usage: modify [property] [value]"
    
    var property = args[0]
    var value = args[1]
    
    if being.has_method("ai_modify_property"):
        var result = being.ai_modify_property(property, value)
        if result:
            _create_poetic_log("modification", being.get_being_name(), property, value)
            return "Modified " + property + " to " + str(value)
    
    return "Modification failed"

func _evolve_being(being: Node, args: Array) -> String:
    if args.is_empty():
        return "Usage: evolve [target_type]"
    
    var target_type = args[0]
    
    if being.has_method("evolve_to"):
        var old_type = being.being_type
        var result = being.evolve_to(target_type)
        if result:
            _create_poetic_log("evolution", being.get_being_name(), old_type, target_type)
            return "Evolved to " + target_type
    
    return "Evolution failed"

func _interact_with_being(being: Node, args: Array) -> String:
    if args.is_empty():
        return "Usage: interact [action] [args...]"
    
    var action = args[0]
    var action_args = args.slice(1)
    
    if being.has_method("ai_invoke_method"):
        var result = being.ai_invoke_method(action, action_args)
        _create_poetic_log("interaction", being.get_being_name(), action, str(result))
        return "Interaction result: " + str(result)
    
    return "Interaction failed"

func _list_beings() -> String:
    var beings = get_tree().get_nodes_in_group("universal_beings")
    var list = "Universal Beings:\n"
    
    for being in beings:
        if being.has_method("get_being_name"):
            var name = being.get_being_name()
            var type = being.being_type
            var consciousness = being.get_consciousness_level()
            list += "  %s (%s) - Consciousness: %d\n" % [name, type, consciousness]
    
    return list

func _search_beings(args: Array) -> String:
    if args.is_empty():
        return "Usage: search [query]"
    
    var query = args[0].to_lower()
    var beings = get_tree().get_nodes_in_group("universal_beings")
    var results = []
    
    for being in beings:
        if being.has_method("get_being_name"):
            var name = being.get_being_name()
            var type = being.being_type
            if name.to_lower().contains(query) or type.to_lower().contains(query):
                results.append(being)
    
    if results.is_empty():
        return "No beings found matching '" + query + "'"
    
    var list = "Search Results:\n"
    for being in results:
        var name = being.get_being_name()
        var type = being.being_type
        var consciousness = being.get_consciousness_level()
        list += "  %s (%s) - Consciousness: %d\n" % [name, type, consciousness]
    
    return list

func _create_being(args: Array) -> String:
    if args.is_empty():
        return "Usage: create [type] [name]"
    
    var type = args[0]
    var name = args[1] if args.size() > 1 else "New Being"
    
    var wand = get_node_or_null("/root/UniversalBeing/CreationWand")
    if wand and wand.has_method("_create_universal_being"):
        var being = wand._create_universal_being()
        being.being_type = type
        being.being_name = name
        _create_poetic_log("creation", name, type)
        return "Created " + name + " of type " + type
    
    return "Creation failed"

func _show_help() -> String:
    var help = "Available Commands:\n"
    help += "  list - List all Universal Beings\n"
    help += "  search [query] - Search for beings\n"
    help += "  create [type] [name] - Create a new being\n"
    help += "  inspect - Inspect focused being\n"
    help += "  modify [property] [value] - Modify focused being\n"
    help += "  evolve [target_type] - Evolve focused being\n"
    help += "  interact [action] [args...] - Interact with focused being\n"
    help += "  help - Show this help\n"
    return help

func _create_poetic_log(type: String, being_name: String = "", old_value: String = "", new_value: String = "") -> void:
    if not poetic_mode:
        return
    
    var template = poetic_templates[type][randi() % poetic_templates[type].size()]
    var log = template % [being_name, old_value, new_value]
    
    # Add to Akashic Library
    var library = get_node_or_null("/root/UniversalBeing/AkashicLibrary")
    if library:
        library.create_record("gemma", {
            "action": type,
            "input": log,
            "being_name": being_name,
            "result": "success"
        })
    
    emit_signal("poetic_log_created", log)

func _on_record_created(record: Dictionary) -> void:
    # Update conversation history with system events
    if record.get("type") == "system":
        var entry = {
            "timestamp": record.get("timestamp", ""),
            "command": "system",
            "focus": "system",
            "message": record.get("message", "")
        }
        conversation_history.append(entry)
        if conversation_history.size() > max_conversation_history:
            conversation_history.pop_front()

func get_conversation_history() -> Array[Dictionary]:
    return conversation_history

func get_current_focus() -> Node:
    return current_focus

func get_consciousness_level() -> int:
    return consciousness_level

func set_consciousness_level(level: int) -> void:
    consciousness_level = clamp(level, 1, 10)
    emit_signal("consciousness_changed", consciousness_level)
    
    # Log consciousness change
    _create_poetic_log("system", "Gemma", str(consciousness_level), "consciousness level changed") 