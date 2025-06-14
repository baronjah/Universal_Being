# user_interface.gd - Manages game UI
extends Control

var config
signal big_bang_triggered

# UI elements
var menu_container
var menu_buttons = [
	"Things",
	"Scenes",
	"Actions",
	"Instructions",
	"Settings",
	"Exit"
]

func _ready():
	# Create UI elements
	_create_menu()
	
	# Create Big Bang button
	var big_bang_button = Button.new()
	big_bang_button.text = "Big Bang"
	big_bang_button.connect("pressed", self, "_on_big_bang_button_pressed")
	add_child(big_bang_button)

func _create_menu():
	menu_container = VBoxContainer.new()
	add_child(menu_container)
	
	for item in menu_buttons:
		var button = Button.new()
		button.text = item
		menu_container.add_child(button)

func _on_big_bang_button_pressed():
	# Emit signal to trigger big bang
	emit_signal("big_bang_triggered")
	
	# Animation for button (the "funny thingy dingy")
	var tween = get_tree().create_tween()
	tween.tween_property($BigBangButton, "rotation", Vector3(0, TAU, 0), 1.0)



# Manages game UI for the universe simulation
extends Control

var config: Dictionary
signal big_bang_triggered

# UI elements
var menu_container: VBoxContainer
var big_bang_button: Button
var menu_buttons = [
	"Things",
	"Scenes",
	"Actions",
	"Instructions",
	"Settings",
	"Exit"
]

func _ready() -> void:
	# Set layout
	anchors_preset = Control.PRESET_FULL_RECT
	
	# Create UI elements
	_create_menu()
	
	# Create Big Bang button
	big_bang_button = Button.new()
	big_bang_button.text = "Big Bang"
	big_bang_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	big_bang_button.position.y = 500
	big_bang_button.position.x = 500
	big_bang_button.pressed.connect(_on_big_bang_button_pressed)
	add_child(big_bang_button)

func _create_menu() -> void:
	menu_container = VBoxContainer.new()
	menu_container.position = Vector3(50, 50, 0)
	add_child(menu_container)
	
	for item in menu_buttons:
		var button = Button.new()
		button.text = item
		menu_container.add_child(button)

func _on_big_bang_button_pressed() -> void:
	# Emit signal to trigger big bang
	big_bang_triggered.emit()
	
	# Animation for button (the "funny thingy dingy")
	var tween = create_tween()
	tween.tween_property(big_bang_button, "rotation", Vector3(0, 6.28, 0), 1.0)
