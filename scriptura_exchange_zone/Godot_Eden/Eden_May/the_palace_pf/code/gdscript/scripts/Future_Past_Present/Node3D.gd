#@tool
extends Node3D

var galaxy_seed
var galaxy_rng

# Called when the node enters the scene tree for the first time.
func _ready():
	galaxy_seed = 2137
	galaxy_rng = RandomNumberGenerator.new()
	galaxy_rng.seed = galaxy_seed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#var test1: Vector4
	#print("%.1f, %.1f, %.1f, %.1f" % [test1.x, test1.y, test1.z, test1.w])
	#print(test1)
	pass
	#var galaxy_fog_temperature = 1888.01#random_temperature()
	#var galaxy_fog_color = random_color(galaxy_fog_temperature)
	#print("galaxy_fog_color = ", galaxy_fog_color)

func random_color(galaxy_temperature: float) -> Color:
	print("galaxy temp in function = ", galaxy_temperature)
	
	# Define color ranges for different temperature brackets
	var colors = [
		Color(1.0, 0.0, 0.0),   # Red
		Color(1.0, 0.5, 0.0),   # Orange
		Color(1.0, 1.0, 0.0),   # Yellow
		Color(1.0, 1.0, 1.0),   # White
		Color(0.5, 1.0, 1.0),   # Light Blue
		Color(0.0, 0.0, 1.0),   # Blue
		Color(0.5, 0.0, 1.0)    # Purple
	]

	# Define the temperature range
	var min_temp = 2000.0
	var max_temp = 18000.0

	# Clamp temperature between min_temp and max_temp
	var clamped_temp = clamp(galaxy_temperature, min_temp, max_temp)
	
	# Normalize temperature to 0-1 range
	var normalized_temp = (clamped_temp - min_temp) / (max_temp - min_temp)
	
	# Ensure normalized_temp is exactly 0.0 or 1.0 at the extremes
	if is_equal_approx(normalized_temp, 0.0):
		normalized_temp = 0.0
	elif is_equal_approx(normalized_temp, 1.0):
		normalized_temp = 1.0
	
	# Calculate color index
	var color_index = normalized_temp * (colors.size() - 1)
	
	var index1 = int(floor(color_index))
	var index2 = int(ceil(color_index))
	index2 = min(index2, colors.size() - 1)  # Ensure we don't go out of bounds
	
	var t = fmod(color_index, 1.0)
	
	# Interpolate between the two closest colors
	var final_color = colors[index1].lerp(colors[index2], t)
	
	# Apply gamma correction
	final_color.r = pow(final_color.r, 1.0 / 2.2)
	final_color.g = pow(final_color.g, 1.0 / 2.2)
	final_color.b = pow(final_color.b, 1.0 / 2.2)
	
	print("final color maybe lol = ", final_color)
	return final_color

func random_temperature():
	var galaxy_temperature = galaxy_rng.randf_range(0.0, 20000.0)
	print(galaxy_temperature)
	return galaxy_temperature
