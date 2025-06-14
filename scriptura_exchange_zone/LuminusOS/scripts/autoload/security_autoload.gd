extends Node

# Autoload script for initializing security systems
# Add this to your project's autoload list with name "SecuritySystem"

# References
var firewall_manager = null

func _ready():
    # Initialize security systems when the game starts
    initialize_security()
    print("Security systems autoload initialized")

func initialize_security():
    # Create and initialize the FirewallManager
    firewall_manager = load("res://scripts/security/FirewallManager.gd").new()
    firewall_manager.name = "FirewallManager"
    get_tree().root.add_child(firewall_manager)
    
    # Connect to firewall signals
    firewall_manager.firewall_initialized.connect(_on_firewall_initialized)
    firewall_manager.intrusion_detected.connect(_on_intrusion_detected)
    
    print("FirewallManager initialized as global singleton")

func _on_firewall_initialized():
    # Example of setting up additional security after firewall is ready
    print("Firewall initialized - setting up additional security measures")
    
    # Add default protected paths for all drives
    var paths_to_protect = [
        "/mnt/c/Users/Percision 15/",
        "/mnt/d/"
    ]
    
    for path in paths_to_protect:
        firewall_manager.add_protected_path(path)
    
    # Add game-specific word transformations
    firewall_manager.add_word_transformation("game", "interactive_reality")
    firewall_manager.add_word_transformation("play", "experience")
    firewall_manager.add_word_transformation("player", "creator")
    
    print("Additional security measures configured")

func _on_intrusion_detected(word, severity, path):
    # Log all intrusions to security log
    var timestamp = Time.get_datetime_string_from_system()
    var log_message = "[" + timestamp + "] SECURITY: Blocked word '" + word + "' (severity: " + str(severity) + ")"
    
    print(log_message)
    # In a complete implementation, would write to security log file
    
    # Take action based on severity
    if severity >= 3:
        # High severity - trigger emergency response
        print("HIGH SEVERITY INTRUSION DETECTED - Emergency protocols activated")
        # Would implement additional protection here
    
# Global security helper functions - accessible from anywhere via SecuritySystem singleton

# Check if a word is safe before processing
func is_word_safe(word: String, context: String = "") -> bool:
    if not firewall_manager or not firewall_manager.is_initialized:
        return true  # Default to allowing if security isn't ready
    
    var result = firewall_manager.test_word(word, context)
    return result.allowed

# Process a word through security system, returning safe version
func secure_word(word: String, context: String = "") -> String:
    if not firewall_manager or not firewall_manager.is_initialized:
        return word  # Return original if security isn't ready
    
    var result = firewall_manager.process_word(word, context)
    return result.word  # Return potentially transformed word

# Get current security level
func get_security_level() -> String:
    if not firewall_manager or not firewall_manager.is_initialized:
        return "Not initialized"
    
    var status = firewall_manager.get_security_status()
    return status.security_level

# Enable divine protection mode
func activate_divine_protection() -> bool:
    if not firewall_manager or not firewall_manager.is_initialized:
        return false
    
    return firewall_manager.activate_divine_protection()