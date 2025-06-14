extends Node
class_name WishDimensionDemo

"""
Wish Dimension Demo
-------------------
Demonstrates the integration between the Wish Knowledge System
and the 12-Dimensional Data Processing System.

This demo showcases how wishes can be processed, transformed,
and manifested across different dimensional planes.
"""

# Core systems
var wish_system: WishKnowledgeSystem
var dimensional_bridge: DimensionalDataBridge
var wish_connector: WishDimensionalConnector

# Demo state
var current_dimension = "AWARENESS"
var demo_wishes = [
    "Create a magical sword that can freeze enemies",
    "Design a living forest that evolves based on visitor emotions",
    "Build a time-shifting puzzle that changes its structure over time",
    "Manifest a companion creature that reflects the user's mood",
    "Form a crystal that resonates with the user's thoughts",
    "Develop a harmony sphere that balances energies in its vicinity",
    "Generate a consciousness mesh that enhances user awareness",
    "Create a mirror realm that reflects but transforms visitor actions",
    "Design a purposeful path that guides users toward their intentions",
    "Build a genesis engine that produces unique worlds from ideas",
    "Form an integration nexus that combines disparate elements",
    "Manifest a transcendent gate that enables travel beyond normal space"
]

var processed_elements = {}
var dimension_results = {}

# UI references
var dimension_selector
var wish_input
var process_button
var results_display
var dimension_chain_input
var process_chain_button

# Demo initialization
func _ready():
    # Initialize core systems
    _init_systems()
    
    # Setup UI
    _setup_ui()
    
    # Connect signals
    _connect_signals()
    
    # Set initial dimension
    _set_dimension(current_dimension)
    
    print("Wish Dimension Demo initialized")

# Initialize core systems
func _init_systems():
    # Create core systems
    wish_system = WishKnowledgeSystem.new()
    add_child(wish_system)
    
    dimensional_bridge = DimensionalDataBridge.new()
    add_child(dimensional_bridge)
    
    # Initialize systems
    wish_system.initialize()
    
    # Create connector
    wish_connector = WishDimensionalConnector.new(wish_system, dimensional_bridge)
    add_child(wish_connector)

# Setup UI elements
func _setup_ui():
    # In a real implementation, this would create UI controls
    # For this demo, we'll simulate UI through console
    print("\n----- WISH DIMENSION DEMO -----")
    print("Available commands:")
    print("  dimension <dimension_name> - Change current dimension")
    print("  process <wish_text> - Process a wish in current dimension")
    print("  chain <wish_text> <dim1,dim2,...> - Process through dimension chain")
    print("  transform <element_id> <dimension> - Transform element to new dimension")
    print("  influence <element_id> <dimension> <strength> - Apply dimensional influence")
    print("  list - List processed elements")
    print("  help - Show this help message")
    print("  examples - Show example wishes for each dimension")
    print("-------------------------------")

# Connect signals
func _connect_signals():
    wish_connector.dimension_detected.connect(_on_dimension_detected)
    wish_connector.wish_transformed.connect(_on_wish_transformed)
    wish_connector.element_generated.connect(_on_element_generated)

# Set current dimension
func _set_dimension(dimension: String):
    dimensional_bridge.set_dimension_by_name(dimension)
    current_dimension = dimension
    print("\nCurrent dimension set to: " + dimension)

# Process wish in current dimension
func process_wish(wish_text: String):
    print("\nProcessing wish: \"" + wish_text + "\" in dimension " + current_dimension)
    
    var element_id = wish_connector.process_dimensional_wish(wish_text)
    var element = wish_system.get_element(element_id)
    
    # Store processed element
    processed_elements[element_id] = {
        "element": element,
        "original_wish": wish_text,
        "dimension": current_dimension
    }
    
    # Store in dimension results
    if not dimension_results.has(current_dimension):
        dimension_results[current_dimension] = []
    dimension_results[current_dimension].append(element_id)
    
    # Display results
    _display_element_details(element)
    
    return element_id

# Process wish through dimension chain
func process_wish_chain(wish_text: String, dimension_chain: Array):
    print("\nProcessing wish through dimension chain:")
    print("  Wish: \"" + wish_text + "\"")
    print("  Chain: " + str(dimension_chain))
    
    var element_id = wish_connector.process_wish_through_dimensions(wish_text, dimension_chain)
    var element = wish_system.get_element(element_id)
    
    # Store processed element
    processed_elements[element_id] = {
        "element": element,
        "original_wish": wish_text,
        "dimension_chain": dimension_chain
    }
    
    # Store in final dimension results
    var final_dimension = dimension_chain[-1]
    if not dimension_results.has(final_dimension):
        dimension_results[final_dimension] = []
    dimension_results[final_dimension].append(element_id)
    
    # Display results
    _display_element_details(element)
    
    return element_id

# Transform element to different dimension
func transform_element(element_id: String, target_dimension: String):
    print("\nTransforming element " + element_id + " to dimension " + target_dimension)
    
    var transformed_element = wish_connector.transform_element_to_dimension(element_id, target_dimension)
    
    if transformed_element:
        # Generate new ID for transformed element
        var new_id = WishKnowledgeSystem.generate_unique_id()
        
        # Store transformed element
        processed_elements[new_id] = {
            "element": transformed_element,
            "transformed_from": element_id,
            "original_dimension": processed_elements[element_id].dimension if processed_elements.has(element_id) else "UNKNOWN",
            "dimension": target_dimension
        }
        
        # Store in dimension results
        if not dimension_results.has(target_dimension):
            dimension_results[target_dimension] = []
        dimension_results[target_dimension].append(new_id)
        
        # Display results
        _display_element_details(transformed_element)
        
        return new_id
    
    print("Failed to transform element")
    return ""

# Apply dimensional influence
func apply_influence(element_id: String, influence_dimension: String, strength: float = 0.5):
    print("\nApplying " + influence_dimension + " influence (strength: " + str(strength) + ") to element " + element_id)
    
    var success = wish_connector.apply_dimensional_influence(element_id, influence_dimension, strength)
    
    if success:
        var element = wish_system.get_element(element_id)
        
        # Update processed element
        processed_elements[element_id].influenced_by = influence_dimension
        processed_elements[element_id].influence_strength = strength
        
        # Display updated element
        _display_element_details(element)
        
        return true
    
    print("Failed to apply influence")
    return false

# List all processed elements
func list_elements():
    print("\nProcessed Elements:")
    print("-------------------")
    
    if processed_elements.size() == 0:
        print("No elements processed yet")
        return
    
    for element_id in processed_elements:
        var info = processed_elements[element_id]
        var element = info.element
        
        print(element_id + ": " + element.name)
        print("  Type: " + _get_element_type_name(element.type))
        print("  Dimension: " + (info.dimension if info.has("dimension") else "UNKNOWN"))
        
        if info.has("original_wish"):
            print("  Original Wish: \"" + info.original_wish + "\"")
        
        if info.has("dimension_chain"):
            print("  Dimension Chain: " + str(info.dimension_chain))
        
        if info.has("transformed_from"):
            print("  Transformed From: " + info.transformed_from)
        
        if info.has("influenced_by"):
            print("  Influenced By: " + info.influenced_by + " (Strength: " + str(info.influence_strength) + ")")
        
        print("")

# Show example wishes
func show_examples():
    print("\nExample Wishes for Each Dimension:")
    print("--------------------------------")
    
    for i in range(demo_wishes.size()):
        var dimension = wish_connector.DIMENSIONAL_KEYWORDS.keys()[i]
        var wish = demo_wishes[i]
        
        print(dimension + ": \"" + wish + "\"")

# Display element details
func _display_element_details(element):
    print("\nElement Details:")
    print("  ID: " + element.id)
    print("  Name: " + element.name)
    print("  Type: " + _get_element_type_name(element.type))
    print("  Description: " + element.description)
    print("  Dimensional Plane: " + _get_dimension_name_by_id(element.dimensional_plane))
    print("  Implementation Difficulty: " + _get_difficulty_name(element.implementation_difficulty))
    
    if element.properties.size() > 0:
        print("  Properties:")
        for prop in element.properties:
            print("    - " + prop + ": " + str(element.properties[prop]))
    
    # In a real UI, we would display more details

# Helper: Get element type name
func _get_element_type_name(type_id: int) -> String:
    match type_id:
        WishKnowledgeSystem.ElementType.CHARACTER: return "CHARACTER"
        WishKnowledgeSystem.ElementType.LOCATION: return "LOCATION"
        WishKnowledgeSystem.ElementType.ITEM: return "ITEM"
        WishKnowledgeSystem.ElementType.ABILITY: return "ABILITY"
        WishKnowledgeSystem.ElementType.QUEST: return "QUEST"
        WishKnowledgeSystem.ElementType.STORYLINE: return "STORYLINE"
        WishKnowledgeSystem.ElementType.MECHANIC: return "MECHANIC"
        WishKnowledgeSystem.ElementType.RULE: return "RULE"
        WishKnowledgeSystem.ElementType.VISUAL: return "VISUAL"
        WishKnowledgeSystem.ElementType.AUDIO: return "AUDIO"
        WishKnowledgeSystem.ElementType.INTERACTION: return "INTERACTION"
        WishKnowledgeSystem.ElementType.SYSTEM: return "SYSTEM"
        _: return "UNKNOWN"

# Helper: Get dimension name by ID
func _get_dimension_name_by_id(dimension_id: int) -> String:
    match dimension_id:
        WishKnowledgeSystem.DimensionalPlane.REALITY: return "REALITY (ESSENCE)"
        WishKnowledgeSystem.DimensionalPlane.LINEAR: return "LINEAR (ENERGY)"
        WishKnowledgeSystem.DimensionalPlane.SPATIAL: return "SPATIAL (SPACE)"
        WishKnowledgeSystem.DimensionalPlane.TEMPORAL: return "TEMPORAL (TIME)"
        WishKnowledgeSystem.DimensionalPlane.CONSCIOUS: return "CONSCIOUS (FORM)"
        WishKnowledgeSystem.DimensionalPlane.CONNECTION: return "CONNECTION (HARMONY)"
        WishKnowledgeSystem.DimensionalPlane.CREATION: return "CREATION (AWARENESS)"
        WishKnowledgeSystem.DimensionalPlane.NETWORK: return "NETWORK (REFLECTION)"
        WishKnowledgeSystem.DimensionalPlane.HARMONY: return "HARMONY (INTENT)"
        WishKnowledgeSystem.DimensionalPlane.UNITY: return "UNITY (GENESIS)"
        WishKnowledgeSystem.DimensionalPlane.TRANSCENDENT: return "TRANSCENDENT (SYNTHESIS)"
        WishKnowledgeSystem.DimensionalPlane.BEYOND: return "BEYOND (TRANSCENDENCE)"
        _: return "UNKNOWN"

# Helper: Get difficulty name
func _get_difficulty_name(difficulty_id: int) -> String:
    match difficulty_id:
        WishKnowledgeSystem.ImplementationDifficulty.TRIVIAL: return "TRIVIAL"
        WishKnowledgeSystem.ImplementationDifficulty.EASY: return "EASY"
        WishKnowledgeSystem.ImplementationDifficulty.MODERATE: return "MODERATE"
        WishKnowledgeSystem.ImplementationDifficulty.CHALLENGING: return "CHALLENGING"
        WishKnowledgeSystem.ImplementationDifficulty.DIFFICULT: return "DIFFICULT"
        WishKnowledgeSystem.ImplementationDifficulty.VERY_DIFFICULT: return "VERY_DIFFICULT"
        WishKnowledgeSystem.ImplementationDifficulty.GROUNDBREAKING: return "GROUNDBREAKING"
        _: return "UNKNOWN"

# Signal handlers
func _on_dimension_detected(wish_text, dimension):
    print("Dimensional alignment detected: " + dimension)

func _on_wish_transformed(original_wish, transformed_wish, dimension):
    print("Wish transformed for dimension " + dimension + ":")
    print("  Original: \"" + original_wish + "\"")
    print("  Transformed: \"" + transformed_wish + "\"")

func _on_element_generated(element_id, dimension):
    print("Element generated in dimension " + dimension + ": " + element_id)

# Demo function to run examples
func run_demo_examples():
    # Process example wishes in their corresponding dimensions
    for i in range(demo_wishes.size()):
        var dimension = wish_connector.DIMENSIONAL_KEYWORDS.keys()[i]
        var wish = demo_wishes[i]
        
        # Set dimension
        _set_dimension(dimension)
        
        # Process wish
        process_wish(wish)
    
    # Show dimension chain example
    _set_dimension("ESSENCE")
    process_wish_chain(
        "Create a magical temple that evolves with its visitors",
        ["ESSENCE", "FORM", "AWARENESS", "TRANSCENDENCE"]
    )
    
    # Show transformation example
    if dimension_results.has("ESSENCE") and dimension_results.ESSENCE.size() > 0:
        var element_id = dimension_results.ESSENCE[0]
        transform_element(element_id, "TRANSCENDENCE")
    
    # Show influence example
    if dimension_results.has("SPACE") and dimension_results.SPACE.size() > 0:
        var element_id = dimension_results.SPACE[0]
        apply_influence(element_id, "TIME", 0.7)
    
    # List all processed elements
    list_elements()

# Command-line interface for the demo (simplified)
func process_command(command: String):
    var parts = command.split(" ", false)
    
    if parts.size() == 0:
        return
    
    var cmd = parts[0].to_lower()
    
    match cmd:
        "dimension":
            if parts.size() > 1:
                var dimension = parts[1].to_upper()
                _set_dimension(dimension)
            else:
                print("Please specify a dimension name")
        
        "process":
            if parts.size() > 1:
                var wish_text = command.substr(command.find(" ") + 1)
                process_wish(wish_text)
            else:
                print("Please specify a wish to process")
        
        "chain":
            if parts.size() > 2:
                var wish_text = command.substr(command.find(" ") + 1)
                var chain_start = wish_text.rfind(" ")
                var dimension_chain_text = wish_text.substr(chain_start + 1)
                wish_text = wish_text.substr(0, chain_start)
                
                var dimension_chain = dimension_chain_text.split(",", false)
                for i in range(dimension_chain.size()):
                    dimension_chain[i] = dimension_chain[i].strip_edges().to_upper()
                
                process_wish_chain(wish_text, dimension_chain)
            else:
                print("Please specify a wish and dimension chain")
        
        "transform":
            if parts.size() > 2:
                var element_id = parts[1]
                var dimension = parts[2].to_upper()
                transform_element(element_id, dimension)
            else:
                print("Please specify element ID and target dimension")
        
        "influence":
            if parts.size() > 2:
                var element_id = parts[1]
                var dimension = parts[2].to_upper()
                var strength = 0.5
                if parts.size() > 3:
                    strength = float(parts[3])
                
                apply_influence(element_id, dimension, strength)
            else:
                print("Please specify element ID and influence dimension")
        
        "list":
            list_elements()
        
        "examples":
            show_examples()
        
        "demo":
            run_demo_examples()
        
        "help":
            _setup_ui()
        
        _:
            print("Unknown command: " + cmd)
            print("Type 'help' for available commands")

# Example usage:
# var demo = WishDimensionDemo.new()
# add_child(demo)
# demo.process_command("dimension CREATION")
# demo.process_command("process Create a magical sword that freezes enemies")
# demo.process_command("list")
# demo.process_command("demo")