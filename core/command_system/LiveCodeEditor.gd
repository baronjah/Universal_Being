# ==================================================
# LIVE CODE EDITOR - Edit Reality While It Runs
# PURPOSE: In-game code editing with hot reload
# LOCATION: core/command_system/LiveCodeEditor.gd
# ==================================================

extends UniversalBeing
class_name LiveCodeEditor

@onready var code_edit: CodeEdit = CodeEdit.new()
@onready var output_log: RichTextLabel = RichTextLabel.new()

var current_target: Node = null
var current_script_path: String = ""
var original_source: String = ""

signal code_executed(result: Variant)
signal script_reloaded(target: Node)

func _ready() -> void:
	_setup_ui()
	_setup_shortcuts()

func _setup_ui() -> void:
	# Code editor setup
	code_edit.syntax_highlighter = CodeHighlighter.new()
	code_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	code_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	code_edit.custom_minimum_size = Vector2(600, 400)
	
	# Add GDScript highlighting
	var highlighter = code_edit.syntax_highlighter as CodeHighlighter
	highlighter.add_keyword_color("func", Color.CORNFLOWER_BLUE)
	highlighter.add_keyword_color("var", Color.CORNFLOWER_BLUE)
	highlighter.add_keyword_color("if", Color.CORAL)
	highlighter.add_keyword_color("return", Color.CORAL)
	
	# Output log
	output_log.bbcode_enabled = true
	output_log.custom_minimum_size = Vector2(600, 150)
	
	# Layout
	var vbox = VBoxContainer.new()
	vbox.add_child(code_edit)
	vbox.add_child(output_log)
	add_child(vbox)

func _setup_shortcuts() -> void:
	# Ctrl+Enter to execute
	var execute_shortcut = Shortcut.new()
	var execute_event = InputEventKey.new()
	execute_event.keycode = KEY_ENTER
	execute_event.ctrl_pressed = true
	execute_shortcut.events = [execute_event]
	
	# Ctrl+S to save and reload
	var save_shortcut = Shortcut.new()
	var save_event = InputEventKey.new()
	save_event.keycode = KEY_S
	save_event.ctrl_pressed = true
	save_shortcut.events = [save_event]

func edit_node(node: Node) -> void:
	"""Open node's script for editing"""
	current_target = node
	
	if node.get_script():
		var script = node.get_script() as Script
		if script.resource_path != "":
			current_script_path = script.resource_path
			var file = FileAccess.open(current_script_path, FileAccess.READ)
			if file:
				original_source = file.get_as_text()
				code_edit.text = original_source
				file.close()
				log_output("[color=green]Editing: %s[/color]" % current_script_path)
		else:
			# Runtime script
			code_edit.text = script.source_code
			log_output("[color=yellow]Editing runtime script[/color]")

func execute_selection() -> void:
	"""Execute selected code or current line"""
	var code = code_edit.get_selected_text()
	if code.is_empty():
		# Get current line
		var line = code_edit.get_line(code_edit.get_caret_line())
		code = line
	
	execute_code(code)

func execute_code(code: String) -> Variant:
	"""Execute arbitrary GDScript code in context"""
	var script = GDScript.new()
	script.source_code = """
extends Node
var target
func _execute():
	%s
""" % code
	
	var executor = Node.new()
	executor.set_script(script)
	executor.set("target", current_target)
	
	if executor.has_method("_execute"):
		var result = executor.call("_execute")
		log_output("[color=cyan]>>> %s[/color]" % code)
		log_output("[color=white]%s[/color]" % str(result))
		code_executed.emit(result)
		executor.queue_free()
		return result
	
	executor.queue_free()
	return null

func save_and_reload() -> void:
	"""Save changes and hot reload script"""
	if current_script_path == "":
		log_output("[color=red]No script path to save[/color]")
		return
	
	# Save to file
	var file = FileAccess.open(current_script_path, FileAccess.WRITE)
	if file:
		file.store_string(code_edit.text)
		file.close()
		
		# Hot reload
		if current_target and current_target.get_script():
			var script = load(current_script_path)
			current_target.set_script(script)
			script_reloaded.emit(current_target)
			log_output("[color=green]✅ Saved and reloaded![/color]")
	else:
		log_output("[color=red]Failed to save file[/color]")

func create_runtime_script(base_class: String = "Node") -> GDScript:
	"""Create a new runtime script from editor content"""
	var script = GDScript.new()
	script.source_code = code_edit.text
	return script

func log_output(text: String) -> void:
	"""Add text to output log"""
	output_log.append_bbcode(text + "\n")
	# Auto scroll to bottom
	output_log.scroll_to_line(output_log.get_line_count() - 1)

func toggle_visibility() -> void:
	visible = not visible
	if visible:
		code_edit.grab_focus()

# Quick snippets for common operations
func insert_snippet(snippet_name: String) -> void:
	var snippets = {
		"being": """
extends UniversalBeing

func pentagon_init() -> void:
	super()
	being_name = "NewBeing"
	being_type = "custom"
	consciousness_level = 3

func pentagon_process(delta: float) -> void:
	super(delta)
	# Your logic here
""",
		"trigger": """
# Natural language trigger
func on_trigger(word: String, data: Dictionary, speaker: UniversalBeing) -> void:
	match word:
		"activate":
			print("Activated by ", speaker.being_name)
		_:
			pass
""",
		"evolution": """
func can_evolve_to(new_type: String) -> bool:
	return consciousness_level >= 5

func evolve() -> void:
	being_type = "evolved_form"
	consciousness_level += 1
	emit_signal("evolved", self)
"""
	}
	
	if snippet_name in snippets:
		code_edit.insert_text_at_caret(snippets[snippet_name])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_editor"):
		toggle_visibility()
	elif visible:
		if event.is_action_pressed("execute_code"):
			execute_selection()
		elif event.is_action_pressed("save_code"):
			save_and_reload()