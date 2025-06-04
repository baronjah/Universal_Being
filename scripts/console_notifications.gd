# ==================================================
# COMPONENT NAME: console_notifications.gd
# DESCRIPTION: Console Notifications Component
# PURPOSE: Send being events to console as notifications
# CREATED: 2025-06-03 - Claude Desktop MCP
# ==================================================

extends Node

class_name ConsoleNotificationsComponent

# Godot lifecycle functions removed - base UniversalBeing handles bridging to Pentagon Architecture

# Notification settings
var enabled: bool = true
var log_interactions: bool = true
var log_state_changes: bool = true
var log_consciousness: bool = true
var log_components: bool = true
var notification_prefix: String = "📢"

# References
var being_reference: Node
var console_reference: Node

# Signal
signal notification_sent(message: String)

func apply_to_being(being: Node) -> void:
	"""Apply notifications to a Universal Being"""
	being_reference = being
	
	# Find console
	_find_console()
	
	# Connect to all being signals
	_connect_being_signals()
	
	# Send initial notification
	_send_notification("%s now broadcasting to console!" % being.name)
	
	print("📢 Console notifications activated for %s" % being.name)

func _find_console() -> void:
	"""Find the console being for notifications"""
	var main = get_tree().root.get_node_or_null("Main")
	if main and main.has_method("find_console_being"):
		console_reference = main.find_console_being()
	
	if not console_reference:
		# Try to find by group
		var console_beings = get_tree().get_nodes_in_group("console_beings")
		if not console_beings.is_empty():
			console_reference = console_beings[0]

func _connect_being_signals() -> void:
	"""Connect to all relevant being signals"""
	if not being_reference:
		return
	
	# Core signals
	if being_reference.has_signal("consciousness_changed") and log_consciousness:
		being_reference.consciousness_changed.connect(_on_consciousness_changed)
	
	if being_reference.has_signal("being_evolved") and log_state_changes:
		being_reference.being_evolved.connect(_on_being_evolved)
	
	if being_reference.has_signal("component_added") and log_components:
		being_reference.component_added.connect(_on_component_added)
	
	if being_reference.has_signal("component_removed") and log_components:
		being_reference.component_removed.connect(_on_component_removed)
	
	# Interaction signals
	if being_reference.has_signal("clicked") and log_interactions:
		being_reference.clicked.connect(_on_clicked)
	
	if being_reference.has_signal("hover_entered") and log_interactions:
		being_reference.hover_entered.connect(_on_hover_entered)
	
	if being_reference.has_signal("hover_exited") and log_interactions:
		being_reference.hover_exited.connect(_on_hover_exited)

func _send_notification(message: String) -> void:
	"""Send a notification to the console"""
	if not enabled:
		return
	
	var full_message = "%s %s: %s" % [notification_prefix, being_reference.name, message]
	
	# Send to console if available
	if console_reference and console_reference.has_method("add_message"):
		console_reference.add_message("system", full_message)
	else:
		print(full_message)
	
	notification_sent.emit(full_message)

# Signal handlers
func _on_consciousness_changed(level: int) -> void:
	_send_notification("Consciousness evolved to level %d ✨" % level)

func _on_being_evolved(old_form: String, new_form: String) -> void:
	_send_notification("Transformed from %s to %s 🦋" % [old_form, new_form])

func _on_component_added(component_name: String) -> void:
	_send_notification("Component '%s' integrated 🔧" % component_name)

func _on_component_removed(component_name: String) -> void:
	_send_notification("Component '%s' removed 🔌" % component_name)

func _on_clicked() -> void:
	_send_notification("Received interaction click 👆")

func _on_hover_entered() -> void:
	_send_notification("Hover attention received 👁️")

func _on_hover_exited() -> void:
	_send_notification("Hover attention released 👁️‍🗨️")

# Configuration methods
func set_enabled(value: bool) -> void:
	enabled = value
	_send_notification("Notifications %s" % ("enabled" if value else "disabled"))

func set_notification_prefix(prefix: String) -> void:
	notification_prefix = prefix
	_send_notification("Prefix changed to '%s'" % prefix)

func get_component_info() -> Dictionary:
	"""Return component information"""
	return {
		"name": "Console Notifications Component",
		"type": "interface",
		"active": enabled,
		"properties": {
			"log_interactions": log_interactions,
			"log_state_changes": log_state_changes,
			"log_consciousness": log_consciousness,
			"log_components": log_components,
			"prefix": notification_prefix
		}
	}

func remove_from_being() -> void:
	"""Clean up when component is removed"""
	_send_notification("Console notifications deactivating... 👋")
	
	# Disconnect all signals
	if being_reference:
		if being_reference.has_signal("consciousness_changed"):
			being_reference.consciousness_changed.disconnect(_on_consciousness_changed)
		if being_reference.has_signal("being_evolved"):
			being_reference.being_evolved.disconnect(_on_being_evolved)
		# ... disconnect other signals as needed

# AI Interface
func ai_get_state() -> Dictionary:
	"""Get component state for AI inspection"""
	return {
		"enabled": enabled,
		"settings": {
			"log_interactions": log_interactions,
			"log_state_changes": log_state_changes,
			"log_consciousness": log_consciousness,
			"log_components": log_components
		},
		"notifications_sent": get_signal_connection_list("notification_sent").size()
	}

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	"""Allow AI to invoke component methods"""
	match method_name:
		"enable":
			set_enabled(true)
			return "Notifications enabled"
		"disable":
			set_enabled(false)
			return "Notifications disabled"
		"send_custom":
			if args.size() > 0:
				_send_notification(args[0])
				return "Custom notification sent"
		"set_prefix":
			if args.size() > 0:
				set_notification_prefix(args[0])
				return "Prefix updated"
	
	return "Unknown method: " + method_name
