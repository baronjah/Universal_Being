extends Node3D
class_name PlayButton

# Signal for when play mode is activated
signal play_mode_activated(settings)

# Visual properties
var button_size = Vector2(15, 6)  # Much smaller size (1/10th of original)
var button_color = Color(0.2, 0.6, 0.8, 1.0)
var hover_color = Color(0.3, 0.7, 0.9, 1.0)
var text_color = Color(1.0, 1.0, 1.0, 1.0)
var corner_radius = 1
var font_size = 12

# Button state
var is_hovered = false
var is_pressed = false
var is_enabled = true

# Components
var button_mesh
var button_area
var label_3d
var collision_shape
var animation_player

# Settings for world creation
var world_settings = {
    "element_density": 100,
    "world_size": Vector3(100, 100, 100),
    "initial_elements": {
        "fire": 10,
        "water": 20,
        "wood": 15,
        "ash": 5
    },
    "physics_intensity": 1.0,
    "word_connection_threshold": 0.7
}

func _ready():
    # Create button mesh
    create_button_mesh()
    
    # Create interaction area
    create_interaction_area()
    
    # Create text label
    create_label()
    
    # Setup animations
    create_animations()
    
    # Connect signals
    button_area.input_event.connect(_on_input_event)
    button_area.mouse_entered.connect(_on_mouse_entered)
    button_area.mouse_exited.connect(_on_mouse_exited)

func create_button_mesh():
    # Create button mesh
    button_mesh = CSGBox3D.new()
    button_mesh.size = Vector3(button_size.x, button_size.y, 5)
    button_mesh.material = StandardMaterial3D.new()
    button_mesh.material.albedo_color = button_color
    add_child(button_mesh)
    
    # Round the corners by using CSGPolygon for rounding
    var corner_amount = corner_radius
    add_rounded_corners(button_mesh, corner_amount)

func add_rounded_corners(box, radius):
    # This is simplified - for actual corner rounding in 3D, you'd use CSG operations
    # Add slight scale to visually suggest rounded corners
    box.size = Vector3(box.size.x - radius*0.2, box.size.y - radius*0.2, box.size.z)

func create_interaction_area():
    # Create area for interaction
    button_area = Area3D.new()
    add_child(button_area)
    
    # Add collision shape
    collision_shape = CollisionShape3D.new()
    var box_shape = BoxShape3D.new()
    box_shape.size = Vector3(button_size.x, button_size.y, 2)  # Thinner depth but still thick enough for interaction
    collision_shape.shape = box_shape
    button_area.add_child(collision_shape)

func create_label():
    # Create 3D text
    label_3d = Label3D.new()
    label_3d.text = "PLAY"
    label_3d.font_size = font_size
    label_3d.modulate = text_color
    label_3d.position = Vector3(0, 0, 0.6)  # Position slightly in front of button (reduced z)
    # Scale text to match button
    label_3d.scale = Vector3(0.1, 0.1, 0.1)
    add_child(label_3d)

func create_animations():
    # Create animation player
    animation_player = AnimationPlayer.new()
    add_child(animation_player)
    
    # Create animation library for our animations
    var anim_library = AnimationLibrary.new()
    
    # Create hover animation
    var hover_animation = Animation.new()
    var track_index = hover_animation.add_track(Animation.TYPE_VALUE)
    hover_animation.track_set_path(track_index, "button_mesh:material:albedo_color")
    hover_animation.track_insert_key(track_index, 0.0, button_color)
    hover_animation.track_insert_key(track_index, 0.2, hover_color)
    anim_library.add_animation("hover", hover_animation)
    
    # Create click animation
    var click_animation = Animation.new()
    track_index = click_animation.add_track(Animation.TYPE_VALUE)
    click_animation.track_set_path(track_index, ".:scale")
    click_animation.track_insert_key(track_index, 0.0, Vector3(1, 1, 1))
    click_animation.track_insert_key(track_index, 0.1, Vector3(0.9, 0.9, 0.9))
    click_animation.track_insert_key(track_index, 0.2, Vector3(1, 1, 1))
    anim_library.add_animation("click", click_animation)
    
    # Create activated animation
    var activate_animation = Animation.new()
    track_index = activate_animation.add_track(Animation.TYPE_VALUE)
    activate_animation.track_set_path(track_index, ".:rotation_degrees")
    activate_animation.track_insert_key(track_index, 0.0, Vector3(0, 0, 0))
    activate_animation.track_insert_key(track_index, 0.3, Vector3(0, 360, 0))
    anim_library.add_animation("activate", activate_animation)
    
    # Add the library to the animation player
    animation_player.add_animation_library("", anim_library)

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
    if not is_enabled:
        return
        
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                is_pressed = true
                animation_player.play("click")
            else:
                if is_pressed and is_hovered:
                    activate()
                is_pressed = false

func _on_mouse_entered():
    if not is_enabled:
        return
        
    is_hovered = true
    animation_player.play("hover")

func _on_mouse_exited():
    if not is_enabled:
        return
        
    is_hovered = false
    button_mesh.material.albedo_color = button_color

func activate():
    # Disable further interaction
    is_enabled = false
    
    # Play activation animation
    animation_player.play("activate")
    
    # Wait for animation to complete
    await animation_player.animation_finished
    
    # Emit signal to start play mode
    emit_signal("play_mode_activated", world_settings)
    
    # Optional: Hide button after activation
    # visible = false

func set_settings(settings):
    # Update settings from external source
    world_settings = settings