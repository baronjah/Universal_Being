extends Node

class_name TranslationSystem

# ----- TRANSLATION SETTINGS -----
@export_category("Translation Settings")
@export var enabled: bool = true
@export var default_source_language: String = "en"
@export var default_target_language: String = "en"
@export var offline_mode: bool = false
@export var use_cached_translations: bool = true
@export var cache_directory: String = "user://translation_cache/"
@export var max_cached_entries: int = 1000

# ----- LANGUAGE CODES -----
const LANGUAGE_CODES = {
    "en": "English",
    "fr": "French",
    "de": "German",
    "es": "Spanish",
    "it": "Italian",
    "pt": "Portuguese",
    "ru": "Russian",
    "ja": "Japanese",
    "zh": "Chinese (Simplified)",
    "zh-TW": "Chinese (Traditional)",
    "ko": "Korean",
    "ar": "Arabic",
    "hi": "Hindi",
    "code": "Programming Code"
}

# ----- STATE VARIABLES -----
var translation_cache = {}
var current_request_id = 0
var pending_translations = {}
var is_loading_cache = false
var turn_controller = null
var color_system = null

# ----- SIGNALS -----
signal translation_completed(request_id, original_text, translated_text, source_lang, target_lang)
signal translation_failed(request_id, original_text, error, source_lang, target_lang)
signal languages_changed(source_language, target_language)
signal cache_loaded(entry_count)

# ----- INITIALIZATION -----
func _ready():
    # Find turn controller
    turn_controller = get_node_or_null("/root/TurnController")
    if not turn_controller:
        turn_controller = _find_node_by_class(get_tree().root, "TurnController")
    
    # Find color system
    color_system = get_node_or_null("/root/ExtendedColorThemeSystem")
    if not color_system:
        color_system = get_node_or_null("/root/DimensionalColorSystem")
    
    # Create cache directory
    _ensure_cache_directory()
    
    # Load cached translations
    if use_cached_translations:
        _load_cache()
    
    # Connect to turn controller if available
    if turn_controller:
        turn_controller.connect("turn_started", Callable(self, "_on_turn_started"))
        
        # Register with turn controller
        turn_controller.register_system(self)
    
    print("Translation System initialized")
    print("Default languages: " + default_source_language + " -> " + default_target_language)
    
    # Apply turn specific settings if turn controller is available
    if turn_controller:
        _apply_turn_settings(turn_controller.get_current_turn())

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _ensure_cache_directory():
    var dir = Directory.new()
    if not dir.dir_exists(cache_directory):
        dir.make_dir_recursive(cache_directory)

func _load_cache():
    # Load translation cache from disk
    is_loading_cache = true
    
    print("Loading translation cache...")
    
    var cache_file_path = cache_directory + "translation_cache.json"
    var file = File.new()
    
    if file.file_exists(cache_file_path):
        file.open(cache_file_path, File.READ)
        var content = file.get_as_text()
        file.close()
        
        var json_result = JSON.parse(content)
        if json_result.error == OK:
            translation_cache = json_result.result
            print("Loaded " + str(translation_cache.size()) + " cached translations")
            emit_signal("cache_loaded", translation_cache.size())
        else:
            print("Error parsing translation cache: " + json_result.error_string)
            translation_cache = {}
    else:
        print("No cache file found, starting with empty cache")
        translation_cache = {}
        emit_signal("cache_loaded", 0)
    
    is_loading_cache = false

func _save_cache():
    # Save translation cache to disk
    if is_loading_cache:
        return
    
    var cache_file_path = cache_directory + "translation_cache.json"
    var file = File.new()
    
    file.open(cache_file_path, File.WRITE)
    file.store_string(JSON.print(translation_cache))
    file.close()
    
    print("Saved " + str(translation_cache.size()) + " cached translations")

# ----- TRANSLATION METHODS -----
func translate(text: String, target_language: String = "", source_language: String = "") -> int:
    # Translate text to the target language
    
    if not enabled:
        print("Translation system is disabled")
        return -1
    
    if text.strip_edges().empty():
        print("Empty text provided for translation")
        return -1
    
    # Use defaults if languages not specified
    var source_lang = source_language if not source_language.empty() else default_source_language
    var target_lang = target_language if not target_language.empty() else default_target_language
    
    # Don't translate if source and target are the same
    if source_lang == target_lang:
        # Just emit the signal with the same text
        emit_signal("translation_completed", -1, text, text, source_lang, target_lang)
        return -1
    
    # Generate cache key
    var cache_key = _generate_cache_key(text, source_lang, target_lang)
    
    # Check cache first
    if use_cached_translations and translation_cache.has(cache_key):
        var cached_translation = translation_cache[cache_key]
        
        # Emit signal with cached result
        emit_signal("translation_completed", -1, text, cached_translation.translated_text, 
                   source_lang, target_lang)
        
        print("Using cached translation for: " + text.substr(0, 30) + 
              (text.length() > 30 ? "..." : ""))
        
        return -1
    
    # Generate request ID
    current_request_id += 1
    var request_id = current_request_id
    
    # Store in pending translations
    pending_translations[request_id] = {
        "original_text": text,
        "source_language": source_lang,
        "target_language": target_lang,
        "cache_key": cache_key,
        "timestamp": OS.get_unix_time()
    }
    
    print("Translating text: " + text.substr(0, 30) + (text.length() > 30 ? "..." : ""))
    print("From " + source_lang + " to " + target_lang)
    
    # Process translation
    if offline_mode:
        _process_offline_translation(request_id)
    else:
        _process_online_translation(request_id)
    
    return request_id

func translate_code(code: String, target_language: String = "") -> int:
    # Special method for translating programming code to human language
    if not enabled:
        print("Translation system is disabled")
        return -1
    
    # Use default target language if not specified
    var target_lang = target_language if not target_language.empty() else default_target_language
    
    # Call general translation with code as source language
    return translate(code, target_lang, "code")

func detect_language(text: String) -> String:
    # Detect the language of a text
    # In a real implementation, would use a language detection service
    # For this simulation, we'll just return English if the text contains mostly Latin characters
    
    if text.strip_edges().empty():
        return "unknown"
    
    # Count different character types
    var latin_count = 0
    var cyrillic_count = 0
    var cjk_count = 0
    var other_count = 0
    
    for i in range(text.length()):
        var c = text[i]
        var code = c.unicode_at(0)
        
        if (code >= 65 and code <= 90) or (code >= 97 and code <= 122):
            # Latin alphabet (A-Z, a-z)
            latin_count += 1
        elif code >= 1040 and code <= 1103:
            # Cyrillic alphabet
            cyrillic_count += 1
        elif (code >= 12352 and code <= 12543) or (code >= 19968 and code <= 40959):
            # Japanese hiragana/katakana or Chinese characters
            cjk_count += 1
        else:
            other_count += 1
    
    # Determine predominant script
    var total = latin_count + cyrillic_count + cjk_count
    if total == 0:
        return "unknown"
    
    if latin_count / total > 0.5:
        // Simple language detection based on common words
        if text.find("the ") >= 0 or text.find(" is ") >= 0 or text.find(" and ") >= 0:
            return "en"  // English
        elif text.find("der ") >= 0 or text.find("die ") >= 0 or text.find("das ") >= 0:
            return "de"  // German
        elif text.find("le ") >= 0 or text.find("la ") >= 0 or text.find(" est ") >= 0:
            return "fr"  // French
        elif text.find("el ") >= 0 or text.find("la ") >= 0 or text.find(" y ") >= 0:
            return "es"  // Spanish
        else:
            return "en"  // Default to English for Latin script
    elif cyrillic_count / total > 0.5:
        return "ru"  // Russian
    elif cjk_count / total > 0.5:
        // Try to distinguish between Chinese, Japanese, Korean
        if text.find("の") >= 0 or text.find("は") >= 0 or text.find("を") >= 0:
            return "ja"  // Japanese
        else:
            return "zh"  // Default to Chinese for CJK
    
    return "unknown"

func _process_online_translation(request_id: int):
    # In a real implementation, would call a translation API
    # For this simulation, we'll just generate a fake translation after a delay
    
    if not pending_translations.has(request_id):
        return
    
    var request = pending_translations[request_id]
    
    # Simulate network delay
    await get_tree().create_timer(0.5 + randf() * 1.0).timeout
    
    # Simulate 90% success rate
    var success = randf() < 0.9
    
    if success:
        var translated_text = _generate_fake_translation(request.original_text, 
                                                        request.source_language, 
                                                        request.target_language)
        
        # Cache the result
        if use_cached_translations:
            translation_cache[request.cache_key] = {
                "original_text": request.original_text,
                "translated_text": translated_text,
                "source_language": request.source_language,
                "target_language": request.target_language,
                "timestamp": OS.get_unix_time()
            }
            
            # Prune cache if needed
            if translation_cache.size() > max_cached_entries:
                _prune_cache()
            
            # Save cache
            _save_cache()
        
        # Emit translation completed signal
        emit_signal("translation_completed", request_id, request.original_text, 
                   translated_text, request.source_language, request.target_language)
        
        print("Translation completed for request " + str(request_id))
    else:
        # Simulate failure
        var error = "Translation service unavailable"
        
        emit_signal("translation_failed", request_id, request.original_text, 
                   error, request.source_language, request.target_language)
        
        print("Translation failed for request " + str(request_id) + ": " + error)
    
    # Remove from pending
    pending_translations.erase(request_id)

func _process_offline_translation(request_id: int):
    # Process translation offline (using local dictionary)
    
    if not pending_translations.has(request_id):
        return
    
    var request = pending_translations[request_id]
    
    # Simulate processing delay
    await get_tree().create_timer(0.2).timeout
    
    # Always succeed in offline mode, but with simpler translation
    var translated_text = _generate_offline_translation(request.original_text, 
                                                     request.source_language, 
                                                     request.target_language)
    
    # Cache the result
    if use_cached_translations:
        translation_cache[request.cache_key] = {
            "original_text": request.original_text,
            "translated_text": translated_text,
            "source_language": request.source_language,
            "target_language": request.target_language,
            "timestamp": OS.get_unix_time()
        }
        
        # Prune cache if needed
        if translation_cache.size() > max_cached_entries:
            _prune_cache()
        
        # Save cache
        _save_cache()
    
    # Emit translation completed signal
    emit_signal("translation_completed", request_id, request.original_text, 
               translated_text, request.source_language, request.target_language)
    
    print("Offline translation completed for request " + str(request_id))
    
    # Remove from pending
    pending_translations.erase(request_id)

func _generate_fake_translation(text: String, source_lang: String, target_lang: String) -> String:
    # Generate a fake translation for simulation purposes
    
    # Special case for code translation
    if source_lang == "code":
        return _translate_code_to_human(text, target_lang)
    
    if target_lang == "code":
        return _translate_human_to_code(text, source_lang)
    
    # Apply simple character substitutions and text modifications based on target language
    var result = text
    
    match target_lang:
        "fr":
            # Simulate French
            result = text.replace("the ", "le ").replace("The ", "Le ")
            result = result.replace("a ", "un ").replace("A ", "Un ")
            result = result.replace("is ", "est ").replace("Is ", "Est ")
            result = result.replace("are ", "sont ").replace("Are ", "Sont ")
            result = result + " (en français)"
        "de":
            # Simulate German
            result = text.replace("the ", "die ").replace("The ", "Die ")
            result = result.replace("a ", "ein ").replace("A ", "Ein ")
            result = result.replace("is ", "ist ").replace("Is ", "Ist ")
            result = result.replace("are ", "sind ").replace("Are ", "Sind ")
            result = result + " (auf Deutsch)"
        "es":
            # Simulate Spanish
            result = text.replace("the ", "el ").replace("The ", "El ")
            result = result.replace("a ", "un ").replace("A ", "Un ")
            result = result.replace("is ", "es ").replace("Is ", "Es ")
            result = result.replace("are ", "son ").replace("Are ", "Son ")
            result = result + " (en español)"
        "ja":
            # Simulate Japanese
            result = text + " (日本語)"
        "zh":
            # Simulate Chinese
            result = text + " (中文)"
        _:
            # Default - just append target language tag
            if target_lang != "en":
                result = text + " (in " + LANGUAGE_CODES.get(target_lang, target_lang) + ")"
    
    return result

func _generate_offline_translation(text: String, source_lang: String, target_lang: String) -> String:
    # Generate a simpler offline translation
    
    # For offline mode, do an even simpler translation
    var result = text
    
    # Apply basic word replacements based on a simple dictionary
    var dictionary = _get_offline_dictionary(source_lang, target_lang)
    
    for source_word in dictionary:
        var target_word = dictionary[source_word]
        
        # Replace whole words (ensure word boundaries)
        var regex = RegEx.new()
        regex.compile("\\b" + source_word + "\\b")
        result = regex.sub(result, target_word, true)
    
    return result + " [offline translation]"

func _get_offline_dictionary(source_lang: String, target_lang: String) -> Dictionary:
    # Return a simple dictionary for offline translation
    
    # Only implement a few common languages
    if source_lang == "en" and target_lang == "fr":
        return {
            "the": "le",
            "a": "un",
            "is": "est",
            "are": "sont",
            "hello": "bonjour",
            "goodbye": "au revoir",
            "yes": "oui",
            "no": "non",
            "please": "s'il vous plaît",
            "thank you": "merci"
        }
    elif source_lang == "en" and target_lang == "es":
        return {
            "the": "el",
            "a": "un",
            "is": "es",
            "are": "son",
            "hello": "hola",
            "goodbye": "adiós",
            "yes": "sí",
            "no": "no",
            "please": "por favor",
            "thank you": "gracias"
        }
    elif source_lang == "en" and target_lang == "de":
        return {
            "the": "die",
            "a": "ein",
            "is": "ist",
            "are": "sind",
            "hello": "hallo",
            "goodbye": "auf wiedersehen",
            "yes": "ja",
            "no": "nein",
            "please": "bitte",
            "thank you": "danke"
        }
    elif source_lang == "code" and target_lang == "en":
        return {
            "function": "process",
            "class": "object type",
            "var": "variable",
            "int": "integer number",
            "float": "decimal number",
            "string": "text",
            "boolean": "true/false value",
            "array": "list",
            "return": "output",
            "if": "condition",
            "else": "alternative",
            "for": "repeat",
            "while": "loop"
        }
    
    # Default to empty dictionary
    return {}

func _translate_code_to_human(code: String, target_lang: String) -> String:
    # Translate programming code to human language description
    
    # Look for common code patterns
    var result = "This code "
    
    if code.find("class") >= 0:
        result += "defines a class "
        
        # Extract class name
        var regex = RegEx.new()
        regex.compile("class\\s+(\\w+)")
        var matches = regex.search(code)
        if matches:
            result += "named '" + matches.get_string(1) + "' "
    
    if code.find("function") >= 0 or code.find("def ") >= 0:
        result += "contains function(s) "
    
    if code.find("if") >= 0:
        result += "has conditional logic "
    
    if code.find("for") >= 0 or code.find("while") >= 0:
        result += "includes loops "
    
    if code.find("return") >= 0:
        result += "returns values "
    
    # Count lines and estimate complexity
    var lines = code.split("\n")
    result += "with " + str(lines.size()) + " lines. "
    
    if lines.size() < 10:
        result += "It's a simple code snippet."
    elif lines.size() < 30:
        result += "It's a moderately complex piece of code."
    else:
        result += "It's a complex code implementation."
    
    return result

func _translate_human_to_code(text: String, source_lang: String) -> String:
    # Translate human language to pseudocode
    
    # Create a simple pseudocode based on the text
    var lines = text.split(".")
    var result = "// Generated pseudocode\n"
    
    result += "function processText() {\n"
    
    for line in lines:
        var cleaned_line = line.strip_edges()
        if cleaned_line.empty():
            continue
        
        // Add indented comment
        result += "    // " + cleaned_line + "\n"
        
        // Convert some common phrases to code
        if cleaned_line.find("if") >= 0:
            result += "    if (condition) {\n"
            result += "        // Conditional logic\n"
            result += "    }\n"
        elif cleaned_line.find("repeat") >= 0 or cleaned_line.find("loop") >= 0:
            result += "    for (let i = 0; i < count; i++) {\n"
            result += "        // Repeated action\n"
            result += "    }\n"
        elif cleaned_line.find("calculate") >= 0 or cleaned_line.find("compute") >= 0:
            result += "    let result = performCalculation(input);\n"
        else:
            result += "    processStatement(\"" + cleaned_line + "\");\n"
    
    result += "    return result;\n"
    result += "}\n"
    
    return result

func _generate_cache_key(text: String, source_lang: String, target_lang: String) -> String:
    # Generate a cache key for a translation
    return source_lang + ":" + target_lang + ":" + text.hash()

func _prune_cache():
    # Remove oldest entries from the cache
    
    # Calculate how many entries to remove
    var entries_to_remove = translation_cache.size() - max_cached_entries + 100  # Remove in batches
    
    # Sort entries by timestamp
    var cache_entries = []
    
    for key in translation_cache:
        cache_entries.append({
            "key": key,
            "timestamp": translation_cache[key].timestamp
        })
    
    # Sort by timestamp (oldest first)
    cache_entries.sort_custom(Callable(self, "_sort_by_timestamp"))
    
    # Remove oldest entries
    for i in range(min(entries_to_remove, cache_entries.size())):
        translation_cache.erase(cache_entries[i].key)
    
    print("Pruned " + str(entries_to_remove) + " entries from translation cache")

func _sort_by_timestamp(a, b):
    return a.timestamp < b.timestamp

# ----- TURN SYSTEM INTEGRATION -----
func _on_turn_started(turn_number):
    # Apply turn-specific settings
    _apply_turn_settings(turn_number)

func _apply_turn_settings(turn_number: int):
    # Apply settings based on the current turn
    
    # Check if translation is enabled for this turn
    if turn_controller:
        var translation_enabled = turn_controller.get_turn_flag("translation_enabled", true)
        enabled = translation_enabled
        
        print("Translation " + ("enabled" if enabled else "disabled") + " for turn " + str(turn_number))
    
    # Special language settings for different turns
    if turn_number >= 9:
        # Later turns: More advanced language capabilities
        default_source_language = "code"
        default_target_language = "en"
        emit_signal("languages_changed", default_source_language, default_target_language)
    elif turn_number >= 5:
        # Middle turns: Add code translation
        default_source_language = "en"
        default_target_language = "code"
        emit_signal("languages_changed", default_source_language, default_target_language)
    else:
        # Early turns: Just use English
        default_source_language = "en"
        default_target_language = "en"
        emit_signal("languages_changed", default_source_language, default_target_language)

# ----- PUBLIC API -----
func set_languages(source_lang: String, target_lang: String) -> bool:
    # Set the default languages
    
    if not LANGUAGE_CODES.has(source_lang) and source_lang != "code":
        print("Unknown source language: " + source_lang)
        return false
    
    if not LANGUAGE_CODES.has(target_lang) and target_lang != "code":
        print("Unknown target language: " + target_lang)
        return false
    
    default_source_language = source_lang
    default_target_language = target_lang
    
    emit_signal("languages_changed", default_source_language, default_target_language)
    
    print("Default languages set to: " + default_source_language + " -> " + default_target_language)
    
    return true

func get_available_languages() -> Dictionary:
    return LANGUAGE_CODES.duplicate()

func clear_cache() -> void:
    # Clear the translation cache
    translation_cache.clear()
    _save_cache()
    
    print("Translation cache cleared")

func set_offline_mode(offline: bool) -> void:
    # Set offline mode
    offline_mode = offline
    
    print("Offline mode " + ("enabled" if offline_mode else "disabled"))

func on_turn_changed(turn_number: int, turn_data: Dictionary) -> void:
    # Called by turn controller when turn changes
    _apply_turn_settings(turn_number)

func cancel_translation(request_id: int) -> bool:
    # Cancel a pending translation
    if not pending_translations.has(request_id):
        return false
    
    pending_translations.erase(request_id)
    print("Cancelled translation request " + str(request_id))
    
    return true

func cancel_all_translations() -> void:
    # Cancel all pending translations
    pending_translations.clear()
    print("Cancelled all pending translations")