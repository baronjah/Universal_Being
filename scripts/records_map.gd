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

## Create a new record and attach it to a parent if provided
func create_record(record_id: String, parent_id: String = "") -> void:
    if records_map.has(record_id):
        return
    records_map[record_id] = {
        "parent": parent_id,
        "children": [],
        "data": {}
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

func encode_record_id(value: int) -> String:
    var n := value
    if n == 0:
        return ID_CHARS[0]
    var result := ""
    while n > 0:
        var idx := n % ID_CHARS.length()
        result = ID_CHARS[idx] + result
        n /= ID_CHARS.length()
    return result

func decode_record_id(compact_id: String) -> int:
    var val := 0
    for ch in compact_id.to_lower():
        var idx := ID_CHARS.find(ch)
        if idx == -1:
            continue
        val = val * ID_CHARS.length() + idx
    return val
