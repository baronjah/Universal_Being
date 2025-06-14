extends Node
class_name OpenAIGateway

# OpenAI API configuration
var api_key: String = ""
var api_url: String = "https://api.openai.com/v1/chat/completions"
var default_model: String = "gpt-4o"
var simulation_mode: bool = true # For testing without real API calls
var last_response: Dictionary = {}
var is_processing: bool = false
var max_tokens: int = 500
var temperature: float = 0.7

# Connection to memory system
var memory_manager = null
var word_processor = null

signal request_completed(response_data)
signal request_error(error_message)
signal word_transformed(original, transformed)
signal dialog_generated(character, dialog)
signal world_description_created(description)

func _ready():
	randomize()
	# Connect to memory evolution manager if available
	if get_node_or_null("/root/MemoryEvolutionManager"):
		memory_manager = get_node("/root/MemoryEvolutionManager")
	
	# Find word translator
	var word_translator = get_node_or_null("/root/WordTranslator")
	if word_translator:
		word_processor = word_translator
	
	# Load API key from environment or file (for security)
	_load_api_key()

func _load_api_key():
	var file = FileAccess.open("user://openai_api_key.txt", FileAccess.READ)
	if file:
		api_key = file.get_line().strip_edges()
		file.close()
		if api_key.length() > 0:
			simulation_mode = false
	
	if simulation_mode:
		print("OpenAI Gateway running in simulation mode - no real API requests will be made")

func set_api_key(key: String):
	api_key = key
	if api_key.length() > 0:
		simulation_mode = false
		# Save API key securely
		var file = FileAccess.open("user://openai_api_key.txt", FileAccess.WRITE)
		if file:
			file.store_line(api_key)
			file.close()
	else:
		simulation_mode = true

func toggle_simulation_mode():
	simulation_mode = !simulation_mode
	return simulation_mode

func generate_text(prompt: String, context: Array = [], custom_params: Dictionary = {}):
	if is_processing:
		emit_signal("request_error", "Another request is already in progress")
		return false
	
	is_processing = true
	
	# Build the request based on OpenAI's chat completion format
	var request_data = {
		"model": custom_params.get("model", default_model),
		"messages": [{"role": "system", "content": "You are a creative assistant helping with a 3D word game called WorldOfWords3D."}],
		"max_tokens": custom_params.get("max_tokens", max_tokens),
		"temperature": custom_params.get("temperature", temperature)
	}
	
	# Add context messages if provided
	for message in context:
		request_data.messages.append(message)
	
	# Add the user prompt
	request_data.messages.append({"role": "user", "content": prompt})
	
	if simulation_mode:
		_simulate_response(prompt)
		return true
	
	# Create HTTP request
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# Convert request data to JSON
	var json = JSON.stringify(request_data)
	
	# Set headers
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]
	
	# Send request
	var error = http_request.request(api_url, headers, HTTPClient.METHOD_POST, json)
	if error != OK:
		is_processing = false
		emit_signal("request_error", "HTTP Request Error: " + str(error))
		http_request.queue_free()
		return false
	
	return true

func _on_request_completed(result, response_code, headers, body):
	is_processing = false
	
	# Get the node that made the request and remove it
	var http_request = get_child(get_child_count() - 1)
	http_request.queue_free()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("request_error", "HTTP Result Error: " + str(result))
		return
	
	if response_code != 200:
		emit_signal("request_error", "HTTP Response Error: " + str(response_code) + "\nBody: " + body.get_string_from_utf8())
		return
	
	# Parse response
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		emit_signal("request_error", "JSON Parse Error")
		return
	
	last_response = json
	emit_signal("request_completed", json)
	
	# If this response should be saved to memory, do so
	if memory_manager:
		memory_manager.capture_word("openai", json.choices[0].message.content)

func _simulate_response(prompt: String):
	# Simple simulation for testing without API calls
	await get_tree().create_timer(0.7).timeout
	
	var simulated_responses = [
		"Imagine floating words that connect ideas across dimensional space.",
		"The creative process forms pathways between concepts, like neural connections.",
		"Words evolve through stages, each transformation revealing deeper meaning.",
		"In WorldOfWords3D, language becomes tangible, visible in three dimensions.",
		"The interface between thought and creation is where magic happens.",
		"Memory systems capture fleeting ideas, preserving them for future exploration.",
		"Terminal commands create ripples in the data sea, affecting nearby word structures.",
		"Your word ecosystem grows more complex with each interaction.",
		"Some flaws are intentional, serving as creative pivot points.",
		"The emoticon system allows expression beyond traditional word structures."
	]
	
	# Generate more contextual response if possible
	var response_text = ""
	
	if prompt.to_lower().contains("transform"):
		response_text = "Transformation complete: Your word has evolved to its next form, gaining new properties in the 3D space."
	elif prompt.to_lower().contains("memory"):
		response_text = "Memory systems synchronized. Triple storage mechanism has preserved your concept in all three dimensions."
	elif prompt.to_lower().contains("visualize") or prompt.to_lower().contains("visual"):
		response_text = "Visualization engaged: Your concept now exists in the data sea, interacting with nearby word structures."
	elif prompt.to_lower().contains("terminal") or prompt.to_lower().contains("command"):
		response_text = "Command processed through the terminal interface. Results are propagating through the system."
	else:
		# Use random response from the list
		response_text = simulated_responses[randi() % simulated_responses.size()]
	
	# Create a simulated response structure
	var simulated_json = {
		"id": "sim_" + str(randi()),
		"object": "chat.completion",
		"created": Time.get_unix_time_from_system(),
		"model": "simulation-model",
		"choices": [
			{
				"index": 0,
				"message": {
					"role": "assistant",
					"content": response_text
				},
				"finish_reason": "stop"
			}
		],
		"usage": {
			"prompt_tokens": prompt.length() / 4,
			"completion_tokens": response_text.length() / 4,
			"total_tokens": (prompt.length() + response_text.length()) / 4
		}
	}
	
	last_response = simulated_json
	is_processing = false
	
	# If this response should be saved to memory, do so
	if memory_manager:
		memory_manager.capture_word("openai_sim", response_text)
		
	emit_signal("request_completed", simulated_json)

func transform_word(word: String, transformation_type: String = "evolve"):
	"""
	Transform a word using the OpenAI API
	transformation_type can be:
	- evolve: natural evolution of the word
	- reverse: create opposite meaning
	- expand: create a more complex version
	- condense: simplify the word
	- emotionalize: add emotional content
	"""
	var prompt = "Transform the word '%s' using the '%s' transformation. Return only the transformed word or short phrase without explanation." % [word, transformation_type]
	
	var custom_params = {
		"max_tokens": 50,
		"temperature": 0.7
	}
	
	# Connect one-time handler for this specific transformation
	var callable = Callable(self, "_on_word_transformation_completed").bind(word)
	if not request_completed.is_connected(callable):
		request_completed.connect(callable, CONNECT_ONE_SHOT)
	
	# Start the request
	return generate_text(prompt, [], custom_params)

func _on_word_transformation_completed(response_data, original_word):
	if "choices" in response_data and response_data.choices.size() > 0:
		var transformed_word = response_data.choices[0].message.content.strip_edges()
		emit_signal("word_transformed", original_word, transformed_word)
		
		# Process with word processor if available
		if word_processor:
			word_processor.process_word(transformed_word)

func generate_dialogue(character_name: String, context: String, emotion: String = "neutral"):
	"""
	Generate dialogue for a character within WorldOfWords3D
	"""
	var prompt = "Create a single line of dialogue for a character named '%s' in the context: '%s'. The character is feeling '%s'. Return only the dialogue text without quotation marks or name prefix." % [character_name, context, emotion]
	
	var custom_params = {
		"max_tokens": 100,
		"temperature": 0.8
	}
	
	# Connect one-time handler for dialogue generation
	var callable = Callable(self, "_on_dialogue_generated").bind(character_name)
	if not request_completed.is_connected(callable):
		request_completed.connect(callable, CONNECT_ONE_SHOT)
	
	# Start the request
	return generate_text(prompt, [], custom_params)

func _on_dialogue_generated(response_data, character_name):
	if "choices" in response_data and response_data.choices.size() > 0:
		var dialogue = response_data.choices[0].message.content.strip_edges()
		emit_signal("dialog_generated", character_name, dialogue)

func generate_world_description(theme: String, complexity: int = 3):
	"""
	Generate a description for a new world or area within WorldOfWords3D
	Complexity ranges from 1 (simple) to 5 (complex)
	"""
	var prompt = "Create a vivid description of a '%s' themed world or area for a 3D word game. Complexity level: %d (1-5). This description should evoke imagery and suggest word-objects that might exist in this space." % [theme, complexity]
	
	var custom_params = {
		"max_tokens": 200,
		"temperature": 0.8
	}
	
	# Connect one-time handler for world description
	var callable = Callable(self, "_on_world_description_created")
	if not request_completed.is_connected(callable):
		request_completed.connect(callable, CONNECT_ONE_SHOT)
	
	# Start the request
	return generate_text(prompt, [], custom_params)

func _on_world_description_created(response_data):
	if "choices" in response_data and response_data.choices.size() > 0:
		var description = response_data.choices[0].message.content.strip_edges()
		emit_signal("world_description_created", description)

func extract_keywords_from_text(text: String, max_keywords: int = 10):
	"""
	Extract the most important keywords from a text
	"""
	var prompt = "Extract up to %d important keywords or phrases from the following text. Return only the keywords separated by commas without explanations:\n\n%s" % [max_keywords, text]
	
	var custom_params = {
		"max_tokens": 100,
		"temperature": 0.3
	}
	
	var context = [
		{"role": "system", "content": "You extract keywords from text, responding with only the keywords separated by commas."}
	]
	
	# Start the request
	return generate_text(prompt, context, custom_params)

func connect_to_word_catcher(word_catcher_node: Node):
	"""
	Connect this gateway to a word catching system for automatic word processing
	"""
	if word_catcher_node:
		word_transformed.connect(word_catcher_node.catch_word)
		print("Connected OpenAI Gateway to word catcher system")
		return true
	return false