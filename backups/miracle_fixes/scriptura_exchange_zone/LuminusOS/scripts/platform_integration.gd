extends Node

class_name PlatformIntegration

# Platform Integration System for LuminusOS
# Enables cross-platform gameplay, synchronization, and VR/Desktop compatibility

signal platform_initialized(platform_info)
signal synchronization_complete(data_size)
signal device_connected(device_id, platform)
signal remote_command_received(command, params)
signal remote_game_event(game_id, event_type, data)

# Constants
const SUPPORTED_PLATFORMS = ["Windows", "Linux", "macOS", "Android", "iOS", "Web", "VR"]
const SYNC_INTERVAL = 60  # Seconds between automatic syncs
const MAX_REMOTE_DEVICES = 8
const PROTOCOL_VERSION = "1.0"

# Platform detection and info
var platform_info = {
    "os": "",
    "device_type": "",
    "screen_size": Vector2i(0, 0),
    "capabilities": {
        "vr_support": false,
        "touch_support": false,
        "gamepad_support": false,
        "multi_display": false,
        "high_performance": false
    },
    "memory_mb": 0,
    "device_id": "",
    "protocol_version": PROTOCOL_VERSION
}

# Connected devices
var connected_devices = {}

# Game session state
var active_games = {}
var shared_game_state = {}

# Synchronization state
var last_sync_time = 0
var sync_progress = 0.0
var pending_sync_operations = []
var sync_timer = null

# Platform adapters
var vr_adapter = null
var mobile_adapter = null
var desktop_adapter = null
var web_adapter = null

# Local data tracking
var game_creator = null
var data_evolution_system = null
var storage_manager = null

func _ready():
    print("Platform Integration System initializing...")
    
    # Detect platform
    _detect_platform()
    
    # Create a unique device ID if not already set
    if platform_info.device_id.is_empty():
        platform_info.device_id = _generate_device_id()
    
    # Set up synchronization timer
    sync_timer = Timer.new()
    sync_timer.wait_time = SYNC_INTERVAL
    sync_timer.autostart = true
    sync_timer.one_shot = false
    sync_timer.timeout.connect(_on_sync_timer)
    add_child(sync_timer)
    
    # Initialize platform-specific adapters
    _initialize_platform_adapters()
    
    # Try to connect to external systems
    _connect_to_external_systems()
    
    print("Platform Integration initialized for " + platform_info.os + " " + platform_info.device_type)
    emit_signal("platform_initialized", platform_info)

# Initialize connection to a remote platform/device
func connect_to_remote(device_id, address, platform_type="unknown"):
    # Check if already connected
    if connected_devices.has(device_id):
        return "Already connected to device: " + device_id
    
    # Validate device ID
    if not _is_valid_device_id(device_id):
        return "Invalid device ID format"
    
    # Limit number of connections
    if connected_devices.size() >= MAX_REMOTE_DEVICES:
        return "Maximum number of connected devices reached (" + str(MAX_REMOTE_DEVICES) + ")"
    
    # Create connection record
    connected_devices[device_id] = {
        "address": address,
        "platform": platform_type,
        "connection_time": Time.get_unix_time_from_system(),
        "last_sync_time": 0,
        "status": "connecting"
    }
    
    # Platform-specific connection logic (simulated)
    var success = _establish_connection(device_id, address)
    
    if success:
        connected_devices[device_id].status = "connected"
        emit_signal("device_connected", device_id, platform_type)
        return "Successfully connected to " + platform_type + " device: " + device_id
    else:
        connected_devices[device_id].status = "failed"
        return "Failed to connect to device. Check address and try again."

# Register a game for cross-platform compatibility
func register_game(game_id, compatibility_options={}):
    if not active_games.has(game_id):
        # Default compatibility options
        var default_options = {
            "vr_enabled": false,
            "touch_enabled": false,
            "gamepad_enabled": false,
            "multi_display": false,
            "sync_interval": 30,  # Seconds
            "data_priority": "medium",
            "shared_state_enabled": true,
            "platform_specific_settings": {}
        }
        
        # Merge with provided options
        for key in compatibility_options:
            default_options[key] = compatibility_options[key]
        
        # Register game
        active_games[game_id] = default_options
        
        # Initialize shared state
        if default_options.shared_state_enabled and not shared_game_state.has(game_id):
            shared_game_state[game_id] = {
                "global": {},
                "players": {},
                "last_update": Time.get_unix_time_from_system(),
                "version": 1
            }
        
        return "Game registered for cross-platform play: " + game_id
    else:
        return "Game already registered: " + game_id

# Synchronize game data between platforms
func synchronize_game(game_id, force=false):
    if not active_games.has(game_id):
        return "Game not registered: " + game_id
    
    # Check if sync is needed based on interval
    var now = Time.get_unix_time_from_system()
    var last_sync = active_games[game_id].get("last_sync_time", 0)
    
    if not force and (now - last_sync) < active_games[game_id].sync_interval:
        return "Sync not needed yet. Last sync was " + str(int(now - last_sync)) + " seconds ago."
    
    # Check for connected devices
    if connected_devices.size() == 0:
        return "No devices connected for synchronization."
    
    # Prepare synchronization
    var sync_operation = {
        "game_id": game_id,
        "start_time": now,
        "status": "in_progress",
        "devices": connected_devices.keys(),
        "data_size": 0,
        "completed_devices": []
    }
    
    pending_sync_operations.append(sync_operation)
    
    # Begin sync process (simulated)
    _process_sync_operation(sync_operation.size() - 1)
    
    return "Synchronization started for game: " + game_id

# Get shared game state
func get_shared_state(game_id, key="", default_value=null):
    if not shared_game_state.has(game_id):
        return default_value
    
    if key.is_empty():
        return shared_game_state[game_id].global
    
    if shared_game_state[game_id].global.has(key):
        return shared_game_state[game_id].global[key]
    
    return default_value

# Set shared game state
func set_shared_state(game_id, key, value):
    if not active_games.has(game_id):
        return "Game not registered: " + game_id
    
    if not shared_game_state.has(game_id):
        shared_game_state[game_id] = {
            "global": {},
            "players": {},
            "last_update": Time.get_unix_time_from_system(),
            "version": 1
        }
    
    # Update state
    shared_game_state[game_id].global[key] = value
    shared_game_state[game_id].last_update = Time.get_unix_time_from_system()
    shared_game_state[game_id].version += 1
    
    # Schedule sync
    _queue_state_sync(game_id)
    
    return "State updated: " + game_id + "." + key

# List connected devices
func list_connected_devices():
    var result = "Connected Devices (" + str(connected_devices.size()) + "):\n\n"
    
    if connected_devices.size() == 0:
        return "No devices connected."
    
    for device_id in connected_devices:
        var device = connected_devices[device_id]
        result += "- " + device_id + " (" + device.platform + ")\n"
        result += "  Status: " + device.status + "\n"
        result += "  Connected: " + _format_time_ago(device.connection_time) + "\n"
        result += "  Last sync: " + (device.last_sync_time > 0 ? _format_time_ago(device.last_sync_time) : "Never") + "\n\n"
    
    return result

# Get platform compatibility report for a game
func get_compatibility_report(game_id):
    if not active_games.has(game_id):
        return "Game not registered: " + game_id
    
    var result = "Compatibility Report for " + game_id + ":\n\n"
    
    var game_settings = active_games[game_id]
    result += "VR Support: " + ("Enabled" if game_settings.vr_enabled else "Disabled") + "\n"
    result += "Touch Support: " + ("Enabled" if game_settings.touch_enabled else "Disabled") + "\n"
    result += "Gamepad Support: " + ("Enabled" if game_settings.gamepad_enabled else "Disabled") + "\n"
    result += "Multi-Display: " + ("Enabled" if game_settings.multi_display else "Disabled") + "\n"
    result += "Shared State: " + ("Enabled" if game_settings.shared_state_enabled else "Disabled") + "\n"
    result += "Sync Interval: " + str(game_settings.sync_interval) + " seconds\n\n"
    
    # Platform-specific settings
    result += "Platform-Specific Settings:\n"
    for platform in game_settings.platform_specific_settings:
        result += "- " + platform + ":\n"
        for setting in game_settings.platform_specific_settings[platform]:
            var value = game_settings.platform_specific_settings[platform][setting]
            result += "  " + setting + ": " + str(value) + "\n"
    
    # Compatibility scores
    result += "\nCompatibility Scores:\n"
    for platform in SUPPORTED_PLATFORMS:
        var score = _calculate_compatibility_score(game_id, platform)
        result += "- " + platform + ": " + str(score) + "/10\n"
    
    return result

# Process platform integration commands
func cmd_platform(args):
    if args.size() == 0:
        var result = "Platform Integration Commands:\n\n"
        result += "platform info - Show platform information\n"
        result += "platform connect <device_id> <address> [platform_type] - Connect to a remote device\n"
        result += "platform devices - List connected devices\n"
        result += "platform register <game_id> - Register a game for cross-platform play\n"
        result += "platform sync <game_id> [force] - Synchronize game data\n"
        result += "platform state <game_id> [key] [value] - Get/set shared game state\n"
        result += "platform compatibility <game_id> - Show compatibility report\n"
        result += "platform vr <enable/disable> <game_id> - Enable/disable VR for a game\n"
        return result
    
    match args[0]:
        "info":
            return _get_platform_info()
            
        "connect":
            if args.size() < 3:
                return "Usage: platform connect <device_id> <address> [platform_type]"
                
            var platform_type = "unknown"
            if args.size() >= 4:
                platform_type = args[3]
                
            return connect_to_remote(args[1], args[2], platform_type)
            
        "devices":
            return list_connected_devices()
            
        "register":
            if args.size() < 2:
                return "Usage: platform register <game_id>"
                
            return register_game(args[1])
            
        "sync":
            if args.size() < 2:
                return "Usage: platform sync <game_id> [force]"
                
            var force = false
            if args.size() >= 3 and args[2].to_lower() == "force":
                force = true
                
            return synchronize_game(args[1], force)
            
        "state":
            if args.size() < 2:
                return "Usage: platform state <game_id> [key] [value]"
            
            # Get state
            if args.size() == 2:
                var state = get_shared_state(args[1])
                if state == null:
                    return "No shared state for game: " + args[1]
                
                var result = "Shared State for " + args[1] + ":\n\n"
                for key in state:
                    result += key + ": " + str(state[key]) + "\n"
                return result
            
            # Get specific key
            if args.size() == 3:
                var value = get_shared_state(args[1], args[2])
                if value == null:
                    return "No value for key: " + args[2]
                return args[2] + " = " + str(value)
            
            # Set key-value
            if args.size() >= 4:
                var value = args[3]
                if args.size() > 4:
                    value = " ".join(args.slice(3))
                
                return set_shared_state(args[1], args[2], value)
            
        "compatibility":
            if args.size() < 2:
                return "Usage: platform compatibility <game_id>"
                
            return get_compatibility_report(args[1])
            
        "vr":
            if args.size() < 3:
                return "Usage: platform vr <enable/disable> <game_id>"
                
            var enable = args[1].to_lower() == "enable"
            
            if not active_games.has(args[2]):
                return "Game not registered: " + args[2]
                
            active_games[args[2]].vr_enabled = enable
            
            if enable:
                return "VR support enabled for game: " + args[2]
            else:
                return "VR support disabled for game: " + args[2]
            
        _:
            return "Unknown platform command. Try 'info', 'connect', 'devices', 'register', 'sync', 'state', 'compatibility', or 'vr'"

# Helper Functions

func _detect_platform():
    # Detect OS
    var os_name = OS.get_name()
    platform_info.os = os_name
    
    # Determine device type
    if OS.has_feature("mobile"):
        platform_info.device_type = "mobile"
    elif OS.has_feature("web"):
        platform_info.device_type = "web"
    else:
        platform_info.device_type = "desktop"
    
    # Set screen size
    platform_info.screen_size = DisplayServer.window_get_size()
    
    # Detect capabilities
    platform_info.capabilities.vr_support = OS.has_feature("vr")
    platform_info.capabilities.touch_support = DisplayServer.is_touchscreen_available()
    platform_info.capabilities.gamepad_support = Input.get_connected_joypads().size() > 0
    platform_info.capabilities.multi_display = DisplayServer.get_screen_count() > 1
    
    # Estimate performance level (simple heuristic)
    var performance_rating = 0
    
    # More cores = higher performance
    performance_rating += OS.get_processor_count() * 10
    
    # More memory = higher performance (limited info available in Godot)
    platform_info.memory_mb = OS.get_static_memory_usage() / (1024 * 1024)
    performance_rating += platform_info.memory_mb / 1024
    
    # Mobile devices typically have less powerful GPUs
    if platform_info.device_type == "mobile":
        performance_rating *= 0.7
    
    platform_info.capabilities.high_performance = performance_rating > 50

func _initialize_platform_adapters():
    # Create appropriate adapters based on platform
    match platform_info.device_type:
        "mobile":
            mobile_adapter = _create_mobile_adapter()
        "desktop":
            desktop_adapter = _create_desktop_adapter()
        "web":
            web_adapter = _create_web_adapter()
    
    # VR adapter if supported
    if platform_info.capabilities.vr_support:
        vr_adapter = _create_vr_adapter()

func _create_mobile_adapter():
    # Simulated mobile adapter
    return {
        "touch_controls": true,
        "orientation": "portrait",
        "screen_dpi": 300,
        "battery_level": 80
    }

func _create_desktop_adapter():
    # Simulated desktop adapter
    return {
        "multi_window": true,
        "keyboard_layout": "qwerty",
        "display_count": DisplayServer.get_screen_count(),
        "fullscreen_supported": true
    }

func _create_web_adapter():
    # Simulated web adapter
    return {
        "browser": "unknown",
        "local_storage": true,
        "webgl_supported": true,
        "offline_support": false
    }

func _create_vr_adapter():
    # Simulated VR adapter
    return {
        "headset_type": "unknown",
        "controllers": 2,
        "room_scale": true,
        "hand_tracking": false
    }

func _connect_to_external_systems():
    # Try to get references to required systems
    game_creator = get_node_or_null("/root/GameCreator")
    data_evolution_system = get_node_or_null("/root/DataEvolutionSystem")
    storage_manager = get_node_or_null("/root/StorageManager")
    
    # Output connection status
    if game_creator != null:
        print("Connected to GameCreator system")
    
    if data_evolution_system != null:
        print("Connected to DataEvolutionSystem")
    
    if storage_manager != null:
        print("Connected to StorageManager")

func _generate_device_id():
    # Generate a unique device ID
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    
    var id_parts = []
    id_parts.append(platform_info.os.substr(0, 3).to_upper())
    id_parts.append(platform_info.device_type.substr(0, 3).to_upper())
    
    # Add random part
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var random_part = ""
    for i in range(8):
        random_part += chars[rng.randi() % chars.length()]
    
    id_parts.append(random_part)
    
    return "-".join(id_parts)

func _is_valid_device_id(device_id):
    # Basic validation
    if device_id.length() < 10:
        return false
    
    # Should contain at least two hyphens
    var hyphen_count = 0
    for c in device_id:
        if c == '-':
            hyphen_count += 1
    
    return hyphen_count >= 2

func _establish_connection(device_id, address):
    # Simulated connection logic
    print("Establishing connection to " + device_id + " at " + address)
    
    # Simulate connection delay
    await get_tree().create_timer(0.5).timeout
    
    # Random success (for simulation)
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    return rng.randf() > 0.2  # 80% success rate

func _process_sync_operation(operation_index):
    # Simulate synchronization process
    if operation_index < 0 or operation_index >= pending_sync_operations.size():
        return
    
    var operation = pending_sync_operations[operation_index]
    var game_id = operation.game_id
    
    # Calculate data size (simulated)
    var data_size = 0
    if game_creator != null and game_creator.created_games.has(game_id):
        var game_data = game_creator.created_games[game_id]
        
        # Rough estimate based on game content
        data_size += game_data.scenes.size() * 50  # KB per scene
        data_size += game_data.scripts.size() * 20  # KB per script
        data_size += game_data.resources.size() * 100  # KB per resource
    else:
        # Default size if game not found
        data_size = 200  # KB
    
    operation.data_size = data_size
    
    # Simulate sync time
    await get_tree().create_timer(data_size / 1000.0).timeout  # Larger games take longer
    
    # Mark devices as completed
    for device_id in operation.devices:
        operation.completed_devices.append(device_id)
        
        # Update device last sync time
        if connected_devices.has(device_id):
            connected_devices[device_id].last_sync_time = Time.get_unix_time_from_system()
    
    # Mark as complete
    operation.status = "completed"
    
    # Update game sync time
    if active_games.has(game_id):
        active_games[game_id].last_sync_time = Time.get_unix_time_from_system()
    
    # Send signal
    emit_signal("synchronization_complete", data_size)
    
    # Remove from pending operations
    pending_sync_operations.remove_at(operation_index)

func _queue_state_sync(game_id):
    # Queue state synchronization on next sync timer
    var already_queued = false
    
    for operation in pending_sync_operations:
        if operation.game_id == game_id:
            already_queued = true
            break
    
    if not already_queued:
        # Force immediate sync if high priority
        if active_games.has(game_id) and active_games[game_id].data_priority == "high":
            synchronize_game(game_id, true)

func _on_sync_timer():
    # Regular sync check for all active games
    for game_id in active_games:
        # Skip if already queued
        var already_queued = false
        for operation in pending_sync_operations:
            if operation.game_id == game_id:
                already_queued = true
                break
        
        if not already_queued:
            synchronize_game(game_id, false)

func _calculate_compatibility_score(game_id, platform):
    if not active_games.has(game_id):
        return 0
    
    var score = 7  # Base score
    var settings = active_games[game_id]
    
    # Platform specific adjustments
    match platform:
        "VR":
            if not settings.vr_enabled:
                score = 0  # Not compatible
            else:
                score += 3  # Full score
        "Android", "iOS":
            if not settings.touch_enabled:
                score -= 3
            if settings.platform_specific_settings.has(platform):
                score += 2
        "Web":
            if settings.data_priority == "high":
                score -= 2  # High data usage is problematic on web
            if settings.platform_specific_settings.has("Web"):
                score += 2
    
    # General adjustments
    if settings.gamepad_enabled:
        score += 1
    
    if settings.multi_display and platform == "Windows":
        score += 1
    
    return clamp(score, 0, 10)

func _get_platform_info():
    var result = "Platform Information:\n\n"
    
    result += "OS: " + platform_info.os + "\n"
    result += "Device Type: " + platform_info.device_type + "\n"
    result += "Device ID: " + platform_info.device_id + "\n"
    result += "Screen Size: " + str(platform_info.screen_size.x) + "x" + str(platform_info.screen_size.y) + "\n"
    result += "Memory: " + str(int(platform_info.memory_mb)) + " MB\n\n"
    
    result += "Capabilities:\n"
    result += "- VR Support: " + str(platform_info.capabilities.vr_support) + "\n"
    result += "- Touch Support: " + str(platform_info.capabilities.touch_support) + "\n"
    result += "- Gamepad Support: " + str(platform_info.capabilities.gamepad_support) + "\n"
    result += "- Multi-Display: " + str(platform_info.capabilities.multi_display) + "\n"
    result += "- High Performance: " + str(platform_info.capabilities.high_performance) + "\n\n"
    
    result += "Protocol Version: " + platform_info.protocol_version + "\n"
    
    return result

func _format_time_ago(timestamp):
    var now = Time.get_unix_time_from_system()
    var diff = now - timestamp
    
    if diff < 60:
        return str(int(diff)) + " seconds ago"
    elif diff < 3600:
        return str(int(diff / 60)) + " minutes ago"
    elif diff < 86400:
        return str(int(diff / 3600)) + " hours ago"
    else:
        return str(int(diff / 86400)) + " days ago"