extends Node

class_name PlayerPreferenceAnalyzer

# Constants
const MIN_DATA_POINTS = 5
const ANALYSIS_INTERVAL = 120 # seconds
const SMOOTHING_FACTOR = 0.3
const ENJOYMENT_INDICATORS = {
    "session_duration": 0.2,
    "action_frequency": 0.2, 
    "completion_rate": 0.2,
    "revisit_frequency": 0.2,
    "exploration_breadth": 0.2
}

# Preference categories and tracking
var preference_categories = {
    "challenge": {
        "current_value": 0.5,
        "history": [],
        "indicators": {
            "difficulty_selected": [],
            "retry_attempts": [],
            "time_spent_on_challenges": []
        }
    },
    "creation": {
        "current_value": 0.5,
        "history": [],
        "indicators": {
            "items_created": [],
            "creation_time_spent": [],
            "customization_depth": []
        }
    },
    "exploration": {
        "current_value": 0.5, 
        "history": [],
        "indicators": {
            "areas_visited": [],
            "discovery_rate": [],
            "path_diversity": []
        }
    },
    "social": {
        "current_value": 0.5,
        "history": [],
        "indicators": {
            "interaction_frequency": [],
            "dialogue_choices": [],
            "relationship_building": []
        }
    },
    "achievement": {
        "current_value": 0.5,
        "history": [],
        "indicators": {
            "goals_completed": [],
            "progress_tracking": [],
            "perfectionism": []
        }
    }
}

# Player state tracking
var activity_log = []
var enjoyment_metrics = {
    "session_duration": [],
    "action_frequency": [],
    "completion_rate": [],
    "revisit_frequency": [],
    "exploration_breadth": []
}

# Analytics
var enjoyment_factor = 1.0
var last_analysis_time = 0
var confidence_level = 0.0

# Signals
signal preferences_updated(preferences)
signal enjoyment_factor_changed(factor)
signal confidence_level_changed(level)

# Reference to account manager
var _account_manager = null

func _ready():
    # Set up analysis timer
    var timer = Timer.new()
    timer.wait_time = ANALYSIS_INTERVAL
    timer.autostart = true
    timer.connect("timeout", self, "_on_analysis_interval")
    add_child(timer)
    
    # Find account manager if available
    if has_node("/root/SmartAccountManager") or get_node_or_null("/root/SmartAccountManager"):
        _account_manager = get_node("/root/SmartAccountManager")
        print("Connected to SmartAccountManager")

func _on_analysis_interval():
    analyze_player_preferences()
    last_analysis_time = OS.get_unix_time()

func log_activity(activity_data):
    # Add timestamp if not provided
    if not activity_data.has("timestamp"):
        activity_data["timestamp"] = OS.get_unix_time()
    
    # Add to activity log
    activity_log.append(activity_data)
    
    # Limit log size to prevent memory issues
    if activity_log.size() > 1000:
        activity_log.pop_front()
    
    # Check if we should run analysis
    if OS.get_unix_time() - last_analysis_time > ANALYSIS_INTERVAL and activity_log.size() >= MIN_DATA_POINTS:
        analyze_player_preferences()
        last_analysis_time = OS.get_unix_time()

func log_preference_indicator(category, indicator, value):
    if category in preference_categories and indicator in preference_categories[category]["indicators"]:
        # Add data point to indicator
        preference_categories[category]["indicators"][indicator].append({
            "value": value,
            "timestamp": OS.get_unix_time()
        })
        
        # Limit array size
        if preference_categories[category]["indicators"][indicator].size() > 20:
            preference_categories[category]["indicators"][indicator].pop_front()
        
        return true
    
    return false

func log_enjoyment_metric(metric, value):
    if metric in enjoyment_metrics:
        enjoyment_metrics[metric].append({
            "value": value,
            "timestamp": OS.get_unix_time()
        })
        
        # Limit array size
        if enjoyment_metrics[metric].size() > 20:
            enjoyment_metrics[metric].pop_front()
        
        return true
    
    return false

func analyze_player_preferences():
    # Skip if not enough data
    if activity_log.size() < MIN_DATA_POINTS:
        print("Not enough data for preference analysis")
        return
    
    # Analyze each preference category
    for category in preference_categories:
        var indicators = preference_categories[category]["indicators"]
        var indicators_count = 0
        var indicators_sum = 0.0
        
        # Process each indicator in this category
        for indicator in indicators:
            var data_points = indicators[indicator]
            if data_points.size() >= MIN_DATA_POINTS:
                var avg_value = 0.0
                
                # Calculate weighted average, with recent values weighted more
                var weight_sum = 0.0
                for i in range(data_points.size()):
                    var weight = 1.0 + (i / float(data_points.size()))
                    avg_value += data_points[i]["value"] * weight
                    weight_sum += weight
                
                if weight_sum > 0:
                    avg_value /= weight_sum
                    indicators_sum += avg_value
                    indicators_count += 1
        
        # Update category preference if we have indicators
        if indicators_count > 0:
            var new_value = indicators_sum / indicators_count
            
            # Apply smoothing to avoid rapid changes
            new_value = preference_categories[category]["current_value"] * (1.0 - SMOOTHING_FACTOR) + new_value * SMOOTHING_FACTOR
            
            # Clamp to valid range
            new_value = clamp(new_value, 0.1, 0.9)
            
            # Update category value
            preference_categories[category]["current_value"] = new_value
            preference_categories[category]["history"].append({
                "value": new_value,
                "timestamp": OS.get_unix_time()
            })
            
            # Limit history size
            if preference_categories[category]["history"].size() > 20:
                preference_categories[category]["history"].pop_front()
    
    # Calculate overall enjoyment factor
    calculate_enjoyment_factor()
    
    # Calculate confidence level based on data quantity
    calculate_confidence_level()
    
    # Update account manager if connected
    if _account_manager:
        _account_manager.enjoyment_factor = enjoyment_factor
        
        var preferences = {}
        for category in preference_categories:
            var key = "prefers_" + category
            preferences[key] = preference_categories[category]["current_value"]
        
        _account_manager.player_preferences = preferences
    
    # Emit updated preferences
    var current_preferences = {}
    for category in preference_categories:
        current_preferences[category] = preference_categories[category]["current_value"]
    
    emit_signal("preferences_updated", current_preferences)
    emit_signal("enjoyment_factor_changed", enjoyment_factor)
    emit_signal("confidence_level_changed", confidence_level)
    
    print("Analyzed player preferences - Enjoyment factor: " + str(enjoyment_factor))

func calculate_enjoyment_factor():
    var factor_sum = 0.0
    var weight_sum = 0.0
    
    # Process each enjoyment metric
    for metric in enjoyment_metrics:
        var data_points = enjoyment_metrics[metric]
        if data_points.size() >= MIN_DATA_POINTS:
            var avg_value = 0.0
            for point in data_points:
                avg_value += point["value"]
            
            avg_value /= data_points.size()
            
            var weight = ENJOYMENT_INDICATORS[metric]
            factor_sum += avg_value * weight
            weight_sum += weight
    
    # Update enjoyment factor if we have data
    if weight_sum > 0:
        var new_factor = factor_sum / weight_sum
        
        # Apply smoothing
        new_factor = enjoyment_factor * (1.0 - SMOOTHING_FACTOR) + new_factor * SMOOTHING_FACTOR
        
        # Clamp to reasonable range
        new_factor = clamp(new_factor, 0.5, 2.0)
        
        enjoyment_factor = new_factor

func calculate_confidence_level():
    var total_indicators = 0
    var total_data_points = 0
    
    # Count indicators with sufficient data
    for category in preference_categories:
        var indicators = preference_categories[category]["indicators"]
        for indicator in indicators:
            total_indicators += 1
            total_data_points += indicators[indicator].size()
    
    # Calculate confidence based on data quantity and variety
    var data_coverage = min(1.0, total_data_points / float(total_indicators * MIN_DATA_POINTS * 2))
    
    # Factor in history length
    var history_factor = 0.0
    var history_count = 0
    for category in preference_categories:
        history_factor += min(1.0, preference_categories[category]["history"].size() / 10.0)
        history_count += 1
    
    if history_count > 0:
        history_factor /= history_count
    
    # Calculate final confidence
    confidence_level = (data_coverage * 0.7 + history_factor * 0.3)
    
    print("Preference analysis confidence: " + str(confidence_level * 100.0) + "%")

# Artificial intelligence enhancement functions for auto-correction

func get_auto_correction_suggestion():
    # Skip if confidence is too low
    if confidence_level < 0.3:
        return null
    
    # Find player's highest preference
    var highest_preference = ""
    var highest_value = 0.0
    
    for category in preference_categories:
        var value = preference_categories[category]["current_value"]
        if value > highest_value:
            highest_value = value
            highest_preference = category
    
    # Skip if no strong preference
    if highest_value < 0.6:
        return null
    
    # Calculate suggested point adjustment based on preferences
    var suggestion = {
        "category": highest_preference,
        "amount": highest_value * 50, # Scale based on preference strength
        "confidence": confidence_level,
        "reason": "Player shows strong preference for " + highest_preference
    }
    
    return suggestion

func should_auto_correct():
    # Only auto-correct if we have reasonable confidence
    return confidence_level >= 0.3

# Helper methods for external access

func get_preference_value(category):
    if category in preference_categories:
        return preference_categories[category]["current_value"]
    return 0.5

func get_enjoyment_factor():
    return enjoyment_factor

func get_confidence_level():
    return confidence_level