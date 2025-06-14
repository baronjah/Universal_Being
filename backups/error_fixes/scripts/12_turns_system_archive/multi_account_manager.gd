extends Node

class_name MultiAccountManager

# Account tier constants
enum AccountTier {
    FREE,
    PLUS,
    MAX,
    ENTERPRISE
}

# Thread priority levels
enum ThreadPriority {
    LOW,
    MEDIUM,
    HIGH,
    CRITICAL
}

# Account tier specifications
const TIER_SPECS = {
    AccountTier.FREE: {
        "max_threads": 1,
        "storage_limit_gb": 5,
        "api_calls_per_min": 10,
        "price_monthly": 0,
        "max_dimensions": 3
    },
    AccountTier.PLUS: {
        "max_threads": 3, 
        "storage_limit_gb": 50,
        "api_calls_per_min": 60,
        "price_monthly": 20,
        "max_dimensions": 7
    },
    AccountTier.MAX: {
        "max_threads": 8,
        "storage_limit_gb": 250,
        "api_calls_per_min": 250,
        "price_monthly": 50,
        "max_dimensions": 12
    },
    AccountTier.ENTERPRISE: {
        "max_threads": 32,
        "storage_limit_gb": 2000, # 2TB
        "api_calls_per_min": 1000,
        "price_monthly": 100,
        "max_dimensions": 12,
        "custom_dimensions": true
    }
}

# Account instances
var accounts = {}
var active_account_id = ""
var thread_pools = {}

# Storage integration
var storage_usage = {}
var luno_storage_linked = false
var additional_storage_gb = 0

# API connection
var api_usage_counter = {}
var api_usage_time = {}
var api_keys = {}

# Threads and processing
var active_threads = {}
var thread_usage = {}
var thread_mutex = Mutex.new()

# References
var _smart_account_manager = null
var _account_connector = null

# Signals
signal account_switched(from_id, to_id)
signal thread_allocated(account_id, thread_id, priority)
signal thread_completed(account_id, thread_id)
signal api_limit_reached(account_id)
signal storage_limit_reached(account_id)

func _ready():
    # Connect to systems
    connect_to_systems()
    
    # Initialize storage monitor
    var storage_timer = Timer.new()
    storage_timer.wait_time = 300 # 5 minutes
    storage_timer.autostart = true
    storage_timer.connect("timeout", self, "_on_storage_monitor")
    add_child(storage_timer)
    
    # Initialize API usage monitor
    var api_timer = Timer.new()
    api_timer.wait_time = 60 # 1 minute
    api_timer.autostart = true
    api_timer.connect("timeout", self, "_on_api_usage_reset")
    add_child(api_timer)

func connect_to_systems():
    # Connect to SmartAccountManager
    if has_node("/root/SmartAccountManager") or get_node_or_null("/root/SmartAccountManager"):
        _smart_account_manager = get_node("/root/SmartAccountManager")
        print("Connected to SmartAccountManager")
    
    # Connect to SharedAccountConnector
    if has_node("/root/SharedAccountConnector") or get_node_or_null("/root/SharedAccountConnector"):
        _account_connector = get_node("/root/SharedAccountConnector")
        print("Connected to SharedAccountConnector")

func create_account(display_name, tier = AccountTier.FREE, api_key = ""):
    # Generate unique account ID
    var account_id = _generate_unique_id()
    
    # Configure account based on tier
    var account_data = {
        "id": account_id,
        "display_name": display_name,
        "tier": tier,
        "tier_name": AccountTier.keys()[tier],
        "created_at": OS.get_datetime(),
        "last_active": OS.get_datetime(),
        "api_key": api_key,
        "threads_allocated": 0,
        "storage_used_gb": 0,
        "api_calls_count": 0,
        "max_threads": TIER_SPECS[tier]["max_threads"],
        "storage_limit_gb": TIER_SPECS[tier]["storage_limit_gb"],
        "api_calls_per_min": TIER_SPECS[tier]["api_calls_per_min"],
        "dimensions_limit": TIER_SPECS[tier]["max_dimensions"],
        "price_monthly": TIER_SPECS[tier]["price_monthly"],
        "active_threads": [],
        "thread_history": [],
        "color_scheme": _generate_tier_colors(tier)
    }
    
    # Store account data
    accounts[account_id] = account_data
    
    # Initialize usage counters
    storage_usage[account_id] = 0
    api_usage_counter[account_id] = 0
    api_usage_time[account_id] = OS.get_unix_time()
    
    # Store API key if provided
    if not api_key.empty():
        api_keys[api_key] = account_id
    
    # Initialize thread pool for this account
    thread_pools[account_id] = []
    for i in range(account_data["max_threads"]):
        thread_pools[account_id].append({
            "id": "thread_" + str(i),
            "active": false,
            "start_time": 0,
            "priority": ThreadPriority.MEDIUM,
            "task": ""
        })
    
    # If this is the first account, make it active
    if accounts.size() == 1:
        active_account_id = account_id
    
    print("Created account: " + display_name + " (Tier: " + account_data["tier_name"] + ")")
    return account_id

func switch_account(account_id):
    if not account_id in accounts:
        print("Account not found: " + account_id)
        return false
    
    var previous_account = active_account_id
    active_account_id = account_id
    
    # Update last active timestamp
    accounts[account_id]["last_active"] = OS.get_datetime()
    
    print("Switched to account: " + accounts[account_id]["display_name"])
    
    # Notify the SmartAccountManager
    if _smart_account_manager:
        # Would implement account switching in SmartAccountManager
        pass
    
    # Notify listeners
    emit_signal("account_switched", previous_account, active_account_id)
    return true

func allocate_thread(account_id, task_description, priority = ThreadPriority.MEDIUM):
    if not account_id in accounts:
        print("Account not found: " + account_id)
        return null
    
    var account = accounts[account_id]
    
    # Check if account has reached thread limit
    if account["threads_allocated"] >= account["max_threads"]:
        print("Thread limit reached for account: " + account["display_name"])
        return null
    
    # Find available thread in pool
    var thread_id = null
    
    thread_mutex.lock()
    for thread in thread_pools[account_id]:
        if not thread["active"]:
            thread["active"] = true
            thread["start_time"] = OS.get_unix_time()
            thread["priority"] = priority
            thread["task"] = task_description
            thread_id = thread["id"]
            break
    thread_mutex.unlock()
    
    if thread_id:
        # Update account thread allocation
        account["threads_allocated"] += 1
        account["active_threads"].append({
            "id": thread_id,
            "start_time": OS.get_unix_time(),
            "priority": priority,
            "task": task_description
        })
        
        # Track thread usage
        if not account_id in thread_usage:
            thread_usage[account_id] = []
        
        thread_usage[account_id].append({
            "thread_id": thread_id,
            "start_time": OS.get_unix_time(),
            "priority": priority
        })
        
        print("Allocated thread " + thread_id + " for account: " + account["display_name"])
        emit_signal("thread_allocated", account_id, thread_id, priority)
        
        return thread_id
    
    print("No threads available in pool for account: " + account["display_name"])
    return null

func release_thread(account_id, thread_id):
    if not account_id in accounts:
        print("Account not found: " + account_id)
        return false
    
    var account = accounts[account_id]
    var thread_found = false
    
    thread_mutex.lock()
    # Find thread in pool
    for thread in thread_pools[account_id]:
        if thread["id"] == thread_id and thread["active"]:
            thread["active"] = false
            thread["task"] = ""
            thread_found = true
            break
    thread_mutex.unlock()
    
    if thread_found:
        # Update account thread allocation
        account["threads_allocated"] = max(0, account["threads_allocated"] - 1)
        
        # Remove from active threads list
        var index_to_remove = -1
        for i in range(account["active_threads"].size()):
            if account["active_threads"][i]["id"] == thread_id:
                index_to_remove = i
                break
        
        if index_to_remove >= 0:
            # Add to thread history before removing
            account["thread_history"].append({
                "id": thread_id,
                "start_time": account["active_threads"][index_to_remove]["start_time"],
                "end_time": OS.get_unix_time(),
                "duration": OS.get_unix_time() - account["active_threads"][index_to_remove]["start_time"],
                "priority": account["active_threads"][index_to_remove]["priority"],
                "task": account["active_threads"][index_to_remove]["task"]
            })
            
            # Remove from active list
            account["active_threads"].remove(index_to_remove)
        
        # Update thread usage tracking
        for i in range(thread_usage[account_id].size()):
            if thread_usage[account_id][i]["thread_id"] == thread_id:
                thread_usage[account_id][i]["end_time"] = OS.get_unix_time()
                thread_usage[account_id][i]["duration"] = OS.get_unix_time() - thread_usage[account_id][i]["start_time"]
                break
        
        print("Released thread " + thread_id + " for account: " + account["display_name"])
        emit_signal("thread_completed", account_id, thread_id)
        
        return true
    
    print("Thread not found or not active: " + thread_id)
    return false

func upgrade_account(account_id, new_tier):
    if not account_id in accounts:
        print("Account not found: " + account_id)
        return false
    
    if not new_tier in AccountTier.values():
        print("Invalid account tier")
        return false
    
    var account = accounts[account_id]
    var old_tier = account["tier"]
    
    if new_tier <= old_tier:
        print("Cannot downgrade account tier")
        return false
    
    # Update account tier
    account["tier"] = new_tier
    account["tier_name"] = AccountTier.keys()[new_tier]
    
    # Update account specs based on new tier
    account["max_threads"] = TIER_SPECS[new_tier]["max_threads"]
    account["storage_limit_gb"] = TIER_SPECS[new_tier]["storage_limit_gb"]
    account["api_calls_per_min"] = TIER_SPECS[new_tier]["api_calls_per_min"]
    account["dimensions_limit"] = TIER_SPECS[new_tier]["max_dimensions"]
    account["price_monthly"] = TIER_SPECS[new_tier]["price_monthly"]
    account["color_scheme"] = _generate_tier_colors(new_tier)
    
    # Update thread pool
    var current_pool_size = thread_pools[account_id].size()
    var new_pool_size = account["max_threads"]
    
    if new_pool_size > current_pool_size:
        # Add new threads to pool
        for i in range(current_pool_size, new_pool_size):
            thread_pools[account_id].append({
                "id": "thread_" + str(i),
                "active": false,
                "start_time": 0,
                "priority": ThreadPriority.MEDIUM,
                "task": ""
            })
    
    print("Upgraded account " + account["display_name"] + " from " + 
          AccountTier.keys()[old_tier] + " to " + AccountTier.keys()[new_tier])
    
    return true

func track_api_call(account_id, api_endpoint):
    if not account_id in accounts:
        print("Account not found: " + account_id)
        return false
    
    var account = accounts[account_id]
    
    # Check if account has reached API call limit
    if api_usage_counter[account_id] >= account["api_calls_per_min"]:
        print("API call limit reached for account: " + account["display_name"])
        emit_signal("api_limit_reached", account_id)
        return false
    
    # Increment API call counter
    api_usage_counter[account_id] += 1
    account["api_calls_count"] += 1
    
    return true

func update_storage_usage(account_id, size_change_mb):
    if not account_id in accounts:
        print("Account not found: " + account_id)
        return false
    
    var account = accounts[account_id]
    var size_change_gb = size_change_mb / 1024.0
    
    # Update storage usage
    storage_usage[account_id] += size_change_gb
    account["storage_used_gb"] += size_change_gb
    
    # Check if account has reached storage limit
    if account["storage_used_gb"] >= account["storage_limit_gb"]:
        print("Storage limit reached for account: " + account["display_name"])
        emit_signal("storage_limit_reached", account_id)
        return false
    
    return true

func link_luno_storage(account_id, storage_size_gb = 2000):
    if not account_id in accounts:
        print("Account not found: " + account_id)
        return false
    
    var account = accounts[account_id]
    
    # Add additional storage
    additional_storage_gb = storage_size_gb
    account["storage_limit_gb"] += additional_storage_gb
    luno_storage_linked = true
    
    print("Linked Luno storage (2TB) to account: " + account["display_name"])
    return true

func get_account_data(account_id = ""):
    # Use active account if none specified
    if account_id.empty():
        account_id = active_account_id
    
    if not account_id in accounts:
        print("Account not found: " + account_id)
        return null
    
    return accounts[account_id]

func get_thread_status(account_id, thread_id):
    if not account_id in accounts or not account_id in thread_pools:
        print("Account not found: " + account_id)
        return null
    
    for thread in thread_pools[account_id]:
        if thread["id"] == thread_id:
            return thread
    
    return null

func get_account_colors(account_id = ""):
    # Use active account if none specified
    if account_id.empty():
        account_id = active_account_id
    
    if not account_id in accounts:
        return null
    
    return accounts[account_id]["color_scheme"]

func _on_storage_monitor():
    # Update storage usage for all accounts
    for account_id in accounts:
        var account = accounts[account_id]
        
        # In a real implementation, would actually check storage usage
        # For now, simulate storage usage growth for active accounts
        if account["active_threads"].size() > 0:
            var usage_growth = randf() * 0.1 # 0-0.1 GB per check for active accounts
            update_storage_usage(account_id, usage_growth * 1024) # Convert to MB

func _on_api_usage_reset():
    # Reset API usage counters for all accounts
    for account_id in api_usage_counter:
        api_usage_counter[account_id] = 0
        api_usage_time[account_id] = OS.get_unix_time()

func _generate_unique_id():
    return str(OS.get_unix_time()) + "_" + str(randi() % 10000)

func _generate_tier_colors(tier):
    # Generate color scheme based on account tier
    match tier:
        AccountTier.FREE:
            return {
                "primary": Color(0.3, 0.7, 0.9, 0.9), # Blue
                "secondary": Color(0.2, 0.5, 0.7, 0.7),
                "text": Color(0.9, 0.9, 0.9),
                "accent": Color(0.4, 0.8, 1.0),
                "glow_intensity": 0.5
            }
        AccountTier.PLUS:
            return {
                "primary": Color(0.3, 0.8, 0.3, 0.9), # Green
                "secondary": Color(0.2, 0.6, 0.2, 0.7),
                "text": Color(0.9, 0.9, 0.9),
                "accent": Color(0.4, 1.0, 0.4),
                "glow_intensity": 0.7
            }
        AccountTier.MAX:
            return {
                "primary": Color(0.8, 0.3, 0.8, 0.9), # Purple
                "secondary": Color(0.6, 0.2, 0.6, 0.7),
                "text": Color(0.9, 0.9, 0.9),
                "accent": Color(1.0, 0.4, 1.0),
                "glow_intensity": 0.9
            }
        AccountTier.ENTERPRISE:
            return {
                "primary": Color(0.9, 0.8, 0.2, 0.9), # Gold
                "secondary": Color(0.7, 0.6, 0.1, 0.7),
                "text": Color(0.9, 0.9, 0.9),
                "accent": Color(1.0, 0.9, 0.3),
                "glow_intensity": 1.0
            }
        _:
            return {
                "primary": Color(0.7, 0.7, 0.7, 0.9), # Gray
                "secondary": Color(0.5, 0.5, 0.5, 0.7),
                "text": Color(0.9, 0.9, 0.9),
                "accent": Color(0.8, 0.8, 0.8),
                "glow_intensity": 0.5
            }