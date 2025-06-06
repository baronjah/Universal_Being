# ==================================================
# SCRIPT NAME: akashic_living_database.gd
# DESCRIPTION: Living Database features to add to AkashicRecordsSystemSystem
# PURPOSE: Implement key features from Gemini research
# CREATED: 2025-12-01
# ==================================================

# Add these to your existing AkashicRecordsSystemSystem.gd

# ===== INTERACTION LOGGING =====

var interaction_logs: Array[Dictionary] = []
var being_memories: Dictionary = {}  # uuid -> memories array

func log_interaction(data: Dictionary) -> void:
	"""Log detailed interaction with emotional context"""
	var entry = {
		"id": "evt_%d_%d" % [Time.get_ticks_msec(), randi()],
		"timestamp": Time.get_ticks_msec(),
		"type": data.get("type", "unknown"),
		"participants": data.get("participants", []),
		"location": data.get("location", Vector3.ZERO),
		"outcome": data.get("outcome", {}),
		"emotion": infer_emotion(data)
	}
	
	interaction_logs.append(entry)
	
	# Update being memories
	for participant in entry.participants:
		add_being_memory(participant, entry)
	
	# Save to file periodically
	if interaction_logs.size() % 10 == 0:
		save_interaction_logs()

func infer_emotion(data: Dictionary) -> String:
	"""Simple emotion inference"""
	var type_emotions = {
		"attack": "hostile",
		"help": "friendly", 
		"trade": "neutral",
		"gift": "generous"
	}
	
	var interaction_type = data.get("type", "")
	for key in type_emotions:
		if interaction_type.contains(key):
			return type_emotions[key]
	return "neutral"

func add_being_memory(being_uuid: String, event: Dictionary) -> void:
	"""Add memory to specific being"""
	if not being_memories.has(being_uuid):
		being_memories[being_uuid] = []
	
	var memory = {
		"event_id": event.id,
		"summary": summarize_for_being(being_uuid, event),
		"emotion": event.emotion,
		"importance": randf_range(0.3, 1.0)
	}
	
	being_memories[being_uuid].append(memory)
	
	# Keep only 50 most important memories
	if being_memories[being_uuid].size() > 50:
		being_memories[being_uuid].sort_custom(
			func(a, b): return a.importance > b.importance
		)
		being_memories[being_uuid] = being_memories[being_uuid].slice(0, 50)

func summarize_for_being(being_uuid: String, event: Dictionary) -> String:
	"""Create memory summary from being's perspective"""
	if being_uuid in event.participants:
		return "Participated in %s" % event.type
	return "Witnessed %s" % event.type

# ===== QUERY SYSTEM =====

func query_interactions(filters: Dictionary) -> Array:
	"""Query interaction history"""
	var results = []
	
	for log in interaction_logs:
		var matches = true
		
		# Check type filter
		if filters.has("type") and log.type != filters.type:
			matches = false
		
		# Check participant filter
		if filters.has("participant"):
			if not filters.participant in log.participants:
				matches = false
		
		# Check time range
		if filters.has("since"):
			if log.timestamp < filters.since:
				matches = false
		
		if matches:
			results.append(log)
	
	return results

func get_being_memories(being_uuid: String) -> Array:
	"""Get all memories for a being"""
	return being_memories.get(being_uuid, [])

# ===== CAUSAL EVENTS =====

var causal_patterns: Dictionary = {
	"revenge": {
		"trigger": {"type": "attack", "emotion": "hostile"},
		"consequence": "create_rivalry"
	},
	"friendship": {
		"trigger": {"type": "help", "count": 3},
		"consequence": "create_alliance"
	}
}

func check_causal_triggers(being_uuid: String) -> void:
	"""Check if being's history triggers any events"""
	var memories = get_being_memories(being_uuid)
	
	# Count interaction types
	var interaction_counts = {}
	for memory in memories:
		var type = memory.get("type", "unknown")
		interaction_counts[type] = interaction_counts.get(type, 0) + 1
	
	# Check patterns
	for pattern_name in causal_patterns:
		var pattern = causal_patterns[pattern_name]
		if should_trigger_pattern(interaction_counts, pattern):
			emit_signal("causal_event_triggered", pattern.consequence, being_uuid)

func should_trigger_pattern(counts: Dictionary, pattern: Dictionary) -> bool:
	"""Check if pattern conditions are met"""
	var trigger = pattern.trigger
	
	if trigger.has("type") and trigger.has("count"):
		var type_count = counts.get(trigger.type, 0)
		return type_count >= trigger.count
	
	return false

# ===== PERSISTENCE =====

func save_interaction_logs() -> void:
	"""Save logs to JSON file"""
	var file = FileAccess.open("user://interaction_logs.json", FileAccess.WRITE)
	if file:
		var data = {
			"logs": interaction_logs,
			"timestamp": Time.get_datetime_string_from_system()
		}
		file.store_string(JSON.stringify(data))
		file.close()

func load_interaction_logs() -> void:
	"""Load logs from file"""
	if FileAccess.file_exists("user://interaction_logs.json"):
		var file = FileAccess.open("user://interaction_logs.json", FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var data = json.data
				interaction_logs = data.get("logs", [])

# ===== INTEGRATION HELPERS =====

func get_status() -> Dictionary:
	"""Get Akashic Records status"""
	return {
		"being_count": being_memories.size(),
		"event_count": interaction_logs.size(),
		"loaded": true
	}

func log_creation(data: Dictionary) -> void:
	"""Log being creation event"""
	log_interaction({
		"type": "creation",
		"participants": [data.get("being", {}).get("uuid", "unknown")],
		"outcome": {"being_type": data.get("type", "unknown")}
	})

func log_event(data: Dictionary) -> void:
	"""Generic event logging"""
	log_interaction(data)

# Signals
signal causal_event_triggered(event_type: String, being_uuid: String)
