# creation_build_scene.gd
extends Spatial

var creation_tool_visible = false
onready var creation_tool = $CreationToolUI

func _ready():
	# Hide tool initially
	creation_tool.visible = false
	
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_QUOTELEFT and event.pressed:  # The "`" key
			toggle_creation_tool()
			
func toggle_creation_tool():
	creation_tool_visible = !creation_tool_visible
	creation_tool.visible = creation_tool_visible
	
	# Enable/disable world interaction based on tool visibility
	if creation_tool_visible:
		enter_creation_mode()
	else:
		exit_creation_mode()
		
func enter_creation_mode():
	# Enable grid visualization
	$WorldGrid.visible = true
	# Change camera behavior if needed
	$Camera.creation_mode = true
	
func exit_creation_mode():
	# Disable grid visualization
	$WorldGrid.visible = false
	# Restore normal camera behavior
	$Camera.creation_mode = false
