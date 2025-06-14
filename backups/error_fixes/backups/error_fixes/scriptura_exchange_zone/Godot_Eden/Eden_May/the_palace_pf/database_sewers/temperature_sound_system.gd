extends Node

# Temperature Sound System
# Manages audio feedback for temperature states, changes, and word transformations

# Audio players for different sound categories
var ambient_player: AudioStreamPlayer
var transition_player: AudioStreamPlayer
var word_transform_player: AudioStreamPlayer

# Reference to temperature system
var temperature_system
var temperature_word_effects

# Audio resources for different temperature states
var temperature_ambient_sounds = {
    "FROZEN": preload("res://sounds/temp_frozen_ambient.ogg"),
    "COLD": preload("res://sounds/temp_cold_ambient.ogg"),
    "NORMAL": preload("res://sounds/temp_normal_ambient.ogg"),
    "WARM": preload("res://sounds/temp_warm_ambient.ogg"),
    "HOT": preload("res://sounds/temp_hot_ambient.ogg"),
    "BOILING": preload("res://sounds/temp_boiling_ambient.ogg"),
    "PLASMA": preload("res://sounds/temp_plasma_ambient.ogg")
}

# Audio resources for temperature transitions
var temperature_transition_sounds = {
    "FROZEN_TO_COLD": preload("res://sounds/temp_frozen_to_cold.ogg"),
    "COLD_TO_NORMAL": preload("res://sounds/temp_cold_to_normal.ogg"),
    "NORMAL_TO_WARM": preload("res://sounds/temp_normal_to_warm.ogg"),
    "WARM_TO_HOT": preload("res://sounds/temp_warm_to_hot.ogg"),
    "HOT_TO_BOILING": preload("res://sounds/temp_hot_to_boiling.ogg"),
    "BOILING_TO_PLASMA": preload("res://sounds/temp_boiling_to_plasma.ogg"),
    
    "COLD_TO_FROZEN": preload("res://sounds/temp_cold_to_frozen.ogg"),
    "NORMAL_TO_COLD": preload("res://sounds/temp_normal_to_cold.ogg"),
    "WARM_TO_NORMAL": preload("res://sounds/temp_warm_to_normal.ogg"),
    "HOT_TO_WARM": preload("res://sounds/temp_hot_to_warm.ogg"),
    "BOILING_TO_HOT": preload("res://sounds/temp_boiling_to_hot.ogg"),
    "PLASMA_TO_BOILING": preload("res://sounds/temp_plasma_to_boiling.ogg")
}

# Audio resources for word transformations
var word_transformation_sounds = {
    "FREEZE": preload("res://sounds/word_freeze.ogg"),
    "MELT": preload("res://sounds/word_melt.ogg"),
    "EVAPORATE": preload("res://sounds/word_evaporate.ogg"),
    "CONDENSE": preload("res://sounds/word_condense.ogg"),
    "IONIZE": preload("res://sounds/word_ionize.ogg"),
    "DEIONIZE": preload("res://sounds/word_deionize.ogg")
}

# Current active ambient sound
var current_ambient_sound = "NORMAL"

# Volume settings
var ambient_volume = 0.3
var transition_volume = 0.5
var word_transform_volume = 0.7

# Master volume for all temperature sounds
var master_volume = 1.0

func _ready():
    # Create audio players
    ambient_player = AudioStreamPlayer.new()
    transition_player = AudioStreamPlayer.new()
    word_transform_player = AudioStreamPlayer.new()
    
    # Add to tree
    add_child(ambient_player)
    add_child(transition_player)
    add_child(word_transform_player)
    
    # Set up bus and volume
    ambient_player.bus = "Ambient"
    transition_player.bus = "SFX"
    word_transform_player.bus = "SFX"
    
    # Set initial volumes
    update_volumes()
    
    # Get system references
    temperature_system = get_node_or_null("/root/TemperatureSystem")
    temperature_word_effects = get_node_or_null("/root/TemperatureWordEffects")
    
    # Connect signals
    if temperature_system:
        temperature_system.connect("temperature_changed", self, "_on_temperature_changed")
        temperature_system.connect("temperature_state_changed", self, "_on_temperature_state_changed")
    
    if temperature_word_effects:
        temperature_word_effects.connect("word_transformed", self, "_on_word_transformed")
    
    # Start ambient sound for current temperature
    if temperature_system:
        var state = temperature_system.temperature_state_to_string(temperature_system.current_temperature_state)
        play_ambient_sound(state)

# Update volume settings for all players
func update_volumes():
    ambient_player.volume_db = linear2db(ambient_volume * master_volume)
    transition_player.volume_db = linear2db(transition_volume * master_volume)
    word_transform_player.volume_db = linear2db(word_transform_volume * master_volume)

# Play ambient sound for temperature state
func play_ambient_sound(state_name):
    # Skip if same ambient sound is already playing
    if state_name == current_ambient_sound and ambient_player.playing:
        return
    
    current_ambient_sound = state_name
    
    # Check if sound exists
    if not temperature_ambient_sounds.has(state_name):
        return
    
    # Fade out current sound if playing
    if ambient_player.playing:
        # Create tween for smooth transition
        var tween = Tween.new()
        add_child(tween)
        tween.interpolate_property(ambient_player, "volume_db", 
                ambient_player.volume_db, -80, 1.0, 
                Tween.TRANS_SINE, Tween.EASE_IN)
        tween.start()
        
        # Wait for fade out then change sound
        yield(tween, "tween_completed")
        ambient_player.stop()
        tween.queue_free()
    
    # Set new ambient sound
    ambient_player.stream = temperature_ambient_sounds[state_name]
    ambient_player.volume_db = -80  # Start silent for fade-in
    ambient_player.play()
    
    # Fade in new sound
    var tween = Tween.new()
    add_child(tween)
    tween.interpolate_property(ambient_player, "volume_db", 
            -80, linear2db(ambient_volume * master_volume), 1.0, 
            Tween.TRANS_SINE, Tween.EASE_OUT)
    tween.start()
    
    # Clean up tween when done
    yield(tween, "tween_completed")
    tween.queue_free()

# Play temperature transition sound
func play_transition_sound(from_state, to_state):
    var transition_key = from_state + "_TO_" + to_state
    
    # Check if transition sound exists
    if not temperature_transition_sounds.has(transition_key):
        return
    
    # Play transition sound
    transition_player.stream = temperature_transition_sounds[transition_key]
    transition_player.play()

# Play word transformation sound
func play_transformation_sound(transformation_type):
    var type_name = ""
    
    # Convert enum to string
    match transformation_type:
        temperature_word_effects.TransformationType.FREEZE:
            type_name = "FREEZE"
        temperature_word_effects.TransformationType.MELT:
            type_name = "MELT"
        temperature_word_effects.TransformationType.EVAPORATE:
            type_name = "EVAPORATE"
        temperature_word_effects.TransformationType.CONDENSE:
            type_name = "CONDENSE"
        temperature_word_effects.TransformationType.IONIZE:
            type_name = "IONIZE"
        temperature_word_effects.TransformationType.DEIONIZE:
            type_name = "DEIONIZE"
    
    # Check if transformation sound exists
    if type_name == "" or not word_transformation_sounds.has(type_name):
        return
    
    # Play transformation sound
    word_transform_player.stream = word_transformation_sounds[type_name]
    word_transform_player.play()

# Called when temperature changes
func _on_temperature_changed(new_temp, new_state):
    # No sound effect for temperature changes without state change
    # State changes are handled in _on_temperature_state_changed
    pass

# Called when temperature state changes
func _on_temperature_state_changed(old_state, new_state):
    # Convert states to strings
    var from_state = temperature_system.temperature_state_to_string(old_state)
    var to_state = temperature_system.temperature_state_to_string(new_state)
    
    # Play transition sound
    play_transition_sound(from_state, to_state)
    
    # Update ambient sound
    play_ambient_sound(to_state)

# Called when a word transforms
func _on_word_transformed(word_id, word_text, transformation_type, new_form):
    play_transformation_sound(transformation_type)

# Set master volume
func set_master_volume(volume):
    master_volume = clamp(volume, 0.0, 1.0)
    update_volumes()

# Set ambient volume
func set_ambient_volume(volume):
    ambient_volume = clamp(volume, 0.0, 1.0)
    update_volumes()

# Set transition volume
func set_transition_volume(volume):
    transition_volume = clamp(volume, 0.0, 1.0)
    update_volumes()

# Set word transform volume
func set_word_transform_volume(volume):
    word_transform_volume = clamp(volume, 0.0, 1.0)
    update_volumes()

# Console commands
func console_command(command, args):
    match command:
        "temp_sound", "temperature_sound":
            if args.size() > 0:
                match args[0]:
                    "volume":
                        if args.size() > 1:
                            set_master_volume(float(args[1]))
                            return "Temperature sound volume set to " + args[1]
                        return "Current temperature sound volume: " + str(master_volume)
                    
                    "ambient":
                        if args.size() > 1:
                            set_ambient_volume(float(args[1]))
                            return "Ambient sound volume set to " + args[1]
                        return "Current ambient sound volume: " + str(ambient_volume)
                    
                    "transition":
                        if args.size() > 1:
                            set_transition_volume(float(args[1]))
                            return "Transition sound volume set to " + args[1]
                        return "Current transition sound volume: " + str(transition_volume)
                    
                    "transform":
                        if args.size() > 1:
                            set_word_transform_volume(float(args[1]))
                            return "Word transformation sound volume set to " + args[1]
                        return "Current word transformation sound volume: " + str(word_transform_volume)
                    
                    "play":
                        if args.size() > 1:
                            match args[1]:
                                "ambient":
                                    if args.size() > 2:
                                        play_ambient_sound(args[2])
                                        return "Playing ambient sound for " + args[2] + " state"
                                
                                "transition":
                                    if args.size() > 3:
                                        play_transition_sound(args[2], args[3])
                                        return "Playing transition from " + args[2] + " to " + args[3]
                                
                                "transform":
                                    if args.size() > 2:
                                        # Map string to transformation type
                                        var type_map = {
                                            "freeze": temperature_word_effects.TransformationType.FREEZE,
                                            "melt": temperature_word_effects.TransformationType.MELT,
                                            "evaporate": temperature_word_effects.TransformationType.EVAPORATE,
                                            "condense": temperature_word_effects.TransformationType.CONDENSE,
                                            "ionize": temperature_word_effects.TransformationType.IONIZE,
                                            "deionize": temperature_word_effects.TransformationType.DEIONIZE
                                        }
                                        
                                        if type_map.has(args[2].to_lower()):
                                            play_transformation_sound(type_map[args[2].to_lower()])
                                            return "Playing transformation sound for " + args[2]
                                        
                                        return "Unknown transformation type: " + args[2]
                            
                            return "Usage: play <ambient|transition|transform> <params>"
                    
                    "stop":
                        if args.size() > 1:
                            match args[1]:
                                "ambient":
                                    ambient_player.stop()
                                    return "Ambient sound stopped"
                                "transition":
                                    transition_player.stop()
                                    return "Transition sound stopped"
                                "transform":
                                    word_transform_player.stop()
                                    return "Transformation sound stopped"
                                "all":
                                    ambient_player.stop()
                                    transition_player.stop()
                                    word_transform_player.stop()
                                    return "All temperature sounds stopped"
                        
                        return "Usage: stop <ambient|transition|transform|all>"
                    
                    "current":
                        return "Current temperature ambient: " + current_ambient_sound
            
            return "Available commands: volume, ambient, transition, transform, play, stop, current"