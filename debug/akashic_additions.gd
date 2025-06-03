# Add these methods to your AkashicRecords.gd file

# ===== LIVING DATABASE FEATURES =====

# 1. Enhanced Event Logging
func log_interaction(data: Dictionary) -> void:
	"""Log interaction with emotional context - Gemini research"""
	var entry = {
		"timestamp": Time.get_ticks_msec(),
		"type": data.get("type", "unknown"),
		"participants": data.get("participants", []),
		"emotion": infer_emotion(data),
		"location": data.get("location", Vector3.ZERO)
	}
	session_interactions.append(entry)
	emit_signal("akashic_memory_updated", "interaction", entry)

func infer_emotion(data: Dictionary) -> String:
	var emotions = {
		"attack": "hostile", "help": "friendly",
		"trade": "neutral", "gift": "generous"
	}
	for key in emotions:
		if data.get("type", "").contains(key):
			return emotions[key]
	return "neutral"

# 2. Query System
func query_interactions(filters: Dictionary) -> Array:
	"""Query historical interactions"""
	var results = []
	for log in session_interactions:
		var matches_filter = true
		if filters.has("type") and log.type != filters.type:
			matches_filter = false
		if filters.has("participant") and not filters.participant in log.participants:
			matches_filter = false
		if matches_filter:
			results.append(log)
	return results

# 3. Status for Console
func get_status() -> Dictionary:
	return {
		"being_count": session_beings.size(),
		"event_count": session_interactions.size(),
		"loaded": true
	}

# 4. Event helpers
func log_creation(data: Dictionary) -> void:
	log_interaction({
		"type": "creation",
		"participants": [data.get("being", {}).get("uuid", "unknown")]
	})

func log_event(data: Dictionary) -> void:
	log_interaction(data)
