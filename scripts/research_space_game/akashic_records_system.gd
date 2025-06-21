# akashic_records_system.gd
extends Node
class_name AkashicRecordsSystem

signal record_accessed(record_id: String)
signal knowledge_integrated(knowledge_type: String)
signal universal_pattern_discovered(pattern: String)

# The Akashic Records - universal memory bank
var records: Dictionary = {}
var accessed_records: Array[String] = []
var integrated_knowledge: Dictionary = {}
var discovered_patterns: Array[String] = []

# Record categories
enum RecordType {
	PERSONAL,      # Player's journey
	PLANETARY,     # Planet histories
	STELLAR,       # Star system knowledge
	GALACTIC,      # Galaxy-wide events
	UNIVERSAL,     # Cosmic truths
	DIMENSIONAL    # Interdimensional knowledge
}

class AkashicRecord:
	var id: String
	var type: RecordType
	var content: Dictionary
	var access_requirements: Dictionary
	var timestamp: float
	
	func _init(p_id: String, p_type: RecordType):
		id = p_id
		type = p_type
		timestamp = Time.get_unix_time_from_system()
		content = {}
		access_requirements = {"consciousness_level": 1}

func _ready():
	initialize_core_records()
	
func initialize_core_records():
	# Create fundamental records
	create_record("origin_of_consciousness", RecordType.UNIVERSAL, {
		"description": "The first spark of awareness in the void",
		"knowledge": "consciousness_fundamentals",
		"pattern": "emergence"
	})
	
	create_record("universal_being_genesis", RecordType.UNIVERSAL, {
		"description": "The birth of Universal Being consciousness",
		"knowledge": "consciousness_evolution",
		"pattern": "transcendence"
	})

func create_record(record_id: String, type: RecordType, data: Dictionary) -> AkashicRecord:
	var record = AkashicRecord.new(record_id, type)
	record.content = data
	records[record_id] = record
	return record

func access_record(record_id: String) -> Dictionary:
	if records.has(record_id):
		var record = records[record_id]
		accessed_records.append(record_id)
		record_accessed.emit(record_id)
		return record.content
	return {}

func integrate_knowledge(knowledge_type: String, data: Dictionary):
	integrated_knowledge[knowledge_type] = data
	knowledge_integrated.emit(knowledge_type)

func discover_pattern(pattern_name: String):
	if pattern_name not in discovered_patterns:
		discovered_patterns.append(pattern_name)
		universal_pattern_discovered.emit(pattern_name)

func get_records_by_type(type: RecordType) -> Array:
	var filtered_records = []
	for record_id in records:
		var record = records[record_id]
		if record.type == type:
			filtered_records.append(record)
	return filtered_records

func _to_string() -> String:
	return "AkashicRecordsSystem [Records: %d, Accessed: %d, Patterns: %d]" % [
		records.size(), accessed_records.size(), discovered_patterns.size()
	]