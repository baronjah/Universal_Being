@tool
extends EditorScript

# This script updates import paths in all scripts to reference the new file locations
# Run it in the Godot editor to update paths throughout the project

func _run():
	print("Updating import paths...")
	
	# Define mappings for old paths to new paths
	var path_mappings = {
		"res://code/gdscript/scripts/akashic_records/thing_creator.gd": "res://code/gdscript/scripts/core/core_thing_creator.gd",
		"res://code/gdscript/scripts/akashic_records/akashic_records_manager.gd": "res://code/gdscript/scripts/core/core_akashic_records_manager.gd",
		"res://code/gdscript/scripts/UniversalBridge.gd": "res://code/gdscript/scripts/core/universal_bridge.gd",
		"res://code/gdscript/scripts/akashic_records/thing_creator_ui.gd": "res://code/gdscript/scripts/ui/thing_creator_ui.gd",
		"res://code/gdscript/scripts/akashic_records/thing_creator_standalone.gd": "res://code/gdscript/scripts/ui/thing_creator_standalone.gd",
		"res://code/gdscript/scripts/kamisama_home/thing_creator_standalone.gd": "res://code/gdscript/scripts/ui/thing_creator_standalone.gd",
		"res://code/gdscript/scripts/akashic_records/console_integration_helper.gd": "res://code/gdscript/scripts/integration/console_integration_helper.gd",
		# New Core paths
		"res://code/gdscript/scripts/core/thing_creator.gd": "res://code/gdscript/scripts/core/core_thing_creator.gd",
		"res://code/gdscript/scripts/core/akashic_records_manager.gd": "res://code/gdscript/scripts/core/core_akashic_records_manager.gd",
		"res://code/gdscript/scripts/core/universal_bridge.gd": "res://code/gdscript/scripts/core/universal_bridge.gd"
	}
	
	# Define class name mappings (old to new)
	var class_mappings = {
		"ThingCreatorA": "ThingCreator",
		"AkashicRecordsManagerA": "AkashicRecordsManager",
		"ThingCreatorStandaloneA": "ThingCreatorStandalone",
		"ThingCreatorUIA": "ThingCreatorUI",
		# New Core prefix mappings
		"ThingCreator": "CoreThingCreator",
		"AkashicRecordsManager": "CoreAkashicRecordsManager",
		"ThingCreatorStandalone": "CoreThingCreatorStandalone",
		"ThingCreatorUI": "CoreThingCreatorUI",
		"UniversalBridge": "CoreUniversalBridge",
		"EntityManager": "CoreEntityManager"
	}
	
	# Get all scripts in the project
	var scripts = _find_all_scripts("res://")
	print("Found " + str(scripts.size()) + " script files")
	
	var updated_count = 0
	
	# Update each script
	for script_path in scripts:
		# Skip the scripts we just created
		if script_path.begins_with("res://code/gdscript/scripts/core/") or \
		   script_path.begins_with("res://code/gdscript/scripts/ui/") or \
		   script_path.begins_with("res://code/gdscript/scripts/integration/"):
			continue
			
		var updated = _update_script_imports(script_path, path_mappings, class_mappings)
		if updated:
			updated_count += 1
	
	print("Updated " + str(updated_count) + " scripts")

# Find all GDScript files in the project
func _find_all_scripts(path):
	var scripts = []
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			var full_path = path + "/" + file_name
			
			if dir.current_is_dir() and not file_name.begins_with("."):
				scripts.append_array(_find_all_scripts(full_path))
			elif file_name.ends_with(".gd"):
				scripts.append(full_path)
				
			file_name = dir.get_next()
	
	return scripts

# Update imports and class references in a script
func _update_script_imports(script_path, path_mappings, class_mappings):
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return false
		
	var content = file.get_as_text()
	file.close()
	
	var original_content = content
	
	# Update path imports (preload and load)
	for old_path in path_mappings:
		var new_path = path_mappings[old_path]
		content = content.replace('preload("' + old_path + '")', 'preload("' + new_path + '")')
		content = content.replace('load("' + old_path + '")', 'load("' + new_path + '")')
	
	# Update class references
	for old_class in class_mappings:
		var new_class = class_mappings[old_class]
		
		# Update variable type declarations
		content = content.replace("var thing_creator: " + old_class, "var thing_creator: " + new_class)
		content = content.replace("var akashic_records_manager: " + old_class, "var akashic_records_manager: " + new_class)
		
		# Update function return types
		content = content.replace("-> " + old_class, "-> " + new_class)
		
		# Update class references in code
		content = content.replace(" " + old_class + ".", " " + new_class + ".")
		content = content.replace("(" + old_class + ".", "(" + new_class + ".")
		
		# Update get_instance() calls
		content = content.replace(old_class + ".get_instance()", new_class + ".get_instance()")
	
	# Only write if content has changed
	if content != original_content:
		file = FileAccess.open(script_path, FileAccess.WRITE)
		if file:
			file.store_string(content)
			file.close()
			print("Updated: " + script_path)
			return true
	
	return false
