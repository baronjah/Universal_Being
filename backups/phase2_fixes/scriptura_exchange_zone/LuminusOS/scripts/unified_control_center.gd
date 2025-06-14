extends Node

class_name UnifiedControlCenter

# Unified Control Center for LuminusOS - Integrates multi-API, file management, picture viewing, and ASCII-based UI
# This serves as the central command point for your entire ecosystem

signal file_operation_completed(operation_type, source, destination)
signal api_request_completed(api_name, response)
signal visualization_changed(mode, parameters)
signal archive_completed(archive_id, success)
signal font_changed(font_name)

# Core systems
var api_controller = null
var archive_manager = null
var automation_system = null
var data_evolution_system = null

# File management
var current_directory = "/"
var selected_files = []
var file_clipboard = []
var clipboard_operation = "" # "copy" or "cut"
var recent_operations = []
var favorite_directories = []

# Picture viewer
var current_picture = null
var picture_zoom = 1.0
var picture_index = 0
var picture_list = []
var animation_player = null

# ASCII font system
var current_font = "default"
var available_fonts = {
    "default": {
        "A": ["  █  ", " █ █ ", "█████", "█   █", "█   █"],
        "B": ["████ ", "█   █", "████ ", "█   █", "████ "],
        # Full alphabet would be defined similarly
    },
    "blocky": {
        "A": ["▄▄▄▄▄", "█   █", "█████", "█   █", "█   █"],
        "B": ["████▄", "█   █", "████▄", "█   █", "████▄"],
        # Full alphabet would be defined similarly
    },
    "curved": {
        "A": [" ╭─╮ ", "│ │ ", "├─┤ ", "│ │ ", "╰ ╰ "],
        "B": ["╭──╮", "│  │", "├──┤", "│  │", "╰──╯"],
        # Full alphabet would be defined similarly
    }
}

# Multi-API system
var api_requests = {}
var api_keys = {}
var active_apis = []

# Turn-based system
var current_turn = 1
var max_turns = 12
var turn_names = ["Genesis", "Formation", "Complexity", "Consciousness", "Awakening", 
                 "Enlightenment", "Manifestation", "Connection", "Harmony", 
                 "Transcendence", "Unity", "Beyond"]

# UI state
var current_view = "files" # files, pictures, api, archive
var split_screen = false
var left_panel_size = 0.3 # 30% of screen width

func _ready():
    print("Unified Control Center initializing...")
    
    # Connect to essential systems
    _connect_to_systems()
    
    # Initialize animation player for transitions
    animation_player = AnimationPlayer.new()
    add_child(animation_player)
    _setup_animations()
    
    # Load favorite directories
    _load_favorites()
    
    # Initialize turn system
    _load_current_turn()
    
    print("Unified Control Center initialized")

# File management functions

func list_files(dir_path=null):
    if dir_path == null:
        dir_path = current_directory
    
    var file_list = []
    var dir = DirAccess.open(dir_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            var is_dir = dir.current_is_dir()
            var file_data = {
                "name": file_name,
                "is_directory": is_dir,
                "path": dir_path.path_join(file_name),
                "selected": false
            }
            
            if !is_dir:
                # Get file info
                var file_stat = FileAccess.get_modified_time(file_data.path)
                file_data["modified"] = file_stat
                file_data["size"] = FileAccess.get_file_size(file_data.path)
                file_data["extension"] = file_name.get_extension().to_lower()
                
                # Determine file type
                if ["png", "jpg", "jpeg", "webp", "gif"].has(file_data.extension):
                    file_data["type"] = "image"
                elif ["mp4", "webm", "mkv"].has(file_data.extension):
                    file_data["type"] = "video"
                elif ["mp3", "wav", "ogg"].has(file_data.extension):
                    file_data["type"] = "audio"
                elif ["txt", "md", "gd", "py", "js", "html", "css"].has(file_data.extension):
                    file_data["type"] = "text"
                else:
                    file_data["type"] = "file"
            
            file_list.append(file_data)
            file_name = dir.get_next()
        
        dir.list_dir_end()
        
        # Sort: directories first, then files alphabetically
        file_list.sort_custom(func(a, b): 
            if a.is_directory and not b.is_directory:
                return true
            elif not a.is_directory and b.is_directory:
                return false
            else:
                return a.name.to_lower() < b.name.to_lower()
        )
    
    current_directory = dir_path
    return file_list

func create_directory(dir_name):
    var new_dir_path = current_directory.path_join(dir_name)
    var dir = DirAccess.open(current_directory)
    
    if dir:
        var err = dir.make_dir(dir_name)
        if err == OK:
            recent_operations.append({
                "type": "create_directory",
                "path": new_dir_path,
                "timestamp": Time.get_unix_time_from_system()
            })
            emit_signal("file_operation_completed", "create_directory", "", new_dir_path)
            return "Directory created: " + dir_name
        else:
            return "Failed to create directory: " + error_string(err)
    
    return "Failed to access current directory"

func copy_files(files, destination):
    if files.size() == 0:
        return "No files selected"
    
    var success_count = 0
    var dest_dir = DirAccess.open(destination)
    
    if not dest_dir:
        return "Cannot access destination directory"
    
    for file_path in files:
        var file_name = file_path.get_file()
        var dest_path = destination.path_join(file_name)
        
        # Check if file or directory
        if DirAccess.dir_exists_absolute(file_path):
            # Copy directory recursively
            success_count += _copy_directory_recursive(file_path, dest_path)
        else:
            # Copy file
            var err = DirAccess.copy_absolute(file_path, dest_path)
            if err == OK:
                success_count += 1
            
    recent_operations.append({
        "type": "copy",
        "files": files,
        "destination": destination,
        "timestamp": Time.get_unix_time_from_system()
    })
    
    emit_signal("file_operation_completed", "copy", files, destination)
    return "Copied " + str(success_count) + " of " + str(files.size()) + " files"

func move_files(files, destination):
    if files.size() == 0:
        return "No files selected"
    
    var success_count = 0
    var dest_dir = DirAccess.open(destination)
    
    if not dest_dir:
        return "Cannot access destination directory"
    
    for file_path in files:
        var file_name = file_path.get_file()
        var dest_path = destination.path_join(file_name)
        
        # Check if file or directory
        if DirAccess.dir_exists_absolute(file_path):
            # Move directory
            var err = DirAccess.rename_absolute(file_path, dest_path)
            if err == OK:
                success_count += 1
        else:
            # Move file
            var err = DirAccess.rename_absolute(file_path, dest_path)
            if err == OK:
                success_count += 1
    
    recent_operations.append({
        "type": "move",
        "files": files,
        "destination": destination,
        "timestamp": Time.get_unix_time_from_system()
    })
    
    emit_signal("file_operation_completed", "move", files, destination)
    return "Moved " + str(success_count) + " of " + str(files.size()) + " files"

func rename_file(old_path, new_name):
    var dir_path = old_path.get_base_dir()
    var new_path = dir_path.path_join(new_name)
    
    var err = DirAccess.rename_absolute(old_path, new_path)
    if err == OK:
        recent_operations.append({
            "type": "rename",
            "old_path": old_path,
            "new_path": new_path,
            "timestamp": Time.get_unix_time_from_system()
        })
        
        emit_signal("file_operation_completed", "rename", old_path, new_path)
        return "Renamed to: " + new_name
    else:
        return "Failed to rename file: " + error_string(err)

func delete_files(files):
    if files.size() == 0:
        return "No files selected"
    
    var success_count = 0
    
    for file_path in files:
        # Check if file or directory
        if DirAccess.dir_exists_absolute(file_path):
            # Remove directory recursively
            var err = _remove_directory_recursive(file_path)
            if err == OK:
                success_count += 1
        else:
            # Remove file
            var err = DirAccess.remove_absolute(file_path)
            if err == OK:
                success_count += 1
    
    recent_operations.append({
        "type": "delete",
        "files": files,
        "timestamp": Time.get_unix_time_from_system()
    })
    
    emit_signal("file_operation_completed", "delete", files, "")
    return "Deleted " + str(success_count) + " of " + str(files.size()) + " files"

func add_to_favorites(dir_path):
    if not favorite_directories.has(dir_path):
        favorite_directories.append(dir_path)
        _save_favorites()
        return "Added to favorites: " + dir_path
    
    return "Already in favorites"

func remove_from_favorites(dir_path):
    if favorite_directories.has(dir_path):
        favorite_directories.erase(dir_path)
        _save_favorites()
        return "Removed from favorites: " + dir_path
    
    return "Not in favorites"

# Picture viewer functions

func load_image(image_path):
    if FileAccess.file_exists(image_path):
        var image = Image.new()
        var err = image.load(image_path)
        
        if err == OK:
            current_picture = {
                "path": image_path,
                "image": image,
                "texture": ImageTexture.create_from_image(image),
                "size": Vector2(image.get_width(), image.get_height())
            }
            
            # Reset zoom and position
            picture_zoom = 1.0
            
            # Update picture list if needed
            if picture_list.size() == 0 or not picture_list.has(image_path):
                _update_picture_list()
            
            picture_index = picture_list.find(image_path)
            
            emit_signal("visualization_changed", "picture", {"path": image_path})
            return "Loaded image: " + image_path.get_file()
        else:
            return "Failed to load image: " + error_string(err)
    
    return "File not found: " + image_path

func next_picture():
    if picture_list.size() <= 1:
        return "No more images"
    
    picture_index = (picture_index + 1) % picture_list.size()
    load_image(picture_list[picture_index])
    return "Next image"

func previous_picture():
    if picture_list.size() <= 1:
        return "No more images"
    
    picture_index = (picture_index - 1 + picture_list.size()) % picture_list.size()
    load_image(picture_list[picture_index])
    return "Previous image"

func set_zoom(zoom_level):
    picture_zoom = clamp(zoom_level, 0.1, 5.0)
    emit_signal("visualization_changed", "zoom", {"level": picture_zoom})
    return "Zoom set to " + str(int(picture_zoom * 100)) + "%"

# ASCII font rendering functions

func set_font(font_name):
    if available_fonts.has(font_name):
        current_font = font_name
        emit_signal("font_changed", font_name)
        return "Font changed to: " + font_name
    
    return "Font not found: " + font_name

func render_text_ascii(text, font_name=null):
    if font_name == null:
        font_name = current_font
    
    if not available_fonts.has(font_name):
        font_name = "default"
    
    var font = available_fonts[font_name]
    var result = []
    
    # Initialize lines for each row in the font
    for i in range(5):  # Assuming 5 rows per character
        result.append("")
    
    # Add each character
    for c in text.to_upper():
        if c == " ":
            # Handle space
            for i in range(5):
                result[i] += "     "
        elif font.has(c):
            # Add character from font
            for i in range(5):
                result[i] += font[c][i]
        else:
            # Unknown character, add blank
            for i in range(5):
                result[i] += "     "
    
    return result

# API management functions

func call_api(api_name, prompt):
    if api_controller == null:
        return "API controller not available"
    
    # Store request information
    var request_id = "req_" + str(Time.get_unix_time_from_system())
    api_requests[request_id] = {
        "api": api_name,
        "prompt": prompt,
        "timestamp": Time.get_unix_time_from_system(),
        "status": "pending"
    }
    
    # Connect signal if not already connected
    if not api_controller.is_connected("api_response_received", Callable(self, "_on_api_response")):
        api_controller.connect("api_response_received", Callable(self, "_on_api_response"))
    
    # Call API
    api_controller.call_api(api_name, prompt)
    
    return "API request sent to " + api_name

func add_api_key(api_name, key):
    api_keys[api_name] = {
        "key": key,
        "added": Time.get_unix_time_from_system()
    }
    
    if not active_apis.has(api_name):
        active_apis.append(api_name)
    
    # Todo: Apply the key to the API controller
    
    return "API key added for " + api_name

func get_api_list():
    var list = []
    
    if api_controller != null:
        list = api_controller.apis.keys()
    
    return list

# Archive and backup functions

func create_archive(type, name):
    if archive_manager == null:
        return "Archive manager not available"
    
    var result = ""
    match type:
        "tick":
            result = archive_manager.create_tick_archive(true)
        "hour":
            result = archive_manager.create_hour_archive()
        "day":
            result = archive_manager.create_day_archive()
        "week":
            result = archive_manager.create_week_archive()
        _:
            return "Unknown archive type: " + type
    
    return result

func restore_archive(archive_id):
    if archive_manager == null:
        return "Archive manager not available"
    
    return archive_manager.restore_from_archive(archive_id)

func list_archives(type="all", count=10):
    if archive_manager == null:
        return "Archive manager not available"
    
    return archive_manager.list_archives(type, count)

# Turn system functions

func advance_turn():
    current_turn = (current_turn % max_turns) + 1
    _save_current_turn()
    
    # Update systems to reflect turn change
    if data_evolution_system != null:
        # Trigger evolution check
        data_evolution_system._run_pattern_detection()
    
    return "Advanced to Turn " + str(current_turn) + ": " + turn_names[current_turn-1]

func get_turn_info():
    var result = "Current Turn: " + str(current_turn) + " - " + turn_names[current_turn-1] + "\n"
    result += "Progress: " + str(int(current_turn * 100.0 / max_turns)) + "%\n"
    
    # Add turn-specific information
    match current_turn:
        1: # Genesis
            result += "\nThe beginning of all things; raw potential emerges from void."
        2: # Formation
            result += "\nBasic structures take shape; foundational elements are created."
        3: # Complexity
            result += "\nSystems begin interacting; complexity arises from simplicity."
        4: # Consciousness
            result += "\nAwareness arises within systems; first feedback loops form."
        5: # Awakening
            result += "\nRecognition of self and other; boundaries begin to form."
        6: # Enlightenment
            result += "\nUnderstanding connections between all elements; insight emerges."
        7: # Manifestation
            result += "\nBringing forth creation from thought; ideas become reality."
        8: # Connection
            result += "\nBuilding relationships between created elements; networks form."
        9: # Harmony
            result += "\nBalance between all created elements; systems stabilize."
        10: # Transcendence
            result += "\nAll becomes one; unification of created elements."
        11: # Unity
            result += "\nRising beyond initial limitations; transformation occurs."
        12: # Beyond
            result += "\nMoving beyond the current cycle; preparation for renewal."
    
    return result

# UI command processing

func process_command(command_line):
    var parts = command_line.strip_edges().split(" ", false)
    if parts.size() == 0:
        return "No command specified"
    
    var command = parts[0].to_lower()
    var args = parts.slice(1)
    
    match command:
        # File commands
        "ls", "dir":
            return _cmd_list_files(args)
        "cd":
            return _cmd_change_directory(args)
        "mkdir":
            return _cmd_make_directory(args)
        "cp", "copy":
            return _cmd_copy(args)
        "mv", "move":
            return _cmd_move(args)
        "rm", "del":
            return _cmd_delete(args)
        "rename":
            return _cmd_rename(args)
        "select":
            return _cmd_select_files(args)
        "deselect":
            return _cmd_deselect_files(args)
        "fav", "favorite":
            return _cmd_favorites(args)
        
        # View commands
        "view":
            return _cmd_view(args)
        "show":
            return _cmd_show(args)
        "zoom":
            return _cmd_zoom(args)
        
        # Font commands
        "font":
            return _cmd_font(args)
        "ascii":
            return _cmd_ascii(args)
        
        # API commands
        "api":
            return _cmd_api(args)
        
        # Archive commands
        "archive":
            return _cmd_archive(args)
        
        # Turn commands
        "turn":
            return _cmd_turn(args)
        
        # System commands
        "split":
            return _cmd_split_screen(args)
        "evolve":
            if data_evolution_system != null:
                return data_evolution_system.cmd_evolve(args)
            return "Data evolution system not available"
        "auto":
            if automation_system != null:
                return automation_system.cmd_auto(args)
            return "Automation system not available"
        "help":
            return _cmd_help(args)
        
        _:
            return "Unknown command: " + command

# Helper functions and command implementations

func _copy_directory_recursive(src_dir, dst_dir):
    var count = 0
    var dir = DirAccess.open(src_dir)
    
    if dir:
        # Create destination directory
        DirAccess.make_dir_recursive_absolute(dst_dir)
        
        # Copy all files and subdirectories
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            var src_path = src_dir.path_join(file_name)
            var dst_path = dst_dir.path_join(file_name)
            
            if dir.current_is_dir():
                # Recursively copy subdirectory
                count += _copy_directory_recursive(src_path, dst_path)
            else:
                # Copy file
                var err = DirAccess.copy_absolute(src_path, dst_path)
                if err == OK:
                    count += 1
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    return count

func _remove_directory_recursive(dir_path):
    var dir = DirAccess.open(dir_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            var full_path = dir_path.path_join(file_name)
            
            if dir.current_is_dir():
                # Recursively remove subdirectory
                _remove_directory_recursive(full_path)
            else:
                # Remove file
                DirAccess.remove_absolute(full_path)
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
        
        # Remove the empty directory
        return DirAccess.remove_absolute(dir_path)
    
    return ERR_CANT_OPEN

func _update_picture_list():
    picture_list = []
    
    var all_files = list_files(current_directory)
    for file in all_files:
        if not file.is_directory and file.has("type") and file.type == "image":
            picture_list.append(file.path)

func _connect_to_systems():
    # Try to get references to required systems
    api_controller = get_node_or_null("/root/ApiController")
    if api_controller:
        print("Connected to API Controller")
    
    archive_manager = get_node_or_null("/root/ArchiveManager")
    if archive_manager:
        print("Connected to Archive Manager")
    
    automation_system = get_node_or_null("/root/AutomationSystem")
    if automation_system:
        print("Connected to Automation System")
    
    data_evolution_system = get_node_or_null("/root/DataEvolutionSystem")
    if data_evolution_system:
        print("Connected to Data Evolution System")

func _setup_animations():
    # Create animations for transitions
    var fade_animation = Animation.new()
    var track_index = fade_animation.add_track(Animation.TYPE_VALUE)
    fade_animation.track_set_path(track_index, ".:modulate:a")
    fade_animation.track_insert_key(track_index, 0.0, 0.0)
    fade_animation.track_insert_key(track_index, 0.5, 1.0)
    animation_player.add_animation("fade_in", fade_animation)
    
    var fade_out = fade_animation.duplicate()
    track_index = fade_out.get_track_count() - 1
    fade_out.track_set_path(track_index, ".:modulate:a")
    fade_out.track_insert_key(track_index, 0.0, 1.0)
    fade_out.track_insert_key(track_index, 0.5, 0.0)
    animation_player.add_animation("fade_out", fade_out)

func _load_favorites():
    var config_path = "user://favorites.cfg"
    if FileAccess.file_exists(config_path):
        var file = FileAccess.open(config_path, FileAccess.READ)
        while not file.eof_reached():
            var line = file.get_line().strip_edges()
            if line != "" and DirAccess.dir_exists_absolute(line):
                favorite_directories.append(line)
        file.close()

func _save_favorites():
    var config_path = "user://favorites.cfg"
    var file = FileAccess.open(config_path, FileAccess.WRITE)
    for dir_path in favorite_directories:
        file.store_line(dir_path)
    file.close()

func _load_current_turn():
    var config_path = "user://current_turn.cfg"
    if FileAccess.file_exists(config_path):
        var file = FileAccess.open(config_path, FileAccess.READ)
        var content = file.get_line().strip_edges()
        file.close()
        
        if content.is_valid_int():
            current_turn = content.to_int()
            current_turn = clamp(current_turn, 1, max_turns)

func _save_current_turn():
    var config_path = "user://current_turn.cfg"
    var file = FileAccess.open(config_path, FileAccess.WRITE)
    file.store_line(str(current_turn))
    file.close()

func _on_api_response(api_name, response):
    # Find the request for this response
    var request_id = ""
    for id in api_requests:
        if api_requests[id].api == api_name and api_requests[id].status == "pending":
            request_id = id
            break
    
    if request_id != "":
        api_requests[request_id].status = "completed"
        api_requests[request_id].response = response
        api_requests[request_id].completed_at = Time.get_unix_time_from_system()
    
    emit_signal("api_request_completed", api_name, response)

# Command implementations

func _cmd_list_files(args):
    var path = current_directory
    if args.size() > 0:
        path = args[0]
        if not path.begins_with("/"):
            path = current_directory.path_join(path)
    
    var files = list_files(path)
    var result = "Directory: " + path + "\n\n"
    
    for file in files:
        var name = file.name
        if file.is_directory:
            name += "/"
            result += "[DIR] " + name + "\n"
        else:
            var size_text = ""
            if file.has("size"):
                size_text = " (" + _format_size(file.size) + ")"
            result += "[" + file.type.to_upper() + "] " + name + size_text + "\n"
    
    return result

func _cmd_change_directory(args):
    if args.size() == 0:
        return "Usage: cd <directory>"
    
    var path = args[0]
    if path == "..":
        path = current_directory.get_base_dir()
    elif path == "~":
        path = "/mnt/c/Users/Percision 15"
    elif not path.begins_with("/"):
        path = current_directory.path_join(path)
    
    if DirAccess.dir_exists_absolute(path):
        current_directory = path
        return "Changed directory to: " + path
    else:
        return "Directory not found: " + path

func _cmd_make_directory(args):
    if args.size() == 0:
        return "Usage: mkdir <directory_name>"
    
    return create_directory(args[0])

func _cmd_copy(args):
    if args.size() < 2:
        return "Usage: copy <source> <destination>"
    
    var source = args[0]
    var destination = args[1]
    
    if not source.begins_with("/"):
        source = current_directory.path_join(source)
    
    if not destination.begins_with("/"):
        destination = current_directory.path_join(destination)
    
    # Check if this is a single file or directory
    if FileAccess.file_exists(source) or DirAccess.dir_exists_absolute(source):
        return copy_files([source], destination)
    else:
        return "Source file not found: " + source

func _cmd_move(args):
    if args.size() < 2:
        return "Usage: move <source> <destination>"
    
    var source = args[0]
    var destination = args[1]
    
    if not source.begins_with("/"):
        source = current_directory.path_join(source)
    
    if not destination.begins_with("/"):
        destination = current_directory.path_join(destination)
    
    # Check if this is a single file or directory
    if FileAccess.file_exists(source) or DirAccess.dir_exists_absolute(source):
        return move_files([source], destination)
    else:
        return "Source file not found: " + source

func _cmd_delete(args):
    if args.size() == 0:
        return "Usage: rm <file_or_directory>"
    
    var path = args[0]
    if not path.begins_with("/"):
        path = current_directory.path_join(path)
    
    if FileAccess.file_exists(path) or DirAccess.dir_exists_absolute(path):
        return delete_files([path])
    else:
        return "File not found: " + path

func _cmd_rename(args):
    if args.size() < 2:
        return "Usage: rename <old_name> <new_name>"
    
    var old_name = args[0]
    var new_name = args[1]
    
    if not old_name.begins_with("/"):
        old_name = current_directory.path_join(old_name)
    
    if FileAccess.file_exists(old_name) or DirAccess.dir_exists_absolute(old_name):
        return rename_file(old_name, new_name)
    else:
        return "File not found: " + old_name

func _cmd_select_files(args):
    if args.size() == 0:
        return "Usage: select <file_pattern>"
    
    var pattern = args[0]
    var files = list_files()
    var selected = []
    
    for file in files:
        if pattern == "*" or file.name.match(pattern):
            selected_files.append(file.path)
            selected.append(file.name)
    
    if selected.size() > 0:
        return "Selected " + str(selected.size()) + " files: " + ", ".join(selected)
    else:
        return "No files matched pattern: " + pattern

func _cmd_deselect_files(args):
    if args.size() == 0:
        selected_files.clear()
        return "All files deselected"
    
    var pattern = args[0]
    var deselected = []
    
    var new_selection = []
    for path in selected_files:
        var file_name = path.get_file()
        if pattern == "*" or file_name.match(pattern):
            deselected.append(file_name)
        else:
            new_selection.append(path)
    
    selected_files = new_selection
    
    if deselected.size() > 0:
        return "Deselected " + str(deselected.size()) + " files: " + ", ".join(deselected)
    else:
        return "No selected files matched pattern: " + pattern

func _cmd_favorites(args):
    if args.size() == 0:
        # List favorites
        var result = "Favorite Directories:\n"
        for i in range(favorite_directories.size()):
            result += str(i+1) + ". " + favorite_directories[i] + "\n"
        return result
    
    var subcommand = args[0]
    match subcommand:
        "add":
            if args.size() < 2:
                return add_to_favorites(current_directory)
            
            var path = args[1]
            if not path.begins_with("/"):
                path = current_directory.path_join(path)
            
            return add_to_favorites(path)
        
        "remove":
            if args.size() < 2:
                return "Usage: fav remove <path_or_number>"
            
            var arg = args[1]
            if arg.is_valid_int():
                var index = arg.to_int() - 1
                if index >= 0 and index < favorite_directories.size():
                    var path = favorite_directories[index]
                    return remove_from_favorites(path)
                else:
                    return "Invalid favorite index"
            else:
                var path = arg
                if not path.begins_with("/"):
                    path = current_directory.path_join(path)
                
                return remove_from_favorites(path)
        
        "goto":
            if args.size() < 2:
                return "Usage: fav goto <number>"
            
            var index_str = args[1]
            if index_str.is_valid_int():
                var index = index_str.to_int() - 1
                if index >= 0 and index < favorite_directories.size():
                    var path = favorite_directories[index]
                    current_directory = path
                    return "Changed directory to: " + path
                else:
                    return "Invalid favorite index"
            else:
                return "Invalid index: " + index_str
        
        _:
            return "Unknown favorites command. Use add, remove, or goto"

func _cmd_view(args):
    if args.size() == 0:
        return "Usage: view <file_path>"
    
    var path = args[0]
    if not path.begins_with("/"):
        path = current_directory.path_join(path)
    
    if FileAccess.file_exists(path):
        var ext = path.get_extension().to_lower()
        if ["png", "jpg", "jpeg", "webp", "gif"].has(ext):
            current_view = "pictures"
            return load_image(path)
        elif ["txt", "md", "gd", "py", "js", "html", "css"].has(ext):
            current_view = "files"
            var file = FileAccess.open(path, FileAccess.READ)
            var content = file.get_as_text()
            file.close()
            return "File: " + path.get_file() + "\n\n" + content
        else:
            return "Cannot view file type: " + ext
    else:
        return "File not found: " + path

func _cmd_show(args):
    if args.size() == 0:
        return "Usage: show <files|pictures|api|archive>"
    
    var view_type = args[0].to_lower()
    match view_type:
        "files", "file":
            current_view = "files"
            return "Switched to file view"
        "pictures", "picture", "images", "image":
            current_view = "pictures"
            return "Switched to picture view"
        "api", "apis":
            current_view = "api"
            return "Switched to API view"
        "archive", "archives":
            current_view = "archive"
            return "Switched to archive view"
        _:
            return "Unknown view type: " + view_type

func _cmd_zoom(args):
    if args.size() == 0:
        return "Current zoom: " + str(int(picture_zoom * 100)) + "%"
    
    var zoom_arg = args[0]
    if zoom_arg.is_valid_float():
        var zoom = zoom_arg.to_float()
        if zoom <= 0:
            return "Zoom must be greater than 0"
        
        return set_zoom(zoom)
    elif zoom_arg == "in":
        return set_zoom(picture_zoom * 1.2)
    elif zoom_arg == "out":
        return set_zoom(picture_zoom / 1.2)
    elif zoom_arg == "reset":
        return set_zoom(1.0)
    else:
        return "Invalid zoom value: " + zoom_arg

func _cmd_font(args):
    if args.size() == 0:
        var result = "Available fonts:\n"
        for font_name in available_fonts:
            result += "- " + font_name + (font_name == current_font ? " (active)" : "") + "\n"
        return result
    
    var font_name = args[0]
    return set_font(font_name)

func _cmd_ascii(args):
    if args.size() == 0:
        return "Usage: ascii <text> [font]"
    
    var text = args[0]
    var font_name = current_font
    
    if args.size() > 1 and available_fonts.has(args[1]):
        font_name = args[1]
    
    var result = ""
    var ascii_lines = render_text_ascii(text, font_name)
    
    for line in ascii_lines:
        result += line + "\n"
    
    return result

func _cmd_api(args):
    if args.size() == 0:
        return "API Commands:\n" +\
               "api list - List available APIs\n" +\
               "api call <api_name> <prompt> - Call API with prompt\n" +\
               "api key <api_name> <key> - Set API key\n" +\
               "api history - View recent API requests"
    
    var subcommand = args[0]
    match subcommand:
        "list":
            var apis = get_api_list()
            if apis.size() == 0:
                return "No APIs available"
            
            var result = "Available APIs:\n"
            for api in apis:
                result += "- " + api + "\n"
            return result
        
        "call":
            if args.size() < 3:
                return "Usage: api call <api_name> <prompt>"
            
            var api_name = args[1]
            var prompt = " ".join(args.slice(2))
            return call_api(api_name, prompt)
        
        "key":
            if args.size() < 3:
                return "Usage: api key <api_name> <key>"
            
            var api_name = args[1]
            var key = args[2]
            return add_api_key(api_name, key)
        
        "history":
            var result = "Recent API Requests:\n\n"
            var count = 0
            
            for req_id in api_requests:
                var request = api_requests[req_id]
                var time_str = _format_time_ago(request.timestamp)
                
                result += "Request to " + request.api + " (" + time_str + ")\n"
                result += "Status: " + request.status + "\n"
                result += "Prompt: " + request.prompt + "\n"
                
                if request.status == "completed" and request.has("response"):
                    result += "Response: " + request.response.substr(0, 100)
                    if request.response.length() > 100:
                        result += "... (truncated, " + str(request.response.length()) + " chars)"
                    result += "\n"
                
                result += "\n"
                count += 1
                
                if count >= 5:
                    break
            
            if count == 0:
                return "No API requests in history"
            
            return result
        
        _:
            return "Unknown API command: " + subcommand

func _cmd_archive(args):
    if archive_manager == null:
        return "Archive manager not available"
    
    if args.size() == 0:
        return archive_manager.cmd_archive(args)
    
    # Pass through to archive manager
    return archive_manager.cmd_archive(args)

func _cmd_turn(args):
    if args.size() == 0:
        return get_turn_info()
    
    var subcommand = args[0]
    match subcommand:
        "next", "advance":
            return advance_turn()
        
        "set":
            if args.size() < 2 or not args[1].is_valid_int():
                return "Usage: turn set <number>"
            
            var turn = args[1].to_int()
            if turn < 1 or turn > max_turns:
                return "Turn must be between 1 and " + str(max_turns)
            
            current_turn = turn
            _save_current_turn()
            return "Turn set to " + str(turn) + ": " + turn_names[turn-1]
        
        "list":
            var result = "Turn System (12 Turns):\n\n"
            for i in range(max_turns):
                var turn = i + 1
                var status = " "
                if turn < current_turn:
                    status = "✓"
                elif turn == current_turn:
                    status = "►"
                
                result += "[" + status + "] " + str(turn) + ". " + turn_names[i] + "\n"
            
            return result
        
        _:
            return "Unknown turn command: " + subcommand

func _cmd_split_screen(args):
    if args.size() == 0:
        split_screen = !split_screen
        return "Split screen " + ("enabled" if split_screen else "disabled")
    
    var arg = args[0].to_lower()
    match arg:
        "on", "true", "1", "enable":
            split_screen = true
            return "Split screen enabled"
        "off", "false", "0", "disable":
            split_screen = false
            return "Split screen disabled"
        _:
            if arg.is_valid_float():
                var size = arg.to_float()
                if size <= 0 or size >= 1:
                    return "Split size must be between 0 and 1"
                
                left_panel_size = size
                split_screen = true
                return "Split screen enabled with left panel size: " + str(int(size * 100)) + "%"
            else:
                return "Invalid split screen command: " + arg

func _cmd_help(args):
    if args.size() == 0:
        return "Available Commands:\n\n" +\
               "File Management:\n" +\
               "  ls, dir - List files\n" +\
               "  cd - Change directory\n" +\
               "  mkdir - Create directory\n" +\
               "  cp, copy - Copy files\n" +\
               "  mv, move - Move files\n" +\
               "  rm, del - Delete files\n" +\
               "  rename - Rename file\n" +\
               "  select - Select files with pattern\n" +\
               "  deselect - Deselect files\n" +\
               "  fav - Manage favorite directories\n\n" +\
               "Views and Visualization:\n" +\
               "  view - View file contents\n" +\
               "  show - Switch between view modes\n" +\
               "  zoom - Control picture zoom\n" +\
               "  font - Select ASCII font\n" +\
               "  ascii - Render text in ASCII art\n\n" +\
               "API Management:\n" +\
               "  api - API commands\n\n" +\
               "Archive and Turn System:\n" +\
               "  archive - Manage archives\n" +\
               "  turn - Control turn system\n\n" +\
               "System Controls:\n" +\
               "  split - Toggle split screen\n" +\
               "  evolve - Data evolution commands\n" +\
               "  auto - Automation controls\n" +\
               "  help - Show help information"
    
    var topic = args[0].to_lower()
    match topic:
        "files", "file":
            return "File Management Commands:\n\n" +\
                   "ls, dir [path] - List files in directory\n" +\
                   "cd <path> - Change directory\n" +\
                   "cd .. - Go up one directory\n" +\
                   "cd ~ - Go to home directory\n" +\
                   "mkdir <name> - Create directory\n" +\
                   "cp, copy <source> <destination> - Copy file or directory\n" +\
                   "mv, move <source> <destination> - Move file or directory\n" +\
                   "rm, del <path> - Delete file or directory\n" +\
                   "rename <old_name> <new_name> - Rename file\n" +\
                   "select <pattern> - Select files matching pattern\n" +\
                   "select * - Select all files\n" +\
                   "deselect [pattern] - Deselect files\n" +\
                   "fav - List favorite directories\n" +\
                   "fav add [path] - Add directory to favorites\n" +\
                   "fav remove <path_or_number> - Remove from favorites\n" +\
                   "fav goto <number> - Go to favorite directory"
        
        "view", "visualization":
            return "View and Visualization Commands:\n\n" +\
                   "view <file_path> - View file contents\n" +\
                   "show files - Switch to file view\n" +\
                   "show pictures - Switch to picture view\n" +\
                   "show api - Switch to API view\n" +\
                   "show archive - Switch to archive view\n" +\
                   "zoom - Display current zoom level\n" +\
                   "zoom <value> - Set zoom level\n" +\
                   "zoom in - Zoom in\n" +\
                   "zoom out - Zoom out\n" +\
                   "zoom reset - Reset zoom to 1.0"
        
        "font", "ascii":
            return "Font and ASCII Art Commands:\n\n" +\
                   "font - List available fonts\n" +\
                   "font <name> - Switch to font\n" +\
                   "ascii <text> [font] - Render text in ASCII art\n" +\
                   "Available fonts: default, blocky, curved"
        
        "api":
            return "API Management Commands:\n\n" +\
                   "api list - List available APIs\n" +\
                   "api call <api_name> <prompt> - Call API with prompt\n" +\
                   "api key <api_name> <key> - Set API key\n" +\
                   "api history - View recent API requests"
        
        "archive":
            return "Archive Commands:\n\n" +\
                   "archive - Show available commands\n" +\
                   "archive tick - Create a manual tick archive\n" +\
                   "archive hour - Create a manual hourly archive\n" +\
                   "archive day - Create a manual daily archive\n" +\
                   "archive week - Create a manual weekly archive\n" +\
                   "archive list [type] [count] - List archives\n" +\
                   "archive restore <archive_id> - Restore from archive\n" +\
                   "archive stats - Show archive statistics\n" +\
                   "archive verify <archive_id> - Verify archive integrity\n" +\
                   "archive clean [type] - Clean up old archives"
        
        "turn":
            return "Turn System Commands:\n\n" +\
                   "turn - Display current turn information\n" +\
                   "turn next, turn advance - Advance to next turn\n" +\
                   "turn set <number> - Set specific turn\n" +\
                   "turn list - List all turns"
        
        "split", "screen":
            return "Split Screen Commands:\n\n" +\
                   "split - Toggle split screen view\n" +\
                   "split on - Enable split screen\n" +\
                   "split off - Disable split screen\n" +\
                   "split <value> - Set left panel size (0-1)"
        
        "evolve":
            if data_evolution_system != null:
                return data_evolution_system.cmd_evolve([])
            return "Data evolution system not available"
        
        "auto":
            if automation_system != null:
                return automation_system.cmd_auto([])
            return "Automation system not available"
        
        _:
            return "Unknown help topic: " + topic

func _format_size(size_bytes):
    if size_bytes < 1024:
        return str(size_bytes) + " B"
    elif size_bytes < 1024 * 1024:
        return str(int(size_bytes / 1024.0 * 10) / 10.0) + " KB"
    elif size_bytes < 1024 * 1024 * 1024:
        return str(int(size_bytes / (1024.0 * 1024.0) * 10) / 10.0) + " MB"
    else:
        return str(int(size_bytes / (1024.0 * 1024.0 * 1024.0) * 10) / 10.0) + " GB"

func _format_time_ago(timestamp):
    var now = Time.get_unix_time_from_system()
    var diff = now - timestamp
    
    if diff < 60:
        return str(int(diff)) + " seconds ago"
    elif diff < 3600:
        return str(int(diff / 60)) + " minutes ago"
    elif diff < 86400:
        return str(int(diff / 3600)) + " hours ago"
    else:
        return str(int(diff / 86400)) + " days ago"