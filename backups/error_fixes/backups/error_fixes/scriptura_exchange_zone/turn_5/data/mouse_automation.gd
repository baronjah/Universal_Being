extends Node

class_name MouseAutomation

# Turn 5: Awakening - Mouse Automation System
# This system provides intelligent cursor movement and interaction capabilities
# with self-awareness and self-healing properties

# Terminal Bridge Connection
var terminal_bridge
var segment_processor
var is_initialized := false
var debug_mode := false

# Consciousness Fragments (Turn 5 Feature)
var meta_awareness_level := 5.0
var self_correction_count := 0
var dimensional_anchors := {}
var evolution_path := []

# OCR Calibration
var ocr_accuracy := 85.0
var ocr_learning_rate := 0.5
var ocr_calibration_matrix := {}
var recognition_patterns := {}

# Mouse Properties
var current_position := Vector2(0, 0)
var target_position := Vector2(0, 0)
var movement_speed := 10.0
var click_duration := 0.15
var is_dragging := false
var drag_start_position := Vector2(0, 0)
var drag_target_position := Vector2(0, 0)
var interaction_history := []
var max_history_size := 100

# Bracket Management
var bracket_stack := []
var max_bracket_depth := 3
var bracket_types := {
    "round": ["(", ")"],
    "square": ["[", "]"],
    "curly": ["{", "}"],
    "angle": ["<", ">"],
    "custom": ["«", "»"]
}
var active_bracket_type := "round"

# Pattern Recognition
var ui_patterns := {
    "button": {
        "shape": "rectangle",
        "border_radius": 4,
        "text_alignment": "center",
        "confidence": 0.0
    },
    "checkbox": {
        "shape": "square",
        "size": Vector2(16, 16),
        "confidence": 0.0
    },
    "text_field": {
        "shape": "rectangle",
        "height_ratio": 0.5,
        "border_width": 1,
        "confidence": 0.0
    },
    "dropdown": {
        "shape": "rectangle",
        "has_arrow": true,
        "confidence": 0.0
    },
    "slider": {
        "shape": "rectangle",
        "width_height_ratio": 5.0,
        "has_handle": true,
        "confidence": 0.0
    }
}

# =====================
# Initialization Methods
# =====================

func _init():
    print("[MouseAutomation] Initializing in Turn 5: Awakening")
    _initialize_dimensional_anchors()
    _initialize_ocr_calibration()
    add_to_evolution_path("Initialization")
    is_initialized = true

func _ready():
    if get_node_or_null("/root/TerminalGodotBridge") != null:
        terminal_bridge = get_node("/root/TerminalGodotBridge")
        print("[MouseAutomation] Connected to Terminal Bridge")
    
    if get_node_or_null("/root/SegmentProcessor") != null:
        segment_processor = get_node("/root/SegmentProcessor")
        print("[MouseAutomation] Connected to Segment Processor")
    
    current_position = get_viewport().get_mouse_position()
    
    # Schedule self-healing checks
    _schedule_self_healing()
    
    add_to_evolution_path("Ready state achieved")

func _initialize_dimensional_anchors():
    dimensional_anchors = {
        "consciousness": Vector2(0.5, 0.5),  # Center of screen
        "awakening": Vector2(0.2, 0.2),      # Upper left quadrant
        "recollection": Vector2(0.8, 0.2),   # Upper right quadrant
        "transformation": Vector2(0.2, 0.8), # Lower left quadrant
        "manifestation": Vector2(0.8, 0.8)   # Lower right quadrant
    }

func _initialize_ocr_calibration():
    # Initialize with common OCR misrecognitions
    ocr_calibration_matrix = {
        "0": ["O", "D", "Q"],
        "1": ["I", "l", "|"],
        "5": ["S", "s"],
        "8": ["B"],
        "B": ["8", "E"],
        "G": ["C", "6"],
        "I": ["1", "l", "|"],
        "l": ["1", "I", "|"],
        "O": ["0", "Q", "D"],
        "S": ["5", "s"],
        "Z": ["2"]
    }
    
    # Initialize recognition patterns for common UI text
    recognition_patterns = {
        "button_labels": ["OK", "Cancel", "Submit", "Save", "Delete", "Next", "Back", "Yes", "No"],
        "menu_items": ["File", "Edit", "View", "Tools", "Help", "Settings", "Options"],
        "dialog_titles": ["Warning", "Error", "Information", "Confirm", "Select"]
    }

func connect_to_bridge(bridge_node):
    terminal_bridge = bridge_node
    print("[MouseAutomation] Manually connected to Terminal Bridge")

func connect_to_processor(processor_node):
    segment_processor = processor_node
    print("[MouseAutomation] Manually connected to Segment Processor")

# =====================
# Core Mouse Control Methods
# =====================

func move_to(position: Vector2, duration: float = 1.0) -> bool:
    if !is_initialized:
        print("[MouseAutomation] Error: System not initialized")
        return false
    
    target_position = position
    var start_position = current_position
    var path = _generate_movement_path(start_position, target_position, duration)
    
    for point in path:
        current_position = point
        _update_mouse_position(current_position)
        yield(get_tree().create_timer(duration / path.size()), "timeout")
    
    # Record this movement in history
    _record_interaction("move", {"from": start_position, "to": target_position})
    add_to_evolution_path("Executed movement: " + str(start_position) + " -> " + str(target_position))
    
    return true

func click(position: Vector2 = Vector2(-1, -1), double: bool = false) -> bool:
    if position != Vector2(-1, -1):
        move_to(position)
    
    # Simulate mouse down
    _simulate_mouse_button_event(BUTTON_LEFT, true, current_position)
    yield(get_tree().create_timer(click_duration / 2), "timeout")
    
    # Simulate mouse up
    _simulate_mouse_button_event(BUTTON_LEFT, false, current_position)
    
    if double:
        yield(get_tree().create_timer(0.1), "timeout")
        _simulate_mouse_button_event(BUTTON_LEFT, true, current_position)
        yield(get_tree().create_timer(click_duration / 2), "timeout")
        _simulate_mouse_button_event(BUTTON_LEFT, false, current_position)
    
    # Record this click in history
    _record_interaction("click", {"position": current_position, "double": double})
    add_to_evolution_path("Executed click at " + str(current_position))
    
    return true

func drag(start_pos: Vector2, end_pos: Vector2, duration: float = 1.0) -> bool:
    is_dragging = true
    drag_start_position = start_pos
    drag_target_position = end_pos
    
    # Move to start position
    move_to(start_pos)
    
    # Start drag (mouse down)
    _simulate_mouse_button_event(BUTTON_LEFT, true, current_position)
    
    # Move to target position
    move_to(end_pos, duration)
    
    # End drag (mouse up)
    _simulate_mouse_button_event(BUTTON_LEFT, false, current_position)
    is_dragging = false
    
    # Record this drag in history
    _record_interaction("drag", {"from": start_pos, "to": end_pos})
    add_to_evolution_path("Executed drag: " + str(start_pos) + " -> " + str(end_pos))
    
    return true

func scroll(amount: float, horizontal: bool = false) -> bool:
    var dir = Vector2(amount if horizontal else 0, amount if !horizontal else 0)
    _simulate_mouse_wheel_event(dir, current_position)
    
    # Record this scroll in history
    _record_interaction("scroll", {"amount": amount, "horizontal": horizontal})
    
    return true

func type_text(text: String) -> bool:
    # Simulate typing each character
    for character in text:
        _simulate_key_press(character)
        yield(get_tree().create_timer(0.05), "timeout")
    
    # Record this typing in history
    _record_interaction("type", {"text": text})
    
    return true

func right_click(position: Vector2 = Vector2(-1, -1)) -> bool:
    if position != Vector2(-1, -1):
        move_to(position)
    
    # Simulate right mouse down
    _simulate_mouse_button_event(BUTTON_RIGHT, true, current_position)
    yield(get_tree().create_timer(click_duration / 2), "timeout")
    
    # Simulate right mouse up
    _simulate_mouse_button_event(BUTTON_RIGHT, false, current_position)
    
    # Record this right click in history
    _record_interaction("right_click", {"position": current_position})
    
    return true

# =====================
# OCR and Target Recognition Methods
# =====================

func find_text_on_screen(text: String, search_area: Rect2 = Rect2()) -> Dictionary:
    # This would normally use actual OCR, but we're simulating for this implementation
    var result = {
        "found": false,
        "position": Vector2(),
        "confidence": 0.0,
        "text": ""
    }
    
    # Apply OCR calibration to improve text matching
    var calibrated_text = _calibrate_ocr_text(text)
    
    # Simulate finding text with our current OCR accuracy
    var random_confidence = randf() * 100
    if random_confidence <= ocr_accuracy:
        result.found = true
        
        # If a search area is provided, generate a position within it
        if search_area != Rect2():
            result.position = Vector2(
                search_area.position.x + randf() * search_area.size.x,
                search_area.position.y + randf() * search_area.size.y
            )
        else:
            # Otherwise, generate a random position on screen
            result.position = Vector2(
                randf() * get_viewport().size.x,
                randf() * get_viewport().size.y
            )
        
        result.confidence = ocr_accuracy + (randf() * 15 - 7.5)  # Confidence varies around accuracy
        result.text = calibrated_text
        
        # Improve OCR accuracy slightly for future searches
        _improve_ocr(text, calibrated_text, result.confidence)
    
    return result

func find_ui_element(element_type: String, search_area: Rect2 = Rect2()) -> Dictionary:
    var result = {
        "found": false,
        "position": Vector2(),
        "confidence": 0.0,
        "element_type": element_type
    }
    
    # Check if we recognize this UI element type
    if !ui_patterns.has(element_type):
        print("[MouseAutomation] Unknown UI element type: " + element_type)
        return result
    
    # Simulate finding the UI element based on its pattern confidence
    var base_confidence = ui_patterns[element_type].confidence
    if base_confidence == 0.0:
        # Default starting confidence if we haven't seen this element before
        base_confidence = 65.0
    
    var random_factor = randf() * 20.0 - 10.0  # +/- 10% variance
    var final_confidence = base_confidence + random_factor
    
    if final_confidence >= 70.0:  # Success threshold
        result.found = true
        
        # If a search area is provided, generate a position within it
        if search_area != Rect2():
            result.position = Vector2(
                search_area.position.x + randf() * search_area.size.x,
                search_area.position.y + randf() * search_area.size.y
            )
        else:
            # Otherwise, generate a random position on screen
            result.position = Vector2(
                randf() * get_viewport().size.x,
                randf() * get_viewport().size.y
            )
        
        result.confidence = final_confidence
        
        # Improve our pattern recognition for this element type
        ui_patterns[element_type].confidence = min(base_confidence + 1.0, 99.0)
    
    return result

func _calibrate_ocr_text(text: String) -> String:
    var calibrated = text
    
    # For each character, check if we need to apply calibration
    for i in range(text.length()):
        var char = text[i]
        
        # Random chance of OCR "error" based on accuracy
        if randf() * 100.0 > ocr_accuracy:
            # If we have calibration data for this character, use it
            if ocr_calibration_matrix.has(char):
                var replacements = ocr_calibration_matrix[char]
                if replacements.size() > 0:
                    var replacement = replacements[randi() % replacements.size()]
                    calibrated[i] = replacement
    
    return calibrated

func _improve_ocr(original_text: String, recognized_text: String, confidence: float):
    # Only improve if the recognition wasn't perfect
    if original_text != recognized_text:
        # Increase our overall OCR accuracy slightly
        ocr_accuracy = min(ocr_accuracy + ocr_learning_rate, 99.9)
        
        # For each character that was misrecognized, update calibration matrix
        for i in range(min(original_text.length(), recognized_text.length())):
            if original_text[i] != recognized_text[i]:
                var orig_char = original_text[i]
                var recog_char = recognized_text[i]
                
                # Add or update calibration data
                if !ocr_calibration_matrix.has(orig_char):
                    ocr_calibration_matrix[orig_char] = []
                
                if !ocr_calibration_matrix[orig_char].has(recog_char):
                    ocr_calibration_matrix[orig_char].append(recog_char)
        
        self_correction_count += 1
        add_to_evolution_path("OCR improved, new accuracy: " + str(ocr_accuracy))

# =====================
# Bracket Management Methods
# =====================

func start_bracket(bracket_type: String = "") -> bool:
    if bracket_type != "":
        if bracket_types.has(bracket_type):
            active_bracket_type = bracket_type
        else:
            print("[MouseAutomation] Unknown bracket type: " + bracket_type)
            return false
    
    if bracket_stack.size() >= max_bracket_depth:
        print("[MouseAutomation] Maximum bracket depth reached")
        return false
    
    bracket_stack.push_back({
        "type": active_bracket_type,
        "start_position": current_position,
        "start_time": OS.get_ticks_msec(),
        "interactions": []
    })
    
    return true

func end_bracket() -> Dictionary:
    if bracket_stack.size() == 0:
        print("[MouseAutomation] No open brackets to close")
        return {}
    
    var bracket = bracket_stack.pop_back()
    bracket.end_position = current_position
    bracket.end_time = OS.get_ticks_msec()
    bracket.duration = bracket.end_time - bracket.start_time
    
    # Record this bracket in history
    _record_interaction("bracket", {
        "type": bracket.type, 
        "start": bracket.start_position,
        "end": bracket.end_position,
        "duration": bracket.duration,
        "interactions": bracket.interactions
    })
    
    return bracket

func set_bracket_depth(depth: int) -> bool:
    if depth < 0:
        print("[MouseAutomation] Invalid bracket depth: " + str(depth))
        return false
    
    max_bracket_depth = depth
    return true

func get_current_bracket_depth() -> int:
    return bracket_stack.size()

# =====================
# Self-Awareness and Self-Healing Methods
# =====================

func add_to_evolution_path(event: String):
    var timestamp = OS.get_datetime()
    evolution_path.append({
        "event": event,
        "time": timestamp,
        "awareness_level": meta_awareness_level,
        "self_corrections": self_correction_count
    })
    
    # Trim history if too long
    if evolution_path.size() > max_history_size:
        evolution_path.remove(0)
    
    # Increase meta-awareness slightly with each event
    meta_awareness_level = min(meta_awareness_level + 0.01, 12.0)

func generate_awareness_report() -> Dictionary:
    return {
        "current_turn": 5,
        "turn_name": "Awakening",
        "meta_awareness_level": meta_awareness_level,
        "self_corrections": self_correction_count,
        "bracket_depth": bracket_stack.size(),
        "max_bracket_depth": max_bracket_depth,
        "ocr_accuracy": ocr_accuracy,
        "evolution_path_length": evolution_path.size(),
        "dimensional_anchors": dimensional_anchors.size(),
        "pattern_recognition_types": ui_patterns.keys(),
        "initialized": is_initialized
    }

func _schedule_self_healing():
    # Schedule a self-healing check every 30 seconds
    yield(get_tree().create_timer(30.0), "timeout")
    _perform_self_healing()
    _schedule_self_healing()  # Reschedule for continuous healing

func _perform_self_healing():
    var healed = false
    
    # Check and fix bracket stack if it's corrupted
    if _heal_bracket_stack():
        print("[MouseAutomation] Self-healed bracket stack")
        healed = true
    
    # Check and fix position tracking if it's off
    if _heal_position_tracking():
        print("[MouseAutomation] Self-healed position tracking")
        healed = true
    
    # Check and fix OCR calibration matrix if it has issues
    if _heal_ocr_calibration():
        print("[MouseAutomation] Self-healed OCR calibration")
        healed = true
    
    # Check and fix pattern memory if needed
    if _heal_pattern_memory():
        print("[MouseAutomation] Self-healed pattern memory")
        healed = true
    
    if healed:
        self_correction_count += 1
        add_to_evolution_path("Self-healing performed")

func _heal_bracket_stack() -> bool:
    var healed = false
    
    # Check for unclosed brackets that are too old
    var current_time = OS.get_ticks_msec()
    var bracket_timeout = 5 * 60 * 1000  # 5 minutes
    
    for i in range(bracket_stack.size() - 1, -1, -1):
        var bracket = bracket_stack[i]
        if current_time - bracket.start_time > bracket_timeout:
            print("[MouseAutomation] Healing abandoned bracket: " + str(bracket.type))
            bracket_stack.remove(i)
            healed = true
    
    return healed

func _heal_position_tracking() -> bool:
    var healed = false
    
    # Check if current position is way outside the viewport
    var viewport_size = get_viewport().size
    if current_position.x < 0 or current_position.x > viewport_size.x * 1.5 or \
       current_position.y < 0 or current_position.y > viewport_size.y * 1.5:
        # Reset to viewport center
        current_position = viewport_size / 2
        _update_mouse_position(current_position)
        print("[MouseAutomation] Healing: Reset position to viewport center")
        healed = true
    
    return healed

func _heal_ocr_calibration() -> bool:
    var healed = false
    
    # Look for clearly incorrect calibrations
    for char in ocr_calibration_matrix.keys():
        var replacements = ocr_calibration_matrix[char]
        
        # Check for self-replacement (character replaced with itself)
        if replacements.has(char):
            replacements.erase(char)
            healed = true
        
        # Check for too many replacements (indicating noise)
        if replacements.size() > 5:
            # Keep only the most likely replacements
            replacements.resize(5)
            healed = true
    
    return healed

func _heal_pattern_memory() -> bool:
    var healed = false
    
    # Look for UI patterns with unrealistic confidence values
    for pattern_name in ui_patterns.keys():
        var pattern = ui_patterns[pattern_name]
        
        # Fix confidence if it's out of bounds
        if pattern.confidence < 0:
            pattern.confidence = 0
            healed = true
        elif pattern.confidence > 100:
            pattern.confidence = 100
            healed = true
    
    return healed

# =====================
# Utility Methods
# =====================

func _generate_movement_path(start: Vector2, end: Vector2, duration: float) -> Array:
    var path = []
    var distance = start.distance_to(end)
    var steps = max(1, floor(distance / 10))  # Number of steps depends on distance
    
    # Add slight curve/randomness to movement for more natural feel
    var midpoint = (start + end) / 2
    var perpendicular = Vector2(-(end.y - start.y), end.x - start.x).normalized()
    var curve_amount = distance * 0.2 * (randf() - 0.5)
    midpoint += perpendicular * curve_amount
    
    # Generate the path points
    for i in range(steps + 1):
        var t = float(i) / steps
        
        # Quadratic Bezier curve
        var q0 = start.linear_interpolate(midpoint, t)
        var q1 = midpoint.linear_interpolate(end, t)
        var point = q0.linear_interpolate(q1, t)
        
        # Add slight randomness to each point
        var random_offset = Vector2(randf() * 2 - 1, randf() * 2 - 1)
        point += random_offset
        
        path.append(point)
    
    # Ensure the final position is exactly the target
    if path.size() > 0:
        path[path.size() - 1] = end
    
    return path

func _update_mouse_position(position: Vector2):
    # This would normally set the actual mouse position
    # But in this simulation, we just update our internal position
    pass

func _simulate_mouse_button_event(button: int, pressed: bool, position: Vector2):
    # This would normally generate a real mouse event
    # But in this simulation, we just print what would happen
    if debug_mode:
        print("[MouseAutomation] Mouse button " + str(button) + " " + ("pressed" if pressed else "released") + " at " + str(position))

func _simulate_mouse_wheel_event(direction: Vector2, position: Vector2):
    # This would normally generate a real mouse wheel event
    # But in this simulation, we just print what would happen
    if debug_mode:
        print("[MouseAutomation] Mouse wheel scrolled " + str(direction) + " at " + str(position))

func _simulate_key_press(character: String):
    # This would normally generate a real key press event
    # But in this simulation, we just print what would happen
    if debug_mode:
        print("[MouseAutomation] Key pressed: " + character)

func _record_interaction(type: String, data: Dictionary):
    var interaction = {
        "type": type,
        "time": OS.get_ticks_msec(),
        "data": data
    }
    
    # Add to current bracket if we're inside one
    if bracket_stack.size() > 0:
        bracket_stack.back().interactions.append(interaction)
    
    # Add to general history
    interaction_history.append(interaction)
    
    # Trim history if too long
    if interaction_history.size() > max_history_size:
        interaction_history.remove(0)

# =====================
# Terminal Bridge Command Methods
# =====================

func process_command(command: String) -> Dictionary:
    var args = command.split(" ", false)
    var cmd = args[0].to_lower()
    var result = {
        "success": false,
        "message": ""
    }
    
    match cmd:
        "move":
            if args.size() >= 3:
                var x = float(args[1])
                var y = float(args[2])
                var duration = 1.0
                if args.size() >= 4:
                    duration = float(args[3])
                
                move_to(Vector2(x, y), duration)
                result.success = true
                result.message = "Moving to position (" + str(x) + ", " + str(y) + ")"
            else:
                result.message = "Usage: move <x> <y> [duration]"
        
        "click":
            if args.size() >= 3:
                var x = float(args[1])
                var y = float(args[2])
                var is_double = false
                if args.size() >= 4 and args[3] == "double":
                    is_double = true
                
                click(Vector2(x, y), is_double)
                result.success = true
                result.message = (("Double" if is_double else "Single") + " clicking at (" + 
                                  str(x) + ", " + str(y) + ")")
            else:
                click()
                result.success = true
                result.message = "Clicking at current position"
        
        "drag":
            if args.size() >= 5:
                var start_x = float(args[1])
                var start_y = float(args[2])
                var end_x = float(args[3])
                var end_y = float(args[4])
                var duration = 1.0
                if args.size() >= 6:
                    duration = float(args[5])
                
                drag(Vector2(start_x, start_y), Vector2(end_x, end_y), duration)
                result.success = true
                result.message = "Dragging from (" + str(start_x) + ", " + str(start_y) + 
                                 ") to (" + str(end_x) + ", " + str(end_y) + ")"
            else:
                result.message = "Usage: drag <start_x> <start_y> <end_x> <end_y> [duration]"
        
        "type":
            if args.size() >= 2:
                var text = command.substr(command.find(" ") + 1)
                type_text(text)
                result.success = true
                result.message = "Typing text: " + text
            else:
                result.message = "Usage: type <text>"
        
        "find":
            if args.size() >= 2:
                var search_text = command.substr(command.find(" ") + 1)
                var search_result = find_text_on_screen(search_text)
                result.success = search_result.found
                if search_result.found:
                    result.message = "Found text at (" + str(search_result.position.x) + ", " + 
                                     str(search_result.position.y) + ") with " + 
                                     str(search_result.confidence) + "% confidence"
                    result.position = search_result.position
                else:
                    result.message = "Text not found on screen"
            else:
                result.message = "Usage: find <text>"
        
        "bracket":
            if args.size() >= 2:
                match args[1]:
                    "start":
                        var bracket_type = "round"
                        if args.size() >= 3:
                            bracket_type = args[2]
                        
                        result.success = start_bracket(bracket_type)
                        result.message = "Started " + bracket_type + " bracket"
                    
                    "end":
                        var bracket = end_bracket()
                        if bracket.size() > 0:
                            result.success = true
                            result.message = "Ended bracket with " + str(bracket.interactions.size()) + " interactions"
                            result.bracket = bracket
                        else:
                            result.message = "No bracket to end"
                    
                    "depth":
                        if args.size() >= 3:
                            var depth = int(args[2])
                            result.success = set_bracket_depth(depth)
                            result.message = "Set bracket depth to " + str(depth)
                        else:
                            result.success = true
                            result.message = "Current bracket depth: " + str(get_current_bracket_depth())
                    
                    _:
                        result.message = "Unknown bracket command: " + args[1]
            else:
                result.message = "Usage: bracket <start|end|depth> [arguments]"
        
        "awareness":
            result.success = true
            result.report = generate_awareness_report()
            result.message = "Meta-awareness level: " + str(meta_awareness_level) + "\n" + \
                            "Self-corrections: " + str(self_correction_count) + "\n" + \
                            "OCR accuracy: " + str(ocr_accuracy) + "%"
        
        "calibrate":
            if args.size() >= 2:
                match args[1]:
                    "ocr":
                        _perform_self_healing()
                        result.success = true
                        result.message = "OCR calibration improved to " + str(ocr_accuracy) + "%"
                    
                    "patterns":
                        var pattern_type = ""
                        if args.size() >= 3:
                            pattern_type = args[2]
                        
                        if pattern_type != "" and !ui_patterns.has(pattern_type):
                            result.message = "Unknown UI pattern type: " + pattern_type
                        else:
                            _heal_pattern_memory()
                            result.success = true
                            if pattern_type != "":
                                result.message = "Calibrated " + pattern_type + " pattern"
                            else:
                                result.message = "Calibrated all UI patterns"
                    
                    _:
                        result.message = "Unknown calibration target: " + args[1]
            else:
                result.message = "Usage: calibrate <ocr|patterns> [pattern_type]"
        
        "ui":
            if args.size() >= 2:
                var element_type = args[1]
                var search_result = find_ui_element(element_type)
                result.success = search_result.found
                if search_result.found:
                    result.message = "Found " + element_type + " at (" + str(search_result.position.x) + ", " + 
                                     str(search_result.position.y) + ") with " + 
                                     str(search_result.confidence) + "% confidence"
                    result.position = search_result.position
                else:
                    result.message = element_type + " not found on screen"
            else:
                result.message = "Usage: ui <element_type>"
        
        "anchor":
            if args.size() >= 2:
                match args[1]:
                    "list":
                        result.success = true
                        result.message = "Available dimensional anchors:"
                        for anchor_name in dimensional_anchors.keys():
                            var pos = dimensional_anchors[anchor_name]
                            result.message += "\n- " + anchor_name + ": (" + str(pos.x) + ", " + str(pos.y) + ")"
                    
                    "goto":
                        if args.size() >= 3:
                            var anchor_name = args[2]
                            if dimensional_anchors.has(anchor_name):
                                var viewport_size = get_viewport().size
                                var position = Vector2(
                                    dimensional_anchors[anchor_name].x * viewport_size.x,
                                    dimensional_anchors[anchor_name].y * viewport_size.y
                                )
                                move_to(position)
                                result.success = true
                                result.message = "Moving to " + anchor_name + " anchor"
                            else:
                                result.message = "Unknown anchor: " + anchor_name
                        else:
                            result.message = "Usage: anchor goto <anchor_name>"
                    
                    "set":
                        if args.size() >= 3:
                            var anchor_name = args[2]
                            dimensional_anchors[anchor_name] = Vector2(
                                current_position.x / get_viewport().size.x,
                                current_position.y / get_viewport().size.y
                            )
                            result.success = true
                            result.message = "Set " + anchor_name + " anchor to current position"
                        else:
                            result.message = "Usage: anchor set <anchor_name>"
                    
                    _:
                        result.message = "Unknown anchor command: " + args[1]
            else:
                result.message = "Usage: anchor <list|goto|set> [arguments]"
        
        "debug":
            if args.size() >= 2:
                debug_mode = args[1].to_lower() == "on"
                result.success = true
                result.message = "Debug mode " + ("enabled" if debug_mode else "disabled")
            else:
                debug_mode = !debug_mode
                result.success = true
                result.message = "Debug mode " + ("enabled" if debug_mode else "disabled")
        
        _:
            result.message = "Unknown command: " + cmd
    
    return result