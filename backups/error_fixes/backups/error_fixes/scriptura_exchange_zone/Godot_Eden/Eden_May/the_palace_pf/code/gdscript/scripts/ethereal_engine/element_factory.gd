# element_factory.gd
class_name ElementFactory
extends Node

# Registry of all possible elements that can be created
var element_registry = {
	"water": {
		"base_molecule": "H2O",
		"states": ["solid", "liquid", "gas"],
		"default_state": "liquid",
		"properties": {
			"density": 1.0,
			"color": Color(0, 0.5, 1.0, 0.8)
		}
	},
	# Other elements...
}

static func create_element(type, properties):
	if type in element_registry:
		var base_properties = element_registry[type].duplicate(true)
		
		# Override with provided properties
		for key in properties:
			if key in base_properties.properties:
				base_properties.properties[key] = properties[key]
				
		# Create the element instance
		var element_scene = load("res://elements/" + type + ".tscn")
		var element = element_scene.instance()
		
		# Configure the element
		element.initialize(base_properties)
		
		return element
	else:
		push_error("Unknown element type: " + type)
		return null
