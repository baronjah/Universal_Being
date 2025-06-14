extends Node

signal api_response_received(api_name, response)

# Configuration for different API endpoints
var apis = {
    "claude": {
        "endpoint": "https://api.anthropic.com/v1/complete",
        "active": true,
        "last_response": null,
        "color": Color(0.5, 0.2, 0.7)  # Purple for Claude
    },
    "gemini": {
        "endpoint": "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent",
        "active": true,
        "last_response": null,
        "color": Color(0.2, 0.5, 0.9)  # Blue for Gemini
    }
}

# Simulation mode for testing without actual API keys
var simulation_mode = true
var simulation_responses = {
    "claude": [
        "Claude API response 1: Word simulation manifested.",
        "Claude API response 2: Dimensional analysis complete.",
        "Claude API response 3: Terminal interface optimized."
    ],
    "gemini": [
        "Gemini API response 1: Multi-core processing enabled.",
        "Gemini API response 2: Memory zone expansion complete.",
        "Gemini API response 3: Symbolic representation enhanced."
    ]
}

# Call the specified API with the given prompt
func call_api(api_name, prompt):
    if not apis.has(api_name):
        push_error("Unknown API: " + api_name)
        return

    var api = apis[api_name]
    
    if simulation_mode:
        # Simulate API response for testing
        var responses = simulation_responses[api_name]
        var response = responses[randi() % responses.size()]
        
        # Add some randomized delay to simulate network latency
        yield(get_tree().create_timer(rand_range(0.5, 1.5)), "timeout")
        
        # Store response and emit signal
        api.last_response = response
        emit_signal("api_response_received", api_name, response)
    else:
        # Actual API implementation would go here
        # This would require proper HTTP request handling
        var http_request = HTTPRequest.new()
        add_child(http_request)
        http_request.connect("request_completed", self, "_on_request_completed", [api_name, http_request])
        
        # Construct headers and body based on API
        var headers = []
        var body = ""
        
        if api_name == "claude":
            headers = [
                "Content-Type: application/json",
                "x-api-key: YOUR_CLAUDE_API_KEY"  # Replace with actual key in production
            ]
            body = JSON.print({
                "prompt": prompt,
                "model": "claude-3-sonnet-20240229",
                "max_tokens_to_sample": 300
            })
        elif api_name == "gemini":
            headers = [
                "Content-Type: application/json"
            ]
            body = JSON.print({
                "contents": [{"parts": [{"text": prompt}]}]
            })
        
        # Make the actual API request
        var error = http_request.request(api.endpoint, headers, true, HTTPClient.METHOD_POST, body)
        if error != OK:
            push_error("HTTP Request Error: " + str(error))

# Handle HTTP response
func _on_request_completed(result, response_code, headers, body, api_name, request):
    if result != HTTPRequest.RESULT_SUCCESS:
        push_error("HTTP Request failed: " + str(result))
        emit_signal("api_response_received", api_name, "Error: Request failed")
        request.queue_free()
        return
    
    var response = ""
    var json = JSON.parse(body.get_string_from_utf8())
    
    if json.error != OK:
        push_error("JSON Parse Error: " + json.error_string)
        response = "Error: Could not parse response"
    else:
        # Extract response text based on API format
        if api_name == "claude":
            response = json.result.completion
        elif api_name == "gemini":
            response = json.result.candidates[0].content.parts[0].text
    
    # Store the response and emit signal
    apis[api_name].last_response = response
    emit_signal("api_response_received", api_name, response)
    request.queue_free()

# Get the last response from a specific API
func get_last_response(api_name):
    if apis.has(api_name):
        return apis[api_name].last_response
    return null

# Get the color associated with an API
func get_api_color(api_name):
    if apis.has(api_name):
        return apis[api_name].color
    return Color(1, 1, 1)  # Default white