extends Node
class_name LuminousDataController

# Signals
signal data_processed(bytes_processed)
signal data_capacity_changed(new_capacity)
signal cache_performance_report(stats)
signal automation_task_completed(task_name, result)

# Data handling constants
const DATA_BLOCK_SIZE = 4096  # 4KB blocks
const INITIAL_CAPACITY = 1024 * 1024 * 32  # 32MB initial capacity
const MAX_CAPACITY = 1024 * 1024 * 1024 * 2  # 2GB max capacity
const COMPRESSION_RATIO = 2.5  # Average compression ratio

# Multi-threading
var processing_thread: Thread
var thread_mutex: Mutex
var thread_semaphore: Semaphore
var stop_thread: bool = false

# Caching system
var cache: Dictionary = {}
var cache_stats: Dictionary = {
    "hits": 0,
    "misses": 0,
    "evictions": 0,
    "total_requests": 0,
    "compression_savings": 0
}
var cache_size_limit: int = 100 * 1024 * 1024  # 100MB cache limit
var current_cache_size: int = 0
var lru_list: Array = []  # Least Recently Used tracking

# Dynamic capacity management
var current_capacity: int = INITIAL_CAPACITY
var used_capacity: int = 0
var capacity_warnings: Array = []

# Data transformation pipelines
var transformation_pipelines: Dictionary = {}
var active_transformations: Array = []

# Game automation systems
var automation_templates: Dictionary = {}
var generated_assets: Dictionary = {}
var automation_queue: Array = []
var automation_history: Array = []

# File monitoring
var watched_directories: Dictionary = {}
var file_change_history: Dictionary = {}
var delta_snapshots: Array = []

func _ready():
    # Initialize subsystems
    _initialize_cache()
    _initialize_pipelines()
    _initialize_automation_templates()
    
    # Start processing thread
    thread_mutex = Mutex.new()
    thread_semaphore = Semaphore.new()
    processing_thread = Thread.new()
    processing_thread.start(_background_processor)
    
    # Schedule regular maintenance
    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = 60  # 1 minute
    timer.timeout.connect(_scheduled_maintenance)
    timer.autostart = true

func _exit_tree():
    # Properly shut down thread
    if processing_thread and processing_thread.is_started():
        thread_mutex.lock()
        stop_thread = true
        thread_mutex.unlock()
        thread_semaphore.post()
        processing_thread.wait_to_finish()

# Main data processing functions
func process_data_block(data: PackedByteArray, pipeline_name: String = "default") -> PackedByteArray:
    if data.size() > MAX_CAPACITY:
        push_error("Data exceeds maximum capacity")
        return PackedByteArray()
    
    # Check cache first
    var data_hash = _hash_data(data)
    if _check_cache(data_hash, pipeline_name):
        return _get_from_cache(data_hash, pipeline_name)
    
    # Process through pipeline
    var result = _apply_pipeline(data, pipeline_name)
    
    # Cache result
    _add_to_cache(data_hash, pipeline_name, result)
    
    # Update stats
    thread_mutex.lock()
    used_capacity += result.size()
    thread_mutex.unlock()
    
    emit_signal("data_processed", result.size())
    return result

func expand_capacity(additional_bytes: int) -> bool:
    thread_mutex.lock()
    var new_capacity = current_capacity + additional_bytes
    
    if new_capacity > MAX_CAPACITY:
        capacity_warnings.append({
            "timestamp": Time.get_unix_time_from_system(),
            "requested": new_capacity,
            "granted": MAX_CAPACITY,
            "message": "Capacity expansion limited to maximum"
        })
        new_capacity = MAX_CAPACITY
    
    var previous = current_capacity
    current_capacity = new_capacity
    thread_mutex.unlock()
    
    emit_signal("data_capacity_changed", current_capacity)
    print("Capacity expanded from %d to %d bytes" % [previous, current_capacity])
    return true

# Cache management
func _initialize_cache():
    cache = {}
    current_cache_size = 0
    lru_list = []

func _check_cache(data_hash: String, pipeline_name: String) -> bool:
    thread_mutex.lock()
    cache_stats["total_requests"] += 1
    var key = data_hash + "_" + pipeline_name
    var exists = cache.has(key)
    
    if exists:
        cache_stats["hits"] += 1
        # Update LRU status
        lru_list.erase(key)
        lru_list.push_back(key)
    else:
        cache_stats["misses"] += 1
    
    thread_mutex.unlock()
    return exists

func _get_from_cache(data_hash: String, pipeline_name: String) -> PackedByteArray:
    thread_mutex.lock()
    var key = data_hash + "_" + pipeline_name
    var result = cache[key].duplicate() if cache.has(key) else PackedByteArray()
    thread_mutex.unlock()
    return result

func _add_to_cache(data_hash: String, pipeline_name: String, data: PackedByteArray) -> void:
    thread_mutex.lock()
    var key = data_hash + "_" + pipeline_name
    
    # Check if we need to evict entries
    while current_cache_size + data.size() > cache_size_limit and lru_list.size() > 0:
        var evict_key = lru_list.pop_front()
        var evicted_size = cache[evict_key].size()
        current_cache_size -= evicted_size
        cache.erase(evict_key)
        cache_stats["evictions"] += 1
    
    # Only add if it fits after eviction
    if current_cache_size + data.size() <= cache_size_limit:
        cache[key] = data
        current_cache_size += data.size()
        lru_list.push_back(key)
    
    thread_mutex.unlock()

func _hash_data(data: PackedByteArray) -> String:
    var ctx = HashingContext.new()
    ctx.start(HashingContext.HASH_SHA256)
    ctx.update(data)
    var hash = ctx.finish()
    return hash.hex_encode()

# Data transformation pipelines
func _initialize_pipelines():
    # Default pipeline
    transformation_pipelines["default"] = [
        _transform_compress,
        _transform_encrypt
    ]
    
    # Game asset pipeline
    transformation_pipelines["game_asset"] = [
        _transform_optimize_asset,
        _transform_compress,
        _transform_encrypt
    ]
    
    # Script pipeline
    transformation_pipelines["script"] = [
        _transform_minify_script,
        _transform_compress
    ]
    
    # Scene pipeline
    transformation_pipelines["scene"] = [
        _transform_optimize_scene,
        _transform_compress
    ]

func _apply_pipeline(data: PackedByteArray, pipeline_name: String) -> PackedByteArray:
    if not transformation_pipelines.has(pipeline_name):
        pipeline_name = "default"
    
    var result = data
    var pipeline = transformation_pipelines[pipeline_name]
    
    thread_mutex.lock()
    active_transformations.push_back({
        "pipeline": pipeline_name,
        "start_time": Time.get_unix_time_from_system(),
        "data_size": data.size()
    })
    thread_mutex.unlock()
    
    for transform_func in pipeline:
        result = transform_func.call(result)
    
    thread_mutex.lock()
    var transform_data = active_transformations.pop_back()
    transform_data["end_time"] = Time.get_unix_time_from_system()
    transform_data["result_size"] = result.size()
    transform_data["compression_ratio"] = float(data.size()) / max(1, result.size())
    thread_mutex.unlock()
    
    return result

# Transformation functions
func _transform_compress(data: PackedByteArray) -> PackedByteArray:
    # Simulate compression
    var compressed_size = int(float(data.size()) / COMPRESSION_RATIO)
    var result = data.slice(0, min(compressed_size, data.size() - 1))
    cache_stats["compression_savings"] += (data.size() - result.size())
    return result

func _transform_encrypt(data: PackedByteArray) -> PackedByteArray:
    # Placeholder for encryption, just return data in this implementation
    return data

func _transform_optimize_asset(data: PackedByteArray) -> PackedByteArray:
    # Simulation of asset optimization
    # In a real implementation, this would optimize textures, models, etc.
    var optimal_size = int(data.size() * 0.8)  # Assume 20% optimization
    return data.slice(0, min(optimal_size, data.size() - 1))

func _transform_minify_script(data: PackedByteArray) -> PackedByteArray:
    # Simulation of script minification
    # In a real implementation, this would remove comments, whitespace, etc.
    var minified_size = int(data.size() * 0.7)  # Assume 30% reduction
    return data.slice(0, min(minified_size, data.size() - 1))

func _transform_optimize_scene(data: PackedByteArray) -> PackedByteArray:
    # Simulation of scene optimization
    # In a real implementation, this would optimize scene structure
    var optimized_size = int(data.size() * 0.85)  # Assume 15% optimization
    return data.slice(0, min(optimized_size, data.size() - 1))

# Game development automation
func _initialize_automation_templates():
    # Entity template
    automation_templates["entity"] = {
        "script_template": "res://templates/entity_script.gd",
        "scene_template": "res://templates/entity_scene.tscn",
        "parameters": ["name", "health", "speed", "attack_power"]
    }
    
    # Level template
    automation_templates["level"] = {
        "script_template": "res://templates/level_script.gd",
        "scene_template": "res://templates/level_scene.tscn",
        "parameters": ["name", "width", "height", "difficulty"]
    }
    
    # UI screen template
    automation_templates["ui_screen"] = {
        "script_template": "res://templates/ui_screen_script.gd",
        "scene_template": "res://templates/ui_screen_scene.tscn",
        "parameters": ["title", "buttons", "panels"]
    }

func generate_game_entity(params: Dictionary) -> Dictionary:
    if not _validate_template_params("entity", params):
        return {"success": false, "error": "Invalid parameters for entity template"}
    
    var result = {
        "success": true,
        "entity_id": str(randi()),
        "files": {}
    }
    
    # Create script
    var script_content = _load_template("entity", "script")
    script_content = _populate_template(script_content, params)
    var script_path = "res://scenes/entities/%s.gd" % params.name.to_lower().replace(" ", "_")
    result.files[script_path] = script_content
    
    # Create scene
    var scene_content = _load_template("entity", "scene")
    scene_content = _populate_template(scene_content, params)
    var scene_path = "res://scenes/entities/%s.tscn" % params.name.to_lower().replace(" ", "_")
    result.files[scene_path] = scene_content
    
    # Queue asset generation
    _queue_automation_task("generate_entity_assets", params)
    
    # Store in generated assets
    thread_mutex.lock()
    generated_assets[result.entity_id] = {
        "type": "entity",
        "params": params.duplicate(),
        "timestamp": Time.get_unix_time_from_system(),
        "paths": result.files.keys()
    }
    thread_mutex.unlock()
    
    emit_signal("automation_task_completed", "generate_game_entity", result)
    return result

func generate_game_level(params: Dictionary) -> Dictionary:
    if not _validate_template_params("level", params):
        return {"success": false, "error": "Invalid parameters for level template"}
    
    var result = {
        "success": true,
        "level_id": str(randi()),
        "files": {}
    }
    
    # Create script
    var script_content = _load_template("level", "script")
    script_content = _populate_template(script_content, params)
    var script_path = "res://scenes/levels/%s.gd" % params.name.to_lower().replace(" ", "_")
    result.files[script_path] = script_content
    
    # Create scene
    var scene_content = _load_template("level", "scene")
    scene_content = _populate_template(scene_content, params)
    var scene_path = "res://scenes/levels/%s.tscn" % params.name.to_lower().replace(" ", "_")
    result.files[scene_path] = scene_content
    
    # Queue layout generation based on size
    _queue_automation_task("generate_level_layout", params)
    
    # Store in generated assets
    thread_mutex.lock()
    generated_assets[result.level_id] = {
        "type": "level",
        "params": params.duplicate(),
        "timestamp": Time.get_unix_time_from_system(),
        "paths": result.files.keys()
    }
    thread_mutex.unlock()
    
    emit_signal("automation_task_completed", "generate_game_level", result)
    return result

func generate_ui_screen(params: Dictionary) -> Dictionary:
    if not _validate_template_params("ui_screen", params):
        return {"success": false, "error": "Invalid parameters for UI screen template"}
    
    var result = {
        "success": true,
        "screen_id": str(randi()),
        "files": {}
    }
    
    # Create script
    var script_content = _load_template("ui_screen", "script")
    script_content = _populate_template(script_content, params)
    var script_path = "res://scenes/ui/%s.gd" % params.title.to_lower().replace(" ", "_")
    result.files[script_path] = script_content
    
    # Create scene
    var scene_content = _load_template("ui_screen", "scene")
    scene_content = _populate_template(scene_content, params)
    var scene_path = "res://scenes/ui/%s.tscn" % params.title.to_lower().replace(" ", "_")
    result.files[scene_path] = scene_content
    
    # Store in generated assets
    thread_mutex.lock()
    generated_assets[result.screen_id] = {
        "type": "ui_screen",
        "params": params.duplicate(),
        "timestamp": Time.get_unix_time_from_system(),
        "paths": result.files.keys()
    }
    thread_mutex.unlock()
    
    emit_signal("automation_task_completed", "generate_ui_screen", result)
    return result

func _validate_template_params(template_type: String, params: Dictionary) -> bool:
    if not automation_templates.has(template_type):
        return false
    
    var required_params = automation_templates[template_type].parameters
    for param in required_params:
        if not params.has(param):
            return false
    
    return true

func _load_template(template_type: String, template_part: String) -> String:
    # In a real implementation, this would load from template files
    # Simulated implementation returns placeholder templates
    var template = ""
    
    if template_type == "entity":
        if template_part == "script":
            template = """extends CharacterBody3D

# Generated entity: {name}

@export var health: float = {health}
@export var speed: float = {speed}
@export var attack_power: float = {attack_power}

func _ready():
    # Entity initialization code
    pass

func _physics_process(delta):
    # Entity movement and physics
    pass

func attack():
    # Attack logic
    pass
"""
        elif template_part == "scene":
            template = """[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scenes/entities/{name_lower}.gd" id="1_script"]

[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_1"]

[node name="{name}" type="CharacterBody3D"]
script = ExtResource("1_script")
health = {health}
speed = {speed}
attack_power = {attack_power}

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
shape = SubResource("CapsuleShape3D_1")

[node name="Mesh" type="MeshInstance3D" parent="."]
"""
    
    elif template_type == "level":
        if template_part == "script":
            template = """extends Node3D

# Generated level: {name}

@export var width: int = {width}
@export var height: int = {height}
@export var difficulty: int = {difficulty}

var player_start_position: Vector3 = Vector3(2, 0, 2)
var exit_position: Vector3 = Vector3({width} - 2, 0, {height} - 2)

func _ready():
    # Level initialization code
    generate_layout()
    spawn_entities()

func generate_layout():
    # Layout generation logic
    pass

func spawn_entities():
    # Entity spawning logic
    var enemy_count = difficulty * 3
    for i in range(enemy_count):
        # Spawn enemies
        pass
"""
        elif template_part == "scene":
            template = """[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scenes/levels/{name_lower}.gd" id="1_script"]

[node name="{name}" type="Node3D"]
script = ExtResource("1_script")
width = {width}
height = {height}
difficulty = {difficulty}

[node name="Floor" type="StaticBody3D" parent="."]

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 0.866025, 0.5, 0, -0.5, 0.866025, 0, 10, 10)

[node name="SpawnPositions" type="Node3D" parent="."]
"""
    
    elif template_type == "ui_screen":
        if template_part == "script":
            template = """extends Control

# Generated UI screen: {title}

signal button_pressed(button_name)

func _ready():
    # Initialize UI elements
    setup_buttons()
    
func setup_buttons():
    # Setup button connections
    for button in get_buttons():
        button.pressed.connect(_on_button_pressed.bind(button.name))
        
func _on_button_pressed(button_name):
    emit_signal("button_pressed", button_name)
    
func get_buttons():
    return $ButtonContainer.get_children()
"""
        elif template_part == "scene":
            template = """[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scenes/ui/{title_lower}.gd" id="1_script"]

[node name="{title}" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1_script")

[node name="Background" type="Panel" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="Title" type="Label" parent="."]
layout_mode = 1
anchors_preset = 10
anchor_right = 1.0
offset_bottom = 80.0
grow_horizontal = 2
theme_override_font_sizes/font_size = 36
text = "{title}"
horizontal_alignment = 1
vertical_alignment = 1

[node name="ButtonContainer" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -100.0
offset_top = -20.0
offset_right = 100.0
offset_bottom = 20.0
grow_horizontal = 2
grow_vertical = 2
"""
    
    return template

func _populate_template(template: String, params: Dictionary) -> String:
    var result = template
    
    for key in params:
        var token = "{%s}" % key
        var value = str(params[key])
        result = result.replace(token, value)
    
    # Additional transformations
    if params.has("name"):
        result = result.replace("{name_lower}", params.name.to_lower().replace(" ", "_"))
    if params.has("title"):
        result = result.replace("{title_lower}", params.title.to_lower().replace(" ", "_"))
    
    return result

func _queue_automation_task(task_name: String, params: Dictionary) -> void:
    thread_mutex.lock()
    automation_queue.push_back({
        "task": task_name,
        "params": params.duplicate(),
        "timestamp": Time.get_unix_time_from_system(),
        "status": "pending"
    })
    thread_mutex.unlock()
    thread_semaphore.post()  # Signal the worker thread

# Maintenance functions
func _scheduled_maintenance():
    # Update capacity statistics
    var usage_percent = (float(used_capacity) / current_capacity) * 100
    
    # Cleanup old entries in various tracking arrays
    _cleanup_historical_data()
    
    # Report cache performance
    emit_signal("cache_performance_report", cache_stats)
    
    # Process any pending automation tasks
    if automation_queue.size() > 0:
        thread_semaphore.post()

func _cleanup_historical_data():
    var now = Time.get_unix_time_from_system()
    
    # Keep only recent capacity warnings (last 7 days)
    thread_mutex.lock()
    var old_warnings_count = capacity_warnings.size()
    capacity_warnings = capacity_warnings.filter(func(warning): return now - warning.timestamp < 7 * 24 * 60 * 60)
    
    # Keep only recent automation history (last 30 days)
    var old_automation_count = automation_history.size()
    automation_history = automation_history.filter(func(entry): return now - entry.timestamp < 30 * 24 * 60 * 60)
    
    # Keep only recent delta snapshots (last 24 hours)
    var old_snapshots_count = delta_snapshots.size()
    delta_snapshots = delta_snapshots.filter(func(snapshot): return now - snapshot.timestamp < 24 * 60 * 60)
    thread_mutex.unlock()

# Background processing
func _background_processor():
    while true:
        thread_semaphore.wait()  # Wait for work or shutdown signal
        
        thread_mutex.lock()
        var should_stop = stop_thread
        thread_mutex.unlock()
        
        if should_stop:
            break
        
        # Process automation queue
        _process_automation_queue()
        
        # Process file change monitoring
        _process_file_changes()

func _process_automation_queue():
    thread_mutex.lock()
    var tasks_to_process = automation_queue.slice(0, min(5, automation_queue.size() - 1))
    for i in range(min(5, automation_queue.size())):
        if automation_queue.size() > 0:
            automation_queue.pop_front()
    thread_mutex.unlock()
    
    for task in tasks_to_process:
        var result = _execute_automation_task(task.task, task.params)
        task.result = result
        task.status = "completed"
        task.completion_time = Time.get_unix_time_from_system()
        
        thread_mutex.lock()
        automation_history.push_back(task)
        thread_mutex.unlock()

func _execute_automation_task(task_name: String, params: Dictionary) -> Dictionary:
    # Process specific automation tasks
    match task_name:
        "generate_entity_assets":
            return _generate_entity_assets(params)
        "generate_level_layout":
            return _generate_level_layout(params)
        _:
            return {"success": false, "error": "Unknown automation task: " + task_name}

func _generate_entity_assets(params: Dictionary) -> Dictionary:
    # Simulate asset generation for an entity
    # In a real implementation, this would create textures, animations, etc.
    return {
        "success": true,
        "asset_paths": [
            "res://assets/entities/%s.png" % params.name.to_lower().replace(" ", "_"),
            "res://assets/entities/%s_normal.png" % params.name.to_lower().replace(" ", "_")
        ]
    }

func _generate_level_layout(params: Dictionary) -> Dictionary:
    # Simulate level layout generation
    # In a real implementation, this would create a level layout
    var width = params.width if params.has("width") else 20
    var height = params.height if params.has("height") else 20
    
    # Create a simple grid layout
    var grid = []
    for y in range(height):
        var row = []
        for x in range(width):
            # Borders are walls, everything else is floor
            if x == 0 or x == width - 1 or y == 0 or y == height - 1:
                row.append(1)  # Wall
            else:
                row.append(0)  # Floor
        grid.append(row)
    
    # Add some random walls
    var difficulty = params.difficulty if params.has("difficulty") else 1
    var wall_count = width * height * 0.1 * difficulty
    for i in range(wall_count):
        var x = randi() % (width - 2) + 1
        var y = randi() % (height - 2) + 1
        grid[y][x] = 1
    
    return {
        "success": true,
        "layout": grid,
        "spawn_points": [Vector2(1, 1)],
        "exit_points": [Vector2(width - 2, height - 2)]
    }

func _process_file_changes():
    # Monitor watched directories for changes
    for dir_path in watched_directories:
        var dir_info = watched_directories[dir_path]
        var last_check_time = dir_info.last_check_time
        var now = Time.get_unix_time_from_system()
        
        # Only check directories periodically (every 5 seconds)
        if now - last_check_time < 5:
            continue
        
        # Update last check time
        thread_mutex.lock()
        watched_directories[dir_path].last_check_time = now
        thread_mutex.unlock()
        
        # Scan directory for changes
        var current_files = _scan_directory_files(dir_path)
        var changes = _detect_file_changes(dir_info.files, current_files)
        
        if changes.added.size() > 0 or changes.modified.size() > 0 or changes.removed.size() > 0:
            # Record changes
            var change_record = {
                "timestamp": now,
                "directory": dir_path,
                "added": changes.added,
                "modified": changes.modified,
                "removed": changes.removed
            }
            
            thread_mutex.lock()
            if not file_change_history.has(dir_path):
                file_change_history[dir_path] = []
            file_change_history[dir_path].push_back(change_record)
            delta_snapshots.push_back(change_record)
            
            # Update directory file listing
            watched_directories[dir_path].files = current_files
            thread_mutex.unlock()

func _scan_directory_files(path: String) -> Dictionary:
    var result = {}
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if file_name != "." and file_name != "..":
                var full_path = path.path_join(file_name)
                
                if dir.current_is_dir():
                    # Recursively scan subdirectories
                    var subdir_files = _scan_directory_files(full_path)
                    for subfile in subdir_files:
                        result[subfile] = subdir_files[subfile]
                else:
                    # Get file info
                    var file_info = {
                        "path": full_path,
                        "modified_time": FileAccess.get_modified_time(full_path),
                        "size": FileAccess.get_file_size(full_path)
                    }
                    result[full_path] = file_info
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    return result

func _detect_file_changes(old_files: Dictionary, new_files: Dictionary) -> Dictionary:
    var changes = {
        "added": [],
        "modified": [],
        "removed": []
    }
    
    # Detect added and modified files
    for file_path in new_files:
        if not old_files.has(file_path):
            changes.added.append(file_path)
        elif new_files[file_path].modified_time != old_files[file_path].modified_time:
            changes.modified.append(file_path)
    
    # Detect removed files
    for file_path in old_files:
        if not new_files.has(file_path):
            changes.removed.append(file_path)
    
    return changes

# Public API for watching directories
func watch_directory(path: String) -> bool:
    if not DirAccess.dir_exists_absolute(path):
        return false
    
    thread_mutex.lock()
    if not watched_directories.has(path):
        watched_directories[path] = {
            "files": _scan_directory_files(path),
            "last_check_time": Time.get_unix_time_from_system()
        }
    thread_mutex.unlock()
    
    return true

func stop_watching_directory(path: String) -> bool:
    thread_mutex.lock()
    var was_watching = watched_directories.has(path)
    if was_watching:
        watched_directories.erase(path)
    thread_mutex.unlock()
    
    return was_watching