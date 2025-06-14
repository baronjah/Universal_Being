extends Node

class_name AkashicGameFramework

# Akashic Game Framework
# Main controller for Godot games with Akashic Records integration
# Provides unified access to game functionality, dimensional awareness,
# and cross-drive state persistence

# Core components
var akashic_records_connector: AkashicRecordsGameConnector
var dimension_controller
var turn_manager

# Game configuration
var game_config = {
	"id": "",
	"name": "",
	"version": "1.0.0",
	"author": "",
	"default_dimension": 3,
	"auto_save_interval": 300, # 5 minutes
	"max_save_slots": 10,
	"enable_akashic_records": true,
	"enable_dimensional_effects": true,
	"enable_turn_system": true,
	"enable_debug_commands": true
}

# Game state
var game_state = {
	"started": false,
	"paused": false,
	"current_level": "",
	"current_dimension": 3,
	"current_turn": 1,
	"play_time": 0,
	"saves_count": 0,
	"loads_count": 0
}

# Player data
var player_data = {
	"position": Vector3.ZERO,
	"stats": {},
	"inventory": [],
	"actions_history": [],
	"achievements": []
}

# Game objects
var game_objects = {}
var game_levels = {}
var registered_actions = {}

# Signals
signal game_initialized(game_id)
signal game_saved(save_id)
signal game_loaded(save_id)
signal player_action_recorded(action_type, action_data)
signal dimension_changed(old_dimension, new_dimension)
signal turn_changed(old_turn, new_turn)
signal level_changed(old_level, new_level)
signal akashic_record_created(record_id, record_type)
signal game_state_updated(property, value)

# Internal
var _timer
var _last_save_time = 0
var _initialized = false
var _akashic_available = false
var _dimension_available = false
var _turn_available = false

func _ready():
	# Create timer for auto-save and time tracking
	_timer = Timer.new()
	_timer.wait_time = 60 # Update every minute
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	_timer.start()
	
	# Connect to required systems
	_find_required_systems()

func _find_required_systems():
	# Find or create AkashicRecordsGameConnector
	if has_node("AkashicRecordsGameConnector"):
		akashic_records_connector = get_node("AkashicRecordsGameConnector")
	else:
		var connector_class = load("res://akashic_records_game_connector.gd")
		if connector_class:
			akashic_records_connector = connector_class.new()
			akashic_records_connector.name = "AkashicRecordsGameConnector"
			add_child(akashic_records_connector)
	
	if akashic_records_connector:
		_akashic_available = true
		
		# Connect signals
		akashic_records_connector.game_state_saved.connect(_on_game_state_saved)
		akashic_records_connector.game_state_loaded.connect(_on_game_state_loaded)
		akashic_records_connector.dimension_changed.connect(_on_dimension_changed)
		akashic_records_connector.record_saved.connect(_on_record_saved)
	
	# Find dimension controller
	if has_node("/root/ShapeDimensionController") or get_node_or_null("/root/ShapeDimensionController"):
		dimension_controller = get_node("/root/ShapeDimensionController")
		_dimension_available = true
	
	# Find turn manager
	if has_node("/root/TurnCycleManager") or get_node_or_null("/root/TurnCycleManager"):
		turn_manager = get_node("/root/TurnCycleManager")
		_turn_available = true
		
		if turn_manager:
			turn_manager.turn_completed.connect(_on_turn_completed)

func initialize_game(game_id, game_name, game_version="1.0.0", author=""):
	if _initialized:
		print("Game already initialized")
		return false
	
	print("Initializing game: " + game_name + " (ID: " + game_id + ", Version: " + game_version + ")")
	
	# Update game configuration
	game_config.id = game_id
	game_config.name = game_name
	game_config.version = game_version
	game_config.author = author
	
	# Set current dimension
	if _dimension_available and dimension_controller:
		game_state.current_dimension = dimension_controller.current_dimension
		game_config.default_dimension = dimension_controller.current_dimension
	
	# Set current turn
	if _turn_available and turn_manager:
		game_state.current_turn = turn_manager.current_turn
	
	# Initialize Akashic Records connector
	if _akashic_available and game_config.enable_akashic_records:
		akashic_records_connector.initialize_game(game_id, game_name, game_version)
	
	_initialized = true
	game_state.started = true
	
	emit_signal("game_initialized", game_id)
	
	return true

# Game state management

func save_game(slot=-1, description=""):
	if not _initialized:
		print("ERROR: Game not initialized")
		return null
	
	# Prepare complete game state
	var save_data = {
		"game_state": game_state.duplicate(true),
		"player_data": player_data.duplicate(true),
		"game_objects": _prepare_objects_for_save(),
		"description": description,
		"timestamp": Time.get_unix_time_from_system(),
		"game_version": game_config.version
	}
	
	var save_id = ""
	
	# Save via Akashic connector if available
	if _akashic_available and game_config.enable_akashic_records:
		save_id = akashic_records_connector.save_game_state(save_data, "", slot)
	else:
		# Fallback to direct file saving
		save_id = _direct_save_game(save_data, slot)
	
	if save_id:
		_last_save_time = Time.get_unix_time_from_system()
		game_state.saves_count += 1
		print("Game saved: " + save_id)
	
	return save_id

func load_game(save_id="", slot=-1):
	if not _initialized:
		print("ERROR: Game not initialized")
		return false
	
	var save_data
	
	# Load via Akashic connector if available
	if _akashic_available and game_config.enable_akashic_records:
		save_data = akashic_records_connector.load_game_state(save_id, slot)
	else:
		# Fallback to direct file loading
		save_data = _direct_load_game(save_id, slot)
	
	if not save_data:
		print("ERROR: Could not load save data")
		return false
	
	# Apply loaded data to current game
	if save_data.has("game_state"):
		_restore_game_state(save_data.game_state)
	
	if save_data.has("player_data"):
		_restore_player_data(save_data.player_data)
	
	if save_data.has("game_objects"):
		_restore_game_objects(save_data.game_objects)
	
	# Check dimension
	var save_dimension = save_data.game_state.get("current_dimension", game_config.default_dimension)
	if save_dimension != game_state.current_dimension:
		change_dimension(save_dimension)
	
	# Check turn
	var save_turn = save_data.game_state.get("current_turn", 1)
	if save_turn != game_state.current_turn and _turn_available:
		_update_turn(save_turn)
	
	game_state.loads_count += 1
	print("Game loaded: " + (save_id if not save_id.empty() else "slot " + str(slot)))
	
	return true

func _direct_save_game(save_data, slot=-1):
	# Generate save ID and filename
	var timestamp = Time.get_unix_time_from_system()
	var save_id = "save_" + game_config.id + "_" + str(timestamp)
	
	var filename
	if slot >= 0 and slot < game_config.max_save_slots:
		filename = "slot_" + str(slot) + ".save"
	else:
		filename = save_id + ".save"
	
	# Ensure save directory exists
	var save_dir = "user://saves/" + game_config.id + "/"
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
	
	dir = DirAccess.open("user://saves/")
	if not dir.dir_exists(game_config.id):
		dir.make_dir(game_config.id)
	
	# Save to file
	var file = FileAccess.open(save_dir + filename, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		return save_id
	
	return null

func _direct_load_game(save_id="", slot=-1):
	var filename
	if slot >= 0 and slot < game_config.max_save_slots:
		filename = "slot_" + str(slot) + ".save"
	elif not save_id.empty():
		filename = save_id + ".save"
	else:
		# Find newest save
		filename = _find_newest_save()
		if filename.empty():
			return null
	
	var save_dir = "user://saves/" + game_config.id + "/"
	var file_path = save_dir + filename
	
	if not FileAccess.file_exists(file_path):
		return null
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return null
	
	var json_string = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return null
	
	return json.get_data()

func _find_newest_save():
	var save_dir = "user://saves/" + game_config.id + "/"
	var dir = DirAccess.open(save_dir)
	
	if not dir:
		return ""
	
	var newest_file = ""
	var newest_time = 0
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".save"):
			var file_path = save_dir + file_name
			var modified_time = FileAccess.get_modified_time(file_path)
			
			if modified_time > newest_time:
				newest_time = modified_time
				newest_file = file_name
		
		file_name = dir.get_next()
	
	return newest_file

func _prepare_objects_for_save():
	var saveable_objects = {}
	
	for object_id in game_objects:
		var obj = game_objects[object_id]
		
		# Skip transient objects
		if obj.has("transient") and obj.transient:
			continue
		
		# Make a copy without connections to other objects
		saveable_objects[object_id] = _strip_object_connections(obj)
	
	return saveable_objects

func _strip_object_connections(obj):
	var stripped = obj.duplicate(true)
	
	# Remove node references and other non-serializable data
	var keys_to_remove = []
	
	for key in stripped:
		var value = stripped[key]
		
		# Check if value is a node or object reference that can't be saved
		if value is Node or (value is Object and not value is Resource):
			keys_to_remove.append(key)
	
	for key in keys_to_remove:
		stripped.erase(key)
	
	return stripped

func _restore_game_state(loaded_state):
	# Update fields while preserving values not in the save
	for key in loaded_state:
		if game_state.has(key):
			game_state[key] = loaded_state[key]
	
	emit_signal("game_state_updated", "loaded", true)

func _restore_player_data(loaded_player):
	# Update fields while preserving values not in the save
	for key in loaded_player:
		if player_data.has(key):
			player_data[key] = loaded_player[key]

func _restore_game_objects(loaded_objects):
	# Clear existing objects unless they're marked as persistent
	var persistent_objects = {}
	
	for object_id in game_objects:
		var obj = game_objects[object_id]
		if obj.has("persistent") and obj.persistent:
			persistent_objects[object_id] = obj
	
	game_objects.clear()
	
	# Add back persistent objects
	for object_id in persistent_objects:
		game_objects[object_id] = persistent_objects[object_id]
	
	# Add loaded objects
	for object_id in loaded_objects:
		game_objects[object_id] = loaded_objects[object_id]
		
		# Report loaded object
		if game_config.enable_debug_commands:
			print("Loaded object: " + object_id)

# Dimension management

func change_dimension(new_dimension):
	if new_dimension == game_state.current_dimension:
		return true
	
	print("Changing game dimension from " + str(game_state.current_dimension) + 
		" to " + str(new_dimension))
	
	var old_dimension = game_state.current_dimension
	game_state.current_dimension = new_dimension
	
	# Update dimension controller if available
	if _dimension_available and dimension_controller:
		if dimension_controller.has_method("change_dimension"):
			dimension_controller.change_dimension(new_dimension)
	
	# Update Akashic connector if available
	if _akashic_available and game_config.enable_akashic_records:
		akashic_records_connector.change_dimension(new_dimension)
	
	emit_signal("dimension_changed", old_dimension, new_dimension)
	emit_signal("game_state_updated", "current_dimension", new_dimension)
	
	# Apply dimensional effects if enabled
	if game_config.enable_dimensional_effects:
		_apply_dimensional_effects(new_dimension)
	
	return true

func _apply_dimensional_effects(dimension):
	match dimension:
		1: # Foundation dimension
			# Basic physical rules
			pass
		2: # Growth dimension
			# Biological and development effects
			pass
		3: # Energy dimension
			# Energy and power effects
			pass
		4: # Insight dimension
			# Information and knowledge effects
			pass
		5: # Force dimension
			# Advanced physics effects
			pass
		6: # Vision dimension
			# Perception effects
			pass
		7: # Wisdom dimension
			# Integration effects
			pass
		8: # Transcendence dimension
			# Beyond physical effects
			pass
		9: # Unity dimension
			# All combined effects
			pass

# Turn system integration

func _update_turn(new_turn):
	if not _turn_available:
		game_state.current_turn = new_turn
		return
	
	if turn_manager and turn_manager.has_method("set_turn"):
		turn_manager.set_turn(new_turn)
	
	var old_turn = game_state.current_turn
	game_state.current_turn = new_turn
	
	emit_signal("turn_changed", old_turn, new_turn)
	emit_signal("game_state_updated", "current_turn", new_turn)

func _on_turn_completed(turn_number):
	# Turn changed, update game state
	game_state.current_turn = turn_number
	emit_signal("game_state_updated", "current_turn", turn_number)
	
	# Potentially trigger effects based on turn
	_apply_turn_effects(turn_number)
	
	# Potentially auto-save
	if Time.get_unix_time_from_system() - _last_save_time > game_config.auto_save_interval:
		_auto_save()

func _apply_turn_effects(turn_number):
	# Apply effects specific to the current turn
	# These would be customized for each game
	pass

# Game objects management

func register_game_object(object_id, object_data, type="generic"):
	if game_objects.has(object_id):
		print("WARNING: Object with ID " + object_id + " already exists. Overwriting.")
	
	# Create object
	var object = object_data.duplicate(true)
	object.id = object_id
	object.type = type
	object.created_at = Time.get_unix_time_from_system()
	object.dimension = game_state.current_dimension
	
	# Add to game objects
	game_objects[object_id] = object
	
	# Create record in Akashic system if enabled
	if _akashic_available and game_config.enable_akashic_records:
		akashic_records_connector.create_game_object_record(object, type, object_id)
	
	return object_id

func get_game_object(object_id):
	if game_objects.has(object_id):
		return game_objects[object_id]
	return null

func update_game_object(object_id, updates):
	if not game_objects.has(object_id):
		print("ERROR: Object with ID " + object_id + " not found.")
		return false
	
	var object = game_objects[object_id]
	
	# Apply updates
	for key in updates:
		object[key] = updates[key]
	
	# Update modified timestamp
	object.last_modified = Time.get_unix_time_from_system()
	
	# Update record in Akashic system if enabled
	if _akashic_available and game_config.enable_akashic_records:
		akashic_records_connector.update_game_object_record(object_id, object)
	
	return true

func remove_game_object(object_id):
	if not game_objects.has(object_id):
		print("ERROR: Object with ID " + object_id + " not found.")
		return false
	
	# Remove from game objects
	game_objects.erase(object_id)
	
	return true

# Player actions and events

func record_player_action(action_type, action_data):
	if not _initialized:
		return null
	
	# Create action record
	var action = {
		"type": action_type,
		"data": action_data,
		"timestamp": Time.get_unix_time_from_system(),
		"dimension": game_state.current_dimension,
		"turn": game_state.current_turn
	}
	
	# Add to player history
	player_data.actions_history.append(action)
	
	# Record in Akashic system if enabled
	var record_id = null
	if _akashic_available and game_config.enable_akashic_records:
		record_id = akashic_records_connector.record_player_action(action_type, action_data)
	
	emit_signal("player_action_recorded", action_type, action_data)
	
	return record_id

func register_action_handler(action_type, handler_obj, handler_method):
	registered_actions[action_type] = {
		"object": handler_obj,
		"method": handler_method
	}

func execute_action(action_type, action_data):
	# Record the action
	record_player_action(action_type, action_data)
	
	# Execute handler if registered
	if registered_actions.has(action_type):
		var handler = registered_actions[action_type]
		if handler.object and handler.object.has_method(handler.method):
			handler.object.call(handler.method, action_data)
			return true
	
	return false

# Level management

func register_level(level_id, level_data):
	game_levels[level_id] = level_data.duplicate(true)

func change_level(level_id):
	if not game_levels.has(level_id):
		print("ERROR: Level with ID " + level_id + " not found.")
		return false
	
	var old_level = game_state.current_level
	game_state.current_level = level_id
	
	emit_signal("level_changed", old_level, level_id)
	emit_signal("game_state_updated", "current_level", level_id)
	
	return true

# Time and auto-save management

func _on_timer_timeout():
	# Update play time
	if game_state.started and not game_state.paused:
		game_state.play_time += 1
		emit_signal("game_state_updated", "play_time", game_state.play_time)
	
	# Check if we should auto-save
	if game_config.auto_save_interval > 0 and game_state.started and not game_state.paused:
		var current_time = Time.get_unix_time_from_system()
		if current_time - _last_save_time >= game_config.auto_save_interval:
			_auto_save()

func _auto_save():
	if not _initialized or game_state.paused:
		return
	
	print("Performing auto-save...")
	
	# Save with auto-save prefix
	var auto_save_id = "auto_" + str(Time.get_unix_time_from_system())
	save_game(-1, "Auto-save")
	
	_last_save_time = Time.get_unix_time_from_system()

# Signal handlers

func _on_game_state_saved(game_id, save_id):
	emit_signal("game_saved", save_id)

func _on_game_state_loaded(game_id, save_id):
	emit_signal("game_loaded", save_id)

func _on_dimension_changed(old_dimension, new_dimension):
	game_state.current_dimension = new_dimension
	emit_signal("dimension_changed", old_dimension, new_dimension)
	emit_signal("game_state_updated", "current_dimension", new_dimension)

func _on_record_saved(game_id, record_id, dimension):
	emit_signal("akashic_record_created", record_id, "unknown")

# Debugging and utilities

func get_dimensional_description(dimension=0):
	if dimension == 0:
		dimension = game_state.current_dimension
	
	var descriptions = {
		1: "Foundation - Basic physical rules and structures",
		2: "Growth - Biological and developmental patterns",
		3: "Energy - Power flows and force dynamics",
		4: "Insight - Knowledge and information systems",
		5: "Force - Advanced physics and control",
		6: "Vision - Perception and awareness",
		7: "Wisdom - Integration of knowledge systems",
		8: "Transcendence - Beyond physical limitations",
		9: "Unity - All dimensions combined"
	}
	
	if dimension in descriptions:
		return descriptions[dimension]
	
	return "Unknown dimension"

func generate_debug_report():
	if not _initialized:
		return "Game not initialized"
	
	var report = "AkashicGameFramework Debug Report\n"
	report += "===============================\n\n"
	
	report += "Game: " + game_config.name + " (ID: " + game_config.id + ", Version: " + game_config.version + ")\n"
	report += "State: " + ("Started" if game_state.started else "Not started") + ", " + ("Paused" if game_state.paused else "Running") + "\n"
	report += "Play time: " + str(game_state.play_time / 60) + " minutes\n"
	report += "Current level: " + game_state.current_level + "\n"
	report += "Current dimension: " + str(game_state.current_dimension) + " - " + get_dimensional_description() + "\n"
	report += "Current turn: " + str(game_state.current_turn) + "\n"
	report += "Saves/Loads: " + str(game_state.saves_count) + "/" + str(game_state.loads_count) + "\n\n"
	
	report += "Systems available:\n"
	report += "- Akashic Records: " + str(_akashic_available) + "\n"
	report += "- Dimension Controller: " + str(_dimension_available) + "\n"
	report += "- Turn Manager: " + str(_turn_available) + "\n\n"
	
	report += "Game objects: " + str(game_objects.size()) + "\n"
	report += "Game levels: " + str(game_levels.size()) + "\n"
	report += "Player actions history: " + str(player_data.actions_history.size()) + "\n"
	
	return report

func execute_command(command, args=[]):
	if not game_config.enable_debug_commands:
		return "Debug commands disabled"
	
	match command:
		"help":
			return "Available commands: help, save, load, dimension, turn, report, state"
		
		"save":
			var slot = -1
			if args.size() > 0:
				slot = int(args[0])
			
			var save_id = save_game(slot, "Command save")
			return "Game saved: " + save_id
		
		"load":
			var arg = ""
			if args.size() > 0:
				arg = args[0]
			
			if arg.is_valid_integer():
				var result = load_game("", int(arg))
				return "Load result: " + str(result)
			else:
				var result = load_game(arg)
				return "Load result: " + str(result)
		
		"dimension":
			if args.size() > 0 and args[0].is_valid_integer():
				var dim = int(args[0])
				if dim >= 1 and dim <= 9:
					change_dimension(dim)
					return "Dimension changed to " + str(dim)
				else:
					return "Invalid dimension (must be 1-9)"
			else:
				return "Current dimension: " + str(game_state.current_dimension) + " - " + get_dimensional_description()
		
		"turn":
			if args.size() > 0 and args[0].is_valid_integer():
				var turn = int(args[0])
				if turn >= 1 and turn <= 12:
					_update_turn(turn)
					return "Turn changed to " + str(turn)
				else:
					return "Invalid turn (must be 1-12)"
			else:
				return "Current turn: " + str(game_state.current_turn)
		
		"report":
			return generate_debug_report()
		
		"state":
			var state_str = JSON.stringify(game_state)
			return "Game state: " + state_str
		
		_:
			return "Unknown command: " + command