#!/usr/bin/env python3
# Data Sea Visualizer - Creates an ocean-like visualization of data
# Enhances wish_console with flowing data visualization patterns

import os
import sys
import time
import json
import random
import math
import curses
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple, Set

class WaveProperties:
    """Properties of a data wave"""
    def __init__(self, 
                 amplitude: float = 1.0, 
                 frequency: float = 1.0,
                 phase: float = 0.0,
                 speed: float = 1.0,
                 color_index: int = 0):
        self.amplitude = amplitude  # Wave height
        self.frequency = frequency  # Wave frequency
        self.phase = phase          # Wave phase
        self.speed = speed          # Wave movement speed
        self.color_index = color_index  # Color of the wave
        
class DataPoint:
    """Represents a single data point in the sea"""
    def __init__(self, 
                 x: float, 
                 y: float, 
                 value: float, 
                 category: str = "",
                 properties: Dict[str, Any] = None):
        self.x = x
        self.y = y
        self.value = value
        self.category = category
        self.properties = properties or {}
        self.char = '●'  # Default visualization character
        self.color = 0   # Default color
        self.velocity_x = 0.0
        self.velocity_y = 0.0
        self.age = 0     # How many cycles this point has existed
        
    def update(self, dt: float, waves: List[WaveProperties]) -> None:
        """Update data point position based on waves and time"""
        # Apply wave effects to position
        wave_x = 0.0
        wave_y = 0.0
        
        for wave in waves:
            # Calculate wave influence on this point
            phase = wave.phase + self.x * wave.frequency
            wave_y += wave.amplitude * math.sin(phase)
            wave_x += wave.amplitude * 0.2 * math.cos(phase)  # Smaller X influence
            
        # Update position with wave influence and velocity
        self.x += self.velocity_x * dt + wave_x * dt
        self.y += self.velocity_y * dt + wave_y * dt
        
        # Age the point
        self.age += 1
        
    def is_visible(self, width: int, height: int) -> bool:
        """Check if the point is within visible bounds"""
        return 0 <= int(self.x) < width and 0 <= int(self.y) < height

class SeaOfData:
    """Creates and manages a visual sea of data points"""
    
    # Color pairs mapping
    COLORS = {
        "BLUE": 1,
        "GREEN": 2,
        "CYAN": 3,
        "RED": 4,
        "MAGENTA": 5,
        "YELLOW": 6,
        "WHITE": 7,
        "BRIGHT_BLUE": 8,
        "BRIGHT_GREEN": 9,
        "BRIGHT_CYAN": 10,
        "BRIGHT_RED": 11,
        "BRIGHT_MAGENTA": 12,
        "BRIGHT_YELLOW": 13,
        "BRIGHT_WHITE": 14
    }
    
    # Characters used for rendering based on value
    CHARS = [' ', '·', '°', 'o', 'O', '0', '@', '█']
    
    def __init__(self):
        self.data_points: List[DataPoint] = []
        self.waves: List[WaveProperties] = []
        self.width = 80
        self.height = 24
        self.time = 0.0
        self.categories: Dict[str, Dict[str, Any]] = {}
        self.active_category = None
        self.depth_map = []  # Water depth at each position
        self.particles = []  # Special effect particles
        self.debug_mode = False
        
        # Initialize with default waves
        self._init_default_waves()
        
    def _init_default_waves(self) -> None:
        """Initialize default wave patterns"""
        self.waves = [
            WaveProperties(amplitude=0.2, frequency=0.05, phase=0.0, speed=0.3, color_index=1),
            WaveProperties(amplitude=0.1, frequency=0.1, phase=1.57, speed=0.5, color_index=3),
            WaveProperties(amplitude=0.15, frequency=0.08, phase=0.5, speed=0.2, color_index=2)
        ]
        
    def setup_curses_colors(self) -> None:
        """Initialize curses color pairs"""
        curses.start_color()
        curses.use_default_colors()
        
        # Initialize color pairs
        curses.init_pair(1, curses.COLOR_BLUE, -1)
        curses.init_pair(2, curses.COLOR_GREEN, -1)
        curses.init_pair(3, curses.COLOR_CYAN, -1)
        curses.init_pair(4, curses.COLOR_RED, -1)
        curses.init_pair(5, curses.COLOR_MAGENTA, -1)
        curses.init_pair(6, curses.COLOR_YELLOW, -1)
        curses.init_pair(7, curses.COLOR_WHITE, -1)
        
        # Initialize bright colors if supported
        if curses.COLORS >= 16:
            curses.init_pair(8, curses.COLOR_BLUE + 8, -1)
            curses.init_pair(9, curses.COLOR_GREEN + 8, -1)
            curses.init_pair(10, curses.COLOR_CYAN + 8, -1)
            curses.init_pair(11, curses.COLOR_RED + 8, -1)
            curses.init_pair(12, curses.COLOR_MAGENTA + 8, -1)
            curses.init_pair(13, curses.COLOR_YELLOW + 8, -1)
            curses.init_pair(14, curses.COLOR_WHITE + 8, -1)
            
    def resize(self, width: int, height: int) -> None:
        """Resize the data sea"""
        self.width = width
        self.height = height
        
        # Recreate depth map
        self._init_depth_map()
        
    def _init_depth_map(self) -> None:
        """Initialize the depth map for the sea"""
        self.depth_map = [[0.0 for _ in range(self.width)] for _ in range(self.height)]
        
        # Create some terrain features
        for _ in range(5):  # Create 5 random features
            feature_type = random.choice(["ridge", "trench", "plateau"])
            x_center = random.randint(0, self.width-1)
            y_center = random.randint(0, self.height-1)
            radius = random.randint(3, 10)
            intensity = random.uniform(0.3, 1.0)
            
            # Create the feature
            for y in range(max(0, y_center-radius), min(self.height, y_center+radius)):
                for x in range(max(0, x_center-radius), min(self.width, x_center+radius)):
                    distance = math.sqrt((x - x_center)**2 + (y - y_center)**2)
                    if distance <= radius:
                        factor = (radius - distance) / radius
                        
                        if feature_type == "ridge":
                            self.depth_map[y][x] += factor * intensity
                        elif feature_type == "trench":
                            self.depth_map[y][x] -= factor * intensity
                        else:  # plateau
                            if distance <= radius * 0.7:
                                self.depth_map[y][x] += intensity * 0.8
        
        # Normalize depth map to range 0.0 - 1.0
        min_depth = min(min(row) for row in self.depth_map)
        max_depth = max(max(row) for row in self.depth_map)
        depth_range = max_depth - min_depth if max_depth > min_depth else 1.0
        
        for y in range(self.height):
            for x in range(self.width):
                self.depth_map[y][x] = (self.depth_map[y][x] - min_depth) / depth_range
        
    def add_data_point(self, 
                      value: float, 
                      category: str = "", 
                      properties: Dict[str, Any] = None) -> DataPoint:
        """Add a new data point to the sea"""
        # Start at a random position, typically from the edges
        side = random.choice(["top", "bottom", "left", "right"])
        
        if side == "top":
            x = random.uniform(0, self.width)
            y = 0
            velocity_y = random.uniform(0.5, 2.0)
            velocity_x = random.uniform(-0.5, 0.5)
        elif side == "bottom":
            x = random.uniform(0, self.width)
            y = self.height - 1
            velocity_y = random.uniform(-2.0, -0.5)
            velocity_x = random.uniform(-0.5, 0.5)
        elif side == "left":
            x = 0
            y = random.uniform(0, self.height)
            velocity_x = random.uniform(0.5, 2.0)
            velocity_y = random.uniform(-0.5, 0.5)
        else:  # right
            x = self.width - 1
            y = random.uniform(0, self.height)
            velocity_x = random.uniform(-2.0, -0.5)
            velocity_y = random.uniform(-0.5, 0.5)
            
        # Create data point
        point = DataPoint(x, y, value, category, properties)
        point.velocity_x = velocity_x
        point.velocity_y = velocity_y
        
        # Assign a character based on value
        value_index = min(int(value * len(self.CHARS)), len(self.CHARS) - 1)
        point.char = self.CHARS[value_index]
        
        # Assign a color based on category
        if category in self.categories:
            point.color = self.categories[category].get("color", 0)
        else:
            # Create a new category with a random color
            color = random.choice(list(self.COLORS.values()))
            self.categories[category] = {
                "color": color,
                "count": 0,
                "total_value": 0.0
            }
            point.color = color
            
        # Update category statistics
        if category:
            self.categories[category]["count"] += 1
            self.categories[category]["total_value"] += value
            
        self.data_points.append(point)
        return point
        
    def add_data_burst(self, 
                      center_x: float, 
                      center_y: float, 
                      count: int, 
                      value_range: Tuple[float, float] = (0.3, 0.9),
                      category: str = "") -> None:
        """Add a burst of data points around a center point"""
        for _ in range(count):
            angle = random.uniform(0, 2 * math.pi)
            distance = random.uniform(1, 5)
            x = center_x + math.cos(angle) * distance
            y = center_y + math.sin(angle) * distance
            
            value = random.uniform(value_range[0], value_range[1])
            
            point = DataPoint(x, y, value, category)
            value_index = min(int(value * len(self.CHARS)), len(self.CHARS) - 1)
            point.char = self.CHARS[value_index]
            
            # Velocity pointing outward from center
            point.velocity_x = math.cos(angle) * random.uniform(0.5, 2.0)
            point.velocity_y = math.sin(angle) * random.uniform(0.5, 2.0)
            
            # Assign color
            if category in self.categories:
                point.color = self.categories[category].get("color", 0)
            
            self.data_points.append(point)
            
    def add_data_stream(self, 
                       start_x: float, 
                       start_y: float,
                       end_x: float,
                       end_y: float,
                       count: int,
                       value: float = 0.7,
                       category: str = "") -> None:
        """Add a stream of data points from start to end"""
        dx = end_x - start_x
        dy = end_y - start_y
        length = math.sqrt(dx*dx + dy*dy)
        
        if length == 0:
            return
            
        # Normalize direction
        dx /= length
        dy /= length
        
        # Add points along the path with some randomness
        for i in range(count):
            progress = i / count
            jitter_x = random.uniform(-1, 1)
            jitter_y = random.uniform(-1, 1)
            
            x = start_x + dx * progress * length + jitter_x
            y = start_y + dy * progress * length + jitter_y
            
            point = DataPoint(x, y, value, category)
            value_index = min(int(value * len(self.CHARS)), len(self.CHARS) - 1)
            point.char = self.CHARS[value_index]
            
            # Velocity in the direction of the stream
            point.velocity_x = dx * random.uniform(0.5, 2.0)
            point.velocity_y = dy * random.uniform(0.5, 2.0)
            
            # Assign color
            if category in self.categories:
                point.color = self.categories[category].get("color", 0)
            
            self.data_points.append(point)
    
    def update(self, dt: float) -> None:
        """Update the data sea state"""
        self.time += dt
        
        # Update waves
        for wave in self.waves:
            wave.phase += wave.speed * dt
            
        # Update data points
        for point in self.data_points:
            point.update(dt, self.waves)
            
        # Remove points that are out of bounds or too old
        self.data_points = [p for p in self.data_points 
                           if p.is_visible(self.width, self.height) and p.age < 200]
                           
        # Update particles
        for particle in self.particles:
            particle["age"] += 1
            particle["x"] += particle["vx"] * dt
            particle["y"] += particle["vy"] * dt
            
        # Remove old particles
        self.particles = [p for p in self.particles 
                         if p["age"] < p["lifetime"] and 
                         0 <= int(p["x"]) < self.width and 
                         0 <= int(p["y"]) < self.height]
    
    def add_particle_effect(self, 
                          x: float, 
                          y: float, 
                          effect_type: str = "splash", 
                          color: int = 7) -> None:
        """Add a special particle effect"""
        if effect_type == "splash":
            # Create splash effect - particles moving outward
            for _ in range(10):
                angle = random.uniform(0, 2 * math.pi)
                speed = random.uniform(2.0, 5.0)
                vx = math.cos(angle) * speed
                vy = math.sin(angle) * speed
                lifetime = random.randint(5, 15)
                
                self.particles.append({
                    "x": x,
                    "y": y,
                    "vx": vx,
                    "vy": vy,
                    "char": random.choice(["*", ".", "o", "°"]),
                    "color": color,
                    "age": 0,
                    "lifetime": lifetime
                })
        
        elif effect_type == "bubble":
            # Rising bubbles
            for _ in range(5):
                vx = random.uniform(-0.5, 0.5)
                vy = random.uniform(-2.0, -0.5)
                lifetime = random.randint(10, 20)
                
                self.particles.append({
                    "x": x,
                    "y": y,
                    "vx": vx,
                    "vy": vy,
                    "char": random.choice(["o", "O", "°", "•"]),
                    "color": color,
                    "age": 0,
                    "lifetime": lifetime
                })
                
        elif effect_type == "ripple":
            # Expanding ripple
            self.particles.append({
                "x": x,
                "y": y, 
                "vx": 0,
                "vy": 0,
                "radius": 1,
                "max_radius": 8,
                "char": "○",
                "color": color,
                "age": 0,
                "lifetime": 15,
                "type": "ripple"
            })
            
    def render(self, stdscr) -> None:
        """Render the data sea to the curses window"""
        # Clear screen
        stdscr.clear()
        
        # Get terminal dimensions
        height, width = stdscr.getmaxyx()
        height = min(height, self.height)
        width = min(width, self.width)
        
        # Render depth map as background
        for y in range(height):
            for x in range(width):
                if y < len(self.depth_map) and x < len(self.depth_map[0]):
                    depth = self.depth_map[y][x]
                    depth_char = " "
                    if depth < 0.3:
                        depth_char = "·"
                    elif depth < 0.5:
                        depth_char = "·"
                    elif depth < 0.7:
                        depth_char = ":"
                    else:
                        depth_char = "·"
                        
                    color = curses.color_pair(1)  # Blue for water
                    stdscr.addstr(y, x, depth_char, color)
        
        # Render particles
        for particle in self.particles:
            x, y = int(particle["x"]), int(particle["y"])
            if 0 <= x < width and 0 <= y < height:
                if "type" in particle and particle["type"] == "ripple":
                    # Render ripple as circle
                    radius = particle["radius"]
                    progress = particle["age"] / particle["lifetime"]
                    particle["radius"] = progress * particle["max_radius"]
                    
                    for angle in range(0, 360, 45):  # Draw 8 points around circle
                        rad_angle = math.radians(angle)
                        rx = int(x + math.cos(rad_angle) * radius)
                        ry = int(y + math.sin(rad_angle) * radius)
                        
                        if 0 <= rx < width and 0 <= ry < height:
                            color = curses.color_pair(particle["color"])
                            stdscr.addstr(ry, rx, particle["char"], color)
                else:
                    # Regular particle
                    color = curses.color_pair(particle["color"])
                    try:
                        stdscr.addstr(y, x, particle["char"], color)
                    except curses.error:
                        pass  # Ignore errors from writing at bottom-right corner
        
        # Render data points
        for point in self.data_points:
            x, y = int(point.x), int(point.y)
            if 0 <= x < width and 0 <= y < height:
                color = curses.color_pair(point.color)
                try:
                    stdscr.addstr(y, x, point.char, color)
                except curses.error:
                    pass  # Ignore errors from writing at bottom-right corner
                    
        # Render category stats if debug mode is on
        if self.debug_mode:
            y_pos = 1
            stdscr.addstr(0, 0, "Data Sea Categories:", curses.A_BOLD)
            
            for category, stats in self.categories.items():
                if y_pos < height - 1:
                    color = curses.color_pair(stats["color"])
                    info = f"{category}: {stats['count']} pts"
                    stdscr.addstr(y_pos, 0, info, color)
                    y_pos += 1
                    
            # Show total points
            if y_pos < height - 1:
                total = sum(stats["count"] for stats in self.categories.values())
                stdscr.addstr(y_pos, 0, f"Total: {total} pts")
                
        # Refresh the screen
        stdscr.refresh()
        
    def integrate_with_wish_console(self, wish_console, conn_manager=None) -> None:
        """Integrate sea of data with wish console data"""
        # Create data points from memories
        for i, memory in enumerate(wish_console.memories):
            # Extract value from memory (normalized 0-1)
            if hasattr(memory, "truth_value"):
                value = memory.truth_value / 10.0  # Assuming 0-10 scale
            else:
                value = random.uniform(0.3, 0.9)  # Random if no truth value
                
            # Determine category from memory tags
            category = "unknown"
            for tag in memory.tags:
                if tag.startswith("#"):
                    category = tag.strip("#")
                    break
                    
            # Create data point properties
            properties = {
                "id": f"memory_{i}",
                "content": memory.content[:20],  # First 20 chars of content
                "dimensions": memory.dimensions,
                "tags": memory.tags
            }
            
            # Add data point
            self.add_data_point(value, category, properties)
            
        # Create data points from API connections if available
        if hasattr(wish_console, "apis"):
            for api_name, api in wish_console.apis.items():
                value = 0.8 if api.is_online else 0.2
                category = "api"
                
                properties = {
                    "id": f"api_{api_name}",
                    "url": api.url,
                    "online": api.is_online
                }
                
                self.add_data_point(value, category, properties)
                
        # Integrate with connection manager if available
        if conn_manager:
            for conn_name, conn in conn_manager.connections.items():
                # Value based on connection state
                if conn.state == "active":
                    value = 0.9
                elif conn.state == "glitched":
                    value = 0.5
                else:
                    value = 0.3
                    
                category = conn.conn_type
                
                properties = {
                    "id": conn_name,
                    "source": conn.source,
                    "target": conn.target,
                    "state": conn.state
                }
                
                self.add_data_point(value, category, properties)
                
                # Add stream between connected points
                if random.random() < 0.3:  # Only for some connections
                    # Find random positions for source and target
                    start_x = random.uniform(0, self.width)
                    start_y = random.uniform(0, self.height)
                    end_x = random.uniform(0, self.width)
                    end_y = random.uniform(0, self.height)
                    
                    # Add data stream
                    self.add_data_stream(
                        start_x, start_y, end_x, end_y,
                        count=random.randint(5, 15),
                        value=value,
                        category=category
                    )
        
def main(stdscr):
    """Main function for standalone testing"""
    # Setup curses
    curses.curs_set(0)  # Hide cursor
    stdscr.timeout(50)  # Non-blocking input with 50ms timeout
    
    # Create sea of data
    sea = SeaOfData()
    sea.setup_curses_colors()
    
    # Get terminal dimensions
    height, width = stdscr.getmaxyx()
    sea.resize(width, height)
    sea._init_depth_map()
    
    # Add some initial data points
    for _ in range(30):
        category = random.choice(["memory", "api", "dimension", "drive"])
        value = random.uniform(0.2, 1.0)
        sea.add_data_point(value, category)
    
    # Main loop
    running = True
    last_time = time.time()
    
    while running:
        # Calculate time delta
        current_time = time.time()
        dt = current_time - last_time
        last_time = current_time
        
        # Handle input
        try:
            key = stdscr.getch()
            if key == ord('q'):
                running = False
            elif key == ord('b'):
                # Add data burst at random location
                x = random.uniform(0, width)
                y = random.uniform(0, height)
                category = random.choice(["memory", "api", "dimension", "drive"])
                sea.add_data_burst(x, y, random.randint(10, 20), category=category)
            elif key == ord('s'):
                # Add splash effect
                x = random.uniform(0, width)
                y = random.uniform(0, height)
                sea.add_particle_effect(x, y, "splash", random.randint(1, 7))
            elif key == ord('r'):
                # Add ripple effect
                x = random.uniform(0, width)
                y = random.uniform(0, height)
                sea.add_particle_effect(x, y, "ripple", random.randint(1, 7))
            elif key == ord('d'):
                # Toggle debug mode
                sea.debug_mode = not sea.debug_mode
        except:
            pass
        
        # Randomly add new data points
        if random.random() < 0.1:  # 10% chance each frame
            category = random.choice(["memory", "api", "dimension", "drive"])
            value = random.uniform(0.2, 1.0)
            sea.add_data_point(value, category)
            
        # Randomly add special effects
        if random.random() < 0.02:  # 2% chance each frame
            x = random.uniform(0, width)
            y = random.uniform(0, height)
            effect = random.choice(["splash", "bubble", "ripple"])
            sea.add_particle_effect(x, y, effect, random.randint(1, 7))
        
        # Update and render
        sea.update(dt)
        sea.render(stdscr)
        
        # Sleep to control frame rate
        time.sleep(0.05)

# Example usage
if __name__ == "__main__":
    try:
        curses.wrapper(main)
    except KeyboardInterrupt:
        print("Exiting Data Sea Visualizer")