extends Node

# Library settings
@export var max_records: int = 10000
@export var auto_save_interval: float = 300.0  # 5 minutes
@export var save_file_path: String = "user://akashic_records.json"
@export var backup_count: int = 5

# Library state
var records: Array[Dictionary] = []
var current_save_timer: float = 0.0
var is_saving: bool = false
var last_backup_time: String = ""

# Record types and their validation rules
var record_types: Dictionary = {
    "creation": {
        "required_fields": ["being_name", "being_type", "creator"],
        "optional_fields": ["properties", "components", "consciousness"]
    },
    "modification": {
        "required_fields": ["being_name", "property", "old_value", "new_value"],
        "optional_fields": ["modifier", "reason"]
    },
    "evolution": {
        "required_fields": ["being_name", "old_type", "new_type"],
        "optional_fields": ["evolver", "properties", "consciousness"]
    },
    "interaction": {
        "required_fields": ["being_name", "interaction_type", "target"],
        "optional_fields": ["properties", "result"]
    },
    "system": {
        "required_fields": ["system_name", "action"],
        "optional_fields": ["properties", "result"]
    },
    "gemma": {
        "required_fields": ["action", "input"],
        "optional_fields": ["being_name", "result", "consciousness"]
    }
}

# Signals
signal record_created(record: Dictionary)
signal record_modified(record: Dictionary)
signal library_saved(path: String)
signal library_loaded(path: String)
signal backup_created(path: String)

func _ready() -> void:
    # Load existing records
    _load_records()
    
    # Start save timer
    current_save_timer = auto_save_interval

func _process(delta: float) -> void:
    # Handle auto-save
    if auto_save_interval > 0:
        current_save_timer -= delta
        if current_save_timer <= 0:
            _save_records()
            current_save_timer = auto_save_interval

func create_record(type: String, data: Dictionary) -> Dictionary:
    # Validate record type
    if not record_types.has(type):
        push_error("Invalid record type: " + type)
        return {}
    
    # Add required fields
    var record = {
        "type": type,
        "timestamp": Time.get_datetime_string_from_system(),
        "uuid": _generate_uuid()
    }
    
    # Validate required fields
    var required = record_types[type].required_fields
    for field in required:
        if not data.has(field):
            push_error("Missing required field for " + type + ": " + field)
            return {}
        record[field] = data[field]
    
    # Add optional fields
    var optional = record_types[type].optional_fields
    for field in optional:
        if data.has(field):
            record[field] = data[field]
    
    # Add to records
    records.append(record)
    if records.size() > max_records:
        records.pop_front()
    
    # Emit signal
    emit_signal("record_created", record)
    
    return record

func modify_record(uuid: String, data: Dictionary) -> Dictionary:
    # Find record
    var index = records.find(func(r): return r.get("uuid") == uuid)
    if index == -1:
        push_error("Record not found: " + uuid)
        return {}
    
    # Update record
    var record = records[index]
    for key in data:
        record[key] = data[key]
    
    # Add modification timestamp
    record["modified_at"] = Time.get_datetime_string_from_system()
    
    # Emit signal
    emit_signal("record_modified", record)
    
    return record

func get_record(uuid: String) -> Dictionary:
    var record = records.filter(func(r): return r.get("uuid") == uuid)
    if record.is_empty():
        return {}
    return record[0]

func get_records_by_type(type: String) -> Array[Dictionary]:
    return records.filter(func(r): return r.get("type") == type)

func get_records_by_being(being_name: String) -> Array[Dictionary]:
    return records.filter(func(r): return r.get("being_name") == being_name)

func get_records_by_time_range(start_time: String, end_time: String) -> Array[Dictionary]:
    return records.filter(func(r):
        var time = r.get("timestamp", "")
        return time >= start_time and time <= end_time
    )

func search_records(query: String) -> Array[Dictionary]:
    var query_lower = query.to_lower()
    return records.filter(func(r):
        # Search in all string fields
        for value in r.values():
            if value is String and value.to_lower().contains(query_lower):
                return true
        return false
    )

func _save_records() -> void:
    if is_saving:
        return
    
    is_saving = true
    
    # Create backup if needed
    if not last_backup_time.is_empty():
        var last_time = Time.get_unix_time_from_datetime_string(last_backup_time)
        var current_time = Time.get_unix_time_from_system()
        if current_time - last_time >= 86400:  # 24 hours
            _create_backup()
    
    # Save records
    var save_data = {
        "version": "1.0",
        "timestamp": Time.get_datetime_string_from_system(),
        "record_count": records.size(),
        "records": records
    }
    
    var file = FileAccess.open(save_file_path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()
        emit_signal("library_saved", save_file_path)
    else:
        push_error("Failed to save Akashic records: " + str(FileAccess.get_open_error()))
    
    is_saving = false

func _load_records() -> void:
    if not FileAccess.file_exists(save_file_path):
        return
    
    var file = FileAccess.open(save_file_path, FileAccess.READ)
    if file:
        var json = JSON.new()
        var error = json.parse(file.get_as_text())
        if error == OK:
            var data = json.get_data()
            if data.has("records"):
                records = data.records
                emit_signal("library_loaded", save_file_path)
        else:
            push_error("Failed to parse Akashic records: " + json.get_error_message())
        file.close()
    else:
        push_error("Failed to load Akashic records: " + str(FileAccess.get_open_error()))

func _create_backup() -> void:
    var backup_path = save_file_path + ".backup"
    var backup_index = 1
    
    # Find next available backup index
    while FileAccess.file_exists(backup_path + str(backup_index)):
        backup_index += 1
        if backup_index > backup_count:
            # Remove oldest backup
            var oldest = backup_path + "1"
            if FileAccess.file_exists(oldest):
                var dir = DirAccess.open("user://")
                if dir:
                    dir.remove(oldest)
            backup_index = 1
    
    # Create backup
    var file = FileAccess.open(backup_path + str(backup_index), FileAccess.WRITE)
    if file:
        var save_data = {
            "version": "1.0",
            "timestamp": Time.get_datetime_string_from_system(),
            "record_count": records.size(),
            "records": records
        }
        file.store_string(JSON.stringify(save_data))
        file.close()
        last_backup_time = Time.get_datetime_string_from_system()
        emit_signal("backup_created", backup_path + str(backup_index))
    else:
        push_error("Failed to create Akashic backup: " + str(FileAccess.get_open_error()))

func _generate_uuid() -> String:
    var uuid = ""
    var hex_chars = "0123456789abcdef"
    for i in range(32):
        if i == 8 or i == 12 or i == 16 or i == 20:
            uuid += "-"
        uuid += hex_chars[randi() % 16]
    return uuid

func get_statistics() -> Dictionary:
    var stats = {
        "total_records": records.size(),
        "records_by_type": {},
        "oldest_record": "",
        "newest_record": "",
        "most_active_being": "",
        "being_activity": {}
    }
    
    # Count records by type
    for record in records:
        var type = record.get("type", "unknown")
        stats.records_by_type[type] = stats.records_by_type.get(type, 0) + 1
        
        # Track being activity
        var being = record.get("being_name", "")
        if not being.is_empty():
            stats.being_activity[being] = stats.being_activity.get(being, 0) + 1
    
    # Find oldest and newest records
    if not records.is_empty():
        var times = records.map(func(r): return r.get("timestamp", ""))
        times.sort()
        stats.oldest_record = times[0]
        stats.newest_record = times[times.size() - 1]
    
    # Find most active being
    var max_activity = 0
    for being in stats.being_activity:
        if stats.being_activity[being] > max_activity:
            max_activity = stats.being_activity[being]
            stats.most_active_being = being
    
    return stats

func export_records(format: String = "json") -> String:
    match format:
        "json":
            return JSON.stringify(records)
        "csv":
            var csv = "timestamp,type,being_name,message\n"
            for record in records:
                csv += "%s,%s,%s,%s\n" % [
                    record.get("timestamp", ""),
                    record.get("type", ""),
                    record.get("being_name", ""),
                    record.get("message", "").replace(",", ";")
                ]
            return csv
        "text":
            var text = "Akashic Records Export\n"
            text += "=====================\n\n"
            for record in records:
                text += "[%s] [%s] " % [
                    record.get("timestamp", ""),
                    record.get("type", "").to_upper()
                ]
                if record.has("being_name"):
                    text += "%s: " % record.being_name
                if record.has("message"):
                    text += record.message
                text += "\n"
            return text
        _:
            push_error("Unsupported export format: " + format)
            return "" 