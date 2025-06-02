# Add this to main.gd to create Genesis Machine

func create_genesis_machine() -> void:
	"""Create the Genesis Machine for universe creation"""
	print("🌌 Creating Genesis Machine...")
	
	# Create UI window
	var genesis_window = Window.new()
	genesis_window.title = "Genesis Machine - Universe Creator"
	genesis_window.size = Vector2i(800, 600)
	genesis_window.position = Vector2i(100, 100)
	
	# Create simple universe creator
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Title
	var title = Label.new()
	title.text = "🌌 GENESIS MACHINE"
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)
	
	# Status
	var status = RichTextLabel.new()
	status.bbcode_enabled = true
	status.text = "[center]In the beginning, there was only potential...[/center]"
	status.custom_minimum_size.y = 200
	vbox.add_child(status)
	
	# Create button
	var create_btn = Button.new()
	create_btn.text = "CREATE NEW UNIVERSE"
	create_btn.custom_minimum_size.y = 50
	create_btn.pressed.connect(func():
		status.text += "\n✨ Let there be a universe!"
		create_nested_universe()
	)
	vbox.add_child(create_btn)
	
	# Rules section
	var rules_label = Label.new()
	rules_label.text = "Universe Rules:"
	vbox.add_child(rules_label)
	
	# Gravity slider
	var gravity_box = HBoxContainer.new()
	var gravity_label = Label.new()
	gravity_label.text = "Gravity: "
	gravity_label.custom_minimum_size.x = 100
	gravity_box.add_child(gravity_label)
	
	var gravity_slider = HSlider.new()
	gravity_slider.min_value = -20
	gravity_slider.max_value = 20
	gravity_slider.value = 9.8
	gravity_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gravity_box.add_child(gravity_slider)
	
	var gravity_value = Label.new()
	gravity_value.text = "9.8"
	gravity_slider.value_changed.connect(func(val):
		gravity_value.text = "%.1f" % val
		status.text += "\n⚙️ Gravity adjusted to %.1f" % val
	)
	gravity_box.add_child(gravity_value)
	vbox.add_child(gravity_box)
	
	# Add to window
	genesis_window.add_child(vbox)
	get_tree().root.add_child(genesis_window)
	genesis_window.show()
	
	print("🌌 Genesis Machine created!")
	
	# Notify AI
	if GemmaAI:
		GemmaAI.ai_message.emit("🌌 Genesis Machine online! Ready to create universes within universes!")

func create_nested_universe() -> void:
	"""Create a universe inside the current universe"""
	var universe = Node3D.new()
	universe.name = "Universe_%d" % Time.get_ticks_msec()
	
	# Add some basic content
	var light = DirectionalLight3D.new()
	light.rotation = Vector3(-0.5, -0.5, 0)
	universe.add_child(light)
	
	# Create a few random beings
	for i in 3:
		var being = SystemBootstrap.create_universal_being()
		if being:
			being.name = "CosmicBeing_%d" % i
			being.set("consciousness_level", randi_range(1, 5))
			universe.add_child(being)
	
	get_tree().current_scene.add_child(universe)
	
	print("🌌 Universe '%s' created with %d beings!" % [universe.name, 3])
	
	# Log to Akashic
	if SystemBootstrap:
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("log_event"):
			akashic.log_event({
				"type": "universe_creation",
				"name": universe.name,
				"beings": 3
			})

# Add to input handling:
# KEY_G:  # G for Genesis
#     create_genesis_machine()
