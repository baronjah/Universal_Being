# file_encryption.gd
extends Node

const EncryptionEngine = preload("res://scripts/encryption_engine.gd")

# Encrypt a JSON object and save it to a file
func encrypt_and_save_json(data, file_path, player_name, entity_name):
	# Convert JSON to string
	var json_string = JSON.stringify(data)
	
	# Create encryption engine with the player name and entity name as seeds
	var encryption = EncryptionEngine.new()
	encryption.initialize(player_name, entity_name)
	
	# Encrypt the string
	var encrypted_string = encryption.encrypt_string(json_string)
	
	# Save the encrypted string to file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(encrypted_string)
		file.close()
		return true
	else:
		printerr("Failed to open file for writing: " + file_path)
		return false

# Load and decrypt a JSON file
func load_and_decrypt_json(file_path, player_name, entity_name):
	# Check if file exists
	if not FileAccess.file_exists(file_path):
		printerr("File does not exist: " + file_path)
		return null
	
	# Read the encrypted string from file
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		printerr("Failed to open file for reading: " + file_path)
		return null
	
	var encrypted_string = file.get_as_text()
	file.close()
	
	# Create encryption engine with the same seeds
	var encryption = EncryptionEngine.new()
	encryption.initialize(player_name, entity_name)
	
	# Decrypt the string
	var decrypted_string = encryption.decrypt_string(encrypted_string)
	
	# Parse JSON
	var json = JSON.new()
	var error = json.parse(decrypted_string)
	if error == OK:
		return json.get_data()
	else:
		printerr("JSON Parse Error: " + json.get_error_message() + " at line " + str(json.get_error_line()))
		return null

# Helper function to get the player name from saved data
func get_player_name():
	# Try to read the player name from the player data file
	var player_name_file_path = "user://player_data.json"
	
	if FileAccess.file_exists(player_name_file_path):
		var file = FileAccess.open(player_name_file_path, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var error = json.parse(json_text)
			if error == OK:
				var data = json.get_data()
				if data.has("player_name"):
					return data["player_name"]
	
	# Return a default name if we couldn't get the player name
	return "Player"

# Save a creation build file
func save_creation_build(multiverse_name, data):
	var player_name = get_player_name()
	var file_path = "user://creationbuild_" + multiverse_name.to_lower().replace(" ", "_") + ".json"
	return encrypt_and_save_json(data, file_path, player_name, multiverse_name)

# Load a creation build file
func load_creation_build(multiverse_name):
	var player_name = get_player_name()
	var file_path = "user://creationbuild_" + multiverse_name.to_lower().replace(" ", "_") + ".json"
	return load_and_decrypt_json(file_path, player_name, multiverse_name)

# Save a creation play file (universe)
func save_creation_play(universe_name, data):
	var player_name = get_player_name()
	var file_path = "user://creationplay_" + universe_name.to_lower().replace(" ", "_") + ".json"
	return encrypt_and_save_json(data, file_path, player_name, universe_name)

# Load a creation play file (universe)
func load_creation_play(universe_name):
	var player_name = get_player_name()
	var file_path = "user://creationplay_" + universe_name.to_lower().replace(" ", "_") + ".json"
	return load_and_decrypt_json(file_path, player_name, universe_name)

# Save game progress (autosave)
func save_game_progress(universe_name, data):
	var player_name = get_player_name()
	var file_path = "user://savefileofcreation_" + universe_name.to_lower().replace(" ", "_") + ".json"
	return encrypt_and_save_json(data, file_path, player_name, universe_name)

# Load game progress
func load_game_progress(universe_name):
	var player_name = get_player_name()
	var file_path = "user://savefileofcreation_" + universe_name.to_lower().replace(" ", "_") + ".json"
	return load_and_decrypt_json(file_path, player_name, universe_name)
