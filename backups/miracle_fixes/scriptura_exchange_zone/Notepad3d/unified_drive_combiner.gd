extends Node

class_name UnifiedDriveCombiner

# Constants for drive identification
const DRIVE_TYPES = {
    "C_DRIVE": {
        "path": "/mnt/c",
        "color": Color(0.2, 0.7, 0.3, 1.0),  # Green
        "frequency": 333,
        "symbol": "©",
        "type": "LOCAL",
        "priority": 1
    },
    "D_DRIVE": {
        "path": "/mnt/d",
        "color": Color(0.3, 0.5, 0.9, 1.0),  # Blue
        "frequency": 555,
        "symbol": "Đ",
        "type": "NETWORK",
        "priority": 2
    },
    "VIRTUAL_DRIVE": {
        "path": "res://virtual_drive",
        "color": Color(0.8, 0.3, 0.8, 1.0),  # Purple
        "frequency": 777,
        "symbol": "∞",
        "type": "VIRTUAL",
        "priority": 3
    },
    "MEMORY_DRIVE": {
        "path": "user://memory_drive",
        "color": Color(1.0, 0.7, 0.2, 1.0),  # Orange
        "frequency": 999,
        "symbol": "Ω",
        "type": "MEMORY",
        "priority": 0
    }
}

# Data storage settings
const MAX_SYNC_TIME = 9.0  # Maximum sync time in seconds
const NEURAL_CONNECTION_LIMIT = 389  # Maximum number of neural connections
const DEFAULT_BOTTLE_SIZE = 1024 * 1024 * 10  # 10MB default bottle size for neural data

# Energy and universe settings
const ENERGY_STATES = {
    "DORMANT": {
        "color": Color(0.2, 0.2, 0.4, 0.5),
        "frequency": 33,
        "flow_rate": 0.01
    },
    "ACTIVE": {
        "color": Color(0.4, 0.6, 0.9, 0.7),
        "frequency": 77,
        "flow_rate": 0.1
    },
    "VIBRANT": {
        "color": Color(0.6, 0.8, 1.0, 0.8),
        "frequency": 144,
        "flow_rate": 0.3
    },
    "GLOWING": {
        "color": Color(0.8, 0.9, 1.0, 0.9),
        "frequency": 233,
        "flow_rate": 0.7
    },
    "RADIANT": {
        "color": Color(1.0, 1.0, 1.0, 1.0),
        "frequency": 389,
        "flow_rate": 1.0
    }
}

# Universe connection settings
const UNIVERSE_CENTERS = {
    "PRIMARY": Vector2(0.5, 0.5),
    "MEMORY": Vector2(0.3, 0.2),
    "DREAM": Vector2(0.7, 0.2),
    "REFLECTION": Vector2(0.3, 0.8),
    "CREATION": Vector2(0.7, 0.8)
}

# Drive state
var active_drives = {}
var drive_stats = {}
var connected_paths = []
var neural_connections = []
var bottle_capacity = DEFAULT_BOTTLE_SIZE
var bottle_fill_level = 0

# Universe and energy state
var active_universes = ["PRIMARY"]
var universe_connections = []
var current_energy_state = "ACTIVE"
var energy_flow = 0.0
var star_points = []  # For the 389-star universe visualization
var dimension_shifts = 0

# Connected systems
var drive_connector = null
var terminal_bridge = null
var unified_command_system = null
var akashic_bridge = null

# Visualization properties
var canvas = null
var drive_visualization = {}
var connection_lines = []
var bottle_visualization = {
    "position": Vector2(0.5, 0.5),
    "size": Vector2(0.3, 0.5),
    "color": Color(0.3, 0.6, 0.9, 0.7),
    "fill_color": Color(0.2, 0.5, 1.0, 0.8),
    "fill_level": 0.0
}

# Signals
signal drive_connected(drive_id)
signal drive_disconnected(drive_id)
signal drives_combined(drive_ids)
signal neural_connection_established(source, target)
signal bottle_capacity_changed(new_capacity)
signal sync_completed(drive_ids, sync_time)

func _init():
    print("Initializing Unified Drive Combiner...")
    
    # Set up visualization
    _setup_visualization()
    
    # Connect to systems
    _connect_systems()
    
    # Initialize drives
    _initialize_drives()
    
    # Generate star universe
    _generate_star_universe(389)
    
    print("Unified Drive Combiner initialized")
    
func _generate_star_universe(star_count):
    star_points.clear()
    
    # Golden ratio to ensure even distribution
    var golden_ratio = 1.618033988749895
    var golden_angle = TAU * (1.0 - 1.0/golden_ratio)
    
    # Generate stars with different brightness and distances
    for i in range(star_count):
        var distance = sqrt(randf()) * 0.45  # Square root for more even distribution
        var angle = i * golden_angle
        
        var pos = Vector2(
            0.5 + cos(angle) * distance,
            0.5 + sin(angle) * distance
        )
        
        var brightness = pow(randf(), 2) * 0.8 + 0.2
        var size = randf_range(0.001, 0.004)
        
        star_points.append({
            "position": pos,
            "brightness": brightness,
            "size": size,
            "pulse_rate": randf_range(0.2, 1.0),
            "pulse_phase": randf() * TAU
        })
    }
    
    # Special star at the center - orange as requested
    star_points.append({
        "position": Vector2(0.5, 0.5),
        "brightness": 1.0,
        "size": 0.01,
        "pulse_rate": 0.5,
        "pulse_phase": 0.0,
        "color": Color(1.0, 0.6, 0.0, 1.0)  # Orange
    })

func _setup_visualization():
    # Create visualization canvas
    canvas = Control.new()
    canvas.set_name("UnifiedDriveCombinerCanvas")
    canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.connect("draw", Callable(self, "_draw_visualization"))

func _connect_systems():
    # Connect to DriveConnector
    if ClassDB.class_exists("DriveConnector"):
        drive_connector = load("res://drive_connector.gd").new()
        print("Connected to DriveConnector")
    else:
        print("DriveConnector not available, trying to load directly")
        var script = load("/mnt/c/Users/Percision 15/drive_connector.gd")
        if script:
            drive_connector = script.new()
            print("Loaded DriveConnector directly")
        else:
            print("DriveConnector not found, creating stub")
            drive_connector = Node.new()
            drive_connector.name = "DriveConnectorStub"
    }
    
    # Connect to TerminalVisualBridge
    if ClassDB.class_exists("TerminalVisualBridge"):
        terminal_bridge = load("res://terminal_visual_bridge.gd").new()
        print("Connected to TerminalVisualBridge")
    else:
        print("TerminalVisualBridge not available, trying to load directly")
        var script = load("/mnt/c/Users/Percision 15/terminal_visual_bridge.gd")
        if script:
            terminal_bridge = script.new()
            print("Loaded TerminalVisualBridge directly")
        else:
            print("TerminalVisualBridge not found, creating stub")
            terminal_bridge = Node.new()
            terminal_bridge.name = "TerminalBridgeStub"
    }
    
    # Connect to UnifiedCommandSystem
    if ClassDB.class_exists("UnifiedCommandSystem"):
        unified_command_system = load("res://unified_command_system.gd").new()
        print("Connected to UnifiedCommandSystem")
    else:
        print("UnifiedCommandSystem not available, trying to load directly")
        var script = load("/mnt/c/Users/Percision 15/unified_drive_command_system.gd")
        if script:
            unified_command_system = script.new()
            print("Loaded UnifiedCommandSystem directly")
        else:
            print("UnifiedCommandSystem not found, creating stub")
            unified_command_system = Node.new()
            unified_command_system.name = "UnifiedCommandSystemStub"
    }
    
    # Connect to AkashicBridge
    if ClassDB.class_exists("AkashicBridge"):
        akashic_bridge = load("res://akashic_bridge.gd").new()
        print("Connected to AkashicBridge")
    else:
        print("AkashicBridge not available, creating stub")
        akashic_bridge = Node.new()
        akashic_bridge.name = "AkashicBridgeStub"
    }

func _initialize_drives():
    # Add all available drives
    for drive_id in DRIVE_TYPES:
        var drive_data = DRIVE_TYPES[drive_id]
        connect_drive(drive_id, drive_data.path)
    }
    
    # Set up visualization
    _setup_drive_visualization()

func _setup_drive_visualization():
    drive_visualization.clear()
    
    # Create visualization data for each drive
    var angle_step = TAU / active_drives.size()
    var radius = 0.35
    var i = 0
    
    for drive_id in active_drives:
        var drive_data = DRIVE_TYPES[drive_id]
        var angle = i * angle_step
        
        drive_visualization[drive_id] = {
            "position": Vector2(0.5, 0.5) + Vector2(cos(angle), sin(angle)) * radius,
            "size": 0.1,
            "color": drive_data.color,
            "symbol": drive_data.symbol,
            "connection_strength": 0.0,
            "active": true
        }
        
        i += 1
    }

func _process(delta):
    # Update visualization
    _update_visualization(delta)
    
    # Update neural connections
    _update_neural_connections(delta)
    
    # Update bottle fill level
    _update_bottle_fill_level(delta)
    
    # Update star universe
    _update_star_universe(delta)
    
    # Update energy flow
    _update_energy_flow(delta)
    
    # Update canvas
    if canvas:
        canvas.queue_redraw()
        
func _update_star_universe(delta):
    # Update star pulsing
    for star in star_points:
        star.pulse_phase += delta * star.pulse_rate
        if star.pulse_phase > TAU:
            star.pulse_phase -= TAU
    }
    
    # Occasionally shift a random star slightly
    if randf() < delta * 0.1:
        var random_star_index = randi() % star_points.size()
        var random_star = star_points[random_star_index]
        
        # Skip the orange center star
        if "color" in random_star and random_star.color.r > 0.9 and random_star.color.g > 0.5 and random_star.color.b < 0.1:
            return
        }
        
        # Slight position adjustment
        random_star.position += Vector2(
            randf_range(-0.002, 0.002),
            randf_range(-0.002, 0.002)
        )
        
        # Keep stars within bounds
        random_star.position.x = clamp(random_star.position.x, 0.0, 1.0)
        random_star.position.y = clamp(random_star.position.y, 0.0, 1.0)
    }
    
func _update_energy_flow(delta):
    # Update energy flow based on current state
    var flow_rate = ENERGY_STATES[current_energy_state].flow_rate
    energy_flow += delta * flow_rate
    
    if energy_flow > 1.0:
        energy_flow -= 1.0
        
        # Occasionally transition to different energy state
        if randf() < 0.05:
            _transition_energy_state()
        }
    }
    
func _transition_energy_state():
    # Get current state index
    var states = ENERGY_STATES.keys()
    var current_index = states.find(current_energy_state)
    
    # Choose adjacent states with higher probability, distant states with lower
    var next_index = current_index
    var change = randi() % 3 - 1  # -1, 0, or 1
    
    if change == 0 and randf() < 0.3:
        # Occasionally make a bigger jump
        change = randi() % 2 * 2 - 1  # -1 or 1, doubled
    }
    
    next_index = (current_index + change) % states.size()
    if next_index < 0:
        next_index += states.size()
    }
    
    # Set new energy state
    current_energy_state = states[next_index]
    
    # If transitioning to RADIANT, try to activate another universe
    if current_energy_state == "RADIANT" and active_universes.size() < UNIVERSE_CENTERS.size():
        _activate_random_universe()
    }
    
func _activate_random_universe():
    # Find inactive universes
    var inactive_universes = []
    for universe in UNIVERSE_CENTERS.keys():
        if not universe in active_universes:
            inactive_universes.append(universe)
        }
    }
    
    if inactive_universes.size() > 0:
        # Activate a random universe
        var random_universe = inactive_universes[randi() % inactive_universes.size()]
        active_universes.append(random_universe)
        
        # Create universe connections
        for existing_universe in active_universes:
            if existing_universe != random_universe:
                universe_connections.append({
                    "source": existing_universe,
                    "target": random_universe,
                    "energy": 0.1,
                    "growth_rate": 0.05 + randf() * 0.1
                })
            }
        }
        
        # Increment dimension shifts
        dimension_shifts += 1
    }

func _update_visualization(delta):
    # Update drive connection strength
    for drive_id in drive_visualization:
        var vis_data = drive_visualization[drive_id]
        
        if active_drives[drive_id].combined:
            // Gradually increase connection strength
            vis_data.connection_strength = min(1.0, vis_data.connection_strength + delta * 0.5)
        } else {
            // Gradually decrease connection strength
            vis_data.connection_strength = max(0.0, vis_data.connection_strength - delta * 0.5)
        }
    }
    
    # Pulse effect for connections
    for i in range(connection_lines.size()):
        connection_lines[i].pulse += delta * connection_lines[i].frequency
        if connection_lines[i].pulse > 1.0:
            connection_lines[i].pulse -= 1.0
        }
    }

func _update_neural_connections(delta):
    # Update neural connection strength
    for i in range(neural_connections.size()):
        neural_connections[i].strength += neural_connections[i].growth_rate * delta
        neural_connections[i].strength = clamp(neural_connections[i].strength, 0.0, 1.0)
        
        # Update connection frequency
        neural_connections[i].phase += delta * neural_connections[i].frequency
        if neural_connections[i].phase > TAU:
            neural_connections[i].phase -= TAU
        }
    }

func _update_bottle_fill_level(delta):
    # Calculate target fill level based on active neural connections
    var target_fill_level = float(neural_connections.size()) / NEURAL_CONNECTION_LIMIT
    
    // Gradually adjust fill level
    if bottle_visualization.fill_level < target_fill_level:
        bottle_visualization.fill_level = min(target_fill_level, bottle_visualization.fill_level + delta * 0.1)
    } else if bottle_visualization.fill_level > target_fill_level:
        bottle_visualization.fill_level = max(target_fill_level, bottle_visualization.fill_level - delta * 0.05)
    }
    
    // Update actual data fill level
    bottle_fill_level = int(bottle_capacity * bottle_visualization.fill_level)
}

func _draw_visualization():
    if not canvas:
        return
    
    var size = canvas.get_size()
    
    # Draw background
    canvas.draw_rect(Rect2(0, 0, size.x, size.y), Color(0.05, 0.05, 0.1, 1.0))
    
    # Draw star universe
    _draw_star_universe(size)
    
    # Draw connection lines
    _draw_connection_lines(size)
    
    # Draw neural connections
    _draw_neural_connections(size)
    
    # Draw neural bottle
    _draw_neural_bottle(size)
    
    # Draw drives
    _draw_drives(size)
    
    # Draw universe connections
    _draw_universe_connections(size)
    
    # Draw energy state
    _draw_energy_state(size)
    
func _draw_star_universe(size):
    # Draw each star in the universe
    for star in star_points:
        var pos = Vector2(star.position.x * size.x, star.position.y * size.y)
        var brightness = star.brightness
        var current_size = star.size * size.x
        
        # Apply pulsing effect
        var pulse = 0.8 + 0.2 * sin(star.pulse_phase)
        brightness *= pulse
        current_size *= pulse
        
        # Use star's custom color if available, otherwise use white with brightness
        var color
        if "color" in star:
            color = star.color
            color.a = brightness
        else:
            color = Color(brightness, brightness, brightness, brightness)
        
        canvas.draw_circle(pos, current_size, color)
    }
    
func _draw_universe_connections(size):
    # Only draw if we have multiple active universes
    if active_universes.size() <= 1:
        return
    
    # Draw connections between universe centers
    for i in range(active_universes.size()):
        var universe1 = active_universes[i]
        
        for j in range(i+1, active_universes.size()):
            var universe2 = active_universes[j]
            
            if not UNIVERSE_CENTERS.has(universe1) or not UNIVERSE_CENTERS.has(universe2):
                continue
            
            var pos1 = Vector2(
                UNIVERSE_CENTERS[universe1].x * size.x,
                UNIVERSE_CENTERS[universe1].y * size.y
            )
            
            var pos2 = Vector2(
                UNIVERSE_CENTERS[universe2].x * size.x,
                UNIVERSE_CENTERS[universe2].y * size.y
            )
            
            # Draw a curved connection line
            var control_offset = Vector2((pos2.y - pos1.y) * 0.3, (pos1.x - pos2.x) * 0.3)
            var control_point = (pos1 + pos2) * 0.5 + control_offset
            
            var energy_state = ENERGY_STATES[current_energy_state]
            var connection_color = energy_state.color
            
            # Draw the connection with gradient
            var segments = 20
            var points = []
            
            for k in range(segments + 1):
                var t = float(k) / float(segments)
                var p = _quadratic_bezier(pos1, control_point, pos2, t)
                points.append(p)
            }
            
            for k in range(segments):
                var t = float(k) / float(segments)
                var flow_offset = fmod(energy_flow + t, 1.0)
                var alpha = 0.3 + 0.7 * (1.0 - abs(flow_offset * 2.0 - 1.0))
                var line_color = connection_color
                line_color.a = alpha
                
                canvas.draw_line(points[k], points[k+1], line_color, 2.0 + 3.0 * alpha)
            }
        }
    }
    
func _draw_energy_state(size):
    var energy_state = ENERGY_STATES[current_energy_state]
    var color = energy_state.color
    
    # Draw energy state indicator
    var indicator_pos = Vector2(size.x * 0.95, size.y * 0.05)
    var indicator_size = size.x * 0.03
    
    canvas.draw_circle(indicator_pos, indicator_size, color)
    
    # Draw energy flow rate indicator
    var flow_width = size.x * 0.1
    var flow_height = size.y * 0.01
    var flow_rect = Rect2(
        indicator_pos.x - flow_width / 2,
        indicator_pos.y + indicator_size * 1.5,
        flow_width,
        flow_height
    )
    
    canvas.draw_rect(flow_rect, Color(0.2, 0.2, 0.2, 0.5))
    canvas.draw_rect(
        Rect2(flow_rect.position, Vector2(flow_width * energy_state.flow_rate, flow_height)),
        color
    )

func _draw_connection_lines(size):
    # Draw lines between combined drives and center
    for drive_id in drive_visualization:
        var vis_data = drive_visualization[drive_id]
        var drive_pos = Vector2(vis_data.position.x * size.x, vis_data.position.y * size.y)
        var center_pos = Vector2(size.x * 0.5, size.y * 0.5)
        
        # Only draw lines for combined drives
        if vis_data.connection_strength > 0.01:
            var line_color = vis_data.color
            line_color.a = vis_data.connection_strength * 0.7
            
            var line_width = 2.0 + vis_data.connection_strength * 3.0
            canvas.draw_line(drive_pos, center_pos, line_color, line_width)
            
            // Draw data pulses along the line
            for connection in connection_lines:
                if connection.source == drive_id:
                    var pulse_pos = lerp(drive_pos, center_pos, connection.pulse)
                    var pulse_size = 5.0 * connection.strength
                    
                    canvas.draw_circle(pulse_pos, pulse_size, connection.color)
                }
            }
        }
    }

func _draw_neural_connections(size):
    # Draw neural connections between bottle and edges
    var bottle_center = Vector2(
        bottle_visualization.position.x * size.x,
        bottle_visualization.position.y * size.y
    )
    
    for connection in neural_connections:
        var connection_strength = connection.strength
        if connection_strength < 0.05:
            continue
        }
        
        var angle = connection.angle
        var length = connection.length * 150.0
        var end_pos = bottle_center + Vector2(cos(angle), sin(angle)) * length
        
        // Draw curved neural connection
        var control_offset = Vector2(sin(angle), -cos(angle)) * length * 0.5
        var control_point = (bottle_center + end_pos) * 0.5 + control_offset
        
        // Draw path with pulsing gradient
        var segments = 20
        var points = []
        
        for i in range(segments + 1):
            var t = float(i) / float(segments)
            var p = _quadratic_bezier(bottle_center, control_point, end_pos, t)
            points.append(p)
        }
        
        // Draw segments with color gradient
        for i in range(segments):
            var t1 = float(i) / float(segments)
            var t2 = float(i + 1) / float(segments)
            
            var pulse_phase = fmod(connection.phase + t1, 1.0)
            var pulse_intensity = 0.5 + 0.5 * sin(pulse_phase * TAU)
            
            var color = connection.color
            color.a = connection_strength * (0.3 + 0.7 * pulse_intensity)
            
            // Width based on pulse
            var width = 1.0 + 2.0 * connection_strength * pulse_intensity
            
            canvas.draw_line(points[i], points[i+1], color, width)
        }
    }

func _quadratic_bezier(p0, p1, p2, t):
    var q0 = p0.lerp(p1, t)
    var q1 = p1.lerp(p2, t)
    return q0.lerp(q1, t)

func _draw_neural_bottle(size):
    var bottle_pos = Vector2(
        bottle_visualization.position.x * size.x,
        bottle_visualization.position.y * size.y
    )
    var bottle_width = bottle_visualization.size.x * size.x
    var bottle_height = bottle_visualization.size.y * size.y
    
    // Draw bottle outline
    var bottle_rect = Rect2(
        bottle_pos.x - bottle_width / 2,
        bottle_pos.y - bottle_height / 2,
        bottle_width,
        bottle_height
    )
    
    canvas.draw_rect(bottle_rect, bottle_visualization.color)
    
    // Draw bottle fill level
    var fill_height = bottle_height * bottle_visualization.fill_level
    var fill_rect = Rect2(
        bottle_pos.x - bottle_width / 2,
        bottle_pos.y + bottle_height / 2 - fill_height,
        bottle_width,
        fill_height
    )
    
    canvas.draw_rect(fill_rect, bottle_visualization.fill_color)
    
    // Draw capacity indicator
    var capacity_width = bottle_width * 0.8
    var capacity_height = 10
    var capacity_rect = Rect2(
        bottle_pos.x - capacity_width / 2,
        bottle_pos.y + bottle_height / 2 + 20,
        capacity_width,
        capacity_height
    )
    
    canvas.draw_rect(capacity_rect, Color(0.3, 0.3, 0.3, 0.8))
    canvas.draw_rect(
        Rect2(capacity_rect.position, Vector2(capacity_width * bottle_visualization.fill_level, capacity_height)),
        bottle_visualization.fill_color
    )

func _draw_drives(size):
    # Draw each drive as a circle with symbol
    for drive_id in drive_visualization:
        var vis_data = drive_visualization[drive_id]
        var drive_pos = Vector2(vis_data.position.x * size.x, vis_data.position.y * size.y)
        var drive_size = vis_data.size * size.x * 0.2
        
        // Draw drive circle
        var drive_color = vis_data.color
        if active_drives[drive_id].combined:
            drive_color = drive_color.lightened(0.2)
        }
        
        canvas.draw_circle(drive_pos, drive_size, drive_color)
        
        // Draw drive symbol in center
        // Since we can't draw text directly, draw a simple shape
        var symbol_size = drive_size * 0.6
        var symbol_pos = drive_pos
        
        match vis_data.symbol:
            "©":
                // Draw C
                canvas.draw_circle(symbol_pos, symbol_size, Color(0,0,0,0))
                canvas.draw_circle(symbol_pos, symbol_size, Color(1,1,1,0.8), false, 2.0)
            "Đ":
                // Draw D with line
                var rect = Rect2(symbol_pos.x - symbol_size/2, symbol_pos.y - symbol_size/2, symbol_size, symbol_size)
                canvas.draw_rect(rect, Color(0,0,0,0))
                canvas.draw_rect(rect, Color(1,1,1,0.8), false, 2.0)
                canvas.draw_line(
                    Vector2(symbol_pos.x - symbol_size/2, symbol_pos.y),
                    Vector2(symbol_pos.x + symbol_size/2, symbol_pos.y),
                    Color(1,1,1,0.8), 
                    2.0
                )
            "∞":
                // Draw infinity symbol
                var left_center = symbol_pos + Vector2(-symbol_size * 0.4, 0)
                var right_center = symbol_pos + Vector2(symbol_size * 0.4, 0)
                var radius = symbol_size * 0.3
                
                canvas.draw_circle(left_center, radius, Color(0,0,0,0))
                canvas.draw_circle(left_center, radius, Color(1,1,1,0.8), false, 2.0)
                canvas.draw_circle(right_center, radius, Color(0,0,0,0))
                canvas.draw_circle(right_center, radius, Color(1,1,1,0.8), false, 2.0)
            "Ω":
                // Draw omega symbol
                var points = []
                var segments = 10
                
                for i in range(segments + 1):
                    var angle = PI - PI * float(i) / float(segments)
                    var point = symbol_pos + Vector2(cos(angle), sin(angle)) * symbol_size * 0.6
                    points.append(point)
                }
                
                // Add bottom points
                points.append(symbol_pos + Vector2(-symbol_size * 0.4, symbol_size * 0.5))
                points.append(symbol_pos + Vector2(symbol_size * 0.4, symbol_size * 0.5))
                
                // Draw the shape
                for i in range(points.size() - 1):
                    canvas.draw_line(points[i], points[i+1], Color(1,1,1,0.8), 2.0)
                }
        }
        
        // Draw connection indicator if combined
        if active_drives[drive_id].combined:
            var indicator_size = drive_size * 0.3
            var indicator_pos = drive_pos + Vector2(drive_size * 0.7, -drive_size * 0.7)
            canvas.draw_circle(indicator_pos, indicator_size, Color(0.2, 0.9, 0.3, 0.8))
        }
    }

func connect_drive(drive_id, path):
    if drive_id in active_drives:
        print("Drive already connected: " + drive_id)
        return false
    }
    
    if not drive_id in DRIVE_TYPES:
        print("Unknown drive type: " + drive_id)
        return false
    }
    
    var drive_data = DRIVE_TYPES[drive_id]
    
    // Set up drive
    active_drives[drive_id] = {
        "id": drive_id,
        "path": path,
        "type": drive_data.type,
        "combined": false,
        "connection_time": OS.get_unix_time(),
        "data_count": 0,
        "neural_connections": []
    }
    
    // Initialize drive stats
    drive_stats[drive_id] = {
        "data_in": 0,
        "data_out": 0,
        "syncs": 0,
        "neural_asks": 0,
        "last_access": OS.get_unix_time()
    }
    
    // Connect path
    if not path in connected_paths:
        connected_paths.append(path)
    }
    
    // Connect to drive connector if available
    if drive_connector and drive_connector.has_method("connect_drive"):
        drive_connector.connect_drive(
            drive_id,
            drive_id,
            drive_data.type,
            path
        )
    }
    
    emit_signal("drive_connected", drive_id)
    
    // Update visualization
    _setup_drive_visualization()
    
    return true
}

func disconnect_drive(drive_id):
    if not drive_id in active_drives:
        print("Drive not connected: " + drive_id)
        return false
    }
    
    var drive = active_drives[drive_id]
    
    // Remove from connected paths
    var path_index = connected_paths.find(drive.path)
    if path_index >= 0:
        connected_paths.remove_at(path_index)
    }
    
    // Disconnect from drive connector
    if drive_connector and drive_connector.has_method("disconnect_drive"):
        drive_connector.disconnect_drive(drive_id)
    }
    
    // Remove any neural connections
    for i in range(neural_connections.size() - 1, -1, -1):
        if neural_connections[i].source == drive_id or neural_connections[i].target == drive_id:
            neural_connections.remove_at(i)
        }
    }
    
    // Remove from active drives
    active_drives.erase(drive_id)
    
    emit_signal("drive_disconnected", drive_id)
    
    // Update visualization
    _setup_drive_visualization()
    
    return true
}

func combine_drives(drive_ids = null):
    // If no drives specified, combine all active drives
    if drive_ids == null:
        drive_ids = active_drives.keys()
    }
    
    // Make sure all drives exist
    for drive_id in drive_ids:
        if not drive_id in active_drives:
            print("Drive not found: " + drive_id)
            return false
        }
    }
    
    // Mark drives as combined
    for drive_id in drive_ids:
        active_drives[drive_id].combined = true
    }
    
    // Establish neural connections between drives
    var combined_count = 0
    
    for drive_id in drive_ids:
        // Create connection to neural bottle
        create_neural_connection(drive_id, "BOTTLE")
        combined_count += 1
    }
    
    // Create connection lines for visualization
    _create_connection_lines(drive_ids)
    
    // Emit signal
    emit_signal("drives_combined", drive_ids)
    
    // Update terminal with visualization
    if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
        terminal_bridge.process_terminal_command("temp", ["HOT"])
        terminal_bridge.process_terminal_command("energy", ["1", "2", "3"])
    }
    
    print(str(combined_count) + " drives combined")
    return true
}

func _create_connection_lines(drive_ids):
    connection_lines.clear()
    
    for drive_id in drive_ids:
        // Create data pulse connection
        var connection = {
            "source": drive_id,
            "target": "BOTTLE",
            "pulse": randf(),
            "frequency": (DRIVE_TYPES[drive_id].frequency % 100) * 0.01,  // Convert to reasonable animation speed
            "color": DRIVE_TYPES[drive_id].color,
            "strength": 1.0
        }
        
        connection_lines.append(connection)
    }
}

func create_neural_connection(source_id, target_id = "BOTTLE"):
    // Make sure source drive exists
    if not source_id in active_drives and source_id != "BOTTLE":
        print("Source drive not found: " + source_id)
        return false
    }
    
    // Check if within connection limit
    if neural_connections.size() >= NEURAL_CONNECTION_LIMIT:
        print("Neural connection limit reached")
        return false
    }
    
    // Create neural connection
    var freq_base = 0
    var angle_base = 0
    var color
    
    if source_id in DRIVE_TYPES:
        freq_base = DRIVE_TYPES[source_id].frequency
        angle_base = randf() * TAU
        color = DRIVE_TYPES[source_id].color
    } else {
        // For BOTTLE and other special sources
        freq_base = 389
        angle_base = randf() * TAU
        color = bottle_visualization.color
    }
    
    var connection = {
        "source": source_id,
        "target": target_id,
        "frequency": freq_base * 0.01,
        "strength": 0.1,
        "growth_rate": 0.1 + randf() * 0.2,
        "angle": angle_base + randf_range(-0.5, 0.5),
        "length": 0.5 + randf() * 0.5,
        "color": color,
        "phase": randf() * TAU,
        "creation_time": OS.get_unix_time()
    }
    
    neural_connections.append(connection)
    
    // Register with drive if it's a standard drive
    if source_id in active_drives:
        active_drives[source_id].neural_connections.append(connection)
        
        // Update stats
        if source_id in drive_stats:
            drive_stats[source_id].neural_asks += 1
        }
    }
    
    // Emit signal
    emit_signal("neural_connection_established", source_id, target_id)
    
    return true
}

func sync_drives(drive_ids = null, force_fast = false):
    // If no drives specified, sync all combined drives
    if drive_ids == null:
        drive_ids = []
        for drive_id in active_drives:
            if active_drives[drive_id].combined:
                drive_ids.append(drive_id)
            }
        }
    }
    
    // Make sure all drives exist
    for drive_id in drive_ids:
        if not drive_id in active_drives:
            print("Drive not found: " + drive_id)
            return false
        }
    }
    
    // Calculate sync time - faster if fewer drives or forced fast
    var sync_time = MAX_SYNC_TIME * (float(drive_ids.size()) / active_drives.size())
    
    if force_fast:
        sync_time = min(sync_time, 3.0)
    }
    
    // Start sync through drive connector
    if drive_connector and drive_connector.has_method("sync_drives") and drive_ids.size() >= 2:
        for i in range(drive_ids.size()):
            for j in range(i+1, drive_ids.size()):
                drive_connector.sync_drives(drive_ids[i], drive_ids[j])
            }
        }
    }
    
    // Update stats
    for drive_id in drive_ids:
        if drive_id in drive_stats:
            drive_stats[drive_id].syncs += 1
            drive_stats[drive_id].last_access = OS.get_unix_time()
        }
    }
    
    // Emit signal
    emit_signal("sync_completed", drive_ids, sync_time)
    
    print("Sync completed in " + str(sync_time) + " seconds")
    return {
        "drives": drive_ids,
        "sync_time": sync_time
    }
}

func store_data(data_id, content, drive_ids = null):
    // If no drives specified, store in all combined drives
    if drive_ids == null:
        drive_ids = []
        for drive_id in active_drives:
            if active_drives[drive_id].combined:
                drive_ids.append(drive_id)
            }
        }
    }
    
    var stored_count = 0
    
    // Store in each specified drive
    for drive_id in drive_ids:
        if drive_connector and drive_connector.has_method("store_data"):
            var result = drive_connector.store_data(drive_id, data_id, content)
            
            if result:
                stored_count += 1
                
                // Update stats
                if drive_id in drive_stats:
                    drive_stats[drive_id].data_in += 1
                    drive_stats[drive_id].last_access = OS.get_unix_time()
                }
                
                // Update drive data count
                if drive_id in active_drives:
                    active_drives[drive_id].data_count += 1
                }
            }
        }
    }
    
    // Also store in neural bottle
    if neural_connections.size() > 0:
        var bottle_content = {
            "id": data_id,
            "content": content,
            "drives": drive_ids,
            "timestamp": OS.get_unix_time()
        }
        
        // Simulate storing in bottle
        bottle_fill_level += content.length()
        bottle_fill_level = min(bottle_fill_level, bottle_capacity)
        
        // Update bottle visualization
        bottle_visualization.fill_level = float(bottle_fill_level) / bottle_capacity
    }
    
    return {
        "stored": true,
        "drives": stored_count,
        "data_id": data_id
    }
}

func retrieve_data(data_id, drive_ids = null):
    // If no drives specified, check all combined drives
    if drive_ids == null:
        drive_ids = []
        for drive_id in active_drives:
            if active_drives[drive_id].combined:
                drive_ids.append(drive_id)
            }
        }
    }
    
    var data_content = null
    var source_drive = null
    
    // Check each drive
    for drive_id in drive_ids:
        if drive_connector and drive_connector.has_method("get_data"):
            var content = drive_connector.get_data(drive_id, data_id)
            
            if content:
                data_content = content
                source_drive = drive_id
                
                // Update stats
                if drive_id in drive_stats:
                    drive_stats[drive_id].data_out += 1
                    drive_stats[drive_id].last_access = OS.get_unix_time()
                }
                
                break
            }
        }
    }
    
    if data_content:
        return {
            "found": true,
            "drive": source_drive,
            "data": data_content
        }
    } else {
        return {
            "found": false,
            "data_id": data_id
        }
    }
}

func get_active_drives():
    return active_drives.keys()

func get_combined_drives():
    var combined = []
    
    for drive_id in active_drives:
        if active_drives[drive_id].combined:
            combined.append(drive_id)
        }
    }
    
    return combined
}

func get_drive_stats(drive_id):
    if drive_id in drive_stats:
        return drive_stats[drive_id]
    } else {
        return null
    }
}

func get_neural_connections():
    return neural_connections
}

func get_bottle_capacity():
    return bottle_capacity
}

func set_bottle_capacity(capacity):
    bottle_capacity = capacity
    emit_signal("bottle_capacity_changed", capacity)
    return true
}

func get_visualization_canvas():
    return canvas
}

func process_neural_ask(question, drive_ids = null):
    // Process a neural question across combined drives
    if drive_ids == null:
        drive_ids = get_combined_drives()
    }
    
    if drive_ids.size() == 0:
        return {
            "error": "No combined drives available for neural ask"
        }
    }
    
    // Create neural connections for each drive
    for drive_id in drive_ids:
        // Create a new neural connection for this question
        create_neural_connection(drive_id, "BOTTLE")
        
        // Update stats
        if drive_id in drive_stats:
            drive_stats[drive_id].neural_asks += 1
        }
    }
    
    // Simulate processing time - would be async in real implementation
    var processing_time = 9.0 * randf_range(0.8, 1.2)  // Around 9 seconds as requested
    
    // Would process with actual AI here
    
    return {
        "question": question,
        "drives": drive_ids,
        "connections": neural_connections.size(),
        "processing_time": processing_time
    }
}

func process_command(command, args):
    match command:
        "connect":
            if args.size() >= 2:
                return connect_drive(args[0], args[1])
            } elif args.size() >= 1:
                if args[0] in DRIVE_TYPES:
                    return connect_drive(args[0], DRIVE_TYPES[args[0]].path)
                } else {
                    return {"error": "Unknown drive type"}
                }
            } else {
                return {"error": "Insufficient arguments"}
            }
        
        "disconnect":
            if args.size() >= 1:
                return disconnect_drive(args[0])
            } else {
                return {"error": "Drive ID required"}
            }
        
        "combine":
            if args.size() >= 1:
                return combine_drives(args)
            } else {
                return combine_drives()
            }
        
        "sync":
            if args.size() >= 1:
                var force_fast = false
                if args.size() >= 2 and args[1] == "fast":
                    force_fast = true
                }
                return sync_drives(args, force_fast)
            } else {
                return sync_drives()
            }
        
        "store":
            if args.size() >= 2:
                var data_id = args[0]
                var content = args[1]
                var drives = null
                
                if args.size() >= 3:
                    drives = args.slice(2)
                }
                
                return store_data(data_id, content, drives)
            } else {
                return {"error": "Insufficient arguments"}
            }
        
        "retrieve":
            if args.size() >= 1:
                var data_id = args[0]
                var drives = null
                
                if args.size() >= 2:
                    drives = args.slice(1)
                }
                
                return retrieve_data(data_id, drives)
            } else {
                return {"error": "Data ID required"}
            }
        
        "neural":
            if args.size() >= 1:
                var question = args[0]
                var drives = null
                
                if args.size() >= 2:
                    drives = args.slice(1)
                }
                
                return process_neural_ask(question, drives)
            } else {
                return {"error": "Question required"}
            }
        
        "bottle":
            if args.size() >= 1 and args[0] == "capacity" and args.size() >= 2:
                return set_bottle_capacity(int(args[1]))
            } else {
                return {
                    "capacity": bottle_capacity,
                    "fill_level": bottle_fill_level,
                    "percentage": float(bottle_fill_level) / bottle_capacity * 100.0
                }
            }
        
        "universe":
            if args.size() >= 1:
                match args[0]:
                    "activate":
                        if args.size() >= 2:
                            return activate_universe(args[1])
                        } else {
                            return {"error": "Universe name required"}
                        }
                    "deactivate":
                        if args.size() >= 2:
                            return deactivate_universe(args[1])
                        } else {
                            return {"error": "Universe name required"}
                        }
                    "shift":
                        return shift_dimension()
                    "reset":
                        return reset_universes()
                    _:
                        return {"error": "Unknown universe command"}
            } else {
                return {
                    "active": active_universes,
                    "shifts": dimension_shifts,
                    "connections": universe_connections.size()
                }
            }
        
        "energy":
            if args.size() >= 1:
                match args[0]:
                    "state":
                        if args.size() >= 2 and args[1] in ENERGY_STATES:
                            current_energy_state = args[1]
                            return {"energy_state": current_energy_state}
                        } else {
                            return {"error": "Valid energy state required"}
                        }
                    "flow":
                        if args.size() >= 2:
                            energy_flow = float(args[1])
                            return {"energy_flow": energy_flow}
                        } else {
                            return {"error": "Flow value required"}
                        }
                    "cycle":
                        return cycle_energy_states()
                    _:
                        return {"error": "Unknown energy command"}
            } else {
                return {
                    "state": current_energy_state,
                    "flow": energy_flow,
                    "rate": ENERGY_STATES[current_energy_state].flow_rate
                }
            }
        
        "stars":
            if args.size() >= 1:
                match args[0]:
                    "generate":
                        var count = 389
                        if args.size() >= 2:
                            count = int(args[1])
                        }
                        _generate_star_universe(count)
                        return {"generated": count}
                    "pulse":
                        return pulse_stars()
                    _:
                        return {"error": "Unknown stars command"}
            } else {
                return {
                    "count": star_points.size(),
                    "center": star_points.size() > 0 and "color" in star_points[star_points.size()-1]
                }
            }
        
        "list":
            if args.size() >= 1:
                match args[0]:
                    "drives":
                        return get_active_drives()
                    "combined":
                        return get_combined_drives()
                    "neural":
                        return get_neural_connections()
                    "universes":
                        return active_universes
                    _:
                        return {"error": "Unknown list type"}
            } else {
                return {
                    "drives": get_active_drives(),
                    "combined": get_combined_drives(),
                    "neural_count": neural_connections.size(),
                    "universes": active_universes,
                    "energy": current_energy_state
                }
            }
        
        "stats":
            if args.size() >= 1:
                return get_drive_stats(args[0])
            } else {
                var all_stats = {}
                for drive_id in drive_stats:
                    all_stats[drive_id] = drive_stats[drive_id]
                }
                return all_stats
            }
        
        _:
            return {"error": "Unknown command: " + command}
            
func activate_universe(universe_name):
    if not universe_name in UNIVERSE_CENTERS:
        return {"error": "Unknown universe: " + universe_name}
    }
    
    if universe_name in active_universes:
        return {"message": "Universe already active: " + universe_name}
    }
    
    active_universes.append(universe_name)
    
    # Create connections to existing universes
    for existing_universe in active_universes:
        if existing_universe != universe_name:
            universe_connections.append({
                "source": existing_universe,
                "target": universe_name,
                "energy": 0.1,
                "growth_rate": 0.05 + randf() * 0.1
            })
        }
    }
    
    dimension_shifts += 1
    
    return {
        "activated": universe_name,
        "active_count": active_universes.size(),
        "dimension_shifts": dimension_shifts
    }
}

func deactivate_universe(universe_name):
    if not universe_name in active_universes:
        return {"error": "Universe not active: " + universe_name}
    }
    
    # Don't allow deactivating the primary universe
    if universe_name == "PRIMARY" and active_universes.size() > 0:
        return {"error": "Cannot deactivate the PRIMARY universe while others are active"}
    }
    
    # Remove universe from active list
    var index = active_universes.find(universe_name)
    if index >= 0:
        active_universes.remove_at(index)
    }
    
    # Remove connections
    for i in range(universe_connections.size() - 1, -1, -1):
        if universe_connections[i].source == universe_name or universe_connections[i].target == universe_name:
            universe_connections.remove_at(i)
        }
    }
    
    dimension_shifts += 1
    
    return {
        "deactivated": universe_name,
        "active_count": active_universes.size(),
        "dimension_shifts": dimension_shifts
    }
}

func shift_dimension():
    dimension_shifts += 1
    
    # Randomly activate or deactivate a universe
    if active_universes.size() < UNIVERSE_CENTERS.size() and randf() < 0.7:
        # Prefer activating when we have fewer universes
        _activate_random_universe()
        return {
            "shift": "activation",
            "dimension_shifts": dimension_shifts,
            "active_universes": active_universes
        }
    } elif active_universes.size() > 1:
        # Remove a random non-PRIMARY universe
        var removable = []
        for universe in active_universes:
            if universe != "PRIMARY":
                removable.append(universe)
            }
        }
        
        if removable.size() > 0:
            var to_remove = removable[randi() % removable.size()]
            deactivate_universe(to_remove)
            
            return {
                "shift": "deactivation",
                "removed": to_remove,
                "dimension_shifts": dimension_shifts,
                "active_universes": active_universes
            }
        }
    }
    
    # If we can't activate or deactivate, just return the current state
    return {
        "shift": "energy_only",
        "dimension_shifts": dimension_shifts,
        "active_universes": active_universes
    }
}

func reset_universes():
    # Deactivate all except PRIMARY
    for i in range(active_universes.size() - 1, -1, -1):
        if active_universes[i] != "PRIMARY":
            deactivate_universe(active_universes[i])
        }
    }
    
    # Make sure PRIMARY is active
    if not "PRIMARY" in active_universes:
        active_universes.append("PRIMARY")
    }
    
    universe_connections.clear()
    dimension_shifts = 0
    
    return {
        "reset": true,
        "active_universes": active_universes,
        "dimension_shifts": dimension_shifts
    }
}

func cycle_energy_states():
    var states = ENERGY_STATES.keys()
    var current_index = states.find(current_energy_state)
    
    # Move to next state
    current_index = (current_index + 1) % states.size()
    current_energy_state = states[current_index]
    
    return {
        "state": current_energy_state,
        "flow_rate": ENERGY_STATES[current_energy_state].flow_rate,
        "frequency": ENERGY_STATES[current_energy_state].frequency
    }
}

func pulse_stars():
    # Create a wave effect through the stars
    var center = Vector2(0.5, 0.5)
    
    for star in star_points:
        var distance = star.position.distance_to(center)
        star.pulse_phase = clamp(1.0 - distance * 2.0, 0.0, 1.0) * TAU
    }
    
    return {
        "pulsed": true,
        "stars": star_points.size()
    }
}