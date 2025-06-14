extends Node

class_name StorageManager

# Storage Manager for LuminusOS
# Handles large-scale storage operations, optimization, and access for games and data

signal storage_allocated(game_id, size_mb)
signal storage_threshold_reached(current_percent, threshold_percent)
signal storage_optimized(space_saved_mb)
signal backup_created(backup_id, size_mb)
signal storage_stats_updated(stats)

# Constants
const MAX_STORAGE_CAPACITY = 2048000  # 2TB in MB
const WARNING_THRESHOLD = 0.75  # 75% capacity warning
const CRITICAL_THRESHOLD = 0.9  # 90% capacity critical
const OPTIMIZATION_THRESHOLD = 0.8  # 80% triggers optimization
const DEFAULT_GAME_ALLOCATION = 5000  # 5GB in MB

# Storage structure
var storage_stats = {
    "total_capacity_mb": MAX_STORAGE_CAPACITY,
    "used_mb": 0,
    "available_mb": MAX_STORAGE_CAPACITY,
    "percent_used": 0.0,
    "allocated": {
        "games": {},
        "backups": {},
        "system": 1024,  # 1GB for system
        "cache": 2048,   # 2GB for cache
        "temp": 1024,    # 1GB for temporary files
        "user_data": 512 # 512MB for user data
    },
    "usage_history": []
}

# Storage allocation table
var allocations = {}

# Backup registry
var backups = {}

# Paths
var storage_path = "user://storage/"
var games_path = "user://storage/games/"
var backups_path = "user://storage/backups/"

# Initialization
func _ready():
    print("Storage Manager initializing...")
    
    # Create required directories
    _ensure_directory_exists(storage_path)
    _ensure_directory_exists(games_path)
    _ensure_directory_exists(backups_path)
    
    # Initialize storage stats tracking
    _initialize_storage_stats()
    
    # Set up periodic checks
    var timer = Timer.new()
    timer.wait_time = 300  # Check every 5 minutes
    timer.autostart = true
    timer.one_shot = false
    timer.timeout.connect(_on_storage_check_timer)
    add_child(timer)
    
    # Daily stats recording timer
    var stats_timer = Timer.new()
    stats_timer.wait_time = 86400  # Once a day
    stats_timer.autostart = true
    stats_timer.one_shot = false
    stats_timer.timeout.connect(_on_daily_stats_recording)
    add_child(stats_timer)
    
    print("Storage Manager initialized with capacity: " + format_size(MAX_STORAGE_CAPACITY))

# Allocate storage for a new game
func allocate_game_storage(game_id, size_mb=DEFAULT_GAME_ALLOCATION):
    # Check if already allocated
    if allocations.has(game_id):
        return "Storage already allocated for " + game_id + ": " + format_size(allocations[game_id].size_mb)
    
    # Check available space
    if storage_stats.available_mb < size_mb:
        return "ERROR: Insufficient storage. Available: " + format_size(storage_stats.available_mb)
    
    # Create game directory
    var game_path = games_path + game_id + "/"
    _ensure_directory_exists(game_path)
    
    # Create allocation record
    allocations[game_id] = {
        "size_mb": size_mb,
        "path": game_path,
        "allocated_time": Time.get_unix_time_from_system(),
        "usage_mb": 0,
        "last_accessed": Time.get_unix_time_from_system(),
        "backup_policy": "daily",
        "retention_days": 30
    }
    
    # Update storage stats
    storage_stats.allocated.games[game_id] = size_mb
    _update_storage_stats()
    
    emit_signal("storage_allocated", game_id, size_mb)
    
    return "Storage allocated for " + game_id + ": " + format_size(size_mb)

# Resize allocated storage for a game
func resize_game_storage(game_id, new_size_mb):
    if not allocations.has(game_id):
        return "ERROR: No allocation found for " + game_id
    
    var current_size = allocations[game_id].size_mb
    var size_diff = new_size_mb - current_size
    
    if size_diff > 0 and storage_stats.available_mb < size_diff:
        return "ERROR: Insufficient storage for resize. Need " + format_size(size_diff) + " more"
    
    # Update allocation
    allocations[game_id].size_mb = new_size_mb
    
    # Update storage stats
    storage_stats.allocated.games[game_id] = new_size_mb
    _update_storage_stats()
    
    return "Storage resized for " + game_id + ": " + format_size(current_size) + " → " + format_size(new_size_mb)

# Create a backup of a game
func create_game_backup(game_id, label=""):
    if not allocations.has(game_id):
        return "ERROR: No allocation found for " + game_id
    
    var backup_id = game_id + "_" + str(Time.get_unix_time_from_system())
    if label != "":
        backup_id += "_" + label
    
    var game_size = allocations[game_id].usage_mb
    
    # Check available space
    if storage_stats.available_mb < game_size:
        return "ERROR: Insufficient storage for backup. Need " + format_size(game_size)
    
    # Create backup directory
    var backup_path = backups_path + backup_id + "/"
    _ensure_directory_exists(backup_path)
    
    # Create backup record
    backups[backup_id] = {
        "game_id": game_id,
        "backup_time": Time.get_unix_time_from_system(),
        "size_mb": game_size,
        "path": backup_path,
        "label": label,
        "retention_days": allocations[game_id].retention_days
    }
    
    # Update storage stats
    if not storage_stats.allocated.backups.has(game_id):
        storage_stats.allocated.backups[game_id] = 0
    storage_stats.allocated.backups[game_id] += game_size
    _update_storage_stats()
    
    emit_signal("backup_created", backup_id, game_size)
    
    return "Backup created: " + backup_id + " (" + format_size(game_size) + ")"

# Get storage stats
func get_storage_stats():
    _update_storage_stats()
    
    var result = "Storage Statistics:\n\n"
    
    # Main stats
    result += "Total Capacity: " + format_size(storage_stats.total_capacity_mb) + "\n"
    result += "Used: " + format_size(storage_stats.used_mb) + " (" + str(int(storage_stats.percent_used * 100)) + "%)\n"
    result += "Available: " + format_size(storage_stats.available_mb) + "\n\n"
    
    # Show warnings if needed
    if storage_stats.percent_used >= CRITICAL_THRESHOLD:
        result += "⚠️ CRITICAL: Storage usage is very high! Optimization required.\n\n"
    elif storage_stats.percent_used >= WARNING_THRESHOLD:
        result += "⚠️ WARNING: Storage usage is high. Consider cleanup.\n\n"
    
    # Allocation breakdown
    result += "Storage Allocation:\n"
    
    # System allocations
    result += "- System: " + format_size(storage_stats.allocated.system) + "\n"
    result += "- Cache: " + format_size(storage_stats.allocated.cache) + "\n"
    result += "- Temp: " + format_size(storage_stats.allocated.temp) + "\n"
    result += "- User Data: " + format_size(storage_stats.allocated.user_data) + "\n"
    
    # Games allocations
    var total_games_allocation = 0
    result += "\nGames:\n"
    for game_id in storage_stats.allocated.games:
        result += "- " + game_id + ": " + format_size(storage_stats.allocated.games[game_id]) + "\n"
        total_games_allocation += storage_stats.allocated.games[game_id]
    result += "Total Games: " + format_size(total_games_allocation) + "\n"
    
    # Backup allocations
    var total_backups_allocation = 0
    result += "\nBackups:\n"
    for game_id in storage_stats.allocated.backups:
        result += "- " + game_id + ": " + format_size(storage_stats.allocated.backups[game_id]) + "\n"
        total_backups_allocation += storage_stats.allocated.backups[game_id]
    result += "Total Backups: " + format_size(total_backups_allocation) + "\n"
    
    return result

# List all backups for a game
func list_game_backups(game_id):
    if not allocations.has(game_id):
        return "ERROR: No allocation found for " + game_id
    
    var result = "Backups for " + game_id + ":\n\n"
    var game_backups = []
    
    # Find all backups for this game
    for backup_id in backups:
        if backups[backup_id].game_id == game_id:
            game_backups.append(backups[backup_id])
    
    if game_backups.size() == 0:
        return "No backups found for " + game_id
    
    # Sort by backup time (newest first)
    game_backups.sort_custom(func(a, b): return a.backup_time > b.backup_time)
    
    # Format the list
    for backup in game_backups:
        var backup_time = Time.get_datetime_string_from_unix_time(backup.backup_time)
        var label_text = "" if backup.label.is_empty() else " - " + backup.label
        
        result += "- " + backup_time + label_text + " (" + format_size(backup.size_mb) + ")\n"
        result += "  ID: " + backup_id + "\n"
    
    return result

# Optimize storage usage
func optimize_storage():
    var result = "Storage Optimization:\n\n"
    var space_saved = 0
    
    # Check if optimization is needed
    if storage_stats.percent_used < OPTIMIZATION_THRESHOLD:
        return "Optimization not necessary. Current usage: " + str(int(storage_stats.percent_used * 100)) + "%"
    
    # 1. Clean up old backups
    result += "Cleaning up old backups...\n"
    var removed_backups = []
    var now = Time.get_unix_time_from_system()
    
    for backup_id in backups:
        var backup = backups[backup_id]
        var backup_age_days = (now - backup.backup_time) / 86400.0
        
        # Remove if older than retention period
        if backup_age_days > backup.retention_days:
            space_saved += backup.size_mb
            removed_backups.append(backup_id)
            
            if storage_stats.allocated.backups.has(backup.game_id):
                storage_stats.allocated.backups[backup.game_id] -= backup.size_mb
    
    # Remove the backups
    for backup_id in removed_backups:
        backups.erase(backup_id)
    
    result += "Removed " + str(removed_backups.size()) + " old backups\n"
    
    # 2. Clean up cache
    var cache_to_free = storage_stats.allocated.cache * 0.5  # Free up 50% of cache
    storage_stats.allocated.cache -= cache_to_free
    space_saved += cache_to_free
    result += "Cleared " + format_size(cache_to_free) + " from cache\n"
    
    # 3. Clean up temp files
    var temp_to_free = storage_stats.allocated.temp * 0.75  # Free up 75% of temp
    storage_stats.allocated.temp -= temp_to_free
    space_saved += temp_to_free
    result += "Cleared " + format_size(temp_to_free) + " from temporary files\n"
    
    # Update stats
    _update_storage_stats()
    
    emit_signal("storage_optimized", space_saved)
    
    result += "\nTotal space saved: " + format_size(space_saved) + "\n"
    result += "New usage: " + str(int(storage_stats.percent_used * 100)) + "%"
    
    return result

# Process storage manager commands
func cmd_storage(args):
    if args.size() == 0:
        var result = "Storage Manager Commands:\n\n"
        result += "storage stats - Show storage statistics\n"
        result += "storage allocate <game_id> [size_mb] - Allocate storage for a game\n"
        result += "storage resize <game_id> <new_size_mb> - Change allocated storage size\n"
        result += "storage backup <game_id> [label] - Create a backup\n"
        result += "storage backups <game_id> - List backups for a game\n"
        result += "storage optimize - Run storage optimization\n"
        result += "storage history - Show usage history\n"
        return result
    
    match args[0]:
        "stats":
            return get_storage_stats()
            
        "allocate":
            if args.size() < 2:
                return "Usage: storage allocate <game_id> [size_mb]"
                
            var size = DEFAULT_GAME_ALLOCATION
            if args.size() >= 3 and args[2].is_valid_int():
                size = args[2].to_int()
                
            return allocate_game_storage(args[1], size)
            
        "resize":
            if args.size() < 3 or not args[2].is_valid_int():
                return "Usage: storage resize <game_id> <new_size_mb>"
                
            return resize_game_storage(args[1], args[2].to_int())
            
        "backup":
            if args.size() < 2:
                return "Usage: storage backup <game_id> [label]"
                
            var label = ""
            if args.size() >= 3:
                label = args[2]
                
            return create_game_backup(args[1], label)
            
        "backups":
            if args.size() < 2:
                return "Usage: storage backups <game_id>"
                
            return list_game_backups(args[1])
            
        "optimize":
            return optimize_storage()
            
        "history":
            return _get_storage_history()
            
        _:
            return "Unknown storage command. Try 'stats', 'allocate', 'resize', 'backup', 'backups', 'optimize', or 'history'"

# Helper functions
func _initialize_storage_stats():
    storage_stats.used_mb = storage_stats.allocated.system + storage_stats.allocated.cache + 
                            storage_stats.allocated.temp + storage_stats.allocated.user_data
    storage_stats.available_mb = storage_stats.total_capacity_mb - storage_stats.used_mb
    storage_stats.percent_used = storage_stats.used_mb / float(storage_stats.total_capacity_mb)
    
    # Initialize history with current point
    _record_usage_history()

func _update_storage_stats():
    # Calculate total usage
    var total_used = storage_stats.allocated.system + storage_stats.allocated.cache + 
                     storage_stats.allocated.temp + storage_stats.allocated.user_data
    
    # Add game allocations
    for game_id in storage_stats.allocated.games:
        total_used += storage_stats.allocated.games[game_id]
    
    # Add backup allocations
    for game_id in storage_stats.allocated.backups:
        total_used += storage_stats.allocated.backups[game_id]
    
    # Update stats
    storage_stats.used_mb = total_used
    storage_stats.available_mb = storage_stats.total_capacity_mb - total_used
    storage_stats.percent_used = total_used / float(storage_stats.total_capacity_mb)
    
    # Check thresholds
    if storage_stats.percent_used >= CRITICAL_THRESHOLD:
        emit_signal("storage_threshold_reached", storage_stats.percent_used, CRITICAL_THRESHOLD)
    elif storage_stats.percent_used >= WARNING_THRESHOLD:
        emit_signal("storage_threshold_reached", storage_stats.percent_used, WARNING_THRESHOLD)
    
    # Update signal
    emit_signal("storage_stats_updated", storage_stats)

func _on_storage_check_timer():
    _update_storage_stats()
    
    # Auto-optimize if needed
    if storage_stats.percent_used >= OPTIMIZATION_THRESHOLD:
        optimize_storage()

func _on_daily_stats_recording():
    _record_usage_history()

func _record_usage_history():
    var history_point = {
        "timestamp": Time.get_unix_time_from_system(),
        "datetime": Time.get_datetime_dict_from_system(),
        "used_mb": storage_stats.used_mb,
        "percent_used": storage_stats.percent_used,
        "game_count": storage_stats.allocated.games.size(),
        "backup_count": backups.size()
    }
    
    storage_stats.usage_history.append(history_point)
    
    # Limit history size
    if storage_stats.usage_history.size() > 90:  # Keep 90 days
        storage_stats.usage_history.remove_at(0)

func _get_storage_history():
    var result = "Storage Usage History:\n\n"
    
    if storage_stats.usage_history.size() == 0:
        return "No history data available yet."
    
    # Show last 10 history points
    var start_idx = max(0, storage_stats.usage_history.size() - 10)
    
    for i in range(start_idx, storage_stats.usage_history.size()):
        var point = storage_stats.usage_history[i]
        var date = point.datetime
        var date_str = "%04d-%02d-%02d" % [date.year, date.month, date.day]
        
        result += "- " + date_str + ": " + format_size(point.used_mb) + " (" + str(int(point.percent_used * 100)) + "%)\n"
        result += "  Games: " + str(point.game_count) + ", Backups: " + str(point.backup_count) + "\n"
    
    # Show growth rate
    if storage_stats.usage_history.size() >= 2:
        var first = storage_stats.usage_history[0]
        var last = storage_stats.usage_history.back()
        var days_diff = (last.timestamp - first.timestamp) / 86400.0
        
        if days_diff > 0:
            var growth_mb = last.used_mb - first.used_mb
            var daily_growth = growth_mb / days_diff
            
            result += "\nAverage Daily Growth: " + format_size(daily_growth) + "\n"
            
            # Projection to full
            if daily_growth > 0:
                var days_to_full = (storage_stats.total_capacity_mb - last.used_mb) / daily_growth
                result += "Estimated Days Until Full: " + str(int(days_to_full)) + "\n"
    
    return result

func _ensure_directory_exists(dir_path):
    var dir = DirAccess.open("user://")
    if not dir.dir_exists(dir_path):
        dir.make_dir_recursive(dir_path)

func format_size(size_mb):
    if size_mb < 1024:
        return str(int(size_mb)) + " MB"
    elif size_mb < 1024 * 1024:
        return str(int(size_mb / 1024.0 * 100) / 100.0) + " GB"
    else:
        return str(int(size_mb / (1024.0 * 1024.0) * 100) / 100.0) + " TB"