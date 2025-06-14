extends Node
class_name WordDreamCreator

signal word_created(word_data: Dictionary)
signal dream_sequence_completed(sequence_data: Dictionary)
signal device_connected(device_info: Dictionary)

# Core components
var dream_connector: Node = null
var wish_maker: Node = null
var luno_manager: Node = null

# Word creation structures
var word_database: Array = []
var dream_sequences: Array = []
var active_sequence: Dictionary = {}

# Device connections
var connected_devices: Dictionary = {
    "current": {
        "name": "primary",
        "type": "desktop",
        "status": "active",
        "last_login": 0
    },
    "secondary": [],
    "cloud": {}
}

# Configuration
var creation_config: Dictionary = {
    "auto_creation": true,
    "dream_depth_required": 3,
    "min_word_length": 3,
    "max_word_length": 12,
    "daily_creation_limit": 33,
    "creation_count": 0,
    "last_reset": 0
}

# Payment tracking
var payment_records: Array = []
var subscription_status: Dictionary = {
    "active": true,
    "renewal_date": 0,
    "tier": "creator",
    "monthly_cost": 0
}

func _ready():
    # Initialize the system
    print("💭 Word Dream Creator initializing...")
    
    # Connect to required systems
    _connect_to_systems()
    
    # Initialize word database
    _initialize_word_database()
    
    # Check device connections
    _update_device_connections()
    
    # Reset counters if needed
    _check_date_reset()

func _connect_to_systems():
    # Connect to Dream Connector
    dream_connector = get_node_or_null("/root/DreamConnector")
    if dream_connector:
        print("✓ Connected to Dream Connector")
        dream_connector.connect("dream_symbol_received", Callable(self, "_on_dream_symbol"))
        dream_connector.connect("dream_state_changed", Callable(self, "_on_dream_state_changed"))
    else:
        # Create our own dream connector if not found
        dream_connector = DreamConnector.new()
        add_child(dream_connector)
        print("✓ Created Dream Connector instance")
        dream_connector.connect("dream_symbol_received", Callable(self, "_on_dream_symbol"))
        dream_connector.connect("dream_state_changed", Callable(self, "_on_dream_state_changed"))
    
    # Connect to Wish Maker
    wish_maker = get_node_or_null("/root/WishMakerMachine")
    if wish_maker:
        print("✓ Connected to Wish Maker Machine")
    
    # Connect to LUNO
    luno_manager = get_node_or_null("/root/LunoCycleManager")
    if luno_manager:
        print("✓ Connected to LUNO Cycle Manager")
        luno_manager.register_participant("WordDreamCreator", Callable(self, "_on_luno_tick"))

func _initialize_word_database():
    # This would load the existing word database
    # For now, we'll create a sample database
    
    word_database = []
    
    # Add some sample dream-derived words
    word_database.append({
        "word": "luminus",
        "origin": "dream",
        "creation_date": OS.get_unix_time() - 86400 * 7,
        "dream_depth": 4,
        "associations": ["light", "knowledge", "interface"],
        "power_level": 8
    })
    
    word_database.append({
        "word": "ethereal",
        "origin": "dream",
        "creation_date": OS.get_unix_time() - 86400 * 3,
        "dream_depth": 3,
        "associations": ["spirit", "engine", "flow"],
        "power_level": 7
    })
    
    print("📚 Word database initialized with %d entries" % word_database.size())

func _update_device_connections():
    # Update current device info
    connected_devices.current.last_login = OS.get_unix_time()
    
    # This would check for other connected devices
    # For simulation, we'll add some sample devices
    
    if connected_devices.secondary.size() == 0:
        # Add some sample secondary devices
        connected_devices.secondary.append({
            "name": "ipad-m2",
            "type": "tablet",
            "status": "connected", 
            "last_login": OS.get_unix_time() - 3600
        })
        
        connected_devices.secondary.append({
            "name": "macbook-pro",
            "type": "laptop",
            "status": "inactive",
            "last_login": OS.get_unix_time() - 86400
        })
    
    # Cloud connection status
    connected_devices.cloud = {
        "status": "connected",
        "synced_at": OS.get_unix_time(),
        "storage_used": 128.5,  # MB
        "storage_total": 1024   # MB
    }
    
    print("🔄 Device connections updated")
    
    # Check subscription status
    _check_subscription()

func _check_date_reset():
    var current_time = OS.get_unix_time()
    var current_date = Time.get_date_dict_from_system()
    
    # Get the timestamp from the beginning of the current day
    var day_start = Time.get_unix_time_from_datetime_dict({
        "year": current_date.year,
        "month": current_date.month,
        "day": current_date.day,
        "hour": 0,
        "minute": 0,
        "second": 0
    })
    
    # Reset counter if we're on a new day
    if creation_config.last_reset < day_start:
        creation_config.creation_count = 0
        creation_config.last_reset = current_time
        print("🔄 Word creation counter reset for new day")

func _check_subscription():
    # Check if subscription is still active
    
    # For simulation, we'll set the renewal date to 30 days from now
    if subscription_status.renewal_date == 0:
        var current_date = Time.get_date_dict_from_system()
        
        # Set renewal to 30 days from now
        current_date.day += 30
        if current_date.day > 28:  # Simple handling to avoid invalid dates
            current_date.day = 28
            current_date.month += 1
            if current_date.month > 12:
                current_date.month = 1
                current_date.year += 1
        
        subscription_status.renewal_date = Time.get_unix_time_from_datetime_dict(current_date)
        subscription_status.monthly_cost = 9.99  # Example cost
    
    # Log subscription status
    var days_remaining = (subscription_status.renewal_date - OS.get_unix_time()) / 86400
    print("💰 Subscription active: %d days remaining" % days_remaining)
    
    # Record a payment if none exists
    if payment_records.size() == 0:
        payment_records.append({
            "date": OS.get_unix_time() - 86400 * 5,  # 5 days ago
            "amount": subscription_status.monthly_cost,
            "status": "completed",
            "method": "credit_card"
        })

func create_word_from_dream(dream_info: Dictionary = {}) -> Dictionary:
    # Check if we're at the daily limit
    if creation_config.creation_count >= creation_config.daily_creation_limit:
        print("⚠️ Daily word creation limit reached")
        return {
            "success": false,
            "reason": "daily_limit",
            "word": "",
            "data": null
        }
    
    # Get dream state if not provided
    if dream_info.is_empty() and dream_connector:
        dream_info = dream_connector.get_dream_state()
    
    # Check if dream depth is sufficient
    if dream_info.has("depth") and dream_info.depth < creation_config.dream_depth_required:
        print("⚠️ Dream depth insufficient for word creation (%d/%d)" % [
            dream_info.depth, 
            creation_config.dream_depth_required
        ])
        return {
            "success": false,
            "reason": "insufficient_depth",
            "word": "",
            "data": null
        }
    
    # Generate a new word from dream symbols
    var new_word = _generate_dream_word(dream_info)
    
    if new_word.empty():
        print("⚠️ Failed to generate word from dream")
        return {
            "success": false,
            "reason": "generation_failed",
            "word": "",
            "data": null
        }
    
    # Create word entry
    var word_data = {
        "word": new_word,
        "origin": "dream",
        "creation_date": OS.get_unix_time(),
        "dream_depth": dream_info.get("depth", 1),
        "associations": [],
        "power_level": dream_info.get("depth", 1) * 2
    }
    
    # Add associations based on dream symbols
    if dream_info.has("symbols") and dream_info.symbols.size() > 0:
        for symbol in dream_info.symbols:
            var association = _symbol_to_association(symbol)
            if not association.empty() and not word_data.associations.has(association):
                word_data.associations.append(association)
    
    # Add to database
    word_database.append(word_data)
    
    # Increment counter
    creation_config.creation_count += 1
    
    print("✨ Created new word from dream: '%s' (power level: %d)" % [
        new_word,
        word_data.power_level
    ])
    
    # Emit signal
    emit_signal("word_created", word_data)
    
    return {
        "success": true,
        "word": new_word,
        "data": word_data
    }

func _generate_dream_word(dream_info: Dictionary) -> String:
    # This would be more sophisticated in a real implementation
    # For now, we'll create a word based on dream symbols or a template
    
    # If we have dream symbols, use them as inspiration
    if dream_info.has("symbols") and dream_info.symbols.size() > 0:
        # Extract parts from symbols
        var parts = []
        for symbol in dream_info.symbols:
            if symbol is String and symbol.length() >= 2:
                parts.append(symbol.substr(0, 2).to_lower())
        
        # If we have enough parts, combine them
        if parts.size() >= 2:
            # Take some parts and combine them
            var word_base = ""
            for i in range(min(3, parts.size())):
                word_base += parts[i]
            
            # Add a common suffix
            var suffixes = ["um", "ia", "on", "ex", "is", "us"]
            var suffix = suffixes[randi() % suffixes.size()]
            
            return word_base + suffix
    
    # If we don't have symbols or couldn't create from them, use templates
    var prefixes = ["lum", "eth", "qua", "zep", "vol", "cen", "arm", "dyn"]
    var middles = ["in", "er", "an", "or", "ul", "im", "ax"]
    var suffixes = ["ium", "ius", "ex", "on", "us", "is", "um", "ia"]
    
    var prefix = prefixes[randi() % prefixes.size()]
    var middle = middles[randi() % middles.size()]
    var suffix = suffixes[randi() % suffixes.size()]
    
    # Sometimes skip the middle
    if randf() > 0.5:
        return prefix + suffix
    else:
        return prefix + middle + suffix

func _symbol_to_association(symbol: String) -> String:
    # Convert a dream symbol to a word association
    # This would be more sophisticated in a real implementation
    
    # Simple mapping based on first letter
    var mappings = {
        "G": "genesis",
        "F": "formation",
        "C": "complexity",
        "A": "awakening",
        "E": "enlightenment",
        "M": "manifestation",
        "H": "harmony",
        "T": "transcendence",
        "U": "unity",
        "B": "beyond"
    }
    
    if symbol.length() > 0 and mappings.has(symbol.left(1)):
        return mappings[symbol.left(1)]
    
    # Default associations
    var defaults = ["dream", "vision", "creation", "word", "thought"]
    return defaults[randi() % defaults.size()]

func start_dream_sequence():
    # Start a new dream sequence for word creation
    
    # Check if dream connector is available
    if not dream_connector:
        print("⚠️ Cannot start dream sequence: Dream Connector not available")
        return false
    
    # Enter dream state
    if not dream_connector.enter_dream():
        print("⚠️ Failed to enter dream state")
        return false
    
    # Initialize dream sequence
    active_sequence = {
        "id": "seq_" + str(OS.get_unix_time()),
        "start_time": OS.get_unix_time(),
        "end_time": 0,
        "symbols_collected": [],
        "words_created": [],
        "current_depth": 0,
        "target_depth": creation_config.dream_depth_required,
        "completed": false
    }
    
    print("🌙 Dream sequence started: %s" % active_sequence.id)
    return true

func end_dream_sequence() -> Dictionary:
    # End the current dream sequence
    
    # Check if we have an active sequence
    if active_sequence.is_empty():
        print("⚠️ No active dream sequence to end")
        return {}
    
    # Exit dream state if dream connector is available
    if dream_connector:
        dream_connector.exit_dream()
    
    # Complete the sequence
    active_sequence.end_time = OS.get_unix_time()
    active_sequence.completed = true
    
    # Create a final word if we have sufficient depth
    if active_sequence.current_depth >= creation_config.dream_depth_required:
        var dream_info = {
            "depth": active_sequence.current_depth,
            "symbols": active_sequence.symbols_collected
        }
        
        var result = create_word_from_dream(dream_info)
        if result.success:
            active_sequence.words_created.append(result.word)
    
    # Store the completed sequence
    var completed_sequence = active_sequence.duplicate()
    dream_sequences.append(completed_sequence)
    
    print("🌙 Dream sequence completed: %s" % active_sequence.id)
    print("   Duration: %d seconds, Words created: %d" % [
        completed_sequence.end_time - completed_sequence.start_time,
        completed_sequence.words_created.size()
    ])
    
    # Emit signal
    emit_signal("dream_sequence_completed", completed_sequence)
    
    # Clear active sequence
    active_sequence = {}
    
    return completed_sequence

func connect_device(device_info: Dictionary) -> bool:
    # Connect a new device to the system
    
    # Check if device already exists
    for device in connected_devices.secondary:
        if device.name == device_info.name:
            # Update existing device
            device.status = "connected"
            device.last_login = OS.get_unix_time()
            
            print("🔄 Reconnected existing device: %s" % device.name)
            emit_signal("device_connected", device)
            return true
    
    # Add new device
    var new_device = {
        "name": device_info.name,
        "type": device_info.get("type", "unknown"),
        "status": "connected",
        "last_login": OS.get_unix_time()
    }
    
    connected_devices.secondary.append(new_device)
    
    print("➕ Connected new device: %s (%s)" % [new_device.name, new_device.type])
    emit_signal("device_connected", new_device)
    
    return true

func record_payment(amount: float, method: String = "credit_card") -> Dictionary:
    # Record a new payment
    
    var payment = {
        "date": OS.get_unix_time(),
        "amount": amount,
        "status": "completed",
        "method": method
    }
    
    payment_records.append(payment)
    
    # Update subscription
    var current_date = Time.get_date_dict_from_system()
    
    # Set renewal to 30 days from now
    current_date.month += 1
    if current_date.month > 12:
        current_date.month = 1
        current_date.year += 1
    
    subscription_status.renewal_date = Time.get_unix_time_from_datetime_dict(current_date)
    subscription_status.monthly_cost = amount
    
    print("💰 Payment recorded: $%.2f via %s" % [amount, method])
    print("   Subscription renewed until: %04d-%02d-%02d" % [
        current_date.year, 
        current_date.month, 
        current_date.day
    ])
    
    return payment

func get_words_by_power(min_power: int = 0, max_power: int = 10) -> Array:
    # Get words within a power range
    var result = []
    
    for word in word_database:
        if word.power_level >= min_power and word.power_level <= max_power:
            result.append(word)
    
    return result

func search_words(query: String) -> Array:
    # Search for words
    var result = []
    var lowered_query = query.to_lower()
    
    for word in word_database:
        # Check word itself
        if word.word.to_lower().contains(lowered_query):
            result.append(word)
            continue
        
        # Check associations
        for association in word.associations:
            if association.to_lower().contains(lowered_query):
                result.append(word)
                break
    
    return result

func _on_dream_symbol(symbol: String):
    # Handle incoming dream symbols
    if not active_sequence.is_empty():
        # Add to sequence
        if not active_sequence.symbols_collected.has(symbol):
            active_sequence.symbols_collected.append(symbol)
            print("💫 Dream symbol collected: %s" % symbol)
    
    # If we have wish maker, make a special wish
    if wish_maker and randf() > 0.7:  # 30% chance
        var wish_text = "I wish for the dream symbol %s to inspire creation" % symbol
        wish_maker.make_wish(wish_text, {"origin": "dream", "symbol": symbol})

func _on_dream_state_changed(state: Dictionary):
    # Handle dream state changes
    if not active_sequence.is_empty():
        active_sequence.current_depth = state.get("depth", 0)
        
        print("🌊 Dream depth changed: %d/%d" % [
            active_sequence.current_depth,
            active_sequence.target_depth
        ])
        
        # Auto-create word if we reach the required depth
        if active_sequence.current_depth >= active_sequence.target_depth and creation_config.auto_creation:
            var dream_info = {
                "depth": active_sequence.current_depth,
                "symbols": active_sequence.symbols_collected
            }
            
            var result = create_word_from_dream(dream_info)
            if result.success:
                active_sequence.words_created.append(result.word)

func _on_luno_tick(turn: int, phase_name: String):
    # Special case for evolution
    if turn == 0 and phase_name == "Evolution":
        print("✨ WordDreamCreator evolving with system")
        
        # Evolve word creation capabilities
        creation_config.dream_depth_required = max(1, creation_config.dream_depth_required - 1)
        creation_config.daily_creation_limit += 3
        
        print("🔼 Word creation enhanced: Required depth: %d, Daily limit: %d" % [
            creation_config.dream_depth_required,
            creation_config.daily_creation_limit
        ])
        
        return
    
    # Process based on current phase
    match phase_name:
        "Genesis":
            # Genesis phase is ideal for word creation
            if not active_sequence.is_empty():
                print("🌱 Genesis phase boosting word creation potential")
                active_sequence.current_depth += 1
        
        "Consciousness", "Enlightenment":
            # These phases enhance word power
            print("✨ %s phase enhancing word power" % phase_name)
        
        "Unity":
            # Unity phase connects words
            print("🔄 Unity phase strengthening word connections")

# Public API methods
func get_word_database() -> Array:
    return word_database

func get_dream_sequences() -> Array:
    return dream_sequences

func get_connected_devices() -> Dictionary:
    return connected_devices

func get_creation_config() -> Dictionary:
    return creation_config

func get_subscription_status() -> Dictionary:
    return subscription_status

func get_payment_history() -> Array:
    return payment_records

# Example usage:
# var word_creator = WordDreamCreator.new()
# add_child(word_creator)
# word_creator.start_dream_sequence()
# ... later ...
# var sequence = word_creator.end_dream_sequence()