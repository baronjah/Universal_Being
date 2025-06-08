extends Panel

## Camera Consciousness Effect Sliders
## Provides controls for adjusting consciousness-based visual effects

signal effect_changed(effect_name: String, value: float)

@onready var vignette_slider: HSlider = $VBoxContainer/ScrollContainer/SlidersContainer/VignetteContainer/VignetteSlider
@onready var dof_slider: HSlider = $VBoxContainer/ScrollContainer/SlidersContainer/DOFContainer/DOFSlider
@onready var bloom_slider: HSlider = $VBoxContainer/ScrollContainer/SlidersContainer/BloomContainer/BloomSlider
@onready var chromatic_slider: HSlider = $VBoxContainer/ScrollContainer/SlidersContainer/ChromaticContainer/ChromaticSlider
@onready var distortion_slider: HSlider = $VBoxContainer/ScrollContainer/SlidersContainer/DistortionContainer/DistortionSlider
@onready var quantum_slider: HSlider = $VBoxContainer/ScrollContainer/SlidersContainer/QuantumContainer/QuantumSlider
@onready var master_slider: HSlider = $VBoxContainer/ScrollContainer/SlidersContainer/MasterContainer/MasterSlider

@onready var save_preset: Button = $VBoxContainer/PresetContainer/SavePreset
@onready var load_preset: Button = $VBoxContainer/PresetContainer/LoadPreset
@onready var reset_button: Button = $VBoxContainer/PresetContainer/ResetButton

var effect_values: Dictionary = {}

func _ready():
	connect_sliders()
	connect_buttons()
	initialize_values()

func connect_sliders():
	vignette_slider.value_changed.connect(_on_vignette_changed)
	dof_slider.value_changed.connect(_on_dof_changed)
	bloom_slider.value_changed.connect(_on_bloom_changed)
	chromatic_slider.value_changed.connect(_on_chromatic_changed)
	distortion_slider.value_changed.connect(_on_distortion_changed)
	quantum_slider.value_changed.connect(_on_quantum_changed)
	master_slider.value_changed.connect(_on_master_changed)

func connect_buttons():
	save_preset.pressed.connect(_on_save_preset)
	load_preset.pressed.connect(_on_load_preset)
	reset_button.pressed.connect(_on_reset_all)

func initialize_values():
	effect_values = {
		"vignette": 0.0,
		"dof": 0.0,
		"bloom": 0.0,
		"chromatic": 0.0,
		"distortion": 0.0,
		"quantum": 0.0,
		"master": 1.0
	}
	update_sliders_from_values()

func update_sliders_from_values():
	vignette_slider.value = effect_values.vignette
	dof_slider.value = effect_values.dof
	bloom_slider.value = effect_values.bloom
	chromatic_slider.value = effect_values.chromatic
	distortion_slider.value = effect_values.distortion
	quantum_slider.value = effect_values.quantum
	master_slider.value = effect_values.master

func _on_vignette_changed(value: float):
	effect_values.vignette = value
	effect_changed.emit("vignette", value)

func _on_dof_changed(value: float):
	effect_values.dof = value
	effect_changed.emit("dof", value)

func _on_bloom_changed(value: float):
	effect_values.bloom = value
	effect_changed.emit("bloom", value)

func _on_chromatic_changed(value: float):
	effect_values.chromatic = value
	effect_changed.emit("chromatic", value)

func _on_distortion_changed(value: float):
	effect_values.distortion = value
	effect_changed.emit("distortion", value)

func _on_quantum_changed(value: float):
	effect_values.quantum = value
	effect_changed.emit("quantum", value)

func _on_master_changed(value: float):
	effect_values.master = value
	effect_changed.emit("master", value)

func set_consciousness_level(level: int):
	pass
	# Adjust sliders based on consciousness level
	var base_intensity = level * 0.1
	
	effect_values.vignette = base_intensity * 0.5
	effect_values.bloom = base_intensity * 0.8
	effect_values.quantum = level * 0.15
	
	update_sliders_from_values()
	emit_all_effects()

func emit_all_effects():
	for effect_name in effect_values:
		effect_changed.emit(effect_name, effect_values[effect_name])

func _on_save_preset():
	# Save current settings as preset
	print("Saving effect preset: ", effect_values)

func _on_load_preset():
	# Load saved preset
	print("Loading effect preset")

func _on_reset_all():
	initialize_values()
	emit_all_effects()