# ButterflyUniversalBeing.gd
# A beautiful flying creature for the Universal Being ecosystem

extends UniversalBeing
class_name ButterflyUniversalBeing

# Butterfly properties
var flight_speed: float = 200.0
var flutter_amplitude: float = 50.0
var flutter_frequency: float = 3.0
var time_passed: float = 0.0
var base_position: Vector2
var color: Color = Color.CYAN

# Visual components
var wing_left: Polygon2D
var wing_right: Polygon2D
var body: Polygon2D

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Blue Butterfly"
	being_type = "butterfly"
	consciousness_level = 3
	name = being_name
	create_butterfly_visuals()
	base_position = position
	
func pentagon_ready() -> void:
	super.pentagon_ready()
	# Add consciousness glow
	var glow = PointLight2D.new()
	glow.texture = preload("res://icon.svg") if preload("res://icon.svg") else null
	glow.scale = Vector2(0.3, 0.3)
	glow.energy = 0.5
	glow.color = color
	add_child(glow)
	
	print("🦋 %s awakened with consciousness level %d!" % [being_name, consciousness_level])

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	time_passed += delta
	
	# Flutter animation
	var flutter_y = sin(time_passed * flutter_frequency) * flutter_amplitude
	position.y = base_position.y + flutter_y
	
	# Wing animation
	if wing_left and wing_right:
		var wing_angle = sin(time_passed * flutter_frequency * 2) * 0.3
		wing_left.rotation = -wing_angle
		wing_right.rotation = wing_angle
	
	# Gentle horizontal movement
	position.x += flight_speed * delta
	if position.x > get_viewport_rect().size.x + 100:
		position.x = -100

func create_butterfly_visuals() -> void:
	# Body
	body = Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(0, -10), Vector2(3, 0), Vector2(0, 10),
		Vector2(-3, 0)
	])
	body.color = Color.BLACK
	add_child(body)
	
	# Left wing
	wing_left = Polygon2D.new()
	wing_left.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(-20, -10), Vector2(-25, 0),
		Vector2(-20, 10), Vector2(-10, 5)
	])
	wing_left.color = color
	wing_left.position = Vector2(-3, 0)
	add_child(wing_left)
	
	# Right wing  
	wing_right = Polygon2D.new()
	wing_right.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(20, -10), Vector2(25, 0),
		Vector2(20, 10), Vector2(10, 5)
	])
	wing_right.color = color
	wing_right.position = Vector2(3, 0)
	add_child(wing_right)

func set_butterfly_color(new_color: Color) -> void:
	color = new_color
	if wing_left:
		wing_left.color = color
	if wing_right:
		wing_right.color = color

func _ready() -> void:
	pentagon_ready()

func _process(delta: float) -> void:
	if pentagon_active:
		pentagon_process(delta)
