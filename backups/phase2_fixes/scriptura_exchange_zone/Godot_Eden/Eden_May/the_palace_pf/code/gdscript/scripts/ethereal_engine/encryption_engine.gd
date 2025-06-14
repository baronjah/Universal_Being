# encryption_engine.gd
extends Node

const EncryptionMapping = preload("res://code/scripts/ethereal_engine/encryption_mapping.gd")
const KeyGenerator = preload("res://code/scripts/ethereal_engine/encryption_key_generator.gd")

# Encrypt a string using the player name and world name as key components
func encrypt_string(input_string, player_name, world_name):
	var key = KeyGenerator.generate_key(player_name, world_name)
	var result = ""
	var pos = 0
	
	for i in range(input_string.length()):
		var char = input_string[i]
		
		# Check if this character should be encrypted
		if char in EncryptionMapping.SPECIAL_CHARS:
			# Get the basic romanji representation
			var romanji = EncryptionMapping.ROMANJI_MAPPING[char]
			
			# Apply key-based transformation
			var key_byte = KeyGenerator.get_key_byte(key, pos)
			var transformed_romanji = transform_romanji(romanji, key_byte)
			
			result += transformed_romanji
		else:
			# Non-special characters remain unchanged
			result += char
			
		pos += 1
		
	return result
	
# Decrypt a previously encrypted string
func decrypt_string(encrypted_string, player_name, world_name):
	var key = KeyGenerator.generate_key(player_name, world_name)
	var result = ""
	var pos = 0
	var i = 0
	
	while i < encrypted_string.length():
		# Check if this might be an encrypted pair
		if i + 1 < encrypted_string.length():
			var possible_romanji = encrypted_string.substr(i, 2)
			
			# Get key byte for this position
			var key_byte = KeyGenerator.get_key_byte(key, pos)
			
			# Try to reverse the transformation
			var original_romanji = reverse_transform_romanji(possible_romanji, key_byte)
			
			# Check if this is a valid romanji pair
			if original_romanji in EncryptionMapping.REVERSE_MAPPING:
				# It's a valid pair, decrypt it
				result += EncryptionMapping.REVERSE_MAPPING[original_romanji]
				i += 2
				pos += 1
				continue
		
		# If we get here, it's not a special character
		result += encrypted_string[i]
		i += 1
		pos += 1
		
	return result
	
# Transform a romanji pair based on a key byte
func transform_romanji(romanji, key_byte):
	# This is a simplified example - you could make this more complex
	# For now, we'll just use the key to choose between a few transformations
	var transformations = [
		func(r): return r,                      # No change
		func(r): return r.to_upper(),           # Uppercase
		func(r): return r[1] + r[0],            # Swap characters
		func(r): return r + str(key_byte % 10)  # Add a digit
	]
	
	var transform_index = key_byte % transformations.size()
	return transformations[transform_index].call(romanji)
	
# Reverse a transformation applied to a romanji pair
func reverse_transform_romanji(transformed, key_byte):
	# Apply reverse transformations in order
	var transform_index = key_byte % 4
	
	match transform_index:
		0: # No change
			return transformed
		1: # Was uppercase
			return transformed.to_lower()
		2: # Was swapped
			if transformed.length() == 2:
				return transformed[1] + transformed[0]
			return transformed
		3: # Had digit added
			if transformed.length() > 2:
				return transformed.substr(0, 2)
			return transformed
			
	return transformed


## version 2.0

# encryption_engine.gd
extends RefCounted

# Mapping dictionary from characters to Romanji/Hiragana representation
var char_to_romanji = {
	"a": "ka", "b": "ki", "c": "ku", "d": "ke", "e": "ko",
	"f": "sa", "g": "shi", "h": "su", "i": "se", "j": "so",
	"k": "ta", "l": "chi", "m": "tsu", "n": "te", "o": "to",
	"p": "na", "q": "ni", "r": "nu", "s": "ne", "t": "no",
	"u": "ha", "v": "hi", "w": "fu", "x": "he", "y": "ho",
	"z": "ma", "0": "mi", "1": "mu", "2": "me", "3": "mo",
	"4": "ya", "5": "yu", "6": "yo", "7": "ra", "8": "ri",
	"9": "ru", "+": "re", "-": "ro", "*": "wa", "/": "wo",
	"=": "n", ".": "ga", ",": "gi", ";": "gu", ":": "ge",
	"_": "go", "(": "za", ")": "ji", "{": "zu", "}": "ze",
	"[": "zo", "]": "da", "!": "di", "@": "du", "#": "de",
	"$": "do", "%": "ba", "^": "bi", "&": "bu", "<": "be",
	">": "bo", "?": "pa", "|": "pi", "~": "pu", "`": "pe",
	" ": "po"
}

# Reverse mapping for decryption
var romanji_to_char = {}

# Encryption key derived from player name and entity name
var encryption_key = []
var key_length = 0

# Initialize the encryption engine with the player and entity names
func initialize(player_name, entity_name):
	# Create reverse mapping
	romanji_to_char.clear()
	for key in char_to_romanji:
		romanji_to_char[char_to_romanji[key]] = key
	
	# Generate encryption key from player name and entity name
	generate_encryption_key(player_name, entity_name)

# Generate a unique encryption key based on player name and entity name
func generate_encryption_key(player_name, entity_name):
	encryption_key.clear()
	
	# Combine the names
	var combined = player_name + "_" + entity_name
	
	# Use characters from combined name as seed values
	for i in range(combined.length()):
		var char_code = combined.unicode_at(i)
		encryption_key.append(char_code % 256)  # Keep values in byte range
	
	# Ensure we have at least 16 values in the key
	while encryption_key.size() < 16:
		var last = encryption_key[encryption_key.size() - 1]
		encryption_key.append((last * 17 + 23) % 256)
	
	key_length = encryption_key.size()

# Encrypt a single character using the key
func encrypt_char(c, position):
	var key_value = encryption_key[position % key_length]
	
	# Apply a simple transformation based on the key value
	var char_code = c.unicode_at(0)
	var transformed = char_code ^ key_value  # XOR with key value
	
	# Ensure the result is within ASCII range
	transformed = transformed % 128
	
	# Convert back to character
	return String.chr(transformed)

# Decrypt a single character using the key
func decrypt_char(c, position):
	var key_value = encryption_key[position % key_length]
	
	# Apply the inverse transformation
	var char_code = c.unicode_at(0)
	var transformed = (char_code ^ key_value)  # XOR is its own inverse
	
	# Ensure the result is within ASCII range
	transformed = transformed % 128
	
	# Convert back to character
	return String.chr(transformed)

# Encrypt a string by first applying the character mapping and then the key transformation
func encrypt_string(input_string):
	var mapped_string = ""
	
	# Apply character mapping
	for i in range(input_string.length()):
		var c = input_string[i].to_lower()
		if char_to_romanji.has(c):
			mapped_string += char_to_romanji[c]
		else:
			# For characters not in our mapping, use a fallback
			mapped_string += "xx"  # Placeholder for unmapped chars
	
	# Apply key-based encryption
	var encrypted_string = ""
	for i in range(mapped_string.length()):
		encrypted_string += encrypt_char(mapped_string[i], i)
	
	return encrypted_string

# Decrypt a string by first applying the key transformation and then the reverse character mapping
func decrypt_string(encrypted_string):
	# Apply key-based decryption
	var mapped_string = ""
	for i in range(encrypted_string.length()):
		mapped_string += decrypt_char(encrypted_string[i], i)
	
	# Apply reverse character mapping
	var decrypted_string = ""
	var i = 0
	while i < mapped_string.length():
		if i + 1 < mapped_string.length():
			var pair = mapped_string.substr(i, 2)
			if romanji_to_char.has(pair):
				decrypted_string += romanji_to_char[pair]
				i += 2
			else:
				# Handle unmapped pairs
				if pair == "xx":
					# This was an unmapped character in the original string
					decrypted_string += "?"
				else:
					# Something went wrong with decryption
					decrypted_string += "#"
				i += 2
		else:
			# Odd leftover character, something is wrong
			decrypted_string += "!"
			i += 1
	
	return decrypted_string
