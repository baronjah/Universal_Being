extends Node
class_name ApiSwitchExample

# ApiSwitchExample
# Demonstrates usage of the API Switch Manager with the Eden Garden System
# Shows how to implement API switching during offline mode and system restarts

# Core system references
var eden_garden_system = null
var api_switch_manager = null
var eden_api_integration = null

# UI elements (for demonstration purposes)
var api_status_label = null
var endpoint_selector = null
var offline_toggle = null
var add_endpoint_button = null
var restart_button = null

func _ready():
    # Initialize core components
    _initialize_systems()
    
    # Set up UI elements for this example
    _setup_ui()
    
    # Set up signal connections
    _connect_signals()
    
    print("API Switch Example initialized")

# System Initialization

func _initialize_systems():
    # Create the API Switch Manager
    api_switch_manager = ApiSwitchManager.new()
    add_child(api_switch_manager)
    
    # Create the Eden Garden System (or get reference to existing one)
    # For this example, we assume it's already created elsewhere
    eden_garden_system = get_node("/root/EdenGardenSystem")
    if not eden_garden_system:
        # Create a minimal version for the example
        eden_garden_system = Node.new()
        eden_garden_system.name = "EdenGardenSystem"
        eden_garden_system.set_script(load("res://eden_garden_system.gd"))
        get_tree().root.add_child(eden_garden_system)
    
    # Create the API Integration layer
    eden_api_integration = EdenApiIntegration.new()
    add_child(eden_api_integration)
    
    # Initialize the integration layer
    eden_api_integration.initialize(api_switch_manager, eden_garden_system)
    
    # Initial API setup
    _setup_default_endpoints()

func _setup_default_endpoints():
    # The ApiSwitchManager already sets up default endpoints in its _ready function,
    # but we'll add a custom one here for demonstration
    
    # Add a custom endpoint for our example
    eden_api_integration.create_custom_endpoint(
        "custom_example",
        "https://example-eden-api.com",
        "",
        {"Content-Type": "application/json"}
    )
    
    # List available endpoints
    var endpoints = eden_api_integration.get_available_endpoints()
    print("Available API endpoints: %d" % endpoints.size())
    for endpoint in endpoints:
        print(" - %s: %s (healthy: %s, priority: %d)" % 
              [endpoint.name, endpoint.url, str(endpoint.is_healthy), endpoint.priority])

# UI Setup (for demonstration purposes)

func _setup_ui():
    # This would normally be done through a scene, but we're doing it programmatically
    # for this example
    
    # Create a simple UI for demonstrating API switching
    var ui_container = VBoxContainer.new()
    ui_container.name = "ApiSwitchUI"
    ui_container.anchor_right = 1.0
    ui_container.anchor_bottom = 1.0
    ui_container.margin_left = 20
    ui_container.margin_top = 20
    ui_container.margin_right = -20
    ui_container.margin_bottom = -20
    add_child(ui_container)
    
    # Add title
    var title = Label.new()
    title.text = "API Switching Demo"
    title.align = Label.ALIGN_CENTER
    ui_container.add_child(title)
    
    # Add status label
    api_status_label = Label.new()
    api_status_label.text = "API Status: Connected to default"
    ui_container.add_child(api_status_label)
    
    # Add endpoint selector
    var selector_label = Label.new()
    selector_label.text = "Select API Endpoint:"
    ui_container.add_child(selector_label)
    
    endpoint_selector = OptionButton.new()
    ui_container.add_child(endpoint_selector)
    _populate_endpoint_selector()
    
    # Add offline toggle
    var offline_container = HBoxContainer.new()
    ui_container.add_child(offline_container)
    
    var offline_label = Label.new()
    offline_label.text = "Offline Mode:"
    offline_container.add_child(offline_label)
    
    offline_toggle = CheckButton.new()
    offline_container.add_child(offline_toggle)
    
    # Add endpoint creation UI
    var endpoint_container = HBoxContainer.new()
    ui_container.add_child(endpoint_container)
    
    var endpoint_label = Label.new()
    endpoint_label.text = "Add Custom Endpoint:"
    endpoint_container.add_child(endpoint_label)
    
    var endpoint_name = LineEdit.new()
    endpoint_name.name = "EndpointName"
    endpoint_name.placeholder_text = "Name"
    endpoint_container.add_child(endpoint_name)
    
    var endpoint_url = LineEdit.new()
    endpoint_url.name = "EndpointURL"
    endpoint_url.placeholder_text = "URL"
    endpoint_container.add_child(endpoint_url)
    
    add_endpoint_button = Button.new()
    add_endpoint_button.text = "Add"
    endpoint_container.add_child(add_endpoint_button)
    
    # Add restart button
    restart_button = Button.new()
    restart_button.text = "Simulate System Restart"
    ui_container.add_child(restart_button)
    
    # Add action log
    var log_label = Label.new()
    log_label.text = "Action Log:"
    ui_container.add_child(log_label)
    
    var log_box = TextEdit.new()
    log_box.name = "LogBox"
    log_box.rect_min_size = Vector2(0, 200)
    log_box.readonly = true
    ui_container.add_child(log_box)

func _populate_endpoint_selector():
    endpoint_selector.clear()
    
    var endpoints = eden_api_integration.get_available_endpoints()
    for i in range(endpoints.size()):
        var endpoint = endpoints[i]
        endpoint_selector.add_item(endpoint.name)
        endpoint_selector.set_item_metadata(i, endpoint.name)

# Signal Connections

func _connect_signals():
    # Connect UI signals
    endpoint_selector.connect("item_selected", self, "_on_endpoint_selected")
    offline_toggle.connect("toggled", self, "_on_offline_toggled")
    add_endpoint_button.connect("pressed", self, "_on_add_endpoint_pressed")
    restart_button.connect("pressed", self, "_on_restart_pressed")
    
    # Connect API Integration signals
    eden_api_integration.connect("api_status_changed", self, "_on_api_status_changed")
    eden_api_integration.connect("api_sync_completed", self, "_on_api_sync_completed")
    
    # Connect API Switch Manager signals
    api_switch_manager.connect("api_switched", self, "_on_api_switched")
    api_switch_manager.connect("connection_state_changed", self, "_on_connection_state_changed")

# Core API Switching Functionality

func switch_api_endpoint(endpoint_name):
    if eden_api_integration.switch_api_endpoint(endpoint_name):
        _log_action("Switched API endpoint to: " + endpoint_name)
        return true
    else:
        _log_action("Failed to switch API endpoint to: " + endpoint_name)
        return false

func toggle_offline_mode(offline):
    api_switch_manager.set_online_mode(not offline)
    _log_action("System is now " + ("offline" if offline else "online"))

func add_custom_endpoint(name, url):
    if eden_api_integration.create_custom_endpoint(name, url):
        _log_action("Added custom endpoint: " + name + " (" + url + ")")
        _populate_endpoint_selector()
        return true
    else:
        _log_action("Failed to add custom endpoint: " + name)
        return false

func simulate_restart():
    _log_action("Simulating system restart...")
    
    # Save the current state before "restart"
    api_switch_manager.save_persistent_data()
    
    # Remove the current nodes
    var current_endpoint = api_switch_manager.current_endpoint
    remove_child(api_switch_manager)
    api_switch_manager.queue_free()
    
    remove_child(eden_api_integration)
    eden_api_integration.queue_free()
    
    # Create new instances (simulating restart)
    api_switch_manager = ApiSwitchManager.new()
    add_child(api_switch_manager)
    
    eden_api_integration = EdenApiIntegration.new()
    add_child(eden_api_integration)
    
    # Reinitialize
    eden_api_integration.initialize(api_switch_manager, eden_garden_system)
    
    # Repopulate UI
    _populate_endpoint_selector()
    
    # Verify endpoint persistence
    if api_switch_manager.current_endpoint == current_endpoint:
        _log_action("Restart successful - restored endpoint: " + current_endpoint)
    else:
        _log_action("Restart completed but endpoint changed from " + current_endpoint + 
                   " to " + api_switch_manager.current_endpoint)
    
    # Reconnect signals
    _connect_signals()

# Helper Methods

func _log_action(message):
    print(message)
    var log_box = get_node("ApiSwitchUI/LogBox")
    if log_box:
        log_box.text += message + "\n"

# Signal Handlers

func _on_endpoint_selected(index):
    var endpoint_name = endpoint_selector.get_item_metadata(index)
    switch_api_endpoint(endpoint_name)

func _on_offline_toggled(toggled):
    toggle_offline_mode(toggled)

func _on_add_endpoint_pressed():
    var name_field = get_node("ApiSwitchUI/EndpointName")
    var url_field = get_node("ApiSwitchUI/EndpointURL")
    
    if name_field and url_field:
        var name = name_field.text.strip_edges()
        var url = url_field.text.strip_edges()
        
        if name.empty() or url.empty():
            _log_action("Error: Name and URL are required")
            return
        
        add_custom_endpoint(name, url)
        
        # Clear fields
        name_field.text = ""
        url_field.text = ""

func _on_restart_pressed():
    simulate_restart()

func _on_api_status_changed(status_code, message):
    api_status_label.text = "API Status: " + message
    _log_action("API status changed: " + message)

func _on_api_sync_completed(success):
    _log_action("API sync " + ("completed successfully" if success else "failed"))

func _on_api_switched(endpoint_name):
    _log_action("API endpoint switched to: " + endpoint_name)
    
    # Update the UI selector
    for i in range(endpoint_selector.get_item_count()):
        if endpoint_selector.get_item_metadata(i) == endpoint_name:
            endpoint_selector.select(i)
            break

func _on_connection_state_changed(is_online):
    offline_toggle.pressed = not is_online
    _log_action("Connection state changed to: " + ("online" if is_online else "offline"))

# Usage examples for integrating into Eden Garden System

func add_api_switch_support_to_eden_garden():
    """
    This method demonstrates how to integrate API switching into the 
    Eden Garden System. In a real implementation, this code would be
    placed within the Eden Garden System itself.
    """
    
    # 1. Make sure Eden Garden System has the required signals
    # signal system_went_offline
    # signal system_went_online
    # signal eden_restart_requested
    # signal garden_state_changed(new_state)
    # signal fruit_added(fruit_data)
    # signal echo_created(echo_data)
    
    # 2. Add API switch methods to Eden Garden System
    
    # Example method for switching API endpoints
    # func switch_api_endpoint(endpoint_name):
    #     if api_integration and api_integration.switch_api_endpoint(endpoint_name):
    #         return true
    #     return false
    
    # Example method for toggling offline mode
    # func set_offline_mode(offline):
    #     var previous_state = is_offline
    #     is_offline = offline
    #     
    #     if is_offline and not previous_state:
    #         emit_signal("system_went_offline")
    #     elif not is_offline and previous_state:
    #         emit_signal("system_went_online")
    
    # Example method for handing system restart
    # func request_restart():
    #     emit_signal("eden_restart_requested")
    #     # Save system state
    #     save_garden_state()
    #     
    #     # Additional restart logic
    #     # ...
    
    # 3. Add API endpoint method hooks
    
    # Example method for responding to API switch
    # func _on_api_switched(endpoint_name):
    #     current_api_endpoint = endpoint_name
    #     update_garden_interface()
    
    # Example method for handling connection state changes
    # func _on_connection_state_changed(is_online):
    #     update_garden_interface()
    #     if is_online:
    #         # Maybe refresh data from API
    #         refresh_garden_state_from_api()
    
    # The implementation is complete with the 3 files:
    # 1. api_switch_manager.gd - Core endpoint management
    # 2. eden_api_integration.gd - Integration layer
    # 3. This example showing how to use it
    
    pass