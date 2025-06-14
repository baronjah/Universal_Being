extends Node
class_name LunoSleepSystem

signal sleep_state_changed(state: Dictionary)
signal core_allocation_changed(allocation: Dictionary)
signal calm_word_generated(word_data: Dictionary)
signal platform_sync_completed(platform_data: Dictionary)

# Core constants
const VERSION = "2.1.0"
const MAX_SLEEP_DEPTH = 5
const CALM_WORD_LIBRARY_SIZE = 144

# Sleep cycle phases
enum SleepPhase {
    AWAKE,
    LIGHT_SLEEP,
    DEEP_SLEEP,
    REM_SLEEP,
    DELTA_SLEEP
}

# Core allocation options
enum CoreAllocation {
    SINGLE_CORE,
    DUAL_CORE,
    QUAD_CORE,
    ADAPTIVE
}

# Platform support
enum Platform {
    WINDOWS,
    APPLE,
    LINUX,
    CONSOLE,
    MOBILE
}

# Current sleep state
var sleep_state: Dictionary = {
    "active": false,
    "phase": SleepPhase.AWAKE,
    "depth": 0,
    "cycle_count": 0,
    "current_cycle": 0,
    "cycle_duration": 720,  # 12 minutes per cycle
    "started_at": 0,
    "calm_level": 0.0,
    "dream_active": false
}

# System resources
var system_resources: Dictionary = {
    "core_allocation": CoreAllocation.SINGLE_CORE,
    "cores_available": 1,
    "cores_active": 1,
    "memory_allocated": 256,  # MB
    "memory_available": 1024, # MB
    "power_mode": "low",
    "battery_optimization": true,
    "offline_mode": true
}

# Core management
var core_management: Dictionary = {
    "windows": {
        "enabled": true,
        "cores": 1,
        "priority": "normal",
        "affinity": [0]
    },
    "apple": {
        "enabled": false,
        "cores": 0,
        "priority": "low",
        "affinity": []
    },
    "gemini": {
        "enabled": false,
        "cores": 0,
        "priority": "background",
        "affinity": []
    },
    "luno": {
        "enabled": true,
        "cores": 1,
        "priority": "high",
        "affinity": [1]
    }
}

# Calm word system
var calm_words: Dictionary = {
    "library": [],
    "current_word": "",
    "power_words": [],
    "calm_phrases": [],
    "last_generated": 0,
    "generation_interval": 1800  # 30 minutes
}

# Platform synchronization
var platform_sync: Dictionary = {
    "active": false,
    "platforms": {},
    "sync_interval": 3600,  # 1 hour
    "last_sync": 0,
    "auto_sync": true
}

# LUNO integration
var luno_manager: Node = null
var word_dream_creator: Node = null

func _ready():
    # Initialize the sleep system
    print("💤 LUNO Sleep System v%s initializing..." % VERSION)
    
    # Connect to required systems
    _connect_to_systems()
    
    # Initialize calm words
    _initialize_calm_words()
    
    # Detect system cores
    _detect_system_cores()
    
    # Initialize platform sync
    _initialize_platform_sync()
    
    # Check if we should auto-start in sleep mode
    var current_time = Time.get_time_dict_from_system()
    if current_time.hour >= 22 or current_time.hour < 7:
        # Auto-start sleep mode during night hours
        start_sleep_cycle()

func _connect_to_systems():
    # Connect to LUNO system if available
    luno_manager = get_node_or_null("/root/LunoCycleManager")
    if luno_manager:
        print("✓ Connected to LUNO Cycle Manager")
        luno_manager.register_participant("SleepSystem", Callable(self, "_on_luno_tick"))
    else:
        print("⚠️ LUNO Cycle Manager not found, operating independently")
    
    # Connect to Word Dream Creator if available
    word_dream_creator = get_node_or_null("/root/WordDreamCreator")
    if word_dream_creator:
        print("✓ Connected to Word Dream Creator")

func _initialize_calm_words():
    # Initialize the calm word library
    calm_words.library = [
        # Base calm words
        "serenity", "tranquil", "peaceful", "gentle", "quiet", 
        "harmony", "balance", "stillness", "calm", "rest",
        "breathe", "flow", "ease", "relax", "serene",
        "silence", "whisper", "soft", "slow", "steady",
        
        # Nature words
        "ocean", "stream", "forest", "breeze", "cloud",
        "rain", "star", "moon", "sunset", "dawn",
        "garden", "meadow", "mountain", "lake", "horizon",
        
        # Computer calm words
        "idle", "standby", "sleep", "hibernate", "suspend",
        "pause", "buffer", "cache", "float", "stream",
        "core", "pulse", "cycle", "wave", "node"
    ]
    
    # Power words that have extra calming effect
    calm_words.power_words = [
        "ethereal", "luminus", "seraphic", "breath", "azure",
        "whisper", "crystalline", "echo", "radiance", "zephyr"
    ]
    
    # Calm phrases
    calm_words.calm_phrases = [
        "core resting",
        "system cooling",
        "memory flowing",
        "power saving",
        "cycles pausing",
        "resource optimizing",
        "mind clearing",
        "thought slowing",
        "energy conserving",
        "processing dreams"
    ]
    
    # Generate initial word
    _generate_calm_word()
    
    print("📝 Calm word system initialized with %d words" % 
          (calm_words.library.size() + calm_words.power_words.size()))

func _detect_system_cores():
    # In a real implementation, this would detect actual system cores
    # For simulation, we'll set reasonable defaults
    
    # Simulate a quad-core system
    system_resources.cores_available = 4
    system_resources.cores_active = 1  # Start with one core
    
    # Set available memory
    system_resources.memory_available = 4096  # 4 GB
    
    print("💻 System resources detected:")
    print("   Cores: %d" % system_resources.cores_available)
    print("   Memory: %d MB" % system_resources.memory_available)

func _initialize_platform_sync():
    # Set up platform synchronization
    platform_sync.platforms = {
        Platform.WINDOWS: {
            "name": "Windows",
            "enabled": true,
            "cores": 1,
            "sync_status": "active",
            "last_sync": OS.get_unix_time()
        },
        Platform.APPLE: {
            "name": "Apple",
            "enabled": false,
            "cores": 0,
            "sync_status": "disconnected",
            "last_sync": 0
        },
        Platform.CONSOLE: {
            "name": "Game Console",
            "enabled": false,
            "cores": 0,
            "sync_status": "disconnected",
            "last_sync": 0
        },
        Platform.LINUX: {
            "name": "Linux",
            "enabled": false,
            "cores": 0,
            "sync_status": "disconnected",
            "last_sync": 0
        },
        Platform.MOBILE: {
            "name": "Mobile",
            "enabled": false,
            "cores": 0,
            "sync_status": "disconnected",
            "last_sync": 0
        }
    }
    
    print("🔄 Platform sync initialized")

func start_sleep_cycle(cycles: int = 5) -> bool:
    # Start the sleep cycle system
    
    if sleep_state.active:
        print("⚠️ Sleep cycle already active")
        return false
    
    sleep_state.active = true
    sleep_state.phase = SleepPhase.LIGHT_SLEEP
    sleep_state.depth = 1
    sleep_state.cycle_count = cycles
    sleep_state.current_cycle = 0
    sleep_state.started_at = OS.get_unix_time()
    sleep_state.calm_level = 0.2
    
    # Apply resource changes for sleep mode
    _adjust_resources_for_sleep()
    
    print("💤 Sleep cycle started")
    print("   Phase: Light Sleep")
    print("   Planned cycles: %d" % cycles)
    
    # Generate calm word
    _generate_calm_word()
    
    # Emit signal
    emit_signal("sleep_state_changed", sleep_state)
    
    return true

func stop_sleep_cycle() -> bool:
    # Stop the sleep cycle system
    
    if not sleep_state.active:
        print("⚠️ Sleep cycle not active")
        return false
    
    var cycles_completed = sleep_state.current_cycle
    var duration = OS.get_unix_time() - sleep_state.started_at
    
    sleep_state.active = false
    sleep_state.phase = SleepPhase.AWAKE
    sleep_state.depth = 0
    sleep_state.calm_level = 0.0
    
    # Restore resources
    _restore_resources_after_sleep()
    
    print("⏰ Sleep cycle stopped")
    print("   Cycles completed: %d/%d" % [cycles_completed, sleep_state.cycle_count])
    print("   Duration: %d minutes" % (duration / 60))
    
    # Emit signal
    emit_signal("sleep_state_changed", sleep_state)
    
    return true

func advance_sleep_cycle() -> Dictionary:
    # Advance to the next sleep cycle
    
    if not sleep_state.active:
        print("⚠️ Cannot advance: Sleep cycle not active")
        return {}
    
    sleep_state.current_cycle += 1
    
    # Determine next phase based on cycle progression
    var cycle_progress = float(sleep_state.current_cycle) / sleep_state.cycle_count
    
    if cycle_progress < 0.2:
        sleep_state.phase = SleepPhase.LIGHT_SLEEP
        sleep_state.depth = 1
        sleep_state.calm_level = 0.3
    elif cycle_progress < 0.4:
        sleep_state.phase = SleepPhase.DEEP_SLEEP
        sleep_state.depth = 2
        sleep_state.calm_level = 0.5
    elif cycle_progress < 0.7:
        sleep_state.phase = SleepPhase.DELTA_SLEEP
        sleep_state.depth = 3
        sleep_state.calm_level = 0.8
        sleep_state.dream_active = false  # No dreams in delta sleep
    elif cycle_progress < 0.9:
        sleep_state.phase = SleepPhase.REM_SLEEP
        sleep_state.depth = 4
        sleep_state.calm_level = 0.6
        sleep_state.dream_active = true  # Dreams active in REM
    else:
        sleep_state.phase = SleepPhase.LIGHT_SLEEP
        sleep_state.depth = 2
        sleep_state.calm_level = 0.4
        sleep_state.dream_active = false
    
    # Generate a new calm word
    _generate_calm_word()
    
    # Adjust core allocation based on sleep phase
    _adjust_core_allocation_for_phase()
    
    print("💤 Advanced to sleep cycle %d/%d" % [sleep_state.current_cycle, sleep_state.cycle_count])
    print("   Phase: %s" % _get_phase_name(sleep_state.phase))
    print("   Depth: %d" % sleep_state.depth)
    print("   Calm Level: %.1f" % sleep_state.calm_level)
    
    # Check if we've completed all cycles
    if sleep_state.current_cycle >= sleep_state.cycle_count:
        print("✅ Sleep cycle sequence completed")
        stop_sleep_cycle()
    
    # Emit signal
    emit_signal("sleep_state_changed", sleep_state)
    
    return sleep_state

func set_core_allocation(allocation: int) -> bool:
    # Set the core allocation mode
    
    if allocation < 0 or allocation > CoreAllocation.ADAPTIVE:
        print("⚠️ Invalid core allocation: %d" % allocation)
        return false
    
    system_resources.core_allocation = allocation
    
    # Apply the new allocation
    match allocation:
        CoreAllocation.SINGLE_CORE:
            system_resources.cores_active = 1
        CoreAllocation.DUAL_CORE:
            system_resources.cores_active = min(2, system_resources.cores_available)
        CoreAllocation.QUAD_CORE:
            system_resources.cores_active = min(4, system_resources.cores_available)
        CoreAllocation.ADAPTIVE:
            # Adaptive will adjust based on load
            if sleep_state.active:
                # Use fewer cores in sleep mode
                system_resources.cores_active = 1
            else:
                # Use more cores when awake
                system_resources.cores_active = min(system_resources.cores_available, 2)
    
    # Update core management
    _update_core_management()
    
    print("💻 Core allocation set to: %s" % _get_allocation_name(allocation))
    print("   Active cores: %d/%d" % [system_resources.cores_active, system_resources.cores_available])
    
    # Emit signal
    emit_signal("core_allocation_changed", system_resources)
    
    return true

func enable_platform(platform: int, enable: bool) -> bool:
    # Enable or disable a platform
    
    if not platform_sync.platforms.has(platform):
        print("⚠️ Invalid platform: %d" % platform)
        return false
    
    var platform_info = platform_sync.platforms[platform]
    platform_info.enabled = enable
    
    if enable:
        platform_info.sync_status = "connecting"
        platform_info.cores = 1
        
        # Simulate connection process
        await get_tree().create_timer(0.5).timeout
        
        platform_info.sync_status = "active"
        platform_info.last_sync = OS.get_unix_time()
        
        print("✅ Platform enabled: %s" % platform_info.name)
    else:
        platform_info.sync_status = "disconnecting"
        platform_info.cores = 0
        
        # Simulate disconnection process
        await get_tree().create_timer(0.3).timeout
        
        platform_info.sync_status = "disconnected"
        
        print("❌ Platform disabled: %s" % platform_info.name)
    
    # Update core allocation
    _update_core_availability()
    
    # Emit signal
    emit_signal("platform_sync_completed", platform_sync)
    
    return true

func enable_gemini_core(enable: bool) -> bool:
    # Enable or disable the Gemini core
    
    core_management.gemini.enabled = enable
    
    if enable:
        core_management.gemini.cores = 1
        print("✅ Gemini core enabled")
    else:
        core_management.gemini.cores = 0
        print("❌ Gemini core disabled")
    
    # Update core allocation
    _update_core_management()
    
    return true

func toggle_offline_mode(enable: bool) -> bool:
    # Toggle offline mode
    
    system_resources.offline_mode = enable
    
    if enable:
        print("🔌 Offline mode enabled")
        
        # In offline mode, limit core usage
        if system_resources.cores_active > 2:
            set_core_allocation(CoreAllocation.DUAL_CORE)
    else:
        print("🔌 Offline mode disabled")
    
    return true

func _generate_calm_word() -> String:
    # Generate a calming word or phrase
    
    # Decide whether to generate a word or phrase
    var use_phrase = randf() > 0.7  # 30% chance for phrase
    
    var result = ""
    
    if use_phrase:
        # Use a calm phrase
        result = calm_words.calm_phrases[randi() % calm_words.calm_phrases.size()]
    else:
        # Combine words
        var base_word = ""
        var modifier = ""
        
        # 20% chance to use a power word
        if randf() > 0.8:
            base_word = calm_words.power_words[randi() % calm_words.power_words.size()]
        else:
            base_word = calm_words.library[randi() % calm_words.library.size()]
        
        # Sometimes add a modifier
        if randf() > 0.5:
            modifier = calm_words.library[randi() % calm_words.library.size()]
            result = modifier + " " + base_word
        else:
            result = base_word
    
    # Update last generated time
    calm_words.last_generated = OS.get_unix_time()
    calm_words.current_word = result
    
    # Create word data
    var word_data = {
        "word": result,
        "is_phrase": use_phrase,
        "power_level": sleep_state.calm_level * 10,
        "sleep_phase": sleep_state.phase,
        "generated_at": calm_words.last_generated
    }
    
    print("🌙 Calm word generated: \"%s\"" % result)
    
    # Emit signal
    emit_signal("calm_word_generated", word_data)
    
    return result

func _adjust_resources_for_sleep():
    # Adjust system resources for sleep mode
    
    # Lower core count
    var previous_cores = system_resources.cores_active
    system_resources.cores_active = 1
    
    # Lower memory usage
    var previous_memory = system_resources.memory_allocated
    system_resources.memory_allocated = 128  # Minimum memory usage
    
    # Set power mode to low
    system_resources.power_mode = "low"
    
    # Enable battery optimization
    system_resources.battery_optimization = true
    
    print("⬇️ Resources adjusted for sleep:")
    print("   Cores: %d → %d" % [previous_cores, system_resources.cores_active])
    print("   Memory: %d → %d MB" % [previous_memory, system_resources.memory_allocated])
    
    # Update core management
    _update_core_management()

func _restore_resources_after_sleep():
    # Restore system resources after sleep
    
    # Restore cores based on allocation setting
    var previous_cores = system_resources.cores_active
    
    match system_resources.core_allocation:
        CoreAllocation.SINGLE_CORE:
            system_resources.cores_active = 1
        CoreAllocation.DUAL_CORE:
            system_resources.cores_active = min(2, system_resources.cores_available)
        CoreAllocation.QUAD_CORE:
            system_resources.cores_active = min(4, system_resources.cores_available)
        CoreAllocation.ADAPTIVE:
            system_resources.cores_active = min(system_resources.cores_available, 2)
    
    # Restore memory
    var previous_memory = system_resources.memory_allocated
    system_resources.memory_allocated = min(system_resources.memory_available, 512)
    
    # Restore power mode
    system_resources.power_mode = "normal"
    
    print("⬆️ Resources restored after sleep:")
    print("   Cores: %d → %d" % [previous_cores, system_resources.cores_active])
    print("   Memory: %d → %d MB" % [previous_memory, system_resources.memory_allocated])
    
    # Update core management
    _update_core_management()

func _adjust_core_allocation_for_phase():
    # Adjust core allocation based on current sleep phase
    
    match sleep_state.phase:
        SleepPhase.LIGHT_SLEEP:
            # Light sleep: minimal resources
            core_management.windows.cores = 1
            core_management.luno.cores = 0
            core_management.gemini.cores = 0
            core_management.apple.cores = 0
        
        SleepPhase.DEEP_SLEEP:
            # Deep sleep: almost no resources
            core_management.windows.cores = 0
            core_management.luno.cores = 1
            core_management.gemini.cores = 0
            core_management.apple.cores = 0
        
        SleepPhase.DELTA_SLEEP:
            # Delta sleep: only essential systems
            core_management.windows.cores = 0
            core_management.luno.cores = 1
            core_management.gemini.cores = 0
            core_management.apple.cores = 0
        
        SleepPhase.REM_SLEEP:
            # REM sleep: dream processing
            core_management.windows.cores = 0
            core_management.luno.cores = 1
            if core_management.gemini.enabled:
                core_management.gemini.cores = 1
            core_management.apple.cores = 0
    
    # Update memory allocation based on phase
    system_resources.memory_allocated = 64 + (sleep_state.depth * 32)  # 64-192 MB
    
    # Update core management
    _update_core_management()

func _update_core_management():
    # Update core management settings
    
    # Count total allocated cores
    var total_allocated = 0
    for system in core_management:
        total_allocated += core_management[system].cores
    
    # Ensure we don't exceed active cores
    if total_allocated > system_resources.cores_active:
        # Reduce allocations proportionally
        for system in core_management:
            if core_management[system].cores > 0:
                core_management[system].cores = max(1, int(core_management[system].cores * system_resources.cores_active / total_allocated))
    
    # Update affinities based on cores
    var core_index = 0
    for system in core_management:
        core_management[system].affinity = []
        for i in range(core_management[system].cores):
            if core_index < system_resources.cores_available:
                core_management[system].affinity.append(core_index)
                core_index += 1
    
    print("💻 Core management updated:")
    for system in core_management:
        if core_management[system].cores > 0:
            print("   %s: %d cores, priority: %s" % [
                system,
                core_management[system].cores,
                core_management[system].priority
            ])

func _update_core_availability():
    # Update core availability based on platforms
    
    var available_cores = 1  # Always have at least one core
    
    # Count cores from all enabled platforms
    for platform_id in platform_sync.platforms:
        var platform = platform_sync.platforms[platform_id]
        if platform.enabled and platform.sync_status == "active":
            available_cores += platform.cores
    
    # Update available cores
    system_resources.cores_available = available_cores
    
    # Adjust active cores if needed
    if system_resources.cores_active > system_resources.cores_available:
        system_resources.cores_active = system_resources.cores_available
    
    print("💻 Core availability updated: %d cores available" % system_resources.cores_available)
    
    # Update core management
    _update_core_management()

func _get_phase_name(phase: int) -> String:
    match phase:
        SleepPhase.AWAKE: return "Awake"
        SleepPhase.LIGHT_SLEEP: return "Light Sleep"
        SleepPhase.DEEP_SLEEP: return "Deep Sleep"
        SleepPhase.REM_SLEEP: return "REM Sleep"
        SleepPhase.DELTA_SLEEP: return "Delta Sleep"
        _: return "Unknown"

func _get_allocation_name(allocation: int) -> String:
    match allocation:
        CoreAllocation.SINGLE_CORE: return "Single Core"
        CoreAllocation.DUAL_CORE: return "Dual Core"
        CoreAllocation.QUAD_CORE: return "Quad Core"
        CoreAllocation.ADAPTIVE: return "Adaptive"
        _: return "Unknown"

func _on_luno_tick(turn: int, phase_name: String):
    # Handle LUNO cycle ticks
    
    # Special case for evolution
    if turn == 0 and phase_name == "Evolution":
        print("✨ LunoSleepSystem evolving with system")
        return
    
    # Process based on current phase
    match phase_name:
        "Genesis", "Formation":
            # Early phases are good for starting sleep
            if not sleep_state.active and randf() > 0.8:  # 20% chance
                print("🌙 Genesis/Formation phase prompting sleep")
                start_sleep_cycle(3)  # Shorter cycle
        
        "Consciousness", "Enlightenment":
            # These phases are better for wakefulness
            if sleep_state.active:
                print("☀️ Consciousness/Enlightenment phase prompting awakening")
                stop_sleep_cycle()
        
        "Unity", "Beyond":
            # Later phases advance sleep cycles
            if sleep_state.active:
                advance_sleep_cycle()

# Public API
func get_sleep_state() -> Dictionary:
    return sleep_state

func get_system_resources() -> Dictionary:
    return system_resources

func get_core_management() -> Dictionary:
    return core_management

func get_calm_word() -> String:
    return calm_words.current_word

func get_platform_sync() -> Dictionary:
    return platform_sync

# Example usage:
# var sleep_system = LunoSleepSystem.new()
# add_child(sleep_system)
# sleep_system.set_core_allocation(LunoSleepSystem.CoreAllocation.DUAL_CORE)
# sleep_system.start_sleep_cycle()