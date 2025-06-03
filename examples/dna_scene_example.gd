# ==================================================
# SCRIPT NAME: dna_scene_example.gd
# DESCRIPTION: Example of using DNA system with loaded scenes
# PURPOSE: Demonstrate how scenes can be analyzed and cloned with DNA
# CREATED: 2025-06-03 - Universal Being Evolution
# ==================================================

extends Node

# Example: Creating a Universal Being that loads a scene and can be cloned

func demonstrate_scene_dna() -> void:
	"""Demonstrate scene DNA analysis and cloning"""
	
	# 1. Create a Universal Being
	var scene_being = UniversalBeing.new()
	scene_being.being_name = "UI Controller"
	scene_being.being_type = "ui_master"
	scene_being.consciousness_level = 3
	
	# 2. Load a scene into the being
	var scene_loaded = scene_being.load_scene("res://scenes/ui/control_panel.tscn")
	if not scene_loaded:
		print("Failed to load scene")
		return
	
	print("✅ Scene loaded into Universal Being")
	
	# 3. Analyze the DNA (this extracts all scene information)
	var dna = scene_being.analyze_dna()
	print("🧬 DNA Analysis complete:")
	print(dna.get_summary())
	
	# 4. Show what the DNA captured about the scene
	print("\n📊 Scene Analysis:")
	print("- Node count: %d" % dna.node_catalog.size())
	print("- Interaction points: %d" % dna.interaction_points.size())
	print("- Modifiable elements: %d" % dna.modifiable_elements.size())
	print("- Detected patterns: %d" % dna.scene_analysis.get("reusable_patterns", []).size())
	
	# 5. Create a blueprint for cloning
	var blueprint = scene_being.create_blueprint()
	print("\n📋 Blueprint created with inheritance factors:")
	print("- Consciousness: %.0f%%" % (blueprint.inheritance_factors.consciousness_inheritance * 100))
	print("- Components: %.0f%%" % (blueprint.inheritance_factors.component_inheritance * 100))
	print("- Scene: %.0f%%" % (blueprint.inheritance_factors.scene_inheritance * 100))
	
	# 6. Clone the being (including its scene)
	var clone = scene_being.clone_being({
		"consciousness_level": 4  # Upgrade consciousness in clone
	})
	
	print("\n🧬 Clone created: %s" % clone.being_name)
	print("- Consciousness: %d (upgraded from %d)" % [clone.consciousness_level, scene_being.consciousness_level])
	print("- Has scene: %s" % str(clone.scene_is_loaded))
	
	# 7. Save DNA to file for later use
	var dna_saved = scene_being.save_dna_to_file("user://scene_templates/ui_controller.dna")
	if dna_saved:
		print("\n💾 DNA saved to file for future use")
	
	# 8. Evolution example - evolve from another being's template
	var evolved = scene_being.evolve_from_template(clone, 0.2)  # 20% mutation rate
	if evolved:
		print("\n🦋 Evolution successful! Being evolved traits from clone")
	
	# 9. Show evolution options
	var evolution_options = scene_being.get_evolution_options()
	print("\n🔮 Available evolution paths:")
	for option in evolution_options:
		print("- %s (probability: %.0f%%)" % [option.path_type, option.probability * 100])

func demonstrate_scene_component_extraction() -> void:
	"""Demonstrate extracting components from a scene"""
	
	# Create a being with a complex scene
	var complex_being = UniversalBeing.new()
	complex_being.being_name = "Complex UI System"
	complex_being.load_scene("res://scenes/ui/complex_interface.tscn")
	
	# Analyze DNA
	var dna = complex_being.analyze_dna()
	
	# Extract specific components we're interested in
	print("\n🔍 Extractable components found:")
	
	for node_path in dna.node_catalog:
		var node_info = dna.node_catalog[node_path]
		if node_info.is_reusable:
			print("✓ %s (%s)" % [node_info.name, node_info.class])
			
			# Could create a component from this node
			if node_info.class == "Button":
				print("  → Can extract as interactive component")
			elif node_info.class == "MeshInstance3D":
				print("  → Can extract as visual component")
	
	# Show interaction points
	print("\n🤝 Interaction points:")
	for interaction in dna.interaction_points:
		print("- %s: %s (%s)" % [
			interaction.node_name,
			interaction.interaction_type,
			interaction.node_path
		])

func demonstrate_template_application() -> void:
	"""Demonstrate applying templates to modify beings"""
	
	var being = UniversalBeing.new()
	being.being_name = "Template Test"
	being.consciousness_level = 2
	
	# Create a template for enhancement
	var enhancement_template = {
		"consciousness_modifications": {
			"level_change": 2  # Increase by 2 levels
		},
		"component_modifications": {
			"add_components": [
				"res://components/enhanced_ai.ub.zip",
				"res://components/particle_aura.ub.zip"
			]
		},
		"visual_modifications": {
			"layer_change": 1  # Move up one visual layer
		}
	}
	
	print("\n🎨 Applying enhancement template...")
	being.apply_template("Enhancement", enhancement_template)
	
	print("✅ Template applied!")
	print("- New consciousness: %d" % being.consciousness_level)
	print("- Components: %d" % being.components.size())
	print("- Visual layer: %d" % being.visual_layer)

func demonstrate_dna_based_creation() -> void:
	"""Demonstrate creating beings from DNA profiles"""
	
	# Load a saved DNA profile
	var loaded_dna = UniversalBeingDNA.load_from_file("user://scene_templates/ui_controller.dna")
	if not loaded_dna:
		print("No saved DNA found")
		return
	
	# Create a creator being (needs consciousness level 3+)
	var creator = UniversalBeing.new()
	creator.being_name = "DNA Creator"
	creator.consciousness_level = 5
	
	# Check if creator can create from this DNA
	if creator.can_create_from_dna(loaded_dna):
		print("\n🧬 Creator can manifest being from DNA!")
		
		# Create new being from DNA
		var created_being = creator.create_from_dna(loaded_dna)
		if created_being:
			print("✨ New being created from DNA: %s" % created_being.being_name)
			print("- Consciousness: %d (reduced from template)" % created_being.consciousness_level)
			print("- Type: %s" % created_being.being_type)
	else:
		print("❌ Creator lacks sufficient consciousness to manifest this DNA")

# Run all demonstrations
func _ready() -> void:
	print("=== UNIVERSAL BEING DNA SCENE EXAMPLE ===\n")
	
	demonstrate_scene_dna()
	demonstrate_scene_component_extraction()
	demonstrate_template_application()
	demonstrate_dna_based_creation()
	
	print("\n=== DEMONSTRATION COMPLETE ===")
	print("🧬 DNA system enables:")
	print("- Complete scene analysis and documentation")
	print("- Blueprint creation for rapid cloning")
	print("- Evolution based on other beings' DNA")
	print("- Component extraction for reuse")
	print("- Template-based modifications")
	print("- Creation from saved DNA profiles")