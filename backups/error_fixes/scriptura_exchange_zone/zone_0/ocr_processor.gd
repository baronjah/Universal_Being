extends Node

class_name OCRProcessor

# OCR settings and paths
const OCR_CACHE_DIR = "/mnt/c/Users/Percision 15/12_turns_system/ocr_cache/"
const OCR_LOG_PATH = "/mnt/c/Users/Percision 15/12_turns_system/ocr_log.json"
const EMOTION_WORDS_PATH = "/mnt/c/Users/Percision 15/12_turns_system/emotion_words.json"

# Processing queue
var processing_queue = []
var is_processing = false
var main_thread = Thread.new()
var mutex = Mutex.new()

# Emotion recognition
var emotion_words = {
    "joy": ["happy", "excited", "glad", "delighted", "joyful", "pleased", "thrilled"],
    "sadness": ["sad", "unhappy", "depressed", "down", "miserable", "heartbroken", "gloomy"],
    "anger": ["angry", "mad", "furious", "annoyed", "irritated", "enraged", "hostile"],
    "fear": ["afraid", "scared", "fearful", "terrified", "anxious", "worried", "nervous"],
    "surprise": ["surprised", "amazed", "astonished", "shocked", "stunned", "startled"],
    "disgust": ["disgusted", "revolted", "repulsed", "nauseated", "loathing"],
    "neutral": ["neutral", "indifferent", "unaffected", "impartial", "balanced"]
}

# Processing statistics
var stats = {
    "images_processed": 0,
    "total_processing_time_ms": 0,
    "average_processing_time_ms": 0,
    "characters_recognized": 0,
    "words_recognized": 0,
    "emotion_detections": 0
}

# Signals
signal processing_started(image_id)
signal processing_completed(image_id, results)
signal processing_failed(image_id, error)
signal emotion_detected(image_id, emotion, intensity)

func _ready():
    # Load emotion words dictionary if available
    load_emotion_words()
    
    # Create cache directory if it doesn't exist
    var dir = Directory.new()
    if not dir.dir_exists(OCR_CACHE_DIR):
        dir.make_dir_recursive(OCR_CACHE_DIR)
    
    print("OCR Processor initialized")
    print("OCR Cache Directory: " + OCR_CACHE_DIR)

func load_emotion_words():
    var file = File.new()
    if file.file_exists(EMOTION_WORDS_PATH):
        file.open(EMOTION_WORDS_PATH, File.READ)
        var content = file.get_as_text()
        file.close()
        
        var result = JSON.parse(content)
        if result.error == OK:
            emotion_words = result.result
            print("Loaded emotion words dictionary from: " + EMOTION_WORDS_PATH)
        else:
            print("Error parsing emotion words file: " + result.error_string)
            save_emotion_words()
    else:
        # Create default emotion words file
        save_emotion_words()

func save_emotion_words():
    var file = File.new()
    file.open(EMOTION_WORDS_PATH, File.WRITE)
    file.store_string(JSON.print(emotion_words, "  "))
    file.close()
    
    print("Saved emotion words dictionary to: " + EMOTION_WORDS_PATH)

func process_image(image_path, image_id = "", options = {}):
    if image_id.empty():
        image_id = str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    # Check if image exists
    var file = File.new()
    if not file.file_exists(image_path):
        print("Image file not found: " + image_path)
        emit_signal("processing_failed", image_id, "Image file not found")
        return null
    
    # Add to processing queue
    var item = {
        "id": image_id,
        "path": image_path,
        "options": options,
        "timestamp": OS.get_unix_time()
    }
    
    mutex.lock()
    processing_queue.append(item)
    mutex.unlock()
    
    # Start processing if not already processing
    if not is_processing:
        _process_next()
    
    emit_signal("processing_started", image_id)
    print("Added image to OCR processing queue: " + image_path)
    
    return image_id

func _process_next():
    mutex.lock()
    if processing_queue.size() == 0:
        is_processing = false
        mutex.unlock()
        return
    
    is_processing = true
    var item = processing_queue[0]
    processing_queue.remove(0)
    mutex.unlock()
    
    # Process the image (in a real implementation, would use a separate thread)
    # For now, simulate processing with a timer
    var timer = Timer.new()
    timer.one_shot = true
    timer.wait_time = 1.0  # Simulate processing time
    timer.connect("timeout", self, "_on_processing_completed", [item])
    add_child(timer)
    timer.start()
    
    print("Processing image: " + item.path)

func _on_processing_completed(item):
    # Simulate OCR results
    var results = _simulate_ocr_results(item)
    
    # Update statistics
    stats.images_processed += 1
    stats.total_processing_time_ms += results.metadata.processing_time_ms
    stats.average_processing_time_ms = stats.total_processing_time_ms / stats.images_processed
    stats.characters_recognized += results.text.length()
    stats.words_recognized += results.text.split(" ").size()
    
    if results.has("emotions"):
        stats.emotion_detections += 1
    
    # Cache results
    _cache_ocr_results(item.id, results)
    
    # Emit completion signal
    emit_signal("processing_completed", item.id, results)
    
    # Emit emotion signal if emotions detected
    if results.has("emotions") and results.has("primary_emotion"):
        emit_signal("emotion_detected", item.id, results.primary_emotion, results.intensity)
    
    print("Completed OCR processing for: " + item.id)
    print("Text detected: " + results.text.substr(0, 50) + (results.text.length() > 50 ? "..." : ""))
    
    # Process next item in queue
    _process_next()

func _simulate_ocr_results(item):
    # In a real implementation, would process the actual image
    # For now, generate sample text based on the image path
    
    # Sample texts for simulation
    var sample_texts = [
        "The OCR system has detected text in this image. The emotional content appears to be primarily positive.",
        "This image contains text elements that suggest a narrative about technology and innovation.",
        "Text detected includes numbers and symbols representing the turn-based system: 1.1.1.1",
        "The image shows a data visualization with text labels indicating emotional states.",
        "Multiple paragraphs of text are visible, describing a process of digital transformation.",
        "API integration features are mentioned prominently in the detected text.",
        "The text references human-computer interaction and emotional intelligence concepts.",
        "OCR detection complete. Text contains references to Apple Intelligence and integrated features.",
        "The image shows a terminal interface with command line text and numeric data.",
        "Text appears to be documentation for an emotion tracking and analysis system."
    ]
    
    # Select a sample text based on image characteristics (for simulation, just random)
    var text_index = abs(item.path.hash()) % sample_texts.size()
    var detected_text = sample_texts[text_index]
    
    # Add some randomness to the text
    if randf() > 0.5:
        detected_text += " Additional context indicates timing related data: " + str(OS.get_time().hour) + ":" + str(OS.get_time().minute) + "."
    
    # Analyze text for emotions
    var emotion_analysis = _analyze_text_emotions(detected_text)
    
    # Simulate processing metadata
    var processing_time = randi() % 2000 + 500  # 500-2500ms
    var confidence = rand_range(0.65, 0.98)
    
    # Compile results
    var results = {
        "text": detected_text,
        "confidence": confidence,
        "emotions": emotion_analysis.emotions,
        "primary_emotion": emotion_analysis.primary_emotion,
        "intensity": emotion_analysis.intensity,
        "metadata": {
            "processing_time_ms": processing_time,
            "language": "en",
            "word_count": detected_text.split(" ").size(),
            "character_count": detected_text.length(),
            "timestamp": OS.get_datetime()
        }
    }
    
    return results

func _analyze_text_emotions(text):
    # A simple emotion analysis based on word matching
    # In a real implementation, would use more sophisticated NLP
    
    text = text.to_lower()
    var emotions = {
        "joy": 0.0,
        "sadness": 0.0,
        "anger": 0.0,
        "fear": 0.0,
        "surprise": 0.0,
        "disgust": 0.0,
        "neutral": 0.5  # Start with a baseline of neutrality
    }
    
    var words = text.split(" ")
    var emotion_word_count = 0
    
    # Count emotion words
    for emotion in emotion_words:
        for keyword in emotion_words[emotion]:
            var count = 0
            for word in words:
                var cleaned_word = word.strip_edges().to_lower()
                if cleaned_word == keyword or cleaned_word.find(keyword) >= 0:
                    count += 1
            
            if count > 0:
                emotions[emotion] += count * 0.2  # Weight for each occurrence
                emotion_word_count += count
    
    # Cap emotion values at 1.0
    for emotion in emotions:
        emotions[emotion] = min(emotions[emotion], 1.0)
    
    # Find primary emotion
    var primary_emotion = "neutral"
    var highest_value = 0.0
    
    for emotion in emotions:
        if emotions[emotion] > highest_value:
            highest_value = emotions[emotion]
            primary_emotion = emotion
    
    # If no strong emotions, default to neutral
    if highest_value < 0.3:
        primary_emotion = "neutral"
        highest_value = emotions["neutral"]
    
    return {
        "emotions": emotions,
        "primary_emotion": primary_emotion,
        "intensity": highest_value,
        "emotion_word_count": emotion_word_count
    }

func _cache_ocr_results(image_id, results):
    var cache_path = OCR_CACHE_DIR + image_id + ".json"
    
    var file = File.new()
    file.open(cache_path, File.WRITE)
    file.store_string(JSON.print(results, "  "))
    file.close()
    
    # Also update the log
    _update_ocr_log(image_id, results)

func _update_ocr_log(image_id, results):
    # Read existing log
    var log_data = {"entries": []}
    var file = File.new()
    
    if file.file_exists(OCR_LOG_PATH):
        file.open(OCR_LOG_PATH, File.READ)
        var content = file.get_as_text()
        file.close()
        
        var result = JSON.parse(content)
        if result.error == OK:
            log_data = result.result
    
    # Add new entry
    log_data.entries.append({
        "id": image_id,
        "timestamp": OS.get_datetime(),
        "text_length": results.text.length(),
        "word_count": results.text.split(" ").size(),
        "primary_emotion": results.primary_emotion if results.has("primary_emotion") else "unknown",
        "processing_time_ms": results.metadata.processing_time_ms
    })
    
    # Update statistics
    log_data.stats = stats
    
    # Write updated log
    file.open(OCR_LOG_PATH, File.WRITE)
    file.store_string(JSON.print(log_data, "  "))
    file.close()

func get_cached_result(image_id):
    var cache_path = OCR_CACHE_DIR + image_id + ".json"
    
    var file = File.new()
    if file.file_exists(cache_path):
        file.open(cache_path, File.READ)
        var content = file.get_as_text()
        file.close()
        
        var result = JSON.parse(content)
        if result.error == OK:
            return result.result
    
    return null

func get_statistics():
    return stats

func clear_cache():
    # Delete all cached OCR results
    var dir = Directory.new()
    if dir.open(OCR_CACHE_DIR) == OK:
        dir.list_dir_begin(true)
        var file_name = dir.get_next()
        
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(".json"):
                dir.remove(OCR_CACHE_DIR + file_name)
            file_name = dir.get_next()
    
    print("Cleared OCR cache directory")
    return true