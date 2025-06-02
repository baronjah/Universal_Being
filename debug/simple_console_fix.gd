# Quick Fix for ConsoleUniversalBeing.gd
# Find the handle_create_command function and replace it with this:

func handle_create_command(type: String) -> void:
	match type:
		"button":
			create_button_universal_being()
		"input":
			create_input_universal_being()
		"output":
			create_output_display()
		"tree":
			create_tree_universal_being()
		"butterfly":  # ADD THIS CASE
			terminal_output("🦋 Creating butterfly...")
			var butterfly = SystemBootstrap.create_universal_being()
			if butterfly:
				butterfly.name = "Butterfly"
				butterfly.set("being_type", "butterfly")
				butterfly.set("consciousness_level", 3)
				
				var label = Label.new()
				label.text = "🦋"
				label.add_theme_font_size_override("font_size", 48)
				label.modulate = Color.CYAN
				butterfly.add_child(label)
				
				get_tree().current_scene.add_child(butterfly)
				butterfly.position = get_viewport().size / 2
				
				terminal_output("✅ Butterfly created!")
				
				if GemmaAI:
					GemmaAI.ai_message.emit("🦋 Beautiful butterfly created!")
		_:
			terminal_output("🖥️ Can create: button, input, output, tree, butterfly")  # UPDATE THIS LINE

# Also fix the tree creation - find create_tree_universal_being and update:
func create_tree_universal_being() -> void:
	terminal_output("🌳 Creating the first tree in our garden...")
	
	# Simple fallback tree since TreeUniversalBeing not found
	var tree = SystemBootstrap.create_universal_being()
	if tree:
		tree.name = "Tree Being"
		tree.set("being_type", "tree")
		tree.set("consciousness_level", 2)
		
		var visual = Label.new()
		visual.text = "🌳"
		visual.add_theme_font_size_override("font_size", 64)
		tree.add_child(visual)
		
		get_tree().current_scene.add_child(tree)
		tree.position = Vector2(get_viewport().size.x / 2, get_viewport().size.y - 100)
		
		terminal_output("✅ Tree planted!")
		
		if GemmaAI:
			GemmaAI.ai_message.emit("🌳 A tree has been planted!")
