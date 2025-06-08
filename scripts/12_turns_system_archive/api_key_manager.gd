extends Node

class_name ApiKeyManager

# API Provider types
enum ApiProvider {
    OPENAI,
    GOOGLE,
    DROPBOX,
    GITHUB,
    CUSTOM
}

# Key security levels
enum SecurityLevel {
    MINIMAL,
    STANDARD,
    HIGH,
    MAXIMUM
}

# API key data structure
var api_keys = {}

# Security settings
var encryption_enabled = true
var rotation_enabled = false
var rotation_interval_days = 90
var usage_tracking_enabled = true

# Storage
var secure_storage = {}
var usage_logs = []

# References
var _account_manager = null
var _processor = null

# Signals
signal key_added(provider, masked_key)
signal key_removed(provider)
signal key_rotated(provider, old_masked_key, new_masked_key)
signal usage_threshold_reached(provider, usage_percent)

func _ready():
    # Connect to other systems
    connect_to_systems()
    
    # Set up security check timer
    var security_timer = Timer.new()
    security_timer.wait_time = 3600 # Check once per hour
    security_timer.autostart = true
    security_timer.connect("timeout", self, "_on_security_check")
    add_child(security_timer)

func connect_to_systems():
    # Connect to MultiAccountManager
    if has_node("/root/MultiAccountManager") or get_node_or_null("/root/MultiAccountManager"):
        _account_manager = get_node("/root/MultiAccountManager")
        print("Connected to MultiAccountManager")
    
    # Connect to MultiThreadedProcessor
    if has_node("/root/MultiThreadedProcessor") or get_node_or_null("/root/MultiThreadedProcessor"):
        _processor = get_node("/root/MultiThreadedProcessor")
        print("Connected to MultiThreadedProcessor")

func add_api_key(provider_id, api_key, account_id = "", security_level = SecurityLevel.STANDARD, alias = ""):
    # Validate inputs
    if not provider_id in ApiProvider.values() and provider_id is String:
        provider_id = ApiProvider.CUSTOM
    
    # Generate unique key ID
    var key_id = str(OS.get_unix_time()) + "_" + str(randi() % 10000)
    
    # Use account if connected to account manager
    if account_id.empty() and _account_manager:
        account_id = _account_manager.active_account_id
    
    # Set provider name
    var provider_name = provider_id
    if provider_id in ApiProvider.values():
        provider_name = ApiProvider.keys()[provider_id]
    
    # Assign alias if not provided
    if alias.empty():
        alias = provider_name + " API Key"
    
    # Get masked key for logging/display
    var masked_key = _mask_api_key(api_key)
    
    # Store the API key data
    api_keys[key_id] = {
        "provider": provider_id,
        "provider_name": provider_name,
        "key": _encrypt_key(api_key) if encryption_enabled else api_key,
        "encrypted": encryption_enabled,
        "account_id": account_id,
        "added_at": OS.get_unix_time(),
        "last_used": 0,
        "last_validated": OS.get_unix_time(),
        "security_level": security_level,
        "alias": alias,
        "is_valid": true,
        "usage_count": 0,
        "masked_key": masked_key,
        "rotation_due": OS.get_unix_time() + (rotation_interval_days * 86400) if rotation_enabled else 0
    }
    
    # Log the addition
    _log_key_event(key_id, "added", {
        "provider": provider_name,
        "account_id": account_id,
        "masked_key": masked_key
    })
    
    # Emit signal
    emit_signal("key_added", provider_name, masked_key)
    
    print("Added API key for " + provider_name + ": " + masked_key)
    return key_id

func get_api_key(provider, account_id = ""):
    # Find matching API key
    for key_id in api_keys:
        var key_info = api_keys[key_id]
        
        var provider_match = false
        if provider is int and key_info["provider"] == provider:
            provider_match = true
        elif provider is String and key_info["provider_name"] == provider:
            provider_match = true
        
        var account_match = account_id.empty() or key_info["account_id"] == account_id
        
        if provider_match and account_match and key_info["is_valid"]:
            # Update usage stats
            key_info["last_used"] = OS.get_unix_time()
            key_info["usage_count"] += 1
            
            # Return decrypted key
            return _decrypt_key(key_info["key"]) if key_info["encrypted"] else key_info["key"]
    
    print("No API key found for provider: " + str(provider))
    return ""

func remove_api_key(key_id):
    if not key_id in api_keys:
        print("API key not found: " + key_id)
        return false
    
    var provider_name = api_keys[key_id]["provider_name"]
    var masked_key = api_keys[key_id]["masked_key"]
    
    # Log the removal
    _log_key_event(key_id, "removed", {
        "provider": provider_name,
        "masked_key": masked_key
    })
    
    # Remove the key
    api_keys.erase(key_id)
    
    # Emit signal
    emit_signal("key_removed", provider_name)
    
    print("Removed API key for " + provider_name + ": " + masked_key)
    return true

func rotate_api_key(key_id, new_api_key):
    if not key_id in api_keys:
        print("API key not found: " + key_id)
        return false
    
    var key_info = api_keys[key_id]
    var provider_name = key_info["provider_name"]
    var old_masked_key = key_info["masked_key"]
    var new_masked_key = _mask_api_key(new_api_key)
    
    # Update the key
    key_info["key"] = _encrypt_key(new_api_key) if encryption_enabled else new_api_key
    key_info["masked_key"] = new_masked_key
    key_info["last_validated"] = OS.get_unix_time()
    key_info["rotation_due"] = OS.get_unix_time() + (rotation_interval_days * 86400) if rotation_enabled else 0
    
    # Log the rotation
    _log_key_event(key_id, "rotated", {
        "provider": provider_name,
        "old_masked_key": old_masked_key,
        "new_masked_key": new_masked_key
    })
    
    # Emit signal
    emit_signal("key_rotated", provider_name, old_masked_key, new_masked_key)
    
    print("Rotated API key for " + provider_name + ": " + old_masked_key + " -> " + new_masked_key)
    return true

func validate_api_key(key_id):
    if not key_id in api_keys:
        print("API key not found: " + key_id)
        return false
    
    var key_info = api_keys[key_id]
    
    # In a real implementation, would make an API call to validate the key
    # For this demo, simulate validation
    var validation_success = true
    
    # Update validation status
    key_info["is_valid"] = validation_success
    key_info["last_validated"] = OS.get_unix_time()
    
    # Log the validation
    _log_key_event(key_id, "validated", {
        "provider": key_info["provider_name"],
        "is_valid": validation_success
    })
    
    print("Validated API key for " + key_info["provider_name"] + ": " + (validation_success ? "Valid" : "Invalid"))
    return validation_success

func get_keys_for_account(account_id):
    if account_id.empty():
        return []
    
    var keys = []
    for key_id in api_keys:
        if api_keys[key_id]["account_id"] == account_id:
            # Create a sanitized copy without the actual key
            var key_copy = api_keys[key_id].duplicate()
            key_copy.erase("key")
            keys.append(key_copy)
    
    return keys

func set_security_level(key_id, security_level):
    if not key_id in api_keys:
        print("API key not found: " + key_id)
        return false
    
    if not security_level in SecurityLevel.values():
        print("Invalid security level")
        return false
    
    api_keys[key_id]["security_level"] = security_level
    print("Set security level for " + api_keys[key_id]["provider_name"] + " key to " + SecurityLevel.keys()[security_level])
    return true

func enable_key_rotation(enabled, interval_days = 90):
    rotation_enabled = enabled
    rotation_interval_days = interval_days
    
    # Update rotation due dates for existing keys
    if enabled:
        for key_id in api_keys:
            api_keys[key_id]["rotation_due"] = OS.get_unix_time() + (interval_days * 86400)
    
    print("Key rotation " + ("enabled" : "disabled") + (enabled ? " with interval " + str(interval_days) + " days" : ""))
    return true

func get_usage_stats(provider = null):
    var stats = {
        "total_keys": api_keys.size(),
        "total_usage": 0,
        "providers": {},
        "accounts": {}
    }
    
    for key_id in api_keys:
        var key_info = api_keys[key_id]
        var provider_name = key_info["provider_name"]
        var account_id = key_info["account_id"]
        var usage_count = key_info["usage_count"]
        
        # Update total usage
        stats["total_usage"] += usage_count
        
        # Update provider stats
        if not provider_name in stats["providers"]:
            stats["providers"][provider_name] = {
                "key_count": 0,
                "usage_count": 0
            }
        
        stats["providers"][provider_name]["key_count"] += 1
        stats["providers"][provider_name]["usage_count"] += usage_count
        
        # Update account stats
        if not account_id.empty():
            if not account_id in stats["accounts"]:
                stats["accounts"][account_id] = {
                    "key_count": 0,
                    "usage_count": 0
                }
            
            stats["accounts"][account_id]["key_count"] += 1
            stats["accounts"][account_id]["usage_count"] += usage_count
    }
    
    # Filter by provider if specified
    if provider != null:
        var provider_name = provider
        if provider is int and provider in ApiProvider.values():
            provider_name = ApiProvider.keys()[provider]
        
        if provider_name in stats["providers"]:
            return stats["providers"][provider_name]
        else:
            return null
    
    return stats

func _on_security_check():
    # Check for keys that need rotation
    var current_time = OS.get_unix_time()
    var keys_to_rotate = []
    
    for key_id in api_keys:
        var key_info = api_keys[key_id]
        
        # Check rotation if enabled
        if rotation_enabled and key_info["rotation_due"] > 0 and current_time > key_info["rotation_due"]:
            keys_to_rotate.append({
                "key_id": key_id,
                "provider": key_info["provider_name"],
                "days_overdue": (current_time - key_info["rotation_due"]) / 86400
            })
    }
    
    # In a real implementation, would notify about keys that need rotation
    if keys_to_rotate.size() > 0:
        print(str(keys_to_rotate.size()) + " API keys need rotation")
        # Would implement notification here

func _encrypt_key(api_key):
    # In a real implementation, would use proper encryption
    # For this demo, just add a simple prefix
    return "ENCRYPTED:" + api_key

func _decrypt_key(encrypted_key):
    # In a real implementation, would use proper decryption
    # For this demo, just remove the prefix
    if encrypted_key.begins_with("ENCRYPTED:"):
        return encrypted_key.substr(10)
    return encrypted_key

func _mask_api_key(api_key):
    # Create masked version for display/logging
    if api_key.length() <= 8:
        return "****" + api_key.substr(api_key.length() - 4, 4)
    else:
        return api_key.substr(0, 4) + "****" + api_key.substr(api_key.length() - 4, 4)

func _log_key_event(key_id, event_type, details):
    if not usage_tracking_enabled:
        return
    
    var event = {
        "timestamp": OS.get_unix_time(),
        "key_id": key_id,
        "event": event_type,
        "details": details
    }
    
    usage_logs.append(event)
    
    # Limit log size
    if usage_logs.size() > 1000:
        usage_logs.pop_front()

func import_openai_api_key(api_key, account_id = ""):
    # Validate key format
    if not api_key.begins_with("sk-"):
        print("Invalid OpenAI API key format")
        return false
    
    return add_api_key(ApiProvider.OPENAI, api_key, account_id, SecurityLevel.HIGH, "OpenAI API Key")

func import_google_api_key(api_key, client_id = "", client_secret = "", account_id = ""):
    return add_api_key(ApiProvider.GOOGLE, api_key, account_id, SecurityLevel.STANDARD, "Google API Key")