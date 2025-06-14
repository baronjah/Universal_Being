#!/usr/bin/env python3
# Shape Visualizer - Creates 3D shapes and pattern-based visualizations
# Integrates with eye tracking and wish_console systems

import os
import sys
import time
import json
import random
import math
import threading
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple, Set, Union

# Check for optional dependencies
try:
    import numpy as np
    NUMPY_AVAILABLE = True
except ImportError:
    NUMPY_AVAILABLE = False

# Constants
CONFIG = {
    "offline_mode": True,           # Work without external dependencies
    "shape_dimensions": 3,          # 2D or 3D shapes
    "max_shapes": 89,               # Maximum shapes to render
    "base_shapes": ["square", "rectangle", "triangle", "circle", "pentagon", "hexagon"],
    "pattern_sequence": [0, 3, 4, 2, 1],  # Base numerical pattern
    "emoji_support": True,          # Use emoji for visualization
    "eye_tracking_integration": True,  # Integrate with eye tracking
    "connection_strength": 29,      # Connection strength parameter (1-100)
    "update_interval": 0.1,         # Seconds between updates
    "growth_direction": 7,          # Primary growth direction (1-8)
    "self_check_interval": 5.0,     # Seconds between self checks
    "debug_mode": False,            # Show debug information
    "whim_probability": 0.15,       # Probability of introducing a whim/variation
    "shape_color_map": {            # Color mapping for shapes
        "square": "#3498db",        # Blue
        "rectangle": "#2ecc71",     # Green
        "triangle": "#e74c3c",      # Red
        "circle": "#f39c12",        # Orange
        "pentagon": "#9b59b6",      # Purple
        "hexagon": "#1abc9c"        # Teal
    }
}

# Offline emoji mapping
EMOJI_MAP = {
    "square": "🟦",
    "rectangle": "🟩",
    "triangle": "🔺",
    "circle": "🔵",
    "pentagon": "🔹",
    "hexagon": "🔷",
    "connection": "➖",
    "connection_v": "│",
    "connection_d1": "╱",
    "connection_d2": "╲",
    "growth": "↗",
    "whim": "✨",
    "eye": "👁️",
    "hair": "〰️",
    "power": "⚡",
    "check": "✓",
    "error": "✗",
    "pattern": ["⓪", "①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨"],
    "empty": "⬜"
}

class ShapeProperties:
    """Properties of a shape in the system"""
    
    def __init__(self, 
                shape_type: str, 
                position: Tuple[float, float, float] = (0, 0, 0),
                size: float = 1.0,
                rotation: Tuple[float, float, float] = (0, 0, 0),
                color: str = "#FFFFFF"):
        self.shape_type = shape_type
        self.position = position
        self.size = size
        self.rotation = rotation
        self.color = color
        self.creation_time = time.time()
        self.properties = {}
        self.connected_shapes = []
        self.pattern_value = random.choice(CONFIG["pattern_sequence"])
        self.growth_factor = 1.0
        self.energy = random.uniform(0.5, 1.0)
        self.visible = True
        self.highlight = False
        self.whim_affected = False
        self.self_checked = False
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert shape properties to dictionary"""
        return {
            "shape_type": self.shape_type,
            "position": self.position,
            "size": self.size,
            "rotation": self.rotation,
            "color": self.color,
            "creation_time": self.creation_time,
            "properties": self.properties,
            "connected_shapes": [s.shape_type for s in self.connected_shapes],
            "pattern_value": self.pattern_value,
            "growth_factor": self.growth_factor,
            "energy": self.energy,
            "visible": self.visible,
            "highlight": self.highlight,
            "whim_affected": self.whim_affected,
            "self_checked": self.self_checked
        }
        
    def connect_to(self, other: 'ShapeProperties') -> None:
        """Connect this shape to another shape"""
        if other not in self.connected_shapes:
            self.connected_shapes.append(other)
            
    def grow(self, direction: int = None, amount: float = 0.1) -> None:
        """Grow the shape in the specified direction"""
        if direction is None:
            direction = CONFIG["growth_direction"]
            
        self.size += amount * self.growth_factor
        
        # Adjust position based on growth direction
        x, y, z = self.position
        
        if direction == 1:  # Up
            y += amount * 0.5
        elif direction == 2:  # Right
            x += amount * 0.5
        elif direction == 3:  # Down
            y -= amount * 0.5
        elif direction == 4:  # Left
            x -= amount * 0.5
        elif direction == 5:  # Up-Right
            x += amount * 0.35
            y += amount * 0.35
        elif direction == 6:  # Down-Right
            x += amount * 0.35
            y -= amount * 0.35
        elif direction == 7:  # Down-Left
            x -= amount * 0.35
            y -= amount * 0.35
        elif direction == 8:  # Up-Left
            x -= amount * 0.35
            y += amount * 0.35
        
        self.position = (x, y, z)
        
    def apply_whim(self) -> None:
        """Apply a random whim/variation to the shape"""
        whim_type = random.choice(["color", "size", "rotation", "energy", "pattern"])
        
        if whim_type == "color":
            # Slightly adjust color
            self.color = self._adjust_color(self.color)
        elif whim_type == "size":
            # Random size adjustment
            self.size *= random.uniform(0.8, 1.2)
        elif whim_type == "rotation":
            # Random rotation
            rx, ry, rz = self.rotation
            self.rotation = (
                rx + random.uniform(-30, 30),
                ry + random.uniform(-30, 30),
                rz + random.uniform(-30, 30)
            )
        elif whim_type == "energy":
            # Change energy level
            self.energy = min(1.0, max(0.1, self.energy + random.uniform(-0.2, 0.2)))
        elif whim_type == "pattern":
            # Change pattern value
            self.pattern_value = random.choice(CONFIG["pattern_sequence"])
            
        self.whim_affected = True
        
    def _adjust_color(self, color: str) -> str:
        """Adjust a hex color slightly"""
        if not color.startswith('#') or len(color) != 7:
            return color
            
        # Convert to RGB
        r = int(color[1:3], 16)
        g = int(color[3:5], 16)
        b = int(color[5:7], 16)
        
        # Adjust each component
        r = max(0, min(255, r + random.randint(-20, 20)))
        g = max(0, min(255, g + random.randint(-20, 20)))
        b = max(0, min(255, b + random.randint(-20, 20)))
        
        # Convert back to hex
        return f"#{r:02x}{g:02x}{b:02x}"
        
    def self_check(self) -> bool:
        """Perform a self-check on the shape"""
        # Check if shape is valid
        valid = (
            self.size > 0 and
            self.energy > 0 and
            self.shape_type in CONFIG["base_shapes"]
        )
        
        self.self_checked = True
        return valid

class ConnectionProperties:
    """Properties of a connection between shapes"""
    
    def __init__(self,
                source: ShapeProperties,
                target: ShapeProperties,
                strength: float = 0.5,
                connection_type: str = "default"):
        self.source = source
        self.target = target
        self.strength = strength
        self.connection_type = connection_type
        self.creation_time = time.time()
        self.active = True
        self.energy_transfer = 0.0
        self.growth_enabled = False
        self.hair_connection = False  # Special connection type
        self.channel_capacity = strength * 10  # Max energy transfer
        
    def transfer_energy(self) -> float:
        """Transfer energy from source to target"""
        if not self.active:
            return 0.0
            
        # Calculate energy transfer amount
        available = self.source.energy * 0.1  # 10% of source energy
        capacity = self.channel_capacity * 0.01  # Percentage of capacity
        transfer = min(available, capacity)
        
        # Apply transfer
        if transfer > 0.01:  # Minimum threshold
            self.source.energy -= transfer
            self.target.energy = min(1.0, self.target.energy + transfer * 0.9)  # 10% loss in transfer
            self.energy_transfer = transfer
            return transfer
            
        return 0.0
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert connection properties to dictionary"""
        return {
            "source": id(self.source),  # Use object ID as reference
            "target": id(self.target),  # Use object ID as reference
            "strength": self.strength,
            "connection_type": self.connection_type,
            "creation_time": self.creation_time,
            "active": self.active,
            "energy_transfer": self.energy_transfer,
            "growth_enabled": self.growth_enabled,
            "hair_connection": self.hair_connection,
            "channel_capacity": self.channel_capacity
        }

class ShapePattern:
    """Represents a pattern formed by multiple shapes"""
    
    def __init__(self, name: str, values: List[int] = None):
        self.name = name
        self.values = values or CONFIG["pattern_sequence"]
        self.shapes: List[ShapeProperties] = []
        self.creation_time = time.time()
        self.power = 1.0
        self.completion = 0.0
        self.self_check_passed = False
        
    def add_shape(self, shape: ShapeProperties) -> None:
        """Add a shape to the pattern"""
        self.shapes.append(shape)
        
        # Update completion percentage
        target_length = len(self.values)
        current_length = len(self.shapes)
        
        if target_length > 0:
            self.completion = min(1.0, current_length / target_length)
            
        # Check if pattern matches values
        if len(self.shapes) <= len(self.values):
            idx = len(self.shapes) - 1
            if idx >= 0 and self.shapes[idx].pattern_value != self.values[idx]:
                # If this shape's value doesn't match the expected value, adjust it
                self.shapes[idx].pattern_value = self.values[idx]
                
    def calculate_power(self) -> float:
        """Calculate the power of this pattern"""
        if not self.shapes:
            return 0.0
            
        # Power increases with completion percentage
        completion_power = self.completion * 2
        
        # Power increases with number of correct values
        correct_values = 0
        for i, shape in enumerate(self.shapes):
            if i < len(self.values) and shape.pattern_value == self.values[i]:
                correct_values += 1
                
        value_power = correct_values / max(1, len(self.values))
        
        # Combined power
        self.power = (completion_power + value_power) / 2
        return self.power
        
    def self_check(self) -> bool:
        """Perform a self-check on the pattern"""
        # Check if pattern has correct structure
        valid = (
            len(self.shapes) > 0 and
            self.completion > 0.0 and
            self.power > 0.0
        )
        
        self.self_check_passed = valid
        return valid
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert pattern to dictionary"""
        return {
            "name": self.name,
            "values": self.values,
            "shapes": [id(s) for s in self.shapes],  # References to shapes
            "creation_time": self.creation_time,
            "power": self.power,
            "completion": self.completion,
            "self_check_passed": self.self_check_passed
        }

class ShapeVisualizer:
    """Visualizes and manages 3D shapes and patterns"""
    
    def __init__(self):
        self.shapes: List[ShapeProperties] = []
        self.connections: List[ConnectionProperties] = []
        self.patterns: List[ShapePattern] = []
        self.running = False
        self.thread = None
        self.last_update = time.time()
        self.frames = 0
        self.eye_tracker = None
        self.focused_shape = None
        self.shape_id_counter = 1
        self.active_whims = []
        self.grid_width = 40
        self.grid_height = 20
        self.grid = [[' ' for _ in range(self.grid_width)] for _ in range(self.grid_height)]
        self.last_self_check = time.time()
        self.hair_growth_points = []  # Points where hair connections can grow
        self.emoji_mode = CONFIG["emoji_support"]
        self.offline_mode = CONFIG["offline_mode"]
        
        # Initialize with basic patterns
        self._init_basic_patterns()
        
    def _init_basic_patterns(self) -> None:
        """Initialize basic shape patterns"""
        # Create standard patterns
        self.patterns.append(ShapePattern("basic", [0, 3, 4, 2, 1]))
        self.patterns.append(ShapePattern("reversed", [1, 2, 4, 3, 0]))
        self.patterns.append(ShapePattern("binary", [0, 1, 0, 1, 0]))
        self.patterns.append(ShapePattern("fibonacci", [1, 1, 2, 3, 5]))
        self.patterns.append(ShapePattern("prime", [2, 3, 5, 7, 11]))
        
        # Create growing pattern
        growth_pattern = ShapePattern("growth", [0, 1, 2, 3, 4])
        
        # Create some initial shapes for the growth pattern
        for i in range(3):  # Start with 3 shapes
            shape_type = random.choice(CONFIG["base_shapes"])
            
            # Position with some randomness
            x = random.uniform(-5, 5)
            y = random.uniform(-5, 5)
            z = random.uniform(-1, 1)
            
            # Create shape
            shape = ShapeProperties(
                shape_type,
                position=(x, y, z),
                size=random.uniform(0.8, 1.2),
                color=CONFIG["shape_color_map"].get(shape_type, "#FFFFFF")
            )
            
            # Set pattern value
            shape.pattern_value = growth_pattern.values[i] if i < len(growth_pattern.values) else 0
            
            # Add to shapes list
            self.shapes.append(shape)
            
            # Add to pattern
            growth_pattern.add_shape(shape)
            
        # Connect shapes in the pattern
        for i in range(len(growth_pattern.shapes) - 1):
            self._create_connection(
                growth_pattern.shapes[i],
                growth_pattern.shapes[i + 1],
                strength=random.uniform(0.4, 0.8)
            )
            
        # Add pattern to list
        self.patterns.append(growth_pattern)
        
        # Create some hair growth points
        for _ in range(3):
            self.hair_growth_points.append({
                "position": (random.uniform(-5, 5), random.uniform(-5, 5), 0),
                "energy": random.uniform(0.5, 1.0),
                "growth_rate": random.uniform(0.05, 0.2),
                "connections": 0,
                "max_connections": random.randint(3, 8)
            })
            
    def _create_connection(self, 
                          source: ShapeProperties, 
                          target: ShapeProperties,
                          strength: float = 0.5,
                          connection_type: str = "default") -> ConnectionProperties:
        """Create a connection between two shapes"""
        conn = ConnectionProperties(source, target, strength, connection_type)
        
        # Update the shapes' connections
        source.connect_to(target)
        target.connect_to(source)
        
        # Add to connections list
        self.connections.append(conn)
        
        # Randomly make some connections special "hair" connections
        if random.random() < 0.2:  # 20% chance
            conn.hair_connection = True
            conn.connection_type = "hair"
            conn.channel_capacity *= 1.5  # Higher capacity
            
        return conn
        
    def start(self) -> bool:
        """Start the shape visualizer"""
        if self.running:
            return True  # Already running
            
        # Set running flag
        self.running = True
        
        # Create and start thread
        self.thread = threading.Thread(target=self._update_thread)
        self.thread.daemon = True
        self.thread.start()
        
        return True
        
    def stop(self) -> None:
        """Stop the shape visualizer"""
        self.running = False
        
        if self.thread:
            self.thread.join(timeout=1.0)
            
    def _update_thread(self) -> None:
        """Thread for updating shape visualization"""
        last_time = time.time()
        
        while self.running:
            # Calculate time delta
            current_time = time.time()
            dt = current_time - last_time
            last_time = current_time
            
            # Update system
            self._update(dt)
            
            # Self-check periodically
            if current_time - self.last_self_check >= CONFIG["self_check_interval"]:
                self._perform_self_check()
                self.last_self_check = current_time
                
            # Sleep to control update rate
            time.sleep(CONFIG["update_interval"])
            
    def _update(self, dt: float) -> None:
        """Update shape visualization state"""
        # Limit the number of shapes
        if len(self.shapes) > CONFIG["max_shapes"]:
            # Remove oldest shapes
            excess = len(self.shapes) - CONFIG["max_shapes"]
            self.shapes = self.shapes[excess:]
            
        # Update connections
        for conn in self.connections:
            conn.transfer_energy()
            
            # Apply growth if enabled
            if conn.growth_enabled and conn.active:
                growth_amt = conn.strength * 0.01 * dt
                conn.target.grow(amount=growth_amt)
                
            # Hair connections have special behavior
            if conn.hair_connection and random.random() < 0.2 * dt:
                # Hair connections occasionally spawn new connections
                if (len(self.connections) < 5 * len(self.shapes) and 
                    random.random() < 0.05):
                    # Find another shape to connect to
                    candidates = [s for s in self.shapes if s != conn.source and s != conn.target]
                    if candidates:
                        target = random.choice(candidates)
                        self._create_connection(
                            conn.target, 
                            target, 
                            strength=conn.strength * 0.8,
                            connection_type="hair_child"
                        )
                        
        # Update shapes
        for shape in self.shapes:
            # Apply energy decay
            shape.energy = max(0.1, shape.energy - 0.01 * dt)
            
            # Random growth
            if random.random() < 0.05 * dt:
                shape.grow(amount=0.02 * shape.energy)
                
            # Apply whims occasionally
            if random.random() < CONFIG["whim_probability"] * dt:
                shape.apply_whim()
                
                # Record active whim
                self.active_whims.append({
                    "shape": shape,
                    "time": time.time(),
                    "duration": random.uniform(1.0, 5.0)
                })
                
        # Update patterns
        for pattern in self.patterns:
            pattern.calculate_power()
            
        # Process hair growth points
        for point in self.hair_growth_points:
            # Grow energy
            point["energy"] = min(1.0, point["energy"] + point["growth_rate"] * dt)
            
            # Attempt to create new connections if energy is high enough
            if (point["energy"] > 0.8 and 
                point["connections"] < point["max_connections"] and
                random.random() < 0.1 * dt):
                
                # Find a nearby shape to connect to
                for shape in self.shapes:
                    # Calculate distance to shape
                    sx, sy, sz = shape.position
                    px, py, pz = point["position"]
                    
                    distance = math.sqrt((sx-px)**2 + (sy-py)**2 + (sz-pz)**2)
                    
                    # If close enough, create hair connection
                    if distance < 5.0:
                        # Create a new shape at the growth point
                        new_shape = ShapeProperties(
                            random.choice(CONFIG["base_shapes"]),
                            position=point["position"],
                            size=random.uniform(0.6, 1.0),
                            color=self._adjust_color(shape.color)
                        )
                        self.shapes.append(new_shape)
                        
                        # Create hair connection
                        conn = self._create_connection(
                            new_shape,
                            shape,
                            strength=point["energy"],
                            connection_type="hair_root"
                        )
                        conn.hair_connection = True
                        
                        # Update growth point
                        point["connections"] += 1
                        point["energy"] *= 0.5  # Reduce energy after connection
                        
                        # Add the new shape to a random pattern
                        if self.patterns:
                            pattern = random.choice(self.patterns)
                            pattern.add_shape(new_shape)
                            
                        break
                        
        # Process active whims
        current_time = time.time()
        remaining_whims = []
        
        for whim in self.active_whims:
            if current_time - whim["time"] < whim["duration"]:
                remaining_whims.append(whim)
            else:
                whim["shape"].whim_affected = False
                
        self.active_whims = remaining_whims
                
        # Create new shapes occasionally
        if random.random() < 0.05 * dt and len(self.shapes) < CONFIG["max_shapes"]:
            self._create_random_shape()
            
        # Update eye tracking integration
        self._update_eye_tracking()
        
        # Update frame counter
        self.frames += 1
        
    def _perform_self_check(self) -> None:
        """Perform a self-check on all objects"""
        # Check each shape
        for shape in self.shapes:
            shape.self_check()
            
        # Check each pattern
        for pattern in self.patterns:
            pattern.self_check()
            
        # Verify connections
        invalid_connections = []
        for i, conn in enumerate(self.connections):
            # Check if both shapes still exist
            if conn.source not in self.shapes or conn.target not in self.shapes:
                invalid_connections.append(i)
                
        # Remove invalid connections (in reverse order to preserve indices)
        for i in sorted(invalid_connections, reverse=True):
            del self.connections[i]
            
    def _update_eye_tracking(self) -> None:
        """Update integration with eye tracking"""
        # Skip if no eye tracker available
        if not self.eye_tracker:
            return
            
        # Get current eye state
        try:
            state = self.eye_tracker.get_current_state()
            focus_regions = self.eye_tracker.focus_regions
            
            # Skip if no meaningful data
            if not state or not hasattr(state, 'gaze_point'):
                return
                
            # Convert gaze point to 3D space
            gx, gy = state.gaze_point
            
            # Map to the shape space (-10 to 10 in x,y)
            space_x = (gx * 20) - 10
            space_y = 10 - (gy * 20)
            
            # Find closest shape to gaze
            closest_shape = None
            closest_dist = float('inf')
            
            for shape in self.shapes:
                sx, sy, sz = shape.position
                dist = math.sqrt((space_x - sx)**2 + (space_y - sy)**2)
                
                if dist < closest_dist:
                    closest_dist = dist
                    closest_shape = shape
                    
            # If we found a shape close enough to the gaze
            if closest_shape and closest_dist < 3.0:
                # Set as focused shape
                self.focused_shape = closest_shape
                closest_shape.highlight = True
                
                # Boost energy of focused shape
                closest_shape.energy = min(1.0, closest_shape.energy + 0.05)
                
                # Create gaze connection if focused long enough
                if hasattr(state, 'fixation_duration') and state.fixation_duration > 1.0:
                    # Find any pattern this shape belongs to
                    for pattern in self.patterns:
                        if closest_shape in pattern.shapes:
                            # Increase pattern power
                            pattern.power = min(1.0, pattern.power + 0.05)
                            break
            else:
                # Clear focus if no shape is gazed at
                if self.focused_shape:
                    self.focused_shape.highlight = False
                    self.focused_shape = None
                    
        except Exception as e:
            if CONFIG["debug_mode"]:
                print(f"Error in eye tracking update: {e}")
                
    def _create_random_shape(self) -> ShapeProperties:
        """Create a random shape"""
        # Select random shape type
        shape_type = random.choice(CONFIG["base_shapes"])
        
        # Random position
        x = random.uniform(-10, 10)
        y = random.uniform(-10, 10)
        z = random.uniform(-2, 2)
        
        # Create shape
        shape = ShapeProperties(
            shape_type,
            position=(x, y, z),
            size=random.uniform(0.5, 1.5),
            color=CONFIG["shape_color_map"].get(shape_type, "#FFFFFF")
        )
        
        # Set random pattern value
        shape.pattern_value = random.choice(CONFIG["pattern_sequence"])
        
        # Add to shapes list
        self.shapes.append(shape)
        
        # Randomly add to a pattern
        if self.patterns and random.random() < 0.3:
            pattern = random.choice(self.patterns)
            pattern.add_shape(shape)
            
        # Possibly connect to existing shapes
        if self.shapes and len(self.shapes) > 1:
            # Connect to random existing shape
            target = random.choice([s for s in self.shapes if s != shape])
            self._create_connection(
                shape,
                target,
                strength=random.uniform(0.3, 0.7)
            )
            
        return shape
        
    def _adjust_color(self, color: str) -> str:
        """Adjust a color slightly"""
        if not color.startswith('#') or len(color) != 7:
            return "#FFFFFF"
            
        # Convert to RGB
        r = int(color[1:3], 16)
        g = int(color[3:5], 16)
        b = int(color[5:7], 16)
        
        # Adjust each component
        r = max(0, min(255, r + random.randint(-20, 20)))
        g = max(0, min(255, g + random.randint(-20, 20)))
        b = max(0, min(255, b + random.randint(-20, 20)))
        
        # Convert back to hex
        return f"#{r:02x}{g:02x}{b:02x}"
    
    def get_visualization(self) -> str:
        """Generate ASCII visualization of the shapes"""
        # Clear grid
        self.grid = [[' ' for _ in range(self.grid_width)] for _ in range(self.grid_height)]
        
        # Draw shapes on grid
        for shape in self.shapes:
            # Map 3D position to 2D grid
            sx, sy, sz = shape.position
            
            # Map coordinates to grid coordinates
            grid_x = int((sx + 10) / 20 * self.grid_width)
            grid_y = int((10 - sy) / 20 * self.grid_height)
            
            # Make sure coordinates are in bounds
            grid_x = max(0, min(self.grid_width - 1, grid_x))
            grid_y = max(0, min(self.grid_height - 1, grid_y))
            
            # Choose character for shape
            if self.emoji_mode:
                char = EMOJI_MAP.get(shape.shape_type, "■")
            else:
                if shape.shape_type == "square":
                    char = "■"
                elif shape.shape_type == "rectangle":
                    char = "□"
                elif shape.shape_type == "triangle":
                    char = "▲"
                elif shape.shape_type == "circle":
                    char = "●"
                elif shape.shape_type == "pentagon":
                    char = "⬠"
                elif shape.shape_type == "hexagon":
                    char = "⬡"
                else:
                    char = "+"
                    
            # Add highlight for focused shape
            if shape.highlight:
                char = EMOJI_MAP.get("eye", "👁️") if self.emoji_mode else "*"
                
            # Draw shape on grid
            self.grid[grid_y][grid_x] = char
            
        # Draw connections
        for conn in self.connections:
            # Get grid positions of source and target
            sx, sy, sz = conn.source.position
            tx, ty, tz = conn.target.position
            
            # Map coordinates to grid coordinates
            source_x = int((sx + 10) / 20 * self.grid_width)
            source_y = int((10 - sy) / 20 * self.grid_height)
            target_x = int((tx + 10) / 20 * self.grid_width)
            target_y = int((10 - ty) / 20 * self.grid_height)
            
            # Make sure coordinates are in bounds
            source_x = max(0, min(self.grid_width - 1, source_x))
            source_y = max(0, min(self.grid_height - 1, source_y))
            target_x = max(0, min(self.grid_width - 1, target_x))
            target_y = max(0, min(self.grid_height - 1, target_y))
            
            # Skip if source and target are at the same point
            if source_x == target_x and source_y == target_y:
                continue
                
            # Draw a line between source and target (simple Bresenham algorithm)
            dx = abs(target_x - source_x)
            dy = abs(target_y - source_y)
            sx = 1 if source_x < target_x else -1
            sy = 1 if source_y < target_y else -1
            err = dx - dy
            
            x, y = source_x, source_y
            
            while x != target_x or y != target_y:
                if 0 <= x < self.grid_width and 0 <= y < self.grid_height:
                    # Only draw if the cell is empty
                    if self.grid[y][x] == ' ':
                        # Choose character for connection
                        if self.emoji_mode:
                            if conn.hair_connection:
                                char = EMOJI_MAP.get("hair", "〰️")
                            else:
                                if x == source_x:  # Vertical
                                    char = EMOJI_MAP.get("connection_v", "│")
                                elif y == source_y:  # Horizontal
                                    char = EMOJI_MAP.get("connection", "➖")
                                elif (x - source_x) * (y - source_y) > 0:  # Diagonal \
                                    char = EMOJI_MAP.get("connection_d2", "╲")
                                else:  # Diagonal /
                                    char = EMOJI_MAP.get("connection_d1", "╱")
                        else:
                            if conn.hair_connection:
                                char = "~"
                            else:
                                if x == source_x:  # Vertical
                                    char = "|"
                                elif y == source_y:  # Horizontal
                                    char = "-"
                                elif (x - source_x) * (y - source_y) > 0:  # Diagonal \
                                    char = "\\"
                                else:  # Diagonal /
                                    char = "/"
                                    
                        self.grid[y][x] = char
                
                e2 = 2 * err
                if e2 > -dy:
                    err -= dy
                    x += sx
                if e2 < dx:
                    err += dx
                    y += sy
                    
        # Draw hair growth points
        for point in self.hair_growth_points:
            px, py, pz = point["position"]
            
            # Map coordinates to grid coordinates
            grid_x = int((px + 10) / 20 * self.grid_width)
            grid_y = int((10 - py) / 20 * self.grid_height)
            
            # Make sure coordinates are in bounds
            grid_x = max(0, min(self.grid_width - 1, grid_x))
            grid_y = max(0, min(self.grid_height - 1, grid_y))
            
            # Draw growth point
            if 0 <= grid_x < self.grid_width and 0 <= grid_y < self.grid_height:
                self.grid[grid_y][grid_x] = EMOJI_MAP.get("hair", "〰️") if self.emoji_mode else "^"
                
        # Convert grid to string
        result = []
        for row in self.grid:
            result.append(''.join(row))
            
        # Add statistics
        result.append("")
        result.append(f"Shapes: {len(self.shapes)}/{CONFIG['max_shapes']}")
        result.append(f"Connections: {len(self.connections)}")
        result.append(f"Patterns: {len(self.patterns)}")
        result.append(f"Active Whims: {len(self.active_whims)}")
        result.append(f"Hair Points: {len(self.hair_growth_points)}")
        
        if self.eye_tracker:
            result.append(f"Eye Tracking: {'Active' if getattr(self.eye_tracker, 'active', False) else 'Inactive'}")
            
        # Add pattern information
        if self.patterns:
            result.append("")
            result.append("Pattern Sequence: " + " ".join(str(v) for v in CONFIG["pattern_sequence"]))
            result.append("Pattern Powers:")
            
            for pattern in self.patterns:
                power_bar = "=" * int(pattern.power * 10)
                result.append(f"  {pattern.name}: [{power_bar:<10}] {pattern.power:.1f} ({len(pattern.shapes)} shapes)")
                
        return "\n".join(result)
        
    def set_eye_tracker(self, tracker) -> None:
        """Set the eye tracking interface"""
        self.eye_tracker = tracker
        
    def get_patterns_as_dict(self) -> Dict[str, Any]:
        """Get all patterns as a dictionary"""
        return {
            pattern.name: {
                "values": pattern.values,
                "shapes": len(pattern.shapes),
                "power": pattern.power,
                "completion": pattern.completion
            }
            for pattern in self.patterns
        }
        
    def get_status(self) -> Dict[str, Any]:
        """Get visualizer status as a dictionary"""
        return {
            "shapes": len(self.shapes),
            "connections": len(self.connections),
            "patterns": len(self.patterns),
            "frames": self.frames,
            "active_whims": len(self.active_whims),
            "hair_points": len(self.hair_growth_points),
            "eye_tracking": self.eye_tracker is not None,
            "focused_shape": self.focused_shape.shape_type if self.focused_shape else None,
            "offline_mode": self.offline_mode,
            "emoji_mode": self.emoji_mode
        }
        
    def toggle_emoji_mode(self) -> None:
        """Toggle emoji mode on or off"""
        self.emoji_mode = not self.emoji_mode
        
    def integrate_with_console(self, console) -> None:
        """Integrate with a console system"""
        # Check if console has necessary methods
        if not hasattr(console, "add_memory"):
            print("Console integration failed: missing add_memory method")
            return
            
        # Add initial memory about shape system
        console.add_memory(
            f"Shape visualization system initialized with {len(self.shapes)} shapes "
            f"and {len(self.patterns)} patterns. "
            f"Base pattern sequence: {CONFIG['pattern_sequence']}",
            tags=["#shapes", "#visualization", "#patterns"]
        )
        
        # Try to integrate with eye tracking if available
        if hasattr(console, "eye_tracker"):
            self.set_eye_tracker(console.eye_tracker)
            console.add_memory(
                "Shape visualizer integrated with eye tracking system.",
                tags=["#shapes", "#eye_tracking"]
            )
            
        # Start visualizer if not already running
        if not self.running:
            self.start()

def main():
    """Main function for testing shape visualizer"""
    print("Initializing shape visualizer...")
    visualizer = ShapeVisualizer()
    
    # Start visualizer
    visualizer.start()
    
    print("\nShape visualizer started")
    print("- Press 'q' to quit")
    print("- Press 'v' to show visualization")
    print("- Press 'e' to toggle emoji mode")
    print("- Press 's' to show status")
    print("- Press 'p' to show patterns")
    
    # Main loop
    try:
        while True:
            # Get input (non-blocking)
            if os.name == 'nt':
                import msvcrt
                if msvcrt.kbhit():
                    key = msvcrt.getch().decode('utf-8').lower()
                else:
                    key = None
            else:
                import sys, tty, termios
                old_settings = termios.tcgetattr(sys.stdin)
                try:
                    tty.setcbreak(sys.stdin.fileno())
                    if sys.stdin.read(1):
                        key = sys.stdin.read(1).lower()
                    else:
                        key = None
                finally:
                    termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)
            
            # Process key
            if key == 'q':
                break
            elif key == 'v':
                print("\n" + visualizer.get_visualization())
            elif key == 'e':
                visualizer.toggle_emoji_mode()
                print(f"Emoji mode: {'Enabled' if visualizer.emoji_mode else 'Disabled'}")
            elif key == 's':
                status = visualizer.get_status()
                print("\nStatus:")
                for key, value in status.items():
                    print(f"  {key}: {value}")
            elif key == 'p':
                patterns = visualizer.get_patterns_as_dict()
                print("\nPatterns:")
                for name, info in patterns.items():
                    print(f"  {name}: {info['shapes']} shapes, Power: {info['power']:.2f}")
                    print(f"    Values: {info['values']}")
                    
            # Sleep to reduce CPU usage
            time.sleep(0.1)
            
    except KeyboardInterrupt:
        print("\nExiting...")
    finally:
        # Stop visualizer
        visualizer.stop()
        print("\nShape visualizer stopped")

if __name__ == "__main__":
    main()