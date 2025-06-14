# res://scripts/godot_ai_bridge.gd
extends Node
class_name GodotAIBridge

# Configuration
@export var port: int = 8888
@export var api_key_file: String = "user://api_key.txt"
@export var default_model: String = "gpt-4"
@export var debug_mode: bool = true

# WebSocket server
var ws_server: WebSocketServer
var connected_clients: Dictionary = {}

# AI request handling
var http_request: HTTPRequest
var chat_history: Array = []
var current_api_key: String = ""
var current_model: String = ""
var is_processing_request: bool = false

# Signals
signal client_connected(id: int, info: Dictionary)
signal client_disconnected(id: int)
signal message_received(id: int, message: String)
signal ai_response_received(response: String, full_data: Dictionary)
signal ai_error(error_code: int, error_message: String)
signal ai_thinking(is_thinking: bool)
signal connection_status_changed(is_connected: bool, client_count: int)

func _ready() -> void:
    # Initialize HTTP request for AI API calls
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_request_completed)
    
    # Load API key if available
    _load_api_key()
    
    # Set default model
    current_model = default_model
    
    # Initialize WebSocket server
    ws_server = WebSocketServer.new()
    var err = ws_server.listen(port)
    if err != OK:
        printerr("Failed to start WebSocket server on port ", port, ": ", err)
        return
    
    if debug_mode:
        print("WebSocket server started on port: ", port)
    
    # Initialize empty chat history
    reset_chat_history()

func _process(delta: float) -> void:
    # Poll the WebSocket server
    if ws_server.is_listening():
        ws_server.poll()

func _load_api_key() -> void:
    var file = FileAccess.open(api_key_file, FileAccess.READ)
    if file:
        current_api_key = file.get_as_text().strip_edges()
        file.close()
        
        if debug_mode:
            print("API key loaded from: ", api_key_file)
    else:
        if debug_mode:
            print("No API key file found at: ", api_key_file)

func save_api_key(api_key: String) -> void:
    var file = FileAccess.open(api_key_file, FileAccess.WRITE)
    if file:
        file.store_string(api_key)
        file.close()
        current_api_key = api_key
        if debug_mode:
            print("API key saved to: ", api_key_file)
    else:
        printerr("Failed to save API key to: ", api_key_file)

func reset_chat_history() -> void:
    chat_history = []

func add_system_message(content: String) -> void:
    chat_history.append({
        "role": "system",
        "content": content
    })

func start_server() -> bool:
    if ws_server.is_listening():
        if debug_mode:
            print("Server is already running")
        return true
    
    var err = ws_server.listen(port)
    if err != OK:
        printerr("Failed to start WebSocket server: ", err)
        return false
    
    if debug_mode:
        print("WebSocket server started on port: ", port)
    
    return true

func stop_server() -> void:
    if ws_server.is_listening():
        ws_server.stop()
        connected_clients.clear()
        
        if debug_mode:
            print("WebSocket server stopped")
        
        emit_signal("connection_status_changed", false, 0)

func _handle_new_connection() -> void:
    var id = ws_server.get_peer(1).get_unique_id()
    connected_clients[id] = {
        "connection_time": Time.get_unix_time_from_system(),
        "messages_sent": 0,
        "last_active": Time.get_unix_time_from_system()
    }
    
    if debug_mode:
        print("Client connected with ID: ", id)
    
    emit_signal("client_connected", id, connected_clients[id])
    emit_signal("connection_status_changed", true, connected_clients.size())

func _handle_disconnect(id: int) -> void:
    if connected_clients.has(id):
        connected_clients.erase(id)
        
        if debug_mode:
            print("Client disconnected: ", id)
        
        emit_signal("client_disconnected", id)
        emit_signal("connection_status_changed", connected_clients.size() > 0, connected_clients.size())

func _handle_data_packet(peer_id: int) -> void:
    var peer = ws_server.get_peer(peer_id)
    var packet = peer.get_packet()
    var message = packet.get_string_from_utf8()
    
    # Update client activity
    if connected_clients.has(peer_id):
        connected_clients[peer_id]["last_active"] = Time.get_unix_time_from_system()
        connected_clients[peer_id]["messages_sent"] += 1
    
    if debug_mode:
        print("Received from client ", peer_id, ": ", message)
    
    # Try to parse as JSON
    var json_result = JSON.parse_string(message)
    if json_result != null and json_result is Dictionary:
        _process_json_message(peer_id, json_result)
    else:
        # Treat as plain text message
        _process_text_message(peer_id, message)

func _process_json_message(peer_id: int, json_data: Dictionary) -> void:
    if json_data.has("user_message"):
        var user_message = json_data["user_message"]
        emit_signal("message_received", peer_id, user_message)
        send_ai_request(user_message)
    
    elif json_data.has("command"):
        _handle_command(peer_id, json_data["command"], json_data.get("params", {}))

func _process_text_message(peer_id: int, message: String) -> void:
    emit_signal("message_received", peer_id, message)
    send_ai_request(message)

func _handle_command(peer_id: int, command: String, params: Dictionary) -> void:
    match command:
        "set_api_key":
            if params.has("key"):
                save_api_key(params["key"])
                send_response_to_client(peer_id, {"status": "API key updated"})
        
        "set_model":
            if params.has("model"):
                current_model = params["model"]
                send_response_to_client(peer_id, {"status": "Model updated to " + current_model})
        
        "reset_chat":
            reset_chat_history()
            send_response_to_client(peer_id, {"status": "Chat history reset"})
        
        "system_message":
            if params.has("content"):
                add_system_message(params["content"])
                send_response_to_client(peer_id, {"status": "System message added"})
        
        _:
            send_response_to_client(peer_id, {"error": "Unknown command: " + command})

func send_ai_request(user_message: String) -> void:
    if is_processing_request:
        if debug_mode:
            print("Already processing a request. Ignoring.")
        return
    
    if current_api_key.is_empty():
        printerr("No API key set. Cannot send request.")
        emit_signal("ai_error", -1, "No API key configured")
        return
    
    # Add user message to history
    chat_history.append({
        "role": "user",
        "content": user_message
    })
    
    # Create request body
    var body = {
        "model": current_model,
        "messages": chat_history
    }
    
    var headers = [
        "Authorization: Bearer " + current_api_key,
        "Content-Type: application/json"
    ]
    
    is_processing_request = true
    emit_signal("ai_thinking", true)
    
    if debug_mode:
        print("Sending request to OpenAI API...")
    
    # Make the HTTP request
    var error = http_request.request(
        "https://api.openai.com/v1/chat/completions",
        headers,
        HTTPClient.METHOD_POST,
        JSON.stringify(body)
    )
    
    if error != OK:
        is_processing_request = false
        emit_signal("ai_thinking", false)
        printerr("HTTP Request failed: ", error)
        emit_signal("ai_error", error, "Failed to send request")

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
    is_processing_request = false
    emit_signal("ai_thinking", false)
    
    if result != HTTPRequest.RESULT_SUCCESS:
        printerr("HTTP Request failed with result code: ", result)
        emit_signal("ai_error", result, "Network error")
        return
    
    if response_code != 200:
        var error_text = body.get_string_from_utf8()
        printerr("API returned error: ", response_code, " - ", error_text)
        emit_signal("ai_error", response_code, error_text)
        return
    
    var json_string = body.get_string_from_utf8()
    var json_result = JSON.parse_string(json_string)
    
    if json_result == null:
        printerr("Failed to parse API response as JSON")
        emit_signal("ai_error", -1, "Invalid JSON response")
        return
    
    if json_result.has("error"):
        printerr("API error: ", json_result["error"])
        emit_signal("ai_error", -1, json_result["error"]["message"])
        return
    
    if json_result.has("choices") and json_result["choices"].size() > 0:
        var message = json_result["choices"][0]["message"]
        var content = message["content"]
        
        # Add the AI response to the chat history
        chat_history.append({
            "role": "assistant",
            "content": content
        })
        
        if debug_mode:
            print("AI response: ", content)
        
        emit_signal("ai_response_received", content, json_result)
        
        # Broadcast response to all connected clients
        broadcast_message({
            "ai_response": content,
            "model": current_model
        })
    
    else:
        printerr("Unexpected API response format")
        emit_signal("ai_error", -1, "Unexpected API response format")

func broadcast_message(message: Variant) -> void:
    var message_text: String
    
    if message is String:
        message_text = message
    else:
        message_text = JSON.stringify(message)
    
    for peer_id in connected_clients.keys():
        var peer = ws_server.get_peer(peer_id)
        peer.send_text(message_text)

func send_response_to_client(peer_id: int, response: Variant) -> void:
    if not connected_clients.has(peer_id):
        return
    
    var response_text: String
    
    if response is String:
        response_text = response
    else:
        response_text = JSON.stringify(response)
    
    var peer = ws_server.get_peer(peer_id)
    peer.send_text(response_text)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        stop_server()