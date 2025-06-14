extends Node

class_name SmartAccountManager

# Constants
const DIMENSION_MAX_LEVEL = 12
const MIN_POINTS = 0
const POINTS_SOFT_CAP = 10000
const AUTO_CORRECTION_INTERVAL = 60 # seconds

# Dimension symbols - the # symbol is significant in this system
const DIMENSION_SYMBOLS = {
    1: "#",
    2: "##",
    3: "###",
    4: "####",
    5: "#####",
    6: "######",
    7: "#######",
    8: "########",
    9: "#########",
    10: "##########",
    11: "###########",
    12: "############"
}

# Player account data
var player_name = ""
var account_id = ""
var total_points = 0
var current_dimension = 1
var enjoyment_factor = 1.0 # Multiplier based on player's enjoyment patterns
var last_auto_correction = 0

# References to other systems
var _akashic_db = null
var _account_connector = null

# Points distribution across categories
var points_categories = {
    "creation": 0,
    "exploration": 0,
    "interaction": 0,
    "challenge": 0,
    "mastery": 0
}

# Player preferences (auto-detected and manually set)
var player_preferences = {
    "prefers_challenge": 0.5, # 0.0-1.0
    "prefers_creation": 0.5,  # 0.0-1.0
    "prefers_exploration": 0.5, # 0.0-1.0
    "prefers_social": 0.5,     # 0.0-1.0
    "prefers_achievement": 0.5 # 0.0-1.0
}

# Signals
signal points_updated(total, category, amount)
signal dimension_changed(new_dimension)
signal preferences_updated()

func _ready():
    # Connect to Akashic Database if available
    if has_node("/root/AkashicDatabase") or get_node_or_null("/root/AkashicDatabase"):
        _akashic_db = get_node("/root/AkashicDatabase")
    
    # Connect to Account Connector if available
    if has_node("/root/SharedAccountConnector") or get_node_or_null("/root/SharedAccountConnector"):
        _account_connector = get_node("/root/SharedAccountConnector")
        
    # Set up auto-correction timer
    var timer = Timer.new()
    timer.wait_time = AUTO_CORRECTION_INTERVAL
    timer.autostart = true
    timer.connect("timeout", self, "_on_auto_correction_timer")
    add_child(timer)
    
    # Load player data
    load_account_data()

func load_account_data():
    # TODO: Load from file or database
    # Placeholder for now
    if _account_connector:
        player_name = _account_connector.get_current_player_name()
        account_id = _account_connector.get_current_account_id()
    
    # For testing - initialize with random data
    if player_name.empty():
        player_name = "Player" + str(randi() % 1000)
    
    if account_id.empty():
        account_id = generate_unique_id()
    
    # Load preferences from saved data or initialize defaults
    analyze_player_patterns()

func save_account_data():
    # TODO: Save to file or database
    print("Saving account data for: ", player_name)
    
    # Update connected systems
    if _account_connector:
        _account_connector.update_account_data({
            "points": total_points,
            "dimension": current_dimension,
            "preferences": player_preferences
        })

func add_points(amount, category = ""):
    var actual_amount = amount * enjoyment_factor
    
    # Apply category-specific bonuses based on player preferences
    if category in points_categories:
        var preference_key = "prefers_" + category if category == "challenge" else \
                            "prefers_creation" if category == "creation" else \
                            "prefers_exploration" if category == "exploration" else \
                            "prefers_social" if category == "interaction" else \
                            "prefers_achievement" if category == "mastery" else ""
        
        if preference_key in player_preferences:
            actual_amount *= (1.0 + player_preferences[preference_key])
        
        # Update category total
        points_categories[category] += actual_amount
    
    total_points += actual_amount
    
    # Check for dimension advancement
    check_dimension_advancement()
    
    # Update Akashic DB if connected
    if _akashic_db and category == "creation":
        _akashic_db.record_creation_event(actual_amount)
    
    emit_signal("points_updated", total_points, category, actual_amount)
    return actual_amount

func subtract_points(amount, category = ""):
    var actual_amount = min(amount, points_categories[category] if category in points_categories else amount)
    
    if category in points_categories:
        points_categories[category] -= actual_amount
    
    total_points -= actual_amount
    total_points = max(total_points, MIN_POINTS)
    
    emit_signal("points_updated", total_points, category, -actual_amount)
    return actual_amount

func check_dimension_advancement():
    # Calculate required points for next dimension
    var points_for_next_dimension = pow(current_dimension, 2) * 1000
    
    if total_points >= points_for_next_dimension and current_dimension < DIMENSION_MAX_LEVEL:
        advance_dimension()

func advance_dimension():
    current_dimension += 1
    print("Advanced to dimension: ", current_dimension)
    emit_signal("dimension_changed", current_dimension)
    
    # Apply dimension advancement effects
    if _akashic_db:
        _akashic_db.unlock_dimension(current_dimension)

func analyze_player_patterns():
    # This would normally analyze actual player data
    # For now, we'll just use placeholder logic
    
    # Example: Check if player has more creation points than other categories
    var total_cat_points = 0
    for cat in points_categories:
        total_cat_points += points_categories[cat]
    
    if total_cat_points > 0:
        player_preferences["prefers_creation"] = clamp(points_categories["creation"] / total_cat_points, 0.1, 0.9)
        player_preferences["prefers_exploration"] = clamp(points_categories["exploration"] / total_cat_points, 0.1, 0.9)
        
    # This would be updated based on actual gameplay telemetry
    emit_signal("preferences_updated")

func _on_auto_correction_timer():
    auto_correct_points()
    last_auto_correction = OS.get_unix_time()
    save_account_data()

func auto_correct_points():
    # Automatically adjust points based on player enjoyment patterns
    # This creates a feedback loop that maximizes player enjoyment
    
    # Calculate auto-correction
    var correction_amount = 0
    
    # If player is below dimension average, boost slightly
    var expected_points = current_dimension * 500
    if total_points < expected_points:
        correction_amount = expected_points * 0.05
    
    # Apply preference-based corrections
    var preferred_category = get_highest_preference_category()
    if preferred_category != "":
        points_categories[preferred_category] += correction_amount
        total_points += correction_amount
        
        print("Auto-corrected points: +", correction_amount, " to ", preferred_category)
    
    # Re-analyze preferences after correction
    analyze_player_patterns()

func get_highest_preference_category():
    var highest_pref = 0.0
    var category = ""
    
    if player_preferences["prefers_challenge"] > highest_pref:
        highest_pref = player_preferences["prefers_challenge"]
        category = "challenge"
        
    if player_preferences["prefers_creation"] > highest_pref:
        highest_pref = player_preferences["prefers_creation"] 
        category = "creation"
        
    if player_preferences["prefers_exploration"] > highest_pref:
        highest_pref = player_preferences["prefers_exploration"]
        category = "exploration"
        
    if player_preferences["prefers_social"] > highest_pref:
        highest_pref = player_preferences["prefers_social"]
        category = "interaction"
        
    if player_preferences["prefers_achievement"] > highest_pref:
        highest_pref = player_preferences["prefers_achievement"]
        category = "mastery"
        
    return category

func generate_unique_id():
    # Generate a simple unique ID
    return str(OS.get_unix_time()) + str(randi() % 10000)

# Helper methods for external access
func get_points_display():
    # Format points for display
    return str(int(total_points))
    
func get_dimension_display():
    # Get dimension with appropriate formatting and symbol
    return "Dimension " + str(current_dimension) + " / " + str(DIMENSION_MAX_LEVEL) + " " + DIMENSION_SYMBOLS[current_dimension]
    
func get_progress_to_next_dimension():
    # Calculate progress percentage to next dimension
    var points_for_next_dimension = pow(current_dimension, 2) * 1000
    if current_dimension >= DIMENSION_MAX_LEVEL:
        return 1.0
        
    var progress = float(total_points) / float(points_for_next_dimension)
    return clamp(progress, 0.0, 1.0)