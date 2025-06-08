# ==================================================
# UNIVERSAL BEING SYSTEM: Akashic Library
# PURPOSE: Records all actions and changes in poetic, genesis-style language
# i found it in scripts folder, in flooodgates i seen it in systems, we might need to add systems folder to python scriptura
# ==================================================

extends UniversalBeing
class_name AkashicLibrary # Commented to avoid duplicate

# Library state
var library_path: String = "res://akashic_library/"
var current_session: String = ""
var session_log: Array[Dictionary] = []
var max_log_size: int = 10000

# Genesis-style templates
const GENESIS_TEMPLATES = {
	"creation": [
		"🌟 In the great void, {name} emerges, birthing infinite possibilities",
		"🌌 From the cosmic forge, {name} takes form, a new being in the eternal dance",
		"✨ A spark of consciousness ignites, and {name} awakens to existence"
	],
	"destruction": [
		"💫 {name} completes its cosmic dance, returning to the eternal void",
		"🌠 The essence of {name} dissolves, becoming one with the infinite",
		"⚡ {name} transcends its form, merging with the universal consciousness"
	],
	"evolution": [
		"🦋 {name} undergoes metamorphosis, emerging as {new_form}",
		"🌱 {name} evolves beyond its current state, becoming {new_form}",
		"🌪️ A cosmic transformation reshapes {name} into {new_form}"
	],
	"interaction": [
		"🤝 {name} reaches out to {target}, creating a bond of consciousness",
		"💫 The paths of {name} and {target} intertwine in the cosmic dance",
		"✨ A spark of interaction flows between {name} and {target}"
	],
	"modification": [
		"🔧 The cosmic forge reshapes {name}, altering its essence",
		"🌊 The tides of change flow through {name}, transforming its nature",
		"⚡ Divine inspiration strikes {name}, revealing new potential"
	],
	"observation": [
		"👁️ The cosmic eye turns its gaze upon {name}, perceiving its essence",
		"🔍 The universal consciousness observes {name}, understanding its nature",
		"✨ The light of awareness illuminates {name}, revealing its truth"
	]
}

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	name = "AkashicLibrary"
	current_session = Time.get_datetime_string_from_system()
	ensure_library_directory()
	print("📚 Akashic Library: Initialized in the cosmic void")

func pentagon_ready() -> void:
	load_session_log()
	print("📚 Akashic Library: Ready to record the cosmic dance")

func pentagon_process(delta: float) -> void:
	# Periodically save session log
	if session_log.size() > 0 and session_log.size() % 100 == 0:
		save_session_log()

func pentagon_input(event: InputEvent) -> void:
	pass

func pentagon_sewers() -> void:
	save_session_log()
	print("📚 Akashic Library: Preserving the cosmic record")

# ===== LIBRARY MANAGEMENT =====

func ensure_library_directory() -> void:
	"""Ensure the library directory exists"""
	if not DirAccess.dir_exists_absolute(library_path):
		DirAccess.make_dir_recursive_absolute(library_path)

func load_session_log() -> void:
	"""Load the current session log"""
	var log_path = library_path + "session_" + current_session + ".json"
	if FileAccess.file_exists(log_path):
		var file = FileAccess.open(log_path, FileAccess.READ)
		if file:
			var json = JSON.parse_string(file.get_as_text())
			if json is Array:
				session_log = json
			file.close()

func save_session_log() -> void:
	"""Save the current session log"""
	var log_path = library_path + "session_" + current_session + ".json"
	var file = FileAccess.open(log_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(session_log, "\t"))
		file.close()

# ===== LOGGING FUNCTIONS =====

func log_universe_event(event_type: String, message: String, data: Dictionary = {}) -> void:
	"""Log a universe-related event in poetic style"""
	var entry = {
		"timestamp": Time.get_datetime_string_from_system(),
		"type": event_type,
		"message": message,
		"data": data,
		"session": current_session
	}
	
	session_log.append(entry)
	if session_log.size() > max_log_size:
		session_log.pop_front()
	
	print("📚 " + message)

func log_being_event(being: UniversalBeing, event_type: String, data: Dictionary = {}) -> void:
	"""Log a being-related event in poetic style"""
	var template = GENESIS_TEMPLATES.get(event_type, ["{name} experiences a cosmic event"])[0]
	var message = template.format({
		"name": being.being_name,
		"new_form": data.get("new_form", "a new form"),
		"target": data.get("target", "another being")
	})
	
	log_universe_event(event_type, message, {
		"being_uuid": being.being_uuid,
		"being_type": being.being_type,
		"consciousness_level": being.consciousness_level,
		"event_data": data
	})

func log_system_event(system_name: String, event_type: String, data: Dictionary = {}) -> void:
	pass
	# Log a system-related event in poetic style
	var template = GENESIS_TEMPLATES.get(event_type, ["The cosmic system {name} experiences a divine event"])[0]
	var message = template.format({
		"name": system_name,
		"new_form": data.get("new_form", "a new state"),
		"target": data.get("target", "the universal consciousness")
	})
	
	log_universe_event(event_type, message, {
		"system": system_name,
		"event_data": data
	})

# ===== QUERY FUNCTIONS =====

func query_being_history(being_uuid: String) -> Array[Dictionary]:
	"""Query the history of a specific being"""
	return session_log.filter(func(entry): 
		return entry.data.has("being_uuid") and entry.data.being_uuid == being_uuid
	)

func query_event_type(event_type: String) -> Array[Dictionary]:
	"""Query events of a specific type"""
	return session_log.filter(func(entry): 
		return entry.type == event_type
	)

func query_time_range(start_time: String, end_time: String) -> Array[Dictionary]:
	"""Query events within a time range"""
	return session_log.filter(func(entry):
		return entry.timestamp >= start_time and entry.timestamp <= end_time
	)

# ===== UTILITY FUNCTIONS =====

func get_session_summary() -> Dictionary:
	"""Get a summary of the current session"""
	var event_counts = {}
	for entry in session_log:
		event_counts[entry.type] = event_counts.get(entry.type, 0) + 1
	
	return {
		"session": current_session,
		"total_events": session_log.size(),
		"event_types": event_counts,
		"start_time": session_log[0].timestamp if session_log.size() > 0 else "",
		"end_time": session_log[-1].timestamp if session_log.size() > 0 else ""
	}

func clear_session_log() -> void:
	"""Clear the current session log"""
	session_log.clear()
	print("📚 Akashic Library: The cosmic slate is wiped clean")
