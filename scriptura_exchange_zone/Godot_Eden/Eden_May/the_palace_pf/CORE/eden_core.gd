extends Node

# Eden Core System
# Central manager for the Eden_May Game Project

class_name EdenCore

# Core systems
var game_project = null
var word_manager = null
var line_processor = null

# Turn system
var current_turn = 8
var next_turn = 9
var turn_states = {
	1: "Foundation",
	2: "Pattern",
	3: "Frequency",
	4: "Consciousness",
	5: "Probability",
	6: "Energy",
	7: "Information",
	8: "Lines",
	9: "Game_Creation",
	10: "Integration",
	11: "Embodiment",
	12: "Transcendence"
}

# Automation
var automation_enabled = true
var automation_level = 0.8 # 0-1 scale
var auto_update_timer = null
var auto_update_interval = 5.0 # seconds

# Game state
var player = {
	"name": "JSH",
	"consciousness_level": 4,
	"turn_progress": 0.8, # 0-1 scale
	"active_spells": []
}

# Command history and processing
var command_history = []
var last_command_time = 0
var input_buffer = []

# Signals
signal turn_advanced(turn_number, turn_name)
signal spell_cast(spell_name, effect)
signal automation_state_changed(enabled, level)
signal input_processed(result)

func _init():
	print("Eden Core initializing")
	
	# Create auto-update timer
	auto_update_timer = Timer.new()
	auto_update_timer.wait_time = auto_update_interval
	auto_update_timer.one_shot = false
	auto_update_timer.connect("timeout", self, "_on_auto_update")
	add_child(auto_update_timer)
	
	if automation_enabled:
		auto_update_timer.start()

func _ready():
	print("Eden Core system ready")
	print("Current Turn: " + str(current_turn) + " - " + turn_states[current_turn])
	
	# Initialize subsystems
	initialize_subsystems()
	
	# Connect signals from subsystems
	connect_signals()
	
	# Initial system update
	update_system(0)

func initialize_subsystems():
	# Create or find game project
	if not game_project:
		game_project = get_node_or_null("../GameProject")
		if not game_project:
			game_project = EdenMayGame.new()
			game_project.name = "GameProject"
			add_child(game_project)
	
	# Create or find word manager
	if not word_manager:
		word_manager = get_node_or_null("../WordManager")
		if not word_manager:
			word_manager = WordManager.new()
			word_manager.name = "WordManager"
			add_child(word_manager)
	
	# Create or find line processor
	if not line_processor:
		line_processor = get_node_or_null("../LineProcessor")
		if not line_processor:
			line_processor = LineProcessor.new()
			line_processor.name = "LineProcessor"
			add_child(line_processor)
	
	# Set up references between systems
	if line_processor and word_manager:
		line_processor.set_word_manager(word_manager)
	
	print("Subsystems initialized")

func connect_signals():
	if line_processor:
		line_processor.connect("line_processed", self, "_on_line_processed")
		line_processor.connect("pattern_detected", self, "_on_pattern_detected")
	
	print("Signals connected")

func _on_auto_update():
	update_system(auto_update_timer.wait_time)

func update_system(delta):
	if not automation_enabled:
		return
		
	# Process any queued inputs
	process_input_buffer()
	
	# Update turn progress
	player.turn_progress += delta * 0.01 * automation_level
	
	# Check for turn advancement
	if player.turn_progress >= 1.0 and current_turn < 12:
		advance_turn()
	
	# Update game project if available
	if game_project and game_project.has_method("process_update"):
		game_project.process_update(delta)

func process_input_buffer():
	if input_buffer.size() == 0:
		return
	
	var next_input = input_buffer.pop_front()
	process_input(next_input.text, next_input.context)

func process_input(text, context="user"):
	if text.strip_edges() == "":
		return null
	
	print("Processing input: " + text)
	
	# Record in command history
	var command_record = {
		"text": text,
		"context": context,
		"timestamp": OS.get_unix_time(),
		"turn": current_turn
	}
	
	command_history.append(command_record)
	last_command_time = command_record.timestamp
	
	# Check for special commands
	var result = check_special_commands(text)
	if result:
		emit_signal("input_processed", result)
		return result
	
	# Process text through line processor
	if line_processor:
		var line_result = line_processor.process_line(text)
		
		# Update result with any detected spells
		if word_manager:
			var spells = word_manager.check_spell_in_text(text)
			if spells.size() > 0:
				for spell in spells:
					cast_spell(spell)
		
		emit_signal("input_processed", line_result)
		return line_result
	
	# Fallback direct processing if line processor not available
	var basic_result = {
		"text": text,
		"processed": true,
		"context": context,
		"turn": current_turn
	}
	
	emit_signal("input_processed", basic_result)
	return basic_result

func check_special_commands(text):
	text = text.strip_edges().to_lower()

	# Check for turn advancement command
	if text == "next turn" or text == "advance turn":
		return advance_turn()

	# Check for automation command
	if text == "enable automation" or text == "automation on":
		return set_automation(true)

	if text == "disable automation" or text == "automation off":
		return set_automation(false)

	# Check for create game command
	if text == "create game":
		return create_game()

	# Check for TLDR command
	if text.begins_with("tldr "):
		var tldr_text = text.substr(5)
		return investigate_tldr(tldr_text)

	# Check for wish maker commands
	if text == "wish" or text == "wishmaker" or text == "wish maker":
		return open_wish_maker()

	if text == "tokens" or text == "token balance":
		return display_token_balance()

	if text.begins_with("wish make "):
		var wish_text = text.substr(10)
		return make_wish(wish_text)

	if text.begins_with("wish gemini "):
		var wish_text = text.substr(12)
		return make_wish(wish_text, "gemini")

	if text.begins_with("wish claude "):
		var wish_text = text.substr(12)
		return make_wish(wish_text, "claude")

	# Check for spell words
	if word_manager and word_manager.spell_dictionary.has(text):
		return cast_spell(text)

	# No special command detected
	return null

func advance_turn():
	if current_turn >= 12:
		print("Already at final turn: Transcendence")
		return {
			"type": "turn_status",
			"message": "Already at final turn: Transcendence",
			"turn": current_turn,
			"state": turn_states[current_turn]
		}
	
	current_turn += 1
	next_turn = min(12, current_turn + 1)
	player.turn_progress = 0.0
	
	print("Advanced to Turn " + str(current_turn) + " - " + turn_states[current_turn])
	
	# Update subsystems
	if game_project and game_project.has_method("advance_turn"):
		game_project.advance_turn()
	
	if word_manager and word_manager.has_method("set_turn"):
		word_manager.set_turn(current_turn)
	
	if line_processor and line_processor.has_method("set_turn"):
		line_processor.set_turn(current_turn)
	
	emit_signal("turn_advanced", current_turn, turn_states[current_turn])
	
	return {
		"type": "turn_advanced",
		"turn": current_turn,
		"state": turn_states[current_turn],
		"message": "Advanced to Turn " + str(current_turn) + " - " + turn_states[current_turn]
	}

func set_automation(enabled, level=null):
	automation_enabled = enabled
	
	if level != null:
		automation_level = clamp(level, 0.0, 1.0)
	
	if automation_enabled:
		auto_update_timer.start()
		print("Automation enabled, level: " + str(automation_level))
	else:
		auto_update_timer.stop()
		print("Automation disabled")
	
	emit_signal("automation_state_changed", automation_enabled, automation_level)
	
	return {
		"type": "automation_status",
		"enabled": automation_enabled,
		"level": automation_level,
		"message": "Automation " + ("enabled" if automation_enabled else "disabled") + ", level: " + str(automation_level)
	}

func create_game(parameters={}):
	print("Creating game with parameters: ", parameters)
	
	if game_project and game_project.has_method("create_game"):
		var game = game_project.create_game(parameters)
		
		return {
			"type": "game_created",
			"name": game.name,
			"description": game.description,
			"turn": current_turn,
			"message": "Created game: " + game.name
		}
	
	# Fallback if game_project not available
	return {
		"type": "game_created",
		"name": "Eden Game",
		"description": "A game created in Eden",
		"turn": current_turn,
		"message": "Created generic Eden game"
	}

func cast_spell(spell_name):
	if not word_manager or not word_manager.spell_dictionary.has(spell_name):
		print("Unknown spell: " + spell_name)
		return {
			"type": "spell_error",
			"spell": spell_name,
			"message": "Unknown spell: " + spell_name
		}
	
	var spell = word_manager.spell_dictionary[spell_name]
	print("Casting spell: " + spell_name + " (Power: " + str(spell.power) + ")")
	
	# Process spell through word manager
	if word_manager.has_method("process_spell_word"):
		word_manager.process_spell_word(spell_name)
	
	# Add to player's active spells
	if not player.active_spells.has(spell_name):
		player.active_spells.append(spell_name)
	
	# Apply spell effect based on type
	var effect_description = "Spell effect not implemented"
	
	match spell.effect:
		"technology_advancement":
			effect_description = "Advanced technology by " + str(spell.power)
			# Additional implementation here
		"ai_autonomy":
			effect_description = "Enhanced AI autonomy by " + str(spell.power)
			automation_level = min(1.0, automation_level + 0.1)
		"time_pause":
			effect_description = "Paused time for " + str(spell.power) + " cycles"
			# Temporarily disable automation
			var old_state = automation_enabled
			set_automation(false)
			# Schedule re-enabling
			yield(get_tree().create_timer(spell.power), "timeout")
			set_automation(old_state)
		"fantasy_creation":
			effect_description = "Created fantasy world with power " + str(spell.power)
			# Additional implementation here
		"silence_restraint":
			effect_description = "Applied silence with strength " + str(spell.power)
			# Additional implementation here
		"spell_combination":
			effect_description = "Combined active spells with multiplier " + str(spell.power)
			combine_active_spells()
		"healing":
			effect_description = "Applied healing force with power " + str(spell.power)
			# Additional implementation here
		"cleaning":
			effect_description = "Cleansed and purified with power " + str(spell.power)
			# Additional implementation here
		"perspective":
			effect_description = "Shifted perspective with power " + str(spell.power)
			player.consciousness_level = min(8, player.consciousness_level + 1)
		"integration":
			effect_description = "Integrated systems with power " + str(spell.power)
			player.turn_progress = min(1.0, player.turn_progress + 0.1)
		"investigation":
			effect_description = "Triggered investigation with power " + str(spell.power)
			# Investigation handled separately
		_:
			effect_description = "Applied " + spell.effect + " with power " + str(spell.power)
	
	emit_signal("spell_cast", spell_name, effect_description)
	
	return {
		"type": "spell_cast",
		"spell": spell_name,
		"effect": spell.effect,
		"power": spell.power,
		"message": effect_description,
		"turn": current_turn
	}

func combine_active_spells():
	if player.active_spells.size() < 2 or not word_manager:
		return
	
	for i in range(player.active_spells.size()):
		for j in range(i + 1, player.active_spells.size()):
			var spell1 = player.active_spells[i]
			var spell2 = player.active_spells[j]
			
			if word_manager.has_method("create_spell_combination"):
				word_manager.create_spell_combination(spell1, spell2)

func investigate_tldr(text):
	print("TLDR Investigation: " + text)
	
	var result = {
		"type": "tldr_investigation",
		"text": text,
		"turn": current_turn,
		"timestamp": OS.get_unix_time()
	}
	
	# Process through word manager if available
	if word_manager and word_manager.has_method("investigate_tldr"):
		var investigation = word_manager.investigate_tldr(text)
		result.keywords = investigation.keywords
		result.related_spells = investigation.related_spells
		result.message = "Investigated: " + text + "\nFound " + str(investigation.keywords.size()) + " keywords and " + str(investigation.related_spells.size()) + " spells"
	else:
		# Basic processing
		var words = text.split(" ")
		var key_words = []
		
		for word in words:
			if word.length() > 3:
				key_words.append(word.to_lower())
		
		result.keywords = key_words
		result.message = "Investigated: " + text + "\nFound " + str(key_words.size()) + " keywords"
	
	return result

func queue_input(text, context="user"):
	input_buffer.append({
		"text": text,
		"context": context
	})

func get_system_status():
	return {
		"turn": {
			"current": current_turn,
			"next": next_turn,
			"state": turn_states[current_turn],
			"progress": player.turn_progress
		},
		"player": player,
		"automation": {
			"enabled": automation_enabled,
			"level": automation_level
		},
		"systems": {
			"game_project": game_project != null,
			"word_manager": word_manager != null,
			"line_processor": line_processor != null,
			"wish_maker": get_node_or_null("../WishMaker") != null
		},
		"commands": command_history.size(),
		"last_command_time": last_command_time,
		"input_buffer": input_buffer.size()
	}

func _on_line_processed(result):
	# Update turn progress based on line processing
	player.turn_progress += 0.02

	# Additional processing can be added here

func _on_pattern_detected(pattern_name):
	print("Pattern detected: " + pattern_name)

	# Update game state based on detected pattern
	# Additional processing can be added here

# =====================================================
# WishMaker Integration Methods
# =====================================================

func open_wish_maker():
	print("Opening Wish Maker interface")

	# Check if WishMaker instance already exists
	var wish_maker_ui = get_node_or_null("/root/WishMakerSystem")
	if wish_maker_ui:
		# Show existing instance
		return "Wish Maker is already open"

	# Load scene
	var wish_maker_scene = load("res://Eden_May/wish_maker.tscn")
	if not wish_maker_scene:
		return "Error: Could not load Wish Maker scene"

	# Instance scene
	var wish_maker_instance = wish_maker_scene.instance()
	get_tree().root.add_child(wish_maker_instance)

	return "Wish Maker opened in new window"

func display_token_balance():
	var wish_maker = get_node_or_null("../WishMaker")
	if not wish_maker:
		wish_maker = get_node_or_null("/root/WishMakerSystem/WishMaker")

	if wish_maker and wish_maker.has_method("get_token_balance"):
		var balance = wish_maker.get_token_balance()
		return "Current token balance: " + str(balance)
	else:
		return "Wish Maker not available. Use /wish to open it first."

func make_wish(wish_text, api_choice=null):
	# Get reference to WishMaker
	var wish_maker = get_node_or_null("../WishMaker")
	if not wish_maker:
		wish_maker = get_node_or_null("/root/WishMakerSystem/WishMaker")

	if not wish_maker:
		# Create WishMaker if it doesn't exist
		open_wish_maker()
		wish_maker = get_node_or_null("/root/WishMakerSystem/WishMaker")
		if not wish_maker:
			return "Error: Could not create Wish Maker"

	# Validate wish text
	if wish_text.strip_edges() == "":
		return "Error: Wish text cannot be empty"

	# Get token amount (fixed amount for command version)
	var token_amount = 100

	# Force API if specified
	if api_choice:
		# Set API override
		wish_maker.api_override = api_choice

	# Make the wish
	var result = wish_maker.make_wish(wish_text, token_amount)

	# Clear API override
	wish_maker.api_override = null

	# Return result
	if result:
		return "Wish granted! Token balance: " + str(wish_maker.get_token_balance())
	else:
		return "Wish failed. Try with more specific text or more tokens."