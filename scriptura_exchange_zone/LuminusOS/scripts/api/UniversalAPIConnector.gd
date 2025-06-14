class_name UniversalAPIConnector
extends Node

# ================ API CONNECTION SYSTEM ================
# Universal connector that bridges to any API service

# API Service Configurations
var api_registry = {}
var api_auth_data = {}
var active_connections = {}
var default_api = ""
var simulation_mode = true
var connection_timeout = 10.0
var max_retries = 3
var auto_refresh_tokens = true
var offline_response_cache = {}

# Known API Services
const KNOWN_SERVICES = {
    "openai": {
        "base_url": "https://api.openai.com/v1",
        "required_auth": ["api_key"],
        "endpoints": {
            "chat": "/chat/completions",
            "embeddings": "/embeddings",
            "images": "/images/generations"
        },
        "default_model": "gpt-4o",
        "response_format": "json"
    },
    "claude": {
        "base_url": "https://api.anthropic.com/v1",
        "required_auth": ["api_key"],
        "endpoints": {
            "chat": "/messages",
            "complete": "/complete"
        },
        "default_model": "claude-3-opus-20240229",
        "response_format": "json"
    },
    "gemini": {
        "base_url": "https://generativelanguage.googleapis.com/v1beta",
        "required_auth": ["api_key"],
        "endpoints": {
            "generate": "/models/gemini-1.5-pro:generateContent"
        },
        "default_model": "gemini-1.5-pro",
        "response_format": "json"
    },
    "stability": {
        "base_url": "https://api.stability.ai/v1",
        "required_auth": ["api_key"],
        "endpoints": {
            "text-to-image": "/generation/text-to-image"
        },
        "default_model": "stable-diffusion-xl-1024-v1-0",
        "response_format": "json"
    },
    "elevenlabs": {
        "base_url": "https://api.elevenlabs.io/v1",
        "required_auth": ["api_key"],
        "endpoints": {
            "text-to-speech": "/text-to-speech"
        },
        "default_model": "eleven_monolingual_v1",
        "response_format": "audio"
    }
}

# API Operation Status
var request_counter = 0
var pending_requests = {}
var completed_requests = {}
var failed_requests = {}
var active_tasks = {}

# Signals
signal api_registered(service_name)
signal api_connected(service_name, successful)
signal request_sent(request_id, service_name, endpoint)
signal response_received(request_id, service_name, data)
signal request_failed(request_id, service_name, error)
signal all_services_ready()
signal simulation_response(request_id, service_name, simulated_data)

# ================ INITIALIZATION ================
func _ready():
    initialize_registry()
    
    # Create HTTPRequest node for API requests
    var request_handler = HTTPRequest.new()
    request_handler.name = "RequestHandler"
    add_child(request_handler)
    
    # Set up autoload for secure storage
    var secure_storage = SecureStorage.new()
    secure_storage.name = "SecureStorage"
    add_child(secure_storage)
    
    print("Universal API Connector initialized")

# Create secure storage for API keys
class SecureStorage:
    extends Node
    
    var encrypted_data = {}
    var encryption_key = "luminusos_api_secure"
    
    func store_key(service_name, key_data):
        # In a real implementation, this would properly encrypt the API key
        # For this demo, we'll just store it with minimal obfuscation
        encrypted_data[service_name] = _simple_encrypt(key_data)
        return true
    
    func retrieve_key(service_name):
        if service_name in encrypted_data:
            return _simple_decrypt(encrypted_data[service_name])
        return null
    
    func _simple_encrypt(data):
        # This is NOT real encryption - just simple obfuscation for demo
        # In a real implementation, use proper encryption
        var result = ""
        for c in data:
            result += char(ord(c) + 1)
        return result
    
    func _simple_decrypt(data):
        # Decrypt the simple obfuscation
        var result = ""
        for c in data:
            result += char(ord(c) - 1)
        return result
    
    func has_key(service_name):
        return service_name in encrypted_data
    
    func delete_key(service_name):
        if service_name in encrypted_data:
            encrypted_data.erase(service_name)
            return true
        return false

func initialize_registry():
    # Register known API services
    for service_name in KNOWN_SERVICES:
        register_api_service(
            service_name,
            KNOWN_SERVICES[service_name].base_url,
            KNOWN_SERVICES[service_name].required_auth,
            KNOWN_SERVICES[service_name].endpoints
        )
    
    print("Registered " + str(KNOWN_SERVICES.size()) + " known API services")

# ================ API REGISTRATION AND CONNECTION ================
func register_api_service(service_name, base_url, required_auth, endpoints, service_config = {}):
    # Register a new API service in the registry
    api_registry[service_name] = {
        "base_url": base_url,
        "required_auth": required_auth,
        "endpoints": endpoints,
        "status": "registered",
        "config": service_config
    }
    
    # Initialize auth data
    api_auth_data[service_name] = {}
    
    print("Registered API service: " + service_name)
    emit_signal("api_registered", service_name)
    
    return true

func set_api_key(service_name, api_key):
    # Store API key securely
    if not service_name in api_registry:
        push_warning("Unknown API service: " + service_name)
        return false
    
    # Store in secure storage
    var secure_storage = get_node("SecureStorage")
    secure_storage.store_key(service_name, api_key)
    
    # Mark auth as complete
    api_auth_data[service_name]["has_key"] = true
    
    print("API key set for service: " + service_name)
    return true

func connect_to_api(service_name):
    # Establish connection to API service
    if not service_name in api_registry:
        push_warning("Unknown API service: " + service_name)
        return false
    
    # If in simulation mode, just pretend to connect
    if simulation_mode:
        api_registry[service_name].status = "connected"
        active_connections[service_name] = {
            "connected_at": Time.get_unix_time_from_system(),
            "simulated": true
        }
        
        print("Simulated connection to API service: " + service_name)
        emit_signal("api_connected", service_name, true)
        return true
    
    # Check for required auth
    var secure_storage = get_node("SecureStorage")
    for auth_item in api_registry[service_name].required_auth:
        if auth_item == "api_key" and not secure_storage.has_key(service_name):
            push_warning("Missing API key for service: " + service_name)
            return false
    
    # Make a test request to verify connection
    var test_result = _test_api_connection(service_name)
    
    if test_result:
        api_registry[service_name].status = "connected"
        active_connections[service_name] = {
            "connected_at": Time.get_unix_time_from_system(),
            "simulated": false
        }
        
        print("Connected to API service: " + service_name)
        emit_signal("api_connected", service_name, true)
        return true
    else:
        api_registry[service_name].status = "connection_failed"
        emit_signal("api_connected", service_name, false)
        return false

func _test_api_connection(service_name):
    # Make a minimal test request to verify connection
    # In a real implementation, this would make an actual API call
    
    # Simulate success most of the time
    var success = randf() < 0.9
    return success

func connect_all_services():
    # Connect to all registered API services
    var connected_count = 0
    
    for service_name in api_registry:
        if connect_to_api(service_name):
            connected_count += 1
    
    if connected_count == api_registry.size():
        emit_signal("all_services_ready")
    
    return connected_count

func disconnect_from_api(service_name):
    # Disconnect from API service
    if not service_name in active_connections:
        return false
    
    active_connections.erase(service_name)
    api_registry[service_name].status = "registered"
    
    print("Disconnected from API service: " + service_name)
    return true

func set_default_api(service_name):
    # Set the default API service
    if not service_name in api_registry:
        push_warning("Unknown API service: " + service_name)
        return false
    
    default_api = service_name
    print("Default API service set to: " + service_name)
    return true

# ================ REQUEST HANDLING ================
func send_request(service_name, endpoint_name, data, options = {}):
    # Send a request to an API endpoint
    if not service_name in api_registry:
        push_warning("Unknown API service: " + service_name)
        return null
    
    if not endpoint_name in api_registry[service_name].endpoints:
        push_warning("Unknown endpoint for service " + service_name + ": " + endpoint_name)
        return null
    
    # Create request ID
    request_counter += 1
    var request_id = str(request_counter) + "_" + service_name + "_" + endpoint_name
    
    # If in simulation mode, generate a simulated response
    if simulation_mode or (service_name in active_connections and active_connections[service_name].simulated):
        var simulated_data = _generate_simulated_response(service_name, endpoint_name, data)
        
        # Store in completed requests
        completed_requests[request_id] = {
            "service": service_name,
            "endpoint": endpoint_name,
            "data": data,
            "response": simulated_data,
            "simulated": true,
            "timestamp": Time.get_unix_time_from_system()
        }
        
        # Cache for offline use
        var cache_key = service_name + "_" + endpoint_name + "_" + str(hash(str(data)))
        offline_response_cache[cache_key] = simulated_data
        
        print("Simulated response for " + service_name + ":" + endpoint_name)
        emit_signal("simulation_response", request_id, service_name, simulated_data)
        emit_signal("response_received", request_id, service_name, simulated_data)
        
        return request_id
    
    # Connect if not already connected
    if not service_name in active_connections:
        if not connect_to_api(service_name):
            push_warning("Failed to connect to API service: " + service_name)
            return null
    
    # Prepare the request
    var url = api_registry[service_name].base_url + api_registry[service_name].endpoints[endpoint_name]
    var headers = _prepare_headers(service_name, options)
    var request_data = _prepare_request_data(service_name, endpoint_name, data)
    
    # Store in pending requests
    pending_requests[request_id] = {
        "service": service_name,
        "endpoint": endpoint_name,
        "data": data,
        "options": options,
        "timestamp": Time.get_unix_time_from_system(),
        "retries": 0
    }
    
    # Get HTTP request node
    var request_handler = get_node("RequestHandler")
    
    # In a real implementation, this would make the actual HTTP request
    # For this demo, we'll simulate the HTTP request
    print("Sending request to " + service_name + ":" + endpoint_name)
    emit_signal("request_sent", request_id, service_name, endpoint_name)
    
    # Simulate response after a delay
    _simulate_http_response(request_id)
    
    return request_id

func _prepare_headers(service_name, options):
    # Prepare headers for the request
    var headers = []
    
    # Add content type
    headers.append("Content-Type: application/json")
    
    # Add authorization
    var secure_storage = get_node("SecureStorage")
    if secure_storage.has_key(service_name):
        var api_key = secure_storage.retrieve_key(service_name)
        
        match service_name:
            "openai":
                headers.append("Authorization: Bearer " + api_key)
            "claude":
                headers.append("x-api-key: " + api_key)
            "gemini":
                # For Gemini, API key is typically added as a URL parameter
                pass
            _:
                # Default format
                headers.append("Authorization: Bearer " + api_key)
    
    # Add custom headers from options
    if "headers" in options:
        for header_name in options.headers:
            headers.append(header_name + ": " + options.headers[header_name])
    
    return headers

func _prepare_request_data(service_name, endpoint_name, data):
    # Format request data according to API requirements
    var formatted_data = data.duplicate()
    
    # Add service-specific formatting
    match service_name:
        "openai":
            if endpoint_name == "chat" and not "model" in formatted_data:
                formatted_data["model"] = KNOWN_SERVICES.openai.default_model
        
        "claude":
            if endpoint_name == "chat" and not "model" in formatted_data:
                formatted_data["model"] = KNOWN_SERVICES.claude.default_model
        
        "gemini":
            if endpoint_name == "generate" and not "model" in formatted_data:
                formatted_data["model"] = KNOWN_SERVICES.gemini.default_model
    
    # Convert to JSON
    return JSON.stringify(formatted_data)

func _simulate_http_response(request_id):
    # Simulate HTTP response for demo purposes
    if not request_id in pending_requests:
        return
    
    var request = pending_requests[request_id]
    
    # Create a timer to simulate network delay
    var timer = Timer.new()
    timer.one_shot = true
    timer.wait_time = randf_range(0.5, 2.0)
    add_child(timer)
    timer.timeout.connect(_on_response_timer_timeout.bind(request_id, timer))
    timer.start()

func _on_response_timer_timeout(request_id, timer):
    # Handle simulated response
    timer.queue_free()
    
    if not request_id in pending_requests:
        return
    
    var request = pending_requests[request_id]
    
    # Simulate success most of the time
    var success = randf() < 0.9
    
    if success:
        # Generate simulated response
        var response_data = _generate_simulated_response(
            request.service, 
            request.endpoint, 
            request.data
        )
        
        # Move from pending to completed
        pending_requests.erase(request_id)
        completed_requests[request_id] = {
            "service": request.service,
            "endpoint": request.endpoint,
            "data": request.data,
            "response": response_data,
            "simulated": true,
            "timestamp": Time.get_unix_time_from_system()
        }
        
        # Cache for offline use
        var cache_key = request.service + "_" + request.endpoint + "_" + str(hash(str(request.data)))
        offline_response_cache[cache_key] = response_data
        
        print("Response received for " + request.service + ":" + request.endpoint)
        emit_signal("response_received", request_id, request.service, response_data)
    else:
        # Simulate failure
        var error = "Simulated network error"
        
        # Retry or report failure
        if request.retries < max_retries:
            # Retry the request
            request.retries += 1
            print("Retrying request (attempt " + str(request.retries) + ")")
            _simulate_http_response(request_id)
        else:
            # Move from pending to failed
            pending_requests.erase(request_id)
            failed_requests[request_id] = {
                "service": request.service,
                "endpoint": request.endpoint,
                "data": request.data,
                "error": error,
                "timestamp": Time.get_unix_time_from_system()
            }
            
            print("Request failed after " + str(max_retries) + " retries")
            emit_signal("request_failed", request_id, request.service, error)

func _generate_simulated_response(service_name, endpoint_name, data):
    # Generate a simulated response for testing
    match service_name:
        "openai":
            return _simulate_openai_response(endpoint_name, data)
        "claude":
            return _simulate_claude_response(endpoint_name, data)
        "gemini":
            return _simulate_gemini_response(endpoint_name, data)
        "stability":
            return _simulate_stability_response(endpoint_name, data)
        "elevenlabs":
            return _simulate_elevenlabs_response(endpoint_name, data)
        _:
            # Generic response
            return {
                "status": "success",
                "simulated": true,
                "service": service_name,
                "data": {"response": "Simulated response for " + service_name}
            }

func _simulate_openai_response(endpoint_name, data):
    # Simulate OpenAI API response
    match endpoint_name:
        "chat":
            # Simulate chat completion
            var response_content = "This is a simulated response from OpenAI ChatGPT."
            
            # If we have user message, make the response more contextual
            if "messages" in data:
                for message in data.messages:
                    if message.role == "user":
                        var user_content = message.content
                        if typeof(user_content) == TYPE_STRING and user_content.length() > 0:
                            response_content = "In response to your message about '" + user_content.substr(0, 20) + "...', here is my simulated reply."
            
            return {
                "id": "sim_" + str(randi()),
                "object": "chat.completion",
                "created": Time.get_unix_time_from_system(),
                "model": data.get("model", KNOWN_SERVICES.openai.default_model),
                "choices": [
                    {
                        "index": 0,
                        "message": {
                            "role": "assistant",
                            "content": response_content
                        },
                        "finish_reason": "stop"
                    }
                ],
                "usage": {
                    "prompt_tokens": 20,
                    "completion_tokens": 30,
                    "total_tokens": 50
                }
            }
        
        "embeddings":
            # Simulate embeddings
            var embedding_values = []
            for i in range(10):  # Simplified embedding vector
                embedding_values.append(randf() - 0.5)
            
            return {
                "object": "list",
                "data": [
                    {
                        "object": "embedding",
                        "embedding": embedding_values,
                        "index": 0
                    }
                ],
                "model": data.get("model", "text-embedding-ada-002"),
                "usage": {
                    "prompt_tokens": 10,
                    "total_tokens": 10
                }
            }
        
        "images":
            # Simulate image generation (just returning a fake URL)
            return {
                "created": Time.get_unix_time_from_system(),
                "data": [
                    {
                        "url": "https://example.com/simulated-image.jpg"
                    }
                ]
            }
        
        _:
            # Generic endpoint response
            return {
                "status": "success",
                "simulated": true,
                "service": "openai",
                "endpoint": endpoint_name,
                "message": "Simulated response for unknown OpenAI endpoint"
            }

func _simulate_claude_response(endpoint_name, data):
    # Simulate Claude API response
    match endpoint_name:
        "chat":
            var response_content = "This is a simulated response from Claude."
            
            # Make response more contextual if possible
            if "messages" in data:
                for message in data.messages:
                    if message.role == "user":
                        var user_content = message.content
                        if typeof(user_content) == TYPE_STRING and user_content.length() > 0:
                            response_content = "I understand you're asking about '" + user_content.substr(0, 20) + "...'. Here's my simulated Claude response."
            
            return {
                "id": "msg_" + str(randi()),
                "type": "message",
                "role": "assistant",
                "content": [
                    {
                        "type": "text",
                        "text": response_content
                    }
                ],
                "model": data.get("model", KNOWN_SERVICES.claude.default_model),
                "stop_reason": "end_turn",
                "usage": {
                    "input_tokens": 20,
                    "output_tokens": 30
                }
            }
        
        "complete":
            # Simulate completion
            return {
                "id": "compl_" + str(randi()),
                "type": "completion",
                "completion": "This is a simulated completion from Claude.",
                "model": data.get("model", KNOWN_SERVICES.claude.default_model),
                "stop_reason": "stop_sequence",
                "usage": {
                    "prompt_tokens": 20,
                    "completion_tokens": 30
                }
            }
        
        _:
            # Generic endpoint response
            return {
                "status": "success",
                "simulated": true,
                "service": "claude",
                "endpoint": endpoint_name,
                "message": "Simulated response for unknown Claude endpoint"
            }

func _simulate_gemini_response(endpoint_name, data):
    # Simulate Gemini API response
    match endpoint_name:
        "generate":
            # Simulate content generation
            var response_content = "This is a simulated response from Google's Gemini model."
            
            return {
                "candidates": [
                    {
                        "content": {
                            "parts": [
                                {
                                    "text": response_content
                                }
                            ],
                            "role": "model"
                        },
                        "finishReason": "STOP",
                        "safetyRatings": []
                    }
                ],
                "promptFeedback": {
                    "safetyRatings": []
                }
            }
        
        _:
            # Generic endpoint response
            return {
                "status": "success",
                "simulated": true,
                "service": "gemini",
                "endpoint": endpoint_name,
                "message": "Simulated response for unknown Gemini endpoint"
            }

func _simulate_stability_response(endpoint_name, data):
    # Simulate Stability API response
    match endpoint_name:
        "text-to-image":
            # Simulate image generation
            return {
                "artifacts": [
                    {
                        "base64": "simulated_base64_image_data",
                        "seed": randi(),
                        "finishReason": "SUCCESS"
                    }
                ]
            }
        
        _:
            # Generic endpoint response
            return {
                "status": "success",
                "simulated": true,
                "service": "stability",
                "endpoint": endpoint_name,
                "message": "Simulated response for unknown Stability endpoint"
            }

func _simulate_elevenlabs_response(endpoint_name, data):
    # Simulate ElevenLabs API response
    match endpoint_name:
        "text-to-speech":
            # Simulate audio generation (just returning success)
            return {
                "status": "success",
                "audio": "simulated_audio_data",
                "message": "Audio generation simulated successfully"
            }
        
        _:
            # Generic endpoint response
            return {
                "status": "success",
                "simulated": true,
                "service": "elevenlabs",
                "endpoint": endpoint_name,
                "message": "Simulated response for unknown ElevenLabs endpoint"
            }

# ================ CONVENIENCE METHODS ================
func complete_text(prompt, options = {}):
    # Convenience method for text completion
    var service = options.get("service", default_api if default_api else "openai")
    
    match service:
        "openai":
            var request_data = {
                "model": options.get("model", KNOWN_SERVICES.openai.default_model),
                "messages": [
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                "temperature": options.get("temperature", 0.7),
                "max_tokens": options.get("max_tokens", 500)
            }
            
            return send_request(service, "chat", request_data)
        
        "claude":
            var request_data = {
                "model": options.get("model", KNOWN_SERVICES.claude.default_model),
                "messages": [
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                "temperature": options.get("temperature", 0.7),
                "max_tokens": options.get("max_tokens", 500)
            }
            
            return send_request(service, "chat", request_data)
        
        "gemini":
            var request_data = {
                "contents": [
                    {
                        "parts": [
                            {
                                "text": prompt
                            }
                        ]
                    }
                ],
                "generationConfig": {
                    "temperature": options.get("temperature", 0.7),
                    "maxOutputTokens": options.get("max_tokens", 500)
                }
            }
            
            return send_request(service, "generate", request_data)
        
        _:
            push_warning("Unsupported service for text completion: " + service)
            return null

func generate_image(prompt, options = {}):
    # Convenience method for image generation
    var service = options.get("service", "stability")  # Default to Stability
    
    match service:
        "openai":
            var request_data = {
                "prompt": prompt,
                "n": options.get("n", 1),
                "size": options.get("size", "1024x1024")
            }
            
            return send_request(service, "images", request_data)
        
        "stability":
            var request_data = {
                "text_prompts": [
                    {
                        "text": prompt,
                        "weight": 1.0
                    }
                ],
                "cfg_scale": options.get("cfg_scale", 7.0),
                "height": options.get("height", 1024),
                "width": options.get("width", 1024),
                "samples": options.get("samples", 1)
            }
            
            return send_request(service, "text-to-image", request_data)
        
        _:
            push_warning("Unsupported service for image generation: " + service)
            return null

func text_to_speech(text, options = {}):
    # Convenience method for text-to-speech
    var service = options.get("service", "elevenlabs")
    
    match service:
        "elevenlabs":
            var request_data = {
                "text": text,
                "voice_id": options.get("voice_id", "21m00Tcm4TlvDq8ikWAM"),
                "model_id": options.get("model_id", "eleven_monolingual_v1")
            }
            
            return send_request(service, "text-to-speech", request_data)
        
        _:
            push_warning("Unsupported service for text-to-speech: " + service)
            return null

# ================ RESPONSE HANDLING ================
func get_response(request_id):
    # Get response for a request
    if request_id in completed_requests:
        return completed_requests[request_id].response
    
    if request_id in pending_requests:
        return {"status": "pending", "message": "Request is still being processed"}
    
    if request_id in failed_requests:
        return {"status": "failed", "error": failed_requests[request_id].error}
    
    return null

func extract_text_from_response(request_id):
    # Extract text content from API response
    var response = get_response(request_id)
    if response == null:
        return ""
    
    # Check service and endpoint
    if request_id in completed_requests:
        var service = completed_requests[request_id].service
        var endpoint = completed_requests[request_id].endpoint
        
        match service:
            "openai":
                if endpoint == "chat" and "choices" in response and response.choices.size() > 0:
                    if "message" in response.choices[0] and "content" in response.choices[0].message:
                        return response.choices[0].message.content
            
            "claude":
                if endpoint == "chat" and "content" in response:
                    var content_text = ""
                    for part in response.content:
                        if part.type == "text":
                            content_text += part.text
                    return content_text
                
                if endpoint == "complete" and "completion" in response:
                    return response.completion
            
            "gemini":
                if endpoint == "generate" and "candidates" in response and response.candidates.size() > 0:
                    if "content" in response.candidates[0] and "parts" in response.candidates[0].content:
                        var text = ""
                        for part in response.candidates[0].content.parts:
                            if "text" in part:
                                text += part.text
                        return text
    
    # Generic fallback
    if typeof(response) == TYPE_DICTIONARY and "text" in response:
        return response.text
    elif typeof(response) == TYPE_DICTIONARY and "content" in response:
        return response.content
    elif typeof(response) == TYPE_STRING:
        return response
    
    return ""

func get_request_status(request_id):
    # Get status of a request
    if request_id in completed_requests:
        return "completed"
    
    if request_id in pending_requests:
        return "pending"
    
    if request_id in failed_requests:
        return "failed"
    
    return "unknown"

func get_api_status(service_name):
    # Get status of API service
    if not service_name in api_registry:
        return "unknown"
    
    return api_registry[service_name].status

func get_all_services_status():
    # Get status of all API services
    var statuses = {}
    
    for service_name in api_registry:
        statuses[service_name] = {
            "status": api_registry[service_name].status,
            "connected": service_name in active_connections,
            "endpoints": api_registry[service_name].endpoints.keys()
        }
    
    return statuses

# ================ SIMULATION CONTROL ================
func set_simulation_mode(enabled):
    # Enable or disable simulation mode
    simulation_mode = enabled
    
    # Update active connections
    for service_name in active_connections:
        active_connections[service_name].simulated = enabled
    
    print("Simulation mode " + ("enabled" if enabled else "disabled"))
    return true

func clear_response_cache():
    # Clear cached responses
    offline_response_cache.clear()
    print("Response cache cleared")
    return true

# ================ TASK MANAGEMENT ================
func create_task(task_name, description, actions):
    # Create a managed task that performs a sequence of API calls
    var task_id = "task_" + str(randi())
    
    active_tasks[task_id] = {
        "name": task_name,
        "description": description,
        "actions": actions,
        "current_step": 0,
        "results": [],
        "status": "created",
        "created_at": Time.get_unix_time_from_system()
    }
    
    return task_id

func start_task(task_id):
    # Start executing a task
    if not task_id in active_tasks:
        push_warning("Unknown task: " + task_id)
        return false
    
    var task = active_tasks[task_id]
    
    # Update status
    task.status = "running"
    task.started_at = Time.get_unix_time_from_system()
    
    # Start first action
    _execute_task_step(task_id)
    
    return true

func _execute_task_step(task_id):
    # Execute the current step of a task
    if not task_id in active_tasks:
        return
    
    var task = active_tasks[task_id]
    
    # Check if task is complete
    if task.current_step >= task.actions.size():
        task.status = "completed"
        task.completed_at = Time.get_unix_time_from_system()
        print("Task completed: " + task.name)
        return
    
    # Get current action
    var action = task.actions[task.current_step]
    
    # Execute action
    var request_id = null
    
    match action.type:
        "complete_text":
            request_id = complete_text(action.prompt, action.get("options", {}))
        
        "generate_image":
            request_id = generate_image(action.prompt, action.get("options", {}))
        
        "text_to_speech":
            request_id = text_to_speech(action.text, action.get("options", {}))
        
        _:
            # Generic API request
            if "service" in action and "endpoint" in action and "data" in action:
                request_id = send_request(action.service, action.endpoint, action.data, action.get("options", {}))
    
    if request_id:
        # Connect to response signal (one-shot)
        var response_callable = Callable(self, "_on_task_response").bind(task_id, request_id)
        if not response_received.is_connected(response_callable):
            response_received.connect(response_callable, CONNECT_ONE_SHOT)
        
        # Connect to failure signal (one-shot)
        var failure_callable = Callable(self, "_on_task_failure").bind(task_id, request_id)
        if not request_failed.is_connected(failure_callable):
            request_failed.connect(failure_callable, CONNECT_ONE_SHOT)
    else:
        # Failed to start request, move to next step
        task.results.append({
            "step": task.current_step,
            "action": action,
            "status": "failed",
            "error": "Failed to start request"
        })
        
        task.current_step += 1
        _execute_task_step(task_id)

func _on_task_response(request_id, service_name, response_data, task_id, task_request_id):
    # Handle response for a task step
    if request_id != task_request_id or not task_id in active_tasks:
        return
    
    var task = active_tasks[task_id]
    var action = task.actions[task.current_step]
    
    # Store result
    task.results.append({
        "step": task.current_step,
        "action": action,
        "status": "completed",
        "request_id": request_id,
        "response": response_data
    })
    
    # Process result if needed
    if "process_result" in action and action.process_result:
        # In a real implementation, this would process the result according to action.process_result
        pass
    
    # Move to next step
    task.current_step += 1
    _execute_task_step(task_id)

func _on_task_failure(request_id, service_name, error, task_id, task_request_id):
    # Handle failure for a task step
    if request_id != task_request_id or not task_id in active_tasks:
        return
    
    var task = active_tasks[task_id]
    var action = task.actions[task.current_step]
    
    # Store result
    task.results.append({
        "step": task.current_step,
        "action": action,
        "status": "failed",
        "request_id": request_id,
        "error": error
    })
    
    # Check retry policy
    if "retry_on_failure" in action and action.retry_on_failure and task.results[-1].get("retries", 0) < action.get("max_retries", 3):
        # Retry the step
        task.results[-1].retries = task.results[-1].get("retries", 0) + 1
        print("Retrying task step (attempt " + str(task.results[-1].retries) + ")")
        _execute_task_step(task_id)
    else:
        # Move to next step
        task.current_step += 1
        _execute_task_step(task_id)

func get_task_status(task_id):
    # Get status of a task
    if not task_id in active_tasks:
        return null
    
    var task = active_tasks[task_id]
    return {
        "name": task.name,
        "status": task.status,
        "current_step": task.current_step,
        "total_steps": task.actions.size(),
        "progress": float(task.current_step) / task.actions.size()
    }

func get_task_results(task_id):
    # Get results of a task
    if not task_id in active_tasks:
        return null
    
    return active_tasks[task_id].results

# ================ UTILITY METHODS ================
func format_prompt(template, variables):
    # Format a prompt template with variables
    var formatted = template
    
    for var_name in variables:
        var placeholder = "{" + var_name + "}"
        formatted = formatted.replace(placeholder, str(variables[var_name]))
    
    return formatted