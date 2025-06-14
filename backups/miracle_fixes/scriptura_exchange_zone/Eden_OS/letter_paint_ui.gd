extends Control

class_name LetterPaintUI

# References to systems
var letter_paint_system: LetterPaintSystem
var paint_system: PaintSystem
var dimensional_color_system: DimensionalColorSystem
var turn_cycle_manager: TurnCycleManager
var astral_entity_system: AstralEntitySystem

# UI elements - to be assigned in the scene
@onready var paint_canvas = $PaintCanvas
@onready var dimension_selector = $SidePanel/DimensionSelector
@onready var letter_display = $SidePanel/LetterDisplay
@onready var insight_panel = $InsightPanel
@onready var insight_text = $InsightPanel/InsightText
@onready var letter_info_panel = $LetterInfoPanel
@onready var letter_info_text = $LetterInfoPanel/LetterInfoText
@onready var power_bar = $SidePanel/PowerBar

# Letter input tracking
var active_letters = []
var current_word = ""
var mind_power = 0.0
var last_insight = ""

# iPad-like interface settings
var ipad_mode = true
var pencil_mode = true
var letter_size = 100.0
var auto_recognize = true

func _ready():
	# Get references to systems
	letter_paint_system = get_node_or_null("/root/LetterPaintSystem")
	if not letter_paint_system:
		letter_paint_system = LetterPaintSystem.new()
		add_child(letter_paint_system)
	
	paint_system = get_node_or_null("/root/PaintSystem")
	if not paint_system:
		paint_system = PaintSystem.new()
		add_child(paint_system)
	
	dimensional_color_system = get_node_or_null("/root/DimensionalColorSystem")
	turn_cycle_manager = get_node_or_null("/root/TurnCycleManager")
	astral_entity_system = get_node_or_null("/root/AstralEntitySystem")
	
	# Connect signals
	letter_paint_system.letter_painted.connect(_on_letter_painted)
	letter_paint_system.glyph_recognized.connect(_on_glyph_recognized)
	letter_paint_system.mind_updated.connect(_on_mind_updated)
	
	paint_canvas.stroke_completed.connect(_on_stroke_completed)
	
	# Setup UI
	_setup_ui()
	
	# Initial UI update
	_update_ui()

func _setup_ui():
	# Set up dimension selector
	dimension_selector.clear()
	for i in range(1, 10):
		var dimension_name = ""
		match i:
			1: dimension_name = "Foundation (AZURE)"
			2: dimension_name = "Growth (EMERALD)"
			3: dimension_name = "Energy (AMBER)"
			4: dimension_name = "Insight (VIOLET)"
			5: dimension_name = "Force (CRIMSON)"
			6: dimension_name = "Vision (INDIGO)"
			7: dimension_name = "Wisdom (SAPPHIRE)"
			8: dimension_name = "Transcendence (GOLD)"
			9: dimension_name = "Unity (SILVER)"
		
		dimension_selector.add_item(dimension_name, i)
	
	# Default to first dimension
	dimension_selector.select(0)
	
	# Set initial power
	power_bar.value = 0.0
	
	# Connect UI signals
	dimension_selector.item_selected.connect(_on_dimension_selected)
	
	# Hide insight panel initially
	insight_panel.visible = false
	letter_info_panel.visible = false

func _update_ui():
	# Update letter display
	letter_display.text = current_word
	
	# Update power bar
	power_bar.value = min(100.0, mind_power)

func _on_letter_painted(letter, dimension, power):
	# Add to current word
	current_word += letter
	
	# Add to active letters
	active_letters.append(letter)
	
	# Update mind power
	mind_power += power
	
	# Show letter info
	_show_letter_info(letter, dimension, power)
	
	# Update UI
	_update_ui()

func _on_glyph_recognized(glyph_data):
	# The letter was already added in _on_letter_painted
	# This is just for additional visual feedback
	
	# Maybe play a sound or animation
	print("Recognized: " + glyph_data.character + " (Confidence: " + str(glyph_data.confidence) + ")")

func _on_mind_updated(update_type, strength):
	# Get update type name
	var type_name = LetterPaintSystem.MindUpdateType.keys()[update_type]
	
	# Show insight panel
	_show_insight(type_name, strength)
	
	# Update power (mind updates drain power)
	mind_power = max(0.0, mind_power - strength * 0.5)
	
	# Update UI
	_update_ui()

func _on_stroke_completed(stroke_id):
	if auto_recognize:
		# Automatically try to recognize as a letter
		letter_paint_system.process_stroke_as_letter(stroke_id)

func _show_letter_info(letter, dimension, power):
	# Format the letter info text
	var info = "Letter: " + letter + "\n"
	info += "Dimension: " + str(dimension) + "\n"
	info += "Power: " + str(power) + "\n"
	
	# Get dimension properties
	var properties = letter_paint_system.letter_dimension_properties.get(dimension, {})
	
	if not properties.is_empty():
		info += "\nProperties:\n"
		info += "- Stability: " + str(properties.stability) + "\n"
		info += "- Persistence: " + str(properties.persistence) + "\n"
		info += "- Manifestation: " + str(properties.manifestation) + "\n"
		
		if properties.has("effects"):
			info += "\nEffects:\n"
			for effect in properties.effects:
				info += "- " + effect + "\n"
	
	# Set the info text
	letter_info_text.text = info
	
	# Show the panel
	letter_info_panel.visible = true
	
	# Auto-hide after 3 seconds
	await get_tree().create_timer(3.0).timeout
	letter_info_panel.visible = false

func _show_insight(type, strength):
	# Format the insight text
	var insight = "Mind Update: " + type + "\n"
	insight += "Strength: " + str(strength) + "\n\n"
	
	# Generate an insight if available
	if not last_insight.is_empty():
		insight += last_insight
	else:
		insight += "Your mind expands with new understanding."
	
	# Set the insight text
	insight_text.text = insight
	
	# Show the panel
	insight_panel.visible = true
	
	# Auto-hide after 5 seconds
	await get_tree().create_timer(5.0).timeout
	insight_panel.visible = false
	
	# Clear last insight
	last_insight = ""

func _on_dimension_selected(index):
	var dimension = dimension_selector.get_item_id(index)
	
	# Update paint system dimension
	paint_system.set_brush_dimension(dimension)
	
	# Update UI
	_update_ui()

func _on_clear_button_pressed():
	# Clear the canvas
	paint_canvas.clear_canvas()
	
	# Clear current word
	current_word = ""
	active_letters.clear()
	
	# Update UI
	_update_ui()

func _on_update_mind_button_pressed():
	# Only allow updates if there is enough mind power
	if mind_power < 5.0:
		# Not enough power
		print("Not enough mind power to update")
		return
	
	# Generate a mind update
	if not current_word.is_empty():
		# Create an update from the current word
		var dimension = paint_system.current_brush_settings.dimension
		var letters = []
		for letter in current_word:
			letters.append(letter)
		
		letter_paint_system._generate_mind_update(
			letters,
			dimension,
			LetterPaintSystem.MindUpdateType.INTEGRATION,
			mind_power * 0.2
		)
		
		# Clear the current word
		current_word = ""
		active_letters.clear()
	else:
		# Create a general update
		var dimension = paint_system.current_brush_settings.dimension
		
		letter_paint_system._generate_mind_update(
			["Ω"], # Special character
			dimension,
			LetterPaintSystem.MindUpdateType.REFLECTION,
			mind_power * 0.2
		)
	
	# Use up most of the mind power
	mind_power *= 0.3
	
	# Update UI
	_update_ui()

func _on_paint_letter_button_pressed():
	# Show letter selection dialog
	$LetterSelectDialog.popup_centered()

func _on_paint_word_button_pressed():
	# Show word input dialog
	$WordInputDialog.popup_centered()

func _on_letter_selected(letter):
	# Paint the selected letter
	var canvas_size = paint_canvas.size
	var position = Vector2(canvas_size.x / 2, canvas_size.y / 2)
	
	letter_paint_system.paint_letter(
		letter,
		position,
		letter_size,
		paint_system.current_brush_settings.dimension
	)
	
	# Close dialog
	$LetterSelectDialog.hide()

func _on_word_entered(word):
	# Paint the entered word
	var canvas_size = paint_canvas.size
	var position = Vector2(canvas_size.x / 2 - (word.length() * letter_size * 0.35), canvas_size.y / 2)
	
	letter_paint_system.paint_word(
		word,
		position,
		letter_size,
		paint_system.current_brush_settings.dimension
	)
	
	# Close dialog
	$WordInputDialog.hide()

func _on_toggle_ipad_mode_button_pressed():
	ipad_mode = !ipad_mode
	
	# Update UI based on mode
	$SidePanel/ModeLabel.text = "Mode: " + ("iPad" if ipad_mode else "Desktop")
	
	# Update canvas behavior
	paint_canvas.show_grid = !ipad_mode

func _on_toggle_pencil_mode_button_pressed():
	pencil_mode = !pencil_mode
	
	# Update UI based on mode
	$SidePanel/PencilLabel.text = "Input: " + ("Pencil" if pencil_mode else "Touch")
	
	# Update brush settings
	if pencil_mode:
		paint_system.set_brush_size(5.0)
		paint_system.set_brush_hardness(0.9)
	else:
		paint_system.set_brush_size(15.0)
		paint_system.set_brush_hardness(0.7)

func _on_size_slider_value_changed(value):
	letter_size = value
	$SidePanel/SizeLabel.text = "Letter Size: " + str(int(letter_size))

func _on_activate_word_button_pressed():
	if current_word.is_empty():
		return
	
	# Check if the current word is a power word
	var upper_word = current_word.to_upper()
	if letter_paint_system.power_words.has(upper_word):
		# Activate the power word
		letter_paint_system._activate_power_word(upper_word)
		
		# Clear the current word
		current_word = ""
		active_letters.clear()
		
		# Update UI
		_update_ui()
	else:
		# Try to generate a mind update from the word
		var dimension = paint_system.current_brush_settings.dimension
		var letters = []
		for letter in current_word:
			letters.append(letter)
		
		letter_paint_system._generate_mind_update(
			letters,
			dimension
		)
		
		# Clear the current word
		current_word = ""
		active_letters.clear()
		
		# Update UI
		_update_ui()

# Input handling for iPad-like experience
func _input(event):
	if not ipad_mode:
		return
	
	if event is InputEventMouseMotion:
		if pencil_mode:
			# For Apple Pencil, we'd use the pressure value
			# In this simulation, we'll just use a fixed pressure
			var pressure = 1.0
			event.pressure = pressure
			
	elif event is InputEventMagnifyGesture:
		# Handle pinch to zoom
		if event.factor > 1.0:
			paint_canvas.zoom_in()
		else:
			paint_canvas.zoom_out()
	
	elif event is InputEventPanGesture:
		# Handle pan gesture
		paint_canvas.pan_view(event.delta * 10.0)

class LetterSelectDialog extends Window:
	signal letter_selected(letter)
	
	var letter_buttons = []
	var grid_container: GridContainer
	
	func _ready():
		title = "Select Letter"
		size = Vector2(400, 300)
		
		grid_container = GridContainer.new()
		grid_container.columns = 6
		add_child(grid_container)
		
		# Create letter buttons A-Z
		for i in range(65, 91):  # ASCII codes for A-Z
			var letter = char(i)
			var button = Button.new()
			button.text = letter
			button.custom_minimum_size = Vector2(60, 60)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.pressed.connect(_on_letter_button_pressed.bind(letter))
			
			grid_container.add_child(button)
			letter_buttons.append(button)
		
		# Add special characters
		var special_chars = [".", ",", "?", "!", "∞", "Ω"]
		for char in special_chars:
			var button = Button.new()
			button.text = char
			button.custom_minimum_size = Vector2(60, 60)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.pressed.connect(_on_letter_button_pressed.bind(char))
			
			grid_container.add_child(button)
			letter_buttons.append(button)
		
		# Add cancel button
		var cancel_button = Button.new()
		cancel_button.text = "Cancel"
		cancel_button.custom_minimum_size = Vector2(100, 40)
		cancel_button.pressed.connect(hide)
		
		var cancel_container = HBoxContainer.new()
		cancel_container.alignment = BoxContainer.ALIGNMENT_CENTER
		cancel_container.add_child(cancel_button)
		
		var main_container = VBoxContainer.new()
		main_container.add_child(grid_container)
		main_container.add_child(cancel_container)
		
		add_child(main_container)
	
	func _on_letter_button_pressed(letter):
		emit_signal("letter_selected", letter)
		hide()

class WordInputDialog extends Window:
	signal word_entered(word)
	
	var line_edit: LineEdit
	var confirm_button: Button
	var cancel_button: Button
	
	func _ready():
		title = "Enter Word"
		size = Vector2(400, 150)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		line_edit = LineEdit.new()
		line_edit.placeholder_text = "Enter a word..."
		line_edit.custom_minimum_size = Vector2(300, 40)
		
		var button_container = HBoxContainer.new()
		button_container.alignment = BoxContainer.ALIGNMENT_CENTER
		
		confirm_button = Button.new()
		confirm_button.text = "OK"
		confirm_button.custom_minimum_size = Vector2(100, 40)
		confirm_button.pressed.connect(_on_confirm)
		
		cancel_button = Button.new()
		cancel_button.text = "Cancel"
		cancel_button.custom_minimum_size = Vector2(100, 40)
		cancel_button.pressed.connect(hide)
		
		button_container.add_child(confirm_button)
		button_container.add_child(cancel_button)
		
		vbox.add_child(line_edit)
		vbox.add_child(button_container)
		
		add_child(vbox)
	
	func _on_confirm():
		if not line_edit.text.is_empty():
			emit_signal("word_entered", line_edit.text)
			line_edit.text = ""
		hide()