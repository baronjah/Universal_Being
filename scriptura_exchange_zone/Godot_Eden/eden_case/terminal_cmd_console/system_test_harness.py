#!/usr/bin/env python3
# System Test Harness - Tests integrated systems with progression sequences and error handling
# Connects with all other system components for comprehensive testing

import os
import sys
import time
import json
import random
import math
import threading
import traceback
import signal
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple, Set, Union, Callable

# Try to import from other modules
try:
    from twelve_turns_system import TwelveTurnsSystem, CONFIG as TURNS_CONFIG
    TURNS_AVAILABLE = True
except ImportError:
    TURNS_AVAILABLE = False
    TURNS_CONFIG = {}

try:
    from sensory_layer_system import SensoryLayerSystem, CONFIG as SENSORY_CONFIG
    SENSORY_AVAILABLE = True
except ImportError:
    SENSORY_AVAILABLE = False
    SENSORY_CONFIG = {}

try:
    from attention_color_system import AttentionColorSystem, CONFIG as ATTENTION_CONFIG
    ATTENTION_AVAILABLE = True
except ImportError:
    ATTENTION_AVAILABLE = False
    ATTENTION_CONFIG = {}

# Constants
CONFIG = {
    "test_duration": 3600,         # Total test duration in seconds
    "progression_sequences": [
        [1, 3],
        [2, 4],
        [1, 6, 0, 1],
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        [9, 9]
    ],
    "sequence_change_interval": 300,  # Change sequence every 5 minutes
    "error_test_probability": 0.05,   # Probability of injecting test errors
    "error_types": [
        "value_error",
        "index_error",
        "type_error",
        "zero_division",
        "key_error",
        "attribute_error"
    ],
    "error_recovery_time": 5,      # Seconds to wait after error
    "ai_tools": [
        {"name": "text_generation", "status": "online", "color": "#3498db"},
        {"name": "image_recognition", "status": "offline", "color": "#e74c3c"},
        {"name": "voice_synthesis", "status": "degraded", "color": "#f39c12"},
        {"name": "data_analysis", "status": "online", "color": "#2ecc71"},
        {"name": "movement_tracking", "status": "online", "color": "#9b59b6"}
    ],
    "ai_tool_status_check_interval": 30,  # Check AI tool status every 30 seconds
    "story_elements": {
        "starts": [
            "In the beginning there was data",
            "The system awoke to a sea of information",
            "It started with a single connection",
            "The first pattern emerged from chaos",
            "A dance of numbers began the sequence"
        ],
        "middles": [
            "The patterns grew more complex",
            "Connections formed across the system",
            "New dimensions of understanding emerged",
            "The rhythm of data ebbed and flowed",
            "Colors shifted through the spectrum of meaning"
        ],
        "endings": [
            "Until finally, understanding was reached",
            "The cycle completed, ready to begin anew",
            "The system rested, its work complete for now",
            "All elements harmonized in perfect balance",
            "The story paused, waiting for the next chapter"
        ]
    },
    "narrative_styles": [
        "linear",           # Straightforward progression
        "cyclical",         # Repeating patterns
        "fragmented",       # Broken, non-sequential
        "nested",           # Stories within stories
        "stream_of_consciousness"  # Free-flowing association
    ],
    "seasons": {
        "fallout": 4,
        "happy_tree_friends": 5,
        "adventure_time": 10
    },
    "narration_shift_interval": 450,  # Shift narration style every 7.5 minutes
    "multiplayer_simulation": True,   # Simulate multiple players
    "player_count": 3,               # Number of simulated players
    "player_action_interval": 15,     # Player actions every 15 seconds
    "movement_tracking": True,        # Track simulated body movements
    "movement_to_money_conversion": 0.01,  # Each movement generates 0.01 units of virtual currency
    "bracket_blink_interval": 1.5,    # Text bracket blink every 1.5 seconds
    "text_line_ratio": 13000/23,      # 13k characters ≈ 23 lines of text
    "maya_combo_multiplier": 6547,    # Maya combo turn multiplier
    "hashtag_communication_enabled": True,  # Enable hashtag-based communication
    "spacebar_data_separation": True, # Use spacebars to separate data
    "debug_mode": True,               # Show debug information
    "save_interval": 300,             # Save state every 5 minutes
    "crash_recovery_enabled": True,   # Enable recovery from crashes
    "log_file": "system_test_harness.log"  # Log file for test results
}

class ColorCodes:
    """ANSI color codes for terminal output"""
    RESET = "\033[0m"
    BLACK = "\033[30m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    BLUE = "\033[34m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    WHITE = "\033[37m"
    
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
        """Convert hex color to RGB tuple"""
        hex_color = hex_color.lstrip('#')
        return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
        
    @staticmethod
    def hex(hex_color: str) -> str:
        """Generate color code from hex"""
        r, g, b = ColorCodes.hex_to_rgb(hex_color)
        return ColorCodes.rgb(r, g, b)

class AITool:
    """Represents an AI tool with status and capabilities"""
    
    STATUS_COLORS = {
        "online": ColorCodes.GREEN,
        "offline": ColorCodes.RED,
        "degraded": ColorCodes.YELLOW,
        "maintenance": ColorCodes.BLUE,
        "unknown": ColorCodes.WHITE
    }
    
    def __init__(self, name: str, status: str = "unknown", color: str = "#FFFFFF"):
        self.name = name
        self.status = status
        self.color = color
        self.last_status_change = time.time()
        self.uptime = 0.0
        self.downtime = 0.0
        self.usage_count = 0
        self.success_rate = 1.0
        self.response_time = 0.5  # seconds
        
    def update_status(self, new_status: str) -> bool:
        """Update the status of this AI tool"""
        if new_status == self.status:
            return False
            
        # Calculate time in previous status
        time_in_status = time.time() - self.last_status_change
        
        # Update status tracking
        if self.status == "online":
            self.uptime += time_in_status
        elif self.status in ["offline", "degraded", "maintenance"]:
            self.downtime += time_in_status
            
        # Set new status
        self.status = new_status
        self.last_status_change = time.time()
        
        return True
        
    def use(self, simulate_delay: bool = True) -> Tuple[bool, Any]:
        """Simulate using this AI tool"""
        self.usage_count += 1
        
        # Simulate processing delay
        if simulate_delay:
            time.sleep(self.response_time * random.uniform(0.8, 1.2))
            
        # Determine success based on status
        if self.status == "online":
            success_chance = self.success_rate
        elif self.status == "degraded":
            success_chance = self.success_rate * 0.6
        elif self.status == "maintenance":
            success_chance = self.success_rate * 0.3
        else:  # offline or unknown
            success_chance = 0.0
            
        # Simulate success/failure
        success = random.random() < success_chance
        
        # Generate result
        if success:
            result = f"AI tool '{self.name}' processed request successfully"
        else:
            result = f"AI tool '{self.name}' failed to process request"
            
        return success, result
        
    def get_colored_status(self) -> str:
        """Get status with appropriate color code"""
        color = self.STATUS_COLORS.get(self.status, ColorCodes.WHITE)
        return f"{color}{self.status}{ColorCodes.RESET}"
        
    def get_info(self) -> Dict[str, Any]:
        """Get information about this AI tool"""
        return {
            "name": self.name,
            "status": self.status,
            "color": self.color,
            "uptime": self.uptime,
            "downtime": self.downtime,
            "usage_count": self.usage_count,
            "success_rate": self.success_rate,
            "response_time": self.response_time
        }

class StoryGenerator:
    """Generates narrative stories with different styles"""
    
    def __init__(self, elements: Dict[str, List[str]], styles: List[str]):
        self.elements = elements
        self.styles = styles
        self.current_style = random.choice(styles)
        self.current_season = 1
        self.current_episode = 1
        self.story_arc = []
        self.continuity_elements = {}
        self.character_states = {}
        
    def generate_story_segment(self, segment_type: str = "random") -> str:
        """Generate a story segment of specified type"""
        if segment_type == "start":
            return random.choice(self.elements["starts"])
        elif segment_type == "middle":
            return random.choice(self.elements["middles"])
        elif segment_type == "end":
            return random.choice(self.elements["endings"])
        else:  # random
            all_segments = (
                self.elements["starts"] + 
                self.elements["middles"] + 
                self.elements["endings"]
            )
            return random.choice(all_segments)
            
    def generate_story(self, segments: int = 3) -> str:
        """Generate a complete story with specified number of segments"""
        story = []
        
        # Always start with a start segment
        story.append(self.generate_story_segment("start"))
        
        # Add middle segments
        for _ in range(max(0, segments - 2)):
            story.append(self.generate_story_segment("middle"))
            
        # End with an ending segment
        story.append(self.generate_story_segment("end"))
        
        # Apply current narrative style
        story = self._apply_narrative_style(story)
        
        # Add season/episode information
        story_with_info = self._add_episode_info(story)
        
        return story_with_info
        
    def _apply_narrative_style(self, story_segments: List[str]) -> List[str]:
        """Apply the current narrative style to story segments"""
        styled_segments = story_segments.copy()
        
        if self.current_style == "linear":
            # Linear style is already the default
            pass
            
        elif self.current_style == "cyclical":
            # Repeat elements in a pattern
            if len(styled_segments) > 1:
                first_segment = styled_segments[0]
                styled_segments.append(first_segment)
                
        elif self.current_style == "fragmented":
            # Shuffle segments
            random.shuffle(styled_segments)
            
        elif self.current_style == "nested":
            # Create stories within stories
            if len(styled_segments) > 1:
                nested_idx = random.randint(0, len(styled_segments) - 1)
                nested_story = self.generate_story(2)  # Small nested story
                styled_segments[nested_idx] += f" Within this: {nested_story}"
                
        elif self.current_style == "stream_of_consciousness":
            # Join with ellipses and add thought fragments
            thought_fragments = [
                "...thinking...",
                "...memories flood in...",
                "...connections forming...",
                "...patterns emerging...",
                "...shifting perspective..."
            ]
            
            for i in range(len(styled_segments)):
                if i > 0:
                    # Insert a thought fragment between segments
                    styled_segments[i] = f"{random.choice(thought_fragments)} {styled_segments[i]}"
                    
        # Store in story arc
        self.story_arc.append({
            "style": self.current_style,
            "segments": styled_segments,
            "season": self.current_season,
            "episode": self.current_episode
        })
        
        return styled_segments
        
    def _add_episode_info(self, story_segments: List[str]) -> str:
        """Add season and episode information to the story"""
        header = f"Season {self.current_season}, Episode {self.current_episode}: "
        story_text = " ".join(story_segments)
        
        # Increment episode for next time
        self.current_episode += 1
        
        # Check for season finale
        if self.current_episode > 12:  # 12 episodes per season
            self.current_season += 1
            self.current_episode = 1
            
        return header + story_text
        
    def shift_narrative_style(self) -> str:
        """Shift to a different narrative style"""
        old_style = self.current_style
        
        # Choose a different style
        remaining_styles = [s for s in self.styles if s != old_style]
        self.current_style = random.choice(remaining_styles)
        
        return f"Narrative style shifted from {old_style} to {self.current_style}"
        
    def get_series_info(self, series_name: str) -> Dict[str, Any]:
        """Get information about a specific series"""
        seasons = CONFIG["seasons"].get(series_name.lower(), 0)
        
        if seasons == 0:
            return {"error": f"Unknown series: {series_name}"}
            
        return {
            "name": series_name,
            "seasons": seasons,
            "episodes_per_season": 12,  # Assuming 12 episodes per season
            "total_episodes": seasons * 12,
            "current_style": self.current_style
        }

class SimulatedPlayer:
    """Simulates a player interacting with the system"""
    
    def __init__(self, player_id: int, name: str = ""):
        self.player_id = player_id
        self.name = name or f"Player {player_id}"
        self.virtual_currency = 0.0
        self.actions_performed = 0
        self.movements_tracked = 0
        self.points = 0
        self.active = True
        self.last_action_time = time.time()
        self.last_movement_time = time.time()
        self.position = [0.0, 0.0, 0.0]  # x, y, z
        self.interaction_history = []
        
    def perform_action(self) -> Dict[str, Any]:
        """Perform a random action"""
        # Update last action time
        self.last_action_time = time.time()
        
        # Increment counter
        self.actions_performed += 1
        
        # Choose random action type
        action_types = ["data_input", "query", "navigation", "interaction", "command"]
        action_type = random.choice(action_types)
        
        # Generate action data
        action_data = self._generate_action_data(action_type)
        
        # Add to history
        self.interaction_history.append({
            "time": time.time(),
            "type": action_type,
            "data": action_data
        })
        
        # Return action info
        return {
            "player": self.name,
            "action_type": action_type,
            "action_data": action_data,
            "timestamp": time.time()
        }
        
    def _generate_action_data(self, action_type: str) -> Dict[str, Any]:
        """Generate data for the specified action type"""
        if action_type == "data_input":
            return {
                "content": f"Data input from {self.name}",
                "length": random.randint(10, 100),
                "tags": ["#data", "#input", f"#{self.name.lower()}"]
            }
        elif action_type == "query":
            return {
                "query": f"Query from {self.name}",
                "parameters": {
                    "limit": random.randint(5, 20),
                    "filter": random.choice(["none", "color", "tag", "reason"])
                }
            }
        elif action_type == "navigation":
            return {
                "target": random.choice(["data_pool", "attention_round", "sensory_layer", "turn"]),
                "method": random.choice(["direct", "search", "browse"])
            }
        elif action_type == "interaction":
            return {
                "target_id": f"item_{random.randint(1, 100)}",
                "interaction_type": random.choice(["view", "edit", "tag", "connect", "delete"])
            }
        elif action_type == "command":
            return {
                "command": f"cmd_{random.randint(1, 10)}",
                "parameters": [str(random.randint(1, 100)) for _ in range(random.randint(0, 3))]
            }
        else:
            return {"error": "Unknown action type"}
            
    def track_movement(self) -> Dict[str, Any]:
        """Simulate tracking a physical movement"""
        if not CONFIG["movement_tracking"]:
            return {"error": "Movement tracking disabled"}
            
        # Update last movement time
        self.last_movement_time = time.time()
        
        # Increment counter
        self.movements_tracked += 1
        
        # Generate random movement
        movement_type = random.choice([
            "head_turn", "hand_gesture", "body_shift", 
            "walk", "jump", "sit", "stand"
        ])
        
        # Update position with random movement
        self.position = [
            self.position[0] + random.uniform(-0.5, 0.5),
            self.position[1] + random.uniform(-0.5, 0.5),
            self.position[2] + random.uniform(-0.2, 0.2)
        ]
        
        # Calculate movement magnitude
        magnitude = math.sqrt(sum(p*p for p in self.position))
        
        # Generate virtual currency based on movement
        earned = magnitude * CONFIG["movement_to_money_conversion"]
        self.virtual_currency += earned
        
        # Return movement data
        return {
            "player": self.name,
            "movement_type": movement_type,
            "position": self.position,
            "magnitude": magnitude,
            "currency_earned": earned,
            "timestamp": time.time()
        }
        
    def get_status(self) -> Dict[str, Any]:
        """Get player status information"""
        return {
            "player_id": self.player_id,
            "name": self.name,
            "active": self.active,
            "currency": self.virtual_currency,
            "actions": self.actions_performed,
            "movements": self.movements_tracked,
            "points": self.points,
            "position": self.position,
            "last_action": self.interaction_history[-1] if self.interaction_history else None
        }

class SystemTestHarness:
    """Main test harness for integrated system testing"""
    
    def __init__(self):
        # System components
        self.turns_system = None
        self.sensory_system = None
        self.attention_system = None
        
        # Test state
        self.running = False
        self.current_progression_sequence = CONFIG["progression_sequences"][0]
        self.current_sequence_index = 0
        self.test_start_time = None
        self.last_sequence_change = 0
        self.last_save = 0
        self.error_count = 0
        self.error_recoveries = 0
        self.last_error_time = 0
        
        # AI tool tracking
        self.ai_tools: Dict[str, AITool] = {}
        self.last_ai_status_check = 0
        
        # Story generation
        self.story_generator = StoryGenerator(
            CONFIG["story_elements"],
            CONFIG["narrative_styles"]
        )
        self.last_narration_shift = 0
        
        # Text display
        self.bracket_visible = True
        self.last_bracket_blink = 0
        
        # Multiplayer
        self.players: Dict[int, SimulatedPlayer] = {}
        self.last_player_action = 0
        
        # Test threads
        self.main_thread = None
        self.error_injection_thread = None
        self.status_check_thread = None
        
        # Logging
        self.log_file = CONFIG["log_file"]
        self._init_logging()
        
        # Initialize components
        self._init_components()
        
    def _init_logging(self) -> None:
        """Initialize logging"""
        with open(self.log_file, "w") as f:
            f.write(f"System Test Harness Log - {datetime.now().isoformat()}\n")
            f.write("=" * 50 + "\n\n")
            
    def _log(self, message: str, message_type: str = "INFO") -> None:
        """Log a message to the log file"""
        timestamp = datetime.now().isoformat()
        log_entry = f"[{timestamp}] [{message_type}] {message}\n"
        
        with open(self.log_file, "a") as f:
            f.write(log_entry)
            
        # Print if debug mode is enabled
        if CONFIG["debug_mode"]:
            color = {
                "INFO": ColorCodes.BLUE,
                "ERROR": ColorCodes.RED,
                "WARNING": ColorCodes.YELLOW,
                "SUCCESS": ColorCodes.GREEN,
                "TEST": ColorCodes.MAGENTA
            }.get(message_type, "")
            
            print(f"{color}[{message_type}]{ColorCodes.RESET} {message}")
            
    def _init_components(self) -> None:
        """Initialize test components"""
        # Initialize AI tools
        for tool_info in CONFIG["ai_tools"]:
            tool = AITool(
                tool_info["name"],
                tool_info.get("status", "unknown"),
                tool_info.get("color", "#FFFFFF")
            )
            self.ai_tools[tool.name] = tool
            
        # Initialize simulated players if enabled
        if CONFIG["multiplayer_simulation"]:
            for i in range(CONFIG["player_count"]):
                player = SimulatedPlayer(i, f"Player_{i}")
                self.players[i] = player
                
        # Initialize system components if available
        if TURNS_AVAILABLE:
            try:
                self.turns_system = TwelveTurnsSystem()
                self._log("Twelve Turns System initialized", "SUCCESS")
            except Exception as e:
                self._log(f"Error initializing Twelve Turns System: {e}", "ERROR")
                
        if SENSORY_AVAILABLE:
            try:
                self.sensory_system = SensoryLayerSystem()
                self._log("Sensory Layer System initialized", "SUCCESS")
            except Exception as e:
                self._log(f"Error initializing Sensory Layer System: {e}", "ERROR")
                
        if ATTENTION_AVAILABLE:
            try:
                self.attention_system = AttentionColorSystem()
                self._log("Attention Color System initialized", "SUCCESS")
            except Exception as e:
                self._log(f"Error initializing Attention Color System: {e}", "ERROR")
                
        # Integrate components if available
        self._integrate_components()
                
    def _integrate_components(self) -> None:
        """Integrate available system components"""
        systems_integrated = 0
        
        # Integrate turns and sensory
        if self.turns_system and self.sensory_system:
            try:
                if hasattr(self.sensory_system, "integrate_with_turns"):
                    self.sensory_system.integrate_with_turns(self.turns_system)
                    systems_integrated += 1
                    self._log("Integrated Sensory Layer with Twelve Turns", "SUCCESS")
            except Exception as e:
                self._log(f"Error integrating Sensory and Turns: {e}", "ERROR")
                
        # Integrate turns and attention
        if self.turns_system and self.attention_system:
            try:
                if hasattr(self.attention_system, "integrate_with_turns"):
                    self.attention_system.integrate_with_turns(self.turns_system)
                    systems_integrated += 1
                    self._log("Integrated Attention Color with Twelve Turns", "SUCCESS")
            except Exception as e:
                self._log(f"Error integrating Attention and Turns: {e}", "ERROR")
                
        # Integrate sensory and attention
        if self.sensory_system and self.attention_system:
            try:
                if hasattr(self.attention_system, "integrate_with_sensory"):
                    self.attention_system.integrate_with_sensory(self.sensory_system)
                    systems_integrated += 1
                    self._log("Integrated Attention Color with Sensory Layer", "SUCCESS")
            except Exception as e:
                self._log(f"Error integrating Attention and Sensory: {e}", "ERROR")
                
        self._log(f"Integrated {systems_integrated} system pairs", "INFO")
        
    def start(self) -> bool:
        """Start the test harness"""
        if self.running:
            return True  # Already running
            
        # Record start time
        self.test_start_time = time.time()
        
        # Set running flag
        self.running = True
        
        # Start system components
        if self.turns_system:
            try:
                self.turns_system.start()
                self._log("Started Twelve Turns System", "SUCCESS")
            except Exception as e:
                self._log(f"Error starting Twelve Turns System: {e}", "ERROR")
                
        if self.sensory_system:
            try:
                self.sensory_system.start()
                self._log("Started Sensory Layer System", "SUCCESS")
            except Exception as e:
                self._log(f"Error starting Sensory Layer System: {e}", "ERROR")
                
        if self.attention_system:
            try:
                self.attention_system.start()
                self._log("Started Attention Color System", "SUCCESS")
            except Exception as e:
                self._log(f"Error starting Attention Color System: {e}", "ERROR")
                
        # Start main processing thread
        self.main_thread = threading.Thread(target=self._main_processing_thread)
        self.main_thread.daemon = True
        self.main_thread.start()
        
        # Start error injection thread if enabled
        if CONFIG["error_test_probability"] > 0:
            self.error_injection_thread = threading.Thread(target=self._error_injection_thread)
            self.error_injection_thread.daemon = True
            self.error_injection_thread.start()
            
        # Start status check thread
        self.status_check_thread = threading.Thread(target=self._status_check_thread)
        self.status_check_thread.daemon = True
        self.status_check_thread.start()
        
        self._log("System Test Harness started", "SUCCESS")
        return True
        
    def stop(self) -> None:
        """Stop the test harness"""
        self.running = False
        
        # Wait for threads to end
        if self.main_thread:
            self.main_thread.join(timeout=1.0)
            
        if self.error_injection_thread:
            self.error_injection_thread.join(timeout=1.0)
            
        if self.status_check_thread:
            self.status_check_thread.join(timeout=1.0)
            
        # Stop system components
        if self.turns_system:
            try:
                self.turns_system.stop()
                self._log("Stopped Twelve Turns System", "INFO")
            except Exception as e:
                self._log(f"Error stopping Twelve Turns System: {e}", "ERROR")
                
        if self.sensory_system:
            try:
                self.sensory_system.stop()
                self._log("Stopped Sensory Layer System", "INFO")
            except Exception as e:
                self._log(f"Error stopping Sensory Layer System: {e}", "ERROR")
                
        if self.attention_system:
            try:
                self.attention_system.stop()
                self._log("Stopped Attention Color System", "INFO")
            except Exception as e:
                self._log(f"Error stopping Attention Color System: {e}", "ERROR")
                
        self._log("System Test Harness stopped", "INFO")
        
        # Generate test summary
        self._generate_test_summary()
        
    def _main_processing_thread(self) -> None:
        """Main processing thread for test harness"""
        last_sequence_update = time.time()
        last_player_update = time.time()
        last_narration_update = time.time()
        last_bracket_update = time.time()
        
        while self.running:
            current_time = time.time()
            
            try:
                # Check if test duration has elapsed
                if self.test_start_time and current_time - self.test_start_time >= CONFIG["test_duration"]:
                    self._log("Test duration completed", "SUCCESS")
                    self.running = False
                    break
                    
                # Update progression sequence
                if current_time - last_sequence_update >= CONFIG["sequence_change_interval"]:
                    self._update_progression_sequence()
                    last_sequence_update = current_time
                    
                # Update player actions
                if CONFIG["multiplayer_simulation"] and current_time - last_player_update >= CONFIG["player_action_interval"]:
                    self._process_player_actions()
                    last_player_update = current_time
                    
                # Update narrative style
                if current_time - last_narration_update >= CONFIG["narration_shift_interval"]:
                    self._shift_narration()
                    last_narration_update = current_time
                    
                # Update text bracket blink
                if current_time - last_bracket_update >= CONFIG["bracket_blink_interval"]:
                    self._update_text_bracket()
                    last_bracket_update = current_time
                    
                # Save state periodically
                if current_time - self.last_save >= CONFIG["save_interval"]:
                    self._save_state()
                    self.last_save = current_time
                    
                # Apply current progression value to components
                self._apply_progression_value()
                
                # Sleep to reduce CPU usage
                time.sleep(0.1)
                
            except Exception as e:
                self.error_count += 1
                error_msg = f"Error in main processing thread: {e}"
                error_trace = traceback.format_exc()
                self._log(error_msg, "ERROR")
                self._log(error_trace, "ERROR")
                
                # Recover if enabled
                if CONFIG["crash_recovery_enabled"]:
                    self._recover_from_error()
                    
    def _error_injection_thread(self) -> None:
        """Thread for injecting test errors"""
        while self.running:
            # Random sleep between 5-30 seconds
            sleep_time = random.uniform(5, 30)
            time.sleep(sleep_time)
            
            # Check for error injection
            if random.random() < CONFIG["error_test_probability"]:
                self._inject_test_error()
                
    def _status_check_thread(self) -> None:
        """Thread for checking component status"""
        while self.running:
            current_time = time.time()
            
            # Check AI tool status
            if current_time - self.last_ai_status_check >= CONFIG["ai_tool_status_check_interval"]:
                self._check_ai_tool_status()
                self.last_ai_status_check = current_time
                
            # Sleep to reduce CPU usage
            time.sleep(1.0)
            
    def _update_progression_sequence(self) -> None:
        """Update the current progression sequence"""
        # Get next sequence in rotation
        sequence_idx = (self.current_sequence_index + 1) % len(CONFIG["progression_sequences"])
        self.current_sequence_index = sequence_idx
        self.current_progression_sequence = CONFIG["progression_sequences"][sequence_idx]
        
        self._log(f"Progression sequence changed to {self.current_progression_sequence}", "INFO")
        
    def _apply_progression_value(self) -> None:
        """Apply current progression value to components"""
        # Skip if no progression sequence
        if not self.current_progression_sequence:
            return
            
        # Get current value based on time
        cycle_position = int(time.time()) % len(self.current_progression_sequence)
        value = self.current_progression_sequence[cycle_position]
        
        # Apply to Twelve Turns System
        if self.turns_system and hasattr(self.turns_system, "progression_value"):
            try:
                # Update progression value attribute
                self.turns_system.progression_value = value
            except Exception as e:
                self._log(f"Error applying progression to Twelve Turns: {e}", "ERROR")
                
        # Apply to Sensory Layer System (if applicable)
        if self.sensory_system and hasattr(self.sensory_system, "add_sensory_input"):
            try:
                # Create a sensory input with the progression value
                tag = f"#progression_{value}"
                content = f"Progression value: {value}"
                
                # Add as a sensory input occasionally (not every cycle)
                if random.random() < 0.2:  # 20% chance
                    self.sensory_system.add_sensory_input(
                        random.choice(["visual", "auditory", "intuitive"]),
                        content,
                        0.7,  # Medium-high intensity
                        tags=[tag]
                    )
            except Exception as e:
                self._log(f"Error applying progression to Sensory Layer: {e}", "ERROR")
                
    def _process_player_actions(self) -> None:
        """Process actions from simulated players"""
        for player_id, player in self.players.items():
            if not player.active:
                continue
                
            # Perform player action
            try:
                action_result = player.perform_action()
                
                # Process the action with components
                self._apply_player_action(player, action_result)
                
                # Track movement occasionally
                if CONFIG["movement_tracking"] and random.random() < 0.3:  # 30% chance
                    movement_result = player.track_movement()
                    
                    # Log movement (debug only)
                    if CONFIG["debug_mode"]:
                        self._log(f"Player movement: {player.name} - {movement_result['movement_type']}", "INFO")
                        
            except Exception as e:
                self._log(f"Error processing player {player.name} action: {e}", "ERROR")
                
    def _apply_player_action(self, player: SimulatedPlayer, action: Dict[str, Any]) -> None:
        """Apply a player action to system components"""
        action_type = action.get("action_type", "")
        action_data = action.get("action_data", {})
        
        # Apply to Twelve Turns System
        if action_type == "command" and self.turns_system and hasattr(self.turns_system, "add_command"):
            try:
                # Convert to command string
                command = f"{action_data.get('command', '')} {' '.join(action_data.get('parameters', []))}"
                
                # Add to turns system
                self.turns_system.add_command(command, "player", 5)
            except Exception as e:
                self._log(f"Error applying command to Twelve Turns: {e}", "ERROR")
                
        # Apply to Attention Color System
        if action_type == "data_input" and self.attention_system and hasattr(self.attention_system, "add_data_item"):
            try:
                # Extract data
                content = action_data.get("content", "")
                tags = action_data.get("tags", [])
                
                # Add to attention system
                self.attention_system.add_data_item(content, "player_input", tags)
            except Exception as e:
                self._log(f"Error applying data to Attention Color: {e}", "ERROR")
                
        # Apply to Sensory Layer System
        if action_type == "interaction" and self.sensory_system and hasattr(self.sensory_system, "add_sensory_input"):
            try:
                # Extract data
                target_id = action_data.get("target_id", "")
                interaction_type = action_data.get("interaction_type", "")
                
                # Convert to sensory input
                content = f"Player {player.name} {interaction_type} on {target_id}"
                
                # Determine sensory type based on interaction
                sensory_map = {
                    "view": "visual",
                    "edit": "proprioceptive",
                    "tag": "visual",
                    "connect": "auditory",
                    "delete": "touch"
                }
                
                sensory_type = sensory_map.get(interaction_type, "intuitive")
                
                # Add to sensory system
                self.sensory_system.add_sensory_input(
                    sensory_type,
                    content,
                    0.6,  # Medium intensity
                    source=f"player_{player.player_id}"
                )
                
            except Exception as e:
                self._log(f"Error applying interaction to Sensory Layer: {e}", "ERROR")
                
    def _shift_narration(self) -> None:
        """Shift the narrative style"""
        try:
            result = self.story_generator.shift_narrative_style()
            self._log(result, "INFO")
            
            # Generate a story with new style
            story = self.story_generator.generate_story(3)
            
            # Log the generated story
            self._log(f"Generated story:\n{story}", "INFO")
            
            # Apply to systems if possible
            self._apply_story_to_systems(story)
            
        except Exception as e:
            self._log(f"Error shifting narration: {e}", "ERROR")
            
    def _apply_story_to_systems(self, story: str) -> None:
        """Apply generated story to active systems"""
        # Apply to Twelve Turns System as a command
        if self.turns_system and hasattr(self.turns_system, "add_command"):
            try:
                # Add story as a special command
                self.turns_system.add_command(f"story {story}", "story", 7)
            except Exception as e:
                self._log(f"Error applying story to Twelve Turns: {e}", "ERROR")
                
        # Apply to Attention Color System as data item
        if self.attention_system and hasattr(self.attention_system, "add_data_item"):
            try:
                # Add story as a data item
                tags = ["#story", "#narrative", f"#{self.story_generator.current_style}"]
                self.attention_system.add_data_item(story, "story", tags)
            except Exception as e:
                self._log(f"Error applying story to Attention Color: {e}", "ERROR")
                
    def _update_text_bracket(self) -> None:
        """Update text bracket blinking state"""
        # Toggle bracket visibility
        self.bracket_visible = not self.bracket_visible
        
        # Display bracket if in debug mode
        if CONFIG["debug_mode"]:
            bracket = "[_]" if self.bracket_visible else "[ ]"
            print(f"\rText Bracket: {bracket}", end="")
            
    def _inject_test_error(self) -> None:
        """Inject a test error for system resilience testing"""
        # Skip if too soon after last error
        if time.time() - self.last_error_time < 30:  # At least 30 seconds between errors
            return
            
        # Choose error type
        error_type = random.choice(CONFIG["error_types"])
        
        self._log(f"Injecting test error: {error_type}", "TEST")
        self.last_error_time = time.time()
        
        try:
            # Create appropriate error
            if error_type == "value_error":
                int("not_a_number")
            elif error_type == "index_error":
                [][10]
            elif error_type == "type_error":
                "string" + 123
            elif error_type == "zero_division":
                1 / 0
            elif error_type == "key_error":
                {}["nonexistent_key"]
            elif error_type == "attribute_error":
                object().nonexistent_attribute
        except Exception as e:
            self.error_count += 1
            self._log(f"Test error injected: {e}", "TEST")
            
            # Recover if enabled
            if CONFIG["crash_recovery_enabled"]:
                self._recover_from_error()
                
    def _recover_from_error(self) -> None:
        """Attempt to recover from an error"""
        self._log("Attempting error recovery...", "INFO")
        
        # Wait a bit
        time.sleep(CONFIG["error_recovery_time"])
        
        # Increment recovery counter
        self.error_recoveries += 1
        
        # Reload system components if needed
        if random.random() < 0.3:  # 30% chance to reload components
            self._log("Reloading system components", "INFO")
            
            # Reinitialize components that might be affected
            if self.turns_system is None and TURNS_AVAILABLE:
                try:
                    self.turns_system = TwelveTurnsSystem()
                    self.turns_system.start()
                    self._log("Reinitialized Twelve Turns System", "SUCCESS")
                except Exception as e:
                    self._log(f"Error reinitializing Twelve Turns System: {e}", "ERROR")
                    
            if self.sensory_system is None and SENSORY_AVAILABLE:
                try:
                    self.sensory_system = SensoryLayerSystem()
                    self.sensory_system.start()
                    self._log("Reinitialized Sensory Layer System", "SUCCESS")
                except Exception as e:
                    self._log(f"Error reinitializing Sensory Layer System: {e}", "ERROR")
                    
            if self.attention_system is None and ATTENTION_AVAILABLE:
                try:
                    self.attention_system = AttentionColorSystem()
                    self.attention_system.start()
                    self._log("Reinitialized Attention Color System", "SUCCESS")
                except Exception as e:
                    self._log(f"Error reinitializing Attention Color System: {e}", "ERROR")
                    
            # Re-integrate components
            self._integrate_components()
            
        self._log("Error recovery completed", "SUCCESS")
            
    def _check_ai_tool_status(self) -> None:
        """Check and update AI tool status"""
        for name, tool in self.ai_tools.items():
            # Randomly change status sometimes
            if random.random() < 0.1:  # 10% chance to change status
                # Choose new status
                statuses = ["online", "offline", "degraded", "maintenance"]
                new_status = random.choice(statuses)
                
                # Update status
                if tool.update_status(new_status):
                    self._log(f"AI tool '{name}' status changed to {new_status}", "INFO")
                    
        # Generate status report if in debug mode
        if CONFIG["debug_mode"]:
            self._generate_ai_status_report()
            
    def _generate_ai_status_report(self) -> None:
        """Generate a report of AI tool status"""
        report = ["AI TOOL STATUS REPORT"]
        report.append("=" * 20)
        
        for name, tool in self.ai_tools.items():
            status_str = tool.get_colored_status()
            report.append(f"{name}: {status_str}")
            
        # Print concatenated report
        print("\n".join(report))
        
    def _save_state(self) -> None:
        """Save the state of the test harness"""
        try:
            state = {
                "timestamp": datetime.now().isoformat(),
                "progression_sequence": self.current_progression_sequence,
                "sequence_index": self.current_sequence_index,
                "error_count": self.error_count,
                "error_recoveries": self.error_recoveries,
                "players": {
                    player_id: player.get_status()
                    for player_id, player in self.players.items()
                },
                "ai_tools": {
                    name: tool.get_info()
                    for name, tool in self.ai_tools.items()
                },
                "current_narrative_style": self.story_generator.current_style,
                "current_season": self.story_generator.current_season,
                "current_episode": self.story_generator.current_episode
            }
            
            with open("test_harness_state.json", "w") as f:
                json.dump(state, f, indent=2)
                
            self._log("Test harness state saved", "INFO")
                
        except Exception as e:
            self._log(f"Error saving test harness state: {e}", "ERROR")
            
    def _generate_test_summary(self) -> None:
        """Generate a summary of the test run"""
        if not self.test_start_time:
            return
            
        # Calculate test duration
        duration = time.time() - self.test_start_time
        hours, remainder = divmod(duration, 3600)
        minutes, seconds = divmod(remainder, 60)
        
        # Build summary
        summary = ["\nSYSTEM TEST SUMMARY"]
        summary.append("=" * 70)
        summary.append(f"Test Duration: {int(hours)}h {int(minutes)}m {int(seconds)}s")
        summary.append(f"Error Count: {self.error_count}")
        summary.append(f"Error Recoveries: {self.error_recoveries}")
        summary.append(f"Recovery Rate: {(self.error_recoveries / max(1, self.error_count)) * 100:.1f}%")
        
        # Player statistics
        if self.players:
            total_actions = sum(p.actions_performed for p in self.players.values())
            total_movements = sum(p.movements_tracked for p in self.players.values())
            total_currency = sum(p.virtual_currency for p in self.players.values())
            
            summary.append("\nPLAYER STATISTICS")
            summary.append("-" * 30)
            summary.append(f"Total Players: {len(self.players)}")
            summary.append(f"Total Actions: {total_actions}")
            summary.append(f"Total Movements: {total_movements}")
            summary.append(f"Total Virtual Currency: {total_currency:.2f}")
            
        # AI tool statistics
        if self.ai_tools:
            online_count = sum(1 for t in self.ai_tools.values() if t.status == "online")
            
            summary.append("\nAI TOOL STATISTICS")
            summary.append("-" * 30)
            summary.append(f"Total Tools: {len(self.ai_tools)}")
            summary.append(f"Online Tools: {online_count}")
            summary.append(f"Usage Count: {sum(t.usage_count for t in self.ai_tools.values())}")
            
        # Narrative statistics
        summary.append("\nNARRATIVE STATISTICS")
        summary.append("-" * 30)
        summary.append(f"Current Style: {self.story_generator.current_style}")
        summary.append(f"Season/Episode: {self.story_generator.current_season}/{self.story_generator.current_episode}")
        summary.append(f"Story Arc Length: {len(self.story_generator.story_arc)}")
        
        # Write summary to log
        self._log("\n".join(summary), "SUCCESS")
        
        # Print summary to console
        print("\n".join(summary))
        
    def get_status_report(self) -> str:
        """Generate a status report of the test harness"""
        if not self.test_start_time:
            return "Test not started"
            
        # Calculate test progress
        elapsed = time.time() - self.test_start_time
        total = CONFIG["test_duration"]
        progress = (elapsed / total) * 100
        
        # Build report
        report = ["SYSTEM TEST STATUS"]
        report.append("=" * 70)
        report.append(f"Progress: {progress:.1f}% ({elapsed:.1f}s / {total}s)")
        report.append(f"Current Progression Sequence: {self.current_progression_sequence}")
        report.append(f"Error Count: {self.error_count}")
        report.append(f"Error Recoveries: {self.error_recoveries}")
        
        # Component status
        report.append("\nCOMPONENT STATUS")
        report.append("-" * 30)
        
        if self.turns_system:
            report.append("Twelve Turns System: Active")
        else:
            report.append("Twelve Turns System: Inactive")
            
        if self.sensory_system:
            report.append("Sensory Layer System: Active")
        else:
            report.append("Sensory Layer System: Inactive")
            
        if self.attention_system:
            report.append("Attention Color System: Active")
        else:
            report.append("Attention Color System: Inactive")
            
        # AI tool status
        report.append("\nAI TOOL STATUS")
        report.append("-" * 30)
        
        for name, tool in self.ai_tools.items():
            report.append(f"{name}: {tool.status}")
            
        # Current narrative info
        report.append("\nNARRATIVE STATUS")
        report.append("-" * 30)
        report.append(f"Style: {self.story_generator.current_style}")
        report.append(f"Season: {self.story_generator.current_season}")
        report.append(f"Episode: {self.story_generator.current_episode}")
        
        # Text bracket status
        bracket = "[_]" if self.bracket_visible else "[ ]"
        report.append(f"\nText Bracket: {bracket}")
        
        # Return as string
        return "\n".join(report)
        
    def process_hashtag_message(self, message: str) -> Dict[str, Any]:
        """Process a message with hashtags for communication"""
        if not CONFIG["hashtag_communication_enabled"] or not message:
            return {"error": "Hashtag communication disabled or empty message"}
            
        # Extract hashtags
        words = message.split()
        hashtags = [word for word in words if word.startswith("#")]
        
        # Skip if no hashtags
        if not hashtags:
            return {"error": "No hashtags found in message"}
            
        # Process message based on hashtags
        results = {}
        
        for tag in hashtags:
            tag_lower = tag.lower()
            
            # Count hash characters
            hash_count = 0
            for c in tag:
                if c == '#':
                    hash_count += 1
                else:
                    break
                    
            # Get tag content without hashes
            tag_content = tag[hash_count:]
            
            # Process based on reason level (hash count)
            results[tag] = self._process_tag(tag_content, hash_count, message)
            
        # Apply to systems
        self._apply_hashtag_results(message, hashtags, results)
        
        return results
        
    def _process_tag(self, tag_content: str, reason_level: int, original_message: str) -> Dict[str, Any]:
        """Process a specific tag with associated reason level"""
        result = {
            "tag": tag_content,
            "reason_level": reason_level,
            "processed": True
        }
        
        # Special handling based on tag content
        if tag_content == "reason":
            result["type"] = "reason"
            result["description"] = f"Reason level {reason_level} applied"
            
        elif tag_content == "data":
            result["type"] = "data"
            result["description"] = f"Data with reason level {reason_level}"
            
        elif tag_content == "3d":
            result["type"] = "visualization"
            result["description"] = f"3D visualization at level {reason_level}"
            
        elif tag_content == "sea":
            result["type"] = "data_sea"
            result["description"] = f"Data sea connection at level {reason_level}"
            
        else:
            # General tag
            result["type"] = "general"
            result["description"] = f"General tag '{tag_content}' at level {reason_level}"
            
        return result
        
    def _apply_hashtag_results(self, message: str, hashtags: List[str], results: Dict[str, Dict[str, Any]]) -> None:
        """Apply hashtag processing results to systems"""
        # Apply to Attention Color System
        if self.attention_system and hasattr(self.attention_system, "process_text"):
            try:
                self.attention_system.process_text(message, hashtags)
            except Exception as e:
                self._log(f"Error applying hashtags to Attention Color: {e}", "ERROR")
                
        # Apply to Sensory Layer System
        if self.sensory_system and hasattr(self.sensory_system, "process_text"):
            try:
                self.sensory_system.process_text(message)
            except Exception as e:
                self._log(f"Error applying hashtags to Sensory Layer: {e}", "ERROR")
                
        # Apply to Twelve Turns System
        if self.turns_system and hasattr(self.turns_system, "add_command"):
            try:
                # Convert hashtags to a command
                tag_str = " ".join(hashtags)
                self.turns_system.add_command(f"hashtag {tag_str}", "hashtag", 6)
            except Exception as e:
                self._log(f"Error applying hashtags to Twelve Turns: {e}", "ERROR")

def handle_signal(signum, frame):
    """Handle termination signals"""
    print("\nReceived termination signal. Shutting down test harness...")
    if test_harness and test_harness.running:
        test_harness.stop()
    sys.exit(0)
    
# Register signal handlers
signal.signal(signal.SIGINT, handle_signal)
signal.signal(signal.SIGTERM, handle_signal)

# Global test harness reference
test_harness = None

def main():
    """Main function for the System Test Harness"""
    global test_harness
    print("Initializing System Test Harness...")
    test_harness = SystemTestHarness()
    
    # Start the test harness
    print("Starting tests...")
    test_harness.start()
    
    # Command processing loop
    try:
        while test_harness.running:
            command = input("> ").strip()
            
            if command.lower() in ["quit", "exit"]:
                test_harness.stop()
                break
            elif command.lower() == "status":
                print(test_harness.get_status_report())
            elif command.lower().startswith("story"):
                # Get series name if provided
                parts = command.split(maxsplit=1)
                series_name = parts[1] if len(parts) > 1 else "adventure_time"
                
                # Get series info
                info = test_harness.story_generator.get_series_info(series_name)
                print(f"Series Info for {series_name}:")
                for key, value in info.items():
                    print(f"  {key}: {value}")
            elif command.lower() == "tools":
                # Generate AI tool status report
                test_harness._generate_ai_status_report()
            elif command.lower() == "error":
                # Inject a test error
                test_harness._inject_test_error()
            elif command.startswith("#"):
                # Process as hashtag message
                results = test_harness.process_hashtag_message(command)
                
                # Show results
                print("Hashtag Processing Results:")
                for tag, result in results.items():
                    print(f"  {tag}: {result['description']}")
            else:
                # Process as regular message
                print(f"Command not recognized: {command}")
                
    except KeyboardInterrupt:
        print("\nExiting...")
    finally:
        # Stop test harness if still running
        if test_harness.running:
            test_harness.stop()
            
        print("System Test Harness stopped.")

if __name__ == "__main__":
    main()