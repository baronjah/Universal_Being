extends Node

class_name TurnController

# ----- TURN CONTROLLER -----
# Manages the 12-turn cycle for the Akashic Notepad3D game
# Each turn corresponds to a different dimension with unique properties

# ----- CONSTANTS -----
const TURN_COUNT = 12
const DIMENSION_NAMES = ["1D", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "11D", "12D"]
const DIMENSION_SYMBOLS = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ"]

# ----- DIMENSION PROPERTIES -----
# Properties that affect gameplay mechanics in each dimension
const DIMENSION_PROPERTIES = [
    # 1D - Alpha
    {
        "linearity": 1.0,       # Everything happens in sequence
        "word_power": 0.5,      # Words have reduced power
        "evolution_speed": 0.3, # Slow evolution
        "stability": 0.9,       # Very stable
        "color": Color(0.9, 0.2, 0.2),  # Red
        "description": "The linear dimension. All entities exist in sequence, one after another."
    },
    # 2D - Beta
    {
        "linearity": 0.7,
        "word_power": 0.7,
        "evolution_speed": 0.5,
        "stability": 0.8,
        "color": Color(0.9, 0.5, 0.2),  # Orange
        "description": "The planar dimension. Entities exist on a flat surface with width and height."
    },
    # 3D - Gamma
    {
        "linearity": 0.5,
        "word_power": 1.0,      # Normal power
        "evolution_speed": 1.0, # Normal evolution
        "stability": 0.7,
        "color": Color(0.9, 0.9, 0.2),  # Yellow
        "description": "The spatial dimension. Entities exist in physical space with width, height, and depth."
    },
    # 4D - Delta
    {
        "linearity": 0.4,
        "word_power": 1.2,
        "evolution_speed": 1.2,
        "stability": 0.6,
        "color": Color(0.5, 0.9, 0.2),  # Yellow-green
        "description": "The temporal dimension. Entities exist across time and perceive past, present, and future."
    },
    # 5D - Epsilon
    {
        "linearity": 0.3,
        "word_power": 1.5,
        "evolution_speed": 1.5,
        "stability": 0.5,
        "color": Color(0.2, 0.9, 0.2),  # Green
        "description": "The probability dimension. Entities exist in multiple possible states simultaneously."
    },
    # 6D - Zeta
    {
        "linearity": 0.2,
        "word_power": 1.7,
        "evolution_speed": 1.7,
        "stability": 0.4,
        "color": Color(0.2, 0.9, 0.5),  # Teal
        "description": "The conceptual dimension. Entities exist as pure concepts and ideas."
    },
    # 7D - Eta
    {
        "linearity": 0.1,
        "word_power": 2.0,
        "evolution_speed": 2.0,
        "stability": 0.3,
        "color": Color(0.2, 0.9, 0.9),  # Cyan
        "description": "The consciousness dimension. Entities are aware of their existence across all dimensions."
    },
    # 8D - Theta
    {
        "linearity": 0.05,
        "word_power": 2.5,
        "evolution_speed": 2.5,
        "stability": 0.2,
        "color": Color(0.2, 0.5, 0.9),  # Blue
        "description": "The harmony dimension. Entities resonate with all other entities across realities."
    },
    # 9D - Iota
    {
        "linearity": 0.0,
        "word_power": 3.0,
        "evolution_speed": 3.0,
        "stability": 0.1,
        "color": Color(0.5, 0.2, 0.9),  # Purple
        "description": "The possibility dimension. All possible futures and pasts exist simultaneously."
    },
    # 10D - Kappa
    {
        "linearity": 0.0,
        "word_power": 3.5,
        "evolution_speed": 2.0,
        "stability": 0.2,
        "color": Color(0.9, 0.2, 0.9),  # Magenta
        "description": "The intention dimension. Reality is shaped directly by thought and intention."
    },
    # 11D - Lambda
    {
        "linearity": 0.1,
        "word_power": 4.0,
        "evolution_speed": 1.0,
        "stability": 0.4,
        "color": Color(0.9, 0.2, 0.5),  # Pink
        "description": "The manifestation dimension. Thoughts become form instantly."
    },
    # 12D - Mu
    {
        "linearity": 0.5,
        "word_power": 5.0,
        "evolution_speed": 0.5,
        "stability": 0.9,
        "color": Color(0.9, 0.2, 0.2),  # Red (cycle completion)
        "description": "The integration dimension. All dimensions merge into a unified reality."
    }
]

# ----- TURN STATE -----
var current_turn = 2  # Start at turn 3 (index 2)
var turn_progress = 0.0  # 0.0 to 1.0
var turn_duration = 60.0  # Seconds per turn
var auto_advance = false

# ----- SIGNALS -----
signal turn_changed(turn_number, dimension_symbol, dimension_properties)
signal turn_progressed(turn_number, progress)
signal auto_advance_toggled(enabled)

# ----- INITIALIZATION -----
func _ready():
    print("Turn Controller initializing...")
    
    # Emit initial turn signal
    emit_signal("turn_changed", current_turn, DIMENSION_SYMBOLS[current_turn], DIMENSION_PROPERTIES[current_turn])

# ----- PROCESS -----
func _process(delta):
    if auto_advance:
        turn_progress += delta / turn_duration
        
        if turn_progress >= 1.0:
            # Advance to next turn
            advance_turn()
            turn_progress = 0.0
        
        # Emit progress signal
        emit_signal("turn_progressed", current_turn, turn_progress)

# ----- TURN MANAGEMENT -----
func advance_turn():
    # Move to next turn
    current_turn = (current_turn + 1) % TURN_COUNT
    
    # Emit turn changed signal
    emit_signal("turn_changed", current_turn, DIMENSION_SYMBOLS[current_turn], DIMENSION_PROPERTIES[current_turn])
    
    print("Advanced to turn %d: Dimension %s (%s)" % [
        current_turn + 1,
        DIMENSION_NAMES[current_turn],
        DIMENSION_SYMBOLS[current_turn]
    ])
    
    return current_turn

func set_turn(turn_index):
    # Validate turn index
    if turn_index < 0 or turn_index >= TURN_COUNT:
        print("Invalid turn index: %d" % turn_index)
        return false
    
    # Set turn index
    current_turn = turn_index
    turn_progress = 0.0
    
    # Emit turn changed signal
    emit_signal("turn_changed", current_turn, DIMENSION_SYMBOLS[current_turn], DIMENSION_PROPERTIES[current_turn])
    
    print("Set turn to %d: Dimension %s (%s)" % [
        current_turn + 1,
        DIMENSION_NAMES[current_turn],
        DIMENSION_SYMBOLS[current_turn]
    ])
    
    return true

func toggle_auto_advance():
    auto_advance = !auto_advance
    emit_signal("auto_advance_toggled", auto_advance)
    
    print("Auto advance %s" % ("enabled" if auto_advance else "disabled"))
    
    return auto_advance

func set_turn_duration(seconds):
    if seconds > 0:
        turn_duration = seconds
        print("Turn duration set to %.1f seconds" % turn_duration)
        return true
    else:
        print("Invalid turn duration: %.1f" % seconds)
        return false

# ----- PUBLIC API -----
func get_current_turn_info():
    return {
        "turn_index": current_turn,
        "turn_number": current_turn + 1,
        "dimension_name": DIMENSION_NAMES[current_turn],
        "dimension_symbol": DIMENSION_SYMBOLS[current_turn],
        "properties": DIMENSION_PROPERTIES[current_turn],
        "progress": turn_progress
    }

func get_dimension_properties(dimension_index):
    if dimension_index >= 0 and dimension_index < DIMENSION_PROPERTIES.size():
        return DIMENSION_PROPERTIES[dimension_index]
    return null

# ----- CONSOLE INTERFACE -----
func process_command(command, args):
    match command:
        "next":
            advance_turn()
            return "Advanced to Turn %d: %s (%s)" % [
                current_turn + 1,
                DIMENSION_NAMES[current_turn],
                DIMENSION_SYMBOLS[current_turn]
            ]
        
        "set":
            if args.size() > 0 and args[0].is_valid_integer():
                var turn = int(args[0]) - 1  # Convert from 1-based to 0-based
                if set_turn(turn):
                    return "Set turn to %d: %s (%s)" % [
                        current_turn + 1,
                        DIMENSION_NAMES[current_turn],
                        DIMENSION_SYMBOLS[current_turn]
                    ]
                else:
                    return "Invalid turn number. Use 1-%d." % TURN_COUNT
            else:
                return "Usage: turn set <number>"
        
        "auto":
            if args.size() > 0:
                match args[0]:
                    "on":
                        auto_advance = true
                        emit_signal("auto_advance_toggled", auto_advance)
                        return "Auto advance enabled"
                    "off":
                        auto_advance = false
                        emit_signal("auto_advance_toggled", auto_advance)
                        return "Auto advance disabled"
                    "toggle":
                        toggle_auto_advance()
                        return "Auto advance %s" % ("enabled" if auto_advance else "disabled")
                    _:
                        return "Usage: turn auto [on|off|toggle]"
            else:
                toggle_auto_advance()
                return "Auto advance %s" % ("enabled" if auto_advance else "disabled")
        
        "duration":
            if args.size() > 0 and args[0].is_valid_float():
                var duration = float(args[0])
                if set_turn_duration(duration):
                    return "Turn duration set to %.1f seconds" % turn_duration
                else:
                    return "Invalid turn duration"
            else:
                return "Usage: turn duration <seconds>"
        
        "info":
            var info = get_current_turn_info()
            var props = info.properties
            
            return "Turn %d: %s (%s)\n" % [info.turn_number, info.dimension_name, info.dimension_symbol] + \
                   "Progress: %.1f%%\n" % (info.progress * 100) + \
                   "Properties:\n" + \
                   "- Linearity: %.1f\n" % props.linearity + \
                   "- Word Power: %.1f\n" % props.word_power + \
                   "- Evolution Speed: %.1f\n" % props.evolution_speed + \
                   "- Stability: %.1f\n" % props.stability + \
                   "Description: %s" % props.description
        
        _:
            return "Unknown turn command: %s\nAvailable commands: next, set, auto, duration, info" % command