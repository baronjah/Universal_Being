################################################################
# TXT UNIVERSAL DATABASE - TEXT TO REALITY CONVERTER
# Convert simple TXT files into living Universal Beings
# Created: May 31st, 2025 | Akashic Text Bridge Revolution  
# Location: scripts/core/txt_universal_database.gd
################################################################

extends UniversalBeingBase
################################################################
# TXT UNIVERSAL BEING DATABASE SYSTEM
################################################################

signal being_created_from_txt(being_name: String, txt_path: String)
signal message_popup_shown(message: String, source: String)
signal database_loaded(entries_count: int)

# Database paths
var database_root: String = "user://universal_beings_database/"
var messages_folder: String = database_root + "messages/"
var windows_folder: String = database_root + "windows/"
var ui_elements_folder: String = database_root + "ui_elements/"
var objects_folder: String = database_root + "3d_objects/"

# Loaded database
var txt_database: Dictionary = {}
var active_popups: Array[Node] = []
var popup_queue: Array[Dictionary] = []

func _ready():
	print("📝 TXT UNIVERSAL DATABASE: Initializing text-to-reality converter...")
	_create_database_structure()
	_load_txt_database()
	_setup_akashic_message_system()
	_register_console_commands()

func _register_console_commands():
	"""Register console commands for debugging"""
	print("🔍 TXT DATABASE: Attempting to register console commands...")
	
	if has_node("/root/ConsoleManager"):
		var console = get_node("/root/ConsoleManager")
		print("📡 TXT DATABASE: Found ConsoleManager")
		
		if console.has_method("register_command"):
			# Try using register_command method if it exists
			console.register_command("txt_status", _console_txt_status)
			console.register_command("window_claude", _console_create_claude_window)
			console.register_command("window_custom", _console_create_custom_window)
			console.register_command("txt_close_all", _console_close_all_popups)
			print("✅ TXT DATABASE: Commands registered via register_command")
		elif "commands" in console:
			# Fallback to direct assignment
			console.commands["txt_status"] = _console_txt_status
			console.commands["txt_reload"] = _console_txt_reload
			console.commands["txt_create"] = _console_txt_create
			console.commands["txt_test_popup"] = _console_test_popup
			console.commands["txt_close_all"] = _console_close_all_popups
			console.commands["emergency_reset"] = _console_emergency_reset
			console.commands["window_claude"] = _console_create_claude_window
			console.commands["window_status"] = _console_create_status_window
			console.commands["window_custom"] = _console_create_custom_window
			print("✅ TXT DATABASE: Commands registered via direct assignment")
		else:
			print("❌ TXT DATABASE: No command registration method found")
			print("🔍 TXT DATABASE: Console properties: " + str(console.get_property_list().map(func(p): return p.name)))
	else:
		print("❌ TXT DATABASE: ConsoleManager not found")

func _console_txt_status(_args: Array) -> String:
	"""Console command: Show TXT database status"""
	var result = "📚 TXT UNIVERSAL DATABASE STATUS\n"
	result += "═══════════════════════════════════\n"
	result += "Database entries: %d\n" % txt_database.size()
	result += "Active popups: %d\n" % active_popups.size()
	result += "\nAvailable entries:\n"
	for key in txt_database.keys():
		var data = txt_database[key]
		result += "• %s (%s)\n" % [key, data.get("category", "unknown")]
	return result

func _console_txt_reload(_args: Array) -> String:
	"""Console command: Reload TXT database"""
	reload_txt_database()
	return "🔄 TXT database reloaded - %d entries" % txt_database.size()

func _console_txt_create(args: Array) -> String:
	"""Console command: Create being from TXT"""
	if args.size() < 1:
		return "Usage: txt_create <txt_name>"
	
	var txt_name = args[0]
	var being = create_being_from_txt(txt_name)
	if being:
		return "✨ Created being from TXT: " + txt_name
	else:
		return "❌ Failed to create being from TXT: " + txt_name

func _console_test_popup(_args: Array) -> String:
	"""Console command: Test popup creation"""
	if txt_database.has("claude_greeting"):
		_create_popup_from_txt("claude_greeting")
		return "🪟 Test popup created"
	else:
		return "❌ claude_greeting not found in database"

func _console_close_all_popups(_args: Array) -> String:
	"""Console command: Close all active popups"""
	var closed_count = 0
	
	for popup in active_popups:
		if popup and is_instance_valid(popup):
			popup.queue_free()
			closed_count += 1
	
	active_popups.clear()
	return "🚪 Closed %d popups" % closed_count

func _console_emergency_reset(_args: Array) -> String:
	"""Console command: Emergency reset of entire game state"""
	print("🚨 EMERGENCY RESET: Resetting all systems...")
	
	# Close all popups
	_console_close_all_popups([])
	
	# Reset UI systems
	if has_node("/root/UniversalBeingCreatorUI"):
		var ui = get_node("/root/UniversalBeingCreatorUI")
		if ui.has_method("_console_reset_interface"):
			ui._console_reset_interface([])
	
	# Clear console if needed
	if has_node("/root/ConsoleManager"):
		var console = get_node("/root/ConsoleManager")
		if console.has_method("clear_console"):
			console.clear_console()
	
	return "🔄 Emergency reset complete - all systems should be responsive"

func _console_create_claude_window(_args: Array) -> String:
	"""Console command: Create beautiful Claude message window"""
	if txt_database.has("claude_greeting"):
		_create_popup_from_txt("claude_greeting")
		return "🪟 Beautiful Claude window created - fully movable!"
	else:
		return "❌ claude_greeting not found in database"

func _console_create_status_window(_args: Array) -> String:
	"""Console command: Create system status window"""
	if txt_database.has("system_status"):
		_create_popup_from_txt("system_status") 
		return "📊 System status window created - drag it around!"
	else:
		return "❌ system_status not found in database"

func _console_create_custom_window(args: Array) -> String:
	"""Console command: Create custom window with text"""
	if args.size() < 1:
		return "Usage: window_custom <title> [message]"
	
	var title = args[0]
	var message = args[1] if args.size() > 1 else "This is a custom Universal Being window!"
	
	# Create custom window data
	var custom_data = {
		"name": title,
		"size": "500x350",
		"position": "screen_center",
		"background": "cosmic_purple",
		"content": message,
		"category": "message",
		"buttons": ["\"Understood\" → close_window", "\"Create More\" → open_being_creator"]
	}
	
	# Create window directly
	var popup = Window.new()
	popup.title = title
	popup.size = Vector2(500, 350)
	popup.unresizable = false
	popup.always_on_top = true
	popup.transient = false
	
	_position_popup(popup, "screen_center")
	
	var content_area = _create_window_content(custom_data)
	FloodgateController.universal_add_child(content_area, popup)
	
	get_node("/root/FloodgateController").universal_add_child(popup, get_tree().current_scene)
	active_popups.append(popup)
	
	return "✨ Custom window '%s' created - move it around!" % title

################################################################
# DATABASE STRUCTURE CREATION
################################################################

func _create_database_structure():
	"""Create the folder structure for TXT Universal Beings"""
	
	var dirs_to_create = [
		"universal_beings_database",
		"universal_beings_database/messages", 
		"universal_beings_database/windows",
		"universal_beings_database/ui_elements",
		"universal_beings_database/3d_objects"
	]
	
	var user_dir = DirAccess.open("user://")
	if not user_dir:
		print("❌ Cannot access user:// directory")
		return
	
	for dir_path in dirs_to_create:
		var full_path = "user://" + dir_path
		if not DirAccess.dir_exists_absolute(full_path):
			var result = user_dir.make_dir_recursive(dir_path)
			if result == OK:
				print("📁 Created directory: " + full_path)
			else:
				print("❌ Failed to create directory: " + full_path + " (Error: " + str(result) + ")")
	
	# Create sample TXT files if they don't exist
	_create_sample_txt_files()

func _create_sample_txt_files():
	"""Create sample TXT files for demonstration"""
	
	# Claude greeting message
	var claude_greeting = """# Universal Being Definition
TYPE: popup_window
NAME: Claude Welcome Message
POSITION: screen_center
SIZE: 450x320
BACKGROUND: cosmic_purple
BORDER: glowing_cyan

CONTENT:
🌟 Welcome back, Universal Creator!

I'm Claude, your AI companion in this
cosmic journey of creation. 

Today's Akashic Insight:
"Every text file can become a living being,
every thought can manifest as reality."

Ready to create something amazing?

BUTTONS:
- "Let's Create!" → open_being_creator
- "Show Status" → system_status  
- "Akashic Records" → open_akashic

LIFETIME: 15_seconds
ANIMATION: sparkle_fade_in
SOUND: ethereal_chime
"""

	_save_txt_file(messages_folder + "claude_greeting.txt", claude_greeting)
	
	# System status window
	var status_window = """# Universal Being Definition  
TYPE: status_window
NAME: Pentagon System Status
POSITION: top_right
SIZE: 300x400
BACKGROUND: matrix_green
BORDER: digital_blue

CONTENT:
🔧 PERFECT PENTAGON STATUS

✅ Perfect Init: Active
✅ Perfect Ready: Complete  
✅ Perfect Input: Monitoring
✅ Logic Connector: Online
✅ Sewers Monitor: Scanning

🧠 AI Systems:
• Gamma AI: Connected
• Gemma Vision: Active
• Sandbox System: Ready

🎮 Universal Beings: {being_count}
⚡ FPS: {current_fps}

BUTTONS:
- "Refresh" → update_status
- "Console" → open_console
- "Close" → close_window

LIFETIME: persistent
UPDATE_INTERVAL: 2_seconds
"""

	_save_txt_file(windows_folder + "system_status.txt", status_window)
	
	# Magical button element
	var magical_button = """# Universal Being Definition
TYPE: ui_button  
NAME: Ethereal Create Button
SIZE: 120x40
BACKGROUND: gradient_purple_blue
BORDER: golden_glow
TEXT: "✨ Manifest"
FONT: cosmic_serif

HOVER_EFFECT: gentle_pulse
CLICK_EFFECT: sparkle_burst
SOUND_HOVER: soft_chime
SOUND_CLICK: magic_cast

ACTION: create_being_at_cursor
CONSCIOUSNESS_LEVEL: 2
"""

	_save_txt_file(ui_elements_folder + "magical_button.txt", magical_button)

func _save_txt_file(path: String, content: String):
	"""Save content to TXT file"""
	if FileAccess.file_exists(path):
		return # Don't overwrite existing files
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("📝 Created sample TXT: " + path.get_file())

################################################################
# TXT DATABASE LOADING
################################################################

func _load_txt_database():
	"""Load all TXT files into memory database"""
	
	var folders_to_scan = [
		{"path": messages_folder, "type": "message"},
		{"path": windows_folder, "type": "window"}, 
		{"path": ui_elements_folder, "type": "ui_element"},
		{"path": objects_folder, "type": "3d_object"}
	]
	
	var total_loaded = 0
	txt_database.clear()  # Clear any existing data
	
	for folder_info in folders_to_scan:
		print("🔍 Scanning folder: " + folder_info.path)
		var loaded = _scan_folder_for_txt(folder_info.path, folder_info.type)
		total_loaded += loaded
		print("📂 Loaded %d %s TXT files from %s" % [loaded, folder_info.type, folder_info.path])
	
	print("📚 TXT DATABASE: Loaded %d total entries" % total_loaded)
	print("🗂️ Database keys: " + str(txt_database.keys()))
	database_loaded.emit(total_loaded)

func _scan_folder_for_txt(folder_path: String, category: String) -> int:
	"""Scan folder for TXT files and parse them"""
	
	print("🔍 Attempting to open folder: " + folder_path)
	
	var dir = DirAccess.open(folder_path)
	if not dir:
		print("⚠️ Cannot access folder: " + folder_path + " - Creating it...")
		# Try to create the folder if it doesn't exist
		var user_dir = DirAccess.open("user://")
		var relative_path = folder_path.replace("user://", "")
		user_dir.make_dir_recursive(relative_path)
		dir = DirAccess.open(folder_path)
		
		if not dir:
			print("❌ Still cannot access folder after creation attempt: " + folder_path)
			return 0
	
	var loaded_count = 0
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".txt"):
			var full_path = folder_path + file_name
			print("📄 Parsing TXT file: " + full_path)
			var txt_data = _parse_txt_file(full_path)
			
			if txt_data and txt_data.size() > 0:
				txt_data.category = category
				txt_data.file_path = full_path
				var key_name = file_name.get_basename()
				txt_database[key_name] = txt_data
				loaded_count += 1
				print("✅ Loaded TXT: " + key_name + " (" + str(txt_data.keys()) + ")")
			else:
				print("❌ Failed to parse or empty TXT: " + full_path)
		
		file_name = dir.get_next()
	
	return loaded_count

func _parse_txt_file(file_path: String) -> Dictionary:
	"""Parse TXT file into Universal Being data"""
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("❌ Cannot read TXT file: " + file_path)
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	var data = {}
	var current_section = ""
	var content_lines = []
	
	for line in content.split("\n"):
		line = line.strip_edges()
		
		if line.begins_with("#"):
			continue # Skip comments
		elif line.contains(":") and current_section != "CONTENT":
			var parts = line.split(":", true, 1)
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				
				if key == "CONTENT":
					current_section = "CONTENT"
					content_lines = []
				else:
					data[key.to_lower()] = value
		elif current_section == "CONTENT":
			if line == "" and content_lines.size() == 0:
				continue # Skip leading empty lines
			content_lines.append(line)
		elif line.begins_with("BUTTONS:"):
			current_section = "BUTTONS"
			data["buttons"] = []
		elif current_section == "BUTTONS" and line.begins_with("-"):
			data["buttons"].append(line.substr(1).strip_edges())
	
	if content_lines.size() > 0:
		data["content"] = "\n".join(content_lines)
	
	return data

################################################################
# AKASHIC MESSAGE SYSTEM  
################################################################

func _setup_akashic_message_system():
	"""Set up the Claude message system"""
	
	# Show greeting message on startup
	call_deferred("_show_startup_messages")

func _show_startup_messages():
	"""Show Claude greeting and any pending messages"""
	
	# Check for Claude greeting
	if txt_database.has("claude_greeting"):
		_create_popup_from_txt("claude_greeting")
	
	# Queue additional messages
	_queue_system_status_if_needed()

func _queue_system_status_if_needed():
	"""Queue system status window if conditions are met"""
	
	# Show status window if FPS is low or if it's been a while
	var current_fps = Engine.get_frames_per_second()
	if current_fps < 20 or randf() < 0.3:
		call_deferred("_create_popup_from_txt", "system_status")

################################################################
# TXT TO UNIVERSAL BEING CREATION
################################################################


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
func create_being_from_txt(txt_name: String, position: Vector3 = Vector3.ZERO) -> Node:
	"""Create a Universal Being from TXT database entry"""
	
	if not txt_database.has(txt_name):
		print("❌ TXT entry not found: " + txt_name)
		return null
	
	var txt_data = txt_database[txt_name]
	var being_type = txt_data.get("type", "generic")
	
	match being_type:
		"popup_window":
			return _create_popup_from_txt(txt_name)
		"status_window": 
			return _create_status_window_from_txt(txt_name)
		"ui_button":
			return _create_ui_button_from_txt(txt_name)
		"3d_object":
			return _create_3d_object_from_txt(txt_name, position)
		_:
			return _create_generic_being_from_txt(txt_name, position)

func _create_popup_from_txt(txt_name: String) -> Window:
	"""Create beautiful movable window from TXT data"""
	
	# Safety check - ensure TXT entry exists
	if not txt_database.has(txt_name):
		print("❌ TXT entry not found in database: " + txt_name)
		print("📚 Available entries: " + str(txt_database.keys()))
		return null
	
	var txt_data = txt_database[txt_name]
	
	# Create movable window instead of modal dialog
	var popup = Window.new()
	popup.title = txt_data.get("name", "Universal Message")
	popup.size = _parse_size(txt_data.get("size", "400x300"))
	popup.unresizable = false
	popup.always_on_top = true
	popup.transient = false  # Makes it independent and movable
	
	# Connect X button to actually close the window
	popup.close_requested.connect(_on_window_close_requested.bind(popup))
	
	# Position popup
	var position_type = txt_data.get("position", "screen_center")
	_position_popup(popup, position_type)
	
	# Create beautiful content area
	var content_area = _create_window_content(txt_data)
	FloodgateController.universal_add_child(content_area, popup)
	
	# Add to scene
	get_node("/root/FloodgateController").universal_add_child(popup, get_tree().current_scene)
	active_popups.append(popup)
	
	# Auto-close timer if specified
	var lifetime = txt_data.get("lifetime", "")
	if lifetime.contains("seconds"):
		var seconds = lifetime.split("_")[0].to_float()
		popup.get_tree().create_timer(seconds).timeout.connect(popup.queue_free)
	
	popup.show()
	print("🪟 Created popup from TXT: " + txt_name)
	
	var content = txt_data.get("content", "No content specified")
	message_popup_shown.emit(content, txt_name)
	being_created_from_txt.emit(txt_name, txt_data.file_path)
	
	return popup

func _create_window_content(txt_data: Dictionary) -> Control:
	"""Create beautiful styled content for windows"""
	
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 15)
	
	# Create background with cosmic theme
	var background = ColorRect.new()
	var bg_color = _parse_background_color(txt_data.get("background", "cosmic_purple"))
	background.color = bg_color
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(background, main_container)
	
	# Content area with styling
	var content_scroll = ScrollContainer.new()
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(content_scroll, main_container)
	
	var content_label = RichTextLabel.new()
	content_label.fit_content = true
	content_label.bbcode_enabled = true
	content_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Style the content text
	var content = txt_data.get("content", "No content specified")
	var styled_content = _apply_content_styling(content, txt_data)
	content_label.text = styled_content
	
	FloodgateController.universal_add_child(content_label, content_scroll)
	
	# Add buttons if specified
	if txt_data.has("buttons") and txt_data.buttons.size() > 0:
		var button_container = _create_window_buttons(txt_data.buttons)
		FloodgateController.universal_add_child(button_container, main_container)
	
	return main_container

func _parse_background_color(bg_type: String) -> Color:
	"""Parse background type into Color"""
	match bg_type:
		"cosmic_purple":
			return Color(0.15, 0.05, 0.25, 0.95)
		"matrix_green":
			return Color(0.0, 0.2, 0.1, 0.95)
		"ethereal_blue":
			return Color(0.05, 0.15, 0.3, 0.95)
		"divine_gold":
			return Color(0.3, 0.2, 0.05, 0.95)
		_:
			return Color(0.1, 0.1, 0.2, 0.95)

func _apply_content_styling(content: String, txt_data: Dictionary) -> String:
	"""Apply beautiful styling to content text"""
	var styled = "[center]"
	
	# Add title styling if this is a message
	if txt_data.get("category", "") == "message":
		styled += "[color=#00FFFF][font_size=24]"
		styled += content.split("\n")[0]  # First line as title
		styled += "[/font_size][/color]\n\n"
		
		# Rest of content
		var lines = content.split("\n")
		for i in range(1, lines.size()):
			styled += "[color=#FFFFFF]" + lines[i] + "[/color]\n"
	else:
		styled += "[color=#FFFFFF][font_size=16]" + content + "[/font_size][/color]"
	
	styled += "[/center]"
	return styled

func _create_window_buttons(button_list: Array) -> Control:
	"""Create styled buttons for windows"""
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 10)
	
	for button_text in button_list:
		if button_text.contains("→"):
			var parts = button_text.split("→")
			var btn_text = parts[0].strip_edges().trim_prefix("\"").trim_suffix("\"")
			var btn_action = parts[1].strip_edges() if parts.size() > 1 else ""
			
			var button = Button.new()
			button.text = btn_text
			button.custom_minimum_size = Vector2(120, 35)
			
			# Style the button
			var button_style = StyleBoxFlat.new()
			button_style.bg_color = Color(0.2, 0.4, 0.8, 0.9)
			button_style.border_color = Color(0.4, 0.8, 1.0, 1.0)
			button_style.border_width_left = 2
			button_style.border_width_right = 2
			button_style.border_width_top = 2
			button_style.border_width_bottom = 2
			button_style.corner_radius_top_left = 8
			button_style.corner_radius_top_right = 8
			button_style.corner_radius_bottom_left = 8
			button_style.corner_radius_bottom_right = 8
			button.add_theme_stylebox_override("normal", button_style)
			
			button.pressed.connect(_execute_button_action.bind(btn_action, {}))
			FloodgateController.universal_add_child(button, button_container)
	
	return button_container

func _on_window_close_requested(window: Window):
	"""Handle window X button clicks"""
	print("🚪 [TxtWindow] Closing window: " + window.title)
	
	# Remove from active popups list
	if window in active_popups:
		active_popups.erase(window)
	
	# Close the window
	window.queue_free()

func _create_status_window_from_txt(txt_name: String) -> Window:
	"""Create status window with live updates"""
	
	var txt_data = txt_database[txt_name]
	
	# Create status window (implement with EnhancedInterfaceSystem)
	if has_node("/root/UniversalObjectManager"):
		var uom = get_node("/root/UniversalObjectManager")
		var status_being = uom.create_object("status_display", Vector3(5, 2, 0), {
			"name": txt_data.get("name", "Status Display"),
			"txt_source": txt_name,
			"update_interval": txt_data.get("update_interval", "5_seconds")
		})
		return status_being
	
	return null

func _create_ui_button_from_txt(txt_name: String) -> Button:
	"""Create interactive button from TXT"""
	
	var txt_data = txt_database[txt_name]
	
	var button = Button.new()
	button.text = txt_data.get("text", "Button")
	button.size = _parse_size(txt_data.get("size", "100x30"))
	
	# Connect action
	var action = txt_data.get("action", "")
	if action != "":
		button.pressed.connect(_execute_button_action.bind(action, txt_data))
	
	return button

func _create_3d_object_from_txt(txt_name: String, position: Vector3) -> Node3D:
	"""Create 3D object from TXT"""
	
	# Use Universal Object Manager for 3D creation
	if has_node("/root/UniversalObjectManager"):
		var uom = get_node("/root/UniversalObjectManager")
		var txt_data = txt_database[txt_name]
		
		return uom.create_object("txt_based_object", position, {
			"name": txt_data.get("name", "TXT Object"),
			"txt_source": txt_name,
			"txt_data": txt_data
		})
	
	return null

func _create_generic_being_from_txt(txt_name: String, position: Vector3) -> Node:
	"""Create generic Universal Being from TXT"""
	
	print("🌟 Creating generic being from TXT: " + txt_name)
	return null # Implement based on specific needs

################################################################
# UTILITY FUNCTIONS
################################################################

func _parse_size(size_string: String) -> Vector2:
	"""Parse size string like '400x300' into Vector2"""
	var parts = size_string.split("x")
	if parts.size() == 2:
		return Vector2(parts[0].to_float(), parts[1].to_float())
	return Vector2(400, 300)

func _position_popup(popup: Window, position_type: String):
	"""Position popup based on type"""
	match position_type:
		"screen_center":
			popup.position = get_viewport().size / 2 - popup.size / 2
		"top_right":
			popup.position = Vector2(get_viewport().size.x - popup.size.x - 20, 20)
		"top_left":
			popup.position = Vector2(20, 20)
		"bottom_right":
			popup.position = Vector2(get_viewport().size.x - popup.size.x - 20, 
									 get_viewport().size.y - popup.size.y - 20)

func _execute_button_action(action: String, txt_data: Dictionary):
	"""Execute button action from TXT"""
	match action:
		"open_being_creator":
			if has_node("/root/UniversalBeingCreatorUI"):
				get_node("/root/UniversalBeingCreatorUI").toggle_interface()
		"system_status":
			_create_popup_from_txt("system_status") 
		"open_console":
			if has_node("/root/ConsoleManager"):
				get_node("/root/ConsoleManager").toggle_console()
		"create_being_at_cursor":
			print("🎯 Creating being at cursor position...")
		_:
			print("🔧 Executing custom action: " + action)

################################################################
# PUBLIC API
################################################################

func get_txt_entries_by_category(category: String) -> Array:
	"""Get all TXT entries for a specific category"""
	var entries = []
	for key in txt_database:
		var data = txt_database[key]
		if data.get("category", "") == category:
			entries.append({"name": key, "data": data})
	return entries

func reload_txt_database():
	"""Reload the entire TXT database"""
	txt_database.clear()
	_load_txt_database()

func add_message_to_queue(message_name: String):
	"""Add a message popup to the queue"""
	if txt_database.has(message_name):
		popup_queue.append({"name": message_name, "time": Time.get_unix_time_from_system()})

################################################################
# END OF TXT UNIVERSAL DATABASE
################################################################