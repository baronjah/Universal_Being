# ==================================================
# SCRIPT NAME: windows_console_fix.gd
# DESCRIPTION: Windows 11 console emoji/symbol compatibility fix
# CREATED: 2025-05-23 - ASCII fallbacks for admin terminal issues
# ==================================================

extends UniversalBeingBase
# Windows 11 emoji mapping for admin terminal compatibility
var emoji_to_ascii: Dictionary = {
	# Status indicators
	"🎮": "[GAME]",
	"🔧": "[SETUP]", 
	"✅": "[OK]",
	"❌": "[FAIL]",
	"⚠️": "[WARN]",
	"🚀": "[LAUNCH]",
	
	# Debug symbols  
	"🎯": "[TARGET]",
	"🔍": "[SEARCH]",
	"📝": "[TODO]",
	"💾": "[SAVE]",
	"⏱️": "[TIMER]",
	"🤖": "[AUTO]",
	"👋": "[USER]",
	"⏳": "[WAIT]",
	"🔄": "[CYCLE]",
	"⏪": "[BACK]",
	
	# Light being states
	"🌟": "[LIGHT]",
	"💫": "[AWAKEN]", 
	"✨": "[MAGIC]",
	"🌌": "[SPACE]",
	"🔮": "[CRYSTAL]",
	
	# Project symbols
	"🏠": "[HOME]",
	"📊": "[DATA]",
	"🎨": "[CREATE]",
	"🔗": "[LINK]",
	"📈": "[GROW]",
	
	# ASCII art alternatives
	"🌈": "[-RAINBOW-]",
	"⭐": "[*]",
	"🔥": "[FIRE]",
	"💎": "[GEM]",
	"🎪": "[TENT]"
}

# Extended ASCII patterns from luminous data calibration
var terminal_safe_patterns: Dictionary = {
	"cross": "[+]",
	"cybe": "[#]", 
	"wall": "[|]",
	"space": "[ ]",
	"corner": "[/]",
	"center": "[·]",
	"line_h": "[-]",
	"line_v": "[|]",
	"box": "[□]",
	"filled": "[■]"
}

# Terminal capabilities detection
var is_windows_admin: bool = false
var supports_unicode: bool = true
var terminal_width: int = 80

func _ready() -> void:
	_detect_terminal_capabilities()

func _detect_terminal_capabilities() -> void:
	# Check if running in Windows admin mode
	if OS.get_name() == "Windows":
		# Simple heuristic - admin mode often has encoding issues
		var test_output = []
		OS.execute("cmd", ["/c", "echo", "🎮"], test_output)
		if test_output.size() > 0 and test_output[0].find("?") != -1:
			is_windows_admin = true
			supports_unicode = false
			print("[CONSOLE] Windows admin mode detected - using ASCII fallbacks")
	
	# Get terminal width if possible
	var env_cols = OS.get_environment("COLUMNS")
	if env_cols != "":
		terminal_width = env_cols.to_int()


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func safe_print(text: String) -> String:
	if not supports_unicode:
		return _convert_to_ascii(text)
	return text

func _convert_to_ascii(text: String) -> String:
	var result = text
	
	# Replace emojis with ASCII equivalents
	for emoji in emoji_to_ascii:
		result = result.replace(emoji, emoji_to_ascii[emoji])
	
	# Handle any remaining Unicode characters
	result = _sanitize_unicode(result)
	
	return result

func _sanitize_unicode(text: String) -> String:
	var result = ""
	for i in range(text.length()):
		var character = text[i]
		var code = character.unicode_at(0)
		
		# Keep standard ASCII (0-127)
		if code <= 127:
			result += character
		# Keep extended ASCII (128-255) 
		elif code <= 255:
			result += character
		# Replace anything else with safe alternative
		else:
			result += "?"
	
	return result

# Create ASCII art from calibration data patterns
func create_ascii_frame(width: int, height: int, title: String = "") -> String:
	var frame = ""
	
	# Top border
	frame += "+" + "-".repeat(width - 2) + "+\n"
	
	# Title line if provided
	if title != "":
		var title_line = "| " + title
		var padding = width - title_line.length() - 1
		if padding > 0:
			title_line += " ".repeat(padding)
		title_line += "|\n"
		frame += title_line
		frame += "+" + "-".repeat(width - 2) + "+\n"
	
	# Content area
	for i in range(height - 2):
		frame += "|" + " ".repeat(width - 2) + "|\n"
	
	# Bottom border
	frame += "+" + "-".repeat(width - 2) + "+\n"
	
	return frame

# Generate progress bars using ASCII
func create_progress_bar(current: float, maximum: float, width: int = 20) -> String:
	var filled = int((current / maximum) * width)
	var empty = width - filled
	return "[" + "=".repeat(filled) + " ".repeat(empty) + "]"

# Status display using calibration patterns
func create_status_display(project: String, status: String, progress: float) -> String:
	var display = ""
	display += "+---[ " + project.to_upper() + " ]---+\n"
	display += "| Status: " + status + "\n"
	display += "| Progress: " + create_progress_bar(progress, 100.0, 15) + " " + str(int(progress)) + "%\n"
	display += "+----------------------+\n"
	return display

# Console command wrapper for safe output
func console_print(manager: Node, text: String) -> void:
	var safe_text = safe_print(text)
	if manager.has_method("_print_to_console"):
		manager._print_to_console(safe_text)
	else:
		print(safe_text)

# Calibration test function using luminous data patterns
func test_terminal_calibration() -> void:
	print("=== TERMINAL CALIBRATION TEST ===")
	print("Unicode support: " + str(supports_unicode))
	print("Windows admin mode: " + str(is_windows_admin))
	print("Terminal width: " + str(terminal_width))
	print("")
	
	# Test emoji conversion
	print("Original: 🎮🔧✅🚀")
	print("Converted: " + safe_print("🎮🔧✅🚀"))
	print("")
	
	# Test ASCII patterns
	print(create_ascii_frame(40, 5, "TEST FRAME"))
	print("")
	
	# Test progress display
	print(create_status_display("TALKING_RAGDOLL", "TESTING", 75.5))

# Integration with existing console manager
func patch_console_manager(console_manager: Node) -> void:
	if not console_manager:
		return
	
	# In Godot 4, we can't directly replace methods
	# Instead, we'll add a property to indicate patching is active
	if console_manager.has_method("_print_to_console"):
		console_manager.set_meta("windows_console_fix_active", true)
		console_manager.set_meta("windows_console_fix", self)
