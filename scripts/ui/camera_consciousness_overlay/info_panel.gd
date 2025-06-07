extends Panel

## Camera Consciousness Info Panel
## Displays information about the current consciousness level and effects

@onready var level_icon: TextureRect = $VBoxContainer/LevelContainer/LevelIcon
@onready var level_name: Label = $VBoxContainer/LevelContainer/LevelName
@onready var description: Label = $VBoxContainer/Description
@onready var effects_list: RichTextLabel = $VBoxContainer/EffectsList
@onready var fps_counter: Label = $VBoxContainer/StatusContainer/FPSCounter
@onready var camera_mode: Label = $VBoxContainer/StatusContainer/CameraMode

var consciousness_level: int = 0
var consciousness_names: Array[String] = [
	"Dormant", "Aware", "Conscious", "Awakened", "Enlightened", "Transcendent"
]

func _ready():
	update_display()

func _process(_delta):
	fps_counter.text = "FPS: " + str(Engine.get_frames_per_second())

func update_consciousness_level(level: int):
	consciousness_level = level
	update_display()

func update_display():
	pass
	var level_name_text = "Level %d - %s" % [consciousness_level, 
		consciousness_names[min(consciousness_level, consciousness_names.size() - 1)]]
	level_name.text = level_name_text
	
	# Update description based on level
	match consciousness_level:
		0:
			description.text = "The camera observes without awareness, capturing basic visual data."
		1:
			description.text = "The camera begins to notice patterns and movements in its field of view."
		2:
			description.text = "The camera develops spatial awareness and depth perception."
		3:
			description.text = "The camera awakens to the interconnected nature of all visual elements."
		4:
			description.text = "The camera transcends ordinary perception, seeing beyond the visible spectrum."
		_:
			description.text = "The camera has achieved cosmic consciousness, perceiving all dimensions simultaneously."

func update_effects(effects: Array[String]):
	pass
	var effects_text = "[b]Active Effects:[/b]\n"
	for effect in effects:
		effects_text += "• %s\n" % effect
	effects_list.text = effects_text

func update_camera_mode(mode: String):
	camera_mode.text = "Mode: " + mode