# Add this to ConsoleUniversalBeing.gd in the process_console_command function

# In the "create" case, add:
"butterfly":
	create_butterfly_being()
	
# Then add this function:
func create_butterfly_being() -> void:
	terminal_output("🦋 Creating Butterfly Universal Being...")
	
	# Load butterfly class
	var ButterflyClass = load("res://beings/ButterflyUniversalBeing.gd")
	if not ButterflyClass:
		# Fallback: create basic being with butterfly properties
		var butterfly = SystemBootstrap.create_universal_being()
		if butterfly:
			butterfly.name = "Butterfly Being"
			butterfly.set("being_type", "butterfly") 
			butterfly.set("consciousness_level", 3)
			
			# Add simple visuals
			var sprite = Sprite2D.new()
			sprite.modulate = Color.CYAN
			butterfly.add_child(sprite)
			
			get_tree().current_scene.add_child(butterfly)
			terminal_output("✅ Basic Butterfly created!")
		return
	
	# Create proper butterfly
	var butterfly = ButterflyClass.new()
	get_tree().current_scene.add_child(butterfly)
	butterfly.position = Vector2(400, 300)
	
	terminal_output("✅ Beautiful Butterfly created!")
	terminal_output("🦋 It flies with consciousness level 3!")
	
	# Register with systems
	if SystemBootstrap:
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_being"):
			flood_gates.register_being(butterfly)
			
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("log_event"):
			akashic.log_event({
				"type": "creation",
				"being": "butterfly",
				"consciousness": 3,
				"created_by": "console"
			})
	
	# Notify Gemma
	if GemmaAI:
		GemmaAI.ai_message.emit("🦋 A beautiful butterfly has emerged into being!")

# Also update the create command help:
# In handle_create_command, add to the error message:
terminal_output("🖥️ Can create: button, input, output, tree, butterfly")
