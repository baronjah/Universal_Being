extends Node

class_name ProjectMergerConnector

# Reference to the systems
var project_merger
var cloud_noise_generator
var ethereal_tunnel_manager

# Configuration
var auto_visualize = true
var dimension_mapping = {
    "script": 3,
    "scene": 4,
    "resource": 3,
    "config": 2,
    "data": 5,
    "other": 2
}

func _init():
    print("Initializing Project Merger Connector")

func initialize(merger, noise_gen, tunnel_mgr = null):
    """Initialize with references to required systems"""
    project_merger = merger
    cloud_noise_generator = noise_gen
    ethereal_tunnel_manager = tunnel_mgr
    
    # Connect signals
    project_merger.connect("scan_completed", self, "_on_scan_completed")
    project_merger.connect("merge_completed", self, "_on_merge_completed")
    
    project_merger.cloud_noise_generator = cloud_noise_generator
    
    print("Project Merger Connector initialized")
    return self

func scan_all_drives():
    """Trigger a scan of all drives"""
    if project_merger == null:
        print("Project merger not initialized")
        return null
    
    return project_merger.scan_all_drives()

func merge_to_drive(target_drive_name = null):
    """Merge all projects to a target drive"""
    if project_merger == null:
        print("Project merger not initialized")
        return null
    
    return project_merger.merge_projects(target_drive_name)

func register_all_local_drives():
    """Auto-detect and register all available local drives"""
    # This would use platform-specific methods to find drives
    # For now, just register the C and D drives on Windows
    
    project_merger.register_drive("/mnt/c", "local", "C")
    
    # Check if D drive exists
    var dir = Directory.new()
    if dir.dir_exists("/mnt/d"):
        project_merger.register_drive("/mnt/d", "local", "D")
    
    # Register the user's home directory
    project_merger.register_drive("/home", "local", "Home")
    
    print("Registered all available local drives")

func register_google_drive(credentials_path = ""):
    """Register Google Drive as a source"""
    # This would use Google Drive API in a real implementation
    project_merger.register_drive("google_drive://", "google_drive", "GoogleDrive")
    print("Registered Google Drive")

func create_drive_tunnels():
    """Create ethereal tunnels between drives"""
    if ethereal_tunnel_manager == null:
        print("Ethereal tunnel manager not available")
        return
    
    # Create tunnel anchors for each drive
    var anchors = {}
    var base_coordinates = Vector3(0, 0, 0)
    var position_offset = 10.0
    
    var i = 0
    for drive_name in project_merger.drives:
        var drive = project_merger.drives[drive_name]
        var drive_pos = base_coordinates + Vector3(
            sin(i * PI/3) * position_offset,
            cos(i * PI/3) * position_offset,
            0
        )
        
        var anchor_id = "drive_" + drive_name
        anchors[drive_name] = ethereal_tunnel_manager.register_anchor(
            anchor_id,
            drive_pos,
            "drive"
        )
        
        # Set properties on the anchor
        anchors[drive_name].set_property("drive_path", drive.path)
        anchors[drive_name].set_property("drive_type", drive.type)
        anchors[drive_name].set_property("size", drive.size)
        
        i += 1
    
    # Create tunnels between all drives
    var drive_names = project_merger.drives.keys()
    for i in range(drive_names.size()):
        var source_name = drive_names[i]
        
        for j in range(i+1, drive_names.size()):
            var target_name = drive_names[j]
            
            var tunnel_id = "drive_tunnel_" + source_name + "_to_" + target_name
            ethereal_tunnel_manager.create_tunnel(
                tunnel_id,
                anchors[source_name],
                anchors[target_name]
            )
    
    print("Created drive tunnels in the ethereal network")

func generate_merged_visualization(stats):
    """Generate visualization for merged projects"""
    if cloud_noise_generator == null:
        print("Cloud noise generator not available")
        return null
    
    # Create a unified cloud shape
    var cloud_shape = cloud_noise_generator.generate_cloud_shape(
        "cube", 
        "perlin",
        3,
        1.0,
        1.0
    )
    
    # Add components for each file type
    if stats.has("file_types"):
        var type_shapes = []
        var i = 0
        var position_scale = 0.5
        
        for file_type in stats.file_types:
            var type_count = stats.file_types[file_type]
            var type_dimension = dimension_mapping.get(file_type, 3)
            
            if type_count > 0:
                var type_size = 0.3 + log(type_count) / 10.0
                
                # Choose shape based on file type
                var shape_type = "sphere"
                match file_type:
                    "script": shape_type = "cube"
                    "scene": shape_type = "pyramid"
                    "resource": shape_type = "cylinder"
                    "config": shape_type = "octahedron"
                    "data": shape_type = "disk"
                    "other": shape_type = "icosphere"
                
                # Generate component shape
                var component = cloud_noise_generator.generate_cloud_shape(
                    shape_type,
                    "simplex",
                    type_dimension,
                    type_size,
                    0.8
                )
                
                # Position component around center
                var angle = i * (2 * PI / stats.file_types.size())
                var position = Vector3(
                    cos(angle) * position_scale,
                    sin(angle) * position_scale,
                    0
                )
                
                cloud_noise_generator.set_cloud_position(component.id, position)
                
                # Apply color based on file type
                var color
                match file_type:
                    "script": color = Color(0.2, 0.7, 1.0)  # Blue
                    "scene": color = Color(0.2, 1.0, 0.3)   # Green
                    "resource": color = Color(1.0, 0.7, 0.2) # Orange
                    "config": color = Color(0.7, 0.2, 1.0)  # Purple
                    "data": color = Color(1.0, 1.0, 0.2)    # Yellow
                    "other": color = Color(0.5, 0.5, 0.5)   # Gray
                
                cloud_noise_generator.apply_color_to_cloud(component.id, color)
                
                # Add to type shapes array
                type_shapes.append(component)
                i += 1
        
        # Combine all component shapes with the main shape
        if type_shapes.size() > 0:
            var combined = cloud_noise_generator.combine_clouds([cloud_shape] + type_shapes)
            return combined
    
    return cloud_shape

func _on_scan_completed(stats):
    """Handle scan completion"""
    print("Scan completed:")
    print("- Total size: " + project_merger.get_total_size_formatted())
    print("- Drives: " + str(stats.drive_count))
    
    # Create visualization if auto_visualize is enabled
    if auto_visualize and cloud_noise_generator != null:
        var visualization = generate_scan_visualization(stats)
        print("Generated scan visualization with ID: " + str(visualization.id))

func _on_merge_completed(stats):
    """Handle merge completion"""
    print("Merge completed:")
    print("- Merged projects: " + str(stats.merged_projects))
    print("- Merged files: " + str(stats.merged_files))
    print("- Total size: " + project_merger.format_size(stats.total_size))
    
    # Create visualization if auto_visualize is enabled
    if auto_visualize and cloud_noise_generator != null:
        var visualization = generate_merged_visualization(stats)
        print("Generated merge visualization with ID: " + str(visualization.id))

func generate_scan_visualization(stats):
    """Generate visualization for scan results"""
    if cloud_noise_generator == null:
        return null
    
    # Create a cloud shape for each drive
    var drive_clouds = []
    var i = 0
    
    for drive_name in project_merger.drives:
        var drive = project_merger.drives[drive_name]
        
        # Skip drives with no size
        if drive.size <= 0:
            continue
        
        # Calculate size relative to total
        var relative_size = sqrt(drive.size / float(project_merger.total_size))
        var size = 0.5 + relative_size * 2.0
        
        # Generate cloud shape for drive
        var cloud = cloud_noise_generator.generate_cloud_shape(
            "sphere",
            "perlin",
            3,
            size,
            0.7 + relative_size
        )
        
        # Position around center
        var angle = i * (2 * PI / project_merger.drives.size())
        var radius = 2.0 + relative_size
        var position = Vector3(
            cos(angle) * radius,
            sin(angle) * radius,
            0
        )
        
        cloud_noise_generator.set_cloud_position(cloud.id, position)
        
        # Add to array
        drive_clouds.append(cloud)
        i += 1
    
    # Combine into a single visualization
    if drive_clouds.size() > 0:
        return cloud_noise_generator.combine_clouds(drive_clouds)
    else:
        return cloud_noise_generator.generate_cloud_shape("sphere", "perlin", 3, 1.0, 1.0)

func get_detailed_statistics():
    """Get detailed statistics about merged projects"""
    var stats = {
        "total_size": project_merger.total_size,
        "total_size_formatted": project_merger.get_total_size_formatted(),
        "drive_count": project_merger.drives.size(),
        "file_counts": project_merger.file_counts.duplicate(),
        "file_sizes": project_merger.file_type_sizes.duplicate(),
        "drives": {}
    }
    
    # Add drive-specific information
    for drive_name in project_merger.drives:
        var drive = project_merger.drives[drive_name]
        stats.drives[drive_name] = {
            "path": drive.path,
            "type": drive.type,
            "size": drive.size,
            "size_formatted": project_merger.format_size(drive.size),
            "file_count": drive.file_count,
            "project_count": drive.projects.size()
        }
    
    return stats