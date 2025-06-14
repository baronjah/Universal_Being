extends Node

# This script connects the MouseAutomation system to the Terminal-Godot Bridge
# It serves as the integration layer for Turn 5: Awakening

class_name MouseAutomationIntegration

var terminal_bridge
var mouse_automation
var segment_processor

var automation_enabled := true
var automation_queue := []
var is_processing_queue := false

# ==================
# Initialization
# ==================

func _ready():
    # Connect to required nodes
    yield(get_tree(), "idle_frame")
    _connect_to_dependencies()
    
    print("[MouseAutomationIntegration] Initialized for Turn 5: Awakening")

func _connect_to_dependencies():
    # Find and connect to TerminalGodotBridge
    if get_node_or_null("/root/TerminalGodotBridge") != null:
        terminal_bridge = get_node("/root/TerminalGodotBridge")
        print("[MouseAutomationIntegration] Connected to Terminal Bridge")
        
        # Register ourselves with the bridge
        if terminal_bridge.has_method("register_mouse_automation"):
            terminal_bridge.register_mouse_automation(self)
    
    # Find and connect to MouseAutomation
    if get_node_or_null("/root/MouseAutomation") != null:
        mouse_automation = get_node("/root/MouseAutomation")
        print("[MouseAutomationIntegration] Connected to Mouse Automation")
    else:
        # Create MouseAutomation if it doesn't exist
        mouse_automation = MouseAutomation.new()
        mouse_automation.name = "MouseAutomation"
        get_tree().root.add_child(mouse_automation)
        print("[MouseAutomationIntegration] Created and connected to Mouse Automation")
    
    # Find and connect to SegmentProcessor
    if get_node_or_null("/root/SegmentProcessor") != null:
        segment_processor = get_node("/root/SegmentProcessor")
        print("[MouseAutomationIntegration] Connected to Segment Processor")
        
        # Connect mouse automation to segment processor
        if mouse_automation.has_method("connect_to_processor"):
            mouse_automation.connect_to_processor(segment_processor)
    
    # Connect mouse automation to terminal bridge if needed
    if terminal_bridge != null and mouse_automation.has_method("connect_to_bridge"):
        mouse_automation.connect_to_bridge(terminal_bridge)

# ==================
# Command Processing
# ==================

func process_automation_command(command: String) -> Dictionary:
    # Process mouse automation commands
    if mouse_automation != null:
        return mouse_automation.process_command(command)
    else:
        return {
            "success": false,
            "message": "Mouse automation system not available"
        }

func queue_automation_sequence(commands: Array) -> Dictionary:
    # Add commands to queue for sequential processing
    automation_queue.append_array(commands)
    
    # Start processing the queue if not already in progress
    if !is_processing_queue:
        _process_automation_queue()
    
    return {
        "success": true,
        "message": "Queued " + str(commands.size()) + " automation commands",
        "queue_size": automation_queue.size()
    }

func _process_automation_queue():
    if !automation_enabled or automation_queue.size() == 0:
        is_processing_queue = false
        return
    
    is_processing_queue = true
    var command = automation_queue[0]
    automation_queue.remove(0)
    
    var result = process_automation_command(command)
    print("[MouseAutomationIntegration] Executed: " + command + " - " + 
          ("Success" if result.success else "Failed"))
    
    # Process next command after a short delay
    yield(get_tree().create_timer(0.5), "timeout")
    _process_automation_queue()

# ==================
# OCR Integration
# ==================

func calibrate_ocr_from_text(original_text: String, recognized_text: String) -> Dictionary:
    # Improve OCR calibration based on text correction
    if mouse_automation != null and mouse_automation.has_method("_improve_ocr"):
        mouse_automation._improve_ocr(original_text, recognized_text, 80.0)
        return {
            "success": true,
            "message": "OCR calibrated with correction data",
            "accuracy": mouse_automation.ocr_accuracy
        }
    else:
        return {
            "success": false,
            "message": "OCR calibration not available"
        }

# ==================
# Bracket Management Integration
# ==================

func start_automation_bracket(bracket_name: String, bracket_type: String = "round") -> Dictionary:
    if mouse_automation != null and mouse_automation.has_method("start_bracket"):
        var success = mouse_automation.start_bracket(bracket_type)
        
        if success:
            return {
                "success": true,
                "message": "Started automation bracket: " + bracket_name,
                "type": bracket_type,
                "depth": mouse_automation.get_current_bracket_depth()
            }
        else:
            return {
                "success": false,
                "message": "Failed to start automation bracket"
            }
    else:
        return {
            "success": false,
            "message": "Bracket management not available"
        }

func end_automation_bracket() -> Dictionary:
    if mouse_automation != null and mouse_automation.has_method("end_bracket"):
        var bracket = mouse_automation.end_bracket()
        
        if bracket.size() > 0:
            return {
                "success": true,
                "message": "Ended automation bracket",
                "interactions": bracket.interactions.size(),
                "duration": bracket.duration
            }
        else:
            return {
                "success": false,
                "message": "No automation bracket to end"
            }
    else:
        return {
            "success": false,
            "message": "Bracket management not available"
        }

# ==================
# Pattern Recognition Integration
# ==================

func register_ui_pattern(element_type: String, pattern_data: Dictionary) -> Dictionary:
    if mouse_automation != null and mouse_automation.has_method("find_ui_element"):
        # Create or update UI pattern
        mouse_automation.ui_patterns[element_type] = pattern_data
        mouse_automation.ui_patterns[element_type].confidence = 75.0
        
        return {
            "success": true,
            "message": "Registered UI pattern: " + element_type,
            "pattern": pattern_data
        }
    else:
        return {
            "success": false,
            "message": "Pattern recognition not available"
        }

# ==================
# Self-Awareness Integration
# ==================

func generate_self_aware_report() -> Dictionary:
    if mouse_automation != null and mouse_automation.has_method("generate_awareness_report"):
        var report = mouse_automation.generate_awareness_report()
        
        # Enhance with segment processor data if available
        if segment_processor != null and segment_processor.has_method("get_segmentation_stats"):
            var segment_stats = segment_processor.get_segmentation_stats()
            report.segment_stats = segment_stats
        
        # Enhance with terminal bridge data if available
        if terminal_bridge != null and terminal_bridge.has_method("get_bridge_stats"):
            var bridge_stats = terminal_bridge.get_bridge_stats()
            report.bridge_stats = bridge_stats
        
        return {
            "success": true,
            "message": "Generated self-aware system report",
            "report": report
        }
    else:
        return {
            "success": false,
            "message": "Self-awareness reporting not available"
        }

# ==================
# Terminal Command Interpretation
# ==================

func handle_terminal_command(command: String) -> Dictionary:
    var result = {
        "success": false,
        "message": "",
        "handler": "mouse_automation"
    }
    
    # Split into command and arguments
    var parts = command.split(" ", false)
    if parts.size() == 0:
        result.message = "Empty command"
        return result
    
    var cmd = parts[0].to_lower()
    
    # Mouse automation specific commands
    match cmd:
        "automate":
            if parts.size() >= 2:
                var subcmd = parts[1].to_lower()
                var automation_cmd = command.substr(command.find(subcmd))
                
                result = process_automation_command(automation_cmd)
            else:
                result.message = "Usage: automate <command> [arguments]"
        
        "autobot":
            if parts.size() >= 2:
                match parts[1].to_lower():
                    "enable":
                        automation_enabled = true
                        result.success = true
                        result.message = "Autobot enabled"
                    
                    "disable":
                        automation_enabled = false
                        result.success = true
                        result.message = "Autobot disabled"
                    
                    "status":
                        result.success = true
                        result.message = "Autobot is " + ("enabled" if automation_enabled else "disabled")
                        result.queue_size = automation_queue.size()
                    
                    "sequence":
                        if parts.size() >= 3:
                            var sequence_name = parts[2]
                            var commands = _get_predefined_sequence(sequence_name)
                            
                            if commands.size() > 0:
                                result = queue_automation_sequence(commands)
                            else:
                                result.message = "Unknown sequence: " + sequence_name
                        else:
                            result.message = "Usage: autobot sequence <sequence_name>"
                    
                    "clear":
                        automation_queue.clear()
                        is_processing_queue = false
                        result.success = true
                        result.message = "Automation queue cleared"
                    
                    _:
                        result.message = "Unknown autobot command: " + parts[1]
            else:
                result.success = true
                result.message = "Autobot is " + ("enabled" if automation_enabled else "disabled") + \
                               "\nQueue size: " + str(automation_queue.size())
        
        _:
            # Not a mouse automation command
            result.handler = "other"
    
    return result

# ==================
# Predefined Sequences
# ==================

func _get_predefined_sequence(sequence_name: String) -> Array:
    var commands = []
    
    match sequence_name.to_lower():
        "scan_ui":
            commands = [
                "ui button",
                "ui text_field",
                "ui checkbox",
                "ui dropdown",
                "ui slider"
            ]
        
        "calibrate_all":
            commands = [
                "calibrate ocr",
                "calibrate patterns",
                "awareness"
            ]
        
        "center_scan":
            var viewport_size = get_viewport().size
            var center_x = viewport_size.x / 2
            var center_y = viewport_size.y / 2
            
            commands = [
                "move " + str(center_x) + " " + str(center_y),
                "bracket start",
                "move " + str(center_x - 100) + " " + str(center_y - 100),
                "move " + str(center_x + 100) + " " + str(center_y - 100),
                "move " + str(center_x + 100) + " " + str(center_y + 100),
                "move " + str(center_x - 100) + " " + str(center_y + 100),
                "move " + str(center_x) + " " + str(center_y),
                "bracket end"
            ]
        
        "awakening_anchors":
            commands = [
                "anchor goto consciousness",
                "anchor goto awakening",
                "anchor goto recollection",
                "anchor goto transformation",
                "anchor goto manifestation"
            ]
    
    return commands