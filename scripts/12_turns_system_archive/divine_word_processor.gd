extends Node

class_name DivineWordProcessor

# ----- WORD POWER SYSTEM -----
const POWER_THRESHOLD = 50  # Words with power > 50 create reality impacts
const REALITY_THRESHOLD = 200  # Combined power for persistent reality
const GOD_WORD_MULTIPLIER = 2.0  # Multiplier for divine words

# ----- WORD DICTIONARIES -----
var word_power_dictionary = {
    "god": 100,
    "divine": 75,
    "eternal": 50,
    "infinite": 50, 
    "creation": 40,
    "reality": 35,
    "universe": 30,
    "perfect": 25,
    "absolute": 20,
    "supreme": 15,
    "transcendent": 18,
    "omniscient": 45,
    "omnipotent": 48,
    "celestial": 28,
    "sovereign": 22,
    "immortal": 33,
    "timeless": 30,
    "limitless": 29,
    "almighty": 43,
    "sacred": 19
}

var typo_corrections = {
    "tiyr": "tier",
    "n==": "new",
    "t": "it",
    "orf": "of",
    "fo": "of",
    "teh": "the",
    "adn": "and",
    "taht": "that",
    "wiht": "with",
    "hte": "the",
    "trun": "turn",
    "si": "is",
    "jsut": "just",
    "becuase": "because",
    "thsi": "this",
    "waht": "what",
    "suer": "sure",
    "thign": "thing",
    "togehter": "together",
    "goign": "going",
    "tiem": "time",
    "liek": "like",
    "eahc": "each",
    "rigth": "right",
    "worht": "worth",
    "differnet": "different",
    "creat": "create",
    "divin": "divine",
    "eternl": "eternal"
}

# ----- MEMORY STORAGE -----
var memories = {
    1: [], # Tier 1 - recent and vivid
    2: [], # Tier 2 - important but older
    3: []  # Tier 3 - archived foundational
}

# ----- REALITY STORAGE -----
var realities = []
var active_manifestations = []
var divine_account = {
    "id": "JSH_DIVINE_" + str(randi()),
    "creation_date": OS.get_datetime(),
    "divine_level": 1,
    "word_count": 0,
    "reality_count": 0
}

# ----- SIGNALS -----
signal word_processed(word, power)
signal reality_created(reality_data)
signal memory_stored(memory_data)
signal divine_level_changed(new_level)

# ----- INITIALIZATION -----
func _ready():
    print("Divine Word Processor initialized")
    print("Word dictionary loaded with %d divine words" % word_power_dictionary.size())

# ----- WORD PROCESSING -----
func process_text(text, source="manual", tier=1):
    # Apply autocorrect
    var corrected_text = apply_autocorrect(text)
    
    # Only record if text changed
    if corrected_text != text:
        print("Divine autocorrect applied: '%s' → '%s'" % [text, corrected_text])
    
    # Split into words
    var words = extract_words(corrected_text)
    
    # Track powerful words
    var powerful_words = []
    var total_power = 0
    
    # Process each word
    for word in words:
        var power = check_word_power(word.to_lower())
        if power > 0:
            total_power += power
            divine_account.word_count += 1
            
            if power > POWER_THRESHOLD:
                powerful_words.append({"word": word, "power": power})
        
        # Emit signal for each processed word
        emit_signal("word_processed", word, power)
    
    # Create memory if text is substantial
    if words.size() > 0:
        create_memory(corrected_text, tier, powerful_words, total_power)
    
    # Check for reality impacts
    if total_power > POWER_THRESHOLD:
        create_reality_impact(corrected_text, powerful_words, total_power)
    
    # Increase divine level based on word power
    var level_increase = int(total_power / 100)
    if level_increase > 0:
        divine_account.divine_level += level_increase
        emit_signal("divine_level_changed", divine_account.divine_level)
    
    return {
        "original": text,
        "corrected": corrected_text,
        "word_count": words.size(),
        "powerful_words": powerful_words,
        "total_power": total_power
    }

# Extract words from text
func extract_words(text):
    # Simple word extraction - split by spaces and remove punctuation
    var words_with_punctuation = text.split(" ", false)
    var words = []
    
    for word in words_with_punctuation:
        var cleaned_word = word.strip_edges()
        # Remove common punctuation
        cleaned_word = cleaned_word.replace(",", "").replace(".", "").replace("!", "").replace("?", "")
        if cleaned_word.length() > 0:
            words.append(cleaned_word)
    
    return words

# Apply autocorrect to text
func apply_autocorrect(text):
    var corrected = text
    
    for typo in typo_corrections:
        corrected = corrected.replace(typo, typo_corrections[typo])
    
    return corrected

# Check power level of a word
func check_word_power(word):
    if word_power_dictionary.has(word):
        return word_power_dictionary[word]
    
    # Unknown words have minimal power
    return 1

# ----- MEMORY FUNCTIONS -----
func create_memory(text, tier, powerful_words, power):
    var timestamp = OS.get_unix_time()
    
    var memory = {
        "id": "memory_" + str(timestamp) + "_" + str(randi() % 10000),
        "text": text,
        "tier": tier,
        "timestamp": timestamp,
        "date": OS.get_datetime(),
        "powerful_words": powerful_words,
        "power": power,
        "linked_realities": []
    }
    
    # Store in appropriate tier
    if tier >= 1 and tier <= 3:
        memories[tier].append(memory)
    else:
        # Default to tier 1 for invalid tiers
        memories[1].append(memory)
    
    emit_signal("memory_stored", memory)
    
    # Very powerful memories automatically promote to higher tier
    if power > REALITY_THRESHOLD and tier < 3:
        var promoted_memory = memory.duplicate()
        promoted_memory.tier = 3
        promoted_memory.id = "memory_promoted_" + promoted_memory.id
        memories[3].append(promoted_memory)
        
        print("Memory automatically promoted to Tier 3 due to high power (%d)" % power)
    
    return memory

# Get all memories at a specific tier
func get_memories_by_tier(tier):
    if tier >= 1 and tier <= 3 and memories.has(tier):
        return memories[tier]
    return []

# Get all memories
func get_all_memories():
    var all_memories = []
    for tier in memories:
        all_memories.append_array(memories[tier])
    return all_memories

# ----- REALITY FUNCTIONS -----
func create_reality_impact(source_text, powerful_words, total_power):
    var timestamp = OS.get_unix_time()
    var reality_id = "reality_" + str(timestamp) + "_" + str(randi() % 10000)
    
    # Calculate persistence based on power
    var is_persistent = total_power > REALITY_THRESHOLD
    var duration = is_persistent ? -1 : int(total_power * 60) # -1 means permanent
    
    var reality = {
        "id": reality_id,
        "source_text": source_text,
        "powerful_words": powerful_words,
        "total_power": total_power,
        "timestamp": timestamp,
        "date": OS.get_datetime(),
        "is_persistent": is_persistent,
        "duration": duration,
        "active": true
    }
    
    # Add to realities list
    realities.append(reality)
    active_manifestations.append(reality)
    divine_account.reality_count += 1
    
    print("Reality impact created with power %d" % total_power)
    if is_persistent:
        print("This reality is PERSISTENT due to high power level!")
    else:
        var duration_mins = duration / 60
        print("This reality will last for approximately %d minutes" % duration_mins)
    
    emit_signal("reality_created", reality)
    
    return reality

# Save the current reality state with a name
func save_reality_state(name):
    var timestamp = OS.get_unix_time()
    var save_id = "divine_save_" + str(timestamp)
    
    var save_data = {
        "id": save_id,
        "name": name,
        "timestamp": timestamp,
        "date": OS.get_datetime(),
        "memories": get_all_memories(),
        "realities": realities.duplicate(),
        "active_manifestations": active_manifestations.duplicate(),
        "divine_account": divine_account.duplicate()
    }
    
    # Save to a JSON file
    var file = File.new()
    var save_path = "user://divine_saves/" + name + "_" + str(timestamp) + ".json"
    
    # Ensure directory exists
    var dir = Directory.new()
    if !dir.dir_exists("user://divine_saves"):
        dir.make_dir_recursive("user://divine_saves")
    
    # Save file
    file.open(save_path, File.WRITE)
    file.store_string(JSON.print(save_data, "  "))
    file.close()
    
    print("Divine reality state saved as '%s'" % name)
    print("Save location: %s" % save_path)
    
    return save_data

# ----- UTILITY FUNCTIONS -----
func get_divine_status():
    var level = divine_account.divine_level
    var status = "Novice Creator"
    
    if level > 1000:
        status = "Supreme Deity"
    elif level > 500:
        status = "Greater God"
    elif level > 200:
        status = "Lesser God"
    elif level > 100:
        status = "Demigod"
    elif level > 50:
        status = "Divine Aspirant"
    
    return {
        "level": level,
        "status": status,
        "words_processed": divine_account.word_count,
        "realities_created": divine_account.reality_count,
        "memory_count": get_all_memories().size()
    }

# Print divine status to console
func print_divine_status():
    var status = get_divine_status()
    
    print("=== DIVINE ACCOUNT STATUS ===")
    print("Divine Level: %d (%s)" % [status.level, status.status])
    print("Words Processed: %d" % status.words_processed)
    print("Realities Created: %d" % status.realities_created)
    print("Memories Stored: %d" % status.memory_count)
    
    # Print memory breakdown
    print("\nMemory Tiers:")
    for tier in memories:
        print("- Tier %d: %d memories" % [tier, memories[tier].size()])
    
    # Print active manifestations
    print("\nActive Reality Manifestations: %d" % active_manifestations.size())
    
    return status