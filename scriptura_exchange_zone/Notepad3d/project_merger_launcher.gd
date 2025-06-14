extends Node

# Project Merger Launcher
# This script initializes and runs the project merger system,
# integrating it with the unified cloud noise generator.

var project_merger
var cloud_noise_generator
var ethereal_tunnel_manager
var merger_connector

func _ready():
    print("Initializing Project Merger System")
    initialize_systems()
    register_drives()
    run_merger()

func initialize_systems():
    """Initialize all required systems"""
    # Create the cloud noise generator
    cloud_noise_generator = preload("res://unified_cloud_noise.gd").new()
    add_child(cloud_noise_generator)
    
    # Create the ethereal tunnel manager
    ethereal_tunnel_manager = preload("res://ethereal_tunnel.gd").new()
    add_child(ethereal_tunnel_manager)
    
    # Create the project merger
    project_merger = UnifiedProjectMerger.new()
    add_child(project_merger)
    
    # Create and initialize the connector
    merger_connector = ProjectMergerConnector.new()
    add_child(merger_connector)
    merger_connector.initialize(project_merger, cloud_noise_generator, ethereal_tunnel_manager)
    
    print("All systems initialized")

func register_drives():
    """Register drives for merging"""
    # Register local drives
    merger_connector.register_all_local_drives()
    
    # Register Google Drive if available
    if OS.get_name() != "Server" and OS.has_feature("Google"):
        merger_connector.register_google_drive()
    
    # Create tunnels between drives
    merger_connector.create_drive_tunnels()
    
    print("All drives registered")

func run_merger():
    """Run the merging process"""
    print("Starting drive scan")
    var scan_stats = merger_connector.scan_all_drives()
    
    # Print the scan summary
    print("\nScan Summary:")
    print(project_merger.get_summary_text())
    
    # Perform the merge
    print("\nStarting project merge")
    var merge_stats = merger_connector.merge_to_drive()
    
    # Generate visualization
    var visualization = merger_connector.generate_merged_visualization(merge_stats)
    
    # Output final stats
    var detailed_stats = merger_connector.get_detailed_statistics()
    print("\nMerge completed with the following statistics:")
    print("- Total size: " + detailed_stats.total_size_formatted)
    print("- Total drives: " + str(detailed_stats.drive_count))
    
    var file_count_sum = 0
    for type in detailed_stats.file_counts:
        file_count_sum += detailed_stats.file_counts[type]
    
    print("- Total files: " + str(file_count_sum))
    
    print("\nDetailed file type statistics:")
    for type in detailed_stats.file_counts:
        var type_size = project_merger.format_size(detailed_stats.file_sizes[type])
        print("- " + type + ": " + str(detailed_stats.file_counts[type]) + " files, " + type_size)
    
    print("\nDrive statistics:")
    for drive_name in detailed_stats.drives:
        var drive = detailed_stats.drives[drive_name]
        print("- " + drive_name + " (" + drive.type + "): " + 
              drive.size_formatted + ", " + 
              str(drive.file_count) + " files, " +
              str(drive.project_count) + " projects")
    
    # Return stats for any caller
    return {
        "scan_stats": scan_stats,
        "merge_stats": merge_stats,
        "detailed_stats": detailed_stats,
        "visualization": visualization
    }

# Direct execution entry point
func _run_from_command_line():
    """Run the merger directly from command line"""
    initialize_systems()
    register_drives()
    run_merger()
    
    # Output final message
    print("\nProject merger completed successfully")
    print("Total size: " + project_merger.get_total_size_formatted())
    
    # Clean up and quit
    yield(get_tree().create_timer(1.0), "timeout")
    get_tree().quit()

# Command-line execution check
if OS.has_feature("standalone"):
    _run_from_command_line()