extends Node
class_name UniversalBridge

# System references
var akashic_records_manager: Node = null
var jsh_records_system: Node = null
var jsh_database_system: Node = null
var interaction_matrix: Node = null
var element_manager: Node = null
var thing_creator: Node = null

# Signals
signal entity_created(entity)
signal entity_transformed(entity, old_type, new_type)
signal entity_interaction(entity1, entity2, result)

func _ready() -> void:
    # Load the interaction matrix
    var InteractionMatrix = load("res://interaction_matrix.gd")
    interaction_matrix = InteractionMatrix.new()
    add_child(interaction_matrix)

    # Find the element manager, defer if tree is not ready
    find_element_manager()

# Safe method to find nodes in a group
func find_nodes_in_group_safe(group_name: String) -> Array:
    var nodes = []
    var tree = get_tree()
    if tree != null:
        nodes = tree.get_nodes_in_group(group_name)
    return nodes

# Find the element manager
func find_element_manager() -> void:
    if not is_inside_tree():
        # Defer the call if not in tree yet
        call_deferred("find_element_manager")
        return

    var nodes = find_nodes_in_group_safe("element_manager")
    if nodes.size() > 0:
        element_manager = nodes[0]
        print("UniversalBridge: Found element manager")
    else:
        print("UniversalBridge: Element manager not found")

# Safely access element manager functionality
func apply_element_effect(entity: Node, element_type: String) -> bool:
    if element_manager == null:
        print("UniversalBridge: Cannot apply element effect - element manager not found")
        return false

    # Check if the element manager has the apply_element method
    if element_manager.has_method("apply_element"):
        return element_manager.apply_element(entity, element_type)

    print("UniversalBridge: Element manager does not have apply_element method")
    return false

func initialize(records_manager: Node, records_system: Node, database_system: Node) -> void:
    akashic_records_manager = records_manager
    jsh_records_system = records_system
    jsh_database_system = database_system

    # Try to find element manager if we haven't already
    if element_manager == null:
        find_element_manager()

    print("UniversalBridge: Initialized with system references")

# Entity creation and management
func create_entity(type: String = "primordial", properties: Dictionary = {}) -> Node:
    print("UniversalBridge: Creating entity of type: ", type)
    
    # Load the UniversalEntity class
    var UniversalEntity = load("res://universal_entity.gd")
    
    # Create the entity
    var entity = UniversalEntity.new("", type, properties)
    
    # Register with Akashic Records Manager
    if akashic_records_manager != null:
        akashic_records_manager.register_entity(entity)
    
    # Emit signal
    emit_signal("entity_created", entity)
    
    return entity

func transform_entity(entity: Node, new_type: String) -> bool:
    print("UniversalBridge: Transforming entity ", entity.get_id(), " to ", new_type)
    
    if entity == null or not entity is UniversalEntity:
        print("UniversalBridge: Invalid entity for transformation")
        return false
    
    var old_type = entity.get_type()
    
    # Perform the transformation
    var success = entity.transform(new_type)
    
    if success:
        # Update in Akashic Records Manager
        if akashic_records_manager != null:
            akashic_records_manager.update_entity_type(entity.get_id(), new_type)
        
        # Emit signal
        emit_signal("entity_transformed", entity, old_type, new_type)
    
    return success

# Interaction processing
func process_interaction(entity1: Node, entity2: Node) -> Dictionary:
    print("UniversalBridge: Processing interaction between entities")
    
    if entity1 == null or entity2 == null or not entity1 is UniversalEntity or not entity2 is UniversalEntity:
        print("UniversalBridge: Invalid entities for interaction")
        return {"success": false, "effect": "invalid_entities"}
    
    # Get entity types
    var type1 = entity1.get_type()
    var type2 = entity2.get_type()
    
    # Get interaction effect from matrix
    var effect = "none"
    if interaction_matrix != null:
        effect = interaction_matrix.get_interaction_effect(type1, type2)
    
    print("UniversalBridge: Interaction effect: ", effect)
    
    # Process the interaction effect
    var result = process_interaction_effect(entity1, entity2, effect)
    
    # Emit signal
    emit_signal("entity_interaction", entity1, entity2, result)
    
    return result

func process_interaction_effect(entity1: Node, entity2: Node, effect: String) -> Dictionary:
    # Base result structure
    var result = {
        "success": true,
        "effect": effect,
        "source_entity": entity1,
        "target_entity": entity2,
        "source_type": entity1.get_type(),
        "target_type": entity2.get_type(),
        "transformations": [],
        "new_entities": []
    }

    # Process different effects
    match effect:
        "none":
            # No effect
            result["success"] = true
        
        "intensify":
            # Intensify the source entity
            var intensity = entity1.get_property("intensity", 1)
            entity1.set_property("intensity", intensity + 1)
        
        "diminish":
            # Diminish the target entity
            var intensity = entity2.get_property("intensity", 1)
            entity2.set_property("intensity", max(1, intensity - 1))
        
        "consume":
            # Source consumes target
            var energy1 = entity1.get_property("energy", 10)
            var energy2 = entity2.get_property("energy", 5)
            
            # Transfer energy
            entity1.set_property("energy", energy1 + energy2)
            entity2.set_property("energy", 0)
            
            # Transform target to "consumed"
            if transform_entity(entity2, "consumed"):
                result["transformations"].append({
                    "entity": entity2,
                    "from": result["target_type"],
                    "to": "consumed"
                })
        
        "fuse":
            # Fuse both entities into a new one
            var new_entity = create_entity("fused", {
                "energy": entity1.get_property("energy", 10) + entity2.get_property("energy", 10),
                "parent_entities": [entity1.get_id(), entity2.get_id()]
            })
            
            result["new_entities"].append(new_entity)
            
            # Add references
            entity1.add_reference("fused_into", new_entity.get_id())
            entity2.add_reference("fused_into", new_entity.get_id())
        
        "transform":
            # Transform source entity based on target
            var new_type = "transformed_" + entity1.get_type()
            
            if transform_entity(entity1, new_type):
                result["transformations"].append({
                    "entity": entity1,
                    "from": result["source_type"],
                    "to": new_type
                })
        
        "split":
            # Split the target entity into two
            var new_entity1 = create_entity(entity2.get_type(), {
                "energy": entity2.get_property("energy", 10) / 2,
                "parent_entity": entity2.get_id()
            })
            
            var new_entity2 = create_entity(entity2.get_type(), {
                "energy": entity2.get_property("energy", 10) / 2,
                "parent_entity": entity2.get_id()
            })
            
            result["new_entities"].append(new_entity1)
            result["new_entities"].append(new_entity2)
            
            # Update the original entity
            entity2.set_property("energy", 1)
            entity2.add_reference("split_into", new_entity1.get_id())
            entity2.add_reference("split_into", new_entity2.get_id())
        
        "transmute":
            # Both entities transform into new types
            var new_type1 = "transmuted_" + entity1.get_type()
            var new_type2 = "transmuted_" + entity2.get_type()
            
            if transform_entity(entity1, new_type1):
                result["transformations"].append({
                    "entity": entity1,
                    "from": result["source_type"],
                    "to": new_type1
                })
            
            if transform_entity(entity2, new_type2):
                result["transformations"].append({
                    "entity": entity2,
                    "from": result["target_type"],
                    "to": new_type2
                })
        
        "create":
            # Create a new entity from the interaction
            var new_type = entity1.get_type() + "_" + entity2.get_type()
            var new_entity = create_entity(new_type, {
                "energy": (entity1.get_property("energy", 10) + entity2.get_property("energy", 10)) / 2,
                "parent_entities": [entity1.get_id(), entity2.get_id()]
            })
            
            result["new_entities"].append(new_entity)
            
            # Add references
            entity1.add_reference("created", new_entity.get_id())
            entity2.add_reference("created", new_entity.get_id())
        
        _:
            # Unknown effect
            result["success"] = false
            result["effect"] = "unknown_effect"
    
    return result