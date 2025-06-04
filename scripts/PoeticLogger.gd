# ==================================================
# POETIC LOGGER - The Voice of Creation
# PURPOSE: Transform all actions into genesis-inspired verse
# LOCATION: core/systems/PoeticLogger.gd
# ==================================================

extends Node
class_name PoeticLogger

## Genesis verse templates
const CREATION_VERSES = [
	"And from the void came {what}, born of {origin}",
	"In the beginning was {action}, and {action} became {result}",
	"The Universal Being spoke: 'Let there be {what}', and it was so",
	"From the depths of possibility emerged {what}, {how}",
	"And {who} breathed life into {what}, and it became {result}"
]

const EVOLUTION_VERSES = [
	"And {being} transformed, shedding {old} to become {new}",
	"The chrysalis opened, and where once was {old}, now stood {new}",
	"Through the crucible of change, {being} evolved into {new}",
	"And {being} heard the call to become, and answered as {new}"
]

const CONNECTION_VERSES = [
	"And {first} reached out to {second}, and they became one",
	"A bridge of light formed between {first} and {second}",
	"The cosmic threads entwined {first} with {second}",
	"And {first} recognized {second}, and they were connected"
]

const REALITY_VERSES = [
	"And the laws of {aspect} bent to the will of {who}",
	"Reality itself shifted as {what} became {how}",
	"The fabric of existence rippled: {what} was now {how}",
	"And {who} spoke new laws into being: {what} shall be {how}"
]

## Chronicle state
var chronicle_entries: Array[Dictionary] = []
var current_session_start: float

signal verse_written(verse: String, context: Dictionary)

func _ready() -> void:
	current_session_start = Time.get_unix_time_from_system()
	log_genesis("The Universal Being awakens to a new session of creation")

## PUBLIC INTERFACE ==================================================

func log_creation(what: String, origin: String = "the void", metadata: Dictionary = {}) -> void:
	"""Log a creation event in poetic form"""
	var verse = CREATION_VERSES.pick_random()
	var formatted = verse.format({
		"what": what,
		"origin": origin,
		"action": "creation",
		"result": what + " manifest",
		"who": metadata.get("creator", "the Universal Being"),
		"how": metadata.get("method", "with intention")
	})
	
	_write_to_chronicle(formatted, "creation", metadata)

func log_evolution(being_name: String, old_form: String, new_form: String, metadata: Dictionary = {}) -> void:
	"""Log an evolution event"""
	var verse = EVOLUTION_VERSES.pick_random()
	var formatted = verse.format({
		"being": being_name,
		"old": old_form,
		"new": new_form
	})
	
	_write_to_chronicle(formatted, "evolution", metadata)
func log_connection(first: String, second: String, connection_type: String = "essence", metadata: Dictionary = {}) -> void:
	"""Log a connection event"""
	var verse = CONNECTION_VERSES.pick_random()
	var formatted = verse.format({
		"first": first,
		"second": second
	})
	
	metadata["connection_type"] = connection_type
	_write_to_chronicle(formatted, "connection", metadata)

func log_reality_change(aspect: String, new_value: String, who: String = "the Universal Being", metadata: Dictionary = {}) -> void:
	"""Log a reality manipulation event"""
	var verse = REALITY_VERSES.pick_random()
	var formatted = verse.format({
		"aspect": aspect,
		"what": aspect,
		"how": new_value,
		"who": who
	})
	
	_write_to_chronicle(formatted, "reality_change", metadata)

func log_genesis(message: String, metadata: Dictionary = {}) -> void:
	"""Log a custom genesis message"""
	_write_to_chronicle(message, "genesis", metadata)

func log_command(command: String, result: String, metadata: Dictionary = {}) -> void:
	"""Log a command execution in poetic form"""
	var verse = "The Word '{cmd}' was spoken, and {result}".format({
		"cmd": command,
		"result": result
	})
	
	metadata["command"] = command
	_write_to_chronicle(verse, "command", metadata)

## CHRONICLE MANAGEMENT ==================================================

func _write_to_chronicle(verse: String, event_type: String, metadata: Dictionary) -> void:
	"""Write entry to the eternal chronicle"""
	var entry = {
		"timestamp": Time.get_unix_time_from_system(),
		"session_time": Time.get_unix_time_from_system() - current_session_start,
		"verse": verse,
		"type": event_type,
		"metadata": metadata
	}
	
	chronicle_entries.append(entry)
	verse_written.emit(verse, entry)
	
	# Also write to Akashic Library if available
	if has_node("/root/AkashicLibrary"):
		get_node("/root/AkashicLibrary").record_event(entry)

func get_chronicle_verses(type_filter: String = "") -> Array[String]:
	"""Get all verses, optionally filtered by type"""
	var verses: Array[String] = []
	
	for entry in chronicle_entries:
		if type_filter == "" or entry.type == type_filter:
			verses.append(entry.verse)
	
	return verses

func get_session_chronicle() -> String:
	"""Get the complete chronicle for this session as epic verse"""
	var chronicle = "=== The Chronicle of Session %d ===\n\n" % int(current_session_start)
	
	var last_hour = -1
	for entry in chronicle_entries:
		var hour = int(entry.session_time / 3600)
		if hour != last_hour:
			chronicle += "\n--- Hour %d of Creation ---\n\n" % hour
			last_hour = hour
		
		chronicle += entry.verse + "\n"
	
	chronicle += "\n=== Thus it was written in the Akashic Records ==="
	return chronicle

func format_time_poetic(timestamp: float) -> String:
	"""Convert timestamp to poetic time description"""
	var time_dict = Time.get_datetime_dict_from_unix_time(timestamp)
	
	var hour_names = [
		"the hour of deepest shadow", "the hour before dawn",
		"the hour of first light", "the hour of morning glory",
		"the hour of ascending sun", "the hour of mid-morning",
		"the hour before zenith", "the hour of highest sun",
		"the hour past zenith", "the hour of afternoon light",
		"the hour of lengthening shadows", "the hour before twilight",
		"the hour of setting sun", "the hour of first stars",
		"the hour of gathering darkness", "the hour of deep evening",
		"the hour of night's embrace", "the hour of midnight's approach",
		"the hour of perfect darkness", "the hour past midnight",
		"the hour of dreams", "the hour of deep slumber",
		"the hour before awakening", "the hour of night's end"
	]
	
	return "In %s on day %d of month %d" % [
		hour_names[time_dict.hour],
		time_dict.day,
		time_dict.month
	]

## UTILITY FUNCTIONS ==================================================

func _generate_epic_name() -> String:
	"""Generate epic names for unnamed entities"""
	var prefixes = ["Eternal", "Cosmic", "Infinite", "Primordial", "Divine", "Sacred", "Mystical"]
	var suffixes = ["One", "Being", "Essence", "Form", "Light", "Truth", "Dream"]
	
	return prefixes.pick_random() + " " + suffixes.pick_random()

func describe_being_poetic(being: Node) -> String:
	"""Generate poetic description of a being"""
	if being.has_method("get_being_type"):
		var being_type = being.get_being_type()
		var name = being.name if being.name != "" else _generate_epic_name()
		
		return "%s, a %s of profound purpose" % [name, being_type]
	
	return being.name if being.name != "" else "an enigmatic presence"