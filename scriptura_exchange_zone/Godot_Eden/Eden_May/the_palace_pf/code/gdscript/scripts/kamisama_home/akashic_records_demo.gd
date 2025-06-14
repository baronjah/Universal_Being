# Akashic Records Demo Script
# This script demonstrates basic usage of the Akashic Records system

extends Node

# Reference to the Akashic Records integration
var akashic_records = null

func _ready():
    # Get the Akashic Records integration from the main scene
    # Replace 'get_node("/root/Main")' with the actual path to your main scene
    var main = get_node("/root/Main")
    akashic_records = main.get_akashic_records()
    
    if akashic_records:
        print("Akashic Records Demo: Connected to system")
        create_demo_entries()
    else:
        push_error("Akashic Records Demo: Could not connect to system")

func create_demo_entries():
    # Create demo entries in the dictionary
    print("Creating demo dictionary entries...")
    
    # Basic Element: Water
    akashic_records.create_word(
        "water", 
        "element", 
        {
            "state": "liquid",
            "temperature": 20,
            "color": "blue",
            "properties": {
                "can_flow": true,
                "can_freeze": true,
                "can_evaporate": true
            }
        }
    )
    
    # Basic Element: Fire
    akashic_records.create_word(
        "fire", 
        "element", 
        {
            "state": "plasma",
            "temperature": 500,
            "color": "orange",
            "properties": {
                "can_spread": true,
                "requires_fuel": true,
                "emits_light": true
            }
        }
    )
    
    # Derived Element: Steam (child of Water)
    akashic_records.create_word(
        "steam", 
        "element", 
        {
            "state": "gas",
            "temperature": 100,
            "color": "white",
            "properties": {
                "can_flow": true,
                "can_condense": true,
                "visibility": "partial"
            }
        },
        "water"  # Parent ID
    )
    
    # Entity: Tree
    akashic_records.create_word(
        "tree", 
        "entity", 
        {
            "height": 5,
            "age": 50,
            "material": "wood",
            "properties": {
                "can_grow": true,
                "can_burn": true,
                "produces_oxygen": true
            }
        }
    )
    
    # Test an interaction between fire and tree
    var interaction_result = akashic_records.process_interaction(
        "fire", 
        "tree", 
        {"intensity": 0.8, "duration": 10}
    )
    
    print("Interaction result: ", interaction_result)
    
    # Save all entries
    var save_result = akashic_records.save_all()
    print("Save result: ", save_result)
    
    print("Demo entries created and saved")

# For manual testing, you can call this function to add more entries
func add_test_entry(id: String, category: String, properties: Dictionary = {}):
    if akashic_records:
        var result = akashic_records.create_word(id, category, properties)
        if result:
            print("Created word: " + id)
        else:
            print("Failed to create word: " + id)
    else:
        print("Akashic Records not available")