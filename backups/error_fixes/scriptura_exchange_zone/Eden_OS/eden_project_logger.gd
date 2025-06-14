extends Node

class_name EdenProjectLogger

# Logging constants and paths
const LOG_DIR = "/mnt/c/Users/Percision 15/Eden_OS/logs/"
const STORY_DIR = "/mnt/c/Users/Percision 15/Eden_OS/stories/"
const VISUALIZATION_DIR = "/mnt/c/Users/Percision 15/Eden_OS/visualizations/"
const COLOR_MAPPING_FILE = "/mnt/c/Users/Percision 15/Eden_OS/color_mapping.json"

# Story and log format settings
var story_format = {
    "timestamp_format": "%Y-%m-%d %H:%M:%S",
    "day_counter": true,
    "include_emotions": true,
    "include_shapes": true,
    "include_colors": true,
    "auto_link_code": true
}

# Project statistics
var project_stats = {
    "start_date": "",
    "days_active": 0,
    "log_entries": 0,
    "stories_created": 0,
    "emotions_tracked": 0,
    "shapes_visualized": 0,
    "color_palettes": 0,
    "code_references": 0
}

# State tracking
var current_day = 0
var last_date = ""
var current_story_id = ""
var active_emotions = []
var active_shapes = []
var active_colors = []
var godot_references = []

# System connections
var ethereal_engine = null
var turn_system = null
var api_orchestrator = null

# Signals
signal log_entry_created(entry_id, entry_type, content)
signal story_updated(story_id, day, content)
signal visualization_generated(vis_id, shape_data, color_data)
signal day_changed(old_day, new_day)

func _ready():
    # Create necessary directories if they don't exist
    _ensure_directories()
    
    # Load existing project stats if available
    _load_project_stats()
    
    # Initialize current day based on previous logs
    _initialize_day_counter()
    
    # Connect to other systems
    _connect_to_systems()
    
    print("Eden Project Logger initialized")
    print("Current day: " + str(current_day))
    print("Log directory: " + LOG_DIR)
    print("Story directory: " + STORY_DIR)

func _ensure_directories():
    var dir = Directory.new()
    
    if not dir.dir_exists(LOG_DIR):
        dir.make_dir_recursive(LOG_DIR)
    
    if not dir.dir_exists(STORY_DIR):
        dir.make_dir_recursive(STORY_DIR)
    
    if not dir.dir_exists(VISUALIZATION_DIR):
        dir.make_dir_recursive(VISUALIZATION_DIR)

func _load_project_stats():
    var stats_path = LOG_DIR + "project_stats.json"
    var file = File.new()
    
    if file.file_exists(stats_path):
        file.open(stats_path, File.READ)
        var content = file.get_as_text()
        file.close()
        
        var result = JSON.parse(content)
        if result.error == OK:
            project_stats = result.result
            print("Loaded project statistics from: " + stats_path)
        else:
            print("Error parsing project statistics: " + result.error_string)
            _save_project_stats()
    else:
        # Initialize stats with defaults
        project_stats.start_date = _format_date(OS.get_datetime())
        _save_project_stats()

func _save_project_stats():
    var stats_path = LOG_DIR + "project_stats.json"
    var file = File.new()
    
    file.open(stats_path, File.WRITE)
    file.store_string(JSON.print(project_stats, "  "))
    file.close()
    
    print("Saved project statistics to: " + stats_path)

func _initialize_day_counter():
    # Check the last log date
    var dir = Directory.new()
    var latest_log = ""
    var latest_time = 0
    
    if dir.open(LOG_DIR) == OK:
        dir.list_dir_begin(true)
        var file_name = dir.get_next()
        
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(".json") and file_name != "project_stats.json":
                var file_path = LOG_DIR + file_name
                var modified_time = dir.get_modified_time(file_path)
                
                if modified_time > latest_time:
                    latest_time = modified_time
                    latest_log = file_path
            
            file_name = dir.get_next()
    
    if latest_log != "":
        var file = File.new()
        file.open(latest_log, File.READ)
        var content = file.get_as_text()
        file.close()
        
        var result = JSON.parse(content)
        if result.error == OK:
            var log_data = result.result
            
            if log_data.has("day"):
                current_day = log_data.day
            
            if log_data.has("date"):
                last_date = log_data.date
        
        # Check if this is a new day
        var current_date = _format_date(OS.get_datetime())
        if current_date != last_date:
            current_day += 1
            emit_signal("day_changed", current_day - 1, current_day)
            print("New day detected: Day " + str(current_day))
            
            # Update project stats
            project_stats.days_active = current_day
            _save_project_stats()
        
        last_date = current_date
    else:
        # First run, initialize day 1
        current_day = 1
        last_date = _format_date(OS.get_datetime())
        
        # Create first log entry
        create_log_entry("system", "Eden Project initialized on day 1", {})
        
        # Update project stats
        project_stats.days_active = 1
        _save_project_stats()

func _connect_to_systems():
    # Try to connect to Ethereal Engine
    ethereal_engine = get_node_or_null("/root/EtherealEngine")
    if ethereal_engine:
        print("Connected to Ethereal Engine")
        
        # Connect signals
        if ethereal_engine.has_signal("shape_created"):
            ethereal_engine.connect("shape_created", self, "_on_shape_created")
        
        if ethereal_engine.has_signal("color_palette_changed"):
            ethereal_engine.connect("color_palette_changed", self, "_on_color_palette_changed")
    
    # Try to find a Turn System
    turn_system = get_node_or_null("/root/TurnIntegrator")
    if not turn_system:
        turn_system = get_node_or_null("/root/TurnPrioritySystem")
    
    if turn_system:
        print("Connected to " + turn_system.get_class())
        
        # Connect appropriate signals
        if turn_system is TurnIntegrator and turn_system.has_signal("turn_integrated"):
            turn_system.connect("turn_integrated", self, "_on_turn_integrated")
        elif turn_system is TurnPrioritySystem and turn_system.has_signal("turn_advanced"):
            turn_system.connect("turn_advanced", self, "_on_turn_advanced")
    
    # Try to find API Orchestrator
    api_orchestrator = get_node_or_null("/root/APIOrchestrator")
    if api_orchestrator:
        print("Connected to API Orchestrator")
        
        # Connect signals
        if api_orchestrator.has_signal("emotion_detected"):
            api_orchestrator.connect("emotion_detected", self, "_on_emotion_detected")

func create_log_entry(entry_type, content, metadata = {}):
    var timestamp = OS.get_datetime()
    var entry_id = str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    # Create entry object
    var entry = {
        "id": entry_id,
        "type": entry_type,
        "content": content,
        "timestamp": timestamp,
        "timestamp_str": _format_datetime(timestamp),
        "day": current_day,
        "date": _format_date(timestamp),
        "metadata": metadata
    }
    
    # Add entry-type specific data
    match entry_type:
        "emotion":
            if not entry.metadata.has("emotions"):
                entry.metadata.emotions = []
            active_emotions = entry.metadata.emotions
        "shape":
            if not entry.metadata.has("shapes"):
                entry.metadata.shapes = []
            active_shapes = entry.metadata.shapes
        "color":
            if not entry.metadata.has("colors"):
                entry.metadata.colors = []
            active_colors = entry.metadata.colors
        "code":
            if not entry.metadata.has("references"):
                entry.metadata.references = []
            godot_references = entry.metadata.references
    
    # Save entry to log file
    var log_path = LOG_DIR + "day_" + str(current_day) + "_" + entry_id + ".json"
    var file = File.new()
    file.open(log_path, File.WRITE)
    file.store_string(JSON.print(entry, "  "))
    file.close()
    
    # Update project stats
    project_stats.log_entries += 1
    
    if entry_type == "emotion":
        project_stats.emotions_tracked += 1
    elif entry_type == "shape":
        project_stats.shapes_visualized += 1
    elif entry_type == "color":
        project_stats.color_palettes += 1
    elif entry_type == "code":
        project_stats.code_references += 1
    
    _save_project_stats()
    
    # Emit signal
    emit_signal("log_entry_created", entry_id, entry_type, content)
    
    print("Created log entry: " + entry_type + " - " + content.substr(0, 40) + (content.length() > 40 ? "..." : ""))
    
    # Update the current story
    update_current_story(entry)
    
    return entry_id

func update_current_story(log_entry):
    # If no current story, create one
    if current_story_id.empty() or _should_create_new_story():
        current_story_id = _create_new_story()
    
    # Load current story
    var story = _load_story(current_story_id)
    
    # Add log entry content to story
    var story_entry = {
        "id": log_entry.id,
        "type": log_entry.type,
        "content": log_entry.content,
        "time": log_entry.timestamp_str
    }
    
    # Add type-specific data to story entry
    match log_entry.type:
        "emotion":
            story_entry.emotions = log_entry.metadata.emotions if log_entry.metadata.has("emotions") else []
        "shape":
            story_entry.shapes = log_entry.metadata.shapes if log_entry.metadata.has("shapes") else []
        "color":
            story_entry.colors = log_entry.metadata.colors if log_entry.metadata.has("colors") else []
        "code":
            story_entry.references = log_entry.metadata.references if log_entry.metadata.has("references") else []
    
    # Add entry to story entries
    story.entries.append(story_entry)
    
    # Update last modified timestamp
    story.last_modified = log_entry.timestamp_str
    
    # Save updated story
    _save_story(story)
    
    # Emit signal
    emit_signal("story_updated", current_story_id, current_day, story_entry.content)
    
    return current_story_id

func _create_new_story():
    var timestamp = OS.get_datetime()
    var story_id = "story_" + str(current_day) + "_" + str(OS.get_unix_time())
    
    # Create new story object
    var story = {
        "id": story_id,
        "title": "Eden Project - Day " + str(current_day),
        "created": _format_datetime(timestamp),
        "last_modified": _format_datetime(timestamp),
        "day": current_day,
        "entries": []
    }
    
    # Save story
    _save_story(story)
    
    # Update project stats
    project_stats.stories_created += 1
    _save_project_stats()
    
    print("Created new story: " + story.title)
    
    return story_id

func _save_story(story):
    var story_path = STORY_DIR + story.id + ".json"
    var file = File.new()
    
    file.open(story_path, File.WRITE)
    file.store_string(JSON.print(story, "  "))
    file.close()
    
    # Also create a readable text version
    _create_story_text_file(story)
    
    print("Saved story: " + story.title)

func _create_story_text_file(story):
    var text_path = STORY_DIR + story.id + ".txt"
    var file = File.new()
    
    file.open(text_path, File.WRITE)
    
    # Write story header
    file.store_line("=================================")
    file.store_line(story.title)
    file.store_line("Created: " + story.created)
    file.store_line("Last Modified: " + story.last_modified)
    file.store_line("=================================")
    file.store_line("")
    
    # Write entries
    for entry in story.entries:
        file.store_line("[" + entry.time + "] " + entry.type.to_upper())
        file.store_line(entry.content)
        
        # Add type-specific information
        if entry.type == "emotion" and entry.has("emotions") and story_format.include_emotions:
            file.store_line("Emotions: " + str(entry.emotions))
        
        if entry.type == "shape" and entry.has("shapes") and story_format.include_shapes:
            file.store_line("Shapes: " + str(entry.shapes))
            
        if entry.type == "color" and entry.has("colors") and story_format.include_colors:
            file.store_line("Colors: " + str(entry.colors))
            
        if entry.type == "code" and entry.has("references") and story_format.auto_link_code:
            file.store_line("Code References: " + str(entry.references))
        
        file.store_line("-----------------------------------")
        file.store_line("")
    
    file.close()
    
    print("Created text version of story: " + text_path)

func _load_story(story_id):
    var story_path = STORY_DIR + story_id + ".json"
    var file = File.new()
    
    if file.file_exists(story_path):
        file.open(story_path, File.READ)
        var content = file.get_as_text()
        file.close()
        
        var result = JSON.parse(content)
        if result.error == OK:
            return result.result
    
    # Return empty story if file doesn't exist or can't be parsed
    return {
        "id": story_id,
        "title": "Eden Project - Day " + str(current_day),
        "created": _format_datetime(OS.get_datetime()),
        "last_modified": _format_datetime(OS.get_datetime()),
        "day": current_day,
        "entries": []
    }

func _should_create_new_story():
    # Create a new story if:
    # 1. The day has changed
    # 2. The current story has too many entries
    
    if current_story_id.empty():
        return true
    
    var story = _load_story(current_story_id)
    
    if story.day != current_day:
        return true
    
    if story.entries.size() >= 100:  # Max entries per story
        return true
    
    return false

func generate_visualization(shape_data = null, color_data = null):
    # If no shape data provided, use active shapes
    if shape_data == null:
        shape_data = active_shapes
    
    # If no color data provided, use active colors
    if color_data == null:
        color_data = active_colors
    
    # If still empty, generate some defaults
    if shape_data.size() == 0:
        shape_data = ["sphere", "cube", "cylinder"]
    
    if color_data.size() == 0:
        color_data = [
            Color(1, 0, 0),  # Red
            Color(0, 1, 0),  # Green
            Color(0, 0, 1)   # Blue
        ]
    
    var vis_id = "vis_" + str(OS.get_unix_time())
    var vis_data = {
        "id": vis_id,
        "shapes": shape_data,
        "colors": color_data,
        "timestamp": _format_datetime(OS.get_datetime()),
        "day": current_day
    }
    
    # Save visualization data
    var vis_path = VISUALIZATION_DIR + vis_id + ".json"
    var file = File.new()
    file.open(vis_path, File.WRITE)
    file.store_string(JSON.print(vis_data, "  "))
    file.close()
    
    # Try to send to Ethereal Engine
    if ethereal_engine and ethereal_engine.has_method("create_shapes_from_data"):
        ethereal_engine.create_shapes_from_data(vis_data)
    
    # Emit signal
    emit_signal("visualization_generated", vis_id, shape_data, color_data)
    
    print("Generated visualization: " + vis_id)
    
    # Log the visualization creation
    create_log_entry("visualization", "Created 3D visualization with " + str(shape_data.size()) + " shapes and " + str(color_data.size()) + " colors", {
        "visualization_id": vis_id,
        "shapes": shape_data,
        "colors": color_data
    })
    
    return vis_id

func add_godot_reference(file_path, line_number, description):
    var reference = {
        "file": file_path,
        "line": line_number,
        "description": description,
        "timestamp": _format_datetime(OS.get_datetime())
    }
    
    # Add to references list
    godot_references.append(reference)
    
    # Log the reference
    create_log_entry("code", "Added Godot code reference: " + description, {
        "references": [reference]
    })
    
    print("Added Godot code reference: " + description)
    return reference

func add_active_emotion(emotion, intensity = 1.0, source = "manual"):
    var emotion_data = {
        "emotion": emotion,
        "intensity": intensity,
        "source": source,
        "timestamp": _format_datetime(OS.get_datetime())
    }
    
    # Add to active emotions
    active_emotions.append(emotion_data)
    
    # Keep only the last 10 emotions
    if active_emotions.size() > 10:
        active_emotions.remove(0)
    
    # Log the emotion
    create_log_entry("emotion", "Detected emotion: " + emotion + " with intensity " + str(intensity) + " from " + source, {
        "emotions": [emotion_data]
    })
    
    print("Added active emotion: " + emotion)
    return emotion_data

func add_active_shape(shape_name, dimensions = Vector3(1, 1, 1), position = Vector3(0, 0, 0)):
    var shape_data = {
        "name": shape_name,
        "dimensions": dimensions,
        "position": position,
        "timestamp": _format_datetime(OS.get_datetime())
    }
    
    # Add to active shapes
    active_shapes.append(shape_data)
    
    # Keep only the last 10 shapes
    if active_shapes.size() > 10:
        active_shapes.remove(0)
    
    # Log the shape
    create_log_entry("shape", "Added shape: " + shape_name, {
        "shapes": [shape_data]
    })
    
    print("Added active shape: " + shape_name)
    return shape_data

func add_active_color(color_name, color_value = Color(1, 1, 1)):
    var color_data = {
        "name": color_name,
        "value": color_value,
        "timestamp": _format_datetime(OS.get_datetime())
    }
    
    # Add to active colors
    active_colors.append(color_data)
    
    # Keep only the last 10 colors
    if active_colors.size() > 10:
        active_colors.remove(0)
    
    # Log the color
    create_log_entry("color", "Added color: " + color_name, {
        "colors": [color_data]
    })
    
    print("Added active color: " + color_name)
    return color_data

func get_active_elements():
    return {
        "emotions": active_emotions,
        "shapes": active_shapes,
        "colors": active_colors,
        "references": godot_references
    }

func get_daily_stories(day = null):
    if day == null:
        day = current_day
    
    var stories = []
    var dir = Directory.new()
    
    if dir.open(STORY_DIR) == OK:
        dir.list_dir_begin(true)
        var file_name = dir.get_next()
        
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(".json"):
                var story = _load_story(file_name.replace(".json", ""))
                if story.day == day:
                    stories.append(story)
            
            file_name = dir.get_next()
    }
    
    return stories

func _on_shape_created(shape_id, shape_type, dimensions):
    # Called when Ethereal Engine creates a shape
    add_active_shape(shape_type, dimensions)

func _on_color_palette_changed(palette_id, colors):
    # Called when Ethereal Engine changes color palette
    for color in colors:
        add_active_color(color.name, color.value)

func _on_turn_integrated(turn_number, game_dimension):
    # Called when TurnIntegrator integrates a turn
    create_log_entry("turn", "Turn integrated: " + turn_number + " with dimension " + str(game_dimension), {
        "turn_number": turn_number,
        "dimension": game_dimension
    })

func _on_turn_advanced(turn_number, turn_lines):
    # Called when TurnPrioritySystem advances a turn
    create_log_entry("turn", "Turn advanced to: " + turn_number, {
        "turn_number": turn_number,
        "turn_lines": turn_lines
    })

func _on_emotion_detected(source, emotion, intensity, timestamp):
    # Called when API Orchestrator detects emotion
    add_active_emotion(emotion, intensity, source)

func _format_datetime(datetime):
    return str(datetime.year) + "-" + str(datetime.month).pad_zeros(2) + "-" + str(datetime.day).pad_zeros(2) + " " + \
           str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2)

func _format_date(datetime):
    return str(datetime.year) + "-" + str(datetime.month).pad_zeros(2) + "-" + str(datetime.day).pad_zeros(2)