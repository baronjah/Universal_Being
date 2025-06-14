extends Node

class_name EmotionPricingSystem

"""
Emotion-Based Pricing System
Manages the cost of operations based on emotional content
Uses satoshi micropayments (0.00000001 to 0.00000009 BTC)
"""

# Emotion levels and their associated costs (in satoshis)
const EMOTION_COSTS = {
    "neutral": 0,  # No emotional content
    "mild": 1,     # Slight emotional tinge
    "medium": 3,   # Moderate emotional content
    "strong": 5,   # Strong emotional content
    "intense": 9   # Maximum emotional intensity
}

# Different emotion types
const EMOTION_TYPES = [
    "joy",
    "sadness", 
    "anger",
    "fear",
    "surprise",
    "disgust",
    "trust",
    "anticipation",
    "focus",
    "inspiration"
]

# Modifier coefficients for different account tiers
const TIER_MODIFIERS = {
    "free": 1.0,        # Base rate
    "plus": 0.8,        # 20% discount
    "max": 0.5,         # 50% discount
    "enterprise": 0.3   # 70% discount
}

# Optimal emotion-API pairings (discount applied when matching)
const API_EMOTION_AFFINITIES = {
    "claude_api": ["joy", "trust", "inspiration"],
    "gemini_api": ["surprise", "focus", "anticipation"],
    "openai_api": ["anger", "fear", "sadness"],
    "custom_api": ["disgust"]  # Example custom API
}

# Daily emotion point limits by tier
const TIER_EMOTION_LIMITS = {
    "free": 100,
    "plus": 500,
    "max": 2000,
    "enterprise": 10000
}

# Account tracking
var account_usage = {}
var daily_reset_time = 0
var emotion_points_used = {}

# Signal for cost calculations
signal cost_calculated(account_id, emotion_type, emotion_level, cost)
signal limit_reached(account_id, emotion_type)

func _ready():
    # Initialize daily reset timer
    daily_reset_time = Time.get_unix_time_from_system()
    var timer = Timer.new()
    timer.wait_time = 3600  # Check hourly
    timer.autostart = true
    timer.timeout.connect(_check_daily_reset)
    add_child(timer)

func _check_daily_reset():
    var current_time = Time.get_unix_time_from_system()
    var day_seconds = 86400  # 24 hours in seconds
    
    if current_time - daily_reset_time > day_seconds:
        # Reset all emotion usage counters
        emotion_points_used.clear()
        daily_reset_time = current_time

func calculate_cost(account_id, api_name, task_data):
    # Get account tier
    var tier = _get_account_tier(account_id)
    
    # Extract emotion information from task data
    var emotion_type = task_data.get("emotion_type", "neutral")
    var emotion_level = task_data.get("emotion_level", "neutral")
    
    # Get base cost in satoshis
    var base_cost = EMOTION_COSTS.get(emotion_level, 0)
    
    # Apply tier discount
    var tier_modifier = TIER_MODIFIERS.get(tier, 1.0)
    var total_cost = base_cost * tier_modifier
    
    # Apply API affinity discount (10% discount when emotion matches API strength)
    if API_EMOTION_AFFINITIES.has(api_name) and emotion_type in API_EMOTION_AFFINITIES[api_name]:
        total_cost *= 0.9
        
        # Apply task-specific modifiers
        match task_data.get("task_type", ""):
            "creative_writing":
                if api_name == "claude_api":
                    total_cost *= 0.9  # Claude performs well on creative tasks
            "code_generation":
                if api_name == "openai_api":
                    total_cost *= 0.85  # OpenAI performs well on code
            "summarization":
                if api_name == "gemini_api":
                    total_cost *= 0.9  # Gemini is efficient for summarization
    
    # Round to nearest satoshi (integers 0-9)
    total_cost = clamp(int(total_cost), 0, 9)
    
    # Track usage for this account
    _track_emotion_usage(account_id, emotion_type, total_cost)
    
    # Emit cost signal
    emit_signal("cost_calculated", account_id, emotion_type, emotion_level, total_cost)
    
    return total_cost

func get_account_usage(account_id):
    """
    Get the total emotion points used by an account
    """
    var total_used = 0
    
    if account_id in emotion_points_used:
        for emotion_type in emotion_points_used[account_id]:
            total_used += emotion_points_used[account_id][emotion_type]
    
    return total_used

func get_account_limit(account_id):
    """
    Get the emotion point limit for an account based on tier
    """
    var tier = _get_account_tier(account_id)
    return TIER_EMOTION_LIMITS.get(tier, 100)  # Default to free tier

func check_limit_reached(account_id):
    """
    Check if an account has reached its daily emotion point limit
    """
    var used = get_account_usage(account_id)
    var limit = get_account_limit(account_id)
    
    return used >= limit

func get_top_emotions(account_id):
    """
    Get the top 3 emotions used by an account
    """
    var emotions = []
    
    if account_id in emotion_points_used:
        var usage = emotion_points_used[account_id]
        var sorted_emotions = []
        
        for emotion_type in usage:
            sorted_emotions.append({
                "type": emotion_type,
                "points": usage[emotion_type]
            })
        
        # Sort by points used (descending)
        sorted_emotions.sort_custom(func(a, b): return a.points > b.points)
        
        # Return top 3 or all if less than 3
        for i in range(min(3, sorted_emotions.size())):
            emotions.append(sorted_emotions[i])
    
    return emotions

func get_optimal_api(account_id, emotion_type):
    """
    Get the optimal API for a given emotion type
    """
    var optimal_api = ""
    var best_match = 0
    
    for api_name in API_EMOTION_AFFINITIES:
        if emotion_type in API_EMOTION_AFFINITIES[api_name]:
            # If we find a perfect match, return immediately
            return api_name
            
        # Count partial matches in affinity list
        var match_count = 0
        for e in API_EMOTION_AFFINITIES[api_name]:
            # Check string similarity
            if emotion_type.similarity(e) > 0.5:
                match_count += 1
        
        if match_count > best_match:
            best_match = match_count
            optimal_api = api_name
    
    return optimal_api

func get_emotion_price_chart():
    """
    Return a formatted chart of emotion costs
    """
    var chart = {}
    
    for level in EMOTION_COSTS:
        var level_costs = {}
        for tier in TIER_MODIFIERS:
            level_costs[tier] = int(EMOTION_COSTS[level] * TIER_MODIFIERS[tier])
        chart[level] = level_costs
    
    return chart

# Private helper methods

func _track_emotion_usage(account_id, emotion_type, cost):
    # Initialize account if needed
    if not account_id in emotion_points_used:
        emotion_points_used[account_id] = {}
    
    # Initialize emotion type if needed
    if not emotion_type in emotion_points_used[account_id]:
        emotion_points_used[account_id][emotion_type] = 0
    
    # Add cost to total
    emotion_points_used[account_id][emotion_type] += cost
    
    # Check if limit reached
    if check_limit_reached(account_id):
        emit_signal("limit_reached", account_id, emotion_type)

func _get_account_tier(account_id):
    # In a real implementation, this would get the actual tier
    # For this example, infer from account name
    if account_id.begins_with("enterprise"):
        return "enterprise"
    elif account_id.begins_with("max"):
        return "max"
    elif account_id.begins_with("plus"):
        return "plus"
    else:
        return "free"