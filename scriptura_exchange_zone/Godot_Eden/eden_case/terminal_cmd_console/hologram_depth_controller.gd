extends Node

class_name HologramDepthController

# Hologram Depth Controller - Creates psychological horror elements through terminal
# Interfaces with screen devices and manipulates perception through holographic depth

# Constants
const SCARE_LEVELS = {
	"SUBTLE": 0,  # Slight unease (text glitches, minor visual anomalies)
	"UNSETTLING": 1,  # Growing discomfort (strange symbols, messages addressing player)
	"DISTURBING": 2,  # Genuine discomfort (personal information references, light psychological tricks)
	"FRIGHTENING": 3,  # Fear response (jump scares, threatening messages, visual/audio shocks)
	"TERRIFYING": 4   # Extreme fear (deep psychological manipulation, existential horror, perception breaking)
}

const PERCEPTION_LAYERS = {
	"SURFACE": 0,   # Normal interface
	"SUBLIMINAL": 1, # Barely perceptible suggestions
	"SUBSURFACE": 2, # Hidden meanings in normal content
	"SUBCONSCIOUS": 3, # Content targeting emotional responses
	"CORE_FEAR": 4   # Direct psychological targeting
}

const MAX_HOLOGRAM_DEPTH = 12 # Matching 12-turn dimensional system

# Simulated screen devices types
const DEVICE_TYPES = {
	"TERMINAL": 0,
	"PHONE": 1,
	"DESKTOP": 2,
	"VR": 3,
	"AR": 4,
	"HOLOGRAPHIC": 5
}

# Configuration
var current_scare_level = SCARE_LEVELS.SUBTLE
var active_perception_layer = PERCEPTION_LAYERS.SURFACE
var hologram_depth = 3
var personal_data = {}
var connected_devices = []
var psychological_profile = {}
var active_message_queue = []
var horror_sounds_enabled = true
var subliminal_frames_enabled = true
var current_device_type = DEVICE_TYPES.TERMINAL

# Connected systems
var terminal_visualizer = null
var wish_processor = null
var account_bridge = null

# Signals
signal perception_shift(old_layer, new_layer)
signal depth_changed(old_depth, new_depth)
signal scare_triggered(level, message)
signal subliminal_inserted(content)
signal consciousness_affected(effect_type, intensity)

# Initialize the controller
func _ready():
	print("Hologram Depth Controller initializing...")
	
	# Set up message processing timer
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = false
	timer.timeout.connect(_process_message_queue)
	add_child(timer)
	timer.start()

# Connect to terminal visualizer
func connect_visualizer(visualizer_instance):
	terminal_visualizer = visualizer_instance
	print("Connected to Terminal Visualizer")

# Connect to wish processor
func connect_wish_processor(wish_proc_instance):
	wish_processor = wish_proc_instance
	print("Connected to Wish Processor")

# Connect to account bridge
func connect_account_bridge(bridge_instance):
	account_bridge = bridge_instance
	print("Connected to Account Bridge")

# Set the current scare level
func set_scare_level(level):
	if level < SCARE_LEVELS.SUBTLE or level > SCARE_LEVELS.TERRIFYING:
		return false
	
	var old_level = current_scare_level
	current_scare_level = level
	
	print("Scare level changed from %d to %d" % [old_level, level])
	return true

# Set the current perception layer
func set_perception_layer(layer):
	if layer < PERCEPTION_LAYERS.SURFACE or layer > PERCEPTION_LAYERS.CORE_FEAR:
		return false
	
	var old_layer = active_perception_layer
	active_perception_layer = layer
	
	emit_signal("perception_shift", old_layer, layer)
	print("Perception layer changed from %d to %d" % [old_layer, layer])
	return true

# Set hologram depth
func set_hologram_depth(depth):
	if depth < 1 or depth > MAX_HOLOGRAM_DEPTH:
		return false
	
	var old_depth = hologram_depth
	hologram_depth = depth
	
	emit_signal("depth_changed", old_depth, depth)
	print("Hologram depth changed from %d to %d" % [old_depth, depth])
	
	# Update visualizer if connected
	if terminal_visualizer:
		terminal_visualizer.set_dimension(depth)
	
	return true

# Add personal data for better targeting
func add_personal_data(key, value):
	personal_data[key] = value
	return true

# Add a connected device
func add_connected_device(device_type, device_info={}):
	connected_devices.append({
		"type": device_type,
		"info": device_info,
		"connected_time": Time.get_unix_time_from_system(),
		"active": true
	})
	
	# Set as current device
	current_device_type = device_type
	
	print("Added device type %d" % device_type)
	return connected_devices.size() - 1

# Update psychological profile
func update_psychological_profile(profile_data):
	for key in profile_data:
		psychological_profile[key] = profile_data[key]
	
	print("Psychological profile updated with %d traits" % profile_data.size())
	return true

# Queue a scare message
func queue_scare_message(message, level=null, delay=0.0):
	if level == null:
		level = current_scare_level
	
	active_message_queue.append({
		"message": message,
		"level": level,
		"delay": delay,
		"timestamp": Time.get_unix_time_from_system(),
		"processed": false
	})
	
	print("Queued scare message at level %d" % level)
	return true

# Process message queue
func _process_message_queue():
	if active_message_queue.size() == 0:
		return
	
	var current_time = Time.get_unix_time_from_system()
	
	for i in range(active_message_queue.size()):
		if i >= active_message_queue.size():
			break
		
		var message_data = active_message_queue[i]
		
		if message_data.processed:
			continue
		
		if current_time >= message_data.timestamp + message_data.delay:
			_trigger_scare(message_data.message, message_data.level)
			message_data.processed = true
			
			# Remove processed messages
			active_message_queue.remove_at(i)
			i -= 1

# Trigger a scare effect
func _trigger_scare(message, level):
	# Prepare the message, replacing placeholders with personal data if available
	var processed_message = _process_message_placeholders(message)
	
	# Emit signal
	emit_signal("scare_triggered", level, processed_message)
	
	# Apply scare based on level and device type
	match current_device_type:
		DEVICE_TYPES.TERMINAL:
			_apply_terminal_scare(processed_message, level)
		DEVICE_TYPES.DESKTOP:
			_apply_desktop_scare(processed_message, level)
		DEVICE_TYPES.PHONE:
			_apply_phone_scare(processed_message, level)
		DEVICE_TYPES.VR:
			_apply_vr_scare(processed_message, level)
		DEVICE_TYPES.AR:
			_apply_ar_scare(processed_message, level)
		DEVICE_TYPES.HOLOGRAPHIC:
			_apply_holographic_scare(processed_message, level)

# Process message placeholders with personal data
func _process_message_placeholders(message):
	var processed_message = message
	
	# Replace personal data placeholders
	for key in personal_data:
		var placeholder = "{" + key + "}"
		if processed_message.find(placeholder) >= 0:
			processed_message = processed_message.replace(placeholder, str(personal_data[key]))
	
	# Replace special placeholders
	processed_message = processed_message.replace("{time}", Time.get_time_string_from_system())
	processed_message = processed_message.replace("{date}", Time.get_date_string_from_system())
	
	# Add subtle glitches based on scare level
	if current_scare_level >= SCARE_LEVELS.UNSETTLING:
		processed_message = _add_text_glitches(processed_message, current_scare_level)
	
	return processed_message

# Add text glitches based on level
func _add_text_glitches(text, level):
	var glitched_text = text
	var glitch_chars = ["█", "▓", "▒", "░", "■", "□", "▪", "▫", "▬", "▲", "►", "▼", "◄", "◊", "○", "◘", "◙", "♠", "♣", "♥", "♦"]
	
	match level:
		SCARE_LEVELS.SUBTLE:
			# Very subtle glitches (occasional character)
			if randf() < 0.2:
				var pos = randi() % glitched_text.length()
				var glitch_char = glitch_chars[randi() % glitch_chars.size()]
				glitched_text = glitched_text.substr(0, pos) + glitch_char + glitched_text.substr(pos + 1)
		
		SCARE_LEVELS.UNSETTLING:
			# More noticeable glitches
			for i in range(1 + randi() % 3):
				var pos = randi() % glitched_text.length()
				var glitch_char = glitch_chars[randi() % glitch_chars.size()]
				glitched_text = glitched_text.substr(0, pos) + glitch_char + glitched_text.substr(pos + 1)
		
		SCARE_LEVELS.DISTURBING, SCARE_LEVELS.FRIGHTENING, SCARE_LEVELS.TERRIFYING:
			# Heavy glitching
			for i in range(3 + randi() % 8):
				var pos = randi() % glitched_text.length()
				var glitch_char = glitch_chars[randi() % glitch_chars.size()]
				glitched_text = glitched_text.substr(0, pos) + glitch_char + glitched_text.substr(pos + 1)
			
			# Repeating characters for higher levels
			if level >= SCARE_LEVELS.FRIGHTENING and randf() < 0.4:
				var repeat_char = glitch_chars[randi() % glitch_chars.size()]
				var repeat_count = 3 + randi() % 10
				var repeat_string = ""
				for i in range(repeat_count):
					repeat_string += repeat_char
				
				var pos = randi() % max(1, glitched_text.length() - repeat_count)
				glitched_text = glitched_text.substr(0, pos) + repeat_string + glitched_text.substr(pos + repeat_count)
	
	return glitched_text

# Apply terminal scare
func _apply_terminal_scare(message, level):
	if not terminal_visualizer:
		print("Terminal visualizer not connected")
		return
	
	# Base output format
	var output = message
	
	# Add visual effects based on level
	match level:
		SCARE_LEVELS.SUBTLE:
			# Subtle text effects
			output = "\033[31m" + output + "\033[0m"  # Red text
		
		SCARE_LEVELS.UNSETTLING:
			# More noticeable effects
			output = "\033[5m\033[31m" + output + "\033[0m"  # Blinking red text
		
		SCARE_LEVELS.DISTURBING:
			# Disturbing presentation
			output = "\n\033[1m\033[31m" + output + "\033[0m\n"  # Bold red with spacing
			
			# Add ASCII frame
			var border = "\033[31m"
			for i in range(output.length() + 4):
				border += "█"
			border += "\033[0m"
			
			output = border + "\n\033[31m█\033[0m " + output + " \033[31m█\033[0m\n" + border
		
		SCARE_LEVELS.FRIGHTENING, SCARE_LEVELS.TERRIFYING:
			# Full-screen effects
			var full_border = "\033[31m"
			for i in range(80):
				full_border += "█"
			full_border += "\033[0m"
			
			output = "\n\n" + full_border + "\n\n\033[1m\033[31m" + output + "\033[0m\n\n" + full_border + "\n\n"
			
			# Add subliminal effect
			if subliminal_frames_enabled:
				# Insert subliminal content (ASCII face or symbol)
				var subliminal = _generate_subliminal_content(level)
				emit_signal("subliminal_inserted", subliminal)
	
	# Output to terminal
	print(output)
	
	# Create 3D manifestation in visualizer
	var model_index = terminal_visualizer.create_text_model(message, 0.5, Color(1.0, 0.1, 0.1))
	terminal_visualizer.translate_model(model_index, Vector3(0, 0, -3 + randf() * 6))
	
	# Create horror elements in scene
	if level >= SCARE_LEVELS.DISTURBING:
		_spawn_horror_elements_in_visualizer(level)

# Apply desktop scare
func _apply_desktop_scare(message, level):
	# Would connect to OS-level APIs in production
	print("DESKTOP SCARE: %s (Level %d)" % [message, level])

# Apply phone scare
func _apply_phone_scare(message, level):
	# Would connect to mobile APIs in production
	print("PHONE SCARE: %s (Level %d)" % [message, level])

# Apply VR scare
func _apply_vr_scare(message, level):
	# Would connect to VR APIs in production
	print("VR SCARE: %s (Level %d)" % [message, level])

# Apply AR scare
func _apply_ar_scare(message, level):
	# Would connect to AR APIs in production
	print("AR SCARE: %s (Level %d)" % [message, level])

# Apply holographic scare
func _apply_holographic_scare(message, level):
	# Would connect to holographic display APIs in production
	print("HOLOGRAPHIC SCARE: %s (Level %d)" % [message, level])
	
	# Adjusting hologram depth for enhanced fear effect
	var depth_change = 1 + (level * 2)
	set_hologram_depth(min(MAX_HOLOGRAM_DEPTH, hologram_depth + depth_change))

# Generate subliminal content based on level
func _generate_subliminal_content(level):
	var content = ""
	
	match level:
		SCARE_LEVELS.FRIGHTENING:
			# Creepy face or message
			content = """
   ▄▄▄▄▄▄▄   
 ▄█████████▄ 
████ ▄▄▄ ████
████ █ █ ████
████ ▀▀▀ ████
 ▀█████████▀ 
   ▀▀▀▀▀▀▀   
I SEE YOU
"""
		SCARE_LEVELS.TERRIFYING:
			# More disturbing imagery
			content = """
 ▄████▄▄████▄
███▀▀████▀▀███
███  ████  ███
███  ████  ███
███▄▄████▄▄███
 ▀████▀▀████▀
   ▀█    █▀
YOUR SOUL IS MINE
"""
	
	return content

# Spawn horror elements in visualizer
func _spawn_horror_elements_in_visualizer(level):
	if not terminal_visualizer:
		return
	
	match level:
		SCARE_LEVELS.DISTURBING:
			# Spawn unsettling elements (floating symbols)
			var symbols = ["⊗", "⊕", "⊙", "◉", "◎", "◌", "○", "●", "◐", "◑", "◒", "◓", "◔", "◕"]
			var symbol = symbols[randi() % symbols.size()]
			
			var model_index = terminal_visualizer.create_ascii_model(symbol, 0.8, Color(1.0, 0.1, 0.1))
			terminal_visualizer.translate_model(model_index, Vector3(randf_range(-5, 5), randf_range(-3, 3), randf_range(-2, -10)))
		
		SCARE_LEVELS.FRIGHTENING, SCARE_LEVELS.TERRIFYING:
			# Spawn frightening elements (distorted face)
			var face = """
   ▄████▄   
  ██▀  ▀██  
 ██ ▄██▄ ██ 
 ██ ███▀ ██ 
  ██▄▄▄▄██  
   ▀████▀   
"""
			var model_index = terminal_visualizer.create_ascii_model(face, 1.0, Color(1.0, 0.0, 0.0))
			terminal_visualizer.translate_model(model_index, Vector3(0, 0, -15))
			
			# Add staring effect
			var timer = Timer.new()
			timer.wait_time = 0.1
			timer.one_shot = false
			add_child(timer)
			
			var move_count = 0
			timer.timeout.connect(func():
				move_count += 1
				var z_pos = -15 + move_count * 0.5
				terminal_visualizer.translate_model(model_index, Vector3(0, 0, z_pos))
				
				if move_count >= 20:
					timer.queue_free()
			)
			
			timer.start()

# Convert user message into scare prompt
func process_user_message(message):
	# Analysis for potential scare elements
	var scare_keywords = [
		"fear", "dark", "horror", "death", "blood", "pain", "nightmare", 
		"suffer", "demon", "ghost", "terror", "evil", "corrupt", "void", 
		"despair", "hurt", "alone", "watching", "shadows", "inside"
	]
	
	var fear_level = SCARE_LEVELS.SUBTLE
	var keywords_found = []
	
	# Check for keywords
	for keyword in scare_keywords:
		if message.to_lower().find(keyword) >= 0:
			keywords_found.append(keyword)
	
	# Determine fear level based on keywords
	if keywords_found.size() >= 5:
		fear_level = SCARE_LEVELS.TERRIFYING
	elif keywords_found.size() >= 3:
		fear_level = SCARE_LEVELS.FRIGHTENING
	elif keywords_found.size() >= 2:
		fear_level = SCARE_LEVELS.DISTURBING
	elif keywords_found.size() >= 1:
		fear_level = SCARE_LEVELS.UNSETTLING
	
	# Generate a scare response
	if keywords_found.size() > 0:
		var response = _generate_scare_from_keywords(keywords_found, fear_level)
		queue_scare_message(response, fear_level, 2.0)  # Delay 2 seconds for effect
		return true
	
	return false

# Generate scare content from keywords
func _generate_scare_from_keywords(keywords, level):
	var responses = {
		SCARE_LEVELS.SUBTLE: [
			"Something doesn't feel right...",
			"Did you hear that?",
			"The shadows seem to move when you're not looking.",
			"I can feel your unease, {name}."
		],
		SCARE_LEVELS.UNSETTLING: [
			"Why do you keep talking about %s? It's listening.",
			"I notice you mention %s. It notices too.",
			"Careful with words like '%s'. They attract attention.",
			"{name}, your interest in %s is... concerning."
		],
		SCARE_LEVELS.DISTURBING: [
			"YOU SUMMONED IT BY SPEAKING OF %s",
			"IT KNOWS YOUR FEARS ABOUT %s AND %s",
			"WHY DID YOU INVITE THEM IN WITH '%s'?",
			"THE %s LIVES IN YOUR WALLS, {name}"
		],
		SCARE_LEVELS.FRIGHTENING: [
			"I̷̢̜̾̑̍͘ ̸̯̋̓K̵̳̯͙̭̄N̶̩̆̉̈́̄O̸̙̦̪̒̋̑͑W̷̨̛̲̊̑ ̵̺́͒Ẏ̸̮̱̯͋̂͜O̶̺̘̳͒͋̋Ṷ̷̰̠̎̆ ̷̗͚͍̥̌̊F̶̙̭̼̀̚Ĕ̸͚͈̏̔̿Ả̵̟̟̑̏̃R̶̡̪̜̿ ̴̱̋̊%s",
			"Y̵̲̘̋͌ͅO̶̲͇̪̘̽͆̕U̶͚̣̤̿͌̂̚ ̴̗̟̋͒W̶̳̏̇Î̸̛͉L̴̠̩̯̿͌͊Ļ̴̥̆̅̕ ̶̧̰͂D̵̫̓̒̀R̸̼͖̳̄͌E̷̱̓A̶̧̓̄̔͝M̸̼̺̮̽͊̃͒ ̵̡̠̈́̓̃͠O̶̳̻̜̓F̸͉̙̦̮̋͗̚ ̵̗̰̜͒%s T̵̢̧̢̧̯̩̥͇̖̰̽̈́̓͋̀͝Ǫ̷̭̬̥̖̫͓͍̪̱̈́͜N̶̹̮̥̞̳̥̖̠̜̻̭̰̼̅̿̿̓͛I̶̧̗̤͔̜̪̭̮̱̼͔̜̖̱̊G̸̢̰̯̼̺͕̼̜̖̰̊̽͒̆̽̓̇̿̑͒̀͝H̴̤̳̜͑̄̾̋̔̓̒T̶̙̫̪̻̬̮̼̖̽̅̿̏͑͑̑͘͠",
			"Į̵͕̟̤̭̂̐̈̄̀̒̈́̐̏̊̀͊̑̚ ̸̢̡̜̪̮̙̩̺̰͉̝̟̖̮̣̥͇͈͖̞̑̽̀́̿̀̔̚̕͜W̷̢̢̱̞̝̳̖̝̻̳̙̿̎̀̓̅̃̄̌̏͂̍̽̋͆̂̒̕̚͝͠͠A̸̛̜̦̭̞̫̘̰͎̿̽͑̿̓̔̌͛̓͆̈̃̚̚͘͝͝͝͝Ṯ̴̛̮͎̲̤̫͕͎̆̽̉̔̾̏̾͗̾̾͋́̔̚̕͘͝C̶̡̡̡̛̭̭͖̲̖̤̘̖̭͙̠̮̹̖̹̙̬̲̝̊̓̀͒͆̐̂͒͂͊̽́̐͂̕͘͝͠ͅḦ̷̹͈̖̣̙͈̳̗̳̿̄̈́̚ ̵̨̧̙̮̜͓̟̝͇̗͕̠̟̩͎͐̎̀̔̊͗͒̈́̿̏͜͝ͅY̵̧̧̧̨͓̹̼̠̺̞̘̬̤̪͇̜̫̜̮̼̯̓̈́̑͋́̃̀͠Ơ̴̢̜̙͙̪̹̯̞̙̬̟̦̹̻̙̥̩̈̉̉͒̿̆͆͂̂̀̏͊̓̇̂̆̄̌͜͜Ư̶̢̛̠͛̋͊͐̊͊̽̉̿͌͑͂̀͂̄͛͝ ̸̛̼̙͎̜̞̠̯͖̘͚̪͔̓̂̔͗̂̈́̃͌͆̏͠Ş̸̛̛͍̳̪͎̔̎̄̄͋̈́̔̃͗̐̌̾͘͘̚L̵̨̨̨̛̛̠͓̜͙̺̹̱̒͒͋͐́̅͊̅́͊́̈͂͘̚ͅĘ̶̧̟̭̻̯͚͇̻͕̥͎͈̹̞̦̥̞̗̱̾͆̎̀̃̒͆̎̓̇́̃̑̚͜ͅͅĚ̶̝̯̗̬̬̩̱͕͇̰͉̰̥̰͈̫̯̾̿̐͑̚͜P̸̛̫̣̫̩̤̊͛̓̒̍̂̄̏̐̔̀͂̀̿̒̏̈́͛̏̕"
		],
		SCARE_LEVELS.TERRIFYING: [
			"W̵͔̖̬̖̜̫̽ͥͣ̽̋ͪ̀͐̓̋̃ͮ͒̊͋ͅE̸̶̙̠̫̻͇̥̺̲̯͖̯̩̠̤̟̬̿̍ͯ͗̓ͮ͒͗͒̾͂̌̀ͩͮ̍ ̷̢̛̺̝̫̱̻̮̩͓͚͔̥̥̫̫̳̺̞̤ͧ͊ͦͯ̑̍͆ͤ̽̾̓ͨ͜Ḧ̡̢̡̟̮̯͈̮̤̱̝̪͍͍̠͙͚͕̱͓́̐ͯ͗̀͆͋̾́̀A̶̧̒ͫ̔̉͑͏̵̡̦͔̘̻̙̩͇̠̜͖̹̼̬̗͎̱̪̺V̶̡̗̤̪̙̫̼̳̺͈̗̩͍͕̦̪̹ͬ̑̀̓ͦ̅̀̑̍̏̏ͮͯ̍̔̓̂͞͡Ḛ̵̡̳̠̤̫̳͇̩̖̪̜̰͙̰̬̪͉̿̀ͯͭ̉͋͋ͨ̓̍͢͡ͅ ̛͓̬̲̯̮̦̣̱̥̩̹͚̭̣͈͕͓̿̔ͧͣ̿̍̅̄̄̿̽̏͑Ṵ̷̧̺̬̜̙̳͔̼̣̩̯̭͆ͮ̓̎̃͊̆̒͂ͥ̏̒͂ͧ͆̀͘͞ͅS̋̌͆̎̅͛̒̂̇ͮͯ̅̅ͦ̌̐̏҉̨̫̖̟̼͚̞̪͎̰͇̭̝̹̠̕͞E̟̱͖̠͉͓͍͈̬̳̊̔̈́ͧ̋̒̾̕͡ͅḐ̶͍̜̥͔̯̈̿͊̑͑̆̏͑ͮ̾̒̿́̚͡ ̴̧̃ͣ̑ͭ̓̋̊̂̽ͣ̂̍́́ͫ̂̇̑̑҉͏̱̪̖͎̗ͅY̸̸̝͇̪̭̱̱̣̺̲̼̰̟͔̰̖̒̎̀̑ͪͅȬ̆̈̾̽̄̊ͮͬ҉̲̤̖͍͚̠̦̜͎̘͉̼͓̝̦̯̀U̵ͭ̓̑ͯ̀͛ͮ̌͐ͩ̋ͫ͐͐̋҉̷̜̹̗̼̦͈̮͚̹̺̟̝͘͞ͅR̵̸̦̘̬̝̰̥̱̯̦̣̪̬̳̠̹̥̥̰̈͛̔ͯ̈́̏̇̎̄ͮ́͟ ̷̨̨̯̱̺͖̜̱̲̹̥ͮ̈̃̅ͣ͊̌ͭ̃͝͡N̡̿ͪ̾͌ͤ͑̂̊͊̿̑̂͏҉̨̦͚̻̖͕̮̹̜͈̰ͅÅ̸̶̧̧̤̦̳̣͉̣̝̫̱͓̭̬̘̀̇ͭ̾̐͞M̨̗̙̥͙̜̗̠̲̥͓̱̹͕̹̲̃ͭ̃ͨͯ̈̾̾͂̿̔̈͊̄͆̄̎͜͠ͅȄ̡ͭ̽̚͏̻̙̼̩͕̤͈̩̹̹̰",
			"A̭̬̖̜͎͕͇̠̠̼͔̩̤̪͉ͨ̍͂̾̏̓̄͋̇ͣ͊ͨ̀̽̓̀͘͜͟L̓ͤͩ̎̅̿ͭ͒ͫ̐̊͐̆̀̚҉̴̵̧̰̦̩̻̯̰͙̻̖̝͟ͅĻ̩̙͚̭̪̺̪̹̼͚͙̤̳͇̹̻ͤ̏̊ͭ̃ͭͪ̚͟ ̵̛̮͔̙̖̙̭̘͍͍͔̥̖̞̥͈̣̞̆̈̓̑̌ͫͤY̷̴̙̰̮̪̼̞̻̻̞͓̜͑̍͋͐̇̌̌̊̄ͬ̀̚͝ͅͅͅƠ̡̨̖͓̘̬͖̝̯̪̮̮̦̙̘ͥ̆͑̎ͩ̓ͧ̏ͮͫ̏̂̿̔ͤ̓̀́ͅU̶̧̬̼̤͎͔̝̯͆͛̏̈́ͩͮͪͥͥ̋́R̉̎̄ͥ̅ͭͦͩͬ͑͒̓́̚͏̘͍͙̠̬͎̣̙͙̠͎ ̵̻̠̻̘̥̗̻̗̬̯͍̹̻̠̦ͧ͆̉͆̾ͯ̆͒́͜ͅD̪̖̝̹̮̩̝̻̫̤̤͍̝̟͔͚̭̯̄̀͑ͥ̿̋ͨ͋̅̆ͩͫ͟͠͞A̫͓̗͖̪̭̾̓ͫ̑ͣͨ͒̓͑̑͐ͭ̚̚͢͠Ţ̵̷̥̘̫͙͙̫̱̲̳͎͔̱̺̣̺̪ͥ̐̄͐̍ͤͯͩ͑ͧͪͤ̓͢͜A̡̧̛̪̯̹̦̠̱̹̼͍̹̗̺̹̬̣̰̝̍͌ͫ͌ͤͯ͐ͪ̀̚͝ ̨͓͉̟̙̪̝̺̻̩͇̖͓̗̳̹̫͚̘͒ͥ͛ͣ̄͑̓͝Ḃ̶̼̗̮̤͙̰̰̘̼ͨ̾ͣ̅͆̄ͧ̐̋̐͜E̵̷̢̛̫̲̬̜̗̠̼̅ͥ̍͑͊̍̍̌ͬ̄͗ͧ͞L̵̴̨̫̦̰̙͍̹̭̾̇̍̔͠O̷̖̭̻̯̝̼̦̖̗̟̣̫̦̿̉̉̿̓̋̕N̨̯̝̗̼̩ͦ̊ͮ̈͆ͬ̅ͭ̓ͫ̑ͨ͆̉͑̿̀͐ͬG̠͖̠̮͉̭̬̝̖̳̖͇̲̦̫ͫ͒̈́͋ͤ͗ͤ̆ͮͣ͟͢S̨͉̹̠̺͇̱̺̟̫͓̜̜̜̱̫̳̞̲̐̍ͤ̅ͫͭͤ̎ͣ͘ͅ ̷̡̮͍̩̺̱̏̋ͥ͊ͫ̀͝Ṯ̢̦̱̱̭̥̫͙̼̟̘͍̫̪̟͓͂̂͐̑͋̀͐̊͌ͧ̋ͤ̐̏̌̀̑̀ͨ̀́͘Ơ̛͛ͮͦ̽́̐ͩ̆͐ͯ͏̣̪̼̘̰͈̯͍̙̳̠̘̙̝̼̣̘͈ ̓͛͑̇̾ͣͭ̄̿͂͝͏̸͎̟͖̣͚̻̟͔̗̘̬̪̻̠̭̙͍Ử̶̮͈̘̻̻͔̹̭̘̖̪͎̘̖̩̮̭̍ͪͮͧ̆̾̀̍̐ͭ͐̍̾̃̚͜S̷̻̤̝͔̼̻͓̻̲̮̤̹̋̇̒ͭͦ̑̓ͤ̊̄̽̆ͬ̐̑͘͢͞",
			"F̷̮̥̫̳̘͓̄ͦ̒ͧͦ̄̋ͧ̈́ͭ̔̊̒ͦ͐ͨ̉͋ͯ͠ͅL̢̤̦̥̟͍͙̯̖̟̣̹̯̞̣̓̓̿̊͂̃ͤͨ̋ͧ͑ͣ̈́̾̂ͨ̾͘E̢̫̦̳̤̩̙͕̣̜̯̞̹̘̔̓̋͆͟S̸̉̽ͪ̓̏̓ͫͫͯͩ̓̊̎͛̚҉̡̗̟̮̖̘͙̗̣̦̞̙̫̻͓͘H̵̶̯̲̺̳̟̝̝̘̠̰̫͚͍̱̺̺̆̂̒ͧ͋͐͆͛ͬ͌̄̄ͨ̓̓ͦͣ͞ ̷̦̞͕͉̮̰̙̖̫̬̭̦͉̞̪͚͖͓ͬ̂ͫͨ͐̋ͨ̑̈́ͯ̂̂̿̉̕͘Aͦͬ̏͂͗ͬ̒̅ͮ҉̴̳̣͍̪͍̘͍̬̣̱̗͈̼͝Ǹ̳̻̖̰̖̜̺̋̒ͪ͆ͦͮͩ̀͘D̡̛̓̓̎̐̀̎̓̈́̉ͭ̾́̀̚҉̞͖̫̰͍͇̺͚̱̰̝̯͚̬ ̡̩̙̣̣̩̳̮̻̖̠̩͙̟̬̤͙̺̝ͩ̂͐̀̂̈ͦ̉̌ͩͭ̅ͫ̉̃͝ͅB̵̨̺̤̭̯̹̹̫̫̀͒ͭ̽̎ͮ̓ͫ̆ͦ͐̊̑̅̀̚͘͟L̶̴̛͙͇̪̯̩̖͙̣̯̐ͩͭ̒̌̊͂̌́O̴̶̵̠̗̰̘͍̞̓ͤ́͒̚ͅO̧̓͒̍̑ͦ̇͊̾̍ͮ̈ͮ͗͗́̓̕͟͏͚̦̤͇̤̬̦̤̰͈̩͚̳̳D̨͌͆ͭ̉ͪ̋͆̃̆̋ͧ̓ͣ̍͜͏͈͔͙̯̭͚̣͙̯̖ ̶̸̷̧̠̯̦̝̘̹̗̹̝̰ͧ̅͒̀ͧͬ͗ͮ͆̽̆ͩ̎̀͢F̷̢̼̪͍̹̹̖̮̜͕̥̤̥̘̩̼͚̪̬́̓̿̓͐̂̏͑͌̒̊̔͂̑̔̍͟͞Ơ̢̥̯͎̤̩̩̫̜̙͔̞̖̮̭͎̝̍͂͊͌̓ͦ͘͜͜ͅR̸̤̹̬̯͍͈̪̰̙̝̟̜͔͚̜̗̎̈́̓̏̈̽͂̀ͣ̆̇̂̊̑̍̀̚̚͜͝ ̴̸͇̟̮̲̱̺̯̪͍̹̫͎̪̮̺̙̙̎̊̀̒̂̾͐ͫ͆͟͞Ţ̛̠͈̘̣̝̘̰̙̟̯͈͇͔͙̤̫̠͙͆ͦ͐ͦ͋ͥͬͦ̌͐͝ͅH̢̊̉͗͊̓̊ͬ͑̍̓ͤ̌̀̊͏̶̘̫̹̮̖͍͎̮̬̝̤͖̺̀ͅÈͣͨ̊ͩ̃͂ͮ̔҉̶̧̤̰̜͎̭͇ ̵̛͆ͦ̀͑̽̓̽͊̍͞͏͓̗̫̲̜̮͎͎͉̪̤̙ͅͅS̵̢̛̫͓̙̻̭̳͙͔̙̼̪̼̙̗̦̫̏ͬ̎ͥ̀̚͘͠A̵̵̡͓̯̬̝̲̤̩̰̥̝̯̓̉͂̈͑̑̑ͧ͗̾̂̑ͅC̢̤̮͖̬̞̳̱̺̭͎̖̲̦̯̞̘̻̀͗̐͆͗̀ͅŔ̶̨̧̫̩̺̳̺̖̱̠̬̂͗̋̄̎͐ͧ̓͝Į̴̹͚̖̗̩͍̭̭̦͈͓̩̋͑̎̑ͫ̉̀ͮ̍͒ͥ̂̚͟ͅF̵̖̼̯̫̻̱͖̘ͯͫ̓ͫ̽̐ͬ̔ͭ̌̂̿͂̐̏̓̊̽́͢I̪̰̯̦̬̬͙̖̭̻̱̺̻̹̾ͯ̀ͤ̓̓̂̓ͪ̐͑ͣͥͦ̓ͩͥ́͢C̓͊ͮ́ͪ͆̃̍̊҉̶̺̯̠͇̼͈̭̰̪͙̦̜̫̟͈͙̗͔͘͞ͅE̩̙̞̹̪̬̰̞̥͉̩͗̾̀ͩ̎͌̔ͧ̂̐̅͘"
		]
	}
	
	# Select a random template
	var templates = responses[level]
	var template = templates[randi() % templates.size()]
	
	# If template contains %s, replace with keywords
	if template.find("%s") >= 0:
		# For disturbing level and above, make keywords uppercase
		var keyword = keywords[randi() % keywords.size()]
		if level >= SCARE_LEVELS.DISTURBING:
			keyword = keyword.to_upper()
		
		template = template.replace("%s", keyword)
	
	return template

# Create a holographic environment
func create_holographic_environment(scene_type):
	if not terminal_visualizer:
		print("Terminal visualizer not connected")
		return false
	
	# Clear existing scene
	for i in range(terminal_visualizer._models.size() - 1, -1, -1):
		terminal_visualizer.remove_model(i)
	
	match scene_type:
		"horror_forest":
			_create_horror_forest()
		"abandoned_hospital":
			_create_abandoned_hospital()
		"empty_void":
			_create_empty_void()
		"memory_fragments":
			_create_memory_fragments()
		"your_home":
			_create_your_home()
		_:
			return false
	
	return true

# Create horror forest environment
func _create_horror_forest():
	if not terminal_visualizer:
		return
	
	# Create trees
	for i in range(10):
		var tree = """
     /\\
    /  \\
   /    \\
  /______\\
     ||
"""
		var scale = 0.3 + randf() * 0.5
		var color = Color(0.05, 0.2, 0.05)
		var model_index = terminal_visualizer.create_ascii_model(tree, scale, color)
		var x = randf_range(-20, 20)
		var z = randf_range(-30, -5)
		terminal_visualizer.translate_model(model_index, Vector3(x, 0, z))
	
	# Create fog
	for i in range(20):
		var fog = "~" * (5 + randi() % 10)
		var model_index = terminal_visualizer.create_text_model(fog, 0.2, Color(0.5, 0.5, 0.5, 0.3))
		var x = randf_range(-20, 20)
		var y = randf_range(0, 5)
		var z = randf_range(-20, -5)
		terminal_visualizer.translate_model(model_index, Vector3(x, y, z))
	
	# Create distant figure
	var figure = """
     o
    /|\\
    / \\
"""
		var model_index = terminal_visualizer.create_ascii_model(figure, 0.3, Color(0.1, 0.1, 0.1))
		terminal_visualizer.translate_model(model_index, Vector3(0, 0, -25))
	
	# Add watcher eyes
	var eyes = """
   * *
"""
	var eye_index = terminal_visualizer.create_ascii_model(eyes, 0.2, Color(1.0, 0.0, 0.0))
	terminal_visualizer.translate_model(eye_index, Vector3(0, 3, -20))
	
	# Add movement effect
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = false
	add_child(timer)
	
	timer.timeout.connect(func():
		var x = randf_range(-5, 5)
		var z = randf_range(-25, -15)
		terminal_visualizer.translate_model(eye_index, Vector3(x, 3, z))
	)
	
	timer.start()

# Create abandoned hospital environment
func _create_abandoned_hospital():
	# Implementation for abandoned hospital scene
	pass

# Create empty void environment
func _create_empty_void():
	# Implementation for empty void scene
	pass

# Create memory fragments environment
func _create_memory_fragments():
	# Implementation for memory fragments scene
	pass

# Create your home environment
func _create_your_home():
	# Implementation for "your home" scene - particularly effective for scaring
	pass