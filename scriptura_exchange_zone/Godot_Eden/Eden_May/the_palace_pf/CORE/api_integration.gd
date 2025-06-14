extends Node

# API Integration for Eden_May
# This script integrates the API Coordinator with the existing Eden_May systems

class_name APIIntegration

# References to game systems
var eden_core = null
var game_project = null
var word_manager = null
var line_processor = null
var wish_maker = null
var api_coordinator = null

# Configuration
var config = {
	"auto_connect": true,
	"default_apis": ["gemini_advanced", "claude_luna"],
	"apply_color_effects": true,
	"register_commands": true
}

# Color effect elements
var color_affected_elements = []

# Integration status
var initialized = false

func _init():
	print("API Integration initializing")

func _ready():
	print("API Integration ready")
	find_systems()
	
	if config.auto_connect:
		connect_default_apis()
	
	if config.register_commands:
		register_api_commands()

func initialize(core_system):
	print("Initializing API Integration with core system")
	eden_core = core_system
	initialized = true
	find_systems()

func find_systems():
	# Find Eden Core if not provided
	if not eden_core:
		eden_core = get_node_or_null("/root/EdenMayGame/EdenCore")
	
	# Find other systems through Eden Core or direct node paths
	if eden_core:
		# Typically these would be accessible through the EdenCore
		game_project = eden_core.get_node_or_null("../GameProject")
		word_manager = eden_core.get_node_or_null("../WordManager")
		line_processor = eden_core.get_node_or_null("../LineProcessor")
	else:
		# Direct node paths as fallback
		game_project = get_node_or_null("/root/EdenMayGame/GameProject")
		word_manager = get_node_or_null("/root/EdenMayGame/WordManager")
		line_processor = get_node_or_null("/root/EdenMayGame/LineProcessor")
	
	# Find or create Wish Maker
	wish_maker = get_node_or_null("/root/EdenMayGame/WishMaker")
	if not wish_maker:
		wish_maker = get_node_or_null("/root/WishMakerSystem/WishMaker")
	
	# Find or create API Coordinator
	api_coordinator = get_node_or_null("/root/EdenMayGame/APICoordinator")
	if not api_coordinator:
		api_coordinator = get_node_or_null("/root/APICoordinatorSystem/APICoordinator")
	
	if not api_coordinator:
		print("Creating new API Coordinator")
		api_coordinator = APICoordinator.new()
		api_coordinator.name = "APICoordinator"
		if eden_core:
			eden_core.add_child(api_coordinator)
		else:
			add_child(api_coordinator)
	
	# Connect signals
	if api_coordinator:
		api_coordinator.connect("color_state_changed", self, "_on_color_state_changed")
		api_coordinator.connect("api_response_received", self, "_on_api_response_received")

func connect_default_apis():
	if not api_coordinator:
		return
	
	for api_name in config.default_apis:
		api_coordinator.connect_to_api(api_name)

func register_api_commands():
	if not eden_core:
		return
	
	# Register API command handlers if eden_core has the appropriate method
	if eden_core.has_method("register_command_handler"):
		eden_core.register_command_handler("api", self, "_handle_api_command")
	
	# Alternative method to add commands through special commands
	if eden_core.has_method("add_special_command"):
		eden_core.add_special_command("api", "Access API Coordinator functions")

func _handle_api_command(args):
	if not api_coordinator:
		return "API Coordinator not available"
	
	if args.size() == 0:
		return _show_api_help()
	
	var subcommand = args[0].to_lower()
	
	match subcommand:
		"connect":
			if args.size() < 2:
				return "Usage: /api connect <api_name or 'all'>"
			return _connect_api(args[1])
		
		"disconnect":
			if args.size() < 2:
				return "Usage: /api disconnect <api_name or 'all'>"
			return _disconnect_api(args[1])
		
		"status":
			return _show_api_status()
		
		"request":
			if args.size() < 3:
				return "Usage: /api request <api_name> <request_text>"
			var api_name = args[1]
			var request_text = args.slice(2, args.size() - 1).join(" ")
			return _send_api_request(api_name, request_text)
		
		"show":
			return _show_api_ui()
		
		"colors":
			return _show_color_info()
		
		"help":
			return _show_api_help()
		
		_:
			return "Unknown API command: " + subcommand + "\nTry /api help"

func _connect_api(api_name):
	if not api_coordinator:
		return "API Coordinator not available"
	
	var result = api_coordinator.connect_to_api(api_name)
	if result:
		if api_name == "all":
			return "Connecting to all available APIs"
		else:
			return "Connecting to " + api_name
	else:
		return "Failed to connect to " + api_name

func _disconnect_api(api_name):
	# Implementation would depend on the disconnect method in APICoordinator
	return "API disconnect not implemented yet"

func _show_api_status():
	if not api_coordinator:
		return "API Coordinator not available"
	
	var status = "API Connection Status:\n"
	
	for api_name in api_coordinator.connections_status:
		var connected = api_coordinator.connections_status[api_name]
		status += "- " + api_name + ": " + ("Connected" if connected else "Disconnected") + "\n"
	
	status += "\nCurrent color state: " + api_coordinator.current_color_state
	
	return status

func _send_api_request(api_name, request_text):
	if not api_coordinator:
		return "API Coordinator not available"
	
	var request_id = "cmd_" + str(OS.get_unix_time())
	var result = api_coordinator.send_request(api_name, request_text, request_id)
	
	if result:
		return "Request sent to " + api_name + ". Results will appear when available."
	else:
		return "Failed to send request to " + api_name

func _show_api_ui():
	# Implementation would depend on the UI system in your project
	var scene = load("res://Eden_May/api_coordinator.tscn")
	if not scene:
		return "API Coordinator UI scene not found"
	
	var instance = scene.instance()
	get_tree().root.add_child(instance)
	
	return "API Coordinator UI opened"

func _show_color_info():
	if not api_coordinator:
		return "API Coordinator not available"
	
	var info = "Color Progression System:\n\n"
	
	for state in api_coordinator.color_progression:
		var color = api_coordinator.color_progression[state]
		info += state.capitalize() + ": RGB(" + str(int(color.r * 255)) + "," + str(int(color.g * 255)) + "," + str(int(color.b * 255)) + ")\n"
	
	info += "\nCurrent state: " + api_coordinator.current_color_state
	
	return info

func _show_api_help():
	return """
API Coordinator Commands:
/api connect <api_name or 'all'> - Connect to API
/api disconnect <api_name or 'all'> - Disconnect from API
/api status - Show API connection status
/api request <api_name> <text> - Send request to API
/api show - Open API Coordinator UI
/api colors - Show color progression information
/api help - Show this help
"""

func register_color_affected_element(element):
	color_affected_elements.append(element)

func _on_color_state_changed(state_name, color):
	if not config.apply_color_effects:
		return
	
	print("Color state changed to: " + state_name)
	
	# Apply color to registered elements
	for element in color_affected_elements:
		if is_instance_valid(element):
			# For most objects, modulate is the property to change
			if element.has_method("set_modulate"):
				element.modulate = color
			# For specific types like ColorRect, use color property
			elif element.has_method("set_color"):
				element.color = color

func _on_api_response_received(api_name, response, request_id):
	print("Response received from " + api_name + " for request: " + request_id)
	
	# Handle different request types
	if request_id.begins_with("cmd_"):
		# Command-line request, could display in console
		if eden_core and eden_core.has_method("show_message"):
			eden_core.show_message("Response from " + api_name + ":\n" + response)
	elif request_id.begins_with("wish_"):
		# Wish Maker request
		if wish_maker:
			wish_maker.process_api_response(api_name, response, request_id)
	elif request_id.begins_with("word_"):
		# Word processing request
		if word_manager:
			word_manager.process_api_response(api_name, response, request_id)
	elif request_id.begins_with("line_"):
		# Line processing request
		if line_processor:
			line_processor.process_api_response(api_name, response, request_id)
	elif request_id.begins_with("game_"):
		# Game project request
		if game_project:
			game_project.process_api_response(api_name, response, request_id)
	
	# Generic processing for any subscribed listeners would go here

# Integration for Wish Maker system
func enhance_wish_maker():
	if not wish_maker or not api_coordinator:
		return
	
	# Add the process_api_response method if it doesn't exist
	if not wish_maker.has_method("process_api_response"):
		wish_maker.process_api_response = funcref(self, "_wish_maker_process_api_response")
	
	# Connect coordinator signal to wish maker
	api_coordinator.connect("api_response_received", wish_maker, "process_api_response")
	
	print("Wish Maker enhanced with API integration")

# Function to handle API responses for Wish Maker
# This will be added to Wish Maker's functionality
func _wish_maker_process_api_response(api_name, response, request_id):
	# This would be called on the wish_maker instance
	print("Processing API response for Wish Maker")
	
	# Parse the request ID to find the wish it relates to
	var wish_id = request_id.replace("wish_", "")
	
	# Find the active wish in wish history
	var wish_found = false
	var wish_index = -1
	
	for i in range(wish_maker.wish_history.size()):
		var wish = wish_maker.wish_history[i]
		if str(wish.timestamp) == wish_id:
			wish_found = true
			wish_index = i
			break
	
	if wish_found:
		# Update the wish with the API response
		wish_maker.wish_history[wish_index].api_response = response
		wish_maker.wish_history[wish_index].api_name = api_name
		
		# Emit appropriate signals based on the response
		if "error" in response.to_lower() or "failed" in response.to_lower():
			wish_maker.emit_signal("wish_failed", wish_maker.wish_history[wish_index].text, 
								  "API Error: " + response)
		else:
			wish_maker.emit_signal("wish_granted", wish_maker.wish_history[wish_index].text, response)
			
			# Award tokens for successful wish
			wish_maker.token_balance += wish_maker.calculate_reward(
				wish_maker.wish_history[wish_index].tokens)
	else:
		print("Could not find wish for request ID: " + request_id)

# Integration with Layer 0
func integrate_with_layer_0(layer_0_node):
	if not layer_0_node:
		print("Layer 0 node not provided")
		return false
	
	print("Integrating API system with Layer 0")
	
	# Check if Layer 0 has a view area for UI
	var view_area = layer_0_node.get_node_or_null("ViewArea")
	if not view_area:
		print("ViewArea not found in Layer 0")
		return false
	
	# Register API system with Layer 0
	if layer_0_node.has_method("register_system"):
		layer_0_node.register_system(api_coordinator, "api_coordinator")
		print("API Coordinator registered with Layer 0")
	
	# Add API UI button to Layer 0 interface
	if layer_0_node.has_method("add_menu_entry"):
		layer_0_node.add_menu_entry("things", {
			"name": "API Coordinator",
			"description": "Control multiple AI models",
			"action": "show_api_coordinator",
			"icon": "terminal"
		})
		print("API menu entry added to Layer 0")
	
	# Define function to show API coordinator UI
	if layer_0_node.has_method("add_to_view_area"):
		# Create a funcref to show the UI
		var show_api_ui_func = funcref(self, "_show_api_ui_in_view_area")
		
		# Attach it to the layer_0_node
		layer_0_node.show_api_coordinator = show_api_ui_func
		
		print("API UI display function added to Layer 0")
	
	return true

# Function to show API UI in view area
func _show_api_ui_in_view_area(view_area):
	# Clear existing content
	for child in view_area.get_children():
		child.queue_free()
	
	# Create API UI instance
	var ui_scene = load("res://Eden_May/api_coordinator.tscn")
	if ui_scene:
		var ui_instance = ui_scene.instance().get_node("APICoordinatorUI")
		if ui_instance:
			view_area.add_child(ui_instance)
			return true
	
	return false