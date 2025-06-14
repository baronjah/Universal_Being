# world_grid.gd
extends Node2D

class_name WorldGrid

# Grid dimensions
var width: int = 100
var height: int = 100

# The main grid data structure
var grid = []
var entity_grid = []  # For tracking entities in each cell

# Environment layers (can be expanded)
var moisture_layer = []
var temperature_layer = []
var nutrient_layer = []

func _ready():
	initialize_grid()
	
func initialize_grid():
	# Initialize empty grid
	grid = []
	entity_grid = []
	moisture_layer = []
	temperature_layer = []
	nutrient_layer = []
	
	for x in range(width):
		grid.append([])
		entity_grid.append([])
		moisture_layer.append([])
		temperature_layer.append([])
		nutrient_layer.append([])
		
		for y in range(height):
			grid[x].append({
				"type": "empty",
				"variant": 0
			})
			entity_grid[x].append([])  # Array of entities at this position
			moisture_layer[x].append(randf())  # Random initial values
			temperature_layer[x].append(randf())
			nutrient_layer[x].append(randf())
	
	# Visualization will be handled separately
	update_visual_representation()

func get_cell(x: int, y: int) -> Dictionary:
	if x >= 0 and x < width and y >= 0 and y < height:
		return grid[x][y]
	return {"type": "invalid"}
	
func set_cell(x: int, y: int, data: Dictionary) -> void:
	if x >= 0 and x < width and y >= 0 and y < height:
		grid[x][y] = data
		emit_signal("cell_changed", x, y, data)
		# This will trigger the ripple effect system
		propagate_changes(x, y, data)
		update_visual_representation()

func propagate_changes(x: int, y: int, data: Dictionary) -> void:
	# This is where the ripple effect happens
	# Example: If a water source is placed, increase moisture in surrounding cells
	if data["type"] == "water":
		for dx in range(-3, 4):
			for dy in range(-3, 4):
				var nx = x + dx
				var ny = y + dy
				if nx >= 0 and nx < width and ny >= 0 and ny < height:
					var distance = sqrt(dx*dx + dy*dy)
					if distance > 0:
						moisture_layer[nx][ny] += 0.2 / distance
						moisture_layer[nx][ny] = clamp(moisture_layer[nx][ny], 0.0, 1.0)
						
	# More propagation rules can be added here
	
func update_visual_representation():
	# Update the TileMap or other visual elements
	# This would be implemented based on your visual design
	pass
