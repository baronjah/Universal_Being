extends Node

# Simple virtual file system for LuminusOS

var root_directory = {
	"name": "/",
	"type": "directory",
	"children": {}
}

var current_directory_path = "/"
var current_directory = root_directory

func _ready():
	# Initialize some default directories and files
	create_directory("/Home")
	create_directory("/Home/Documents")
	create_directory("/Home/Programs")
	create_directory("/System")
	
	# Create some sample files
	write_file("/Home/welcome.txt", "Welcome to LuminusOS!\nThis is a sample text file.")
	write_file("/Home/Programs/hello.ls", "// LuminusOS Script\nfunc main() {\n  Print(\"Hello, World!\");\n  return 0;\n}")
	write_file("/System/about.txt", "LuminusOS v1.0\nInspired by TempleOS\nCreated with Godot 4.4")

# File system navigation
func get_current_directory():
	return current_directory

func get_current_path():
	return current_directory_path
	
func change_directory(path):
	var target_dir = get_directory(path)
	if target_dir:
		if path.begins_with("/"):
			current_directory_path = path
		else:
			if current_directory_path.ends_with("/"):
				current_directory_path += path
			else:
				current_directory_path += "/" + path
		current_directory = target_dir
		return true
	return false
	
# File system operations
func create_directory(path):
	var parent_path = get_parent_path(path)
	var dir_name = get_name_from_path(path)
	
	var parent = get_directory(parent_path)
	if parent:
		parent["children"][dir_name] = {
			"name": dir_name,
			"type": "directory",
			"children": {}
		}
		return true
	return false

func write_file(path, content):
	var parent_path = get_parent_path(path)
	var file_name = get_name_from_path(path)
	
	var parent = get_directory(parent_path)
	if parent:
		parent["children"][file_name] = {
			"name": file_name,
			"type": "file",
			"content": content
		}
		return true
	return false

func read_file(path):
	var file = get_file(path)
	if file and file["type"] == "file":
		return file["content"]
	return null

func list_directory(path=""):
	var dir = current_directory
	if path != "":
		dir = get_directory(path)
	
	if dir:
		var files = []
		for child_name in dir["children"]:
			var child = dir["children"][child_name]
			var type_indicator = "[DIR] " if child["type"] == "directory" else "[FILE]"
			files.append(type_indicator + " " + child["name"])
		return files
	return []

# Helper functions
func get_directory(path):
	if path == "" or path == "/":
		return root_directory
		
	var normalized_path = path
	if not normalized_path.begins_with("/"):
		if current_directory_path.ends_with("/"):
			normalized_path = current_directory_path + normalized_path
		else:
			normalized_path = current_directory_path + "/" + normalized_path
	
	var parts = normalized_path.split("/")
	parts = parts.filter(func(part): return part != "")
	
	var current = root_directory
	for part in parts:
		if part == "..":
			# Go up one directory
			var parent_path = get_parent_path(normalized_path)
			current = get_directory(parent_path)
		elif part == ".":
			# Stay in current directory
			continue
		else:
			if current["children"].has(part) and current["children"][part]["type"] == "directory":
				current = current["children"][part]
			else:
				return null
	
	return current

func get_file(path):
	var parent_path = get_parent_path(path)
	var file_name = get_name_from_path(path)
	
	var parent = get_directory(parent_path)
	if parent and parent["children"].has(file_name):
		return parent["children"][file_name]
	return null

func get_parent_path(path):
	if path == "/" or path == "":
		return "/"
		
	var parts = path.split("/")
	parts = parts.filter(func(part): return part != "")
	
	if parts.size() <= 1:
		return "/"
		
	parts.pop_back()
	return "/" + "/".join(parts)

func get_name_from_path(path):
	var parts = path.split("/")
	parts = parts.filter(func(part): return part != "")
	
	if parts.size() == 0:
		return ""
		
	return parts[parts.size() - 1]