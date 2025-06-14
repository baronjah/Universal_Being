extends Node

# JSH Terminal Demo - Entry point for the JSH Terminal Visualizer System
# Works with LUMINUS CORE to provide advanced terminal visualization

# Initialize dependencies
var terminal_visualizer = null
var terminal_output = ""
var current_dimension = 3
var current_mode = "bitcoin"  # Options: demo, wow, bitcoin, wildstar

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize visualizer
	terminal_visualizer = preload("res://jsh_terminal_visualizer.gd").new()
	add_child(terminal_visualizer)
	
	# Connect signals
	terminal_visualizer.frame_rendered.connect(_on_frame_rendered)
	
	# Set up terminal size
	terminal_visualizer.width = 80
	terminal_visualizer.height = 25
	
	# Create scene based on selected mode
	_setup_visualization_mode()
	
	# Start rendering
	terminal_visualizer.render_frame()
	
	# Print startup message
	print("JSH Terminal Demo started in %s mode" % current_mode)
	print("Use dimension_change(1-12) to change dimensions")
	print("Use change_mode(mode) to change visualization mode")

# Set up the visualization based on selected mode
func _setup_visualization_mode():
	match current_mode:
		"demo":
			terminal_visualizer.create_demo_scene()
		"wow":
			terminal_visualizer.create_wow_interface()
		"bitcoin":
			terminal_visualizer.create_bitcoin_visualization()
		"wildstar":
			terminal_visualizer.create_wildstar_visualization()
		_:
			terminal_visualizer.create_demo_scene()

# Handle frame rendering
func _on_frame_rendered(frame_data):
	terminal_output = frame_data.text
	
	# Output to console (in a real system, this would go to the terminal)
	_print_to_terminal(terminal_output)

# Print to terminal (simplified for demo)
func _print_to_terminal(text):
	# In a real implementation, this would interface with the actual terminal
	# For now, we'll just print to the Godot console
	if OS.has_feature("editor"):
		print("Frame rendered to terminal (%d chars)" % text.length())
	else:
		# When running as standalone, actually try to print to console
		print(text)

# Change the current dimension (1-12)
func dimension_change(dimension):
	dimension = clamp(dimension, 1, 12)
	current_dimension = dimension
	
	# Update visualizer
	terminal_visualizer.set_dimension(dimension)
	
	# Render a new frame
	terminal_visualizer.render_frame()
	
	return "Dimension changed to %d" % dimension

# Change visualization mode
func change_mode(mode):
	if mode in ["demo", "wow", "bitcoin", "wildstar"]:
		current_mode = mode
		
		# Clear existing models
		for i in range(terminal_visualizer._models.size() - 1, -1, -1):
			terminal_visualizer.remove_model(i)
		
		# Set up new mode
		_setup_visualization_mode()
		
		return "Visualization mode changed to %s" % mode
	else:
		return "Invalid mode. Use demo, wow, bitcoin, or wildstar"

# Run Bitcoin time machine simulation
func run_bitcoin_simulation(amount=300):
	if current_mode != "bitcoin":
		change_mode("bitcoin")
	
	# Display time travel message
	var message = "Time traveling to 2013 with $%d investment..." % amount
	print(message)
	
	# Calculate returns
	var btc_amount = amount / 300.0 # $300 per BTC in 2013
	var current_value = btc_amount * 30000.0 # Approximate 2023 value
	var roi = (current_value / amount) * 100
	
	# Wait a bit
	await get_tree().create_timer(2.0).timeout
	
	# Show results
	var result = """
Time Travel Investment Results:
------------------------------
Initial Investment: $%d
BTC Purchased: %.4f BTC
Current Value: $%.2f
Return on Investment: %.2f%%
	""" % [amount, btc_amount, current_value, roi]
	
	print(result)
	return result

# Run Wildstar nostalgia mode
func run_wildstar_nostalgia():
	if current_mode != "wildstar":
		change_mode("wildstar")
	
	# Show Wildstar nostalgia message
	var message = "Traveling back to Wildstar's prime in 2014..."
	print(message)
	
	# Wait a bit
	await get_tree().create_timer(2.0).timeout
	
	# Show nostalgic message
	var result = """
Wildstar Nostalgia Trip:
----------------------
WELCOME, CUPCAKE! 
Server: Pergo (PvP)
Active Players: 1.5 million
Current Event: Strain Ultradrop
Housing System: REVOLUTIONARY
Combat Style: Action-Combat with Telegraphs

"Those Dominion folks didn't know what hit 'em!"
	"""
	
	print(result)
	return result

# Run WoW classic experience
func run_wow_classic():
	if current_mode != "wow":
		change_mode("wow")
	
	# Show WoW message
	var message = "Logging into World of Warcraft circa 2004..."
	print(message)
	
	# Wait a bit
	await get_tree().create_timer(2.0).timeout
	
	# Show classic message
	var result = """
World of Warcraft Classic:
------------------------
Server: Blackrock (PvP)
Level 60 Shaman
Location: The Barrens
Current Activity: Warsong Gulch
Guild: <Thunder Bluff Steakhouse>
Achievement: Grand Marshal grind (week 6)

"Lok'tar Ogar! For the Horde!"
	"""
	
	print(result)
	return result

# Interface with LUMINUS CORE
func connect_to_luminus_core(api_key=""):
	var connection_message = "Connecting to LUMINUS CORE..."
	print(connection_message)
	
	# Simulate connection
	await get_tree().create_timer(1.5).timeout
	
	var result = """
LUMINUS CORE Connection:
---------------------
Status: Connected
API Version: 7.3.14
Bridge Type: Terminal Visualization
Dimension Access: 1-12
Word Database: Synchronized
Wish Processing: Enabled

Type "manifest [word]" to visualize words in the terminal
	"""
	
	print(result)
	return result

# Manifest a word in the terminal (connects to word visualization)
func manifest_word(word):
	var message = "Manifesting word: %s" % word
	print(message)
	
	# Calculate word power based on length and characters
	var power = 0
	for c in word:
		power += c.unicode_at(0) % 10
	
	power = power / 10.0
	
	# Create ASCII art manifestation based on word
	var char_mapping = {
		"a": "∆", "b": "β", "c": "¢", "d": "∂", "e": "ε", 
		"f": "ƒ", "g": "g", "h": "η", "i": "∞", "j": "∫", 
		"k": "κ", "l": "λ", "m": "µ", "n": "η", "o": "ø", 
		"p": "π", "q": "q", "r": "®", "s": "∑", "t": "τ", 
		"u": "υ", "v": "√", "w": "ω", "x": "×", "y": "¥", "z": "ζ"
	}
	
	var manifestation = ""
	manifestation += "Word Power: %.1f\n" % power
	manifestation += " " + "─".repeat(word.length() + 2) + "\n"
	
	var symbols = ""
	for c in word.to_lower():
		if char_mapping.has(c):
			symbols += char_mapping[c]
		else:
			symbols += c
	
	manifestation += "( " + symbols + " )\n"
	manifestation += " " + "─".repeat(word.length() + 2) + "\n"
	
	# Create visualization
	var size = 0.3 + power * 0.2
	var color = Color(0.2 + power * 0.8, 0.5, 1.0)
	
	# Add to 3D view
	var model_index = terminal_visualizer.create_ascii_model(manifestation, size, color)
	terminal_visualizer.translate_model(model_index, Vector3(0, 0, 0))
	
	# Render frame
	terminal_visualizer.render_frame()
	
	return "Word manifested with power %.1f" % power

# Process coins and generate bitcoin visualization
func process_coins(coins="BTC"):
	if current_mode != "bitcoin":
		change_mode("bitcoin")
	
	var coin_list = coins.split(",")
	var result = "Processing coin data for: %s\n" % coins
	
	# Generate mock data
	for coin in coin_list:
		coin = coin.strip_edges()
		var price = 0
		var change = 0
		
		match coin.to_upper():
			"BTC":
				price = 300 + randf_range(-20, 20)
				change = randf_range(-5, 5)
			"ETH":
				price = 10 + randf_range(-2, 2)
				change = randf_range(-8, 8)
			"DOGE":
				price = 0.0002 + randf_range(-0.0001, 0.0001)
				change = randf_range(-10, 10)
			_:
				price = randf_range(1, 1000)
				change = randf_range(-15, 15)
		
		result += "%s: $%.2f (%+.2f%%)\n" % [coin, price, change]
	
	print(result)
	return result

# Activate the terminal's 12-turn system
func activate_turn_system():
	var result = "Activating 12-Turn Dimensional System...\n"
	
	# Dimension descriptions
	var dimensions = [
		"1D: Point - The beginning of all things",
		"2D: Line - Basic structures take shape",
		"3D: Space - Systems begin interacting",
		"4D: Time - Awareness arises within systems",
		"5D: Consciousness - Recognition of self and other",
		"6D: Connection - Understanding connections between all elements",
		"7D: Creation - Bringing forth creation from thought",
		"8D: Network - Building relationships between created elements",
		"9D: Harmony - Balance between all created elements",
		"10D: Unity - All becomes one",
		"11D: Transcendence - Rising beyond initial limitations",
		"12D: Beyond - Moving beyond the current cycle"
	]
	
	result += "\nAvailable Dimensions:\n"
	for i in range(dimensions.size()):
		result += "%d: %s\n" % [i+1, dimensions[i]]
	
	result += "\nCurrent Dimension: %d\n" % current_dimension
	result += "Use dimension_change(N) to switch dimensions\n"
	
	print(result)
	return result