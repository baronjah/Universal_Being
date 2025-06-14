extends SceneTree

# Simple tool script to generate a static icon for the Ethereal Engine
# Run this with Godot from command line to generate the icon

func _init():
	print("Generating Ethereal Engine icon...")
	
	# Create an image
	var img = Image.new()
	img.create(64, 64, false, Image.FORMAT_RGBA8)
	
	# Fill with dark background
	img.fill(Color(0.1, 0.1, 0.15, 1.0))
	
	# Draw the central symbol
	draw_symbol(img, "◉", Vector2(32, 32), 3.0, Color(1, 1, 1, 0.9))
	
	# Draw orbital symbols
	var colors = [
		Color(0.9, 0.3, 0.3),  # Red
		Color(0.9, 0.6, 0.2),  # Orange
		Color(0.9, 0.9, 0.2),  # Yellow
		Color(0.4, 0.9, 0.3),  # Green
		Color(0.3, 0.9, 0.8),  # Teal
		Color(0.3, 0.7, 0.9),  # Light Blue
	]
	
	var symbols = ["⬡", "⚹", "♦", "∞", "△", "◇"]
	
	# Draw first orbital ring
	for i in range(6):
		var angle = deg_to_rad(i * 60)
		var pos = Vector2(cos(angle) * 18, sin(angle) * 18) + Vector2(32, 32)
		draw_symbol(img, symbols[i], pos, 1.8, colors[i])
	
	# Draw an outer ring
	draw_circle(img, Vector2(32, 32), 26, Color(0.5, 0.5, 1.0, 0.3), 1)
	
	# Save the image
	img.save_png("res://ethereal_engine_icon.png")
	
	print("Icon saved to ethereal_engine_icon.png")
	quit()

func draw_symbol(img, symbol, position, scale, color):
	# This is a simplification since we can't easily draw text on an Image
	# In a real implementation, you'd use a Font to render text to an ImageTexture
	
	# For now, just draw a simple shape based on the symbol
	match symbol:
		"◉":  # Center symbol - filled circle
			draw_filled_circle(img, position, 8 * scale, color)
		"⬡":  # Hexagon
			draw_filled_circle(img, position, 5 * scale, color)
		"⚹":  # Star
			draw_star(img, position, 6 * scale, color)
		"♦":  # Diamond
			draw_filled_circle(img, position, 4 * scale, color)
		"∞":  # Infinity
			draw_filled_circle(img, position, 4 * scale, color)
		"△":  # Triangle
			draw_filled_circle(img, position, 5 * scale, color)
		"◇":  # Diamond
			draw_filled_circle(img, position, 4 * scale, color)
		_:    # Default
			draw_filled_circle(img, position, 3 * scale, color)

func draw_filled_circle(img, center, radius, color):
	# Simple circle drawing algorithm
	for x in range(max(0, int(center.x - radius)), min(img.get_width(), int(center.x + radius + 1))):
		for y in range(max(0, int(center.y - radius)), min(img.get_height(), int(center.y + radius + 1))):
			var dist = Vector2(x, y).distance_to(center)
			if dist <= radius:
				var alpha = 1.0 - (dist / radius) * 0.5
				var pixel_color = Color(color.r, color.g, color.b, color.a * alpha)
				blend_pixel(img, x, y, pixel_color)

func draw_circle(img, center, radius, color, thickness=1):
	# Simple circle outline drawing algorithm
	for x in range(max(0, int(center.x - radius - thickness)), min(img.get_width(), int(center.x + radius + thickness + 1))):
		for y in range(max(0, int(center.y - radius - thickness)), min(img.get_height(), int(center.y + radius + thickness + 1))):
			var dist = Vector2(x, y).distance_to(center)
			if dist >= radius - thickness and dist <= radius + thickness:
				var alpha = 1.0 - abs(dist - radius) / thickness
				var pixel_color = Color(color.r, color.g, color.b, color.a * alpha)
				blend_pixel(img, x, y, pixel_color)

func draw_star(img, center, radius, color):
	# Draw a simple star
	var points = 5
	var inner_radius = radius * 0.4
	
	for i in range(points * 2):
		var angle = deg_to_rad(i * 180 / points)
		var r = radius if i % 2 == 0 else inner_radius
		var pos = Vector2(cos(angle) * r, sin(angle) * r) + center
		
		if i > 0:
			draw_line(img, prev_pos, pos, color)
		
		var prev_pos = pos
	
	# Connect the last point to the first
	var first_angle = 0
	var first_pos = Vector2(cos(first_angle) * radius, sin(first_angle) * radius) + center
	draw_line(img, prev_pos, first_pos, color)

func draw_line(img, from, to, color):
	# Simple line drawing algorithm
	var delta = to - from
	var steps = max(abs(delta.x), abs(delta.y))
	
	if steps < 1:
		return
	
	var step = delta / steps
	
	for i in range(steps + 1):
		var pos = from + step * i
		var x = int(pos.x)
		var y = int(pos.y)
		
		if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
			blend_pixel(img, x, y, color)

func blend_pixel(img, x, y, color):
	# Get existing color
	var existing = img.get_pixel(x, y)
	
	# Blend the new color with the existing color
	var blended = Color(
		existing.r * (1 - color.a) + color.r * color.a,
		existing.g * (1 - color.a) + color.g * color.a,
		existing.b * (1 - color.a) + color.b * color.a,
		existing.a + color.a * (1 - existing.a)
	)
	
	img.set_pixel(x, y, blended)