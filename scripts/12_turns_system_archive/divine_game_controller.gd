extends Node

# Divine Game Controller
# Initializes and integrates all systems for the 12 turns word game
# Terminal 1: Divine Word Genesis

# Integration with existing main.gd system
var main_controller = null

func _ready():
	# Create the 12-turns system core components
	initialize_systems()
	initialize_ui()
	
	# Try to connect to existing main controller
	main_controller = get_node_or_null("/root/main")
	if main_controller:
		connect_to_main_controller()
	
	print("Divine Word Genesis System Initialized")
	print("Terminal 1: Divine Word Genesis is ready")
	print("12 turns system active - 9-second sacred interval enabled")

func initialize_systems():
	# Check if the new systems already exist
	if get_node_or_null("/root/DivineWordGame") == null:
		var word_game = DivineWordGame.new()
		word_game.name = "DivineWordGame"
		get_tree().root.add_child(word_game)
	
	if get_node_or_null("/root/WordCommentSystem") == null:
		var comment_system = WordCommentSystem.new()
		comment_system.name = "WordCommentSystem"
		get_tree().root.add_child(comment_system)
	
	if get_node_or_null("/root/WordDreamStorage") == null:
		var dream_storage = WordDreamStorage.new()
		dream_storage.name = "WordDreamStorage"
		get_tree().root.add_child(dream_storage)
	
	if get_node_or_null("/root/WordSalemGameController") == null:
		var salem_controller = WordSalemGameController.new()
		salem_controller.name = "WordSalemGameController"
		get_tree().root.add_child(salem_controller)
	
	if get_node_or_null("/root/WordCrimesAnalysis") == null:
		var crimes_analysis = WordCrimesAnalysis.new()
		crimes_analysis.name = "WordCrimesAnalysis" 
		get_tree().root.add_child(crimes_analysis)

func initialize_ui():
	# Create the main UI container
	var ui_container = Control.new()
	ui_container.name = "UIContainer"
	ui_container.set_anchors_preset(Control.PRESET_WIDE)
	add_child(ui_container)
	
	# Create the Divine Word UI
	var main_ui = DivineWordUI.new()
	main_ui.name = "DivineWordUI"
	main_ui.set_anchors_preset(Control.PRESET_WIDE)
	ui_container.add_child(main_ui)
	
	# Create the Word Comment UI
	var comment_ui = WordCommentUI.new()
	comment_ui.name = "WordCommentUI"
	comment_ui.set_anchors_preset(Control.PRESET_WIDE)
	comment_ui.visible = false  # Start hidden
	ui_container.add_child(comment_ui)
	
	# Create the Salem Game UI
	var salem_ui = WordSalemUI.new()
	salem_ui.name = "WordSalemUI"
	salem_ui.set_anchors_preset(Control.PRESET_WIDE)
	salem_ui.visible = false  # Start hidden
	ui_container.add_child(salem_ui)

func connect_to_main_controller():
	if main_controller:
		# Connect signals from main controller to our systems
		main_controller.connect("turn_advanced", self, "_on_main_turn_advanced")
		main_controller.connect("note_created", self, "_on_main_note_created")
		main_controller.connect("word_manifested", self, "_on_main_word_manifested")
		
		# Connect our divine word processor to the existing one
		var divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
		var word_salem_controller = get_node_or_null("/root/WordSalemGameController")
		
		if divine_word_processor and word_salem_controller:
			# Connect signals for word processing
			if main_controller.word_processor:
				main_controller.word_processor.connect("word_processed", divine_word_processor, "_on_word_processed_external")
				
				# Also connect to Salem controller
				main_controller.word_processor.connect("word_processed", word_salem_controller, "_on_word_processed_external")
		
		print("Connected to existing main controller")

func _input(event):
	# Handle UI toggling with Tab key
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_TAB:
			toggle_ui()
		elif event.scancode == KEY_QUOTELEFT:  # Backtick key
			toggle_comment_mode()

func toggle_ui():
	# Toggle between different UI screens
	var ui_container = get_node("UIContainer")
	var main_ui = ui_container.get_node("DivineWordUI")
	var comment_ui = ui_container.get_node("WordCommentUI")
	var salem_ui = ui_container.get_node("WordSalemUI")
	
	if main_ui.visible:
		main_ui.visible = false
		comment_ui.visible = true
		salem_ui.visible = false
	elif comment_ui.visible:
		main_ui.visible = false
		comment_ui.visible = false
		salem_ui.visible = true
	else:
		main_ui.visible = true
		comment_ui.visible = false
		salem_ui.visible = false

func toggle_comment_mode():
	# Toggle dream mode in the comment UI
	var ui_container = get_node("UIContainer")
	var comment_ui = ui_container.get_node("WordCommentUI")
	
	# Make sure Comment UI is visible
	if !comment_ui.visible:
		ui_container.get_node("DivineWordUI").visible = false
		ui_container.get_node("WordSalemUI").visible = false
		comment_ui.visible = true
	
	# Toggle dream mode
	comment_ui._on_dream_toggle(!comment_ui.dream_mode)

# Event handlers for main controller signals

func _on_main_turn_advanced(turn_number, symbol, dimension):
	# Sync with our turn system
	var turn_system = get_node_or_null("/root/TurnSystem")
	if turn_system:
		turn_system.set_dimension(turn_number)
		print("Synchronized with main controller: Turn " + str(turn_number) + " - Dimension " + dimension)
		
		# Add comment about dimension change
		var word_comment_system = get_node_or_null("/root/WordCommentSystem")
		if word_comment_system:
			word_comment_system.add_comment("dimension_change", 
				"SYNCHRONIZED: Main controller advanced to " + dimension,
				word_comment_system.CommentType.OBSERVATION)

func _on_main_note_created(note_data):
	# Process the note in our systems
	var divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
	var word_comment_system = get_node_or_null("/root/WordCommentSystem")
	
	if divine_word_processor and word_comment_system:
		var power = divine_word_processor.process_word(note_data.text, "Main_" + str(note_data.id))
		
		# Add as comment
		word_comment_system.add_comment("note_" + str(note_data.id),
			"NOTE: \"" + note_data.text + "\" from main controller (Power: " + str(power) + ")",
			word_comment_system.CommentType.OBSERVATION)
		
		print("Processed note from main controller: " + note_data.text)

func _on_main_word_manifested(word, position, power):
	# Process the manifested word in our systems
	var divine_word_game = get_node_or_null("/root/DivineWordGame")
	var word_comment_system = get_node_or_null("/root/WordCommentSystem")
	
	if divine_word_game and word_comment_system:
		# Process in game
		divine_word_game.process_word(word)
		
		# Add as divine comment
		word_comment_system.add_comment(word,
			"MANIFESTED: Word manifested from main controller at position " + str(position) + " with power " + str(power),
			word_comment_system.CommentType.DIVINE)
		
		print("Word manifested from main controller: " + word)