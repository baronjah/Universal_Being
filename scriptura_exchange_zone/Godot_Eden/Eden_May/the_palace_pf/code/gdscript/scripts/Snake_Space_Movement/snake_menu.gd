extends Node
class_name SnakeMenuHandler
# JSH_World/grid
#
# res://code/gdscript/scripts/Snake_Space_Movement/snake_menu.gd
# Reference to main node
var main_ref = null

# Menu state
var current_menu_page = 0
var menu_pages = ["main", "instructions", "high_scores"]
var menu_container_name = "snake_menu_container"

# High scores storage
var high_scores = []

func _ready_thingy():
	# Find main reference
	var scene_root = get_tree().get_root()
	if scene_root.has_node("main"):
		main_ref = scene_root.get_node("main")
	
	# Load high scores if they exist
	load_high_scores()

# Handle menu button clicks
func handle_button_click(button_name):
	match button_name:
		"Play Game", "thing_4" when current_menu_page == 0:
			launch_snake_game()
		
		"Instructions", "thing_5" when current_menu_page == 0:
			show_menu_page(1)  # Show instructions page
		
		"High Scores", "thing_6" when current_menu_page == 0:
			show_menu_page(2)  # Show high scores page
		
		"Back", "thing_7":
			if current_menu_page == 0:
				# Main menu back button - return to desktop
				hide_snake_menu()
			else:
				# Submenus back button - return to main menu
				show_menu_page(0)  # Show main menu

# Launch the snake game
func launch_snake_game(difficulty = "normal"):
	# Hide menu
	hide_snake_menu()
	
	# Launch game
	if main_ref:
		if main_ref.has_method("launch_snake_game"):
			main_ref.launch_snake_game(difficulty)
		else:
			# Fallback to basic methods if the launcher doesn't exist
			if main_ref.has_method("three_stages_of_creation_snake"):
				main_ref.three_stages_of_creation_snake("snake_game")
			if main_ref.has_method("show_snake_game"):
				main_ref.show_snake_game()

# Show specific menu page
func show_menu_page(page_index):
	current_menu_page = page_index
	
	# Use the scenes framework to show the page
	if main_ref and main_ref.has_method("show_menu_scene"):
		main_ref.show_menu_scene("snake_menu", page_index)
	else:
		# Fallback if show_menu_scene doesn't exist
		_create_menu_page(page_index)

# Hide the snake menu
func hide_snake_menu():
	if main_ref and main_ref.has_method("hide_menu_container"):
		main_ref.hide_menu_container(menu_container_name)
	else:
		# Fallback
		var container = get_node_or_null("../" + menu_container_name)
		if container:
			container.visible = false

# Add a high score
func add_high_score(score, player_name = "Player"):
	high_scores.append({
		"score": score,
		"player": player_name,
		"date": Time.get_date_string_from_system()
	})
	
	# Sort by score (highest first)
	high_scores.sort_custom(func(a, b): return a.score > b.score)
	
	# Keep only top 10
	if high_scores.size() > 10:
		high_scores.resize(10)
	
	# Save high scores
	save_high_scores()
	
	# Update high scores display if visible
	if current_menu_page == 2:
		_update_high_scores_display()

# Load high scores from file
func load_high_scores():
	# Use Godot's file system to load scores
	if FileAccess.file_exists("user://snake_high_scores.dat"):
		var file = FileAccess.open("user://snake_high_scores.dat", FileAccess.READ)
		var content = file.get_as_text()
		
		if content:
			var data = JSON.parse_string(content)
			if data:
				high_scores = data

# Save high scores to file
func save_high_scores():
	var file = FileAccess.open("user://snake_high_scores.dat", FileAccess.WRITE)
	file.store_string(JSON.stringify(high_scores))

# Fallback menu creation if scenes framework isn't available
func _create_menu_page(page_index):
	# Clear existing menu items
	for child in get_children():
		child.queue_free()
	
	# Build menu based on page index
	match page_index:
		0:  # Main menu
			_create_main_menu()
		1:  # Instructions
			_create_instructions_menu()
		2:  # High scores
			_create_high_scores_menu()

# Create main menu items
func _create_main_menu():
	# Create title
	var title = Label3D.new()
	title.text = "Snake Game"
	title.position = Vector3(0, 4, 0.1)
	add_child(title)
	
	# Create buttons
	_create_button("Play Game", Vector3(-2, 2, 0.1), Color(0, 0.7, 0, 1))
	_create_button("Instructions", Vector3(-2, 0, 0.1), Color(0.3, 0.5, 0.9, 1))
	_create_button("High Scores", Vector3(-2, -2, 0.1), Color(0.9, 0.7, 0.1, 1))
	_create_button("Back", Vector3(-2, -4, 0.1), Color(0.5, 0.5, 0.5, 1))

# Create instructions menu items
func _create_instructions_menu():
	# Create title
	var title = Label3D.new()
	title.text = "How to Play"
	title.position = Vector3(0, 4, 0.1)
	add_child(title)
	
	# Create instruction text
	var instructions = [
		"Use arrow keys or WASD to move the snake",
		"Eat food to grow longer",
		"Avoid hitting walls and yourself"
	]
	
	for i in range(instructions.size()):
		var text = Label3D.new()
		text.text = instructions[i]
		text.position = Vector3(-4, 2 - i, 0.1)
		add_child(text)
	
	# Back button
	_create_button("Back", Vector3(-2, -4, 0.1), Color(0.5, 0.5, 0.5, 1))

# Create high scores menu
func _create_high_scores_menu():
	# Create title
	var title = Label3D.new()
	title.text = "High Scores"
	title.position = Vector3(0, 4, 0.1)
	add_child(title)
	
	# Create high scores list
	_update_high_scores_display()
	
	# Back button
	_create_button("Back", Vector3(-2, -4, 0.1), Color(0.5, 0.5, 0.5, 1))

# Update high scores display
func _update_high_scores_display():
	# Remove existing score displays
	var existingScores = get_tree().get_nodes_in_group("high_score_text")
	for node in existingScores:
		node.queue_free()
	
	# Display scores
	for i in range(min(high_scores.size(), 5)):
		var score_data = high_scores[i]
		var text = Label3D.new()
		text.add_to_group("high_score_text")
		text.text = "%d. %s: %d" % [i+1, score_data.player, score_data.score]
		text.position = Vector3(-3, 2 - i, 0.1)
		add_child(text)
	
	# If no scores
	if high_scores.size() == 0:
		var text = Label3D.new()
		text.add_to_group("high_score_text")
		text.text = "No high scores yet!"
		text.position = Vector3(-2, 1, 0.1)
		add_child(text)

# Create a button with text
func _create_button(label_text, position, color = Color(0.5, 0.5, 0.5, 1)):
	# Create button container
	var button = Node3D.new()
	button.name = label_text.replace(" ", "_")
	button.position = position
	add_child(button)
	
	# Create button mesh
	var button_mesh = MeshInstance3D.new()
	button.add_child(button_mesh)
	
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(3, 0.6)
	button_mesh.mesh = quad_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	button_mesh.material_override = material
	
	# Create button text
	var text = Label3D.new()
	text.text = label_text
	text.position.z = 0.01
	button.add_child(text)
	
	# Add click area
	var area = Area3D.new()
	button.add_child(area)
	
	var collision = CollisionShape3D.new()
	area.add_child(collision)
	
	var shape = BoxShape3D.new()
	shape.size = Vector3(3, 0.6, 0.1)
	collision.shape = shape
	
	# Connect click signal
	area.input_event.connect(func(camera, event, pos, normal, shape_idx): 
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			handle_button_click(label_text)
	)
	
	return button
