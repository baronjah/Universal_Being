# ==================================================
# UNIVERSAL BEING: RecordsMap
# TYPE: database
# PURPOSE: Simple Akashic Records dictionary store
# COMPONENTS: None
# ==================================================

extends Node
class_name RecordsMap

## Record storage
var records_map: Dictionary = {}
var next_id_counter: Dictionary = {}

func _ready():
	create_record("root", "")
	add_data("root", "description", "Cosmic Records Root")

## Create a new record and attach it to a parent if provided
func create_record(record_id: String, parent_id: String = "") -> void:
	if records_map.has(record_id):
		return
	records_map[record_id] = {
		"parent": parent_id,
		"children": [],
		"data": {},
		"position": Vector3.ZERO,
		"visible": false
	}
	if parent_id != "" and records_map.has(parent_id):
		records_map[parent_id]["children"].append(record_id)

## Add or update data on a record
func add_data(record_id: String, key: String, value) -> void:
	if not records_map.has(record_id):
		push_warning("Record '%s' does not exist" % record_id)
		return
	records_map[record_id]["data"][key] = value

## Retrieve data from a record
func get_data(record_id: String, key: String):
	if not records_map.has(record_id):
		return null
	return records_map[record_id]["data"].get(key, null)

## Minimalistic base-36 ID encoding/decoding
const ID_CHARS := "0123456789abcdefghijklmnopqrstuvwxyz"

func generate_compact_id(parent_id: String = "root") -> String:
	var base_chars = "abcdefghijklmnopqrstuvwxyz"
	
	if not next_id_counter.has(parent_id):
		next_id_counter[parent_id] = 0
	
	var counter = next_id_counter[parent_id]
	var id = ""
	
	if counter < 26:
		id = base_chars[counter] + "0"
	elif counter < 702:
		var first = (counter - 26) / 26
		var second = (counter - 26) % 26
		id = base_chars[first] + base_chars[second] + "0"
	else:
		id = "z" + str(counter)
	
	next_id_counter[parent_id] += 1
	return id

func create_semantic_id(concept_path: String) -> String:
	var semantic_map = {
		"consciousness.navigator.3d": "c3d",
		"interface.notepad.layer": "ui.np",
		"data.akashic.record": "ak.data",
		"entity.word.floating": "word.float",
		"system.cosmic.database": "sys.cosmos",
		"visual.stellar.color": "vis.star",
		"input.keyboard.floating": "key.float",
		"navigation.camera.free": "cam.free",
		"manifestation.word.create": "create.word",
		"interaction.energy.touch": "touch.energy"
	}
	
	if semantic_map.has(concept_path):
		return semantic_map[concept_path] + "." + generate_compact_id("semantic")
	else:
		return concept_path + "." + generate_compact_id("unknown")

func decode_semantic_meaning(semantic_id: String) -> Dictionary:
	var parts = semantic_id.split(".")
	if parts.size() < 2:
		return {"error": "invalid_semantic_id"}
	
	var meaning = {
		"domain": parts[0],
		"concept": parts[1] if parts.size() > 1 else "",
		"instance": parts[2] if parts.size() > 2 else "",
		"full_path": semantic_id
	}
	
	return meaning

func get_child_records(record_id: String) -> Array:
	if records_map.has(record_id):
		return records_map[record_id]["children"]
	return []

func get_record_hierarchy(record_id: String) -> Array:
	var hierarchy = []
	var current = record_id
	
	while current != "" and records_map.has(current):
		hierarchy.push_front(current)
		current = records_map[current]["parent"]
	
	return hierarchy

func set_record_position(record_id: String, position: Vector3):
	if records_map.has(record_id):
		records_map[record_id]["position"] = position

func get_record_position(record_id: String) -> Vector3:
	if records_map.has(record_id):
		return records_map[record_id]["position"]
	return Vector3.ZERO

func set_record_visible(record_id: String, visible: bool):
	if records_map.has(record_id):
		records_map[record_id]["visible"] = visible

func is_record_visible(record_id: String) -> bool:
	if records_map.has(record_id):
		return records_map[record_id]["visible"]
	return false
