extends Node

class_name FunctionGridManager

# ----- GRID SETTINGS -----
@export_category("Grid Settings")
@export var grid_size: Vector2i = Vector2i(4, 4)  # 4x4 grid by default
@export var enable_dynamic_resizing: bool = true
@export var min_grid_size: Vector2i = Vector2i(2, 2)
@export var max_grid_size: Vector2i = Vector2i(9, 9)

# ----- REFRESH SETTINGS -----
@export_category("Refresh Settings")
@export var auto_refresh_enabled: bool = true
@export var refresh_interval: float = 60.0  # Default: 1 minute
@export var staggered_refresh: bool = true
@export var minimum_refresh_interval: float = 5.0  # Seconds
@export var enable_per_cell_refresh_rates: bool = true

# ----- COMPRESSION SETTINGS -----
@export_category("Compression Settings")
@export var enable_data_compression: bool = true
@export var compression_level: int = 6  # 0-9, higher = more compression
@export var compressed_storage_path: String = "user://function_grid_compressed/"
@export var apply_delta_compression: bool = true  # Only store changes

# ----- STATE VARIABLES -----
var function_grid = []  # 2D array of function cells
var cell_states = {}    # Dictionary of cell states
var cell_refresh_timers = {}
var main_refresh_timer: Timer
var precise_timing_system = null
var turn_controller = null
var blink_controller = null
var translation_system = null

# ----- CELL STATE CONSTANTS -----
enum CellState {
    IDLE,
    ACTIVE,
    PROCESSING,
    ERROR,
    DISABLED,
    HIGHLIGHTED
}

# ----- SIGNALS -----
signal grid_initialized(width, height)
signal grid_resized(old_size, new_size)
signal cell_refreshed(x, y, function_id)
signal cell_state_changed(x, y, old_state, new_state)
signal compression_completed(compression_ratio, bytes_saved)
signal function_executed(function_id, result)
signal all_cells_refreshed()

# ----- INITIALIZATION -----
func _ready():
    # Find related systems
    _find_systems()
    
    # Initialize the function grid
    _initialize_grid()
    
    # Set up refresh timer
    _setup_refresh_timer()
    
    # Register with turn controller if available
    if turn_controller:
        turn_controller.register_system(self)
    
    # Connect to precise timing if available
    if precise_timing_system:
        _connect_precise_timing()
    
    print("Function Grid Manager initialized")
    print("Grid size: " + str(grid_size.x) + "x" + str(grid_size.y))
    print("Refresh interval: " + str(refresh_interval) + "s")

func _find_systems():
    # Find turn controller
    turn_controller = get_node_or_null("/root/TurnController")
    if not turn_controller:
        turn_controller = _find_node_by_class(get_tree().root, "TurnController")
    
    # Find precise timing system
    precise_timing_system = get_node_or_null("/root/PreciseTimingSystem")
    if not precise_timing_system:
        precise_timing_system = _find_node_by_class(get_tree().root, "PreciseTimingSystem")
    
    # Find blink controller
    blink_controller = get_node_or_null("/root/BlinkAnimationController")
    if not blink_controller:
        blink_controller = _find_node_by_class(get_tree().root, "BlinkAnimationController")
    
    # Find translation system
    translation_system = get_node_or_null("/root/TranslationSystem")
    if not translation_system:
        translation_system = _find_node_by_class(get_tree().root, "TranslationSystem")
    
    print("Systems found - Turn Controller: %s, Precise Timing: %s, Blink Controller: %s, Translation: %s" % [
        "Yes" if turn_controller else "No",
        "Yes" if precise_timing_system else "No",
        "Yes" if blink_controller else "No",
        "Yes" if translation_system else "No"
    ])

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _initialize_grid():
    # Initialize the function grid with the specified size
    function_grid = []
    cell_states = {}
    
    for x in range(grid_size.x):
        var column = []
        for y in range(grid_size.y):
            # Create a new cell with default function
            var cell = {
                "function_id": _generate_cell_id(x, y),
                "function_name": "func_" + str(x) + "_" + str(y),
                "function": Callable(),
                "last_refresh": 0,
                "refresh_count": 0,
                "last_result": null,
                "metadata": {
                    "position": Vector2i(x, y),
                    "created_at": Time.get_unix_time_from_system(),
                    "tags": []
                }
            }
            
            column.append(cell)
            
            # Set initial state
            _set_cell_state(x, y, CellState.IDLE)
            
            # Set up individual refresh timer if enabled
            if enable_per_cell_refresh_rates:
                _setup_cell_refresh_timer(x, y)
        
        function_grid.append(column)
    
    emit_signal("grid_initialized", grid_size.x, grid_size.y)
    print("Grid initialized with size " + str(grid_size.x) + "x" + str(grid_size.y))

func _setup_refresh_timer():
    # Set up the main refresh timer
    main_refresh_timer = Timer.new()
    main_refresh_timer.wait_time = refresh_interval
    main_refresh_timer.one_shot = false
    main_refresh_timer.connect("timeout", Callable(self, "_on_refresh_timer_timeout"))
    add_child(main_refresh_timer)
    
    if auto_refresh_enabled:
        main_refresh_timer.start()

func _setup_cell_refresh_timer(x: int, y: int):
    # Set up individual refresh timer for a cell
    var timer = Timer.new()
    var cell_id = _generate_cell_id(x, y)
    
    # Calculate a slightly different interval for each cell if staggered
    var base_interval = refresh_interval
    if staggered_refresh:
        # Add a slight offset based on position
        var offset = (x * y * 0.1) % (refresh_interval * 0.2)
        base_interval += offset
    
    timer.wait_time = base_interval
    timer.one_shot = false
    timer.connect("timeout", Callable(self, "_on_cell_refresh_timeout").bind(x, y))
    add_child(timer)
    
    cell_refresh_timers[cell_id] = timer
    
    if auto_refresh_enabled:
        timer.start()

func _connect_precise_timing():
    # Connect to precise timing system events
    
    # Register for minute markers
    if precise_timing_system.has_method("register_minute_callback"):
        for minute in [0, 15, 30, 45]:
            precise_timing_system.register_minute_callback(-1, minute, func(h, m):
                # Refresh a quarter of the grid every 15 minutes
                var section = minute / 15
                _refresh_grid_section(section)
            )
    
    # Set up special timing for turn 15
    if precise_timing_system.has_method("register_time_callback"):
        precise_timing_system.register_time_callback(15, 0, 0, func(h, m, s):
            # Special grid refresh behavior at exactly 15:00
            print("Executing special grid refresh at exactly 15:00")
            _full_grid_refresh_sequence()
        )

# ----- GRID MANAGEMENT -----
func resize_grid(new_size: Vector2i) -> bool:
    # Resize the function grid to a new size
    if not enable_dynamic_resizing:
        print("Dynamic grid resizing is disabled")
        return false
    
    # Validate new size
    if new_size.x < min_grid_size.x or new_size.y < min_grid_size.y or 
       new_size.x > max_grid_size.x or new_size.y > max_grid_size.y:
        print("Invalid grid size: " + str(new_size.x) + "x" + str(new_size.y))
        return false
    
    var old_size = grid_size
    grid_size = new_size
    
    print("Resizing grid from " + str(old_size.x) + "x" + str(old_size.y) + 
          " to " + str(new_size.x) + "x" + str(new_size.y))
    
    # Save existing cell data
    var existing_cells = {}
    for x in range(min(old_size.x, new_size.x)):
        for y in range(min(old_size.y, new_size.y)):
            var cell_id = _generate_cell_id(x, y)
            existing_cells[cell_id] = function_grid[x][y]
    
    # Re-initialize the grid with new size
    _initialize_grid()
    
    # Restore existing cell data
    for x in range(min(old_size.x, new_size.x)):
        for y in range(min(old_size.y, new_size.y)):
            var cell_id = _generate_cell_id(x, y)
            if existing_cells.has(cell_id):
                function_grid[x][y] = existing_cells[cell_id]
    
    emit_signal("grid_resized", old_size, new_size)
    
    return true

func _generate_cell_id(x: int, y: int) -> String:
    # Generate a unique ID for a cell
    return "cell_" + str(x) + "_" + str(y)

func get_cell(x: int, y: int) -> Dictionary:
    # Get a cell at specified coordinates
    if _validate_coordinates(x, y):
        return function_grid[x][y].duplicate()
    
    return {}

func get_cell_state(x: int, y: int):
    # Get the state of a cell
    var cell_id = _generate_cell_id(x, y)
    if cell_states.has(cell_id):
        return cell_states[cell_id]
    
    return CellState.DISABLED

func _set_cell_state(x: int, y: int, new_state):
    # Set the state of a cell
    var cell_id = _generate_cell_id(x, y)
    var old_state = cell_states.get(cell_id, CellState.DISABLED)
    
    if old_state != new_state:
        cell_states[cell_id] = new_state
        emit_signal("cell_state_changed", x, y, old_state, new_state)
        
        # Visual feedback with blink controller if available
        if blink_controller and new_state == CellState.ACTIVE:
            blink_controller.trigger_blink(cell_id)
        elif blink_controller and new_state == CellState.ERROR:
            blink_controller.trigger_flicker(cell_id, 2)
    
    return new_state

func _validate_coordinates(x: int, y: int) -> bool:
    # Validate if coordinates are within grid bounds
    return x >= 0 and x < grid_size.x and y >= 0 and y < grid_size.y

# ----- FUNCTION MANAGEMENT -----
func register_function(x: int, y: int, function_name: String, function: Callable, metadata: Dictionary = {}) -> bool:
    # Register a function at specified coordinates
    if not _validate_coordinates(x, y):
        print("Invalid coordinates: " + str(x) + "," + str(y))
        return false
    
    var cell = function_grid[x][y]
    cell.function_name = function_name
    cell.function = function
    
    # Merge metadata
    for key in metadata:
        cell.metadata[key] = metadata[key]
    
    print("Registered function '" + function_name + "' at " + str(x) + "," + str(y))
    
    # Change state to idle (or active if it's already processing)
    if get_cell_state(x, y) != CellState.PROCESSING:
        _set_cell_state(x, y, CellState.IDLE)
    
    return true

func execute_function(x: int, y: int, args: Array = []) -> Variant:
    # Execute a function at specified coordinates
    if not _validate_coordinates(x, y):
        print("Invalid coordinates: " + str(x) + "," + str(y))
        return null
    
    var cell = function_grid[x][y]
    var function = cell.function
    
    if not function.is_valid():
        print("No valid function at " + str(x) + "," + str(y))
        _set_cell_state(x, y, CellState.ERROR)
        return null
    
    print("Executing function '" + cell.function_name + "' at " + str(x) + "," + str(y))
    
    # Set state to processing
    _set_cell_state(x, y, CellState.PROCESSING)
    
    var result = null
    try:
        # Execute the function with provided arguments
        if args.size() > 0:
            result = function.callv(args)
        else:
            result = function.call()
        
        # Store result and update state
        cell.last_result = result
        cell.last_refresh = Time.get_unix_time_from_system()
        cell.refresh_count += 1
        
        _set_cell_state(x, y, CellState.ACTIVE)
        
        # Emit signal
        emit_signal("function_executed", cell.function_id, result)
    except Exception as e:
        print("Error executing function at " + str(x) + "," + str(y) + ": " + str(e))
        _set_cell_state(x, y, CellState.ERROR)
    
    return result

func unregister_function(x: int, y: int) -> bool:
    # Unregister a function at specified coordinates
    if not _validate_coordinates(x, y):
        print("Invalid coordinates: " + str(x) + "," + str(y))
        return false
    
    var cell = function_grid[x][y]
    var old_function_name = cell.function_name
    
    # Reset the cell
    cell.function_name = "func_" + str(x) + "_" + str(y)
    cell.function = Callable()
    cell.last_result = null
    
    print("Unregistered function '" + old_function_name + "' at " + str(x) + "," + str(y))
    
    # Set state to disabled
    _set_cell_state(x, y, CellState.DISABLED)
    
    return true

# ----- REFRESH MANAGEMENT -----
func refresh_cell(x: int, y: int) -> Variant:
    # Refresh a single cell
    if not _validate_coordinates(x, y):
        print("Invalid coordinates: " + str(x) + "," + str(y))
        return null
    
    var cell = function_grid[x][y]
    
    # Execute the function
    var result = execute_function(x, y)
    
    # Emit refresh signal
    emit_signal("cell_refreshed", x, y, cell.function_id)
    
    return result

func refresh_row(y: int) -> bool:
    # Refresh an entire row
    if y < 0 or y >= grid_size.y:
        print("Invalid row: " + str(y))
        return false
    
    print("Refreshing row " + str(y))
    
    for x in range(grid_size.x):
        refresh_cell(x, y)
        
        # Small delay between cells if staggered refresh
        if staggered_refresh:
            await get_tree().create_timer(0.1).timeout
    
    return true

func refresh_column(x: int) -> bool:
    # Refresh an entire column
    if x < 0 or x >= grid_size.x:
        print("Invalid column: " + str(x))
        return false
    
    print("Refreshing column " + str(x))
    
    for y in range(grid_size.y):
        refresh_cell(x, y)
        
        # Small delay between cells if staggered refresh
        if staggered_refresh:
            await get_tree().create_timer(0.1).timeout
    
    return true

func refresh_all() -> bool:
    # Refresh all cells in the grid
    print("Refreshing all cells")
    
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            refresh_cell(x, y)
            
            # Small delay between cells if staggered refresh
            if staggered_refresh:
                await get_tree().create_timer(0.05).timeout
    
    emit_signal("all_cells_refreshed")
    
    return true

func _refresh_grid_section(section: int) -> bool:
    # Refresh a section of the grid (0-3 for quarters)
    if section < 0 or section > 3:
        print("Invalid grid section: " + str(section))
        return false
    
    print("Refreshing grid section " + str(section))
    
    # Calculate section boundaries
    var start_x = 0
    var start_y = 0
    var end_x = grid_size.x
    var end_y = grid_size.y
    
    match section:
        0:  # Top-left quarter
            end_x = grid_size.x / 2
            end_y = grid_size.y / 2
        1:  # Top-right quarter
            start_x = grid_size.x / 2
            end_y = grid_size.y / 2
        2:  # Bottom-left quarter
            start_y = grid_size.y / 2
            end_x = grid_size.x / 2
        3:  # Bottom-right quarter
            start_x = grid_size.x / 2
            start_y = grid_size.y / 2
    
    # Refresh cells in this section
    for x in range(start_x, end_x):
        for y in range(start_y, end_y):
            refresh_cell(x, y)
            
            # Small delay between cells if staggered refresh
            if staggered_refresh:
                await get_tree().create_timer(0.05).timeout
    
    return true

func _full_grid_refresh_sequence():
    # Special sequence for full grid refresh
    
    # First, highlight all cells
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            _set_cell_state(x, y, CellState.HIGHLIGHTED)
    
    await get_tree().create_timer(0.5).timeout
    
    # Then refresh in a specific pattern (spiral, diagonal, or other pattern)
    var refresh_pattern = "spiral"
    
    match refresh_pattern:
        "spiral":
            _refresh_spiral_pattern()
        "diagonal":
            _refresh_diagonal_pattern()
        "waves":
            _refresh_wave_pattern()
        _:
            refresh_all()

func _refresh_spiral_pattern():
    # Refresh in a spiral pattern from the center outward
    var center_x = grid_size.x / 2
    var center_y = grid_size.y / 2
    
    print("Refreshing in spiral pattern from center")
    
    # Start at center
    refresh_cell(center_x, center_y)
    await get_tree().create_timer(0.2).timeout
    
    # Spiral outward
    var max_radius = max(grid_size.x, grid_size.y)
    for radius in range(1, max_radius):
        # Top edge
        for x in range(center_x - radius, center_x + radius + 1):
            var y = center_y - radius
            if _validate_coordinates(x, y):
                refresh_cell(x, y)
                await get_tree().create_timer(0.05).timeout
        
        # Right edge
        for y in range(center_y - radius + 1, center_y + radius + 1):
            var x = center_x + radius
            if _validate_coordinates(x, y):
                refresh_cell(x, y)
                await get_tree().create_timer(0.05).timeout
        
        # Bottom edge
        for x in range(center_x + radius - 1, center_x - radius - 1, -1):
            var y = center_y + radius
            if _validate_coordinates(x, y):
                refresh_cell(x, y)
                await get_tree().create_timer(0.05).timeout
        
        # Left edge
        for y in range(center_y + radius - 1, center_y - radius, -1):
            var x = center_x - radius
            if _validate_coordinates(x, y):
                refresh_cell(x, y)
                await get_tree().create_timer(0.05).timeout

func _refresh_diagonal_pattern():
    # Refresh in diagonal lines
    print("Refreshing in diagonal pattern")
    
    # Main diagonal (top-left to bottom-right)
    for i in range(min(grid_size.x, grid_size.y)):
        refresh_cell(i, i)
        await get_tree().create_timer(0.1).timeout
    
    # Anti-diagonal (top-right to bottom-left)
    for i in range(min(grid_size.x, grid_size.y)):
        refresh_cell(grid_size.x - 1 - i, i)
        await get_tree().create_timer(0.1).timeout
    
    # Other diagonals
    for offset in range(1, max(grid_size.x, grid_size.y)):
        # Above main diagonal
        for i in range(min(grid_size.x - offset, grid_size.y)):
            refresh_cell(i + offset, i)
            await get_tree().create_timer(0.05).timeout
        
        # Below main diagonal
        for i in range(min(grid_size.x, grid_size.y - offset)):
            refresh_cell(i, i + offset)
            await get_tree().create_timer(0.05).timeout

func _refresh_wave_pattern():
    # Refresh in wave pattern from top to bottom
    print("Refreshing in wave pattern")
    
    for y in range(grid_size.y):
        # Alternate direction for each row
        if y % 2 == 0:
            for x in range(grid_size.x):
                refresh_cell(x, y)
                await get_tree().create_timer(0.05).timeout
        else:
            for x in range(grid_size.x - 1, -1, -1):
                refresh_cell(x, y)
                await get_tree().create_timer(0.05).timeout

# ----- TIMER CALLBACKS -----
func _on_refresh_timer_timeout():
    # Called when the main refresh timer expires
    if auto_refresh_enabled:
        refresh_all()

func _on_cell_refresh_timeout(x: int, y: int):
    # Called when a cell's individual refresh timer expires
    if auto_refresh_enabled and _validate_coordinates(x, y):
        refresh_cell(x, y)

# ----- COMPRESSION FUNCTIONS -----
func compress_grid_data() -> Dictionary:
    # Compress the current grid data for storage
    if not enable_data_compression:
        return {"compressed": false, "data": function_grid}
    
    print("Compressing grid data...")
    
    # Convert grid to serializable format
    var serialized_data = _serialize_grid()
    
    # Create directory if it doesn't exist
    var dir = Directory.new()
    if not dir.dir_exists(compressed_storage_path):
        dir.make_dir_recursive(compressed_storage_path)
    
    # Generate filename with timestamp
    var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
    var filename = compressed_storage_path + "grid_" + timestamp + ".zip"
    
    # Compress data (simulating compression in this mock implementation)
    var original_size = serialized_data.length()
    var compressed_size = int(original_size * (0.9 - (compression_level * 0.05)))  # Simulate compression ratio
    var compression_ratio = float(original_size) / max(1, compressed_size)
    
    # Save to file (in a real implementation)
    var file = File.new()
    file.open(filename, File.WRITE)
    file.store_string(JSON.print(serialized_data))  # In reality, this would be compressed data
    file.close()
    
    # Calculate savings
    var bytes_saved = original_size - compressed_size
    
    print("Compression complete - Ratio: " + str(compression_ratio) + ", Saved: " + str(bytes_saved) + " bytes")
    emit_signal("compression_completed", compression_ratio, bytes_saved)
    
    return {
        "compressed": true,
        "filename": filename,
        "original_size": original_size,
        "compressed_size": compressed_size,
        "compression_ratio": compression_ratio,
        "timestamp": timestamp
    }

func _serialize_grid() -> Dictionary:
    # Convert grid to serializable format
    var serialized = {
        "size": {"x": grid_size.x, "y": grid_size.y},
        "cells": {},
        "metadata": {
            "timestamp": Time.get_unix_time_from_system(),
            "version": "1.0",
            "compression_level": compression_level
        }
    }
    
    # Store cell data
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            var cell = function_grid[x][y]
            var cell_id = _generate_cell_id(x, y)
            
            # Store cell data without the callable
            serialized.cells[cell_id] = {
                "function_name": cell.function_name,
                "last_refresh": cell.last_refresh,
                "refresh_count": cell.refresh_count,
                "last_result": var_to_str(cell.last_result),  # Convert to string
                "metadata": cell.metadata,
                "state": get_cell_state(x, y)
            }
    
    return serialized

func decompress_grid_data(filename: String) -> bool:
    # Decompress and load grid data from file
    var file = File.new()
    if not file.file_exists(filename):
        print("File does not exist: " + filename)
        return false
    
    print("Decompressing grid data from: " + filename)
    
    # Read and parse file
    file.open(filename, File.READ)
    var content = file.get_as_text()
    file.close()
    
    var json_result = JSON.parse(content)
    if json_result.error != OK:
        print("Error parsing grid data: " + json_result.error_string)
        return false
    
    var data = json_result.result
    
    # Validate data
    if not data.has("size") or not data.has("cells"):
        print("Invalid grid data format")
        return false
    
    # Resize grid if necessary
    var new_size = Vector2i(data.size.x, data.size.y)
    if new_size != grid_size:
        resize_grid(new_size)
    
    # Restore cell data
    for cell_id in data.cells:
        var cell_data = data.cells[cell_id]
        
        # Extract coordinates from cell_id
        var coords = cell_id.split("_")
        if coords.size() >= 3:
            var x = int(coords[1])
            var y = int(coords[2])
            
            if _validate_coordinates(x, y):
                # Restore cell data
                var cell = function_grid[x][y]
                cell.function_name = cell_data.function_name
                cell.last_refresh = cell_data.last_refresh
                cell.refresh_count = cell_data.refresh_count
                cell.last_result = str_to_var(cell_data.last_result)
                cell.metadata = cell_data.metadata
                
                # Restore state
                _set_cell_state(x, y, cell_data.state)
    
    print("Grid data decompressed and restored successfully")
    
    return true

# ----- TURN SYSTEM INTEGRATION -----
func on_turn_changed(turn_number: int, turn_data: Dictionary) -> void:
    # Called when the turn changes
    print("Turn changed to " + str(turn_number))
    
    # Special handling for turn changes
    if turn_number == 12:
        _on_final_turn()
    elif turn_number == 15:
        _on_turn15()
    
    # Refresh grid based on turn data
    if turn_data.has("flags") and turn_data.flags.has("grid_enabled") and turn_data.flags.grid_enabled:
        # Adjust grid size based on turn if needed
        if enable_dynamic_resizing:
            var new_size = Vector2i(
                min(turn_number, max_grid_size.x),
                min(turn_number, max_grid_size.y)
            )
            if new_size != grid_size:
                resize_grid(new_size)
        
        # Full refresh
        refresh_all()

func _on_final_turn():
    # Special handling for final turn
    print("Final turn activated - Compressing all grid data")
    
    # Apply compression to save all data
    compress_grid_data()
    
    # Enable special grid behavior
    staggered_refresh = true
    enable_per_cell_refresh_rates = true
    
    # Increase refresh rate
    refresh_interval = 30.0  # 30 seconds
    main_refresh_timer.wait_time = refresh_interval
    main_refresh_timer.start()

func _on_turn15():
    # Special handling for turn 15
    print("Turn 15 activated - Precision grid mode")
    
    # Dynamic resize to 15x15 grid if supported
    if enable_dynamic_resizing and max_grid_size.x >= 15 and max_grid_size.y >= 15:
        resize_grid(Vector2i(15, 15))
    
    # Set grid to maximum precision
    refresh_interval = 15.0  # 15 seconds
    main_refresh_timer.wait_time = refresh_interval
    main_refresh_timer.start()
    
    # Apply special pattern
    _full_grid_refresh_sequence()

# ----- PUBLIC API -----
func get_grid_size() -> Vector2i:
    return grid_size

func get_active_cell_count() -> int:
    var count = 0
    for cell_id in cell_states:
        if cell_states[cell_id] == CellState.ACTIVE:
            count += 1
    
    return count

func get_all_cells_data() -> Array:
    var cells_data = []
    
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            var cell = function_grid[x][y]
            cells_data.append({
                "x": x,
                "y": y,
                "function_name": cell.function_name,
                "state": get_cell_state(x, y),
                "last_refresh": cell.last_refresh,
                "refresh_count": cell.refresh_count
            })
    
    return cells_data

func highlight_cell(x: int, y: int) -> bool:
    if not _validate_coordinates(x, y):
        return false
    
    _set_cell_state(x, y, CellState.HIGHLIGHTED)
    
    # Visual feedback with blink controller if available
    if blink_controller:
        blink_controller.trigger_wink(_generate_cell_id(x, y))
    
    return true

func get_cell_by_name(function_name: String) -> Dictionary:
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            var cell = function_grid[x][y]
            if cell.function_name == function_name:
                return {
                    "x": x,
                    "y": y,
                    "cell": cell.duplicate()
                }
    
    return {}

func set_auto_refresh(enabled: bool) -> void:
    auto_refresh_enabled = enabled
    
    if auto_refresh_enabled:
        main_refresh_timer.start()
    else:
        main_refresh_timer.stop()
    
    print("Auto refresh " + ("enabled" if enabled else "disabled"))

func clear_grid() -> void:
    # Clear all functions from the grid
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            unregister_function(x, y)
    
    print("Grid cleared")

func register_built_in_functions() -> void:
    # Register some built-in utility functions
    
    # Register time function at 0,0
    register_function(0, 0, "get_time", func():
        return Time.get_time_string_from_system()
    )
    
    # Register random number function at 0,1
    register_function(0, 1, "get_random", func(min_val: int = 0, max_val: int = 100):
        return randi() % (max_val - min_val + 1) + min_val
    )
    
    # Register translation function at 1,0 if translation system is available
    if translation_system:
        register_function(1, 0, "translate", func(text: String, to_lang: String = "en"):
            var request_id = translation_system.translate(text, to_lang)
            return "Translation requested (ID: " + str(request_id) + ")"
        )
    
    # Register turn info function at 1,1 if turn controller is available
    if turn_controller:
        register_function(1, 1, "get_turn_info", func():
            return {
                "current_turn": turn_controller.get_current_turn(),
                "total_turns": turn_controller.get_total_turns(),
                "power": turn_controller.get_power_percentage() * 100
            }
        )
    
    print("Built-in functions registered")

func execute_function_by_name(function_name: String, args: Array = []) -> Variant:
    # Execute a function by name
    var cell_info = get_cell_by_name(function_name)
    
    if cell_info.empty():
        print("Function not found: " + function_name)
        return null
    
    return execute_function(cell_info.x, cell_info.y, args)

# ----- UTILITY FUNCTIONS -----
func get_cell_coordinates_from_id(cell_id: String) -> Vector2i:
    var parts = cell_id.split("_")
    if parts.size() >= 3:
        return Vector2i(int(parts[1]), int(parts[2]))
    
    return Vector2i(-1, -1)