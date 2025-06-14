extends Node

class_name DatapoolSyncManager

# Core connections
var drive_connectors = {}
var memory_systems = {}
var active_pools = {}

# Google Drive connections
var google_drive_accounts = {}
var drive_priorities = []

# Sync configuration
var sync_interval = 300 # seconds
var auto_sync_enabled = true
var conflict_resolution = "newest" # newest, manual, merge
var sync_log = []

# Data pool structure
var data_pool_types = {
	"memory": {
		"path": "user://memory_pools/",
		"extensions": [".mem", ".mfrag", ".anchor"],
		"priority": 10
	},
	"story": {
		"path": "user://story_pools/",
		"extensions": [".story", ".selem", ".quest"],
		"priority": 8
	},
	"dimension": {
		"path": "user://dimension_pools/",
		"extensions": [".dim", ".dshift", ".dportal"],
		"priority": 6
	},
	"word": {
		"path": "user://word_pools/",
		"extensions": [".word", ".wpower", ".wcombo"],
		"priority": 9
	},
	"system": {
		"path": "user://system_pools/",
		"extensions": [".sys", ".config", ".log"],
		"priority": 5
	}
}

# Statistics
var total_syncs = 0
var total_files_synced = 0
var last_sync_time = 0
var bytes_transferred = 0

signal sync_started
signal sync_completed(success, message)
signal pool_updated(pool_id, status)
signal drive_connected(drive_id, success)

func _ready():
	initialize_system()
	setup_auto_sync()
	scan_connected_drives()

func initialize_system():
	# Create necessary directories
	var dir = Directory.new()
	
	for type in data_pool_types:
		if not dir.dir_exists(data_pool_types[type].path):
			dir.make_dir_recursive(data_pool_types[type].path)
	
	# Load any saved configuration
	load_configuration()
	
	print("Datapool Sync Manager initialized")

func setup_auto_sync():
	if auto_sync_enabled:
		var timer = Timer.new()
		timer.wait_time = sync_interval
		timer.autostart = true
		timer.connect("timeout", self, "auto_sync_all_pools")
		add_child(timer)

func scan_connected_drives():
	print("Scanning for connected drives...")
	
	# Look for drive connector implementations
	if has_node("/root/GoogleDriveConnector"):
		var google_drive = get_node("/root/GoogleDriveConnector")
		register_drive_connector("google_drive_main", google_drive)
	
	if has_node("/root/DriveConnector"):
		var drive = get_node("/root/DriveConnector")
		register_drive_connector("drive_main", drive)
	
	if has_node("/root/DriveMemoryConnector"):
		var memory_drive = get_node("/root/DriveMemoryConnector")
		register_drive_connector("memory_drive", memory_drive)
	
	if has_node("/root/MemoryDriveConnector"):
		var alt_memory_drive = get_node("/root/MemoryDriveConnector")
		register_drive_connector("alt_memory_drive", alt_memory_drive)
	
	print("Found " + str(drive_connectors.size()) + " drive connectors")

func register_drive_connector(id, connector):
	drive_connectors[id] = {
		"connector": connector,
		"status": "disconnected",
		"last_sync": 0,
		"quota": {
			"total": 0,
			"used": 0
		},
		"capabilities": get_connector_capabilities(connector)
	}
	
	# Try to connect
	connect_drive(id)

func get_connector_capabilities(connector):
	var capabilities = {
		"can_read": true,
		"can_write": true,
		"supports_memory": false,
		"supports_story": false,
		"supports_dimension": false,
		"supports_word": false,
		"supports_system": false
	}
	
	# Try to detect capabilities based on methods
	if connector.has_method("store_memory") or connector.has_method("retrieve_memory"):
		capabilities.supports_memory = true
	
	if connector.has_method("save_story") or connector.has_method("load_story"):
		capabilities.supports_story = true
	
	if connector.has_method("store_dimension") or connector.has_method("access_dimension"):
		capabilities.supports_dimension = true
	
	if connector.has_method("save_word") or connector.has_method("load_word"):
		capabilities.supports_word = true
	
	if connector.has_method("configure_system") or connector.has_method("get_system_status"):
		capabilities.supports_system = true
	
	return capabilities

func connect_drive(drive_id):
	if not drive_connectors.has(drive_id):
		print("Drive connector not found: " + drive_id)
		return false
	
	var connector_data = drive_connectors[drive_id]
	var connector = connector_data.connector
	
	print("Connecting to drive: " + drive_id)
	
	var success = false
	if connector.has_method("connect"):
		success = connector.connect()
	elif connector.has_method("authenticate"):
		success = connector.authenticate()
	else:
		# Assume connected if no connect method
		success = true
	
	if success:
		connector_data.status = "connected"
		connector_data.last_sync = OS.get_unix_time()
		
		# Try to get quota information
		if connector.has_method("get_storage_info"):
			var info = connector.get_storage_info()
			if typeof(info) == TYPE_DICTIONARY:
				connector_data.quota = info
		
		print("Successfully connected to drive: " + drive_id)
	else:
		connector_data.status = "connection_failed"
		print("Failed to connect to drive: " + drive_id)
	
	emit_signal("drive_connected", drive_id, success)
	return success

# Google Drive specific functions
func scan_google_accounts():
	print("Scanning for Google Drive accounts...")
	
	# Reset accounts list
	google_drive_accounts.clear()
	
	# Look for the main Google Drive connector
	if drive_connectors.has("google_drive_main"):
		var connector = drive_connectors.google_drive_main.connector
		
		# Check if the connector has account listing capability
		if connector.has_method("list_accounts"):
			var accounts = connector.list_accounts()
			for account in accounts:
				google_drive_accounts[account.id] = account
		else:
			# Add the main account
			google_drive_accounts["default"] = {
				"id": "default",
				"name": "Default Google Account",
				"email": "unknown",
				"status": "active"
			}
	
	# Check for additional connector implementations
	for i in range(1, 6):  # Check for up to 5 additional connectors
		var alt_connector_name = "google_drive_" + str(i)
		if has_node("/root/" + alt_connector_name):
			var alt_connector = get_node("/root/" + alt_connector_name)
			register_drive_connector(alt_connector_name, alt_connector)
			
			# Add account info
			google_drive_accounts[alt_connector_name] = {
				"id": alt_connector_name,
				"name": "Google Account " + str(i),
				"email": "unknown",
				"status": "active"
			}
	
	print("Found " + str(google_drive_accounts.size()) + " Google accounts")
	return google_drive_accounts.size()

func connect_to_google_account(account_id):
	if not google_drive_accounts.has(account_id):
		print("Google account not found: " + account_id)
		return false
	
	# Find associated connector
	var connector_id = ""
	if account_id == "default":
		connector_id = "google_drive_main"
	else:
		# Check if account ID matches a connector ID
		if drive_connectors.has(account_id):
			connector_id = account_id
		else:
			# Try to find connector by account
			for drive_id in drive_connectors:
				if drive_id.begins_with("google_drive_"):
					var connector = drive_connectors[drive_id].connector
					if connector.has_method("get_account_id") and connector.get_account_id() == account_id:
						connector_id = drive_id
						break
	
	if connector_id == "":
		print("No connector found for Google account: " + account_id)
		return false
	
	return connect_drive(connector_id)

# Data pool management
func create_data_pool(name, type, description=""):
	if not data_pool_types.has(type):
		print("Invalid data pool type: " + type)
		return null
	
	var pool_id = "pool_" + type + "_" + str(OS.get_unix_time())
	
	var pool = {
		"id": pool_id,
		"name": name,
		"type": type,
		"description": description,
		"created_at": OS.get_unix_time(),
		"last_synced": 0,
		"drives": {},
		"sync_frequency": sync_interval,
		"auto_sync": true,
		"storage_path": data_pool_types[type].path + name + "/",
		"file_count": 0,
		"size_bytes": 0
	}
	
	# Create directory for this pool
	var dir = Directory.new()
	if not dir.dir_exists(pool.storage_path):
		dir.make_dir_recursive(pool.storage_path)
	
	active_pools[pool_id] = pool
	
	print("Created data pool: " + name + " (Type: " + type + ")")
	save_configuration()
	
	return pool_id

func attach_drive_to_pool(pool_id, drive_id, options={}):
	if not active_pools.has(pool_id):
		print("Data pool not found: " + pool_id)
		return false
	
	if not drive_connectors.has(drive_id):
		print("Drive connector not found: " + drive_id)
		return false
	
	var pool = active_pools[pool_id]
	var connector_data = drive_connectors[drive_id]
	
	# Check if drive supports this pool type
	var capability_name = "supports_" + pool.type
	if not connector_data.capabilities.has(capability_name) or not connector_data.capabilities[capability_name]:
		print("Drive doesn't support pool type " + pool.type + ": " + drive_id)
		return false
	
	# Add drive to pool's drive list
	pool.drives[drive_id] = {
		"added_at": OS.get_unix_time(),
		"last_synced": 0,
		"status": "pending",
		"remote_path": options.get("remote_path", "/DataPools/" + pool.name + "/"),
		"priority": options.get("priority", 5),
		"sync_direction": options.get("sync_direction", "bidirectional")
	}
	
	print("Attached drive " + drive_id + " to pool " + pool_id)
	save_configuration()
	
	# Initial sync if auto-sync is enabled
	if pool.auto_sync:
		sync_pool(pool_id)
	
	return true

func sync_pool(pool_id):
	if not active_pools.has(pool_id):
		print("Data pool not found: " + pool_id)
		return false
	
	var pool = active_pools[pool_id]
	emit_signal("sync_started")
	
	print("Syncing data pool: " + pool.name)
	
	var successful_syncs = 0
	var failed_syncs = 0
	var total_drives = pool.drives.size()
	
	# Sort drives by priority
	var sorted_drives = []
	for drive_id in pool.drives:
		sorted_drives.append({"id": drive_id, "priority": pool.drives[drive_id].priority})
	
	sorted_drives.sort_custom(self, "sort_by_priority")
	
	# Sync with each drive
	for drive_data in sorted_drives:
		var drive_id = drive_data.id
		var drive_config = pool.drives[drive_id]
		
		if not drive_connectors.has(drive_id):
			print("Drive connector not found: " + drive_id)
			drive_config.status = "missing"
			failed_syncs += 1
			continue
		
		var connector_data = drive_connectors[drive_id]
		
		# Skip if not connected
		if connector_data.status != "connected":
			print("Drive not connected, attempting to connect: " + drive_id)
			if not connect_drive(drive_id):
				drive_config.status = "disconnected"
				failed_syncs += 1
				continue
		
		print("Syncing with drive: " + drive_id)
		var connector = connector_data.connector
		var success = false
		
		# Check sync direction
		if drive_config.sync_direction == "bidirectional" or drive_config.sync_direction == "upload":
			# Upload local files to drive
			success = upload_to_drive(pool, drive_id)
		
		if drive_config.sync_direction == "bidirectional" or drive_config.sync_direction == "download":
			# Download files from drive
			success = download_from_drive(pool, drive_id)
		
		if success:
			drive_config.status = "synced"
			drive_config.last_synced = OS.get_unix_time()
			successful_syncs += 1
		else:
			drive_config.status = "sync_failed"
			failed_syncs += 1
	
	# Update pool sync time
	pool.last_synced = OS.get_unix_time()
	
	# Update statistics
	total_syncs += 1
	last_sync_time = OS.get_unix_time()
	
	var success = failed_syncs == 0
	var message = successful_syncs + "/" + total_drives + " drives synced successfully"
	
	print("Pool sync completed: " + message)
	emit_signal("pool_updated", pool_id, success ? "synced" : "partial_sync")
	emit_signal("sync_completed", success, message)
	
	save_configuration()
	return success

func sort_by_priority(a, b):
	return a.priority > b.priority

func upload_to_drive(pool, drive_id):
	var drive_config = pool.drives[drive_id]
	var connector = drive_connectors[drive_id].connector
	
	print("Uploading files to drive: " + drive_id)
	
	# Create remote directory if needed
	ensure_remote_directory(drive_id, drive_config.remote_path)
	
	# Get local files
	var local_files = get_local_files(pool.storage_path)
	
	var successful_uploads = 0
	var failed_uploads = 0
	
	for file_info in local_files:
		var file_path = file_info.path
		var relative_path = file_path.replace(pool.storage_path, "")
		var remote_path = drive_config.remote_path + relative_path
		
		print("Uploading: " + file_path + " to " + remote_path)
		
		var success = false
		
		# Find the appropriate upload method
		if connector.has_method("upload_file"):
			success = connector.upload_file(file_path, remote_path)
		elif connector.has_method("store_file"):
			success = connector.store_file(file_path, remote_path)
		elif connector.has_method("sync_file"):
			success = connector.sync_file(file_path, remote_path)
		elif pool.type == "memory" and connector.has_method("store_memory"):
			var content = read_file_content(file_path)
			success = connector.store_memory(content, relative_path)
		elif pool.type == "story" and connector.has_method("save_story"):
			var content = read_file_content(file_path)
			success = connector.save_story(content, relative_path)
		elif pool.type == "word" and connector.has_method("save_word"):
			var content = read_file_content(file_path)
			success = connector.save_word(content, relative_path)
		else:
			print("No suitable upload method found for: " + drive_id)
			return false
		
		if success:
			successful_uploads += 1
			bytes_transferred += file_info.size
		else:
			failed_uploads += 1
			print("Failed to upload: " + file_path)
	
	total_files_synced += successful_uploads
	
	print("Upload completed: " + str(successful_uploads) + " successful, " + str(failed_uploads) + " failed")
	return failed_uploads == 0

func download_from_drive(pool, drive_id):
	var drive_config = pool.drives[drive_id]
	var connector = drive_connectors[drive_id].connector
	
	print("Downloading files from drive: " + drive_id)
	
	# Get remote files list
	var remote_files = get_remote_files(drive_id, drive_config.remote_path)
	if remote_files == null:
		print("Failed to get remote files list")
		return false
	
	var successful_downloads = 0
	var failed_downloads = 0
	
	for file_info in remote_files:
		var remote_path = file_info.path
		var relative_path = remote_path.replace(drive_config.remote_path, "")
		var local_path = pool.storage_path + relative_path
		
		# Skip if local file is newer
		if should_skip_download(local_path, file_info.modified):
			print("Skipping newer local file: " + local_path)
			continue
		
		print("Downloading: " + remote_path + " to " + local_path)
		
		var success = false
		
		# Find the appropriate download method
		if connector.has_method("download_file"):
			success = connector.download_file(remote_path, local_path)
		elif connector.has_method("retrieve_file"):
			success = connector.retrieve_file(remote_path, local_path)
		elif connector.has_method("sync_file"):
			success = connector.sync_file(local_path, remote_path, true)
		elif pool.type == "memory" and connector.has_method("retrieve_memory"):
			var content = connector.retrieve_memory(relative_path)
			if content:
				success = write_file_content(local_path, content)
		elif pool.type == "story" and connector.has_method("load_story"):
			var content = connector.load_story(relative_path)
			if content:
				success = write_file_content(local_path, content)
		elif pool.type == "word" and connector.has_method("load_word"):
			var content = connector.load_word(relative_path)
			if content:
				success = write_file_content(local_path, content)
		else:
			print("No suitable download method found for: " + drive_id)
			return false
		
		if success:
			successful_downloads += 1
			bytes_transferred += file_info.size
		else:
			failed_downloads += 1
			print("Failed to download: " + remote_path)
	
	total_files_synced += successful_downloads
	
	print("Download completed: " + str(successful_downloads) + " successful, " + str(failed_downloads) + " failed")
	return failed_downloads == 0

func should_skip_download(local_path, remote_modified):
	var file = File.new()
	if not file.file_exists(local_path):
		return false
	
	var dir = Directory.new()
	var local_modified = dir.get_modified_time(local_path)
	
	# If conflict resolution is set to "newest"
	if conflict_resolution == "newest":
		return local_modified > remote_modified
	
	# For "manual" resolution, we'll handle conflicts separately
	if conflict_resolution == "manual":
		if local_modified != remote_modified:
			# Mark as conflict and download with a different name
			add_conflict(local_path, remote_modified)
			return false
	
	return false

func add_conflict(local_path, remote_modified):
	var conflict = {
		"local_path": local_path,
		"remote_modified": remote_modified,
		"detected_at": OS.get_unix_time(),
		"resolved": false
	}
	
	# Store conflict information for later resolution
	var conflicts_file = "user://datapool_conflicts.json"
	var conflicts = []
	
	var file = File.new()
	if file.file_exists(conflicts_file):
		file.open(conflicts_file, File.READ)
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.parse(content)
		if json.error == OK:
			conflicts = json.result
	
	conflicts.append(conflict)
	
	file.open(conflicts_file, File.WRITE)
	file.store_string(JSON.print(conflicts))
	file.close()

# Helper functions
func ensure_remote_directory(drive_id, path):
	if not drive_connectors.has(drive_id):
		return false
	
	var connector = drive_connectors[drive_id].connector
	
	if connector.has_method("ensure_directory"):
		return connector.ensure_directory(path)
	elif connector.has_method("create_folder"):
		if not connector.folder_exists(path):
			return connector.create_folder(path)
		return true
	elif connector.has_method("make_dir"):
		return connector.make_dir(path)
	
	# Default assume directory exists
	return true

func get_local_files(path):
	var files = []
	var dir = Directory.new()
	
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		while file_name != "":
			var full_path = path + file_name
			
			if dir.current_is_dir():
				# Recursively get files from subdirectories
				files.append_array(get_local_files(full_path + "/"))
			else:
				files.append({
					"path": full_path,
					"name": file_name,
					"size": get_file_size(full_path),
					"modified": dir.get_modified_time(full_path)
				})
			
			file_name = dir.get_next()
	
	return files

func get_remote_files(drive_id, path):
	if not drive_connectors.has(drive_id):
		return null
	
	var connector = drive_connectors[drive_id].connector
	
	# Try to use the best available method
	if connector.has_method("list_files"):
		return connector.list_files(path)
	elif connector.has_method("get_files"):
		return connector.get_files(path)
	elif connector.has_method("list_directory"):
		return connector.list_directory(path)
	
	# If no suitable method is found
	print("No method available to list remote files for drive: " + drive_id)
	return []

func get_file_size(path):
	var file = File.new()
	if file.open(path, File.READ) == OK:
		var size = file.get_len()
		file.close()
		return size
	return 0

func read_file_content(path):
	var file = File.new()
	if file.open(path, File.READ) == OK:
		var content = file.get_as_text()
		file.close()
		return content
	return ""

func write_file_content(path, content):
	# Ensure directory exists
	var dir_path = path.get_base_dir()
	var dir = Directory.new()
	if not dir.dir_exists(dir_path):
		dir.make_dir_recursive(dir_path)
	
	# Write file
	var file = File.new()
	if file.open(path, File.WRITE) == OK:
		file.store_string(content)
		file.close()
		return true
	return false

# Configuration management
func save_configuration():
	var config = {
		"active_pools": active_pools,
		"drive_priorities": drive_priorities,
		"sync_interval": sync_interval,
		"auto_sync_enabled": auto_sync_enabled,
		"conflict_resolution": conflict_resolution,
		"statistics": {
			"total_syncs": total_syncs,
			"total_files_synced": total_files_synced,
			"last_sync_time": last_sync_time,
			"bytes_transferred": bytes_transferred
		}
	}
	
	var file = File.new()
	file.open("user://datapool_config.json", File.WRITE)
	file.store_string(JSON.print(config))
	file.close()

func load_configuration():
	var file = File.new()
	if not file.file_exists("user://datapool_config.json"):
		return
	
	file.open("user://datapool_config.json", File.READ)
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.parse(content)
	if json.error == OK:
		var config = json.result
		
		if config.has("active_pools"):
			active_pools = config.active_pools
		
		if config.has("drive_priorities"):
			drive_priorities = config.drive_priorities
		
		if config.has("sync_interval"):
			sync_interval = config.sync_interval
		
		if config.has("auto_sync_enabled"):
			auto_sync_enabled = config.auto_sync_enabled
		
		if config.has("conflict_resolution"):
			conflict_resolution = config.conflict_resolution
		
		if config.has("statistics"):
			var stats = config.statistics
			if stats.has("total_syncs"):
				total_syncs = stats.total_syncs
			if stats.has("total_files_synced"):
				total_files_synced = stats.total_files_synced
			if stats.has("last_sync_time"):
				last_sync_time = stats.last_sync_time
			if stats.has("bytes_transferred"):
				bytes_transferred = stats.bytes_transferred

# Automatic sync
func auto_sync_all_pools():
	if not auto_sync_enabled:
		return
	
	print("Starting automatic sync of all pools...")
	
	for pool_id in active_pools:
		var pool = active_pools[pool_id]
		
		if pool.auto_sync:
			sync_pool(pool_id)
	
	print("Automatic sync completed")

# User commands
func process_command(command):
	var parts = command.split(" ", false)
	
	if parts.size() == 0:
		return "Invalid command"
	
	match parts[0].to_lower():
		"pool":
			return process_pool_command(parts)
		"drive":
			return process_drive_command(parts)
		"sync":
			return process_sync_command(parts)
		"google":
			return process_google_command(parts)
		"status":
			return get_status_report()
		"help":
			return show_help()
		_:
			return "Unknown command: " + parts[0]

func process_pool_command(parts):
	if parts.size() < 2:
		return "Usage: pool <create|list|attach|detach|info>"
	
	match parts[1].to_lower():
		"create":
			if parts.size() < 4:
				return "Usage: pool create <name> <type> [description]"
			
			var name = parts[2]
			var type = parts[3]
			var description = ""
			
			if parts.size() > 4:
				description = " ".join(parts.slice(4, parts.size() - 1))
			
			var pool_id = create_data_pool(name, type, description)
			if pool_id:
				return "Created pool: " + name + " [ID: " + pool_id + "]"
			else:
				return "Failed to create pool"
		
		"list":
			var result = "Data Pools:\n"
			
			if active_pools.empty():
				return "No data pools found"
			
			for id in active_pools:
				var pool = active_pools[id]
				result += "- " + pool.name + " [" + pool.type + "] "
				
				if pool.last_synced > 0:
					var time_diff = OS.get_unix_time() - pool.last_synced
					result += "Last synced: " + get_time_ago(time_diff)
				else:
					result += "Never synced"
					
				result += "\n"
				
			return result
			
		"attach":
			if parts.size() < 4:
				return "Usage: pool attach <pool_id> <drive_id> [priority]"
			
			var pool_id = parts[2]
			var drive_id = parts[3]
			var priority = 5
			
			if parts.size() > 4:
				priority = int(parts[4])
			
			var options = {"priority": priority}
			
			if attach_drive_to_pool(pool_id, drive_id, options):
				return "Attached drive " + drive_id + " to pool " + pool_id
			else:
				return "Failed to attach drive"
		
		"detach":
			if parts.size() < 4:
				return "Usage: pool detach <pool_id> <drive_id>"
			
			var pool_id = parts[2]
			var drive_id = parts[3]
			
			if not active_pools.has(pool_id):
				return "Pool not found: " + pool_id
			
			if not active_pools[pool_id].drives.has(drive_id):
				return "Drive not attached to this pool: " + drive_id
			
			active_pools[pool_id].drives.erase(drive_id)
			save_configuration()
			
			return "Detached drive " + drive_id + " from pool " + pool_id
			
		"info":
			if parts.size() < 3:
				return "Usage: pool info <pool_id>"
			
			var pool_id = parts[2]
			
			if not active_pools.has(pool_id):
				return "Pool not found: " + pool_id
			
			var pool = active_pools[pool_id]
			var result = "Pool Information: " + pool.name + "\n"
			result += "Type: " + pool.type + "\n"
			result += "Description: " + pool.description + "\n"
			result += "Created: " + get_time_ago(OS.get_unix_time() - pool.created_at) + " ago\n"
			
			if pool.last_synced > 0:
				result += "Last Synced: " + get_time_ago(OS.get_unix_time() - pool.last_synced) + " ago\n"
			else:
				result += "Last Synced: Never\n"
			
			result += "Auto Sync: " + str(pool.auto_sync) + "\n"
			result += "Storage Path: " + pool.storage_path + "\n\n"
			
			result += "Attached Drives:\n"
			if pool.drives.empty():
				result += "No drives attached\n"
			else:
				for drive_id in pool.drives:
					var drive_info = pool.drives[drive_id]
					result += "- " + drive_id + " (Status: " + drive_info.status + ", Priority: " + str(drive_info.priority) + ")\n"
					result += "  Direction: " + drive_info.sync_direction + "\n"
					
					if drive_info.last_synced > 0:
						result += "  Last Synced: " + get_time_ago(OS.get_unix_time() - drive_info.last_synced) + " ago\n"
					else:
						result += "  Last Synced: Never\n"
			
			return result
			
		_:
			return "Unknown pool command: " + parts[1]

func process_drive_command(parts):
	if parts.size() < 2:
		return "Usage: drive <list|connect|disconnect|info>"
	
	match parts[1].to_lower():
		"list":
			var result = "Drive Connectors:\n"
			
			if drive_connectors.empty():
				return "No drive connectors found"
			
			for id in drive_connectors:
				var connector = drive_connectors[id]
				result += "- " + id + " [Status: " + connector.status + "]\n"
				
			return result
			
		"connect":
			if parts.size() < 3:
				return "Usage: drive connect <drive_id>"
			
			var drive_id = parts[2]
			
			if connect_drive(drive_id):
				return "Connected to drive: " + drive_id
			else:
				return "Failed to connect to drive: " + drive_id
				
		"disconnect":
			if parts.size() < 3:
				return "Usage: drive disconnect <drive_id>"
			
			var drive_id = parts[2]
			
			if not drive_connectors.has(drive_id):
				return "Drive not found: " + drive_id
			
			var connector = drive_connectors[drive_id].connector
			var success = false
			
			if connector.has_method("disconnect"):
				success = connector.disconnect()
			elif connector.has_method("logout"):
				success = connector.logout()
			else:
				success = true
			
			if success:
				drive_connectors[drive_id].status = "disconnected"
				return "Disconnected from drive: " + drive_id
			else:
				return "Failed to disconnect from drive: " + drive_id
				
		"info":
			if parts.size() < 3:
				return "Usage: drive info <drive_id>"
			
			var drive_id = parts[2]
			
			if not drive_connectors.has(drive_id):
				return "Drive not found: " + drive_id
			
			var drive = drive_connectors[drive_id]
			var result = "Drive Information: " + drive_id + "\n"
			result += "Status: " + drive.status + "\n"
			
			if drive.last_sync > 0:
				result += "Last Sync: " + get_time_ago(OS.get_unix_time() - drive.last_sync) + " ago\n"
			else:
				result += "Last Sync: Never\n"
			
			if drive.quota.total > 0:
				var used_percent = (drive.quota.used / drive.quota.total) * 100.0
				result += "Storage: " + format_size(drive.quota.used) + " / " + format_size(drive.quota.total) + " (" + str(int(used_percent)) + "%)\n"
			
			result += "\nCapabilities:\n"
			for capability in drive.capabilities:
				result += "- " + capability + ": " + str(drive.capabilities[capability]) + "\n"
			
			return result
			
		_:
			return "Unknown drive command: " + parts[1]

func process_sync_command(parts):
	if parts.size() < 2:
		return "Usage: sync <all|pool|status>"
	
	match parts[1].to_lower():
		"all":
			auto_sync_all_pools()
			return "Syncing all pools..."
			
		"pool":
			if parts.size() < 3:
				return "Usage: sync pool <pool_id>"
			
			var pool_id = parts[2]
			
			if not active_pools.has(pool_id):
				return "Pool not found: " + pool_id
			
			sync_pool(pool_id)
			return "Syncing pool: " + active_pools[pool_id].name
			
		"status":
			var result = "Sync Status:\n"
			result += "Total Syncs: " + str(total_syncs) + "\n"
			result += "Files Synced: " + str(total_files_synced) + "\n"
			result += "Data Transferred: " + format_size(bytes_transferred) + "\n"
			
			if last_sync_time > 0:
				result += "Last Sync: " + get_time_ago(OS.get_unix_time() - last_sync_time) + " ago\n"
			else:
				result += "Last Sync: Never\n"
				
			return result
			
		_:
			return "Unknown sync command: " + parts[1]

func process_google_command(parts):
	if parts.size() < 2:
		return "Usage: google <accounts|connect|disconnect>"
	
	match parts[1].to_lower():
		"accounts":
			scan_google_accounts()
			
			var result = "Google Drive Accounts:\n"
			
			if google_drive_accounts.empty():
				return "No Google accounts found"
			
			for id in google_drive_accounts:
				var account = google_drive_accounts[id]
				result += "- " + account.name
				
				if account.has("email") and account.email != "unknown":
					result += " (" + account.email + ")"
					
				result += " [Status: " + account.status + "]\n"
				
			return result
			
		"connect":
			if parts.size() < 3:
				return "Usage: google connect <account_id>"
			
			var account_id = parts[2]
			
			if connect_to_google_account(account_id):
				return "Connected to Google account: " + account_id
			else:
				return "Failed to connect to Google account: " + account_id
				
		"disconnect":
			if parts.size() < 3:
				return "Usage: google disconnect <account_id>"
			
			var account_id = parts[2]
			
			if not google_drive_accounts.has(account_id):
				return "Google account not found: " + account_id
			
			# Find associated connector
			var connector_id = ""
			if account_id == "default":
				connector_id = "google_drive_main"
			else:
				for drive_id in drive_connectors:
					if drive_id.begins_with("google_drive_"):
						var connector = drive_connectors[drive_id].connector
						if connector.has_method("get_account_id") and connector.get_account_id() == account_id:
							connector_id = drive_id
							break
			
			if connector_id == "":
				return "No connector found for Google account: " + account_id
			
			// Use the drive disconnect command
			var drive_parts = ["drive", "disconnect", connector_id]
			return process_drive_command(drive_parts)
			
		_:
			return "Unknown google command: " + parts[1]

func get_status_report():
	var report = "DATAPOOL SYNC MANAGER STATUS\n\n"
	
	report += "Pools: " + str(active_pools.size()) + "\n"
	report += "Drives: " + str(drive_connectors.size()) + "\n"
	report += "Google Accounts: " + str(google_drive_accounts.size()) + "\n"
	report += "Auto Sync: " + str(auto_sync_enabled) + "\n"
	report += "Sync Interval: " + str(sync_interval) + " seconds\n"
	report += "Conflict Resolution: " + conflict_resolution + "\n\n"
	
	report += "Statistics:\n"
	report += "Total Syncs: " + str(total_syncs) + "\n"
	report += "Files Synced: " + str(total_files_synced) + "\n"
	report += "Data Transferred: " + format_size(bytes_transferred) + "\n"
	
	if last_sync_time > 0:
		report += "Last Sync: " + get_time_ago(OS.get_unix_time() - last_sync_time) + " ago\n\n"
	else:
		report += "Last Sync: Never\n\n"
	
	report += "Connected Drives:\n"
	var connected_count = 0
	
	for id in drive_connectors:
		if drive_connectors[id].status == "connected":
			report += "- " + id + "\n"
			connected_count += 1
	
	if connected_count == 0:
		report += "No connected drives\n"
	
	return report

func show_help():
	return """
DATAPOOL SYNC MANAGER - COMMANDS

pool create <name> <type> [description] - Create a new data pool
pool list - List all data pools
pool attach <pool_id> <drive_id> [priority] - Attach a drive to a pool
pool detach <pool_id> <drive_id> - Detach a drive from a pool
pool info <pool_id> - Show detailed information about a pool

drive list - List available drive connectors
drive connect <drive_id> - Connect to a drive
drive disconnect <drive_id> - Disconnect from a drive
drive info <drive_id> - Show detailed information about a drive

sync all - Sync all pools
sync pool <pool_id> - Sync specific pool
sync status - Show sync statistics

google accounts - List Google Drive accounts
google connect <account_id> - Connect to a Google account
google disconnect <account_id> - Disconnect from a Google account

status - Show system status
help - Show this help text
"""

# Utility functions
func get_time_ago(seconds):
	if seconds < 60:
		return str(seconds) + " seconds"
	elif seconds < 3600:
		return str(int(seconds / 60)) + " minutes"
	elif seconds < 86400:
		return str(int(seconds / 3600)) + " hours"
	elif seconds < 604800:
		return str(int(seconds / 86400)) + " days"
	elif seconds < 2592000:
		return str(int(seconds / 604800)) + " weeks"
	else:
		return str(int(seconds / 2592000)) + " months"

func format_size(bytes):
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1048576:
		return str(int(bytes / 1024)) + " KB"
	elif bytes < 1073741824:
		return str(int(bytes / 1048576)) + " MB"
	else:
		return str(stepify(bytes / 1073741824.0, 0.01)) + " GB"