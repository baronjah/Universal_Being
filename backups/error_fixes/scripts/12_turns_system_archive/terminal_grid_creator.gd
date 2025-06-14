extends Node

# Terminal Grid Creator
# Creates game elements (dungeons, ships, bases) using ASCII symbols
# Handles pattern detection and supports special effects

class_name TerminalGridCreator

# ----- GRID PROPERTIES -----
@export var grid_width: int = 80
@export var grid_height: int = 24
@export var cell_size: Vector2 = Vector2(16, 16)
@export var default_symbol: String = "."

# ----- SPECIAL SYMBOL PATTERNS -----
const SPECIAL_PATTERNS = {
    "#$%$#@@": "miracle_portal",
    "####": "solid_wall",
    "~~~~": "water_area",
    "^^^^": "lava_pit",
    "...+...": "door_corridor",
    "@@@": "entity_spawn",
    "$$$": "treasure_room",
    "###\n#+#\n###": "enclosed_room",
    "[@]": "player_start",
    "<->": "teleporter",
    "/*\\": "time_rune",
    "|/\\|": "dimension_gate"
}

# ----- GRID CELLS -----
var grid_cells = []
var grid_elements = []
var recent_patterns = []
var saved_grids = {}

# ----- SHAPE CATEGORIES -----
enum ShapeCategory {
    ROOM,
    CORRIDOR,
    SHIP,
    BASE,
    ENTITY,
    SPECIAL
}

# ----- TIME STATES -----
enum TimeState {
    PAST,
    PRESENT,
    FUTURE,
    TIMELESS
}

# ----- GAME SYSTEMS -----
var dual_core_terminal = null
var divine_word_game = null
var turn_system = null

# ----- SIGNALS -----
signal grid_created(grid_id, width, height)
signal grid_element_added(element_id, category, pattern)
signal grid_element_removed(element_id)
signal special_pattern_detected(pattern, effect)
signal miracle_portal_created(x, y)
signal grid_saved(grid_id, name)
signal grid_loaded(grid_id, name)
signal time_effect_applied(grid_id, time_state)

# ----- INITIALIZATION -----
func _ready():
    print("Terminal Grid Creator initializing...")
    
    # Initialize empty grid
    _initialize_grid()
    
    # Connect to game systems
    _connect_to_game_systems()
    
    print("Terminal Grid Creator initialized")
    print("Grid size: " + str(grid_width) + "x" + str(grid_height))

func _initialize_grid():
    grid_cells = []
    
    # Create empty grid with default symbols
    for y in range(grid_height):
        var row = []
        for x in range(grid_width):
            row.append({
                "symbol": default_symbol,
                "element_id": -1,  # No element
                "color": Color(1, 1, 1),
                "properties": {}
            })
        grid_cells.append(row)

func _connect_to_game_systems():
    # Connect to dual core terminal
    dual_core_terminal = get_node_or_null("/root/DualCoreTerminal")
    if dual_core_terminal:
        dual_core_terminal.connect("special_pattern_detected", self, "_on_special_pattern_detected")
        dual_core_terminal.connect("time_state_changed", self, "_on_time_state_changed")
    
    # Connect to divine word game
    divine_word_game = get_node_or_null("/root/DivineWordGame")
    
    # Connect to turn system
    turn_system = get_node_or_null("/root/TurnSystem")
    if turn_system:
        turn_system.connect("dimension_changed", self, "_on_dimension_changed")

# ----- GRID MANAGEMENT -----
func create_grid(width, height, default_sym = "."):
    # Store current grid if it has elements
    if grid_elements.size() > 0:
        saved_grids["previous_grid"] = {
            "cells": grid_cells.duplicate(true),
            "elements": grid_elements.duplicate(true),
            "width": grid_width,
            "height": grid_height
        }
    
    # Update grid properties
    grid_width = width
    grid_height = height
    default_symbol = default_sym
    
    # Create new grid
    _initialize_grid()
    grid_elements = []
    
    # Generate grid ID
    var grid_id = "grid_" + str(OS.get_unix_time())
    
    emit_signal("grid_created", grid_id, width, height)
    return grid_id

func place_symbol(x, y, symbol, element_id = -1, properties = {}):
    # Check bounds
    if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
        return false
    
    # Update cell
    grid_cells[y][x].symbol = symbol
    grid_cells[y][x].element_id = element_id
    
    # Add properties
    for key in properties:
        grid_cells[y][x].properties[key] = properties[key]
    
    # Check for special pattern at this location
    _check_patterns_at(x, y)
    
    return true

func place_pattern(x, y, pattern, category, properties = {}):
    var lines = pattern.split("\n")
    var height = lines.size()
    var width = 0
    
    # Find max width
    for line in lines:
        width = max(width, line.length())
    
    # Create element entry
    var element_id = grid_elements.size()
    var element = {
        "id": element_id,
        "category": category,
        "pattern": pattern,
        "x": x,
        "y": y,
        "width": width,
        "height": height,
        "properties": properties.duplicate(),
        "cells": []
    }
    
    # Place each symbol
    for dy in range(height):
        if y + dy >= grid_height:
            continue
        
        var line = lines[dy]
        for dx in range(line.length()):
            if x + dx >= grid_width:
                continue
            
            var symbol = line[dx]
            place_symbol(x + dx, y + dy, symbol, element_id, properties)
            
            # Track cells in element
            element.cells.append({"x": x + dx, "y": y + dy})
    
    # Add element
    grid_elements.append(element)
    
    # Check for special pattern
    _check_pattern_string(pattern, x, y)
    
    emit_signal("grid_element_added", element_id, category, pattern)
    return element_id

func remove_element(element_id):
    if element_id < 0 or element_id >= grid_elements.size():
        return false
    
    var element = grid_elements[element_id]
    
    # Clear all cells used by this element
    for cell in element.cells:
        var x = cell.x
        var y = cell.y
        
        if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
            grid_cells[y][x].symbol = default_symbol
            grid_cells[y][x].element_id = -1
            grid_cells[y][x].properties = {}
    
    # Remove element
    grid_elements[element_id] = null  # Keep array indices intact
    
    emit_signal("grid_element_removed", element_id)
    return true

func save_grid(name):
    var grid_data = {
        "cells": grid_cells.duplicate(true),
        "elements": grid_elements.duplicate(true),
        "width": grid_width,
        "height": grid_height,
        "default_symbol": default_symbol,
        "saved_time": OS.get_unix_time()
    }
    
    saved_grids[name] = grid_data
    
    emit_signal("grid_saved", "grid_" + str(OS.get_unix_time()), name)
    return true

func load_grid(name):
    if not saved_grids.has(name):
        return false
    
    var grid_data = saved_grids[name]
    
    # Load grid properties
    grid_width = grid_data.width
    grid_height = grid_data.height
    default_symbol = grid_data.default_symbol
    
    # Load cells and elements
    grid_cells = grid_data.cells.duplicate(true)
    grid_elements = grid_data.elements.duplicate(true)
    
    emit_signal("grid_loaded", "grid_" + str(OS.get_unix_time()), name)
    return true

# ----- PATTERN DETECTION -----
func _check_patterns_at(x, y):
    # Check for horizontal patterns
    _check_horizontal_pattern(x, y)
    
    # Check for vertical patterns
    _check_vertical_pattern(x, y)
    
    # Check for rectangular patterns
    _check_rectangular_pattern(x, y)

func _check_horizontal_pattern(x, y):
    if x + 10 > grid_width:
        return
    
    # Build horizontal string
    var h_string = ""
    for dx in range(10):
        h_string += grid_cells[y][x + dx].symbol
    
    # Check against special patterns
    for pattern in SPECIAL_PATTERNS:
        if h_string.find(pattern) >= 0:
            _on_pattern_detected(pattern, SPECIAL_PATTERNS[pattern], x, y)

func _check_vertical_pattern(x, y):
    if y + 10 > grid_height:
        return
    
    # Build vertical string
    var v_string = ""
    for dy in range(10):
        v_string += grid_cells[y + dy][x].symbol
    
    # Check against special patterns
    for pattern in SPECIAL_PATTERNS:
        if v_string.find(pattern) >= 0:
            _on_pattern_detected(pattern, SPECIAL_PATTERNS[pattern], x, y)

func _check_rectangular_pattern(x, y):
    # Check for small rectangular patterns (up to 5x5)
    if x + 5 > grid_width or y + 5 > grid_height:
        return
    
    # Build rectangular string
    var rect_string = ""
    for dy in range(5):
        for dx in range(5):
            rect_string += grid_cells[y + dy][x + dx].symbol
        rect_string += "\n"
    
    # Check against special patterns that contain newlines
    for pattern in SPECIAL_PATTERNS:
        if "\n" in pattern and rect_string.find(pattern) >= 0:
            _on_pattern_detected(pattern, SPECIAL_PATTERNS[pattern], x, y)

func _check_pattern_string(pattern, x, y):
    # Check the pattern string directly for special patterns
    for special in SPECIAL_PATTERNS:
        if pattern.find(special) >= 0:
            _on_pattern_detected(special, SPECIAL_PATTERNS[special], x, y)

func _on_pattern_detected(pattern, effect, x, y):
    # Add to recent patterns
    recent_patterns.append({
        "pattern": pattern,
        "effect": effect,
        "x": x,
        "y": y,
        "timestamp": OS.get_unix_time()
    })
    
    # Emit signal
    emit_signal("special_pattern_detected", pattern, effect)
    
    # Handle special effects
    match effect:
        "miracle_portal":
            _create_miracle_portal(x, y)
        "teleporter":
            _create_teleporter(x, y)
        "time_rune":
            _create_time_rune(x, y)
        "dimension_gate":
            _create_dimension_gate(x, y)

func _create_miracle_portal(x, y):
    # Create special visual effect for miracle portal
    var portal_properties = {
        "type": "miracle_portal",
        "active": true,
        "created_at": OS.get_unix_time(),
        "color": Color(1, 0.5, 1)  # Purple glow
    }
    
    # Create portal pattern
    var portal_pattern = "#$%$#@@\n@#$%$#@\n@$#%$#@"
    place_pattern(x, y, portal_pattern, ShapeCategory.SPECIAL, portal_properties)
    
    emit_signal("miracle_portal_created", x, y)
    
    # Notify divine word game if available
    if divine_word_game:
        divine_word_game.process_word("miracle_portal")

func _create_teleporter(x, y):
    # Create teleporter effect
    var teleporter_properties = {
        "type": "teleporter",
        "active": true,
        "created_at": OS.get_unix_time(),
        "destination_x": randi() % grid_width,
        "destination_y": randi() % grid_height
    }
    
    place_pattern(x, y, "<->", ShapeCategory.SPECIAL, teleporter_properties)

func _create_time_rune(x, y):
    # Create time rune effect
    var time_rune_properties = {
        "type": "time_rune",
        "active": true,
        "created_at": OS.get_unix_time(),
        "time_state": TimeState.PRESENT
    }
    
    place_pattern(x, y, "/*\\", ShapeCategory.SPECIAL, time_rune_properties)

func _create_dimension_gate(x, y):
    # Create dimension gate effect
    var dimension_gate_properties = {
        "type": "dimension_gate",
        "active": true,
        "created_at": OS.get_unix_time(),
        "current_dimension": turn_system.current_dimension if turn_system else 3,
        "target_dimension": (turn_system.current_dimension + 1) % (turn_system.max_turns + 1) if turn_system else 4
    }
    
    place_pattern(x, y, "|/\\|", ShapeCategory.SPECIAL, dimension_gate_properties)

# ----- TIME EFFECTS -----
func apply_time_effect(time_state):
    var current_grid_id = "grid_" + str(OS.get_unix_time())
    
    # Apply different effects based on time state
    match time_state:
        TimeState.PAST:
            # Show older versions of elements
            if saved_grids.has("previous_grid"):
                # Temporarily load past version
                var current = {
                    "cells": grid_cells.duplicate(true),
                    "elements": grid_elements.duplicate(true),
                    "width": grid_width,
                    "height": grid_height
                }
                
                # Load previous grid
                grid_cells = saved_grids.previous_grid.cells.duplicate(true)
                grid_elements = saved_grids.previous_grid.elements.duplicate(true)
                
                # Apply faded effect
                for y in range(grid_height):
                    for x in range(grid_width):
                        if grid_cells[y][x].has("color"):
                            grid_cells[y][x].color = grid_cells[y][x].color.darkened(0.3)
                
                # Save current as temp for later restoration
                saved_grids["temp_current"] = current
        
        TimeState.FUTURE:
            # Show potential future elements
            # Generate some new elements based on existing ones
            var future_elements = []
            
            for element in grid_elements:
                if element == null:
                    continue
                
                # Create evolved version of the element
                var evolved = element.duplicate(true)
                evolved.id = grid_elements.size() + future_elements.size()
                
                # Shift position slightly
                evolved.x += randi() % 5 - 2
                evolved.y += randi() % 3 - 1
                
                # Ensure within bounds
                evolved.x = clamp(evolved.x, 0, grid_width - evolved.width)
                evolved.y = clamp(evolved.y, 0, grid_height - evolved.height)
                
                future_elements.append(evolved)
            
            # Save current as temp
            saved_grids["temp_current"] = {
                "cells": grid_cells.duplicate(true),
                "elements": grid_elements.duplicate(true),
                "width": grid_width,
                "height": grid_height
            }
            
            # Add future elements
            for element in future_elements:
                # Parse pattern
                var lines = element.pattern.split("\n")
                
                # Place each symbol
                for dy in range(element.height):
                    if element.y + dy >= grid_height:
                        continue
                    
                    var line = lines[dy] if dy < lines.size() else ""
                    for dx in range(element.width):
                        if element.x + dx >= grid_width or dx >= line.length():
                            continue
                        
                        var symbol = line[dx]
                        grid_cells[element.y + dy][element.x + dx].symbol = symbol
                        grid_cells[element.y + dy][element.x + dx].element_id = element.id
                        grid_cells[element.y + dy][element.x + dx].color = Color(0.8, 0.8, 1.0)  # Bluish tint
        
        TimeState.TIMELESS:
            # Show all time states overlapping
            # Save current first
            saved_grids["temp_current"] = {
                "cells": grid_cells.duplicate(true),
                "elements": grid_elements.duplicate(true),
                "width": grid_width,
                "height": grid_height
            }
            
            # Blend past and future if available
            if saved_grids.has("previous_grid"):
                for y in range(min(grid_height, saved_grids.previous_grid.height)):
                    for x in range(min(grid_width, saved_grids.previous_grid.width)):
                        # 50% chance to use past symbol
                        if randf() < 0.5:
                            grid_cells[y][x].symbol = saved_grids.previous_grid.cells[y][x].symbol
                            grid_cells[y][x].color = Color(1, 0.7, 1)  # Purple tint
        
        TimeState.PRESENT:
            # Restore from temp if it exists
            if saved_grids.has("temp_current"):
                grid_cells = saved_grids.temp_current.cells.duplicate(true)
                grid_elements = saved_grids.temp_current.elements.duplicate(true)
                saved_grids.erase("temp_current")
    
    emit_signal("time_effect_applied", current_grid_id, time_state)
    return current_grid_id

# ----- EVENT HANDLERS -----
func _on_special_pattern_detected(pattern, effect):
    # Called when DualCoreTerminal detects a pattern
    # Add to recent patterns
    recent_patterns.append({
        "pattern": pattern,
        "effect": effect,
        "x": -1,  # Unknown location
        "y": -1,
        "source": "terminal",
        "timestamp": OS.get_unix_time()
    })
    
    # If it's a grid-related pattern, try to place it somewhere
    if SPECIAL_PATTERNS.has(pattern):
        # Find a suitable location
        var x = randi() % (grid_width - 10)
        var y = randi() % (grid_height - 5)
        
        place_pattern(x, y, pattern, ShapeCategory.SPECIAL, {
            "source": "terminal_pattern",
            "effect": effect
        })

func _on_time_state_changed(old_state, new_state):
    # Apply time effect to the grid
    apply_time_effect(new_state)

func _on_dimension_changed(new_dimension, old_dimension):
    # Handle dimension change
    # Save current grid
    save_grid("dimension_" + str(old_dimension))
    
    # If we have a saved grid for the new dimension, load it
    if saved_grids.has("dimension_" + str(new_dimension)):
        load_grid("dimension_" + str(new_dimension))
    else:
        # Create a new grid for this dimension
        create_grid(grid_width, grid_height, default_symbol)
        
        # Add dimension-specific elements
        _add_dimension_elements(new_dimension)

func _add_dimension_elements(dimension):
    # Add dimension-specific elements to a new grid
    match dimension:
        1: # Linear elements (1D)
            place_pattern(10, grid_height / 2, "----------------", ShapeCategory.CORRIDOR, {
                "dimension": 1,
                "description": "Linear path"
            })
        
        2: # Planar elements (2D)
            var square = "+----+\n|    |\n|    |\n+----+"
            place_pattern(grid_width / 2 - 3, grid_height / 2 - 2, square, ShapeCategory.ROOM, {
                "dimension": 2,
                "description": "Square room"
            })
        
        3: # Spatial elements (3D)
            var cube = "/-----\\\n|     |\n|     |\n|     |\n\\-----/"
            place_pattern(grid_width / 2 - 3, grid_height / 2 - 2, cube, ShapeCategory.ROOM, {
                "dimension": 3,
                "description": "Cube room"
            })
        
        4: # Temporal elements (4D)
            place_pattern(grid_width / 2 - 3, grid_height / 2 - 1, "/*\\", ShapeCategory.SPECIAL, {
                "dimension": 4,
                "description": "Time rune",
                "type": "time_rune"
            })
        
        5: # Probability elements (5D)
            var pattern = "~~~?\n?~~~\n~~~?\n?~~~"
            place_pattern(grid_width / 2 - 2, grid_height / 2 - 2, pattern, ShapeCategory.SPECIAL, {
                "dimension": 5,
                "description": "Probability waves"
            })
        
        7: # Dream elements (7D)
            var pattern = "*   *\n * * \n  *  \n * * \n*   *"
            place_pattern(grid_width / 2 - 2, grid_height / 2 - 2, pattern, ShapeCategory.SPECIAL, {
                "dimension": 7,
                "description": "Dream fragment"
            })
        
        9: # Judgment elements (9D)
            var pattern = "=====\n  |\n  |\n  O  "
            place_pattern(grid_width / 2 - 2, grid_height / 2 - 2, pattern, ShapeCategory.SPECIAL, {
                "dimension": 9,
                "description": "Scales of judgment"
            })
        
        12: # Divine elements (12D)
            place_pattern(grid_width / 2 - 3, grid_height / 2 - 1, "#$%$#@@", ShapeCategory.SPECIAL, {
                "dimension": 12,
                "description": "Miracle portal",
                "type": "miracle_portal"
            })

# ----- PUBLIC API -----
func get_grid_size():
    return Vector2(grid_width, grid_height)

func get_cell(x, y):
    if x < 0 or x >= grid_width or y < 0 or y >= grid_height:
        return null
    
    return grid_cells[y][x]

func get_grid_as_string():
    var result = ""
    
    for y in range(grid_height):
        var row = ""
        for x in range(grid_width):
            row += grid_cells[y][x].symbol
        result += row + "\n"
    
    return result

func get_element(element_id):
    if element_id < 0 or element_id >= grid_elements.size():
        return null
    
    return grid_elements[element_id]

func get_elements_by_category(category):
    var result = []
    
    for element in grid_elements:
        if element != null and element.category == category:
            result.append(element)
    
    return result

func get_saved_grid_names():
    return saved_grids.keys()

func clear_grid():
    _initialize_grid()
    grid_elements = []
    return true

func get_recent_patterns(limit=5):
    if recent_patterns.size() <= limit:
        return recent_patterns
    
    return recent_patterns.slice(recent_patterns.size() - limit, recent_patterns.size() - 1)

func add_room(x, y, width, height, door_positions=[]):
    # Create a room with optional doors
    var room = ""
    
    # Generate room ASCII art
    for dy in range(height):
        var row = ""
        for dx in range(width):
            var is_door = false
            
            # Check if this position has a door
            for door in door_positions:
                if door.x == dx and door.y == dy:
                    is_door = true
                    break
            
            # Border chars
            if dy == 0 and dx == 0:
                row += "+"  # Top-left corner
            elif dy == 0 and dx == width - 1:
                row += "+"  # Top-right corner
            elif dy == height - 1 and dx == 0:
                row += "+"  # Bottom-left corner
            elif dy == height - 1 and dx == width - 1:
                row += "+"  # Bottom-right corner
            elif dy == 0 or dy == height - 1:
                row += "-"  # Horizontal walls
            elif dx == 0 or dx == width - 1:
                row += "|"  # Vertical walls
            else:
                row += " "  # Interior
            
            # Replace with door if needed
            if is_door:
                row[row.length() - 1] = "+"
        
        room += row
        if dy < height - 1:
            room += "\n"
    
    return place_pattern(x, y, room, ShapeCategory.ROOM, {
        "type": "room",
        "has_doors": door_positions.size() > 0
    })

func add_corridor(start_x, start_y, end_x, end_y):
    # Create a corridor between two points
    var pattern = ""
    var min_x = min(start_x, end_x)
    var max_x = max(start_x, end_x)
    var min_y = min(start_y, end_y)
    var max_y = max(start_y, end_y)
    
    # Determine if horizontal or vertical
    if abs(end_x - start_x) > abs(end_y - start_y):
        # Horizontal corridor
        pattern = "#" + "-".repeat(max_x - min_x - 1) + "#"
        return place_pattern(min_x, start_y, pattern, ShapeCategory.CORRIDOR, {
            "type": "corridor",
            "direction": "horizontal"
        })
    else:
        # Vertical corridor
        for dy in range(max_y - min_y + 1):
            pattern += "#\n"
        return place_pattern(start_x, min_y, pattern, ShapeCategory.CORRIDOR, {
            "type": "corridor",
            "direction": "vertical"
        })

func add_ship(x, y, ship_type="small"):
    var pattern = ""
    
    match ship_type:
        "small":
            pattern = " /\\\n<==>\n \\/"
        "medium":
            pattern = "  /\\\n /  \\\n<====>\n \\  /\n  \\/"
        "large":
            pattern = "   /\\\n  /  \\\n /    \\\n<======>\n \\    /\n  \\  /\n   \\/"
        "alien":
            pattern = " _._\n/ O \\\n<-X->\n\\_^_/"
    
    return place_pattern(x, y, pattern, ShapeCategory.SHIP, {
        "type": "ship",
        "ship_type": ship_type
    })

func add_base(x, y, base_type="outpost"):
    var pattern = ""
    
    match base_type:
        "outpost":
            pattern = "+---+\n|[o]|\n+---+"
        "fortress":
            pattern = "+-----+\n|  ^  |\n| [ ] |\n|< X >|\n+-----+"
        "spaceport":
            pattern = "  /\\  \n /  \\ \n/====\\\n|    |\n|====|"
    
    return place_pattern(x, y, pattern, ShapeCategory.BASE, {
        "type": "base",
        "base_type": base_type
    })

func add_entity(x, y, entity_type="player"):
    var symbol = "@"
    
    match entity_type:
        "player":
            symbol = "@"
        "enemy":
            symbol = "E"
        "npc":
            symbol = "N"
        "treasure":
            symbol = "$"
        "boss":
            symbol = "B"
    
    return place_symbol(x, y, symbol, grid_elements.size(), {
        "type": "entity",
        "entity_type": entity_type
    })

func generate_dungeon(rooms=5, corridor_chance=0.7):
    # Clear grid
    clear_grid()
    
    # Generate rooms
    var room_positions = []
    for i in range(rooms):
        var width = 5 + randi() % 5
        var height = 3 + randi() % 3
        var x = randi() % (grid_width - width - 2) + 1
        var y = randi() % (grid_height - height - 2) + 1
        
        var room_id = add_room(x, y, width, height)
        room_positions.append({
            "id": room_id,
            "x": x,
            "y": y,
            "width": width,
            "height": height,
            "center_x": x + width / 2,
            "center_y": y + height / 2
        })
    
    # Generate corridors between rooms
    for i in range(room_positions.size()):
        var room1 = room_positions[i]
        
        # Connect to a random other room
        var room2_idx = (i + 1 + randi() % (room_positions.size() - 1)) % room_positions.size()
        var room2 = room_positions[room2_idx]
        
        if randf() < corridor_chance:
            add_corridor(room1.center_x, room1.center_y, room2.center_x, room2.center_y)
    
    # Add some entities
    var player_room = room_positions[randi() % room_positions.size()]
    add_entity(player_room.center_x, player_room.center_y, "player")
    
    # Add some treasures and enemies
    for i in range(1, room_positions.size()):
        var room = room_positions[i]
        var entity_type = "enemy" if randf() < 0.7 else "treasure"
        
        add_entity(room.center_x, room.center_y, entity_type)
    
    return "dungeon_" + str(OS.get_unix_time())

func generate_space_map(ships=3, bases=2):
    # Clear grid
    clear_grid()
    
    # Fill with stars
    for i in range(grid_width * grid_height / 50):
        var x = randi() % grid_width
        var y = randi() % grid_height
        place_symbol(x, y, ".", -1, {"type": "star"})
    
    # Add ships
    var ship_types = ["small", "medium", "large", "alien"]
    for i in range(ships):
        var x = randi() % (grid_width - 10) + 5
        var y = randi() % (grid_height - 10) + 5
        var ship_type = ship_types[randi() % ship_types.size()]
        
        add_ship(x, y, ship_type)
    
    # Add bases
    var base_types = ["outpost", "fortress", "spaceport"]
    for i in range(bases):
        var x = randi() % (grid_width - 10) + 5
        var y = randi() % (grid_height - 10) + 5
        var base_type = base_types[randi() % base_types.size()]
        
        add_base(x, y, base_type)
    
    # Add player ship
    var player_x = grid_width / 2
    var player_y = grid_height - 5
    add_ship(player_x, player_y, "small")
    
    return "space_map_" + str(OS.get_unix_time())