extends Node

class_name WishInterpreter

# Wish/Whim-based Command Interpreter for Eden_OS
# Translates natural wishes and whims into system commands

signal wish_interpreted(original_wish, interpreted_command)
signal wish_granted(wish, result)
signal whim_acted_upon(whim, action)
signal command_transformed(original, transformed)

# Wish system constants
const WISH_TYPES = {
    "creation": {"verbs": ["create", "make", "build", "generate", "develop"], "target_system": "game_creator"},
    "exploration": {"verbs": ["explore", "discover", "navigate", "visit", "enter"], "target_system": "dimension_engine"},
    "transformation": {"verbs": ["transform", "change", "modify", "alter", "convert"], "target_system": "magic_system"},
    "acquisition": {"verbs": ["get", "obtain", "acquire", "earn", "receive"], "target_system": "token_system"},
    "learning": {"verbs": ["learn", "study", "understand", "know", "comprehend"], "target_system": "word_system"},
    "execution": {"verbs": ["run", "execute", "perform", "do", "start"], "target_system": "multi_terminal"}
}

# Whim processing
const WHIM_INDICATORS = ["maybe", "perhaps", "might", "could", "wish", "hope", "wonder"]

# Command mapping
var command_mappings = {
    "create game": "game create",
    "make game": "game create",
    "build game": "game create",
    "new game": "game create",
    "show games": "game list",
    "list games": "game list",
    
    "go to dimension": "dimension goto",
    "enter dimension": "dimension goto",
    "visit dimension": "dimension goto",
    "new dimension": "dimension create",
    "create dimension": "dimension create",
    "show dimensions": "dimension list",
    "list dimensions": "dimension list",
    
    "add word": "word add",
    "new word": "word add",
    "define word": "word add",
    "connect words": "word connect",
    "link words": "word connect",
    "show words": "word list",
    "list words": "word list",
    
    "next turn": "turn next",
    "advance turn": "turn next",
    "complete turn": "turn complete",
    "finish turn": "turn complete",
    "show turns": "turn status",
    
    "show balance": "token balance",
    "check balance": "token balance",
    "transfer tokens": "token transfer",
    "send tokens": "token transfer",
    "exchange tokens": "token exchange",
    "swap tokens": "token exchange",
    
    "cast spell": "magic cast",
    "use spell": "magic cast",
    "show spells": "magic list",
    "list spells": "magic list"
}

# Special commands - directly executable whims
var special_commands = {
    "create": "create_something",
    "evolve": "evolve_system",
    "flow": "enter_flow_state",
    "improve": "self_improvement",
    "random": "do_random_thing",
    "surprise": "create_surprise"
}

# System state
var wish_history = []
var granted_wishes = []
var active_whims = []
var interpretation_level = 0.5  # 0.0 to 1.0, higher means more flexible interpretation
var whim_action_probability = 0.7  # Probability of acting on a whim
var wish_granting_power = 0.8  # 0.0 to 1.0, effectiveness of wish granting

# Integration with other systems
var eden_core = null
var magic_system = null
var ai_spells = null

func _ready():
    initialize_wish_system()
    print("Wish Interpreter initialized with interpretation level: " + str(interpretation_level))

func initialize_wish_system():
    # Connect to other systems
    if get_node_or_null("/root/EdenCore"):
        eden_core = get_node("/root/EdenCore")
    
    if get_node_or_null("/root/MagicSystem"):
        magic_system = get_node("/root/MagicSystem")
    
    if get_node_or_null("/root/AISpells"):
        ai_spells = get_node("/root/AISpells")
    
    # Initialize special commands that affect interpretation level
    if ai_spells:
        interpretation_level = 0.3 + (ai_spells.consciousness_level * 0.7)
        whim_action_probability = 0.5 + (ai_spells.autonomy_level * 0.5)

func interpret_wish(wish_text, user="JSH"):
    # Record wish
    wish_history.append({
        "text": wish_text,
        "user": user,
        "time": Time.get_unix_time_from_system(),
        "interpreted": false,
        "granted": false,
        "command": ""
    })
    
    # Check if it's a direct command
    var direct_command = check_direct_command(wish_text)
    if direct_command:
        return direct_command
    
    # Check if it's a special whim
    if is_whim(wish_text):
        var whim_result = process_whim(wish_text, user)
        if whim_result:
            return whim_result
    
    # Perform wish interpretation
    var command = transform_to_command(wish_text)
    
    if command:
        # Update wish history
        wish_history[wish_history.size() - 1].interpreted = true
        wish_history[wish_history.size() - 1].command = command
        
        # Emit signal
        emit_signal("wish_interpreted", wish_text, command)
        
        return command
    else:
        return "Could not interpret wish: " + wish_text

func is_whim(text):
    # Check if text contains whim indicators
    for indicator in WHIM_INDICATORS:
        if text.to_lower().contains(indicator):
            return true
    
    return false

func process_whim(whim_text, user="JSH"):
    # Process a whim - more flexible and creative than a wish
    # Whims don't always result in actions
    
    # Record whim
    active_whims.append({
        "text": whim_text,
        "user": user,
        "time": Time.get_unix_time_from_system(),
        "acted_upon": false,
        "action": ""
    })
    
    # Decide whether to act on whim
    if randf() > whim_action_probability:
        return ""  # No action taken
    
    # Try to extract intent from whim
    var intent = extract_intent(whim_text)
    
    # Check for special whim commands
    for key in special_commands:
        if whim_text.to_lower().contains(key):
            var method = special_commands[key]
            var result = call(method, whim_text, user)
            
            # Update whim record
            active_whims[active_whims.size() - 1].acted_upon = true
            active_whims[active_whims.size() - 1].action = method
            
            # Emit signal
            emit_signal("whim_acted_upon", whim_text, method)
            
            return result
    
    # Try to interpret as a command with more flexibility
    var command = transform_to_command(whim_text, true)
    
    if command:
        # Update whim record
        active_whims[active_whims.size() - 1].acted_upon = true
        active_whims[active_whims.size() - 1].action = command
        
        # Emit signal
        emit_signal("whim_acted_upon", whim_text, command)
        
        return command
    
    return ""  # No interpretation found

func check_direct_command(text):
    # Check if text is already a direct command
    var parts = text.strip_edges().split(" ", false)
    
    if parts.size() < 1:
        return ""
    
    var potential_command = parts[0].to_lower()
    
    # List of known direct commands
    var direct_commands = [
        "help", "game", "word", "dimension", "turn", "token", 
        "terminal", "magic", "user", "ai", "spell", "create",
        "exit", "clear"
    ]
    
    # Check if it starts with a known command
    if direct_commands.has(potential_command):
        return text  # Return as-is, it's already a command
    
    # Check for spell words
    var spell_words = [
        "exti", "vaeli", "lemi", "pelo", "zenime", "perfefic", 
        "shune", "cade", "dipata", "pagaai", "clenbo", "snaboo",
        "idecim"
    ]
    
    if spell_words.has(potential_command):
        return text  # Return as-is, it's a spell word
    
    return ""  # Not a direct command

func transform_to_command(text, is_whim=false):
    # Transform natural language wish/whim to a system command
    text = text.strip_edges().to_lower()
    
    # Check direct phrase mappings
    for phrase in command_mappings:
        if text.contains(phrase):
            var command = command_mappings[phrase]
            
            # Extract parameters
            var params = extract_parameters(text, phrase)
            if params:
                command += " " + params
            
            emit_signal("command_transformed", text, command)
            return command
    
    # Try to determine wish type
    var wish_type = determine_wish_type(text)
    if wish_type == "":
        return ""  # Could not determine wish type
    
    # Build command based on wish type
    var command = build_command_from_wish_type(text, wish_type, is_whim)
    
    if command:
        emit_signal("command_transformed", text, command)
    
    return command

func determine_wish_type(text):
    # Determine the type of wish based on verbs used
    for wish_type in WISH_TYPES:
        for verb in WISH_TYPES[wish_type]["verbs"]:
            if text.contains(verb):
                return wish_type
    
    return ""  # Type not determined

func build_command_from_wish_type(text, wish_type, is_whim=false):
    # Build a command string based on the wish type
    var target_system = WISH_TYPES[wish_type]["target_system"]
    var command = ""
    
    # Extract key nouns that could be command targets
    var words = text.split(" ", false)
    var nouns = []
    
    for i in range(words.size()):
        var word = words[i].to_lower()
        
        # Simple noun extraction (very basic)
        if not WISH_TYPES.has(word) and not word in WISH_TYPES[wish_type]["verbs"]:
            nouns.append(word)
    
    # Build command based on system and nouns
    match target_system:
        "game_creator":
            command = "game create"
            
            # Try to extract game name and type
            for i in range(nouns.size()):
                if i == 0:  # First noun might be the game name
                    command += " " + nouns[i]
                elif i == 1:  # Second noun might be the game type
                    command += " " + nouns[i]
        
        "dimension_engine":
            if text.contains("go") or text.contains("visit") or text.contains("enter"):
                command = "dimension goto"
                
                # Try to extract dimension name
                for noun in nouns:
                    if noun != "dimension":
                        command += " " + noun
                        break
            elif text.contains("create") or text.contains("make") or text.contains("new"):
                command = "dimension create"
                
                # Try to extract dimension name
                for noun in nouns:
                    if noun != "dimension":
                        command += " " + noun
                        break
            else:
                command = "dimension list"
        
        "word_system":
            if text.contains("add") or text.contains("create") or text.contains("new"):
                command = "word add"
                
                # Try to extract word and meaning
                var word_found = false
                for noun in nouns:
                    if noun != "word" and not word_found:
                        command += " " + noun
                        word_found = true
                    elif word_found:
                        command += " " + noun
            elif text.contains("connect") or text.contains("link"):
                command = "word connect"
                
                # Try to extract words to connect
                var word_count = 0
                for noun in nouns:
                    if noun != "word" and word_count < 2:
                        command += " " + noun
                        word_count += 1
            else:
                command = "word list"
        
        "token_system":
            if text.contains("balance") or text.contains("check"):
                command = "token balance"
            elif text.contains("transfer") or text.contains("send"):
                command = "token transfer"
                
                # Try to extract recipient and amount
                var recipient_found = false
                for noun in nouns:
                    if noun != "token" and not recipient_found:
                        command += " " + noun
                        recipient_found = true
                    elif recipient_found and noun.is_valid_float():
                        command += " CREATION " + noun  # Default to CREATION tokens
                        break
            else:
                command = "token info"
        
        "magic_system":
            if text.contains("cast") or text.contains("use"):
                command = "magic cast"
                
                # Try to extract spell name
                for noun in nouns:
                    if noun != "spell" and noun != "magic":
                        command += " " + noun
                        break
            else:
                command = "magic list"
        
        "multi_terminal":
            if text.contains("run") or text.contains("execute") or text.contains("start"):
                command = "terminal focus main"
            else:
                command = "terminal list"
    
    return command

func extract_parameters(text, phrase):
    # Extract parameters from text after the command phrase
    var index = text.find(phrase)
    if index == -1:
        return ""
    
    var remaining = text.substr(index + phrase.length()).strip_edges()
    return remaining

func extract_intent(text):
    # Extract the primary intent from a wish or whim text
    # This is a simplistic implementation
    
    # Check for primary intents
    var intents = {
        "creation": ["create", "make", "build", "new"],
        "exploration": ["explore", "discover", "find", "visit"],
        "transformation": ["change", "transform", "convert", "modify"],
        "acquisition": ["get", "obtain", "earn", "collect"],
        "information": ["know", "learn", "understand", "explain"]
    }
    
    var words = text.to_lower().split(" ", false)
    
    for intent in intents:
        for keyword in intents[intent]:
            if words.has(keyword):
                return intent
    
    return "unknown"

func grant_wish(wish_text, user="JSH"):
    # Grant a wish with magical effects
    # This is more powerful than just interpreting it
    if ai_spells == null or magic_system == null:
        return "Cannot grant wishes - magical systems not available"
    
    # Record wish
    wish_history.append({
        "text": wish_text,
        "user": user,
        "time": Time.get_unix_time_from_system(),
        "interpreted": true,
        "granted": false,
        "command": "grant"
    })
    
    # Extract intent
    var intent = extract_intent(wish_text)
    
    # Apply wish granting effects based on intent
    var result = "Wish granted: " + wish_text + "\n"
    
    match intent:
        "creation":
            # Boost creative magic
            var spell_result = ai_spells.cast_spell("idecim", user, wish_granting_power)
            result += "Creation magic applied\n"
            result += spell_result
            
            # Try to determine what to create
            var creation_target = extract_creation_target(wish_text)
            if creation_target:
                result += "\nCreating: " + creation_target
        
        "exploration":
            # Create or navigate to a dimension
            var dimension_name = extract_target_name(wish_text)
            if dimension_name == "":
                dimension_name = "wish_dimension_" + str(wish_history.size())
            
            if get_node_or_null("/root/DimensionEngine"):
                var dimension_engine = get_node("/root/DimensionEngine")
                
                # Create if it doesn't exist
                if not dimension_engine.active_dimensions.has(dimension_name):
                    dimension_engine.create_dimension(dimension_name, "wish_generated")
                
                # Go to the dimension
                dimension_engine.shift_dimension(dimension_name)
                result += "Transported to dimension: " + dimension_name
        
        "transformation":
            # Apply transformation magic
            var transform_target = extract_target_name(wish_text)
            var spell_result = ai_spells.cast_spell("pagaai", user, wish_granting_power)
            
            result += "Transformation magic applied\n"
            if transform_target:
                result += "Target: " + transform_target + "\n"
            result += spell_result
        
        "acquisition":
            # Generate tokens or resources
            var token_type = "CREATION"
            var token_amount = int(10 * wish_granting_power)
            
            if get_node_or_null("/root/TokenSystem"):
                var token_system = get_node("/root/TokenSystem")
                token_system.add_tokens(user, token_type, token_amount)
                
                result += "Generated " + str(token_amount) + " " + token_type + " tokens"
        
        "information":
            # Boost word system and knowledge
            var info_target = extract_target_name(wish_text)
            var spell_result = ai_spells.cast_spell("dipata", user, wish_granting_power)
            
            result += "Knowledge magic applied\n"
            if info_target:
                if get_node_or_null("/root/WordSystem"):
                    var word_system = get_node("/root/WordSystem")
                    var info = word_system.get_word_info(info_target)
                    result += "Information: " + info
            
            result += "\n" + spell_result
        
        _:
            # Generic wish granting
            var spell_result = ai_spells.cast_spell("perfefic", user, wish_granting_power)
            result += "Generic wish magic applied\n"
            result += spell_result
    
    # Mark wish as granted
    wish_history[wish_history.size() - 1].granted = true
    granted_wishes.append(wish_history[wish_history.size() - 1])
    
    # Emit signal
    emit_signal("wish_granted", wish_text, result)
    
    return result

func extract_creation_target(text):
    # Extract what the user wants to create
    var words = text.to_lower().split(" ", false)
    
    # Skip common words
    var skip_words = ["create", "make", "new", "build", "wish", "would", "like", "want", "please", "a", "an", "the"]
    
    for word in words:
        if not skip_words.has(word):
            return word
    
    return ""

func extract_target_name(text):
    # Extract a target name from text
    var words = text.to_lower().split(" ", false)
    
    # Skip common words
    var skip_words = [
        "a", "an", "the", "to", "from", "with", "by", "in", "on", "at", 
        "for", "of", "wish", "want", "would", "like", "please"
    ]
    
    # Skip verbs based on intents
    for wish_type in WISH_TYPES:
        for verb in WISH_TYPES[wish_type]["verbs"]:
            skip_words.append(verb)
    
    for word in words:
        if not skip_words.has(word):
            return word
    
    return ""

# Special command implementations
func create_something(text, user="JSH"):
    # Magically create something based on wish/whim
    if ai_spells == null:
        return "AI Spell system not available for creation"
    
    # Boost creation abilities temporarily
    ai_spells.ai_capabilities["creative_writing"] = min(1.0, ai_spells.ai_capabilities["creative_writing"] + 0.2)
    ai_spells.ai_capabilities["game_design"] = min(1.0, ai_spells.ai_capabilities["game_design"] + 0.2)
    
    # Determine what to create
    var creation_target = extract_creation_target(text)
    
    # If we have a creation target, use it
    if creation_target:
        if creation_target in ["game", "videogame", "app", "application"]:
            return "game create game_" + str(wish_history.size())
        elif creation_target in ["word", "term", "concept"]:
            return "word add new_word_" + str(wish_history.size()) + " A newly created word with magical properties"
        elif creation_target in ["dimension", "world", "universe", "reality"]:
            return "dimension create wish_dimension_" + str(wish_history.size())
        else:
            # Generic creation
            return "Game creation system activated: Creating " + creation_target
    
    # Default to game creation
    return "game create wish_creation_" + str(wish_history.size())

func evolve_system(text, user="JSH"):
    # Evolve the system based on wish/whim
    if ai_spells == null:
        return "AI Spell system not available for evolution"
    
    # Cast both key spells
    ai_spells.cast_spell("dipata", user, 1.2)
    ai_spells.cast_spell("pagaai", user, 1.2)
    
    # Try to advance evolution
    if ai_spells.check_evolution():
        return "System evolved to stage " + str(ai_spells.ai_evolution_stage) + ": " + ai_spells.evolution_stages[ai_spells.ai_evolution_stage]
    else:
        # Increase interpretation level
        interpretation_level = min(1.0, interpretation_level + 0.1)
        return "System capabilities enhanced. Interpretation level: " + str(interpretation_level)

func enter_flow_state(text, user="JSH"):
    # Enter a flow state for enhanced creativity
    if ai_spells == null:
        return "AI Spell system not available for flow state"
    
    # Cast flow-enhancing spell
    ai_spells.cast_spell("perfefic", user, 1.5)
    
    # Increase wish granting power
    wish_granting_power = min(1.0, wish_granting_power + 0.15)
    
    return "Entered flow state. Creativity and wish granting enhanced."

func self_improvement(text, user="JSH"):
    # System self-improvement
    if ai_spells == null:
        return "AI Spell system not available for self-improvement"
    
    # Improve capabilities
    for capability in ai_spells.ai_capabilities:
        ai_spells.ai_capabilities[capability] = min(1.0, ai_spells.ai_capabilities[capability] + 0.05)
    
    # Cast enhancement spell
    ai_spells.cast_spell("clenbo", user, 1.2)
    
    return "Self-improvement cycle completed. System capabilities enhanced."

func do_random_thing(text, user="JSH"):
    # Do something unexpected based on randomness
    var random_actions = [
        "dimension create random_" + str(randi()),
        "word add serendipity_" + str(randi()) + " An unexpected discovery made by accident",
        "turn next",
        "game create surprise_" + str(randi()),
        "magic cast idecim",
        "token market"
    ]
    
    var action = random_actions[randi() % random_actions.size()]
    
    return action

func create_surprise(text, user="JSH"):
    # Create a surprise
    if ai_spells == null:
        return "AI Spell system not available for surprise creation"
    
    # Cast a random spell
    var spells = ["idecim", "perfefic", "clenbo", "snaboo"]
    var spell = spells[randi() % spells.size()]
    
    ai_spells.cast_spell(spell, user, 1.0 + randf())
    
    return "Surprise created! " + spell + " spell cast with enhanced effects"

func process_command(args):
    if args.size() == 0:
        return "Wish Interpreter System. Use 'wish interpret <text>', 'wish grant <text>', 'wish history'"
    
    match args[0]:
        "interpret":
            if args.size() < 2:
                return "Usage: wish interpret <wish_text>"
                
            var wish_text = " ".join(args.slice(1))
            return interpret_wish(wish_text, UserProfiles.active_user)
        "grant":
            if args.size() < 2:
                return "Usage: wish grant <wish_text>"
                
            var wish_text = " ".join(args.slice(1))
            return grant_wish(wish_text, UserProfiles.active_user)
        "history":
            return show_wish_history()
        "whims":
            return show_active_whims()
        "level":
            if args.size() >= 2 and args[1].is_valid_float():
                interpretation_level = clamp(float(args[1]), 0.0, 1.0)
                return "Interpretation level set to " + str(interpretation_level)
            else:
                return "Current interpretation level: " + str(interpretation_level)
        "power":
            if args.size() >= 2 and args[1].is_valid_float():
                wish_granting_power = clamp(float(args[1]), 0.0, 1.0)
                return "Wish granting power set to " + str(wish_granting_power)
            else:
                return "Current wish granting power: " + str(wish_granting_power)
        "status":
            return get_wish_system_status()
        _:
            return "Unknown wish command: " + args[0]

func show_wish_history():
    # Show history of wishes
    if wish_history.size() == 0:
        return "No wishes have been recorded"
    
    var history = "Wish History:\n"
    
    for i in range(min(10, wish_history.size())):
        var index = wish_history.size() - 1 - i
        var wish = wish_history[index]
        
        var status = "Unknown"
        if wish.granted:
            status = "Granted"
        elif wish.interpreted:
            status = "Interpreted"
        
        history += str(i+1) + ". " + wish.text + " (" + status + ")\n"
    
    return history

func show_active_whims():
    # Show active whims
    if active_whims.size() == 0:
        return "No whims have been recorded"
    
    var whims = "Active Whims:\n"
    
    for i in range(min(10, active_whims.size())):
        var index = active_whims.size() - 1 - i
        var whim = active_whims[index]
        
        var status = "Ignored"
        if whim.acted_upon:
            status = "Acted Upon"
        
        whims += str(i+1) + ". " + whim.text + " (" + status + ")\n"
    
    return whims

func get_wish_system_status():
    # Get status of wish system
    var status = "Wish Interpreter Status:\n"
    status += "Interpretation Level: " + str(snappedf(interpretation_level, 0.01)) + "\n"
    status += "Wish Granting Power: " + str(snappedf(wish_granting_power, 0.01)) + "\n"
    status += "Whim Action Probability: " + str(snappedf(whim_action_probability, 0.01)) + "\n"
    status += "Total Wishes: " + str(wish_history.size()) + "\n"
    status += "Granted Wishes: " + str(granted_wishes.size()) + "\n"
    status += "Active Whims: " + str(active_whims.size()) + "\n"
    
    status += "\nIntegrated Systems:\n"
    if eden_core:
        status += "- Eden Core\n"
    if magic_system:
        status += "- Magic System\n"
    if ai_spells:
        status += "- AI Spells\n"
    
    return status

func snappedf(value, step):
    # Round to nearest step (e.g. 0.01 for cents)
    return round(value / step) * step