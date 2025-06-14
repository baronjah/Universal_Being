extends Node

class_name NumericTokenSystem

signal token_energy_changed(token_id, new_energy, source)
signal token_resonance_detected(token_id_1, token_id_2, resonance_value)
signal token_manifestation(token_id, power, dimension)
signal token_cluster_formed(cluster_id, tokens)

# Token configuration
const TOKEN_TYPES = {
    "BASE": {
        "color": Color(1.0, 0.3, 0.3),  # Red
        "dimension": 1,
        "base_energy": 10.0,
        "transfer_efficiency": 0.9,
        "manifestation_threshold": 80.0
    },
    "TIME": {
        "color": Color(0.3, 1.0, 0.3),  # Green
        "dimension": 2,
        "base_energy": 12.0,
        "transfer_efficiency": 0.95,
        "manifestation_threshold": 85.0
    },
    "SPACE": {
        "color": Color(0.3, 0.3, 1.0),  # Blue
        "dimension": 3,
        "base_energy": 15.0,
        "transfer_efficiency": 0.92,
        "manifestation_threshold": 90.0
    },
    "ENERGY": {
        "color": Color(1.0, 1.0, 0.3),  # Yellow
        "dimension": 4,
        "base_energy": 18.0,
        "transfer_efficiency": 0.97,
        "manifestation_threshold": 95.0
    },
    "INFO": {
        "color": Color(1.0, 0.3, 1.0),  # Magenta
        "dimension": 5,
        "base_energy": 20.0,
        "transfer_efficiency": 0.99,
        "manifestation_threshold": 100.0
    },
    "CONSCIOUSNESS": {
        "color": Color(0.3, 1.0, 1.0),  # Cyan
        "dimension": 6,
        "base_energy": 25.0,
        "transfer_efficiency": 0.96,
        "manifestation_threshold": 110.0
    },
    "CONNECTION": {
        "color": Color(1.0, 0.6, 0.0),  # Orange
        "dimension": 7,
        "base_energy": 22.0,
        "transfer_efficiency": 0.94,
        "manifestation_threshold": 105.0
    },
    "POTENTIAL": {
        "color": Color(0.6, 0.0, 1.0),  # Purple
        "dimension": 8,
        "base_energy": 30.0,
        "transfer_efficiency": 0.91,
        "manifestation_threshold": 120.0
    },
    "INTEGRATION": {
        "color": Color(0.0, 0.6, 0.3),  # Teal
        "dimension": 9,
        "base_energy": 35.0,
        "transfer_efficiency": 0.93,
        "manifestation_threshold": 130.0
    }
}

# Prime numbers used for token creation and resonance
const PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

# Numeric patterns and their meanings
const PATTERN_MEANINGS = {
    "111": "unity",
    "123": "progression",
    "222": "balance",
    "333": "expansion",
    "369": "harmonic",
    "404": "missing",
    "444": "stability",
    "555": "change",
    "666": "creation",
    "777": "insight",
    "888": "abundance",
    "999": "completion",
    "1234": "sequence",
    "1010": "binary",
    "1111": "alignment",
    "1212": "cycles",
    "1221": "reflection",
    "1313": "oscillation",
    "1414": "transformation",
    "1515": "evolution",
    "1616": "structure",
    "1717": "insight",
    "1818": "material",
    "1919": "completion",
    "2020": "clarity",
    "2121": "mastery",
    "2222": "foundation",
    "2323": "expression",
    "2424": "harmony",
    "2525": "intuition",
    "2626": "balance",
    "2727": "instructor",
    "2828": "polarity",
    "2929": "cooperation",
    "3030": "connection",
    "3131": "understanding",
    "3232": "communication",
    "3333": "guidance",
    "3434": "creativity",
    "3535": "expression",
    "4444": "foundation",
    "5555": "transition",
    "6666": "harmony",
    "7777": "spiritual",
    "8888": "abundance",
    "9999": "completion",
    "12345": "progression",
    "10101": "digital",
    "11111": "unity"
}

# Active tokens in the system
var active_tokens = {}

# Token clustering and resonance data
var token_clusters = {}
var token_resonances = {}

# References to tunnel system
var tunnel_controller
var ethereal_tunnel_manager
var word_pattern_visualizer

# Fibonacci sequence for scaling
var fibonacci_cache = {0: 0, 1: 1}

# Token processing timers
var process_time = 0.0
var last_token_cleanup = 0.0
var last_resonance_check = 0.0
var last_cluster_check = 0.0

# System configuration
var config = {
    "max_tokens": 100,
    "token_decay_rate": 0.05,
    "resonance_check_interval": 1.0,
    "cluster_check_interval": 2.0,
    "cleanup_interval": 5.0,
    "min_resonance_threshold": 0.3,
    "min_cluster_size": 3,
    "max_cluster_size": 9,
    "enable_fibonacci_scaling": true,
    "enable_prime_resonance": true,
    "enable_pattern_meanings": true,
    "synchronize_with_word_patterns": true
}

func _ready():
    # Auto-detect components
    _detect_components()
    
    # Initialize Fibonacci sequence up to 20
    _precompute_fibonacci(20)

func _process(delta):
    process_time += delta
    
    # Check for token cleanup
    if process_time - last_token_cleanup >= config.cleanup_interval:
        _cleanup_expired_tokens()
        last_token_cleanup = process_time
    
    # Check for resonances
    if process_time - last_resonance_check >= config.resonance_check_interval:
        _check_token_resonances()
        last_resonance_check = process_time
    
    # Check for clusters
    if process_time - last_cluster_check >= config.cluster_check_interval:
        _check_token_clusters()
        last_cluster_check = process_time
    
    # Update token energies
    _update_token_energies(delta)

func _detect_components():
    # Find tunnel controller
    if not tunnel_controller:
        var potential_controllers = get_tree().get_nodes_in_group("tunnel_controllers")
        if potential_controllers.size() > 0:
            tunnel_controller = potential_controllers[0]
            print("Found tunnel controller: " + tunnel_controller.name)
            
            # Get tunnel manager reference
            ethereal_tunnel_manager = tunnel_controller.ethereal_tunnel_manager
    
    # Find word pattern visualizer
    if not word_pattern_visualizer:
        var potential_visualizers = get_tree().get_nodes_in_group("word_pattern_visualizers")
        if potential_visualizers.size() > 0:
            word_pattern_visualizer = potential_visualizers[0]
            print("Found word pattern visualizer: " + word_pattern_visualizer.name)

func create_token(value, type = "BASE", source = "system"):
    # Validate value
    if not _is_valid_token_value(value):
        print("Invalid token value: ", value)
        return null
    
    # Generate token ID
    var token_id = _generate_token_id(value, type)
    
    # Check if token already exists
    if active_tokens.has(token_id):
        # Update existing token
        var existing_token = active_tokens[token_id]
        existing_token.energy += TOKEN_TYPES[type].base_energy
        existing_token.last_update = process_time
        
        emit_signal("token_energy_changed", token_id, existing_token.energy, source)
        return token_id
    
    # Check if we're at token limit
    if active_tokens.size() >= config.max_tokens:
        # Remove oldest token
        var oldest_token_id = null
        var oldest_time = INF
        
        for tid in active_tokens:
            if active_tokens[tid].last_update < oldest_time:
                oldest_time = active_tokens[tid].last_update
                oldest_token_id = tid
        
        if oldest_token_id:
            remove_token(oldest_token_id)
    
    # Process numeric patterns
    var patterns = _extract_numeric_patterns(str(value))
    var pattern_boost = 0.0
    var pattern_meanings = []
    
    if config.enable_pattern_meanings:
        for pattern in patterns:
            if PATTERN_MEANINGS.has(pattern):
                pattern_meanings.push_back(PATTERN_MEANINGS[pattern])
                pattern_boost += 5.0 * pattern.length()
    
    # Calculate prime factors
    var prime_factors = _get_prime_factors(value) if config.enable_prime_resonance else []
    
    # Apply Fibonacci scaling if enabled
    var scaled_energy = TOKEN_TYPES[type].base_energy
    if config.enable_fibonacci_scaling:
        var fib_position = _is_fibonacci(value)
        if fib_position > 0:
            scaled_energy *= (1.0 + (fib_position * 0.1))
    
    # Create new token
    var token = {
        "id": token_id,
        "value": value,
        "type": type,
        "dimension": TOKEN_TYPES[type].dimension,
        "energy": scaled_energy + pattern_boost,
        "creation_time": process_time,
        "last_update": process_time,
        "source": source,
        "patterns": patterns,
        "pattern_meanings": pattern_meanings,
        "prime_factors": prime_factors,
        "clusters": []
    }
    
    # Add to active tokens
    active_tokens[token_id] = token
    
    # If word pattern visualizer is available, create corresponding word pattern
    if word_pattern_visualizer and config.synchronize_with_word_patterns:
        var pattern_text = _token_to_word_pattern(token)
        word_pattern_visualizer.add_word_pattern(pattern_text, token.energy, token.dimension)
    
    # Emit signal
    emit_signal("token_energy_changed", token_id, token.energy, source)
    
    return token_id

func remove_token(token_id):
    if not active_tokens.has(token_id):
        return false
    
    # Get token before removing
    var token = active_tokens[token_id]
    
    # Remove from clusters
    for cluster_id in token.clusters:
        if token_clusters.has(cluster_id):
            token_clusters[cluster_id].tokens.erase(token_id)
            
            # If cluster is now too small, remove it
            if token_clusters[cluster_id].tokens.size() < config.min_cluster_size:
                token_clusters.erase(cluster_id)
    
    # Remove from resonances
    var resonances_to_remove = []
    for resonance_key in token_resonances:
        var parts = resonance_key.split("_to_")
        if parts[0] == token_id or parts[1] == token_id:
            resonances_to_remove.push_back(resonance_key)
    
    for key in resonances_to_remove:
        token_resonances.erase(key)
    
    # Remove token
    active_tokens.erase(token_id)
    
    # Remove word pattern if synchronized
    if word_pattern_visualizer and config.synchronize_with_word_patterns:
        var pattern_text = _token_to_word_pattern(token)
        if word_pattern_visualizer.has_method("remove_word_pattern"):
            word_pattern_visualizer.remove_word_pattern(pattern_text)
    
    return true

func transfer_energy(source_token_id, target_token_id, amount):
    if not active_tokens.has(source_token_id) or not active_tokens.has(target_token_id):
        return false
    
    var source_token = active_tokens[source_token_id]
    var target_token = active_tokens[target_token_id]
    
    # Check if source has enough energy
    if source_token.energy < amount:
        amount = source_token.energy  # Cap at available energy
    
    if amount <= 0:
        return false
    
    # Calculate transfer efficiency
    var efficiency = TOKEN_TYPES[source_token.type].transfer_efficiency
    
    # Apply resonance bonus if tokens resonate
    var resonance_key = source_token_id + "_to_" + target_token_id
    var reverse_key = target_token_id + "_to_" + source_token_id
    
    if token_resonances.has(resonance_key):
        efficiency += token_resonances[resonance_key] * 0.1
    elif token_resonances.has(reverse_key):
        efficiency += token_resonances[reverse_key] * 0.1
    
    efficiency = min(efficiency, 0.99)  # Cap efficiency
    
    # Transfer energy
    var transferred = amount * efficiency
    source_token.energy -= amount
    target_token.energy += transferred
    
    # Update last update time
    source_token.last_update = process_time
    target_token.last_update = process_time
    
    # Synchronize with word patterns
    if word_pattern_visualizer and config.synchronize_with_word_patterns:
        var source_pattern = _token_to_word_pattern(source_token)
        var target_pattern = _token_to_word_pattern(target_token)
        
        if word_pattern_visualizer.has_method("transfer_energy_between_patterns"):
            word_pattern_visualizer.transfer_energy_between_patterns(
                source_pattern, target_pattern, transferred)
    
    # Emit signals
    emit_signal("token_energy_changed", source_token_id, source_token.energy, "transfer")
    emit_signal("token_energy_changed", target_token_id, target_token.energy, "transfer")
    
    return true

func apply_numeric_boost(tunnel_id, value):
    if not ethereal_tunnel_manager or not ethereal_tunnel_manager.has_tunnel(tunnel_id):
        return false
    
    var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
    
    # Create a token for this value
    var token_type = _get_token_type_for_dimension(tunnel_data.dimension)
    var token_id = create_token(value, token_type, "tunnel_" + tunnel_id)
    
    if not token_id:
        return false
    
    var token = active_tokens[token_id]
    
    # Apply token energy as stability boost
    var stability_boost = token.energy / 1000.0
    var new_stability = min(1.0, tunnel_data.stability + stability_boost)
    
    ethereal_tunnel_manager.set_tunnel_stability(tunnel_id, new_stability)
    
    # Add visual effect if tunnel visualizer is available
    if tunnel_visualizer and tunnel_visualizer.has_method("add_color_flash"):
        var token_color = TOKEN_TYPES[token_type].color
        tunnel_visualizer.add_color_flash(tunnel_id, token_color)
    
    return true

func apply_token_to_transfer(content, source_dimension = 3):
    # Extract numeric values from content
    var numbers = _extract_numbers_from_string(content)
    
    if numbers.empty():
        return content
    
    # Calculate combined numeric value
    var combined_value = 0
    for num in numbers:
        combined_value += num
    
    # Create token for this combined value
    var token_type = _get_token_type_for_dimension(source_dimension)
    var token_id = create_token(combined_value, token_type, "transfer")
    
    if not token_id:
        return content
    
    var token = active_tokens[token_id]
    
    # For demonstration purposes, we'll just add the token ID as a tag
    # In a real implementation, you might encrypt the content or add metadata
    var modified_content = content + "\n[Token: " + token_id + "]"
    
    return modified_content

func check_manifestation_conditions():
    var manifested_tokens = []
    
    # Check each token for manifestation conditions
    for token_id in active_tokens:
        var token = active_tokens[token_id]
        
        # Check energy threshold
        var manifestation_threshold = TOKEN_TYPES[token.type].manifestation_threshold
        
        if token.energy >= manifestation_threshold:
            _manifest_token(token_id)
            manifested_tokens.push_back(token_id)
        else if token.clusters.size() > 0:
            # Check if token is part of a high-energy cluster
            for cluster_id in token.clusters:
                if token_clusters.has(cluster_id):
                    var cluster = token_clusters[cluster_id]
                    
                    if cluster.total_energy >= manifestation_threshold * 1.5:
                        _manifest_token(token_id, cluster_id)
                        manifested_tokens.push_back(token_id)
                        break
    
    return manifested_tokens

func get_token_info(token_id):
    if not active_tokens.has(token_id):
        return null
    
    return active_tokens[token_id]

func get_active_token_count():
    return active_tokens.size()

func get_highest_energy_tokens(count = 5):
    var tokens = active_tokens.keys()
    tokens.sort_custom(Callable(self, "_sort_by_energy"))
    
    return tokens.slice(0, min(count, tokens.size()) - 1)

func get_active_clusters():
    return token_clusters.keys()

func get_cluster_info(cluster_id):
    if not token_clusters.has(cluster_id):
        return null
    
    return token_clusters[cluster_id]

func _update_token_energies(delta):
    # Apply energy changes to tokens
    for token_id in active_tokens:
        var token = active_tokens[token_id]
        
        # Apply decay
        token.energy *= (1.0 - config.token_decay_rate * delta)
        
        # Apply dimension boost based on current system turn
        if tunnel_controller:
            var turn_info = tunnel_controller.get_current_turn_info()
            var dimension = token.dimension
            
            # Different turns affect different dimensions
            match turn_info.turn:
                0:  # Origin - boosts base dimension
                    if dimension == 1:
                        token.energy += 1.0 * delta
                
                4:  # Reflection - boosts information dimension
                    if dimension == 5:
                        token.energy += 1.5 * delta
                
                7:  # Insight - boosts consciousness dimension
                    if dimension == 6:
                        token.energy += 2.0 * delta
                
                10:  # Manifestation - boosts all dimensions
                    token.energy += 0.5 * delta
        
        # Apply cluster effect
        if token.clusters.size() > 0:
            token.energy += 0.2 * token.clusters.size() * delta
        
        # Apply pattern meaning boost
        if token.pattern_meanings.size() > 0:
            token.energy += 0.1 * token.pattern_meanings.size() * delta
        
        # Apply prime factor boost
        if token.prime_factors.size() > 0:
            token.energy += 0.05 * token.prime_factors.size() * delta
        
        # Remove tokens with insufficient energy
        if token.energy < 1.0:
            remove_token(token_id)

func _check_token_resonances():
    # Reset resonances
    token_resonances.clear()
    
    # Check all token pairs for resonance
    var token_ids = active_tokens.keys()
    
    for i in range(token_ids.size()):
        var token1_id = token_ids[i]
        
        for j in range(i + 1, token_ids.size()):
            var token2_id = token_ids[j]
            
            var resonance = _calculate_token_resonance(token1_id, token2_id)
            
            if resonance >= config.min_resonance_threshold:
                var resonance_key = token1_id + "_to_" + token2_id
                token_resonances[resonance_key] = resonance
                
                # Emit signal for significant resonances
                if resonance >= 0.6:
                    emit_signal("token_resonance_detected", token1_id, token2_id, resonance)

func _check_token_clusters():
    # Use resonance data to form clusters
    var used_tokens = {}
    var new_clusters = {}
    
    # Sort resonances by strength
    var sorted_resonances = []
    for resonance_key in token_resonances:
        sorted_resonances.push_back({
            "key": resonance_key,
            "value": token_resonances[resonance_key]
        })
    
    sorted_resonances.sort_custom(Callable(self, "_sort_by_resonance_value"))
    
    # Start with highest resonance pairs
    for resonance_data in sorted_resonances:
        var resonance_key = resonance_data.key
        var parts = resonance_key.split("_to_")
        var token1_id = parts[0]
        var token2_id = parts[1]
        
        # Skip if either token is already in a full cluster
        if used_tokens.has(token1_id) and used_tokens[token1_id].size() >= config.max_cluster_size:
            continue
        
        if used_tokens.has(token2_id) and used_tokens[token2_id].size() >= config.max_cluster_size:
            continue
        
        # Find if either token is already in a cluster
        var cluster_id = null
        
        if used_tokens.has(token1_id):
            cluster_id = used_tokens[token1_id][0]  # Use first cluster
        elif used_tokens.has(token2_id):
            cluster_id = used_tokens[token2_id][0]  # Use first cluster
        
        if cluster_id == null:
            # Create new cluster
            cluster_id = _generate_cluster_id()
            new_clusters[cluster_id] = {
                "id": cluster_id,
                "tokens": [],
                "dimension": 0,  # Will be calculated
                "total_energy": 0.0,
                "formation_time": process_time
            }
        
        // Add tokens to cluster
        var cluster = new_clusters[cluster_id]
        
        if not cluster.tokens.has(token1_id):
            cluster.tokens.push_back(token1_id)
            
            if not used_tokens.has(token1_id):
                used_tokens[token1_id] = []
            
            used_tokens[token1_id].push_back(cluster_id)
        }
        
        if not cluster.tokens.has(token2_id):
            cluster.tokens.push_back(token2_id)
            
            if not used_tokens.has(token2_id):
                used_tokens[token2_id] = []
            
            used_tokens[token2_id].push_back(cluster_id)
        }
    }
    
    // Calculate cluster properties
    for cluster_id in new_clusters:
        var cluster = new_clusters[cluster_id]
        
        // Only keep clusters of sufficient size
        if cluster.tokens.size() < config.min_cluster_size:
            continue
        
        // Calculate total energy and average dimension
        var total_energy = 0.0
        var dimension_sum = 0
        
        for token_id in cluster.tokens:
            if active_tokens.has(token_id):
                var token = active_tokens[token_id]
                total_energy += token.energy
                dimension_sum += token.dimension
                
                // Add cluster to token
                if not token.clusters.has(cluster_id):
                    token.clusters.push_back(cluster_id)
            }
        }
        
        cluster.total_energy = total_energy
        cluster.dimension = round(float(dimension_sum) / cluster.tokens.size())
        
        // Store or update cluster
        if token_clusters.has(cluster_id):
            token_clusters[cluster_id] = cluster
        else:
            token_clusters[cluster_id] = cluster
            emit_signal("token_cluster_formed", cluster_id, cluster.tokens)
        }
    }

func _manifest_token(token_id, cluster_id = ""):
    if not active_tokens.has(token_id):
        return
    
    var token = active_tokens[token_id]
    var dimension = token.dimension
    var power = token.energy
    
    // If manifesting from cluster, increase power
    if cluster_id != "" and token_clusters.has(cluster_id):
        var cluster = token_clusters[cluster_id]
        power += cluster.total_energy * 0.2
        
        // Use cluster dimension if higher
        if cluster.dimension > dimension:
            dimension = cluster.dimension
        }
    }
    
    print("Manifesting token: " + token_id + " (Value: " + str(token.value) + 
          ", Dimension: " + str(dimension) + ", Power: " + str(power) + ")")
    
    // Emit signal
    emit_signal("token_manifestation", token_id, power, dimension)
    
    // Affect tunnels in the same dimension
    if ethereal_tunnel_manager:
        var tunnels = ethereal_tunnel_manager.get_tunnels()
        
        for tunnel_id in tunnels:
            var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
            
            // Match dimension
            if tunnel_data.dimension == dimension:
                // Apply stability boost
                var stability_boost = power / 1000.0
                var new_stability = min(1.0, tunnel_data.stability + stability_boost)
                
                ethereal_tunnel_manager.set_tunnel_stability(tunnel_id, new_stability)
                
                // Apply visual effect
                if tunnel_visualizer and tunnel_visualizer.has_method("add_color_flash"):
                    tunnel_visualizer.add_color_flash(tunnel_id, TOKEN_TYPES[token.type].color)
            }
        }
    }
    
    // Synchronize with word pattern system
    if word_pattern_visualizer and config.synchronize_with_word_patterns:
        var pattern = _token_to_word_pattern(token)
        
        // Set enough energy to trigger manifestation in the word system too
        if word_pattern_visualizer.has_method("visualize_word_pattern"):
            word_pattern_visualizer.visualize_word_pattern(pattern, power, dimension)
    }
    
    // Remove the manifested token
    remove_token(token_id)

func _cleanup_expired_tokens():
    var tokens_to_remove = []
    
    // Find expired tokens (very low energy or too old)
    for token_id in active_tokens:
        var token = active_tokens[token_id]
        var age = process_time - token.creation_time
        
        // Remove tokens older than 60 seconds with low energy
        if age > 60.0 and token.energy < 5.0:
            tokens_to_remove.push_back(token_id)
        }
        
        // Remove very low energy tokens regardless of age
        if token.energy < 0.5:
            tokens_to_remove.push_back(token_id)
        }
    }
    
    // Remove expired tokens
    for token_id in tokens_to_remove:
        remove_token(token_id)
    }

func _calculate_token_resonance(token1_id, token2_id):
    var token1 = active_tokens[token1_id]
    var token2 = active_tokens[token2_id]
    
    // Base resonance - similarity of values
    var value_ratio = min(token1.value, token2.value) / max(token1.value, token2.value)
    
    // Dimension resonance
    var dimension_similarity = 1.0 - (abs(token1.dimension - token2.dimension) / 9.0)
    
    // Pattern resonance
    var pattern_match = 0.0
    
    for pattern1 in token1.patterns:
        for pattern2 in token2.patterns:
            if pattern1 == pattern2:
                pattern_match = 1.0
                break
            
            // Partial match for related patterns
            if pattern1.length() >= 3 and pattern2.find(pattern1) >= 0:
                pattern_match = max(pattern_match, 0.7)
            else if pattern2.length() >= 3 and pattern1.find(pattern2) >= 0:
                pattern_match = max(pattern_match, 0.7)
            }
        }
    }
    
    // Prime factor resonance
    var prime_resonance = 0.0
    
    if config.enable_prime_resonance:
        var common_factors = 0.0
        
        for factor in token1.prime_factors:
            if token2.prime_factors.has(factor):
                common_factors += 1.0
            }
        }
        
        if token1.prime_factors.size() > 0 and token2.prime_factors.size() > 0:
            prime_resonance = common_factors / max(token1.prime_factors.size(), token2.prime_factors.size())
        }
    }
    
    // Fibonacci resonance
    var fibonacci_resonance = 0.0
    
    if config.enable_fibonacci_scaling:
        var fib1 = _is_fibonacci(token1.value)
        var fib2 = _is_fibonacci(token2.value)
        
        if fib1 > 0 and fib2 > 0:
            fibonacci_resonance = 1.0 - (abs(fib1 - fib2) / max(fib1, fib2))
        }
    }
    
    // Calculate combined resonance
    var resonance = (
        value_ratio * 0.3 +
        dimension_similarity * 0.2 +
        pattern_match * 0.2 +
        prime_resonance * 0.15 +
        fibonacci_resonance * 0.15
    )
    
    return resonance

func _extract_numeric_patterns(value_str):
    var patterns = []
    
    // Check common patterns
    for pattern in PATTERN_MEANINGS.keys():
        if value_str.find(pattern) >= 0:
            patterns.push_back(pattern)
        }
    }
    
    // Look for repeating digits
    for i in range(value_str.length() - 2):
        var digit = value_str[i]
        
        if value_str[i+1] == digit and value_str[i+2] == digit:
            patterns.push_back(digit + digit + digit)
        }
    }
    
    // Look for sequences
    for i in range(value_str.length() - 2):
        var d1 = int(value_str[i])
        var d2 = int(value_str[i+1])
        var d3 = int(value_str[i+2])
        
        if d2 == d1 + 1 and d3 == d2 + 1:
            patterns.push_back(value_str.substr(i, 3))
        }
    }
    
    return patterns

func _extract_numbers_from_string(text):
    var numbers = []
    var current_number = ""
    
    for i in range(text.length()):
        var c = text[i]
        
        if c >= '0' and c <= '9':
            current_number += c
        else if current_number.length() > 0:
            numbers.push_back(int(current_number))
            current_number = ""
        }
    }
    
    // Add final number if there is one
    if current_number.length() > 0:
        numbers.push_back(int(current_number))
    }
    
    return numbers

func _get_prime_factors(n):
    var factors = []
    var original_n = n
    
    // Handle special cases
    if n <= 1:
        return factors
    }
    
    // Find factors of 2
    while n % 2 == 0:
        factors.push_back(2)
        n /= 2
    }
    
    // Find factors of odd numbers
    var i = 3
    while i * i <= n:
        while n % i == 0:
            factors.push_back(i)
            n /= i
        }
        i += 2
    }
    
    // If n is a prime number greater than 2
    if n > 2:
        factors.push_back(n)
    }
    
    return factors

func _is_fibonacci(n):
    // Check if a number is in the Fibonacci sequence
    // Returns the position if found, 0 if not
    
    // Small values check
    if n == 0 or n == 1:
        return n + 1  // Position 1 for 0, position 2 for 1
    }
    
    // Check if in cache
    for i in range(3, fibonacci_cache.size() + 1):
        if fibonacci_cache[i] == n:
            return i
        }
        
        // If we've gone past n, it's not a Fibonacci number
        if fibonacci_cache[i] > n:
            return 0
        }
    }
    
    // Compute more Fibonacci numbers if needed
    var i = fibonacci_cache.size() + 1
    while true:
        var fib = _fibonacci(i)
        
        if fib == n:
            return i
        }
        
        if fib > n:
            return 0
        }
        
        i += 1
        
        // Safety check to avoid infinite loop
        if i > 100:
            return 0
        }
    }
    
    return 0

func _fibonacci(n):
    // Calculate nth Fibonacci number with caching
    if fibonacci_cache.has(n):
        return fibonacci_cache[n]
    }
    
    var result = _fibonacci(n-1) + _fibonacci(n-2)
    fibonacci_cache[n] = result
    
    return result

func _precompute_fibonacci(max_n):
    // Precompute Fibonacci sequence up to max_n
    for i in range(2, max_n + 1):
        fibonacci_cache[i] = fibonacci_cache[i-1] + fibonacci_cache[i-2]
    }

func _is_valid_token_value(value):
    // Validate token value
    if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
        return false
    }
    
    // Convert to integer if needed
    if typeof(value) == TYPE_FLOAT:
        value = int(value)
    }
    
    // Range check
    if value < 0 or value > 9999999:
        return false
    }
    
    return true

func _generate_token_id(value, type):
    // Create unique ID for this token
    var timestamp = str(int(process_time * 1000.0))
    var random_suffix = str(randi() % 10000).pad_zeros(4)
    
    return type.to_lower() + "_" + str(value) + "_" + timestamp + "_" + random_suffix

func _generate_cluster_id():
    // Create unique ID for a cluster
    var timestamp = str(int(process_time * 1000.0))
    var random_suffix = str(randi() % 100000).pad_zeros(5)
    
    return "cluster_" + timestamp + "_" + random_suffix

func _get_token_type_for_dimension(dimension):
    // Map dimension to token type
    for type in TOKEN_TYPES:
        if TOKEN_TYPES[type].dimension == dimension:
            return type
        }
    }
    
    // Default to BASE type
    return "BASE"

func _token_to_word_pattern(token):
    // Convert token to a word pattern for visualization
    var value_str = str(token.value)
    var pattern = value_str
    
    // Add type prefix
    pattern = token.type.to_lower() + "_" + pattern
    
    // Add pattern meaning if available
    if token.pattern_meanings.size() > 0:
        pattern += "_" + token.pattern_meanings[0]
    }
    
    return pattern

func _sort_by_energy(a, b):
    return active_tokens[a].energy > active_tokens[b].energy

func _sort_by_resonance_value(a, b):
    return a.value > b.value