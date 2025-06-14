extends Node

# Global Firewall Manager
# Singleton that provides easy access to the WordFirewall system from anywhere

# References
var word_firewall = null
var config = {}
var is_initialized = false

# Signals (forwarded from WordFirewall)
signal security_level_changed(from_level, to_level)
signal intrusion_detected(word, severity, path)
signal word_transformed(original, transformed)
signal rule_triggered(rule_name, word, action)
signal firewall_initialized()

func _ready():
    # Make this a singleton
    name = "FirewallManager"
    
    # Load firewall configuration
    load_configuration()
    
    # Initialize firewall when idle (to ensure other systems are ready)
    call_deferred("initialize_firewall")

func load_configuration():
    var config_path = "res://scripts/security/firewall_config.json"
    var file = FileAccess.open(config_path, FileAccess.READ)
    
    if file:
        var json_string = file.get_as_text()
        file.close()
        
        var json_result = JSON.parse_string(json_string)
        if json_result:
            config = json_result
            print("[FirewallManager] Configuration loaded successfully")
        else:
            push_error("[FirewallManager] Failed to parse configuration file")
            config = {}
    else:
        push_error("[FirewallManager] Failed to open configuration file")
        config = {}

func initialize_firewall():
    # Create and initialize the WordFirewall
    word_firewall = load("res://scripts/security/WordFirewall.gd").new()
    word_firewall.name = "WordFirewall"
    add_child(word_firewall)
    
    # Connect signals
    word_firewall.security_level_changed.connect(_on_security_level_changed)
    word_firewall.intrusion_detected.connect(_on_intrusion_detected)
    word_firewall.word_transformed.connect(_on_word_transformed)
    word_firewall.rule_triggered.connect(_on_rule_triggered)
    
    # Apply configuration
    apply_configuration()
    
    is_initialized = true
    print("[FirewallManager] WordFirewall initialized and configured")
    emit_signal("firewall_initialized")

func apply_configuration():
    if not word_firewall or not config:
        return
    
    # Apply security level
    if "security_level" in config:
        word_firewall.set_security_level(config.security_level)
    
    # Apply auto activation setting
    if "auto_activate" in config:
        if config.auto_activate:
            word_firewall.activate()
        else:
            word_firewall.deactivate()
    
    # Apply protected paths
    if "protected_paths" in config:
        for path in config.protected_paths:
            word_firewall.add_protected_path(path)
    
    # Apply custom transformations
    if "custom_transformations" in config:
        for original in config.custom_transformations:
            word_firewall.add_word_transformation(
                original, 
                config.custom_transformations[original]
            )
    
    # Apply rule sets
    if "rule_sets" in config:
        for rule_name in config.rule_sets:
            if rule_name in word_firewall.rule_sets:
                # Rule already exists, update enabled state
                if config.rule_sets[rule_name].enabled:
                    word_firewall.enable_rule(rule_name)
                else:
                    word_firewall.disable_rule(rule_name)
            else:
                # Add new rule
                word_firewall.add_rule(rule_name, config.rule_sets[rule_name])
    
    print("[FirewallManager] Configuration applied")

# ================ PUBLIC API ================
# These functions provide easy access to the WordFirewall

func process_word(word: String, source_path: String = "", context: Dictionary = {}) -> Dictionary:
    if is_initialized and word_firewall:
        return word_firewall.process_word(word, source_path, context)
    else:
        # Return safe default if not yet initialized
        return {"word": word, "allowed": true, "transformed": false}

func set_security_level(level: int) -> bool:
    if is_initialized and word_firewall:
        return word_firewall.set_security_level(level)
    return false

func get_security_status() -> Dictionary:
    if is_initialized and word_firewall:
        return word_firewall.get_security_status()
    else:
        return {
            "active": false,
            "security_level": "NOT_INITIALIZED",
            "protected_paths": 0,
            "active_rules": 0,
            "intrusions_detected": 0,
            "transformations_active": 0
        }

func activate():
    if is_initialized and word_firewall:
        word_firewall.activate()

func deactivate():
    if is_initialized and word_firewall:
        word_firewall.deactivate()

func test_word(word: String, path: String = "") -> Dictionary:
    if is_initialized and word_firewall:
        return word_firewall.test_word(word, path)
    else:
        # Return safe default if not yet initialized
        return {"word": word, "allowed": true, "transformed": false}

func add_protected_path(path: String):
    if is_initialized and word_firewall:
        word_firewall.add_protected_path(path)

func remove_protected_path(path: String):
    if is_initialized and word_firewall:
        word_firewall.remove_protected_path(path)

func add_word_transformation(original: String, transformed: String):
    if is_initialized and word_firewall:
        word_firewall.add_word_transformation(original, transformed)

func activate_divine_protection():
    if is_initialized and word_firewall:
        return word_firewall.activate_divine_protection()
    return false

# ================ SIGNAL FORWARDERS ================
# These functions receive signals from the firewall and forward them

func _on_security_level_changed(from_level, to_level):
    emit_signal("security_level_changed", from_level, to_level)

func _on_intrusion_detected(word, severity, path):
    emit_signal("intrusion_detected", word, severity, path)
    
    # Handle based on notification settings
    if config.get("notification_settings", {}).get("notify_on_intrusion", true):
        notify_intrusion(word, severity, path)

func _on_word_transformed(original, transformed):
    emit_signal("word_transformed", original, transformed)
    
    # Log if enabled
    if config.get("scanner_settings", {}).get("log_all_transformations", true):
        print("[FirewallManager] Word transformed: " + original + " → " + transformed)

func _on_rule_triggered(rule_name, word, action):
    emit_signal("rule_triggered", rule_name, word, action)
    
    # Notify if enabled
    if config.get("notification_settings", {}).get("notify_on_rule_trigger", false):
        print("[FirewallManager] Rule triggered: " + rule_name + " on word: " + word)

# ================ NOTIFICATION SYSTEM ================
func notify_intrusion(word, severity, path):
    var style = config.get("notification_settings", {}).get("notification_style", "minimal")
    
    if style == "minimal":
        print("[SECURITY ALERT] Blocked: " + word)
    else:
        print("[SECURITY ALERT] Intrusion detected:")
        print("  Word: " + word)
        print("  Severity: " + str(severity))
        print("  Path: " + path)
    
    # In a full implementation, this would display a UI notification

# ================ HELPER FUNCTIONS ================
func get_security_level_name(level: int) -> String:
    if word_firewall:
        return word_firewall.SECURITY_LEVELS[level]
    else:
        return "UNKNOWN"