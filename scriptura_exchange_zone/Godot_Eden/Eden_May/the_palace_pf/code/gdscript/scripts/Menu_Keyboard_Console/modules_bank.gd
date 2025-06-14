extends Node

class_name ModulesBank


static var multi_threading: bool
static var jsh_tasker: bool
static var jsh_records: bool
static var jsh_terminal: bool
static var jsh_database: bool

static var type_of_file : String = "modules"

const type_of_module = [
	"multi_threading",
	"jsh_tasker",
	"jsh_terminal",
	"jsh_database"
]

const module_blue_print = {
	0: [
		["page|modules"],
		["multi_threading|true"],
		["jsh_tasker|false"],
		["jsh_terminal|false"], # but wanna true
		["jsh_database|false"]
	]
}




###########







#const type_of_module = [
	#"multi_threading",
	#"jsh_tasker",
	#"jsh_terminal",
	#"jsh_database"
#]


static func change_multi_threading_mode(new_value):
	if new_value is bool:
		multi_threading = new_value
	else:
		#print("new_value : " , new_value)
		if new_value == "true":
			multi_threading = true
		else:
			multi_threading = false

static func check_multi_threading_mode():
	return multi_threading



static func change_jsh_tasker_mode(new_value):
	if new_value is bool:
		jsh_tasker = new_value
	else:
		if new_value == "true":
			jsh_tasker = true
		else:
			jsh_tasker = false


static func check_jsh_tasker_mode():
	return jsh_tasker



static func change_jsh_records_mode(new_value):
	if new_value is bool:
		jsh_records = new_value
	else:
		if new_value == "true":
			jsh_records = true
		else:
			jsh_records = false

static func check_settings_file_name():
	return jsh_records


static func change_jsh_terminal_mode(new_value):
	if new_value is bool:
		jsh_terminal = new_value
	else:
		if new_value == "true":
			jsh_terminal = true
		else:
			jsh_terminal = false

static func check_jsh_terminal_mode():
	return jsh_terminal


static func change_jsh_database_mode(new_value):
	if new_value is bool:
		jsh_database = new_value
	else:
		if new_value == "true":
			jsh_database = true
		else:
			jsh_database = false


static func check_jsh_database_mode():
	return jsh_database








static func check_all_settings_data():

	var message_to_send : Dictionary = {
					"page": type_of_file,
					"multi_threading": multi_threading,
					"jsh_tasker": jsh_tasker,
					"jsh_records": jsh_records,
					"jsh_terminal": jsh_terminal,
					"jsh_database": jsh_database 
	}
	return message_to_send
	
static func load_settings_file(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	print("modules_stuff lol")
	if file:
		while !file.eof_reached():
			#print( "file :" , file) 
			var line = file.get_line()
			print(" modules stuff : " , line)
			var parts = line.split(" : ", false, 1)  # Split only on first occurrence
			if parts.size() == 2:
				match parts[0]:
					#"page":
					#	type_of_file = parts[1].strip_edges()
					"multi_threading":
						var value = parts[1].strip_edges()
						print("modules stuff : " , value)
						change_multi_threading_mode(value)
					"jsh_tasker":
						var value = parts[1].strip_edges()
						change_jsh_tasker_mode(value)
					"jsh_records":
						var value = parts[1].strip_edges()
						change_jsh_records_mode(value)
					"jsh_terminal":
						var value = parts[1].strip_edges()
						change_jsh_terminal_mode(value)
					"jsh_database":  # Note: keeping original typo for compatibility
						var value = parts[1].strip_edges()
						change_jsh_database_mode(value)
		
		print("Settings loaded: " , file_path)
		print("multi_threading: ", multi_threading)
		print("jsh_tasker: ", jsh_tasker)
		print("jsh_records: ", jsh_records)
		print("jsh_terminal: ", jsh_terminal)
		print("jsh_database: ", jsh_database)
		return true
	return false

static func save_settings_file(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("page : " + str(type_of_file))
		file.store_line("multi_threading : " + str(multi_threading))
		file.store_line("jsh_tasker : " + str(jsh_tasker))
		file.store_line("jsh_records : " + str(jsh_records))
		file.store_line("jsh_terminal : " + str(jsh_terminal))
		file.store_line("jsh_database : " + str(jsh_database))
		return true
	return false


# Add to SettingsBank class
static func save_settings_data(settings_data: Dictionary) -> bool:
	# Update the static variables with the new data
	if settings_data.has("multi_threading"):
		var value = settings_data["multi_threading"]
		change_multi_threading_mode(value)
	if settings_data.has("jsh_tasker"):
		var value = settings_data["jsh_tasker"]
		change_jsh_tasker_mode(value)
	if settings_data.has("jsh_records"):
		var value = settings_data["jsh_records"]
		change_jsh_records_mode(value)
	if settings_data.has("jsh_terminal"):
		var value = settings_data["jsh_terminal"]
		change_jsh_terminal_mode(value)
	if settings_data.has("jsh_database"):
		var value = settings_data["jsh_database"]
		change_jsh_database_mode(value)
		
	# Now save to file
	return save_settings_file("user://settings.txt")
