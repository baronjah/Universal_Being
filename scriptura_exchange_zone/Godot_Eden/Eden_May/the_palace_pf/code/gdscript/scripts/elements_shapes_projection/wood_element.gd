#Now let's create a wood element script that can interact with fire. Wood can act as fuel for fire, change its properties as it burns, and eventually turn to ash:

# wood_element.gd - Wood element behavior and properties
# Claude Decipher: Wood elements that can change weight while being consumed by fire

# i think i named it elements.gd

extends "res://code/gdscript/scripts/elements_shapes_projection/base_element.gd"

class_name WoodElement

# Wood-specific properties
var moisture_content: float = 0.4    # 0-1 value, affects burning speed (0=dry, 1=soaked)
var density: float = 1.0             # Density affects burn rate and weight
var fuel_value: float = 100.0        # How much total fuel this wood contains
var burn_resistance: float = 0.3     # How resistant to catching fire (0-1)
var current_heat: float = 0.0        # Current heat level of the wood
var ignition_point: float = 3.0      # Heat required to catch fire
var burning: bool = false            # Whether the wood is currently burning
var char_level: float = 0.0          # 0-1 value of how charred the wood is
var structural_integrity: float = 1.0 # How intact the wood is (affects breaking)

# Physical properties that change during burning
var weight: float = 1.0              # Weight decreases as wood burns
var original_weight: float = 1.0     # Starting weight for reference
var color: Color = Color(0.6, 0.4, 0.2, 1.0)  # Brown wood color
var connected_fires = []             # Fires currently consuming this wood

# Ash transformation
var ash_element_scene = null         # Scene to instance for ash (would be set in editor)
var ash_remaining: float = 0.1       # Percentage that turns to ash (10%)

func _init():
	element_type = "wood"
	attraction_radius = 2.0
	repulsion_radius = 0.8
	connection_strength = 0.9
	evolution_factor = 0.0
	
func _ready():
	# Set up initial wood properties
	add_to_group("wood_elements")
	add_to_group("flammable_elements")
	original_weight = weight
	update_visual_properties()

func _process(delta):
	# Handle heating and cooling
	if current_heat > 0:
		# Wood gradually cools unless being heated
		current_heat = max(0, current_heat - delta * 0.2 * (1.0 - char_level))
	
	# Check if wood should ignite
	if current_heat >= ignition_point and not burning:
		ignite()
	
	# Handle burning process
	if burning:
		process_burning(delta)
	
	# Update physical properties
	update_physical_properties()

func is_flammable():
	# Check if this wood can catch fire
	return moisture_content < 0.8 and not burning and char_level < 0.9

func apply_heat(heat_amount):
	# Wood receiving heat from nearby fire
	var effective_heat = heat_amount * (1.0 - moisture_content * 0.8) * (1.0 - burn_resistance)
	
	# Wet wood takes longer to heat up
	if moisture_content > 0.6:
		# Evaporate some moisture before heating significantly
		moisture_content = max(0.0, moisture_content - heat_amount * 0.05)
		effective_heat *= 0.3
	
	current_heat += effective_heat
	
	# Update visual properties based on heating
	if current_heat > ignition_point * 0.5 and not burning:
		# Wood beginning to smolder/char before fully igniting
		char_level = min(0.3, current_heat / ignition_point * 0.3)
		update_visual_properties()
		
	return effective_heat  # Return how much heat was effectively absorbed

func ignite():
	# Wood catches fire
	burning = true
	
	# Create fire element on the wood if it doesn't already have one
	if connected_fires.size() == 0:
		create_fire_on_surface()

func create_fire_on_surface():
	# Create a fire element on this wood
	var fire_element = load("res://code/gdscript/scripts/elements_shapes_projection/fire_element.gd").new()
	fire_element.global_position = global_position + Vector3(0, 0.5, 0)
	fire_element.heat_intensity = 1.0
	get_parent().add_child(fire_element)
	
	# Connect the fire to this wood as fuel source
	connect_fire(fire_element)
	
	return fire_element

func connect_fire(fire):
	# Connect a fire element to this wood as a fuel source
	if not connected_fires.has(fire):
		connected_fires.append(fire)
		if fire.has_method("connect_to_fuel_source"):
			fire.connect_to_fuel_source(self)

func disconnect_fire(fire):
	# Disconnect a fire from this wood
	if connected_fires.has(fire):
		connected_fires.erase(fire)

func process_burning(delta):
	# Handle the burning process
	if fuel_value <= 0:
		burning = false
		convert_to_ash()
		return
	
	# Calculate burn rate based on wood properties
	var burn_rate = 0.2 * (1.0 - moisture_content * 0.5) * (1.0 + char_level * 0.5)
	
	# Denser wood burns slower but lasts longer
	burn_rate *= (2.0 - density)
	
	# Actual fuel consumption this frame
	var fuel_consumed = burn_rate * delta
	
	# Adjust based on connected fires
	if connected_fires.size() > 0:
		fuel_consumed *= 1.0 + (connected_fires.size() * 0.2)
	
	# Apply fuel consumption
	fuel_value = max(0, fuel_value - fuel_consumed)
	
	# Update charring
	char_level = min(1.0, char_level + (fuel_consumed / (original_weight * 50)))
	
	# Update structural integrity
	structural_integrity = max(0.1, 1.0 - char_level * 0.9)
	
	# Update weight based on fuel consumed
	update_weight(fuel_consumed)
	
	# Check for breaking due to burning
	check_structural_failure()

func update_weight(fuel_consumed):
	# Weight decreases as wood burns
	var weight_loss = fuel_consumed * 0.5  # Not all mass is lost as some becomes char/ash
	weight = max(original_weight * ash_remaining, weight - weight_loss)
	
	# Update mass for physics
	mass = weight  # Directly update the mass property instead of using a setter

func provide_fuel(requested_amount):
	# Provide fuel to connected fire elements
	if fuel_value <= 0 or not burning:
		return 0.0
	
	var actual_amount = min(requested_amount, fuel_value * 0.1)  # Limit how much can be taken at once
	fuel_value -= actual_amount
	
	return actual_amount

func check_structural_failure():
	# Wood can break/collapse when burned too much
	if structural_integrity < 0.3 and fuel_value > 0:
		if randf() < (1.0 - structural_integrity) * 0.1:
			break_apart()

func break_apart():
	# Wood breaks into smaller pieces when structural integrity fails
	for i in range(2):  # Create two smaller wood pieces
		var new_wood = WoodElement.new()
		new_wood.global_position = global_position + Vector3(randf() - 0.5, 0, randf() - 0.5)
		new_wood.fuel_value = fuel_value * 0.3
		new_wood.char_level = char_level
		new_wood.moisture_content = moisture_content
		new_wood.burning = burning
		new_wood.weight = weight * 0.4
		new_wood.original_weight = new_wood.weight
		new_wood.structural_integrity = structural_integrity * 0.8
		get_parent().add_child(new_wood)
		
		# Transfer some of the fire to the new piece
		if burning and connected_fires.size() > 0:
			var fire = connected_fires[0].duplicate()
			fire.global_position = new_wood.global_position + Vector3(0, 0.2, 0)
			fire.heat_intensity *= 0.7
			get_parent().add_child(fire)
			new_wood.connect_fire(fire)
	
	# Destroy this piece
	queue_free()

func convert_to_ash():
	# Wood fully burned, convert to ash
	# Always create ash from script since we're not using scenes
	var ash = load("res://code/gdscript/scripts/elements_shapes_projection/ash_element.gd").new()
	if ash:
		ash.global_position = global_position
		ash.scale = Vector3(1, 0.2, 1) * scale.x  # Ash is flatter
		if ash.has_method("set_amount"):
			ash.set_amount(weight * ash_remaining)
		else:
			# Direct property assignment if no setter method
			ash.amount = weight * ash_remaining
		get_parent().add_child(ash)
	
	# Disconnect any remaining fires
	for fire in connected_fires.duplicate():
		if is_instance_valid(fire):
			disconnect_fire(fire)
	
	# Remove the wood
	queue_free()

func update_visual_properties():
	# Update visual appearance based on current state
	if char_level > 0.8:
		color = Color(0.1, 0.1, 0.1, 1.0)  # Almost fully charred
	elif char_level > 0.5:
		color = Color(0.2, 0.2, 0.2, 1.0)  # Heavily charred
	elif char_level > 0.2:
		color = Color(0.3, 0.25, 0.2, 1.0)  # Partially charred
	elif current_heat > ignition_point * 0.7:
		color = Color(0.5, 0.3, 0.1, 1.0)  # Hot but not burning
	
	# Apply color to material if available
	var mesh_instance = get_node_or_null("MeshInstance3D")
	if mesh_instance and mesh_instance.material_override:
		mesh_instance.material_override.albedo_color = color

func absorb_water(amount):
	# Wood can absorb water, increasing moisture content
	moisture_content = min(1.0, moisture_content + amount * 0.5)
	
	# Water can extinguish burning wood
	if burning and amount > 0.5:
		var extinguish_chance = amount * 0.7
		if randf() < extinguish_chance:
			burning = false
			current_heat *= 0.3
			
			# Disconnect fires
			for fire in connected_fires.duplicate():
				if is_instance_valid(fire):
					disconnect_fire(fire)
					if fire.has_method("extinguish"):
						fire.extinguish()
	
	return moisture_content

func update_physical_properties():
	# Update scale based on remaining fuel and charring
	var size_factor = 0.5 + (fuel_value / (original_weight * 100)) * 0.5
	var height_factor = 1.0 - char_level * 0.3  # Charred wood shrinks a bit
	
	scale = Vector3(size_factor, height_factor * size_factor, size_factor)
