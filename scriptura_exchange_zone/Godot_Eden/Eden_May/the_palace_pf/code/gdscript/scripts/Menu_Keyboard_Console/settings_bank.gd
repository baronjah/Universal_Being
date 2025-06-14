
#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#
# here we have access to settings of menu too
# few files in txt form too, as settings
# change, load, compare, check
# stitch, patch, load, unload
# change, understand, list
# layer, turn, process

# settings_bank.gd
extends Node3D
class_name SettingsBank

# Static variables to store settings
static var page: String = "settings"
static var path_to_main_directory: String
static var path_to_settings_file: String
static var settings_file_name: String
static var last_created_thing_number: int = 0
static var available_directory: String

static var type_of_file : String = "settings"

const type_of_settings_0 = [
	"path_to_main_directory",
	"last_created_thing_number"
]

const settings_file_blue_print_0 = {
	0: [
		["page|settings"],
		["directory_path|D:/Eden"],
		["database_path|akashic_records"],
		["file_name|settings.txt"],
		["last_thing_number|0"]
	]
}

static func change_path_to_main_directory(new_path):
	path_to_main_directory = new_path

static func check_main_directory_path():
	return path_to_main_directory

static func change_path_to_settings_file(new_path):
	path_to_settings_file = new_path

static func check_settings_file_path():
	return path_to_settings_file

static func change_settings_file_name(new_name):
	settings_file_name = new_name

static func check_settings_file_name():
	return settings_file_name

static func check_all_settings_data():

	var message_to_send : Dictionary = {
					"page": type_of_file,
					"directory_path": path_to_main_directory,
					"database_path": path_to_settings_file,
					"file_name": settings_file_name,
					"last_thing_number": last_created_thing_number,
					"available_directiory": available_directory 
	}
	return message_to_send
	
static func load_settings_file(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		while !file.eof_reached():
			#print( "file :" , file) 
			var line = file.get_line()
			print(" settings stuff : " , line)
			var parts = line.split(" : ", false, 1)  # Split only on first occurrence
			if parts.size() == 2:
				match parts[0]:
					"page":
						type_of_file = parts[1].strip_edges()
					"directory_path":
						path_to_main_directory = parts[1].strip_edges()
					"database_path":
						path_to_settings_file = parts[1].strip_edges()
					"file_name":
						settings_file_name = parts[1].strip_edges()
					"last_thing_number":
						last_created_thing_number = int(parts[1].strip_edges())
					"available_directiory":  # Note: keeping original typo for compatibility
						available_directory = parts[1].strip_edges()
		
		print("Settings loaded: " , file_path)
		print("Main directory: ", path_to_main_directory)
		print("Settings path: ", path_to_settings_file)
		print("File name: ", settings_file_name)
		print("Last thing number: ", last_created_thing_number)
		print("Available directory: ", available_directory)
		return true
	return false

static func save_settings_file(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("page : " + type_of_file)
		file.store_line("directory_path : " + path_to_main_directory)
		file.store_line("settings_path : " + path_to_settings_file)
		file.store_line("file_name : " + settings_file_name)
		file.store_line("last_thing_number : " + str(last_created_thing_number))
		file.store_line("available_directiory : " + available_directory)
		return true
	return false


# Add to SettingsBank class
static func save_settings_data(settings_data: Dictionary) -> bool:
	# Update the static variables with the new data
	if settings_data.has("directory_path"):
		path_to_main_directory = settings_data["directory_path"]
	if settings_data.has("database_path"):
		path_to_settings_file = settings_data["database_path"]
	if settings_data.has("file_name"):
		settings_file_name = settings_data["file_name"]
	if settings_data.has("last_thing_number"):
		last_created_thing_number = int(settings_data["last_thing_number"])
	if settings_data.has("available_directiory"):
		available_directory = settings_data["available_directiory"]
		
	# Now save to file
	return save_settings_file("user://settings.txt")
