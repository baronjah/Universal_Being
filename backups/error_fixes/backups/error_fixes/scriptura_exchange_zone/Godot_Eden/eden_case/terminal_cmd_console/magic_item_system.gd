extends Node
class_name MagicItemSystem

# MagicItemSystem
# A comprehensive system for creating magical items, spells, and shop interactions
# Designed to integrate with the AI Game Creator and Eden Garden System

signal item_created(item_data)
signal spell_learned(spell_data)
signal shop_transaction(transaction_data)
signal energy_cycle_completed(cycle_data)
signal stability_updated(stability_info)

# Core configuration
const ENERGY_CYCLE_INTERVAL = 12  # Base energy cycle interval in seconds
const MAX_STABILITY = 100.0
const MIN_STABILITY = 0.0
const DEFAULT_ITEM_COST = 50
const RARITY_LEVELS = ["common", "uncommon", "rare", "epic", "legendary", "mythic"]
const ENERGY_TYPES = ["fire", "water", "earth", "air", "light", "shadow", "void", "cosmic"]
const TOOL_CATEGORIES = ["wand", "staff", "orb", "crystal", "tome", "relic", "artifact", "charm"]

# System state
var current_stability = MAX_STABILITY
var energy_pool = {}
var energy_cycle_active = false
var energy_cycle_timer = null
var current_frequency = 1.0  # Multiplier for energy cycle speed
var interaction_counter = 0
var turn_counter = 0
var available_tools = []
var shop_inventory = []
var player_inventory = []
var known_spells = []
var craft_queue = []

# Integrations
var api_manager = null
var game_creator = null

class MagicItem:
    var id = ""
    var name = ""
    var type = ""
    var rarity = "common"
    var cost = DEFAULT_ITEM_COST
    var energy_signature = {}
    var stability_impact = 0.0
    var effects = []
    var description = ""
    var creator = ""
    var creation_timestamp = 0
    var durability = 100.0
    var attunement_required = false
    var compatibility = []
    
    func _init(p_name="", p_type="wand", p_rarity="common"):
        id = str(OS.get_unix_time()) + "_" + str(randi() % 1000)
        name = p_name
        type = p_type
        rarity = p_rarity
        creation_timestamp = OS.get_unix_time()
        
        # Set cost based on rarity
        match rarity:
            "common": cost = 50
            "uncommon": cost = 150
            "rare": cost = 300
            "epic": cost = 750
            "legendary": cost = 2000
            "mythic": cost = 5000
    
    func generate_energy_signature(primary_type="", secondary_type=""):
        energy_signature = {}
        var types = ENERGY_TYPES.duplicate()
        
        # Ensure primary type is included
        if primary_type != "" and primary_type in types:
            energy_signature[primary_type] = 20.0 + randf() * 30.0
            types.erase(primary_type)
        
        # Ensure secondary type is included
        if secondary_type != "" and secondary_type in types:
            energy_signature[secondary_type] = 10.0 + randf() * 20.0
            types.erase(secondary_type)
        
        # Add random energy types
        var num_additional = 1 + randi() % 3  # 1-3 additional energy types
        for i in range(num_additional):
            if types.empty():
                break
                
            var type_index = randi() % types.size()
            var type_name = types[type_index]
            energy_signature[type_name] = 5.0 + randf() * 15.0
            types.erase(type_name)
        
        # Normalize signature to add up to 100
        var total = 0.0
        for type_name in energy_signature:
            total += energy_signature[type_name]
        
        if total > 0:
            for type_name in energy_signature:
                energy_signature[type_name] = (energy_signature[type_name] / total) * 100.0
    
    func generate_effects(num_effects=1):
        var possible_effects = [
            "Amplifies %s energy by %.1f%%",
            "Converts %s energy to %s energy",
            "Stabilizes energy flow by %.1f%%",
            "Enhances spell duration by %.1f%%",
            "Reduces energy cost by %.1f%%",
            "Accelerates casting speed by %.1f%%",
            "Creates %s resonance field",
            "Grants protection against %s energy",
            "Stores up to %.1f energy units",
            "Reveals hidden %s sources"
        ]
        
        effects = []
        for i in range(num_effects):
            var effect_template = possible_effects[randi() % possible_effects.size()]
            var effect = ""
            
            # Fill in the template based on its format
            if "%s" in effect_template:
                if "%.1f" in effect_template:
                    # Template with energy type and numeric value
                    var energy_type = ENERGY_TYPES[randi() % ENERGY_TYPES.size()]
                    var value = 10.0 + randf() * 40.0  # 10-50
                    effect = effect_template % [energy_type, value]
                elif "to %s" in effect_template:
                    # Template with two energy types
                    var energy_type1 = ENERGY_TYPES[randi() % ENERGY_TYPES.size()]
                    var energy_type2 = ENERGY_TYPES[randi() % ENERGY_TYPES.size()]
                    while energy_type2 == energy_type1:
                        energy_type2 = ENERGY_TYPES[randi() % ENERGY_TYPES.size()]
                    effect = effect_template % [energy_type1, energy_type2]
                else:
                    # Template with just energy type
                    var energy_type = ENERGY_TYPES[randi() % ENERGY_TYPES.size()]
                    effect = effect_template % energy_type
            elif "%.1f" in effect_template:
                # Template with just numeric value
                var value = 10.0 + randf() * 40.0  # 10-50
                effect = effect_template % value
            
            effects.append(effect)
    
    func to_dict():
        return {
            "id": id,
            "name": name,
            "type": type,
            "rarity": rarity,
            "cost": cost,
            "energy_signature": energy_signature,
            "stability_impact": stability_impact,
            "effects": effects,
            "description": description,
            "creator": creator,
            "creation_timestamp": creation_timestamp,
            "durability": durability,
            "attunement_required": attunement_required,
            "compatibility": compatibility
        }
    
    func from_dict(data):
        id = data.get("id", "")
        name = data.get("name", "")
        type = data.get("type", "wand")
        rarity = data.get("rarity", "common")
        cost = data.get("cost", DEFAULT_ITEM_COST)
        energy_signature = data.get("energy_signature", {})
        stability_impact = data.get("stability_impact", 0.0)
        effects = data.get("effects", [])
        description = data.get("description", "")
        creator = data.get("creator", "")
        creation_timestamp = data.get("creation_timestamp", 0)
        durability = data.get("durability", 100.0)
        attunement_required = data.get("attunement_required", false)
        compatibility = data.get("compatibility", [])

class Spell:
    var id = ""
    var name = ""
    var energy_cost = {}
    var cast_time = 1.0  # seconds
    var cooldown = 0.0   # seconds
    var effects = []
    var stability_requirement = 0.0
    var tool_requirement = ""
    var description = ""
    var creator = ""
    var creation_timestamp = 0
    var difficulty = 1  # 1-10 scale
    var learned_through = "discovery"  # discovery, teaching, tome
    var compatible_tools = []
    
    func _init(p_name="", p_difficulty=1):
        id = str(OS.get_unix_time()) + "_spell_" + str(randi() % 1000)
        name = p_name
        difficulty = p_difficulty
        creation_timestamp = OS.get_unix_time()
        
        # Set stability requirement based on difficulty
        stability_requirement = difficulty * 10.0
    
    func generate_energy_cost(primary_type="", total_cost=100.0):
        energy_cost = {}
        var types = ENERGY_TYPES.duplicate()
        
        # Ensure primary type is included
        if primary_type != "" and primary_type in types:
            energy_cost[primary_type] = total_cost * (0.5 + randf() * 0.3)  # 50-80% of cost
            types.erase(primary_type)
            
            # Add 1-2 additional energy types for remainder
            var remaining_cost = total_cost - energy_cost[primary_type]
            var num_additional = 1 + randi() % 2
            for i in range(num_additional):
                if types.empty() or remaining_cost <= 0:
                    break
                    
                var type_index = randi() % types.size()
                var type_name = types[type_index]
                
                if i == num_additional - 1:
                    # Last type gets all remaining cost
                    energy_cost[type_name] = remaining_cost
                else:
                    # Split remaining cost
                    var cost_portion = remaining_cost * (0.3 + randf() * 0.4)
                    energy_cost[type_name] = cost_portion
                    remaining_cost -= cost_portion
                
                types.erase(type_name)
        else:
            # No primary type specified, distribute randomly
            var num_types = 2 + randi() % 3  # 2-4 energy types
            var remaining_cost = total_cost
            
            for i in range(num_types):
                if types.empty() or remaining_cost <= 0:
                    break
                    
                var type_index = randi() % types.size()
                var type_name = types[type_index]
                
                if i == num_types - 1:
                    # Last type gets all remaining cost
                    energy_cost[type_name] = remaining_cost
                else:
                    # Split cost
                    var portion = remaining_cost / (num_types - i)
                    var variation = portion * 0.4  # 40% variation
                    var cost_portion = portion - variation + randf() * (variation * 2)
                    energy_cost[type_name] = cost_portion
                    remaining_cost -= cost_portion
                
                types.erase(type_name)
    
    func generate_effects(num_effects=1):
        var possible_effects = [
            "Creates a %s energy burst dealing %.1f damage",
            "Shields target with %s energy for %.1f seconds",
            "Transforms target into a %s creature temporarily",
            "Summons a %s elemental for %.1f minutes",
            "Teleports caster %.1f meters in chosen direction",
            "Enhances target's %s resistance by %.1f%%",
            "Reveals hidden %s energies within %.1f meter radius",
            "Creates a %s portal to connected location",
            "Binds %.1f %s energy to target object",
            "Disperses harmful %s energies in area"
        ]
        
        effects = []
        for i in range(num_effects):
            var effect_template = possible_effects[randi() % possible_effects.size()]
            var effect = ""
            
            # Fill in the template based on its format
            if "%.1f" in effect_template and "%s" in effect_template:
                # Template with energy type and numeric value
                var energy_type = ENERGY_TYPES[randi() % ENERGY_TYPES.size()]
                var value = 0.0
                
                if "damage" in effect_template:
                    value = 10.0 + (difficulty * 5.0) + randf() * 20.0  # 10-100 based on difficulty
                elif "seconds" in effect_template:
                    value = 5.0 + (difficulty * 2.0) + randf() * 10.0  # 5-50 seconds based on difficulty
                elif "minutes" in effect_template:
                    value = 1.0 + (difficulty * 0.5) + randf() * 3.0  # 1-10 minutes based on difficulty
                elif "meters" in effect_template:
                    value = 5.0 + (difficulty * 3.0) + randf() * 20.0  # 5-80 meters based on difficulty
                elif "%" in effect_template:
                    value = 10.0 + (difficulty * 5.0) + randf() * 30.0  # 10-100% based on difficulty
                else:
                    value = 1.0 + (difficulty * 1.0) + randf() * 5.0  # Generic value based on difficulty
                
                if "%.1f %s" in effect_template:
                    effect = effect_template % [value, energy_type]
                else:
                    effect = effect_template % [energy_type, value]
            elif "%s" in effect_template:
                # Template with just energy type
                var energy_type = ENERGY_TYPES[randi() % ENERGY_TYPES.size()]
                effect = effect_template % energy_type
            elif "%.1f" in effect_template:
                # Template with just numeric value
                var value = 5.0 + (difficulty * 3.0) + randf() * 20.0  # Value scaled by difficulty
                effect = effect_template % value
            
            effects.append(effect)
    
    func to_dict():
        return {
            "id": id,
            "name": name,
            "energy_cost": energy_cost,
            "cast_time": cast_time,
            "cooldown": cooldown,
            "effects": effects,
            "stability_requirement": stability_requirement,
            "tool_requirement": tool_requirement,
            "description": description,
            "creator": creator,
            "creation_timestamp": creation_timestamp,
            "difficulty": difficulty,
            "learned_through": learned_through,
            "compatible_tools": compatible_tools
        }
    
    func from_dict(data):
        id = data.get("id", "")
        name = data.get("name", "")
        energy_cost = data.get("energy_cost", {})
        cast_time = data.get("cast_time", 1.0)
        cooldown = data.get("cooldown", 0.0)
        effects = data.get("effects", [])
        stability_requirement = data.get("stability_requirement", 0.0)
        tool_requirement = data.get("tool_requirement", "")
        description = data.get("description", "")
        creator = data.get("creator", "")
        creation_timestamp = data.get("creation_timestamp", 0)
        difficulty = data.get("difficulty", 1)
        learned_through = data.get("learned_through", "discovery")
        compatible_tools = data.get("compatible_tools", [])

class ShopTransaction:
    var id = ""
    var item_id = ""
    var item_name = ""
    var cost = 0
    var transaction_type = "purchase"  # purchase, sell, trade
    var timestamp = 0
    var buyer = ""
    var seller = "shop"
    var discount_applied = 0.0
    var success = true
    var notes = ""
    
    func _init(p_item_id="", p_cost=0, p_type="purchase"):
        id = str(OS.get_unix_time()) + "_trans_" + str(randi() % 1000)
        item_id = p_item_id
        cost = p_cost
        transaction_type = p_type
        timestamp = OS.get_unix_time()
    
    func to_dict():
        return {
            "id": id,
            "item_id": item_id,
            "item_name": item_name,
            "cost": cost,
            "transaction_type": transaction_type,
            "timestamp": timestamp,
            "buyer": buyer,
            "seller": seller,
            "discount_applied": discount_applied,
            "success": success,
            "notes": notes
        }

func _ready():
    # Initialize energy cycle timer
    energy_cycle_timer = Timer.new()
    energy_cycle_timer.one_shot = false
    energy_cycle_timer.wait_time = ENERGY_CYCLE_INTERVAL
    energy_cycle_timer.connect("timeout", self, "_on_energy_cycle_timeout")
    add_child(energy_cycle_timer)
    
    # Initialize energy pool with zero values for all types
    for type in ENERGY_TYPES:
        energy_pool[type] = 0.0
    
    # Load previous system state
    load_system_state()
    
    # Generate initial shop inventory
    if shop_inventory.empty():
        generate_shop_inventory(5)
    
    # Set up initial available tools
    if available_tools.empty():
        generate_available_tools()
    
    print("Magic Item System initialized with stability: %.1f%%" % current_stability)

# Energy and Stability Management

func start_energy_cycle(frequency=1.0):
    current_frequency = clamp(frequency, 0.1, 5.0)
    energy_cycle_timer.wait_time = ENERGY_CYCLE_INTERVAL / current_frequency
    energy_cycle_timer.start()
    energy_cycle_active = true
    print("Energy cycle started with frequency multiplier: %.1f" % current_frequency)
    return true

func stop_energy_cycle():
    energy_cycle_timer.stop()
    energy_cycle_active = false
    print("Energy cycle stopped")
    return true

func set_cycle_frequency(frequency):
    if frequency <= 0:
        print("Invalid frequency value")
        return false
    
    current_frequency = clamp(frequency, 0.1, 5.0)
    if energy_cycle_active:
        energy_cycle_timer.wait_time = ENERGY_CYCLE_INTERVAL / current_frequency
    
    print("Energy cycle frequency set to: %.1f" % current_frequency)
    return true

func process_energy_cycle():
    if not energy_cycle_active:
        return false
    
    # Generate random energy fluctuations
    var cycle_data = {
        "energy_changes": {},
        "stability_impact": 0.0,
        "turn": turn_counter
    }
    
    # Update turn counter
    turn_counter += 1
    
    # Process energy fluctuations
    for type in energy_pool:
        var base_change = randf() * 5.0 - 1.0  # -1 to +4 range
        var frequency_factor = sqrt(current_frequency)
        var change = base_change * frequency_factor
        
        energy_pool[type] += change
        energy_pool[type] = clamp(energy_pool[type], 0.0, 100.0)
        
        cycle_data.energy_changes[type] = change
    
    # Calculate stability impact
    var stability_impact = (randf() * 2.0 - 1.0) * current_frequency
    
    # Higher frequencies decrease stability more
    if current_frequency > 1.5:
        stability_impact -= (current_frequency - 1.5) * 0.5
    
    # Apply stability change
    update_stability(stability_impact)
    cycle_data.stability_impact = stability_impact
    
    emit_signal("energy_cycle_completed", cycle_data)
    return true

func update_stability(change):
    var old_stability = current_stability
    current_stability += change
    current_stability = clamp(current_stability, MIN_STABILITY, MAX_STABILITY)
    
    var stability_info = {
        "previous": old_stability,
        "current": current_stability,
        "change": change,
        "threshold_crossed": false,
        "is_critical": current_stability < 30.0,
        "is_optimal": current_stability > 70.0
    }
    
    # Check if a stability threshold was crossed
    var thresholds = [25.0, 50.0, 75.0]
    for threshold in thresholds:
        if (old_stability < threshold and current_stability >= threshold) or \
           (old_stability >= threshold and current_stability < threshold):
            stability_info.threshold_crossed = true
            stability_info.threshold = threshold
            break
    
    emit_signal("stability_updated", stability_info)
    return stability_info

# Item Creation and Management

func create_magic_item(name, type="wand", rarity="common", creator="system"):
    # Check if item creation would affect stability
    var creation_stability_cost = 0.0
    match rarity:
        "common": creation_stability_cost = 1.0
        "uncommon": creation_stability_cost = 2.0
        "rare": creation_stability_cost = 5.0
        "epic": creation_stability_cost = 10.0
        "legendary": creation_stability_cost = 20.0
        "mythic": creation_stability_cost = 30.0
    
    # Verify we have enough stability
    if current_stability < creation_stability_cost:
        print("Not enough stability to create item. Need %.1f, have %.1f" % [creation_stability_cost, current_stability])
        return null
    
    # Create the item
    var item = MagicItem.new(name, type, rarity)
    item.creator = creator
    
    # Generate energy signature and effects
    var num_effects = 1
    match rarity:
        "uncommon": num_effects = 2
        "rare": num_effects = 3
        "epic": num_effects = 4
        "legendary": num_effects = 5
        "mythic": num_effects = 6
    
    # Find dominant energy type in the pool
    var max_energy_type = ENERGY_TYPES[0]
    var max_energy_value = energy_pool[max_energy_type]
    var second_energy_type = ENERGY_TYPES[1]
    var second_energy_value = energy_pool[second_energy_type]
    
    for type in energy_pool:
        if energy_pool[type] > max_energy_value:
            second_energy_type = max_energy_type
            second_energy_value = max_energy_value
            max_energy_type = type
            max_energy_value = energy_pool[type]
        elif energy_pool[type] > second_energy_value:
            second_energy_type = type
            second_energy_value = energy_pool[type]
    
    # Generate energy signature influenced by the current energy pool
    item.generate_energy_signature(max_energy_type, second_energy_type)
    item.generate_effects(num_effects)
    
    # Set stability impact based on rarity and energy signature
    item.stability_impact = creation_stability_cost * 0.1  # 10% of creation cost as ongoing impact
    
    # Generate description
    item.description = "A %s %s infused with %s energy" % [rarity, type, max_energy_type]
    if second_energy_type != max_energy_type:
        item.description += " and %s energy" % second_energy_type
    item.description += ". " + item.effects[0] if item.effects.size() > 0 else ""
    
    # Determine tool compatibility
    for i in range(1 + randi() % 3):  # 1-3 compatible tools
        var tool_type = TOOL_CATEGORIES[randi() % TOOL_CATEGORIES.size()]
        if not tool_type in item.compatibility:
            item.compatibility.append(tool_type)
    
    # Apply stability cost
    update_stability(-creation_stability_cost)
    
    # Increment interaction counter
    interaction_counter += 1
    
    # Add to shop inventory if created by the system
    if creator == "system":
        shop_inventory.append(item.to_dict())
    
    print("Created new %s %s: %s" % [rarity, type, name])
    emit_signal("item_created", item.to_dict())
    
    return item

func generate_shop_inventory(count=5):
    # Clear existing inventory
    shop_inventory = []
    
    # Generate common items
    for i in range(count):
        var rarity_roll = randf() * 100.0
        var rarity = "common"
        
        if rarity_roll > 98:
            rarity = "mythic"
        elif rarity_roll > 90:
            rarity = "legendary"
        elif rarity_roll > 80:
            rarity = "epic"
        elif rarity_roll > 60:
            rarity = "rare"
        elif rarity_roll > 30:
            rarity = "uncommon"
        
        var type = TOOL_CATEGORIES[randi() % TOOL_CATEGORIES.size()]
        var name = "Shop %s %s" % [rarity.capitalize(), type.capitalize()]
        
        var item = create_magic_item(name, type, rarity, "shop")
        if item:
            shop_inventory.append(item.to_dict())
    
    print("Generated shop inventory with %d items" % shop_inventory.size())
    return shop_inventory

func purchase_item(item_id, buyer="player"):
    # Find the item in shop inventory
    var item_data = null
    var item_index = -1
    
    for i in range(shop_inventory.size()):
        if shop_inventory[i].id == item_id:
            item_data = shop_inventory[i]
            item_index = i
            break
    
    if item_data == null:
        print("Item not found in shop inventory: %s" % item_id)
        return null
    
    # Create transaction record
    var transaction = ShopTransaction.new(item_id, item_data.cost, "purchase")
    transaction.item_name = item_data.name
    transaction.buyer = buyer
    
    # TODO: In a real game, check if player has enough currency
    # For this example, we'll assume they do
    var success = true
    
    if success:
        # Remove from shop inventory
        shop_inventory.remove(item_index)
        
        # Add to player inventory
        player_inventory.append(item_data)
        
        # Finalize transaction
        transaction.success = true
        transaction.notes = "Successfully purchased %s for %d" % [item_data.name, item_data.cost]
        print(transaction.notes)
    else:
        transaction.success = false
        transaction.notes = "Failed to purchase %s, insufficient funds" % item_data.name
        print(transaction.notes)
    
    emit_signal("shop_transaction", transaction.to_dict())
    return transaction

func sell_item(item_id, seller="player"):
    # Find the item in player inventory
    var item_data = null
    var item_index = -1
    
    for i in range(player_inventory.size()):
        if player_inventory[i].id == item_id:
            item_data = player_inventory[i]
            item_index = i
            break
    
    if item_data == null:
        print("Item not found in player inventory: %s" % item_id)
        return null
    
    # Create transaction record
    var sell_price = item_data.cost * 0.5  # 50% of original cost
    var transaction = ShopTransaction.new(item_id, sell_price, "sell")
    transaction.item_name = item_data.name
    transaction.seller = seller
    transaction.buyer = "shop"
    
    # Remove from player inventory
    player_inventory.remove(item_index)
    
    # Add back to shop inventory at full price
    shop_inventory.append(item_data)
    
    # Finalize transaction
    transaction.success = true
    transaction.notes = "Successfully sold %s for %d" % [item_data.name, sell_price]
    print(transaction.notes)
    
    emit_signal("shop_transaction", transaction.to_dict())
    return transaction

func generate_available_tools():
    available_tools = []
    
    # Add basic tools for all categories
    for category in TOOL_CATEGORIES:
        var tool_data = {
            "id": "basic_" + category,
            "name": "Basic " + category.capitalize(),
            "type": category,
            "creation_cost": 100,
            "energy_types": [ENERGY_TYPES[randi() % ENERGY_TYPES.size()]],
            "description": "A basic " + category + " for creating magic items."
        }
        available_tools.append(tool_data)
    
    # Add a few advanced tools
    var advanced_categories = TOOL_CATEGORIES.duplicate()
    for i in range(3):
        if advanced_categories.empty():
            break
            
        var idx = randi() % advanced_categories.size()
        var category = advanced_categories[idx]
        advanced_categories.remove(idx)
        
        var energy_types = []
        for j in range(2):
            energy_types.append(ENERGY_TYPES[randi() % ENERGY_TYPES.size()])
        
        var tool_data = {
            "id": "advanced_" + category,
            "name": "Advanced " + category.capitalize(),
            "type": category,
            "creation_cost": 250,
            "energy_types": energy_types,
            "description": "An advanced " + category + " for creating higher quality magic items."
        }
        available_tools.append(tool_data)
    
    print("Generated %d available tools" % available_tools.size())
    return available_tools

# Spell Creation and Management

func create_spell(name, primary_energy_type="", difficulty=1, creator="system"):
    # Check if spell creation would affect stability
    var creation_stability_cost = difficulty * 2.0
    
    # Verify we have enough stability
    if current_stability < creation_stability_cost:
        print("Not enough stability to create spell. Need %.1f, have %.1f" % [creation_stability_cost, current_stability])
        return null
    
    # Create the spell
    var spell = Spell.new(name, difficulty)
    spell.creator = creator
    
    # If primary energy type not specified, use dominant energy in pool
    if primary_energy_type == "":
        var max_energy = 0.0
        for type in energy_pool:
            if energy_pool[type] > max_energy:
                max_energy = energy_pool[type]
                primary_energy_type = type
    
    # Generate energy cost
    var total_energy_cost = 50.0 + (difficulty * 25.0)  # 50-300 based on difficulty
    spell.generate_energy_cost(primary_energy_type, total_energy_cost)
    
    # Set cast time and cooldown based on difficulty
    spell.cast_time = 0.5 + (difficulty * 0.5)  # 0.5-5.5 seconds
    spell.cooldown = difficulty * 2.0  # 2-20 seconds
    
    # Generate effects
    var num_effects = 1 + (difficulty / 3)  # 1-4 effects based on difficulty
    spell.generate_effects(num_effects)
    
    # Set compatible tools
    var num_compatible = 1 + randi() % 3  # 1-3 compatible tools
    var available_categories = TOOL_CATEGORIES.duplicate()
    for i in range(num_compatible):
        if available_categories.empty():
            break
            
        var idx = randi() % available_categories.size()
        var category = available_categories[idx]
        available_categories.remove(idx)
        
        spell.compatible_tools.append(category)
    
    # Require a tool for high difficulty spells
    if difficulty > 5:
        spell.tool_requirement = spell.compatible_tools[0]
    
    # Generate description
    spell.description = "A level %d %s spell" % [difficulty, primary_energy_type]
    if spell.effects.size() > 0:
        spell.description += " that " + spell.effects[0].lower()
    if spell.tool_requirement != "":
        spell.description += ". Requires a %s to cast" % spell.tool_requirement
    
    # Apply stability cost
    update_stability(-creation_stability_cost)
    
    # Add to known spells
    known_spells.append(spell.to_dict())
    
    # Increment interaction counter
    interaction_counter += 1
    
    print("Created new level %d spell: %s" % [difficulty, name])
    emit_signal("spell_learned", spell.to_dict())
    
    return spell

func cast_spell(spell_id):
    # Find the spell in known spells
    var spell_data = null
    
    for i in range(known_spells.size()):
        if known_spells[i].id == spell_id:
            spell_data = known_spells[i]
            break
    
    if spell_data == null:
        print("Spell not found: %s" % spell_id)
        return false
    
    # Check stability requirement
    if current_stability < spell_data.stability_requirement:
        print("Not enough stability to cast spell. Need %.1f, have %.1f" % 
              [spell_data.stability_requirement, current_stability])
        return false
    
    # Check tool requirement if any
    if spell_data.tool_requirement != "":
        var has_required_tool = false
        for item in player_inventory:
            if item.type == spell_data.tool_requirement:
                has_required_tool = true
                break
        
        if not has_required_tool:
            print("Missing required tool: %s" % spell_data.tool_requirement)
            return false
    
    # Check energy cost
    for energy_type in spell_data.energy_cost:
        if energy_pool.has(energy_type) and energy_pool[energy_type] < spell_data.energy_cost[energy_type]:
            print("Not enough %s energy. Need %.1f, have %.1f" % 
                  [energy_type, spell_data.energy_cost[energy_type], energy_pool[energy_type]])
            return false
    
    # Consume energy
    for energy_type in spell_data.energy_cost:
        if energy_pool.has(energy_type):
            energy_pool[energy_type] -= spell_data.energy_cost[energy_type]
    
    # Apply stability impact
    var stability_impact = -spell_data.difficulty * 0.5
    update_stability(stability_impact)
    
    # Increment interaction counter
    interaction_counter += 1
    
    print("Successfully cast spell: %s" % spell_data.name)
    return true

# API Integration

func initialize_with_api_manager(api_manager_node):
    if not api_manager_node:
        print("Cannot initialize: Invalid API manager")
        return false
    
    api_manager = api_manager_node
    
    # Set up API commands for magic item system
    if api_manager.has_method("make_request"):
        print("API manager connected, ready for magic system communications")
        return true
    
    print("API manager does not have required methods")
    return false

func connect_to_game_creator(game_creator_node):
    if not game_creator_node:
        print("Cannot connect: Invalid Game Creator node")
        return false
    
    game_creator = game_creator_node
    
    # Connect signals if needed
    print("Connected to AI Game Creator")
    return true

# Turn System Integration

func process_turn(turn_number):
    # Update turn counter
    turn_counter = turn_number
    
    # Process energy cycle
    process_energy_cycle()
    
    # Process craft queue
    process_craft_queue()
    
    # Chance for random shop inventory update
    if randi() % 10 == 0:  # 10% chance each turn
        generate_shop_inventory(3 + randi() % 3)  # 3-5 items
    
    print("Processed turn %d" % turn_number)
    return true

func process_craft_queue():
    if craft_queue.empty():
        return false
    
    var items_to_remove = []
    var crafted_items = []
    
    for craft_item in craft_queue:
        craft_item.progress += 1
        
        if craft_item.progress >= craft_item.required_turns:
            # Craft is complete
            var item = create_magic_item(
                craft_item.name,
                craft_item.type,
                craft_item.rarity,
                craft_item.creator
            )
            
            if item:
                crafted_items.append(item.to_dict())
                items_to_remove.append(craft_item)
    
    # Remove completed crafts
    for item in items_to_remove:
        craft_queue.erase(item)
    
    if crafted_items.size() > 0:
        print("Crafted %d items from queue" % crafted_items.size())
    
    return crafted_items.size() > 0

func add_to_craft_queue(name, type, rarity, creator="player"):
    var required_turns = 1
    match rarity:
        "common": required_turns = 1
        "uncommon": required_turns = 2
        "rare": required_turns = 3
        "epic": required_turns = 5
        "legendary": required_turns = 10
        "mythic": required_turns = 20
    
    var craft_item = {
        "id": str(OS.get_unix_time()) + "_craft_" + str(randi() % 1000),
        "name": name,
        "type": type,
        "rarity": rarity,
        "creator": creator,
        "progress": 0,
        "required_turns": required_turns,
        "timestamp": OS.get_unix_time()
    }
    
    craft_queue.append(craft_item)
    print("Added %s %s to craft queue (%d turns required)" % [rarity, type, required_turns])
    return craft_item

# Data Persistence

func save_system_state():
    var file = File.new()
    var data = {
        "current_stability": current_stability,
        "energy_pool": energy_pool,
        "current_frequency": current_frequency,
        "interaction_counter": interaction_counter,
        "turn_counter": turn_counter,
        "available_tools": available_tools,
        "shop_inventory": shop_inventory,
        "player_inventory": player_inventory,
        "known_spells": known_spells,
        "craft_queue": craft_queue,
        "timestamp": OS.get_unix_time()
    }
    
    var error = file.open("user://magic_item_system_data.json", File.WRITE)
    if error != OK:
        print("Error saving system state: %s" % error)
        return false
    
    file.store_string(JSON.print(data, "  "))
    file.close()
    print("Magic Item System state saved")
    return true

func load_system_state():
    var file = File.new()
    if not file.file_exists("user://magic_item_system_data.json"):
        print("No previous system state found")
        return false
    
    var error = file.open("user://magic_item_system_data.json", File.READ)
    if error != OK:
        print("Error loading system state: %s" % error)
        return false
    
    var json_string = file.get_as_text()
    file.close()
    
    var json_result = JSON.parse(json_string)
    if json_result.error != OK:
        print("Error parsing system state: %s at line %s" % [json_result.error, json_result.error_line])
        return false
    
    var data = json_result.result
    
    # Load data
    current_stability = data.get("current_stability", MAX_STABILITY)
    energy_pool = data.get("energy_pool", {})
    current_frequency = data.get("current_frequency", 1.0)
    interaction_counter = data.get("interaction_counter", 0)
    turn_counter = data.get("turn_counter", 0)
    available_tools = data.get("available_tools", [])
    shop_inventory = data.get("shop_inventory", [])
    player_inventory = data.get("player_inventory", [])
    known_spells = data.get("known_spells", [])
    craft_queue = data.get("craft_queue", [])
    
    print("Magic Item System state loaded")
    return true

# Signal Handlers

func _on_energy_cycle_timeout():
    process_energy_cycle()

# Helper Methods

func get_system_stats():
    return {
        "stability": current_stability,
        "energy_pool": energy_pool,
        "frequency": current_frequency,
        "interactions": interaction_counter,
        "turn": turn_counter,
        "shop_items": shop_inventory.size(),
        "player_items": player_inventory.size(),
        "known_spells": known_spells.size(),
        "crafting_queue": craft_queue.size()
    }

# Demo Functions

func run_demo_cycle():
    # Start energy cycle if not already running
    if not energy_cycle_active:
        start_energy_cycle(1.0)
    
    # Create a demo item
    var item = create_magic_item("Demo Wand", "wand", "rare", "demo")
    
    # Create a demo spell
    var spell = create_spell("Demo Fireball", "fire", 3, "demo")
    
    # Process a turn
    process_turn(turn_counter + 1)
    
    # Update shop
    generate_shop_inventory(3)
    
    # Add craft to queue
    add_to_craft_queue("Crafted Staff", "staff", "uncommon", "demo")
    
    print("Demo cycle complete. System stats:")
    print(get_system_stats())
    return true