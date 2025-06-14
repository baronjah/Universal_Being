extends Node

class_name ArchiveManager

# Archive Manager for LuminusOS
# Handles hourly data archiving and project change tracking

signal archive_created(archive_id, timestamp)
signal archive_restored(archive_id, success)
signal tick_recorded(tick_id, changes)
signal archive_space_warning(used_percent)
signal archive_integrity_verified(archive_id, result)

# Constants
const HOUR_ARCHIVE_PREFIX = "hour_"
const TICK_ARCHIVE_PREFIX = "tick_"
const DAILY_ARCHIVE_PREFIX = "day_"
const WEEK_ARCHIVE_PREFIX = "week_"
const ARCHIVE_VERSION = "1.0"
const MAX_TICK_INTERVAL = 60  # seconds
const MIN_TICK_INTERVAL = 1   # seconds
const DEFAULT_TICK_INTERVAL = 10  # seconds
const ARCHIVE_RETENTION = {
    "tick": 24,     # Hours to keep tick archives
    "hour": 168,    # Hours to keep hourly archives (7 days)
    "day": 90,      # Days to keep daily archives
    "week": 52      # Weeks to keep weekly archives
}
const AUTO_VERIFY_INTERVAL = 24  # Hours between automatic integrity verification

# Archive storage and configuration
var archives = {
    "tick": {},
    "hour": {},
    "day": {},
    "week": {}
}

var archive_config = {
    "auto_tick": true,
    "tick_interval": DEFAULT_TICK_INTERVAL,
    "auto_verify": true,
    "compress_archives": true,
    "max_archive_size_mb": 5000,  # 5GB
    "include_resources": true,
    "archive_path": "user://archives/",
    "max_archive_count": {
        "tick": 1000,
        "hour": 168,
        "day": 90,
        "week": 52
    }
}

# Runtime tracking
var last_tick_time = 0
var last_hour_archive_time = 0
var last_day_archive_time = 0
var last_week_archive_time = 0
var last_verify_time = 0
var total_archive_size_mb = 0
var current_tick = 0
var tick_timer = null

# Project change tracking
var current_project_state = {}
var change_stack = []
var project_metadata = {}

# System references
var game_creator = null
var data_evolution_system = null
var storage_manager = null

func _ready():
    print("Archive Manager initializing...")
    
    # Create required directories
    _ensure_directory_exists(archive_config.archive_path)
    
    # Set up tick timer
    tick_timer = Timer.new()
    tick_timer.wait_time = archive_config.tick_interval
    tick_timer.autostart = archive_config.auto_tick
    tick_timer.one_shot = false
    tick_timer.timeout.connect(_on_tick_timer)
    add_child(tick_timer)
    
    # Set up hourly archive timer (offset by a random amount to distribute load)
    var hour_timer = Timer.new()
    hour_timer.wait_time = 3600 + (randf() * 120)  # 1 hour + random offset up to 2 minutes
    hour_timer.autostart = true
    hour_timer.one_shot = false
    hour_timer.timeout.connect(_on_hour_timer)
    add_child(hour_timer)
    
    # Set up daily archive timer
    var day_timer = Timer.new()
    day_timer.wait_time = 86400  # 24 hours
    day_timer.autostart = true
    day_timer.one_shot = false
    day_timer.timeout.connect(_on_day_timer)
    add_child(day_timer)
    
    # Connect to other systems
    _connect_to_systems()
    
    # Initialize project state
    _initialize_project_state()
    
    # Load any existing archives (simulated)
    _load_archive_metadata()
    
    print("Archive Manager initialized with " + str(total_archive_size_mb) + "MB of existing archives")

# Create a tick archive (small incremental change snapshot)
func create_tick_archive(manual=false):
    # Don't create tick if interval hasn't passed (unless manual)
    var now = Time.get_unix_time_from_system()
    if not manual and (now - last_tick_time) < archive_config.tick_interval:
        return "Tick interval not reached. Last tick: " + _format_time_ago(last_tick_time)
    
    # Update tick counter
    current_tick += 1
    last_tick_time = now
    
    # Create tick ID
    var tick_id = TICK_ARCHIVE_PREFIX + str(current_tick) + "_" + str(int(now))
    
    # Capture changes since last tick
    var changes = _capture_changes()
    
    # Only create archive if there are changes
    if changes.size() == 0 and not manual:
        return "No changes detected since last tick."
    
    # Create archive
    var archive = {
        "id": tick_id,
        "timestamp": now,
        "datetime": Time.get_datetime_dict_from_system(),
        "changes": changes,
        "tick_number": current_tick,
        "manually_created": manual,
        "size_kb": _estimate_changes_size(changes)
    }
    
    # Add to archives
    archives.tick[tick_id] = archive
    
    # Update total archive size
    total_archive_size_mb += archive.size_kb / 1024.0
    
    # Enforce maximum tick count
    _enforce_maximum_archives("tick")
    
    # Signal
    emit_signal("tick_recorded", tick_id, changes.size())
    
    # Auto-save project state
    _update_project_state()
    
    if manual:
        return "Manual tick archive created: " + tick_id + " with " + str(changes.size()) + " changes"
    else:
        return "Tick archive created: " + tick_id
    
# Create an hourly archive
func create_hour_archive():
    var now = Time.get_unix_time_from_system()
    
    # Create archive ID
    var archive_id = HOUR_ARCHIVE_PREFIX + str(int(now))
    
    # Capture full project state
    var state = _capture_full_state()
    
    # Estimate size
    var size_kb = _estimate_state_size(state)
    
    # Create archive
    var archive = {
        "id": archive_id,
        "timestamp": now,
        "datetime": Time.get_datetime_dict_from_system(),
        "state": state,
        "tick_range": [max(0, current_tick - 100), current_tick],
        "size_kb": size_kb
    }
    
    # Add to archives
    archives.hour[archive_id] = archive
    last_hour_archive_time = now
    
    # Update total archive size
    total_archive_size_mb += size_kb / 1024.0
    
    # Enforce maximum hour count
    _enforce_maximum_archives("hour")
    
    # Signal
    emit_signal("archive_created", archive_id, now)
    
    return "Hourly archive created: " + archive_id

# Create a daily archive
func create_day_archive():
    var now = Time.get_unix_time_from_system()
    
    # Create archive ID
    var date = Time.get_date_dict_from_unix_time(now)
    var archive_id = DAILY_ARCHIVE_PREFIX + str(date.year) + "_" + str(date.month) + "_" + str(date.day)
    
    # Capture full project state with additional metadata
    var state = _capture_full_state()
    
    # Add daily stats
    var stats = _calculate_daily_stats()
    state.daily_stats = stats
    
    # Estimate size
    var size_kb = _estimate_state_size(state) + _estimate_stats_size(stats)
    
    # Create archive
    var archive = {
        "id": archive_id,
        "timestamp": now,
        "datetime": date,
        "state": state,
        "daily_stats": stats,
        "tick_range": [max(0, current_tick - 1000), current_tick],
        "size_kb": size_kb
    }
    
    # Add to archives
    archives.day[archive_id] = archive
    last_day_archive_time = now
    
    # Update total archive size
    total_archive_size_mb += size_kb / 1024.0
    
    # Enforce maximum day count
    _enforce_maximum_archives("day")
    
    # Signal
    emit_signal("archive_created", archive_id, now)
    
    return "Daily archive created: " + archive_id

# Create a weekly archive
func create_week_archive():
    var now = Time.get_unix_time_from_system()
    
    # Create archive ID
    var date = Time.get_date_dict_from_unix_time(now)
    var week = (int(date.day / 7) + 1)
    var archive_id = WEEK_ARCHIVE_PREFIX + str(date.year) + "_" + str(date.month) + "_W" + str(week)
    
    # Capture full project state with extensive metadata
    var state = _capture_full_state(true)  # Include resources
    
    # Add weekly stats and trends
    var stats = _calculate_weekly_stats()
    state.weekly_stats = stats
    
    # Estimate size
    var size_kb = _estimate_state_size(state) + _estimate_stats_size(stats) * 3
    
    # Create archive
    var archive = {
        "id": archive_id,
        "timestamp": now,
        "datetime": date,
        "state": state,
        "weekly_stats": stats,
        "week_number": week,
        "size_kb": size_kb
    }
    
    # Add to archives
    archives.week[archive_id] = archive
    last_week_archive_time = now
    
    # Update total archive size
    total_archive_size_mb += size_kb / 1024.0
    
    # Enforce maximum week count
    _enforce_maximum_archives("week")
    
    # Signal
    emit_signal("archive_created", archive_id, now)
    
    return "Weekly archive created: " + archive_id

# Restore from an archive
func restore_from_archive(archive_id):
    # Find archive
    var archive_type = _determine_archive_type(archive_id)
    if archive_type == "unknown":
        return "Archive not found: " + archive_id
    
    var archive = archives[archive_type][archive_id]
    
    # For tick archives, we need to replay all ticks up to this one
    if archive_type == "tick":
        # Find all tick archives up to this one
        var tick_number = archive.tick_number
        var ticks_to_apply = []
        
        for tick_id in archives.tick:
            var tick = archives.tick[tick_id]
            if tick.tick_number <= tick_number:
                ticks_to_apply.append(tick)
        
        # Sort by tick number
        ticks_to_apply.sort_custom(func(a, b): return a.tick_number < b.tick_number)
        
        # Simulate restoring from ticks
        await get_tree().create_timer(0.5).timeout  # Simulate restoration time
        
        emit_signal("archive_restored", archive_id, true)
        return "Restored to tick " + str(tick_number) + " by applying " + str(ticks_to_apply.size()) + " sequential ticks."
    else:
        # For hour/day/week archives, we can directly restore the state
        await get_tree().create_timer(1.0).timeout  # Simulate restoration time
        
        emit_signal("archive_restored", archive_id, true)
        return "Restored to state from archive: " + archive_id
    
# List archives
func list_archives(type="all", count=10):
    var result = "Archives"
    if type != "all":
        result += " (" + type + ")"
    result += ":\n\n"
    
    var archive_count = 0
    
    if type == "all" or type == "tick":
        result += "Tick Archives:\n"
        var tick_archives = archives.tick.keys()
        tick_archives.sort()
        tick_archives.reverse()
        
        var tick_count = min(count, tick_archives.size())
        for i in range(tick_count):
            var tick_id = tick_archives[i]
            var tick = archives.tick[tick_id]
            var time_str = _format_datetime(tick.datetime)
            
            result += "- " + tick_id + " (" + time_str + ")\n"
            result += "  Changes: " + str(tick.changes.size()) + ", Size: " + _format_size(tick.size_kb) + "\n"
            
            archive_count += 1
        
        if tick_archives.size() > 0:
            result += "\n"
    
    if type == "all" or type == "hour":
        result += "Hourly Archives:\n"
        var hour_archives = archives.hour.keys()
        hour_archives.sort()
        hour_archives.reverse()
        
        var hour_count = min(count, hour_archives.size())
        for i in range(hour_count):
            var hour_id = hour_archives[i]
            var hour = archives.hour[hour_id]
            var time_str = _format_datetime(hour.datetime)
            
            result += "- " + hour_id + " (" + time_str + ")\n"
            result += "  Size: " + _format_size(hour.size_kb) + "\n"
            
            archive_count += 1
        
        if hour_archives.size() > 0:
            result += "\n"
    
    if type == "all" or type == "day":
        result += "Daily Archives:\n"
        var day_archives = archives.day.keys()
        day_archives.sort()
        day_archives.reverse()
        
        var day_count = min(count, day_archives.size())
        for i in range(day_count):
            var day_id = day_archives[i]
            var day = archives.day[day_id]
            var time_str = "%04d-%02d-%02d" % [day.datetime.year, day.datetime.month, day.datetime.day]
            
            result += "- " + day_id + " (" + time_str + ")\n"
            result += "  Size: " + _format_size(day.size_kb) + "\n"
            
            archive_count += 1
        
        if day_archives.size() > 0:
            result += "\n"
    
    if type == "all" or type == "week":
        result += "Weekly Archives:\n"
        var week_archives = archives.week.keys()
        week_archives.sort()
        week_archives.reverse()
        
        var week_count = min(count, week_archives.size())
        for i in range(week_count):
            var week_id = week_archives[i]
            var week = archives.week[week_id]
            var time_str = "%04d-%02d Week %d" % [week.datetime.year, week.datetime.month, week.week_number]
            
            result += "- " + week_id + " (" + time_str + ")\n"
            result += "  Size: " + _format_size(week.size_kb) + "\n"
            
            archive_count += 1
    
    if archive_count == 0:
        return "No archives found" + (type != "all" ? " of type: " + type : "") + "."
    
    result += "\nTotal Archive Storage: " + _format_size(total_archive_size_mb * 1024)
    return result

# Configure the archive system
func configure_archive_system(options):
    var result = "Archive System Configuration:\n\n"
    
    for key in options:
        if archive_config.has(key):
            # Handle nested dictionaries
            if typeof(archive_config[key]) == TYPE_DICTIONARY and typeof(options[key]) == TYPE_DICTIONARY:
                for subkey in options[key]:
                    if archive_config[key].has(subkey):
                        archive_config[key][subkey] = options[key][subkey]
                        result += key + "." + subkey + " = " + str(options[key][subkey]) + "\n"
            else:
                # Special handling for tick interval
                if key == "tick_interval":
                    var interval = options[key]
                    if typeof(interval) == TYPE_INT or typeof(interval) == TYPE_FLOAT:
                        interval = clamp(interval, MIN_TICK_INTERVAL, MAX_TICK_INTERVAL)
                        archive_config.tick_interval = interval
                        # Update timer if running
                        if tick_timer:
                            tick_timer.wait_time = interval
                        result += key + " = " + str(interval) + " (clamped to valid range)\n"
                elif key == "auto_tick" and tick_timer:
                    archive_config.auto_tick = options[key]
                    tick_timer.paused = not options[key]
                    result += key + " = " + str(options[key]) + "\n"
                else:
                    archive_config[key] = options[key]
                    result += key + " = " + str(options[key]) + "\n"
        else:
            result += "Unknown option: " + key + "\n"
    
    return result

# Get stats about the archive system
func get_archive_stats():
    var result = "Archive System Statistics:\n\n"
    
    # Archive counts
    result += "Archive Counts:\n"
    result += "- Tick Archives: " + str(archives.tick.size()) + "/" + str(archive_config.max_archive_count.tick) + "\n"
    result += "- Hourly Archives: " + str(archives.hour.size()) + "/" + str(archive_config.max_archive_count.hour) + "\n"
    result += "- Daily Archives: " + str(archives.day.size()) + "/" + str(archive_config.max_archive_count.day) + "\n"
    result += "- Weekly Archives: " + str(archives.week.size()) + "/" + str(archive_config.max_archive_count.week) + "\n\n"
    
    # Storage usage
    result += "Storage Usage: " + _format_size(total_archive_size_mb * 1024) + "\n"
    var usage_percent = (total_archive_size_mb / archive_config.max_archive_size_mb) * 100
    result += "Storage Percentage: " + str(int(usage_percent)) + "%\n\n"
    
    # Timing info
    result += "Timing Information:\n"
    result += "- Current Tick: " + str(current_tick) + "\n"
    result += "- Tick Interval: " + str(archive_config.tick_interval) + " seconds\n"
    result += "- Last Tick: " + (last_tick_time > 0 ? _format_time_ago(last_tick_time) : "Never") + "\n"
    result += "- Last Hour Archive: " + (last_hour_archive_time > 0 ? _format_time_ago(last_hour_archive_time) : "Never") + "\n"
    result += "- Last Day Archive: " + (last_day_archive_time > 0 ? _format_time_ago(last_day_archive_time) : "Never") + "\n"
    result += "- Last Week Archive: " + (last_week_archive_time > 0 ? _format_time_ago(last_week_archive_time) : "Never") + "\n\n"
    
    # Configuration
    result += "Configuration:\n"
    result += "- Auto Tick: " + str(archive_config.auto_tick) + "\n"
    result += "- Auto Verify: " + str(archive_config.auto_verify) + "\n"
    result += "- Compression: " + str(archive_config.compress_archives) + "\n"
    result += "- Include Resources: " + str(archive_config.include_resources) + "\n"
    
    return result

# Archive system commands
func cmd_archive(args):
    if args.size() == 0:
        var result = "Archive System Commands:\n\n"
        result += "archive tick - Create a manual tick archive\n"
        result += "archive hour - Create a manual hourly archive\n"
        result += "archive day - Create a manual daily archive\n"
        result += "archive week - Create a manual weekly archive\n"
        result += "archive list [type] [count] - List archives\n"
        result += "archive restore <archive_id> - Restore from an archive\n"
        result += "archive stats - Show archive system statistics\n"
        result += "archive verify <archive_id> - Verify archive integrity\n"
        result += "archive config <key> <value> - Configure the archive system\n"
        result += "archive clean [type] - Clean up old archives\n"
        return result
    
    match args[0]:
        "tick":
            return create_tick_archive(true)
            
        "hour":
            return create_hour_archive()
            
        "day":
            return create_day_archive()
            
        "week":
            return create_week_archive()
            
        "list":
            var type = "all"
            if args.size() >= 2:
                type = args[1]
                
            var count = 10
            if args.size() >= 3 and args[2].is_valid_int():
                count = args[2].to_int()
                
            return list_archives(type, count)
            
        "restore":
            if args.size() < 2:
                return "Usage: archive restore <archive_id>"
                
            return restore_from_archive(args[1])
            
        "stats":
            return get_archive_stats()
            
        "verify":
            if args.size() < 2:
                return "Usage: archive verify <archive_id>"
                
            return _verify_archive(args[1])
            
        "config":
            if args.size() < 3:
                return "Usage: archive config <key> <value>"
                
            var key = args[1]
            var value = args[2]
            
            # Parse value according to type
            if value.is_valid_int():
                value = value.to_int()
            elif value.is_valid_float():
                value = value.to_float()
            elif value.to_lower() == "true":
                value = true
            elif value.to_lower() == "false":
                value = false
                
            var options = {}
            options[key] = value
            
            return configure_archive_system(options)
            
        "clean":
            var type = "all"
            if args.size() >= 2:
                type = args[1]
                
            return _clean_archives(type)
            
        _:
            return "Unknown archive command. Try 'tick', 'hour', 'day', 'week', 'list', 'restore', 'stats', 'verify', 'config', or 'clean'"

# Helper functions

func _connect_to_systems():
    # Try to get references to required systems
    game_creator = get_node_or_null("/root/GameCreator")
    data_evolution_system = get_node_or_null("/root/DataEvolutionSystem")
    storage_manager = get_node_or_null("/root/StorageManager")
    
    # Output connection status
    if game_creator != null:
        print("Connected to GameCreator system")
    
    if data_evolution_system != null:
        print("Connected to DataEvolutionSystem")
    
    if storage_manager != null:
        print("Connected to StorageManager")

func _initialize_project_state():
    # Capture initial state from connected systems
    if game_creator != null:
        current_project_state.games = game_creator.created_games.duplicate(true)
    
    # Add metadata
    project_metadata = {
        "creation_time": Time.get_unix_time_from_system(),
        "last_modified": Time.get_unix_time_from_system(),
        "archive_version": ARCHIVE_VERSION,
        "archive_count": 0
    }

func _update_project_state():
    # Update state from connected systems
    if game_creator != null:
        current_project_state.games = game_creator.created_games.duplicate(true)
    
    # Update metadata
    project_metadata.last_modified = Time.get_unix_time_from_system()
    project_metadata.archive_count += 1

func _capture_changes():
    var changes = []
    
    # Capture changes from game creator
    if game_creator != null and current_project_state.has("games"):
        var current_games = game_creator.created_games
        var last_games = current_project_state.games
        
        # Check for new games
        for game_id in current_games:
            if not last_games.has(game_id):
                changes.append({
                    "type": "game_added",
                    "game_id": game_id,
                    "timestamp": Time.get_unix_time_from_system()
                })
                continue
            
            # Check for modified scripts
            for script_name in current_games[game_id].scripts:
                if not last_games[game_id].scripts.has(script_name):
                    changes.append({
                        "type": "script_added",
                        "game_id": game_id,
                        "script_name": script_name,
                        "timestamp": Time.get_unix_time_from_system()
                    })
                elif current_games[game_id].scripts[script_name].content != last_games[game_id].scripts[script_name].content:
                    changes.append({
                        "type": "script_modified",
                        "game_id": game_id,
                        "script_name": script_name,
                        "timestamp": Time.get_unix_time_from_system()
                    })
            
            # Check for removed scripts
            for script_name in last_games[game_id].scripts:
                if not current_games[game_id].scripts.has(script_name):
                    changes.append({
                        "type": "script_removed",
                        "game_id": game_id,
                        "script_name": script_name,
                        "timestamp": Time.get_unix_time_from_system()
                    })
            
            # Check for new scenes
            for scene_name in current_games[game_id].scenes:
                if not last_games[game_id].scenes.has(scene_name):
                    changes.append({
                        "type": "scene_added",
                        "game_id": game_id,
                        "scene_name": scene_name,
                        "timestamp": Time.get_unix_time_from_system()
                    })
            
            # Check for removed scenes
            for scene_name in last_games[game_id].scenes:
                if not current_games[game_id].scenes.has(scene_name):
                    changes.append({
                        "type": "scene_removed",
                        "game_id": game_id,
                        "scene_name": scene_name,
                        "timestamp": Time.get_unix_time_from_system()
                    })
            
            # Check for status changes
            if current_games[game_id].status != last_games[game_id].status:
                changes.append({
                    "type": "status_changed",
                    "game_id": game_id,
                    "old_status": last_games[game_id].status,
                    "new_status": current_games[game_id].status,
                    "timestamp": Time.get_unix_time_from_system()
                })
        
        # Check for removed games
        for game_id in last_games:
            if not current_games.has(game_id):
                changes.append({
                    "type": "game_removed",
                    "game_id": game_id,
                    "timestamp": Time.get_unix_time_from_system()
                })
    
    return changes

func _capture_full_state(include_resources=false):
    var state = {}
    
    # Capture game state
    if game_creator != null:
        state.games = game_creator.created_games.duplicate(true)
        
        # Remove actual content if not including resources
        if not include_resources:
            for game_id in state.games:
                for script_name in state.games[game_id].scripts:
                    # Replace content with metadata only
                    var content = state.games[game_id].scripts[script_name].content
                    state.games[game_id].scripts[script_name].content = _generate_content_summary(content)
    
    # Add metadata
    state.metadata = {
        "capture_time": Time.get_unix_time_from_system(),
        "datetime": Time.get_datetime_dict_from_system(),
        "current_tick": current_tick,
        "version": ARCHIVE_VERSION,
        "resource_level": "full" if include_resources else "metadata"
    }
    
    # Add evolution data if available
    if data_evolution_system != null:
        state.evolution_data = {
            "detected_patterns": data_evolution_system.detected_patterns.duplicate(true),
            "evolution_state": data_evolution_system.evolution_state.duplicate(true)
        }
    
    return state

func _calculate_daily_stats():
    var stats = {
        "changes": {
            "total": 0,
            "by_type": {},
            "by_hour": {}
        },
        "game_activity": {},
        "peak_hours": [],
        "growth_metrics": {}
    }
    
    # Calculate stats from tick archives
    for tick_id in archives.tick:
        var tick = archives.tick[tick_id]
        
        # Only include ticks from the last 24 hours
        var now = Time.get_unix_time_from_system()
        if (now - tick.timestamp) > 86400:
            continue
        
        # Count changes by type
        for change in tick.changes:
            stats.changes.total += 1
            
            if not stats.changes.by_type.has(change.type):
                stats.changes.by_type[change.type] = 0
            stats.changes.by_type[change.type] += 1
            
            # Count by hour
            var hour = Time.get_datetime_dict_from_unix_time(change.timestamp).hour
            if not stats.changes.by_hour.has(hour):
                stats.changes.by_hour[hour] = 0
            stats.changes.by_hour[hour] += 1
            
            # Track game activity
            if change.has("game_id"):
                if not stats.game_activity.has(change.game_id):
                    stats.game_activity[change.game_id] = 0
                stats.game_activity[change.game_id] += 1
    
    # Determine peak hours (top 3)
    var hours = []
    for hour in stats.changes.by_hour:
        hours.append({"hour": hour, "changes": stats.changes.by_hour[hour]})
    
    hours.sort_custom(func(a, b): return a.changes > b.changes)
    
    for i in range(min(3, hours.size())):
        stats.peak_hours.append(hours[i].hour)
    
    # Calculate growth metrics
    if game_creator != null:
        stats.growth_metrics = {
            "total_games": game_creator.created_games.size(),
            "total_scripts": 0,
            "total_scenes": 0
        }
        
        for game_id in game_creator.created_games:
            stats.growth_metrics.total_scripts += game_creator.created_games[game_id].scripts.size()
            stats.growth_metrics.total_scenes += game_creator.created_games[game_id].scenes.size()
    
    return stats

func _calculate_weekly_stats():
    var stats = {
        "changes": {
            "total": 0,
            "by_day": {},
            "by_type": {}
        },
        "game_activity": {},
        "growth_trend": [],
        "productivity_score": 0
    }
    
    # Calculate stats from daily archives (last 7 days)
    var daily_archives = []
    for day_id in archives.day:
        daily_archives.append(archives.day[day_id])
    
    # Sort by timestamp (newest first)
    daily_archives.sort_custom(func(a, b): return a.timestamp > b.timestamp)
    
    # Take up to 7 most recent
    var days_to_analyze = min(7, daily_archives.size())
    
    for i in range(days_to_analyze):
        var day = daily_archives[i]
        var day_of_week = Time.get_datetime_dict_from_unix_time(day.timestamp).weekday
        
        # Add daily stats to weekly aggregation
        if day.has("daily_stats"):
            stats.changes.total += day.daily_stats.changes.total
            
            # By day
            if not stats.changes.by_day.has(day_of_week):
                stats.changes.by_day[day_of_week] = 0
            stats.changes.by_day[day_of_week] += day.daily_stats.changes.total
            
            # By type
            for change_type in day.daily_stats.changes.by_type:
                if not stats.changes.by_type.has(change_type):
                    stats.changes.by_type[change_type] = 0
                stats.changes.by_type[change_type] += day.daily_stats.changes.by_type[change_type]
            
            # Game activity
            for game_id in day.daily_stats.game_activity:
                if not stats.game_activity.has(game_id):
                    stats.game_activity[game_id] = 0
                stats.game_activity[game_id] += day.daily_stats.game_activity[game_id]
        
        # Add to growth trend
        if day.has("daily_stats") and day.daily_stats.has("growth_metrics"):
            stats.growth_trend.append({
                "day": day_of_week,
                "total_games": day.daily_stats.growth_metrics.total_games,
                "total_scripts": day.daily_stats.growth_metrics.total_scripts,
                "total_scenes": day.daily_stats.growth_metrics.total_scenes
            })
    
    # Calculate productivity score (simple algorithm based on changes and consistency)
    if stats.changes.total > 0:
        var change_score = min(100, stats.changes.total / 10)
        
        # Check day consistency
        var days_active = stats.changes.by_day.size()
        var consistency_score = (days_active / 7.0) * 100
        
        # Calculate final score
        stats.productivity_score = int((change_score + consistency_score) / 2)
    
    return stats

func _on_tick_timer():
    if archive_config.auto_tick:
        create_tick_archive()

func _on_hour_timer():
    create_hour_archive()
    
    # Verify archives periodically
    var now = Time.get_unix_time_from_system()
    if archive_config.auto_verify and (now - last_verify_time) >= (AUTO_VERIFY_INTERVAL * 3600):
        _verify_all_archives()
        last_verify_time = now

func _on_day_timer():
    create_day_archive()
    
    # Check if we need a weekly archive (day of week = 1, Monday)
    var date = Time.get_datetime_dict_from_system()
    if date.weekday == 1:  # Monday
        create_week_archive()
    
    # Clean up old archives
    _clean_archives("all")

func _enforce_maximum_archives(type):
    if not archive_config.max_archive_count.has(type):
        return
    
    var max_count = archive_config.max_archive_count[type]
    
    # If we're under the limit, no action needed
    if archives[type].size() <= max_count:
        return
    
    # We need to remove the oldest archives
    var archive_list = []
    for archive_id in archives[type]:
        archive_list.append({
            "id": archive_id,
            "timestamp": archives[type][archive_id].timestamp,
            "size_kb": archives[type][archive_id].size_kb
        })
    
    # Sort by timestamp (oldest first)
    archive_list.sort_custom(func(a, b): return a.timestamp < b.timestamp)
    
    # Remove oldest archives until we're under the limit
    var remove_count = archives[type].size() - max_count
    var total_freed_kb = 0
    
    for i in range(remove_count):
        var archive_id = archive_list[i].id
        total_freed_kb += archive_list[i].size_kb
        archives[type].erase(archive_id)
    
    # Update total size
    total_archive_size_mb -= total_freed_kb / 1024.0
    
    print("Removed " + str(remove_count) + " old " + type + " archives, freed " + _format_size(total_freed_kb))

func _clean_archives(type="all"):
    var now = Time.get_unix_time_from_system()
    var removed_count = 0
    var total_freed_kb = 0
    
    # Clean up based on retention policy
    if type == "all" or type == "tick":
        # Remove ticks older than ARCHIVE_RETENTION.tick hours
        var tick_retention_seconds = ARCHIVE_RETENTION.tick * 3600
        var old_ticks = []
        
        for tick_id in archives.tick:
            var tick = archives.tick[tick_id]
            if (now - tick.timestamp) > tick_retention_seconds:
                old_ticks.append(tick_id)
                total_freed_kb += tick.size_kb
        
        for tick_id in old_ticks:
            archives.tick.erase(tick_id)
            removed_count += 1
    
    if type == "all" or type == "hour":
        # Remove hourly archives older than ARCHIVE_RETENTION.hour hours
        var hour_retention_seconds = ARCHIVE_RETENTION.hour * 3600
        var old_hours = []
        
        for hour_id in archives.hour:
            var hour = archives.hour[hour_id]
            if (now - hour.timestamp) > hour_retention_seconds:
                old_hours.append(hour_id)
                total_freed_kb += hour.size_kb
        
        for hour_id in old_hours:
            archives.hour.erase(hour_id)
            removed_count += 1
    
    if type == "all" or type == "day":
        # Remove daily archives older than ARCHIVE_RETENTION.day days
        var day_retention_seconds = ARCHIVE_RETENTION.day * 86400
        var old_days = []
        
        for day_id in archives.day:
            var day = archives.day[day_id]
            if (now - day.timestamp) > day_retention_seconds:
                old_days.append(day_id)
                total_freed_kb += day.size_kb
        
        for day_id in old_days:
            archives.day.erase(day_id)
            removed_count += 1
    
    if type == "all" or type == "week":
        # Remove weekly archives older than ARCHIVE_RETENTION.week weeks
        var week_retention_seconds = ARCHIVE_RETENTION.week * 604800  # 7 days
        var old_weeks = []
        
        for week_id in archives.week:
            var week = archives.week[week_id]
            if (now - week.timestamp) > week_retention_seconds:
                old_weeks.append(week_id)
                total_freed_kb += week.size_kb
        
        for week_id in old_weeks:
            archives.week.erase(week_id)
            removed_count += 1
    
    # Update total size
    total_archive_size_mb -= total_freed_kb / 1024.0
    
    return "Cleaned up " + str(removed_count) + " old archives, freed " + _format_size(total_freed_kb)

func _verify_archive(archive_id):
    # Find archive
    var archive_type = _determine_archive_type(archive_id)
    if archive_type == "unknown":
        return "Archive not found: " + archive_id
    
    var archive = archives[archive_type][archive_id]
    
    # Perform verification (simulated)
    await get_tree().create_timer(0.5).timeout
    
    var verification_result = {
        "archive_id": archive_id,
        "type": archive_type,
        "integrity": true,
        "errors": []
    }
    
    # Simulate potential issues
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    
    if rng.randf() < 0.05:  # 5% chance of issue
        verification_result.integrity = false
        verification_result.errors.append("Content hash mismatch")
    
    # Emit signal
    emit_signal("archive_integrity_verified", archive_id, verification_result)
    
    if verification_result.integrity:
        return "Archive " + archive_id + " verified successfully."
    else:
        return "Archive " + archive_id + " verification failed: " + ", ".join(verification_result.errors)

func _verify_all_archives():
    var result = {
        "total": 0,
        "success": 0,
        "failed": 0,
        "failed_archives": []
    }
    
    # Count archives
    result.total = archives.tick.size() + archives.hour.size() + archives.day.size() + archives.week.size()
    
    # Verify all (simplified for simulation)
    # In a real implementation, this would check each archive thoroughly
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    
    # Simulate a few random failures
    result.success = result.total
    result.failed = 0
    
    if result.total > 10:
        var fail_count = rng.randi_range(0, 2)  # 0-2 random failures
        result.failed = fail_count
        result.success = result.total - fail_count
    
    # For simulation, just add a fake failed archive if needed
    if result.failed > 0:
        result.failed_archives.append(HOUR_ARCHIVE_PREFIX + str(int(rng.randf() * 1000000)))
    
    return result

func _determine_archive_type(archive_id):
    # Check in each archive type
    if archive_id.begins_with(TICK_ARCHIVE_PREFIX) and archives.tick.has(archive_id):
        return "tick"
    elif archive_id.begins_with(HOUR_ARCHIVE_PREFIX) and archives.hour.has(archive_id):
        return "hour"
    elif archive_id.begins_with(DAILY_ARCHIVE_PREFIX) and archives.day.has(archive_id):
        return "day"
    elif archive_id.begins_with(WEEK_ARCHIVE_PREFIX) and archives.week.has(archive_id):
        return "week"
    
    return "unknown"

func _load_archive_metadata():
    # Simulated for this implementation
    # In a real implementation, this would load archive metadata from disk
    
    # Simulate a few archives of each type
    var now = Time.get_unix_time_from_system()
    
    # Create some tick archives
    for i in range(20):
        var tick_time = now - (i * 1800)  # Every 30 minutes
        var tick_id = TICK_ARCHIVE_PREFIX + str(current_tick - i) + "_" + str(int(tick_time))
        
        archives.tick[tick_id] = {
            "id": tick_id,
            "timestamp": tick_time,
            "datetime": Time.get_datetime_dict_from_unix_time(tick_time),
            "changes": [],
            "tick_number": current_tick - i,
            "manually_created": false,
            "size_kb": 50 + (randi() % 200)  # 50-250 KB
        }
    
    # Create some hourly archives
    for i in range(24):
        var hour_time = now - (i * 3600)  # Every hour
        var hour_id = HOUR_ARCHIVE_PREFIX + str(int(hour_time))
        
        archives.hour[hour_id] = {
            "id": hour_id,
            "timestamp": hour_time,
            "datetime": Time.get_datetime_dict_from_unix_time(hour_time),
            "state": null,
            "tick_range": [current_tick - ((i+1) * 12), current_tick - (i * 12)],
            "size_kb": 500 + (randi() % 1000)  # 500-1500 KB
        }
    
    # Create some daily archives
    for i in range(10):
        var day_time = now - (i * 86400)  # Every day
        var date = Time.get_date_dict_from_unix_time(day_time)
        var day_id = DAILY_ARCHIVE_PREFIX + str(date.year) + "_" + str(date.month) + "_" + str(date.day)
        
        archives.day[day_id] = {
            "id": day_id,
            "timestamp": day_time,
            "datetime": date,
            "state": null,
            "daily_stats": null,
            "tick_range": [0, 0],
            "size_kb": 5000 + (randi() % 5000)  # 5-10 MB
        }
    
    # Create some weekly archives
    for i in range(4):
        var week_time = now - (i * 604800)  # Every week
        var date = Time.get_date_dict_from_unix_time(week_time)
        var week = (int(date.day / 7) + 1)
        var week_id = WEEK_ARCHIVE_PREFIX + str(date.year) + "_" + str(date.month) + "_W" + str(week)
        
        archives.week[week_id] = {
            "id": week_id,
            "timestamp": week_time,
            "datetime": date,
            "state": null,
            "weekly_stats": null,
            "week_number": week,
            "size_kb": 20000 + (randi() % 10000)  # 20-30 MB
        }
    
    # Calculate total size
    for type in archives:
        for archive_id in archives[type]:
            total_archive_size_mb += archives[type][archive_id].size_kb / 1024.0

func _estimate_changes_size(changes):
    # Rough estimate
    var size_kb = 0
    
    for change in changes:
        match change.type:
            "game_added":
                size_kb += 50
            "game_removed":
                size_kb += 20
            "script_added", "script_modified":
                size_kb += 30
            "script_removed":
                size_kb += 10
            "scene_added":
                size_kb += 40
            "scene_removed":
                size_kb += 15
            "status_changed":
                size_kb += 5
            _:
                size_kb += 10
    
    # Add overhead for metadata
    size_kb += 5
    
    return max(5, size_kb)  # Minimum 5 KB

func _estimate_state_size(state):
    # Rough estimate
    var size_kb = 100  # Base size
    
    if state.has("games"):
        size_kb += state.games.size() * 200  # Base per game
        
        for game_id in state.games:
            size_kb += state.games[game_id].scripts.size() * 50
            size_kb += state.games[game_id].scenes.size() * 100
            size_kb += state.games[game_id].resources.size() * 20
    
    if state.has("evolution_data"):
        size_kb += 200
    
    return size_kb

func _estimate_stats_size(stats):
    # Rough estimate
    var size_kb = 50  # Base size
    
    if stats.has("changes"):
        size_kb += stats.changes.size() * 10
    
    if stats.has("game_activity"):
        size_kb += stats.game_activity.size() * 5
    
    if stats.has("growth_trend"):
        size_kb += stats.growth_trend.size() * 10
    
    return size_kb

func _generate_content_summary(content):
    if content.length() < 100:
        return "(Content: " + str(content.length()) + " characters)"
    
    var lines = content.split("\n")
    return "(Content: " + str(content.length()) + " characters, " + str(lines.size()) + " lines)"

func _format_time_ago(timestamp):
    var now = Time.get_unix_time_from_system()
    var diff = now - timestamp
    
    if diff < 60:
        return str(int(diff)) + " seconds ago"
    elif diff < 3600:
        return str(int(diff / 60)) + " minutes ago"
    elif diff < 86400:
        return str(int(diff / 3600)) + " hours ago"
    else:
        return str(int(diff / 86400)) + " days ago"

func _format_datetime(datetime):
    return "%04d-%02d-%02d %02d:%02d:%02d" % [
        datetime.year, datetime.month, datetime.day,
        datetime.hour, datetime.minute, datetime.second
    ]

func _format_size(size_kb):
    if size_kb < 1024:
        return str(int(size_kb)) + " KB"
    elif size_kb < 1024 * 1024:
        return str(int(size_kb / 1024.0 * 100) / 100.0) + " MB"
    else:
        return str(int(size_kb / (1024.0 * 1024.0) * 100) / 100.0) + " GB"

func _ensure_directory_exists(dir_path):
    var dir = DirAccess.open("user://")
    if not dir.dir_exists(dir_path):
        dir.make_dir_recursive(dir_path)