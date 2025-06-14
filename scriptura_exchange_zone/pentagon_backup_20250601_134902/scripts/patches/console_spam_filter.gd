# ==================================================
# SCRIPT NAME: console_spam_filter.gd
# DESCRIPTION: Intelligent console message filtering to reduce spam
# PURPOSE: Keep console clean and performant
# CREATED: 2025-05-28 - Console optimization
# ==================================================

extends UniversalBeingBase
# Message tracking
var message_counts = {}
var last_message_time = {}
var suppressed_messages = {}

# Filter settings
var max_repeats_per_minute = 3
var max_repeats_per_second = 1
var spam_threshold = 5
var cleanup_interval = 60.0  # seconds

# Message categories
enum MessagePriority {
	CRITICAL,    # Always show
	IMPORTANT,   # Show with minimal filtering  
	NORMAL,      # Standard filtering
	VERBOSE,     # Heavy filtering
	DEBUG        # Suppress when in loops
}

# Category patterns
var category_patterns = {
	"[LOADER] Resource not found": MessagePriority.VERBOSE,
	"[RULE] game_rules.txt": MessagePriority.VERBOSE, 
	"[RULE] Executing": MessagePriority.VERBOSE,
	"😊 [UniversalEntity] System satisfaction": MessagePriority.DEBUG,
	"[UniversalEntity]": MessagePriority.NORMAL,
	"[FloodgateController]": MessagePriority.IMPORTANT,
	"[ERROR]": MessagePriority.CRITICAL,
	"[WARNING]": MessagePriority.IMPORTANT,
	"[CRITICAL]": MessagePriority.CRITICAL
}

var console_manager: Node
var cleanup_timer: Timer

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	console_manager = get_node_or_null("/root/ConsoleManager")
	
	# Setup cleanup timer
	cleanup_timer = TimerManager.get_timer()
	cleanup_timer.wait_time = cleanup_interval
	cleanup_timer.timeout.connect(_cleanup_old_messages)
	cleanup_timer.autostart = true
	add_child(cleanup_timer)
	
	# Register console commands
	await get_tree().process_frame
	setup_console_commands()
	
	print("[ConsoleFilter] Message filtering active")


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
func should_show_message(message: String) -> bool:
	var current_time = Time.get_unix_time_from_system()
	var message_key = _get_message_key(message)
	var priority = _get_message_priority(message)
	
	# Always show critical messages
	if priority == MessagePriority.CRITICAL:
		return true
	
	# Track message frequency
	if not message_counts.has(message_key):
		message_counts[message_key] = 0
		last_message_time[message_key] = current_time
	
	message_counts[message_key] += 1
	var time_since_last = current_time - last_message_time[message_key]
	
	# Apply filtering based on priority and frequency
	var should_show = _apply_filtering_rules(message_key, priority, time_since_last, current_time)
	
	if should_show:
		last_message_time[message_key] = current_time
		
		# Add spam indicator if message was suppressed before
		if suppressed_messages.has(message_key) and suppressed_messages[message_key] > 0:
			var suppressed_count = suppressed_messages[message_key]
			message += " [color=gray](+" + str(suppressed_count) + " suppressed)[/color]"
			suppressed_messages[message_key] = 0
	else:
		# Track suppressed messages
		if not suppressed_messages.has(message_key):
			suppressed_messages[message_key] = 0
		suppressed_messages[message_key] += 1
	
	return should_show

func _get_message_key(message: String) -> String:
	# Extract meaningful part of message for grouping
	for pattern in category_patterns.keys():
		if message.begins_with(pattern):
			return pattern
	
	# For other messages, use first 50 characters
	return message.substr(0, 50)

func _get_message_priority(message: String) -> MessagePriority:
	for pattern in category_patterns.keys():
		if message.begins_with(pattern):
			return category_patterns[pattern]
	
	return MessagePriority.NORMAL

func _apply_filtering_rules(message_key: String, priority: MessagePriority, time_since_last: float, current_time: float) -> bool:
	var count = message_counts[message_key]
	
	match priority:
		MessagePriority.CRITICAL:
			return true
		
		MessagePriority.IMPORTANT:
			# Allow max 5 per minute
			return time_since_last > 12.0 or count <= 5
		
		MessagePriority.NORMAL:
			# Allow max 3 per minute
			return time_since_last > 20.0 or count <= 3
		
		MessagePriority.VERBOSE:
			# Allow max 2 per minute, and not more than 1 per 10 seconds
			if count > 10:  # After 10 times, show only once per minute
				return time_since_last > 60.0
			elif count > 2:  # After 2 times, slow down significantly  
				return time_since_last > 30.0
			else:
				return time_since_last > 10.0
		
		MessagePriority.DEBUG:
			# Very restrictive - only first few times, then once per minute
			if count > 20:
				return time_since_last > 300.0  # 5 minutes
			elif count > 5:
				return time_since_last > 60.0   # 1 minute
			else:
				return time_since_last > 15.0   # 15 seconds
	
	return true

func _cleanup_old_messages() -> void:
	var current_time = Time.get_unix_time_from_system()
	var keys_to_remove = []
	
	for key in last_message_time.keys():
		if current_time - last_message_time[key] > cleanup_interval * 2:
			keys_to_remove.append(key)
	
	for key in keys_to_remove:
		message_counts.erase(key)
		last_message_time.erase(key)
		suppressed_messages.erase(key)

# Public API for console manager
func filter_message(message: String) -> String:
	if should_show_message(message):
		return message
	else:
		return ""  # Empty string means don't show

func get_filter_stats() -> Dictionary:
	return {
		"tracked_messages": message_counts.size(),
		"total_suppressions": _count_total_suppressions(),
		"active_filters": category_patterns.size()
	}

func _count_total_suppressions() -> int:
	var total = 0
	for count in suppressed_messages.values():
		total += count
	return total

# Console commands for filter management
func setup_console_commands() -> void:
	if console_manager and console_manager.has_method("register_command"):
		console_manager.register_command("filter_stats", _cmd_filter_stats, "Show console filter statistics")
		console_manager.register_command("filter_reset", _cmd_filter_reset, "Reset message counters")
		console_manager.register_command("filter_config", _cmd_filter_config, "Configure filter settings")

func _cmd_filter_stats(_args: Array) -> void:
	var stats = get_filter_stats()
	_print("[color=cyan]=== Console Filter Stats ===[/color]")
	_print("Tracked message types: " + str(stats.tracked_messages))
	_print("Total messages suppressed: " + str(stats.total_suppressions))
	_print("Active filter patterns: " + str(stats.active_filters))
	
	if not suppressed_messages.is_empty():
		_print("\n[color=yellow]Currently Suppressed:[/color]")
		for key in suppressed_messages.keys():
			if suppressed_messages[key] > 0:
				_print("  " + key + ": " + str(suppressed_messages[key]))

func _cmd_filter_reset(_args: Array) -> void:
	message_counts.clear()
	last_message_time.clear()
	suppressed_messages.clear()
	_print("[color=green]Console filter counters reset[/color]")

func _cmd_filter_config(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: filter_config <setting> <value>")
		_print("Settings: max_per_minute, spam_threshold")
		_print("Current max_per_minute: " + str(max_repeats_per_minute))
		_print("Current spam_threshold: " + str(spam_threshold))
		return
	
	var setting = args[0]
	var value = int(args[1])
	
	match setting:
		"max_per_minute":
			max_repeats_per_minute = value
			_print("Max repeats per minute set to: " + str(value))
		"spam_threshold":
			spam_threshold = value
			_print("Spam threshold set to: " + str(value))
		_:
			_print("Unknown setting: " + setting)

func _print(text: String) -> void:
	if console_manager:
		console_manager._print_to_console(text)
	else:
		print(text)