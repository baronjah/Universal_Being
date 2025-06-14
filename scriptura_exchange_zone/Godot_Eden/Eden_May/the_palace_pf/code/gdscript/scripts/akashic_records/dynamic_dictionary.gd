extends Node
class_name DynamicDictionary

# Dictionary storage
var words: Dictionary = {}
var root_words: Array[String] = []
var interaction_engine = null

# File references
var dictionary_dir = "res://dictionary/"
var elements_dir = "res://dictionary/elements/"
var entities_dir = "res://dictionary/entities/"
var interactions_dir = "res://dictionary/interactions/"

signal word_added(word_id)
signal word_removed(word_id)
signal word_updated(word_id)
signal dictionary_loaded()

func _ready():
	# Create directories if they don't exist
	var dir = DirAccess.open("res://")
	if dir:
		if not dir.dir_exists(dictionary_dir):
			dir.make_dir_recursive(dictionary_dir)
		if not dir.dir_exists(elements_dir):
			dir.make_dir_recursive(elements_dir)
		if not dir.dir_exists(entities_dir):
			dir.make_dir_recursive(entities_dir)
		if not dir.dir_exists(interactions_dir):
			dir.make_dir_recursive(interactions_dir)

func add_word(word: WordEntry) -> bool:
	if words.has(word.id):
		return false
	
	words[word.id] = word
	
	# If word has no parent, add to root words
	if word.parent_id.is_empty():
		root_words.append(word.id)
	else:
		# Add as child to parent
		if words.has(word.parent_id):
			words[word.parent_id].add_child(word.id)
	
	emit_signal("word_added", word.id)
	return true

func remove_word(word_id: String) -> bool:
	if not words.has(word_id):
		return false
	
	var word = words[word_id]
	
	# Remove from parent
	if not word.parent_id.is_empty() and words.has(word.parent_id):
		words[word.parent_id].remove_child(word_id)
	
	# Remove from root words
	if root_words.has(word_id):
		root_words.erase(word_id)
	
	# Mark children as root words or remove them
	for child_id in word.children.duplicate():
		if words.has(child_id):
			if word.parent_id.is_empty():
				# If the removed word was a root, its children become roots
				words[child_id].parent_id = ""
				root_words.append(child_id)
			else:
				# Otherwise, connect children to grandparent
				words[child_id].parent_id = word.parent_id
				words[word.parent_id].add_child(child_id)
	
	# Remove the word
	words.erase(word_id)
	
	emit_signal("word_removed", word_id)
	return true

func get_word(word_id: String) -> WordEntry:
	if words.has(word_id):
		return words[word_id]
	return null

func update_word(word: WordEntry) -> bool:
	if not words.has(word.id):
		return false
	
	words[word.id] = word
	emit_signal("word_updated", word.id)
	return true

func load_dictionary(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return false
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error != OK:
		return false
	
	var data = json.data
	
	# Clear existing dictionary
	words.clear()
	root_words.clear()
	
	# Load words
	for word_id in data:
		var word = WordEntry.new()
		word.from_dict(data[word_id])
		words[word_id] = word
		
		# Check if root word
		if word.parent_id.is_empty():
			root_words.append(word_id)
	
	# Resolve variant references
	for word_id in data:
		if data[word_id].has("variant_ids"):
			for variant_id in data[word_id]["variant_ids"]:
				if words.has(variant_id):
					words[word_id].add_variant(words[variant_id])
	
	emit_signal("dictionary_loaded")
	return true

func save_dictionary(file_path: String) -> bool:
	var data = {}
	
	# Convert words to dictionaries
	for word_id in words:
		data[word_id] = words[word_id].to_dict()
	
	# Save to file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return false
	
	file.store_string(JSON.stringify(data, "  "))
	return true

func add_interaction_rule(word1_id: String, word2_id: String, result_id: String, conditions: Dictionary = {}) -> bool:
	if not words.has(word1_id) or not words.has(word2_id):
		return false
		
	words[word1_id].add_interaction_rule(word2_id, result_id, conditions)
	return true

func get_word_hierarchy(word_id: String, max_depth: int = -1) -> Dictionary:
	if not words.has(word_id):
		return {}
	
	var result = {}
	result[word_id] = _build_hierarchy(word_id, max_depth, 0)
	return result

func _build_hierarchy(word_id: String, max_depth: int, current_depth: int) -> Dictionary:
	if not words.has(word_id) or (max_depth >= 0 and current_depth >= max_depth):
		return {}
	
	var word = words[word_id]
	var result = {
		"id": word.id,
		"category": word.category,
		"properties": word.properties,
		"children": {}
	}
	
	for child_id in word.children:
		result["children"][child_id] = _build_hierarchy(child_id, max_depth, current_depth + 1)
	
	return result

# Dictionary splitting functions
func should_split_word(word_id: String) -> bool:
	if not words.has(word_id):
		return false
	
	var word = words[word_id]
	
	# Criteria for splitting:
	# 1. Too many children (more than 10)
	# 2. Complex interactions (more than 5)
	# 3. Many states (more than 3)
	
	if word.children.size() > 10:
		return true
	
	if word.interactions.size() > 5:
		return true
	
	if word.states.size() > 3:
		return true
	
	return false

func split_word_to_file(word_id: String) -> bool:
	if not words.has(word_id) or not should_split_word(word_id):
		return false
	
	var word = words[word_id]
	
	# Create file path
	var file_path = dictionary_dir + word_id + "_dictionary.json"
	
	# Gather word and its children
	var split_data = {}
	split_data[word_id] = word.to_dict()
	
	for child_id in word.children:
		if words.has(child_id):
			split_data[child_id] = words[child_id].to_dict()
	
	# Save to file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return false
	
	file.store_string(JSON.stringify(split_data, "  "))
	
	# Update file reference in main dictionary
	word.file_reference = file_path
	
	return true

func load_split_file(word_id: String) -> bool:
	if not words.has(word_id) or words[word_id].file_reference.is_empty():
		return false
	
	var file_path = words[word_id].file_reference
	
	return load_dictionary(file_path)

# Search and query functions
func search_words(query: String, filter_category: String = "") -> Array:
	var results = []
	
	for word_id in words:
		var word = words[word_id]
		
		# Check if category filter matches
		if not filter_category.is_empty() and word.category != filter_category:
			continue
		
		# Check if query matches id
		if query.is_empty() or word_id.findn(query) >= 0:
			results.append(word_id)
		
	return results

func get_words_by_category(category: String) -> Array:
	var results = []
	
	for word_id in words:
		if words[word_id].category == category:
			results.append(word_id)
	
	return results

# Words with property in specific range
func find_words_by_property(property_name: String, min_value: float, max_value: float) -> Array:
	var results = []
	
	for word_id in words:
		var word = words[word_id]
		
		if word.properties.has(property_name):
			var value = word.properties[property_name]
			
			if value is float and value >= min_value and value <= max_value:
				results.append(word_id)
	
	return results

# Create a variant of an existing word
func generate_variant(word_id: String, variant_id: String, mutation_factor: float = 0.2) -> WordEntry:
	if not words.has(word_id):
		return null
	
	var original = words[word_id]
	
	# Create variant with similar properties
	var variant = WordEntry.new(variant_id, original.category)
	variant.parent_id = original.id
	
	# Copy and modify properties
	for prop in original.properties:
		if original.properties[prop] is float:
			var value = original.properties[prop]
			var mutation = (randf() - 0.5) * mutation_factor
			variant.properties[prop] = clamp(value + mutation, 0.0, 1.0)
		else:
			variant.properties[prop] = original.properties[prop]
	
	# Copy states
	variant.states = original.states.duplicate()
	variant.current_state = original.current_state
	
	# Connect variant to original
	original.add_variant(variant)
	
	# Add to dictionary
	add_word(variant)
	
	return variant