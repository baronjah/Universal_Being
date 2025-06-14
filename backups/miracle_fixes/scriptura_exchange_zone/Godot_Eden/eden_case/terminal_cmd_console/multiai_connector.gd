extends Node

class_name MultiAIConnector

# MultiAIConnector - Connects to multiple AI systems simultaneously
# Allows parallel queries, AI switching, and result comparison

# AI service constants
const AI_SERVICES = {
	"CLAUDE": 0,
	"OPENAI": 1,
	"LOCAL": 2,
	"GOOGLE": 3,
	"CUSTOM": 4
}

const AI_MODELS = {
	"CLAUDE": ["claude-3-opus-20240229", "claude-3-sonnet-20240229", "claude-3-haiku-20240307"],
	"OPENAI": ["gpt-4-1106-preview", "gpt-3.5-turbo-1106", "gpt-4-vision-preview"],
	"LOCAL": ["llama-3-8b-q4", "mistral-7b-instruct", "gguf-mixtral"],
	"GOOGLE": ["gemini-pro", "gemini-pro-vision", "palm-2"],
	"CUSTOM": ["custom-model-1", "custom-model-2"]
}

const CONNECTION_STATES = {
	"DISCONNECTED": 0,
	"CONNECTING": 1,
	"CONNECTED": 2,
	"ERROR": 3
}

# AI configuration
var ai_connections = {}
var active_ais = []
var api_keys = {}
var model_settings = {}
var request_queue = []
var concurrent_requests = 3
var active_requests = 0
var request_count = 0

# Connected systems
var account_bridge = null
var wish_processor = null

# Signals
signal ai_connected(service_id, model)
signal ai_disconnected(service_id)
signal response_received(request_id, service_id, response)
signal all_responses_received(request_id, responses)
signal request_error(request_id, service_id, error)

# Initialize the connector
func _ready():
	print("MultiAI Connector initializing...")

# Connect to account bridge
func connect_to_account_bridge(bridge_instance):
	account_bridge = bridge_instance
	print("Connected to Account Bridge")

# Connect to wish processor
func connect_to_wish_processor(wish_proc_instance):
	wish_processor = wish_proc_instance
	print("Connected to Wish Processor")

# Connect to an AI service
func connect_ai(service_id, service_type, model, connection_params={}):
	# Check if already connected
	if ai_connections.has(service_id) and ai_connections[service_id].state == CONNECTION_STATES.CONNECTED:
		return true
	
	# Initialize connection
	var connection = {
		"service_id": service_id,
		"service_type": service_type,
		"model": model,
		"state": CONNECTION_STATES.CONNECTING,
		"last_used": Time.get_unix_time_from_system(),
		"params": connection_params
	}
	
	ai_connections[service_id] = connection
	
	# Connect based on service type
	var success = false
	match service_type:
		AI_SERVICES.CLAUDE:
			success = _connect_claude(service_id, model, connection_params)
		AI_SERVICES.OPENAI:
			success = _connect_openai(service_id, model, connection_params)
		AI_SERVICES.LOCAL:
			success = _connect_local(service_id, model, connection_params)
		AI_SERVICES.GOOGLE:
			success = _connect_google(service_id, model, connection_params)
		AI_SERVICES.CUSTOM:
			success = _connect_custom(service_id, model, connection_params)
	
	if success:
		ai_connections[service_id].state = CONNECTION_STATES.CONNECTED
		
		# Add to active AIs if not already there
		if not active_ais.has(service_id):
			active_ais.append(service_id)
		
		emit_signal("ai_connected", service_id, model)
		print("Connected to AI service: %s (Model: %s)" % [service_id, model])
	else:
		ai_connections[service_id].state = CONNECTION_STATES.ERROR
		print("Failed to connect to AI service: %s" % service_id)
	
	return success

# Disconnect from an AI service
func disconnect_ai(service_id):
	if not ai_connections.has(service_id):
		return false
	
	# Update state
	ai_connections[service_id].state = CONNECTION_STATES.DISCONNECTED
	
	# Remove from active AIs
	if active_ais.has(service_id):
		active_ais.erase(service_id)
	
	emit_signal("ai_disconnected", service_id)
	print("Disconnected from AI service: %s" % service_id)
	return true

# Send request to a specific AI service
func send_request(service_id, prompt, params={}):
	if not ai_connections.has(service_id) or ai_connections[service_id].state != CONNECTION_STATES.CONNECTED:
		return ""
	
	# Generate request ID
	var request_id = "req_" + str(request_count) + "_" + str(int(Time.get_unix_time_from_system()))
	request_count += 1
	
	# Create request object
	var request = {
		"id": request_id,
		"service_id": service_id,
		"prompt": prompt,
		"params": params,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Add to queue
	request_queue.append(request)
	
	# Process queue
	_process_request_queue()
	
	return request_id

# Send request to all active AI services
func send_broadcast_request(prompt, params={}):
	if active_ais.size() == 0:
		return ""
	
	# Generate request ID
	var request_id = "bc_" + str(request_count) + "_" + str(int(Time.get_unix_time_from_system()))
	request_count += 1
	
	# Track services responding to this broadcast
	var broadcast_services = []
	
	# Create requests for each active AI
	for service_id in active_ais:
		if ai_connections[service_id].state == CONNECTION_STATES.CONNECTED:
			var request = {
				"id": request_id,
				"service_id": service_id,
				"prompt": prompt,
				"params": params,
				"timestamp": Time.get_unix_time_from_system(),
				"is_broadcast": true
			}
			
			# Add to queue
			request_queue.append(request)
			broadcast_services.append(service_id)
	
	# Store broadcast info
	if broadcast_services.size() > 0:
		_store_broadcast_info(request_id, broadcast_services)
		
		# Process queue
		_process_request_queue()
		
		return request_id
	
	return ""

# Store broadcast request information
func _store_broadcast_info(request_id, services):
	var file = FileAccess.open("user://broadcasts/" + request_id + ".json", FileAccess.WRITE)
	if file:
		var data = {
			"request_id": request_id,
			"services": services,
			"responses_received": [],
			"timestamp": Time.get_unix_time_from_system()
		}
		
		file.store_string(JSON.stringify(data, "  "))

# Update broadcast info with a response
func _update_broadcast_info(request_id, service_id, response):
	var file_path = "user://broadcasts/" + request_id + ".json"
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(content)
			
			if parse_result == OK:
				var data = json.get_data()
				
				# Add response
				if not data.responses_received.has(service_id):
					data.responses_received.append(service_id)
				
				# Check if all responses received
				if data.responses_received.size() == data.services.size():
					# All responses received, emit signal
					emit_signal("all_responses_received", request_id, _get_all_responses(request_id))
				
				# Save updated data
				file = FileAccess.open(file_path, FileAccess.WRITE)
				if file:
					file.store_string(JSON.stringify(data, "  "))

# Get all responses for a broadcast request
func _get_all_responses(request_id):
	var responses = {}
	
	# Directory for individual responses
	var dir = DirAccess.open("user://responses")
	if not dir:
		return responses
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.begins_with(request_id + "_") and file_name.ends_with(".json"):
			var response_file = FileAccess.open("user://responses/" + file_name, FileAccess.READ)
			if response_file:
				var content = response_file.get_as_text()
				response_file.close()
				
				var json = JSON.new()
				var parse_result = json.parse(content)
				
				if parse_result == OK:
					var response_data = json.get_data()
					responses[response_data.service_id] = response_data
		
		file_name = dir.get_next()
	
	return responses

# Process the request queue
func _process_request_queue():
	# Process up to our concurrent limit
	while request_queue.size() > 0 and active_requests < concurrent_requests:
		var request = request_queue[0]
		request_queue.remove_at(0)
		
		# Increment active requests
		active_requests += 1
		
		# Process based on service type
		var service_id = request.service_id
		var service_type = ai_connections[service_id].service_type
		
		match service_type:
			AI_SERVICES.CLAUDE:
				_process_claude_request(request)
			AI_SERVICES.OPENAI:
				_process_openai_request(request)
			AI_SERVICES.LOCAL:
				_process_local_request(request)
			AI_SERVICES.GOOGLE:
				_process_google_request(request)
			AI_SERVICES.CUSTOM:
				_process_custom_request(request)

# Handle completion of a request
func _handle_request_completed(request, response, error=""):
	# Update "last_used" timestamp
	if ai_connections.has(request.service_id):
		ai_connections[request.service_id].last_used = Time.get_unix_time_from_system()
	
	# Decrement active requests
	active_requests -= 1
	
	# Save response
	_save_response(request.id, request.service_id, response)
	
	# Emit signals
	if error == "":
		emit_signal("response_received", request.id, request.service_id, response)
		
		# If this is a broadcast request, update broadcast info
		if request.has("is_broadcast") and request.is_broadcast:
			_update_broadcast_info(request.id, request.service_id, response)
	else:
		emit_signal("request_error", request.id, request.service_id, error)
	
	# Process next requests in queue
	_process_request_queue()

# Save a response
func _save_response(request_id, service_id, response):
	# Create directory if it doesn't exist
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("user://responses"):
		dir.make_dir("user://responses")
	
	# Save response
	var file = FileAccess.open("user://responses/" + request_id + "_" + service_id + ".json", FileAccess.WRITE)
	if file:
		var data = {
			"request_id": request_id,
			"service_id": service_id,
			"response": response,
			"timestamp": Time.get_unix_time_from_system()
		}
		
		file.store_string(JSON.stringify(data, "  "))

# Connect to Claude
func _connect_claude(service_id, model, params):
	# Check for API key
	if not params.has("api_key") and not api_keys.has("claude"):
		return false
	
	var api_key = params.get("api_key", api_keys.get("claude", ""))
	
	if api_key == "":
		return false
	
	# Store API key
	api_keys["claude"] = api_key
	
	# No actual connection needed for API-based services
	return true

# Connect to OpenAI
func _connect_openai(service_id, model, params):
	# Check for API key
	if not params.has("api_key") and not api_keys.has("openai"):
		return false
	
	var api_key = params.get("api_key", api_keys.get("openai", ""))
	
	if api_key == "":
		return false
	
	# Store API key
	api_keys["openai"] = api_key
	
	# No actual connection needed for API-based services
	return true

# Connect to local AI
func _connect_local(service_id, model, params):
	# Check for required params
	if not params.has("host") or not params.has("port"):
		return false
	
	# Since we can't actually connect here, just return success
	return true

# Connect to Google
func _connect_google(service_id, model, params):
	# Check for API key
	if not params.has("api_key") and not api_keys.has("google"):
		return false
	
	var api_key = params.get("api_key", api_keys.get("google", ""))
	
	if api_key == "":
		return false
	
	# Store API key
	api_keys["google"] = api_key
	
	# No actual connection needed for API-based services
	return true

# Connect to custom service
func _connect_custom(service_id, model, params):
	# Just store whatever parameters we're given
	return true

# Process Claude request
func _process_claude_request(request):
	# In a real implementation, this would use Claude API
	# For now, simulate a response
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	add_child(timer)
	
	timer.timeout.connect(func():
		var response = {
			"id": request.id,
			"result": "Claude response to: " + request.prompt,
			"model": ai_connections[request.service_id].model,
			"tokens": 150 + int(request.prompt.length() * 1.5)
		}
		
		_handle_request_completed(request, response)
		timer.queue_free()
	)
	
	timer.start()

# Process OpenAI request
func _process_openai_request(request):
	# In a real implementation, this would use OpenAI API
	# For now, simulate a response
	var timer = Timer.new()
	timer.wait_time = 1.2
	timer.one_shot = true
	add_child(timer)
	
	timer.timeout.connect(func():
		var response = {
			"id": request.id,
			"result": "OpenAI response to: " + request.prompt,
			"model": ai_connections[request.service_id].model,
			"tokens": 180 + int(request.prompt.length() * 1.8)
		}
		
		_handle_request_completed(request, response)
		timer.queue_free()
	)
	
	timer.start()

# Process local AI request
func _process_local_request(request):
	# In a real implementation, this would use local HTTP API
	# For now, simulate a response
	var timer = Timer.new()
	timer.wait_time = 0.8
	timer.one_shot = true
	add_child(timer)
	
	timer.timeout.connect(func():
		var response = {
			"id": request.id,
			"result": "Local AI response to: " + request.prompt,
			"model": ai_connections[request.service_id].model,
			"tokens": 120 + int(request.prompt.length() * 1.2)
		}
		
		_handle_request_completed(request, response)
		timer.queue_free()
	)
	
	timer.start()

# Process Google request
func _process_google_request(request):
	# In a real implementation, this would use Google AI API
	# For now, simulate a response
	var timer = Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	add_child(timer)
	
	timer.timeout.connect(func():
		var response = {
			"id": request.id,
			"result": "Google AI response to: " + request.prompt,
			"model": ai_connections[request.service_id].model,
			"tokens": 200 + int(request.prompt.length() * 2.0)
		}
		
		_handle_request_completed(request, response)
		timer.queue_free()
	)
	
	timer.start()

# Process custom request
func _process_custom_request(request):
	# Simulate a response
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	add_child(timer)
	
	timer.timeout.connect(func():
		var response = {
			"id": request.id,
			"result": "Custom service response to: " + request.prompt,
			"model": ai_connections[request.service_id].model,
			"tokens": 100 + int(request.prompt.length() * 1.0)
		}
		
		_handle_request_completed(request, response)
		timer.queue_free()
	)
	
	timer.start()

# Set up all Google accounts
func setup_google_accounts(account_ids):
	var success_count = 0
	
	for account_id in account_ids:
		# Add account to bridge if using account bridge
		if account_bridge:
			if not account_bridge.accounts.has(account_id):
				account_bridge.add_account(account_id, account_bridge.ACCOUNT_TYPES.GOOGLE, {
					"email": account_id,
					"display_name": account_id.split("@")[0]
				})
		
		# Create AI connection for Google service
		var ai_id = "google_" + account_id.split("@")[0]
		var model = AI_MODELS.GOOGLE[0]  # Use default model
		
		if connect_ai(ai_id, AI_SERVICES.GOOGLE, model, {
			"account_id": account_id,
			"auto_reconnect": true
		}):
			success_count += 1
	
	return success_count

# Set up all AI services
func setup_all_ai_services(claude_key="", openai_key="", local_params={}):
	var setup_services = []
	
	# Setup Claude if key provided
	if claude_key != "":
		api_keys["claude"] = claude_key
		var claude_id = "claude_main"
		
		if connect_ai(claude_id, AI_SERVICES.CLAUDE, AI_MODELS.CLAUDE[0], {
			"api_key": claude_key,
			"auto_reconnect": true
		}):
			setup_services.append(claude_id)
	
	# Setup OpenAI if key provided
	if openai_key != "":
		api_keys["openai"] = openai_key
		var openai_id = "openai_main"
		
		if connect_ai(openai_id, AI_SERVICES.OPENAI, AI_MODELS.OPENAI[0], {
			"api_key": openai_key,
			"auto_reconnect": true
		}):
			setup_services.append(openai_id)
	
	# Setup local AI if params provided
	if local_params.has("host") and local_params.has("port"):
		var local_id = "local_main"
		
		if connect_ai(local_id, AI_SERVICES.LOCAL, AI_MODELS.LOCAL[0], local_params):
			setup_services.append(local_id)
	
	return setup_services

# Create a game creation session
func create_game_session(prompt):
	# Generate session ID
	var session_id = "game_" + str(int(Time.get_unix_time_from_system()))
	
	# Create directory for session
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("user://game_sessions"):
		dir.make_dir("user://game_sessions")
	
	if dir and not dir.dir_exists("user://game_sessions/" + session_id):
		dir.make_dir("user://game_sessions/" + session_id)
	
	# Store session info
	var file = FileAccess.open("user://game_sessions/" + session_id + "/info.json", FileAccess.WRITE)
	if file:
		var data = {
			"session_id": session_id,
			"prompt": prompt,
			"created": Time.get_unix_time_from_system(),
			"status": "initializing",
			"active_ais": active_ais.duplicate()
		}
		
		file.store_string(JSON.stringify(data, "  "))
	
	# Send requests to all active AIs
	var game_prompt = """
Create a game concept based on the following prompt: "%s"

The game should include:
1. Core gameplay mechanics
2. Setting and story elements
3. Visual style and aesthetics
4. Key features that make it unique
5. Technical specifications (platform, engine, etc.)

Format your response as a structured game design document.
""" % prompt
	
	var request_id = send_broadcast_request(game_prompt)
	
	# Store request info
	file = FileAccess.open("user://game_sessions/" + session_id + "/requests.json", FileAccess.WRITE)
	if file:
		var data = {
			"initial_request": request_id,
			"requests": [request_id],
			"status": "pending"
		}
		
		file.store_string(JSON.stringify(data, "  "))
	
	return session_id

# Process game design from all AIs
func process_game_designs(session_id):
	var file_path = "user://game_sessions/" + session_id + "/requests.json"
	
	if not FileAccess.file_exists(file_path):
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	if parse_result != OK:
		return false
	
	var data = json.get_data()
	var initial_request = data.initial_request
	
	# Get all responses
	var responses = _get_all_responses(initial_request)
	
	# Merge game designs
	var merged_design = _merge_game_designs(responses, session_id)
	
	# Store merged design
	file = FileAccess.open("user://game_sessions/" + session_id + "/merged_design.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(merged_design, "  "))
	
	# Update session status
	_update_session_status(session_id, "design_complete")
	
	return true

# Merge game designs from multiple AIs
func _merge_game_designs(responses, session_id):
	# In a real implementation, this would use more sophisticated merging
	var merged_design = {
		"session_id": session_id,
		"timestamp": Time.get_unix_time_from_system(),
		"components": {
			"core_mechanics": [],
			"setting": [],
			"visual_style": [],
			"unique_features": [],
			"technical_specs": []
		},
		"contributors": []
	}
	
	# Extract components from each response
	for service_id in responses:
		var response = responses[service_id]
		
		# Add contributor
		merged_design.contributors.append({
			"service_id": service_id,
			"model": ai_connections[service_id].model if ai_connections.has(service_id) else "unknown"
		})
		
		# Very simplistic extraction (in real implementation, use more robust parsing)
		var result = response.response.result
		
		# Look for core mechanics
		if result.find("Core gameplay") >= 0 or result.find("Mechanics") >= 0:
			merged_design.components.core_mechanics.append({
				"source": service_id,
				"content": "From " + service_id + ": Core gameplay elements"
			})
		
		# Look for setting
		if result.find("Setting") >= 0 or result.find("Story") >= 0:
			merged_design.components.setting.append({
				"source": service_id,
				"content": "From " + service_id + ": Setting and story elements"
			})
		
		# Look for visual style
		if result.find("Visual") >= 0 or result.find("Aesthetics") >= 0:
			merged_design.components.visual_style.append({
				"source": service_id,
				"content": "From " + service_id + ": Visual style elements"
			})
		
		# Look for unique features
		if result.find("Unique") >= 0 or result.find("Features") >= 0:
			merged_design.components.unique_features.append({
				"source": service_id,
				"content": "From " + service_id + ": Unique features"
			})
		
		# Look for technical specs
		if result.find("Technical") >= 0 or result.find("Platform") >= 0:
			merged_design.components.technical_specs.append({
				"source": service_id,
				"content": "From " + service_id + ": Technical specifications"
			})
	
	return merged_design

# Update game session status
func _update_session_status(session_id, status):
	var file_path = "user://game_sessions/" + session_id + "/info.json"
	
	if not FileAccess.file_exists(file_path):
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	if parse_result != OK:
		return false
	
	var data = json.get_data()
	data.status = status
	data.last_updated = Time.get_unix_time_from_system()
	
	file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "  "))
		return true
	
	return false