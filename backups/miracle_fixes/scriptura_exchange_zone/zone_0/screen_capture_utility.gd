extends Node

class_name ScreenCaptureUtility

# ----- CONFIGURATION -----
@export_category("Capture Settings")
@export var auto_capture_enabled: bool = false
@export var capture_interval: float = 5.0  # Seconds between auto-captures
@export var default_capture_method: String = "native"  # native, gdi, directx
@export var capture_quality: int = 90  # JPEG quality for saved images (0-100)
@export var capture_format: String = "png"  # png, jpg, bmp
@export var default_save_path: String = "user://captures/"

@export_category("OCR Settings")
@export var ocr_engine: String = "tesseract"  # tesseract, easyocr, windows
@export var ocr_languages: Array[String] = ["eng"]
@export var ocr_confidence_threshold: float = 0.65
@export var enable_preprocessing: bool = true
@export var enable_offline_mode: bool = true
@export var cache_ocr_results: bool = true

# ----- CAPTURE STATE -----
var is_capturing: bool = false
var capture_timer: Timer
var last_capture_path: String = ""
var pending_captures: Array = []
var capture_count: int = 0

# ----- OCR STATE -----
var ocr_processor: OCRProcessor = null
var is_processing_ocr: bool = false
var last_recognized_text: String = ""
var ocr_history: Array = []
var languages_installed: Array = []

# ----- COMPONENTS -----
var color_system = null
var animation_system = null
var ui = null

# ----- SIGNALS -----
signal capture_started(id, method)
signal capture_completed(id, path)
signal capture_failed(id, error)
signal ocr_started(id, image_path)
signal ocr_completed(id, results)
signal ocr_failed(id, error)
signal auto_capture_toggled(enabled)

# ----- INITIALIZATION -----
func _ready():
    # Initialize the capture directory
    _ensure_capture_directory()
    
    # Set up the timer for auto-capture
    _setup_timer()
    
    # Initialize OCR processor
    _initialize_ocr()
    
    # Find and connect to other systems
    _find_components()
    
    print("Screen Capture Utility initialized")
    print("Default save path: " + default_save_path)
    print("OCR Engine: " + ocr_engine)

func _ensure_capture_directory():
    var dir = Directory.new()
    if not dir.dir_exists(default_save_path):
        dir.make_dir_recursive(default_save_path)

func _setup_timer():
    capture_timer = Timer.new()
    capture_timer.wait_time = capture_interval
    capture_timer.one_shot = false
    capture_timer.autostart = false
    capture_timer.connect("timeout", Callable(self, "_on_capture_timer_timeout"))
    add_child(capture_timer)
    
    if auto_capture_enabled:
        capture_timer.start()

func _initialize_ocr():
    # Get OCR processor reference
    ocr_processor = get_node_or_null("/root/OCRProcessor")
    
    if not ocr_processor:
        # Create new OCR processor if not found
        ocr_processor = OCRProcessor.new()
        add_child(ocr_processor)
    
    # Connect signals
    ocr_processor.connect("processing_started", Callable(self, "_on_ocr_processing_started"))
    ocr_processor.connect("processing_completed", Callable(self, "_on_ocr_processing_completed"))
    ocr_processor.connect("processing_failed", Callable(self, "_on_ocr_processing_failed"))
    
    # Check installed languages
    _check_installed_languages()

func _check_installed_languages():
    # In a real implementation, would check what OCR language packs are installed
    # For this implementation, we'll assume English is always available
    languages_installed = ["eng"]
    
    # Simulate checking for other languages
    var additional_languages = ["deu", "fra", "spa", "jpn", "chi_sim"]
    var installed_count = randi() % 4  # Randomly assume some languages are installed
    
    for i in range(installed_count):
        languages_installed.append(additional_languages[i])
    
    print("OCR languages available: " + str(languages_installed))

func _find_components():
    # Find Color System
    color_system = get_node_or_null("/root/DimensionalColorSystem")
    if not color_system:
        color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
    
    # Find Animation System
    animation_system = get_node_or_null("/root/ColorAnimationSystem")
    if not animation_system:
        animation_system = _find_node_by_class(get_tree().root, "ColorAnimationSystem")
    
    print("Components found - Color System: %s, Animation System: %s" % [
        "Yes" if color_system else "No",
        "Yes" if animation_system else "No"
    ])

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

# ----- CAPTURE METHODS -----
func capture_screen(method: String = "", destination: String = "") -> String:
    # Use defaults if no specific parameters provided
    var capture_method = method if method else default_capture_method
    var save_path = destination if destination else _generate_capture_path()
    
    # Create capture ID
    var capture_id = "capture_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    # Signal that capture is starting
    is_capturing = true
    emit_signal("capture_started", capture_id, capture_method)
    
    # In a real implementation, would use the appropriate method to capture
    # For this mock-up, we'll simulate the capture
    _simulate_screen_capture(capture_id, capture_method, save_path)
    
    return capture_id

func capture_window(window_title: String = "", method: String = "", destination: String = "") -> String:
    # Capture a specific window instead of the full screen
    var capture_method = method if method else default_capture_method
    var save_path = destination if destination else _generate_capture_path()
    
    # Create capture ID
    var capture_id = "window_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    # Signal that capture is starting
    is_capturing = true
    emit_signal("capture_started", capture_id, capture_method)
    
    # In a real implementation, would find and capture the specific window
    # For this mock-up, we'll simulate the capture
    _simulate_window_capture(capture_id, window_title, capture_method, save_path)
    
    return capture_id

func capture_region(x: int, y: int, width: int, height: int, method: String = "", destination: String = "") -> String:
    # Capture a specific region of the screen
    var capture_method = method if method else default_capture_method
    var save_path = destination if destination else _generate_capture_path()
    
    # Create capture ID
    var capture_id = "region_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    # Signal that capture is starting
    is_capturing = true
    emit_signal("capture_started", capture_id, capture_method)
    
    # In a real implementation, would capture the specific region
    # For this mock-up, we'll simulate the capture
    _simulate_region_capture(capture_id, x, y, width, height, capture_method, save_path)
    
    return capture_id

func capture_from_clipboard(destination: String = "") -> String:
    # Capture image from clipboard
    var save_path = destination if destination else _generate_capture_path()
    
    # Create capture ID
    var capture_id = "clipboard_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    # Signal that capture is starting
    is_capturing = true
    emit_signal("capture_started", capture_id, "clipboard")
    
    # In a real implementation, would get image from system clipboard
    # For this mock-up, we'll simulate the capture
    _simulate_clipboard_capture(capture_id, save_path)
    
    return capture_id

# ----- SIMULATION METHODS (WOULD BE REPLACED WITH ACTUAL CAPTURE CODE) -----
func _simulate_screen_capture(capture_id: String, method: String, save_path: String):
    # Simulate a screen capture
    print("Simulating screen capture with method: " + method)
    
    # Add slight delay to simulate processing time
    await get_tree().create_timer(0.5).timeout
    
    # Simulate success
    var success = randf() > 0.05  # 95% success rate
    
    if success:
        # Update state
        is_capturing = false
        last_capture_path = save_path
        capture_count += 1
        
        # Signal completion
        emit_signal("capture_completed", capture_id, save_path)
        
        print("Screen capture completed: " + save_path)
        return true
    else:
        # Simulate failure
        is_capturing = false
        emit_signal("capture_failed", capture_id, "Failed to capture screen")
        
        print("Screen capture failed")
        return false

func _simulate_window_capture(capture_id: String, window_title: String, method: String, save_path: String):
    # Simulate a window capture
    print("Simulating window capture for window: " + (window_title if window_title else "Active Window"))
    
    # Add slight delay to simulate processing time
    await get_tree().create_timer(0.6).timeout
    
    # Simulate success
    var success = randf() > 0.1  # 90% success rate
    
    if success:
        # Update state
        is_capturing = false
        last_capture_path = save_path
        capture_count += 1
        
        # Signal completion
        emit_signal("capture_completed", capture_id, save_path)
        
        print("Window capture completed: " + save_path)
        return true
    else:
        # Simulate failure
        is_capturing = false
        emit_signal("capture_failed", capture_id, "Failed to find or capture window")
        
        print("Window capture failed")
        return false

func _simulate_region_capture(capture_id: String, x: int, y: int, width: int, height: int, method: String, save_path: String):
    # Simulate a region capture
    print("Simulating region capture at (%d, %d, %d, %d)" % [x, y, width, height])
    
    # Add slight delay to simulate processing time
    await get_tree().create_timer(0.4).timeout
    
    # Simulate success
    var success = randf() > 0.05  # 95% success rate
    
    if success:
        # Update state
        is_capturing = false
        last_capture_path = save_path
        capture_count += 1
        
        # Signal completion
        emit_signal("capture_completed", capture_id, save_path)
        
        print("Region capture completed: " + save_path)
        return true
    else:
        # Simulate failure
        is_capturing = false
        emit_signal("capture_failed", capture_id, "Failed to capture region")
        
        print("Region capture failed")
        return false

func _simulate_clipboard_capture(capture_id: String, save_path: String):
    # Simulate a clipboard capture
    print("Simulating clipboard image capture")
    
    # Add slight delay to simulate processing time
    await get_tree().create_timer(0.3).timeout
    
    # Simulate success
    var success = randf() > 0.2  # 80% success rate
    
    if success:
        # Update state
        is_capturing = false
        last_capture_path = save_path
        capture_count += 1
        
        # Signal completion
        emit_signal("capture_completed", capture_id, save_path)
        
        print("Clipboard capture completed: " + save_path)
        return true
    else:
        # Simulate failure
        is_capturing = false
        emit_signal("capture_failed", capture_id, "No image data in clipboard")
        
        print("Clipboard capture failed")
        return false

# ----- OCR METHODS -----
func perform_ocr(image_path: String, language: String = "", options: Dictionary = {}) -> String:
    # Use OCR to recognize text in the image
    if not ocr_processor:
        print("OCR processor not available")
        return ""
    
    # Set default language if not specified
    var lang = language if language else ocr_languages[0]
    
    # Check if language is installed
    if not languages_installed.has(lang):
        print("OCR language not installed: " + lang)
        if languages_installed.size() > 0:
            lang = languages_installed[0]
            print("Using fallback language: " + lang)
        else:
            print("No OCR languages installed")
            return ""
    
    # Create default options if not provided
    var ocr_options = options.duplicate()
    if not ocr_options.has("confidence_threshold"):
        ocr_options["confidence_threshold"] = ocr_confidence_threshold
    if not ocr_options.has("preprocessing"):
        ocr_options["preprocessing"] = enable_preprocessing
    if not ocr_options.has("language"):
        ocr_options["language"] = lang
    
    # Create OCR ID
    var ocr_id = "ocr_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    # Signal OCR starting
    is_processing_ocr = true
    emit_signal("ocr_started", ocr_id, image_path)
    
    # Process image
    ocr_processor.process_image(image_path, ocr_id, ocr_options)
    
    return ocr_id

func auto_capture_and_ocr(method: String = "", language: String = "") -> String:
    # Capture screen and immediately perform OCR
    var capture_id = capture_screen(method)
    
    # Wait for capture to complete
    await self.capture_completed
    
    # Get the saved image path
    var image_path = last_capture_path
    
    # Perform OCR on the captured image
    if image_path:
        return perform_ocr(image_path, language)
    
    return ""

# ----- AUTO-CAPTURE METHODS -----
func toggle_auto_capture(enabled: bool) -> void:
    auto_capture_enabled = enabled
    
    if auto_capture_enabled:
        capture_timer.start()
    else:
        capture_timer.stop()
    
    emit_signal("auto_capture_toggled", auto_capture_enabled)
    print("Auto-capture " + ("enabled" if auto_capture_enabled else "disabled"))

func set_capture_interval(seconds: float) -> void:
    capture_interval = max(1.0, seconds)  # Minimum 1 second interval
    capture_timer.wait_time = capture_interval
    
    print("Capture interval set to: " + str(capture_interval) + " seconds")

func _on_capture_timer_timeout():
    # Called when the auto-capture timer expires
    if auto_capture_enabled and not is_capturing:
        capture_screen()

# ----- UTILITY METHODS -----
func _generate_capture_path() -> String:
    # Generate a unique file path for the capture
    var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
    var filename = "capture_" + timestamp + "." + capture_format
    return default_save_path + filename

func get_last_capture_path() -> String:
    return last_capture_path

func get_capture_statistics() -> Dictionary:
    return {
        "total_captures": capture_count,
        "auto_capture_enabled": auto_capture_enabled,
        "capture_interval": capture_interval,
        "last_capture_path": last_capture_path,
        "is_capturing": is_capturing,
        "is_processing_ocr": is_processing_ocr,
        "ocr_history_count": ocr_history.size()
    }

# ----- EVENT HANDLERS -----
func _on_ocr_processing_started(image_id):
    print("OCR processing started for image: " + image_id)

func _on_ocr_processing_completed(image_id, results):
    is_processing_ocr = false
    
    # Store results
    last_recognized_text = results.text
    ocr_history.append({
        "id": image_id,
        "timestamp": OS.get_datetime(),
        "text": results.text,
        "confidence": results.confidence
    })
    
    # Limit history size
    if ocr_history.size() > 20:
        ocr_history.remove(0)
    
    # Signal completion
    emit_signal("ocr_completed", image_id, results)
    
    print("OCR processing completed for image: " + image_id)
    print("Recognized text: " + results.text.substr(0, 50) + (results.text.length() > 50 ? "..." : ""))

func _on_ocr_processing_failed(image_id, error):
    is_processing_ocr = false
    emit_signal("ocr_failed", image_id, error)
    
    print("OCR processing failed for image: " + image_id)
    print("Error: " + error)

# ----- PUBLIC API -----
func get_recognized_text() -> String:
    return last_recognized_text

func get_ocr_history() -> Array:
    return ocr_history

func clear_ocr_history() -> void:
    ocr_history.clear()
    print("OCR history cleared")

func set_capture_format(format: String) -> void:
    if format in ["png", "jpg", "bmp"]:
        capture_format = format
        print("Capture format set to: " + capture_format)
    else:
        print("Unsupported capture format: " + format)

func set_capture_quality(quality: int) -> void:
    capture_quality = clamp(quality, 10, 100)
    print("Capture quality set to: " + str(capture_quality))

func set_ocr_engine(engine: String) -> void:
    if engine in ["tesseract", "easyocr", "windows"]:
        ocr_engine = engine
        print("OCR engine set to: " + ocr_engine)
    else:
        print("Unsupported OCR engine: " + engine)

func set_default_capture_method(method: String) -> void:
    if method in ["native", "gdi", "directx"]:
        default_capture_method = method
        print("Default capture method set to: " + default_capture_method)
    else:
        print("Unsupported capture method: " + method)