extends Node
#class_name ComponentLoader # Commented to avoid duplicate

# Component structure specification:
# component.ub.zip
# ├── manifest.json
# ├── scripts/
# │   └── main.gd
# ├── resources/
# │   └── *.tres
# └── scenes/
#     └── *.tscn

static func load_component(zip_path: String) -> Dictionary:
	var reader = ZIPReader.new()
	var err = reader.open(zip_path)
	
	if err != OK:
		push_error("Failed to open component ZIP: %s" % zip_path)
		return {}
	
	var component_data = {
		"path": zip_path,
		"manifest": {},
		"scripts": {},
		"resources": {},
		"scenes": {}
	}
	
	# Read manifest first
	var manifest_data = reader.read_file("manifest.json")
	if manifest_data.size() > 0:
		var json = JSON.new()
		var parse_result = json.parse(manifest_data.get_string_from_utf8())
		if parse_result == OK:
			component_data.manifest = json.data
		else:
			push_error("Failed to parse manifest.json in %s" % zip_path)
	
	# Load all files
	var files = reader.get_files()
	for file in files:
		if file.ends_with(".gd"):
			var script_data = reader.read_file(file)
			component_data.scripts[file] = script_data.get_string_from_utf8()
		elif file.ends_with(".tres") or file.ends_with(".res"):
			# For now, store raw data - in real implementation would deserialize
			component_data.resources[file] = reader.read_file(file)
		elif file.ends_with(".tscn"):
			# For now, store raw data - in real implementation would parse scene
			component_data.scenes[file] = reader.read_file(file)
	
	reader.close()
	return component_data

static func apply_component_to_being(being: UniversalBeing, component_data: Dictionary) -> void:
	var manifest = component_data.get("manifest", {})
	
	# Apply metadata
	if manifest.has("metadata"):
		for key in manifest.metadata:
			being.metadata[key] = manifest.metadata[key]
	
	# Apply properties
	if manifest.has("properties"):
		for prop in manifest.properties:
			if being.has_method("set"):
				being.set(prop.name, prop.value)
	
	# Load main script if exists
	if component_data.scripts.has("scripts/main.gd"):
		var script_source = component_data.scripts["scripts/main.gd"]
		# In production, would compile and attach script
		print("Component script loaded: %d bytes" % script_source.length())
	
	# Register component
	being.component_data[component_data.path] = manifest
	
	print("🔌 Component applied: %s" % manifest.get("name", "Unknown"))

static func create_component_template(output_path: String, component_name: String) -> void:
	var manifest = {
		"name": component_name,
		"version": "1.0.0",
		"author": "Universal Being System",
		"description": "Component for Universal Being",
		"compatibility": {
			"godot": "4.4+",
			"universal_being": "1.0+"
		},
		"metadata": {},
		"properties": [],
		"methods": [],
		"signals": []
	}
	
	var writer = ZIPPacker.new()
	var err = writer.open(output_path)
	
	if err != OK:
		push_error("Failed to create component ZIP: %s" % output_path)
		return
	
	# Write manifest
	var json = JSON.new()
	writer.start_file("manifest.json")
	writer.write_file(json.stringify(manifest, "\t").to_utf8_buffer())
	writer.close_file()
	
	# Create directory structure
	writer.start_file("scripts/main.gd")
	writer.write_file(("# Component: %s\n# Main script\n\nextends Node\n\nfunc _ready():\n\tpass" % component_name).to_utf8_buffer())
	writer.close_file()
	
	writer.start_file("resources/.gitkeep")
	writer.write_file("".to_utf8_buffer())
	writer.close_file()
	
	writer.start_file("scenes/.gitkeep")
	writer.write_file("".to_utf8_buffer())
	writer.close_file()
	
	writer.close()
	print("✨ Component template created: %s" % output_path)