extends Node
class_name MemoryTrajectoryTracker

"""
Memory Trajectory Tracker
------------------------
Manages daily memory trajectories with start, center, and end mission points
Records and visualizes memory paths across dimensions
"""

# Node references
var _memory_system = null
var _connection_system = null
var _visualizer = null
var _main_system = null  # Reference to main.gd controller

# Trajectory Constants
const TRAJECTORY_POINTS = {
    "START": 0,    # Beginning point (most important)
    "CENTER": 1,   # Middle checkpoint (second priority)
    "END": 2       # Final destination (important)
}

const TRAJECTORY_MARKERS = {
    "START": "►",   # Start marker (triangle pointing right)
    "CENTER": "◉",  # Center marker (bullseye)
    "END": "◀"      # End marker (triangle pointing left)
}

# Data Structures
class TrajectoryPoint:
    var id: String
    var type: int  # TRAJECTORY_POINTS
    var memory_id: String
    var dimension: int
    var timestamp: int
    var content: String
    var metadata = {}
    
    func _init(p_id: String, p_type: int, p_memory_id: String = "", p_content: String = ""):
        id = p_id
        type = p_type
        memory_id = p_memory_id
        content = p_content
        timestamp = OS.get_unix_time()
    
    func set_dimension(dim: int):
        dimension = dim
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "type": type,
            "memory_id": memory_id,
            "dimension": dimension,
            "timestamp": timestamp,
            "content": content,
            "metadata": metadata
        }
    
    static func from_dict(data: Dictionary) -> TrajectoryPoint:
        var point = TrajectoryPoint.new(
            data.id,
            data.type,
            data.memory_id,
            data.content
        )
        point.dimension = data.dimension
        point.timestamp = data.timestamp
        point.metadata = data.metadata.duplicate()
        return point

class DailyTrajectory:
    var id: String
    var date: String
    var points = {}  # TRAJECTORY_POINTS -> TrajectoryPoint
    var connected_memories = []
    var notes: String = ""
    var created_at: int
    var updated_at: int
    var completed: bool = false
    
    func _init(p_id: String, p_date: String):
        id = p_id
        date = p_date
        created_at = OS.get_unix_time()
        updated_at = created_at
    
    func add_point(point: TrajectoryPoint) -> bool:
        if points.has(point.type):
            return false
        
        points[point.type] = point
        updated_at = OS.get_unix_time()
        return true
    
    func update_point(type: int, memory_id: String, content: String) -> bool:
        if not points.has(type):
            return false
        
        points[type].memory_id = memory_id
        points[type].content = content
        points[type].timestamp = OS.get_unix_time()
        updated_at = OS.get_unix_time()
        return true
    
    func is_complete() -> bool:
        return points.has(TRAJECTORY_POINTS.START) and points.has(TRAJECTORY_POINTS.END)
    
    func mark_completed():
        completed = true
        updated_at = OS.get_unix_time()
    
    func add_connected_memory(memory_id: String):
        if not connected_memories.has(memory_id):
            connected_memories.append(memory_id)
            updated_at = OS.get_unix_time()
    
    func to_dict() -> Dictionary:
        var points_dict = {}
        for key in points:
            points_dict[key] = points[key].to_dict()
            
        return {
            "id": id,
            "date": date,
            "points": points_dict,
            "connected_memories": connected_memories,
            "notes": notes,
            "created_at": created_at,
            "updated_at": updated_at,
            "completed": completed
        }
    
    static func from_dict(data: Dictionary) -> DailyTrajectory:
        var trajectory = DailyTrajectory.new(data.id, data.date)
        
        for key in data.points:
            var point_data = data.points[key]
            trajectory.points[int(key)] = TrajectoryPoint.from_dict(point_data)
        
        trajectory.connected_memories = data.connected_memories.duplicate()
        trajectory.notes = data.notes
        trajectory.created_at = data.created_at
        trajectory.updated_at = data.updated_at
        trajectory.completed = data.completed
        
        return trajectory

# System Variables
var _trajectories = {}  # date string -> DailyTrajectory
var _active_trajectory = null
var _current_date = ""
var _auto_save_timer = null
var _dimension_names = []

# Signals
signal trajectory_created(date)
signal trajectory_updated(trajectory_id)
signal trajectory_completed(trajectory_id)
signal point_added(trajectory_id, point_type)
signal point_updated(trajectory_id, point_type)

# System Initialization
func _ready():
    # Create auto-save timer
    _auto_save_timer = Timer.new()
    _auto_save_timer.wait_time = 300  # 5 minutes
    _auto_save_timer.autostart = true
    _auto_save_timer.one_shot = false
    _auto_save_timer.connect("timeout", self, "_on_auto_save_timer_timeout")
    add_child(_auto_save_timer)
    
    # Initialize current date
    _update_current_date()

func initialize(memory_system = null, connection_system = null, visualizer = null, main_system = null):
    _memory_system = memory_system
    _connection_system = connection_system
    _visualizer = visualizer
    _main_system = main_system
    
    # Get dimension names from main system if available
    if _main_system and _main_system.has_method("get_dimension_name"):
        _dimension_names = []
        for i in range(1, 13):
            _dimension_names.append(_main_system.get_dimension_name(i))
    else:
        # Fallback dimension names
        _dimension_names = [
            "GENESIS", "DUALITY", "EXPRESSION", "STABILITY",
            "TRANSFORMATION", "BALANCE", "ILLUMINATION", "REFLECTION",
            "HARMONY", "MANIFESTATION", "INTEGRATION", "TRANSCENDENCE"
        ]
    
    # Load existing trajectories
    load_trajectories()
    
    # Create today's trajectory if it doesn't exist
    ensure_today_trajectory()
    
    return true

# Trajectory Management
func create_trajectory(date: String = "") -> String:
    if date.empty():
        date = _current_date
    
    # Check if trajectory already exists
    if _trajectories.has(date):
        return _trajectories[date].id
    
    # Create new trajectory
    var trajectory_id = "traj_" + date + "_" + str(randi() % 1000).pad_zeros(3)
    var trajectory = DailyTrajectory.new(trajectory_id, date)
    
    # Add default points (empty)
    for point_type in TRAJECTORY_POINTS.values():
        var point_id = "point_" + str(point_type) + "_" + date
        var point = TrajectoryPoint.new(point_id, point_type)
        trajectory.add_point(point)
    
    # Store trajectory
    _trajectories[date] = trajectory
    
    # Save to file
    save_trajectory(trajectory)
    
    emit_signal("trajectory_created", date)
    
    return trajectory_id

func get_trajectory(date: String = "") -> DailyTrajectory:
    if date.empty():
        date = _current_date
    
    if _trajectories.has(date):
        return _trajectories[date]
    
    return null

func ensure_today_trajectory() -> String:
    _update_current_date()
    
    if not _trajectories.has(_current_date):
        return create_trajectory(_current_date)
    
    return _trajectories[_current_date].id

func set_active_trajectory(date: String = "") -> bool:
    if date.empty():
        date = _current_date
    
    if not _trajectories.has(date):
        return false
    
    _active_trajectory = _trajectories[date]
    return true

func get_active_trajectory() -> DailyTrajectory:
    if not _active_trajectory:
        ensure_today_trajectory()
        set_active_trajectory()
    
    return _active_trajectory

# Point Management
func set_trajectory_point(point_type: int, memory_id: String, content: String, date: String = "") -> bool:
    if date.empty():
        date = _current_date
    
    if not _trajectories.has(date):
        var trajectory_id = create_trajectory(date)
    
    var trajectory = _trajectories[date]
    
    # Get the memory's dimension if available
    var dimension = 1
    if _memory_system and memory_id:
        var memory = _memory_system.get_memory(memory_id)
        if memory:
            dimension = memory.dimension
    
    # Check if point exists
    if trajectory.points.has(point_type):
        # Update existing point
        trajectory.update_point(point_type, memory_id, content)
        trajectory.points[point_type].set_dimension(dimension)
        
        emit_signal("point_updated", trajectory.id, point_type)
    else:
        # Create new point
        var point_id = "point_" + str(point_type) + "_" + date
        var point = TrajectoryPoint.new(point_id, point_type, memory_id, content)
        point.set_dimension(dimension)
        
        trajectory.add_point(point)
        
        emit_signal("point_added", trajectory.id, point_type)
    
    # Check if trajectory is now complete
    if trajectory.is_complete() and not trajectory.completed:
        trajectory.mark_completed()
        emit_signal("trajectory_completed", trajectory.id)
    
    # Save updated trajectory
    save_trajectory(trajectory)
    
    emit_signal("trajectory_updated", trajectory.id)
    
    return true

func get_trajectory_point(point_type: int, date: String = "") -> TrajectoryPoint:
    if date.empty():
        date = _current_date
    
    if not _trajectories.has(date):
        return null
    
    var trajectory = _trajectories[date]
    
    if trajectory.points.has(point_type):
        return trajectory.points[point_type]
    
    return null

func add_trajectory_note(note: String, date: String = "") -> bool:
    if date.empty():
        date = _current_date
    
    if not _trajectories.has(date):
        return false
    
    var trajectory = _trajectories[date]
    
    if note.empty():
        return false
    
    # Add note (append)
    if trajectory.notes.empty():
        trajectory.notes = note
    else:
        trajectory.notes += "\n" + note
    
    trajectory.updated_at = OS.get_unix_time()
    
    # Save updated trajectory
    save_trajectory(trajectory)
    
    emit_signal("trajectory_updated", trajectory.id)
    
    return true

func connect_memory_to_trajectory(memory_id: String, date: String = "") -> bool:
    if date.empty():
        date = _current_date
    
    if not _trajectories.has(date):
        return false
    
    var trajectory = _trajectories[date]
    
    trajectory.add_connected_memory(memory_id)
    
    # Save updated trajectory
    save_trajectory(trajectory)
    
    emit_signal("trajectory_updated", trajectory.id)
    
    return true

# File Operations
func save_trajectory(trajectory: DailyTrajectory) -> bool:
    var dir = Directory.new()
    var trajectories_dir = "user://trajectories"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(trajectories_dir):
        dir.make_dir_recursive(trajectories_dir)
    
    # Save as JSON
    var file = File.new()
    var file_path = trajectories_dir.plus_file(trajectory.id + ".json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open trajectory file for writing: " + str(err))
        return false
    
    file.store_string(JSON.print(trajectory.to_dict(), "  "))
    file.close()
    
    return true

func load_trajectories() -> bool:
    var dir = Directory.new()
    var trajectories_dir = "user://trajectories"
    
    if not dir.dir_exists(trajectories_dir):
        return false
    
    var err = dir.open(trajectories_dir)
    if err != OK:
        push_error("Failed to open trajectories directory: " + str(err))
        return false
    
    dir.list_dir_begin(true, true)
    var file_name = dir.get_next()
    
    while file_name != "":
        if file_name.ends_with(".json"):
            var file_path = trajectories_dir.plus_file(file_name)
            load_trajectory_from_file(file_path)
        file_name = dir.get_next()
    
    dir.list_dir_end()
    
    # Update current date
    _update_current_date()
    
    # Set active trajectory to today's
    if _trajectories.has(_current_date):
        _active_trajectory = _trajectories[_current_date]
    
    return true

func load_trajectory_from_file(file_path: String) -> bool:
    var file = File.new()
    var err = file.open(file_path, File.READ)
    
    if err != OK:
        push_error("Failed to open trajectory file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse trajectory JSON: " + str(parse_result.error))
        return false
    
    var trajectory_data = parse_result.result
    var trajectory = DailyTrajectory.from_dict(trajectory_data)
    
    # Store trajectory
    _trajectories[trajectory.date] = trajectory
    
    return true

func save_all_trajectories() -> int:
    var saved_count = 0
    
    for date in _trajectories:
        if save_trajectory(_trajectories[date]):
            saved_count += 1
    
    return saved_count

# Integration with Visualizer
func visualize_trajectory(date: String = "") -> bool:
    if not _visualizer:
        return false
    
    if date.empty():
        date = _current_date
    
    if not _trajectories.has(date):
        return false
    
    var trajectory = _trajectories[date]
    
    # Create a new layout for the trajectory
    var layout_id = _visualizer.create_layout("Trajectory " + date)
    
    if layout_id.empty():
        return false
    
    # Create root node for trajectory
    var root_id = _visualizer.create_split_node(layout_id, _visualizer.SPLIT_TYPES.VERTICAL)
    var layout = _visualizer.get_layout(layout_id)
    
    # Create nodes for points
    var points = [
        {"type": TRAJECTORY_POINTS.START, "name": "Start Point"},
        {"type": TRAJECTORY_POINTS.CENTER, "name": "Center Point"},
        {"type": TRAJECTORY_POINTS.END, "name": "End Point"}
    ]
    
    for point_data in points:
        var point_type = point_data.type
        if trajectory.points.has(point_type):
            var point = trajectory.points[point_type]
            var content = point.content
            
            if content.empty() and point.memory_id:
                # Try to get content from memory
                if _memory_system:
                    var memory = _memory_system.get_memory(point.memory_id)
                    if memory:
                        content = memory.content
            
            if content.empty():
                content = "Empty " + point_data.name
                
            # Create node for point
            var node_id = _visualizer.add_child_split(
                layout_id,
                root_id,
                _visualizer.SPLIT_TYPES.VERTICAL,
                content
            )
            
            if not node_id.empty():
                var node = _visualizer.find_node_by_id(layout.root_node, node_id)
                
                # Set marker
                var marker = TRAJECTORY_MARKERS.START
                if point_type == TRAJECTORY_POINTS.CENTER:
                    marker = TRAJECTORY_MARKERS.CENTER
                elif point_type == TRAJECTORY_POINTS.END:
                    marker = TRAJECTORY_MARKERS.END
                
                node.marker = marker
                
                # Set metadata
                node.metadata["trajectory_point"] = point_type
                node.metadata["memory_id"] = point.memory_id
                node.metadata["dimension"] = point.dimension
            
    # Set active layout and render
    _visualizer.set_active_layout(layout_id)
    _visualizer.render_layout()
    
    return true

# Utility Functions
func _update_current_date():
    var datetime = OS.get_datetime()
    _current_date = "%04d-%02d-%02d" % [datetime.year, datetime.month, datetime.day]

func _on_auto_save_timer_timeout():
    save_all_trajectories()

func get_trajectory_summary(date: String = "") -> String:
    if date.empty():
        date = _current_date
    
    if not _trajectories.has(date):
        return "No trajectory data for " + date
    
    var trajectory = _trajectories[date]
    var summary = "# Trajectory for " + date + " #\n\n"
    
    # Add point information
    for point_type in TRAJECTORY_POINTS.values():
        var type_name = ""
        var marker = ""
        
        if point_type == TRAJECTORY_POINTS.START:
            type_name = "Start Point"
            marker = TRAJECTORY_MARKERS.START
        elif point_type == TRAJECTORY_POINTS.CENTER:
            type_name = "Center Point"
            marker = TRAJECTORY_MARKERS.CENTER
        elif point_type == TRAJECTORY_POINTS.END:
            type_name = "End Point"
            marker = TRAJECTORY_MARKERS.END
        
        summary += "## " + marker + " " + type_name + "\n"
        
        if trajectory.points.has(point_type):
            var point = trajectory.points[point_type]
            
            # Get dimension name
            var dimension_name = "Unknown"
            if point.dimension >= 1 and point.dimension <= 12:
                dimension_name = _dimension_names[point.dimension - 1]
            
            summary += "Dimension: " + str(point.dimension) + " (" + dimension_name + ")\n"
            
            if point.memory_id:
                summary += "Memory: " + point.memory_id + "\n"
            
            if point.content:
                summary += "Content: " + point.content + "\n"
            else:
                summary += "Content: Not set\n"
        else:
            summary += "Not set\n"
        
        summary += "\n"
    
    # Add connected memories
    if trajectory.connected_memories.size() > 0:
        summary += "## Connected Memories\n"
        for memory_id in trajectory.connected_memories:
            var memory_content = memory_id
            
            # Try to get memory content
            if _memory_system:
                var memory = _memory_system.get_memory(memory_id)
                if memory:
                    memory_content = memory.content
                    if memory_content.length() > 50:
                        memory_content = memory_content.substr(0, 47) + "..."
            
            summary += "- " + memory_content + "\n"
        
        summary += "\n"
    
    # Add notes
    if not trajectory.notes.empty():
        summary += "## Notes\n"
        summary += trajectory.notes + "\n\n"
    
    # Add status
    summary += "Status: " + ("Completed" if trajectory.completed else "In Progress") + "\n"
    
    return summary

func create_trajectory_connection_graph(date: String = "") -> Dictionary:
    if date.empty():
        date = _current_date
    
    if not _trajectories.has(date):
        return {"error": "No trajectory found for date " + date}
    
    var trajectory = _trajectories[date]
    var graph = {
        "nodes": [],
        "links": []
    }
    
    # Add trajectory points as nodes
    for point_type in trajectory.points:
        var point = trajectory.points[point_type]
        if point.memory_id.empty() and point.content.empty():
            continue
        
        var node_type = "start"
        if point_type == TRAJECTORY_POINTS.CENTER:
            node_type = "center"
        elif point_type == TRAJECTORY_POINTS.END:
            node_type = "end"
        
        graph.nodes.append({
            "id": point.id,
            "type": node_type,
            "content": point.content,
            "memory_id": point.memory_id,
            "dimension": point.dimension
        })
    
    # Add connected memories as nodes
    for memory_id in trajectory.connected_memories:
        if _memory_system:
            var memory = _memory_system.get_memory(memory_id)
            if memory:
                graph.nodes.append({
                    "id": memory_id,
                    "type": "memory",
                    "content": memory.content,
                    "memory_id": memory_id,
                    "dimension": memory.dimension
                })
    
    # Create links between trajectory points
    var point_ids = []
    for point_type in [TRAJECTORY_POINTS.START, TRAJECTORY_POINTS.CENTER, TRAJECTORY_POINTS.END]:
        if trajectory.points.has(point_type):
            var point = trajectory.points[point_type]
            if not point.memory_id.empty() or not point.content.empty():
                point_ids.append(point.id)
    
    # Create sequential links
    for i in range(point_ids.size() - 1):
        graph.links.append({
            "source": point_ids[i],
            "target": point_ids[i + 1],
            "type": "trajectory"
        })
    
    # Add links from points to connected memories
    for point_type in trajectory.points:
        var point = trajectory.points[point_type]
        if point.memory_id.empty():
            continue
        
        for memory_id in trajectory.connected_memories:
            if _connection_system and _memory_system:
                var connected = _connection_system.get_connections_for_memory(point.memory_id)
                for conn in connected:
                    if conn.source_id == point.memory_id and conn.target_id == memory_id:
                        graph.links.append({
                            "source": point.id,
                            "target": memory_id,
                            "type": conn.type
                        })
                    elif conn.target_id == point.memory_id and conn.source_id == memory_id:
                        graph.links.append({
                            "source": memory_id,
                            "target": point.id,
                            "type": conn.type
                        })
            else:
                # If no connection system, create default connections
                graph.links.append({
                    "source": point.id,
                    "target": memory_id,
                    "type": "default"
                })
    
    return graph

# Main integration for complete trajectory creation
func create_full_trajectory(start_content: String, center_content: String, end_content: String, date: String = "") -> String:
    if date.empty():
        date = _current_date
    
    # Ensure trajectory exists
    var trajectory_id = ensure_today_trajectory()
    
    # Create memories for each point
    var memory_ids = {
        TRAJECTORY_POINTS.START: "",
        TRAJECTORY_POINTS.CENTER: "",
        TRAJECTORY_POINTS.END: ""
    }
    
    if _memory_system:
        # Create with appropriate dimensions
        var dimensions = {
            TRAJECTORY_POINTS.START: 1,  # Genesis
            TRAJECTORY_POINTS.CENTER: 7, # Illumination
            TRAJECTORY_POINTS.END: 12    # Transcendence
        }
        
        # Get current dimension from main system if available
        if _main_system and _main_system.has("current_dimension"):
            dimensions[TRAJECTORY_POINTS.CENTER] = _main_system.current_dimension
        
        # Create memories
        for point_type in [TRAJECTORY_POINTS.START, TRAJECTORY_POINTS.CENTER, TRAJECTORY_POINTS.END]:
            var content = ""
            if point_type == TRAJECTORY_POINTS.START:
                content = start_content
            elif point_type == TRAJECTORY_POINTS.CENTER:
                content = center_content
            else:
                content = end_content
                
            if not content.empty():
                memory_ids[point_type] = _memory_system.create_memory(
                    content,
                    dimensions[point_type]
                )
    
    # Set trajectory points
    set_trajectory_point(TRAJECTORY_POINTS.START, memory_ids[TRAJECTORY_POINTS.START], start_content, date)
    set_trajectory_point(TRAJECTORY_POINTS.CENTER, memory_ids[TRAJECTORY_POINTS.CENTER], center_content, date)
    set_trajectory_point(TRAJECTORY_POINTS.END, memory_ids[TRAJECTORY_POINTS.END], end_content, date)
    
    # Connect memories if created
    if _connection_system:
        var point_ids = []
        for point_type in [TRAJECTORY_POINTS.START, TRAJECTORY_POINTS.CENTER, TRAJECTORY_POINTS.END]:
            if not memory_ids[point_type].empty():
                point_ids.append(memory_ids[point_type])
        
        # Create sequential connections
        for i in range(point_ids.size() - 1):
            _connection_system.connect_memories(
                point_ids[i],
                point_ids[i+1],
                _connection_system.CONNECTION_TYPES.SEQUENTIAL,
                "Trajectory connection " + date
            )
    
    # Visualize if possible
    if _visualizer:
        visualize_trajectory(date)
    
    return trajectory_id
    
# Example usage:
# var trajectory_tracker = MemoryTrajectoryTracker.new()
# add_child(trajectory_tracker)
# trajectory_tracker.initialize(memory_system, connection_system, visualizer, main_system)
# 
# # Create today's trajectory
# var trajectory_id = trajectory_tracker.create_full_trajectory(
#     "Starting mission for today: organize memory fragments",
#     "Integrate connection system with visualization",
#     "Complete memory recycling and trajectory documentation"
# )
# 
# # Visualize
# trajectory_tracker.visualize_trajectory()