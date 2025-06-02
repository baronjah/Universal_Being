# ==================================================
# SCRIPT NAME: AkashicRecordsEnhanced.gd
# DESCRIPTION: Enhanced Akashic Records with Living Database features
# PURPOSE: Implement Gemini's research for deeper narratives and AI integration
# CREATED: 2025-12-01
# AUTHOR: JSH + Claude (Opus) - Based on Gemini Research
# ==================================================

extends Node

# This file contains enhancements to add to AkashicRecords.gd

# ===== ENHANCED EVENT LOGGING =====

## Detailed Interaction Logging
var interaction_logs: Array[Dictionary] = []
var being_database: Dictionary = {}  # uuid -> being_state
var evolution_history: Array[Dictionary] = []
var causal_triggers: Dictionary = {}  # pattern -> consequence

## Memory Limits
const MAX_GLOBAL_LOGS: int = 10000
const MAX_BEING_MEMORIES: int = 100
const MEMORY_IMPORTANCE_THRESHOLD: float = 0.3

# ===== GRANULAR EVENT LOGGING =====

func log_interaction(data: Dictionary) -> void:
	"""Log interaction with maximum granularity as per Gemini's recommendation"""
	var entry = {
		"id": generate_event_id(),
		"timestamp": Time.get_ticks_msec(),
		"type": data.get("type", "unknown"),  # combat, dialogue, trade, etc.
		"participants": data.get("participants", []),
		"initiator": data.get("initiator", null),
		"target": data.get("target", null),
		"location": data.get("location", Vector3.ZERO),
		"outcome": data.get("outcome", {}),
		"emotional_context": infer_emotional_context(data),
		"intensity": calculate_interaction_intensity(data),
		"consequences": [],
		"tags": data.get("tags", [])
	}
	
	# Add to global logs
	interaction_logs.append(entry)
	
	# Update individual being memories
	for participant in entry.participants:
		update_being_memory(participant, entry)
	
	# Check for causal triggers
	check_causal_patterns(entry)
	
	# Emit signal for AI or other systems
	emit_signal("interaction_logged", entry)
	
	# Maintain log size
	if interaction_logs.size() > MAX_GLOBAL_LOGS:
		archive_old_logs()

func infer_emotional_context(data: Dictionary) -> String:
	"""Infer emotional context from interaction data"""
	var emotion_keywords = {
		"attack": "hostile",
		"help": "friendly",
		"trade": "neutral",
		"flee": "fearful",
		"gift": "generous",
		"steal": "greedy",
		"protect": "protective",
		"betray": "treacherous"
	}
	
	var interaction_type = data.get("type", "").to_lower()
	for keyword in emotion_keywords:
		if interaction_type.contains(keyword):
			return emotion_keywords[keyword]
	
	# Check outcome for emotional cues
	var outcome = data.get("outcome", {})
	if outcome.has("damage_dealt") and outcome.damage_dealt > 0:
		return "aggressive"
	elif outcome.has("health_restored") and outcome.health_restored > 0:
		return "caring"
	
	return "neutral"

func calculate_interaction_intensity(data: Dictionary) -> float:
	"""Calculate importance/intensity of interaction (0.0 - 1.0)"""
	var intensity = 0.5  # Base intensity
	
	# Increase for certain types
	match data.get("type", ""):
		"death": intensity = 1.0
		"birth": intensity = 0.9
		"evolution": intensity = 0.8
		"combat": intensity = 0.7
		"trade": intensity = 0.4
		"dialogue": intensity = 0.3
	
	# Modify based on participants
	var participant_count = data.get("participants", []).size()
	if participant_count > 2:
		intensity += 0.1 * min(participant_count - 2, 3)
	
	return clamp(intensity, 0.0, 1.0)

# ===== BEING MEMORY MANAGEMENT =====

func update_being_memory(being_uuid: String, event: Dictionary) -> void:
	"""Update individual being's memory with significance filtering"""
	if not being_database.has(being_uuid):
		being_database[being_uuid] = create_being_record(being_uuid)
	
	var being_record = being_database[being_uuid]
	var memories = being_record.get("memories", [])
	
	# Calculate memory importance from being's perspective
	var importance = calculate_memory_importance(being_uuid, event)
	
	if importance >= MEMORY_IMPORTANCE_THRESHOLD:
		var memory = {
			"event_id": event.id,
			"timestamp": event.timestamp,
			"summary": summarize_event_for_being(being_uuid, event),
			"importance": importance,
			"emotional_impact": determine_emotional_impact(being_uuid, event),
			"participants": event.participants,
			"tags": event.tags
		}
		
		memories.append(memory)
		
		# Keep only most important memories if over limit
		if memories.size() > MAX_BEING_MEMORIES:
			memories.sort_custom(func(a, b): return a.importance > b.importance)
			memories = memories.slice(0, MAX_BEING_MEMORIES)
		
		being_record.memories = memories
		being_database[being_uuid] = being_record
		
		# Save to being's ZIP file if needed
		save_being_memories(being_uuid, memories)

func calculate_memory_importance(being_uuid: String, event: Dictionary) -> float:
	"""Calculate how important an event is to a specific being"""
	var importance = event.get("intensity", 0.5)
	
	# Higher importance if being was initiator or target
	if event.get("initiator") == being_uuid:
		importance += 0.2
	if event.get("target") == being_uuid:
		importance += 0.3
	
	# Check emotional relevance
	var being_record = being_database.get(being_uuid, {})
	var being_traits = being_record.get("traits", [])
	
	# Trait-based importance modifiers
	if "curious" in being_traits and event.type == "discovery":
		importance += 0.2
	if "vengeful" in being_traits and event.emotional_context == "hostile":
		importance += 0.3
	
	return clamp(importance, 0.0, 1.0)

# ===== CAUSAL EVENT CHAINS =====

func check_causal_patterns(event: Dictionary) -> void:
	"""Check if this event triggers any causal chains"""
	for pattern_key in causal_triggers:
		var pattern = causal_triggers[pattern_key]
		if matches_pattern(event, pattern.trigger_conditions):
			var triggered = trigger_causal_event(pattern.consequence, event)
			if triggered:
				event.consequences.append(pattern.consequence.id)

func matches_pattern(event: Dictionary, conditions: Dictionary) -> bool:
	"""Check if event matches trigger conditions"""
	for key in conditions:
		if not event.has(key):
			return false
		
		var event_value = event[key]
		var condition_value = conditions[key]
		
		# Support different condition types
		if condition_value is Dictionary:
			if condition_value.has("min") and event_value < condition_value.min:
				return false
			if condition_value.has("max") and event_value > condition_value.max:
				return false
			if condition_value.has("equals") and event_value != condition_value.equals:
				return false
			if condition_value.has("contains") and not str(event_value).contains(condition_value.contains):
				return false
		else:
			if event_value != condition_value:
				return false
	
	return true

func trigger_causal_event(consequence: Dictionary, triggering_event: Dictionary) -> bool:
	"""Trigger a consequence event based on causal chain"""
	print("🔮 Akashic: Causal chain triggered by event %s" % triggering_event.id)
	
	# Create the consequence event
	var new_event = {
		"type": consequence.get("type", "consequence"),
		"caused_by": triggering_event.id,
		"participants": consequence.get("participants", triggering_event.participants),
		"description": consequence.get("description", ""),
		"delay": consequence.get("delay", 0.0)
	}
	
	if new_event.delay > 0:
		# Schedule for later
		schedule_future_event(new_event)
	else:
		# Trigger immediately
		emit_signal("causal_event_triggered", new_event)
	
	return true

# ===== QUERYING SYSTEM =====

func query_history(filters: Dictionary) -> Array:
	"""Advanced querying system for historical data"""
	var results = []
	
	for log in interaction_logs:
		if matches_filters(log, filters):
			results.append(log)
	
	# Sort by relevance if requested
	if filters.has("sort_by"):
		match filters.sort_by:
			"timestamp":
				results.sort_custom(func(a, b): return a.timestamp > b.timestamp)
			"importance":
				results.sort_custom(func(a, b): return a.intensity > b.intensity)
			"relevance":
				# Sort by relevance to query
				var query_terms = filters.get("keywords", [])
				results.sort_custom(func(a, b): 
					return calculate_relevance(a, query_terms) > calculate_relevance(b, query_terms)
				)
	
	# Limit results if requested
	if filters.has("limit"):
		results = results.slice(0, filters.limit)
	
	return results

func query_being_memories(being_uuid: String, filters: Dictionary = {}) -> Array:
	"""Query specific being's memories"""
	if not being_database.has(being_uuid):
		return []
	
	var being_record = being_database[being_uuid]
	var memories = being_record.get("memories", [])
	
	if filters.is_empty():
		return memories
	
	# Filter memories
	var filtered = []
	for memory in memories:
		if matches_filters(memory, filters):
			filtered.append(memory)
	
	return filtered

# ===== DREAM ACCESS SYSTEM =====

func get_dream_accessible_memories(being_uuid: String, dream_depth: int = 1) -> Dictionary:
	"""Get memories accessible in dream state"""
	var accessible = {
		"personal_memories": [],
		"witnessed_events": [],
		"collective_memories": [],
		"possible_futures": []
	}
	
	# Personal memories (always accessible)
	accessible.personal_memories = query_being_memories(being_uuid, {
		"importance": {"min": 0.5}  # Only important memories in dreams
	})
	
	# Witnessed events (based on dream depth)
	if dream_depth >= 2:
		accessible.witnessed_events = query_history({
			"participants": {"contains": being_uuid},
			"limit": 10
		})
	
	# Collective memories (deep dreams)
	if dream_depth >= 3:
		accessible.collective_memories = query_history({
			"importance": {"min": 0.8},
			"limit": 5
		})
	
	# Possible futures (prophetic dreams)
	if dream_depth >= 4:
		accessible.possible_futures = generate_possible_futures(being_uuid)
	
	return accessible

func generate_possible_futures(being_uuid: String) -> Array:
	"""Generate possible future events based on patterns"""
	var futures = []
	
	# Analyze being's history for patterns
	var being_patterns = analyze_being_patterns(being_uuid)
	
	for pattern in being_patterns:
		if pattern.confidence > 0.7:
			futures.append({
				"type": "prophecy",
				"description": pattern.predicted_outcome,
				"probability": pattern.confidence,
				"conditions": pattern.required_conditions
			})
	
	return futures

# ===== HELPER FUNCTIONS =====

func generate_event_id() -> String:
	"""Generate unique event ID"""
	return "evt_%d_%d" % [Time.get_ticks_msec(), randi() % 1000]

func create_being_record(being_uuid: String) -> Dictionary:
	"""Create a new being record"""
	return {
		"uuid": being_uuid,
		"memories": [],
		"traits": [],
		"relationships": {},
		"stats": {
			"interactions": 0,
			"evolutions": 0,
			"significance": 0.0
		}
	}

func save_being_memories(being_uuid: String, memories: Array) -> void:
	"""Save being memories to their ZIP file"""
	# This would integrate with existing ZIP save system
	pass

func summarize_event_for_being(being_uuid: String, event: Dictionary) -> String:
	"""Create a summary of event from being's perspective"""
	var summary = ""
	
	if event.initiator == being_uuid:
		summary = "I initiated %s with " % event.type
	elif event.target == being_uuid:
		summary = "I was target of %s by " % event.type
	else:
		summary = "I witnessed %s between " % event.type
	
	# Add participant info
	var others = []
	for p in event.participants:
		if p != being_uuid:
			others.append(p)
	
	summary += str(others)
	
	return summary

func determine_emotional_impact(being_uuid: String, event: Dictionary) -> String:
	"""Determine emotional impact of event on being"""
	# Would be enhanced with being personality traits
	return event.get("emotional_context", "neutral")

func archive_old_logs() -> void:
	"""Archive old logs to file"""
	# Save oldest 1000 logs to file and remove from memory
	var to_archive = interaction_logs.slice(0, 1000)
	interaction_logs = interaction_logs.slice(1000)
	
	# Save to file
	var file_path = "user://akashic_archive_%d.json" % Time.get_ticks_msec()
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(to_archive))
		file.close()

func schedule_future_event(event: Dictionary) -> void:
	"""Schedule an event to occur in the future"""
	# Would integrate with game's event system
	pass

func matches_filters(data: Dictionary, filters: Dictionary) -> bool:
	"""Check if data matches all filters"""
	for key in filters:
		if not data.has(key):
			return false
		
		var filter_value = filters[key]
		var data_value = data[key]
		
		if filter_value is Dictionary:
			# Complex filter
			if not matches_pattern(data, {key: filter_value}):
				return false
		elif filter_value is Array:
			# Must contain one of the values
			if not data_value in filter_value:
				return false
		else:
			# Simple equality
			if data_value != filter_value:
				return false
	
	return true

func calculate_relevance(event: Dictionary, keywords: Array) -> float:
	"""Calculate relevance score for event based on keywords"""
	var relevance = 0.0
	var event_text = JSON.stringify(event).to_lower()
	
	for keyword in keywords:
		if event_text.contains(keyword.to_lower()):
			relevance += 1.0
	
	return relevance

func analyze_being_patterns(being_uuid: String) -> Array:
	"""Analyze patterns in being's history"""
	# Placeholder for pattern analysis
	return []

# ===== SIGNALS =====
signal interaction_logged(event: Dictionary)
signal causal_event_triggered(event: Dictionary)
signal memory_archived(being_uuid: String, memory_count: int)
