extends Node

class_name TimeTrackerLauncher

# ----- COMPONENT REFERENCES -----
var usage_time_tracker: UsageTimeTracker
var visual_indicator_system: VisualIndicatorSystem
var time_tracking_ui: TimeTrackingUI
var turn_system: Node = null

# ----- CONFIGURATION -----
@export_category("Tracker Settings")
@export var auto_launch_on_ready: bool = true
@export var hourly_limit: float = 1.0
@export var initial_visual_mode: int = 2  # Detailed by default

# ----- SYSTEM PATHS -----
var usage_tracker_path: String = "res://usage_time_tracker.gd"
var visual_system_path: String = "res://visual_indicator_system.gd"
var ui_path: String = "res://time_tracking_ui.tscn"

# ----- INITIALIZATION -----
func _ready():
    if auto_launch_on_ready:
        launch_time_tracking_system()

# ----- SYSTEM LAUNCH -----
func launch_time_tracking_system() -> bool:
    print("Launching time tracking system...")
    
    # Create usage time tracker
    usage_time_tracker = UsageTimeTracker.new()
    usage_time_tracker.name = "UsageTimeTracker"
    usage_time_tracker.hourly_limit = hourly_limit
    add_child(usage_time_tracker)
    
    # Create visual indicator system
    visual_indicator_system = VisualIndicatorSystem.new()
    visual_indicator_system.name = "VisualIndicatorSystem"
    visual_indicator_system.current_mode = initial_visual_mode
    add_child(visual_indicator_system)
    
    # Find turn system if it exists
    _find_turn_system()
    
    # Create UI
    var ui_scene = load(ui_path)
    if ui_scene:
        time_tracking_ui = ui_scene.instantiate()
        add_child(time_tracking_ui)
    else:
        push_error("Failed to load UI scene")
        return false
    
    # Add to groups for easy finding
    usage_time_tracker.add_to_group("time_trackers")
    visual_indicator_system.add_to_group("visual_indicators")
    
    print("Time tracking system launched successfully")
    return true

func _find_turn_system():
    # Try to find an existing turn system in the scene
    var potential_systems = get_tree().get_nodes_in_group("turn_systems")
    if potential_systems.size() > 0:
        turn_system = potential_systems[0]
        print("Found turn system: " + turn_system.name)
    else:
        # Find using class name
        var root = get_tree().root
        turn_system = _find_node_by_class(root, "TurnSystem")
        if not turn_system:
            turn_system = _find_node_by_class(root, "TurnCycleController")
            
        if turn_system:
            print("Found turn system by class: " + turn_system.name)
            
            # Add to turn systems group for easy finding
            turn_system.add_to_group("turn_systems")

func _find_node_by_class(node, class_name):
    if node.get_class() == class_name:
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name)
        if found:
            return found
    
    return null

# ----- PUBLIC API -----
func cycle_visual_mode() -> int:
    if visual_indicator_system:
        return visual_indicator_system.cycle_mode()
    return -1

func set_hourly_limit(hours: float) -> bool:
    if usage_time_tracker:
        hourly_limit = hours
        return usage_time_tracker.set_hourly_limit(hours)
    return false

func get_usage_summary() -> Dictionary:
    if usage_time_tracker:
        return usage_time_tracker.get_usage_summary()
    return {}

func toggle_tracking() -> bool:
    if usage_time_tracker:
        return usage_time_tracker.toggle_tracking()
    return false

func toggle_ui_compact_mode() -> bool:
    if time_tracking_ui:
        return time_tracking_ui.toggle_compact_mode()
    return false

func toggle_ui_auto_hide() -> bool:
    if time_tracking_ui:
        return time_tracking_ui.toggle_auto_hide()
    return false