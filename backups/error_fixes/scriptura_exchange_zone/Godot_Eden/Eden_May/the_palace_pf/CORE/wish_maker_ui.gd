extends Control

# Wish Maker UI for Eden_May Game
# Provides interface for making wishes and managing tokens

# References to other systems
var wish_maker = null
var eden_core = null

# UI elements
onready var token_display = $TokenPanel/TokenDisplay
onready var wish_input = $WishPanel/WishInput
onready var token_slider = $WishPanel/TokenSlider
onready var token_value = $WishPanel/TokenValue
onready var wish_button = $WishPanel/WishButton
onready var result_text = $ResultPanel/ResultText
onready var history_list = $HistoryPanel/ScrollContainer/HistoryList
onready var api_indicator = $WishPanel/APIIndicator

# Base token values
var min_tokens = 50
var max_tokens = 10000
var current_token_value = 100

func _ready():
	initialize_connections()
	initialize_ui()
	update_token_display()
	
	# Connect signals
	token_slider.connect("value_changed", self, "_on_token_slider_changed")
	wish_button.connect("pressed", self, "_on_wish_button_pressed")
	wish_input.connect("text_changed", self, "_on_wish_text_changed")
	
	if wish_maker:
		wish_maker.connect("wish_granted", self, "_on_wish_granted")
		wish_maker.connect("wish_failed", self, "_on_wish_failed")
		wish_maker.connect("token_balance_changed", self, "_on_token_balance_changed")

func initialize_connections():
	# Get reference to WishMaker
	wish_maker = get_node_or_null("../WishMaker")
	if not wish_maker:
		wish_maker = get_node_or_null("/root/EdenMayGame/WishMaker")
	
	# If still not found, create it
	if not wish_maker:
		wish_maker = WishMaker.new()
		wish_maker.name = "WishMaker"
		get_parent().add_child(wish_maker)
	
	# Get reference to EdenCore
	eden_core = get_node_or_null("../EdenCore")
	if not eden_core:
		eden_core = get_node_or_null("/root/EdenMayGame/EdenCore")
	
	print("Wish Maker UI initialized")

func initialize_ui():
	# Set up token slider
	token_slider.min_value = min_tokens
	token_slider.max_value = max_tokens
	token_slider.value = current_token_value
	
	# Update token value display
	token_value.text = str(current_token_value)
	
	# Clear result text
	result_text.clear()
	result_text.append_bbcode("[b]Wish Results:[/b]\n")
	result_text.append_bbcode("Enter a wish and set token amount to begin")
	
	# Clear history list
	history_list.clear()
	
	# Initialize API indicator
	api_indicator.text = "API: Auto-select"
	
	# Update history
	update_history_display()

func update_token_display():
	if wish_maker:
		token_display.text = "Current Token Balance: " + str(wish_maker.get_token_balance())

func update_history_display():
	if not wish_maker:
		return
		
	history_list.clear()
	var wish_history = wish_maker.get_wish_history()
	
	if wish_history.size() == 0:
		history_list.append_bbcode("No wish history yet")
		return
	
	history_list.append_bbcode("[b]Wish History:[/b]\n")
	
	# Display most recent wishes first
	for i in range(wish_history.size() - 1, -1, -1):
		var wish = wish_history[i]
		var success_indicator = "[color=green]✓[/color]" if wish.result else "[color=red]✗[/color]"
		
		history_list.append_bbcode(success_indicator + " [b]" + wish.text.substr(0, 30) + 
			("..." if wish.text.length() > 30 else "") + "[/b]\n")
		history_list.append_bbcode("    API: " + wish.api + " | Tokens: " + str(wish.tokens) + 
			" | Turn: " + str(wish.turn) + "\n")
		
		# Limit to most recent 10 wishes
		if i < wish_history.size() - 10:
			break

func _on_token_slider_changed(value):
	current_token_value = int(value)
	token_value.text = str(current_token_value)
	
	# Update indicator color based on token amount
	if current_token_value < 100:
		token_value.modulate = Color(1, 0.5, 0.5)  # Red for low values
	elif current_token_value > 1000:
		token_value.modulate = Color(0.5, 1, 0.5)  # Green for high values
	else:
		token_value.modulate = Color(1, 1, 1)  # Default white

func _on_wish_text_changed(new_text):
	# Update API indicator based on wish text
	if wish_maker:
		var api = wish_maker.determine_api_for_wish(new_text)
		api_indicator.text = "API: " + api.capitalize()
		
		# Update color based on API
		if api == "gemini":
			api_indicator.modulate = Color(0.2, 0.7, 1.0)  # Blue for Gemini
		else:
			api_indicator.modulate = Color(0.7, 0.3, 0.7)  # Purple for Claude

func _on_wish_button_pressed():
	var wish_text = wish_input.text.strip_edges()
	
	if wish_text == "":
		_show_error("Please enter a wish")
		return
	
	if not wish_maker:
		_show_error("Wish Maker system not available")
		return
	
	# Disable button while processing
	wish_button.disabled = true
	
	# Make the wish
	var success = wish_maker.make_wish(wish_text, current_token_value)
	
	# Re-enable button
	wish_button.disabled = false
	
	# Clear input if successful
	if success:
		wish_input.text = ""

func _on_wish_granted(wish_text, result):
	result_text.clear()
	result_text.append_bbcode("[b]Wish Granted![/b]\n")
	result_text.append_bbcode("[color=green]" + wish_text + "[/color]\n\n")
	result_text.append_bbcode("[b]Result:[/b]\n")
	result_text.append_bbcode(result + "\n")
	
	# Update token display and history
	update_token_display()
	update_history_display()
	
	# Show success animation
	_play_success_animation()

func _on_wish_failed(wish_text, reason):
	result_text.clear()
	result_text.append_bbcode("[b]Wish Failed[/b]\n")
	result_text.append_bbcode("[color=red]" + wish_text + "[/color]\n\n")
	result_text.append_bbcode("[b]Reason:[/b]\n")
	result_text.append_bbcode(reason + "\n")
	
	# Update token display and history
	update_token_display()
	update_history_display()
	
	# Show failure animation
	_play_failure_animation()

func _on_token_balance_changed(new_balance):
	update_token_display()

func _show_error(message):
	result_text.clear()
	result_text.append_bbcode("[b]Error[/b]\n")
	result_text.append_bbcode("[color=red]" + message + "[/color]")

func _play_success_animation():
	# Simple animation for success
	$AnimationPlayer.play("success_flash")

func _play_failure_animation():
	# Simple animation for failure
	$AnimationPlayer.play("failure_flash")

func _on_add_tokens_pressed():
	if wish_maker:
		var added = wish_maker.add_tokens(1000)
		if added:
			update_token_display()
			result_text.clear()
			result_text.append_bbcode("[b]Tokens Added[/b]\n")
			result_text.append_bbcode("Added 1000 tokens to your balance")

func _on_clear_history_pressed():
	if wish_maker:
		wish_maker.clear_fulfilled_wishes()
		update_history_display()

func _on_auto_wish_toggled(button_pressed):
	$WishPanel/AutoWishTimer.paused = !button_pressed
	
	if button_pressed:
		result_text.clear()
		result_text.append_bbcode("[b]Auto-Wish Activated[/b]\n")
		result_text.append_bbcode("Wishes will be made automatically every 10 seconds")
	else:
		result_text.append_bbcode("[b]Auto-Wish Deactivated[/b]\n")

func _on_auto_wish_timer_timeout():
	if not $WishPanel/AutoWishCheck.pressed or not wish_maker:
		return
		
	# Generate a random wish
	var wishes = [
		"Show me data about token efficiency",
		"Create a game level using turn patterns",
		"Generate information for Turn " + str(wish_maker.current_turn),
		"Help me optimize my token usage",
		"Show token performance statistics",
		"Create a visualization of my wish history",
		"Generate a random game concept",
		"Analyze pattern effectiveness in Turn " + str(wish_maker.current_turn)
	]
	
	var random_wish = wishes[randi() % wishes.size()]
	var random_tokens = min_tokens + randi() % (max_tokens - min_tokens)
	
	# Update UI
	wish_input.text = random_wish
	token_slider.value = random_tokens
	
	# Make wish
	wish_maker.make_wish(random_wish, random_tokens)