#!/usr/bin/env python3
"""
Evolutionary Color Visualizer

This module provides a framework for visualizing data evolution through color transformation.
It allows for dynamic visualization of data patterns across multiple dimensions, with colors
representing the transformation and evolution of data through various states.

Core concepts:
- Color-based data visualization
- Multi-dimensional data evolution
- Pattern recognition through color transformation
- Time-sequence data representation
- Visual data integration across systems
"""

import os
import time
import json
import math
import random
import colorsys
from enum import Enum, auto
from typing import Dict, List, Optional, Set, Tuple, Union, Any, Callable
from datetime import datetime
from threading import Lock

# Try to import visualization libraries with graceful fallback
try:
    import numpy as np
    NUMPY_AVAILABLE = True
except ImportError:
    NUMPY_AVAILABLE = False
    print("Warning: NumPy not available, some features will be limited")

try:
    from PIL import Image, ImageDraw
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False
    print("Warning: PIL not available, image generation will be disabled")

# Try to import related modules with graceful fallback
try:
    from ai_integration_platform import DataFormat, DataStream
    AI_PLATFORM_AVAILABLE = True
except ImportError:
    AI_PLATFORM_AVAILABLE = False
    print("Warning: AI Integration Platform not available, some features disabled")

try:
    from symbol_data_evolution import SymbolEvolution, DataDimension
    SYMBOL_EVOLUTION_AVAILABLE = True
except ImportError:
    SYMBOL_EVOLUTION_AVAILABLE = False
    print("Warning: Symbol data evolution not available, some features disabled")

# Constants
DEFAULT_COLOR_DIMENSIONS = 3  # RGB
MAX_COLOR_DIMENSIONS = 12     # Maximum dimensions that can be visualized
DEFAULT_COLOR_DEPTH = 256     # Default color depth (0-255)
DEFAULT_EVOLUTION_STEPS = 33  # Number of evolution steps
DEFAULT_PATTERN_COMPLEXITY = 3  # Complexity of generated patterns
DEFAULT_OUTPUT_DIR = os.path.expanduser("~/evolutionary_visualizer_output")
COLOR_SCHEMES = {
    "rainbow": [(255,0,0), (255,127,0), (255,255,0), (0,255,0), (0,0,255), (75,0,130), (148,0,211)],
    "ocean": [(0,119,190), (0,180,216), (144,224,239), (202,240,248), (0,75,143)],
    "forest": [(0,68,27), (44,162,95), (120,198,121), (203,233,192), (35,139,69)],
    "fire": [(255,0,0), (255,127,0), (255,223,0), (255,170,0), (255,65,0)],
    "earth": [(121,85,72), (141,110,99), (161,136,127), (188,170,164), (215,204,200)],
    "cosmic": [(13,11,34), (54,28,90), (127,25,108), (212,53,88), (255,136,54)]
}
STANDARD_RATES = [1, 2, 3, 5, 8, 13, 21, 33, 54, 87, 141, 228]  # Fibonacci-ish progression

class ColorDimension(Enum):
    """Dimensions for color mapping"""
    RED = auto()           # Red component (primary)
    GREEN = auto()         # Green component (primary)
    BLUE = auto()          # Blue component (primary)
    HUE = auto()           # Color wheel position
    SATURATION = auto()    # Color intensity
    VALUE = auto()         # Brightness
    TEMPERATURE = auto()   # Warm to cool
    WEIGHT = auto()        # Visual weight/significance
    OPACITY = auto()       # Transparency level
    PATTERN = auto()       # Background pattern
    TEXTURE = auto()       # Surface quality
    LUMINANCE = auto()     # Perceived brightness

class EvolutionMode(Enum):
    """Modes for data evolution visualization"""
    LINEAR = auto()        # Straight-line progression
    CYCLIC = auto()        # Repeating patterns
    SPIRAL = auto()        # Evolving cycles
    BRANCHING = auto()     # Tree-like evolution
    CONVERGING = auto()    # Multiple paths merging
    DIVERGING = auto()     # Single path splitting
    QUANTUM = auto()       # Probability-based evolution
    CHAOTIC = auto()       # Unpredictable patterns

class ColorEvolutionSystem:
    """Core system for evolving data through color transformations"""
    
    def __init__(self, 
                 dimensions: int = DEFAULT_COLOR_DIMENSIONS,
                 color_depth: int = DEFAULT_COLOR_DEPTH,
                 evolution_steps: int = DEFAULT_EVOLUTION_STEPS,
                 base_colors: Optional[List[Tuple[int, int, int]]] = None,
                 mode: EvolutionMode = EvolutionMode.LINEAR,
                 output_dir: str = DEFAULT_OUTPUT_DIR):
        """Initialize the color evolution system"""
        self.dimensions = min(dimensions, MAX_COLOR_DIMENSIONS)
        self.color_depth = color_depth
        self.evolution_steps = evolution_steps
        self.base_colors = base_colors or COLOR_SCHEMES["rainbow"]
        self.mode = mode
        self.output_dir = output_dir
        self.dimension_weights = [1.0] * self.dimensions
        self.dimension_mappings: Dict[int, ColorDimension] = {}
        self.evolution_history: List[Dict[str, Any]] = []
        self.current_evolution_step = 0
        self.patterns: Dict[str, Any] = {}
        self.color_mappings: Dict[str, Callable] = {}
        self._lock = Lock()
        
        # Create output directory
        os.makedirs(self.output_dir, exist_ok=True)
        
        # Map dimensions to color attributes
        self._map_dimensions()
        
        # Set up standard patterns
        self._init_patterns()
        
        # Initialize integrations
        self.data_stream = None
        self.symbol_evolution = None
        self._init_integrations()
    
    def _map_dimensions(self) -> None:
        """Map data dimensions to color attributes"""
        # Standard RGB mapping for first 3 dimensions
        color_dims = list(ColorDimension)
        for i in range(self.dimensions):
            if i < len(color_dims):
                self.dimension_mappings[i] = color_dims[i]
            else:
                # Cycle through dimensions if more are needed
                self.dimension_mappings[i] = color_dims[i % len(color_dims)]
    
    def _init_patterns(self) -> None:
        """Initialize standard patterns"""
        self.patterns = {
            "grid": {
                "type": "grid",
                "line_spacing": 10,
                "line_width": 1,
                "angle": 0
            },
            "dots": {
                "type": "dots",
                "dot_size": 2,
                "spacing": 8,
                "offset": 0
            },
            "waves": {
                "type": "waves",
                "amplitude": 10,
                "frequency": 0.05,
                "phase": 0
            },
            "spirals": {
                "type": "spirals",
                "density": 0.1,
                "rotation": 0,
                "arms": 3
            },
            "noise": {
                "type": "noise",
                "scale": 0.1,
                "octaves": 4,
                "persistence": 0.5
            }
        }
    
    def _init_integrations(self) -> None:
        """Initialize integrations with other systems"""
        # Set up data stream if available
        if AI_PLATFORM_AVAILABLE:
            try:
                self.data_stream = DataStream(
                    name="color_evolution",
                    buffer_size=1024 * 1024  # 1MB buffer
                )
                self.data_stream.start()
            except Exception as e:
                print(f"Error initializing data stream: {e}")
        
        # Set up symbol evolution if available
        if SYMBOL_EVOLUTION_AVAILABLE:
            try:
                self.symbol_evolution = SymbolEvolution()
            except Exception as e:
                print(f"Error initializing symbol evolution: {e}")
    
    def set_dimension_weight(self, dimension: int, weight: float) -> bool:
        """Set the weight for a specific dimension"""
        with self._lock:
            if dimension < 0 or dimension >= self.dimensions:
                return False
            
            self.dimension_weights[dimension] = max(0.0, min(1.0, weight))
            return True
    
    def set_dimension_mapping(self, dimension: int, color_dimension: ColorDimension) -> bool:
        """Map a data dimension to a specific color dimension"""
        with self._lock:
            if dimension < 0 or dimension >= self.dimensions:
                return False
            
            self.dimension_mappings[dimension] = color_dimension
            return True
    
    def set_evolution_mode(self, mode: EvolutionMode) -> None:
        """Set the evolution mode"""
        with self._lock:
            self.mode = mode
    
    def set_color_scheme(self, scheme_name: str) -> bool:
        """Set the color scheme using a predefined scheme"""
        with self._lock:
            if scheme_name not in COLOR_SCHEMES:
                return False
            
            self.base_colors = COLOR_SCHEMES[scheme_name]
            return True
    
    def reset_evolution(self) -> None:
        """Reset the evolution process"""
        with self._lock:
            self.evolution_history = []
            self.current_evolution_step = 0
    
    def map_data_to_colors(self, data: Any) -> Dict[int, List[int]]:
        """Map input data to color values for each dimension"""
        color_values = {}
        
        # Normalize and map data based on type
        if isinstance(data, (int, float)):
            # Single numeric value
            normalized = self._normalize_value(data)
            for dim in range(self.dimensions):
                color_values[dim] = self._map_to_color_dimension(normalized, dim)
        
        elif isinstance(data, (list, tuple)):
            # List of values
            for dim in range(self.dimensions):
                if dim < len(data):
                    normalized = self._normalize_value(data[dim])
                    color_values[dim] = self._map_to_color_dimension(normalized, dim)
                else:
                    # Use default value for missing dimensions
                    color_values[dim] = self._map_to_color_dimension(0.5, dim)
        
        elif isinstance(data, dict):
            # Dictionary with dimension keys
            for dim in range(self.dimensions):
                if str(dim) in data:
                    normalized = self._normalize_value(data[str(dim)])
                    color_values[dim] = self._map_to_color_dimension(normalized, dim)
                elif dim in data:
                    normalized = self._normalize_value(data[dim])
                    color_values[dim] = self._map_to_color_dimension(normalized, dim)
                else:
                    # Use default value for missing dimensions
                    color_values[dim] = self._map_to_color_dimension(0.5, dim)
        
        elif isinstance(data, str):
            # String data - hash the string to get numeric values
            hash_val = self._hash_string(data)
            for dim in range(self.dimensions):
                # Extract different parts of the hash for each dimension
                segment = (hash_val >> (dim * 8)) & 0xFF
                normalized = segment / 255.0
                color_values[dim] = self._map_to_color_dimension(normalized, dim)
        
        else:
            # Unknown data type - use default values
            for dim in range(self.dimensions):
                color_values[dim] = self._map_to_color_dimension(0.5, dim)
        
        return color_values
    
    def _normalize_value(self, value: Union[int, float]) -> float:
        """Normalize a value to 0.0-1.0 range"""
        if isinstance(value, bool):
            return 1.0 if value else 0.0
        
        try:
            # Try to convert to float
            float_val = float(value)
            
            # Check if it's already in 0-1 range
            if 0.0 <= float_val <= 1.0:
                return float_val
            
            # Normalize common ranges
            if 0 <= float_val <= 255:
                return float_val / 255.0
            elif 0 <= float_val <= 100:
                return float_val / 100.0
            elif -1.0 <= float_val <= 1.0:
                return (float_val + 1.0) / 2.0
            else:
                # Use sigmoid function for unbounded values
                return 1.0 / (1.0 + math.exp(-float_val))
        
        except (ValueError, TypeError):
            # Default to middle value for non-numeric
            return 0.5
    
    def _map_to_color_dimension(self, normalized_value: float, dimension: int) -> List[int]:
        """Map a normalized value to a color dimension"""
        if dimension not in self.dimension_mappings:
            # Default to first 3 dimensions if not mapped
            if dimension < 3:
                color_dim = list(ColorDimension)[dimension]
            else:
                color_dim = ColorDimension.RED  # Default
        else:
            color_dim = self.dimension_mappings[dimension]
        
        # Apply dimension weight
        weighted_value = normalized_value * self.dimension_weights[dimension]
        
        # Map based on color dimension
        if color_dim == ColorDimension.RED:
            return [int(weighted_value * self.color_depth), 0, 0]
        elif color_dim == ColorDimension.GREEN:
            return [0, int(weighted_value * self.color_depth), 0]
        elif color_dim == ColorDimension.BLUE:
            return [0, 0, int(weighted_value * self.color_depth)]
        elif color_dim == ColorDimension.HUE:
            # Convert hue to RGB
            rgb = self._hsv_to_rgb(weighted_value, 1.0, 1.0)
            return [int(r * self.color_depth) for r in rgb]
        elif color_dim == ColorDimension.SATURATION:
            # Use saturation with default hue
            rgb = self._hsv_to_rgb(0.5, weighted_value, 1.0)
            return [int(r * self.color_depth) for r in rgb]
        elif color_dim == ColorDimension.VALUE:
            # Use value/brightness with default hue
            value = weighted_value
            return [int(value * self.color_depth)] * 3
        elif color_dim == ColorDimension.TEMPERATURE:
            # Temperature: blue (cold) to red (hot)
            if weighted_value < 0.5:
                # Cold: blue to white
                blue = 1.0
                red_green = weighted_value * 2.0
                return [int(red_green * self.color_depth), int(red_green * self.color_depth), int(blue * self.color_depth)]
            else:
                # Hot: white to red
                red = 1.0
                green_blue = 1.0 - (weighted_value - 0.5) * 2.0
                return [int(red * self.color_depth), int(green_blue * self.color_depth), int(green_blue * self.color_depth)]
        else:
            # Default to grayscale for other dimensions
            value = int(weighted_value * self.color_depth)
            return [value, value, value]
    
    def _hsv_to_rgb(self, h: float, s: float, v: float) -> Tuple[float, float, float]:
        """Convert HSV color to RGB (all values 0.0-1.0)"""
        if s == 0.0:
            return (v, v, v)
        
        h = h * 6.0  # Convert hue to 0-6 range
        i = int(h)
        f = h - i
        p = v * (1.0 - s)
        q = v * (1.0 - s * f)
        t = v * (1.0 - s * (1.0 - f))
        
        if i == 0:
            return (v, t, p)
        elif i == 1:
            return (q, v, p)
        elif i == 2:
            return (p, v, t)
        elif i == 3:
            return (p, q, v)
        elif i == 4:
            return (t, p, v)
        else:
            return (v, p, q)
    
    def _hash_string(self, text: str) -> int:
        """Generate a numeric hash from a string"""
        hash_val = 0
        for char in text:
            hash_val = ((hash_val << 5) - hash_val) + ord(char)
            hash_val = hash_val & 0xFFFFFFFF  # Keep 32 bits
        return hash_val
    
    def evolve_color(self, 
                    color_values: Dict[int, List[int]], 
                    step: int) -> Dict[int, List[int]]:
        """Evolve color values based on evolution mode and step"""
        evolved_values = {}
        
        # Apply evolution based on mode
        if self.mode == EvolutionMode.LINEAR:
            # Simple linear progression
            rate = step / self.evolution_steps
            for dim, values in color_values.items():
                evolved = [int(min(self.color_depth, v + v * rate)) for v in values]
                evolved_values[dim] = evolved
        
        elif self.mode == EvolutionMode.CYCLIC:
            # Oscillating values
            for dim, values in color_values.items():
                cycle_rate = 2 * math.pi * step / self.evolution_steps
                modifier = (math.sin(cycle_rate) + 1) / 2  # 0.0 to 1.0
                evolved = [int(min(self.color_depth, v * (0.5 + modifier))) for v in values]
                evolved_values[dim] = evolved
        
        elif self.mode == EvolutionMode.SPIRAL:
            # Spiral progression - combine cycling with growth
            for dim, values in color_values.items():
                cycle_rate = 2 * math.pi * step / self.evolution_steps
                growth = step / self.evolution_steps
                modifier_x = math.cos(cycle_rate) * growth
                modifier_y = math.sin(cycle_rate) * growth
                modifier = math.sqrt(modifier_x**2 + modifier_y**2)
                evolved = [int(min(self.color_depth, v * (0.5 + modifier))) for v in values]
                evolved_values[dim] = evolved
        
        elif self.mode == EvolutionMode.BRANCHING:
            # Create two variations based on step parity
            branch = step % 2
            for dim, values in color_values.items():
                if branch == 0:
                    # First branch - enhance reds
                    evolved = values.copy()
                    evolved[0] = int(min(self.color_depth, values[0] * (1 + step/self.evolution_steps)))
                else:
                    # Second branch - enhance blues
                    evolved = values.copy()
                    evolved[2] = int(min(self.color_depth, values[2] * (1 + step/self.evolution_steps)))
                evolved_values[dim] = evolved
        
        elif self.mode == EvolutionMode.CONVERGING:
            # Values converge toward a target
            targets = {
                0: [self.color_depth, 0, 0],  # Red
                1: [0, self.color_depth, 0],  # Green
                2: [0, 0, self.color_depth]   # Blue
            }
            rate = step / self.evolution_steps
            for dim, values in color_values.items():
                target = targets.get(dim, [self.color_depth//2] * 3)
                evolved = []
                for i, v in enumerate(values):
                    if i < len(target):
                        evolved.append(int(v * (1-rate) + target[i] * rate))
                    else:
                        evolved.append(v)
                evolved_values[dim] = evolved
        
        elif self.mode == EvolutionMode.DIVERGING:
            # Values diverge from original
            rate = step / self.evolution_steps
            for dim, values in color_values.items():
                if dim % 3 == 0:
                    # First set: enhance primary color
                    factor = 1 + rate
                    evolved = values.copy()
                    evolved[dim % 3] = int(min(self.color_depth, values[dim % 3] * factor))
                elif dim % 3 == 1:
                    # Second set: reduce primary color
                    factor = 1 - rate * 0.5
                    evolved = values.copy()
                    evolved[dim % 3] = int(max(0, values[dim % 3] * factor))
                else:
                    # Third set: invert change
                    evolved = values.copy()
                    evolved[0] = evolved[2]
                    evolved[2] = values[0]
                evolved_values[dim] = evolved
        
        elif self.mode == EvolutionMode.QUANTUM:
            # Probabilistic changes based on step
            for dim, values in color_values.items():
                evolved = []
                for v in values:
                    if random.random() < step / self.evolution_steps:
                        # Quantum jump
                        direction = 1 if random.random() > 0.5 else -1
                        jump = int(v * random.random() * 0.5) * direction
                        evolved.append(max(0, min(self.color_depth, v + jump)))
                    else:
                        evolved.append(v)
                evolved_values[dim] = evolved
        
        elif self.mode == EvolutionMode.CHAOTIC:
            # Chaotic changes - use logistic map for chaos
            r = 3.9  # Chaos parameter (3.57 to 4.0 is chaotic)
            for dim, values in color_values.items():
                evolved = []
                for v in values:
                    # Normalize to 0-1 for logistic map
                    x = v / self.color_depth
                    # Apply logistic map iteration
                    for _ in range(step):
                        x = r * x * (1 - x)
                    # Convert back to color range
                    evolved.append(int(x * self.color_depth))
                evolved_values[dim] = evolved
        
        else:
            # Default - no evolution
            evolved_values = color_values.copy()
        
        return evolved_values
    
    def evolve_data(self, 
                   data: Any, 
                   steps: Optional[int] = None,
                   save_history: bool = True) -> List[Dict[int, List[int]]]:
        """Evolve data through multiple steps and return color progression"""
        with self._lock:
            # Map initial data to colors
            color_values = self.map_data_to_colors(data)
            
            # Determine number of steps
            num_steps = steps if steps is not None else self.evolution_steps
            
            # Create evolution sequence
            evolution_sequence = [color_values.copy()]
            
            # Evolve through steps
            for step in range(1, num_steps + 1):
                evolved = self.evolve_color(evolution_sequence[-1], step)
                evolution_sequence.append(evolved)
                
                # Save to history if requested
                if save_history:
                    self.evolution_history.append({
                        "step": self.current_evolution_step + step,
                        "timestamp": time.time(),
                        "data": data,
                        "colors": evolved
                    })
            
            # Update current step
            if save_history:
                self.current_evolution_step += num_steps
            
            # Publish to data stream if available
            if self.data_stream:
                self.data_stream.publish({
                    "type": "evolution_complete",
                    "steps": num_steps,
                    "results": len(evolution_sequence),
                    "timestamp": time.time()
                })
            
            return evolution_sequence
    
    def combine_colors(self, colors: Dict[int, List[int]]) -> List[int]:
        """Combine color values from all dimensions into a single RGB color"""
        combined = [0, 0, 0]  # RGB
        
        # Combine based on dimension mapping
        for dim, values in colors.items():
            # Apply dimension weight
            weight = self.dimension_weights[dim]
            
            # Add weighted contribution
            for i in range(min(3, len(values))):
                combined[i] += int(values[i] * weight)
        
        # Ensure values are within range
        combined = [min(self.color_depth, max(0, c)) for c in combined]
        
        return combined
    
    def create_color_image(self, 
                          colors: Union[Dict[int, List[int]], List[Dict[int, List[int]]]],
                          width: int = 100,
                          height: int = 100,
                          pattern: Optional[str] = None,
                          save_path: Optional[str] = None) -> Optional[Any]:
        """Create an image from color values"""
        if not PIL_AVAILABLE:
            print("PIL not available, cannot create image")
            return None
        
        # Handle single color set or sequence
        if isinstance(colors, dict):
            # Single color set
            color_list = [colors]
        else:
            # Sequence of colors
            color_list = colors
        
        # Calculate image layout
        if len(color_list) == 1:
            # Single image
            cols, rows = 1, 1
        else:
            # Grid of images for sequence
            cols = min(8, len(color_list))
            rows = (len(color_list) + cols - 1) // cols  # Ceiling division
        
        # Create combined image
        full_width = cols * width
        full_height = rows * height
        image = Image.new('RGB', (full_width, full_height), color=(0, 0, 0))
        draw = ImageDraw.Draw(image)
        
        # Process each color set
        for idx, color_set in enumerate(color_list):
            # Determine position in grid
            col = idx % cols
            row = idx // cols
            x_offset = col * width
            y_offset = row * height
            
            # Combine colors from all dimensions
            combined_color = self.combine_colors(color_set)
            rgb_color = tuple(combined_color[:3])
            
            # Draw rectangle with this color
            draw.rectangle(
                [x_offset, y_offset, x_offset + width, y_offset + height],
                fill=rgb_color
            )
            
            # Apply pattern if specified
            if pattern and pattern in self.patterns:
                self._apply_pattern(
                    draw, 
                    x_offset, 
                    y_offset, 
                    width, 
                    height, 
                    self.patterns[pattern],
                    rgb_color
                )
        
        # Save if path provided
        if save_path:
            directory = os.path.dirname(save_path)
            if directory:
                os.makedirs(directory, exist_ok=True)
            image.save(save_path)
        
        return image
    
    def _apply_pattern(self, 
                      draw: Any, 
                      x_offset: int, 
                      y_offset: int, 
                      width: int, 
                      height: int, 
                      pattern_def: Dict[str, Any],
                      base_color: Tuple[int, int, int]) -> None:
        """Apply a pattern to the image"""
        pattern_type = pattern_def["type"]
        
        # Calculate contrast color
        contrast_color = self._get_contrast_color(base_color)
        
        if pattern_type == "grid":
            # Draw grid lines
            spacing = pattern_def.get("line_spacing", 10)
            line_width = pattern_def.get("line_width", 1)
            angle = pattern_def.get("angle", 0)
            
            if angle == 0:
                # Horizontal lines
                for y in range(0, height, spacing):
                    draw.line(
                        [x_offset, y_offset + y, x_offset + width, y_offset + y],
                        fill=contrast_color,
                        width=line_width
                    )
                
                # Vertical lines
                for x in range(0, width, spacing):
                    draw.line(
                        [x_offset + x, y_offset, x_offset + x, y_offset + height],
                        fill=contrast_color,
                        width=line_width
                    )
            else:
                # Angled grid requires more complex math
                pass  # Simplified version doesn't implement angled grid
        
        elif pattern_type == "dots":
            # Draw dot pattern
            dot_size = pattern_def.get("dot_size", 2)
            spacing = pattern_def.get("spacing", 8)
            offset = pattern_def.get("offset", 0)
            
            for x in range(offset, width, spacing):
                for y in range(offset, height, spacing):
                    draw.ellipse(
                        [x_offset + x - dot_size, y_offset + y - dot_size,
                         x_offset + x + dot_size, y_offset + y + dot_size],
                        fill=contrast_color
                    )
        
        elif pattern_type == "waves":
            # Draw wave pattern
            amplitude = pattern_def.get("amplitude", 10)
            frequency = pattern_def.get("frequency", 0.05)
            phase = pattern_def.get("phase", 0)
            
            # Horizontal waves
            for x in range(width):
                y = int(amplitude * math.sin(frequency * x + phase))
                y1 = y_offset + height // 2 + y
                draw.point([x_offset + x, y1], fill=contrast_color)
        
        elif pattern_type == "spirals":
            # Draw spiral pattern
            density = pattern_def.get("density", 0.1)
            rotation = pattern_def.get("rotation", 0)
            arms = pattern_def.get("arms", 3)
            
            center_x = width // 2
            center_y = height // 2
            
            for radius in range(0, min(width, height) // 2, 2):
                for arm in range(arms):
                    angle = rotation + (radius * density) + (arm * 2 * math.pi / arms)
                    x = center_x + int(radius * math.cos(angle))
                    y = center_y + int(radius * math.sin(angle))
                    
                    if 0 <= x < width and 0 <= y < height:
                        draw.point([x_offset + x, y_offset + y], fill=contrast_color)
        
        elif pattern_type == "noise" and NUMPY_AVAILABLE:
            # Create noise pattern using NumPy if available
            scale = pattern_def.get("scale", 0.1)
            octaves = pattern_def.get("octaves", 4)
            persistence = pattern_def.get("persistence", 0.5)
            
            # Simple implementation of noise pattern
            for x in range(width):
                for y in range(height):
                    # Use pseudo-random noise
                    if random.random() < 0.05:  # 5% of pixels
                        draw.point([x_offset + x, y_offset + y], fill=contrast_color)
    
    def _get_contrast_color(self, color: Tuple[int, int, int]) -> Tuple[int, int, int]:
        """Calculate a contrasting color for patterns"""
        r, g, b = color
        # Calculate perceived brightness
        brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255
        
        if brightness > 0.5:
            # Dark contrast for light colors
            return (max(0, r - 128), max(0, g - 128), max(0, b - 128))
        else:
            # Light contrast for dark colors
            return (min(255, r + 128), min(255, g + 128), min(255, b + 128))
    
    def save_evolution_visualization(self, 
                                   data: Any,
                                   steps: Optional[int] = None,
                                   width: int = 800,
                                   height: int = 600,
                                   filename: Optional[str] = None) -> str:
        """Generate and save a visualization of data evolution"""
        # Evolve the data
        evolution_sequence = self.evolve_data(data, steps)
        
        # Determine output filename
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"evolution_{timestamp}.png"
        
        # Ensure path has extension
        if not filename.lower().endswith(('.png', '.jpg', '.jpeg', '.gif')):
            filename += '.png'
        
        # Create complete path
        output_path = os.path.join(self.output_dir, filename)
        
        # Calculate cell size for grid
        steps_count = len(evolution_sequence)
        cols = min(int(math.sqrt(steps_count) * 1.5), 10)  # Wider than tall
        rows = (steps_count + cols - 1) // cols
        
        cell_width = width // cols
        cell_height = height // rows
        
        # Create combined image
        if PIL_AVAILABLE:
            image = Image.new('RGB', (width, height), color=(0, 0, 0))
            draw = ImageDraw.Draw(image)
            
            # Draw title
            title = f"Data Evolution - {self.mode.name} Mode - {steps_count} Steps"
            if hasattr(draw, 'text'):
                draw.text((10, 10), title, fill=(255, 255, 255))
            
            # Draw each evolution step
            for idx, colors in enumerate(evolution_sequence):
                col = idx % cols
                row = idx // cols
                x_offset = col * cell_width
                y_offset = row * cell_height + 30  # Account for title
                
                # Combine colors for this step
                combined_color = self.combine_colors(colors)
                rgb_color = tuple(combined_color[:3])
                
                # Draw cell
                draw.rectangle(
                    [x_offset, y_offset, x_offset + cell_width - 2, y_offset + cell_height - 2],
                    fill=rgb_color,
                    outline=(64, 64, 64)
                )
                
                # Draw step number
                if hasattr(draw, 'text'):
                    draw.text(
                        (x_offset + 5, y_offset + 5),
                        str(idx),
                        fill=self._get_contrast_color(rgb_color)
                    )
            
            # Save image
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            image.save(output_path)
            
            # Publish to data stream if available
            if self.data_stream:
                self.data_stream.publish({
                    "type": "visualization_saved",
                    "path": output_path,
                    "steps": steps_count,
                    "mode": self.mode.name,
                    "timestamp": time.time()
                })
            
            return output_path
        else:
            print("PIL not available, cannot create visualization")
            return ""
    
    def create_color_sequence(self, 
                             steps: int,
                             start_color: Optional[Tuple[int, int, int]] = None,
                             end_color: Optional[Tuple[int, int, int]] = None) -> List[Tuple[int, int, int]]:
        """Create a sequence of colors transitioning from start to end"""
        if start_color is None:
            start_color = self.base_colors[0] if self.base_colors else (0, 0, 0)
        
        if end_color is None:
            end_color = self.base_colors[-1] if len(self.base_colors) > 1 else (255, 255, 255)
        
        # Ensure we have proper RGB tuples
        start_rgb = tuple(max(0, min(255, c)) for c in start_color[:3])
        end_rgb = tuple(max(0, min(255, c)) for c in end_color[:3])
        
        sequence = []
        for step in range(steps):
            # Linear interpolation between colors
            t = step / (steps - 1) if steps > 1 else 0
            r = int(start_rgb[0] * (1 - t) + end_rgb[0] * t)
            g = int(start_rgb[1] * (1 - t) + end_rgb[1] * t)
            b = int(start_rgb[2] * (1 - t) + end_rgb[2] * t)
            sequence.append((r, g, b))
        
        return sequence
    
    def generate_transformation_matrix(self, dimensions: int = 3) -> List[List[float]]:
        """Generate a random transformation matrix for color evolution"""
        matrix = []
        
        for i in range(dimensions):
            row = []
            for j in range(dimensions):
                # Generate values that tend to preserve color characteristics
                if i == j:
                    # Diagonal values - stronger influence
                    value = 0.7 + random.random() * 0.3  # 0.7 to 1.0
                else:
                    # Off-diagonal - weaker cross-influence
                    value = random.random() * 0.3  # 0.0 to 0.3
                row.append(value)
            matrix.append(row)
        
        return matrix
    
    def apply_transformation(self, 
                            color: List[int], 
                            matrix: List[List[float]]) -> List[int]:
        """Apply a transformation matrix to a color"""
        if len(color) != len(matrix) or any(len(row) != len(color) for row in matrix):
            # Matrix dimensions don't match color
            return color
        
        result = []
        for i in range(len(color)):
            value = sum(color[j] * matrix[i][j] for j in range(len(color)))
            result.append(int(max(0, min(self.color_depth, value))))
        
        return result
    
    def create_animation_frames(self, 
                               data: Any,
                               steps: int = 33,
                               width: int = 200,
                               height: int = 200,
                               pattern: Optional[str] = None) -> List[Any]:
        """Create a series of frames for animation"""
        if not PIL_AVAILABLE:
            print("PIL not available, cannot create animation frames")
            return []
        
        # Evolve data
        evolution_sequence = self.evolve_data(data, steps)
        
        frames = []
        for idx, colors in enumerate(evolution_sequence):
            # Create image for this step
            image = self.create_color_image(
                colors,
                width=width,
                height=height,
                pattern=pattern
            )
            
            if image:
                frames.append(image)
        
        return frames
    
    def save_animation(self, 
                      frames: List[Any],
                      output_path: str,
                      duration: int = 100) -> bool:
        """Save a series of frames as an animated GIF"""
        if not PIL_AVAILABLE or not frames:
            print("PIL not available or no frames provided, cannot save animation")
            return False
        
        try:
            # Ensure directory exists
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            
            # Save as animated GIF
            frames[0].save(
                output_path,
                save_all=True,
                append_images=frames[1:],
                optimize=False,
                duration=duration,
                loop=0
            )
            
            # Publish to data stream if available
            if self.data_stream:
                self.data_stream.publish({
                    "type": "animation_saved",
                    "path": output_path,
                    "frames": len(frames),
                    "duration": duration,
                    "timestamp": time.time()
                })
            
            return True
        except Exception as e:
            print(f"Error saving animation: {e}")
            return False
    
    def analyze_evolution_pattern(self, evolution_sequence: List[Dict[int, List[int]]]) -> Dict[str, Any]:
        """Analyze the pattern of evolution in a sequence"""
        analysis = {
            "sequence_length": len(evolution_sequence),
            "dimensions": self.dimensions,
            "mode": self.mode.name,
            "patterns": {},
            "metrics": {}
        }
        
        if len(evolution_sequence) < 2:
            analysis["error"] = "Sequence too short for analysis"
            return analysis
        
        # Analyze each dimension
        for dim in range(self.dimensions):
            dim_analysis = {
                "start_values": [],
                "end_values": [],
                "delta": [],
                "trend": "stable"
            }
            
            # Extract start and end values
            if dim in evolution_sequence[0]:
                dim_analysis["start_values"] = evolution_sequence[0][dim]
            
            if dim in evolution_sequence[-1]:
                dim_analysis["end_values"] = evolution_sequence[-1][dim]
            
            # Calculate changes
            if "start_values" in dim_analysis and "end_values" in dim_analysis:
                # Ensure same length
                min_len = min(len(dim_analysis["start_values"]), len(dim_analysis["end_values"]))
                
                for i in range(min_len):
                    start_val = dim_analysis["start_values"][i]
                    end_val = dim_analysis["end_values"][i]
                    delta = end_val - start_val
                    dim_analysis["delta"].append(delta)
                
                # Determine trend
                avg_delta = sum(dim_analysis["delta"]) / len(dim_analysis["delta"]) if dim_analysis["delta"] else 0
                
                if avg_delta > 0.1 * self.color_depth:
                    dim_analysis["trend"] = "increasing"
                elif avg_delta < -0.1 * self.color_depth:
                    dim_analysis["trend"] = "decreasing"
                else:
                    dim_analysis["trend"] = "stable"
            
            analysis["patterns"][f"dimension_{dim}"] = dim_analysis
        
        # Calculate overall metrics
        combined_start = self.combine_colors(evolution_sequence[0])
        combined_end = self.combine_colors(evolution_sequence[-1])
        
        brightness_start = sum(combined_start) / (3 * self.color_depth)
        brightness_end = sum(combined_end) / (3 * self.color_depth)
        
        analysis["metrics"]["brightness_change"] = brightness_end - brightness_start
        analysis["metrics"]["color_distance"] = math.sqrt(sum((combined_end[i] - combined_start[i])**2 for i in range(3)))
        
        return analysis
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert the evolution system configuration to a dictionary"""
        with self._lock:
            config = {
                "dimensions": self.dimensions,
                "color_depth": self.color_depth,
                "evolution_steps": self.evolution_steps,
                "base_colors": self.base_colors,
                "mode": self.mode.name,
                "output_dir": self.output_dir,
                "dimension_weights": self.dimension_weights,
                "dimension_mappings": {str(d): m.name for d, m in self.dimension_mappings.items()},
                "current_evolution_step": self.current_evolution_step,
                "patterns": self.patterns,
                "timestamp": time.time()
            }
            
            return config
    
    @classmethod
    def from_dict(cls, config: Dict[str, Any]) -> 'ColorEvolutionSystem':
        """Create a ColorEvolutionSystem from a dictionary configuration"""
        # Create instance with basic settings
        system = cls(
            dimensions=config.get("dimensions", DEFAULT_COLOR_DIMENSIONS),
            color_depth=config.get("color_depth", DEFAULT_COLOR_DEPTH),
            evolution_steps=config.get("evolution_steps", DEFAULT_EVOLUTION_STEPS),
            base_colors=config.get("base_colors"),
            mode=EvolutionMode[config.get("mode", "LINEAR")],
            output_dir=config.get("output_dir", DEFAULT_OUTPUT_DIR)
        )
        
        # Set additional properties
        if "dimension_weights" in config:
            system.dimension_weights = config["dimension_weights"]
        
        if "dimension_mappings" in config:
            for dim_str, mapping_name in config["dimension_mappings"].items():
                dim = int(dim_str)
                if dim < system.dimensions and hasattr(ColorDimension, mapping_name):
                    system.dimension_mappings[dim] = ColorDimension[mapping_name]
        
        if "current_evolution_step" in config:
            system.current_evolution_step = config["current_evolution_step"]
        
        if "patterns" in config:
            system.patterns.update(config["patterns"])
        
        return system

class DataEvolutionVisualizer:
    """High-level interface for visualizing data evolution"""
    
    def __init__(self, 
                 dimensions: int = DEFAULT_COLOR_DIMENSIONS,
                 color_scheme: str = "rainbow",
                 pattern_complexity: int = DEFAULT_PATTERN_COMPLEXITY,
                 output_dir: Optional[str] = None):
        """Initialize the data evolution visualizer"""
        self.dimensions = dimensions
        self.color_scheme = color_scheme
        self.pattern_complexity = pattern_complexity
        self.output_dir = output_dir or os.path.join(DEFAULT_OUTPUT_DIR, "visualizations")
        self.evolution_systems: Dict[str, ColorEvolutionSystem] = {}
        self._lock = Lock()
        
        # Create output directory
        os.makedirs(self.output_dir, exist_ok=True)
        
        # Create default evolution system
        self._create_default_system()
    
    def _create_default_system(self) -> None:
        """Create the default color evolution system"""
        default_system = ColorEvolutionSystem(
            dimensions=self.dimensions,
            base_colors=COLOR_SCHEMES.get(self.color_scheme, COLOR_SCHEMES["rainbow"]),
            output_dir=self.output_dir
        )
        
        self.evolution_systems["default"] = default_system
    
    def create_evolution_system(self, 
                               name: str,
                               mode: EvolutionMode,
                               dimensions: Optional[int] = None,
                               color_scheme: Optional[str] = None) -> bool:
        """Create a new evolution system with specified settings"""
        with self._lock:
            if name in self.evolution_systems:
                return False
            
            dims = dimensions or self.dimensions
            cs = color_scheme or self.color_scheme
            
            system = ColorEvolutionSystem(
                dimensions=dims,
                base_colors=COLOR_SCHEMES.get(cs, COLOR_SCHEMES["rainbow"]),
                mode=mode,
                output_dir=os.path.join(self.output_dir, name)
            )
            
            self.evolution_systems[name] = system
            return True
    
    def visualize_data(self, 
                      data: Any,
                      system_name: str = "default",
                      steps: int = DEFAULT_EVOLUTION_STEPS,
                      width: int = 800,
                      height: int = 600,
                      pattern: Optional[str] = None,
                      filename: Optional[str] = None) -> str:
        """Visualize data evolution using the specified system"""
        with self._lock:
            if system_name not in self.evolution_systems:
                if system_name != "default":
                    print(f"Evolution system '{system_name}' not found, using default")
                system_name = "default"
                
                # Create default if needed
                if system_name not in self.evolution_systems:
                    self._create_default_system()
            
            system = self.evolution_systems[system_name]
            
            # Generate filename if not provided
            if filename is None:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"{system_name}_{timestamp}.png"
            
            # Generate visualization
            output_path = system.save_evolution_visualization(
                data=data,
                steps=steps,
                width=width,
                height=height,
                filename=filename
            )
            
            return output_path
    
    def create_animation(self, 
                        data: Any,
                        system_name: str = "default",
                        steps: int = DEFAULT_EVOLUTION_STEPS,
                        width: int = 200,
                        height: int = 200,
                        duration: int = 100,
                        pattern: Optional[str] = None,
                        filename: Optional[str] = None) -> str:
        """Create an animated visualization of data evolution"""
        with self._lock:
            if system_name not in self.evolution_systems:
                if system_name != "default":
                    print(f"Evolution system '{system_name}' not found, using default")
                system_name = "default"
                
                # Create default if needed
                if system_name not in self.evolution_systems:
                    self._create_default_system()
            
            system = self.evolution_systems[system_name]
            
            # Generate filename if not provided
            if filename is None:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"{system_name}_animation_{timestamp}.gif"
            
            # Ensure correct extension
            if not filename.lower().endswith('.gif'):
                filename += '.gif'
            
            # Create frames
            frames = system.create_animation_frames(
                data=data,
                steps=steps,
                width=width,
                height=height,
                pattern=pattern
            )
            
            if not frames:
                return ""
            
            # Save animation
            output_path = os.path.join(system.output_dir, filename)
            success = system.save_animation(frames, output_path, duration)
            
            return output_path if success else ""
    
    def visualize_multiple_data(self, 
                               data_items: List[Any],
                               system_name: str = "default",
                               filename: Optional[str] = None) -> str:
        """Create a comparative visualization of multiple data items"""
        with self._lock:
            if not PIL_AVAILABLE:
                print("PIL not available, cannot create visualization")
                return ""
            
            if system_name not in self.evolution_systems:
                if system_name != "default":
                    print(f"Evolution system '{system_name}' not found, using default")
                system_name = "default"
                
                # Create default if needed
                if system_name not in self.evolution_systems:
                    self._create_default_system()
            
            system = self.evolution_systems[system_name]
            
            # Generate filename if not provided
            if filename is None:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"{system_name}_comparison_{timestamp}.png"
            
            # Determine layout
            item_count = len(data_items)
            if item_count == 0:
                return ""
            
            # Use square-ish grid
            cols = min(int(math.sqrt(item_count) * 1.5), 5)
            rows = (item_count + cols - 1) // cols
            
            cell_width = 150
            cell_height = 150
            width = cols * cell_width
            height = rows * cell_height + 50  # Additional height for title
            
            # Create image
            image = Image.new('RGB', (width, height), color=(0, 0, 0))
            draw = ImageDraw.Draw(image)
            
            # Draw title
            title = f"Data Comparison - {system_name} - {item_count} Items"
            if hasattr(draw, 'text'):
                draw.text((10, 10), title, fill=(255, 255, 255))
            
            # Process each data item
            for idx, data in enumerate(data_items):
                # Map data to colors
                colors = system.map_data_to_colors(data)
                combined_color = system.combine_colors(colors)
                rgb_color = tuple(combined_color[:3])
                
                # Calculate position
                col = idx % cols
                row = idx // cols
                x_offset = col * cell_width
                y_offset = row * cell_height + 50  # Account for title
                
                # Draw cell
                draw.rectangle(
                    [x_offset, y_offset, x_offset + cell_width - 2, y_offset + cell_height - 2],
                    fill=rgb_color,
                    outline=(64, 64, 64)
                )
                
                # Add item number
                if hasattr(draw, 'text'):
                    draw.text(
                        (x_offset + 5, y_offset + 5),
                        f"Item {idx+1}",
                        fill=system._get_contrast_color(rgb_color)
                    )
            
            # Save image
            output_path = os.path.join(system.output_dir, filename)
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            image.save(output_path)
            
            return output_path
    
    def create_color_palette(self, 
                            data: Any,
                            system_name: str = "default",
                            colors: int = 12,
                            width: int = 600,
                            height: int = 100,
                            filename: Optional[str] = None) -> str:
        """Create a color palette derived from the data"""
        with self._lock:
            if not PIL_AVAILABLE:
                print("PIL not available, cannot create color palette")
                return ""
            
            if system_name not in self.evolution_systems:
                if system_name != "default":
                    print(f"Evolution system '{system_name}' not found, using default")
                system_name = "default"
                
                # Create default if needed
                if system_name not in self.evolution_systems:
                    self._create_default_system()
            
            system = self.evolution_systems[system_name]
            
            # Generate filename if not provided
            if filename is None:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"{system_name}_palette_{timestamp}.png"
            
            # Map data to initial color
            mapped_colors = system.map_data_to_colors(data)
            base_color = system.combine_colors(mapped_colors)
            
            # Generate a palette by evolving colors
            palette = []
            
            # Create three different color sequences
            # 1. Varying hue
            base_hsv = colorsys.rgb_to_hsv(
                base_color[0] / system.color_depth,
                base_color[1] / system.color_depth,
                base_color[2] / system.color_depth
            )
            
            hue_seq_count = colors // 3
            for i in range(hue_seq_count):
                h = (base_hsv[0] + i / hue_seq_count) % 1.0
                rgb = colorsys.hsv_to_rgb(h, base_hsv[1], base_hsv[2])
                palette.append((
                    int(rgb[0] * system.color_depth),
                    int(rgb[1] * system.color_depth),
                    int(rgb[2] * system.color_depth)
                ))
            
            # 2. Varying saturation
            sat_seq_count = colors // 3
            for i in range(sat_seq_count):
                s = 0.3 + (i / sat_seq_count) * 0.7  # 0.3 to 1.0
                rgb = colorsys.hsv_to_rgb(base_hsv[0], s, base_hsv[2])
                palette.append((
                    int(rgb[0] * system.color_depth),
                    int(rgb[1] * system.color_depth),
                    int(rgb[2] * system.color_depth)
                ))
            
            # 3. Varying brightness
            val_seq_count = colors - hue_seq_count - sat_seq_count
            for i in range(val_seq_count):
                v = 0.3 + (i / val_seq_count) * 0.7  # 0.3 to 1.0
                rgb = colorsys.hsv_to_rgb(base_hsv[0], base_hsv[1], v)
                palette.append((
                    int(rgb[0] * system.color_depth),
                    int(rgb[1] * system.color_depth),
                    int(rgb[2] * system.color_depth)
                ))
            
            # Create palette image
            cell_width = width // len(palette)
            image = Image.new('RGB', (width, height), color=(0, 0, 0))
            draw = ImageDraw.Draw(image)
            
            # Draw palette colors
            for i, color in enumerate(palette):
                x1 = i * cell_width
                x2 = (i + 1) * cell_width
                draw.rectangle([x1, 0, x2, height], fill=color)
            
            # Save image
            output_path = os.path.join(system.output_dir, filename)
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            image.save(output_path)
            
            # Return color codes along with path
            hex_palette = [f"#{r:02x}{g:02x}{b:02x}" for r, g, b in palette]
            
            system.data_stream.publish({
                "type": "palette_created",
                "path": output_path,
                "colors": hex_palette,
                "timestamp": time.time()
            }) if system.data_stream else None
            
            return output_path
    
    def get_evolution_system(self, name: str = "default") -> Optional[ColorEvolutionSystem]:
        """Get an evolution system by name"""
        with self._lock:
            return self.evolution_systems.get(name)
    
    def save_configuration(self, filename: str = "visualizer_config.json") -> bool:
        """Save the visualizer configuration to a file"""
        with self._lock:
            try:
                config = {
                    "dimensions": self.dimensions,
                    "color_scheme": self.color_scheme,
                    "pattern_complexity": self.pattern_complexity,
                    "output_dir": self.output_dir,
                    "evolution_systems": {
                        name: system.to_dict()
                        for name, system in self.evolution_systems.items()
                    },
                    "timestamp": time.time()
                }
                
                config_path = os.path.join(self.output_dir, filename)
                os.makedirs(os.path.dirname(config_path), exist_ok=True)
                
                with open(config_path, 'w') as f:
                    json.dump(config, f, indent=2)
                
                return True
            except Exception as e:
                print(f"Error saving configuration: {e}")
                return False
    
    @classmethod
    def load_configuration(cls, filename: str) -> Optional['DataEvolutionVisualizer']:
        """Load a visualizer configuration from a file"""
        if not os.path.exists(filename):
            print(f"Configuration file not found: {filename}")
            return None
        
        try:
            with open(filename, 'r') as f:
                config = json.load(f)
            
            # Create visualizer with basic settings
            visualizer = cls(
                dimensions=config.get("dimensions", DEFAULT_COLOR_DIMENSIONS),
                color_scheme=config.get("color_scheme", "rainbow"),
                pattern_complexity=config.get("pattern_complexity", DEFAULT_PATTERN_COMPLEXITY),
                output_dir=config.get("output_dir", DEFAULT_OUTPUT_DIR)
            )
            
            # Load evolution systems
            for name, system_config in config.get("evolution_systems", {}).items():
                if name != "default":  # Skip default which is already created
                    system = ColorEvolutionSystem.from_dict(system_config)
                    visualizer.evolution_systems[name] = system
            
            return visualizer
        except Exception as e:
            print(f"Error loading configuration: {e}")
            return None

def main():
    """Main function for CLI usage"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Evolutionary Color Visualizer")
    parser.add_argument("--data", help="Data to visualize (text, number, or JSON)")
    parser.add_argument("--mode", choices=[m.name for m in EvolutionMode], default="LINEAR", help="Evolution mode")
    parser.add_argument("--steps", type=int, default=DEFAULT_EVOLUTION_STEPS, help="Number of evolution steps")
    parser.add_argument("--dimensions", type=int, default=DEFAULT_COLOR_DIMENSIONS, help="Number of color dimensions")
    parser.add_argument("--scheme", choices=list(COLOR_SCHEMES.keys()), default="rainbow", help="Color scheme")
    parser.add_argument("--output", help="Output file path")
    parser.add_argument("--width", type=int, default=800, help="Output image width")
    parser.add_argument("--height", type=int, default=600, help="Output image height")
    parser.add_argument("--animate", action="store_true", help="Create animation")
    parser.add_argument("--duration", type=int, default=100, help="Animation frame duration in ms")
    parser.add_argument("--palette", action="store_true", help="Create color palette")
    
    args = parser.parse_args()
    
    # Create visualizer
    visualizer = DataEvolutionVisualizer(
        dimensions=args.dimensions,
        color_scheme=args.scheme
    )
    
    # Create evolution system with specified mode
    system_name = f"{args.mode.lower()}_system"
    visualizer.create_evolution_system(
        name=system_name,
        mode=EvolutionMode[args.mode],
        dimensions=args.dimensions,
        color_scheme=args.scheme
    )
    
    # Parse data
    data = args.data
    if data:
        try:
            # Try to parse as JSON
            data = json.loads(data)
        except json.JSONDecodeError:
            try:
                # Try to parse as number
                data = float(data)
            except ValueError:
                # Use as string
                pass
    else:
        # Default data
        data = "evolutionary_color_visualizer"
    
    # Generate output filename if not provided
    output_path = args.output
    if not output_path:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        if args.animate:
            output_path = f"evolution_{timestamp}.gif"
        else:
            output_path = f"evolution_{timestamp}.png"
    
    # Create visualization based on options
    if args.palette:
        # Create color palette
        output = visualizer.create_color_palette(
            data=data,
            system_name=system_name,
            colors=12,
            width=args.width,
            height=args.height,
            filename=output_path
        )
        print(f"Color palette created: {output}")
    
    elif args.animate:
        # Create animation
        output = visualizer.create_animation(
            data=data,
            system_name=system_name,
            steps=args.steps,
            width=args.width,
            height=args.height,
            duration=args.duration,
            filename=output_path
        )
        print(f"Animation created: {output}")
    
    else:
        # Create static visualization
        output = visualizer.visualize_data(
            data=data,
            system_name=system_name,
            steps=args.steps,
            width=args.width,
            height=args.height,
            filename=output_path
        )
        print(f"Visualization created: {output}")

if __name__ == "__main__":
    main()