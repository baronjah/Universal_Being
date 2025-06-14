# 🏛️ Console Channel System - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
class_name ConsoleChannelSystem

# Console Channel System - Organize console output by channels

signal channel_changed(channel: String)

# Channel definitions
enum Channel {
	ALL,
	SYSTEM,
	GAME,
	UNIVERSAL,
	ERROR,
	DEBUG,
	PLAYER,
	RULES
}

var channel_names = {
	Channel.ALL: "All",
	Channel.SYSTEM: "System",
	Channel.GAME: "Game",
	Channel.UNIVERSAL: "Universal",
	Channel.ERROR: "Errors",
	Channel.DEBUG: "Debug",
	Channel.PLAYER: "Player",
	Channel.RULES: "Rules"
}

var channel_colors = {
	Channel.SYSTEM: "#808080",    # Gray
	Channel.GAME: "#00ff00",      # Green
	Channel.UNIVERSAL: "#00ffff", # Cyan
	Channel.ERROR: "#ff0000",     # Red
	Channel.DEBUG: "#ffff00",     # Yellow
	Channel.PLAYER: "#ff00ff",    # Magenta
	Channel.RULES: "#00ff80"      # Teal
}

# Channel state
var active_channels: Dictionary = {}
var current_filter: Channel = Channel.ALL
var channel_buttons: Dictionary = {}
var channel_button_container: HBoxContainer

# Message history with channels
var channeled_messages: Array[Dictionary] = []
const MAX_MESSAGES = 1000


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
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
func setup_channels(console_ui: Control) -> void:
	"""Initialize channel system UI"""
	
	# Create channel button container
	channel_button_container = HBoxContainer.new()
	channel_button_container.name = "ChannelButtons"
	
	# Style the container
	var panel = PanelContainer.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	panel_style.content_margin_left = 5
	panel_style.content_margin_right = 5
	panel_style.content_margin_top = 2
	panel_style.content_margin_bottom = 2
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# Add label
	var label = Label.new()
	label.text = "Channels: "
	label.add_theme_color_override("font_color", Color.WHITE)
	FloodgateController.universal_add_child(label, channel_button_container)
	
	# Create channel buttons
	for channel in Channel.values():
		if channel == Channel.ALL:
			continue  # Skip ALL, use individual toggles instead
			
		var btn = Button.new()
		btn.text = channel_names[channel]
		btn.toggle_mode = true
		btn.pressed = true  # All channels on by default
		btn.custom_minimum_size = Vector2(80, 24)
		
		# Style the button
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
		normal_style.border_width_all = 1
		normal_style.border_color = Color(channel_colors[channel])
		
		var pressed_style = StyleBoxFlat.new()
		pressed_style.bg_color = Color(channel_colors[channel])
		pressed_style.bg_color.a = 0.3
		pressed_style.border_width_all = 2
		pressed_style.border_color = Color(channel_colors[channel])
		
		btn.add_theme_stylebox_override("normal", normal_style)
		btn.add_theme_stylebox_override("pressed", pressed_style)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color(channel_colors[channel]))
		
		# Connect button
		btn.toggled.connect(_on_channel_toggled.bind(channel))
		
		FloodgateController.universal_add_child(btn, channel_button_container)
		channel_buttons[channel] = btn
		active_channels[channel] = true
	
	# Add "All On/Off" buttons
	FloodgateController.universal_add_child(VSeparator.new(, channel_button_container))
	
	var all_on_btn = Button.new()
	all_on_btn.text = "All On"
	all_on_btn.custom_minimum_size = Vector2(60, 24)
	all_on_btn.pressed.connect(_enable_all_channels)
	FloodgateController.universal_add_child(all_on_btn, channel_button_container)
	
	var all_off_btn = Button.new()
	all_off_btn.text = "All Off"
	all_off_btn.custom_minimum_size = Vector2(60, 24)
	all_off_btn.pressed.connect(_disable_all_channels)
	FloodgateController.universal_add_child(all_off_btn, channel_button_container)
	
	# Add clear button
	FloodgateController.universal_add_child(VSeparator.new(, channel_button_container))
	
	var clear_btn = Button.new()
	clear_btn.text = "Clear"
	clear_btn.custom_minimum_size = Vector2(60, 24)
	clear_btn.pressed.connect(_clear_console)
	FloodgateController.universal_add_child(clear_btn, channel_button_container)
	
	FloodgateController.universal_add_child(channel_button_container, panel)
	
	# Insert at top of console
	var console_vbox = console_ui.get_node_or_null("ConsolePanel/VBoxContainer")
	if console_vbox:
		FloodgateController.universal_add_child(panel, console_vbox)
		console_vbox.move_child(panel, 1)  # After title bar

func print_to_channel(message: String, channel: Channel = Channel.GAME) -> void:
	"""Print a message to a specific channel"""
	
	# Store message with channel
	var msg_data = {
		"text": message,
		"channel": channel,
		"timestamp": Time.get_ticks_msec(),
		"color": channel_colors.get(channel, "#ffffff")
	}
	
	channeled_messages.append(msg_data)
	
	# Limit message history
	if channeled_messages.size() > MAX_MESSAGES:
		channeled_messages.pop_front()
	
	# Only display if channel is active
	if active_channels.get(channel, true):
		var formatted = "[color=%s][%s][/color] %s" % [
			msg_data.color,
			channel_names[channel],
			message
		]
		_display_message(formatted)

func _on_channel_toggled(pressed: bool, channel: Channel) -> void:
	"""Handle channel button toggle"""
	active_channels[channel] = pressed
	_refresh_display()
	channel_changed.emit(channel_names[channel])

func _enable_all_channels() -> void:
	"""Enable all channels"""
	for channel in channel_buttons:
		channel_buttons[channel].pressed = true
		active_channels[channel] = true
	_refresh_display()

func _disable_all_channels() -> void:
	"""Disable all channels"""
	for channel in channel_buttons:
		channel_buttons[channel].pressed = false
		active_channels[channel] = false
	_refresh_display()

func _refresh_display() -> void:
	"""Refresh console display based on active channels"""
	_clear_display()
	
	# Re-display messages from active channels
	for msg_data in channeled_messages:
		if active_channels.get(msg_data.channel, true):
			var formatted = "[color=%s][%s][/color] %s" % [
				msg_data.color,
				channel_names[msg_data.channel],
				msg_data.text
			]
			_display_message(formatted)

func _clear_console() -> void:
	"""Clear all messages"""
	channeled_messages.clear()
	_clear_display()

func _display_message(_formatted_text: String) -> void:
	"""Display a formatted message (implement in console_manager)"""
	pass

func _clear_display() -> void:
	"""Clear the display (implement in console_manager)"""
	pass

# Convenience functions for common channels
func print_system(message: String) -> void:
	print_to_channel(message, Channel.SYSTEM)

func print_game(message: String) -> void:
	print_to_channel(message, Channel.GAME)

func print_universal(message: String) -> void:
	print_to_channel(message, Channel.UNIVERSAL)

func print_error(message: String) -> void:
	print_to_channel(message, Channel.ERROR)

func print_debug(message: String) -> void:
	print_to_channel(message, Channel.DEBUG)

func print_player(message: String) -> void:
	print_to_channel(message, Channel.PLAYER)

func print_rules(message: String) -> void:
	print_to_channel(message, Channel.RULES)
