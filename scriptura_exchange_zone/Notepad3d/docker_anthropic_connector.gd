extends Node

class_name DockerAnthropicConnector

# Anthropic API constants
const ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"
const DEFAULT_MODEL = "claude-3-opus-20240229"
const DEFAULT_MAX_TOKENS = 4096

# Docker connection properties
var docker_enabled = false
var docker_container_name = "anthropic-claude-terminal"
var docker_image = "anthropic/claude-terminal:latest"
var connection_status = "DISCONNECTED"

# Credentials and authentication
var api_key = ""
var api_version = "2023-06-01"

# Connection to other systems
var terminal_bridge = null
var akashic_bridge = null
var drive_connector = null

# Memory system
var conversation_history = []
var memory_storage = {}
var memory_drives = []

# Signals
signal api_response_received(response)
signal connection_status_changed(status)
signal memory_updated(drive_id, memory_id)

func _init():
    # Initialize the connector
    print("Initializing Docker Anthropic Connector...")
    
    # Load any saved credentials
    _load_credentials()
    
    # Check if Docker is installed and available
    _check_docker_availability()
    
    # Connect to terminal bridge if available
    _connect_to_terminal_bridge()
    
    # Connect to drive system if available
    _connect_to_drive_system()

func _load_credentials():
    # Check for credentials file
    var file = FileAccess.open("user://anthropic_credentials.cfg", FileAccess.READ)
    if file:
        api_key = file.get_line().strip_edges()
        file.close()
        
        if api_key != "":
            print("Anthropic API credentials loaded")
        else:
            print("Anthropic API credentials file exists but is empty")
    else:
        print("No Anthropic API credentials found")

func _check_docker_availability():
    # Try to run a simple docker command to check availability
    var output = []
    var exit_code = OS.execute("docker", ["--version"], output, true)
    
    if exit_code == 0:
        print("Docker available: " + output[0])
        docker_enabled = true
        connection_status = "DOCKER_AVAILABLE"
        emit_signal("connection_status_changed", connection_status)
    else:
        print("Docker not available or not installed")
        docker_enabled = false
        connection_status = "DOCKER_UNAVAILABLE"
        emit_signal("connection_status_changed", connection_status)

func _connect_to_terminal_bridge():
    # Check if TerminalVisualBridge is available
    if ClassDB.class_exists("TerminalVisualBridge"):
        terminal_bridge = load("res://terminal_visual_bridge.gd").new()
        print("Connected to TerminalVisualBridge")
    else:
        print("TerminalVisualBridge not available, trying to load directly")
        var script = load("/mnt/c/Users/Percision 15/terminal_visual_bridge.gd")
        if script:
            terminal_bridge = script.new()
            print("Loaded TerminalVisualBridge directly")
        else:
            print("TerminalVisualBridge not found, creating stub")
            terminal_bridge = Node.new()
            terminal_bridge.name = "TerminalBridgeStub"

func _connect_to_drive_system():
    # Check if DriveConnector is available
    if ClassDB.class_exists("DriveConnector"):
        drive_connector = load("res://drive_connector.gd").new()
        print("Connected to DriveConnector")
    else:
        print("DriveConnector not available, creating stub")
        drive_connector = Node.new()
        drive_connector.name = "DriveConnectorStub"

func set_api_key(key):
    # Set API key and save to file
    api_key = key
    
    var file = FileAccess.open("user://anthropic_credentials.cfg", FileAccess.WRITE)
    if file:
        file.store_line(api_key)
        file.close()
        print("Anthropic API credentials saved")
        return true
    else:
        print("Failed to save Anthropic API credentials")
        return false

func create_docker_container():
    if not docker_enabled:
        print("Docker not available")
        return false
    
    # Check if container already exists
    var output = []
    var exit_code = OS.execute("docker", ["ps", "-a", "--filter", "name=" + docker_container_name], output, true)
    
    if exit_code == 0 and output[0].find(docker_container_name) >= 0:
        print("Docker container already exists: " + docker_container_name)
        return true
    
    # Create the container
    var create_args = [
        "run",
        "-d",
        "--name", docker_container_name,
        "-e", "ANTHROPIC_API_KEY=" + api_key,
        "-v", "anthropic_data:/app/data",
        docker_image
    ]
    
    exit_code = OS.execute("docker", create_args, output, true)
    
    if exit_code == 0:
        print("Docker container created: " + docker_container_name)
        connection_status = "CONTAINER_CREATED"
        emit_signal("connection_status_changed", connection_status)
        return true
    else:
        print("Failed to create Docker container: " + output[0])
        connection_status = "CONTAINER_FAILED"
        emit_signal("connection_status_changed", connection_status)
        return false

func start_docker_container():
    if not docker_enabled:
        print("Docker not available")
        return false
    
    var output = []
    var exit_code = OS.execute("docker", ["start", docker_container_name], output, true)
    
    if exit_code == 0:
        print("Docker container started: " + docker_container_name)
        connection_status = "CONTAINER_RUNNING"
        emit_signal("connection_status_changed", connection_status)
        return true
    else:
        print("Failed to start Docker container: " + output[0])
        return false

func stop_docker_container():
    if not docker_enabled:
        print("Docker not available")
        return false
    
    var output = []
    var exit_code = OS.execute("docker", ["stop", docker_container_name], output, true)
    
    if exit_code == 0:
        print("Docker container stopped: " + docker_container_name)
        connection_status = "CONTAINER_STOPPED"
        emit_signal("connection_status_changed", connection_status)
        return true
    else:
        print("Failed to stop Docker container: " + output[0])
        return false

func remove_docker_container():
    if not docker_enabled:
        print("Docker not available")
        return false
    
    # Stop container first if running
    stop_docker_container()
    
    var output = []
    var exit_code = OS.execute("docker", ["rm", docker_container_name], output, true)
    
    if exit_code == 0:
        print("Docker container removed: " + docker_container_name)
        connection_status = "CONTAINER_REMOVED"
        emit_signal("connection_status_changed", connection_status)
        return true
    else:
        print("Failed to remove Docker container: " + output[0])
        return false

func send_api_request(message, system_prompt = "", model = DEFAULT_MODEL, max_tokens = DEFAULT_MAX_TOKENS):
    if api_key == "":
        print("API key not set")
        return null
    
    # Prepare the request
    var headers = [
        "Content-Type: application/json",
        "X-API-Key: " + api_key,
        "anthropic-version: " + api_version
    ]
    
    var messages = []
    
    # Add conversation history
    for msg in conversation_history:
        messages.append(msg)
    
    # Add the new message
    messages.append({
        "role": "user",
        "content": message
    })
    
    var data = {
        "model": model,
        "messages": messages,
        "max_tokens": max_tokens
    }
    
    if system_prompt != "":
        data["system"] = system_prompt
    
    # Create HTTP request
    var http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.connect("request_completed", self._on_request_completed)
    
    # Convert data to JSON
    var json_data = JSON.stringify(data)
    
    # Send the request
    var error = http_request.request(
        ANTHROPIC_API_URL,
        headers,
        HTTPClient.METHOD_POST,
        json_data
    )
    
    if error != OK:
        print("HTTP Request error: " + str(error))
        return null
    
    return true

func _on_request_completed(result, response_code, headers, body):
    # Process the API response
    if result != HTTPRequest.RESULT_SUCCESS:
        print("HTTP Request failed with result: " + str(result))
        return
    
    if response_code != 200:
        print("API request failed with response code: " + str(response_code))
        print("Response body: " + body.get_string_from_utf8())
        return
    
    # Parse the JSON response
    var json = JSON.parse_string(body.get_string_from_utf8())
    
    if not json:
        print("Failed to parse JSON response")
        return
    
    # Extract the assistant's response
    var assistant_message = {
        "role": "assistant",
        "content": json.content[0].text
    }
    
    # Add to conversation history
    conversation_history.append(assistant_message)
    
    # Emit signal with response
    emit_signal("api_response_received", assistant_message.content)
    
    # Process with terminal bridge if available
    if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
        terminal_bridge.process_terminal_command("words", [assistant_message.content])
    
    # Store in memory system
    _store_in_memory(assistant_message.content)

func _store_in_memory(content):
    # Generate a memory ID
    var memory_id = _generate_memory_id()
    
    # Create memory object
    var memory = {
        "id": memory_id,
        "content": content,
        "timestamp": OS.get_unix_time(),
        "type": "anthropic_response"
    }
    
    # Store in local memory
    memory_storage[memory_id] = memory
    
    # Store in akashic system if available
    if akashic_bridge and akashic_bridge.has_method("create_record"):
        akashic_bridge.create_record(memory_id, JSON.stringify(memory))
    
    # Store across drives if available
    if drive_connector and drive_connector.has_method("store_data"):
        for drive_id in memory_drives:
            drive_connector.store_data(drive_id, memory_id, JSON.stringify(memory))
            emit_signal("memory_updated", drive_id, memory_id)
    
    return memory_id

func _generate_memory_id():
    # Generate a unique memory ID
    return "anthropic_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000000)

func connect_to_drive(drive_id):
    # Add drive to memory drives list
    if not drive_id in memory_drives:
        memory_drives.append(drive_id)
        print("Connected to drive: " + drive_id)
        return true
    else:
        print("Already connected to drive: " + drive_id)
        return false

func disconnect_from_drive(drive_id):
    # Remove drive from memory drives list
    if drive_id in memory_drives:
        memory_drives.erase(drive_id)
        print("Disconnected from drive: " + drive_id)
        return true
    else:
        print("Not connected to drive: " + drive_id)
        return false

func get_connected_drives():
    return memory_drives

func clear_conversation_history():
    conversation_history.clear()
    print("Conversation history cleared")
    return true

func get_conversation_history():
    return conversation_history

func get_memory(memory_id):
    # Check local memory first
    if memory_id in memory_storage:
        return memory_storage[memory_id]
    
    # Check akashic system if available
    if akashic_bridge and akashic_bridge.has_method("read_record"):
        var record = akashic_bridge.read_record(memory_id)
        if record:
            var memory = JSON.parse_string(record)
            memory_storage[memory_id] = memory
            return memory
    
    # Check connected drives if available
    if drive_connector and drive_connector.has_method("get_data"):
        for drive_id in memory_drives:
            var data = drive_connector.get_data(drive_id, memory_id)
            if data:
                var memory = JSON.parse_string(data)
                memory_storage[memory_id] = memory
                return memory
    
    return null

func list_memories():
    var memories = []
    
    # Add local memories
    for memory_id in memory_storage.keys():
        memories.append(memory_id)
    
    # Add akashic memories if available
    if akashic_bridge and akashic_bridge.has_method("list_records"):
        var records = akashic_bridge.list_records()
        for record_id in records:
            if record_id.begins_with("anthropic_") and not record_id in memories:
                memories.append(record_id)
    
    # Add drive memories if available
    if drive_connector and drive_connector.has_method("list_data"):
        for drive_id in memory_drives:
            var data_list = drive_connector.list_data(drive_id)
            for data_id in data_list:
                if data_id.begins_with("anthropic_") and not data_id in memories:
                    memories.append(data_id)
    
    return memories

func get_docker_status():
    if not docker_enabled:
        return "DOCKER_UNAVAILABLE"
    
    var output = []
    var exit_code = OS.execute("docker", ["ps", "--filter", "name=" + docker_container_name, "--format", "{{.Status}}"], output, true)
    
    if exit_code == 0:
        if output.size() > 0 and output[0].strip_edges() != "":
            return "RUNNING: " + output[0].strip_edges()
        else:
            return "STOPPED"
    else:
        return "UNKNOWN"

func get_connection_status():
    return connection_status

# Terminal command interface for the connector
func process_command(command, args):
    match command:
        "set_api_key":
            if args.size() > 0:
                return set_api_key(args[0])
            else:
                return "API key not provided"
        
        "create_container":
            return create_docker_container()
        
        "start_container":
            return start_docker_container()
        
        "stop_container":
            return stop_docker_container()
        
        "remove_container":
            return remove_docker_container()
        
        "send_message":
            if args.size() > 0:
                var message = args.join(" ")
                return send_api_request(message)
            else:
                return "Message not provided"
        
        "clear_history":
            return clear_conversation_history()
        
        "status":
            return get_docker_status()
        
        "connect_drive":
            if args.size() > 0:
                return connect_to_drive(args[0])
            else:
                return "Drive ID not provided"
        
        "disconnect_drive":
            if args.size() > 0:
                return disconnect_from_drive(args[0])
            else:
                return "Drive ID not provided"
        
        "list_drives":
            return get_connected_drives()
        
        "list_memories":
            return list_memories()
        
        "get_memory":
            if args.size() > 0:
                return get_memory(args[0])
            else:
                return "Memory ID not provided"
        
        _:
            return "Unknown Docker Anthropic command: " + command