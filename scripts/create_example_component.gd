#!/usr/bin/env -S godot --headless --script
extends SceneTree

# Creates an example UI behavior component

func _init():
	print("Creating example ui_behavior.ub.zip component...")
	
	# Create the component
	ComponentLoader.create_component_template("res://components/ui_behavior.ub.zip", "UI Behavior")
	
	print("✅ Example component created!")
	quit()