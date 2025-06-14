# first_launch.gd
extends Control

@onready var name_input = $CenterContainer/PanelContainer/VBoxContainer/NameInput
@onready var save_button = $CenterContainer/PanelContainer/VBoxContainer/SaveButton
@onready var error_label = $CenterContainer/PanelContainer/VBoxContainer/ErrorLabel

const MIN_NAME_LENGTH = 3
const MAX_NAME_LENGTH = 20

func _ready():
	# Hide any error message initially
	error_label.text = ""
	error_label.hide()
	
	# Connect button signal
	save_button.pressed.connect(_on_save_button_pressed)
	
	# Connect text changed signal to validate input
	name_input.text_changed.connect(_on_name_input_text_changed)
	
	# Initial button state
	save_button.disabled = true
	
	# Focus the input field
	name_input.grab_focus()

func _on_name_input_text_changed(new_text):
	# Simple validation
	var valid = new_text.length() >= MIN_NAME_LENGTH and new_text.length() <= MAX_NAME_LENGTH
	
	# Additional validation if needed (e.g., no special characters)
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9_]+$")  # Only allow alphanumeric and underscore
	
	if not regex.search(new_text):
		valid = false
		error_label.text = "Name can only contain letters, numbers, and underscores."
		error_label.show()
	elif new_text.length() < MIN_NAME_LENGTH:
		error_label.text = "Name must be at least " + str(MIN_NAME_LENGTH) + " characters."
		error_label.show()
	elif new_text.length() > MAX_NAME_LENGTH:
		error_label.text = "Name must be at most " + str(MAX_NAME_LENGTH) + " characters."
		error_label.show()
	else:
		error_label.text = ""
		error_label.hide()
	
	# Update button state
	save_button.disabled = not valid

func _on_save_button_pressed():
	# Get the player name
	var player_name = name_input.text.strip_edges()
	
	# Save the player name
	save_player_name(player_name)
	
	# Proceed to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func save_player_name(player_name):
	# Create a dictionary with player data
	var player_data = {
		"player_name": player_name,
		"first_login": Time.get_datetime_string_from_system(),
		"last_login": Time.get_datetime_string_from_system()
	}
	
	# Convert to JSON string
	var json_string = JSON.stringify(player_data)
	
	# Save to file
	var file = FileAccess.open("user://player_data.json", FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
