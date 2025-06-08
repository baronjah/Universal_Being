# ==================================================
# AUTO REGISTER FALLBACKS - Scans project for same-named classes
# ==================================================

extends Node

func _ready():
	auto_discover_and_register_fallbacks()

func auto_discover_and_register_fallbacks():
	print("🔍 Auto-discovering fallback implementations...")
	
	var class_files = {}
	scan_directory_for_classes("res://", class_files)
	
	# Register all implementations of each class
	for class_names in class_files.keys():
		var implementations = class_files[class_names]
		if implementations.size() > 1:
			print("📋 Found " + str(implementations.size()) + " implementations of " + class_names)
			
			for impl in implementations:
				var priority = get_priority_from_filename(impl.path)
				# UniversalFallbackSystem.register_class_implementation(class_names, impl.path, priority)
				print("  ✅ " + impl.path + " (priority: " + str(priority) + ")")

func scan_directory_for_classes(path: String, class_files: Dictionary):
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			scan_directory_for_classes(full_path, class_files)
		elif file_name.ends_with(".gd"):
			var class_names = extract_class_name(full_path)
			if class_names != "":
				if not class_files.has(class_names):
					class_files[class_names] = []
				class_files[class_names].append({"path": full_path, "name": file_name})
		
		file_name = dir.get_next()

func extract_class_name(file_path: String) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return ""
	
	var content = file.get_as_text()
	file.close()
	
	# Look for class_name declaration
	var regex = RegEx.new()
	regex.compile("class_name\\s+([A-Za-z_][A-Za-z0-9_]*)")
	var result = regex.search(content)
	
	if result:
		return result.get_string(1)
	return ""

func get_priority_from_filename(file_path: String) -> int:
	# Higher priority for files with certain keywords
	var filename = file_path.get_file().to_lower()
	
	if "advanced" in filename or "enhanced" in filename:
		return 200
	elif "base" in filename or "basic" in filename:
		return 100
	elif "experimental" in filename:
		return 50
	else:
		return 150  # Default priority
