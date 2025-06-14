extends Node

class_name DriveConnector

# Drive types
const DRIVE_TYPES = {
    "LOCAL": {
        "color": Color(0.2, 0.7, 0.3, 1.0),  # Green
        "icon": "local_drive",
        "priority": 0
    },
    "NETWORK": {
        "color": Color(0.3, 0.5, 0.9, 1.0),  # Blue
        "icon": "network_drive",
        "priority": 1
    },
    "CLOUD": {
        "color": Color(0.6, 0.3, 0.9, 1.0),  # Purple
        "icon": "cloud_drive",
        "priority": 2
    },
    "REMOVABLE": {
        "color": Color(0.9, 0.6, 0.2, 1.0),  # Orange
        "icon": "removable_drive",
        "priority": 3
    },
    "VIRTUAL": {
        "color": Color(0.7, 0.7, 0.7, 1.0),  # Gray
        "icon": "virtual_drive",
        "priority": 4
    }
}

# Data storage states
const STORAGE_STATES = {
    "READY": {
        "color": Color(0.2, 0.8, 0.2, 1.0),  # Green
        "description": "Drive ready for data operations"
    },
    "SYNCING": {
        "color": Color(0.9, 0.9, 0.2, 1.0),  # Yellow
        "description": "Drive synchronizing data"
    },
    "LOCKED": {
        "color": Color(0.9, 0.2, 0.2, 1.0),  # Red
        "description": "Drive locked or read-only"
    },
    "DISCONNECTED": {
        "color": Color(0.5, 0.5, 0.5, 1.0),  # Gray
        "description": "Drive currently disconnected"
    },
    "CORRUPTED": {
        "color": Color(0.9, 0.5, 0.1, 1.0),  # Orange
        "description": "Drive data may be corrupted"
    }
}

# Properties
var connected_drives = {}
var active_sync_operations = {}
var datapoints = {}
var drive_stats = {}

# Connected systems
var terminal_bridge = null
var docker_connector = null
var akashic_bridge = null

# Visualization properties
var canvas = null
var drive_icons = []
var data_flow_lines = []
var sync_indicators = []

# Signals
signal drive_connected(drive_id)
signal drive_disconnected(drive_id)
signal data_stored(drive_id, data_id)
signal data_retrieved(drive_id, data_id)
signal data_updated(drive_id, data_id)
signal data_deleted(drive_id, data_id)
signal sync_started(source_drive, target_drive)
signal sync_completed(source_drive, target_drive)
signal sync_failed(source_drive, target_drive, error)

func _init():
    print("Initializing Drive Connector...")
    
    # Set up visualization
    _setup_visualization()
    
    # Connect to other systems
    _connect_systems()
    
    # Initialize default drives
    _initialize_default_drives()
    
    print("Drive Connector initialized")

func _setup_visualization():
    # Create visualization canvas
    canvas = Control.new()
    canvas.set_name("DriveCanvas")
    canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.connect("draw", Callable(self, "_draw_drives"))

func _connect_systems():
    # Connect to TerminalVisualBridge
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
    
    # Connect to DockerAnthropicConnector
    if ClassDB.class_exists("DockerAnthropicConnector"):
        docker_connector = load("res://docker_anthropic_connector.gd").new()
        print("Connected to DockerAnthropicConnector")
    else:
        print("DockerAnthropicConnector not available, trying to load directly")
        var script = load("/mnt/c/Users/Percision 15/docker_anthropic_connector.gd")
        if script:
            docker_connector = script.new()
            print("Loaded DockerAnthropicConnector directly")
        else:
            print("DockerAnthropicConnector not found, creating stub")
            docker_connector = Node.new()
            docker_connector.name = "DockerConnectorStub"
    
    # Connect to AkashicNumberSystem
    if ClassDB.class_exists("AkashicNumberSystem"):
        akashic_bridge = load("res://akashic_bridge.gd").new()
        print("Connected to AkashicNumberSystem")
    else:
        print("AkashicNumberSystem not available, creating stub")
        akashic_bridge = Node.new()
        akashic_bridge.name = "AkashicBridgeStub"

func _initialize_default_drives():
    # Add local drive
    connect_drive("local_c", "C Drive", "LOCAL", "/mnt/c")
    
    # Add any available removable drives
    var drives = _detect_drives()
    for drive in drives:
        if drive != "local_c":  # Skip C drive which we've already added
            connect_drive(drive.id, drive.name, drive.type, drive.path)

func _detect_drives():
    var detected_drives = []
    
    # Try to detect Windows drives through WSL
    var output = []
    var exit_code = OS.execute("ls", ["/mnt"], output, true)
    
    if exit_code == 0 and output.size() > 0:
        var drives = output[0].split("\n")
        
        for drive in drives:
            drive = drive.strip_edges()
            if drive.length() == 1 and drive.is_valid_identifier():
                var drive_letter = drive.to_lower()
                
                if drive_letter == "c":
                    continue  # Skip C drive as we've already added it
                
                var drive_type = "REMOVABLE"
                if drive_letter == "d":
                    drive_type = "REMOVABLE"  # Often DVD drive or secondary partition
                
                detected_drives.append({
                    "id": "local_" + drive_letter,
                    "name": drive_letter.to_upper() + " Drive",
                    "type": drive_type,
                    "path": "/mnt/" + drive_letter
                })
    }
    
    return detected_drives

func _process(delta):
    # Update sync operations
    _update_sync_operations(delta)
    
    # Update visualization
    if canvas:
        canvas.queue_redraw()

func _update_sync_operations(delta):
    var completed_syncs = []
    
    for sync_id in active_sync_operations.keys():
        var sync_op = active_sync_operations[sync_id]
        
        # Update progress
        sync_op.progress += delta * sync_op.speed
        
        if sync_op.progress >= 1.0:
            # Sync operation completed
            completed_syncs.append(sync_id)
            
            # Emit completed signal
            emit_signal("sync_completed", sync_op.source_drive, sync_op.target_drive)
            
            # Update drive stats
            if sync_op.source_drive in drive_stats and sync_op.target_drive in drive_stats:
                drive_stats[sync_op.source_drive].syncs_out += 1
                drive_stats[sync_op.target_drive].syncs_in += 1
        }
    
    # Remove completed syncs
    for sync_id in completed_syncs:
        active_sync_operations.erase(sync_id)

func _draw_drives():
    if not canvas:
        return
    
    var size = canvas.get_size()
    
    # Draw background
    canvas.draw_rect(Rect2(0, 0, size.x, size.y), Color(0.1, 0.1, 0.1, 1.0))
    
    # Draw drive icons
    _draw_drive_icons(size)
    
    # Draw sync operations
    _draw_sync_operations(size)
    
    # Draw data flow lines
    _draw_data_flow_lines(size)

func _draw_drive_icons(size):
    var drive_count = connected_drives.size()
    if drive_count == 0:
        return
    
    var spacing = size.x / (drive_count + 1)
    var i = 0
    
    for drive_id in connected_drives.keys():
        var drive = connected_drives[drive_id]
        var drive_type = drive.type
        var drive_state = drive.state
        
        var x = spacing * (i + 1)
        var y = size.y * 0.2
        
        # Draw drive icon
        var type_data = DRIVE_TYPES[drive_type]
        var state_data = STORAGE_STATES[drive_state]
        
        var icon_color = type_data.color
        var icon_state_color = state_data.color
        
        # Draw main drive icon
        canvas.draw_rect(
            Rect2(x - 30, y - 20, 60, 40),
            icon_color
        )
        
        # Draw state indicator
        canvas.draw_rect(
            Rect2(x - 20, y - 10, 40, 20),
            icon_color.darkened(0.3)
        )
        
        # Draw state indicator light
        canvas.draw_circle(
            Vector2(x + 25, y - 15),
            5,
            icon_state_color
        )
        
        # Draw drive name
        # Drawing text directly not supported in GDScript 4, would need a Label node
        # Instead, draw a text indicator rectangle
        var label_rect = Rect2(x - 40, y + 25, 80, 15)
        canvas.draw_rect(label_rect, icon_color.darkened(0.5))
        canvas.draw_rect(label_rect, icon_color, false, 1)
        
        # Draw data count
        var data_count = 0
        if drive_id in datapoints:
            data_count = datapoints[drive_id].size()
        
        var data_rect = Rect2(x - 15, y + 45, 30, 15)
        canvas.draw_rect(data_rect, Color(0.2, 0.2, 0.2, 0.8))
        canvas.draw_rect(data_rect, icon_color, false, 1)
        
        i += 1
    }

func _draw_sync_operations(size):
    for sync_id in active_sync_operations.keys():
        var sync_op = active_sync_operations[sync_id]
        
        var source_drive = sync_op.source_drive
        var target_drive = sync_op.target_drive
        
        if not source_drive in connected_drives or not target_drive in connected_drives:
            continue
        
        var source_index = connected_drives.keys().find(source_drive)
        var target_index = connected_drives.keys().find(target_drive)
        
        var drive_count = connected_drives.size()
        var spacing = size.x / (drive_count + 1)
        
        var source_x = spacing * (source_index + 1)
        var target_x = spacing * (target_index + 1)
        var y = size.y * 0.2
        
        # Calculate sync indicator position
        var progress = sync_op.progress
        var indicator_x = lerp(source_x, target_x, progress)
        
        # Draw sync line
        canvas.draw_line(
            Vector2(source_x, y),
            Vector2(target_x, y),
            Color(0.2, 0.6, 0.9, 0.5),
            2.0
        )
        
        # Draw data package
        var package_color = Color(0.2, 0.6, 0.9, 1.0)
        canvas.draw_rect(
            Rect2(indicator_x - 5, y - 5, 10, 10),
            package_color
        )
    }

func _draw_data_flow_lines(size):
    # Draw recent data flow lines
    for line in data_flow_lines:
        var progress = (OS.get_ticks_msec() - line.start_time) / 1000.0
        
        if progress > 1.0:
            continue
        
        var source_drive = line.source_drive
        var target_drive = line.target_drive
        
        if not source_drive in connected_drives or not target_drive in connected_drives:
            continue
        
        var source_index = connected_drives.keys().find(source_drive)
        var target_index = connected_drives.keys().find(target_drive)
        
        var drive_count = connected_drives.size()
        var spacing = size.x / (drive_count + 1)
        
        var source_x = spacing * (source_index + 1)
        var target_x = spacing * (target_index + 1)
        var y = size.y * 0.2 + 60  # Below the drive icons
        
        # Calculate flow indicator position
        var indicator_x = lerp(source_x, target_x, progress)
        
        # Draw flow line
        canvas.draw_line(
            Vector2(source_x, y),
            Vector2(target_x, y),
            Color(0.9, 0.6, 0.2, 0.3),
            1.0
        )
        
        # Draw data package
        var package_color = Color(0.9, 0.6, 0.2, 1.0)
        canvas.draw_rect(
            Rect2(indicator_x - 3, y - 3, 6, 6),
            package_color
        )
    }

func connect_drive(drive_id, drive_name, drive_type, drive_path):
    if drive_id in connected_drives:
        print("Drive already connected: " + drive_id)
        return false
    
    # Validate drive type
    if not drive_type in DRIVE_TYPES:
        print("Invalid drive type: " + drive_type)
        return false
    
    # Create drive object
    var drive = {
        "id": drive_id,
        "name": drive_name,
        "type": drive_type,
        "path": drive_path,
        "state": "READY",
        "connection_time": OS.get_unix_time(),
        "data_count": 0
    }
    
    # Initialize drive stats
    drive_stats[drive_id] = {
        "data_in": 0,
        "data_out": 0,
        "syncs_in": 0,
        "syncs_out": 0,
        "last_access": OS.get_unix_time()
    }
    
    # Initialize datapoints storage
    datapoints[drive_id] = {}
    
    # Add drive
    connected_drives[drive_id] = drive
    
    # Emit signal
    emit_signal("drive_connected", drive_id)
    
    print("Drive connected: " + drive_id + " (" + drive_name + ")")
    return true

func disconnect_drive(drive_id):
    if not drive_id in connected_drives:
        print("Drive not connected: " + drive_id)
        return false
    
    # Change drive state to disconnected
    connected_drives[drive_id].state = "DISCONNECTED"
    
    # Cancel any active sync operations involving this drive
    var syncs_to_cancel = []
    
    for sync_id in active_sync_operations.keys():
        var sync_op = active_sync_operations[sync_id]
        
        if sync_op.source_drive == drive_id or sync_op.target_drive == drive_id:
            syncs_to_cancel.append(sync_id)
        }
    
    for sync_id in syncs_to_cancel:
        var sync_op = active_sync_operations[sync_id]
        emit_signal("sync_failed", sync_op.source_drive, sync_op.target_drive, "Drive disconnected")
        active_sync_operations.erase(sync_id)
    
    # Remove drive
    connected_drives.erase(drive_id)
    
    # Emit signal
    emit_signal("drive_disconnected", drive_id)
    
    print("Drive disconnected: " + drive_id)
    return true

func store_data(drive_id, data_id, data_content):
    if not drive_id in connected_drives:
        print("Drive not connected: " + drive_id)
        return false
    
    var drive = connected_drives[drive_id]
    
    # Check drive state
    if drive.state == "LOCKED" or drive.state == "DISCONNECTED":
        print("Drive not available for writing: " + drive_id)
        return false
    
    # Store data
    if not drive_id in datapoints:
        datapoints[drive_id] = {}
    
    datapoints[drive_id][data_id] = {
        "id": data_id,
        "content": data_content,
        "timestamp": OS.get_unix_time(),
        "size": data_content.length()
    }
    
    # Update drive stats
    drive_stats[drive_id].data_in += 1
    drive_stats[drive_id].last_access = OS.get_unix_time()
    
    # Update drive data count
    drive.data_count = datapoints[drive_id].size()
    
    # Emit signal
    emit_signal("data_stored", drive_id, data_id)
    
    print("Data stored on drive " + drive_id + ": " + data_id)
    return true

func get_data(drive_id, data_id):
    if not drive_id in connected_drives:
        print("Drive not connected: " + drive_id)
        return null
    
    var drive = connected_drives[drive_id]
    
    # Check drive state
    if drive.state == "DISCONNECTED":
        print("Drive not available for reading: " + drive_id)
        return null
    
    # Get data
    if not drive_id in datapoints:
        print("No data on drive: " + drive_id)
        return null
    
    if not data_id in datapoints[drive_id]:
        print("Data not found on drive " + drive_id + ": " + data_id)
        return null
    
    var data = datapoints[drive_id][data_id]
    
    # Update drive stats
    drive_stats[drive_id].data_out += 1
    drive_stats[drive_id].last_access = OS.get_unix_time()
    
    # Emit signal
    emit_signal("data_retrieved", drive_id, data_id)
    
    print("Data retrieved from drive " + drive_id + ": " + data_id)
    return data.content

func update_data(drive_id, data_id, data_content):
    if not drive_id in connected_drives:
        print("Drive not connected: " + drive_id)
        return false
    
    var drive = connected_drives[drive_id]
    
    # Check drive state
    if drive.state == "LOCKED" or drive.state == "DISCONNECTED":
        print("Drive not available for writing: " + drive_id)
        return false
    
    # Check if data exists
    if not drive_id in datapoints or not data_id in datapoints[drive_id]:
        return store_data(drive_id, data_id, data_content)
    
    # Update data
    datapoints[drive_id][data_id].content = data_content
    datapoints[drive_id][data_id].timestamp = OS.get_unix_time()
    datapoints[drive_id][data_id].size = data_content.length()
    
    # Update drive stats
    drive_stats[drive_id].data_in += 1
    drive_stats[drive_id].last_access = OS.get_unix_time()
    
    # Emit signal
    emit_signal("data_updated", drive_id, data_id)
    
    print("Data updated on drive " + drive_id + ": " + data_id)
    return true

func delete_data(drive_id, data_id):
    if not drive_id in connected_drives:
        print("Drive not connected: " + drive_id)
        return false
    
    var drive = connected_drives[drive_id]
    
    # Check drive state
    if drive.state == "LOCKED" or drive.state == "DISCONNECTED":
        print("Drive not available for writing: " + drive_id)
        return false
    
    # Check if data exists
    if not drive_id in datapoints or not data_id in datapoints[drive_id]:
        print("Data not found on drive " + drive_id + ": " + data_id)
        return false
    
    # Delete data
    datapoints[drive_id].erase(data_id)
    
    # Update drive data count
    drive.data_count = datapoints[drive_id].size()
    
    # Emit signal
    emit_signal("data_deleted", drive_id, data_id)
    
    print("Data deleted from drive " + drive_id + ": " + data_id)
    return true

func list_data(drive_id):
    if not drive_id in connected_drives:
        print("Drive not connected: " + drive_id)
        return []
    
    var drive = connected_drives[drive_id]
    
    # Check drive state
    if drive.state == "DISCONNECTED":
        print("Drive not available for reading: " + drive_id)
        return []
    
    # List data
    if not drive_id in datapoints:
        return []
    
    # Update drive stats
    drive_stats[drive_id].last_access = OS.get_unix_time()
    
    return datapoints[drive_id].keys()

func sync_drives(source_drive, target_drive, filter_prefix = ""):
    if not source_drive in connected_drives:
        print("Source drive not connected: " + source_drive)
        return false
    
    if not target_drive in connected_drives:
        print("Target drive not connected: " + target_drive)
        return false
    
    var source = connected_drives[source_drive]
    var target = connected_drives[target_drive]
    
    # Check drive states
    if source.state == "DISCONNECTED":
        print("Source drive not available for reading: " + source_drive)
        return false
    
    if target.state == "LOCKED" or target.state == "DISCONNECTED":
        print("Target drive not available for writing: " + target_drive)
        return false
    
    # Set drives to syncing state
    source.state = "SYNCING"
    target.state = "SYNCING"
    
    # Create sync operation
    var sync_id = "sync_" + str(OS.get_unix_time()) + "_" + source_drive + "_" + target_drive
    
    var sync_op = {
        "id": sync_id,
        "source_drive": source_drive,
        "target_drive": target_drive,
        "start_time": OS.get_unix_time(),
        "progress": 0.0,
        "speed": 0.1 + randf() * 0.2,  # Random speed between 0.1 and 0.3
        "filter_prefix": filter_prefix
    }
    
    active_sync_operations[sync_id] = sync_op
    
    # Start syncing data in the background
    _start_background_sync(sync_id)
    
    # Emit signal
    emit_signal("sync_started", source_drive, target_drive)
    
    print("Sync started from " + source_drive + " to " + target_drive)
    return sync_id

func _start_background_sync(sync_id):
    if not sync_id in active_sync_operations:
        return
    
    var sync_op = active_sync_operations[sync_id]
    var source_drive = sync_op.source_drive
    var target_drive = sync_op.target_drive
    var filter_prefix = sync_op.filter_prefix
    
    # Get data to sync
    var data_to_sync = []
    
    if source_drive in datapoints:
        for data_id in datapoints[source_drive].keys():
            if filter_prefix == "" or data_id.begins_with(filter_prefix):
                data_to_sync.append(data_id)
        }
    
    # Update sync operation
    sync_op.data_count = data_to_sync.size()
    
    # Sync will complete automatically in _process function
    # Add a data flow line for visualization
    data_flow_lines.append({
        "source_drive": source_drive,
        "target_drive": target_drive,
        "start_time": OS.get_ticks_msec(),
        "data_count": data_to_sync.size()
    })
    
    # When sync completes, the data will be copied
    # This happens in _update_sync_operations when progress reaches 1.0
    
    # Schedule actual data copy when sync completes
    await get_tree().create_timer(sync_op.speed * 10.0).timeout
    
    # Copy the data if sync is still active
    if sync_id in active_sync_operations and active_sync_operations[sync_id].progress >= 1.0:
        # Copy data from source to target
        for data_id in data_to_sync:
            var data_content = get_data(source_drive, data_id)
            if data_content:
                store_data(target_drive, data_id, data_content)
        }
        
        # Set drives back to ready state
        if source_drive in connected_drives:
            connected_drives[source_drive].state = "READY"
        
        if target_drive in connected_drives:
            connected_drives[target_drive].state = "READY"
    }

func cancel_sync(sync_id):
    if not sync_id in active_sync_operations:
        print("Sync operation not found: " + sync_id)
        return false
    
    var sync_op = active_sync_operations[sync_id]
    
    # Cancel sync
    active_sync_operations.erase(sync_id)
    
    # Set drives back to ready state
    var source_drive = sync_op.source_drive
    var target_drive = sync_op.target_drive
    
    if source_drive in connected_drives:
        connected_drives[source_drive].state = "READY"
    
    if target_drive in connected_drives:
        connected_drives[target_drive].state = "READY"
    
    # Emit signal
    emit_signal("sync_failed", source_drive, target_drive, "Sync cancelled")
    
    print("Sync cancelled: " + sync_id)
    return true

func get_drive_state(drive_id):
    if not drive_id in connected_drives:
        print("Drive not connected: " + drive_id)
        return "DISCONNECTED"
    
    return connected_drives[drive_id].state

func set_drive_state(drive_id, state):
    if not drive_id in connected_drives:
        print("Drive not connected: " + drive_id)
        return false
    
    if not state in STORAGE_STATES:
        print("Invalid drive state: " + state)
        return false
    
    connected_drives[drive_id].state = state
    print("Drive state changed: " + drive_id + " -> " + state)
    
    return true

func get_drive_stats(drive_id):
    if not drive_id in drive_stats:
        print("Drive stats not found: " + drive_id)
        return null
    
    return drive_stats[drive_id]

func get_connected_drives():
    return connected_drives.keys()

func get_active_syncs():
    return active_sync_operations.keys()

func get_visualization_canvas():
    return canvas

# Terminal command interface for the connector
func process_command(command, args):
    match command:
        "connect_drive":
            if args.size() >= 3:
                var drive_id = args[0]
                var drive_name = args[1]
                var drive_type = args[2]
                var drive_path = ""
                
                if args.size() >= 4:
                    drive_path = args[3]
                
                return connect_drive(drive_id, drive_name, drive_type, drive_path)
            else:
                return "Insufficient arguments for connect_drive"
        
        "disconnect_drive":
            if args.size() >= 1:
                return disconnect_drive(args[0])
            else:
                return "Drive ID not provided"
        
        "store_data":
            if args.size() >= 3:
                var drive_id = args[0]
                var data_id = args[1]
                var data_content = args[2]
                
                return store_data(drive_id, data_id, data_content)
            else:
                return "Insufficient arguments for store_data"
        
        "get_data":
            if args.size() >= 2:
                var drive_id = args[0]
                var data_id = args[1]
                
                return get_data(drive_id, data_id)
            else:
                return "Insufficient arguments for get_data"
        
        "update_data":
            if args.size() >= 3:
                var drive_id = args[0]
                var data_id = args[1]
                var data_content = args[2]
                
                return update_data(drive_id, data_id, data_content)
            else:
                return "Insufficient arguments for update_data"
        
        "delete_data":
            if args.size() >= 2:
                var drive_id = args[0]
                var data_id = args[1]
                
                return delete_data(drive_id, data_id)
            else:
                return "Insufficient arguments for delete_data"
        
        "list_data":
            if args.size() >= 1:
                return list_data(args[0])
            else:
                return "Drive ID not provided"
        
        "sync_drives":
            if args.size() >= 2:
                var source_drive = args[0]
                var target_drive = args[1]
                var filter_prefix = ""
                
                if args.size() >= 3:
                    filter_prefix = args[2]
                
                return sync_drives(source_drive, target_drive, filter_prefix)
            else:
                return "Insufficient arguments for sync_drives"
        
        "cancel_sync":
            if args.size() >= 1:
                return cancel_sync(args[0])
            else:
                return "Sync ID not provided"
        
        "get_drive_state":
            if args.size() >= 1:
                return get_drive_state(args[0])
            else:
                return "Drive ID not provided"
        
        "set_drive_state":
            if args.size() >= 2:
                var drive_id = args[0]
                var state = args[1]
                
                return set_drive_state(drive_id, state)
            else:
                return "Insufficient arguments for set_drive_state"
        
        "get_drive_stats":
            if args.size() >= 1:
                return get_drive_stats(args[0])
            else:
                return "Drive ID not provided"
        
        "list_drives":
            return get_connected_drives()
        
        "list_syncs":
            return get_active_syncs()
        
        _:
            return "Unknown Drive Connector command: " + command