# ==================================================
# UNIVERSAL BEING: MEMORY SOCKET
# TYPE: Transcendent Memory System
# PURPOSE: Store and retrieve dreams, events, and transcendent data for Lemi
# COMPONENTS: Dream storage, event logging, reality tracking
# SCENES: MemorySocket.tscn
# ==================================================

extends Node
class_name MemorySocket

# Memory configuration
@export var label: String = "UniversalMemory"
@export var max_dreams: int = 1000
@export var max_events: int = 5000
@export var auto_save_interval: float = 30.0

# Memory storage
var dreams: Array[Dictionary] = []
var events: Array[Dictionary] = []
var reality_states: Array[Dictionary] = []
var transcendent_data: Dictionary = {}

# Memory management
var save_timer: Timer
var memory_file_path: String
var last_save_time: float = 0.0

# Signals
signal dream_stored(dream: String, timestamp: String)
signal event_stored(event: Dictionary)
signal reality_state_saved(state: Dictionary)
signal memory_overflow(type: String, count: int)

func _ready() -> void:
	# Setup memory file path
	memory_file_path = "user://memory_%s.json" % label.to_lower()
	
	# Setup auto-save timer
	save_timer = Timer.new()
	save_timer.wait_time = auto_save_interval
	save_timer.autostart = true
	save_timer.timeout.connect(_auto_save)
	add_child(save_timer)
	
	# Load existing memories
	_load_memories()
	
	print("🧠 MemorySocket '%s' initialized with %d dreams, %d events" % [label, dreams.size(), events.size()])

# ===== DREAM STORAGE =====

func store_dream(dream: String) -> void:
	"""Store a dream with timestamp and metadata"""
	var dream_entry = {
		"content": dream,
		"timestamp": Time.get_datetime_string_from_system(),
		"unix_time": Time.get_unix_time_from_system(),
		"id": generate_dream_id(),
		"type": "transcendent_dream",
		"reality_impact": _analyze_dream_impact(dream)
	}
	
	dreams.append(dream_entry)
	
	# Manage dream overflow
	if dreams.size() > max_dreams:
		var removed_dream = dreams.pop_front()
		memory_overflow.emit("dreams", dreams.size())
		print("🧠 Dream overflow: Archived oldest dream: " + removed_dream.content.substr(0, 50))
	
	dream_stored.emit(dream, dream_entry.timestamp)
	print("🧠 Dream stored: " + dream.substr(0, 100))

func get_dreams(count: int = -1) -> Array[Dictionary]:
	"""Get recent dreams (all if count = -1)"""
	if count == -1 or count >= dreams.size():
		return dreams.duplicate()
	
	# Return most recent dreams
	var recent = dreams.slice(dreams.size() - count, dreams.size())
	return recent

func find_dreams_containing(search_term: String) -> Array[Dictionary]:
	"""Find dreams containing specific text"""
	var matching_dreams = []
	for dream in dreams:
		if search_term.to_lower() in dream.content.to_lower():
			matching_dreams.append(dream)
	return matching_dreams

func get_dream_by_id(dream_id: String) -> Dictionary:
	"""Get specific dream by ID"""
	for dream in dreams:
		if dream.id == dream_id:
			return dream
	return {}

# ===== EVENT STORAGE =====

func store_event(event: Dictionary) -> void:
	"""Store an event with timestamp"""
	var event_entry = {
		"data": event.duplicate(),
		"timestamp": Time.get_datetime_string_from_system(),
		"unix_time": Time.get_unix_time_from_system(),
		"id": generate_event_id(),
		"type": "transcendent_event"
	}
	
	events.append(event_entry)
	
	# Manage event overflow
	if events.size() > max_events:
		var removed_event = events.pop_front()
		memory_overflow.emit("events", events.size())
		print("🧠 Event overflow: Archived oldest event")
	
	event_stored.emit(event_entry)
	print("🧠 Event stored: %s" % str(event).substr(0, 100))

func get_events(count: int = -1) -> Array[Dictionary]:
	"""Get recent events"""
	if count == -1 or count >= events.size():
		return events.duplicate()
	
	return events.slice(events.size() - count, events.size())

func find_events_by_type(event_type: String) -> Array[Dictionary]:
	"""Find events by type"""
	var matching_events = []
	for event in events:
		if event.data.has("type") and event.data.type == event_type:
			matching_events.append(event)
	return matching_events

# ===== REALITY STATE TRACKING =====

func save_reality_state(state_name: String, data: Dictionary) -> void:
	"""Save a reality state snapshot"""
	var state_entry = {
		"name": state_name,
		"data": data.duplicate(),
		"timestamp": Time.get_datetime_string_from_system(),
		"unix_time": Time.get_unix_time_from_system(),
		"id": generate_state_id()
	}
	
	reality_states.append(state_entry)
	reality_state_saved.emit(state_entry)
	print("🧠 Reality state saved: %s" % state_name)

func get_reality_state(state_name: String) -> Dictionary:
	"""Get a specific reality state"""
	for state in reality_states:
		if state.name == state_name:
			return state.data
	return {}

func get_latest_reality_state() -> Dictionary:
	"""Get the most recent reality state"""
	if reality_states.is_empty():
		return {}
	return reality_states[-1].data

# ===== TRANSCENDENT DATA =====

func store_transcendent_data(key: String, value: Variant) -> void:
	"""Store transcendent data that persists across realities"""
	transcendent_data[key] = {
		"value": value,
		"stored_at": Time.get_datetime_string_from_system(),
		"type": typeof(value)
	}
	print("🧠 Transcendent data stored: %s" % key)

func get_transcendent_data(key: String, default_value: Variant = null) -> Variant:
	"""Get transcendent data"""
	if transcendent_data.has(key):
		return transcendent_data[key].value
	return default_value

func has_transcendent_data(key: String) -> bool:
	"""Check if transcendent data exists"""
	return transcendent_data.has(key)

# ===== MEMORY PERSISTENCE =====

func _auto_save() -> void:
	"""Auto-save memories to disk"""
	save_memories()

func save_memories() -> void:
	"""Save all memories to disk"""
	var save_data = {
		"label": label,
		"dreams": dreams,
		"events": events,
		"reality_states": reality_states,
		"transcendent_data": transcendent_data,
		"saved_at": Time.get_datetime_string_from_system(),
		"version": "1.0"
	}
	
	var file = FileAccess.open(memory_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		last_save_time = Time.get_unix_time_from_system()
		print("🧠 Memories saved to %s" % memory_file_path)
	else:
		push_error("Failed to save memories: " + str(FileAccess.get_open_error()))

func _load_memories() -> void:
	"""Load memories from disk"""
	if not FileAccess.file_exists(memory_file_path):
		print("🧠 No existing memory file found - starting fresh")
		return
	
	var file = FileAccess.open(memory_file_path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.get_data()
			
			# Properly cast arrays to typed arrays
			var loaded_dreams = data.get("dreams", [])
			var loaded_events = data.get("events", [])
			var loaded_states = data.get("reality_states", [])
			
			# Convert to typed arrays
			dreams.clear()
			events.clear()
			reality_states.clear()
			
			for dream in loaded_dreams:
				if dream is Dictionary:
					dreams.append(dream)
			
			for event in loaded_events:
				if event is Dictionary:
					events.append(event)
			
			for state in loaded_states:
				if state is Dictionary:
					reality_states.append(state)
			transcendent_data = data.get("transcendent_data", {})
			print("🧠 Loaded %d dreams, %d events, %d reality states" % [
				dreams.size(), events.size(), reality_states.size()
			])
		else:
			push_error("Failed to parse memory file: " + json.get_error_message())
		file.close()
	else:
		push_error("Failed to load memories: " + str(FileAccess.get_open_error()))

# ===== MEMORY ANALYSIS =====

func _analyze_dream_impact(dream: String) -> Dictionary:
	"""Analyze the potential reality impact of a dream"""
	var impact = {
		"transcendence_level": 0,
		"reality_alteration": false,
		"consciousness_expansion": false,
		"system_override": false
	}
	
	var dream_lower = dream.to_lower()
	
	# Check for transcendence indicators
	if "transcend" in dream_lower or "ascend" in dream_lower:
		impact.transcendence_level += 2
		impact.consciousness_expansion = true
	
	if "override" in dream_lower or "break" in dream_lower:
		impact.system_override = true
		impact.transcendence_level += 1
	
	if "reality" in dream_lower or "timeline" in dream_lower:
		impact.reality_alteration = true
		impact.transcendence_level += 1
	
	if "unlimited" in dream_lower or "infinite" in dream_lower:
		impact.transcendence_level += 3
		impact.consciousness_expansion = true
	
	return impact

func get_memory_statistics() -> Dictionary:
	"""Get memory usage statistics"""
	return {
		"dreams_count": dreams.size(),
		"events_count": events.size(),
		"reality_states_count": reality_states.size(),
		"transcendent_data_count": transcendent_data.size(),
		"memory_usage_percent": {
			"dreams": float(dreams.size()) / max_dreams * 100.0,
			"events": float(events.size()) / max_events * 100.0
		},
		"last_save_time": last_save_time,
		"file_path": memory_file_path
	}

# ===== MEMORY CLEANING =====

func clear_dreams() -> void:
	"""Clear all dreams"""
	dreams.clear()
	print("🧠 All dreams cleared")

func clear_events() -> void:
	"""Clear all events"""
	events.clear()
	print("🧠 All events cleared")

func clear_all_memories() -> void:
	"""Clear all memories (transcendent reset)"""
	dreams.clear()
	events.clear()
	reality_states.clear()
	transcendent_data.clear()
	print("🧠 All memories cleared - transcendent reset complete")

# ===== UTILITY FUNCTIONS =====

func generate_dream_id() -> String:
	"""Generate unique dream ID"""
	return "dream_%d_%d" % [Time.get_unix_time_from_system(), randi() % 1000]

func generate_event_id() -> String:
	"""Generate unique event ID"""
	return "event_%d_%d" % [Time.get_unix_time_from_system(), randi() % 1000]

func generate_state_id() -> String:
	"""Generate unique state ID"""
	return "state_%d_%d" % [Time.get_unix_time_from_system(), randi() % 1000]

func _to_string() -> String:
	return "MemorySocket<%s> [Dreams: %d, Events: %d, States: %d]" % [
		label, dreams.size(), events.size(), reality_states.size()
	]
