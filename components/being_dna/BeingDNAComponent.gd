# ==================================================
# UNIVERSAL BEING COMPONENT: Being DNA
# PURPOSE: Visual DNA system for Universal Beings
# COMPONENTS: None (base component)
# SCENES: res://components/being_dna/dna_visualizer.tscn
# ==================================================

extends Component
class_name BeingDNAComponent

# ===== DNA SYSTEM =====

## DNA Structure
var dna_helix: Node2D = null
var dna_traits: Dictionary = {
    "physical": {
        "form": 0.5,  # 0.0 = abstract, 1.0 = concrete
        "density": 0.5,  # 0.0 = ethereal, 1.0 = solid
        "elasticity": 0.5,  # 0.0 = rigid, 1.0 = fluid
        "resonance": 0.5  # 0.0 = silent, 1.0 = harmonic
    },
    "consciousness": {
        "awareness": 0.5,  # 0.0 = dormant, 1.0 = awakened
        "creativity": 0.5,  # 0.0 = static, 1.0 = dynamic
        "harmony": 0.5,  # 0.0 = chaotic, 1.0 = ordered
        "evolution": 0.5  # 0.0 = stable, 1.0 = evolving
    },
    "interaction": {
        "receptivity": 0.5,  # 0.0 = closed, 1.0 = open
        "expression": 0.5,  # 0.0 = silent, 1.0 = vocal
        "connection": 0.5,  # 0.0 = isolated, 1.0 = networked
        "transformation": 0.5  # 0.0 = fixed, 1.0 = fluid
    },
    "essence": {
        "purpose": 0.5,  # 0.0 = undefined, 1.0 = defined
        "potential": 0.5,  # 0.0 = limited, 1.0 = infinite
        "wisdom": 0.5,  # 0.0 = naive, 1.0 = enlightened
        "harmony": 0.5  # 0.0 = discordant, 1.0 = resonant
    }
}

## DNA Evolution
var evolution_path: Array[String] = []
var evolution_history: Array[Dictionary] = []
var evolution_potential: Dictionary = {}
var mutation_rate: float = 0.1

## Visual State
var helix_visible: bool = true
var helix_animation_speed: float = 1.0
var helix_scale: float = 1.0
var helix_opacity: float = 0.8

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
    super.pentagon_init()
    component_name = "being_dna"
    component_version = "1.0.0"
    component_description = "Visual DNA system for Universal Beings"
    print("🧬 BeingDNA: Pentagon Init Complete")

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Create DNA visualizer
    create_dna_visualizer()
    
    # Initialize evolution potential
    calculate_evolution_potential()
    
    print("🧬 BeingDNA: Pentagon Ready Complete")

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Update DNA visualization
    if dna_helix and helix_visible:
        update_dna_visualization(delta)

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    # Handle DNA interaction
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            handle_dna_click(event.position)

func pentagon_sewers() -> void:
    # Save DNA state
    save_dna_state()
    
    # Cleanup visualizer
    if dna_helix:
        dna_helix.queue_free()
        dna_helix = null
    
    super.pentagon_sewers()

# ===== DNA VISUALIZATION =====

func create_dna_visualizer() -> void:
    # Create the DNA helix visualizer
    var visualizer_scene = load("res://components/being_dna/dna_visualizer.tscn")
    if visualizer_scene:
        dna_helix = visualizer_scene.instantiate()
        if parent_being:
            parent_being.add_child(dna_helix)
            # Handle both 2D and 3D parent beings
            if parent_being is Node2D:
                dna_helix.global_position = parent_being.global_position
            elif parent_being is Node3D:
                # Convert 3D position to 2D for the DNA helix
                dna_helix.global_position = Vector2(parent_being.global_position.x, parent_being.global_position.y)
            else:
                dna_helix.position = Vector2.ZERO
            dna_helix.scale = Vector2.ONE * helix_scale
            dna_helix.modulate.a = helix_opacity
            print("🧬 BeingDNA: Visualizer created")

func update_dna_visualization(delta: float) -> void:
    # Update DNA helix animation and appearance
    if not dna_helix:
        return
    
    # Update helix animation
    dna_helix.rotation += delta * helix_animation_speed
    
    # Update trait colors
    for category_key in dna_traits.keys():
        var category_data = dna_traits[category_key]
        for trait_key in category_data.keys():
            var trait_value = category_data[trait_key]
            update_trait_visualization(category_key, trait_key, trait_value)

func update_trait_visualization(category_key: String, trait_key: String, trait_value: float) -> void:
    # Update visual representation of a trait
    if not dna_helix or not dna_helix.has_method("update_trait"):
        return
    
    # Convert trait value to color
    var trait_color = get_trait_color(category_key, trait_key, trait_value)
    dna_helix.update_trait(category_key, trait_key, trait_color)

func get_trait_color(category_key: String, trait_key: String, trait_value: float) -> Color:
    # Get color representation of trait value
    var base_colors = {
        "physical": Color(0.2, 0.8, 0.2),  # Green
        "consciousness": Color(0.8, 0.2, 0.8),  # Purple
        "interaction": Color(0.2, 0.2, 0.8),  # Blue
        "essence": Color(0.8, 0.8, 0.2)  # Yellow
    }
    
    var base_color = base_colors.get(category_key, Color.WHITE)
    return base_color.lightened(trait_value)

# ===== DNA EVOLUTION =====

func calculate_evolution_potential() -> void:
    # Calculate potential evolution paths based on current DNA
    evolution_potential.clear()
    
    # Analyze current traits
    for category_name in dna_traits:
        for trait_name in dna_traits[category_name]:
            var value = dna_traits[category_name][trait_name]
            var potential = calculate_trait_potential(category_name, trait_name, value)
            evolution_potential[category_name + "." + trait_name] = potential

func calculate_trait_potential(category: String, trait_name: String, value: float) -> Dictionary:
    # Calculate evolution potential for a trait
    var potential = {
        "current": value,
        "min": 0.0,
        "max": 1.0,
        "mutation_rate": mutation_rate,
        "evolution_paths": []
    }
    
    # Add possible evolution paths
    if value < 0.5:
        potential.evolution_paths.append({
            "direction": "increase",
            "probability": 1.0 - value,
            "description": "Evolve towards higher " + trait_name
        })
    if value > 0.5:
        potential.evolution_paths.append({
            "direction": "decrease",
            "probability": value,
            "description": "Evolve towards lower " + trait_name
        })
    
    return potential

func evolve_trait(category: String, trait_name: String, direction: String) -> bool:
    # Evolve a specific trait
    if not dna_traits.has(category) or not dna_traits[category].has(trait_name):
        return false
    
    var current_value = dna_traits[category][trait_name]
    var change = mutation_rate * (1.0 if direction == "increase" else -1.0)
    var new_value = clamp(current_value + change, 0.0, 1.0)
    
    # Record evolution
    evolution_history.append({
        "category": category,
        "trait": trait_name,
        "old_value": current_value,
        "new_value": new_value,
        "direction": direction,
        "timestamp": Time.get_unix_time_from_system()
    })
    
    # Update trait value
    dna_traits[category][trait_name] = new_value
    
    # Update visualization
    update_trait_visualization(category, trait_name, new_value)
    
    # Recalculate potential
    calculate_evolution_potential()
    
    # Notify parent being
    if parent_being and parent_being.has_method("on_dna_evolved"):
        parent_being.on_dna_evolved(category, trait_name, current_value, new_value)
    
    print("🧬 BeingDNA: Trait evolved - %s.%s: %.2f → %.2f" % [
        category, trait_name, current_value, new_value
    ])
    
    return true

# ===== DNA STATE MANAGEMENT =====

func save_dna_state() -> void:
    # Save current DNA state to component data
    component_data["dna_traits"] = dna_traits
    component_data["evolution_history"] = evolution_history
    component_data["evolution_potential"] = evolution_potential
    
    # Save to Akashic Records if available
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        var akashic = SystemBootstrap.get_akashic_records()
        if akashic and akashic.has_method("log_dna_evolution"):
            akashic.log_dna_evolution(parent_being, dna_traits, evolution_history)

func load_dna_state() -> void:
    # Load DNA state from component data
    if component_data.has("dna_traits"):
        dna_traits = component_data["dna_traits"]
    if component_data.has("evolution_history"):
        evolution_history = component_data["evolution_history"]
    if component_data.has("evolution_potential"):
        evolution_potential = component_data["evolution_potential"]

# ===== DNA INTERACTION =====

func handle_dna_click(position: Vector2) -> void:
    # Handle click on DNA visualization
    if not dna_helix:
        return
    
    # Check if click is on a trait
    var clicked_trait = dna_helix.get_trait_at_position(position)
    if clicked_trait:
        var category = clicked_trait.get("category", "")
        var trait_name = clicked_trait.get("trait", "")
        var value = clicked_trait.get("value", 0.5)
        
        # Show evolution options
        show_evolution_options(category, trait_name, value)

func show_evolution_options(category: String, trait_name: String, value: float) -> void:
    # Show available evolution options for a trait
    var potential = evolution_potential.get(category + "." + trait_name, {})
    if potential.is_empty():
        return
    
    # Create evolution menu
    var menu = create_evolution_menu(category, trait_name, potential)
    if menu and parent_being:
        parent_being.add_child(menu)
        menu.global_position = get_viewport().get_mouse_position()

func create_evolution_menu(category: String, trait_name: String, potential: Dictionary) -> Control:
    # Create menu for trait evolution options
    var menu_scene = load("res://components/being_dna/evolution_menu.tscn")
    if not menu_scene:
        return null
    
    var menu = menu_scene.instantiate()
    if menu.has_method("setup_evolution_options"):
        menu.setup_evolution_options(category, trait_name, potential, self)
    
    return menu

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    # Provide AI interface for DNA manipulation
    return {
        "component_type": "being_dna",
        "version": component_version,
        "traits": dna_traits,
        "evolution_potential": evolution_potential,
        "methods": {
            "evolve_trait": Callable(self, "evolve_trait"),
            "get_trait_value": Callable(self, "get_trait_value"),
            "calculate_potential": Callable(self, "calculate_evolution_potential")
        }
    }

func get_trait_value(category: String, trait_name: String) -> float:
    # Get current value of a trait
    if dna_traits.has(category) and dna_traits[category].has(trait_name):
        return dna_traits[category][trait_name]
    return 0.5  # Default value
