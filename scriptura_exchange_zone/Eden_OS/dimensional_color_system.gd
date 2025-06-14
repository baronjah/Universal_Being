extends Node

class_name DimensionalColorSystem

# The 9 base dimensional colors + 3 extension colors
enum DimColor {
	AZURE,     # Dimension 1 - Foundation, associated with basic reality perception
	EMERALD,   # Dimension 2 - Growth, associated with expansion and evolution
	AMBER,     # Dimension 3 - Energy, associated with vital force and power
	VIOLET,    # Dimension 4 - Insight, associated with perception beyond physical
	CRIMSON,   # Dimension 5 - Force, associated with will and intention
	INDIGO,    # Dimension 6 - Vision, associated with far-seeing and prophecy
	SAPPHIRE,  # Dimension 7 - Wisdom, associated with deep understanding
	GOLD,      # Dimension 8 - Transcendence, associated with ascending consciousness
	SILVER,    # Dimension 9 - Unity, associated with oneness and completion
	OBSIDIAN,  # Extension 1 - Void, associated with emptiness and potential
	PLATINUM,  # Extension 2 - Ascension, associated with highest evolution
	DIAMOND    # Extension 3 - Purity, associated with perfect clarity
}

# Color value mapping
var color_values = {
	DimColor.AZURE: Color("#1E90FF"),
	DimColor.EMERALD: Color("#50C878"),
	DimColor.AMBER: Color("#FFBF00"),
	DimColor.VIOLET: Color("#8F00FF"),
	DimColor.CRIMSON: Color("#DC143C"),
	DimColor.INDIGO: Color("#4B0082"),
	DimColor.SAPPHIRE: Color("#0F52BA"),
	DimColor.GOLD: Color("#FFD700"),
	DimColor.SILVER: Color("#C0C0C0"),
	DimColor.OBSIDIAN: Color("#1A1110"),
	DimColor.PLATINUM: Color("#E5E4E2"),
	DimColor.DIAMOND: Color("#B9F2FF")
}

# Each color has specific properties and affinities
var color_properties = {
	DimColor.AZURE: {
		"vibrational_frequency": 1.0,
		"dimensional_depth": 1,
		"resonance_pattern": "linear",
		"stability_factor": 0.9,
		"essence": "foundation",
		"affinity": ["water", "air", "crystal"]
	},
	DimColor.EMERALD: {
		"vibrational_frequency": 1.2,
		"dimensional_depth": 2,
		"resonance_pattern": "spiral",
		"stability_factor": 0.85,
		"essence": "growth",
		"affinity": ["plant", "forest", "healing"]
	},
	DimColor.AMBER: {
		"vibrational_frequency": 1.4,
		"dimensional_depth": 3,
		"resonance_pattern": "radial",
		"stability_factor": 0.8,
		"essence": "energy",
		"affinity": ["sun", "fire", "vitality"]
	},
	DimColor.VIOLET: {
		"vibrational_frequency": 1.6,
		"dimensional_depth": 4,
		"resonance_pattern": "wave",
		"stability_factor": 0.75,
		"essence": "insight",
		"affinity": ["dream", "vision", "perception"]
	},
	DimColor.CRIMSON: {
		"vibrational_frequency": 1.8,
		"dimensional_depth": 5,
		"resonance_pattern": "pulse",
		"stability_factor": 0.7,
		"essence": "force",
		"affinity": ["blood", "power", "passion"]
	},
	DimColor.INDIGO: {
		"vibrational_frequency": 2.0,
		"dimensional_depth": 6,
		"resonance_pattern": "quantum",
		"stability_factor": 0.65,
		"essence": "vision",
		"affinity": ["space", "time", "foresight"]
	},
	DimColor.SAPPHIRE: {
		"vibrational_frequency": 2.2,
		"dimensional_depth": 7,
		"resonance_pattern": "tessellate",
		"stability_factor": 0.6,
		"essence": "wisdom",
		"affinity": ["knowledge", "truth", "depth"]
	},
	DimColor.GOLD: {
		"vibrational_frequency": 2.4,
		"dimensional_depth": 8,
		"resonance_pattern": "fractal",
		"stability_factor": 0.55,
		"essence": "transcendence",
		"affinity": ["light", "sun", "divinity"]
	},
	DimColor.SILVER: {
		"vibrational_frequency": 2.6,
		"dimensional_depth": 9,
		"resonance_pattern": "harmonic",
		"stability_factor": 0.5,
		"essence": "unity",
		"affinity": ["moon", "reflection", "wholeness"]
	},
	DimColor.OBSIDIAN: {
		"vibrational_frequency": 2.8,
		"dimensional_depth": 10,
		"resonance_pattern": "void",
		"stability_factor": 0.4,
		"essence": "emptiness",
		"affinity": ["darkness", "potential", "mystery"]
	},
	DimColor.PLATINUM: {
		"vibrational_frequency": 3.0,
		"dimensional_depth": 11,
		"resonance_pattern": "ascension",
		"stability_factor": 0.3,
		"essence": "perfection",
		"affinity": ["evolution", "refinement", "mastery"]
	},
	DimColor.DIAMOND: {
		"vibrational_frequency": 3.2,
		"dimensional_depth": 12,
		"resonance_pattern": "absolute",
		"stability_factor": 0.2,
		"essence": "purity",
		"affinity": ["clarity", "perfection", "ultimate"]
	}
}

# Color combinations create emergent properties
var combination_matrix = {}

func _ready():
	_initialize_combination_matrix()

func _initialize_combination_matrix():
	# Generate all possible color combinations and their properties
	var colors = color_values.keys()
	for i in range(colors.size()):
		for j in range(i, colors.size()):
			var color1 = colors[i]
			var color2 = colors[j]
			var combined_properties = _calculate_combined_properties(color1, color2)
			combination_matrix[color1 * 100 + color2] = combined_properties
			combination_matrix[color2 * 100 + color1] = combined_properties

func _calculate_combined_properties(color1, color2):
	var properties1 = color_properties[color1]
	var properties2 = color_properties[color2]
	
	# Calculate blended properties
	var combined = {
		"vibrational_frequency": (properties1.vibrational_frequency + properties2.vibrational_frequency) / 2.0,
		"dimensional_depth": max(properties1.dimensional_depth, properties2.dimensional_depth),
		"resonance_pattern": properties1.dimensional_depth > properties2.dimensional_depth ? properties1.resonance_pattern : properties2.resonance_pattern,
		"stability_factor": (properties1.stability_factor + properties2.stability_factor) / 2.0,
		"essence": properties1.essence + "-" + properties2.essence,
		"affinity": []
	}
	
	# Merge affinities
	for aff in properties1.affinity:
		combined.affinity.append(aff)
	for aff in properties2.affinity:
		if not aff in combined.affinity:
			combined.affinity.append(aff)
	
	return combined

func get_color_value(color_enum) -> Color:
	return color_values[color_enum]

func get_color_property(color_enum, property: String):
	if color_properties.has(color_enum) and color_properties[color_enum].has(property):
		return color_properties[color_enum][property]
	return null

func get_combined_properties(color1, color2):
	var key = color1 * 100 + color2
	if combination_matrix.has(key):
		return combination_matrix[key]
	return null

func blend_colors(color1_enum, color2_enum, ratio: float = 0.5) -> Color:
	var color1 = get_color_value(color1_enum)
	var color2 = get_color_value(color2_enum)
	
	return color1.lerp(color2, ratio)

func get_complementary_color(color_enum) -> int:
	# Returns the complementary color in the dimensional system
	var dimensional_depth = color_properties[color_enum].dimensional_depth
	var complement_depth = (dimensional_depth + 6) % 12
	if complement_depth == 0:
		complement_depth = 12
	
	# Find the color with this depth
	for col_enum in color_properties:
		if color_properties[col_enum].dimensional_depth == complement_depth:
			return col_enum
	
	return color_enum  # Default to same color if no complement found

func get_color_for_dimension(dimension: int) -> int:
	# Get the appropriate color for a specific dimension
	for col_enum in color_properties:
		if color_properties[col_enum].dimensional_depth == dimension:
			return col_enum
	
	# Default to AZURE if dimension not found
	return DimColor.AZURE

func get_dimensional_resonance(color_enum1, color_enum2) -> float:
	# Calculate resonance between two colors based on their dimensional properties
	var depth1 = color_properties[color_enum1].dimensional_depth
	var depth2 = color_properties[color_enum2].dimensional_depth
	var freq1 = color_properties[color_enum1].vibrational_frequency
	var freq2 = color_properties[color_enum2].vibrational_frequency
	
	var depth_diff = abs(depth1 - depth2)
	var freq_ratio = min(freq1, freq2) / max(freq1, freq2)
	
	# Higher resonance for harmonious relationships (depths with mathematical relationships)
	var harmonic = 1.0
	if depth_diff == 0: # Same dimension
		harmonic = 2.0
	elif depth_diff == 3 or depth_diff == 4 or depth_diff == 6: # Musical intervals
		harmonic = 1.5
	elif depth_diff == 7: # Perfect fifth in music
		harmonic = 1.8
	
	return freq_ratio * harmonic * (1.0 - (depth_diff / 12.0))