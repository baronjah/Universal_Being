extends Node

class_name TokenAnalyzer

# Token Analyzer
# Breaks down file content into tokens for analysis and matching

# Different tokenization strategies
enum TokenStrategy {
	CODE_TOKENS,       # Tokenizes code with awareness of programming syntax
	NATURAL_LANGUAGE,  # Tokenizes natural language text
	SEMANTIC_TOKENS,   # Creates semantic token representations (concepts)
	VARIABLE_NAMES,    # Focuses on extracting variable names
	FUNCTION_NAMES     # Focuses on extracting function names
}

# Token type classifications
enum TokenType {
	KEYWORD,           # Language keywords
	IDENTIFIER,        # Variable, function, class names
	OPERATOR,          # Operators
	STRING_LITERAL,    # String literals
	NUMBER_LITERAL,    # Number literals
	COMMENT,           # Comments
	PUNCTUATION,       # Punctuation
	UNKNOWN            # Unclassified tokens
}

# Token data structure
class Token:
	var text: String
	var type: int
	var line: int
	var column: int
	var source_file: String
	var context: String
	
	func _init(p_text, p_type = TokenType.UNKNOWN, p_line = -1, p_column = -1, p_source = "", p_context = ""):
		text = p_text
		type = p_type
		line = p_line
		column = p_column
		source_file = p_source
		context = p_context
	
	func to_string():
		return text + " (" + str(type) + ") at line " + str(line)

# Default stop words for tokenization
var stop_words = [
	"the", "a", "an", "and", "or", "but", "if", "then", "else", "when", "at", "from", "by", "on", "off",
	"for", "in", "to", "with", "is", "are", "was", "were", "be", "been", "being",
	"have", "has", "had", "do", "does", "did", "will", "would", "shall", "should",
	"can", "could", "may", "might", "must", "var", "func", "class", "extends", "return"
]

# Common keywords in various languages
var code_keywords = {
	"gdscript": [
		"if", "elif", "else", "for", "while", "match", "break", "continue", "pass",
		"return", "class", "extends", "func", "var", "const", "enum", "static", "export",
		"onready", "tool", "signal", "self", "null", "true", "false"
	],
	"common": [
		"if", "else", "for", "while", "return", "break", "continue", "function", "var",
		"let", "const", "class", "this", "new", "import", "export", "true", "false", "null"
	]
}

# File cache
var file_token_cache = {}

# Tokenize a file using the specified strategy
func tokenize_file(file_path, strategy = TokenStrategy.CODE_TOKENS):
	# Check cache first
	var cache_key = file_path + str(strategy)
	if file_token_cache.has(cache_key):
		return file_token_cache[cache_key]
	
	# Read file content
	var file = File.new()
	if not file.file_exists(file_path):
		push_error("File not found: " + file_path)
		return []
	
	if file.open(file_path, File.READ) != OK:
		push_error("Could not open file: " + file_path)
		return []
	
	var content = file.get_as_text()
	file.close()
	
	# Tokenize content
	var tokens = tokenize_content(content, strategy, file_path)
	
	# Cache result
	file_token_cache[cache_key] = tokens
	
	return tokens

# Tokenize content string using the specified strategy
func tokenize_content(content, strategy = TokenStrategy.CODE_TOKENS, source_file = ""):
	var tokens = []
	
	match strategy:
		TokenStrategy.CODE_TOKENS:
			tokens = _tokenize_code(content, source_file)
		TokenStrategy.NATURAL_LANGUAGE:
			tokens = _tokenize_natural_language(content, source_file)
		TokenStrategy.SEMANTIC_TOKENS:
			tokens = _tokenize_semantic(content, source_file)
		TokenStrategy.VARIABLE_NAMES:
			tokens = _extract_variable_names(content, source_file)
		TokenStrategy.FUNCTION_NAMES:
			tokens = _extract_function_names(content, source_file)
	
	return tokens

# Find similar tokens between two token lists
func find_similar_tokens(tokens1, tokens2, threshold = 0.7):
	var similarities = []
	
	# Convert tokens to text for comparison
	var text_tokens1 = tokens_to_text_array(tokens1)
	var text_tokens2 = tokens_to_text_array(tokens2)
	
	# Find similar tokens
	for i in range(text_tokens1.size()):
		for j in range(text_tokens2.size()):
			var similarity = calculate_string_similarity(text_tokens1[i], text_tokens2[j])
			
			if similarity >= threshold:
				similarities.append({
					"token1": tokens1[i],
					"token2": tokens2[j],
					"similarity": similarity
				})
	
	# Sort by similarity (highest first)
	similarities.sort_custom(self, "_sort_by_similarity")
	
	return similarities

# Calculate token similarity to a pattern
func calculate_token_pattern_similarity(token, pattern):
	if pattern is String:
		# Simple string pattern
		return calculate_string_similarity(token.text, pattern)
	elif pattern is Dictionary:
		# Complex pattern with type and text
		var type_match = pattern.has("type") and token.type == pattern.type
		var text_similarity = calculate_string_similarity(token.text, pattern.text)
		
		# Weight type match higher
		return text_similarity * (1.5 if type_match else 1.0)
	
	return 0.0

# Calculate string similarity (0.0-1.0)
func calculate_string_similarity(str1, str2):
	if str1 == str2:
		return 1.0
	
	if str1.empty() or str2.empty():
		return 0.0
	
	# Convert to lowercase for comparison
	str1 = str1.to_lower()
	str2 = str2.to_lower()
	
	# Simple Levenshtein distance implementation
	var m = str1.length() + 1
	var n = str2.length() + 1
	
	var matrix = []
	for i in range(m):
		var row = []
		for j in range(n):
			row.append(0)
		matrix.append(row)
	
	for i in range(m):
		matrix[i][0] = i
	
	for j in range(n):
		matrix[0][j] = j
	
	for j in range(1, n):
		for i in range(1, m):
			var substitution_cost = 0 if str1[i-1] == str2[j-1] else 1
			
			matrix[i][j] = min(
				matrix[i-1][j] + 1,                  # Deletion
				matrix[i][j-1] + 1,                  # Insertion
				matrix[i-1][j-1] + substitution_cost # Substitution
			)
	
	# Normalize to 0.0-1.0 range
	var max_length = max(str1.length(), str2.length())
	if max_length == 0:
		return 1.0  # Both strings are empty
		
	return 1.0 - (float(matrix[m-1][n-1]) / float(max_length))

# Extract common tokens between two token lists
func extract_common_tokens(tokens1, tokens2):
	var common_tokens = []
	var text_tokens1 = tokens_to_text_array(tokens1)
	var text_tokens2 = tokens_to_text_array(tokens2)
	
	for i in range(text_tokens1.size()):
		if text_tokens2.has(text_tokens1[i]):
			common_tokens.append(tokens1[i])
	
	return common_tokens

# Analyze a file for specific token patterns
func analyze_file_tokens(file_path, patterns, strategy = TokenStrategy.CODE_TOKENS):
	var tokens = tokenize_file(file_path, strategy)
	var matches = []
	
	for pattern in patterns:
		var pattern_matches = []
		
		for token in tokens:
			var similarity = calculate_token_pattern_similarity(token, pattern)
			if similarity >= pattern.get("threshold", 0.7):
				pattern_matches.append({
					"token": token,
					"similarity": similarity
				})
		
		if not pattern_matches.empty():
			matches.append({
				"pattern": pattern,
				"matches": pattern_matches
			})
	
	return matches

# Convert tokens to a simple text array
func tokens_to_text_array(tokens):
	var text_array = []
	
	for token in tokens:
		text_array.append(token.text)
	
	return text_array

# Implementation-specific methods

func _tokenize_code(content, source_file):
	var tokens = []
	var lines = content.split("\n")
	
	# Simple regex patterns for tokenization
	var patterns = {
		"identifier": "\\b[a-zA-Z_][a-zA-Z0-9_]*\\b",
		"string": "\"[^\"]*\"|'[^']*'",
		"number": "\\b\\d+(\\.\\d+)?\\b",
		"operator": "[\\+\\-\\*\\/\\=\\<\\>\\!\\&\\|\\^\\~\\%]+",
		"punctuation": "[\\(\\)\\[\\]\\{\\}\\,\\.\\;\\:']"
	}
	
	# Compile regexes
	var regexes = {}
	for key in patterns:
		var regex = RegEx.new()
		regex.compile(patterns[key])
		regexes[key] = regex
	
	# Determine language from file extension
	var language = "common"
	if source_file.ends_with(".gd"):
		language = "gdscript"
	
	# Process each line
	for line_num in range(lines.size()):
		var line = lines[line_num]
		var current_pos = 0
		
		while current_pos < line.length():
			var smallest_start = line.length()
			var best_match = null
			var match_type = ""
			
			# Find the earliest match
			for key in regexes:
				var matches = regexes[key].search_all(line, current_pos)
				
				for regex_match in matches:
					if regex_match.get_start() < smallest_start and regex_match.get_start() == current_pos:
						smallest_start = regex_match.get_start()
						best_match = regex_match
						match_type = key
						break
				
				if smallest_start == current_pos:
					break
			
			if best_match:
				var token_text = best_match.get_string()
				var token_type = TokenType.UNKNOWN
				
				match match_type:
					"identifier":
						# Check if it's a keyword
						if code_keywords[language].has(token_text):
							token_type = TokenType.KEYWORD
						else:
							token_type = TokenType.IDENTIFIER
					"string":
						token_type = TokenType.STRING_LITERAL
					"number":
						token_type = TokenType.NUMBER_LITERAL
					"operator":
						token_type = TokenType.OPERATOR
					"punctuation":
						token_type = TokenType.PUNCTUATION
				
				# Create token
				var token = Token.new(
					token_text,
					token_type,
					line_num + 1,
					best_match.get_start() + 1,
					source_file,
					line.strip_edges()
				)
				
				tokens.append(token)
				
				# Move past this token
				current_pos = best_match.get_end()
			else:
				# No match found, skip this character
				current_pos += 1
	
	return tokens

func _tokenize_natural_language(content, source_file):
	var tokens = []
	
	# Remove special characters
	var cleaned_content = content.replace("\n", " ").replace("\t", " ")
	
	# Replace punctuation with spaces
	var punctuation = ".,;:!?()[]{}<>\"'`-+*/\\|@#$%^&="
	for p in punctuation:
		cleaned_content = cleaned_content.replace(p, " ")
	
	# Split by whitespace
	var words = cleaned_content.split(" ", false)
	var line_num = 1
	var column = 1
	
	for word in words:
		word = word.strip_edges().to_lower()
		
		if not word.empty() and not stop_words.has(word):
			var token = Token.new(
				word,
				TokenType.IDENTIFIER,
				line_num,
				column,
				source_file
			)
			
			tokens.append(token)
		
		column += word.length() + 1
	
	return tokens

func _tokenize_semantic(content, source_file):
	# First get regular tokens
	var base_tokens = _tokenize_natural_language(content, source_file)
	var semantic_tokens = []
	
	# Identify multi-word semantic tokens (up to 3 words)
	for i in range(base_tokens.size()):
		# Single word
		semantic_tokens.append(base_tokens[i])
		
		# Two words
		if i < base_tokens.size() - 1:
			var two_word = base_tokens[i].text + "_" + base_tokens[i+1].text
			var two_word_token = Token.new(
				two_word,
				TokenType.IDENTIFIER,
				base_tokens[i].line,
				base_tokens[i].column,
				source_file
			)
			semantic_tokens.append(two_word_token)
		
		# Three words
		if i < base_tokens.size() - 2:
			var three_word = base_tokens[i].text + "_" + base_tokens[i+1].text + "_" + base_tokens[i+2].text
			var three_word_token = Token.new(
				three_word,
				TokenType.IDENTIFIER,
				base_tokens[i].line,
				base_tokens[i].column,
				source_file
			)
			semantic_tokens.append(three_word_token)
	
	return semantic_tokens

func _extract_variable_names(content, source_file):
	var tokens = []
	var lines = content.split("\n")
	
	# Pattern for variable declarations
	var var_patterns = [
		# GDScript var declarations
		"\\bvar\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\b",
		# GDScript export var declarations
		"\\bexport\\s+var\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\b",
		# GDScript onready var declarations
		"\\bonready\\s+var\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\b",
		# GDScript const declarations
		"\\bconst\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\b"
	]
	
	# Compile regexes
	var regexes = []
	for pattern in var_patterns:
		var regex = RegEx.new()
		regex.compile(pattern)
		regexes.append(regex)
	
	# Process each line
	for line_num in range(lines.size()):
		var line = lines[line_num]
		
		for regex in regexes:
			var matches = regex.search_all(line)
			
			for regex_match in matches:
				if regex_match.get_group_count() >= 1:
					var var_name = regex_match.get_string(1)
					
					var token = Token.new(
						var_name,
						TokenType.IDENTIFIER,
						line_num + 1,
						regex_match.get_start() + 1,
						source_file,
						line.strip_edges()
					)
					
					tokens.append(token)
	
	return tokens

func _extract_function_names(content, source_file):
	var tokens = []
	var lines = content.split("\n")
	
	# Pattern for function declarations
	var func_pattern = "\\bfunc\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\("
	
	# Compile regex
	var regex = RegEx.new()
	regex.compile(func_pattern)
	
	# Process each line
	for line_num in range(lines.size()):
		var line = lines[line_num]
		var matches = regex.search_all(line)
		
		for regex_match in matches:
			if regex_match.get_group_count() >= 1:
				var func_name = regex_match.get_string(1)
				
				var token = Token.new(
					func_name,
					TokenType.IDENTIFIER,
					line_num + 1,
					regex_match.get_start() + 1,
					source_file,
					line.strip_edges()
				)
				
				tokens.append(token)
	
	return tokens

func _sort_by_similarity(a, b):
	return a.similarity > b.similarity

# Clear token cache
func clear_cache():
	file_token_cache.clear()

# Analyze token frequencies in content
func analyze_token_frequencies(content, strategy = TokenStrategy.CODE_TOKENS):
	var tokens = tokenize_content(content, strategy)
	var frequencies = {}
	
	for token in tokens:
		var text = token.text.to_lower()
		if not frequencies.has(text):
			frequencies[text] = 0
		frequencies[text] += 1
	
	return frequencies