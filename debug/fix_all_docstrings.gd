extends Node

# Fix all docstring issues in GDScript files
# Converts Python-style """ docstrings to # comments

static func fix_docstrings_in_project():
	print("🔧 Fixing docstring issues in all GDScript files...")
	
	var dir = DirAccess.open("res://")
	if not dir:
		print("❌ Failed to open project directory")
		return
	
	var fixed_count = 0
	_process_directory(dir, "res://", fixed_count)
	
	print("✅ Fixed %d files with docstring issues" % fixed_count)

static func _process_directory(dir: DirAccess, path: String, fixed_count: int):
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			var subdir = DirAccess.open(full_path)
			if subdir:
				_process_directory(subdir, full_path, fixed_count)
		elif file_name.ends_with(".gd"):
			if _fix_file_docstrings(full_path):
				fixed_count += 1
		
		file_name = dir.get_next()

static func _fix_file_docstrings(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var content = file.get_as_text()
	file.close()
	
	# Pattern to match function with docstring
	var regex = RegEx.new()
	regex.compile('(func\\s+\\w+\\s*\\([^)]*\\)[^:]*:\\s*\\n\\s*)"""([^"]+)"""')
	
	var fixed_content = content
	var has_changes = false
	
	# Replace all docstrings with comments
	for match in regex.search_all(content):
		var full_match = match.get_string(0)
		var func_part = match.get_string(1)
		var doc_text = match.get_string(2).strip_edges()
		
		var replacement = func_part + "# " + doc_text
		fixed_content = fixed_content.replace(full_match, replacement)
		has_changes = true
	
	if has_changes:
		file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			file.store_string(fixed_content)
			file.close()
			print("✅ Fixed docstrings in: %s" % file_path)
			return true
	
	return false
