extends Node

class_name DesktopTunnelConnector

signal file_transfer_started(source_path, target_path)
signal file_transfer_completed(source_path, target_path)
signal desktop_notification(title, message, level)
signal color_scheme_changed(scheme_name, colors)

# Configuration
const DEFAULT_CONFIG_PATH = "user://desktop_tunnel_config.json"
const DEFAULT_CONNECTION_TIMEOUT = 5.0

# Connection states
enum ConnectionState {
    DISCONNECTED,
    CONNECTING,
    CONNECTED,
    ERROR
}

# Desktop directories to monitor
var watched_directories = []
var file_filters = ["*.gd", "*.tscn", "*.json", "*.txt", "*.md"]

# Tunnel system references
var tunnel_controller
var ethereal_tunnel_manager

# Connection state
var current_state = ConnectionState.DISCONNECTED
var connection_error = ""
var last_sync_time = 0

# Desktop paths and anchors mapping
var path_to_anchor = {}
var anchor_to_path = {}

# File change detection
var file_modification_times = {}

# Config
var config = {
    "auto_sync_interval": 60,          # Seconds between auto-sync
    "enable_desktop_notifications": true,
    "enable_file_watching": true,
    "max_simultaneous_transfers": 3,
    "color_schemes": {
        "default": {
            "background": Color(0.12, 0.12, 0.18),
            "foreground": Color(0.9, 0.9, 0.95),
            "accent": Color(0.0, 0.7, 1.0), 
            "success": Color(0.0, 0.9, 0.3),
            "warning": Color(0.9, 0.9, 0.0),
            "error": Color(0.9, 0.2, 0.2)
        },
        "dark": {
            "background": Color(0.08, 0.08, 0.12),
            "foreground": Color(0.85, 0.85, 0.9),
            "accent": Color(0.3, 0.5, 1.0),
            "success": Color(0.0, 0.8, 0.2),
            "warning": Color(0.8, 0.8, 0.0),
            "error": Color(0.8, 0.1, 0.1)
        },
        "light": {
            "background": Color(0.9, 0.9, 0.95),
            "foreground": Color(0.1, 0.1, 0.15),
            "accent": Color(0.0, 0.5, 1.0),
            "success": Color(0.0, 0.7, 0.3),
            "warning": Color(0.9, 0.7, 0.0),
            "error": Color(0.9, 0.1, 0.1)
        },
        "ethereal": {
            "background": Color(0.15, 0.1, 0.2),
            "foreground": Color(0.9, 0.85, 1.0),
            "accent": Color(0.5, 0.3, 1.0),
            "success": Color(0.2, 0.9, 0.5),
            "warning": Color(1.0, 0.8, 0.2),
            "error": Color(1.0, 0.2, 0.5)
        }
    },
    "active_color_scheme": "default"
}

# Pending transfers
var pending_transfers = []
var active_transfers = []

func _ready():
    load_config()
    
    # Auto-detect components if in scene tree
    if not tunnel_controller:
        var potential_controllers = get_tree().get_nodes_in_group("tunnel_controllers")
        if potential_controllers.size() > 0:
            tunnel_controller = potential_controllers[0]
            print("Automatically found tunnel controller: " + tunnel_controller.name)
            ethereal_tunnel_manager = tunnel_controller.ethereal_tunnel_manager

func _process(delta):
    # Check for auto-sync
    if current_state == ConnectionState.CONNECTED and config.auto_sync_interval > 0:
        var current_time = Time.get_unix_time_from_system()
        if current_time - last_sync_time >= config.auto_sync_interval:
            sync_directories()
            last_sync_time = current_time
    
    # Process transfers
    _process_transfers()
    
    # Check for file changes in watched directories
    if config.enable_file_watching and Engine.get_idle_frames() % 30 == 0: # Check every 30 frames
        _check_for_file_changes()

func connect_to_desktop():
    if current_state == ConnectionState.CONNECTED:
        return true
    
    current_state = ConnectionState.CONNECTING
    
    # Attempt to connect to desktop environment
    var connected = _establish_desktop_connection()
    
    if connected:
        current_state = ConnectionState.CONNECTED
        print("Connected to desktop environment")
        
        # Start monitoring directories
        if config.enable_file_watching:
            _initialize_file_monitoring()
        
        # Apply color scheme
        apply_color_scheme(config.active_color_scheme)
        
        # Send desktop notification
        if config.enable_desktop_notifications:
            send_desktop_notification("Tunnel System Connected", "Ethereal tunnels connected to desktop", "info")
        
        return true
    else:
        current_state = ConnectionState.ERROR
        connection_error = "Failed to connect to desktop environment"
        print("Connection error: " + connection_error)
        return false

func disconnect_from_desktop():
    if current_state != ConnectionState.CONNECTED:
        return
    
    # Stop file watching
    _stop_file_monitoring()
    
    # Cancel any pending transfers
    pending_transfers.clear()
    
    # Wait for active transfers to complete
    for transfer in active_transfers:
        if transfer.has("cleanup_callback"):
            transfer.cleanup_callback.call_func()
    
    active_transfers.clear()
    
    current_state = ConnectionState.DISCONNECTED
    print("Disconnected from desktop environment")

func _establish_desktop_connection():
    # Check for OS access permissions
    if not OS.has_feature("pc"):
        connection_error = "This feature requires desktop environment"
        return false
    
    # Setup directories based on OS
    var user_directories = []
    
    if OS.has_feature("windows"):
        user_directories = [
            OS.get_environment("USERPROFILE") + "/Desktop",
            OS.get_environment("USERPROFILE") + "/Documents",
            OS.get_environment("USERPROFILE") + "/Downloads"
        ]
    elif OS.has_feature("macos"):
        user_directories = [
            OS.get_environment("HOME") + "/Desktop",
            OS.get_environment("HOME") + "/Documents",
            OS.get_environment("HOME") + "/Downloads"
        ]
    elif OS.has_feature("linux"):
        user_directories = [
            OS.get_environment("HOME") + "/Desktop",
            OS.get_environment("HOME") + "/Documents",
            OS.get_environment("HOME") + "/Downloads"
        ]
    else:
        connection_error = "Unsupported operating system"
        return false
    
    # Check if directories exist
    for dir in user_directories:
        if not DirAccess.dir_exists_absolute(dir):
            connection_error = "Cannot access directory: " + dir
            return false
    
    # Store valid directories
    watched_directories = user_directories
    
    return true

func register_directory_as_anchor(directory_path, anchor_id = ""):
    if not DirAccess.dir_exists_absolute(directory_path):
        print("Directory does not exist: " + directory_path)
        return null
    
    # Generate anchor ID if not provided
    if anchor_id.empty():
        var dir_name = directory_path.get_file()
        anchor_id = dir_name.to_lower().replace(" ", "_") + "_anchor"
    
    # Check if we have a tunnel manager
    if not ethereal_tunnel_manager:
        print("No tunnel manager available")
        return null
    
    # Create coordinates based on directory properties
    var dir_access = DirAccess.open(directory_path)
    var file_count = 0
    var total_size = 0
    
    dir_access.list_dir_begin()
    var file_name = dir_access.get_next()
    while file_name != "":
        if not dir_access.current_is_dir():
            var file_path = directory_path.path_join(file_name)
            var file_size = FileAccess.get_file_size(file_path)
            total_size += file_size
            file_count += 1
        file_name = dir_access.get_next()
    dir_access.list_dir_end()
    
    # Generate coordinates from directory properties
    var x = (directory_path.length() % 10) - 5.0
    var y = (file_count % 8) - 4.0
    var z = (total_size / 1024.0 / 1024.0) % 10 - 5.0
    
    var coordinates = Vector3(x, y, z)
    
    # Register the anchor
    var anchor = ethereal_tunnel_manager.register_anchor(anchor_id, coordinates, "directory")
    
    if anchor:
        # Store mapping
        path_to_anchor[directory_path] = anchor_id
        anchor_to_path[anchor_id] = directory_path
        
        print("Registered directory as anchor: " + directory_path + " -> " + anchor_id)
    
    return anchor

func create_tunnels_between_directories(source_dir, target_dir, dimension = 0):
    # Get or create anchors
    var source_anchor = path_to_anchor.get(source_dir)
    if not source_anchor:
        var source_result = register_directory_as_anchor(source_dir)
        if not source_result:
            return null
        source_anchor = path_to_anchor[source_dir]
    
    var target_anchor = path_to_anchor.get(target_dir)
    if not target_anchor:
        var target_result = register_directory_as_anchor(target_dir)
        if not target_result:
            return null
        target_anchor = path_to_anchor[target_dir]
    
    # Use current dimension if not specified
    if dimension <= 0 and tunnel_controller:
        dimension = tunnel_controller.current_dimension
    else:
        dimension = 3  # Default
    
    # Create tunnel
    if tunnel_controller:
        var tunnel = tunnel_controller.establish_tunnel(source_anchor, target_anchor)
        return tunnel
    elif ethereal_tunnel_manager:
        var tunnel = ethereal_tunnel_manager.establish_tunnel(source_anchor, target_anchor, dimension)
        return tunnel
    
    return null

func transfer_file(source_file, target_file, tunnel_id = ""):
    # Validate files
    if not FileAccess.file_exists(source_file):
        print("Source file does not exist: " + source_file)
        return false
    
    # Ensure target directory exists
    var target_dir = target_file.get_base_dir()
    if not DirAccess.dir_exists_absolute(target_dir):
        var dir_access = DirAccess.open("res://")
        dir_access.make_dir_recursive(target_dir)
    
    # If tunnel not specified, find appropriate tunnel
    if tunnel_id.empty():
        var source_dir = source_file.get_base_dir()
        var target_dir = target_file.get_base_dir()
        
        var source_anchor = path_to_anchor.get(source_dir)
        var target_anchor = path_to_anchor.get(target_dir)
        
        # Try to find parent directories if direct ones aren't registered
        if not source_anchor:
            for dir in path_to_anchor.keys():
                if source_dir.begins_with(dir):
                    source_anchor = path_to_anchor[dir]
                    break
        
        if not target_anchor:
            for dir in path_to_anchor.keys():
                if target_dir.begins_with(dir):
                    target_anchor = path_to_anchor[dir]
                    break
        
        if source_anchor and target_anchor:
            tunnel_id = source_anchor + "_to_" + target_anchor
            
            # Check if tunnel exists
            if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
                # Try reverse direction
                tunnel_id = target_anchor + "_to_" + source_anchor
                
                if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
                    # Create tunnel
                    var tunnel = create_tunnels_between_directories(source_dir, target_dir)
                    if tunnel:
                        tunnel_id = tunnel.id
    
    # Add to transfer queue
    var transfer = {
        "source_file": source_file,
        "target_file": target_file,
        "tunnel_id": tunnel_id,
        "status": "pending",
        "progress": 0.0,
        "file_size": FileAccess.get_file_size(source_file)
    }
    
    pending_transfers.push_back(transfer)
    emit_signal("file_transfer_started", source_file, target_file)
    
    return true

func sync_directories():
    if current_state != ConnectionState.CONNECTED:
        print("Not connected to desktop")
        return false
    
    # Create anchors for any unregistered watched directories
    for dir in watched_directories:
        if not path_to_anchor.has(dir):
            register_directory_as_anchor(dir)
    
    # Create tunnels between directories that don't have them
    for i in range(watched_directories.size()):
        for j in range(i+1, watched_directories.size()):
            var dir1 = watched_directories[i]
            var dir2 = watched_directories[j]
            
            var anchor1 = path_to_anchor.get(dir1)
            var anchor2 = path_to_anchor.get(dir2)
            
            if anchor1 and anchor2:
                var tunnel_id = anchor1 + "_to_" + anchor2
                var reverse_tunnel_id = anchor2 + "_to_" + anchor1
                
                if not ethereal_tunnel_manager.has_tunnel(tunnel_id) and not ethereal_tunnel_manager.has_tunnel(reverse_tunnel_id):
                    create_tunnels_between_directories(dir1, dir2)
    
    last_sync_time = Time.get_unix_time_from_system()
    return true

func send_desktop_notification(title, message, level = "info"):
    if not config.enable_desktop_notifications:
        return
    
    # Send notification through OS when possible
    if OS.has_feature("pc"):
        OS.request_attention()
    
    # Emit our own signal for in-app notifications
    emit_signal("desktop_notification", title, message, level)

func apply_color_scheme(scheme_name):
    if not config.color_schemes.has(scheme_name):
        print("Color scheme not found: " + scheme_name)
        return false
    
    var scheme = config.color_schemes[scheme_name]
    config.active_color_scheme = scheme_name
    
    # Apply colors to UI if possible
    emit_signal("color_scheme_changed", scheme_name, scheme)
    
    return true

func add_color_scheme(scheme_name, colors):
    config.color_schemes[scheme_name] = colors
    save_config()
    return true

func load_config():
    if not FileAccess.file_exists(DEFAULT_CONFIG_PATH):
        save_config()  # Save default config
        return
    
    var file = FileAccess.open(DEFAULT_CONFIG_PATH, FileAccess.READ)
    if not file:
        return
    
    var json = file.get_as_text()
    file.close()
    
    var json_result = JSON.parse_string(json)
    if json_result:
        # Only replace existing keys
        for key in json_result.keys():
            if config.has(key):
                config[key] = json_result[key]

func save_config():
    var file = FileAccess.open(DEFAULT_CONFIG_PATH, FileAccess.WRITE)
    if not file:
        return false
    
    var json = JSON.stringify(config)
    file.store_string(json)
    file.close()
    
    return true

func _process_transfers():
    # Start new transfers if we have capacity
    while pending_transfers.size() > 0 and active_transfers.size() < config.max_simultaneous_transfers:
        var transfer = pending_transfers.pop_front()
        transfer.status = "active"
        transfer.start_time = Time.get_unix_time_from_system()
        
        # Start transfer process
        _start_file_transfer(transfer)
        
        active_transfers.push_back(transfer)
    
    # Check for completed transfers
    var completed_transfers = []
    
    for transfer in active_transfers:
        if transfer.status == "completed" or transfer.status == "failed":
            completed_transfers.push_back(transfer)
            
            if transfer.status == "completed":
                emit_signal("file_transfer_completed", transfer.source_file, transfer.target_file)
    
    # Remove completed transfers
    for transfer in completed_transfers:
        active_transfers.erase(transfer)

func _start_file_transfer(transfer):
    # If using tunnel system for transfer visualization
    if transfer.tunnel_id != "" and tunnel_controller:
        # Read file content
        var file = FileAccess.open(transfer.source_file, FileAccess.READ)
        if not file:
            transfer.status = "failed"
            transfer.error = "Cannot open source file"
            return
        
        var content = file.get_as_text()
        file.close()
        
        # Send through tunnel (visualization only)
        tunnel_controller.transfer_through_tunnel(transfer.tunnel_id, content)
        
        # Connect to signal for visualization
        var completion_signal_id = tunnel_controller.connect("tunnel_transfer_completed", self, "_on_tunnel_transfer_completed", [transfer])
        
        # Store cleanup callback
        transfer.cleanup_callback = func():
            if tunnel_controller.is_connected("tunnel_transfer_completed", self, "_on_tunnel_transfer_completed"):
                tunnel_controller.disconnect("tunnel_transfer_completed", self, "_on_tunnel_transfer_completed")
    
    # Perform actual file copy (this happens immediately regardless of visualization)
    var source_file = FileAccess.open(transfer.source_file, FileAccess.READ)
    var target_file = FileAccess.open(transfer.target_file, FileAccess.WRITE)
    
    if not source_file or not target_file:
        transfer.status = "failed"
        transfer.error = "Failed to open files for copy"
        return
    
    var content = source_file.get_buffer(source_file.get_length())
    target_file.store_buffer(content)
    
    source_file.close()
    target_file.close()
    
    # If no tunnel visualization, mark as completed immediately
    if transfer.tunnel_id == "" or not tunnel_controller:
        transfer.status = "completed"
        transfer.progress = 1.0

func _on_tunnel_transfer_completed(tunnel_id, content, transfer):
    if transfer.tunnel_id == tunnel_id:
        transfer.status = "completed"
        transfer.progress = 1.0
        
        # Call cleanup callback
        if transfer.has("cleanup_callback"):
            transfer.cleanup_callback.call_func()

func _initialize_file_monitoring():
    # Create initial snapshot of file modification times
    for dir in watched_directories:
        _scan_directory_for_files(dir)

func _stop_file_monitoring():
    file_modification_times.clear()

func _scan_directory_for_files(directory):
    var dir_access = DirAccess.open(directory)
    if not dir_access:
        return
    
    dir_access.list_dir_begin()
    var file_name = dir_access.get_next()
    
    while file_name != "":
        var path = directory.path_join(file_name)
        
        if dir_access.current_is_dir():
            # Recursively scan subdirectories
            _scan_directory_for_files(path)
        else:
            # Check if file matches filters
            var matched = false
            for filter in file_filters:
                if file_name.match(filter):
                    matched = true
                    break
            
            if matched:
                # Store modification time
                var mod_time = FileAccess.get_modified_time(path)
                file_modification_times[path] = mod_time
        
        file_name = dir_access.get_next()
    
    dir_access.list_dir_end()

func _check_for_file_changes():
    var changed_files = []
    
    # Check existing files for changes
    for file_path in file_modification_times.keys():
        if FileAccess.file_exists(file_path):
            var current_mod_time = FileAccess.get_modified_time(file_path)
            var stored_mod_time = file_modification_times[file_path]
            
            if current_mod_time != stored_mod_time:
                changed_files.push_back(file_path)
                file_modification_times[file_path] = current_mod_time
    
    # Scan directories for new files
    for dir in watched_directories:
        _scan_for_new_files(dir, changed_files)
    
    # Process changed files
    for file_path in changed_files:
        _handle_file_change(file_path)

func _scan_for_new_files(directory, changed_files):
    var dir_access = DirAccess.open(directory)
    if not dir_access:
        return
    
    dir_access.list_dir_begin()
    var file_name = dir_access.get_next()
    
    while file_name != "":
        var path = directory.path_join(file_name)
        
        if dir_access.current_is_dir():
            # Recursively scan subdirectories
            _scan_for_new_files(path, changed_files)
        else:
            # Check if file matches filters
            var matched = false
            for filter in file_filters:
                if file_name.match(filter):
                    matched = true
                    break
            
            if matched and not file_modification_times.has(path):
                # New file found
                changed_files.push_back(path)
                var mod_time = FileAccess.get_modified_time(path)
                file_modification_times[path] = mod_time
        
        file_name = dir_access.get_next()
    
    dir_access.list_dir_end()

func _handle_file_change(file_path):
    # Notify about file change
    var file_name = file_path.get_file()
    var dir_name = file_path.get_base_dir().get_file()
    
    send_desktop_notification("File Changed", "File '" + file_name + "' in '" + dir_name + "' has changed", "info")
    
    # Here you could implement additional logic:
    # - Automatically transfer changed files to connected directories
    # - Update tunnel stability based on file activity
    # - Generate word manifestations from file content
    # - etc.

func get_connection_status():
    var status = {
        "state": current_state,
        "error": connection_error,
        "watched_directories": watched_directories,
        "registered_anchors": path_to_anchor.size(),
        "active_transfers": active_transfers.size(),
        "pending_transfers": pending_transfers.size(),
        "last_sync": last_sync_time
    }
    
    return status

func add_watched_directory(directory_path):
    if not DirAccess.dir_exists_absolute(directory_path):
        return false
    
    if not watched_directories.has(directory_path):
        watched_directories.push_back(directory_path)
        
        # Create anchor
        register_directory_as_anchor(directory_path)
        
        # Start monitoring
        if config.enable_file_watching:
            _scan_directory_for_files(directory_path)
        
        return true
    
    return false

func remove_watched_directory(directory_path):
    if watched_directories.has(directory_path):
        watched_directories.erase(directory_path)
        
        # Remove anchors and tunnels
        if path_to_anchor.has(directory_path):
            var anchor_id = path_to_anchor[directory_path]
            
            # Remove related tunnels
            var tunnels = ethereal_tunnel_manager.get_tunnels_for_anchor(anchor_id)
            for tunnel_id in tunnels:
                ethereal_tunnel_manager.collapse_tunnel(tunnel_id)
            
            # Remove anchor
            ethereal_tunnel_manager.remove_anchor(anchor_id)
            
            # Remove mappings
            anchor_to_path.erase(anchor_id)
            path_to_anchor.erase(directory_path)
        
        return true
    
    return false