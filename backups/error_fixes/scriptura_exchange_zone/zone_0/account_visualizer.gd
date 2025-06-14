extends Control

class_name AccountVisualizer

# Constants
const DIMENSION_COLORS = [
    Color(0.2, 0.4, 0.8), # Dimension 1
    Color(0.3, 0.6, 0.9), # Dimension 2
    Color(0.4, 0.7, 0.8), # Dimension 3
    Color(0.5, 0.8, 0.7), # Dimension 4
    Color(0.6, 0.9, 0.6), # Dimension 5
    Color(0.7, 0.9, 0.5), # Dimension 6
    Color(0.8, 0.9, 0.4), # Dimension 7
    Color(0.9, 0.8, 0.3), # Dimension 8
    Color(0.9, 0.7, 0.2), # Dimension 9
    Color(0.9, 0.6, 0.1), # Dimension 10
    Color(0.9, 0.5, 0.0), # Dimension 11
    Color(1.0, 0.4, 0.0)  # Dimension 12
]

const CATEGORY_COLORS = {
    "creation": Color(0.2, 0.8, 0.2),
    "exploration": Color(0.2, 0.2, 0.8),
    "interaction": Color(0.8, 0.2, 0.8),
    "challenge": Color(0.8, 0.2, 0.2),
    "mastery": Color(0.8, 0.8, 0.2)
}

const VISUALIZATION_MODES = ["radial", "bar", "line", "custom"]

# UI elements
var visualizer_container
var points_label
var dimension_label
var category_bars = {}
var dimension_progress
var preference_indicators = {}
var history_graph
var playstyle_label

# Settings
var visualization_mode = "radial"
var animation_speed = 1.0
var color_scheme = "standard"
var show_predictions = true
var highlight_preferences = true

# State data
var current_points = 0
var current_dimension = 1
var dimension_progress_value = 0.0
var category_values = {}
var preferences = {}
var points_history = []
var playstyle = "Unknown"

# References
var _account_manager = null
var _preference_analyzer = null
var _auto_correction = null

# Tween for animations
var tween

func _ready():
    # Setup UI elements
    setup_ui()
    
    # Connect to systems
    connect_to_systems()
    
    # Initial update
    update_visualization()

func setup_ui():
    # Main container
    visualizer_container = VBoxContainer.new()
    visualizer_container.anchor_right = 1.0
    visualizer_container.anchor_bottom = 1.0
    add_child(visualizer_container)
    
    # Top section - Account Info
    var top_section = HBoxContainer.new()
    visualizer_container.add_child(top_section)
    
    # Points display
    var points_container = VBoxContainer.new()
    top_section.add_child(points_container)
    
    var points_title = Label.new()
    points_title.text = "ACCOUNT POINTS"
    points_title.align = Label.ALIGN_CENTER
    points_container.add_child(points_title)
    
    points_label = Label.new()
    points_label.text = "0"
    points_label.align = Label.ALIGN_CENTER
    points_container.add_child(points_label)
    
    # Dimension display
    var dimension_container = VBoxContainer.new()
    top_section.add_child(dimension_container)
    
    var dimension_title = Label.new()
    dimension_title.text = "DIMENSION"
    dimension_title.align = Label.ALIGN_CENTER
    dimension_container.add_child(dimension_title)
    
    dimension_label = Label.new()
    dimension_label.text = "1 / 12 #"
    dimension_label.align = Label.ALIGN_CENTER
    dimension_container.add_child(dimension_label)
    
    # Playstyle display
    var playstyle_container = VBoxContainer.new()
    top_section.add_child(playstyle_container)
    
    var playstyle_title = Label.new()
    playstyle_title.text = "PLAYSTYLE"
    playstyle_title.align = Label.ALIGN_CENTER
    playstyle_container.add_child(playstyle_title)
    
    playstyle_label = Label.new()
    playstyle_label.text = "Unknown"
    playstyle_label.align = Label.ALIGN_CENTER
    playstyle_container.add_child(playstyle_label)
    
    # Middle section - Category Breakdown
    var middle_section = VBoxContainer.new()
    visualizer_container.add_child(middle_section)
    
    var categories_title = Label.new()
    categories_title.text = "POINTS BY CATEGORY"
    categories_title.align = Label.ALIGN_CENTER
    middle_section.add_child(categories_title)
    
    var categories_grid = GridContainer.new()
    categories_grid.columns = 5
    middle_section.add_child(categories_grid)
    
    # Create category bars
    for category in CATEGORY_COLORS:
        var category_container = VBoxContainer.new()
        categories_grid.add_child(category_container)
        
        var category_label = Label.new()
        category_label.text = category.capitalize()
        category_label.align = Label.ALIGN_CENTER
        category_container.add_child(category_label)
        
        var progress_bar = ProgressBar.new()
        progress_bar.max_value = 1.0
        progress_bar.rect_min_size = Vector2(80, 20)
        progress_bar.modulate = CATEGORY_COLORS[category]
        category_container.add_child(progress_bar)
        
        var value_label = Label.new()
        value_label.text = "0"
        value_label.align = Label.ALIGN_CENTER
        category_container.add_child(value_label)
        
        category_bars[category] = {"bar": progress_bar, "label": value_label}
    
    # Bottom section - Dimension Progress
    var bottom_section = VBoxContainer.new()
    visualizer_container.add_child(bottom_section)
    
    var dimension_progress_title = Label.new()
    dimension_progress_title.text = "PROGRESS TO NEXT DIMENSION"
    dimension_progress_title.align = Label.ALIGN_CENTER
    bottom_section.add_child(dimension_progress_title)
    
    dimension_progress = ProgressBar.new()
    dimension_progress.max_value = 1.0
    dimension_progress.rect_min_size = Vector2(300, 30)
    bottom_section.add_child(dimension_progress)
    
    # Create tween for animations
    tween = Tween.new()
    add_child(tween)
    
    # Visualization area
    setup_visualization_area()

func setup_visualization_area():
    # This would be a custom visualization based on the mode
    # For this example, we'll just add a placeholder
    var visualization_container = Control.new()
    visualization_container.rect_min_size = Vector2(400, 200)
    visualizer_container.add_child(visualization_container)
    
    # In a real implementation, this would create the actual visualization
    # based on the selected mode (radial, bar, line, etc.)

func connect_to_systems():
    # Connect to account manager
    if has_node("/root/SmartAccountManager") or get_node_or_null("/root/SmartAccountManager"):
        _account_manager = get_node("/root/SmartAccountManager")
        _account_manager.connect("points_updated", self, "_on_points_updated")
        _account_manager.connect("dimension_changed", self, "_on_dimension_changed")
        print("Connected to SmartAccountManager")
        
        # Initial data
        current_points = _account_manager.total_points
        current_dimension = _account_manager.current_dimension
        dimension_progress_value = _account_manager.get_progress_to_next_dimension()
        category_values = _account_manager.points_categories
    
    # Connect to preference analyzer
    if has_node("/root/PlayerPreferenceAnalyzer") or get_node_or_null("/root/PlayerPreferenceAnalyzer"):
        _preference_analyzer = get_node("/root/PlayerPreferenceAnalyzer")
        _preference_analyzer.connect("preferences_updated", self, "_on_preferences_updated")
        print("Connected to PlayerPreferenceAnalyzer")
    
    # Connect to auto-correction system
    if has_node("/root/AutoCorrectionSystem") or get_node_or_null("/root/AutoCorrectionSystem"):
        _auto_correction = get_node("/root/AutoCorrectionSystem")
        _auto_correction.connect("playstyle_detected", self, "_on_playstyle_detected")
        _auto_correction.connect("correction_applied", self, "_on_correction_applied")
        print("Connected to AutoCorrectionSystem")
        
        # Initial playstyle
        playstyle = _auto_correction.get_playstyle()

func update_visualization():
    # Update labels
    points_label.text = str(int(current_points))

    # Get dimension symbol
    var dimension_symbol = "#"
    if _account_manager and _account_manager.has_method("get_dimension_display"):
        dimension_label.text = _account_manager.get_dimension_display()
    else:
        dimension_symbol = "#".repeat(current_dimension)
        dimension_label.text = str(current_dimension) + " / 12 " + dimension_symbol

    playstyle_label.text = playstyle
    
    # Update dimension progress
    tween.interpolate_property(dimension_progress, "value", 
        dimension_progress.value, dimension_progress_value, 
        0.5 * animation_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT)
    
    # Update dimension progress color
    dimension_progress.modulate = DIMENSION_COLORS[min(current_dimension - 1, DIMENSION_COLORS.size() - 1)]
    
    # Update category bars
    var total_points = 0
    for category in category_values:
        total_points += category_values[category]
    
    for category in category_bars:
        var value = 0
        if category in category_values:
            value = category_values[category]
        
        var normalized = 0.0
        if total_points > 0:
            normalized = float(value) / float(total_points)
        
        # Update progress bar
        tween.interpolate_property(category_bars[category]["bar"], "value", 
            category_bars[category]["bar"].value, normalized, 
            0.5 * animation_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT)
        
        # Update label
        category_bars[category]["label"].text = str(int(value))
        
        # Highlight preferred categories
        if highlight_preferences and category in preferences:
            var pref_value = preferences[category]
            if pref_value >= 0.7:
                category_bars[category]["bar"].modulate = CATEGORY_COLORS[category].lightened(0.3)
            else:
                category_bars[category]["bar"].modulate = CATEGORY_COLORS[category]
    
    # Start animations
    tween.start()
    
    # In a real implementation, would also update the actual visualization
    # based on the visualization_mode

func _on_points_updated(total, category, amount):
    # Update current points
    current_points = total
    
    # Update category values if available
    if _account_manager:
        category_values = _account_manager.points_categories
    
    # Add to points history
    points_history.append({
        "points": total,
        "category": category,
        "amount": amount,
        "timestamp": OS.get_unix_time()
    })
    
    # Limit history size
    if points_history.size() > 100:
        points_history.pop_front()
    
    # Update visualization
    update_visualization()
    
    # If large point gain, add special effect
    if amount >= 50:
        play_point_gain_effect(amount)

func _on_dimension_changed(new_dimension):
    # Update dimension
    current_dimension = new_dimension
    
    # Get progress to next dimension
    if _account_manager:
        dimension_progress_value = _account_manager.get_progress_to_next_dimension()
    
    # Update visualization
    update_visualization()
    
    # Play dimension advancement effect
    play_dimension_advancement_effect()

func _on_preferences_updated(new_preferences):
    # Update preferences
    preferences = new_preferences
    
    # Update visualization
    update_visualization()

func _on_playstyle_detected(new_playstyle):
    # Update playstyle
    playstyle = new_playstyle
    
    # Update visualization
    update_visualization()

func _on_correction_applied(amount, category, reason):
    # Could show a subtle notification
    if amount >= 20:
        play_correction_effect(amount, category)

func play_point_gain_effect(amount):
    # In a real implementation, this would play a visual effect
    # For now, we'll just print to the console
    print("VISUAL EFFECT: Large point gain - " + str(amount) + " points!")

func play_dimension_advancement_effect():
    # In a real implementation, this would play a visual effect
    # For now, we'll just print to the console
    print("VISUAL EFFECT: Dimension advancement to level " + str(current_dimension) + "!")

func play_correction_effect(amount, category):
    # In a real implementation, this would play a visual effect
    # For now, we'll just print to the console
    print("VISUAL EFFECT: Auto-correction applied - " + str(amount) + " points to " + category + "!")

func set_visualization_mode(mode):
    # Validate mode
    if mode in VISUALIZATION_MODES:
        visualization_mode = mode
        
        # In a real implementation, would rebuild the visualization
        print("Changed visualization mode to: " + mode)
        return true
    
    return false

func set_animation_speed(speed):
    animation_speed = clamp(speed, 0.1, 3.0)
    return true

func set_color_scheme(scheme):
    color_scheme = scheme
    
    # In a real implementation, would update colors
    print("Changed color scheme to: " + scheme)
    return true

func toggle_predictions(enabled):
    show_predictions = enabled
    
    # In a real implementation, would update visualization
    print("Predictions " + ("enabled" if enabled else "disabled"))
    return true

func toggle_preference_highlighting(enabled):
    highlight_preferences = enabled
    update_visualization()
    return true