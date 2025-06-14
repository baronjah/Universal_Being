# encryption_key_generator.gd
extends Node

# Generate an encryption key based on player name and world name
func generate_key(player_name, world_name):
	var combined = player_name + world_name
	var hash_value = combined.sha256_text()
	
	# Use the hash to create a pseudo-random but deterministic sequence
	var key = []
	for i in range(0, hash_value.length(), 2):
		if i + 1 < hash_value.length():
			var hex_pair = hash_value.substr(i, 2)
			var value = ("0x" + hex_pair).hex_to_int() % 256
			key.append(value)
	
	return key
	
# Get a specific byte from the key at a given position (wrapping around if needed)
func get_key_byte(key, position):
	return key[position % key.size()]
