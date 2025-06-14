extends Node
class_name ResourceManager

# Resource Types
enum ResourceType {
	METALS,
	MINERALS,
	RARE_METALS,
	RADIOACTIVES,
	EXOTIC_MINERALS,
	GASES,
	HELIUM3,
	VOLATILES,
	WATER_ICE,
	METHANE,
	AMMONIA,
	WATER,
	ORGANICS,
	ENERGY,
	ANTIMATTER
}

# Resource display names
var resource_names = {
	ResourceType.METALS: "Metals",
	ResourceType.MINERALS: "Minerals",
	ResourceType.RARE_METALS: "Rare Metals",
	ResourceType.RADIOACTIVES: "Radioactive Materials",
	ResourceType.EXOTIC_MINERALS: "Exotic Minerals",
	ResourceType.GASES: "Gases",
	ResourceType.HELIUM3: "Helium-3",
	ResourceType.VOLATILES: "Volatiles",
	ResourceType.WATER_ICE: "Water Ice",
	ResourceType.METHANE: "Methane",
	ResourceType.AMMONIA: "Ammonia",
	ResourceType.WATER: "Water",
	ResourceType.ORGANICS: "Organic Compounds",
	ResourceType.ENERGY: "Energy",
	ResourceType.ANTIMATTER: "Antimatter"
}

# Resource properties
var resource_properties = {
	ResourceType.METALS: {
		"color": Color(0.7, 0.7, 0.7),
		"base_value": 10.0,
		"mass_per_unit": 1.0,
		"volume_per_unit": 0.5,
		"rarity": 0.8,
		"extraction_difficulty": 0.3,
		"uses": ["construction", "shipbuilding", "industry"]
	},
	ResourceType.MINERALS: {
		"color": Color(0.8, 0.6, 0.4),
		"base_value": 5.0,
		"mass_per_unit": 1.2,
		"volume_per_unit": 0.6,
		"rarity": 0.9,
		"extraction_difficulty": 0.2,
		"uses": ["construction", "industry"]
	},
	ResourceType.RARE_METALS: {
		"color": Color(0.9, 0.8, 0.1),
		"base_value": 40.0,
		"mass_per_unit": 0.8,
		"volume_per_unit": 0.4,
		"rarity": 0.3,
		"extraction_difficulty": 0.5,
		"uses": ["electronics", "research", "shipbuilding"]
	},
	ResourceType.RADIOACTIVES: {
		"color": Color(0.2, 0.8, 0.2),
		"base_value": 60.0,
		"mass_per_unit": 1.5,
		"volume_per_unit": 0.2,
		"rarity": 0.2,
		"extraction_difficulty": 0.7,
		"uses": ["power", "weapons", "research"]
	},
	ResourceType.EXOTIC_MINERALS: {
		"color": Color(0.5, 0.3, 0.8),
		"base_value": 80.0,
		"mass_per_unit": 0.6,
		"volume_per_unit": 0.3,
		"rarity": 0.1,
		"extraction_difficulty": 0.8,
		"uses": ["research", "special_equipment", "advanced_technology"]
	},
	ResourceType.GASES: {
		"color": Color(0.6, 0.9, 0.9),
		"base_value": 8.0,
		"mass_per_unit": 0.1,
		"volume_per_unit": 2.0,
		"rarity": 0.7,
		"extraction_difficulty": 0.4,
		"uses": ["life_support", "industry", "chemistry"]
	},
	ResourceType.HELIUM3: {
		"color": Color(0.9, 0.9, 0.5),
		"base_value": 70.0,
		"mass_per_unit": 0.05,
		"volume_per_unit": 1.0,
		"rarity": 0.2,
		"extraction_difficulty": 0.6,
		"uses": ["fusion_power", "advanced_propulsion"]
	},
	ResourceType.VOLATILES: {
		"color": Color(0.7, 0.8, 0.9),
		"base_value": 15.0,
		"mass_per_unit": 0.2,
		"volume_per_unit": 1.5,
		"rarity": 0.5,
		"extraction_difficulty": 0.4,
		"uses": ["fuel", "chemistry", "life_support"]
	},
	ResourceType.WATER_ICE: {
		"color": Color(0.8, 0.9, 1.0),
		"base_value": 12.0,
		"mass_per_unit": 0.9,
		"volume_per_unit": 1.0,
		"rarity": 0.6,
		"extraction_difficulty": 0.3,
		"uses": ["life_support", "fuel_processing", "cooling"]
	},
	ResourceType.METHANE: {
		"color": Color(0.2, 0.7, 0.6),
		"base_value": 18.0,
		"mass_per_unit": 0.15,
		"volume_per_unit": 1.8,
		"rarity": 0.5,
		"extraction_difficulty": 0.4,
		"uses": ["fuel", "chemistry"]
	},
	ResourceType.AMMONIA: {
		"color": Color(0.7, 0.7, 0.3),
		"base_value": 14.0,
		"mass_per_unit": 0.2,
		"volume_per_unit": 1.6,
		"rarity": 0.4,
		"extraction_difficulty": 0.5,
		"uses": ["fertilizer", "cooling", "chemistry"]
	},
	ResourceType.WATER: {
		"color": Color(0.3, 0.5, 0.9),
		"base_value": 20.0,
		"mass_per_unit": 1.0,
		"volume_per_unit": 1.0,
		"rarity": 0.5,
		"extraction_difficulty": 0.3,
		"uses": ["life_support", "agriculture", "production"]
	},
	ResourceType.ORGANICS: {
		"color": Color(0.3, 0.8, 0.3),
		"base_value": 25.0,
		"mass_per_unit": 0.8,
		"volume_per_unit": 1.1,
		"rarity": 0.4,
		"extraction_difficulty": 0.4,
		"uses": ["agriculture", "medicine", "research"]
	},
	ResourceType.ENERGY: {
		"color": Color(1.0, 0.9, 0.1),
		"base_value": 30.0,
		"mass_per_unit": 0.0,
		"volume_per_unit": 0.0,
		"rarity": 0.3,
		"extraction_difficulty": 0.5,
		"uses": ["power", "shields", "weapons"]
	},
	ResourceType.ANTIMATTER: {
		"color": Color(1.0, 0.2, 0.8),
		"base_value": 200.0,
		"mass_per_unit": 0.01,
		"volume_per_unit": 0.1,
		"rarity": 0.05,
		"extraction_difficulty": 0.9,
		"uses": ["advanced_propulsion", "weapons", "power"]
	}
}

# Player inventory
var player_resources = {}

# Market prices (fluctuate over time)
var market_prices = {}

# Resource deposits mapped by celestial body ID
var resource_deposits = {}

# Global market fluctuation
var market_fluctuation = 1.0
var market_trends = {}

# Singleton instance
static var _instance = null

static func get_instance():
	if _instance == null:
		_instance = ResourceManager.new()
	return _instance

func _init():
	# Initialize player resources
	for resource in ResourceType.keys():
		player_resources[ResourceType[resource]] = 0.0
		
	# Initialize market prices
	update_market_prices()
	
	# Initialize market trends
	for resource in ResourceType.keys():
		market_trends[ResourceType[resource]] = {
			"direction": randf_range(-0.05, 0.05),
			"duration": randi_range(5, 20),
			"timer": 0
		}

# Generate resource deposits for a celestial body
func generate_resource_deposits(body_id: int, body_type: String, planet_type = -1, 
								size: float = 1.0, seed_value: int = 0) -> Dictionary:
	# If we already have generated deposits for this body, return them
	if resource_deposits.has(body_id):
		return resource_deposits[body_id]
		
	var deposits = {}
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value if seed_value != 0 else body_id
	
	match body_type:
		"planet":
			deposits = _generate_planet_deposits(planet_type, size, rng)
		"moon":
			deposits = _generate_moon_deposits(planet_type, size * 0.5, rng)
		"asteroid":
			deposits = _generate_asteroid_deposits(size * 0.3, rng)
		"star":
			deposits = _generate_star_deposits(planet_type, rng)  # planet_type is actually star_type here
		"comet":
			deposits = _generate_comet_deposits(size * 0.2, rng)
			
	# Store the generated deposits
	resource_deposits[body_id] = deposits
	return deposits

# Generate deposits for planets based on planet type
func _generate_planet_deposits(planet_type: int, size: float, rng: RandomNumberGenerator) -> Dictionary:
	var deposits = {}
	var resource_chances = {}
	
	# Define resource probabilities by planet type
	match planet_type:
		0:  # ROCKY
			resource_chances = {
				ResourceType.METALS: 0.8,
				ResourceType.MINERALS: 0.9,
				ResourceType.RARE_METALS: 0.4,
				ResourceType.RADIOACTIVES: 0.3
			}
		1:  # GAS_GIANT
			resource_chances = {
				ResourceType.GASES: 1.0,
				ResourceType.HELIUM3: 0.7,
				ResourceType.VOLATILES: 0.8
			}
		2:  # ICE_GIANT
			resource_chances = {
				ResourceType.WATER_ICE: 0.9,
				ResourceType.METHANE: 0.8,
				ResourceType.AMMONIA: 0.7,
				ResourceType.VOLATILES: 0.6
			}
		3:  # WATER_WORLD
			resource_chances = {
				ResourceType.WATER: 1.0,
				ResourceType.MINERALS: 0.5,
				ResourceType.ORGANICS: 0.7
			}
		4:  # LAVA_WORLD
			resource_chances = {
				ResourceType.METALS: 0.9,
				ResourceType.RARE_METALS: 0.7,
				ResourceType.RADIOACTIVES: 0.5,
				ResourceType.EXOTIC_MINERALS: 0.4
			}
		5:  # TERRESTRIAL
			resource_chances = {
				ResourceType.WATER: 0.9,
				ResourceType.METALS: 0.7,
				ResourceType.MINERALS: 0.8,
				ResourceType.ORGANICS: 0.8,
				ResourceType.GASES: 0.7
			}
		6:  # DESERT
			resource_chances = {
				ResourceType.MINERALS: 0.8,
				ResourceType.METALS: 0.6,
				ResourceType.RADIOACTIVES: 0.2,
				ResourceType.WATER: 0.1
			}
		7:  # BARREN
			resource_chances = {
				ResourceType.MINERALS: 0.7,
				ResourceType.METALS: 0.4,
				ResourceType.WATER_ICE: 0.3
			}
	
	# Add a small chance for exotic resources on any planet
	if rng.randf() < 0.05:  # 5% chance
		resource_chances[ResourceType.EXOTIC_MINERALS] = rng.randf_range(0.1, 0.3)
	
	if rng.randf() < 0.02:  # 2% chance
		resource_chances[ResourceType.ANTIMATTER] = rng.randf_range(0.05, 0.1)
	
	# Generate resource deposits
	for resource_type in resource_chances:
		if rng.randf() < resource_chances[resource_type]:
			# Abundance is based on planet size, rarity, and random factor
			var base_amount = size * 100.0 * rng.randf_range(0.5, 1.5)
			var rarity_modifier = 1.0 - resource_properties[resource_type].rarity
			var amount = base_amount * rarity_modifier
			
			# Add variation (+/- 20%)
			amount *= rng.randf_range(0.8, 1.2)
			
			# Generate deposit sites (1-5 sites based on planet size)
			var site_count = max(1, int(size * rng.randf_range(1, 5)))
			var sites = []
			
			for i in range(site_count):
				var site = {
					"id": i,
					"name": _generate_deposit_name(resource_type, i),
					"amount": amount / site_count,
					"quality": rng.randf_range(0.5, 1.0),
					"extraction_rate": _calculate_extraction_rate(resource_type, rng),
					"position": {
						"latitude": rng.randf_range(-90, 90),
						"longitude": rng.randf_range(-180, 180)
					},
					"discovered": false,
					"depleted": false
				}
				sites.append(site)
			
			deposits[resource_type] = {
				"total_amount": amount,
				"sites": sites
			}
	
	return deposits

# Generate moon deposits (similar to planets but smaller)
func _generate_moon_deposits(planet_type: int, size: float, rng: RandomNumberGenerator) -> Dictionary:
	var deposits = {}
	var resource_chances = {}
	
	# Moons generally have similar but fewer resources than their planets
	# This is a simplified version, could be expanded for more detail
	match planet_type:
		0, 5, 6, 7:  # ROCKY, TERRESTRIAL, DESERT, BARREN moons
			resource_chances = {
				ResourceType.METALS: 0.7,
				ResourceType.MINERALS: 0.8,
				ResourceType.RARE_METALS: 0.3
			}
		3:  # WATER_WORLD moons
			resource_chances = {
				ResourceType.WATER_ICE: 0.8,
				ResourceType.MINERALS: 0.4
			}
		4:  # LAVA_WORLD moons
			resource_chances = {
				ResourceType.METALS: 0.8,
				ResourceType.RARE_METALS: 0.6
			}
		_:  # Default for other moon types
			resource_chances = {
				ResourceType.MINERALS: 0.6,
				ResourceType.WATER_ICE: 0.4
			}
	
	# Generate resource deposits (similar to planets but with reduced amounts)
	for resource_type in resource_chances:
		if rng.randf() < resource_chances[resource_type]:
			var base_amount = size * 50.0 * rng.randf_range(0.5, 1.5)
			var rarity_modifier = 1.0 - resource_properties[resource_type].rarity
			var amount = base_amount * rarity_modifier
			
			# Generate 1-3 deposit sites
			var site_count = rng.randi_range(1, 3)
			var sites = []
			
			for i in range(site_count):
				var site = {
					"id": i,
					"name": _generate_deposit_name(resource_type, i),
					"amount": amount / site_count,
					"quality": rng.randf_range(0.5, 1.0),
					"extraction_rate": _calculate_extraction_rate(resource_type, rng),
					"position": {
						"latitude": rng.randf_range(-90, 90),
						"longitude": rng.randf_range(-180, 180)
					},
					"discovered": false,
					"depleted": false
				}
				sites.append(site)
			
			deposits[resource_type] = {
				"total_amount": amount,
				"sites": sites
			}
	
	return deposits

# Generate asteroid deposits (rich in metals and rare materials)
func _generate_asteroid_deposits(size: float, rng: RandomNumberGenerator) -> Dictionary:
	var deposits = {}
	var resource_chances = {
		ResourceType.METALS: 0.9,
		ResourceType.MINERALS: 0.8,
		ResourceType.RARE_METALS: 0.5,
		ResourceType.WATER_ICE: 0.3,
		ResourceType.RADIOACTIVES: 0.2,
		ResourceType.EXOTIC_MINERALS: 0.1
	}
	
	# Special case: 5% chance for a very rich asteroid
	if rng.randf() < 0.05:
		var lucky_resource = [
			ResourceType.RARE_METALS, 
			ResourceType.RADIOACTIVES, 
			ResourceType.EXOTIC_MINERALS
		][rng.randi() % 3]
		
		resource_chances[lucky_resource] = 1.0  # Guaranteed
		
		# Increase the amount
		var base_amount = size * 200.0 * rng.randf_range(1.5, 3.0)
		var rarity_modifier = 1.0 - resource_properties[lucky_resource].rarity * 0.5  # Less rarity penalty
		var amount = base_amount * rarity_modifier
		
		var site = {
			"id": 0,
			"name": "Rich " + resource_names[lucky_resource] + " Vein",
			"amount": amount,
			"quality": rng.randf_range(0.8, 1.0),  # Higher quality
			"extraction_rate": _calculate_extraction_rate(lucky_resource, rng) * 1.5,  # Faster extraction
			"discovered": false,
			"depleted": false
		}
		
		deposits[lucky_resource] = {
			"total_amount": amount,
			"sites": [site]
		}
	else:
		# Normal asteroid
		for resource_type in resource_chances:
			if rng.randf() < resource_chances[resource_type]:
				var base_amount = size * 30.0 * rng.randf_range(0.5, 1.5)
				var rarity_modifier = 1.0 - resource_properties[resource_type].rarity
				var amount = base_amount * rarity_modifier
				
				var site = {
					"id": 0,
					"name": _generate_deposit_name(resource_type, 0),
					"amount": amount,
					"quality": rng.randf_range(0.5, 1.0),
					"extraction_rate": _calculate_extraction_rate(resource_type, rng),
					"discovered": false,
					"depleted": false
				}
				
				deposits[resource_type] = {
					"total_amount": amount,
					"sites": [site]
				}
	
	return deposits

# Generate star deposits (mostly energy and helium)
func _generate_star_deposits(star_type: int, rng: RandomNumberGenerator) -> Dictionary:
	var deposits = {}
	
	# Stars primarily provide energy and possibly helium-3
	deposits[ResourceType.ENERGY] = {
		"total_amount": 999999.0,  # Effectively unlimited
		"sites": [{
			"id": 0,
			"name": "Stellar Energy",
			"amount": 999999.0,
			"quality": 1.0,
			"extraction_rate": _calculate_star_energy_rate(star_type, rng),
			"discovered": true,  # Stars are obvious energy sources
			"depleted": false,
			"requires_collector": true  # Requires special equipment
		}]
	}
	
	# Some stars may have helium-3 that can be harvested
	if star_type <= 5:  # Hotter stars are better sources
		var quality = rng.randf_range(0.7, 1.0)
		if star_type <= 2:  # O, B, A types
			quality = rng.randf_range(0.9, 1.0)
		
		deposits[ResourceType.HELIUM3] = {
			"total_amount": 99999.0,
			"sites": [{
				"id": 0,
				"name": "Solar Wind Helium-3",
				"amount": 99999.0,
				"quality": quality,
				"extraction_rate": 0.5 + (5 - star_type) * 0.1,  # Hotter stars yield more
				"discovered": false,
				"depleted": false,
				"requires_collector": true
			}]
		}
	
	# Rare chance for exotic particles or antimatter in special star types
	if star_type >= 8:  # WHITE_DWARF, NEUTRON, BLACK_HOLE
		if rng.randf() < 0.3:  # 30% chance
			deposits[ResourceType.ANTIMATTER] = {
				"total_amount": 50.0 * rng.randf_range(1.0, 3.0),
				"sites": [{
					"id": 0,
					"name": "Exotic Matter Phenomenon",
					"amount": 50.0 * rng.randf_range(1.0, 3.0),
					"quality": rng.randf_range(0.8, 1.0),
					"extraction_rate": 0.05,  # Very slow extraction
					"discovered": false,
					"depleted": false,
					"requires_collector": true,
					"requires_research": true  # Requires special research
				}]
			}
	
	return deposits

# Generate comet deposits (ice, volatiles)
func _generate_comet_deposits(size: float, rng: RandomNumberGenerator) -> Dictionary:
	var deposits = {}
	var resource_chances = {
		ResourceType.WATER_ICE: 0.95,
		ResourceType.VOLATILES: 0.8,
		ResourceType.METHANE: 0.6,
		ResourceType.AMMONIA: 0.5,
		ResourceType.ORGANICS: 0.3
	}
	
	for resource_type in resource_chances:
		if rng.randf() < resource_chances[resource_type]:
			var base_amount = size * 20.0 * rng.randf_range(0.5, 1.5)
			var rarity_modifier = 1.0 - resource_properties[resource_type].rarity
			var amount = base_amount * rarity_modifier
			
			var site = {
				"id": 0,
				"name": _generate_deposit_name(resource_type, 0),
				"amount": amount,
				"quality": rng.randf_range(0.5, 1.0),
				"extraction_rate": _calculate_extraction_rate(resource_type, rng),
				"discovered": false,
				"depleted": false
			}
			
			deposits[resource_type] = {
				"total_amount": amount,
				"sites": [site]
			}
	
	return deposits

# Calculate extraction rate based on resource type
func _calculate_extraction_rate(resource_type: int, rng: RandomNumberGenerator) -> float:
	var base_rate = 1.0 - resource_properties[resource_type].extraction_difficulty
	return base_rate * rng.randf_range(0.8, 1.2)

# Calculate star energy collection rate
func _calculate_star_energy_rate(star_type: int, rng: RandomNumberGenerator) -> float:
	var base_rate = 0.0
	
	match star_type:
		0:  # O_TYPE
			base_rate = 5.0
		1:  # B_TYPE
			base_rate = 4.0
		2:  # A_TYPE
			base_rate = 3.0
		3:  # F_TYPE
			base_rate = 2.0
		4:  # G_TYPE
			base_rate = 1.5
		5:  # K_TYPE
			base_rate = 1.0
		6:  # M_TYPE
			base_rate = 0.5
		7:  # RED_GIANT
			base_rate = 3.0
		8:  # WHITE_DWARF
			base_rate = 1.0
		9:  # NEUTRON
			base_rate = 0.5
		10:  # BLACK_HOLE
			base_rate = 0.1
	
	return base_rate * rng.randf_range(0.9, 1.1)

# Generate a name for a resource deposit
func _generate_deposit_name(resource_type: int, index: int) -> String:
	var prefixes = ["Rich", "Large", "Major", "Primary", "Secondary", "Minor", "Small"]
	var suffixes = ["Deposit", "Vein", "Concentration", "Field", "Source", "Reserve", "Pocket"]
	
	var rng = RandomNumberGenerator.new()
	rng.seed = resource_type * 100 + index
	
	var prefix = prefixes[rng.randi() % prefixes.size()]
	var suffix = suffixes[rng.randi() % suffixes.size()]
	
	return prefix + " " + resource_names[resource_type] + " " + suffix

# Update market prices based on trends
func update_market_prices() -> void:
	for resource in ResourceType.keys():
		var res_type = ResourceType[resource]
		var base_value = resource_properties[res_type].base_value
		
		# Update market trend
		var trend = market_trends[res_type]
		trend.timer += 1
		
		if trend.timer >= trend.duration:
			# Change trend
			trend.direction = randf_range(-0.05, 0.05)
			trend.duration = randi_range(5, 20)
			trend.timer = 0
		
		# Calculate current market fluctuation
		var current_fluctuation = 1.0 + trend.direction * trend.timer/trend.duration
		
		# Calculate price with global and resource-specific fluctuations
		market_prices[res_type] = base_value * market_fluctuation * current_fluctuation
		
		# Add random noise (+/- 5%)
		market_prices[res_type] *= randf_range(0.95, 1.05)

# Extract resources from a deposit
func extract_resource(body_id: int, resource_type: int, site_id: int, 
					  extraction_efficiency: float = 1.0, time_delta: float = 1.0) -> float:
	if not resource_deposits.has(body_id):
		return 0.0
	
	var body_deposits = resource_deposits[body_id]
	if not body_deposits.has(resource_type):
		return 0.0
	
	var deposit = body_deposits[resource_type]
	if site_id >= deposit.sites.size():
		return 0.0
	
	var site = deposit.sites[site_id]
	if site.depleted or not site.discovered:
		return 0.0
	
	# Mark as discovered
	site.discovered = true
	
	# Calculate extraction amount
	var base_amount = site.amount * site.extraction_rate * time_delta * 0.01  # 1% per unit time at base rate
	var extracted = base_amount * extraction_efficiency * site.quality
	
	# Ensure we don't extract more than available
	extracted = min(extracted, site.amount)
	
	# Update remaining amount
	site.amount -= extracted
	deposit.total_amount -= extracted
	
	# Check if depleted
	if site.amount <= 0.01:  # Small threshold to avoid floating point issues
		site.depleted = true
		site.amount = 0.0
	
	# Add to player inventory
	add_resource_to_inventory(resource_type, extracted)
	
	return extracted

# Add resource to player inventory
func add_resource_to_inventory(resource_type: int, amount: float) -> void:
	if not player_resources.has(resource_type):
		player_resources[resource_type] = 0.0
	
	player_resources[resource_type] += amount

# Remove resource from player inventory
func remove_resource_from_inventory(resource_type: int, amount: float) -> bool:
	if not player_resources.has(resource_type) or player_resources[resource_type] < amount:
		return false
	
	player_resources[resource_type] -= amount
	return true

# Get current price for a resource
func get_resource_price(resource_type: int) -> float:
	if market_prices.has(resource_type):
		return market_prices[resource_type]
	return 0.0

# Sell resources at market price
func sell_resources(resource_type: int, amount: float) -> float:
	if not player_resources.has(resource_type) or player_resources[resource_type] < amount:
		return 0.0
	
	var price = get_resource_price(resource_type)
	var value = price * amount
	
	# Remove from inventory
	player_resources[resource_type] -= amount
	
	return value

# Buy resources at market price
func buy_resources(resource_type: int, amount: float, credits: float) -> float:
	var price = get_resource_price(resource_type)
	var total_cost = price * amount
	
	if credits < total_cost:
		return 0.0
	
	# Add to inventory
	add_resource_to_inventory(resource_type, amount)
	
	return total_cost

# Get player inventory
func get_player_inventory() -> Dictionary:
	return player_resources

# Scan celestial body for resources (reveals some deposits)
func scan_body_for_resources(body_id: int, scan_strength: float = 1.0) -> Array:
	if not resource_deposits.has(body_id):
		return []
	
	var body_deposits = resource_deposits[body_id]
	var discovered_resources = []
	
	# Chance to discover each resource type based on scan strength
	for resource_type in body_deposits:
		var deposit = body_deposits[resource_type]
		var sites = deposit.sites
		
		for site in sites:
			# More difficult resources require better scanners
			var difficulty = resource_properties[resource_type].extraction_difficulty
			var discovery_chance = scan_strength / (difficulty + 0.5)
			
			if randf() < discovery_chance and not site.discovered:
				site.discovered = true
				discovered_resources.append({
					"resource_type": resource_type,
					"resource_name": resource_names[resource_type],
					"site_name": site.name,
					"amount": site.amount,
					"quality": site.quality
				})
	
	return discovered_resources

# Search for resource deposits in a region of space
func search_for_deposits(region_id: String, scan_strength: float = 1.0) -> Dictionary:
	# This would connect to galaxy or sector data to find hidden resources
	# Simplified implementation for now
	var found_deposits = {}
	
	# Randomly determine if we find anything
	if randf() < scan_strength * 0.5:
		# Determine which type of celestial body we found
		var body_types = ["asteroid", "comet"]
		var body_type = body_types[randi() % body_types.size()]
		
		# Generate a new body ID
		var new_body_id = int(region_id) * 1000 + randi() % 1000
		
		# Create deposits for this body
		var size = randf_range(0.1, 0.5)
		var deposits
		
		if body_type == "asteroid":
			deposits = _generate_asteroid_deposits(size, RandomNumberGenerator.new())
		else:  # comet
			deposits = _generate_comet_deposits(size, RandomNumberGenerator.new())
		
		resource_deposits[new_body_id] = deposits
		
		found_deposits = {
			"body_id": new_body_id,
			"body_type": body_type,
			"size": size,
			"resource_count": deposits.size()
		}
	
	return found_deposits

# Update function called every frame or tick
func update(delta: float) -> void:
	# Update market periodically
	_update_timer += delta
	if _update_timer >= _update_interval:
		update_market_prices()
		_update_timer = 0.0

# Time tracking for updates
var _update_timer: float = 0.0
var _update_interval: float = 60.0  # Update market every 60 seconds

# Serialize player resources
func serialize_player_resources() -> Dictionary:
	var data = {}
	for resource_type in player_resources:
		data[resource_type] = player_resources[resource_type]
	return data

# Deserialize player resources
func deserialize_player_resources(data: Dictionary) -> void:
	player_resources.clear()
	for resource_type_str in data:
		var resource_type = int(resource_type_str)
		player_resources[resource_type] = data[resource_type_str]

# Create crafting recipe requirements
func create_recipe(output_resource: int, output_amount: float, ingredients: Dictionary) -> Dictionary:
	return {
		"output_resource": output_resource,
		"output_amount": output_amount,
		"ingredients": ingredients
	}

# Craft an item using a recipe
func craft_item(recipe: Dictionary) -> bool:
	# Check if we have all ingredients
	for ingredient in recipe.ingredients:
		var required_amount = recipe.ingredients[ingredient]
		if not player_resources.has(ingredient) or player_resources[ingredient] < required_amount:
			return false
	
	# Consume ingredients
	for ingredient in recipe.ingredients:
		player_resources[ingredient] -= recipe.ingredients[ingredient]
	
	# Add crafted item to inventory
	add_resource_to_inventory(recipe.output_resource, recipe.output_amount)
	
	return true