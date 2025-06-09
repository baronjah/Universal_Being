extends Node

# Creation settings
@export var creation_range: float = 10.0
@export var creation_energy: float = 1.0
@export var modification_strength: float = 0.5

# Creation state
var is_creating: bool = false
var target_position: Vector3 = Vector3.ZERO
var current_being: Node = null

# Signals
signal creation_started
signal creation_ended
signal creation_triggered(position: Vector3)
signal being_modified(being: Node, modification: Dictionary)

func _ready() -> void:
    # Connect to parent UniversalBeing
    var parent = get_parent()
    if parent and parent.has_method("pentagon_ready"):
        parent.pentagon_ready.connect(_on_parent_ready)

func _process(_delta: float) -> void:
    if not is_creating:
        return
        
    # Update target position
    var camera = get_viewport().get_camera_3d()
    if camera:
        var space_state = get_tree().root.get_world_3d().direct_space_state
        var mouse_pos = get_viewport().get_mouse_position()
        var ray_origin = camera.project_ray_origin(mouse_pos)
        var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * creation_range
        
        var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
        var result = space_state.intersect_ray(query)
        
        if result:
            target_position = result.position
            if Input.is_action_just_pressed("ui_accept"):
                _trigger_creation()

func _input(event: InputEvent) -> void:
    # Start/end creation
    if event.is_action_pressed("ui_select"):  # Left click
        is_creating = true
        emit_signal("creation_started")
    elif event.is_action_released("ui_select"):
        is_creating = false
        emit_signal("creation_ended")
    
    # Modify current being
    if event.is_action_pressed("ui_focus_next"):  # F key
        _modify_current_being()

func _on_parent_ready() -> void:
    # Initialize wand with parent's consciousness
    var parent = get_parent()
    if parent and parent.has_method("get_consciousness_level"):
        creation_energy = parent.get_consciousness_level() * 0.2

func _trigger_creation() -> void:
    emit_signal("creation_triggered", target_position)
    
    # Create a new Universal Being
    var new_being = _create_universal_being()
    if new_being:
        get_tree().root.add_child(new_being)
        new_being.global_position = target_position
        current_being = new_being
        
        # Log creation in Akashic Records
        _log_creation(new_being)

func _create_universal_being() -> Node:
    # Create a basic Universal Being
    var being = Node3D.new()
    being.set_script(load("res://core/UniversalBeing.gd"))
    being.being_type = "created"
    being.being_name = "New Being"
    being.consciousness_level = 1
    
    # Add basic components
    var mesh = MeshInstance3D.new()
    var box_mesh = BoxMesh.new()
    box_mesh.size = Vector3(1, 1, 1)
    mesh.mesh = box_mesh
    being.add_child(mesh)
    
    var collision = CollisionShape3D.new()
    var box_shape = BoxShape3D.new()
    box_shape.size = Vector3(1, 1, 1)
    collision.shape = box_shape
    being.add_child(collision)
    
    return being

func _modify_current_being() -> void:
    if not current_being:
        return
        
    # Modify the current being
    var modification = {
        "scale": Vector3(1.1, 1.1, 1.1),
        "color": Color(randf(), randf(), randf(), 1.0),
        "consciousness": current_being.consciousness_level + 0.1
    }
    
    emit_signal("being_modified", current_being, modification)
    _apply_modification(current_being, modification)
    _log_modification(current_being, modification)

func _apply_modification(being: Node, modification: Dictionary) -> void:
    if not being:
        return
        
    # Apply scale
    if "scale" in modification:
        being.scale *= modification.scale
    
    # Apply color
    if "color" in modification:
        var mesh = being.get_node_or_null("MeshInstance3D")
        if mesh and mesh.mesh:
            var material = StandardMaterial3D.new()
            material.albedo_color = modification.color
            mesh.material_override = material
    
    # Apply consciousness
    if "consciousness" in modification and being.has_method("set_consciousness_level"):
        being.set_consciousness_level(modification.consciousness)

func _log_creation(being: Node) -> void:
    var logger = get_node_or_null("/root/UniversalBeing/AkashicLogger")
    if logger and logger.has_method("log_creation"):
        logger.log_creation(being)

func _log_modification(being: Node, modification: Dictionary) -> void:
    var logger = get_node_or_null("/root/UniversalBeing/AkashicLogger")
    if logger and logger.has_method("log_modification"):
        logger.log_modification(being, modification) 