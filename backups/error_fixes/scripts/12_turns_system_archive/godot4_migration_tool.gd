class_name Godot4MigrationTool
extends Node

# ----- MIGRATION SETTINGS -----
@export_category("Migration Settings")
@export var godot3_project_path: String = ""
@export var godot4_project_path: String = ""
@export var backup_before_migration: bool = true
@export var auto_fix_deprecated: bool = true
@export var migrate_resources: bool = true
@export var verbose_logging: bool = true

# ----- MIGRATION STATISTICS -----
var files_processed: int = 0
var files_modified: int = 0
var errors_encountered: int = 0
var warnings_generated: int = 0

# ----- CONVERSION MAPS -----
# Node name changes from Godot 3 to 4
const NODE_RENAMES = {
    "Spatial": "Node3D",
    "MeshInstance": "MeshInstance3D",
    "AnimationPlayer": "AnimationPlayer",  # No change
    "RigidBody": "RigidBody3D",
    "KinematicBody": "CharacterBody3D",
    "StaticBody": "StaticBody3D",
    "Camera": "Camera3D",
    "Control": "Control",  # No change
    "RayCast": "RayCast3D",
    "Area": "Area3D",
    "Position2D": "Marker2D",
    "Position3D": "Marker3D",
    "CollisionShape": "CollisionShape3D",
    "CollisionPolygon": "CollisionPolygon3D",
    "VisibilityNotifier": "VisibleOnScreenNotifier3D",
    "VisibilityEnabler": "VisibleOnScreenEnabler3D",
    "Joint": "Joint3D",
    "Navigation": "NavigationRegion3D",
    "NavigationMeshInstance": "NavigationRegion3D",
    "Path": "Path3D",
    "PathFollow": "PathFollow3D",
    "AnimatedSprite": "AnimatedSprite2D",
    "RemoteTransform": "RemoteTransform3D"
}

# Method name changes from Godot 3 to 4
const METHOD_RENAMES = {
    "get_translation": "get_position",
    "set_translation": "set_position",
    "rotate_x": "rotate_x",  # No change but format differs
    "rotate_y": "rotate_y",  # No change but format differs
    "rotate_z": "rotate_z",  # No change but format differs
    "is_network_master": "is_multiplayer_authority",
    "rpc_id": "rpc_id",  # No change but usage differs
    "rpc_unreliable_id": "rpc_id",
    "rpc": "rpc",  # No change but usage differs
    "rpc_unreliable": "rpc",
    "yield": "await",
    "is_action_pressed": "is_action_pressed",  # No change, included for completeness
    "is_action_just_pressed": "is_action_just_pressed",  # No change, included for completeness
    "get_slide_count": "get_slide_collision_count",
    "get_slide_collision": "get_slide_collision",  # No change but usage differs
    "connect": "connect",  # No change but syntax differs
    "emit_signal": "emit_signal",  # No change but can be replaced with direct call
    "get_node": "get_node"  # No change, included for completeness
}

# Property name changes from Godot 3 to 4
const PROPERTY_RENAMES = {
    "translation": "position",
    "rotation_degrees": "rotation_degrees",  # No change but treatment differs
    "visible": "visible",  # No change, included for completeness
    "transform": "transform",  # No change but usage differs
    "global_transform": "global_transform",  # No change but usage differs
    "rect_size": "size",
    "rect_position": "position",
    "rect_global_position": "global_position",
    "rect_min_size": "custom_minimum_size",
    "margin_left": "position.x",  # This is trickier and may need custom handling
    "margin_right": "size.x + position.x",  # This is trickier and may need custom handling
    "margin_top": "position.y",  # This is trickier and may need custom handling
    "margin_bottom": "size.y + position.y",  # This is trickier and may need custom handling
    "mesh_library": "mesh_library",  # No change, included for completeness
    "ray_length": "target_position.length()",  # For RayCast
    "cast_to": "target_position"
}

# Physics layers handling changes
const PHYSICS_LAYER_NAMES = [
    "layer_1",
    "layer_2",
    "layer_3",
    "layer_4",
    "layer_5",
    "layer_6",
    "layer_7",
    "layer_8",
    "layer_9",
    "layer_10",
    "layer_11",
    "layer_12",
    "layer_13",
    "layer_14",
    "layer_15",
    "layer_16",
    "layer_17",
    "layer_18",
    "layer_19",
    "layer_20"
]

# Input map changes
const INPUT_MAP_CHANGES = {
    "KEY_": "Key",
    "JOY_": "Joy",
    "BUTTON_": "Button",
    "MOTION_": "Motion",
    "MOUSE_": "Mouse"
}

# Common patterns that need updating
const CODE_PATTERNS_TO_UPDATE = {
    # Await replacement for yield
    "yield\\s*\\(([^,]+)\\s*,\\s*[\"\']([^\"\']+)[\"\']\\s*\\)": "await $1.$2",
    # Direct signal emission
    "emit_signal\\s*\\([\"\']([^\"\']+)[\"\'](?:,\\s*([^)]+))?\\)": "$1.emit($2)",
    # _physics_process delta parameter type
    "func\\s+_physics_process\\s*\\(\\s*delta\\s*\\)": "func _physics_process(delta: float) -> void",
    # _process delta parameter type
    "func\\s+_process\\s*\\(\\s*delta\\s*\\)": "func _process(delta: float) -> void",
    # Return type hints for builtin functions
    "func\\s+_ready\\s*\\(\\s*\\)": "func _ready() -> void",
    "func\\s+_input\\s*\\(\\s*event\\s*\\)": "func _input(event: InputEvent) -> void",
    # Signal connection with callables
    "connect\\s*\\([\"\']([^\"\']+)[\"\']\\s*,\\s*([^,]+)\\s*,\\s*[\"\']([^\"\']+)[\"\']\\)": "connect(\"$1\", Callable($2, \"$3\"))",
    # RigidBody to RigidBody3D mode property
    "mode\\s*=\\s*RigidBody.MODE_": "freeze = ",
    # Replace Vector2/Vector3 constructors
    "Vector2\\s*\\(\\s*([^,]+)\\s*,\\s*([^)]+)\\s*\\)": "Vector2($1, $2)",
    "Vector3\\s*\\(\\s*([^,]+)\\s*,\\s*([^,]+)\\s*,\\s*([^)]+)\\s*\\)": "Vector3($1, $2, $3)",
    # Add typed array declarations
    "var\\s+([a-zA-Z0-9_]+)\\s*=\\s*\\[\\]": "var $1: Array = []"
}

# ----- COMPONENT REFERENCES -----
var file_system = null
var color_system = null
var akashic_system = null
var progress_dialog = null

# ----- SIGNALS -----
signal migration_started(total_files)
signal migration_completed(stats)
signal file_processed(file_path, modified)
signal migration_error(file_path, error_message)
signal migration_warning(file_path, warning_message)
signal progress_updated(current, total)

# ----- INITIALIZATION -----
func _ready():
    _find_components()
    print("Godot4 Migration Tool initialized")

func _find_components():
    # Find FileSystem
    file_system = get_node_or_null("/root/FileSystem")
    if not file_system:
        file_system = self  # Use basic built-in functions if dedicated FileSystem not found
    
    # Find Color System
    color_system = get_node_or_null("/root/DimensionalColorSystem")
    if not color_system:
        color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
    
    # Find Akashic System
    akashic_system = get_node_or_null("/root/AkashicNumberSystem")
    if not akashic_system:
        akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
    
    print("Components found - Color System: %s, Akashic System: %s" % [
        "Yes" if color_system else "No",
        "Yes" if akashic_system else "No"
    ])

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

# ----- MIGRATION FUNCTIONS -----
func start_migration() -> bool:
    # Check if paths are valid
    if godot3_project_path.is_empty() or godot4_project_path.is_empty():
        push_error("Both Godot 3 and Godot 4 project paths must be specified")
        return false
    
    # Reset statistics
    files_processed = 0
    files_modified = 0
    errors_encountered = 0
    warnings_generated = 0
    
    # Get all script files to process
    var script_files = _get_all_script_files(godot3_project_path)
    if script_files.size() == 0:
        push_error("No script files found at path: " + godot3_project_path)
        return false
    
    print("Starting migration of " + str(script_files.size()) + " script files")
    emit_signal("migration_started", script_files.size())
    
    # Create backup if needed
    if backup_before_migration:
        _create_backup(godot3_project_path)
    
    # Process each script file
    var total_files = script_files.size()
    var current_file = 0
    
    for file_path in script_files:
        current_file += 1
        
        # Update progress
        emit_signal("progress_updated", current_file, total_files)
        
        # Process file
        var result = _process_script_file(file_path)
        files_processed += 1
        
        if result.modified:
            files_modified += 1
        
        if result.errors.size() > 0:
            errors_encountered += result.errors.size()
            for error in result.errors:
                emit_signal("migration_error", file_path, error)
        
        if result.warnings.size() > 0:
            warnings_generated += result.warnings.size()
            for warning in result.warnings:
                emit_signal("migration_warning", file_path, warning)
        
        emit_signal("file_processed", file_path, result.modified)
    
    # Migrate project settings
    _migrate_project_settings()
    
    # Migrate resources if needed
    if migrate_resources:
        _migrate_resources()
    
    # Migration complete
    var stats = {
        "files_processed": files_processed,
        "files_modified": files_modified,
        "errors_encountered": errors_encountered,
        "warnings_generated": warnings_generated
    }
    
    print("Migration completed. Stats: " + str(stats))
    emit_signal("migration_completed", stats)
    
    return true

func _get_all_script_files(path: String) -> Array:
    var files = []
    var dir = DirAccess.open(path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            var full_path = path.path_join(file_name)
            
            if dir.current_is_dir() and file_name != "." and file_name != "..":
                # Recursively process subdirectories
                files.append_array(_get_all_script_files(full_path))
            elif file_name.ends_with(".gd"):
                files.append(full_path)
            
            file_name = dir.get_next()
    else:
        push_error("Failed to open directory: " + path)
    
    return files

func _create_backup(path: String) -> void:
    # Create a backup directory
    var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
    var backup_path = path + "_backup_" + timestamp
    
    var dir = DirAccess.open(path.get_base_dir())
    if dir:
        var err = dir.make_dir(backup_path)
        if err != OK:
            push_error("Failed to create backup directory: " + backup_path)
            return
        
        # Copy files using OS.execute for robustness
        var output = []
        var exit_code = OS.execute("cp", ["-r", path + "/*", backup_path], output, true)
        
        if exit_code != 0:
            push_error("Failed to create backup. Error: " + str(output))
        else:
            print("Backup created at: " + backup_path)
    else:
        push_error("Failed to open directory for backup: " + path.get_base_dir())

func _process_script_file(file_path: String) -> Dictionary:
    # Initialize result
    var result = {
        "modified": false,
        "errors": [],
        "warnings": []
    }
    
    # Read file
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        result.errors.append("Failed to open file for reading: " + file_path)
        return result
    
    var content = file.get_as_text()
    file.close()
    
    # Process content
    var original_content = content
    content = _update_script_content(content, file_path, result)
    
    # Write back if modified
    if content != original_content:
        # Determine output path in Godot 4 project
        var rel_path = file_path.replace(godot3_project_path, "")
        var output_path = godot4_project_path + rel_path
        
        # Ensure directory exists
        var dir = DirAccess.open(output_path.get_base_dir())
        if not dir:
            # Try to create the directory
            var err = DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
            if err != OK:
                result.errors.append("Failed to create directory: " + output_path.get_base_dir())
                return result
        
        # Write file
        var output_file = FileAccess.open(output_path, FileAccess.WRITE)
        if not output_file:
            result.errors.append("Failed to open file for writing: " + output_path)
            return result
        
        output_file.store_string(content)
        output_file.close()
        
        result.modified = true
        print("Updated: " + output_path)
    
    return result

func _update_script_content(content: String, file_path: String, result: Dictionary) -> String:
    # Apply all migration updates to script content
    
    # 1. Handle class/node renames
    content = _update_node_references(content, result)
    
    # 2. Handle method renames
    content = _update_method_calls(content, result)
    
    # 3. Handle property renames
    content = _update_property_references(content, result)
    
    # 4. Update code patterns
    content = _update_code_patterns(content, result)
    
    # 5. Handle special cases
    content = _handle_special_cases(content, file_path, result)
    
    # 6. Update for typed GDScript
    if auto_fix_deprecated:
        content = _add_type_hints(content, result)
    
    return content

func _update_node_references(content: String, result: Dictionary) -> String:
    # Update node class references
    var updated_content = content
    
    for old_name in NODE_RENAMES:
        var new_name = NODE_RENAMES[old_name]
        
        # Skip if no change needed
        if old_name == new_name:
            continue
        
        # Update extends statements
        var extends_pattern = "extends\\s+" + old_name
        updated_content = updated_content.replace(extends_pattern, "extends " + new_name)
        
        # Update preload and load statements
        var preload_pattern = "preload\\(\"res://.*/" + old_name + ".gd\"\\)"
        var load_pattern = "load\\(\"res://.*/" + old_name + ".gd\"\\)"
        
        # These would need regex for more accurate replacement
        # For simplicity, we're looking for exact pattern matches
        
        # Update is checks
        var is_pattern = "is\\s+" + old_name
        updated_content = updated_content.replace(is_pattern, "is " + new_name)
        
        # Update class_name declarations
        var class_pattern = "class_name\\s+(" + old_name + ")"
        var regex = RegEx.new()
        regex.compile(class_pattern)
        var matches = regex.search_all(updated_content)
        
        for match_result in matches:
            var old_text = match_result.get_string()
            var new_text = old_text.replace(old_name, new_name)
            updated_content = updated_content.replace(old_text, new_text)
    
    return updated_content

func _update_method_calls(content: String, result: Dictionary) -> String:
    # Update method calls
    var updated_content = content
    
    for old_method in METHOD_RENAMES:
        var new_method = METHOD_RENAMES[old_method]
        
        # Skip if no change needed
        if old_method == new_method:
            continue
        
        # This is a simplified approach for straightforward replacements
        # More complex cases like yield->await need special handling
        var method_pattern = "\\." + old_method + "\\("
        updated_content = updated_content.replace(method_pattern, "." + new_method + "(")
    
    return updated_content

func _update_property_references(content: String, result: Dictionary) -> String:
    # Update property references
    var updated_content = content
    
    for old_prop in PROPERTY_RENAMES:
        var new_prop = PROPERTY_RENAMES[old_prop]
        
        # Skip if no change needed
        if old_prop == new_prop:
            continue
        
        # Simple dot notation property access
        var prop_pattern = "\\." + old_prop + "\\b"
        updated_content = updated_content.replace(prop_pattern, "." + new_prop)
    
    return updated_content

func _update_code_patterns(content: String, result: Dictionary) -> String:
    # Update code patterns using regex
    var updated_content = content
    
    for pattern in CODE_PATTERNS_TO_UPDATE:
        var replacement = CODE_PATTERNS_TO_UPDATE[pattern]
        
        var regex = RegEx.new()
        regex.compile(pattern)
        
        var matches = regex.search_all(updated_content)
        for match_result in matches:
            var old_text = match_result.get_string()
            var new_text = regex.sub(old_text, replacement)
            updated_content = updated_content.replace(old_text, new_text)
    
    return updated_content

func _handle_special_cases(content: String, file_path: String, result: Dictionary) -> String:
    # Handle special cases that need custom processing
    var updated_content = content
    
    # Handle onready vars (Godot 4 supports them but static typing is preferred)
    if auto_fix_deprecated:
        var onready_regex = RegEx.new()
        onready_regex.compile("onready\\s+var\\s+([a-zA-Z0-9_]+)\\s*=\\s*(.+)")
        
        var matches = onready_regex.search_all(updated_content)
        for match_result in matches:
            var old_text = match_result.get_string()
            var var_name = match_result.get_string(1)
            var var_value = match_result.get_string(2)
            
            # Create new format with @onready annotation
            var new_text = "@onready var " + var_name + " = " + var_value
            updated_content = updated_content.replace(old_text, new_text)
    
    # Handle exports (export var -> @export var)
    if auto_fix_deprecated:
        var export_regex = RegEx.new()
        export_regex.compile("export\\s*\\((.+?)\\)\\s+var\\s+([a-zA-Z0-9_]+)")
        
        var matches = export_regex.search_all(updated_content)
        for match_result in matches:
            var old_text = match_result.get_string()
            var export_args = match_result.get_string(1)
            var var_name = match_result.get_string(2)
            
            # Create new format with @export annotation
            var new_text = "@export var " + var_name
            updated_content = updated_content.replace(old_text, new_text)
            
            # Add a warning because export parameters need manual conversion
            result.warnings.append("Export hint converted. Please check @export parameters manually: " + old_text)
    
    # Handle tool annotation
    if auto_fix_deprecated:
        updated_content = updated_content.replace("tool", "@tool")
    
    # Handle network related changes
    updated_content = updated_content.replace("master", "authority")
    updated_content = updated_content.replace("slave", "puppet")
    updated_content = updated_content.replace("set_network_master", "set_multiplayer_authority")
    
    return updated_content

func _add_type_hints(content: String, result: Dictionary) -> String:
    # Add type hints to improve code (optional)
    var updated_content = content
    
    # Add return type void to functions without return types
    var func_regex = RegEx.new()
    func_regex.compile("func\\s+([a-zA-Z0-9_]+)\\s*\\(([^)]*)\\)\\s*:")
    
    var matches = func_regex.search_all(updated_content)
    for match_result in matches:
        var old_text = match_result.get_string()
        var func_name = match_result.get_string(1)
        var func_params = match_result.get_string(2)
        
        # Skip functions that already have return type
        if old_text.find("->") != -1:
            continue
        
        # Add basic void return type
        var new_text = old_text.replace("):", ") -> void:")
        updated_content = updated_content.replace(old_text, new_text)
    
    # Add parameter types where reasonable guesses can be made
    var param_regex = RegEx.new()
    param_regex.compile("\\(([^)]*)\\)")
    
    var common_param_types = {
        "delta": "float",
        "event": "InputEvent",
        "body": "Node",
        "area": "Area3D",
        "value": "Variant",
        "pos": "Vector2",
        "position": "Vector3",
        "id": "int",
        "index": "int",
        "name": "String",
        "text": "String"
    }
    
    matches = param_regex.search_all(updated_content)
    for match_result in matches:
        var old_text = match_result.get_string()
        var params = match_result.get_string(1)
        
        # Skip if empty parameters or already has type hints
        if params.strip_edges() == "" or params.find(":") != -1:
            continue
        
        # Add type hints for recognizable parameters
        var param_list = params.split(",")
        var new_params = []
        
        for param in param_list:
            param = param.strip_edges()
            var param_name = param
            
            # Handle default values
            if param.find("=") != -1:
                param_name = param.split("=")[0].strip_edges()
            
            # Check if we can add a type hint
            var typed_param = param
            for common_name in common_param_types:
                if param_name == common_name:
                    var type_hint = common_param_types[common_name]
                    typed_param = param_name + ": " + type_hint
                    
                    # Re-add default value if it was there
                    if param.find("=") != -1:
                        typed_param += " = " + param.split("=")[1].strip_edges()
                    
                    break
            
            new_params.append(typed_param)
        
        var new_text = "(" + ", ".join(new_params) + ")"
        updated_content = updated_content.replace(old_text, new_text)
    
    return updated_content

func _migrate_project_settings() -> void:
    # Read the Godot 3 project.godot file
    var godot3_project_file = godot3_project_path.path_join("project.godot")
    var godot4_project_file = godot4_project_path.path_join("project.godot")
    
    var file = FileAccess.open(godot3_project_file, FileAccess.READ)
    if not file:
        push_error("Failed to open Godot 3 project file: " + godot3_project_file)
        return
    
    var content = file.get_as_text()
    file.close()
    
    # Update syntax and settings for Godot 4
    var updated_content = content
    
    # Update config_version
    updated_content = updated_content.replace("config_version=4", "config_version=5")
    
    # Update input mapping syntax
    for old_key in INPUT_MAP_CHANGES:
        var new_key = INPUT_MAP_CHANGES[old_key]
        updated_content = updated_content.replace(old_key, new_key)
    
    # Write to Godot 4 project file
    var output_file = FileAccess.open(godot4_project_file, FileAccess.WRITE)
    if not output_file:
        push_error("Failed to open Godot 4 project file for writing: " + godot4_project_file)
        return
    
    output_file.store_string(updated_content)
    output_file.close()
    
    print("Project settings migrated: " + godot4_project_file)

func _migrate_resources() -> void:
    # Get all resource files (.tres, .tscn, etc.)
    var resource_extensions = [".tres", ".tscn", ".material", ".mesh", ".shader"]
    var resources = []
    
    for ext in resource_extensions:
        var ext_resources = _get_files_with_extension(godot3_project_path, ext)
        resources.append_array(ext_resources)
    
    # Process each resource file
    for resource_path in resources:
        _migrate_resource_file(resource_path)

func _get_files_with_extension(path: String, extension: String) -> Array:
    var files = []
    var dir = DirAccess.open(path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            var full_path = path.path_join(file_name)
            
            if dir.current_is_dir() and file_name != "." and file_name != "..":
                # Recursively process subdirectories
                files.append_array(_get_files_with_extension(full_path, extension))
            elif file_name.ends_with(extension):
                files.append(full_path)
            
            file_name = dir.get_next()
    else:
        push_error("Failed to open directory: " + path)
    
    return files

func _migrate_resource_file(file_path: String) -> void:
    # Read resource file
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        push_error("Failed to open resource file: " + file_path)
        return
    
    var content = file.get_as_text()
    file.close()
    
    # Update paths and class references
    var updated_content = content
    
    # Update node type references
    for old_name in NODE_RENAMES:
        var new_name = NODE_RENAMES[old_name]
        
        # Skip if no change needed
        if old_name == new_name:
            continue
        
        # Update type references in resources
        updated_content = updated_content.replace("type=\"" + old_name + "\"", "type=\"" + new_name + "\"")
        updated_content = updated_content.replace("[ext_resource type=\"" + old_name + "\"", "[ext_resource type=\"" + new_name + "\"")
    
    # Determine output path in Godot 4 project
    var rel_path = file_path.replace(godot3_project_path, "")
    var output_path = godot4_project_path + rel_path
    
    # Ensure directory exists
    var dir = DirAccess.open(output_path.get_base_dir())
    if not dir:
        # Try to create the directory
        var err = DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
        if err != OK:
            push_error("Failed to create directory: " + output_path.get_base_dir())
            return
    
    # Write updated resource file
    var output_file = FileAccess.open(output_path, FileAccess.WRITE)
    if not output_file:
        push_error("Failed to open resource file for writing: " + output_path)
        return
    
    output_file.store_string(updated_content)
    output_file.close()
    
    print("Migrated resource: " + output_path)

# ----- PUBLIC API -----
func migrate_project(from_path: String, to_path: String) -> Dictionary:
    godot3_project_path = from_path
    godot4_project_path = to_path
    
    if start_migration():
        return {
            "success": true,
            "files_processed": files_processed,
            "files_modified": files_modified,
            "errors": errors_encountered,
            "warnings": warnings_generated
        }
    else:
        return {
            "success": false,
            "error": "Migration failed to start"
        }

func migrate_single_file(file_path: String, output_path: String = "") -> Dictionary:
    # Check if file exists
    if not FileAccess.file_exists(file_path):
        return {
            "success": false,
            "error": "File does not exist: " + file_path
        }
    
    # Determine output path
    var actual_output_path = output_path
    if actual_output_path.is_empty():
        actual_output_path = file_path.get_basename() + "_godot4" + file_path.get_extension()
    
    # Initialize result
    var result = {
        "modified": false,
        "errors": [],
        "warnings": []
    }
    
    # Read file
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        return {
            "success": false,
            "error": "Failed to open file for reading: " + file_path
        }
    
    var content = file.get_as_text()
    file.close()
    
    # Process content
    var original_content = content
    content = _update_script_content(content, file_path, result)
    
    # Write back if modified
    if content != original_content:
        var output_file = FileAccess.open(actual_output_path, FileAccess.WRITE)
        if not output_file:
            return {
                "success": false,
                "error": "Failed to open file for writing: " + actual_output_path
            }
        
        output_file.store_string(content)
        output_file.close()
        
        result.modified = true
        print("Updated: " + actual_output_path)
    
    return {
        "success": true,
        "modified": result.modified,
        "warnings": result.warnings,
        "errors": result.errors,
        "output_path": actual_output_path
    }

func check_compatibility(file_path: String) -> Dictionary:
    # Check a file for Godot 4 compatibility without modifying it
    
    # Check if file exists
    if not FileAccess.file_exists(file_path):
        return {
            "success": false,
            "error": "File does not exist: " + file_path
        }
    
    # Initialize result
    var result = {
        "modified": false,
        "errors": [],
        "warnings": []
    }
    
    # Read file
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        return {
            "success": false,
            "error": "Failed to open file for reading: " + file_path
        }
    
    var content = file.get_as_text()
    file.close()
    
    # Process content (without saving)
    var updated_content = _update_script_content(content, file_path, result)
    var is_compatible = (content == updated_content)
    
    # Find specific compatibility issues
    var compatibility_issues = []
    
    # Check for node class names
    for old_name in NODE_RENAMES:
        if old_name != NODE_RENAMES[old_name] and content.find(old_name) != -1:
            compatibility_issues.append("Uses deprecated node type: " + old_name)
    
    # Check for method names
    for old_method in METHOD_RENAMES:
        if old_method != METHOD_RENAMES[old_method] and content.find("." + old_method + "(") != -1:
            compatibility_issues.append("Uses deprecated method: " + old_method)
    
    # Check for properties
    for old_prop in PROPERTY_RENAMES:
        if old_prop != PROPERTY_RENAMES[old_prop] and content.find("." + old_prop) != -1:
            compatibility_issues.append("Uses deprecated property: " + old_prop)
    
    # Check for yield pattern
    if content.find("yield") != -1:
        compatibility_issues.append("Uses yield, which should be replaced with await")
    
    return {
        "success": true,
        "compatible": is_compatible,
        "issues": compatibility_issues,
        "warnings": result.warnings,
        "errors": result.errors
    }

func generate_migration_report(directory_path: String) -> Dictionary:
    # Generate a report of all files in a directory and their Godot 4 compatibility
    var report = {
        "total_files": 0,
        "compatible_files": 0,
        "incompatible_files": 0,
        "file_details": []
    }
    
    # Get all script files
    var script_files = _get_all_script_files(directory_path)
    report.total_files = script_files.size()
    
    # Check each file
    for file_path in script_files:
        var compatibility = check_compatibility(file_path)
        
        if compatibility.success:
            if compatibility.compatible:
                report.compatible_files += 1
            else:
                report.incompatible_files += 1
            
            report.file_details.append({
                "path": file_path,
                "compatible": compatibility.compatible,
                "issues": compatibility.issues,
                "warnings": compatibility.warnings,
                "errors": compatibility.errors
            })
    
    return report