extends Node

class_name MemorySystem

# ----- SIGNALS -----
signal memory_created(memory_data)
signal memory_promoted(memory_id, old_tier, new_tier)
signal memory_archived(memory_id)
signal sewer_cleaned(files_moved, bytes_freed)
signal tier_overflowed(tier)

# ----- CONSTANTS -----
const TIER1_CAPACITY = 100  # RAM - Fast access, limited capacity
const TIER2_CAPACITY = 50   # C: Drive - Medium access, medium capacity
const TIER3_CAPACITY = -1   # D: Drive - Slow access, unlimited capacity (-1 = unlimited)

const SEWER_CLEANUP_THRESHOLD_MB = 100  # Cleanup when sewers exceed this size
const SEWER_AUTO_COMPRESS_DAYS = 7      # Auto-compress files older than 7 days
const SEWER_AUTO_ARCHIVE_DAYS = 30      # Auto-archive files older than 30 days

# ----- MEMORY STRUCTURE -----
var memories = {
	1: [],  # Tier 1: RAM - temporary/recent memories (98% retention)
	2: [],  # Tier 2: C: Drive - important memories (85% retention)
	3: []   # Tier 3: D: Drive - eternal/archived memories (100% retention)
}

# ----- SEWER SYSTEM -----
# Data sewers store overflow from memory tiers
var data_sewers = {
	"PHYSICAL": [],
	"DIGITAL": [],
	"ASTRAL": [],
	"QUANTUM": [],
	"MEMORY": [],
	"DREAM": []
}

# Compressed archives
var archives = []

# ----- STATE VARIABLES -----
var total_memories_created: int = 0
var auto_cleanup_enabled: bool = true
var current_reality: String = "DIGITAL"
var total_bytes_stored: int = 0
var total_bytes_archived: int = 0

# ----- INITIALIZATION -----
func _ready():
	print("Memory System initializing...")
	
	# Create necessary directories
	_ensure_directories_exist()
	
	# Load saved state if available
	_load_state()
	
	print("Memory System initialized with %d memories across 3 tiers" % get_total_memory_count())

# ----- PROCESS -----
func _process(delta):
	# Check for automated cleanup if enabled
	if auto_cleanup_enabled:
		# Run sewer cleanup infrequently
		if randf() < 0.001:  # ~0.1% chance per frame, averages once every few minutes
			check_and_clean_sewers()

# ----- MEMORY FUNCTIONS -----
func create_memory(text: String, tier: int = 1, power: float = 1.0, 
				   tags: Array = [], reality_type: String = "") -> Dictionary:
	# Validate tier
	tier = clamp(tier, 1, 3)
	
	# Use current reality if none specified
	if reality_type.is_empty():
		reality_type = current_reality
	
	# Create memory data
	var memory_id = "memory_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 100000)
	var memory = {
		"id": memory_id,
		"text": text,
		"tier": tier,
		"power": power,
		"tags": tags,
		"reality": reality_type,
		"creation_time": Time.get_unix_time_from_system(),
		"last_accessed": Time.get_unix_time_from_system(),
		"access_count": 0,
		"size_bytes": text.length() * 2  # Approximate size estimation
	}
	
	# Add to appropriate tier
	memories[tier].append(memory)
	total_memories_created += 1
	total_bytes_stored += memory.size_bytes
	
	# Check for tier overflow
	_check_tier_capacity(tier)
	
	# Auto-promote very powerful memories
	if power > 75 and tier < 3:
		promote_memory(memory_id, 3)
	
	# Signal memory created
	emit_signal("memory_created", memory)
	
	print("Memory created in Tier %d: '%s'" % [tier, text.substr(0, min(30, text.length())) + (text.length() > 30 ? "..." : "")])
	return memory

func get_memory(memory_id: String) -> Dictionary:
	# Search in all tiers
	for tier in memories:
		for memory in memories[tier]:
			if memory.id == memory_id:
				# Update access statistics
				memory.last_accessed = Time.get_unix_time_from_system()
				memory.access_count += 1
				return memory
	
	# Check sewers if not found in active memories
	for reality in data_sewers:
		for memory in data_sewers[reality]:
			if memory.id == memory_id:
				# Return from sewer
				return memory
	
	# Not found
	print("Memory not found: %s" % memory_id)
	return {}

func promote_memory(memory_id: String, target_tier: int) -> bool:
	# Validate tier
	if target_tier < 1 or target_tier > 3:
		push_error("Invalid target tier: %d" % target_tier)
		return false
	
	# Find memory
	for tier in memories:
		for i in range(memories[tier].size()):
			if memories[tier][i].id == memory_id:
				# Skip if already in target tier
				if tier == target_tier:
					return true
				
				# Can't demote to lower tier
				if tier > target_tier:
					push_error("Cannot demote memory from tier %d to %d" % [tier, target_tier])
					return false
				
				# Get memory
				var memory = memories[tier][i]
				var old_tier = memory.tier
				
				# Remove from current tier
				memories[tier].remove_at(i)
				
				# Update tier
				memory.tier = target_tier
				memory.promotion_time = Time.get_unix_time_from_system()
				
				# Add to new tier
				memories[target_tier].append(memory)
				
				# Signal promotion
				emit_signal("memory_promoted", memory_id, old_tier, target_tier)
				
				print("Memory promoted from Tier %d to Tier %d: '%s'" % [
					old_tier, 
					target_tier, 
					memory.text.substr(0, min(30, memory.text.length())) + (memory.text.length() > 30 ? "..." : "")
				])
				
				return true
	
	# Not found
	push_error("Memory not found for promotion: %s" % memory_id)
	return false

func archive_memory(memory_id: String) -> bool:
	# Find memory in any tier
	for tier in memories:
		for i in range(memories[tier].size()):
			if memories[tier][i].id == memory_id:
				var memory = memories[tier][i]
				
				# Add to archives
				memory.archive_time = Time.get_unix_time_from_system()
				archives.append(memory)
				
				# Move bytes from stored to archived
				total_bytes_stored -= memory.size_bytes
				total_bytes_archived += memory.size_bytes
				
				# Remove from tier
				memories[tier].remove_at(i)
				
				# Signal archive
				emit_signal("memory_archived", memory_id)
				
				print("Memory archived: '%s'" % memory.text.substr(0, min(30, memory.text.length())) + (memory.text.length() > 30 ? "..." : ""))
				
				return true
	
	# Not found
	push_error("Memory not found for archiving: %s" % memory_id)
	return false

func get_memories_by_tier(tier: int) -> Array:
	if tier >= 1 and tier <= 3:
		return memories[tier].duplicate()
	return []

func get_memories_by_reality(reality: String) -> Array:
	var result = []
	
	# Search all tiers
	for tier in memories:
		for memory in memories[tier]:
			if memory.reality == reality:
				result.append(memory)
	
	return result

func get_memories_by_tag(tag: String) -> Array:
	var result = []
	
	# Search all tiers
	for tier in memories:
		for memory in memories[tier]:
			if tag in memory.tags:
				result.append(memory)
	
	return result

func search_memories(search_term: String) -> Array:
	var results = []
	
	# Search all tiers
	for tier in memories:
		for memory in memories[tier]:
			if search_term.to_lower() in memory.text.to_lower():
				results.append(memory)
	
	return results

# ----- SEWER SYSTEM -----
func move_to_sewer(memory_id: String, reality_type: String = "") -> bool:
	# Use current reality if none specified
	if reality_type.is_empty():
		reality_type = current_reality
	
	# Ensure reality type is valid
	if not data_sewers.has(reality_type):
		push_error("Invalid reality type for sewer: %s" % reality_type)
		return false
	
	# Find memory in any tier
	for tier in memories:
		for i in range(memories[tier].size()):
			if memories[tier][i].id == memory_id:
				var memory = memories[tier][i]
				
				# Add to sewer
				memory.moved_to_sewer_time = Time.get_unix_time_from_system()
				data_sewers[reality_type].append(memory)
				
				# Remove from tier
				memories[tier].remove_at(i)
				
				print("Memory moved to %s sewer: '%s'" % [
					reality_type, 
					memory.text.substr(0, min(30, memory.text.length())) + (memory.text.length() > 30 ? "..." : "")
				])
				
				return true
	
	# Not found
	push_error("Memory not found for sewer: %s" % memory_id)
	return false

func check_and_clean_sewers() -> Dictionary:
	var cleanup_stats = {
		"files_moved": 0,
		"bytes_freed": 0,
		"compressed": 0,
		"archived": 0
	}
	
	# Check each reality sewer
	for reality in data_sewers:
		var sewer_size = 0
		
		# Calculate sewer size
		for memory in data_sewers[reality]:
			sewer_size += memory.size_bytes
		
		# Convert to MB
		var sewer_size_mb = sewer_size / (1024 * 1024)
		
		# Clean if above threshold
		if sewer_size_mb >= SEWER_CLEANUP_THRESHOLD_MB:
			print("Cleaning %s sewer (%.2f MB)" % [reality, sewer_size_mb])
			
			# Sort by age (oldest first)
			data_sewers[reality].sort_custom(func(a, b): return a.creation_time < b.creation_time)
			
			# Process memories, starting with oldest
			var current_time = Time.get_unix_time_from_system()
			
			# Remove or compress old memories
			for i in range(data_sewers[reality].size() - 1, -1, -1):
				var memory = data_sewers[reality][i]
				var age_days = (current_time - memory.creation_time) / (60 * 60 * 24)
				
				# Archive very old memories
				if age_days > SEWER_AUTO_ARCHIVE_DAYS:
					# Add to archives
					memory.archive_time = current_time
					archives.append(memory)
					
					# Move bytes from stored to archived
					total_bytes_stored -= memory.size_bytes
					total_bytes_archived += memory.size_bytes
					
					# Remove from sewer
					data_sewers[reality].remove_at(i)
					
					cleanup_stats.files_moved += 1
					cleanup_stats.bytes_freed += memory.size_bytes
					cleanup_stats.archived += 1
				
				# Compress moderately old memories
				elif age_days > SEWER_AUTO_COMPRESS_DAYS:
					# Simulate compression by reducing size
					var old_size = memory.size_bytes
					memory.size_bytes = int(memory.size_bytes * 0.6)  # 40% compression
					memory.compressed = true
					memory.compression_time = current_time
					
					cleanup_stats.bytes_freed += (old_size - memory.size_bytes)
					cleanup_stats.compressed += 1
					
					# Stop cleaning if we've freed enough space
					if cleanup_stats.bytes_freed > SEWER_CLEANUP_THRESHOLD_MB * 1024 * 1024 * 0.6:
						break
			}
			
			print("Sewer cleanup complete: %d files moved, %.2f MB freed" % [
				cleanup_stats.files_moved,
				cleanup_stats.bytes_freed / (1024 * 1024)
			])
			
			# Signal cleanup
			emit_signal("sewer_cleaned", cleanup_stats.files_moved, cleanup_stats.bytes_freed)
		}
	
	return cleanup_stats

# ----- HELPER FUNCTIONS -----
func _check_tier_capacity(tier: int):
	var capacity = -1
	
	match tier:
		1: capacity = TIER1_CAPACITY
		2: capacity = TIER2_CAPACITY
		3: capacity = TIER3_CAPACITY
	
	# Skip unlimited tier
	if capacity == -1:
		return
	
	# Check for overflow
	if memories[tier].size() > capacity:
		emit_signal("tier_overflowed", tier)
		
		# Sort by least recently accessed
		memories[tier].sort_custom(func(a, b): return a.last_accessed < b.last_accessed)
		
		# Move older memories to sewer
		while memories[tier].size() > capacity:
			var oldest = memories[tier][0]
			move_to_sewer(oldest.id)
			
			# Safety check - break if nothing was moved
			if memories[tier].size() > 0 and memories[tier][0].id == oldest.id:
				memories[tier].remove_at(0)
		
		print("Tier %d overflow managed - reduced to %d memories" % [tier, memories[tier].size()])
	}

func _ensure_directories_exist():
	var dir = DirAccess.open("user://")
	if not dir:
		push_error("Failed to access user directory")
		return
	
	# Create memory directories
	if not dir.dir_exists("memories"):
		dir.make_dir("memories")
	
	# Create tier directories
	for tier in range(1, 4):
		if not dir.dir_exists("memories/tier_" + str(tier)):
			dir.make_dir("memories/tier_" + str(tier))
	
	# Create sewers directory
	if not dir.dir_exists("sewers"):
		dir.make_dir("sewers")
	
	# Create archives directory
	if not dir.dir_exists("archives"):
		dir.make_dir("archives")

# ----- STATE MANAGEMENT -----
func _save_state():
	var save_data = {
		"memories": memories,
		"data_sewers": data_sewers,
		"archives": archives,
		"total_memories_created": total_memories_created,
		"total_bytes_stored": total_bytes_stored,
		"total_bytes_archived": total_bytes_archived,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var dir = DirAccess.open("user://")
	if not dir:
		push_error("Failed to access user directory")
		return
	
	if not dir.dir_exists("memory_data"):
		dir.make_dir("memory_data")
	
	var file = FileAccess.open("user://memory_data/memory_system_state.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		print("Memory system state saved")
	else:
		push_error("Failed to save memory system state")

func _load_state():
	if not FileAccess.file_exists("user://memory_data/memory_system_state.json"):
		return
	
	var file = FileAccess.open("user://memory_data/memory_system_state.json", FileAccess.READ)
	if not file:
		push_error("Failed to load memory system state")
		return
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	
	if error == OK:
		var data = json.get_data()
		memories = data.get("memories", memories)
		data_sewers = data.get("data_sewers", data_sewers)
		archives = data.get("archives", [])
		total_memories_created = data.get("total_memories_created", 0)
		total_bytes_stored = data.get("total_bytes_stored", 0)
		total_bytes_archived = data.get("total_bytes_archived", 0)
		print("Memory system state loaded")
	else:
		push_error("JSON Parse Error: " + json.get_error_message())

# ----- PUBLIC API -----
func get_total_memory_count() -> int:
	var count = 0
	for tier in memories:
		count += memories[tier].size()
	return count

func get_memory_stats() -> Dictionary:
	return {
		"tier1_count": memories[1].size(),
		"tier2_count": memories[2].size(),
		"tier3_count": memories[3].size(),
		"total_active": get_total_memory_count(),
		"total_created": total_memories_created,
		"sewer_size": get_sewer_size(),
		"archive_size": archives.size(),
		"bytes_stored": total_bytes_stored,
		"bytes_archived": total_bytes_archived
	}

func get_sewer_size() -> int:
	var total = 0
	for reality in data_sewers:
		total += data_sewers[reality].size()
	return total

func set_reality_context(reality: String):
	current_reality = reality

func toggle_auto_cleanup(enabled: bool) -> bool:
	auto_cleanup_enabled = enabled
	return auto_cleanup_enabled

func save_game() -> void:
	_save_state()