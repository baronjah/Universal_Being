extends Node
class_name InteractionMatrix

# Interaction Matrix defines how different entity types interact with each other
# This class provides a structured way to define and access interaction rules

# Matrix storage: maps [type1][type2] -> interaction_result
var interaction_rules = {}

# Default base interactions for primordial entities
var base_interactions = {
	"intensify": {
		"description": "Increases intensity of both entities",
		"effects": ["increase_energy", "increase_stability"],
		"transformation_chance": 0.1
	},
	"merge": {
		"description": "Entities merge into a new form",
		"effects": ["combine_properties", "create_new_entity"],
		"transformation_chance": 0.4
	},
	"consume": {
		"description": "One entity consumes the other",
		"effects": ["transfer_energy", "remove_consumed"],
		"transformation_chance": 0.2
	},
	"transform": {
		"description": "Triggers transformation in one or both entities",
		"effects": ["increase_transformation_energy"],
		"transformation_chance": 0.6
	},
	"repel": {
		"description": "Entities repel each other",
		"effects": ["decrease_proximity", "increase_velocity"],
		"transformation_chance": 0.0
	},
	"catalyze": {
		"description": "One entity catalyzes transformation in the other",
		"effects": ["increase_transformation_energy", "maintain_catalyst"],
		"transformation_chance": 0.8
	}
}

# Element-specific interaction definitions
var element_interactions = {
	"fire": {
		"fire": "intensify",
		"water": "diminish",
		"wood": "consume",
		"ash": "consume"
	},
	"water": {
		"fire": "diminish",
		"water": "merge",
		"wood": "nurture",
		"ash": "dissolve"
	},
	"wood": {
		"fire": "burn",
		"water": "absorb",
		"wood": "grow",
		"ash": "nutrients"
	},
	"ash": {
		"fire": "resist",
		"water": "muddy",
		"wood": "fertilize",
		"ash": "settle"
	}
}

# Detailed interaction results
var interaction_details = {
	# Fire interactions
	"intensify": {
		"description": "The fire grows more intense",
		"result_type": "property_change",
		"effects": {
			"energy": 0.2,
			"heat": 0.3,
			"stability": -0.1
		},
		"transformation": {
			"chance": 0.2,
			"target": "energy"
		}
	},
	"diminish": {
		"description": "The fire is extinguished",
		"result_type": "state_change",
		"effects": {
			"energy": -0.5,
			"heat": -0.8,
			"stability": 0.3
		},
		"transformation": {
			"chance": 0.4,
			"target": "ash"
		}
	},
	"burn": {
		"description": "The wood burns, creating ash and more fire",
		"result_type": "create",
		"effects": {
			"energy": 0.3,
			"heat": 0.4
		},
		"create": {
			"type": "ash",
			"position": "mid"
		},
		"transformation": {
			"chance": 0.7,
			"target": "ash"
		}
	},
	"consume": {
		"description": "Fire consumes the material",
		"result_type": "consume",
		"effects": {
			"energy": 0.4,
			"size": 0.2
		},
		"consume": {
			"target": "other",
			"energy_transfer": 0.7
		}
	},
	
	# Water interactions
	"dissolve": {
		"description": "Water dissolves the material",
		"result_type": "state_change",
		"effects": {
			"clarity": -0.3,
			"flow": -0.1
		},
		"state_change": {
			"new_state": "dissolved"
		}
	},
	"merge": {
		"description": "Waters combine into a larger body",
		"result_type": "merge",
		"effects": {
			"volume": 0.5,
			"flow": 0.2
		},
		"merge": {
			"retain_properties": ["clarity", "flow"],
			"combine_properties": ["volume", "energy"]
		}
	},
	"nurture": {
		"description": "Water nurtures growth",
		"result_type": "property_change",
		"effects": {
			"growth": 0.4,
			"stability": 0.2
		},
		"property_change": {
			"target": "other",
			"growth": 0.4
		}
	},
	
	# Wood interactions
	"grow": {
		"description": "Wood grows stronger",
		"result_type": "property_change",
		"effects": {
			"size": 0.3,
			"strength": 0.2
		},
		"transformation": {
			"chance": 0.1,
			"target": "tree"
		}
	},
	"absorb": {
		"description": "Wood absorbs water",
		"result_type": "property_change",
		"effects": {
			"stability": 0.2,
			"flexibility": 0.3
		},
		"consume": {
			"target": "other",
			"amount": 0.6
		}
	},
	"nutrients": {
		"description": "Wood gains nutrients from ash",
		"result_type": "property_change",
		"effects": {
			"growth": 0.5,
			"stability": 0.2
		},
		"consume": {
			"target": "other",
			"amount": 0.8
		}
	},
	
	# Ash interactions
	"settle": {
		"description": "Ash settles and compacts",
		"result_type": "property_change",
		"effects": {
			"density": 0.3,
			"stability": 0.4
		},
		"transformation": {
			"chance": 0.1,
			"target": "earth"
		}
	},
	"resist": {
		"description": "Ash resists further burning",
		"result_type": "block",
		"effects": {
			"energy": -0.3
		}
	},
	"muddy": {
		"description": "Ash and water create mud",
		"result_type": "create",
		"create": {
			"type": "mud",
			"position": "mid",
			"consume_parents": true
		}
	},
	"fertilize": {
		"description": "Ash fertilizes wood",
		"result_type": "property_change",
		"effects": {
			"growth": 0.6,
			"stability": 0.2
		},
		"consume": {
			"target": "self",
			"amount": 0.9
		}
	}
}

# Initialize basic interaction matrix
func _init():
	# Initialize base types
	var base_types = ["primordial", "fire", "water", "wood", "ash"]
	
	# Create empty structure
	for type1 in base_types:
		interaction_rules[type1] = {}
		for type2 in base_types:
			if type1 == "primordial" and type2 == "primordial":
				# Default interaction for primordial entities
				interaction_rules[type1][type2] = "transform"
			elif type1 == "primordial" or type2 == "primordial":
				# Primordial interactions
				interaction_rules[type1][type2] = "catalyze"
			elif element_interactions.has(type1) and element_interactions[type1].has(type2):
				# Element-specific interaction
				interaction_rules[type1][type2] = element_interactions[type1][type2]
			else:
				# Default interaction
				interaction_rules[type1][type2] = "repel"

# Get interaction rule between two entity types
func get_interaction(type1: String, type2: String) -> Dictionary:
	# Check if we have a defined interaction
	var interaction_name = ""
	
	if interaction_rules.has(type1) and interaction_rules[type1].has(type2):
		interaction_name = interaction_rules[type1][type2]
	elif interaction_rules.has(type2) and interaction_rules[type2].has(type1):
		# Try reverse lookup
		interaction_name = interaction_rules[type2][type1]
	else:
		# Default to repel if no interaction defined
		interaction_name = "repel"
	
	# Look up detailed interaction info
	if interaction_details.has(interaction_name):
		var result = interaction_details[interaction_name].duplicate(true)
		result["name"] = interaction_name
		return result
	else:
		# Return a default interaction if not found
		return {
			"name": interaction_name,
			"description": "Default interaction",
			"result_type": "none",
			"effects": {}
		}

# Register a new interaction between types
func register_interaction(type1: String, type2: String, interaction_name: String) -> void:
	# Ensure type entries exist
	if not interaction_rules.has(type1):
		interaction_rules[type1] = {}
	
	# Register the interaction
	interaction_rules[type1][type2] = interaction_name
	
	# Output for debugging
	print("Registered interaction: " + type1 + " + " + type2 + " -> " + interaction_name)

# Define a new interaction result
func define_interaction(interaction_name: String, details: Dictionary) -> void:
	interaction_details[interaction_name] = details.duplicate(true)
	print("Defined interaction details for: " + interaction_name)

# Process an interaction between two entities
func process_interaction(entity1_type: String, entity2_type: String, context: Dictionary = {}) -> Dictionary:
	# Get the interaction rule
	var interaction = get_interaction(entity1_type, entity2_type)
	
	# Prepare result
	var result = {
		"success": true,
		"interaction": interaction.name,
		"description": interaction.description,
		"type": interaction.get("result_type", "none"),
		"effects": []
	}
	
	# Apply context-specific modifiers if needed
	if context.has("intensity"):
		# Modify effects based on intensity
		var intensity = context.intensity
		if interaction.has("effects"):
			for effect_name in interaction.effects:
				var effect_value = interaction.effects[effect_name] * intensity
				result[effect_name] = effect_value
				result.effects.append(effect_name + ": " + str(effect_value))
	else:
		# Use default effects
		if interaction.has("effects"):
			for effect_name in interaction.effects:
				result[effect_name] = interaction.effects[effect_name]
				result.effects.append(effect_name + ": " + str(interaction.effects[effect_name]))
	
	# Handle transformation chance
	if interaction.has("transformation"):
		var transform_data = interaction.transformation
		var chance = transform_data.chance
		
		# Apply context modifiers to chance
		if context.has("catalyst"):
			chance += 0.2
		if context.has("inhibitor"):
			chance -= 0.2
		
		# Check if transformation should occur
		if randf() <= chance:
			result["transformation"] = {
				"triggered": true,
				"target": transform_data.target
			}
		else:
			result["transformation"] = {
				"triggered": false
			}
	
	# Handle creation of new entities
	if interaction.has("create"):
		var create_data = interaction.create
		result["create"] = {
			"type": create_data.type,
			"position": create_data.position,
			"consume_parents": create_data.get("consume_parents", false)
		}
	
	# Handle consumption of entities
	if interaction.has("consume"):
		var consume_data = interaction.consume
		result["consume"] = {
			"target": consume_data.target,
			"amount": consume_data.get("amount", 1.0),
			"energy_transfer": consume_data.get("energy_transfer", 0.0)
		}
	
	return result

# Debug: Print the entire interaction matrix
func print_matrix() -> void:
	print("=== INTERACTION MATRIX ===")
	for type1 in interaction_rules.keys():
		for type2 in interaction_rules[type1].keys():
			var interaction = interaction_rules[type1][type2]
			print(type1 + " + " + type2 + " -> " + interaction)
	print("=======================")