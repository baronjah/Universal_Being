extends Node

class_name TextSummarizationSystem

# ----- CONSTANTS -----
const MAX_TOKEN_COUNT = 17000 # Target slightly over 16.9K to account for formatting
const MIN_TOKEN_COUNT = 1000 # Minimum size for generated summaries
const TOKEN_AVG_CHARS = 3.5 # Average characters per token (approximate)
const SUMMARY_LEVELS = 5 # Number of summary abstraction levels
const MIN_SENTENCE_LENGTH = 6 # Minimum words to consider a sentence complete
const MAX_SENTENCE_RATIO = 0.6 # Max percentage of sentences to include in highest detail summary

# Reality dimensions - borrowed from RealityDataProcessor
const REALITY_DIMENSIONS = {
	"physical": { # Most concrete details
		"importance_threshold": 0.4,
		"detail_level": 0.9,
		"token_ratio": 0.5,
		"description": "Base physical reality layer - concrete details and facts"
	},
	"digital": { # Important informational elements
		"importance_threshold": 0.5,
		"detail_level": 0.8,
		"token_ratio": 0.3,
		"description": "Digital reality layer - key information and data points"
	},
	"temporal": { # Sequential and time-based information
		"importance_threshold": 0.6,
		"detail_level": 0.6,
		"token_ratio": 0.15,
		"description": "Time-based layer with sequence and progression"
	},
	"conceptual": { # Abstract ideas and themes
		"importance_threshold": 0.7,
		"detail_level": 0.4,
		"token_ratio": 0.05,
		"description": "Idea and thought layer - abstract connections and themes"
	},
	"quantum": { # Highest-level overview
		"importance_threshold": 0.85,
		"detail_level": 0.1,
		"token_ratio": 0.01,
		"description": "Parallel possibility layer - essence and highest abstractions"
	}
}

# ----- PROCESSING ALGORITHMS -----
const SUMMARIZATION_ALGORITHMS = {
	"extractive": {
		"description": "Extracts and retains key sentences based on importance",
		"complexity": "medium",
		"token_efficiency": 0.6,
		"content_retention": 0.8
	},
	"abstractive": {
		"description": "Generates new sentences that capture essential meaning",
		"complexity": "high",
		"token_efficiency": 0.9,
		"content_retention": 0.7
	},
	"hybrid": {
		"description": "Combines extraction with abstraction for balanced summary",
		"complexity": "high",
		"token_efficiency": 0.75,
		"content_retention": 0.85
	},
	"dimensional": {
		"description": "Creates multi-layered summary at different abstraction levels",
		"complexity": "very high",
		"token_efficiency": 0.8,
		"content_retention": 0.9
	}
}

# ----- WORD POWER SYSTEM -----
# Borrowed and extended from DivineWordProcessor
var word_importance_dictionary = {
	# Core concept words (very high importance)
	"summary": 0.9, "overview": 0.85, "important": 0.8, "significance": 0.8,
	"critical": 0.85, "essential": 0.85, "key": 0.8, "vital": 0.8,
	"conclusion": 0.9, "ultimately": 0.8, "fundamentally": 0.8,
	
	# Information structure words (high importance)
	"first": 0.75, "second": 0.7, "third": 0.7, "finally": 0.8,
	"however": 0.7, "therefore": 0.75, "because": 0.7, "consequently": 0.7,
	"notably": 0.75, "significantly": 0.7, "in conclusion": 0.9,
	
	# Topic indicators (medium-high importance)
	"research": 0.65, "study": 0.65, "analysis": 0.65, "data": 0.6,
	"results": 0.7, "findings": 0.7, "evidence": 0.7, "suggests": 0.6,
	"indicates": 0.6, "demonstrates": 0.65, "reveals": 0.65,
	
	# Narrative words (medium importance)
	"development": 0.55, "progress": 0.5, "decline": 0.5, "increase": 0.5,
	"decrease": 0.5, "change": 0.5, "transformation": 0.55, "shift": 0.5,
	"evolution": 0.55, "revolution": 0.6, "innovation": 0.6,
	
	# Common words (low importance)
	"the": 0.1, "a": 0.1, "an": 0.1, "is": 0.1, "are": 0.1,
	"was": 0.1, "were": 0.1, "be": 0.1, "to": 0.1, "of": 0.1,
	"in": 0.1, "on": 0.1, "at": 0.1, "by": 0.1, "with": 0.1,
	"that": 0.1, "this": 0.1, "these": 0.1, "those": 0.1, "it": 0.1
}

# ----- VARIABLES -----
var divine_word_processor = null
var reality_data_processor = null
var memory_investment_system = null

# Storage for original text and generated summaries
var original_text = ""
var token_count = 0
var char_count = 0
var sentences = []
var paragraphs = []
var sentence_importance = {}
var summary_by_dimension = {}
var current_algorithm = "hybrid"
var current_max_tokens = MAX_TOKEN_COUNT
var processing_start_time = 0
var processing_end_time = 0

# ----- SIGNALS -----
signal processing_started(text_length, token_count)
signal dimension_summary_completed(dimension, summary_length, token_count)
signal processing_completed(total_time, summary_count)
signal summary_extracted(level, token_count)

# ----- INITIALIZATION -----
func _ready():
	print("TextSummarizationSystem initializing...")
	
	# Connect to other systems if available
	connect_to_divine_word_processor()
	connect_to_reality_data_processor()
	connect_to_memory_investment_system()
	
	print("TextSummarizationSystem ready!")
	print("Max token capacity: " + str(MAX_TOKEN_COUNT))
	print("Available algorithms: " + str(SUMMARIZATION_ALGORITHMS.keys()))

# ----- PUBLIC API -----

# Main function to generate comprehensive summary
func generate_summary(text, max_tokens = MAX_TOKEN_COUNT, algorithm = "hybrid"):
	# Reset data
	original_text = text
	current_algorithm = algorithm
	current_max_tokens = min(max_tokens, MAX_TOKEN_COUNT)
	summary_by_dimension = {}
	
	# Start timer
	processing_start_time = OS.get_unix_time()
	
	# Pre-process text
	token_count = estimate_token_count(text)
	char_count = text.length()
	
	print("Processing text with " + str(token_count) + " tokens (" + str(char_count) + " characters)")
	emit_signal("processing_started", char_count, token_count)
	
	# Break text into paragraphs and sentences
	paragraphs = split_into_paragraphs(text)
	sentences = split_into_sentences(text)
	
	# Calculate importance for each sentence
	sentence_importance = calculate_sentence_importance(sentences)
	
	# Generate multi-level summary based on selected algorithm
	match algorithm:
		"extractive":
			_generate_extractive_summary()
		"abstractive":
			_generate_abstractive_summary()
		"hybrid":
			_generate_hybrid_summary()
		"dimensional":
			_generate_dimensional_summary()
		_:
			# Default to hybrid
			_generate_hybrid_summary()
	
	# End timer
	processing_end_time = OS.get_unix_time()
	var processing_time = processing_end_time - processing_start_time
	
	# Emit completion signal
	emit_signal("processing_completed", processing_time, summary_by_dimension.size())
	
	print("Summary generation completed in " + str(processing_time) + " seconds")
	print("Generated " + str(summary_by_dimension.size()) + " summary levels")
	
	return summary_by_dimension

# Get a specific dimension's summary
func get_dimension_summary(dimension):
	if summary_by_dimension.has(dimension):
		return summary_by_dimension[dimension]
	return ""

# Get all summaries as a single text with headers
func get_combined_summary():
	var combined = ""
	
	# Start with quantum (most abstract) and move to physical (most detailed)
	var dimensions = ["quantum", "conceptual", "temporal", "digital", "physical"]
	
	for dimension in dimensions:
		if summary_by_dimension.has(dimension):
			combined += "# " + dimension.capitalize() + " Summary\n\n"
			combined += summary_by_dimension[dimension]
			combined += "\n\n---\n\n"
	
	return combined.strip_edges()

# Get a specific summary level by number (1=most abstract, 5=most detailed)
func get_summary_level(level):
	var dimensions = ["quantum", "conceptual", "temporal", "digital", "physical"]
	var index = clamp(level - 1, 0, dimensions.size() - 1)
	
	return get_dimension_summary(dimensions[index])

# Get a flexible summary constrained to token count
func get_flexible_summary(max_tokens):
	# Calculate how many dimensions we can include
	var dimensions = ["physical", "digital", "temporal", "conceptual", "quantum"]
	var tokens_used = 0
	var combined = ""
	
	# Start with quantum (most abstract)
	for dimension in ["quantum", "conceptual", "temporal", "digital", "physical"]:
		if summary_by_dimension.has(dimension):
			var summary = summary_by_dimension[dimension]
			var summary_tokens = estimate_token_count(summary)
			
			# Check if adding this would exceed the max
			if tokens_used + summary_tokens <= max_tokens:
				if combined.length() > 0:
					combined += "\n\n---\n\n"
				combined += "# " + dimension.capitalize() + " Summary\n\n"
				combined += summary
				tokens_used += summary_tokens
			else:
				# Try to include a truncated version if it's the first section
				if tokens_used == 0:
					var truncated = truncate_text_to_tokens(summary, max_tokens)
					combined += "# " + dimension.capitalize() + " Summary\n\n"
					combined += truncated
					break
				else:
					# Skip if we've already included some content
					break
	
	return combined

# Split text into paragraphs
func split_into_paragraphs(text):
	# Split by double newlines
	var split_text = text.split("\n\n", false)
	var result = []
	
	# Clean up paragraphs and filter empty ones
	for paragraph in split_text:
		paragraph = paragraph.strip_edges()
		if paragraph.length() > 0:
			# Also handle single newlines that might indicate paragraphs
			var single_line_paragraphs = paragraph.split("\n", false)
			for line in single_line_paragraphs:
				line = line.strip_edges()
				if line.length() > 0:
					result.append(line)
	
	return result

# Split text into sentences
func split_into_sentences(text):
	var sentence_delimiters = [". ", "! ", "? ", ".\n", "!\n", "?\n"]
	var result = []
	var current_text = text
	var current_sentence = ""
	
	# Handle edge cases for common abbreviations
	current_text = current_text.replace("Mr.", "Mr\u200B.") # Insert zero-width space
	current_text = current_text.replace("Mrs.", "Mrs\u200B.")
	current_text = current_text.replace("Dr.", "Dr\u200B.")
	current_text = current_text.replace("Ph.D.", "PhD")
	current_text = current_text.replace("i.e.", "ie")
	current_text = current_text.replace("e.g.", "eg")
	
	# Find sentence boundaries
	var pos = 0
	while pos < current_text.length():
		var next_delimiter_pos = current_text.length()
		var found_delimiter = ""
		
		# Find the next delimiter
		for delimiter in sentence_delimiters:
			var delimiter_pos = current_text.find(delimiter, pos)
			if delimiter_pos != -1 and delimiter_pos < next_delimiter_pos:
				next_delimiter_pos = delimiter_pos
				found_delimiter = delimiter
		
		# Extract the sentence
		if found_delimiter != "":
			var sentence = current_text.substr(pos, next_delimiter_pos - pos + 1)
			sentence = sentence.strip_edges()
			
			# Only add if it's a valid sentence
			if is_valid_sentence(sentence):
				result.append(sentence)
			
			# Move past the delimiter
			pos = next_delimiter_pos + found_delimiter.length()
		else:
			# Last sentence may not have a delimiter
			var last_sentence = current_text.substr(pos).strip_edges()
			if is_valid_sentence(last_sentence):
				result.append(last_sentence)
			break
	
	# Restore abbreviations
	for i in range(result.size()):
		result[i] = result[i].replace("Mr\u200B.", "Mr.")
		result[i] = result[i].replace("Mrs\u200B.", "Mrs.")
		result[i] = result[i].replace("Dr\u200B.", "Dr.")
	
	return result

# Validate if text is a proper sentence
func is_valid_sentence(text):
	if text.empty():
		return false
	
	# Count words (rough estimate)
	var words = text.split(" ", false)
	if words.size() < MIN_SENTENCE_LENGTH:
		# Short phrases might not be complete sentences
		# Check if it ends with punctuation
		var last_char = text[text.length() - 1]
		if last_char != "." and last_char != "!" and last_char != "?":
			return false
	
	return true

# Estimate token count from text
func estimate_token_count(text):
	if text.empty():
		return 0
	
	# Approximate token count based on character count
	# This is a rough estimate as actual tokenization is more complex
	return int(text.length() / TOKEN_AVG_CHARS)

# Truncate text to fit token count
func truncate_text_to_tokens(text, max_tokens):
	if estimate_token_count(text) <= max_tokens:
		return text
	
	# Split into sentences
	var text_sentences = split_into_sentences(text)
	var result = ""
	var current_tokens = 0
	
	for sentence in text_sentences:
		var sentence_tokens = estimate_token_count(sentence)
		
		# Check if adding this sentence would exceed max tokens
		if current_tokens + sentence_tokens <= max_tokens:
			if result.length() > 0:
				result += " "
			result += sentence
			current_tokens += sentence_tokens
		else:
			break
	
	return result

# Calculate importance score for each sentence
func calculate_sentence_importance(sentence_list):
	var importance = {}
	var max_length = 0
	var title_bonus = 0.3
	var conclusion_bonus = 0.25
	var word_frequency = {}
	
	# First pass - find max length and word frequency
	for sentence in sentence_list:
		max_length = max(max_length, sentence.length())
		
		# Count word frequency
		var words = sentence.to_lower().split(" ", false)
		for word in words:
			# Clean word of punctuation
			word = word.replace(",", "").replace(".", "").replace("!", "").replace("?", "")
			if word.length() > 0:
				if not word_frequency.has(word):
					word_frequency[word] = 0
				word_frequency[word] += 1
	
	# Second pass - calculate importance scores
	for i in range(sentence_list.size()):
		var sentence = sentence_list[i]
		var words = sentence.to_lower().split(" ", false)
		var score = 0.0
		
		# Position bonus
		var position_score = 0.0
		if i == 0:
			# First sentence often contains the main point
			position_score = title_bonus
		elif i == sentence_list.size() - 1:
			# Last sentence often contains conclusion
			position_score = conclusion_bonus
		else:
			# Gradually reducing importance for middle sentences
			position_score = 0.2 * (1.0 - float(i) / sentence_list.size())
		
		# Word importance score
		var word_score = 0.0
		var important_word_count = 0
		
		for word in words:
			# Clean word
			word = word.to_lower().replace(",", "").replace(".", "").replace("!", "").replace("?", "")
			
			# Check if it's in our importance dictionary
			if word_importance_dictionary.has(word):
				word_score += word_importance_dictionary[word]
				if word_importance_dictionary[word] > 0.5:
					important_word_count += 1
			
			# Add additional score based on frequency (rarer words = more important)
			if word_frequency.has(word) and word_frequency[word] < sentence_list.size() * 0.2:
				word_score += 0.2
		
		# Normalize word score
		if words.size() > 0:
			word_score = word_score / words.size()
		
		# Length score - favor medium length sentences
		var length_factor = 1.0 - abs((sentence.length() / max_length) - 0.5)
		
		# Important word density
		var density_score = float(important_word_count) / max(words.size(), 1)
		
		# Calculate final score with weights
		score = position_score * 0.3 + word_score * 0.4 + length_factor * 0.1 + density_score * 0.2
		
		# Apply divine word processor influence if available
		if divine_word_processor:
			var divine_words = _find_divine_words(sentence)
			if divine_words.size() > 0:
				score += 0.2
		
		# Store score
		importance[sentence] = clamp(score, 0.0, 1.0)
	
	return importance

# Connect to other systems
func connect_to_divine_word_processor():
	if ClassDB.class_exists("DivineWordProcessor"):
		divine_word_processor = DivineWordProcessor.new()
		add_child(divine_word_processor)
		print("Connected to DivineWordProcessor")
		return true
	
	# Try to find existing instance
	if has_node("/root/DivineWordProcessor") or get_node_or_null("/root/DivineWordProcessor"):
		divine_word_processor = get_node("/root/DivineWordProcessor")
		print("Connected to existing DivineWordProcessor")
		return true
	
	return false

func connect_to_reality_data_processor():
	if ClassDB.class_exists("RealityDataProcessor"):
		reality_data_processor = RealityDataProcessor.new()
		add_child(reality_data_processor)
		print("Connected to RealityDataProcessor")
		return true
	
	# Try to find existing instance
	if has_node("/root/RealityDataProcessor") or get_node_or_null("/root/RealityDataProcessor"):
		reality_data_processor = get_node("/root/RealityDataProcessor")
		print("Connected to existing RealityDataProcessor")
		return true
	
	return false

func connect_to_memory_investment_system():
	if ClassDB.class_exists("MemoryInvestmentSystem"):
		memory_investment_system = MemoryInvestmentSystem.new()
		add_child(memory_investment_system)
		print("Connected to MemoryInvestmentSystem")
		return true
	
	# Try to find existing instance
	if has_node("/root/MemoryInvestmentSystem") or get_node_or_null("/root/MemoryInvestmentSystem"):
		memory_investment_system = get_node("/root/MemoryInvestmentSystem")
		print("Connected to existing MemoryInvestmentSystem")
		return true
	
	return false

# ----- IMPLEMENTATION METHODS -----

# Generate using extractive algorithm
func _generate_extractive_summary():
	# For each dimension, extract sentences based on importance thresholds
	for dimension in REALITY_DIMENSIONS:
		var threshold = REALITY_DIMENSIONS[dimension].importance_threshold
		var tokens_target = current_max_tokens * REALITY_DIMENSIONS[dimension].token_ratio
		
		var selected_sentences = []
		var current_tokens = 0
		
		# First select sentences above threshold
		for sentence in sentences:
			if sentence_importance[sentence] >= threshold:
				selected_sentences.append(sentence)
				current_tokens += estimate_token_count(sentence)
		
		# If we have too many sentences, sort by importance and take top ones
		if current_tokens > tokens_target:
			selected_sentences.sort_custom(self, "_sort_by_importance")
			
			var pruned_sentences = []
			current_tokens = 0
			
			for sentence in selected_sentences:
				var sentence_tokens = estimate_token_count(sentence)
				if current_tokens + sentence_tokens <= tokens_target:
					pruned_sentences.append(sentence)
					current_tokens += sentence_tokens
				else:
					break
			
			selected_sentences = pruned_sentences
		
		# Reorder sentences to maintain original sequence
		selected_sentences.sort_custom(self, "_sort_by_original_order")
		
		# Join sentences and store the summary
		summary_by_dimension[dimension] = _join_sentences(selected_sentences)
		
		# Emit signal
		emit_signal("dimension_summary_completed", dimension, summary_by_dimension[dimension].length(), current_tokens)
	
	# Also generate a combined summary that fits in max tokens
	summary_by_dimension["combined"] = get_flexible_summary(current_max_tokens)

# Generate using abstractive algorithm
func _generate_abstractive_summary():
	# Since we can't actually generate new text without NLP,
	# we'll simulate abstractive summarization by extracting key phrases
	# and restructuring them with transitional phrases
	
	for dimension in REALITY_DIMENSIONS:
		var threshold = REALITY_DIMENSIONS[dimension].importance_threshold
		var tokens_target = current_max_tokens * REALITY_DIMENSIONS[dimension].token_ratio
		var detail_level = REALITY_DIMENSIONS[dimension].detail_level
		
		# For abstractive, we first extract key sentences
		var key_sentences = []
		for sentence in sentences:
			if sentence_importance[sentence] >= threshold:
				key_sentences.append(sentence)
		
		# Sort by importance
		key_sentences.sort_custom(self, "_sort_by_importance")
		
		# Keep only top percentage based on detail level
		var keep_count = int(key_sentences.size() * detail_level)
		key_sentences = key_sentences.slice(0, keep_count - 1)
		
		# Now extract key phrases and concepts from these sentences
		var key_concepts = _extract_key_concepts(key_sentences)
		
		# Build abstractive summary using key concepts and transitional phrases
		var summary = _build_abstractive_summary(key_concepts, dimension, tokens_target)
		
		# Store the summary
		summary_by_dimension[dimension] = summary
		
		# Emit signal
		emit_signal("dimension_summary_completed", dimension, summary.length(), estimate_token_count(summary))
	
	# Also generate a combined summary that fits in max tokens
	summary_by_dimension["combined"] = get_flexible_summary(current_max_tokens)

# Generate using hybrid algorithm
func _generate_hybrid_summary():
	# Hybrid approach combines extractive and abstractive techniques
	
	for dimension in REALITY_DIMENSIONS:
		var threshold = REALITY_DIMENSIONS[dimension].importance_threshold
		var tokens_target = current_max_tokens * REALITY_DIMENSIONS[dimension].token_ratio
		var detail_level = REALITY_DIMENSIONS[dimension].detail_level
		
		# Extract important sentences (extractive component)
		var key_sentences = []
		for sentence in sentences:
			if sentence_importance[sentence] >= threshold:
				key_sentences.append(sentence)
		
		# Sort by importance
		key_sentences.sort_custom(self, "_sort_by_importance")
		
		# For more abstract dimensions (conceptual, quantum), use more abstractive approach
		var abstractive_ratio = 0.0
		if dimension == "conceptual":
			abstractive_ratio = 0.7
		elif dimension == "quantum":
			abstractive_ratio = 0.9
		elif dimension == "temporal":
			abstractive_ratio = 0.5
		elif dimension == "digital":
			abstractive_ratio = 0.3
		elif dimension == "physical":
			abstractive_ratio = 0.1
		
		# Split token budget between extractive and abstractive components
		var extractive_tokens = tokens_target * (1.0 - abstractive_ratio)
		var abstractive_tokens = tokens_target * abstractive_ratio
		
		# Generate extractive component
		var extractive_sentences = []
		var current_tokens = 0
		
		for sentence in key_sentences:
			var sentence_tokens = estimate_token_count(sentence)
			if current_tokens + sentence_tokens <= extractive_tokens:
				extractive_sentences.append(sentence)
				current_tokens += sentence_tokens
		
		# Generate abstractive component if needed
		var abstractive_component = ""
		if abstractive_ratio > 0.0:
			var key_concepts = _extract_key_concepts(key_sentences)
			abstractive_component = _build_abstractive_summary(key_concepts, dimension, abstractive_tokens)
		
		# Combine components
		var summary = ""
		
		# For higher dimensions (more abstract), start with abstractive component
		if dimension == "quantum" or dimension == "conceptual":
			if abstractive_component.length() > 0:
				summary = abstractive_component + "\n\n"
			
			if current_tokens > 0:
				summary += _join_sentences(extractive_sentences)
		else:
			# For lower dimensions (more concrete), start with extractive component
			if current_tokens > 0:
				summary = _join_sentences(extractive_sentences)
			
			if abstractive_component.length() > 0:
				summary += "\n\n" + abstractive_component
		
		# Store the summary
		summary_by_dimension[dimension] = summary
		
		# Emit signal
		emit_signal("dimension_summary_completed", dimension, summary.length(), estimate_token_count(summary))
	
	# Also generate a combined summary that fits in max tokens
	summary_by_dimension["combined"] = get_flexible_summary(current_max_tokens)

# Generate using dimensional algorithm
func _generate_dimensional_summary():
	# Dimensional algorithm creates multi-layer summaries using reality dimensions
	
	# First, create a very abstract overview (quantum dimension)
	var quantum_threshold = REALITY_DIMENSIONS["quantum"].importance_threshold
	var quantum_tokens = current_max_tokens * REALITY_DIMENSIONS["quantum"].token_ratio
	
	var quantum_sentences = []
	for sentence in sentences:
		if sentence_importance[sentence] >= quantum_threshold:
			quantum_sentences.append(sentence)
	
	quantum_sentences.sort_custom(self, "_sort_by_importance")
	
	# Take only top 3-5 sentences for quantum level
	var quantum_count = min(5, quantum_sentences.size())
	var quantum_summary_sentences = quantum_sentences.slice(0, quantum_count - 1)
	
	# Generate quantum summary (most abstract)
	var quantum_concepts = _extract_key_concepts(quantum_summary_sentences)
	summary_by_dimension["quantum"] = _build_abstractive_summary(quantum_concepts, "quantum", quantum_tokens)
	
	# Now process each dimension with varying levels of detail
	for dimension in ["conceptual", "temporal", "digital", "physical"]:
		var threshold = REALITY_DIMENSIONS[dimension].importance_threshold
		var tokens_target = current_max_tokens * REALITY_DIMENSIONS[dimension].token_ratio
		
		# Each successive dimension builds on the previous one
		var prev_summary = ""
		if dimension == "conceptual":
			prev_summary = summary_by_dimension["quantum"]
		elif dimension == "temporal":
			prev_summary = summary_by_dimension["conceptual"]
		elif dimension == "digital":
			prev_summary = summary_by_dimension["temporal"]
		elif dimension == "physical":
			prev_summary = summary_by_dimension["digital"]
		
		# Extract sentences based on importance threshold
		var selected_sentences = []
		for sentence in sentences:
			if sentence_importance[sentence] >= threshold:
				selected_sentences.append(sentence)
		
		# Sort by importance
		selected_sentences.sort_custom(self, "_sort_by_importance")
		
		# Calculate remaining token budget after accounting for previous summary
		var prev_tokens = estimate_token_count(prev_summary)
		var remaining_tokens = tokens_target - prev_tokens
		
		# Select sentences that fit within token budget
		var current_tokens = 0
		var dimension_sentences = []
		
		for sentence in selected_sentences:
			var sentence_tokens = estimate_token_count(sentence)
			if current_tokens + sentence_tokens <= remaining_tokens:
				dimension_sentences.append(sentence)
				current_tokens += sentence_tokens
			else:
				break
		
		# Sort sentences by original order
		dimension_sentences.sort_custom(self, "_sort_by_original_order")
		
		# Build summary by expanding on previous dimension
		var summary = ""
		
		if dimension == "physical":
			# For physical (most detailed), use primarily extractive
			summary = _join_sentences(dimension_sentences)
		else:
			// Blend previous summary with new extracted content
			var dimension_summary = _join_sentences(dimension_sentences)
			
			// Apply dimension-specific connectors
			if dimension == "conceptual":
				summary = prev_summary + "\n\nFurther exploration reveals:\n" + dimension_summary
			elif dimension == "temporal":
				summary = prev_summary + "\n\nThe sequence of developments includes:\n" + dimension_summary
			elif dimension == "digital":
				summary = prev_summary + "\n\nKey information points include:\n" + dimension_summary
		}
		
		// Store the dimension summary
		summary_by_dimension[dimension] = summary
		
		// Emit signal
		emit_signal("dimension_summary_completed", dimension, summary.length(), estimate_token_count(summary))
	}
	
	// Create integrated dimensional summary
	summary_by_dimension["integrated"] = _create_integrated_dimensional_summary()
	
	// Also generate a combined summary that fits in max tokens
	summary_by_dimension["combined"] = get_flexible_summary(current_max_tokens)

# Create an integrated summary across all dimensions
func _create_integrated_dimensional_summary():
	var integrated = "# Multi-Dimensional Summary\n\n"
	
	# Add quantum (highest abstraction) summary
	if summary_by_dimension.has("quantum"):
		integrated += "## Core Essence\n\n"
		integrated += summary_by_dimension["quantum"] + "\n\n"
	
	# Add conceptual summary
	if summary_by_dimension.has("conceptual"):
		integrated += "## Key Concepts\n\n"
		integrated += summary_by_dimension["conceptual"] + "\n\n"
	
	# Add temporal summary
	if summary_by_dimension.has("temporal"):
		integrated += "## Sequential Development\n\n"
		integrated += summary_by_dimension["temporal"] + "\n\n"
	
	# Add digital summary
	if summary_by_dimension.has("digital"):
		integrated += "## Information Layer\n\n"
		integrated += summary_by_dimension["digital"] + "\n\n"
	
	# Add physical summary (most detailed)
	if summary_by_dimension.has("physical"):
		integrated += "## Detailed Analysis\n\n"
		integrated += summary_by_dimension["physical"]
	
	return integrated

# Extract key concepts from a list of sentences
func _extract_key_concepts(sentences):
	var concepts = []
	var word_count = {}
	
	# Count word frequency across important sentences
	for sentence in sentences:
		var words = sentence.to_lower().split(" ", false)
		
		for word in words:
			# Clean word
			word = word.replace(",", "").replace(".", "").replace("!", "").replace("?", "")
			
			if word.length() < 3 or word in ["the", "and", "but", "for", "with", "that", "this"]:
				continue
			
			if not word_count.has(word):
				word_count[word] = 0
			
			word_count[word] += 1
	
	# Find important concepts (words with high frequency)
	for word in word_count:
		if word_count[word] >= 2:  # Appears in at least 2 sentences
			concepts.append({
				"word": word,
				"frequency": word_count[word],
				"importance": 0.0
			})
	
	# Score concepts by importance
	for i in range(concepts.size()):
		var word = concepts[i].word
		
		# Check against importance dictionary
		if word_importance_dictionary.has(word):
			concepts[i].importance = word_importance_dictionary[word]
		else:
			# Base importance on frequency
			concepts[i].importance = 0.3 + min(0.6, concepts[i].frequency / 10.0)
		
		# Check if it's a divine word
		if divine_word_processor and divine_word_processor.word_power_dictionary.has(word):
			concepts[i].importance += 0.2
	
	# Sort by importance
	concepts.sort_custom(self, "_sort_concepts_by_importance")
	
	return concepts

# Build an abstractive summary from key concepts
func _build_abstractive_summary(concepts, dimension, token_budget):
	# Since we can't truly generate abstractive text, we'll construct 
	# a summary using templates and key concepts
	
	if concepts.size() == 0:
		return ""
	
	var summary = ""
	var tokens_used = 0
	var max_concepts = min(10, concepts.size())
	
	# Use different templates based on dimension
	match dimension:
		"quantum":
			summary = "At its core, this explores "
			
			# Add top concepts
			for i in range(min(3, concepts.size())):
				if i > 0:
					summary += i == concepts.size() - 1 or i == 2 ? " and " : ", "
				summary += concepts[i].word
			
			summary += ". The essential elements involve "
			
			# Add a few more concepts
			for i in range(3, min(5, concepts.size())):
				if i > 3:
					summary += i == concepts.size() - 1 or i == 4 ? " and " : ", "
				summary += concepts[i].word
			
			summary += "."
		
		"conceptual":
			summary = "The key concepts encompass "
			
			# Add top concepts
			for i in range(min(4, concepts.size())):
				if i > 0:
					summary += i == concepts.size() - 1 or i == 3 ? " and " : ", "
				summary += concepts[i].word
			
			summary += ". These ideas relate to "
			
			# Add a few more concepts
			for i in range(4, min(8, concepts.size())):
				if i > 4:
					summary += i == concepts.size() - 1 or i == 7 ? " and " : ", "
				summary += concepts[i].word
			
			summary += "."
		
		"temporal":
			summary = "The progression begins with "
			
			# Add concepts as a sequence
			for i in range(min(6, concepts.size())):
				if i > 0:
					summary += ", followed by "
				summary += concepts[i].word
				
				if i == 4:  # Break after 5 elements
					summary += ". The sequence continues with "
			
			summary += ", ultimately culminating in the relationship between "
			
			# Add final concepts
			for i in range(6, min(8, concepts.size())):
				if i > 6:
					summary += " and "
				summary += concepts[i].word
			
			summary += "."
		
		"digital":
			summary = "The key information points include "
			
			# Add concepts as data points
			for i in range(min(max_concepts, concepts.size())):
				if i > 0:
					summary += i == concepts.size() - 1 or i == max_concepts - 1 ? " and " : ", "
				summary += concepts[i].word
			
			summary += ". These elements form the structured data representation."
		
		"physical":
			summary = "The concrete details incorporate "
			
			# Add concepts as physical elements
			for i in range(min(max_concepts, concepts.size())):
				if i > 0:
					summary += i == concepts.size() - 1 or i == max_concepts - 1 ? " and " : ", "
				summary += concepts[i].word
			
			summary += ". These represent the most tangible aspects."
	
	# Check if we're within token budget
	tokens_used = estimate_token_count(summary)
	if tokens_used > token_budget:
		# Truncate if necessary
		summary = truncate_text_to_tokens(summary, token_budget)
	
	return summary

# Join sentences into paragraphs
func _join_sentences(sentence_list):
	if sentence_list.empty():
		return ""
	
	var result = ""
	var paragraph_sentences = []
	var sentence_count = 0
	
	for sentence in sentence_list:
		paragraph_sentences.append(sentence)
		sentence_count += 1
		
		# Create a new paragraph every 3-5 sentences
		if sentence_count >= 3 and (sentence_count >= 5 or randf() > 0.7):
			result += _join_paragraph(paragraph_sentences) + "\n\n"
			paragraph_sentences = []
			sentence_count = 0
	
	# Add any remaining sentences
	if not paragraph_sentences.empty():
		result += _join_paragraph(paragraph_sentences)
	
	return result.strip_edges()

# Join sentences into a single paragraph
func _join_paragraph(sentence_list):
	var result = ""
	
	for i in range(sentence_list.size()):
		var sentence = sentence_list[i]
		
		# Make sure sentence ends with proper punctuation
		var last_char = sentence[sentence.length() - 1]
		if last_char != "." and last_char != "!" and last_char != "?":
			sentence += "."
		
		# Add to result
		result += sentence
		
		# Add space after sentence if not the last one
		if i < sentence_list.size() - 1:
			result += " "
	
	return result

# Find divine words in a sentence
func _find_divine_words(sentence):
	var divine_words = []
	
	# Only proceed if divine word processor is available
	if not divine_word_processor:
		return divine_words
	
	# Extract words
	var words = sentence.to_lower().split(" ", false)
	
	for word in words:
		# Clean word
		word = word.replace(",", "").replace(".", "").replace("!", "").replace("?", "")
		
		# Check if it's a divine word
		if divine_word_processor.word_power_dictionary.has(word):
			divine_words.append(word)
	
	return divine_words

# Sort sentences by importance (higher first)
func _sort_by_importance(a, b):
	return sentence_importance[a] > sentence_importance[b]

# Sort sentences by original order
func _sort_by_original_order(a, b):
	return sentences.find(a) < sentences.find(b)

# Sort concepts by importance
func _sort_concepts_by_importance(a, b):
	return a.importance > b.importance