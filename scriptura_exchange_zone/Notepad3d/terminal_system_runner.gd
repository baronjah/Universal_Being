extends Node

class_name TerminalSystemRunner

# Components
var terminal_interface = null
var visual_bridge = null
var temperature_system = null
var ethereal_bridge = null
var akashic_bridge = null

# Node structure
var main_container = null
var terminal_container = null
var visualization_container = null

# Status flags
var system_initialized = false
var terminal_ready = false
var visualization_ready = false

# Signal for system events
signal system_initialized()
signal command_processed(command, result)
signal visualization_updated()

func _init():
    print("Terminal System Runner initializing...")
    _initialize_system()

func _initialize_system():
    # Create main container
    main_container = VBoxContainer.new()
    main_container.set_name("MainContainer")
    main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    
    # Create visualization container
    visualization_container = Control.new()
    visualization_container.set_name("VisualizationContainer")
    visualization_container.set_size(Vector2(800, 400))
    visualization_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
    visualization_container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
    
    # Create terminal container
    terminal_container = Control.new()
    terminal_container.set_name("TerminalContainer")
    terminal_container.set_custom_minimum_size(Vector2(800, 300))
    terminal_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
    
    # Add containers to main container
    main_container.add_child(visualization_container)
    main_container.add_child(terminal_container)
    
    # Initialize components
    _initialize_components()
    
    # Connect signals
    _connect_signals()
    
    system_initialized = true
    emit_signal("system_initialized")
    
    print("Terminal System Runner initialized successfully")

func _initialize_components():
    # Initialize each component and add to the correct container
    
    # Visual Bridge
    visual_bridge = load("/mnt/c/Users/Percision 15/terminal_visual_bridge.gd").new()
    visualization_container.add_child(visual_bridge)
    
    # Temperature System
    temperature_system = load("/mnt/c/Users/Percision 15/color_temperature_visualization.gd").new()
    visualization_container.add_child(temperature_system)
    
    # Terminal Interface
    terminal_interface = load("/mnt/c/Users/Percision 15/terminal_akashic_interface.gd").new()
    terminal_container.add_child(terminal_interface)
    
    # Ethereal Bridge - Create stub if real one not available
    if ClassDB.class_exists("EtherealEngineBridge"):
        ethereal_bridge = load("res://ethereal_engine_bridge.gd").new()
    else:
        # Create stub
        ethereal_bridge = Node.new()
        ethereal_bridge.name = "EtherealBridgeStub"
    add_child(ethereal_bridge)
    
    # Akashic Bridge - Create stub if real one not available
    if ClassDB.class_exists("AkashicNumberSystem"):
        akashic_bridge = load("res://akashic_bridge.gd").new()
    else:
        # Create stub
        akashic_bridge = Node.new()
        akashic_bridge.name = "AkashicBridgeStub"
    add_child(akashic_bridge)
    
    # Add visualization canvases to visualization container
    if visual_bridge.has_method("get_visualization_canvas"):
        var canvas = visual_bridge.get_visualization_canvas()
        if canvas:
            visualization_container.add_child(canvas)
    
    if temperature_system.has_method("get_visualization_canvas"):
        var canvas = temperature_system.get_visualization_canvas()
        if canvas:
            visualization_container.add_child(canvas)
    
    # Set visualization ready
    visualization_ready = true
    
    # Set terminal ready
    terminal_ready = true

func _connect_signals():
    # Connect Visual Bridge signals
    if visual_bridge and "color_temperature_changed" in visual_bridge:
        visual_bridge.color_temperature_changed.connect(
            Callable(self, "_on_visual_bridge_temperature_changed"))
    
    if visual_bridge and "universe_changed" in visual_bridge:
        visual_bridge.universe_changed.connect(
            Callable(self, "_on_visual_bridge_universe_changed"))
    
    if visual_bridge and "turn_completed" in visual_bridge:
        visual_bridge.turn_completed.connect(
            Callable(self, "_on_visual_bridge_turn_completed"))
    
    # Connect Temperature System signals
    if temperature_system and "temperature_changed" in temperature_system:
        temperature_system.temperature_changed.connect(
            Callable(self, "_on_temperature_system_temperature_changed"))
    
    if temperature_system and "frequency_resonance" in temperature_system:
        temperature_system.frequency_resonance.connect(
            Callable(self, "_on_temperature_system_frequency_resonance"))
    
    # Connect Terminal Interface signals
    if terminal_interface and "command_executed" in terminal_interface:
        terminal_interface.command_executed.connect(
            Callable(self, "_on_terminal_interface_command_executed"))
    
    if terminal_interface and "mode_changed" in terminal_interface:
        terminal_interface.mode_changed.connect(
            Callable(self, "_on_terminal_interface_mode_changed"))

func _process(delta):
    # Update components if needed
    if system_initialized:
        _update_visualization(delta)

func _update_visualization(delta):
    if visualization_ready:
        # Nothing specific to update here, as components handle their own updates
        emit_signal("visualization_updated")

func _on_visual_bridge_temperature_changed(temp_name, color, frequency):
    print("Visual Bridge temperature changed: " + temp_name)
    
    # Sync with Temperature System
    if temperature_system and temperature_system.has_method("set_temperature_by_name"):
        temperature_system.set_temperature_by_name(temp_name)
    
    # Display in terminal
    if terminal_interface and terminal_interface.has_method("display_output"):
        terminal_interface.display_output("Temperature changed to " + temp_name + " (" + str(frequency) + " Hz)")

func _on_visual_bridge_universe_changed(universe_name, center_color):
    print("Universe changed to: " + universe_name)
    
    # Display in terminal
    if terminal_interface and terminal_interface.has_method("display_output"):
        terminal_interface.display_output("Active universe: " + universe_name)

func _on_visual_bridge_turn_completed(turn_number, total_turns):
    print("Turn completed: " + str(turn_number) + "/" + str(total_turns))
    
    # Display in terminal
    if terminal_interface and terminal_interface.has_method("display_output"):
        terminal_interface.display_output("Turn " + str(turn_number) + " completed")

func _on_temperature_system_temperature_changed(temp_value, temp_name, color, frequency):
    print("Temperature System temperature changed: " + str(temp_value) + "°C (" + temp_name + ")")
    
    # Sync with Visual Bridge
    if visual_bridge and visual_bridge.has_method("set_temperature"):
        visual_bridge.set_temperature(temp_name)
    
    # Display in terminal
    if terminal_interface and terminal_interface.has_method("display_output"):
        terminal_interface.display_output("Temperature changed to " + str(temp_value) + "°C (" + temp_name + ")")

func _on_temperature_system_frequency_resonance(frequency, amplitude, resonance_type):
    print("Frequency resonance: " + resonance_type + " at " + str(frequency) + " Hz")
    
    # Display in terminal
    if terminal_interface and terminal_interface.has_method("display_output"):
        terminal_interface.display_output("Frequency resonance: " + resonance_type + " at " + str(frequency) + " Hz (amplitude: " + str(amplitude) + ")")

func _on_terminal_interface_command_executed(command, result):
    print("Terminal command executed: " + command)
    
    # Process command result
    emit_signal("command_processed", command, result)

func _on_terminal_interface_mode_changed(mode):
    print("Terminal mode changed to: " + mode)

func process_terminal_command(command):
    if terminal_interface and terminal_interface.has_method("process_input"):
        return terminal_interface.process_input(command)
    
    return null

func get_main_container():
    return main_container

func is_system_ready():
    return system_initialized and terminal_ready and visualization_ready

# External API
func set_temperature(temp_name):
    if temperature_system and temperature_system.has_method("set_temperature_by_name"):
        return temperature_system.set_temperature_by_name(temp_name)
    elif visual_bridge and visual_bridge.has_method("set_temperature"):
        return visual_bridge.set_temperature(temp_name)
    
    return false

func set_universe(universe_name):
    if visual_bridge and visual_bridge.has_method("change_universe"):
        return visual_bridge.change_universe(universe_name)
    
    return false

func complete_turn():
    if visual_bridge and visual_bridge.has_method("complete_turn"):
        return visual_bridge.complete_turn()
    
    return false

func process_words(words_text):
    if ethereal_bridge and ethereal_bridge.has_method("process_words"):
        return ethereal_bridge.process_words(words_text)
    elif visual_bridge and visual_bridge.has_method("connect_to_ethereal_words"):
        var words_data = {
            "text": words_text,
            "source": "external",
            "timestamp": OS.get_ticks_msec()
        }
        
        return visual_bridge.connect_to_ethereal_words(words_data)
    
    return null

func generate_cosmic_address():
    if terminal_interface and terminal_interface.has_method("_generate_cosmic_address"):
        return terminal_interface._generate_cosmic_address()
    elif visual_bridge and visual_bridge.has_method("generate_cosmic_address"):
        return visual_bridge.generate_cosmic_address()
    
    return null

# Run a terminal command and display the result
func run_command(command_text):
    if terminal_interface and terminal_interface.has_method("process_input"):
        var result = terminal_interface.process_input(command_text)
        print("Command result: " + str(result))
        return result
    
    return null

# Main entry point
func run():
    print("Running Terminal System...")
    
    # Nothing specific to run, as system initializes in _init
    
    if is_system_ready():
        print("Terminal System ready!")
        return true
    else:
        print("Terminal System not ready!")
        return false