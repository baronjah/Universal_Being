extends Node

class_name MemoryDiarySystem

# Memory Diary System
# Manages memory entries across multiple Claude accounts and creates a unified diary

# Configuration
var config = {
    "diary_root": "/mnt/c/Users/Percision 15/memory/diary",
    "claude_accounts": {
        "normal": {
            "path": "/mnt/c/Users/Percision 15/memory/claude/normal",
            "active": true
        },
        "max": {
            "path": "/mnt/c/Users/Percision 15/memory/claude/max",
            "active": true
        }
    },
    "memory_paths": {
        "primary": "/mnt/c/Users/Percision 15/memory",
        "secondary": "/mnt/c/Users/Percision 15/OneDrive/memory",
        "tertiary": "/mnt/d/memory_backup"
    },
    "diary_format": {
        "date_format": "%Y-%m-%d",
        "time_format": "%H:%M:%S",
        "entry_template": "[{date} {time}] [{account}] {content}"
    }
}

# Memory state tracking
var memory_entries = []
var diary_entries = []
var account_states = {}
var last_sync_time = 0

# References to other components
var terminal = null
var visualizer = null
var external_connections = null

# Signals
signal entry_added(entry_data)
signal diary_updated(entry_count)
signal accounts_synced(account_name)

# Initialize memory diary system
func _ready():
    # Ensure directories exist
    _ensure_directories()
    
    # Load existing entries
    load_all_entries()
    
    # Initialize account states
    for account in config.claude_accounts:
        account_states[account] = {
            "connected": config.claude_accounts[account].active,
            "entries": 0,
            "last_entry": 0
        }
    
    # Set last sync time
    last_sync_time = OS.get_unix_time()

# Connect to terminal
func connect_terminal(term):
    terminal = term
    
    # Register commands
    terminal.register_command("diary", "Manage memory diary", funcref(self, "_cmd_diary"), 1, "diary <subcommand> [args]")
    terminal.register_command("account", "Manage Claude accounts", funcref(self, "_cmd_account"), 1, "account <subcommand> [args]")
    terminal.register_command("entry", "Add or view memory entries", funcref(self, "_cmd_entry"), 1, "entry <subcommand> [args]")
    terminal.register_command("merge", "Merge entries from multiple accounts", funcref(self, "_cmd_merge"), 0, "merge [account1] [account2]")
    
    return true

# Connect to visualizer
func connect_visualizer(vis):
    visualizer = vis
    
    # Register data source
    visualizer.register_data_source("diary", "Memory Diary", funcref(self, "_get_diary_data"))
    
    return true

# Connect to external connections system
func connect_external(ext):
    external_connections = ext
    return true

# Ensure required directories exist
func _ensure_directories():
    var dir = Directory.new()
    
    # Create diary root
    if not dir.dir_exists(config.diary_root):
        dir.make_dir_recursive(config.diary_root)
    
    # Create account directories
    for account in config.claude_accounts:
        var account_path = config.claude_accounts[account].path
        if not dir.dir_exists(account_path):
            dir.make_dir_recursive(account_path)
    
    # Create memory path directories
    for key in config.memory_paths:
        var memory_path = config.memory_paths[key]
        if not dir.dir_exists(memory_path):
            dir.make_dir_recursive(memory_path)

# Load all memory entries from disk
func load_all_entries():
    memory_entries.clear()
    diary_entries.clear()
    
    # Load entries from each account
    for account in config.claude_accounts:
        var account_entries = _load_account_entries(account)
        
        # Track entry count
        if account_states.has(account):
            account_states[account].entries = account_entries.size()
            
            if account_entries.size() > 0:
                account_states[account].last_entry = account_entries.back().timestamp
    
    # Load main diary entries
    _load_diary_entries()
    
    return memory_entries.size()

# Add a new memory entry
func add_memory_entry(content, account = "normal", tags = []):
    var timestamp = OS.get_unix_time()
    var date_str = Time.get_datetime_string_from_unix_time(timestamp, config.diary_format.date_format)
    var time_str = Time.get_datetime_string_from_unix_time(timestamp, config.diary_format.time_format)
    
    var entry = {
        "timestamp": timestamp,
        "date": date_str,
        "time": time_str,
        "account": account,
        "content": content,
        "tags": tags
    }
    
    # Add to memory entries
    memory_entries.append(entry)
    
    # Save entry to account file
    _save_account_entry(entry)
    
    # Add to diary
    _add_diary_entry(entry)
    
    # Update account state
    if account_states.has(account):
        account_states[account].entries += 1
        account_states[account].last_entry = timestamp
    
    # Emit signal
    emit_signal("entry_added", entry)
    
    return entry

# Add entry to the main diary
func _add_diary_entry(entry):
    # Format entry for diary
    var formatted_entry = config.diary_format.entry_template.format({
        "date": entry.date,
        "time": entry.time,
        "account": entry.account,
        "content": entry.content
    })
    
    # Add to diary entries list
    diary_entries.append({
        "timestamp": entry.timestamp,
        "formatted": formatted_entry,
        "raw": entry
    })
    
    # Save to diary file
    _save_diary_entry(formatted_entry)
    
    # Emit signal
    emit_signal("diary_updated", diary_entries.size())
    
    return diary_entries.size()

# Save entry to account file
func _save_account_entry(entry):
    var account = entry.account
    
    if not config.claude_accounts.has(account):
        push_error("Unknown account: " + account)
        return false
    
    var account_path = config.claude_accounts[account].path
    var date_path = account_path.plus_file(entry.date)
    var dir = Directory.new()
    
    # Create date directory if needed
    if not dir.dir_exists(date_path):
        dir.make_dir_recursive(date_path)
    
    # Create entry file
    var entry_file = date_path.plus_file(entry.time.replace(":", "-") + ".json")
    var file = File.new()
    
    if file.open(entry_file, File.WRITE) != OK:
        push_error("Failed to open entry file: " + entry_file)
        return false
    
    file.store_string(JSON.print(entry, "  "))
    file.close()
    
    return true

# Save entry to diary file
func _save_diary_entry(formatted_entry):
    var date = Time.get_date_dict_from_unix_time(OS.get_unix_time())
    var diary_file = config.diary_root.plus_file(str(date.year) + "-" + str(date.month) + ".log")
    var file = File.new()
    
    # Append to diary file
    if file.open(diary_file, File.READ_WRITE) != OK:
        # Create file if it doesn't exist
        if file.open(diary_file, File.WRITE) != OK:
            push_error("Failed to open diary file: " + diary_file)
            return false
    else:
        # Move to end of file
        file.seek_end()
    
    file.store_line(formatted_entry)
    file.close()
    
    return true

# Load entries from an account
func _load_account_entries(account):
    if not config.claude_accounts.has(account):
        push_error("Unknown account: " + account)
        return []
    
    var account_path = config.claude_accounts[account].path
    var dir = Directory.new()
    
    if not dir.dir_exists(account_path):
        push_error("Account path does not exist: " + account_path)
        return []
    
    var entries = []
    
    # Open account directory
    if dir.open(account_path) != OK:
        push_error("Failed to open account directory: " + account_path)
        return []
    
    # Enumerate date directories
    dir.list_dir_begin(true, true)
    var date_dir = dir.get_next()
    
    while date_dir != "":
        var date_path = account_path.plus_file(date_dir)
        
        if dir.current_is_dir():
            # Load entries for this date
            var date_entries = _load_date_entries(date_path, account, date_dir)
            entries.append_array(date_entries)
        
        date_dir = dir.get_next()
    
    dir.list_dir_end()
    
    # Sort entries by timestamp
    entries.sort_custom(self, "_sort_by_timestamp")
    
    # Add to memory entries
    for entry in entries:
        memory_entries.append(entry)
    
    return entries

# Load entries for a specific date
func _load_date_entries(date_path, account, date_str):
    var dir = Directory.new()
    var entries = []
    
    if dir.open(date_path) != OK:
        push_error("Failed to open date directory: " + date_path)
        return []
    
    # Enumerate entry files
    dir.list_dir_begin(true, true)
    var entry_file = dir.get_next()
    
    while entry_file != "":
        if not dir.current_is_dir() and entry_file.ends_with(".json"):
            var file_path = date_path.plus_file(entry_file)
            var entry = _load_entry_file(file_path, account, date_str)
            
            if entry != null:
                entries.append(entry)
        
        entry_file = dir.get_next()
    
    dir.list_dir_end()
    
    return entries

# Load a single entry file
func _load_entry_file(file_path, account, date_str):
    var file = File.new()
    
    if not file.file_exists(file_path):
        push_error("Entry file does not exist: " + file_path)
        return null
    
    if file.open(file_path, File.READ) != OK:
        push_error("Failed to open entry file: " + file_path)
        return null
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    
    if parse_result.error != OK:
        push_error("Failed to parse entry file: " + file_path)
        return null
    
    var entry = parse_result.result
    
    # Ensure account is set
    if not entry.has("account") or entry.account.empty():
        entry.account = account
    
    # Ensure date is set
    if not entry.has("date") or entry.date.empty():
        entry.date = date_str
    
    return entry

# Load diary entries
func _load_diary_entries():
    var dir = Directory.new()
    
    if not dir.dir_exists(config.diary_root):
        push_error("Diary root does not exist: " + config.diary_root)
        return []
    
    if dir.open(config.diary_root) != OK:
        push_error("Failed to open diary root: " + config.diary_root)
        return []
    
    var entries = []
    
    # Enumerate diary files
    dir.list_dir_begin(true, true)
    var diary_file = dir.get_next()
    
    while diary_file != "":
        if not dir.current_is_dir() and diary_file.ends_with(".log"):
            var file_path = config.diary_root.plus_file(diary_file)
            var file_entries = _load_diary_file(file_path)
            entries.append_array(file_entries)
        
        diary_file = dir.get_next()
    
    dir.list_dir_end()
    
    # Sort entries by timestamp (if available)
    entries.sort_custom(self, "_sort_diary_entries")
    
    # Add to diary entries
    diary_entries = entries
    
    return entries

# Load a single diary file
func _load_diary_file(file_path):
    var file = File.new()
    
    if not file.file_exists(file_path):
        push_error("Diary file does not exist: " + file_path)
        return []
    
    if file.open(file_path, File.READ) != OK:
        push_error("Failed to open diary file: " + file_path)
        return []
    
    var entries = []
    var line_num = 0
    
    while not file.eof_reached():
        var line = file.get_line()
        line_num += 1
        
        if not line.empty():
            var entry = {
                "formatted": line,
                "timestamp": 0,  # No timestamp for raw diary entries
                "line": line_num,
                "file": file_path
            }
            
            entries.append(entry)
    }
    
    file.close()
    
    return entries

# Merge entries from multiple accounts
func merge_accounts(accounts = []):
    var merged_count = 0
    
    # If no accounts specified, use all accounts
    if accounts.empty():
        for account in config.claude_accounts:
            accounts.append(account)
    
    # Load all entries first
    load_all_entries()
    
    # Track entries by date-time to avoid duplicates
    var tracked_entries = {}
    
    # Process each account
    for account in accounts:
        if not config.claude_accounts.has(account):
            continue
        
        # Get entries for this account
        var account_entries = []
        
        for entry in memory_entries:
            if entry.account == account:
                var key = entry.date + "-" + entry.time
                
                if not tracked_entries.has(key):
                    tracked_entries[key] = entry
                    account_entries.append(entry)
        
        # Update account state
        if account_states.has(account):
            account_states[account].entries = account_entries.size()
            
            if account_entries.size() > 0:
                account_states[account].last_entry = account_entries.back().timestamp
        
        # Sync with external connections if available
        if external_connections != null:
            _sync_account_with_external(account)
        
        emit_signal("accounts_synced", account)
        merged_count += account_entries.size()
    }
    
    return merged_count

# Sync account with external connections
func _sync_account_with_external(account):
    if external_connections == null:
        return 0
    
    if not config.claude_accounts.has(account):
        return 0
    
    var account_path = config.claude_accounts[account].path
    
    # Get entries for this account
    var account_entries = []
    
    for entry in memory_entries:
        if entry.account == account:
            account_entries.append(entry)
    
    # Sync to memory paths
    var sync_count = 0
    
    for key in config.memory_paths:
        var memory_path = config.memory_paths[key]
        var target_path = memory_path.plus_file("claude").plus_file(account)
        
        # Create target directory if needed
        var dir = Directory.new()
        if not dir.dir_exists(target_path):
            dir.make_dir_recursive(target_path)
        
        # Copy latest 10 entries
        var recent_entries = account_entries.slice(
            max(0, account_entries.size() - 10),
            account_entries.size() - 1
        )
        
        for entry in recent_entries:
            var date_path = target_path.plus_file(entry.date)
            
            if not dir.dir_exists(date_path):
                dir.make_dir_recursive(date_path)
            
            var entry_file = date_path.plus_file(entry.time.replace(":", "-") + ".json")
            var file = File.new()
            
            if not file.file_exists(entry_file):
                if file.open(entry_file, File.WRITE) == OK:
                    file.store_string(JSON.print(entry, "  "))
                    file.close()
                    sync_count += 1
        }
    }
    
    return sync_count

# Search for entries matching criteria
func search_entries(query, account = "", date_from = "", date_to = ""):
    var results = []
    
    # Convert dates to timestamps if provided
    var timestamp_from = 0
    var timestamp_to = 0
    
    if not date_from.empty():
        var date_dict = _parse_date_string(date_from)
        if date_dict != null:
            timestamp_from = Time.get_unix_time_from_datetime_dict(date_dict)
    
    if not date_to.empty():
        var date_dict = _parse_date_string(date_to)
        if date_dict != null:
            # Set to end of day
            date_dict.hour = 23
            date_dict.minute = 59
            date_dict.second = 59
            timestamp_to = Time.get_unix_time_from_datetime_dict(date_dict)
    
    # Search entries
    for entry in memory_entries:
        var match_account = account.empty() or entry.account == account
        var match_date = true
        
        if timestamp_from > 0:
            match_date = match_date and entry.timestamp >= timestamp_from
        
        if timestamp_to > 0:
            match_date = match_date and entry.timestamp <= timestamp_to
        
        var match_query = query.empty() or entry.content.to_lower().find(query.to_lower()) >= 0
        
        if match_account and match_date and match_query:
            results.append(entry)
    }
    
    return results

# Helper function to parse date string (YYYY-MM-DD)
func _parse_date_string(date_str):
    var parts = date_str.split("-")
    
    if parts.size() != 3:
        return null
    
    var year = int(parts[0])
    var month = int(parts[1])
    var day = int(parts[2])
    
    if year < 1970 or month < 1 or month > 12 or day < 1 or day > 31:
        return null
    
    return {
        "year": year,
        "month": month,
        "day": day,
        "hour": 0,
        "minute": 0,
        "second": 0
    }

# Get account status information
func get_account_status(account = ""):
    if account.empty():
        return account_states
    
    if account_states.has(account):
        return account_states[account]
    
    return null

# Helper function to sort entries by timestamp
func _sort_by_timestamp(a, b):
    if a.timestamp < b.timestamp:
        return true
    return false

# Helper function to sort diary entries
func _sort_diary_entries(a, b):
    # If both have timestamps, use those
    if a.timestamp > 0 and b.timestamp > 0:
        return a.timestamp < b.timestamp
    
    # Otherwise, sort by file and line number
    if a.file == b.file:
        return a.line < b.line
    
    return a.file < b.file

# Get diary data for visualizer
func _get_diary_data():
    return {
        "type": "diary",
        "entries": memory_entries.size(),
        "accounts": account_states.size(),
        "last_entry": memory_entries.size() > 0 ? memory_entries.back().timestamp : 0
    }

# Terminal commands

func _cmd_diary(args):
    if args.size() < 1:
        return "ERROR: Usage: diary <subcommand> [args]"
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1, args.size() - 1)
    
    match subcommand:
        "list":
            var count = 10  # Default number of entries to show
            var account = ""  # All accounts
            
            # Parse flags
            var parsed = terminal.parse_args(subargs)
            
            if parsed.flags.has("count"):
                count = int(parsed.flags.count)
            
            if parsed.flags.has("account"):
                account = parsed.flags.account
            
            # Get entries
            var entries = []
            
            for entry in memory_entries:
                if account.empty() or entry.account == account:
                    entries.append(entry)
            
            # Show only the most recent entries
            if entries.size() > count:
                entries = entries.slice(entries.size() - count, entries.size() - 1)
            
            var output = "Diary entries (" + (account.empty() ? "all accounts" : account) + "):\n"
            
            for entry in entries:
                output += "[" + entry.date + " " + entry.time + "] [" + entry.account + "] " + entry.content.substr(0, 50)
                
                if entry.content.length() > 50:
                    output += "..."
                
                output += "\n"
            
            return output
        
        "search":
            if subargs.size() < 1:
                return "ERROR: Usage: diary search <query> [--account=name] [--from=YYYY-MM-DD] [--to=YYYY-MM-DD]"
            
            var query = subargs[0]
            
            # Parse flags
            var parsed = terminal.parse_args(subargs.slice(1, subargs.size() - 1))
            var account = parsed.flags.get("account", "")
            var date_from = parsed.flags.get("from", "")
            var date_to = parsed.flags.get("to", "")
            
            var results = search_entries(query, account, date_from, date_to)
            
            var output = "Search results for '" + query + "': " + str(results.size()) + " entries\n"
            
            for result in results:
                output += "[" + result.date + " " + result.time + "] [" + result.account + "] " + result.content.substr(0, 50)
                
                if result.content.length() > 50:
                    output += "..."
                
                output += "\n"
            
            return output
        
        "stats":
            var output = "Diary statistics:\n"
            output += "  Total entries: " + str(memory_entries.size()) + "\n"
            output += "  Diary files: " + str(diary_entries.size()) + "\n"
            output += "  Last sync: " + Time.get_datetime_string_from_unix_time(last_sync_time) + "\n"
            
            output += "  Accounts:\n"
            for account in account_states:
                output += "    " + account + ": " + str(account_states[account].entries) + " entries"
                
                if account_states[account].last_entry > 0:
                    output += " (last: " + Time.get_datetime_string_from_unix_time(account_states[account].last_entry) + ")"
                
                output += "\n"
            
            return output
        
        "reload":
            var count = load_all_entries()
            return "Reloaded " + str(count) + " entries"
        
        _:
            return "ERROR: Unknown subcommand: " + subcommand

func _cmd_account(args):
    if args.size() < 1:
        return "ERROR: Usage: account <subcommand> [args]"
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1, args.size() - 1)
    
    match subcommand:
        "list":
            var output = "Claude accounts:\n"
            
            for account in config.claude_accounts:
                var state = "Inactive"
                
                if config.claude_accounts[account].active:
                    state = "Active"
                
                output += "  " + account + ": " + state + " (" + config.claude_accounts[account].path + ")\n"
            
            return output
        
        "activate":
            if subargs.size() < 1:
                return "ERROR: Usage: account activate <account>"
            
            var account = subargs[0]
            
            if not config.claude_accounts.has(account):
                return "ERROR: Unknown account: " + account
            
            config.claude_accounts[account].active = true
            
            if account_states.has(account):
                account_states[account].connected = true
            
            return "Activated account: " + account
        
        "deactivate":
            if subargs.size() < 1:
                return "ERROR: Usage: account deactivate <account>"
            
            var account = subargs[0]
            
            if not config.claude_accounts.has(account):
                return "ERROR: Unknown account: " + account
            
            config.claude_accounts[account].active = false
            
            if account_states.has(account):
                account_states[account].connected = false
            
            return "Deactivated account: " + account
        
        "add":
            if subargs.size() < 2:
                return "ERROR: Usage: account add <name> <path>"
            
            var account = subargs[0]
            var path = subargs[1]
            
            # Make path absolute if not already
            if not path.begins_with("/"):
                path = OS.get_executable_path().get_base_dir().plus_file(path)
            
            config.claude_accounts[account] = {
                "path": path,
                "active": true
            }
            
            account_states[account] = {
                "connected": true,
                "entries": 0,
                "last_entry": 0
            }
            
            # Create directory if it doesn't exist
            var dir = Directory.new()
            if not dir.dir_exists(path):
                dir.make_dir_recursive(path)
            
            return "Added account: " + account + " at " + path
        
        _:
            return "ERROR: Unknown subcommand: " + subcommand

func _cmd_entry(args):
    if args.size() < 1:
        return "ERROR: Usage: entry <subcommand> [args]"
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1, args.size() - 1)
    
    match subcommand:
        "add":
            if subargs.size() < 1:
                return "ERROR: Usage: entry add <content> [--account=name] [--tags=tag1,tag2]"
            
            var content = subargs[0]
            
            # Handle multi-word content
            if subargs.size() > 1:
                # Check if second argument starts with --
                if not subargs[1].begins_with("--"):
                    # Concatenate all non-flag arguments
                    var content_args = []
                    var i = 0
                    
                    while i < subargs.size() and not subargs[i].begins_with("--"):
                        content_args.append(subargs[i])
                        i += 1
                    
                    content = content_args.join(" ")
                    subargs = subargs.slice(i, subargs.size() - 1)
            
            # Parse flags
            var parsed = terminal.parse_args(subargs)
            var account = parsed.flags.get("account", "normal")
            var tags = []
            
            if parsed.flags.has("tags"):
                tags = parsed.flags.tags.split(",")
            
            var entry = add_memory_entry(content, account, tags)
            
            return "Added entry to " + account + " account: " + content
        
        "get":
            if subargs.size() < 1:
                return "ERROR: Usage: entry get <index>"
            
            var index = int(subargs[0])
            
            if index < 0 or index >= memory_entries.size():
                return "ERROR: Invalid entry index: " + str(index)
            
            var entry = memory_entries[index]
            
            var output = "Entry " + str(index) + ":\n"
            output += "  Date: " + entry.date + " " + entry.time + "\n"
            output += "  Account: " + entry.account + "\n"
            
            if entry.has("tags") and entry.tags.size() > 0:
                output += "  Tags: " + str(entry.tags) + "\n"
            
            output += "  Content: " + entry.content + "\n"
            
            return output
        
        _:
            return "ERROR: Unknown subcommand: " + subcommand

func _cmd_merge(args):
    var accounts = []
    
    # If accounts specified, use those
    if args.size() > 0:
        for arg in args:
            if config.claude_accounts.has(arg):
                accounts.append(arg)
    
    var merged_count = merge_accounts(accounts)
    
    return "Merged " + str(merged_count) + " entries from " + str(accounts.size()) + " accounts"