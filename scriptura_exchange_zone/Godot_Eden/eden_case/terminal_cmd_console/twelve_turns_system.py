#!/usr/bin/env python3
# Twelve Turns System - Command processing with progressive cycles
# Integrates visualization, connection mapping, and cyclical pattern recognition

import os
import sys
import time
import json
import random
import math
import threading
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple, Set, Union, Callable

# Constants
CONFIG = {
    "turn_count": 12,               # Number of turns in a complete cycle
    "progression_sequence": [0, 1, 2, 3, 6, 8, 9, 8, 1, 2],  # Primary progression sequence from user
    "command_limit_per_turn": 5,    # Maximum commands processed in one turn
    "connection_strength": 10,      # Base strength of connections
    "easing_functions": True,       # Use easing functions for transitions
    "color_connections": True,      # Visualize connections with colors
    "offline_mode": True,           # Work without external dependencies
    "jesus_mode": False,            # Special mode with regenerative properties
    "tyran_duear_mode": False,      # Alternative command processing mode
    "auto_turn_advance": True,      # Automatically advance turns
    "turn_duration": 120,           # Seconds per turn (120 seconds = 2 minutes for word game turns)
    "turn_4_duration": 40,          # Special reduced duration for turn 4
    "word_game_duration": 120,      # Duration for word game play (2 minutes per turn)
    "display_mode": "terminal",     # Output display mode (terminal, file, both)
    "debug_mode": False,            # Show debug information
    "save_interval": 300,           # Save state every 5 minutes
    "connection_decay_rate": 0.05,  # Rate at which connections decay
    "continue_moving": True,        # Continue moving together in time
    "word_play_enabled": True,      # Enable word game play mechanics
    
    # Multi-window and data folding configuration
    "multi_window_enabled": True,   # Enable multi-window functionality
    "window_count": 3,              # Number of windows to manage
    "data_folding_enabled": True,   # Enable data folding/unfolding
    "fold_interval_seconds": 60,    # Seconds between auto-fold/unfold operations
    "fold_interval_minutes": 2,     # Minutes between major fold/unfold operations
    "account_sync_enabled": True,   # Synchronize data across accounts
    "single_account_mode": True,    # Use a single account across windows
    
    # Black Box Device configuration
    "black_box_enabled": True,      # Enable the Black Box Device functionality
    "black_box_reason_tagging": True, # Enable reason-based tagging for Black Box
    "reason_tags": [                # Common reason tags for operations
        "#reason",                  # Generic reason tag
        "#device",                  # Device-specific tag
        "#continue",                # Continuity tag
        "#ocn",                     # OCN tag (Ongoing Connection Network)
        "#akk",                     # All Knowledge Known tag
        "#connection",              # Connection tag
        "#new",                     # New information tag
        "#claude_code",             # Claude Code integration tag
        "#memories",                # Memories tag
    ],
    "black_box_log_level": 3,       # Logging level for Black Box (1-5)
    "black_box_self_monitoring": True, # Allow Black Box to monitor itself
    "device_interconnection": True, # Allow devices to interconnect
    
    # Claude integration
    "claude_memories_enabled": True,  # Enable connection to Claude's memories
    "claude_code_integration": True,  # Enable Claude Code integration
    "use_snake_case": True,          # Use snake_case for code identifiers
    "memory_sync_interval": 30,      # Sync memories every 30 seconds
    "memory_file_paths": [           # Paths to memory files
        "/mnt/c/Users/Percision 15/CLAUDE.md",
        "/mnt/c/Users/Percision 15/CLAUDE.local.md",
    ],
    "memory_connection_strength": 15, # Memory connection strength (higher than regular)
    
    "command_colors": {             # Color mapping for command types
        "system": "#3498db",        # Blue
        "visualization": "#2ecc71", # Green
        "data": "#e74c3c",          # Red
        "connection": "#f39c12",    # Orange
        "turn": "#9b59b6",          # Purple
        "meta": "#1abc9c",          # Teal
        "word": "#e67e22",          # Orange-brown for word commands
        "fold": "#16a085",          # Teal-green for folding operations
        "unfold": "#27ae60",        # Green for unfolding operations
        "reason": "#2c3e50",        # Dark blue for reason tags
        "device": "#7f8c8d",        # Gray for device operations
        "black_box": "#000000",     # Black for Black Box operations
        "claude": "#3980b3",        # Claude blue for Claude operations
        "claude_code": "#2b5d87",   # Darker blue for Claude Code operations
        "memory": "#9980fa"         # Purple for memory operations
    }
}

# Terminal colors
class Colors:
    """Terminal color codes"""
    RESET = "\033[0m"
    BLACK = "\033[30m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    WHITE = "\033[37m"
    
    # Bright versions
    BRIGHT_BLACK = "\033[90m"
    BRIGHT_RED = "\033[91m"
    BRIGHT_GREEN = "\033[92m"
    BRIGHT_YELLOW = "\033[93m"
    BRIGHT_BLUE = "\033[94m"
    BRIGHT_MAGENTA = "\033[95m"
    BRIGHT_CYAN = "\033[96m"
    BRIGHT_WHITE = "\033[97m"
    
    # Background colors
    BG_BLACK = "\033[40m"
    BG_RED = "\033[41m"
    BG_GREEN = "\033[42m"
    BG_YELLOW = "\033[43m"
    BG_BLUE = "\033[44m"
    BG_MAGENTA = "\033[45m"
    BG_CYAN = "\033[46m"
    BG_WHITE = "\033[47m"
    
    @staticmethod
    def rgb(r: int, g: int, b: int) -> str:
        """Generate RGB color code"""
        return f"\033[38;2;{r};{g};{b}m"
        
    @staticmethod
    def bg_rgb(r: int, g: int, b: int) -> str:
        """Generate RGB background color code"""
        return f"\033[48;2;{r};{g};{b}m"
        
    @staticmethod
    def hex_to_rgb(hex_color: str) -> Tuple[int, int, int]:
        """Convert hex color to RGB"""
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
        
    @staticmethod
    def hex(hex_color: str) -> str:
        """Generate color code from hex"""
        r, g, b = Colors.hex_to_rgb(hex_color)
        return Colors.rgb(r, g, b)

class EasingFunctions:
    """Easing functions for smooth transitions"""
    
    @staticmethod
    def linear(t: float) -> float:
        """Linear easing"""
        return t
        
    @staticmethod
    def ease_in_quad(t: float) -> float:
        """Quadratic ease in"""
        return t * t
        
    @staticmethod
    def ease_out_quad(t: float) -> float:
        """Quadratic ease out"""
        return t * (2 - t)
        
    @staticmethod
    def ease_in_out_quad(t: float) -> float:
        """Quadratic ease in and out"""
        return 2 * t * t if t < 0.5 else -1 + (4 - 2 * t) * t
        
    @staticmethod
    def ease_in_cubic(t: float) -> float:
        """Cubic ease in"""
        return t * t * t
        
    @staticmethod
    def ease_out_cubic(t: float) -> float:
        """Cubic ease out"""
        return (t - 1) * (t - 1) * (t - 1) + 1
        
    @staticmethod
    def ease_in_out_cubic(t: float) -> float:
        """Cubic ease in and out"""
        return 4 * t * t * t if t < 0.5 else (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
        
    @staticmethod
    def ease_in_sine(t: float) -> float:
        """Sinusoidal ease in"""
        return 1 - math.cos(t * math.pi / 2)
        
    @staticmethod
    def ease_out_sine(t: float) -> float:
        """Sinusoidal ease out"""
        return math.sin(t * math.pi / 2)
        
    @staticmethod
    def ease_in_out_sine(t: float) -> float:
        """Sinusoidal ease in and out"""
        return -(math.cos(math.pi * t) - 1) / 2
        
    @staticmethod
    def get_function(name: str) -> Callable[[float], float]:
        """Get easing function by name"""
        functions = {
            "linear": EasingFunctions.linear,
            "ease_in_quad": EasingFunctions.ease_in_quad,
            "ease_out_quad": EasingFunctions.ease_out_quad,
            "ease_in_out_quad": EasingFunctions.ease_in_out_quad,
            "ease_in_cubic": EasingFunctions.ease_in_cubic,
            "ease_out_cubic": EasingFunctions.ease_out_cubic,
            "ease_in_out_cubic": EasingFunctions.ease_in_out_cubic,
            "ease_in_sine": EasingFunctions.ease_in_sine,
            "ease_out_sine": EasingFunctions.ease_out_sine,
            "ease_in_out_sine": EasingFunctions.ease_in_out_sine
        }
        return functions.get(name, EasingFunctions.linear)

class Command:
    """Represents a command in the system"""
    
    def __init__(self, 
                raw_text: str, 
                command_type: str = "system", 
                priority: int = 5,
                turn_index: int = 0):
        self.raw_text = raw_text
        self.command_type = command_type
        self.priority = priority  # 1-10, 10 being highest
        self.turn_index = turn_index
        self.creation_time = time.time()
        self.execution_time = None
        self.executed = False
        self.result = None
        self.success = None
        self.connections: List['CommandConnection'] = []
        self.easing = "linear"
        self.progression_value = 0
        self.tags = []
        self.attempts = 0
        self.max_attempts = 3
        
        # Parse the command
        self._parse()
        
    def _parse(self) -> None:
        """Parse the command to extract metadata"""
        # Detect command type based on content
        if self.raw_text.startswith("/") or self.raw_text.startswith("!"):
            self.command_type = "system"
            
            # Extract any tags
            for word in self.raw_text.split():
                if word.startswith("#"):
                    self.tags.append(word.strip())
                    
        elif any(kw in self.raw_text.lower() for kw in ["connect", "link", "join", "bridge"]):
            self.command_type = "connection"
        elif any(kw in self.raw_text.lower() for kw in ["turn", "cycle", "phase", "step"]):
            self.command_type = "turn"
        elif any(kw in self.raw_text.lower() for kw in ["show", "display", "visualize", "render"]):
            self.command_type = "visualization"
        elif any(kw in self.raw_text.lower() for kw in ["data", "info", "status", "report"]):
            self.command_type = "data"
        elif any(kw in self.raw_text.lower() for kw in ["meta", "about", "system", "config"]):
            self.command_type = "meta"
            
        # Extract progression value if present
        for word in self.raw_text.split():
            if word.isdigit() and 0 <= int(word) <= 5:
                self.progression_value = int(word)
                break
                
        # Check for easing function keywords
        for easing in ["linear", "ease", "quad", "cubic", "sine"]:
            if easing in self.raw_text.lower():
                if "in_out" in self.raw_text.lower():
                    self.easing = f"ease_in_out_{easing.replace('ease_', '')}"
                elif "in" in self.raw_text.lower():
                    self.easing = f"ease_in_{easing.replace('ease_', '')}"
                elif "out" in self.raw_text.lower():
                    self.easing = f"ease_out_{easing.replace('ease_', '')}"
                else:
                    self.easing = easing
                break
                
    def execute(self) -> Any:
        """Execute the command and return the result"""
        self.attempts += 1
        
        try:
            # This would actually process the command
            # Here we just simulate success based on progression value
            success_chance = 0.7 + (self.progression_value * 0.05)
            
            # Adjust for Jesus mode (higher success rate)
            if CONFIG["jesus_mode"]:
                success_chance += 0.2
                
            # Easing functions can affect execution
            if CONFIG["easing_functions"]:
                ease_func = EasingFunctions.get_function(self.easing)
                t = self.turn_index / max(1, CONFIG["turn_count"] - 1)
                ease_factor = ease_func(t)
                success_chance *= (0.8 + 0.4 * ease_factor)
                
            self.success = random.random() < success_chance
            
            if self.success:
                self.result = f"Command executed: {self.raw_text}"
            else:
                self.result = f"Command failed: {self.raw_text}"
                
            self.execution_time = time.time()
            self.executed = True
            
            return self.result
        except Exception as e:
            self.success = False
            self.result = f"Error executing command: {e}"
            self.execution_time = time.time()
            self.executed = True
            return self.result
            
    def retry(self) -> Any:
        """Retry executing the command"""
        if self.attempts >= self.max_attempts:
            return f"Max attempts ({self.max_attempts}) reached for command: {self.raw_text}"
            
        return self.execute()
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "raw_text": self.raw_text,
            "command_type": self.command_type,
            "priority": self.priority,
            "turn_index": self.turn_index,
            "creation_time": self.creation_time,
            "execution_time": self.execution_time,
            "executed": self.executed,
            "result": self.result,
            "success": self.success,
            "easing": self.easing,
            "progression_value": self.progression_value,
            "tags": self.tags,
            "attempts": self.attempts,
            "max_attempts": self.max_attempts
        }
        
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Command':
        """Create a Command from dictionary"""
        cmd = cls(
            raw_text=data["raw_text"],
            command_type=data["command_type"],
            priority=data["priority"],
            turn_index=data["turn_index"]
        )
        
        cmd.creation_time = data["creation_time"]
        cmd.execution_time = data["execution_time"]
        cmd.executed = data["executed"]
        cmd.result = data["result"]
        cmd.success = data["success"]
        cmd.easing = data["easing"]
        cmd.progression_value = data["progression_value"]
        cmd.tags = data["tags"]
        cmd.attempts = data["attempts"]
        cmd.max_attempts = data["max_attempts"]
        
        return cmd
        
    def get_color(self) -> str:
        """Get color for this command type"""
        return CONFIG["command_colors"].get(self.command_type, "#FFFFFF")

class CommandConnection:
    """Connection between two commands"""
    
    def __init__(self,
                source: Command,
                target: Command,
                strength: float = 1.0,
                connection_type: str = "sequential"):
        self.source = source
        self.target = target
        self.strength = strength
        self.connection_type = connection_type
        self.creation_time = time.time()
        self.active = True
        self.color = self._calculate_color()
        self.properties = {}
        
    def _calculate_color(self) -> str:
        """Calculate connection color based on source and target"""
        if not CONFIG["color_connections"]:
            return "#FFFFFF"
            
        # Get source and target colors
        source_color = Colors.hex_to_rgb(self.source.get_color())
        target_color = Colors.hex_to_rgb(self.target.get_color())
        
        # Blend colors based on strength
        r = int((source_color[0] + target_color[0]) / 2)
        g = int((source_color[1] + target_color[1]) / 2)
        b = int((source_color[2] + target_color[2]) / 2)
        
        # Convert back to hex
        return f"#{r:02x}{g:02x}{b:02x}"
        
    def update(self) -> None:
        """Update connection properties"""
        # Apply decay
        self.strength *= (1.0 - CONFIG["connection_decay_rate"])
        
        # Deactivate if strength is too low
        if self.strength < 0.1:
            self.active = False
            
        # Update color
        self.color = self._calculate_color()
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "source": id(self.source),  # Use object ID as reference
            "target": id(self.target),  # Use object ID as reference
            "strength": self.strength,
            "connection_type": self.connection_type,
            "creation_time": self.creation_time,
            "active": self.active,
            "color": self.color,
            "properties": self.properties
        }

class Turn:
    """Represents a turn in the system"""
    
    def __init__(self, index: int, max_commands: int = 5):
        self.index = index
        self.max_commands = max_commands
        self.commands: List[Command] = []
        self.start_time = None
        self.end_time = None
        self.active = False
        self.complete = False
        self.progression_value = index % len(CONFIG["progression_sequence"])
        self.easing = "linear"
        self.notes = []
        self.success_rate = 0.0
        
    def start(self) -> None:
        """Start the turn"""
        self.start_time = time.time()
        self.active = True
        
    def end(self) -> None:
        """End the turn"""
        self.end_time = time.time()
        self.active = False
        self.complete = True
        
        # Calculate success rate
        if self.commands:
            successful = sum(1 for cmd in self.commands if cmd.success)
            self.success_rate = successful / len(self.commands)
            
    def add_command(self, command: Command) -> bool:
        """Add a command to this turn"""
        if len(self.commands) >= self.max_commands:
            return False
            
        command.turn_index = self.index
        self.commands.append(command)
        return True
        
    def execute_commands(self) -> List[str]:
        """Execute all commands in this turn"""
        results = []
        
        # Sort by priority (highest first)
        sorted_commands = sorted(self.commands, key=lambda c: c.priority, reverse=True)
        
        for command in sorted_commands:
            if not command.executed:
                result = command.execute()
                results.append(result)
                
        return results
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            "index": self.index,
            "max_commands": self.max_commands,
            "commands": [cmd.to_dict() for cmd in self.commands],
            "start_time": self.start_time,
            "end_time": self.end_time,
            "active": self.active,
            "complete": self.complete,
            "progression_value": self.progression_value,
            "easing": self.easing,
            "notes": self.notes,
            "success_rate": self.success_rate
        }
        
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Turn':
        """Create a Turn from dictionary"""
        turn = cls(data["index"], data["max_commands"])
        
        turn.start_time = data["start_time"]
        turn.end_time = data["end_time"]
        turn.active = data["active"]
        turn.complete = data["complete"]
        turn.progression_value = data["progression_value"]
        turn.easing = data["easing"]
        turn.notes = data["notes"]
        turn.success_rate = data["success_rate"]
        
        # Recreate commands
        turn.commands = [Command.from_dict(cmd_data) for cmd_data in data["commands"]]
        
        return turn

class TwelveTurnsSystem:
    """Main system managing the 12 turns cycle"""
    
    def __init__(self):
        # System state
        self.running = False
        self.turns: List[Turn] = []
        self.current_turn_index = 0
        self.current_turn: Optional[Turn] = None
        self.cycle_count = 0
        self.command_connections: List[CommandConnection] = []
        self.command_history: List[Command] = []
        self.turn_thread = None
        self.last_update = time.time()
        self.last_save = time.time()
        self.color_enabled = True
        self.jesus_factor = 1.0 if CONFIG["jesus_mode"] else 0.0
        self.console_width = 80
        self.stats = {
            "commands_executed": 0,
            "commands_succeeded": 0,
            "commands_failed": 0,
            "turns_completed": 0,
            "cycles_completed": 0,
            "connections_created": 0,
            "progression_reached": [0] * len(CONFIG["progression_sequence"])
        }
        
        # Initialize turn objects
        self._init_turns()
        
    def _init_turns(self) -> None:
        """Initialize turn objects"""
        self.turns = []
        
        for i in range(CONFIG["turn_count"]):
            # Use the progression sequence for commands per turn
            progression_idx = i % len(CONFIG["progression_sequence"])
            max_commands = CONFIG["progression_sequence"][progression_idx] + 1
            
            # Create the turn
            turn = Turn(i, max_commands=max_commands)
            
            # Set progression value from sequence
            turn.progression_value = CONFIG["progression_sequence"][progression_idx]
            
            # Set easing function based on position in cycle
            easing_funcs = ["linear", "ease_in_quad", "ease_out_quad", "ease_in_out_quad",
                           "ease_in_cubic", "ease_out_cubic", "ease_in_out_cubic",
                           "ease_in_sine", "ease_out_sine", "ease_in_out_sine"]
            turn.easing = easing_funcs[i % len(easing_funcs)]
            
            # Add to turns list
            self.turns.append(turn)
            
        # Set current turn
        self.current_turn_index = 0
        self.current_turn = self.turns[0]
        
    def start(self) -> bool:
        """Start the system"""
        if self.running:
            return True  # Already running
            
        # Set running flag
        self.running = True
        
        # Start the first turn
        self.current_turn.start()
        
        # Start turn processing thread if auto_turn_advance is enabled
        if CONFIG["auto_turn_advance"]:
            self.turn_thread = threading.Thread(target=self._turn_processing_thread)
            self.turn_thread.daemon = True
            self.turn_thread.start()
            
        return True
        
    def stop(self) -> None:
        """Stop the system"""
        self.running = False
        
        # Wait for thread to end
        if self.turn_thread:
            self.turn_thread.join(timeout=1.0)
            
        # Save state before exiting
        self._save_state()
        
    def _turn_processing_thread(self) -> None:
        """Thread for processing turns automatically"""
        while self.running:
            current_time = time.time()
            
            # Check if current turn should end
            if (self.current_turn and self.current_turn.active and 
                current_time - self.current_turn.start_time >= CONFIG["turn_duration"]):
                self.advance_turn()
                
            # Save state periodically
            if current_time - self.last_save >= CONFIG["save_interval"]:
                self._save_state()
                self.last_save = current_time
                
            # Sleep to reduce CPU usage
            time.sleep(0.1)
            
    def advance_turn(self) -> bool:
        """Advance to the next turn"""
        # End current turn
        if self.current_turn:
            if self.current_turn.active:
                self.current_turn.end()
                self.stats["turns_completed"] += 1
                
                # Execute any remaining commands
                if self.current_turn.commands:
                    self.current_turn.execute_commands()
                    
        # Move to next turn
        self.current_turn_index = (self.current_turn_index + 1) % CONFIG["turn_count"]
        
        # Check if we completed a cycle
        if self.current_turn_index == 0:
            self.cycle_count += 1
            self.stats["cycles_completed"] += 1
            
        # Set new current turn
        self.current_turn = self.turns[self.current_turn_index]
        
        # Start the new turn
        self.current_turn.start()
        
        # Create connections between sequential turns
        if self.turns[self.current_turn_index - 1].commands and self.current_turn.commands:
            for prev_cmd in self.turns[self.current_turn_index - 1].commands:
                for curr_cmd in self.current_turn.commands:
                    # Create connection
                    self._create_connection(prev_cmd, curr_cmd, "sequential")
                    
        return True
        
    def add_command(self, command_text: str, command_type: str = "system", priority: int = 5) -> bool:
        """Add a command to the current turn"""
        if not self.current_turn or not self.current_turn.active:
            return False
            
        # Create command object
        command = Command(command_text, command_type, priority, self.current_turn_index)
        
        # Add to current turn
        if not self.current_turn.add_command(command):
            return False
            
        # Add to history
        self.command_history.append(command)
        
        # Create connections to similar commands
        self._create_similar_connections(command)
        
        return True
        
    def execute_command(self, command_text: str) -> str:
        """Execute a command immediately outside of turn structure"""
        # Create command object
        command = Command(command_text, "system", 10, self.current_turn_index)
        
        # Execute
        result = command.execute()
        
        # Add to history
        self.command_history.append(command)
        
        # Update stats
        self.stats["commands_executed"] += 1
        if command.success:
            self.stats["commands_succeeded"] += 1
        else:
            self.stats["commands_failed"] += 1
            
        return result
        
    def _create_connection(self, 
                          source: Command, 
                          target: Command,
                          connection_type: str = "default") -> CommandConnection:
        """Create a connection between commands"""
        # Set connection strength based on configuration
        strength = CONFIG["connection_strength"] / 10.0  # Scale to 0-1
        
        # Create connection
        connection = CommandConnection(source, target, strength, connection_type)
        
        # Add to connections list
        self.command_connections.append(connection)
        
        # Add to commands' connections
        source.connections.append(connection)
        
        # Update stats
        self.stats["connections_created"] += 1
        
        return connection
        
    def _create_similar_connections(self, command: Command) -> None:
        """Create connections between similar commands"""
        # Skip if no command history
        if not self.command_history:
            return
            
        # Check last 10 commands for similarities
        recent_commands = self.command_history[-10:]
        
        for cmd in recent_commands:
            if cmd == command:
                continue
                
            # Check for similarities
            similarity = 0.0
            
            # Same command type
            if cmd.command_type == command.command_type:
                similarity += 0.3
                
            # Similar text (simple word overlap)
            cmd_words = set(cmd.raw_text.lower().split())
            command_words = set(command.raw_text.lower().split())
            word_overlap = len(cmd_words.intersection(command_words))
            
            if word_overlap > 0:
                similarity += 0.1 * word_overlap
                
            # Same progression value
            if cmd.progression_value == command.progression_value:
                similarity += 0.2
                
            # Same tags
            tag_overlap = len(set(cmd.tags).intersection(set(command.tags)))
            if tag_overlap > 0:
                similarity += 0.1 * tag_overlap
                
            # Create connection if similarity is high enough
            if similarity > 0.3:
                self._create_connection(cmd, command, "similarity")
                
    def _update_connections(self) -> None:
        """Update all connections"""
        active_connections = []
        
        for connection in self.command_connections:
            connection.update()
            
            # Keep only active connections
            if connection.active:
                active_connections.append(connection)
                
        self.command_connections = active_connections
        
    def update(self) -> None:
        """Update system state"""
        # Skip if not running
        if not self.running:
            return
            
        # Update connections
        self._update_connections()
        
        # Track last update time
        self.last_update = time.time()
        
    def get_turn_statistics(self) -> Dict[str, Any]:
        """Get statistics for all turns"""
        result = {}
        
        for turn in self.turns:
            result[f"Turn {turn.index}"] = {
                "commands": len(turn.commands),
                "max_commands": turn.max_commands,
                "progression": turn.progression_value,
                "easing": turn.easing,
                "success_rate": turn.success_rate,
                "complete": turn.complete
            }
            
        return result
        
    def get_current_progression(self) -> int:
        """Get the current progression value"""
        if not self.current_turn:
            return 0
            
        return self.current_turn.progression_value
        
    def _save_state(self) -> None:
        """Save system state to file"""
        try:
            state = {
                "timestamp": datetime.now().isoformat(),
                "turns": [turn.to_dict() for turn in self.turns],
                "current_turn_index": self.current_turn_index,
                "cycle_count": self.cycle_count,
                "command_history": [cmd.to_dict() for cmd in self.command_history[-100:]],  # Last 100 commands
                "stats": self.stats,
                "jesus_factor": self.jesus_factor
            }
            
            with open("twelve_turns_state.json", "w") as f:
                json.dump(state, f, indent=2)
                
            if CONFIG["debug_mode"]:
                print(f"State saved at {datetime.now().isoformat()}")
                
        except Exception as e:
            if CONFIG["debug_mode"]:
                print(f"Error saving state: {e}")
                
    def load_state(self) -> bool:
        """Load system state from file"""
        try:
            if os.path.exists("twelve_turns_state.json"):
                with open("twelve_turns_state.json", "r") as f:
                    state = json.load(f)
                    
                # Recreate turns
                self.turns = [Turn.from_dict(turn_data) for turn_data in state["turns"]]
                
                # Set current turn
                self.current_turn_index = state["current_turn_index"]
                self.current_turn = self.turns[self.current_turn_index] if self.turns else None
                
                # Restore other state
                self.cycle_count = state["cycle_count"]
                self.command_history = [Command.from_dict(cmd_data) for cmd_data in state["command_history"]]
                self.stats = state["stats"]
                self.jesus_factor = state["jesus_factor"]
                
                return True
        except Exception as e:
            if CONFIG["debug_mode"]:
                print(f"Error loading state: {e}")
                
        return False
        
    def toggle_jesus_mode(self) -> None:
        """Toggle Jesus mode on/off"""
        CONFIG["jesus_mode"] = not CONFIG["jesus_mode"]
        self.jesus_factor = 1.0 if CONFIG["jesus_mode"] else 0.0
        
    def toggle_tyran_mode(self) -> None:
        """Toggle Tyran Duear mode on/off"""
        CONFIG["tyran_duear_mode"] = not CONFIG["tyran_duear_mode"]
        
    def get_visualization(self) -> str:
        """Generate ASCII visualization of the system"""
        # Get terminal size
        try:
            self.console_width = os.get_terminal_size().columns
        except:
            self.console_width = 80
            
        width = self.console_width
        result = []
        
        # Title
        title = "TWELVE TURNS SYSTEM"
        result.append(self._center_text(title, width))
        result.append(self._center_text("=" * len(title), width))
        result.append("")
        
        # Current status
        cycle_info = f"Cycle: {self.cycle_count}"
        turn_info = f"Turn: {self.current_turn_index + 1}/{CONFIG['turn_count']}"
        progression = f"Progression: {self.get_current_progression()}"
        
        status_line = f"{cycle_info}   {turn_info}   {progression}"
        if self.color_enabled:
            status_line = f"{Colors.BRIGHT_CYAN}{status_line}{Colors.RESET}"
            
        result.append(self._center_text(status_line, width))
        result.append("")
        
        # Turn progress visualization
        turn_slots = []
        for i, turn in enumerate(self.turns):
            if turn.complete:
                slot = "◉" if self.color_enabled else "O"
                color = Colors.GREEN
            elif turn.active:
                slot = "◎" if self.color_enabled else ">"
                color = Colors.YELLOW
            else:
                slot = "○" if self.color_enabled else "-"
                color = Colors.RESET
                
            if self.color_enabled:
                turn_slots.append(f"{color}{slot}{Colors.RESET}")
            else:
                turn_slots.append(slot)
                
        turn_progress = " ".join(turn_slots)
        result.append(self._center_text(turn_progress, width))
        result.append("")
        
        # Current turn details
        if self.current_turn:
            turn_header = f"TURN {self.current_turn_index + 1} DETAILS"
            if self.color_enabled:
                turn_header = f"{Colors.BRIGHT_BLUE}{turn_header}{Colors.RESET}"
                
            result.append(turn_header)
            result.append("-" * len(turn_header))
            
            # Commands in current turn
            if self.current_turn.commands:
                for i, cmd in enumerate(self.current_turn.commands):
                    status = "✓" if cmd.success else "✗" if cmd.executed else "○"
                    
                    cmd_text = f"{status} {cmd.raw_text}"
                    if self.color_enabled:
                        color = Colors.hex(cmd.get_color())
                        cmd_text = f"{color}{cmd_text}{Colors.RESET}"
                        
                    result.append(cmd_text)
            else:
                result.append("No commands in current turn")
                
            # Turn progression visualization
            prog_value = self.current_turn.progression_value
            progression = ["○"] * 6  # 0-5
            for i in range(prog_value + 1):
                progression[i] = "●"
                
            prog_viz = " ".join(progression)
            if self.color_enabled:
                prog_viz = f"{Colors.BRIGHT_YELLOW}{prog_viz}{Colors.RESET}"
                
            result.append("")
            result.append(f"Progression: {prog_viz}  ({prog_value}/5)")
            
        # Connections visualization
        if self.command_connections:
            result.append("")
            result.append("CONNECTIONS")
            result.append("-----------")
            
            # Group by type
            conn_by_type = {}
            for conn in self.command_connections:
                if conn.connection_type not in conn_by_type:
                    conn_by_type[conn.connection_type] = []
                conn_by_type[conn.connection_type].append(conn)
                
            # Show counts by type
            for conn_type, conns in conn_by_type.items():
                count_text = f"{conn_type}: {len(conns)}"
                if self.color_enabled:
                    # Choose color based on type
                    if conn_type == "sequential":
                        color = Colors.BRIGHT_GREEN
                    elif conn_type == "similarity":
                        color = Colors.BRIGHT_BLUE
                    else:
                        color = Colors.BRIGHT_CYAN
                        
                    count_text = f"{color}{count_text}{Colors.RESET}"
                    
                result.append(count_text)
                
        # Special modes
        if CONFIG["jesus_mode"] or CONFIG["tyran_duear_mode"]:
            result.append("")
            modes = []
            if CONFIG["jesus_mode"]:
                modes.append("Jesus Mode: ACTIVE")
            if CONFIG["tyran_duear_mode"]:
                modes.append("Tyran Duear Mode: ACTIVE")
                
            modes_text = " | ".join(modes)
            if self.color_enabled:
                modes_text = f"{Colors.BRIGHT_MAGENTA}{modes_text}{Colors.RESET}"
                
            result.append(self._center_text(modes_text, width))
            
        # Statistics
        result.append("")
        result.append("STATISTICS")
        result.append("----------")
        result.append(f"Commands: {self.stats['commands_executed']} total, "
                     f"{self.stats['commands_succeeded']} succeeded, "
                     f"{self.stats['commands_failed']} failed")
        result.append(f"Turns completed: {self.stats['turns_completed']}")
        result.append(f"Cycles completed: {self.stats['cycles_completed']}")
        result.append(f"Connections created: {self.stats['connections_created']}")
        
        return "\n".join(result)
        
    def _center_text(self, text: str, width: int) -> str:
        """Center text in a field of given width"""
        # Remove ANSI color codes for length calculation
        clean_text = text
        for color in dir(Colors):
            if isinstance(getattr(Colors, color), str) and color.isupper():
                clean_text = clean_text.replace(getattr(Colors, color), "")
                
        padding = max(0, width - len(clean_text))
        return " " * (padding // 2) + text
        
    def integrate_with_console(self, console) -> None:
        """Integrate with a console system"""
        # Check if console has add_memory method
        if not hasattr(console, "add_memory"):
            print("Console integration failed: missing add_memory method")
            return
            
        # Add initial memory about 12 turns system
        console.add_memory(
            f"Twelve Turns System initialized with {CONFIG['turn_count']} turns and "
            f"progression sequence {CONFIG['progression_sequence']}.",
            tags=["#twelve_turns", "#system"]
        )
        
        # Try to integrate with eye tracking if available
        if hasattr(console, "eye_tracker"):
            console.add_memory(
                "Twelve Turns System detected eye tracking capability.",
                tags=["#twelve_turns", "#eye_tracking"]
            )
            
        # Start system if not already running
        if not self.running:
            self.start()

def process_command(system: TwelveTurnsSystem, command: str) -> str:
    """Process a command in the appropriate mode"""
    # Skip empty commands
    if not command:
        return ""
        
    # System commands
    if command.startswith("/"):
        cmd = command[1:].strip().lower()
        
        if cmd == "help":
            return """
Commands:
/help                - Show this help
/status              - Show system status
/advance             - Advance to next turn
/togglejesus         - Toggle Jesus mode
/toggletyran         - Toggle Tyran Duear mode
/togglecolor         - Toggle color output
/save                - Save system state
/load                - Load system state
/quit or /exit       - Exit the program

Normal text is processed as a command for the current turn
""".strip()
        elif cmd == "status":
            return system.get_visualization()
        elif cmd == "advance":
            system.advance_turn()
            return "Advanced to next turn"
        elif cmd == "togglejesus":
            system.toggle_jesus_mode()
            return f"Jesus mode: {'ON' if CONFIG['jesus_mode'] else 'OFF'}"
        elif cmd == "toggletyran":
            system.toggle_tyran_mode()
            return f"Tyran Duear mode: {'ON' if CONFIG['tyran_duear_mode'] else 'OFF'}"
        elif cmd == "togglecolor":
            system.color_enabled = not system.color_enabled
            return f"Color output: {'ON' if system.color_enabled else 'OFF'}"
        elif cmd == "save":
            system._save_state()
            return "System state saved"
        elif cmd == "load":
            success = system.load_state()
            return f"System state {'loaded' if success else 'failed to load'}"
        elif cmd in ["quit", "exit"]:
            system.stop()
            return "Exiting..."
        else:
            return f"Unknown command: {cmd}"
            
    # Process as regular command in current turn
    success = system.add_command(command)
    if success:
        return f"Command added to turn {system.current_turn_index + 1}"
    else:
        # If couldn't add to current turn, execute immediately
        result = system.execute_command(command)
        return f"Command executed immediately: {result}"

def main():
    """Main function for the Twelve Turns System"""
    print("Initializing Twelve Turns System...")
    system = TwelveTurnsSystem()
    
    # Load state if available
    system.load_state()
    
    # Start the system
    system.start()
    
    print("""
TWELVE TURNS SYSTEM
==================

Type commands to add to the current turn
Type /help for a list of system commands
Type /quit to exit

""")
    
    print(system.get_visualization())
    print()
    
    # Main loop
    try:
        while system.running:
            # Prompt with current turn info
            if system.color_enabled:
                prompt = f"{Colors.BRIGHT_GREEN}Turn {system.current_turn_index + 1}{Colors.RESET}> "
            else:
                prompt = f"Turn {system.current_turn_index + 1}> "
                
            command = input(prompt).strip()
            
            # Process command
            result = process_command(system, command)
            if result:
                print(result)
                
            # Update system
            system.update()
            
    except KeyboardInterrupt:
        print("\nExiting...")
    finally:
        system.stop()
        print("Twelve Turns System stopped.")

if __name__ == "__main__":
    main()