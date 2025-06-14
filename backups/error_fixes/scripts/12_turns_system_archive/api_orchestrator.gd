extends Node

class_name APIOrchestrator

# API integration constants
const API_CONFIG_PATH = "/mnt/c/Users/Percision 15/12_turns_system/api_config.json"
const OCR_CACHE_DIR = "/mnt/c/Users/Percision 15/12_turns_system/ocr_cache/"
const EMOTION_DATA_PATH = "/mnt/c/Users/Percision 15/12_turns_system/emotion_data.json"
const DATA_COLLECTION_PATH = "/mnt/c/Users/Percision 15/12_turns_system/collected_data/"

# API credentials and endpoints
var api_keys = {
    "openai": "",
    "apple_vision": "",
    "emotion_api": "",
    "ocr_service": ""
}

# Integration states
var integration_states = {
    "openai": false,
    "apple_vision": false, 
    "emotion_api": false,
    "ocr_service": false
}

# Data collection
var collected_data = {
    "turns": [],
    "ocr_results": [],
    "emotion_records": [],
    "api_interactions": [],
    "human_interactions": []
}

# Queue for API requests
var request_queue = []
var processing_request = false

# References to other systems
var turn_system = null
var ocr_processor = null

# Signals
signal api_request_completed(request_id, result, success)
signal ocr_completed(image_id, text, emotions, metadata)
signal emotion_detected(source, emotion, intensity, timestamp)
signal data_gathered(source, data_type, content)

func _ready():
    # Create necessary directories if they don't exist
    var dir = Directory.new()
    if not dir.dir_exists(OCR_CACHE_DIR):
        dir.make_dir_recursive(OCR_CACHE_DIR)
    
    if not dir.dir_exists(DATA_COLLECTION_PATH):
        dir.make_dir_recursive(DATA_COLLECTION_PATH)
    
    # Load API configuration
    load_api_config()
    
    # Connect to existing systems
    connect_to_systems()
    
    # Initialize HTTP request node for API calls
    var http_request = HTTPRequest.new()
    add_child(http_request)
    
    print("API Orchestrator initialized")
    print("Integration states: OpenAI: " + str(integration_states["openai"]) + 
          ", Apple Vision: " + str(integration_states["apple_vision"]) + 
          ", Emotion API: " + str(integration_states["emotion_api"]) + 
          ", OCR Service: " + str(integration_states["ocr_service"]))

func load_api_config():
    var file = File.new()
    if file.file_exists(API_CONFIG_PATH):
        file.open(API_CONFIG_PATH, File.READ)
        var content = file.get_as_text()
        file.close()
        
        var result = JSON.parse(content)
        if result.error == OK:
            var config = result.result
            
            # Load API keys if available
            if config.has("api_keys"):
                for key in config.api_keys:
                    if api_keys.has(key):
                        api_keys[key] = config.api_keys[key]
                        integration_states[key] = !config.api_keys[key].empty()
            
            print("API configuration loaded from: " + API_CONFIG_PATH)
        else:
            print("Error parsing API configuration: " + result.error_string)
            create_default_api_config()
    else:
        # Create default configuration
        create_default_api_config()

func create_default_api_config():
    var config = {
        "api_keys": {
            "openai": api_keys.openai,
            "apple_vision": api_keys.apple_vision,
            "emotion_api": api_keys.emotion_api,
            "ocr_service": api_keys.ocr_service
        },
        "endpoints": {
            "openai": "https://api.openai.com/v1/chat/completions",
            "apple_vision": "https://api.apple-ml.com/vision",
            "emotion_api": "https://api.emotion-recognition.com/analyze",
            "ocr_service": "https://api.ocr-service.com/process"
        },
        "options": {
            "max_concurrent_requests": 3,
            "request_timeout": 30,
            "collect_emotion_data": true,
            "emotion_sampling_rate": 10,
            "ocr_cache_days": 7
        }
    }
    
    var file = File.new()
    file.open(API_CONFIG_PATH, File.WRITE)
    file.store_string(JSON.print(config, "  "))
    file.close()
    
    print("Default API configuration created at: " + API_CONFIG_PATH)

func connect_to_systems():
    # Try to find existing TurnPrioritySystem or TurnIntegrator
    turn_system = get_node_or_null("/root/TurnPrioritySystem")
    if not turn_system:
        turn_system = get_node_or_null("/root/TurnIntegrator")
    
    if turn_system:
        # Connect turn signals appropriately
        if turn_system is TurnPrioritySystem:
            turn_system.connect("turn_advanced", self, "_on_turn_advanced")
        elif turn_system is TurnIntegrator:
            turn_system.connect("turn_integrated", self, "_on_turn_integrated")
        print("Connected to Turn System: " + turn_system.get_class())
    
    # Try to find existing OCRProcessor
    ocr_processor = get_node_or_null("/root/OCRProcessor")
    if ocr_processor:
        ocr_processor.connect("processing_completed", self, "_on_ocr_processing_completed")
        print("Connected to OCR Processor")

func set_api_key(service, key):
    if api_keys.has(service):
        api_keys[service] = key
        integration_states[service] = !key.empty()
        
        # Update config file
        save_api_config()
        
        print("Set API key for " + service)
        return true
    
    return false

func save_api_config():
    # Load existing config first
    var config = {}
    var file = File.new()
    if file.file_exists(API_CONFIG_PATH):
        file.open(API_CONFIG_PATH, File.READ)
        var content = file.get_as_text()
        file.close()
        
        var result = JSON.parse(content)
        if result.error == OK:
            config = result.result
    
    # Update API keys
    if not config.has("api_keys"):
        config["api_keys"] = {}
    
    for key in api_keys:
        config["api_keys"][key] = api_keys[key]
    
    # Save updated config
    file.open(API_CONFIG_PATH, File.WRITE)
    file.store_string(JSON.print(config, "  "))
    file.close()
    
    print("Saved API configuration to: " + API_CONFIG_PATH)

func process_image_with_ocr(image_path, options = {}):
    if not integration_states["ocr_service"] and not integration_states["apple_vision"]:
        print("No OCR service is configured")
        return null
    
    var image_id = str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    # Check if we have a local OCR processor
    if ocr_processor:
        ocr_processor.process_image(image_path, image_id, options)
        print("Processing image with local OCR: " + image_path)
        return image_id
    
    # Otherwise queue an API request
    var request_data = {
        "id": image_id,
        "type": "ocr",
        "service": integration_states["apple_vision"] ? "apple_vision" : "ocr_service",
        "path": image_path,
        "options": options
    }
    
    _queue_api_request(request_data)
    print("Queued OCR request for: " + image_path)
    
    return image_id

func analyze_emotion(text_content, source="api"):
    if not integration_states["emotion_api"] and not integration_states["openai"]:
        print("No emotion analysis service is configured")
        return null
    
    var emotion_id = str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    # Queue API request
    var request_data = {
        "id": emotion_id,
        "type": "emotion",
        "service": integration_states["emotion_api"] ? "emotion_api" : "openai",
        "content": text_content,
        "source": source
    }
    
    _queue_api_request(request_data)
    print("Queued emotion analysis for text from source: " + source)
    
    return emotion_id

func continue_with_ai(context, prompt, options = {}):
    if not integration_states["openai"]:
        print("OpenAI API is not configured")
        return null
    
    var continuation_id = str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    # Queue API request
    var request_data = {
        "id": continuation_id,
        "type": "continuation",
        "service": "openai",
        "context": context,
        "prompt": prompt,
        "options": options
    }
    
    _queue_api_request(request_data)
    print("Queued AI continuation request")
    
    return continuation_id

func record_human_interaction(interaction_type, content, metadata = {}):
    var timestamp = OS.get_datetime()
    var interaction_id = str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    var interaction_data = {
        "id": interaction_id,
        "type": interaction_type,
        "content": content,
        "timestamp": timestamp,
        "metadata": metadata
    }
    
    # Add to collected data
    collected_data.human_interactions.append(interaction_data)
    
    # Also record any emotions in the interaction
    if integration_states["emotion_api"] or integration_states["openai"]:
        if typeof(content) == TYPE_STRING and content.length() > 5:
            analyze_emotion(content, "human")
    
    # Emit signal
    emit_signal("data_gathered", "human", interaction_type, interaction_data)
    
    print("Recorded human interaction: " + interaction_type)
    return interaction_id

func gather_turn_data(turn_data):
    # This function gathers data from each turn
    var timestamp = OS.get_datetime()
    var turn_record = {
        "turn_string": turn_data.turn_string if turn_data.has("turn_string") else "0.0.0.0",
        "timestamp": timestamp,
        "active_category": turn_data.active_category if turn_data.has("active_category") else "",
        "turn_lines": turn_data.turn_lines if turn_data.has("turn_lines") else []
    }
    
    # Add to collected data
    collected_data.turns.append(turn_record)
    
    # Emit signal
    emit_signal("data_gathered", "turn", "turn_data", turn_record)
    
    # Save to file periodically (every 10 turns)
    if collected_data.turns.size() % 10 == 0:
        save_collected_data()
    
    print("Gathered turn data for turn: " + turn_record.turn_string)
    return turn_record

func save_collected_data():
    var timestamp = OS.get_unix_time()
    var file_path = DATA_COLLECTION_PATH + "data_" + str(timestamp) + ".json"
    
    var file = File.new()
    file.open(file_path, File.WRITE)
    file.store_string(JSON.print(collected_data, "  "))
    file.close()
    
    print("Saved collected data to: " + file_path)
    return file_path

func _queue_api_request(request_data):
    # Add to queue
    request_queue.append(request_data)
    
    # Process queue if not already processing
    if not processing_request:
        _process_next_request()

func _process_next_request():
    if request_queue.size() == 0:
        processing_request = false
        return
    
    processing_request = true
    var request = request_queue[0]
    
    # Mock API response for now - in a real implementation, would make HTTP request
    var timer = Timer.new()
    timer.one_shot = true
    timer.wait_time = 1.5  # Simulate API delay
    timer.connect("timeout", self, "_on_mock_api_response", [request])
    add_child(timer)
    timer.start()
    
    print("Processing API request: " + request.type + " using " + request.service)

func _on_mock_api_response(request):
    # Remove from queue
    request_queue.remove(0)
    
    # Generate mock response based on request type
    var response = {}
    var success = true
    
    match request.type:
        "ocr":
            response = _generate_mock_ocr_response(request)
        "emotion":
            response = _generate_mock_emotion_response(request)
        "continuation":
            response = _generate_mock_continuation_response(request)
        _:
            success = false
            response = {"error": "Unknown request type"}
    
    # Record API interaction
    var api_interaction = {
        "request_id": request.id,
        "type": request.type,
        "service": request.service,
        "timestamp": OS.get_datetime(),
        "success": success
    }
    collected_data.api_interactions.append(api_interaction)
    
    # Emit appropriate signals
    emit_signal("api_request_completed", request.id, response, success)
    
    if request.type == "ocr" and success:
        emit_signal("ocr_completed", request.id, response.text, response.emotions, response.metadata)
        
        # Add to collected data
        collected_data.ocr_results.append({
            "id": request.id,
            "path": request.path,
            "result": response,
            "timestamp": OS.get_datetime()
        })
    
    if request.type == "emotion" and success:
        emit_signal("emotion_detected", 
                    request.source, 
                    response.primary_emotion, 
                    response.intensity, 
                    OS.get_datetime())
        
        # Add to collected data
        collected_data.emotion_records.append({
            "id": request.id,
            "source": request.source,
            "content": request.content.substr(0, 50) + "...",  # Truncate for storage
            "emotions": response.emotions,
            "timestamp": OS.get_datetime()
        })
    
    # Process next request
    _process_next_request()

func _generate_mock_ocr_response(request):
    # Generate mock OCR result
    var sample_texts = [
        "The magical way to turn on api integrations is through emotional resonance.",
        "Gather data from multiple sources to create a cohesive narrative.",
        "OCR systems can detect emotions through textual and visual analysis.",
        "Turn counter 1.1.1.1 represents the beginning of a new cycle.",
        "Human interactions often trigger emotional responses worth analyzing."
    ]
    
    var text = sample_texts[randi() % sample_texts.size()]
    
    # Generate mock emotions detected in the text/image
    var emotions = {
        "joy": rand_range(0.0, 1.0),
        "sadness": rand_range(0.0, 0.5),
        "anger": rand_range(0.0, 0.3),
        "fear": rand_range(0.0, 0.4),
        "surprise": rand_range(0.0, 0.8),
        "disgust": rand_range(0.0, 0.2),
        "neutral": rand_range(0.0, 0.9)
    }
    
    # Find primary emotion
    var primary_emotion = "neutral"
    var highest_score = 0
    for emotion in emotions:
        if emotions[emotion] > highest_score:
            highest_score = emotions[emotion]
            primary_emotion = emotion
    
    return {
        "text": text,
        "confidence": rand_range(0.7, 0.99),
        "emotions": emotions,
        "primary_emotion": primary_emotion,
        "intensity": highest_score,
        "metadata": {
            "word_count": text.split(" ").size(),
            "processing_time_ms": randi() % 1000 + 500,
            "language": "en"
        }
    }

func _generate_mock_emotion_response(request):
    # Analysis of emotional content
    var emotions = {
        "joy": rand_range(0.0, 1.0),
        "sadness": rand_range(0.0, 0.5),
        "anger": rand_range(0.0, 0.3),
        "fear": rand_range(0.0, 0.4),
        "surprise": rand_range(0.0, 0.8),
        "disgust": rand_range(0.0, 0.2),
        "neutral": rand_range(0.0, 0.9)
    }
    
    # Find primary emotion
    var primary_emotion = "neutral"
    var highest_score = 0
    for emotion in emotions:
        if emotions[emotion] > highest_score:
            highest_score = emotions[emotion]
            primary_emotion = emotion
    
    return {
        "emotions": emotions,
        "primary_emotion": primary_emotion,
        "intensity": highest_score,
        "metadata": {
            "character_count": request.content.length(),
            "processing_time_ms": randi() % 300 + 100
        }
    }

func _generate_mock_continuation_response(request):
    # Sample continuations based on prompts
    var continuations = [
        "The system continues to evolve as it processes more emotional data from multiple sources.",
        "Through API integration, the OCR capabilities enhance the system's ability to understand human interactions.",
        "Each turn in the cycle brings new insights as the data is processed and analyzed.",
        "Emotion tracking reveals patterns in how users interact with the system over time.",
        "The 12 lines of text capture the essence of each turn, preserving the story for future analysis."
    ]
    
    var continuation = continuations[randi() % continuations.size()]
    
    return {
        "continuation": continuation,
        "tokens_generated": continuation.split(" ").size(),
        "processing_time_ms": randi() % 1500 + 500,
        "model": "mock-gpt-4"
    }

# ----- EVENT HANDLERS -----

func _on_turn_advanced(turn_number, turn_lines):
    # This is called when TurnPrioritySystem advances a turn
    if turn_system is TurnPrioritySystem:
        gather_turn_data(turn_system.get_turn_data())

func _on_turn_integrated(turn_number, game_dimension):
    # This is called when TurnIntegrator integrates a turn
    if turn_system is TurnIntegrator:
        gather_turn_data(turn_system.get_current_turn_data())

func _on_ocr_processing_completed(image_id, results):
    # This is called when local OCR processor completes
    emit_signal("ocr_completed", image_id, results.text, results.emotions, results.metadata)
    
    # Add to collected data
    collected_data.ocr_results.append({
        "id": image_id,
        "result": results,
        "timestamp": OS.get_datetime()
    })
    
    print("OCR processing completed for image: " + image_id)