class_name AkashicNumberSystem
extends Node

# Core number limits
const NUMERIC_BOUNDARIES = {
    "BASE_LIMIT": 9,
    "EXPANDED_LIMIT": 99,
    "MULTIPLICATION_FACTOR": 33,
    "SYMBOL_COUNT": 7,
    "DIMENSIONAL_LIMIT": 5
}

# Symbol mapping for the SCRIPUTRA system
var SCRIPUTRA_SYMBOLS = {
    "#": {"value": 1, "function": "direct_connection", "dimensional_depth": 1},
    "##": {"value": 2, "function": "secondary_connection", "dimensional_depth": 2},
    "###": {"value": 3, "function": "tertiary_connection", "dimensional_depth": 3},
    "#_": {"value": 4, "function": "snake_connection", "dimensional_depth": 2},
    "_#": {"value": 5, "function": "reverse_connection", "dimensional_depth": 2},
    "#9": {"value": 9, "function": "limit_connection", "dimensional_depth": 4},
    "##9": {"value": 99, "function": "expanded_connection", "dimensional_depth": 5}
}

# Akashic Records structure
var AKASHIC_RECORDS = {
    "LAYERS": 9,
    "RECORDS_PER_LAYER": 99,
    "TOTAL_CAPACITY": 9 * 99, # 891
    "ACTIVE_RECORDS": []
}

# Text processing limits
var TEXT_PROCESSING = {
    "LINE_LIMIT": 9,
    "CHAR_LIMIT_PER_LINE": 99,
    "PRECISION_CUTTING": true,
    "FOLDING_ENABLED": true
}

# Schedule management for weekly tasks
var SCHEDULE_LOOP = {
    "DAYS_IN_CYCLE": 7,
    "PRIORITY_LEVELS": ["#", "##", "###"],
    "CURRENT_DAY": 0,
    "TASKS_PER_DAY": 9
}

# Lucky number patterns
var LUCKY_NUMBERS = {
    "888": {"meaning": "prosperity", "multiplier": 3},
    "1333": {"meaning": "transformation", "multiplier": 4}
}

# Constructor with initialization
func _init():
    initialize_akashic_records()
    set_current_day()

# Initialize the akashic records structure
func initialize_akashic_records():
    AKASHIC_RECORDS.ACTIVE_RECORDS = []
    for i in range(AKASHIC_RECORDS.LAYERS):
        var layer_records = []
        for j in range(AKASHIC_RECORDS.RECORDS_PER_LAYER):
            layer_records.append(null)
        AKASHIC_RECORDS.ACTIVE_RECORDS.append(layer_records)

# Set the current day based on system time
func set_current_day():
    var date = Time.get_date_dict_from_system()
    SCHEDULE_LOOP.CURRENT_DAY = date.weekday % SCHEDULE_LOOP.DAYS_IN_CYCLE

# Transform text to SNAKE_CASE format
func to_snake_case(text: String) -> String:
    text = text.to_lower()
    # Replace spaces and non-alphanumeric characters with underscores
    var regex = RegEx.new()
    regex.compile("\\s+|[^a-z0-9]")
    text = regex.sub(text, "_", true)
    # Remove consecutive underscores
    regex.compile("_+")
    text = regex.sub(text, "_", true)
    # Remove leading/trailing underscores
    text = text.strip_edges(true, true)
    if text.begins_with("_"):
        text = text.substr(1)
    if text.ends_with("_"):
        text = text.substr(0, text.length() - 1)
    return text

# Process text according to the LINE_LIMIT and other constraints
func process_text(text: String) -> String:
    var lines = text.split("\n")
    var processed_lines = []
    
    # Apply LINE_LIMIT
    var max_lines = min(lines.size(), TEXT_PROCESSING.LINE_LIMIT)
    
    for i in range(max_lines):
        var line = lines[i]
        # Apply character limit if needed
        if line.length() > TEXT_PROCESSING.CHAR_LIMIT_PER_LINE:
            line = line.substr(0, TEXT_PROCESSING.CHAR_LIMIT_PER_LINE)
        
        # Process line with precision cutting if enabled
        if TEXT_PROCESSING.PRECISION_CUTTING:
            line = apply_precision_cutting(line)
        
        processed_lines.append(line)
    
    return "\n".join(processed_lines)

# Apply precision cutting to maintain semantic integrity
func apply_precision_cutting(line: String) -> String:
    # Find the last complete word that fits within the character limit
    if line.length() <= TEXT_PROCESSING.CHAR_LIMIT_PER_LINE:
        return line
    
    var limit = TEXT_PROCESSING.CHAR_LIMIT_PER_LINE
    while limit > 0 and limit < line.length():
        if line[limit] == ' ':
            return line.substr(0, limit)
        limit -= 1
    
    # If no space found, just cut at the limit
    return line.substr(0, TEXT_PROCESSING.CHAR_LIMIT_PER_LINE)

# Store a record in the akashic structure
func store_record(layer: int, index: int, data) -> bool:
    if layer < 0 or layer >= AKASHIC_RECORDS.LAYERS:
        return false
    if index < 0 or index >= AKASHIC_RECORDS.RECORDS_PER_LAYER:
        return false
    
    AKASHIC_RECORDS.ACTIVE_RECORDS[layer][index] = data
    return true

# Retrieve a record from the akashic structure
func get_record(layer: int, index: int):
    if layer < 0 or layer >= AKASHIC_RECORDS.LAYERS:
        return null
    if index < 0 or index >= AKASHIC_RECORDS.RECORDS_PER_LAYER:
        return null
    
    return AKASHIC_RECORDS.ACTIVE_RECORDS[layer][index]

# Generate schedule for the next week
func generate_next_week_schedule(tasks: Dictionary) -> String:
    var schedule = "SCHEDULE FOR NEXT WEEK:\n"
    
    for day in range(SCHEDULE_LOOP.DAYS_IN_CYCLE):
        var day_name = get_day_name(day)
        schedule += "DAY " + str(day + 1) + " (" + day_name + "):\n"
        
        if tasks.has(day):
            var day_tasks = tasks[day]
            var count = 0
            for task in day_tasks:
                if count >= SCHEDULE_LOOP.TASKS_PER_DAY:
                    break
                
                var priority_level = min(task.get("priority", 0), SCHEDULE_LOOP.PRIORITY_LEVELS.size() - 1)
                var priority_symbol = SCHEDULE_LOOP.PRIORITY_LEVELS[priority_level]
                
                schedule += "  " + priority_symbol + " " + task.get("description", "Unknown task") + "\n"
                count += 1
        else:
            schedule += "  No tasks scheduled\n"
        
        schedule += "\n"
    
    return schedule

# Get day name from index
func get_day_name(day_index: int) -> String:
    var days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    return days[day_index % days.size()]

# Calculate symbolic value based on the SCRIPUTRA system
func calculate_symbolic_value(symbol: String) -> int:
    if SCRIPUTRA_SYMBOLS.has(symbol):
        return SCRIPUTRA_SYMBOLS[symbol].value
    return 0

# Get dimensional depth of a symbol
func get_dimensional_depth(symbol: String) -> int:
    if SCRIPUTRA_SYMBOLS.has(symbol):
        return SCRIPUTRA_SYMBOLS[symbol].dimensional_depth
    return 0

# Apply lucky number transformations
func apply_lucky_number(value: int) -> int:
    var value_str = str(value)
    
    # Check for 888 pattern
    if value_str.find("888") != -1:
        value *= LUCKY_NUMBERS["888"].multiplier
    
    # Check for 1333 pattern
    if value_str.find("1333") != -1:
        value *= LUCKY_NUMBERS["1333"].multiplier
    
    return value

# Calculate the "legged it" time based on turns of an hour
func calculate_legged_time(turns: int, minutes_per_turn: int = 2) -> Dictionary:
    var total_minutes = turns * minutes_per_turn
    var hours = total_minutes / 60
    var remaining_minutes = total_minutes % 60
    
    return {
        "turns": turns,
        "minutes": total_minutes,
        "hours": hours,
        "remaining_minutes": remaining_minutes,
        "formatted": "%d hours %d minutes (%d turns)" % [hours, remaining_minutes, turns]
    }

# Calculate the turns based on play time
func calculate_turns_from_time(hours: float) -> int:
    var minutes = hours * 60
    return int(minutes / 2) # Assuming 2 minutes per turn