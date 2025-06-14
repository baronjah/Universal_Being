extends Node
class_name HyperRefreshSystem

"""
Hyper Refresh System
-------------------
An advanced system for creating ultra-responsive, real-time feeling interactions
with extreme refresh capabilities and multi-dimensional data synchronization.

This system integrates with the data_sewer_bridge and story_data_manager to
provide lightning-fast data updates, visual feedback, and seamless browser integration.

Features:
- Ultra-high intensity refresh modes (8-100+ hash levels)
- Real-time data synchronization across multiple interfaces
- Advanced visual pulsing and transition effects
- Browser WebSocket integration for instant updates
- Adaptive refresh rate based on system performance
- Memory-optimized data transmission protocol
"""

# Signal declarations
signal hyper_refresh_triggered(intensity, target_elements)
signal reality_pulse_emitted(strength, affected_components)
signal sync_state_changed(old_state, new_state)
signal interface_updated(interface_id, update_type)
signal performance_threshold_reached(metric_type, value)

# Constants
const REFRESH_INTENSITY_LEVELS = {
    "NORMAL": 7,       # Standard maximum refresh (7 hashes)
    "HIGH": 15,        # High intensity (8-15 hashes)
    "ULTRA": 30,       # Ultra high intensity (16-30 hashes)
    "HYPER": 50,       # Hyper intensity (31-50 hashes)
    "REALITY": 100,    # Reality simulation (51-100 hashes)
    "TRANSCENDENT": -1 # Beyond reality (101+ hashes, no upper limit)
}

const SYNC_STATES = {
    "DISCONNECTED": 0,  # No synchronization
    "CONNECTED": 1,     # Basic connection established
    "SYNCING": 2,       # Actively synchronizing data
    "REAL_TIME": 3,     # Real-time data flow established
    "HYPER_SYNC": 4     # Advanced predictive sync engaged
}

const PULSE_PATTERNS = {
    "SINE": 0,          # Smooth sine wave pulsing
    "SQUARE": 1,        # Sharp on/off transitions
    "TRIANGLE": 2,      # Linear ramp up/down
    "EXPONENTIAL": 3,   # Accelerating pulse
    "CHAOTIC": 4,       # Unpredictable pattern
    "QUANTUM": 5        # State-dependent pattern
}

const INTERFACE_TYPES = {
    "CONSOLE": 0,        # Terminal/console interface
    "BROWSER": 1,        # Web browser interface
    "GODOT": 2,          # Godot visual interface
    "SYSTEM": 3,         # System-level interface
    "COMBINED": 4        # Multi-interface synchronization
}

# Configuration
var _config = {
    "default_refresh_intensity": REFRESH_INTENSITY_LEVELS.NORMAL,
    "enable_reality_pulses": true,
    "pulse_pattern": PULSE_PATTERNS.SINE,
    "pulse_frequency": 2.0,  # Hz
    "auto_intensity_scaling": true,
    "browser_websocket_url": "ws://localhost:8080/refresh",
    "performance_monitoring": true,
    "max_refresh_rate": 120.0,  # Hz
    "memory_optimization_level": 3,  # 1-5 scale
    "adaptive_sync": true,
    "interface_priority": INTERFACE_TYPES.CONSOLE,
    "enable_predictive_refresh": true,
    "debug_visuals": false
}

# Runtime variables
var _current_intensity = REFRESH_INTENSITY_LEVELS.NORMAL
var _current_sync_state = SYNC_STATES.DISCONNECTED
var _connected_interfaces = {}
var _pulse_timer = null
var _last_refresh_time = 0
var _refresh_history = []
var _active_pulse_pattern = PULSE_PATTERNS.SINE
var _performance_metrics = {
    "refresh_rate": 0.0,
    "response_time": 0.0,
    "memory_usage": 0.0,
    "cpu_usage": 0.0,
    "frame_time": 0.0
}
var _current_reality_pulse_strength = 0.0
var _data_sewer_bridge = null
var _story_data_manager = null
var _enabled = true
var _hash_count_buffer = []
var _websocket_client = null
var _predictive_data_cache = {}

# Class definitions
class RefreshEvent:
    var timestamp: int
    var intensity: int
    var target_elements: Array
    var duration: float
    var success: bool
    var response_time: float
    var metadata = {}
    
    func _init(p_intensity: int, p_targets: Array = []):
        timestamp = OS.get_unix_time()
        intensity = p_intensity
        target_elements = p_targets
        success = false
    
    func complete(p_response_time: float, p_success: bool):
        response_time = p_response_time
        success = p_success
        duration = OS.get_unix_time() - timestamp
    
    func to_dict() -> Dictionary:
        return {
            "timestamp": timestamp,
            "intensity": intensity,
            "target_elements": target_elements,
            "duration": duration,
            "success": success,
            "response_time": response_time,
            "metadata": metadata
        }

class Interface:
    var id: String
    var type: int
    var name: String
    var status: String = "disconnected"  # disconnected, connected, active
    var update_frequency: float = 1.0
    var last_update_time: int = 0
    var supports_real_time: bool = false
    var metadata = {}
    
    func _init(p_id: String, p_type: int, p_name: String):
        id = p_id
        type = p_type
        name = p_name
    
    func update() -> bool:
        last_update_time = OS.get_unix_time()
        return true
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "type": type,
            "name": name,
            "status": status,
            "update_frequency": update_frequency,
            "last_update_time": last_update_time,
            "supports_real_time": supports_real_time,
            "metadata": metadata
        }

class RealityPulse:
    var timestamp: int
    var strength: float
    var duration: float
    var affected_components: Array
    var pulse_pattern: int
    var frequency: float
    var metadata = {}
    
    func _init(p_strength: float, p_pattern: int, p_frequency: float, p_components: Array = []):
        timestamp = OS.get_unix_time()
        strength = p_strength
        pulse_pattern = p_pattern
        frequency = p_frequency
        affected_components = p_components
    
    func calculate_value(elapsed_time: float) -> float:
        var value = 0.0
        
        match pulse_pattern:
            PULSE_PATTERNS.SINE:
                value = 0.5 + 0.5 * sin(elapsed_time * frequency * 2.0 * PI)
            PULSE_PATTERNS.SQUARE:
                value = 1.0 if fmod(elapsed_time * frequency, 1.0) < 0.5 else 0.0
            PULSE_PATTERNS.TRIANGLE:
                var phase = fmod(elapsed_time * frequency, 1.0)
                value = 2.0 * phase if phase < 0.5 else 2.0 * (1.0 - phase)
            PULSE_PATTERNS.EXPONENTIAL:
                var phase = fmod(elapsed_time * frequency, 1.0)
                value = pow(phase, 2.0)
            PULSE_PATTERNS.CHAOTIC:
                value = 0.5 + 0.5 * sin(elapsed_time * frequency * 2.0 * PI) * sin(elapsed_time * frequency * 1.3 * PI)
            PULSE_PATTERNS.QUANTUM:
                # Quantum pattern depends on the current timestamp for randomness
                var quantum_seed = (OS.get_unix_time() % 100) / 100.0
                value = 0.5 + 0.5 * sin((elapsed_time + quantum_seed) * frequency * 2.0 * PI)
        
        return value * strength
    
    func to_dict() -> Dictionary:
        return {
            "timestamp": timestamp,
            "strength": strength,
            "duration": duration,
            "affected_components": affected_components,
            "pulse_pattern": pulse_pattern,
            "frequency": frequency,
            "metadata": metadata
        }

# Initialization
func _ready():
    _setup_pulse_timer()
    _initialize_interfaces()
    _initialize_websocket()
    
    # Debug message
    print("HyperRefreshSystem: Initialized with intensity level " + str(_current_intensity))

# Setup the pulse timer
func _setup_pulse_timer():
    _pulse_timer = Timer.new()
    _pulse_timer.wait_time = 1.0 / _config.pulse_frequency
    _pulse_timer.one_shot = false
    _pulse_timer.autostart = true
    _pulse_timer.connect("timeout", self, "_on_pulse_timer_timeout")
    add_child(_pulse_timer)

# Initialize default interfaces
func _initialize_interfaces():
    # Add console interface
    _add_interface(INTERFACE_TYPES.CONSOLE, "Main Console")
    
    # Add browser interface if enabled
    if _config.browser_websocket_url != "":
        _add_interface(INTERFACE_TYPES.BROWSER, "Web Browser")
    
    # Add Godot interface
    _add_interface(INTERFACE_TYPES.GODOT, "Godot Engine")

# Initialize WebSocket client for browser integration
func _initialize_websocket():
    if _connected_interfaces.has("interface_" + str(INTERFACE_TYPES.BROWSER)):
        _websocket_client = WebSocketClient.new()
        _websocket_client.connect("connection_established", self, "_on_websocket_connected")
        _websocket_client.connect("connection_error", self, "_on_websocket_error")
        _websocket_client.connect("connection_closed", self, "_on_websocket_closed")
        _websocket_client.connect("data_received", self, "_on_websocket_data_received")
        
        var err = _websocket_client.connect_to_url(_config.browser_websocket_url)
        if err != OK:
            push_error("HyperRefreshSystem: Failed to connect to WebSocket server")

# Process function for time-dependent functionality
func _process(delta):
    if not _enabled:
        return
    
    # Update performance metrics
    if _config.performance_monitoring:
        _update_performance_metrics(delta)
    
    # Process WebSocket connection
    if _websocket_client and _websocket_client.get_connection_status() != WebSocketClient.CONNECTION_DISCONNECTED:
        _websocket_client.poll()
    
    # Calculate current reality pulse value
    if _config.enable_reality_pulses:
        var elapsed_time = OS.get_ticks_msec() / 1000.0
        _current_reality_pulse_strength = _calculate_reality_pulse_value(elapsed_time)
    
    # Apply automatic refresh if enabled and due
    if _config.auto_intensity_scaling and OS.get_ticks_msec() - _last_refresh_time > (1000.0 / _config.max_refresh_rate):
        _apply_auto_refresh()

# Public API Methods

# Set reference to data sewer bridge
func set_data_sewer_bridge(bridge) -> void:
    _data_sewer_bridge = bridge

# Set reference to story data manager
func set_story_data_manager(manager) -> void:
    _story_data_manager = manager

# Process hash markers with extended intensity levels
func process_hash_markers(text: String) -> Dictionary:
    var hash_count = 0
    var i = 0
    
    # Count consecutive hash symbols
    while i < text.length() and text[i] == '#':
        hash_count += 1
        i += 1
    
    var result = {
        "original_text": text,
        "processed_text": text.substr(hash_count) if hash_count > 0 else text,
        "hash_count": hash_count,
        "refresh_triggered": false,
        "refresh_intensity": "",
        "reality_pulse": false
    }
    
    # Store hash count in buffer for pattern detection
    _hash_count_buffer.append(hash_count)
    if _hash_count_buffer.size() > 10:
        _hash_count_buffer.pop_front()
    
    # Check if the hash count triggers a hyper refresh
    if hash_count > 0:
        _current_intensity = hash_count
        
        # Determine intensity level
        var intensity_name = "NORMAL"
        if hash_count <= 7:
            intensity_name = "NORMAL"
        elif hash_count <= 15:
            intensity_name = "HIGH"
        elif hash_count <= 30:
            intensity_name = "ULTRA"
        elif hash_count <= 50:
            intensity_name = "HYPER"
        elif hash_count <= 100:
            intensity_name = "REALITY"
        else:
            intensity_name = "TRANSCENDENT"
        
        result.refresh_triggered = true
        result.refresh_intensity = intensity_name
        
        # Trigger the refresh
        _trigger_hyper_refresh(hash_count)
        
        # Potentially trigger a reality pulse for high intensity refreshes
        if hash_count > 30 and _config.enable_reality_pulses:
            result.reality_pulse = true
            _emit_reality_pulse(min(1.0, hash_count / 100.0))
    
    return result

# Trigger a hyper refresh with specific intensity
func trigger_refresh(intensity: int = -1, target_elements: Array = []) -> bool:
    if not _enabled:
        return false
    
    if intensity < 0:
        intensity = _current_intensity
    
    return _trigger_hyper_refresh(intensity, target_elements)

# Emit a reality pulse
func emit_reality_pulse(strength: float = 0.5, components: Array = []) -> bool:
    if not _enabled or not _config.enable_reality_pulses:
        return false
    
    return _emit_reality_pulse(strength, components)

# Change the pulse pattern
func set_pulse_pattern(pattern: int) -> void:
    if pattern >= 0 and pattern < PULSE_PATTERNS.size():
        _active_pulse_pattern = pattern
        _config.pulse_pattern = pattern

# Connect to a specific interface
func connect_to_interface(interface_type: int) -> bool:
    var interface_id = "interface_" + str(interface_type)
    
    if not _connected_interfaces.has(interface_id):
        return false
    
    var interface = _connected_interfaces[interface_id]
    
    if interface.status == "connected" or interface.status == "active":
        return true
    
    interface.status = "connected"
    
    # Perform interface-specific connection logic
    match interface_type:
        INTERFACE_TYPES.BROWSER:
            # Attempt to connect to WebSocket for browser
            if _websocket_client and _websocket_client.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED:
                var err = _websocket_client.connect_to_url(_config.browser_websocket_url)
                return err == OK
                
        INTERFACE_TYPES.GODOT:
            # Simply mark as connected since it's the current environment
            interface.status = "active"
            return true
            
        INTERFACE_TYPES.CONSOLE:
            # Connect to console if available
            if _data_sewer_bridge:
                interface.status = "active"
                return true
    
    return interface.status == "connected" or interface.status == "active"

# Update all connected interfaces
func update_all_interfaces() -> int:
    var updated_count = 0
    
    for interface_id in _connected_interfaces:
        var interface = _connected_interfaces[interface_id]
        
        if interface.status == "connected" or interface.status == "active":
            if interface.update():
                updated_count += 1
                emit_signal("interface_updated", interface_id, "refresh")
    
    return updated_count

# Get current performance metrics
func get_performance_metrics() -> Dictionary:
    if _config.performance_monitoring:
        return _performance_metrics.duplicate()
    else:
        return {}

# Get refresh history
func get_refresh_history() -> Array:
    var history = []
    for event in _refresh_history:
        history.append(event.to_dict())
    return history

# Update configuration
func update_config(new_config: Dictionary) -> bool:
    for key in new_config:
        if _config.has(key):
            _config[key] = new_config[key]
    
    # Apply configuration changes
    if _pulse_timer:
        _pulse_timer.wait_time = 1.0 / _config.pulse_frequency
    
    return true

# Enable/disable the system
func set_enabled(enabled: bool) -> void:
    _enabled = enabled
    
    if _pulse_timer:
        if enabled:
            _pulse_timer.start()
        else:
            _pulse_timer.stop()

# Internal Implementation Methods

# Trigger a hyper refresh with specific intensity
func _trigger_hyper_refresh(intensity: int, target_elements: Array = []) -> bool:
    if not _enabled:
        return false
    
    var refresh_event = RefreshEvent.new(intensity, target_elements)
    var start_time = OS.get_ticks_msec()
    
    # Prepare affected components
    var affected_components = []
    
    # Add default components if not specified
    if target_elements.empty():
        for interface_id in _connected_interfaces:
            var interface = _connected_interfaces[interface_id]
            if interface.status == "connected" or interface.status == "active":
                affected_components.append(interface_id)
    else:
        affected_components = target_elements
    
    # Apply intensity-specific effects
    if _data_sewer_bridge:
        # For lower intensities, use data sewer bridge's built-in functions
        if intensity <= 7:
            var hash_text = ""
            for i in range(intensity):
                hash_text += "#"
            _data_sewer_bridge.process_hash_markers(hash_text)
        else:
            # For higher intensities, apply direct modifications
            _apply_hyper_intensity_effects(_data_sewer_bridge, intensity)
    
    # Update story data manager if available
    if _story_data_manager:
        _apply_story_data_effects(_story_data_manager, intensity)
    
    # Update interfaces
    for component in affected_components:
        if _connected_interfaces.has(component):
            _connected_interfaces[component].update()
            emit_signal("interface_updated", component, "hyper_refresh")
    
    # Send WebSocket update if browser interface is available
    if _websocket_client and _websocket_client.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
        var data = {
            "type": "hyper_refresh",
            "intensity": intensity,
            "timestamp": OS.get_unix_time()
        }
        _websocket_client.get_peer(1).put_packet(JSON.print(data).to_utf8())
    
    # Complete the event
    var response_time = (OS.get_ticks_msec() - start_time) / 1000.0
    refresh_event.complete(response_time, true)
    
    # Track history
    _refresh_history.append(refresh_event)
    if _refresh_history.size() > 100:
        _refresh_history.pop_front()
    
    # Update last refresh time
    _last_refresh_time = OS.get_ticks_msec()
    
    # Emit signal
    emit_signal("hyper_refresh_triggered", intensity, affected_components)
    
    return true

# Apply special effects based on high intensity values
func _apply_hyper_intensity_effects(bridge, intensity: int) -> void:
    # Apply different effects based on intensity levels
    if intensity <= 15:  # HIGH
        # Rapid visual updates with moderate data changes
        bridge.update_console_size(80 + int(intensity * 1.5), 24 + intensity)
        
        # Add pulsing shape
        var shape_id = bridge.add_console_shape(
            bridge.SHAPE_TYPES.RECTANGLE,
            Vector2(5, 5),
            Vector2(intensity * 2, intensity),
            Color(0.5 + intensity / 30.0, 0.2, 0.7, 0.7)
        )
        
    elif intensity <= 30:  # ULTRA
        # More intensive visual changes with data stream modifications
        bridge.update_console_size(80 + int(intensity * 2), 24 + int(intensity * 1.5))
        
        # Create multiple shapes
        for i in range(3):
            var shape_id = bridge.add_console_shape(
                bridge.SHAPE_TYPES.CIRCLE,
                Vector2(10 + i * 20, 10),
                Vector2(intensity / 3.0, intensity / 3.0),
                Color(0.1, 0.7, 0.9, 0.8)
            )
        
        # Create a data pipeline to visualize the intensity
        var pipeline_id = bridge.create_pipeline(
            bridge.PIPELINE_TYPES.CONSOLE,
            "intensity_visualizer",
            "console_overlay"
        )
        bridge.start_data_flow(pipeline_id, {"intensity": intensity, "time": OS.get_unix_time()})
        
    elif intensity <= 50:  # HYPER
        # Major system-wide changes with complex visualizations
        bridge.update_console_size(80 + int(intensity * 3), 24 + int(intensity * 2))
        
        # Create complex visualizations
        for i in range(5):
            var shape_id = bridge.add_console_shape(
                bridge.SHAPE_TYPES.POLYGON,
                Vector2(40, 12),
                Vector2(intensity / 2.0, intensity / 2.0),
                Color(1.0, 0.3, 0.1, 0.9)
            )
        
        # Trigger combo reason analysis
        bridge.change_reason_state(
            bridge.REASON_STATES.PROCESSING,
            "Hyper-intensity refresh triggered"
        )
        
    elif intensity <= 100:  # REALITY
        # Reality-altering effects
        bridge.update_console_size(200, 50)  # Dramatically expand console
        
        # Create comprehensive visual environment
        for i in range(10):
            var shape_id = bridge.add_console_shape(
                bridge.SHAPE_TYPES.GRID,
                Vector2(i * 20, i * 5),
                Vector2(200 - i * 20, 50 - i * 5),
                Color(
                    sin(i * 0.1 + OS.get_ticks_msec() * 0.001) * 0.5 + 0.5,
                    cos(i * 0.1 + OS.get_ticks_msec() * 0.001) * 0.5 + 0.5,
                    sin(i * 0.2 + OS.get_ticks_msec() * 0.002) * 0.5 + 0.5,
                    0.7
                )
            )
        
        # Create multiple data pipelines
        for i in range(3):
            var pipeline_id = bridge.create_pipeline(
                bridge.PIPELINE_TYPES.CONSOLE,
                "reality_stream_" + str(i),
                "console_overlay"
            )
            bridge.start_data_flow(pipeline_id, {
                "reality_level": intensity,
                "stream_id": i,
                "timestamp": OS.get_unix_time()
            })
        
    else:  # TRANSCENDENT
        # Beyond reality effects - extreme transformations
        bridge.update_console_size(300, 100)  # Maximum expansion
        
        # Create otherworldly visualization
        for i in range(20):
            var hue = float(i) / 20.0
            var shape_id = bridge.add_console_shape(
                i % 5,  # Cycle through all shape types
                Vector2(150 + 100 * sin(i * PI / 10), 50 + 40 * cos(i * PI / 10)),
                Vector2(10 + i, 10 + i),
                Color.from_hsv(hue, 1.0, 1.0, 0.9)
            )
        
        # Reset the entire state system
        bridge.reset()
        
        # Create new transcendent state
        bridge.change_reason_state(
            bridge.REASON_STATES.REFLECTING,
            "Transcendent state achieved through ultra-high intensity refresh"
        )

# Apply effects to story data manager
func _apply_story_data_effects(manager, intensity: int) -> void:
    if intensity > 7:
        # Record history entry about the high-intensity refresh
        var category = manager.HISTORY_CATEGORIES.EVENT
        if intensity > 50:
            category = manager.HISTORY_CATEGORIES.MILESTONE
        
        var entry_id = manager.record_history(
            category,
            "High-intensity refresh triggered at level " + str(intensity),
            {"intensity": intensity, "timestamp": OS.get_unix_time()},
            ["refresh", "intensity", "system"]
        )
        
        if intensity > 30:
            # For very high intensities, create a story to document it
            var story_id = manager.create_story(
                "Hyper-Refresh Event " + str(OS.get_unix_time()),
                manager.STORY_TYPES.SYSTEM,
                "A level " + str(intensity) + " refresh occurred, causing significant system-wide changes and potential reality fluctuations.",
                [entry_id],
                {"intensity": intensity, "permanent_record": true},
                ["system", "refresh", "hyper", "reality"]
            )
        
        # At reality or transcendent levels, change the day cycle
        if intensity > 50:
            var current_cycle = manager.get_current_day_cycle()
            var next_cycle = (current_cycle.cycle + 1) % manager.DAY_CYCLE_PHASES.size()
            manager._advance_day_cycle()  # Directly advancing the cycle
        
        # Create a task to analyze the effects of the high-intensity refresh
        if intensity > 15:
            var task_id = manager.create_task(
                "Analyze Hyper-Refresh Effects",
                "Study and document the effects of the level " + str(intensity) + " refresh",
                intensity * 100,  # Token allocation based on intensity
                manager._current_day_cycle,
                4  # High priority
            )
            
            # Automatically start the task
            manager.start_task(task_id)

# Emit a reality pulse
func _emit_reality_pulse(strength: float, components: Array = []) -> bool:
    if not _enabled or not _config.enable_reality_pulses:
        return false
    
    var affected_components = components
    if affected_components.empty():
        # If no components specified, affect all interfaces
        for interface_id in _connected_interfaces:
            affected_components.append(interface_id)
    
    var pulse = RealityPulse.new(
        strength,
        _active_pulse_pattern,
        _config.pulse_frequency,
        affected_components
    )
    
    # Apply the pulse effect to components
    for component in affected_components:
        if _connected_interfaces.has(component):
            var interface = _connected_interfaces[component]
            
            # Apply visual effects based on interface type
            match interface.type:
                INTERFACE_TYPES.CONSOLE:
                    if _data_sewer_bridge:
                        # Create pulsing visual effect
                        var shape_id = "pulse_" + str(OS.get_unix_time())
                        _data_sewer_bridge.add_console_shape(
                            _data_sewer_bridge.SHAPE_TYPES.CIRCLE,
                            Vector2(40, 12),
                            Vector2(30 * strength, 15 * strength),
                            Color(0.9, 0.4, 0.1, 0.7 * strength)
                        )
                
                INTERFACE_TYPES.BROWSER:
                    # Send pulse data via WebSocket
                    if _websocket_client and _websocket_client.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
                        var data = {
                            "type": "reality_pulse",
                            "strength": strength,
                            "pattern": _active_pulse_pattern,
                            "timestamp": OS.get_unix_time()
                        }
                        _websocket_client.get_peer(1).put_packet(JSON.print(data).to_utf8())
    
    # Emit signal
    emit_signal("reality_pulse_emitted", strength, affected_components)
    
    return true

# Calculate current reality pulse value
func _calculate_reality_pulse_value(elapsed_time: float) -> float:
    if not _config.enable_reality_pulses:
        return 0.0
    
    var pulse = RealityPulse.new(
        1.0,
        _active_pulse_pattern,
        _config.pulse_frequency,
        []
    )
    
    return pulse.calculate_value(elapsed_time)

# Update performance metrics
func _update_performance_metrics(delta: float) -> void:
    # Update frame time directly
    _performance_metrics.frame_time = delta * 1000.0  # Convert to milliseconds
    
    # Calculate refresh rate based on recent history
    if _refresh_history.size() > 0:
        var count = min(_refresh_history.size(), 10)
        var recent_refreshes = _refresh_history.slice(_refresh_history.size() - count, _refresh_history.size() - 1)
        
        var total_response_time = 0.0
        for refresh in recent_refreshes:
            total_response_time += refresh.response_time
        
        if count > 0:
            _performance_metrics.response_time = total_response_time / count
        
        # Calculate refresh rate if we have multiple refreshes
        if recent_refreshes.size() > 1:
            var first = recent_refreshes[0]
            var last = recent_refreshes[recent_refreshes.size() - 1]
            var time_span = last.timestamp - first.timestamp
            
            if time_span > 0:
                _performance_metrics.refresh_rate = (recent_refreshes.size() - 1) / float(time_span)
    
    # Check for performance threshold breaches
    if _performance_metrics.frame_time > 33.3:  # Below 30 FPS
        emit_signal("performance_threshold_reached", "frame_time", _performance_metrics.frame_time)
    
    if _performance_metrics.response_time > 0.5:  # 500ms response time
        emit_signal("performance_threshold_reached", "response_time", _performance_metrics.response_time)

# Add an interface to the system
func _add_interface(type: int, name: String) -> String:
    var interface_id = "interface_" + str(type)
    var interface = Interface.new(interface_id, type, name)
    
    # Configure based on type
    match type:
        INTERFACE_TYPES.CONSOLE:
            interface.update_frequency = 5.0  # Updates per second
            interface.supports_real_time = true
        
        INTERFACE_TYPES.BROWSER:
            interface.update_frequency = 10.0  # Updates per second
            interface.supports_real_time = true
        
        INTERFACE_TYPES.GODOT:
            interface.update_frequency = 60.0  # Updates per second
            interface.supports_real_time = true
            interface.status = "connected"  # Auto-connect
    
    _connected_interfaces[interface_id] = interface
    return interface_id

# Apply automatic refresh based on hash pattern
func _apply_auto_refresh() -> void:
    if _hash_count_buffer.size() < 3:
        return
    
    # Detect patterns in hash counts
    var increasing = true
    var decreasing = true
    var alternating = true
    
    for i in range(1, _hash_count_buffer.size()):
        if _hash_count_buffer[i] <= _hash_count_buffer[i-1]:
            increasing = false
        if _hash_count_buffer[i] >= _hash_count_buffer[i-1]:
            decreasing = false
        if i > 1 and _hash_count_buffer[i] != _hash_count_buffer[i-2]:
            alternating = false
    
    # Apply special effects based on detected pattern
    if increasing and _hash_count_buffer[-1] > 0:
        # Growing pattern detected, apply escalating refresh
        _trigger_hyper_refresh(_hash_count_buffer[-1] + 5)
    elif decreasing and _hash_count_buffer[-1] > 0:
        # Shrinking pattern detected, apply de-escalating pulse
        _emit_reality_pulse(_hash_count_buffer[-1] / 10.0)
    elif alternating and _hash_count_buffer[-1] > 0:
        # Alternating pattern detected, switch pulse pattern
        set_pulse_pattern((_active_pulse_pattern + 1) % PULSE_PATTERNS.size())
        _emit_reality_pulse(0.5)

# WebSocket callbacks
func _on_websocket_connected(protocol):
    if _connected_interfaces.has("interface_" + str(INTERFACE_TYPES.BROWSER)):
        _connected_interfaces["interface_" + str(INTERFACE_TYPES.BROWSER)].status = "active"
    
    print("HyperRefreshSystem: WebSocket connected with protocol: " + protocol)
    
    # Send initial data
    var data = {
        "type": "connected",
        "system": "hyper_refresh",
        "timestamp": OS.get_unix_time()
    }
    _websocket_client.get_peer(1).put_packet(JSON.print(data).to_utf8())

func _on_websocket_error():
    if _connected_interfaces.has("interface_" + str(INTERFACE_TYPES.BROWSER)):
        _connected_interfaces["interface_" + str(INTERFACE_TYPES.BROWSER)].status = "disconnected"
    
    print("HyperRefreshSystem: WebSocket error occurred")

func _on_websocket_closed(code, reason):
    if _connected_interfaces.has("interface_" + str(INTERFACE_TYPES.BROWSER)):
        _connected_interfaces["interface_" + str(INTERFACE_TYPES.BROWSER)].status = "disconnected"
    
    print("HyperRefreshSystem: WebSocket closed with code: " + str(code) + ", reason: " + reason)

func _on_websocket_data_received():
    if _websocket_client:
        var data = _websocket_client.get_peer(1).get_packet().get_string_from_utf8()
        var parsed = JSON.parse(data)
        
        if parsed.error == OK:
            var message = parsed.result
            
            # Process incoming message
            match message.type:
                "refresh_request":
                    if message.has("intensity"):
                        _trigger_hyper_refresh(message.intensity)
                
                "pulse_request":
                    if message.has("strength"):
                        _emit_reality_pulse(message.strength)
                
                "config_update":
                    if message.has("config"):
                        update_config(message.config)

# Pulse timer callback
func _on_pulse_timer_timeout():
    if _config.enable_reality_pulses:
        # Calculate current pulse value
        var elapsed_time = OS.get_ticks_msec() / 1000.0
        _current_reality_pulse_strength = _calculate_reality_pulse_value(elapsed_time)
        
        # Apply pulse to connected interfaces
        for interface_id in _connected_interfaces:
            var interface = _connected_interfaces[interface_id]
            
            if interface.status == "active" and randf() < 0.3:  # Apply randomly to active interfaces
                match interface.type:
                    INTERFACE_TYPES.CONSOLE:
                        if _data_sewer_bridge:
                            # Pulse console shapes
                            for shape_id in ["default_grid", "pulse_indicator"]:
                                if _data_sewer_bridge._registered_shapes.has(shape_id):
                                    _data_sewer_bridge.update_shape(shape_id, {
                                        "color": Color(
                                            0.3,
                                            0.3,
                                            0.3,
                                            0.3 + 0.4 * _current_reality_pulse_strength
                                        )
                                    })
                    
                    INTERFACE_TYPES.BROWSER:
                        # Send pulse update via WebSocket
                        if _websocket_client and _websocket_client.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
                            var data = {
                                "type": "pulse_update",
                                "value": _current_reality_pulse_strength,
                                "timestamp": OS.get_unix_time()
                            }
                            _websocket_client.get_peer(1).put_packet(JSON.print(data).to_utf8())

# Example usage:
# var hyper_refresh = HyperRefreshSystem.new()
# add_child(hyper_refresh)
# 
# # Connect to data sewer bridge
# var data_bridge = DataSewerBridge.new()
# add_child(data_bridge)
# hyper_refresh.set_data_sewer_bridge(data_bridge)
# 
# # Connect to story data manager
# var story_manager = StoryDataManager.new()
# add_child(story_manager)
# hyper_refresh.set_story_data_manager(story_manager)
# 
# # Process an ultra-high intensity refresh command
# var result = hyper_refresh.process_hash_markers("################################################################")
# print("Triggered " + result.refresh_intensity + " intensity refresh")
# 
# # Change the pulse pattern
# hyper_refresh.set_pulse_pattern(HyperRefreshSystem.PULSE_PATTERNS.EXPONENTIAL)
# 
# # Enable reality pulses at maximum frequency
# hyper_refresh.update_config({
#     "enable_reality_pulses": true,
#     "pulse_frequency": 5.0,
#     "pulse_pattern": HyperRefreshSystem.PULSE_PATTERNS.CHAOTIC
# })