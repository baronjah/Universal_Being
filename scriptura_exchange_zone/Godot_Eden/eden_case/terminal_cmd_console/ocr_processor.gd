extends Node
class_name OCRProcessor

# Signals
signal text_recognized(text, metadata)
signal screenshot_taken(image)
signal processing_status(is_active)

# Configuration
export var auto_capture = true
export var capture_interval = 5.0  # Seconds between captures
export var screen_regions = []     # Regions to capture and process
export var min_confidence = 0.65   # Minimum confidence for OCR results
export var history_size = 20       # Number of recent results to retain

# Processing state
var is_capturing = false
var capture_timer = null
var processing_queue = []
var is_processing = false
var recent_results = []
var recognized_text_db = {}

# Dependencies
var ai_bridge = null

func _ready():
    # Initialize capture timer
    capture_timer = Timer.new()
    capture_timer.wait_time = capture_interval
    capture_timer.one_shot = false
    capture_timer.connect("timeout", self, "_on_capture_timer_timeout")
    add_child(capture_timer)
    
    # Define default screen regions if none specified
    if screen_regions.empty():
        # Default to full screen
        screen_regions.append({
            "name": "full_screen",
            "rect": Rect2(0, 0, OS.window_size.x, OS.window_size.y),
            "priority": 1
        })
    
    # Start automatic capture if enabled
    if auto_capture:
        start_capture()

func start_capture():
    if !is_capturing:
        is_capturing = true
        capture_timer.start()
        emit_signal("processing_status", true)
        print("OCR capture started, interval: ", capture_interval, "s")

func stop_capture():
    if is_capturing:
        is_capturing = false
        capture_timer.stop()
        emit_signal("processing_status", false)
        print("OCR capture stopped")

func set_capture_interval(interval):
    capture_interval = max(0.5, interval)  # Minimum 0.5 seconds
    capture_timer.wait_time = capture_interval
    print("OCR capture interval set to ", capture_interval, "s")

func set_ai_bridge(bridge):
    ai_bridge = bridge
    print("AI Bridge connected to OCR processor")

func _on_capture_timer_timeout():
    take_screenshot()

func take_screenshot():
    # Capture the entire screen
    var image = _capture_screen()
    if image:
        emit_signal("screenshot_taken", image)
        _queue_image_for_processing(image, "full_screen")
    else:
        printerr("Failed to capture screenshot")

func capture_region(region_name):
    # Find the specified region
    var region = null
    for r in screen_regions:
        if r.name == region_name:
            region = r
            break
    
    if region == null:
        printerr("Region not found: ", region_name)
        return false
    
    # Capture the specified region
    var image = _capture_screen_region(region.rect)
    if image:
        emit_signal("screenshot_taken", image)
        _queue_image_for_processing(image, region_name)
        return true
    
    return false

func _capture_screen():
    # In Godot, we can capture the viewport
    # This is a simulated implementation
    var viewport = get_viewport()
    if viewport:
        var img = viewport.get_texture().get_data()
        img.flip_y()  # Viewport texture is flipped
        return img
    return null

func _capture_screen_region(rect):
    # Capture a specific region of the screen
    var full_image = _capture_screen()
    if full_image:
        # Ensure rect is within bounds
        var img_rect = Rect2(0, 0, full_image.get_width(), full_image.get_height())
        rect = rect.clip(img_rect)
        
        # Create new image for the region
        var region_image = Image.new()
        region_image.create(rect.size.x, rect.size.y, false, full_image.get_format())
        region_image.blit_rect(full_image, rect, Vector2(0, 0))
        
        return region_image
    
    return null

func _queue_image_for_processing(image, region_name="full_screen"):
    # Add image to processing queue
    processing_queue.append({
        "image": image,
        "region": region_name,
        "timestamp": OS.get_unix_time()
    })
    
    # Start processing if not already in progress
    if !is_processing:
        _process_next_in_queue()

func _process_next_in_queue():
    # Check if queue is empty
    if processing_queue.size() == 0:
        is_processing = false
        return
    
    is_processing = true
    
    # Get next image from queue
    var item = processing_queue.pop_front()
    
    # Process with AI bridge if available
    if ai_bridge != null:
        var task_id = ai_bridge.process_image(item.image, "ocr")
        yield(ai_bridge, "ai_process_complete")
        _handle_ocr_result(task_id, item)
    else:
        # Fallback to simple processing
        var result = _simple_ocr_processing(item.image)
        _handle_ocr_result(null, item, result)
    
    # Process next item
    _process_next_in_queue()

func _simple_ocr_processing(image):
    # Very basic fallback when AI Bridge is not available
    # In a real implementation, this would use a simple OCR library
    print("Performing basic OCR processing (fallback)")
    
    # Simulate OCR result
    return {
        "text": "Simulated OCR result when AI Bridge is not available",
        "confidence": 0.7
    }

func _handle_ocr_result(task_id, item, fallback_result=null):
    var result = fallback_result
    
    # If we have a task ID and AI Bridge, get the result from there
    if task_id != null and ai_bridge != null:
        # In a real implementation, we would match the result to the task ID
        # For simplicity, we'll use the fallback result
        pass
    
    if result != null and result.confidence >= min_confidence:
        # Extract text
        var text = result.text
        var metadata = {
            "region": item.region,
            "timestamp": item.timestamp,
            "confidence": result.confidence
        }
        
        # Add to recent results
        recent_results.append({
            "text": text,
            "metadata": metadata
        })
        
        # Trim history if needed
        if recent_results.size() > history_size:
            recent_results.pop_front()
        
        # Update text database
        _update_text_database(text, metadata)
        
        # Emit signal
        emit_signal("text_recognized", text, metadata)

func _update_text_database(text, metadata):
    # Split text into words and phrases for analysis
    var words = text.split(" ", false)
    var timestamp = metadata.timestamp
    
    # Update word frequency
    for word in words:
        if word.length() < 2:
            continue  # Skip very short words
        
        var lower_word = word.to_lower()
        
        if !recognized_text_db.has(lower_word):
            recognized_text_db[lower_word] = {
                "count": 0,
                "first_seen": timestamp,
                "last_seen": timestamp,
                "regions": {}
            }
        
        var entry = recognized_text_db[lower_word]
        entry.count += 1
        entry.last_seen = timestamp
        
        # Track by region
        var region = metadata.region
        if !entry.regions.has(region):
            entry.regions[region] = 0
        entry.regions[region] += 1

func get_text_database_stats():
    # Return statistics about the recognized text
    var unique_words = recognized_text_db.size()
    var total_occurrences = 0
    var frequent_words = []
    
    # Calculate total occurrences
    for word in recognized_text_db:
        total_occurrences += recognized_text_db[word].count
    
    # Find most frequent words
    var words = recognized_text_db.keys()
    words.sort_custom(self, "_sort_by_frequency")
    
    # Take top 20 words
    var top_count = min(20, words.size())
    for i in range(top_count):
        var word = words[i]
        frequent_words.append({
            "word": word,
            "count": recognized_text_db[word].count
        })
    
    return {
        "unique_words": unique_words,
        "total_occurrences": total_occurrences,
        "frequent_words": frequent_words,
        "recent_capture_count": recent_results.size()
    }

func _sort_by_frequency(a, b):
    return recognized_text_db[a].count > recognized_text_db[b].count

func search_recent_text(query, case_sensitive=false):
    # Search recent text for a query
    var matches = []
    var query_text = query if case_sensitive else query.to_lower()
    
    for result in recent_results:
        var text = result.text if case_sensitive else result.text.to_lower()
        if text.find(query_text) != -1:
            matches.append(result)
    
    return matches

func clear_history():
    # Clear recent results
    recent_results.clear()
    print("OCR history cleared")

func save_text_database(file_path="user://ocr_text_db.json"):
    # Save text database to disk
    var file = File.new()
    var err = file.open(file_path, File.WRITE)
    if err != OK:
        printerr("Failed to save text database: ", err)
        return false
    
    file.store_string(JSON.print(recognized_text_db))
    file.close()
    print("Saved OCR text database to: ", file_path)
    return true

func load_text_database(file_path="user://ocr_text_db.json"):
    # Load text database from disk
    var file = File.new()
    if !file.file_exists(file_path):
        print("No saved text database found at: ", file_path)
        return false
    
    var err = file.open(file_path, File.READ)
    if err != OK:
        printerr("Failed to load text database: ", err)
        return false
    
    var json = JSON.parse(file.get_as_text())
    file.close()
    
    if json.error != OK:
        printerr("Failed to parse text database JSON: ", json.error_string)
        return false
    
    recognized_text_db = json.result
    print("Loaded OCR text database from: ", file_path)
    return true