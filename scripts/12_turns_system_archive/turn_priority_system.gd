extends Node

class_name TurnPrioritySystem

# Constants
const TURNS_FILE_PATH = "/mnt/c/Users/Percision 15/12_turns_system/current_turn.txt"
const DISPLAY1_PATH = "/mnt/c/Users/Percision 15/12_turns_system/display1_turn.txt"
const DISPLAY2_PATH = "/mnt/c/Users/Percision 15/12_turns_system/display2_turn.txt"

# Turn tracking
var current_turn = [1, 1, 1, 1]  # Format: [major, minor, revision, cycle]
var turn_history = []
var turn_lines = ["", "", "", "", "", "", "", "", "", "", "", ""]  # 12 lines of text

# Priority lists
var priority_categories = {
    "creation": [],
    "implementation": [],
    "testing": [],
    "refinement": []
}

# Signals
signal turn_advanced(turn_number, turn_lines)
signal priority_shifted(old_category, new_category, item)
signal cycle_completed(cycle_number)

func _ready():
    # Load current turn state if exists
    load_turn_state()
    
    # Initialize default priorities if empty
    _initialize_default_priorities()
    
    # Save current state to display files
    save_display_files()
    
    print("Turn Priority System initialized")
    print("Current turn: " + get_turn_string())

func _initialize_default_priorities():
    # Only initialize if empty
    if priority_categories["creation"].size() == 0:
        priority_categories["creation"] = [
            "Concept design",
            "World building",
            "Character creation",
            "Story arcs",
            "Game mechanics"
        ]
    
    if priority_categories["implementation"].size() == 0:
        priority_categories["implementation"] = [
            "Core systems",
            "User interface",
            "Art integration",
            "Sound design",
            "Level design"
        ]
        
    if priority_categories["testing"].size() == 0:
        priority_categories["testing"] = [
            "Functionality tests",
            "Balance testing",
            "User experience",
            "Performance tests",
            "Bug fixing"
        ]
        
    if priority_categories["refinement"].size() == 0:
        priority_categories["refinement"] = [
            "Polish gameplay",
            "Enhance visuals",
            "Optimize code",
            "Refine controls",
            "Final integration"
        ]

func load_turn_state():
    var file = File.new()
    if file.file_exists(TURNS_FILE_PATH):
        file.open(TURNS_FILE_PATH, File.READ)
        
        # Read turn numbers
        var turn_line = file.get_line()
        var parts = turn_line.split(".")
        if parts.size() == 4:
            for i in range(4):
                current_turn[i] = int(parts[i])
        
        # Read turn lines
        for i in range(12):
            if file.eof_reached():
                break
            turn_lines[i] = file.get_line()
            
        file.close()
        print("Loaded turn state from: " + TURNS_FILE_PATH)
    else:
        # Initialize with default messages
        for i in range(12):
            turn_lines[i] = "Turn line " + str(i+1) + " initialized"
        save_turn_state()

func save_turn_state():
    var file = File.new()
    file.open(TURNS_FILE_PATH, File.WRITE)
    
    # Write turn counter
    file.store_line(get_turn_string())
    
    # Write turn lines
    for line in turn_lines:
        file.store_line(line)
        
    file.close()
    
    # Also save to display files
    save_display_files()
    
    print("Saved turn state to: " + TURNS_FILE_PATH)

func save_display_files():
    # Display 1 - Shows current turn and all 12 lines
    var file1 = File.new()
    file1.open(DISPLAY1_PATH, File.WRITE)
    file1.store_line("CURRENT TURN: " + get_turn_string())
    file1.store_line("----------------------------")
    
    for i in range(12):
        file1.store_line(str(i+1) + ". " + turn_lines[i])
    
    file1.close()
    
    # Display 2 - Shows current turn with active priorities
    var file2 = File.new()
    file2.open(DISPLAY2_PATH, File.WRITE)
    file2.store_line("TURN " + get_turn_string() + " - ACTIVE PRIORITIES")
    file2.store_line("===================================")
    
    # Determine active priorities based on current turn
    var category_index = (current_turn[1] - 1) % 4
    var category_name = priority_categories.keys()[category_index]
    
    file2.store_line("CATEGORY: " + category_name.to_upper())
    file2.store_line("-----------------------------------")
    
    for item in priority_categories[category_name]:
        file2.store_line("* " + item)
    
    file2.close()

func get_turn_string():
    return str(current_turn[0]) + "." + str(current_turn[1]) + "." + str(current_turn[2]) + "." + str(current_turn[3])

func advance_turn():
    # Store previous turn data
    turn_history.append({
        "turn": current_turn.duplicate(),
        "lines": turn_lines.duplicate()
    })
    
    # Advance the turn counter
    current_turn[3] += 1  # Advance cycle
    
    # Check for rollover
    if current_turn[3] > 12:
        current_turn[3] = 1
        current_turn[2] += 1  # Advance revision
        
        # Shift a priority from one category to the next
        _shift_priority()
        
        emit_signal("cycle_completed", current_turn[2])
    
    if current_turn[2] > 9:
        current_turn[2] = 1
        current_turn[1] += 1  # Advance minor version
    
    if current_turn[1] > 9:
        current_turn[1] = 1
        current_turn[0] += 1  # Advance major version
    
    # Update turn lines
    _update_turn_lines()
    
    # Save the new state
    save_turn_state()
    
    # Emit signal with turn information
    emit_signal("turn_advanced", get_turn_string(), turn_lines)
    
    print("Advanced to turn: " + get_turn_string())
    return get_turn_string()

func _update_turn_lines():
    # Shift lines up by one, dropping the oldest
    for i in range(11):
        turn_lines[i] = turn_lines[i+1]
    
    # Add a new line at the bottom - this is where new information goes
    var category_index = (current_turn[1] - 1) % 4
    var category_name = priority_categories.keys()[category_index]
    var priority_index = (current_turn[3] - 1) % priority_categories[category_name].size()
    
    turn_lines[11] = "Turn " + get_turn_string() + ": Working on " + \
                    priority_categories[category_name][priority_index] + \
                    " in " + category_name + " phase"

func _shift_priority():
    # Move a priority item from one category to the next
    var from_index = (current_turn[1] - 1) % 4
    var to_index = (from_index + 1) % 4
    
    var from_category = priority_categories.keys()[from_index]
    var to_category = priority_categories.keys()[to_index]
    
    # Only shift if there are items to shift
    if priority_categories[from_category].size() > 0:
        var item = priority_categories[from_category][0]
        priority_categories[from_category].remove(0)
        priority_categories[to_category].append(item)
        
        emit_signal("priority_shifted", from_category, to_category, item)
        print("Shifted priority '" + item + "' from " + from_category + " to " + to_category)

func add_priority(category, item):
    if priority_categories.has(category):
        priority_categories[category].append(item)
        save_turn_state()
        return true
    return false

func remove_priority(category, item):
    if priority_categories.has(category):
        var index = priority_categories[category].find(item)
        if index >= 0:
            priority_categories[category].remove(index)
            save_turn_state()
            return true
    return false

func set_current_turn(major, minor, revision, cycle):
    current_turn[0] = major
    current_turn[1] = minor
    current_turn[2] = revision
    current_turn[3] = cycle
    save_turn_state()
    
    print("Set turn to: " + get_turn_string())
    return get_turn_string()

func get_active_priorities():
    var category_index = (current_turn[1] - 1) % 4
    var category_name = priority_categories.keys()[category_index]
    
    return {
        "category": category_name,
        "items": priority_categories[category_name]
    }

func get_turn_data():
    return {
        "turn_string": get_turn_string(),
        "turn_counter": current_turn,
        "active_category": priority_categories.keys()[(current_turn[1] - 1) % 4],
        "active_priorities": get_active_priorities(),
        "turn_lines": turn_lines
    }