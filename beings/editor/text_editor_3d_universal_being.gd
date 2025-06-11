# 3D TEXT EDITOR UNIVERSAL BEING - SPATIAL TEXT INTERACTION
# Sacred rule: No flat interfaces - everything is spatial and 3D
extends UniversalBeing
class_name TextEditor3DUniversalBeing

signal text_changed(new_text: String)
signal file_opened(file_path: String)
signal file_saved(file_path: String)
signal cursor_moved(line: int, column: int)

# Text editor state
var current_text: String = ""
var current_file_path: String = ""
var cursor_line: int = 0
var cursor_column: int = 0
var text_lines: Array = []
var line_nodes: Array = []

# 3D Editor components
var editor_plane: MeshInstance3D = null
var text_display_nodes: Array = []
var cursor_indicator: MeshInstance3D = null
var line_number_display: Array = []

# Visual styling
var editor_color: Color = Color(0.1, 0.1, 0.2, 0.95)
var text_color: Color = Color(0.9, 0.9, 1.0)
var cursor_color: Color = Color(0.2, 1.0, 0.2)
var line_number_color: Color = Color(0.6, 0.6, 0.8)

# Editor configuration
var max_visible_lines: int = 30
var chars_per_line: int = 80
var line_height: float = 0.8
var char_width: float = 0.4

# Pentagon lifecycle
func pentagon_init():
	super.pentagon_init()
	being_type = "text_editor_3d"
	being_name = "3D Text Editor Universal Being"
	consciousness_level = 4
	print("📝 3D Text Editor: Initializing spatial text interface...")

func pentagon_ready():
	super.pentagon_ready()
	create_3d_text_editor_interface()
	load_default_content()
	print("✨ 3D Text Editor: Ready for spatial text creation!")

func pentagon_process(delta: float):
	super.pentagon_process(delta)
	update_cursor_blink(delta)
	handle_spatial_text_input()

func pentagon_input(event: InputEvent):
	super.pentagon_input(event)
	if event is InputEventKey and event.pressed:
		handle_text_input(event)

func pentagon_sewers():
	save_current_work()
	super.pentagon_sewers()

func create_3d_text_editor_interface():
	"""Create the 3D spatial text editor interface"""
	print("🌌 Creating 3D text editor in space...")
	
	# Create main editor plane
	editor_plane = MeshInstance3D.new()
	editor_plane.name = "TextEditor3DPlane"
	var plane = PlaneMesh.new()
	plane.size = Vector2(chars_per_line * char_width, max_visible_lines * line_height)
	editor_plane.mesh = plane
	editor_plane.position = Vector3(0, 0, 0)
	
	# Editor material with transparency
	var material = StandardMaterial3D.new()
	material.albedo_color = editor_color
	material.emission_enabled = true
	material.emission = editor_color * 0.3
	material.emission_energy = 0.2
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	editor_plane.material_override = material
	add_child(editor_plane)
	
	# Create text display area
	create_text_display_area()
	
	# Create cursor indicator
	create_3d_cursor()
	
	# Create line numbers
	create_line_number_display()
	
	print("📝 3D Text Editor interface created successfully")

func create_text_display_area():
	"""Create the 3D text display with Label3D nodes for each line"""
	text_display_nodes.clear()
	
	for i in range(max_visible_lines):
		var line_label = Label3D.new()
		line_label.name = "TextLine_" + str(i)
		line_label.text = ""
		line_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		line_label.position = Vector3(
			-chars_per_line * char_width * 0.4, 
			(max_visible_lines * 0.5 - i) * line_height * 0.8, 
			0.1
		)
		line_label.modulate = text_color
		line_label.pixel_size = 0.01
		line_label.font_size = 24
		
		editor_plane.add_child(line_label)
		text_display_nodes.append(line_label)

func create_3d_cursor():
	"""Create 3D cursor indicator"""
	cursor_indicator = MeshInstance3D.new()
	cursor_indicator.name = "TextCursor3D"
	
	var cursor_mesh = BoxMesh.new()
	cursor_mesh.size = Vector3(0.1, line_height * 0.6, 0.05)
	cursor_indicator.mesh = cursor_mesh
	
	var cursor_material = StandardMaterial3D.new()
	cursor_material.albedo_color = cursor_color
	cursor_material.emission_enabled = true
	cursor_material.emission = cursor_color * 2.0
	cursor_material.emission_energy = 1.0
	cursor_indicator.material_override = cursor_material
	
	editor_plane.add_child(cursor_indicator)
	update_cursor_position()

func create_line_number_display():
	"""Create 3D line number display"""
	line_number_display.clear()
	
	for i in range(max_visible_lines):
		var line_num_label = Label3D.new()
		line_num_label.name = "LineNumber_" + str(i)
		line_num_label.text = str(i + 1)
		line_num_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		line_num_label.position = Vector3(
			-chars_per_line * char_width * 0.5 - 2.0, 
			(max_visible_lines * 0.5 - i) * line_height * 0.8, 
			0.1
		)
		line_num_label.modulate = line_number_color
		line_num_label.pixel_size = 0.008
		line_num_label.font_size = 20
		
		editor_plane.add_child(line_num_label)
		line_number_display.append(line_num_label)

var cursor_blink_time: float = 0.0
var cursor_visible: bool = true

func update_cursor_blink(delta: float):
	"""Make cursor blink like a real text editor"""
	cursor_blink_time += delta
	if cursor_blink_time >= 0.5:
		cursor_blink_time = 0.0
		cursor_visible = !cursor_visible
		if cursor_indicator:
			cursor_indicator.visible = cursor_visible

func handle_text_input(event: InputEvent):
	"""Handle keyboard input for text editing"""
	match event.keycode:
		KEY_ENTER:
			insert_newline()
		KEY_BACKSPACE:
			delete_character()
		KEY_DELETE:
			delete_character_forward()
		KEY_LEFT:
			move_cursor_left()
		KEY_RIGHT:
			move_cursor_right()
		KEY_UP:
			move_cursor_up()
		KEY_DOWN:
			move_cursor_down()
		KEY_HOME:
			move_cursor_to_line_start()
		KEY_END:
			move_cursor_to_line_end()
		KEY_TAB:
			insert_tab()
		_:
			# Regular character input
			if event.unicode > 0 and event.unicode < 127:
				var char = char(event.unicode)
				if char.is_valid_identifier() or char in " .,;:!?()-[]{}\"'<>=+*/\\\n\t":
					insert_character(char)

func handle_spatial_text_input():
	"""Handle spatial-specific text input and interaction"""
	# This could include gesture-based input, voice recognition,
	# or other spatial interaction methods in the future
	pass

func insert_character(character: String):
	"""Insert character at cursor position"""
	ensure_line_exists(cursor_line)
	
	var line = text_lines[cursor_line]
	if cursor_column >= line.length():
		line += character
	else:
		line = line.insert(cursor_column, character)
	
	text_lines[cursor_line] = line
	cursor_column += 1
	
	update_text_display()
	update_cursor_position()
	text_changed.emit(get_full_text())

func insert_newline():
	"""Insert new line at cursor position"""
	ensure_line_exists(cursor_line)
	
	var current_line = text_lines[cursor_line]
	var before_cursor = current_line.substr(0, cursor_column)
	var after_cursor = current_line.substr(cursor_column)
	
	text_lines[cursor_line] = before_cursor
	text_lines.insert(cursor_line + 1, after_cursor)
	
	cursor_line += 1
	cursor_column = 0
	
	update_text_display()
	update_cursor_position()
	text_changed.emit(get_full_text())

func delete_character():
	"""Delete character before cursor (backspace)"""
	if cursor_column > 0:
		ensure_line_exists(cursor_line)
		var line = text_lines[cursor_line]
		line = line.erase(cursor_column - 1, 1)
		text_lines[cursor_line] = line
		cursor_column -= 1
	elif cursor_line > 0:
		# Join with previous line
		var current_line = text_lines[cursor_line] if cursor_line < text_lines.size() else ""
		var previous_line = text_lines[cursor_line - 1]
		cursor_column = previous_line.length()
		text_lines[cursor_line - 1] = previous_line + current_line
		text_lines.remove_at(cursor_line)
		cursor_line -= 1
	
	update_text_display()
	update_cursor_position()
	text_changed.emit(get_full_text())

func delete_character_forward():
	"""Delete character after cursor (delete key)"""
	ensure_line_exists(cursor_line)
	var line = text_lines[cursor_line]
	if cursor_column < line.length():
		line = line.erase(cursor_column, 1)
		text_lines[cursor_line] = line
	elif cursor_line < text_lines.size() - 1:
		# Join with next line
		var next_line = text_lines[cursor_line + 1]
		text_lines[cursor_line] = line + next_line
		text_lines.remove_at(cursor_line + 1)
	
	update_text_display()
	text_changed.emit(get_full_text())

func insert_tab():
	"""Insert tab (4 spaces) at cursor position"""
	for i in range(4):
		insert_character(" ")

func move_cursor_left():
	"""Move cursor left"""
	if cursor_column > 0:
		cursor_column -= 1
	elif cursor_line > 0:
		cursor_line -= 1
		ensure_line_exists(cursor_line)
		cursor_column = text_lines[cursor_line].length()
	
	update_cursor_position()
	cursor_moved.emit(cursor_line, cursor_column)

func move_cursor_right():
	"""Move cursor right"""
	ensure_line_exists(cursor_line)
	var line = text_lines[cursor_line]
	if cursor_column < line.length():
		cursor_column += 1
	elif cursor_line < text_lines.size() - 1:
		cursor_line += 1
		cursor_column = 0
	
	update_cursor_position()
	cursor_moved.emit(cursor_line, cursor_column)

func move_cursor_up():
	"""Move cursor up"""
	if cursor_line > 0:
		cursor_line -= 1
		ensure_line_exists(cursor_line)
		cursor_column = min(cursor_column, text_lines[cursor_line].length())
		update_cursor_position()
		cursor_moved.emit(cursor_line, cursor_column)

func move_cursor_down():
	"""Move cursor down"""
	if cursor_line < text_lines.size() - 1 or text_lines.is_empty():
		cursor_line += 1
		ensure_line_exists(cursor_line)
		cursor_column = min(cursor_column, text_lines[cursor_line].length())
		update_cursor_position()
		cursor_moved.emit(cursor_line, cursor_column)

func move_cursor_to_line_start():
	"""Move cursor to start of line"""
	cursor_column = 0
	update_cursor_position()
	cursor_moved.emit(cursor_line, cursor_column)

func move_cursor_to_line_end():
	"""Move cursor to end of line"""
	ensure_line_exists(cursor_line)
	cursor_column = text_lines[cursor_line].length()
	update_cursor_position()
	cursor_moved.emit(cursor_line, cursor_column)

func ensure_line_exists(line_index: int):
	"""Ensure text_lines has enough entries"""
	while text_lines.size() <= line_index:
		text_lines.append("")

func update_cursor_position():
	"""Update 3D cursor position based on line/column"""
	if cursor_indicator:
		var x_pos = -chars_per_line * char_width * 0.4 + cursor_column * char_width * 0.4
		var y_pos = (max_visible_lines * 0.5 - cursor_line) * line_height * 0.8
		cursor_indicator.position = Vector3(x_pos, y_pos, 0.15)

func update_text_display():
	"""Update the visual text display"""
	for i in range(text_display_nodes.size()):
		var line_node = text_display_nodes[i]
		if i < text_lines.size():
			line_node.text = text_lines[i]
		else:
			line_node.text = ""

func get_full_text() -> String:
	"""Get complete text content"""
	return "\n".join(text_lines)

func set_text(text: String):
	"""Set editor text content"""
	text_lines = text.split("\n")
	cursor_line = 0
	cursor_column = 0
	update_text_display()
	update_cursor_position()
	text_changed.emit(text)

func load_file(file_path: String) -> bool:
	"""Load text file into editor"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("❌ Could not open file: " + file_path)
		return false
	
	var content = file.get_as_text()
	file.close()
	
	set_text(content)
	current_file_path = file_path
	file_opened.emit(file_path)
	print("📂 Loaded file: " + file_path)
	return true

func save_file(file_path: String = "") -> bool:
	"""Save editor content to file"""
	var save_path = file_path if file_path != "" else current_file_path
	if save_path == "":
		print("❌ No file path specified for save")
		return false
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		print("❌ Could not save file: " + save_path)
		return false
	
	file.store_string(get_full_text())
	file.close()
	
	current_file_path = save_path
	file_saved.emit(save_path)
	print("💾 Saved file: " + save_path)
	return true

func save_current_work():
	"""Save current work if there's a file path"""
	if current_file_path != "":
		save_file()

func load_default_content():
	"""Load default content for demonstration"""
	var default_text = """# 3D TEXT EDITOR - SPATIAL INTERFACE
# Welcome to true 3D text editing!

extends UniversalBeing
class_name MyNewBeing

func pentagon_init():
	super.pentagon_init()
	being_type = "custom"
	consciousness_level = 1

func pentagon_ready():
	super.pentagon_ready()
	print("I am alive in 3D space!")

func pentagon_process(delta: float):
	super.pentagon_process(delta)
	# Your code here

func pentagon_input(event: InputEvent):
	super.pentagon_input(event)
	# Handle input

func pentagon_sewers():
	super.pentagon_sewers()
"""
	set_text(default_text)

# Public interface
func open_file(file_path: String):
	"""Public interface to open file"""
	load_file(file_path)

func save_as(file_path: String):
	"""Public interface to save as"""
	save_file(file_path)

func get_text() -> String:
	"""Public interface to get text"""
	return get_full_text()

func clear_editor():
	"""Clear all text"""
	set_text("")

func get_cursor_info() -> Dictionary:
	"""Get cursor position info"""
	return {
		"line": cursor_line,
		"column": cursor_column,
		"total_lines": text_lines.size()
	}