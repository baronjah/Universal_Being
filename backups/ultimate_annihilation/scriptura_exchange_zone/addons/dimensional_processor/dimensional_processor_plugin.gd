tool
extends EditorPlugin

func _enter_tree():
    # Add DimensionalProcessorManager singleton
    add_autoload_singleton("DimensionalProcessor", "res://addons/dimensional_processor/dimensional_processor.gd")
    
    # Log that the plugin was enabled
    print("12-Dimensional Data Processor plugin enabled")

func _exit_tree():
    # Remove the autoload singleton
    remove_autoload_singleton("DimensionalProcessor")
    
    # Log that the plugin was disabled
    print("12-Dimensional Data Processor plugin disabled")