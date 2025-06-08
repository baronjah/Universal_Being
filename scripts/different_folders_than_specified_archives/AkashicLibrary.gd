# ==================================================
# AKASHIC LIBRARY - The Eternal Chronicle
# PURPOSE: Persistent storage of all universal events
# LOCATION: core/systems/AkashicLibrary.gd  
# ==================================================

extends Node
class_name AkashicLibrarySystem

## Chronicle configuration
const SAVE_PATH = "user://akashic_chronicle.json"
const MAX_ENTRIES_IN_MEMORY = 10000
const AUTOSAVE_INTERVAL = 60.0 # seconds

## Chronicle data
var chronicle: Array[Dictionary] = []
var session_id: String
var autosave_timer: Timer

signal entry_recorded(entry: Dictionary)
signal chronicle_saved()
signal chronicle_loaded()

func _ready() -> void:
	session_id = _generate_session_id()
	_load_chronicle()
	_setup_autosave()
	
	# Log library initialization
	record_event({
		"type": "system",
		"verse": "The Akashic Library opens its eternal pages",
		"metadata": {"session_id": session_id}
	})

## PUBLIC INTERFACE ==================================================

func record_event(entry: Dictionary) -> void:
	"""Record an event in the eternal chronicle"""
	# Ensure required fields
	if not entry.has("timestamp"):
		entry.timestamp = Time.get_unix_time_from_system()
	if not entry.has("session_id"):
		entry.session_id = session_id
	
	# Add to chronicle
	chronicle.append(entry)
	entry_recorded.emit(entry)
	
	# Manage memory
	if chronicle.size() > MAX_ENTRIES_IN_MEMORY:
		_archive_old_entries()

func query_chronicle(filters: Dictionary = {}) -> Array[Dictionary]:
	"""Query the chronicle with filters"""
	var results: Array[Dictionary] = []
	
	for entry in chronicle:
		if _matches_filters(entry, filters):
			results.append(entry)
	
	return results

func get_universe_history(universe_id: String) -> Array[Dictionary]:
	"""Get all events related to a specific universe"""
	return query_chronicle({
		"metadata.universe_id": universe_id
	})

func get_being_history(being_name: String) -> Array[Dictionary]:
	"""Get all events related to a specific being"""
	return query_chronicle({
		"$or": [
			{"metadata.being": being_name},
			{"metadata.target": being_name},
			{"verse": {"$contains": being_name}}
		]
	})

func get_session_events(session_id: String = "") -> Array[Dictionary]:
	"""Get all events from a specific session"""
	if session_id == "":
		session_id = self.session_id
	
	return query_chronicle({"session_id": session_id})
## PERSISTENCE ==================================================

func save_chronicle() -> void:
	"""Save chronicle to disk"""
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Failed to open chronicle file for writing")
		return
	
	var save_data = {
		"version": "1.0",
		"last_saved": Time.get_unix_time_from_system(),
		"entries": chronicle
	}
	
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	
	chronicle_saved.emit()
	
	# Log the save
	record_event({
		"type": "system",
		"verse": "The chronicle is inscribed upon the eternal tablets",
		"metadata": {"entries_saved": chronicle.size()}
	})

func _load_chronicle() -> void:
	"""Load chronicle from disk"""
	if not FileAccess.file_exists(SAVE_PATH):
		# First time - create new chronicle
		chronicle.clear()
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open chronicle file for reading")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse chronicle: " + json.get_error_message())
		return
	
	var save_data = json.data
	if save_data.has("entries"):
		chronicle = save_data.entries
		chronicle_loaded.emit()

## CHRONICLE ANALYSIS ==================================================

func generate_summary(time_range: Dictionary = {}) -> String:
	"""Generate a poetic summary of events"""
	var events = query_chronicle(time_range)
	
	var summary = "=== Chronicle Summary ===\n\n"
	
	# Count event types
	var type_counts = {}
	for event in events:
		var type = event.get("type", "unknown")
		type_counts[type] = type_counts.get(type, 0) + 1
	
	# Generate summary verses
	for type in type_counts:
		var count = type_counts[type]
		summary += _generate_summary_verse(type, count) + "\n"
	
	summary += "\n" + str(events.size()) + " events recorded in the eternal chronicle."
	
	return summary

func get_creation_genealogy() -> Dictionary:
	"""Build a tree of what created what"""
	var genealogy = {}
	
	var creation_events = query_chronicle({"type": "creation"})
	for event in creation_events:
		var creator = event.metadata.get("creator", "Unknown")
		var created = event.metadata.get("what", "Unknown")
		
		if not genealogy.has(creator):
			genealogy[creator] = []
		genealogy[creator].append(created)
	
	return genealogy

## HELPER FUNCTIONS ==================================================

func _setup_autosave() -> void:
	"""Setup automatic chronicle saving"""
	autosave_timer = Timer.new()
	autosave_timer.wait_time = AUTOSAVE_INTERVAL
	autosave_timer.timeout.connect(save_chronicle)
	add_child(autosave_timer)
	autosave_timer.start()

func _archive_old_entries() -> void:
	"""Archive old entries to reduce memory usage"""
	# For now, just remove oldest entries
	# In future, could write to separate archive files
	var to_remove = chronicle.size() - MAX_ENTRIES_IN_MEMORY
	for i in range(to_remove):
		chronicle.pop_front()

func _matches_filters(entry: Dictionary, filters: Dictionary) -> bool:
	"""Check if entry matches all filters"""
	for key in filters:
		var filter_value = filters[key]
		
		# Handle special operators
		if key == "$or":
			var any_match = false
			for sub_filter in filter_value:
				if _matches_filters(entry, sub_filter):
					any_match = true
					break
			if not any_match:
				return false
			continue
		
		# Handle nested keys (e.g., "metadata.universe_id")
		var entry_value = _get_nested_value(entry, key)
		
		# Handle contains operator
		if filter_value is Dictionary and filter_value.has("$contains"):
			var search_str = filter_value["$contains"]
			if not (entry_value is String and search_str in entry_value):
				return false
		else:
			# Direct comparison
			if entry_value != filter_value:
				return false
	
	return true

func _get_nested_value(dict: Dictionary, key_path: String) -> Variant:
	"""Get value from nested dictionary using dot notation"""
	var keys = key_path.split(".")
	var current = dict
	
	for key in keys:
		if current is Dictionary and current.has(key):
			current = current[key]
		else:
			return null
	
	return current

func _generate_session_id() -> String:
	"""Generate unique session identifier"""
	return "session_" + str(Time.get_unix_time_from_system()) + "_" + str(randi())

func _generate_summary_verse(event_type: String, count: int) -> String:
	"""Generate a summary verse for event type"""
	match event_type:
		"creation":
			return "%d acts of creation brought new forms into being" % count
		"evolution":
			return "%d transformations reshaped the nature of existence" % count
		"connection":
			return "%d bonds were forged between entities" % count
		"reality_change":
			return "%d times the laws of reality bent to new will" % count
		"command":
			return "%d commands echoed through the void" % count
		_:
			return "%d %s events rippled through existence" % [count, event_type]

## CLEANUP ==================================================

func _exit_tree() -> void:
	"""Save chronicle on exit"""
	save_chronicle()
