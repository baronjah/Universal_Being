extends Node
class_name InteractionEngine

# References
var dictionary = null

# History
var interaction_history = []
var max_history = 100

signal interaction_processed(word1_id, word2_id, result_id, success)

func process_interaction(word1: WordEntry, word2: WordEntry, context: Dictionary = {}) -> Dictionary:
	if word1 == null or word2 == null:
		return {"success": false, "result": "", "error": "Invalid words"}
	
	# Check if the first word has an interaction rule for the second
	var interaction = word1.get_interaction_result(word2.id)
	if interaction.is_empty():
		return {"success": false, "result": "", "error": "No interaction rule found"}
	
	# Check conditions
	var result_id = interaction.get("result", "")
	var conditions = interaction.get("conditions", {})
	
	if not word1.evaluate_conditions(conditions, context):
		return {"success": false, "result": "", "error": "Conditions not met"}
	
	# Check if result exists
	if result_id.is_empty() or (dictionary != null and not dictionary.words.has(result_id)):
		return {"success": false, "result": "", "error": "Result not found"}
	
	# Record interaction in history
	_record_interaction(word1.id, word2.id, result_id, true)
	
	# Update usage statistics for both words
	word1.record_usage()
	word2.record_usage()
	
	# Emit signal
	emit_signal("interaction_processed", word1.id, word2.id, result_id, true)
	
	# Return success
	return {
		"success": true,
		"result": result_id,
		"word1": word1.id,
		"word2": word2.id,
		"data": {
			"word1_state": word1.current_state,
			"word2_state": word2.current_state,
			"context": context
		}
	}

func _record_interaction(word1_id: String, word2_id: String, result_id: String, success: bool) -> void:
	var interaction = {
		"timestamp": Time.get_unix_time_from_system(),
		"word1": word1_id,
		"word2": word2_id,
		"result": result_id,
		"success": success
	}
	
	interaction_history.push_front(interaction)
	
	# Limit history size
	if interaction_history.size() > max_history:
		interaction_history.resize(max_history)

func get_interactions_for_word(word_id: String) -> Array:
	var results = []
	
	for interaction in interaction_history:
		if interaction["word1"] == word_id or interaction["word2"] == word_id:
			results.append(interaction)
	
	return results

func get_interactions_between(word1_id: String, word2_id: String) -> Array:
	var results = []
	
	for interaction in interaction_history:
		if (interaction["word1"] == word1_id and interaction["word2"] == word2_id) or \
		   (interaction["word1"] == word2_id and interaction["word2"] == word1_id):
			results.append(interaction)
	
	return results

func get_recent_interactions(limit: int = 10) -> Array:
	return interaction_history.slice(0, min(limit, interaction_history.size()))

func clear_history() -> void:
	interaction_history.clear()

# Simulate interaction between words
func simulate_interaction(word1_id: String, word2_id: String, context: Dictionary = {}) -> Dictionary:
	if dictionary == null:
		return {"success": false, "error": "Dictionary not set"}
	
	var word1 = dictionary.get_word(word1_id)
	var word2 = dictionary.get_word(word2_id)
	
	if word1 == null or word2 == null:
		return {"success": false, "error": "Word not found"}
	
	return process_interaction(word1, word2, context)

# Find possible interactions for a word
func find_possible_interactions(word_id: String) -> Array:
	if dictionary == null:
		return []
	
	var word = dictionary.get_word(word_id)
	if word == null:
		return []
	
	var results = []
	
	# Check interactions defined in the word
	for target_id in word.interactions:
		if dictionary.words.has(target_id):
			results.append({
				"word1": word_id,
				"word2": target_id,
				"result": word.interactions[target_id].get("result", ""),
				"conditions": word.interactions[target_id].get("conditions", {})
			})
	
	# Check interactions where this word is a target
	for other_id in dictionary.words:
		var other_word = dictionary.words[other_id]
		if other_word.interactions.has(word_id):
			results.append({
				"word1": other_id,
				"word2": word_id,
				"result": other_word.interactions[word_id].get("result", ""),
				"conditions": other_word.interactions[word_id].get("conditions", {})
			})
	
	return results

# Create a chain of interactions
func create_interaction_chain(word_ids: Array, context: Dictionary = {}) -> Array:
	if word_ids.size() < 2:
		return [{"success": false, "error": "Need at least two words for a chain"}]
	
	var results = []
	var current_context = context.duplicate()
	
	for i in range(word_ids.size() - 1):
		var word1_id = word_ids[i]
		var word2_id = word_ids[i + 1]
		
		var result = simulate_interaction(word1_id, word2_id, current_context)
		results.append(result)
		
		if not result["success"]:
			# Chain broken, return what we have so far
			break
		
		# Update context with the result for next iteration
		if result.has("data") and result["data"].has("context"):
			for key in result["data"]["context"]:
				current_context[key] = result["data"]["context"][key]
	
	return results