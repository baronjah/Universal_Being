extends Node

signal turn_complete(turn_number, phase_name)
signal phase_change(old_phase, new_phase)
signal cycle_complete

# Turn system configuration
var max_turns_per_phase = 12
var current_turn = 1
var current_phase = 1
var phase_names = [
    "Genesis (α)",
    "Formation (β)",
    "Complexity (γ)",
    "Consciousness (δ)",
    "Awakening (ε)",
    "Enlightenment (ζ)",
    "Manifestation (η)",
    "Connection (θ)",
    "Harmony (ι)",
    "Transcendence (κ)",
    "Unity (λ)",
    "Beyond (μ)"
]

# API usage tracking
var api_calls = {
    "claude": 0,
    "gemini": 0
}

# Cost estimation (per 1K tokens)
var cost_per_1k_tokens = {
    "claude": 0.03,  # Simplified rate
    "gemini": 0.01   # Simplified rate
}

# Estimated token count per call
var avg_tokens_per_call = 500

# Initialize the turn system
func _ready():
    update_display()

# Advance to the next turn
func advance_turn():
    current_turn += 1
    
    # Check if we've completed a phase
    if current_turn > max_turns_per_phase:
        var old_phase = current_phase
        current_turn = 1
        current_phase += 1
        
        # Check if we've completed a full cycle
        if current_phase > phase_names.size():
            current_phase = 1
            emit_signal("cycle_complete")
        
        emit_signal("phase_change", old_phase, current_phase)
    
    # Emit turn completion signal
    emit_signal("turn_complete", current_turn, get_current_phase_name())
    
    # Update the UI
    update_display()
    
    # Check if we should take a break
    if current_turn % 12 == 0:
        suggest_break()

# Get the name of the current phase
func get_current_phase_name():
    return phase_names[current_phase - 1]

# Update the display with current turn information
func update_display():
    # Implementation depends on UI structure
    if has_node("../TurnDisplay"):
        var display = get_node("../TurnDisplay")
        display.get_node("TurnLabel").text = "Turn: " + str(current_turn) + "/12"
        display.get_node("PhaseLabel").text = "Phase: " + get_current_phase_name()
        
        # Update progress bar
        display.get_node("TurnProgress").value = (current_turn / float(max_turns_per_phase)) * 100
        
        # Update API call counter
        display.get_node("APIUsageLabel").text = "Claude: " + str(api_calls["claude"]) + " | Gemini: " + str(api_calls["gemini"])
        
        # Update cost estimate
        var claude_cost = (api_calls["claude"] * avg_tokens_per_call / 1000.0) * cost_per_1k_tokens["claude"]
        var gemini_cost = (api_calls["gemini"] * avg_tokens_per_call / 1000.0) * cost_per_1k_tokens["gemini"]
        display.get_node("CostLabel").text = "Est. Cost: $" + str(stepify(claude_cost + gemini_cost, 0.01))

# Track an API call
func track_api_call(api_name):
    if api_calls.has(api_name):
        api_calls[api_name] += 1
        update_display()
        
        # Advance turn on each API call
        advance_turn()

# Suggest a break at turn boundaries
func suggest_break():
    # Show break suggestion notification
    if has_node("../BreakNotification"):
        var notification = get_node("../BreakNotification")
        notification.visible = true
        notification.get_node("Label").text = "Turn cycle complete. Consider taking a break."
        
        # Auto-hide after 10 seconds
        yield(get_tree().create_timer(10.0), "timeout")
        notification.visible = false