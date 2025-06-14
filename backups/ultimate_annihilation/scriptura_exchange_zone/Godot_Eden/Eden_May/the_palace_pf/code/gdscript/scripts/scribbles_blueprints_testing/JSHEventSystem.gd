extends Node
class_name JSHEventSystem

# The JSHEventSystem handles communication between different components of the system
# It provides a central event bus for publishing and subscribing to events

# Singleton instance
static var _instance = null
static func get_instance() -> JSHEventSystem:
	if not _instance:
		_instance = JSHEventSystem.new()
	return _instance

# Signal for event broadcasting
signal event_emitted(event_name, event_data)

# Event subscribers - maps event names to arrays of callbacks
# Format: {event_name: [EventSubscriber]}
var _subscribers = {}

# Event channels - groups of related events
# Format: {channel_name: [event_name]}
var _channels = {}

# Event history - for debugging and replay
# Format: [EventRecord]
var _event_history = []

# Maximum history size
var max_history_size = 100

# Event logging level
# 0 = None, 1 = Errors only, 2 = Important events, 3 = All events
var logging_level = 2

# Event subscriber inner class
class EventSubscriber:
	var id: String
	var callback: Callable
	var filter_func: Callable
	var priority: int
	var one_time: bool
	var enabled: bool
	
	func _init(p_id: String, p_callback: Callable, p_filter_func: Callable = Callable(), 
	           p_priority: int = 0, p_one_time: bool = false):
		id = p_id
		callback = p_callback
		filter_func = p_filter_func
		priority = p_priority
		one_time = p_one_time
		enabled = true

# Event record inner class
class EventRecord:
	var timestamp: float
	var event_name: String
	var event_data: Dictionary
	
	func _init(p_event_name: String, p_event_data: Dictionary):
		timestamp = Time.get_ticks_msec() / 1000.0
		event_name = p_event_name
		event_data = p_event_data.duplicate(true)

func _init():
	# Initialize default channels
	if not _instance:
		_setup_default_channels()

func _setup_default_channels() -> void:
	# Define standard event channels
	create_channel("entity", [
		"entity_created",
		"entity_deleted",
		"entity_updated",
		"entity_transformed",
		"entity_evolved",
		"entity_moved",
		"entity_split",
		"entity_merged"
	])
	
	create_channel("database", [
		"database_initialized",
		"database_shutdown",
		"entity_saved",
		"entity_loaded",
		"query_executed",
		"transaction_started",
		"transaction_committed",
		"transaction_rolled_back"
	])
	
	create_channel("spatial", [
		"zone_created",
		"zone_deleted",
		"zone_activated",
		"zone_deactivated",
		"entity_entered_zone",
		"entity_exited_zone",
		"zone_loaded",
		"zone_unloaded"
	])
	
	create_channel("system", [
		"system_initialized",
		"system_shutdown",
		"error_occurred",
		"warning_issued",
		"performance_threshold_exceeded",
		"thread_started",
		"thread_stopped"
	])
	
	create_channel("ui", [
		"console_command_executed",
		"visualization_changed",
		"ui_configuration_changed"
	])

# Subscribe to an event
func subscribe(event_name: String, callback: Callable, subscriber_id: String = "", 
               filter_func: Callable = Callable(), priority: int = 0, one_time: bool = false) -> String:
	# Generate subscriber ID if not provided
	if subscriber_id.is_empty():
		subscriber_id = str(randi()) + "_" + str(Time.get_ticks_msec())
	
	# Initialize event subscriber list if needed
	if not _subscribers.has(event_name):
		_subscribers[event_name] = []
	
	# Create subscriber object
	var subscriber = EventSubscriber.new(subscriber_id, callback, filter_func, priority, one_time)
	
	# Add to subscriber list
	_subscribers[event_name].append(subscriber)
	
	# Sort subscribers by priority (higher priority first)
	_subscribers[event_name].sort_custom(func(a, b): return a.priority > b.priority)
	
	return subscriber_id

# Subscribe to multiple events at once
func subscribe_to_multiple(event_names: Array, callback: Callable, subscriber_id: String = "",
                           filter_func: Callable = Callable(), priority: int = 0, one_time: bool = false) -> Array:
	var ids = []
	
	for event_name in event_names:
		var id = subscribe(event_name, callback, subscriber_id + "_" + event_name, filter_func, priority, one_time)
		ids.append(id)
	
	return ids

# Subscribe to all events in a channel
func subscribe_to_channel(channel_name: String, callback: Callable, subscriber_id: String = "",
                          filter_func: Callable = Callable(), priority: int = 0, one_time: bool = false) -> Array:
	# Check if channel exists
	if not _channels.has(channel_name):
		push_error("Channel not found: " + channel_name)
		return []
	
	return subscribe_to_multiple(_channels[channel_name], callback, subscriber_id, filter_func, priority, one_time)

# Unsubscribe from an event
func unsubscribe(event_name: String, subscriber_id: String) -> bool:
	# Check if event and subscribers exist
	if not _subscribers.has(event_name):
		return false
	
	var subscribers = _subscribers[event_name]
	var initial_count = subscribers.size()
	
	# Filter out the subscriber with matching ID
	_subscribers[event_name] = subscribers.filter(func(s): return s.id != subscriber_id)
	
	return _subscribers[event_name].size() < initial_count

# Unsubscribe from all events
func unsubscribe_all(subscriber_id: String) -> int:
	var unsubscribe_count = 0
	
	for event_name in _subscribers.keys():
		var subscribers = _subscribers[event_name]
		var initial_count = subscribers.size()
		
		_subscribers[event_name] = subscribers.filter(func(s): return s.id != subscriber_id)
		
		unsubscribe_count += initial_count - _subscribers[event_name].size()
	
	return unsubscribe_count

# Emit an event
func emit_event(event_name: String, event_data: Dictionary = {}) -> int:
	# Log event
	if logging_level >= 3 or (logging_level >= 2 and event_name.begins_with("system_")):
		_log_event(event_name, event_data)
	
	# Add to history
	_add_to_history(event_name, event_data)
	
	# Emit the global signal
	event_emitted.emit(event_name, event_data)
	
	# If no direct subscribers, return 0
	if not _subscribers.has(event_name):
		return 0
	
	var notify_count = 0
	var subscribers_to_remove = []
	
	# Notify subscribers
	for subscriber in _subscribers[event_name]:
		# Skip disabled subscribers
		if not subscriber.enabled:
			continue
		
		# Apply filter if specified
		if subscriber.filter_func.is_valid():
			if not subscriber.filter_func.call(event_data):
				continue
		
		# Invoke callback
		subscriber.callback.call(event_name, event_data)
		notify_count += 1
		
		# Mark one-time subscribers for removal
		if subscriber.one_time:
			subscribers_to_remove.append(subscriber)
	
	# Remove one-time subscribers
	for subscriber in subscribers_to_remove:
		_subscribers[event_name].erase(subscriber)
	
	return notify_count

# Create a new event channel or add events to an existing channel
func create_channel(channel_name: String, event_names: Array) -> void:
	if not _channels.has(channel_name):
		_channels[channel_name] = []
	
	for event_name in event_names:
		if not event_name in _channels[channel_name]:
			_channels[channel_name].append(event_name)

# Remove a channel
func remove_channel(channel_name: String) -> bool:
	if not _channels.has(channel_name):
		return false
	
	_channels.erase(channel_name)
	return true

# Get events in a channel
func get_channel_events(channel_name: String) -> Array:
	if not _channels.has(channel_name):
		return []
	
	return _channels[channel_name].duplicate()

# Get all channels
func get_all_channels() -> Array:
	return _channels.keys()

# Check if an event exists in any channel
func is_event_registered(event_name: String) -> bool:
	for channel_name in _channels:
		if event_name in _channels[channel_name]:
			return true
	
	return false

# Enable a specific subscriber
func enable_subscriber(event_name: String, subscriber_id: String) -> bool:
	if not _subscribers.has(event_name):
		return false
	
	for subscriber in _subscribers[event_name]:
		if subscriber.id == subscriber_id:
			subscriber.enabled = true
			return true
	
	return false

# Disable a specific subscriber
func disable_subscriber(event_name: String, subscriber_id: String) -> bool:
	if not _subscribers.has(event_name):
		return false
	
	for subscriber in _subscribers[event_name]:
		if subscriber.id == subscriber_id:
			subscriber.enabled = false
			return true
	
	return false

# Get subscriber count for an event
func get_subscriber_count(event_name: String) -> int:
	if not _subscribers.has(event_name):
		return 0
	
	return _subscribers[event_name].size()

# Get all events that have subscribers
func get_events_with_subscribers() -> Array:
	var events = []
	
	for event_name in _subscribers:
		if not _subscribers[event_name].is_empty():
			events.append(event_name)
	
	return events

# Add event to history
func _add_to_history(event_name: String, event_data: Dictionary) -> void:
	var record = EventRecord.new(event_name, event_data)
	_event_history.append(record)
	
	# Trim history if it exceeds max size
	if _event_history.size() > max_history_size:
		_event_history.pop_front()

# Log an event
func _log_event(event_name: String, event_data: Dictionary) -> void:
	var log_text = "EVENT: " + event_name
	
	if not event_data.is_empty():
		log_text += " - Data: " + str(event_data)
	
	print(log_text)

# Get event history
func get_event_history(max_events: int = -1, filter_func: Callable = Callable()) -> Array:
	var history = []
	
	var count = max_events if max_events > 0 else _event_history.size()
	var start_idx = max(0, _event_history.size() - count)
	
	for i in range(start_idx, _event_history.size()):
		var record = _event_history[i]
		
		# Apply filter if specified
		if filter_func.is_valid():
			if not filter_func.call(record.event_name, record.event_data):
				continue
		
		history.append({
			"timestamp": record.timestamp,
			"event_name": record.event_name,
			"event_data": record.event_data
		})
	
	return history

# Clear event history
func clear_history() -> void:
	_event_history.clear()

# Save event history to a file
func save_history_to_file(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open file for writing: " + file_path)
		return false
	
	# Convert history to serializable format
	var serialized_data = []
	for record in _event_history:
		serialized_data.append({
			"timestamp": record.timestamp,
			"event_name": record.event_name,
			"event_data": record.event_data
		})
	
	# Save as JSON
	file.store_string(JSON.stringify(serialized_data, "\t"))
	return true

# Load event history from a file
func load_history_from_file(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		push_error("File doesn't exist: " + file_path)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open file for reading: " + file_path)
		return false
	
	var json_text = file.get_as_text()
	var json_result = JSON.parse_string(json_text)
	if json_result == null:
		push_error("Failed to parse JSON from file: " + file_path)
		return false
	
	# Clear existing history
	_event_history.clear()
	
	# Load history from JSON
	var loaded_data = json_result
	for record_data in loaded_data:
		var record = EventRecord.new(record_data["event_name"], record_data["event_data"])
		record.timestamp = record_data["timestamp"]
		_event_history.append(record)
	
	return true

# Replay event history
func replay_history(start_idx: int = 0, end_idx: int = -1, delay: float = 0.0) -> void:
	if _event_history.is_empty():
		return
	
	var end = end_idx if end_idx >= 0 else _event_history.size() - 1
	
	for i in range(start_idx, min(end + 1, _event_history.size())):
		var record = _event_history[i]
		
		emit_event(record.event_name, record.event_data)
		
		if delay > 0:
			await get_tree().create_timer(delay).timeout