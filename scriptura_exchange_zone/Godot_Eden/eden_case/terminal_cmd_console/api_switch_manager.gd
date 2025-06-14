extends Node
class_name ApiSwitchManager

# ApiSwitchManager
# A comprehensive API endpoint management system with offline support and restart persistence
# Designed to integrate with the Eden Garden ecosystem

signal api_switched(endpoint_name)
signal connection_state_changed(is_online)
signal api_health_changed(endpoint_name, is_healthy)
signal request_completed(endpoint_name, success, data)
signal persistent_data_saved
signal persistent_data_loaded

# Core configuration
const CONFIG_FILE_PATH = "user://api_switch_config.json"
const DEFAULT_TIMEOUT = 10.0
const HEALTH_CHECK_INTERVAL = 30.0
const MAX_RETRY_COUNT = 3
const OFFLINE_QUEUE_MAX_SIZE = 100

# API endpoint registry
var endpoints = {}
var current_endpoint = ""
var previous_endpoint = ""
var auto_fallback = true
var is_online = true
var offline_queue = []
var health_check_timer = null
var retry_counter = {}

# Persistence data
var persistent_data = {
    "selected_api": "",
    "custom_endpoints": {},
    "offline_preferences": {},
    "last_session_time": 0,
    "restart_count": 0
}

class ApiEndpoint:
    var name = ""
    var url = ""
    var auth_token = ""
    var headers = {}
    var timeout = DEFAULT_TIMEOUT
    var is_healthy = true
    var last_health_check = 0
    var priority = 0
    var requires_encryption = false
    var connection_params = {}
    
    func _init(p_name, p_url, p_auth_token="", p_headers={}, p_timeout=DEFAULT_TIMEOUT, p_priority=0):
        name = p_name
        url = p_url
        auth_token = p_auth_token
        headers = p_headers
        timeout = p_timeout
        priority = p_priority
        last_health_check = OS.get_unix_time()
    
    func to_dict():
        return {
            "name": name,
            "url": url,
            "auth_token": auth_token,
            "headers": headers,
            "timeout": timeout,
            "is_healthy": is_healthy,
            "priority": priority,
            "requires_encryption": requires_encryption,
            "connection_params": connection_params
        }
    
    func from_dict(data):
        name = data.get("name", "")
        url = data.get("url", "")
        auth_token = data.get("auth_token", "")
        headers = data.get("headers", {})
        timeout = data.get("timeout", DEFAULT_TIMEOUT)
        is_healthy = data.get("is_healthy", true)
        priority = data.get("priority", 0)
        requires_encryption = data.get("requires_encryption", false)
        connection_params = data.get("connection_params", {})

class OfflineRequest:
    var endpoint_name = ""
    var request_type = ""
    var endpoint_path = ""
    var body = {}
    var headers = {}
    var timestamp = 0
    var retry_count = 0
    var id = ""
    
    func _init(p_endpoint_name, p_request_type, p_endpoint_path, p_body={}, p_headers={}):
        endpoint_name = p_endpoint_name
        request_type = p_request_type
        endpoint_path = p_endpoint_path
        body = p_body
        headers = p_headers
        timestamp = OS.get_unix_time()
        id = str(timestamp) + "_" + str(randi())
    
    func to_dict():
        return {
            "endpoint_name": endpoint_name,
            "request_type": request_type,
            "endpoint_path": endpoint_path,
            "body": body,
            "headers": headers,
            "timestamp": timestamp,
            "retry_count": retry_count,
            "id": id
        }
    
    func from_dict(data):
        endpoint_name = data.get("endpoint_name", "")
        request_type = data.get("request_type", "")
        endpoint_path = data.get("endpoint_path", "")
        body = data.get("body", {})
        headers = data.get("headers", {})
        timestamp = data.get("timestamp", 0)
        retry_count = data.get("retry_count", 0)
        id = data.get("id", "")

func _ready():
    # Initialize health check timer
    health_check_timer = Timer.new()
    health_check_timer.wait_time = HEALTH_CHECK_INTERVAL
    health_check_timer.one_shot = false
    health_check_timer.connect("timeout", self, "_on_health_check_timer_timeout")
    add_child(health_check_timer)
    health_check_timer.start()
    
    # Load persistent configuration
    load_persistent_data()
    
    # Initialize with default endpoints if needed
    _initialize_default_endpoints()
    
    # Set the last used endpoint from persistent data
    if persistent_data.selected_api != "" and endpoints.has(persistent_data.selected_api):
        current_endpoint = persistent_data.selected_api
    elif not endpoints.empty():
        # Set the highest priority endpoint as default
        var highest_priority = -1
        for endpoint_name in endpoints:
            var endpoint = endpoints[endpoint_name]
            if endpoint.priority > highest_priority:
                highest_priority = endpoint.priority
                current_endpoint = endpoint_name

# API Endpoint Management Methods

func add_endpoint(name, url, auth_token="", headers={}, timeout=DEFAULT_TIMEOUT, priority=0):
    var endpoint = ApiEndpoint.new(name, url, auth_token, headers, timeout, priority)
    endpoints[name] = endpoint
    print("API endpoint added: %s" % name)
    return endpoint

func remove_endpoint(name):
    if endpoints.has(name):
        if current_endpoint == name:
            # Switch to another endpoint if removing the current one
            _find_and_switch_to_next_healthy_endpoint()
        endpoints.erase(name)
        print("API endpoint removed: %s" % name)
        save_persistent_data()
        return true
    return false

func switch_to_endpoint(name):
    if not endpoints.has(name):
        print("Cannot switch to non-existent API endpoint: %s" % name)
        return false
    
    var endpoint = endpoints[name]
    if not endpoint.is_healthy and auto_fallback:
        print("Warning: Switching to unhealthy endpoint %s" % name)
    
    previous_endpoint = current_endpoint
    current_endpoint = name
    persistent_data.selected_api = name
    save_persistent_data()
    
    print("API switched to: %s" % name)
    emit_signal("api_switched", name)
    return true

func get_current_endpoint():
    if current_endpoint == "" or not endpoints.has(current_endpoint):
        return null
    return endpoints[current_endpoint]

func get_endpoint(name):
    if endpoints.has(name):
        return endpoints[name]
    return null

func list_endpoints():
    var result = []
    for name in endpoints:
        var endpoint = endpoints[name]
        result.append({
            "name": name,
            "url": endpoint.url,
            "is_healthy": endpoint.is_healthy,
            "priority": endpoint.priority
        })
    return result

func check_endpoint_health(name):
    if not endpoints.has(name):
        return false
    
    var endpoint = endpoints[name]
    var http_request = HTTPRequest.new()
    add_child(http_request)
    
    var health_check_url = endpoint.url
    if not health_check_url.ends_with("/"):
        health_check_url += "/"
    health_check_url += "health"
    
    http_request.connect("request_completed", self, "_on_health_check_completed", [http_request, name])
    var error = http_request.request(health_check_url, endpoint.headers, true, HTTPClient.METHOD_GET)
    
    if error != OK:
        print("Error checking health for endpoint %s: %s" % [name, error])
        _mark_endpoint_health(name, false)
        http_request.queue_free()
        return false
    
    return true

# Online/Offline Management Methods

func set_online_mode(online):
    if is_online == online:
        return
    
    is_online = online
    print("Connection state changed to: %s" % ("online" if online else "offline"))
    emit_signal("connection_state_changed", is_online)
    
    if is_online:
        # Process offline queue when coming back online
        process_offline_queue()

func is_in_online_mode():
    return is_online

func add_to_offline_queue(endpoint_name, request_type, endpoint_path, body={}, headers={}):
    if offline_queue.size() >= OFFLINE_QUEUE_MAX_SIZE:
        print("Warning: Offline queue is full, removing oldest request")
        offline_queue.pop_front()
    
    var request = OfflineRequest.new(endpoint_name, request_type, endpoint_path, body, headers)
    offline_queue.append(request)
    save_offline_queue()
    print("Request added to offline queue: %s" % request.id)
    return request.id

func process_offline_queue():
    if not is_online or offline_queue.empty():
        return
    
    print("Processing offline queue (%d items)..." % offline_queue.size())
    
    var requests_to_remove = []
    for request in offline_queue:
        if process_offline_request(request):
            requests_to_remove.append(request)
    
    for request in requests_to_remove:
        offline_queue.erase(request)
    
    save_offline_queue()
    print("Offline queue processing completed, %d requests remaining" % offline_queue.size())

func process_offline_request(request):
    if not endpoints.has(request.endpoint_name):
        print("Cannot process offline request: endpoint %s does not exist" % request.endpoint_name)
        return true  # Remove from queue as it can't be processed
    
    var endpoint = endpoints[request.endpoint_name]
    var http_request = HTTPRequest.new()
    add_child(http_request)
    
    var full_url = endpoint.url
    if not full_url.ends_with("/"):
        full_url += "/"
    full_url += request.endpoint_path
    
    # Combine headers
    var merged_headers = endpoint.headers.duplicate()
    for key in request.headers:
        merged_headers[key] = request.headers[key]
    
    # Add authorization if needed
    if endpoint.auth_token != "":
        merged_headers["Authorization"] = "Bearer " + endpoint.auth_token
    
    var method = _get_http_method(request.request_type)
    var body_json = JSON.print(request.body)
    
    http_request.connect("request_completed", self, "_on_offline_request_completed", [http_request, request])
    var error = http_request.request(full_url, merged_headers, true, method, body_json)
    
    if error != OK:
        print("Error sending offline request %s: %s" % [request.id, error])
        request.retry_count += 1
        if request.retry_count >= MAX_RETRY_COUNT:
            print("Max retry count reached for request %s, removing from queue" % request.id)
            return true  # Remove from queue
        return false  # Keep in queue for retry
    
    return false  # Keep in queue until we get a response

# Request Methods

func make_request(endpoint_path, method="GET", body={}, custom_headers={}, use_endpoint=""):
    var target_endpoint_name = use_endpoint if use_endpoint != "" else current_endpoint
    
    if target_endpoint_name == "" or not endpoints.has(target_endpoint_name):
        print("No valid endpoint available for request")
        return false
    
    if not is_online:
        print("Device is offline, adding request to queue")
        add_to_offline_queue(target_endpoint_name, method, endpoint_path, body, custom_headers)
        return true
    
    var endpoint = endpoints[target_endpoint_name]
    var http_request = HTTPRequest.new()
    add_child(http_request)
    
    var full_url = endpoint.url
    if not full_url.ends_with("/"):
        full_url += "/"
    full_url += endpoint_path
    
    # Combine headers
    var merged_headers = endpoint.headers.duplicate()
    for key in custom_headers:
        merged_headers[key] = custom_headers[key]
    
    # Add authorization if needed
    if endpoint.auth_token != "":
        merged_headers["Authorization"] = "Bearer " + endpoint.auth_token
    
    var http_method = _get_http_method(method)
    var body_json = JSON.print(body)
    
    http_request.connect("request_completed", self, "_on_request_completed", [http_request, target_endpoint_name])
    var error = http_request.request(full_url, merged_headers, true, http_method, body_json)
    
    if error != OK:
        print("Error making request to %s: %s" % [full_url, error])
        http_request.queue_free()
        return false
    
    return true

# Data Persistence Methods

func save_persistent_data():
    var file = File.new()
    var data = {
        "selected_api": current_endpoint,
        "custom_endpoints": {},
        "offline_preferences": {
            "auto_fallback": auto_fallback,
        },
        "last_session_time": OS.get_unix_time(),
        "restart_count": persistent_data.restart_count + 1
    }
    
    # Save only custom endpoints (not defaults)
    for name in endpoints:
        var endpoint = endpoints[name]
        if name.begins_with("custom_"):
            data.custom_endpoints[name] = endpoint.to_dict()
    
    var json_string = JSON.print(data, "  ")
    var error = file.open(CONFIG_FILE_PATH, File.WRITE)
    if error != OK:
        print("Error saving persistent data: %s" % error)
        return false
    
    file.store_string(json_string)
    file.close()
    print("Persistent API data saved")
    emit_signal("persistent_data_saved")
    return true

func load_persistent_data():
    var file = File.new()
    if not file.file_exists(CONFIG_FILE_PATH):
        print("No persistent API data found, using defaults")
        return false
    
    var error = file.open(CONFIG_FILE_PATH, File.READ)
    if error != OK:
        print("Error loading persistent data: %s" % error)
        return false
    
    var json_string = file.get_as_text()
    file.close()
    
    var json_result = JSON.parse(json_string)
    if json_result.error != OK:
        print("Error parsing persistent data: %s at line %s" % [json_result.error, json_result.error_line])
        return false
    
    var data = json_result.result
    persistent_data = data
    
    # Load custom endpoints
    if data.has("custom_endpoints"):
        for name in data.custom_endpoints:
            var endpoint_data = data.custom_endpoints[name]
            var endpoint = ApiEndpoint.new(name, endpoint_data.url)
            endpoint.from_dict(endpoint_data)
            endpoints[name] = endpoint
    
    # Load preferences
    if data.has("offline_preferences"):
        var prefs = data.offline_preferences
        auto_fallback = prefs.get("auto_fallback", true)
    
    print("Persistent API data loaded")
    emit_signal("persistent_data_loaded")
    return true

func save_offline_queue():
    var file = File.new()
    var queue_data = []
    
    for request in offline_queue:
        queue_data.append(request.to_dict())
    
    var json_string = JSON.print(queue_data, "  ")
    var error = file.open("user://api_offline_queue.json", File.WRITE)
    if error != OK:
        print("Error saving offline queue: %s" % error)
        return false
    
    file.store_string(json_string)
    file.close()
    return true

func load_offline_queue():
    var file = File.new()
    if not file.file_exists("user://api_offline_queue.json"):
        return false
    
    var error = file.open("user://api_offline_queue.json", File.READ)
    if error != OK:
        print("Error loading offline queue: %s" % error)
        return false
    
    var json_string = file.get_as_text()
    file.close()
    
    var json_result = JSON.parse(json_string)
    if json_result.error != OK:
        print("Error parsing offline queue: %s at line %s" % [json_result.error, json_result.error_line])
        return false
    
    var queue_data = json_result.result
    offline_queue = []
    
    for request_data in queue_data:
        var request = OfflineRequest.new("", "", "")
        request.from_dict(request_data)
        offline_queue.append(request)
    
    print("Loaded %d offline requests" % offline_queue.size())
    return true

# Integration with Eden Garden System

func connect_to_eden_garden(eden_garden_node):
    if not eden_garden_node or not eden_garden_node is Node:
        print("Invalid Eden Garden node provided")
        return false
    
    # Connect Eden Garden signals to API Switch Manager
    eden_garden_node.connect("system_went_offline", self, "_on_eden_garden_offline")
    eden_garden_node.connect("system_went_online", self, "_on_eden_garden_online")
    eden_garden_node.connect("eden_restart_requested", self, "_on_eden_restart_requested")
    
    # Connect API Switch Manager signals to Eden Garden
    self.connect("api_switched", eden_garden_node, "_on_api_switched")
    self.connect("connection_state_changed", eden_garden_node, "_on_connection_state_changed")
    
    print("Connected to Eden Garden System")
    return true

func export_garden_state_to_api(garden_data):
    if not is_online or current_endpoint == "":
        print("Cannot export garden state: system offline or no endpoint selected")
        return false
    
    return make_request("garden/state", "POST", garden_data)

func import_garden_state_from_api():
    if not is_online or current_endpoint == "":
        print("Cannot import garden state: system offline or no endpoint selected")
        return null
    
    if make_request("garden/state", "GET"):
        print("Garden state import requested")
        return true
    return false

# Private Helper Methods

func _initialize_default_endpoints():
    # Only add default endpoints if none are loaded from persistent storage
    if endpoints.empty():
        add_endpoint("default", "https://api.eden-garden.example.com", "", {}, DEFAULT_TIMEOUT, 10)
        add_endpoint("backup", "https://backup-api.eden-garden.example.com", "", {}, DEFAULT_TIMEOUT, 5)
        add_endpoint("local", "http://localhost:8080", "", {}, DEFAULT_TIMEOUT, 1)
        
        # Add OpenAI endpoint with API key from CLAUDE.md if available
        var api_key = _extract_openai_key_from_claude_md()
        if api_key != "":
            var openai_headers = {
                "Content-Type": "application/json",
                "Authorization": "Bearer " + api_key
            }
            add_endpoint("openai", "https://api.openai.com/v1", api_key, openai_headers, 30.0, 8)

func _extract_openai_key_from_claude_md():
    var file = File.new()
    if file.file_exists("/mnt/c/Users/Percision 15/CLAUDE.md"):
        var error = file.open("/mnt/c/Users/Percision 15/CLAUDE.md", File.READ)
        if error != OK:
            return ""
        
        var content = file.get_as_text()
        file.close()
        
        # Look for OpenAI API key pattern
        var regex = RegEx.new()
        regex.compile("sk-[a-zA-Z0-9]{48}")
        var result = regex.search(content)
        if result:
            return result.get_string()
    
    return ""

func _get_http_method(method_str):
    method_str = method_str.to_upper()
    match method_str:
        "GET":
            return HTTPClient.METHOD_GET
        "POST":
            return HTTPClient.METHOD_POST
        "PUT":
            return HTTPClient.METHOD_PUT
        "DELETE":
            return HTTPClient.METHOD_DELETE
        "PATCH":
            return HTTPClient.METHOD_PATCH
        _:
            return HTTPClient.METHOD_GET

func _find_and_switch_to_next_healthy_endpoint():
    var highest_priority = -1
    var best_endpoint = ""
    
    for name in endpoints:
        var endpoint = endpoints[name]
        if endpoint.is_healthy and endpoint.priority > highest_priority:
            highest_priority = endpoint.priority
            best_endpoint = name
    
    if best_endpoint != "":
        switch_to_endpoint(best_endpoint)
        return true
    
    # If no healthy endpoint, switch to highest priority regardless of health
    highest_priority = -1
    for name in endpoints:
        var endpoint = endpoints[name]
        if endpoint.priority > highest_priority:
            highest_priority = endpoint.priority
            best_endpoint = name
    
    if best_endpoint != "":
        switch_to_endpoint(best_endpoint)
        return true
    
    return false

func _mark_endpoint_health(name, is_healthy):
    if not endpoints.has(name):
        return
    
    var endpoint = endpoints[name]
    var health_changed = endpoint.is_healthy != is_healthy
    endpoint.is_healthy = is_healthy
    endpoint.last_health_check = OS.get_unix_time()
    
    if health_changed:
        emit_signal("api_health_changed", name, is_healthy)
        
        # If current endpoint became unhealthy, try to switch to a healthy one
        if name == current_endpoint and not is_healthy and auto_fallback:
            _find_and_switch_to_next_healthy_endpoint()

# Signal Handlers

func _on_health_check_timer_timeout():
    # Check health of all endpoints
    for name in endpoints:
        check_endpoint_health(name)

func _on_health_check_completed(result, response_code, headers, body, http_request, endpoint_name):
    var is_healthy = result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300
    _mark_endpoint_health(endpoint_name, is_healthy)
    http_request.queue_free()

func _on_request_completed(result, response_code, headers, body, http_request, endpoint_name):
    var success = result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300
    var response_body = {}
    
    if success and body.size() > 0:
        var json_result = JSON.parse(body.get_string_from_utf8())
        if json_result.error == OK:
            response_body = json_result.result
    
    emit_signal("request_completed", endpoint_name, success, response_body)
    
    # If request was successful, mark endpoint as healthy
    if success:
        _mark_endpoint_health(endpoint_name, true)
    else:
        # Increment retry counter for this endpoint
        if not retry_counter.has(endpoint_name):
            retry_counter[endpoint_name] = 0
        retry_counter[endpoint_name] += 1
        
        # If too many failures, mark as unhealthy
        if retry_counter[endpoint_name] >= MAX_RETRY_COUNT:
            _mark_endpoint_health(endpoint_name, false)
            retry_counter[endpoint_name] = 0
    
    http_request.queue_free()

func _on_offline_request_completed(result, response_code, headers, body, http_request, request):
    var success = result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300
    
    # Remove from offline queue only if successful
    if success:
        var idx = offline_queue.find(request)
        if idx >= 0:
            offline_queue.remove(idx)
            save_offline_queue()
    else:
        request.retry_count += 1
    
    http_request.queue_free()

func _on_eden_garden_offline():
    set_online_mode(false)

func _on_eden_garden_online():
    set_online_mode(true)

func _on_eden_restart_requested():
    save_persistent_data()
    save_offline_queue()