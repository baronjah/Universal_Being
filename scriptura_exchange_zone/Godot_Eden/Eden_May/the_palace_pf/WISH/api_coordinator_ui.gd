extends Control

# Visual interface for the API Coordinator
# Displays connection status and provides controls for all API integrations

# Reference to the API Coordinator
var api_coordinator = null

# UI Elements
onready var status_panel = $StatusPanel
onready var connection_panel = $ConnectionPanel
onready var color_indicator = $ColorIndicator
onready var request_panel = $RequestPanel
onready var data_panel = $DataPanel

# Connection status indicators
var api_indicators = {}

# Color transition animation
var color_tween = null

func _ready():
	print("API Coordinator UI initializing")
	initialize_ui()
	find_coordinator()
	setup_connections()

func initialize_ui():
	# Initialize color transition tween
	color_tween = Tween.new()
	add_child(color_tween)
	
	# Setup API indicators
	api_indicators = {
		"gemini": $ConnectionPanel/GeminiStatus,
		"gemini_advanced": $ConnectionPanel/GeminiAdvancedStatus,
		"claude": $ConnectionPanel/ClaudeStatus,
		"claude_luna": $ConnectionPanel/ClaudeLunaStatus,
		"openai": $ConnectionPanel/OpenAIStatus
	}
	
	# Initialize status indicators to disconnected state
	for api_name in api_indicators:
		if api_indicators[api_name]:
			api_indicators[api_name].modulate = Color(0.5, 0.5, 0.5)
	
	# Set initial color indicator
	color_indicator.color = Color(0, 0, 0)  # Start with void/black

func find_coordinator():
	# Try to find the API Coordinator
	api_coordinator = get_node_or_null("../APICoordinator")
	if not api_coordinator:
		api_coordinator = get_node_or_null("/root/EdenMayGame/APICoordinator")
	
	if not api_coordinator:
		print("API Coordinator not found, creating new instance")
		api_coordinator = APICoordinator.new()
		api_coordinator.name = "APICoordinator"
		get_parent().add_child(api_coordinator)
	
	print("API Coordinator found/created")

func setup_connections():
	if not api_coordinator:
		print("Error: API Coordinator not available")
		return
	
	# Connect signals
	api_coordinator.connect("connection_status_changed", self, "_on_connection_status_changed")
	api_coordinator.connect("color_state_changed", self, "_on_color_state_changed")
	api_coordinator.connect("api_response_received", self, "_on_api_response_received")
	api_coordinator.connect("data_parsed", self, "_on_data_parsed")
	
	# Connect UI buttons
	$ConnectionPanel/ConnectAllButton.connect("pressed", self, "_on_connect_all_pressed")
	$RequestPanel/SendRequestButton.connect("pressed", self, "_on_send_request_pressed")
	$DataPanel/ParseDataButton.connect("pressed", self, "_on_parse_data_pressed")
	
	# Connect individual API connect buttons
	for api_name in api_indicators:
		var button_name = api_name.capitalize() + "ConnectButton"
		var button = get_node_or_null("ConnectionPanel/" + button_name)
		if button:
			button.connect("pressed", self, "_on_connect_api_pressed", [api_name])

func _on_connection_status_changed(api_name, connected):
	# Update the UI indicator
	if api_indicators.has(api_name) and api_indicators[api_name]:
		var indicator = api_indicators[api_name]
		
		# Set color based on connection status
		if connected:
			indicator.modulate = Color(0.2, 1, 0.2)  # Green for connected
		else:
			indicator.modulate = Color(1, 0.2, 0.2)  # Red for disconnected
		
		# Update status text
		$StatusPanel/StatusText.text = api_name.capitalize() + " is now " + ("connected" if connected else "disconnected")

func _on_color_state_changed(state_name, color):
	# Animate color change
	color_tween.interpolate_property(color_indicator, "color", 
									color_indicator.color, color, 1.0, 
									Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	color_tween.start()
	
	# Update status text
	$StatusPanel/ColorStateText.text = "Current State: " + state_name.capitalize()

func _on_api_response_received(api_name, response, request_id):
	# Update response display
	var response_text = $RequestPanel/ResponseText
	response_text.text = "Response from " + api_name.capitalize() + " (ID: " + request_id + "):\n"
	response_text.text += response
	
	# Update status
	$StatusPanel/StatusText.text = "Received response from " + api_name.capitalize()

func _on_data_parsed(source, parsed_data):
	# Update data display
	var data_text = $DataPanel/ParsedDataText
	data_text.text = "Data from " + source + ":\n"
	
	if parsed_data.success:
		data_text.text += "Success - Format: " + parsed_data.format + "\n\n"
		
		if parsed_data.format == "json":
			data_text.text += JSON.print(parsed_data.data, "  ")
		elif parsed_data.format == "csv":
			if parsed_data.has("headers"):
				data_text.text += "Headers: " + str(parsed_data.headers) + "\n"
			data_text.text += "Rows: " + str(parsed_data.data.size()) + "\n"
			data_text.text += "First row: " + str(parsed_data.data[0] if parsed_data.data.size() > 0 else "empty")
		else:
			data_text.text += str(parsed_data.data)
	else:
		data_text.text += "Error: " + parsed_data.error

func _on_connect_all_pressed():
	if not api_coordinator:
		return
		
	var results = api_coordinator.connect_to_api("all")
	$StatusPanel/StatusText.text = "Connecting to all APIs..."

func _on_connect_api_pressed(api_name):
	if not api_coordinator:
		return
		
	var result = api_coordinator.connect_to_api(api_name)
	$StatusPanel/StatusText.text = "Connecting to " + api_name.capitalize() + "..."

func _on_send_request_pressed():
	if not api_coordinator:
		return
		
	var request_text = $RequestPanel/RequestInput.text
	if request_text.strip_edges() == "":
		$StatusPanel/StatusText.text = "Error: Empty request"
		return
	
	# Get selected API
	var api_name = $RequestPanel/APISelector.text.to_lower()
	
	# Send the request
	var request_id = str(OS.get_unix_time())
	var result = api_coordinator.send_request(api_name, request_text, request_id)
	
	if result:
		$StatusPanel/StatusText.text = "Request sent to " + api_name
	else:
		$StatusPanel/StatusText.text = "Error sending request to " + api_name

func _on_parse_data_pressed():
	if not api_coordinator:
		return
		
	var data_source = $DataPanel/SourceInput.text
	var data_path = $DataPanel/PathInput.text
	
	if data_source.strip_edges() == "" or data_path.strip_edges() == "":
		$StatusPanel/StatusText.text = "Error: Source and path required"
		return
	
	# Parse options
	var options = {
		"format": $DataPanel/FormatSelector.text.to_lower(),
		"force_refresh": $DataPanel/ForceRefreshCheck.pressed
	}
	
	# Send parse request
	var result = api_coordinator.parse_data(data_source, data_path, options)
	
	if result.success:
		$StatusPanel/StatusText.text = "Data parsed successfully"
	else:
		$StatusPanel/StatusText.text = "Error parsing data: " + result.error

func set_api_key(api_name, key):
	if api_coordinator:
		return api_coordinator.set_api_key(api_name, key)
	return false

func get_current_color():
	if api_coordinator:
		return api_coordinator.get_current_color()
	return Color(0, 0, 0)  # Default to black/void if no coordinator