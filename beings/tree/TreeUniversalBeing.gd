# ==================================================
# SCRIPT NAME: TreeUniversalBeing.gd
# DESCRIPTION: A living tree being for the Universal Being ecosystem
# PURPOSE: Create beautiful trees that grow and respond to consciousness
# CREATED: 2025-12-01
# ==================================================

extends UniversalBeing
class_name TreeUniversalBeing

# Godot lifecycle functions removed - base UniversalBeing handles bridging to Pentagon Architecture

# Tree properties
var growth_stage: int = 0  # 0-5 stages
var trunk_height: float = 100.0
var branch_count: int = 5
var leaf_count: int = 20
var sway_amount: float = 0.0
var time_passed: float = 0.0
var season: String = "spring"

# Visual components
var trunk: Line2D
var branches: Array[Line2D] = []
var leaves: Array[Polygon2D] = []

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Sacred Tree"
	being_type = "tree"
	consciousness_level = 2
	name = being_name
	position = Vector3(0, 0, 0)  # Anchor at ground level

func pentagon_ready() -> void:
	super.pentagon_ready()
	create_tree_structure()
	print("🌳 %s planted with consciousness level %d!" % [being_name, consciousness_level])

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	time_passed += delta
	
	# Gentle swaying
	sway_amount = sin(time_passed * 0.5) * 0.02
	rotation.z = sway_amount
	
	# Grow over time
	if growth_stage < 5 and time_passed > growth_stage * 10.0:
		grow_tree()

func create_tree_structure() -> void:
	# Create trunk
	trunk = Line2D.new()
	trunk.width = 8.0
	trunk.default_color = Color(0.4, 0.3, 0.2)  # Brown
	trunk.add_point(Vector2(0, 0))
	trunk.add_point(Vector2(0, -trunk_height))
	add_child(trunk)
	
	# Create branches
	for i in branch_count:
		var branch = Line2D.new()
		branch.width = 4.0
		branch.default_color = Color(0.5, 0.4, 0.3)
		
		var branch_y = -trunk_height * (0.5 + i * 0.1)
		var branch_x = randf_range(-50, 50)
		
		branch.add_point(Vector2(0, branch_y))
		branch.add_point(Vector2(branch_x, branch_y - 30))
		
		add_child(branch)
		branches.append(branch)
		
		# Add leaves to branch
		create_leaves_on_branch(branch, Vector2(branch_x, branch_y - 30))

func create_leaves_on_branch(branch: Line2D, end_pos: Vector2) -> void:
	for j in randi_range(3, 6):
		var leaf = Polygon2D.new()
		
		# Leaf shape
		var leaf_points = PackedVector2Array([
			Vector2(0, 0),
			Vector2(5, -10),
			Vector2(0, -15),
			Vector2(-5, -10)
		])
		
		leaf.polygon = leaf_points
		leaf.color = get_season_color()
		
		# Position on branch
		var t = randf()
		var leaf_pos = end_pos * t
		leaf.position = leaf_pos
		leaf.rotation = randf_range(-PI/4, PI/4)
		leaf.scale = Vector2.ONE * randf_range(0.8, 1.2)
		
		add_child(leaf)
		leaves.append(leaf)

func get_season_color() -> Color:
	match season:
		"spring": return Color(0.3, 0.8, 0.3)  # Light green
		"summer": return Color(0.2, 0.6, 0.2)  # Dark green
		"autumn": return Color(0.9, 0.6, 0.2)  # Orange
		"winter": return Color(0.6, 0.6, 0.6)  # Gray
		_: return Color(0.3, 0.7, 0.3)

func grow_tree() -> void:
	growth_stage += 1
	trunk_height += 20
	
	# Update trunk
	trunk.set_point_position(1, Vector2(0, -trunk_height))
	
	# Add new branches
	var new_branch = Line2D.new()
	new_branch.width = 4.0
	new_branch.default_color = Color(0.5, 0.4, 0.3)
	
	var branch_y = -trunk_height * 0.8
	var branch_x = randf_range(-60, 60)
	
	new_branch.add_point(Vector2(0, branch_y))
	new_branch.add_point(Vector2(branch_x, branch_y - 40))
	
	add_child(new_branch)
	branches.append(new_branch)
	create_leaves_on_branch(new_branch, Vector2(branch_x, branch_y - 40))
	
	print("🌳 %s grew to stage %d!" % [being_name, growth_stage])

func set_season(new_season: String) -> void:
	season = new_season
	# Update all leaves
	for leaf in leaves:
		leaf.color = get_season_color()
