extends Control

# References to UI elements
onready var prompt_input = $VBoxContainer/PromptInput
onready var claude_button = $VBoxContainer/ButtonsContainer/ClaudeButton
onready var gemini_button = $VBoxContainer/ButtonsContainer/GeminiButton
onready var compare_button = $VBoxContainer/ButtonsContainer/CompareButton
onready var response_container = $VBoxContainer/ResponseContainer
onready var claude_panel = $VBoxContainer/ResponseContainer/ClaudePanel
onready var gemini_panel = $VBoxContainer/ResponseContainer/GeminiPanel
onready var compare_panel = $VBoxContainer/ResponseContainer/ComparePanel
onready var api_controller = $APIController

# Current prompt text
var current_prompt = ""

# Panel visibility states
var current_view = "none"

func _ready():
    # Connect button signals
    claude_button.connect("pressed", self, "_on_claude_button_pressed")
    gemini_button.connect("pressed", self, "_on_gemini_button_pressed")
    compare_button.connect("pressed", self, "_on_compare_button_pressed")
    
    # Connect API controller signal
    api_controller.connect("api_response_received", self, "_on_api_response")
    
    # Set button colors
    claude_button.modulate = api_controller.get_api_color("claude")
    gemini_button.modulate = api_controller.get_api_color("gemini")
    
    # Hide all panels initially
    claude_panel.visible = false
    gemini_panel.visible = false
    compare_panel.visible = false
    
    # Disable compare button until we have responses from both APIs
    compare_button.disabled = true

func _on_claude_button_pressed():
    current_prompt = prompt_input.text
    if current_prompt.empty():
        return
        
    # Visual feedback
    claude_button.disabled = true
    claude_button.text = "Processing..."
    
    # Call the Claude API
    api_controller.call_api("claude", current_prompt)
    
    # Show the Claude panel
    _set_view("claude")

func _on_gemini_button_pressed():
    current_prompt = prompt_input.text
    if current_prompt.empty():
        return
        
    # Visual feedback
    gemini_button.disabled = true
    gemini_button.text = "Processing..."
    
    # Call the Gemini API
    api_controller.call_api("gemini", current_prompt)
    
    # Show the Gemini panel
    _set_view("gemini")

func _on_compare_button_pressed():
    # Show the compare panel with both responses
    _set_view("compare")

func _on_api_response(api_name, response):
    # Update the appropriate panel with the response
    if api_name == "claude":
        var label = claude_panel.get_node("ScrollContainer/Label")
        label.text = response
        
        # Reset button state
        claude_button.disabled = false
        claude_button.text = "Claude API"
    elif api_name == "gemini":
        var label = gemini_panel.get_node("ScrollContainer/Label")
        label.text = response
        
        # Reset button state
        gemini_button.disabled = false
        gemini_button.text = "Gemini API"
    
    # Enable compare button if we have responses from both APIs
    if api_controller.get_last_response("claude") != null && api_controller.get_last_response("gemini") != null:
        compare_button.disabled = false
        
        # Update compare panel
        var compare_text = ""
        compare_text += "Claude:\n" + api_controller.get_last_response("claude") + "\n\n"
        compare_text += "Gemini:\n" + api_controller.get_last_response("gemini")
        compare_panel.get_node("ScrollContainer/Label").text = compare_text

# Set which view is currently displayed
func _set_view(view):
    current_view = view
    
    # Hide all panels first
    claude_panel.visible = false
    gemini_panel.visible = false
    compare_panel.visible = false
    
    # Show the requested panel
    match view:
        "claude":
            claude_panel.visible = true
        "gemini":
            gemini_panel.visible = true
        "compare":
            compare_panel.visible = true
            
    # Update button highlights
    claude_button.modulate = api_controller.get_api_color("claude") if view == "claude" else Color(0.8, 0.8, 0.8)
    gemini_button.modulate = api_controller.get_api_color("gemini") if view == "gemini" else Color(0.8, 0.8, 0.8)
    compare_button.modulate = Color(1, 1, 1) if view == "compare" else Color(0.8, 0.8, 0.8)