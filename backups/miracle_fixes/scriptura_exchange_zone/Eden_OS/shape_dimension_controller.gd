extends Node

class_name ShapeDimensionController

signal shape_transcended(shape_id, from_dimension, to_dimension)
signal shape_attuned(shape_id, color_enum)
signal zone_evolved(zone_id, new_properties)
signal dimension_resonance_changed(dimension, resonance_value)

# References to other systems
var shape_system: ShapeSystem
var dimensional_color_system: DimensionalColorSystem
var turn_cycle_manager: TurnCycleManager
var astral_entity_system: AstralEntitySystem

# Dimensional resonance values (1-9 dimensions)
var dimensional_resonance = {
	1: 1.0,  # Foundation
	2: 1.0,  # Growth
	3: 1.0,  # Energy
	4: 1.0,  # Insight
	5: 1.0,  # Force
	6: 1.0,  # Vision
	7: 1.0,  # Wisdom
	8: 1.0,  # Transcendence
	9: 1.0   # Unity
}

# Shape evolution tracking
var shape_evolution_stages = {}  # shape_id -> evolution stage
var zone_evolution_stages = {}   # zone_id -> evolution stage

# Constants
const MIN_RESONANCE = 0.2
const MAX_RESONANCE = 2.0
const RESONANCE_CHANGE_STEP = 0.05
const EVOLUTION_THRESHOLD = 5.0  # Accumulated energy needed for evolution

func _ready():
	# Initialize systems
	shape_system = get_node_or_null("/root/ShapeSystem")
	if not shape_system:
		shape_system = ShapeSystem.new()
		add_child(shape_system)
	
	dimensional_color_system = get_node_or_null("/root/DimensionalColorSystem")
	if not dimensional_color_system:
		dimensional_color_system = DimensionalColorSystem.new()
		add_child(dimensional_color_system)
	
	turn_cycle_manager = get_node_or_null("/root/TurnCycleManager")
	astral_entity_system = get_node_or_null("/root/AstralEntitySystem")
	
	# Connect signals
	if turn_cycle_manager:
		turn_cycle_manager.turn_completed.connect(_on_turn_completed)
		turn_cycle_manager.cycle_completed.connect(_on_cycle_completed)
	
	shape_system.shape_created.connect(_on_shape_created)
	shape_system.shape_transformed.connect(_on_shape_transformed)
	shape_system.shape_merged.connect(_on_shape_merged)
	shape_system.zone_created.connect(_on_zone_created)

func _on_turn_completed(turn_number):
	# Process dimensional resonance changes based on current turn
	var current_color = turn_cycle_manager.turn_color_mapping[turn_number - 1]
	var current_dimension = dimensional_color_system.color_properties[current_color].dimensional_depth
	
	# Enhance resonance for the current dimension
	_modify_dimensional_resonance(current_dimension, RESONANCE_CHANGE_STEP)
	
	# Slightly decrease resonance for other dimensions
	for dim in range(1, 10):
		if dim != current_dimension:
			_modify_dimensional_resonance(dim, -RESONANCE_CHANGE_STEP * 0.5)
	
	# Process shape evolution for shapes in the current dimension
	for shape_id in shape_system.shapes:
		var shape = shape_system.shapes[shape_id]
		if shape.dimension == current_dimension:
			_process_shape_evolution(shape_id, 0.2)  # Small evolution step
		
		# Attune shape to current turn's color if it matches the shape's dimension
		if shape.dimension == current_dimension:
			_attune_shape_to_color(shape_id, current_color)

func _on_cycle_completed():
	# Major evolution step at the end of a cycle
	for shape_id in shape_system.shapes:
		_process_shape_evolution(shape_id, 1.0)  # Large evolution step
	
	for zone_id in shape_system.zones:
		_process_zone_evolution(zone_id)
	
	# Create entities for evolved shapes
	_sync_shapes_with_entities()

func _on_shape_created(shape_id, shape_type):
	# Initialize evolution stage for the new shape
	shape_evolution_stages[shape_id] = 0.0
	
	# If turn cycle manager exists, attune to current turn's color
	if turn_cycle_manager:
		var current_turn = turn_cycle_manager.current_turn
		if current_turn > 0:
			var current_color = turn_cycle_manager.turn_color_mapping[current_turn - 1]
			_attune_shape_to_color(shape_id, current_color)

func _on_shape_transformed(shape_id, transformation_type):
	# When a shape is transformed, add small evolution energy
	_process_shape_evolution(shape_id, 0.1)

func _on_shape_merged(shape_id1, shape_id2, new_shape_id):
	# When shapes merge, combine their evolution energy
	var evolution1 = shape_evolution_stages.get(shape_id1, 0.0)
	var evolution2 = shape_evolution_stages.get(shape_id2, 0.0)
	
	# New shape starts with average evolution plus bonus
	shape_evolution_stages[new_shape_id] = (evolution1 + evolution2) / 2.0 + 0.5
	
	# Clean up old shapes
	shape_evolution_stages.erase(shape_id1)
	shape_evolution_stages.erase(shape_id2)

func _on_zone_created(zone_id, zone_properties):
	# Initialize evolution stage for the new zone
	zone_evolution_stages[zone_id] = 0.0

func _modify_dimensional_resonance(dimension: int, change: float):
	if dimension < 1 or dimension > 9:
		return
	
	dimensional_resonance[dimension] += change
	
	# Clamp to valid range
	dimensional_resonance[dimension] = clamp(
		dimensional_resonance[dimension],
		MIN_RESONANCE,
		MAX_RESONANCE
	)
	
	emit_signal("dimension_resonance_changed", dimension, dimensional_resonance[dimension])

func _process_shape_evolution(shape_id: String, energy: float):
	if not shape_system.shapes.has(shape_id):
		return
	
	var shape = shape_system.shapes[shape_id]
	
	# Apply dimensional resonance as a multiplier
	energy *= dimensional_resonance[shape.dimension]
	
	# Add energy to the shape's evolution stage
	if not shape_evolution_stages.has(shape_id):
		shape_evolution_stages[shape_id] = 0.0
	
	shape_evolution_stages[shape_id] += energy
	
	# Check if evolution threshold is reached
	if shape_evolution_stages[shape_id] >= EVOLUTION_THRESHOLD:
		_evolve_shape(shape_id)

func _evolve_shape(shape_id: String):
	if not shape_system.shapes.has(shape_id):
		return
	
	var shape = shape_system.shapes[shape_id]
	
	# Reset evolution energy
	shape_evolution_stages[shape_id] = 0.0
	
	# Determine if shape should transcend to next dimension
	var current_dim = shape.dimension
	var next_dim = current_dim + 1
	
	if next_dim <= 9:  # Maximum dimension is 9
		# Transform the shape as it transcends
		var center = shape.get_center()
		
		# Create transformation effect - apply slight scaling
		var params = {
			"scale_factor": 1.1,
			"center": center
		}
		shape_system.transform_shape(shape_id, ShapeSystem.TransformationType.SCALE, params)
		
		# Update the shape's dimension
		shape.dimension = next_dim
		
		# Update the shape's color to match the new dimension
		var new_dim_color = dimensional_color_system.get_color_for_dimension(next_dim)
		shape.color = dimensional_color_system.get_color_value(new_dim_color)
		
		emit_signal("shape_transcended", shape_id, current_dim, next_dim)

func _process_zone_evolution(zone_id: String):
	if not shape_system.zones.has(zone_id):
		return
	
	var zone = shape_system.zones[zone_id]
	
	# Calculate zone energy based on shapes it contains
	var energy = 0.0
	var shapes_count = zone.shapes.size()
	
	if shapes_count > 0:
		# Add energy based on shapes and their connections
		energy += shapes_count * 0.2
		
		var total_connections = 0
		for shape_id in zone.shapes:
			if shape_system.shapes.has(shape_id):
				var shape = shape_system.shapes[shape_id]
				total_connections += shape.connected_shapes.size()
		
		energy += total_connections * 0.1
		
		# Apply dimensional resonance
		energy *= dimensional_resonance[zone.dimension]
		
		# Add energy to zone evolution
		if not zone_evolution_stages.has(zone_id):
			zone_evolution_stages[zone_id] = 0.0
		
		zone_evolution_stages[zone_id] += energy
		
		# Check for evolution
		if zone_evolution_stages[zone_id] >= EVOLUTION_THRESHOLD:
			_evolve_zone(zone_id)

func _evolve_zone(zone_id: String):
	if not shape_system.zones.has(zone_id):
		return
	
	var zone = shape_system.zones[zone_id]
	
	# Reset evolution energy
	zone_evolution_stages[zone_id] = 0.0
	
	# New properties for the evolved zone
	var new_properties = {
		"evolution_level": zone.properties.get("evolution_level", 0) + 1,
		"stability": zone.properties.get("stability", 1.0) + 0.2,
		"energy_capacity": zone.properties.get("energy_capacity", 1.0) * 1.5
	}
	
	# Update zone properties
	for key in new_properties:
		zone.properties[key] = new_properties[key]
	
	# Expand zone boundaries slightly
	zone.expand_boundaries(Vector2(20, 20))
	
	emit_signal("zone_evolved", zone_id, new_properties)

func _attune_shape_to_color(shape_id: String, color_enum: int):
	if not shape_system.shapes.has(shape_id):
		return
	
	var shape = shape_system.shapes[shape_id]
	
	# Check if the shape's dimension resonates with this color
	var shape_dim = shape.dimension
	var color_dim = dimensional_color_system.color_properties[color_enum].dimensional_depth
	
	# Colors resonate most strongly with their matching dimension
	var resonance = dimensional_color_system.get_dimensional_resonance(
		dimensional_color_system.get_color_for_dimension(shape_dim),
		color_enum
	)
	
	# Only attune if there's enough resonance
	if resonance > 0.5:
		# Slightly blend the shape's color toward the attunement color
		var attunement_color = dimensional_color_system.get_color_value(color_enum)
		shape.color = shape.color.lerp(attunement_color, 0.2)
		
		# Add color attunement property to the shape
		if not shape.properties.has("color_attunements"):
			shape.properties["color_attunements"] = []
		
		var attunements = shape.properties["color_attunements"]
		if not color_enum in attunements:
			attunements.append(color_enum)
			shape.properties["color_attunements"] = attunements
		
		emit_signal("shape_attuned", shape_id, color_enum)

func _sync_shapes_with_entities():
	if not astral_entity_system:
		return
		
	for shape_id in shape_system.shapes:
		var shape = shape_system.shapes[shape_id]
		
		# Check if this shape already has an entity
		var entity_id = ""
		var shape_entity_id = shape.properties.get("entity_id", "")
		
		if shape_entity_id and astral_entity_system.get_entity(shape_entity_id):
			entity_id = shape_entity_id
		else:
			# Create a new entity for this shape
			var shape_name = shape.properties.get("name", "Shape_" + shape_id.split("_")[1])
			var entity_type = AstralEntitySystem.EntityType.CREATION
			
			entity_id = astral_entity_system.create_entity(shape_name, entity_type)
			
			# Link shape to entity
			shape.properties["entity_id"] = entity_id
		
		# Update entity properties to match shape
		var entity = astral_entity_system.get_entity(entity_id)
		if entity:
			# Set dimensional presence
			entity.dimensional_presence.add_dimension(shape.dimension, 1.0)
			
			# Copy color attunements
			if shape.properties.has("color_attunements"):
				for color_enum in shape.properties["color_attunements"]:
					entity.add_color_attunement(color_enum)
			
			# Set shape properties
			entity.properties["shape_id"] = shape_id
			entity.properties["shape_type"] = shape.type
			entity.properties["point_count"] = shape.points.size()
			
			# Connect entities for shapes that are connected
			for connected_shape_id in shape.connected_shapes:
				if shape_system.shapes.has(connected_shape_id):
					var connected_shape = shape_system.shapes[connected_shape_id]
					if connected_shape.properties.has("entity_id"):
						var connected_entity_id = connected_shape.properties["entity_id"]
						entity.connect_to(connected_entity_id)

func get_dimension_dominant_shape(dimension: int) -> String:
	# Find the most evolved shape in a dimension
	var max_evolution = 0.0
	var dominant_shape_id = ""
	
	for shape_id in shape_system.shapes:
		var shape = shape_system.shapes[shape_id]
		if shape.dimension == dimension:
			var evolution = shape_evolution_stages.get(shape_id, 0.0)
			if evolution > max_evolution:
				max_evolution = evolution
				dominant_shape_id = shape_id
	
	return dominant_shape_id

func create_zone_from_shapes(shapes: Array, name: String) -> String:
	if shapes.size() == 0:
		return ""
	
	# Calculate bounding box for all shapes
	var min_x = 9999999.0
	var min_y = 9999999.0
	var max_x = -9999999.0
	var max_y = -9999999.0
	
	var total_dimension = 0
	
	for shape_id in shapes:
		if shape_system.shapes.has(shape_id):
			var shape = shape_system.shapes[shape_id]
			var bbox = shape.get_bounding_box()
			
			min_x = min(min_x, bbox.position.x)
			min_y = min(min_y, bbox.position.y)
			max_x = max(max_x, bbox.position.x + bbox.size.x)
			max_y = max(max_y, bbox.position.y + bbox.size.y)
			
			total_dimension += shape.dimension
	
	# Add padding to the zone
	min_x -= 20
	min_y -= 20
	max_x += 20
	max_y += 20
	
	var boundaries = Rect2(min_x, min_y, max_x - min_x, max_y - min_y)
	
	# Average dimension of all shapes
	var avg_dimension = int(total_dimension / shapes.size())
	if avg_dimension < 1:
		avg_dimension = 1
	
	# Create the zone
	var zone_id = shape_system.create_zone(name, boundaries, avg_dimension)
	
	# Add shapes to the zone
	for shape_id in shapes:
		if shape_system.shapes.has(shape_id):
			shape_system.add_shape_to_zone(shape_id, zone_id)
	
	return zone_id

func manifest_entity_as_shape(entity_id: String, position: Vector2) -> String:
	if not astral_entity_system or not astral_entity_system.get_entity(entity_id):
		return ""
	
	var entity = astral_entity_system.get_entity(entity_id)
	
	# Determine shape type based on entity type
	var shape_type = ShapeSystem.ShapeType.CUSTOM
	match entity.type:
		AstralEntitySystem.EntityType.THOUGHT:
			shape_type = ShapeSystem.ShapeType.SPIRAL
		AstralEntitySystem.EntityType.MEMORY:
			shape_type = ShapeSystem.ShapeType.CIRCLE
		AstralEntitySystem.EntityType.CONCEPT:
			shape_type = ShapeSystem.ShapeType.HEXAGON
		AstralEntitySystem.EntityType.ESSENCE:
			shape_type = ShapeSystem.ShapeType.STAR
		AstralEntitySystem.EntityType.WORD:
			shape_type = ShapeSystem.ShapeType.TRIANGLE
		AstralEntitySystem.EntityType.INTENTION:
			shape_type = ShapeSystem.ShapeType.PENTAGON
		AstralEntitySystem.EntityType.CREATION:
			shape_type = ShapeSystem.ShapeType.SQUARE
	
	# Determine size based on entity's evolution stage
	var size = 30.0 + entity.evolution_stage * 5.0
	
	# Determine dimension from entity's primary dimension
	var dimension = entity.dimensional_presence.get_primary_dimension()
	
	# Create the shape
	var shape_id = shape_system.create_standard_shape(shape_type, position, size, dimension)
	
	if shape_id and shape_system.shapes.has(shape_id):
		var shape = shape_system.shapes[shape_id]
		
		# Link shape to entity
		shape.properties["entity_id"] = entity_id
		shape.properties["name"] = entity.name
		
		# Copy color attunements
		for color in entity.color_attunement:
			if not shape.properties.has("color_attunements"):
				shape.properties["color_attunements"] = []
			shape.properties["color_attunements"].append(color)
		
		# Update entity properties
		entity.properties["shape_id"] = shape_id
	
	return shape_id

func get_shapes_by_attunement(color_enum: int) -> Array:
	var result = []
	
	for shape_id in shape_system.shapes:
		var shape = shape_system.shapes[shape_id]
		if shape.properties.has("color_attunements"):
			var attunements = shape.properties["color_attunements"]
			if color_enum in attunements:
				result.append(shape_id)
	
	return result

func generate_shape_report(shape_id: String) -> String:
	if not shape_system.shapes.has(shape_id):
		return "Shape not found"
	
	var shape = shape_system.shapes[shape_id]
	var report = "Shape Report: " + shape_id + "\n"
	report += "=======================\n\n"
	
	report += "Type: " + ShapeSystem.ShapeType.keys()[shape.type] + "\n"
	report += "Dimension: " + str(shape.dimension) + "\n"
	report += "Points: " + str(shape.points.size()) + "\n"
	report += "Center: " + str(shape.get_center()) + "\n"
	report += "Creation Time: " + Time.get_datetime_string_from_unix_time(shape.creation_time) + "\n"
	
	# Evolution info
	report += "Evolution Energy: " + str(shape_evolution_stages.get(shape_id, 0.0)) + " / " + str(EVOLUTION_THRESHOLD) + "\n"
	
	# Color attunements
	if shape.properties.has("color_attunements"):
		report += "\nColor Attunements:\n"
		for color_enum in shape.properties["color_attunements"]:
			report += "- " + dimensional_color_system.DimColor.keys()[color_enum] + "\n"
	
	# Connected shapes
	if shape.connected_shapes.size() > 0:
		report += "\nConnected Shapes:\n"
		for connected_id in shape.connected_shapes:
			if shape_system.shapes.has(connected_id):
				var connected_shape = shape_system.shapes[connected_id]
				report += "- " + ShapeSystem.ShapeType.keys()[connected_shape.type]
				if connected_shape.properties.has("name"):
					report += " (" + connected_shape.properties.name + ")"
				report += "\n"
	
	# Associated entity
	if shape.properties.has("entity_id") and astral_entity_system:
		var entity_id = shape.properties["entity_id"]
		var entity = astral_entity_system.get_entity(entity_id)
		if entity:
			report += "\nAssociated Entity:\n"
			report += "Name: " + entity.name + "\n"
			report += "Type: " + AstralEntitySystem.EntityType.keys()[entity.type] + "\n"
			report += "Evolution Stage: " + AstralEntitySystem.EvolutionStage.keys()[entity.evolution_stage] + "\n"
	
	return report