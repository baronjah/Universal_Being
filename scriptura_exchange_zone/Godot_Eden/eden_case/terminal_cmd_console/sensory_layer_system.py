#!/usr/bin/env python3
# Sensory Layer System - Integrates sensory experiences with reason and stability
# Connects with twelve_turns_system and other components for holistic experiences

import os
import sys
import time
import json
import random
import math
import threading
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple, Set, Union, Callable

# Try to import from other modules
try:
    from twelve_turns_system import CONFIG as TURNS_CONFIG
    TURNS_AVAILABLE = True
except ImportError:
    TURNS_AVAILABLE = False
    TURNS_CONFIG = {}

# Constants
CONFIG = {
    "layer_count": 7,              # Number of sensory layers
    "stability_threshold": 0.7,    # Threshold for layer stability (0-1)
    "reason_integration": True,    # Integrate reasoning with sensory data
    "sensory_types": [             # Types of sensory experiences
        "visual",                  # Visual sensory input
        "auditory",                # Auditory/hearing sensory input
        "taste",                   # Taste sensory input
        "touch",                   # Touch/tactile sensory input
        "smell",                   # Smell/olfactory sensory input
        "proprioceptive",          # Awareness of body position
        "intuitive"                # Intuitive/gut feeling
    ],
    "word_sensory_mapping": True,  # Map words to sensory experiences
    "stability_decay_rate": 0.02,  # Rate at which stability decays
    "reason_amplification": 1.3,   # How much reason amplifies sensory input
    "integration_interval": 5,     # Seconds between integration cycles
    "flavor_profiles": [           # Basic flavor profiles for taste
        "sweet",
        "sour",
        "salty",
        "bitter", 
        "umami",
        "spicy"
    ],
    "sound_profiles": [            # Basic sound profiles for hearing
        "harmonic",
        "dissonant",
        "rhythmic",
        "melodic",
        "percussive",
        "ambient"
    ],
    "reason_categories": [         # Categories of reasoning
        "logical",
        "emotional",
        "intuitive",
        "ethical",
        "practical",
        "abstract"
    ],
    "stability_factors": {         # Factors affecting stability
        "consistency": 0.4,        # Consistency of input over time
        "coherence": 0.3,          # Coherence between different inputs
        "intensity": 0.2,          # Intensity of sensory input
        "familiarity": 0.1         # Familiarity of patterns
    },
    "debug_mode": False,           # Show debug information
    "offline_mode": True,          # Work without external dependencies
    "save_interval": 300,          # Save state every 5 minutes
    "harmony_threshold": 0.65,     # Threshold for sensory harmony
}

# Load turns config if available
if TURNS_AVAILABLE:
    CONFIG["turns_integration"] = True
    CONFIG["turn_count"] = TURNS_CONFIG.get("turn_count", 12)
    CONFIG["progression_sequence"] = TURNS_CONFIG.get("progression_sequence", [0, 1, 2, 3, 4, 5])
    CONFIG["reason_tags"] = TURNS_CONFIG.get("reason_tags", ["#reason"])
else:
    CONFIG["turns_integration"] = False
    CONFIG["turn_count"] = 12
    CONFIG["progression_sequence"] = [0, 1, 2, 3, 4, 5]
    CONFIG["reason_tags"] = ["#reason"]

class SensoryInput:
    """Represents a sensory input in the system"""
    
    def __init__(self, 
                sensory_type: str, 
                intensity: float = 0.5,
                content: str = "", 
                source: str = "system"):
        self.sensory_type = sensory_type
        self.intensity = intensity  # 0.0 to 1.0
        self.content = content
        self.source = source
        self.timestamp = time.time()
        self.duration = 0.0  # Duration of sensation
        self.decay_rate = CONFIG["stability_decay_rate"]
        self.processed = False
        self.associated_words: List[str] = []
        self.connections: List['SensoryConnection'] = []
        self.tags: List[str] = []
        self.harmony_score = 0.5  # Default middle value
        self.reason_score = 0.0  # Reason integration score
        
        # Initialize sensory properties based on type
        self.properties = self._init_properties()
        
    def _init_properties(self) -> Dict[str, Any]:
        """Initialize properties based on sensory type"""
        props = {
            "raw_value": 0.5,
            "processed_value": 0.5,
            "stability": 0.5,
            "active": True
        }
        
        # Add type-specific properties
        if self.sensory_type == "visual":
            props.update({
                "color": "#FFFFFF",
                "brightness": 0.5,
                "movement": 0.0,
                "pattern": "none",
                "clarity": 0.5
            })
        elif self.sensory_type == "auditory":
            # Choose random sound profile
            sound_profile = random.choice(CONFIG["sound_profiles"])
            props.update({
                "volume": 0.5,
                "pitch": 0.5,
                "timbre": sound_profile,
                "rhythm": 0.0,
                "clarity": 0.5
            })
        elif self.sensory_type == "taste":
            # Choose random flavor profile
            flavor = random.choice(CONFIG["flavor_profiles"])
            props.update({
                "flavor": flavor,
                "intensity": self.intensity,
                "complexity": 0.3,
                "pleasantness": 0.5,
                "aftertaste": 0.2
            })
        elif self.sensory_type == "touch":
            props.update({
                "pressure": 0.5,
                "temperature": 0.5,
                "texture": "neutral",
                "location": "general",
                "pleasantness": 0.5
            })
        elif self.sensory_type == "smell":
            props.update({
                "intensity": self.intensity,
                "pleasantness": 0.5,
                "familiarity": 0.3,
                "complexity": 0.4,
                "type": "neutral"
            })
        elif self.sensory_type == "proprioceptive":
            props.update({
                "position": "neutral",
                "balance": 0.5,
                "movement": 0.0,
                "effort": 0.3,
                "comfort": 0.5
            })
        elif self.sensory_type == "intuitive":
            props.update({
                "certainty": 0.5,
                "direction": "neutral",
                "urgency": 0.3,
                "clarity": 0.4,
                "source": "unknown"
            })
            
        return props
        
    def update(self, dt: float) -> None:
        """Update sensory input state"""
        # Apply decay to intensity
        self.intensity *= (1.0 - self.decay_rate * dt)
        
        # Update duration
        self.duration += dt
        
        # Deactivate if intensity too low
        if self.intensity < 0.05:
            self.properties["active"] = False
            
    def apply_reason(self, reason_type: str, strength: float) -> None:
        """Apply reasoning to this sensory input"""
        if not CONFIG["reason_integration"]:
            return
            
        # Find matching reason category
        category_match = False
        for category in CONFIG["reason_categories"]:
            if category in reason_type.lower():
                category_match = True
                break
                
        # Apply reason score
        base_score = 0.3 if category_match else 0.1
        reason_factor = CONFIG["reason_amplification"]
        
        # Calculate reason score
        self.reason_score = min(1.0, self.reason_score + (base_score * strength * reason_factor))
        
        # Reason increases stability
        stability_increase = 0.1 * strength * reason_factor
        self.properties["stability"] = min(1.0, self.properties["stability"] + stability_increase)
        
        # Add reason tag if not present
        reason_tag = f"#{reason_type.lower()}"
        if reason_tag not in self.tags:
            self.tags.append(reason_tag)
            
    def calculate_harmony(self, other_inputs: List['SensoryInput']) -> None:
        """Calculate harmony with other sensory inputs"""
        if not other_inputs:
            return
            
        # Start with base harmony score
        harmony = 0.5
        
        # Check each other input for compatibility
        compatible_count = 0
        for other in other_inputs:
            # Skip self
            if other is self:
                continue
                
            # Skip inactive inputs
            if not other.properties.get("active", False):
                continue
                
            # Check if types are complementary
            complementary = False
            if (self.sensory_type == "visual" and other.sensory_type == "auditory") or \
               (self.sensory_type == "taste" and other.sensory_type == "smell") or \
               (self.sensory_type == "touch" and other.sensory_type == "proprioceptive"):
                complementary = True
                
            # Check if content is related
            content_related = False
            if self.content and other.content:
                # Simple word overlap check
                self_words = set(self.content.lower().split())
                other_words = set(other.content.lower().split())
                overlap = len(self_words.intersection(other_words))
                
                if overlap > 0:
                    content_related = True
                    
            # Check tag overlap
            tag_overlap = len(set(self.tags).intersection(set(other.tags)))
            
            # Combine factors
            if complementary:
                harmony += 0.15
            if content_related:
                harmony += 0.1
            if tag_overlap > 0:
                harmony += 0.05 * tag_overlap
                
            # Count compatible inputs
            if complementary or content_related or tag_overlap > 0:
                compatible_count += 1
                
        # Adjust harmony based on compatible inputs
        if compatible_count > 0:
            # Normalize to 0-1 range
            harmony = min(1.0, harmony)
            
            # Apply smoothing with current harmony score (70% new, 30% current)
            self.harmony_score = (0.7 * harmony) + (0.3 * self.harmony_score)
        
    def get_stability(self) -> float:
        """Get the current stability value"""
        return self.properties["stability"]
        
    def extract_words(self) -> List[str]:
        """Extract significant words from content"""
        if not self.content:
            return []
            
        # Split content into words
        words = self.content.lower().split()
        
        # Filter out common words
        common_words = {"the", "and", "a", "an", "of", "to", "in", "for", "on", "is", "are", "be", "that", "this"}
        filtered_words = [word for word in words if word not in common_words and len(word) > 2]
        
        # Store associated words
        self.associated_words = filtered_words
        
        return filtered_words
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "sensory_type": self.sensory_type,
            "intensity": self.intensity,
            "content": self.content,
            "source": self.source,
            "timestamp": self.timestamp,
            "duration": self.duration,
            "processed": self.processed,
            "associated_words": self.associated_words,
            "tags": self.tags,
            "harmony_score": self.harmony_score,
            "reason_score": self.reason_score,
            "properties": self.properties
        }
        
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'SensoryInput':
        """Create sensory input from dictionary"""
        sensory_input = cls(
            sensory_type=data["sensory_type"],
            intensity=data["intensity"],
            content=data["content"],
            source=data["source"]
        )
        
        sensory_input.timestamp = data["timestamp"]
        sensory_input.duration = data["duration"]
        sensory_input.processed = data["processed"]
        sensory_input.associated_words = data["associated_words"]
        sensory_input.tags = data["tags"]
        sensory_input.harmony_score = data["harmony_score"]
        sensory_input.reason_score = data["reason_score"]
        sensory_input.properties = data["properties"]
        
        return sensory_input

class SensoryConnection:
    """Connection between sensory inputs"""
    
    def __init__(self,
                source: SensoryInput,
                target: SensoryInput,
                strength: float = 0.5,
                connection_type: str = "association"):
        self.source = source
        self.target = target
        self.strength = strength
        self.connection_type = connection_type
        self.creation_time = time.time()
        self.active = True
        self.reason_tags: List[str] = []
        self.stability_contribution = 0.0
        
    def update(self, dt: float) -> None:
        """Update connection"""
        # Apply decay
        self.strength *= (1.0 - CONFIG["stability_decay_rate"] * dt)
        
        # Deactivate if strength too low
        if self.strength < 0.1:
            self.active = False
            
    def calculate_stability_contribution(self) -> float:
        """Calculate how much this connection contributes to stability"""
        # Base contribution from strength
        contribution = self.strength * 0.3
        
        # Adjust based on harmony
        harmony = min(self.source.harmony_score, self.target.harmony_score)
        contribution += harmony * 0.3
        
        # Adjust based on reason score
        reason = max(self.source.reason_score, self.target.reason_score)
        contribution += reason * 0.4
        
        # Store and return
        self.stability_contribution = contribution
        return contribution
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "source": id(self.source),  # Use object ID as reference
            "target": id(self.target),  # Use object ID as reference
            "strength": self.strength,
            "connection_type": self.connection_type,
            "creation_time": self.creation_time,
            "active": self.active,
            "reason_tags": self.reason_tags,
            "stability_contribution": self.stability_contribution
        }

class SensoryLayer:
    """Represents a layer of sensory integration"""
    
    def __init__(self, layer_id: int, name: str = ""):
        self.layer_id = layer_id
        self.name = name or f"Layer {layer_id}"
        self.inputs: List[SensoryInput] = []
        self.connections: List[SensoryConnection] = []
        self.creation_time = time.time()
        self.stability = 0.5
        self.active = True
        self.processing_status = "idle"  # idle, processing, stable, unstable
        self.dominant_sensory_type = None
        self.integration_level = 0.0
        self.last_update = time.time()
        self.reason_integration = 0.0
        self.associated_turn = None  # For turns integration
        
    def add_input(self, input_obj: SensoryInput) -> bool:
        """Add a sensory input to this layer"""
        # Add to inputs list
        self.inputs.append(input_obj)
        
        # Connect to existing inputs with similar content
        self._create_connections(input_obj)
        
        # Extract words if not done already
        if not input_obj.associated_words:
            input_obj.extract_words()
            
        # Update dominant sensory type
        self._update_dominant_sensory_type()
        
        # Return success
        return True
        
    def _create_connections(self, new_input: SensoryInput) -> None:
        """Create connections between new input and existing inputs"""
        for existing in self.inputs:
            # Skip self
            if existing is new_input:
                continue
                
            # Check for word association
            association_strength = 0.0
            
            # Words in common
            new_words = set(new_input.associated_words)
            existing_words = set(existing.associated_words)
            common_words = new_words.intersection(existing_words)
            
            if common_words:
                # Strength based on number of common words
                association_strength = min(0.9, 0.2 + (len(common_words) * 0.1))
                
                # Create connection if strong enough
                if association_strength > 0.3:
                    connection = SensoryConnection(
                        existing,
                        new_input,
                        strength=association_strength,
                        connection_type="word_association"
                    )
                    
                    # Add to connections list
                    self.connections.append(connection)
                    
                    # Add to input connections
                    existing.connections.append(connection)
                    new_input.connections.append(connection)
                    
            # Check for sensory complementarity
            if self._are_complementary(existing.sensory_type, new_input.sensory_type):
                # Create complementary connection
                connection = SensoryConnection(
                    existing,
                    new_input,
                    strength=0.6,
                    connection_type="complementary"
                )
                
                # Add to connections list
                self.connections.append(connection)
                
                # Add to input connections
                existing.connections.append(connection)
                new_input.connections.append(connection)
                
    def _are_complementary(self, type1: str, type2: str) -> bool:
        """Check if two sensory types are complementary"""
        complementary_pairs = [
            ("visual", "auditory"),
            ("taste", "smell"),
            ("touch", "proprioceptive")
        ]
        
        return (type1, type2) in complementary_pairs or (type2, type1) in complementary_pairs
        
    def _update_dominant_sensory_type(self) -> None:
        """Update the dominant sensory type in this layer"""
        if not self.inputs:
            self.dominant_sensory_type = None
            return
            
        # Count by type
        type_counts = {}
        for input_obj in self.inputs:
            sensory_type = input_obj.sensory_type
            type_counts[sensory_type] = type_counts.get(sensory_type, 0) + 1
            
        # Find dominant type
        dominant_type = max(type_counts.items(), key=lambda x: x[1])[0]
        self.dominant_sensory_type = dominant_type
        
    def update(self, dt: float) -> None:
        """Update layer state"""
        # Update inputs
        for input_obj in self.inputs:
            input_obj.update(dt)
            
        # Update connections
        active_connections = []
        for connection in self.connections:
            connection.update(dt)
            
            # Keep only active connections
            if connection.active:
                active_connections.append(connection)
                
        self.connections = active_connections
        
        # Remove inactive inputs
        self.inputs = [input_obj for input_obj in self.inputs if input_obj.properties.get("active", False)]
        
        # Calculate harmony scores
        for input_obj in self.inputs:
            input_obj.calculate_harmony(self.inputs)
            
        # Calculate stability
        self._calculate_stability()
        
        # Calculate integration level
        self._calculate_integration_level()
        
        # Update processing status
        self._update_processing_status()
        
        # Track last update time
        self.last_update = time.time()
        
    def _calculate_stability(self) -> None:
        """Calculate layer stability"""
        if not self.inputs:
            self.stability = 0.5  # Default middle value
            return
            
        # Average input stability
        input_stability = sum(i.get_stability() for i in self.inputs) / len(self.inputs)
        
        # Connection contribution
        connection_contribution = 0.0
        if self.connections:
            # Calculate stability contribution for each connection
            connection_stability = sum(c.calculate_stability_contribution() for c in self.connections)
            connection_contribution = min(0.5, connection_stability / len(self.connections))
            
        # Reason integration contribution
        reason_contribution = self.reason_integration * 0.2
        
        # Combined stability with weights
        stability = (
            (input_stability * 0.4) + 
            (connection_contribution * 0.4) + 
            (reason_contribution * 0.2)
        )
        
        # Smooth with current stability (80% new, 20% current)
        self.stability = (stability * 0.8) + (self.stability * 0.2)
        
    def _calculate_integration_level(self) -> None:
        """Calculate sensory integration level"""
        if not self.inputs:
            self.integration_level = 0.0
            return
            
        # Count active connections relative to possible connections
        possible_connections = (len(self.inputs) * (len(self.inputs) - 1)) / 2
        
        if possible_connections == 0:
            self.integration_level = 0.0
            return
            
        # Calculate integration level
        integration = len(self.connections) / possible_connections
        
        # Adjust based on stability
        integration *= (0.5 + self.stability * 0.5)
        
        # Adjust based on reason integration
        integration *= (0.8 + self.reason_integration * 0.2)
        
        # Store integration level
        self.integration_level = min(1.0, integration)
        
    def _update_processing_status(self) -> None:
        """Update the processing status based on stability"""
        if len(self.inputs) < 2:
            self.processing_status = "idle"
        elif self.stability >= CONFIG["stability_threshold"]:
            self.processing_status = "stable"
        elif self.stability <= 0.3:
            self.processing_status = "unstable"
        else:
            self.processing_status = "processing"
            
    def apply_reasoning(self, reason_type: str, strength: float = 0.5) -> None:
        """Apply reasoning to this layer"""
        if not CONFIG["reason_integration"]:
            return
            
        # Apply to all inputs
        for input_obj in self.inputs:
            input_obj.apply_reason(reason_type, strength)
            
        # Apply to layer reason integration
        self.reason_integration = min(1.0, self.reason_integration + (strength * 0.3))
        
    def associate_with_turn(self, turn_index: int) -> None:
        """Associate this layer with a turn in the twelve turns system"""
        if not CONFIG["turns_integration"]:
            return
            
        self.associated_turn = turn_index
        
    def get_dominant_words(self, count: int = 5) -> List[str]:
        """Get the most dominant words in this layer"""
        if not self.inputs:
            return []
            
        # Collect all words with their count
        word_counts = {}
        for input_obj in self.inputs:
            for word in input_obj.associated_words:
                word_counts[word] = word_counts.get(word, 0) + 1
                
        # Sort by count
        sorted_words = sorted(word_counts.items(), key=lambda x: x[1], reverse=True)
        
        # Return top words
        return [word for word, _ in sorted_words[:count]]
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "layer_id": self.layer_id,
            "name": self.name,
            "inputs": [input_obj.to_dict() for input_obj in self.inputs],
            "creation_time": self.creation_time,
            "stability": self.stability,
            "active": self.active,
            "processing_status": self.processing_status,
            "dominant_sensory_type": self.dominant_sensory_type,
            "integration_level": self.integration_level,
            "reason_integration": self.reason_integration,
            "associated_turn": self.associated_turn,
            "dominant_words": self.get_dominant_words()
        }

class SensoryLayerSystem:
    """Main system for managing sensory layers"""
    
    def __init__(self):
        # System state
        self.running = False
        self.layers: List[SensoryLayer] = []
        self.current_layer_index = 0
        self.integration_thread = None
        self.last_update = time.time()
        self.last_save = time.time()
        self.stats = {
            "inputs_processed": 0,
            "connections_created": 0,
            "reasons_applied": 0,
            "stable_layers": 0,
            "harmony_achieved": 0
        }
        
        # Initialize layers
        self._init_layers()
        
    def _init_layers(self) -> None:
        """Initialize sensory layers"""
        self.layers = []
        
        for i in range(CONFIG["layer_count"]):
            # Create layer with name
            layer = SensoryLayer(i, f"Layer {i}")
            
            # Associate with turn if available
            if CONFIG["turns_integration"]:
                turn_index = i % CONFIG["turn_count"]
                layer.associate_with_turn(turn_index)
                
            # Add to layers list
            self.layers.append(layer)
            
        # Set current layer
        self.current_layer_index = 0
        
    def start(self) -> bool:
        """Start the sensory layer system"""
        if self.running:
            return True  # Already running
            
        # Set running flag
        self.running = True
        
        # Start integration thread
        self.integration_thread = threading.Thread(target=self._integration_thread)
        self.integration_thread.daemon = True
        self.integration_thread.start()
        
        return True
        
    def stop(self) -> None:
        """Stop the sensory layer system"""
        self.running = False
        
        # Wait for thread to end
        if self.integration_thread:
            self.integration_thread.join(timeout=1.0)
            
        # Save state before exiting
        self._save_state()
        
    def _integration_thread(self) -> None:
        """Thread for sensory integration"""
        last_integration = time.time()
        
        while self.running:
            current_time = time.time()
            
            # Calculate time delta
            dt = current_time - self.last_update
            
            # Update layers
            for layer in self.layers:
                layer.update(dt)
                
            # Run integration cycle periodically
            if current_time - last_integration >= CONFIG["integration_interval"]:
                self._run_integration_cycle()
                last_integration = current_time
                
            # Save state periodically
            if current_time - self.last_save >= CONFIG["save_interval"]:
                self._save_state()
                self.last_save = current_time
                
            # Update statistics
            self._update_statistics()
            
            # Track last update time
            self.last_update = current_time
            
            # Sleep to reduce CPU usage
            time.sleep(0.05)
            
    def _run_integration_cycle(self) -> None:
        """Run a sensory integration cycle"""
        # Check for harmony between layers
        self._check_harmony()
        
        # Apply reason to stable layers
        self._apply_reason_to_stable()
        
        # Update current layer index
        self.current_layer_index = (self.current_layer_index + 1) % len(self.layers)
        
    def _check_harmony(self) -> None:
        """Check for harmony between layers"""
        harmonious_layers = []
        
        # Check each layer's stability
        for layer in self.layers:
            if layer.stability >= CONFIG["harmony_threshold"]:
                harmonious_layers.append(layer)
                
        # If enough harmonious layers, record harmony achievement
        if len(harmonious_layers) >= 3:  # Arbitrary threshold
            self.stats["harmony_achieved"] += 1
            
    def _apply_reason_to_stable(self) -> None:
        """Apply reasoning to stable layers"""
        if not CONFIG["reason_integration"]:
            return
            
        # Find stable layers
        stable_layers = [layer for layer in self.layers 
                        if layer.stability >= CONFIG["stability_threshold"]]
        
        # Skip if no stable layers
        if not stable_layers:
            return
            
        # Apply random reason from categories
        reason_type = random.choice(CONFIG["reason_categories"])
        strength = random.uniform(0.4, 0.8)
        
        for layer in stable_layers:
            layer.apply_reasoning(reason_type, strength)
            
        # Update stats
        self.stats["reasons_applied"] += 1
        
    def _update_statistics(self) -> None:
        """Update system statistics"""
        # Count stable layers
        stable_layers = sum(1 for layer in self.layers 
                           if layer.stability >= CONFIG["stability_threshold"])
        self.stats["stable_layers"] = stable_layers
        
    def add_sensory_input(self, 
                         sensory_type: str, 
                         content: str, 
                         intensity: float = 0.5,
                         layer_index: Optional[int] = None,
                         source: str = "system") -> bool:
        """Add a sensory input to the system"""
        # Validate sensory type
        if sensory_type not in CONFIG["sensory_types"]:
            return False
            
        # Create sensory input
        input_obj = SensoryInput(sensory_type, intensity, content, source)
        
        # Extract words
        input_obj.extract_words()
        
        # Determine layer index
        if layer_index is None:
            layer_index = self.current_layer_index
            
        # Validate layer index
        if layer_index < 0 or layer_index >= len(self.layers):
            return False
            
        # Add to layer
        success = self.layers[layer_index].add_input(input_obj)
        
        # Update stats on success
        if success:
            self.stats["inputs_processed"] += 1
            
        return success
        
    def add_word_input(self, word: str, intensity: float = 0.5) -> bool:
        """Add a word as sensory input with automatic type mapping"""
        if not CONFIG["word_sensory_mapping"] or not word:
            return False
            
        # Map word to sensory type based on simple heuristics
        sensory_type = "intuitive"  # Default
        
        # Visual words
        visual_words = {"see", "look", "watch", "color", "bright", "dark", "light", "image", "picture"}
        # Auditory words
        auditory_words = {"hear", "sound", "noise", "listen", "loud", "quiet", "voice", "music", "word"}
        # Taste words
        taste_words = {"taste", "flavor", "sweet", "sour", "bitter", "salty", "food", "eat", "drink"}
        # Touch words
        touch_words = {"touch", "feel", "soft", "hard", "rough", "smooth", "hot", "cold", "texture"}
        # Smell words
        smell_words = {"smell", "scent", "odor", "aroma", "fragrance", "stink", "fresh", "musty"}
        
        # Check word against each sensory type
        word_lower = word.lower()
        
        for w in visual_words:
            if w in word_lower:
                sensory_type = "visual"
                break
                
        for w in auditory_words:
            if w in word_lower:
                sensory_type = "auditory"
                break
                
        for w in taste_words:
            if w in word_lower:
                sensory_type = "taste"
                break
                
        for w in touch_words:
            if w in word_lower:
                sensory_type = "touch"
                break
                
        for w in smell_words:
            if w in word_lower:
                sensory_type = "smell"
                break
                
        # Add as sensory input
        return self.add_sensory_input(sensory_type, word, intensity)
        
    def process_text(self, text: str) -> List[str]:
        """Process text into sensory inputs"""
        if not text:
            return []
            
        # Split into words
        words = text.split()
        
        # Filter out common words
        common_words = {"the", "and", "a", "an", "of", "to", "in", "for", "on", "is", "are", "be"}
        significant_words = [word for word in words if word.lower() not in common_words and len(word) > 2]
        
        # Process each significant word
        processed_words = []
        for word in significant_words:
            # Add with random intensity
            intensity = random.uniform(0.4, 0.9)
            if self.add_word_input(word, intensity):
                processed_words.append(word)
                
        return processed_words
        
    def apply_reason_tag(self, tag: str, layer_index: Optional[int] = None) -> bool:
        """Apply a reason tag to a layer"""
        # Skip if not enabled
        if not CONFIG["reason_integration"]:
            return False
            
        # Determine layer index
        if layer_index is None:
            layer_index = self.current_layer_index
            
        # Validate layer index
        if layer_index < 0 or layer_index >= len(self.layers):
            return False
            
        # Extract reason type
        reason_type = tag.strip("#").lower()
        
        # Apply reasoning with medium strength
        self.layers[layer_index].apply_reasoning(reason_type, 0.6)
        
        # Update stats
        self.stats["reasons_applied"] += 1
        
        return True
        
    def _save_state(self) -> None:
        """Save system state to file"""
        try:
            state = {
                "timestamp": datetime.now().isoformat(),
                "layers": [layer.to_dict() for layer in self.layers],
                "current_layer_index": self.current_layer_index,
                "stats": self.stats
            }
            
            with open("sensory_layer_state.json", "w") as f:
                json.dump(state, f, indent=2)
                
            if CONFIG["debug_mode"]:
                print(f"Sensory layer state saved at {datetime.now().isoformat()}")
                
        except Exception as e:
            if CONFIG["debug_mode"]:
                print(f"Error saving sensory layer state: {e}")
                
    def get_layer_visualization(self, layer_index: Optional[int] = None) -> str:
        """Generate a visualization of a layer"""
        # Determine layer index
        if layer_index is None:
            layer_index = self.current_layer_index
            
        # Validate layer index
        if layer_index < 0 or layer_index >= len(self.layers):
            return "Invalid layer index"
            
        # Get layer
        layer = self.layers[layer_index]
        
        # Build visualization
        result = []
        result.append(f"LAYER {layer.name}")
        result.append("=" * len(f"LAYER {layer.name}"))
        result.append(f"Status: {layer.processing_status}  Stability: {layer.stability:.2f}  Integration: {layer.integration_level:.2f}")
        result.append(f"Dominant Type: {layer.dominant_sensory_type or 'None'}")
        result.append(f"Inputs: {len(layer.inputs)}  Connections: {len(layer.connections)}")
        
        # Show dominant words
        dominant_words = layer.get_dominant_words()
        if dominant_words:
            result.append(f"Dominant Words: {', '.join(dominant_words)}")
            
        # Show inputs
        if layer.inputs:
            result.append("\nSENSORY INPUTS:")
            for i, input_obj in enumerate(layer.inputs):
                # Show input with basic info
                input_line = f"{i+1}. {input_obj.sensory_type} ({input_obj.intensity:.2f}): {input_obj.content}"
                result.append(input_line)
                
                # Show tags if present
                if input_obj.tags:
                    result.append(f"   Tags: {' '.join(input_obj.tags)}")
                    
        # Show turn association if enabled
        if CONFIG["turns_integration"] and layer.associated_turn is not None:
            result.append(f"\nAssociated with Turn: {layer.associated_turn + 1}")
            
        return "\n".join(result)
        
    def get_system_visualization(self) -> str:
        """Generate a visualization of the entire system"""
        result = []
        result.append("SENSORY LAYER SYSTEM")
        result.append("===================")
        
        # System status
        result.append(f"Layers: {len(self.layers)}  Current: {self.current_layer_index + 1}")
        result.append(f"Stable Layers: {self.stats['stable_layers']}/{len(self.layers)}")
        result.append(f"Harmony Achievements: {self.stats['harmony_achieved']}")
        result.append(f"Inputs Processed: {self.stats['inputs_processed']}")
        result.append(f"Reasons Applied: {self.stats['reasons_applied']}")
        
        # Layer summary
        result.append("\nLAYER SUMMARY:")
        for i, layer in enumerate(self.layers):
            # Create status indicator
            if layer.processing_status == "stable":
                status = "✓"
            elif layer.processing_status == "unstable":
                status = "✗"
            elif layer.processing_status == "processing":
                status = "⟳"
            else:
                status = "-"
                
            # Create summary line
            current = ">" if i == self.current_layer_index else " "
            summary = f"{current} Layer {i+1}: {status} {layer.processing_status.capitalize()} - "
            summary += f"Stability: {layer.stability:.2f} - Type: {layer.dominant_sensory_type or 'None'}"
            
            result.append(summary)
            
        # Show current layer details
        result.append("\nCURRENT LAYER DETAILS:")
        result.append(self.get_layer_visualization(self.current_layer_index))
        
        return "\n".join(result)
        
    def integrate_with_turns(self, turns_system) -> bool:
        """Integrate with Twelve Turns System"""
        if not CONFIG["turns_integration"] or not TURNS_AVAILABLE:
            return False
            
        # Check if turns system has necessary attributes
        if not hasattr(turns_system, "current_turn_index") or not hasattr(turns_system, "turns"):
            return False
            
        # Associate each layer with a turn
        for i, layer in enumerate(self.layers):
            turn_index = i % len(turns_system.turns)
            layer.associate_with_turn(turn_index)
            
        return True

def main():
    """Main function for testing the Sensory Layer System"""
    print("Initializing Sensory Layer System...")
    system = SensoryLayerSystem()
    
    # Start the system
    system.start()
    
    print("\nSensory Layer System started")
    print("- Type 'quit' or 'exit' to stop")
    print("- Type 'status' to show system status")
    print("- Type 'layer N' to show details of layer N")
    print("- Type 'reason TAG' to apply a reason tag to current layer")
    print("- Type 'add TYPE CONTENT' to add a sensory input")
    print("- Type anything else to process as text input")
    
    # Main loop
    try:
        while system.running:
            command = input("> ").strip()
            
            if command.lower() in ["quit", "exit"]:
                break
            elif command.lower() == "status":
                print("\n" + system.get_system_visualization())
            elif command.lower().startswith("layer "):
                # Extract layer number
                try:
                    layer_num = int(command.split()[1]) - 1
                    print("\n" + system.get_layer_visualization(layer_num))
                except (ValueError, IndexError):
                    print("Invalid layer number")
            elif command.lower().startswith("reason "):
                # Extract reason tag
                tag = command.split()[1]
                if not tag.startswith("#"):
                    tag = "#" + tag
                system.apply_reason_tag(tag)
                print(f"Applied reason tag {tag} to current layer")
            elif command.lower().startswith("add "):
                # Extract type and content
                parts = command.split(maxsplit=2)
                if len(parts) < 3:
                    print("Invalid format. Use: add TYPE CONTENT")
                    continue
                    
                sensory_type = parts[1].lower()
                content = parts[2]
                
                if sensory_type not in CONFIG["sensory_types"]:
                    print(f"Invalid sensory type. Valid types: {', '.join(CONFIG['sensory_types'])}")
                    continue
                    
                # Add sensory input
                system.add_sensory_input(sensory_type, content)
                print(f"Added {sensory_type} input: {content}")
            else:
                # Process as text
                words = system.process_text(command)
                print(f"Processed {len(words)} words as sensory input")
                
            # Update system
            time.sleep(0.1)
            
    except KeyboardInterrupt:
        print("\nExiting...")
    finally:
        # Stop system
        system.stop()
        print("Sensory Layer System stopped")

if __name__ == "__main__":
    main()