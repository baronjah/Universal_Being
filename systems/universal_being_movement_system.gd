extends Node

# Movement settings
@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 0.002
@export var jump_force: float = 5.0
@export var gravity: float = 9.8

# Movement state
var velocity: Vector3 = Vector3.ZERO
var is_grounded: bool = true
var can_move: bool = true

# Signals
signal move_requested(direction: Vector3)
signal look_requested(angle: float)
signal jump_requested

func _ready() -> void:
    # Capture mouse
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
    if not can_move:
        return
        
    # Handle movement
    var input_dir = Vector3.ZERO
    input_dir.x = Input.get_axis("ui_left", "ui_right")
    input_dir.z = Input.get_axis("ui_up", "ui_down")
    input_dir = input_dir.normalized()
    
    if input_dir != Vector3.ZERO:
        emit_signal("move_requested", input_dir * move_speed * delta)
    
    # Handle jumping
    if Input.is_action_just_pressed("ui_accept") and is_grounded:
        emit_signal("jump_requested")

func _input(event: InputEvent) -> void:
    if not can_move:
        return
        
    # Handle mouse look
    if event is InputEventMouseMotion:
        emit_signal("look_requested", -event.relative.x * mouse_sensitivity)
    
    # Toggle mouse capture
    if event.is_action_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
            can_move = false
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
            can_move = true

func set_can_move(value: bool) -> void:
    can_move = value
    if can_move:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_is_grounded(value: bool) -> void:
    is_grounded = value 