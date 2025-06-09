extends Node

class_name TurnIntegrator

# References to other systems
var turn_priority_system = null
var twelve_turns_game = null

# Integration settings
var auto_advance_turns = true
var turn_duration = 60.0  # Default 60 seconds per turn
var turn_timer = null

# Signals
signal integration_completed
signal turn_integrated(turn_number, game_dimension)

func _ready():
	# Setup the turn timer
	turn_timer = Timer.new()
	turn_timer.one_shot = false
	turn_timer.wait_time = turn_duration
	turn_timer.connect("timeout", self, "_on_turn_timer_timeout")
	add_child(turn_timer)
	
	# Connect to existing systems
	connect_to_systems()
	
	print("Turn Integrator initialized")

func connect_to_systems():
	# Try to find existing TurnPrioritySystem
	turn_priority_system = get_node_or_null("/root/TurnPrioritySystem")
	if not turn_priority_system:
		turn_priority_system = TurnPrioritySystem.new()
		turn_priority_system.name = "TurnPrioritySystem"
		get_tree().root.add_child(turn_priority_system)
		print("Created new TurnPrioritySystem")
	
	# Connect signals from TurnPrioritySystem
	turn_priority_system.connect("turn_advanced", self, "_on_turn_advanced")
	turn_priority_system.connect("priority_shifted", self, "_on_priority_shifted")
	turn_priority_system.connect("cycle_completed", self, "_on_cycle_completed")
	
	# Try to find existing TwelveTurnsGame
	twelve_turns_game = get_node_or_null("/root/TwelveTurnsGame")
	if twelve_turns_game:
		# Connect to TwelveTurnsGame signals
		if not twelve_turns_game.is_connected("dimension_transition_complete", self, "_on_dimension_transition"):
			twelve_turns_game.connect("dimension_transition_complete", self, "_on_dimension_transition")
		print("Connected to TwelveTurnsGame")
	
	emit_signal("integration_completed")

func start_turn_cycle():
	if auto_advance_turns:
		turn_timer.start()
		print("Started automatic turn cycle with " + str(turn_duration) + " seconds per turn")
	
	# Initial turn state sync
	sync_turn_state()

func stop_turn_cycle():
	turn_timer.stop()
	print("Stopped automatic turn cycle")

func sync_turn_state():
	if twelve_turns_game and twelve_turns_game.turn_system:
		# Sync dimension to match the minor version in turn_priority_system
		var dimension = turn_priority_system.current_turn[1]
		twelve_turns_game.turn_system.set_dimension(dimension)
		
		# Add a comment about the synchronization
		if twelve_turns_game.word_comment_system:
			twelve_turns_game.word_comment_system.add_comment(
				"turn_sync",
				"Synchronized turn " + turn_priority_system.get_turn_string() + 
				" with dimension " + str(dimension),
				twelve_turns_game.word_comment_system.CommentType.OBSERVATION
			)
		
		emit_signal("turn_integrated", turn_priority_system.get_turn_string(), dimension)
		print("Synchronized turn state: " + turn_priority_system.get_turn_string() + " with dimension " + str(dimension))

func advance_turn():
	if turn_priority_system:
		turn_priority_system.advance_turn()
		
		# Sync with TwelveTurnsGame
		sync_turn_state()
		
		return turn_priority_system.get_turn_string()
	
	return "0.0.0.0"

func add_priority(category, item):
	if turn_priority_system:
		return turn_priority_system.add_priority(category, item)
	return false

func remove_priority(category, item):
	if turn_priority_system:
		return turn_priority_system.remove_priority(category, item)
	return false

func set_turn_duration(seconds):
	turn_duration = seconds
	if turn_timer:
		turn_timer.wait_time = seconds
		if turn_timer.is_stopped() and auto_advance_turns:
			turn_timer.start()
	print("Set turn duration to " + str(seconds) + " seconds")

func set_auto_advance(enabled):
	auto_advance_turns = enabled
	if enabled and turn_timer and turn_timer.is_stopped():
		turn_timer.start()
	elif not enabled and turn_timer and not turn_timer.is_stopped():
		turn_timer.stop()
	print("Auto advance turns set to: " + str(enabled))

func get_current_turn_data():
	if turn_priority_system:
		return turn_priority_system.get_turn_data()
	return null

func get_active_priorities():
	if turn_priority_system:
		return turn_priority_system.get_active_priorities()
	return null

# ----- EVENT HANDLERS -----

func _on_turn_timer_timeout():
	advance_turn()

func _on_turn_advanced(turn_number, turn_lines):
	# This is called when the TurnPrioritySystem advances a turn
	print("Turn advanced to: " + turn_number)
	
	# If connected to TwelveTurnsGame, add the event to the comment system
	if twelve_turns_game and twelve_turns_game.word_comment_system:
		twelve_turns_game.word_comment_system.add_comment(
			"turn_advanced", 
			"Advanced to turn " + turn_number + " - Active category: " + 
			turn_priority_system.get_active_priorities().category,
			twelve_turns_game.word_comment_system.CommentType.OBSERVATION
		)

func _on_priority_shifted(old_category, new_category, item):
	# This is called when a priority shifts from one category to another
	print("Priority shifted: " + item + " from " + old_category + " to " + new_category)
	
	# If connected to TwelveTurnsGame, add the event to the comment system
	if twelve_turns_game and twelve_turns_game.word_comment_system:
		twelve_turns_game.word_comment_system.add_comment(
			"priority_shift", 
			"Priority '" + item + "' graduated from " + old_category + " to " + new_category,
			twelve_turns_game.word_comment_system.CommentType.DIVINE
		)

func _on_cycle_completed(cycle_number):
	# This is called when a full cycle of turns completes
	print("Completed cycle: " + str(cycle_number))
	
	# If connected to TwelveTurnsGame, record this in the dream storage
	if twelve_turns_game and twelve_turns_game.word_dream_storage:
		twelve_turns_game.word_dream_storage.save_dimension_record(
			cycle_number,
			{
				"event": "cycle_completion",
				"cycle": cycle_number,
				"active_category": turn_priority_system.get_active_priorities().category,
				"turn": turn_priority_system.get_turn_string()
			},
			2  # Save to tier 2
		)

func _on_dimension_transition(from_dim, to_dim):
	# This is called when TwelveTurnsGame changes dimensions
	print("Dimension transition from " + str(from_dim) + " to " + str(to_dim))
	
	# Update our turn counter to match the dimension if possible
	if turn_priority_system:
		var current = turn_priority_system.current_turn.duplicate()
		current[1] = to_dim  # Set minor version to match dimension
		turn_priority_system.set_current_turn(current[0], current[1], current[2], current[3])
		
		# Update the turn display files
		turn_priority_system.save_display_files()
		
		print("Updated turn to match dimension: " + turn_priority_system.get_turn_string())
