extends Node

class_name MultiAccountAPIController

"""
Multi-Account API Controller
Manages interactions between multiple accounts and their API connections
Handles account creation, API connections, data routing, and window management
"""

# References to other systems
var account_manager = null
var thread_processor = null
var visualizer = null

# API Types and capabilities
enum APIType {
    CLAUDE,
    GEMINI,
    CUSTOM,
    INTERNAL,
    SHARED,
    SECURE
}

# API Connection states
enum ConnectionState {
    INACTIVE,
    CONNECTING,
    ACTIVE,
    ERROR,
    THROTTLED
}

# Stored API connections
var api_connections = {}
var connection_usage = {}

# Window content cache
var window_content = {}

# Account-specific API limits
var account_api_limits = {
    "free": {
        "connections": 1,
        "requests_per_minute": 10,
        "custom_apis": false
    },
    "plus": {
        "connections": 3,
        "requests_per_minute": 60,
        "custom_apis": false
    },
    "max": {
        "connections": 8,
        "requests_per_minute": 250,
        "custom_apis": true
    },
    "enterprise": {
        "connections": 20,
        "requests_per_minute": 1000,
        "custom_apis": true
    }
}

# API usage tracking
var api_usage = {}
var api_usage_time = {}

# Signals
signal api_request_sent(from_account, to_account, api_type, request)
signal api_response_received(from_account, to_account, api_type, response)
signal api_connection_state_changed(connection_id, new_state)
signal window_content_updated(account_id, window_id, content)

func _ready():
    # Connect to other systems
    _connect_to_systems()
    
    # Setup tracking timer
    var timer = Timer.new()
    timer.wait_time = 60.0  # Reset tracking every minute
    timer.autostart = true
    timer.timeout.connect(_reset_api_usage_counters)
    add_child(timer)

func _connect_to_systems():
    # Connect to MultiAccountManager
    if has_node("/root/MultiAccountManager") or get_node_or_null("/root/MultiAccountManager"):
        account_manager = get_node("/root/MultiAccountManager")
        print("Connected to MultiAccountManager")
    
    # Connect to MultiThreadedProcessor
    if has_node("/root/MultiThreadedProcessor") or get_node_or_null("/root/MultiThreadedProcessor"):
        thread_processor = get_node("/root/MultiThreadedProcessor")
        print("Connected to MultiThreadedProcessor")
    
    # Connect to MultiAccount3DVisualizer
    if has_node("/root/MultiAccount3DVisualizer") or get_node_or_null("/root/MultiAccount3DVisualizer"):
        visualizer = get_node("/root/MultiAccount3DVisualizer")
        print("Connected to MultiAccount3DVisualizer")
        
        # Connect visualization signals
        visualizer.api_connected.connect(_on_visualizer_api_connected)
        visualizer.window_selected.connect(_on_visualizer_window_selected)
        visualizer.account_activated.connect(_on_visualizer_account_activated)

func create_api_connection(from_account, to_account, api_type=APIType.CLAUDE):
    """
    Create an API connection between two accounts
    """
    # Check if accounts exist
    if not _verify_account(from_account) or not _verify_account(to_account):
        print("Invalid account(s) for API connection")
        return false
    
    # Verify account has available connections
    if not _check_api_connection_limit(from_account):
        print("Account " + from_account + " has reached API connection limit")
        return false
    
    # Create connection ID
    var connection_id = from_account + "_to_" + to_account + "_" + APIType.keys()[api_type]
    
    # Check if connection already exists
    if connection_id in api_connections:
        print("Connection already exists: " + connection_id)
        return false
    
    # Create the connection data
    api_connections[connection_id] = {
        "from_account": from_account,
        "to_account": to_account,
        "api_type": api_type,
        "state": ConnectionState.INACTIVE,
        "created_at": Time.get_unix_time_from_system(),
        "last_used": 0,
        "usage_count": 0
    }
    
    # Initialize tracking
    connection_usage[connection_id] = 0
    
    # Create visualization if available
    if visualizer:
        # Find API windows for each account
        var from_window_idx = _find_api_window(from_account)
        var to_window_idx = _find_api_window(to_account)
        
        if from_window_idx >= 0 and to_window_idx >= 0:
            visualizer.connect_api_windows(from_account, to_account, from_window_idx, to_window_idx)
    
    print("Created API connection: " + connection_id)
    return true

func send_api_request(from_account, to_account, api_type, request_data):
    """
    Send an API request from one account to another
    """
    # Find the connection
    var connection_id = _find_api_connection(from_account, to_account, api_type)
    if connection_id.empty():
        print("No API connection found between accounts")
        return null
    
    # Check if connection is active
    if api_connections[connection_id].state != ConnectionState.ACTIVE:
        # Try to activate connection
        _set_connection_state(connection_id, ConnectionState.CONNECTING)
        
        # For simulation, immediately activate
        _set_connection_state(connection_id, ConnectionState.ACTIVE)
    
    # Check API usage limits
    if not _check_api_usage_limit(from_account):
        print("Account " + from_account + " has reached API usage limit")
        _set_connection_state(connection_id, ConnectionState.THROTTLED)
        return null
    
    # Track usage
    _track_api_usage(from_account)
    connection_usage[connection_id] += 1
    api_connections[connection_id].usage_count += 1
    api_connections[connection_id].last_used = Time.get_unix_time_from_system()
    
    # Emit request signal
    emit_signal("api_request_sent", from_account, to_account, api_type, request_data)
    
    # Process the request with appropriate API implementation
    var response = _process_api_request(connection_id, request_data)
    
    # Update window content if visualizer is available
    if visualizer:
        # Find API windows
        var from_window_idx = _find_api_window(from_account)
        if from_window_idx >= 0:
            visualizer.set_window_content(from_account, from_window_idx, "Sent: " + str(request_data).substr(0, 20))
        
        var to_window_idx = _find_api_window(to_account)
        if to_window_idx >= 0:
            visualizer.set_window_content(to_account, to_window_idx, "Received: " + str(response).substr(0, 20))
    
    # Emit response signal
    emit_signal("api_response_received", from_account, to_account, api_type, response)
    
    return response

func get_api_connections(account_id):
    """
    Get all API connections for an account
    """
    var connections = []
    
    for connection_id in api_connections:
        var connection = api_connections[connection_id]
        if connection.from_account == account_id or connection.to_account == account_id:
            connections.append(connection)
    
    return connections

func create_api_window(account_id):
    """
    Create a new API window for an account
    """
    if not _verify_account(account_id):
        return null
    
    if visualizer:
        return visualizer.add_window_to_account(account_id, 1)  # 1 = API window type
    
    return null

# Helper methods

func _verify_account(account_id):
    """
    Verify that an account exists
    """
    # If we have account manager, check with it
    if account_manager:
        return account_manager.get_account_data(account_id) != null
    
    # Otherwise just check if we have it in the visualizer
    if visualizer:
        return account_id in visualizer.account_nodes
    
    return false

func _check_api_connection_limit(account_id):
    """
    Check if account has reached its API connection limit
    """
    # Get account tier
    var tier = _get_account_tier(account_id)
    
    # Get connection limit for tier
    var connection_limit = account_api_limits[tier].connections
    
    # Count current connections
    var current_connections = 0
    for connection_id in api_connections:
        var connection = api_connections[connection_id]
        if connection.from_account == account_id:
            current_connections += 1
    
    return current_connections < connection_limit

func _check_api_usage_limit(account_id):
    """
    Check if account has reached its API usage limit
    """
    # Get account tier
    var tier = _get_account_tier(account_id)
    
    # Get usage limit for tier
    var usage_limit = account_api_limits[tier].requests_per_minute
    
    # Check current usage
    var current_usage = api_usage.get(account_id, 0)
    
    return current_usage < usage_limit

func _track_api_usage(account_id):
    """
    Track API usage for rate limiting
    """
    if not account_id in api_usage:
        api_usage[account_id] = 0
        api_usage_time[account_id] = Time.get_unix_time_from_system()
    
    api_usage[account_id] += 1

func _reset_api_usage_counters():
    """
    Reset API usage counters (called by timer)
    """
    for account_id in api_usage:
        api_usage[account_id] = 0
        api_usage_time[account_id] = Time.get_unix_time_from_system()

func _get_account_tier(account_id):
    """
    Get account tier
    """
    # If we have account manager, get real tier
    if account_manager:
        var account = account_manager.get_account_data(account_id)
        if account:
            return account["tier_name"].to_lower()
    
    # Default to free
    return "free"

func _find_api_connection(from_account, to_account, api_type):
    """
    Find an existing API connection between accounts
    """
    var connection_id = from_account + "_to_" + to_account + "_" + APIType.keys()[api_type]
    
    if connection_id in api_connections:
        return connection_id
    
    return ""

func _set_connection_state(connection_id, new_state):
    """
    Update API connection state
    """
    if not connection_id in api_connections:
        return false
    
    api_connections[connection_id].state = new_state
    emit_signal("api_connection_state_changed", connection_id, new_state)
    
    return true

func _process_api_request(connection_id, request_data):
    """
    Process an API request
    """
    var connection = api_connections[connection_id]
    var api_type = connection.api_type
    
    # Simulate API processing
    var response = {
        "success": true,
        "timestamp": Time.get_unix_time_from_system(),
        "connection_id": connection_id,
        "api_type": APIType.keys()[api_type]
    }
    
    # Different response formats based on API type
    match api_type:
        APIType.CLAUDE:
            response["completion"] = "Response to: " + str(request_data).substr(0, 50) + "..."
            response["model"] = "claude-3-sonnet-20240229"
        APIType.GEMINI:
            response["text"] = "Processed request successfully: " + str(request_data).substr(0, 50) + "..."
            response["model"] = "gemini-pro"
        APIType.CUSTOM:
            response["data"] = {"result": "Custom API processed request", "input": str(request_data).substr(0, 30)}
            response["custom_fields"] = ["processed", "at", Time.get_date_dict_from_system()]
        APIType.INTERNAL:
            response["internal_data"] = {"status": "ok", "account": connection.to_account}
        APIType.SHARED:
            response["shared_data"] = {"source": connection.from_account, "target": connection.to_account}
        APIType.SECURE:
            response["secure_response"] = {"encrypted": true, "id": randi() % 1000}
    
    # Simulate processing time
    if thread_processor:
        # In a real implementation, would use thread processing
        pass
    else:
        # Simulate a delay
        # await get_tree().create_timer(randf_range(0.5, 1.5)).timeout
        pass
    
    return response

func _find_api_window(account_id):
    """
    Find an API window for an account
    """
    if not visualizer or not account_id in visualizer.account_windows:
        return -1
    
    var windows = visualizer.account_windows[account_id]
    
    for i in range(windows.size()):
        if windows[i].type == 1:  # API window type
            return i
    
    return -1

# Signal handlers

func _on_visualizer_api_connected(from_account, to_account, connection_type):
    # Create actual API connection in the controller
    if not _find_api_connection(from_account, to_account, APIType.CLAUDE).empty():
        return
    
    create_api_connection(from_account, to_account, APIType.CLAUDE)

func _on_visualizer_window_selected(account_id, window_id):
    # Handle window selection
    print("Window selected: " + window_id + " on account " + account_id)

func _on_visualizer_account_activated(account_id):
    # Handle account activation
    print("Account activated: " + account_id)
    
    # If using account manager, switch active account
    if account_manager:
        account_manager.switch_account(account_id)