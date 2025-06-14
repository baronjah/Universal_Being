extends Node

class_name UnifiedProjectMerger

# Constants for drive types
const DRIVE_TYPE_LOCAL = "local"
const DRIVE_TYPE_GOOGLE = "google_drive"
const DRIVE_TYPE_NETWORK = "network"

# File classification types
const FILE_TYPE_SCRIPT = "script"
const FILE_TYPE_SCENE = "scene"
const FILE_TYPE_RESOURCE = "resource"
const FILE_TYPE_CONFIG = "config"
const FILE_TYPE_DATA = "data"
const FILE_TYPE_OTHER = "other"

# Storage for drive information
var drives = {}
var total_size = 0
var file_counts = {}
var file_type_sizes = {}

# References to other systems
var cloud_noise_generator
var visualization_system
var connection_manager

signal scan_completed(stats)
signal merge_completed(stats)

func _init():
    # Initialize the counters
    for type in [FILE_TYPE_SCRIPT, FILE_TYPE_SCENE, FILE_TYPE_RESOURCE, 
                 FILE_TYPE_CONFIG, FILE_TYPE_DATA, FILE_TYPE_OTHER]:
        file_counts[type] = 0
        file_type_sizes[type] = 0

func register_drive(drive_path, drive_type = DRIVE_TYPE_LOCAL, drive_name = ""):
    """Register a drive for scanning and merging"""
    if drive_name == "":
        drive_name = drive_path.split("/")[-1]
    
    drives[drive_name] = {
        "path": drive_path,
        "type": drive_type,
        "size": 0,
        "file_count": 0,
        "last_scan": 0,
        "projects": []
    }
    
    print("Registered drive: " + drive_name + " (" + drive_path + ")")
    return drive_name

func scan_all_drives():
    """Scan all registered drives for projects"""
    total_size = 0
    
    for drive_name in drives.keys():
        scan_drive(drive_name)
    
    var stats = {
        "total_size": total_size,
        "drive_count": drives.size(),
        "file_counts": file_counts,
        "file_type_sizes": file_type_sizes
    }
    
    emit_signal("scan_completed", stats)
    return stats

func scan_drive(drive_name):
    """Scan a specific drive for projects"""
    if !drives.has(drive_name):
        print("Drive not found: " + drive_name)
        return null
    
    var drive = drives[drive_name]
    drive.projects = []
    drive.size = 0
    drive.file_count = 0
    
    # Different scanning approaches based on drive type
    match drive.type:
        DRIVE_TYPE_LOCAL:
            _scan_local_drive(drive)
        DRIVE_TYPE_GOOGLE:
            _scan_google_drive(drive)
        DRIVE_TYPE_NETWORK:
            _scan_network_drive(drive)
    
    drive.last_scan = Time.get_unix_time_from_system()
    total_size += drive.size
    
    print("Scanned drive: " + drive_name + ", size: " + str(drive.size) + " bytes, files: " + str(drive.file_count))
    return drive

func _scan_local_drive(drive):
    """Scan a local drive for projects"""
    var dir = Directory.new()
    if dir.open(drive.path) != OK:
        print("Failed to open directory: " + drive.path)
        return
    
    dir.list_dir_begin(true, true)
    var file_name = dir.get_next()
    
    while file_name != "":
        var full_path = drive.path.path_join(file_name)
        
        if dir.current_is_dir():
            # Check if this is a Godot project
            if _is_godot_project(full_path):
                _add_project(drive, full_path, "godot")
            else:
                # Recursively scan subdirectories
                var subdrive = {
                    "path": full_path,
                    "type": drive.type,
                    "size": 0,
                    "file_count": 0,
                    "projects": []
                }
                _scan_local_drive(subdrive)
                
                # Add the stats from the subdirectory
                drive.size += subdrive.size
                drive.file_count += subdrive.file_count
                drive.projects.append_array(subdrive.projects)
        else:
            # Process individual files
            var file_size = _get_file_size(full_path)
            var file_type = _classify_file(full_path)
            
            drive.size += file_size
            drive.file_count += 1
            
            file_counts[file_type] += 1
            file_type_sizes[file_type] += file_size
        
        file_name = dir.get_next()
    
    dir.list_dir_end()

func _scan_google_drive(drive):
    """Scan a Google Drive for projects"""
    # This would use Google Drive API to scan files
    # For now, we'll just simulate with dummy data
    print("Google Drive scanning not yet implemented")
    
    # Placeholder for demo
    drive.size = 1024 * 1024 * 100  # 100 MB
    drive.file_count = 50
    drive.projects = [
        {"path": "google_drive://MyGodotProject", "type": "godot", "size": 1024 * 1024 * 20}
    ]

func _scan_network_drive(drive):
    """Scan a network drive for projects"""
    # Similar to local drive but with network-specific handling
    print("Network drive scanning not yet implemented")
    
    # For now, use the local scan method
    _scan_local_drive(drive)

func _is_godot_project(path):
    """Check if a directory is a Godot project"""
    var dir = Directory.new()
    return dir.file_exists(path.path_join("project.godot"))

func _add_project(drive, project_path, project_type):
    """Add a project to the drive's project list"""
    var project_size = _calculate_directory_size(project_path)
    var project_info = {
        "path": project_path,
        "type": project_type,
        "size": project_size,
        "files": _count_directory_files(project_path)
    }
    
    drive.projects.append(project_info)
    drive.size += project_size
    drive.file_count += project_info.files

func _calculate_directory_size(path):
    """Calculate the total size of a directory"""
    var total = 0
    var dir = Directory.new()
    
    if dir.open(path) != OK:
        return 0
    
    dir.list_dir_begin(true, true)
    var file_name = dir.get_next()
    
    while file_name != "":
        var full_path = path.path_join(file_name)
        
        if dir.current_is_dir():
            total += _calculate_directory_size(full_path)
        else:
            total += _get_file_size(full_path)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    return total

func _count_directory_files(path):
    """Count the number of files in a directory"""
    var count = 0
    var dir = Directory.new()
    
    if dir.open(path) != OK:
        return 0
    
    dir.list_dir_begin(true, true)
    var file_name = dir.get_next()
    
    while file_name != "":
        var full_path = path.path_join(file_name)
        
        if dir.current_is_dir():
            count += _count_directory_files(full_path)
        else:
            count += 1
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    return count

func _get_file_size(path):
    """Get the size of a file"""
    var file = File.new()
    if !file.file_exists(path):
        return 0
    
    var size = 0
    file.open(path, File.READ)
    size = file.get_len()
    file.close()
    
    return size

func _classify_file(path):
    """Classify a file based on its extension and contents"""
    var ext = path.get_extension().to_lower()
    
    match ext:
        "gd", "cs", "gdscript", "shader", "gdshader":
            return FILE_TYPE_SCRIPT
        "tscn", "scn":
            return FILE_TYPE_SCENE
        "tres", "res", "material", "mesh", "theme":
            return FILE_TYPE_RESOURCE
        "godot", "import", "cfg", "ini", "json":
            return FILE_TYPE_CONFIG
        "txt", "csv", "xml", "dat":
            return FILE_TYPE_DATA
        _:
            return FILE_TYPE_OTHER

func merge_projects(target_drive_name = null):
    """Merge all discovered projects into a target drive"""
    if target_drive_name == null:
        # Use the first drive as the target by default
        if drives.size() > 0:
            target_drive_name = drives.keys()[0]
        else:
            print("No drives registered for merging")
            return null
    
    if !drives.has(target_drive_name):
        print("Target drive not found: " + target_drive_name)
        return null
    
    var target_drive = drives[target_drive_name]
    var merged_stats = {
        "merged_projects": 0,
        "merged_files": 0,
        "total_size": 0,
        "file_types": {}
    }
    
    print("Starting project merge to drive: " + target_drive_name)
    
    # Track all the projects we've found
    var all_projects = []
    for drive_name in drives.keys():
        var drive = drives[drive_name]
        for project in drive.projects:
            all_projects.append({
                "drive": drive_name,
                "project": project
            })
    
    # Merge similar projects
    var project_groups = _group_similar_projects(all_projects)
    
    # Perform the actual merging
    for group_name in project_groups:
        var group = project_groups[group_name]
        if group.size() > 1:
            print("Merging project group: " + group_name + " with " + str(group.size()) + " similar projects")
            _merge_project_group(group, target_drive, merged_stats)
        else:
            # Just copy the single project to the target if needed
            var project_info = group[0]
            if project_info.drive != target_drive_name:
                print("Copying single project to target drive: " + project_info.project.path)
                _copy_project_to_target(project_info.project, target_drive, merged_stats)
    
    # Generate visualization for the merged projects
    _generate_cloud_visualization(target_drive, merged_stats)
    
    emit_signal("merge_completed", merged_stats)
    return merged_stats

func _group_similar_projects(all_projects):
    """Group similar projects together based on their structure and content"""
    var groups = {}
    
    for project_info in all_projects:
        var project = project_info.project
        
        # Create a signature for the project based on key files
        var signature = _calculate_project_signature(project)
        
        # Use the signature as a group key
        if !groups.has(signature):
            groups[signature] = []
        
        groups[signature].append(project_info)
    
    return groups

func _calculate_project_signature(project):
    """Calculate a signature for a project based on its structure and key files"""
    # This would be a more complex analysis in a real implementation
    # For now, just use the project type and basic structure
    var path = project.path
    var type = project.type
    
    return type + "_" + path.get_file()

func _merge_project_group(group, target_drive, stats):
    """Merge a group of similar projects together"""
    # Determine the target project (either the newest or largest)
    var target_project = _select_target_project(group)
    
    # Create a merged project in the target drive
    var merged_path = target_drive.path.path_join("merged_" + target_project.project.path.get_file())
    _ensure_directory_exists(merged_path)
    
    # Track what we've merged
    stats.merged_projects += group.size()
    
    # Copy all unique files from all projects in the group
    for project_info in group:
        var project = project_info.project
        _merge_project_files(project.path, merged_path, stats)
    
    # Add the merged project to the target drive
    var merged_size = _calculate_directory_size(merged_path)
    target_drive.projects.append({
        "path": merged_path,
        "type": target_project.project.type,
        "size": merged_size,
        "merged": true,
        "merged_count": group.size()
    })
    
    print("Merged " + str(group.size()) + " projects to: " + merged_path + ", size: " + str(merged_size) + " bytes")

func _select_target_project(group):
    """Select which project in a group to use as the target"""
    # For now, use the largest project as the target
    var largest = group[0]
    
    for project_info in group:
        if project_info.project.size > largest.project.size:
            largest = project_info
    
    return largest

func _merge_project_files(source_path, target_path, stats):
    """Merge files from source project to target project"""
    var dir = Directory.new()
    
    if dir.open(source_path) != OK:
        print("Failed to open source directory: " + source_path)
        return
    
    dir.list_dir_begin(true, true)
    var file_name = dir.get_next()
    
    while file_name != "":
        var source_file = source_path.path_join(file_name)
        var target_file = target_path.path_join(file_name)
        
        if dir.current_is_dir():
            # Recursively handle directories
            _ensure_directory_exists(target_file)
            _merge_project_files(source_file, target_file, stats)
        else:
            # Handle file merging
            var should_copy = true
            
            if File.new().file_exists(target_file):
                # File already exists in target - determine if we should overwrite
                should_copy = _should_overwrite_file(source_file, target_file)
            
            if should_copy:
                _copy_file(source_file, target_file)
                stats.merged_files += 1
                
                # Update file type stats
                var file_type = _classify_file(source_file)
                if !stats.file_types.has(file_type):
                    stats.file_types[file_type] = 0
                
                stats.file_types[file_type] += 1
                stats.total_size += _get_file_size(source_file)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()

func _ensure_directory_exists(path):
    """Make sure a directory exists, creating it if necessary"""
    var dir = Directory.new()
    if !dir.dir_exists(path):
        var parent = path.get_base_dir()
        if !dir.dir_exists(parent):
            _ensure_directory_exists(parent)
        
        dir.make_dir(path)

func _should_overwrite_file(source_file, target_file):
    """Determine if a source file should overwrite a target file"""
    # This could be enhanced with content comparison, modification times, etc.
    var source_size = _get_file_size(source_file)
    var target_size = _get_file_size(target_file)
    
    # By default, prefer the larger file
    return source_size > target_size

func _copy_file(source_path, target_path):
    """Copy a file from source to target"""
    var dir = Directory.new()
    return dir.copy(source_path, target_path)

func _copy_project_to_target(project, target_drive, stats):
    """Copy a single project to the target drive"""
    var source_path = project.path
    var target_path = target_drive.path.path_join(source_path.get_file())
    
    _ensure_directory_exists(target_path)
    _merge_project_files(source_path, target_path, stats)
    
    # Update stats
    stats.merged_projects += 1
    target_drive.projects.append({
        "path": target_path,
        "type": project.type,
        "size": _calculate_directory_size(target_path),
        "merged": false
    })

func _generate_cloud_visualization(target_drive, stats):
    """Generate a cloud visualization for the merged projects"""
    if cloud_noise_generator == null:
        print("Cloud noise generator not available for visualization")
        return
    
    # Create shapes for each project type
    var shapes = {}
    var colors = {}
    
    # Define colors for different file types
    colors[FILE_TYPE_SCRIPT] = Color(0.2, 0.7, 1.0)  # Blue
    colors[FILE_TYPE_SCENE] = Color(0.2, 1.0, 0.3)   # Green
    colors[FILE_TYPE_RESOURCE] = Color(1.0, 0.7, 0.2) # Orange
    colors[FILE_TYPE_CONFIG] = Color(0.7, 0.2, 1.0)  # Purple
    colors[FILE_TYPE_DATA] = Color(1.0, 1.0, 0.2)    # Yellow
    colors[FILE_TYPE_OTHER] = Color(0.5, 0.5, 0.5)   # Gray
    
    # Create proportional shapes for each file type
    var total_files = stats.merged_files
    if total_files > 0:
        for file_type in stats.file_types:
            var proportion = float(stats.file_types[file_type]) / float(total_files)
            var size = 0.5 + proportion * 2.0
            
            var shape_type = "sphere"
            match file_type:
                FILE_TYPE_SCRIPT:
                    shape_type = "cube"
                FILE_TYPE_SCENE:
                    shape_type = "pyramid"
                FILE_TYPE_RESOURCE:
                    shape_type = "cylinder"
                FILE_TYPE_CONFIG:
                    shape_type = "octahedron"
                FILE_TYPE_DATA:
                    shape_type = "disk"
                FILE_TYPE_OTHER:
                    shape_type = "icosphere"
            
            # Generate the cloud shape
            var cloud_shape = cloud_noise_generator.generate_cloud_shape(
                shape_type,
                "perlin",
                3,
                size,
                1.0 + proportion
            )
            
            # Apply the color
            cloud_noise_generator.apply_color_to_cloud(cloud_shape.id, colors[file_type])
            
            shapes[file_type] = cloud_shape
    
    # Combine all shapes into a merged visualization
    var merged_shape = cloud_noise_generator.combine_clouds(shapes.values())
    
    # Update visualization system if available
    if visualization_system != null:
        visualization_system.set_main_visualization(merged_shape)
    
    return merged_shape

# Utility functions for human-readable sizes
func format_size(size_bytes):
    """Format a byte size into a human-readable string"""
    var sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB"]
    var order = 0
    
    while size_bytes >= 1024 and order < sizes.size() - 1:
        order += 1
        size_bytes = size_bytes / 1024.0
    
    var size_str = str(stepify(size_bytes, 0.01))
    return size_str + " " + sizes[order]

func get_total_size_formatted():
    """Get the total size in a human-readable format"""
    return format_size(total_size)

func get_summary_text():
    """Get a summary of the merged projects"""
    var summary = "Project Merger Summary:\n"
    summary += "Total size: " + get_total_size_formatted() + "\n"
    summary += "Number of drives: " + str(drives.size()) + "\n"
    
    var total_projects = 0
    for drive_name in drives:
        total_projects += drives[drive_name].projects.size()
    
    summary += "Total projects found: " + str(total_projects) + "\n"
    summary += "File counts by type:\n"
    
    for file_type in file_counts:
        summary += "- " + file_type + ": " + str(file_counts[file_type]) + " files, " + format_size(file_type_sizes[file_type]) + "\n"
    
    return summary