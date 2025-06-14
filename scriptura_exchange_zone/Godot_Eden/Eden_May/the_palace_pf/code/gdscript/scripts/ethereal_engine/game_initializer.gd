# game_initializer.gd
extends Node

# Path for the player data file
const PLAYER_DATA_PATH = "user://player_data.json"

# Called when the scene tree is loaded
func _ready():
	# Check if this is the first launch
	if is_first_launch():
		# Show the first launch scene
		get_tree().change_scene_to_file("res://scenes/first_launch.tscn")
	else:
		# Update last login timestamp
		update_last_login()
		
		# Proceed to main menu
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Check if this is the first launch by looking for player data
func is_first_launch():
	return not FileAccess.file_exists(PLAYER_DATA_PATH)

# Update the last login timestamp in the player data
func update_last_login():
	# Read existing player data
	var file = FileAccess.open(PLAYER_DATA_PATH, FileAccess.READ)
	if not file:
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		printerr("Failed to parse player data: " + json.get_error_message())
		return
	
	var player_data = json.get_data()
	
	# Update last login timestamp
	player_data["last_login"] = Time.get_datetime_string_from_system()
	
	# Save updated data
	file = FileAccess.open(PLAYER_DATA_PATH, FileAccess.WRITE)
	if not file:
		printerr("Failed to open player data file for writing")
		return
	
	file.store_string(JSON.stringify(player_data))
	file.close()

# Get the player's name
func get_player_name():
	if is_first_launch():
		return "Player"  # Default name
	
	var file = FileAccess.open(PLAYER_DATA_PATH, FileAccess.READ)
	if not file:
		return "Player"  # Default name
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		return "Player"  # Default name
	
	var player_data = json.get_data()
	
	return player_data.get("player_name", "Player")
