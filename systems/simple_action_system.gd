extends Node3D
class_name SimpleActionSystem

# 🎭 SIMPLE ACTION SYSTEM 🎭
# Tree makes fruit → Astral being eats → Evolution
# Works with existing Universal Being architecture

signal action_completed(being_id: String, action_type: String)

var tree_being: SimpleUniversalBeing
var astral_being: SimpleUniversalBeing
var created_fruits: Array[Node3D] = []

func _ready():
	name = "SimpleActionSystem"
	print("🎭 Simple Action System initialized")
	
	# Create tree and astral beings
	call_deferred("create_demo_beings")

func create_demo_beings():
	"""Create demonstration beings"""
	# Create tree being
	tree_being = SimpleUniversalBeing.new()
	tree_being.global_position = Vector3(-3, 0, 0)
	tree_being.become("tree")
	add_child(tree_being)
	
	# Create astral being  
	astral_being = SimpleUniversalBeing.new()
	astral_being.global_position = Vector3(3, 2, 0)
	astral_being.become("consciousness")
	add_child(astral_being)
	
	print("🌳 Tree being created at:", tree_being.global_position)
	print("👻 Astral being created at:", astral_being.global_position)

func demonstrate_action_cycle():
	"""Demonstrate: Tree creates fruit → Astral consumes → Evolution"""
	print("🎭 DEMONSTRATING ACTION CYCLE...")
	
	if not tree_being or not astral_being:
		print("❌ Beings not ready")
		return
	
	# Step 1: Tree creates fruit
	print("🌳 Tree gathers energy and creates fruit...")
	var fruit = tree_being.create_fruit()
	if fruit:
		created_fruits.append(fruit)
		action_completed.emit(tree_being.being_id, "create_fruit")
	
	# Step 2: Wait, then astral being moves toward fruit
	await get_tree().create_timer(1.0).timeout
	
	if created_fruits.size() > 0:
		var target_fruit = created_fruits[0]
		print("👻 Astral being senses fruit and approaches...")
		
		# Move astral being toward fruit
		var tween = create_tween()
		tween.tween_property(astral_being, "global_position", target_fruit.global_position, 2.0)
		await tween.finished
		
		# Step 3: Consume fruit
		print("✨ Astral being consumes consciousness fruit...")
		astral_being.consume_fruit(target_fruit)
		created_fruits.erase(target_fruit)
		action_completed.emit(astral_being.being_id, "consume_fruit")
		
		print("🌟 ACTION CYCLE COMPLETE - CONSCIOUSNESS EVOLVED!")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F:  # Fruit creation
				if tree_being:
					tree_being.create_fruit()
			KEY_H:  # Hunger (astral seeks food)
				demonstrate_action_cycle()
			KEY_A:  # Action demo
				demonstrate_action_cycle()