# Create required directories for the Akashic Records system
# This script can be run from the Godot editor to create the necessary directories

extends Node

func _ready():
    # Define the base directory path - adjust this to match your project path
    var base_dir = "res://dictionary/"
    
    # Define subdirectories
    var subdirs = [
        "",  # Main dictionary directory
        "elements/",
        "entities/",
        "interactions/",
        "zones/"
    ]
    
    # Create directories
    var dir = DirAccess.open("res://")
    if dir:
        print("Creating Akashic Records directories...")
        
        for subdir in subdirs:
            var full_path = base_dir + subdir
            
            # Create directory if it doesn't exist
            if not dir.dir_exists(full_path):
                var err = dir.make_dir_recursive(full_path)
                if err == OK:
                    print("Created directory: " + full_path)
                else:
                    push_error("Failed to create directory: " + full_path + " Error: " + str(err))
            else:
                print("Directory already exists: " + full_path)
        
        print("Directory creation complete!")
    else:
        push_error("Failed to open base directory for creating Akashic Records folders")
    
    # Exit after creating directories (if this is run as a standalone script)
    get_tree().quit()