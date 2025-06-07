extends Node

# Terminal Symbols System
# Provides emoji and symbol management for terminal messages
# Integrates with the Terminal Memory System for visual representation

class_name TerminalSymbols

# Symbol categories
enum SymbolCategory {
	GENERAL,
	DRIVES,
	POKEMON,
	EMOTIONS,
	DIMENSIONS,
	ELEMENTS,
	SYSTEM,
	CUSTOM
}

# Symbol mapping
var symbols = {
	"general": {
		"success": "✅",
		"error": "❌",
		"warning": "⚠️",
		"info": "ℹ️",
		"question": "❓",
		"star": "⭐",
		"sparkle": "✨",
		"fire": "🔥",
		"heart": "❤️",
		"clock": "🕒",
		"lock": "🔒",
		"unlock": "🔓",
		"eye": "👁️",
		"brain": "🧠",
		"thinking": "🤔",
		"idea": "💡",
		"magic": "✨",
		"music": "🎵",
		"alert": "🚨"
	},
	"drives": {
		"local": "💻",
		"icloud": "☁️",
		"gdrive": "📝",
		"remote": "🌐",
		"backup": "📼",
		"encrypted": "🔒",
		"shared": "👥",
		"archive": "📦",
		"system": "⚙️",
		"external": "📀"
	},
	"pokemon": {
		"squirtle": "🐢",
		"charmander": "🔥",
		"bulbasaur": "🌿",
		"pikachu": "⚡",
		"eevee": "🦊",
		"snorlax": "😴",
		"mewtwo": "👁️",
		"dragonite": "🐉",
		"mew": "💫",
		"lugia": "🌊"
	},
	"emotions": {
		"happy": "😊",
		"sad": "😢",
		"angry": "😠",
		"surprised": "😲",
		"confused": "😕",
		"love": "😍",
		"cool": "😎",
		"nervous": "😰",
		"sleepy": "😴",
		"sick": "🤒"
	},
	"dimensions": {
		"physical": "📦",
		"digital": "💾",
		"temporal": "⏳",
		"conceptual": "💭",
		"quantum": "⚛️",
		"dream": "💤",
		"memory": "📝",
		"parallel": "🌀",
		"spiritual": "✨",
		"void": "⚫"
	},
	"elements": {
		"fire": "🔥",
		"water": "💧",
		"earth": "🌍",
		"air": "💨",
		"light": "✨",
		"dark": "🌑",
		"metal": "⚙️",
		"wood": "🌲",
		"electric": "⚡",
		"ice": "❄️"
	},
	"system": {
		"terminal": "🖥️",
		"memory": "💾",
		"processor": "🧮",
		"network": "🌐",
		"time": "⏱️",
		"power": "🔋",
		"sync": "🔄",
		"search": "🔍",
		"commands": "#️⃣",
		"settings": "⚙️"
	},
	"custom": {}  # For user-defined symbols
}

# Terminal reference
var terminal_memory = null

func _ready():
	# Look for terminal memory system
	terminal_memory = get_node_or_null("/root/TerminalMemorySystem")
	
	if terminal_memory and terminal_memory.has_method("add_memory_text"):
		terminal_memory.add_memory_text("Terminal Symbols initialized with " + str(count_all_symbols()) + " symbols.", "system")

# Get a symbol by name and category
func get_symbol(name: String, category: String = "general") -> String:
	if symbols.has(category) and symbols[category].has(name):
		return symbols[category][name]
	return "❓"  # Unknown symbol

# Get all symbols in a category
func get_category_symbols(category: String) -> Dictionary:
	if symbols.has(category):
		return symbols[category]
	return {}

# Add a custom symbol
func add_custom_symbol(name: String, symbol: String) -> bool:
	if not symbols.has("custom"):
		symbols["custom"] = {}
		
	symbols["custom"][name] = symbol
	
	if terminal_memory and terminal_memory.has_method("add_memory_text"):
		terminal_memory.add_memory_text("Added custom symbol: " + name + " " + symbol, "system")
		
	return true

# Remove a custom symbol
func remove_custom_symbol(name: String) -> bool:
	if symbols.has("custom") and symbols["custom"].has(name):
		symbols["custom"].erase(name)
		
		if terminal_memory and terminal_memory.has_method("add_memory_text"):
			terminal_memory.add_memory_text("Removed custom symbol: " + name, "system")
			
		return true
		
	return false

# Count all symbols
func count_all_symbols() -> int:
	var count = 0
	
	for category in symbols:
		count += symbols[category].size()
		
	return count

# Format a message with symbols
func format_message(message: String) -> String:
	# Replace symbol codes with actual symbols
	var formatted = message
	
	# Replace :symbol_name: with the actual symbol
	var regex = RegEx.new()
	regex.compile(":(\\w+):")
	
	var matches = regex.search_all(message)
	for match_result in matches:
		var symbol_name = match_result.get_string(1)
		var symbol = find_symbol(symbol_name)
		
		if symbol != "":
			formatted = formatted.replace(":" + symbol_name + ":", symbol)
			
	return formatted

# Find a symbol across all categories
func find_symbol(name: String) -> String:
	for category in symbols:
		if symbols[category].has(name):
			return symbols[category][name]
			
	return ""

# Generate a symbol pattern
func generate_symbol_pattern(symbol: String, length: int) -> String:
	var pattern = ""
	
	for i in range(length):
		pattern += symbol
		
	return pattern

# Format a terminal header
func format_header(title: String, width: int = 50) -> String:
	var symbol = "="
	var padding = (width - title.length() - 4) / 2
	var left_padding = floor(padding)
	var right_padding = ceil(padding)
	
	var header = generate_symbol_pattern(symbol, width) + "\n"
	header += symbol + " " + generate_symbol_pattern(" ", left_padding)
	header += title
	header += generate_symbol_pattern(" ", right_padding) + " " + symbol + "\n"
	header += generate_symbol_pattern(symbol, width)
	
	return header

# Format a progress bar
func format_progress_bar(progress: float, width: int = 20) -> String:
	var filled_chars = int(width * clamp(progress, 0, 1))
	var empty_chars = width - filled_chars
	
	var bar = "["
	bar += generate_symbol_pattern("█", filled_chars)
	bar += generate_symbol_pattern("░", empty_chars)
	bar += "] " + str(int(progress * 100)) + "%"
	
	return bar

# Generate Pokemon-themed output
func generate_pokemon_themed(text: String) -> String:
	var pokemon_keys = symbols["pokemon"].keys()
	var random_pokemon = pokemon_keys[randi() % pokemon_keys.size()]
	var pokemon_symbol = symbols["pokemon"][random_pokemon]
	
	return pokemon_symbol + " " + text + " " + pokemon_symbol

# Process symbol commands
func process_command(command: String) -> void:
	var parts = command.split(" ", true, 2)
	var cmd = parts[0].to_lower()
	var args = parts[1] if parts.size() > 1 else ""
	
	match cmd:
		"#symbol", "#symbols":
			_process_symbol_command(args)
		"##symbol", "##symbols":
			_process_advanced_symbol_command(args)
		"###symbol", "###symbols":
			_process_system_symbol_command(args)

# Process basic symbol commands
func _process_symbol_command(args: String) -> void:
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		_display_symbol_help()
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"list":
			_list_symbols(subargs)
		"get":
			_get_symbol(subargs)
		"add":
			_add_symbol(subargs)
		"remove":
			_remove_symbol(subargs)
		"help":
			_display_symbol_help()
		_:
			_log("Unknown symbol command: " + subcmd)

# Process advanced symbol commands
func _process_advanced_symbol_command(args: String) -> void:
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		_display_advanced_symbol_help()
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"format":
			_format_with_symbols(subargs)
		"header":
			_create_header(subargs)
		"progress":
			_create_progress(subargs)
		"pattern":
			_create_pattern(subargs)
		"pokemon":
			_pokemon_theme(subargs)
		"help":
			_display_advanced_symbol_help()
		_:
			_log("Unknown advanced symbol command: " + subcmd)

# Process system symbol commands
func _process_system_symbol_command(args: String) -> void:
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		_display_system_symbol_help()
		return
		
	var subcmd = parts[0].to_lower()
	var subargs = parts[1] if parts.size() > 1 else ""
	
	match subcmd:
		"import":
			_import_symbols(subargs)
		"export":
			_export_symbols(subargs)
		"reset":
			_reset_symbols(subargs)
		"emoji":
			_show_emoji_support()
		"help":
			_display_system_symbol_help()
		_:
			_log("Unknown system symbol command: " + subcmd)

# List symbols
func _list_symbols(category: String) -> void:
	if category.empty():
		_log("Available symbol categories:")
		for cat in symbols:
			_log("- " + cat + " (" + str(symbols[cat].size()) + " symbols)")
	elif symbols.has(category):
		_log("Symbols in category '" + category + "':")
		for name in symbols[category]:
			_log("- " + name + ": " + symbols[category][name])
	else:
		_log("Unknown category: " + category)

# Get a specific symbol
func _get_symbol(args: String) -> void:
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 2:
		_log("Usage: #symbol get <category> <name>")
		return
		
	var category = parts[0]
	var name = parts[1]
	
	if symbols.has(category) and symbols[category].has(name):
		_log("Symbol " + name + " in category " + category + ": " + symbols[category][name])
	else:
		_log("Symbol not found: " + category + "/" + name)

# Add a custom symbol
func _add_symbol(args: String) -> void:
	var parts = args.split(" ", true, 2)
	
	if parts.size() < 2:
		_log("Usage: #symbol add <name> <symbol>")
		return
		
	var name = parts[0]
	var symbol = parts[1]
	
	if add_custom_symbol(name, symbol):
		_log("Added symbol: " + name + " = " + symbol)
	else:
		_log("Failed to add symbol.")

# Remove a custom symbol
func _remove_symbol(name: String) -> void:
	if remove_custom_symbol(name):
		_log("Removed symbol: " + name)
	else:
		_log("Symbol not found: " + name)

# Display symbol help
func _display_symbol_help() -> void:
	_log("Symbol Commands:")
	_log("  #symbol list [category] - List symbols in category")
	_log("  #symbol get <category> <name> - Get a specific symbol")
	_log("  #symbol add <name> <symbol> - Add a custom symbol")
	_log("  #symbol remove <name> - Remove a custom symbol")
	_log("  #symbol help - Display this help")

# Display advanced symbol help
func _display_advanced_symbol_help() -> void:
	_log("Advanced Symbol Commands:")
	_log("  ##symbol format <text> - Format text with embedded symbols")
	_log("  ##symbol header <title> [width] - Create a header")
	_log("  ##symbol progress <percent> [width] - Create a progress bar")
	_log("  ##symbol pattern <symbol> <length> - Create a pattern")
	_log("  ##symbol pokemon <text> - Add Pokemon theme to text")
	_log("  ##symbol help - Display this help")

# Display system symbol help
func _display_system_symbol_help() -> void:
	_log("System Symbol Commands:")
	_log("  ###symbol import <path> - Import symbols from file")
	_log("  ###symbol export <path> - Export symbols to file")
	_log("  ###symbol reset [category] - Reset symbols")
	_log("  ###symbol emoji - Show emoji support info")
	_log("  ###symbol help - Display this help")

# Format text with symbols
func _format_with_symbols(text: String) -> void:
	_log(format_message(text))

# Create a header
func _create_header(args: String) -> void:
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		_log("Usage: ##symbol header <title> [width]")
		return
		
	var title = parts[0]
	var width = int(parts[1]) if parts.size() > 1 else 40
	
	_log(format_header(title, width))

# Create a progress bar
func _create_progress(args: String) -> void:
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 1:
		_log("Usage: ##symbol progress <percent> [width]")
		return
		
	var percent = float(parts[0]) / 100.0
	var width = int(parts[1]) if parts.size() > 1 else 20
	
	_log(format_progress_bar(percent, width))

# Create a pattern
func _create_pattern(args: String) -> void:
	var parts = args.split(" ", true, 1)
	
	if parts.size() < 2:
		_log("Usage: ##symbol pattern <symbol> <length>")
		return
		
	var symbol = parts[0]
	var length = int(parts[1])
	
	_log(generate_symbol_pattern(symbol, length))

# Apply Pokemon theme
func _pokemon_theme(text: String) -> void:
	_log(generate_pokemon_themed(text))

# Import symbols from file
func _import_symbols(path: String) -> void:
	_log("Importing symbols from: " + path)
	# In a real implementation, this would load from a file

# Export symbols to file
func _export_symbols(path: String) -> void:
	_log("Exporting symbols to: " + path)
	# In a real implementation, this would save to a file

# Reset symbols
func _reset_symbols(category: String) -> void:
	if category.empty() or category == "all":
		_log("Resetting all custom symbols")
		symbols["custom"] = {}
	elif category == "custom" and symbols.has("custom"):
		_log("Resetting custom symbols")
		symbols["custom"] = {}
	else:
		_log("Cannot reset built-in symbol category: " + category)

# Show emoji support info
func _show_emoji_support() -> void:
	_log("Emoji Support Information:")
	_log("This terminal supports Unicode emoji symbols.")
	_log("You can use emoji inline with :emoji_name: syntax.")
	_log("Examples: :star: :fire: :heart:")
	_log("Custom symbols can be added with #symbol add command.")

# Log helper
func _log(message: String) -> void:
	print(message)
	if terminal_memory and terminal_memory.has_method("add_memory_text"):
		terminal_memory.add_memory_text(message, "symbol")