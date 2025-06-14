extends Node
class_name DynamicColorSystem

"""
DynamicColorSystem
----------------
Advanced color management system for the dual memories project that goes
far beyond basic gray, implementing:

1. Dynamic color shifting based on memory content
2. Dimensional color mapping for different memory paths
3. Color blending for mixed memory sources
4. Custom color schemes with rich vibrant palettes
5. Animated color transitions and gradients
6. Color-coded memory visualization
7. Synesthetic color mapping based on text analysis
8. Message weight analysis for visual depth perception

The color system integrates with all parts of the dual memories architecture
to provide rich visual feedback and enhance the visual representation of
memory states and transformations.
"""

# System references
var animation_system: AnimationSystem
var terminal_split_controller: TerminalSplitController
var dual_memories_coordinator: DualMemoriesCoordinator
var meaning_transformation_pipeline = null

# Color palettes
var active_palette = "cosmic"
var color_palettes = {
    "cosmic": {
        "background": Color(0.05, 0.05, 0.1),
        "text": Color(0.9, 0.95, 1.0),
        "primary": Color(0.3, 0.2, 0.8),     # Deep purple
        "secondary": Color(0.2, 0.6, 0.9),   # Sky blue
        "tertiary": Color(0.8, 0.3, 0.9),    # Violet
        "quaternary": Color(0.1, 0.5, 0.7),  # Deep blue
        "accent1": Color(1.0, 0.5, 0.0),     # Orange
        "accent2": Color(0.0, 0.8, 0.6),     # Teal
        "accent3": Color(0.9, 0.8, 0.2),     # Gold
        "accent4": Color(0.7, 0.3, 0.5),     # Mauve
        "gradient1": [Color(0.05, 0.1, 0.2), Color(0.2, 0.3, 0.7)],
        "gradient2": [Color(0.0, 0.5, 0.7), Color(0.7, 0.2, 0.8)]
    },
    "vibrant": {
        "background": Color(0.1, 0.1, 0.1),
        "text": Color(0.95, 0.95, 0.95),
        "primary": Color(1.0, 0.2, 0.3),     # Bright red
        "secondary": Color(0.2, 0.8, 0.2),   # Bright green
        "tertiary": Color(0.2, 0.2, 1.0),    # Bright blue
        "quaternary": Color(1.0, 0.8, 0.0),  # Yellow
        "accent1": Color(1.0, 0.0, 1.0),     # Magenta
        "accent2": Color(0.0, 1.0, 1.0),     # Cyan
        "accent3": Color(1.0, 0.5, 0.0),     # Orange
        "accent4": Color(0.5, 0.0, 0.5),     # Purple
        "gradient1": [Color(1.0, 0.0, 0.0), Color(1.0, 1.0, 0.0)],
        "gradient2": [Color(0.0, 1.0, 0.0), Color(0.0, 1.0, 1.0)]
    },
    "earth": {
        "background": Color(0.15, 0.1, 0.05),
        "text": Color(0.9, 0.85, 0.8),
        "primary": Color(0.5, 0.3, 0.1),     # Brown
        "secondary": Color(0.3, 0.5, 0.2),   # Olive
        "tertiary": Color(0.6, 0.4, 0.2),    # Tan
        "quaternary": Color(0.4, 0.3, 0.25), # Dark brown
        "accent1": Color(0.7, 0.5, 0.3),     # Light brown
        "accent2": Color(0.2, 0.4, 0.3),     # Forest green
        "accent3": Color(0.6, 0.5, 0.4),     # Beige
        "accent4": Color(0.4, 0.3, 0.5),     # Purple-gray
        "gradient1": [Color(0.4, 0.3, 0.2), Color(0.5, 0.4, 0.3)],
        "gradient2": [Color(0.2, 0.4, 0.1), Color(0.4, 0.5, 0.2)]
    },
    "neon": {
        "background": Color(0.03, 0.03, 0.05),
        "text": Color(0.9, 0.9, 0.9),
        "primary": Color(1.0, 0.0, 1.0),     # Hot pink
        "secondary": Color(0.0, 1.0, 1.0),   # Cyan
        "tertiary": Color(1.0, 1.0, 0.0),    # Yellow
        "quaternary": Color(0.5, 1.0, 0.0),  # Lime
        "accent1": Color(1.0, 0.5, 0.0),     # Orange
        "accent2": Color(0.0, 0.5, 1.0),     # Blue
        "accent3": Color(1.0, 0.0, 0.5),     # Magenta
        "accent4": Color(0.5, 0.0, 1.0),     # Purple
        "gradient1": [Color(1.0, 0.0, 0.5), Color(0.5, 0.0, 1.0)],
        "gradient2": [Color(0.0, 1.0, 0.5), Color(0.0, 0.5, 1.0)]
    },
    "pastel": {
        "background": Color(0.9, 0.9, 0.95),
        "text": Color(0.2, 0.2, 0.25),
        "primary": Color(0.8, 0.6, 0.8),     # Lavender
        "secondary": Color(0.6, 0.8, 0.8),   # Light blue
        "tertiary": Color(0.8, 0.8, 0.6),    # Light yellow
        "quaternary": Color(0.6, 0.8, 0.6),  # Light green
        "accent1": Color(0.9, 0.7, 0.6),     # Peach
        "accent2": Color(0.7, 0.6, 0.9),     # Periwinkle
        "accent3": Color(0.9, 0.8, 0.9),     # Pink
        "accent4": Color(0.6, 0.9, 0.8),     # Mint
        "gradient1": [Color(0.8, 0.6, 0.8), Color(0.6, 0.8, 0.8)],
        "gradient2": [Color(0.8, 0.8, 0.6), Color(0.6, 0.8, 0.6)]
    },
    "monochrome_blue": {
        "background": Color(0.05, 0.1, 0.2),
        "text": Color(0.8, 0.9, 1.0),
        "primary": Color(0.1, 0.3, 0.7),     # Medium blue
        "secondary": Color(0.2, 0.4, 0.8),   # Bright blue
        "tertiary": Color(0.05, 0.2, 0.5),   # Dark blue
        "quaternary": Color(0.3, 0.5, 0.9),  # Light blue
        "accent1": Color(0.5, 0.7, 1.0),     # Very light blue
        "accent2": Color(0.15, 0.25, 0.6),   # Muted blue
        "accent3": Color(0.0, 0.4, 0.8),     # Strong blue
        "accent4": Color(0.2, 0.5, 0.7),     # Sky blue
        "gradient1": [Color(0.0, 0.2, 0.4), Color(0.2, 0.4, 0.8)],
        "gradient2": [Color(0.1, 0.3, 0.6), Color(0.3, 0.5, 0.9)]
    },
    "rainbow": {
        "background": Color(0.1, 0.1, 0.1),
        "text": Color(1.0, 1.0, 1.0),
        "primary": Color(1.0, 0.0, 0.0),     # Red
        "secondary": Color(1.0, 0.5, 0.0),   # Orange
        "tertiary": Color(1.0, 1.0, 0.0),    # Yellow
        "quaternary": Color(0.0, 1.0, 0.0),  # Green
        "accent1": Color(0.0, 0.0, 1.0),     # Blue
        "accent2": Color(0.5, 0.0, 1.0),     # Indigo
        "accent3": Color(0.8, 0.0, 0.8),     # Violet
        "accent4": Color(1.0, 0.0, 0.5),     # Pink
        "gradient1": [Color(1.0, 0.0, 0.0), Color(1.0, 1.0, 0.0), Color(0.0, 1.0, 0.0), Color(0.0, 0.0, 1.0)],
        "gradient2": [Color(1.0, 0.0, 1.0), Color(0.0, 1.0, 1.0)]
    },
    "memories": {
        "background": Color(0.05, 0.05, 0.07),
        "text": Color(0.9, 0.9, 0.93),
        "primary": Color(0.4, 0.1, 0.8),     # Deep purple
        "secondary": Color(0.1, 0.5, 0.9),   # Deep blue
        "tertiary": Color(0.9, 0.3, 0.5),    # Pink
        "quaternary": Color(0.3, 0.7, 0.9),  # Light blue
        "accent1": Color(0.9, 0.6, 0.1),     # Gold
        "accent2": Color(0.1, 0.8, 0.6),     # Turquoise
        "accent3": Color(0.8, 0.2, 0.8),     # Purple
        "accent4": Color(0.6, 0.8, 0.1),     # Lime
        "gradient1": [Color(0.4, 0.1, 0.8), Color(0.1, 0.5, 0.9)],
        "gradient2": [Color(0.9, 0.3, 0.5), Color(0.9, 0.6, 0.1)]
    }
}

# Terminal color assignments
var terminal_colors = {
    "terminal_0": "primary",
    "terminal_1": "secondary",
    "terminal_2": "tertiary",
    "terminal_3": "quaternary",
    "terminal_4": "accent1",
    "terminal_5": "accent2",
    "terminal_6": "accent3",
    "terminal_7": "accent4",
    "terminal_8": "primary"
}

# Text color mapping
var word_colors = {}
var dimensional_colors = {}
var mood_colors = {}
var weight_colors = {}

# Color transition state
var is_transitioning = false
var transition_progress = 0.0
var transition_from_palette = ""
var transition_to_palette = ""
var transition_duration = 1.0
var transition_timer = 0.0

# Rainbow mode settings
var rainbow_mode = false
var rainbow_phase = 0.0
var rainbow_colors = [
    Color(1.0, 0.0, 0.0),  # Red
    Color(1.0, 0.5, 0.0),  # Orange
    Color(1.0, 1.0, 0.0),  # Yellow
    Color(0.0, 1.0, 0.0),  # Green
    Color(0.0, 0.5, 1.0),  # Blue
    Color(0.3, 0.0, 0.8),  # Indigo
    Color(0.7, 0.0, 0.7)   # Violet
]

# System options
var multi_dimensional_coloring = true
var message_weight_coloring = true
var animated_colors = false

# Signals
signal color_palette_changed(old_palette, new_palette)
signal color_assigned(element_id, color)
signal color_transition_completed(palette_name)
signal terminal_colors_updated()
signal rainbow_mode_toggled(enabled)
signal hash_marker_processed(marker_count, mode)
signal message_weight_detected(text, weight)

# Initialize the color system
func _init():
    # Initialize color mappings
    _initialize_color_mappings()
    set_process(true)
    randomize()

# Initialize with system references
func initialize(animation_sys = null, terminal_controller = null, memories_coordinator = null, meaning_pipeline = null):
    animation_system = animation_sys
    terminal_split_controller = terminal_controller
    dual_memories_coordinator = memories_coordinator
    meaning_transformation_pipeline = meaning_pipeline
    
    # Set initial palette
    set_color_palette("cosmic", false)
    
    print("Dynamic Color System initialized")

# Process frame updates
func _process(delta):
    # Handle color transitions
    if is_transitioning:
        transition_timer += delta
        transition_progress = min(transition_timer / transition_duration, 1.0)
        
        # Update colors during transition
        _update_transition_colors()
        
        # Check if transition is complete
        if transition_progress >= 1.0:
            is_transitioning = false
            active_palette = transition_to_palette
            emit_signal("color_transition_completed", active_palette)
    
    # Handle rainbow mode
    if rainbow_mode:
        rainbow_phase += delta * 0.5
        if rainbow_phase > 1.0:
            rainbow_phase = 0.0
        _update_rainbow_colors(delta)
    
    # Handle animated colors
    if animated_colors:
        _update_animated_colors(delta)

# Set the active color palette
func set_color_palette(palette_name: String, with_transition: bool = true, duration: float = 1.0) -> bool:
    # Check if palette exists
    if not color_palettes.has(palette_name):
        return false
    
    var old_palette = active_palette
    
    # If transition requested
    if with_transition and old_palette != palette_name:
        transition_from_palette = old_palette
        transition_to_palette = palette_name
        transition_duration = duration
        transition_timer = 0.0
        transition_progress = 0.0
        is_transitioning = true
    else:
        # Instant change
        active_palette = palette_name
    
    # Apply to terminals
    apply_colors_to_terminals()
    
    # Create animation if available
    if animation_system and with_transition:
        animation_system.create_color_shift_animation(
            get_color("primary", old_palette),
            get_color("primary", palette_name),
            duration
        )
    
    emit_signal("color_palette_changed", old_palette, active_palette)
    return true

# Get a color from the active palette
func get_color(color_name: String, palette_name: String = "") -> Color:
    var palette = palette_name if palette_name else active_palette
    
    if color_palettes.has(palette) and color_palettes[palette].has(color_name):
        return color_palettes[palette][color_name]
    
    # Default to white if color not found
    return Color(1, 1, 1)

# Get a gradient from the active palette
func get_gradient(gradient_name: String, palette_name: String = "") -> Array:
    var palette = palette_name if palette_name else active_palette
    
    if color_palettes.has(palette) and color_palettes[palette].has(gradient_name):
        return color_palettes[palette][gradient_name]
    
    # Default gradient if not found
    return [Color(0, 0, 0), Color(1, 1, 1)]

# Assign colors to terminals based on active palette
func apply_colors_to_terminals() -> void:
    if not terminal_split_controller:
        return
    
    # Apply to each active terminal
    for i in range(9): # Max 9 terminals
        if terminal_split_controller.dual_core_terminal and \
           terminal_split_controller.dual_core_terminal.cores.has(i):
           
            var color_style = "default"
            var terminal_key = "terminal_" + str(i)
            
            # Get color name from terminal_colors map
            var color_name = terminal_colors.get(terminal_key, "primary")
            
            # Map color name to DualCoreTerminal style
            match color_name:
                "primary":
                    color_style = "blue"
                "secondary":
                    color_style = "green"
                "tertiary":
                    color_style = "purple"
                "quaternary":
                    color_style = "red"
                "accent1":
                    color_style = "gold"
                "accent2":
                    color_style = "orange"
                "accent3":
                    color_style = "cyan"
                "accent4":
                    color_style = "rainbow"
            
            # Apply style
            terminal_split_controller.dual_core_terminal.cores[i].bracket_style = color_style
    
    emit_signal("terminal_colors_updated")

# Process hash markers in text to detect color change commands
func process_hash_markers(text: String) -> Dictionary:
    var result = {
        "text": text,
        "original_text": text,
        "hash_count": 0,
        "action": "",
        "color_change": false,
        "hash_markers_removed": false
    }
    
    # Count consecutive hash symbols at start
    var hash_count = 0
    var i = 0
    
    while i < text.length() and text[i] == '#':
        hash_count += 1
        i += 1
    
    if hash_count > 0:
        result.hash_count = hash_count
        result.hash_markers_removed = true
        result.text = text.substr(hash_count)  # Remove hash markers
        
        # Specific actions based on hash count
        if hash_count in [1, 2, 3, 4, 5, 6, 7]:
            # Choose palette based on hash count
            var palettes = color_palettes.keys()
            var palette_index = min(hash_count - 1, palettes.size() - 1)
            var new_palette = palettes[palette_index]
            
            result.action = "palette_" + new_palette
            result.color_change = true
            set_color_palette(new_palette, true, 1.0)
            
            # Emit signal
            emit_signal("hash_marker_processed", hash_count, new_palette)
            
        elif hash_count >= 8 and hash_count < 11:
            # Special cases for extended functionality
            if hash_count == 8:
                # Custom palette (user-defined)
                result.action = "custom_palette"
                # Implementation would depend on how custom palettes are stored
            elif hash_count == 9:
                # Rainbow pulsing
                result.action = "rainbow_pulse"
                rainbow_mode = true
                animated_colors = true
                emit_signal("rainbow_mode_toggled", true)
            elif hash_count == 10:
                # Multi-dimensional coloring
                result.action = "multi_dimensional"
                multi_dimensional_coloring = true
            
            # Emit signal
            emit_signal("hash_marker_processed", hash_count, result.action)
            
        elif hash_count >= 15:
            # Full rainbow mode
            result.action = "rainbow"
            rainbow_mode = true
            set_color_palette("rainbow", true, 1.0)
            emit_signal("rainbow_mode_toggled", true)
            emit_signal("hash_marker_processed", hash_count, "rainbow")
    
    return result

# Process text to apply color based on content
func color_text_by_content(text: String, memory_type: String = "undefined") -> String:
    var colored_text = text
    var color = get_color("text")  # Default text color
    
    # Apply specific memory dimension coloring
    if memory_type in dimensional_colors and multi_dimensional_coloring:
        var color_key = dimensional_colors[memory_type]
        color = get_color(color_key)
    
    # Apply emotional context coloring
    if mood_colors.size() > 0:
        for mood in mood_colors.keys():
            if mood.to_lower() in text.to_lower():
                var mood_color_key = mood_colors[mood]
                var mood_color = get_color(mood_color_key)
                # Blend with existing color (60% current, 40% mood)
                color = color.linear_interpolate(mood_color, 0.4)
                break
    
    # Apply message weight coloring if enabled
    if message_weight_coloring:
        var weight = _analyze_message_weight(text)
        if weight in weight_colors:
            var weight_color_key = weight_colors[weight]
            var w_color = get_color(weight_color_key)
            # Blend with existing color (70% current, 30% weight)
            color = color.linear_interpolate(w_color, 0.3)
    
    # Check for special sequences
    if "000" in text:
        color = Color(0.2, 0.2, 0.2)  # Dark gray for zeros
    elif "111" in text:
        color = Color(0.9, 0.9, 0.9)  # Light gray for ones
    elif "222" in text:
        color = Color(0.6, 0.6, 0.6)  # Medium gray for twos
    
    # Apply color using BBCode
    colored_text = "[color=#" + color.to_html() + "]" + text + "[/color]"
    
    return colored_text

# Get color for specific dimension
func get_dimension_color(dimension: String) -> Color:
    if dimensional_colors.has(dimension):
        return get_color(dimensional_colors[dimension])
    
    # Default
    return get_color("primary")

# Get color for a word
func get_word_color(word: String) -> Color:
    # Check if word has a specific color assignment
    if word_colors.has(word.to_lower()):
        return get_color(word_colors[word.to_lower()])
    
    # Generate consistent color based on word hash
    var hash_value = 0
    for c in word:
        hash_value += ord(c)
    
    var color_keys = color_palettes[active_palette].keys()
    var usable_keys = []
    
    # Filter only actual color keys (not gradients or special keys)
    for key in color_keys:
        if key != "background" and key != "text" and not key.begins_with("gradient"):
            usable_keys.append(key)
    
    # Get a consistent color based on hash
    var color_key = usable_keys[hash_value % usable_keys.size()]
    
    # Cache for future use
    word_colors[word.to_lower()] = color_key
    
    return get_color(color_key)

# Process multi-colored text with hash sections
func process_multi_colored_text(text: String) -> String:
    var sections = text.split("#")
    var result = ""
    
    if sections.size() <= 1:
        return text
    
    for i in range(sections.size()):
        if i == 0:
            result += sections[i]
            continue
            
        var section_text = sections[i]
        if section_text.empty():
            continue
            
        var color = generate_color_from_text(section_text)
        result += "[color=#" + color.to_html() + "]" + section_text + "[/color]"
        
    return result

# Generate a color based on text content
func generate_color_from_text(text: String) -> Color:
    var hash = 0
    for i in range(text.length()):
        hash = ((hash << 5) - hash) + text.ord_at(i)
        hash = hash & 0xFFFFFFFF
    
    # Convert hash to color
    var r = float((hash >> 16) & 0xFF) / 255.0
    var g = float((hash >> 8) & 0xFF) / 255.0
    var b = float(hash & 0xFF) / 255.0
    
    return Color(r, g, b)

# Create a color gradient between two colors
func create_color_gradient(color1: Color, color2: Color, steps: int) -> Array:
    var gradient = []
    for i in range(steps):
        var t = float(i) / (steps - 1)
        var r = color1.r + (color2.r - color1.r) * t
        var g = color1.g + (color2.g - color1.g) * t
        var b = color1.b + (color2.b - color1.b) * t
        var a = color1.a + (color2.a - color1.a) * t
        gradient.append(Color(r, g, b, a))
    return gradient

# Create a custom color palette
func create_custom_palette(palette_name: String, colors: Dictionary) -> bool:
    # Check for required basic colors
    var required_colors = ["background", "text", "primary", "secondary"]
    
    for required in required_colors:
        if not colors.has(required):
            return false
    
    # Create palette
    color_palettes[palette_name] = colors
    return true

# Enable/disable message weight coloring
func set_message_weight_coloring(enabled: bool) -> void:
    message_weight_coloring = enabled

# Enable/disable multi-dimensional coloring
func set_multi_dimensional_coloring(enabled: bool) -> void:
    multi_dimensional_coloring = enabled

# Enable/disable rainbow mode
func set_rainbow_mode(enabled: bool) -> void:
    rainbow_mode = enabled
    emit_signal("rainbow_mode_toggled", enabled)
    
    if enabled:
        animated_colors = true
    else:
        # Return to standard palette if disabling rainbow mode
        apply_colors_to_terminals()

# Enable/disable animated colors
func set_animated_colors(enabled: bool) -> void:
    animated_colors = enabled

# Sets a specific color for a dimension
func set_dimension_color(dimension: String, color_key: String) -> void:
    dimensional_colors[dimension] = color_key

# Gets color for message weight
func get_color_for_weight(weight: String) -> Color:
    if weight in weight_colors:
        return get_color(weight_colors[weight])
    return get_color("text")  # Default text color

# Creates a visual color transition between word and wish systems
func create_dimension_blend(word_memory_color_key: String, wish_knowledge_color_key: String, blend_factor: float) -> Color:
    var word_color = get_color(word_memory_color_key)
    var wish_color = get_color(wish_knowledge_color_key)
    return word_color.linear_interpolate(wish_color, blend_factor)

# Process a word restart by color rules
func process_word_restart(text: String) -> Dictionary:
    var result = {
        "original_text": text,
        "processed_text": text,
        "color_key": "text",
        "restart_detected": false,
        "restart_type": "",
        "weight": "medium"
    }
    
    # Check for restart keywords
    var text_lower = text.to_lower()
    
    if "restart" in text_lower or "rules" in text_lower or "reason" in text_lower:
        result.restart_detected = true
        
        if "restart" in text_lower:
            result.restart_type = "restart"
            result.color_key = "accent1"  # Orange
        elif "rules" in text_lower:
            result.restart_type = "rules"
            result.color_key = "tertiary"  # Violet
        elif "reason" in text_lower:
            result.restart_type = "reason"
            result.color_key = "secondary"  # Blue
        
        # Apply message weight analysis
        result.weight = _analyze_message_weight(text)
        
        # Apply color based on restart type and weight
        var color = get_color(result.color_key)
        var weight_color = get_color_for_weight(result.weight)
        
        # Blend colors (70% restart type, 30% weight)
        var final_color = color.linear_interpolate(weight_color, 0.3)
        
        # Apply BBCode coloring
        result.processed_text = "[color=#" + final_color.to_html() + "]" + text + "[/color]"
    
    return result

# Private methods

# Analyze message weight based on content
func _analyze_message_weight(text: String) -> String:
    var text_lower = text.to_lower()
    
    # Words indicating heaviness
    var heavy_words = ["heavy", "dense", "thick", "solid", "massive", "weight", "deep", "reason"]
    var light_words = ["light", "airy", "thin", "transparent", "weightless", "float", "simple"]
    var ethereal_words = ["ethereal", "dream", "spiritual", "astral", "divine", "restart"]
    
    # Count word occurrences
    var heavy_count = 0
    var light_count = 0
    var ethereal_count = 0
    
    for word in heavy_words:
        if word in text_lower:
            heavy_count += 1
            
    for word in light_words:
        if word in text_lower:
            light_count += 1
            
    for word in ethereal_words:
        if word in text_lower:
            ethereal_count += 1
    
    # Message length factor (longer messages tend to feel "heavier")
    var length_factor = clamp(text.length() / 100.0, 0.0, 1.0)
    
    # Determine weight based on counts and length
    var weight = "medium"  # Default
    
    if ethereal_count > 0 and ethereal_count >= heavy_count and ethereal_count >= light_count:
        weight = "ethereal"
    elif heavy_count > 0 or length_factor > 0.7:
        weight = "heavy"
    elif light_count > 0 or text.length() < 20:
        weight = "light"
    elif length_factor > 0.4:
        weight = "dense"
    
    # Emit signal for detected weight
    emit_signal("message_weight_detected", text, weight)
    
    return weight

# Initialize color mappings
func _initialize_color_mappings():
    # Dimensional color mapping
    dimensional_colors = {
        "1D": "primary",
        "2D": "secondary",
        "3D": "tertiary",
        "4D": "quaternary",
        "5D": "accent1",
        "6D": "accent2",
        "7D": "accent3",
        "8D": "accent4",
        "9D": "primary",
        "10D": "secondary",
        "11D": "tertiary",
        "12D": "quaternary",
        "word": "primary",
        "wish": "accent1",
        "dual": "tertiary",
        "dream": "accent2",
        "reality": "quaternary",
        "virtual": "secondary",
        "spiritual": "accent3",
        "quantum": "accent4",
        "undefined": "text"
    }
    
    # Mood color mapping
    mood_colors = {
        "happy": "accent3",
        "sad": "quaternary",
        "angry": "primary",
        "calm": "secondary",
        "excited": "accent1",
        "neutral": "tertiary"
    }
    
    # Message weight colors
    weight_colors = {
        "light": "accent2",       # Teal
        "medium": "text",         # Default text
        "heavy": "primary",       # Deep color
        "dense": "quaternary",    # Rich color
        "ethereal": "accent3"     # Bright/light color
    }
    
    # Special word color mapping
    word_colors = {
        "memory": "primary",
        "word": "secondary",
        "dual": "tertiary",
        "terminal": "quaternary",
        "dimension": "accent1",
        "color": "accent2",
        "shape": "accent3",
        "transform": "accent4",
        "claude": "primary",
        "desktop": "secondary",
        "console": "tertiary",
        "editor": "quaternary",
        "split": "accent1",
        "hash": "accent2",
        "hatching": "accent3",
        "catchphrase": "accent4",
        "restart": "accent1",
        "rules": "tertiary",
        "reason": "secondary"
    }

# Update colors during transition
func _update_transition_colors():
    if terminal_split_controller == null:
        return
        
    var terminals = terminal_split_controller.active_terminal_cores
    
    for i in range(terminals.size()):
        var core_id = terminals[i]
        if terminal_split_controller.dual_core_terminal.cores.has(core_id):
            var terminal = terminal_split_controller.dual_core_terminal.cores[core_id]
            
            # Get from and to colors
            var from_color = get_color("text", transition_from_palette)
            var to_color = get_color("text", transition_to_palette)
            
            # Interpolate
            var text_color = from_color.linear_interpolate(to_color, transition_progress)
            
            # Apply
            terminal.text_color = text_color

# Update rainbow mode colors
func _update_rainbow_colors(delta):
    if terminal_split_controller == null:
        return
        
    var terminals = terminal_split_controller.active_terminal_cores
    var color_count = rainbow_colors.size()
    
    for i in range(terminals.size()):
        var core_id = terminals[i]
        if terminal_split_controller.dual_core_terminal.cores.has(core_id):
            var terminal = terminal_split_controller.dual_core_terminal.cores[core_id]
            
            var color_index = int((rainbow_phase * color_count + i) % color_count)
            var next_index = (color_index + 1) % color_count
            
            var blend = fmod(rainbow_phase * color_count, 1.0)
            var color = rainbow_colors[color_index].linear_interpolate(
                rainbow_colors[next_index], blend)
            
            # Apply rainbow colors
            terminal.text_color = color
            terminal.cursor_color = color.lightened(0.3)
            terminal.background_color = Color(0.1, 0.1, 0.1)  # Dark background to make colors pop

# Update animated colors
func _update_animated_colors(delta):
    if terminal_split_controller == null:
        return
        
    var pulse = (sin(OS.get_ticks_msec() * 0.001) + 1.0) * 0.5
    var terminals = terminal_split_controller.active_terminal_cores
    
    for i in range(terminals.size()):
        var core_id = terminals[i]
        if terminal_split_controller.dual_core_terminal.cores.has(core_id):
            var terminal = terminal_split_controller.dual_core_terminal.cores[core_id]
            
            # Get base color for this terminal
            var color_name = terminal_colors.get("terminal_" + str(core_id), "primary")
            var color = get_color(color_name)
            
            # Apply pulse effect
            var pulsed_color = color.lightened(pulse * 0.3)
            
            # Apply animated colors
            terminal.text_color = pulsed_color
            terminal.cursor_color = pulsed_color.lightened(0.2)
        }