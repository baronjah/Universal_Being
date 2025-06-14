extends Node

# Keyboard Shape System
# Creates visual representations of keyboard layouts and special key combinations
# Integrates with the terminal for keyboard-based shape visualization
# Supports # and ### command prefixes for different operation levels

class_name KeyboardShapeSystem

# Keyboard layouts
enum KeyboardLayout { 
	QWERTY, 
	DVORAK, 
	COLEMAK, 
	WORKMAN,
	CUSTOM 
}

# Keyboard visualization modes
enum VisualMode {
	TEXT,      # Simple text-based representation
	UNICODE,   # Unicode box-drawing characters
	EMOJI,     # Emoji-based visualization
	COLOR,     # Color-coded visualization
	ADVANCED   # Full 3D representation (for Godot integration)
}

# Key types for special highlighting
enum KeyType {
	NORMAL,
	SPECIAL,
	MODIFIER,
	FUNCTION,
	NAVIGATION,
	NUMPAD,
	CUSTOM
}

# Keyboard state and properties
var current_layout = KeyboardLayout.QWERTY
var current_mode = VisualMode.UNICODE
var special_keys = {
	"enter": {"symbol": "⏎", "emoji": "↩️", "color": Color(0.2, 0.8, 0.2)},
	"shift": {"symbol": "⇧", "emoji": "⬆️", "color": Color(0.8, 0.2, 0.2)},
	"ctrl": {"symbol": "⌃", "emoji": "🎮", "color": Color(0.2, 0.2, 0.8)},
	"alt": {"symbol": "⌥", "emoji": "⚙️", "color": Color(0.8, 0.8, 0.2)},
	"space": {"symbol": "␣", "emoji": "⬜", "color": Color(0.6, 0.6, 0.6)},
	"tab": {"symbol": "⇥", "emoji": "➡️", "color": Color(0.2, 0.7, 0.7)},
	"esc": {"symbol": "⎋", "emoji": "🚪", "color": Color(0.8, 0.2, 0.8)},
	"backspace": {"symbol": "⌫", "emoji": "◀️", "color": Color(0.7, 0.3, 0.3)},
	"capslock": {"symbol": "⇪", "emoji": "🔒", "color": Color(0.5, 0.5, 0.8)},
	"win": {"symbol": "⊞", "emoji": "🪟", "color": Color(0.3, 0.7, 0.3)},
	"cmd": {"symbol": "⌘", "emoji": "🍎", "color": Color(0.7, 0.3, 0.7)},
	"fn": {"symbol": "ƒn", "emoji": "🔣", "color": Color(0.5, 0.5, 0.7)},
	"hash": {"symbol": "#", "emoji": "#️⃣", "color": Color(0.7, 0.7, 0.3)}
}

var terminal = null
var symbol_system = null

# Keyboard layouts as nested arrays
var layouts = {
	KeyboardLayout.QWERTY: [
		["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
		["a", "s", "d", "f", "g", "h", "j", "k", "l"],
		["z", "x", "c", "v", "b", "n", "m"]
	],
	KeyboardLayout.DVORAK: [
		["'", ",", ".", "p", "y", "f", "g", "c", "r", "l"],
		["a", "o", "e", "u", "i", "d", "h", "t", "n", "s"],
		[";", "q", "j", "k", "x", "b", "m", "w", "v", "z"]
	],
	KeyboardLayout.COLEMAK: [
		["q", "w", "f", "p", "g", "j", "l", "u", "y", ";"],
		["a", "r", "s", "t", "d", "h", "n", "e", "i", "o"],
		["z", "x", "c", "v", "b", "k", "m"]
	],
	KeyboardLayout.WORKMAN: [
		["q", "d", "r", "w", "b", "j", "f", "u", "p", ";"],
		["a", "s", "h", "t", "g", "y", "n", "e", "o", "i"],
		["z", "x", "m", "c", "v", "k", "l"]
	],
	KeyboardLayout.CUSTOM: [
		["#", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
		["@", "q", "w", "e", "r", "t", "y", "u", "i", "o"],
		["<", ">", "z", "x", "c", "v", "b", "n", "m", "p"]
	]
}

# Custom shapes for special visualizations
var shapes = {
	"arrow": [
		"   ▲   ",
		"  ▲▲▲  ",
		" ▲▲▲▲▲ ",
		"▲▲▲▲▲▲▲"
	],
	"diamond": [
		"   ◆   ",
		"  ◆◆◆  ",
		" ◆◆◆◆◆ ",
		"◆◆◆◆◆◆◆",
		" ◆◆◆◆◆ ",
		"  ◆◆◆  ",
		"   ◆   "
	],
	"hashtag": [
		" ##### ",
		"#######",
		" ##### ",
		"#######",
		" ##### "
	],
	"crooked": [
		"  /\\  ",
		" /  \\ ",
		"/    \\",
		"\\    /",
		" \\  / ",
		"  \\/  "
	],
	"v": [
		"\\    /",
		" \\  / ",
		"  \\/  "
	]
}

func _ready():
	# Look for terminal system
	terminal = get_node_or_null("/root/IntegratedTerminal")
	
	if terminal and terminal.has_node("symbol_system"):
		symbol_system = terminal.get_node("symbol_system")
		
	if terminal and terminal.has_method("add_text"):
		terminal.add_text("Keyboard Shape System initialized.", "system")

# Process keyboard-related commands
func process_command(command):
	var parts = command.split(" ", true, 1)
	var cmd = parts[0].to_lower()
	var args = parts[1] if parts.size() > 1 else ""
	
	match cmd:
		"#keyboard", "#kb":
			process_keyboard_command(args)
			return true
		"#shape":
			process_shape_command(args)
			return true
		"##keyboard", "##kb":
			process_advanced_keyboard_command(args)
			return true
		"##shape":
			process_advanced_shape_command(args)
			return true
		"###keyboard", "###kb":
			process_system_keyboard_command(args)
			return true
		"###shape":
			process_system_shape_command(args)
			return true
		_:
			return false

# Process basic keyboard commands
func process_keyboard_command(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		display_keyboard_help()
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"show":
			show_keyboard(subargs)
		"layout":
			set_keyboard_layout(subargs)
		"mode":
			set_visual_mode(subargs)
		"combo":
			show_key_combo(subargs)
		"key":
			show_key_info(subargs)
		"list":
			list_keyboard_options(subargs)
		"help":
			display_keyboard_help()
		_:
			log_message("Unknown keyboard command: " + subcmd, "error")

# Process basic shape commands
func process_shape_command(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		display_shape_help()
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"show":
			show_shape(subargs)
		"list":
			list_shapes()
		"ascii":
			show_ascii_art(subargs)
		"help":
			display_shape_help()
		_:
			log_message("Unknown shape command: " + subcmd, "error")

# Process advanced keyboard commands
func process_advanced_keyboard_command(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		display_advanced_keyboard_help()
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"highlight":
			highlight_keys(subargs)
		"animate":
			animate_keyboard(subargs)
		"custom":
			customize_key(subargs)
		"help":
			display_advanced_keyboard_help()
		_:
			log_message("Unknown advanced keyboard command: " + subcmd, "error")

# Process advanced shape commands
func process_advanced_shape_command(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		display_advanced_shape_help()
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"create":
			create_custom_shape(subargs)
		"modify":
			modify_shape(subargs)
		"animate":
			animate_shape(subargs)
		"help":
			display_advanced_shape_help()
		_:
			log_message("Unknown advanced shape command: " + subcmd, "error")

# Process system keyboard commands
func process_system_keyboard_command(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		display_system_keyboard_help()
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"reset":
			reset_keyboard_settings()
		"export":
			export_keyboard_layout(subargs)
		"import":
			import_keyboard_layout(subargs)
		"help":
			display_system_keyboard_help()
		_:
			log_message("Unknown system keyboard command: " + subcmd, "error")

# Process system shape commands
func process_system_shape_command(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		display_system_shape_help()
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"reset":
			reset_shapes()
		"export":
			export_shapes(subargs)
		"import":
			import_shapes(subargs)
		"help":
			display_system_shape_help()
		_:
			log_message("Unknown system shape command: " + subcmd, "error")

# Show keyboard visualization
func show_keyboard(layout_name=""):
	if !layout_name.empty():
		set_keyboard_layout(layout_name)
	
	var layout_text = ""
	match current_layout:
		KeyboardLayout.QWERTY: layout_text = "QWERTY"
		KeyboardLayout.DVORAK: layout_text = "Dvorak"
		KeyboardLayout.COLEMAK: layout_text = "Colemak"
		KeyboardLayout.WORKMAN: layout_text = "Workman"
		KeyboardLayout.CUSTOM: layout_text = "Custom"
	
	log_message("Keyboard Layout: " + layout_text, "keyboard")
	
	var keyboard = generate_keyboard_visualization()
	for line in keyboard:
		log_message(line, "keyboard")

# Set keyboard layout
func set_keyboard_layout(layout_name):
	match layout_name.to_lower():
		"qwerty":
			current_layout = KeyboardLayout.QWERTY
			log_message("Keyboard layout set to QWERTY", "system")
		"dvorak":
			current_layout = KeyboardLayout.DVORAK
			log_message("Keyboard layout set to Dvorak", "system")
		"colemak":
			current_layout = KeyboardLayout.COLEMAK
			log_message("Keyboard layout set to Colemak", "system")
		"workman":
			current_layout = KeyboardLayout.WORKMAN
			log_message("Keyboard layout set to Workman", "system")
		"custom":
			current_layout = KeyboardLayout.CUSTOM
			log_message("Keyboard layout set to Custom", "system")
		_:
			log_message("Unknown keyboard layout: " + layout_name, "error")
			log_message("Available layouts: qwerty, dvorak, colemak, workman, custom", "system")

# Set visualization mode
func set_visual_mode(mode_name):
	match mode_name.to_lower():
		"text":
			current_mode = VisualMode.TEXT
			log_message("Visual mode set to Text", "system")
		"unicode":
			current_mode = VisualMode.UNICODE
			log_message("Visual mode set to Unicode", "system")
		"emoji":
			current_mode = VisualMode.EMOJI
			log_message("Visual mode set to Emoji", "system")
		"color":
			current_mode = VisualMode.COLOR
			log_message("Visual mode set to Color", "system")
		"advanced":
			current_mode = VisualMode.ADVANCED
			log_message("Visual mode set to Advanced", "system")
		_:
			log_message("Unknown visual mode: " + mode_name, "error")
			log_message("Available modes: text, unicode, emoji, color, advanced", "system")

# Show key combination visualization
func show_key_combo(combo):
	var keys = combo.split("+")
	
	if keys.size() < 1:
		log_message("Please specify a key combination (e.g. 'ctrl+shift+s')", "error")
		return
	
	log_message("Key Combination: " + combo, "keyboard")
	
	var combo_str = ""
	
	for i in range(keys.size()):
		var key = keys[i].strip_edges().to_lower()
		
		if special_keys.has(key):
			match current_mode:
				VisualMode.TEXT:
					combo_str += "[" + key.to_upper() + "]"
				VisualMode.UNICODE:
					combo_str += special_keys[key].symbol
				VisualMode.EMOJI:
					combo_str += special_keys[key].emoji
				_:
					combo_str += special_keys[key].symbol
		else:
			combo_str += key.to_upper()
			
		if i < keys.size() - 1:
			combo_str += " + "
			
	log_message("Visualization: " + combo_str, "keyboard")
	
	# Also highlight in keyboard if it's a simple key
	if keys.size() == 1 and keys[0].length() == 1:
		var highlight_map = {}
		highlight_map[keys[0].strip_edges().to_lower()] = Color(1, 0.5, 0.5)
		show_keyboard_with_highlights(highlight_map)

# Show information about a specific key
func show_key_info(key):
	key = key.strip_edges().to_lower()
	
	if key.length() > 1 and special_keys.has(key):
		log_message("Key Information: " + key.to_upper(), "keyboard")
		log_message("- Symbol: " + special_keys[key].symbol, "keyboard")
		log_message("- Emoji: " + special_keys[key].emoji, "keyboard")
		log_message("- Color: RGB(" + str(special_keys[key].color.r * 255) + ", " + 
							str(special_keys[key].color.g * 255) + ", " + 
							str(special_keys[key].color.b * 255) + ")", "keyboard")
	elif key.length() == 1:
		log_message("Key Information: " + key.to_upper(), "keyboard")
		log_message("- ASCII Code: " + str(key.to_ascii()[0]), "keyboard")
		log_message("- Hex: 0x" + "%X" % key.to_ascii()[0], "keyboard")
		
		# Also highlight in keyboard
		var highlight_map = {}
		highlight_map[key] = Color(1, 0.5, 0.5)
		show_keyboard_with_highlights(highlight_map)
	else:
		log_message("Unknown key: " + key, "error")

# List keyboard options
func list_keyboard_options(option_type=""):
	match option_type.to_lower():
		"layouts":
			log_message("Available Keyboard Layouts:", "system")
			log_message("- QWERTY - Standard English layout", "system")
			log_message("- Dvorak - Designed for typing efficiency", "system")
			log_message("- Colemak - Modern alternative to QWERTY", "system")
			log_message("- Workman - Optimized for common English words", "system")
			log_message("- Custom - User-defined layout", "system")
		"modes":
			log_message("Available Visualization Modes:", "system")
			log_message("- Text - Simple text representation", "system")
			log_message("- Unicode - Uses Unicode box-drawing characters", "system")
			log_message("- Emoji - Uses emoji for visualization", "system")
			log_message("- Color - Color-coded visualization", "system")
			log_message("- Advanced - Full 3D representation (Godot)", "system")
		"specials":
			log_message("Special Keys:", "system")
			for key in special_keys:
				log_message("- " + key + ": " + special_keys[key].symbol, "system")
		_:
			log_message("Available option types: layouts, modes, specials", "system")

# Show a predefined shape
func show_shape(shape_name):
	if shapes.has(shape_name.to_lower()):
		log_message("Shape: " + shape_name, "shape")
		for line in shapes[shape_name.to_lower()]:
			log_message(line, "shape")
	else:
		log_message("Unknown shape: " + shape_name, "error")
		log_message("Use '#shape list' to see available shapes", "system")

# List available shapes
func list_shapes():
	log_message("Available Shapes:", "system")
	for shape_name in shapes:
		log_message("- " + shape_name, "system")

# Show ASCII art (simulated)
func show_ascii_art(art_name):
	match art_name.to_lower():
		"keyboard":
			log_message("ASCII Keyboard:", "shape")
			log_message("┌───┐ ┌───┬───┬───┬───┐ ┌───┬───┬───┬───┐ ┌───┬───┬───┬───┐", "shape")
			log_message("│Esc│ │F1 │F2 │F3 │F4 │ │F5 │F6 │F7 │F8 │ │F9 │F10│F11│F12│", "shape")
			log_message("└───┘ └───┴───┴───┴───┘ └───┴───┴───┴───┘ └───┴───┴───┴───┘", "shape")
			log_message("┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───────┐", "shape")
			log_message("│ ~ │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ - │ + │ Bksp  │", "shape")
			log_message("├───┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─────┤", "shape")
			log_message("│ Tab │ Q │ W │ E │ R │ T │ Y │ U │ I │ O │ P │ [ │ ] │  \\  │", "shape")
			log_message("├─────┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴─────┤", "shape")
			log_message("│ Caps │ A │ S │ D │ F │ G │ H │ J │ K │ L │ ; │ ' │  Enter │", "shape")
			log_message("├──────┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴────────┤", "shape")
			log_message("│ Shift  │ Z │ X │ C │ V │ B │ N │ M │ , │ . │ / │   Shift  │", "shape")
			log_message("├─────┬──┴┬──┴──┬┴───┴───┴───┴───┴───┴──┬┴───┴┬──┴┬─────────┤", "shape")
			log_message("│Ctrl │Win│ Alt │         Space         │ Alt │Win│   Ctrl  │", "shape")
			log_message("└─────┴───┴─────┴───────────────────────┴─────┴───┴─────────┘", "shape")
		"hash":
			log_message("ASCII Hash:", "shape")
			log_message("   #     #   ", "shape")
			log_message(" ########### ", "shape")
			log_message("   #     #   ", "shape")
			log_message(" ########### ", "shape")
			log_message("   #     #   ", "shape")
		"computer":
			log_message("ASCII Computer:", "shape")
			log_message("     .---.      ", "shape")
			log_message("     |   |      ", "shape")
			log_message("     |   |      ", "shape")
			log_message(" .=========.    ", "shape")
			log_message(" |.-''''''-.|   ", "shape")
			log_message(" ||         ||  ", "shape")
			log_message(" ||         ||  ", "shape")
			log_message(" ||         ||  ", "shape")
			log_message(" |'---------'|  ", "shape")
			log_message(" `^'-------'`   ", "shape")
		"crooked":
			log_message("ASCII Crooked Brackets:", "shape")
			log_message("    /\\      ", "shape")
			log_message("   /  \\     ", "shape")
			log_message("  /    \\    ", "shape")
			log_message(" /      \\   ", "shape")
			log_message("/        \\  ", "shape")
			log_message("\\        /  ", "shape")
			log_message(" \\      /   ", "shape")
			log_message("  \\    /    ", "shape")
			log_message("   \\  /     ", "shape")
			log_message("    \\/      ", "shape")
		_:
			log_message("Unknown ASCII art: " + art_name, "error")
			log_message("Available options: keyboard, hash, computer, crooked", "system")

# Highlight specific keys on the keyboard
func highlight_keys(key_list):
	var keys = key_list.split(",")
	
	if keys.size() < 1:
		log_message("Please specify keys to highlight (e.g. 'a,s,d,f')", "error")
		return
	
	var highlight_map = {}
	for key in keys:
		var clean_key = key.strip_edges().to_lower()
		highlight_map[clean_key] = Color(1, 0.5, 0.5)  # Default highlight color
	
	log_message("Highlighting keys: " + key_list, "keyboard")
	show_keyboard_with_highlights(highlight_map)

# Animate keyboard (simulated)
func animate_keyboard(animation_type):
	match animation_type.to_lower():
		"typing":
			log_message("Typing Animation:", "keyboard")
			log_message("Press keys in sequence: H → E → L → L → O", "keyboard")
			
			var highlight_sequence = ["h", "e", "l", "l", "o"]
			for key in highlight_sequence:
				var highlight_map = {}
				highlight_map[key] = Color(1, 0.5, 0.5)
				show_keyboard_with_highlights(highlight_map)
				yield(get_tree().create_timer(0.5), "timeout")
				
			log_message("Animation complete: 'HELLO'", "keyboard")
		"wave":
			log_message("Wave Animation:", "keyboard")
			
			var wave_sequences = [
				["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
				["a", "s", "d", "f", "g", "h", "j", "k", "l"],
				["z", "x", "c", "v", "b", "n", "m"]
			]
			
			for row in wave_sequences:
				var highlight_map = {}
				for key in row:
					highlight_map[key] = Color(0.5, 0.5, 1)
				show_keyboard_with_highlights(highlight_map)
				yield(get_tree().create_timer(0.3), "timeout")
				
			log_message("Wave animation complete", "keyboard")
		"rainbow":
			log_message("Rainbow Animation:", "keyboard")
			log_message("Animation not available in terminal mode", "keyboard")
			log_message("Use Godot interface for full visual effects", "keyboard")
		_:
			log_message("Unknown animation type: " + animation_type, "error")
			log_message("Available animations: typing, wave, rainbow", "system")

# Customize a key's appearance
func customize_key(args):
	var parts = args.split(" ", true, 2)
	
	if parts.size() < 3:
		log_message("Usage: ##keyboard custom <key> <property> <value>", "error")
		return
		
	var key = parts[0].strip_edges().to_lower()
	var property = parts[1].strip_edges().to_lower()
	var value = parts[2]
	
	if !special_keys.has(key):
		special_keys[key] = {"symbol": key, "emoji": key, "color": Color(0.8, 0.8, 0.8)}
	
	match property:
		"symbol":
			special_keys[key].symbol = value
			log_message("Updated symbol for key '" + key + "' to: " + value, "system")
		"emoji":
			special_keys[key].emoji = value
			log_message("Updated emoji for key '" + key + "' to: " + value, "system")
		"color":
			var color_parts = value.split(",")
			if color_parts.size() >= 3:
				var r = float(color_parts[0]) / 255.0
				var g = float(color_parts[1]) / 255.0
				var b = float(color_parts[2]) / 255.0
				special_keys[key].color = Color(r, g, b)
				log_message("Updated color for key '" + key + "' to RGB(" + value + ")", "system")
			else:
				log_message("Invalid color format. Use R,G,B values (0-255)", "error")
		_:
			log_message("Unknown property: " + property, "error")
			log_message("Available properties: symbol, emoji, color", "system")

# Create a custom shape
func create_custom_shape(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		log_message("Usage: ##shape create <name>", "error")
		log_message("Then enter each line of the shape, ending with ##shape end", "error")
		return
		
	var shape_name = parts[0].strip_edges().to_lower()
	
	log_message("Creating custom shape: " + shape_name, "system")
	log_message("Enter each line of the shape, then use ##shape end when done", "system")
	
	# In a real implementation, this would set up a shape creation mode
	# For this mock-up, we'll just create a sample shape
	
	shapes[shape_name] = [
		"Custom",
		"Shape",
		"Example"
	]
	
	log_message("Custom shape created! Use '#shape show " + shape_name + "' to view it.", "system")

# Modify an existing shape
func modify_shape(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		log_message("Usage: ##shape modify <name> [operation]", "error")
		return
		
	var shape_name = parts[0].strip_edges().to_lower()
	var operation = parts[1] if parts.size() > 1 else ""
	
	if !shapes.has(shape_name):
		log_message("Shape not found: " + shape_name, "error")
		return
	
	match operation.to_lower():
		"rotate":
			log_message("Rotating shape: " + shape_name, "system")
			# In a real implementation, this would actually rotate the shape
			log_message("Shape rotated", "system")
		"mirror":
			log_message("Mirroring shape: " + shape_name, "system")
			# In a real implementation, this would actually mirror the shape
			log_message("Shape mirrored", "system")
		"scale":
			log_message("Scaling shape: " + shape_name, "system")
			# In a real implementation, this would actually scale the shape
			log_message("Shape scaled", "system")
		_:
			log_message("Unknown operation: " + operation, "error")
			log_message("Available operations: rotate, mirror, scale", "system")

# Animate a shape (simulated)
func animate_shape(args):
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		log_message("Usage: ##shape animate <name> [animation]", "error")
		return
		
	var shape_name = parts[0].strip_edges().to_lower()
	var animation = parts[1] if parts.size() > 1 else "pulse"
	
	if !shapes.has(shape_name):
		log_message("Shape not found: " + shape_name, "error")
		return
	
	log_message("Animating shape: " + shape_name + " (" + animation + ")", "system")
	
	# Show the shape multiple times to simulate animation
	for i in range(3):
		for line in shapes[shape_name]:
			log_message(line, "shape")
		yield(get_tree().create_timer(0.5), "timeout")
		log_message("", "shape")  # Empty line as separator
		yield(get_tree().create_timer(0.2), "timeout")
	
	log_message("Animation complete", "system")

# Reset keyboard settings
func reset_keyboard_settings():
	current_layout = KeyboardLayout.QWERTY
	current_mode = VisualMode.UNICODE
	
	# Reset special keys to defaults
	special_keys = {
		"enter": {"symbol": "⏎", "emoji": "↩️", "color": Color(0.2, 0.8, 0.2)},
		"shift": {"symbol": "⇧", "emoji": "⬆️", "color": Color(0.8, 0.2, 0.2)},
		"ctrl": {"symbol": "⌃", "emoji": "🎮", "color": Color(0.2, 0.2, 0.8)},
		"alt": {"symbol": "⌥", "emoji": "⚙️", "color": Color(0.8, 0.8, 0.2)},
		"space": {"symbol": "␣", "emoji": "⬜", "color": Color(0.6, 0.6, 0.6)},
		"tab": {"symbol": "⇥", "emoji": "➡️", "color": Color(0.2, 0.7, 0.7)},
		"esc": {"symbol": "⎋", "emoji": "🚪", "color": Color(0.8, 0.2, 0.8)},
		"backspace": {"symbol": "⌫", "emoji": "◀️", "color": Color(0.7, 0.3, 0.3)},
		"capslock": {"symbol": "⇪", "emoji": "🔒", "color": Color(0.5, 0.5, 0.8)},
		"win": {"symbol": "⊞", "emoji": "🪟", "color": Color(0.3, 0.7, 0.3)},
		"cmd": {"symbol": "⌘", "emoji": "🍎", "color": Color(0.7, 0.3, 0.7)},
		"fn": {"symbol": "ƒn", "emoji": "🔣", "color": Color(0.5, 0.5, 0.7)},
		"hash": {"symbol": "#", "emoji": "#️⃣", "color": Color(0.7, 0.7, 0.3)}
	}
	
	log_message("Keyboard settings reset to defaults", "system")

# Export keyboard layout
func export_keyboard_layout(path):
	if path.empty():
		path = "user://keyboard_layout.dat"
	
	log_message("Exporting keyboard layout to: " + path, "system")
	
	# In a real implementation, this would save to a file
	# For this mock-up, we'll just simulate it
	
	yield(get_tree().create_timer(0.5), "timeout")
	log_message("Keyboard layout exported successfully", "system")

# Import keyboard layout
func import_keyboard_layout(path):
	if path.empty():
		path = "user://keyboard_layout.dat"
	
	log_message("Importing keyboard layout from: " + path, "system")
	
	# In a real implementation, this would load from a file
	# For this mock-up, we'll just simulate it
	
	yield(get_tree().create_timer(0.5), "timeout")
	log_message("Keyboard layout imported successfully", "system")

# Reset shapes
func reset_shapes():
	shapes = {
		"arrow": [
			"   ▲   ",
			"  ▲▲▲  ",
			" ▲▲▲▲▲ ",
			"▲▲▲▲▲▲▲"
		],
		"diamond": [
			"   ◆   ",
			"  ◆◆◆  ",
			" ◆◆◆◆◆ ",
			"◆◆◆◆◆◆◆",
			" ◆◆◆◆◆ ",
			"  ◆◆◆  ",
			"   ◆   "
		],
		"hashtag": [
			" ##### ",
			"#######",
			" ##### ",
			"#######",
			" ##### "
		],
		"crooked": [
			"  /\\  ",
			" /  \\ ",
			"/    \\",
			"\\    /",
			" \\  / ",
			"  \\/  "
		],
		"v": [
			"\\    /",
			" \\  / ",
			"  \\/  "
		]
	}
	
	log_message("Shapes reset to defaults", "system")

# Export shapes
func export_shapes(path):
	if path.empty():
		path = "user://shapes.dat"
	
	log_message("Exporting shapes to: " + path, "system")
	
	# In a real implementation, this would save to a file
	# For this mock-up, we'll just simulate it
	
	yield(get_tree().create_timer(0.5), "timeout")
	log_message("Shapes exported successfully", "system")

# Import shapes
func import_shapes(path):
	if path.empty():
		path = "user://shapes.dat"
	
	log_message("Importing shapes from: " + path, "system")
	
	# In a real implementation, this would load from a file
	# For this mock-up, we'll just simulate it
	
	yield(get_tree().create_timer(0.5), "timeout")
	log_message("Shapes imported successfully", "system")

# Generate keyboard visualization
func generate_keyboard_visualization():
	var current_keys = layouts[current_layout]
	var result = []
	
	match current_mode:
		VisualMode.TEXT:
			# Simple text mode
			for row in current_keys:
				var line = ""
				for key in row:
					line += "[" + key.to_upper() + "] "
				result.append(line)
		VisualMode.UNICODE:
			# Unicode box drawing characters
			for row in current_keys:
				var line = "┌"
				for i in range(row.size()):
					line += "───"
					if i < row.size() - 1:
						line += "┬"
				line += "┐"
				result.append(line)
				
				line = "│"
				for key in row:
					if key.length() == 1:
						line += " " + key.to_upper() + " │"
					else:
						line += special_keys[key].symbol + "│"
				result.append(line)
				
				line = "└"
				for i in range(row.size()):
					line += "───"
					if i < row.size() - 1:
						line += "┴"
				line += "┘"
				result.append(line)
		VisualMode.EMOJI:
			# Emoji representation
			for row in current_keys:
				var line = ""
				for key in row:
					if special_keys.has(key):
						line += special_keys[key].emoji + " "
					else:
						line += key.to_upper() + "️⃣ "
				result.append(line)
		_:
			# Default to Unicode mode for other modes in this mock-up
			for row in current_keys:
				var line = "┌"
				for i in range(row.size()):
					line += "───"
					if i < row.size() - 1:
						line += "┬"
				line += "┐"
				result.append(line)
				
				line = "│"
				for key in row:
					if key.length() == 1:
						line += " " + key.to_upper() + " │"
					else:
						line += special_keys[key].symbol + "│"
				result.append(line)
				
				line = "└"
				for i in range(row.size()):
					line += "───"
					if i < row.size() - 1:
						line += "┴"
				line += "┘"
				result.append(line)
	
	# Add special row for Enter, Space, etc. in Unicode mode
	if current_mode == VisualMode.UNICODE:
		result.append("┌───────┬───────┬─" + "─".repeat(15) + "┬───────┐")
		result.append("│ " + special_keys["ctrl"].symbol + " │ " + 
					  special_keys["alt"].symbol + " │ " + 
					  special_keys["space"].symbol + " ".repeat(13) + "│ " + 
					  special_keys["enter"].symbol + " │")
		result.append("└───────┴───────┴─" + "─".repeat(15) + "┴───────┘")
	
	return result

# Show keyboard with highlighted keys
func show_keyboard_with_highlights(highlight_map):
	var current_keys = layouts[current_layout]
	var result = []
	
	# For simplicity, we'll use Unicode mode for highlighting
	for row in current_keys:
		var line = "┌"
		for i in range(row.size()):
			line += "───"
			if i < row.size() - 1:
				line += "┬"
		line += "┐"
		result.append(line)
		
		line = "│"
		for key in row:
			if highlight_map.has(key):
				# Highlighted key
				line += "[H]│"
			elif key.length() == 1:
				line += " " + key.to_upper() + " │"
			else:
				line += special_keys[key].symbol + "│"
		result.append(line)
		
		line = "└"
		for i in range(row.size()):
			line += "───"
			if i < row.size() - 1:
				line += "┴"
		line += "┘"
		result.append(line)
	
	# Add special row for Enter, Space, etc.
	result.append("┌───────┬───────┬─" + "─".repeat(15) + "┬───────┐")
	
	var line = "│ "
	if highlight_map.has("ctrl"):
		line += "[H]"
	else:
		line += special_keys["ctrl"].symbol + " "
	
	line += "│ "
	if highlight_map.has("alt"):
		line += "[H]"
	else:
		line += special_keys["alt"].symbol + " "
	
	line += "│ "
	if highlight_map.has("space"):
		line += "[H]" + " ".repeat(13)
	else:
		line += special_keys["space"].symbol + " ".repeat(13)
	
	line += "│ "
	if highlight_map.has("enter"):
		line += "[H]"
	else:
		line += special_keys["enter"].symbol + " "
	
	line += "│"
	result.append(line)
	
	result.append("└───────┴───────┴─" + "─".repeat(15) + "┴───────┘")
	
	# Display the result
	for line in result:
		log_message(line, "keyboard")

# Display keyboard help
func display_keyboard_help():
	log_message("Keyboard Commands:", "system")
	log_message("  #keyboard show [layout] - Display keyboard layout", "system")
	log_message("  #keyboard layout <name> - Set keyboard layout", "system")
	log_message("  #keyboard mode <mode> - Set visualization mode", "system")
	log_message("  #keyboard combo <keys> - Show key combination", "system")
	log_message("  #keyboard key <key> - Show key information", "system")
	log_message("  #keyboard list [option] - List keyboard options", "system")
	log_message("  #keyboard help - Display this help", "system")
	log_message("", "system")
	log_message("For advanced keyboard commands, type ##keyboard help", "system")

# Display shape help
func display_shape_help():
	log_message("Shape Commands:", "system")
	log_message("  #shape show <name> - Display a predefined shape", "system")
	log_message("  #shape list - List available shapes", "system")
	log_message("  #shape ascii <type> - Show ASCII art", "system")
	log_message("  #shape help - Display this help", "system")
	log_message("", "system")
	log_message("For advanced shape commands, type ##shape help", "system")

# Display advanced keyboard help
func display_advanced_keyboard_help():
	log_message("Advanced Keyboard Commands:", "system")
	log_message("  ##keyboard highlight <keys> - Highlight specific keys", "system")
	log_message("  ##keyboard animate <type> - Animate the keyboard", "system")
	log_message("  ##keyboard custom <key> <property> <value> - Customize key appearance", "system")
	log_message("  ##keyboard help - Display this help", "system")

# Display advanced shape help
func display_advanced_shape_help():
	log_message("Advanced Shape Commands:", "system")
	log_message("  ##shape create <name> - Create a custom shape", "system")
	log_message("  ##shape modify <name> <operation> - Modify a shape", "system")
	log_message("  ##shape animate <name> [animation] - Animate a shape", "system")
	log_message("  ##shape help - Display this help", "system")

# Display system keyboard help
func display_system_keyboard_help():
	log_message("System Keyboard Commands:", "system")
	log_message("  ###keyboard reset - Reset keyboard settings", "system")
	log_message("  ###keyboard export [path] - Export keyboard layout", "system")
	log_message("  ###keyboard import [path] - Import keyboard layout", "system")
	log_message("  ###keyboard help - Display this help", "system")

# Display system shape help
func display_system_shape_help():
	log_message("System Shape Commands:", "system")
	log_message("  ###shape reset - Reset shapes to defaults", "system")
	log_message("  ###shape export [path] - Export shapes", "system")
	log_message("  ###shape import [path] - Import shapes", "system")
	log_message("  ###shape help - Display this help", "system")

# Log a message to the terminal
func log_message(message, category="keyboard"):
	print(message)
	
	if terminal and terminal.has_method("add_text"):
		terminal.add_text(message, category)