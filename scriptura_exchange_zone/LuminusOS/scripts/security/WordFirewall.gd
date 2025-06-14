class_name WordFirewall
extends Node

# ================ FIREWALL CORE ================
# Security system for protecting data pathways and word processing
# Inspired by traditional firewalls but operating on linguistic boundaries

const SECURITY_LEVELS = ["BASIC", "ENHANCED", "ADVANCED", "QUANTUM", "DIVINE"]
const FILTER_MODES = ["ALLOW", "DENY", "TRANSFORM", "REDIRECT"]
var current_security_level = 0
var is_active = true
var protected_paths = []
var rule_sets = {}
var intrusion_logs = []
var word_transformation_map = {}

# Signals
signal security_level_changed(from_level, to_level)
signal intrusion_detected(word, severity, path)
signal word_transformed(original, transformed)
signal rule_triggered(rule_name, word, action)

# ================ INITIALIZATION ================
func _ready():
    setup_default_protection()
    start_monitoring()
    print("[WordFirewall] System activated - Default protection enabled")

func setup_default_protection():
    # Set up basic path protection
    protected_paths = [
        "/mnt/d/",
        "/user/data/",
        "/system/core/",
        "/memory/primary/",
        "/runtime/active/",
        "/network/external/"
    ]
    
    # Create default rule sets
    rule_sets = {
        "system_protection": {
            "description": "Protects core system words from alteration",
            "priority": 10,
            "enabled": true,
            "patterns": ["system", "kernel", "root", "admin", "sudo", "exec"],
            "mode": "DENY",
            "action": "block_and_log"
        },
        "data_security": {
            "description": "Secures sensitive data words",
            "priority": 8,
            "enabled": true,
            "patterns": ["password", "key", "secret", "credentials", "token"],
            "mode": "TRANSFORM",
            "action": "obfuscate_and_log"
        },
        "external_filter": {
            "description": "Filters incoming words from external sources",
            "priority": 6,
            "enabled": true,
            "patterns": ["http", "url", "download", "remote", "fetch"],
            "mode": "REDIRECT",
            "action": "scan_before_process"
        },
        "creative_safety": {
            "description": "Ensures creation words are properly constrained",
            "priority": 5,
            "enabled": true,
            "patterns": ["create", "generate", "spawn", "instantiate", "manifest"],
            "mode": "TRANSFORM",
            "action": "add_safety_bounds"
        },
        "sin_protection": {
            "description": "Transforms sin-related words into creation patterns",
            "priority": 9,
            "enabled": true,
            "patterns": ["sin", "curse", "dark", "corrupt", "fall"],
            "mode": "TRANSFORM",
            "action": "redeem_to_creation"
        }
    }
    
    # Set up word transformation map for certain rules
    word_transformation_map = {
        "sin": "creation",
        "curse": "blessing",
        "dark": "illuminate",
        "corrupt": "cleanse",
        "fall": "ascend",
        "password": "****PROTECTED****",
        "secret": "****SECURED****"
    }

func start_monitoring():
    # Begin monitoring words passing through system
    var timer = Timer.new()
    timer.wait_time = 1.0  # Check every second
    timer.autostart = true
    timer.timeout.connect(_on_monitor_tick)
    add_child(timer)

# ================ SECURITY LEVEL MANAGEMENT ================
func set_security_level(level: int) -> bool:
    if level < 0 or level >= SECURITY_LEVELS.size():
        push_warning("[WordFirewall] Invalid security level: " + str(level))
        return false
    
    var previous_level = current_security_level
    current_security_level = level
    
    print("[WordFirewall] Security level changed from " + 
          SECURITY_LEVELS[previous_level] + " to " + SECURITY_LEVELS[current_security_level])
    
    _apply_level_specific_rules(level)
    emit_signal("security_level_changed", previous_level, current_security_level)
    
    return true

func _apply_level_specific_rules(level: int):
    match level:
        0:  # BASIC
            # Basic protection only
            pass
            
        1:  # ENHANCED
            # Add more protected paths
            protected_paths.append("/user/downloads/")
            protected_paths.append("/memory/secondary/")
            
            # Enable more aggressive scanning
            var transform_rule = rule_sets["data_security"]
            transform_rule.patterns.append("personal")
            transform_rule.patterns.append("private")
            
        2:  # ADVANCED
            # Add proactive protection
            add_rule("proactive_defense", {
                "description": "Actively scans and predicts potential threats",
                "priority": 7,
                "enabled": true,
                "patterns": ["modify", "override", "bypass", "exploit"],
                "mode": "REDIRECT",
                "action": "analyze_intent"
            })
            
        3:  # QUANTUM
            # Add quantum entanglement security
            add_rule("quantum_entanglement", {
                "description": "Creates quantum paired security tokens",
                "priority": 9,
                "enabled": true,
                "patterns": ["quantum", "entangle", "superposition", "observe"],
                "mode": "TRANSFORM",
                "action": "create_quantum_pair"
            })
            
        4:  # DIVINE
            # Add highest level protection
            add_rule("divine_protection", {
                "description": "Applies spiritual-level security to all words",
                "priority": 11,
                "enabled": true,
                "patterns": ["divine", "spirit", "soul", "eternal", "transcend"],
                "mode": "TRANSFORM",
                "action": "apply_divine_blessing"
            })

# ================ RULE MANAGEMENT ================
func add_rule(rule_name: String, rule_config: Dictionary) -> bool:
    if rule_name in rule_sets:
        push_warning("[WordFirewall] Rule already exists: " + rule_name)
        return false
    
    # Validate required fields
    var required_fields = ["description", "priority", "enabled", "patterns", "mode", "action"]
    for field in required_fields:
        if not field in rule_config:
            push_warning("[WordFirewall] Missing required field in rule config: " + field)
            return false
    
    # Add the rule
    rule_sets[rule_name] = rule_config
    print("[WordFirewall] Added rule: " + rule_name)
    
    return true

func disable_rule(rule_name: String) -> bool:
    if not rule_name in rule_sets:
        push_warning("[WordFirewall] Rule not found: " + rule_name)
        return false
    
    rule_sets[rule_name].enabled = false
    print("[WordFirewall] Disabled rule: " + rule_name)
    
    return true

func enable_rule(rule_name: String) -> bool:
    if not rule_name in rule_sets:
        push_warning("[WordFirewall] Rule not found: " + rule_name)
        return false
    
    rule_sets[rule_name].enabled = true
    print("[WordFirewall] Enabled rule: " + rule_name)
    
    return true

# ================ WORD PROCESSING ================
func process_word(word: String, source_path: String = "", context: Dictionary = {}) -> Dictionary:
    if not is_active:
        return {"word": word, "allowed": true, "transformed": false}
    
    # Check if path is protected
    var path_protected = is_path_protected(source_path)
    
    # Get applicable rules
    var applicable_rules = _get_applicable_rules(word)
    
    # Apply rules in priority order
    var result = {"word": word, "allowed": true, "transformed": false, "redirected": false}
    
    for rule in applicable_rules:
        var rule_config = rule_sets[rule]
        
        match rule_config.mode:
            "ALLOW":
                # Explicitly allowed
                result.allowed = true
                emit_signal("rule_triggered", rule, word, "allowed")
                break  # Allow takes precedence
                
            "DENY":
                if _should_apply_rule(rule_config, word, source_path, context):
                    # Word denied
                    result.allowed = false
                    _log_intrusion(word, 2, source_path, rule)
                    emit_signal("rule_triggered", rule, word, "denied")
                    emit_signal("intrusion_detected", word, 2, source_path)
                    break  # Deny takes precedence over transformations
            
            "TRANSFORM":
                if _should_apply_rule(rule_config, word, source_path, context):
                    # Transform the word
                    var transformed = _transform_word(word, rule_config.action)
                    if transformed != word:
                        result.word = transformed
                        result.transformed = true
                        emit_signal("rule_triggered", rule, word, "transformed")
                        emit_signal("word_transformed", word, transformed)
            
            "REDIRECT":
                if _should_apply_rule(rule_config, word, source_path, context):
                    # Redirect for additional processing
                    result.redirected = true
                    result.redirect_action = rule_config.action
                    emit_signal("rule_triggered", rule, word, "redirected")
    
    return result

func is_path_protected(path: String) -> bool:
    if path == "":
        return false
        
    for protected_path in protected_paths:
        if path.begins_with(protected_path):
            return true
    
    return false

func _get_applicable_rules(word: String) -> Array:
    var matched_rules = []
    
    # Check each rule
    for rule_name in rule_sets:
        var rule = rule_sets[rule_name]
        
        # Skip disabled rules
        if not rule.enabled:
            continue
        
        # Check if word matches any patterns
        for pattern in rule.patterns:
            if word.to_lower().contains(pattern.to_lower()):
                matched_rules.append(rule_name)
                break
    
    # Sort by priority (higher numbers first)
    matched_rules.sort_custom(Callable(self, "_sort_rules_by_priority"))
    
    return matched_rules

func _sort_rules_by_priority(a, b):
    return rule_sets[a].priority > rule_sets[b].priority

func _should_apply_rule(rule_config, word, source_path, context) -> bool:
    # Additional conditions can be checked here
    # For now, simply return true if the rule is enabled
    return rule_config.enabled

func _transform_word(word: String, action: String) -> String:
    # Check if we have a direct mapping
    if word.to_lower() in word_transformation_map:
        return word_transformation_map[word.to_lower()]
    
    # Apply specific transformations based on action
    match action:
        "obfuscate_and_log":
            return "****" + word.substr(0, 1) + "*" * (word.length() - 1)
            
        "add_safety_bounds":
            return "safe_" + word + "_bounded"
            
        "redeem_to_creation":
            return "create_" + word.replace("sin", "virtue").replace("curse", "blessing")
            
        "create_quantum_pair":
            return "quantum{" + word + "}"
            
        "apply_divine_blessing":
            return "✝" + word + "✝"
    
    # Default: return original word
    return word

func _log_intrusion(word: String, severity: int, path: String, rule: String):
    var intrusion = {
        "timestamp": Time.get_unix_time_from_system(),
        "word": word,
        "severity": severity,
        "path": path,
        "rule_triggered": rule
    }
    
    intrusion_logs.append(intrusion)
    
    # Limit log size
    if intrusion_logs.size() > 1000:
        intrusion_logs.pop_front()
    
    print("[WordFirewall] Intrusion detected: " + word + " (Severity: " + str(severity) + ")")

# ================ MONITORING ================
func _on_monitor_tick():
    # Regular security system pulse
    if current_security_level >= 2:  # ADVANCED or higher
        _scan_for_anomalies()

func _scan_for_anomalies():
    # Proactively scan for potential threats
    # This would connect to the memory and word systems in a real implementation
    pass

# ================ PUBLIC API ================
func get_security_status() -> Dictionary:
    return {
        "active": is_active,
        "security_level": SECURITY_LEVELS[current_security_level],
        "protected_paths": protected_paths.size(),
        "active_rules": _count_active_rules(),
        "intrusions_detected": intrusion_logs.size(),
        "transformations_active": word_transformation_map.size()
    }

func _count_active_rules() -> int:
    var count = 0
    for rule_name in rule_sets:
        if rule_sets[rule_name].enabled:
            count += 1
    return count

func activate():
    is_active = true
    print("[WordFirewall] System activated")

func deactivate():
    is_active = false
    print("[WordFirewall] System deactivated - WARNING: All word protection disabled")

func test_word(word: String, path: String = "") -> Dictionary:
    return process_word(word, path)

func add_protected_path(path: String):
    if not protected_paths.has(path):
        protected_paths.append(path)
        print("[WordFirewall] Added protected path: " + path)

func remove_protected_path(path: String):
    if protected_paths.has(path):
        protected_paths.erase(path)
        print("[WordFirewall] Removed protected path: " + path)

func clear_intrusion_logs():
    var previous_count = intrusion_logs.size()
    intrusion_logs.clear()
    print("[WordFirewall] Cleared " + str(previous_count) + " intrusion logs")

func add_word_transformation(original: String, transformed: String):
    word_transformation_map[original.to_lower()] = transformed
    print("[WordFirewall] Added word transformation: " + original + " → " + transformed)

# ================ ADVANCED SECURITY FEATURES ================
# These would be expanded in the actual implementation

func create_security_perimeter(area_name: String, paths: Array) -> bool:
    print("[WordFirewall] Created security perimeter: " + area_name)
    for path in paths:
        add_protected_path(path)
    return true

func perform_deep_scan() -> Dictionary:
    print("[WordFirewall] Performing deep security scan...")
    # Simulate scan process
    await get_tree().create_timer(2.0).timeout
    
    return {
        "scan_completed": true,
        "threats_found": 0,
        "system_integrity": 100.0,
        "recommendations": ["Consider adding more path protection"]
    }

# The divine protection system - highest level security
func activate_divine_protection():
    if current_security_level < 4:
        set_security_level(4)  # Set to DIVINE level
    
    print("[WordFirewall] Divine protection activated - All paths sanctified")
    
    # Apply special divine transformations
    word_transformation_map["evil"] = "good"
    word_transformation_map["darkness"] = "light"
    word_transformation_map["chaos"] = "order"
    word_transformation_map["destruction"] = "creation"
    word_transformation_map["hate"] = "love"
    
    # Emit special signal
    emit_signal("rule_triggered", "divine_protection", "*all words*", "blessed")
    
    return true