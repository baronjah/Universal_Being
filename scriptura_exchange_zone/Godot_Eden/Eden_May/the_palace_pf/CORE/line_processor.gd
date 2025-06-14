extends Node

# Line Processor for Eden_May Game
# Processes text input line by line based on Turn 8 patterns

class_name LineProcessor

# Line patterns (from Turn 8)
var patterns = {
	"parallel": {
		"power": 8,
		"alignment": "horizontal",
		"temporal_reach": "wide",
		"description": "Independent lines that run alongside each other",
		"markers": ["\n\n", "- ", "* ", "1. ", "2. "]
	},
	"intersecting": {
		"power": 4,
		"alignment": "cross",
		"temporal_reach": "focused",
		"description": "Lines that cross and intersect with each other",
		"markers": ["|", "+", "table", "grid", "cross"]
	},
	"spiral": {
		"power": 7,
		"alignment": "circular",
		"temporal_reach": "expanding",
		"description": "Lines that curve and spiral outward or inward",
		"markers": ["@", "spiral", "circle", "curve", "loop"]
	},
	"fractal": {
		"power": 9,
		"alignment": "recursive",
		"temporal_reach": "infinite",
		"description": "Lines that divide and repeat in self-similar patterns",
		"markers": ["  ", "\t", "{", "}", "nested"]
	}
}

# Current state
var current_pattern = "parallel"
var active_turn = 8
var processing_enabled = true
var line_history = []
var pattern_stats = {
	"parallel": 0,
	"intersecting": 0,
	"spiral": 0,
	"fractal": 0
}

# References to other systems
var word_manager = null

signal line_processed(result)
signal pattern_detected(pattern_name)

func _init():
	print("Line Processor initialized")
	print("Current pattern: " + current_pattern)

func _ready():
	# Try to get reference to word manager
	if get_parent() and get_parent().has_node("WordManager"):
		word_manager = get_parent().get_node("WordManager")
		print("Connected to Word Manager")

func set_word_manager(manager):
	word_manager = manager
	print("Word Manager connection established")

func process_line(text, detect_pattern=true):
	if not processing_enabled or text.strip_edges() == "":
		return null
		
	# Store original text
	var original_text = text
	
	# Detect pattern if requested
	var used_pattern = current_pattern
	if detect_pattern:
		used_pattern = detect_line_pattern(text)
		if used_pattern != current_pattern:
			print("Detected new pattern: " + used_pattern)
			emit_signal("pattern_detected", used_pattern)
			current_pattern = used_pattern
	
	# Update pattern stats
	pattern_stats[used_pattern] += 1
	
	# Process based on pattern
	var result = {
		"original": original_text,
		"processed": "",
		"pattern": used_pattern,
		"words": [],
		"turn": active_turn,
		"timestamp": OS.get_unix_time()
	}
	
	# Apply the pattern processing
	result.processed = apply_pattern(text, used_pattern)
	
	# Extract words if word manager is available
	if word_manager:
		result.words = word_manager.process_line(text, used_pattern)
	else:
		# Basic word extraction
		result.words = extract_words(text, used_pattern)
	
	# Store in history
	line_history.append(result)
	
	# Emit signal
	emit_signal("line_processed", result)
	
	return result

func detect_line_pattern(text):
	# Initialize scores for each pattern
	var scores = {
		"parallel": 0,
		"intersecting": 0,
		"spiral": 0,
		"fractal": 0
	}
	
	# Check for pattern markers
	for pattern_name in patterns:
		var pattern = patterns[pattern_name]
		
		# Check each marker
		for marker in pattern.markers:
			if marker in text:
				scores[pattern_name] += 2
	
	# Special pattern detection logic
	
	# Parallel pattern - look for repeated line starts or paragraph breaks
	if "\n\n" in text or text.begins_with("- ") or text.begins_with("* "):
		scores.parallel += 3
	
	# Check for numbered list (1. 2. 3. pattern)
	var numbered_list_regex = RegEx.new()
	numbered_list_regex.compile("\\d+\\. ")
	if numbered_list_regex.search(text):
		scores.parallel += 3
	
	# Intersecting pattern - look for table or grid structures
	if "|" in text and "-" in text:
		scores.intersecting += 3
	
	# Check for code blocks
	if text.begins_with("```") or text.ends_with("```"):
		scores.intersecting += 3
	
	# Spiral pattern - look for circular references or looping concepts
	if "(" in text and ")" in text and ("loop" in text or "cycle" in text or "circular" in text):
		scores.spiral += 3
	
	# Fractal pattern - look for indentation or nested structures
	var indent_level = 0
	while indent_level < text.length() and (text[indent_level] == ' ' or text[indent_level] == '\t'):
		indent_level += 1
	
	if indent_level > 0:
		scores.fractal += indent_level / 2
	
	if "{" in text and "}" in text:
		scores.fractal += 2
	
	# Favor the current pattern slightly for consistency
	scores[current_pattern] += 1
	
	# Find highest scoring pattern
	var max_score = 0
	var detected_pattern = current_pattern
	
	for pattern_name in scores:
		if scores[pattern_name] > max_score:
			max_score = scores[pattern_name]
			detected_pattern = pattern_name
	
	# If no strong pattern detected, keep current
	if max_score < 2:
		detected_pattern = current_pattern
	
	return detected_pattern

func apply_pattern(text, pattern_name):
	match pattern_name:
		"parallel":
			return apply_parallel_pattern(text)
		"intersecting":
			return apply_intersecting_pattern(text)
		"spiral":
			return apply_spiral_pattern(text)
		"fractal":
			return apply_fractal_pattern(text)
		_:
			return text

func apply_parallel_pattern(text):
	# Clean up excessive whitespace
	var result = text.strip_edges()
	result = result.replace("\n\n\n", "\n\n")
	
	# Ensure list items are properly formatted
	var lines = result.split("\n")
	for i in range(lines.size()):
		var line = lines[i]
		
		# Convert inconsistent list markers to standard
		if line.begins_with("* "):
			lines[i] = "- " + line.substr(2)
		elif line.begins_with("+ "):
			lines[i] = "- " + line.substr(2)
	
	return PoolStringArray(lines).join("\n")

func apply_intersecting_pattern(text):
	# Normalize table formatting
	if "|" in text:
		var lines = text.split("\n")
		var has_header_separator = false
		
		for i in range(lines.size()):
			var line = lines[i]
			
			# Check for and normalize header separator
			if line.begins_with("|") and "-" in line and not "|-" in line:
				lines[i] = line.replace("-", "---")
				has_header_separator = true
		
		# Add header separator if table detected but no separator
		if "|" in lines[0] and not has_header_separator and lines.size() > 1:
			var header_parts = lines[0].split("|")
			var separator = "|"
			
			for j in range(1, header_parts.size() - 1):
				separator += "---|"
			
			lines.insert(1, separator)
		
		return PoolStringArray(lines).join("\n")
	
	# Normalize code blocks
	if "```" in text:
		var lines = text.split("\n")
		var in_code_block = false
		
		for i in range(lines.size()):
			var line = lines[i]
			
			if line.begins_with("```"):
				in_code_block = not in_code_block
				
				# Ensure code language is specified
				if in_code_block and line == "```":
					lines[i] = "```txt"
		
		return PoolStringArray(lines).join("\n")
	
	return text

func apply_spiral_pattern(text):
	# Process circular references
	if "(" in text and ")" in text:
		# Enhance anything in parentheses with emphasis
		var start = 0
		var enhanced_text = ""
		
		while start < text.length():
			var open_pos = text.find("(", start)
			
			if open_pos == -1:
				# No more parentheses, add the rest
				enhanced_text += text.substr(start)
				break
			
			var close_pos = text.find(")", open_pos)
			if close_pos == -1:
				# No closing parenthesis, add the rest
				enhanced_text += text.substr(start)
				break
			
			# Add text before parenthesis
			enhanced_text += text.substr(start, open_pos - start)
			
			# Extract and enhance the text in parentheses
			var inner_text = text.substr(open_pos + 1, close_pos - open_pos - 1)
			enhanced_text += "(" + inner_text + ")" # Could add emphasis, but we'll keep it simple
			
			# Update start position
			start = close_pos + 1
		
		return enhanced_text
	
	return text

func apply_fractal_pattern(text):
	# Preserve indentation levels
	var lines = text.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i]
		
		# Count indentation
		var indent_level = 0
		while indent_level < line.length() and (line[indent_level] == ' ' or line[indent_level] == '\t'):
			indent_level += 1
		
		if indent_level > 0:
			# Normalize indentation to spaces
			var indentation = " ".repeat(indent_level)
			var content = line.substr(indent_level)
			lines[i] = indentation + content
	
	return PoolStringArray(lines).join("\n")

func extract_words(text, pattern_name="parallel"):
	var words = []
	
	# Basic word extraction based on spaces
	var raw_words = text.split(" ")
	
	for word in raw_words:
		# Clean the word
		word = word.strip_edges().to_lower()
		word = word.replace(",", "").replace(".", "").replace("!", "").replace("?", "")
		
		if word != "":
			words.append(word)
	
	return words

func set_pattern(pattern_name):
	if patterns.has(pattern_name):
		current_pattern = pattern_name
		print("Line pattern set to: " + pattern_name)
		return true
	return false

func set_turn(turn_number):
	if turn_number >= 1 and turn_number <= 12:
		active_turn = turn_number
		print("Line Processor updated to Turn " + str(active_turn))
		return true
	return false

func get_dominant_pattern():
	var max_count = 0
	var dominant = current_pattern
	
	for pattern in pattern_stats:
		if pattern_stats[pattern] > max_count:
			max_count = pattern_stats[pattern]
			dominant = pattern
	
	return dominant

func get_pattern_stats():
	return pattern_stats

func get_pattern_description(pattern_name):
	if patterns.has(pattern_name):
		return patterns[pattern_name].description
	return ""

func get_recent_lines(count=5):
	if line_history.size() == 0:
		return []
	
	var start_index = max(0, line_history.size() - count)
	var recent = []
	
	for i in range(start_index, line_history.size()):
		recent.append(line_history[i])
	
	return recent

func generate_line_stats_report():
	var report = "== Line Processing Report ==\n"
	report += "Current pattern: " + current_pattern + "\n"
	report += "Active turn: " + str(active_turn) + "\n\n"
	
	report += "Pattern usage:\n"
	for pattern in pattern_stats:
		var percentage = 0
		if line_history.size() > 0:
			percentage = (float(pattern_stats[pattern]) / line_history.size()) * 100
		
		report += "- " + pattern + ": " + str(pattern_stats[pattern]) + " lines (" + str(int(percentage)) + "%)\n"
	
	report += "\nTotal lines processed: " + str(line_history.size()) + "\n"
	
	return report