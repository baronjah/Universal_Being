extends Node

# Script to update the main UI with Wish Maker integration
# This script is meant to be executed once to update the main.tscn

func _ready():
	print("Starting UI update process for Wish Maker integration")
	add_wish_maker_tab()
	update_help_information()
	print("UI update complete")
	queue_free()  # Remove this node after updating

func add_wish_maker_tab():
	# Get the TabContainer
	var tab_container = get_node("/root/EdenMayGame/UI/MainContainer/ContentContainer/SidePanel/VBoxContainer/TabContainer")
	if not tab_container:
		print("Error: TabContainer not found")
		return
	
	# Create the Wish Maker tab
	var wish_tab = Tabs.new()
	wish_tab.name = "WishMaker"
	tab_container.add_child(wish_tab)
	
	# Create scroll container
	var scroll = ScrollContainer.new()
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 1.0
	scroll.scroll_horizontal_enabled = false
	wish_tab.add_child(scroll)
	
	# Create rich text label
	var text = RichTextLabel.new()
	text.name = "WishInfoText"
	text.size_flags_horizontal = SIZE_EXPAND_FILL
	text.size_flags_vertical = SIZE_EXPAND_FILL
	text.bbcode_enabled = true
	text.bbcode_text = "[b]Wish Maker System[/b]\n\n" +
		"Make wishes using tokens with Gemini and Claude integration.\n\n" +
		"[b]Available in:[/b]\n" +
		"- Separate window (click button below)\n" +
		"- Command: /wish\n\n" +
		"[b]Token Balance:[/b] 2,000,000\n\n" +
		"[color=#aaddff]Click the button below to open the Wish Maker[/color]"
	scroll.add_child(text)
	
	# Add button to open Wish Maker
	var button = Button.new()
	button.name = "OpenWishMakerButton"
	button.text = "Open Wish Maker"
	button.rect_min_size = Vector2(180, 40)
	button.rect_position = Vector2(30, 200)
	button.connect("pressed", self, "_on_open_wish_maker_pressed")
	wish_tab.add_child(button)
	
	print("Wish Maker tab added")

func update_help_information():
	# Get the Help text
	var help_text = get_node("/root/EdenMayGame/UI/MainContainer/ContentContainer/SidePanel/VBoxContainer/TabContainer/Help/HelpScroll/HelpText")
	if not help_text:
		print("Error: Help text not found")
		return
	
	# Add wish maker information to help
	var current_text = help_text.bbcode_text
	var wish_maker_help = "\n\n[b]Wish Maker Commands:[/b]\n" +
		"/wish - Open Wish Maker interface\n" +
		"/tokens - Show current token balance\n" +
		"/wish_make <text> - Make a wish directly\n" +
		"/wish_gemini <text> - Force Gemini API for wish\n" +
		"/wish_claude <text> - Force Claude for wish\n"
	
	help_text.bbcode_text = current_text + wish_maker_help
	
	print("Help information updated")

func _on_open_wish_maker_pressed():
	# Open the Wish Maker scene
	var eden_core = get_node("/root/EdenMayGame/EdenCore")
	if eden_core and eden_core.has_method("open_wish_maker"):
		eden_core.open_wish_maker()
	else:
		print("Manually loading wish_maker.tscn")
		# Fallback direct loading
		var wish_maker_scene = load("res://Eden_May/wish_maker.tscn")
		if wish_maker_scene:
			var wish_maker_instance = wish_maker_scene.instance()
			get_tree().root.add_child(wish_maker_instance)
		else:
			print("Error: Could not load wish_maker.tscn")