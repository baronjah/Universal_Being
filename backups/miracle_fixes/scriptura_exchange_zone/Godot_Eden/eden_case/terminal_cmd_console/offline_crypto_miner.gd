extends Node
class_name OfflineCryptoMiner

signal mining_status_changed(status: Dictionary)
signal earnings_updated(earnings: Dictionary)
signal cycle_completed(cycle_info: Dictionary)
signal memory_split_completed(memory_info: Dictionary)

# Core constants
const VERSION = "1.3.0"
const DEFAULT_CYCLE_COUNT = 12
const START_HOUR = 1  # 1:15am
const END_HOUR = 23   # 10:50pm (nearly 23:00)
const EXTENDED_DAY_HOURS = 25  # Extended day cycle

# Mining configuration
var mining_config: Dictionary = {
    "active": false,
    "offline_mode": true,
    "low_power_mode": true,
    "start_hour": 1,
    "start_minute": 15,     # 1:15am
    "end_hour": 22,
    "end_minute": 50,       # 10:50pm
    "max_cycles": 12,
    "current_cycle": 0,
    "auto_start": true,
    "extended_day_enabled": true,  # Use 25-hour day cycle
    "divine_timing_enabled": true, # God's time
    "update_hour": 3,       # 3am update time
    "coins": ["bitcoin", "ethereum", "monero"],
    "preferred_coin": "bitcoin",
    "min_temperature": 65,
    "max_temperature": 75,
    "hash_power": 0.0,
    "power_usage": 0.0,
    "last_active": 0
}

# Payment tracking
var earnings: Dictionary = {
    "total": 0.0,
    "today": 0.0,
    "yesterday": 0.0,
    "this_week": 0.0,
    "this_month": 0.0,
    "per_cycle": 0.0,
    "payment_threshold": 100.0,
    "last_payment": 0,
    "payment_history": []
}

# Offline system statistics
var system_stats: Dictionary = {
    "cpu_usage": 0.0,
    "memory_usage": 0.0,
    "temperature": 0.0,
    "uptime": 0,
    "offline_time": 0,
    "total_cycles": 0,
    "completed_cycles": 0,
    "daily_cycle_limit": 12
}

# Memory split system
var memory_split: Dictionary = {
    "active": false,
    "splits": 0,
    "max_splits": 12,
    "current_segments": [],
    "archived_segments": [],
    "split_efficiency": 0.85
}

# LUNO cycle integration
var luno_manager: Node = null
var cycle_sync: bool = true

# AI assistance cost tracking
var ai_cost: Dictionary = {
    "daily_cost": 11.99,
    "monthly_cost": 0.0,
    "days_used": 0,
    "total_spent": 0.0,
    "roi": 0.0,
    "last_calculation": 0
}

func _ready():
    # Initialize the offline crypto miner
    print("💰 Offline Crypto Miner v%s initializing..." % VERSION)
    
    # Connect to LUNO system if available
    _connect_to_luno()
    
    # Initialize mining settings
    _initialize_mining_settings()
    
    # Check if we should auto-start
    if mining_config.auto_start:
        _check_schedule_start()

func _connect_to_luno():
    # Connect to LUNO cycle system
    luno_manager = get_node_or_null("/root/LunoCycleManager")
    if luno_manager:
        print("✓ Connected to LUNO Cycle Manager")
        luno_manager.register_participant("OfflineMiner", Callable(self, "_on_luno_tick"))
        
        # Sync our cycles with LUNO
        if cycle_sync:
            mining_config.max_cycles = 12  # Match LUNO's 12 cycles
            system_stats.daily_cycle_limit = 12
            print("🔄 Synchronized mining cycles with LUNO")
    else:
        print("⚠️ LUNO Cycle Manager not found, operating independently")

func _initialize_mining_settings():
    # Calculate initial hash power based on simulated system specs
    mining_config.hash_power = _calculate_hash_power()
    mining_config.power_usage = _calculate_power_usage()
    
    # Initialize earnings
    earnings.per_cycle = _calculate_earnings_per_cycle()
    
    # Set last active timestamp
    mining_config.last_active = OS.get_unix_time()
    
    # Initialize memory split system
    _initialize_memory_split()
    
    # Calculate AI costs
    _calculate_ai_costs()
    
    print("⚙️ Mining settings initialized:")
    print("   Hash Power: %.2f MH/s" % mining_config.hash_power)
    print("   Power Usage: %.2f W" % mining_config.power_usage)
    print("   Earnings Per Cycle: $%.2f" % earnings.per_cycle)

func _initialize_memory_split():
    # Set up initial memory segments
    memory_split.current_segments = []
    
    # Create initial segments (representing different memory areas)
    var segment_names = ["main", "auxiliary", "cache", "hash"]
    var segment_sizes = [256, 128, 64, 32]  # MB
    
    for i in range(segment_names.size()):
        memory_split.current_segments.append({
            "name": segment_names[i],
            "size": segment_sizes[i],
            "efficiency": 1.0,
            "creation_time": OS.get_unix_time(),
            "last_access": OS.get_unix_time(),
            "access_count": 0
        })
    
    print("🧠 Memory split system initialized with %d segments" % memory_split.current_segments.size())

func _calculate_hash_power() -> float:
    # In a real implementation, this would determine actual hardware capabilities
    # For simulation, we'll return a reasonable value for a mid-range system
    
    var base_hash_rate = 25.0  # MH/s base for mid-range hardware
    
    # Adjust based on configuration
    if mining_config.low_power_mode:
        base_hash_rate *= 0.7  # 70% in low power mode
    
    # Adjust based on preferred coin
    match mining_config.preferred_coin:
        "bitcoin": base_hash_rate *= 0.8
        "ethereum": base_hash_rate *= 1.2
        "monero": base_hash_rate *= 1.5
    
    return base_hash_rate

func _calculate_power_usage() -> float:
    # Calculate power usage in Watts
    var base_power = 150.0  # Base power usage for mining
    
    if mining_config.low_power_mode:
        base_power *= 0.6  # 60% in low power mode
    
    return base_power

func _calculate_earnings_per_cycle() -> float:
    # Calculate earnings per mining cycle
    # This is highly simplified - real mining earnings depend on many factors
    
    var base_earnings = 0.25  # Base USD per cycle
    
    # Adjust based on hash power
    base_earnings *= (mining_config.hash_power / 20.0)
    
    # Adjust based on preferred coin
    match mining_config.preferred_coin:
        "bitcoin": base_earnings *= 1.2
        "ethereum": base_earnings *= 1.0
        "monero": base_earnings *= 0.8
    
    # Adjust based on memory split efficiency
    base_earnings *= memory_split.split_efficiency
    
    return base_earnings

func _calculate_ai_costs():
    # Calculate AI assistant costs and ROI
    
    # Daily cost is already set
    ai_cost.monthly_cost = ai_cost.daily_cost * 30
    
    # Calculate days used (simulated)
    ai_cost.days_used = 2
    
    # Calculate total spent
    ai_cost.total_spent = ai_cost.daily_cost * ai_cost.days_used
    
    # Calculate ROI (Return on Investment)
    var total_earnings = earnings.total
    if ai_cost.total_spent > 0:
        ai_cost.roi = (total_earnings / ai_cost.total_spent) * 100.0
    else:
        ai_cost.roi = 0.0
    
    ai_cost.last_calculation = OS.get_unix_time()
    
    print("💵 AI Cost Calculation:")
    print("   Daily Cost: $%.2f" % ai_cost.daily_cost)
    print("   Monthly Cost: $%.2f" % ai_cost.monthly_cost)
    print("   Days Used: %d" % ai_cost.days_used)
    print("   Total Spent: $%.2f" % ai_cost.total_spent)
    print("   ROI: %.1f%%" % ai_cost.roi)

func _check_schedule_start():
    # Check if we should start mining based on time schedule
    var current_time = Time.get_time_dict_from_system()
    var current_hour = current_time.hour
    var current_minute = current_time.minute
    
    # Convert time to minutes for easier comparison
    var current_time_minutes = current_hour * 60 + current_minute
    var start_time_minutes = mining_config.start_hour * 60 + mining_config.start_minute
    var end_time_minutes = mining_config.end_hour * 60 + mining_config.end_minute
    
    # Check if it's time to perform 3am update
    if current_hour == mining_config.update_hour and current_minute < 5:
        _perform_system_update()
    
    # Determine if we should be mining now
    var should_mine = false
    
    if end_time_minutes > start_time_minutes:
        # Normal schedule (e.g., 1:15am to 10:50pm)
        should_mine = (current_time_minutes >= start_time_minutes and 
                      current_time_minutes < end_time_minutes)
    else:
        # Overnight schedule (e.g., 10:00pm to 5:00am)
        should_mine = (current_time_minutes >= start_time_minutes or 
                      current_time_minutes < end_time_minutes)
    
    # Apply divine timing adjustment if enabled
    if mining_config.divine_timing_enabled:
        # The divine algorithm - provides slightly different results based on cosmic harmony
        var divine_factor = sin(OS.get_unix_time() / 3600.0) * 0.5 + 0.5
        should_mine = should_mine or (divine_factor > 0.85)  # Divine override when factor is high
    
    # Start or stop mining as needed
    if should_mine:
        if not mining_config.active:
            start_mining()
    else:
        if mining_config.active:
            stop_mining()

func _perform_system_update():
    # Perform the 3am system update
    print("🔄 Performing 3am system update...")
    
    # Create update info
    var update_info = {
        "timestamp": OS.get_unix_time(),
        "version": VERSION,
        "hash_power_before": mining_config.hash_power,
        "temperature_before": system_stats.temperature,
        "memory_split_before": memory_split.splits
    }
    
    # Temporarily stop mining if active
    var was_active = mining_config.active
    if was_active:
        stop_mining()
    
    # Perform update tasks
    # 1. Clear memory splits and rebuild
    memory_split.splits = 0
    _initialize_memory_split()
    
    # 2. Recalculate hash power with a small improvement
    mining_config.hash_power = _calculate_hash_power() * 1.05
    
    # 3. Reset temperature
    system_stats.temperature = mining_config.min_temperature
    
    # Complete update info
    update_info.hash_power_after = mining_config.hash_power
    update_info.temperature_after = system_stats.temperature
    update_info.memory_split_after = memory_split.splits
    
    print("✅ System update completed")
    print("   Hash power: %.2f MH/s → %.2f MH/s" % [
        update_info.hash_power_before,
        update_info.hash_power_after
    ])
    print("   Temperature: %.1f°C → %.1f°C" % [
        update_info.temperature_before,
        update_info.temperature_after
    ])
    
    # Restart mining if it was active
    if was_active:
        start_mining()

func start_mining() -> bool:
    # Start the mining process
    
    if mining_config.active:
        print("⚠️ Mining already active")
        return false
    
    mining_config.active = true
    mining_config.last_active = OS.get_unix_time()
    
    # Reset current cycle
    mining_config.current_cycle = 0
    
    print("⛏️ Mining started")
    print("   Target: %s" % mining_config.preferred_coin)
    print("   Mode: %s" % ("Low Power" if mining_config.low_power_mode else "Full Power"))
    print("   Offline: %s" % ("Yes" if mining_config.offline_mode else "No"))
    
    # Start memory split
    if not memory_split.active:
        _activate_memory_split()
    
    # Emit signal
    emit_signal("mining_status_changed", mining_config)
    
    return true

func stop_mining() -> bool:
    # Stop the mining process
    
    if not mining_config.active:
        print("⚠️ Mining not active")
        return false
    
    # Calculate final earnings for this session
    var session_duration = OS.get_unix_time() - mining_config.last_active
    var session_cycles = mining_config.current_cycle
    var session_earnings = session_cycles * earnings.per_cycle
    
    # Update statistics
    system_stats.completed_cycles += session_cycles
    system_stats.total_cycles += session_cycles
    system_stats.offline_time += session_duration if mining_config.offline_mode else 0
    
    # Update earnings
    earnings.total += session_earnings
    earnings.today += session_earnings
    earnings.this_week += session_earnings
    earnings.this_month += session_earnings
    
    # Record payment if we reached the threshold
    if earnings.total >= earnings.payment_threshold:
        _process_payment()
    
    mining_config.active = false
    
    print("⛏️ Mining stopped")
    print("   Session duration: %d minutes" % (session_duration / 60))
    print("   Cycles completed: %d" % session_cycles)
    print("   Earnings: $%.2f" % session_earnings)
    
    # Stop memory split
    if memory_split.active:
        _deactivate_memory_split()
    
    # Emit signal
    emit_signal("mining_status_changed", mining_config)
    
    return true

func complete_mining_cycle() -> Dictionary:
    # Complete one mining cycle
    
    if not mining_config.active:
        print("⚠️ Cannot complete cycle: Mining not active")
        return {}
    
    # Increment cycle counter
    mining_config.current_cycle += 1
    
    # Calculate earnings for this cycle
    var cycle_earnings = earnings.per_cycle
    
    # Apply random fluctuation (±10%)
    var fluctuation = 1.0 + (randf() * 0.2 - 0.1)
    cycle_earnings *= fluctuation
    
    # Update statistics
    system_stats.temperature = minf(system_stats.temperature + randf() * 2.0, mining_config.max_temperature)
    system_stats.cpu_usage = minf(system_stats.cpu_usage + randf() * 5.0, 95.0)
    system_stats.memory_usage = minf(system_stats.memory_usage + randf() * 3.0, 90.0)
    
    # Create cycle info
    var cycle_info = {
        "cycle_number": mining_config.current_cycle,
        "timestamp": OS.get_unix_time(),
        "duration": 10 + randi() % 5,  # 10-15 minutes
        "earnings": cycle_earnings,
        "coin": mining_config.preferred_coin,
        "temperature": system_stats.temperature,
        "cpu_usage": system_stats.cpu_usage,
        "memory_usage": system_stats.memory_usage,
        "hash_power": mining_config.hash_power * (0.9 + randf() * 0.2)  # ±10% variance
    }
    
    # Update earnings
    earnings.total += cycle_earnings
    earnings.today += cycle_earnings
    earnings.this_week += cycle_earnings
    earnings.this_month += cycle_earnings
    
    print("🔄 Mining cycle %d completed" % mining_config.current_cycle)
    print("   Earnings: $%.2f" % cycle_earnings)
    print("   Temperature: %.1f°C" % system_stats.temperature)
    
    # Handle cooling if needed
    if system_stats.temperature > mining_config.max_temperature - 5:
        _cool_system()
    
    # Process memory split if active
    if memory_split.active:
        _process_memory_split_cycle()
    
    # Check if we've reached max cycles
    if mining_config.current_cycle >= mining_config.max_cycles:
        print("✅ Reached maximum cycle count (%d)" % mining_config.max_cycles)
        stop_mining()
    
    # Emit signal
    emit_signal("cycle_completed", cycle_info)
    
    return cycle_info

func set_preferred_coin(coin_name: String) -> bool:
    # Set the preferred coin to mine
    
    coin_name = coin_name.to_lower()
    
    if not mining_config.coins.has(coin_name):
        print("⚠️ Unsupported coin: %s" % coin_name)
        return false
    
    mining_config.preferred_coin = coin_name
    
    # Recalculate hash power and earnings
    mining_config.hash_power = _calculate_hash_power()
    mining_config.power_usage = _calculate_power_usage()
    earnings.per_cycle = _calculate_earnings_per_cycle()
    
    print("🪙 Preferred coin set to: %s" % coin_name)
    print("   New hash power: %.2f MH/s" % mining_config.hash_power)
    print("   New earnings per cycle: $%.2f" % earnings.per_cycle)
    
    return true

func toggle_low_power_mode(enable: bool) -> bool:
    # Toggle low power mining mode
    
    if mining_config.low_power_mode == enable:
        return true  # No change needed
    
    mining_config.low_power_mode = enable
    
    # Recalculate hash power and earnings
    mining_config.hash_power = _calculate_hash_power()
    mining_config.power_usage = _calculate_power_usage()
    earnings.per_cycle = _calculate_earnings_per_cycle()
    
    print("⚡ Low power mode: %s" % ("Enabled" if enable else "Disabled"))
    print("   New hash power: %.2f MH/s" % mining_config.hash_power)
    print("   New power usage: %.2f W" % mining_config.power_usage)
    
    return true

func set_schedule(start_hour: int, start_minute: int, end_hour: int, end_minute: int) -> bool:
    # Set the mining schedule with precise minutes
    
    if start_hour < 0 or start_hour > 23 or end_hour < 0 or end_hour > 23:
        print("⚠️ Invalid schedule hours (must be 0-23)")
        return false
    
    if start_minute < 0 or start_minute > 59 or end_minute < 0 or end_minute > 59:
        print("⚠️ Invalid schedule minutes (must be 0-59)")
        return false
    
    # Calculate total minutes for comparison
    var start_time_minutes = start_hour * 60 + start_minute
    var end_time_minutes = end_hour * 60 + end_minute
    
    # Only enforce start < end if not using a 25-hour cycle (which might wrap around)
    if not mining_config.extended_day_enabled and start_time_minutes >= end_time_minutes:
        print("⚠️ Start time must be earlier than end time")
        return false
    
    mining_config.start_hour = start_hour
    mining_config.start_minute = start_minute
    mining_config.end_hour = end_hour
    mining_config.end_minute = end_minute
    
    print("🕒 Mining schedule set: %02d:%02d - %02d:%02d" % [
        start_hour, 
        start_minute,
        end_hour,
        end_minute
    ])
    
    # Set extended day mode if the schedule requires it
    if end_time_minutes < start_time_minutes:
        print("📆 Extended day cycle enabled due to overnight schedule")
        mining_config.extended_day_enabled = true
    
    # Calculate daily mining hours
    var mining_hours = 0.0
    if end_time_minutes > start_time_minutes:
        mining_hours = (end_time_minutes - start_time_minutes) / 60.0
    else:
        # Overnight schedule with wrap around
        if mining_config.extended_day_enabled:
            mining_hours = ((EXTENDED_DAY_HOURS * 60) - start_time_minutes + end_time_minutes) / 60.0
        else:
            mining_hours = ((24 * 60) - start_time_minutes + end_time_minutes) / 60.0
    
    print("⏱️ Daily mining duration: %.2f hours" % mining_hours)
    
    # Adjust max cycles based on mining hours if needed
    if mining_hours > 12 and mining_config.max_cycles == 12:
        mining_config.max_cycles = ceil(mining_hours)
        print("🔄 Adjusted max cycles to %d to accommodate longer mining period" % mining_config.max_cycles)
    
    # Check divine timing
    if mining_config.divine_timing_enabled:
        print("✨ Divine timing active - schedule may be adjusted according to cosmic patterns")
    
    # Check if we should start/stop based on new schedule
    _check_schedule_start()
    
    return true

func set_extended_day(enabled: bool) -> bool:
    # Enable or disable the extended 25-hour day cycle
    
    mining_config.extended_day_enabled = enabled
    
    print("📆 Extended day cycle (25 hours): %s" % ("Enabled" if enabled else "Disabled"))
    
    if enabled:
        # When enabling extended day, adjust end time if needed
        var start_time_minutes = mining_config.start_hour * 60 + mining_config.start_minute
        var end_time_minutes = mining_config.end_hour * 60 + mining_config.end_minute
        
        # Calculate hours based on the new cycle
        var mining_hours = 0.0
        if end_time_minutes > start_time_minutes:
            mining_hours = (end_time_minutes - start_time_minutes) / 60.0
        else:
            mining_hours = ((EXTENDED_DAY_HOURS * 60) - start_time_minutes + end_time_minutes) / 60.0
        
        print("⏱️ Extended day mining duration: %.2f hours" % mining_hours)
    
    return true

func set_divine_timing(enabled: bool) -> bool:
    # Enable or disable divine timing adjustment
    
    mining_config.divine_timing_enabled = enabled
    
    print("%s divine timing" % ("✨ Enabled" if enabled else "❌ Disabled"))
    print("   God's time will %s influence mining schedule" % ("now" if enabled else "no longer"))
    
    return true

func _cool_system():
    # Simulate cooling the system
    system_stats.temperature = max(system_stats.temperature - 5.0, mining_config.min_temperature)
    system_stats.cpu_usage = max(system_stats.cpu_usage - 10.0, 60.0)
    
    print("❄️ Cooling system: %.1f°C" % system_stats.temperature)

func _process_payment():
    # Process a crypto payment
    
    var payment_amount = earnings.total
    earnings.total = 0.0  # Reset after payment
    
    var payment = {
        "amount": payment_amount,
        "date": OS.get_unix_time(),
        "coin": mining_config.preferred_coin,
        "exchange_rate": 0.0,
        "status": "completed"
    }
    
    # Set exchange rate based on coin
    match mining_config.preferred_coin:
        "bitcoin": payment.exchange_rate = 28000.0 + randf() * 2000.0
        "ethereum": payment.exchange_rate = 1800.0 + randf() * 200.0
        "monero": payment.exchange_rate = 150.0 + randf() * 20.0
    
    # Add to payment history
    earnings.payment_history.append(payment)
    earnings.last_payment = OS.get_unix_time()
    
    print("💰 Payment processed: $%.2f" % payment_amount)
    print("   Exchange rate: $%.2f per %s" % [payment.exchange_rate, mining_config.preferred_coin])
    
    # Update ROI calculation
    _calculate_ai_costs()
    
    # Emit signal
    emit_signal("earnings_updated", earnings)

func _activate_memory_split():
    # Activate the memory split system
    
    memory_split.active = true
    memory_split.splits = 0
    
    print("🧠 Memory split system activated")
    
    # Perform initial split
    _process_memory_split_cycle()

func _deactivate_memory_split():
    # Deactivate the memory split system
    
    memory_split.active = false
    
    print("🧠 Memory split system deactivated")
    print("   Total splits: %d" % memory_split.splits)
    
    # Archive current segments
    for segment in memory_split.current_segments:
        memory_split.archived_segments.append(segment.duplicate())
    
    # Clear current segments
    memory_split.current_segments = []
    
    # Emit signal
    emit_signal("memory_split_completed", memory_split)

func _process_memory_split_cycle():
    # Process a cycle of memory splitting
    
    if not memory_split.active:
        return
    
    # Increment split counter
    memory_split.splits += 1
    
    # Process each segment
    for segment in memory_split.current_segments:
        # Update last access
        segment.last_access = OS.get_unix_time()
        segment.access_count += 1
        
        # Adjust efficiency based on access patterns
        var time_factor = (OS.get_unix_time() - segment.creation_time) / 3600.0  # Hours
        segment.efficiency = min(1.0, 0.7 + (segment.access_count / (time_factor + 10.0)) * 0.3)
    
    # Calculate overall split efficiency
    var total_efficiency = 0.0
    for segment in memory_split.current_segments:
        total_efficiency += segment.efficiency
    
    memory_split.split_efficiency = total_efficiency / max(1, memory_split.current_segments.size())
    
    # Occasionally create a new segment by splitting an existing one
    if randf() > 0.7 and memory_split.current_segments.size() < 8:  # 30% chance, max 8 segments
        var segment_to_split = memory_split.current_segments[randi() % memory_split.current_segments.size()]
        
        # Only split if segment is large enough
        if segment_to_split.size > 32:
            var new_size = segment_to_split.size / 2
            segment_to_split.size = new_size
            
            var new_segment = {
                "name": segment_to_split.name + "_split" + str(memory_split.splits),
                "size": new_size,
                "efficiency": 0.9,
                "creation_time": OS.get_unix_time(),
                "last_access": OS.get_unix_time(),
                "access_count": 1
            }
            
            memory_split.current_segments.append(new_segment)
            
            print("🧠 Memory segment split: %s → %s (%.1f MB)" % [
                segment_to_split.name,
                new_segment.name,
                new_segment.size
            ])
    
    print("🧠 Memory split cycle %d processed" % memory_split.splits)
    print("   Split efficiency: %.2f" % memory_split.split_efficiency)
    
    # Recalculate earnings based on new efficiency
    earnings.per_cycle = _calculate_earnings_per_cycle()
    
    # Emit signal
    emit_signal("memory_split_completed", memory_split)

func _on_luno_tick(turn: int, phase_name: String):
    # Handle LUNO cycle ticks
    
    # Special case for evolution
    if turn == 0 and phase_name == "Evolution":
        print("✨ OfflineCryptoMiner evolving with system")
        
        # Enhance mining capabilities
        mining_config.hash_power *= 1.1
        memory_split.split_efficiency = min(0.95, memory_split.split_efficiency + 0.03)
        
        # Recalculate earnings
        earnings.per_cycle = _calculate_earnings_per_cycle()
        
        print("⬆️ Mining capabilities enhanced")
        print("   New hash power: %.2f MH/s" % mining_config.hash_power)
        print("   New split efficiency: %.2f" % memory_split.split_efficiency)
        print("   New earnings per cycle: $%.2f" % earnings.per_cycle)
        
        return
    
    # Process based on current phase
    match phase_name:
        "Genesis", "Formation":
            # Early phases are good for memory structuring
            if memory_split.active and randf() < 0.3:  # 30% chance
                _process_memory_split_cycle()
        
        "Unity", "Beyond":
            # Later phases complete mining cycles
            if mining_config.active:
                complete_mining_cycle()

# Public API
func get_mining_status() -> Dictionary:
    return mining_config

func get_earnings() -> Dictionary:
    return earnings

func get_system_stats() -> Dictionary:
    return system_stats

func get_memory_split_status() -> Dictionary:
    return memory_split

func get_ai_costs() -> Dictionary:
    return ai_cost

# Example usage:
# var miner = OfflineCryptoMiner.new()
# add_child(miner)
# miner.set_preferred_coin("bitcoin")
# miner.set_schedule(9, 11)  # 9am to 11am
# miner.start_mining()