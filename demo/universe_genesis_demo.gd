# ==================================================
# UNIVERSAL BEING DEMO: Universe Genesis Example
# TYPE: Demo Script
# PURPOSE: Show how to use the Universe Genesis system
# AUTHOR: Claude Desktop
# DATE: 2025-06-03
# ==================================================

extends Node

func _ready() -> void:
	print("🌌 Universe Genesis Demo Starting...")
	
	# Wait for systems to be ready
	await get_tree().create_timer(1.0).timeout
	
	# Create a console with Universe Genesis component
	var console = create_genesis_console()
	if not console:
		print("❌ Failed to create console")
		return
	
	# Demo: Create universes from templates
	print("\n=== Creating Template Universes ===")
	
	# Create a sandbox universe
	console.process_command("universe template sandbox TestSandbox")
	await get_tree().create_timer(0.5).timeout
	
	# Create a quantum universe
	console.process_command("universe template quantum QuantumRealm")
	await get_tree().create_timer(0.5).timeout
	
	# Create a paradise universe
	console.process_command("universe template paradise Eden")
	await get_tree().create_timer(0.5).timeout
	
	# Demo: Show universe DNA
	print("\n=== Universe DNA ===")
	console.process_command("universe dna")
	await get_tree().create_timer(0.5).timeout
	
	# Demo: Create recursive universes
	print("\n=== Recursive Universe Creation ===")
	console.process_command("universe recursive 3 2")
	await get_tree().create_timer(1.0).timeout
	
	# Demo: Time dilation
	print("\n=== Time Dilation ===")
	console.process_command("universe time 2.5")
	await get_tree().create_timer(0.5).timeout
	
	# Demo: List all universes
	print("\n=== All Universes ===")
	console.process_command("list universes")
	await get_tree().create_timer(0.5).timeout
	
	print("\n🌌 Universe Genesis Demo Complete!")
	print("Press Ctrl+O to open the Universe Simulator and explore visually!")

func create_genesis_console() -> ConversationalConsoleBeing:
	"""Create a console with Universe Genesis component"""
	var ConversationalConsoleClass = load("res://beings/conversational_console_being.gd")
	if not ConversationalConsoleClass:
		return null
	
	var console = ConversationalConsoleClass.new()
	console.name = "Genesis Console Demo"
	add_child(console)
	
	# The component is automatically loaded in pentagon_ready
	return console

# Example natural language commands for the console:
var example_commands = [
	"Create a universe called MyRealm",
	"Make a quantum universe with fast time",
	"Create 5 nested universes",
	"Show me the DNA of this universe",
	"Set gravity to 2.5 in this universe",
	"Enter the universe called Eden",
	"Create a portal to QuantumRealm",
	"Make time go 10 times faster",
	"Split this universe in two",
	"Merge TestSandbox with Eden"
]
