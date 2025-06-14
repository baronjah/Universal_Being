# Master File Navigator - Maps ALL Claude Files Across PC
# JSH #memories
extends Node
class_name MasterFileNavigator

signal file_discovered(path: String, category: String)
signal connection_found(from: String, to: String, strength: float)
signal scan_completed(total_files: int)

# Master file database
var file_database = {
	"godot_projects": {},
	"claude_files": {},
	"ai_files": {},
	"screenshots": {},
	"documentation": {},
	"source_code": {}
}

# Known project locations
var project_roots = [
	"/mnt/c/Users/Percision 15/",
	"/mnt/c/Users/Percision 15/Desktop/",
	"/mnt/c/Users/Percision 15/Desktop/claude_desktop/",
	"/mnt/c/claude/",
	"/mnt/c/eden/",
	"/mnt/c/kamisama/",
	"/mnt/d/Eden/",
	"/mnt/d/Eden_Backup/",
	"/mnt/d/Godot Projects/",
	"/mnt/d/Luminus/"
]

# File patterns to track
var file_patterns = {
	"godot": ["*.gd", "*.tscn", "*.tres", "project.godot"],
	"claude": ["claude*.txt", "claude*.md", "CLAUDE.md", "instructions_*.txt"],
	"ai": ["chatgpt*.txt", "luminus*.txt", "luno*.txt", "nova*.txt"],
	"screenshots": ["*.png", "*.jpg", "screenshot*.png"],
	"docs": ["*.md", "README*", "*.txt"],
	"turns": ["turn_*.txt", "step_*.txt"]
}

# Connection strength tracking
var file_connections = {}
var import_graph = {}  # Track which files import others

func _ready():
	print("🗺️ Master File Navigator initializing...")
	print("📂 Preparing to map entire Claude ecosystem...")
	start_comprehensive_scan()

func start_comprehensive_scan():
	"""Begin scanning all known locations"""
	var total_files = 0
	
	for root in project_roots:
		print("🔍 Scanning: %s" % root)
		total_files += scan_directory_deep(root, 0)
	
	print("✅ Scan complete! Found %d relevant files" % total_files)
	analyze_connections()
	generate_navigation_report()
	scan_completed.emit(total_files)

func scan_directory_deep(path: String, depth: int) -> int:
	"""Recursively scan directory and categorize files"""
	if depth > 10:  # Prevent infinite recursion
		return 0
	
	var dir = DirAccess.open(path)
	if not dir:
		return 0
	
	var files_found = 0
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path.path_join(file_name)
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			# Skip system directories
			if not file_name in ["node_modules", ".git", "__pycache__", "AppData"]:
				files_found += scan_directory_deep(full_path, depth + 1)
		else:
			# Analyze file
			if categorize_file(full_path, file_name):
				files_found += 1
		
		file_name = dir.get_next()
	
	return files_found

func categorize_file(path: String, filename: String) -> bool:
	"""Categorize and store file information"""
	var category = determine_category(filename, path)
	
	if category == "":
		return false
	
	# Extract metadata
	var file_info = {
		"name": filename,
		"path": path,
		"category": category,
		"size": 0,
		"modified": 0,
		"connections": [],
		"importance": calculate_importance(path, filename),
		"project": identify_project(path)
	}
	
	# Get file stats if possible
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		file_info.size = file.get_length()
		file.close()
	
	# Store in appropriate database
	match category:
		"godot":
			file_database.godot_projects[path] = file_info
		"claude":
			file_database.claude_files[path] = file_info
		"ai":
			file_database.ai_files[path] = file_info
		"screenshot":
			file_database.screenshots[path] = file_info
		"documentation":
			file_database.documentation[path] = file_info
		_:
			file_database.source_code[path] = file_info
	
	file_discovered.emit(path, category)
	return true

func determine_category(filename: String, path: String) -> String:
	"""Determine file category based on name and path"""
	var lower_name = filename.to_lower()
	var lower_path = path.to_lower()
	
	# Check patterns
	if lower_name.ends_with(".gd") or lower_name.ends_with(".tscn") or lower_name == "project.godot":
		return "godot"
	elif "claude" in lower_name or "CLAUDE" in filename:
		return "claude"
	elif "chatgpt" in lower_name or "luminus" in lower_name or "luno" in lower_name:
		return "ai"
	elif lower_name.ends_with(".png") or lower_name.ends_with(".jpg"):
		if "screenshot" in lower_name:
			return "screenshot"
	elif lower_name.ends_with(".md") or "readme" in lower_name:
		return "documentation"
	elif lower_name.ends_with(".txt") and ("turn_" in lower_name or "step_" in lower_name):
		return "claude"  # Turn/step files are Claude-related
	
	return ""

func identify_project(path: String) -> String:
	"""Identify which project a file belongs to"""
	var path_lower = path.to_lower()
	
	if "eden_os" in path_lower:
		return "Eden_OS"
	elif "godot_eden" in path_lower:
		return "Godot_Eden"
	elif "luminusos" in path_lower or "luminus" in path_lower:
		return "LuminusOS"
	elif "notepad3d" in path_lower or "notepad_3d" in path_lower:
		return "Notepad3D"
	elif "akashic" in path_lower:
		return "Akashic_Records"
	elif "12_turns" in path_lower:
		return "12_Turns_System"
	elif "harmony" in path_lower:
		return "Harmony"
	elif "claude_four" in path_lower:
		return "Claude_Four_Evolution"
	else:
		return "Unknown"

func calculate_importance(path: String, filename: String) -> float:
	"""Calculate file importance for prioritization"""
	var importance = 1.0
	
	# Recent files are more important
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		file.close()
		# Check if modified recently (would need actual timestamp check)
		importance += 2.0
	
	# Key files get higher importance
	if filename in ["main.gd", "project.godot", "CLAUDE.md", "README.md"]:
		importance += 5.0
	elif "main" in filename or "core" in filename or "system" in filename:
		importance += 3.0
	elif "claude" in filename.to_lower():
		importance += 4.0
	
	# Files in key directories
	if "claude_desktop" in path or "claude_four" in path:
		importance += 2.0
	
	return importance

func analyze_connections():
	"""Analyze connections between files"""
	print("🔗 Analyzing file connections...")
	
	# Scan Godot files for imports and references
	for path in file_database.godot_projects:
		analyze_godot_imports(path)
	
	# Scan documentation for cross-references
	for path in file_database.documentation:
		analyze_doc_references(path)
	
	# Connect related projects
	connect_related_projects()

func analyze_godot_imports(file_path: String):
	"""Analyze a Godot script for imports and connections"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return
	
	var content = file.get_as_text()
	file.close()
	
	# Look for preload, load, class_name references
	var patterns = [
		"preload\\(\"([^\"]+)\"\\)",
		"load\\(\"([^\"]+)\"\\)",
		"extends\\s+(\\w+)",
		"class_name\\s+(\\w+)"
	]
	
	for pattern in patterns:
		var regex = RegEx.new()
		regex.compile(pattern)
		var results = regex.search_all(content)
		
		for result in results:
			if result.get_string_count() > 1:
				var reference = result.get_string(1)
				create_connection(file_path, reference, 1.0)

func analyze_doc_references(file_path: String):
	"""Analyze documentation for project references"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return
	
	var content = file.get_as_text()
	file.close()
	
	# Look for project names and file references
	var projects = ["Eden", "Harmony", "Luminus", "Notepad3D", "Akashic", "Claude"]
	
	for project in projects:
		if project in content:
			# Create weak connection to project
			create_connection(file_path, project, 0.5)

func connect_related_projects():
	"""Create connections between related projects"""
	var project_connections = {
		"Eden_OS": ["Godot_Eden", "Harmony"],
		"Notepad3D": ["Akashic_Records", "Claude_Four_Evolution"],
		"LuminusOS": ["12_Turns_System"],
		"12_Turns_System": ["Claude_Four_Evolution"],
		"Harmony": ["Eden_OS", "Godot_Eden"]
	}
	
	for project in project_connections:
		for related in project_connections[project]:
			create_project_connection(project, related, 0.8)

func create_connection(from: String, to: String, strength: float):
	"""Create a connection between files or entities"""
	if not file_connections.has(from):
		file_connections[from] = {}
	
	file_connections[from][to] = strength
	connection_found.emit(from, to, strength)

func create_project_connection(from_project: String, to_project: String, strength: float):
	"""Create connection between projects"""
	# Find representative files from each project
	var from_files = get_project_files(from_project)
	var to_files = get_project_files(to_project)
	
	if not from_files.is_empty() and not to_files.is_empty():
		create_connection(from_files[0], to_files[0], strength)

func get_project_files(project_name: String) -> Array:
	"""Get all files belonging to a project"""
	var files = []
	
	for category in file_database:
		for path in file_database[category]:
			if file_database[category][path].project == project_name:
				files.append(path)
	
	return files

func generate_navigation_report() -> String:
	"""Generate comprehensive navigation report"""
	var report = """
🗺️ MASTER FILE NAVIGATION REPORT
================================
Generated: %s

📊 FILE STATISTICS:
""" % Time.get_datetime_string_from_system()
	
	# Count files by category
	var total = 0
	for category in file_database:
		var count = file_database[category].size()
		total += count
		report += "- %s: %d files\n" % [category, count]
	
	report += "\nTotal Files: %d\n" % total
	
	# Project breakdown
	report += "\n🏗️ PROJECTS DISCOVERED:\n"
	var projects = {}
	
	for category in file_database:
		for path in file_database[category]:
			var project = file_database[category][path].project
			if not projects.has(project):
				projects[project] = 0
			projects[project] += 1
	
	for project in projects:
		report += "- %s: %d files\n" % [project, projects[project]]
	
	# Key connections
	report += "\n🔗 KEY CONNECTIONS:\n"
	var connection_count = 0
	for from in file_connections:
		connection_count += file_connections[from].size()
	
	report += "Total Connections: %d\n" % connection_count
	
	# Save report
	save_navigation_data()
	
	return report

func save_navigation_data():
	"""Save navigation data for future use"""
	var save_data = {
		"scan_time": Time.get_datetime_string_from_system(),
		"file_database": file_database,
		"connections": file_connections,
		"projects": {}
	}
	
	# Save to file
	var file = FileAccess.open("user://master_navigation.dat", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("💾 Navigation data saved")

func find_file(filename: String) -> Array:
	"""Find all instances of a file by name"""
	var results = []
	
	for category in file_database:
		for path in file_database[category]:
			if file_database[category][path].name == filename:
				results.append(path)
	
	return results

func get_project_summary(project_name: String) -> Dictionary:
	"""Get summary of a specific project"""
	var summary = {
		"name": project_name,
		"files": [],
		"total_size": 0,
		"categories": {},
		"key_files": []
	}
	
	for category in file_database:
		for path in file_database[category]:
			var file_info = file_database[category][path]
			if file_info.project == project_name:
				summary.files.append(path)
				summary.total_size += file_info.size
				
				if not summary.categories.has(category):
					summary.categories[category] = 0
				summary.categories[category] += 1
				
				if file_info.importance > 5.0:
					summary.key_files.append(path)
	
	return summary