# ==================================================
# SCRIPT NAME: ComponentLibrary.gd
# DESCRIPTION: Visual Component Library for browsing and applying .ub.zip components
# PURPOSE: Enable in-game component discovery and application to Universal Beings
# CREATED: 2025-06-03 - Universal Being Evolution
# ==================================================

extends Window

# ===== COMPONENT LIBRARY - THE PALETTE OF POSSIBILITIES =====

signal component_applied(being: Node, component_path: String)

# Component categories
const COMPONENT_CATEGORIES = {
	"🎨 Visual": ["particle", "mesh", "sprite", "aura", "glow"],
	"📜 Script": ["behavior", "ai", "movement", "interaction"],
	"🌈 Shader": ["material", "effect", "distortion", "consciousness"],
	"🎬 Action": ["animation", "sequence", "trigger", "event"],
	"🧠 Memory": ["storage", "state", "history", "knowledge"],
	"🖼️ Interface": ["ui", "panel", "button", "display"],
	"🔊 Audio": ["sound", "music", "voice", "ambient"],
	"⚡ Physics": ["collision", "force", "gravity", "quantum"]
}

# UI References
var category_list: ItemList
var component_grid: GridContainer
var preview_panel: Panel
var being_selector: OptionButton
var search_bar: LineEdit

# Component data
var available_components: Dictionary = {}  # path -> component_info
var filtered_components: Array = []
var selected_component: String = ""
var target_being: Node = null

func _ready():
	title = "🎨 Universal Being Component Library"
	size = Vector2(1000, 700)
	position = Vector2(200, 150)
	
	# Initialize UI
	_create_ui()
	_discover_components()
	_populate_being_selector()
	
	# Connect close
	close_requested.connect(_on_close_requested)
	
	# Log genesis
	_log_genesis("🎨 Component Library manifested - infinite possibilities await...")
func _create_ui():
	"""Create the library UI layout"""
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 10)
	add_child(main_vbox)
	
	# Header with search and being selector
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	main_vbox.add_child(header)
	
	# Search bar
	search_bar = LineEdit.new()
	search_bar.placeholder_text = "🔍 Search components..."
	search_bar.custom_minimum_size = Vector2(300, 0)
	search_bar.text_changed.connect(_on_search_changed)
	header.add_child(search_bar)
	
	# Being selector
	var being_label = Label.new()
	being_label.text = "Apply to:"
	header.add_child(being_label)
	
	being_selector = OptionButton.new()
	being_selector.custom_minimum_size = Vector2(200, 0)
	being_selector.item_selected.connect(_on_being_selected)
	header.add_child(being_selector)
	
	# Main content split
	var hsplit = HSplitContainer.new()
	hsplit.split_offset = 200
	main_vbox.add_child(hsplit)
	
	# Left: Categories
	category_list = ItemList.new()
	category_list.custom_minimum_size = Vector2(200, 0)
	category_list.add_item("🌟 All Components")
	for category in COMPONENT_CATEGORIES:
		category_list.add_item(category)
	category_list.item_selected.connect(_on_category_selected)
	category_list.select(0)
	hsplit.add_child(category_list)
	# Right: Component browser
	var right_vbox = VBoxContainer.new()
	hsplit.add_child(right_vbox)
	
	# Component grid scroll
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 400)
	right_vbox.add_child(scroll)
	
	component_grid = GridContainer.new()
	component_grid.columns = 4
	component_grid.add_theme_constant_override("h_separation", 10)
	component_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(component_grid)
	
	# Preview panel
	preview_panel = Panel.new()
	preview_panel.custom_minimum_size = Vector2(0, 200)
	right_vbox.add_child(preview_panel)
	
	var preview_vbox = VBoxContainer.new()
	preview_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview_vbox.add_theme_constant_override("separation", 5)
	preview_panel.add_child(preview_vbox)
	
	var preview_title = Label.new()
	preview_title.name = "PreviewTitle"
	preview_title.text = "Select a component to preview"
	preview_title.add_theme_font_size_override("font_size", 16)
	preview_vbox.add_child(preview_title)
	
	var preview_desc = RichTextLabel.new()
	preview_desc.name = "PreviewDesc"
	preview_desc.bbcode_enabled = true
	preview_desc.fit_content = true
	preview_vbox.add_child(preview_desc)
	
	# Apply button
	var apply_btn = Button.new()
	apply_btn.name = "ApplyButton"
	apply_btn.text = "✨ Apply Component"
	apply_btn.disabled = true
	apply_btn.pressed.connect(_on_apply_pressed)
	preview_vbox.add_child(apply_btn)
func _discover_components():
	"""Discover all available .ub.zip components"""
	available_components.clear()
	
	# Check components directory
	var dir = DirAccess.open("res://components/")
	if not dir:
		print("🎨 No components directory found")
		return
	
	dir.list_dir_begin()
	var folder_name = dir.get_next()
	
	while folder_name != "":
		if folder_name.ends_with(".ub.zip"):
			var component_path = "res://components/" + folder_name
			var manifest_path = component_path + "/manifest.json"
			
			# Try to load manifest
			if FileAccess.file_exists(manifest_path):
				var file = FileAccess.open(manifest_path, FileAccess.READ)
				var json_text = file.get_as_text()
				file.close()
				
				var json = JSON.new()
				var parse_result = json.parse(json_text)
				if parse_result == OK:
					var manifest = json.data
					available_components[component_path] = {
						"name": manifest.get("name", folder_name),
						"description": manifest.get("description", "No description"),
						"category": manifest.get("category", "Unknown"),
						"version": manifest.get("version", "1.0.0"),
						"author": manifest.get("author", "Unknown"),
						"tags": manifest.get("tags", [])
					}
		
		folder_name = dir.get_next()
	
	dir.list_dir_end()
	
	print("🎨 Discovered %d components" % available_components.size())
	_update_component_display()
func _populate_being_selector():
	"""Populate the being selector with available Universal Beings"""
	being_selector.clear()
	being_selector.add_item("None Selected")
	
	# Get all beings from Main
	var main = get_node_or_null("/root/Main")
	if main and main.has_method("get"):
		var beings = main.get("demo_beings")
		if beings:
			for being in beings:
				var being_name = being.name
				if being.has_method("get"):
					var custom_name = being.get("being_name")
					if custom_name:
						being_name = custom_name
				being_selector.add_item(being_name)

func _update_component_display(filter_category: String = ""):
	"""Update the component grid display"""
	# Clear existing
	for child in component_grid.get_children():
		child.queue_free()
	
	filtered_components.clear()
	
	# Filter and display components
	for comp_path in available_components:
		var comp_info = available_components[comp_path]
		
		# Apply category filter
		if filter_category != "" and filter_category != "🌟 All Components":
			var matches_category = false
			for keyword in COMPONENT_CATEGORIES.get(filter_category, []):
				if keyword in comp_info.name.to_lower() or keyword in comp_info.tags:
					matches_category = true
					break
			if not matches_category:
				continue
		
		# Apply search filter
		if search_bar.text != "":
			var search_lower = search_bar.text.to_lower()
			if not (search_lower in comp_info.name.to_lower() or 
					search_lower in comp_info.description.to_lower()):
				continue
		
		filtered_components.append(comp_path)
		_create_component_card(comp_path, comp_info)
func _create_component_card(comp_path: String, comp_info: Dictionary):
	"""Create a visual card for a component"""
	var card = Panel.new()
	card.custom_minimum_size = Vector2(150, 120)
	card.tooltip_text = comp_info.description
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 5)
	card.add_child(vbox)
	
	# Icon (placeholder - could be actual component preview)
	var icon = Label.new()
	icon.text = _get_component_icon(comp_info.category)
	icon.add_theme_font_size_override("font_size", 32)
	icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	vbox.add_child(icon)
	
	# Name
	var name_label = Label.new()
	name_label.text = comp_info.name
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_label)
	
	# Make clickable
	card.gui_input.connect(_on_component_card_clicked.bind(comp_path))
	
	component_grid.add_child(card)

func _get_component_icon(category: String) -> String:
	"""Get icon for component category"""
	var icons = {
		"visual": "🎨",
		"script": "📜",
		"shader": "🌈",
		"action": "🎬",
		"memory": "🧠",
		"interface": "🖼️",
		"audio": "🔊",
		"physics": "⚡"
	}
	
	for key in icons:
		if key in category.to_lower():
			return icons[key]
	
	return "✨"  # Default
func _on_component_card_clicked(event: InputEvent, comp_path: String):
	"""Handle component card click"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		selected_component = comp_path
		_update_preview(comp_path)

func _update_preview(comp_path: String):
	"""Update the preview panel with component details"""
	var comp_info = available_components[comp_path]
	
	var title = preview_panel.get_node("VBoxContainer/PreviewTitle")
	var desc = preview_panel.get_node("VBoxContainer/PreviewDesc")
	var apply_btn = preview_panel.get_node("VBoxContainer/ApplyButton")
	
	title.text = comp_info.name
	
	desc.text = "[b]Description:[/b] %s\n\n" % comp_info.description
	desc.text += "[b]Category:[/b] %s\n" % comp_info.category
	desc.text += "[b]Version:[/b] %s\n" % comp_info.version
	desc.text += "[b]Author:[/b] %s\n" % comp_info.author
	if comp_info.tags.size() > 0:
		desc.text += "[b]Tags:[/b] %s" % ", ".join(comp_info.tags)
	
	# Enable apply button if being is selected
	apply_btn.disabled = (target_being == null)

func _on_category_selected(index: int):
	"""Handle category selection"""
	var category = category_list.get_item_text(index)
	_update_component_display(category)

func _on_search_changed(text: String):
	"""Handle search text change"""
	var current_category = category_list.get_item_text(category_list.get_selected_items()[0])
	_update_component_display(current_category)

func _on_being_selected(index: int):
	"""Handle being selection"""
	if index == 0:
		target_being = null
	else:
		var main = get_node_or_null("/root/Main")
		if main and main.has_method("get"):
			var beings = main.get("demo_beings")
			if beings and index - 1 < beings.size():
				target_being = beings[index - 1]
	
	# Update apply button
	if selected_component != "":
		_update_preview(selected_component)
func _on_apply_pressed():
	"""Apply selected component to target being"""
	if not target_being or selected_component == "":
		return
	
	if target_being.has_method("add_component"):
		var success = target_being.add_component(selected_component)
		if success:
			component_applied.emit(target_being, selected_component)
			_log_genesis("✨ Component '%s' applied to being '%s'" % [
				available_components[selected_component].name,
				target_being.name
			])
			
			# Visual feedback
			var apply_btn = preview_panel.get_node("VBoxContainer/ApplyButton")
			apply_btn.text = "✅ Applied!"
			await get_tree().create_timer(1.0).timeout
			apply_btn.text = "✨ Apply Component"
		else:
			push_error("Failed to apply component to being")

func _on_close_requested():
	"""Handle window close"""
	hide()

func toggle_visibility():
	"""Toggle library visibility"""
	if visible:
		hide()
	else:
		show()
		_populate_being_selector()  # Refresh beings

func _log_genesis(message: String):
	"""Log genesis events in poetic style"""
	print("🎨 GENESIS: " + message)
	
	# Try to log to Akashic Library
	var bootstrap = get_node_or_null("/root/SystemBootstrap")
	if bootstrap and bootstrap.has_method("get_akashic_library"):
		var akashic = bootstrap.get_akashic_library()
		if akashic and akashic.has_method("log_component_event"):
			akashic.log_component_event("library", message, {
				"timestamp": Time.get_unix_time_from_system()
			})