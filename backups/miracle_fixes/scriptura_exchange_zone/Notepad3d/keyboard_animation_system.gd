extends Node

class_name KeyboardAnimationSystem

# Constants for keyboard properties
const KEY_STATES = {
    "IDLE": 0,
    "PRESSED": 1,
    "RELEASED": 2,
    "HELD": 3
}

const KEY_TYPES = {
    "STANDARD": {
        "color": Color(0.8, 0.8, 0.8, 1.0),
        "press_animation": "bounce",
        "press_sound": "click_soft"
    },
    "SPECIAL": {
        "color": Color(0.6, 0.8, 1.0, 1.0),
        "press_animation": "glow",
        "press_sound": "click_medium"
    },
    "MODIFIER": {
        "color": Color(0.8, 0.7, 0.2, 1.0),
        "press_animation": "expand",
        "press_sound": "click_heavy"
    },
    "FUNCTION": {
        "color": Color(0.9, 0.5, 0.5, 1.0),
        "press_animation": "flash",
        "press_sound": "beep"
    },
    "SPACE": {
        "color": Color(0.7, 0.9, 0.7, 1.0),
        "press_animation": "ripple",
        "press_sound": "sweep"
    },
    "ENTER": {
        "color": Color(0.5, 0.8, 0.5, 1.0),
        "press_animation": "expand_flash",
        "press_sound": "confirm"
    }
}

const GESTURE_TYPES = {
    "SWIPE_LEFT": {
        "color": Color(0.9, 0.4, 0.4, 1.0),
        "animation": "slide_left",
        "particles": "wind_left",
        "sound": "swoosh_left"
    },
    "SWIPE_RIGHT": {
        "color": Color(0.4, 0.9, 0.4, 1.0),
        "animation": "slide_right",
        "particles": "wind_right",
        "sound": "swoosh_right"
    },
    "SWIPE_UP": {
        "color": Color(0.4, 0.7, 0.9, 1.0),
        "animation": "float_up",
        "particles": "wind_up",
        "sound": "swoosh_up"
    },
    "SWIPE_DOWN": {
        "color": Color(0.9, 0.9, 0.4, 1.0),
        "animation": "drop_down",
        "particles": "wind_down",
        "sound": "swoosh_down"
    },
    "PINCH_IN": {
        "color": Color(0.9, 0.4, 0.9, 1.0),
        "animation": "shrink",
        "particles": "implode",
        "sound": "suck_in"
    },
    "PINCH_OUT": {
        "color": Color(0.4, 0.9, 0.9, 1.0),
        "animation": "expand",
        "particles": "explode",
        "sound": "puff_out"
    },
    "ROTATE_CW": {
        "color": Color(0.7, 0.7, 0.9, 1.0),
        "animation": "spin_cw",
        "particles": "spiral_cw",
        "sound": "spin_up"
    },
    "ROTATE_CCW": {
        "color": Color(0.9, 0.7, 0.7, 1.0),
        "animation": "spin_ccw",
        "particles": "spiral_ccw",
        "sound": "spin_down"
    }
}

const CHARACTER_STATES = {
    "IDLE": {
        "animation": "idle",
        "particle_rate": 0.0,
        "sound": ""
    },
    "TYPING": {
        "animation": "typing",
        "particle_rate": 0.2,
        "sound": "keyboard_ambient"
    },
    "THINKING": {
        "animation": "thinking",
        "particle_rate": 0.1,
        "sound": "hum"
    },
    "EXCITED": {
        "animation": "excited",
        "particle_rate": 0.8,
        "sound": "chime"
    },
    "CONFUSED": {
        "animation": "confused",
        "particle_rate": 0.3,
        "sound": "question"
    },
    "PROCESSING": {
        "animation": "processing",
        "particle_rate": 0.5,
        "sound": "computer"
    },
    "ERROR": {
        "animation": "error",
        "particle_rate": 0.9,
        "sound": "error"
    },
    "SUCCESS": {
        "animation": "success",
        "particle_rate": 0.7,
        "sound": "success"
    }
}

# Keyboard state
var keyboard_keys = {}
var active_keys = []
var recent_gestures = []
var current_character_state = "IDLE"
var text_buffer = ""
var character_mood = 0.5  # 0.0 = sad, 1.0 = happy
var character_energy = 0.5  # 0.0 = low, 1.0 = high
var animation_intensity = 1.0
var keyboard_position = Vector2(0.5, 0.8)  # Position in normalized screen space
var keyboard_scale = 1.0

# Material properties
var keyboard_color = Color(0.8, 0.8, 0.8, 1.0)
var keyboard_material = "GLOSSY"
var keyboard_reflectivity = 0.5
var keyboard_emission = 0.0

# Connected systems
var terminal_bridge = null
var color_spectrum = null
var character_system = null

# Visualization properties
var canvas = null
var animation_time = 0.0
var particle_systems = {}
var sound_players = {}

# Signals
signal key_pressed(key, state)
signal gesture_detected(gesture_type)
signal character_state_changed(state)
signal text_processed(text)

func _init():
    print("Initializing Keyboard Animation System...")
    
    # Initialize keyboard
    _initialize_keyboard()
    
    # Create visualization
    _setup_visualization()
    
    # Connect to other systems
    _connect_systems()
    
    # Initialize particle systems
    _initialize_particles()
    
    # Initialize sound players
    _initialize_sounds()
    
    print("Keyboard Animation System initialized")

func _initialize_keyboard():
    # Standard alphanumeric keys
    var alpha_keys = "abcdefghijklmnopqrstuvwxyz"
    var numeric_keys = "0123456789"
    
    # Create standard keys
    for key in alpha_keys:
        keyboard_keys[key] = {
            "type": "STANDARD",
            "state": KEY_STATES.IDLE,
            "time": 0.0,
            "position": Vector2(0, 0),  # Will be set during layout
            "size": Vector2(0.08, 0.08),
            "color": KEY_TYPES.STANDARD.color,
            "animation_progress": 0.0
        }
    
    for key in numeric_keys:
        keyboard_keys[key] = {
            "type": "STANDARD",
            "state": KEY_STATES.IDLE,
            "time": 0.0,
            "position": Vector2(0, 0),
            "size": Vector2(0.08, 0.08),
            "color": KEY_TYPES.STANDARD.color,
            "animation_progress": 0.0
        }
    
    # Special keys
    var special_keys = {
        "space": {
            "type": "SPACE",
            "size": Vector2(0.4, 0.08)
        },
        "enter": {
            "type": "ENTER",
            "size": Vector2(0.15, 0.08)
        },
        "shift": {
            "type": "MODIFIER",
            "size": Vector2(0.15, 0.08)
        },
        "ctrl": {
            "type": "MODIFIER",
            "size": Vector2(0.12, 0.08)
        },
        "alt": {
            "type": "MODIFIER",
            "size": Vector2(0.12, 0.08)
        },
        "tab": {
            "type": "SPECIAL",
            "size": Vector2(0.12, 0.08)
        },
        "backspace": {
            "type": "SPECIAL",
            "size": Vector2(0.15, 0.08)
        },
        "esc": {
            "type": "FUNCTION",
            "size": Vector2(0.08, 0.08)
        }
    }
    
    # Add special keys
    for key in special_keys:
        var key_data = special_keys[key]
        keyboard_keys[key] = {
            "type": key_data.type,
            "state": KEY_STATES.IDLE,
            "time": 0.0,
            "position": Vector2(0, 0),
            "size": key_data.size,
            "color": KEY_TYPES[key_data.type].color,
            "animation_progress": 0.0
        }
    
    # Function keys
    for i in range(1, 13):
        var key = "f" + str(i)
        keyboard_keys[key] = {
            "type": "FUNCTION",
            "state": KEY_STATES.IDLE,
            "time": 0.0,
            "position": Vector2(0, 0),
            "size": Vector2(0.08, 0.08),
            "color": KEY_TYPES.FUNCTION.color,
            "animation_progress": 0.0
        }
    
    # Special symbol keys
    var symbols = "`-=[]\\;',./~!@#$%^&*()_+{}|:\"<>?"
    for i in range(symbols.length()):
        var key = symbols[i]
        keyboard_keys[key] = {
            "type": "SPECIAL",
            "state": KEY_STATES.IDLE,
            "time": 0.0,
            "position": Vector2(0, 0),
            "size": Vector2(0.08, 0.08),
            "color": KEY_TYPES.SPECIAL.color,
            "animation_progress": 0.0
        }
    
    # Layout keys in QWERTY arrangement
    _layout_keyboard()

func _layout_keyboard():
    var rows = [
        "`1234567890-=",
        "qwertyuiop[]\\",
        "asdfghjkl;'",
        "zxcvbnm,./"
    ]
    
    var row_offsets = [0.0, 0.12, 0.18, 0.25]
    
    # Position each key in the standard layout
    for row_index in range(rows.size()):
        var row = rows[row_index]
        var offset_x = row_offsets[row_index]
        
        for key_index in range(row.length()):
            var key = row[key_index]
            if key in keyboard_keys:
                keyboard_keys[key].position = Vector2(
                    0.05 + offset_x + key_index * 0.09,
                    0.1 + row_index * 0.12
                )
            }
        }
    
    # Position special keys
    if "space" in keyboard_keys:
        keyboard_keys["space"].position = Vector2(0.35, 0.58)
    }
    
    if "enter" in keyboard_keys:
        keyboard_keys["enter"].position = Vector2(0.85, 0.35)
    }
    
    if "shift" in keyboard_keys:
        keyboard_keys["shift"].position = Vector2(0.1, 0.46)
    }
    
    if "ctrl" in keyboard_keys:
        keyboard_keys["ctrl"].position = Vector2(0.08, 0.58)
    }
    
    if "alt" in keyboard_keys:
        keyboard_keys["alt"].position = Vector2(0.22, 0.58)
    }
    
    if "tab" in keyboard_keys:
        keyboard_keys["tab"].position = Vector2(0.08, 0.23)
    }
    
    if "backspace" in keyboard_keys:
        keyboard_keys["backspace"].position = Vector2(0.85, 0.11)
    }
    
    if "esc" in keyboard_keys:
        keyboard_keys["esc"].position = Vector2(0.05, 0.0)
    }
    
    # Position function keys
    for i in range(1, 13):
        var key = "f" + str(i)
        if key in keyboard_keys:
            keyboard_keys[key].position = Vector2(
                0.05 + (i - 1) * 0.09,
                0.0
            )
        }
    }

func _setup_visualization():
    # Create visualization canvas
    canvas = Control.new()
    canvas.set_name("KeyboardAnimationCanvas")
    canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.connect("draw", Callable(self, "_draw_keyboard"))
    canvas.connect("gui_input", Callable(self, "_on_canvas_input"))

func _connect_systems():
    # Connect to TerminalVisualBridge
    if ClassDB.class_exists("TerminalVisualBridge"):
        terminal_bridge = load("res://terminal_visual_bridge.gd").new()
        print("Connected to TerminalVisualBridge")
    else:
        print("TerminalVisualBridge not available, trying to load directly")
        var script = load("/mnt/c/Users/Percision 15/terminal_visual_bridge.gd")
        if script:
            terminal_bridge = script.new()
            print("Loaded TerminalVisualBridge directly")
        else:
            print("TerminalVisualBridge not found, creating stub")
            terminal_bridge = Node.new()
            terminal_bridge.name = "TerminalBridgeStub"
    }
    
    # Connect to ExpandedColorSpectrum
    if ClassDB.class_exists("ExpandedColorSpectrum"):
        color_spectrum = load("res://expanded_color_spectrum.gd").new()
        print("Connected to ExpandedColorSpectrum")
    else:
        print("ExpandedColorSpectrum not available, trying to load directly")
        var script = load("/mnt/c/Users/Percision 15/expanded_color_spectrum.gd")
        if script:
            color_spectrum = script.new()
            print("Loaded ExpandedColorSpectrum directly")
        else:
            print("ExpandedColorSpectrum not found, creating stub")
            color_spectrum = Node.new()
            color_spectrum.name = "ColorSpectrumStub"
    }
    
    # Create or connect to CharacterSystem
    character_system = Node.new()
    character_system.name = "CharacterSystem"
    add_child(character_system)

func _initialize_particles():
    # Create particle systems for keyboard effects
    particle_systems = {
        "key_press": {
            "particles": [],
            "rate": 10.0,
            "lifetime": 1.0,
            "size": 3.0,
            "color": Color(1.0, 1.0, 1.0, 0.8)
        },
        "swipe": {
            "particles": [],
            "rate": 30.0,
            "lifetime": 1.5,
            "size": 5.0,
            "color": Color(0.8, 0.8, 1.0, 0.6)
        },
        "character": {
            "particles": [],
            "rate": 5.0,
            "lifetime": 2.0,
            "size": 8.0,
            "color": Color(1.0, 0.8, 0.4, 0.5)
        }
    }

func _initialize_sounds():
    # Create sound player stubs (would be actual sound players in a real implementation)
    sound_players = {
        "key_press": null,
        "gesture": null,
        "character": null,
        "ambient": null
    }

func _process(delta):
    # Update animation time
    animation_time += delta
    
    # Update key animations
    _update_key_animations(delta)
    
    # Update particle systems
    _update_particles(delta)
    
    # Update character state
    _update_character(delta)
    
    # Update gesture animations
    _update_gestures(delta)
    
    # Update visualization
    if canvas:
        canvas.queue_redraw()

func _update_key_animations(delta):
    # Update animation state for all keys
    for key in keyboard_keys:
        var key_data = keyboard_keys[key]
        
        match key_data.state:
            KEY_STATES.PRESSED:
                key_data.animation_progress = min(1.0, key_data.animation_progress + delta * 5.0)
                
                # Transition to HELD state after a short press animation
                if key_data.animation_progress >= 1.0:
                    key_data.state = KEY_STATES.HELD
                    key_data.animation_progress = 1.0
            
            KEY_STATES.RELEASED:
                key_data.animation_progress = max(0.0, key_data.animation_progress - delta * 5.0)
                
                # Transition back to IDLE when animation completes
                if key_data.animation_progress <= 0.0:
                    key_data.state = KEY_STATES.IDLE
                    key_data.animation_progress = 0.0
            
            KEY_STATES.HELD:
                # Subtle pulsing animation while held
                key_data.animation_progress = 0.8 + 0.2 * sin(animation_time * 3.0)
    }
    
    # Remove inactive keys from active list
    for i in range(active_keys.size() - 1, -1, -1):
        if keyboard_keys[active_keys[i]].state == KEY_STATES.IDLE:
            active_keys.remove_at(i)
        }
    }

func _update_particles(delta):
    # Update each particle system
    for system_name in particle_systems:
        var system = particle_systems[system_name]
        
        # Remove expired particles
        for i in range(system.particles.size() - 1, -1, -1):
            var particle = system.particles[i]
            particle.lifetime -= delta
            
            if particle.lifetime <= 0:
                system.particles.remove_at(i)
            }
        }
        
        # Add new particles based on system state
        match system_name:
            "key_press":
                if active_keys.size() > 0:
                    for key_name in active_keys:
                        var key_data = keyboard_keys[key_name]
                        
                        if key_data.state == KEY_STATES.PRESSED:
                            _emit_key_particles(key_name, key_data.position, key_data.color)
                        }
                    }
            
            "swipe":
                if recent_gestures.size() > 0:
                    for gesture in recent_gestures:
                        if gesture.time > 0:
                            _emit_swipe_particles(gesture.type, gesture.position, GESTURE_TYPES[gesture.type].color)
                        }
                    }
            
            "character":
                var state_data = CHARACTER_STATES[current_character_state]
                var emission_chance = state_data.particle_rate * delta * 30.0
                
                if randf() < emission_chance:
                    var position = Vector2(0.5, 0.3)  # Character position
                    var color = _get_character_color()
                    _emit_character_particles(position, color)
                }
    }

func _emit_key_particles(key_name, position, color):
    var system = particle_systems.key_press
    var particle_count = 3
    
    for i in range(particle_count):
        var particle = {
            "position": position + Vector2(randf_range(-0.03, 0.03), randf_range(-0.03, 0.03)),
            "velocity": Vector2(randf_range(-0.1, 0.1), randf_range(-0.2, -0.05)),
            "size": system.size * (0.7 + randf() * 0.6),
            "color": color.lightened(randf() * 0.3),
            "lifetime": system.lifetime * (0.7 + randf() * 0.6),
            "rotation": randf() * TAU
        }
        
        system.particles.append(particle)
    }

func _emit_swipe_particles(gesture_type, position, color):
    var system = particle_systems.swipe
    var particle_count = 10
    
    # Direction based on gesture type
    var direction = Vector2(0, 0)
    
    match gesture_type:
        "SWIPE_LEFT":
            direction = Vector2(-1, 0)
        "SWIPE_RIGHT":
            direction = Vector2(1, 0)
        "SWIPE_UP":
            direction = Vector2(0, -1)
        "SWIPE_DOWN":
            direction = Vector2(0, 1)
        "PINCH_IN":
            # Particles move toward center
            direction = Vector2(0, 0)  # Special case handled below
        "PINCH_OUT":
            # Particles move away from center
            direction = Vector2(0, 0)  # Special case handled below
        "ROTATE_CW":
            direction = Vector2(0, 0)  # Special case handled below
        "ROTATE_CCW":
            direction = Vector2(0, 0)  # Special case handled below
    
    for i in range(particle_count):
        var particle_pos = position + Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
        var velocity = Vector2(0, 0)
        
        match gesture_type:
            "PINCH_IN":
                var to_center = Vector2(0.5, 0.5) - particle_pos
                velocity = to_center.normalized() * 0.3
            "PINCH_OUT":
                var from_center = particle_pos - Vector2(0.5, 0.5)
                velocity = from_center.normalized() * 0.3
            "ROTATE_CW":
                var from_center = particle_pos - Vector2(0.5, 0.5)
                velocity = Vector2(-from_center.y, from_center.x).normalized() * 0.3
            "ROTATE_CCW":
                var from_center = particle_pos - Vector2(0.5, 0.5)
                velocity = Vector2(from_center.y, -from_center.x).normalized() * 0.3
            _:
                velocity = direction * (0.2 + randf() * 0.3)
        
        var particle = {
            "position": particle_pos,
            "velocity": velocity,
            "size": system.size * (0.7 + randf() * 0.6),
            "color": color.lightened(randf() * 0.3),
            "lifetime": system.lifetime * (0.7 + randf() * 0.6),
            "rotation": randf() * TAU
        }
        
        system.particles.append(particle)
    }

func _emit_character_particles(position, color):
    var system = particle_systems.character
    var particle_count = 5
    
    for i in range(particle_count):
        var angle = randf() * TAU
        var distance = randf() * 0.1
        var velocity = Vector2(cos(angle), sin(angle)) * (0.05 + randf() * 0.1)
        
        # Character emotion affects particle behavior
        if character_mood < 0.3:
            # Sad - particles drift downward
            velocity.y += 0.05
            color = color.darkened(0.3)
        } elif character_mood > 0.7:
            // Happy - particles drift upward
            velocity.y -= 0.05
            color = color.lightened(0.3)
        }
        
        // Character energy affects particle size and speed
        var energy_factor = 0.5 + character_energy
        
        var particle = {
            "position": position + Vector2(cos(angle), sin(angle)) * distance,
            "velocity": velocity * energy_factor,
            "size": system.size * (0.7 + randf() * 0.6) * energy_factor,
            "color": color,
            "lifetime": system.lifetime * (0.7 + randf() * 0.6),
            "rotation": randf() * TAU
        }
        
        system.particles.append(particle)
    }

func _update_character(delta):
    # Update character animation state based on keyboard activity
    var key_activity = active_keys.size() > 0
    var recent_text = text_buffer.length() > 0
    
    if key_activity and current_character_state != "TYPING":
        set_character_state("TYPING")
    } elif not key_activity and current_character_state == "TYPING":
        if recent_text:
            # Process the text buffer
            _process_text_buffer()
            set_character_state("PROCESSING")
        } else {
            set_character_state("IDLE")
        }
    }
    
    # If in processing state, occasionally switch to thinking
    if current_character_state == "PROCESSING" and randf() < delta * 0.5:
        set_character_state("THINKING")
    }
    
    # If in thinking state, occasionally switch back to processing
    if current_character_state == "THINKING" and randf() < delta * 0.3:
        set_character_state("PROCESSING")
    }
    
    # After some time in processing, show results
    if current_character_state == "PROCESSING" and animation_time % 5.0 < delta:
        if randf() < character_mood:
            set_character_state("SUCCESS")
        } else {
            set_character_state("ERROR")
        }
    }
    
    # Success and error states are temporary
    if (current_character_state == "SUCCESS" or current_character_state == "ERROR") and animation_time % 2.0 < delta:
        set_character_state("IDLE")
    }

func _update_gestures(delta):
    # Update active gestures
    for i in range(recent_gestures.size() - 1, -1, -1):
        var gesture = recent_gestures[i]
        gesture.time -= delta
        
        if gesture.time <= 0:
            recent_gestures.remove_at(i)
        }
    }

func _process_text_buffer():
    if text_buffer.length() > 0:
        emit_signal("text_processed", text_buffer)
        
        # Send to terminal bridge if available
        if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
            terminal_bridge.process_terminal_command("words", [text_buffer])
        }
        
        # Clear the buffer
        text_buffer = ""
    }

func _get_character_color():
    # Generate color based on character emotion and energy
    var h = lerp(0.6, 0.15, character_mood)  # Blue to yellow/orange
    var s = lerp(0.3, 0.9, character_energy)
    var v = lerp(0.7, 1.0, character_energy)
    
    return Color.from_hsv(h, s, v)

func _draw_keyboard():
    if not canvas:
        return
    
    var size = canvas.get_size()
    
    # Draw background
    var bg_color = Color(0.1, 0.1, 0.1, 0.9)
    canvas.draw_rect(Rect2(0, 0, size.x, size.y), bg_color)
    
    # Draw animated character
    _draw_character(size)
    
    # Draw keyboard
    _draw_keyboard_base(size)
    
    # Draw individual keys
    for key in keyboard_keys:
        _draw_key(key, keyboard_keys[key], size)
    }
    
    # Draw active particles
    _draw_particles(size)
    
    # Draw gesture trails
    _draw_gestures(size)
    
    # Draw character state indicator
    _draw_character_state(size)

func _draw_character(size):
    # Draw a simple character representation
    var character_center = Vector2(size.x * 0.5, size.y * 0.3)
    var character_size = min(size.x, size.y) * 0.15
    
    # Draw character body - color based on state
    var state_data = CHARACTER_STATES[current_character_state]
    var body_color = _get_character_color()
    
    # Draw body with animation
    var body_scale = 1.0 + 0.1 * sin(animation_time * 2.0)
    var rotation = 0.0
    
    match current_character_state:
        "IDLE":
            // Subtle breathing animation
            body_scale = 1.0 + 0.03 * sin(animation_time * 1.5)
        "TYPING":
            // Small rapid movements
            character_center.x += sin(animation_time * 15.0) * 3.0
            character_center.y += sin(animation_time * 10.0) * 2.0
        "THINKING":
            // Slight tilt back and forth
            rotation = sin(animation_time * 0.7) * 0.1
        "EXCITED":
            // Bouncing and scaling
            character_center.y += sin(animation_time * 8.0) * 10.0
            body_scale = 1.0 + 0.2 * sin(animation_time * 5.0)
        "CONFUSED":
            // Tilting and slight movement
            rotation = sin(animation_time * 1.3) * 0.3
            character_center.x += sin(animation_time * 2.0) * 5.0
        "PROCESSING":
            // Pulsing and slight vibration
            body_scale = 1.0 + 0.15 * sin(animation_time * 6.0)
            character_center.x += sin(animation_time * 20.0) * 2.0
        "ERROR":
            // Shake and flash red
            character_center.x += sin(animation_time * 25.0) * 8.0
            body_color = Color.lerp(body_color, Color(1,0,0), 0.5 + 0.5 * sin(animation_time * 15.0))
        "SUCCESS":
            // Grow and spin
            body_scale = 1.0 + 0.3 * sin(animation_time * 3.0)
            rotation = animation_time * 5.0
    
    # Apply rotation and scaling
    var transform = Transform2D().rotated(rotation).scaled(Vector2(body_scale, body_scale))
    
    # Draw character body
    var points = []
    var point_count = 8
    
    for i in range(point_count):
        var angle = i * TAU / point_count + animation_time * 0.2
        var radius = character_size * (0.8 + 0.2 * sin(angle * 3.0 + animation_time))
        var point = transform * Vector2(cos(angle), sin(angle)) * radius
        points.append(character_center + point)
    }
    
    // Draw filled shape
    for i in range(1, points.size() - 1):
        canvas.draw_polygon([
            points[0],
            points[i],
            points[i+1]
        ], [body_color])
    }
    
    // Draw outline
    for i in range(points.size()):
        var next_i = (i + 1) % points.size()
        canvas.draw_line(points[i], points[next_i], body_color.darkened(0.3), 2.0)
    }
    
    // Draw eyes
    var eye_offset = character_size * 0.2
    var eye_size = character_size * 0.15
    var left_eye = character_center + transform * Vector2(-eye_offset, -eye_offset * 0.7)
    var right_eye = character_center + transform * Vector2(eye_offset, -eye_offset * 0.7)
    
    canvas.draw_circle(left_eye, eye_size, Color(1,1,1))
    canvas.draw_circle(right_eye, eye_size, Color(1,1,1))
    
    // Draw pupils - follow "typing" direction
    var pupil_direction = Vector2(0, 1)
    if active_keys.size() > 0:
        var last_key = active_keys[active_keys.size() - 1]
        var key_pos = keyboard_keys[last_key].position
        pupil_direction = (Vector2(key_pos.x, key_pos.y) - Vector2(0.5, 0.3)).normalized()
    }
    
    var pupil_offset = eye_size * 0.5 * pupil_direction
    var pupil_size = eye_size * 0.5
    
    canvas.draw_circle(left_eye + pupil_offset, pupil_size, Color(0,0,0))
    canvas.draw_circle(right_eye + pupil_offset, pupil_size, Color(0,0,0))
    
    // Draw mouth
    var mouth_width = character_size * 0.3
    var mouth_height = character_size * 0.1 * (0.5 + 0.5 * character_mood)
    var mouth_y_offset = character_size * 0.3
    
    var mouth_rect = Rect2(
        character_center.x - mouth_width / 2,
        character_center.y + mouth_y_offset - mouth_height / 2,
        mouth_width,
        mouth_height
    )
    
    // Different mouth shapes based on state
    match current_character_state:
        "IDLE", "THINKING":
            // Simple line
            canvas.draw_line(
                Vector2(mouth_rect.position.x, mouth_rect.position.y + mouth_rect.size.y / 2),
                Vector2(mouth_rect.position.x + mouth_rect.size.x, mouth_rect.position.y + mouth_rect.size.y / 2),
                Color(0,0,0),
                2.0
            )
        "TYPING", "PROCESSING":
            // Small oval
            canvas.draw_rect(mouth_rect, Color(0,0,0))
        "EXCITED", "SUCCESS":
            // Happy curve
            var curve_points = []
            var curve_segments = 10
            
            for i in range(curve_segments + 1):
                var t = float(i) / float(curve_segments)
                var x = mouth_rect.position.x + t * mouth_rect.size.x
                var y = mouth_rect.position.y + mouth_rect.size.y * (1.0 - 4.0 * (t - 0.5) * (t - 0.5))
                curve_points.append(Vector2(x, y))
            }
            
            for i in range(curve_segments):
                canvas.draw_line(curve_points[i], curve_points[i+1], Color(0,0,0), 2.0)
        "CONFUSED", "ERROR":
            // Zigzag
            var zigzag_points = []
            var zigzag_segments = 6
            
            for i in range(zigzag_segments + 1):
                var t = float(i) / float(zigzag_segments)
                var x = mouth_rect.position.x + t * mouth_rect.size.x
                var y = mouth_rect.position.y + mouth_rect.size.y / 2 + sin(t * TAU * 1.5) * mouth_rect.size.y * 0.5
                zigzag_points.append(Vector2(x, y))
            }
            
            for i in range(zigzag_segments):
                canvas.draw_line(zigzag_points[i], zigzag_points[i+1], Color(0,0,0), 2.0)

func _draw_keyboard_base(size):
    var kb_width = size.x * 0.9
    var kb_height = size.y * 0.4
    var kb_x = size.x * keyboard_position.x - kb_width / 2
    var kb_y = size.y * keyboard_position.y - kb_height / 2
    
    # Draw keyboard background
    var kb_rect = Rect2(kb_x, kb_y, kb_width, kb_height)
    canvas.draw_rect(kb_rect, keyboard_color)
    
    # Apply material effects
    if keyboard_material == "GLOSSY" or keyboard_reflectivity > 0:
        var highlight_rect = Rect2(kb_x + kb_width * 0.1, kb_y + kb_height * 0.1, kb_width * 0.8, kb_height * 0.4)
        var highlight_color = Color(1, 1, 1, keyboard_reflectivity * 0.3)
        canvas.draw_rect(highlight_rect, highlight_color)
    }
    
    if keyboard_emission > 0:
        var glow_size = min(kb_width, kb_height) * 0.05
        var glow_color = keyboard_color.lightened(0.3)
        glow_color.a = keyboard_emission * 0.5
        
        canvas.draw_rect(Rect2(kb_x - glow_size, kb_y - glow_size, kb_width + glow_size * 2, kb_height + glow_size * 2), glow_color)
    }
    
    # Draw keyboard border
    canvas.draw_rect(kb_rect, keyboard_color.darkened(0.3), false, 2.0)

func _draw_key(key_name, key_data, size):
    var kb_width = size.x * 0.9
    var kb_height = size.y * 0.4
    var kb_x = size.x * keyboard_position.x - kb_width / 2
    var kb_y = size.y * keyboard_position.y - kb_height / 2
    
    var key_x = kb_x + key_data.position.x * kb_width
    var key_y = kb_y + key_data.position.y * kb_height
    var key_width = key_data.size.x * kb_width
    var key_height = key_data.size.y * kb_height
    
    # Calculate key animation effects
    var animation_progress = key_data.animation_progress
    var key_color = key_data.color
    var key_offset = 0.0
    var key_scale = 1.0
    
    match key_data.type:
        "STANDARD", "SPECIAL":
            # Simple press animation
            key_offset = animation_progress * 2.0
            key_scale = 1.0 - animation_progress * 0.1
        "MODIFIER":
            # Slight glow and larger press
            key_offset = animation_progress * 3.0
            key_scale = 1.0 - animation_progress * 0.15
            key_color = key_color.lightened(animation_progress * 0.2)
        "FUNCTION":
            # Flash animation
            key_offset = animation_progress * 2.0
            key_scale = 1.0 - animation_progress * 0.1
            key_color = key_color.lightened(animation_progress * 0.5)
        "SPACE":
            # Ripple animation
            key_offset = animation_progress * 1.0
            key_scale = 1.0 - animation_progress * 0.05
        "ENTER":
            # Expand and flash
            key_offset = animation_progress * 3.0
            key_scale = 1.0 + animation_progress * 0.1
            key_color = key_color.lightened(animation_progress * 0.3)
    
    # Apply scale and offset
    var scaled_width = key_width * key_scale
    var scaled_height = key_height * key_scale
    var offset_x = (key_width - scaled_width) / 2
    var offset_y = (key_height - scaled_height) / 2 + key_offset
    
    var key_rect = Rect2(
        key_x + offset_x,
        key_y + offset_y,
        scaled_width,
        scaled_height
    )
    
    # Draw key background
    canvas.draw_rect(key_rect, key_color)
    
    # Draw key border
    canvas.draw_rect(key_rect, key_color.darkened(0.3), false, 1.0)
    
    # Draw key label
    # We can't draw text directly in GDScript 4, so we'll draw a simple indicator
    var label_size = min(scaled_width, scaled_height) * 0.3
    var label_x = key_rect.position.x + key_rect.size.x / 2
    var label_y = key_rect.position.y + key_rect.size.y / 2
    
    var special_symbols = {
        "space": "_",
        "enter": "↵",
        "shift": "⇧",
        "ctrl": "^",
        "alt": "⎇",
        "tab": "⇥",
        "backspace": "←",
        "esc": "⎋"
    }
    
    var label = key_name
    if key_name in special_symbols:
        label = special_symbols[key_name]
    }
    
    # Draw a symbol representation (since we can't draw text directly)
    if label.length() == 1:
        // For single character keys, draw a small circle
        canvas.draw_circle(Vector2(label_x, label_y), label_size, Color(0,0,0,0.7))
    } else if key_name.begins_with("f") and key_name.length() <= 3:
        // For function keys, draw a small rectangle
        var func_rect = Rect2(label_x - label_size, label_y - label_size / 2, label_size * 2, label_size)
        canvas.draw_rect(func_rect, Color(0,0,0,0.7))
    } else {
        // For other special keys, draw different shapes
        match key_name:
            "space":
                var space_rect = Rect2(label_x - label_size * 2, label_y - label_size / 3, label_size * 4, label_size * 2/3)
                canvas.draw_rect(space_rect, Color(0,0,0,0.7))
            "enter":
                var points = [
                    Vector2(label_x + label_size, label_y - label_size),
                    Vector2(label_x + label_size, label_y + label_size),
                    Vector2(label_x - label_size, label_y)
                ]
                canvas.draw_polygon(points, [Color(0,0,0,0.7)])
            "shift", "ctrl", "alt":
                var tri_size = label_size * 1.2
                var points = [
                    Vector2(label_x, label_y - tri_size),
                    Vector2(label_x + tri_size, label_y + tri_size),
                    Vector2(label_x - tri_size, label_y + tri_size)
                ]
                canvas.draw_polygon(points, [Color(0,0,0,0.7)])
            _:
                canvas.draw_circle(Vector2(label_x, label_y), label_size, Color(0,0,0,0.7))
        }
    }

func _draw_particles(size):
    # Draw particles for each system
    for system_name in particle_systems:
        var system = particle_systems[system_name]
        
        for particle in system.particles:
            var position = Vector2(
                particle.position.x * size.x,
                particle.position.y * size.y
            )
            
            // Adjust color based on lifetime
            var color = particle.color
            color.a *= min(1.0, particle.lifetime * 2.0)
            
            // Draw particle
            match system_name:
                "key_press":
                    // Simple circle
                    canvas.draw_circle(position, particle.size, color)
                "swipe":
                    // Line with trail
                    var velocity = particle.velocity
                    var trail_length = velocity.length() * 20.0
                    var trail_end = position - velocity.normalized() * trail_length
                    
                    canvas.draw_line(position, trail_end, color, particle.size)
                    canvas.draw_circle(position, particle.size * 0.7, color.lightened(0.2))
                "character":
                    // Star shape
                    var points = []
                    var point_count = 5
                    var inner_radius = particle.size * 0.4
                    var outer_radius = particle.size
                    
                    for i in range(point_count * 2):
                        var angle = i * TAU / (point_count * 2) + particle.rotation
                        var radius = outer_radius if i % 2 == 0 else inner_radius
                        points.append(position + Vector2(cos(angle), sin(angle)) * radius)
                    }
                    
                    // Draw filled star
                    for i in range(1, points.size() - 1):
                        canvas.draw_polygon([
                            points[0],
                            points[i],
                            points[i+1]
                        ], [color])
                    }
            }
        }
    }

func _draw_gestures(size):
    # Draw recent gesture trails
    for gesture in recent_gestures:
        var gesture_data = GESTURE_TYPES[gesture.type]
        var gesture_color = gesture_data.color
        gesture_color.a = gesture.time / gesture.max_time
        
        match gesture.type:
            "SWIPE_LEFT", "SWIPE_RIGHT", "SWIPE_UP", "SWIPE_DOWN":
                var start_pos = Vector2(gesture.position.x * size.x, gesture.position.y * size.y)
                var end_pos = Vector2(0, 0)
                
                match gesture.type:
                    "SWIPE_LEFT":
                        end_pos = Vector2(start_pos.x - 100, start_pos.y)
                    "SWIPE_RIGHT":
                        end_pos = Vector2(start_pos.x + 100, start_pos.y)
                    "SWIPE_UP":
                        end_pos = Vector2(start_pos.x, start_pos.y - 100)
                    "SWIPE_DOWN":
                        end_pos = Vector2(start_pos.x, start_pos.y + 100)
                
                # Draw arrow line
                canvas.draw_line(start_pos, end_pos, gesture_color, 3.0)
                
                # Draw arrowhead
                var direction = (end_pos - start_pos).normalized()
                var arrow_size = 10.0
                var arrow_p1 = end_pos - direction.rotated(PI * 0.8) * arrow_size
                var arrow_p2 = end_pos - direction.rotated(-PI * 0.8) * arrow_size
                
                canvas.draw_line(end_pos, arrow_p1, gesture_color, 3.0)
                canvas.draw_line(end_pos, arrow_p2, gesture_color, 3.0)
            
            "PINCH_IN", "PINCH_OUT":
                var center_pos = Vector2(gesture.position.x * size.x, gesture.position.y * size.y)
                var circle_count = 3
                
                for i in range(circle_count):
                    var t = float(i) / float(circle_count - 1)
                    var progress = gesture.time / gesture.max_time
                    
                    if gesture.type == "PINCH_IN":
                        var radius = 50.0 * (1.0 - progress) * (1.0 - t)
                        canvas.draw_circle(center_pos, radius, Color(0,0,0,0))
                        canvas.draw_circle(center_pos, radius, gesture_color, false, 2.0)
                    } else {
                        var radius = 50.0 * progress * (t + 0.2)
                        canvas.draw_circle(center_pos, radius, Color(0,0,0,0))
                        canvas.draw_circle(center_pos, radius, gesture_color, false, 2.0)
                    }
                }
            
            "ROTATE_CW", "ROTATE_CCW":
                var center_pos = Vector2(gesture.position.x * size.x, gesture.position.y * size.y)
                var segment_count = 12
                var radius = 40.0
                
                for i in range(segment_count):
                    var start_angle = i * TAU / segment_count
                    var end_angle = (i + 0.7) * TAU / segment_count
                    
                    if gesture.type == "ROTATE_CCW":
                        var temp = start_angle
                        start_angle = end_angle
                        end_angle = temp
                    }
                    
                    var rotation_offset = gesture.time / gesture.max_time * TAU
                    
                    if gesture.type == "ROTATE_CW":
                        start_angle += rotation_offset
                        end_angle += rotation_offset
                    } else {
                        start_angle -= rotation_offset
                        end_angle -= rotation_offset
                    }
                    
                    var start_pos = center_pos + Vector2(cos(start_angle), sin(start_angle)) * radius
                    var end_pos = center_pos + Vector2(cos(end_angle), sin(end_angle)) * radius
                    
                    canvas.draw_line(start_pos, end_pos, gesture_color, 2.0)
                }
        }
    }

func _draw_character_state(size):
    var state_data = CHARACTER_STATES[current_character_state]
    var state_color
    
    match current_character_state:
        "IDLE":
            state_color = Color(0.8, 0.8, 0.8, 1.0)
        "TYPING":
            state_color = Color(0.4, 0.8, 1.0, 1.0)
        "THINKING":
            state_color = Color(0.8, 0.7, 0.2, 1.0)
        "EXCITED":
            state_color = Color(1.0, 0.7, 0.3, 1.0)
        "CONFUSED":
            state_color = Color(0.7, 0.3, 0.7, 1.0)
        "PROCESSING":
            state_color = Color(0.3, 0.7, 0.7, 1.0)
        "ERROR":
            state_color = Color(1.0, 0.3, 0.3, 1.0)
        "SUCCESS":
            state_color = Color(0.3, 1.0, 0.3, 1.0)
        _:
            state_color = Color(0.5, 0.5, 0.5, 1.0)
    
    # Draw state indicator
    var indicator_rect = Rect2(size.x * 0.05, size.y * 0.05, size.x * 0.2, size.y * 0.05)
    canvas.draw_rect(indicator_rect, Color(0.1, 0.1, 0.1, 0.8))
    
    var fill_width = indicator_rect.size.x * (float(current_character_state.length()) / 10.0)
    var fill_rect = Rect2(indicator_rect.position, Vector2(fill_width, indicator_rect.size.y))
    canvas.draw_rect(fill_rect, state_color)

func _on_canvas_input(event):
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            # Detect click on keyboard keys
            var size = canvas.get_size()
            var kb_width = size.x * 0.9
            var kb_height = size.y * 0.4
            var kb_x = size.x * keyboard_position.x - kb_width / 2
            var kb_y = size.y * keyboard_position.y - kb_height / 2
            
            var mouse_pos = event.position
            var normalized_pos = Vector2(
                (mouse_pos.x - kb_x) / kb_width,
                (mouse_pos.y - kb_y) / kb_height
            )
            
            # Check if click is within keyboard bounds
            if normalized_pos.x >= 0 and normalized_pos.x <= 1 and normalized_pos.y >= 0 and normalized_pos.y <= 1:
                # Find closest key
                var closest_key = null
                var closest_distance = 1.0e10
                
                for key in keyboard_keys:
                    var key_data = keyboard_keys[key]
                    var key_pos = key_data.position
                    var key_size = key_data.size
                    
                    # Check if mouse is within key bounds
                    if normalized_pos.x >= key_pos.x - key_size.x/2 and normalized_pos.x <= key_pos.x + key_size.x/2 and normalized_pos.y >= key_pos.y - key_size.y/2 and normalized_pos.y <= key_pos.y + key_size.y/2:
                        var distance = (Vector2(key_pos.x, key_pos.y) - normalized_pos).length()
                        
                        if distance < closest_distance:
                            closest_distance = distance
                            closest_key = key
                        }
                    }
                }
                
                if closest_key:
                    press_key(closest_key)
                }
            }
        } elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            # Release all active keys when mouse button is released
            for key in active_keys.duplicate():
                release_key(key)
            }
        }
    } elif event is InputEventMouseMotion:
        # Detect gestures
        if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
            var motion = event.relative
            var gesture_detected = false
            
            # Detect swipe gestures - require minimum movement
            if motion.length() > 30:
                var gesture_type = "NONE"
                var angle = atan2(motion.y, motion.x)
                
                # Determine swipe direction
                if abs(angle) < PI * 0.25:
                    gesture_type = "SWIPE_RIGHT"
                } elif abs(angle - PI) < PI * 0.25 or abs(angle + PI) < PI * 0.25:
                    gesture_type = "SWIPE_LEFT"
                } elif abs(angle - PI * 0.5) < PI * 0.25:
                    gesture_type = "SWIPE_DOWN"
                } elif abs(angle + PI * 0.5) < PI * 0.25:
                    gesture_type = "SWIPE_UP"
                }
                
                if gesture_type != "NONE":
                    add_gesture(gesture_type, Vector2(event.position.x / canvas.get_size().x, event.position.y / canvas.get_size().y))
                    gesture_detected = true
                }
            }
            
            # If no swipe detected, check for rotation
            if not gesture_detected and event.relative.length() > 10:
                var size = canvas.get_size()
                var center = Vector2(size.x * 0.5, size.y * 0.5)
                var from_center = event.position - center
                var angle_change = from_center.angle_to(from_center - event.relative)
                
                if abs(angle_change) > 0.2:  // Minimum rotation threshold
                    var gesture_type = angle_change > 0 ? "ROTATE_CW" : "ROTATE_CCW"
                    add_gesture(gesture_type, Vector2(0.5, 0.5))  // Always centered
                }
            }
        }
    }
    
    # Keyboard handling would go here in a real implementation

func press_key(key):
    if not key in keyboard_keys:
        return false
    
    var key_data = keyboard_keys[key]
    
    # Only press if not already active
    if key_data.state == KEY_STATES.IDLE or key_data.state == KEY_STATES.RELEASED:
        key_data.state = KEY_STATES.PRESSED
        key_data.time = OS.get_ticks_msec()
        key_data.animation_progress = 0.0
        
        # Add to active keys if not already present
        if not key in active_keys:
            active_keys.append(key)
        }
        
        # Process key press
        _process_key_press(key)
        
        # Emit signal
        emit_signal("key_pressed", key, KEY_STATES.PRESSED)
        
        return true
    }
    
    return false

func release_key(key):
    if not key in keyboard_keys:
        return false
    
    var key_data = keyboard_keys[key]
    
    # Only release if currently pressed or held
    if key_data.state == KEY_STATES.PRESSED or key_data.state == KEY_STATES.HELD:
        key_data.state = KEY_STATES.RELEASED
        key_data.time = OS.get_ticks_msec()
        
        # Process key release
        _process_key_release(key)
        
        # Emit signal
        emit_signal("key_pressed", key, KEY_STATES.RELEASED)
        
        return true
    }
    
    return false

func add_gesture(gesture_type, position):
    if not gesture_type in GESTURE_TYPES:
        return false
    
    var gesture = {
        "type": gesture_type,
        "position": position,
        "time": 2.0,  # Duration in seconds
        "max_time": 2.0
    }
    
    recent_gestures.append(gesture)
    
    # Process gesture
    _process_gesture(gesture_type)
    
    # Emit signal
    emit_signal("gesture_detected", gesture_type)
    
    return true

func set_character_state(state):
    if not state in CHARACTER_STATES:
        return false
    
    if state != current_character_state:
        var old_state = current_character_state
        current_character_state = state
        
        # Emit signal
        emit_signal("character_state_changed", state)
        
        # Process state change
        _process_character_state_change(old_state, state)
        
        return true
    }
    
    return false

func _process_key_press(key):
    # Handle key-specific behavior
    match key:
        "space":
            text_buffer += " "
        "enter":
            # Process current text buffer
            _process_text_buffer()
        "backspace":
            # Remove last character from buffer
            if text_buffer.length() > 0:
                text_buffer = text_buffer.substr(0, text_buffer.length() - 1)
            }
        "shift", "ctrl", "alt":
            # Modifier keys don't add to text buffer
            pass
        _:
            # Add key to text buffer
            text_buffer += key
    }
    
    # Send key press to terminal bridge
    if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
        terminal_bridge.process_terminal_command("energy", ["0", key])
    }

func _process_key_release(key):
    # No special processing needed for key release
    pass

func _process_gesture(gesture_type):
    # Handle gesture-specific effects
    match gesture_type:
        "SWIPE_LEFT":
            # Send to terminal bridge
            if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
                terminal_bridge.process_terminal_command("temp", ["down"])
            }
        "SWIPE_RIGHT":
            # Send to terminal bridge
            if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
                terminal_bridge.process_terminal_command("temp", ["up"])
            }
        "SWIPE_UP":
            # Increase character mood
            character_mood = min(1.0, character_mood + 0.2)
        "SWIPE_DOWN":
            # Decrease character mood
            character_mood = max(0.0, character_mood - 0.2)
        "PINCH_IN":
            # Decrease animation intensity
            animation_intensity = max(0.5, animation_intensity - 0.2)
        "PINCH_OUT":
            # Increase animation intensity
            animation_intensity = min(2.0, animation_intensity + 0.2)
        "ROTATE_CW":
            # Increase character energy
            character_energy = min(1.0, character_energy + 0.2)
        "ROTATE_CCW":
            # Decrease character energy
            character_energy = max(0.0, character_energy - 0.2)
    }

func _process_character_state_change(old_state, new_state):
    # Update character animation parameters based on state change
    match new_state:
        "EXCITED":
            character_mood = min(1.0, character_mood + 0.3)
            character_energy = min(1.0, character_energy + 0.3)
        "CONFUSED":
            character_mood = max(0.0, character_mood - 0.2)
        "ERROR":
            character_mood = max(0.0, character_mood - 0.3)
            character_energy = min(1.0, character_energy + 0.3)
        "SUCCESS":
            character_mood = min(1.0, character_mood + 0.4)
            character_energy = min(1.0, character_energy + 0.2)
    }
    
    # Send state change to terminal bridge
    if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
        var state_data = CHARACTER_STATES[new_state]
        
        // Temperature based on state
        var temp_name = "NEUTRAL"
        
        match new_state:
            "IDLE":
                temp_name = "COOL"
            "TYPING":
                temp_name = "NEUTRAL"
            "THINKING":
                temp_name = "VERY_COLD"
            "EXCITED":
                temp_name = "HOT"
            "CONFUSED":
                temp_name = "COLD"
            "PROCESSING":
                temp_name = "WARM"
            "ERROR":
                temp_name = "VERY_HOT"
            "SUCCESS":
                temp_name = "HOT"
        
        terminal_bridge.process_terminal_command("temp", [temp_name])
    }

# Public API for external systems

func get_keyboard_keys():
    return keyboard_keys

func get_active_keys():
    return active_keys

func get_text_buffer():
    return text_buffer

func set_keyboard_material(material_name):
    keyboard_material = material_name
    
    match material_name:
        "MATTE":
            keyboard_reflectivity = 0.0
            keyboard_emission = 0.0
        "GLOSSY":
            keyboard_reflectivity = 0.7
            keyboard_emission = 0.0
        "METALLIC":
            keyboard_reflectivity = 0.8
            keyboard_emission = 0.0
        "EMISSIVE":
            keyboard_reflectivity = 0.2
            keyboard_emission = 0.7
    
    return true

func set_keyboard_color(color):
    keyboard_color = color
    return true

func get_visualization_canvas():
    return canvas

func process_command(command, args):
    match command:
        "press":
            if args.size() > 0:
                return press_key(args[0])
            else:
                return "Key not provided"
        
        "release":
            if args.size() > 0:
                return release_key(args[0])
            else:
                return "Key not provided"
        
        "gesture":
            if args.size() >= 2:
                var gesture_type = args[0]
                var position = Vector2(0.5, 0.5)
                
                if args.size() >= 4:
                    position = Vector2(float(args[1]), float(args[2]))
                }
                
                return add_gesture(gesture_type, position)
            } else {
                return "Insufficient arguments for gesture"
            }
        
        "state":
            if args.size() > 0:
                return set_character_state(args[0])
            else:
                return "State not provided"
        
        "mood":
            if args.size() > 0:
                character_mood = clamp(float(args[0]), 0.0, 1.0)
                return character_mood
            } else {
                return character_mood
            }
        
        "energy":
            if args.size() > 0:
                character_energy = clamp(float(args[0]), 0.0, 1.0)
                return character_energy
            } else {
                return character_energy
            }
        
        "material":
            if args.size() > 0:
                return set_keyboard_material(args[0])
            } else {
                return keyboard_material
            }
        
        "color":
            if args.size() >= 3:
                var r = float(args[0])
                var g = float(args[1])
                var b = float(args[2])
                var a = 1.0
                
                if args.size() >= 4:
                    a = float(args[3])
                }
                
                return set_keyboard_color(Color(r, g, b, a))
            } else {
                return keyboard_color
            }
        
        "text":
            if args.size() > 0:
                text_buffer = args[0]
                return text_buffer
            } else {
                return text_buffer
            }
        
        "process":
            _process_text_buffer()
            return "Text processed"
        
        _:
            return "Unknown keyboard command: " + command