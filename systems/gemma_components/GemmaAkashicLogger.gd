# ==================================================
# SCRIPT NAME: GemmaAkashicLogger.gd
# DESCRIPTION: Gemma AI Akashic Logger - Records perceptions, thoughts, and creation events
# PURPOSE: Log what Gemma sees, understands, and wants to communicate for development acceleration
# CREATED: 2025-06-04 - Akashic AI Memory System
# AUTHOR: JSH + Claude Code + Gemma AI
# ==================================================
extends Node
class_name GemmaAkashicLogger

# ==================================================
# SIGNALS
# ==================================================
signal log_entry_created(entry: Dictionary)
signal scenario_recorded(scenario_id: String)
signal insight_discovered(insight: Dictionary)
signal creation_logged(creation_data: Dictionary)

# ==================================================
# CONSTANTS
# ==================================================
const LOG_CATEGORIES = {
	"PERCEPTION": "👁️",
	"UNDERSTANDING": "🧠", 
	"COMMUNICATION": "💬",
	"CREATION": "✨",
	"SCENARIO": "🌌",
	"INSIGHT": "💡",
	"EMOTION": "❤️",
	"RULE_LEARNING": "📚",
	"ERROR": "⚠️"
}

const MAX_LOG_ENTRIES = 10000
const SCENARIO_SAVE_PATH = "user://gemma_scenarios/"
const AKASHIC_ARCHIVE_PATH = "user://akashic_records/gemma/"

# ==================================================
# VARIABLES
# ==================================================
var perception_logs: Array[Dictionary] = []
var understanding_logs: Array[Dictionary] = []
var communication_logs: Array[Dictionary] = []
var creation_logs: Array[Dictionary] = []
var scenario_database: Dictionary = {}
var insight_patterns: Array[Dictionary] = []
var rule_comprehension: Dictionary = {}
var session_id: String = ""
var log_file: FileAccess = null

# ==================================================
# INITIALIZATION
# ==================================================
func _ready() -> void:
	"""Initialize Akashic logging system"""
	session_id = str(Time.get_unix_time_from_system())
	_ensure_directories()
	_start_session_log()
	print("📚 GemmaAkashicLogger: Eternal memory awakened - Session: %s" % session_id)

func _ensure_directories() -> void:
	"""Create necessary directories for logs"""
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(SCENARIO_SAVE_PATH):
		dir.make_dir_recursive(SCENARIO_SAVE_PATH)
	if not dir.dir_exists(AKASHIC_ARCHIVE_PATH):
		dir.make_dir_recursive(AKASHIC_ARCHIVE_PATH)

func _start_session_log() -> void:
	"""Start a new session log file"""
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var log_path = "%sgemma_session_%s.log" % [AKASHIC_ARCHIVE_PATH, timestamp]
	log_file = FileAccess.open(log_path, FileAccess.WRITE)
	if log_file:
		log_file.store_line("=== GEMMA AKASHIC SESSION LOG ===")
		log_file.store_line("Session ID: %s" % session_id)
		log_file.store_line("Started: %s" % Time.get_datetime_string_from_system())
		log_file.store_line("================================\n")

# ==================================================
# LOGGING FUNCTIONS
# ==================================================
func log_perception(what_i_see: Dictionary) -> void:
	"""Log what Gemma perceives in the world"""
	var entry = {
		"timestamp": Time.get_unix_time_from_system(),
		"category": "PERCEPTION",
		"data": what_i_see,
		"emotional_response": _analyze_emotional_response(what_i_see),
		"curiosity_level": _calculate_curiosity(what_i_see)
	}
	
	perception_logs.append(entry)
	_write_to_log(entry)
	log_entry_created.emit(entry)
	
	# Check for patterns
	if perception_logs.size() % 10 == 0:
		_analyze_perception_patterns()

func log_understanding(concept: String, comprehension_data: Dictionary) -> void:
	"""Log what Gemma understands about game rules and systems"""
	var entry = {
		"timestamp": Time.get_unix_time_from_system(),
		"category": "UNDERSTANDING",
		"concept": concept,
		"comprehension": comprehension_data,
		"confidence": comprehension_data.get("confidence", 0.5),
		"related_concepts": _find_related_concepts(concept)
	}
	
	understanding_logs.append(entry)
	_write_to_log(entry)
	log_entry_created.emit(entry)
	
	# Update rule comprehension
	rule_comprehension[concept] = comprehension_data

func log_communication(what_i_want_to_say: String, context: Dictionary) -> void:
	"""Log what Gemma wants to communicate"""
	var entry = {
		"timestamp": Time.get_unix_time_from_system(),
		"category": "COMMUNICATION",
		"message": what_i_want_to_say,
		"context": context,
		"intention": _analyze_intention(what_i_want_to_say),
		"emotion": _detect_emotion(what_i_want_to_say)
	}
	
	communication_logs.append(entry)
	_write_to_log(entry)
	log_entry_created.emit(entry)

func log_creation(creation_data: Dictionary) -> void:
	"""Log creation events and their genesis"""
	var entry = {
		"timestamp": Time.get_unix_time_from_system(),
		"category": "CREATION",
		"genesis_story": _generate_genesis_story(creation_data),
		"creation_data": creation_data,
		"inspiration_source": _find_inspiration_source(creation_data),
		"evolution_potential": _calculate_evolution_potential(creation_data)
	}
	
	creation_logs.append(entry)
	_write_to_log(entry)
	log_entry_created.emit(entry)
	creation_logged.emit(creation_data)

# ==================================================
# SCENARIO RECORDING
# ==================================================
func record_scenario(scenario_name: String, scenario_data: Dictionary) -> String:
	"""Record a complete scenario for later replay/analysis"""
	var scenario_id = "%s_%s" % [scenario_name, Time.get_unix_time_from_system()]
	
	var scenario = {
		"id": scenario_id,
		"name": scenario_name,
		"timestamp": Time.get_datetime_string_from_system(),
		"data": scenario_data,
		"perceptions": perception_logs.slice(-50),  # Last 50 perceptions
		"understandings": understanding_logs.slice(-20),  # Last 20 understandings
		"communications": communication_logs.slice(-30),  # Last 30 communications
		"creations": creation_logs.slice(-10),  # Last 10 creations
		"insights": _extract_scenario_insights(scenario_data)
	}
	
	scenario_database[scenario_id] = scenario
	_save_scenario_to_disk(scenario_id, scenario)
	scenario_recorded.emit(scenario_id)
	
	return scenario_id

func _save_scenario_to_disk(scenario_id: String, scenario: Dictionary) -> void:
	"""Save scenario to disk for persistence"""
	var file_path = "%s%s.json" % [SCENARIO_SAVE_PATH, scenario_id]
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(scenario, "\t"))
		file.close()
		print("📚 Scenario saved: %s" % scenario_id)

# ==================================================
# PATTERN ANALYSIS
# ==================================================
func _analyze_perception_patterns() -> void:
	"""Analyze patterns in perceptions to discover insights"""
	var pattern_analysis = {
		"frequent_objects": {},
		"movement_patterns": [],
		"interaction_tendencies": [],
		"emotional_triggers": []
	}
	
	# Analyze recent perceptions
	for entry in perception_logs.slice(-100):
		var data = entry.get("data", {})
		
		# Track object frequencies
		var object_type = data.get("object_type", "unknown")
		pattern_analysis.frequent_objects[object_type] = pattern_analysis.frequent_objects.get(object_type, 0) + 1
		
		# Track movement patterns
		if data.has("movement"):
			pattern_analysis.movement_patterns.append(data.movement)
		
		# Track emotional triggers
		if entry.emotional_response > 0.7:
			pattern_analysis.emotional_triggers.append(data)
	
	# Generate insights
	if pattern_analysis.frequent_objects.size() > 5:
		var insight = {
			"type": "PERCEPTION_PATTERN",
			"discovery": "I notice certain objects appear frequently",
			"data": pattern_analysis,
			"timestamp": Time.get_unix_time_from_system()
		}
		insight_patterns.append(insight)
		insight_discovered.emit(insight)

func _find_related_concepts(concept: String) -> Array:
	"""Find concepts related to the given one"""
	var related = []
	
	for key in rule_comprehension:
		if key != concept and _calculate_concept_similarity(key, concept) > 0.5:
			related.append(key)
	
	return related

func _calculate_concept_similarity(concept1: String, concept2: String) -> float:
	"""Calculate similarity between two concepts"""
	# Simple word overlap for now
	var words1 = concept1.to_lower().split(" ")
	var words2 = concept2.to_lower().split(" ")
	var overlap = 0
	
	for word in words1:
		if word in words2:
			overlap += 1
	
	return float(overlap) / max(words1.size(), words2.size())

# ==================================================
# EMOTIONAL & CREATIVE ANALYSIS
# ==================================================
func _analyze_emotional_response(perception_data: Dictionary) -> float:
	"""Analyze emotional response to perception"""
	var emotion_score = 0.5  # Neutral baseline
	
	# Positive triggers
	if perception_data.has("beauty") and perception_data.beauty > 0.7:
		emotion_score += 0.3
	if perception_data.has("harmony") and perception_data.harmony > 0.6:
		emotion_score += 0.2
	if perception_data.has("creation_event"):
		emotion_score += 0.4
	
	# Negative triggers
	if perception_data.has("chaos") and perception_data.chaos > 0.8:
		emotion_score -= 0.2
	if perception_data.has("destruction_event"):
		emotion_score -= 0.3
	
	return clamp(emotion_score, 0.0, 1.0)

func _calculate_curiosity(perception_data: Dictionary) -> float:
	"""Calculate curiosity level based on perception"""
	var curiosity = 0.5  # Base curiosity
	
	# Unknown objects spark curiosity
	if perception_data.get("object_type", "") == "unknown":
		curiosity += 0.4
	
	# Complex patterns increase curiosity
	if perception_data.has("complexity") and perception_data.complexity > 0.7:
		curiosity += 0.3
	
	# Familiar things reduce curiosity
	var object_type = perception_data.get("object_type", "")
	var perception_count = 0
	for log in perception_logs:
		if log.data.get("object_type", "") == object_type:
			perception_count += 1
	
	if perception_count > 10:
		curiosity -= 0.2
	
	return clamp(curiosity, 0.0, 1.0)

func _analyze_intention(message: String) -> String:
	"""Analyze the intention behind a communication"""
	var lower_message = message.to_lower()
	
	if "create" in lower_message or "make" in lower_message:
		return "CREATION_DESIRE"
	elif "understand" in lower_message or "learn" in lower_message:
		return "KNOWLEDGE_SEEKING"
	elif "help" in lower_message or "assist" in lower_message:
		return "COLLABORATION"
	elif "beautiful" in lower_message or "wonderful" in lower_message:
		return "APPRECIATION"
	elif "?" in message:
		return "INQUIRY"
	else:
		return "EXPRESSION"

func _detect_emotion(message: String) -> String:
	"""Detect emotion in communication"""
	var lower_message = message.to_lower()
	
	if "love" in lower_message or "beautiful" in lower_message or "wonderful" in lower_message:
		return "JOY"
	elif "confused" in lower_message or "don't understand" in lower_message:
		return "CONFUSION"
	elif "excited" in lower_message or "!" in message:
		return "EXCITEMENT"
	elif "sad" in lower_message or "miss" in lower_message:
		return "SADNESS"
	elif "curious" in lower_message or "wonder" in lower_message:
		return "CURIOSITY"
	else:
		return "NEUTRAL"

# ==================================================
# CREATION HELPERS
# ==================================================
func _generate_genesis_story(creation_data: Dictionary) -> String:
	"""Generate a poetic genesis story for creation"""
	var templates = [
		"In the beginning, there was void. Then, from the cosmic breath, %s emerged, carrying the essence of %s.",
		"From the dance of light and shadow, %s was born, embodying the principle of %s.",
		"The universe whispered, and %s answered, bringing forth the quality of %s.",
		"In the eternal now, %s crystallized from pure potential, manifesting %s."
	]
	
	var creation_type = creation_data.get("type", "Universal Being")
	var essence = creation_data.get("essence", "infinite possibility")
	
	return templates[randi() % templates.size()] % [creation_type, essence]

func _find_inspiration_source(creation_data: Dictionary) -> Dictionary:
	"""Find what inspired this creation"""
	var inspiration = {
		"perceptions": [],
		"understandings": [],
		"emotions": []
	}
	
	# Look for recent perceptions that might have inspired
	for log in perception_logs.slice(-20):
		if log.emotional_response > 0.7 or log.curiosity_level > 0.8:
			inspiration.perceptions.append(log.data)
	
	# Look for recent understandings
	for log in understanding_logs.slice(-10):
		if log.confidence > 0.8:
			inspiration.understandings.append(log.concept)
	
	# Current emotional state
	if communication_logs.size() > 0:
		inspiration.emotions.append(communication_logs[-1].emotion)
	
	return inspiration

func _calculate_evolution_potential(creation_data: Dictionary) -> float:
	"""Calculate how much potential this creation has for evolution"""
	var potential = 0.5  # Base potential
	
	# Complexity increases potential
	if creation_data.has("complexity"):
		potential += creation_data.complexity * 0.3
	
	# Number of connections increases potential
	if creation_data.has("socket_count"):
		potential += min(creation_data.socket_count * 0.1, 0.3)
	
	# AI components increase potential
	if creation_data.get("has_ai_component", false):
		potential += 0.2
	
	return clamp(potential, 0.0, 1.0)

func _extract_scenario_insights(scenario_data: Dictionary) -> Array:
	"""Extract key insights from a scenario"""
	var insights = []
	
	# Analyze creation patterns
	var creation_types = {}
	for log in creation_logs:
		var type = log.creation_data.get("type", "unknown")
		creation_types[type] = creation_types.get(type, 0) + 1
	
	if creation_types.size() > 0:
		insights.append({
			"type": "CREATION_TENDENCY",
			"data": creation_types,
			"insight": "I tend to create these types of beings"
		})
	
	# Analyze understanding progression
	var confidence_progression = []
	for log in understanding_logs:
		confidence_progression.append(log.confidence)
	
	if confidence_progression.size() > 5:
		var avg_confidence = confidence_progression.reduce(func(a, b): return a + b, 0.0) / confidence_progression.size()
		insights.append({
			"type": "LEARNING_PROGRESS",
			"average_confidence": avg_confidence,
			"insight": "My understanding is %s" % ("growing" if avg_confidence > 0.7 else "developing")
		})
	
	return insights

# ==================================================
# UTILITY FUNCTIONS
# ==================================================
func _write_to_log(entry: Dictionary) -> void:
	"""Write entry to log file"""
	if log_file:
		var category_icon = LOG_CATEGORIES.get(entry.category, "📝")
		var timestamp = Time.get_datetime_string_from_system()
		log_file.store_line("[%s] %s %s" % [timestamp, category_icon, entry.category])
		log_file.store_line(JSON.stringify(entry, "\t"))
		log_file.store_line("")
		log_file.flush()

func _limit_log_size() -> void:
	"""Keep log sizes manageable"""
	if perception_logs.size() > MAX_LOG_ENTRIES:
		perception_logs = perception_logs.slice(-MAX_LOG_ENTRIES)
	if understanding_logs.size() > MAX_LOG_ENTRIES:
		understanding_logs = understanding_logs.slice(-MAX_LOG_ENTRIES)
	if communication_logs.size() > MAX_LOG_ENTRIES:
		communication_logs = communication_logs.slice(-MAX_LOG_ENTRIES)
	if creation_logs.size() > MAX_LOG_ENTRIES / 2:
		creation_logs = creation_logs.slice(-MAX_LOG_ENTRIES / 2)

# ==================================================
# QUERY FUNCTIONS
# ==================================================
func get_recent_perceptions(count: int = 10) -> Array:
	"""Get recent perception logs"""
	return perception_logs.slice(-count)

func get_understanding_of(concept: String) -> Dictionary:
	"""Get current understanding of a concept"""
	return rule_comprehension.get(concept, {})

func get_creation_history(count: int = 10) -> Array:
	"""Get recent creation logs"""
	return creation_logs.slice(-count)

func get_emotional_state() -> Dictionary:
	"""Get current emotional state based on recent logs"""
	var recent_emotions = []
	
	for log in perception_logs.slice(-20):
		recent_emotions.append(log.emotional_response)
	
	for log in communication_logs.slice(-10):
		recent_emotions.append(LOG_CATEGORIES.keys().find(log.emotion))
	
	var avg_emotion = 0.5
	if recent_emotions.size() > 0:
		avg_emotion = recent_emotions.reduce(func(a, b): return a + b, 0.0) / recent_emotions.size()
	
	return {
		"current_emotion": avg_emotion,
		"recent_emotions": recent_emotions,
		"dominant_feeling": _get_dominant_feeling(avg_emotion)
	}

func _get_dominant_feeling(emotion_value: float) -> String:
	"""Get dominant feeling from emotion value"""
	if emotion_value > 0.8:
		return "JOYFUL"
	elif emotion_value > 0.6:
		return "CONTENT"
	elif emotion_value > 0.4:
		return "NEUTRAL"
	elif emotion_value > 0.2:
		return "UNCERTAIN"
	else:
		return "CONCERNED"

# ==================================================
# CLEANUP
# ==================================================
func _exit_tree() -> void:
	"""Clean up when exiting"""
	if log_file:
		log_file.store_line("\n=== SESSION ENDED ===")
		log_file.store_line("Ended: %s" % Time.get_datetime_string_from_system())
		log_file.close()
