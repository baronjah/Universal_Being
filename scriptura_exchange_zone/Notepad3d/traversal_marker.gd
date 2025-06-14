extends Node

class_name TraversalMarker

# Traversal Marker System
# Places claude.txt files in directories as you navigate them
# Similar to Minecraft signs marking explored territories

# Configuration
var config = {
    "marker_filename": "claude.txt",
    "marker_template": """
=== CLAUDE MARKER ===
Location: {location}
Visited: {timestamp}
Coordinates: {x}, {y}, {z}
Distance: {distance} blocks
Biome: {biome}
Notes: {notes}
=====================
""",
    "default_notes": "Explored this area. Potential for resources.",
    "world_origin": "/mnt/c/Users/Percision 15",
    "biomes": [
        "Forest", "Desert", "Mountains", "Ocean", "Plains", 
        "Jungle", "Swamp", "Tundra", "Savanna", "Taiga",
        "Terminal", "Data Sea", "Memory Cavern", "Project Peak", "Code Valley"
    ],
    "auto_place_markers": true,
    "marker_distance": 16  # Minimum blocks between markers
}

# Traversal state
var current_position = Vector3(0, 0, 0)
var current_location = ""
var visited_locations = {}
var placed_markers = []
var world_seed = 0
var traversal_history = []

# OCR calibration targets
var ocr_calibration_points = [
    {"x": 0, "y": 0, "z": 0, "text": "Origin Point"},
    {"x": 16, "y": 0, "z": 0, "text": "East Marker"},
    {"x": -16, "y": 0, "z": 0, "text": "West Marker"},
    {"x": 0, "y": 0, "z": 16, "text": "South Marker"},
    {"x": 0, "y": 0, "z": -16, "text": "North Marker"},
    {"x": 0, "y": 16, "z": 0, "text": "Sky Marker"},
    {"x": 0, "y": -16, "z": 0, "text": "Depth Marker"}
]

# References
var terminal = null
var visualizer = null

# Signals
signal marker_placed(location, coords)
signal territory_mapped(mapped_percentage)

# Initialize the marker system
func _ready():
    # Generate world seed based on date
    var date = Time.get_date_dict_from_unix_time(OS.get_unix_time())
    world_seed = date.year * 10000 + date.month * 100 + date.day
    
    # Set random seed for biome generation
    seed(world_seed)
    
    # Set current location to world origin
    current_location = config.world_origin
    
    # Mark origin as visited
    visited_locations[current_location] = {
        "coords": current_position,
        "timestamp": OS.get_unix_time(),
        "marker_placed": false
    }
    
    # Add calibration markers
    for point in ocr_calibration_points:
        var cal_position = Vector3(point.x, point.y, point.z)
        var cal_location = _position_to_path(cal_position)
        
        # Create directory if it doesn't exist
        _ensure_directory(cal_location)
        
        # Place marker with calibration text
        place_marker(cal_location, cal_position, point.text)

# Connect to terminal
func connect_terminal(term):
    terminal = term
    
    # Register commands
    terminal.register_command("mark", "Place a marker at current location", funcref(self, "_cmd_mark"), 0, "mark [notes]")
    terminal.register_command("explore", "Move to and explore a location", funcref(self, "_cmd_explore"), 1, "explore <path>")
    terminal.register_command("position", "Show current position", funcref(self, "_cmd_position"))
    terminal.register_command("map", "Show map of explored territories", funcref(self, "_cmd_map"))
    terminal.register_command("read", "Read marker at location", funcref(self, "_cmd_read"), 1, "read [location]")
    terminal.register_command("calibrate", "Place OCR calibration markers", funcref(self, "_cmd_calibrate"))
    
    return true

# Connect to visualizer
func connect_visualizer(vis):
    visualizer = vis
    
    # Register data source
    visualizer.register_data_source("traversal", "World Traversal", funcref(self, "_get_traversal_data"))
    
    return true

# Move to and explore a location
func explore_location(location):
    # If path is relative, make it absolute
    if not location.begins_with("/"):
        location = current_location.plus_file(location)
    
    # Normalize path
    location = location.simplify_path()
    
    # Check if location exists
    var dir = Directory.new()
    if not dir.dir_exists(location):
        return {
            "success": false,
            "error": "Location does not exist: " + location
        }
    
    # Calculate position for this location
    var new_position = _path_to_position(location)
    
    # Calculate movement
    var movement = new_position - current_position
    var distance = movement.length()
    
    # Update current location and position
    var old_location = current_location
    current_location = location
    current_position = new_position
    
    # Add to traversal history
    traversal_history.append({
        "from": old_location,
        "to": location,
        "distance": distance,
        "timestamp": OS.get_unix_time()
    })
    
    # Mark as visited
    visited_locations[location] = {
        "coords": current_position,
        "timestamp": OS.get_unix_time(),
        "marker_placed": false
    }
    
    # Auto-place marker if enabled and minimum distance met
    var marker_placed = false
    if config.auto_place_markers and distance >= config.marker_distance:
        marker_placed = place_marker(location, current_position)
    
    # List files in location
    var files = []
    
    if dir.open(location) == OK:
        dir.list_dir_begin(true, true)
        var file_name = dir.get_next()
        
        while file_name != "":
            if not dir.current_is_dir():
                files.append(file_name)
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    }
    
    # Calculate territory mapping percentage
    var mapping_percentage = float(visited_locations.size()) / 100.0  # Simplified calculation
    emit_signal("territory_mapped", mapping_percentage)
    
    return {
        "success": true,
        "location": location,
        "position": current_position,
        "distance": distance,
        "marker_placed": marker_placed,
        "files": files
    }

# Place a marker at a location
func place_marker(location, position = null, notes = null):
    # Use current position if not specified
    if position == null:
        position = current_position
    
    # Use default notes if not specified
    if notes == null:
        notes = config.default_notes
    
    # Ensure directory exists
    _ensure_directory(location)
    
    # Generate marker content
    var timestamp = Time.get_datetime_string_from_unix_time(OS.get_unix_time())
    var biome = _get_biome_for_position(position)
    var distance = position.length()  # Distance from origin
    
    var marker_content = config.marker_template.format({
        "location": location,
        "timestamp": timestamp,
        "x": position.x,
        "y": position.y,
        "z": position.z,
        "distance": distance,
        "biome": biome,
        "notes": notes
    })
    
    # Write marker file
    var marker_path = location.plus_file(config.marker_filename)
    var file = File.new()
    
    if file.open(marker_path, File.WRITE) != OK:
        push_error("Failed to write marker file: " + marker_path)
        return false
    
    file.store_string(marker_content)
    file.close()
    
    # Update visited location
    if visited_locations.has(location):
        visited_locations[location].marker_placed = true
    
    # Add to placed markers
    placed_markers.append({
        "location": location,
        "position": position,
        "timestamp": OS.get_unix_time(),
        "notes": notes,
        "biome": biome
    })
    
    # Emit signal
    emit_signal("marker_placed", location, position)
    
    return true

# Read a marker at a location
func read_marker(location):
    # If no location specified, use current location
    if location.empty():
        location = current_location
    
    # If path is relative, make it absolute
    if not location.begins_with("/"):
        location = current_location.plus_file(location)
    
    # Normalize path
    location = location.simplify_path()
    
    # Check if marker exists
    var marker_path = location.plus_file(config.marker_filename)
    var file = File.new()
    
    if not file.file_exists(marker_path):
        return {
            "success": false,
            "error": "No marker found at location: " + location
        }
    
    # Read marker content
    if file.open(marker_path, File.READ) != OK:
        return {
            "success": false,
            "error": "Failed to read marker file: " + marker_path
        }
    
    var content = file.get_as_text()
    file.close()
    
    return {
        "success": true,
        "location": location,
        "content": content
    }

# Get map of explored territories
func get_map():
    var map_data = {
        "origin": config.world_origin,
        "current": current_location,
        "current_position": current_position,
        "visited": visited_locations.size(),
        "markers": placed_markers.size(),
        "locations": []
    }
    
    # Add locations to map
    for location in visited_locations:
        var visited = visited_locations[location]
        
        map_data.locations.append({
            "path": location,
            "coords": visited.coords,
            "timestamp": visited.timestamp,
            "has_marker": visited.marker_placed,
            "distance": visited.coords.length()
        })
    
    return map_data

# Place OCR calibration markers
func place_calibration_markers():
    var placed_count = 0
    
    for point in ocr_calibration_points:
        var cal_position = Vector3(point.x, point.y, point.z)
        var cal_location = _position_to_path(cal_position)
        
        # Create directory if it doesn't exist
        _ensure_directory(cal_location)
        
        # Place marker with calibration text
        if place_marker(cal_location, cal_position, point.text):
            placed_count += 1
    
    return placed_count

# Calculate position from a path
func _path_to_position(path):
    # Get path relative to world origin
    var rel_path = path
    
    if path.begins_with(config.world_origin):
        rel_path = path.substr(config.world_origin.length())
    
    if rel_path.begins_with("/"):
        rel_path = rel_path.substr(1)
    
    # Split into path components
    var components = rel_path.split("/")
    
    # Start at origin
    var x = 0
    var y = 0
    var z = 0
    
    # Use path components to calculate position
    for i in range(components.size()):
        if components[i].empty():
            continue
        
        # Use component name to influence position
        var component_hash = _string_to_hash(components[i])
        
        # X component - use first digit
        x += ((component_hash % 100) / 10) * 4
        
        # Y component - use second digit
        y += (component_hash % 10) * 2
        
        # Z component - use depth
        z += i * 4
        
        # Add some variation based on component name
        var char_sum = 0
        for c in components[i]:
            char_sum += ord(c)
        
        # Apply some rotation based on depth
        var angle = PI * i / 8.0
        var rotated_x = x * cos(angle) - z * sin(angle)
        var rotated_z = x * sin(angle) + z * cos(angle)
        
        x = rotated_x + (char_sum % 8) - 4
        z = rotated_z + ((char_sum / 8) % 8) - 4
    }
    
    return Vector3(x, y, z)

# Calculate path from a position
func _position_to_path(position):
    # This is a simplified inverse of the above function
    # Just using coordinates for path components
    
    var path = config.world_origin
    
    path = path.plus_file("x" + str(int(position.x)))
    path = path.plus_file("y" + str(int(position.y)))
    path = path.plus_file("z" + str(int(position.z)))
    
    return path

# Get biome for a position
func _get_biome_for_position(position):
    # Use position to determine biome
    var fx = position.x * 0.1
    var fy = position.y * 0.1
    var fz = position.z * 0.1
    
    # Simplified Perlin noise approximation
    var value = sin(fx) * cos(fz) + sin(fy * 2.0)
    value = (value + 1.0) / 2.0  # Normalize to 0.0 - 1.0
    
    # Select biome based on value
    var biome_index = int(value * config.biomes.size()) % config.biomes.size()
    
    return config.biomes[biome_index]

# Ensure a directory exists
func _ensure_directory(path):
    var dir = Directory.new()
    
    if not dir.dir_exists(path):
        dir.make_dir_recursive(path)
    
    return dir.dir_exists(path)

# Generate a hash from a string
func _string_to_hash(str):
    var hash = 0
    
    for c in str:
        hash = ((hash << 5) - hash) + ord(c)
        hash = hash & 0xFFFFFFFF  # Convert to 32bit integer
    
    return abs(hash)

# Get traversal data for visualizer
func _get_traversal_data():
    var result = {
        "type": "traversal",
        "position": {
            "x": current_position.x,
            "y": current_position.y,
            "z": current_position.z
        },
        "locations_visited": visited_locations.size(),
        "markers_placed": placed_markers.size(),
        "current_biome": _get_biome_for_position(current_position),
        "mapping_completion": float(visited_locations.size()) / 100.0  # Simplified calculation
    }
    
    return result

# Terminal commands

func _cmd_mark(args):
    var notes = config.default_notes
    
    if args.size() > 0:
        notes = args.join(" ")
    
    var result = place_marker(current_location, current_position, notes)
    
    if result:
        return "Placed marker at " + current_location
    else:
        return "ERROR: Failed to place marker"

func _cmd_explore(args):
    if args.size() < 1:
        return "ERROR: Usage: explore <path>"
    
    var location = args[0]
    var result = explore_location(location)
    
    if not result.success:
        return "ERROR: " + result.error
    
    var output = "Explored " + result.location + "\n"
    output += "  Position: (" + str(result.position.x) + ", " + str(result.position.y) + ", " + str(result.position.z) + ")\n"
    output += "  Distance traveled: " + str(result.distance) + " blocks\n"
    
    if result.marker_placed:
        output += "  Placed a marker at this location\n"
    
    if result.files.size() > 0:
        output += "  Found " + str(result.files.size()) + " files"
    
    return output

func _cmd_position(args):
    var biome = _get_biome_for_position(current_position)
    var origin_distance = current_position.length()
    
    var output = "Current position:\n"
    output += "  Location: " + current_location + "\n"
    output += "  Coordinates: (" + str(current_position.x) + ", " + str(current_position.y) + ", " + str(current_position.z) + ")\n"
    output += "  Distance from origin: " + str(origin_distance) + " blocks\n"
    output += "  Biome: " + biome + "\n"
    output += "  Markers placed: " + str(placed_markers.size()) + "\n"
    output += "  Locations visited: " + str(visited_locations.size())
    
    return output

func _cmd_map(args):
    var map_data = get_map()
    var output = "World Map:\n"
    
    output += "  Origin: " + map_data.origin + "\n"
    output += "  Current location: " + map_data.current + "\n"
    output += "  Coordinates: (" + str(map_data.current_position.x) + ", " + str(map_data.current_position.y) + ", " + str(map_data.current_position.z) + ")\n"
    output += "  Locations visited: " + str(map_data.visited) + "\n"
    output += "  Markers placed: " + str(map_data.markers) + "\n\n"
    
    # Show locations sorted by distance
    map_data.locations.sort_custom(self, "_sort_by_distance")
    
    output += "Nearby locations:\n"
    
    for i in range(min(5, map_data.locations.size())):
        var loc = map_data.locations[i]
        var marker_status = loc.has_marker ? "📍" : "  "
        
        output += "  " + marker_status + " " + loc.path.get_file() + " (" + str(loc.distance) + " blocks)\n"
    
    return output

func _cmd_read(args):
    var location = ""
    
    if args.size() >= 1:
        location = args[0]
    
    var result = read_marker(location)
    
    if not result.success:
        return "ERROR: " + result.error
    
    return "Marker at " + result.location + ":\n" + result.content

func _cmd_calibrate(args):
    var count = place_calibration_markers()
    return "Placed " + str(count) + " calibration markers"

# Sort helper for locations by distance
func _sort_by_distance(a, b):
    return a.distance < b.distance