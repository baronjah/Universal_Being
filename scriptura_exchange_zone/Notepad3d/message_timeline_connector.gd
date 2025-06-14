extends Node

class_name MessageTimelineConnector

# Constants for message lifecycle
const LIFECYCLE_STAGES = {
    "SEED": {
        "color": Color(0.2, 0.8, 0.2, 1.0),  # Green
        "energy": 0.1,
        "frequency": 33,
        "description": "Initial message idea"
    },
    "GERMINATING": {
        "color": Color(0.4, 0.8, 0.4, 1.0),  # Light green
        "energy": 0.3,
        "frequency": 89,
        "description": "Message in development"
    },
    "SPROUTING": {
        "color": Color(0.8, 0.8, 0.2, 1.0),  # Yellow-green
        "energy": 0.5,
        "frequency": 99,
        "description": "Message taking form"
    },
    "GROWING": {
        "color": Color(0.9, 0.7, 0.2, 1.0),  # Gold
        "energy": 0.7,
        "frequency": 333,
        "description": "Message evolving and expanding"
    },
    "BLOOMING": {
        "color": Color(1.0, 0.6, 0.2, 1.0),  # Orange
        "energy": 0.8,
        "frequency": 389,
        "description": "Message in full expression"
    },
    "FRUITING": {
        "color": Color(1.0, 0.4, 0.4, 1.0),  # Red-orange
        "energy": 0.9,
        "frequency": 555,
        "description": "Message producing results"
    },
    "SEEDING": {
        "color": Color(0.8, 0.2, 0.6, 1.0),  # Purple
        "energy": 1.0,
        "frequency": 777,
        "description": "Message generating new ideas"
    },
    "DORMANT": {
        "color": Color(0.4, 0.4, 0.6, 1.0),  # Blue-gray
        "energy": 0.2,
        "frequency": 999,
        "description": "Message stored for later activation"
    }
}

# App connection constants
const CLAUDE_APPS = {
    "CLAUDE_DESKTOP": {
        "type": "desktop",
        "color": Color(0.5, 0.6, 0.9, 1.0),  # Blue
        "priority": 1
    },
    "CLAUDE_BROWSER": {
        "type": "browser",
        "color": Color(0.7, 0.5, 0.9, 1.0),  # Purple
        "priority": 2
    },
    "CLAUDE_MOBILE": {
        "type": "mobile",
        "color": Color(0.3, 0.7, 0.8, 1.0),  # Teal
        "priority": 3
    },
    "CLAUDE_CODE": {
        "type": "terminal",
        "color": Color(0.2, 0.8, 0.6, 1.0),  # Green-blue
        "priority": 0
    },
    "CLAUDE_API": {
        "type": "api",
        "color": Color(0.8, 0.3, 0.3, 1.0),  # Red
        "priority": 4
    }
}

# Timeline constants
const HATCHING_INTERVALS = [9, 33, 89, 99, 333, 389, 555, 777, 999]  # In minutes
const MAX_TIMELINE_DURATION = 60 * 24 * 7  # One week in minutes
const DEFAULT_HATCHING_TIME = 389  # Default hatching time in minutes

# Visualization properties
var timeline_start_time = 0
var timeline_current_time = 0
var timeline_zoom = 1.0
var timeline_view_range = 24 * 60  # 24 hours in minutes

# Connection properties
var terminal_bridge = null
var docker_connector = null
var drive_connector = null
var akashic_bridge = null

# Timeline data
var messages = {}
var active_apps = {}
var connected_drives = []
var claude_instances = []

# Visualization elements
var canvas = null
var timeline_grid = []
var message_nodes = []
var app_connection_lines = []

# Signals
signal message_added(message_id)
signal message_updated(message_id)
signal message_hatched(message_id, stage)
signal app_connected(app_id)
signal app_disconnected(app_id)
signal timeline_updated()

func _init():
    print("Initializing Message Timeline Connector...")
    
    # Initialize the timeline
    _initialize_timeline()
    
    # Connect to systems
    _connect_systems()
    
    # Set up visualization
    _setup_visualization()
    
    print("Message Timeline Connector initialized")

func _initialize_timeline():
    # Set timeline start time to now
    timeline_start_time = OS.get_unix_time()
    timeline_current_time = timeline_start_time
    
    # Create initial timeline grid
    _create_timeline_grid()

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
    
    # Connect to DriveConnector
    if ClassDB.class_exists("DriveConnector"):
        drive_connector = load("res://drive_connector.gd").new()
        print("Connected to DriveConnector")
    else:
        print("DriveConnector not available, creating stub")
        drive_connector = Node.new()
        drive_connector.name = "DriveConnectorStub"
    
    # Connect to AkashicNumberSystem
    if ClassDB.class_exists("AkashicNumberSystem"):
        akashic_bridge = load("res://akashic_bridge.gd").new()
        print("Connected to AkashicNumberSystem")
    else:
        print("AkashicNumberSystem not available, creating stub")
        akashic_bridge = Node.new()
        akashic_bridge.name = "AkashicBridgeStub"

func _setup_visualization():
    # Create visualization canvas
    canvas = Control.new()
    canvas.set_name("TimelineCanvas")
    canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.connect("draw", Callable(self, "_draw_timeline"))
    
    # Create default Claude instances
    for app_id in CLAUDE_APPS.keys():
        _add_claude_instance(app_id)

func _create_timeline_grid():
    timeline_grid.clear()
    
    # Create major time markers (days)
    var day_count = MAX_TIMELINE_DURATION / (24 * 60)
    
    for i in range(day_count + 1):
        var marker = {
            "time": timeline_start_time + i * 24 * 60 * 60,  # Convert minutes to seconds
            "type": "day",
            "label": "Day " + str(i)
        }
        
        timeline_grid.append(marker)
    
    # Create hour markers
    var hour_count = MAX_TIMELINE_DURATION / 60
    
    for i in range(hour_count + 1):
        if i % 24 != 0:  # Skip hour markers that coincide with day markers
            var marker = {
                "time": timeline_start_time + i * 60 * 60,  # Convert minutes to seconds
                "type": "hour",
                "label": "Hour " + str(i % 24)
            }
            
            timeline_grid.append(marker)
        }
    
    # Create hatching interval markers
    for interval in HATCHING_INTERVALS:
        var marker_count = MAX_TIMELINE_DURATION / interval
        
        for i in range(1, marker_count + 1):
            var marker = {
                "time": timeline_start_time + i * interval * 60,  # Convert minutes to seconds
                "type": "hatching",
                "interval": interval,
                "label": "Hatching " + str(interval) + " #" + str(i)
            }
            
            timeline_grid.append(marker)
        }

func _process(delta):
    # Update timeline current time
    timeline_current_time = OS.get_unix_time()
    
    # Check for message hatching events
    _check_message_hatching()
    
    # Update visualization
    if canvas:
        canvas.queue_redraw()
    
    # Emit timeline updated signal
    emit_signal("timeline_updated")

func _check_message_hatching():
    # Check each message for hatching events
    for message_id in messages.keys():
        var message = messages[message_id]
        
        # Skip messages that have completed their lifecycle
        if message.lifecycle_stage == "SEEDING" or message.lifecycle_stage == "DORMANT":
            continue
        
        # Calculate time since creation
        var time_elapsed = timeline_current_time - message.creation_time
        var minutes_elapsed = time_elapsed / 60
        
        # Check if message should hatch to next stage
        var current_stage_index = _get_lifecycle_stage_index(message.lifecycle_stage)
        
        if current_stage_index < LIFECYCLE_STAGES.keys().size() - 1:
            var next_stage = LIFECYCLE_STAGES.keys()[current_stage_index + 1]
            
            # Check if it's time to hatch based on hatching schedule
            var hatching_time = message.hatching_schedule[current_stage_index]
            
            if minutes_elapsed >= hatching_time:
                # Hatch to next stage
                message.lifecycle_stage = next_stage
                message.last_hatched_time = timeline_current_time
                
                # Update message visualization
                _update_message_visualization(message_id)
                
                # Emit signal
                emit_signal("message_hatched", message_id, next_stage)
                
                # Log hatching event
                print("Message " + message_id + " hatched to " + next_stage)
                
                # Update message in connected systems
                _propagate_message_update(message_id)
        }

func _get_lifecycle_stage_index(stage):
    var stages = LIFECYCLE_STAGES.keys()
    return stages.find(stage)

func _update_message_visualization(message_id):
    # Find the message node
    for i in range(message_nodes.size()):
        if message_nodes[i].id == message_id:
            var message = messages[message_id]
            var lifecycle_data = LIFECYCLE_STAGES[message.lifecycle_stage]
            
            # Update node properties
            message_nodes[i].color = lifecycle_data.color
            message_nodes[i].energy = lifecycle_data.energy
            message_nodes[i].frequency = lifecycle_data.frequency
            
            break

func _propagate_message_update(message_id):
    var message = messages[message_id]
    
    # Update in Akashic system
    if akashic_bridge and akashic_bridge.has_method("update_record"):
        akashic_bridge.update_record(message_id, JSON.stringify(message))
    
    # Update in connected drives
    if drive_connector and drive_connector.has_method("update_data"):
        for drive_id in connected_drives:
            drive_connector.update_data(drive_id, message_id, JSON.stringify(message))
    
    # Update in Docker system for Claude instances
    if docker_connector and docker_connector.has_method("update_memory"):
        docker_connector.update_memory(message_id, JSON.stringify(message))
    
    # Emit message updated signal
    emit_signal("message_updated", message_id)

func _draw_timeline():
    if not canvas:
        return
    
    var size = canvas.get_size()
    
    # Draw background
    canvas.draw_rect(Rect2(0, 0, size.x, size.y), Color(0.15, 0.15, 0.15, 1.0))
    
    # Draw timeline grid
    _draw_timeline_grid(size)
    
    # Draw current time indicator
    _draw_current_time_indicator(size)
    
    # Draw message nodes
    _draw_message_nodes(size)
    
    # Draw app connections
    _draw_app_connections(size)

func _draw_timeline_grid(size):
    var timeline_width = size.x * 0.9
    var timeline_start_x = size.x * 0.05
    var timeline_y = size.y * 0.5
    var timeline_height = size.y * 0.8
    
    # Draw main timeline line
    canvas.draw_line(
        Vector2(timeline_start_x, timeline_y),
        Vector2(timeline_start_x + timeline_width, timeline_y),
        Color(0.5, 0.5, 0.5, 1.0),
        2.0
    )
    
    # Draw grid markers
    for marker in timeline_grid:
        var marker_time = marker.time
        var position_ratio = (marker_time - timeline_start_time) / (MAX_TIMELINE_DURATION * 60)
        position_ratio = position_ratio * timeline_zoom
        
        # Skip markers outside of view range
        if position_ratio < 0 or position_ratio > 1:
            continue
        
        var marker_x = timeline_start_x + position_ratio * timeline_width
        var marker_height = 0.0
        var marker_color = Color.GRAY
        
        match marker.type:
            "day":
                marker_height = timeline_height * 0.2
                marker_color = Color(1.0, 1.0, 1.0, 0.8)
            "hour":
                marker_height = timeline_height * 0.1
                marker_color = Color(0.7, 0.7, 0.7, 0.6)
            "hatching":
                marker_height = timeline_height * 0.15
                
                # Color based on interval
                var interval = marker.interval
                if interval == 9:
                    marker_color = Color(1.0, 0.3, 0.3, 0.7)  # Red
                elif interval == 33:
                    marker_color = Color(1.0, 0.6, 0.3, 0.7)  # Orange
                elif interval == 89:
                    marker_color = Color(1.0, 0.9, 0.3, 0.7)  # Yellow
                elif interval == 99:
                    marker_color = Color(0.6, 1.0, 0.3, 0.7)  # Green
                elif interval == 333:
                    marker_color = Color(0.3, 1.0, 0.8, 0.7)  # Teal
                elif interval == 389:
                    marker_color = Color(0.3, 0.7, 1.0, 0.7)  # Blue
                elif interval == 555:
                    marker_color = Color(0.6, 0.3, 1.0, 0.7)  # Purple
                elif interval == 777:
                    marker_color = Color(0.9, 0.3, 0.9, 0.7)  # Magenta
                elif interval == 999:
                    marker_color = Color(1.0, 1.0, 1.0, 0.7)  # White
        
        # Draw marker line
        canvas.draw_line(
            Vector2(marker_x, timeline_y - marker_height / 2),
            Vector2(marker_x, timeline_y + marker_height / 2),
            marker_color,
            2.0
        )
        
        # Draw marker label
        # Drawing text directly not supported in GDScript 4, would need a Label node
        # Instead, draw a text indicator rectangle
        var label_rect = Rect2(marker_x - 20, timeline_y + marker_height / 2 + 5, 40, 10)
        canvas.draw_rect(label_rect, marker_color.darkened(0.3))
        canvas.draw_rect(label_rect, marker_color, false, 1)

func _draw_current_time_indicator(size):
    var timeline_width = size.x * 0.9
    var timeline_start_x = size.x * 0.05
    var timeline_y = size.y * 0.5
    
    # Calculate position for current time
    var time_elapsed = timeline_current_time - timeline_start_time
    var position_ratio = time_elapsed / (MAX_TIMELINE_DURATION * 60)
    position_ratio = position_ratio * timeline_zoom
    
    var indicator_x = timeline_start_x + position_ratio * timeline_width
    
    # Draw current time indicator
    canvas.draw_line(
        Vector2(indicator_x, timeline_y - size.y * 0.4),
        Vector2(indicator_x, timeline_y + size.y * 0.4),
        Color(0.2, 0.8, 1.0, 0.8),
        2.0
    )
    
    # Draw indicator head
    canvas.draw_circle(
        Vector2(indicator_x, timeline_y),
        10.0,
        Color(0.2, 0.8, 1.0, 1.0)
    )

func _draw_message_nodes(size):
    var timeline_width = size.x * 0.9
    var timeline_start_x = size.x * 0.05
    var timeline_y = size.y * 0.5
    
    # Draw each message node
    for node in message_nodes:
        var message = messages[node.id]
        
        # Calculate position
        var time_elapsed = message.creation_time - timeline_start_time
        var position_ratio = time_elapsed / (MAX_TIMELINE_DURATION * 60)
        position_ratio = position_ratio * timeline_zoom
        
        var node_x = timeline_start_x + position_ratio * timeline_width
        var node_y = timeline_y
        
        # Calculate node size based on energy
        var lifecycle_data = LIFECYCLE_STAGES[message.lifecycle_stage]
        var node_size = 5.0 + lifecycle_data.energy * 15.0
        
        # Draw node
        canvas.draw_circle(
            Vector2(node_x, node_y),
            node_size,
            lifecycle_data.color
        )
        
        # Draw connection to app
        var app_id = message.app_id
        if app_id in active_apps:
            var app_data = CLAUDE_APPS[app_id]
            var app_y = timeline_y - size.y * 0.3 + app_data.priority * 30
            
            canvas.draw_line(
                Vector2(node_x, node_y),
                Vector2(node_x, app_y),
                app_data.color.darkened(0.3),
                1.0
            )
            
            # Draw app icon
            canvas.draw_circle(
                Vector2(node_x, app_y),
                8.0,
                app_data.color
            )
        }

func _draw_app_connections(size):
    var timeline_width = size.x * 0.9
    var timeline_start_x = size.x * 0.05
    var timeline_y = size.y * 0.2
    
    # Draw each app connection
    var x_offset = 0
    for app_id in active_apps.keys():
        var app_data = CLAUDE_APPS[app_id]
        var app_x = timeline_start_x + x_offset
        var app_y = timeline_y + app_data.priority * 30
        
        # Draw app node
        canvas.draw_circle(
            Vector2(app_x, app_y),
            15.0,
            app_data.color
        )
        
        # Draw connection to timeline
        canvas.draw_line(
            Vector2(app_x, app_y),
            Vector2(app_x, timeline_y + size.y * 0.3),
            app_data.color.darkened(0.3),
            2.0
        )
        
        x_offset += 60
    }

func add_message(content, app_id, lifecycle_stage = "SEED", hatching_schedule = null):
    # Generate message ID
    var message_id = _generate_message_id()
    
    # Set default hatching schedule if not provided
    if not hatching_schedule:
        hatching_schedule = _generate_default_hatching_schedule()
    
    # Create message object
    var message = {
        "id": message_id,
        "content": content,
        "app_id": app_id,
        "creation_time": timeline_current_time,
        "last_hatched_time": timeline_current_time,
        "lifecycle_stage": lifecycle_stage,
        "hatching_schedule": hatching_schedule,
        "connected_drives": connected_drives.duplicate(),
        "version": 1
    }
    
    # Store message
    messages[message_id] = message
    
    # Create message node for visualization
    var lifecycle_data = LIFECYCLE_STAGES[lifecycle_stage]
    var node = {
        "id": message_id,
        "position": Vector2(0, 0),  # Will be calculated during drawing
        "color": lifecycle_data.color,
        "energy": lifecycle_data.energy,
        "frequency": lifecycle_data.frequency
    }
    
    message_nodes.append(node)
    
    # Store in Akashic system
    if akashic_bridge and akashic_bridge.has_method("create_record"):
        akashic_bridge.create_record(message_id, JSON.stringify(message))
    
    # Store in connected drives
    if drive_connector and drive_connector.has_method("store_data"):
        for drive_id in connected_drives:
            drive_connector.store_data(drive_id, message_id, JSON.stringify(message))
    
    # Store in Docker system for Claude instances
    if docker_connector and docker_connector.has_method("store_memory"):
        docker_connector.store_memory(message_id, JSON.stringify(message))
    
    # Emit message added signal
    emit_signal("message_added", message_id)
    
    return message_id

func update_message(message_id, content = null, lifecycle_stage = null):
    if not message_id in messages:
        print("Message not found: " + message_id)
        return false
    
    var message = messages[message_id]
    var updated = false
    
    # Update content if provided
    if content != null:
        message.content = content
        updated = true
    
    # Update lifecycle stage if provided
    if lifecycle_stage != null and lifecycle_stage in LIFECYCLE_STAGES:
        message.lifecycle_stage = lifecycle_stage
        message.last_hatched_time = timeline_current_time
        
        # Update message visualization
        _update_message_visualization(message_id)
        
        updated = true
    
    if updated:
        # Increment version
        message.version += 1
        
        # Propagate update to connected systems
        _propagate_message_update(message_id)
        
        return true
    
    return false

func accelerate_hatching(message_id, factor = 2.0):
    if not message_id in messages:
        print("Message not found: " + message_id)
        return false
    
    var message = messages[message_id]
    
    # Accelerate remaining hatching stages
    var current_stage_index = _get_lifecycle_stage_index(message.lifecycle_stage)
    
    for i in range(current_stage_index, message.hatching_schedule.size()):
        message.hatching_schedule[i] = message.hatching_schedule[i] / factor
    
    # Propagate update to connected systems
    _propagate_message_update(message_id)
    
    return true

func connect_to_drive(drive_id):
    if not drive_id in connected_drives:
        connected_drives.append(drive_id)
        print("Connected to drive: " + drive_id)
        
        # Connect Docker system to drive if available
        if docker_connector and docker_connector.has_method("connect_to_drive"):
            docker_connector.connect_to_drive(drive_id)
        
        return true
    else:
        print("Already connected to drive: " + drive_id)
        return false

func disconnect_from_drive(drive_id):
    if drive_id in connected_drives:
        connected_drives.erase(drive_id)
        print("Disconnected from drive: " + drive_id)
        
        # Disconnect Docker system from drive if available
        if docker_connector and docker_connector.has_method("disconnect_from_drive"):
            docker_connector.disconnect_from_drive(drive_id)
        
        return true
    else:
        print("Not connected to drive: " + drive_id)
        return false

func get_connected_drives():
    return connected_drives

func connect_claude_app(app_id):
    if app_id in CLAUDE_APPS and not app_id in active_apps:
        active_apps[app_id] = {
            "connection_time": timeline_current_time,
            "messages": []
        }
        
        print("Connected Claude app: " + app_id)
        emit_signal("app_connected", app_id)
        
        return true
    else:
        print("Invalid Claude app ID or already connected: " + app_id)
        return false

func disconnect_claude_app(app_id):
    if app_id in active_apps:
        active_apps.erase(app_id)
        
        print("Disconnected Claude app: " + app_id)
        emit_signal("app_disconnected", app_id)
        
        return true
    else:
        print("Claude app not connected: " + app_id)
        return false

func get_active_apps():
    return active_apps.keys()

func get_message(message_id):
    if message_id in messages:
        return messages[message_id]
    
    # Try to load from akashic system
    if akashic_bridge and akashic_bridge.has_method("read_record"):
        var record = akashic_bridge.read_record(message_id)
        if record:
            var message = JSON.parse_string(record)
            messages[message_id] = message
            return message
    
    # Try to load from connected drives
    if drive_connector and drive_connector.has_method("get_data"):
        for drive_id in connected_drives:
            var data = drive_connector.get_data(drive_id, message_id)
            if data:
                var message = JSON.parse_string(data)
                messages[message_id] = message
                return message
    
    return null

func list_messages(filter_stage = null, filter_app = null):
    var result = []
    
    for message_id in messages.keys():
        var message = messages[message_id]
        
        # Apply filters if provided
        if filter_stage != null and message.lifecycle_stage != filter_stage:
            continue
        
        if filter_app != null and message.app_id != filter_app:
            continue
        
        result.append(message_id)
    }
    
    return result

func set_timeline_zoom(zoom):
    timeline_zoom = clamp(zoom, 0.1, 10.0)
    return timeline_zoom

func set_timeline_view_range(range_minutes):
    timeline_view_range = clamp(range_minutes, 60, MAX_TIMELINE_DURATION)
    return timeline_view_range

func _generate_message_id():
    return "msg_" + str(timeline_current_time) + "_" + str(randi() % 10000)

func _generate_default_hatching_schedule():
    var schedule = []
    
    # Start with quick germination
    schedule.append(33)  # SEED to GERMINATING
    
    # Middle stages with moderate times
    schedule.append(89)  # GERMINATING to SPROUTING
    schedule.append(99)  # SPROUTING to GROWING
    schedule.append(333)  # GROWING to BLOOMING
    
    # Later stages with longer times
    schedule.append(389)  # BLOOMING to FRUITING
    schedule.append(555)  # FRUITING to SEEDING
    schedule.append(777)  # SEEDING to DORMANT
    
    return schedule

func _add_claude_instance(app_id):
    # Create Claude instance tracking object
    var instance = {
        "app_id": app_id,
        "creation_time": timeline_current_time,
        "status": "DISCONNECTED",
        "messages": []
    }
    
    claude_instances.append(instance)

func get_visualization_canvas():
    return canvas

# Terminal command interface for the connector
func process_command(command, args):
    match command:
        "add_message":
            if args.size() >= 2:
                var content = args[0]
                var app_id = args[1]
                var stage = "SEED"
                
                if args.size() >= 3:
                    stage = args[2]
                
                return add_message(content, app_id, stage)
            else:
                return "Insufficient arguments for add_message"
        
        "update_message":
            if args.size() >= 2:
                var message_id = args[0]
                var content = args[1]
                var stage = null
                
                if args.size() >= 3:
                    stage = args[2]
                
                return update_message(message_id, content, stage)
            else:
                return "Insufficient arguments for update_message"
        
        "accelerate":
            if args.size() >= 1:
                var message_id = args[0]
                var factor = 2.0
                
                if args.size() >= 2 and args[1].is_valid_float():
                    factor = float(args[1])
                
                return accelerate_hatching(message_id, factor)
            else:
                return "Insufficient arguments for accelerate"
        
        "connect_drive":
            if args.size() >= 1:
                return connect_to_drive(args[0])
            else:
                return "Drive ID not provided"
        
        "disconnect_drive":
            if args.size() >= 1:
                return disconnect_from_drive(args[0])
            else:
                return "Drive ID not provided"
        
        "connect_app":
            if args.size() >= 1:
                return connect_claude_app(args[0])
            else:
                return "App ID not provided"
        
        "disconnect_app":
            if args.size() >= 1:
                return disconnect_claude_app(args[0])
            else:
                return "App ID not provided"
        
        "zoom":
            if args.size() >= 1 and args[0].is_valid_float():
                return set_timeline_zoom(float(args[0]))
            else:
                return "Invalid zoom factor"
        
        "list_messages":
            var filter_stage = null
            var filter_app = null
            
            if args.size() >= 1:
                filter_stage = args[0]
            
            if args.size() >= 2:
                filter_app = args[1]
            
            return list_messages(filter_stage, filter_app)
        
        "get_message":
            if args.size() >= 1:
                return get_message(args[0])
            else:
                return "Message ID not provided"
        
        "list_apps":
            return get_active_apps()
        
        "list_drives":
            return get_connected_drives()
        
        _:
            return "Unknown Message Timeline command: " + command