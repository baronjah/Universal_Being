extends Node

class_name ExternalConnections

# External Connections System
# Connects the visualizer to external services like Claude API, Google Drive, and local Windows drives

# Configuration
var config = {
    "claude_api_key": "",  # Store in secure location, not hardcoded
    "google_drive_token_path": "user://google_drive_token.json",
    "windows_drives": ["C:", "D:"],
    "memory_paths": {
        "primary": "/mnt/c/Users/Percision 15/memory",
        "secondary": "/mnt/c/Users/Percision 15/OneDrive/memory",
        "tertiary": "/mnt/d/memory_backup"
    }
}

# Connection states
var connection_states = {
    "claude": false,
    "google_drive": false,
    "windows_drives": {},
    "memory_paths": {}
}

# References to other components
var terminal = null
var visualizer = null
var connector = null

# Signals
signal connection_state_changed(system, state)
signal data_transferred(system, bytes, direction)
signal memory_synced(source, target, files_count)

# Command execution tools
var http_request = null
var file_util = null
var process_runner = null

# Initialize connections
func _ready():
    # Initialize HTTP request for API connections
    http_request = HTTPRequest.new()
    add_child(http_request)
    
    # Initialize file utility
    file_util = Node.new()
    file_util.name = "FileUtil"
    add_child(file_util)
    
    # Initialize process runner
    process_runner = Node.new()
    process_runner.name = "ProcessRunner"
    add_child(process_runner)
    
    # Initialize Windows drive connection states
    for drive in config.windows_drives:
        connection_states.windows_drives[drive] = false
    
    # Initialize memory path connection states
    for key in config.memory_paths:
        connection_states.memory_paths[key] = false
    
    # Check initial connections
    check_all_connections()

# Connect to terminal
func connect_terminal(term):
    terminal = term
    
    # Register commands
    terminal.register_command("connect", "Connect to external service", funcref(self, "_cmd_connect"), 1, "connect <service>")
    terminal.register_command("disconnect", "Disconnect from external service", funcref(self, "_cmd_disconnect"), 1, "disconnect <service>")
    terminal.register_command("status", "Check connection status", funcref(self, "_cmd_status"))
    terminal.register_command("sync", "Synchronize memory paths", funcref(self, "_cmd_sync"), 0, "sync [source] [target]")
    terminal.register_command("drive", "Manage Google Drive", funcref(self, "_cmd_drive"), 1, "drive <subcommand> [args]")
    terminal.register_command("claude", "Interact with Claude API", funcref(self, "_cmd_claude"), 1, "claude <subcommand> [args]")
    terminal.register_command("memory", "Access memory paths", funcref(self, "_cmd_memory"), 1, "memory <subcommand> [args]")
    
    return true

# Connect to visualizer
func connect_visualizer(vis):
    visualizer = vis
    
    # Register data sources
    visualizer.register_data_source("claude", "Claude API", funcref(self, "_get_claude_data"))
    visualizer.register_data_source("gdrive", "Google Drive", funcref(self, "_get_gdrive_data"))
    visualizer.register_data_source("memory", "Memory Paths", funcref(self, "_get_memory_data"))
    
    return true

# Connect to project connector
func connect_project_connector(conn):
    connector = conn
    return true

# Check all external connections
func check_all_connections():
    check_claude_connection()
    check_google_drive_connection()
    check_windows_drives()
    check_memory_paths()
    
    return connection_states

# Check Claude API connection
func check_claude_connection():
    if config.claude_api_key.empty():
        connection_states.claude = false
        emit_signal("connection_state_changed", "claude", false)
        return false
    
    # In a real implementation, validate the API key with a request
    # For now, we'll just check if it exists
    connection_states.claude = true
    emit_signal("connection_state_changed", "claude", true)
    
    return true

# Check Google Drive connection
func check_google_drive_connection():
    var token_file = File.new()
    
    if not token_file.file_exists(config.google_drive_token_path):
        connection_states.google_drive = false
        emit_signal("connection_state_changed", "google_drive", false)
        return false
    
    # In a real implementation, validate the token
    # For now, we'll just check if the file exists
    connection_states.google_drive = true
    emit_signal("connection_state_changed", "google_drive", true)
    
    return true

# Check Windows drive connections
func check_windows_drives():
    var all_connected = true
    
    for drive in config.windows_drives:
        var dir = Directory.new()
        var path = "/mnt/" + drive.to_lower().replace(":", "")
        var exists = dir.dir_exists(path)
        
        connection_states.windows_drives[drive] = exists
        emit_signal("connection_state_changed", "windows_drive_" + drive, exists)
        
        if not exists:
            all_connected = false
    
    return all_connected

# Check memory path connections
func check_memory_paths():
    var all_connected = true
    
    for key in config.memory_paths:
        var dir = Directory.new()
        var path = config.memory_paths[key]
        var exists = dir.dir_exists(path)
        
        connection_states.memory_paths[key] = exists
        emit_signal("connection_state_changed", "memory_path_" + key, exists)
        
        if not exists:
            all_connected = false
    
    return all_connected

# Set Claude API key (should be done securely, not hardcoded)
func set_claude_api_key(key):
    config.claude_api_key = key
    check_claude_connection()
    return connection_states.claude

# Create memory directories if they don't exist
func create_memory_directories():
    var dir = Directory.new()
    var created_count = 0
    
    for key in config.memory_paths:
        var path = config.memory_paths[key]
        
        if not dir.dir_exists(path):
            # Create directory recursively
            var current_path = ""
            var parts = path.split("/")
            
            for part in parts:
                if part.empty():
                    current_path = "/"
                    continue
                
                current_path = current_path.plus_file(part)
                
                if not dir.dir_exists(current_path):
                    dir.make_dir(current_path)
                    created_count += 1
            
            emit_signal("connection_state_changed", "memory_path_" + key, true)
            connection_states.memory_paths[key] = true
        
    return created_count

# Synchronize memory paths
func sync_memory_paths(source_key = "primary", target_key = "all"):
    if not connection_states.memory_paths.has(source_key):
        return {
            "success": false,
            "error": "Source memory path not found: " + source_key
        }
    
    if not connection_states.memory_paths[source_key]:
        return {
            "success": false,
            "error": "Source memory path not connected: " + source_key
        }
    
    var source_path = config.memory_paths[source_key]
    var sync_targets = []
    
    if target_key == "all":
        # Sync to all other memory paths
        for key in config.memory_paths:
            if key != source_key and connection_states.memory_paths[key]:
                sync_targets.append({
                    "key": key,
                    "path": config.memory_paths[key]
                })
    else:
        # Sync to specific target
        if not connection_states.memory_paths.has(target_key):
            return {
                "success": false,
                "error": "Target memory path not found: " + target_key
            }
        
        if not connection_states.memory_paths[target_key]:
            return {
                "success": false,
                "error": "Target memory path not connected: " + target_key
            }
        
        sync_targets.append({
            "key": target_key,
            "path": config.memory_paths[target_key]
        })
    
    var results = {
        "success": true,
        "source": source_key,
        "targets": []
    }
    
    for target in sync_targets:
        var result = _sync_directories(source_path, target.path)
        result.key = target.key
        results.targets.append(result)
        
        emit_signal("memory_synced", source_key, target.key, result.files_synced)
    
    return results

# Internal: Synchronize two directories
func _sync_directories(source_path, target_path):
    var dir = Directory.new()
    var result = {
        "path": target_path,
        "files_synced": 0,
        "errors": []
    }
    
    # Ensure target directory exists
    if not dir.dir_exists(target_path):
        dir.make_dir_recursive(target_path)
    
    # Open source directory
    if dir.open(source_path) != OK:
        result.errors.append("Cannot open source directory: " + source_path)
        return result
    
    # Enumerate files
    dir.list_dir_begin(true, true)
    var file_name = dir.get_next()
    
    while file_name != "":
        var source_file = source_path.plus_file(file_name)
        var target_file = target_path.plus_file(file_name)
        
        if dir.current_is_dir():
            # Recursively sync subdirectory
            var subdir_result = _sync_directories(source_file, target_file)
            result.files_synced += subdir_result.files_synced
            result.errors.append_array(subdir_result.errors)
        else:
            # Copy file if newer
            var source_modified_time = File.new().get_modified_time(source_file)
            var target_modified_time = 0
            
            if File.new().file_exists(target_file):
                target_modified_time = File.new().get_modified_time(target_file)
            
            if source_modified_time > target_modified_time:
                # Source is newer, copy file
                var err = dir.copy(source_file, target_file)
                
                if err == OK:
                    result.files_synced += 1
                else:
                    result.errors.append("Failed to copy: " + source_file + " to " + target_file)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    
    return result

# Send a prompt to Claude API
func send_claude_prompt(prompt, model = "claude-3-5-sonnet-20240620"):
    if not connection_states.claude:
        return {
            "success": false,
            "error": "Claude API not connected"
        }
    
    # In a real implementation, send an HTTP request to the Claude API
    # For this demo, we'll simulate a response
    
    var response = {
        "success": true,
        "model": model,
        "prompt": prompt,
        "response": "This is a simulated response from Claude API.",
        "usage": {
            "input_tokens": prompt.length() / 4,
            "output_tokens": 10
        }
    }
    
    emit_signal("data_transferred", "claude", response.usage.input_tokens + response.usage.output_tokens, "out")
    
    return response

# List files in Google Drive
func list_google_drive_files(folder_path = "/"):
    if not connection_states.google_drive:
        return {
            "success": false,
            "error": "Google Drive not connected"
        }
    
    # In a real implementation, use the Google Drive API
    # For this demo, we'll simulate a response
    
    var files = [
        {"name": "Project Notes.txt", "type": "text", "size": 1024, "modified": "2024-05-15"},
        {"name": "Visualizer Data", "type": "folder", "size": 0, "modified": "2024-05-14"},
        {"name": "Research.pdf", "type": "pdf", "size": 2048576, "modified": "2024-05-10"}
    ]
    
    emit_signal("data_transferred", "google_drive", 1024, "in")
    
    return {
        "success": true,
        "path": folder_path,
        "files": files
    }

# Upload file to Google Drive
func upload_to_google_drive(local_path, remote_path):
    if not connection_states.google_drive:
        return {
            "success": false,
            "error": "Google Drive not connected"
        }
    
    var file = File.new()
    
    if not file.file_exists(local_path):
        return {
            "success": false,
            "error": "Local file does not exist: " + local_path
        }
    
    # In a real implementation, use the Google Drive API
    # For this demo, we'll simulate a response
    
    var file_size = file.get_len(local_path)
    emit_signal("data_transferred", "google_drive", file_size, "out")
    
    return {
        "success": true,
        "local_path": local_path,
        "remote_path": remote_path,
        "size": file_size
    }

# Download file from Google Drive
func download_from_google_drive(remote_path, local_path):
    if not connection_states.google_drive:
        return {
            "success": false,
            "error": "Google Drive not connected"
        }
    
    # In a real implementation, use the Google Drive API
    # For this demo, we'll simulate a response
    
    var file_size = 1024  # Simulated file size
    emit_signal("data_transferred", "google_drive", file_size, "in")
    
    return {
        "success": true,
        "remote_path": remote_path,
        "local_path": local_path,
        "size": file_size
    }

# Get memory path content
func get_memory_path_content(path_key = "primary", sub_path = ""):
    if not connection_states.memory_paths.has(path_key):
        return {
            "success": false,
            "error": "Memory path not found: " + path_key
        }
    
    if not connection_states.memory_paths[path_key]:
        return {
            "success": false,
            "error": "Memory path not connected: " + path_key
        }
    
    var base_path = config.memory_paths[path_key]
    var full_path = base_path
    
    if not sub_path.empty():
        full_path = base_path.plus_file(sub_path)
    
    var dir = Directory.new()
    
    if not dir.dir_exists(full_path):
        return {
            "success": false,
            "error": "Path does not exist: " + full_path
        }
    
    if dir.open(full_path) != OK:
        return {
            "success": false,
            "error": "Cannot open path: " + full_path
        }
    
    var files = []
    var dirs = []
    
    dir.list_dir_begin(true, true)
    var file_name = dir.get_next()
    
    while file_name != "":
        if dir.current_is_dir():
            dirs.append(file_name)
        else:
            files.append({
                "name": file_name,
                "size": File.new().get_len(full_path.plus_file(file_name)),
                "modified": File.new().get_modified_time(full_path.plus_file(file_name))
            })
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    
    return {
        "success": true,
        "path": full_path,
        "directories": dirs,
        "files": files
    }

# Store data in memory path
func store_in_memory(data, filename, path_key = "primary", sub_path = ""):
    if not connection_states.memory_paths.has(path_key):
        return {
            "success": false,
            "error": "Memory path not found: " + path_key
        }
    
    if not connection_states.memory_paths[path_key]:
        return {
            "success": false,
            "error": "Memory path not connected: " + path_key
        }
    
    var base_path = config.memory_paths[path_key]
    var dir_path = base_path
    
    if not sub_path.empty():
        dir_path = base_path.plus_file(sub_path)
    
    var file_path = dir_path.plus_file(filename)
    var dir = Directory.new()
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(dir_path):
        dir.make_dir_recursive(dir_path)
    
    # Write data to file
    var file = File.new()
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        return {
            "success": false,
            "error": "Cannot open file for writing: " + file_path
        }
    
    file.store_string(data)
    file.close()
    
    return {
        "success": true,
        "path": file_path,
        "size": data.length()
    }

# Retrieve data from memory path
func retrieve_from_memory(filename, path_key = "primary", sub_path = ""):
    if not connection_states.memory_paths.has(path_key):
        return {
            "success": false,
            "error": "Memory path not found: " + path_key
        }
    
    if not connection_states.memory_paths[path_key]:
        return {
            "success": false,
            "error": "Memory path not connected: " + path_key
        }
    
    var base_path = config.memory_paths[path_key]
    var dir_path = base_path
    
    if not sub_path.empty():
        dir_path = base_path.plus_file(sub_path)
    
    var file_path = dir_path.plus_file(filename)
    var file = File.new()
    
    if not file.file_exists(file_path):
        return {
            "success": false,
            "error": "File does not exist: " + file_path
        }
    
    var err = file.open(file_path, File.READ)
    
    if err != OK:
        return {
            "success": false,
            "error": "Cannot open file for reading: " + file_path
        }
    
    var content = file.get_as_text()
    file.close()
    
    return {
        "success": true,
        "path": file_path,
        "content": content,
        "size": content.length()
    }

# Data source handlers for visualizer

func _get_claude_data():
    return {
        "type": "claude",
        "connected": connection_states.claude,
        "model": "claude-3-5-sonnet-20240620",
        "tokens_used": 1024,
        "interactions": 5
    }

func _get_gdrive_data():
    return {
        "type": "gdrive",
        "connected": connection_states.google_drive,
        "files": 25,
        "space_used": 1024 * 1024 * 50,  # 50 MB
        "last_sync": OS.get_unix_time()
    }

func _get_memory_data():
    var total_files = 0
    var total_size = 0
    
    for key in connection_states.memory_paths:
        if connection_states.memory_paths[key]:
            var content = get_memory_path_content(key)
            
            if content.success:
                total_files += content.files.size()
                
                for file in content.files:
                    total_size += file.size
    
    return {
        "type": "memory",
        "connected_paths": connection_states.memory_paths.size(),
        "files": total_files,
        "size": total_size,
        "last_sync": OS.get_unix_time()
    }

# Terminal commands

func _cmd_connect(args):
    if args.size() < 1:
        return "ERROR: Usage: connect <service>"
    
    var service = args[0].to_lower()
    
    match service:
        "claude":
            if args.size() >= 2:
                set_claude_api_key(args[1])
                return "Claude API key set"
            else:
                return "ERROR: API key required"
        
        "gdrive", "google", "drive":
            # In a real implementation, start OAuth flow
            return "Google Drive authentication requires browser access"
        
        "windows", "drives":
            check_windows_drives()
            var connected = 0
            
            for drive in connection_states.windows_drives:
                if connection_states.windows_drives[drive]:
                    connected += 1
            
            return "Connected to " + str(connected) + "/" + str(connection_states.windows_drives.size()) + " Windows drives"
        
        "memory":
            create_memory_directories()
            check_memory_paths()
            var connected = 0
            
            for key in connection_states.memory_paths:
                if connection_states.memory_paths[key]:
                    connected += 1
            
            return "Connected to " + str(connected) + "/" + str(connection_states.memory_paths.size()) + " memory paths"
        
        _:
            return "ERROR: Unknown service: " + service

func _cmd_disconnect(args):
    if args.size() < 1:
        return "ERROR: Usage: disconnect <service>"
    
    var service = args[0].to_lower()
    
    match service:
        "claude":
            config.claude_api_key = ""
            connection_states.claude = false
            emit_signal("connection_state_changed", "claude", false)
            return "Disconnected from Claude API"
        
        "gdrive", "google", "drive":
            # In a real implementation, revoke token
            connection_states.google_drive = false
            emit_signal("connection_state_changed", "google_drive", false)
            return "Disconnected from Google Drive"
        
        _:
            return "ERROR: Cannot disconnect from " + service

func _cmd_status(args):
    var result = "Connection Status:\n"
    
    result += "  Claude API: " + ("Connected" if connection_states.claude else "Disconnected") + "\n"
    result += "  Google Drive: " + ("Connected" if connection_states.google_drive else "Disconnected") + "\n"
    
    result += "  Windows Drives:\n"
    for drive in connection_states.windows_drives:
        result += "    " + drive + ": " + ("Connected" if connection_states.windows_drives[drive] else "Disconnected") + "\n"
    
    result += "  Memory Paths:\n"
    for key in connection_states.memory_paths:
        result += "    " + key + " (" + config.memory_paths[key] + "): " + ("Connected" if connection_states.memory_paths[key] else "Disconnected") + "\n"
    
    return result

func _cmd_sync(args):
    var source = "primary"
    var target = "all"
    
    if args.size() >= 1:
        source = args[0]
    
    if args.size() >= 2:
        target = args[1]
    
    var result = sync_memory_paths(source, target)
    
    if not result.success:
        return "ERROR: " + result.error
    
    var output = "Synced from " + source + ":\n"
    
    for target_result in result.targets:
        output += "  To " + target_result.key + ": " + str(target_result.files_synced) + " files"
        
        if target_result.errors.size() > 0:
            output += " (" + str(target_result.errors.size()) + " errors)"
        
        output += "\n"
    
    return output

func _cmd_drive(args):
    if args.size() < 1:
        return "ERROR: Usage: drive <subcommand> [args]"
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1, args.size() - 1)
    
    match subcommand:
        "ls", "list":
            var path = "/"
            
            if subargs.size() >= 1:
                path = subargs[0]
            
            var result = list_google_drive_files(path)
            
            if not result.success:
                return "ERROR: " + result.error
            
            var output = "Contents of " + result.path + ":\n"
            
            for file in result.files:
                var type_symbol = file.type == "folder" ? "[DIR] " : ""
                output += "  " + type_symbol + file.name + " (" + str(file.size) + " bytes, " + file.modified + ")\n"
            
            return output
        
        "upload":
            if subargs.size() < 2:
                return "ERROR: Usage: drive upload <local_path> <remote_path>"
            
            var local_path = subargs[0]
            var remote_path = subargs[1]
            
            var result = upload_to_google_drive(local_path, remote_path)
            
            if not result.success:
                return "ERROR: " + result.error
            
            return "Uploaded " + local_path + " to " + remote_path + " (" + str(result.size) + " bytes)"
        
        "download":
            if subargs.size() < 2:
                return "ERROR: Usage: drive download <remote_path> <local_path>"
            
            var remote_path = subargs[0]
            var local_path = subargs[1]
            
            var result = download_from_google_drive(remote_path, local_path)
            
            if not result.success:
                return "ERROR: " + result.error
            
            return "Downloaded " + remote_path + " to " + local_path + " (" + str(result.size) + " bytes)"
        
        _:
            return "ERROR: Unknown subcommand: " + subcommand

func _cmd_claude(args):
    if args.size() < 1:
        return "ERROR: Usage: claude <subcommand> [args]"
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1, args.size() - 1)
    
    match subcommand:
        "prompt":
            if subargs.size() < 1:
                return "ERROR: Usage: claude prompt <text>"
            
            var prompt = subargs.join(" ")
            var result = send_claude_prompt(prompt)
            
            if not result.success:
                return "ERROR: " + result.error
            
            return "Claude response:\n" + result.response + "\n\nTokens used: " + str(result.usage.input_tokens + result.usage.output_tokens)
        
        "model":
            if subargs.size() < 1:
                return "Current model: claude-3-5-sonnet-20240620"
            
            return "Model set to: " + subargs[0]
        
        _:
            return "ERROR: Unknown subcommand: " + subcommand

func _cmd_memory(args):
    if args.size() < 1:
        return "ERROR: Usage: memory <subcommand> [args]"
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1, args.size() - 1)
    
    match subcommand:
        "ls", "list":
            var path_key = "primary"
            var sub_path = ""
            
            if subargs.size() >= 1:
                path_key = subargs[0]
            
            if subargs.size() >= 2:
                sub_path = subargs[1]
            
            var result = get_memory_path_content(path_key, sub_path)
            
            if not result.success:
                return "ERROR: " + result.error
            
            var output = "Contents of " + result.path + ":\n"
            
            output += "  Directories:\n"
            for dir_name in result.directories:
                output += "    [DIR] " + dir_name + "\n"
            
            output += "  Files:\n"
            for file in result.files:
                var date = Time.get_datetime_string_from_unix_time(file.modified)
                output += "    " + file.name + " (" + str(file.size) + " bytes, " + date + ")\n"
            
            return output
        
        "store":
            if subargs.size() < 2:
                return "ERROR: Usage: memory store <filename> <data> [path_key] [sub_path]"
            
            var filename = subargs[0]
            var data = subargs[1]
            var path_key = "primary"
            var sub_path = ""
            
            if subargs.size() >= 3:
                path_key = subargs[2]
            
            if subargs.size() >= 4:
                sub_path = subargs[3]
            
            var result = store_in_memory(data, filename, path_key, sub_path)
            
            if not result.success:
                return "ERROR: " + result.error
            
            return "Stored " + str(result.size) + " bytes to " + result.path
        
        "retrieve":
            if subargs.size() < 1:
                return "ERROR: Usage: memory retrieve <filename> [path_key] [sub_path]"
            
            var filename = subargs[0]
            var path_key = "primary"
            var sub_path = ""
            
            if subargs.size() >= 2:
                path_key = subargs[1]
            
            if subargs.size() >= 3:
                sub_path = subargs[2]
            
            var result = retrieve_from_memory(filename, path_key, sub_path)
            
            if not result.success:
                return "ERROR: " + result.error
            
            return "Content of " + result.path + " (" + str(result.size) + " bytes):\n" + result.content
        
        _:
            return "ERROR: Unknown subcommand: " + subcommand