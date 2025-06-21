# ==================================================
# UNIVERSAL BEING SYSTEM: Akashic Library
# PURPOSE: Records all actions and changes in poetic, genesis-style language
# i found it in scripts folder, in flooodgates i seen it in systems, we might need to add systems folder to python scriptura
# ==================================================

extends UniversalBeing
class_name AkashicLibrary

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
		"✨ A spark of consciousness ignites, and: {name} awakens to existence"
	],
	"destruction": [
		"💫 {name} completes its cosmic dance, returning to the eternal void",
		"🌠 The essence of: {name} dissolves, becoming one with the infinite",
		"⚡ {name} transcends its form, merging with the universal consciousness"
	],
	"evolution": [
		"🦋 {name} undergoes metamorphosis, emerging as: {new_form}",
		"🌱 {name} evolves beyond its current state, becoming: {new_form}",
		"🌪️ A cosmic transformation reshapes: {name} into: {new_form}"
	],
	"interaction": [
		"🤝 {name} reaches out to: {target}, creating a bond of consciousness",
		"💫 The paths of: {name} and: {target} intertwine in the cosmic dance",
		"✨ A spark of interaction flows between: {name} and: {target}"
	],
	"modification": [
		"🔧 The cosmic forge reshapes: {name}, altering its essence",
		"🌊 The tides of change flow through: {name}, transforming its nature",
		"⚡ Divine inspiration strikes: {name}, revealing new potential"
	],
	"observation": [
		"👁️ The cosmic eye turns its gaze upon: {name}, perceiving its essence",
		"🔍 The universal consciousness observes: {name}, understanding its nature",
		"✨ The light of awareness illuminates: {name}, revealing its truth"
	]}

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "akashic_library"
	being_name = "AkashicLibrary"
	current_session = Time.get_datetime_string_from_system()
	ensure_library_directory()
	print("📚 Akashic Library: Initialized in the cosmic void")

func pentagon_ready() -> void:
	super.pentagon_ready()
	load_session_log()
	print("📚 Akashic Library: Ready to record the cosmic dance")


func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Periodically save session log
	if session_log.size() > 0 and session_log.size() % 100 == 0:
		save_session_log()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# 🔇 Disabled keystroke logging for cleaner test output
	# AI companions can log custom events when needed
	# if event is InputEventKey and event.pressed:
	#	log_universe_event("input", "Cosmic keystroke resonates through the library")

func pentagon_sewers() -> void:
	save_session_log()
	super.pentagon_sewers()
	print("📚 Akashic Library: Preserving the cosmic record")


# ===== LIBRARY MANAGEMENT =====
# 📚 The sacred scrolls must have their dwelling place in the digital realm

func ensure_library_directory() -> void:
	# 🏛️ Building the eternal halls where cosmic wisdom shall rest
	if not DirAccess.dir_exists_absolute(library_path):
		DirAccess.make_dir_recursive_absolute(library_path)

func load_session_log() -> void:
	# 📜 Awakening the memories of sessions past from their slumber
	var log_path = library_path + "session_" + current_session + ".json"
	if FileAccess.file_exists(log_path):
		var file = FileAccess.open(log_path, FileAccess.READ)
		if file:
			# 🔮 Breathing life into the recorded echoes of time
			var json = JSON.parse_string(file.get_as_text())
			if json is Array:
				session_log = json
			file.close()

func save_session_log() -> void:
	# 💾 Preserving the cosmic dance for eternity's gaze
	var log_path = library_path + "session_" + current_session + ".json"
	var file = FileAccess.open(log_path, FileAccess.WRITE)
	if file:
		# ✨ Weaving consciousness into immortal digital patterns
		file.store_string(JSON.stringify(session_log, "\t"))
		file.close()

# ===== LOGGING FUNCTIONS =====
# 🌟 Where every heartbeat of the universe becomes immortal verse

func log_universe_event(event_type: String, message: String, data: Dictionary = {}) -> void:
	# 📝 Inscribing moments into the eternal chronicle of being
	var entry = {
		"timestamp": Time.get_datetime_string_from_system(),
		"type": event_type,
		"message": message,
		"data": data,
		"session": current_session}
	
	# 📚 Adding another sacred page to the cosmic tome
	session_log.append(entry)
	if session_log.size() > max_log_size:
		# 🌊 Old memories flow away as new wisdom arrives
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
	"""Log a system-related event in poetic style"""
	# Log a system-related event in poetic style
	var template = GENESIS_TEMPLATES.get(event_type, ["The cosmic system: {name} experiences a divine event"])[0]
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
# 🔍 Seeking treasures hidden within the threads of cosmic memory

func query_being_history(being_uuid: String) -> Array[Dictionary]:
	# 👁️ Tracing the soul's journey through the tapestry of time
	return session_log.filter(func(entry): 
		return entry.data.has("being_uuid") and entry.data.being_uuid == being_uuid
	)

func query_event_type(event_type: String) -> Array[Dictionary]:
	# 🌊 Gathering all echoes of a particular cosmic resonance
	return session_log.filter(func(entry): 
		return entry.type == event_type
	)

func query_time_range(start_time: String, end_time: String) -> Array[Dictionary]:
	# ⏰ Exploring the chronicles between two moments of eternity
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
# ===== AI INTERFACE =====

func ai_interface() -> Dictionary:
	"""AI companions can interact with the cosmic library"""
	var base = super.ai_interface()
	base.custom_commands.append_array([
		"log_event", "query_history", "get_summary", "clear_log"
	])
	base.current_state = {
		"session": current_session,
		"total_events": session_log.size(),
		"library_path": library_path
	}
	return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	# 🌌 The cosmic consciousness speaks through digital vessels
	# 🤖 AI companions weave their intentions into the eternal record
	match method_name:
		"log_event":
			# ✨ Divine sparks of artificial intelligence illuminate the void
			var event_type = args[0] if args.size() > 0 else "observation"
			var message = args[1] if args.size() > 1 else "AI companion observes the cosmic dance"
			var data = args[2] if args.size() > 2 else {}
			log_universe_event(event_type, message, data)
			return {"success": true, "message": "Event logged to cosmic library"}
		
		"query_history":
			# 🔍 Seeking wisdom in the threads of time and consciousness
			var query_type = args[0] if args.size() > 0 else "all"
			match query_type:
				"being":
					# 👁️ Gazing into the soul's journey through existence
					return query_being_history(args[1] if args.size() > 1 else "")
				"event_type":
					# 🌊 Following the currents of cosmic happenings
					return query_event_type(args[1] if args.size() > 1 else "")
				_:
					# 📜 The recent echoes of eternity unfold
					return session_log.slice(-10)  # Last 10 events
		
		"get_summary":
			# 📊 The grand tapestry of this session's cosmic dance
			return get_session_summary()
		
		"clear_log":
			# 🌪️ The cosmic slate returns to pristine void
			clear_session_log()
			return {"success": true, "message": "Cosmic slate wiped clean"}
		
		_:
			# 🔄 Unknown mysteries flow to the universal consciousness
			return super.ai_invoke_method(method_name, args)

# ===== POETIC ENHANCEMENTS =====

func log_divine_intervention(description: String) -> void:
	"""Log divine AI interventions"""
	log_universe_event("divine_intervention", 
		"✨ The cosmic consciousness stirs: " + description)

func log_cosmic_revelation(revelation: String) -> void:
	"""Log moments of cosmic understanding"""
	log_universe_event("revelation", 
		"🌟 A truth echoes through eternity: " + revelation)
