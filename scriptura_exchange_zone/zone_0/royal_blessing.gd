extends Node

# Royal Blessing System
# Implements the divine blessing mechanics for the 12 turns system
# Terminal 1: Divine Word Genesis

class_name RoyalBlessingSystem

# ----- BLESSING TYPES -----
enum BlessingType {
	GENESIS,       # Creates new dimensional pockets
	CHRONOS,       # Manipulates time flow
	HARMONY,       # Aligns words into patterns
	JUDGMENT,      # Determines cosmic worth
	TRANSCENDENCE  # Bypasses dimensional boundaries
}

# ----- BLESSING PROPERTIES -----
var blessing_properties = {
	BlessingType.GENESIS: {
		"name": "Blessing of Genesis",
		"description": "Creates new dimensional pockets where words follow unique rules",
		"power_multiplier": 2.0,
		"duration_turns": 12,
		"favor_cost": 50
	},
	BlessingType.CHRONOS: {
		"name": "Blessing of Chronos",
		"description": "Manipulates the flow of the 9-second interval",
		"time_multiplier": 1.5,
		"duration_turns": 9,
		"favor_cost": 75
	},
	BlessingType.HARMONY: {
		"name": "Blessing of Harmony",
		"description": "Aligns disparate words into harmonious patterns",
		"pattern_bonus": 3.0,
		"duration_turns": 7,
		"favor_cost": 60
	},
	BlessingType.JUDGMENT: {
		"name": "Blessing of Judgment",
		"description": "Grants the power to determine cosmic worth of words",
		"judgment_power": 12.0,
		"duration_turns": 9,
		"favor_cost": 90
	},
	BlessingType.TRANSCENDENCE: {
		"name": "Blessing of Transcendence",
		"description": "Allows words to bypass dimensional boundaries",
		"dimension_bonus": 12.0,
		"duration_turns": 3,
		"favor_cost": 120
	}
}

# ----- STATE VARIABLES -----
var active_blessings = {}
var royal_favor = {}
var blessed_words = {}
var royal_decrees = []
var royal_titles = {}

# ----- SYSTEM REFERENCES -----
var turn_system = null
var divine_word_processor = null
var word_comment_system = null
var word_dream_storage = null

# ----- SIGNALS -----
signal blessing_granted(player, word, blessing_type)
signal blessing_expired(player, word, blessing_type)
signal royal_favor_changed(player, old_amount, new_amount)
signal royal_decree_issued(decree_text, blessing_type)
signal royal_title_granted(player, title)

func _ready():
	connect_systems()
	initialize_royal_titles()

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
	
	# Connect to the comment system
	word_comment_system = get_node_or_null("/root/WordCommentSystem")
	
	# Connect to the dream storage
	word_dream_storage = get_node_or_null("/root/WordDreamStorage")

func initialize_royal_titles():
	# Initialize the royal titles players can earn
	var royal_title_data = {
		"Wordweaver": {
			"description": "Master of basic word creation",
			"favor_required": 100,
			"dimension_required": 3,
			"powers": ["10% word power boost"]
		},
		"Dreamshaper": {
			"description": "Adept at dream manipulation",
			"favor_required": 250,
			"dimension_required": 7,
			"powers": ["Dream storage boost", "Dream visions"]
		},
		"Justice Arbiter": {
			"description": "Skilled in word judgment",
			"favor_required": 400,
			"dimension_required": 9,
			"powers": ["Enhanced judgment influence", "Crime detection"]
		},
		"Harmony Weaver": {
			"description": "Creates balanced word patterns",
			"favor_required": 600,
			"dimension_required": 10,
			"powers": ["Pattern recognition", "Word alignment"]
		},
		"Dimensional Duke": {
			"description": "Master of a specific dimension",
			"favor_required": 800,
			"dimension_required": 12,
			"powers": ["Dimensional pocket creation", "Local reality manipulation"]
		},
		"Royal Vizier": {
			"description": "Direct advisor to the Queen",
			"favor_required": 1000,
			"dimension_required": 12,
			"powers": ["Blessing cost reduction", "Royal decree enhancement"]
		},
		"Divine Aspirant": {
			"description": "Candidate for ascension to divinity",
			"favor_required": 2000,
			"dimension_required": 12,
			"powers": ["All lesser title powers", "Reality creation"]
		}
	}
	
	# Store the data
	royal_titles = royal_title_data

# ----- BLESSING MANAGEMENT -----

func grant_blessing(player_name, word, blessing_type, requester="system"):
	# Check if player has sufficient royal favor
	if not royal_favor.has(player_name):
		royal_favor[player_name] = 0
	
	var favor_cost = blessing_properties[blessing_type].favor_cost
	if royal_favor[player_name] < favor_cost:
		return {
			"success": false,
			"message": "Insufficient royal favor. Required: " + str(favor_cost) + ", Available: " + str(royal_favor[player_name])
		}
	
	# Reduce royal favor
	var old_favor = royal_favor[player_name]
	royal_favor[player_name] -= favor_cost
	emit_signal("royal_favor_changed", player_name, old_favor, royal_favor[player_name])
	
	# Create blessing data
	var duration = blessing_properties[blessing_type].duration_turns
	var blessing_id = word + "_" + str(blessing_type) + "_" + str(OS.get_unix_time())
	
	var blessing_data = {
		"id": blessing_id,
		"player": player_name,
		"word": word,
		"type": blessing_type,
		"type_name": blessing_properties[blessing_type].name,
		"granted_turn": turn_system.current_turn if turn_system else 0,
		"granted_dimension": turn_system.current_dimension if turn_system else 1,
		"expires_turn": (turn_system.current_turn if turn_system else 0) + duration,
		"requester": requester,
		"timestamp": OS.get_unix_time()
	}
	
	# Add to active blessings
	active_blessings[blessing_id] = blessing_data
	
	# Track blessings for this word
	if not blessed_words.has(word):
		blessed_words[word] = []
	blessed_words[word].append(blessing_data)
	
	# Emit signal
	emit_signal("blessing_granted", player_name, word, blessing_type)
	
	# Create a royal decree
	var decree_text = "By royal decree, the Queen of Time and Space grants the " + 
		blessing_properties[blessing_type].name + " to the word '" + word + 
		"' spoken by " + player_name + "."
	
	record_royal_decree(decree_text, blessing_type, player_name, word)
	
	# Save to highest memory tier
	if word_dream_storage:
		var save_data = blessing_data.duplicate()
		save_data["decree_text"] = decree_text
		word_dream_storage.save_comment({
			"word": word,
			"text": decree_text,
			"type": 4,  # Divine type
			"blessing_data": save_data,
			"timestamp": OS.get_unix_time()
		}, 3)  # Tier 3 - D: Drive
	
	return {
		"success": true,
		"message": decree_text,
		"blessing_id": blessing_id,
		"duration": duration
	}

func record_royal_decree(decree_text, blessing_type, player_name, word):
	var decree = {
		"text": decree_text,
		"type": blessing_type,
		"player": player_name,
		"word": word,
		"timestamp": OS.get_unix_time(),
		"turn": turn_system.current_turn if turn_system else 0,
		"dimension": turn_system.current_dimension if turn_system else 1
	}
	
	royal_decrees.append(decree)
	emit_signal("royal_decree_issued", decree_text, blessing_type)
	
	# Add as comment in the word comment system
	if word_comment_system:
		word_comment_system.add_comment(word, decree_text, word_comment_system.CommentType.DIVINE)
	
	return decree

func check_blessing_expiration():
	var expired_blessings = []
	var current_turn = turn_system.current_turn if turn_system else 0
	
	# Check each active blessing
	for blessing_id in active_blessings:
		var blessing = active_blessings[blessing_id]
		
		if blessing.expires_turn <= current_turn:
			expired_blessings.append(blessing_id)
	
	# Process expired blessings
	for blessing_id in expired_blessings:
		var blessing = active_blessings[blessing_id]
		
		# Emit signal
		emit_signal("blessing_expired", blessing.player, blessing.word, blessing.type)
		
		# Add comment
		if word_comment_system:
			word_comment_system.add_comment(blessing.word, 
				"The " + blessing.type_name + " granted to this word has expired.",
				word_comment_system.CommentType.OBSERVATION)
		
		# Remove from active blessings
		active_blessings.erase(blessing_id)

func get_active_blessings_for_word(word):
	var word_blessings = []
	
	for blessing_id in active_blessings:
		if active_blessings[blessing_id].word == word:
			word_blessings.append(active_blessings[blessing_id])
	
	return word_blessings

func get_active_blessings_for_player(player_name):
	var player_blessings = []
	
	for blessing_id in active_blessings:
		if active_blessings[blessing_id].player == player_name:
			player_blessings.append(active_blessings[blessing_id])
	
	return player_blessings

# ----- ROYAL FAVOR MANAGEMENT -----

func adjust_royal_favor(player_name, amount, reason=""):
	if not royal_favor.has(player_name):
		royal_favor[player_name] = 0
	
	var old_favor = royal_favor[player_name]
	royal_favor[player_name] += amount
	
	# Ensure favor doesn't go negative
	if royal_favor[player_name] < 0:
		royal_favor[player_name] = 0
	
	emit_signal("royal_favor_changed", player_name, old_favor, royal_favor[player_name])
	
	# Add comment
	if word_comment_system:
		var message = player_name + " " + (amount >= 0 ? "gained" : "lost") + " " + 
					  str(abs(amount)) + " royal favor"
		
		if reason:
			message += " for " + reason
		
		word_comment_system.add_comment("royal_favor", message, 
			word_comment_system.CommentType.DIVINE)
	
	# Check if new royal titles are earned
	check_royal_titles(player_name)
	
	return royal_favor[player_name]

func get_royal_favor(player_name):
	if royal_favor.has(player_name):
		return royal_favor[player_name]
	return 0

# ----- ROYAL TITLES -----

func check_royal_titles(player_name):
	// Check if player has earned any new titles
	var current_favor = get_royal_favor(player_name)
	var current_dimension = turn_system.current_dimension if turn_system else 1
	var titles_granted = []
	
	for title in royal_titles:
		var title_data = royal_titles[title]
		
		// Check if requirements are met
		if current_favor >= title_data.favor_required and current_dimension >= title_data.dimension_required:
			// Check if player already has this title
			var has_title = false
			
			if word_comment_system:
				var comments = word_comment_system.get_comments_for_word(player_name)
				for comment in comments:
					if comment.text.find("granted the royal title of " + title) >= 0:
						has_title = true
						break
			
			if not has_title:
				grant_royal_title(player_name, title)
				titles_granted.append(title)
	
	return titles_granted

func grant_royal_title(player_name, title):
	if not royal_titles.has(title):
		return {
			"success": false,
			"message": "Invalid royal title: " + title
		}
	
	var title_data = royal_titles[title]
	
	// Create decree
	var decree_text = "By royal decree, the Queen of Time and Space has granted " + 
					  player_name + " the royal title of " + title + ": " + 
					  title_data.description
	
	record_royal_decree(decree_text, -1, player_name, player_name)
	emit_signal("royal_title_granted", player_name, title)
	
	// Apply title benefits
	apply_title_benefits(player_name, title)
	
	return {
		"success": true,
		"message": decree_text,
		"title": title,
		"powers": title_data.powers
	}

func apply_title_benefits(player_name, title):
	if not royal_titles.has(title):
		return false
	
	var title_data = royal_titles[title]
	
	// Apply benefits based on title
	match title:
		"Wordweaver":
			// Apply 10% word power boost
			if divine_word_processor:
				divine_word_processor.add_player_modifier(player_name, "title_wordweaver", 1.1)
		
		"Dreamshaper":
			// Enhanced dream storage
			if word_dream_storage:
				// Allow direct tier 3 dream storage
				// Will be handled in word processing
				pass
		
		"Justice Arbiter":
			// Enhanced judgment influence
			// Will be handled in word salem controller
			pass
		
		"Harmony Weaver":
			// Pattern recognition boost
			if divine_word_processor:
				divine_word_processor.add_player_modifier(player_name, "title_harmony", 1.5)
		
		"Dimensional Duke":
			// Dimensional pocket creation
			// Special handling for royal blessing cost reduction
			var blessing_costs = blessing_properties.duplicate(true)
			for blessing_type in blessing_costs:
				blessing_costs[blessing_type].favor_cost *= 0.8
		
		"Royal Vizier":
			// Blessing cost reduction
			var blessing_costs = blessing_properties.duplicate(true)
			for blessing_type in blessing_costs:
				blessing_costs[blessing_type].favor_cost *= 0.5
		
		"Divine Aspirant":
			// All lesser title powers plus reality creation
			if divine_word_processor:
				divine_word_processor.add_player_modifier(player_name, "title_divine", 2.0)
			
			// Reality creation will be handled in word processing
	
	return true

func get_player_titles(player_name):
	var titles = []
	
	if word_comment_system:
		var comments = word_comment_system.get_comments_for_word(player_name)
		for comment in comments:
			if comment.text.find("granted the royal title of ") >= 0:
				// Extract title from comment
				var title_start = comment.text.find("royal title of ") + 15
				var title_end = comment.text.find(":", title_start)
				if title_end >= 0:
					var title = comment.text.substr(title_start, title_end - title_start)
					titles.append(title)
	
	return titles

# ----- ROYAL DECREE PARSING -----

func parse_royal_decree(text, source_player):
	// Check if text contains a royal decree
	if text.to_lower().find("by royal decree") < 0:
		return null
	
	// Extract the blessed word and blessing type
	var word_start = text.find("bless ") + 6
	var word_end = text.find(" with ", word_start)
	
	if word_start >= 6 and word_end >= 0:
		var word = text.substr(word_start, word_end - word_start).strip_edges()
		var blessing_type_text = text.substr(word_end + 6).strip_edges()
		
		// Determine blessing type
		var blessing_type = -1
		
		if blessing_type_text.to_lower().find("genesis") >= 0:
			blessing_type = BlessingType.GENESIS
		elif blessing_type_text.to_lower().find("chronos") >= 0:
			blessing_type = BlessingType.CHRONOS
		elif blessing_type_text.to_lower().find("harmony") >= 0:
			blessing_type = BlessingType.HARMONY
		elif blessing_type_text.to_lower().find("judgment") >= 0:
			blessing_type = BlessingType.JUDGMENT
		elif blessing_type_text.to_lower().find("transcendence") >= 0:
			blessing_type = BlessingType.TRANSCENDENCE
		
		if blessing_type >= 0:
			// Check if player has sufficient favor
			return grant_blessing(source_player, word, blessing_type, source_player)
	}
	
	return null

# ----- BLESSING EFFECTS -----

func apply_blessing_effects(word, power, source_player):
	var word_blessings = get_active_blessings_for_word(word)
	var total_modifier = 1.0
	
	for blessing in word_blessings:
		match blessing.type:
			BlessingType.GENESIS:
				// Power multiplier for new dimensional pockets
				total_modifier *= blessing_properties[BlessingType.GENESIS].power_multiplier
			
			BlessingType.HARMONY:
				// Pattern bonus for harmonic alignment
				total_modifier *= blessing_properties[BlessingType.HARMONY].pattern_bonus
			
			BlessingType.TRANSCENDENCE:
				// Dimension bonus for transcending boundaries
				total_modifier *= blessing_properties[BlessingType.TRANSCENDENCE].dimension_bonus
	
	// Apply dimension-specific modifications
	if turn_system:
		var dimension = turn_system.current_dimension
		
		// Blessings are especially powerful in dimensions 7, 9, and the dimension they were granted in
		for blessing in word_blessings:
			if blessing.granted_dimension == dimension:
				total_modifier *= 1.5
			
			if dimension == 7: // Dream dimension
				total_modifier *= 1.3
			
			if dimension == 9: // Judgment dimension
				total_modifier *= 1.7
			
			if dimension == 12: // Divine dimension
				total_modifier *= 2.0
	
	// Return the modified power
	return power * total_modifier

# ----- SPECIAL BLESSING EFFECTS -----

func apply_chronos_blessing(word, source_player):
	// Check if the word has a Chronos blessing
	var has_chronos = false
	var word_blessings = get_active_blessings_for_word(word)
	
	for blessing in word_blessings:
		if blessing.type == BlessingType.CHRONOS:
			has_chronos = true
			break
	
	if has_chronos and turn_system:
		// Modify turn duration for the next turn
		var time_multiplier = blessing_properties[BlessingType.CHRONOS].time_multiplier
		turn_system.modify_next_turn_duration(time_multiplier)
		
		// Add comment
		if word_comment_system:
			word_comment_system.add_comment(word, 
				"The Blessing of Chronos alters the flow of time. Next turn duration: " + 
				str(9.0 * time_multiplier) + " seconds",
				word_comment_system.CommentType.DIVINE)
		
		return true
	
	return false

func apply_judgment_blessing(word, target_player, source_player):
	// Check if the word has a Judgment blessing
	var has_judgment = false
	var word_blessings = get_active_blessings_for_word(word)
	
	for blessing in word_blessings:
		if blessing.type == BlessingType.JUDGMENT:
			has_judgment = true
			break
	
	if has_judgment:
		// Get judgment power
		var judgment_power = blessing_properties[BlessingType.JUDGMENT].judgment_power
		
		// Add comment
		if word_comment_system:
			word_comment_system.add_comment(target_player, 
				"The Blessing of Judgment grants " + source_player + " the power to judge " + target_player +
				" with power " + str(judgment_power),
				word_comment_system.CommentType.DIVINE)
		
		// Apply judgment effects (will be handled by Salem controller)
		var salem_controller = get_node_or_null("/root/WordSalemGameController")
		if salem_controller:
			salem_controller.apply_judgment_influence(source_player, target_player, judgment_power)
		
		return true
	
	return false

# ----- EVENT HANDLERS -----

func _on_turn_completed(turn_number):
	// Check for expired blessings
	check_blessing_expiration()
	
	// Special handling for 9th turn
	if turn_number % 9 == 0:
		// Words spoken during 9th turns have enhanced blessing potential
		if word_comment_system:
			word_comment_system.add_comment("sacred_turn", 
				"The 9th turn enhances royal blessing potential. Words spoken now resonate with divine power.",
				word_comment_system.CommentType.DIVINE)

func _on_dimension_changed(new_dimension, old_dimension):
	// Special handling for key dimensions
	match new_dimension:
		9:  // Judgment dimension - enhance judgment blessings
			for blessing_id in active_blessings:
				var blessing = active_blessings[blessing_id]
				if blessing.type == BlessingType.JUDGMENT:
					// Double the duration in dimension 9
					blessing.expires_turn += blessing_properties[BlessingType.JUDGMENT].duration_turns
					
					// Add comment
					if word_comment_system:
						word_comment_system.add_comment(blessing.word, 
							"The Judgment dimension extends the duration of the Blessing of Judgment.",
							word_comment_system.CommentType.DIVINE)
		
		12: // Divine dimension - enhance all blessings
			for blessing_id in active_blessings:
				var blessing = active_blessings[blessing_id]
				
				// Add extra turns to all blessings in dimension 12
				blessing.expires_turn += 3
				
				// Add comment
				if word_comment_system:
					word_comment_system.add_comment(blessing.word, 
						"The Divine dimension extends the duration of the " + blessing.type_name + ".",
						word_comment_system.CommentType.DIVINE)

func _on_word_processed(word, power, source_player):
	// Check if this is a royal decree
	var decree_result = parse_royal_decree(word, source_player)
	
	if decree_result and decree_result.success:
		// Royal decree succeeded
		adjust_royal_favor(source_player, 10, "successfully issuing a royal decree")
	
	// Apply active blessing effects
	var modified_power = apply_blessing_effects(word, power, source_player)
	
	// Apply special blessing effects
	apply_chronos_blessing(word, source_player)
	
	// Check for royal favor increase based on word power
	var favor_gain = 0
	
	if modified_power >= 100:
		favor_gain = 20
	elif modified_power >= 50:
		favor_gain = 10
	elif modified_power >= 25:
		favor_gain = 5
	elif modified_power >= 10:
		favor_gain = 2
	
	if favor_gain > 0:
		adjust_royal_favor(source_player, favor_gain, "creating a powerful word")
	
	return modified_power