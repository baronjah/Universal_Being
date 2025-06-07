extends Node

class_name SharedAccountConnector

# Connection states
enum ConnectionState {
    DISCONNECTED,
    CONNECTING,
    CONNECTED,
    ERROR
}

# Account types
enum AccountType {
    LOCAL,
    WINDOWS,
    GAME,
    GODOT
}

# Properties
var current_account_id = ""
var current_player_name = ""
var connection_state = ConnectionState.DISCONNECTED
var account_type = AccountType.LOCAL
var account_data = {}
var systems_connected = []

# Signals
signal account_connected(account_id, player_name)
signal account_disconnected(account_id)
signal data_synchronized()
signal connection_state_changed(new_state)

func _ready():
    # Initialize the connector
    print("SharedAccountConnector initialized")
    
    # Try to load existing account data
    load_account_data()
    
    # Connect to available systems
    connect_to_available_systems()

func connect_to_available_systems():
    # Check for AkashicDatabase
    if has_node("/root/AkashicDatabase") or get_node_or_null("/root/AkashicDatabase"):
        var akashic_db = get_node("/root/AkashicDatabase")
        systems_connected.append("AkashicDatabase")
        print("Connected to AkashicDatabase")
    
    # Check for other systems to connect with
    var system_nodes = [
        "WordProcessorTasks",
        "EtherealEngine",
        "ThreadManager"
    ]
    
    for system in system_nodes:
        if has_node("/root/" + system) or get_node_or_null("/root/" + system):
            systems_connected.append(system)
            print("Connected to " + system)
    
    # Update connection state
    if systems_connected.size() > 0:
        connection_state = ConnectionState.CONNECTED
        emit_signal("connection_state_changed", connection_state)

func connect_account(account_id = "", player_name = "", type = AccountType.LOCAL):
    # Set connection to connecting state
    connection_state = ConnectionState.CONNECTING
    emit_signal("connection_state_changed", connection_state)
    
    # Generate new account ID if not provided
    if account_id.empty():
        account_id = generate_unique_id()
    
    # Generate player name if not provided
    if player_name.empty():
        player_name = "Player_" + str(OS.get_unix_time()).substr(6, 4)
    
    # Set current account properties
    current_account_id = account_id
    current_player_name = player_name
    account_type = type
    
    # Create initial account data if new
    if not account_data.has("points"):
        account_data = {
            "points": 0,
            "dimension": 1,
            "preferences": {},
            "systems_access": {},
            "created_at": OS.get_datetime(),
            "last_login": OS.get_datetime()
        }
    else:
        # Update last login
        account_data["last_login"] = OS.get_datetime()
    
    # Update connection state
    connection_state = ConnectionState.CONNECTED
    emit_signal("connection_state_changed", connection_state)
    emit_signal("account_connected", current_account_id, current_player_name)
    
    # Save the updated data
    save_account_data()
    
    return current_account_id

func disconnect_account():
    # Update last session data
    if not current_account_id.empty():
        account_data["last_logout"] = OS.get_datetime()
        save_account_data()
    
    var old_id = current_account_id
    
    # Reset account variables
    current_account_id = ""
    current_player_name = ""
    account_data = {}
    
    # Update connection state
    connection_state = ConnectionState.DISCONNECTED
    emit_signal("connection_state_changed", connection_state)
    emit_signal("account_disconnected", old_id)

func load_account_data():
    # Check if we have a saved account
    var file = File.new()
    var filepath = "user://account_data.json"
    
    if file.file_exists(filepath):
        file.open(filepath, File.READ)
        var json_text = file.get_as_text()
        file.close()
        
        var json = JSON.parse(json_text)
        if json.error == OK:
            var data = json.result
            
            # Load account data if valid
            if data.has("account_id") and data.has("player_name"):
                current_account_id = data["account_id"]
                current_player_name = data["player_name"]
                account_data = data.get("account_data", {})
                account_type = data.get("account_type", AccountType.LOCAL)
                
                # Update connection state
                connection_state = ConnectionState.CONNECTED
                emit_signal("connection_state_changed", connection_state)
                emit_signal("account_connected", current_account_id, current_player_name)
                
                print("Loaded account for: " + current_player_name)
                return true
    
    # No saved account or couldn't load it
    print("No saved account found or couldn't load it")
    return false

func save_account_data():
    # Skip if no account is loaded
    if current_account_id.empty():
        return false
    
    # Prepare data to save
    var save_data = {
        "account_id": current_account_id,
        "player_name": current_player_name,
        "account_type": account_type,
        "account_data": account_data
    }
    
    # Save to file
    var file = File.new()
    var filepath = "user://account_data.json"
    file.open(filepath, File.WRITE)
    file.store_string(JSON.print(save_data, "  "))
    file.close()
    
    print("Saved account data for: " + current_player_name)
    return true

func update_account_data(new_data):
    # Merge new data with existing account data
    for key in new_data:
        account_data[key] = new_data[key]
    
    # Save the updated data
    save_account_data()
    
    # Synchronize with connected systems
    synchronize_data()
    
    return account_data

func synchronize_data():
    # Placeholder for syncing across systems
    # Would implement actual synchronization with other systems
    
    print("Synchronizing account data across " + str(systems_connected.size()) + " systems")
    
    # Emit signal for other systems to listen to
    emit_signal("data_synchronized")
    
    return true

func generate_unique_id():
    # Generate a simple unique ID based on time and random number
    return str(OS.get_unix_time()) + "_" + str(randi() % 10000)

# Getters
func get_current_account_id():
    return current_account_id
    
func get_current_player_name():
    return current_player_name
    
func get_account_type_string():
    match account_type:
        AccountType.LOCAL:
            return "Local"
        AccountType.WINDOWS:
            return "Windows"
        AccountType.GAME:
            return "Game"
        AccountType.GODOT:
            return "Godot"
        _:
            return "Unknown"
            
func get_connection_state_string():
    match connection_state:
        ConnectionState.DISCONNECTED:
            return "Disconnected"
        ConnectionState.CONNECTING:
            return "Connecting"
        ConnectionState.CONNECTED:
            return "Connected"
        ConnectionState.ERROR:
            return "Error"
        _:
            return "Unknown"

func get_account_data(key = ""):
    if key.empty():
        return account_data
    
    if account_data.has(key):
        return account_data[key]
    
    return null