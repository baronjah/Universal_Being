extends Node
class_name DataPathProtector

# Constants
const SECURITY_LEVELS = ["BASIC", "ENHANCED", "ADVANCED", "QUANTUM", "TRANSCENDENT"]
const MAX_LEVEL = 4  # Corresponds to TRANSCENDENT

# Properties
var protected_paths = {}
var security_level = 0  # 0-4, corresponding to SECURITY_LEVELS
var active_firewalls = {}
var word_based_rules = {}
var intrusion_detection_active = false
var last_scan_time = 0
var resource_consumption = 0.0  # 0.0-1.0

# Signals
signal security_level_changed(old_level, new_level)
signal path_protected(path, protection_level)
signal intrusion_detected(path, severity)
signal firewall_report_generated(report)
signal word_rule_applied(rule_name, affected_paths)

func _ready():
    initialize_firewall()
    _start_background_monitoring()

func initialize_firewall():
    # Set up initial protection
    security_level = 0
    
    # Base system paths to protect
    add_protected_path("/mnt/d/", 1)
    add_protected_path("/user/data/", 1)
    add_protected_path("/system/core/", 2)
    
    # Create basic word-based rules
    create_word_rule("deny_unsafe", ["delete", "format", "destroy", "overwrite"], 3)
    create_word_rule("protect_memory", ["memory", "data", "storage"], 2)
    
    print("Firewall initialized at " + SECURITY_LEVELS[security_level] + " level")
    print("Initial paths protected: " + str(protected_paths.keys()))

func add_protected_path(path, protection_level = 1):
    if path in protected_paths:
        # Update existing path protection
        var old_level = protected_paths[path]
        protected_paths[path] = max(old_level, protection_level)
    else:
        # Add new path
        protected_paths[path] = protection_level
    
    print("Path protected: " + path + " (Level " + str(protection_level) + ")")
    emit_signal("path_protected", path, protection_level)
    
    return true

func remove_protected_path(path):
    if path in protected_paths:
        protected_paths.erase(path)
        print("Protection removed from path: " + path)
        return true
    return false

func create_word_rule(rule_name, trigger_words, action_level = 1):
    word_based_rules[rule_name] = {
        "trigger_words": trigger_words,
        "action_level": action_level,
        "enabled": true,
        "affected_paths": []
    }
    
    print("Word rule created: " + rule_name + " (Level " + str(action_level) + ")")
    print("  Trigger words: " + str(trigger_words))
    
    return rule_name

func enable_word_rule(rule_name):
    if rule_name in word_based_rules:
        word_based_rules[rule_name].enabled = true
        return true
    return false

func disable_word_rule(rule_name):
    if rule_name in word_based_rules:
        word_based_rules[rule_name].enabled = false
        return true
    return false

func apply_word_rule_to_paths(rule_name, paths):
    if not rule_name in word_based_rules:
        return false
    
    word_based_rules[rule_name].affected_paths = paths
    
    print("Rule '" + rule_name + "' applied to paths: " + str(paths))
    emit_signal("word_rule_applied", rule_name, paths)
    
    return true

func check_word_against_rules(word, path = ""):
    var triggered_rules = []
    
    # Check each rule
    for rule_name in word_based_rules:
        var rule = word_based_rules[rule_name]
        
        if not rule.enabled:
            continue
        
        # Skip if this rule has specific paths and current path isn't included
        if rule.affected_paths.size() > 0 and not path in rule.affected_paths:
            continue
        
        # Check if the word triggers this rule
        for trigger_word in rule.trigger_words:
            if word.to_lower().contains(trigger_word.to_lower()):
                triggered_rules.append({
                    "rule_name": rule_name,
                    "action_level": rule.action_level,
                    "trigger_word": trigger_word
                })
                break
    
    return triggered_rules

func upgrade_security_level():
    if security_level >= MAX_LEVEL:
        print("Already at maximum security level: " + SECURITY_LEVELS[security_level])
        return false
    
    var old_level = security_level
    security_level += 1
    
    print("Security level upgraded from " + SECURITY_LEVELS[old_level] + " to " + SECURITY_LEVELS[security_level])
    emit_signal("security_level_changed", old_level, security_level)
    
    # Apply new security features based on level
    _apply_security_features(security_level)
    
    return true

func _apply_security_features(level):
    match level:
        1:  # ENHANCED
            add_protected_path("/memory/", 2)
            create_word_rule("protect_system", ["system", "kernel", "root"], 3)
            intrusion_detection_active = true
        
        2:  # ADVANCED
            add_protected_path("/network/", 3)
            create_word_rule("restrict_execute", ["execute", "run", "spawn"], 3)
            resource_consumption = 0.2
        
        3:  # QUANTUM
            for path in protected_paths.keys():
                protected_paths[path] += 1  # Increase all protection levels
            
            create_word_rule("quantum_barrier", ["quantum", "breach", "override"], 4)
            resource_consumption = 0.4
        
        4:  # TRANSCENDENT
            # Apply highest protection to all paths
            for path in protected_paths.keys():
                protected_paths[path] = 5  # Maximum protection
            
            create_word_rule("transcendent_shield", ["transcend", "infinite", "absolute"], 5)
            resource_consumption = 0.6

func scan_path_for_intrusions(path):
    if not path in protected_paths:
        print("Path not protected, cannot scan: " + path)
        return false
    
    var protection_level = protected_paths[path]
    var intrusion_found = false
    var severity = 0
    
    # Simulated scan - in real implementation, would actually check files
    if randf() < 0.1:  # 10% chance of finding something
        intrusion_found = true
        severity = 1 + randi() % 3  # Severity 1-3
    
    if intrusion_found:
        print("Intrusion detected in path: " + path)
        print("Severity level: " + str(severity))
        emit_signal("intrusion_detected", path, severity)
        
        # Take automatic action based on security level
        if severity <= security_level:
            print("Automatically mitigating intrusion...")
            # Mitigation would happen here
        else:
            print("Manual intervention required - severity exceeds security level")
    else:
        print("Path scan complete: " + path + " - No intrusions detected")
    
    last_scan_time = Time.get_unix_time_from_system()
    
    return intrusion_found

func scan_all_protected_paths():
    var report = {
        "scan_time": Time.get_unix_time_from_system(),
        "paths_scanned": protected_paths.size(),
        "intrusions_found": 0,
        "intrusion_details": []
    }
    
    for path in protected_paths:
        print("Scanning path: " + path)
        
        # Simulated scan - in real implementation, would actually check files
        if randf() < 0.1:  # 10% chance of finding something
            var severity = 1 + randi() % 3  # Severity 1-3
            
            report.intrusions_found += 1
            report.intrusion_details.append({
                "path": path,
                "severity": severity,
                "protection_level": protected_paths[path]
            })
            
            emit_signal("intrusion_detected", path, severity)
        
        # Small delay to simulate scanning time
        await get_tree().create_timer(0.1).timeout
    
    print("Scan complete. Found " + str(report.intrusions_found) + " potential issues.")
    
    last_scan_time = report.scan_time
    emit_signal("firewall_report_generated", report)
    
    return report

func _start_background_monitoring():
    # Start timer for periodic monitoring
    var timer = Timer.new()
    timer.wait_time = 60  # Check every minute
    timer.autostart = true
    timer.timeout.connect(_on_monitor_timer_timeout)
    add_child(timer)
    
    print("Background monitoring started")

func _on_monitor_timer_timeout():
    if intrusion_detection_active:
        # Periodically check a random protected path
        if protected_paths.size() > 0:
            var paths = protected_paths.keys()
            var random_path = paths[randi() % paths.size()]
            
            print("Performing routine check of: " + random_path)
            scan_path_for_intrusions(random_path)

func get_system_status():
    var status = {
        "security_level": SECURITY_LEVELS[security_level],
        "protection_active": protected_paths.size() > 0,
        "protected_paths_count": protected_paths.size(),
        "intrusion_detection": intrusion_detection_active,
        "last_scan": last_scan_time,
        "resource_usage": resource_consumption,
        "word_rules_count": word_based_rules.size()
    }
    
    return status

func word_based_system_check(command):
    # Split the command into words
    var words = command.split(" ")
    var all_triggered_rules = []
    
    # Check each word
    for word in words:
        var triggered_rules = check_word_against_rules(word)
        
        for rule in triggered_rules:
            all_triggered_rules.append(rule)
    
    if all_triggered_rules.size() > 0:
        print("WARNING: Command triggered security rules: ")
        for rule in all_triggered_rules:
            print("  - Rule: " + rule.rule_name + " (triggered by: " + rule.trigger_word + ")")
        
        # If any high-level rules triggered, block the command
        for rule in all_triggered_rules:
            if rule.action_level >= 3:
                print("Command blocked due to security policy")
                return false
    
    return true  # Allow the command

func create_yoyo_security_pattern(keywords):
    # Create a cyclic security pattern based on keywords
    print("Creating yoyo security pattern with keywords: " + str(keywords))
    
    var pattern = []
    
    # Cycle forward through keywords
    for i in range(keywords.size()):
        pattern.append(keywords[i])
    
    # Cycle backward
    for i in range(keywords.size() - 1, -1, -1):
        pattern.append(keywords[i])
    
    print("Yoyo pattern created: " + str(pattern))
    
    # Apply pattern to security
    for keyword in pattern:
        create_word_rule("yoyo_" + keyword, [keyword], 2)
    
    return pattern