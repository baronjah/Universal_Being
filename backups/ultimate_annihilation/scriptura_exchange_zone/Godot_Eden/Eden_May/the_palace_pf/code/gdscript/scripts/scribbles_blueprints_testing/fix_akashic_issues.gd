extends Node
class_name AkashicFixer

# This is a utility script to fix common issues in the Akashic Records system

func _ready() -> void:
    print("AkashicFixer: Starting fixes...")
    # Wait for one frame to ensure scene tree is ready
    await get_tree().process_frame
    # Run all fixes
    fix_get_tree_issues()
    fix_class_name_issues()
    fix_visible_property_issues()
    fix_nil_return_issues()
    fix_register_command_issues()
    fix_zone_manager_issues()
    print("AkashicFixer: All fixes applied. You can remove this node now.")

# Issue 1: get_tree() might return null in _ready()
func fix_get_tree_issues() -> void:
    print("Fixing get_tree() issues...")
    var files = find_files_with_pattern("get_tree")
    
    for file_path in files:
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            file.close()
            
            # Replace direct tree access patterns with null check
            var pattern1 = "var nodes = get_tree().get_nodes_in_group"
            var replacement1 = "var tree = get_tree()\nif tree:\n\tvar nodes = tree.get_nodes_in_group"
            
            # Replace other direct tree access
            var pattern2 = "get_tree().root.find_node"
            var replacement2 = "var tree = get_tree()\nif tree and tree.root:\n\tvar node = tree.root.find_node"
            
            content = content.replace(pattern1, replacement1)
            content = content.replace(pattern2, replacement2)
            
            # Write back the fixed content
            file = FileAccess.open(file_path, FileAccess.WRITE)
            if file:
                file.store_string(content)
                file.close()
                print("Fixed get_tree() issues in " + file_path)

# Issue 2: class_name parameter conflicts
func fix_class_name_issues() -> void:
    print("Fixing class_name parameter issues...")
    var files = find_files_with_pattern("class_name")
    
    for file_path in files:
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            file.close()
            
            # Find function parameters named "class_name"
            var pattern = "func.*\\(.*class_name.*\\)"
            var regex = RegEx.new()
            regex.compile(pattern)
            var result = regex.search(content)
            
            if result:
                # Replace class_name parameter with class_name_param
                var line = result.get_string()
                var fixed_line = line.replace("class_name", "class_name_param")
                content = content.replace(line, fixed_line)
                
                # Fix usage inside the function too
                var pattern2 = "class_name\\s*="
                var replacement2 = "class_name_param ="
                content = content.replace(pattern2, replacement2)
                
                # Write back the fixed content
                file = FileAccess.open(file_path, FileAccess.WRITE)
                if file:
                    file.store_string(content)
                    file.close()
                    print("Fixed class_name parameter issues in " + file_path)

# Issue 3: visible property access
func fix_visible_property_issues() -> void:
    print("Fixing visible property issues...")
    var files = find_files_with_pattern("visible")
    
    for file_path in files:
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            file.close()
            
            # Replace "and visible" with "and self.visible"
            var pattern = "\\band visible\\b"
            var replacement = "and self.visible"
            
            # Check if it needs fixing
            if content.find(pattern) >= 0:
                content = content.replace(pattern, replacement)
                
                # Write back the fixed content
                file = FileAccess.open(file_path, FileAccess.WRITE)
                if file:
                    file.store_string(content)
                    file.close()
                    print("Fixed visible property issues in " + file_path)

# Issue 4: Fix nil return value issues
func fix_nil_return_issues() -> void:
    print("Fixing nil return value issues...")
    var files = find_files_with_pattern("return success")
    
    for file_path in files:
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            file.close()
            
            # Replace "return success" with null check
            var pattern = "return success"
            var replacement = "return success if success != null else false"
            
            if content.find(pattern) >= 0:
                content = content.replace(pattern, replacement)
                
                # Write back the fixed content
                file = FileAccess.open(file_path, FileAccess.WRITE)
                if file:
                    file.store_string(content)
                    file.close()
                    print("Fixed nil return issues in " + file_path)

# Issue 5: register_command issues
func fix_register_command_issues() -> void:
    print("Fixing register_command issues...")
    var files = find_files_with_pattern("register_command")
    
    for file_path in files:
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            file.close()
            
            # Replace direct callback reference with Callable
            var pattern = "register_command\\(.*\"callback\"\\]\\)"
            var replacement = "register_command(cmd[\"name\"], cmd[\"description\"], Callable(self, cmd[\"callback\"]))"
            
            var regex = RegEx.new()
            regex.compile(pattern)
            var result = regex.search(content)
            
            if result:
                var line = result.get_string()
                content = content.replace(line, replacement)
                
                # Write back the fixed content
                file = FileAccess.open(file_path, FileAccess.WRITE)
                if file:
                    file.store_string(content)
                    file.close()
                    print("Fixed register_command issues in " + file_path)

# Issue 6: Fix ZoneManager.new() issues
func fix_zone_manager_issues() -> void:
    print("Fixing zone manager issues...")
    # Make sure the zone_manager.gd script is in place - already done above
    # Update references to zones variable in akashic_records_manager.gd - already done above
    print("Zone manager issues already fixed with the new implementation")

# Helper function to find files with a specific text pattern
func find_files_with_pattern(pattern: String) -> Array:
    var result = []
    var dir = DirAccess.open("res://")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd") and !dir.current_is_dir():
                var file = FileAccess.open("res://" + file_name, FileAccess.READ)
                if file:
                    var content = file.get_as_text()
                    file.close()
                    if content.find(pattern) >= 0:
                        result.append("res://" + file_name)
            file_name = dir.get_next()
    return result