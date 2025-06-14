extends Node

# This script ensures the OpenAIGateway is registered as a singleton
# Add this script to your project's autoload list

func _ready():
	# Check if OpenAIGateway singleton exists
	if not Engine.has_singleton("OpenAIGateway"):
		# Create and register the OpenAIGateway instance
		var openai_gateway = load("res://scripts/api/OpenAIGateway.gd").new()
		openai_gateway.name = "OpenAIGateway"
		get_tree().root.add_child(openai_gateway)
		
		print("OpenAIGateway singleton registered")
	
	# Initialize connections to other systems
	_connect_to_existing_systems()

func _connect_to_existing_systems():
	# Wait a frame to ensure all other autoloads are ready
	await get_tree().process_frame
	
	var openai_gateway = get_node_or_null("/root/OpenAIGateway")
	if not openai_gateway:
		print("ERROR: Failed to find OpenAIGateway singleton")
		return
	
	# Connect to MemoryEvolutionManager if it exists
	var memory_manager = get_node_or_null("/root/MemoryEvolutionManager")
	if memory_manager:
		# Connect signals as needed
		if not openai_gateway.word_transformed.is_connected(memory_manager.catch_word):
			openai_gateway.word_transformed.connect(memory_manager.catch_word)
		
		print("Connected OpenAIGateway to MemoryEvolutionManager")
	
	# Connect to WordTranslator if it exists
	var word_translator = get_node_or_null("/root/WordTranslator")
	if word_translator:
		# Assign reference
		openai_gateway.word_processor = word_translator
		
		print("Connected OpenAIGateway to WordTranslator")