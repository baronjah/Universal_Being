extends Node

class_name DataSplitterTerminalBridge

# ----- NODE PATHS -----
@export_node_path var data_splitter_controller_path: NodePath
@export_node_path var terminal_bridge_connector_path: NodePath
@export_node_path var console_path: NodePath

# ----- COMPONENT REFERENCES -----
var data_splitter_controller = null
var terminal_bridge_connector = null
var console = null

# ----- CONFIGURATION -----
@export var auto_initialize: bool = true
@export var enable_debug_logs: bool = true
@export var max_command_history: int = 50
@export var enable_color_output: bool = true
@export var attach_to_turn_system: bool = true

# ----- BRIDGE SETTINGS -----
@export var terminal_poll_interval: float = 0.5  # seconds
@export var data_sewer_path: String = "user://data_sewers"
@export var terminal_data_path: String = "user://terminal_data"
@export var terminal_file_extension: String = ".terminal"
@export var bridge_active: bool = false

# ----- COMMAND PREFIXES -----
const CMD_DATA_SPLIT = "/split"
const CMD_DATA_STREAM = "/stream"
const CMD_DATA_CHUNK = "/chunk"
const CMD_DATA_MERGE = "/merge"
const CMD_DATA_LIST = "/list"
const CMD_DATA_ANALYZE = "/analyze"
const CMD_DATA_VISUALIZE = "/visualize"
const CMD_DATA_HELP = "/help"

# ----- COMMUNICATION STATE -----
var last_poll_time = 0
var terminal_last_modified = {}
var command_history = []
var last_command_index = -1
var active_terminal_windows = []
var current_dimension: int = 3
var current_reality: String = "Digital"
var current_terminal_id: int = 0
var pending_data_operations = []

# ----- SIGNALS -----
signal terminal_bridge_ready
signal command_processed(command, result)
signal terminal_message_received(terminal_id, message)
signal data_operation_completed(operation_type, result)
signal terminal_bridge_error(error_message)
signal dimension_changed(new_dimension)
signal reality_changed(new_reality)

# ----- INITIALIZATION -----
func _ready():
	if auto_initialize:
		initialize()

func initialize():
	print("DataSplitterTerminalBridge: Initializing...")
	
	# Find components
	_resolve_component_paths()
	
	# Create required directories
	_create_directories()
	
	# Initialize terminal data
	_init_terminal_data()
	
	# Connect signals
	_connect_signals()
	
	# Start bridge
	bridge_active = true
	
	print("DataSplitterTerminalBridge: Initialization complete")
	emit_signal("terminal_bridge_ready")

func _resolve_component_paths():
	# Resolve DataSplitterController
	if data_splitter_controller_path:
		data_splitter_controller = get_node_or_null(data_splitter_controller_path)
		
	if not data_splitter_controller:
		data_splitter_controller = get_node_or_null("/root/DataSplitterController")
		if not data_splitter_controller:
			var nodes = get_tree().get_nodes_in_group("data_splitter")
			if nodes.size() > 0:
				data_splitter_controller = nodes[0]
	
	# Resolve TerminalBridgeConnector
	if terminal_bridge_connector_path:
		terminal_bridge_connector = get_node_or_null(terminal_bridge_connector_path)
		
	if not terminal_bridge_connector:
		terminal_bridge_connector = get_node_or_null("/root/TerminalBridgeConnector")
		if not terminal_bridge_connector:
			var nodes = get_tree().get_nodes_in_group("terminal_bridge")
			if nodes.size() > 0:
				terminal_bridge_connector = nodes[0]
	
	# Resolve Console
	if console_path:
		console = get_node_or_null(console_path)
		
	if not console and data_splitter_controller:
		console = data_splitter_controller.get_node_or_null("../Console")
		
	# Log results
	if enable_debug_logs:
		print("DataSplitterTerminalBridge: Component resolution:")
		print("- Data Splitter Controller: ", "Found" if data_splitter_controller else "Not found")
		print("- Terminal Bridge Connector: ", "Found" if terminal_bridge_connector else "Not found")
		print("- Console: ", "Found" if console else "Not found")

func _create_directories():
	# Create data sewer directory
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists(data_sewer_path):
			dir.make_dir_recursive(data_sewer_path)
		
		# Create terminal data directory
		if not dir.dir_exists(terminal_data_path):
			dir.make_dir_recursive(terminal_data_path)
			
		if enable_debug_logs:
			print("DataSplitterTerminalBridge: Directories created")
	else:
		print("DataSplitterTerminalBridge: Error accessing user directory")

func _init_terminal_data():
	# Create terminal data files for multiple terminals
	for i in range(6):  # Support 6 terminal windows
		var terminal_file = terminal_data_path + "/terminal_" + str(i) + terminal_file_extension
		
		if not FileAccess.file_exists(terminal_file):
			var file = FileAccess.open(terminal_file, FileAccess.WRITE)
			if file:
				var init_data = {
					"terminal_id": i,
					"last_update": Time.get_unix_time_from_system(),
					"messages": ["Terminal " + str(i) + " initialized for data splitting"],
					"data_operations": [],
					"data_results": []
				}
				file.store_string(JSON.stringify(init_data))
				
				if enable_debug_logs:
					print("DataSplitterTerminalBridge: Created terminal file for Terminal " + str(i))
		
		# Store last modified time
		terminal_last_modified[i] = Time.get_unix_time_from_system()
		
		# Add to active terminals
		active_terminal_windows.append(i)

func _connect_signals():
	# Connect to DataSplitterController signals
	if data_splitter_controller:
		# Connect to initialization_completed if available
		if data_splitter_controller.has_signal("initialization_completed"):
			data_splitter_controller.connect("initialization_completed", Callable(self, "_on_data_splitter_initialized"))
		
		# Connect to data operation signals
		if data_splitter_controller.has_signal("data_stream_created"):
			data_splitter_controller.connect("data_stream_created", Callable(self, "_on_data_stream_created"))
		
		if data_splitter_controller.has_signal("data_chunk_created"):
			data_splitter_controller.connect("data_chunk_created", Callable(self, "_on_data_chunk_created"))
		
		if data_splitter_controller.has_signal("data_split_created"):
			data_splitter_controller.connect("data_split_created", Callable(self, "_on_data_split_created"))
		
		if data_splitter_controller.has_signal("data_merged"):
			data_splitter_controller.connect("data_merged", Callable(self, "_on_data_merged"))
		
		if data_splitter_controller.has_signal("dimension_changed"):
			data_splitter_controller.connect("dimension_changed", Callable(self, "_on_dimension_changed"))
		
		if data_splitter_controller.has_signal("reality_changed"):
			data_splitter_controller.connect("reality_changed", Callable(self, "_on_reality_changed"))
	
	# Connect to TerminalBridgeConnector signals
	if terminal_bridge_connector:
		# Connect to terminal_connected if available
		if terminal_bridge_connector.has_signal("terminal_connected"):
			terminal_bridge_connector.connect("terminal_connected", Callable(self, "_on_terminal_connected"))
		
		# Connect to color shift signals
		if terminal_bridge_connector.has_signal("color_shift_detected"):
			terminal_bridge_connector.connect("color_shift_detected", Callable(self, "_on_color_shift_detected"))

# ----- PROCESSING -----
func _process(delta):
	if not bridge_active:
		return
	
	# Poll terminals at specified interval
	last_poll_time += delta
	if last_poll_time >= terminal_poll_interval:
		last_poll_time = 0
		_poll_terminal_files()
	
	# Process pending data operations
	_process_pending_data_operations()

func _poll_terminal_files():
	# Check terminal files for changes
	for terminal_id in active_terminal_windows:
		var terminal_file = terminal_data_path + "/terminal_" + str(terminal_id) + terminal_file_extension
		
		if FileAccess.file_exists(terminal_file):
			# Check if file has been modified
			var file_access = FileAccess.open(terminal_file, FileAccess.READ)
			if file_access:
				var modified_time = Time.get_unix_time_from_system()
				
				if not terminal_last_modified.has(terminal_id) or modified_time > terminal_last_modified[terminal_id]:
					terminal_last_modified[terminal_id] = modified_time
					
					# Read terminal data
					var json_text = file_access.get_as_text()
					
					var json = JSON.parse_string(json_text)
					if json:
						_process_terminal_data(json)
					else:
						print("DataSplitterTerminalBridge: Error parsing terminal JSON for Terminal " + str(terminal_id))

func _process_terminal_data(data):
	var terminal_id = data.terminal_id
	
	# Process messages
	if data.has("messages") and data.messages.size() > 0:
		var last_message = data.messages[data.messages.size() - 1]
		emit_signal("terminal_message_received", terminal_id, last_message)
		
		# Check if it's a data splitter command
		if last_message.begins_with("/"):
			_process_command(last_message, terminal_id)
	
	# Process data operations
	if data.has("data_operations") and data.operations.size() > 0:
		for operation in data.data_operations:
			# Check if operation is new
			var is_new = true
			
			for pending in pending_data_operations:
				if pending.id == operation.id:
					is_new = false
					break
			
			if is_new:
				pending_data_operations.append(operation)

func _process_command(command: String, terminal_id: int):
	# Store command in history
	_add_to_command_history(command)
	
	# Set current terminal ID
	current_terminal_id = terminal_id
	
	# Process command based on prefix
	var parts = command.split(" ", false, 1)
	var cmd = parts[0].to_lower()
	var params = ""
	if parts.size() > 1:
		params = parts[1]
	
	var result = {}
	
	match cmd:
		CMD_DATA_SPLIT:
			result = _handle_split_command(params)
		CMD_DATA_STREAM:
			result = _handle_stream_command(params)
		CMD_DATA_CHUNK:
			result = _handle_chunk_command(params)
		CMD_DATA_MERGE:
			result = _handle_merge_command(params)
		CMD_DATA_LIST:
			result = _handle_list_command(params)
		CMD_DATA_ANALYZE:
			result = _handle_analyze_command(params)
		CMD_DATA_VISUALIZE:
			result = _handle_visualize_command(params)
		CMD_DATA_HELP, "/data-help":
			result = _handle_help_command(params)
		_:
			# Check if command might be for data splitter
			if command.begins_with("/data-"):
				var custom_cmd = command.substr(6)
				result = _handle_custom_command(custom_cmd)
			else:
				# Not a data splitter command
				return
	
	# Send command result to terminal
	_send_result_to_terminal(result, terminal_id)
	
	# Emit signal
	emit_signal("command_processed", command, result)

func _process_pending_data_operations():
	# Process pending operations
	if pending_data_operations.size() > 0:
		var operation = pending_data_operations[0]
		
		match operation.type:
			"split":
				if data_splitter_controller:
					var result = data_splitter_controller.split_data_chunk(operation.chunk_id, operation.split_factor)
					_send_operation_result_to_terminal(operation.terminal_id, result)
					emit_signal("data_operation_completed", "split", result)
			"merge":
				if data_splitter_controller:
					var result = data_splitter_controller.merge_data_chunks(operation.chunk_ids, operation.merge_type)
					_send_operation_result_to_terminal(operation.terminal_id, result)
					emit_signal("data_operation_completed", "merge", result)
			"create_stream":
				if data_splitter_controller:
					var result = data_splitter_controller.create_data_stream(operation.stream_id, operation.data_type, operation.size)
					_send_operation_result_to_terminal(operation.terminal_id, result)
					emit_signal("data_operation_completed", "create_stream", result)
			"create_chunk":
				if data_splitter_controller:
					var result = data_splitter_controller.create_data_chunk(operation.chunk_id, operation.content, operation.parent_stream)
					_send_operation_result_to_terminal(operation.terminal_id, result)
					emit_signal("data_operation_completed", "create_chunk", result)
		
		# Remove processed operation
		pending_data_operations.pop_front()

# ----- COMMAND HANDLERS -----
func _handle_split_command(params: String) -> Dictionary:
	# Split command: /split [chunk_id] [split_factor]
	if params.strip_edges().is_empty():
		return {
			"success": false,
			"message": "Usage: " + CMD_DATA_SPLIT + " [chunk_id] [split_factor]"
		}
	
	var parts = params.split(" ", false)
	var chunk_id = parts[0]
	var split_factor = 3  # Default split factor
	
	if parts.size() >= 2 and parts[1].is_valid_integer():
		split_factor = parts[1].to_int()
	
	if data_splitter_controller:
		# Add operation to pending list
		_add_pending_operation({
			"id": "split_" + str(Time.get_unix_time_from_system()),
			"type": "split",
			"chunk_id": chunk_id,
			"split_factor": split_factor,
			"terminal_id": current_terminal_id
		})
		
		return {
			"success": true,
			"message": "Splitting chunk '" + chunk_id + "' with factor " + str(split_factor) + "...",
			"operation": "split",
			"chunk_id": chunk_id,
			"split_factor": split_factor
		}
	else:
		return {
			"success": false,
			"message": "Data Splitter Controller not available"
		}

func _handle_stream_command(params: String) -> Dictionary:
	# Stream command: /stream [stream_id] [data_type] [size]
	if params.strip_edges().is_empty():
		return {
			"success": false,
			"message": "Usage: " + CMD_DATA_STREAM + " [stream_id] [data_type] [size]"
		}
	
	var parts = params.split(" ", false)
	var stream_id = parts[0]
	var data_type = "binary"  # Default data type
	var size = 16  # Default size
	
	if parts.size() >= 2:
		data_type = parts[1]
	
	if parts.size() >= 3 and parts[2].is_valid_integer():
		size = parts[2].to_int()
	
	if data_splitter_controller:
		# Add operation to pending list
		_add_pending_operation({
			"id": "stream_" + str(Time.get_unix_time_from_system()),
			"type": "create_stream",
			"stream_id": stream_id,
			"data_type": data_type,
			"size": size,
			"terminal_id": current_terminal_id
		})
		
		return {
			"success": true,
			"message": "Creating data stream '" + stream_id + "' of type " + data_type + " with size " + str(size) + "...",
			"operation": "create_stream",
			"stream_id": stream_id,
			"data_type": data_type,
			"size": size
		}
	else:
		return {
			"success": false,
			"message": "Data Splitter Controller not available"
		}

func _handle_chunk_command(params: String) -> Dictionary:
	# Chunk command: /chunk [chunk_id] [parent_stream] [content]
	if params.strip_edges().is_empty():
		return {
			"success": false,
			"message": "Usage: " + CMD_DATA_CHUNK + " [chunk_id] [parent_stream] [content]"
		}
	
	var parts = params.split(" ", false, 2)
	
	if parts.size() < 3:
		return {
			"success": false,
			"message": "Usage: " + CMD_DATA_CHUNK + " [chunk_id] [parent_stream] [content]"
		}
	
	var chunk_id = parts[0]
	var parent_stream = parts[1]
	var content = parts[2]
	
	if data_splitter_controller:
		# Add operation to pending list
		_add_pending_operation({
			"id": "chunk_" + str(Time.get_unix_time_from_system()),
			"type": "create_chunk",
			"chunk_id": chunk_id,
			"parent_stream": parent_stream,
			"content": content,
			"terminal_id": current_terminal_id
		})
		
		return {
			"success": true,
			"message": "Creating data chunk '" + chunk_id + "' in stream '" + parent_stream + "'...",
			"operation": "create_chunk",
			"chunk_id": chunk_id,
			"parent_stream": parent_stream,
			"content_length": content.length()
		}
	else:
		return {
			"success": false,
			"message": "Data Splitter Controller not available"
		}

func _handle_merge_command(params: String) -> Dictionary:
	# Merge command: /merge [chunk_id1,chunk_id2,...] [merge_type]
	if params.strip_edges().is_empty():
		return {
			"success": false,
			"message": "Usage: " + CMD_DATA_MERGE + " [chunk_id1,chunk_id2,...] [merge_type]"
		}
	
	var parts = params.split(" ", false)
	
	if parts.size() < 1:
		return {
			"success": false,
			"message": "Usage: " + CMD_DATA_MERGE + " [chunk_id1,chunk_id2,...] [merge_type]"
		}
	
	var chunk_ids_str = parts[0]
	var chunk_ids = chunk_ids_str.split(",", false)
	
	if chunk_ids.size() < 2:
		return {
			"success": false,
			"message": "Need at least 2 chunks to merge. Usage: " + CMD_DATA_MERGE + " [chunk_id1,chunk_id2,...] [merge_type]"
		}
	
	var merge_type = "concatenate"  # Default merge type
	
	if parts.size() >= 2:
		merge_type = parts[1]
	
	if data_splitter_controller:
		# Add operation to pending list
		_add_pending_operation({
			"id": "merge_" + str(Time.get_unix_time_from_system()),
			"type": "merge",
			"chunk_ids": chunk_ids,
			"merge_type": merge_type,
			"terminal_id": current_terminal_id
		})
		
		return {
			"success": true,
			"message": "Merging " + str(chunk_ids.size()) + " chunks with merge type '" + merge_type + "'...",
			"operation": "merge",
			"chunk_ids": chunk_ids,
			"merge_type": merge_type
		}
	else:
		return {
			"success": false,
			"message": "Data Splitter Controller not available"
		}

func _handle_list_command(params: String) -> Dictionary:
	# List command: /list [streams|chunks|splits|all]
	var list_type = "all"
	
	if not params.strip_edges().is_empty():
		list_type = params.strip_edges().to_lower()
	
	if data_splitter_controller:
		var streams = []
		var chunks = {}
		var splits = {}
		var listing = "[color=#88ff99]Data Splitter Elements:[/color]\n"
		
		# Get data from controller
		if list_type == "all" or list_type == "streams":
			if data_splitter_controller.has_method("get_data_streams"):
				streams = data_splitter_controller.get_data_streams()
			elif data_splitter_controller.has("data_streams"):
				streams = data_splitter_controller.data_streams
		
		if list_type == "all" or list_type == "chunks":
			if data_splitter_controller.has_method("get_data_chunks"):
				chunks = data_splitter_controller.get_data_chunks()
			elif data_splitter_controller.has("data_chunks"):
				chunks = data_splitter_controller.data_chunks
		
		if list_type == "all" or list_type == "splits":
			if data_splitter_controller.has_method("get_data_splits"):
				splits = data_splitter_controller.get_data_splits()
			elif data_splitter_controller.has("data_splits"):
				splits = data_splitter_controller.data_splits
		
		# Generate listing
		if list_type == "all" or list_type == "streams":
			listing += "\n[color=#aaaaff]Streams (" + str(streams.size()) + "):[/color]\n"
			for stream in streams:
				listing += "- " + stream.id + " (" + stream.type + ", " + str(stream.size) + " bytes, " + str(stream.chunks.size()) + " chunks)\n"
		
		if list_type == "all" or list_type == "chunks":
			listing += "\n[color=#ffaaaa]Chunks (" + str(chunks.size()) + "):[/color]\n"
			var chunk_count = 0
			for chunk_id in chunks:
				listing += "- " + chunk_id + " (size: " + str(chunks[chunk_id].size) + ")\n"
				chunk_count += 1
				if chunk_count >= 10 and chunks.size() > 10:
					listing += "  ... and " + str(chunks.size() - 10) + " more\n"
					break
		
		if list_type == "all" or list_type == "splits":
			listing += "\n[color=#aaffaa]Splits (" + str(splits.size()) + "):[/color]\n"
			var split_count = 0
			for split_id in splits:
				listing += "- " + split_id + " (factor: " + str(splits[split_id].factor) + ")\n"
				split_count += 1
				if split_count >= 5 and splits.size() > 5:
					listing += "  ... and " + str(splits.size() - 5) + " more\n"
					break
		
		_log_message(listing)
		
		return {
			"success": true,
			"message": listing,
			"streams_count": streams.size(),
			"chunks_count": chunks.size(),
			"splits_count": splits.size()
		}
	else:
		return {
			"success": false,
			"message": "Data Splitter Controller not available"
		}

func _handle_analyze_command(params: String) -> Dictionary:
	# Analyze command: /analyze [text_to_analyze]
	if params.strip_edges().is_empty():
		return {
			"success": false,
			"message": "Usage: " + CMD_DATA_ANALYZE + " [text_to_analyze]"
		}
	
	# Perform basic analysis
	var analysis = {
		"total_chars": params.length(),
		"word_count": params.split(" ", false).size(),
		"line_count": params.split("\n", false).size(),
		"special_chars": {}
	}
	
	var special_chars = ["[", "]", "=", "|", "#", "@", "$", "%", "^", "&", "*"]
	
	for char in special_chars:
		var count = params.count(char)
		if count > 0:
			analysis.special_chars[char] = count
	
	# Check if there are potential natural split points
	var natural_splits = []
	
	if params.find("[") >= 0 and params.find("]") >= 0:
		natural_splits.append("brackets")
	
	if params.find("=") >= 0:
		natural_splits.append("equals")
	
	if params.find("|") >= 0:
		natural_splits.append("pipes")
	
	if params.find(",") >= 0:
		natural_splits.append("commas")
	
	analysis["natural_splits"] = natural_splits
	
	var message = "[color=#88ff99]Text Analysis:[/color]\n"
	message += "Characters: " + str(analysis.total_chars) + "\n"
	message += "Words: " + str(analysis.word_count) + "\n"
	message += "Lines: " + str(analysis.line_count) + "\n"
	
	if analysis.special_chars.size() > 0:
		message += "\n[color=#aaaaff]Special Characters:[/color]\n"
		for char in analysis.special_chars:
			message += "- '" + char + "': " + str(analysis.special_chars[char]) + "\n"
	
	if natural_splits.size() > 0:
		message += "\n[color=#aaffaa]Suggested Split Methods:[/color]\n"
		for split in natural_splits:
			message += "- " + split + "\n"
	
	_log_message(message)
	
	return {
		"success": true,
		"message": message,
		"analysis": analysis
	}

func _handle_visualize_command(params: String) -> Dictionary:
	# Visualize command: /visualize [chunk_id|stream_id] [dimension]
	if params.strip_edges().is_empty():
		return {
			"success": false,
			"message": "Usage: " + CMD_DATA_VISUALIZE + " [chunk_id|stream_id] [dimension]"
		}
	
	var parts = params.split(" ", false)
	var entity_id = parts[0]
	var dimension = current_dimension
	
	if parts.size() >= 2 and parts[1].is_valid_integer():
		dimension = parts[1].to_int()
	
	if data_splitter_controller:
		# Try to find entity
		var entity_type = "unknown"
		var found = false
		
		if data_splitter_controller.has_method("get_data_streams"):
			var streams = data_splitter_controller.get_data_streams()
			for stream in streams:
				if stream.id == entity_id:
					entity_type = "stream"
					found = true
					break
		elif data_splitter_controller.has("data_streams"):
			for stream in data_splitter_controller.data_streams:
				if stream.id == entity_id:
					entity_type = "stream"
					found = true
					break
		
		if not found and data_splitter_controller.has_method("get_data_chunks"):
			var chunks = data_splitter_controller.get_data_chunks()
			if chunks.has(entity_id):
				entity_type = "chunk"
				found = true
		elif not found and data_splitter_controller.has("data_chunks"):
			if data_splitter_controller.data_chunks.has(entity_id):
				entity_type = "chunk"
				found = true
		
		if found:
			var visualization_text = "[color=#88ff99]Visualizing " + entity_type + " '" + entity_id + "' in " + str(dimension) + "D:[/color]\n\n"
			
			if entity_type == "stream":
				visualization_text += _generate_stream_visualization(entity_id, dimension)
			else:
				visualization_text += _generate_chunk_visualization(entity_id, dimension)
			
			_log_message(visualization_text)
			
			return {
				"success": true,
				"message": visualization_text,
				"entity_type": entity_type,
				"entity_id": entity_id,
				"dimension": dimension
			}
		else:
			return {
				"success": false,
				"message": "Entity '" + entity_id + "' not found"
			}
	else:
		return {
			"success": false,
			"message": "Data Splitter Controller not available"
		}

func _handle_help_command(params: String) -> Dictionary:
	# Help command: /help
	var help_text = "[color=#88ff99]Data Splitter Terminal Bridge Commands:[/color]\n"
	help_text += "/split [chunk_id] [split_factor] - Split a data chunk\n"
	help_text += "/stream [stream_id] [data_type] [size] - Create a new data stream\n"
	help_text += "/chunk [chunk_id] [parent_stream] [content] - Create a new data chunk\n"
	help_text += "/merge [chunk_id1,chunk_id2,...] [merge_type] - Merge multiple chunks\n"
	help_text += "/list [streams|chunks|splits|all] - List data elements\n"
	help_text += "/analyze [text] - Analyze text for data splitting\n"
	help_text += "/visualize [chunk_id|stream_id] [dimension] - Visualize data in terminal\n"
	help_text += "/help - Display this help\n"
	
	_log_message(help_text)
	
	return {
		"success": true,
		"message": help_text
	}

func _handle_custom_command(command: String) -> Dictionary:
	# Handle custom commands passed to data splitter
	if data_splitter_controller and data_splitter_controller.has_method("process_command"):
		var result = data_splitter_controller.process_command(command)
		
		if not result.success:
			_log_message("Error: " + result.message)
		
		return result
	else:
		return {
			"success": false,
			"message": "Data Splitter Controller not available or does not support custom commands"
		}

# ----- HELPER FUNCTIONS -----
func _add_to_command_history(command: String):
	command_history.append(command)
	
	if command_history.size() > max_command_history:
		command_history.pop_front()
	
	last_command_index = command_history.size()

func _add_pending_operation(operation: Dictionary):
	pending_data_operations.append(operation)

func _send_result_to_terminal(result: Dictionary, terminal_id: int):
	var message = result.message if result.has("message") else ""
	
	if enable_color_output:
		if result.success:
			message = "[color=#88ff99]" + message + "[/color]"
		else:
			message = "[color=#ff7777]" + message + "[/color]"
	
	_send_message_to_terminal(terminal_id, message)

func _send_operation_result_to_terminal(terminal_id: int, result: Dictionary):
	var message = ""
	
	if result.success:
		message = "[color=#88ff99]Operation completed successfully![/color]\n"
		
		if result.has("message"):
			message += result.message
	else:
		message = "[color=#ff7777]Operation failed: " + result.message + "[/color]"
	
	_send_message_to_terminal(terminal_id, message)
	
	# Add result to terminal data file
	var terminal_file = terminal_data_path + "/terminal_" + str(terminal_id) + terminal_file_extension
	if FileAccess.file_exists(terminal_file):
		var file_access = FileAccess.open(terminal_file, FileAccess.READ)
		if file_access:
			var json_text = file_access.get_as_text()
			var json = JSON.parse_string(json_text)
			
			if json:
				if not json.has("data_results"):
					json.data_results = []
				
				json.data_results.append({
					"timestamp": Time.get_unix_time_from_system(),
					"result": result
				})
				
				file_access.close()
				
				# Save updated data
				file_access = FileAccess.open(terminal_file, FileAccess.WRITE)
				if file_access:
					file_access.store_string(JSON.stringify(json))

func _send_message_to_terminal(terminal_id: int, message: String):
	var terminal_file = terminal_data_path + "/terminal_" + str(terminal_id) + terminal_file_extension
	
	if FileAccess.file_exists(terminal_file):
		var file_access = FileAccess.open(terminal_file, FileAccess.READ)
		if file_access:
			var json_text = file_access.get_as_text()
			var json = JSON.parse_string(json_text)
			
			if json:
				if not json.has("messages"):
					json.messages = []
				
				json.messages.append(message)
				json.last_update = Time.get_unix_time_from_system()
				
				file_access.close()
				
				# Save updated data
				file_access = FileAccess.open(terminal_file, FileAccess.WRITE)
				if file_access:
					file_access.store_string(JSON.stringify(json))
					
					if enable_debug_logs:
						print("DataSplitterTerminalBridge: Message sent to Terminal " + str(terminal_id))
				else:
					print("DataSplitterTerminalBridge: Error opening terminal file for writing")
			else:
				print("DataSplitterTerminalBridge: Error parsing terminal JSON")
		else:
			print("DataSplitterTerminalBridge: Error opening terminal file for reading")
	else:
		print("DataSplitterTerminalBridge: Terminal file not found for Terminal " + str(terminal_id))

func _log_message(message: String):
	# Log to console if available
	if console:
		var output = console.get_node_or_null("Panel/OutputLabel")
		if output and output is RichTextLabel:
			output.text += message + "\n"
			
			# Scroll to bottom
			output.scroll_to_line(output.get_line_count() - 1)
	
	# Print to debug console if debug logs enabled
	if enable_debug_logs:
		print("DataSplitterTerminalBridge: " + message.replace("[color=#88ff99]", "").replace("[/color]", "").replace("[color=#aaaaff]", "").replace("[color=#ffaaaa]", "").replace("[color=#aaffaa]", "").replace("[color=#ff7777]", ""))

func _generate_stream_visualization(stream_id: String, dimension: int) -> String:
	var visualization = ""
	var stream_data = null
	
	# Get stream data
	if data_splitter_controller.has_method("get_data_streams"):
		var streams = data_splitter_controller.get_data_streams()
		for stream in streams:
			if stream.id == stream_id:
				stream_data = stream
				break
	elif data_splitter_controller.has("data_streams"):
		for stream in data_splitter_controller.data_streams:
			if stream.id == stream_id:
				stream_data = stream
				break
	
	if not stream_data:
		return "Stream data not found"
	
	# Generate visualization based on dimension
	match dimension:
		1:
			# 1D visualization - simple line
			visualization += "[color=#aaaaff]" + "|" + "=" * (stream_data.size / 2) + stream_id + "=" * (stream_data.size / 2) + "|" + "[/color]\n"
			
			if stream_data.has("chunks") and stream_data.chunks.size() > 0:
				visualization += "-" * 40 + "\n"
				visualization += "Chunks: "
				
				for i in range(stream_data.chunks.size()):
					if i > 0:
						visualization += " - "
					visualization += stream_data.chunks[i]
		
		2:
			# 2D visualization - box
			var width = min(40, stream_data.size + 10)
			var top_bottom = "+" + "-" * (width - 2) + "+\n"
			
			visualization += "[color=#aaaaff]" + top_bottom
			
			# Create content lines
			var side = "|"
			
			# Stream ID line
			var padding = " " * ((width - 2 - stream_id.length()) / 2)
			visualization += side + padding + stream_id + padding
			if (width - 2 - stream_id.length()) % 2 != 0:
				visualization += " "
			visualization += side + "\n"
			
			// Stream type line
			var type_text = "Type: " + stream_data.type
			padding = " " * ((width - 2 - type_text.length()) / 2)
			visualization += side + padding + type_text + padding
			if (width - 2 - type_text.length()) % 2 != 0:
				visualization += " "
			visualization += side + "\n"
			
			// Stream size line
			var size_text = "Size: " + str(stream_data.size)
			padding = " " * ((width - 2 - size_text.length()) / 2)
			visualization += side + padding + size_text + padding
			if (width - 2 - size_text.length()) % 2 != 0:
				visualization += " "
			visualization += side + "\n"
			
			// Chunk count line
			var chunk_text = "Chunks: " + str(stream_data.chunks.size())
			padding = " " * ((width - 2 - chunk_text.length()) / 2)
			visualization += side + padding + chunk_text + padding
			if (width - 2 - chunk_text.length()) % 2 != 0:
				visualization += " "
			visualization += side + "\n"
			
			visualization += top_bottom + "[/color]"
			
			// If chunks exist, list them
			if stream_data.has("chunks") and stream_data.chunks.size() > 0:
				visualization += "\nChunks:\n"
				for chunk_id in stream_data.chunks:
					visualization += "- " + chunk_id + "\n"
		
		3, _:
			// 3D+ visualization - more detailed ASCII art
			var width = min(60, stream_data.size + 20)
			
			// Top
			visualization += "[color=#aaaaff]" + "    " + "_" * (width - 8) + "\n"
			visualization += "   /|" + " " * (width - 8) + "|\n"
			
			// Stream ID line
			var stream_id_padded = stream_id
			if stream_id.length() < width - 12:
				var padding = (width - 12 - stream_id.length()) / 2
				stream_id_padded = " " * padding + stream_id + " " * padding
			else:
				stream_id_padded = stream_id.substr(0, width - 15) + "..."
			
			visualization += "  / |  " + stream_id_padded + "  |\n"
			
			// Stream properties
			var type_text = "Type: " + stream_data.type
			var size_text = "Size: " + str(stream_data.size)
			var chunk_text = "Chunks: " + str(stream_data.chunks.size())
			
			visualization += " /__|" + "_" * (width - 8) + "|\n"
			visualization += "|   |" + " " * (width - 8) + "|\n"
			visualization += "|   |  " + type_text + " " * (width - 12 - type_text.length()) + "|\n"
			visualization += "|   |  " + size_text + " " * (width - 12 - size_text.length()) + "|\n"
			visualization += "|   |  " + chunk_text + " " * (width - 12 - chunk_text.length()) + "|\n"
			visualization += "|___|" + "_" * (width - 8) + "|[/color]\n"
			
			// Show dimensions based on dimension count
			if dimension >= 4:
				var dimension_text = "Dimensions: " + str(dimension) + "D"
				visualization += "\n[color=#ffaaaa]" + dimension_text + "[/color]\n"
				
				for d in range(4, dimension + 1):
					visualization += "  Dimension " + str(d) + ": " + _get_dimension_property(d) + "\n"
			
			// If chunks exist, list them with ASCII connection
			if stream_data.has("chunks") and stream_data.chunks.size() > 0:
				visualization += "\n[color=#aaffaa]Connected Chunks:[/color]\n"
				visualization += "    |\n"
				for i in range(stream_data.chunks.size()):
					if i < stream_data.chunks.size() - 1:
						visualization += "    ├─── " + stream_data.chunks[i] + "\n"
					else:
						visualization += "    └─── " + stream_data.chunks[i] + "\n"
	
	return visualization

func _generate_chunk_visualization(chunk_id: String, dimension: int) -> String:
	var visualization = ""
	var chunk_data = null
	
	// Get chunk data
	if data_splitter_controller.has_method("get_data_chunks"):
		var chunks = data_splitter_controller.get_data_chunks()
		if chunks.has(chunk_id):
			chunk_data = chunks[chunk_id]
	elif data_splitter_controller.has("data_chunks"):
		if data_splitter_controller.data_chunks.has(chunk_id):
			chunk_data = data_splitter_controller.data_chunks[chunk_id]
	
	if not chunk_data:
		return "Chunk data not found"
	
	// Generate visualization based on dimension
	match dimension:
		1:
			// 1D visualization - simple representation
			visualization += "[color=#ffaaaa][" + chunk_id + ":" + str(chunk_data.size) + "][/color]\n"
			
			if chunk_data.has("content") and chunk_data.content.length() > 0:
				var content = chunk_data.content
				if content.length() > 40:
					content = content.substr(0, 37) + "..."
				visualization += "Content: " + content
		
		2:
			// 2D visualization - box
			var width = min(40, chunk_data.size + 10)
			var top_bottom = "+" + "-" * (width - 2) + "+\n"
			
			visualization += "[color=#ffaaaa]" + top_bottom
			
			// Create content lines
			var side = "|"
			
			// Chunk ID line
			var padding = " " * ((width - 2 - chunk_id.length()) / 2)
			visualization += side + padding + chunk_id + padding
			if (width - 2 - chunk_id.length()) % 2 != 0:
				visualization += " "
			visualization += side + "\n"
			
			// Parent stream line
			var stream_text = "Stream: " + chunk_data.parent_stream
			padding = " " * ((width - 2 - stream_text.length()) / 2)
			visualization += side + padding + stream_text + padding
			if (width - 2 - stream_text.length()) % 2 != 0:
				visualization += " "
			visualization += side + "\n"
			
			// Size line
			var size_text = "Size: " + str(chunk_data.size)
			padding = " " * ((width - 2 - size_text.length()) / 2)
			visualization += side + padding + size_text + padding
			if (width - 2 - size_text.length()) % 2 != 0:
				visualization += " "
			visualization += side + "\n"
			
			visualization += top_bottom + "[/color]"
			
			// Show content
			if chunk_data.has("content") and chunk_data.content.length() > 0:
				visualization += "\nContent:\n"
				var content = chunk_data.content
				if content.length() > 100:
					content = content.substr(0, 97) + "..."
				visualization += content + "\n"
		
		3, _:
			// 3D+ visualization - more detailed ASCII art
			var width = min(60, chunk_data.size + 20)
			
			// Top
			visualization += "[color=#ffaaaa]" + "    " + "_" * (width - 8) + "\n"
			visualization += "   /|" + " " * (width - 8) + "|\n"
			
			// Chunk ID line
			var chunk_id_padded = chunk_id
			if chunk_id.length() < width - 12:
				var padding = (width - 12 - chunk_id.length()) / 2
				chunk_id_padded = " " * padding + chunk_id + " " * padding
			else:
				chunk_id_padded = chunk_id.substr(0, width - 15) + "..."
			
			visualization += "  / |  " + chunk_id_padded + "  |\n"
			
			// Chunk properties
			var stream_text = "Stream: " + chunk_data.parent_stream
			var size_text = "Size: " + str(chunk_data.size)
			var created_text = "Created: " + _format_timestamp(chunk_data.created_at)
			
			visualization += " /__|" + "_" * (width - 8) + "|\n"
			visualization += "|   |" + " " * (width - 8) + "|\n"
			visualization += "|   |  " + stream_text + " " * (width - 12 - stream_text.length()) + "|\n"
			visualization += "|   |  " + size_text + " " * (width - 12 - size_text.length()) + "|\n"
			visualization += "|   |  " + created_text + " " * (width - 12 - created_text.length()) + "|\n"
			
			// Content preview
			if chunk_data.has("content") and chunk_data.content.length() > 0:
				var content = chunk_data.content
				if content.length() > width - 15:
					content = content.substr(0, width - 18) + "..."
				visualization += "|   |  " + content + " " * (width - 12 - content.length()) + "|\n"
			else:
				visualization += "|   |" + " " * (width - 8) + "|\n"
			
			visualization += "|___|" + "_" * (width - 8) + "|[/color]\n"
			
			// Show dimensions based on dimension count
			if dimension >= 4:
				var dimension_text = "Dimensions: " + str(dimension) + "D"
				visualization += "\n[color=#ffaaaa]" + dimension_text + "[/color]\n"
				
				for d in range(4, dimension + 1):
					visualization += "  Dimension " + str(d) + ": " + _get_dimension_property(d) + "\n"
			
			// Display properties
			if chunk_data.has("properties"):
				visualization += "\n[color=#aaffaa]Properties:[/color]\n"
				for prop in chunk_data.properties:
					visualization += "  " + prop + ": " + str(chunk_data.properties[prop]) + "\n"
	
	return visualization

func _get_dimension_property(dimension: int) -> String:
	match dimension:
		4:
			return "Time"
		5:
			return "Consciousness"
		6:
			return "Soul"
		7:
			return "Creation"
		8:
			return "Harmony"
		9:
			return "Unity"
		10:
			return "Infinite"
		11:
			return "Transcendence"
		12:
			return "Divine"
		_:
			return "Unknown"

func _format_timestamp(timestamp) -> String:
	var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
	return "%04d-%02d-%02d %02d:%02d:%02d" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute,
		datetime.second
	]

# ----- SIGNAL HANDLERS -----
func _on_data_splitter_initialized():
	if enable_debug_logs:
		print("DataSplitterTerminalBridge: Data Splitter Controller initialized")
	
	if data_splitter_controller:
		current_dimension = data_splitter_controller.current_dimension
		current_reality = data_splitter_controller.current_reality
		
		_send_message_to_all_terminals("Data Splitter initialized - Ready to process data in " + 
			str(current_dimension) + "D " + current_reality + " reality")

func _on_data_stream_created(stream_id, data_type, size):
	if enable_debug_logs:
		print("DataSplitterTerminalBridge: Stream created - " + stream_id)
	
	_send_message_to_all_terminals("[color=#aaaaff]New data stream created: " + stream_id + 
		" (Type: " + data_type + ", Size: " + str(size) + ")[/color]")

func _on_data_chunk_created(chunk_id, content, parent_stream):
	if enable_debug_logs:
		print("DataSplitterTerminalBridge: Chunk created - " + chunk_id)
	
	_send_message_to_all_terminals("[color=#ffaaaa]New data chunk created: " + chunk_id + 
		" in stream " + parent_stream + "[/color]")

func _on_data_split_created(split_id, original_chunk, resulting_chunks):
	if enable_debug_logs:
		print("DataSplitterTerminalBridge: Split created - " + split_id)
	
	_send_message_to_all_terminals("[color=#aaffaa]Data split performed: " + original_chunk + 
		" split into " + str(resulting_chunks.size()) + " chunks[/color]")

func _on_data_merged(merge_id, source_chunks, result_chunk):
	if enable_debug_logs:
		print("DataSplitterTerminalBridge: Merge performed - " + merge_id)
	
	_send_message_to_all_terminals("[color=#ffaaff]Data merge performed: " + 
		str(source_chunks.size()) + " chunks merged into " + result_chunk + "[/color]")

func _on_dimension_changed(new_dimension, old_dimension = 0):
	current_dimension = new_dimension
	
	if enable_debug_logs:
		print("DataSplitterTerminalBridge: Dimension changed to " + str(new_dimension) + "D")
	
	_send_message_to_all_terminals("[color=#88ffff]Dimension changed to " + str(new_dimension) + "D[/color]")
	
	emit_signal("dimension_changed", new_dimension)

func _on_reality_changed(new_reality, old_reality):
	current_reality = new_reality
	
	if enable_debug_logs:
		print("DataSplitterTerminalBridge: Reality changed to " + new_reality)
	
	_send_message_to_all_terminals("[color=#ffff88]Reality changed to " + new_reality + "[/color]")
	
	emit_signal("reality_changed", new_reality)

func _on_terminal_connected(details):
	if enable_debug_logs:
		print("DataSplitterTerminalBridge: Terminal connected")
	
	_send_message_to_all_terminals("[color=#88ff99]Terminal connected to Data Splitter[/color]")

func _on_color_shift_detected(from_color, to_color, temperature):
	if enable_debug_logs:
		print("DataSplitterTerminalBridge: Color shift detected")
	
	_send_message_to_all_terminals("[color=#" + to_color.to_html() + "]Color shift detected - Temperature: " + 
		str(temperature) + "[/color]")

# ----- PUBLIC API -----
func send_message_to_terminal(terminal_id: int, message: String) -> bool:
	if terminal_id < 0 or terminal_id >= 6:
		return false
	
	_send_message_to_terminal(terminal_id, message)
	return true

func _send_message_to_all_terminals(message: String):
	for terminal_id in active_terminal_windows:
		_send_message_to_terminal(terminal_id, message)

func process_direct_command(command: String) -> Dictionary:
	if command.begins_with("/"):
		return _process_command(command, current_terminal_id)
	else:
		# Not a command
		return {
			"success": false,
			"message": "Not a valid command. Commands should start with /"
		}

func create_data_stream(stream_id: String, data_type: String = "binary", size: int = 16) -> Dictionary:
	if not data_splitter_controller:
		return {
			"success": false,
			"message": "Data Splitter Controller not available"
		}
	
	var result = data_splitter_controller.create_data_stream(stream_id, data_type, size)
	return result

func split_data_chunk(chunk_id: String, split_factor: int = 3) -> Dictionary:
	if not data_splitter_controller:
		return {
			"success": false,
			"message": "Data Splitter Controller not available"
		}
	
	var result = data_splitter_controller.split_data_chunk(chunk_id, split_factor)
	return result

func merge_data_chunks(chunk_ids: Array, merge_type: String = "concatenate") -> Dictionary:
	if not data_splitter_controller:
		return {
			"success": false,
			"message": "Data Splitter Controller not available"
		}
	
	var result = data_splitter_controller.merge_data_chunks(chunk_ids, merge_type)
	return result

func get_current_dimension() -> int:
	return current_dimension

func get_current_reality() -> String:
	return current_reality

func set_current_terminal(terminal_id: int) -> bool:
	if terminal_id >= 0 and terminal_id < 6:
		current_terminal_id = terminal_id
		return true
	return false

func is_terminal_bridge_active() -> bool:
	return bridge_active

func start_bridge():
	bridge_active = true
	print("DataSplitterTerminalBridge: Bridge started")

func stop_bridge():
	bridge_active = false
	print("DataSplitterTerminalBridge: Bridge stopped")