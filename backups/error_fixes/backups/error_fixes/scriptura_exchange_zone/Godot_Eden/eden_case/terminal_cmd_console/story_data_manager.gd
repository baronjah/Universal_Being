extends Node
class_name StoryDataManager

"""
Story Data Manager
-----------------
A system for managing historical data, stories, and complex narrative structures
that integrate with the data sewer bridge pipeline.

Features:
- Historical data tracking across multiple time periods
- Token usage analytics and real-time monitoring
- Day cycle task management and scheduling
- Multi-driver storage integration
- Story complexity analysis and tracking
- Timeline visualization and chronological sorting
"""

# Signal declarations
signal history_recorded(entry_id, timestamp, category)
signal story_linked(story_id, history_ids)
signal token_consumed(amount, reason, task_id)
signal day_cycle_changed(old_cycle, new_cycle)
signal driver_status_changed(driver_id, status)

# Constants for story types and categories
const STORY_TYPES = {
    "NARRATIVE": 0,    # General narrative content
    "TECHNICAL": 1,    # Technical documentation
    "ANALYTICAL": 2,   # Data analysis stories
    "PERSONAL": 3,     # User-specific narratives
    "SYSTEM": 4        # System-generated stories
}

const HISTORY_CATEGORIES = {
    "ACTION": 0,       # User or system actions
    "EVENT": 1,        # Significant events
    "INSIGHT": 2,      # Discovered insights
    "MILESTONE": 3,    # Achieved milestones
    "ERROR": 4,        # Error conditions
    "RECOVERY": 5      # System recovery events
}

const DAY_CYCLE_PHASES = {
    "MORNING": 0,      # Planning and organization (0-6 hours)
    "MIDDAY": 1,       # Active work and processing (6-12 hours)
    "AFTERNOON": 2,    # Review and refinement (12-18 hours)
    "EVENING": 3       # Backup and maintenance (18-24 hours)
}

const DRIVER_TYPES = {
    "LOCAL": 0,        # Local filesystem storage
    "REMOTE": 1,       # Remote server storage
    "CLOUD": 2,        # Cloud service integration
    "MEMORY": 3,       # In-memory storage
    "HYBRID": 4        # Combined storage approach
}

# Configuration
var _config = {
    "token_tracking_enabled": true,
    "token_alert_threshold": 10000,
    "history_retention_days": 30,
    "auto_day_cycle": true,
    "cycle_duration_hours": 6,
    "default_driver": DRIVER_TYPES.LOCAL,
    "story_complexity_analysis": true,
    "max_tracked_stories": 1000,
    "max_history_entries": 10000,
    "timeline_visualization": true,
    "default_tokens_per_cycle": 100000,
    "token_buffer_percentage": 10
}

# Runtime variables
var _history_entries = {}
var _stories = {}
var _current_day_cycle = DAY_CYCLE_PHASES.MORNING
var _cycle_start_time = 0
var _available_drivers = {}
var _active_driver = null
var _token_usage = {
    "total": 0,
    "current_cycle": 0,
    "by_reason": {},
    "by_task": {},
    "by_day": {}
}
var _tasks = {}
var _current_task_id = ""
var _history_counter = 0
var _story_counter = 0
var _task_counter = 0
var _data_sewer_bridge = null

# Class definitions
class HistoryEntry:
    var id: String
    var timestamp: int
    var category: int
    var content: String
    var metadata = {}
    var tags = []
    var linked_stories = []
    var token_count: int = 0
    var complexity_score: float = 0.0
    
    func _init(p_id: String, p_category: int, p_content: String):
        id = p_id
        category = p_category
        content = p_content
        timestamp = OS.get_unix_time()
    
    func add_tag(tag: String) -> void:
        if not tags.has(tag):
            tags.append(tag)
    
    func link_story(story_id: String) -> void:
        if not linked_stories.has(story_id):
            linked_stories.append(story_id)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "timestamp": timestamp,
            "category": category,
            "content": content,
            "metadata": metadata,
            "tags": tags,
            "linked_stories": linked_stories,
            "token_count": token_count,
            "complexity_score": complexity_score
        }

class Story:
    var id: String
    var title: String
    var type: int
    var content: String
    var history_entries = []
    var created_at: int
    var updated_at: int
    var version: int = 1
    var metadata = {}
    var complexity_score: float = 0.0
    var token_count: int = 0
    var tags = []
    
    func _init(p_id: String, p_title: String, p_type: int, p_content: String):
        id = p_id
        title = p_title
        type = p_type
        content = p_content
        created_at = OS.get_unix_time()
        updated_at = created_at
    
    func add_history_entry(entry_id: String) -> void:
        if not history_entries.has(entry_id):
            history_entries.append(entry_id)
            updated_at = OS.get_unix_time()
    
    func update_content(new_content: String) -> void:
        content = new_content
        updated_at = OS.get_unix_time()
        version += 1
    
    func add_tag(tag: String) -> void:
        if not tags.has(tag):
            tags.append(tag)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "title": title,
            "type": type,
            "content": content,
            "history_entries": history_entries,
            "created_at": created_at,
            "updated_at": updated_at,
            "version": version,
            "metadata": metadata,
            "complexity_score": complexity_score,
            "token_count": token_count,
            "tags": tags
        }

class Task:
    var id: String
    var name: String
    var description: String
    var status: String = "pending"  # pending, in_progress, completed, cancelled
    var priority: int = 1  # 1 (lowest) to 5 (highest)
    var token_allocation: int
    var token_used: int = 0
    var stories = []
    var history_entries = []
    var created_at: int
    var started_at: int = 0
    var completed_at: int = 0
    var cycle_phase: int
    var dependencies = []
    var metadata = {}
    
    func _init(p_id: String, p_name: String, p_description: String, p_token_allocation: int, p_cycle_phase: int):
        id = p_id
        name = p_name
        description = p_description
        token_allocation = p_token_allocation
        cycle_phase = p_cycle_phase
        created_at = OS.get_unix_time()
    
    func start_task() -> void:
        status = "in_progress"
        started_at = OS.get_unix_time()
    
    func complete_task() -> void:
        status = "completed"
        completed_at = OS.get_unix_time()
    
    func cancel_task() -> void:
        status = "cancelled"
        completed_at = OS.get_unix_time()
    
    func add_token_usage(amount: int) -> void:
        token_used += amount
    
    func get_remaining_tokens() -> int:
        return token_allocation - token_used
    
    func add_story(story_id: String) -> void:
        if not stories.has(story_id):
            stories.append(story_id)
    
    func add_history_entry(entry_id: String) -> void:
        if not history_entries.has(entry_id):
            history_entries.append(entry_id)
    
    func add_dependency(task_id: String) -> void:
        if not dependencies.has(task_id):
            dependencies.append(task_id)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
            "description": description,
            "status": status,
            "priority": priority,
            "token_allocation": token_allocation,
            "token_used": token_used,
            "stories": stories,
            "history_entries": history_entries,
            "created_at": created_at,
            "started_at": started_at,
            "completed_at": completed_at,
            "cycle_phase": cycle_phase,
            "dependencies": dependencies,
            "metadata": metadata
        }

class Driver:
    var id: String
    var type: int
    var name: String
    var path: String = ""
    var connection_string: String = ""
    var status: String = "disconnected"  # disconnected, connected, error
    var metadata = {}
    var capabilities = []
    var last_connected: int = 0
    var error_message: String = ""
    
    func _init(p_id: String, p_type: int, p_name: String):
        id = p_id
        type = p_type
        name = p_name
    
    func connect_driver() -> bool:
        # Implementation would depend on driver type
        match type:
            DRIVER_TYPES.LOCAL:
                if path == "":
                    status = "error"
                    error_message = "No path specified for local driver"
                    return false
                    
                # Check if path exists
                var dir = Directory.new()
                if not dir.dir_exists(path):
                    dir.make_dir_recursive(path)
                
                status = "connected"
                last_connected = OS.get_unix_time()
                return true
                
            DRIVER_TYPES.REMOTE, DRIVER_TYPES.CLOUD:
                if connection_string == "":
                    status = "error"
                    error_message = "No connection string specified"
                    return false
                
                # In a real implementation, this would attempt a connection
                # For now, we'll simulate a successful connection
                status = "connected"
                last_connected = OS.get_unix_time()
                return true
                
            DRIVER_TYPES.MEMORY:
                status = "connected"
                last_connected = OS.get_unix_time()
                return true
                
            _:
                status = "error"
                error_message = "Unknown driver type"
                return false
    
    func disconnect_driver() -> void:
        status = "disconnected"
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "type": type,
            "name": name,
            "path": path,
            "connection_string": connection_string,
            "status": status,
            "metadata": metadata,
            "capabilities": capabilities,
            "last_connected": last_connected,
            "error_message": error_message
        }

# Initialization
func _ready():
    _cycle_start_time = OS.get_unix_time()
    _setup_default_driver()
    
    if _config.auto_day_cycle:
        _setup_day_cycle_timer()
    
    # Debug message
    print("StoryDataManager: Initialized with day cycle " + _get_cycle_name(_current_day_cycle))

# Setup the day cycle timer
func _setup_day_cycle_timer():
    var timer = Timer.new()
    timer.wait_time = _config.cycle_duration_hours * 3600  # Convert hours to seconds
    timer.one_shot = false
    timer.autostart = true
    timer.connect("timeout", self, "_on_day_cycle_timeout")
    add_child(timer)

# Setup default driver
func _setup_default_driver():
    var driver_id = "default_driver"
    var driver = Driver.new(driver_id, _config.default_driver, "Default Driver")
    
    match _config.default_driver:
        DRIVER_TYPES.LOCAL:
            driver.path = "user://story_data"
        DRIVER_TYPES.MEMORY:
            # No path needed for memory driver
            pass
        _:
            # For other driver types, additional setup would be required
            pass
    
    _available_drivers[driver_id] = driver
    
    # Connect the driver
    if driver.connect_driver():
        _active_driver = driver
        print("StoryDataManager: Connected to default driver")
    else:
        push_error("StoryDataManager: Failed to connect to default driver - " + driver.error_message)

# Process function for time-dependent functionality
func _process(delta):
    if _config.auto_day_cycle:
        _check_day_cycle()

# Public API Methods

# Record a new history entry
func record_history(category: int, content: String, metadata: Dictionary = {}, tags: Array = []) -> String:
    _history_counter += 1
    var entry_id = "history_" + str(_history_counter)
    
    var entry = HistoryEntry.new(entry_id, category, content)
    entry.metadata = metadata
    entry.token_count = _estimate_token_count(content)
    entry.complexity_score = _calculate_complexity(content)
    
    # Add tags
    for tag in tags:
        entry.add_tag(tag)
    
    # Store the entry
    _history_entries[entry_id] = entry
    
    # Track tokens
    if _config.token_tracking_enabled:
        _consume_tokens(entry.token_count, "history_recording", _current_task_id)
    
    # Track in current task if one is active
    if _current_task_id != "" and _tasks.has(_current_task_id):
        _tasks[_current_task_id].add_history_entry(entry_id)
    
    # Emit signal
    emit_signal("history_recorded", entry_id, entry.timestamp, category)
    
    return entry_id

# Create a new story
func create_story(title: String, type: int, content: String, linked_history_ids: Array = [], metadata: Dictionary = {}, tags: Array = []) -> String:
    _story_counter += 1
    var story_id = "story_" + str(_story_counter)
    
    var story = Story.new(story_id, title, type, content)
    story.metadata = metadata
    story.token_count = _estimate_token_count(content)
    story.complexity_score = _calculate_complexity(content)
    
    # Add tags
    for tag in tags:
        story.add_tag(tag)
    
    # Link history entries
    for history_id in linked_history_ids:
        if _history_entries.has(history_id):
            story.add_history_entry(history_id)
            _history_entries[history_id].link_story(story_id)
    
    # Store the story
    _stories[story_id] = story
    
    # Track tokens
    if _config.token_tracking_enabled:
        _consume_tokens(story.token_count, "story_creation", _current_task_id)
    
    # Track in current task if one is active
    if _current_task_id != "" and _tasks.has(_current_task_id):
        _tasks[_current_task_id].add_story(story_id)
    
    # Emit signal for each linked history entry
    for history_id in linked_history_ids:
        emit_signal("story_linked", story_id, history_id)
    
    return story_id

# Update an existing story
func update_story(story_id: String, new_content: String) -> bool:
    if not _stories.has(story_id):
        push_error("StoryDataManager: Story " + story_id + " not found")
        return false
    
    var story = _stories[story_id]
    var old_token_count = story.token_count
    var new_token_count = _estimate_token_count(new_content)
    
    # Update the story
    story.update_content(new_content)
    story.token_count = new_token_count
    story.complexity_score = _calculate_complexity(new_content)
    
    # Track token differential
    if _config.token_tracking_enabled:
        var token_diff = new_token_count - old_token_count
        if token_diff > 0:
            _consume_tokens(token_diff, "story_update", _current_task_id)
    
    return true

# Create a new task
func create_task(name: String, description: String, token_allocation: int, cycle_phase: int = -1, priority: int = 3) -> String:
    if cycle_phase == -1:
        cycle_phase = _current_day_cycle
    
    _task_counter += 1
    var task_id = "task_" + str(_task_counter)
    
    var task = Task.new(task_id, name, description, token_allocation, cycle_phase)
    task.priority = clamp(priority, 1, 5)
    
    # Store the task
    _tasks[task_id] = task
    
    return task_id

# Start a task
func start_task(task_id: String) -> bool:
    if not _tasks.has(task_id):
        push_error("StoryDataManager: Task " + task_id + " not found")
        return false
    
    var task = _tasks[task_id]
    
    # Check if task is already in progress
    if task.status == "in_progress":
        return true
    
    # Check if task was already completed
    if task.status == "completed" or task.status == "cancelled":
        push_error("StoryDataManager: Task " + task_id + " is already " + task.status)
        return false
    
    # Check dependencies
    for dep_id in task.dependencies:
        if _tasks.has(dep_id) and _tasks[dep_id].status != "completed":
            push_error("StoryDataManager: Dependency " + dep_id + " not completed")
            return false
    
    # Start the task
    task.start_task()
    
    # Set as current task
    _current_task_id = task_id
    
    # Record history
    record_history(
        HISTORY_CATEGORIES.ACTION,
        "Started task: " + task.name,
        {"task_id": task_id},
        ["task", "start"]
    )
    
    return true

# Complete a task
func complete_task(task_id: String) -> bool:
    if not _tasks.has(task_id):
        push_error("StoryDataManager: Task " + task_id + " not found")
        return false
    
    var task = _tasks[task_id]
    
    # Check if task is in progress
    if task.status != "in_progress":
        push_error("StoryDataManager: Task " + task_id + " is not in progress")
        return false
    
    # Complete the task
    task.complete_task()
    
    # Clear current task if this was it
    if _current_task_id == task_id:
        _current_task_id = ""
    
    # Record history
    record_history(
        HISTORY_CATEGORIES.MILESTONE,
        "Completed task: " + task.name,
        {"task_id": task_id, "token_used": task.token_used},
        ["task", "complete"]
    )
    
    return true

# Register a new driver
func register_driver(type: int, name: String, path: String = "", connection_string: String = "") -> String:
    var driver_id = "driver_" + str(_available_drivers.size() + 1)
    
    var driver = Driver.new(driver_id, type, name)
    driver.path = path
    driver.connection_string = connection_string
    
    # Set capabilities based on type
    match type:
        DRIVER_TYPES.LOCAL:
            driver.capabilities = ["read", "write", "delete"]
        DRIVER_TYPES.REMOTE:
            driver.capabilities = ["read", "write", "delete", "sync"]
        DRIVER_TYPES.CLOUD:
            driver.capabilities = ["read", "write", "delete", "sync", "version"]
        DRIVER_TYPES.MEMORY:
            driver.capabilities = ["read", "write", "delete", "fast"]
        DRIVER_TYPES.HYBRID:
            driver.capabilities = ["read", "write", "delete", "sync", "fallback"]
    
    # Store the driver
    _available_drivers[driver_id] = driver
    
    return driver_id

# Connect to a registered driver
func connect_to_driver(driver_id: String) -> bool:
    if not _available_drivers.has(driver_id):
        push_error("StoryDataManager: Driver " + driver_id + " not found")
        return false
    
    var driver = _available_drivers[driver_id]
    var old_status = driver.status
    
    var success = driver.connect_driver()
    
    if success:
        _active_driver = driver
        
        if old_status != driver.status:
            emit_signal("driver_status_changed", driver_id, driver.status)
    
    return success

# Set the data sewer bridge reference
func set_data_sewer_bridge(bridge) -> void:
    _data_sewer_bridge = bridge

# Get current day cycle information
func get_current_day_cycle() -> Dictionary:
    return {
        "cycle": _current_day_cycle,
        "name": _get_cycle_name(_current_day_cycle),
        "start_time": _cycle_start_time,
        "elapsed_time": OS.get_unix_time() - _cycle_start_time
    }

# Get token usage statistics
func get_token_usage() -> Dictionary:
    return _token_usage.duplicate(true)

# Get specific history entry
func get_history_entry(entry_id: String) -> Dictionary:
    if _history_entries.has(entry_id):
        return _history_entries[entry_id].to_dict()
    return {}

# Get specific story
func get_story(story_id: String) -> Dictionary:
    if _stories.has(story_id):
        return _stories[story_id].to_dict()
    return {}

# Get specific task
func get_task(task_id: String) -> Dictionary:
    if _tasks.has(task_id):
        return _tasks[task_id].to_dict()
    return {}

# Get history entries by tag
func get_history_by_tag(tag: String) -> Array:
    var result = []
    
    for entry_id in _history_entries:
        var entry = _history_entries[entry_id]
        if entry.tags.has(tag):
            result.append(entry.to_dict())
    
    return result

# Get stories by tag
func get_stories_by_tag(tag: String) -> Array:
    var result = []
    
    for story_id in _stories:
        var story = _stories[story_id]
        if story.tags.has(tag):
            result.append(story.to_dict())
    
    return result

# Get tasks for the current day cycle
func get_tasks_for_current_cycle() -> Array:
    var result = []
    
    for task_id in _tasks:
        var task = _tasks[task_id]
        if task.cycle_phase == _current_day_cycle:
            result.append(task.to_dict())
    
    return result

# Update configuration
func update_config(new_config: Dictionary) -> bool:
    for key in new_config:
        if _config.has(key):
            _config[key] = new_config[key]
    
    return true

# Advanced story queries
func query_stories(query: Dictionary) -> Array:
    var result = []
    
    # Filter stories based on query parameters
    for story_id in _stories:
        var story = _stories[story_id]
        var match_all = true
        
        for key in query:
            match key:
                "type":
                    if story.type != query.type:
                        match_all = false
                "min_complexity":
                    if story.complexity_score < query.min_complexity:
                        match_all = false
                "max_complexity":
                    if story.complexity_score > query.max_complexity:
                        match_all = false
                "tags":
                    for tag in query.tags:
                        if not story.tags.has(tag):
                            match_all = false
                "created_after":
                    if story.created_at < query.created_after:
                        match_all = false
                "updated_after":
                    if story.updated_at < query.updated_after:
                        match_all = false
                "min_token_count":
                    if story.token_count < query.min_token_count:
                        match_all = false
                "max_token_count":
                    if story.token_count > query.max_token_count:
                        match_all = false
        
        if match_all:
            result.append(story.to_dict())
    
    return result

# Internal Implementation Methods

# Consume tokens and track usage
func _consume_tokens(amount: int, reason: String, task_id: String = "") -> void:
    _token_usage.total += amount
    _token_usage.current_cycle += amount
    
    # Track by reason
    if not _token_usage.by_reason.has(reason):
        _token_usage.by_reason[reason] = 0
    _token_usage.by_reason[reason] += amount
    
    # Track by task
    if task_id != "":
        if not _token_usage.by_task.has(task_id):
            _token_usage.by_task[task_id] = 0
        _token_usage.by_task[task_id] += amount
        
        # Update task token usage
        if _tasks.has(task_id):
            _tasks[task_id].add_token_usage(amount)
    
    # Track by day
    var current_day = str(OS.get_date().year) + "-" + str(OS.get_date().month) + "-" + str(OS.get_date().day)
    if not _token_usage.by_day.has(current_day):
        _token_usage.by_day[current_day] = 0
    _token_usage.by_day[current_day] += amount
    
    # Emit signal
    emit_signal("token_consumed", amount, reason, task_id)
    
    # Check alert threshold
    if _token_usage.current_cycle >= _config.token_alert_threshold:
        # In a real implementation, this would trigger alerts
        if _config.debug_mode:
            print("StoryDataManager: Token alert threshold reached - " + str(_token_usage.current_cycle) + " tokens used")

# Estimate token count for a text string
func _estimate_token_count(text: String) -> int:
    # Simple estimation: roughly 4 characters per token on average
    return int(max(1, text.length() / 4))

# Calculate text complexity
func _calculate_complexity(text: String) -> float:
    # Simple complexity metric based on length, unique words, and special characters
    var length_factor = min(1.0, text.length() / 1000.0)  # Scale with text length up to 1000 chars
    
    # Count unique words
    var words = text.split(" ", false)
    var unique_words = {}
    for word in words:
        unique_words[word.to_lower()] = true
    
    var vocabulary_factor = min(1.0, unique_words.size() / 200.0)  # Scale with vocabulary up to 200 words
    
    # Count special characters
    var special_char_count = 0
    for i in range(text.length()):
        var c = text[i]
        if not c.is_valid_identifier() and not c.is_valid_integer() and c != " ":
            special_char_count += 1
    
    var special_char_factor = min(1.0, special_char_count / 100.0)  # Scale with special chars up to 100
    
    # Calculate overall complexity (0.0 to 5.0 scale)
    return (length_factor * 2.0 + vocabulary_factor * 2.0 + special_char_factor) * 5.0 / 5.0

# Check and potentially update the day cycle
func _check_day_cycle():
    var current_time = OS.get_unix_time()
    var elapsed_hours = (current_time - _cycle_start_time) / 3600.0
    
    if elapsed_hours >= _config.cycle_duration_hours:
        _advance_day_cycle()

# Advance to the next day cycle
func _advance_day_cycle():
    var old_cycle = _current_day_cycle
    _current_day_cycle = (_current_day_cycle + 1) % DAY_CYCLE_PHASES.size()
    _cycle_start_time = OS.get_unix_time()
    
    # Reset current cycle token usage
    _token_usage.current_cycle = 0
    
    # Emit signal
    emit_signal("day_cycle_changed", old_cycle, _current_day_cycle)
    
    if _config.debug_mode:
        print("StoryDataManager: Advanced to day cycle " + _get_cycle_name(_current_day_cycle))

# Timer callback for day cycle
func _on_day_cycle_timeout():
    _advance_day_cycle()

# Get the name of a day cycle
func _get_cycle_name(cycle: int) -> String:
    for name in DAY_CYCLE_PHASES:
        if DAY_CYCLE_PHASES[name] == cycle:
            return name
    return "UNKNOWN"

# Save history and stories to active driver
func _save_data() -> bool:
    if not _active_driver or _active_driver.status != "connected":
        push_error("StoryDataManager: No active driver connected")
        return false
    
    # Only drivers with write capability can save data
    if not _active_driver.capabilities.has("write"):
        push_error("StoryDataManager: Active driver does not support writing")
        return false
    
    var result = true
    
    match _active_driver.type:
        DRIVER_TYPES.LOCAL:
            # Save to local filesystem
            result = _save_to_filesystem(_active_driver.path)
        
        DRIVER_TYPES.MEMORY:
            # Memory driver doesn't need to save data persistently
            result = true
        
        DRIVER_TYPES.REMOTE, DRIVER_TYPES.CLOUD, DRIVER_TYPES.HYBRID:
            # In a real implementation, this would save to remote/cloud storage
            result = true
    
    return result

# Save data to filesystem
func _save_to_filesystem(base_path: String) -> bool:
    # Create base directory if it doesn't exist
    var dir = Directory.new()
    if not dir.dir_exists(base_path):
        dir.make_dir_recursive(base_path)
    
    # Save history entries
    var history_data = {}
    for entry_id in _history_entries:
        history_data[entry_id] = _history_entries[entry_id].to_dict()
    
    var history_file = File.new()
    var history_path = base_path + "/history.json"
    var history_error = history_file.open(history_path, File.WRITE)
    
    if history_error != OK:
        push_error("StoryDataManager: Failed to open history file for writing")
        return false
    
    history_file.store_string(JSON.print(history_data))
    history_file.close()
    
    # Save stories
    var stories_data = {}
    for story_id in _stories:
        stories_data[story_id] = _stories[story_id].to_dict()
    
    var stories_file = File.new()
    var stories_path = base_path + "/stories.json"
    var stories_error = stories_file.open(stories_path, File.WRITE)
    
    if stories_error != OK:
        push_error("StoryDataManager: Failed to open stories file for writing")
        return false
    
    stories_file.store_string(JSON.print(stories_data))
    stories_file.close()
    
    # Save tasks
    var tasks_data = {}
    for task_id in _tasks:
        tasks_data[task_id] = _tasks[task_id].to_dict()
    
    var tasks_file = File.new()
    var tasks_path = base_path + "/tasks.json"
    var tasks_error = tasks_file.open(tasks_path, File.WRITE)
    
    if tasks_error != OK:
        push_error("StoryDataManager: Failed to open tasks file for writing")
        return false
    
    tasks_file.store_string(JSON.print(tasks_data))
    tasks_file.close()
    
    # Save token usage
    var token_file = File.new()
    var token_path = base_path + "/token_usage.json"
    var token_error = token_file.open(token_path, File.WRITE)
    
    if token_error != OK:
        push_error("StoryDataManager: Failed to open token usage file for writing")
        return false
    
    token_file.store_string(JSON.print(_token_usage))
    token_file.close()
    
    return true

# Load data from active driver
func _load_data() -> bool:
    if not _active_driver or _active_driver.status != "connected":
        push_error("StoryDataManager: No active driver connected")
        return false
    
    # Only drivers with read capability can load data
    if not _active_driver.capabilities.has("read"):
        push_error("StoryDataManager: Active driver does not support reading")
        return false
    
    var result = true
    
    match _active_driver.type:
        DRIVER_TYPES.LOCAL:
            # Load from local filesystem
            result = _load_from_filesystem(_active_driver.path)
        
        DRIVER_TYPES.MEMORY:
            # Memory driver doesn't have persistent data to load
            result = true
        
        DRIVER_TYPES.REMOTE, DRIVER_TYPES.CLOUD, DRIVER_TYPES.HYBRID:
            # In a real implementation, this would load from remote/cloud storage
            result = true
    
    return result

# Load data from filesystem
func _load_from_filesystem(base_path: String) -> bool:
    # Check if directory exists
    var dir = Directory.new()
    if not dir.dir_exists(base_path):
        push_error("StoryDataManager: Data directory does not exist")
        return false
    
    var loaded_all = true
    
    # Load history entries
    var history_file = File.new()
    var history_path = base_path + "/history.json"
    
    if history_file.file_exists(history_path):
        var history_error = history_file.open(history_path, File.READ)
        
        if history_error == OK:
            var history_text = history_file.get_as_text()
            history_file.close()
            
            var parse_result = JSON.parse(history_text)
            if parse_result.error == OK:
                var history_data = parse_result.result
                
                # Create history entries from loaded data
                for entry_id in history_data:
                    var data = history_data[entry_id]
                    var entry = HistoryEntry.new(data.id, data.category, data.content)
                    
                    # Restore properties
                    entry.timestamp = data.timestamp
                    entry.metadata = data.metadata
                    entry.tags = data.tags
                    entry.linked_stories = data.linked_stories
                    entry.token_count = data.token_count
                    entry.complexity_score = data.complexity_score
                    
                    _history_entries[entry_id] = entry
                
                # Set history counter to max ID
                _history_counter = _history_entries.size()
            else:
                push_error("StoryDataManager: Error parsing history data")
                loaded_all = false
        else:
            push_error("StoryDataManager: Error opening history file")
            loaded_all = false
    }
    
    # Load stories
    var stories_file = File.new()
    var stories_path = base_path + "/stories.json"
    
    if stories_file.file_exists(stories_path):
        var stories_error = stories_file.open(stories_path, File.READ)
        
        if stories_error == OK:
            var stories_text = stories_file.get_as_text()
            stories_file.close()
            
            var parse_result = JSON.parse(stories_text)
            if parse_result.error == OK:
                var stories_data = parse_result.result
                
                # Create stories from loaded data
                for story_id in stories_data:
                    var data = stories_data[story_id]
                    var story = Story.new(data.id, data.title, data.type, data.content)
                    
                    # Restore properties
                    story.history_entries = data.history_entries
                    story.created_at = data.created_at
                    story.updated_at = data.updated_at
                    story.version = data.version
                    story.metadata = data.metadata
                    story.complexity_score = data.complexity_score
                    story.token_count = data.token_count
                    story.tags = data.tags
                    
                    _stories[story_id] = story
                
                # Set story counter to max ID
                _story_counter = _stories.size()
            else:
                push_error("StoryDataManager: Error parsing stories data")
                loaded_all = false
        else:
            push_error("StoryDataManager: Error opening stories file")
            loaded_all = false
    }
    
    # Load tasks
    var tasks_file = File.new()
    var tasks_path = base_path + "/tasks.json"
    
    if tasks_file.file_exists(tasks_path):
        var tasks_error = tasks_file.open(tasks_path, File.READ)
        
        if tasks_error == OK:
            var tasks_text = tasks_file.get_as_text()
            tasks_file.close()
            
            var parse_result = JSON.parse(tasks_text)
            if parse_result.error == OK:
                var tasks_data = parse_result.result
                
                # Create tasks from loaded data
                for task_id in tasks_data:
                    var data = tasks_data[task_id]
                    var task = Task.new(
                        data.id,
                        data.name,
                        data.description,
                        data.token_allocation,
                        data.cycle_phase
                    )
                    
                    # Restore properties
                    task.status = data.status
                    task.priority = data.priority
                    task.token_used = data.token_used
                    task.stories = data.stories
                    task.history_entries = data.history_entries
                    task.created_at = data.created_at
                    task.started_at = data.started_at
                    task.completed_at = data.completed_at
                    task.dependencies = data.dependencies
                    task.metadata = data.metadata
                    
                    _tasks[task_id] = task
                
                # Set task counter to max ID
                _task_counter = _tasks.size()
            else:
                push_error("StoryDataManager: Error parsing tasks data")
                loaded_all = false
        else:
            push_error("StoryDataManager: Error opening tasks file")
            loaded_all = false
    }
    
    # Load token usage
    var token_file = File.new()
    var token_path = base_path + "/token_usage.json"
    
    if token_file.file_exists(token_path):
        var token_error = token_file.open(token_path, File.READ)
        
        if token_error == OK:
            var token_text = token_file.get_as_text()
            token_file.close()
            
            var parse_result = JSON.parse(token_text)
            if parse_result.error == OK:
                _token_usage = parse_result.result
            else:
                push_error("StoryDataManager: Error parsing token usage data")
                loaded_all = false
        else:
            push_error("StoryDataManager: Error opening token usage file")
            loaded_all = false
    }
    
    return loaded_all

# Example usage:
# var story_manager = StoryDataManager.new()
# add_child(story_manager)
# 
# # Create a local driver
# var driver_id = story_manager.register_driver(
#     StoryDataManager.DRIVER_TYPES.LOCAL,
#     "Local Storage",
#     "user://story_data"
# )
# 
# story_manager.connect_to_driver(driver_id)
# 
# # Create a task for token management
# var task_id = story_manager.create_task(
#     "Data Analysis",
#     "Analyze and process collected data",
#     10000,  # Token allocation
#     StoryDataManager.DAY_CYCLE_PHASES.MIDDAY,
#     4  # High priority
# )
# 
# story_manager.start_task(task_id)
# 
# # Record a history entry
# var history_id = story_manager.record_history(
#     StoryDataManager.HISTORY_CATEGORIES.EVENT,
#     "System detected unusual data pattern",
#     {"pattern_type": "anomaly", "confidence": 0.87},
#     ["data", "anomaly", "pattern"]
# )
# 
# # Create a story with the history entry
# var story_id = story_manager.create_story(
#     "Anomaly Detection Report",
#     StoryDataManager.STORY_TYPES.ANALYTICAL,
#     "The system detected an unusual pattern...",
#     [history_id],
#     {"priority": "high", "action_required": true},
#     ["report", "anomaly", "action-required"]
# )
# 
# # Get token usage stats
# var token_stats = story_manager.get_token_usage()
# print("Total tokens used: " + str(token_stats.total))
# 
# # Complete the task
# story_manager.complete_task(task_id)