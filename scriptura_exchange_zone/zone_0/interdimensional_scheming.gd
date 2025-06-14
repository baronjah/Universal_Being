extends Node

# Interdimensional Scheming System
# Implements covert operations and strategy across the 12 dimensions
# Terminal 4: Interdimensional Strategy Core

class_name InterdimensionalSchemingSystem

# ----- SCHEME TYPES -----
enum SchemeType {
	ALLIANCE,       # Form alliances with other players
	DECEPTION,      # Hide true intentions behind linguistic misdirection
	ASCENSION,      # Accelerate dimensional ascension
	MANIFOLD,       # Operate multiple simultaneous plans
	DIVINE          # Curry favor with the Queen
}

# ----- SCHEME CATEGORIES -----
enum SchemeCategory {
	OFFENSIVE,      # Targets other players negatively
	DEFENSIVE,      # Protects from other schemes
	DIPLOMATIC,     # Creates relationships between players
	ASCENDANT,      # Advances dimensional progress
	ROYAL           # Interacts with the divine court
}

# ----- DIMENSION-SPECIFIC SCHEME MODIFIERS -----
var dimension_modifiers = {
	1: {
		"name": "Linear Plotting",
		"detection_difficulty": 1.0,
		"power_modifier": 0.8,
		"preferred_scheme": SchemeType.ALLIANCE,
		"description": "Simple, straightforward schemes with clear objectives"
	},
	2: {
		"name": "Mirror Deception",
		"detection_difficulty": 1.2,
		"power_modifier": 0.9,
		"preferred_scheme": SchemeType.DECEPTION,
		"description": "Schemes that appear to be their opposite, masking true intentions"
	},
	3: {
		"name": "Spatial Maneuvering",
		"detection_difficulty": 1.3,
		"power_modifier": 1.0,
		"preferred_scheme": SchemeType.ALLIANCE,
		"description": "Schemes that leverage position and physical manifestation"
	},
	4: {
		"name": "Temporal Plotting",
		"detection_difficulty": 1.5,
		"power_modifier": 1.2,
		"preferred_scheme": SchemeType.MANIFOLD,
		"description": "Schemes that play out over time with delayed effects"
	},
	5: {
		"name": "Quantum Scheming",
		"detection_difficulty": 2.0,
		"power_modifier": 1.5,
		"preferred_scheme": SchemeType.DECEPTION,
		"description": "Probability-based schemes with multiple possible outcomes"
	},
	6: {
		"name": "Resonant Intrigue",
		"detection_difficulty": 1.8,
		"power_modifier": 1.4,
		"preferred_scheme": SchemeType.ALLIANCE,
		"description": "Schemes that create repeating patterns of influence"
	},
	7: {
		"name": "Dream Manipulation",
		"detection_difficulty": 2.5,
		"power_modifier": 1.8,
		"preferred_scheme": SchemeType.DECEPTION,
		"description": "Schemes that operate in the dream realm to influence reality"
	},
	8: {
		"name": "Network Conspiracy",
		"detection_difficulty": 2.2,
		"power_modifier": 1.6,
		"preferred_scheme": SchemeType.MANIFOLD,
		"description": "Schemes that operate through interconnected relationships"
	},
	9: {
		"name": "Judgment Subversion",
		"detection_difficulty": 2.0,
		"power_modifier": 2.0,
		"preferred_scheme": SchemeType.ALLIANCE,
		"description": "Schemes that manipulate or evade word judgment"
	},
	10: {
		"name": "Harmonic Orchestration",
		"detection_difficulty": 1.9,
		"power_modifier": 2.2,
		"preferred_scheme": SchemeType.DIVINE,
		"description": "Perfectly balanced schemes with multiple aligned components"
	},
	11: {
		"name": "Meta-Scheming",
		"detection_difficulty": 2.8,
		"power_modifier": 2.5,
		"preferred_scheme": SchemeType.ASCENSION,
		"description": "Self-aware schemes that adapt to counter-schemes"
	},
	12: {
		"name": "Divine Machination",
		"detection_difficulty": 3.0,
		"power_modifier": 3.0,
		"preferred_scheme": SchemeType.DIVINE,
		"description": "Transcendent schemes that alter reality itself"
	}
}

# ----- ACTIVE SCHEMES -----
var active_schemes = {}
var player_schemes = {}
var scheme_targets = {}
var scheme_alliances = {}
var scheme_counters = {}
var scheme_discoveries = {}

# ----- PATTERN RECOGNITION -----
var word_patterns = {}
var suspicious_patterns = []
var scheme_keywords = {
	SchemeType.ALLIANCE: ["ally", "friend", "together", "unite", "alliance", "pact", "covenant", "bond"],
	SchemeType.DECEPTION: ["deceive", "mask", "hide", "false", "trick", "illusion", "disguise", "veil"],
	SchemeType.ASCENSION: ["rise", "ascend", "elevate", "higher", "transcend", "climb", "advance", "uplift"],
	SchemeType.MANIFOLD: ["many", "multiple", "diverse", "varied", "complex", "multitude", "several", "fold"],
	SchemeType.DIVINE: ["divine", "royal", "queen", "blessing", "crown", "throne", "majesty", "court"]
}

# ----- SYSTEM REFERENCES -----
var turn_system = null
var divine_word_processor = null
var word_comment_system = null
var word_salem_controller = null
var word_crimes_analysis = null
var word_dream_storage = null
var royal_blessing_system = null

# ----- SIGNALS -----
signal scheme_created(scheme_id, creator, scheme_type)
signal scheme_discovered(scheme_id, discoverer)
signal scheme_activated(scheme_id)
signal scheme_completed(scheme_id, success)
signal alliance_formed(player1, player2, scheme_id)
signal counter_scheme_created(original_scheme_id, counter_scheme_id)

func _ready():
	connect_systems()
	initialize_pattern_recognition()

func connect_systems():
	# Connect to turn system
	turn_system = get_node_or_null("/root/TurnSystem")
	if turn_system:
		turn_system.connect("turn_completed", self, "_on_turn_completed")
		turn_system.connect("dimension_changed", self, "_on_dimension_changed")
	
	# Connect to divine word processor
	divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
	if divine_word_processor:
		divine_word_processor.connect("word_processed", self, "_on_word_processed")
	
	# Connect to word comment system
	word_comment_system = get_node_or_null("/root/WordCommentSystem")
	
	# Connect to word salem controller
	word_salem_controller = get_node_or_null("/root/WordSalemGameController")
	
	# Connect to word crimes analysis
	word_crimes_analysis = get_node_or_null("/root/WordCrimesAnalysis")
	
	# Connect to word dream storage
	word_dream_storage = get_node_or_null("/root/WordDreamStorage")
	
	# Connect to royal blessing system
	royal_blessing_system = get_node_or_null("/root/RoyalBlessingSystem")

func initialize_pattern_recognition():
	# Initialize suspicious patterns for scheme detection
	suspicious_patterns = [
		"(alliance|pact|treaty)\\s+(with|between)\\s+[a-zA-Z]+", # Alliance patterns
		"(deceive|trick|fool)\\s+[a-zA-Z]+", # Deception patterns
		"(ascend|rise)\\s+(to|through)\\s+dimension", # Ascension patterns
		"(multiple|many|several)\\s+(plans|schemes|operations)", # Manifold patterns
		"(divine|royal|queen)\\s+(favor|blessing|court)" # Divine patterns
	]

# ----- SCHEME CREATION AND MANAGEMENT -----

func create_scheme(creator, scheme_type, targets=[], description="", duration=5):
	# Get current dimension
	var current_dimension = turn_system.current_dimension if turn_system else 1
	
	# Generate scheme ID
	var scheme_id = "scheme_" + creator + "_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
	
	# Calculate scheme power
	var base_power = 10.0
	var dimension_modifier = dimension_modifiers[current_dimension].power_modifier
	var preferred_modifier = 1.0
	
	if dimension_modifiers[current_dimension].preferred_scheme == scheme_type:
		preferred_modifier = 1.5
	
	var total_power = base_power * dimension_modifier * preferred_modifier
	
	# Determine detection difficulty
	var detection_difficulty = dimension_modifiers[current_dimension].detection_difficulty
	
	# Create scheme data
	var scheme_data = {
		"id": scheme_id,
		"creator": creator,
		"type": scheme_type,
		"type_name": SchemeType.keys()[scheme_type],
		"targets": targets,
		"description": description,
		"created_dimension": current_dimension,
		"created_turn": turn_system.current_turn if turn_system else 0,
		"expiry_turn": (turn_system.current_turn if turn_system else 0) + duration,
		"power": total_power,
		"detection_difficulty": detection_difficulty,
		"activated": false,
		"discovered_by": [],
		"counter_schemes": [],
		"success_probability": 0.7, # Base probability
		"active_in_dimensions": [current_dimension],
		"is_counter_scheme": false,
		"original_scheme": "",
		"timestamp": OS.get_unix_time()
	}
	
	# Store in active schemes
	active_schemes[scheme_id] = scheme_data
	
	# Track schemes by player
	if not player_schemes.has(creator):
		player_schemes[creator] = []
	player_schemes[creator].append(scheme_id)
	
	# Track schemes by target
	for target in targets:
		if not scheme_targets.has(target):
			scheme_targets[target] = []
		scheme_targets[target].append(scheme_id)
	
	# Emit signal
	emit_signal("scheme_created", scheme_id, creator, scheme_type)
	
	# Create hidden comment
	if word_comment_system:
		var comment_text = "SCHEME CREATED: " + SchemeType.keys()[scheme_type] + " scheme in dimension " + str(current_dimension)
		if description:
			comment_text += " - " + description
		
		word_comment_system.add_comment("scheme_" + scheme_id, comment_text, word_comment_system.CommentType.OBSERVATION)
	
	return scheme_data

func activate_scheme(scheme_id):
	if not active_schemes.has(scheme_id):
		return {
			"success": false,
			"message": "Scheme not found: " + scheme_id
		}
	
	var scheme = active_schemes[scheme_id]
	
	if scheme.activated:
		return {
			"success": false,
			"message": "Scheme already activated"
		}
	
	# Mark as activated
	scheme.activated = true
	
	# Calculate success probability based on counter-schemes
	var counter_scheme_penalty = 0.0
	for counter_id in scheme.counter_schemes:
		if active_schemes.has(counter_id):
			var counter = active_schemes[counter_id]
			counter_scheme_penalty += counter.power / 100.0
	
	scheme.success_probability = max(0.1, scheme.success_probability - counter_scheme_penalty)
	
	# Apply scheme effects
	var effect_result = apply_scheme_effects(scheme)
	
	# Emit signal
	emit_signal("scheme_activated", scheme_id)
	
	# Create comment
	if word_comment_system:
		var comment_text = "SCHEME ACTIVATED: " + scheme.creator + "'s " + scheme.type_name + " scheme"
		if scheme.description:
			comment_text += " - " + scheme.description
		
		word_comment_system.add_comment("scheme_" + scheme_id, comment_text, word_comment_system.CommentType.OBSERVATION)
	
	return {
		"success": true,
		"message": "Scheme activated successfully",
		"effect_result": effect_result
	}

func apply_scheme_effects(scheme):
	var results = []
	
	# Apply effects based on scheme type
	match scheme.type:
		SchemeType.ALLIANCE:
			results = apply_alliance_scheme(scheme)
			
		SchemeType.DECEPTION:
			results = apply_deception_scheme(scheme)
			
		SchemeType.ASCENSION:
			results = apply_ascension_scheme(scheme)
			
		SchemeType.MANIFOLD:
			results = apply_manifold_scheme(scheme)
			
		SchemeType.DIVINE:
			results = apply_divine_scheme(scheme)
	
	return results

func apply_alliance_scheme(scheme):
	var results = []
	
	# Form alliances between creator and targets
	for target in scheme.targets:
		# Create alliance entry
		var alliance_id = "alliance_" + scheme.creator + "_" + target + "_" + str(OS.get_unix_time())
		
		var alliance_data = {
			"id": alliance_id,
			"scheme_id": scheme.id,
			"player1": scheme.creator,
			"player2": target,
			"formed_dimension": scheme.created_dimension,
			"formed_turn": turn_system.current_turn if turn_system else 0,
			"power": scheme.power,
			"timestamp": OS.get_unix_time()
		}
		
		# Store alliance
		if not scheme_alliances.has(scheme.creator):
			scheme_alliances[scheme.creator] = {}
		
		if not scheme_alliances.has(target):
			scheme_alliances[target] = {}
		
		scheme_alliances[scheme.creator][target] = alliance_data
		scheme_alliances[target][scheme.creator] = alliance_data
		
		# Emit signal
		emit_signal("alliance_formed", scheme.creator, target, scheme.id)
		
		# Create comment
		if word_comment_system:
			var comment_text = "ALLIANCE FORMED: " + scheme.creator + " and " + target + " have formed an alliance"
			word_comment_system.add_comment("alliance_" + alliance_id, comment_text, word_comment_system.CommentType.OBSERVATION)
		
		results.append({
			"type": "alliance_formed",
			"player1": scheme.creator,
			"player2": target,
			"alliance_id": alliance_id
		})
		
		# Apply alliance benefits
		if divine_word_processor:
			# Words spoken by allies gain a power boost when used together
			divine_word_processor.add_word_relationship(scheme.creator, target, "alliance", scheme.power / 100.0)
	
	return results

func apply_deception_scheme(scheme):
	var results = []
	
	for target in scheme.targets:
		# Deception schemes make targets misidentify word meanings
		if word_comment_system:
			var comment_text = "DECEPTION ACTIVE: " + target + " is now subject to linguistic misdirection"
			word_comment_system.add_comment("deception_" + scheme.id, comment_text, word_comment_system.CommentType.OBSERVATION)
		
		# Apply deception effects
		if word_salem_controller:
			# In Salem game, this affects investigations
			word_salem_controller.apply_deception_effect(target, scheme.power / 100.0, scheme.expiry_turn)
		
		results.append({
			"type": "deception_applied",
			"target": target,
			"power": scheme.power,
			"duration": scheme.expiry_turn - (turn_system.current_turn if turn_system else 0)
		})
	
	return results

func apply_ascension_scheme(scheme):
	var results = []
	
	# Ascension schemes accelerate dimension progression
	var current_dimension = turn_system.current_dimension if turn_system else 1
	var target_dimension = min(12, current_dimension + 1)
	
	# Create a transition probability based on scheme power
	var transition_probability = scheme.power / 100.0
	
	if randf() < transition_probability:
		# Success - will transition on next turn
		if turn_system:
			turn_system.queue_dimension_change(target_dimension)
			
			var comment_text = "ASCENSION IMMINENT: Transition to Dimension " + str(target_dimension) + " has been accelerated"
			word_comment_system.add_comment("ascension_" + scheme.id, comment_text, word_comment_system.CommentType.DIVINE)
			
			results.append({
				"type": "ascension_success",
				"current_dimension": current_dimension,
				"target_dimension": target_dimension,
				"next_turn": (turn_system.current_turn if turn_system else 0) + 1
			})
	else:
		# Failure - no immediate transition
		var comment_text = "ASCENSION FAILED: The attempt to accelerate dimensional transition was unsuccessful"
		word_comment_system.add_comment("ascension_" + scheme.id, comment_text, word_comment_system.CommentType.OBSERVATION)
		
		results.append({
			"type": "ascension_failed",
			"current_dimension": current_dimension
		})
	
	return results

func apply_manifold_scheme(scheme):
	var results = []
	
	# Manifold schemes operate across multiple dimensions simultaneously
	var current_dimension = turn_system.current_dimension if turn_system else 1
	
	# Determine which additional dimensions to operate in
	var additional_dimensions = []
	
	# Always add dimension 5 (probability manipulation)
	if current_dimension != 5:
		additional_dimensions.append(5)
	
	# Add dream dimension if available
	if current_dimension != 7 and scheme.created_dimension >= 7:
		additional_dimensions.append(7)
	
	# Add judgment dimension if available
	if current_dimension != 9 and scheme.created_dimension >= 9:
		additional_dimensions.append(9)
	
	# Update scheme's active dimensions
	scheme.active_in_dimensions = [current_dimension] + additional_dimensions
	
	# Apply effects in each dimension
	for dimension in additional_dimensions:
		# Record dimensional activity
		var comment_text = "MANIFOLD EXPANSION: Scheme now operates in Dimension " + str(dimension)
		word_comment_system.add_comment("manifold_" + scheme.id, comment_text, word_comment_system.CommentType.OBSERVATION)
		
		results.append({
			"type": "manifold_expansion",
			"dimension": dimension,
			"base_dimension": current_dimension
		})
		
		# Special handling for specific dimensions
		if dimension == 7 and word_dream_storage:
			# Create dream fragments for this scheme
			var dream_text = "A vision of " + scheme.creator + " operating across multiple realities simultaneously"
			word_dream_storage.store_in_divine_memory("manifold_dream_" + scheme.id, {
				"dream_text": dream_text,
				"scheme_id": scheme.id,
				"timestamp": OS.get_unix_time()
			})
	
	return results

func apply_divine_scheme(scheme):
	var results = []
	
	# Divine schemes seek to curry favor with the Queen
	if royal_blessing_system:
		// Grant royal favor based on scheme power
		var favor_amount = ceil(scheme.power / 10.0)
		
		royal_blessing_system.adjust_royal_favor(scheme.creator, favor_amount, "divine machination")
		
		var comment_text = "DIVINE FAVOR: " + scheme.creator + " has gained " + str(favor_amount) + " royal favor"
		word_comment_system.add_comment("divine_" + scheme.id, comment_text, word_comment_system.CommentType.DIVINE)
		
		results.append({
			"type": "royal_favor_increased",
			"player": scheme.creator,
			"amount": favor_amount
		})
		
		// Check for divine visions based on scheme power
		if scheme.power >= 50:
			// Create a divine vision
			var vision_id = "vision_" + scheme.id
			var vision_text = "The Queen of Time and Space acknowledges your devotion. Continue your service across all dimensions."
			
			word_comment_system.add_comment(vision_id, "DIVINE VISION: " + vision_text, word_comment_system.CommentType.DIVINE)
			
			// Store in highest memory tier
			if word_dream_storage:
				word_dream_storage.save_comment({
					"word": vision_id,
					"text": vision_text,
					"type": 4, // Divine type
					"timestamp": OS.get_unix_time()
				}, 3) // Tier 3 - D: Drive
		}
	
	return results

func create_counter_scheme(discoverer, original_scheme_id, description=""):
	if not active_schemes.has(original_scheme_id):
		return {
			"success": false,
			"message": "Original scheme not found: " + original_scheme_id
		}
	
	var original = active_schemes[original_scheme_id]
	
	// Determine counter scheme type
	var counter_type = SchemeType.DECEPTION // Default counter
	
	match original.type:
		SchemeType.ALLIANCE:
			counter_type = SchemeType.DECEPTION
		SchemeType.DECEPTION:
			counter_type = SchemeType.ALLIANCE
		SchemeType.ASCENSION:
			counter_type = SchemeType.MANIFOLD
		SchemeType.MANIFOLD:
			counter_type = SchemeType.DIVINE
		SchemeType.DIVINE:
			counter_type = SchemeType.ASCENSION
	
	// Create counter scheme
	var targets = [original.creator]
	var counter_scheme = create_scheme(discoverer, counter_type, targets, description)
	
	// Mark as counter scheme
	counter_scheme.is_counter_scheme = true
	counter_scheme.original_scheme = original_scheme_id
	
	// Add to original scheme's counters
	original.counter_schemes.append(counter_scheme.id)
	
	// Create scheme counters tracking
	if not scheme_counters.has(original_scheme_id):
		scheme_counters[original_scheme_id] = []
	scheme_counters[original_scheme_id].append(counter_scheme.id)
	
	// Emit signal
	emit_signal("counter_scheme_created", original_scheme_id, counter_scheme.id)
	
	// Create comment
	if word_comment_system:
		var comment_text = "COUNTER SCHEME: " + discoverer + " has created a " + counter_scheme.type_name + " scheme to counter " + original.creator + "'s " + original.type_name + " scheme"
		word_comment_system.add_comment("counter_" + counter_scheme.id, comment_text, word_comment_system.CommentType.OBSERVATION)
	
	return counter_scheme

# ----- SCHEME DETECTION -----

func attempt_scheme_detection(detector, target_player="", word=""):
	var detection_results = []
	var current_dimension = turn_system.current_dimension if turn_system else 1
	
	// Detection is most effective in dimensions 5, 8, and 9
	var detection_boost = 1.0
	
	if current_dimension == 5: // Probability dimension
		detection_boost = 1.5
	elif current_dimension == 8: // Interconnection dimension
		detection_boost = 2.0
	elif current_dimension == 9: // Judgment dimension
		detection_boost = 1.8
	
	// If targeting a specific player
	if target_player:
		if player_schemes.has(target_player):
			for scheme_id in player_schemes[target_player]:
				if active_schemes.has(scheme_id):
					var scheme = active_schemes[scheme_id]
					
					// Check if not already discovered by this detector
					if not detector in scheme.discovered_by:
						// Calculate detection chance
						var detection_chance = (1.0 / scheme.detection_difficulty) * detection_boost
						
						// Adjust based on word if provided
						if word and word_related_to_scheme(word, scheme):
							detection_chance *= 1.5
						
						// Detection roll
						if randf() < detection_chance:
							// Success - scheme detected
							scheme.discovered_by.append(detector)
							
							// Record discovery
							if not scheme_discoveries.has(detector):
								scheme_discoveries[detector] = []
							scheme_discoveries[detector].append(scheme_id)
							
							// Create comment
							if word_comment_system:
								var comment_text = "SCHEME DETECTED: " + detector + " has discovered " + target_player + "'s " + scheme.type_name + " scheme"
								word_comment_system.add_comment("detection_" + scheme_id, comment_text, word_comment_system.CommentType.OBSERVATION)
							
							// Emit signal
							emit_signal("scheme_discovered", scheme_id, detector)
							
							detection_results.append({
								"success": true,
								"scheme_id": scheme_id,
								"scheme_type": scheme.type,
								"scheme_creator": scheme.creator,
								"scheme_description": scheme.description
							})
					}
			}
		}
	} else {
		// General detection attempt against all schemes
		for scheme_id in active_schemes:
			var scheme = active_schemes[scheme_id]
			
			// Don't detect own schemes
			if scheme.creator == detector:
				continue
			
			// Check if not already discovered
			if not detector in scheme.discovered_by:
				// Calculate detection chance (much lower for untargeted)
				var detection_chance = (0.3 / scheme.detection_difficulty) * detection_boost
				
				// Adjust based on word if provided
				if word and word_related_to_scheme(word, scheme):
					detection_chance *= 2.0
				
				// Detection roll
				if randf() < detection_chance:
					// Success - scheme detected
					scheme.discovered_by.append(detector)
					
					// Record discovery
					if not scheme_discoveries.has(detector):
						scheme_discoveries[detector] = []
					scheme_discoveries[detector].append(scheme_id)
					
					// Create comment
					if word_comment_system:
						var comment_text = "SCHEME DETECTED: " + detector + " has discovered " + scheme.creator + "'s " + scheme.type_name + " scheme"
						word_comment_system.add_comment("detection_" + scheme_id, comment_text, word_comment_system.CommentType.OBSERVATION)
					
					// Emit signal
					emit_signal("scheme_discovered", scheme_id, detector)
					
					detection_results.append({
						"success": true,
						"scheme_id": scheme_id,
						"scheme_type": scheme.type,
						"scheme_creator": scheme.creator,
						"scheme_description": scheme.description
					})
				}
			}
		}
	}
	
	return detection_results

func word_related_to_scheme(word, scheme):
	// Check if word is related to the scheme type
	if scheme_keywords.has(scheme.type):
		var keywords = scheme_keywords[scheme.type]
		for keyword in keywords:
			if word.to_lower().find(keyword) >= 0:
				return true
	
	// Check if word is in the scheme description
	if scheme.description and scheme.description.to_lower().find(word.to_lower()) >= 0:
		return true
	
	return false

func analyze_word_for_schemes(word, source_player):
	// Check if word contains suspicious patterns
	for pattern in suspicious_patterns:
		var regex = RegEx.new()
		regex.compile(pattern)
		var result = regex.search(word.to_lower())
		
		if result:
			// Track this word pattern
			if not word_patterns.has(source_player):
				word_patterns[source_player] = []
			
			word_patterns[source_player].append({
				"word": word,
				"pattern": pattern,
				"timestamp": OS.get_unix_time(),
				"turn": turn_system.current_turn if turn_system else 0,
				"dimension": turn_system.current_dimension if turn_system else 1
			})
			
			// If in dimension 5, 8, or 9, automatically attempt scheme detection
			var current_dimension = turn_system.current_dimension if turn_system else 1
			
			if current_dimension == 5 or current_dimension == 8 or current_dimension == 9:
				// Other players have a chance to detect the scheme
				for player in player_schemes:
					if player != source_player:
						attempt_scheme_detection(player, source_player, word)
			
			return true
	
	return false

# ----- DREAM-BASED SCHEME DETECTION -----

func analyze_dream_for_schemes(dream_text, source_player):
	var results = []
	
	// Dream-based detection only works in dimension 7
	var current_dimension = turn_system.current_dimension if turn_system else 1
	
	if current_dimension != 7:
		return results
	
	// Look for scheme keywords in dream text
	for scheme_type in scheme_keywords:
		var keywords = scheme_keywords[scheme_type]
		for keyword in keywords:
			if dream_text.to_lower().find(keyword) >= 0:
				// Dream contains scheme-related keyword
				
				// Check for schemes of this type
				for scheme_id in active_schemes:
					var scheme = active_schemes[scheme_id]
					
					if scheme.type == scheme_type and scheme.creator != source_player:
						// Roll for dream-based detection
						var detection_chance = 0.4  // Higher in dreams
						
						if randf() < detection_chance:
							// Success - scheme revealed in dream
							if not scheme.discovered_by.has(source_player):
								scheme.discovered_by.append(source_player)
								
								// Record discovery
								if not scheme_discoveries.has(source_player):
									scheme_discoveries[source_player] = []
								scheme_discoveries[source_player].append(scheme_id)
								
								// Create comment
								if word_comment_system:
									var comment_text = "DREAM REVELATION: " + source_player + " has glimpsed " + scheme.creator + "'s " + scheme.type_name + " scheme in a dream"
									word_comment_system.add_comment("dream_detection_" + scheme_id, comment_text, word_comment_system.CommentType.DREAM)
								
								// Emit signal
								emit_signal("scheme_discovered", scheme_id, source_player)
								
								results.append({
									"success": true,
									"scheme_id": scheme_id,
									"scheme_type": scheme.type,
									"scheme_creator": scheme.creator,
									"scheme_description": scheme.description,
									"via_dream": true
								})
						}
				}
	}
	
	return results

# ----- SCHEME COMMAND PARSING -----

func parse_scheme_command(text, source_player):
	// Check if text contains a scheme command
	if text.to_lower().find("/scheme") != 0:
		return null
	
	// Extract scheme type and targets
	var args = text.substr(8).strip_edges().split(" ", false)
	
	if args.size() < 1:
		return {
			"success": false,
			"message": "Invalid scheme command. Format: /scheme [type] [target1,target2,...] [description]"
		}
	
	var scheme_type_str = args[0].to_lower()
	var scheme_type = -1
	
	// Parse scheme type
	match scheme_type_str:
		"alliance":
			scheme_type = SchemeType.ALLIANCE
		"deception":
			scheme_type = SchemeType.DECEPTION
		"ascension":
			scheme_type = SchemeType.ASCENSION
		"manifold":
			scheme_type = SchemeType.MANIFOLD
		"divine":
			scheme_type = SchemeType.DIVINE
		_:
			return {
				"success": false,
				"message": "Invalid scheme type. Valid types: alliance, deception, ascension, manifold, divine"
			}
	
	// Parse targets
	var targets = []
	if args.size() >= 2:
		targets = args[1].split(",", false)
	
	// Parse description
	var description = ""
	if args.size() >= 3:
		var desc_start = text.find(args[2])
		description = text.substr(desc_start)
	
	// Create scheme
	var scheme = create_scheme(source_player, scheme_type, targets, description)
	
	return {
		"success": true,
		"message": "Scheme created successfully",
		"scheme": scheme
	}

func parse_counter_scheme_command(text, source_player):
	// Check if text contains a counter scheme command
	if text.to_lower().find("/counter") != 0:
		return null
	
	// Extract original scheme ID and description
	var args = text.substr(9).strip_edges().split(" ", false)
	
	if args.size() < 1:
		return {
			"success": false,
			"message": "Invalid counter scheme command. Format: /counter [original_scheme_id] [description]"
		}
	
	var original_scheme_id = args[0]
	
	// Parse description
	var description = ""
	if args.size() >= 2:
		var desc_start = text.find(args[1])
		description = text.substr(desc_start)
	
	// Check if player has discovered the original scheme
	if not scheme_discoveries.has(source_player) or not original_scheme_id in scheme_discoveries[source_player]:
		return {
			"success": false,
			"message": "You have not discovered the scheme: " + original_scheme_id
		}
	
	// Create counter scheme
	var counter_scheme = create_counter_scheme(source_player, original_scheme_id, description)
	
	return {
		"success": true,
		"message": "Counter scheme created successfully",
		"counter_scheme": counter_scheme
	}

# ----- TURN-BASED PROCESSING -----

func process_scheme_turns():
	var completed_schemes = []
	var current_turn = turn_system.current_turn if turn_system else 0
	
	// Check each active scheme
	for scheme_id in active_schemes:
		var scheme = active_schemes[scheme_id]
		
		// Check if scheme has expired
		if scheme.expiry_turn <= current_turn:
			// Calculate success
			var success = false
			
			if scheme.activated:
				// Generate random success based on probability
				if randf() < scheme.success_probability:
					success = true
			
			// Record completion
			completed_schemes.append({
				"scheme_id": scheme_id,
				"success": success
			})
			
			// Create comment
			if word_comment_system:
				var result_text = success ? "SUCCEEDED" : "FAILED"
				var comment_text = "SCHEME " + result_text + ": " + scheme.creator + "'s " + scheme.type_name + " scheme has completed"
				word_comment_system.add_comment("scheme_complete_" + scheme_id, comment_text, word_comment_system.CommentType.OBSERVATION)
			
			// Emit signal
			emit_signal("scheme_completed", scheme_id, success)
		}
	}
	
	// Remove completed schemes
	for completion in completed_schemes:
		active_schemes.erase(completion.scheme_id)
	
	return completed_schemes

# ----- EVENT HANDLERS -----

func _on_turn_completed(turn_number):
	// Process schemes on turn completion
	process_scheme_turns()
	
	// Special handling for turns divisible by 9
	if turn_number % 9 == 0:
		// Words spoken during 9th turns have enhanced scheme detection
		if word_comment_system:
			word_comment_system.add_comment("sacred_turn_schemes", 
				"The 9th turn enhances scheme detection. Hidden plans may be revealed.",
				word_comment_system.CommentType.OBSERVATION)
		
		// Automatic scheme detection chance for everyone
		var players = []
		for player in player_schemes:
			players.append(player)
		
		for detector in players:
			for target in players:
				if detector != target:
					attempt_scheme_detection(detector, target)

func _on_dimension_changed(new_dimension, old_dimension):
	// Special handling for key dimensions
	match new_dimension:
		5:  // Probability dimension - schemes are easier to detect
			if word_comment_system:
				word_comment_system.add_comment("dimension_5_schemes", 
					"Entering Dimension 5: Probability waves reveal hidden schemes more easily.",
					word_comment_system.CommentType.OBSERVATION)
		
		7:  // Dream dimension - schemes may appear in dreams
			if word_comment_system:
				word_comment_system.add_comment("dimension_7_schemes", 
					"Entering Dimension 7: Schemes may manifest in the dreamscape.",
					word_comment_system.CommentType.DREAM)
		
		8:  // Interconnection dimension - alliances are strengthened
			if word_comment_system:
				word_comment_system.add_comment("dimension_8_schemes", 
					"Entering Dimension 8: Alliance schemes gain power through interconnection.",
					word_comment_system.CommentType.OBSERVATION)
			
			// Boost all alliance schemes
			for scheme_id in active_schemes:
				var scheme = active_schemes[scheme_id]
				if scheme.type == SchemeType.ALLIANCE:
					scheme.power *= 1.5
		
		9:  // Judgment dimension - deception schemes are revealed
			if word_comment_system:
				word_comment_system.add_comment("dimension_9_schemes", 
					"Entering Dimension 9: Judgment may reveal deception schemes.",
					word_comment_system.CommentType.OBSERVATION)
			
			// Automatic detection chance for deception schemes
			var deception_schemes = []
			for scheme_id in active_schemes:
				var scheme = active_schemes[scheme_id]
				if scheme.type == SchemeType.DECEPTION:
					deception_schemes.append(scheme_id)
			
			// Everyone has a chance to detect deception schemes
			var players = []
			for player in player_schemes:
				players.append(player)
			
			for scheme_id in deception_schemes:
				var scheme = active_schemes[scheme_id]
				for detector in players:
					if detector != scheme.creator:
						// High chance to detect deception in dimension 9
						if randf() < 0.4:
							// Success - scheme detected
							if not detector in scheme.discovered_by:
								scheme.discovered_by.append(detector)
								
								// Record discovery
								if not scheme_discoveries.has(detector):
									scheme_discoveries[detector] = []
								scheme_discoveries[detector].append(scheme_id)
								
								// Create comment
								if word_comment_system:
									var comment_text = "JUDGMENT REVEALS: " + detector + " has discovered " + scheme.creator + "'s deception scheme"
									word_comment_system.add_comment("judgment_detection_" + scheme_id, comment_text, word_comment_system.CommentType.OBSERVATION)
								
								// Emit signal
								emit_signal("scheme_discovered", scheme_id, detector)

func _on_word_processed(word, power, source_player):
	// Analyze word for potential schemes
	analyze_word_for_schemes(word, source_player)
	
	// Check if word is a scheme command
	var scheme_result = parse_scheme_command(word, source_player)
	
	if scheme_result and scheme_result.success:
		// Scheme command succeeded
		return
	
	// Check if word is a counter scheme command
	var counter_result = parse_counter_scheme_command(word, source_player)
	
	if counter_result and counter_result.success:
		// Counter scheme command succeeded
		return
	
	// Check for automatic scheme activation in certain dimensions
	var current_dimension = turn_system.current_dimension if turn_system else 1
	
	// In dimension 11, schemes may activate automatically with consciousness words
	if current_dimension == 11:
		var consciousness_keywords = ["aware", "conscious", "realize", "understand", "comprehend", "sentient", "cognizant"]
		
		for keyword in consciousness_keywords:
			if word.to_lower().find(keyword) >= 0 and player_schemes.has(source_player):
				// Get player's inactive schemes
				var inactive_schemes = []
				for scheme_id in player_schemes[source_player]:
					if active_schemes.has(scheme_id) and not active_schemes[scheme_id].activated:
						inactive_schemes.append(scheme_id)
				
				if inactive_schemes.size() > 0:
					// Randomly select one to activate
					var random_scheme = inactive_schemes[randi() % inactive_schemes.size()]
					activate_scheme(random_scheme)
					
					// Add comment
					if word_comment_system:
						word_comment_system.add_comment("auto_activate_" + random_scheme, 
							"CONSCIOUS ACTIVATION: " + word + " has triggered the activation of a scheme in Dimension 11",
							word_comment_system.CommentType.OBSERVATION)
				
				break

# ----- PUBLIC API -----

func get_active_schemes():
	return active_schemes

func get_player_active_schemes(player_name):
	var result = []
	
	if player_schemes.has(player_name):
		for scheme_id in player_schemes[player_name]:
			if active_schemes.has(scheme_id):
				result.append(active_schemes[scheme_id])
	
	return result

func get_schemes_targeting_player(player_name):
	var result = []
	
	if scheme_targets.has(player_name):
		for scheme_id in scheme_targets[player_name]:
			if active_schemes.has(scheme_id):
				result.append(active_schemes[scheme_id])
	
	return result

func get_discovered_schemes(player_name):
	var result = []
	
	if scheme_discoveries.has(player_name):
		for scheme_id in scheme_discoveries[player_name]:
			if active_schemes.has(scheme_id):
				result.append(active_schemes[scheme_id])
	
	return result

func get_player_alliances(player_name):
	var result = []
	
	if scheme_alliances.has(player_name):
		for ally in scheme_alliances[player_name]:
			result.append({
				"player": ally,
				"alliance": scheme_alliances[player_name][ally]
			})
	
	return result

func check_scheme_command(text, source_player):
	// Check if text is a scheme command
	var scheme_result = parse_scheme_command(text, source_player)
	
	if scheme_result and scheme_result.success:
		return scheme_result
	
	// Check if text is a counter scheme command
	var counter_result = parse_counter_scheme_command(text, source_player)
	
	if counter_result and counter_result.success:
		return counter_result
	
	return null