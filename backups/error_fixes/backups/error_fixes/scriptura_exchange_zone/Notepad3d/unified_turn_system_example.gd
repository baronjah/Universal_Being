extends Node

class_name UnifiedTurnSystemExample

# Reference to the unified connector
var turn_connector = null

# Example settings
var auto_start = true
var default_turn_duration = 9.0  # Sacred 9-second interval
var default_dimension = 3  # Start in 3D by default

# UI references
var turn_label = null
var dimension_label = null
var symbol_label = null

func _ready():
	print("Unified Turn System Example starting...")
	
	# Create the turn connector
	turn_connector = UnifiedTurnSystemConnector.new()
	add_child(turn_connector)
	
	# Connect to signals
	turn_connector.connect("system_initialized", self, "_on_system_initialized")
	turn_connector.connect("turn_components_connected", self, "_on_components_connected")
	turn_connector.connect("snake_case_applied", self, "_on_snake_case_applied")
	
	# Find UI elements if they exist
	turn_label = get_node_or_null("TurnLabel")
	dimension_label = get_node_or_null("DimensionLabel")
	symbol_label = get_node_or_null("SymbolLabel")
	
	print("Unified Turn System Example initialized")

func _on_system_initialized():
	print("Turn connector system initialized!")
	
	# Configure the turn system
	if auto_start:
		start_turn_cycle()

func _on_components_connected():
	print("Turn components connected!")
	
	# Set some default values
	turn_connector.set_turn_duration(default_turn_duration)
	turn_connector.set_dimension(default_dimension)
	
	# Update the UI with initial values
	update_ui()

func _on_snake_case_applied(original, snake_case):
	# Just for debugging - this will be called for each mapping
	pass

func start_turn_cycle():
	# Start the turn cycle using the unified API
	var result = turn_connector.start_turn()
	print("Turn cycle started: " + str(result))
	
	# Set auto-advance if available
	turn_connector.set_auto_advance(true)
	
	# Schedule regular UI updates
	var timer = Timer.new()
	timer.wait_time = 1.0  # Update once per second
	timer.one_shot = false
	timer.connect("timeout", self, "update_ui")
	add_child(timer)
	timer.start()

func update_ui():
	# Update UI elements with current state
	var current_turn = turn_connector.get_current_turn()
	var current_dimension = turn_connector.get_current_dimension()
	var dimension_name = turn_connector.get_dimension_name()
	var turn_symbol = turn_connector.get_turn_symbol()
	
	print("Current state: Turn " + str(current_turn) + 
		  " | Dimension " + str(current_dimension) + 
		  " (" + dimension_name + ") | Symbol: " + turn_symbol)
	
	# Update UI labels if they exist
	if turn_label:
		turn_label.text = "Turn: " + str(current_turn)
	
	if dimension_label:
		dimension_label.text = "Dimension: " + str(current_dimension) + "D - " + dimension_name
	
	if symbol_label:
		symbol_label.text = "Symbol: " + turn_symbol

func _input(event):
	# Handle input for manual turn control
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_RIGHT:
			# Advance turn with right arrow
			turn_connector.advance_turn()
			update_ui()
		
		elif event.scancode == KEY_UP:
			# Increment dimension with up arrow
			turn_connector.set_dimension(turn_connector.get_current_dimension() + 1)
			update_ui()
		
		elif event.scancode == KEY_DOWN:
			# Decrement dimension with down arrow
			turn_connector.set_dimension(turn_connector.get_current_dimension() - 1)
			update_ui()
		
		elif event.scancode == KEY_SPACE:
			# Toggle auto-advance with space
			var turn_data = turn_connector.get_turn_data()
			if turn_data and turn_data.has("flags"):
				var auto_advance = !turn_data.flags.get("auto_advance", true)
				turn_connector.set_auto_advance(auto_advance)
				print("Auto-advance turns set to: " + str(auto_advance))

# Additional example methods showing snake_case usage

func get_current_turn_info():
	var info = {
		"turn_number": turn_connector.get_current_turn(),
		"dimension": turn_connector.get_current_dimension(),
		"dimension_name": turn_connector.get_dimension_name(),
		"turn_symbol": turn_connector.get_turn_symbol(),
		"turn_data": turn_connector.get_turn_data()
	}
	
	return info

func set_turn_parameters(turn_number, dimension, auto_advance):
	var success = true
	
	if turn_number > 0:
		success = success and turn_connector.start_turn(turn_number)
	
	if dimension > 0:
		success = success and turn_connector.set_dimension(dimension)
	
	turn_connector.set_auto_advance(auto_advance)
	
	return success