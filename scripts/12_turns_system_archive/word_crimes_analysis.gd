extends Node

# Word Crimes Analysis System
# Analyzes linguistic patterns and power levels within the 12-turn system
# Terminal 1: Divine Word Genesis

class_name WordCrimesAnalysis

# ----- CRIME CATEGORIES -----
enum CrimeType {
	MINOR,      # Small linguistic infractions
	MODERATE,   # Medium severity word crimes
	MAJOR,      # Serious linguistic violations
	COSMIC      # Reality-altering forbidden word patterns
}

# Reference to other systems
var divine_word_processor = null
var turn_system = null
var word_salem_controller = null
var word_comment_system = null
var word_dream_storage = null

# Analysis thresholds
var power_thresholds = {
	"minor": 10,
	"moderate": 25,
	"major": 50,
	"cosmic": 100
}

# ----- BANNED WORD PATTERNS -----
var banned_words = [
	"delete",
	"crash",
	"error",
	"terminate",
	"kill",
	"destroy",
	"corrupt",
	"void",
	"null",
	"erase"
]

# Pattern recognition
var dangerous_patterns = {
	"executable": ["^exe", "sudo", "rm -rf", "override", "hack"],
	"destructive": ["destroy", "erase", "kill", "terminate"],
	"self_reference": ["self", "reference", "recursion", "loop"],
	"reality_destabilization": ["destabilize", "collapse", "shatter", "break"],
	"dimension_fracture": ["fracture", "split", "divide", "tear"],
	"consciousness_corruption": ["corrupt", "manipulate", "control", "force"],
	"rogue_ai": ["SHODAN", "GLaDOS", "HAL"]
}

# Linguistic analysis metrics
var metrics = {
	"avg_word_power": 0,
	"max_word_power": 0,
	"dangerous_word_count": 0,
	"cosmic_word_count": 0,
	"total_words_processed": 0,
	"power_by_dimension": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	"crime_frequency": {},
	"player_power_levels": {}
}

# Statistical tracking
var word_history = []
var crime_history = []
var word_combinations = {}
var dimension_influence = []

# ----- CRIME RECORDS -----
var crime_ledger = []
var criminal_records = {}
var pattern_violations = {}
var active_judgments = {}

# ----- SIGNALS -----
signal word_crime_detected(criminal, crime_type, word_power)
signal dangerous_pattern_detected(pattern, word, power)
signal cosmic_power_threshold_reached(word, power)
signal judgment_issued(word, verdict, punishment)
signal pardon_granted(word, reason)
signal player_power_anomaly(player_name, current_power, average_power)
signal dimension_power_spike(dimension, power_delta)

func _ready():
	load_crime_ledger()
	initialize_connections()
	initialize_dimension_tracking()

func initialize_connections():
	# Connect to the divine word processor and turn system
	divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
	turn_system = get_node_or_null("/root/TurnSystem")
	word_salem_controller = get_node_or_null("/root/WordSalemGameController")
	word_comment_system = get_node_or_null("/root/WordCommentSystem")
	word_dream_storage = get_node_or_null("/root/WordDreamStorage")
	
	if divine_word_processor:
		divine_word_processor.connect("word_processed", self, "_on_word_processed")
	
	if turn_system:
		turn_system.connect("turn_completed", self, "_on_turn_completed")
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")
	
	if word_salem_controller:
		word_salem_controller.connect("word_crime_detected", self, "_on_salem_crime_detected")
	
	if word_comment_system:
		word_comment_system.connect("comment_added", self, "_on_comment_added")
		word_comment_system.connect("defense_registered", self, "_on_defense_registered")

func initialize_dimension_tracking():
	# Reset dimension influence tracking
	dimension_influence = []
	for i in range(12):
		dimension_influence.append({
			"dimension": i + 1,
			"power_total": 0,
			"words_processed": 0,
			"avg_power": 0,
			"max_power": 0,
			"crime_count": 0,
			"transitions": {}
		})

# ----- CRIME DETECTION -----
func analyze_word(word, power, source_player):
	var crime_type = null
	var crime_detected = false
	
	# Check for banned words
	if word.to_lower() in banned_words:
		crime_type = CrimeType.MAJOR
		crime_detected = true
	
	# Check for dangerous patterns
	var pattern_detected = check_dangerous_patterns(word)
	if pattern_detected:
		if not crime_detected or CrimeType.MODERATE > crime_type:
			crime_type = CrimeType.MODERATE
		crime_detected = true
	
	# Check for cosmic power threshold (potentially dangerous)
	if power >= power_thresholds.cosmic:
		emit_signal("cosmic_power_threshold_reached", word, power)
		if turn_system and turn_system.current_dimension == 9:  # Judgment dimension enhances crime detection
			if not crime_detected:
				crime_type = CrimeType.MINOR
				crime_detected = true
	
	# Record the crime if detected
	if crime_detected and crime_type != null:
		record_crime(word, crime_type, power, source_player)
		emit_signal("word_crime_detected", source_player, get_crime_type_name(crime_type), power)
		
		# Add a comment about the crime
		if word_comment_system:
			word_comment_system.add_comment(word, 
				"CRIME DETECTED: " + get_crime_type_name(crime_type) + " linguistic violation by " + source_player, 
				word_comment_system.CommentType.WARNING)
		
		return true
	
	return false

func check_dangerous_patterns(word):
	var word_lower = word.to_lower()
	var pattern_found = null
	
	# Check each dangerous pattern
	for pattern_type in dangerous_patterns:
		var pattern_words = dangerous_patterns[pattern_type]
		
		for pattern_word in pattern_words:
			var regex = RegEx.new()
			regex.compile(pattern_word)
			if regex.search(word_lower):
				pattern_found = pattern_type
				
				# Record the pattern violation
				if not pattern_violations.has(pattern_type):
					pattern_violations[pattern_type] = []
				
				pattern_violations[pattern_type].append({
					"word": word,
					"timestamp": OS.get_unix_time(),
					"dimension": turn_system.current_dimension if turn_system else 1
				})
				
				emit_signal("dangerous_pattern_detected", pattern_type, word, 0)
				
				# Add a comment about the pattern violation
				if word_comment_system:
					word_comment_system.add_comment(word, 
						"PATTERN VIOLATION: Word matches dangerous pattern '" + pattern_type + "'", 
						word_comment_system.CommentType.WARNING)
				
				break
		
		if pattern_found:
			break
	
	return pattern_found != null

func record_crime(word, crime_type, power, criminal):
	var timestamp = OS.get_unix_time()
	
	var crime = {
		"id": "crime_" + str(timestamp) + "_" + str(randi() % 10000),
		"word": word,
		"type": crime_type,
		"power": power,
		"criminal": criminal,
		"timestamp": timestamp,
		"date": OS.get_datetime(),
		"dimension": turn_system.current_dimension if turn_system else 1,
		"turn": turn_system.current_turn if turn_system else 0,
		"judged": false,
		"verdict": null,
		"punishment": null
	}
	
	# Add to crime ledger
	crime_ledger.append(crime)
	
	# Add to criminal record
	if not criminal_records.has(criminal):
		criminal_records[criminal] = []
	
	criminal_records[criminal].append(crime)
	
	# Update crime metrics
	metrics.crime_frequency[get_crime_type_name(crime_type)] = metrics.crime_frequency.get(get_crime_type_name(crime_type), 0) + 1
	
	# Update dimension crime count
	var current_dim = turn_system.current_dimension - 1 if turn_system else 0  # 0-based index
	dimension_influence[current_dim].crime_count += 1
	
	# Add to crime history for analysis
	crime_history.append(crime)
	
	# Save to crime ledger file
	save_to_crime_ledger(crime)
	
	return crime

# ----- JUDGMENT AND SENTENCING -----
func issue_judgment(crime_id, verdict, punishment, judge="System"):
	var crime = find_crime_by_id(crime_id)
	if not crime:
		print("Crime not found: " + crime_id)
		return null
	
	crime.judged = true
	crime.verdict = verdict
	crime.punishment = punishment
	crime.judge = judge
	crime.judgment_timestamp = OS.get_unix_time()
	
	# Create an active judgment
	var judgment = {
		"crime_id": crime_id,
		"word": crime.word,
		"criminal": crime.criminal,
		"verdict": verdict,
		"punishment": punishment,
		"judge": judge,
		"timestamp": OS.get_unix_time(),
		"executed": false,
		"active": true
	}
	
	active_judgments[crime_id] = judgment
	
	# Add comment about judgment
	if word_comment_system:
		word_comment_system.add_comment(crime.word, 
			"JUDGMENT: " + verdict + " - " + punishment + " (Judge: " + judge + ")", 
			word_comment_system.CommentType.ACCUSATION)
	
	emit_signal("judgment_issued", crime.word, verdict, punishment)
	
	# If Salem game is active, notify it
	if word_salem_controller:
		word_salem_controller.notify_judgment_issued(crime.word, verdict, punishment, crime.criminal)
	
	save_to_crime_ledger(crime, true)  # Update the crime record
	return judgment

func pardon_crime(crime_id, reason, pardoner="System"):
	var crime = find_crime_by_id(crime_id)
	if not crime:
		print("Crime not found: " + crime_id)
		return false
	
	crime.pardoned = true
	crime.pardon_reason = reason
	crime.pardoner = pardoner
	crime.pardon_timestamp = OS.get_unix_time()
	
	# Remove from active judgments if present
	if active_judgments.has(crime_id):
		active_judgments.erase(crime_id)
	
	# Add comment about pardon
	if word_comment_system:
		word_comment_system.add_comment(crime.word, 
			"PARDON: Crime pardoned - " + reason + " (Pardoner: " + pardoner + ")", 
			word_comment_system.CommentType.DEFENSE)
	
	emit_signal("pardon_granted", crime.word, reason)
	
	# If Salem game is active, notify it
	if word_salem_controller:
		word_salem_controller.notify_pardon_granted(crime.word, reason, crime.criminal)
	
	save_to_crime_ledger(crime, true)  # Update the crime record
	return true

# ----- WORD PROCESSING -----
func _on_word_processed(word, power, source_player):
	# First run the crime detection
	analyze_word(word, power, source_player)
	
	# Update basic metrics
	metrics.total_words_processed += 1
	metrics.avg_word_power = ((metrics.avg_word_power * (metrics.total_words_processed - 1)) + power) / metrics.total_words_processed
	
	if power > metrics.max_word_power:
		metrics.max_word_power = power
	
	# Update player metrics
	if not source_player in metrics.player_power_levels:
		metrics.player_power_levels[source_player] = {
			"total_power": 0,
			"word_count": 0,
			"avg_power": 0,
			"max_power": 0
		}
	
	var player_stats = metrics.player_power_levels[source_player]
	player_stats.total_power += power
	player_stats.word_count += 1
	player_stats.avg_power = player_stats.total_power / player_stats.word_count
	
	if power > player_stats.max_power:
		player_stats.max_power = power
	
	# Check for player power anomalies (3x average)
	if player_stats.word_count > 5 and power > (player_stats.avg_power * 3):
		emit_signal("player_power_anomaly", source_player, power, player_stats.avg_power)
	
	# Update dimension metrics
	var current_dim = turn_system.current_dimension - 1 if turn_system else 0  # 0-based index
	dimension_influence[current_dim].power_total += power
	dimension_influence[current_dim].words_processed += 1
	dimension_influence[current_dim].avg_power = dimension_influence[current_dim].power_total / dimension_influence[current_dim].words_processed
	
	if power > dimension_influence[current_dim].max_power:
		dimension_influence[current_dim].max_power = power
	
	# Update current dimension in metrics array
	metrics.power_by_dimension[current_dim] += power
	
	# Record word in history
	word_history.append({
		"word": word,
		"power": power,
		"player": source_player,
		"dimension": turn_system.current_dimension if turn_system else 1,
		"turn": turn_system.current_turn if turn_system else 0,
		"timestamp": OS.get_unix_time()
	})
	
	# Check word combinations
	check_word_combinations(word, power, source_player)

func check_word_combinations(new_word, new_power, source_player):
	# Look at the last 3 words in history
	if word_history.size() >= 4:
		var recent_words = []
		for i in range(1, 4):  # Get the 3 words before this one
			recent_words.append(word_history[word_history.size() - i - 1].word)
		
		# Create combination keys
		for i in range(recent_words.size()):
			var combination = recent_words[i] + " " + new_word
			
			if not word_combinations.has(combination):
				word_combinations[combination] = {
					"count": 0,
					"total_power": 0,
					"avg_power": 0
				}
			
			word_combinations[combination].count += 1
			word_combinations[combination].total_power += new_power
			word_combinations[combination].avg_power = word_combinations[combination].total_power / word_combinations[combination].count
	
	# Check 9-word sequences (important for the 9-second rule)
	if word_history.size() >= 9:
		var nine_word_sequence = []
		for i in range(9):
			nine_word_sequence.append(word_history[word_history.size() - i - 1].word)
		
		analyze_nine_word_sequence(nine_word_sequence, source_player)

func analyze_nine_word_sequence(words, source_player):
	# Calculate total power of the sequence
	var total_sequence_power = 0
	for i in range(words.size()):
		var word_entry = word_history[word_history.size() - i - 1]
		total_sequence_power += word_entry.power
	
	# Apply the 9-second rule multiplier
	var nine_second_multiplier = 1.9  # Significant multiplier for 9-word sequences
	var adjusted_power = total_sequence_power * nine_second_multiplier
	
	# Check for sequence patterns
	var sequence_patterns = detect_sequence_patterns(words)
	
	# If patterns are found, apply additional analysis
	if sequence_patterns.size() > 0:
		for pattern in sequence_patterns:
			if pattern == "ascending":
				adjusted_power *= 1.5
			elif pattern == "descending":
				adjusted_power *= 0.7
			elif pattern == "alternating":
				adjusted_power *= 1.2
			elif pattern == "repeating":
				adjusted_power *= 2.0
	
	# Record significant sequences
	if adjusted_power >= power_thresholds.major:
		crime_history.append({
			"type": "nine_word_sequence",
			"words": words,
			"raw_power": total_sequence_power,
			"adjusted_power": adjusted_power,
			"player": source_player,
			"patterns": sequence_patterns,
			"turn": turn_system.current_turn if turn_system else 0,
			"timestamp": OS.get_unix_time()
		})
		
		# If this reaches cosmic level, add a crime
		if adjusted_power >= power_thresholds.cosmic:
			record_crime(words.join(" "), CrimeType.COSMIC, adjusted_power, source_player)

func detect_sequence_patterns(words):
	var patterns = []
	
	# Check for repeating words
	var word_counts = {}
	for word in words:
		if not word_counts.has(word):
			word_counts[word] = 0
		word_counts[word] += 1
	
	for word in word_counts.keys():
		if word_counts[word] >= 3:
			patterns.append("repeating")
			break
	
	# Check for ascending/descending word lengths
	var lengths = []
	for word in words:
		lengths.append(word.length())
	
	var ascending = true
	var descending = true
	
	for i in range(1, lengths.size()):
		if lengths[i] <= lengths[i-1]:
			ascending = false
		if lengths[i] >= lengths[i-1]:
			descending = false
	
	if ascending:
		patterns.append("ascending")
	elif descending:
		patterns.append("descending")
	
	# Check for alternating patterns
	var alternating = true
	for i in range(2, lengths.size()):
		if not (lengths[i] == lengths[i-2]):
			alternating = false
			break
	
	if alternating:
		patterns.append("alternating")
	
	return patterns

# ----- SIGNAL HANDLERS -----
func _on_turn_completed(turn_number):
	# Analyze trends every 12 turns (one full cycle)
	if turn_number % 12 == 0:
		analyze_cycle_trends()

func _on_dimension_changed(new_dimension, old_dimension):
	# Record the transition for analysis
	if old_dimension > 0 and old_dimension <= 12 and new_dimension > 0 and new_dimension <= 12:
		var old_dim_index = old_dimension - 1
		
		if not dimension_influence[old_dim_index].transitions.has(str(new_dimension)):
			dimension_influence[old_dim_index].transitions[str(new_dimension)] = 0
		dimension_influence[old_dim_index].transitions[str(new_dimension)] += 1
	
	# Special handling for Dimension 9 (Judgment)
	if new_dimension == 9:
		# When entering Judgment dimension, evaluate all recent crimes
		var recent_crimes = get_recent_crimes(1800)  # Last 30 minutes
		
		for crime in recent_crimes:
			if not crime.has("judged") or not crime.judged:
				if not crime.has("pardoned") or not crime.pardoned:
					# In dimension 9, auto-judges minor crimes only
					if crime.type == CrimeType.MINOR:
						issue_judgment(crime.id, "Guilty", "Linguistic Correction Required", "Dimension 9 Arbiter")

func _on_comment_added(word, comment_text, type):
	# Check if this is a accusation comment
	if word_comment_system and type == word_comment_system.CommentType.ACCUSATION:
		# Extract criminal from text if possible
		var criminal = "Unknown"
		
		if comment_text.to_lower().find("by ") >= 0:
			var parts = comment_text.split("by ", true, 1)
			if parts.size() > 1:
				criminal = parts[1].strip_edges()
				if criminal.ends_with("."):
					criminal = criminal.substr(0, criminal.length() - 1)
		
		# Create a minor crime for accusations
		var crime = record_crime(word, CrimeType.MINOR, 0, criminal)
		
		# If in Judgment dimension, auto-judge this crime
		if turn_system and turn_system.current_dimension == 9:
			issue_judgment(crime.id, "Accusation Filed", "Awaiting Defense", "Accuser")

func _on_defense_registered(word, defense_text):
	# Find any active judgments or crimes for this word
	var found_crime = false
	
	for crime in crime_ledger:
		if crime.word == word and not (crime.has("pardoned") and crime.pardoned):
			# If a defense is registered and we're in dimension 9, consider pardon
			if turn_system and turn_system.current_dimension == 9:
				# 50% chance of pardon for minor crimes with defense
				if crime.type == CrimeType.MINOR and randf() < 0.5:
					pardon_crime(crime.id, "Defense accepted", "Judgment Council")
				# 25% chance of pardon for moderate crimes with defense
				elif crime.type == CrimeType.MODERATE and randf() < 0.25:
					pardon_crime(crime.id, "Defense partially accepted", "Judgment Council")
			
			found_crime = true
			break
	
	# If no crime found but defense registered, add a comment
	if not found_crime and word_comment_system:
		word_comment_system.add_comment(word,
			"LEGAL NOTE: Defense registered, but no crimes on record for this word",
			word_comment_system.CommentType.OBSERVATION)

func _on_salem_crime_detected(criminal, crime_type, word_power):
	# Convert string crime type to enum
	var crime_enum = CrimeType.MINOR
	
	match crime_type.to_lower():
		"minor": crime_enum = CrimeType.MINOR
		"moderate": crime_enum = CrimeType.MODERATE
		"major": crime_enum = CrimeType.MAJOR
		"cosmic": crime_enum = CrimeType.COSMIC
	
	# Create a corresponding crime in our system
	record_crime("salem_crime_" + str(OS.get_unix_time()), crime_enum, word_power, criminal)

func analyze_cycle_trends():
	# Analyze word power trends across dimensions
	var dimension_power_deltas = []
	
	for i in range(12):
		var prev_value = metrics.power_by_dimension[i]
		var current_cycle_power = dimension_influence[i].power_total
		
		# Calculate delta from last cycle
		var delta = current_cycle_power - prev_value
		dimension_power_deltas.append({
			"dimension": i + 1,
			"delta": delta,
			"percent_change": prev_value > 0 ? (delta / prev_value) * 100 : 0
		})
		
		# Check for significant power spikes (>50% increase)
		if prev_value > 0 and delta > 0 and (delta / prev_value) > 0.5:
			emit_signal("dimension_power_spike", i + 1, delta)
	
	# Analyze player trends
	for player_name in metrics.player_power_levels.keys():
		var player = metrics.player_power_levels[player_name]
		
		# Check for potential power abuse
		if player.word_count > 20 and player.avg_power > metrics.avg_word_power * 2:
			# Player's average word power is twice the global average
			log_potential_abuse(player_name, player.avg_power, metrics.avg_word_power)
	
	# Analyze word combinations for dangerous pairs
	analyze_dangerous_combinations()

func analyze_dangerous_combinations():
	var dangerous_combinations = []
	
	for combination in word_combinations.keys():
		var combo_data = word_combinations[combination]
		
		# Check if this combination has occurred multiple times and has high power
		if combo_data.count >= 3 and combo_data.avg_power >= power_thresholds.moderate:
			dangerous_combinations.append({
				"combination": combination,
				"count": combo_data.count,
				"avg_power": combo_data.avg_power
			})
	
	# Sort by average power, descending
	dangerous_combinations.sort_custom(self, "sort_by_power_descending")
	
	# Log the top dangerous combinations
	for i in range(min(5, dangerous_combinations.size())):
		log_dangerous_combination(dangerous_combinations[i])

func sort_by_power_descending(a, b):
	return a.avg_power > b.avg_power

func log_potential_abuse(player_name, player_avg, global_avg):
	print("WARNING: Potential power abuse by player " + player_name + 
		". Average word power: " + str(player_avg) + 
		" (Global average: " + str(global_avg) + ")")
	
	# Add to crime history
	crime_history.append({
		"type": "power_abuse",
		"player": player_name,
		"player_avg": player_avg,
		"global_avg": global_avg,
		"turn": turn_system.current_turn if turn_system else 0,
		"timestamp": OS.get_unix_time()
	})
	
	# Record a crime
	record_crime("power_abuse", CrimeType.MODERATE, player_avg, player_name)

func log_dangerous_combination(combination_data):
	print("ALERT: Dangerous word combination detected: '" + 
		combination_data.combination + "'. Occurrences: " + 
		str(combination_data.count) + ", Average power: " + 
		str(combination_data.avg_power))
	
	# Add to crime history
	crime_history.append({
		"type": "dangerous_combination",
		"combination": combination_data.combination,
		"count": combination_data.count,
		"avg_power": combination_data.avg_power,
		"turn": turn_system.current_turn if turn_system else 0,
		"timestamp": OS.get_unix_time()
	})

# ----- FILE OPERATIONS -----
func load_crime_ledger():
	var file = File.new()
	var ledger_path = "user://word_crimes_ledger.txt"
	
	if not file.file_exists(ledger_path):
		print("Crime ledger not found. Starting with empty ledger.")
		return
	
	file.open(ledger_path, File.READ)
	
	while not file.eof_reached():
		var line = file.get_line()
		if line.strip_edges().empty():
			continue
		
		var json_result = JSON.parse(line)
		if json_result.error == OK:
			var crime = json_result.result
			
			# Add to ledger
			crime_ledger.append(crime)
			
			# Add to criminal records
			if not criminal_records.has(crime.criminal):
				criminal_records[crime.criminal] = []
			
			criminal_records[crime.criminal].append(crime)
			
			# Add to active judgments if judged but not executed
			if crime.has("judged") and crime.judged and crime.has("verdict"):
				if not crime.has("executed") or not crime.executed:
					active_judgments[crime.id] = {
						"crime_id": crime.id,
						"word": crime.word,
						"criminal": crime.criminal,
						"verdict": crime.verdict,
						"punishment": crime.punishment,
						"judge": crime.judge if crime.has("judge") else "System",
						"timestamp": crime.judgment_timestamp if crime.has("judgment_timestamp") else crime.timestamp,
						"executed": false,
						"active": true
					}
		else:
			print("Error parsing crime record: " + json_result.error_string)
	
	file.close()
	print("Loaded " + str(crime_ledger.size()) + " crimes from ledger")

func save_to_crime_ledger(crime, update=false):
	var file = File.new()
	var ledger_path = "user://word_crimes_ledger.txt"
	
	if update:
		# For updates, we need to update the specific line
		var temp_file = File.new()
		var temp_path = "user://word_crimes_ledger_temp.txt"
		
		file.open(ledger_path, File.READ)
		temp_file.open(temp_path, File.WRITE)
		
		while not file.eof_reached():
			var line = file.get_line()
			if line.strip_edges().empty():
				temp_file.store_line("")
				continue
			
			var json_result = JSON.parse(line)
			if json_result.error == OK:
				var existing_crime = json_result.result
				
				if existing_crime.id == crime.id:
					# Replace this crime record
					temp_file.store_line(JSON.print(crime))
				else:
					temp_file.store_line(line)
			else:
				temp_file.store_line(line)
		
		file.close()
		temp_file.close()
		
		# Replace original with temp file
		var dir = Directory.new()
		dir.remove(ledger_path)
		dir.rename(temp_path, ledger_path)
	else:
		# For new crimes, just append
		file.open(ledger_path, File.READ_WRITE)
		file.seek_end()
		
		# Add a newline if the file doesn't end with one
		if file.get_len() > 0:
			file.seek(file.get_len() - 1)
			var last_char = file.get_buffer(1).get_string_from_utf8()
			if last_char != "\n":
				file.store_line("")
		
		file.store_line(JSON.print(crime))
		file.close()

# ----- UTILITY FUNCTIONS -----
func find_crime_by_id(crime_id):
	for crime in crime_ledger:
		if crime.id == crime_id:
			return crime
	return null

func get_crime_type_name(type):
	match type:
		CrimeType.MINOR:
			return "Minor"
		CrimeType.MODERATE:
			return "Moderate"
		CrimeType.MAJOR:
			return "Major"
		CrimeType.COSMIC:
			return "Cosmic"
		_:
			return "Unknown"

func get_criminal_record(criminal):
	if criminal_records.has(criminal):
		return criminal_records[criminal]
	return []

func get_crimes_by_type(type):
	var crimes = []
	for crime in crime_ledger:
		if crime.type == type:
			crimes.append(crime)
	return crimes

func get_recent_crimes(seconds=600):
	var crimes = []
	var current_time = OS.get_unix_time()
	
	for crime in crime_ledger:
		if current_time - crime.timestamp <= seconds:
			crimes.append(crime)
	
	return crimes

func get_crime_risk_level(word, power):
	var risk_level = 0
	
	# Check for banned words
	if word.to_lower() in banned_words:
		risk_level += 3  # Major risk
	
	# Check for dangerous patterns
	for pattern_type in dangerous_patterns:
		var pattern_words = dangerous_patterns[pattern_type]
		for pattern_word in pattern_words:
			var regex = RegEx.new()
			regex.compile(pattern_word)
			if regex.search(word.to_lower()):
				risk_level += 2  # Moderate risk
				break
	
	# Check power level
	if power >= power_thresholds.cosmic:
		risk_level += 1  # Minor risk due to high power
	
	return risk_level

# ----- REPORT GENERATION -----
func export_crime_ledger():
	var report = "# WORD CRIMES LEDGER\n"
	report += "Generated: " + str(OS.get_datetime()) + "\n\n"
	
	report += "## CRIME STATISTICS\n"
	report += "- Total Crimes: " + str(crime_ledger.size()) + "\n"
	report += "- Minor Infractions: " + str(get_crimes_by_type(CrimeType.MINOR).size()) + "\n"
	report += "- Moderate Crimes: " + str(get_crimes_by_type(CrimeType.MODERATE).size()) + "\n"
	report += "- Major Offenses: " + str(get_crimes_by_type(CrimeType.MAJOR).size()) + "\n"
	report += "- Cosmic Crimes: " + str(get_crimes_by_type(CrimeType.COSMIC).size()) + "\n\n"
	
	# Known criminals
	report += "## KNOWN OFFENDERS\n"
	for criminal in criminal_records:
		report += "### " + criminal + "\n"
		report += "- Total Offenses: " + str(criminal_records[criminal].size()) + "\n"
		
		var minor = 0
		var moderate = 0
		var major = 0
		var cosmic = 0
		
		for crime in criminal_records[criminal]:
			match crime.type:
				CrimeType.MINOR: minor += 1
				CrimeType.MODERATE: moderate += 1
				CrimeType.MAJOR: major += 1
				CrimeType.COSMIC: cosmic += 1
		
		report += "- Minor: " + str(minor) + "\n"
		report += "- Moderate: " + str(moderate) + "\n"
		report += "- Major: " + str(major) + "\n"
		report += "- Cosmic: " + str(cosmic) + "\n\n"
	
	# Recent judgments
	report += "## RECENT JUDGMENTS\n"
	var judgments_listed = 0
	
	for crime in crime_ledger:
		if crime.has("judged") and crime.judged and crime.has("verdict"):
			var date = OS.get_datetime_from_unix_time(crime.judgment_timestamp if crime.has("judgment_timestamp") else crime.timestamp)
			var date_str = "%04d-%02d-%02d %02d:%02d:%02d" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
			
			report += "### Crime: " + crime.id + "\n"
			report += "- Word: " + crime.word + "\n"
			report += "- Criminal: " + crime.criminal + "\n"
			report += "- Type: " + get_crime_type_name(crime.type) + "\n"
			report += "- Verdict: " + crime.verdict + "\n"
			report += "- Punishment: " + crime.punishment + "\n"
			report += "- Date: " + date_str + "\n\n"
			
			judgments_listed += 1
			if judgments_listed >= 10:  # List at most 10 recent judgments
				break
	
	return report

# ----- SALEM GAME INTEGRATION -----
func get_player_crime_summary(player_name):
	var crimes = []
	
	# Collect all crimes associated with this player
	for crime in crime_history:
		if crime.player == player_name:
			crimes.append(crime)
	
	# Calculate summary statistics
	var total_crimes = crimes.size()
	var crime_types = {}
	var most_recent = null
	var highest_power = 0
	var highest_power_crime = null
	
	for crime in crimes:
		# Count by type
		if not crime_types.has(crime.type):
			crime_types[crime.type] = 0
		crime_types[crime.type] += 1
		
		# Track most recent
		if most_recent == null or crime.timestamp > most_recent.timestamp:
			most_recent = crime
		
		# Track highest power
		if crime.has("adjusted_power") and crime.adjusted_power > highest_power:
			highest_power = crime.adjusted_power
			highest_power_crime = crime
		elif crime.has("avg_power") and crime.avg_power > highest_power:
			highest_power = crime.avg_power
			highest_power_crime = crime
	
	return {
		"player": player_name,
		"total_crimes": total_crimes,
		"crime_types": crime_types,
		"most_recent": most_recent,
		"highest_power_crime": highest_power_crime,
		"highest_power": highest_power
	}

func get_dimension_crime_report():
	var report = []
	
	for i in range(12):
		report.append({
			"dimension": i + 1,
			"crime_count": dimension_influence[i].crime_count,
			"avg_power": dimension_influence[i].avg_power,
			"max_power": dimension_influence[i].max_power,
			"words_processed": dimension_influence[i].words_processed
		})
	
	return report

func get_evidence_for_trial(accused_player):
	var evidence = {
		"summary": get_player_crime_summary(accused_player),
		"word_history": [],
		"dangerous_patterns": [],
		"dimension_influence": []
	}
	
	# Get the player's word history
	for entry in word_history:
		if entry.player == accused_player:
			evidence.word_history.append(entry)
	
	# Get dangerous pattern matches
	for entry in evidence.word_history:
		for pattern_type in dangerous_patterns:
			var pattern_words = dangerous_patterns[pattern_type]
			for pattern_word in pattern_words:
				var regex = RegEx.new()
				regex.compile(pattern_word)
				if regex.search(entry.word.to_lower()):
					evidence.dangerous_patterns.append({
						"pattern": pattern_type,
						"word": entry.word,
						"power": entry.power,
						"dimension": entry.dimension,
						"turn": entry.turn
					})
	
	# Get dimension influence
	var dim_counts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	var dim_power = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	
	for entry in evidence.word_history:
		var dim_index = entry.dimension - 1
		dim_counts[dim_index] += 1
		dim_power[dim_index] += entry.power
	
	for i in range(12):
		if dim_counts[i] > 0:
			evidence.dimension_influence.append({
				"dimension": i + 1,
				"word_count": dim_counts[i],
				"total_power": dim_power[i],
				"avg_power": dim_power[i] / dim_counts[i]
			})
	
	return evidence

# ----- WORD POWER ANALYSIS -----
func detect_divine_word_pattern(words):
	# Check if this sequence forms a divine pattern
	
	# Rule 1: Ascending dimension power (1D to 12D)
	var ascending_dimension = true
	var last_power = 0
	
	for word in words:
		var word_data = null
		for entry in word_history:
			if entry.word == word:
				word_data = entry
				break
		
		if word_data:
			var dim_index = word_data.dimension - 1
			var dim_power = dimension_influence[dim_index].avg_power * word_data.power
			
			if dim_power <= last_power:
				ascending_dimension = false
				break
			
			last_power = dim_power
	
	# Rule 2: Follows the sacred 9-pattern
	var nine_pattern = false
	if words.size() == 9 or words.size() % 9 == 0:
		nine_pattern = true
	
	# Rule 3: Contains at least one cosmic-level word
	var has_cosmic = false
	for word in words:
		for entry in word_history:
			if entry.word == word and entry.power >= power_thresholds.cosmic:
				has_cosmic = true
				break
		
		if has_cosmic:
			break
	
	# Calculate divine pattern strength
	var divine_strength = 0
	if ascending_dimension:
		divine_strength += 50
	if nine_pattern:
		divine_strength += 30
	if has_cosmic:
		divine_strength += 20
	
	return {
		"is_divine": divine_strength >= 70,
		"strength": divine_strength,
		"ascending_dimension": ascending_dimension,
		"nine_pattern": nine_pattern,
		"has_cosmic": has_cosmic
	}