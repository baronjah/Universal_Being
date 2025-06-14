extends Node

# Word Dream Storage
# Persistent storage system for word dreams and comments
# Terminal 1: Divine Word Genesis

class_name WordDreamStorage

# ----- MEMORY TIERS -----
# Tier 1: RAM - Short-term memory (session only)
# Tier 2: C: Drive - Semi-permanent memory
# Tier 3: D: Drive - Eternal memory (never deleted)

# Storage paths
var tier1_path = "user://ram_storage/" # RAM (Tier 1)
var tier2_path = "user://c_drive/" # C: Drive (Tier 2)
var tier3_path = "user://d_drive/" # D: Drive (Tier 3)

# ----- STORAGE CONTAINERS -----
var dreams = {
	1: [], # Tier 1 dreams
	2: [], # Tier 2 dreams
	3: []  # Tier 3 dreams (eternal)
}

var comments = {
	1: [], # Tier 1 comments
	2: [], # Tier 2 comments
	3: []  # Tier 3 comments (eternal)
}

var dimension_records = {}
var defense_records = {}

# Auto-save timer
var auto_save_timer = null
var auto_save_interval = 60 # Save every minute

# References to other systems
var word_comment_system = null
var turn_system = null

# ----- SIGNALS -----
signal dream_saved(dream_id, tier)
signal dream_loaded(dream_data)
signal comment_saved(comment_id, tier)
signal dimension_record_saved(dimension, record_id, tier)
signal dimension_record_loaded(dimension, record_data)
signal defense_record_saved(defense_id, tier)
signal defense_record_loaded(defense_id, record_data)
signal memory_backup_completed(backup_path)
signal storage_tier_changed(new_tier)

# ----- MEMORY STATISTICS -----
var memory_stats = {
	"dreams_saved": 0,
	"dreams_loaded": 0,
	"comments_saved": 0,
	"dimension_records_saved": 0,
	"defense_records_saved": 0,
	"tier_1_size": 0,
	"tier_2_size": 0,
	"tier_3_size": 0,
	"last_backup_time": 0,
	"backup_count": 0
}

func _ready():
	print("Word Dream Storage initialized")
	print("Memory Tiers: RAM (1), C: Drive (2), D: Drive (3)")
	
	initialize_storage()
	connect_systems()
	start_auto_save()

func initialize_storage():
	# Create storage directories
	var dir = Directory.new()
	if not dir.dir_exists(tier1_path):
		dir.make_dir_recursive(tier1_path)
	
	if not dir.dir_exists(tier2_path):
		dir.make_dir_recursive(tier2_path)
	
	if not dir.dir_exists(tier3_path):
		dir.make_dir_recursive(tier3_path)
	
	# Initialize dimension record containers
	for i in range(1, 13):
		dimension_records[i] = []
	
	# Load persistent data
	load_persistent_memories()

func connect_systems():
	word_comment_system = get_node_or_null("/root/WordCommentSystem")
	turn_system = get_node_or_null("/root/TurnSystem")
	
	if word_comment_system:
		word_comment_system.connect("dream_recorded", self, "_on_dream_recorded")
		word_comment_system.connect("comment_added", self, "_on_comment_added")
		word_comment_system.connect("defense_registered", self, "_on_defense_registered")
	
	if turn_system:
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")
		turn_system.connect("turn_completed", self, "_on_turn_completed")

func start_auto_save():
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = auto_save_interval
	auto_save_timer.one_shot = false
	auto_save_timer.connect("timeout", self, "_on_auto_save_timeout")
	add_child(auto_save_timer)
	auto_save_timer.start()

# ----- DREAM STORAGE FUNCTIONS -----
func save_dream(dream_data, tier=1):
	# Generate ID if not present
	if not dream_data.has("id"):
		dream_data["id"] = "dream_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
	
	# Add timestamp if not present
	if not dream_data.has("timestamp"):
		dream_data["timestamp"] = OS.get_unix_time()
	
	# Add tier information
	dream_data["tier"] = tier
	
	# Store in appropriate tier
	dreams[tier].append(dream_data)
	
	# Update stats
	memory_stats.dreams_saved += 1
	update_memory_size_stats()
	
	# If tier 2 or 3, save to disk
	if tier >= 2:
		persist_to_disk(dream_data, tier, "dreams")
	
	# Emit signal
	emit_signal("dream_saved", dream_data.id, tier)
	
	print("Dream saved to tier " + str(tier) + ": " + dream_data.id)
	return dream_data.id

func load_dream(dream_id):
	# Check if in tier 1
	for dream in dreams[1]:
		if dream.id == dream_id:
			emit_signal("dream_loaded", dream)
			memory_stats.dreams_loaded += 1
			return dream
	
	# Check if in tier 2
	for dream in dreams[2]:
		if dream.id == dream_id:
			emit_signal("dream_loaded", dream)
			memory_stats.dreams_loaded += 1
			return dream
	
	# Check if in tier 3
	for dream in dreams[3]:
		if dream.id == dream_id:
			emit_signal("dream_loaded", dream)
			memory_stats.dreams_loaded += 1
			return dream
	
	# Not found in memory, try to load from disk
	var tier_2_path = tier2_path + "dreams_" + dream_id + ".json"
	var tier_3_path = tier3_path + "dreams_" + dream_id + ".json"
	
	var file = File.new()
	if file.file_exists(tier_3_path):
		var dream = load_from_disk(tier_3_path)
		if dream:
			dreams[3].append(dream)
			emit_signal("dream_loaded", dream)
			memory_stats.dreams_loaded += 1
			return dream
	
	if file.file_exists(tier_2_path):
		var dream = load_from_disk(tier_2_path)
		if dream:
			dreams[2].append(dream)
			emit_signal("dream_loaded", dream)
			memory_stats.dreams_loaded += 1
			return dream
	
	print("Dream not found: " + dream_id)
	return null

func save_comment(comment_data, tier=1):
	# Generate ID if not present
	if not comment_data.has("id"):
		comment_data["id"] = "comment_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
	
	# Add timestamp if not present
	if not comment_data.has("timestamp"):
		comment_data["timestamp"] = OS.get_unix_time()
	
	# Add tier information
	comment_data["tier"] = tier
	
	# Store in appropriate tier
	comments[tier].append(comment_data)
	
	# Update stats
	memory_stats.comments_saved += 1
	update_memory_size_stats()
	
	# If tier 2 or 3, save to disk
	if tier >= 2:
		persist_to_disk(comment_data, tier, "comments")
	
	# Emit signal
	emit_signal("comment_saved", comment_data.id, tier)
	
	print("Comment saved to tier " + str(tier) + ": " + comment_data.id)
	return comment_data.id

# ----- DIMENSION RECORDS -----
func save_dimension_record(dimension, record_data, tier=1):
	# Validate dimension
	if dimension < 1 or dimension > 12:
		print("Invalid dimension: " + str(dimension))
		return null
	
	# Generate ID if not present
	if not record_data.has("id"):
		record_data["id"] = "dimension_" + str(dimension) + "_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
	
	# Add timestamp and dimension information
	if not record_data.has("timestamp"):
		record_data["timestamp"] = OS.get_unix_time()
	
	record_data["dimension"] = dimension
	record_data["tier"] = tier
	
	# Store in dimension records
	dimension_records[dimension].append(record_data)
	
	# Update stats
	memory_stats.dimension_records_saved += 1
	update_memory_size_stats()
	
	# If tier 2 or 3, save to disk
	if tier >= 2:
		persist_to_disk(record_data, tier, "dimension_" + str(dimension))
	
	# Emit signal
	emit_signal("dimension_record_saved", dimension, record_data.id, tier)
	
	print("Dimension " + str(dimension) + " record saved to tier " + str(tier) + ": " + record_data.id)
	return record_data.id

func load_dimension_records(dimension):
	# Validate dimension
	if dimension < 1 or dimension > 12:
		print("Invalid dimension: " + str(dimension))
		return []
	
	if dimension_records.has(dimension):
		return dimension_records[dimension]
	
	return []

# ----- DEFENSE RECORDS -----
func save_defense_record(defense_id, record_data, tier=2):
	# Add defense ID if not present
	if not record_data.has("id"):
		record_data["id"] = defense_id
	
	# Add timestamp if not present
	if not record_data.has("timestamp"):
		record_data["timestamp"] = OS.get_unix_time()
	
	record_data["tier"] = tier
	
	# Store in defense records
	defense_records[defense_id] = record_data
	
	# Update stats
	memory_stats.defense_records_saved += 1
	update_memory_size_stats()
	
	# If tier 2 or 3, save to disk
	if tier >= 2:
		persist_to_disk(record_data, tier, "defense")
	
	# Emit signal
	emit_signal("defense_record_saved", defense_id, tier)
	
	print("Defense record saved to tier " + str(tier) + ": " + defense_id)
	return defense_id

func load_defense_record(defense_id):
	if defense_records.has(defense_id):
		return defense_records[defense_id]
	
	# Not found in memory, try to load from disk
	var tier_2_path = tier2_path + "defense_" + defense_id + ".json"
	var tier_3_path = tier3_path + "defense_" + defense_id + ".json"
	
	var file = File.new()
	if file.file_exists(tier_3_path):
		var defense = load_from_disk(tier_3_path)
		if defense:
			defense_records[defense_id] = defense
			emit_signal("defense_record_loaded", defense_id, defense)
			return defense
	
	if file.file_exists(tier_2_path):
		var defense = load_from_disk(tier_2_path)
		if defense:
			defense_records[defense_id] = defense
			emit_signal("defense_record_loaded", defense_id, defense)
			return defense
	
	print("Defense record not found: " + defense_id)
	return null

# ----- MEMORY MANAGEMENT -----
func promote_to_tier(data_id, from_tier, to_tier):
	# Can only promote upward
	if to_tier <= from_tier:
		return false
	
	# Check if data exists in the source tier
	var data = null
	var data_type = ""
	
	# Check in dreams
	for dream in dreams[from_tier]:
		if dream.id == data_id:
			data = dream
			data_type = "dreams"
			break
	
	# Check in comments
	if not data:
		for comment in comments[from_tier]:
			if comment.id == data_id:
				data = comment
				data_type = "comments"
				break
	
	# Check in dimension records
	if not data:
		for dimension in dimension_records:
			for record in dimension_records[dimension]:
				if record.id == data_id:
					data = record
					data_type = "dimension_" + str(dimension)
					break
	
	# Check in defense records
	if not data:
		if defense_records.has(data_id):
			data = defense_records[data_id]
			data_type = "defense"
	
	if not data:
		print("Data not found for promotion: " + data_id)
		return false
	
	# Update tier information
	data.tier = to_tier
	
	# Remove from source tier arrays if necessary
	if data_type == "dreams":
		dreams[from_tier].erase(data)
		dreams[to_tier].append(data)
	elif data_type == "comments":
		comments[from_tier].erase(data)
		comments[to_tier].append(data)
	
	# Persist to appropriate tier storage
	persist_to_disk(data, to_tier, data_type)
	
	# Emit signal
	emit_signal("storage_tier_changed", to_tier)
	
	print("Promoted " + data_id + " from tier " + str(from_tier) + " to tier " + str(to_tier))
	return true

func persist_to_disk(data, tier, category):
	var base_path = ""
	
	if tier == 2:
		base_path = tier2_path
	elif tier == 3:
		base_path = tier3_path
	else:
		# Tier 1 is not persisted
		return false
	
	var file_name = category + "_" + data.id + ".json"
	var file_path = base_path + file_name
	
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_string(JSON.print(data, "  "))
	file.close()
	
	return true

func load_from_disk(file_path):
	var file = File.new()
	if not file.file_exists(file_path):
		return null
	
	file.open(file_path, File.READ)
	var content = file.get_as_text()
	file.close()
	
	var result = JSON.parse(content)
	if result.error == OK:
		return result.result
	else:
		print("Error parsing file: " + file_path)
		print("Error: " + str(result.error_string))
		return null

func load_persistent_memories():
	var dir = Directory.new()
	
	# Load tier 2
	if dir.open(tier2_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".json"):
				var file_path = tier2_path + file_name
				var data = load_from_disk(file_path)
				
				if data and data.has("tier") and data.has("id"):
					if file_name.begins_with("dreams_"):
						dreams[2].append(data)
					elif file_name.begins_with("comments_"):
						comments[2].append(data)
					elif file_name.begins_with("defense_"):
						defense_records[data.id] = data
					elif file_name.begins_with("dimension_"):
						var dimension = int(file_name.split("_")[1])
						if dimension_records.has(dimension):
							dimension_records[dimension].append(data)
			
			file_name = dir.get_next()
	
	# Load tier 3
	if dir.open(tier3_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".json"):
				var file_path = tier3_path + file_name
				var data = load_from_disk(file_path)
				
				if data and data.has("tier") and data.has("id"):
					if file_name.begins_with("dreams_"):
						dreams[3].append(data)
					elif file_name.begins_with("comments_"):
						comments[3].append(data)
					elif file_name.begins_with("defense_"):
						defense_records[data.id] = data
					elif file_name.begins_with("dimension_"):
						var dimension = int(file_name.split("_")[1])
						if dimension_records.has(dimension):
							dimension_records[dimension].append(data)
			
			file_name = dir.get_next()
	
	update_memory_size_stats()
	print("Loaded persistent memories: " + str(dreams[2].size() + dreams[3].size()) + " dreams, " + 
		  str(comments[2].size() + comments[3].size()) + " comments")

# ----- AUTOMATIC ARCHIVING -----

# Archive important dreams to higher tiers
func archive_dreams(min_power=50, min_tier=2):
	for tier in [1, 2]:
		for dream in dreams[tier]:
			# Only archive powerful dreams
			if dream.has("power") and dream.power >= min_power and dream.tier < min_tier:
				promote_to_tier(dream.id, dream.tier, min_tier)

# Archive important comments (divine, warning) to higher tiers
func archive_important_comments():
	if word_comment_system:
		for tier in [1, 2]:
			for comment in comments[tier]:
				# Archive divine and warning comments
				if (comment.has("type") and (comment.type == word_comment_system.CommentType.DIVINE or 
				comment.type == word_comment_system.CommentType.WARNING)) and comment.tier < 3:
					promote_to_tier(comment.id, comment.tier, 3)

# Archive accepted defenses to higher tiers
func archive_accepted_defenses():
	# Iterate through defense records and promote accepted ones
	for defense_id in defense_records:
		var defense = defense_records[defense_id]
		if defense.has("accepted") and defense.accepted and defense.tier < 3:
			promote_to_tier(defense_id, defense.tier, 3)

func backup_memories():
	var timestamp = OS.get_unix_time()
	var backup_dir = "user://word_dreams/backups/" + str(timestamp) + "/"
	
	var dir = Directory.new()
	if not dir.dir_exists(backup_dir):
		dir.make_dir_recursive(backup_dir)
	
	# Backup tier 2
	var tier_2_backup = backup_dir + "tier_2/"
	dir.make_dir_recursive(tier_2_backup)
	
	if dir.open(tier2_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".json"):
				dir.copy(tier2_path + file_name, tier_2_backup + file_name)
			file_name = dir.get_next()
	
	# Backup tier 3
	var tier_3_backup = backup_dir + "tier_3/"
	dir.make_dir_recursive(tier_3_backup)
	
	if dir.open(tier3_path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".json"):
				dir.copy(tier3_path + file_name, tier_3_backup + file_name)
			file_name = dir.get_next()
	
	# Update stats
	memory_stats.last_backup_time = timestamp
	memory_stats.backup_count += 1
	
	# Signal backup completion
	emit_signal("memory_backup_completed", backup_dir)
	
	print("Memory backup completed: " + backup_dir)
	return backup_dir

# Save all in-memory data to disk
func save_all_data():
	# Process dreams
	if word_comment_system and word_comment_system.dream_fragments:
		for dream in word_comment_system.dream_fragments:
			var dream_data = dream.duplicate()
			save_dream(dream_data)
	
	# Process comments
	if word_comment_system and word_comment_system.comment_history:
		for entry in word_comment_system.comment_history:
			var comment_data = {
				"word": entry.word,
				"text": entry.comment.text,
				"type": entry.comment.type,
				"author": entry.comment.author,
				"timestamp": entry.comment.timestamp,
				"turn": entry.comment.turn,
				"dimension": entry.comment.dimension
			}
			save_comment(comment_data)
	
	# Process defense statements
	if word_comment_system:
		for word in word_comment_system.defense_statements:
			var defenses_list = word_comment_system.defense_statements[word]
			for defense in defenses_list:
				var defense_data = defense.duplicate()
				defense_data["word"] = word
				save_defense_record(word + "_" + str(defense.timestamp), defense_data)
	
	# Save dimension records if in a turn system
	if turn_system:
		var current_dimension = turn_system.current_dimension
		var dimension_data = {
			"dimension": current_dimension,
			"turn": turn_system.current_turn,
			"timestamp": OS.get_unix_time()
		}
		
		# Add memory stats for this dimension
		if word_comment_system:
			var dreams_count = 0
			var comments_count = 0
			
			for dream in word_comment_system.dream_fragments:
				if dream.dimension == current_dimension:
					dreams_count += 1
			
			for entry in word_comment_system.comment_history:
				if entry.comment.dimension == current_dimension:
					comments_count += 1
			
			dimension_data["dreams_count"] = dreams_count
			dimension_data["comments_count"] = comments_count
		
		save_dimension_record(current_dimension, dimension_data)
	
	print("All data saved to persistent storage")

# ----- UTILITY FUNCTIONS -----
func update_memory_size_stats():
	memory_stats.tier_1_size = dreams[1].size() + comments[1].size()
	memory_stats.tier_2_size = dreams[2].size() + comments[2].size()
	memory_stats.tier_3_size = dreams[3].size() + comments[3].size()
	
	for dimension in dimension_records:
		memory_stats.tier_1_size += dimension_records[dimension].size()
	
	memory_stats.tier_1_size += defense_records.size()

func get_memory_stats():
	update_memory_size_stats()
	return memory_stats

func clear_tier_1_memory():
	dreams[1] = []
	comments[1] = []
	
	for dimension in dimension_records:
		# Keep only tier 2 and 3 records
		var kept_records = []
		for record in dimension_records[dimension]:
			if record.tier >= 2:
				kept_records.append(record)
		dimension_records[dimension] = kept_records
	
	# Keep only tier 2 and 3 defense records
	var kept_defenses = {}
	for defense_id in defense_records:
		if defense_records[defense_id].tier >= 2:
			kept_defenses[defense_id] = defense_records[defense_id]
	defense_records = kept_defenses
	
	update_memory_size_stats()
	print("Tier 1 memory cleared")
	return true

func generate_dream_report():
	var report = "# DIVINE WORD DREAM SYSTEM REPORT\n"
	report += "Generated: " + str(OS.get_datetime()) + "\n\n"
	
	report += "## MEMORY STATISTICS\n"
	report += "- Dreams saved: " + str(memory_stats.dreams_saved) + "\n"
	report += "- Tier 1 memory size: " + str(memory_stats.tier_1_size) + " items\n" 
	report += "- Tier 2 memory size: " + str(memory_stats.tier_2_size) + " items\n"
	report += "- Tier 3 memory size: " + str(memory_stats.tier_3_size) + " items\n"
	report += "- Backups created: " + str(memory_stats.backup_count) + "\n\n"
	
	report += "## TIER 3 DREAMS (ETERNAL)\n"
	for dream in dreams[3]:
		var date = OS.get_datetime_from_unix_time(dream.timestamp)
		var date_str = "%04d-%02d-%02d %02d:%02d:%02d" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
		
		report += "### Dream: " + dream.id + "\n"
		report += "- Date: " + date_str + "\n"
		report += "- Power: " + str(dream.power if dream.has("power") else "Unknown") + "\n"
		
		if dream.has("dream_text"):
			report += dream.dream_text + "\n\n"
		elif dream.has("narrative"):
			report += dream.narrative + "\n\n"
		else:
			report += "[Dream content unavailable]\n\n"
	
	return report

# ----- SIGNAL HANDLERS -----

func _on_dream_recorded(dream_text, power_level):
	# Find the dream in the word_comment_system
	if word_comment_system and word_comment_system.dream_fragments.size() > 0:
		var last_dream = word_comment_system.dream_fragments.back()
		save_dream(last_dream)

func _on_comment_added(word, comment_text, type):
	# Find the comment in the word_comment_system
	if word_comment_system and word_comment_system.word_comments.has(word):
		var comments_list = word_comment_system.word_comments[word]
		if comments_list.size() > 0:
			var last_comment = comments_list.back().duplicate()
			last_comment["word"] = word
			save_comment(last_comment)

func _on_defense_registered(word, defense_text):
	# Find the defense in the word_comment_system
	if word_comment_system and word_comment_system.defense_statements.has(word):
		var defenses_list = word_comment_system.defense_statements[word]
		if defenses_list.size() > 0:
			var last_defense = defenses_list.back().duplicate()
			last_defense["word"] = word
			save_defense_record(word + "_" + str(last_defense.timestamp), last_defense)

func _on_dimension_changed(new_dimension, old_dimension):
	# Save dimension record for the dimension we're leaving
	if old_dimension > 0:
		var dimension_data = {
			"dimension": old_dimension,
			"exited_at_turn": turn_system.current_turn if turn_system else 0,
			"timestamp": OS.get_unix_time()
		}
		
		save_dimension_record(old_dimension, dimension_data)
	
	# Special handling for significant dimensions
	match new_dimension:
		7:  # Dream dimension
			# Archive dreams when entering dream dimension
			archive_dreams()
		9:  # Judgment dimension
			# Archive defenses when entering judgment dimension
			archive_accepted_defenses()
		12: # Divine dimension
			# Archive important comments when entering divine dimension
			archive_important_comments()

func _on_turn_completed(turn_number):
	# Every 12 turns (one full cycle), save all data
	if turn_number % 12 == 0:
		save_all_data()
		
		# Also do a backup every 12 turns
		backup_memories()

func _on_auto_save_timeout():
	# Auto-save basic metadata only
	update_memory_size_stats()
	
	# Every 10 minutes (600 seconds), do a full save
	if OS.get_unix_time() % 600 < auto_save_interval:
		save_all_data()