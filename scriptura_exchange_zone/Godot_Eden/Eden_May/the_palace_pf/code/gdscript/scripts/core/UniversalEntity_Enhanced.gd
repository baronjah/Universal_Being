class_name CoreUniversalEntity
extends Node3D

# ----- CORE IDENTITY PROPERTIES -----
var entity_id: String = ""
var source_word: String = ""
var entity_type: String = "primordial"
var manifestation_level: float = 0.0  # 0.0 = potential, 1.0 = fully manifested

# ----- FORM AND PROPERTIES -----
var current_form: String = "seed"
var properties: Dictionary = {}
var evolution_stage: int = 0
var creation_timestamp: String = ""
var transformation_history: Array = []
var references: Dictionary = {}

# ----- COMPLEXITY AND EVOLUTION -----
var complexity: float = 0.0
var parent_entities: Array = []
var child_entities: Array = []
var last_processed_time: int = 0
var should_split: bool = false
var metadata: Dictionary = {}
var tags: Array = []
var zones: Array = []

# ----- RELATIONSHIPS -----
var parent_entity = null
var connected_entities = []

# ----- REALITY CONTEXT -----
var reality_context: String = "physical"
var dimension_layer: int = 0

# ----- VISUAL COMPONENTS -----
@onready var visual_container: Node3D
@onready var effect_container: Node3D
var particle_systems = {}

# ----- SIGNALS -----
signal entity_manifested(entity)
signal entity_transformed(entity, old_form, new_form)
signal entity_evolved(entity, old_stage, new_stage)
signal entity_connected(entity, target_entity, connection_type)
signal transformed(old_type, new_type)
signal property_changed(property_name, old_value, new_value)
signal interacted(other_entity, result)
signal complexity_changed(old_value, new_value)
signal evolution_stage_changed(old_stage, new_stage)
signal entity_split(original_entity, new_entities)
signal entity_merged(source_entities, new_entity)

# ----- INITIALIZATION -----
func _init(id: String = "", type: String = "primordial", init_properties: Dictionary = {}) -> void:
    if id.empty():
        entity_id = _generate_unique_id()
    else:
        entity_id = id
        
    entity_type = type
    properties = init_properties.duplicate()
    creation_timestamp = Time.get_datetime_string_from_system()
    
    # Initialize complexity if provided
    if init_properties.has("complexity"):
        complexity = init_properties.complexity
    else:
        complexity = calculate_initial_complexity()
    
    # Initialize evolution stage if provided
    if init_properties.has("evolution_stage"):
        evolution_stage = init_properties.evolution_stage
    
    # Initialize parent entities if provided
    if init_properties.has("parent_entities"):
        parent_entities = init_properties.parent_entities.duplicate()
    
    # Initialize metadata if provided
    if init_properties.has("metadata"):
        metadata = init_properties.metadata.duplicate()
    
    # Initialize tags if provided
    if init_properties.has("tags"):
        tags = init_properties.tags.duplicate()
    
    # Record creation time
    last_processed_time = Time.get_ticks_msec()
    
    # Add initial transformation record
    add_transformation_record("creation", "none", entity_type)

func _ready() -> void:
    # Set node name based on entity type and ID
    name = entity_type + "_" + entity_id.substr(0, 8)
    
    # Create containers for visuals
    visual_container = Node3D.new()
    visual_container.name = "VisualContainer"
    add_child(visual_container)
    
    effect_container = Node3D.new()
    effect_container.name = "EffectContainer"
    add_child(effect_container)
    
    # Initialize with seed form if none specified
    if current_form == "seed":
        _update_visual_representation()

# ----- CORE MANIFESTATION SYSTEM -----

func manifest_from_word(word: String, influence: float = 1.0) -> CoreUniversalEntity:
    """
    The core function that creates an entity from a word
    """
    source_word = word
    properties = _word_to_properties(word)
    manifestation_level = min(influence, 1.0)
    
    # Determine initial form based on word properties
    current_form = _determine_initial_form()
    
    # Set entity type based on properties
    entity_type = _determine_entity_type_from_properties()
    
    # Update visuals
    _update_visual_representation()
    
    # Emit signal
    emit_signal("entity_manifested", self)
    
    return self

func transform(new_type: String) -> bool:
    # Don't transform if already this type
    if new_type == entity_type:
        return false
        
    var old_type = entity_type
    
    # Record the transformation
    add_transformation_record("transform", old_type, new_type)
    
    # Update the type
    entity_type = new_type
    
    # Update the node name to reflect the new type
    name = entity_type + "_" + entity_id.substr(0, 8)
    
    # Emit signal
    emit_signal("transformed", old_type, new_type)
    
    return true

func transform_to(new_form: String, transformation_time: float = 1.0) -> CoreUniversalEntity:
    """
    Transform this entity to a new form
    """
    if new_form == current_form:
        return self
        
    var old_form = current_form
    current_form = new_form
    
    # Create transformation effect
    var tween = create_tween()
    tween.tween_method(Callable(self, "_set_transformation_progress"), 0.0, 1.0, transformation_time)
    tween.tween_callback(Callable(self, "_finalize_transformation"))
    
    emit_signal("entity_transformed", self, old_form, new_form)
    
    return self

func evolve(evolution_factor: float = 0.2) -> CoreUniversalEntity:
    """
    Evolve this entity to the next stage
    """
    var old_stage = evolution_stage
    
    # Increase manifestation level
    manifestation_level = min(manifestation_level + evolution_factor, 1.0)
    
    # Increase complexity
    var old_complexity = complexity
    complexity += 10.0 * evolution_factor
    emit_signal("complexity_changed", old_complexity, complexity)
    
    # Calculate new evolution stage based on manifestation level
    var new_stage = int(manifestation_level * 5)  # 5 possible evolution stages
    
    if new_stage > evolution_stage:
        evolution_stage = new_stage
        _update_properties_for_evolution()
        _update_visual_representation()
        emit_signal("entity_evolved", self, old_stage, evolution_stage)
        emit_signal("evolution_stage_changed", old_stage, evolution_stage)
        
        # Add transformation record for stage change
        add_transformation_record("evolution", "stage_" + str(old_stage), "stage_" + str(new_stage))
    
    # Check if we should split due to high complexity
    check_split_threshold()
    
    return self

# ----- CONNECTION SYSTEM -----

func connect_to(target_entity, connection_type: String = "default") -> bool:
    """
    Connect this entity to another entity
    """
    if target_entity == self or target_entity == null:
        return false
    
    # Check if already connected
    for entity in connected_entities:
        if entity.entity_id == target_entity.entity_id:
            return false
    
    # Add to connections
    connected_entities.append(target_entity)
    
    # Add reference
    add_reference(connection_type, target_entity.entity_id)
    
    # Visual connection
    _create_connection_visual(target_entity, connection_type)
    
    # Emit signal
    emit_signal("entity_connected", self, target_entity, connection_type)
    return true

func become_child_of(parent) -> bool:
    """
    Make this entity a child of another entity
    """
    if parent == null or parent == self:
        return false
        
    if parent_entity:
        parent_entity.child_entities.erase(self)
    
    parent_entity = parent
    parent.child_entities.append(self)
    
    # Add reference
    add_reference("parent", parent.entity_id)
    
    # Update visual parent relationship
    # Could adjust scale, material, etc. to show relationship
    
    return true

# ----- PROPERTY MANAGEMENT -----

func set_property(property_name: String, value) -> void:
    var old_value = null
    if properties.has(property_name):
        old_value = properties[property_name]
        
    properties[property_name] = value
    emit_signal("property_changed", property_name, old_value, value)

func get_property(property_name: String, default_value = null):
    if properties.has(property_name):
        return properties[property_name]
    return default_value

func interact_with(other_entity) -> Dictionary:
    # Get the interaction result based on both entity types
    # This should be determined by the interaction matrix
    var result = {
        "success": false,
        "effect": "none",
        "source_entity": self,
        "target_entity": other_entity,
        "source_type": entity_type,
        "target_type": other_entity.entity_type if other_entity else "none"
    }
    
    # Signal that interaction happened
    emit_signal("interacted", other_entity, result)
    
    return result

# ----- REFERENCE MANAGEMENT -----

func add_reference(reference_type: String, target_entity_id: String) -> void:
    if not references.has(reference_type):
        references[reference_type] = []
    
    # Avoid duplicates
    if not target_entity_id in references[reference_type]:
        references[reference_type].append(target_entity_id)

func remove_reference(reference_type: String, target_entity_id: String) -> bool:
    if not references.has(reference_type):
        return false
    
    var index = references[reference_type].find(target_entity_id)
    if index >= 0:
        references[reference_type].remove_at(index)
        return true
    
    return false

func add_transformation_record(action: String, from_type: String, to_type: String) -> void:
    var record = {
        "action": action,
        "from_type": from_type,
        "to_type": to_type,
        "timestamp": Time.get_datetime_string_from_system()
    }
    
    transformation_history.append(record)

# ----- COMPLEXITY SYSTEM -----

func calculate_initial_complexity() -> float:
    var base_complexity = 1.0
    
    # Type-based complexity
    match entity_type:
        "primordial":
            base_complexity = 1.0
        "fire", "water", "air", "earth", "metal", "wood", "ash":
            base_complexity = 2.5
        "fused":
            base_complexity = 5.0
        "transformed":
            base_complexity = 4.0
        _:
            # For custom types, assume medium complexity
            base_complexity = 3.0
    
    # Property-based complexity - more properties = more complex
    base_complexity += properties.size() * 0.5
    
    # Reference-based complexity - more connections = more complex
    for ref_type in references:
        base_complexity += references[ref_type].size() * 0.3
    
    # Round to 2 decimal places
    return snappedf(base_complexity, 0.01)

func update_complexity() -> void:
    var old_complexity = complexity
    var new_complexity = calculate_complexity()
    
    if new_complexity != old_complexity:
        complexity = new_complexity
        emit_signal("complexity_changed", old_complexity, new_complexity)
        
        # Check if we need to update evolution stage
        check_evolution_stage()
        
        # Check if we should split due to high complexity
        check_split_threshold()

func calculate_complexity() -> float:
    # Start with the base calculation
    var current_complexity = calculate_initial_complexity()
    
    # Time factor - longer-lived entities are more complex
    var time_alive_ms = Time.get_ticks_msec() - last_processed_time
    current_complexity += (time_alive_ms / 60000.0) * 0.1  # Add 0.1 per minute
    
    # Transformation history factor - more transformations = more complex
    current_complexity += transformation_history.size() * 0.2
    
    # Child entity factor - more children = more complex
    current_complexity += child_entities.size() * 0.5
    
    # Metadata factor
    current_complexity += metadata.size() * 0.3
    
    # Round to 2 decimal places
    return snappedf(current_complexity, 0.01)

# ----- EVOLUTION STAGE SYSTEM -----

func check_evolution_stage() -> void:
    var old_stage = evolution_stage
    var new_stage = calculate_evolution_stage()
    
    if new_stage != old_stage:
        evolution_stage = new_stage
        emit_signal("evolution_stage_changed", old_stage, new_stage)
        
        # Add transformation record for stage change
        add_transformation_record("evolution", "stage_" + str(old_stage), "stage_" + str(new_stage))

func calculate_evolution_stage() -> int:
    # Constants for evolution thresholds
    const COMPLEXITY_THRESHOLD_LOW = 10
    const COMPLEXITY_THRESHOLD_MED = 50
    const COMPLEXITY_THRESHOLD_HIGH = 100

    if complexity < COMPLEXITY_THRESHOLD_LOW:
        return 0
    elif complexity < COMPLEXITY_THRESHOLD_MED:
        return 1
    elif complexity < COMPLEXITY_THRESHOLD_HIGH:
        return 2
    else:
        return 3

# ----- SPLITTING AND MERGING -----

func check_split_threshold() -> void:
    # Constants for evolution thresholds
    const COMPLEXITY_THRESHOLD_HIGH = 100

    if complexity > COMPLEXITY_THRESHOLD_HIGH and evolution_stage >= 2:
        should_split = true

func attempt_split() -> Array:
    if not should_split:
        return []
    
    print("CoreUniversalEntity: Attempting to split entity " + entity_id)
    
    # Create new entities from this one
    var new_entities = []
    
    # Decide how to split based on entity type and properties
    var split_count = 2
    if complexity > COMPLEXITY_THRESHOLD_HIGH * 2:
        split_count = 3
    
    # Distribute properties among the new entities
    var property_keys = properties.keys()
    
    for i in range(split_count):
        var new_properties = {}
        
        # Distribute some properties to each new entity
        for j in range(property_keys.size()):
            if j % split_count == i:
                var key = property_keys[j]
                new_properties[key] = properties[key]
        
        # Add parent reference and basic metadata
        new_properties["parent_entities"] = [entity_id]
        new_properties["complexity"] = complexity / split_count
        new_properties["evolution_stage"] = evolution_stage - 1
        
        # Create new entity with same type but derived
        var new_entity = CoreUniversalEntity.new("", "derived_" + entity_type, new_properties)
        
        # Track this new entity as a child
        child_entities.append(new_entity.get_id())
        
        # Add to result list
        new_entities.append(new_entity)
    
    # Reset split flag and reduce complexity of this entity
    should_split = false
    complexity /= 2
    
    # Emit signal about the split
    emit_signal("entity_split", self, new_entities)
    
    return new_entities

static func merge_entities(entities: Array) -> CoreUniversalEntity:
    if entities.size() < 2:
        print("CoreUniversalEntity: Need at least 2 entities to merge")
        return null
    
    print("CoreUniversalEntity: Merging " + str(entities.size()) + " entities")
    
    # Calculate merged properties
    var merged_properties = {}
    var total_complexity = 0.0
    var parent_ids = []
    var all_tags = []
    
    for entity in entities:
        if not entity is CoreUniversalEntity:
            continue
        
        # Add parent ID
        parent_ids.append(entity.get_id())
        
        # Sum complexities
        total_complexity += entity.complexity
        
        # Merge properties
        for key in entity.properties:
            if not merged_properties.has(key):
                merged_properties[key] = entity.properties[key]
            elif typeof(merged_properties[key]) == TYPE_FLOAT or typeof(merged_properties[key]) == TYPE_INT:
                merged_properties[key] += entity.properties[key]
        
        # Collect tags
        for tag in entity.tags:
            if not tag in all_tags:
                all_tags.append(tag)
    
    # Set up the merged entity properties
    merged_properties["parent_entities"] = parent_ids
    merged_properties["complexity"] = total_complexity * 0.8  # Slight reduction in complexity
    merged_properties["evolution_stage"] = 2  # Start at medium evolution stage
    merged_properties["tags"] = all_tags
    
    # Create merged entity
    var merged_type = "merged"
    if entities.size() > 0:
        merged_type = "merged_" + entities[0].get_type()
    
    var merged_entity = CoreUniversalEntity.new("", merged_type, merged_properties)
    
    # For each original entity, add the merged entity as a child
    for entity in entities:
        if entity is CoreUniversalEntity:
            entity.child_entities.append(merged_entity.get_id())
    
    # Emit signal from the new entity about the merge
    merged_entity.emit_signal("entity_merged", entities, merged_entity)
    
    return merged_entity

# ----- ZONE MANAGEMENT -----

func add_to_zone(zone_id: String) -> bool:
    if zone_id in zones:
        return false  # Already in this zone
    
    zones.append(zone_id)
    return true

func remove_from_zone(zone_id: String) -> bool:
    var index = zones.find(zone_id)
    if index >= 0:
        zones.remove_at(index)
        return true
    return false

func get_zones() -> Array:
    return zones.duplicate()

# ----- TAG MANAGEMENT -----

func add_tag(tag: String) -> bool:
    if tag in tags:
        return false
    
    tags.append(tag)
    return true

func remove_tag(tag: String) -> bool:
    var index = tags.find(tag)
    if index >= 0:
        tags.remove_at(index)
        return true
    return false

func has_tag(tag: String) -> bool:
    return tag in tags

func get_tags() -> Array:
    return tags.duplicate()

# ----- METADATA MANAGEMENT -----

func set_metadata(key: String, value) -> void:
    metadata[key] = value

func get_metadata(key: String, default_value = null):
    if metadata.has(key):
        return metadata[key]
    return default_value

func remove_metadata(key: String) -> bool:
    if metadata.has(key):
        metadata.erase(key)
        return true
    return false

# ----- LIFECYCLE MANAGEMENT -----

func process(delta: float) -> void:
    # Update since last processed
    var current_time = Time.get_ticks_msec()
    var time_since_last = current_time - last_processed_time
    
    # Only process if enough time has passed
    if time_since_last > 100:  # 100ms minimum between processing
        # Update complexity
        update_complexity()
        
        # Check if we should split
        if should_split:
            var new_entities = attempt_split()
            # Note: The entity that splits should usually be handled by an entity manager
        
        # Update last processed time
        last_processed_time = current_time

# ----- SERIALIZATION -----

func to_dict() -> Dictionary:
    var data = {
        "entity_id": entity_id,
        "entity_type": entity_type,
        "source_word": source_word,
        "manifestation_level": manifestation_level,
        "current_form": current_form,
        "properties": properties,
        "evolution_stage": evolution_stage,
        "creation_timestamp": creation_timestamp,
        "transformation_history": transformation_history,
        "references": references,
        "complexity": complexity,
        "parent_entities": parent_entities.duplicate(),
        "child_entities": child_entities.duplicate(),
        "metadata": metadata.duplicate(),
        "zones": zones.duplicate(),
        "tags": tags.duplicate(),
        "last_processed_time": last_processed_time,
        "should_split": should_split,
        "reality_context": reality_context,
        "dimension_layer": dimension_layer
    }
    
    return data

func from_dict(data: Dictionary) -> bool:
    if not data.has("entity_id") or not data.has("entity_type"):
        return false
    
    entity_id = data.entity_id
    entity_type = data.entity_type
    
    if data.has("source_word"):
        source_word = data.source_word
    
    if data.has("manifestation_level"):
        manifestation_level = data.manifestation_level
    
    if data.has("current_form"):
        current_form = data.current_form
    
    if data.has("properties"):
        properties = data.properties.duplicate()
    
    if data.has("evolution_stage"):
        evolution_stage = data.evolution_stage
    
    if data.has("creation_timestamp"):
        creation_timestamp = data.creation_timestamp
    
    if data.has("transformation_history"):
        transformation_history = data.transformation_history.duplicate()
    
    if data.has("references"):
        references = data.references.duplicate()
    
    if data.has("complexity"):
        complexity = data.complexity
    
    if data.has("parent_entities"):
        parent_entities = data.parent_entities.duplicate()
    
    if data.has("child_entities"):
        child_entities = data.child_entities.duplicate()
    
    if data.has("metadata"):
        metadata = data.metadata.duplicate()
    
    if data.has("zones"):
        zones = data.zones.duplicate()
    
    if data.has("tags"):
        tags = data.tags.duplicate()
    
    if data.has("last_processed_time"):
        last_processed_time = data.last_processed_time
    
    if data.has("should_split"):
        should_split = data.should_split
    
    if data.has("reality_context"):
        reality_context = data.reality_context
    
    if data.has("dimension_layer"):
        dimension_layer = data.dimension_layer
    
    # Update node name
    name = entity_type + "_" + entity_id.substr(0, 8)
    
    # Update visual representation if ready
    if is_inside_tree() and visual_container != null:
        _update_visual_representation()
    
    return true

# ----- UTILITY FUNCTIONS -----

func _generate_unique_id() -> String:
    """
    Generate a unique ID for this entity
    """
    var timestamp = Time.get_unix_time_from_system()
    var random_part = randi() % 1000000
    return str(timestamp) + "_" + str(random_part) + "_" + str(source_word.hash())

# ----- WORD TO PROPERTIES CONVERSION -----

func _word_to_properties(word: String) -> Dictionary:
    """
    Convert a word into entity properties
    """
    var props = {}
    
    # Basic elemental analysis
    var elements = {"fire": 0, "water": 0, "earth": 0, "air": 0, "void": 0, "metal": 0, "wood": 0, "light": 0, "dark": 0}
    
    for element in elements.keys():
        if word.to_lower().find(element) >= 0:
            elements[element] = 1.0
    
    # Check vowel ratio for fluidity
    var vowel_count = 0
    for c in word.to_lower():
        if c in "aeiou":
            vowel_count += 1
    
    var fluidity = float(vowel_count) / max(1, word.length())
    
    # Complexity based on word length and unique characters
    var unique_chars = {}
    for c in word.to_lower():
        unique_chars[c] = true
    var complexity = (float(unique_chars.size()) / 26.0 + float(word.length()) / 20.0) / 2.0
    
    # First letter influences energy
    var first_char = word.substr(0, 1).to_lower()
    var alphabet = "abcdefghijklmnopqrstuvwxyz"
    var first_char_position = alphabet.find(first_char)
    var initial_energy = float(first_char_position) / max(1, alphabet.length())
    
    # Assign properties
    props["elements"] = elements
    props["fluidity"] = fluidity
    props["complexity"] = complexity
    props["energy"] = initial_energy
    props["resonance"] = randf()  # Some randomness for variety
    
    return props

func _determine_initial_form() -> String:
    """
    Determine the initial form of this entity based on its properties
    """
    # Check for dominant element
    var dominant_element = "none"
    var max_element_value = 0
    
    if properties.has("elements"):
        for element in properties["elements"]:
            if properties["elements"][element] > max_element_value:
                dominant_element = element
                max_element_value = properties["elements"][element]
    
    # Return form based on properties
    if max_element_value > 0:
        match dominant_element:
            "fire": return "flame"
            "water": return "droplet"
            "earth": return "crystal"
            "air": return "wisp"
            "void": return "void_spark"
            "metal": return "orb"
            "wood": return "sprout"
            "light": return "light_mote"
            "dark": return "shadow_essence"
    
    # If no dominant element, use other properties
    if properties.has("fluidity") and properties["fluidity"] > 0.7:
        return "flow"
    elif properties.has("complexity") and properties["complexity"] > 0.7:
        return "pattern"
    elif properties.has("energy") and properties["energy"] > 0.7:
        return "spark"
    
    # Default to seed
    return "seed"

func _determine_entity_type_from_properties() -> String:
    """
    Determine entity type based on properties
    """
    # Check for dominant element
    var dominant_element = "none"
    var max_element_value = 0
    
    if properties.has("elements"):
        for element in properties["elements"]:
            if properties["elements"][element] > max_element_value:
                dominant_element = element
                max_element_value = properties["elements"][element]
    
    # Return type based on dominant element
    if max_element_value > 0:
        return dominant_element
    
    # Default to basic primordial
    return "primordial"

# ----- VISUAL REPRESENTATION -----

func _update_visual_representation():
    """
    Update the visual representation based on current form and properties
    """
    # Clear previous visual elements
    for child in visual_container.get_children():
        child.queue_free()
    
    # Clear effect container
    for child in effect_container.get_children():
        child.queue_free()
    
    # Reset particle systems
    particle_systems.clear()
    
    # Create visuals based on current form
    match current_form:
        "seed":
            _create_seed_visual()
        "flame":
            _create_flame_visual()
        "droplet":
            _create_droplet_visual()
        "crystal":
            _create_crystal_visual()
        "wisp":
            _create_wisp_visual()
        "flow":
            _create_flow_visual()
        "void_spark":
            _create_void_spark_visual()
        "spark":
            _create_spark_visual()
        "pattern":
            _create_pattern_visual()
        "orb":
            _create_orb_visual()
        "sprout":
            _create_sprout_visual()
        "light_mote":
            _create_light_mote_visual()
        "shadow_essence":
            _create_shadow_essence_visual()
        _:
            _create_default_visual()
    
    # Apply evolution effects
    _apply_evolution_effects()

func _create_seed_visual():
    var mesh_instance = MeshInstance3D.new()
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.1
    sphere_mesh.height = 0.2
    mesh_instance.mesh = sphere_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.2, 0.8, 0.2)
    
    if evolution_stage > 0:
        material.emission_enabled = true
        material.emission = Color(0.4, 0.9, 0.4)
        material.emission_energy = float(evolution_stage) / 5.0
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)
    
    if evolution_stage > 2:
        # Add particle effect for more evolved seeds
        _add_particle_system("seed_glow", Color(0.4, 0.9, 0.4))

func _create_flame_visual():
    var mesh_instance = MeshInstance3D.new()
    var cone_mesh = CylinderMesh.new()
    cone_mesh.top_radius = 0.0
    cone_mesh.bottom_radius = 0.15
    cone_mesh.height = 0.4
    mesh_instance.mesh = cone_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.9, 0.4, 0.1)
    material.emission_enabled = true
    material.emission = Color(0.9, 0.6, 0.1)
    material.emission_energy = 1.0 + evolution_stage
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)
    
    # Add flame particles
    _add_particle_system("flame", Color(0.9, 0.4, 0.1))

func _create_droplet_visual():
    var mesh_instance = MeshInstance3D.new()
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.15
    sphere_mesh.height = 0.35
    mesh_instance.mesh = sphere_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.2, 0.5, 0.9, 0.8)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.roughness = 0.1
    
    if evolution_stage > 0:
        material.emission_enabled = true
        material.emission = Color(0.3, 0.6, 1.0)
        material.emission_energy = float(evolution_stage) / 10.0
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)
    
    if evolution_stage > 1:
        # Add droplet particles
        _add_particle_system("water_droplets", Color(0.2, 0.6, 0.9, 0.5))

func _create_crystal_visual():
    var mesh_instance = MeshInstance3D.new()
    var prism_mesh = PrismMesh.new()
    prism_mesh.size = Vector3(0.2, 0.3, 0.2)
    mesh_instance.mesh = prism_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.8, 0.8, 0.9, 0.9)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.roughness = 0.1
    material.metallic = 0.3
    
    if evolution_stage > 0:
        material.emission_enabled = true
        material.emission = Color(0.8, 0.8, 1.0)
        material.emission_energy = float(evolution_stage) / 8.0
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)

func _create_wisp_visual():
    var mesh_instance = MeshInstance3D.new()
    var capsule_mesh = CapsuleMesh.new()
    capsule_mesh.radius = 0.1
    capsule_mesh.height = 0.4
    mesh_instance.mesh = capsule_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.9, 0.9, 1.0, 0.3)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.roughness = 0.1
    
    if evolution_stage > 0:
        material.emission_enabled = true
        material.emission = Color(0.9, 0.9, 1.0)
        material.emission_energy = 0.5 + float(evolution_stage) / 4.0
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)
    
    # Add wisp particles
    _add_particle_system("wisp", Color(0.9, 0.9, 1.0, 0.3))

func _create_flow_visual():
    var mesh_instance = MeshInstance3D.new()
    var torus_mesh = TorusMesh.new()
    torus_mesh.inner_radius = 0.1
    torus_mesh.outer_radius = 0.2
    mesh_instance.mesh = torus_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.3, 0.7, 0.9, 0.7)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.roughness = 0.2
    
    if evolution_stage > 0:
        material.emission_enabled = true
        material.emission = Color(0.4, 0.7, 1.0)
        material.emission_energy = float(evolution_stage) / 6.0
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)
    
    # Add flow particles
    _add_particle_system("flow", Color(0.4, 0.7, 0.9, 0.5))

func _create_void_spark_visual():
    var mesh_instance = MeshInstance3D.new()
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.1
    sphere_mesh.height = 0.2
    mesh_instance.mesh = sphere_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.1, 0.0, 0.2)
    material.emission_enabled = true
    material.emission = Color(0.5, 0.0, 1.0)
    material.emission_energy = 1.0 + evolution_stage * 0.5
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)
    
    # Add void particles
    _add_particle_system("void", Color(0.5, 0.0, 1.0, 0.7))

func _create_pattern_visual():
    var mesh_instance = MeshInstance3D.new()
    var box_mesh = BoxMesh.new()
    box_mesh.size = Vector3(0.2, 0.2, 0.2)
    mesh_instance.mesh = box_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.7, 0.7, 0.7)
    material.metallic = 0.5
    material.roughness = 0.3
    
    if evolution_stage > 0:
        material.emission_enabled = true
        material.emission = Color(0.8, 0.8, 0.8)
        material.emission_energy = float(evolution_stage) / 10.0
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)

func _create_spark_visual():
    var mesh_instance = MeshInstance3D.new()
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.05
    sphere_mesh.height = 0.1
    mesh_instance.mesh = sphere_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(1.0, 0.8, 0.2)
    material.emission_enabled = true
    material.emission = Color(1.0, 0.8, 0.2)
    material.emission_energy = 2.0 + evolution_stage
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)
    
    # Add spark particles
    _add_particle_system("spark", Color(1.0, 0.8, 0.2))

func _create_orb_visual():
    var mesh_instance = MeshInstance3D.new()
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.15
    sphere_mesh.height = 0.3
    mesh_instance.mesh = sphere_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.7, 0.7, 0.8)
    material.metallic = 0.8
    material.roughness = 0.1
    
    if evolution_stage > 0:
        material.emission_enabled = true
        material.emission = Color(0.8, 0.8, 0.9)
        material.emission_energy = float(evolution_stage) / 8.0
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)

func _create_sprout_visual():
    var mesh_instance = MeshInstance3D.new()
    var cylinder = CylinderMesh.new()
    cylinder.top_radius = 0.05
    cylinder.bottom_radius = 0.03
    cylinder.height = 0.3
    mesh_instance.mesh = cylinder
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.3, 0.8, 0.3)
    
    if evolution_stage > 0:
        material.emission_enabled = true
        material.emission = Color(0.4, 0.9, 0.4)
        material.emission_energy = float(evolution_stage) / 10.0
    
    mesh_instance.material_override = material
    mesh_instance.rotation_degrees.x = -90  # Point upward
    visual_container.add_child(mesh_instance)
    
    # Add leaf at the top
    var leaf = MeshInstance3D.new()
    var leaf_mesh = SphereMesh.new()
    leaf_mesh.radius = 0.07
    leaf_mesh.height = 0.05
    leaf.mesh = leaf_mesh
    leaf.position = Vector3(0, 0.15, 0)
    
    var leaf_material = StandardMaterial3D.new()
    leaf_material.albedo_color = Color(0.1, 0.9, 0.2)
    leaf.material_override = leaf_material
    
    mesh_instance.add_child(leaf)

func _create_light_mote_visual():
    var mesh_instance = MeshInstance3D.new()
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.1
    sphere_mesh.height = 0.2
    mesh_instance.mesh = sphere_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(1.0, 1.0, 0.8, 0.7)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.emission_enabled = true
    material.emission = Color(1.0, 1.0, 0.8)
    material.emission_energy = 2.0 + evolution_stage
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)
    
    # Add light particles
    _add_particle_system("light", Color(1.0, 1.0, 0.8, 0.6))

func _create_shadow_essence_visual():
    var mesh_instance = MeshInstance3D.new()
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.12
    sphere_mesh.height = 0.24
    mesh_instance.mesh = sphere_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.1, 0.1, 0.2, 0.7)
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.emission_enabled = true
    material.emission = Color(0.2, 0.1, 0.3)
    material.emission_energy = 0.5 + evolution_stage * 0.3
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)
    
    # Add shadow particles
    _add_particle_system("shadow", Color(0.1, 0.1, 0.2, 0.5))

func _create_default_visual():
    var mesh_instance = MeshInstance3D.new()
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.15
    sphere_mesh.height = 0.3
    mesh_instance.mesh = sphere_mesh
    
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.8, 0.8, 0.8)
    
    if evolution_stage > 0:
        material.emission_enabled = true
        material.emission = Color(0.9, 0.9, 0.9)
        material.emission_energy = float(evolution_stage) / 10.0
    
    mesh_instance.material_override = material
    visual_container.add_child(mesh_instance)

func _add_particle_system(type: String, base_color: Color):
    var particles = GPUParticles3D.new()
    particles.name = type + "_particles"
    
    var material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
    material.emission_sphere_radius = 0.1
    
    match type:
        "seed_glow":
            material.direction = Vector3(0, 1, 0)
            material.initial_velocity_min = 0.1
            material.initial_velocity_max = 0.2
            material.scale_min = 0.01
            material.scale_max = 0.03
        "flame":
            material.direction = Vector3(0, 1, 0)
            material.initial_velocity_min = 0.2
            material.initial_velocity_max = 0.5
            material.scale_min = 0.05
            material.scale_max = 0.1
        "water_droplets":
            material.direction = Vector3(0, -1, 0)
            material.initial_velocity_min = 0.1
            material.initial_velocity_max = 0.3
            material.scale_min = 0.02
            material.scale_max = 0.04
        "wisp":
            material.direction = Vector3(0, 0.5, 0)
            material.initial_velocity_min = 0.05
            material.initial_velocity_max = 0.2
            material.scale_min = 0.03
            material.scale_max = 0.08
        "flow":
            material.direction = Vector3(0, 0, 0)
            material.initial_velocity_min = 0.1
            material.initial_velocity_max = 0.3
            material.scale_min = 0.03
            material.scale_max = 0.05
        "void":
            material.direction = Vector3(0, 0, 0)
            material.initial_velocity_min = 0.05
            material.initial_velocity_max = 0.15
            material.scale_min = 0.02
            material.scale_max = 0.06
        "spark":
            material.direction = Vector3(0, 0, 0)
            material.initial_velocity_min = 0.3
            material.initial_velocity_max = 0.7
            material.scale_min = 0.01
            material.scale_max = 0.03
        "light":
            material.direction = Vector3(0, 0, 0)
            material.initial_velocity_min = 0.1
            material.initial_velocity_max = 0.3
            material.scale_min = 0.03
            material.scale_max = 0.08
        "shadow":
            material.direction = Vector3(0, 0, 0)
            material.initial_velocity_min = 0.05
            material.initial_velocity_max = 0.15
            material.scale_min = 0.04
            material.scale_max = 0.1
    
    # Set the color of the particles
    material.color = base_color
    
    # Create a mesh for the particles
    var particle_mesh = QuadMesh.new()
    particles.draw_pass_1 = particle_mesh
    
    # Set the process material
    particles.process_material = material
    
    # Set particle count and lifetime based on evolution stage
    particles.amount = 20 + (10 * evolution_stage)
    particles.lifetime = 1.0
    
    # Add to the effect container
    effect_container.add_child(particles)
    
    # Store reference to the particle system
    particle_systems[type] = particles

func _set_transformation_progress(progress: float):
    """
    Handle visual transformation between forms
    """
    # Scale pulsing effect during transformation
    var scale_factor = 1.0 + sin(progress * 3.14159 * 2) * 0.3
    visual_container.scale = Vector3(scale_factor, scale_factor, scale_factor)
    
    # Color shift effect for all mesh instances
    for child in visual_container.get_children():
        if child is MeshInstance3D and child.material_override:
            var material = child.material_override
            if material is StandardMaterial3D:
                material.emission_enabled = true
                material.emission_energy = 1.0 + sin(progress * 3.14159) * 2.0

func _finalize_transformation():
    """
    Called when transformation is complete
    """
    visual_container.scale = Vector3(1, 1, 1)
    _update_visual_representation()

# ----- EVOLUTION EFFECTS -----

func _update_properties_for_evolution():
    """
    Update properties based on evolution stage
    """
    # Enhance existing properties proportionally to evolution
    var boost_factor = 1.0 + (evolution_stage * 0.2)
    
    # Copy properties to avoid modifying while iterating
    var prop_keys = properties.keys()
    
    # Enhance numeric properties
    for key in prop_keys:
        if properties[key] is float or properties[key] is int:
            properties[key] = properties[key] * boost_factor
        elif properties[key] is Dictionary:
            # For nested dictionaries like elements
            for subkey in properties[key]:
                if properties[key][subkey] is float or properties[key][subkey] is int:
                    properties[key][subkey] = properties[key][subkey] * boost_factor
    
    # Add new properties at certain evolution stages
    if evolution_stage >= 2 and not properties.has("resonance_field"):
        properties["resonance_field"] = 0.3
    
    if evolution_stage >= 3 and not properties.has("influence_radius"):
        properties["influence_radius"] = 2.0
    
    if evolution_stage >= 4 and not properties.has("transcendence"):
        properties["transcendence"] = 0.1

func _apply_evolution_effects():
    """
    Apply visual effects based on evolution stage
    """
    # Scale visual container based on evolution
    var scale_factor = 1.0 + (evolution_stage * 0.15)
    visual_container.scale = Vector3(scale_factor, scale_factor, scale_factor)
    
    # Add glow effect at higher evolution stages
    for child in visual_container.get_children():
        if child is MeshInstance3D and child.material_override:
            var material = child.material_override
            if material is StandardMaterial3D:
                if evolution_stage >= 1:
                    material.emission_enabled = true
                    material.emission_energy = evolution_stage * 0.5
                
                if evolution_stage >= 3:
                    # Add special effects for highly evolved entities
                    material.metallic = 0.3 + (evolution_stage * 0.1)
                    material.roughness = max(0.1, 0.5 - (evolution_stage * 0.1))

# ----- CONNECTION VISUALIZATION -----

func _create_connection_visual(target_entity, connection_type: String):
    """
    Create a visual representation of a connection between entities
    """
    # Calculate connection properties
    var start_pos = global_position
    var end_pos = target_entity.global_position
    var connection_length = start_pos.distance_to(end_pos)
    
    # Create connection line
    var connection_visual = MeshInstance3D.new()
    connection_visual.name = "Connection_" + target_entity.entity_id
    
    var cylinder = CylinderMesh.new()
    cylinder.top_radius = 0.02
    cylinder.bottom_radius = 0.02
    cylinder.height = connection_length
    connection_visual.mesh = cylinder
    
    # Rotate and position to connect the two entities
    var look_at_pos = end_pos
    connection_visual.look_at_from_position(
        start_pos.lerp(end_pos, 0.5),  # Position at middle
        look_at_pos,
        Vector3.UP
    )
    # Rotate 90 degrees to align cylinder properly
    connection_visual.rotate_object_local(Vector3.RIGHT, PI/2)
    
    # Material based on connection type
    var material = StandardMaterial3D.new()
    
    match connection_type:
        "default":
            material.albedo_color = Color(0.7, 0.7, 0.7, 0.5)
        "strong":
            material.albedo_color = Color(0.2, 0.6, 1.0, 0.7)
        "conflict":
            material.albedo_color = Color(1.0, 0.3, 0.2, 0.7)
        "harmony":
            material.albedo_color = Color(0.4, 0.9, 0.4, 0.7)
    
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    connection_visual.material_override = material
    
    # Add to scene
    add_child(connection_visual)
    
    # Optional: animate the connection forming
    var tween = create_tween()
    connection_visual.scale.y = 0
    tween.tween_property(connection_visual, "scale:y", 1.0, 0.5)

# ----- GETTERS -----
func get_id() -> String:
    return entity_id

func get_type() -> String:
    return entity_type

func get_creation_timestamp() -> String:
    return creation_timestamp

func get_transformation_history() -> Array:
    return transformation_history

func get_properties() -> Dictionary:
    return properties

func get_references() -> Dictionary:
    return references