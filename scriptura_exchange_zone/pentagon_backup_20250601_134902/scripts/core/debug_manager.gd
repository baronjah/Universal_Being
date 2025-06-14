extends UniversalBeingBase
# Debug Manager - Controls console output verbosity
# Reduces spam from 10k lines to only what matters

signal debug_level_changed(category: String, enabled: bool)

var debug_categories = {
	"jsh_tree": false,  # JSH tree updates (major spammer)
	"performance": false,  # Performance warnings
	"physics": false,  # Physics debug info
	"creation": true,  # Object creation messages
	"commands": true,  # Console command execution
	"errors": true,  # Always show errors
	"warnings": true,  # Show warnings
	"asset_loading": false,  # Asset loading messages
	"inspector": false,  # Inspector updates
	"universal_being": true,  # Universal Being actions
	"ragdoll": false,  # Ragdoll physics updates
	"console_spam": false  # General console spam
}

var spam_patterns = [
	"Performance:",
	"JSH tree",
	"Inspector:",
	"Physics step",
	"Ragdoll update",
	"Asset loaded:",
	"Tree update:",
	"Memory usage:",
	"Frame time:",
	"Draw calls:"
]

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Hook into print functions
	set_process(true)
	print("[DebugManager] Initialized - Console spam reduction active")


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
func is_debug_enabled(category: String) -> bool:
	return debug_categories.get(category, false)

func set_debug_category(category: String, enabled: bool):
	if category in debug_categories:
		debug_categories[category] = enabled
		debug_level_changed.emit(category, enabled)
		print("[DebugManager] %s debug: %s" % [category, "ON" if enabled else "OFF"])

func toggle_debug_category(category: String):
	if category in debug_categories:
		set_debug_category(category, not debug_categories[category])

func should_print(message: String) -> bool:
	# Always print errors
	if "error" in message.to_lower() or "Error" in message:
		return true
	
	# Check spam patterns
	for pattern in spam_patterns:
		if pattern in message and not debug_categories.get("console_spam", false):
			return false
	
	# Check specific categories
	if "JSH" in message and not debug_categories.get("jsh_tree", false):
		return false
	
	if "Performance" in message and not debug_categories.get("performance", false):
		return false
	
	if "Physics" in message and not debug_categories.get("physics", false):
		return false
	
	if "Inspector" in message and not debug_categories.get("inspector", false):
		return false
	
	return true

func filtered_print(message: String):
	if should_print(message):
		print(message)

func get_debug_status() -> String:
	var status = "[Debug Categories]\n"
	for category in debug_categories:
		status += "%s: %s\n" % [category, "ON" if debug_categories[category] else "OFF"]
	return status

# Console commands
func _on_console_command(command: String, args: Array):
	match command:
		"debug":
			if args.size() == 0:
				return get_debug_status()
			elif args.size() == 1:
				if args[0] == "all":
					for cat in debug_categories:
						set_debug_category(cat, true)
					return "All debug categories enabled"
				elif args[0] == "none":
					for cat in debug_categories:
						if cat != "errors":  # Keep errors on
							set_debug_category(cat, false)
					return "All debug categories disabled (except errors)"
			elif args.size() == 2:
				var cat = args[0]
				var enable = args[1] == "on" or args[1] == "true"
				if cat in debug_categories:
					set_debug_category(cat, enable)
					return "%s debug: %s" % [cat, "ON" if enable else "OFF"]
				else:
					return "Unknown debug category: %s" % cat
		"spam":
			set_debug_category("console_spam", not debug_categories.get("console_spam", false))
			return "Console spam: %s" % ["ON" if debug_categories.get("console_spam", false) else "OFF"]