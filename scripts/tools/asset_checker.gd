# Asset Checker - Universal Being Asset Validation System
# Validates .ub.zip assets follow Pentagon Architecture rules

extends UniversalBeing
#class_name UniversalBeingAssetChecker # Commented to avoid duplicate

enum ValidationResult { VALID, WARNING, ERROR, CRITICAL }

class ValidationReport:
	var asset_path: String
	var result: ValidationResult = ValidationResult.VALID
	var issues: Array[Dictionary] = []
	var manifest_data: Dictionary = {}
	var pentagon_compliance: bool = false
	var consciousness_valid: bool = false
	
	func add_issue(level: ValidationResult, message: String, file: String = "") -> void:
		issues.append({
			"level": level,
			"message": message, 
			"file": file,
			"timestamp": Time.get_datetime_string_from_system()
		})
		if level > result:
			result = level

static func validate_asset(asset_path: String) -> ValidationReport:
	"""Validate a .ub.zip asset file"""
	var report = ValidationReport.new()
	report.asset_path = asset_path
	
	print("🔍 Validating asset: %s" % asset_path)
	
	# Check if file exists and is ZIP
	if not FileAccess.file_exists(asset_path):
		report.add_issue(ValidationResult.CRITICAL, "Asset file not found", asset_path)
		return report
	
	if not asset_path.ends_with(".ub.zip"):
		report.add_issue(ValidationResult.ERROR, "Asset must be .ub.zip format", asset_path)
	
	# Extract and validate ZIP contents
	var zip_reader = ZIPReader.new()
	var err = zip_reader.open(asset_path)
	if err != OK:
		report.add_issue(ValidationResult.CRITICAL, "Cannot open ZIP file: " + str(err), asset_path)
		return report
	
	var files = zip_reader.get_files()
	print("📁 Found %d files in asset" % files.size())
	
	# Validate manifest.json
	if not _validate_manifest(zip_reader, files, report):
		return report
	
	# Validate Pentagon Architecture compliance
	_validate_pentagon_compliance(zip_reader, files, report)
	
	# Validate consciousness system
	_validate_consciousness_system(report)
	
	# Validate file structure
	_validate_file_structure(files, report)
	
	zip_reader.close()
	
	# Final assessment
	if report.result == ValidationResult.VALID:
		print("✅ Asset validation PASSED: %s" % asset_path)
	else:
		print("❌ Asset validation FAILED: %s (%s)" % [asset_path, _result_to_string(report.result)])
	
	return report

static func _validate_manifest(zip_reader: ZIPReader, files: PackedStringArray, report: ValidationReport) -> bool:
	"""Validate manifest.json exists and is properly structured"""
	
	if not "manifest.json" in files:
		report.add_issue(ValidationResult.CRITICAL, "Missing required manifest.json file")
		return false
	
	var manifest_data = zip_reader.read_file("manifest.json")
	if manifest_data.is_empty():
		report.add_issue(ValidationResult.CRITICAL, "Cannot read manifest.json")
		return false
	
	var json = JSON.new()
	var parse_result = json.parse(manifest_data.get_string_from_utf8())
	if parse_result != OK:
		report.add_issue(ValidationResult.CRITICAL, "Invalid JSON in manifest.json")
		return false
	
	var manifest = json.data
	report.manifest_data = manifest
	
	# Validate required manifest fields
	var required_fields = ["name", "version", "type", "consciousness_level", "description"]
	for field in required_fields:
		if not field in manifest:
			report.add_issue(ValidationResult.ERROR, "Missing required manifest field: " + field, "manifest.json")
	
	# Validate consciousness level
	if "consciousness_level" in manifest:
		var level = manifest.consciousness_level
		if typeof(level) != TYPE_INT or level < 0 or level > 5:
			report.add_issue(ValidationResult.ERROR, "Invalid consciousness_level: must be 0-5", "manifest.json")
		else:
			report.consciousness_valid = true
	
	# Validate asset type
	if "type" in manifest:
		var valid_types = ["being", "component", "scene", "material", "sound", "texture"]
		if not manifest.type in valid_types:
			report.add_issue(ValidationResult.WARNING, "Unknown asset type: " + str(manifest.type), "manifest.json")
	
	return true

static func _validate_pentagon_compliance(zip_reader: ZIPReader, files: PackedStringArray, report: ValidationReport) -> void:
	"""Check Pentagon Architecture compliance in all .gd files"""
	
	var gd_files = files.filter(func(f): return f.ends_with(".gd"))
	print("🔍 Checking %d GDScript files for Pentagon compliance" % gd_files.size())
	
	for file_path in gd_files:
		var content = zip_reader.read_file(file_path).get_string_from_utf8()
		_check_script_pentagon_compliance(content, file_path, report)

static func _check_script_pentagon_compliance(content: String, file_path: String, report: ValidationReport) -> void:
	"""Check individual script for Pentagon compliance"""
	
	var lines = content.split("\n")
	var has_pentagon_functions = false
	var has_godot_violations = false
	var extends_universal_being = false
	
	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		
		# Check if extends UniversalBeing
		if line.begins_with("extends UniversalBeing"):
			extends_universal_being = true
		
		# Check for Pentagon functions
		if line.contains("func pentagon_"):
			has_pentagon_functions = true
		
		# Check for Godot function violations (only in Universal Being scripts)
		if extends_universal_being and (line.contains("func _ready(") or line.contains("func _process(") or line.contains("func _input(")):
			has_godot_violations = true
			report.add_issue(ValidationResult.ERROR, 
				"Pentagon violation: Universal Being using Godot function at line %d" % (i+1), 
				file_path)
	
	if extends_universal_being and not has_pentagon_functions:
		report.add_issue(ValidationResult.WARNING, "Universal Being has no Pentagon functions", file_path)
	
	if extends_universal_being and not has_godot_violations:
		report.pentagon_compliance = true

static func _validate_consciousness_system(report: ValidationReport) -> void:
	"""Validate consciousness-related properties"""
	
	var manifest = report.manifest_data
	if not manifest.has("consciousness_traits"):
		report.add_issue(ValidationResult.WARNING, "No consciousness_traits defined in manifest")
		return
	
	var traits = manifest.consciousness_traits
	var valid_trait_names = ["creativity", "harmony", "evolution_rate", "resonance", "stability"]
	
	for trait_name in traits:
		if not trait_name in valid_trait_names:
			report.add_issue(ValidationResult.WARNING, "Unknown consciousness trait: " + trait_name, "manifest.json")
		
		var value = traits[trait_name]
		if typeof(value) != TYPE_FLOAT or value < 0.0 or value > 1.0:
			report.add_issue(ValidationResult.ERROR, "Consciousness trait %s must be float 0.0-1.0" % trait_name, "manifest.json")

static func _validate_file_structure(files: PackedStringArray, report: ValidationReport) -> void:
	"""Validate overall file structure"""
	
	var has_scripts = false
	var has_main_script = false
	var has_documentation = false
	
	for file_path in files:
		if file_path.begins_with("scripts/") and file_path.ends_with(".gd"):
			has_scripts = true
			if file_path == "scripts/main_script.gd":
				has_main_script = true
		
		if file_path.ends_with("documentation.md") or file_path.ends_with("README.md"):
			has_documentation = true
	
	if not has_scripts:
		report.add_issue(ValidationResult.WARNING, "No scripts/ folder found")
	
	if not has_main_script:
		report.add_issue(ValidationResult.WARNING, "No main_script.gd found in scripts/")
	
	if not has_documentation:
		report.add_issue(ValidationResult.WARNING, "No documentation file found")

static func _result_to_string(result: ValidationResult) -> String:
	match result:
		ValidationResult.VALID: return "VALID"
		ValidationResult.WARNING: return "WARNING" 
		ValidationResult.ERROR: return "ERROR"
		ValidationResult.CRITICAL: return "CRITICAL"
		_: return "UNKNOWN"

static func validate_all_assets_in_directory(directory_path: String) -> Array[ValidationReport]:
	"""Validate all .ub.zip assets in a directory"""
	var reports: Array[ValidationReport] = []
	
	var dir = DirAccess.open(directory_path)
	if not dir:
		push_error("Cannot open directory: " + directory_path)
		return reports
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".ub.zip"):
			var full_path = directory_path + "/" + file_name
			var report = validate_asset(full_path)
			reports.append(report)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	print("🔍 Validated %d assets in %s" % [reports.size(), directory_path])
	return reports

static func print_validation_summary(reports: Array[ValidationReport]) -> void:
	"""Print summary of validation results"""
	var valid_count = 0
	var warning_count = 0
	var error_count = 0
	var critical_count = 0
	
	for report in reports:
		match report.result:
			ValidationResult.VALID: valid_count += 1
			ValidationResult.WARNING: warning_count += 1
			ValidationResult.ERROR: error_count += 1
			ValidationResult.CRITICAL: critical_count += 1
	
	print("\n🎯 VALIDATION SUMMARY:")
	print("✅ Valid: %d" % valid_count)
	print("⚠️  Warnings: %d" % warning_count)  
	print("❌ Errors: %d" % error_count)
	print("🚨 Critical: %d" % critical_count)
	print("📊 Total: %d assets" % reports.size())