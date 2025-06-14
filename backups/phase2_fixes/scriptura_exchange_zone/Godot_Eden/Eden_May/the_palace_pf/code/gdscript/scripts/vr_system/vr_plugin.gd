@tool
extends EditorPlugin

func _enter_tree():
	# Register VR autoload singleton
	add_autoload_singleton("VRManager", "res://code/gdscript/scripts/vr_system/vr_manager.gd")
	
	# Add custom types for integration
	add_custom_type("VRSceneSetup", "Node", preload("res://code/gdscript/scripts/vr_system/vr_scene_setup.gd"), preload("res://icon.png"))
	add_custom_type("VRAkashicInterface", "Node", preload("res://code/gdscript/scripts/vr_system/vr_akashic_interface.gd"), preload("res://icon.png"))
	
	print("VR Plugin initialized")

func _exit_tree():
	# Remove autoload singleton
	remove_autoload_singleton("VRManager")
	
	# Remove custom types
	remove_custom_type("VRSceneSetup")
	remove_custom_type("VRAkashicInterface")
	
	print("VR Plugin unloaded")

func _has_main_screen():
	return false

func _get_plugin_name():
	return "Eden VR"

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")

func _handles(object):
	return false