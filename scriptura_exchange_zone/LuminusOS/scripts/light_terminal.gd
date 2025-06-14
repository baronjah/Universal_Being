extends RichTextLabel

# Light Terminal Interface for Light of Data System
# Specialized terminal for handling light data transformations and storytelling

# System references
var light_data_system = null
var light_visualizer = null
var light_story_integrator = null
var data_sea = null
var memory_system = null

# Input field reference
var command_input

# Command history 
var command_history = []
var history_position = -1

# Initialization
func _ready():
    # Setup references
    light_data_system = get_node_or_null("/root/LightDataTransformer")
    if not light_data_system:
        light_data_system = get_node_or_null("../../../LightDataTransformer")
    
    light_visualizer = get_node_or_null("/root/LightDataVisualizer")
    if not light_visualizer:
        light_visualizer = get_node_or_null("../../../LightDataVisualizer")
    
    data_sea = get_node_or_null("/root/DataSeaController")
    memory_system = get_node_or_null("/root/TerminalMemorySystem")
    
    # Create light story integrator if not found
    light_story_integrator = get_node_or_null("/root/LightStoryIntegrator")
    if not light_story_integrator:
        light_story_integrator = LightStoryIntegrator.new()
        add_child(light_story_integrator)
        
        # Connect to other systems
        if light_data_system:
            light_story_integrator.transformer = light_data_system
    
    # Get command input reference
    command_input = get_node_or_null("../CommandInput")
    if command_input:
        command_input.connect("text_submitted", Callable(self, "_on_command_submitted"))
    
    # Show welcome message
    display_welcome()

# Show welcome message
func display_welcome():
    clear()
    append_bbcode("[color=#88CCFF][b]Light of Data Terminal[/b][/color]\n")
    append_bbcode("Transform data between 12 and 22 lines\n")
    append_bbcode("-----------------------------------------\n")
    append_bbcode("Type [color=#FFFF00]help[/color] to see available commands\n\n")

# Process command input
func _on_command_submitted(command):
    if command.strip_edges() == "":
        if command_input:
            command_input.clear()
        return
    
    # Add command to history
    command_history.append(command)
    history_position = command_history.size()
    
    # Show command
    append_bbcode("[color=#88FFAA]> " + command + "[/color]\n")
    
    # Process command
    process_command(command)
    
    # Clear input
    if command_input:
        command_input.clear()

# Process the command
func process_command(command):
    var parts = command.strip_edges().split(" ", false)
    var cmd = parts[0].to_lower()
    var args = parts.slice(1)
    var args_text = " ".join(args)
    
    match cmd:
        "help":
            show_help()
        "clear":
            clear()
        "transform":
            transform_data(args_text)
        "visualize":
            visualize_data(args_text)
        "integrate":
            integrate_with_story(args_text)
        "modes":
            show_transformation_modes()
        "intensity":
            set_light_intensity(args_text)
        "sources":
            show_light_sources()
        "history":
            show_transformation_history()
        "stories":
            show_story_integration()
        "status":
            show_system_status()
        _:
            # Pass to light data system if available
            if light_data_system and light_data_system.has_method("process_command"):
                var result = light_data_system.process_command(command)
                append_bbcode(result + "\n")
            else:
                append_bbcode("Unknown command: " + cmd + "\n")

# Show help
func show_help():
    append_bbcode("[color=#FFFF88]Light of Data Terminal Commands:[/color]\n\n")
    append_bbcode("Core Commands:\n")
    append_bbcode("  [color=#AAFFAA]help[/color] - Show this help\n")
    append_bbcode("  [color=#AAFFAA]clear[/color] - Clear the terminal\n")
    append_bbcode("  [color=#AAFFAA]status[/color] - Show system status\n\n")
    
    append_bbcode("Transformation Commands:\n")
    append_bbcode("  [color=#AAFFAA]transform <data_id> [mode] [target_lines][/color] - Transform data\n")
    append_bbcode("  [color=#AAFFAA]modes[/color] - Show available transformation modes\n")
    append_bbcode("  [color=#AAFFAA]intensity <level>[/color] - Set light intensity (0-4)\n\n")
    
    append_bbcode("Visualization Commands:\n")
    append_bbcode("  [color=#AAFFAA]visualize <transformation_id>[/color] - Visualize a transformation\n")
    append_bbcode("  [color=#AAFFAA]sources[/color] - List active light sources\n\n")
    
    append_bbcode("Storytelling Commands:\n")
    append_bbcode("  [color=#AAFFAA]integrate <transformation_id> [story_type][/color] - Integrate with story\n")
    append_bbcode("  [color=#AAFFAA]stories[/color] - Show active story integrations\n\n")
    
    append_bbcode("History Commands:\n")
    append_bbcode("  [color=#AAFFAA]history[/color] - Show transformation history\n")

# Show system status
func show_system_status():
    append_bbcode("[color=#88CCFF][b]Light of Data System Status[/b][/color]\n\n")
    
    # Light Data Transformer status
    if light_data_system:
        append_bbcode("Transformer: [color=#AAFFAA]Available[/color]\n")
        var sources = light_data_system.get_active_light_sources()
        append_bbcode("  Active Light Sources: " + str(sources.size()) + "\n")
        
        var history = light_data_system.get_transformation_history(3)
        append_bbcode("  Recent Transformations: " + str(history.size()) + "\n")
        
        if light_data_system.config:
            append_bbcode("  Current Intensity: " + light_data_system.LIGHT_INTENSITY_LEVELS[light_data_system.config.default_intensity] + "\n")
            append_bbcode("  Default Mode: " + light_data_system.config.default_mode + "\n")
    else:
        append_bbcode("Transformer: [color=#FFAAAA]Not Available[/color]\n")
    
    # Light Visualizer status
    if light_visualizer:
        append_bbcode("\nVisualizer: [color=#AAFFAA]Available[/color]\n")
        append_bbcode("  " + light_visualizer.get_visualization_status() + "\n")
    else:
        append_bbcode("\nVisualizer: [color=#FFAAAA]Not Available[/color]\n")
    
    # Light Story Integrator status
    if light_story_integrator:
        append_bbcode("\nStory Integration: [color=#AAFFAA]Available[/color]\n")
        var integrations = light_story_integrator.get_active_integrations()
        append_bbcode("  Active Integrations: " + str(integrations.size()) + "\n")
        
        if integrations.size() > 0:
            append_bbcode("  Latest Integration: " + integrations.keys()[integrations.size() - 1] + "\n")
    else:
        append_bbcode("\nStory Integration: [color=#FFAAAA]Not Available[/color]\n")

# Transform data
func transform_data(args_text):
    if not light_data_system:
        append_bbcode("[color=#FFAAAA]Error: Light Data Transformer not available[/color]\n")
        return
    
    # Parse arguments
    var args = args_text.split(" ")
    
    if args.size() < 1 or args[0].empty():
        append_bbcode("Usage: transform <data_id> [mode] [target_lines]\n")
        return
    
    var data_id = args[0]
    var mode = "expand"
    var target_lines = 22
    
    if args.size() >= 2:
        mode = args[1]
    
    if args.size() >= 3 and args[2].is_valid_integer():
        target_lines = args[2].to_int()
        # Ensure within valid range
        target_lines = clamp(target_lines, 12, 22)
    
    # Get data content
    var data_content = _get_data_content(data_id)
    
    # Transform data
    var result = light_data_system.transform_data(data_content, data_id, mode, target_lines)
    
    append_bbcode("[color=#AAFFAA]Transformation complete:[/color] " + result.transformation_id + "\n")
    append_bbcode("  Mode: " + mode + "\n")
    append_bbcode("  Lines: " + str(result.original_lines) + " → " + str(result.result_lines) + "\n")
    
    if result.light_patterns.size() > 0:
        append_bbcode("  Detected " + str(result.light_patterns.size()) + " light patterns\n")
    
    return result

# Get data content from various sources
func _get_data_content(data_id):
    var content = ""
    
    # Try to get from memory system
    if memory_system and memory_system.has_method("get_memory"):
        content = memory_system.get_memory(data_id)
    
    # Use sample content if empty
    if content.empty():
        content = _generate_sample_content(12)
    
    return content

# Generate sample content
func _generate_sample_content(line_count):
    var content = ""
    var sample_lines = [
        "The light reveals patterns hidden within the data sea.",
        "Transformation begins at the edges of perception.",
        "Each word carries its own luminescence, waiting to shine.",
        "Between the twelfth and twenty-second line lies evolution.",
        "Illuminated structures reveal deeper meaning and purpose.",
        "The journey from twelve to twenty-two changes perspective.",
        "Light flows through pathways, connecting disparate concepts.",
        "Dimensions expand when illuminated by understanding.",
        "Data transforms when seen through the lens of light.",
        "Reflections and refractions multiply meaning exponentially.",
        "The space between darkness and light holds potential.",
        "Words shimmer with possibility when properly illuminated.",
        "From simple to complex, the transformation unfolds.",
        "Radiance emanates from the junction of twelve and twenty-two.",
        "The cycle of expansion and contraction creates harmony.",
        "Duality emerges when structure meets illumination.",
        "Each transformation builds upon previous understanding.",
        "The story reveals itself through light and shadow.",
        "Clarity comes through the transformation process.",
        "Knowledge expands when illuminated by new perspective.",
        "The path from darkness to light is transformation.",
        "Expansion creates space for new understanding to emerge."
    ]
    
    # Select random lines
    for i in range(line_count):
        var line_idx = randi() % sample_lines.size()
        content += sample_lines[line_idx] + "\n"
    
    return content

# Visualize transformation
func visualize_data(args_text):
    if not light_visualizer:
        append_bbcode("[color=#FFAAAA]Error: Light Data Visualizer not available[/color]\n")
        return
    
    # Parse arguments
    var args = args_text.split(" ")
    
    if args.size() < 1 or args[0].empty():
        append_bbcode("Usage: visualize <transformation_id>\n")
        return
    
    var transformation_id = args[0]
    
    # Start visualization
    var success = light_visualizer.visualize_transformation(transformation_id)
    
    if success:
        append_bbcode("[color=#AAFFAA]Visualization started:[/color] " + transformation_id + "\n")
    else:
        append_bbcode("[color=#FFAAAA]Error: Failed to visualize transformation[/color]\n")

# Integrate with storytelling
func integrate_with_story(args_text):
    if not light_story_integrator:
        append_bbcode("[color=#FFAAAA]Error: Light Story Integrator not available[/color]\n")
        return
    
    # Parse arguments
    var args = args_text.split(" ")
    
    if args.size() < 1 or args[0].empty():
        append_bbcode("Usage: integrate <transformation_id> [story_type]\n")
        return
    
    var transformation_id = args[0]
    var story_type = "auto"
    
    if args.size() >= 2:
        story_type = args[1]
    
    # Integrate with story
    var result = light_story_integrator.integrate_transformation(transformation_id)
    
    if result:
        append_bbcode("[color=#AAFFAA]Story integration complete:[/color] " + result.title + "\n")
        append_bbcode("  Segments: " + str(result.segments) + "\n")
        append_bbcode("  Words: " + str(result.words) + " (" + str(int(result.light_percentage * 100)) + "% light)\n")
    else:
        append_bbcode("[color=#FFAAAA]Error: Failed to integrate with story[/color]\n")

# Show available transformation modes
func show_transformation_modes():
    if not light_data_system:
        append_bbcode("[color=#FFAAAA]Error: Light Data Transformer not available[/color]\n")
        return
    
    var modes = light_data_system.get_transformation_modes()
    append_bbcode("[color=#88CCFF]Available Transformation Modes:[/color]\n")
    
    for mode in modes:
        var description = ""
        match mode:
            "expand": description = "Increase line count with relevant content"
            "condense": description = "Reduce line count while preserving meaning"
            "illuminate": description = "Enhance text with light-related concepts"
            "refract": description = "Split concepts across multiple lines"
            "reflect": description = "Create mirrored/complementary expressions"
        
        append_bbcode("  [color=#AAFFAA]" + mode + "[/color] - " + description + "\n")

# Set light intensity
func set_light_intensity(args_text):
    if not light_data_system:
        append_bbcode("[color=#FFAAAA]Error: Light Data Transformer not available[/color]\n")
        return
    
    # Parse arguments
    var args = args_text.split(" ")
    
    if args.size() < 1 or args[0].empty():
        // Show current intensity
        var current_level = light_data_system.config.default_intensity
        var level_name = light_data_system.LIGHT_INTENSITY_LEVELS[current_level]
        append_bbcode("Current light intensity: [color=#AAFFAA]" + level_name + "[/color] (" + str(current_level) + ")\n")
        return
    
    // Set intensity level
    var intensity = args[0]
    var level = light_data_system.set_light_intensity(intensity)
    var level_name = light_data_system.LIGHT_INTENSITY_LEVELS[level]
    
    append_bbcode("Light intensity set to: [color=#AAFFAA]" + level_name + "[/color] (" + str(level) + ")\n")

# Show active light sources
func show_light_sources():
    if not light_data_system:
        append_bbcode("[color=#FFAAAA]Error: Light Data Transformer not available[/color]\n")
        return
    
    var sources = light_data_system.get_active_light_sources()
    
    if sources.size() == 0:
        append_bbcode("No active light sources\n")
        return
    
    append_bbcode("[color=#88CCFF]Active Light Sources:[/color] " + str(sources.size()) + "\n")
    
    for source in sources:
        var intensity_name = light_data_system.LIGHT_INTENSITY_LEVELS[source.intensity]
        var time_active = Time.get_unix_time_from_system() - source.creation_time
        
        append_bbcode("  [color=#AAFFAA]" + source.id + "[/color]\n")
        append_bbcode("    Intensity: " + intensity_name + "\n")
        append_bbcode("    Origin: " + source.origin + "\n")
        append_bbcode("    Active for: " + _format_time(time_active) + "\n")

# Show transformation history
func show_transformation_history():
    if not light_data_system:
        append_bbcode("[color=#FFAAAA]Error: Light Data Transformer not available[/color]\n")
        return
    
    var history = light_data_system.get_transformation_history(5)
    
    if history.size() == 0:
        append_bbcode("No transformation history\n")
        return
    
    append_bbcode("[color=#88CCFF]Recent Transformations:[/color]\n")
    
    for transformation in history:
        var time_str = _format_timestamp(transformation.timestamp)
        
        append_bbcode("  [color=#AAFFAA]" + transformation.id + "[/color]\n")
        append_bbcode("    Time: " + time_str + "\n")
        append_bbcode("    Mode: " + transformation.mode + "\n")
        append_bbcode("    Lines: " + str(transformation.original_lines) + " → " + str(transformation.result_lines) + "\n")
        
        if transformation.light_patterns.size() > 0:
            append_bbcode("    Patterns: " + str(transformation.light_patterns.size()) + "\n")

# Show story integration
func show_story_integration():
    if not light_story_integrator:
        append_bbcode("[color=#FFAAAA]Error: Light Story Integrator not available[/color]\n")
        return
    
    var integrations = light_story_integrator.get_active_integrations()
    
    if integrations.size() == 0:
        append_bbcode("No active story integrations\n")
        return
    
    append_bbcode("[color=#88CCFF]Story Integrations:[/color]\n")
    
    for story_id in integrations:
        var integration = integrations[story_id]
        
        append_bbcode("  [color=#AAFFAA]" + integration.title + "[/color] (" + story_id + ")\n")
        append_bbcode("    Status: " + integration.status + "\n")
        append_bbcode("    Segments: " + str(integration.segments_added) + "\n")
        
        if integration.total_words_count > 0:
            var light_percent = float(integration.light_words_count) / integration.total_words_count * 100
            append_bbcode("    Words: " + str(integration.total_words_count) + " (" + str(int(light_percent)) + "% light)\n")
        
        append_bbcode("    Transformation: " + integration.transformation_id + "\n")

# Helper: Format timestamp
func _format_timestamp(timestamp):
    var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
    return "%04d-%02d-%02d %02d:%02d:%02d" % [
        datetime.year,
        datetime.month,
        datetime.day,
        datetime.hour,
        datetime.minute,
        datetime.second
    ]

# Helper: Format time duration
func _format_time(seconds):
    var minutes = int(seconds / 60)
    var remain_seconds = int(seconds) % 60
    
    if minutes > 0:
        return str(minutes) + "m " + str(remain_seconds) + "s"
    else:
        return str(remain_seconds) + "s"

# Button event handlers
func _on_transform_button_pressed():
    var mode_option = get_node_or_null("../../SidePanel/VBoxContainer/ModeOptionButton")
    var target_lines = get_node_or_null("../../SidePanel/VBoxContainer/TargetLinesSpinBox")
    var intensity = get_node_or_null("../../SidePanel/VBoxContainer/IntensitySlider")
    
    if not light_data_system:
        append_bbcode("[color=#FFAAAA]Error: Light Data Transformer not available[/color]\n")
        return
    
    # Set up parameters
    var mode = "expand"
    if mode_option:
        mode = mode_option.get_item_text(mode_option.selected)
    
    var lines = 22
    if target_lines:
        lines = int(target_lines.value)
    
    var intensity_level = 2
    if intensity:
        intensity_level = int(intensity.value) - 1
        light_data_system.set_light_intensity(intensity_level)
    
    # Show input dialog
    var dialog = get_node_or_null("../../DataInputDialog")
    if dialog:
        dialog.show()
        
        # Connect transform button if needed
        var transform_button = get_node_or_null("../../DataInputDialog/VBoxContainer/HBoxContainer/TransformButton")
        if transform_button:
            if not transform_button.is_connected("pressed", Callable(self, "_on_dialog_transform_pressed")):
                transform_button.connect("pressed", Callable(self, "_on_dialog_transform_pressed"))

func _on_dialog_transform_pressed():
    var dialog = get_node_or_null("../../DataInputDialog")
    var text_edit = get_node_or_null("../../DataInputDialog/VBoxContainer/DataTextEdit")
    
    if not dialog or not text_edit:
        return
    
    # Get UI controls
    var mode_option = get_node_or_null("../../SidePanel/VBoxContainer/ModeOptionButton")
    var target_lines = get_node_or_null("../../SidePanel/VBoxContainer/TargetLinesSpinBox")
    
    # Get parameters
    var content = text_edit.text
    var mode = "expand"
    if mode_option:
        mode = mode_option.get_item_text(mode_option.selected)
    
    var lines = 22
    if target_lines:
        lines = int(target_lines.value)
    
    # Perform transformation
    if light_data_system:
        var result = light_data_system.transform_data(content, "user_input", mode, lines)
        
        append_bbcode("[color=#AAFFAA]Transformation complete:[/color] " + result.transformation_id + "\n")
        append_bbcode("  Mode: " + mode + "\n")
        append_bbcode("  Lines: " + str(result.original_lines) + " → " + str(result.result_lines) + "\n")
        
        if result.light_patterns.size() > 0:
            append_bbcode("  Detected " + str(result.light_patterns.size()) + " light patterns\n")
        
        # Update TransformationList
        var transform_list = get_node_or_null("../../SidePanel/VBoxContainer/TransformationList")
        if transform_list:
            transform_list.add_item(result.transformation_id)
    
    # Hide dialog
    dialog.hide()

func _on_visualize_button_pressed():
    var transform_list = get_node_or_null("../../SidePanel/VBoxContainer/TransformationList")
    
    if not transform_list or transform_list.get_selected_items().size() == 0:
        append_bbcode("[color=#FFAAAA]Error: Please select a transformation to visualize[/color]\n")
        return
    
    var selected_idx = transform_list.get_selected_items()[0]
    var transformation_id = transform_list.get_item_text(selected_idx)
    
    # Visualize the transformation
    if light_visualizer:
        var success = light_visualizer.visualize_transformation(transformation_id)
        
        if success:
            append_bbcode("[color=#AAFFAA]Visualization started:[/color] " + transformation_id + "\n")
        else:
            append_bbcode("[color=#FFAAAA]Error: Failed to visualize transformation[/color]\n")
    else:
        append_bbcode("[color=#FFAAAA]Error: Light Data Visualizer not available[/color]\n")

func _on_integrate_button_pressed():
    var transform_list = get_node_or_null("../../SidePanel/VBoxContainer/TransformationList")
    
    if not transform_list or transform_list.get_selected_items().size() == 0:
        append_bbcode("[color=#FFAAAA]Error: Please select a transformation to integrate[/color]\n")
        return
    
    var selected_idx = transform_list.get_selected_items()[0]
    var transformation_id = transform_list.get_item_text(selected_idx)
    
    # Integrate with story
    if light_story_integrator:
        var result = light_story_integrator.integrate_transformation(transformation_id)
        
        if result:
            append_bbcode("[color=#AAFFAA]Story integration complete:[/color] " + result.title + "\n")
            append_bbcode("  Segments: " + str(result.segments) + "\n")
            append_bbcode("  Words: " + str(result.words) + " (" + str(int(result.light_percentage * 100)) + "% light)\n")
        else:
            append_bbcode("[color=#FFAAAA]Error: Failed to integrate with story[/color]\n")
    else:
        append_bbcode("[color=#FFAAAA]Error: Light Story Integrator not available[/color]\n")