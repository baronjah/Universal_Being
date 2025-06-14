@tool
extends SceneTree

# CLI script for analyzing data from the command line
# Usage: godot --path "/project/path" --headless --script "scripts/cli/analyze_data.gd" --data-path "/path/to/data" --output-file "/path/to/output.json"

const DATA_CACHE_DIR = "res://data_cache/"
const DEFAULT_OUTPUT_DIR = "res://analysis_results/"
const MAX_BATCH_SIZE = 1000 # Number of files to process in one batch

var config = {
	"input_path": "",
	"output_path": "",
	"analysis_type": "text", # text, code, patterns, semantic
	"recursive": true,
	"file_patterns": ["*.txt", "*.md", "*.json"],
	"max_files": 10000,
	"export_format": "json", # json, csv, text
	"generate_visualization": false
}

# Stats for monitoring progress
var stats = {
	"files_scanned": 0,
	"files_analyzed": 0,
	"errors": 0,
	"bytes_processed": 0,
	"start_time": 0,
	"patterns_found": 0
}

func _initialize():
	print("Luminous OS Data Analyzer CLI")
	print("=============================")
	
	# Parse command line arguments
	var arguments = OS.get_cmdline_args()
	var data_path = ""
	var output_file = ""
	var config_file_path = ""
	
	for i in range(arguments.size()):
		if arguments[i] == "--data-path" and i + 1 < arguments.size():
			data_path = arguments[i + 1]
		elif arguments[i] == "--output-file" and i + 1 < arguments.size():
			output_file = arguments[i + 1]
		elif arguments[i] == "--config-file" and i + 1 < arguments.size():
			config_file_path = arguments[i + 1]
	
	# If we have direct parameters, use those
	if not data_path.is_empty():
		config.input_path = data_path
	
	if not output_file.is_empty():
		config.output_path = output_file
	
	# Otherwise, try to load from config file
	if config.input_path.is_empty() and not config_file_path.is_empty():
		if not load_config(config_file_path):
			quit(1)
			return
	
	# Validate configuration
	if config.input_path.is_empty():
		printerr("Error: No input path specified. Use --data-path parameter or a config file.")
		quit(1)
		return
	
	# Initialize stats
	stats.start_time = Time.get_unix_time_from_system()
	
	print("Analyzing data from: %s" % config.input_path)
	print("Analysis type: %s" % config.analysis_type)
	
	if config.output_path.is_empty():
		# Set default output path if none provided
		config.output_path = DEFAULT_OUTPUT_DIR.path_join("analysis_results_" + str(int(stats.start_time)) + ".json")
		print("Output file: %s" % config.output_path)
	else:
		print("Output file: %s" % config.output_path)
	
	# Create output directory if it doesn't exist
	var output_dir = config.output_path.get_base_dir()
	var dir = DirAccess.open("res://")
	if dir != null and not dir.dir_exists(output_dir) and output_dir.begins_with("res://"):
		var err = dir.make_dir_recursive(output_dir)
		if err != OK:
			printerr("Error creating output directory: %s" % output_dir)
	
	# Run the analysis
	if analyze_data():
		print("Analysis completed successfully!")
		
		# Print stats
		var time_taken = Time.get_unix_time_from_system() - stats.start_time
		print("\nStatistics:")
		print("Files scanned: %d" % stats.files_scanned)
		print("Files analyzed: %d" % stats.files_analyzed)
		print("Errors encountered: %d" % stats.errors)
		print("Data processed: %.2f MB" % (stats.bytes_processed / 1048576.0))
		print("Patterns found: %d" % stats.patterns_found)
		print("Time taken: %.2f seconds" % time_taken)
		
		quit(0)
	else:
		printerr("Analysis failed.")
		quit(1)

func load_config(file_path):
	# Load configuration from JSON file
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("Error: Could not open config file: %s" % file_path)
		return false
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		printerr("Error parsing JSON: %s at line %d" % [json.get_error_message(), json.get_error_line()])
		return false
	
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		printerr("Invalid config format. Expected JSON object.")
		return false
	
	# Update config with loaded values
	for key in data:
		config[key] = data[key]
	
	return true

func analyze_data():
	# Find all files to analyze
	var files_to_analyze = find_files_to_analyze()
	if files_to_analyze.is_empty():
		printerr("No files found to analyze.")
		return false
	
	stats.files_scanned = files_to_analyze.size()
	print("Found %d files to analyze." % files_to_analyze.size())
	
	# Limit number of files if needed
	if files_to_analyze.size() > config.max_files:
		print("Limiting analysis to %d files as specified in config." % config.max_files)
		files_to_analyze = files_to_analyze.slice(0, config.max_files)
	
	# Process files in batches to avoid memory issues
	var results = {}
	var total_batches = ceil(float(files_to_analyze.size()) / MAX_BATCH_SIZE)
	
	for batch_index in range(total_batches):
		var start_idx = batch_index * MAX_BATCH_SIZE
		var end_idx = min(start_idx + MAX_BATCH_SIZE, files_to_analyze.size())
		var batch = files_to_analyze.slice(start_idx, end_idx)
		
		print("Processing batch %d/%d (%d files)..." % [batch_index + 1, total_batches, batch.size()])
		
		var batch_results = process_batch(batch)
		if batch_results != null:
			for key in batch_results:
				if not results.has(key):
					results[key] = batch_results[key]
				else:
					# Merge results
					if typeof(results[key]) == TYPE_ARRAY:
						results[key].append_array(batch_results[key])
					elif typeof(results[key]) == TYPE_DICTIONARY:
						for subkey in batch_results[key]:
							results[key][subkey] = batch_results[key][subkey]
					else:
						results[key] += batch_results[key]
	
	# Export results
	return export_results(results)

func find_files_to_analyze():
	var files = []
	var root_dir = config.input_path
	
	if root_dir.begins_with("res://"):
		# It's a resource path inside the project
		var dir = DirAccess.open(root_dir)
		if dir == null:
			printerr("Error: Could not access input directory: %s" % root_dir)
			return []
		
		scan_directory(dir, root_dir, files)
	else:
		# It's a file system path
		var dir = DirAccess.open("user://")
		if dir == null:
			printerr("Error: Could not access user directory.")
			return []
		
		# Convert to absolute path if it's relative
		if not root_dir.begins_with("/"):
			root_dir = OS.get_user_data_dir().path_join(root_dir)
		
		var os_dir = DirAccess.open(root_dir)
		if os_dir == null:
			printerr("Error: Could not access input directory: %s" % root_dir)
			return []
		
		scan_os_directory(os_dir, root_dir, files)
	
	return files

func scan_directory(dir, path, files):
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path = path.path_join(file_name)
			
			if dir.current_is_dir():
				if config.recursive:
					var subdir = DirAccess.open(full_path)
					if subdir != null:
						scan_directory(subdir, full_path, files)
			else:
				var matches = false
				for pattern in config.file_patterns:
					if file_name.match(pattern):
						matches = true
						break
				
				if matches:
					files.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func scan_os_directory(dir, path, files):
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path = path.path_join(file_name)
			
			if dir.current_is_dir():
				if config.recursive:
					var subdir = DirAccess.open(full_path)
					if subdir != null:
						scan_os_directory(subdir, full_path, files)
			else:
				var matches = false
				for pattern in config.file_patterns:
					if file_name.match(pattern):
						matches = true
						break
				
				if matches:
					files.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func process_batch(batch):
	match config.analysis_type:
		"text":
			return analyze_text_batch(batch)
		"code":
			return analyze_code_batch(batch)
		"patterns":
			return analyze_patterns_batch(batch)
		"semantic":
			return analyze_semantic_batch(batch)
		_:
			printerr("Unknown analysis type: %s" % config.analysis_type)
			return null

func analyze_text_batch(batch):
	var results = {
		"word_count": 0,
		"character_count": 0,
		"line_count": 0,
		"common_words": {},
		"sentiment_score": 0.0,
		"files_analyzed": []
	}
	
	for file_path in batch:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file == null:
			printerr("Error opening file: %s" % file_path)
			stats.errors += 1
			continue
		
		var content = file.get_as_text()
		file.close()
		
		# Update stats
		stats.bytes_processed += content.length()
		stats.files_analyzed += 1
		
		# Calculate basic metrics
		results.character_count += content.length()
		
		var lines = content.split("\n")
		results.line_count += lines.size()
		
		var words = content.split(" ", false)
		results.word_count += words.size()
		
		# Count common words
		for word in words:
			word = word.strip_edges().to_lower()
			if word.length() < 2:
				continue
				
			if results.common_words.has(word):
				results.common_words[word] += 1
			else:
				results.common_words[word] = 1
		
		# Simplified sentiment analysis (very basic)
		var positive_words = ["good", "great", "excellent", "happy", "positive", "wonderful", "amazing"]
		var negative_words = ["bad", "poor", "terrible", "sad", "negative", "awful", "horrible"]
		
		var sentiment = 0.0
		for word in words:
			word = word.strip_edges().to_lower()
			if positive_words.has(word):
				sentiment += 1.0
			elif negative_words.has(word):
				sentiment -= 1.0
		
		if words.size() > 0:
			sentiment /= words.size()
		
		results.sentiment_score += sentiment
		
		# Add file info
		results.files_analyzed.append({
			"path": file_path,
			"size": content.length(),
			"lines": lines.size(),
			"words": words.size()
		})
	
	# Sort common words by frequency
	var sorted_words = []
	for word in results.common_words.keys():
		sorted_words.append({"word": word, "count": results.common_words[word]})
	
	sorted_words.sort_custom(func(a, b): return a.count > b.count)
	
	var top_words = {}
	for i in range(min(sorted_words.size(), 100)):
		top_words[sorted_words[i].word] = sorted_words[i].count
	
	results.common_words = top_words
	
	# Average sentiment score
	if batch.size() > 0:
		results.sentiment_score /= batch.size()
	
	return results

func analyze_code_batch(batch):
	var results = {
		"file_extensions": {},
		"code_lines": 0,
		"comment_lines": 0,
		"blank_lines": 0,
		"functions_count": 0,
		"classes_count": 0,
		"complexity": 0.0,
		"files_analyzed": []
	}
	
	for file_path in batch:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file == null:
			printerr("Error opening file: %s" % file_path)
			stats.errors += 1
			continue
		
		var content = file.get_as_text()
		file.close()
		
		# Update stats
		stats.bytes_processed += content.length()
		stats.files_analyzed += 1
		
		# Extract file extension
		var extension = file_path.get_extension().to_lower()
		if results.file_extensions.has(extension):
			results.file_extensions[extension] += 1
		else:
			results.file_extensions[extension] = 1
		
		# Analyze code
		var file_results = analyze_code_file(content, extension)
		
		results.code_lines += file_results.code_lines
		results.comment_lines += file_results.comment_lines
		results.blank_lines += file_results.blank_lines
		results.functions_count += file_results.functions_count
		results.classes_count += file_results.classes_count
		results.complexity += file_results.complexity
		
		# Add file info
		results.files_analyzed.append({
			"path": file_path,
			"extension": extension,
			"code_lines": file_results.code_lines,
			"comment_lines": file_results.comment_lines,
			"blank_lines": file_results.blank_lines,
			"functions_count": file_results.functions_count,
			"classes_count": file_results.classes_count,
			"complexity": file_results.complexity
		})
	
	# Average complexity
	if batch.size() > 0:
		results.complexity /= batch.size()
	
	return results

func analyze_code_file(content, extension):
	var results = {
		"code_lines": 0,
		"comment_lines": 0,
		"blank_lines": 0,
		"functions_count": 0,
		"classes_count": 0,
		"complexity": 0.0
	}
	
	var lines = content.split("\n")
	var in_multi_comment = false
	
	# Language-specific patterns
	var function_pattern = ""
	var class_pattern = ""
	var single_comment = ""
	var multi_comment_start = ""
	var multi_comment_end = ""
	
	match extension:
		"gd", "gdscript":
			function_pattern = "^\\s*func\\s+"
			class_pattern = "^\\s*class\\s+"
			single_comment = "#"
			multi_comment_start = '"""'
			multi_comment_end = '"""'
		"cs":
			function_pattern = "\\b(public|private|protected|internal|static)?(\\s+virtual|\\s+override)?\\s+\\w+\\s+\\w+\\s*\\("
			class_pattern = "\\b(public|private|protected|internal|static)?\\s+class\\s+"
			single_comment = "//"
			multi_comment_start = "/*"
			multi_comment_end = "*/"
		"py":
			function_pattern = "^\\s*def\\s+"
			class_pattern = "^\\s*class\\s+"
			single_comment = "#"
			multi_comment_start = '"""'
			multi_comment_end = '"""'
		"js", "ts":
			function_pattern = "\\bfunction\\s+\\w+\\s*\\(|\\b\\w+\\s*=\\s*function\\s*\\(|\\b\\w+\\s*\\(.*\\)\\s*=>"
			class_pattern = "\\bclass\\s+"
			single_comment = "//"
			multi_comment_start = "/*"
			multi_comment_end = "*/"
		_:
			# Default patterns
			function_pattern = "\\bfunction\\s+|\\bdef\\s+|\\bfunc\\s+"
			class_pattern = "\\bclass\\s+"
			single_comment = "#|//"
			multi_comment_start = "/\\*|'''"
			multi_comment_end = "\\*/|'''"
	
	# Simple code analysis
	for line in lines:
		var trimmed_line = line.strip_edges()
		
		if trimmed_line.is_empty():
			results.blank_lines += 1
			continue
		
		if in_multi_comment:
			results.comment_lines += 1
			if trimmed_line.find(multi_comment_end) != -1:
				in_multi_comment = false
			continue
		
		if trimmed_line.begins_with(single_comment):
			results.comment_lines += 1
			continue
		
		if trimmed_line.find(multi_comment_start) != -1:
			if trimmed_line.find(multi_comment_end, trimmed_line.find(multi_comment_start) + multi_comment_start.length()) == -1:
				in_multi_comment = true
			results.comment_lines += 1
			continue
		
		# It's a code line
		results.code_lines += 1
		
		# Count functions
		if trimmed_line.match(function_pattern + ".*"):
			results.functions_count += 1
		
		# Count classes
		if trimmed_line.match(class_pattern + ".*"):
			results.classes_count += 1
		
		# Estimate complexity (very simplistic)
		if trimmed_line.find("if ") != -1 or trimmed_line.find("for ") != -1 or \
		   trimmed_line.find("while ") != -1 or trimmed_line.find("switch ") != -1 or \
		   trimmed_line.find("match ") != -1:
			results.complexity += 1
	
	# Normalize complexity
	var total_lines = results.code_lines + results.comment_lines + results.blank_lines
	if total_lines > 0:
		results.complexity = (results.complexity / total_lines) * 10
	
	return results

func analyze_patterns_batch(batch):
	var results = {
		"patterns_found": [],
		"frequency": {},
		"co_occurrences": {},
		"files_analyzed": []
	}
	
	# Define patterns to look for (can be customized based on config)
	var patterns = [
		"TODO",
		"FIXME",
		"HACK",
		"BUG",
		"NOTE",
		"WARNING",
		"ERROR"
	]
	
	for file_path in batch:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file == null:
			printerr("Error opening file: %s" % file_path)
			stats.errors += 1
			continue
		
		var content = file.get_as_text()
		file.close()
		
		# Update stats
		stats.bytes_processed += content.length()
		stats.files_analyzed += 1
		
		var file_patterns = []
		var pattern_positions = {}
		
		# Find patterns
		for pattern in patterns:
			var regex = RegEx.new()
			regex.compile("\\b" + pattern + "\\b")
			
			var pos = 0
			while true:
				var result = regex.search(content, pos)
				if result == null:
					break
				
				pos = result.get_end()
				var line_number = content.substr(0, result.get_start()).count("\n") + 1
				var line_text = get_line_at_position(content, result.get_start())
				
				var pattern_info = {
					"pattern": pattern,
					"line": line_number,
					"context": line_text.strip_edges(),
					"position": result.get_start()
				}
				
				file_patterns.append(pattern_info)
				
				if not pattern_positions.has(pattern):
					pattern_positions[pattern] = []
				
				pattern_positions[pattern].append(result.get_start())
				
				# Update frequency
				if results.frequency.has(pattern):
					results.frequency[pattern] += 1
				else:
					results.frequency[pattern] = 1
				
				stats.patterns_found += 1
		
		# Analyze co-occurrences (patterns that appear close to each other)
		for pattern_a in pattern_positions.keys():
			for pattern_b in pattern_positions.keys():
				if pattern_a == pattern_b:
					continue
				
				var key = pattern_a + "-" + pattern_b
				var reverse_key = pattern_b + "-" + pattern_a
				
				if results.co_occurrences.has(reverse_key):
					key = reverse_key
				
				for pos_a in pattern_positions[pattern_a]:
					for pos_b in pattern_positions[pattern_b]:
						var distance = abs(pos_a - pos_b)
						if distance < 500:  # Consider patterns close if within 500 chars
							if not results.co_occurrences.has(key):
								results.co_occurrences[key] = 0
							
							results.co_occurrences[key] += 1
		
		# Add file info
		if not file_patterns.is_empty():
			results.files_analyzed.append({
				"path": file_path,
				"patterns": file_patterns
			})
		
		# Add to overall patterns
		results.patterns_found.append_array(file_patterns)
	
	return results

func analyze_semantic_batch(batch):
	var results = {
		"topics": {},
		"keyword_frequency": {},
		"sentiment_by_topic": {},
		"semantic_clusters": [],
		"files_analyzed": []
	}
	
	# This would typically use NLP techniques
	# For simplicity, we'll use a keyword-based approach
	
	var topic_keywords = {
		"development": ["code", "develop", "programming", "software", "app", "application", "debug", "function", "class", "method"],
		"game": ["game", "player", "level", "score", "enemy", "character", "animation", "collision", "sprite", "scene"],
		"data": ["data", "database", "query", "record", "field", "table", "json", "file", "storage", "format"],
		"ui": ["interface", "button", "menu", "click", "display", "screen", "user", "layout", "panel", "view"],
		"performance": ["performance", "optimization", "speed", "memory", "load", "cache", "efficient", "fast", "slow", "bottleneck"]
	}
	
	for file_path in batch:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file == null:
			printerr("Error opening file: %s" % file_path)
			stats.errors += 1
			continue
		
		var content = file.get_as_text()
		file.close()
		
		# Update stats
		stats.bytes_processed += content.length()
		stats.files_analyzed += 1
		
		# Convert to lowercase for better matching
		content = content.to_lower()
		
		# Count topic keywords
		var file_topics = {}
		
		for topic in topic_keywords:
			var count = 0
			
			for keyword in topic_keywords[topic]:
				var regex = RegEx.new()
				regex.compile("\\b" + keyword + "\\w*\\b")
				
				var pos = 0
				while true:
					var result = regex.search(content, pos)
					if result == null:
						break
					
					pos = result.get_end()
					count += 1
					
					# Update keyword frequency
					var word = result.get_string()
					if results.keyword_frequency.has(word):
						results.keyword_frequency[word] += 1
					else:
						results.keyword_frequency[word] = 1
			
			if count > 0:
				file_topics[topic] = count
				
				# Update global topics
				if results.topics.has(topic):
					results.topics[topic] += count
				else:
					results.topics[topic] = count
		
		# Basic sentiment analysis by topic
		for topic in file_topics.keys():
			var positive_count = 0
			var negative_count = 0
			
			var positive_words = ["good", "great", "excellent", "improve", "benefit", "successful", "efficient"]
			var negative_words = ["bad", "poor", "terrible", "issue", "problem", "difficult", "fail"]
			
			for word in positive_words:
				var regex = RegEx.new()
				regex.compile("\\b" + word + "\\w*\\b")
				
				var pos = 0
				while true:
					var result = regex.search(content, pos)
					if result == null:
						break
					
					pos = result.get_end()
					
					# Check if the word is close to a topic keyword
					for keyword in topic_keywords[topic]:
						if content.find(keyword, max(0, pos - 100)) < pos + 100:
							positive_count += 1
							break
			
			for word in negative_words:
				var regex = RegEx.new()
				regex.compile("\\b" + word + "\\w*\\b")
				
				var pos = 0
				while true:
					var result = regex.search(content, pos)
					if result == null:
						break
					
					pos = result.get_end()
					
					# Check if the word is close to a topic keyword
					for keyword in topic_keywords[topic]:
						if content.find(keyword, max(0, pos - 100)) < pos + 100:
							negative_count += 1
							break
			
			var sentiment = 0.0
			if positive_count + negative_count > 0:
				sentiment = float(positive_count - negative_count) / (positive_count + negative_count)
			
			if not results.sentiment_by_topic.has(topic):
				results.sentiment_by_topic[topic] = []
			
			results.sentiment_by_topic[topic].append(sentiment)
		
		# Add file info
		results.files_analyzed.append({
			"path": file_path,
			"topics": file_topics,
			"size": content.length()
		})
	
	# Average the sentiment scores by topic
	for topic in results.sentiment_by_topic.keys():
		var sum = 0.0
		for score in results.sentiment_by_topic[topic]:
			sum += score
		
		if results.sentiment_by_topic[topic].size() > 0:
			results.sentiment_by_topic[topic] = sum / results.sentiment_by_topic[topic].size()
		else:
			results.sentiment_by_topic[topic] = 0.0
	
	# Sort keywords by frequency
	var sorted_keywords = []
	for keyword in results.keyword_frequency.keys():
		sorted_keywords.append({
			"keyword": keyword,
			"count": results.keyword_frequency[keyword]
		})
	
	sorted_keywords.sort_custom(func(a, b): return a.count > b.count)
	
	var top_keywords = {}
	for i in range(min(sorted_keywords.size(), 100)):
		top_keywords[sorted_keywords[i].keyword] = sorted_keywords[i].count
	
	results.keyword_frequency = top_keywords
	
	return results

func get_line_at_position(text, position):
	var start_pos = text.rfind("\n", position)
	if start_pos == -1:
		start_pos = 0
	else:
		start_pos += 1
	
	var end_pos = text.find("\n", position)
	if end_pos == -1:
		end_pos = text.length()
	
	return text.substr(start_pos, end_pos - start_pos)

func export_results(results):
	# Prepare output path
	var output_path = config.output_path
	
	# Create output file
	var file
	if output_path.begins_with("/"):
		# This is an absolute path in the file system
		file = FileAccess.open(output_path, FileAccess.WRITE)
	else:
		# This is a path inside the project
		file = FileAccess.open(output_path, FileAccess.WRITE)
	
	if file == null:
		printerr("Error: Could not create output file: %s" % output_path)
		return false
	
	# Add metadata
	results["metadata"] = {
		"analysis_type": config.analysis_type,
		"timestamp": Time.get_datetime_string_from_system(),
		"input_path": config.input_path,
		"files_analyzed": stats.files_analyzed,
		"files_scanned": stats.files_scanned,
		"patterns_found": stats.patterns_found,
		"bytes_processed": stats.bytes_processed
	}
	
	# Determine export format from file extension
	var export_format = output_path.get_extension().to_lower()
	if export_format not in ["json", "csv", "txt", "text"]:
		export_format = config.export_format  # Use the one from config
	
	match export_format:
		"json":
			file.store_string(JSON.stringify(results, "  "))
		"csv":
			# This is a simplified CSV export - would need to be expanded
			# based on the specific analysis type
			file.store_line("key,value")
			
			match config.analysis_type:
				"text":
					file.store_line("word_count,%d" % results.word_count)
					file.store_line("character_count,%d" % results.character_count)
					file.store_line("line_count,%d" % results.line_count)
					file.store_line("sentiment_score,%.2f" % results.sentiment_score)
					
					# Top 10 words
					var i = 0
					for word in results.common_words:
						if i >= 10:
							break
						file.store_line("common_word_%d,%s,%d" % [i, word, results.common_words[word]])
						i += 1
				"code":
					file.store_line("code_lines,%d" % results.code_lines)
					file.store_line("comment_lines,%d" % results.comment_lines)
					file.store_line("blank_lines,%d" % results.blank_lines)
					file.store_line("functions_count,%d" % results.functions_count)
					file.store_line("classes_count,%d" % results.classes_count)
					file.store_line("complexity,%.2f" % results.complexity)
					
					# File extensions
					for ext in results.file_extensions:
						file.store_line("extension_%s,%d" % [ext, results.file_extensions[ext]])
				"patterns":
					for pattern in results.frequency:
						file.store_line("pattern_%s,%d" % [pattern, results.frequency[pattern]])
					
					# Co-occurrences
					for co_occurrence in results.co_occurrences:
						file.store_line("co_occurrence_%s,%d" % [co_occurrence, results.co_occurrences[co_occurrence]])
				"semantic":
					for topic in results.topics:
						file.store_line("topic_%s,%d" % [topic, results.topics[topic]])
						file.store_line("sentiment_%s,%.2f" % [topic, results.sentiment_by_topic[topic]])
		"txt", "text":
			file.store_line("Luminous OS Data Analysis Results")
			file.store_line("================================")
			file.store_line("")
			file.store_line("Analysis Type: " + config.analysis_type)
			file.store_line("Timestamp: " + Time.get_datetime_string_from_system())
			file.store_line("Input Path: " + config.input_path)
			file.store_line("Files Analyzed: " + str(stats.files_analyzed))
			file.store_line("Files Scanned: " + str(stats.files_scanned))
			file.store_line("Data Processed: %.2f MB" % (stats.bytes_processed / 1048576.0))
			file.store_line("")
			
			match config.analysis_type:
				"text":
					file.store_line("Text Analysis Results:")
					file.store_line("----------------------")
					file.store_line("Word Count: " + str(results.word_count))
					file.store_line("Character Count: " + str(results.character_count))
					file.store_line("Line Count: " + str(results.line_count))
					file.store_line("Sentiment Score: %.2f" % results.sentiment_score)
					file.store_line("")
					
					file.store_line("Most Common Words:")
					var i = 0
					for word in results.common_words:
						if i >= 20:
							break
						file.store_line("  " + word + ": " + str(results.common_words[word]))
						i += 1
				"code":
					file.store_line("Code Analysis Results:")
					file.store_line("---------------------")
					file.store_line("Code Lines: " + str(results.code_lines))
					file.store_line("Comment Lines: " + str(results.comment_lines))
					file.store_line("Blank Lines: " + str(results.blank_lines))
					file.store_line("Functions Count: " + str(results.functions_count))
					file.store_line("Classes Count: " + str(results.classes_count))
					file.store_line("Average Complexity: %.2f" % results.complexity)
					file.store_line("")
					
					file.store_line("File Extensions:")
					for ext in results.file_extensions:
						file.store_line("  " + ext + ": " + str(results.file_extensions[ext]))
				"patterns":
					file.store_line("Pattern Analysis Results:")
					file.store_line("------------------------")
					file.store_line("Patterns Found: " + str(stats.patterns_found))
					file.store_line("")
					
					file.store_line("Pattern Frequency:")
					for pattern in results.frequency:
						file.store_line("  " + pattern + ": " + str(results.frequency[pattern]))
					
					file.store_line("")
					file.store_line("Common Co-occurrences:")
					for co_occurrence in results.co_occurrences:
						file.store_line("  " + co_occurrence + ": " + str(results.co_occurrences[co_occurrence]))
				"semantic":
					file.store_line("Semantic Analysis Results:")
					file.store_line("--------------------------")
					file.store_line("")
					
					file.store_line("Topic Distribution:")
					for topic in results.topics:
						file.store_line("  " + topic + ": " + str(results.topics[topic]))
					
					file.store_line("")
					file.store_line("Topic Sentiment:")
					for topic in results.sentiment_by_topic:
						var sentiment = results.sentiment_by_topic[topic]
						var sentiment_text = "Neutral"
						if sentiment > 0.3:
							sentiment_text = "Positive"
						elif sentiment < -0.3:
							sentiment_text = "Negative"
						
						file.store_line("  " + topic + ": " + sentiment_text + " (%.2f)" % sentiment)
					
					file.store_line("")
					file.store_line("Top Keywords:")
					var i = 0
					for keyword in results.keyword_frequency:
						if i >= 20:
							break
						file.store_line("  " + keyword + ": " + str(results.keyword_frequency[keyword]))
						i += 1
		_:
			# Default to JSON
			file.store_string(JSON.stringify(results, "  "))
	
	file.close()
	
	print("Results exported to: %s" % output_path)
	
	# Generate visualization if requested
	if config.generate_visualization:
		generate_visualization(results, output_path)
	
	return true

func generate_visualization(results, data_path):
	var visualization_path = data_path.get_basename() + "_visualization.html"
	var file = FileAccess.open(visualization_path, FileAccess.WRITE)
	
	if file == null:
		printerr("Error: Could not create visualization file: %s" % visualization_path)
		return
	
	var json_data = JSON.stringify(results)
	
	var html_content = """
<!DOCTYPE html>
<html>
<head>
    <title>Luminous OS Data Analysis Visualization</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .chart-container { width: 800px; height: 400px; margin: 20px 0; }
        .metadata { margin-bottom: 20px; }
        .section { margin-bottom: 40px; }
        h1, h2 { color: #333; }
    </style>
</head>
<body>
    <h1>Luminous OS Data Analysis Visualization</h1>
    
    <div class="metadata" id="metadata">
        <h2>Analysis Metadata</h2>
        <!-- Metadata will be inserted here -->
    </div>
    
    <div class="section">
        <h2>Analysis Results</h2>
        
        <!-- Charts will be inserted here based on analysis type -->
        <div class="chart-container">
            <canvas id="mainChart"></canvas>
        </div>
        
        <div class="chart-container">
            <canvas id="secondaryChart"></canvas>
        </div>
    </div>
    
    <script>
        // Data from analysis
        const analysisData = %s;
        
        // Display metadata
        const metadataElement = document.getElementById('metadata');
        const metadata = analysisData.metadata;
        if (metadata) {
            let metadataHtml = '<ul>';
            for (const key in metadata) {
                metadataHtml += `<li><strong>${key}:</strong> ${metadata[key]}</li>`;
            }
            metadataHtml += '</ul>';
            metadataElement.innerHTML += metadataHtml;
        }
        
        // Create visualizations based on analysis type
        const analysisType = metadata ? metadata.analysis_type : 'unknown';
        
        function createCharts() {
            switch (analysisType) {
                case 'text':
                    createTextAnalysisCharts();
                    break;
                case 'code':
                    createCodeAnalysisCharts();
                    break;
                case 'patterns':
                    createPatternAnalysisCharts();
                    break;
                case 'semantic':
                    createSemanticAnalysisCharts();
                    break;
                default:
                    console.log('Unknown analysis type');
            }
        }
        
        function createTextAnalysisCharts() {
            // Word count chart
            if (analysisData.common_words) {
                const labels = Object.keys(analysisData.common_words).slice(0, 10);
                const data = labels.map(word => analysisData.common_words[word]);
                
                new Chart(document.getElementById('mainChart'), {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Most Common Words',
                            data: data,
                            backgroundColor: 'rgba(54, 162, 235, 0.5)',
                            borderColor: 'rgba(54, 162, 235, 1)',
                            borderWidth: 1
                        }]
                    },
                    options: {
                        scales: {
                            y: {
                                beginAtZero: true
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Top 10 Most Common Words'
                            }
                        }
                    }
                });
            }
            
            // Text metrics chart
            new Chart(document.getElementById('secondaryChart'), {
                type: 'pie',
                data: {
                    labels: ['Words', 'Lines'],
                    datasets: [{
                        data: [analysisData.word_count, analysisData.line_count],
                        backgroundColor: [
                            'rgba(54, 162, 235, 0.5)',
                            'rgba(255, 99, 132, 0.5)'
                        ]
                    }]
                },
                options: {
                    plugins: {
                        title: {
                            display: true,
                            text: 'Text Composition'
                        }
                    }
                }
            });
        }
        
        function createCodeAnalysisCharts() {
            // Code composition chart
            const totalLines = analysisData.code_lines + analysisData.comment_lines + analysisData.blank_lines;
            
            new Chart(document.getElementById('mainChart'), {
                type: 'pie',
                data: {
                    labels: ['Code Lines', 'Comment Lines', 'Blank Lines'],
                    datasets: [{
                        data: [
                            analysisData.code_lines, 
                            analysisData.comment_lines,
                            analysisData.blank_lines
                        ],
                        backgroundColor: [
                            'rgba(54, 162, 235, 0.5)',
                            'rgba(255, 99, 132, 0.5)',
                            'rgba(255, 206, 86, 0.5)'
                        ]
                    }]
                },
                options: {
                    plugins: {
                        title: {
                            display: true,
                            text: 'Code Composition'
                        }
                    }
                }
            });
            
            // File extensions chart
            if (analysisData.file_extensions) {
                const labels = Object.keys(analysisData.file_extensions);
                const data = labels.map(ext => analysisData.file_extensions[ext]);
                
                new Chart(document.getElementById('secondaryChart'), {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'File Extensions',
                            data: data,
                            backgroundColor: 'rgba(75, 192, 192, 0.5)',
                            borderColor: 'rgba(75, 192, 192, 1)',
                            borderWidth: 1
                        }]
                    },
                    options: {
                        scales: {
                            y: {
                                beginAtZero: true
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'File Extensions Distribution'
                            }
                        }
                    }
                });
            }
        }
        
        function createPatternAnalysisCharts() {
            // Pattern frequency chart
            if (analysisData.frequency) {
                const labels = Object.keys(analysisData.frequency);
                const data = labels.map(pattern => analysisData.frequency[pattern]);
                
                new Chart(document.getElementById('mainChart'), {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Pattern Frequency',
                            data: data,
                            backgroundColor: 'rgba(153, 102, 255, 0.5)',
                            borderColor: 'rgba(153, 102, 255, 1)',
                            borderWidth: 1
                        }]
                    },
                    options: {
                        scales: {
                            y: {
                                beginAtZero: true
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Pattern Frequency'
                            }
                        }
                    }
                });
            }
            
            // Co-occurrences chart
            if (analysisData.co_occurrences) {
                const labels = Object.keys(analysisData.co_occurrences).slice(0, 10);
                const data = labels.map(pattern => analysisData.co_occurrences[pattern]);
                
                new Chart(document.getElementById('secondaryChart'), {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Pattern Co-occurrences',
                            data: data,
                            backgroundColor: 'rgba(255, 159, 64, 0.5)',
                            borderColor: 'rgba(255, 159, 64, 1)',
                            borderWidth: 1
                        }]
                    },
                    options: {
                        scales: {
                            y: {
                                beginAtZero: true
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Top 10 Pattern Co-occurrences'
                            }
                        }
                    }
                });
            }
        }
        
        function createSemanticAnalysisCharts() {
            // Topics chart
            if (analysisData.topics) {
                const labels = Object.keys(analysisData.topics);
                const data = labels.map(topic => analysisData.topics[topic]);
                
                new Chart(document.getElementById('mainChart'), {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Topic Distribution',
                            data: data,
                            backgroundColor: 'rgba(255, 99, 132, 0.5)',
                            borderColor: 'rgba(255, 99, 132, 1)',
                            borderWidth: 1
                        }]
                    },
                    options: {
                        scales: {
                            y: {
                                beginAtZero: true
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Topic Distribution'
                            }
                        }
                    }
                });
            }
            
            // Sentiment by topic chart
            if (analysisData.sentiment_by_topic) {
                const labels = Object.keys(analysisData.sentiment_by_topic);
                const data = labels.map(topic => analysisData.sentiment_by_topic[topic]);
                
                new Chart(document.getElementById('secondaryChart'), {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Sentiment by Topic',
                            data: data,
                            backgroundColor: data.map(value => {
                                if (value > 0.3) return 'rgba(75, 192, 192, 0.5)'; // Positive
                                if (value < -0.3) return 'rgba(255, 99, 132, 0.5)'; // Negative
                                return 'rgba(255, 206, 86, 0.5)'; // Neutral
                            }),
                            borderColor: data.map(value => {
                                if (value > 0.3) return 'rgba(75, 192, 192, 1)';
                                if (value < -0.3) return 'rgba(255, 99, 132, 1)';
                                return 'rgba(255, 206, 86, 1)';
                            }),
                            borderWidth: 1
                        }]
                    },
                    options: {
                        scales: {
                            y: {
                                beginAtZero: false,
                                min: -1,
                                max: 1
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Sentiment by Topic'
                            }
                        }
                    }
                });
            }
        }
        
        // Initialize charts
        createCharts();
    </script>
</body>
</html>
""" % json_data
	
	file.store_string(html_content)
	file.close()
	
	print("Visualization exported to: %s" % visualization_path)

# Entry point
func _init():
	_initialize()