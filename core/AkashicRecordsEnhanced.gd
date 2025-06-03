# ==================================================
# SCRIPT NAME: AkashicRecordsEnhanced.gd
# DESCRIPTION: Enhanced Akashic Records with 4D Timeline Management
# PURPOSE: 4D Timeline continuity, scenario branching, save/load, and data compacting
# CREATED: 2025-06-03 - Enhanced by Claude Code
# AUTHOR: JSH + Claude Code + Previous Enhancements
# ==================================================

extends Node
class_name AkashicRecordsEnhanced

# ===== 4D TIMELINE CORE PROPERTIES =====

var timeline_id: String = ""
var current_timeline_index: int = 0
var timeline_branches: Dictionary = {}  # branch_id -> TimelineBranch
var active_scenarios: Dictionary = {}   # scenario_id -> Scenario
var checkpoint_system: CheckpointManager
var data_compactor: DataCompactor

# Timeline continuity
var timeline_depth_limit: int = 1000
var max_timeline_branches: int = 50
var auto_save_interval: float = 30.0
var last_auto_save: float = 0.0

# State management
var universe_states: Dictionary = {}    # timeline_point -> UniverseState
var being_evolution_chains: Dictionary = {}  # being_uuid -> EvolutionChain
var consciousness_flow_map: Dictionary = {}  # Maps consciousness interactions

# Data compacting
var compression_threshold: int = 10000  # Compact when exceeding this many entries
var archive_old_data: bool = true
var keep_critical_checkpoints: bool = true

# ===== 4D TIMELINE NESTED CLASSES =====

class TimelineBranch:
	var branch_id: String
	var parent_timeline: String
	var branch_point: float
	var branch_reason: String
	var universe_states: Array[Dictionary] = []
	var beings_at_branch: Array[Dictionary] = []
	var decision_data: Dictionary = {}
	
	func _init(id: String, parent: String, point: float, reason: String):
		branch_id = id
		parent_timeline = parent
		branch_point = point
		branch_reason = reason

class Scenario:
	var scenario_id: String
	var scenario_type: String  # "evolution", "creation", "collaboration", "experiment"
	var start_time: float
	var end_time: float
	var participants: Array[String] = []  # UUIDs of involved beings
	var key_events: Array[Dictionary] = []
	var outcome_data: Dictionary = {}
	
	func _init(id: String, type: String):
		scenario_id = id
		scenario_type = type
		start_time = Time.get_ticks_msec() / 1000.0

class CheckpointManager:
	var checkpoints: Dictionary = {}  # timestamp -> CheckpointData
	var auto_checkpoint_interval: float = 60.0
	var last_checkpoint: float = 0.0
	var max_checkpoints: int = 100
	
	func create_checkpoint(name: String, data: Dictionary) -> String:
		var timestamp = Time.get_ticks_msec() / 1000.0
		var checkpoint_id = "%s_%f" % [name, timestamp]
		
		checkpoints[checkpoint_id] = {
			"name": name,
			"timestamp": timestamp,
			"data": data,
			"size": JSON.stringify(data).length()
		}
		
		# Maintain checkpoint limit
		if checkpoints.size() > max_checkpoints:
			_cleanup_old_checkpoints()
		
		return checkpoint_id
	
	func restore_checkpoint(checkpoint_id: String) -> Dictionary:
		if checkpoint_id in checkpoints:
			return checkpoints[checkpoint_id].data
		return {}
	
	func _cleanup_old_checkpoints() -> void:
		var sorted_checkpoints = []
		for id in checkpoints.keys():
			sorted_checkpoints.append({"id": id, "timestamp": checkpoints[id].timestamp})
		
		sorted_checkpoints.sort_custom(func(a, b): return a.timestamp > b.timestamp)
		
		# Keep only the most recent checkpoints
		for i in range(max_checkpoints, sorted_checkpoints.size()):
			checkpoints.erase(sorted_checkpoints[i].id)

class DataCompactor:
	var compression_enabled: bool = true
	var auto_archive_enabled: bool = false
	var archive_path: String = "res://data/akashic/archives/"
	var compression_ratio: float = 0.0
	
	# Reference-based compression system
	var string_dictionary: Dictionary = {}  # string -> code
	var reverse_dictionary: Dictionary = {} # code -> string
	var next_code: int = 1000  # Start codes at 1000 to avoid conflicts
	var pattern_cache: Dictionary = {}      # Pattern -> compressed_pattern
	var frequent_sequences: Dictionary = {} # Track repeated sequences
	
	func compact_timeline_data(timeline_data: Dictionary) -> Dictionary:
		if not compression_enabled:
			return timeline_data
		
		var original_size = JSON.stringify(timeline_data).length()
		
		# Step 1: Build string dictionary from data
		_build_string_dictionary(timeline_data)
		
		# Step 2: Compress using reference codes
		var compacted_data = _compress_with_references(timeline_data)
		
		# Step 3: Pattern-based compression
		compacted_data = _compress_patterns(compacted_data)
		
		# Step 4: ZIP-style sequential compression
		compacted_data = _zip_style_compression(compacted_data)
		
		# Step 5: Archive old data
		if auto_archive_enabled:
			_archive_old_entries(compacted_data)
		
		var compressed_size = JSON.stringify(compacted_data).length()
		compression_ratio = 1.0 - (float(compressed_size) / float(original_size))
		
		print("📦 Code-based compression: %.1f%% reduction (%.2fKB -> %.2fKB)" % [
			compression_ratio * 100,
			original_size / 1024.0,
			compressed_size / 1024.0
		])
		print("📦 Dictionary size: %d entries, Pattern cache: %d" % [string_dictionary.size(), pattern_cache.size()])
		
		return compacted_data
	
	func _build_string_dictionary(data: Dictionary) -> void:
		"""Build dictionary of frequent strings for reference compression"""
		var string_frequency = {}
		
		# Recursively collect all strings from the data
		_collect_strings_recursive(data, string_frequency)
		
		# Sort by frequency and assign codes to most common strings
		var sorted_strings = []
		for string_val in string_frequency:
			var frequency = string_frequency[string_val]
			if frequency > 1:  # Only compress strings that appear more than once
				sorted_strings.append({"string": string_val, "frequency": frequency})
		
		sorted_strings.sort_custom(func(a, b): return a.frequency > b.frequency)
		
		# Assign codes to top frequent strings
		for entry in sorted_strings:
			var string_val = entry.string
			if string_val.length() > 3:  # Only compress strings longer than 3 chars
				if not string_val in string_dictionary:
					var code = next_code
					string_dictionary[string_val] = code
					reverse_dictionary[code] = string_val
					next_code += 1
	
	func _collect_strings_recursive(data, frequency_map: Dictionary) -> void:
		"""Recursively collect strings from nested data structures"""
		if data is String:
			if data.length() > 3:  # Only count meaningful strings
				frequency_map[data] = frequency_map.get(data, 0) + 1
		elif data is Dictionary:
			for key in data:
				_collect_strings_recursive(key, frequency_map)
				_collect_strings_recursive(data[key], frequency_map)
		elif data is Array:
			for item in data:
				_collect_strings_recursive(item, frequency_map)
	
	func _compress_with_references(data: Dictionary) -> Dictionary:
		"""Replace frequent strings with reference codes"""
		return _replace_strings_recursive(data)
	
	func _replace_strings_recursive(data):
		"""Recursively replace strings with codes"""
		if data is String:
			if data in string_dictionary:
				return {"$REF": string_dictionary[data]}
			return data
		elif data is Dictionary:
			var compressed = {}
			for key in data:
				var new_key = _replace_strings_recursive(key)
				var new_value = _replace_strings_recursive(data[key])
				compressed[new_key] = new_value
			return compressed
		elif data is Array:
			var compressed = []
			for item in data:
				compressed.append(_replace_strings_recursive(item))
			return compressed
		else:
			return data
	
	func _compress_patterns(data: Dictionary) -> Dictionary:
		"""Advanced pattern compression using sequence detection"""
		var compressed = data.duplicate(true)
		
		# Detect and compress repeating sequences
		if compressed.has("events"):
			compressed.events = _compress_event_sequences(compressed.events)
		
		# Compress being state patterns
		if compressed.has("beings"):
			compressed.beings = _compress_being_patterns(compressed.beings)
		
		# Compress consciousness evolution patterns
		if compressed.has("consciousness_evolution"):
			compressed.consciousness_evolution = _compress_consciousness_patterns(compressed.consciousness_evolution)
		
		return compressed
	
	func _compress_event_sequences(events: Array) -> Array:
		"""Compress repeating event sequences"""
		if events.size() < 3:
			return events
		
		var compressed_events = []
		var i = 0
		
		while i < events.size():
			var sequence_found = false
			
			# Look for sequences of 2-5 events that repeat
			for seq_length in range(2, min(6, events.size() - i + 1)):
				if i + seq_length * 2 <= events.size():
					var sequence = events.slice(i, i + seq_length)
					var next_sequence = events.slice(i + seq_length, i + seq_length * 2)
					
					if _sequences_match(sequence, next_sequence):
						# Found a repeating sequence
						var repeat_count = _count_sequence_repeats(events, i, sequence)
						if repeat_count > 1:
							compressed_events.append({
								"$REPEAT": {
									"sequence": sequence,
									"count": repeat_count
								}
							})
							i += seq_length * repeat_count
							sequence_found = true
							break
			
			if not sequence_found:
				compressed_events.append(events[i])
				i += 1
		
		return compressed_events
	
	func _compress_being_patterns(beings: Dictionary) -> Dictionary:
		"""Compress being data patterns"""
		var compressed = {}
		var pattern_templates = {}
		
		# Find common being property patterns
		for being_id in beings:
			var being_data = beings[being_id]
			if being_data is Dictionary:
				var pattern_signature = _get_being_pattern_signature(being_data)
				
				if pattern_signature in pattern_templates:
					# Use template with differences
					var template = pattern_templates[pattern_signature]
					var differences = _get_differences(template, being_data)
					if differences.size() < being_data.size() / 2:  # Only if it saves space
						compressed[being_id] = {
							"$TEMPLATE": pattern_signature,
							"$DIFF": differences
						}
					else:
						compressed[being_id] = being_data
				else:
					# Create new template
					pattern_templates[pattern_signature] = being_data
					compressed[being_id] = being_data
		
		# Store templates if they're being used
		if pattern_templates.size() > 0:
			compressed["$TEMPLATES"] = pattern_templates
		
		return compressed
	
	func _compress_consciousness_patterns(data: Dictionary) -> Dictionary:
		"""Compress consciousness evolution data by removing micro-changes"""
		var compressed = {}
		
		for being_id in data.keys():
			var evolution_chain = data[being_id]
			if evolution_chain is Array and evolution_chain.size() > 2:
				var filtered_chain = []
				var last_significant = null
				
				for i in range(evolution_chain.size()):
					var entry = evolution_chain[i]
					var is_significant = false
					
					# Always keep first and last entries
					if i == 0 or i == evolution_chain.size() - 1:
						is_significant = true
					# Keep significant consciousness changes
					elif last_significant and _is_significant_consciousness_change(entry, last_significant):
						is_significant = true
					# Keep entries with important events
					elif entry.has("event_type") and entry.event_type in ["evolution", "creation", "destruction"]:
						is_significant = true
					
					if is_significant:
						filtered_chain.append(entry)
						last_significant = entry
				
				# Use RLE (Run-Length Encoding) for consciousness levels
				filtered_chain = _apply_consciousness_rle(filtered_chain)
				compressed[being_id] = filtered_chain
			else:
				compressed[being_id] = evolution_chain
		
		return compressed
	
	func _zip_style_compression(data: Dictionary) -> Dictionary:
		"""Apply ZIP-style compression techniques"""
		var compressed = data.duplicate(true)
		
		# Add compression metadata
		compressed["$COMPRESSION"] = {
			"version": "1.0",
			"method": "reference_pattern_rle",
			"dictionary_size": string_dictionary.size(),
			"timestamp": Time.get_ticks_msec()
		}
		
		# Store the dictionary for decompression
		if string_dictionary.size() > 0:
			compressed["$DICTIONARY"] = reverse_dictionary
		
		return compressed
	
	# Helper methods for pattern compression
	func _sequences_match(seq1: Array, seq2: Array) -> bool:
		if seq1.size() != seq2.size():
			return false
		for i in range(seq1.size()):
			if not _events_similar(seq1[i], seq2[i]):
				return false
		return true
	
	func _events_similar(event1, event2) -> bool:
		if typeof(event1) != typeof(event2):
			return false
		if event1 is Dictionary and event2 is Dictionary:
			var type1 = event1.get("type", "")
			var type2 = event2.get("type", "")
			return type1 == type2
		return event1 == event2
	
	func _count_sequence_repeats(events: Array, start_pos: int, sequence: Array) -> int:
		var count = 0
		var pos = start_pos
		var seq_length = sequence.size()
		
		while pos + seq_length <= events.size():
			var current_seq = events.slice(pos, pos + seq_length)
			if _sequences_match(sequence, current_seq):
				count += 1
				pos += seq_length
			else:
				break
		
		return count
	
	func _get_being_pattern_signature(being_data: Dictionary) -> String:
		"""Create a signature for being data pattern"""
		var signature_parts = []
		var sorted_keys = being_data.keys()
		sorted_keys.sort()
		
		for key in sorted_keys:
			var value = being_data[key]
			if value is String:
				signature_parts.append(key + ":string")
			elif value is int:
				signature_parts.append(key + ":int")
			elif value is float:
				signature_parts.append(key + ":float")
			elif value is Array:
				signature_parts.append(key + ":array[" + str(value.size()) + "]")
			elif value is Dictionary:
				signature_parts.append(key + ":dict")
			else:
				signature_parts.append(key + ":other")
		
		return signature_parts.join("|")
	
	func _get_differences(template: Dictionary, data: Dictionary) -> Dictionary:
		"""Get differences between template and data"""
		var differences = {}
		
		for key in data:
			if not template.has(key) or template[key] != data[key]:
				differences[key] = data[key]
		
		return differences
	
	func _apply_consciousness_rle(chain: Array) -> Array:
		"""Apply Run-Length Encoding to consciousness levels"""
		if chain.size() < 2:
			return chain
		
		var compressed = []
		var current_level = null
		var count = 0
		
		for entry in chain:
			var level = entry.get("consciousness_level", -1)
			
			if level == current_level:
				count += 1
			else:
				# Output previous run
				if current_level != null and count > 1:
					compressed.append({
						"$RLE_CONSCIOUSNESS": current_level,
						"$COUNT": count,
						"$LAST_ENTRY": compressed[-1] if compressed.size() > 0 else entry
					})
				else:
					compressed.append(entry)
				
				current_level = level
				count = 1
		
		return compressed
	
	func _is_significant_consciousness_change(current: Dictionary, previous: Dictionary) -> bool:
		var current_level = current.get("consciousness_level", 0)
		var previous_level = previous.get("consciousness_level", 0)
		return abs(current_level - previous_level) >= 1
	
	# Decompression methods
	func decompress_data(compressed_data: Dictionary) -> Dictionary:
		"""Decompress data back to original format"""
		if not compressed_data.has("$COMPRESSION"):
			return compressed_data  # Not compressed
		
		var decompressed = compressed_data.duplicate(true)
		
		# Remove compression metadata
		decompressed.erase("$COMPRESSION")
		
		# Restore dictionary references
		if decompressed.has("$DICTIONARY"):
			reverse_dictionary = decompressed["$DICTIONARY"]
			_restore_string_references(decompressed)
			decompressed.erase("$DICTIONARY")
		
		# Decompress patterns
		decompressed = _decompress_patterns(decompressed)
		
		return decompressed
	
	func _restore_string_references(data):
		"""Recursively restore string references"""
		if data is Dictionary:
			if data.has("$REF"):
				var code = data["$REF"]
				if code in reverse_dictionary:
					return reverse_dictionary[code]
			else:
				for key in data:
					data[key] = _restore_string_references(data[key])
		elif data is Array:
			for i in range(data.size()):
				data[i] = _restore_string_references(data[i])
		return data
	
	func _decompress_patterns(data: Dictionary) -> Dictionary:
		"""Decompress pattern-compressed data"""
		# Implementation would reverse the pattern compression
		# This is a placeholder for the decompression logic
		return data
	
	func _archive_old_entries(data: Dictionary) -> void:
		# Archive old data to separate files
		_ensure_dir_exists(archive_path)
		
		var archive_file_path = archive_path + "archive_%d.json" % Time.get_ticks_msec()
		var file = FileAccess.open(archive_file_path, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(data, "\t"))
			file.close()
			print("📦 Old data archived to: %s" % archive_file_path)
	
	func _ensure_dir_exists(path: String) -> void:
		if not DirAccess.dir_exists_absolute(path):
			DirAccess.make_dir_recursive_absolute(path)

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

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	name = "AkashicRecordsEnhanced"
	timeline_id = "main_timeline_%d" % Time.get_ticks_msec()
	
	# Initialize subsystems
	checkpoint_system = CheckpointManager.new()
	data_compactor = DataCompactor.new()
	
	# Create initial timeline branch
	var main_branch = TimelineBranch.new(timeline_id, "", 0.0, "Genesis - The Beginning")
	timeline_branches[timeline_id] = main_branch
	
	# Ensure directories exist
	_ensure_dir_exists("res://data/akashic/")
	_ensure_dir_exists("res://data/akashic/timelines/")
	_ensure_dir_exists("res://data/akashic/checkpoints/")
	_ensure_dir_exists("res://data/akashic/archives/")
	
	print("🌌 Enhanced Akashic Records initialized with 4D timeline system")

func pentagon_ready() -> void:
	# Load existing timeline data if available
	load_timeline_continuity()
	
	# Create initial checkpoint
	var initial_state = capture_universe_state()
	checkpoint_system.create_checkpoint("genesis", initial_state)
	
	print("🌌 Akashic Records ready - Timeline continuity restored")

func pentagon_process(delta: float) -> void:
	# Auto-save mechanism
	last_auto_save += delta
	if last_auto_save >= auto_save_interval:
		auto_save_timeline_state()
		last_auto_save = 0.0
	
	# Auto-checkpoint mechanism
	checkpoint_system.last_checkpoint += delta
	if checkpoint_system.last_checkpoint >= checkpoint_system.auto_checkpoint_interval:
		auto_create_checkpoint()
		checkpoint_system.last_checkpoint = 0.0
	
	# Check for data compaction needs
	if should_compact_data():
		compact_timeline_data()

func pentagon_input(event: InputEvent) -> void:
	# Handle timeline navigation input if needed
	pass

func pentagon_sewers() -> void:
	# Save final state before shutdown
	save_timeline_continuity()
	print("🌌 Enhanced Akashic Records preserved for eternity")

# ===== 4D TIMELINE MANAGEMENT =====

func create_timeline_branch(reason: String, decision_data: Dictionary = {}) -> String:
	"""Create a new timeline branch from current point"""
	var branch_point = Time.get_ticks_msec() / 1000.0
	var branch_id = "branch_%d_%s" % [Time.get_ticks_msec(), reason.replace(" ", "_")]
	
	# Capture current universe state
	var current_state = capture_universe_state()
	
	# Create new branch
	var new_branch = TimelineBranch.new(branch_id, timeline_id, branch_point, reason)
	new_branch.decision_data = decision_data
	new_branch.universe_states.append(current_state)
	
	# Store beings at branch point
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("get_all_beings"):
			var all_beings = flood_gates.get_all_beings()
			for being in all_beings:
				if being.has_method("ai_interface"):
					new_branch.beings_at_branch.append(being.ai_interface())
	
	timeline_branches[branch_id] = new_branch
	
	# Manage branch limit
	if timeline_branches.size() > max_timeline_branches:
		_cleanup_old_branches()
	
	log_timeline_event("branch_creation", "🌿 Timeline branched: %s" % reason, {
		"branch_id": branch_id,
		"reason": reason,
		"decision_data": decision_data
	})
	
	return branch_id

func switch_timeline(branch_id: String) -> bool:
	"""Switch to a different timeline branch"""
	if not branch_id in timeline_branches:
		push_error("Timeline branch not found: %s" % branch_id)
		return false
	
	# Save current timeline state
	save_current_timeline_state()
	
	# Switch to new timeline
	var old_timeline = timeline_id
	timeline_id = branch_id
	current_timeline_index = 0
	
	# Restore timeline state
	restore_timeline_state(branch_id)
	
	log_timeline_event("timeline_switch", "🔄 Timeline switched from %s to %s" % [old_timeline, branch_id], {
		"from_timeline": old_timeline,
		"to_timeline": branch_id
	})
	
	return true

func merge_timelines(source_branch: String, target_branch: String) -> bool:
	"""Merge two timeline branches"""
	if not source_branch in timeline_branches or not target_branch in timeline_branches:
		push_error("One or both timeline branches not found")
		return false
	
	var source = timeline_branches[source_branch]
	var target = timeline_branches[target_branch]
	
	# Merge universe states
	target.universe_states.append_array(source.universe_states)
	
	# Merge being data
	target.beings_at_branch.append_array(source.beings_at_branch)
	
	# Merge decision data
	for key in source.decision_data:
		if not key in target.decision_data:
			target.decision_data[key] = source.decision_data[key]
	
	# Remove source branch
	timeline_branches.erase(source_branch)
	
	log_timeline_event("timeline_merge", "🔗 Timelines merged: %s into %s" % [source_branch, target_branch], {
		"source": source_branch,
		"target": target_branch
	})
	
	return true

# ===== SCENARIO SYSTEM =====

func start_scenario(scenario_type: String, participants: Array[String] = []) -> String:
	"""Start a new scenario for tracking related events"""
	var scenario_id = "scenario_%d_%s" % [Time.get_ticks_msec(), scenario_type]
	var scenario = Scenario.new(scenario_id, scenario_type)
	scenario.participants = participants
	
	active_scenarios[scenario_id] = scenario
	
	log_timeline_event("scenario_start", "🎭 Scenario begun: %s with %d participants" % [scenario_type, participants.size()], {
		"scenario_id": scenario_id,
		"scenario_type": scenario_type,
		"participants": participants
	})
	
	return scenario_id

func end_scenario(scenario_id: String, outcome_data: Dictionary = {}) -> bool:
	"""End a scenario and record its outcome"""
	if not scenario_id in active_scenarios:
		return false
	
	var scenario = active_scenarios[scenario_id]
	scenario.end_time = Time.get_ticks_msec() / 1000.0
	scenario.outcome_data = outcome_data
	
	# Archive completed scenario
	_archive_scenario(scenario)
	
	# Remove from active scenarios
	active_scenarios.erase(scenario_id)
	
	log_timeline_event("scenario_end", "🎭 Scenario completed: %s (duration: %.2fs)" % [scenario.scenario_type, scenario.end_time - scenario.start_time], {
		"scenario_id": scenario_id,
		"outcome": outcome_data
	})
	
	return true

func add_scenario_event(scenario_id: String, event_data: Dictionary) -> void:
	"""Add an event to an active scenario"""
	if scenario_id in active_scenarios:
		var scenario = active_scenarios[scenario_id]
		event_data["timestamp"] = Time.get_ticks_msec() / 1000.0
		scenario.key_events.append(event_data)

# ===== STATE CAPTURE AND RESTORATION =====

func capture_universe_state() -> Dictionary:
	"""Capture complete universe state for timeline preservation"""
	var state = {
		"timestamp": Time.get_ticks_msec() / 1000.0,
		"beings": {},
		"universes": {},
		"systems": {},
		"consciousness_network": {}
	}
	
	# Capture all beings
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("get_all_beings"):
			var all_beings = flood_gates.get_all_beings()
			for being in all_beings:
				if being.has_method("ai_interface"):
					state.beings[being.being_uuid] = being.ai_interface()
	
	# Capture universe states
	state.universes = capture_universe_hierarchy()
	
	# Capture system states
	state.systems = capture_system_states()
	
	# Capture consciousness network
	state.consciousness_network = capture_consciousness_network()
	
	return state

func restore_universe_state(state: Dictionary) -> bool:
	"""Restore universe to a previous state"""
	if not state.has("timestamp"):
		push_error("Invalid state data - missing timestamp")
		return false
	
	print("🔄 Restoring universe state from timestamp: %f" % state.timestamp)
	
	# Restore beings
	if state.has("beings"):
		restore_beings_from_state(state.beings)
	
	# Restore universes
	if state.has("universes"):
		restore_universes_from_state(state.universes)
	
	# Restore systems
	if state.has("systems"):
		restore_systems_from_state(state.systems)
	
	# Restore consciousness network
	if state.has("consciousness_network"):
		restore_consciousness_network(state.consciousness_network)
	
	log_timeline_event("state_restoration", "🔄 Universe state restored to timestamp %f" % state.timestamp, {
		"restored_timestamp": state.timestamp,
		"beings_count": state.beings.size() if state.has("beings") else 0
	})
	
	return true

func capture_universe_hierarchy() -> Dictionary:
	"""Capture hierarchical universe structure"""
	var universes = {}
	
	# Find all universe beings
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("get_all_beings"):
			var all_beings = flood_gates.get_all_beings()
			for being in all_beings:
				if being.has_method("get") and being.get("being_type") == "universe":
					universes[being.being_uuid] = {
						"universe_name": being.get("universe_name"),
						"physics_scale": being.get("physics_scale"),
						"time_scale": being.get("time_scale"),
						"lod_level": being.get("lod_level"),
						"universe_rules": being.get("universe_rules"),
						"universe_dna": being.get("universe_dna"),
						"child_count": being.get("child_universes").size() if being.has_method("get") else 0
					}
	
	return universes

func capture_system_states() -> Dictionary:
	"""Capture states of core systems"""
	var systems = {}
	
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		systems["bootstrap_ready"] = true
		
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates:
			systems["flood_gates"] = {
				"beings_count": flood_gates.get_being_count() if flood_gates.has_method("get_being_count") else 0,
				"ready": true
			}
		
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic:
			systems["akashic_records"] = {
				"ready": true
			}
	
	return systems

func capture_consciousness_network() -> Dictionary:
	"""Capture consciousness interaction network"""
	var network = {
		"connections": [],
		"evolution_chains": being_evolution_chains.duplicate(true),
		"flow_map": consciousness_flow_map.duplicate(true)
	}
	
	# Capture current consciousness connections
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("get_all_beings"):
			var all_beings = flood_gates.get_all_beings()
			for being in all_beings:
				if being.has_method("get"):
					var connections = being.get("consciousness_connections")
					if connections and connections.size() > 0:
						network.connections.append({
							"being_uuid": being.being_uuid,
							"consciousness_level": being.consciousness_level,
							"connections": connections.size()
						})
	
	return network

# ===== RESTORATION METHODS =====

func restore_beings_from_state(beings_data: Dictionary) -> void:
	"""Restore beings to previous states"""
	for being_uuid in beings_data:
		var being_data = beings_data[being_uuid]
		# Find being and restore its properties
		if SystemBootstrap and SystemBootstrap.is_system_ready():
			var flood_gates = SystemBootstrap.get_flood_gates()
			if flood_gates and flood_gates.has_method("get_being_by_uuid"):
				var being = flood_gates.get_being_by_uuid(being_uuid)
				if being and being.has_method("ai_modify_property"):
					for property in being_data.properties:
						being.ai_modify_property(property, being_data.properties[property])

func restore_universes_from_state(universes_data: Dictionary) -> void:
	"""Restore universe states"""
	for universe_uuid in universes_data:
		var universe_data = universes_data[universe_uuid]
		# Find and restore universe
		if SystemBootstrap and SystemBootstrap.is_system_ready():
			var flood_gates = SystemBootstrap.get_flood_gates()
			if flood_gates and flood_gates.has_method("get_being_by_uuid"):
				var universe = flood_gates.get_being_by_uuid(universe_uuid)
				if universe and universe.has_method("set_universe_rule"):
					# Restore universe rules
					if universe_data.has("universe_rules"):
						for rule in universe_data.universe_rules:
							universe.set_universe_rule(rule, universe_data.universe_rules[rule])

func restore_systems_from_state(systems_data: Dictionary) -> void:
	"""Restore system states"""
	print("🔄 Restoring system states: %s" % str(systems_data.keys()))

func restore_consciousness_network(network_data: Dictionary) -> void:
	"""Restore consciousness network connections"""
	if network_data.has("evolution_chains"):
		being_evolution_chains = network_data.evolution_chains
	if network_data.has("flow_map"):
		consciousness_flow_map = network_data.flow_map

# ===== CHECKPOINT SYSTEM =====

func create_manual_checkpoint(name: String) -> String:
	"""Create a manual checkpoint"""
	var state = capture_universe_state()
	var checkpoint_id = checkpoint_system.create_checkpoint(name, state)
	
	log_timeline_event("checkpoint_created", "💾 Manual checkpoint created: %s" % name, {
		"checkpoint_id": checkpoint_id,
		"state_size": JSON.stringify(state).length()
	})
	
	return checkpoint_id

func auto_create_checkpoint() -> String:
	"""Create automatic checkpoint"""
	var name = "auto_checkpoint_%d" % Time.get_ticks_msec()
	return create_manual_checkpoint(name)

func restore_from_checkpoint(checkpoint_id: String) -> bool:
	"""Restore universe from checkpoint"""
	var checkpoint_data = checkpoint_system.restore_checkpoint(checkpoint_id)
	if checkpoint_data.is_empty():
		push_error("Checkpoint not found: %s" % checkpoint_id)
		return false
	
	return restore_universe_state(checkpoint_data)

func list_checkpoints() -> Array:
	"""Get list of available checkpoints"""
	var checkpoints_list = []
	for id in checkpoint_system.checkpoints:
		var checkpoint = checkpoint_system.checkpoints[id]
		checkpoints_list.append({
			"id": id,
			"name": checkpoint.name,
			"timestamp": checkpoint.timestamp,
			"size": checkpoint.size
		})
	
	checkpoints_list.sort_custom(func(a, b): return a.timestamp > b.timestamp)
	return checkpoints_list

# ===== DATA COMPACTING SYSTEM =====

func compact_timeline_data() -> void:
	"""Compact timeline data to reduce memory usage"""
	print("📦 Starting timeline data compaction...")
	
	# Compact timeline branches
	for branch_id in timeline_branches:
		var branch = timeline_branches[branch_id]
		branch.universe_states = data_compactor.compact_timeline_data({"states": branch.universe_states})["states"]
	
	# Compact being evolution chains
	being_evolution_chains = data_compactor.compact_timeline_data(being_evolution_chains)
	
	# Compact universe states
	var compacted_states = {}
	for timestamp in universe_states:
		compacted_states[timestamp] = data_compactor.compact_timeline_data(universe_states[timestamp])
	universe_states = compacted_states
	
	print("📦 Timeline data compaction completed")

func should_compact_data() -> bool:
	"""Check if data compaction is needed"""
	var total_entries = 0
	
	# Count timeline entries
	for branch_id in timeline_branches:
		total_entries += timeline_branches[branch_id].universe_states.size()
	
	# Count universe states
	total_entries += universe_states.size()
	
	# Count evolution chains
	total_entries += being_evolution_chains.size()
	
	return total_entries > compression_threshold

# ===== SAVE/LOAD SYSTEM =====

func save_timeline_continuity() -> bool:
	"""Save complete timeline data for continuity"""
	var save_data = {
		"version": "1.0",
		"timeline_id": timeline_id,
		"current_timeline_index": current_timeline_index,
		"timeline_branches": serialize_timeline_branches(),
		"active_scenarios": serialize_active_scenarios(),
		"universe_states": universe_states,
		"being_evolution_chains": being_evolution_chains,
		"consciousness_flow_map": consciousness_flow_map,
		"checkpoints": checkpoint_system.checkpoints,
		"save_timestamp": Time.get_ticks_msec() / 1000.0
	}
	
	var file_path = "res://data/akashic/timeline_continuity.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open timeline continuity file for writing")
		return false
	
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	
	print("🌌 Timeline continuity saved to: %s" % file_path)
	return true

func load_timeline_continuity() -> bool:
	"""Load timeline data for continuity"""
	var file_path = "res://data/akashic/timeline_continuity.json"
	if not FileAccess.file_exists(file_path):
		print("🌌 No existing timeline continuity file found - starting fresh")
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open timeline continuity file for reading")
		return false
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		push_error("Failed to parse timeline continuity JSON")
		return false
	
	var save_data = json.get_data()
	
	# Restore timeline data
	timeline_id = save_data.get("timeline_id", timeline_id)
	current_timeline_index = save_data.get("current_timeline_index", 0)
	universe_states = save_data.get("universe_states", {})
	being_evolution_chains = save_data.get("being_evolution_chains", {})
	consciousness_flow_map = save_data.get("consciousness_flow_map", {})
	
	# Restore timeline branches
	if save_data.has("timeline_branches"):
		deserialize_timeline_branches(save_data.timeline_branches)
	
	# Restore active scenarios
	if save_data.has("active_scenarios"):
		deserialize_active_scenarios(save_data.active_scenarios)
	
	# Restore checkpoints
	if save_data.has("checkpoints"):
		checkpoint_system.checkpoints = save_data.checkpoints
	
	print("🌌 Timeline continuity restored from: %s" % file_path)
	return true

func auto_save_timeline_state() -> void:
	"""Auto-save timeline state"""
	save_timeline_continuity()

# ===== SERIALIZATION HELPERS =====

func serialize_timeline_branches() -> Dictionary:
	"""Serialize timeline branches for saving"""
	var serialized = {}
	for branch_id in timeline_branches:
		var branch = timeline_branches[branch_id]
		serialized[branch_id] = {
			"branch_id": branch.branch_id,
			"parent_timeline": branch.parent_timeline,
			"branch_point": branch.branch_point,
			"branch_reason": branch.branch_reason,
			"universe_states": branch.universe_states,
			"beings_at_branch": branch.beings_at_branch,
			"decision_data": branch.decision_data
		}
	return serialized

func deserialize_timeline_branches(data: Dictionary) -> void:
	"""Deserialize timeline branches from saved data"""
	timeline_branches.clear()
	for branch_id in data:
		var branch_data = data[branch_id]
		var branch = TimelineBranch.new(
			branch_data.branch_id,
			branch_data.parent_timeline,
			branch_data.branch_point,
			branch_data.branch_reason
		)
		branch.universe_states = branch_data.universe_states
		branch.beings_at_branch = branch_data.beings_at_branch
		branch.decision_data = branch_data.decision_data
		timeline_branches[branch_id] = branch

func serialize_active_scenarios() -> Dictionary:
	"""Serialize active scenarios for saving"""
	var serialized = {}
	for scenario_id in active_scenarios:
		var scenario = active_scenarios[scenario_id]
		serialized[scenario_id] = {
			"scenario_id": scenario.scenario_id,
			"scenario_type": scenario.scenario_type,
			"start_time": scenario.start_time,
			"end_time": scenario.end_time,
			"participants": scenario.participants,
			"key_events": scenario.key_events,
			"outcome_data": scenario.outcome_data
		}
	return serialized

func deserialize_active_scenarios(data: Dictionary) -> void:
	"""Deserialize active scenarios from saved data"""
	active_scenarios.clear()
	for scenario_id in data:
		var scenario_data = data[scenario_id]
		var scenario = Scenario.new(scenario_data.scenario_id, scenario_data.scenario_type)
		scenario.start_time = scenario_data.start_time
		scenario.end_time = scenario_data.end_time
		scenario.participants = scenario_data.participants
		scenario.key_events = scenario_data.key_events
		scenario.outcome_data = scenario_data.outcome_data
		active_scenarios[scenario_id] = scenario

# ===== UTILITY FUNCTIONS =====

func _ensure_dir_exists(path: String) -> void:
	"""Ensure directory exists"""
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)

func save_current_timeline_state() -> void:
	"""Save current timeline state before switching"""
	var current_state = capture_universe_state()
	universe_states["%s_%f" % [timeline_id, Time.get_ticks_msec() / 1000.0]] = current_state

func restore_timeline_state(branch_id: String) -> void:
	"""Restore timeline state when switching branches"""
	var branch = timeline_branches[branch_id]
	if branch.universe_states.size() > 0:
		var latest_state = branch.universe_states[-1]
		restore_universe_state(latest_state)

func _cleanup_old_branches() -> void:
	"""Clean up old timeline branches to maintain limit"""
	var sorted_branches = []
	for branch_id in timeline_branches:
		var branch = timeline_branches[branch_id]
		sorted_branches.append({"id": branch_id, "point": branch.branch_point})
	
	sorted_branches.sort_custom(func(a, b): return a.point < b.point)
	
	# Remove oldest branches
	var branches_to_remove = sorted_branches.size() - max_timeline_branches
	for i in range(branches_to_remove):
		timeline_branches.erase(sorted_branches[i].id)

func _archive_scenario(scenario: Scenario) -> void:
	"""Archive completed scenario"""
	var archive_path = "res://data/akashic/scenarios/"
	_ensure_dir_exists(archive_path)
	
	var file_path = archive_path + "scenario_%s.json" % scenario.scenario_id
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var scenario_data = {
			"scenario_id": scenario.scenario_id,
			"scenario_type": scenario.scenario_type,
			"start_time": scenario.start_time,
			"end_time": scenario.end_time,
			"participants": scenario.participants,
			"key_events": scenario.key_events,
			"outcome_data": scenario.outcome_data
		}
		file.store_string(JSON.stringify(scenario_data, "\t"))
		file.close()

func log_timeline_event(event_type: String, message: String, data: Dictionary = {}) -> void:
	"""Log timeline-related events with intelligent compression"""
	print("🌌 %s" % message)
	
	# Store in compressed format
	var log_entry = {
		"event_type": event_type,
		"message": message,
		"data": data,
		"timestamp": Time.get_ticks_msec() / 1000.0
	}
	
	# Add to interaction logs with smart compression
	log_interaction(log_entry)
	
	# Also log to Akashic Library if available
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_library()
		if akashic:
			akashic.log_universe_event(event_type, message, data)

# ===== ENHANCED COMPRESSION INTEGRATION =====

func get_compression_stats() -> Dictionary:
	"""Get detailed compression statistics"""
	var stats = {
		"dictionary_size": data_compactor.string_dictionary.size(),
		"compression_ratio": data_compactor.compression_ratio,
		"timeline_branches": timeline_branches.size(),
		"universe_states": universe_states.size(),
		"being_evolution_chains": being_evolution_chains.size(),
		"active_scenarios": active_scenarios.size(),
		"checkpoints": checkpoint_system.checkpoints.size()
	}
	
	# Calculate total data size
	var total_data = {
		"timeline_branches": timeline_branches,
		"universe_states": universe_states,
		"being_evolution_chains": being_evolution_chains,
		"active_scenarios": serialize_active_scenarios()
	}
	
	var uncompressed_size = JSON.stringify(total_data).length()
	var compressed_data = data_compactor.compact_timeline_data(total_data)
	var compressed_size = JSON.stringify(compressed_data).length()
	
	stats["uncompressed_size_kb"] = uncompressed_size / 1024.0
	stats["compressed_size_kb"] = compressed_size / 1024.0
	stats["space_saved_kb"] = (uncompressed_size - compressed_size) / 1024.0
	stats["efficiency_percent"] = (1.0 - float(compressed_size) / float(uncompressed_size)) * 100.0
	
	return stats

func export_compressed_timeline(file_path: String) -> bool:
	"""Export entire timeline in compressed format"""
	var export_data = {
		"version": "1.0",
		"export_timestamp": Time.get_ticks_msec() / 1000.0,
		"timeline_id": timeline_id,
		"timeline_branches": timeline_branches,
		"universe_states": universe_states,
		"being_evolution_chains": being_evolution_chains,
		"active_scenarios": active_scenarios,
		"interaction_logs": interaction_logs,
		"being_database": being_database,
		"checkpoints": checkpoint_system.checkpoints
	}
	
	# Apply advanced compression
	var compressed_export = data_compactor.compact_timeline_data(export_data)
	
	# Save to file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open export file: %s" % file_path)
		return false
	
	file.store_string(JSON.stringify(compressed_export, "\t"))
	file.close()
	
	var stats = get_compression_stats()
	print("📦 Timeline exported with %.1f%% compression to: %s" % [stats.efficiency_percent, file_path])
	print("📦 Original: %.2fKB → Compressed: %.2fKB (saved %.2fKB)" % [
		stats.uncompressed_size_kb,
		stats.compressed_size_kb,
		stats.space_saved_kb
	])
	
	return true

func import_compressed_timeline(file_path: String) -> bool:
	"""Import timeline from compressed format"""
	if not FileAccess.file_exists(file_path):
		push_error("Import file not found: %s" % file_path)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open import file: %s" % file_path)
		return false
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		push_error("Failed to parse import JSON")
		return false
	
	var compressed_data = json.get_data()
	
	# Decompress the data
	var decompressed_data = data_compactor.decompress_data(compressed_data)
	
	# Restore timeline data
	if decompressed_data.has("timeline_branches"):
		timeline_branches = decompressed_data.timeline_branches
	if decompressed_data.has("universe_states"):
		universe_states = decompressed_data.universe_states
	if decompressed_data.has("being_evolution_chains"):
		being_evolution_chains = decompressed_data.being_evolution_chains
	if decompressed_data.has("active_scenarios"):
		active_scenarios = decompressed_data.active_scenarios
	if decompressed_data.has("interaction_logs"):
		interaction_logs = decompressed_data.interaction_logs
	if decompressed_data.has("being_database"):
		being_database = decompressed_data.being_database
	if decompressed_data.has("checkpoints"):
		checkpoint_system.checkpoints = decompressed_data.checkpoints
	
	print("🌌 Timeline imported successfully from: %s" % file_path)
	print("📦 Decompression completed - timeline data restored")
	
	return true

func optimize_storage() -> Dictionary:
	"""Manually trigger storage optimization"""
	print("🔧 Starting manual storage optimization...")
	
	var before_stats = get_compression_stats()
	
	# Force compression of all stored data
	compact_timeline_data()
	
	# Clean up old checkpoints
	checkpoint_system._cleanup_old_checkpoints()
	
	# Clean up old timeline branches
	_cleanup_old_branches()
	
	# Archive old interaction logs
	if interaction_logs.size() > MAX_GLOBAL_LOGS:
		archive_old_logs()
	
	var after_stats = get_compression_stats()
	
	var optimization_report = {
		"before": before_stats,
		"after": after_stats,
		"space_saved_kb": before_stats.uncompressed_size_kb - after_stats.uncompressed_size_kb,
		"efficiency_gain_percent": after_stats.efficiency_percent - before_stats.efficiency_percent
	}
	
	print("🔧 Storage optimization complete!")
	print("📦 Space saved: %.2fKB" % optimization_report.space_saved_kb)
	print("📦 Efficiency improvement: %.1f%%" % optimization_report.efficiency_gain_percent)
	
	return optimization_report

# ===== SIGNALS =====
signal interaction_logged(event: Dictionary)
signal causal_event_triggered(event: Dictionary)
signal memory_archived(being_uuid: String, memory_count: int)
signal timeline_created(timeline_id: String)
signal timeline_switched(old_timeline: String, new_timeline: String)
signal checkpoint_created(checkpoint_id: String)
signal scenario_started(scenario_id: String)
signal scenario_ended(scenario_id: String)
