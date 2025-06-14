extends Node

# Memory Transfer Integration for 12 Turns System
# Connects the memory transfer system with the 12 turns game system

signal memory_synced(turn_id, stats)
signal turn_memory_transferred(turn_id, target_device, stats)

# System connectors
var memory_transfer_system
var turn_controller
var memory_investment_system

# Configuration
var config = {
	"auto_sync_on_turn_change": true,
	"sync_with_claude": true,
	"save_turn_memories": true,
	"transfer_after_investment": true,
	"ethereal_transfer_for_claude": true
}

# Turn memory tracking
var turn_memories = {}
var current_turn_id = ""
var pending_transfers = []

func _ready():
	# Connect systems
	_connect_systems()
	
	# Initialize
	_initialize()
	
	# Connect signals if available
	if turn_controller:
		turn_controller.turn_changed.connect(_on_turn_changed)
		turn_controller.turn_completed.connect(_on_turn_completed)
	
	if memory_investment_system:
		memory_investment_system.investment_created.connect(_on_investment_created)
		memory_investment_system.investment_matured.connect(_on_investment_matured)
	
	if memory_transfer_system:
		memory_transfer_system.transfer_completed.connect(_on_transfer_completed)
		memory_transfer_system.device_memory_updated.connect(_on_device_memory_updated)

func _connect_systems():
	# Find memory transfer system
	if has_node("/root/MemoryTransferSystem") or get_node_or_null("/root/MemoryTransferSystem"):
		memory_transfer_system = get_node("/root/MemoryTransferSystem")
	else:
		# Create if it doesn't exist
		memory_transfer_system = load("res://memory_transfer_system.gd").new()
		memory_transfer_system.name = "MemoryTransferSystem"
		add_child(memory_transfer_system)
	
	# Find turn controller
	var potential_controllers = get_tree().get_nodes_in_group("turn_controllers")
	if potential_controllers.size() > 0:
		turn_controller = potential_controllers[0]
	
	# Find memory investment system
	var potential_investment_systems = get_tree().get_nodes_in_group("memory_investment")
	if potential_investment_systems.size() > 0:
		memory_investment_system = potential_investment_systems[0]

func _initialize():
	# Ensure directories exist
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("turn_memories"):
		dir.make_dir("turn_memories")
	
	# Load turn memories
	_load_turn_memories()
	
	# Get current turn
	if turn_controller:
		current_turn_id = turn_controller.current_turn_id
		print("Current turn: " + current_turn_id)

func _load_turn_memories():
	var dir = DirAccess.open("user://turn_memories/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				var turn_id = file_name.trim_suffix(".json")
				var file = FileAccess.open("user://turn_memories/" + file_name, FileAccess.READ)
				var content = file.get_as_text()
				var test_json_conv = JSON.new()
				var error = test_json_conv.parse(content)
				
				if error == OK:
					var turn_data = test_json_conv.get_data()
					turn_memories[turn_id] = turn_data
					print("Loaded turn memory: " + turn_id)
			
			file_name = dir.get_next()

func save_turn_memory(turn_id, memory_data = null):
	if not config.save_turn_memories:
		return false
	
	if memory_data == null:
		# If no data provided, gather current memory data
		memory_data = _gather_turn_memory_data(turn_id)
	
	# Save to turn memories
	turn_memories[turn_id] = memory_data
	
	# Save to file
	var file = FileAccess.open("user://turn_memories/" + turn_id + ".json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(memory_data, "  "))
		print("Saved turn memory: " + turn_id)
		return true
	
	return false

func _gather_turn_memory_data(turn_id):
	var memory_data = {
		"turn_id": turn_id,
		"timestamp": Time.get_unix_time_from_system(),
		"investments": [],
		"fragments": [],
		"stats": {
			"investment_count": 0,
			"fragment_count": 0,
			"total_value": 0.0,
			"ethereal_fragments": 0,
			"categories": {}
		}
	}
	
	# If memory investment system is available, get investments
	if memory_investment_system:
		var investments = memory_investment_system.get_investments_for_turn(turn_id)
		memory_data.investments = investments
		memory_data.stats.investment_count = investments.size()
		
		var total_value = 0.0
		var categories = {}
		
		for investment in investments:
			total_value += investment.value
			
			if not categories.has(investment.category):
				categories[investment.category] = {
					"count": 0,
					"value": 0.0
				}
			
			categories[investment.category].count += 1
			categories[investment.category].value += investment.value
		
		memory_data.stats.total_value = total_value
		memory_data.stats.categories = categories
	
	# If drive memory connector is available through the transfer system
	# gather fragments related to this turn
	if memory_transfer_system and memory_transfer_system.drive_memory_connector:
		var drive_memory = memory_transfer_system.drive_memory_connector
		var turn_fragments = []
		var ethereal_count = 0
		
		for fragment in drive_memory.memory_fragments:
			# Check if fragment is related to this turn
			if fragment.has("turn_id") and fragment.turn_id == turn_id:
				turn_fragments.append(fragment)
				
				if fragment.get("is_ethereal", false):
					ethereal_count += 1
		
		memory_data.fragments = turn_fragments
		memory_data.stats.fragment_count = turn_fragments.size()
		memory_data.stats.ethereal_fragments = ethereal_count
	
	return memory_data

func transfer_turn_memory(turn_id, target_device_id, options = null):
	if not memory_transfer_system:
		print("ERROR: Memory transfer system not available")
		return null
	
	# Default options
	if options == null:
		options = {
			"transfer_type": memory_transfer_system.TransferType.DIFFERENTIAL,
			"priority": memory_transfer_system.Priority.NORMAL,
			"include_ethereal": true,
			"metadata": {
				"turn_id": turn_id
			}
		}
	else:
		# Ensure turn_id is in metadata
		if not options.has("metadata"):
			options.metadata = {}
		
		options.metadata.turn_id = turn_id
	
	# Special handling for Claude
	if target_device_id.begins_with("claude") and config.ethereal_transfer_for_claude:
		options.transfer_type = memory_transfer_system.TransferType.ETHEREAL
	
	# Start transfer
	var transfer_id = memory_transfer_system.start_memory_transfer(target_device_id, options)
	
	if transfer_id:
		print("Started turn memory transfer: " + turn_id + " -> " + target_device_id)
	else:
		print("Failed to start turn memory transfer")
	
	return transfer_id

func sync_all_turn_memories():
	print("Syncing all turn memories...")
	
	# Get connected devices
	var connected_devices = []
	if memory_transfer_system and memory_transfer_system.cross_device_connector:
		connected_devices = memory_transfer_system.cross_device_connector.get_all_connected_devices()
	
	if connected_devices.size() == 0:
		print("No connected devices to sync with")
		return false
	
	# For each turn memory, transfer to all connected devices
	for turn_id in turn_memories:
		for device in connected_devices:
			# Skip if it's the current device
			if device.id == memory_transfer_system.device_memory_stats.device_id:
				continue
			
			# Check if we should sync with Claude devices
			if device.type == "claude" and not config.sync_with_claude:
				continue
			
			# Queue transfer
			pending_transfers.append({
				"turn_id": turn_id,
				"target_device_id": device.id,
				"options": null
			})
	
	# Start first pending transfer
	_process_pending_transfers()
	
	return true

func _process_pending_transfers():
	if pending_transfers.size() == 0:
		return
	
	# Check max concurrent transfers
	var active_count = 0
	if memory_transfer_system:
		active_count = memory_transfer_system.active_transfers.size()
	
	var max_transfers = memory_transfer_system.config.max_concurrent_transfers
	
	# Start transfers up to the maximum allowed
	while active_count < max_transfers and pending_transfers.size() > 0:
		var transfer_info = pending_transfers.pop_front()
		
		transfer_turn_memory(
			transfer_info.turn_id,
			transfer_info.target_device_id,
			transfer_info.options
		)
		
		active_count += 1

# Signal handlers

func _on_turn_changed(previous_turn_id, new_turn_id):
	print("Turn changed: " + previous_turn_id + " -> " + new_turn_id)
	
	# Save memory for the previous turn
	if not previous_turn_id.empty():
		save_turn_memory(previous_turn_id)
	
	# Update current turn
	current_turn_id = new_turn_id
	
	# Auto-sync if enabled
	if config.auto_sync_on_turn_change:
		sync_all_turn_memories()

func _on_turn_completed(turn_id):
	print("Turn completed: " + turn_id)
	
	# Save final memory for the completed turn
	save_turn_memory(turn_id)

func _on_investment_created(investment_data):
	print("New investment created: " + investment_data.word)
	
	# If configured to transfer after investment and we have a current turn
	if config.transfer_after_investment and not current_turn_id.empty():
		# Get connected devices
		var connected_devices = []
		if memory_transfer_system and memory_transfer_system.cross_device_connector:
			connected_devices = memory_transfer_system.cross_device_connector.get_all_connected_devices()
		
		# Add single investment transfer to all devices
		for device in connected_devices:
			# Skip if it's the current device
			if device.id == memory_transfer_system.device_memory_stats.device_id:
				continue
			
			# Check if we should sync with Claude devices
			if device.type == "claude" and not config.sync_with_claude:
				continue
			
			# Special options for single investment transfer
			var options = {
				"transfer_type": memory_transfer_system.TransferType.STREAMING,
				"priority": memory_transfer_system.Priority.HIGH,
				"include_ethereal": true,
				"metadata": {
					"turn_id": current_turn_id,
					"single_investment": true,
					"investment_word": investment_data.word
				}
			}
			
			# Queue transfer
			pending_transfers.append({
				"turn_id": current_turn_id,
				"target_device_id": device.id,
				"options": options
			})
		
		# Process pending transfers
		_process_pending_transfers()

func _on_investment_matured(investment_data):
	print("Investment matured: " + investment_data.word)
	
	# Similar logic to _on_investment_created but for matured investments
	# Could implement special handling for matured investments

func _on_transfer_completed(transfer_id, success, stats):
	# Check if this was a turn memory transfer
	if memory_transfer_system and memory_transfer_system.transfer_history.has(transfer_id):
		var transfer = memory_transfer_system.transfer_history[transfer_id]
		
		if transfer.options.has("metadata") and transfer.options.metadata.has("turn_id"):
			var turn_id = transfer.options.metadata.turn_id
			
			print("Turn memory transfer completed: " + turn_id + " -> " + transfer.target_device_id)
			emit_signal("turn_memory_transferred", turn_id, transfer.target_device_id, stats)
	
	# Process next pending transfer
	_process_pending_transfers()

func _on_device_memory_updated(device_id, stats):
	# Memory stats were updated, check if we need to save the current turn
	if not current_turn_id.empty() and config.save_turn_memories:
		# Just update without saving to file to avoid excessive writes
		turn_memories[current_turn_id] = _gather_turn_memory_data(current_turn_id)
		emit_signal("memory_synced", current_turn_id, stats)