extends Control

class_name TunnelUI

# References
var tunnel_controller
var ethereal_tunnel_manager

# UI Elements
var energy_bar
var dimension_indicator
var turn_indicator
var message_log
var transfer_progress

# Color constants
const COLOR_INFO = Color(0.0, 0.7, 1.0)
const COLOR_SUCCESS = Color(0.0, 0.9, 0.3)
const COLOR_WARNING = Color(0.9, 0.9, 0.0)
const COLOR_ERROR = Color(0.9, 0.2, 0.2)

# UI Theme
var compact_theme = {
    "background_color": Color(0.12, 0.12, 0.18, 0.7),
    "panel_color": Color(0.18, 0.18, 0.24, 0.8),
    "border_color": Color(0.3, 0.3, 0.4, 0.9),
    "text_color": Color(0.9, 0.9, 0.95),
    "highlight_color": Color(0.0, 0.7, 1.0),
    "corner_radius": 4,
    "border_width": 1,
    "padding": 8
}

func _ready():
    # Create UI elements
    _setup_ui()
    
    # Connect signals
    _connect_signals()
    
    # Auto-detect components if in scene tree
    if not tunnel_controller:
        var potential_controllers = get_tree().get_nodes_in_group("tunnel_controllers")
        if potential_controllers.size() > 0:
            tunnel_controller = potential_controllers[0]
            print("Automatically found tunnel controller: " + tunnel_controller.name)
    
    if not ethereal_tunnel_manager and tunnel_controller:
        ethereal_tunnel_manager = tunnel_controller.ethereal_tunnel_manager
    
    # Initial update
    _update_energy_display()
    _update_dimension_display()
    _update_turn_display()

func _setup_ui():
    # Base panel
    var panel = Panel.new()
    panel.anchor_right = 1.0
    panel.anchor_bottom = 0.15
    panel.size_flags_horizontal = SIZE_EXPAND_FILL
    add_child(panel)
    
    # Create a theme
    var theme = Theme.new()
    panel.theme = theme
    
    # Create a StyleBox for the panel
    var style_box = StyleBoxFlat.new()
    style_box.bg_color = compact_theme.background_color
    style_box.border_color = compact_theme.border_color
    style_box.border_width_top = compact_theme.border_width
    style_box.border_width_bottom = compact_theme.border_width
    style_box.border_width_left = compact_theme.border_width
    style_box.border_width_right = compact_theme.border_width
    style_box.corner_radius_top_left = compact_theme.corner_radius
    style_box.corner_radius_top_right = compact_theme.corner_radius
    style_box.corner_radius_bottom_left = compact_theme.corner_radius
    style_box.corner_radius_bottom_right = compact_theme.corner_radius
    
    # Apply the style to the panel
    theme.set_stylebox("panel", "Panel", style_box)
    
    # Create HBoxContainer for layout
    var hbox = HBoxContainer.new()
    hbox.anchor_right = 1.0
    hbox.anchor_bottom = 1.0
    hbox.margin_left = compact_theme.padding
    hbox.margin_right = -compact_theme.padding
    hbox.margin_top = compact_theme.padding
    hbox.margin_bottom = -compact_theme.padding
    panel.add_child(hbox)
    
    # Energy Section
    var energy_section = VBoxContainer.new()
    energy_section.size_flags_horizontal = SIZE_EXPAND_FILL
    energy_section.size_flags_stretch_ratio = 1.0
    hbox.add_child(energy_section)
    
    var energy_label = Label.new()
    energy_label.text = "Energy"
    energy_label.theme.set_color("font_color", "Label", compact_theme.text_color)
    energy_section.add_child(energy_label)
    
    energy_bar = ProgressBar.new()
    energy_bar.size_flags_horizontal = SIZE_EXPAND_FILL
    energy_bar.size_flags_vertical = SIZE_FILL
    energy_bar.min_value = 0
    energy_bar.max_value = 100
    energy_bar.value = 100
    energy_section.add_child(energy_bar)
    
    # Dimension Section
    var dimension_section = VBoxContainer.new()
    dimension_section.size_flags_horizontal = SIZE_EXPAND_FILL
    dimension_section.size_flags_stretch_ratio = 1.0
    hbox.add_child(dimension_section)
    
    var dimension_label = Label.new()
    dimension_label.text = "Dimension"
    dimension_label.theme.set_color("font_color", "Label", compact_theme.text_color)
    dimension_section.add_child(dimension_label)
    
    dimension_indicator = Label.new()
    dimension_indicator.text = "3"
    dimension_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    dimension_indicator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    dimension_indicator.theme.set_color("font_color", "Label", compact_theme.highlight_color)
    dimension_section.add_child(dimension_indicator)
    
    # Turn Section
    var turn_section = VBoxContainer.new()
    turn_section.size_flags_horizontal = SIZE_EXPAND_FILL
    turn_section.size_flags_stretch_ratio = 1.0
    hbox.add_child(turn_section)
    
    var turn_label = Label.new()
    turn_label.text = "Turn"
    turn_label.theme.set_color("font_color", "Label", compact_theme.text_color)
    turn_section.add_child(turn_label)
    
    turn_indicator = Label.new()
    turn_indicator.text = "0: Origin"
    turn_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    turn_indicator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    turn_indicator.theme.set_color("font_color", "Label", compact_theme.text_color)
    turn_section.add_child(turn_indicator)
    
    # Transfer Section
    var transfer_section = VBoxContainer.new()
    transfer_section.size_flags_horizontal = SIZE_EXPAND_FILL
    transfer_section.size_flags_stretch_ratio = 1.5
    hbox.add_child(transfer_section)
    
    var transfer_label = Label.new()
    transfer_label.text = "Transfer"
    transfer_label.theme.set_color("font_color", "Label", compact_theme.text_color)
    transfer_section.add_child(transfer_label)
    
    transfer_progress = ProgressBar.new()
    transfer_progress.size_flags_horizontal = SIZE_EXPAND_FILL
    transfer_progress.size_flags_vertical = SIZE_FILL
    transfer_progress.min_value = 0
    transfer_progress.max_value = 100
    transfer_progress.value = 0
    transfer_section.add_child(transfer_progress)
    
    # Message Section
    var message_section = VBoxContainer.new()
    message_section.size_flags_horizontal = SIZE_EXPAND_FILL
    message_section.size_flags_stretch_ratio = 3.0
    hbox.add_child(message_section)
    
    var message_label = Label.new()
    message_label.text = "Status"
    message_label.theme.set_color("font_color", "Label", compact_theme.text_color)
    message_section.add_child(message_label)
    
    message_log = RichTextLabel.new()
    message_log.theme.set_color("default_color", "RichTextLabel", compact_theme.text_color)
    message_log.bbcode_enabled = true
    message_log.fit_content = true
    message_log.scroll_following = true
    message_log.size_flags_horizontal = SIZE_EXPAND_FILL
    message_log.size_flags_vertical = SIZE_FILL
    message_section.add_child(message_log)
    
    # Add controls for tunnel and dimension management
    var controls_button = Button.new()
    controls_button.text = "Controls"
    controls_button.size_flags_vertical = SIZE_SHRINK_CENTER
    controls_button.connect("pressed", self, "_on_controls_button_pressed")
    hbox.add_child(controls_button)

func _connect_signals():
    if tunnel_controller:
        tunnel_controller.connect("connection_status_changed", self, "_on_connection_status_changed")
        tunnel_controller.connect("tunnel_transfer_completed", self, "_on_tunnel_transfer_completed")

func set_controller(controller):
    tunnel_controller = controller
    
    if tunnel_controller:
        ethereal_tunnel_manager = tunnel_controller.ethereal_tunnel_manager
        _connect_signals()
        
        # Update displays
        _update_energy_display()
        _update_dimension_display()
        _update_turn_display()

func _update_energy_display():
    if not tunnel_controller:
        return
    
    var energy_status = tunnel_controller.get_energy_status()
    energy_bar.value = energy_status.percentage
    
    # Change color based on energy level
    if energy_status.percentage < 20:
        energy_bar.theme.set_color("theme.font_color", "ProgressBar", COLOR_ERROR)
    elif energy_status.percentage < 40:
        energy_bar.theme.set_color("theme.font_color", "ProgressBar", COLOR_WARNING)
    else:
        energy_bar.theme.set_color("theme.font_color", "ProgressBar", COLOR_SUCCESS)

func _update_dimension_display():
    if not tunnel_controller:
        return
    
    var dimension_info = tunnel_controller.get_current_dimension()
    dimension_indicator.text = str(dimension_info.dimension)
    dimension_indicator.theme.set_color("font_color", "Label", dimension_info.color)

func _update_turn_display():
    if not tunnel_controller:
        return
    
    var turn_info = tunnel_controller.get_current_turn_info()
    turn_indicator.text = str(turn_info.turn) + ": " + turn_info.name

func _update_transfer_display():
    if not tunnel_controller:
        return
    
    var transfer_info = tunnel_controller.get_active_transfer_progress()
    
    if transfer_info:
        transfer_progress.value = transfer_info.progress
    else:
        transfer_progress.value = 0

func _on_connection_status_changed(status, message):
    var color_code = ""
    
    # Set color based on status
    match status:
        "success":
            color_code = "[color=#00FF44]"
        "info":
            color_code = "[color=#00AAFF]"
        "warning":
            color_code = "[color=#FFFF00]"
        "error":
            color_code = "[color=#FF4444]"
    
    # Add timestamp
    var datetime = Time.get_datetime_dict_from_system()
    var timestamp = "%02d:%02d:%02d" % [datetime.hour, datetime.minute, datetime.second]
    
    # Add message to log
    message_log.bbcode_text += "\n" + color_code + "[" + timestamp + "] " + message + "[/color]"

func _on_tunnel_transfer_completed(tunnel_id, content):
    _on_connection_status_changed("success", "Transfer completed on tunnel " + tunnel_id)
    
    # Could add more details about the transfer here
    if content.length < 50:
        _on_connection_status_changed("info", "Transferred: " + content)
    else:
        _on_connection_status_changed("info", "Transferred: " + content.substr(0, 47) + "...")

func _process(delta):
    # Update UI elements
    if is_instance_valid(tunnel_controller):
        if Engine.get_idle_frames() % 5 == 0:  # Update every 5 frames for performance
            _update_energy_display()
            _update_transfer_display()
        
        if Engine.get_idle_frames() % 30 == 0:  # Less frequent updates
            _update_dimension_display()
            _update_turn_display()

func advance_turn():
    if tunnel_controller:
        var turn_info = tunnel_controller.advance_turn()
        _update_turn_display()
        _on_connection_status_changed("info", "Advanced to Turn " + str(turn_info.turn) + ": " + turn_info.name)
        return turn_info
    return null

func shift_dimension(dimension):
    if tunnel_controller:
        var result = tunnel_controller.shift_dimension(dimension)
        if result:
            _update_dimension_display()
        return result
    return false

func _on_controls_button_pressed():
    # Create popup dialog with controls
    var popup = PopupPanel.new()
    popup.rect_min_size = Vector2(300, 400)
    
    # Apply theme
    var style_box = StyleBoxFlat.new()
    style_box.bg_color = compact_theme.panel_color
    style_box.border_color = compact_theme.border_color
    style_box.border_width_top = compact_theme.border_width
    style_box.border_width_bottom = compact_theme.border_width
    style_box.border_width_left = compact_theme.border_width
    style_box.border_width_right = compact_theme.border_width
    style_box.corner_radius_top_left = compact_theme.corner_radius
    style_box.corner_radius_top_right = compact_theme.corner_radius
    style_box.corner_radius_bottom_left = compact_theme.corner_radius
    style_box.corner_radius_bottom_right = compact_theme.corner_radius
    
    popup.add_theme_stylebox_override("panel", style_box)
    
    # Create VBox for content
    var vbox = VBoxContainer.new()
    vbox.anchor_right = 1.0
    vbox.anchor_bottom = 1.0
    vbox.margin_left = compact_theme.padding
    vbox.margin_right = -compact_theme.padding
    vbox.margin_top = compact_theme.padding
    vbox.margin_bottom = -compact_theme.padding
    popup.add_child(vbox)
    
    # Title
    var title = Label.new()
    title.text = "Tunnel Controls"
    title.theme.set_color("font_color", "Label", compact_theme.highlight_color)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(title)
    
    # Separator
    var separator = HSeparator.new()
    vbox.add_child(separator)
    
    # Turn controls
    var turn_controls = HBoxContainer.new()
    var turn_label = Label.new()
    turn_label.text = "Turn:"
    turn_label.theme.set_color("font_color", "Label", compact_theme.text_color)
    turn_controls.add_child(turn_label)
    
    var advance_turn_button = Button.new()
    advance_turn_button.text = "Advance Turn"
    advance_turn_button.connect("pressed", self, "advance_turn")
    advance_turn_button.size_flags_horizontal = SIZE_EXPAND_FILL
    turn_controls.add_child(advance_turn_button)
    
    vbox.add_child(turn_controls)
    
    # Dimension controls
    var dimension_controls = HBoxContainer.new()
    var dimension_label = Label.new()
    dimension_label.text = "Dimension:"
    dimension_label.theme.set_color("font_color", "Label", compact_theme.text_color)
    dimension_controls.add_child(dimension_label)
    
    var dimension_value = SpinBox.new()
    dimension_value.min_value = 1
    dimension_value.max_value = 9
    dimension_value.value = tunnel_controller.get_current_dimension().dimension if tunnel_controller else 3
    dimension_value.size_flags_horizontal = SIZE_EXPAND_FILL
    dimension_controls.add_child(dimension_value)
    
    var shift_button = Button.new()
    shift_button.text = "Shift"
    shift_button.connect("pressed", self, "_on_shift_button_pressed", [dimension_value])
    dimension_controls.add_child(shift_button)
    
    vbox.add_child(dimension_controls)
    
    # Tunnel management
    var tunnel_management = VBoxContainer.new()
    var tunnel_label = Label.new()
    tunnel_label.text = "Tunnel Management"
    tunnel_label.theme.set_color("font_color", "Label", compact_theme.highlight_color)
    tunnel_management.add_child(tunnel_label)
    
    # Existing tunnels
    var tunnels_label = Label.new()
    tunnels_label.text = "Existing Tunnels:"
    tunnels_label.theme.set_color("font_color", "Label", compact_theme.text_color)
    tunnel_management.add_child(tunnels_label)
    
    var tunnels_list = ItemList.new()
    tunnels_list.theme.set_color("font_color", "ItemList", compact_theme.text_color)
    tunnels_list.theme.set_color("font_color_selected", "ItemList", compact_theme.highlight_color)
    tunnels_list.size_flags_vertical = SIZE_EXPAND_FILL
    tunnels_list.auto_height = true
    
    # Populate list
    if ethereal_tunnel_manager:
        for tunnel_id in ethereal_tunnel_manager.get_tunnels():
            var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
            tunnels_list.add_item(tunnel_id + " (Dim: " + str(tunnel_data.dimension) + ", Stab: " + str(tunnel_data.stability).substr(0, 4) + ")")
    
    tunnel_management.add_child(tunnels_list)
    
    # Button to collapse selected tunnel
    var collapse_button = Button.new()
    collapse_button.text = "Collapse Selected Tunnel"
    collapse_button.connect("pressed", self, "_on_collapse_button_pressed", [tunnels_list])
    tunnel_management.add_child(collapse_button)
    
    vbox.add_child(tunnel_management)
    
    # Create a new tunnel section
    var new_tunnel = VBoxContainer.new()
    var new_tunnel_label = Label.new()
    new_tunnel_label.text = "Create New Tunnel"
    new_tunnel_label.theme.set_color("font_color", "Label", compact_theme.highlight_color)
    new_tunnel.add_child(new_tunnel_label)
    
    # Source and target selectors
    var source_hbox = HBoxContainer.new()
    var source_label = Label.new()
    source_label.text = "Source:"
    source_label.theme.set_color("font_color", "Label", compact_theme.text_color)
    source_hbox.add_child(source_label)
    
    var source_option = OptionButton.new()
    source_option.size_flags_horizontal = SIZE_EXPAND_FILL
    source_hbox.add_child(source_option)
    
    new_tunnel.add_child(source_hbox)
    
    var target_hbox = HBoxContainer.new()
    var target_label = Label.new()
    target_label.text = "Target:"
    target_label.theme.set_color("font_color", "Label", compact_theme.text_color)
    target_hbox.add_child(target_label)
    
    var target_option = OptionButton.new()
    target_option.size_flags_horizontal = SIZE_EXPAND_FILL
    target_hbox.add_child(target_option)
    
    new_tunnel.add_child(target_hbox)
    
    # Populate anchor options
    if ethereal_tunnel_manager:
        for anchor_id in ethereal_tunnel_manager.get_anchors():
            source_option.add_item(anchor_id)
            target_option.add_item(anchor_id)
    
    // Create tunnel button
    var create_button = Button.new()
    create_button.text = "Establish Tunnel"
    create_button.connect("pressed", self, "_on_create_button_pressed", [source_option, target_option])
    new_tunnel.add_child(create_button)
    
    vbox.add_child(new_tunnel)
    
    // Close button
    var close_button = Button.new()
    close_button.text = "Close"
    close_button.connect("pressed", popup, "hide")
    vbox.add_child(close_button)
    
    // Add to scene and show
    add_child(popup)
    popup.popup_centered()

func _on_shift_button_pressed(dimension_value):
    shift_dimension(int(dimension_value.value))

func _on_collapse_button_pressed(tunnels_list):
    var selected_idx = tunnels_list.get_selected_items()
    if selected_idx.size() > 0:
        var text = tunnels_list.get_item_text(selected_idx[0])
        var tunnel_id = text.split(" ")[0]  // Extract tunnel ID from display text
        
        if tunnel_controller:
            tunnel_controller.collapse_tunnel(tunnel_id)
            
            // Update the list
            tunnels_list.remove_item(selected_idx[0])

func _on_create_button_pressed(source_option, target_option):
    var source_id = source_option.get_item_text(source_option.selected)
    var target_id = target_option.get_item_text(target_option.selected)
    
    if source_id == target_id:
        _on_connection_status_changed("error", "Source and target cannot be the same")
        return
    
    if tunnel_controller:
        tunnel_controller.establish_tunnel(source_id, target_id)