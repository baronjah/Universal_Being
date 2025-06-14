extends Node
class_name WishMakerMachine

signal wish_processed(wish_data: Dictionary)
signal connection_status_changed(status: Dictionary)
signal auto_accept_updated(settings: Dictionary)

# Version control
const VERSION = "3.33"
const API_VERSION = "1.0"
const GODOT_MIN_VERSION = "4.0"

# Center date configuration
var center_date: Dictionary = {
    "day": 14,
    "month": 5,
    "trajectory_offset": Vector2(-1, -1),
    "is_active": true
}

# API connections
var api_connections: Dictionary = {
    "claude": {
        "enabled": true,
        "version": "3.7",
        "status": "connected"
    },
    "gpt": {
        "enabled": true,
        "version": "4",
        "status": "connected"
    },
    "godot": {
        "enabled": true,
        "version": "4.4",
        "status": "connected"
    }
}

# Auto-accept settings
var auto_accept_settings: Dictionary = {
    "enabled": true,
    "max_version": "3.33",
    "max_wishes_per_day": 12,
    "current_count": 0,
    "last_reset": 0
}

# Wish storage
var wishes: Array = []
var pending_wishes: Array = []
var rejected_wishes: Array = []

# Debug terminal
var debug_terminal: Node = null
var luno_manager: Node = null
var display_manager: Node = null

func _ready():
    # Initialize the system
    print("🌠 WishMaker Machine v%s initializing..." % VERSION)
    
    # Connect to required systems
    _connect_to_systems()
    
    # Reset wish counter if needed
    _check_date_reset()
    
    # Center the trajectory based on current date
    _center_trajectory()

func _connect_to_systems():
    # Connect to LUNO cycle system
    luno_manager = get_node_or_null("/root/LunoCycleManager")
    if luno_manager:
        print("✓ Connected to LUNO Cycle Manager")
        luno_manager.register_participant("WishMaker", Callable(self, "_on_luno_tick"))
    
    # Connect to Terminal Display Manager
    display_manager = get_node_or_null("/root/TerminalDisplayManager")
    if display_manager:
        print("✓ Connected to Terminal Display Manager")
    
    # Initialize debug terminal
    _initialize_debug_terminal()

func _initialize_debug_terminal():
    # Create debug terminal
    debug_terminal = Node.new()
    debug_terminal.set_name("WishMakerDebugTerminal")
    add_child(debug_terminal)
    
    print("🖥️ Debug terminal initialized")
    
    # Log initial status
    debug_log("WishMaker Machine v%s started" % VERSION)
    debug_log("Trajectory centered on day %d of month %d" % [center_date.day, center_date.month])
    debug_log("Auto-accept enabled: %s (max v%s)" % [auto_accept_settings.enabled, auto_accept_settings.max_version])

func _center_trajectory():
    var current_date = Time.get_date_dict_from_system()
    
    # Check if we're on the center date
    if current_date.day == center_date.day:
        center_date.is_active = true
        debug_log("🎯 Today is day %d! Centering trajectory" % center_date.day)
        
        # Apply special trajectory settings
        var trajectory = center_date.trajectory_offset
        debug_log("📊 Trajectory offset: (%d, %d)" % [trajectory.x, trajectory.y])
        
        # Notify display manager if available
        if display_manager:
            display_manager.set_fractal_offset(trajectory)
    else:
        center_date.is_active = false

func _check_date_reset():
    var current_time = OS.get_unix_time()
    var current_date = Time.get_date_dict_from_system()
    
    # Get the timestamp from the beginning of the current day
    var day_start = Time.get_unix_time_from_datetime_dict({
        "year": current_date.year,
        "month": current_date.month,
        "day": current_date.day,
        "hour": 0,
        "minute": 0,
        "second": 0
    })
    
    # Reset counter if we're on a new day
    if auto_accept_settings.last_reset < day_start:
        auto_accept_settings.current_count = 0
        auto_accept_settings.last_reset = current_time
        debug_log("🔄 Wish counter reset for new day")

func make_wish(wish_text: String, parameters: Dictionary = {}) -> Dictionary:
    # Create wish data structure
    var wish_id = "WISH_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    var current_date = Time.get_date_dict_from_system()
    
    var wish_data = {
        "id": wish_id,
        "text": wish_text,
        "parameters": parameters,
        "timestamp": OS.get_unix_time(),
        "date": current_date,
        "status": "pending",
        "auto_processed": false,
        "result": null
    }
    
    # Log the wish
    debug_log("✨ New wish: \"%s\"" % wish_text)
    
    # Check if we should auto-accept
    if can_auto_accept():
        wish_data.status = "accepted"
        wish_data.auto_processed = true
        auto_accept_settings.current_count += 1
        
        debug_log("✅ Wish auto-accepted (#%d/%d today)" % [
            auto_accept_settings.current_count,
            auto_accept_settings.max_wishes_per_day
        ])
        
        # Process the wish
        process_wish(wish_data)
    else:
        # Add to pending wishes
        pending_wishes.append(wish_data)
        debug_log("⏳ Wish pending approval")
    
    # Emit signal
    emit_signal("wish_processed", wish_data)
    
    return wish_data

func can_auto_accept() -> bool:
    # Check if auto-accept is enabled
    if not auto_accept_settings.enabled:
        return false
    
    # Check if we've reached the daily limit
    if auto_accept_settings.current_count >= auto_accept_settings.max_wishes_per_day:
        return false
    
    return true

func process_wish(wish_data: Dictionary):
    # Add to wishes array
    wishes.append(wish_data)
    
    # Remove from pending if needed
    if wish_data.status == "pending":
        var index = pending_wishes.find(wish_data)
        if index >= 0:
            pending_wishes.remove_at(index)
    
    # Process the wish based on its content
    var result = _interpret_wish(wish_data.text, wish_data.parameters)
    
    # Update wish data with result
    wish_data.result = result
    wish_data.status = "processed"
    
    debug_log("🔮 Wish processed: %s" % wish_data.id)
    
    # Emit signal again with updated data
    emit_signal("wish_processed", wish_data)
    
    return result

func _interpret_wish(wish_text: String, parameters: Dictionary):
    # This would contain the actual wish interpretation logic
    # For now, we'll just return a simple simulation
    
    debug_log("🧠 Interpreting wish: \"%s\"" % wish_text)
    
    # Check for keywords to determine the type of wish
    var result = {
        "success": true,
        "type": "unknown",
        "message": "Wish granted",
        "data": null
    }
    
    # Simplistic keyword detection
    if "connect" in wish_text or "api" in wish_text:
        result.type = "connection"
        result.message = "API connection established"
        result.data = api_connections
    elif "godot" in wish_text:
        result.type = "godot"
        result.message = "Godot integration activated"
    elif "terminal" in wish_text or "debug" in wish_text:
        result.type = "terminal"
        result.message = "Debug terminal configured"
    elif "trajectory" in wish_text or "center" in wish_text:
        result.type = "trajectory"
        result.message = "Trajectory centered"
        result.data = center_date
    else:
        result.type = "generic"
        result.message = "Generic wish processed"
    
    return result

func accept_pending_wish(wish_id: String) -> bool:
    # Find the wish in pending list
    for i in range(pending_wishes.size()):
        if pending_wishes[i].id == wish_id:
            var wish_data = pending_wishes[i]
            wish_data.status = "accepted"
            
            debug_log("✅ Manually accepted wish: %s" % wish_id)
            
            # Process the wish
            process_wish(wish_data)
            return true
    
    debug_log("❌ Could not find pending wish: %s" % wish_id)
    return false

func reject_pending_wish(wish_id: String) -> bool:
    # Find the wish in pending list
    for i in range(pending_wishes.size()):
        if pending_wishes[i].id == wish_id:
            var wish_data = pending_wishes[i]
            wish_data.status = "rejected"
            
            # Move to rejected list
            rejected_wishes.append(wish_data)
            pending_wishes.remove_at(i)
            
            debug_log("❌ Rejected wish: %s" % wish_id)
            
            # Emit signal
            emit_signal("wish_processed", wish_data)
            return true
    
    debug_log("❌ Could not find pending wish: %s" % wish_id)
    return false

func set_auto_accept(enabled: bool, max_version: String = "", max_per_day: int = -1):
    auto_accept_settings.enabled = enabled
    
    if max_version != "":
        auto_accept_settings.max_version = max_version
    
    if max_per_day > 0:
        auto_accept_settings.max_wishes_per_day = max_per_day
    
    debug_log("🔄 Auto-accept settings updated: enabled=%s, max_version=%s, max_per_day=%d" % [
        enabled, 
        auto_accept_settings.max_version,
        auto_accept_settings.max_wishes_per_day
    ])
    
    emit_signal("auto_accept_updated", auto_accept_settings)

func debug_log(message: String):
    # Log to console
    print("[WishMaker] " + message)
    
    # Here you would also log to the debug terminal UI
    # This is a simplified version

func _on_luno_tick(turn: int, phase_name: String):
    # Special case for evolution
    if turn == 0 and phase_name == "Evolution":
        debug_log("✨ WishMaker evolving with system")
        return
    
    # Process based on the current phase
    match phase_name:
        "Genesis":
            # Generate new wish templates in Genesis phase
            if center_date.is_active:
                debug_log("🌱 Genesis phase on center date - enhancing wish capabilities")
        
        "Manifestation":
            # Manifestation phase aligns with wish making
            debug_log("✨ Manifestation phase - wish power enhanced")
            
            # Temporarily increase auto-accept limit
            var previous_limit = auto_accept_settings.max_wishes_per_day
            auto_accept_settings.max_wishes_per_day += 2
            debug_log("⬆️ Temporary wish limit increase: %d → %d" % [previous_limit, auto_accept_settings.max_wishes_per_day])

# API methods for Godot addon integration
func connect_to_godot_debug(port: int = 6007) -> bool:
    debug_log("🔌 Connecting to Godot debug on port %d" % port)
    # This would establish actual debug connection
    api_connections.godot.status = "debug_connected"
    return true

func disconnect_from_godot_debug() -> bool:
    debug_log("🔌 Disconnecting from Godot debug")
    api_connections.godot.status = "connected"
    return true

func get_pending_wishes() -> Array:
    return pending_wishes

func get_processed_wishes() -> Array:
    return wishes

func get_connection_status() -> Dictionary:
    return api_connections

func get_auto_accept_settings() -> Dictionary:
    return auto_accept_settings

func get_center_date_config() -> Dictionary:
    return center_date

# Example usage:
# var wish_maker = WishMakerMachine.new()
# add_child(wish_maker)
# var wish = wish_maker.make_wish("I wish for a Godot debug terminal")