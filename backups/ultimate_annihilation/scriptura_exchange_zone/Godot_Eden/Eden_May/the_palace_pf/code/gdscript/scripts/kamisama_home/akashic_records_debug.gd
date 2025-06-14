# Akashic Records Debug Helper
# This script provides logging and debugging tools for the Akashic Records system integration

extends Node

enum LogLevel {
    ERROR = 0,    # Only errors 
    WARNING = 1,  # Errors and warnings
    INFO = 2,     # Errors, warnings, and general info
    DEBUG = 3     # All messages including debug details
}

# Set current log level
var current_log_level = LogLevel.INFO

# File for extended logging
var log_file = null
var log_to_file = false
var log_path = "res://logs/akashic_records.log"

func _ready():
    if log_to_file:
        # Open log file
        var dir = DirAccess.open("res://")
        if dir and not dir.dir_exists("res://logs"):
            dir.make_dir("res://logs")
        
        log_file = FileAccess.open(log_path, FileAccess.WRITE)
        if log_file:
            var timestamp = Time.get_datetime_string_from_system()
            log_file.store_line("=== Akashic Records Log Started: " + timestamp + " ===")
        else:
            push_error("Failed to open Akashic Records log file.")

func _exit_tree():
    if log_file:
        var timestamp = Time.get_datetime_string_from_system()
        log_file.store_line("=== Akashic Records Log Ended: " + timestamp + " ===")
        log_file.close()

# Log an error message
func error(message: String) -> void:
    _log(LogLevel.ERROR, "[ERROR] " + message)

# Log a warning message
func warning(message: String) -> void:
    if current_log_level >= LogLevel.WARNING:
        _log(LogLevel.WARNING, "[WARNING] " + message)

# Log an info message
func info(message: String) -> void:
    if current_log_level >= LogLevel.INFO:
        _log(LogLevel.INFO, "[INFO] " + message)

# Log a debug message
func debug(message: String) -> void:
    if current_log_level >= LogLevel.DEBUG:
        _log(LogLevel.DEBUG, "[DEBUG] " + message)

# Internal logging function
func _log(level: int, message: String) -> void:
    var timestamp = Time.get_datetime_string_from_system() 
    var formatted_message = timestamp + " " + message
    
    # Log to console
    print(formatted_message)
    
    # Log to file if enabled
    if log_to_file and log_file:
        log_file.store_line(formatted_message)

# Check system integrity
func verify_system() -> bool:
    info("Verifying Akashic Records system integrity...")
    
    var success = true
    
    # Check for essential classes
    if not ClassDB.class_exists("AkashicRecordsManager"):
        error("AkashicRecordsManager class not found")
        success = false
    
    if not ClassDB.class_exists("DynamicDictionary"):
        error("DynamicDictionary class not found")
        success = false
    
    if not ClassDB.class_exists("WordEntry"):
        error("WordEntry class not found")
        success = false
    
    if not ClassDB.class_exists("InteractionEngine"):
        error("InteractionEngine class not found")
        success = false
    
    if not ClassDB.class_exists("ZoneManager"):
        error("ZoneManager class not found")
        success = false
    
    # Check for integration
    var main = Engine.get_main_loop().root.get_child(0)
    if main and main.has_method("get_akashic_records"):
        var akashic_records = main.get_akashic_records()
        if akashic_records:
            info("Akashic Records integration found in main scene")
        else:
            warning("Akashic Records integration method exists but returns null")
            success = false
    else:
        error("Akashic Records integration not found in main scene")
        success = false
    
    # Check for required directories
    var dir = DirAccess.open("res://")
    if dir:
        if not dir.dir_exists("res://dictionary"):
            error("Dictionary directory not found")
            success = false
    else:
        error("Could not access file system")
        success = false
    
    info("Verification complete. Success: " + str(success))
    return success

# Print system status
func print_system_status() -> void:
    info("Akashic Records System Status:")
    
    # Get main scene
    var main = Engine.get_main_loop().root.get_child(0)
    if not main or not main.has_method("get_akashic_records"):
        error("Cannot access main scene or get_akashic_records method")
        return
    
    var akashic_records = main.get_akashic_records()
    if not akashic_records:
        error("Akashic Records integration returned null")
        return
    
    var manager = akashic_records.get_akashic_records_manager()
    if not manager:
        error("Akashic Records manager not found")
        return
    
    # Dictionary stats
    var dictionary = manager.dynamic_dictionary
    if dictionary:
        var word_count = dictionary.words.size() if dictionary.words else 0
        info("Dictionary words: " + str(word_count))
        info("Root words: " + str(dictionary.root_words.size() if dictionary.root_words else 0))
    else:
        warning("Dynamic Dictionary not initialized")
    
    # Zone stats
    var zone_manager = manager.zone_manager
    if zone_manager:
        info("Total zones: " + str(zone_manager.zones.size() if zone_manager.zones else 0))
        info("Active zones: " + str(zone_manager.active_zones.size() if zone_manager.active_zones else 0))
    else:
        warning("Zone Manager not initialized")
    
    # Evolution stats
    var evolution_manager = manager.evolution_manager
    if evolution_manager:
        info("Evolution interval: " + str(evolution_manager.evolution_interval) + " seconds")
        info("Evolution rate: " + str(evolution_manager.evolution_rate))
    else:
        warning("Evolution Manager not initialized")

# Called from console commands for debugging
func report_system_status() -> String:
    var main = Engine.get_main_loop().root.get_child(0)
    if not main or not main.has_method("get_akashic_records"):
        return "ERROR: Cannot access Akashic Records system"
    
    var akashic_records = main.get_akashic_records()
    if not akashic_records:
        return "ERROR: Akashic Records integration returned null"
    
    var manager = akashic_records.get_akashic_records_manager()
    if not manager:
        return "ERROR: Akashic Records manager not found"
    
    var dictionary = manager.dynamic_dictionary
    if not dictionary:
        return "ERROR: Dynamic Dictionary not initialized"
    
    var word_count = dictionary.words.size() if dictionary.words else 0
    
    return "Akashic Records Status: OK\nDictionary words: " + str(word_count) + "\nSystem initialized and running"