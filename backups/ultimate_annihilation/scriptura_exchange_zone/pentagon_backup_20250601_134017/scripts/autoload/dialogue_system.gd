# ==================================================
# SCRIPT NAME: dialogue_system.gd
# DESCRIPTION: Manages ragdoll dialogue and speech patterns
# CREATED: 2025-05-23 - Making the ragdoll talk!
# ==================================================

extends UniversalBeingBase
# Custom dialogue that can be added via console
var custom_dialogue_queue: Array[String] = []

# Dialogue variations for personality
var current_mood: String = "normal"
var mood_modifiers: Dictionary = {
	"happy": ["Haha! ", "Wheee! ", "Oh joy! "],
	"grumpy": ["Ugh... ", "Great, just great... ", "Why me? "],
	"philosophical": ["One might say... ", "In the grand scheme... ", "Existentially speaking... "]
}


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func make_ragdoll_say(text: String) -> void:
	custom_dialogue_queue.append(text)
	
	# Find ragdoll and make it say the text immediately
	var ragdolls = get_tree().get_nodes_in_group("ragdoll")
	if not ragdolls.is_empty():
		var ragdoll = ragdolls[0]
		if ragdoll.has_method("_say_something_custom"):
			ragdoll._say_something_custom(text)

func get_next_custom_dialogue() -> String:
	if custom_dialogue_queue.is_empty():
		return ""
	return custom_dialogue_queue.pop_front()

func set_mood(new_mood: String) -> void:
	if new_mood in mood_modifiers:
		current_mood = new_mood

func modify_dialogue(base_text: String) -> String:
	if current_mood == "normal":
		return base_text
	
	var prefix = mood_modifiers[current_mood][randi() % mood_modifiers[current_mood].size()]
	return prefix + base_text

func show_dialogue(text: String, position: Vector3) -> void:
	# Create a 3D label for the dialogue
	var label = Label3D.new()
	label.text = text
	label.font_size = 24
	label.outline_size = 2
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = Color(1, 1, 1, 1)
	label.position = position
	
	# Add to scene
	get_tree().FloodgateController.universal_add_child(label, get_tree().current_scene)
	
	# Animate fade out
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", position + Vector3(0, 2, 0), 3.0)
	tween.tween_property(label, "modulate:a", 0.0, 3.0)
	tween.chain().tween_callback(label.queue_free)