extends Node

func _ready():
    var migration_tool = Godot4MigrationTool.new()
    add_child(migration_tool)
    
    # Set paths
    migration_tool.godot3_project_path = "."
    migration_tool.godot4_project_path = "./migrated"
    
    # Run compatibility check
    var result = migration_tool.check_compatibility(".")
    
    # Print results
    print("\n=== Migration Compatibility Report ===")
    print("Success: ", result.success)
    if result.has("error"):
        print("Error: ", result.error)
    if result.has("warnings"):
        print("\nWarnings:")
        for warning in result.warnings:
            print("- ", warning)
    if result.has("errors"):
        print("\nErrors:")
        for error in result.errors:
            print("- ", error)
    
    # Exit after printing
    get_tree().quit() 