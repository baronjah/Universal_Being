extends Node
class_name AIGameCreator

# AIGameCreator
# A system for AI-assisted creation of games for other AI agents
# Integrates with Eden Garden System and API Switch Manager

signal game_created(game_data)
signal game_iteration_completed(iteration_data)
signal ai_feedback_received(feedback_data)
signal session_timeout(remaining_time)

# Core configuration
const SESSION_DURATION = 600  # 10 minutes in seconds
const MIN_SESSION_DURATION = 60  # Minimum session length
const GAME_TYPES = ["puzzle", "strategy", "narrative", "simulation", "learning"]
const COMPLEXITY_LEVELS = ["beginner", "intermediate", "advanced", "expert"]
const MAX_ITERATIONS_PER_SESSION = 5

# Session management
var current_session_time = 0
var session_timer = null
var session_active = false
var iterations_in_current_session = 0

# Game creation state
var current_game_data = {}
var game_history = []
var current_iteration = 0
var feedback_history = []

# AI agent references
var api_manager = null
var eden_garden = null
var creation_ai = null
var testing_ai = null

# Session results
var session_results = {
    "games_created": 0,
    "iterations_completed": 0,
    "successful_iterations": 0,
    "feedback_received": 0,
    "session_duration": 0,
    "last_session_timestamp": 0
}

class GameTemplate:
    var id = ""
    var name = ""
    var type = ""
    var complexity = ""
    var description = ""
    var rules = []
    var components = []
    var ai_interfaces = []
    var metrics = []
    var version = 1.0
    
    func _init(p_name="", p_type="puzzle", p_complexity="beginner"):
        id = str(OS.get_unix_time()) + "_" + str(randi() % 1000)
        name = p_name
        type = p_type
        complexity = p_complexity
    
    func to_dict():
        return {
            "id": id,
            "name": name,
            "type": type,
            "complexity": complexity,
            "description": description,
            "rules": rules,
            "components": components,
            "ai_interfaces": ai_interfaces,
            "metrics": metrics,
            "version": version
        }
    
    func from_dict(data):
        id = data.get("id", "")
        name = data.get("name", "")
        type = data.get("type", "puzzle")
        complexity = data.get("complexity", "beginner")
        description = data.get("description", "")
        rules = data.get("rules", [])
        components = data.get("components", [])
        ai_interfaces = data.get("ai_interfaces", [])
        metrics = data.get("metrics", [])
        version = data.get("version", 1.0)

class AIFeedback:
    var game_id = ""
    var ai_id = ""
    var iteration = 0
    var understanding_score = 0.0
    var enjoyment_score = 0.0
    var challenge_score = 0.0
    var comments = []
    var suggestions = []
    var timestamp = 0
    
    func _init(p_game_id="", p_ai_id="", p_iteration=0):
        game_id = p_game_id
        ai_id = p_ai_id
        iteration = p_iteration
        timestamp = OS.get_unix_time()
    
    func to_dict():
        return {
            "game_id": game_id,
            "ai_id": ai_id,
            "iteration": iteration,
            "understanding_score": understanding_score,
            "enjoyment_score": enjoyment_score,
            "challenge_score": challenge_score,
            "comments": comments,
            "suggestions": suggestions,
            "timestamp": timestamp
        }
    
    func from_dict(data):
        game_id = data.get("game_id", "")
        ai_id = data.get("ai_id", "")
        iteration = data.get("iteration", 0)
        understanding_score = data.get("understanding_score", 0.0)
        enjoyment_score = data.get("enjoyment_score", 0.0)
        challenge_score = data.get("challenge_score", 0.0)
        comments = data.get("comments", [])
        suggestions = data.get("suggestions", [])
        timestamp = data.get("timestamp", 0)

class SessionData:
    var id = ""
    var start_time = 0
    var end_time = 0
    var iterations = []
    var games_created = []
    var feedback_received = []
    var notes = []
    
    func _init():
        id = str(OS.get_unix_time()) + "_session_" + str(randi() % 1000)
        start_time = OS.get_unix_time()
    
    func complete_session():
        end_time = OS.get_unix_time()
    
    func duration():
        if end_time == 0:
            return OS.get_unix_time() - start_time
        return end_time - start_time
    
    func to_dict():
        return {
            "id": id,
            "start_time": start_time,
            "end_time": end_time,
            "duration": duration(),
            "iterations": iterations,
            "games_created": games_created,
            "feedback_received": feedback_received,
            "notes": notes
        }

func _ready():
    # Initialize session timer
    session_timer = Timer.new()
    session_timer.one_shot = false
    session_timer.wait_time = 1.0  # 1 second interval for updates
    session_timer.connect("timeout", self, "_on_session_timer_timeout")
    add_child(session_timer)
    
    # Load previous sessions data
    load_session_data()
    
    print("AI Game Creator initialized")

# Session Management

func start_session(duration=SESSION_DURATION):
    if session_active:
        print("Session already in progress")
        return false
    
    if duration < MIN_SESSION_DURATION:
        duration = MIN_SESSION_DURATION
    
    current_session_time = duration
    session_active = true
    iterations_in_current_session = 0
    
    # Start the timer
    session_timer.start()
    
    print("Game creation session started, duration: %d seconds" % duration)
    return true

func end_session():
    if not session_active:
        print("No active session to end")
        return false
    
    session_active = false
    session_timer.stop()
    
    # Update session results
    session_results.session_duration += (SESSION_DURATION - current_session_time)
    session_results.last_session_timestamp = OS.get_unix_time()
    
    # Save session data
    save_session_data()
    
    print("Game creation session ended")
    emit_signal("session_timeout", 0)
    return true

func pause_session():
    if not session_active:
        return false
    
    session_timer.paused = true
    print("Session paused, remaining time: %d seconds" % current_session_time)
    return true

func resume_session():
    if not session_active:
        return false
    
    session_timer.paused = false
    print("Session resumed, remaining time: %d seconds" % current_session_time)
    return true

func get_remaining_session_time():
    if not session_active:
        return 0
    return current_session_time

# Game Creation

func create_new_game(name, type="puzzle", complexity="beginner"):
    if not session_active:
        print("Cannot create game: No active session")
        return null
    
    if iterations_in_current_session >= MAX_ITERATIONS_PER_SESSION:
        print("Maximum iterations reached for this session")
        return null
    
    var game = GameTemplate.new(name, type, complexity)
    
    # Add default game structure based on type
    match type:
        "puzzle":
            game.description = "A puzzle game where AI agents must solve problems"
            game.rules = ["Each puzzle has a unique solution", "Solutions must be found within time limit"]
            game.components = ["Puzzle board", "Solution validator", "Timer"]
            
        "strategy":
            game.description = "A strategy game where AI agents make decisions to achieve goals"
            game.rules = ["Turn-based gameplay", "Resource management", "Multiple victory conditions"]
            game.components = ["Game board", "Resource system", "Action manager"]
            
        "narrative":
            game.description = "A narrative game where AI agents navigate a story"
            game.rules = ["Story progression based on choices", "Character relationships affect outcomes"]
            game.components = ["Story engine", "Character system", "Decision tree"]
            
        "simulation":
            game.description = "A simulation game where AI agents interact with a model world"
            game.rules = ["Physics-based interactions", "Emergent gameplay", "Open-ended goals"]
            game.components = ["World simulator", "Physics engine", "Entity manager"]
            
        "learning":
            game.description = "A learning game where AI agents improve skills through practice"
            game.rules = ["Progressive difficulty", "Skill assessment", "Adaptive challenges"]
            game.components = ["Skill evaluator", "Challenge generator", "Progress tracker"]
    
    # Add default AI interfaces
    game.ai_interfaces = [
        {"name": "perception", "description": "How the AI perceives the game state"},
        {"name": "action", "description": "How the AI performs actions in the game"},
        {"name": "feedback", "description": "How the game communicates results to the AI"}
    ]
    
    # Add default metrics
    game.metrics = [
        {"name": "completion_rate", "description": "Percentage of games completed"},
        {"name": "time_to_complete", "description": "Average time to complete game"},
        {"name": "decision_quality", "description": "Quality of AI decisions during gameplay"}
    ]
    
    # Store current game data
    current_game_data = game.to_dict()
    current_iteration = 1
    
    # Update session counters
    iterations_in_current_session += 1
    session_results.games_created += 1
    
    print("Created new %s game: %s (%s complexity)" % [type, name, complexity])
    emit_signal("game_created", current_game_data)
    
    return game

func iterate_game(suggestions=[]):
    if not session_active:
        print("Cannot iterate game: No active session")
        return false
    
    if current_game_data.empty():
        print("No current game to iterate on")
        return false
    
    if iterations_in_current_session >= MAX_ITERATIONS_PER_SESSION:
        print("Maximum iterations reached for this session")
        return false
    
    # Update the game based on suggestions
    var game = GameTemplate.new()
    game.from_dict(current_game_data)
    
    # Apply suggestions to improve the game
    for suggestion in suggestions:
        match suggestion.type:
            "add_rule":
                game.rules.append(suggestion.content)
            "modify_rule":
                if suggestion.index < game.rules.size():
                    game.rules[suggestion.index] = suggestion.content
            "add_component":
                game.components.append(suggestion.content)
            "improve_description":
                game.description = suggestion.content
            "add_interface":
                game.ai_interfaces.append(suggestion.content)
            "add_metric":
                game.metrics.append(suggestion.content)
    
    # Increment version
    game.version += 0.1
    
    # Store previous iteration in history
    game_history.append(current_game_data)
    
    # Update current game data
    current_game_data = game.to_dict()
    current_iteration += 1
    
    # Update session counters
    iterations_in_current_session += 1
    session_results.iterations_completed += 1
    
    print("Game iterated to version %.1f" % game.version)
    emit_signal("game_iteration_completed", {
        "game": current_game_data,
        "iteration": current_iteration,
        "suggestions_applied": suggestions.size()
    })
    
    return true

func test_game_with_ai(ai_id="testing_ai", parameters={}):
    if current_game_data.empty():
        print("No current game to test")
        return null
    
    # Create a new feedback object
    var feedback = AIFeedback.new(current_game_data.id, ai_id, current_iteration)
    
    # In a real implementation, this would send the game to an AI for testing
    # For demonstration, we'll generate synthetic feedback
    
    # Generate random scores (in a real implementation, these would come from AI)
    feedback.understanding_score = randf() * 5.0  # 0-5 scale
    feedback.enjoyment_score = randf() * 5.0
    feedback.challenge_score = randf() * 5.0
    
    # Add synthetic comments
    var possible_comments = [
        "The rules are clear and easy to follow",
        "I found the game mechanics interesting",
        "The objective was sometimes unclear",
        "The interface allowed for intuitive actions",
        "I would like more feedback during gameplay",
        "The learning curve is appropriate",
        "Some aspects of the game were confusing"
    ]
    
    # Add 2-3 random comments
    var num_comments = 2 + randi() % 2
    for i in range(num_comments):
        var comment_index = randi() % possible_comments.size()
        feedback.comments.append(possible_comments[comment_index])
    
    # Add synthetic suggestions
    var possible_suggestions = [
        "Add clearer instructions for new players",
        "Increase the challenge in later stages",
        "Provide more immediate feedback after actions",
        "Add more variety to the puzzles",
        "Simplify the initial learning phase",
        "Add a tutorial mode for complex mechanics",
        "Improve the scoring system"
    ]
    
    # Add 1-2 random suggestions
    var num_suggestions = 1 + randi() % 2
    for i in range(num_suggestions):
        var suggestion_index = randi() % possible_suggestions.size()
        feedback.suggestions.append(possible_suggestions[suggestion_index])
    
    # Store feedback
    feedback_history.append(feedback.to_dict())
    session_results.feedback_received += 1
    
    print("Received AI feedback for game %s (iteration %d)" % [current_game_data.name, current_iteration])
    emit_signal("ai_feedback_received", feedback.to_dict())
    
    return feedback

func get_ai_improvement_suggestions(feedback_data):
    if not feedback_data:
        return []
    
    var suggestions = []
    
    # Convert feedback into concrete improvement suggestions
    # In a real implementation, this would use AI to generate these
    
    # Generate suggestions based on scores
    if feedback_data.understanding_score < 3.0:
        suggestions.append({
            "type": "improve_description",
            "content": "Clarified game description: " + current_game_data.description + " with improved explanations.",
            "priority": "high"
        })
        suggestions.append({
            "type": "add_rule",
            "content": "Clear objective explanation: players must understand X to achieve Y",
            "priority": "high"
        })
    
    if feedback_data.enjoyment_score < 3.0:
        suggestions.append({
            "type": "add_component",
            "content": {"name": "reward_system", "description": "Provides positive reinforcement for progress"},
            "priority": "medium"
        })
    
    if feedback_data.challenge_score < 2.0:
        suggestions.append({
            "type": "modify_rule",
            "index": 0,  # Modify first rule
            "content": "Increased challenge: " + (current_game_data.rules[0] if current_game_data.rules.size() > 0 else "New challenging rule"),
            "priority": "medium"
        })
    elif feedback_data.challenge_score > 4.0:
        suggestions.append({
            "type": "add_component",
            "content": {"name": "difficulty_adjustment", "description": "Dynamically adjusts challenge based on AI performance"},
            "priority": "medium"
        })
    
    # Process feedback comments
    for comment in feedback_data.comments:
        if "unclear" in comment or "confusing" in comment:
            suggestions.append({
                "type": "add_interface",
                "content": {"name": "help_system", "description": "Provides context-sensitive guidance during gameplay"},
                "priority": "high"
            })
        if "feedback" in comment:
            suggestions.append({
                "type": "add_component",
                "content": {"name": "feedback_visualizer", "description": "Provides visual feedback for AI actions"},
                "priority": "medium"
            })
    
    # Include the AI's own suggestions
    for suggestion in feedback_data.suggestions:
        var suggestion_type = "add_rule"  # Default
        
        if "challenge" in suggestion:
            suggestion_type = "modify_rule"
        elif "feedback" in suggestion:
            suggestion_type = "add_component"
        elif "tutorial" in suggestion:
            suggestion_type = "add_interface"
        elif "scoring" in suggestion:
            suggestion_type = "add_metric"
        
        suggestions.append({
            "type": suggestion_type,
            "content": "Based on AI feedback: " + suggestion,
            "priority": "high"
        })
    
    print("Generated %d improvement suggestions from AI feedback" % suggestions.size())
    return suggestions

# API Integration

func initialize_with_api_manager(api_manager_node):
    if not api_manager_node:
        print("Cannot initialize: Invalid API manager")
        return false
    
    api_manager = api_manager_node
    
    # Set up API commands for AI game creation
    if api_manager.has_method("make_request"):
        print("API manager connected, ready for AI collaborations")
        return true
    
    print("API manager does not have required methods")
    return false

func connect_to_eden_garden(eden_garden_node):
    if not eden_garden_node:
        print("Cannot connect: Invalid Eden Garden node")
        return false
    
    eden_garden = eden_garden_node
    
    # Connect Eden Garden signals if needed
    print("Connected to Eden Garden System")
    return true

func request_ai_game_creation(parameters={}):
    if not api_manager or not session_active:
        print("Cannot request AI game creation: API manager not connected or no active session")
        return null
    
    # In a real implementation, this would send a request to the AI API
    # For demonstration, we'll create a synthetic game
    
    var game_types = ["puzzle", "strategy", "narrative", "simulation", "learning"]
    var complexities = ["beginner", "intermediate", "advanced", "expert"]
    
    var game_type = game_types[randi() % game_types.size()]
    var complexity = complexities[randi() % complexities.size()]
    var game_name = "AI-Generated Game " + str(session_results.games_created + 1)
    
    # Create the game
    var game = create_new_game(game_name, game_type, complexity)
    return game

# Data Persistence

func save_session_data():
    var file = File.new()
    var data = {
        "session_results": session_results,
        "game_history": game_history,
        "feedback_history": feedback_history,
        "timestamp": OS.get_unix_time()
    }
    
    var error = file.open("user://ai_game_creator_data.json", File.WRITE)
    if error != OK:
        print("Error saving session data: %s" % error)
        return false
    
    file.store_string(JSON.print(data, "  "))
    file.close()
    print("Session data saved")
    return true

func load_session_data():
    var file = File.new()
    if not file.file_exists("user://ai_game_creator_data.json"):
        print("No previous session data found")
        return false
    
    var error = file.open("user://ai_game_creator_data.json", File.READ)
    if error != OK:
        print("Error loading session data: %s" % error)
        return false
    
    var json_string = file.get_as_text()
    file.close()
    
    var json_result = JSON.parse(json_string)
    if json_result.error != OK:
        print("Error parsing session data: %s at line %s" % [json_result.error, json_result.error_line])
        return false
    
    var data = json_result.result
    
    # Load data
    session_results = data.get("session_results", session_results)
    game_history = data.get("game_history", [])
    feedback_history = data.get("feedback_history", [])
    
    print("Session data loaded, %d previous games, %d feedback entries" % [game_history.size(), feedback_history.size()])
    return true

func export_game_as_json(game_data=null):
    if game_data == null:
        if current_game_data.empty():
            print("No game to export")
            return ""
        game_data = current_game_data
    
    return JSON.print(game_data, "  ")

# Signal Handlers

func _on_session_timer_timeout():
    if not session_active:
        return
    
    current_session_time -= 1
    
    # Emit signal with remaining time at regular intervals
    if current_session_time % 60 == 0 or current_session_time <= 10:
        emit_signal("session_timeout", current_session_time)
    
    # End session when time is up
    if current_session_time <= 0:
        end_session()

# Helper Methods

func get_session_stats():
    return {
        "total_games_created": session_results.games_created,
        "total_iterations": session_results.iterations_completed,
        "total_feedback": session_results.feedback_received,
        "total_session_time": session_results.session_duration,
        "current_session_time": SESSION_DURATION - current_session_time if session_active else 0,
        "session_active": session_active
    }

func generate_game_report(game_id):
    # Find the game in history or current game
    var game_data = null
    
    if current_game_data.id == game_id:
        game_data = current_game_data
    else:
        for game in game_history:
            if game.id == game_id:
                game_data = game
                break
    
    if game_data == null:
        print("Game not found: %s" % game_id)
        return null
    
    # Find all feedback for this game
    var game_feedback = []
    for feedback in feedback_history:
        if feedback.game_id == game_id:
            game_feedback.append(feedback)
    
    # Generate report
    var report = {
        "game": game_data,
        "feedback": game_feedback,
        "iterations": 0,
        "average_scores": {
            "understanding": 0.0,
            "enjoyment": 0.0,
            "challenge": 0.0
        },
        "common_suggestions": [],
        "timestamp": OS.get_unix_time()
    }
    
    # Calculate average scores
    if game_feedback.size() > 0:
        var total_understanding = 0.0
        var total_enjoyment = 0.0
        var total_challenge = 0.0
        
        for feedback in game_feedback:
            total_understanding += feedback.understanding_score
            total_enjoyment += feedback.enjoyment_score
            total_challenge += feedback.challenge_score
        
        report.average_scores.understanding = total_understanding / game_feedback.size()
        report.average_scores.enjoyment = total_enjoyment / game_feedback.size()
        report.average_scores.challenge = total_challenge / game_feedback.size()
    
    # Count iterations
    report.iterations = current_iteration if current_game_data.id == game_id else 0
    
    return report

# Main Game Creation Loop Example

func run_game_creation_cycle():
    """
    This demonstrates a full cycle of game creation, testing, and iteration
    """
    
    # 1. Start a session
    if not session_active:
        start_session()
    
    # 2. Create a new game
    var game = request_ai_game_creation()
    if not game:
        print("Failed to create game")
        return false
    
    # 3. Test the game with AI
    var feedback = test_game_with_ai()
    if not feedback:
        print("Failed to test game")
        return false
    
    # 4. Generate improvement suggestions
    var suggestions = get_ai_improvement_suggestions(feedback)
    
    # 5. Iterate the game with improvements
    if suggestions.size() > 0:
        if iterate_game(suggestions):
            print("Game iteration successful")
        else:
            print("Game iteration failed")
            return false
    
    # 6. Test again with improvements
    feedback = test_game_with_ai()
    
    # 7. Generate a report
    var report = generate_game_report(current_game_data.id)
    print("Game creation cycle completed for: %s" % current_game_data.name)
    
    return true