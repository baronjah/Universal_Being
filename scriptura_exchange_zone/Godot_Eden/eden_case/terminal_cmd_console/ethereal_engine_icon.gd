extends Node2D
class_name EtherealEngineIcon

"""
EtherealEngineIcon: Visual representation of the Ethereal Engine
Creates a dynamic, animated icon that represents the dimensional 
and symbolic nature of the Ethereal Engine core.
"""

# Icon dimensions
var icon_size = Vector2(64, 64)
var center = Vector2(32, 32)

# Symbol properties
var symbols = ["⬡", "◉", "⚹", "♦", "∞", "△", "◇", "⚛", "⟡", "⦿", "⧉", "✧"]
var symbol_colors = [
	Color(0.9, 0.3, 0.3),  # Red - Genesis
	Color(0.9, 0.6, 0.2),  # Orange - Duality
	Color(0.9, 0.9, 0.2),  # Yellow - Expression
	Color(0.4, 0.9, 0.3),  # Green - Stability
	Color(0.3, 0.9, 0.8),  # Teal - Transformation
	Color(0.3, 0.7, 0.9),  # Light Blue - Balance
	Color(0.3, 0.4, 0.9),  # Blue - Illumination
	Color(0.5, 0.3, 0.9),  # Purple - Reflection
	Color(0.8, 0.3, 0.9),  # Magenta - Harmony
	Color(0.9, 0.3, 0.5),  # Pink - Manifestation
	Color(0.9, 0.3, 0.3),  # Red - Integration
	Color(1.0, 1.0, 1.0),  # White - Transcendence
]

# Animation properties
var rotation_speed = 0.5
var pulse_speed = 2.0
var orbit_speed = 1.0
var time_passed = 0.0

# Runtime variables
var symbol_nodes = []
var center_symbol
var orbiting_symbols = []
var dimensional_rings = []

func _ready():
	# Setup the icon
	setup_icon_components()
	
	# Start animation
	$AnimationTimer.start()

func setup_icon_components():
	# Create the central symbol (represents unity/transcendence)
	center_symbol = create_symbol(symbols[1], center, 1.5, symbol_colors[11])
	add_child(center_symbol)
	
	# Create three dimensional rings
	create_dimensional_rings()
	
	# Create orbiting symbols (one for each dimension)
	create_orbiting_symbols()

func create_dimensional_rings():
	# Create three rings representing different dimensional layers
	for i in range(3):
		var ring = Node2D.new()
		ring.name = "DimensionalRing" + str(i)
		add_child(ring)
		
		# Create a circular path for this ring
		var ring_path = Path2D.new()
		var curve = Curve2D.new()
		var radius = 12 + i * 10
		
		# Add points to create a circle
		for angle in range(0, 360, 10):
			var rad = deg_to_rad(angle)
			var point = Vector2(cos(rad) * radius, sin(rad) * radius) + center
			curve.add_point(point)
		
		# Close the loop
		var rad = deg_to_rad(0)
		var point = Vector2(cos(rad) * radius, sin(rad) * radius) + center
		curve.add_point(point)
		
		ring_path.curve = curve
		ring.add_child(ring_path)
		
		# Store the ring
		dimensional_rings.append(ring)

func create_orbiting_symbols():
	# Create 12 symbols orbiting the center (one for each dimension)
	for i in range(12):
		var angle = deg_to_rad(i * 30)
		var ring_index = i % 3
		var radius = 12 + ring_index * 10
		
		var pos = Vector2(cos(angle) * radius, sin(angle) * radius) + center
		var symbol = create_symbol(symbols[i], pos, 1.0, symbol_colors[i])
		
		# Create path follow for orbiting
		var path_follow = PathFollow2D.new()
		path_follow.name = "SymbolPath" + str(i)
		path_follow.offset = i * (dimensional_rings[ring_index].get_node("DimensionalRing" + str(ring_index)).curve.get_baked_length() / 12)
		path_follow.add_child(symbol)
		
		dimensional_rings[ring_index].get_node("DimensionalRing" + str(ring_index)).add_child(path_follow)
		
		# Store the orbiting symbol
		orbiting_symbols.append({
			"symbol": symbol,
			"path_follow": path_follow,
			"speed": 0.2 + (i % 5) * 0.1,
			"dimension": i + 1
		})

func create_symbol(symbol_text, position, scale_factor, color):
	var symbol_node = Label.new()
	symbol_node.text = symbol_text
	symbol_node.modulate = color
	symbol_node.rect_position = position - Vector2(12, 12) * scale_factor # Center the symbol
	symbol_node.rect_scale = Vector2(scale_factor, scale_factor)
	
	return symbol_node

func _process(delta):
	time_passed += delta
	
	# Rotate the center symbol
	center_symbol.rect_rotation += rotation_speed * delta * 30
	
	# Pulse the center symbol size
	var pulse = (sin(time_passed * pulse_speed) + 1) * 0.2 + 1.3
	center_symbol.rect_scale = Vector2(pulse, pulse)
	
	# Rotate dimensional rings at different speeds
	for i in range(dimensional_rings.size()):
		dimensional_rings[i].rotation += rotation_speed * delta * (i + 1) * 0.3
	
	# Update orbiting symbols
	for i in range(orbiting_symbols.size()):
		var symbol_data = orbiting_symbols[i]
		var path_follow = symbol_data.path_follow
		
		# Move along path at varying speeds
		path_follow.offset += orbit_speed * delta * symbol_data.speed * 100
		
		# Adjust symbol color intensity based on position
		var intensity = (sin(time_passed * 2 + i) + 1) * 0.2 + 0.8
		symbol_data.symbol.modulate = symbol_colors[i] * intensity
		
		# Rotate the symbol
		symbol_data.symbol.rect_rotation += rotation_speed * delta * 20 * (1 + (i % 3))

# Export the icon as a resource
func export_icon():
	# This would be implemented to save the icon as a .png or .tres file
	# For now just a placeholder in this prototype
	print("Icon would be exported here in a full implementation")

func _on_AnimationTimer_timeout():
	# Update animation parameters to keep the icon looking dynamic
	rotation_speed = 0.2 + randf() * 0.5
	pulse_speed = 1.5 + randf() * 1.0
	orbit_speed = 0.8 + randf() * 0.5