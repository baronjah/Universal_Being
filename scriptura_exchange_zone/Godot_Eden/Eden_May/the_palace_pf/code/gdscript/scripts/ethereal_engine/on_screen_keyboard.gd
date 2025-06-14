# on_screen_keyboard.gd
extends Control

signal character_pressed(character)
signal backspace_pressed
signal submit_pressed

# References to keyboard rows
@onready var row1 = $PanelContainer/VBoxContainer/Row1
@onready var row2 = $PanelContainer/VBoxContainer/Row2
@onready var row3 = $PanelContainer/VBoxContainer/Row3
@onready var row4 = $PanelContainer/VBoxContainer/Row4

# Reference to the target LineEdit
var target_line_edit = null

# Shift state
var shift_active = false

func _ready():
	# Setup keyboard layout
	setup_keyboard()
	
	# Connect signals for special keys
	$PanelContainer/VBoxContainer/Row4/ShiftButton.pressed.connect(_on_shift_button_pressed)
	$PanelContainer/VBoxContainer/Row4/BackspaceButton.pressed.connect(_on_backspace_button_pressed)
	$PanelContainer/VBoxContainer/Row4/SpaceButton.pressed.connect(_on_space_button_pressed)
	$PanelContainer/VBoxContainer/Row4/SubmitButton.pressed.connect(_on_submit_button_pressed)

func setup_keyboard():
	# Row 1: 1 2 3 4 5 6 7 8 9 0
	setup_key_row(row1, "1234567890")
	
	# Row 2: Q W E R T Y U I O P
	setup_key_row(row2, "qwertyuiop")
	
	# Row 3: A S D F G H J K L
	setup_key_row(row3, "asdfghjkl")
	
	# Row 4 has special keys already set up in the scene

func setup_key_row(row, characters):
	for c in characters:
		var button = Button.new()
		button.text = c
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_character_button_pressed.bind(c))
		row.add_child(button)

func set_target(line_edit):
	target_line_edit = line_edit
	
	# Focus the target
	if target_line_edit:
		target_line_edit.grab_focus()

func _on_character_button_pressed(character):
	if shift_active:
		character = character.to_upper()
		shift_active = false
		update_shift_button()
	
	emit_signal("character_pressed", character)
	
	# If we have a target LineEdit, update its text
	if target_line_edit:
		target_line_edit.text += character
		target_line_edit.caret_column = target_line_edit.text.length()

func _on_shift_button_pressed():
	shift_active = !shift_active
	update_shift_button()

func update_shift_button():
	var shift_button = $PanelContainer/VBoxContainer/Row4/ShiftButton
	shift_button.text = "SHIFT" if shift_active else "shift"
	
	# Update all character buttons
	update_character_buttons()

func update_character_buttons():
	# Update row 2
	for i in range(row2.get_child_count()):
		var button = row2.get_child(i)
		if button is Button:
			var c = button.text.to_lower()
			button.text = c.to_upper() if shift_active else c
	
	# Update row 3
	for i in range(row3.get_child_count()):
		var button = row3.get_child(i)
		if button is Button:
			var c = button.text.to_lower()
			button.text = c.to_upper() if shift_active else c

func _on_backspace_button_pressed():
	emit_signal("backspace_pressed")
	
	# If we have a target LineEdit, handle backspace
	if target_line_edit and target_line_edit.text.length() > 0:
		var caret_pos = target_line_edit.caret_column
		if caret_pos > 0:
			target_line_edit.text = target_line_edit.text.substr(0, caret_pos - 1) + target_line_edit.text.substr(caret_pos)
			target_line_edit.caret_column = caret_pos - 1

func _on_space_button_pressed():
	emit_signal("character_pressed", " ")
	
	# If we have a target LineEdit, add a space
	if target_line_edit:
		target_line_edit.text += " "
		target_line_edit.caret_column = target_line_edit.text.length()

func _on_submit_button_pressed():
	emit_signal("submit_pressed")
	
	# Hide the keyboard
	hide()

# Public method to show the keyboard with a target LineEdit
func show_for_target(line_edit):
	set_target(line_edit)
	show()
	
	# Reset state
	shift_active = false
	update_shift_button()
