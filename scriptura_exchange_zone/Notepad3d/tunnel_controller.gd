extends Node

class_name TunnelController

signal connection_status_changed(status, message)
signal tunnel_transfer_completed(tunnel_id, content)

# Configuration
const MAX_TUNNELS_PER_ANCHOR = 9
const ENERGY_RECOVERY_RATE = 1.5  # Energy units per second
const DIMENSION_SHIFT_COST = 5.0
const BASE_TRANSFER_COST = 2.0

# Tunnel system
var ethereal_tunnel_manager
var tunnel_visualizer
var current_dimension = 3

# Energy system
var available_energy = 100.0
var max_energy = 100.0
var is_energy_recovering = true

# Turn system
var turn_cycle = 12
var current_turn = 0
var turn_effects = {
    0: {"name": "Origin", "dimension_boost": 1, "energy_boost": 1.5},
    1: {"name": "Flow", "stability_boost": 0.1, "transfer_speed": 1.2},
    2: {"name": "Expansion", "max_tunnels_boost": 2, "dimension_cost_reduction": 0.2},
    3: {"name": "Convergence", "connection_boost": 1.5},
    4: {"name": "Reflection", "word_resonance": 1.3},
    5: {"name": "Diminution", "energy_recovery": 2.0},
    6: {"name": "Elevation", "dimension_boost": 2, "stability_reduction": 0.1},
    7: {"name": "Insight", "word_power": 1.5},
    8: {"name": "Reverberation", "tunnel_durability": 1.3},
    9: {"name": "Crystallization", "energy_efficiency": 1.4},
    10: {"name": "Manifestation", "word_materialization": 1.6},
    11: {"name": "Transition", "dimension_shift_potential": 1.0}
}

# Transfer queue
var pending_transfers = []
var active_transfer = null

func _ready():
    # Auto-detect components if in scene tree
    if not ethereal_tunnel_manager:
        var potential_managers = get_tree().get_nodes_in_group("tunnel_managers")
        if potential_managers.size() > 0:
            ethereal_tunnel_manager = potential_managers[0]
            print("Automatically found tunnel manager: " + ethereal_tunnel_manager.name)
    
    if not tunnel_visualizer:
        var potential_visualizers = get_tree().get_nodes_in_group("tunnel_visualizers")
        if potential_visualizers.size() > 0:
            tunnel_visualizer = potential_visualizers[0]
            print("Automatically found tunnel visualizer: " + tunnel_visualizer.name)
    
    # Connect signals
    _connect_signals()

func _connect_signals():
    if ethereal_tunnel_manager:
        if not ethereal_tunnel_manager.is_connected("tunnel_established", self, "_on_tunnel_established"):
            ethereal_tunnel_manager.connect("tunnel_established", self, "_on_tunnel_established")
        
        if not ethereal_tunnel_manager.is_connected("tunnel_collapsed", self, "_on_tunnel_collapsed"):
            ethereal_tunnel_manager.connect("tunnel_collapsed", self, "_on_tunnel_collapsed")
    
    if tunnel_visualizer:
        if not tunnel_visualizer.is_connected("tunnel_selected", self, "_on_tunnel_selected"):
            tunnel_visualizer.connect("tunnel_selected", self, "_on_tunnel_selected")
        
        if not tunnel_visualizer.is_connected("anchor_selected", self, "_on_anchor_selected"):
            tunnel_visualizer.connect("anchor_selected", self, "_on_anchor_selected")

func _process(delta):
    # Handle energy recovery
    if is_energy_recovering and available_energy < max_energy:
        var recovery_rate = ENERGY_RECOVERY_RATE
        
        # Apply turn effect if any
        if turn_effects[current_turn].has("energy_recovery"):
            recovery_rate *= turn_effects[current_turn].energy_recovery
            
        available_energy = min(available_energy + recovery_rate * delta, max_energy)
    
    # Process transfer queue
    _process_transfer_queue(delta)
    
    # Update tunnel stability based on dimension
    if Engine.get_idle_frames() % 60 == 0:  # Once per second
        _update_tunnel_stability()

func advance_turn():
    current_turn = (current_turn + 1) % turn_cycle
    print("Advanced to turn: " + str(current_turn) + " - " + turn_effects[current_turn].name)
    
    # Apply turn effects
    match current_turn:
        6:  # Elevation - possibility for dimension shift
            if randf() < 0.3:  # 30% chance
                shift_dimension(current_dimension + 1)
        11: # Transition - chance to return to base dimension
            if current_dimension > 3 and randf() < 0.5:  # 50% chance
                shift_dimension(3)
    
    # Return turn info
    return {
        "turn": current_turn,
        "name": turn_effects[current_turn].name,
        "effects": turn_effects[current_turn]
    }

func shift_dimension(new_dimension):
    if new_dimension == current_dimension:
        return false
    
    # Ensure dimension is in valid range
    new_dimension = clamp(new_dimension, 1, 9)
    
    # Check energy cost
    var cost = DIMENSION_SHIFT_COST * abs(new_dimension - current_dimension)
    
    # Apply cost reduction if available in current turn
    if turn_effects[current_turn].has("dimension_cost_reduction"):
        cost *= (1.0 - turn_effects[current_turn].dimension_cost_reduction)
    
    if available_energy < cost:
        emit_signal("connection_status_changed", "error", "Insufficient energy for dimension shift")
        return false
    
    # Apply cost
    available_energy -= cost
    
    # Perform shift
    var old_dimension = current_dimension
    current_dimension = new_dimension
    
    print("Shifted from dimension " + str(old_dimension) + " to " + str(new_dimension))
    
    # Update existing tunnels
    _recalculate_tunnel_stability()
    
    emit_signal("connection_status_changed", "success", "Shifted to dimension " + str(new_dimension))
    return true

func establish_tunnel(source_id, target_id):
    # Verify anchors exist
    if not ethereal_tunnel_manager.has_anchor(source_id) or not ethereal_tunnel_manager.has_anchor(target_id):
        emit_signal("connection_status_changed", "error", "Invalid anchor IDs")
        return null
    
    # Check for existing tunnel
    var existing_tunnel = ethereal_tunnel_manager.get_tunnel_between(source_id, target_id)
    if existing_tunnel:
        emit_signal("connection_status_changed", "warning", "Tunnel already exists")
        return existing_tunnel
    
    # Check max tunnels constraint
    var source_tunnels = ethereal_tunnel_manager.get_tunnels_for_anchor(source_id)
    
    var max_tunnels = MAX_TUNNELS_PER_ANCHOR
    if turn_effects[current_turn].has("max_tunnels_boost"):
        max_tunnels += turn_effects[current_turn].max_tunnels_boost
    
    if source_tunnels.size() >= max_tunnels:
        emit_signal("connection_status_changed", "error", "Source anchor at maximum tunnel capacity")
        return null
    
    # Calculate energy cost
    var source_anchor = ethereal_tunnel_manager.get_anchor_data(source_id)
    var target_anchor = ethereal_tunnel_manager.get_anchor_data(target_id)
    
    var distance = source_anchor.coordinates.distance_to(target_anchor.coordinates)
    var energy_cost = BASE_TRANSFER_COST + (distance * 0.5) + (current_dimension * 1.0)
    
    # Apply energy efficiency if available
    if turn_effects[current_turn].has("energy_efficiency"):
        energy_cost /= turn_effects[current_turn].energy_efficiency
    
    if available_energy < energy_cost:
        emit_signal("connection_status_changed", "error", "Insufficient energy to establish tunnel")
        return null
    
    # Apply cost
    available_energy -= energy_cost
    
    # Create tunnel with current dimension
    var tunnel = ethereal_tunnel_manager.establish_tunnel(source_id, target_id, current_dimension)
    
    if tunnel:
        emit_signal("connection_status_changed", "success", "Tunnel established from " + source_id + " to " + target_id)
    else:
        emit_signal("connection_status_changed", "error", "Failed to establish tunnel")
    
    return tunnel

func collapse_tunnel(tunnel_id):
    if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
        emit_signal("connection_status_changed", "error", "Invalid tunnel ID")
        return false
    
    # Energy is partially recovered when collapsing a tunnel
    var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
    var energy_return = BASE_TRANSFER_COST * 0.3  # Recover 30% of base cost
    
    available_energy = min(available_energy + energy_return, max_energy)
    
    var result = ethereal_tunnel_manager.collapse_tunnel(tunnel_id)
    
    if result:
        emit_signal("connection_status_changed", "success", "Tunnel collapsed")
    else:
        emit_signal("connection_status_changed", "error", "Failed to collapse tunnel")
    
    return result

func transfer_through_tunnel(tunnel_id, content):
    if not ethereal_tunnel_manager.has_tunnel(tunnel_id):
        emit_signal("connection_status_changed", "error", "Invalid tunnel ID")
        return false
    
    var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
    
    # Calculate transfer cost
    var transfer_cost = content.length * 0.05  # Cost per character
    
    # Apply turn effects if any
    if turn_effects[current_turn].has("transfer_speed"):
        transfer_cost /= turn_effects[current_turn].transfer_speed
    
    if available_energy < transfer_cost:
        emit_signal("connection_status_changed", "error", "Insufficient energy for transfer")
        return false
    
    # Apply stability factor - less stable tunnels cost more
    transfer_cost /= tunnel_data.stability
    
    # Apply cost
    available_energy -= transfer_cost
    
    # Add to transfer queue
    pending_transfers.push_back({
        "tunnel_id": tunnel_id,
        "content": content,
        "progress": 0.0,
        "total_time": content.length * 0.01 / tunnel_data.stability  # Transfer time based on content size and stability
    })
    
    emit_signal("connection_status_changed", "info", "Transfer queued")
    return true

func _process_transfer_queue(delta):
    # Start a new transfer if none is active
    if active_transfer == null and pending_transfers.size() > 0:
        active_transfer = pending_transfers.pop_front()
        print("Starting transfer through tunnel: " + active_transfer.tunnel_id)
    
    # Process active transfer
    if active_transfer != null:
        active_transfer.progress += delta
        
        # Check if transfer is complete
        if active_transfer.progress >= active_transfer.total_time:
            emit_signal("tunnel_transfer_completed", active_transfer.tunnel_id, active_transfer.content)
            print("Transfer completed through tunnel: " + active_transfer.tunnel_id)
            
            # Transfer completed
            active_transfer = null

func _update_tunnel_stability():
    var tunnels = ethereal_tunnel_manager.get_tunnels()
    
    for tunnel_id in tunnels:
        var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
        
        # Tunnels in the same dimension as current are most stable
        var dimension_factor = 1.0 - (abs(tunnel_data.dimension - current_dimension) * 0.1)
        
        # Apply turn effects if any
        var stability_modifier = 0.0
        
        if turn_effects[current_turn].has("stability_boost"):
            stability_modifier += turn_effects[current_turn].stability_boost
        
        if turn_effects[current_turn].has("stability_reduction"):
            stability_modifier -= turn_effects[current_turn].stability_reduction
        
        var new_stability = tunnel_data.stability * dimension_factor + stability_modifier
        new_stability = clamp(new_stability, 0.1, 1.0)
        
        if abs(new_stability - tunnel_data.stability) > 0.05:
            ethereal_tunnel_manager.set_tunnel_stability(tunnel_id, new_stability)

func _recalculate_tunnel_stability():
    var tunnels = ethereal_tunnel_manager.get_tunnels()
    
    for tunnel_id in tunnels:
        var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
        
        # Calculate new stability based on dimension difference
        var dimension_difference = abs(tunnel_data.dimension - current_dimension)
        var new_stability = 1.0 - (dimension_difference * 0.15)
        new_stability = clamp(new_stability, 0.1, 1.0)
        
        ethereal_tunnel_manager.set_tunnel_stability(tunnel_id, new_stability)

func _on_tunnel_established(tunnel_id):
    print("Tunnel established: " + tunnel_id)

func _on_tunnel_collapsed(tunnel_id):
    print("Tunnel collapsed: " + tunnel_id)

func _on_tunnel_selected(tunnel_id):
    print("Selected tunnel: " + tunnel_id)
    
    if tunnel_visualizer:
        tunnel_visualizer.zoom_to_tunnel(tunnel_id)

func _on_anchor_selected(anchor_id):
    print("Selected anchor: " + anchor_id)

func get_energy_status():
    return {
        "current": available_energy,
        "max": max_energy,
        "percentage": (available_energy / max_energy) * 100.0
    }

func get_current_dimension():
    return {
        "dimension": current_dimension,
        "color": tunnel_visualizer.get_tunnel_color(current_dimension) if tunnel_visualizer else Color(1,1,1)
    }

func get_current_turn_info():
    return {
        "turn": current_turn,
        "name": turn_effects[current_turn].name,
        "effects": turn_effects[current_turn]
    }

func get_active_transfer_progress():
    if active_transfer:
        return {
            "tunnel_id": active_transfer.tunnel_id,
            "progress": (active_transfer.progress / active_transfer.total_time) * 100.0,
            "content_length": active_transfer.content.length
        }
    return null