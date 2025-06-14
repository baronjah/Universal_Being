extends Node
class_name EdenApiIntegration

# EdenApiIntegration
# Integration module between Eden Garden System and ApiSwitchManager
# Provides simplified API interface and synchronization for the garden ecosystem

signal api_data_received(data)
signal api_sync_completed(success)
signal api_status_changed(status_code, message)
signal api_command_processed(command_name, success)

# Core references
var api_manager = null
var eden_garden = null
var auto_sync_enabled = true
var sync_interval = 300.0 # 5 minutes
var sync_timer = null
var last_sync_time = 0
var offline_actions = []

# API command registry
var registered_commands = {}
var command_permissions = {}

# Cached garden data for offline mode
var cached_garden_state = {}
var pending_changes = []

class ApiCommand:
    var name = ""
    var endpoint_path = ""
    var method = "GET"
    var requires_online = true
    var cached_response = null
    var last_execution_time = 0
    var execution_count = 0
    var permission_level = 0
    
    func _init(p_name, p_endpoint_path, p_method="GET", p_requires_online=true, p_permission_level=0):
        name = p_name
        endpoint_path = p_endpoint_path
        method = p_method
        requires_online = p_requires_online
        permission_level = p_permission_level
    
    func to_dict():
        return {
            "name": name,
            "endpoint_path": endpoint_path,
            "method": method,
            "requires_online": requires_online,
            "last_execution_time": last_execution_time,
            "execution_count": execution_count,
            "permission_level": permission_level
        }

class OfflineAction:
    var action_type = ""
    var data = {}
    var timestamp = 0
    var processed = false
    var id = ""
    
    func _init(p_action_type, p_data={}):
        action_type = p_action_type
        data = p_data
        timestamp = OS.get_unix_time()
        id = str(timestamp) + "_" + str(randi())
    
    func to_dict():
        return {
            "action_type": action_type,
            "data": data,
            "timestamp": timestamp,
            "processed": processed,
            "id": id
        }
    
    func from_dict(dict_data):
        action_type = dict_data.get("action_type", "")
        data = dict_data.get("data", {})
        timestamp = dict_data.get("timestamp", 0)
        processed = dict_data.get("processed", false)
        id = dict_data.get("id", "")

func _ready():
    # Initialize sync timer
    sync_timer = Timer.new()
    sync_timer.wait_time = sync_interval
    sync_timer.one_shot = false
    sync_timer.connect("timeout", self, "_on_sync_timer_timeout")
    add_child(sync_timer)
    
    # Load offline actions
    load_offline_actions()
    
    # Default API commands
    register_command("get_garden_state", "garden/state", "GET", true, 0)
    register_command("update_garden_state", "garden/state", "POST", true, 1)
    register_command("list_fruits", "garden/fruits", "GET", false, 0)
    register_command("add_fruit", "garden/fruits", "POST", true, 1)
    register_command("get_echoes", "garden/echoes", "GET", false, 0)
    register_command("create_echo", "garden/echoes", "POST", true, 1)
    register_command("get_system_status", "system/status", "GET", false, 0)
    register_command("restart_system", "system/restart", "POST", true, 2)

# Setup and Connection Methods

func initialize(api_manager_node, eden_garden_node):
    if not api_manager_node or not eden_garden_node:
        push_error("Cannot initialize EdenApiIntegration with null nodes")
        return false
    
    api_manager = api_manager_node
    eden_garden = eden_garden_node
    
    # Connect API manager signals
    api_manager.connect("api_switched", self, "_on_api_switched")
    api_manager.connect("connection_state_changed", self, "_on_connection_state_changed")
    api_manager.connect("request_completed", self, "_on_api_request_completed")
    
    # Connect Eden Garden signals
    eden_garden.connect("garden_state_changed", self, "_on_garden_state_changed")
    eden_garden.connect("fruit_added", self, "_on_fruit_added")
    eden_garden.connect("echo_created", self, "_on_echo_created")
    eden_garden.connect("system_went_offline", self, "_on_system_went_offline")
    eden_garden.connect("system_went_online", self, "_on_system_went_online")
    
    print("EdenApiIntegration initialized")
    
    # Start auto sync if enabled
    if auto_sync_enabled:
        sync_timer.start()
    
    return true

# API Command Management

func register_command(name, endpoint_path, method="GET", requires_online=true, permission_level=0):
    var command = ApiCommand.new(name, endpoint_path, method, requires_online, permission_level)
    registered_commands[name] = command
    return command

func unregister_command(name):
    if registered_commands.has(name):
        registered_commands.erase(name)
        return true
    return false

func execute_command(command_name, data={}, custom_headers={}, use_endpoint=""):
    if not registered_commands.has(command_name):
        push_error("Unknown API command: %s" % command_name)
        emit_signal("api_command_processed", command_name, false)
        return false
    
    var command = registered_commands[command_name]
    
    # Check if we're offline and command requires online
    if command.requires_online and not api_manager.is_in_online_mode():
        # Add to offline actions queue
        var offline_action = OfflineAction.new("api_command", {
            "command_name": command_name,
            "data": data,
            "custom_headers": custom_headers,
            "use_endpoint": use_endpoint
        })
        offline_actions.append(offline_action)
        save_offline_actions()
        print("Added command %s to offline actions queue" % command_name)
        return true
    
    # Execute the command
    var success = api_manager.make_request(command.endpoint_path, command.method, data, custom_headers, use_endpoint)
    
    if success:
        command.last_execution_time = OS.get_unix_time()
        command.execution_count += 1
    
    return success

# Synchronization Methods

func sync_garden_state():
    if not api_manager.is_in_online_mode():
        print("Cannot sync garden state: offline mode")
        emit_signal("api_sync_completed", false)
        return false
    
    # Get current garden state
    var garden_state = eden_garden.get_garden_state()
    
    # Send to API
    var success = execute_command("update_garden_state", garden_state)
    
    if success:
        last_sync_time = OS.get_unix_time()
        print("Garden state sync initiated")
        return true
    else:
        emit_signal("api_sync_completed", false)
        return false

func import_garden_state():
    if not api_manager.is_in_online_mode():
        print("Cannot import garden state: offline mode")
        return false
    
    return execute_command("get_garden_state")

func process_offline_actions():
    if not api_manager.is_in_online_mode() or offline_actions.empty():
        return false
    
    print("Processing %d offline actions..." % offline_actions.size())
    
    var processed_count = 0
    var actions_to_keep = []
    
    for action in offline_actions:
        if action.processed:
            continue
        
        var success = false
        
        match action.action_type:
            "api_command":
                var cmd_data = action.data
                success = execute_command(
                    cmd_data.command_name, 
                    cmd_data.data, 
                    cmd_data.custom_headers, 
                    cmd_data.use_endpoint
                )
            "garden_state_change":
                # Apply changes to latest garden state
                success = execute_command("update_garden_state", action.data)
            "fruit_added":
                success = execute_command("add_fruit", action.data)
            "echo_created":
                success = execute_command("create_echo", action.data)
        
        if success:
            action.processed = true
            processed_count += 1
        
        # Keep the action (even if processed) until we get confirmation from the API
        actions_to_keep.append(action)
    
    # Update the offline actions list
    offline_actions = actions_to_keep
    save_offline_actions()
    
    print("Processed %d offline actions, %d remaining" % [processed_count, actions_to_keep.size()])
    return processed_count > 0

func toggle_auto_sync(enabled):
    auto_sync_enabled = enabled
    
    if auto_sync_enabled:
        if not sync_timer.is_stopped():
            sync_timer.start()
        print("Auto sync enabled, interval: %d seconds" % sync_interval)
    else:
        sync_timer.stop()
        print("Auto sync disabled")

func set_sync_interval(seconds):
    sync_interval = seconds
    sync_timer.wait_time = seconds
    print("Sync interval set to %d seconds" % seconds)

# Eden Garden Integration Methods

func update_cached_garden_state(state):
    cached_garden_state = state.duplicate(true)
    print("Cached garden state updated")

func apply_garden_state(state):
    if not eden_garden:
        push_error("Cannot apply garden state: Eden Garden node not set")
        return false
    
    return eden_garden.apply_garden_state(state)

func switch_api_endpoint(endpoint_name):
    if not api_manager:
        push_error("Cannot switch API endpoint: API manager not set")
        return false
    
    return api_manager.switch_to_endpoint(endpoint_name)

func get_available_endpoints():
    if not api_manager:
        return []
    
    return api_manager.list_endpoints()

func create_custom_endpoint(name, url, auth_token="", headers={}):
    if not api_manager:
        push_error("Cannot create endpoint: API manager not set")
        return false
    
    if not name.begins_with("custom_"):
        name = "custom_" + name
    
    var endpoint = api_manager.add_endpoint(name, url, auth_token, headers, 10.0, 5)
    api_manager.save_persistent_data()
    return endpoint != null

# Data Persistence

func save_offline_actions():
    var file = File.new()
    var data = []
    
    for action in offline_actions:
        if not action.processed:  # Only save unprocessed actions
            data.append(action.to_dict())
    
    var json_string = JSON.print(data, "  ")
    var error = file.open("user://eden_offline_actions.json", File.WRITE)
    if error != OK:
        push_error("Error saving offline actions: %s" % error)
        return false
    
    file.store_string(json_string)
    file.close()
    return true

func load_offline_actions():
    var file = File.new()
    if not file.file_exists("user://eden_offline_actions.json"):
        return false
    
    var error = file.open("user://eden_offline_actions.json", File.READ)
    if error != OK:
        push_error("Error loading offline actions: %s" % error)
        return false
    
    var json_string = file.get_as_text()
    file.close()
    
    var json_result = JSON.parse(json_string)
    if json_result.error != OK:
        push_error("Error parsing offline actions: %s at line %s" % [json_result.error, json_result.error_line])
        return false
    
    var actions_data = json_result.result
    offline_actions = []
    
    for action_data in actions_data:
        var action = OfflineAction.new("", {})
        action.from_dict(action_data)
        offline_actions.append(action)
    
    print("Loaded %d offline actions" % offline_actions.size())
    return true

# Signal Handlers

func _on_sync_timer_timeout():
    if auto_sync_enabled and api_manager and api_manager.is_in_online_mode():
        sync_garden_state()

func _on_api_switched(endpoint_name):
    print("API endpoint switched to: %s" % endpoint_name)
    emit_signal("api_status_changed", 200, "API endpoint switched to " + endpoint_name)
    
    if api_manager.is_in_online_mode():
        # Try to process any offline actions with the new endpoint
        process_offline_actions()

func _on_connection_state_changed(is_online):
    if is_online:
        emit_signal("api_status_changed", 200, "System is online")
        process_offline_actions()
    else:
        emit_signal("api_status_changed", 503, "System is offline")

func _on_api_request_completed(endpoint_name, success, data):
    if success:
        emit_signal("api_data_received", data)
        
        # Process specific responses
        if data.has("type"):
            match data.type:
                "garden_state":
                    if apply_garden_state(data.garden_state):
                        update_cached_garden_state(data.garden_state)
                        emit_signal("api_sync_completed", true)
                "system_status":
                    emit_signal("api_status_changed", 200, data.message)
    else:
        emit_signal("api_status_changed", 500, "API request failed")

func _on_garden_state_changed(new_state):
    update_cached_garden_state(new_state)
    
    if auto_sync_enabled and api_manager and api_manager.is_in_online_mode():
        # Schedule sync with a small delay to batch multiple changes
        if sync_timer.is_stopped():
            sync_timer.wait_time = 5.0  # Short delay to batch changes
            sync_timer.one_shot = true
            sync_timer.start()
    else:
        # Add to offline actions
        var offline_action = OfflineAction.new("garden_state_change", new_state)
        offline_actions.append(offline_action)
        save_offline_actions()

func _on_fruit_added(fruit_data):
    if api_manager and api_manager.is_in_online_mode():
        execute_command("add_fruit", fruit_data)
    else:
        var offline_action = OfflineAction.new("fruit_added", fruit_data)
        offline_actions.append(offline_action)
        save_offline_actions()

func _on_echo_created(echo_data):
    if api_manager and api_manager.is_in_online_mode():
        execute_command("create_echo", echo_data)
    else:
        var offline_action = OfflineAction.new("echo_created", echo_data)
        offline_actions.append(offline_action)
        save_offline_actions()

func _on_system_went_offline():
    if api_manager:
        api_manager.set_online_mode(false)

func _on_system_went_online():
    if api_manager:
        api_manager.set_online_mode(true)
        process_offline_actions()