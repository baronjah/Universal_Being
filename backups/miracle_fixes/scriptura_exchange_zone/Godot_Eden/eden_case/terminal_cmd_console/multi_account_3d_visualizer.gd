extends Node3D

class_name MultiAccount3DVisualizer

"""
Multi-Account 3D Visualizer
Creates a 3D representation of multiple accounts with interconnected API windows
Each account has its own color scheme, thread pool, and dimensional view
"""

# Account visualization settings
const ACCOUNT_COLORS = {
    "free": Color(0.3, 0.7, 0.9, 0.9),    # Blue
    "plus": Color(0.3, 0.8, 0.3, 0.9),    # Green
    "max": Color(0.8, 0.3, 0.8, 0.9),     # Purple
    "enterprise": Color(0.9, 0.8, 0.2, 0.9)  # Gold
}

# Window types and visual properties
enum WindowType {
    TERMINAL,
    API,
    DATABASE,
    VISUALIZER,
    DEBUG,
    COMMAND,
    CUSTOM
}

# Account references
var account_manager = null
var thread_processor = null

# Tracked objects
var account_nodes = {}
var account_windows = {}
var connections = []
var api_connections = {}

# Materials
var window_material = null
var terminal_material = null
var connection_material = null

# Signal for interaction
signal window_selected(account_id, window_id)
signal account_activated(account_id)
signal api_connected(from_account, to_account, api_type)

func _ready():
    # Create materials
    _create_materials()
    
    # Connect to account manager if available
    _connect_to_systems()
    
    # Setup update timer
    var timer = Timer.new()
    timer.wait_time = 0.5
    timer.autostart = true
    timer.timeout.connect(_update_visualization)
    add_child(timer)
    
    # Initial setup
    _create_default_accounts()
    _update_visualization()

func _connect_to_systems():
    # Connect to MultiAccountManager
    if has_node("/root/MultiAccountManager") or get_node_or_null("/root/MultiAccountManager"):
        account_manager = get_node("/root/MultiAccountManager")
        print("Connected to MultiAccountManager")
    
    # Connect to MultiThreadedProcessor
    if has_node("/root/MultiThreadedProcessor") or get_node_or_null("/root/MultiThreadedProcessor"):
        thread_processor = get_node("/root/MultiThreadedProcessor")
        print("Connected to MultiThreadedProcessor")

func _create_materials():
    # Create window material
    window_material = StandardMaterial3D.new()
    window_material.flags_transparent = true
    window_material.albedo_color = Color(0.8, 0.8, 0.8, 0.7)
    window_material.emission_enabled = true
    window_material.emission = Color(0.8, 0.8, 0.8)
    window_material.emission_energy = 0.5
    
    # Create terminal material
    terminal_material = StandardMaterial3D.new()
    terminal_material.flags_transparent = true
    terminal_material.albedo_color = Color(0.1, 0.1, 0.1, 0.9)
    terminal_material.emission_enabled = true
    terminal_material.emission = Color(0.3, 0.7, 0.3)
    terminal_material.emission_energy = 0.3
    
    # Create connection material
    connection_material = StandardMaterial3D.new()
    connection_material.flags_transparent = true
    connection_material.albedo_color = Color(0.7, 0.8, 1.0, 0.3)
    connection_material.emission_enabled = true
    connection_material.emission = Color(0.7, 0.8, 1.0)
    connection_material.emission_energy = 0.3

func _create_default_accounts():
    # Create at least one account if we don't have access to account manager
    if not account_manager:
        _create_account_node("default_account", "Default Account", "free")
        _add_windows_to_account("default_account", 3)

func create_account(account_id, display_name, tier="free"):
    """
    Create a visual representation of an account
    """
    # Create account node if it doesn't exist
    if not account_id in account_nodes:
        _create_account_node(account_id, display_name, tier)
        
        # Add default windows
        var window_count = 1
        match tier:
            "free": window_count = 1
            "plus": window_count = 3
            "max": window_count = 6
            "enterprise": window_count = 12
            
        _add_windows_to_account(account_id, window_count)
        
        return true
    
    return false

func _create_account_node(account_id, display_name, tier):
    # Create base node for account
    var account_node = Node3D.new()
    account_node.name = "Account_" + account_id
    add_child(account_node)
    
    # Position account based on how many we already have
    var account_count = account_nodes.size()
    var angle = account_count * (2 * PI / 4)  # Distribute in a circle
    var distance = 5.0
    
    account_node.position = Vector3(
        cos(angle) * distance,
        0,
        sin(angle) * distance
    )
    
    # Add visual representation
    var center_mesh = SphereMesh.new()
    center_mesh.radius = 0.5
    center_mesh.height = 1.0
    
    var center = MeshInstance3D.new()
    center.mesh = center_mesh
    account_node.add_child(center)
    
    # Create material for account based on tier
    var account_material = StandardMaterial3D.new()
    account_material.flags_transparent = true
    
    var color = ACCOUNT_COLORS.get(tier, Color(0.8, 0.8, 0.8))
    account_material.albedo_color = color
    account_material.emission_enabled = true
    account_material.emission = color
    account_material.emission_energy = 0.7
    
    center.material_override = account_material
    
    # Add label with name
    var label = Label3D.new()
    label.text = display_name
    label.font_size = 12
    label.pixel_size = 0.01
    label.no_depth_test = true
    label.position.y = 0.8
    account_node.add_child(label)
    
    # Initialize windows container
    account_windows[account_id] = []
    
    # Store node
    account_nodes[account_id] = {
        "node": account_node,
        "tier": tier,
        "display_name": display_name,
        "color": color,
        "windows": 0
    }

func _add_windows_to_account(account_id, count=3):
    if not account_id in account_nodes:
        return
    
    var account_data = account_nodes[account_id]
    var account_node = account_data.node
    
    # Create windows around the account node
    for i in range(count):
        var window_type = _get_random_window_type()
        var window_id = account_id + "_window_" + str(account_data.windows)
        
        # Create window
        var window_node = _create_window_node(window_id, window_type, account_data.color)
        account_node.add_child(window_node)
        
        # Position window around account
        var angle = i * (2 * PI / count)
        var window_distance = 2.0
        
        window_node.position = Vector3(
            cos(angle) * window_distance,
            sin(angle * 0.5) * 0.5,  # Slight vertical variation
            sin(angle) * window_distance
        )
        
        # Store window reference
        account_windows[account_id].append({
            "id": window_id,
            "node": window_node,
            "type": window_type,
            "content": "",
            "connected_apis": []
        })
        
        # Increment window count
        account_data.windows += 1

func _get_random_window_type():
    var types = WindowType.values()
    return types[randi() % types.size()]

func _create_window_node(window_id, window_type, account_color):
    # Create window node
    var window_node = Node3D.new()
    window_node.name = "Window_" + window_id
    
    # Create window mesh
    var window_mesh = BoxMesh.new()
    window_mesh.size = Vector3(1.0, 0.7, 0.1)
    
    var window_instance = MeshInstance3D.new()
    window_instance.mesh = window_mesh
    window_node.add_child(window_instance)
    
    # Material based on window type
    var material = window_material.duplicate()
    
    match window_type:
        WindowType.TERMINAL:
            material.albedo_color = Color(0.1, 0.1, 0.1, 0.9)
            material.emission = Color(0.3, 0.7, 0.3)
        WindowType.API:
            material.albedo_color = Color(0.1, 0.1, 0.3, 0.9)
            material.emission = Color(0.3, 0.3, 0.8)
        WindowType.DATABASE:
            material.albedo_color = Color(0.3, 0.1, 0.1, 0.9)
            material.emission = Color(0.8, 0.3, 0.3)
        WindowType.VISUALIZER:
            material.albedo_color = Color(0.2, 0.2, 0.3, 0.9)
            material.emission = Color(0.5, 0.5, 0.8)
        WindowType.DEBUG:
            material.albedo_color = Color(0.3, 0.1, 0.3, 0.9)
            material.emission = Color(0.8, 0.3, 0.8)
        WindowType.COMMAND:
            material.albedo_color = Color(0.1, 0.3, 0.1, 0.9)
            material.emission = Color(0.3, 0.8, 0.3)
        WindowType.CUSTOM:
            material.albedo_color = account_color
            material.albedo_color.a = 0.9
            material.emission = account_color
    
    # Add account color influence
    material.emission = material.emission.lerp(account_color, 0.3)
    window_instance.material_override = material
    
    # Add window label
    var label = Label3D.new()
    label.text = WindowType.keys()[window_type]
    label.font_size = 10
    label.pixel_size = 0.01
    label.no_depth_test = true
    label.position.y = 0.4
    window_node.add_child(label)
    
    # Make clickable - would need to implement _on_input_event in a real project
    var area = Area3D.new()
    var collision = CollisionShape3D.new()
    var box_shape = BoxShape3D.new()
    box_shape.size = Vector3(1.0, 0.7, 0.2)
    collision.shape = box_shape
    area.add_child(collision)
    window_node.add_child(area)
    
    # Connect signals in a real implementation
    # area.input_event.connect(_on_window_input_event.bind(window_id))
    
    return window_node

func connect_api_windows(from_account, to_account, from_window_index=0, to_window_index=0):
    """
    Create a connection between API windows of different accounts
    """
    # Validate accounts and windows
    if not from_account in account_windows or not to_account in account_windows:
        return false
    
    if from_window_index >= account_windows[from_account].size() or to_window_index >= account_windows[to_account].size():
        return false
    
    # Get window data
    var from_window = account_windows[from_account][from_window_index]
    var to_window = account_windows[to_account][to_window_index]
    
    # Create connection key
    var connection_id = from_account + "_" + to_account + "_" + str(from_window_index) + "_" + str(to_window_index)
    
    # Check if connection already exists
    if connection_id in api_connections:
        return false
    
    # Create visual connection
    var from_pos = from_window.node.global_position
    var to_pos = to_window.node.global_position
    
    var connection_line = _create_connection_line(from_pos, to_pos)
    add_child(connection_line)
    
    # Store connection
    api_connections[connection_id] = {
        "from_account": from_account,
        "to_account": to_account, 
        "from_window": from_window_index,
        "to_window": to_window_index,
        "line": connection_line
    }
    
    # Register connection in window data
    from_window.connected_apis.append(to_account)
    to_window.connected_apis.append(from_account)
    
    # Emit signal
    emit_signal("api_connected", from_account, to_account, "standard")
    
    return true

func _create_connection_line(from_pos, to_pos):
    # Create visual line for connection
    var immediate = ImmediateMesh.new()
    var line_node = MeshInstance3D.new()
    line_node.mesh = immediate
    
    # Draw line
    immediate.clear_surfaces()
    immediate.surface_begin(Mesh.PRIMITIVE_LINES)
    immediate.surface_add_vertex(from_pos)
    immediate.surface_add_vertex(to_pos)
    immediate.surface_end()
    
    # Set material
    line_node.material_override = connection_material.duplicate()
    
    return line_node

func _update_visualization():
    # If we have account manager, update from real accounts
    if account_manager:
        _update_from_account_manager()
    
    # Update existing visualizations
    _update_window_states()
    _update_connections()
    
    # Add subtle movement
    _add_animation_effects()

func _update_from_account_manager():
    # In a real implementation, this would read from the account manager
    # and update visualizations based on actual account data
    pass

func _update_window_states():
    # Update window visual states based on thread usage, API activity, etc.
    for account_id in account_windows:
        for window_data in account_windows[account_id]:
            var window_node = window_data.node
            
            # Skip if node isn't valid
            if not is_instance_valid(window_node):
                continue
            
            # Simulate activity by pulsing
            if randf() < 0.3:  # 30% chance of activity
                var window_mesh = window_node.get_node_or_null("MeshInstance3D")
                if window_mesh and window_mesh.material_override:
                    var material = window_mesh.material_override
                    material.emission_energy = 0.5 + randf() * 0.5

func _update_connections():
    # Update connection lines for all connected windows
    for connection_id in api_connections:
        var connection = api_connections[connection_id]
        var line = connection.line
        
        if is_instance_valid(line) and line.mesh is ImmediateMesh:
            var from_account = connection.from_account
            var to_account = connection.to_account
            var from_window_idx = connection.from_window
            var to_window_idx = connection.to_window
            
            # Verify windows still exist
            if from_account in account_windows and to_account in account_windows:
                if from_window_idx < account_windows[from_account].size() and to_window_idx < account_windows[to_account].size():
                    var from_window = account_windows[from_account][from_window_idx]
                    var to_window = account_windows[to_account][to_window_idx]
                    
                    if is_instance_valid(from_window.node) and is_instance_valid(to_window.node):
                        # Update line vertices to follow window positions
                        var from_pos = from_window.node.global_position
                        var to_pos = to_window.node.global_position
                        
                        var immediate = line.mesh as ImmediateMesh
                        immediate.clear_surfaces()
                        immediate.surface_begin(Mesh.PRIMITIVE_LINES)
                        immediate.surface_add_vertex(from_pos)
                        immediate.surface_add_vertex(to_pos)
                        immediate.surface_end()
                        
                        # Simulate data activity
                        if randf() < 0.1:  # 10% chance of data transfer
                            var material = line.material_override
                            material.emission_energy = 0.3 + randf() * 0.7

func _add_animation_effects():
    # Add subtle movements to all account nodes
    var time = Time.get_ticks_msec() / 1000.0
    
    for account_id in account_nodes:
        var account_data = account_nodes[account_id]
        var account_node = account_data.node
        
        if is_instance_valid(account_node):
            # Subtle bobbing motion
            account_node.position.y = sin(time * 0.5 + hash(account_id)) * 0.1
            
            # Subtle rotation
            account_node.rotation.y += 0.002

func _process(delta):
    # Additional animations or updates that need to happen every frame
    pass

# API Methods for runtime use

func add_window_to_account(account_id, window_type=WindowType.TERMINAL):
    """
    Add a new window to an existing account
    """
    if not account_id in account_nodes:
        return null
    
    var account_data = account_nodes[account_id]
    _add_windows_to_account(account_id, 1)
    
    # Return the ID of the newly created window
    var window_count = account_windows[account_id].size()
    if window_count > 0:
        return account_windows[account_id][window_count - 1].id
    
    return null

func set_window_content(account_id, window_index, content):
    """
    Set content text for a window
    """
    if not account_id in account_windows:
        return false
    
    if window_index >= account_windows[account_id].size():
        return false
    
    var window_data = account_windows[account_id][window_index]
    window_data.content = content
    
    # Update window label if available
    var window_node = window_data.node
    if is_instance_valid(window_node):
        var label = window_node.get_node_or_null("Label3D")
        if label:
            # Limit content length for display
            var display_text = content
            if display_text.length() > 20:
                display_text = display_text.substr(0, 17) + "..."
            
            label.text = display_text
    
    return true

func get_window_content(account_id, window_index):
    """
    Get content text for a window
    """
    if not account_id in account_windows:
        return ""
    
    if window_index >= account_windows[account_id].size():
        return ""
    
    return account_windows[account_id][window_index].content

func set_account_active(account_id, active=true):
    """
    Set account visual state to active/inactive
    """
    if not account_id in account_nodes:
        return false
    
    var account_data = account_nodes[account_id]
    var account_node = account_data.node
    
    if is_instance_valid(account_node):
        # Update visual appearance
        var center = account_node.get_node_or_null("MeshInstance3D")
        if center and center.material_override:
            var material = center.material_override
            
            if active:
                material.emission_energy = 1.2
                # Scale up slightly
                account_node.scale = Vector3(1.2, 1.2, 1.2)
            else:
                material.emission_energy = 0.7
                account_node.scale = Vector3(1.0, 1.0, 1.0)
    
    if active:
        emit_signal("account_activated", account_id)
    
    return true