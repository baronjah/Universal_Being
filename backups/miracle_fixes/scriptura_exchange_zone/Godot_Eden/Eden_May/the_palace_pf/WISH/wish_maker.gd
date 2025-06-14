extends Node

# Wish Maker System for Eden_May Game
# Integrates with Gemini API and token management

class_name WishMaker

# API connections
var gemini_api_connection = null
var claude_connection = null
var api_override = null  # Can be "gemini" or "claude" to force a specific API

# Token management
var token_balance = 2000000  # Default tokens (2M per $1)
var token_cost_per_wish = 100
var token_reward_per_win = 250
var minimum_token_threshold = 50

# Game state
var active_wishes = []
var wish_history = []
var current_turn = 8
var turn_multipliers = {
	8: 1.0,   # Current turn
	9: 1.5,   # Game Creation
	10: 2.0,  # Integration
	11: 3.0,  # Embodiment
	12: 5.0   # Transcendence
}

# Signals
signal wish_granted(wish_text, result)
signal token_balance_changed(new_balance)
signal wish_failed(wish_text, reason)

func _init():
	print("Wish Maker system initialized")
	initialize_api_connections()

func initialize_api_connections():
	# Initialize Gemini API connection
	gemini_api_connection = GeminiConnection.new()
	print("Gemini API connection established")
	
	# Initialize Claude connection if not already connected
	claude_connection = ClaudeConnection.new()
	print("Claude connection established")

func make_wish(wish_text, token_amount=token_cost_per_wish):
	print("Processing wish: " + wish_text)
	
	# Validate wish
	if wish_text.strip_edges() == "":
		emit_signal("wish_failed", wish_text, "Wish cannot be empty")
		return false
	
	# Check minimum token threshold
	if token_amount < minimum_token_threshold:
		emit_signal("wish_failed", wish_text, "Token amount below minimum threshold")
		return false
	
	# Check if user has enough tokens
	if token_amount > token_balance:
		emit_signal("wish_failed", wish_text, "Insufficient token balance")
		return false
	
	# Deduct tokens
	token_balance -= token_amount
	emit_signal("token_balance_changed", token_balance)
	
	# Process through appropriate API based on wish content
	var api_choice = determine_api_for_wish(wish_text)
	var result = process_wish_with_api(wish_text, api_choice, token_amount)
	
	# Record wish
	var wish_record = {
		"text": wish_text,
		"tokens": token_amount,
		"api": api_choice,
		"turn": current_turn,
		"timestamp": OS.get_unix_time(),
		"result": result.success,
		"response": result.response
	}
	
	active_wishes.append(wish_record)
	wish_history.append(wish_record)
	
	# Check if wish succeeded
	if result.success:
		# Award bonus tokens based on current turn
		var reward = calculate_reward(token_amount)
		token_balance += reward
		emit_signal("token_balance_changed", token_balance)
		
		emit_signal("wish_granted", wish_text, result.response)
		return true
	else:
		emit_signal("wish_failed", wish_text, result.error)
		return false

func determine_api_for_wish(wish_text):
	# Check if API is overridden
	if api_override:
		return api_override

	# Analyze wish to determine best API to handle it
	wish_text = wish_text.to_lower()

	if "gemini" in wish_text or "google" in wish_text:
		return "gemini"
	elif "claude" in wish_text:
		return "claude"
	else:
		# Default based on content analysis
		var data_related_terms = ["data", "search", "information", "retrieve", "facts"]
		var creative_terms = ["create", "imagine", "design", "story", "generate"]

		var data_score = 0
		var creative_score = 0

		for term in data_related_terms:
			if term in wish_text:
				data_score += 1

		for term in creative_terms:
			if term in wish_text:
				creative_score += 1

		return "gemini" if data_score > creative_score else "claude"

func process_wish_with_api(wish_text, api_choice, token_amount):
	match api_choice:
		"gemini":
			return process_with_gemini(wish_text, token_amount)
		"claude":
			return process_with_claude(wish_text, token_amount)
		_:
			return process_with_gemini(wish_text, token_amount)

func process_with_gemini(wish_text, token_amount):
	# Simulate Gemini API processing
	print("Processing with Gemini API: " + wish_text)
	
	# Check if Gemini connection is active
	if not gemini_api_connection.is_connected:
		return {
			"success": false,
			"error": "Gemini API connection not available",
			"response": ""
		}
	
	# Simulate API call (in real implementation, would call actual API)
	var success_chance = min(0.7 + (token_amount / token_balance) * 0.3, 0.95)
	var success = randf() < success_chance
	
	if success:
		# Simulate successful response
		return {
			"success": true,
			"error": "",
			"response": "Wish processed through Gemini API successfully. Data retrieved and analyzed."
		}
	else:
		# Simulate failure
		return {
			"success": false,
			"error": "Gemini API processing failed - insufficient specificity or unsupported request",
			"response": ""
		}

func process_with_claude(wish_text, token_amount):
	print("Processing with Claude: " + wish_text)
	
	# Check if Claude connection is active
	if not claude_connection.is_connected:
		return {
			"success": false,
			"error": "Claude connection not available",
			"response": ""
		}
	
	# Simulate Claude processing
	var success_chance = min(0.8 + (token_amount / token_balance) * 0.2, 0.95)
	var success = randf() < success_chance
	
	if success:
		# Simulate successful response
		return {
			"success": true,
			"error": "",
			"response": "Wish processed through Claude successfully. Creative elements generated and integrated."
		}
	else:
		# Simulate failure
		return {
			"success": false,
			"error": "Claude processing failed - request may be too ambiguous or contradictory",
			"response": ""
		}

func calculate_reward(token_amount):
	# Calculate token reward based on turn multiplier
	var multiplier = turn_multipliers.get(current_turn, 1.0)
	var base_reward = token_reward_per_win
	return int(base_reward * multiplier)

func set_turn(turn_number):
	if turn_number >= 1 and turn_number <= 12:
		current_turn = turn_number
		print("Wish Maker updated to Turn " + str(current_turn))
		return true
	return false

func get_token_balance():
	return token_balance

func add_tokens(amount):
	if amount > 0:
		token_balance += amount
		emit_signal("token_balance_changed", token_balance)
		return true
	return false

func set_minimum_threshold(threshold):
	if threshold > 0:
		minimum_token_threshold = threshold
		return true
	return false

func get_active_wishes():
	return active_wishes

func get_wish_history():
	return wish_history

func clear_fulfilled_wishes():
	var fulfilled = []
	var still_active = []
	
	for wish in active_wishes:
		if wish.result:
			fulfilled.append(wish)
		else:
			still_active.append(wish)
	
	active_wishes = still_active
	return fulfilled

# API Connection Classes
class GeminiConnection:
	var is_connected = true
	var api_key = ""
	
	func set_api_key(key):
		api_key = key
		return true
		
	func is_valid():
		return api_key != ""

class ClaudeConnection:
	var is_connected = true
	var api_key = ""
	
	func set_api_key(key):
		api_key = key
		return true
		
	func is_valid():
		return api_key != ""