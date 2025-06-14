extends Node
class_name LunoCycleManager

signal cycle_started(turn: int)
signal cycle_completed(turn: int)
signal participant_tick(participant_name: String, turn: int)

@export var cycle_interval: float = 5.0 # Time between turns (can be changed live)
@export var auto_start: bool = true
@export var offline_mode: bool = false # Controls whether system operates offline
@export var min_turn_duration: int = 9 # Minimum turn duration (seconds)
@export var max_turn_duration: int = 19 # Maximum turn duration (seconds)

var current_turn: int = 1
var participants: Dictionary = {} # {name: Callable}
var turn_phases: Array[String] = [
    "Genesis", "Formation", "Complexity", "Consciousness",
    "Awakening", "Enlightenment", "Manifestation", "Connection",
    "Harmony", "Transcendence", "Unity", "Beyond"
]

var cycle_timer: Timer
var adaptive_timing: bool = true # Dynamically adjust timing based on system load
var system_diagnostics: Dictionary = {}
var firewall_status: Dictionary = {
    "enabled": true,
    "level": "standard", # standard, enhanced, divine
    "last_check": 0
}
var turn_stats: Dictionary = {
    "completed_cycles": 0,
    "total_turns": 0,
    "avg_turn_time": 0
}

func _ready():
    cycle_timer = Timer.new()
    cycle_timer.wait_time = _calculate_adaptive_time()
    cycle_timer.one_shot = false
    cycle_timer.connect("timeout", Callable(self, "_advance_turn"))
    add_child(cycle_timer)
    
    _initialize_diagnostics()
    _initialize_dream_system()
    
    if auto_start:
        start_cycles()

func _initialize_dream_system():
    print("🌙 Initializing Dream System...")
    # Create a dedicated structure for dream data
    var dream_system = {
        "active": false,
        "dream_depth": 0,
        "dream_symbols": [],
        "dream_connections": {},
        "shared_dream_space": ""
    }
    
    # Store it in diagnostics
    system_diagnostics["dream_system"] = dream_system
    print("✨ Dream System initialized and ready for connections")

func _initialize_diagnostics():
    system_diagnostics = {
        "memory_usage": 0,
        "api_connections": {},
        "active_systems": [],
        "last_check": OS.get_unix_time(),
        "health_status": "unknown"
    }
    perform_system_diagnostics()

func start_cycles():
    if not cycle_timer.is_stopped():
        return
    cycle_timer.start()
    print("🔄 LUNO Cycle started at Turn %d → %s" % [current_turn, turn_phases[current_turn - 1]])
    emit_signal("cycle_started", current_turn)

func stop_cycles():
    if cycle_timer.is_stopped():
        return
    cycle_timer.stop()
    print("⏸️ LUNO Cycle stopped at Turn %d" % current_turn)

func register_participant(name: String, participant_function: Callable):
    participants[name] = participant_function
    print("✅ Participant '%s' registered to LUNO Cycles" % name)
    system_diagnostics.active_systems.append(name)

func unregister_participant(name: String):
    if participants.has(name):
        participants.erase(name)
        print("❌ Participant '%s' unregistered from LUNO Cycles" % name)
        system_diagnostics.active_systems.erase(name)

func _calculate_adaptive_time() -> float:
    # Calculate adaptive time based on min/max duration settings
    if not adaptive_timing:
        return cycle_interval
    
    # Get system load - this is a simplified approximation
    var system_load = 0.5 # Default middle value
    if system_diagnostics.has("memory_usage") and system_diagnostics.memory_usage > 0:
        system_load = min(system_diagnostics.memory_usage / 1000000000.0, 1.0) # Scale based on memory usage (up to 1GB)
    
    # Calculate time dynamically between min and max
    var range_size = max_turn_duration - min_turn_duration
    var adaptive_time = min_turn_duration + (range_size * (1.0 - system_load))
    
    print("⏱️ Adaptive turn time: %0.1f seconds (load: %0.2f)" % [adaptive_time, system_load])
    return adaptive_time

func _advance_turn():
    # Run diagnostics on cycle change
    if current_turn % 3 == 0: # Every 3 turns
        perform_system_diagnostics()
    
    if current_turn % 4 == 0: # Every 4 turns
        check_firewall()
    
    # Update turn stats
    turn_stats.total_turns += 1
    
    # Process dream state if active
    if system_diagnostics.has("dream_system") and system_diagnostics.dream_system.active:
        _process_dream_state()
    
    # Advance to next turn
    current_turn = (current_turn % turn_phases.size()) + 1
    var phase_name = turn_phases[current_turn - 1]
    print("\n🌀 Turn %d → %s" % [current_turn, phase_name])

    # Adjust timer duration based on adaptive timing
    if adaptive_timing:
        cycle_timer.wait_time = _calculate_adaptive_time()

    # Call all registered participants
    for name in participants.keys():
        var func = participants[name]
        if func.is_valid():
            func.call(current_turn, phase_name)
            emit_signal("participant_tick", name, current_turn)

    emit_signal("cycle_completed", current_turn)
    
    # Auto-evolution every 12 cycles
    if current_turn == 12:
        turn_stats.completed_cycles += 1
        print("🔄 Full cycle completed - initiating system evolution")
        _evolve_system()

func _process_dream_state():
    var dream_system = system_diagnostics.dream_system
    
    # Increase dream depth with each turn, up to a maximum of 5
    if dream_system.dream_depth < 5:
        dream_system.dream_depth += 1
    
    print("💭 Dream depth: %d" % dream_system.dream_depth)
    
    # Generate dream symbols based on active participants and current phase
    var new_symbol = turn_phases[current_turn - 1].left(1) + str(dream_system.dream_depth)
    dream_system.dream_symbols.append(new_symbol)
    
    # Update shared dream space
    var phase_name = turn_phases[current_turn - 1]
    dream_system.shared_dream_space = "Dreaming in %s phase (depth %d)" % [phase_name, dream_system.dream_depth]

func get_current_phase() -> String:
    return turn_phases[current_turn - 1]

func perform_system_diagnostics():
    print("🔍 Performing system diagnostics...")
    
    # Update basic diagnostic info
    system_diagnostics.memory_usage = OS.get_static_memory_usage()
    system_diagnostics.last_check = OS.get_unix_time()
    
    # Check API connections
    _check_api_connections()
    
    # Determine overall health
    _evaluate_system_health()
    
    print("✅ Diagnostics complete. Status: " + system_diagnostics.health_status)
    return system_diagnostics

func _check_api_connections():
    # This would normally check actual connections
    # Simplified version for demonstration
    var api_services = ["Claude", "GPT", "Gemini", "Microsoft"]
    
    for api in api_services:
        system_diagnostics.api_connections[api] = {
            "connected": not offline_mode,
            "health": "good" if not offline_mode else "offline",
            "last_response": OS.get_unix_time() if not offline_mode else 0
        }

func _evaluate_system_health():
    # Check active systems
    var active_count = system_diagnostics.active_systems.size()
    
    # Memory usage check
    var memory_ok = system_diagnostics.memory_usage < 1000000000 # 1GB threshold
    
    # API status
    var apis_ok = true
    for api in system_diagnostics.api_connections:
        if system_diagnostics.api_connections[api].health == "bad":
            apis_ok = false
    
    # Determine overall health
    if memory_ok and apis_ok and active_count > 0:
        system_diagnostics.health_status = "good"
    elif memory_ok and active_count > 0:
        system_diagnostics.health_status = "degraded"
    else:
        system_diagnostics.health_status = "poor"

func check_firewall():
    print("🔒 Checking firewall status...")
    
    # Simulate checking firewall rules
    firewall_status.last_check = OS.get_unix_time()
    
    # In a real implementation, this would check actual firewall settings
    # For demonstration, we'll just update the status
    print("✅ Firewall check complete. Level: " + firewall_status.level)
    
    return firewall_status

func set_firewall_level(level: String):
    if level in ["standard", "enhanced", "divine"]:
        firewall_status.level = level
        print("🔒 Firewall level set to: " + level)
    else:
        print("❌ Invalid firewall level: " + level)

func toggle_offline_mode(enable: bool):
    offline_mode = enable
    print("🌐 Offline mode: " + ("Enabled" if offline_mode else "Disabled"))
    _check_api_connections()

func _evolve_system():
    # This would implement the system evolution after a full 12-turn cycle
    print("🚀 Evolving system to next level...")
    
    # Process all dream symbols if dream system is active
    if system_diagnostics.has("dream_system"):
        var dream_system = system_diagnostics.dream_system
        if dream_system.active and dream_system.dream_symbols.size() > 0:
            print("✨ Incorporating dream symbols into evolution:")
            for symbol in dream_system.dream_symbols:
                print("  • Symbol: " + symbol)
            
            # Reset dream symbols but maintain active state
            dream_system.dream_symbols = []
            dream_system.dream_depth = 0
            dream_system.shared_dream_space = "Dream reset after evolution"
    
    # Create evolution log
    var evolution_log = {
        "timestamp": OS.get_unix_time(),
        "cycle_number": turn_stats.completed_cycles,
        "total_turns": turn_stats.total_turns,
        "active_participants": system_diagnostics.active_systems.size(),
        "memory_usage": system_diagnostics.memory_usage
    }
    
    # Store evolution log (in a real implementation, this would be saved to disk)
    print("📊 Evolution stats: Cycle #%d, Total turns: %d" % [evolution_log.cycle_number, evolution_log.total_turns])
    
    # In a real implementation, this would update system capabilities
    print("✨ System evolved to next level")
    
    # Signal all participants about the evolution
    for name in participants.keys():
        var func = participants[name]
        if func.is_valid():
            func.call(0, "Evolution") # Special turn number 0 indicates evolution event

func enter_dream_state():
    if not system_diagnostics.has("dream_system"):
        print("❌ Dream system not initialized")
        return false
        
    system_diagnostics.dream_system.active = true
    print("💤 System entered dream state")
    return true
    
func exit_dream_state():
    if not system_diagnostics.has("dream_system"):
        print("❌ Dream system not initialized")
        return false
        
    system_diagnostics.dream_system.active = false
    print("⏰ System exited dream state")
    return true
    
func get_dream_state() -> Dictionary:
    if not system_diagnostics.has("dream_system"):
        return {}
    return system_diagnostics.dream_system

# Example usage:
# In other systems, access and register with:
#
# func _ready():
#     var luno = get_node("/root/LunoCycleManager")
#     if luno:
#         luno.register_participant("MySystem", Callable(self, "_on_luno_tick"))
#
# func _on_luno_tick(turn: int, phase_name: String):
#     print("MySystem received tick at Turn %d → %s" % [turn, phase_name])
#     # Implement phase-specific behavior here