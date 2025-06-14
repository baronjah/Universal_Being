extends Control

class_name PictureViewer

signal image_loaded(path, texture)
signal zoom_changed(level)
signal navigation_changed(index, total)

# Picture viewing properties
var current_image_path = ""
var current_texture = null
var image_list = []
var current_index = -1
var zoom_level = 1.0
var pan_offset = Vector2.ZERO
var is_panning = false
var last_mouse_pos = Vector2.ZERO

# UI Elements
@onready var texture_rect = $ImageContainer/TextureRect
@onready var zoom_label = $ControlPanel/ZoomLabel
@onready var navigation_label = $ControlPanel/NavigationLabel
@onready var animation_player = $AnimationPlayer

# Configuration
var supported_extensions = ["png", "jpg", "jpeg", "gif", "webp", "bmp"]
var max_zoom = 5.0
var min_zoom = 0.1
var zoom_step = 0.2

func _ready():
    # Initialize UI
    texture_rect.expand = true
    texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    
    # Connect to control signals
    $ControlPanel/PreviousButton.pressed.connect(_on_previous_pressed)
    $ControlPanel/NextButton.pressed.connect(_on_next_pressed)
    $ControlPanel/ZoomInButton.pressed.connect(_on_zoom_in_pressed)
    $ControlPanel/ZoomOutButton.pressed.connect(_on_zoom_out_pressed)
    $ControlPanel/ZoomResetButton.pressed.connect(_on_zoom_reset_pressed)

func _input(event):
    if current_texture == null:
        return
        
    # Mouse wheel zooming
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            set_zoom(zoom_level + zoom_step)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            set_zoom(zoom_level - zoom_step)
        elif event.button_index == MOUSE_BUTTON_MIDDLE:
            if event.pressed:
                is_panning = true
                last_mouse_pos = event.position
            else:
                is_panning = false
                
    # Pan with middle mouse button
    if event is InputEventMouseMotion and is_panning:
        var delta = event.position - last_mouse_pos
        pan_offset += delta / zoom_level
        last_mouse_pos = event.position
        _update_image_position()

# Load an image from the specified path
func load_image(path):
    if not FileAccess.file_exists(path):
        push_error("Image file not found: " + path)
        return false
        
    # Check file extension
    var ext = path.get_extension().to_lower()
    if not supported_extensions.has(ext):
        push_error("Unsupported image format: " + ext)
        return false
        
    # Load the image
    var image = Image.new()
    var err = image.load(path)
    
    if err != OK:
        push_error("Failed to load image: " + path)
        return false
        
    # Create texture
    var img_texture = ImageTexture.create_from_image(image)
    
    # Update display
    _set_image(path, img_texture)
    
    # Reset zoom and pan
    zoom_level = 1.0
    pan_offset = Vector2.ZERO
    _update_image_position()
    
    # Update image list if needed
    if image_list.size() == 0 or not image_list.has(path):
        _update_image_list_for_directory(path.get_base_dir())
    
    # Find index in image list
    current_index = image_list.find(path)
    _update_navigation_label()
    
    # Play animation
    animation_player.play("fade_in")
    
    emit_signal("image_loaded", path, img_texture)
    return true

# Load previous image in the list
func previous_image():
    if image_list.size() <= 1 or current_index <= 0:
        return false
        
    current_index -= 1
    load_image(image_list[current_index])
    animation_player.play("slide_right")
    return true

# Load next image in the list
func next_image():
    if image_list.size() <= 1 or current_index >= image_list.size() - 1:
        return false
        
    current_index += 1
    load_image(image_list[current_index])
    animation_player.play("slide_left")
    return true

# Set zoom level
func set_zoom(level):
    zoom_level = clamp(level, min_zoom, max_zoom)
    texture_rect.scale = Vector2(zoom_level, zoom_level)
    _update_image_position()
    _update_zoom_label()
    
    emit_signal("zoom_changed", zoom_level)
    return zoom_level

# Update list of images in the same directory
func _update_image_list_for_directory(directory):
    image_list.clear()
    
    var dir = DirAccess.open(directory)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if not dir.current_is_dir():
                var ext = file_name.get_extension().to_lower()
                if supported_extensions.has(ext):
                    image_list.append(directory.path_join(file_name))
            file_name = dir.get_next()
            
        dir.list_dir_end()
        
        # Sort alphabetically
        image_list.sort()

# Set the current image
func _set_image(path, texture):
    current_image_path = path
    current_texture = texture
    texture_rect.texture = texture
    
    # Update the window title with filename
    var file_name = path.get_file()
    $TitleLabel.text = file_name

# Update zoom label
func _update_zoom_label():
    zoom_label.text = str(int(zoom_level * 100)) + "%"

# Update navigation label
func _update_navigation_label():
    if image_list.size() > 0:
        navigation_label.text = str(current_index + 1) + " / " + str(image_list.size())
    else:
        navigation_label.text = ""

# Update image position based on pan offset
func _update_image_position():
    texture_rect.position = pan_offset

# Button event handlers
func _on_previous_pressed():
    previous_image()

func _on_next_pressed():
    next_image()

func _on_zoom_in_pressed():
    set_zoom(zoom_level + zoom_step)

func _on_zoom_out_pressed():
    set_zoom(zoom_level - zoom_step)

func _on_zoom_reset_pressed():
    set_zoom(1.0)
    pan_offset = Vector2.ZERO
    _update_image_position()