extends Node3D

@export var move_speed := 10.0
@export var rotate_speed := 0.005
@export var zoom_speed := 2.0
@export var tilt_intensity := 0.1

var velocity := Vector3.ZERO
var rotation_input := Vector2.ZERO

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D

func _ready():
    _create_crosshair()

func _create_crosshair():
    var crosshair = ColorRect.new()
    crosshair.color = Color.WHITE
    crosshair.size = Vector2(4, 4)
    crosshair.position = get_viewport().get_visible_rect().size * 0.5 - crosshair.size * 0.5
    crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
    get_viewport().add_child(crosshair)

func _unhandled_input(event):
    if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        rotation_input -= event.relative * rotate_speed

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            camera.position.z = clamp(camera.position.z - zoom_speed, -50, -2)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            camera.position.z = clamp(camera.position.z + zoom_speed, -50, -2)

func _process(delta):
    var direction = Vector3.ZERO
    if Input.is_action_pressed("move_forward"):
        direction -= camera.global_transform.basis.z
    if Input.is_action_pressed("move_backward"):
        direction += camera.global_transform.basis.z
    if Input.is_action_pressed("move_left"):
        direction -= camera.global_transform.basis.x
    if Input.is_action_pressed("move_right"):
        direction += camera.global_transform.basis.x
    if Input.is_action_pressed("move_up"):
        direction += camera.global_transform.basis.y
    if Input.is_action_pressed("move_down"):
        direction -= camera.global_transform.basis.y

    velocity = direction.normalized() * move_speed
    global_translate(velocity * delta)

    rotation.y += rotation_input.x
    rotation.x = clamp(rotation.x + rotation_input.y, -PI / 2, PI / 2)
    rotation_input *= 0.8

    camera_pivot.rotation.z = -rotation_input.x * tilt_intensity
