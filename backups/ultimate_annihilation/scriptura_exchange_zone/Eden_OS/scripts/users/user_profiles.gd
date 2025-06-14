extends Node

class_name UserProfiles

# User Profile System for Eden_OS
# Manages user identities, permissions, and preferences

signal user_created(username)
signal user_switched(old_username, new_username)
signal user_preference_changed(username, preference, value)
signal user_permission_changed(username, permission, value)

# User constants
const DEFAULT_USER = "JSH"
const ADMIN_USERS = ["JSH", "BaronJah", "hotshot12"]
const DEFAULT_PERMISSIONS = {
    "admin": false,
    "create_dimension": true,
    "create_word": true,
    "connect_words": true,
    "modify_terminal": true,
    "create_game": true
}

# User data
var user_database = {}
var active_user = DEFAULT_USER
var nickname_map = {}
var user_activity = {}
var user_customizations = {}

# Session data
var session_start_time = 0
var user_history = []

# JSH's nicknames
var jsh_nicknames = [
    "JSH", "BaronJah", "lolelitaman", "hotshot12", "hotshot1211", 
    "baronjahpl", "baaronjah", "baronjah0", "baronjah5"
]

func _ready():
    initialize_user_system()
    print("User Profile System initialized with default user: " + DEFAULT_USER)

func initialize_user_system():
    # Create JSH user and all aliases
    for nickname in jsh_nicknames:
        create_user(nickname, true)  # All are admin users
        
        # Map all nicknames to JSH
        nickname_map[nickname] = "JSH"
    
    # Set some custom preferences
    set_user_preference("JSH", "theme", "dark")
    set_user_preference("JSH", "color_scheme", "blue")
    set_user_preference("JSH", "font_size", 14)
    
    # Start session
    session_start_time = Time.get_unix_time_from_system()
    switch_user(DEFAULT_USER)

func create_user(username, is_admin=false):
    if user_database.has(username):
        return "User '" + username + "' already exists"
    
    # Create user
    user_database[username] = {
        "created": Time.get_unix_time_from_system(),
        "last_active": Time.get_unix_time_from_system(),
        "is_admin": is_admin,
        "permissions": DEFAULT_PERMISSIONS.duplicate(),
        "preferences": {},
        "statistics": {
            "commands_executed": 0,
            "words_created": 0,
            "dimensions_visited": 0,
            "games_created": 0
        }
    }
    
    # Set admin override
    if is_admin:
        user_database[username]["permissions"]["admin"] = true
    
    # Create user activity log
    user_activity[username] = []
    
    # Create customizations
    user_customizations[username] = {
        "theme": "default",
        "color": Color(0.2, 0.4, 0.8),
        "font": "monospace"
    }
    
    # Emit signal
    emit_signal("user_created", username)
    
    return "User '" + username + "' created" + (" with admin privileges" if is_admin else "")

func switch_user(username):
    if not user_database.has(username):
        return "User '" + username + "' not found"
    
    var old_username = active_user
    active_user = username
    
    # Update activity timestamps
    user_database[username]["last_active"] = Time.get_unix_time_from_system()
    
    # Add to history
    user_history.append({
        "from": old_username,
        "to": username,
        "time": Time.get_unix_time_from_system()
    })
    
    # Record in activity log
    add_user_activity(username, "login", {"previous_user": old_username})
    
    # Emit signal
    emit_signal("user_switched", old_username, username)
    
    return "Switched from user '" + old_username + "' to '" + username + "'"

func is_admin(username=null):
    if username == null:
        username = active_user
    
    if not user_database.has(username):
        return false
    
    return user_database[username]["is_admin"]

func has_permission(permission, username=null):
    if username == null:
        username = active_user
    
    if not user_database.has(username):
        return false
    
    # Admins have all permissions
    if user_database[username]["is_admin"]:
        return true
    
    if user_database[username]["permissions"].has(permission):
        return user_database[username]["permissions"][permission]
    
    return false

func set_permission(username, permission, value):
    if not user_database.has(username):
        return "User '" + username + "' not found"
    
    # Set permission
    user_database[username]["permissions"][permission] = value
    
    # Emit signal
    emit_signal("user_permission_changed", username, permission, value)
    
    return "Permission '" + permission + "' " + ("granted to" if value else "revoked from") + " user '" + username + "'"

func set_user_preference(username, preference, value):
    if not user_database.has(username):
        return "User '" + username + "' not found"
    
    # Set preference
    user_database[username]["preferences"][preference] = value
    
    # Emit signal
    emit_signal("user_preference_changed", username, preference, value)
    
    return "Preference '" + preference + "' set to '" + str(value) + "' for user '" + username + "'"

func get_user_preference(username, preference, default_value=null):
    if not user_database.has(username):
        return default_value
    
    if user_database[username]["preferences"].has(preference):
        return user_database[username]["preferences"][preference]
    
    return default_value

func update_user_statistic(username, statistic, increment=1):
    if not user_database.has(username):
        return false
    
    if not user_database[username]["statistics"].has(statistic):
        user_database[username]["statistics"][statistic] = 0
    
    user_database[username]["statistics"][statistic] += increment
    
    return true

func add_user_activity(username, activity_type, details={}):
    if not user_database.has(username):
        return false
    
    # Add activity
    user_activity[username].append({
        "type": activity_type,
        "time": Time.get_unix_time_from_system(),
        "details": details
    })
    
    return true

func get_user_info(username=null):
    if username == null:
        username = active_user
    
    if not user_database.has(username):
        return "User '" + username + "' not found"
    
    var info = "User: " + username + "\n"
    
    # Check if this is a nickname
    if nickname_map.has(username) and nickname_map[username] != username:
        info += "Primary Identity: " + nickname_map[username] + "\n"
    
    # Add basic info
    info += "Admin: " + str(user_database[username]["is_admin"]) + "\n"
    info += "Created: " + str(Time.get_datetime_string_from_unix_time(user_database[username]["created"])) + "\n"
    info += "Last Active: " + str(Time.get_datetime_string_from_unix_time(user_database[username]["last_active"])) + "\n"
    
    # Add statistics
    info += "\nStatistics:\n"
    for stat in user_database[username]["statistics"]:
        info += "- " + stat + ": " + str(user_database[username]["statistics"][stat]) + "\n"
    
    # Add preferences
    if user_database[username]["preferences"].size() > 0:
        info += "\nPreferences:\n"
        for pref in user_database[username]["preferences"]:
            info += "- " + pref + ": " + str(user_database[username]["preferences"][pref]) + "\n"
    
    return info

func get_all_nicknames(username=null):
    if username == null:
        username = active_user
    
    var nicknames = []
    
    for nick in nickname_map:
        if nickname_map[nick] == username:
            nicknames.append(nick)
    
    return nicknames

func process_command(args):
    if args.size() == 0:
        return "User Profile System. Current user: " + active_user + "\nUse 'user switch', 'user info', 'user create', 'user list', 'user nicknames'"
    
    match args[0]:
        "switch", "change":
            if args.size() < 2:
                return "Usage: user switch <username>"
                
            return switch_user(args[1])
        "create":
            if args.size() < 2:
                return "Usage: user create <username> [admin:true|false]"
                
            var is_admin = false
            if args.size() >= 3 and args[2] == "true":
                is_admin = true
                
            return create_user(args[1], is_admin)
        "info":
            if args.size() < 2:
                return get_user_info()
                
            return get_user_info(args[1])
        "list":
            return list_users()
        "nicknames":
            if args.size() < 2:
                return list_nicknames()
                
            return list_nicknames(args[1])
        "permission":
            if args.size() < 3:
                return "Usage: user permission <username> <permission> [value:true|false]"
                
            var username = args[1]
            var permission = args[2]
            
            if args.size() >= 4:
                var value = args[3] == "true"
                return set_permission(username, permission, value)
            else:
                if not user_database.has(username):
                    return "User '" + username + "' not found"
                    
                if user_database[username]["permissions"].has(permission):
                    return "Permission '" + permission + "' = " + str(user_database[username]["permissions"][permission])
                else:
                    return "Permission not found"
        "preference":
            if args.size() < 3:
                return "Usage: user preference <username> <preference> [value]"
                
            var username = args[1]
            var preference = args[2]
            
            if args.size() >= 4:
                return set_user_preference(username, preference, args[3])
            else:
                var value = get_user_preference(username, preference, "not set")
                return "Preference '" + preference + "' = " + str(value)
        "activity":
            if args.size() < 2:
                return show_user_activity()
                
            return show_user_activity(args[1])
        _:
            return "Unknown user command: " + args[0]

func list_users():
    var result = "Users (" + str(user_database.size()) + "):\n"
    
    for username in user_database:
        var status = " "
        if username == active_user:
            status = "*"
            
        result += status + " " + username
        
        if user_database[username]["is_admin"]:
            result += " (Admin)"
        
        if nickname_map.has(username) and nickname_map[username] != username:
            result += " → " + nickname_map[username]
            
        result += "\n"
    
    return result

func list_nicknames(username=null):
    if username == null:
        username = active_user
    
    var nicknames = get_all_nicknames(username)
    
    if nicknames.size() == 0:
        return "No nicknames found for user '" + username + "'"
    
    var result = "Nicknames for '" + username + "' (" + str(nicknames.size()) + "):\n"
    result += ", ".join(nicknames)
    
    return result

func show_user_activity(username=null):
    if username == null:
        username = active_user
    
    if not user_database.has(username):
        return "User '" + username + "' not found"
    
    if not user_activity.has(username) or user_activity[username].size() == 0:
        return "No activity recorded for user '" + username + "'"
    
    var count = min(10, user_activity[username].size())
    var result = "Recent Activity for '" + username + "' (last " + str(count) + "):\n"
    
    for i in range(max(0, user_activity[username].size() - count), user_activity[username].size()):
        var activity = user_activity[username][i]
        var timestamp = Time.get_datetime_string_from_unix_time(activity["time"])
        
        result += timestamp + ": " + activity["type"]
        
        if activity["details"].size() > 0:
            result += " (" + str(activity["details"]) + ")"
            
        result += "\n"
    
    return result