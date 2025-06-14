extends Control

# Memory Investment Interface
# Provides visual interface for the memory investment system

@onready var investment_system = $"../MemoryInvestmentSystem"
@onready var direction_tracker = $"../WordDirectionTracker"

# UI Elements
var word_input: LineEdit
var category_dropdown: OptionButton
var invest_button: Button
var word_list: ItemList
var direction_display: RichTextLabel
var value_display: Label
var visualization: SubViewport

const CATEGORIES = ["Knowledge", "Insight", "Creation", "Connection", "Memory", "Dream", "Ethereal"]
const COLOR_GRADIENT = [
    Color(0.5, 0.7, 0.9, 0.8),  # Light Blue
    Color(0.4, 0.6, 0.9, 0.8),  # Eve Blue
    Color(0.3, 0.5, 0.9, 0.8),  # Deep Blue
    Color(0.4, 0.4, 0.8, 0.8)   # Twilight Blue
]

func _ready():
    # Create UI elements
    _setup_ui()
    
    # Connect signals
    invest_button.pressed.connect(_on_invest_pressed)
    word_list.item_selected.connect(_on_word_selected)
    
    # Update timer
    var timer = Timer.new()
    timer.wait_time = 0.5
    timer.autostart = true
    timer.timeout.connect(_update_display)
    add_child(timer)
    
    # Initial update
    _update_display()

func _setup_ui():
    # Input area
    var input_container = VBoxContainer.new()
    input_container.set_anchors_preset(PRESET_LEFT_WIDE)
    input_container.custom_minimum_size = Vector2(280, 0)
    add_child(input_container)
    
    var title = Label.new()
    title.text = "Memory Investment"
    title.add_theme_font_size_override("font_size", 18)
    input_container.add_child(title)
    
    input_container.add_child(HSeparator.new())
    
    var word_label = Label.new()
    word_label.text = "Enter Word to Invest:"
    input_container.add_child(word_label)
    
    word_input = LineEdit.new()
    word_input.placeholder_text = "Type a word..."
    input_container.add_child(word_input)
    
    var category_label = Label.new()
    category_label.text = "Category:"
    input_container.add_child(category_label)
    
    category_dropdown = OptionButton.new()
    for i in range(CATEGORIES.size()):
        category_dropdown.add_item(CATEGORIES[i], i)
    input_container.add_child(category_dropdown)
    
    invest_button = Button.new()
    invest_button.text = "Invest Word"
    invest_button.custom_minimum_size = Vector2(0, 40)
    input_container.add_child(invest_button)
    
    input_container.add_child(HSeparator.new())
    
    var list_label = Label.new()
    list_label.text = "Invested Words:"
    input_container.add_child(list_label)
    
    word_list = ItemList.new()
    word_list.custom_minimum_size = Vector2(0, 200)
    word_list.allow_reselect = true
    word_list.auto_height = true
    word_list.same_column_width = true
    input_container.add_child(word_list)
    
    input_container.add_child(HSeparator.new())
    
    value_display = Label.new()
    value_display.text = "Total Value: 0"
    input_container.add_child(value_display)
    
    # Direction display (right panel)
    var direction_container = VBoxContainer.new()
    direction_container.set_anchors_preset(PRESET_RIGHT_WIDE)
    direction_container.custom_minimum_size = Vector2(280, 0)
    add_child(direction_container)
    
    var dir_title = Label.new()
    dir_title.text = "Word Direction Analysis"
    dir_title.add_theme_font_size_override("font_size", 18)
    direction_container.add_child(dir_title)
    
    direction_container.add_child(HSeparator.new())
    
    direction_display = RichTextLabel.new()
    direction_display.bbcode_enabled = true
    direction_display.custom_minimum_size = Vector2(0, 400) 
    direction_display.scroll_following = true
    direction_container.add_child(direction_display)
    
    # Visualization (center area)
    var viewport_container = SubViewportContainer.new()
    viewport_container.set_anchors_preset(PRESET_CENTER)
    viewport_container.size = Vector2(400, 300)
    viewport_container.stretch = true
    add_child(viewport_container)
    
    visualization = SubViewport.new()
    visualization.size = Vector2(400, 300)
    visualization.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    viewport_container.add_child(visualization)
    
    # Add a 3D scene to the viewport
    var spatial = Node3D.new()
    visualization.add_child(spatial)
    
    var camera = Camera3D.new()
    camera.position = Vector3(0, 0, 5)
    camera.current = true
    spatial.add_child(camera)
    
    var light = DirectionalLight3D.new()
    light.position = Vector3(5, 5, 5)
    light.look_at(Vector3.ZERO, Vector3.UP)
    spatial.add_child(light)
    
    # Color the background
    var env = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.05, 0.07, 0.12)
    env.ambient_light_color = Color(0.3, 0.4, 0.5)
    
    var world = World3D.new()
    visualization.world_3d = world
    
    camera.environment = env

func _on_invest_pressed():
    var word = word_input.text.strip_edges()
    if word.is_empty():
        return
    
    var category = CATEGORIES[category_dropdown.selected]
    investment_system.invest_word(word, category)
    direction_tracker.analyze_word(word)
    
    word_input.text = ""
    _update_display()

func _on_word_selected(index):
    var word = word_list.get_item_text(index)
    direction_tracker.focus_word(word)
    _update_direction_display(word)

func _update_display():
    # Update word list
    word_list.clear()
    var investments = investment_system.get_investments()
    
    for investment in investments:
        var value_text = "%.2f" % investment.current_value
        var roi_text = "%.1f%%" % ((investment.current_value / investment.initial_value - 1.0) * 100.0)
        word_list.add_item("%s (%s): %s (%s)" % [investment.word, investment.category, value_text, roi_text])
    
    # Update total value
    var total_value = investment_system.get_total_value()
    value_display.text = "Total Value: %.2f" % total_value
    
    # Activate color cycling
    _update_colors()

func _update_direction_display(word = ""):
    if word.is_empty():
        # Show overall direction metrics
        var trends = direction_tracker.get_overall_direction_trend()
        
        direction_display.clear()
        direction_display.append_text("[b]Overall Direction Analysis:[/b]\n\n")
        
        for direction in trends:
            var strength = trends[direction]
            var bar_count = int(strength * 20)
            var bar = "█".repeat(bar_count)
            
            var color_code = _get_direction_color(direction)
            direction_display.append_text("%s: [color=%s]%s[/color] %.2f\n" % [direction, color_code, bar, strength])
    else:
        # Show specific word direction
        var word_direction = direction_tracker.get_word_direction(word)
        
        direction_display.clear()
        direction_display.append_text("[b]Direction Analysis for '%s':[/b]\n\n" % word)
        
        for direction in word_direction:
            var strength = word_direction[direction]
            if strength > 0.01:  # Only show significant directions
                var bar_count = int(strength * 20)
                var bar = "█".repeat(bar_count)
                
                var color_code = _get_direction_color(direction)
                direction_display.append_text("%s: [color=%s]%s[/color] %.2f\n" % [direction, color_code, bar, strength])
        
        # Show related words
        var related = direction_tracker.get_related_words(word)
        if related.size() > 0:
            direction_display.append_text("\n[b]Related Words:[/b]\n")
            for w in related:
                direction_display.append_text("- %s\n" % w)

func _get_direction_color(direction):
    match direction:
        "forward": return "#4a90e2"
        "backward": return "#e24a4a"
        "up": return "#4ae24a"
        "down": return "#e2e24a"
        "left": return "#e29e4a"
        "right": return "#9e4ae2"
        "inward": return "#4ae2e2"
        "outward": return "#e24ae2"
        _: return "#aaaaaa"

func _update_colors():
    # Cycle the color gradient for UI elements
    var time = Time.get_ticks_msec() / 1000.0
    
    # Calculate color based on time
    var idx = int(time) % COLOR_GRADIENT.size()
    var next_idx = (idx + 1) % COLOR_GRADIENT.size()
    var frac = fract(time)
    
    var current_color = COLOR_GRADIENT[idx].lerp(COLOR_GRADIENT[next_idx], frac)
    
    # Apply color to UI elements
    if is_instance_valid(invest_button):
        var stylebox = StyleBoxFlat.new()
        stylebox.bg_color = current_color
        stylebox.corner_radius_top_left = 4
        stylebox.corner_radius_top_right = 4
        stylebox.corner_radius_bottom_left = 4
        stylebox.corner_radius_bottom_right = 4
        invest_button.add_theme_stylebox_override("normal", stylebox)