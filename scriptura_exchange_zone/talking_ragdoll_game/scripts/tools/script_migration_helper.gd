# ==================================================
# SCRIPT NAME: script_migration_helper.gd
# DESCRIPTION: Helps migrate scripts to PerfectDeltaProcess pattern
# PURPOSE: Find and upgrade all scripts to follow universal rules
# CREATED: 2025-05-28 - Unifying the dream architecture
# ==================================================

extends UniversalBeingBase
signal migration_complete(total_scripts: int, migrated: int)
signal script_analyzed(path: String, needs_migration: bool)

# Migration tracking
var scripts_to_migrate: Array = []
var migration_reports: Array = []
var total_found: int = 0

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "ScriptMigrationHelper"
	print("🔄 [ScriptMigration] Ready to unify all scripts...")


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func scan_all_scripts() -> Dictionary:
	"""Scan entire project for scripts that need migration"""
	print("🔍 [ScriptMigration] Scanning all scripts...")
	
	scripts_to_migrate.clear()
	migration_reports.clear()
	total_found = 0
	
	# Scan project recursively
	_scan_directory("res://scripts/")
	
	var report = {
		"total_scripts": total_found,
		"need_migration": scripts_to_migrate.size(),
		"migration_list": scripts_to_migrate,
		"clean_scripts": total_found - scripts_to_migrate.size()
	}
	
	print("📊 [ScriptMigration] Scan complete:")
	print("   Total scripts: %d" % report.total_scripts)
	print("   Need migration: %d" % report.need_migration)
	print("   Already clean: %d" % report.clean_scripts)
	
	return report

func _scan_directory(path: String) -> void:
	"""Recursively scan directory for GDScript files"""
	var dir = DirAccess.open(path)
	if not dir:
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_scan_directory(full_path)
		elif file_name.ends_with(".gd"):
			_analyze_script(full_path)
			total_found += 1
		
		file_name = dir.get_next()

func _analyze_script(script_path: String) -> void:
	"""Analyze a script to see if it needs migration"""
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return
	
	var content = file.get_as_text()
	file.close()
	
	var analysis = {
		"path": script_path,
		"has_process": "_process(" in content,
		"has_physics_process": "_physics_process(" in content,
		"has_perfect_delta": "PerfectDeltaProcess" in content,
		"needs_migration": false,
		"migration_type": ""
	}
	
	# Determine if migration is needed
	if analysis.has_process or analysis.has_physics_process:
		if not analysis.has_perfect_delta:
			analysis.needs_migration = true
			if analysis.has_physics_process:
				analysis.migration_type = "physics"
			else:
				analysis.migration_type = "process"
			
			scripts_to_migrate.append(analysis)
			script_analyzed.emit(script_path, true)
		else:
			# Already partially migrated, check if complete
			if "_process(" in content or "_physics_process(" in content:
				analysis.needs_migration = true
				analysis.migration_type = "partial"
				scripts_to_migrate.append(analysis)
	
	migration_reports.append(analysis)

func generate_migration_plan(script_analysis: Dictionary) -> String:
	"""Generate migration instructions for a script"""
	var plan = "# Migration Plan for: %s\n" % script_analysis.path.get_file()
	plan += "# Type: %s\n\n" % script_analysis.migration_type
	
	plan += "## Current Issues:\n"
	if script_analysis.has_process:
		plan += "- Uses _process() - needs migration\n"
	if script_analysis.has_physics_process:
		plan += "- Uses _physics_process() - needs migration\n"
	
	plan += "\n## Migration Steps:\n"
	plan += "1. Add to _ready():\n"
	plan += "   PerfectDeltaProcess.register_process(self, process_managed, priority, group)\n\n"
	
	plan += "2. Replace _process(delta) with:\n"
	plan += "   func process_managed(delta: float):\n"
	plan += "       # Your existing _process code here\n\n"
	
	plan += "3. Remove old process functions:\n"
	if script_analysis.has_process:
		plan += "   # Remove: func _process(delta)\n"
	if script_analysis.has_physics_process:
		plan += "   # Remove: func _physics_process(delta)\n"
	
	plan += "\n## Suggested Priority/Group:\n"
	var file_name = script_analysis.path.get_file().to_lower()
	if "ragdoll" in file_name or "physics" in file_name:
		plan += "Priority: 80, Group: 'physics'\n"
	elif "ui" in file_name or "interface" in file_name:
		plan += "Priority: 30, Group: 'ui'\n"
	elif "render" in file_name or "visual" in file_name:
		plan += "Priority: 50, Group: 'render'\n"
	else:
		plan += "Priority: 50, Group: 'logic'\n"
	
	return plan

func auto_migrate_script(script_path: String) -> bool:
	"""Attempt automatic migration of a script"""
	print("🔄 [ScriptMigration] Auto-migrating: %s" % script_path.get_file())
	
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return false
	
	var content = file.get_as_text()
	file.close()
	
	var _original_content = content
	var modified = false
	
	# Add PerfectDelta registration if not present
	if not "PerfectDelta.register_process" in content:
		# Find _ready function or create one
		var ready_pattern = RegEx.new()
		ready_pattern.compile("func _ready\\(\\).*?:")
		
		var registration_code = "\n\t# Register with PerfectDelta\n"
		registration_code += "\tPerfectDelta.register_process(self, process_managed, 50, \"logic\")\n"
		
		if ready_pattern.search(content):
			# Add to existing _ready
			content = ready_pattern.sub(content, "$0" + registration_code, true)
		else:
			# Create _ready function
			var class_end = content.find("\nfunc ") if "\nfunc " in content else content.length()
			var new_ready = "\nfunc _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()" + registration_code + "\n"
			content = content.insert(class_end, new_ready)
		modified = true
	
	# Replace _process with process_managed
	if "_process(" in content:
		content = content.replace("func _process(", "func process_managed(")
		content = content.replace("_process(", "process_managed(")
		modified = true
	
	# Replace _physics_process with process_managed  
	if "_physics_process(" in content:
		content = content.replace("func _physics_process(", "func process_managed(")
		content = content.replace("_physics_process(", "process_managed(")
		modified = true
	
	# Add disable calls in _ready if needed
	if modified and not "set_process(false)" in content:
		var disable_code = "\n\t# Disable default processing\n"
		disable_code += "\tset_process(false)\n"
		disable_code += "\tset_physics_process(false)\n"
		
		# Add after registration
		if "register_process" in content:
			content = content.replace("register_process(self, process_managed", 
				"register_process(self, process_managed") # No change needed, just verify
	
	# Save modified content
	if modified:
		var out_file = FileAccess.open(script_path, FileAccess.WRITE)
		if out_file:
			out_file.store_string(content)
			out_file.close()
			print("✅ [ScriptMigration] Successfully migrated: %s" % script_path.get_file())
			return true
	
	return false

func migrate_all_scripts() -> void:
	"""Migrate all scripts that need it"""
	print("🚀 [ScriptMigration] Starting full migration...")
	
	var scan_result = scan_all_scripts()
	var migrated_count = 0
	
	for script_info in scripts_to_migrate:
		if auto_migrate_script(script_info.path):
			migrated_count += 1
	
	print("🎉 [ScriptMigration] Migration complete!")
	print("   Scripts migrated: %d/%d" % [migrated_count, scripts_to_migrate.size()])
	
	migration_complete.emit(scan_result.total_scripts, migrated_count)

func get_migration_report() -> String:
	"""Generate a comprehensive migration report"""
	var report = "# Script Migration Report\n"
	report += "Generated: %s\n\n" % Time.get_datetime_string_from_system()
	
	report += "## Summary\n"
	report += "- Total scripts scanned: %d\n" % total_found
	report += "- Scripts needing migration: %d\n" % scripts_to_migrate.size()
	report += "- Clean scripts: %d\n\n" % (total_found - scripts_to_migrate.size())
	
	if scripts_to_migrate.size() > 0:
		report += "## Scripts Needing Migration\n"
		for script_info in scripts_to_migrate:
			report += "### %s\n" % script_info.path.get_file()
			report += "- Path: %s\n" % script_info.path
			report += "- Type: %s\n" % script_info.migration_type
			report += "- Has _process: %s\n" % script_info.has_process
			report += "- Has _physics_process: %s\n\n" % script_info.has_physics_process
	
	return report

# Console commands
func register_console_commands() -> void:
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("migrate_scan", _cmd_scan_scripts,
			"Scan all scripts for migration needs")
		console.register_command("migrate_report", _cmd_show_report,
			"Show detailed migration report")
		console.register_command("migrate_all", _cmd_migrate_all,
			"Automatically migrate all scripts")

func _cmd_scan_scripts(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	var result = scan_all_scripts()
	
	console._print_to_console("[color=cyan]🔍 Script Migration Scan[/color]")
	console._print_to_console("Total scripts: %d" % result.total_scripts)
	console._print_to_console("Need migration: %d" % result.need_migration)
	console._print_to_console("Already clean: %d" % result.clean_scripts)

func _cmd_show_report(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager") 
	scan_all_scripts()  # Refresh data
	
	console._print_to_console("[color=yellow]📋 Migration Report[/color]")
	for script_info in scripts_to_migrate:
		console._print_to_console("• %s - %s migration needed" % [
			script_info.path.get_file(), script_info.migration_type
		])

func _cmd_migrate_all(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	console._print_to_console("[color=orange]🚀 Starting automatic migration...[/color]")
	migrate_all_scripts()
