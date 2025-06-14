extends Node

class_name ProjectConnectorSystem

# Project Connector System
# Manages project merging, file synchronization, and cross-application integration
# Enables sound capabilities and drive mapping
# Handles version history during merges

signal project_connected(source, target, connection_type)
signal file_modified(file_path, type, content)
signal sound_activated(signature, amplitude, frequency)
signal drive_mapped(drive_letter, physical_path)
signal version_updated(file_path, old_version, new_version)

# === CONSTANTS ===
const CONNECTION_TYPES = {
	"file": 1,
	"folder": 2,
	"version": 3,
	"application": 4,
	"drive": 5
}

const MERGE_STRATEGIES = {
	"replace": 1,  # Completely replace target with source
	"append": 2,   # Add source content to end of target
	"selective": 3,  # Merge specific sections
	"smart": 4     # Use context to determine merge strategy
}

# === VARIABLES ===
var project_paths = {}       # Paths to connected projects
var file_connections = {}    # Connected files
var folder_connections = {}  # Connected folders
var version_history = {}     # File version history
var sound_signatures = []    # Sound signatures
var drive_mappings = {}      # Drive mappings
var connection_history = []  # History of connections
var file_modification_history = [] # History of file modifications

# === INITIALIZATION ===
func _ready():
	# Initialize default mappings
	_initialize_default_mappings()
	
	print("Project Connector System initialized")

# Initialize default mappings
func _initialize_default_mappings():
	# Set up basic drive mappings
	drive_mappings = {
		"c": "/mnt/c",
		"d": "/mnt/d",
		"u": "user://",
		"r": "res://"
	}
	
	print("Initialized drive mappings for " + str(drive_mappings.size()) + " drives")

# === PROJECT CONNECTIONS ===

# Set project paths
func set_project_paths(paths):
	project_paths = paths
	
	print("Set " + str(project_paths.size()) + " project paths")
	return project_paths

# Connect two projects
func connect_projects(source_project, target_project, connection_type = "folder"):
	if project_paths.has(source_project) and project_paths.has(target_project):
		var connection = {
			"source": source_project,
			"target": target_project,
			"type": connection_type,
			"established_at": OS.get_ticks_msec(),
			"active": true
		}
		
		# Store in connections
		var connection_id = source_project + "_to_" + target_project
		folder_connections[connection_id] = connection
		
		# Record in history
		connection_history.append({
			"action": "connect_projects",
			"source": source_project,
			"target": target_project,
			"type": connection_type,
			"timestamp": OS.get_ticks_msec()
		})
		
		# Emit signal
		emit_signal("project_connected", source_project, target_project, connection_type)
		
		print("Connected project " + source_project + " to " + target_project)
		return connection
	
	print("Cannot connect projects: One or both projects not found")
	return null

# Connect files
func connect_files(source_file, target_file):
	# Create connection
	var connection = {
		"source": source_file,
		"target": target_file,
		"established_at": OS.get_ticks_msec(),
		"active": true,
		"sync_count": 0
	}
	
	# Store in connections
	var connection_id = source_file + "_to_" + target_file
	file_connections[connection_id] = connection
	
	# Record in history
	connection_history.append({
		"action": "connect_files",
		"source": source_file,
		"target": target_file,
		"timestamp": OS.get_ticks_msec()
	})
	
	# Emit signal
	emit_signal("project_connected", source_file, target_file, "file")
	
	print("Connected file " + source_file + " to " + target_file)
	return connection

# Connect folders
func connect_folders(source_folder, target_folder):
	# Create connection
	var connection = {
		"source": source_folder,
		"target": target_folder,
		"established_at": OS.get_ticks_msec(),
		"active": true,
		"sync_count": 0
	}
	
	# Store in connections
	var connection_id = source_folder + "_to_" + target_folder
	folder_connections[connection_id] = connection
	
	# Record in history
	connection_history.append({
		"action": "connect_folders",
		"source": source_folder,
		"target": target_folder,
		"timestamp": OS.get_ticks_msec()
	})
	
	# Emit signal
	emit_signal("project_connected", source_folder, target_folder, "folder")
	
	print("Connected folder " + source_folder + " to " + target_folder)
	return connection

# Map a drive
func map_drive(drive_letter, physical_path):
	drive_mappings[drive_letter] = physical_path
	
	# Emit signal
	emit_signal("drive_mapped", drive_letter, physical_path)
	
	print("Mapped drive " + drive_letter + " to " + physical_path)
	return true

# === FILE OPERATIONS ===

# Create a new file
func create_file(path, content):
	# Record in history
	file_modification_history.append({
		"action": "create",
		"path": path,
		"content_length": content.length(),
		"timestamp": OS.get_ticks_msec()
	})
	
	# Create version history entry
	version_history[path] = [{
		"version": 1,
		"content_length": content.length(),
		"created_at": OS.get_ticks_msec()
	}]
	
	# Emit signal
	emit_signal("file_modified", path, "create", content)
	
	print("Created file " + path)
	return true

# Update an existing file
func update_file(path, content):
	# Get current version
	var current_version = 1
	if version_history.has(path) and version_history[path].size() > 0:
		current_version = version_history[path][version_history[path].size() - 1].version
	
	# Record in history
	file_modification_history.append({
		"action": "update",
		"path": path,
		"content_length": content.length(),
		"timestamp": OS.get_ticks_msec()
	})
	
	# Create or update version history
	if not version_history.has(path):
		version_history[path] = []
	
	version_history[path].append({
		"version": current_version + 1,
		"content_length": content.length(),
		"created_at": OS.get_ticks_msec()
	})
	
	# Emit signals
	emit_signal("file_modified", path, "update", content)
	emit_signal("version_updated", path, current_version, current_version + 1)
	
	print("Updated file " + path + " to version " + str(current_version + 1))
	return true

# Merge files
func merge_files(source_path, target_path, strategy = "smart"):
	# Record in history
	file_modification_history.append({
		"action": "merge",
		"source": source_path,
		"target": target_path,
		"strategy": strategy,
		"timestamp": OS.get_ticks_msec()
	})
	
	# Get current version for target
	var current_version = 1
	if version_history.has(target_path) and version_history[target_path].size() > 0:
		current_version = version_history[target_path][version_history[target_path].size() - 1].version
	
	# Create or update version history
	if not version_history.has(target_path):
		version_history[target_path] = []
	
	version_history[target_path].append({
		"version": current_version + 1,
		"merged_from": source_path,
		"strategy": strategy,
		"created_at": OS.get_ticks_msec()
	})
	
	# Emit signals
	emit_signal("file_modified", target_path, "merge", source_path)
	emit_signal("version_updated", target_path, current_version, current_version + 1)
	
	print("Merged file " + source_path + " into " + target_path + " using strategy " + strategy)
	return true

# Synchronize files
func synchronize_files(source_path, target_path):
	var connection_id = source_path + "_to_" + target_path
	
	if file_connections.has(connection_id):
		var connection = file_connections[connection_id]
		
		# Update sync count
		connection.sync_count += 1
		
		# Record last sync
		connection.last_sync = OS.get_ticks_msec()
		
		# Emit signal
		emit_signal("file_modified", target_path, "sync", source_path)
		
		print("Synchronized file " + source_path + " to " + target_path)
		return true
	
	print("Cannot synchronize: No connection between " + source_path + " and " + target_path)
	return false

# === SOUND CAPABILITIES ===

# Set sound signatures
func set_sound_signatures(signatures):
	sound_signatures = signatures
	
	print("Set " + str(sound_signatures.size()) + " sound signatures")
	return sound_signatures

# Play a sound signature
func play_sound_signature(signature_name):
	for signature in sound_signatures:
		if signature.name == signature_name:
			# Emit signal
			emit_signal("sound_activated", signature_name, signature.amplitude, signature.frequency)
			
			print("Played sound signature " + signature_name)
			return true
	
	print("Sound signature not found: " + signature_name)
	return false

# Get active sound signatures
func get_sound_signatures():
	return sound_signatures

# === APPLICATION INTEGRATION ===

# Connect to external application
func connect_to_application(application_name, parameters = {}):
	# Record in history
	connection_history.append({
		"action": "connect_application",
		"application": application_name,
		"parameters": parameters,
		"timestamp": OS.get_ticks_msec()
	})
	
	# Emit signal
	emit_signal("project_connected", "current", application_name, "application")
	
	print("Connected to application " + application_name)
	return true

# === UTILITY METHODS ===

# Get version history for a file
func get_version_history(file_path):
	if version_history.has(file_path):
		return version_history[file_path]
	return []

# Get drive mappings
func get_drive_mappings():
	return drive_mappings

# Get connection history
func get_connection_history():
	return connection_history

# Get file modifications
func get_file_modifications():
	return file_modification_history

# Resolve path with drive mapping
func resolve_path(path):
	if path.begins_with("/"):
		# Absolute path, use as is
		return path
	
	if path.length() >= 2 and path[1] == ":":
		# Windows-style path with drive letter
		var drive = path[0].to_lower()
		if drive_mappings.has(drive):
			return drive_mappings[drive] + path.substr(2)
	
	# Resource path
	if path.begins_with("res://"):
		return path
	
	# User path
	if path.begins_with("user://"):
		return path
	
	# Default to resource path
	return "res://" + path