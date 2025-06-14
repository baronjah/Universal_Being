extends Node

class_name EmotionAPIIntegration

"""
Emotion API Integration
Connects the Multi-Account system with the Emotion Pricing System
Visualizes emotional content and satoshi costs in 3D space
"""

# References to other systems
var account_manager = null
var api_controller = null
var visualizer = null
var pricing_system = null

# Emotion visualization settings
const EMOTION_COLORS = {
    "joy": Color(1.0, 0.9, 0.1),       # Bright yellow
    "sadness": Color(0.1, 0.3, 0.8),   # Blue
    "anger": Color(0.9, 0.1, 0.1),     # Red
    "fear": Color(0.5, 0.0, 0.5),      # Purple
    "surprise": Color(1.0, 0.6, 0.0),  # Orange
    "disgust": Color(0.2, 0.6, 0.2),   # Green
    "trust": Color(0.0, 0.7, 0.7),     # Teal
    "anticipation": Color(0.9, 0.5, 0.7), # Pink
    "focus": Color(0.5, 0.5, 0.5),     # Gray
    "inspiration": Color(0.9, 0.9, 0.9) # White
}

# Emotion particles and effects
var emotion_particles = {}
var satoshi_counters = {}

# Signal for emotional events
signal emotion_processed(account_id, emotion_type, emotion_level, cost)
signal emotion_threshold_reached(account_id, threshold_type, value)
signal emotional_insight_generated(account_id, insight_data)

func _ready():
    # Connect to systems
    _connect_to_systems()
    
    # Initialize emotion pricing system
    pricing_system = EmotionPricingSystem.new()
    add_child(pricing_system)
    
    # Connect to pricing system signals
    pricing_system.cost_calculated.connect(_on_cost_calculated)
    pricing_system.limit_reached.connect(_on_limit_reached)
    
    # Setup update timer for emotional insights
    var timer = Timer.new()
    timer.wait_time = 30.0  # Generate insights every 30 seconds
    timer.autostart = true
    timer.timeout.connect(_generate_emotional_insights)
    add_child(timer)

func _connect_to_systems():
    # Connect to MultiAccountManager
    if has_node("/root/MultiAccountManager") or get_node_or_null("/root/MultiAccountManager"):
        account_manager = get_node("/root/MultiAccountManager")
        print("Connected to MultiAccountManager")
    
    # Connect to MultiAccountAPIController
    if has_node("/root/MultiAccountAPIController") or get_node_or_null("/root/MultiAccountAPIController"):
        api_controller = get_node("/root/MultiAccountAPIController")
        print("Connected to MultiAccountAPIController")
        
        # Connect to API controller signals
        if api_controller:
            api_controller.api_request_sent.connect(_on_api_request_sent)
            api_controller.api_response_received.connect(_on_api_response_received)
    
    # Connect to MultiAccount3DVisualizer
    if has_node("/root/MultiAccount3DVisualizer") or get_node_or_null("/root/MultiAccount3DVisualizer"):
        visualizer = get_node("/root/MultiAccount3DVisualizer")
        print("Connected to MultiAccount3DVisualizer")

func process_emotional_content(account_id, api_name, content, task_type="general"):
    """
    Process text content to extract and charge for emotional content
    """
    # Analyze text for emotional content
    var emotion_data = _analyze_emotion(content)
    
    # Calculate cost based on emotional content
    var task_data = {
        "emotion_type": emotion_data.type,
        "emotion_level": emotion_data.level,
        "task_type": task_type,
        "content_length": content.length()
    }
    
    var cost = pricing_system.calculate_cost(account_id, api_name, task_data)
    
    # Visualize the emotion if visualizer is available
    if visualizer and account_id in visualizer.account_nodes:
        _visualize_emotion(account_id, emotion_data.type, emotion_data.level, cost)
    
    # Emit signal
    emit_signal("emotion_processed", account_id, emotion_data.type, emotion_data.level, cost)
    
    return {
        "emotion": emotion_data,
        "cost": cost,
        "account_id": account_id,
        "api_name": api_name
    }

func get_account_emotion_stats(account_id):
    """
    Get the emotional usage statistics for an account
    """
    var stats = {
        "total_cost": 0,
        "top_emotions": [],
        "daily_limit": pricing_system.get_account_limit(account_id),
        "usage": pricing_system.get_account_usage(account_id),
        "remaining": 0
    }
    
    # Calculate remaining points
    stats.remaining = stats.daily_limit - stats.usage
    
    # Get top emotions
    stats.top_emotions = pricing_system.get_top_emotions(account_id)
    
    return stats

func get_optimal_emotional_routing(account_id, content):
    """
    Determine the optimal API to route content to based on emotional content
    """
    # Analyze emotional content
    var emotion_data = _analyze_emotion(content)
    
    # Get optimal API
    var optimal_api = pricing_system.get_optimal_api(account_id, emotion_data.type)
    
    return {
        "optimal_api": optimal_api,
        "emotion_type": emotion_data.type,
        "emotion_level": emotion_data.level,
        "estimated_cost": pricing_system.calculate_cost(account_id, optimal_api, {
            "emotion_type": emotion_data.type,
            "emotion_level": emotion_data.level
        })
    }

func get_emotion_price_matrix():
    """
    Get the complete emotion pricing matrix
    """
    return pricing_system.get_emotion_price_chart()

# Visualization methods

func _visualize_emotion(account_id, emotion_type, emotion_level, cost):
    # Get the account node from visualizer
    var account_data = visualizer.account_nodes[account_id]
    var account_node = account_data.node
    
    if not is_instance_valid(account_node):
        return
    
    # Create or update emotion particles
    var emotion_key = account_id + "_" + emotion_type
    
    if not emotion_key in emotion_particles:
        # Create new particle system
        var particles = GPUParticles3D.new()
        account_node.add_child(particles)
        
        # Configure particle properties
        var material = ParticleProcessMaterial.new()
        material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
        material.emission_sphere_radius = 1.0
        material.gravity = Vector3(0, 0.5, 0)
        material.scale_min = 0.05
        material.scale_max = 0.15
        
        # Set color based on emotion
        if emotion_type in EMOTION_COLORS:
            material.color = EMOTION_COLORS[emotion_type]
        else:
            material.color = Color(0.8, 0.8, 0.8)  # Default gray
        
        particles.process_material = material
        
        # Create mesh for particles
        var mesh = SphereMesh.new()
        mesh.radius = 0.1
        mesh.height = 0.2
        particles.draw_pass_1 = mesh
        
        # Store reference
        emotion_particles[emotion_key] = particles
    
    # Update particle count based on emotion level
    var particles = emotion_particles[emotion_key]
    if is_instance_valid(particles):
        var particle_count = 0
        
        match emotion_level:
            "neutral": particle_count = 5
            "mild": particle_count = 15
            "medium": particle_count = 30
            "strong": particle_count = 50
            "intense": particle_count = 100
        
        particles.amount = particle_count
        particles.emitting = true
    
    # Visualize satoshi cost
    _visualize_cost(account_id, cost, EMOTION_COLORS.get(emotion_type, Color(0.8, 0.8, 0.8)))

func _visualize_cost(account_id, cost, color):
    if cost <= 0:
        return
    
    # Get account node
    var account_data = visualizer.account_nodes[account_id]
    var account_node = account_data.node
    
    if not is_instance_valid(account_node):
        return
    
    # Create satoshi indicator
    var satoshi_key = account_id + "_satoshi"
    
    if not satoshi_key in satoshi_counters:
        # Create 3D label for satoshi counter
        var label = Label3D.new()
        label.text = "0 sat"
        label.font_size = 16
        label.pixel_size = 0.01
        label.no_depth_test = true
        label.position.y = 1.2
        account_node.add_child(label)
        
        # Store reference
        satoshi_counters[satoshi_key] = {
            "label": label,
            "total": 0,
            "last_update": Time.get_unix_time_from_system()
        }
    
    # Update counter
    var counter = satoshi_counters[satoshi_key]
    counter.total += cost
    counter.last_update = Time.get_unix_time_from_system()
    
    if is_instance_valid(counter.label):
        counter.label.text = str(counter.total) + " sat"
        counter.label.modulate = color
        
        # Make text pulse
        var scale = 1.0 + (cost * 0.1)
        counter.label.scale = Vector3(scale, scale, scale)

# API signal handlers

func _on_api_request_sent(from_account, to_account, api_type, request):
    # Process emotional content of the request
    if typeof(request) == TYPE_DICTIONARY and request.has("prompt"):
        var api_name = ["claude_api", "gemini_api", "custom_api", "internal", "shared", "secure"][api_type]
        process_emotional_content(from_account, api_name, request.prompt, "request")

func _on_api_response_received(from_account, to_account, api_type, response):
    # Process emotional content of the response
    if typeof(response) == TYPE_DICTIONARY:
        var content = ""
        
        if response.has("completion"):
            content = response.completion
        elif response.has("text"):
            content = response.text
        
        if content:
            var api_name = ["claude_api", "gemini_api", "custom_api", "internal", "shared", "secure"][api_type]
            process_emotional_content(to_account, api_name, content, "response")

# Pricing signal handlers

func _on_cost_calculated(account_id, emotion_type, emotion_level, cost):
    # This is called after a cost calculation
    print("Emotion cost calculated: " + account_id + " - " + emotion_type + " (" + emotion_level + ") = " + str(cost) + " satoshis")

func _on_limit_reached(account_id, emotion_type):
    # This is called when an account reaches its daily limit
    print("Emotion limit reached for " + account_id)
    emit_signal("emotion_threshold_reached", account_id, "daily_limit", pricing_system.get_account_limit(account_id))

# Emotion analysis and insights

func _analyze_emotion(content):
    """
    Analyze text content for emotional content
    This is a simplified implementation - in a real system you would use NLP
    """
    # Simple keyword-based analysis
    var emotions = pricing_system.EMOTION_TYPES
    var scores = {}
    
    for emotion in emotions:
        scores[emotion] = 0
    
    # Simplified emotion detection - count keyword occurrences
    var keywords = {
        "joy": ["happy", "joy", "great", "excellent", "wonderful", "smile", "laugh", "exciting"],
        "sadness": ["sad", "unhappy", "depressing", "sorrow", "grief", "tear", "cry", "lonely"],
        "anger": ["angry", "mad", "hate", "rage", "furious", "annoyed", "irritated", "fuming"],
        "fear": ["afraid", "scared", "terrified", "horror", "dread", "panic", "anxious", "worry"],
        "surprise": ["surprise", "shocked", "amazing", "astonishing", "unexpected", "wow", "incredible"],
        "disgust": ["disgust", "gross", "revolting", "nasty", "repulsive", "yuck", "offensive"],
        "trust": ["trust", "reliable", "confident", "faith", "believe", "assurance", "secure"],
        "anticipation": ["anticipate", "expect", "await", "hope", "looking forward", "predict"],
        "focus": ["focus", "concentrate", "attention", "precise", "clarity", "detail", "specific"],
        "inspiration": ["inspire", "creativity", "vision", "idea", "enlighten", "innovative", "dreamer"]
    }
    
    var content_lower = content.to_lower()
    
    for emotion in keywords:
        for keyword in keywords[emotion]:
            var count = content_lower.count(keyword)
            if count > 0:
                scores[emotion] += count
    
    # Find the dominant emotion
    var max_score = 0
    var dominant_emotion = "neutral"
    
    for emotion in scores:
        if scores[emotion] > max_score:
            max_score = scores[emotion]
            dominant_emotion = emotion
    
    # Determine intensity level
    var level = "neutral"
    
    if max_score > 0:
        if max_score >= 10:
            level = "intense"
        elif max_score >= 7:
            level = "strong"
        elif max_score >= 4:
            level = "medium"
        elif max_score >= 1:
            level = "mild"
    
    return {
        "type": dominant_emotion,
        "level": level,
        "scores": scores
    }

func _generate_emotional_insights():
    """
    Analyze emotional patterns and generate insights
    """
    for account_id in pricing_system.emotion_points_used:
        var account_emotions = pricing_system.emotion_points_used[account_id]
        
        # Skip if not enough emotion data
        if account_emotions.size() < 2:
            continue
        
        # Find the two dominant emotions
        var sorted_emotions = []
        for emotion in account_emotions:
            sorted_emotions.append({
                "type": emotion,
                "points": account_emotions[emotion]
            })
        
        # Sort by points
        sorted_emotions.sort_custom(func(a, b): return a.points > b.points)
        
        if sorted_emotions.size() >= 2:
            var primary = sorted_emotions[0].type
            var secondary = sorted_emotions[1].type
            
            # Generate insight based on emotional pattern
            var insight = _generate_insight(primary, secondary)
            
            # Add account statistics
            insight.account_id = account_id
            insight.total_points = pricing_system.get_account_usage(account_id)
            insight.limit = pricing_system.get_account_limit(account_id)
            insight.remaining = insight.limit - insight.total_points
            
            # Emit signal with insight
            emit_signal("emotional_insight_generated", account_id, insight)

func _generate_insight(primary_emotion, secondary_emotion):
    """
    Generate an insight based on emotional pattern
    """
    var insight = {
        "primary_emotion": primary_emotion,
        "secondary_emotion": secondary_emotion,
        "message": "",
        "recommended_api": "",
        "optimization_tip": ""
    }
    
    # Set recommended API based on primary emotion
    insight.recommended_api = pricing_system.get_optimal_api("", primary_emotion)
    
    # Generate message based on emotion combination
    var combo_key = primary_emotion + "_" + secondary_emotion
    
    match combo_key:
        "joy_trust":
            insight.message = "Positive engagement pattern detected"
            insight.optimization_tip = "Leverage Claude API for creative content"
        "joy_anticipation":
            insight.message = "Forward-looking positivity pattern"
            insight.optimization_tip = "Balance between Claude and Gemini APIs"
        "sadness_fear":
            insight.message = "Caution pattern detected"
            insight.optimization_tip = "OpenAI API handles this emotional blend efficiently"
        "anger_disgust":
            insight.message = "Strong negative reaction pattern"
            insight.optimization_tip = "Consider rate limiting to reduce costs"
        "surprise_joy":
            insight.message = "Discovery and delight pattern"
            insight.optimization_tip = "Gemini API processes this efficiently"
        "focus_trust":
            insight.message = "Steady productivity pattern"
            insight.optimization_tip = "Balance workload across APIs"
        "inspiration_anticipation":
            insight.message = "Creative planning pattern"
            insight.optimization_tip = "Claude API offers best value for this pattern"
        _:
            insight.message = "Mixed emotion pattern detected"
            insight.optimization_tip = "Distribute across optimal APIs for each emotion"
    
    return insight