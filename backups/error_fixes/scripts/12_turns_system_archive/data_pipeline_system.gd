extends Node

class_name DataPipelineSystem

# Core drive configuration
const DRIVE_CONFIG = {
	"core_0": {
		"path": "/mnt/c/Users/Percision 15/12_turns_system/data/core_0",
		"type": "system",
		"description": "Primary system drive - contains core system files and configurations",
		"sync_priority": 1,
		"max_size_gb": 500
	},
	"core_1": {
		"path": "/mnt/c/Users/Percision 15/icloud_sync",
		"type": "cloud",
		"description": "iCloud integration - contains synchronized personal data and backups",
		"sync_priority": 2,
		"max_size_gb": 200
	},
	"core_2": {
		"path": "/mnt/c/Users/Percision 15/google_drive",
		"type": "cloud",
		"description": "Google Drive integration - contains shared project data and resources",
		"sync_priority": 3,
		"max_size_gb": 100
	}
}

# Content types with storage rules
const CONTENT_TYPES = {
	"messages": {
		"description": "User messages and conversations",
		"primary_core": "core_0",
		"backup_cores": ["core_1"],
		"format": "json",
		"encryption": "none",
		"retention": "permanent",
		"indexing": true
	},
	"paintings": {
		"description": "iPad and digital paintings/artwork",
		"primary_core": "core_1",
		"backup_cores": ["core_2"],
		"format": "native",
		"encryption": "light",
		"retention": "permanent",
		"indexing": true
	},
	"notes": {
		"description": "Personal notes and mind maps",
		"primary_core": "core_0",
		"backup_cores": ["core_1"],
		"format": "encrypted",
		"encryption": "full",
		"retention": "permanent",
		"indexing": true
	},
	"system_data": {
		"description": "System configuration and operational data",
		"primary_core": "core_0",
		"backup_cores": [],
		"format": "json",
		"encryption": "none",
		"retention": "rotational",
		"indexing": false
	},
	"turn_data": {
		"description": "Data related to the 12-turn system cycles",
		"primary_core": "core_0",
		"backup_cores": ["core_2"],
		"format": "structured",
		"encryption": "light",
		"retention": "permanent",
		"indexing": true
	},
	"shared_projects": {
		"description": "Collaborative project files and resources",
		"primary_core": "core_2",
		"backup_cores": ["core_0"],
		"format": "native",
		"encryption": "none",
		"retention": "permanent",
		"indexing": true
	},
	"3d_notepad": {
		"description": "3D Notepad data and visualizations",
		"primary_core": "core_0",
		"backup_cores": ["core_1"],
		"format": "specialized",
		"encryption": "light",
		"retention": "permanent",
		"indexing": true
	}
}

# Pipeline configuration
const PIPELINES = {
	"message_storage": {
		"description": "Process and store user messages across appropriate drives",
		"input_types": ["messages"],
		"steps": ["parse", "filter", "process", "store", "index"],
		"output_cores": ["core_0", "core_1"],
		"schedule": "immediate",
		"parallel": true
	},
	"painting_sync": {
		"description": "Synchronize and process paintings and artwork",
		"input_types": ["paintings"],
		"steps": ["import", "optimize", "tag", "store", "index"],
		"output_cores": ["core_1", "core_2"],
		"schedule": "batch",
		"parallel": true
	},
	"note_processor": {
		"description": "Process, encrypt and store personal notes",
		"input_types": ["notes"],
		"steps": ["parse", "encrypt", "categorize", "store", "index"],
		"output_cores": ["core_0", "core_1"],
		"schedule": "immediate",
		"parallel": false
	},
	"turn_cycle": {
		"description": "Process and archive turn cycle data",
		"input_types": ["turn_data"],
		"steps": ["validate", "process", "archive", "index"],
		"output_cores": ["core_0", "core_2"],
		"schedule": "triggered",
		"parallel": true
	},
	"3d_notepad_sync": {
		"description": "Process and synchronize 3D Notepad data",
		"input_types": ["3d_notepad"],
		"steps": ["parse", "render", "optimize", "store"],
		"output_cores": ["core_0", "core_1"],
		"schedule": "immediate",
		"parallel": true
	},
	"system_backup": {
		"description": "Create systematic backups of all critical data",
		"input_types": ["messages", "notes", "turn_data", "3d_notepad"],
		"steps": ["select", "compress", "encrypt", "archive"],
		"output_cores": ["core_0", "core_1", "core_2"],
		"schedule": "daily",
		"parallel": true
	}
}

# Core access status
var core_status = {
	"core_0": {
		"connected": false,
		"available_space_gb": 0,
		"total_space_gb": 0,
		"last_sync": 0
	},
	"core_1": {
		"connected": false,
		"available_space_gb": 0,
		"total_space_gb": 0,
		"last_sync": 0
	},
	"core_2": {
		"connected": false,
		"available_space_gb": 0,
		"total_space_gb": 0,
		"last_sync": 0
	}
}

# Active pipelines
var active_pipelines = {}

# Integration references
var storage_system = null
var akashic_bridge = null

# Processing stats
var stats = {
	"messages_processed": 0,
	"paintings_processed": 0,
	"notes_processed": 0,
	"total_data_processed_mb": 0,
	"pipeline_executions": 0
}

# Error tracking
var errors = []

# Signals
signal pipeline_completed(pipeline_id, stats)
signal data_stored(content_type, data_id, cores)
signal core_status_changed(core_id, status)
signal error_occurred(error_type, message)

func _ready():
	# Initialize data pipeline system
	initialize_system()

func initialize_system():
	print("Initializing Data Pipeline System...")
	
	# Setup core drives
	setup_core_drives()
	
	# Create directory structure
	create_directory_structure()
	
	# Connect to integration systems
	connect_integration_systems()
	
	# Initialize pipelines
	initialize_pipelines()
	
	print("Data Pipeline System initialized")

func setup_core_drives():
	# Initialize core drives and check status
	for core_id in DRIVE_CONFIG:
		var drive_path = DRIVE_CONFIG[core_id].path
		var dir = Directory.new()
		
		if dir.dir_exists(drive_path):
			core_status[core_id].connected = true
			core_status[core_id].total_space_gb = DRIVE_CONFIG[core_id].max_size_gb
			
			# Calculate available space (simulated)
			core_status[core_id].available_space_gb = DRIVE_CONFIG[core_id].max_size_gb * (0.7 + randf() * 0.3)
			
			print("Core " + core_id + " connected: " + drive_path)
		else:
			print("Creating core drive directory: " + drive_path)
			dir.make_dir_recursive(drive_path)
			
			if dir.dir_exists(drive_path):
				core_status[core_id].connected = true
				core_status[core_id].total_space_gb = DRIVE_CONFIG[core_id].max_size_gb
				core_status[core_id].available_space_gb = DRIVE_CONFIG[core_id].max_size_gb
				
				print("Core " + core_id + " created and connected: " + drive_path)
			else:
				print("Failed to create core drive: " + drive_path)
				core_status[core_id].connected = false
				
				# Log error
				errors.append({
					"type": "core_initialization",
					"core_id": core_id,
					"message": "Failed to create core drive directory",
					"timestamp": OS.get_unix_time()
				})
				
				emit_signal("error_occurred", "core_initialization", "Failed to create core drive: " + core_id)
		
		# Emit status signal
		emit_signal("core_status_changed", core_id, core_status[core_id])

func create_directory_structure():
	# Create directory structure for content types
	for core_id in DRIVE_CONFIG:
		if core_status[core_id].connected:
			var base_path = DRIVE_CONFIG[core_id].path
			
			# Create content type directories
			for content_type in CONTENT_TYPES:
				# Check if this content should be stored on this core
				if CONTENT_TYPES[content_type].primary_core == core_id or core_id in CONTENT_TYPES[content_type].backup_cores:
					var content_path = base_path.plus_file(content_type)
					var dir = Directory.new()
					
					if not dir.dir_exists(content_path):
						dir.make_dir_recursive(content_path)
						print("Created directory for " + content_type + " on " + core_id + ": " + content_path)

func connect_integration_systems():
	# Connect to Storage System if available
	if ClassDB.class_exists("StorageIntegrationSystem"):
		storage_system = StorageIntegrationSystem.new()
		add_child(storage_system)
		print("Connected to Storage Integration System")
	
	# Connect to Akashic Bridge if available
	if ClassDB.class_exists("ClaudeAkashicBridge"):
		akashic_bridge = ClaudeAkashicBridge.new()
		add_child(akashic_bridge)
		print("Connected to Claude Akashic Bridge")

func initialize_pipelines():
	# Initialize pipeline processors
	for pipeline_id in PIPELINES:
		var pipeline = PIPELINES[pipeline_id]
		
		active_pipelines[pipeline_id] = {
			"id": pipeline_id,
			"status": "idle",
			"last_run": 0,
			"items_processed": 0,
			"config": pipeline
		}
		
		print("Initialized pipeline: " + pipeline_id)

# Public API methods

# Store user message
func store_message(message_text, metadata = {}):
	# Check if message pipeline is available
	if not active_pipelines.has("message_storage") or active_pipelines.message_storage.status == "error":
		push_error("Message storage pipeline not available")
		return null
	
	# Create message object
	var message = {
		"id": "msg_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000),
		"text": message_text,
		"timestamp": OS.get_unix_time(),
		"metadata": metadata
	}
	
	# Start message pipeline
	execute_pipeline("message_storage", message)
	
	return message.id

# Store painting reference
func store_painting(file_path, title = "", tags = [], metadata = {}):
	# Check if painting pipeline is available
	if not active_pipelines.has("painting_sync") or active_pipelines.painting_sync.status == "error":
		push_error("Painting sync pipeline not available")
		return null
	
	# Create file object
	var file_data = {
		"id": "paint_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000),
		"file_path": file_path,
		"title": title,
		"tags": tags,
		"timestamp": OS.get_unix_time(),
		"metadata": metadata
	}
	
	# Start painting pipeline
	execute_pipeline("painting_sync", file_data)
	
	return file_data.id

# Store note
func store_note(note_text, title = "", is_private = true, metadata = {}):
	# Check if note pipeline is available
	if not active_pipelines.has("note_processor") or active_pipelines.note_processor.status == "error":
		push_error("Note processor pipeline not available")
		return null
	
	# Create note object
	var note = {
		"id": "note_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000),
		"text": note_text,
		"title": title,
		"is_private": is_private,
		"timestamp": OS.get_unix_time(),
		"metadata": metadata
	}
	
	# Start note pipeline
	execute_pipeline("note_processor", note)
	
	return note.id

# Store 3D notepad data
func store_3d_notepad(notepad_data, title = "", metadata = {}):
	# Check if 3D notepad pipeline is available
	if not active_pipelines.has("3d_notepad_sync") or active_pipelines["3d_notepad_sync"].status == "error":
		push_error("3D Notepad sync pipeline not available")
		return null
	
	# Create 3D notepad object
	var notepad = {
		"id": "3dnote_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000),
		"data": notepad_data,
		"title": title,
		"timestamp": OS.get_unix_time(),
		"metadata": metadata
	}
	
	# Start 3D notepad pipeline
	execute_pipeline("3d_notepad_sync", notepad)
	
	return notepad.id

# Store turn data
func store_turn_data(turn_number, turn_data, metadata = {}):
	# Check if turn cycle pipeline is available
	if not active_pipelines.has("turn_cycle") or active_pipelines.turn_cycle.status == "error":
		push_error("Turn cycle pipeline not available")
		return null
	
	# Create turn data object
	var turn = {
		"id": "turn_" + str(turn_number) + "_" + str(OS.get_unix_time()),
		"turn_number": turn_number,
		"data": turn_data,
		"timestamp": OS.get_unix_time(),
		"metadata": metadata
	}
	
	# Start turn cycle pipeline
	execute_pipeline("turn_cycle", turn)
	
	return turn.id

# Trigger system backup
func trigger_backup(include_content_types = []):
	# Default to all content types if none specified
	if include_content_types.empty():
		include_content_types = CONTENT_TYPES.keys()
	
	# Create backup object
	var backup = {
		"id": "backup_" + str(OS.get_unix_time()),
		"content_types": include_content_types,
		"timestamp": OS.get_unix_time()
	}
	
	# Start backup pipeline
	execute_pipeline("system_backup", backup)
	
	return backup.id

# Get status of all cores
func get_cores_status():
	var status = {}
	
	for core_id in core_status:
		status[core_id] = {
			"connected": core_status[core_id].connected,
			"available_gb": core_status[core_id].available_space_gb,
			"total_gb": core_status[core_id].total_space_gb,
			"usage_percentage": (1.0 - (core_status[core_id].available_space_gb / core_status[core_id].total_space_gb)) * 100,
			"last_sync": core_status[core_id].last_sync,
			"type": DRIVE_CONFIG[core_id].type,
			"description": DRIVE_CONFIG[core_id].description
		}
	}
	
	return status

# Get status of all pipelines
func get_pipelines_status():
	var status = {}
	
	for pipeline_id in active_pipelines:
		status[pipeline_id] = {
			"status": active_pipelines[pipeline_id].status,
			"last_run": active_pipelines[pipeline_id].last_run,
			"items_processed": active_pipelines[pipeline_id].items_processed,
			"description": PIPELINES[pipeline_id].description
		}
	}
	
	return status

# Get overall system stats
func get_system_stats():
	return {
		"messages_processed": stats.messages_processed,
		"paintings_processed": stats.paintings_processed,
		"notes_processed": stats.notes_processed,
		"total_data_processed_mb": stats.total_data_processed_mb,
		"pipeline_executions": stats.pipeline_executions,
		"error_count": errors.size(),
		"cores": get_cores_status(),
		"pipelines": get_pipelines_status()
	}

# Execute pipeline for data processing
func execute_pipeline(pipeline_id, data):
	if not active_pipelines.has(pipeline_id):
		push_error("Pipeline not found: " + pipeline_id)
		return false
	
	# Set pipeline to active
	active_pipelines[pipeline_id].status = "active"
	active_pipelines[pipeline_id].last_run = OS.get_unix_time()
	
	# Get pipeline configuration
	var pipeline = PIPELINES[pipeline_id]
	
	# Process pipeline steps
	var result = process_pipeline_steps(pipeline, data)
	
	if result:
		# Pipeline completed successfully
		active_pipelines[pipeline_id].status = "idle"
		active_pipelines[pipeline_id].items_processed += 1
		stats.pipeline_executions += 1
		
		# Update stats based on content type
		if pipeline.input_types.has("messages"):
			stats.messages_processed += 1
		
		if pipeline.input_types.has("paintings"):
			stats.paintings_processed += 1
		
		if pipeline.input_types.has("notes"):
			stats.notes_processed += 1
		
		# Estimate data size
		var data_size_mb = 0.01 # Base size
		
		if typeof(data) == TYPE_DICTIONARY:
			if data.has("text"):
				data_size_mb += data.text.length() / (1024.0 * 1024.0) * 2 # Text size estimate
			
			if data.has("data"):
				if typeof(data.data) == TYPE_DICTIONARY:
					data_size_mb += 0.1 # Small object
				else:
					data_size_mb += 1.0 # Larger object
		
		stats.total_data_processed_mb += data_size_mb
		
		# Emit completion signal
		emit_signal("pipeline_completed", pipeline_id, {
			"data_id": data.id,
			"pipeline": pipeline_id,
			"time_taken": OS.get_unix_time() - active_pipelines[pipeline_id].last_run,
			"data_size_mb": data_size_mb
		})
		
		return true
	else:
		# Pipeline failed
		active_pipelines[pipeline_id].status = "error"
		
		# Log error
		errors.append({
			"type": "pipeline_execution",
			"pipeline_id": pipeline_id,
			"message": "Pipeline execution failed",
			"timestamp": OS.get_unix_time()
		})
		
		emit_signal("error_occurred", "pipeline_execution", "Pipeline execution failed: " + pipeline_id)
		
		return false

# Process pipeline steps
func process_pipeline_steps(pipeline, data):
	# Get content type
	var content_type = null
	for type in pipeline.input_types:
		if CONTENT_TYPES.has(type):
			content_type = type
			break
	
	if content_type == null:
		push_error("No valid content type found for pipeline")
		return false
	
	# Track cores where data was stored
	var stored_cores = []
	
	# Execute each step
	for step in pipeline.steps:
		match step:
			"parse":
				# Parse data into appropriate format
				pass
			"filter":
				# Filter data for security or privacy
				pass
			"process":
				# Process data for storage
				pass
			"store":
				# Store data in appropriate cores
				var primary_core = CONTENT_TYPES[content_type].primary_core
				
				if store_data_to_core(primary_core, content_type, data):
					stored_cores.append(primary_core)
				
				# Store to backup cores
				for backup_core in CONTENT_TYPES[content_type].backup_cores:
					if store_data_to_core(backup_core, content_type, data):
						stored_cores.append(backup_core)
			"index":
				# Index data for searching
				pass
			"encrypt":
				# Encrypt sensitive data
				pass
			"compress":
				# Compress data for storage efficiency
				pass
			"archive":
				# Archive data for long-term storage
				pass
			"optimize":
				# Optimize data (for images, etc.)
				pass
			"tag":
				# Add tags for better organization
				pass
			"categorize":
				# Categorize data
				pass
			"validate":
				# Validate data integrity
				pass
			"render":
				# Render data (for 3D, etc.)
				pass
			"select":
				# Select data for backup
				pass
	
	# Emit signal for successful storage
	if not stored_cores.empty():
		emit_signal("data_stored", content_type, data.id, stored_cores)
	
	return true

# Store data to specific core
func store_data_to_core(core_id, content_type, data):
	if not core_status[core_id].connected:
		push_error("Core not connected: " + core_id)
		return false
	
	# Check for available space
	var data_size_gb = 0.001 # Assume small size by default
	
	if typeof(data) == TYPE_DICTIONARY:
		if data.has("text") and typeof(data.text) == TYPE_STRING:
			data_size_gb = data.text.length() / (1024.0 * 1024.0 * 1024.0) * 2 # Text size estimate
		
		if data.has("data"):
			data_size_gb = 0.01 # Larger object
	
	if core_status[core_id].available_space_gb < data_size_gb:
		push_error("Not enough space on core: " + core_id)
		return false
	
	# Get path for storage
	var storage_path = DRIVE_CONFIG[core_id].path.plus_file(content_type)
	
	# Create file name based on data id
	var file_name = data.id + "." + CONTENT_TYPES[content_type].format
	
	# Store data to file
	var file_path = storage_path.plus_file(file_name)
	var file = File.new()
	
	if file.open(file_path, File.WRITE) == OK:
		file.store_string(JSON.print(data, "  "))
		file.close()
		
		# Update available space
		core_status[core_id].available_space_gb -= data_size_gb
		core_status[core_id].last_sync = OS.get_unix_time()
		
		emit_signal("core_status_changed", core_id, core_status[core_id])
		
		print("Stored " + content_type + " data to " + core_id + ": " + file_path)
		return true
	else:
		push_error("Failed to write file: " + file_path)
		
		# Log error
		errors.append({
			"type": "file_write",
			"core_id": core_id,
			"content_type": content_type,
			"file_path": file_path,
			"message": "Failed to write file",
			"timestamp": OS.get_unix_time()
		})
		
		emit_signal("error_occurred", "file_write", "Failed to write file: " + file_path)
		
		return false
	
	return false