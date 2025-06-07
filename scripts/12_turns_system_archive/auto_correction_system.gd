extends Node

class_name AutoCorrectionSystem

# Constants
const CORRECTION_INTERVAL = 300 # seconds (5 minutes)
const MIN_CORRECTION_AMOUNT = 5
const MAX_CORRECTION_AMOUNT = 100
const MIN_CONFIDENCE_THRESHOLD = 0.3
const ENJOYMENT_THRESHOLD = 0.7
const AUTO_ADJUST_STEP = 0.05

# Settings
var auto_correction_enabled = true
var enjoyment_learning_rate = 0.1
var adjustment_intensity = 0.5 # 0.0-1.0
var notification_level = 1 # 0=none, 1=subtle, 2=obvious

# System state
var last_correction_time = 0
var correction_history = []
var enjoyment_readings = []
var detected_playstyle = ""
var detected_preferences = {}
var enjoyment_model = {
    "baseline": 1.0,
    "trend": 0.0,
    "variance": 0.1
}

# References
var _preference_analyzer = null
var _account_manager = null

# Signals
signal correction_applied(amount, category, reason)
signal playstyle_detected(style)
signal settings_updated()

func _ready():
    # Set up correction timer
    var timer = Timer.new()
    timer.wait_time = CORRECTION_INTERVAL
    timer.autostart = true
    timer.connect("timeout", self, "_on_correction_interval")
    add_child(timer)
    
    # Connect to preference analyzer if available
    if has_node("/root/PlayerPreferenceAnalyzer") or get_node_or_null("/root/PlayerPreferenceAnalyzer"):
        _preference_analyzer = get_node("/root/PlayerPreferenceAnalyzer")
        _preference_analyzer.connect("preferences_updated", self, "_on_preferences_updated")
        _preference_analyzer.connect("enjoyment_factor_changed", self, "_on_enjoyment_factor_changed")
        print("Connected to PlayerPreferenceAnalyzer")
    
    # Connect to account manager if available
    if has_node("/root/SmartAccountManager") or get_node_or_null("/root/SmartAccountManager"):
        _account_manager = get_node("/root/SmartAccountManager")
        print("Connected to SmartAccountManager")
    
    # Initialize
    detect_playstyle()

func _on_correction_interval():
    if auto_correction_enabled:
        apply_auto_correction()
    last_correction_time = OS.get_unix_time()

func _on_preferences_updated(preferences):
    detected_preferences = preferences
    detect_playstyle()

func _on_enjoyment_factor_changed(factor):
    # Add to enjoyment readings
    enjoyment_readings.append({
        "value": factor,
        "timestamp": OS.get_unix_time()
    })
    
    # Limit array size
    if enjoyment_readings.size() > 20:
        enjoyment_readings.pop_front()
    
    # Update enjoyment model
    update_enjoyment_model()

func detect_playstyle():
    if not _preference_analyzer:
        return
    
    # Find dominant preferences
    var primary_pref = ""
    var primary_value = 0.0
    var secondary_pref = ""
    var secondary_value = 0.0
    
    for pref in detected_preferences:
        var value = detected_preferences[pref]
        if value > primary_value:
            secondary_pref = primary_pref
            secondary_value = primary_value
            primary_pref = pref
            primary_value = value
        elif value > secondary_value:
            secondary_pref = pref
            secondary_value = value
    
    # Determine playstyle based on preferences
    var playstyle = ""
    
    if primary_value >= 0.7:
        # Strong single preference
        if primary_pref == "challenge":
            playstyle = "Challenger"
        elif primary_pref == "creation":
            playstyle = "Creator"
        elif primary_pref == "exploration":
            playstyle = "Explorer"
        elif primary_pref == "social":
            playstyle = "Socializer"
        elif primary_pref == "achievement":
            playstyle = "Achiever"
    elif primary_value >= 0.5 and secondary_value >= 0.4:
        # Hybrid playstyle
        playstyle = hybrid_playstyle_name(primary_pref, secondary_pref)
    else:
        playstyle = "Balanced"
    
    if playstyle != detected_playstyle:
        detected_playstyle = playstyle
        emit_signal("playstyle_detected", detected_playstyle)
        print("Detected playstyle: " + detected_playstyle)

func hybrid_playstyle_name(primary, secondary):
    var style_map = {
        "challenge": {
            "creation": "Innovative Challenger",
            "exploration": "Adventurous Challenger",
            "social": "Competitive Socializer",
            "achievement": "Trophy Hunter"
        },
        "creation": {
            "challenge": "Problem Solver",
            "exploration": "World Builder",
            "social": "Collaborative Creator",
            "achievement": "Productive Creator"
        },
        "exploration": {
            "challenge": "Puzzle Explorer",
            "creation": "Creative Explorer",
            "social": "Guide",
            "achievement": "Completionist"
        },
        "social": {
            "challenge": "Team Leader",
            "creation": "Community Builder",
            "exploration": "Group Explorer",
            "achievement": "Social Achiever"
        },
        "achievement": {
            "challenge": "Record Breaker",
            "creation": "Collector",
            "exploration": "Discoverer",
            "social": "Status Seeker"
        }
    }
    
    if primary in style_map and secondary in style_map[primary]:
        return style_map[primary][secondary]
    
    return primary.capitalize() + "-" + secondary.capitalize() + " Hybrid"

func update_enjoyment_model():
    if enjoyment_readings.size() < 3:
        return
    
    # Calculate average enjoyment
    var avg_enjoyment = 0.0
    for reading in enjoyment_readings:
        avg_enjoyment += reading["value"]
    avg_enjoyment /= enjoyment_readings.size()
    
    # Calculate trend (linear regression slope)
    var x_sum = 0.0
    var y_sum = 0.0
    var xy_sum = 0.0
    var x2_sum = 0.0
    var n = enjoyment_readings.size()
    
    for i in range(n):
        var x = float(i)
        var y = enjoyment_readings[i]["value"]
        
        x_sum += x
        y_sum += y
        xy_sum += x * y
        x2_sum += x * x
    
    var slope = (n * xy_sum - x_sum * y_sum) / (n * x2_sum - x_sum * x_sum)
    
    # Calculate variance
    var variance = 0.0
    for reading in enjoyment_readings:
        variance += pow(reading["value"] - avg_enjoyment, 2)
    variance /= enjoyment_readings.size()
    
    # Update model using learning rate to smooth changes
    enjoyment_model["baseline"] = enjoyment_model["baseline"] * (1.0 - enjoyment_learning_rate) + avg_enjoyment * enjoyment_learning_rate
    enjoyment_model["trend"] = enjoyment_model["trend"] * (1.0 - enjoyment_learning_rate) + slope * enjoyment_learning_rate
    enjoyment_model["variance"] = enjoyment_model["variance"] * (1.0 - enjoyment_learning_rate) + variance * enjoyment_learning_rate

func apply_auto_correction():
    if not _preference_analyzer or not _account_manager:
        return false
    
    # Skip if confidence is too low
    if _preference_analyzer.get_confidence_level() < MIN_CONFIDENCE_THRESHOLD:
        print("Auto-correction skipped: Confidence too low")
        return false
    
    # Get correction suggestion
    var suggestion = _preference_analyzer.get_auto_correction_suggestion()
    if not suggestion:
        print("Auto-correction skipped: No suggestion available")
        return false
    
    # Calculate correction amount based on adjustment intensity
    var amount = clamp(
        suggestion["amount"] * adjustment_intensity,
        MIN_CORRECTION_AMOUNT,
        MAX_CORRECTION_AMOUNT
    )
    
    # Apply correction
    var success = false
    if _account_manager.has_method("add_points"):
        success = _account_manager.add_points(amount, suggestion["category"])
    
    if success:
        # Record correction
        correction_history.append({
            "amount": amount,
            "category": suggestion["category"],
            "reason": suggestion["reason"],
            "timestamp": OS.get_unix_time(),
            "confidence": suggestion["confidence"]
        })
        
        # Limit history size
        if correction_history.size() > 50:
            correction_history.pop_front()
        
        # Send notification based on level
        if notification_level >= 1:
            send_correction_notification(amount, suggestion["category"], notification_level)
        
        emit_signal("correction_applied", amount, suggestion["category"], suggestion["reason"])
        print("Auto-correction applied: " + str(amount) + " points to " + suggestion["category"])
        return true
    
    return false

func send_correction_notification(amount, category, level):
    # Only send if connected to necessary systems
    if not _account_manager:
        return
    
    var message = ""
    
    if level == 1:
        # Subtle notification
        message = "You received a bonus for your " + category + " activities."
    else:
        # Obvious notification
        message = "AUTO-CORRECTION: Added " + str(int(amount)) + " points to " + category.capitalize() + " category based on your play style."
    
    # In a real game, would send to notification system
    print("NOTIFICATION: " + message)

func adjust_settings_based_on_feedback(feedback_type, value):
    match feedback_type:
        "enjoyment":
            # Adjust settings based on enjoyment feedback
            if value < ENJOYMENT_THRESHOLD and adjustment_intensity > 0.1:
                adjustment_intensity -= AUTO_ADJUST_STEP
                print("Decreased adjustment intensity to: " + str(adjustment_intensity))
            elif value > ENJOYMENT_THRESHOLD and adjustment_intensity < 0.9:
                adjustment_intensity += AUTO_ADJUST_STEP
                print("Increased adjustment intensity to: " + str(adjustment_intensity))
        
        "notification":
            # Adjust notification level based on feedback
            notification_level = clamp(int(value), 0, 2)
            print("Set notification level to: " + str(notification_level))
        
        "auto_correct":
            # Toggle auto-correction
            auto_correction_enabled = bool(value)
            print("Auto-correction " + ("enabled" if auto_correction_enabled else "disabled"))
    
    emit_signal("settings_updated")
    return true

# Helper methods for external access

func get_playstyle():
    return detected_playstyle

func get_enjoyment_baseline():
    return enjoyment_model["baseline"]

func get_last_correction():
    if correction_history.size() > 0:
        return correction_history[correction_history.size() - 1]
    return null

func get_correction_frequency():
    if correction_history.size() < 2:
        return 0.0
    
    var first = correction_history[0]["timestamp"]
    var last = correction_history[correction_history.size() - 1]["timestamp"]
    var duration = last - first
    
    if duration <= 0:
        return 0.0
    
    return correction_history.size() / float(duration / 3600.0) # per hour