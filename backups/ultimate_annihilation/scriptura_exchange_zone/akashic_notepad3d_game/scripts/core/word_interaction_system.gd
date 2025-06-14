extends Node3D
## Word Interaction System for handling 3D word entities
class_name WordInteractionSystem

var word_entities: Dictionary = {}
var main_controller: Node3D
var word_container: Node3D
var lod_manager: LODManager

func initialize(container: Node3D, controller: Node3D) -> void:
	word_container = container
	main_controller = controller

func update(delta: float) -> void:
	# Update word animations and interactions
	for word_entity in word_entities.values():
		if word_entity.has_method("update"):
			word_entity.update(delta)

func interact_with_word(raycast_result: Dictionary) -> void:
	if raycast_result.has("collider"):
		var collider = raycast_result.collider
		var word_entity = collider.get_parent()
		
		if word_entity.has_method("on_interact"):
			word_entity.on_interact()
			main_controller.selected_word = word_entity

func load_words_for_level(word_data: Array) -> void:
	# Clear existing words
	_clear_existing_words()
	
	# Create new word entities for this level with stable positions
	for data in word_data:
		create_word_visual(data)
	
	print("Loaded ", word_data.size(), " words in stable grid layout")

func create_word_visual(word_data: Dictionary) -> void:
	var word_entity = WordEntity.new()
	word_entity.initialize(word_data)
	word_container.add_child(word_entity)
	word_entities[word_data.id] = word_entity
	
	# Register with LOD manager if available
	if lod_manager:
		lod_manager.register_word_entity(word_entity)

func update_word_visual(word_id: String, properties: Dictionary) -> void:
	if word_entities.has(word_id):
		word_entities[word_id].update_properties(properties)

func _clear_existing_words() -> void:
	for word_entity in word_entities.values():
		# Unregister from LOD manager
		if lod_manager:
			lod_manager.unregister_word_entity(word_entity)
		word_entity.queue_free()
	word_entities.clear()