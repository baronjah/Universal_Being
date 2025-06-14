extends Node
class_name LuminousGeminiIntegration

# Signals
signal api_initialized(success)
signal completion_received(response_data)
signal batch_completed(batch_id, results)
signal error_occurred(error_code, error_message)
signal usage_updated(usage_data)

# API Constants
const API_VERSION = "v1beta"
const BASE_URL = "https://generativelanguage.googleapis.com"
const DEFAULT_MODEL = "gemini-1.5-pro"
const ADVANCED_MODEL = "gemini-1.5-pro-latest"
const MAX_TOKENS = 1024 * 32  # 32K context window for Gemini Advanced
const DEFAULT_TEMPERATURE = 0.7
const DEFAULT_TOP_P = 0.95
const DEFAULT_TOP_K = 40
const RESPONSE_MIME_TYPE = "application/json"

# Configuration
var api_key: String = ""
var current_model: String = DEFAULT_MODEL
var use_advanced_model: bool = true
var max_parallel_requests: int = 5
var request_timeout: int = 60
var auto_retry: bool = true
var max_retries: int = 3
var retry_delay: int = 1000

# Request tracking
var active_requests: Dictionary = {}
var request_queue: Array = []
var completed_requests: Dictionary = {}
var request_history: Array = []

# Rate limiting and usage tracking
var rate_limit_remaining: int = 100
var rate_limit_reset: int = 0
var tokens_used_input: int = 0
var tokens_used_output: int = 0
var total_requests: int = 0
var successful_requests: int = 0
var failed_requests: int = 0

# HTTP Client
var http_client: HTTPClient
var request_mutex: Mutex
var usage_mutex: Mutex

# Multi-threaded operation
var request_thread: Thread
var should_exit: bool = false
var thread_semaphore: Semaphore

# Batching system
var batch_queue: Array = []
var batch_results: Dictionary = {}
var active_batches: Dictionary = {}

# Game generation templates
var game_templates: Dictionary = {}
var code_templates: Dictionary = {}
var system_prompts: Dictionary = {}

func _init():
    request_mutex = Mutex.new()
    usage_mutex = Mutex.new()
    thread_semaphore = Semaphore.new()
    _load_templates()

func _ready():
    # Start request processing thread
    request_thread = Thread.new()
    request_thread.start(_process_request_queue)

func _exit_tree():
    # Ensure clean shutdown
    request_mutex.lock()
    should_exit = true
    request_mutex.unlock()
    
    thread_semaphore.post()
    if request_thread and request_thread.is_started():
        request_thread.wait_to_finish()

# API Configuration
func initialize(key: String, use_advanced: bool = true) -> bool:
    api_key = key
    use_advanced_model = use_advanced
    current_model = ADVANCED_MODEL if use_advanced else DEFAULT_MODEL
    
    var success = _test_api_connection()
    emit_signal("api_initialized", success)
    return success

func set_model(model_name: String) -> void:
    current_model = model_name

func set_timeout(seconds: int) -> void:
    request_timeout = seconds

# Core API Functionality
func generate_content(prompt: String, parameters: Dictionary = {}) -> String:
    var request_id = _generate_request_id()
    var merged_params = _merge_with_defaults(parameters)
    
    var data = {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": prompt
                    }
                ]
            }
        ],
        "generationConfig": merged_params
    }
    
    _queue_request(request_id, "generate_content", data)
    return request_id

func generate_content_stream(prompt: String, parameters: Dictionary = {}) -> String:
    var request_id = _generate_request_id()
    var merged_params = _merge_with_defaults(parameters)
    
    var data = {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": prompt
                    }
                ]
            }
        ],
        "generationConfig": merged_params
    }
    
    _queue_request(request_id, "generate_content_stream", data)
    return request_id

func count_tokens(text: String) -> String:
    var request_id = _generate_request_id()
    
    var data = {
        "contents": [
            {
                "parts": [
                    {
                        "text": text
                    }
                ]
            }
        ]
    }
    
    _queue_request(request_id, "count_tokens", data)
    return request_id

func batch_generate(prompts: Array, parameters: Dictionary = {}) -> String:
    var batch_id = _generate_request_id()
    
    # Initialize batch tracking
    request_mutex.lock()
    active_batches[batch_id] = {
        "total": prompts.size(),
        "completed": 0,
        "results": [],
        "parameters": parameters
    }
    request_mutex.unlock()
    
    # Queue individual requests within the batch
    for i in range(prompts.size()):
        var prompt = prompts[i]
        var request_id = generate_content(prompt, parameters)
        
        request_mutex.lock()
        if not batch_queue.has(batch_id):
            batch_queue[batch_id] = []
        batch_queue[batch_id].append(request_id)
        request_mutex.unlock()
    
    return batch_id

# Game Generation Helpers
func generate_game_script(script_type: String, parameters: Dictionary) -> String:
    var template = _get_game_template("script", script_type)
    if template.empty():
        return ""
    
    var prompt = template.format(parameters)
    return generate_content(prompt)

func generate_game_scene(scene_type: String, parameters: Dictionary) -> String:
    var template = _get_game_template("scene", scene_type)
    if template.empty():
        return ""
    
    var prompt = template.format(parameters)
    return generate_content(prompt)

func generate_game_system(system_type: String, parameters: Dictionary) -> String:
    var template = _get_game_template("system", system_type)
    if template.empty():
        return ""
    
    var prompt = template.format(parameters)
    return generate_content(prompt)

func generate_project_structure(game_type: String, project_name: String) -> String:
    var template = _get_game_template("project", game_type)
    if template.empty():
        return ""
    
    var parameters = {
        "project_name": project_name,
        "version": "1.0.0",
        "author": "Luminous OS"
    }
    
    var prompt = template.format(parameters)
    return generate_content(prompt)

# Request Management
func get_request_status(request_id: String) -> Dictionary:
    request_mutex.lock()
    var status = {}
    
    if active_requests.has(request_id):
        status = {
            "status": "in_progress",
            "type": active_requests[request_id].type
        }
    elif completed_requests.has(request_id):
        status = {
            "status": "completed",
            "type": completed_requests[request_id].type,
            "result": completed_requests[request_id].result
        }
    else:
        status = {
            "status": "unknown"
        }
    
    request_mutex.unlock()
    return status

func get_batch_status(batch_id: String) -> Dictionary:
    request_mutex.lock()
    var status = {}
    
    if active_batches.has(batch_id):
        var batch = active_batches[batch_id]
        status = {
            "status": "in_progress",
            "total": batch.total,
            "completed": batch.completed,
            "progress": float(batch.completed) / batch.total
        }
    elif batch_results.has(batch_id):
        status = {
            "status": "completed",
            "results": batch_results[batch_id]
        }
    else:
        status = {
            "status": "unknown"
        }
    
    request_mutex.unlock()
    return status

func get_usage_stats() -> Dictionary:
    usage_mutex.lock()
    var stats = {
        "tokens_input": tokens_used_input,
        "tokens_output": tokens_used_output,
        "total_requests": total_requests,
        "successful_requests": successful_requests,
        "failed_requests": failed_requests,
        "active_requests": active_requests.size(),
        "queued_requests": request_queue.size()
    }
    usage_mutex.unlock()
    
    return stats

func cancel_request(request_id: String) -> bool:
    request_mutex.lock()
    var found = false
    
    if active_requests.has(request_id):
        active_requests.erase(request_id)
        found = true
    
    var queue_index = -1
    for i in range(request_queue.size()):
        if request_queue[i].id == request_id:
            queue_index = i
            break
    
    if queue_index >= 0:
        request_queue.remove_at(queue_index)
        found = true
    
    request_mutex.unlock()
    return found

func clear_request_history() -> void:
    request_mutex.lock()
    request_history.clear()
    request_mutex.unlock()

# Private Helpers
func _queue_request(request_id: String, type: String, data: Dictionary) -> void:
    var request_data = {
        "id": request_id,
        "type": type,
        "data": data,
        "attempt": 0,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    request_mutex.lock()
    request_queue.push_back(request_data)
    active_requests[request_id] = {
        "type": type,
        "timestamp": Time.get_unix_time_from_system()
    }
    request_mutex.unlock()
    
    # Signal the processing thread
    thread_semaphore.post()

func _process_request_queue() -> void:
    while true:
        thread_semaphore.wait()
        
        request_mutex.lock()
        var should_stop = should_exit
        request_mutex.unlock()
        
        if should_stop:
            break
        
        request_mutex.lock()
        if request_queue.size() > 0:
            var request = request_queue.pop_front()
            request_mutex.unlock()
            
            _process_request(request)
        else:
            request_mutex.unlock()

func _process_request(request: Dictionary) -> void:
    var request_id = request.id
    var type = request.type
    var data = request.data
    var attempt = request.attempt
    
    var result = {}
    var success = false
    
    match type:
        "generate_content":
            result = _execute_generate_content(data)
            success = result.has("success") and result.success
        "generate_content_stream":
            result = _execute_generate_content_stream(data)
            success = result.has("success") and result.success
        "count_tokens":
            result = _execute_count_tokens(data)
            success = result.has("success") and result.success
    
    request_mutex.lock()
    active_requests.erase(request_id)
    
    if success:
        completed_requests[request_id] = {
            "type": type,
            "result": result,
            "timestamp": Time.get_unix_time_from_system()
        }
        
        # Update batch status if part of a batch
        for batch_id in batch_queue:
            if batch_queue[batch_id].has(request_id):
                active_batches[batch_id].completed += 1
                active_batches[batch_id].results.append(result)
                
                # Check if batch is complete
                if active_batches[batch_id].completed == active_batches[batch_id].total:
                    batch_results[batch_id] = active_batches[batch_id].results
                    batch_queue.erase(batch_id)
                    active_batches.erase(batch_id)
                    
                    # Emit batch completion signal
                    call_deferred("emit_signal", "batch_completed", batch_id, batch_results[batch_id])
    else:
        # Handle retry if enabled
        if auto_retry and attempt < max_retries:
            request.attempt += 1
            request_queue.push_back(request)
        else:
            # Update failure stats
            usage_mutex.lock()
            failed_requests += 1
            usage_mutex.unlock()
            
            # Emit error signal
            if result.has("error"):
                call_deferred("emit_signal", "error_occurred", result.error_code, result.error_message)
    
    request_mutex.unlock()
    
    # Emit completion signal for individual requests
    if success:
        call_deferred("emit_signal", "completion_received", result)

func _execute_generate_content(data: Dictionary) -> Dictionary:
    var url = "{0}/{1}/models/{2}:generateContent?key={3}".format([
        BASE_URL, API_VERSION, current_model, api_key
    ])
    
    var json_data = JSON.stringify(data)
    var headers = [
        "Content-Type: application/json",
        "Accept: application/json"
    ]
    
    var response = _make_http_request(url, headers, HTTPClient.METHOD_POST, json_data)
    
    if response.has("error"):
        return response
    
    # Parse response and update token usage
    var json_response = JSON.parse_string(response.body)
    if json_response and json_response.has("candidates") and json_response.candidates.size() > 0:
        var candidate = json_response.candidates[0]
        var content = ""
        
        if candidate.has("content") and candidate.content.has("parts"):
            for part in candidate.content.parts:
                if part.has("text"):
                    content += part.text
        
        # Update usage statistics
        if json_response.has("usageMetadata"):
            usage_mutex.lock()
            tokens_used_input += json_response.usageMetadata.promptTokenCount
            tokens_used_output += json_response.usageMetadata.candidatesTokenCount
            total_requests += 1
            successful_requests += 1
            usage_mutex.unlock()
        
        return {
            "success": true,
            "content": content,
            "raw_response": json_response
        }
    else:
        return {
            "success": false,
            "error_code": "parse_error",
            "error_message": "Could not parse response"
        }

func _execute_generate_content_stream(data: Dictionary) -> Dictionary:
    # Streamed content not fully implemented in this example
    # Would require additional state management and chunked response handling
    return _execute_generate_content(data)

func _execute_count_tokens(data: Dictionary) -> Dictionary:
    var url = "{0}/{1}/models/{2}:countTokens?key={3}".format([
        BASE_URL, API_VERSION, current_model, api_key
    ])
    
    var json_data = JSON.stringify(data)
    var headers = [
        "Content-Type: application/json",
        "Accept: application/json"
    ]
    
    var response = _make_http_request(url, headers, HTTPClient.METHOD_POST, json_data)
    
    if response.has("error"):
        return response
    
    var json_response = JSON.parse_string(response.body)
    if json_response and json_response.has("totalTokens"):
        return {
            "success": true,
            "token_count": json_response.totalTokens
        }
    else:
        return {
            "success": false,
            "error_code": "parse_error",
            "error_message": "Could not parse token count response"
        }

func _make_http_request(url: String, headers: Array, method: int, data: String = "") -> Dictionary:
    var http_request = HTTPRequest.new()
    add_child(http_request)
    
    # Configure request
    http_request.timeout = request_timeout
    
    # Send request
    var error = http_request.request(url, headers, method, data)
    if error != OK:
        http_request.queue_free()
        return {
            "success": false,
            "error_code": "request_failed",
            "error_message": "HTTP Request failed with error code: " + str(error)
        }
    
    # Wait for response
    var response = await http_request.request_completed
    http_request.queue_free()
    
    var result_code = response[0]
    var response_code = response[1]
    var response_headers = response[2]
    var body = response[3]
    
    if result_code != HTTPRequest.RESULT_SUCCESS:
        return {
            "success": false,
            "error_code": "network_error",
            "error_message": "Network error: " + str(result_code)
        }
    
    if response_code < 200 or response_code >= 300:
        var error_message = "HTTP error: " + str(response_code)
        var body_text = body.get_string_from_utf8()
        
        # Try to parse error from JSON body
        var json_result = JSON.parse_string(body_text)
        if json_result and json_result.has("error"):
            error_message = json_result.error.message
        
        return {
            "success": false,
            "error_code": "http_error_" + str(response_code),
            "error_message": error_message
        }
    
    # Parse rate limit headers if present
    for header in response_headers:
        var header_parts = header.split(":", true, 1)
        if header_parts.size() == 2:
            var header_name = header_parts[0].strip_edges().to_lower()
            var header_value = header_parts[1].strip_edges()
            
            if header_name == "x-ratelimit-remaining":
                rate_limit_remaining = int(header_value)
            elif header_name == "x-ratelimit-reset":
                rate_limit_reset = int(header_value)
    
    return {
        "success": true,
        "status_code": response_code,
        "headers": response_headers,
        "body": body.get_string_from_utf8()
    }

func _test_api_connection() -> bool:
    var test_data = {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": "Hello, are you operational?"
                    }
                ]
            }
        ],
        "generationConfig": {
            "temperature": 0.1,
            "maxOutputTokens": 10
        }
    }
    
    var url = "{0}/{1}/models/{2}:generateContent?key={3}".format([
        BASE_URL, API_VERSION, current_model, api_key
    ])
    
    var json_data = JSON.stringify(test_data)
    var headers = [
        "Content-Type: application/json",
        "Accept: application/json"
    ]
    
    var response = _make_http_request(url, headers, HTTPClient.METHOD_POST, json_data)
    return response.has("success") and response.success

func _merge_with_defaults(params: Dictionary) -> Dictionary:
    var merged = {
        "temperature": DEFAULT_TEMPERATURE,
        "topP": DEFAULT_TOP_P,
        "topK": DEFAULT_TOP_K,
        "maxOutputTokens": MAX_TOKENS,
        "stopSequences": []
    }
    
    for key in params:
        merged[key] = params[key]
    
    return merged

func _generate_request_id() -> String:
    return "req_" + str(randi()).pad_zeros(10)

func _get_game_template(category: String, template_type: String) -> String:
    if not game_templates.has(category):
        return ""
    
    if not game_templates[category].has(template_type):
        return ""
    
    return game_templates[category][template_type]

func _load_templates() -> void:
    # Script templates
    game_templates["script"] = {
        "player": """
Create a Godot 4 GDScript class for a player character in a game. The player should have the following characteristics:
- Character name: {name}
- Health: {health}
- Speed: {speed}
- Main abilities: {abilities}
- Game type: {game_type}

Include proper documentation, signal declarations, and organized code structure.
Return ONLY the complete GDScript code with no additional text.
""",
        "enemy": """
Create a Godot 4 GDScript class for an enemy character in a game. The enemy should have the following characteristics:
- Enemy type: {enemy_type}
- Health: {health}
- Attack damage: {damage}
- Behavior pattern: {behavior}
- Special abilities: {abilities}

Include proper documentation, signal declarations, and organized code structure.
Return ONLY the complete GDScript code with no additional text.
""",
        "game_controller": """
Create a Godot 4 GDScript class for the main game controller. This should handle:
- Game state management (menu, playing, paused, game over)
- Score tracking
- Level management
- Save/load functionality
- Game type: {game_type}
- Core mechanics: {mechanics}

Include proper documentation, signal declarations, and organized code structure.
Return ONLY the complete GDScript code with no additional text.
"""
    }
    
    # Scene templates
    game_templates["scene"] = {
        "level": """
Describe the structure of a Godot 4 scene file (.tscn) for a game level with the following characteristics:
- Level name: {name}
- Level type: {level_type}
- Main features: {features}
- Enemy types: {enemies}
- Collectibles: {collectibles}
- Special objects: {special_objects}

Include node hierarchy, attached scripts, and basic property configurations.
Return the description in a structured format that can be used to generate the actual scene file.
""",
        "ui": """
Describe the structure of a Godot 4 scene file (.tscn) for a UI screen with the following characteristics:
- Screen type: {screen_type}
- Main elements: {elements}
- Layout style: {layout}
- Color scheme: {colors}
- Animations: {animations}

Include node hierarchy, attached scripts, and basic property configurations.
Return the description in a structured format that can be used to generate the actual scene file.
"""
    }
    
    # System templates
    game_templates["system"] = {
        "inventory": """
Create a Godot 4 GDScript class for an inventory system with the following features:
- Inventory size: {size}
- Item types: {item_types}
- Stacking: {stackable}
- Weight system: {weight_system}
- UI integration: {ui_integration}

Include proper documentation, signal declarations, and organized code structure.
Return ONLY the complete GDScript code with no additional text.
""",
        "dialog": """
Create a Godot 4 GDScript class for a dialog system with the following features:
- Dialog tree structure: {structure}
- Character support: {characters}
- Branching options: {branching}
- Variables and conditions: {variables}
- UI integration: {ui_integration}

Include proper documentation, signal declarations, and organized code structure.
Return ONLY the complete GDScript code with no additional text.
"""
    }
    
    # Project templates
    game_templates["project"] = {
        "2d_platformer": """
Create a detailed project structure for a 2D platformer game in Godot 4 with the following details:
- Game name: {project_name}
- Version: {version}
- Author: {author}

Include folder structure, key script files, scene organization, and resource requirements.
Format the response as a structured list that can be used to generate the actual project files and folders.
""",
        "top_down_rpg": """
Create a detailed project structure for a top-down RPG game in Godot 4 with the following details:
- Game name: {project_name}
- Version: {version}
- Author: {author}

Include folder structure, key script files, scene organization, and resource requirements.
Format the response as a structured list that can be used to generate the actual project files and folders.
""",
        "fps": """
Create a detailed project structure for a first-person shooter game in Godot 4 with the following details:
- Game name: {project_name}
- Version: {version}
- Author: {author}

Include folder structure, key script files, scene organization, and resource requirements.
Format the response as a structured list that can be used to generate the actual project files and folders.
"""
    }
    
    # System prompts for various tasks
    system_prompts = {
        "game_analysis": """
You are a game design analysis expert. Analyze the following game concept or code snippet and provide insights on:
1. Core gameplay mechanics
2. Player experience and engagement factors
3. Technical implementation considerations
4. Potential improvements or optimizations

Be specific, technical, and actionable in your analysis.
""",
        "code_optimization": """
You are a Godot engine optimization expert. Review the following code and provide specific optimizations for:
1. Performance improvements
2. Memory efficiency
3. Code readability and maintainability
4. Best practices for Godot 4

Provide example code for each optimization suggested.
""",
        "asset_generation": """
You are a game asset designer. Create detailed specifications for the following game asset:
1. Visual description (appearance, colors, dimensions)
2. Animation requirements (if applicable)
3. Technical specifications (format, resolution, polygon count)
4. Integration instructions for Godot 4

Be specific and detailed enough that this specification could be used to create the actual asset.
"""
    }