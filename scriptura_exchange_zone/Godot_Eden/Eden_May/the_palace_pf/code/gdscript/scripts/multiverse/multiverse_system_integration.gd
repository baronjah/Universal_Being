extends Node
class_name MultiverseSystemIntegration

# Singleton pattern
static var _instance = null
static func get_instance() -> MultiverseSystemIntegration:
    if not _instance:
        _instance = MultiverseSystemIntegration.new()
    return _instance

# References to key systems
var akashic_records_manager = null
var universal_bridge = null
var entity_evolution = null
var ui_instance = null

# Multiverse data
var universes = {}
var current_universe_id = ""
var cosmic_turn = 0
var cosmic_age = 0
var metanarrative_progress = 0.0

# Access points and connections
var access_points = []
var connections = []

# Events
signal universe_changed(universe_id)
signal cosmic_turn_advanced(turn)
signal metanarrative_progressed(progress)
signal access_point_discovered(universe_id)

func _init():
    # Register with autoload systems
    call_deferred("_initialize_integration")

func _initialize_integration():
    # Find Akashic Records if available
    if Engine.has_singleton("AkashicRecordsManager"):
        akashic_records_manager = Engine.get_singleton("AkashicRecordsManager")
    
    # Find Universal Bridge if available
    if Engine.has_singleton("UniversalBridge"):
        universal_bridge = Engine.get_singleton("UniversalBridge")
    
    # Find Entity Evolution if available
    if Engine.has_singleton("EntityEvolution"):
        entity_evolution = Engine.get_singleton("EntityEvolution")
    
    # Initialize with default universe if none exists
    if current_universe_id == "":
        create_prime_universe()

func create_ui_instance():
    # Create the UI if it doesn't exist
    if not ui_instance:
        var ui_scene = load("res://code/gdscript/scripts/multiverse/multiverse_navigation_ui.tscn")
        if ui_scene:
            ui_instance = ui_scene.instantiate()
            ui_instance.name = "MultiverseNavigationUI"
            
            # Add to the scene tree - adjust this to match your structure
            if get_tree() and get_tree().root:
                # Try to add to a UI layer if one exists
                var ui_layer = get_tree().root.get_node_or_null("UILayer")
                if ui_layer:
                    ui_layer.add_child(ui_instance)
                else:
                    get_tree().root.add_child(ui_instance)
                    
            print("Multiverse Navigation UI created")
        else:
            push_error("Could not load the Multiverse Navigation UI scene")
    
    return ui_instance

func toggle_ui_visibility():
    if ui_instance:
        ui_instance.visible = !ui_instance.visible
    else:
        var ui = create_ui_instance()
        if ui:
            ui.visible = true

func create_prime_universe():
    # Create the prime universe as the first one
    current_universe_id = "U001-01"
    cosmic_turn = 1
    cosmic_age = 0
    metanarrative_progress = 5.0
    
    # Store universe data
    universes[current_universe_id] = {
        "id": current_universe_id,
        "type": "Prime",
        "stability": 95.0,
        "energy": 80.0,
        "alignment": 10.0,
        "synchronization": 100.0,
        "core_element": "Aether",
        "entities": 0,
        "description": "The prime universe within the JSH Ethereal Engine multiverse. This is the central point from which all other universes diverge or connect.",
        "created_turn": cosmic_turn,
        "last_visited": cosmic_turn
    }
    
    # Generate initial access points
    generate_initial_access_points()
    
    # Emit universe changed event
    emit_signal("universe_changed", current_universe_id)

func generate_initial_access_points():
    # Create a few initial access points
    var types = ["Parallel", "Pocket", "Echo"]
    
    for i in range(3):
        var id = "U" + str(100 + i).pad_zeros(3) + "-01"
        
        universes[id] = {
            "id": id,
            "type": types[i],
            "stability": randf_range(65.0, 90.0),
            "energy": randf_range(50.0, 90.0),
            "alignment": randf_range(-50.0, 50.0),
            "synchronization": randf_range(60.0, 90.0),
            "core_element": ["Chronos", "Void", "Light"][i],
            "entities": 0,
            "description": "A " + types[i].to_lower() + " universe with unique properties.",
            "created_turn": cosmic_turn,
            "last_visited": 0
        }
        
        # Create connection to prime universe
        connections.append({
            "from": current_universe_id,
            "to": id,
            "stability": randf_range(70.0, 95.0),
            "created_turn": cosmic_turn,
            "strength": randf_range(0.7, 0.9)
        })
        
        # Add to access points
        access_points.append({
            "from": current_universe_id,
            "to": id,
            "discovered": true,
            "distance": randf_range(10.0, 40.0)
        })
        
        emit_signal("access_point_discovered", id)

func advance_cosmic_turn():
    cosmic_turn += 1
    
    # Randomly increase metanarrative progress
    metanarrative_progress += randf_range(0.5, 2.0)
    metanarrative_progress = min(metanarrative_progress, 100.0)
    
    # Update cosmic age if needed
    update_cosmic_age()
    
    # Update all universes
    for universe_id in universes:
        var universe = universes[universe_id]
        
        # Adjust stability
        universe.stability += randf_range(-3.0, 2.0)
        universe.stability = clamp(universe.stability, 0.0, 100.0)
        
        # Adjust energy
        universe.energy += randf_range(-2.0, 3.0)
        universe.energy = clamp(universe.energy, 0.0, 100.0)
        
        # Adjust alignment
        universe.alignment += randf_range(-5.0, 5.0)
        universe.alignment = clamp(universe.alignment, -100.0, 100.0)
        
        # Small chance to spawn new access point
        if universe_id == current_universe_id and randf() > 0.7:
            discover_new_access_point()
    
    # Update connections
    for connection in connections:
        connection.stability += randf_range(-2.0, 1.0)
        connection.stability = clamp(connection.stability, 0.0, 100.0)
        
        connection.strength += randf_range(-0.05, 0.03)
        connection.strength = clamp(connection.strength, 0.1, 1.0)
    
    # Emit signals
    emit_signal("cosmic_turn_advanced", cosmic_turn)
    emit_signal("metanarrative_progressed", metanarrative_progress)
    
    # Update UI if it exists
    if ui_instance:
        ui_instance.load_universe_data()

func update_cosmic_age():
    # Update cosmic age based on metanarrative progress
    var old_age = cosmic_age
    
    if metanarrative_progress < 20.0:
        cosmic_age = 0  # Dawn
    elif metanarrative_progress < 40.0:
        cosmic_age = 1  # Expanding
    elif metanarrative_progress < 60.0:
        cosmic_age = 2  # Stabilization
    elif metanarrative_progress < 80.0:
        cosmic_age = 3  # Convergence
    elif metanarrative_progress < 95.0:
        cosmic_age = 4  # Twilight
    else:
        cosmic_age = 5  # Renewal
    
    # If age changed, apply effects
    if cosmic_age != old_age:
        apply_cosmic_age_effects()

func apply_cosmic_age_effects():
    # Apply different effects based on the new cosmic age
    match cosmic_age:
        0:  # Dawn
            # Increase energy in all universes
            for universe_id in universes:
                universes[universe_id].energy += 10.0
                universes[universe_id].energy = min(universes[universe_id].energy, 100.0)
        
        1:  # Expanding
            # Increase chance of new universes
            discover_new_access_point()
            discover_new_access_point()
        
        2:  # Stabilization
            # Increase stability in all universes
            for universe_id in universes:
                universes[universe_id].stability += 5.0
                universes[universe_id].stability = min(universes[universe_id].stability, 100.0)
        
        3:  # Convergence
            # Increase synchronization
            for universe_id in universes:
                universes[universe_id].synchronization += 10.0
                universes[universe_id].synchronization = min(universes[universe_id].synchronization, 100.0)
        
        4:  # Twilight
            # Decrease energy, increase alignment
            for universe_id in universes:
                universes[universe_id].energy -= 5.0
                universes[universe_id].energy = max(universes[universe_id].energy, 10.0)
                
                # Move alignment toward order
                if universes[universe_id].alignment < 0:
                    universes[universe_id].alignment += 10.0
                else:
                    universes[universe_id].alignment += 5.0
                universes[universe_id].alignment = min(universes[universe_id].alignment, 100.0)
        
        5:  # Renewal
            # Reset many values, prepare for next cycle
            metanarrative_progress = 0.0
            
            for universe_id in universes:
                universes[universe_id].energy = randf_range(60.0, 90.0)
                universes[universe_id].stability = randf_range(70.0, 90.0)
            
            cosmic_age = 0  # Back to Dawn

func discover_new_access_point():
    # Determine how many universes we have
    var universe_count = universes.size()
    
    # Create a new universe with a unique ID
    var new_id = "U" + str(100 + universe_count).pad_zeros(3) + "-" + str(randi() % 100).pad_zeros(2)
    
    # Determine universe type
    var types = ["Parallel", "Pocket", "Echo", "Divergent", "Convergent", "Nascent"]
    var type = types[randi() % types.size()]
    
    # Create the universe data
    universes[new_id] = {
        "id": new_id,
        "type": type,
        "stability": randf_range(40.0, 90.0),
        "energy": randf_range(40.0, 95.0),
        "alignment": randf_range(-80.0, 80.0),
        "synchronization": randf_range(30.0, 90.0),
        "core_element": ["Aether", "Chronos", "Void", "Light", "Shadow", "Nexus", "Quantum"][randi() % 7],
        "entities": 0,
        "description": "A " + type.to_lower() + " universe discovered during cosmic turn " + str(cosmic_turn) + ".",
        "created_turn": cosmic_turn,
        "last_visited": 0
    }
    
    # Create connection to current universe
    connections.append({
        "from": current_universe_id,
        "to": new_id,
        "stability": randf_range(50.0, 85.0),
        "created_turn": cosmic_turn,
        "strength": randf_range(0.5, 0.8)
    })
    
    # Add to access points
    access_points.append({
        "from": current_universe_id,
        "to": new_id,
        "discovered": true,
        "distance": randf_range(20.0, 60.0)
    })
    
    # Emit signal
    emit_signal("access_point_discovered", new_id)

func travel_to_universe(universe_id):
    # Check if universe exists
    if not universes.has(universe_id):
        push_error("Cannot travel to non-existent universe: " + universe_id)
        return false
    
    # Check if we have a valid access point to this universe
    var has_access = false
    for ap in access_points:
        if ap.from == current_universe_id and ap.to == universe_id and ap.discovered:
            has_access = true
            break
    
    if not has_access:
        push_error("No valid access point to universe: " + universe_id)
        return false
    
    # Update last visited on current universe
    if universes.has(current_universe_id):
        universes[current_universe_id].last_visited = cosmic_turn
    
    # Update current universe
    var old_universe = current_universe_id
    current_universe_id = universe_id
    
    # Update last visited on new universe
    universes[current_universe_id].last_visited = cosmic_turn
    
    # Update access points based on new universe
    update_access_points_from_current_universe()
    
    # Emit signal
    emit_signal("universe_changed", universe_id)
    
    # Update UI if it exists
    if ui_instance:
        ui_instance.load_universe_data()
    
    return true

func update_access_points_from_current_universe():
    # Clear existing access points
    access_points.clear()
    
    # Find all connections from current universe
    for connection in connections:
        if connection.from == current_universe_id:
            access_points.append({
                "from": current_universe_id,
                "to": connection.to,
                "discovered": true,
                "distance": randf_range(10.0, 50.0)
            })
        elif connection.to == current_universe_id:
            access_points.append({
                "from": current_universe_id,
                "to": connection.from,
                "discovered": true,
                "distance": randf_range(10.0, 50.0)
            })
    
    # Add a small chance of discovering a new universe
    if randf() > 0.7:
        discover_new_access_point()

func get_current_universe_data():
    if universes.has(current_universe_id):
        return universes[current_universe_id]
    return null

func get_universe_data(universe_id):
    if universes.has(universe_id):
        return universes[universe_id]
    return null

func get_access_points():
    return access_points

func get_cosmic_turn():
    return cosmic_turn

func get_cosmic_age():
    return cosmic_age

func get_metanarrative_progress():
    return metanarrative_progress