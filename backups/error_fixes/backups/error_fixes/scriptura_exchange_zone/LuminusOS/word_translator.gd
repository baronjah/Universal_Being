extends Node

signal translation_completed(input_text, translated_text, translation_type)
signal embodiment_detected(source_type, embodiment_level)

# Connection to word animator
var word_animator
var turn_tracker

# Translation modes
enum TranslationMode {
    BODY_TO_WORD,    # Physical gesture/input to linguistic meaning
    WORD_TO_VISUAL,  # Text to visual representation
    WORD_TO_SOUND,   # Text to audio pattern
    SYSTEM_TO_HUMAN, # System output to human-understandable format
    HUMAN_TO_SYSTEM, # Human input to system commands
    SIN_TO_CREATION  # Transform "forbidden" concepts into creative force
}

# Embodiment tracking
var embodiment_sources = {
    "keyboard": {
        "active": true,
        "typing_speed": 0.0,        # Words per minute
        "typing_rhythm": 0.0,       # Consistency measure 0-1
        "key_pressure": 0.5,        # Normalized 0-1
        "pause_frequency": 0.0,     # Pauses per minute
        "error_correction_rate": 0.0 # Corrections per minute
    },
    "mouse": {
        "active": true,
        "movement_speed": 0.0,      # Pixels per second
        "click_pressure": 0.5,      # Normalized 0-1
        "hover_patterns": [],       # Areas of focus
        "selection_tendency": 0.0   # Selection rate
    },
    "voice": {
        "active": false,
        "volume": 0.5,              # Normalized 0-1
        "pitch_variation": 0.0,     # Standard deviation
        "speech_rate": 0.0,         # Words per minute
        "pause_patterns": [],       # Pauses in speech
        "emotional_markers": {}     # Detected emotion levels
    },
    "gaze": {
        "active": false,
        "focus_duration": 0.0,      # Average focus time
        "scan_patterns": [],        # Areas of focus
        "blink_rate": 0.0,          # Blinks per minute
        "pupil_dilation": 0.5       # Normalized 0-1
    }
}

# Sin categorization and creative transmutation
var sin_transformation_map = {
    "pride": {
        "keywords": ["best", "greatest", "superior", "perfect", "elite"],
        "creative_force": "vision",
        "color": Color(0.8, 0.4, 0.0),  # Orange
        "animation": "expand"
    },
    "envy": {
        "keywords": ["jealous", "want", "deserve", "unfair", "theirs"],
        "creative_force": "aspiration",
        "color": Color(0.0, 0.8, 0.4),  # Green
        "animation": "orbit"
    },
    "wrath": {
        "keywords": ["angry", "hate", "destroy", "furious", "rage"],
        "creative_force": "passion",
        "color": Color(0.8, 0.0, 0.0),  # Red
        "animation": "vibrate"
    },
    "sloth": {
        "keywords": ["lazy", "tired", "boring", "later", "easy"],
        "creative_force": "efficiency",
        "color": Color(0.4, 0.4, 0.8),  # Light blue
        "animation": "drift"
    },
    "greed": {
        "keywords": ["more", "mine", "keep", "wealth", "rich"],
        "creative_force": "abundance",
        "color": Color(0.8, 0.8, 0.0),  # Yellow/gold
        "animation": "pulse"
    },
    "gluttony": {
        "keywords": ["consume", "devour", "excess", "indulge", "feast"],
        "creative_force": "appreciation",
        "color": Color(0.6, 0.0, 0.6),  # Purple
        "animation": "grow"
    },
    "lust": {
        "keywords": ["desire", "crave", "body", "pleasure", "flesh"],
        "creative_force": "connection",
        "color": Color(0.8, 0.0, 0.4),  # Pink
        "animation": "float"
    }
}

# Terminal command patterns
var terminal_commands = {
    "create": {
        "regex": "create\\s+(\\w+)",
        "handler": "_handle_create_command",
        "help": "Creates a new object (create [object_name])"
    },
    "connect": {
        "regex": "connect\\s+(\\w+)\\s+to\\s+(\\w+)",
        "handler": "_handle_connect_command",
        "help": "Connects two objects (connect [object1] to [object2])"
    },
    "transform": {
        "regex": "transform\\s+(\\w+)\\s+into\\s+(\\w+)",
        "handler": "_handle_transform_command",
        "help": "Transforms an object (transform [object] into [new_form])"
    },
    "visualize": {
        "regex": "visualize\\s+(.+)",
        "handler": "_handle_visualize_command",
        "help": "Creates visual representation (visualize [concept])"
    },
    "embody": {
        "regex": "embody\\s+(.+)\\s+as\\s+(.+)",
        "handler": "_handle_embody_command",
        "help": "Creates physical manifestation (embody [concept] as [form])"
    }
}

# Recent inputs tracking for rhythm detection
var recent_inputs = []
var last_input_time = 0

func _ready():
    # Connect to animator if available
    word_animator = get_node_or_null("/root/Main/WordAnimator")
    
    # Connect to turn tracker if available
    turn_tracker = get_node_or_null("/root/Main/TurnTracker")
    
    # Start input monitoring
    set_process_input(true)
    
    # Start timer for rhythm analysis
    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = 1.0
    timer.autostart = true
    timer.connect("timeout", self, "_analyze_input_patterns")

# Process all input to analyze embodiment
func _input(event):
    if event is InputEventKey and event.pressed:
        _process_keyboard_input(event)
    elif event is InputEventMouseButton and event.pressed:
        _process_mouse_input(event)
    elif event is InputEventMouseMotion:
        _update_mouse_movement(event)

# Process keyboard input
func _process_keyboard_input(event):
    # Track keystroke timing
    var current_time = OS.get_ticks_msec() / 1000.0
    
    # Add to recent inputs
    recent_inputs.append({
        "type": "keyboard",
        "key": event.scancode,
        "time": current_time,
        "pressure": 1.0 if event.echo else 0.5  # Simulated pressure
    })
    
    # Keep only recent history (10 seconds worth)
    while recent_inputs.size() > 0 and current_time - recent_inputs[0].time > 10.0:
        recent_inputs.pop_front()
    
    # Update last input time
    last_input_time = current_time
    
    # Detect key pressure patterns
    if event.scancode == KEY_SHIFT or event.scancode == KEY_CONTROL:
        embodiment_sources["keyboard"]["key_pressure"] = 0.8
    else:
        # Regular keys use default pressure
        embodiment_sources["keyboard"]["key_pressure"] = 0.5

# Process mouse input
func _process_mouse_input(event):
    # Track mouse click
    var current_time = OS.get_ticks_msec() / 1000.0
    
    # Add to recent inputs
    recent_inputs.append({
        "type": "mouse",
        "button": event.button_index,
        "position": Vector2(event.position.x, event.position.y),
        "time": current_time,
        "pressure": event.pressure if event.pressure > 0 else 0.5  # Use actual pressure or default
    })
    
    # Update click pressure
    embodiment_sources["mouse"]["click_pressure"] = event.pressure if event.pressure > 0 else 0.5

# Track mouse movement
func _update_mouse_movement(event):
    # Calculate mouse speed
    if event.speed.length() > 0:
        embodiment_sources["mouse"]["movement_speed"] = event.speed.length()
    
    # Add hover point if mouse is slow
    if event.speed.length() < 5.0:
        var hover_patterns = embodiment_sources["mouse"]["hover_patterns"]
        hover_patterns.append(Vector2(event.position.x, event.position.y))
        
        # Keep only recent hover points
        while hover_patterns.size() > 20:
            hover_patterns.pop_front()

# Periodic analysis of input patterns
func _analyze_input_patterns():
    # Analyze typing speed and rhythm
    var keyboard_inputs = recent_inputs.filter(func(input): return input.type == "keyboard")
    
    if keyboard_inputs.size() > 1:
        # Calculate typing speed (simulated)
        var first_input_time = keyboard_inputs.front().time
        var last_input_time = keyboard_inputs.back().time
        var time_span = last_input_time - first_input_time
        
        if time_span > 0:
            # Rough estimate of WPM based on 5 chars per word
            var wpm = (keyboard_inputs.size() / 5.0) / (time_span / 60.0)
            embodiment_sources["keyboard"]["typing_speed"] = wpm
            
            # Calculate rhythm consistency (lower variance = more consistent)
            var intervals = []
            for i in range(1, keyboard_inputs.size()):
                intervals.append(keyboard_inputs[i].time - keyboard_inputs[i-1].time)
            
            var avg_interval = 0.0
            for interval in intervals:
                avg_interval += interval
            
            if intervals.size() > 0:
                avg_interval /= intervals.size()
                
                var variance = 0.0
                for interval in intervals:
                    variance += pow(interval - avg_interval, 2)
                variance /= intervals.size()
                
                # Convert variance to a rhythm score (0-1, higher is more consistent)
                var rhythm_score = 1.0 - min(1.0, sqrt(variance) * 2.0)
                embodiment_sources["keyboard"]["typing_rhythm"] = rhythm_score
    
    # Emit embodiment signal if significant change detected
    emit_signal("embodiment_detected", "keyboard", embodiment_sources["keyboard"]["typing_rhythm"])
    emit_signal("embodiment_detected", "mouse", embodiment_sources["mouse"]["click_pressure"])

# Main translation function
func translate(input_text, translation_mode):
    var result = ""
    
    match translation_mode:
        TranslationMode.BODY_TO_WORD:
            result = translate_body_to_word(input_text)
        TranslationMode.WORD_TO_VISUAL:
            result = translate_word_to_visual(input_text)
        TranslationMode.WORD_TO_SOUND:
            result = translate_word_to_sound(input_text)
        TranslationMode.SYSTEM_TO_HUMAN:
            result = translate_system_to_human(input_text)
        TranslationMode.HUMAN_TO_SYSTEM:
            result = translate_human_to_system(input_text)
        TranslationMode.SIN_TO_CREATION:
            result = translate_sin_to_creation(input_text)
    
    # Emit the completion signal
    emit_signal("translation_completed", input_text, result, translation_mode)
    
    return result

# Translate body rhythm and input patterns to text enhancement
func translate_body_to_word(input_text):
    # Enhanced text based on embodiment factors
    var enhanced_text = input_text
    
    # Apply typing rhythm patterns
    var rhythm = embodiment_sources["keyboard"]["typing_rhythm"]
    
    if rhythm > 0.8:
        # Smooth, consistent typing - flow state
        enhanced_text = "✨ " + enhanced_text + " ✨"
    elif rhythm < 0.3:
        # Erratic typing - emotional or uncertain
        enhanced_text = "~ " + enhanced_text + " ~"
    
    # Apply pressure patterns
    var pressure = embodiment_sources["keyboard"]["key_pressure"]
    
    if pressure > 0.7:
        # Strong pressure - emphasis
        enhanced_text = enhanced_text.to_upper()
    elif pressure < 0.3:
        # Light pressure - gentleness
        enhanced_text = enhanced_text.to_lower()
    
    # Add turn context if available
    if turn_tracker:
        enhanced_text += " [Turn " + str(turn_tracker.current_turn) + "/" + str(turn_tracker.max_turns_per_phase) + "]"
    
    return enhanced_text

# Translate words to visual elements (using WordAnimator)
func translate_word_to_visual(input_text):
    # Parse input into individual words
    var words = input_text.split(" ", false)  # false means don't allow empty strings
    
    # Manifest each word if animator is available
    if word_animator:
        for word in words:
            word_animator.manifest_random_word(word)
        
        return "Manifested " + str(words.size()) + " words in visual space"
    else:
        return "WordAnimator not available"

# Translate words to sound patterns
func translate_word_to_sound(input_text):
    # This would connect to an audio system
    # For now, just return a description
    
    var word_count = input_text.split(" ", false).size()
    var letter_count = input_text.length()
    
    # Calculate simple sound parameters
    var base_pitch = 0.5 + (word_count / 20.0)  # 0.5-1.5 range
    var variability = letter_count / 100.0      # 0.0-1.0 range
    
    # Modulate based on vowel content
    var vowel_count = 0
    for c in input_text.to_lower():
        if "aeiou".find(c) >= 0:
            vowel_count += 1
    
    var vowel_ratio = float(vowel_count) / max(1, input_text.length())
    var brightness = 0.3 + (vowel_ratio * 0.7)  # 0.3-1.0 range
    
    return "Sound pattern generated: Pitch " + str(base_pitch) + ", Variability " + str(variability) + ", Brightness " + str(brightness)

# Translate system messages to human-friendly format
func translate_system_to_human(input_text):
    # Enhance system output with more natural language
    var output = input_text
    
    # Replace common system phrases
    output = output.replace("Error:", "I couldn't complete that because")
    output = output.replace("Warning:", "You might want to know that")
    output = output.replace("INFO:", "Just so you know,")
    output = output.replace("NULL", "nothing")
    output = output.replace("undefined", "something I'm not sure about")
    
    # Add emotional tone based on current turn phase
    if turn_tracker:
        match turn_tracker.current_phase:
            1, 2: # Early phases - more mechanical
                output = "System: " + output
            3, 4: # Middle phases - more personable
                output = "I think " + output
            5, 6, 7, 8: # Later phases - more natural
                output = output
            9, 10, 11, 12: # Final phases - more transcendent
                output = "✧ " + output + " ✧"
    
    return output

# Translate human input to system commands
func translate_human_to_system(input_text):
    # Check for terminal commands
    for cmd_name in terminal_commands:
        var command = terminal_commands[cmd_name]
        var regex = RegEx.new()
        regex.compile(command["regex"])
        var result = regex.search(input_text.to_lower())
        
        if result:
            # Command matched, call the handler
            if has_method(command["handler"]):
                return call(command["handler"], result)
    
    # No command matched, try to interpret intent
    if input_text.to_lower().begins_with("how"):
        return "HELP_REQUEST: " + input_text
    elif input_text.to_lower().begins_with("what"):
        return "QUERY: " + input_text
    elif input_text.to_lower().begins_with("why"):
        return "EXPLANATION_REQUEST: " + input_text
    elif input_text.to_lower().ends_with("?"):
        return "QUERY: " + input_text
    else:
        return "STATEMENT: " + input_text

# Transform "sinful" concepts into creative force
func translate_sin_to_creation(input_text):
    # Identify potential "sin" categories in the text
    var detected_sins = {}
    
    for sin_type in sin_transformation_map:
        var sin_data = sin_transformation_map[sin_type]
        var keywords = sin_data["keywords"]
        
        # Check for keywords
        var matched_count = 0
        for keyword in keywords:
            if input_text.to_lower().find(keyword) >= 0:
                matched_count += 1
        
        if matched_count > 0:
            var match_strength = float(matched_count) / keywords.size()
            detected_sins[sin_type] = match_strength
    
    # If no sins detected
    if detected_sins.empty():
        return input_text
    
    # Find the most prominent sin
    var max_strength = 0.0
    var dominant_sin = ""
    
    for sin_type in detected_sins:
        if detected_sins[sin_type] > max_strength:
            max_strength = detected_sins[sin_type]
            dominant_sin = sin_type
    
    # Transform the text based on the creative force
    var creative_force = sin_transformation_map[dominant_sin]["creative_force"]
    var transformed_text = "✧ [" + creative_force.capitalize() + "] " + input_text + " ✧"
    
    # Apply creative transformation to visual elements if animator is available
    if word_animator:
        # Manifest the creative force as a word
        var position = Vector3(0, 1, 0)
        var force_node = word_animator.manifest_word(creative_force, position)
        
        # Apply special effects
        var color = sin_transformation_map[dominant_sin]["color"]
        var animation = sin_transformation_map[dominant_sin]["animation"]
        
        # This would require custom methods on word_animator
        # For now, just return the transformed text
    
    return transformed_text

# Command handlers
func _handle_create_command(result):
    var object_name = result.get_string(1)
    
    # Create object if word animator is available
    if word_animator:
        word_animator.manifest_random_word(object_name)
        return "CREATE_SUCCESS: " + object_name
    else:
        return "CREATE_FAILURE: WordAnimator not available"

func _handle_connect_command(result):
    var object1 = result.get_string(1)
    var object2 = result.get_string(2)
    
    # For now, just return a success message
    return "CONNECT_REQUEST: " + object1 + " to " + object2

func _handle_transform_command(result):
    var object = result.get_string(1)
    var new_form = result.get_string(2)
    
    # For now, just return a success message
    return "TRANSFORM_REQUEST: " + object + " into " + new_form

func _handle_visualize_command(result):
    var concept = result.get_string(1)
    
    # Use word animator if available
    if word_animator:
        word_animator.manifest_random_word(concept)
        return "VISUALIZE_SUCCESS: " + concept
    else:
        return "VISUALIZE_FAILURE: WordAnimator not available"

func _handle_embody_command(result):
    var concept = result.get_string(1)
    var form = result.get_string(2)
    
    # For now, just return a success message
    return "EMBODY_REQUEST: " + concept + " as " + form

# Helper function to analyze word phonetics
func analyze_word_sound(word):
    var vowels = "aeiou"
    var plosives = "pbtdkg"
    var fricatives = "fvszh"
    var liquids = "lr"
    var nasals = "mn"
    
    var sound_profile = {
        "vowel_count": 0,
        "consonant_types": {
            "plosives": 0,
            "fricatives": 0,
            "liquids": 0,
            "nasals": 0,
            "other": 0
        },
        "syllable_estimate": 0,
        "length": word.length()
    }
    
    # Count letter types
    for letter in word.to_lower():
        if vowels.find(letter) >= 0:
            sound_profile["vowel_count"] += 1
        elif plosives.find(letter) >= 0:
            sound_profile["consonant_types"]["plosives"] += 1
        elif fricatives.find(letter) >= 0:
            sound_profile["consonant_types"]["fricatives"] += 1
        elif liquids.find(letter) >= 0:
            sound_profile["consonant_types"]["liquids"] += 1
        elif nasals.find(letter) >= 0:
            sound_profile["consonant_types"]["nasals"] += 1
        else:
            sound_profile["consonant_types"]["other"] += 1
    
    # Estimate syllables (very rough approximation)
    sound_profile["syllable_estimate"] = max(1, sound_profile["vowel_count"])
    
    return sound_profile

# Use translation to generate system commands
func process_user_input(input_text):
    # First apply embodiment influences
    var embodied_text = translate(input_text, TranslationMode.BODY_TO_WORD)
    
    # Then convert to system commands
    var system_command = translate(embodied_text, TranslationMode.HUMAN_TO_SYSTEM)
    
    # Finally check for "sinful" concepts and transform them
    if system_command.begins_with("STATEMENT:"):
        return translate(input_text, TranslationMode.SIN_TO_CREATION)
    
    return system_command

# Process system output for user display
func process_system_output(output_text):
    return translate(output_text, TranslationMode.SYSTEM_TO_HUMAN)