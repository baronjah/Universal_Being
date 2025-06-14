extends Node

class_name StorageIntegrationSystem

# Storage limits in bytes
const STORAGE_LIMITS = {
	"icloud_free": 5 * 1024 * 1024 * 1024,      # 5GB
	"icloud_paid": 200 * 1024 * 1024 * 1024,    # 200GB
	"google_free": 15 * 1024 * 1024 * 1024,     # 15GB
	"google_paid": 100 * 1024 * 1024 * 1024,    # 100GB
	"local_drive": 2 * 1024 * 1024 * 1024 * 1024 # 2TB
}

# Wish system constants
const MAX_WISHES_PER_DAY = 100
const WISH_TOKEN_COST = 10 # Default token cost per wish

# Storage paths
var storage_paths = {
	"icloud": "/mnt/c/Users/Percision 15/icloud_sync",
	"google": "/mnt/c/Users/Percision 15/google_drive",
	"local": "/mnt/c/Users/Percision 15",
	"wishes": "/mnt/c/Users/Percision 15/12_turns_system/wishes"
}

# Storage status tracking
var storage_status = {
	"icloud": {
		"connected": false,
		"used": 0,
		"total": STORAGE_LIMITS.icloud_free,
		"type": "free"
	},
	"google": {
		"connected": false,
		"used": 0,
		"total": STORAGE_LIMITS.google_free,
		"type": "free"
	},
	"local": {
		"connected": true,
		"used": 0,
		"total": STORAGE_LIMITS.local_drive,
		"type": "local"
	}
}

# Wish system tracking
var wish_system = {
	"today_count": 0,
	"total_count": 0,
	"tokens_used": 0,
	"wish_history": [],
	"active_wishes": [],
	"pending_wishes": []
}

# Integration references
var _akashic_bridge = null
var _terminal_interface = null

# Signals
signal storage_connected(platform, status)
signal storage_updated(platform, stats)
signal wish_created(wish_id, wish_text)
signal wish_completed(wish_id)
signal wish_limit_reached(count)
signal terminal_command_generated(command)

func _ready():
	# Initialize the system
	_initialize_system()

func _initialize_system():
	# Create required directories
	_ensure_directories_exist()
	
	# Connect to Akashic Bridge if available
	_connect_to_akashic_bridge()
	
	# Calculate storage usage
	_update_storage_usage()
	
	# Load wish history
	_load_wish_history()
	
	print("Storage Integration System initialized")
	print("Connected to local storage: " + str(storage_status.local.used / 1024 / 1024 / 1024) + "GB used of " + str(storage_status.local.total / 1024 / 1024 / 1024) + "GB")

# Directory management
func _ensure_directories_exist():
	var dir = Directory.new()
	
	for key in storage_paths:
		if not dir.dir_exists(storage_paths[key]):
			dir.make_dir_recursive(storage_paths[key])
			print("Created directory: " + storage_paths[key])

# Connection management
func _connect_to_akashic_bridge():
	# Try to find the Akashic Bridge
	if has_node("/root/ClaudeAkashicBridge") or get_node_or_null("/root/ClaudeAkashicBridge"):
		_akashic_bridge = get_node("/root/ClaudeAkashicBridge")
		print("Connected to existing Claude Akashic Bridge")
	else:
		# Check if the class exists
		if ClassDB.class_exists("ClaudeAkashicBridge"):
			_akashic_bridge = ClaudeAkashicBridge.new()
			add_child(_akashic_bridge)
			print("Created new Claude Akashic Bridge instance")

# Storage usage calculations
func _update_storage_usage():
	# Update local storage usage
	storage_status.local.used = _calculate_directory_size(storage_paths.local)
	emit_signal("storage_updated", "local", storage_status.local)
	
	# Update iCloud if connected
	if storage_status.icloud.connected:
		storage_status.icloud.used = _calculate_directory_size(storage_paths.icloud)
		emit_signal("storage_updated", "icloud", storage_status.icloud)
	
	# Update Google Drive if connected
	if storage_status.google.connected:
		storage_status.google.used = _calculate_directory_size(storage_paths.google)
		emit_signal("storage_updated", "google", storage_status.google)

func _calculate_directory_size(path):
	var dir = Directory.new()
	var size = 0
	
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				size += _calculate_directory_size(path.plus_file(file_name))
			else:
				var file_path = path.plus_file(file_name)
				var file = File.new()
				if file.open(file_path, File.READ) == OK:
					size += file.get_len()
					file.close()
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return size

# Wish system functions
func _load_wish_history():
	var wish_path = storage_paths.wishes.plus_file("wish_history.json")
	var file = File.new()
	
	if file.file_exists(wish_path):
		if file.open(wish_path, File.READ) == OK:
			var json_text = file.get_as_text()
			file.close()
			
			var parse_result = JSON.parse(json_text)
			if parse_result.error == OK:
				var data = parse_result.result
				wish_system.total_count = data.get("total_count", 0)
				wish_system.wish_history = data.get("wish_history", [])
				
				# Calculate today's count
				var today = OS.get_date()
				var today_str = str(today.year) + "-" + str(today.month) + "-" + str(today.day)
				
				wish_system.today_count = 0
				for wish in wish_system.wish_history:
					if wish.date == today_str:
						wish_system.today_count += 1
				
				print("Loaded wish history: " + str(wish_system.total_count) + " total wishes, " + str(wish_system.today_count) + " today")

# Public API methods

# Connect to cloud storage
func connect_cloud_storage(platform, credentials = {}):
	if not (platform == "icloud" or platform == "google"):
		push_error("Invalid platform: " + platform)
		return false
	
	print("Connecting to " + platform + " storage...")
	
	# Simulate connection
	var success = randf() > 0.2 # 80% chance of success
	
	if success:
		storage_status[platform].connected = true
		
		# Check if using paid tier
		if credentials.has("tier") and credentials.tier == "paid":
			if platform == "icloud":
				storage_status[platform].total = STORAGE_LIMITS.icloud_paid
				storage_status[platform].type = "paid"
			elif platform == "google":
				storage_status[platform].total = STORAGE_LIMITS.google_paid
				storage_status[platform].type = "paid"
		
		# Update storage usage
		_update_storage_usage()
		
		emit_signal("storage_connected", platform, true)
		print(platform + " storage connected successfully")
	else:
		emit_signal("storage_connected", platform, false)
		print(platform + " storage connection failed")
	
	return success

# Create a new wish
func create_wish(wish_text, priority = "normal", metadata = {}):
	# Check daily limit
	if wish_system.today_count >= MAX_WISHES_PER_DAY:
		push_warning("Daily wish limit reached")
		emit_signal("wish_limit_reached", wish_system.today_count)
		return null
	
	# Create wish ID
	var wish_id = "wish_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
	
	# Get current date
	var date = OS.get_date()
	var date_str = str(date.year) + "-" + str(date.month) + "-" + str(date.day)
	
	# Estimate token cost
	var token_cost = int(wish_text.length() / 4) # Rough estimate
	if token_cost < WISH_TOKEN_COST:
		token_cost = WISH_TOKEN_COST
	
	# Create wish object
	var wish = {
		"id": wish_id,
		"text": wish_text,
		"priority": priority,
		"date": date_str,
		"timestamp": OS.get_unix_time(),
		"status": "pending",
		"token_cost": token_cost,
		"metadata": metadata
	}
	
	# Store wish
	_store_wish(wish)
	
	# Update counters
	wish_system.today_count += 1
	wish_system.total_count += 1
	wish_system.tokens_used += token_cost
	wish_system.active_wishes.append(wish)
	wish_system.wish_history.append(wish)
	
	# Save wish history
	_save_wish_history()
	
	# Store in Akashic Records if connected
	if _akashic_bridge:
		_akashic_bridge.update_wish(wish_id, "pending", {
			"text": wish_text,
			"priority": priority,
			"token_cost": token_cost
		})
	
	# Generate terminal command for this wish
	var command = _generate_terminal_command(wish)
	if command:
		emit_signal("terminal_command_generated", command)
	
	emit_signal("wish_created", wish_id, wish_text)
	print("Created wish: " + wish_id)
	
	return wish

# Store files across available storage
func store_file(file_path, preferred_storage = "auto"):
	var file = File.new()
	
	if not file.file_exists(file_path):
		push_error("File does not exist: " + file_path)
		return false
	
	# Get file size
	file.open(file_path, File.READ)
	var file_size = file.get_len()
	file.close()
	
	# Get file name
	var file_name = file_path.get_file()
	
	# Determine best storage location
	var target_storage = preferred_storage
	if target_storage == "auto":
		target_storage = _determine_best_storage(file_size)
	
	if not storage_status[target_storage].connected:
		push_error("Selected storage not connected: " + target_storage)
		return false
	
	# Check if there's enough space
	if storage_status[target_storage].used + file_size > storage_status[target_storage].total:
		push_error("Not enough space in " + target_storage + " storage")
		return false
	
	# Create target path
	var target_path = storage_paths[target_storage].plus_file(file_name)
	
	# Copy the file
	var dir = Directory.new()
	if dir.copy(file_path, target_path) == OK:
		# Update storage usage
		_update_storage_usage()
		print("File stored successfully in " + target_storage + ": " + file_name)
		return true
	else:
		push_error("Failed to copy file to " + target_storage)
		return false

# Complete a wish
func complete_wish(wish_id, result = "completed", output = ""):
	var wish_index = -1
	
	# Find the wish in active wishes
	for i in range(wish_system.active_wishes.size()):
		if wish_system.active_wishes[i].id == wish_id:
			wish_index = i
			break
	
	if wish_index == -1:
		push_error("Wish not found: " + wish_id)
		return false
	
	# Update wish status
	wish_system.active_wishes[wish_index].status = result
	wish_system.active_wishes[wish_index].completion_time = OS.get_unix_time()
	wish_system.active_wishes[wish_index].output = output
	
	# Move from active to history
	var completed_wish = wish_system.active_wishes[wish_index]
	wish_system.active_wishes.remove(wish_index)
	
	# Update in Akashic Records if connected
	if _akashic_bridge:
		_akashic_bridge.update_wish(wish_id, result, {
			"completion_time": completed_wish.completion_time,
			"output": output
		})
	
	# Save wish history
	_save_wish_history()
	
	emit_signal("wish_completed", wish_id)
	print("Completed wish: " + wish_id)
	
	return true

# Generate terminal command for wish execution
func generate_terminal_command(wish_text):
	# Analyze wish text to generate appropriate command
	var command = ""
	
	# Basic commands based on keywords
	if wish_text.find("file") >= 0 or wish_text.find("files") >= 0:
		command = "ls -la " + storage_paths.local
	elif wish_text.find("storage") >= 0 or wish_text.find("space") >= 0:
		command = "df -h"
	elif wish_text.find("wish") >= 0 and (wish_text.find("list") >= 0 or wish_text.find("show") >= 0):
		command = "cat " + storage_paths.wishes.plus_file("wish_history.json")
	elif wish_text.find("terminal") >= 0 or wish_text.find("console") >= 0:
		command = "bash " + storage_paths.local.plus_file("12_turns_system/claude_terminal_interface.sh")
	elif wish_text.find("game") >= 0 or wish_text.find("play") >= 0:
		command = "bash " + storage_paths.local.plus_file("12_turns_system/start_game.sh")
	else:
		# If no specific command identified, create a more complex one
		command = _create_complex_command(wish_text)
	
	return command

# Interface management functions
func get_terminal_output_text(wish_text, line_count = 10):
	var output = []
	
	# Generate interesting output based on wish text
	output.append("======== WISH PROCESSING ========")
	
	# Add the wish text as a header
	output.append("WISH: " + wish_text)
	output.append("-------------------------------")
	
	# Generate status lines
	output.append("Connecting to dimensional gates...")
	
	if randf() > 0.5:
		output.append("Gate 0 (Physical): OPEN")
	else:
		output.append("Gate 0 (Physical): CONNECTED")
	
	if randf() > 0.3:
		output.append("Gate 1 (Experience): OPEN")
	else:
		output.append("Gate 1 (Experience): PARTIAL")
	
	if randf() > 0.7:
		output.append("Gate 2 (Transcendent): FLUCTUATING")
	else:
		output.append("Gate 2 (Transcendent): CLOSED")
	
	# Add processing steps
	output.append("Analyzing wish content...")
	output.append("Tokenizing request: " + str(int(wish_text.length() / 4)) + " tokens")
	output.append("Synchronizing storage systems...")
	output.append("Accessing Akashic records...")
	
	# Success or adjustment message
	if randf() > 0.7:
		output.append("WISH ADJUSTMENT REQUIRED")
		output.append("Reprocessing with dimensional filters...")
	else:
		output.append("WISH ACCEPTED for processing")
		
	# Add remaining wishes
	var remaining = MAX_WISHES_PER_DAY - wish_system.today_count
	if remaining < 0:
		remaining = 0
	output.append("Remaining wishes today: " + str(remaining))
	
	# Ensure we have at least the requested number of lines
	while output.size() < line_count:
		output.append("Processing layer " + str(output.size()) + "...")
	
	# If we have too many lines, trim
	if output.size() > line_count:
		output = output.slice(0, line_count - 1)
	
	# Add ending
	output.append("==============================")
	
	return output

# Get the storage status for UI display
func get_storage_status():
	return {
		"local": {
			"used_gb": storage_status.local.used / 1024.0 / 1024.0 / 1024.0,
			"total_gb": storage_status.local.total / 1024.0 / 1024.0 / 1024.0,
			"percentage": (storage_status.local.used * 100.0) / storage_status.local.total,
			"connected": storage_status.local.connected
		},
		"icloud": {
			"used_gb": storage_status.icloud.used / 1024.0 / 1024.0 / 1024.0,
			"total_gb": storage_status.icloud.total / 1024.0 / 1024.0 / 1024.0,
			"percentage": (storage_status.icloud.used * 100.0) / storage_status.icloud.total,
			"connected": storage_status.icloud.connected,
			"type": storage_status.icloud.type
		},
		"google": {
			"used_gb": storage_status.google.used / 1024.0 / 1024.0 / 1024.0,
			"total_gb": storage_status.google.total / 1024.0 / 1024.0 / 1024.0,
			"percentage": (storage_status.google.used * 100.0) / storage_status.google.total,
			"connected": storage_status.google.connected,
			"type": storage_status.google.type
		},
		"wishes": {
			"today": wish_system.today_count,
			"total": wish_system.total_count,
			"remaining": MAX_WISHES_PER_DAY - wish_system.today_count,
			"active": wish_system.active_wishes.size()
		}
	}

# Private methods
func _store_wish(wish):
	var dir = Directory.new()
	
	# Ensure wishes directory exists
	if not dir.dir_exists(storage_paths.wishes):
		dir.make_dir_recursive(storage_paths.wishes)
	
	# Create individual wish file
	var wish_file_path = storage_paths.wishes.plus_file(wish.id + ".json")
	var file = File.new()
	
	if file.open(wish_file_path, File.WRITE) == OK:
		file.store_string(JSON.print(wish, "  "))
		file.close()
	else:
		push_error("Failed to write wish file: " + wish_file_path)

func _save_wish_history():
	var wish_history_path = storage_paths.wishes.plus_file("wish_history.json")
	var file = File.new()
	
	if file.open(wish_history_path, File.WRITE) == OK:
		var data = {
			"total_count": wish_system.total_count,
			"wish_history": wish_system.wish_history
		}
		
		file.store_string(JSON.print(data, "  "))
		file.close()
	else:
		push_error("Failed to save wish history")

func _determine_best_storage(file_size):
	# Default to local storage
	var best_storage = "local"
	var best_free_percentage = 0
	
	# Check all connected storages
	for platform in storage_status:
		if storage_status[platform].connected:
			var free_space = storage_status[platform].total - storage_status[platform].used
			if free_space >= file_size:
				var free_percentage = (free_space * 100.0) / storage_status[platform].total
				if free_percentage > best_free_percentage:
					best_free_percentage = free_percentage
					best_storage = platform
	
	return best_storage

func _generate_terminal_command(wish):
	return generate_terminal_command(wish.text)

func _create_complex_command(wish_text):
	# Create a more complex terminal command based on wish text
	
	# Extract potential targets
	var targets = []
	
	if wish_text.find("notepad") >= 0 or wish_text.find("3d") >= 0:
		targets.append("notepad3d")
	
	if wish_text.find("word") >= 0 or wish_text.find("text") >= 0:
		targets.append("word_game")
	
	if wish_text.find("terminal") >= 0 or wish_text.find("console") >= 0:
		targets.append("terminal_interface")
	
	if wish_text.find("wish") >= 0 or wish_text.find("desire") >= 0:
		targets.append("wish_dimension")
	
	if wish_text.find("3 interface") >= 0 or wish_text.find("three interface") >= 0:
		targets.append("multi_terminal")
	
	# Create a combined command
	var command = ""
	
	if targets.size() > 0:
		# Choose a target
		var target = targets[randi() % targets.size()]
		
		# Create command based on target
		match target:
			"notepad3d":
				command = "bash " + storage_paths.local.plus_file("12_turns_system/digital_printer.sh") + " 'create 3d notepad interface'"
			"word_game":
				command = "bash " + storage_paths.local.plus_file("12_turns_system/word_game.sh")
			"terminal_interface":
				command = "bash " + storage_paths.local.plus_file("12_turns_system/terminal_interface.sh")
			"wish_dimension":
				command = "bash " + storage_paths.local.plus_file("12_turns_system/run_wish_dimension_demo.sh")
			"multi_terminal":
				command = "bash " + storage_paths.local.plus_file("12_turns_system/multi_terminal_controller.sh")
			_:
				command = "echo 'Processing wish: " + wish_text + "'"
	else:
		# Generic command if no specific target
		command = "echo 'Processing wish: " + wish_text + "' && bash " + storage_paths.local.plus_file("12_turns_system/turn_manager.sh")
	
	return command