extends Control

# quantum_terminal_visualizer.gd
# Enhanced terminal visualizer that integrates with DataPackSystem
# and supports dynamic visualization with quantum physics principles

# Configuration
export var background_color = Color(0.1, 0.1, 0.1)
export var text_color = Color(0.8, 0.8, 0.8)
export var highlight_color_1 = Color(0.0, 0.5, 1.0)  # Blue
export var highlight_color_2 = Color(1.0, 0.5, 0.0)  # Orange
export var emoji_color = Color(1.0, 0.9, 0.0)        # Yellow
export var quantum_color = Color(0.7, 0.0, 0.9)      # Purple for quantum elements

# Display settings
export var terminal_width = 600
export var terminal_height = 400
export var font_size = 14
export var auto_scroll = true
export var enable_quantum_effects = true
export var cycle_transition_time = 0.5  # Seconds

# Reference to data system
var data_pack_system = null
onready var rich_text_label = $RichTextLabel

# Terminal display
var terminal_lines = []
var max_lines = 200
var visible_lines = 25
var scroll_position = 0

# Quantum visualization states
var quantum_particles = []
var center_energy = 0.0
var synergy_field = []

# Signal for updates
signal terminal_updated()

func _ready():
    # Set up UI elements
    if not rich_text_label:
        rich_text_label = $RichTextLabel
    
    rich_text_label.bbcode_enabled = true
    
    # Create or get data system
    if not data_pack_system:
        data_pack_system = load("res://data_pack_system.gd").new()
        add_child(data_pack_system)
        data_pack_system.register_terminal(self)
    
    # Connect signals
    data_pack_system.connect("data_updated", self, "_on_data_updated")
    data_pack_system.connect("cycle_changed", self, "_on_cycle_changed")
    
    # Initialize display
    update_terminal_display()
    
    # Generate test data
    data_pack_system.debug_generate_test_data(30)

func _process(delta):
    if enable_quantum_effects:
        _update_quantum_effects(delta)

# Update quantum visualization effects
func _update_quantum_effects(delta):
    # Update center energy based on synergy
    center_energy = lerp(center_energy, data_pack_system.stats.synergy_score, delta * 2.0)
    
    # Update quantum particles
    for i in range(quantum_particles.size()):
        var particle = quantum_particles[i]
        particle.phase += delta * (0.5 + particle.frequency)
        particle.x += cos(particle.phase) * particle.speed * delta
        particle.y += sin(particle.phase) * particle.speed * delta
        
        # Check if particle is outside bounds
        if particle.x < 0 or particle.x > 1 or particle.y < 0 or particle.y > 1:
            # Reset to random position
            particle.x = randf()
            particle.y = randf()
    
    # Occasionally create new particles
    if randf() < delta * 0.3 and quantum_particles.size() < 20:
        _create_quantum_particle()
    
    # Update display to show quantum effects
    update()

# Create a quantum particle for visualization
func _create_quantum_particle():
    var particle = {
        "x": 0.5,  # Center
        "y": 0.5,
        "phase": randf() * TAU,
        "amplitude": 0.2 + randf() * 0.3,
        "frequency": 0.5 + randf() * 2.0,
        "speed": 0.05 + randf() * 0.1,
        "color": Color(highlight_color_1.r, highlight_color_1.g, highlight_color_1.b, 0.3 + randf() * 0.3)
    }
    quantum_particles.append(particle)

# Custom drawing for quantum effects
func _draw():
    if not enable_quantum_effects:
        return
    
    # Draw quantum field lines
    var center_x = rect_size.x / 2
    var center_y = rect_size.y / 2
    var radius = min(rect_size.x, rect_size.y) * 0.4
    
    # Draw synergy field
    var synergy_color = quantum_color
    synergy_color.a = 0.1 + center_energy * 0.3
    
    for i in range(12):  # 12 for LUNO cycles
        var angle1 = TAU * i / 12.0
        var angle2 = TAU * ((i + 1) % 12) / 12.0
        
        var x1 = center_x + cos(angle1) * radius
        var y1 = center_y + sin(angle1) * radius
        var x2 = center_x + cos(angle2) * radius
        var y2 = center_y + sin(angle2) * radius
        
        draw_line(Vector2(x1, y1), Vector2(x2, y2), synergy_color, 1.0 + center_energy * 3.0)
    
    # Draw quantum particles
    for particle in quantum_particles:
        var x = particle.x * rect_size.x
        var y = particle.y * rect_size.y
        var size = 2.0 + particle.amplitude * 10.0 * (0.5 + 0.5 * sin(particle.phase))
        
        draw_circle(Vector2(x, y), size, particle.color)
    
    # Draw center energy
    if center_energy > 0.1:
        var center_color = highlight_color_2
        center_color.a = center_energy * 0.7
        draw_circle(Vector2(center_x, center_y), center_energy * radius * 0.5, center_color)

# Signal handlers
func _on_data_updated(segment_id):
    update_terminal_display()

func _on_cycle_changed(cycle_num, phase_name):
    # Add cycle transition message
    log_message("⚡ Cycle advanced to %d: %s" % [cycle_num, phase_name], "cycle_change")
    
    # Clear quantum particles for transition effect
    quantum_particles.clear()
    
    # Create new particles for new cycle
    for i in range(10):
        _create_quantum_particle()
    
    # Update display
    update_terminal_display()

# Main display update
func update_terminal_display():
    var bbcode = ""
    
    # Get current cycle information
    var cycle_info = data_pack_system.get_current_cycle_info()
    var current_cycle = data_pack_system.current_cycle
    
    # Header with cycle information
    bbcode += "[color=#%s]🌊 LUNO Cycle System - Phase %d: %s[/color]\n" % [
        highlight_color_1.to_html(),
        current_cycle,
        cycle_info.phase
    ]
    
    # Cycle purpose
    bbcode += "[color=#%s]Purpose: %s[/color]\n\n" % [
        highlight_color_2.to_html(),
        cycle_info.purpose
    ]
    
    # Get data display from system
    var display_buffer = data_pack_system.get_display_buffer()
    
    # Format each line with appropriate styling
    for item in display_buffer:
        match item.type:
            "header":
                bbcode += "[color=#%s]%s[/color]\n" % [highlight_color_1.to_html(), item.text]
            "subheader":
                bbcode += "[color=#%s]%s[/color]\n" % [highlight_color_2.to_html(), item.text]
            "stats":
                bbcode += "[color=#%s]%s[/color]\n" % [emoji_color.to_html(), item.text]
            "data":
                bbcode += "%s\n" % item.text
            "segment":
                bbcode += "[color=#%s]%s[/color]\n" % [quantum_color.to_html(), item.text]
            "footer":
                bbcode += "\n[color=#%s]%s[/color]" % [emoji_color.to_html(), item.text]
            _:
                bbcode += "%s\n" % item.text
    
    # Add quantum information if enabled
    if enable_quantum_effects:
        bbcode += "\n[color=#%s]🔮 Quantum Harmonics: %.1f%%[/color]" % [
            quantum_color.to_html(),
            center_energy * 100
        ]
    
    # Update display
    rich_text_label.bbcode_text = bbcode
    
    # Auto-scroll
    if auto_scroll:
        rich_text_label.scroll_to_line(rich_text_label.get_line_count())
    
    emit_signal("terminal_updated")

# Public API for adding messages
func log_message(message, type="info"):
    terminal_lines.append({
        "text": message,
        "type": type,
        "timestamp": OS.get_unix_time()
    })
    
    # Trim if over max
    while terminal_lines.size() > max_lines:
        terminal_lines.pop_front()
    
    # Add to data pack system if appropriate
    if type != "system":  # Don't add system messages to data packs
        data_pack_system.add_data_pack({
            "text": message,
            "type": type
        })
    
    # Update display
    update_terminal_display()

# Navigation methods
func scroll_up():
    scroll_position = max(0, scroll_position - 1)
    update_terminal_display()

func scroll_down():
    scroll_position = min(terminal_lines.size() - visible_lines, scroll_position + 1)
    update_terminal_display()

func page_up():
    scroll_position = max(0, scroll_position - visible_lines)
    update_terminal_display()

func page_down():
    scroll_position = min(terminal_lines.size() - visible_lines, scroll_position + visible_lines)
    update_terminal_display()

func scroll_to_bottom():
    scroll_position = max(0, terminal_lines.size() - visible_lines)
    update_terminal_display()

func scroll_to_top():
    scroll_position = 0
    update_terminal_display()

# Input handling
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.scancode:
            KEY_PAGEUP:
                page_up()
            KEY_PAGEDOWN:
                page_down()
            KEY_UP:
                scroll_up()
            KEY_DOWN:
                scroll_down()
            KEY_HOME:
                scroll_to_top()
            KEY_END:
                scroll_to_bottom()

# Create an instance of the terminal scene
static func create_terminal_scene():
    var scene = Control.new()
    scene.rect_min_size = Vector2(600, 400)
    
    var bg = ColorRect.new()
    bg.name = "Background"
    bg.color = Color(0.1, 0.1, 0.1)
    bg.anchor_right = 1
    bg.anchor_bottom = 1
    scene.add_child(bg)
    
    var rich_text = RichTextLabel.new()
    rich_text.name = "RichTextLabel"
    rich_text.bbcode_enabled = true
    rich_text.anchor_right = 1
    rich_text.anchor_bottom = 1
    rich_text.margin_left = 10
    rich_text.margin_top = 10
    rich_text.margin_right = -10
    rich_text.margin_bottom = -10
    scene.add_child(rich_text)
    
    var timer = Timer.new()
    timer.name = "CycleTimer"
    timer.wait_time = 30.0
    timer.autostart = true
    scene.add_child(timer)
    
    return scene