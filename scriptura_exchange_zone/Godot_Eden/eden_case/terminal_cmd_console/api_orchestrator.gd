extends Node
class_name APIOrchestrator

# Signals
signal api_response(api_name, response, request_id)
signal api_error(api_name, error, request_id)
signal rate_limit_warning(api_name, limit_info)
signal connection_status_changed(api_name, is_connected)

# Configuration
export var config_path = "res://config/api/"
export var auto_retry = true
export var max_retries = 3
export var retry_delay = 2.0  # seconds
export var offline_cache_enabled = true
export var offline_cache_expiry = 86400  # 24 hours in seconds

# API connection state
var api_connections = {}
var request_queue = []
var active_requests = {}
var offline_cache = {}
var api_usage = {}

# Constants
const API_TYPES = {
    "claude": "ai",
    "openai": "ai",
    "google_drive": "storage",
    "telegram": "messaging",
    "local_llm": "ai"
}

func _ready():
    # Initialize default directories
    _ensure_directories_exist()
    
    # Load offline cache
    load_offline_cache()

func _ensure_directories_exist():
    var dir = Directory.new()
    
    # Ensure config directory exists
    if !dir.dir_exists(config_path):
        var parent_dir = config_path.get_base_dir()
        if !dir.dir_exists(parent_dir):
            dir.make_dir_recursive(parent_dir)
        else:
            dir.make_dir(config_path)
    
    # Ensure cache directory exists
    var cache_dir = "user://api_cache"
    if !dir.dir_exists(cache_dir):
        dir.make_dir(cache_dir)

func add_api_connection(api_name, config_file=""):
    # Check if already registered
    if api_connections.has(api_name):
        printerr("API connection already exists: ", api_name)
        return false
    
    # Determine config file path if not provided
    if config_file.empty():
        config_file = config_path.plus_file(api_name + "_config.json")
    
    # Load API configuration
    var config = _load_api_config(config_file)
    if config == null:
        printerr("Failed to load API configuration: ", config_file)
        return false
    
    # Determine API type
    var api_type = API_TYPES.get(api_name, "unknown")
    
    # Create API connection
    api_connections[api_name] = {
        "config": config,
        "type": api_type,
        "is_connected": false,
        "retry_count": 0,
        "last_request_time": 0,
        "rate_limit": {
            "requests_per_minute": config.get("rate_limit", 60),
            "requests_this_minute": 0,
            "reset_time": OS.get_unix_time() + 60
        }
    }
    
    # Initialize usage tracking
    api_usage[api_name] = {
        "total_requests": 0,
        "successful_requests": 0,
        "failed_requests": 0,
        "retry_count": 0,
        "total_tokens": 0,
        "cost": 0.0
    }
    
    print("API connection added: ", api_name)
    
    # Test connection if config has test_endpoint
    if config.has("test_endpoint"):
        _test_connection(api_name)
    else:
        # Assume connected if no test endpoint
        _set_connection_status(api_name, true)
    
    return true

func remove_api_connection(api_name):
    if !api_connections.has(api_name):
        printerr("API connection not found: ", api_name)
        return false
    
    api_connections.erase(api_name)
    print("API connection removed: ", api_name)
    return true

func _load_api_config(config_file):
    var file = File.new()
    if !file.file_exists(config_file):
        # Create default config if it doesn't exist
        return _create_default_config(config_file)
    
    var err = file.open(config_file, File.READ)
    if err != OK:
        printerr("Failed to open config file: ", config_file, ", error: ", err)
        return null
    
    var text = file.get_as_text()
    file.close()
    
    var json = JSON.parse(text)
    if json.error != OK:
        printerr("Failed to parse config JSON: ", json.error_string)
        return null
    
    return json.result

func _create_default_config(config_file):
    # Extract API name from file path
    var api_name = config_file.get_file().get_basename()
    if api_name.ends_with("_config"):
        api_name = api_name.substr(0, api_name.length() - 7)
    
    # Create default configuration based on API type
    var config = {
        "api_key": "YOUR_API_KEY_HERE",
        "base_url": "",
        "version": "v1",
        "rate_limit": 60,
        "timeout": 30
    }
    
    # Add specific defaults based on API name
    match api_name:
        "claude":
            config.base_url = "https://api.anthropic.com"
            config.model = "claude-3-opus-20240229"
        "openai":
            config.base_url = "https://api.openai.com"
            config.model = "gpt-4"
        "google_drive":
            config.base_url = "https://www.googleapis.com/drive/v3"
            config.auth_type = "oauth2"
        "telegram":
            config.base_url = "https://api.telegram.org/bot"
    
    # Save default config
    var file = File.new()
    var err = file.open(config_file, File.WRITE)
    if err != OK:
        printerr("Failed to create default config file: ", config_file, ", error: ", err)
        return null
    
    file.store_string(JSON.print(config, "  "))
    file.close()
    
    print("Created default config for: ", api_name, " at ", config_file)
    return config

func _test_connection(api_name):
    if !api_connections.has(api_name):
        printerr("API connection not found: ", api_name)
        return
    
    var config = api_connections[api_name].config
    if !config.has("test_endpoint"):
        _set_connection_status(api_name, true)  # Assume connected
        return
    
    # TODO: In a real implementation, make an HTTP request to test the connection
    # For now, simulate a successful connection
    _set_connection_status(api_name, true)

func _set_connection_status(api_name, is_connected):
    if !api_connections.has(api_name):
        return
    
    var old_status = api_connections[api_name].is_connected
    api_connections[api_name].is_connected = is_connected
    
    if old_status != is_connected:
        emit_signal("connection_status_changed", api_name, is_connected)
        print("API connection status changed: ", api_name, " = ", is_connected)

func send_request(api_name, endpoint, method="GET", data=null, params={}):
    if !api_connections.has(api_name):
        printerr("API connection not found: ", api_name)
        return -1
    
    # Generate request ID
    var request_id = _generate_request_id()
    
    # Create request data
    var request = {
        "id": request_id,
        "api_name": api_name,
        "endpoint": endpoint,
        "method": method,
        "data": data,
        "params": params,
        "retry_count": 0,
        "timestamp": OS.get_unix_time()
    }
    
    # Check cache for GET requests if offline cache is enabled
    if offline_cache_enabled and method == "GET":
        var cache_key = _generate_cache_key(api_name, endpoint, params)
        if offline_cache.has(cache_key):
            var cached = offline_cache[cache_key]
            if cached.expiry > OS.get_unix_time():
                # Return cached response
                print("Using cached response for: ", api_name, "/", endpoint)
                
                # Simulate delay for realism
                yield(get_tree().create_timer(0.1), "timeout")
                
                emit_signal("api_response", api_name, cached.response, request_id)
                return request_id
    
    # Check rate limits
    if _check_rate_limit(api_name):
        # Add to queue
        request_queue.append(request)
        _process_request_queue()
    else:
        # Exceeded rate limit, queue request for later
        request_queue.append(request)
        print("Rate limit reached for: ", api_name, ", request queued")
    
    return request_id

func _check_rate_limit(api_name):
    if !api_connections.has(api_name):
        return false
    
    var rate_limit = api_connections[api_name].rate_limit
    var current_time = OS.get_unix_time()
    
    # Reset counter if time expired
    if current_time >= rate_limit.reset_time:
        rate_limit.requests_this_minute = 0
        rate_limit.reset_time = current_time + 60  # Reset 1 minute from now
    
    # Check if limit reached
    if rate_limit.requests_this_minute >= rate_limit.requests_per_minute:
        # Emit warning
        emit_signal("rate_limit_warning", api_name, {
            "limit": rate_limit.requests_per_minute,
            "reset_in_seconds": rate_limit.reset_time - current_time
        })
        return false
    
    # Increment counter
    rate_limit.requests_this_minute += 1
    return true

func _process_request_queue():
    # Check if queue is empty
    if request_queue.size() == 0:
        return
    
    # Process each request
    var i = 0
    while i < request_queue.size():
        var request = request_queue[i]
        var api_name = request.api_name
        
        # Check if API is connected
        if !api_connections.has(api_name) or !api_connections[api_name].is_connected:
            # Skip this request
            i += 1
            continue
        
        # Check rate limit
        if !_check_rate_limit(api_name):
            # Skip to next API
            var current_api = api_name
            while i < request_queue.size() and request_queue[i].api_name == current_api:
                i += 1
            continue
        
        # Remove from queue and process
        request_queue.remove(i)
        _execute_request(request)
        
        # Don't increment i since we removed an item

func _execute_request(request):
    var api_name = request.api_name
    var endpoint = request.endpoint
    var method = request.method
    var data = request.data
    var params = request.params
    var request_id = request.id
    
    # Add to active requests
    active_requests[request_id] = request
    
    # Update usage stats
    api_usage[api_name].total_requests += 1
    api_connections[api_name].last_request_time = OS.get_unix_time()
    
    # Perform API call
    # In a real implementation, this would use Godot's HTTPClient or HTTPRequest
    # For demonstration, we'll simulate API responses
    
    # Simulate network delay (0.5 to 2.0 seconds)
    var delay = 0.5 + randf() * 1.5
    yield(get_tree().create_timer(delay), "timeout")
    
    # Simulate response
    var success = randf() > 0.1  # 90% success rate
    
    if success:
        var response = _generate_simulated_response(api_name, endpoint, method, data, params)
        
        # Update usage stats
        api_usage[api_name].successful_requests += 1
        
        # Cache GET responses if enabled
        if offline_cache_enabled and method == "GET":
            var cache_key = _generate_cache_key(api_name, endpoint, params)
            offline_cache[cache_key] = {
                "response": response,
                "timestamp": OS.get_unix_time(),
                "expiry": OS.get_unix_time() + offline_cache_expiry
            }
        
        # Emit response signal
        emit_signal("api_response", api_name, response, request_id)
    else:
        # Simulate error
        var error = _generate_simulated_error(api_name)
        
        # Update usage stats
        api_usage[api_name].failed_requests += 1
        
        # Handle retry if enabled
        if auto_retry and request.retry_count < max_retries:
            print("Retrying request to: ", api_name, "/", endpoint)
            request.retry_count += 1
            api_usage[api_name].retry_count += 1
            
            # Add back to queue after delay
            yield(get_tree().create_timer(retry_delay), "timeout")
            request_queue.append(request)
            _process_request_queue()
        else:
            # Emit error signal
            emit_signal("api_error", api_name, error, request_id)
    
    # Remove from active requests
    active_requests.erase(request_id)

func _generate_request_id():
    return str(OS.get_unix_time()) + "_" + str(randi() % 10000)

func _generate_cache_key(api_name, endpoint, params):
    var key = api_name + ":" + endpoint
    
    if params.size() > 0:
        var param_strings = []
        var param_keys = params.keys()
        param_keys.sort()
        
        for param in param_keys:
            param_strings.append(str(param) + "=" + str(params[param]))
        
        key += "?" + PoolStringArray(param_strings).join("&")
    
    return key

func _generate_simulated_response(api_name, endpoint, method, data, params):
    # This function generates simulated responses for demonstration
    match api_name:
        "claude":
            return _simulate_claude_response(endpoint, data)
        "openai":
            return _simulate_openai_response(endpoint, data)
        "google_drive":
            return _simulate_gdrive_response(endpoint, method, params)
        "telegram":
            return _simulate_telegram_response(endpoint, data)
        _:
            return {"status": "success", "message": "Simulated response"}

func _generate_simulated_error(api_name):
    # Generate random error for demonstration
    var error_types = [
        "connection_error",
        "timeout",
        "authentication_failed",
        "rate_limited",
        "invalid_request"
    ]
    
    var error_type = error_types[randi() % error_types.size()]
    var error_messages = {
        "connection_error": "Could not connect to API server",
        "timeout": "Request timed out",
        "authentication_failed": "Invalid API key or credentials",
        "rate_limited": "Rate limit exceeded",
        "invalid_request": "The request was invalid"
    }
    
    return {
        "error": error_type,
        "message": error_messages[error_type]
    }

func _simulate_claude_response(endpoint, data):
    if endpoint == "messages":
        var prompt = data.get("prompt", "")
        if prompt.empty() and data.has("messages"):
            # Extract last message content for simulation
            var messages = data.get("messages", [])
            if messages.size() > 0:
                prompt = messages[messages.size() - 1].get("content", "")
        
        # Generate simulated response
        var response_text = "This is a simulated Claude response to: '" + prompt + "'. In a real implementation, this would connect to the Claude API."
        
        return {
            "id": "msg_" + _generate_request_id(),
            "type": "message",
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": response_text
                }
            ],
            "model": data.get("model", "claude-3-opus-20240229"),
            "stop_reason": "end_turn",
            "usage": {
                "input_tokens": prompt.length() / 4,
                "output_tokens": response_text.length() / 4
            }
        }
    
    return {"status": "success", "message": "Claude API called"}

func _simulate_openai_response(endpoint, data):
    if endpoint == "chat/completions":
        var messages = data.get("messages", [])
        var last_message_content = ""
        
        if messages.size() > 0:
            last_message_content = messages[messages.size() - 1].get("content", "")
        
        var response_text = "This is a simulated OpenAI response to: '" + last_message_content + "'. In a real implementation, this would connect to the OpenAI API."
        
        return {
            "id": "chatcmpl-" + _generate_request_id(),
            "object": "chat.completion",
            "created": OS.get_unix_time(),
            "model": data.get("model", "gpt-4"),
            "choices": [
                {
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": response_text
                    },
                    "finish_reason": "stop"
                }
            ],
            "usage": {
                "prompt_tokens": last_message_content.length() / 4,
                "completion_tokens": response_text.length() / 4,
                "total_tokens": (last_message_content.length() + response_text.length()) / 4
            }
        }
    
    return {"status": "success", "message": "OpenAI API called"}

func _simulate_gdrive_response(endpoint, method, params):
    if endpoint == "files" and method == "GET":
        # Simulate file list
        var files = []
        for i in range(5):
            files.append({
                "id": "file" + str(i),
                "name": "Simulated File " + str(i) + ".txt",
                "mimeType": "text/plain",
                "createdTime": "2023-01-0" + str(i+1) + "T00:00:00.000Z"
            })
        
        return {
            "kind": "drive#fileList",
            "nextPageToken": "",
            "files": files
        }
    
    return {"status": "success", "message": "Google Drive API called"}

func _simulate_telegram_response(endpoint, data):
    return {
        "ok": true,
        "result": {
            "message_id": randi() % 1000,
            "date": OS.get_unix_time(),
            "text": "Message delivered"
        }
    }

func cancel_request(request_id):
    # Check if request is active
    if active_requests.has(request_id):
        # In a real implementation, this would cancel the HTTP request
        active_requests.erase(request_id)
        return true
    
    # Check if request is in queue
    for i in range(request_queue.size()):
        if request_queue[i].id == request_id:
            request_queue.remove(i)
            return true
    
    return false

func get_api_status(api_name):
    if !api_connections.has(api_name):
        return null
    
    var conn = api_connections[api_name]
    
    return {
        "is_connected": conn.is_connected,
        "last_request_time": conn.last_request_time,
        "requests_this_minute": conn.rate_limit.requests_this_minute,
        "requests_per_minute": conn.rate_limit.requests_per_minute,
        "reset_in_seconds": max(0, conn.rate_limit.reset_time - OS.get_unix_time())
    }

func get_api_usage_stats(api_name=null):
    if api_name != null:
        if !api_usage.has(api_name):
            return null
        return api_usage[api_name]
    
    # Return stats for all APIs
    var total_stats = {
        "total_requests": 0,
        "successful_requests": 0,
        "failed_requests": 0,
        "retry_count": 0,
        "total_tokens": 0,
        "cost": 0.0,
        "apis": []
    }
    
    for name in api_usage:
        var stats = api_usage[name]
        
        total_stats.total_requests += stats.total_requests
        total_stats.successful_requests += stats.successful_requests
        total_stats.failed_requests += stats.failed_requests
        total_stats.retry_count += stats.retry_count
        total_stats.total_tokens += stats.total_tokens
        total_stats.cost += stats.cost
        
        total_stats.apis.append({
            "name": name,
            "requests": stats.total_requests,
            "success_rate": stats.total_requests > 0 ? float(stats.successful_requests) / stats.total_requests : 0.0
        })
    
    return total_stats

func load_offline_cache(cache_file="user://api_cache/offline_cache.json"):
    var file = File.new()
    if !file.file_exists(cache_file):
        offline_cache = {}
        return
    
    var err = file.open(cache_file, File.READ)
    if err != OK:
        printerr("Failed to open offline cache file: ", err)
        offline_cache = {}
        return
    
    var json = JSON.parse(file.get_as_text())
    file.close()
    
    if json.error != OK:
        printerr("Failed to parse offline cache JSON: ", json.error_string)
        offline_cache = {}
        return
    
    offline_cache = json.result
    
    # Clean expired entries
    var current_time = OS.get_unix_time()
    var keys_to_remove = []
    
    for key in offline_cache:
        if offline_cache[key].expiry < current_time:
            keys_to_remove.append(key)
    
    for key in keys_to_remove:
        offline_cache.erase(key)
    
    print("Loaded offline cache with ", offline_cache.size(), " entries (removed ", keys_to_remove.size(), " expired)")

func save_offline_cache(cache_file="user://api_cache/offline_cache.json"):
    var file = File.new()
    var err = file.open(cache_file, File.WRITE)
    if err != OK:
        printerr("Failed to open offline cache file for writing: ", err)
        return false
    
    file.store_string(JSON.print(offline_cache))
    file.close()
    
    print("Saved offline cache with ", offline_cache.size(), " entries")
    return true

func clear_offline_cache():
    offline_cache.clear()
    save_offline_cache()
    print("Offline cache cleared")

func _on_tree_exiting():
    # Save cache on exit
    save_offline_cache()