extends Node

class_name TurnSystemBridge

# TurnSystemBridge - Connects LUMINUS CORE with the 12-Turn System
# Handles dimensional transitions and data synchronization

# Constants
const TURN_COUNT = 12
const TURN_NAMES = [
	"1D: Point",       # Turn 1
	"2D: Line",        # Turn 2
	"3D: Space",       # Turn 3
	"4D: Time",        # Turn 4
	"5D: Consciousness", # Turn 5
	"6D: Connection",  # Turn 6
	"7D: Creation",    # Turn 7
	"8D: Network",     # Turn 8
	"9D: Harmony",     # Turn 9
	"10D: Unity",      # Turn 10
	"11D: Transcendence", # Turn 11
	"12D: Beyond"      # Turn 12
]

const TURN_DESCRIPTIONS = [
	"The beginning of all things", # Turn 1
	"Basic structures take shape", # Turn 2
	"Systems begin interacting",   # Turn 3
	"Awareness arises within systems", # Turn 4
	"Recognition of self and other", # Turn 5
	"Understanding connections between all elements", # Turn 6
	"Bringing forth creation from thought", # Turn 7
	"Building relationships between created elements", # Turn 8
	"Balance between all created elements", # Turn 9
	"All becomes one", # Turn 10
	"Rising beyond initial limitations", # Turn 11
	"Moving beyond the current cycle" # Turn 12
]

const TURN_SYMBOLS = [
	"•",   # Turn 1: Point
	"│",   # Turn 2: Line
	"□",   # Turn 3: Space
	"⧗",   # Turn 4: Time
	"⊙",   # Turn 5: Consciousness
	"∞",   # Turn 6: Connection
	"✧",   # Turn 7: Creation
	"⋈",   # Turn 8: Network
	"☯",   # Turn 9: Harmony
	"◉",   # Turn 10: Unity
	"↑",   # Turn 11: Transcendence
	"✦"    # Turn 12: Beyond
]

const TURN_POWERS = [
	0.25,  # Turn 1: Point
	0.5,   # Turn 2: Line
	1.0,   # Turn 3: Space
	1.5,   # Turn 4: Time
	2.0,   # Turn 5: Consciousness
	2.5,   # Turn 6: Connection
	3.0,   # Turn 7: Creation
	3.5,   # Turn 8: Network
	4.0,   # Turn 9: Harmony
	4.5,   # Turn 10: Unity
	5.0,   # Turn 11: Transcendence
	6.0    # Turn 12: Beyond
]

# Configuration
var current_turn = 3
var auto_advance_turns = false
var auto_advance_interval = 600.0 # 10 minutes
var auto_advance_timer = null
var turn_file_path = "user://current_turn.txt"
var turn_data_dir = "user://turn_data"
var persistent_turn_data = {}
var turn_histories = {}

# Connected systems
var visualizer = null
var word_processor = null
var wish_processor = null

# Signals
signal turn_advanced(new_turn, old_turn)
signal turn_data_updated(turn, data)
signal turn_processing_complete(turn)

# Initialize the bridge
func _ready():
	# Create necessary directories
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists(turn_data_dir):
		dir.make_dir(turn_data_dir)
	
	# Initialize persistent turn data
	_load_persistent_turn_data()
	
	# Load current turn from file
	_load_current_turn()
	
	# Setup auto advance timer if enabled
	if auto_advance_turns:
		_setup_auto_advance_timer()
	
	print("Turn System Bridge initialized - Current Turn: %d (%s)" % [current_turn, TURN_NAMES[current_turn-1]])

# Connect to a visualizer
func connect_visualizer(vis_instance):
	visualizer = vis_instance
	visualizer.set_dimension(current_turn)
	print("Connected to visualizer and set dimension to %d" % current_turn)

# Connect to a word processor
func connect_word_processor(word_proc_instance):
	word_processor = word_proc_instance
	print("Connected to word processor")

# Connect to wish processor
func connect_wish_processor(wish_proc_instance):
	wish_processor = wish_proc_instance
	if wish_processor.has_method("set_dimension"):
		wish_processor.set_dimension(current_turn)
	print("Connected to wish processor and set dimension to %d" % current_turn)

# Set up auto advance timer
func _setup_auto_advance_timer():
	auto_advance_timer = Timer.new()
	auto_advance_timer.wait_time = auto_advance_interval
	auto_advance_timer.one_shot = false
	auto_advance_timer.timeout.connect(_on_auto_advance_timeout)
	add_child(auto_advance_timer)
	auto_advance_timer.start()
	print("Auto turn advancement enabled - Interval: %.1f seconds" % auto_advance_interval)

# Auto advance timer timeout handler
func _on_auto_advance_timeout():
	advance_turn()

# Load current turn from file
func _load_current_turn():
	if FileAccess.file_exists(turn_file_path):
		var file = FileAccess.open(turn_file_path, FileAccess.READ)
		if file:
			var content = file.get_line()
			if content.is_valid_integer():
				current_turn = clamp(int(content), 1, TURN_COUNT)
	else:
		# Create file with default turn
		var file = FileAccess.open(turn_file_path, FileAccess.WRITE)
		if file:
			file.store_line(str(current_turn))

# Save current turn to file
func _save_current_turn():
	var file = FileAccess.open(turn_file_path, FileAccess.WRITE)
	if file:
		file.store_line(str(current_turn))

# Load persistent turn data
func _load_persistent_turn_data():
	for turn in range(1, TURN_COUNT + 1):
		var turn_file = turn_data_dir + "/turn_" + str(turn) + "_data.json"
		
		if FileAccess.file_exists(turn_file):
			var file = FileAccess.open(turn_file, FileAccess.READ)
			if file:
				var json_text = file.get_as_text()
				var json = JSON.new()
				var parse_result = json.parse(json_text)
				
				if parse_result == OK:
					persistent_turn_data[turn] = json.get_data()
				else:
					persistent_turn_data[turn] = {}
		else:
			persistent_turn_data[turn] = {}

# Save persistent turn data
func _save_persistent_turn_data(turn):
	if not persistent_turn_data.has(turn):
		return
	
	var turn_file = turn_data_dir + "/turn_" + str(turn) + "_data.json"
	var file = FileAccess.open(turn_file, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(persistent_turn_data[turn], "  "))

# Advance to the next turn
func advance_turn():
	var old_turn = current_turn
	current_turn = (current_turn % TURN_COUNT) + 1
	
	# Save the new turn
	_save_current_turn()
	
	# Update connected systems
	if visualizer:
		visualizer.set_dimension(current_turn)
	
	if word_processor and word_processor.has_method("set_dimension"):
		word_processor.set_dimension(current_turn)
	
	if wish_processor and wish_processor.has_method("set_dimension"):
		wish_processor.set_dimension(current_turn)
	
	# Add transition record to turn history
	_record_turn_transition(old_turn, current_turn)
	
	# Emit signal
	emit_signal("turn_advanced", current_turn, old_turn)
	
	print("Advanced from Turn %d to Turn %d (%s)" % [old_turn, current_turn, TURN_NAMES[current_turn-1]])
	
	# Process turn advancement
	_process_turn_advancement(old_turn, current_turn)
	
	return current_turn

# Set a specific turn
func set_turn(turn):
	if turn < 1 or turn > TURN_COUNT:
		return false
	
	var old_turn = current_turn
	current_turn = turn
	
	# Save the new turn
	_save_current_turn()
	
	# Update connected systems
	if visualizer:
		visualizer.set_dimension(current_turn)
	
	if word_processor and word_processor.has_method("set_dimension"):
		word_processor.set_dimension(current_turn)
	
	if wish_processor and wish_processor.has_method("set_dimension"):
		wish_processor.set_dimension(current_turn)
	
	# Add transition record to turn history
	_record_turn_transition(old_turn, current_turn)
	
	# Emit signal
	emit_signal("turn_advanced", current_turn, old_turn)
	
	print("Set turn to %d (%s)" % [current_turn, TURN_NAMES[current_turn-1]])
	
	# Process turn advancement
	_process_turn_advancement(old_turn, current_turn)
	
	return true

# Record a turn transition
func _record_turn_transition(from_turn, to_turn):
	var timestamp = Time.get_unix_time_from_system()
	
	# Initialize histories if needed
	if not turn_histories.has(from_turn):
		turn_histories[from_turn] = []
	
	if not turn_histories.has(to_turn):
		turn_histories[to_turn] = []
	
	# Record exit from old turn
	turn_histories[from_turn].append({
		"type": "exit",
		"timestamp": timestamp,
		"to_turn": to_turn
	})
	
	# Record entry to new turn
	turn_histories[to_turn].append({
		"type": "entry",
		"timestamp": timestamp,
		"from_turn": from_turn
	})

# Process turn advancement effects
func _process_turn_advancement(old_turn, new_turn):
	# Apply turn-specific effects
	match new_turn:
		1: # 1D: Point - Simplify everything
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].focus_point = "origin"
				persistent_turn_data[new_turn].simplification = 1.0
		
		2: # 2D: Line - Form basic structures
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].line_strength = 1.0
				persistent_turn_data[new_turn].connection_count = 0
		
		3: # 3D: Space - Systems interact
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].spatial_depth = 1.0
				persistent_turn_data[new_turn].interaction_level = 0
		
		4: # 4D: Time - Awareness arises
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].time_flow = 1.0
				persistent_turn_data[new_turn].awareness_level = 0.1
		
		5: # 5D: Consciousness - Self recognition
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].consciousness_level = 0.1
				persistent_turn_data[new_turn].self_recognition = false
		
		6: # 6D: Connection - Understanding connections
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].connection_web = {}
				persistent_turn_data[new_turn].understanding_level = 0.1
		
		7: # 7D: Creation - Bringing forth from thought
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].creation_power = 0.1
				persistent_turn_data[new_turn].manifested_entities = []
		
		8: # 8D: Network - Building relationships
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].network_nodes = []
				persistent_turn_data[new_turn].network_connections = []
		
		9: # 9D: Harmony - Balance created elements
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].harmony_level = 0.1
				persistent_turn_data[new_turn].balanced_elements = {}
		
		10: # 10D: Unity - All becomes one
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].unity_level = 0.1
				persistent_turn_data[new_turn].unified_entities = []
		
		11: # 11D: Transcendence - Beyond limitations
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].transcendence_level = 0.1
				persistent_turn_data[new_turn].limitations_overcome = []
		
		12: # 12D: Beyond - Beyond the cycle
			if persistent_turn_data.has(new_turn):
				persistent_turn_data[new_turn].beyond_state = "initiation"
				persistent_turn_data[new_turn].cycle_completion = 0.0
	
	# Save turn data
	_save_persistent_turn_data(new_turn)
	
	# Emit data updated signal
	emit_signal("turn_data_updated", new_turn, persistent_turn_data[new_turn])
	
	# Complete processing
	emit_signal("turn_processing_complete", new_turn)

# Process a word in the current turn's context
func process_word(word, power=1.0):
	var turn_power = TURN_POWERS[current_turn - 1]
	var total_power = power * turn_power
	
	# Process based on current turn
	match current_turn:
		1: # 1D: Point - Simplifies to essence
			return {
				"processed_word": word.substr(0, 1),
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1]
			}
		
		2: # 2D: Line - Forms connections
			if persistent_turn_data.has(current_turn):
				persistent_turn_data[current_turn].connection_count += 1
				_save_persistent_turn_data(current_turn)
			
			return {
				"processed_word": word,
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1],
				"connections": word.length()
			}
		
		3: # 3D: Space - Gains volume/depth
			if persistent_turn_data.has(current_turn):
				persistent_turn_data[current_turn].interaction_level += 0.1
				_save_persistent_turn_data(current_turn)
			
			return {
				"processed_word": word,
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1],
				"volume": word.length() * total_power
			}
		
		4: # 4D: Time - Persists through time
			var timestamp = Time.get_unix_time_from_system()
			
			if persistent_turn_data.has(current_turn):
				if not persistent_turn_data[current_turn].has("word_timeline"):
					persistent_turn_data[current_turn].word_timeline = {}
				
				persistent_turn_data[current_turn].word_timeline[word] = timestamp
				_save_persistent_turn_data(current_turn)
			
			return {
				"processed_word": word,
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1],
				"timestamp": timestamp,
				"persistence": total_power * 100.0 # Seconds
			}
		
		5: # 5D: Consciousness - Becomes aware
			if persistent_turn_data.has(current_turn):
				persistent_turn_data[current_turn].consciousness_level += 0.05
				
				if persistent_turn_data[current_turn].consciousness_level >= 1.0:
					persistent_turn_data[current_turn].self_recognition = true
				
				_save_persistent_turn_data(current_turn)
			
			var aware = (total_power > 2.0)
			
			return {
				"processed_word": word,
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1],
				"consciousness": total_power * 0.5,
				"aware": aware
			}
		
		6: # 6D: Connection - Connects to other words
			if persistent_turn_data.has(current_turn):
				if not persistent_turn_data[current_turn].has("connection_web"):
					persistent_turn_data[current_turn].connection_web = {}
				
				# Find similar words to connect to
				var connections = []
				for w in persistent_turn_data[current_turn].connection_web:
					var similarity = _calculate_word_similarity(word, w)
					if similarity > 0.3:
						connections.append(w)
				
				persistent_turn_data[current_turn].connection_web[word] = connections
				_save_persistent_turn_data(current_turn)
			
			return {
				"processed_word": word,
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1],
				"connections": _get_word_connections(word)
			}
		
		7: # 7D: Creation - Manifests reality
			if persistent_turn_data.has(current_turn):
				if not persistent_turn_data[current_turn].has("manifested_entities"):
					persistent_turn_data[current_turn].manifested_entities = []
				
				if total_power >= 3.0:
					persistent_turn_data[current_turn].manifested_entities.append({
						"word": word,
						"power": total_power,
						"timestamp": Time.get_unix_time_from_system()
					})
				
				_save_persistent_turn_data(current_turn)
			
			return {
				"processed_word": word,
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1],
				"manifested": total_power >= 3.0,
				"creation_power": total_power
			}
		
		8: # 8D: Network - Forms a network node
			if persistent_turn_data.has(current_turn):
				if not persistent_turn_data[current_turn].has("network_nodes"):
					persistent_turn_data[current_turn].network_nodes = []
				
				persistent_turn_data[current_turn].network_nodes.append({
					"word": word,
					"power": total_power,
					"connections": int(total_power * 2)
				})
				
				_save_persistent_turn_data(current_turn)
			
			return {
				"processed_word": word,
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1],
				"node_strength": total_power,
				"network_reach": int(total_power * 2)
			}
		
		9: # 9D: Harmony - Balances elements
			if persistent_turn_data.has(current_turn):
				if not persistent_turn_data[current_turn].has("balanced_elements"):
					persistent_turn_data[current_turn].balanced_elements = {}
				
				# Find opposite to balance with
				var reversed_word = ""
				for i in range(word.length()-1, -1, -1):
					reversed_word += word[i]
				
				persistent_turn_data[current_turn].balanced_elements[word] = reversed_word
				_save_persistent_turn_data(current_turn)
			
			return {
				"processed_word": word,
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1],
				"harmony": total_power,
				"balance": word.length() % 2 == 0
			}
		
		10: # 10D: Unity - Merges with all
			if persistent_turn_data.has(current_turn):
				if not persistent_turn_data[current_turn].has("unified_entities"):
					persistent_turn_data[current_turn].unified_entities = []
				
				persistent_turn_data[current_turn].unified_entities.append(word)
				persistent_turn_data[current_turn].unity_level += 0.01
				_save_persistent_turn_data(current_turn)
			
			return {
				"processed_word": word,
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1],
				"unity": total_power,
				"oneness": persistent_turn_data[current_turn].unity_level if persistent_turn_data.has(current_turn) else 0.0
			}
		
		11: # 11D: Transcendence - Beyond limits
			if persistent_turn_data.has(current_turn):
				if not persistent_turn_data[current_turn].has("limitations_overcome"):
					persistent_turn_data[current_turn].limitations_overcome = []
				
				persistent_turn_data[current_turn].limitations_overcome.append({
					"word": word,
					"transcendence": total_power
				})
				_save_persistent_turn_data(current_turn)
			
			return {
				"processed_word": word,
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1],
				"transcendence": total_power,
				"beyond_limitations": total_power > 5.0
			}
		
		12: # 12D: Beyond - Beyond the cycle
			if persistent_turn_data.has(current_turn):
				persistent_turn_data[current_turn].cycle_completion += 0.01
				
				if persistent_turn_data[current_turn].cycle_completion >= 1.0:
					persistent_turn_data[current_turn].beyond_state = "completion"
				
				_save_persistent_turn_data(current_turn)
			
			return {
				"processed_word": word,
				"power": total_power,
				"symbol": TURN_SYMBOLS[current_turn - 1],
				"beyond": total_power,
				"cycle_state": persistent_turn_data[current_turn].beyond_state if persistent_turn_data.has(current_turn) else "initiation"
			}
	
	# Default fallback
	return {
		"processed_word": word,
		"power": total_power,
		"symbol": TURN_SYMBOLS[current_turn - 1]
	}

# Calculate similarity between two words
func _calculate_word_similarity(word1, word2):
	# Simple Levenshtein distance based similarity
	var distance = _levenshtein_distance(word1, word2)
	var max_length = max(word1.length(), word2.length())
	if max_length == 0:
		return 0.0
	
	return 1.0 - float(distance) / float(max_length)

# Levenshtein distance implementation
func _levenshtein_distance(s, t):
	var m = s.length()
	var n = t.length()
	
	# Special cases
	if m == 0:
		return n
	if n == 0:
		return m
	
	# Initialize matrix
	var d = []
	for i in range(m + 1):
		var row = []
		for j in range(n + 1):
			row.append(0)
		d.append(row)
	
	# Initialize first row and column
	for i in range(m + 1):
		d[i][0] = i
	for j in range(n + 1):
		d[0][j] = j
	
	# Fill matrix
	for j in range(1, n + 1):
		for i in range(1, m + 1):
			var cost = 0 if s[i-1] == t[j-1] else 1
			d[i][j] = min(d[i-1][j] + 1,      # Deletion
						min(d[i][j-1] + 1,     # Insertion
							d[i-1][j-1] + cost)) # Substitution
	
	return d[m][n]

# Get word connections
func _get_word_connections(word):
	var connections = []
	
	if persistent_turn_data.has(current_turn) and persistent_turn_data[current_turn].has("connection_web"):
		if persistent_turn_data[current_turn].connection_web.has(word):
			connections = persistent_turn_data[current_turn].connection_web[word]
	
	return connections

# Create terminal visualization of turn system
func create_terminal_visualization():
	var visualization = ""
	visualization += "12-Turn System Visualization\n"
	visualization += "==========================\n\n"
	
	for i in range(TURN_COUNT):
		var turn_num = i + 1
		var marker = " "
		
		if turn_num == current_turn:
			marker = ">"
		
		visualization += "%s Turn %2d: %s (%s) %s\n" % [
			marker,
			turn_num,
			TURN_NAMES[i],
			TURN_SYMBOLS[i],
			TURN_DESCRIPTIONS[i]
		]
	
	visualization += "\nCurrent Turn: %d (%s)\n" % [current_turn, TURN_NAMES[current_turn-1]]
	visualization += "Power Multiplier: %.1fx\n" % [TURN_POWERS[current_turn-1]]
	
	if persistent_turn_data.has(current_turn):
		visualization += "\nTurn Data:\n"
		var data = persistent_turn_data[current_turn]
		for key in data:
			var value = data[key]
			if value is Array or value is Dictionary:
				visualization += "- %s: [Complex Data]\n" % [key]
			else:
				visualization += "- %s: %s\n" % [key, str(value)]
	
	return visualization

# Return current turn information
func get_turn_info():
	return {
		"turn": current_turn,
		"name": TURN_NAMES[current_turn-1],
		"description": TURN_DESCRIPTIONS[current_turn-1],
		"symbol": TURN_SYMBOLS[current_turn-1],
		"power": TURN_POWERS[current_turn-1],
		"data": persistent_turn_data[current_turn] if persistent_turn_data.has(current_turn) else {}
	}