extends Node

class_name ClaudeIntegrationBridge

# ----- CLAUDE INTEGRATION SETTINGS -----
@export_category("Claude Integration")
@export var enabled: bool = true
@export var auto_connect: bool = true
@export var use_memory_system: bool = true
@export var use_ethereal_bridge: bool = true
@export var use_akashic_records: bool = true
@export var default_model: String = "claude-3-7-sonnet"
@export var cache_responses: bool = true
@export var max_tokens_per_minute: int = 8000
@export var freemium_mode: bool = true

# ----- API SETTINGS -----
var api_key: String = ""
var api_base_url: String = "https://api.anthropic.com/v1/messages"
var api_version: String = "2023-06-01"
var organization_id: String = ""

# ----- MEMORY SETTINGS -----
var memory_path: String = "user://claude_memory/"
var cache_path: String = "user://claude_cache/"
var conversation_path: String = "user://claude_conversations/"
var max_memory_items: int = 100
var max_cache_items: int = 50
var max_conversation_history: int = 20

# ----- INTEGRATION STATE -----
var is_connected: bool = false
var token_usage: Dictionary = {
    "input_tokens": 0,
    "output_tokens": 0,
    "total_tokens": 0,
    "last_reset": 0
}
var api_calls_remaining: int = 100
var current_conversation_id: String = ""
var current_conversation_messages: Array = []
var cached_responses: Dictionary = {}
var error_count: int = 0

# ----- SYSTEM REFERENCES -----
var memory_system: Node = null
var ethereal_bridge: Node = null
var triple_connector: Node = null
var performance_optimizer: Node = null

# ----- CREDENTIALS FILE -----
var credentials_file: String = "user://claude_credentials.json"

# ----- REQUEST QUEUE -----
var request_queue: Array = []
var is_processing_queue: bool = false
var last_request_time: int = 0
var request_cooldown: int = 2  # Seconds between API requests

# ----- TIMERS -----
var token_reset_timer: Timer
var queue_process_timer: Timer

# ----- SIGNALS -----
signal claude_connected()
signal claude_disconnected()
signal message_sent(message_id, content)
signal response_received(message_id, content)
signal token_usage_updated(usage)
signal error_occurred(error_code, message)
signal memory_stored(memory_id, content)
signal conversation_started(conversation_id)
signal conversation_ended(conversation_id, message_count)

# ----- INITIALIZATION -----
func _ready():
    # Set up directories
    _ensure_directories_exist()
    
    # Set up timers
    _setup_timers()
    
    # Find system references
    _find_system_references()
    
    # Load credentials
    _load_credentials()
    
    # Reset token usage if needed
    _check_token_reset()
    
    # Auto-connect if enabled
    if auto_connect and not api_key.is_empty():
        connect_to_claude()
    
    # Start with a new conversation
    start_new_conversation()
    
    print("Claude Integration Bridge initialized")

func _ensure_directories_exist():
    var directories = [
        memory_path,
        cache_path,
        conversation_path
    ]
    
    for dir in directories:
        if not DirAccess.dir_exists_absolute(dir):
            DirAccess.make_dir_recursive_absolute(dir)

func _setup_timers():
    # Token reset timer - resets token usage daily
    token_reset_timer = Timer.new()
    token_reset_timer.wait_time = 3600  # Check hourly
    token_reset_timer.one_shot = false
    token_reset_timer.autostart = true
    token_reset_timer.connect("timeout", _on_token_reset_timer_timeout)
    add_child(token_reset_timer)
    
    # Queue process timer - processes queued requests
    queue_process_timer = Timer.new()
    queue_process_timer.wait_time = 1.0  # Check every second
    queue_process_timer.one_shot = false
    queue_process_timer.autostart = true
    queue_process_timer.connect("timeout", _on_queue_process_timer_timeout)
    add_child(queue_process_timer)

func _find_system_references():
    # Find Memory System
    memory_system = _find_node_by_class(get_tree().root, "IntegratedMemorySystem")
    
    # Find Ethereal Bridge
    ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealAkashicBridge")
    
    # Find Triple Connector
    triple_connector = _find_node_by_class(get_tree().root, "TripleMemoryConnector")
    
    # Find Performance Optimizer
    performance_optimizer = _find_node_by_class(get_tree().root, "PerformanceOptimizer")

func _find_node_by_class(node, class_name):
    if node.get_class() == class_name or (node.get_script() and node.get_script().get_path().find(class_name.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name)
        if found:
            return found
    
    return null

func _load_credentials():
    if FileAccess.file_exists(credentials_file):
        var file = FileAccess.open(credentials_file, FileAccess.READ)
        if file:
            var json = JSON.new()
            var error = json.parse(file.get_as_text())
            
            if error == OK:
                var data = json.data
                
                if data.has("api_key"):
                    api_key = data.api_key
                
                if data.has("organization_id"):
                    organization_id = data.organization_id
                
                if data.has("api_base_url"):
                    api_base_url = data.api_base_url
                
                if data.has("default_model"):
                    default_model = data.default_model
            
            file.close()
    
    # For security, don't log the API key
    print("Claude credentials " + (api_key.is_empty() ? "not found" : "loaded successfully"))

func _save_credentials():
    var data = {
        "api_key": api_key,
        "organization_id": organization_id,
        "api_base_url": api_base_url,
        "default_model": default_model
    }
    
    var file = FileAccess.open(credentials_file, FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(data, "  ")
        file.store_string(json_string)
        file.close()
        return true
    
    return false

# ----- CONNECTION MANAGEMENT -----
func connect_to_claude():
    if not enabled or api_key.is_empty():
        print("Cannot connect to Claude: " + (not enabled ? "Integration disabled" : "API key missing"))
        return false
    
    # Simple validation request to check if credentials work
    is_connected = true  # Optimistically set to true
    
    # In a real implementation, this would make a test API call
    # For this demo, we'll just assume it works if we have an API key
    
    if is_connected:
        emit_signal("claude_connected")
        print("Successfully connected to Claude API")
    else:
        emit_signal("error_occurred", "connection_failed", "Failed to connect to Claude API")
        print("Failed to connect to Claude API")
    
    return is_connected

func disconnect_from_claude():
    is_connected = false
    emit_signal("claude_disconnected")
    print("Disconnected from Claude API")
    return true

func is_connected_to_claude():
    return is_connected && !api_key.is_empty()

# ----- CONVERSATION MANAGEMENT -----
func start_new_conversation():
    # Generate a new conversation ID
    current_conversation_id = _generate_id()
    current_conversation_messages = []
    
    print("Started new conversation: " + current_conversation_id)
    emit_signal("conversation_started", current_conversation_id)
    
    return current_conversation_id

func end_current_conversation():
    if current_conversation_id.is_empty():
        return false
    
    # Save conversation before ending
    _save_conversation(current_conversation_id, current_conversation_messages)
    
    var message_count = current_conversation_messages.size()
    emit_signal("conversation_ended", current_conversation_id, message_count)
    
    # Generate memories from conversation if memory system is available
    if use_memory_system and memory_system:
        _generate_memories_from_conversation(current_conversation_id)
    
    # Reset for next conversation
    var last_conversation_id = current_conversation_id
    current_conversation_id = ""
    current_conversation_messages = []
    
    print("Ended conversation: " + last_conversation_id + " with " + str(message_count) + " messages")
    
    return true

func load_conversation(conversation_id):
    var file_path = conversation_path + conversation_id + ".json"
    
    if FileAccess.file_exists(file_path):
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var json = JSON.new()
            var error = json.parse(file.get_as_text())
            
            if error == OK:
                var data = json.data
                
                if data.has("messages"):
                    current_conversation_id = conversation_id
                    current_conversation_messages = data.messages
                    
                    print("Loaded conversation: " + conversation_id + " with " + str(current_conversation_messages.size()) + " messages")
                    return true
            
            file.close()
    
    print("Failed to load conversation: " + conversation_id)
    return false

func _save_conversation(conversation_id, messages):
    var file_path = conversation_path + conversation_id + ".json"
    
    var data = {
        "conversation_id": conversation_id,
        "timestamp": Time.get_unix_time_from_system(),
        "messages": messages
    }
    
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(data, "  ")
        file.store_string(json_string)
        file.close()
        return true
    
    return false

func _generate_memories_from_conversation(conversation_id):
    var file_path = conversation_path + conversation_id + ".json"
    
    if FileAccess.file_exists(file_path):
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var json = JSON.new()
            var error = json.parse(file.get_as_text())
            
            if error == OK:
                var data = json.data
                
                if data.has("messages") and data.messages.size() > 0:
                    # Create a summary memory for the whole conversation
                    var messages = data.messages
                    var summary = _generate_conversation_summary(messages)
                    
                    if memory_system and memory_system.has_method("store_memory"):
                        var memory_id = memory_system.store_memory(
                            summary,
                            ["conversation", "claude", "conversation_" + conversation_id],
                            "conversation_summary"
                        )
                        
                        emit_signal("memory_stored", memory_id, summary)
                    
                    # Also connect to Ethereal Bridge if available
                    if use_ethereal_bridge and ethereal_bridge and ethereal_bridge.has_method("record_memory"):
                        ethereal_bridge.record_memory(
                            summary,
                            ["conversation", "claude", "conversation_" + conversation_id],
                            "0-0-0"  # Default dimension
                        )
            
            file.close()
    
    # In a real implementation, we would analyze the conversation
    # and extract key insights to store as separate memories

func _generate_conversation_summary(messages):
    var summary = "Conversation Summary:\n\n"
    
    if messages.size() <= 3:
        summary += "Brief exchange"
    else:
        summary += "Extended conversation with " + str(messages.size()) + " messages"
    
    return summary
    
    # In a real implementation, we would use Claude to generate
    # a real summary of the conversation content

# ----- MESSAGE SENDING -----
func send_message(content, system_prompt = "", model = ""):
    if not is_connected or content.is_empty():
        return null
    
    # Check token limits for freemium mode
    if freemium_mode and token_usage.total_tokens >= max_tokens_per_minute:
        emit_signal("error_occurred", "token_limit", "Token limit reached in freemium mode")
        return null
    
    # Create message object
    var message_id = _generate_id()
    var message = {
        "id": message_id,
        "role": "user",
        "content": content,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Add to conversation
    current_conversation_messages.append(message)
    
    # Prepare API request
    var model_to_use = model if not model.is_empty() else default_model
    var system_instruction = system_prompt if not system_prompt.is_empty() else "You are Claude, an AI assistant developed by Anthropic to be helpful, harmless, and honest."
    
    var request = {
        "message_id": message_id,
        "model": model_to_use,
        "system": system_instruction,
        "messages": _prepare_messages_for_api(),
        "content": content,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Check cache first if enabled
    if cache_responses:
        var cache_key = content.strip_edges().md5_text()
        if cached_responses.has(cache_key):
            var cache_hit = cached_responses[cache_key]
            print("Cache hit for message: " + message_id)
            
            # Add to conversation
            current_conversation_messages.append({
                "id": cache_hit.id,
                "role": "assistant",
                "content": cache_hit.content,
                "timestamp": Time.get_unix_time_from_system(),
                "cached": true
            })
            
            emit_signal("response_received", cache_hit.id, cache_hit.content)
            return cache_hit.id
    
    # Add to queue
    request_queue.append(request)
    
    # Start processing queue if not already
    if not is_processing_queue:
        _process_queue()
    
    emit_signal("message_sent", message_id, content)
    return message_id

func _prepare_messages_for_api():
    var api_messages = []
    
    // Take the last few messages to stay within context limits
    var recent_messages = current_conversation_messages.slice(
        max(0, current_conversation_messages.size() - max_conversation_history),
        current_conversation_messages.size()
    )
    
    for msg in recent_messages:
        api_messages.append({
            "role": msg.role,
            "content": msg.content
        })
    
    return api_messages

func _process_queue():
    if request_queue.is_empty() or is_processing_queue:
        return
    
    is_processing_queue = true
    
    // Check for cooldown period
    var current_time = Time.get_unix_time_from_system()
    if current_time - last_request_time < request_cooldown:
        // Wait for cooldown
        return
    
    // Get next request
    var request = request_queue[0]
    
    // Allocate performance thread if available
    var thread_id = -1
    if performance_optimizer and performance_optimizer.has_method("allocate_thread"):
        thread_id = performance_optimizer.allocate_thread("claude_api_request", 8)
    
    // Process request
    _process_single_request(request)
    
    // Update last request time
    last_request_time = Time.get_unix_time_from_system()
    
    // Remove from queue
    request_queue.remove_at(0)
    
    // Release thread if allocated
    if thread_id >= 0 and performance_optimizer and performance_optimizer.has_method("release_thread"):
        performance_optimizer.release_thread(thread_id)
    
    is_processing_queue = false
    
    // Continue processing queue if more items
    if not request_queue.is_empty():
        queue_process_timer.start(request_cooldown)  // Schedule next process after cooldown

func _process_single_request(request):
    // In a real implementation, this would make an actual API call
    // For this demo, we'll simulate a response
    
    // Simulate API call
    print("Processing API request for message: " + request.message_id)
    
    // Simulate token counting
    var input_tokens = len(request.content.split(" "))
    var output_tokens = input_tokens * 2  // Simulate Claude's verbosity
    
    // Update token usage
    token_usage.input_tokens += input_tokens
    token_usage.output_tokens += output_tokens
    token_usage.total_tokens += input_tokens + output_tokens
    
    emit_signal("token_usage_updated", token_usage)
    
    // Generate simulated response
    var response_content = _generate_simulated_response(request.content)
    var response_id = _generate_id()
    
    // Add to conversation
    current_conversation_messages.append({
        "id": response_id,
        "role": "assistant",
        "content": response_content,
        "timestamp": Time.get_unix_time_from_system()
    })
    
    // Cache response if enabled
    if cache_responses:
        var cache_key = request.content.strip_edges().md5_text()
        cached_responses[cache_key] = {
            "id": response_id,
            "content": response_content,
            "timestamp": Time.get_unix_time_from_system()
        }
        
        // Trim cache if needed
        if cached_responses.size() > max_cache_items:
            var oldest_key = null
            var oldest_time = Time.get_unix_time_from_system()
            
            for key in cached_responses:
                if cached_responses[key].timestamp < oldest_time:
                    oldest_time = cached_responses[key].timestamp
                    oldest_key = key
            
            if oldest_key:
                cached_responses.erase(oldest_key)
    
    // Save conversation
    _save_conversation(current_conversation_id, current_conversation_messages)
    
    emit_signal("response_received", response_id, response_content)

func _generate_simulated_response(user_message):
    // This is a placeholder for a real Claude API call
    // In a real implementation, this would send the request to Claude's API
    
    // Simple "echo" to simulate a response
    return "I understand you're asking about: " + user_message + "\n\nIn a real implementation, this would be Claude's actual response."

# ----- MEMORY INTEGRATION -----
func store_message_as_memory(message_id, tags = []):
    var message = _find_message_by_id(message_id)
    if not message:
        return null
    
    var memory_tags = tags.duplicate()
    memory_tags.append("claude")
    memory_tags.append("message_" + message_id)
    
    var memory_id = null
    
    // Store in Memory System if available
    if use_memory_system and memory_system and memory_system.has_method("store_memory"):
        memory_id = memory_system.store_memory(
            message.content,
            memory_tags,
            "claude_message_" + message.role
        )
    
    // Also connect to Ethereal Bridge if available
    if use_ethereal_bridge and ethereal_bridge and ethereal_bridge.has_method("record_memory"):
        ethereal_bridge.record_memory(
            message.content,
            memory_tags,
            "0-0-0"  // Default dimension
        )
    
    if memory_id:
        emit_signal("memory_stored", memory_id, message.content)
    
    return memory_id

func _find_message_by_id(message_id):
    for message in current_conversation_messages:
        if message.id == message_id:
            return message
    
    return null

# ----- TOKEN MANAGEMENT -----
func _check_token_reset():
    var current_time = Time.get_unix_time_from_system()
    
    // Check if a new day has started since last reset
    if token_usage.last_reset == 0 or _is_new_day(token_usage.last_reset, current_time):
        token_usage.input_tokens = 0
        token_usage.output_tokens = 0
        token_usage.total_tokens = 0
        token_usage.last_reset = current_time
        
        emit_signal("token_usage_updated", token_usage)
        print("Token usage reset for new day")

func _is_new_day(past_time, current_time):
    var past_date = Time.get_datetime_dict_from_unix_time(past_time)
    var current_date = Time.get_datetime_dict_from_unix_time(current_time)
    
    return past_date.year != current_date.year || 
           past_date.month != current_date.month || 
           past_date.day != current_date.day

func get_token_usage():
    return token_usage.duplicate()

func get_remaining_tokens():
    if freemium_mode:
        return max(0, max_tokens_per_minute - token_usage.total_tokens)
    else:
        return 1000000  // Arbitrary large number for paid tier

# ----- UTILITY FUNCTIONS -----
func _generate_id():
    return str(Time.get_unix_time_from_system()) + "_" + str(randi() % 1000000).pad_zeros(6)

# ----- EVENT HANDLERS -----
func _on_token_reset_timer_timeout():
    _check_token_reset()

func _on_queue_process_timer_timeout():
    if not request_queue.is_empty() and not is_processing_queue:
        _process_queue()

# ----- PUBLIC API -----
func toggle_claude(enabled_state):
    enabled = enabled_state
    
    if enabled:
        if not is_connected and not api_key.is_empty():
            connect_to_claude()
    else:
        if is_connected:
            disconnect_from_claude()
    
    return enabled

func set_api_key(key):
    api_key = key
    _save_credentials()
    
    if enabled and not is_connected and not api_key.is_empty():
        connect_to_claude()
    
    return !api_key.is_empty()

func set_model(model_name):
    default_model = model_name
    _save_credentials()
    return true

func toggle_cache(cache_enabled):
    cache_responses = cache_enabled
    return cache_responses

func toggle_freemium_mode(freemium_enabled):
    freemium_mode = freemium_enabled
    return freemium_mode

func clear_cache():
    cached_responses.clear()
    return true

func get_conversation_list():
    var conversations = []
    
    var dir = DirAccess.open(conversation_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(".json"):
                var conv_id = file_name.split(".")[0]
                
                // Load basic metadata
                var file = FileAccess.open(conversation_path + file_name, FileAccess.READ)
                if file:
                    var json = JSON.new()
                    var error = json.parse(file.get_as_text())
                    
                    if error == OK:
                        var data = json.data
                        conversations.append({
                            "id": conv_id,
                            "timestamp": data.get("timestamp", 0),
                            "message_count": data.get("messages", []).size()
                        })
                    
                    file.close()
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    }
    
    // Sort by timestamp (most recent first)
    conversations.sort_custom(func(a, b): return a.timestamp > b.timestamp)
    
    return conversations

func get_current_conversation_state():
    return {
        "conversation_id": current_conversation_id,
        "message_count": current_conversation_messages.size(),
        "is_connected": is_connected,
        "token_usage": token_usage,
        "queue_size": request_queue.size()
    }

func create_ethereal_connection(content, dimension = ""):
    if not use_ethereal_bridge or not ethereal_bridge:
        return false
    
    if ethereal_bridge.has_method("process_ethereal_data"):
        ethereal_bridge.process_ethereal_data("claude_connection", content)
        return true
    
    return false