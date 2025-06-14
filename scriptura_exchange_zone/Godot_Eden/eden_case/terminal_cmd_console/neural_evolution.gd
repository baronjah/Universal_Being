extends Node
class_name NeuralEvolution

# Signals
signal evolution_step(generation, fitness)
signal pattern_detected(pattern_id, confidence, metadata)
signal training_completed(network_info)
signal weight_updated(layer_id, neuron_id, weight_delta)

# Configuration
export var learning_rate = 0.01
export var mutation_rate = 0.05
export var hidden_layers = [32, 16]
export var input_features = 64
export var output_classes = 8
export var batch_size = 16
export var generation_limit = 100
export var fitness_threshold = 0.95
export var auto_save = true
export var save_interval = 10  # Save every 10 generations

# Neural network state
var weights = []
var biases = []
var generation = 0
var current_fitness = 0.0
var best_fitness = 0.0
var best_weights = []
var best_biases = []
var training_data = []
var validation_data = []
var is_training = false
var recognized_patterns = {}
var patterns_history = []

# Cached computed values
var layer_sizes = []
var activation_cache = {}

# Random number generator for reproducibility
var rng = RandomNumberGenerator.new()

func _ready():
    # Initialize RNG with random seed
    rng.randomize()
    
    # Initialize layer sizes
    layer_sizes = [input_features]
    layer_sizes.append_array(hidden_layers)
    layer_sizes.append(output_classes)
    
    # Initialize network with random weights
    initialize_network()

func initialize_network():
    weights = []
    biases = []
    
    # For each layer pair, initialize weights and biases
    for i in range(layer_sizes.size() - 1):
        var input_size = layer_sizes[i]
        var output_size = layer_sizes[i + 1]
        
        # Initialize weights with Xavier/Glorot initialization
        var w = []
        var scale = sqrt(6.0 / (input_size + output_size))
        
        for j in range(output_size):
            var neuron_weights = []
            for k in range(input_size):
                neuron_weights.append(rng.randf_range(-scale, scale))
            w.append(neuron_weights)
        
        weights.append(w)
        
        # Initialize biases to zeros
        var b = []
        for j in range(output_size):
            b.append(0.0)
        
        biases.append(b)
    
    print("Neural network initialized with architecture: ", layer_sizes)
    
    # Reset generation and fitness
    generation = 0
    current_fitness = 0.0
    best_fitness = 0.0
    best_weights = deep_copy(weights)
    best_biases = deep_copy(biases)

func set_layer_architecture(new_architecture):
    # Validate architecture
    if new_architecture.size() < 2:
        printerr("Invalid architecture: must have at least input and output layers")
        return false
    
    # Update layer sizes
    input_features = new_architecture[0]
    output_classes = new_architecture[new_architecture.size() - 1]
    hidden_layers = []
    
    for i in range(1, new_architecture.size() - 1):
        hidden_layers.append(new_architecture[i])
    
    # Reinitialize network
    layer_sizes = new_architecture
    initialize_network()
    
    print("Network architecture updated: ", layer_sizes)
    return true

func add_training_sample(input_data, expected_output, is_validation=false):
    if input_data.size() != input_features:
        printerr("Invalid input size: expected ", input_features, ", got ", input_data.size())
        return false
    
    # Convert expected output to one-hot encoding if it's a class index
    var target_output = expected_output
    if typeof(expected_output) == TYPE_INT:
        if expected_output < 0 or expected_output >= output_classes:
            printerr("Invalid output class: ", expected_output)
            return false
        
        target_output = []
        for i in range(output_classes):
            target_output.append(1.0 if i == expected_output else 0.0)
    elif expected_output.size() != output_classes:
        printerr("Invalid output size: expected ", output_classes, ", got ", expected_output.size())
        return false
    
    # Create sample
    var sample = {
        "input": input_data.duplicate(),
        "output": target_output.duplicate()
    }
    
    # Add to appropriate dataset
    if is_validation:
        validation_data.append(sample)
    else:
        training_data.append(sample)
    
    return true

func clear_training_data():
    training_data.clear()
    print("Training data cleared")

func clear_validation_data():
    validation_data.clear()
    print("Validation data cleared")

func train(epochs=10, callback_interval=1):
    if training_data.size() == 0:
        printerr("No training data available")
        return false
    
    is_training = true
    print("Starting training for ", epochs, " epochs, ", training_data.size(), " samples")
    
    for epoch in range(epochs):
        # Shuffle training data for each epoch
        training_data.shuffle()
        
        # Process in batches
        var total_loss = 0.0
        var correct_predictions = 0
        var total_samples = training_data.size()
        
        for i in range(0, total_samples, batch_size):
            var batch_end = min(i + batch_size, total_samples)
            var batch_size_actual = batch_end - i
            
            # Process batch
            var batch_loss = 0.0
            var batch_gradients = []
            var batch_bias_gradients = []
            
            # Initialize gradient accumulators
            for layer_idx in range(weights.size()):
                var layer_gradients = []
                var layer_bias_gradients = []
                
                for neuron_idx in range(weights[layer_idx].size()):
                    var neuron_gradients = []
                    for weight_idx in range(weights[layer_idx][neuron_idx].size()):
                        neuron_gradients.append(0.0)
                    
                    layer_gradients.append(neuron_gradients)
                    layer_bias_gradients.append(0.0)
                
                batch_gradients.append(layer_gradients)
                batch_bias_gradients.append(layer_bias_gradients)
            
            # Process each sample in batch
            for j in range(i, batch_end):
                var sample = training_data[j]
                var inputs = sample.input
                var targets = sample.output
                
                # Forward pass
                var activations = forward(inputs)
                var outputs = activations[activations.size() - 1]
                
                # Calculate loss and update stats
                var sample_loss = calculate_loss(outputs, targets)
                batch_loss += sample_loss
                
                # Check if prediction is correct
                var predicted_class = argmax(outputs)
                var target_class = argmax(targets)
                if predicted_class == target_class:
                    correct_predictions += 1
                
                # Backward pass to calculate gradients
                var sample_gradients = backward(activations, targets)
                
                # Accumulate gradients
                for layer_idx in range(weights.size()):
                    for neuron_idx in range(weights[layer_idx].size()):
                        for weight_idx in range(weights[layer_idx][neuron_idx].size()):
                            batch_gradients[layer_idx][neuron_idx][weight_idx] += sample_gradients[0][layer_idx][neuron_idx][weight_idx]
                        
                        batch_bias_gradients[layer_idx][neuron_idx] += sample_gradients[1][layer_idx][neuron_idx]
            
            # Apply gradients averaged over batch
            for layer_idx in range(weights.size()):
                for neuron_idx in range(weights[layer_idx].size()):
                    for weight_idx in range(weights[layer_idx][neuron_idx].size()):
                        var gradient = batch_gradients[layer_idx][neuron_idx][weight_idx] / batch_size_actual
                        weights[layer_idx][neuron_idx][weight_idx] -= learning_rate * gradient
                        
                        # Emit signal for significant weight changes
                        if abs(gradient) > 0.1:
                            emit_signal("weight_updated", layer_idx, neuron_idx, gradient)
                    
                    var bias_gradient = batch_bias_gradients[layer_idx][neuron_idx] / batch_size_actual
                    biases[layer_idx][neuron_idx] -= learning_rate * bias_gradient
            
            total_loss += batch_loss
        
        # Calculate epoch metrics
        var avg_loss = total_loss / total_samples
        var accuracy = float(correct_predictions) / total_samples
        
        # Update fitness and generation
        current_fitness = accuracy
        generation += 1
        
        # Check if this is the best model so far
        if current_fitness > best_fitness:
            best_fitness = current_fitness
            best_weights = deep_copy(weights)
            best_biases = deep_copy(biases)
            
            # Save best model if auto-save is enabled
            if auto_save:
                save_network_state("user://neural_evolution/best_model.nn")
        
        # Emit progress signal
        if epoch % callback_interval == 0 or epoch == epochs - 1:
            print("Epoch ", epoch + 1, "/", epochs, ": Loss = ", avg_loss, ", Accuracy = ", accuracy)
            emit_signal("evolution_step", generation, current_fitness)
        
        # Save at intervals if auto-save is enabled
        if auto_save and epoch % save_interval == 0 and epoch > 0:
            save_network_state("user://neural_evolution/checkpoint_" + str(epoch) + ".nn")
        
        # Check for early stopping
        if current_fitness >= fitness_threshold:
            print("Early stopping: fitness threshold reached")
            break
        
        # Allow process to be cancelled
        if !is_training:
            print("Training cancelled at epoch ", epoch + 1)
            break
    
    # Training complete
    is_training = false
    
    # Validate if validation data is available
    if validation_data.size() > 0:
        var validation_accuracy = validate()
        print("Validation accuracy: ", validation_accuracy)
        
        # Use validation model if it's better
        if validation_accuracy > best_fitness:
            best_fitness = validation_accuracy
            best_weights = deep_copy(weights)
            best_biases = deep_copy(biases)
    
    # Use best weights
    weights = deep_copy(best_weights)
    biases = deep_copy(best_biases)
    
    # Final save
    if auto_save:
        save_network_state("user://neural_evolution/final_model.nn")
    
    # Emit completion signal
    emit_signal("training_completed", {
        "architecture": layer_sizes,
        "epochs": epochs,
        "final_accuracy": current_fitness,
        "best_accuracy": best_fitness,
        "generation": generation
    })
    
    return true

func validate():
    if validation_data.size() == 0:
        print("No validation data available")
        return 0.0
    
    var correct_predictions = 0
    var total_samples = validation_data.size()
    
    for sample in validation_data:
        var inputs = sample.input
        var targets = sample.output
        
        # Forward pass
        var activations = forward(inputs)
        var outputs = activations[activations.size() - 1]
        
        # Check if prediction is correct
        var predicted_class = argmax(outputs)
        var target_class = argmax(targets)
        if predicted_class == target_class:
            correct_predictions += 1
    
    return float(correct_predictions) / total_samples

func stop_training():
    is_training = false

func predict(input_data):
    if input_data.size() != input_features:
        printerr("Invalid input size: expected ", input_features, ", got ", input_data.size())
        return null
    
    # Forward pass
    var activations = forward(input_data)
    var outputs = activations[activations.size() - 1]
    
    # Get predicted class and confidence
    var predicted_class = argmax(outputs)
    var confidence = outputs[predicted_class]
    
    return {
        "class": predicted_class,
        "confidence": confidence,
        "outputs": outputs.duplicate()
    }

func predict_pattern(input_data, confidence_threshold=0.75):
    var prediction = predict(input_data)
    if prediction == null:
        return null
    
    # Only consider predictions with high confidence
    if prediction.confidence < confidence_threshold:
        return null
    
    # Generate pattern ID
    var pattern_id = "pattern_" + str(prediction.class)
    
    # Update pattern history
    var timestamp = OS.get_unix_time()
    patterns_history.append({
        "pattern_id": pattern_id,
        "confidence": prediction.confidence,
        "timestamp": timestamp,
        "class": prediction.class
    })
    
    # Trim history if too large
    if patterns_history.size() > 100:
        patterns_history.pop_front()
    
    # Update pattern recognition database
    if !recognized_patterns.has(pattern_id):
        recognized_patterns[pattern_id] = {
            "class": prediction.class,
            "first_seen": timestamp,
            "occurrences": 0,
            "avg_confidence": 0.0,
            "last_seen": timestamp
        }
    
    var pattern = recognized_patterns[pattern_id]
    pattern.occurrences += 1
    pattern.last_seen = timestamp
    pattern.avg_confidence = (pattern.avg_confidence * (pattern.occurrences - 1) + prediction.confidence) / pattern.occurrences
    
    # Emit signal
    var metadata = {
        "timestamp": timestamp,
        "occurrences": pattern.occurrences,
        "outputs": prediction.outputs
    }
    emit_signal("pattern_detected", pattern_id, prediction.confidence, metadata)
    
    return {
        "pattern_id": pattern_id,
        "confidence": prediction.confidence,
        "metadata": metadata
    }

func forward(inputs):
    # Forward pass through the network
    var activations = []
    var layer_input = inputs.duplicate()
    
    activations.append(layer_input)
    
    # Process each layer
    for layer_idx in range(weights.size()):
        var layer_output = []
        var layer_weights = weights[layer_idx]
        var layer_biases = biases[layer_idx]
        
        for neuron_idx in range(layer_weights.size()):
            var weighted_sum = 0.0
            var neuron_weights = layer_weights[neuron_idx]
            
            for input_idx in range(layer_input.size()):
                weighted_sum += neuron_weights[input_idx] * layer_input[input_idx]
            
            weighted_sum += layer_biases[neuron_idx]
            
            # Apply activation function (ReLU for hidden layers, softmax for output layer)
            if layer_idx < weights.size() - 1:
                layer_output.append(relu(weighted_sum))
            else:
                layer_output.append(weighted_sum)  # Raw output for softmax later
        
        # Apply softmax to output layer
        if layer_idx == weights.size() - 1:
            layer_output = softmax(layer_output)
        
        activations.append(layer_output)
        layer_input = layer_output
    
    return activations

func backward(activations, targets):
    # Backward pass to calculate gradients
    var weight_gradients = []
    var bias_gradients = []
    
    # Initialize gradients with zeros
    for layer_idx in range(weights.size()):
        var layer_weights = weights[layer_idx]
        var layer_weight_gradients = []
        var layer_bias_gradients = []
        
        for neuron_idx in range(layer_weights.size()):
            var neuron_weight_gradients = []
            for weight_idx in range(layer_weights[neuron_idx].size()):
                neuron_weight_gradients.append(0.0)
            
            layer_weight_gradients.append(neuron_weight_gradients)
            layer_bias_gradients.append(0.0)
        
        weight_gradients.append(layer_weight_gradients)
        bias_gradients.append(layer_bias_gradients)
    
    # Calculate output layer error (cross-entropy gradient)
    var output_layer_idx = activations.size() - 1
    var outputs = activations[output_layer_idx]
    var output_errors = []
    
    for i in range(outputs.size()):
        # Derivative of cross-entropy with softmax: output - target
        output_errors.append(outputs[i] - targets[i])
    
    # Backpropagate error through the network
    var layer_errors = output_errors
    
    for layer_idx in range(weights.size() - 1, -1, -1):
        var prev_layer_activations = activations[layer_idx]
        var current_layer_size = weights[layer_idx][0].size()
        var next_layer_size = weights[layer_idx].size()
        
        # Calculate weight and bias gradients for this layer
        for neuron_idx in range(next_layer_size):
            var neuron_error = layer_errors[neuron_idx]
            
            for weight_idx in range(current_layer_size):
                weight_gradients[layer_idx][neuron_idx][weight_idx] = neuron_error * prev_layer_activations[weight_idx]
            
            bias_gradients[layer_idx][neuron_idx] = neuron_error
        
        # Calculate errors for previous layer (if not the input layer)
        if layer_idx > 0:
            var prev_layer_errors = []
            for i in range(current_layer_size):
                var error = 0.0
                for j in range(next_layer_size):
                    error += layer_errors[j] * weights[layer_idx][j][i]
                
                # Apply derivative of ReLU
                error *= relu_derivative(prev_layer_activations[i])
                prev_layer_errors.append(error)
            
            layer_errors = prev_layer_errors
    
    return [weight_gradients, bias_gradients]

func calculate_loss(outputs, targets):
    # Cross-entropy loss for classification
    var loss = 0.0
    var epsilon = 1e-15  # Small value to avoid log(0)
    
    for i in range(outputs.size()):
        loss -= targets[i] * log(max(outputs[i], epsilon))
    
    return loss

func relu(x):
    return max(0.0, x)

func relu_derivative(x):
    return 1.0 if x > 0.0 else 0.0

func softmax(x):
    var result = []
    var max_val = x[0]
    
    # Find maximum value for numerical stability
    for i in range(1, x.size()):
        max_val = max(max_val, x[i])
    
    # Calculate exp(x - max) for each element
    var sum_exp = 0.0
    for i in range(x.size()):
        var exp_val = exp(x[i] - max_val)
        result.append(exp_val)
        sum_exp += exp_val
    
    # Normalize by sum
    for i in range(result.size()):
        result[i] /= sum_exp
    
    return result

func argmax(array):
    var max_idx = 0
    var max_val = array[0]
    
    for i in range(1, array.size()):
        if array[i] > max_val:
            max_val = array[i]
            max_idx = i
    
    return max_idx

func evolve_network():
    # Evolutionary approach: apply random mutations to weights
    for layer_idx in range(weights.size()):
        for neuron_idx in range(weights[layer_idx].size()):
            for weight_idx in range(weights[layer_idx][neuron_idx].size()):
                # Apply mutation with probability
                if rng.randf() < mutation_rate:
                    var mutation = rng.randf_range(-0.1, 0.1)
                    weights[layer_idx][neuron_idx][weight_idx] += mutation
                    
                    # Emit signal for significant mutations
                    if abs(mutation) > 0.05:
                        emit_signal("weight_updated", layer_idx, neuron_idx, mutation)
            
            # Mutate biases
            if rng.randf() < mutation_rate:
                biases[layer_idx][neuron_idx] += rng.randf_range(-0.1, 0.1)
    
    # Increment generation counter
    generation += 1
    
    # Emit evolution step signal
    emit_signal("evolution_step", generation, current_fitness)
    
    return generation

func save_network_state(file_path="user://neural_evolution/network_state.nn"):
    # Ensure directory exists
    var dir = Directory.new()
    var dir_path = file_path.get_base_dir()
    
    if !dir.dir_exists(dir_path):
        dir.make_dir_recursive(dir_path)
    
    # Create serializable state
    var state = {
        "architecture": layer_sizes,
        "weights": weights,
        "biases": biases,
        "generation": generation,
        "fitness": current_fitness,
        "best_fitness": best_fitness,
        "best_weights": best_weights,
        "best_biases": best_biases,
        "recognized_patterns": recognized_patterns,
        "timestamp": OS.get_unix_time()
    }
    
    # Save to file
    var file = File.new()
    var err = file.open(file_path, File.WRITE)
    if err != OK:
        printerr("Failed to save network state: ", err)
        return false
    
    file.store_string(JSON.print(state))
    file.close()
    
    print("Neural network state saved to: ", file_path)
    return true

func load_network_state(file_path="user://neural_evolution/network_state.nn"):
    # Check if file exists
    var file = File.new()
    if !file.file_exists(file_path):
        printerr("Network state file not found: ", file_path)
        return false
    
    # Load from file
    var err = file.open(file_path, File.READ)
    if err != OK:
        printerr("Failed to load network state: ", err)
        return false
    
    var json = JSON.parse(file.get_as_text())
    file.close()
    
    if json.error != OK:
        printerr("Failed to parse network state JSON: ", json.error_string)
        return false
    
    var state = json.result
    
    # Validate state
    if !state.has("architecture") or !state.has("weights") or !state.has("biases"):
        printerr("Invalid network state file format")
        return false
    
    # Update network architecture
    layer_sizes = state.architecture
    input_features = layer_sizes[0]
    output_classes = layer_sizes[layer_sizes.size() - 1]
    hidden_layers = []
    
    for i in range(1, layer_sizes.size() - 1):
        hidden_layers.append(layer_sizes[i])
    
    # Load weights and biases
    weights = state.weights
    biases = state.biases
    
    # Load other state variables
    generation = state.get("generation", 0)
    current_fitness = state.get("fitness", 0.0)
    best_fitness = state.get("best_fitness", 0.0)
    
    if state.has("best_weights") and state.has("best_biases"):
        best_weights = state.best_weights
        best_biases = state.best_biases
    else:
        best_weights = deep_copy(weights)
        best_biases = deep_copy(biases)
    
    # Load pattern recognition database if available
    if state.has("recognized_patterns"):
        recognized_patterns = state.recognized_patterns
    
    print("Neural network state loaded from: ", file_path)
    print("Architecture: ", layer_sizes, ", Generation: ", generation, ", Fitness: ", current_fitness)
    
    return true

func extract_features(data_source, feature_count=64):
    # Simple feature extraction from various data sources
    var features = []
    
    match typeof(data_source):
        TYPE_STRING:
            # Text features: character frequencies and patterns
            features = _extract_text_features(data_source, feature_count)
        TYPE_ARRAY:
            # Numerical array features
            features = _extract_array_features(data_source, feature_count)
        TYPE_DICTIONARY:
            # Dictionary features: convert to feature vector
            features = _extract_dict_features(data_source, feature_count)
        _:
            # Default case: try to convert to string and extract text features
            features = _extract_text_features(str(data_source), feature_count)
    
    # Ensure we have the right number of features
    if features.size() < feature_count:
        # Pad with zeros
        for i in range(features.size(), feature_count):
            features.append(0.0)
    elif features.size() > feature_count:
        # Truncate
        features = features.slice(0, feature_count)
    
    return features

func _extract_text_features(text, feature_count):
    var features = []
    
    # Character frequency features
    var char_counts = {}
    var total_chars = text.length()
    
    for i in range(text.length()):
        var c = text[i]
        if !char_counts.has(c):
            char_counts[c] = 0
        char_counts[c] += 1
    
    # Extract top N character frequencies
    var top_chars = char_counts.keys()
    top_chars.sort_custom(self, "_sort_by_frequency_desc")
    
    var char_features_count = min(26, feature_count / 2)
    for i in range(min(char_features_count, top_chars.size())):
        features.append(float(char_counts[top_chars[i]]) / total_chars)
    
    # Pad if we have fewer than expected character features
    for i in range(features.size(), char_features_count):
        features.append(0.0)
    
    # Text structure features
    var word_count = text.split(" ", false).size()
    var line_count = text.split("\n", false).size()
    var avg_word_length = total_chars / max(1, word_count)
    var numbers_count = 0
    var special_chars_count = 0
    var uppercase_count = 0
    
    for i in range(text.length()):
        var c = text[i]
        var code = ord(c)
        
        if code >= 48 and code <= 57:  # 0-9
            numbers_count += 1
        elif (code >= 33 and code <= 47) or (code >= 58 and code <= 64) or (code >= 91 and code <= 96) or (code >= 123 and code <= 126):
            special_chars_count += 1
        elif code >= 65 and code <= 90:  # A-Z
            uppercase_count += 1
    
    # Add structural features
    features.append(float(word_count) / max(1, total_chars))
    features.append(float(line_count) / max(1, total_chars))
    features.append(avg_word_length / 20.0)  # Normalize by typical max length
    features.append(float(numbers_count) / max(1, total_chars))
    features.append(float(special_chars_count) / max(1, total_chars))
    features.append(float(uppercase_count) / max(1, total_chars))
    
    # Additional text pattern features
    var repeated_chars = 0
    for i in range(1, text.length()):
        if text[i] == text[i-1]:
            repeated_chars += 1
    
    features.append(float(repeated_chars) / max(1, total_chars))
    
    # Sentiment-like features (simple approximation)
    var positive_words = ["good", "great", "excellent", "positive", "nice", "happy"]
    var negative_words = ["bad", "awful", "terrible", "negative", "poor", "sad"]
    
    var positive_count = 0
    var negative_count = 0
    
    var words = text.to_lower().split(" ", false)
    for word in words:
        if positive_words.has(word):
            positive_count += 1
        elif negative_words.has(word):
            negative_count += 1
    
    features.append(float(positive_count) / max(1, word_count))
    features.append(float(negative_count) / max(1, word_count))
    
    return features

func _sort_by_frequency_desc(a, b):
    return a > b

func _extract_array_features(arr, feature_count):
    var features = []
    
    if arr.size() == 0:
        # Return zeros for empty array
        for i in range(feature_count):
            features.append(0.0)
        return features
    
    # Determine if array contains numbers or strings
    var is_numeric = typeof(arr[0]) == TYPE_INT or typeof(arr[0]) == TYPE_REAL
    
    if is_numeric:
        # Statistical features for numeric arrays
        var sum_val = 0.0
        var sum_squared = 0.0
        var min_val = arr[0]
        var max_val = arr[0]
        
        for val in arr:
            sum_val += val
            sum_squared += val * val
            min_val = min(min_val, val)
            max_val = max(max_val, val)
        
        var mean = sum_val / arr.size()
        var variance = sum_squared / arr.size() - mean * mean
        var std_dev = sqrt(max(0, variance))
        
        # Range normalization for consistent features
        var range_val = max_val - min_val
        if range_val == 0:
            range_val = 1.0
        
        # Add statistical features
        features.append((mean - min_val) / range_val)
        features.append(std_dev / range_val)
        features.append((sum_val - min_val * arr.size()) / (range_val * arr.size()))
        
        # Add min/max normalized to [0,1]
        features.append(0.0)  # min is normalized to 0
        features.append(1.0)  # max is normalized to 1
        
        # Add some element values directly, normalized
        var step = max(1, arr.size() / (feature_count - 5))
        for i in range(0, min(arr.size(), feature_count - 5), step):
            features.append((arr[i] - min_val) / range_val)
    else:
        # Text-based features for non-numeric arrays
        var total_length = 0
        var combined_text = ""
        
        for item in arr:
            var item_str = str(item)
            total_length += item_str.length()
            combined_text += item_str + " "
        
        # Get text features and take a subset
        var text_features = _extract_text_features(combined_text, feature_count)
        features.append_array(text_features)
    
    return features

func _extract_dict_features(dict, feature_count):
    var features = []
    
    # Dictionary size relative to typical size (assume 20 as "full")
    features.append(min(1.0, dict.size() / 20.0))
    
    # Key statistics
    var numeric_keys = 0
    var string_keys = 0
    var other_keys = 0
    var total_key_length = 0
    
    # Value statistics
    var numeric_values = 0
    var string_values = 0
    var array_values = 0
    var dict_values = 0
    var other_values = 0
    var total_string_length = 0
    
    for key in dict:
        # Analyze key type
        match typeof(key):
            TYPE_INT, TYPE_REAL:
                numeric_keys += 1
            TYPE_STRING:
                string_keys += 1
                total_key_length += key.length()
            _:
                other_keys += 1
        
        # Analyze value type
        var value = dict[key]
        match typeof(value):
            TYPE_INT, TYPE_REAL:
                numeric_values += 1
            TYPE_STRING:
                string_values += 1
                total_string_length += value.length()
            TYPE_ARRAY:
                array_values += 1
            TYPE_DICTIONARY:
                dict_values += 1
            _:
                other_values += 1
    
    # Add key type distribution features
    if dict.size() > 0:
        features.append(float(numeric_keys) / dict.size())
        features.append(float(string_keys) / dict.size())
        features.append(float(other_keys) / dict.size())
    else:
        features.append(0.0)
        features.append(0.0)
        features.append(0.0)
    
    # Add value type distribution features
    if dict.size() > 0:
        features.append(float(numeric_values) / dict.size())
        features.append(float(string_values) / dict.size())
        features.append(float(array_values) / dict.size())
        features.append(float(dict_values) / dict.size())
        features.append(float(other_values) / dict.size())
    else:
        features.append(0.0)
        features.append(0.0)
        features.append(0.0)
        features.append(0.0)
        features.append(0.0)
    
    # Add average key and string value length
    if string_keys > 0:
        features.append(min(1.0, total_key_length / (string_keys * 10.0)))
    else:
        features.append(0.0)
    
    if string_values > 0:
        features.append(min(1.0, total_string_length / (string_values * 100.0)))
    else:
        features.append(0.0)
    
    # Extract features from a sample of values if available
    var combined_values = ""
    var count = 0
    
    for key in dict:
        if typeof(dict[key]) == TYPE_STRING and count < 5:
            combined_values += dict[key] + " "
            count += 1
    
    if combined_values.length() > 0:
        var value_features = _extract_text_features(combined_values, feature_count - features.size())
        features.append_array(value_features)
    
    # Ensure we have the right number of features
    while features.size() < feature_count:
        features.append(0.0)
    
    return features.slice(0, feature_count)

func deep_copy(data):
    # Deep copy for arrays and dictionaries
    match typeof(data):
        TYPE_ARRAY:
            var copy = []
            for item in data:
                copy.append(deep_copy(item))
            return copy
            
        TYPE_DICTIONARY:
            var copy = {}
            for key in data:
                copy[key] = deep_copy(data[key])
            return copy
            
        _:
            # For primitive types, return as is
            return data