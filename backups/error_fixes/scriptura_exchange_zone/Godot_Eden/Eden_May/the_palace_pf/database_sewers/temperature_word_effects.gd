extends Node

# Temperature Word Effects System
# Handles how temperature affects word behavior and transformations

# References to systems
var temperature_system
var word_manifestation_system
var divine_word_processor

# Track word temperature states and effects
var word_temperature_states = {}
var word_transformations = {}

# Temperature transition thresholds for word transformations
const FREEZE_THRESHOLD = 0  # Words freeze below this
const MELT_THRESHOLD = 5    # Frozen words melt above this
const EVAPORATE_THRESHOLD = 100  # Words start to evaporate above this
const CONDENSE_THRESHOLD = 80  # Evaporated words condense below this
const PLASMA_THRESHOLD = 1000  # Words become plasma above this

# Word transformation types
enum TransformationType {
    FREEZE,        # Liquid to solid
    MELT,          # Solid to liquid
    EVAPORATE,     # Liquid to gas
    CONDENSE,      # Gas to liquid
    IONIZE,        # Matter to plasma
    DEIONIZE       # Plasma to matter
}

# Signals for word transformations
signal word_transformed(word_id, word_text, transformation_type, new_form)

func _ready():
    # Get references to required systems
    temperature_system = get_node("/root/TemperatureSystem")
    word_manifestation_system = get_node("/root/WordManifestationSystem")
    divine_word_processor = get_node("/root/DivineWordProcessor")
    
    # Connect to system signals
    temperature_system.connect("temperature_changed", self, "_on_temperature_changed")
    word_manifestation_system.connect("word_created", self, "_on_word_created")
    word_manifestation_system.connect("word_removed", self, "_on_word_removed")
    
    # Process initial words with current temperature
    process_existing_words()

# Process all existing words with current temperature
func process_existing_words():
    for word_id in word_manifestation_system.active_words:
        var word_node = word_manifestation_system.active_words[word_id]
        var word_text = word_manifestation_system.get_word_text(word_id)
        initialize_word_temperature(word_id, word_text)

# Initialize word temperature tracking
func initialize_word_temperature(word_id, word_text):
    # Default state is based on current temperature
    var temp_state = temperature_system.current_temperature_state
    
    # Track word temperature state
    word_temperature_states[word_id] = {
        "state": temp_state,
        "form": "normal",  # normal, frozen, gas, plasma
        "temperature": temperature_system.current_temperature,
        "text": word_text,
        "power": divine_word_processor.calculate_word_power(word_text)
    }
    
    # Apply initial effects
    apply_temperature_state_to_word(word_id)

# Apply current temperature effects to a word
func apply_temperature_state_to_word(word_id):
    if not word_temperature_states.has(word_id):
        return
    
    var word_data = word_temperature_states[word_id]
    var current_temp = temperature_system.current_temperature
    var word_node = word_manifestation_system.active_words[word_id]
    
    if not is_instance_valid(word_node):
        return
    
    # Check for state transitions based on temperature
    check_word_state_transitions(word_id, current_temp)
    
    # Apply physics changes based on temperature state
    apply_physics_changes(word_node, word_id)
    
    # Apply visual effects through the manifestation system
    word_manifestation_system.update_word_appearance(word_id)

# Check if a word should change state based on temperature
func check_word_state_transitions(word_id, current_temp):
    if not word_temperature_states.has(word_id):
        return
    
    var word_data = word_temperature_states[word_id]
    var old_form = word_data["form"]
    var new_form = old_form
    var transformation_type = null
    
    # Check for transformations based on current form and temperature
    match old_form:
        "normal":
            if current_temp <= FREEZE_THRESHOLD:
                new_form = "frozen"
                transformation_type = TransformationType.FREEZE
            elif current_temp >= EVAPORATE_THRESHOLD:
                new_form = "gas"
                transformation_type = TransformationType.EVAPORATE
            elif current_temp >= PLASMA_THRESHOLD:
                new_form = "plasma"
                transformation_type = TransformationType.IONIZE
        
        "frozen":
            if current_temp > MELT_THRESHOLD:
                new_form = "normal"
                transformation_type = TransformationType.MELT
        
        "gas":
            if current_temp < CONDENSE_THRESHOLD:
                new_form = "normal"
                transformation_type = TransformationType.CONDENSE
            elif current_temp >= PLASMA_THRESHOLD:
                new_form = "plasma"
                transformation_type = TransformationType.IONIZE
        
        "plasma":
            if current_temp < PLASMA_THRESHOLD:
                new_form = "gas"
                transformation_type = TransformationType.DEIONIZE
    
    # Update form if changed
    if new_form != old_form:
        word_data["form"] = new_form
        perform_word_transformation(word_id, transformation_type)
    
    # Update temperature
    word_data["temperature"] = current_temp
    
    # Set temperature state based on system state
    word_data["state"] = temperature_system.current_temperature_state

# Apply physics changes based on temperature state
func apply_physics_changes(word_node, word_id):
    if not word_temperature_states.has(word_id):
        return
    
    var word_data = word_temperature_states[word_id]
    var physics_body = word_node.get_node_or_null("PhysicsBody")
    
    if not physics_body:
        return
    
    # Apply physics properties based on form
    match word_data["form"]:
        "frozen":
            physics_body.gravity_scale = 1.5
            physics_body.mass = word_data["power"] * 1.5
            physics_body.linear_velocity = Vector3.ZERO
            physics_body.angular_velocity = Vector3.ZERO
            
        "normal":
            physics_body.gravity_scale = 1.0
            physics_body.mass = word_data["power"]
            
        "gas":
            physics_body.gravity_scale = -0.3 * (1.0 + word_data["power"] * 0.1)
            physics_body.mass = word_data["power"] * 0.5
            
            # Add random movement
            if randf() < 0.05:  # Occasional random movement
                var force = Vector3(
                    rand_range(-5, 5),
                    rand_range(0, 10),
                    rand_range(-5, 5)
                )
                physics_body.apply_impulse(Vector3.ZERO, force)
                
        "plasma":
            physics_body.gravity_scale = -0.8
            physics_body.mass = word_data["power"] * 0.2
            
            # Add erratic movement
            if randf() < 0.1:  # More frequent random movement
                var force = Vector3(
                    rand_range(-10, 10),
                    rand_range(-5, 15),
                    rand_range(-10, 10)
                )
                physics_body.apply_impulse(Vector3.ZERO, force)

# Perform a word transformation
func perform_word_transformation(word_id, transformation_type):
    if not word_temperature_states.has(word_id):
        return
    
    var word_data = word_temperature_states[word_id]
    var word_text = word_data["text"]
    var new_form = word_data["form"]
    
    # Record the transformation
    if not word_transformations.has(word_id):
        word_transformations[word_id] = []
    
    word_transformations[word_id].append({
        "from": get_previous_form(new_form, transformation_type),
        "to": new_form,
        "type": transformation_type,
        "temperature": temperature_system.current_temperature,
        "timestamp": OS.get_unix_time()
    })
    
    # Apply visual changes via manifestation system
    word_manifestation_system.transform_word(word_id, new_form)
    
    # Emit signal
    emit_signal("word_transformed", word_id, word_text, transformation_type, new_form)
    
    # Log the transformation
    print("Word '" + word_text + "' transformed: " + 
          get_transformation_description(transformation_type, word_text))

# Get the previous form based on the transformation type
func get_previous_form(new_form, transformation_type):
    match transformation_type:
        TransformationType.FREEZE:
            return "normal"
        TransformationType.MELT:
            return "frozen"
        TransformationType.EVAPORATE:
            return "normal"
        TransformationType.CONDENSE:
            return "gas"
        TransformationType.IONIZE:
            return "gas" if new_form == "plasma" else "normal"
        TransformationType.DEIONIZE:
            return "plasma"
    
    return "unknown"

# Get description of a transformation
func get_transformation_description(transformation_type, word_text):
    match transformation_type:
        TransformationType.FREEZE:
            return "'" + word_text + "' froze into a solid crystal form"
        TransformationType.MELT:
            return "'" + word_text + "' melted back to liquid form"
        TransformationType.EVAPORATE:
            return "'" + word_text + "' evaporated into gaseous form"
        TransformationType.CONDENSE:
            return "'" + word_text + "' condensed back to liquid form"
        TransformationType.IONIZE:
            return "'" + word_text + "' ionized into plasma state"
        TransformationType.DEIONIZE:
            return "'" + word_text + "' de-ionized from plasma back to gas"
    
    return "'" + word_text + "' underwent an unknown transformation"

# Called when temperature changes
func _on_temperature_changed(new_temp, new_state):
    # Update all words with new temperature
    for word_id in word_temperature_states.keys():
        if word_manifestation_system.active_words.has(word_id):
            apply_temperature_state_to_word(word_id)

# Called when a new word is created
func _on_word_created(word_node, word_id):
    var word_text = word_manifestation_system.get_word_text(word_id)
    initialize_word_temperature(word_id, word_text)

# Called when a word is removed
func _on_word_removed(word_id):
    if word_temperature_states.has(word_id):
        word_temperature_states.erase(word_id)

# Get transformation history for a word
func get_word_transformation_history(word_id):
    if word_transformations.has(word_id):
        return word_transformations[word_id]
    return []

# Get current form of a word
func get_word_form(word_id):
    if word_temperature_states.has(word_id):
        return word_temperature_states[word_id]["form"]
    return "unknown"

# Console commands
func console_command(command, args):
    match command:
        "temp_effect", "temperature_effect":
            if args.size() > 0:
                match args[0]:
                    "list":
                        var result = "Active word temperature states:\n"
                        for word_id in word_temperature_states:
                            if word_manifestation_system.active_words.has(word_id):
                                var data = word_temperature_states[word_id]
                                result += data["text"] + ": " + data["form"] + \
                                         " (" + str(data["temperature"]) + "°C)\n"
                        return result
                    
                    "history":
                        if args.size() > 1:
                            # Get history for specific word
                            var word_id = args[1]
                            if word_manifestation_system.active_words.has(word_id):
                                var history = get_word_transformation_history(word_id)
                                if history.size() > 0:
                                    var result = "Transformation history for word '" + \
                                                word_temperature_states[word_id]["text"] + "':\n"
                                    for transform in history:
                                        result += "- " + transform["from"] + " → " + \
                                                 transform["to"] + " at " + \
                                                 str(transform["temperature"]) + "°C\n"
                                    return result
                                return "No transformation history for this word."
                            return "Word not found."
                        else:
                            # List all recent transformations
                            var result = "Recent transformations:\n"
                            var count = 0
                            for word_id in word_transformations:
                                if word_manifestation_system.active_words.has(word_id):
                                    var word_text = word_temperature_states[word_id]["text"]
                                    var transformations = word_transformations[word_id]
                                    if transformations.size() > 0:
                                        var last = transformations[transformations.size() - 1]
                                        result += word_text + ": " + last["from"] + " → " + \
                                                 last["to"] + " at " + \
                                                 str(last["temperature"]) + "°C\n"
                                        count += 1
                                        if count >= 5:
                                            break
                            
                            if count == 0:
                                return "No recent transformations."
                            return result
                    
                    "transform":
                        if args.size() > 2:
                            var word_id = args[1]
                            var target_form = args[2]
                            
                            if word_manifestation_system.active_words.has(word_id):
                                var current_form = get_word_form(word_id)
                                var transformation_type = null
                                
                                # Determine transformation type
                                if current_form == "normal" and target_form == "frozen":
                                    transformation_type = TransformationType.FREEZE
                                elif current_form == "frozen" and target_form == "normal":
                                    transformation_type = TransformationType.MELT
                                elif current_form == "normal" and target_form == "gas":
                                    transformation_type = TransformationType.EVAPORATE
                                elif current_form == "gas" and target_form == "normal":
                                    transformation_type = TransformationType.CONDENSE
                                elif target_form == "plasma":
                                    transformation_type = TransformationType.IONIZE
                                elif current_form == "plasma" and target_form != "plasma":
                                    transformation_type = TransformationType.DEIONIZE
                                
                                if transformation_type != null:
                                    word_temperature_states[word_id]["form"] = target_form
                                    perform_word_transformation(word_id, transformation_type)
                                    return "Transformed word to " + target_form + " state."
                                
                                return "Invalid transformation: " + current_form + " → " + target_form
                            return "Word not found."
                        return "Usage: transform <word_id> <form>"
            
            return "Available commands: list, history [word_id], transform <word_id> <form>"