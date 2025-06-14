extends Node

# Terminal Synchronization Protocol
# Enables communication and data flow between the 6 divine terminals
# Terminal 1: Divine Word Genesis

class_name TerminalSyncProtocol

# ----- TERMINAL DEFINITIONS -----
enum TerminalType {
	GENESIS,       # Terminal 1: Divine Word Genesis - Word creation and processing
	OBSERVER,      # Terminal 2: Dimensional Observer - Monitors cross-dimensional effects
	ARCHIVIST,     # Terminal 3: Memory Archivist - Manages the three-tier memory system
	JUDGMENT,      # Terminal 4: Salem Judgment Hall - Handles word crime system
	ROYAL_COURT,   # Terminal 5: Royal Court Communicator - Facilitates royal communication 
	DREAM_WEAVER   # Terminal 6: Dream Weaver - Specializes in dream processing
}

# ----- TERMINAL PROPERTIES -----
var terminal_properties = {
	TerminalType.GENESIS: {
		"name": "Divine Word Genesis",
		"description": "Primary control terminal for word creation and processing",
		"primary_dimension": 1,
		"sync_priority": 1,
		"sacred_number": 1, # First principle
		"capabilities": ["word_creation", "dimension_control", "turn_advancement"]
	},
	TerminalType.OBSERVER: {
		"name": "Dimensional Observer",
		"description": "Monitors cross-dimensional word effects",
		"primary_dimension": 5, # Probability dimension
		"sync_priority": 3,
		"sacred_number": 3, # Trinity
		"capabilities": ["dimension_scanning", "effect_monitoring", "pattern_recognition"]
	},
	TerminalType.ARCHIVIST: {
		"name": "Memory Archivist",
		"description": "Manages the three-tier memory system",
		"primary_dimension": 4, # Temporal dimension
		"sync_priority": 2,
		"sacred_number": 7, # Divine completeness
		"capabilities": ["memory_storage", "memory_retrieval", "history_tracking"]
	},
	TerminalType.JUDGMENT: {
		"name": "Salem Judgment Hall",
		"description": "Handles the Town of Salem word crime system",
		"primary_dimension": 9, # Judgment dimension
		"sync_priority": 4,
		"sacred_number": 9, # Divine judgment
		"capabilities": ["crime_detection", "trial_processing", "sentencing"]
	},
	TerminalType.ROYAL_COURT: {
		"name": "Royal Court Communicator",
		"description": "Facilitates communication with the Queen",
		"primary_dimension": 12, # Divine dimension
		"sync_priority": 5,
		"sacred_number": 12, # Divine governance
		"capabilities": ["royal_decrees", "blessing_requests", "favor_tracking"]
	},
	TerminalType.DREAM_WEAVER: {
		"name": "Dream Weaver",
		"description": "Specializes in dream processing",
		"primary_dimension": 7, # Dream dimension
		"sync_priority": 6,
		"sacred_number": 7, # Mystical revelation
		"capabilities": ["dream_creation", "dream_interpretation", "subconscious_access"]
	}
}

# ----- COMMUNICATION CHANNELS -----
var channels = {
	"words": [], # Word transmission
	"dimensions": [], # Dimension state
	"turns": [], # Turn progression
	"memory": [], # Memory access
	"judgment": [], # Crime and judgment
	"royal": [], # Royal communication
	"dreams": [], # Dream messages
	"scheming": [] # Interdimensional schemes
}

# ----- STATE VARIABLES -----
var active_terminals = {}
var current_terminal = TerminalType.GENESIS
var sync_status = {}
var channel_buffers = {}
var quantum_entanglement_active = false
var sync_interval = 9.0 # Sacred 9-second interval
var sync_timer = 0.0
var multi_core_enabled = true

# ----- SYSTEM REFERENCES -----
var turn_system = null
var divine_word_processor = null
var word_comment_system = null
var word_salem_controller = null
var word_dream_storage = null
var royal_blessing_system = null
var interdimensional_scheming_system = null

# ----- SIGNALS -----
signal terminal_registered(terminal_type, terminal_id)
signal terminal_unregistered(terminal_type, terminal_id)
signal message_transmitted(channel, message, source_terminal, target_terminal)
signal quantum_entanglement_changed(active)
signal sync_completed(successful_terminals)
signal terminal_violation(terminal_type, violation_type, details)

func _ready():
	connect_systems()
	initialize_channels()
	register_current_terminal(TerminalType.GENESIS)
	start_sync_timer()

func _process(delta):
	if quantum_entanglement_active:
		sync_timer += delta
		
		if sync_timer >= sync_interval:
			sync_timer = 0
			sync_all_terminals()

func connect_systems():
	# Connect to the turn system
	turn_system = get_node_or_null("/root/TurnSystem")
	if turn_system:
		turn_system.connect("turn_completed", self, "_on_turn_completed")
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")
	
	# Connect to the divine word processor
	divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
	if divine_word_processor:
		divine_word_processor.connect("word_processed", self, "_on_word_processed")
	
	# Connect to other systems
	word_comment_system = get_node_or_null("/root/WordCommentSystem")
	word_salem_controller = get_node_or_null("/root/WordSalemGameController")
	word_dream_storage = get_node_or_null("/root/WordDreamStorage")
	royal_blessing_system = get_node_or_null("/root/RoyalBlessingSystem")
	interdimensional_scheming_system = get_node_or_null("/root/InterdimensionalSchemingSystem")

func initialize_channels():
	# Initialize all communication channels with empty buffers
	for channel in channels.keys():
		channel_buffers[channel] = []

# ----- TERMINAL REGISTRATION -----

func register_current_terminal(terminal_type):
	# Generate a unique terminal ID
	var terminal_id = "terminal_" + str(terminal_type) + "_" + str(OS.get_unix_time())
	
	# Register this terminal
	active_terminals[terminal_id] = {
		"type": terminal_type,
		"name": terminal_properties[terminal_type].name,
		"registered_at": OS.get_unix_time(),
		"last_sync": OS.get_unix_time(),
		"status": "active",
		"dimension": turn_system.current_dimension if turn_system else terminal_properties[terminal_type].primary_dimension,
		"sync_count": 0
	}
	
	# Set as current terminal
	current_terminal = terminal_type
	
	# Update sync status
	sync_status[terminal_id] = {
		"channels_synced": {},
		"last_successful_sync": OS.get_unix_time(),
		"sync_errors": 0
	}
	
	for channel in channels.keys():
		sync_status[terminal_id].channels_synced[channel] = OS.get_unix_time()
	
	# Emit signal
	emit_signal("terminal_registered", terminal_type, terminal_id)
	
	# Add comment
	if word_comment_system:
		word_comment_system.add_comment("terminal_" + str(terminal_type),
			"TERMINAL REGISTERED: " + terminal_properties[terminal_type].name + " is now active",
			word_comment_system.CommentType.OBSERVATION)
	
	return terminal_id

func unregister_terminal(terminal_id):
	if not active_terminals.has(terminal_id):
		return false
	
	# Get terminal info
	var terminal_info = active_terminals[terminal_id]
	
	# Mark as inactive
	terminal_info.status = "inactive"
	terminal_info.unregistered_at = OS.get_unix_time()
	
	# Remove from sync status
	if sync_status.has(terminal_id):
		sync_status.erase(terminal_id)
	
	# Emit signal
	emit_signal("terminal_unregistered", terminal_info.type, terminal_id)
	
	# Add comment
	if word_comment_system:
		word_comment_system.add_comment("terminal_" + str(terminal_info.type),
			"TERMINAL UNREGISTERED: " + terminal_properties[terminal_info.type].name + " is now inactive",
			word_comment_system.CommentType.OBSERVATION)
	
	return true

# ----- TERMINAL SYNCHRONIZATION -----

func start_sync_timer():
	# Start the synchronized timer
	sync_timer = 0
	quantum_entanglement_active = true
	
	# Emit signal
	emit_signal("quantum_entanglement_changed", true)
	
	# Add comment
	if word_comment_system:
		word_comment_system.add_comment("quantum_sync",
			"QUANTUM ENTANGLEMENT: Terminal synchronization active on 9-second intervals",
			word_comment_system.CommentType.DIVINE)
	
	return true

func stop_sync_timer():
	# Stop the synchronized timer
	quantum_entanglement_active = false
	
	# Emit signal
	emit_signal("quantum_entanglement_changed", false)
	
	# Add comment
	if word_comment_system:
		word_comment_system.add_comment("quantum_sync",
			"QUANTUM ENTANGLEMENT: Terminal synchronization deactivated",
			word_comment_system.CommentType.OBSERVATION)
	
	return true

func sync_all_terminals():
	var successful_terminals = []
	
	# Synchronize all active terminals
	for terminal_id in active_terminals:
		var terminal_info = active_terminals[terminal_id]
		
		if terminal_info.status == "active":
			# Attempt to sync this terminal
			if sync_terminal(terminal_id):
				successful_terminals.append(terminal_id)
	
	# Emit signal
	emit_signal("sync_completed", successful_terminals)
	
	# Special handling for complete synchronization
	if successful_terminals.size() == active_terminals.size() and successful_terminals.size() >= 3:
		on_complete_synchronization()
	
	return successful_terminals

func sync_terminal(terminal_id):
	if not active_terminals.has(terminal_id):
		return false
	
	var terminal_info = active_terminals[terminal_id]
	
	# Check each channel
	var all_channels_synced = true
	
	for channel in channels.keys():
		if not sync_channel(terminal_id, channel):
			all_channels_synced = false
	
	// Update sync status
	terminal_info.last_sync = OS.get_unix_time()
	terminal_info.sync_count += 1
	
	if all_channels_synced:
		sync_status[terminal_id].last_successful_sync = OS.get_unix_time()
		sync_status[terminal_id].sync_errors = 0
	else:
		sync_status[terminal_id].sync_errors += 1
	
	return all_channels_synced

func sync_channel(terminal_id, channel):
	if not active_terminals.has(terminal_id) or not channel_buffers.has(channel):
		return false
	
	var terminal_info = active_terminals[terminal_id]
	
	// Process any pending messages in this channel
	var success = true
	
	for message in channel_buffers[channel]:
		if not message.processed_by.has(terminal_id):
			// Process this message
			if process_message(terminal_id, channel, message):
				message.processed_by.append(terminal_id)
			else:
				success = false
	
	// Update sync status
	if success:
		sync_status[terminal_id].channels_synced[channel] = OS.get_unix_time()
	
	return success

func process_message(terminal_id, channel, message):
	var terminal_info = active_terminals[terminal_id]
	
	// Check if this terminal has capability to process this channel
	var terminal_type = terminal_info.type
	
	// Enhanced processing for specialized terminals
	var success = true
	
	match channel:
		"words":
			// Word processing is enhanced in Terminal 1
			if terminal_type == TerminalType.GENESIS:
				// Apply word processor effects
				if divine_word_processor and message.data.has("word"):
					divine_word_processor.process_word(message.data.word, "Terminal_" + str(terminal_type))
			
		"dimensions":
			// Dimension monitoring is enhanced in Terminal 2
			if terminal_type == TerminalType.OBSERVER:
				// Apply dimensional observation effects
				if message.data.has("dimension_change"):
					// Record detailed dimension transition data
					if word_comment_system:
						word_comment_system.add_comment("dimension_observation",
							"DIMENSIONAL SHIFT OBSERVED: " + str(message.data.from_dimension) + "D → " + str(message.data.to_dimension) + "D",
							word_comment_system.CommentType.OBSERVATION)
			
		"memory":
			// Memory processing is enhanced in Terminal 3
			if terminal_type == TerminalType.ARCHIVIST:
				// Apply archivist effects
				if word_dream_storage and message.data.has("memory_operation"):
					// Handle memory operations
					var tier = message.data.tier if message.data.has("tier") else 1
					
					if message.data.memory_operation == "store" and message.data.has("content"):
						word_dream_storage.save_comment({
							"word": "memory_sync",
							"text": message.data.content,
							"type": message.data.type if message.data.has("type") else 0,
							"terminal_source": message.source_terminal,
							"timestamp": OS.get_unix_time()
						}, tier)
			
		"judgment":
			// Judgment processing is enhanced in Terminal 4
			if terminal_type == TerminalType.JUDGMENT:
				// Apply judgment hall effects
				if word_salem_controller and message.data.has("judgment_action"):
					// Handle judgment operations
					if message.data.judgment_action == "accusation" and message.data.has("accused") and message.data.has("crime"):
						// Process accusation
						word_salem_controller.record_accusation(message.data.accused, message.data.crime)
			
		"royal":
			// Royal court processing is enhanced in Terminal 5
			if terminal_type == TerminalType.ROYAL_COURT:
				// Apply royal court effects
				if royal_blessing_system and message.data.has("royal_action"):
					// Handle royal operations
					if message.data.royal_action == "blessing_request" and message.data.has("word") and message.data.has("blessing_type"):
						// Process blessing request
						royal_blessing_system.grant_blessing(
							message.data.player if message.data.has("player") else "System",
							message.data.word,
							message.data.blessing_type,
							"Terminal_" + str(message.source_terminal)
						)
			
		"dreams":
			// Dream processing is enhanced in Terminal 6
			if terminal_type == TerminalType.DREAM_WEAVER:
				// Apply dream weaver effects
				if word_comment_system and message.data.has("dream_text"):
					// Record dream
					word_comment_system.record_dream_fragment(
						message.data.word if message.data.has("word") else "dream_sync",
						message.data.dream_text
					)
			
		"scheming":
			// Scheming is processed by all terminals
			if interdimensional_scheming_system and message.data.has("scheme_action"):
				// Handle scheme operations
				if message.data.scheme_action == "detection_attempt" and message.data.has("target"):
					// Process scheme detection
					interdimensional_scheming_system.attempt_scheme_detection(
						"Terminal_" + str(terminal_type),
						message.data.target,
						message.data.word if message.data.has("word") else ""
					)
	
	return success

func on_complete_synchronization():
	// Special effects when all terminals are in perfect sync
	
	// Check if current dimension is 9 (judgment)
	var current_dimension = turn_system.current_dimension if turn_system else 1
	
	if current_dimension == 9:
		// In judgment dimension, synchronization reveals all schemes
		if interdimensional_scheming_system:
			// Create a divine revelation
			if word_comment_system:
				word_comment_system.add_comment("divine_revelation",
					"DIVINE REVELATION: Perfect terminal synchronization in Dimension 9 reveals all schemes",
					word_comment_system.CommentType.DIVINE)
			
			// Reveal all schemes to everyone
			var all_schemes = interdimensional_scheming_system.get_active_schemes()
			var terminals = []
			
			for terminal_id in active_terminals:
				terminals.append("Terminal_" + str(active_terminals[terminal_id].type))
			
			for scheme_id in all_schemes:
				for terminal in terminals:
					// Add to discovered schemes
					if not all_schemes[scheme_id].discovered_by.has(terminal):
						all_schemes[scheme_id].discovered_by.append(terminal)
						
						// Emit scheme discovered signal
						interdimensional_scheming_system.emit_signal("scheme_discovered", scheme_id, terminal)
	
	// Check if we have at least 6 terminals in sync (all terminals)
	if active_terminals.size() >= 6:
		// Grant a royal blessing to a random word
		if royal_blessing_system and divine_word_processor:
			// Get recent words
			var recent_words = divine_word_processor.get_recent_words(9)
			
			if recent_words.size() > 0:
				// Select a word
				var chosen_word = recent_words[randi() % recent_words.size()]
				
				// Grant blessing
				royal_blessing_system.grant_blessing(
					"Synchronized_Terminals",
					chosen_word,
					randi() % 5, // Random blessing type
					"Perfect_Sync"
				)
				
				// Create divine comment
				if word_comment_system:
					word_comment_system.add_comment("perfect_sync",
						"PERFECT SYNCHRONIZATION: All 6 terminals in harmony have granted a royal blessing to '" + chosen_word + "'",
						word_comment_system.CommentType.DIVINE)

# ----- MESSAGE TRANSMISSION -----

func transmit_message(channel, message_data, target_terminal=null):
	if not channels.has(channel):
		return false
	
	// Create message object
	var message = {
		"id": "msg_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000),
		"channel": channel,
		"data": message_data,
		"source_terminal": current_terminal,
		"target_terminal": target_terminal,
		"timestamp": OS.get_unix_time(),
		"processed_by": [],
		"current_dimension": turn_system.current_dimension if turn_system else 1
	}
	
	// Add to channel buffer
	channel_buffers[channel].append(message)
	
	// Apply 9-second delay if quantum entanglement is active
	if quantum_entanglement_active:
		// Message will process on next sync cycle
		pass
	else:
		// Process immediately for current terminal
		var terminal_id = "self"
		
		for id in active_terminals:
			if active_terminals[id].type == current_terminal:
				terminal_id = id
				break
		
		if terminal_id != "self":
			process_message(terminal_id, channel, message)
			message.processed_by.append(terminal_id)
	
	// Emit signal
	emit_signal("message_transmitted", channel, message, current_terminal, target_terminal)
	
	return message.id

func word_relay(word, source_player="System", target_terminal=null):
	// Transmit a word to another terminal
	return transmit_message("words", {
		"word": word,
		"player": source_player,
		"relay_timestamp": OS.get_unix_time()
	}, target_terminal)

func memory_operation(operation, content, tier=1, type=0, target_terminal=null):
	// Transmit a memory operation
	return transmit_message("memory", {
		"memory_operation": operation,
		"content": content,
		"tier": tier,
		"type": type,
		"operation_timestamp": OS.get_unix_time()
	}, target_terminal)

func judgment_action(action, accused=null, crime=null, evidence=null, target_terminal=null):
	// Transmit a judgment action
	return transmit_message("judgment", {
		"judgment_action": action,
		"accused": accused,
		"crime": crime,
		"evidence": evidence,
		"judgment_timestamp": OS.get_unix_time()
	}, target_terminal)

func royal_request(action, word=null, blessing_type=null, player=null, target_terminal=null):
	// Transmit a royal court request
	return transmit_message("royal", {
		"royal_action": action,
		"word": word,
		"blessing_type": blessing_type,
		"player": player,
		"request_timestamp": OS.get_unix_time()
	}, target_terminal)

func dream_transmission(dream_text, word=null, target_terminal=null):
	// Transmit a dream
	return transmit_message("dreams", {
		"dream_text": dream_text,
		"word": word,
		"dream_timestamp": OS.get_unix_time()
	}, target_terminal)

func scheme_operation(action, target=null, word=null, scheme_id=null, target_terminal=null):
	// Transmit a scheme operation
	return transmit_message("scheming", {
		"scheme_action": action,
		"target": target,
		"word": word,
		"scheme_id": scheme_id,
		"scheme_timestamp": OS.get_unix_time()
	}, target_terminal)

# ----- TERMINAL VIOLATIONS -----

func check_terminal_violations(terminal_type, action, data=null):
	// Check if a terminal is attempting to perform an action outside its capabilities
	var violations = []
	
	match action:
		"word_creation":
			if terminal_type != TerminalType.GENESIS and terminal_type != TerminalType.DREAM_WEAVER:
				violations.append("Terminal " + str(terminal_type) + " attempted unauthorized word creation")
		
		"dimension_control":
			if terminal_type != TerminalType.GENESIS and terminal_type != TerminalType.OBSERVER:
				violations.append("Terminal " + str(terminal_type) + " attempted unauthorized dimension control")
		
		"memory_tier_3":
			if terminal_type != TerminalType.ARCHIVIST and terminal_type != TerminalType.ROYAL_COURT:
				violations.append("Terminal " + str(terminal_type) + " attempted unauthorized Tier 3 memory access")
		
		"judgment_sentencing":
			if terminal_type != TerminalType.JUDGMENT:
				violations.append("Terminal " + str(terminal_type) + " attempted unauthorized sentencing")
		
		"royal_decree":
			if terminal_type != TerminalType.ROYAL_COURT:
				violations.append("Terminal " + str(terminal_type) + " attempted unauthorized royal decree")
		
		"dream_alteration":
			if terminal_type != TerminalType.DREAM_WEAVER:
				violations.append("Terminal " + str(terminal_type) + " attempted unauthorized dream alteration")
	
	// Report violations
	for violation in violations:
		emit_signal("terminal_violation", terminal_type, action, violation)
		
		if word_comment_system:
			word_comment_system.add_comment("violation_" + str(terminal_type),
				"TERMINAL VIOLATION: " + violation,
				word_comment_system.CommentType.WARNING)
	
	return violations

# ----- DIMENSIONAL TUNNELING -----

func create_dimensional_tunnel(source_dimension, target_dimension, duration=3):
	// Create a tunnel between dimensions for direct communication
	if not turn_system:
		return false
	
	var current_dimension = turn_system.current_dimension
	
	// Check if source dimension is current dimension
	if current_dimension != source_dimension:
		if word_comment_system:
			word_comment_system.add_comment("tunnel_error",
				"TUNNEL ERROR: Cannot create tunnel from dimension " + str(source_dimension) + 
				" while in dimension " + str(current_dimension),
				word_comment_system.CommentType.WARNING)
		return false
	
	// Create tunnel data
	var tunnel_id = "tunnel_" + str(source_dimension) + "_" + str(target_dimension) + "_" + str(OS.get_unix_time())
	
	var tunnel_data = {
		"id": tunnel_id,
		"source_dimension": source_dimension,
		"target_dimension": target_dimension,
		"created_at": OS.get_unix_time(),
		"expires_at": OS.get_unix_time() + (duration * 9), // Duration in terms of 9-second intervals
		"created_by": current_terminal,
		"messages_sent": 0,
		"active": true
	}
	
	// Store tunnel data
	if word_dream_storage:
		word_dream_storage.save_dimension_record(source_dimension, {
			"tunnel": tunnel_data
		})
	
	// Create comment
	if word_comment_system:
		word_comment_system.add_comment("tunnel_" + tunnel_id,
			"DIMENSIONAL TUNNEL CREATED: From Dimension " + str(source_dimension) + 
			" to Dimension " + str(target_dimension) + " (Duration: " + str(duration) + " cycles)",
			word_comment_system.CommentType.DIVINE)
	
	return tunnel_id

func send_through_tunnel(tunnel_id, message_data):
	// Send data through an existing dimensional tunnel
	if not word_dream_storage:
		return false
	
	// Check if tunnel exists and is active
	var tunnel_records = []
	
	for dim in range(1, 13):
		var records = word_dream_storage.load_dimension_records(dim)
		
		for record in records:
			if record.has("tunnel") and record.tunnel.id == tunnel_id:
				tunnel_records.append(record)
	
	if tunnel_records.size() == 0:
		if word_comment_system:
			word_comment_system.add_comment("tunnel_error",
				"TUNNEL ERROR: Tunnel " + tunnel_id + " not found",
				word_comment_system.CommentType.WARNING)
		return false
	
	var tunnel = tunnel_records[0].tunnel
	
	// Check if tunnel has expired
	if OS.get_unix_time() > tunnel.expires_at:
		if word_comment_system:
			word_comment_system.add_comment("tunnel_error",
				"TUNNEL ERROR: Tunnel " + tunnel_id + " has expired",
				word_comment_system.CommentType.WARNING)
		return false
	
	// Send message through tunnel
	var target_dimension = tunnel.target_dimension
	
	// Find terminal in target dimension
	var target_terminal = null
	
	for terminal_id in active_terminals:
		if active_terminals[terminal_id].dimension == target_dimension:
			target_terminal = active_terminals[terminal_id].type
			break
	
	if target_terminal == null:
		if word_comment_system:
			word_comment_system.add_comment("tunnel_error",
				"TUNNEL ERROR: No terminal active in target dimension " + str(target_dimension),
				word_comment_system.CommentType.WARNING)
		return false
	
	// Create tunnel message
	var tunnel_message = {
		"tunnel_id": tunnel_id,
		"source_dimension": tunnel.source_dimension,
		"target_dimension": tunnel.target_dimension,
		"data": message_data,
		"timestamp": OS.get_unix_time()
	}
	
	// Transmit to target terminal - bypassing the 9-second delay
	var channel = "words" // Default channel
	
	if message_data.has("channel"):
		channel = message_data.channel
	
	var message_id = transmit_message(channel, message_data, target_terminal)
	
	// Update tunnel usage
	tunnel.messages_sent += 1
	
	// Create comment
	if word_comment_system:
		word_comment_system.add_comment("tunnel_message_" + tunnel_id,
			"TUNNEL MESSAGE SENT: Through tunnel " + tunnel_id + " to Dimension " + str(target_dimension),
			word_comment_system.CommentType.OBSERVATION)
	
	return message_id

# ----- MULTI-CORE OPERATIONS -----

func enable_multi_core():
	multi_core_enabled = true
	
	if word_comment_system:
		word_comment_system.add_comment("multi_core",
			"MULTI-CORE PROCESSING: Enabled for terminal synchronization",
			word_comment_system.CommentType.OBSERVATION)
	
	return true

func disable_multi_core():
	multi_core_enabled = false
	
	if word_comment_system:
		word_comment_system.add_comment("multi_core",
			"MULTI-CORE PROCESSING: Disabled for terminal synchronization",
			word_comment_system.CommentType.OBSERVATION)
	
	return true

func execute_parallel_operations(operations):
	if not multi_core_enabled:
		// Execute operations serially
		var results = []
		
		for operation in operations:
			var result = execute_operation(operation)
			results.append(result)
		
		return results
	else:
		// Simulate parallel execution
		var results = []
		
		// Group operations by terminal
		var terminal_operations = {}
		
		for operation in operations:
			var terminal = operation.terminal if operation.has("terminal") else current_terminal
			
			if not terminal_operations.has(terminal):
				terminal_operations[terminal] = []
			
			terminal_operations[terminal].append(operation)
		
		// Execute operations for each terminal
		for terminal in terminal_operations:
			for operation in terminal_operations[terminal]:
				var result = execute_operation(operation)
				results.append(result)
		
		return results

func execute_operation(operation):
	if not operation.has("type"):
		return {"success": false, "error": "No operation type specified"}
	
	var result = {"success": false}
	
	match operation.type:
		"word_relay":
			if operation.has("word") and operation.has("target_terminal"):
				result = {
					"success": true,
					"message_id": word_relay(
						operation.word,
						operation.player if operation.has("player") else "System",
						operation.target_terminal
					)
				}
		
		"memory_operation":
			if operation.has("operation") and operation.has("content"):
				result = {
					"success": true,
					"message_id": memory_operation(
						operation.operation,
						operation.content,
						operation.tier if operation.has("tier") else 1,
						operation.type if operation.has("type") else 0,
						operation.target_terminal if operation.has("target_terminal") else null
					)
				}
		
		"judgment_action":
			if operation.has("action"):
				result = {
					"success": true,
					"message_id": judgment_action(
						operation.action,
						operation.accused if operation.has("accused") else null,
						operation.crime if operation.has("crime") else null,
						operation.evidence if operation.has("evidence") else null,
						operation.target_terminal if operation.has("target_terminal") else null
					)
				}
		
		"royal_request":
			if operation.has("action"):
				result = {
					"success": true,
					"message_id": royal_request(
						operation.action,
						operation.word if operation.has("word") else null,
						operation.blessing_type if operation.has("blessing_type") else null,
						operation.player if operation.has("player") else null,
						operation.target_terminal if operation.has("target_terminal") else null
					)
				}
		
		"dream_transmission":
			if operation.has("dream_text"):
				result = {
					"success": true,
					"message_id": dream_transmission(
						operation.dream_text,
						operation.word if operation.has("word") else null,
						operation.target_terminal if operation.has("target_terminal") else null
					)
				}
		
		"scheme_operation":
			if operation.has("action"):
				result = {
					"success": true,
					"message_id": scheme_operation(
						operation.action,
						operation.target if operation.has("target") else null,
						operation.word if operation.has("word") else null,
						operation.scheme_id if operation.has("scheme_id") else null,
						operation.target_terminal if operation.has("target_terminal") else null
					)
				}
		
		"dimensional_tunnel":
			if operation.has("source_dimension") and operation.has("target_dimension"):
				result = {
					"success": true,
					"tunnel_id": create_dimensional_tunnel(
						operation.source_dimension,
						operation.target_dimension,
						operation.duration if operation.has("duration") else 3
					)
				}
		
		"tunnel_message":
			if operation.has("tunnel_id") and operation.has("data"):
				result = {
					"success": true,
					"message_id": send_through_tunnel(
						operation.tunnel_id,
						operation.data
					)
				}
	
	return result

# ----- TERMINAL COMMAND PARSING -----

func parse_terminal_command(text):
	// Check if text contains a terminal command
	if text.to_lower().find("/terminal") != 0:
		return null
	
	// Extract command and arguments
	var args = text.substr(10).strip_edges().split(" ", false)
	
	if args.size() < 1:
		return {
			"success": false,
			"message": "Invalid terminal command. Format: /terminal [command] [args...]"
		}
	
	var command = args[0].to_lower()
	var result = null
	
	match command:
		"sync":
			// Synchronize terminals
			result = {
				"success": true,
				"message": "Terminal synchronization initiated",
				"synced_terminals": sync_all_terminals()
			}
		
		"register":
			// Register a new terminal
			if args.size() < 2:
				return {
					"success": false,
					"message": "Invalid register command. Format: /terminal register [type]"
				}
			
			var terminal_type = -1
			
			match args[1].to_lower():
				"genesis": terminal_type = TerminalType.GENESIS
				"observer": terminal_type = TerminalType.OBSERVER
				"archivist": terminal_type = TerminalType.ARCHIVIST
				"judgment": terminal_type = TerminalType.JUDGMENT
				"royal_court": terminal_type = TerminalType.ROYAL_COURT
				"dream_weaver": terminal_type = TerminalType.DREAM_WEAVER
			
			if terminal_type >= 0:
				result = {
					"success": true,
					"message": "Terminal registered successfully",
					"terminal_id": register_current_terminal(terminal_type)
				}
			else:
				result = {
					"success": false,
					"message": "Invalid terminal type. Valid types: genesis, observer, archivist, judgment, royal_court, dream_weaver"
				}
		
		"tunnel":
			// Create a dimensional tunnel
			if args.size() < 3:
				return {
					"success": false,
					"message": "Invalid tunnel command. Format: /terminal tunnel [source_dimension] [target_dimension] [duration]"
				}
			
			var source_dimension = int(args[1])
			var target_dimension = int(args[2])
			var duration = 3
			
			if args.size() >= 4:
				duration = int(args[3])
			
			if source_dimension >= 1 and source_dimension <= 12 and target_dimension >= 1 and target_dimension <= 12:
				result = {
					"success": true,
					"message": "Dimensional tunnel created",
					"tunnel_id": create_dimensional_tunnel(source_dimension, target_dimension, duration)
				}
			else:
				result = {
					"success": false,
					"message": "Invalid dimensions. Must be between 1 and 12."
				}
		
		"entangle":
			// Toggle quantum entanglement
			if quantum_entanglement_active:
				stop_sync_timer()
				result = {
					"success": true,
					"message": "Quantum entanglement deactivated"
				}
			else:
				start_sync_timer()
				result = {
					"success": true,
					"message": "Quantum entanglement activated"
				}
		
		"multicore":
			// Toggle multi-core processing
			if args.size() < 2:
				return {
					"success": false,
					"message": "Invalid multicore command. Format: /terminal multicore [on/off]"
				}
			
			if args[1].to_lower() == "on":
				enable_multi_core()
				result = {
					"success": true,
					"message": "Multi-core processing enabled"
				}
			elif args[1].to_lower() == "off":
				disable_multi_core()
				result = {
					"success": true,
					"message": "Multi-core processing disabled"
				}
			else:
				result = {
					"success": false,
					"message": "Invalid argument. Use 'on' or 'off'."
				}
		
		"list":
			// List active terminals
			var terminals = []
			
			for terminal_id in active_terminals:
				var terminal_info = active_terminals[terminal_id]
				
				if terminal_info.status == "active":
					terminals.append({
						"id": terminal_id,
						"type": terminal_info.type,
						"name": terminal_info.name,
						"dimension": terminal_info.dimension,
						"sync_count": terminal_info.sync_count
					})
			
			result = {
				"success": true,
				"message": str(terminals.size()) + " active terminals",
				"terminals": terminals
			}
		
		_:
			result = {
				"success": false,
				"message": "Unknown terminal command: " + command
			}
	
	return result

# ----- EVENT HANDLERS -----

func _on_turn_completed(turn_number):
	// Special handling for turns divisible by 9
	if turn_number % 9 == 0:
		// Force synchronization on 9th turns
		sync_all_terminals()
		
		if word_comment_system:
			word_comment_system.add_comment("terminal_sync",
				"SACRED TURN: Terminal synchronization enforced on turn " + str(turn_number),
				word_comment_system.CommentType.OBSERVATION)

func _on_dimension_changed(new_dimension, old_dimension):
	// Update current terminal's dimension
	for terminal_id in active_terminals:
		if active_terminals[terminal_id].type == current_terminal:
			active_terminals[terminal_id].dimension = new_dimension
			break
	
	// Special handling for primary dimensions of each terminal
	var primary_terminal_type = -1
	
	for terminal_type in terminal_properties:
		if terminal_properties[terminal_type].primary_dimension == new_dimension:
			primary_terminal_type = terminal_type
			break
	
	if primary_terminal_type >= 0:
		if word_comment_system:
			word_comment_system.add_comment("terminal_dimension",
				"ENTERING PRIMARY DIMENSION: Dimension " + str(new_dimension) + 
				" is the primary dimension of Terminal " + str(primary_terminal_type) + 
				" (" + terminal_properties[primary_terminal_type].name + ")",
				word_comment_system.CommentType.DIVINE)
		
		// Enhanced synchronization for primary dimension
		for terminal_id in active_terminals:
			if active_terminals[terminal_id].type == primary_terminal_type:
				// Apply special sync boost
				sync_status[terminal_id].sync_errors = 0
				
				// Synchronize all channels immediately
				for channel in channels.keys():
					sync_status[terminal_id].channels_synced[channel] = OS.get_unix_time()
				
				break

func _on_word_processed(word, power, source_player):
	// Check if word is a terminal command
	var command_result = parse_terminal_command(word)
	
	if command_result != null:
		// Terminal command processed
		return
	
	// Special handling for words containing "terminal" and a number
	var regex = RegEx.new()
	regex.compile("terminal\\s+([1-6])")
	var result = regex.search(word.to_lower())
	
	if result:
		// Reference to a specific terminal detected
		var terminal_number = int(result.get_string(1))
		var terminal_type = terminal_number - 1 # Convert from 1-based to 0-based
		
		if terminal_type >= 0 and terminal_type < TerminalType.size():
			// Relay word to the specified terminal
			word_relay(word, source_player, terminal_type)
			
			if word_comment_system:
				word_comment_system.add_comment("terminal_relay",
					"TERMINAL REFERENCE: Word '" + word + "' relayed to Terminal " + str(terminal_number) + 
					" (" + terminal_properties[terminal_type].name + ")",
					word_comment_system.CommentType.OBSERVATION)

# ----- PUBLIC API -----

func get_active_terminals():
	var terminals = []
	
	for terminal_id in active_terminals:
		var terminal_info = active_terminals[terminal_id]
		
		if terminal_info.status == "active":
			terminals.append({
				"id": terminal_id,
				"type": terminal_info.type,
				"name": terminal_info.name,
				"dimension": terminal_info.dimension,
				"sync_count": terminal_info.sync_count
			})
	
	return terminals

func get_current_terminal():
	return {
		"type": current_terminal,
		"name": terminal_properties[current_terminal].name,
		"primary_dimension": terminal_properties[current_terminal].primary_dimension
	}

func get_sync_status():
	return sync_status

func get_channel_status():
	var status = {}
	
	for channel in channels.keys():
		status[channel] = {
			"message_count": channel_buffers[channel].size(),
			"last_message": null
		}
		
		if channel_buffers[channel].size() > 0:
			status[channel].last_message = channel_buffers[channel].back()
	
	return status

func check_terminal_command(text):
	return parse_terminal_command(text)