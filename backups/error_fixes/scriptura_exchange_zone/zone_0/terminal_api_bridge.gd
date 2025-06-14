extends Node

# Terminal API Bridge
# Provides connectivity between terminal cores and external APIs/services
# Handles authentication, data transfer, and synchronization between cores

class_name TerminalAPIBridge

# ----- API CONNECTION CONSTANTS -----
const API_TIMEOUT = 30.0
const MAX_RETRY_COUNT = 3
const AUTH_HEADER = "Authorization"
const MAX_ACCOUNT_API_VALUE = 19
const DEFAULT_PORT = 5000

# ----- API STATE ENUMS -----
enum APIState {
    DISCONNECTED,
    CONNECTING,
    CONNECTED,
    ERROR,
    RATE_LIMITED,
    AUTHENTICATED,
    TRANSFERRING
}

# ----- TERMINAL REFERENCES -----
var dual_core_terminal = null
var connected_cores = []
var terminal_monitors = {}

# ----- API CONNECTIONS -----
var active_connections = {}
var connection_history = []
var auth_tokens = {}
var connection_timeouts = {}
var retry_counts = {}

# ----- INTEGRATION WITH GAME SYSTEMS -----
var divine_word_game = null
var divine_word_processor = null
var turn_system = null
var word_comment_system = null

# ----- DATA TRANSFER -----
var transfer_queue = []
var processed_data = {}
var pending_responses = {}
var last_sync_time = 0

# ----- SIGNALS -----
signal connection_established(api_name, core_id)
signal connection_error(api_name, error_code, error_message)
signal data_received(api_name, data)
signal data_transferred(core_id, api_name, data_size)
signal auth_succeeded(api_name)
signal auth_failed(api_name, reason)
signal cores_synchronized(core_ids)
signal rate_limit_hit(api_name, reset_time)

# ----- INITIALIZATION -----
func _ready():
    print("Terminal API Bridge initializing...")
    
    # Connect to terminal system
    dual_core_terminal = get_node_or_null("/root/DualCoreTerminal")
    if dual_core_terminal:
        _connect_terminal_signals()
        print("Connected to Dual Core Terminal system")
    
    # Connect to game systems
    _connect_game_systems()
    
    # Set up sync timer
    var sync_timer = Timer.new()
    sync_timer.wait_time = 5.0 # Sync every 5 seconds
    sync_timer.one_shot = false
    sync_timer.autostart = true
    sync_timer.connect("timeout", self, "_on_sync_timer_timeout")
    add_child(sync_timer)
    
    print("Terminal API Bridge initialized")

func _connect_terminal_signals():
    if dual_core_terminal:
        dual_core_terminal.connect("core_switched", self, "_on_core_switched")
        dual_core_terminal.connect("input_processed", self, "_on_terminal_input_processed")
        dual_core_terminal.connect("special_pattern_detected", self, "_on_special_pattern_detected")
        dual_core_terminal.connect("miracle_triggered", self, "_on_miracle_triggered")
        
        # Initialize monitors for existing cores
        var cores = dual_core_terminal.get_all_cores()
        for core_id in cores:
            _initialize_core_monitor(core_id)

func _connect_game_systems():
    # Connect to divine word game
    divine_word_game = get_node_or_null("/root/DivineWordGame")
    
    # Connect to divine word processor
    divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
    
    # Connect to turn system
    turn_system = get_node_or_null("/root/TurnSystem")
    if turn_system:
        turn_system.connect("turn_advanced", self, "_on_turn_advanced")
    
    # Connect to word comment system
    word_comment_system = get_node_or_null("/root/WordCommentSystem")

func _initialize_core_monitor(core_id):
    # Create a monitor for this core
    terminal_monitors[core_id] = {
        "last_input": null,
        "last_output": null,
        "connection_status": {},
        "last_activity": OS.get_unix_time(),
        "data_stats": {
            "sent_bytes": 0,
            "received_bytes": 0,
            "last_transfer": 0
        }
    }

# ----- PROCESSING -----
func _process(delta):
    # Process pending connections
    _process_connections()
    
    # Process transfer queue
    _process_transfer_queue()
    
    # Check for connection timeouts
    _check_connection_timeouts()

func _process_connections():
    # Process each active connection
    for api_name in active_connections:
        var connection = active_connections[api_name]
        
        # If connection is in CONNECTING state, check if it has established
        if connection.state == APIState.CONNECTING:
            if connection.has("connection") and connection.connection:
                if connection.connection.get_status() == HTTPClient.STATUS_CONNECTED:
                    # Connection established
                    connection.state = APIState.CONNECTED
                    emit_signal("connection_established", api_name, connection.core_id)
                    
                    # If we have auth token, authenticate
                    if auth_tokens.has(api_name):
                        _authenticate(api_name)
                elif connection.connection.get_status() == HTTPClient.STATUS_BODY or connection.connection.get_status() == HTTPClient.STATUS_CONNECTED:
                    # Check for response
                    if connection.connection.has_response():
                        var headers = connection.connection.get_response_headers_as_dictionary()
                        var body = connection.connection.read_response_body_chunk()
                        
                        # Process response
                        _process_api_response(api_name, headers, body)
                elif connection.connection.get_status() == HTTPClient.STATUS_CANT_CONNECT:
                    # Connection failed
                    connection.state = APIState.ERROR
                    emit_signal("connection_error", api_name, HTTPClient.STATUS_CANT_CONNECT, "Cannot connect to API")
                    
                    # Increment retry count
                    if not retry_counts.has(api_name):
                        retry_counts[api_name] = 0
                    retry_counts[api_name] += 1
                    
                    if retry_counts[api_name] <= MAX_RETRY_COUNT:
                        # Retry connection
                        _connect_to_api(api_name, connection.host, connection.port, connection.core_id)
                    else:
                        # Too many retries, give up
                        emit_signal("connection_error", api_name, HTTPClient.STATUS_CANT_CONNECT, "Max retry count exceeded")

func _process_transfer_queue():
    # Process data transfer queue
    if transfer_queue.size() > 0:
        var transfer = transfer_queue[0]
        var api_name = transfer.api_name
        
        if active_connections.has(api_name):
            var connection = active_connections[api_name]
            
            if connection.state == APIState.AUTHENTICATED:
                # API is authenticated, can transfer data
                var core_id = transfer.core_id
                var data = transfer.data
                var endpoint = transfer.endpoint
                var method = transfer.method
                
                # Try to send the data
                var success = _send_to_api(api_name, endpoint, method, data)
                
                if success:
                    # Data sent, update state
                    connection.state = APIState.TRANSFERRING
                    
                    # Update stats for core monitor
                    if terminal_monitors.has(core_id):
                        var data_size = str(data).length()
                        terminal_monitors[core_id].data_stats.sent_bytes += data_size
                        terminal_monitors[core_id].data_stats.last_transfer = OS.get_unix_time()
                        
                        emit_signal("data_transferred", core_id, api_name, data_size)
                    
                    # Remove from queue
                    transfer_queue.pop_front()
                else:
                    # Failed to send, check if we should retry
                    transfer.retry_count += 1
                    
                    if transfer.retry_count > MAX_RETRY_COUNT:
                        # Too many retries, remove from queue and report error
                        transfer_queue.pop_front()
                        emit_signal("connection_error", api_name, 0, "Failed to send data after " + str(MAX_RETRY_COUNT) + " retries")
            elif connection.state == APIState.CONNECTED:
                # Need to authenticate first
                _authenticate(api_name)
            elif connection.state == APIState.RATE_LIMITED:
                # We're rate limited, stop processing for now
                # The timer will reset the state once the rate limit expires
                pass
            else:
                # Connection not in a state to transfer, remove from queue
                transfer_queue.pop_front()
        else:
            # API connection doesn't exist, remove from queue
            transfer_queue.pop_front()

func _check_connection_timeouts():
    # Check for connection timeouts
    var current_time = OS.get_unix_time()
    
    for api_name in connection_timeouts:
        var timeout_time = connection_timeouts[api_name]
        
        if current_time > timeout_time:
            # Connection has timed out
            if active_connections.has(api_name):
                var connection = active_connections[api_name]
                
                if connection.state == APIState.CONNECTING:
                    # Still trying to connect after timeout
                    connection.state = APIState.ERROR
                    emit_signal("connection_error", api_name, 0, "Connection timeout")
                    
                    # Close connection
                    if connection.has("connection") and connection.connection:
                        connection.connection.close()
                    
                    # Remove from active connections
                    active_connections.erase(api_name)
            
            # Remove timeout
            connection_timeouts.erase(api_name)

# ----- API CONNECTION MANAGEMENT -----
func connect_to_api(api_name, host, port=DEFAULT_PORT, core_id=null):
    # Use active core if none specified
    if core_id == null and dual_core_terminal:
        core_id = dual_core_terminal.get_current_core_id()
    
    # Add to connected cores if not already there
    if core_id != null and not connected_cores.has(core_id):
        connected_cores.append(core_id)
        
        # Initialize monitor if needed
        if not terminal_monitors.has(core_id):
            _initialize_core_monitor(core_id)
        
        # Update monitor with connection info
        terminal_monitors[core_id].connection_status[api_name] = APIState.CONNECTING
    
    return _connect_to_api(api_name, host, port, core_id)

func _connect_to_api(api_name, host, port, core_id):
    # Check if already connected
    if active_connections.has(api_name) and active_connections[api_name].state >= APIState.CONNECTED:
        return true
    
    # Create HTTPClient
    var http = HTTPClient.new()
    var err = http.connect_to_host(host, port)
    
    if err != OK:
        emit_signal("connection_error", api_name, err, "Failed to connect to host")
        return false
    
    # Store connection
    active_connections[api_name] = {
        "connection": http,
        "host": host,
        "port": port,
        "state": APIState.CONNECTING,
        "core_id": core_id
    }
    
    # Set timeout
    connection_timeouts[api_name] = OS.get_unix_time() + API_TIMEOUT
    
    # Reset retry count
    retry_counts[api_name] = 0
    
    print("Connecting to API: " + api_name + " at " + host + ":" + str(port))
    return true

func set_auth_token(api_name, token):
    auth_tokens[api_name] = token
    
    # If already connected, authenticate now
    if active_connections.has(api_name) and active_connections[api_name].state == APIState.CONNECTED:
        _authenticate(api_name)
    
    return true

func _authenticate(api_name):
    if not active_connections.has(api_name) or not auth_tokens.has(api_name):
        return false
    
    var connection = active_connections[api_name]
    
    # Create auth request
    var headers = [
        "Content-Type: application/json",
        AUTH_HEADER + ": " + auth_tokens[api_name]
    ]
    
    var data = JSON.print({"authenticate": true})
    
    # Send auth request
    var err = connection.connection.request("POST", "/auth", headers, data)
    
    if err != OK:
        emit_signal("connection_error", api_name, err, "Failed to send auth request")
        return false
    
    # Wait for response in process_connections
    return true

func _process_api_response(api_name, headers, body):
    if not active_connections.has(api_name):
        return
    
    var connection = active_connections[api_name]
    
    # Check for rate limiting headers
    if headers.has("X-RateLimit-Remaining") and int(headers["X-RateLimit-Remaining"]) == 0:
        connection.state = APIState.RATE_LIMITED
        
        var reset_time = int(headers["X-RateLimit-Reset"]) if headers.has("X-RateLimit-Reset") else 60
        emit_signal("rate_limit_hit", api_name, reset_time)
        
        # Set timer to reset rate limit
        var timer = Timer.new()
        timer.wait_time = reset_time
        timer.one_shot = true
        timer.autostart = true
        timer.connect("timeout", self, "_on_rate_limit_reset", [api_name])
        add_child(timer)
        
        return
    
    # Try to parse JSON body
    var json = JSON.parse(body.get_string_from_utf8())
    
    if json.error == OK:
        var response_data = json.result
        
        # Check response type
        if response_data.has("authenticated") and response_data.authenticated:
            # Authentication successful
            connection.state = APIState.AUTHENTICATED
            emit_signal("auth_succeeded", api_name)
        else:
            # Normal data response
            emit_signal("data_received", api_name, response_data)
            
            # Store in processed data
            processed_data[api_name] = response_data
            
            # Complete transfer
            if connection.state == APIState.TRANSFERRING:
                connection.state = APIState.AUTHENTICATED
            
            # Update core monitor stats if we have a core ID
            if connection.has("core_id") and terminal_monitors.has(connection.core_id):
                var data_size = body.size()
                terminal_monitors[connection.core_id].data_stats.received_bytes += data_size
                terminal_monitors[connection.core_id].data_stats.last_transfer = OS.get_unix_time()
            
            # Check for pending response handlers
            if pending_responses.has(api_name):
                var callback = pending_responses[api_name]
                if callback.has("target") and callback.has("method"):
                    if callback.target.has_method(callback.method):
                        callback.target.call(callback.method, response_data)
                pending_responses.erase(api_name)
    else:
        # Failed to parse JSON
        emit_signal("connection_error", api_name, json.error, "Failed to parse response")

func _send_to_api(api_name, endpoint, method, data):
    if not active_connections.has(api_name):
        return false
    
    var connection = active_connections[api_name]
    
    if not connection.connection:
        return false
    
    # Create request
    var headers = [
        "Content-Type: application/json",
        AUTH_HEADER + ": " + auth_tokens[api_name]
    ]
    
    var json_data = JSON.print(data)
    
    # Send request
    var err = connection.connection.request(method, endpoint, headers, json_data)
    
    if err != OK:
        emit_signal("connection_error", api_name, err, "Failed to send request")
        return false
    
    return true

func _on_rate_limit_reset(api_name):
    if active_connections.has(api_name) and active_connections[api_name].state == APIState.RATE_LIMITED:
        active_connections[api_name].state = APIState.AUTHENTICATED
        print("Rate limit reset for API: " + api_name)

# ----- DATA TRANSFER -----
func send_data(api_name, endpoint, data, method="POST", core_id=null):
    # Use active core if none specified
    if core_id == null and dual_core_terminal:
        core_id = dual_core_terminal.get_current_core_id()
    
    // Add to transfer queue
    transfer_queue.append({
        "api_name": api_name,
        "endpoint": endpoint,
        "data": data,
        "method": method,
        "core_id": core_id,
        "timestamp": OS.get_unix_time(),
        "retry_count": 0
    })
    
    // If connection doesn't exist yet, try to establish it
    if not active_connections.has(api_name):
        emit_signal("connection_error", api_name, 0, "No active connection")
        return false
    
    return true

func register_response_handler(api_name, target, method):
    pending_responses[api_name] = {
        "target": target,
        "method": method,
        "timestamp": OS.get_unix_time()
    }

func synchronize_cores(core_ids=null):
    // If no core IDs specified, sync all connected cores
    if core_ids == null:
        core_ids = connected_cores
    
    var sync_data = {}
    
    // Gather data from each core
    for core_id in core_ids:
        if dual_core_terminal and dual_core_terminal.cores.has(core_id):
            var core_info = dual_core_terminal.get_core_info(core_id)
            
            // Extract relevant data for sync
            sync_data[core_id] = {
                "name": core_info.name,
                "state": core_info.state,
                "bracket_style": core_info.bracket_style,
                "account_value": core_info.account_value,
                "miracle_count": core_info.miracle_count,
                "last_input": core_info.last_input,
                "time_state": dual_core_terminal.get_time_state()
            }
    
    // Record sync time
    last_sync_time = OS.get_unix_time()
    
    emit_signal("cores_synchronized", core_ids)
    return sync_data

func _on_sync_timer_timeout():
    // Auto-sync cores every 5 seconds
    synchronize_cores()

# ----- EVENT HANDLERS -----
func _on_core_switched(old_core_id, new_core_id):
    // Update active API connections for the new core
    for api_name in active_connections:
        var connection = active_connections[api_name]
        
        if connection.core_id == old_core_id:
            connection.core_id = new_core_id
            
            // Update monitor
            if terminal_monitors.has(new_core_id):
                terminal_monitors[new_core_id].connection_status[api_name] = connection.state

func _on_terminal_input_processed(core_id, input_text, result):
    // Update terminal monitor
    if terminal_monitors.has(core_id):
        terminal_monitors[core_id].last_input = input_text
        terminal_monitors[core_id].last_output = result
        terminal_monitors[core_id].last_activity = OS.get_unix_time()
        
        // If input contains API-related commands, process them
        if "#api" in input_text:
            _process_api_command(core_id, input_text)

func _process_api_command(core_id, input_text):
    // Parse API command from input text
    var parts = input_text.split("#api", true, 1)
    
    if parts.size() < 2:
        return
    
    var command_text = parts[1].strip_edges()
    var command_parts = command_text.split(" ", false)
    
    if command_parts.size() < 1:
        return
    
    var cmd = command_parts[0].to_lower()
    
    match cmd:
        "connect":
            // #api connect api_name host [port]
            if command_parts.size() >= 3:
                var api_name = command_parts[1]
                var host = command_parts[2]
                var port = DEFAULT_PORT
                
                if command_parts.size() >= 4 and command_parts[3].is_valid_integer():
                    port = int(command_parts[3])
                
                connect_to_api(api_name, host, port, core_id)
        
        "auth":
            // #api auth api_name token
            if command_parts.size() >= 3:
                var api_name = command_parts[1]
                var token = command_parts[2]
                
                set_auth_token(api_name, token)
        
        "send":
            // #api send api_name endpoint data
            if command_parts.size() >= 4:
                var api_name = command_parts[1]
                var endpoint = command_parts[2]
                var data_str = command_parts.slice(3, command_parts.size() - 1).join(" ")
                
                // Try to parse data as JSON
                var json = JSON.parse(data_str)
                var data = data_str
                
                if json.error == OK:
                    data = json.result
                
                send_data(api_name, endpoint, data, "POST", core_id)
        
        "disconnect":
            // #api disconnect api_name
            if command_parts.size() >= 2:
                var api_name = command_parts[1]
                
                if active_connections.has(api_name):
                    var connection = active_connections[api_name]
                    
                    if connection.has("connection") and connection.connection:
                        connection.connection.close()
                    
                    active_connections.erase(api_name)
                    
                    if core_id != null and terminal_monitors.has(core_id):
                        terminal_monitors[core_id].connection_status.erase(api_name)
                    
                    print("Disconnected from API: " + api_name)

func _on_special_pattern_detected(pattern, effect):
    // Special handling for API patterns
    if pattern == "<->" or pattern == "|/\\|":
        // These patterns indicate dimensional connections or gates
        // Could trigger API sync across dimensions
        for api_name in active_connections:
            var connection = active_connections[api_name]
            
            if connection.state >= APIState.CONNECTED:
                // Send special pattern data
                var data = {
                    "pattern": pattern,
                    "effect": effect,
                    "dimension": turn_system.current_dimension if turn_system else 0,
                    "timestamp": OS.get_unix_time()
                }
                
                send_data(api_name, "/pattern", data, "POST", connection.core_id)

func _on_miracle_triggered(core_id):
    // When a miracle is triggered, notify all connected APIs
    for api_name in active_connections:
        var connection = active_connections[api_name]
        
        if connection.state >= APIState.CONNECTED:
            // Send miracle notification
            var data = {
                "event": "miracle",
                "core_id": core_id,
                "dimension": turn_system.current_dimension if turn_system else 0,
                "timestamp": OS.get_unix_time()
            }
            
            send_data(api_name, "/event", data, "POST", connection.core_id)

func _on_turn_advanced(old_turn, new_turn):
    // When turn advances, update all connected APIs
    for api_name in active_connections:
        var connection = active_connections[api_name]
        
        if connection.state >= APIState.CONNECTED:
            // Send turn update
            var data = {
                "event": "turn_advanced",
                "old_turn": old_turn,
                "new_turn": new_turn,
                "timestamp": OS.get_unix_time()
            }
            
            send_data(api_name, "/event", data, "POST", connection.core_id)

# ----- PUBLIC API -----
func get_connection_status(api_name):
    if active_connections.has(api_name):
        return active_connections[api_name].state
    return APIState.DISCONNECTED

func get_core_monitor_data(core_id):
    if terminal_monitors.has(core_id):
        return terminal_monitors[core_id]
    return null

func get_all_monitors():
    return terminal_monitors

func get_active_connections():
    var connections = []
    for api_name in active_connections:
        connections.append({
            "name": api_name,
            "state": active_connections[api_name].state,
            "host": active_connections[api_name].host,
            "port": active_connections[api_name].port,
            "core_id": active_connections[api_name].core_id
        })
    return connections

func clear_transfer_queue():
    transfer_queue.clear()
    return true

func get_processed_data(api_name):
    if processed_data.has(api_name):
        return processed_data[api_name]
    return null

func get_last_sync_time():
    return last_sync_time

func set_account_api_value(core_id, value):
    if value < 0 or value > MAX_ACCOUNT_API_VALUE:
        return false
    
    if dual_core_terminal and dual_core_terminal.cores.has(core_id):
        dual_core_terminal.cores[core_id].account_value = value
        
        // If account value reached max, set special state
        if value == MAX_ACCOUNT_API_VALUE:
            dual_core_terminal.cores[core_id].state = dual_core_terminal.WindowState.MAX_ACCOUNT
            
            // Add comment about max account value reached
            if word_comment_system:
                word_comment_system.add_comment("account_" + str(core_id),
                    "Core " + str(core_id) + " reached MAX_ACCOUNT value (" + str(value) + ")!",
                    word_comment_system.CommentType.OBSERVATION, "API_Bridge")
        
        return true
    
    return false

func close_all_connections():
    for api_name in active_connections:
        var connection = active_connections[api_name]
        
        if connection.has("connection") and connection.connection:
            connection.connection.close()
    
    active_connections.clear()
    return true