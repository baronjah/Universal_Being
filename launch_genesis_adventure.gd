# ==================================================
# SCRIPT NAME: launch_genesis_adventure.gd
# DESCRIPTION: Scene loader to start the Desert Garden Genesis adventure
# PURPOSE: Initialize and load the collaborative creation garden scenario
# CREATED: 2025-06-04 - Adventure Genesis Launcher
# AUTHOR: JSH + Claude Code + Sacred Genesis
# ==================================================

extends Node
class_name GenesisAdventureLauncher

# ===== GENESIS CONSTANTS =====
const GENESIS_SCENARIO_PATH = "res://scenarios/desert_garden_genesis.gd"
const MAIN_SCENE_PATH = "res://main.tscn"

# Scene management
var genesis_scenario: Node
var main_scene: Node
var system_bootstrap: Node

# ===== INITIALIZATION =====
func _ready() -> void:
	print("🌟 GenesisAdventureLauncher: Preparing the sacred adventure...")
	_launch_genesis_adventure()

func _launch_genesis_adventure() -> void:
	"""Launch the complete Desert Garden Genesis adventure"""
	
	# Ensure SystemBootstrap is ready
	await _ensure_system_ready()
	
	# Load the genesis scenario
	await _load_genesis_scenario()
	
	# Setup player and AI systems
	_setup_adventure_participants()
	
	# Display adventure instructions
	_display_adventure_welcome()
	
	print("🌟 Genesis Adventure launched! The collaborative creation begins!")

# ===== SYSTEM INITIALIZATION =====
func _ensure_system_ready() -> void:
	"""Ensure SystemBootstrap and core systems are ready"""
	print("🔧 Ensuring core systems are ready...")
	
	# Get or create SystemBootstrap
	system_bootstrap = get_node("/root/SystemBootstrap")
	if not system_bootstrap:
		print("❌ SystemBootstrap not found - cannot launch adventure")
		return
	
	# Wait for systems to be ready
	var max_wait_time = 10.0  # 10 seconds max
	var wait_time = 0.0
	
	while not system_bootstrap.is_system_ready() and wait_time < max_wait_time:
		await get_tree().create_timer(0.1).timeout
		wait_time += 0.1
		
	if wait_time >= max_wait_time:
		print("⚠️ Systems took too long to initialize - proceeding anyway")
	else:
		print("✅ Core systems ready for adventure!")

# ===== SCENARIO LOADING =====
func _load_genesis_scenario() -> void:
	"""Load and initialize the Desert Garden Genesis scenario"""
	print("🌴 Loading Desert Garden Genesis scenario...")
	
	# Load the genesis scenario script
	var GenesisScenarioClass = load(GENESIS_SCENARIO_PATH)
	if not GenesisScenarioClass:
		print("❌ Could not load genesis scenario from: %s" % GENESIS_SCENARIO_PATH)
		return
	
	# Create scenario instance
	genesis_scenario = GenesisScenarioClass.new()
	genesis_scenario.name = "DesertGardenGenesis"
	
	# Add to current scene
	get_tree().current_scene.add_child(genesis_scenario)
	
	# Wait for scenario initialization
	await get_tree().create_timer(1.0).timeout
	
	print("✅ Genesis scenario loaded and initialized!")

# ===== PARTICIPANT SETUP =====
func _setup_adventure_participants() -> void:
	"""Setup player and AI companion for collaborative creation"""
	print("👥 Setting up adventure participants...")
	
	# Setup player systems
	_setup_player_systems()
	
	# Setup AI companion (Gemma)
	_setup_ai_companion()
	
	# Setup collaboration interface
	_setup_collaboration_interface()

func _setup_player_systems() -> void:
	"""Setup player control and interaction systems"""
	print("🎮 Setting up player systems...")
	
	# Find or create player being
	var player_spawn = genesis_scenario.garden_beings.get("player_spawn")
	if player_spawn:
		_create_player_being(player_spawn.position)
	
	# Setup input handling for creation tools
	_setup_creation_input_system()

func _setup_ai_companion() -> void:
	"""Setup Gemma AI companion for collaborative creation"""
	print("🤖 Setting up AI companion (Gemma)...")
	
	# Get AI companion from genesis scenario
	var ai_companion = genesis_scenario.garden_beings.get("ai_companion")
	if ai_companion:
		# Connect AI companion to Gemma AI system
		_connect_gemma_ai_system(ai_companion)
		
		# Initialize AI collaboration mode
		ai_companion.set("collaboration_mode", "active")
		ai_companion.set("creation_focus", "organic_garden_expansion")

func _setup_collaboration_interface() -> void:
	"""Setup interface for human-AI collaborative creation"""
	print("🤝 Setting up collaboration interface...")
	
	# Create collaboration UI overlay
	var _collaboration_ui = _create_collaboration_ui()
	
	# Setup suggestion system
	_setup_ai_suggestion_display()
	
	# Setup shared creation tools
	_setup_shared_creation_tools()

# ===== PLAYER CREATION =====
func _create_player_being(spawn_position: Vector3) -> Node:
	"""Create the player Universal Being"""
	var player_being = preload("res://core/UniversalBeing.gd").new()
	player_being.name = "PlayerBeing"
	player_being.being_name = "Garden Creator (Human)"
	player_being.being_type = "player"
	player_being.consciousness_level = 5
	player_being.position = spawn_position
	
	# Add to players group
	player_being.add_to_group("players")
	
	# Player properties
	player_being.set("creation_energy", 100.0)
	player_being.set("collaboration_level", 5)
	player_being.set("garden_knowledge", 50)  # Will grow through collaboration
	
	# Add visual representation
	_add_player_visual(player_being)
	
	# Add to scene
	get_tree().current_scene.add_child(player_being)
	
	print("✅ Player being created at position: %s" % spawn_position)
	return player_being

# ===== AI INTEGRATION =====
func _connect_gemma_ai_system(ai_companion: Node) -> void:
	"""Connect AI companion to Gemma AI system"""
	# Get Gemma AI system from autoload
	var gemma_ai = get_node("/root/GemmaAI")
	if gemma_ai:
		# Connect AI companion to Gemma
		ai_companion.set("ai_backend", gemma_ai)
		ai_companion.set("ai_active", true)
		
		# Setup AI personality for garden collaboration
		var ai_personality = {
			"specialty": "organic_design",
			"creativity_level": 0.8,
			"collaboration_style": "supportive",
			"suggestion_frequency": "moderate"
		}
		ai_companion.set("ai_personality", ai_personality)
		
		print("🔗 AI companion connected to Gemma AI system")
	else:
		print("⚠️ Gemma AI system not found - AI companion will work in basic mode")

# ===== INTERFACE CREATION =====
func _create_collaboration_ui() -> Control:
	"""Create UI for collaborative creation"""
	var ui_overlay = Control.new()
	ui_overlay.name = "CollaborationUI"
	ui_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create collaboration panel
	var panel = Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.position = Vector2(-250, 10)
	panel.size = Vector2(240, 150)
	
	# Add collaboration info
	var info_label = Label.new()
	info_label.text = "🌟 Collaborative Creation Mode\n🤖 AI: Ready\n🌱 Energy: 100%\n🤝 Working Together"
	info_label.position = Vector2(10, 10)
	panel.add_child(info_label)
	
	ui_overlay.add_child(panel)
	get_tree().current_scene.add_child(ui_overlay)
	
	return ui_overlay

# ===== WELCOME MESSAGE =====
func _display_adventure_welcome() -> void:
	"""Display comprehensive welcome message for the adventure"""
	print("🌟 ===== DESERT GARDEN GENESIS ADVENTURE ===== 🌟")
	print("")
	print("🌴 Welcome to your collaborative creation oasis!")
	print("🤖 You and Gemma AI are now partners in creation")
	print("")
	print("🗺️ YOUR GARDEN LAYOUT:")
	print("   🍎 Fruit Grove (Northwest) - Apple, orange, pomegranate trees")
	print("   🌿 Herb Garden (Northeast) - Medicinal and culinary herbs") 
	print("   🌺 Flower Meadow (North) - Colorful wildflower fields")
	print("   🥕 Vegetable Patch (Southwest) - Food crops and vegetables")
	print("   🧘 Meditation Circle (Southeast) - Peaceful contemplation space")
	print("   💧 Water Spring (Center) - Life-giving sacred waters")
	print("")
	print("🛠️ COLLABORATION AREAS:")
	print("   🔨 Northern Expansion - Create new garden sections")
	print("   🎨 Eastern Expansion - Design artistic features")
	print("   🌱 Western Expansion - Experimental growing zones")
	print("   ✨ Central Project - Special collaborative creations")
	print("")
	print("🎮 HOW TO CREATE:")
	print("   • Explore the garden zones to see existing creations")
	print("   • Visit collaboration areas to start new projects")
	print("   • Work with your AI companion for enhanced creativity")
	print("   • Use your creation energy to manifest new beings")
	print("")
	print("🤝 AI COMPANION FEATURES:")
	print("   • Suggests complementary creations")
	print("   • Helps optimize garden layouts")
	print("   • Provides botanical knowledge")
	print("   • Collaborates on complex projects")
	print("")
	print("✨ The adventure begins! Start exploring and creating!")
	print("🌟 ===== GENESIS ADVENTURE ACTIVE ===== 🌟")

# ===== PLACEHOLDER METHODS =====
func _setup_creation_input_system() -> void:
	"""Setup input handling for creation tools"""
	# TODO: Implement creation input system
	pass

func _setup_ai_suggestion_display() -> void:
	"""Setup display system for AI suggestions"""
	# TODO: Implement AI suggestion display
	pass

func _setup_shared_creation_tools() -> void:
	"""Setup tools that both human and AI can use"""
	# TODO: Implement shared creation tools
	pass

func _add_player_visual(player: Node) -> void:
	"""Add visual representation for the player"""
	# Create simple player representation
	var mesh_instance = MeshInstance3D.new()
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.height = 2.0
	capsule_mesh.top_radius = 0.3
	capsule_mesh.bottom_radius = 0.3
	mesh_instance.mesh = capsule_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.6, 1.0)  # Blue for player
	mesh_instance.material_override = material
	
	mesh_instance.position.y = 1.0  # Raise above ground
	player.add_child(mesh_instance)

# ===== UTILITY FUNCTIONS =====
func get_genesis_scenario() -> Node:
	"""Get reference to the genesis scenario"""
	return genesis_scenario

func get_collaboration_status() -> Dictionary:
	"""Get current status of human-AI collaboration"""
	return {
		"player_active": get_tree().get_nodes_in_group("players").size() > 0,
		"ai_companion_active": genesis_scenario and genesis_scenario.ai_companion != null,
		"genesis_scenario_loaded": genesis_scenario != null,
		"collaboration_areas": 4,  # North, East, West, Central
		"total_garden_beings": genesis_scenario.garden_beings.size() if genesis_scenario else 0
	}