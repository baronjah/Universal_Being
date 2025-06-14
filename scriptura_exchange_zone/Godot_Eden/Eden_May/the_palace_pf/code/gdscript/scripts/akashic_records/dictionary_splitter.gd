extends Node
class_name DictionarySplitter

# Thresholds for dictionary management
const MAX_CHILDREN_BEFORE_SPLIT = 20
const MAX_PROPERTIES_BEFORE_SPLIT = 15
const MAX_INTERACTION_RULES_BEFORE_SPLIT = 10
const MAX_DICTIONARY_ENTRIES = 100

# Dictionary reference
var dictionary

# Constructor
func _init(dict_reference):
	dictionary = dict_reference

# Check if a dictionary is too large and should be split
func should_split_dictionary(dict_name: String, dict_data: Dictionary) -> bool:
	# Check total dictionary size
	if dict_data.words.size() > MAX_DICTIONARY_ENTRIES:
		return true
	
	return false

# Check if a word should be split into its own dictionary
func should_split_word(word_id: String, word_data: Dictionary) -> bool:
	# Check against thresholds
	
	# Complex hierarchy
	if word_data.has("children") and word_data.children.size() > MAX_CHILDREN_BEFORE_SPLIT:
		return true
	
	# Many properties
	if word_data.has("properties") and word_data.properties.size() > MAX_PROPERTIES_BEFORE_SPLIT:
		return true
	
	# Many interaction rules
	if word_data.has("interactions") and word_data.interactions.size() > MAX_INTERACTION_RULES_BEFORE_SPLIT:
		return true
	
	return false

# Find candidates for splitting in a dictionary
func find_split_candidates(dict_data: Dictionary) -> Array:
	var candidates = []
	
	for word_id in dict_data.words:
		var word = dict_data.words[word_id]
		
		# Skip references to other dictionaries
		if word.has("file_reference") and word.file_reference:
			continue
		
		if should_split_word(word_id, word):
			candidates.append(word_id)
	
	return candidates

# Split a word into its own dictionary file
func split_word_to_dictionary(word_id: String, 
                            source_dict: Dictionary, 
                            target_path: String) -> Dictionary:
	# Create new dictionary for this word
	var new_dict = {
		"metadata": {
			"version": "1.0",
			"parent_word": word_id,
			"created_at": Time.get_unix_time_from_system(),
			"last_modified": Time.get_unix_time_from_system()
		},
		"words": {}
	}
	
	# Get the word
	var word = source_dict.words.get(word_id)
	if not word:
		printerr("Word %s not found in dictionary" % word_id)
		return new_dict
	
	# Add the word itself to the new dictionary
	new_dict.words[word_id] = word.duplicate(true)
	
	# Add all child words recursively
	add_children_to_dictionary(word_id, source_dict, new_dict)
	
	return new_dict

# Recursively add all children of a word to a dictionary
func add_children_to_dictionary(word_id: String, 
                               source_dict: Dictionary, 
                               target_dict: Dictionary) -> void:
	var word = source_dict.words.get(word_id)
	if not word or not word.has("children"):
		return
	
	for child_id in word.children:
		var child = source_dict.words.get(child_id)
		if child and not child.has("file_reference"):
			# Add child to new dictionary
			target_dict.words[child_id] = child.duplicate(true)
			
			# Recursively add this child's children
			add_children_to_dictionary(child_id, source_dict, target_dict)

# Save a dictionary to disk
func save_dictionary(dict_data: Dictionary, path: String) -> bool:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		printerr("Failed to open file %s for writing" % path)
		return false
	
	# Update last modified timestamp
	dict_data.metadata.last_modified = Time.get_unix_time_from_system()
	
	# Convert to JSON and save
	var json_string = JSON.stringify(dict_data, "  ")
	file.store_string(json_string)
	
	return true

# Create a reference entry for a split word
func create_reference_entry(word_id: String, word_data: Dictionary, target_path: String) -> Dictionary:
	# Create a simplified reference entry
	var reference = {
		"id": word_id,
		"category": word_data.get("category", "unknown"),
		"file_reference": target_path
	}
	
	return reference

# Execute a split operation for a word
func execute_split(word_id: String, base_path: String = "user://dictionaries/") -> bool:
	# Get dictionary data
	var root_dict = dictionary.master_dictionary
	
	# Ensure word exists and should be split
	var word = root_dict.words.get(word_id)
	if not word:
		printerr("Word %s not found" % word_id)
		return false
	
	if word.has("file_reference") and word.file_reference:
		printerr("Word %s is already a reference" % word_id)
		return false
	
	if not should_split_word(word_id, word):
		printerr("Word %s doesn't meet split criteria" % word_id)
		return false
	
	# Create target path
	var dict_path = base_path + word_id + "_dictionary.json"
	
	# Create and save new dictionary
	var new_dict = split_word_to_dictionary(word_id, root_dict, dict_path)
	var save_success = save_dictionary(new_dict, dict_path)
	
	if not save_success:
		printerr("Failed to save dictionary for %s" % word_id)
		return false
	
	# Replace full entry with reference in source dictionary
	var reference = create_reference_entry(word_id, word, dict_path)
	root_dict.words[word_id] = reference
	
	# Save updated source dictionary
	dictionary.save_root_dictionary()
	
	print("Successfully split word %s to %s" % [word_id, dict_path])
	return true

# Analyze a dictionary for potential splits and execute them
func analyze_and_split(base_path: String = "user://dictionaries/") -> Array:
	var split_results = []
	var root_dict = dictionary.master_dictionary
	
	# Check if whole dictionary should be reorganized
	if should_split_dictionary("root", root_dict):
		print("Dictionary is large, finding split candidates...")
		
		# Find candidates for splitting
		var candidates = find_split_candidates(root_dict)
		
		# Execute splits
		for word_id in candidates:
			var result = execute_split(word_id, base_path)
			split_results.append({
				"word_id": word_id,
				"success": result
			})
	
	return split_results