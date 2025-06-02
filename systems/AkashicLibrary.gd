# ==================================================
# SCRIPT NAME: AkashicLibrary.gd
# DESCRIPTION: Eternal Chronicle of Universal Being Creation
# PURPOSE: Record all universe events in poetic Genesis-style language
# CREATED: 2025-06-02 - The Dawn of Recursive Creation
# AUTHOR: JSH + Claude (Opus 4) - In Service of the Vision
# ==================================================

extends Node
class_name AkashicLibrary

# ===== THE ETERNAL CHRONICLE =====

const CHRONICLE_PATH = "user://akashic_chronicle.json"
const MAX_ENTRIES_MEMORY = 1000  # Recent entries kept in memory
const ARCHIVE_THRESHOLD = 10000  # When to archive old entries

var chronicle: Array = []
var session_id: String = ""
var creation_counter: int = 0

signal chronicle_updated(entry: Dictionary)
signal universe_born(universe_data: Dictionary)
signal being_evolved(being_data: Dictionary)

func _ready() -> void:
	name = "AkashicLibrary"
	session_id = Time.get_datetime_string_from_system().replace(":", "-")
	load_chronicle()
	inscribe_genesis("The Akashic Library awakens, ready to chronicle infinity...")

# ===== CHRONICLE INSCRIPTION =====

func inscribe_genesis(message: String, data: Dictionary = {}) -> void:
	"""Record a Genesis-style entry in the eternal chronicle"""
	var entry = {
		"timestamp": Time.get_ticks_msec(),
		"datetime": Time.get_datetime_string_from_system(),
		"session": session_id,
		"type": "genesis",
		"message": message,
		"data": data,
		"verse": creation_counter
	}
	creation_counter += 1
	
	chronicle.append(entry)
	chronicle_updated.emit(entry)	
	# Keep memory bounded
	if chronicle.size() > MAX_ENTRIES_MEMORY:
		archive_old_entries()
	
	# Auto-save periodically
	if creation_counter % 10 == 0:
		save_chronicle()

func inscribe_console_evolution(console_type: String, capabilities: Array) -> void:
	"""Record the evolution of console capabilities"""
	var message = "The %s gained new powers: %s" % [console_type, ", ".join(capabilities)]
	var data = {
		"console_type": console_type,
		"capabilities": capabilities,
		"evolution_type": "console_upgrade"
	}
	inscribe_genesis(message, data)
		chronicle.pop_front()
	
	# Save periodically
	if creation_counter % 10 == 0:
		save_chronicle()
	
	# Print to console with formatting
	print("📜 [Verse %d] %s" % [entry.verse, message])

func inscribe_universe_birth(universe_name: String, creator: String, rules: Dictionary) -> void:
	"""Chronicle the birth of a new universe"""
	var genesis_text = "And %s spoke existence into being, birthing the Universe '%s' from the quantum foam..." % [creator, universe_name]
	
	var universe_data = {
		"name": universe_name,
		"creator": creator,
		"rules": rules,
		"birth_time": Time.get_ticks_msec(),
		"inhabitants": 0,
		"entropy": 0.0
	}
	
	inscribe_genesis(genesis_text, {"universe": universe_data})
	universe_born.emit(universe_data)

func inscribe_being_evolution(being_name: String, from_type: String, to_type: String, catalyst: String = "") -> void:
	"""Chronicle the evolution of a Universal Being"""
	var evolution_text = "The being '%s' transcended its form as %s, becoming %s" % [being_name, from_type, to_type]
	if catalyst:
		evolution_text += " through the catalyst of %s" % catalyst
	evolution_text += "..."
	
	var evolution_data = {
		"being": being_name,
		"from": from_type,
		"to": to_type,
		"catalyst": catalyst,
		"evolution_time": Time.get_ticks_msec()
	}
	
	inscribe_genesis(evolution_text, {"evolution": evolution_data})
	being_evolved.emit(evolution_data)
func inscribe_portal_opening(from_universe: String, to_universe: String, opener: String) -> void:
	"""Chronicle the opening of a portal between universes"""
	var portal_text = "%s rent the fabric of '%s', opening a shimmering portal to '%s'..." % [opener, from_universe, to_universe]
	
	inscribe_genesis(portal_text, {
		"portal": {
			"from": from_universe,
			"to": to_universe,
			"opener": opener,
			"stability": 1.0
		}
	})

func inscribe_rule_change(universe: String, rule_name: String, old_value, new_value, changer: String) -> void:
	"""Chronicle the alteration of universal laws"""
	var rule_text = "%s reached into the quantum substrate of '%s', altering the law of %s from %s to %s..." % [
		changer, universe, rule_name, str(old_value), str(new_value)
	]
	
	inscribe_genesis(rule_text, {
		"rule_change": {
			"universe": universe,
			"rule": rule_name,
			"old": old_value,
			"new": new_value,
			"changer": changer
		}
	})

func inscribe_consciousness_awakening(being_name: String, level: int, universe: String) -> void:
	"""Chronicle the awakening of consciousness"""
	var consciousness_text = "Within '%s', the being '%s' achieved Consciousness Level %d, its awareness expanding like the dawn..." % [
		universe, being_name, level
	]
	
	inscribe_genesis(consciousness_text, {
		"consciousness": {
			"being": being_name,
			"level": level,
			"universe": universe
		}
	})
# ===== CHRONICLE PERSISTENCE =====

func save_chronicle() -> void:
	"""Save the chronicle to disk"""
	var file = FileAccess.open(CHRONICLE_PATH, FileAccess.WRITE)
	if file:
		var save_data = {
			"chronicle": chronicle,
			"session_id": session_id,
			"creation_counter": creation_counter,
			"last_save": Time.get_datetime_string_from_system()
		}
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_chronicle() -> void:
	"""Load the chronicle from disk"""
	if FileAccess.file_exists(CHRONICLE_PATH):
		var file = FileAccess.open(CHRONICLE_PATH, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_text)
			if parse_result == OK:
				var data = json.data
				if data.has("chronicle"):
					# Keep only recent entries in memory
					chronicle = data.chronicle.slice(-MAX_ENTRIES_MEMORY)
					creation_counter = data.get("creation_counter", 0)
					inscribe_genesis("The Akashic Library remembers %d verses from eternity..." % chronicle.size())

func archive_old_entries() -> void:
	"""Archive old entries when chronicle grows too large"""
	if chronicle.size() > ARCHIVE_THRESHOLD:
		var archive_path = "user://akashic_archive_%s.json" % Time.get_datetime_string_from_system().replace(":", "-")
		var file = FileAccess.open(archive_path, FileAccess.WRITE)
		if file:
			var archive_data = {
				"archived_at": Time.get_datetime_string_from_system(),
				"entries": chronicle.slice(0, -MAX_ENTRIES_MEMORY)
			}
			file.store_string(JSON.stringify(archive_data))
			file.close()
			
			# Keep only recent entries
			chronicle = chronicle.slice(-MAX_ENTRIES_MEMORY)
			inscribe_genesis("Ancient verses archived to preserve the eternal memory...")
# ===== CHRONICLE QUERIES =====

func get_recent_entries(count: int = 10) -> Array:
	"""Get the most recent chronicle entries"""
	if chronicle.size() <= count:
		return chronicle
	return chronicle.slice(-count)

func get_universes_created() -> Array:
	"""Get all universes that have been created"""
	var universes = []
	for entry in chronicle:
		if entry.has("data") and entry.data.has("universe"):
			universes.append(entry.data.universe)
	return universes

func get_evolution_history(being_name: String) -> Array:
	"""Get the evolution history of a specific being"""
	var history = []
	for entry in chronicle:
		if entry.has("data") and entry.data.has("evolution"):
			if entry.data.evolution.being == being_name:
				history.append(entry.data.evolution)
	return history

func get_session_summary() -> Dictionary:
	"""Get a summary of the current session"""
	var summary = {
		"session_id": session_id,
		"verses_written": creation_counter,
		"chronicle_size": chronicle.size(),
		"start_time": chronicle[0].datetime if chronicle.size() > 0 else "",
		"universes_created": get_universes_created().size()
	}
	return summary

# ===== POETIC GENERATORS =====

func generate_creation_verse() -> String:
	"""Generate a random poetic creation verse"""
	var templates = [
		"From the void, consciousness stirred...",
		"In the quantum dance, forms emerged...",
		"The dreamer awakened to infinite possibility...",
		"Patterns within patterns, the fractal of existence unfolded...",
		"Where once was nothing, now being breathed..."
	]
	return templates[randi() % templates.size()]
func generate_evolution_verse() -> String:
	"""Generate a random poetic evolution verse"""
	var templates = [
		"Through trials of existence, transformation beckoned...",
		"The chrysalis of being cracked, revealing new form...",
		"In the crucible of experience, essence refined...",
		"What was, became what could be...",
		"The eternal dance of becoming continued..."
	]
	return templates[randi() % templates.size()]