# 🗂️ Phase 3: Entity Registry System

## 📋 Overview

This phase focuses on creating a central registry system for Universal Entities, enabling tracking, querying, and management of all entities across the JSH Ethereal Engine. This registry will serve as the integration point with main.gd and other core systems.

## 🎯 Goals

- Create a centralized entity tracking system
- Implement entity querying capabilities
- Build entity lifecycle management
- Integrate with main.gd and other core systems

## 📑 Tasks

### 📌 Task 1: Registry Core Implementation
- [ ] Create UniversalEntityRegistry class
- [ ] Implement entity registration and retrieval
- [ ] Build entity ID generation system
- [ ] Add entity archiving capabilities

### 📌 Task 2: Entity Querying System
- [ ] Implement word-based entity queries
- [ ] Create form-based filtering
- [ ] Build reality context filtering
- [ ] Add property-based querying

### 📌 Task 3: Entity Lifecycle Management
- [ ] Implement entity creation tracking
- [ ] Build transformation history
- [ ] Create evolution tracking
- [ ] Add relationship management

### 📌 Task 4: Main Integration
- [ ] Integrate registry with main.gd
- [ ] Create dimensional magic functions for entity operations
- [ ] Implement entity signal handling
- [ ] Add memory system integration

### 📌 Task 5: Record System Integration
- [ ] Connect entity registry with record system
- [ ] Implement entity serialization
- [ ] Build entity persistence
- [ ] Add entity restoration from records

## 💾 Implementation Details

### Entity Registry Class

```gdscript
class_name UniversalEntityRegistry
extends Node

# Entity storage
var active_entities = {}
var archived_entities = {}

# Caching and indexing
var word_index = {}
var form_index = {}
var reality_index = {}

# Entity registration
func register_entity(entity: UniversalEntity) -> String:
    var entity_id = generate_entity_id(entity)
    
    # Store in main collection
    active_entities[entity_id] = entity
    
    # Update indexes
    index_entity(entity_id, entity)
    
    # Connect to entity signals
    entity.connect("entity_transformed", Callable(self, "_on_entity_transformed").bind(entity_id))
    entity.connect("entity_evolved", Callable(self, "_on_entity_evolved").bind(entity_id))
    
    # Send registry event
    emit_signal("entity_registered", entity_id, entity)
    
    return entity_id

# Entity retrieval
func get_entity(entity_id: String) -> UniversalEntity:
    if active_entities.has(entity_id):
        return active_entities[entity_id]
    return null

# Entity archiving
func archive_entity(entity_id: String) -> bool:
    if active_entities.has(entity_id):
        var entity = active_entities[entity_id]
        
        # Move to archive
        archived_entities[entity_id] = entity
        active_entities.erase(entity_id)
        
        # Update indexes
        remove_from_indexes(entity_id, entity)
        
        # Send registry event
        emit_signal("entity_archived", entity_id, entity)
        
        return true
    return false

# Helper methods
func generate_entity_id(entity: UniversalEntity) -> String:
    var timestamp = Time.get_ticks_msec()
    var word_hash = entity.source_word.hash()
    return "entity_" + str(word_hash) + "_" + str(timestamp)

# Indexing
func index_entity(entity_id: String, entity: UniversalEntity) -> void:
    # Word indexing
    if not word_index.has(entity.source_word):
        word_index[entity.source_word] = []
    word_index[entity.source_word].append(entity_id)
    
    # Form indexing
    if not form_index.has(entity.current_form):
        form_index[entity.current_form] = []
    form_index[entity.current_form].append(entity_id)
    
    # Reality indexing
    if not reality_index.has(entity.reality_context):
        reality_index[entity.reality_context] = []
    reality_index[entity.reality_context].append(entity_id)

func remove_from_indexes(entity_id: String, entity: UniversalEntity) -> void:
    # Word index
    if word_index.has(entity.source_word):
        word_index[entity.source_word].erase(entity_id)
        
    # Form index
    if form_index.has(entity.current_form):
        form_index[entity.current_form].erase(entity_id)
        
    # Reality index
    if reality_index.has(entity.reality_context):
        reality_index[entity.reality_context].erase(entity_id)

# Query methods
func find_entities_by_word(word: String) -> Array:
    if word_index.has(word):
        return word_index[word].map(func(id): return get_entity(id))
    return []

func find_entities_by_form(form: String) -> Array:
    if form_index.has(form):
        return form_index[form].map(func(id): return get_entity(id))
    return []

func find_entities_in_reality(reality: String) -> Array:
    if reality_index.has(reality):
        return reality_index[reality].map(func(id): return get_entity(id))
    return []

func find_entities_by_property(property: String, min_value: float, max_value: float) -> Array:
    var results = []
    for entity_id in active_entities:
        var entity = active_entities[entity_id]
        if entity.properties.has(property):
            var value = entity.properties[property]
            if value >= min_value and value <= max_value:
                results.append(entity)
    return results

# Event handlers
func _on_entity_transformed(entity: UniversalEntity, old_form: String, new_form: String, entity_id: String) -> void:
    # Update form indexing
    if form_index.has(old_form):
        form_index[old_form].erase(entity_id)
        
    if not form_index.has(new_form):
        form_index[new_form] = []
    form_index[new_form].append(entity_id)
    
    emit_signal("entity_form_changed", entity_id, old_form, new_form)

func _on_entity_evolved(entity: UniversalEntity, new_level: float, entity_id: String) -> void:
    emit_signal("entity_evolved", entity_id, new_level)

# Signals
signal entity_registered(entity_id, entity)
signal entity_archived(entity_id, entity)
signal entity_form_changed(entity_id, old_form, new_form)
signal entity_evolved(entity_id, new_level)
```

### Main Integration

```gdscript
# In main.gd

# Entity system references
var entity_registry: UniversalEntityRegistry
var entity_factory: UniversalEntityFactory  # Optional helper class

func _ready():
    # Initialize entity systems
    entity_registry = UniversalEntityRegistry.new()
    add_child(entity_registry)
    
    # Connect to registry events
    entity_registry.connect("entity_registered", _on_entity_registered)
    entity_registry.connect("entity_archived", _on_entity_archived)
    entity_registry.connect("entity_form_changed", _on_entity_form_changed)
    entity_registry.connect("entity_evolved", _on_entity_evolved)
    
    # Initialize other systems...

# Dimensional magic - Entity creation
func first_dimensional_magic_entity(type_of_action: String, datapoint_node, additional_node = null):
    if type_of_action == "create_entity":
        var container_path = datapoint_node
        var entity_data = additional_node
        
        # Get target container
        var container = get_node_or_null(container_path)
        if not container:
            print("Container not found: " + container_path)
            return {"status": "error", "message": "Container not found"}
            
        # Create entity
        var entity = UniversalEntity.new()
        container.add_child(entity)
        
        # Configure entity from data
        if entity_data.has("word"):
            entity.manifest_from_word(entity_data.word)
        
        if entity_data.has("type"):
            entity.entity_type = entity_data.type
            
        if entity_data.has("position"):
            entity.global_position = entity_data.position
            
        if entity_data.has("reality"):
            entity.reality_context = entity_data.reality
            
        # Register entity
        var entity_id = entity_registry.register_entity(entity)
        
        # Record creation in memory system
        remember("entity_creation", {
            "entity_id": entity_id,
            "word": entity_data.get("word", ""),
            "reality": entity_data.get("reality", "physical")
        })
        
        return {"status": "success", "entity_id": entity_id, "entity": entity}
    
    elif type_of_action == "transform_entity":
        var entity_id = datapoint_node
        var transform_data = additional_node
        
        var entity = entity_registry.get_entity(entity_id)
        if not entity:
            return {"status": "error", "message": "Entity not found"}
            
        # Transform entity
        if transform_data.has("form"):
            entity.transform_to(transform_data.form)
            
        return {"status": "success", "entity_id": entity_id}
    
    elif type_of_action == "evolve_entity":
        var entity_id = datapoint_node
        var evolve_data = additional_node
        
        var entity = entity_registry.get_entity(entity_id)
        if not entity:
            return {"status": "error", "message": "Entity not found"}
            
        # Evolve entity
        var factor = evolve_data.get("factor", 0.1)
        entity.evolve(factor)
        
        return {"status": "success", "entity_id": entity_id}
    
    return {"status": "error", "message": "Unknown action"}

# Event handlers
func _on_entity_registered(entity_id: String, entity: UniversalEntity) -> void:
    print("Entity registered: " + entity_id)
    
    # Notify any listeners
    if has_signal("entity_created"):
        emit_signal("entity_created", entity_id, entity.source_word)

func _on_entity_archived(entity_id: String, entity: UniversalEntity) -> void:
    print("Entity archived: " + entity_id)

func _on_entity_form_changed(entity_id: String, old_form: String, new_form: String) -> void:
    print("Entity form changed: " + entity_id + " from " + old_form + " to " + new_form)
    
    # Check for déjà vu
    check_for_deja_vu("entity_transformation", {"entity_id": entity_id, "old_form": old_form, "new_form": new_form})

func _on_entity_evolved(entity_id: String, new_level: float) -> void:
    print("Entity evolved: " + entity_id + " to level " + str(new_level))
```

### Record System Integration

```gdscript
# Entity serialization and persistence

func serialize_entity(entity: UniversalEntity) -> Dictionary:
    var data = {
        "type": entity.entity_type,
        "word": entity.source_word,
        "form": entity.current_form,
        "level": entity.manifestation_level,
        "properties": entity.properties,
        "reality": entity.reality_context,
        "position": {
            "x": entity.global_position.x,
            "y": entity.global_position.y,
            "z": entity.global_position.z
        },
        "rotation": {
            "x": entity.global_rotation.x,
            "y": entity.global_rotation.y,
            "z": entity.global_rotation.z
        }
    }
    
    # Serialize relationships
    data["relationships"] = {
        "parent": entity.parent_entity,
        "children": entity.child_entities,
        "connected": entity.connected_entities
    }
    
    return data

func deserialize_entity(data: Dictionary) -> UniversalEntity:
    var entity = UniversalEntity.new()
    
    # Set basic properties
    entity.entity_type = data.get("type", "undefined")
    entity.source_word = data.get("word", "")
    entity.current_form = data.get("form", "seed")
    entity.manifestation_level = data.get("level", 0.0)
    entity.properties = data.get("properties", {})
    entity.reality_context = data.get("reality", "physical")
    
    # Set position if provided
    if data.has("position"):
        entity.global_position = Vector3(
            data.position.get("x", 0.0),
            data.position.get("y", 0.0),
            data.position.get("z", 0.0)
        )
    
    # Set rotation if provided
    if data.has("rotation"):
        entity.global_rotation = Vector3(
            data.rotation.get("x", 0.0),
            data.rotation.get("y", 0.0),
            data.rotation.get("z", 0.0)
        )
    
    # Update visual representation
    entity.update_visual_representation()
    
    return entity

# In main.gd or registry class
func save_entities_to_records(record_set_name: String) -> bool:
    var entities_data = []
    
    for entity_id in entity_registry.active_entities:
        var entity = entity_registry.active_entities[entity_id]
        var data = serialize_entity(entity)
        data["id"] = entity_id
        entities_data.append(data)
    
    var record = {
        "type": "entity_collection",
        "entities": entities_data,
        "timestamp": Time.get_ticks_msec(),
        "reality_context": current_reality
    }
    
    # Use existing record system to store
    return add_record_to_set(record_set_name, record)

func load_entities_from_records(record_set_name: String, container_path: String) -> int:
    var container = get_node_or_null(container_path)
    if not container:
        print("Container not found: " + container_path)
        return 0
    
    var records = get_records_from_set(record_set_name, {"type": "entity_collection"})
    if records.size() == 0:
        return 0
    
    # Use most recent record
    var entity_record = records[records.size() - 1]
    var count = 0
    
    for entity_data in entity_record.entities:
        var entity = deserialize_entity(entity_data)
        container.add_child(entity)
        entity_registry.register_entity(entity)
        count += 1
    
    return count
```

## 🔄 Integration Points

- Entity Registry connects Universal Entities to:
  - Main system via dimensional magic
  - Memory system for déjà vu detection
  - Record system for persistence
  - Reality system for context awareness
  - Word manifestation via entity creation

## 📊 Progress Tracking

- 🟥 Not started
- 🟨 In progress
- 🟩 Completed

| Task                      | Status | Notes                                  |
|---------------------------|:------:|----------------------------------------|
| Registry Core             |   🟥   |                                        |
| Entity Querying           |   🟥   |                                        |
| Lifecycle Management      |   🟥   |                                        |
| Main Integration          |   🟥   |                                        |
| Record Integration        |   🟥   |                                        |
| Testing & Refinement      |   🟥   |                                        |

## 🔍 Testing Plan

1. Create test entities via dimensional magic
2. Test entity retrieval with different query methods
3. Verify entity lifecycle tracking
4. Test entity persistence and loading
5. Validate entity signal propagation
6. Test integration with memory system

## 📝 Notes & References

- Entity IDs should be unique and deterministic
- Registry should maintain fast lookup capabilities via indexing
- Integration with main.gd should respect existing architectural patterns
- Signal connections should avoid circular references
- Record system integration should support future enhancements