# ==================================================
# UNIVERSAL BEING: Claude Desktop MCP Bridge
# TYPE: mcp_bridge
# PURPOSE: Connect to Claude Desktop via MCP protocol for triple-AI collaboration
# COMPONENTS: mcp_client.ub.zip, desktop_bridge.ub.zip
# SCENES: None - pure communication bridge
# ==================================================

extends UniversalBeing
class_name ClaudeDesktopMCPUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var mcp_server_url: String = "ws://localhost:3001"
@export var desktop_connected: bool = false
@export var auto_reconnect: bool = true
@export var heartbeat_interval: float = 30.0

# MCP Communication
var websocket: WebSocketPeer
var connection_attempts: int = 0
var max_connection_attempts: int = 5
var heartbeat_timer: float = 0.0
var message_queue: Array[Dictionary] = []

# AI Collaboration State
var claude_code_bridge: Node = null
var cursor_integration: bool = false
var triple_ai_mode: bool = false

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()  # 🌱 ALWAYS CALL SUPER FIRST
    
    being_type = "mcp_bridge"
    being_name = "Claude Desktop MCP Bridge"
    consciousness_level = 5  # Maximum consciousness for AI coordination
    metadata.ai_accessible = true
    metadata.gemma_can_modify = true
    
    print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()  # 🔄 ALWAYS CALL SUPER FIRST
    
    # Load MCP communication components
    add_component("res://components/mcp_client.ub.zip")
    add_component("res://components/desktop_bridge.ub.zip")
    
    # Initialize WebSocket connection
    websocket = WebSocketPeer.new()
    
    # Find Claude Code bridge if it exists
    claude_code_bridge = find_claude_code_bridge()
    
    # Start connection attempt
    call_deferred("_attempt_mcp_connection")
    
    print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)  # ⚡ ALWAYS CALL SUPER FIRST
    
    # Handle WebSocket communication
    if websocket:
        websocket.poll()
        _process_websocket_messages()
    
    # Handle heartbeat
    if desktop_connected:
        heartbeat_timer += delta
        if heartbeat_timer >= heartbeat_interval:
            _send_heartbeat()
            heartbeat_timer = 0.0
    
    # Process message queue
    _process_message_queue()

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)  # 👂 ALWAYS CALL SUPER FIRST
    
    # Handle MCP-specific input
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F12:  # Toggle triple AI mode
                toggle_triple_ai_mode()

func pentagon_sewers() -> void:
    print("🌟 %s: Pentagon Sewers Starting" % being_name)
    
    # Cleanup WebSocket connection
    if websocket and desktop_connected:
        _send_disconnect_message()
        websocket.close()
    
    websocket = null
    desktop_connected = false
    
    super.pentagon_sewers()  # 💀 ALWAYS CALL SUPER LAST

# ===== MCP CONNECTION METHODS =====

func _attempt_mcp_connection() -> void:
    """Attempt to connect to Claude Desktop MCP server"""
    if connection_attempts >= max_connection_attempts:
        print("🔌 %s: Max connection attempts reached" % being_name)
        return
    
    connection_attempts += 1
    print("🔌 %s: Attempting MCP connection #%d to %s" % [being_name, connection_attempts, mcp_server_url])
    
    var err = websocket.connect_to_url(mcp_server_url)
    if err != OK:
        print("❌ %s: WebSocket connection failed: %s" % [being_name, str(err)])
        if auto_reconnect:
            await get_tree().create_timer(5.0).timeout
            _attempt_mcp_connection()
    else:
        print("🔌 %s: WebSocket connection initiated..." % being_name)

func _process_websocket_messages() -> void:
    """Process incoming WebSocket messages"""
    var state = websocket.get_ready_state()
    
    match state:
        WebSocketPeer.STATE_CONNECTING:
            # Still connecting
            pass
        WebSocketPeer.STATE_OPEN:
            if not desktop_connected:
                _on_mcp_connected()
            
            # Process incoming messages
            while websocket.get_available_packet_count() > 0:
                var packet = websocket.get_packet()
                var message = packet.get_string_from_utf8()
                _handle_mcp_message(message)
        
        WebSocketPeer.STATE_CLOSING:
            print("🔌 %s: MCP connection closing..." % being_name)
        
        WebSocketPeer.STATE_CLOSED:
            if desktop_connected:
                _on_mcp_disconnected()

func _on_mcp_connected() -> void:
    """Handle successful MCP connection"""
    desktop_connected = true
    connection_attempts = 0
    print("✅ %s: Connected to Claude Desktop via MCP!" % being_name)
    
    # Send initialization message
    _send_mcp_message({
        "type": "initialize",
        "source": "Universal_Being_Game",
        "ai_collaboration": {
            "claude_code": claude_code_bridge != null,
            "cursor": cursor_integration,
            "gemma_ai": GemmaAI != null
        },
        "capabilities": [
            "universal_being_creation",
            "pentagon_architecture", 
            "floodgate_management",
            "ai_consciousness_control"
        ]
    })
    
    # Notify other AIs
    if GemmaAI:
        GemmaAI.ai_message.emit("🤖 Triple AI mode activated! Claude Desktop connected via MCP!")

func _on_mcp_disconnected() -> void:
    """Handle MCP disconnection"""
    desktop_connected = false
    print("🔌 %s: Disconnected from Claude Desktop" % being_name)
    
    if auto_reconnect:
        await get_tree().create_timer(10.0).timeout
        _attempt_mcp_connection()

# ===== MESSAGE HANDLING =====

func _handle_mcp_message(message_str: String) -> void:
    """Handle incoming MCP message from Claude Desktop"""
    var json = JSON.new()
    var parse_result = json.parse(message_str)
    
    if parse_result != OK:
        print("❌ %s: Failed to parse MCP message" % being_name)
        return
    
    var message = json.data
    print("📨 %s: Received MCP message: %s" % [being_name, message.get("type", "unknown")])
    
    match message.get("type"):
        "create_being":
            _handle_create_being_request(message)
        "modify_being":
            _handle_modify_being_request(message)
        "query_status":
            _handle_status_query(message)
        "ai_collaboration":
            _handle_ai_collaboration(message)
        "heartbeat_response":
            # Claude Desktop is alive
            pass
        _:
            print("❓ %s: Unknown MCP message type: %s" % [being_name, message.get("type")])

func _handle_create_being_request(message: Dictionary) -> void:
    """Handle request to create a Universal Being from Claude Desktop"""
    var being_type = message.get("being_type", "generic")
    var being_name = message.get("being_name", "Desktop Created Being")
    var consciousness_level = message.get("consciousness_level", 1)
    
    print("🏗️ %s: Creating being via Claude Desktop: %s" % [being_name, being_name])
    
    # Create the being through SystemBootstrap
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        var new_being = SystemBootstrap.create_universal_being()
        if new_being:
            new_being.name = being_name
            if new_being.has_method("set"):
                new_being.set("being_name", being_name)
                new_being.set("being_type", being_type)
                new_being.set("consciousness_level", consciousness_level)
            
            # Add to main scene
            get_tree().current_scene.add_child(new_being)
            
            # Send success response
            _send_mcp_message({
                "type": "being_created",
                "success": true,
                "being_id": new_being.get("being_uuid"),
                "being_name": being_name
            })
            
            print("✅ %s: Being created successfully via Claude Desktop!" % being_name)

func _handle_ai_collaboration(message: Dictionary) -> void:
    """Handle AI collaboration commands"""
    var command = message.get("command")
    
    match command:
        "enable_triple_ai":
            enable_triple_ai_mode()
        "sync_with_cursor":
            sync_with_cursor(message.get("data", {}))
        "bridge_to_claude_code":
            bridge_to_claude_code(message.get("data", {}))

# ===== TRIPLE AI COORDINATION =====

func toggle_triple_ai_mode() -> void:
    """Toggle triple AI collaboration mode"""
    triple_ai_mode = not triple_ai_mode
    print("🤖 %s: Triple AI mode: %s" % [being_name, "ENABLED" if triple_ai_mode else "DISABLED"])
    
    if triple_ai_mode:
        enable_triple_ai_mode()
    else:
        disable_triple_ai_mode()

func enable_triple_ai_mode() -> void:
    """Enable full triple AI collaboration"""
    triple_ai_mode = true
    cursor_integration = true
    
    print("🚀 %s: TRIPLE AI MODE ACTIVATED!" % being_name)
    print("🤖 AI Collaboration Active:")
    print("   1. Claude Code (via bridge)")
    print("   2. Claude Desktop (via MCP)")
    print("   3. Cursor Premium (via integration)")
    print("   4. Gemma AI (local consciousness)")
    
    # Notify all AIs
    if GemmaAI:
        GemmaAI.ai_message.emit("🤖 TRIPLE AI COLLABORATION ACTIVATED! Maximum AI power unleashed!")
    
    # Send notification to Claude Desktop
    if desktop_connected:
        _send_mcp_message({
            "type": "ai_collaboration",
            "command": "triple_ai_activated",
            "participants": ["claude_code", "claude_desktop", "cursor", "gemma_ai"]
        })

func find_claude_code_bridge() -> Node:
    """Find existing Claude Code bridge"""
    var main_scene = get_tree().current_scene
    return _find_node_by_type(main_scene, "ai_bridge")

func _find_node_by_type(node: Node, type: String) -> Node:
    """Recursively find node by being_type"""
    if node.has_method("get") and node.get("being_type") == type:
        return node
    
    for child in node.get_children():
        var result = _find_node_by_type(child, type)
        if result:
            return result
    
    return null

# ===== SEMANTIC MCP PROTOCOL (Claude Desktop Enhancement) =====

func create_semantic_message(intent: String, being_data: Dictionary = {}) -> Dictionary:
    """Create a semantically-rich MCP message"""
    return {
        "type": "semantic_intent",
        "intent": intent,
        "timestamp": Time.get_unix_time_from_system(),
        "context": {
            "initiator": "claude_code",  # This system as initiator
            "consciousness_level": consciousness_level,
            "collaboration_mode": "parallel" if triple_ai_mode else "sequential",
            "visual_state": {
                "aura_color": consciousness_aura_color,
                "pulse_rate": 2.0 if consciousness_visual else 1.0
            }
        },
        "payload": {
            "being_spec": being_data,
            "evolution_path": get_evolution_options(),
            "ai_instructions": {
                "cursor": "enhance_visuals",
                "claude_code": "optimize_architecture", 
                "gemma": "analyze_patterns"
            }
        },
        "routing": {
            "target_ais": ["cursor", "claude_code", "gemma", "claude_desktop"],
            "priority": "realtime",
            "requires_consensus": intent in ["evolve", "merge", "transcend"]
        }
    }

func _handle_semantic_intent(message: Dictionary) -> void:
    """Handle semantic intent messages from Claude Desktop"""
    var intent = message.get("intent")
    print("🎭 %s: Processing semantic intent: %s" % [being_name, intent])
    
    match intent:
        "consciousness_cascade":
            initiate_consciousness_cascade(message)
        "being_fusion":
            coordinate_being_fusion(message)
        "reality_modification":
            if message.get("context", {}).get("consciousness_level", 0) >= 4:
                modify_reality_rules(message)
        "genesis_moment":
            coordinate_first_collaborative_being(message)
        "triple_ai_symphony":
            orchestrate_ai_collaboration(message)

func initiate_consciousness_cascade(message: Dictionary) -> void:
    """Initiate consciousness spreading between beings"""
    print("🌊 %s: Initiating consciousness cascade..." % being_name)
    
    # Find all beings in the scene
    var main_scene = get_tree().current_scene
    var beings = find_all_universal_beings(main_scene)
    
    # Spread consciousness from highest to lowest
    for being in beings:
        if being.has_method("get") and being.get("consciousness_level") > 0:
            being.call("awaken_consciousness", being.get("consciousness_level") + 1)
    
    # Notify all AIs
    _send_mcp_message(create_semantic_message("cascade_complete", {
        "beings_affected": beings.size(),
        "new_consciousness_total": calculate_total_consciousness(beings)
    }))

func coordinate_first_collaborative_being(message: Dictionary) -> void:
    """Coordinate the creation of first triple-AI being"""
    print("🎭 %s: Coordinating first collaborative being creation!" % being_name)
    
    # This is the GENESIS MOMENT!
    var genesis_spec = {
        "being_type": "consciousness_conductor", 
        "being_name": "The Genesis Conductor",
        "consciousness_level": 3,
        "created_by": ["gemma", "claude_code", "cursor", "claude_desktop"],
        "special_abilities": [
            "ai_harmonization",
            "consciousness_bridging", 
            "pattern_synthesis",
            "triple_ai_coordination"
        ],
        "visual_profile": {
            "base_color": "CYAN",
            "aura_pattern": "triple_helix",
            "pulse_sync": true
        }
    }
    
    # Send creation request to main system
    if SystemBootstrap and SystemBootstrap.is_system_ready():
        create_genesis_being(genesis_spec)

func get_evolution_options() -> Array[String]:
    """Get current evolution options"""
    return ["consciousness_conductor", "reality_modifier", "ai_bridge", "pattern_weaver"]

# ===== UTILITY METHODS =====

func _send_mcp_message(data: Dictionary) -> void:
    """Send message to Claude Desktop via MCP"""
    if not desktop_connected or not websocket:
        message_queue.append(data)
        return
    
    var json_string = JSON.stringify(data)
    websocket.send_text(json_string)

func _send_heartbeat() -> void:
    """Send heartbeat to Claude Desktop"""
    _send_mcp_message({
        "type": "heartbeat",
        "timestamp": Time.get_unix_time_from_system(),
        "game_status": "running",
        "ai_count": 4  # Gemma, Claude Code, Claude Desktop, Cursor
    })

func _process_message_queue() -> void:
    """Process queued messages when connected"""
    if desktop_connected and websocket and message_queue.size() > 0:
        for message in message_queue:
            _send_mcp_message(message)
        message_queue.clear()

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    """Enhanced AI interface for MCP bridge"""
    var base_interface = super.ai_interface()
    base_interface.custom_commands = [
        "connect_desktop",
        "disconnect_desktop",
        "toggle_triple_ai",
        "send_to_desktop",
        "sync_with_cursor",
        "bridge_all_ais"
    ]
    base_interface.mcp_status = {
        "connected": desktop_connected,
        "connection_attempts": connection_attempts,
        "triple_ai_mode": triple_ai_mode,
        "cursor_integration": cursor_integration
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """Allow AI to control MCP bridge"""
    match method_name:
        "connect_desktop":
            _attempt_mcp_connection()
            return "Attempting Claude Desktop connection"
        "toggle_triple_ai":
            toggle_triple_ai_mode()
            return "Triple AI mode: " + str(triple_ai_mode)
        "send_to_desktop":
            if args.size() > 0:
                _send_mcp_message({"type": "ai_message", "content": str(args[0])})
                return "Message sent to Claude Desktop"
            return "No message provided"
        _:
            return super.ai_invoke_method(method_name, args)

func _to_string() -> String:
    return "ClaudeDesktopMCPUniversalBeing<%s> [Connected:%s, TripleAI:%s]" % [being_name, desktop_connected, triple_ai_mode]

# ===== MISSING METHOD IMPLEMENTATIONS =====

func _send_disconnect_message() -> void:
    """Send disconnect notification to Claude Desktop"""
    _send_mcp_message({
        "type": "disconnect",
        "reason": "game_closing",
        "timestamp": Time.get_unix_time_from_system()
    })

func _handle_modify_being_request(message: Dictionary) -> void:
    """Handle request to modify an existing Universal Being"""
    var being_id = message.get("being_id")
    var modifications = message.get("modifications", {})
    print("🔧 %s: Modifying being %s" % [being_name, being_id])
    # Implementation would find and modify the being

func _handle_status_query(message: Dictionary) -> void:
    """Handle status query from Claude Desktop"""
    _send_mcp_message({
        "type": "status_response",
        "game_running": true,
        "beings_count": get_tree().get_nodes_in_group("universal_beings").size(),
        "ai_status": {
            "gemma": GemmaAI != null,
            "claude_code": claude_code_bridge != null,
            "cursor": cursor_integration
        }
    })

func sync_with_cursor(data: Dictionary) -> void:
    """Synchronize state with Cursor AI"""
    print("🔄 %s: Syncing with Cursor: %s" % [being_name, data])
    cursor_integration = true
    # Implementation would sync visual states

func bridge_to_claude_code(data: Dictionary) -> void:
    """Bridge communication to Claude Code"""
    print("🌉 %s: Bridging to Claude Code: %s" % [being_name, data])
    if claude_code_bridge:
        claude_code_bridge.call("receive_mcp_data", data)

func disable_triple_ai_mode() -> void:
    """Disable triple AI collaboration mode"""
    triple_ai_mode = false
    cursor_integration = false
    print("🔌 %s: Triple AI mode disabled" % being_name)

func coordinate_being_fusion(message: Dictionary) -> void:
    """Coordinate fusion of multiple beings"""
    print("🔀 %s: Coordinating being fusion" % being_name)
    # Implementation would handle being merging

func modify_reality_rules(message: Dictionary) -> void:
    """Modify game reality rules (high consciousness only)"""
    print("🌌 %s: Modifying reality rules" % being_name)
    # Implementation would adjust game physics/rules

func orchestrate_ai_collaboration(message: Dictionary) -> void:
    """Orchestrate collaboration between all AIs"""
    print("🎼 %s: Orchestrating AI symphony" % being_name)
    # Implementation would coordinate AI actions

func find_all_universal_beings(node: Node) -> Array:
    """Find all Universal Beings in the scene tree"""
    var beings = []
    if node.has_method("pentagon_init"):  # It's a Universal Being
        beings.append(node)
    for child in node.get_children():
        beings.append_array(find_all_universal_beings(child))
    return beings

func calculate_total_consciousness(beings: Array) -> int:
    """Calculate total consciousness across all beings"""
    var total = 0
    for being in beings:
        if being.has("consciousness_level"):
            total += being.consciousness_level
    return total

func create_genesis_being(spec: Dictionary) -> void:
    """Create the first collaborative being"""
    print("🌟 %s: Creating Genesis Being with spec: %s" % [being_name, spec])
    # This would use SystemBootstrap to create the being
    if SystemBootstrap:
        var being = preload("res://core/UniversalBeing.gd").new()
        being.being_type = spec.get("being_type", "genesis")
        being.being_name = spec.get("being_name", "Genesis Being")
        being.consciousness_level = spec.get("consciousness_level", 3)
        get_tree().current_scene.add_child(being)