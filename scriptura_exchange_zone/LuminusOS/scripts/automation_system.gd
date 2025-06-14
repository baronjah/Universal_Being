extends Node

class_name AutomationSystem

# Central automation system for LuminusOS
# Coordinates ticking between all subsystems

signal tick_processed(tick_count)
signal automation_status_changed(enabled)
signal system_synchronized(timestamp)

# Reference to subsystems
var multi_core_system = null
var word_story_system = null
var magic_system = null

# Automation settings
var auto_tick_enabled = false
var global_tick_speed = 0.5 # seconds
var tick_timer = 0.0
var tick_count = 0

# Per-system settings
var system_enabled = {
	"multi_core": true,
	"word_story": true,
	"magic": true
}

# System synchronization
var last_sync_time = 0
var sync_interval = 5.0 # seconds
var sync_timer = 0.0

# Performance monitoring
var performance_stats = {
	"avg_tick_time": 0.0,
	"total_ticks": 0,
	"system_load": {
		"multi_core": 0.0,
		"word_story": 0.0,
		"magic": 0.0
	}
}

func _ready():
	pass

func _process(delta):
	if auto_tick_enabled:
		tick_timer += delta
		if tick_timer >= global_tick_speed:
			tick_timer = 0.0
			process_global_tick()
			
	# System synchronization
	sync_timer += delta
	if sync_timer >= sync_interval:
		sync_timer = 0.0
		synchronize_systems()

# Initialize with references to other systems
func initialize(multi_core, word_story, magic):
	multi_core_system = multi_core
	word_story_system = word_story
	magic_system = magic
	
	# Initialize system states
	update_system_states()

# Process a global tick for all subsystems
func process_global_tick():
	var tick_start_time = Time.get_ticks_msec()
	
	# Process each subsystem if enabled
	if multi_core_system != null and system_enabled["multi_core"]:
		var start_time = Time.get_ticks_msec()
		multi_core_system.process_tick()
		performance_stats["system_load"]["multi_core"] = (Time.get_ticks_msec() - start_time) / 1000.0
	
	if word_story_system != null and system_enabled["word_story"]:
		var start_time = Time.get_ticks_msec()
		word_story_system.process_tick()
		performance_stats["system_load"]["word_story"] = (Time.get_ticks_msec() - start_time) / 1000.0
	
	if magic_system != null and system_enabled["magic"]:
		var start_time = Time.get_ticks_msec()
		magic_system.process_tick()
		performance_stats["system_load"]["magic"] = (Time.get_ticks_msec() - start_time) / 1000.0
	
	# Update performance stats
	var tick_duration = (Time.get_ticks_msec() - tick_start_time) / 1000.0
	performance_stats["total_ticks"] += 1
	
	# Running average for tick time
	performance_stats["avg_tick_time"] = (performance_stats["avg_tick_time"] * (performance_stats["total_ticks"] - 1) + tick_duration) / performance_stats["total_ticks"]
	
	# Increment tick count
	tick_count += 1
	
	emit_signal("tick_processed", tick_count)

# Synchronize all system ticks
func synchronize_systems():
	var timestamp = Time.get_unix_time_from_system()
	last_sync_time = timestamp
	
	# Update system states
	update_system_states()
	
	emit_signal("system_synchronized", timestamp)

# Update system states from their internal settings
func update_system_states():
	if multi_core_system != null:
		multi_core_system.auto_tick_enabled = false # Central automation handles ticking
	
	if word_story_system != null:
		word_story_system.auto_tick_enabled = false # Central automation handles ticking
	
	if magic_system != null:
		magic_system.auto_tick_enabled = false # Central automation handles ticking

# Enable/disable global automation
func set_automation_enabled(enabled):
	auto_tick_enabled = enabled
	emit_signal("automation_status_changed", enabled)
	
	# Update all subsystems
	update_system_states()

# Set global tick speed
func set_global_tick_speed(speed):
	if speed >= 0.1:
		global_tick_speed = speed
		return true
	return false

# Enable/disable specific subsystem
func set_system_enabled(system_name, enabled):
	if system_name in system_enabled:
		system_enabled[system_name] = enabled
		update_system_states()
		return true
	return false

# API for LuminusOS terminal

func cmd_auto(args):
	if args.size() == 0:
		return "Usage: auto <command> [parameters]"
	
	match args[0]:
		"status":
			return get_automation_status()
			
		"on":
			set_automation_enabled(true)
			return "Global automation enabled"
			
		"off":
			set_automation_enabled(false)
			return "Global automation disabled"
			
		"speed":
			if args.size() < 2:
				return "Current tick speed: " + str(global_tick_speed) + "s"
			
			if args[1].is_valid_float():
				var new_speed = float(args[1])
				if set_global_tick_speed(new_speed):
					return "Global tick speed set to " + str(global_tick_speed) + "s"
				else:
					return "Tick speed must be at least 0.1s"
			
			return "Invalid tick speed"
			
		"enable":
			if args.size() < 2:
				return "Usage: auto enable <system_name>"
			
			var system_name = args[1]
			if set_system_enabled(system_name, true):
				return "Enabled " + system_name + " system"
			else:
				return "Unknown system: " + system_name
				
		"disable":
			if args.size() < 2:
				return "Usage: auto disable <system_name>"
			
			var system_name = args[1]
			if set_system_enabled(system_name, false):
				return "Disabled " + system_name + " system"
			else:
				return "Unknown system: " + system_name
				
		"once":
			process_global_tick()
			return "Manual global tick processed"
			
		"sync":
			synchronize_systems()
			return "Systems synchronized"
			
		"stats":
			return get_performance_stats()
			
		"systems":
			return get_systems_status()
			
		_:
			return "Unknown automation command. Try 'status', 'on', 'off', 'speed', 'enable', 'disable', 'once', 'sync', 'stats', or 'systems'"

# Helper functions for formatting output

func get_automation_status():
	var status = "Automation System Status:\n"
	status += "Global automation: " + ("Enabled" if auto_tick_enabled else "Disabled") + "\n"
	status += "Global tick speed: " + str(global_tick_speed) + "s\n"
	status += "Total ticks processed: " + str(tick_count) + "\n"
	status += "Last sync time: " + str(last_sync_time) + "\n"
	status += "Sync interval: " + str(sync_interval) + "s\n"
	
	return status

func get_performance_stats():
	var stats = "Automation Performance Stats:\n"
	stats += "Average tick time: " + str(performance_stats["avg_tick_time"]) + "s\n"
	stats += "Total ticks: " + str(performance_stats["total_ticks"]) + "\n"
	stats += "System load:\n"
	
	for system in performance_stats["system_load"]:
		stats += "  " + system + ": " + str(performance_stats["system_load"][system]) + "s per tick\n"
	
	return stats

func get_systems_status():
	var status = "Connected Systems:\n"
	
	status += "Multi-Core System: "
	if multi_core_system != null:
		status += "Connected, " + ("Enabled" if system_enabled["multi_core"] else "Disabled")
	else:
		status += "Not connected"
	status += "\n"
	
	status += "Word/Story System: "
	if word_story_system != null:
		status += "Connected, " + ("Enabled" if system_enabled["word_story"] else "Disabled")
	else:
		status += "Not connected"
	status += "\n"
	
	status += "Magic System: "
	if magic_system != null:
		status += "Connected, " + ("Enabled" if system_enabled["magic"] else "Disabled")
	else:
		status += "Not connected"
	status += "\n"
	
	return status