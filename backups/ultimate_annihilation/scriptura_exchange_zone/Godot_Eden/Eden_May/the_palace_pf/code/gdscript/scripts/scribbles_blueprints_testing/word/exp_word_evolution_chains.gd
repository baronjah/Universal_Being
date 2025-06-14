extends Node
# -----------------------------------------------
# Purpose: Experiment with word evolution chains where one word transforms into another over time
# Status: In Progress
# Date: 2025-05-10
# Author: Claude
# Dependencies: JSHWordManifestor, JSHPhoneticAnalyzer, JSHSemanticAnalyzer, JSHPatternAnalyzer
# Findings:
#   - Words can evolve along phonetic or semantic paths
#   - Phonetic evolution maintains sound patterns but shifts meaning
#   - Semantic evolution maintains meaning but changes form
#   - Combining both creates interesting narrative chains
# Next Steps:
#   - Test with larger word sets
#   - Implement visualization of word evolution chains
#   - Create algorithms for generating interesting chains
#   - Evaluate performance impact of chain calculation
# -----------------------------------------------

class_name ExpWordEvolutionChains

# System references
var word_manifestor = JSHWordManifestor.get_instance()
var phonetic_analyzer = JSHPhoneticAnalyzer.get_instance()
var semantic_analyzer = JSHSemanticAnalyzer.get_instance()
var pattern_analyzer = JSHPatternAnalyzer.get_instance()

# Experiment variables
var word_chains = []
var evolution_paths = {}
var test_words = ["fire", "water", "earth", "air", "spirit", "void", "light", "dark"]
var evolution_steps = 5
var chain_count = 0

# Initialize experiment
func _ready():
	print("Starting Word Evolution Chains experiment")

# Main experiment function
func run_experiment():
	print("Running word evolution chains experiment...")
	
	# Generate evolution chains for each test word
	for word in test_words:
		var chain = generate_evolution_chain(word, evolution_steps)
		word_chains.append(chain)
		print("Evolution chain for '", word, "': ", chain)
		chain_count += 1
	
	# Try different evolution strategies
	print("\nTesting different evolution strategies:")
	print("Phonetic evolution chain for 'fire':", generate_phonetic_chain("fire", 3))
	print("Semantic evolution chain for 'water':", generate_semantic_chain("water", 3))
	print("Mixed evolution chain for 'earth':", generate_mixed_chain("earth", 3))
	
	analyze_results()
	
	print("Word evolution chains experiment completed!")

# Generate an evolution chain for a word
func generate_evolution_chain(start_word: String, steps: int) -> Array:
	var chain = [start_word]
	var current_word = start_word
	
	for i in range(steps):
		# Analyze the current word
		var phonetic_data = phonetic_analyzer.analyze(current_word)
		var semantic_data = semantic_analyzer.analyze(current_word)
		
		# Choose evolution strategy (alternate between phonetic and semantic)
		var next_word = ""
		if i % 2 == 0:
			next_word = evolve_phonetically(current_word, phonetic_data)
		else:
			next_word = evolve_semantically(current_word, semantic_data)
		
		chain.append(next_word)
		current_word = next_word
	
	return chain

# Generate a phonetic-focused evolution chain
func generate_phonetic_chain(start_word: String, steps: int) -> Array:
	var chain = [start_word]
	var current_word = start_word
	
	for i in range(steps):
		var phonetic_data = phonetic_analyzer.analyze(current_word)
		var next_word = evolve_phonetically(current_word, phonetic_data)
		chain.append(next_word)
		current_word = next_word
	
	return chain

# Generate a semantic-focused evolution chain
func generate_semantic_chain(start_word: String, steps: int) -> Array:
	var chain = [start_word]
	var current_word = start_word
	
	for i in range(steps):
		var semantic_data = semantic_analyzer.analyze(current_word)
		var next_word = evolve_semantically(current_word, semantic_data)
		chain.append(next_word)
		current_word = next_word
	
	return chain

# Generate a mixed evolution chain
func generate_mixed_chain(start_word: String, steps: int) -> Array:
	var chain = [start_word]
	var current_word = start_word
	
	for i in range(steps):
		# Analyze current word
		var phonetic_data = phonetic_analyzer.analyze(current_word)
		var semantic_data = semantic_analyzer.analyze(current_word)
		
		# Calculate potential next words
		var phonetic_next = evolve_phonetically(current_word, phonetic_data)
		var semantic_next = evolve_semantically(current_word, semantic_data)
		
		# Choose the more interesting evolution
		var phonetic_interest = calculate_interest_score(phonetic_next)
		var semantic_interest = calculate_interest_score(semantic_next)
		
		var next_word = phonetic_next if phonetic_interest > semantic_interest else semantic_next
		
		chain.append(next_word)
		current_word = next_word
	
	return chain

# Evolve a word based on its phonetic properties
func evolve_phonetically(word: String, phonetic_data: Dictionary) -> String:
	# This is a simplified implementation for the experiment
	# In a real implementation, this would use more sophisticated phonetic evolution rules
	
	# Get the primary element based on phonetic analysis
	var element = phonetic_data.element_affinity.primary if phonetic_data.element_affinity.has("primary") else "neutral"
	
	# Simple mapping of elements to related words
	var element_words = {
		"fire": ["flame", "blaze", "ember", "spark", "inferno"],
		"water": ["stream", "river", "ocean", "droplet", "wave"],
		"earth": ["stone", "mountain", "crystal", "soil", "mineral"],
		"air": ["breeze", "wind", "gust", "tempest", "zephyr"],
		"metal": ["iron", "steel", "bronze", "alloy", "silver"],
		"wood": ["tree", "forest", "branch", "leaf", "root"],
		"lightning": ["thunder", "spark", "bolt", "flash", "storm"],
		"ice": ["frost", "snow", "glacier", "chill", "crystal"]
	}
	
	# If we have words for this element, choose one
	if element_words.has(element):
		var choices = element_words[element]
		return choices[randi() % choices.size()]
	
	# Fallback: modify the original word
	var vowels = "aeiou"
	var consonants = "bcdfghjklmnpqrstvwxyz"
	var new_word = ""
	
	for i in range(word.length()):
		var c = word[i]
		if vowels.find(c) >= 0:
			# Replace vowel with another random vowel (20% chance)
			if randf() < 0.2:
				c = vowels[randi() % vowels.length()]
		elif consonants.find(c) >= 0:
			# Replace consonant with another random consonant (20% chance)
			if randf() < 0.2:
				c = consonants[randi() % consonants.length()]
		new_word += c
	
	return new_word

# Evolve a word based on its semantic properties
func evolve_semantically(word: String, semantic_data: Dictionary) -> String:
	# This is a simplified implementation for the experiment
	# In a real implementation, this would use more sophisticated semantic evolution rules
	
	# Get primary concept if available
	var concept = semantic_data.primary_concept if semantic_data.has("primary_concept") else ""
	
	# Simple mapping of concepts to related words
	var concept_words = {
		"fire": ["heat", "burn", "glow", "warmth", "combustion"],
		"water": ["liquid", "fluid", "aqua", "hydration", "moisture"],
		"earth": ["ground", "land", "terrain", "dirt", "clay"],
		"air": ["atmosphere", "oxygen", "breath", "sky", "vapor"],
		"light": ["illumination", "brightness", "radiance", "glow", "beam"],
		"dark": ["shadow", "gloom", "darkness", "shade", "night"],
		"life": ["vitality", "existence", "living", "organism", "biology"],
		"death": ["end", "expiration", "demise", "passing", "mortality"],
		"power": ["strength", "force", "energy", "might", "potency"],
		"wisdom": ["knowledge", "insight", "intelligence", "understanding", "sagacity"]
	}
	
	# If we have words for this concept, choose one
	if concept_words.has(concept):
		var choices = concept_words[concept]
		return choices[randi() % choices.size()]
	
	# If we have opposing concepts, sometimes choose from those
	if semantic_data.has("opposing_concepts") and not semantic_data.opposing_concepts.is_empty():
		var opposing = semantic_data.opposing_concepts[0]
		if concept_words.has(opposing) and randf() < 0.3:
			var choices = concept_words[opposing]
			return choices[randi() % choices.size()]
	
	# Fallback: choose a word based on positivity
	var positivity = semantic_data.positivity if semantic_data.has("positivity") else 0.5
	
	if positivity > 0.7:
		return ["good", "great", "excellent", "wonderful", "positive"][randi() % 5]
	elif positivity < 0.3:
		return ["bad", "poor", "negative", "troubled", "difficult"][randi() % 5]
	else:
		return ["neutral", "balanced", "moderate", "medium", "average"][randi() % 5]

# Calculate an "interest score" for a word
func calculate_interest_score(word: String) -> float:
	# This is a simplified scoring system for the experiment
	var phonetic_data = phonetic_analyzer.analyze(word)
	var semantic_data = semantic_analyzer.analyze(word)
	
	var score = 0.0
	
	# Longer words are slightly more interesting
	score += min(0.2, word.length() * 0.02)
	
	# Words with higher complexity are more interesting
	score += semantic_data.complexity if semantic_data.has("complexity") else 0.0
	
	# Words with higher power are more interesting
	score += phonetic_data.power if phonetic_data.has("power") else 0.0
	
	# Words at the extreme ends of positivity are more interesting
	var positivity = semantic_data.positivity if semantic_data.has("positivity") else 0.5
	score += abs(positivity - 0.5) * 0.4
	
	# Words with more resonance are more interesting
	score += phonetic_data.resonance if phonetic_data.has("resonance") else 0.0
	
	return score

# Analyze experiment results
func analyze_results():
	print("\nAnalyzing word chain results...")
	
	# Calculate average chain length
	var total_words = 0
	for chain in word_chains:
		total_words += chain.size()
	
	var avg_length = float(total_words) / max(1, word_chains.size())
	print("Average chain length: ", avg_length)
	
	# Calculate unique words ratio
	var all_words = []
	for chain in word_chains:
		for word in chain:
			all_words.append(word)
	
	var unique_words = {}
	for word in all_words:
		unique_words[word] = true
	
	var uniqueness_ratio = float(unique_words.size()) / max(1, all_words.size())
	print("Word uniqueness ratio: ", uniqueness_ratio)
	print("Total chains generated: ", chain_count)
	
	print("Analysis completed")

# Clean up
func _exit_tree():
	print("Cleaning up word evolution chains experiment...")
	word_chains.clear()
	evolution_paths.clear()